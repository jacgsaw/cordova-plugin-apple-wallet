const fs = require("fs")
const path = require("path")

class Logger {
  constructor(customOptions = {}) {
    this.logEntries = []
    this.options = { ...this.options, ...customOptions }
    this.fileName = "cordova-plugin-apple-wallet-config-extension-logs.txt"
    this.fileLogName = path.join(this.options.path, this.fileName)
  }

  saveLogs() {
    this.removeOldLogs()
    if (this.options && !this.options.path) {
      console.log(`wasn't possible save logs`)
      return
    }

    const logContent = this.logEntries.join("\n") + "\n"

    if (!fs.existsSync(this.options.path)) {
      fs.mkdir(this.options.path, { recursive: true }, (err) => {
        if (err) {
          console.error("Error to create log dir:", err)
          return
        }

        fs.writeFile(this.fileLogName, logContent, (err) => {
          if (err) {
            console.error("Error on save log:", err)
          }
        })
      })
      return
    }

    if (fs.existsSync(this.fileLogName)) {
      fs.appendFileSync(this.fileLogName, logContent, "utf8")
      this.logEntries = []
    }
  }

  append(message, opt = {}) {
    const timestamp = new Date().toUTCString()
    const entry = `${timestamp} - ${message}`

    const shouldShowLogs = this.options.lauchLogs ? this.options.lauchLogs : false
    const isMandatory = opt && opt.isImportant ? opt.isImportant : false

    if (isMandatory || shouldShowLogs) {
      console.log(entry)
    }
    this.logEntries.push(entry)
  }

  addLogInfoSection(section, opt) {
    const separator = `--------------------------------------------------------------------------------------------------`
    const entry = `\n\t${section}\n${separator}\n`

    const shouldShowLogs = this.options.lauch ? this.options.lauch : false
    const isMandatory = opt && opt.isImportant ? opt.isImportant : false

    if (isMandatory || shouldShowLogs) {
      console.log(entry)
    }
    this.logEntries.push(entry)
  }

  addLogDaySection(section, opt) {
    const tagToRemove = `TAG_REMOVE_[${new Date().getTime()}]`
    const separator = `=================================================`
    const entry = `\n\n${separator}\n\t${section}\t${tagToRemove}\n${separator}`
    const shouldShowLogs = this.options.lauch ? this.options.lauch : false
    const isMandatory = opt && opt.isImportant ? opt.isImportant : false

    if (isMandatory || shouldShowLogs) {
      console.log(entry)
    }
    this.logEntries.push(entry)
  }

  removeOldLogs() {
    if (this.options && this.options.path && fs.existsSync(this.fileLogName)) {
      const logContent = fs.readFileSync(this.fileLogName, "utf8")
      const oneDayInMillis = 24 * 60 * 60 * 1000
      const now = Date.now()
      const separator = `=================================================`
      const regex = new RegExp(`(${separator}\\n.*?TAG_REMOVE_\\[(\\d+)\\][\\s\\S]*?${separator}\\n)`, "g")

      return logContent.replace(regex, (match, fullLog, timestamp) => {
        const logTime = parseInt(timestamp, 10)
        if (now - logTime > oneDayInMillis) {
          if (fs.existsSync(this.fileLogName)) {
            fs.writeFileSync(this.fileLogName, "", "utf8")
          }
        }
      })
    }
  }
}

module.exports = Logger
