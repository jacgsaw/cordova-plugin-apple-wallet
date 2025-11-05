#!/usr/bin/env node
/* jshint esversion: 6 */

const fs = require("fs");
const path = require("path");

function findUp(startDir, filename, maxLevels = 2) {
    let dir = startDir;
    for (let i = 0; i <= maxLevels; i++) {
        const candidate = path.join(dir, filename);
        if (fs.existsSync(candidate)) return candidate;
        const parent = path.dirname(dir);
        if (parent === dir) break;
        dir = parent;
    }
    return null;
}

module.exports = function (context) {
    const rootdir = context.opts.projectRoot;
    const pluginDir = path.join(rootdir, "plugins", "cordova-plugin-apple-wallet");

    let configPath = path.join(rootdir, "config-build.json");

    if (!fs.existsSync(configPath)) {
        const alt = findUp(pluginDir, "config-build.json", 2);
        if (alt) {
            configPath = alt;
            console.log(`[apple-wallet-jacgsaw] ✔ Usando config-build.json encontrado en: ${configPath}`);
        }
    } else {
        console.log(`[apple-wallet-jacgsaw] ✔ Usando config-build.json en: ${configPath}`);
    }

    let cfg = {};
    try {
        cfg = JSON.parse(fs.readFileSync(configPath, "utf8"));
        console.log("✔ Found config-file, raw contents:\n", cfg);
    } catch (e) {
        console.warn('[apple-wallet-jacgsaw] ⚠️ No se pudo leer config-build.json, usando "prod" por defecto');
        cfg.ios = {
            debug:   { "hst-plugins-environment": "prod" },
            release: { "hst-plugins-environment": "prod" },
        };
    }

    // const isRelease = context.cmdLine && context.cmdLine.indexOf("--release") !== -1;
    const buildType = "release";

    const iosCfg = cfg.ios || {};
    const section = iosCfg[buildType] || {};
    const hstEnv = section["hst-plugins-environment"] || "prod";

    console.log(
        `[apple-wallet-jacgsaw] ➜ iOS buildType="${buildType}", hst-plugins-environment="${hstEnv}"`
    );

    const srcDir = path.join(pluginDir, "src", "ios", "libs", "available", hstEnv);
    const destDir = path.join(pluginDir, "src", "ios", "libs", "selected");

    function copyRecursive(src, dest) {
        if (!fs.existsSync(src)) {
            throw new Error(`[apple-wallet-jacgsaw] La carpeta ${src} no existe`);
        }
        fs.mkdirSync(dest, { recursive: true });
        fs.readdirSync(src).forEach((child) => {
            const s = path.join(src, child);
            const d = path.join(dest, child);
            if (fs.lstatSync(s).isDirectory()) {
                copyRecursive(s, d);
            } else {
                fs.copyFileSync(s, d);
            }
        });
    }

    fs.rmSync(destDir, { recursive: true, force: true });
    copyRecursive(srcDir, destDir);

    console.log(`[apple-wallet-jacgsaw] ✔ Copiados los frameworks de "${hstEnv}"`);
};
