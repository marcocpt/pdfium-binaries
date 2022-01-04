#!/usr/bin/env bash
#
# Variables to provide:
# PDFium_CONFIGURATION = Debug | Release
# PDFium_TARGET_CPU = x86 | x64 | arm | arm64
# PDFium_TARGET_OS = mac | ios | linux | win
# PDFium_BRANCH = main | chromium/3211 | ...
# PDFium_V8 = enabled
PDFium_CONFIGURATION=Debug
PDFium_TARGET_CPU=x64
PDFium_TARGET_OS=mac

set -ex

ENV_FILE=${GITHUB_ENV:-.env}
PATH_FILE=${GITHUB_PATH:-.path}

. steps/00-environment.sh
source "$ENV_FILE"

. steps/01-install.sh
PATH="$(tr '\n' ':' < "$PATH_FILE")$PATH"
export PATH

. steps/02-checkout.sh
. steps/03-patch.sh
. steps/04-install-extras.sh
. steps/05-configure.sh
. steps/06-build.sh
. steps/07-pack.sh
. steps/08-test.sh
