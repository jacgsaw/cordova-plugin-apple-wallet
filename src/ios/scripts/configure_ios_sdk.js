#!/usr/bin/env node

const fs = require("fs")
const path = require("path")

module.exports = function (context) {
  const rootdir = context.opts.projectRoot

  const pluginDir = path.join(rootdir, "plugins", "@pkg", "cordova-plugin-apple-wallet")
  const appConfigFile = path.join(rootdir, "build.json")

  var appConfig = {}

  // Available environments
  var environmentMap = {
    homolog: "homolog",
    prod: "prod",
  }

  try {
    appConfig = JSON.parse(fs.readFileSync(appConfigFile, "utf8"))
  } catch (e) {
    appConfig["hst-plugins-environment"] = environmentMap.homolog
  }

  // Check if environment exists in build.json file
  if (appConfig && appConfig["hst-plugins-environment"] && environmentMap[appConfig["hst-plugins-environment"]]) {
    var environment = environmentMap[appConfig["hst-plugins-environment"]]
    console.log(
      `Using ${appConfig["hst-plugins-environment"] == "homolog" ? "HOMOLOG" : "PRODUCTION"} environment for iOS`
    )

    var availableDir = path.join(pluginDir, "src", "ios", "libs", "available", environment)
    var selectedDir = path.join(pluginDir, "src", "ios", "libs", "selected")

    if (!fs.existsSync(selectedDir)) {
        fs.mkdirSync(selectedDir, { recursive: true });
    }

    function copyRecursive(src, dest) {
      fs.mkdirSync(dest, { recursive: true })

      fs.readdirSync(src).forEach(function (childItemName) {
        const sourcePath = path.join(src, childItemName)
        const destinationPath = path.join(dest, childItemName)

        if (fs.lstatSync(sourcePath).isDirectory()) {
          copyRecursive(sourcePath, destinationPath)
        } else {
          fs.copyFileSync(sourcePath, destinationPath)
        }
      })
    }

    // todo-wesley check files -> is duplicating
    copyRecursive(availableDir, selectedDir)
  } else {
    console.log("Please check 'hst-plugins-environment' property value - use 'homolog' or 'prod'")
  }
}
