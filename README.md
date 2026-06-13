# cordova-plugin-apple-wallet

Plugin Cordova para iOS que integra Apple Wallet usando `HP2AppleSDK`, `HP2AuthorizationClient` y `AlamofireHST` como `xcframeworks` embebidos.

## Estado actual

- Plataforma soportada: `ios`
- Runtime JS expuesto: [www/HP2CordovaPlugin.js](/Users/JOACRUZ/Documents/Proyects/cordova-plugin-apple-wallet/www/HP2CordovaPlugin.js:1)
- Implementacion nativa principal: [src/ios/HP2CordovaPlugin.swift](/Users/JOACRUZ/Documents/Proyects/cordova-plugin-apple-wallet/src/ios/HP2CordovaPlugin.swift:1)
- Definicion del plugin y hooks: [plugin.xml](/Users/JOACRUZ/Documents/Proyects/cordova-plugin-apple-wallet/plugin.xml:1)
- Version actual del paquete: `1.3.7`

## Que hace el plugin

El plugin:

- expone una API Cordova para inicializar el SDK, consultar disponibilidad y ejecutar aprovisionamiento;
- copia frameworks nativos segun ambiente (`homolog` o `prod`);
- crea y configura dos extensiones iOS en el proyecto host:
  - `AuthenticationExtension`
  - `HP2ClientExtension`
- modifica archivos del proyecto Cordova host durante la instalacion.

## Requisitos

- Node `>=16.19.1`
- npm `>=6.13.7`
- Cordova `>=10.0.0`
- `cordova-ios >=6.1.1`
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

```bash
cordova plugin add cordova-plugin-apple-wallet
```

Si el paquete se consume desde Nexus privado:

```bash
cordova plugin add cordova-plugin-apple-wallet --save
```

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
  - copia archivos de extensiones al proyecto iOS.
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

El proyecto hoy tiene dos configuraciones distintas:

- `.npmrc` apunta a `http://51.222.90.96:8081/repository/coe-plugin-apple-wallet/`
- `publishConfig.registry` en `package.json` apunta a `http://51.222.90.96:8081/repository/apple-wallet/`

Este esquema es valido si se quiere instalar dependencias desde el `group` `coe-plugin-apple-wallet` y publicar el plugin al repositorio `hosted` `apple-wallet`. Para `npm publish`, npm usa `publishConfig.registry`.

### Flujo recomendado de publicacion

1. Actualizar version en `package.json`.
2. Mantener el `group` como `registry` general para instalar y el `hosted` como destino de publicacion.
3. Autenticarse por comando contra el registry de publicacion:

```bash
npm adduser --registry http://51.222.90.96:8081/repository/apple-wallet/
```

4. Si Nexus tambien exige autenticacion para consumir el `group`, autenticarse ademas contra ese endpoint:

```bash
npm adduser --registry http://51.222.90.96:8081/repository/coe/
```

5. Ejecutar:

```bash
npm publish --registry http://51.222.90.96:8081/repository/apple-wallet/
```

### Configuracion recomendada de `.npmrc`

El `.npmrc` versionado en el repo deberia contener solo configuracion no sensible:

```ini
registry=http://51.222.90.96:8081/repository/coe/
always-auth=true
```

Las credenciales deben quedar en `~/.npmrc` del usuario que publica o instala, preferiblemente generadas por `npm adduser`.

### Secuencia recomendada de validacion

1. Validar el `registry` por defecto:
```bash
npm config get registry
```
Resultado esperado:
```bash
http://51.222.90.96:8081/repository/coe/
```

2. Validar el destino de publicacion del paquete:
```bash
npm pkg get publishConfig.registry
```
Resultado esperado:
```bash
"http://51.222.90.96:8081/repository/apple-wallet/"
```

3. Revisar configuracion efectiva y credenciales del usuario:
```bash
npm config list
cat ~/.npmrc
```
Verificar que no exista otro `.npmrc` sobreescribiendo el `registry`, y que `~/.npmrc` tenga credenciales para `apple-wallet` y, si aplica, para `coe-plugin-apple-wallet`.

4. Validar autenticacion contra el `group`:
```bash
npm whoami --registry http://51.222.90.96:8081/repository/coe-plugin-apple-wallet/
```
Si falla con `ENEEDAUTH`, aun no hay login valido para ese endpoint.

5. Validar autenticacion contra el repo de publicacion:
```bash
npm whoami --registry http://51.222.90.96:8081/repository/apple-wallet/
```
Si falla con `ENEEDAUTH`, `npm publish` tambien fallara.

6. Verificar la publicacion sin subir el paquete:
```bash
npm publish --dry-run
```
Esto no publica realmente. Si aparece un error de autenticacion contra `apple-wallet`, todavia falta login en ese registry.

### Como dejar la configuracion por defecto

Para dejar el `group` como registry general del usuario actual:

```bash
npm config set registry http://51.222.90.96:8081/repository/coe-plugin-apple-wallet/
```

Para dejar autenticacion siempre activa hacia ese registry:

```bash
npm config set always-auth true
```

Para publicar explicitamente al repo `hosted`:

```bash
npm publish --registry http://51.222.90.96:8081/repository/apple-wallet/
```

Para cambiar ese destino de forma persistente, actualizar `publishConfig.registry` en `package.json`:

```json
"publishConfig": {
  "registry": "http://51.222.90.96:8081/repository/apple-wallet/"
}
```

### Recomendacion de seguridad

No versionar credenciales reales en `.npmrc`. Usar credenciales del entorno o del usuario que publica.

## Riesgos y particularidades actuales

- El plugin modifica codigo del proyecto host; no es un plugin de solo enlace.
- `configure_ios_sdk.js` usa siempre `release`, no detecta `debug`.
- `updateDataBase` recibe `instCode` desde JS pero usa el estado inicializado en memoria; el parametro no controla la instancia.
- `saveDataToKeychain` existe en JS y Swift, pero no esta declarado en el header Objective-C.
- Hay dependencias logicas del proyecto host que no estan documentadas en el codigo fuente original, especialmente `config-build.json` y `Hp2Config/EntitlementProject`.

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
