# Integracion de DaviLogin en AuthenticationExtension

Desde la version `1.3.9` el plugin incluye el login nativo **DaviLogin** (proyecto `cr-ios-superapp`) dentro de la extension `AuthenticationExtension`. Esta extension es la que Apple Wallet abre (`com.apple.PassKit.issuer-provisioning.authorization`) para autenticar al usuario antes de aprovisionar una tarjeta desde la app Wallet.

## Resumen del flujo

```text
Apple Wallet
  └─ AuthenticationExtension (ActionViewController)
       └─ LoginActivity (DaviLogin, SwiftUI)
            ├─ ConfigurationService / NetworkModule  -> servicios de autenticacion
            └─ CoreDataStack.saveDataToKeychainPlugin -> Keychain compartido (app group)
                    sessionId, token, idNumber, idType
  └─ completionHandler(.authorized)

HP2ClientExtension (ActionDelegateHandler)
  └─ CoreDataStack.readFromKeychain(...)  -> usa el token guardado por el login
```

Ambas extensiones comparten datos por Keychain usando el access group `group.com.davivienda.wallet.InAppProvisioningExtension`.

## Que se cambio en el plugin (v1.3.9)

### Codigo de la extension

| Archivo | Cambio |
|---|---|
| `src/ios/Extensions/AuthenticationExtension/DaviLogin/` | Copia de `cr-ios-superapp/DaviLogin/Sources/DaviLogin` (sin storyboard ni `.DS_Store`). |
| `DaviLogin/Resources/Fonts/` | Solo las fuentes usadas por el codigo: `Roboto-Bold`, `Roboto-Medium`, `Roboto-Regular`. |
| `AuthenticationExtension/CoreDataStack.swift` | Copia del `CoreDataStack` de `cordova-plugin-davitools`. Ese plugin solo lo agrega al target de la app, y la extension lo necesita para el Keychain. |
| `AuthenticationExtension/ActionViewController.swift` | Muestra `LoginActivity` inyectando `PagesViewModel` como `environmentObject` (requerido por `LoginActivity`). Usa APIs de Swift 5 (`addChild`, `UIActivityIndicatorView(style:)`). |
| `AuthenticationExtension/Info.plist` | Agrega `UIAppFonts` con las tres fuentes Roboto. |

### Hook `src/ios/scripts/add-action-extension.js`

- **Copia recursiva corregida.** Antes no soportaba subcarpetas: reasignaba `dest` con el retorno (`undefined`) de la llamada recursiva y calculaba rutas con un `..` extra por nivel. Ahora todos los archivos se referencian desde el grupo de la extension con una ruta relativa a `platforms/ios`, sin importar la profundidad.
- **Recursos.** Las carpetas `*.xcassets` se agregan como un solo recurso (`folder.assetcatalog`) y los `.ttf`/`.otf` se agregan al build phase *Resources* de la extension, no a *Sources*.
- **Ignora `.DS_Store`.**
- **Build settings de las extensiones:**
  - `IPHONEOS_DEPLOYMENT_TARGET = 15.0` en ambas extensiones (antes `14.0`). DaviLogin usa APIs de SwiftUI de iOS 15, igual que la app host.
  - `SWIFT_VERSION = 5.0` solo en `AuthenticationExtension`. El proyecto host compila con Swift 4 por la preferencia `SwiftVersion` del `plugin.xml`, y DaviLogin necesita Swift 5.
- Es idempotente: si se ejecuta dos veces no duplica referencias en el `.pbxproj`.

### Cambios hechos en `cr-ios-superapp` para que el codigo compile en la extension

- `Core/System/ConfigurationService.swift`: `try? container.decodeIfPresent(...)` se cambio por `try? container.decode(...)`. En Swift 4 `try?` no aplana opcionales (`Bool??`), y eso producia los errores *"Value of optional type 'Bool?' must be unwrapped"* y *"Type of expression is ambiguous"*.
- `Resources/Colors/Colors.swift`: `Gradients` usa `Color("gradient01Color1")` en lugar de `Color.gradient01Color1`. Esos simbolos los genera Xcode solo cuando `ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS` esta activo, y no lo esta en el target que crea Cordova.

