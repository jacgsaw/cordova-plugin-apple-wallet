#!/usr/bin/env node

const fs = require("fs")
const path = require("path")
const xcode = require("xcode")
const utils = require("./pluginUtils")

module.exports = function (context) {
  // this is just to not block execution if it`s present a error
  try {
    const projectRoot = context.opts.projectRoot
    const plistLibPath = path.join(projectRoot, "plugins" ,"cordova-plugin-apple-wallet", "src", "ios", "libs", "js", "plist")
    const plist = require(plistLibPath)
    const appConfigFile = path.join(projectRoot, "build.json")
    const iosPath = path.join(projectRoot, "platforms", "ios")
    const config = utils.getConfigParser(context, path.join(projectRoot, "config.xml"))
    const projectName = config.name()

    const projectInfoPlist = path.join(iosPath, projectName, `${projectName}-Info.plist`)
    const hp2ClientInfoPlist = path.join(iosPath, "Extensions", "HP2ClientExtension", `Info.plist`)
    const projectFilePath = path.join(iosPath, `${projectName}.xcodeproj`, "project.pbxproj")

    // Get the bundleIdentifier of the main application
    const bundleIdentifier = config.doc["_root"].attrib.id

    // Load the Xcode project file
    const project = xcode.project(projectFilePath)
    project.parseSync()

    let appConfig = {}

    try {
      if (fs.existsSync(appConfigFile)) {
        appConfig = JSON.parse(fs.readFileSync(appConfigFile, "utf8"))
      }
    } catch (ignore) {}

    // Setup Environment Signing
    setupEnvironmentSigningConfig(appConfig, bundleIdentifier)

    // Edit .plist files
    editPlistProjectToIncludeFaceIDDescription(projectInfoPlist)
    editPlistHP2ExtensionToIncludeInstCodeAndGroupID()

    // Edit MainViewController.m file adding code - just for app example
    // insertBiometricCodeIntoMainViewController()

    function setupEnvironmentSigningConfig() {
      const appExtensions = ["HP2ClientExtension", "AuthenticationExtension"]

      if (appConfig && appConfig["signing-dev-team"] && appConfig["signing-dev-team"]["signing"]) {
        let signAlsoProject = false
        const signing = appConfig["signing-dev-team"]["signing"]

        try {
          signAlsoProject = appConfig["signing-dev-team"]["also-project"]
        } catch (ignore) {}

        const buildConfigs = project.pbxXCBuildConfigurationSection()

        Object.keys(buildConfigs).forEach((configKey) => {
          const buildConfig = buildConfigs[configKey]

          if (
            signAlsoProject &&
            buildConfig.buildSettings &&
            buildConfig.buildSettings.PRODUCT_BUNDLE_IDENTIFIER &&
            (buildConfig.buildSettings.PRODUCT_BUNDLE_IDENTIFIER === `${bundleIdentifier}` ||
              buildConfig.buildSettings.PRODUCT_BUNDLE_IDENTIFIER === `"${bundleIdentifier}"`)
          ) {
            buildConfig.buildSettings.DEVELOPMENT_TEAM = signing
          }

          appExtensions.forEach((extension) => {
            if (buildConfig.buildSettings && buildConfig.buildSettings.PRODUCT_NAME === `"${extension}"`) {
              buildConfig.buildSettings.DEVELOPMENT_TEAM = signing
            }
          })
        })
      }

      try {
        fs.writeFileSync(projectFilePath, project.writeSync())
        console.log("Changes saved to Xcode project file.")
      } catch (err) {
        console.error("Error when saving to Xcode project file.", err)
      }
    }

    function editPlistProjectToIncludeFaceIDDescription() {
      try {
        let plistObject = {}

        if (fs.existsSync(projectInfoPlist)) {
          const existingPlistContent = fs.readFileSync(projectInfoPlist, "utf8")
          plistObject = plist.parse(existingPlistContent)
        }

        // console.log(`plistObject: ${JSON.stringify(plistObject)}`)

        if (appConfig && appConfig["ns-face-id-usage-description"]) {
          plistObject["NSFaceIDUsageDescription"] = appConfig["ns-face-id-usage-description"]
        } else {
          plistObject["NSFaceIDUsageDescription"] =
            "Se utilizarán las credenciales biométricas registradas en tu dispositivo, ¿Deseas continuar?"
        }

        const updatedPlistContent = plist.build(plistObject)
        fs.writeFileSync(projectInfoPlist, updatedPlistContent)

        // console.log(`JSON properties have been updated in .plist: ${projectInfoPlist}`)
      } catch (err) {
        console.log(`error when try update plsit project.\nCaused by: ${err}`)
      }
    }

    function editPlistHP2ExtensionToIncludeInstCodeAndGroupID() {
      try {
        let plistObject = {}

        if (fs.existsSync(hp2ClientInfoPlist)) {
          const existingPlistContent = fs.readFileSync(hp2ClientInfoPlist, "utf8")
          plistObject = plist.parse(existingPlistContent)
        }

        // console.log(`plistObject: ${JSON.stringify(plistObject)}`)

        if (appConfig && appConfig["institution-code"]) {
          plistObject["institutionCode"] = appConfig["institution-code"]
        }

        if (appConfig && appConfig["group-id"]) {
          plistObject["groupID"] = appConfig["group-id"]
        }

        const updatedPlistContent = plist.build(plistObject)
        fs.writeFileSync(hp2ClientInfoPlist, updatedPlistContent)

        // console.log(`JSON properties have been updated in .plist: ${hp2ClientInfoPlist}`)
      } catch (err) {
        console.log(`error when try update plsit HP2ClientExtension.\nCaused by: ${err}`)
      }
    }

    function insertBiometricCodeIntoMainViewController() {
      const authenticateUserMethod = "[self authenticateUser];"
      const biometricImport = `#import <LocalAuthentication/LocalAuthentication.h>\n`
      const filePath = path.join(iosPath, projectName, "./MainViewController.m")
      const codeMethodPath = path.join(
        projectRoot,
        "plugins",
        "cordova-plugin-apple-wallet",
        "src",
        "ios",
        "code",
        "main-view-controller.txt"
      )

      try {
        let fileContent = fs.readFileSync(filePath, "utf8")

        const viewDidLoadRegex = /(-\s*\(void\)\s*viewDidLoad\s*\{[^}]*\})/g
        const endMarker = "@end"

        if (!fileContent.includes(authenticateUserMethod)) {
          if (viewDidLoadRegex.test(fileContent)) {
            fileContent = fileContent.replace(viewDidLoadRegex, (match) => {
              return match.replace(/(\n?\s*\})$/, `\n    ${authenticateUserMethod}$1`)
            })
            console.log(`Method ${authenticateUserMethod} inserted inside viewDidLoad.`)
          } else {
            fileContent = fileContent.replace(
              endMarker,
              `\n- (void)viewDidLoad {\n    [super viewDidLoad];\n    ${authenticateUserMethod}\n}\n\n@end`
            )
            console.log("viewDidLoad method not found, it was created above @end.")
          }
        } else {
          console.log("The method is already present in the file.")
        }

        if (biometricImport && !fileContent.includes(biometricImport)) {
          fileContent = `${biometricImport}${fileContent}`
          console.log(`Import ${biometricImport} inserted at the beginning of the file.`)
        }

        try {
          const hash = "//@b5d72bb4eb6154384459a114f7019c2d==//@ don't remove it"
          if (fileContent.includes(hash)) {
            console.log("The method has already been inserted previously.")
            return
          }

          const methodContent = fs.readFileSync(codeMethodPath)
          const methodWithHash = `\n${hash}\n${methodContent}\n${hash}\n`
          fileContent = fileContent.replace(/@end/g, `${methodWithHash}\n@end`)

          console.log("Method inserted successfully!")
        } catch (error) {
          console.error("Error inserting the method:", error)
        }

        fs.writeFileSync(filePath, fileContent, "utf8")
        console.log("File updated successfully!")
      } catch (err) {
        console.error("Error processing the file:", err)
      }
    }
  } catch (errr) {}
}
