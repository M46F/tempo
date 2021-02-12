#!/usr/bin/env bash

set -o nounset
set -o errexit
set -o pipefail

ROOT_FOLDER="$(dirname "${0}")/.."

if [ "$#" -ne 1 ]; then
  echo "Usage: ./update-version.sh <newVersion>"
  exit 1
fi

_updateVersion() {
  local _newVersion=$1
  local _versionPy=$2

  sed -i "s/^__version__ = \"\(.*\)\"$/__version__ = \"$_newVersion\"/" "$_versionPy"
}

_main() {
  local _newVersion=$1

  # To call within `-exec`
  export -f _updateVersion

  find $ROOT_FOLDER \
    -type f -name version.py \
    -path "$ROOT_FOLDER/tempo/*" \
    -exec bash -c "_updateVersion $_newVersion {}" \;
}

_main $1
