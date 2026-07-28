# CLAUDE.md — Contexto del proyecto

> Este archivo es la **memoria permanente** del repositorio. Claude lo lee automáticamente
> al iniciar cualquier sesión. Si algo debe sobrevivir de una conversación a la siguiente,
> va aquí o en la bitácora.

## Qué es este repo

**Backend Bootcamp — C# y ASP.NET Core.** Repositorio de aprendizaje/práctica de backend
con C# y ASP.NET Core. El contenido se va construyendo a medida que avanza el bootcamp.

- Owner: `printbriandev`
- Repo: `Backend-c-`
- Rama por defecto: `main`
- Rama de trabajo de Claude: `claude/repo-changes-monitoring-4j3elf`

## Estado actual

Ver `docs/BITACORA.md` para el registro cronológico completo. Resumen vivo:

- El repo arrancó con un único commit (`README.md`) y sin código todavía.
- Aún no hay solución (`.sln`) ni proyectos (`.csproj`).
- El contenedor remoto **no trae el .NET SDK preinstalado**; el hook de arranque intenta
  instalarlo en cuanto existan proyectos C# en el repo.
- ⚠️ **La política de red del entorno bloquea los dominios de .NET** (verificado:
  `builds.dotnet.microsoft.com` devuelve 403 en el proxy). Mientras siga así, `dotnet`
  no estará disponible en las sesiones remotas y no se podrá compilar ni testear aquí.
  Para arreglarlo hay que permitir en la política de red del entorno:
  `dot.net`, `builds.dotnet.microsoft.com`, `dotnetcli.azureedge.net`, `api.nuget.org`.

## Cómo fluimos (convenciones de trabajo)

### Al empezar cada sesión
1. El hook `.claude/hooks/session-start.sh` imprime un snapshot del repo
   (commits recientes, proyectos detectados, últimas entradas de bitácora).
2. Claude lee este `CLAUDE.md` y `docs/BITACORA.md` antes de tocar nada.
3. Si hay dudas sobre en qué quedamos, la bitácora manda.

### Al terminar cada sesión / cada cambio relevante
1. Añadir una entrada nueva en `docs/BITACORA.md` (arriba del todo, más reciente primero).
2. Actualizar la sección "Estado actual" de este archivo si cambió algo estructural
   (nuevo proyecto, nueva dependencia, nueva decisión de arquitectura).
3. Commit + push a la rama de trabajo.

### Git
- Todo el desarrollo de Claude va a `claude/repo-changes-monitoring-4j3elf`.
- Nunca commits directos a `main`.
- Mensajes de commit en español, en imperativo y descriptivos
  (ej: `agrega endpoint de productos`, no `cambios`).
- Push siempre con `git push -u origin <rama>`.

### Código C# / ASP.NET Core
Convenciones estándar de .NET (se irán ajustando conforme aparezca código real):

- `PascalCase` para clases, métodos, propiedades y namespaces.
- `camelCase` para variables locales y parámetros; `_camelCase` para campos privados.
- Un tipo público por archivo, nombre de archivo = nombre del tipo.
- Estructura habitual de solución:
  ```
  src/<Proyecto>/          proyecto principal (Web API)
  tests/<Proyecto>.Tests/  pruebas
  <Solución>.sln
  ```
- Comandos base: `dotnet build`, `dotnet test`, `dotnet run --project src/<Proyecto>`.
- Formateo: `dotnet format` (verificación: `dotnet format --verify-no-changes`).

## Notas y pendientes

- `README.md` está guardado en **UTF-16** (creado desde PowerShell en Windows). Se lee
  raro en algunas herramientas; conviene reguardarlo en UTF-8 cuando se toque.
- Cuando se cree el primer proyecto, actualizar en este archivo los comandos reales de
  build/test y confirmar que el hook de arranque los deja funcionando.
