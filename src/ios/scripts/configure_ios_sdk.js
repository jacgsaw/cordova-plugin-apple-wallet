#!/usr/bin/env node
/* jshint esversion: 6 */

const fs = require("fs");
const path = require("path");

module.exports = function (context) {
    const rootdir = context.opts.projectRoot;
    const pluginDir = path.join(
        rootdir,
        "plugins",
        "cordova-plugin-apple-wallet",
    );
    const configFile = path.join(rootdir, "config-build.json");

    const buildType = "release";
    const DEFAULT_ENV = "prod";
    const ALLOWED_ENVS = ["homolog", "prod"];

    let cfg = {};

    try {
        cfg = JSON.parse(fs.readFileSync(configFile, "utf8"));
        console.log("✔ Found config-file, raw contents:\n", cfg);
    } catch (e) {
        console.warn(
            `[apple-wallet-jacgsaw] ⚠️ No se pudo leer config-build.json, usando "${DEFAULT_ENV}" por defecto`
        );
        cfg = {
            ios: {
                [buildType]: {
                    "hst-plugins-environment": DEFAULT_ENV,
                },
            },
        };
    }

    const iosCfg = cfg.ios || {};
    const section = iosCfg[buildType] || {};

    let hstEnv = section["hst-plugins-environment"];

    if (!hstEnv || !ALLOWED_ENVS.includes(hstEnv)) {
        console.warn(
            `[apple-wallet-jacgsaw] ⚠️ Ambiente inválido o ausente: "${hstEnv}". Usando "${DEFAULT_ENV}" por defecto`
        );
        hstEnv = DEFAULT_ENV;
    }

    console.log(
        `[apple-wallet-jacgsaw] ➜ iOS buildType="${buildType}", hst-plugins-environment="${hstEnv}"`
    );

    const srcDir = path.join(pluginDir, "src", "ios", "libs", "available", hstEnv);
    const destDir = path.join(pluginDir, "src", "ios", "libs", "selected");

    console.log(
        `[apple-wallet-jacgsaw] ➜ iOS srcDir="${srcDir}", hst-destDir="${destDir}"`
    );

    function copyRecursive(src, dest) {
        if (!fs.existsSync(src)) {
            throw new Error(`[apple-wallet-jacgsaw] La carpeta ${src} no existe`);
        }

        console.log(
            `[apple-wallet-jacgsaw] ➜ Se copian archivos de "${src}" a "${dest}"`
        );

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