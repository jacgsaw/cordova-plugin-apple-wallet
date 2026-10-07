# cordova-plugin-apple-wallet

Plugin Cordova para iOS que integra Apple Wallet usando `HP2AppleSDK`, `HP2AuthorizationClient` y `AlamofireHST` como `xcframeworks` embebidos.

## Estado actual

- Plataforma soportada: `ios`
- Runtime JS expuesto: [www/HP2CordovaPlugin.js](/Users/JOACRUZ/Documents/Proyects/cordova-plugin-apple-wallet/www/HP2CordovaPlugin.js:1)
- Implementacion nativa principal: [src/ios/HP2CordovaPlugin.swift](/Users/JOACRUZ/Documents/Proyects/cordova-plugin-apple-wallet/src/ios/HP2CordovaPlugin.swift:1)
- Definicion del plugin y hooks: [plugin.xml](/Users/JOACRUZ/Documents/Proyects/cordova-plugin-apple-wallet/plugin.xml:1)
- Paquete npm: `@jacgsaw/cordova-plugin-apple-wallet` (id Cordova: `cordova-plugin-apple-wallet`)
- Version actual del paquete: `1.3.9`
- Login nativo DaviLogin integrado en `AuthenticationExtension`: ver [docs/INTEGRACION-DAVILOGIN.md](docs/INTEGRACION-DAVILOGIN.md)

## Que hace el plugin

El plugin:

- expone una API Cordova para inicializar el SDK, consultar disponibilidad y ejecutar aprovisionamiento;
- copia frameworks nativos segun ambiente (`homolog` o `prod`);
- crea y configura dos extensiones iOS en el proyecto host:
  - `AuthenticationExtension`: muestra el login DaviLogin cuando Apple Wallet pide autenticacion
  - `HP2ClientExtension`
- modifica archivos del proyecto Cordova host durante la instalacion.

## Requisitos

- Node `>=16.19.1`
- npm `>=6.13.7`
- Cordova `>=10.0.0`
- `cordova-ios >=6.1.1`
- Deployment target iOS `15.0` en la app host (las extensiones se configuran en `15.0`)
- macOS con Xcode para compilar iOS

## Estructura relevante

```text
.
├── package.json
├── plugin.xml
├── .npmrc
├── www/HP2CordovaPlugin.js
└── src/ios
    ├── HP2CordovaPlugin.swift
    ├── Extensions/
    │   ├── AuthenticationExtension/
    │   │   ├── ActionViewController.swift
    │   │   ├── CoreDataStack.swift
    │   │   └── DaviLogin/        # copia de cr-ios-superapp/DaviLogin/Sources/DaviLogin
    │   └── HP2ClientExtension/
    ├── libs/
    │   ├── available/homolog/
    │   ├── available/prod/
    │   └── js/plist/
    └── scripts/
```

## API JS expuesta

### `init(instCode, groupID, success, error)`

Inicializa el SDK con codigo de institucion y `groupID`.

### `updateDataBase(instCode, cardDataListJson, success, error)`

Carga tarjetas en la base local del SDK. Requiere que el plugin haya sido inicializado.

`cardDataListJson` debe ser un JSON serializado con elementos que incluyan:

```json
[
  {
    "cardHolderName": "Jane Doe",
    "cardId": "123",
    "cardImageBase64": "BASE64...",
    "lastFourDigits": "1234",
    "localizedDescription": "Tarjeta Visa",
    "paymentNetwork": "Visa",
    "cardType": "PAYMENT_CARD",
    "encCard": "optional"
  }
]
```

### `getVersion(instCode, success, error)`

Obtiene la version reportada por el SDK nativo.

Nota: la respuesta nativa usa la clave `versioName` tal como esta implementado hoy.

### `isAvailable(instCode, success, error)`

Indica si Wallet esta disponible.

### `isAvailableForCard(instCode, panId, success, error)`

Indica si una tarjeta puntual puede aprovisionarse.

### `getCards(instCode, success, error)`

