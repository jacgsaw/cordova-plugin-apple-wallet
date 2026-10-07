# Autenticacion en Nexus

El plugin se publica como `@jacgsaw/cordova-plugin-apple-wallet` en el repositorio npm hosted `apple-wallet`:

```text
http://13.140.189.86:8081/repository/apple-wallet/
```

Para instalarlo o publicarlo, npm necesita un token de Nexus. El token se guarda en el `~/.npmrc` de cada usuario y **nunca** en un `.npmrc` versionado.

## Validar si estoy autenticado

```bash
npm whoami --registry http://13.140.189.86:8081/repository/apple-wallet/
```

| Resultado | Significado |
|---|---|
| Un nombre de usuario (por ejemplo `admin`) | Hay un token valido para ese registry. |
| `ENEEDAUTH` o `E401` | No hay credenciales o el token ya no es valido. Hacer login. |

El aviso `npm warn Unknown project config "always-auth"` es solo una advertencia de npm 11 y no afecta el resultado.

Para ver que token esta usando npm (sin mostrar el valor completo):

```bash
grep "13.140.189.86" ~/.npmrc | sed -E 's/(_authToken=).{6}.*/\1******/'
```

Validacion completa desde el proyecto hibrido (comprueba `.npmrc` del proyecto + credenciales):

```bash
cd cr-davivienda-app-mobile
npm view @jacgsaw/cordova-plugin-apple-wallet versions
```

Debe listar las versiones publicadas (por ejemplo `1.3.9`).

## Autenticar un usuario

### 1. Crear el usuario en Nexus (administrador)

En Nexus, *Settings → Security*:

1. **Realms**: verificar que **npm Bearer Token Realm** este activo. Sin el, `npm login` falla aunque usuario y clave sean correctos.
2. **Roles**: crear un rol segun el uso:

   | Uso | Privilegios |
   |---|---|
   | Solo instalar (desarrolladores, pipeline) | `nx-repository-view-npm-apple-wallet-read`, `nx-repository-view-npm-apple-wallet-browse` |
   | Publicar versiones | Los anteriores + `nx-repository-view-npm-apple-wallet-add`, `nx-repository-view-npm-apple-wallet-edit` |

3. **Users**: crear el usuario y asignarle el rol.

### 2. Hacer login desde la maquina del usuario

npm 9+ intenta por defecto un login web que Nexus no soporta; usar `--auth-type=legacy`:

```bash
npm login --auth-type=legacy --registry http://13.140.189.86:8081/repository/apple-wallet/
```

Pide usuario y contrasena de Nexus y agrega a `~/.npmrc`:

```ini
//13.140.189.86:8081/repository/apple-wallet/:_authToken=NpmToken.xxxxxxxx
```

Cada persona se autentica en su propia maquina con su propio usuario.

### 3. Validar

```bash
npm whoami --registry http://13.140.189.86:8081/repository/apple-wallet/
npm view @jacgsaw/cordova-plugin-apple-wallet versions --registry http://13.140.189.86:8081/repository/apple-wallet/
```

### Cambiar de usuario en la misma maquina

Un nuevo `npm login` contra el mismo registry **reemplaza** el token anterior. Para cerrar la sesion actual:

```bash
npm logout --registry http://13.140.189.86:8081/repository/apple-wallet/
```

Si se necesita alternar entre un usuario de lectura y uno de publicacion sin perder ninguno, guardar el de publicacion en un archivo aparte:

```bash
npm login --auth-type=legacy \
  --registry http://13.140.189.86:8081/repository/apple-wallet/ \
  --userconfig ~/.npmrc-nexus-publish

npm publish --userconfig ~/.npmrc-nexus-publish
```

## Pipeline (Azure DevOps)

1. Hacer login una vez con el usuario **de solo lectura** y copiar el valor de `_authToken` desde `~/.npmrc`.
2. Guardarlo como variable secreta, por ejemplo `NEXUS_NPM_TOKEN` en el variable group `IOS_CR`.
3. En `azure-pipelines-ios.yml`, antes de `npm install`:

```yaml
- bash: |
    echo "//13.140.189.86:8081/repository/apple-wallet/:_authToken=$(NEXUS_NPM_TOKEN)" >> ~/.npmrc
  displayName: 'Nexus: credenciales apple-wallet'
```

## Publicar

Requiere un usuario con privilegios de publicacion (`add`/`edit`):

```bash
npm whoami --registry http://13.140.189.86:8081/repository/apple-wallet/
npm publish --dry-run
npm run publish:nexus
```

`publish:nexus` y `publishConfig.registry` en `package.json` apuntan al mismo repositorio hosted. Nexus no permite republicar una version existente: subir `version` en `package.json` y `plugin.xml` antes de publicar.

## Buenas practicas

- No usar `admin` para el trabajo diario ni en el pipeline: usar un usuario de solo lectura para instalar y uno de publicacion solo para `publish:nexus`.
- No versionar tokens. El `.npmrc` del repo solo contiene configuracion (registry/scope).
- El registry usa `http://`: el token viaja sin cifrar. Se recomienda exponer Nexus detras de HTTPS y actualizar las URLs.
- Si un token se expone, revocarlo en Nexus (*Settings → Security → Users*, o regenerando el realm) y volver a hacer login.

## Problemas comunes

| Sintoma | Causa | Solucion |
|---|---|---|
| `npm login` abre/pide URL web o falla con `E404` en `/-/v1/login` | npm 9+ usa login web por defecto | Agregar `--auth-type=legacy`. |
| `E401 Unable to authenticate` en login | Usuario/clave incorrectos o realm npm desactivado | Revisar credenciales y activar **npm Bearer Token Realm**. |
| `ENEEDAUTH` en `npm whoami` | No hay token para ese registry exacto | El registry debe coincidir incluido `/repository/apple-wallet/` con la barra final. |
| `E403` al publicar | El usuario no tiene privilegios `add`/`edit` | Asignar el rol de publicacion. |
| `E400`/`EPUBLISHCONFLICT` al publicar | La version ya existe | Subir la version. |
| `404 ... registry.npmjs.org/@jacgsaw%2f...` | Falta el mapeo del scope en el `.npmrc` del proyecto, o se uso alias `npm:` | Ver [INTEGRACION-DAVILOGIN.md](INTEGRACION-DAVILOGIN.md#2-dependencia). |
