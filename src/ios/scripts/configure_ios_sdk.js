#!/usr/bin/env node
/* jshint esversion: 6 */

const fs = require("fs");
const path = require("path");

module.exports = function (context) {
    const rootdir = context.opts.projectRoot;
    const pluginDir = path.join(
        rootdir,
        "plugins",
        "@pkg",
        "cordova-plugin-apple-wallet",
    );
    const configFile = path.join(rootdir, "config-build.json");

    let cfg = {};
    try {
        cfg = JSON.parse(fs.readFileSync(configFile, "utf8"));
        console.log("✔ Found config-file, raw contents:\n", cfg);
    } catch (e) {
        console.warn(
            '[apple-wallet-jacgsaw] ⚠️ No se pudo leer config-build.json, usando "homolog" por defecto',
        );
        cfg.ios = { debug: { "hst-plugins-environment": "homolog" } };
    }

    const isRelease = context.cmdLine && context.cmdLine.indexOf("--release") !== -1;
    const buildType = isRelease ? "release" : "debug";

    const iosCfg = cfg.ios || {};
    const section = iosCfg[buildType] || {};
    const hstEnv = section["hst-plugins-environment"] || "homolog";

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