## Implementacion en el proyecto hibrido (`cr-davivienda-app-mobile`)

### 1. Acceso a Nexus

El paquete se publica como `@jacgsaw/cordova-plugin-apple-wallet` en el repositorio hosted `apple-wallet`. Agregar al `.npmrc` de la **raiz** del monorepo (npm workspaces) solo el mapeo del scope, sin cambiar el registry general:

```ini
@jacgsaw:registry=http://13.140.189.86:8081/repository/apple-wallet/
```

Las credenciales van en el `~/.npmrc` del usuario, nunca en el repo:

```bash
npm login --auth-type=legacy --registry http://13.140.189.86:8081/repository/apple-wallet/
npm whoami --registry http://13.140.189.86:8081/repository/apple-wallet/
```

Creacion de usuarios, roles, cambio de usuario y problemas de autenticacion: ver [NEXUS-AUTENTICACION.md](NEXUS-AUTENTICACION.md).

En Azure Pipelines (`azure-pipelines-ios.yml`) agregar, antes de `npm install`, un paso que escriba el token desde una variable secreta (por ejemplo `NEXUS_NPM_TOKEN` en el variable group `IOS_CR`):

```yaml
- bash: |
    echo "//13.140.189.86:8081/repository/apple-wallet/:_authToken=$(NEXUS_NPM_TOKEN)" >> ~/.npmrc
  displayName: 'Nexus: credenciales apple-wallet'
```

### 2. Dependencia

En `@app/mobile/ios/package.json`:

```json
"dependencies": {
    "@jacgsaw/cordova-plugin-apple-wallet": "1.3.9"
},
"cordova": {
    "plugins": {
        "@jacgsaw/cordova-plugin-apple-wallet": {},
        "cordova-plugin-apple-wallet": {}
    }
}
```

Por que las dos claves en `cordova.plugins`:

- Al restaurar plugins (`cordova platform add` / `prepare`), Cordova 12 busca la version en `dependencies` usando la clave de `cordova.plugins`. Si solo estuviera `cordova-plugin-apple-wallet` (el id del `plugin.xml`), no encontraria `@jacgsaw/...` y lo buscaria sin scope en npmjs.
- Con la clave `@jacgsaw/...`, Cordova usa el paquete ya instalado por `npm install` (que si respeta el `.npmrc`).
- Cordova agrega por su cuenta la clave `cordova-plugin-apple-wallet` despues de instalar; dejarla evita que modifique el `package.json` en cada build. Con ambas claves el plugin se instala una sola vez.

No usar un alias npm (`"cordova-plugin-apple-wallet": "npm:@jacgsaw/..."`): `cordova-fetch` resuelve el alias sin leer el `.npmrc` y falla con `404 ... registry.npmjs.org/@jacgsaw%2fcordova-plugin-apple-wallet`.

El `id` de Cordova sigue siendo `cordova-plugin-apple-wallet`, por lo que hooks y referencias JS (`HP2CordovaPlugin`) no cambian.

Despues de editar, regenerar el lock desde la raiz del monorepo:

```bash
npm install --legacy-peer-deps
```

### 3. Configuracion del host

Sin cambios respecto a versiones anteriores:

- `config-build.json` en la raiz del proyecto Cordova (ver `config-build.json.example`).
- `Hp2Config/entitlements/AuthenticationExtension.entitlements` y `HP2ClientExtension.entitlements`, con el app group y el keychain access group `group.com.davivienda.wallet.InAppProvisioningExtension`.

### 4. Regenerar la plataforma iOS

Los hooks que crean las extensiones corren en `after_plugin_add` y `after_platform_add`, asi que la plataforma se debe regenerar:

```bash
cd @app/mobile/ios
npm install
npm run ios:add        # elimina y vuelve a agregar platforms/ios
npm run ios:prepare
```

### 5. Validar en Xcode

Abrir `platforms/ios/Davivienda Costa Rica.xcworkspace` y revisar:

