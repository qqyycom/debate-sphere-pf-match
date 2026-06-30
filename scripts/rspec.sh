#!/usr/bin/env bash
set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_REALPATH="$(cd "${PLUGIN_ROOT}" && pwd -P)"
PLUGIN_NAME="$(basename "${PLUGIN_ROOT}")"

if [[ -z "${DISCOURSE_ROOT:-}" ]]; then
  if [[ "$(basename "$(dirname "${PLUGIN_ROOT}")")" == "plugins" ]]; then
    DISCOURSE_ROOT="$(cd "${PLUGIN_ROOT}/../.." && pwd)"
  else
    DISCOURSE_ROOT="${PLUGIN_ROOT}/../discourse"
  fi
fi

INSTALLED_PLUGIN_ROOT="${DISCOURSE_ROOT}/plugins/${PLUGIN_NAME}"
PLUGIN_SPEC_PATH="plugins/${PLUGIN_NAME}/spec"

if [[ ! -d "${DISCOURSE_ROOT}" ]]; then
  echo "Discourse root not found. Set DISCOURSE_ROOT=/path/to/discourse." >&2
  exit 1
fi

if [[ ! -d "${INSTALLED_PLUGIN_ROOT}" ]]; then
  echo "Plugin is not available at ${INSTALLED_PLUGIN_ROOT}." >&2
  echo "Install or symlink this plugin there before running specs." >&2
  exit 1
fi

INSTALLED_PLUGIN_REALPATH="$(cd "${INSTALLED_PLUGIN_ROOT}" && pwd -P)"
if [[ "${INSTALLED_PLUGIN_REALPATH}" != "${PLUGIN_REALPATH}" ]]; then
  echo "Installed plugin path does not point to this checkout:" >&2
  echo "  this checkout: ${PLUGIN_REALPATH}" >&2
  echo "  installed path: ${INSTALLED_PLUGIN_REALPATH}" >&2
  echo "Symlink this checkout to ${INSTALLED_PLUGIN_ROOT} before running specs." >&2
  exit 1
fi

cd "${DISCOURSE_ROOT}"
LOAD_PLUGINS=1 bundle exec rspec "${PLUGIN_SPEC_PATH}" "$@"
