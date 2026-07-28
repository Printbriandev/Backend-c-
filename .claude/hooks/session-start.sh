#!/bin/bash
# SessionStart hook — prepara el entorno e imprime el estado del repo.
#
# Dos trabajos:
#   1. Snapshot del repo (rama, commits, cambios pendientes, proyectos, bitácora)
#      para que la sesión arranque sabiendo en qué punto quedamos.
#   2. Instalar el .NET SDK y restaurar paquetes, pero solo si ya hay proyectos C#.
set -euo pipefail

REPO_DIR="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$REPO_DIR"

echo "==================== ESTADO DEL REPOSITORIO ===================="
echo "Fecha:  $(date '+%Y-%m-%d %H:%M')"
echo "Rama:   $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'desconocida')"
echo
echo "--- Últimos commits ---"
git log --oneline -10 2>/dev/null || echo "(sin historial)"
echo
echo "--- Cambios sin commitear ---"
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
  git status --short
else
  echo "(ninguno, árbol limpio)"
fi
echo
echo "--- Proyectos C# detectados ---"
PROYECTOS=$(find . -name '*.csproj' -o -name '*.sln' 2>/dev/null | grep -v '/obj/' | grep -v '/bin/' || true)
if [ -n "$PROYECTOS" ]; then
  echo "$PROYECTOS"
else
  echo "(todavía no hay proyectos ni soluciones)"
fi
echo
echo "--- Últimas entradas de la bitácora ---"
if [ -f docs/BITACORA.md ]; then
  # Desde el primer encabezado de entrada, las ~40 líneas siguientes.
  awk '/^## [0-9]{4}-/{found=1} found' docs/BITACORA.md | head -40
else
  echo "(docs/BITACORA.md no existe)"
fi
echo
echo "Lee CLAUDE.md y docs/BITACORA.md antes de empezar a trabajar."
echo "Al terminar, añade una entrada nueva a docs/BITACORA.md."
echo "================================================================"

# --- Preparación del entorno .NET (solo en el entorno remoto y si hay proyectos) ---
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

if [ -z "$PROYECTOS" ]; then
  echo "Sin proyectos C#: se omite la instalación del SDK de .NET."
  exit 0
fi

DOTNET_ROOT_DIR="$HOME/.dotnet"
if ! command -v dotnet >/dev/null 2>&1 && [ ! -x "$DOTNET_ROOT_DIR/dotnet" ]; then
  echo "Instalando el SDK de .NET..."
  # La instalación puede fallar si la política de red del entorno bloquea los dominios
  # de Microsoft. No debe tumbar el arranque de la sesión: se avisa y se sigue.
  if curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh; then
    chmod +x /tmp/dotnet-install.sh
    /tmp/dotnet-install.sh --channel LTS --install-dir "$DOTNET_ROOT_DIR" || \
      echo "Aviso: la instalación del SDK de .NET falló."
  else
    echo "Aviso: no se pudo descargar el instalador de .NET (probable bloqueo de red)."
    echo "       Para habilitarlo, permitir estos dominios en la política de red del entorno:"
    echo "         dot.net, builds.dotnet.microsoft.com, dotnetcli.azureedge.net, api.nuget.org"
  fi
fi

if [ -x "$DOTNET_ROOT_DIR/dotnet" ]; then
  export DOTNET_ROOT="$DOTNET_ROOT_DIR"
  export PATH="$DOTNET_ROOT_DIR:$PATH"
  {
    echo "export DOTNET_ROOT=\"$DOTNET_ROOT_DIR\""
    echo "export PATH=\"$DOTNET_ROOT_DIR:\$PATH\""
    echo "export DOTNET_CLI_TELEMETRY_OPTOUT=1"
    echo "export DOTNET_NOLOGO=1"
  } >> "${CLAUDE_ENV_FILE:-/dev/null}"
fi

if command -v dotnet >/dev/null 2>&1; then
  echo "SDK de .NET: $(dotnet --version)"
  echo "Restaurando paquetes..."
  dotnet restore || echo "Aviso: 'dotnet restore' falló; revisar manualmente."
else
  echo "Aviso: no se pudo dejar 'dotnet' disponible en el PATH."
fi
