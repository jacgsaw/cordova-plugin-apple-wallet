const semver = require("semver")
const exec = require("child_process").exec
const fs = require("fs")
const path = require("path")

var COMMENT_KEY = /_comment$/

const deepCopy = (obj) => {
  if (obj === null || typeof obj !== "object") {
    return obj
  }
  if (Array.isArray(obj)) {
    return obj.map((item) => deepCopy(item))
  }
  const copy = {}
  for (const key in obj) {
    if (obj.hasOwnProperty(key)) {
      copy[key] = deepCopy(obj[key])
    }
  }
  return copy
}

const findFileRef = (filePath, project) => {
  // Add a framework dependency to the project.
  const fileRefSection = project.pbxFileReferenceSection()
  let fileRef

  // Check if there is already a reference to the framework
  Object.keys(fileRefSection).some((ref) => {
    if (fileRefSection[ref].path === filePath || fileRefSection[ref].path === `"${filePath}"`) {
      logInfo(`found file`)
      fileRef = ref
      return true
    }
    return false
  })
  return fileRef
}

const hasFile = (project, filePath) => {
  var files = nonComments(project.pbxFileReferenceSection()),
    file,
    id

  for (id in files) {
    file = files[id]

    if (file.path == filePath || file.path == '"' + filePath + '"') {
      console.log(`file: ${JSON.stringify(file)}`)
      return file
    }
  }

  console.log(`file not found`)
  return false
}

const nonComments = (obj) => {
  var keys = Object.keys(obj),
    newObj = {},
    i = 0

  for (i; i < keys.length; i++) {
    if (!COMMENT_KEY.test(keys[i])) {
      newObj[keys[i]] = obj[keys[i]]
    }
  }

  return newObj
}

const setRelativePath = (pathFile, pathOrigin) => {
  const relativePath = path.relative(pathOrigin, pathFile)
  console.log(`\n\n ---> ${relativePath}\n\n`)
  return relativePath
}

// Adds multiple .appex files to the PBXCopyFilesBuildPhase
const addAppExtensionsToBuildPhase = (appExtensionNames) => {
  const filePaths = []

  // Iterates through a list of extensions to find matching .appex files
  appExtensionNames.forEach((appExtensionName) => {
    const filePath = findFileInProject(`${appExtensionName}.appex`)

    if (filePath) {
      filePaths.push(filePath) // Only adds files with valid references
    } else {
      console.error(`Extensão ${appExtensionName}.appex não foi encontrada no projeto.`)
    }
  })

  if (filePaths.length > 0) {
    // Creates the build phase if needed
    const buildPhase = project.addBuildPhase(
      filePaths,
      "PBXCopyFilesBuildPhase",
      "Embed App Extensions",
      project.getFirstTarget().uuid,
      "Embed App Extensions"
    )

    // Sets the correct destination
    if (buildPhase) {
      buildPhase.buildPhase.dstSubfolderSpec = "13"
      console.log("Fase de cópia criada com sucesso e extensões adicionadas.")
    }
  } else {
    console.error("Nenhum arquivo .appex foi encontrado para adicionar.")
  }
}

const getConfigParser = (context, configPath) => {
  let ConfigParser

  if (semver.lt(context.opts.cordova.version, "5.4.0")) {
    ConfigParser = context.requireCordovaModule("cordova-lib/src/ConfigParser/ConfigParser")
  } else {
    ConfigParser = context.requireCordovaModule("cordova-common/src/ConfigParser/ConfigParser")
  }

  return new ConfigParser(configPath)
}

const getNodeVersion = () => {
  try {
    const nodeVersion = process.version
    return nodeVersion
  } catch (ignore) {
    return "undefined"
  }
}

const getCordovaVersion = (callback) => {
  try {
    exec("cordova -v", (err, stdout, stderr) => {
      if (err) {
        callback("undefined")
      }
      callback(stdout.trim())
    })
  } catch (ignore) {
    callback("undefined")
  }
}

const customPbxFileReferenceObj = (file) => {
  let fileObject = {
    isa: "PBXFileReference",
    path: '"' + file.path.replace(/\\/g, "/") + '"',
    sourceTree: file.sourceTree,
    lastKnownFileType: file.lastKnownFileType,
  }

  return fileObject
}

const pbxFileReferenceComment = (file) => {
  return file.basename || path.basename(file.path)
}

const getCordovaIosVersion = (callback) => {
  try {
    exec("cordova platform ls", (err, stdout, stderr) => {
      if (err) {
        callback("undefined")
      }

      const cordovaIosVersion = stdout.match(/ios\s+(\d+\.\d+\.\d+)/)

      if (cordovaIosVersion) {
        callback(cordovaIosVersion[1])
      }
      callback("undefined")
    })
  } catch (ignore) {
    callback("undefined")
  }
}

const getXcodeVersion = (callback) => {
  try {
    exec("xcodebuild -version", (err, stdout, stderr) => {
      if (err) {
        logger.error(`Erro ao obter a versão do Xcode: ${err}`)
        return
      }

      const xcodeVersion = stdout.match(/Xcode\s+(\d+\.\d+)/)
      if (xcodeVersion) {
        callback(xcodeVersion[1])
      }
      callback("undefined")
    })
  } catch (ignore) {
    callback("undefined")
  }
}

const findFileInDirectory = (dir, fileName) => {
  try {
    const files = fs.readdirSync(dir)

    for (const file of files) {
      const fullPath = path.join(dir, file)
      const stat = fs.lstatSync(fullPath)

      if (stat.isDirectory()) {
        const found = findFileInDirectory(fullPath, fileName)
        if (found) {
          return found
        }
      } else if (file.includes === fileName || file.includes === `"${fileName}"` || file.includes(fileName)) {
        return fullPath
      }
    }

    return null
  } catch (err) {
    console.log(`error: ${err}`)
    return null
  }
}

const findFileInPbxReference = (filename, project) => {
  const files = project.pbxFileReferenceSection()

  for (let key in files) {
    const file = files[key]
    if (file && file.path && file.path.includes(filename)) {
      return file.path
    }
  }

  console.error(`File ${filename} not found in project.`)
  return null
}

module.exports = {
  deepCopy,
  findFileRef,
  hasFile,
  findFileInDirectory,
  addAppExtensionsToBuildPhase,
  getConfigParser,
  nonComments,
  addAppExtensionsToBuildPhase,
  findFileInPbxReference,
  getNodeVersion,
  getCordovaVersion,
  getCordovaIosVersion,
  getXcodeVersion,
  customPbxFileReferenceObj,
  pbxFileReferenceComment,
  setRelativePath,
}