- [ ] El target `AuthenticationExtension` existe y tiene `Swift Language Version = Swift 5` e `iOS Deployment Target = 15.0`.
- [ ] Grupo `Extensions/AuthenticationExtension/DaviLogin/...` con todas las fuentes Swift en *Compile Sources* del target.
- [ ] `Colors.xcassets` y las tres `Roboto-*.ttf` en *Copy Bundle Resources* de `AuthenticationExtension`.
- [ ] `CODE_SIGN_ENTITLEMENTS` de la extension apunta a `ExtensionEntitlements/AuthenticationExtension.entitlements`.
- [ ] Compila para *Any iOS Device (arm64)*.
- [ ] En un dispositivo: Wallet > agregar tarjeta > Davivienda abre el login, autentica y continua el aprovisionamiento.

## Actualizar DaviLogin en el plugin

El codigo de DaviLogin es una **copia**; los cambios en `cr-ios-superapp` no llegan solos al plugin. Para sincronizar:

```bash
SRC=/ruta/a/cr-ios-superapp/DaviLogin/Sources/DaviLogin
DST=src/ios/Extensions/AuthenticationExtension/DaviLogin

rsync -a --delete \
  --exclude ".DS_Store" --exclude "*.storyboard" --exclude "Resources/Fonts/" \
  "$SRC/" "$DST/"

mkdir -p "$DST/Resources/Fonts"
for f in Bold Medium Regular; do
  cp "$SRC/Resources/Fonts/Roboto/Roboto-$f.ttf" "$DST/Resources/Fonts/"
done
```

Si DaviLogin empieza a usar otra fuente, copiarla tambien y agregarla a `UIAppFonts` en `AuthenticationExtension/Info.plist`.

Verificacion rapida de compilacion de la extension sin generar el proyecto Cordova:

```bash
find src/ios/Extensions/AuthenticationExtension -name "*.swift" > /tmp/auth.txt
xcrun -sdk iphoneos swiftc -typecheck -target arm64-apple-ios15.0 -swift-version 5 \
  -module-name AuthenticationExtension @/tmp/auth.txt
```

Reglas para el codigo que se copia a la extension:

- Debe compilar en Swift 5 y con deployment target iOS 15.
- No usar simbolos de color/imagen generados por Xcode (`Color.miColor`); usar `Color("miColor")`.
- No usar APIs no disponibles en extensiones (`UIApplication.shared`, etc.).
- No definir `@main`.

## Publicar una nueva version

1. Actualizar la version en `package.json` y en `plugin.xml` (`version="x.y.z"`).
2. Commit en `main` y tag con el numero de version:
   ```bash
   git tag x.y.z
   git push origin main
   git push origin x.y.z
   ```
3. Publicar en Nexus:
   ```bash
   npm publish --dry-run
   npm run publish:nexus
   ```
4. Actualizar la version en `@app/mobile/ios/package.json` del hibrido y regenerar la plataforma (paso 4).

## Problemas conocidos

| Sintoma | Causa | Solucion |
|---|---|---|
| `Value of optional type 'Bool?' must be unwrapped` / `Type of expression is ambiguous` en `ConfigurationService` | La extension se compila con Swift 4 | Verificar `SWIFT_VERSION = 5.0` en el target y usar la version >= 1.3.9 del plugin. |
| `Type 'Color' has no member 'gradient01Color1'` | Simbolos de assets generados por Xcode | Usar `Color("...")`. |
| `cannot find 'CoreDataStack' in scope` | Falta `CoreDataStack.swift` en el target de la extension | Esta incluido en la extension desde 1.3.9. |
| `'background(_:ignoresSafeAreaEdges:)' is only available in iOS 15.0` | Deployment target 14.0 | El hook fija 15.0 desde 1.3.9; regenerar la plataforma. |
| Warning `no rule to process file ... .ttf` | Fuentes agregadas a *Sources* | El hook las agrega a *Resources* desde 1.3.9; regenerar la plataforma. |
| Crash al abrir el login: `No ObservableObject of type PagesViewModel found` | Falta el `environmentObject` | `ActionViewController` lo inyecta desde 1.3.9. |
| Cambios del hook no se reflejan | Los hooks solo corren al agregar plugin/plataforma | `npm run ios:add`. |
