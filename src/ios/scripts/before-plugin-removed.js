#!/usr/bin/env node

const fs = require("fs")
const path = require("path")
const xcode = require("xcode")
const utils = require("./pluginUtils")
const f = require("util").format
const Logger = require(`./logger.js`)

module.exports = function (context) {
  const projectRoot = context.opts.projectRoot
  const hp2ConfigsDir = path.join(projectRoot, "Hp2Config")
  const logDir = path.join(hp2ConfigsDir, "logs")
  const logger = new Logger({ path: logDir, lauchLogs: false })

  try {
    const iosPath = path.join(projectRoot, "platforms", "ios")

    const plistLibPath = path.join(projectRoot, "plugins", "cordova-plugin-apple-wallet", "src", "ios", "libs", "js", "plist")
    const plist = require(plistLibPath)
    const config = utils.getConfigParser(context, path.join(projectRoot, "config.xml"))
    const projectName = config.name()

    logger.addLogDaySection(`Running script for hook on before plugin install`)

    // ======================================================
    // Remove properties from .pbxproj
    // ======================================================

    // const projectFilePath = path.join(iosPath, `${projectName}.xcodeproj`, "project.pbxproj")

    // ======================================================
    // Save the entitlements
    // ======================================================

    const entitlementsExtensonsPath = path.join(projectRoot, "Hp2Config", "entitlements")

    if (!fs.existsSync(entitlementsExtensonsPath)) {
      fs.mkdirSync(entitlementsExtensonsPath, { recursive: true })
    }

    const entitlements = [`AuthenticationExtension.entitlements`, `HP2ClientExtension.entitlements`]

    entitlements.forEach((entitlement) => {
      const srcItem = utils.findFileInDirectory(iosPath, entitlement)
      if (srcItem && fs.existsSync(entitlementsExtensonsPath)) {
        fs.copyFileSync(srcItem, path.join(entitlementsExtensonsPath, entitlement))
      }
    })

    // ======================================================
    // Save in JSON the project plist
    // ======================================================

    const plistFilePath = path.join(iosPath, projectName)
    const entitlementPath = path.join(projectRoot, "Hp2Config", "EntitlementProject")

    if (!fs.existsSync(entitlementPath)) {
      fs.mkdirSync(entitlementPath, { recursive: true })
    }

    const envs = [`release`, `debug`]

    envs.forEach((env) => setJsonFile(entitlementPath, plistFilePath, env))

    function setJsonFile(jsonPath, plistPath, env) {
      const plistFile =
        env === "release"
          ? path.join(plistPath, `Entitlements-Release.plist`)
          : path.join(plistPath, `Entitlements-Debug.plist`)

      const jsonFilePath = path.join(jsonPath, `entitlement_project_issuer-${env}.json`)

      logger.append(`jsonFilePath: ${jsonFilePath}`)
      logger.append(`plistFilePath: ${plistFilePath}`)
      logger.append(`plist: ${plistFile}`)

      try {
        if (fs.existsSync(plistFilePath)) {
          const plistContent = fs.readFileSync(plistFile, "utf8")
          const plistObject = plist.parse(plistContent)

          const filteredObject = {
            "com.apple.developer.pass-type-identifiers": plistObject["com.apple.developer.pass-type-identifiers"],
            "com.apple.developer.payment-pass-provisioning":
              plistObject["com.apple.developer.payment-pass-provisioning"],
            "com.apple.security.application-groups": plistObject["com.apple.security.application-groups"],
          }

          Object.keys(filteredObject).forEach((key) => {
            if (filteredObject[key] === undefined) {
              delete filteredObject[key]
            }
          })

          fs.writeFileSync(jsonFilePath, JSON.stringify(filteredObject, null, 2))

          logger.append(`Relevant .plist properties were saved in the JSON file: ${jsonFilePath}`)
        }
      } catch (err) {
        console.error("Error converting plist to JSON:", err)
      }
      logger.append(`end script`)
    }

    logger.append(`Successful saving cordova-plugin-apple-wallet configs.`, { isImportant: true })
    logger.saveLogs()
  } catch (err) {
    // this avoid some error on remove platform or plugin
    logger.append(`error: ${err}`)
  }
}
