# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)

PKG_NAME="m64p"
PKG_VERSION="1.0"
PKG_SITE="https://m64p.github.io/"
PKG_URL=""
PKG_DEPENDS_TARGET="toolchain mupen64plus-core mupen64plus-rsp-hle mupen64plus-rsp-cxd4 mupen64plus-input-sdl mupen64plus-audio-sdl2 mupen64plus-ui-console mupen64plus-video-glide64mk2 GLideN64"
PKG_LONGDESC="mupen64plus + GLideN64 + a GUI"
PKG_TOOLCHAIN="manual"

configure_package() {
  # Build angrylion-rdp-plus & mupen64plus-gui for Generic
  if [ "${PROJECT}" = "Generic" ]; then
    PKG_DEPENDS_TARGET+=" mupen64plus-gui angrylion-rdp-plus"
  fi
}

makeinstall_target() {
  # Create directories
  mkdir -p $INSTALL/usr/bin
  mkdir -p $INSTALL/usr/config/mupen64plus
  mkdir -p $INSTALL/usr/lib/mupen64plus

  if [ "${PROJECT}" = "Generic" ]; then
    cp $(get_build_dir angrylion-rdp-plus)/.${TARGET_NAME}/*.so         $INSTALL/usr/lib/mupen64plus
    cp $(get_build_dir mupen64plus-gui)/.${TARGET_NAME}/mupen64plus-gui $INSTALL/usr/bin
    cp $PKG_DIR/scripts/gui/*                                           $INSTALL/usr/bin
  fi

  # Install binaries & scripts
  cp $(get_build_dir mupen64plus-ui-console)/mupen64plus $INSTALL/usr/bin/mupen64plus-cli
  cp $PKG_DIR/scripts/cli/*                              $INSTALL/usr/bin

  # Install config files
  cp $PKG_DIR/config/*                             $INSTALL/usr/config/mupen64plus
  cp $(get_build_dir GLideN64)/ini/*.ini           $INSTALL/usr/config/mupen64plus
  cp $(get_build_dir mupen64plus-core)/data/*      $INSTALL/usr/config/mupen64plus
  cp $(get_build_dir mupen64plus-input-sdl)/data/* $INSTALL/usr/config/mupen64plus
  cp $(get_build_dir mupen64plus-video-glide64mk2)/data/* $INSTALL/usr/config/mupen64plus

  # Install libs
  cp $(get_build_dir GLideN64)/libmupen64plus-video-GLideN64.so $INSTALL/usr/lib/mupen64plus
  cp $(get_build_dir mupen64plus-video-glide64mk2)/*-video-glide64mk2.so $INSTALL/usr/lib/mupen64plus
  cp $(get_build_dir mupen64plus-audio-sdl2)/*.so  $INSTALL/usr/lib/mupen64plus
  cp -P $(get_build_dir mupen64plus-core)/*.so*    $INSTALL/usr/lib/mupen64plus
  cp $(get_build_dir mupen64plus-input-sdl)/*.so   $INSTALL/usr/lib/mupen64plus
  cp $(get_build_dir mupen64plus-rsp-cxd4)/*.so    $INSTALL/usr/lib/mupen64plus
  cp $(get_build_dir mupen64plus-rsp-hle)/*.so     $INSTALL/usr/lib/mupen64plus
}