Lista tarjetas conocidas por el SDK.

### `executeProvisioning(instCode, cardholderName, panSuffix, cardDescr, panId, pnp, pushRecId, success, error)`

Dispara el flujo de aprovisionamiento con `pushRecId`.

### `executeProvisioningOfEncryptedCard(instCode, cardholderName, panSuffix, cardDescr, panId, pnp, encCard, success, error)`

Dispara el flujo de aprovisionamiento con tarjeta encriptada.

### `saveDataToKeychain(data, dkey, success, error)`

Guarda informacion en Keychain.

## Ejemplo de uso Cordova

```js
document.addEventListener("deviceready", function () {
  HP2CordovaPlugin.init(
    "BANK01",
    "group.com.company.wallet",
    function (result) {
      console.log("init ok", result);
    },
    function (err) {
      console.error("init error", err);
    }
  );
});
```

Ejemplo de aprovisionamiento:

```js
HP2CordovaPlugin.executeProvisioning(
  "BANK01",
  "Jane Doe",
  "1234",
  "Visa Gold",
  "pan-ref-id",
  "visa",
  "push-record-id",
  function (result) {
    console.log("provisioning ok", result);
  },
  function (err) {
    console.error("provisioning error", err);
  }
);
```

## Instalacion en un proyecto host

Ejemplo desde un proyecto Cordova:

El paquete se publica en Nexus con scope `@jacgsaw`. En el `.npmrc` del proyecto host:

```ini
@jacgsaw:registry=http://13.140.189.86:8081/repository/apple-wallet/
```

Y en el `package.json` del proyecto Cordova:

```json
"@jacgsaw/cordova-plugin-apple-wallet": "1.3.9"
```

O por comando:

```bash
cordova plugin add @jacgsaw/cordova-plugin-apple-wallet@1.3.9 --save
```

