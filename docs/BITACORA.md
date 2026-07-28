# Bitácora del repositorio

Registro cronológico de todo lo que va cambiando en el repo, **más reciente primero**.
Sirve para que cualquier sesión nueva de Claude (o cualquier persona) sepa en qué punto
quedamos sin tener que reconstruirlo leyendo commits.

Formato de cada entrada:

```
## AAAA-MM-DD — Título corto
**Estado:** en curso | terminado | bloqueado
**Cambios:** qué se tocó
**Decisiones:** por qué se hizo así
**Siguiente paso:** qué queda pendiente
```

---

## 2026-07-28 — Sistema de seguimiento del repo

**Estado:** terminado

**Cambios:**
- `CLAUDE.md`: contexto permanente del proyecto (qué es, estado, convenciones de trabajo,
  convenciones de C#/.NET, notas y pendientes).
- `docs/BITACORA.md`: este archivo, registro cronológico de cambios.
- `.claude/hooks/session-start.sh`: hook que corre al iniciar cada sesión remota. Imprime
  un snapshot del repo (rama, commits recientes, cambios sin commitear, proyectos C#
  detectados, últimas entradas de bitácora) e instala el .NET SDK + `dotnet restore`
  cuando ya existan proyectos.
- `.claude/settings.json`: registra el hook `SessionStart`.
- `.gitignore`: ignora artefactos de .NET (`bin/`, `obj/`, `.vs/`, `*.user`, etc.).

**Decisiones:**
- El contenedor remoto es efímero: se borra al terminar la sesión. La única forma de que
  el contexto sobreviva es **commitearlo al repo**, no guardarlo en memoria de sesión.
  De ahí que el seguimiento sean archivos versionados y no notas internas.
- El hook corre en modo **síncrono** para que las dependencias estén listas antes de que
  arranque el agente (evita que intente compilar o testear antes de tiempo).
- La instalación del .NET SDK está condicionada a que existan `.sln`/`.csproj`: hoy el
  repo no tiene código, así que el arranque es instantáneo. En cuanto haya un proyecto,
  el hook instala el SDK solo.

**Estado del repo en este punto:**
- Un commit previo (`1bfe20f primer commit - Backend C#`) con solo `README.md`.
- Sin solución ni proyectos C# todavía.

**Hallazgo — red bloqueada para .NET:**
La política de red de este entorno remoto rechaza los dominios de Microsoft
(`builds.dotnet.microsoft.com` → 403 en el proxy), así que la instalación automática del
SDK no funciona todavía. El hook lo detecta, avisa y **no rompe el arranque** (sale con
código 0). Para habilitarlo hay que permitir `dot.net`, `builds.dotnet.microsoft.com`,
`dotnetcli.azureedge.net` y `api.nuget.org` en la configuración del entorno.

**Validación hecha:**
- Hook con repo sin proyectos → imprime el snapshot y sale limpio (exit 0). ✅
- Hook con un `.csproj` de prueba → intenta instalar, falla la descarga, avisa con las
  instrucciones y sale limpio (exit 0). ✅
- Linter y tests: no ejecutados, todavía no hay código ni SDK disponible.

**Siguiente paso:**
- Mergear esta rama a `main` para que todas las sesiones futuras usen el hook.
- Desbloquear los dominios de .NET en la política de red del entorno.
- Crear el primer proyecto ASP.NET Core y actualizar en `CLAUDE.md` los comandos reales
  de build/test.
