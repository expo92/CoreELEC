# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)

PKG_NAME="GLideN64"
PKG_VERSION="34fa719a61fa2338025facc9810ad2ef1a00e7ee"
PKG_SHA256=""
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/gonetz/GLideN64"
PKG_URL="https://github.com/gonetz/GLideN64/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain linux glibc freetype:host zlib bzip2 libpng ${OPENGLES}"
PKG_LONGDESC="A new generation, open-source graphics plugin for N64 emulators."
PKG_TOOLCHAIN="cmake"
PKG_BUILD_FLAGS="-gold"
 
pre_configure_target() {
  PKG_CMAKE_SCRIPT="$PKG_BUILD/src/CMakeLists.txt"
  PKG_CMAKE_OPTS_TARGET="-DMUPENPLUSAPI=On -DGLES2=1 -DNEON_OPT=On"
  
  # Fix revision header
  PKG_REV_H=$PKG_BUILD/src/Revision.h
  echo "#define PLUGIN_REVISION" ""\"${PKG_VERSION:0:10}""\"     > ${PKG_REV_H}
  echo "#define PLUGIN_REVISION_W" "L"\"${PKG_VERSION:0:10}""\" >> ${PKG_REV_H}

  rm -rf $PKG_BUILD/src/GLideNHQ/inc
}

makeinstall_target() {
 :
}
