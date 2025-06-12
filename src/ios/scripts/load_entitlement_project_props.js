const fs = require("fs")
const path = require("path")
const utils = require("./pluginUtils")

module.exports = function (context) {
  try {
    const projectRoot = context.opts.projectRoot
    const plistLibPath = path.join(projectRoot, "plugins", "cordova-plugin-apple-wallet", "src", "ios", "libs", "js", "plist")
    const plist = require(plistLibPath)
    const iosPath = path.join(projectRoot, "platforms", "ios")
    const config = utils.getConfigParser(context, path.join(projectRoot, "config.xml"))
    const fileJsonPath = path.join(projectRoot, "Hp2Config", "EntitlementProject")
    const projectName = config.name()

    const plistFilePath = path.join(iosPath, projectName)

    const envs = [`release`, `debug`]

    envs.forEach((env) => setPlistFile(fileJsonPath, plistFilePath, env))

    function setPlistFile(jsonPath, plistPath, env) {
      const plistFile =
        env === "release"
          ? path.join(plistPath, `Entitlements-Release.plist`)
          : path.join(plistPath, `Entitlements-Debug.plist`)

      const json = path.join(jsonPath, `entitlement_project_issuer-${env}.json`)

      try {
        if (fs.existsSync(json)) {
          const jsonContent = fs.readFileSync(json, "utf8")
          const jsonObject = JSON.parse(jsonContent)

          let plistObject = {}

          if (fs.existsSync(plistFile)) {
            const existingPlistContent = fs.readFileSync(plistFile, "utf8")
            plistObject = plist.parse(existingPlistContent)
          }

          Object.keys(jsonObject).forEach((key) => {
            plistObject[key] = jsonObject[key]
          })

          const updatedPlistContent = plist.build(plistObject)
          fs.writeFileSync(plistFile, updatedPlistContent)

          // console.log(`JSON properties have been updated in .plist: ${plistFile}`)
        }
      } catch (err) {
        console.error("Error updating plist with JSON data:", err)
      }
    }
  } catch (err) {
    console.error("Erro When executing script:", err)
  }
}
