#!/usr/bin/env node

const fs = require("fs")
const path = require("path")
const xcode = require("xcode")
const pbxFile = require("./pbxFile")
const utils = require("./pluginUtils")
const f = require("util").format
const Logger = require(`./logger.js`)

const values = []

module.exports = function (context) {
  const projectRoot = context.opts.projectRoot
  const iosPath = path.join(projectRoot, "platforms", "ios")
  const config = utils.getConfigParser(context, path.join(projectRoot, "config.xml"))
  const hp2ConfigsDir = path.join(projectRoot, "Hp2Config")
  const logDir = path.join(hp2ConfigsDir, "logs")
  const hp2EntitlementsDir = path.join(hp2ConfigsDir, "entitlements")
  const projectName = config.name()

  const logger = new Logger({ path: logDir, lauchLogs: false })

  const projectFilePath = path.join(iosPath, `${projectName}.xcodeproj`, "project.pbxproj")

  logger.addLogDaySection(`Executing script that is responsable to reorder extensions and the plugin`)

  utils.getNodeVersion()
  logger.addLogInfoSection(`initial config`)

  // get the bundleIdentifier of the main application
  const bundleIdentifier = config.doc["_root"].attrib.id

  // Defines the Extensions directory
  const extensionsPath = path.join(iosPath, "Extensions")

  // Creates the Extensions directory if it not exists
  if (!fs.existsSync(extensionsPath)) {
    fs.mkdirSync(extensionsPath, { recursive: true })
  }

  // Load the Xcode project file
  const project = xcode.project(projectFilePath)
  project.parseSync()

  logger.append(`iosPath: ${iosPath}`)
  logger.append(`hp2ConfigsDir: ${hp2ConfigsDir}`)
  logger.append(`logDir: ${logDir}`)
  logger.append(`hp2EntitlementsDir: ${hp2EntitlementsDir}`)
  logger.append(`projectName: ${projectName}`)

  logger.addLogInfoSection(`target creation section`)

  // Create variables that will be used at script
  let authExtensionTarget
  let extensionsGroup
  let extensionEntitlementsGroup
  let originalStateExtensionsGroupExists
  let hp2ExtensionTarget
  let hp2Group
  let authGroup

  // check if exists AuthenticationExtension
  authExtensionTarget = findTargetByName({ name: "AuthenticationExtension" })

  // check if exists HP2ClientExtension
  hp2ExtensionTarget = findTargetByName({ name: "HP2ClientExtension" })

  // validate if the 'Extensions' group exists and make a temporary copy of it to hold the actual state before it changes
  extensionsGroup = project.findPBXGroupKey({ name: "Extensions" })
  originalStateExtensionsGroupExists = utils.deepCopy(extensionsGroup)

  extensionEntitlementsGroup = project.findPBXGroupKey({ name: "ExtensionEntitlements" })

  if (!authExtensionTarget) {
    // create a new target to running AuthenticationExtension
    authExtensionTarget = addTargetToProject("AuthenticationExtension")
    logger.append(`auth: ${JSON.stringify(authExtensionTarget)}`)
  } else {
    logger.append("Group 'AuthenticationExtension' is already on project.")
  }

  if (!hp2ExtensionTarget) {
    // create a new target to running HP2ClientExtension
    hp2ExtensionTarget = addTargetToProject("HP2ClientExtension")
  } else {
    logger.append("Group 'HP2ClientExtension' is already on project.")
  }

  if (!extensionsGroup) {
    project.addPbxGroup([], "Extensions", "Extensions")
    extensionsGroup = project.findPBXGroupKey({ name: "Extensions" })
    logger.append("'Extensions' group created into project.")

    // Search the  Custom Template e add Extensions to this
    let groupKey = project.findPBXGroupKey({ name: "CustomTemplate" })
    project.addToPbxGroup(extensionsGroup, groupKey)
  } else {
    logger.append("'Extensions' group already exists on project.")
  }

  if (!extensionEntitlementsGroup) {
    project.addPbxGroup([], "ExtensionEntitlements", "ExtensionEntitlements")
    extensionEntitlementsGroup = project.findPBXGroupKey({ name: "ExtensionEntitlements" })
    logger.append("'ExtensionEntitlements' group created into project.")

    // Search the  Custom Template e add ExtensionEntitlements to this
    let groupKey = project.findPBXGroupKey({ name: "CustomTemplate" })
    project.addToPbxGroup(extensionEntitlementsGroup, groupKey)
  } else {
    logger.append("'ExtensionEntitlements' group already exists on project.")
  }

  // Check if the 'HP2ClientExtension' group exists, otherwise create a new group
  hp2Group = project.findPBXGroupKey({ name: "HP2ClientExtension" })

  // Checks if the 'AuthenticationExtension' group exists, otherwise create a new group
  authGroup = project.findPBXGroupKey({ name: "AuthenticationExtension" })

  if (!hp2Group) {
    project.addPbxGroup([], "HP2ClientExtension", "../Extensions/HP2ClientExtension")

    hp2Group = project.findPBXGroupKey({
      name: "HP2ClientExtension",
    })
    logger.append("'HP2ClientExtension' group created in the Xcode project.")
  } else {
    logger.append("Grupo 'HP2ClientExtension' is already created in the Xcode project.")
  }

  if (!authGroup) {
    project.addPbxGroup([], "AuthenticationExtension", "../Extensions/AuthenticationExtension")
    authGroup = project.findPBXGroupKey({
      name: "AuthenticationExtension",
    })
    logger.append("'AuthenticationExtension' group created in the Xcode project.")
  } else {
    logger.append("'AuthenticationExtension' is already created in the Xcode project.")
  }

  if (!originalStateExtensionsGroupExists) {
    // Add subfolders to Extensions
    project.addToPbxGroup(authGroup, extensionsGroup)
    project.addToPbxGroup(hp2Group, extensionsGroup)
  }

  // project target [primary]
  const projectTarget = findPrimaryTarget()

  logger.append(`AuthenticationExtension uuid: ${authExtensionTarget.uuid}`)
  logger.append(`HP2ClientExtension uuid: ${hp2ExtensionTarget.uuid}`)
  logger.append(`Project uuid: ${projectTarget.uuid}`)

  logger.addLogInfoSection(`setup files in each extension`)

  // Create a custom object to easily build extensions
  const extensions = [
    {
      dir: path.join(extensionsPath, "AuthenticationExtension"),
      name: "AuthenticationExtension",
      target: authExtensionTarget,
      groupKey: authGroup,
      buildPhases: getFaultBuildPhases(authExtensionTarget),
      entitlement: "AuthenticationExtension.entitlements",
    },
    {
      dir: path.join(extensionsPath, "HP2ClientExtension"),
      name: "HP2ClientExtension",
      target: hp2ExtensionTarget,
      groupKey: hp2Group,
      buildPhases: getFaultBuildPhases(hp2ExtensionTarget),
      entitlement: "HP2ClientExtension.entitlements",
    },
  ]

  // iterates each extension
  extensions.forEach((extension) => {
    if (!fs.existsSync(extension.dir)) {
      fs.mkdirSync(extension.dir, { recursive: true })
      logger.append(` Extension '${extension.name}' directory created at: ${extension.dir}`)
    }

    // Directory where plugin files are stored
    const sourceDir = path.join(context.opts.plugin.dir, "src", "ios", "Extensions", extension.name)
    logger.append(`buildPhases: ${JSON.stringify(extension.buildPhases)}`)

    // Add buildPhases that are fault
    extension.buildPhases.forEach((phase) => {
      project.addBuildPhase([], phase.identifier, phase.type, extension.target.uuid)
    })

    // Verifies source directory existence prior to copying
    if (fs.existsSync(sourceDir)) {
      // Copies plugin directory contents to the app destination
      copyDirectorySyncExtension(sourceDir, extension.dir, extension, path.join("..", ".."))
    } else {
      console.error(`The origin directory ${sourceDir} does't exists.`)
    }
  })

  logger.addLogInfoSection(`Add UniformTypeIdentifiers.framework to targets`)

  // Control and add UniformTypeIdentifiers.framework to extensions
  let hasFrameworkIdentifierAtHp2ClientExtension = false
  let hasFrameworkIdentifierAtAuthenticationExtension = false

  try {
    const pbxFrameworksBuildPhaseAuth = project.pbxFrameworksBuildPhaseObj(authExtensionTarget.uuid)
    const authUniformTypeId = pbxFrameworksBuildPhaseAuth.files.filter((item) =>
      item.comment.includes("UniformTypeIdentifiers.framework")
    )
    logger.append(`pbxFrameworksBuildPhaseAuth: ${JSON.stringify(pbxFrameworksBuildPhaseAuth)}`)
    logger.append(`authUniformTypeId: ${JSON.stringify(authUniformTypeId)}`)
    hasFrameworkIdentifierAtAuthenticationExtension = !!authUniformTypeId.length
  } catch (err) {
    logger.append(`UniformTypeIdentifiers authExt finder error: ${err}`)
  }

  try {
    const pbxFrameworksBuildPhaseHp2 = project.pbxFrameworksBuildPhaseObj(hp2ExtensionTarget.uuid)
    const hp2UniformTypeId = pbxFrameworksBuildPhaseHp2.files.filter((item) =>
      item.comment.includes("UniformTypeIdentifiers.framework")
    )
    logger.append(`pbxFrameworksBuildPhaseHp2: ${JSON.stringify(pbxFrameworksBuildPhaseHp2)}`)
    logger.append(`hp2UniformTypeId: ${JSON.stringify(hp2UniformTypeId)}`)
    hasFrameworkIdentifierAtHp2ClientExtension = !!hp2UniformTypeId.length
  } catch (err) {
    logger.append(`UniformTypeIdentifiers hp2Ext finder error: ${err}`)
  }

  logger.append(
    `hasFrameworkIdentifierAtHp2ClientExtension: ${hasFrameworkIdentifierAtHp2ClientExtension}
    hasFrameworkIdentifierAtAuthenticationExtension: ${hasFrameworkIdentifierAtAuthenticationExtension}`
  )

  // If UniformTypeIdentifiers.framework don't exists add to the extensions
  if (!hasFrameworkIdentifierAtHp2ClientExtension) {
    addFramework("System/Library/Frameworks/UniformTypeIdentifiers.framework", {
      target: hp2ExtensionTarget.uuid,
      link: true,
      embed: true,
    })
  }

  if (!hasFrameworkIdentifierAtAuthenticationExtension) {
    addFramework("System/Library/Frameworks/UniformTypeIdentifiers.framework", {
      target: authExtensionTarget.uuid,
      link: true,
      embed: true,
    })
  }

  const frameworksNative = ["AlamofireHST.xcframework", "HP2AppleSDK.xcframework", "HP2AuthorizationClient.xcframework"]

  logger.addLogInfoSection(`Remove frameworks not used - HP2ClientExtension`)

  removeFramework(hp2ExtensionTarget, frameworksNative, { phaseName: "Frameworks" })

  logger.addLogInfoSection(`Add frameworks into HP2ClientExtension`)

  // Add frameworks to HP2ClientExtension
  frameworksNative.forEach((framework) => {
    const frameworkPbxFile = findAtPBXFileReference(framework)
    logger.append(`framework to be added into HP2ClientExtension: ${JSON.stringify(frameworkPbxFile)}`)

    if (frameworkPbxFile) {
      let file = new pbxFile(frameworkPbxFile.path, {})
      file.fileRef = frameworkPbxFile.uuid
      file.uuid = project.generateUuid()
      file.target = hp2ExtensionTarget.uuid

      try {
        project.addToPbxBuildFileSection(file)
        project.addToPbxFrameworksBuildPhase(file)
      } catch (error) {
        logger.append(`error save frameworks into new buildPhase in HP2ClientExtension.\nCaused by: ${error}`)
      }
    }
  })
  logger.append(`completed add framework to HP2ClientExtension process.`)

  logger.addLogInfoSection(`Add Model share into targets`)

  // get the project`s Model.xcdatamodeId from plugin folder
  const modelFile = findAtPBXFileReference("Model.xcdatamodeld")

  if (modelFile) {
    const fpathh = path.join(iosPath, "Model.xcdatamodeld")
    const optt = {}

    // Add target membership Model to HP2ClientExtension
    let modelToHp2 = new pbxFile(fpathh, optt)
    modelToHp2.fileRef = modelFile.uuid
    modelToHp2.uuid = project.generateUuid()
    modelToHp2.target = hp2ExtensionTarget.uuid

    project.addToPbxBuildFileSection(modelToHp2)
    project.addToPbxSourcesBuildPhase(modelToHp2)

    // Add target membership Model to AuthenticationExtension
    let modelToAuthExtension = new pbxFile(fpathh, optt)
    modelToAuthExtension.fileRef = modelFile.uuid
    modelToAuthExtension.uuid = project.generateUuid()
    modelToAuthExtension.target = authExtensionTarget.uuid

    project.addToPbxBuildFileSection(modelToAuthExtension)
    project.addToPbxSourcesBuildPhase(modelToAuthExtension)
  }

  logger.addLogInfoSection(`set entitlements files`)

  // Check for Entitlements references
  let authExtensionEntitlement = findAtPBXFileReference("AuthenticationExtension.entitlements")
  let hp2ExtensionEntitlement = findAtPBXFileReference("HP2ClientExtension.entitlements")

  logger.append(
    `authExtEntitlement: ${JSON.stringify(authExtensionEntitlement)}
    hp2ExtEntitlement: ${JSON.stringify(hp2ExtensionEntitlement)}`
  )

  if (!authExtensionEntitlement) {
    // copy from Hp2Config/entitlements [AuthenticationExtension.entitlements] if exists to Extension directory
    regroupEntitlement("AuthenticationExtension.entitlements")
  }

  if (!hp2ExtensionEntitlement) {
    // copy from Hp2Config/entitlements [HP2ClientExtension.entitlements] if exists to Extension directory
    regroupEntitlement("HP2ClientExtension.entitlements")
  }

  logger.addLogInfoSection(`change props of buildSettings`)

  // Access target's build settings
  const buildConfigs = project.pbxXCBuildConfigurationSection()

  const authEntitlementFilePath = utils.findFileInDirectory(iosPath, "AuthenticationExtension.entitlements")
  const hp2EntitlementFilePath = utils.findFileInDirectory(iosPath, "HP2ClientExtension.entitlements")

  logger.append(
    `authEntitlementFilePath: ${authEntitlementFilePath} | hp2EntitlementFilePath: ${hp2EntitlementFilePath}`
  )

  Object.keys(buildConfigs).forEach((configKey) => {
    const buildConfig = buildConfigs[configKey]

    extensions.forEach((extension) => {
      if (buildConfig.buildSettings && buildConfig.buildSettings.PRODUCT_NAME === `"${extension.name}"`) {
        buildConfig.buildSettings.GENERATE_INFOPLIST_FILE = "YES"
        buildConfig.buildSettings.INFOPLIST_FILE = `Extensions/${extension.name}/Info.plist`
        buildConfig.buildSettings.INFOPLIST_KEY_CFBundleDisplayName = extension.name
        buildConfig.buildSettings.CURRENT_PROJECT_VERSION = 1
        buildConfig.buildSettings.IPHONEOS_DEPLOYMENT_TARGET = `14.0`

        logger.append(
          `extensionName: ${extension.name}
           isEqual: ${extension.name == "AuthenticationExtension" || extension.name == "HP2ClientExtension"}`
        )

        if (
          (extension.name == "AuthenticationExtension" && !!authEntitlementFilePath) ||
          (extension.name == "HP2ClientExtension" && !!hp2EntitlementFilePath)
        ) {
          // Set the path to entitlement to property CODE_SIGN_ENTITLEMENTS in each buildSettings
          const entitlementPath =
            extension.name === "AuthenticationExtension" ? authEntitlementFilePath : hp2EntitlementFilePath

          let pathRelative = path.relative(iosPath, entitlementPath)

          buildConfig.buildSettings.CODE_SIGN_ENTITLEMENTS = pathRelative
          logger.append(`Atualizado CODE_SIGN_ENTITLEMENTS para o target: ${extension.name}`)
        }
      }
    })
  })

  // In the end save all changed configs
  try {
    fs.writeFileSync(projectFilePath, project.writeSync())
    logger.append("Changes saved to Xcode project file.")
  } catch (err) {
    logger.append("Error when saving to Xcode project file.", err)
  }

  // save logs on file
  logger.saveLogs()

  // ===================================
  // Functions
  // ===================================

  function addTargetToProject(targetName) {
    return project.addTarget(targetName, `app_extension`, projectName, `${bundleIdentifier}.${targetName}`)
  }

  // Function to copy folder recursevely
  function copyDirectorySyncExtension(src, dest, extension, cumulative) {
    if (!fs.existsSync(dest)) {
      fs.mkdirSync(dest, {
        recursive: true,
      })
    }

    fs.readdirSync(src).forEach((item) => {
      const srcItem = path.join(src, item)
      const destiny = path.join(dest, item)

      if (fs.lstatSync(srcItem).isDirectory()) {
        let cumulativeOut = path.join(cumulative, "..")
        dest = copyDirectorySyncExtension(srcItem, destiny, extension, cumulativeOut)
      } else {
        fs.copyFileSync(srcItem, destiny)
        const destItemRelative = path.relative(iosPath, destiny)
        const destItem = path.join(cumulative, destItemRelative)

        // .plist should be added only in target and project
        if (!destiny.includes(".plist") && !destiny.includes("Action.js")) {
          project.addSourceFile(destItem, { target: extension.target.uuid }, extension.groupKey)
        } else {
          justAddSourceFile(destItem, { target: extension.target.uuid }, extension.groupKey)
        }
      }
    })
  }

  // Function to copy folder recursevely
  function copyDirectorySync(src, dest, callback) {
    if (!fs.existsSync(dest)) {
      fs.mkdirSync(dest, {
        recursive: true,
      })
    }

    logger.append(`callback: ${JSON.stringify(callback)}`)

    fs.readdirSync(src).forEach((item) => {
      const srcItem = path.join(src, item)
      const destItem = path.join(dest, item)

      if (fs.lstatSync(srcItem).isDirectory()) {
        copyDirectorySync(srcItem, destItem, callback)
      } else {
        fs.copyFileSync(srcItem, destItem)

        if (callback) {
          callback(destItem)
        }
      }
    })
  }

  function regroupEntitlement(entitlement) {
    const authEntitlementPath = path.join(hp2EntitlementsDir, entitlement)
    let destItemFolder = path.join(iosPath, "ExtensionEntitlements")
    let destItem = path.join(destItemFolder, entitlement)
    let destItemRelative = path.relative(iosPath, destItem)
    destItemRelative = path.join("..", destItemRelative)

    // Creates the Extensions directory if it not exists
    if (!fs.existsSync(destItemFolder)) {
      fs.mkdirSync(destItemFolder, { recursive: true })
    }

    logger.append(`authEntitlementPath: ${authEntitlementPath} | destItem: ${destItem}`)

    if (fs.existsSync(authEntitlementPath)) {
      fs.copyFileSync(authEntitlementPath, destItem)
      justAddSourceFile(destItemRelative, { target: projectTarget.uuid }, extensionEntitlementsGroup)
    }
  }

  // From a default list of buildPhases for extension check which target don't have configured
  function getFaultBuildPhases(target) {
    const buildPhases = target.pbxNativeTarget.buildPhases

    logger.append(`buildPhases for target [${target.uuid}]: ${JSON.stringify(buildPhases)}`)

    const defaultBuildPhases = [
      { identifier: "PBXSourcesBuildPhase", type: "Sources" },
      { identifier: "PBXFrameworksBuildPhase", type: "Frameworks" },
      { identifier: "PBXResourcesBuildPhase", type: "Resources" },
    ]

    return defaultBuildPhases.filter((phase) => !buildPhases.some((targetPhase) => targetPhase.comment === phase.type))
  }

  function findAtPBXFileReference(fileName) {
    const fileReference = project.pbxFileReferenceSection()
    let arrayOfReferences = []

    Object.keys(fileReference).forEach((key) => {
      const fileRef = fileReference[key]

      if (
        fileRef &&
        fileRef.name &&
        (fileRef.name == fileName ||
          fileRef.name.includes(fileName) ||
          (fileRef.name.includes(`"${fileName}"`) && fileRef.path.includes(`cordova-plugin-apple-wallet`)))
      ) {
        let foundFile = fileRef
        foundFile.uuid = key
        arrayOfReferences.push(foundFile)
      }
    })

    logger.append(`try find: ${fileName} | listOfReferences: ${JSON.stringify(arrayOfReferences)}`)
    return arrayOfReferences && arrayOfReferences.length > 0 ? arrayOfReferences[0] : undefined
  }

  function addFramework(fpath, opt) {
    let customFramework = opt && opt.customFramework == true
    let link = !opt || opt.link == undefined || opt.link // defaults to true if not specified
    let embed = opt && opt.embed // defaults to false if not specified

    if (opt) {
      delete opt.embed
    }

    let file = new pbxFile(fpath, opt)

    logger.append(`framework: ${JSON.stringify(file)}`)

    file.uuid = project.generateUuid()
    file.fileRef = project.generateUuid()
    file.target = opt ? opt.target : undefined

    project.addToPbxBuildFileSection(file) // PBXBuildFile
    project.addToPbxFileReferenceSection(file) // PBXFileReference
    project.addToFrameworksPbxGroup(file) // PBXGroup

    if (link) {
      project.addToPbxFrameworksBuildPhase(file) // PBXFrameworksBuildPhase
    }

    if (customFramework) {
      project.addToFrameworkSearchPaths(file)

      if (embed) {
        opt.embed = embed
        let embeddedFile = new pbxFile(fpath, opt)

        embeddedFile.uuid = project.generateUuid()
        embeddedFile.fileRef = file.fileRef

        // keeping a separate PBXBuildFile entry for Embed Frameworks
        project.addToPbxBuildFileSection(embeddedFile) // PBXBuildFile
        project.addToPbxEmbedFrameworksBuildPhase(embeddedFile) // PBXCopyFilesBuildPhase

        return embeddedFile
      }
    }

    return file
  }

  // Function to find existing target by name
  function findTargetByName(targetProps) {
    const targetName = targetProps.name
    const targets = project.pbxNativeTargetSection()

    for (const uuid in targets) {
      const target = targets[uuid]
      if (target.name === `"${targetName}"`) {
        return { uuid, pbxNativeTarget: target }
      }
    }

    return null
  }

  function justAddSourceFile(path, opt, group) {
    let file
    if (group) {
      file = project.addFile(path, group, opt)
    } else {
      file = project.addPluginFile(path, opt)
    }

    if (!file) return false

    file.target = opt ? opt.target : undefined
    file.uuid = project.generateUuid()

    project.addToPbxBuildFileSection(file) // PBXBuildFile

    return file
  }

  function findPrimaryTarget() {
    const targets = project.pbxNativeTargetSection()

    for (const uuid in targets) {
      const target = targets[uuid]

      if (!target || typeof target !== "object") continue

      if (target.productType === '"com.apple.product-type.application"') {
        return {
          uuid: uuid,
          pbxNativeTarget: target,
        }
      }
    }
    return null
  }

  function removeFramework(target, frameworksToRemove, opt) {
    try {
      if (!opt && !opt.phaseName) {
        console.error(`not implemented yet without prop [opt.phaseName].`)
        return
      }

      const phaseName = opt && opt.phaseName ? opt.phaseName : undefined
      const buildPhases = target.pbxNativeTarget.buildPhases
      // const filteredBuildPhase = phaseName ? [buildPhases.find((phase) => phase.comment === phaseName)] : buildPhases //future
      const filteredBuildPhase = phaseName ? buildPhases.find((phase) => phase.comment === phaseName) : buildPhases

      logger.append(`buildPhases: ${JSON.stringify(filteredBuildPhase)}`)
      logger.append(`frameworks: ${JSON.stringify(frameworksToRemove)}`)

      if (!filteredBuildPhase) {
        console.error(`No PBXCopyFilesBuildPhase found for target ${target.uuid}.`)
        return
      }

      const projectBuildFiles = project.hash.project.objects["PBXFrameworksBuildPhase"]
      logger.append(`\nnode of files [projectBuildFiles]: ${JSON.stringify(projectBuildFiles)}`)
      const node = projectBuildFiles[filteredBuildPhase.value]
      logger.append(`node of files [buildPhase HP2ClientExtension]: ${JSON.stringify(node)}`)

      const filesToRemove = []

      if (node.files) {
        node.files.forEach((file) => {
          for (fm in frameworksToRemove) {
            if (file && file.comment && file.comment.includes(frameworksToRemove[fm])) {
              logger.append(`framework to be removed: ${frameworksToRemove[fm]}`)
              try {
                filesToRemove.push(file)
              } catch (err) {
                logger.append(`error reading files from buildPhases: ${JSON.stringify(err)}`)
              }
            }
          }

          let filteredItems = node.files.filter(
            (item) =>
              !filesToRemove.some((toRemove) => toRemove.value === item.value && toRemove.comment === item.comment)
          )
          if (
            projectBuildFiles &&
            projectBuildFiles[filteredBuildPhase.value] &&
            projectBuildFiles[filteredBuildPhase.value].files
          ) {
            projectBuildFiles[filteredBuildPhase.value].files = filteredItems
          }
        })

        logger.append(`filesToRemove: ${JSON.stringify(filesToRemove)}`)
        logger.append(
          `new file buildPhases for target: ${JSON.stringify(
            project.hash.project.objects["PBXFrameworksBuildPhase"][filteredBuildPhase.value]
          )}\n-------`
        )
      }
    } catch (errr) {
      logger.append(`error on process removeNode: \ncaused by: ${errr}`)
    }
  }
}