Pasos completos para el proyecto hibrido (credenciales, pipeline, regeneracion de la plataforma y validacion en Xcode): [docs/INTEGRACION-DAVILOGIN.md](docs/INTEGRACION-DAVILOGIN.md#implementacion-en-el-proyecto-hibrido-cr-davivienda-app-mobile).

Nota importante:

- el `.npmrc` del plugin no configura al proyecto host para resolver el paquete;
- el proyecto host debe tener acceso al registry privado por su propia configuracion `npm`.

## Hooks y efectos sobre el proyecto host

Durante la instalacion o agregado de plataforma, los hooks del plugin modifican el proyecto iOS host:

- [src/ios/scripts/configure_ios_sdk.js](/Users/JOACRUZ/Documents/Proyects/cordova-plugin-apple-wallet/src/ios/scripts/configure_ios_sdk.js:1)
  - copia frameworks desde `src/ios/libs/available/<env>` hacia `src/ios/libs/selected`;
  - usa `config-build.json` del proyecto host;
  - hoy fija `buildType = "release"`.
- [src/ios/scripts/add-action-extension.js](/Users/JOACRUZ/Documents/Proyects/cordova-plugin-apple-wallet/src/ios/scripts/add-action-extension.js:1)
  - crea grupos y targets para extensiones;
  - copia archivos de extensiones al proyecto iOS, incluidas subcarpetas;
  - agrega `*.xcassets` y fuentes (`.ttf`/`.otf`) como recursos de la extension;
  - fija `IPHONEOS_DEPLOYMENT_TARGET = 15.0` en las extensiones y `SWIFT_VERSION = 5.0` en `AuthenticationExtension`.
- [src/ios/scripts/load_entitlement_project_props.js](/Users/JOACRUZ/Documents/Proyects/cordova-plugin-apple-wallet/src/ios/scripts/load_entitlement_project_props.js:1)
  - mezcla JSON de entitlements del host sobre los plist del proyecto iOS.
- [src/ios/scripts/add-last-plugin-configs.js](/Users/JOACRUZ/Documents/Proyects/cordova-plugin-apple-wallet/src/ios/scripts/add-last-plugin-configs.js:1)
  - inserta `NSFaceIDUsageDescription`;
  - inserta `institutionCode` y `groupID` en `HP2ClientExtension/Info.plist`;
  - puede modificar `MainViewController.m` para inyectar biometria;
  - puede ajustar `DEVELOPMENT_TEAM`.
- [src/ios/scripts/add-swift-support.js](/Users/JOACRUZ/Documents/Proyects/cordova-plugin-apple-wallet/src/ios/scripts/add-swift-support.js:1)
  - agrega soporte Swift y ajusta configuraciones del proyecto.

## Configuracion esperada en el proyecto host

El plugin espera un archivo `config-build.json` en la raiz del proyecto host. Ver ejemplo en [config-build.json.example](/Users/JOACRUZ/Documents/Proyects/cordova-plugin-apple-wallet/config-build.json.example:1).

Claves usadas actualmente:

- `ios.release.hst-plugins-environment`: `homolog` o `prod`
- `signing-dev-team.signing`: team ID de Apple
- `signing-dev-team.also-project`: si tambien firma el target principal
- `ns-face-id-usage-description`: texto para `NSFaceIDUsageDescription`
- `institution-code`: codigo de institucion
- `group-id`: app group para extensiones

Tambien espera estos JSON en el proyecto host si se quieren mezclar entitlements:

```text
Hp2Config/EntitlementProject/entitlement_project_issuer-release.json
Hp2Config/EntitlementProject/entitlement_project_issuer-debug.json
```

## Publicacion en Nexus

- Registry: `http://13.140.189.86:8081/repository/apple-wallet/` (hosted npm).
- Paquete: `@jacgsaw/cordova-plugin-apple-wallet`.
- Validar autenticacion: `npm whoami --registry http://13.140.189.86:8081/repository/apple-wallet/`
- Login: `npm login --auth-type=legacy --registry http://13.140.189.86:8081/repository/apple-wallet/`
- Publicar: `npm publish --dry-run` y luego `npm run publish:nexus`.

Usuarios y roles en Nexus, cambio de usuario, configuracion del pipeline y errores comunes: [docs/NEXUS-AUTENTICACION.md](docs/NEXUS-AUTENTICACION.md).

## Riesgos y particularidades actuales

- El plugin modifica codigo del proyecto host; no es un plugin de solo enlace.
- `configure_ios_sdk.js` usa siempre `release`, no detecta `debug`.
- `updateDataBase` recibe `instCode` desde JS pero usa el estado inicializado en memoria; el parametro no controla la instancia.
- `saveDataToKeychain` existe en JS y Swift, pero no esta declarado en el header Objective-C.
- Hay dependencias logicas del proyecto host que no estan documentadas en el codigo fuente original, especialmente `config-build.json` y `Hp2Config/EntitlementProject`.
- `DaviLogin` es una copia del codigo de `cr-ios-superapp`; los cambios alla deben sincronizarse a mano (ver [docs/INTEGRACION-DAVILOGIN.md](docs/INTEGRACION-DAVILOGIN.md#actualizar-davilogin-en-el-plugin)).
- El proyecto host compila con Swift 4 (`SwiftVersion` en `plugin.xml`); solo `AuthenticationExtension` usa Swift 5.

## Desarrollo local

Si se modifica el codigo del plugin:

1. Probar instalacion en un proyecto Cordova iOS real.
2. Verificar que los hooks creen y actualicen:
   - targets de extensiones
   - `Info.plist`
   - entitlements
   - `MainViewController.m`
3. Verificar que `src/ios/libs/selected` corresponda al ambiente esperado.

## Documentacion para agentes

El archivo [AGENTS.md](/Users/JOACRUZ/Documents/Proyects/cordova-plugin-apple-wallet/AGENTS.md:1) describe:

- contexto operativo del proyecto;
- invariantes que un agente no debe romper;
- flujo recomendado de analisis, cambios y validacion;
- checklist para administradores de agentes.
