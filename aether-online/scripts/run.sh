#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
COMMAND=${1:?usage: scripts/run.sh bootstrap|build|test}

case "$COMMAND" in
  bootstrap|build|test) ;;
  *)
    echo "usage: scripts/run.sh bootstrap|build|test" >&2
    exit 2
    ;;
esac
shift

if [[ -x "${HOME}/.dotnet/dotnet" ]]; then
  export DOTNET_ROOT="${DOTNET_ROOT:-${HOME}/.dotnet}"
  case ":${PATH}:" in
    *":${DOTNET_ROOT}:"*) ;;
    *) export PATH="${DOTNET_ROOT}:${PATH}" ;;
  esac
fi

if [[ -x "${HOME}/.local/bin/pwsh" ]]; then
  case ":${PATH}:" in
    *":${HOME}/.local/bin:"*) ;;
    *) export PATH="${HOME}/.local/bin:${PATH}" ;;
  esac
fi

if ! command -v pwsh >/dev/null 2>&1; then
  echo "pwsh is not on PATH. Install PowerShell 7.6.7 and retry." >&2
  exit 127
fi

exec pwsh -NoProfile -File "${SCRIPT_DIR}/${COMMAND}.ps1" "$@"
