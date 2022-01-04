#!/bin/bash -eux

CFG=${CONFIGURATION:-Release}
V8=${V8:-disabled}
OS=${PDFium_TARGET_OS:?}
CPU=${PDFium_TARGET_CPU:?}
VERSION=${PDFium_VERSION:-}

STAGING="$PWD/staging"
SOURCE=${PDFium_SOURCE_DIR:-pdfium}
BUILD=${PDFium_BUILD_DIR:-pdfium/out}

if [ "$OS" == "win" ]; then
  STAGING_BIN="$STAGING/$CPU/bin"
  STAGING_LIB="$STAGING/$CPU/lib"
  STAGING_RES="$STAGING/$CPU/res"
else
  STAGING_LIB="$STAGING/lib"
  STAGING_RES="$STAGING/res"
fi

mkdir -p "$STAGING"
mkdir -p "$STAGING_LIB"

cp PDFiumConfig.cmake "$STAGING"
cp "$SOURCE/LICENSE" "$STAGING"
cp "$BUILD/args.gn" "$STAGING"
cp -R "$SOURCE/public" "$STAGING/include"
rm -f "$STAGING/include/DEPS"
rm -f "$STAGING/include/README"
rm -f "$STAGING/include/PRESUBMIT.py"
case "$OS" in
  mac)
    mv "$BUILD/libpdfium.dylib" "$STAGING_LIB/libpdfium_macOS.dylib"
    install_name_tool -id @rpath/libpdfium_macOS.dylib "$STAGING_LIB/libpdfium_macOS.dylib"
    ;;
  linux)
    mv "$BUILD/libpdfium.so" "$STAGING_LIB"
    ;;
  android)
    mv "$BUILD/libpdfium.cr.so" "$STAGING_LIB/libpdfium.so"
    ;;
  win)
    mv "$BUILD/pdfium.dll.lib" "$STAGING_LIB"
    mkdir -p "$STAGING_BIN"
    mv "$BUILD/pdfium.dll" "$STAGING_BIN"
    [ "$CFG" == "Debug" ] && mv "$BUILD/pdfium.dll.pdb" "$STAGING_BIN"
    ;;
esac

if [ "$V8" == "enabled" ]; then
  mkdir -p "$STAGING_RES"
  mv "$BUILD/icudtl.dat" "$STAGING_RES"
  mv "$BUILD/snapshot_blob.bin" "$STAGING_RES"
fi

[ -n "$VERSION" ] && cat >"$STAGING/VERSION" <<END
MAJOR=$(echo "$VERSION" | cut -d. -f1)
MINOR=$(echo "$VERSION" | cut -d. -f2)
BUILD=$(echo "$VERSION" | cut -d. -f3)
PATCH=$(echo "$VERSION" | cut -d. -f4)
END

ARTIFACT_BASE="$PWD/pdfium-$OS-$CPU"
[ "$V8" == "enabled" ] && ARTIFACT_BASE="$ARTIFACT_BASE-v8"
[ "$CFG" == "Debug" ] && ARTIFACT_BASE="$ARTIFACT_BASE-debug"
ARTIFACT="$ARTIFACT_BASE.tgz"

pushd "$STAGING"
tar cvzf "$ARTIFACT" -- *
popd