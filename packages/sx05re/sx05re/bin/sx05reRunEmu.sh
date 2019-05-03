#!/bin/bash
#https://github.com/RetroPie/RetroPie-Setup/blob/master/scriptmodules/supplementary/runcommand/runcommand.sh
#https://github.com/shantigilbert/CoreELEC/blob/addon_v2.5/packages/sx05re/sx05re/bin/sx05reRunEmu.sh
#Input parameters (es_systems.cfg)
#Standard System. RETROARCH
#1: System 
#2: %ROM% - Replaced with absolute path to the selected ROM, with most Bash special characters escaped with a backslash.
#2: %ROM_RAW%	- Replaced with the unescaped, absolute path to the selected ROM. If your emulator is picky about paths, you might want to use this instead of %ROM%, but enclosed in quotes.
#3: %BASENAME%	- Replaced with the "base" name of the path to the selected ROM. For example, a path of "/foo/bar.rom", this tag would be "bar". This tag is useful for setting up AdvanceMAME.
#Special system. Stand-alone
#1': Name of system: LIBRETRO, REICAST, MAME, PSP,...
#2': $2_libretro.so or %ROM%
#3': %ROM%

# Set Global variables
ROOTDIR="/storage"
CONFIGDIR="$ROOTDIR/.config/retroarch/configs"
ROMDIR="$ROOTDIR/roms"
LOG="/storage/sx05re.log"
SYSTEM="LIBRETRO REICAST ADVMAME PSP"

#Functions
# Set framebuffer geometry to match the resolution, splash should change according to the resolution.
function Set_framebuffer() {
local hdmimode=`cat /sys/class/display/mode`;
local splash
case $hdmimode in
  480*)            X=720  Y=480  splash="/storage/.config/splash/splash-1080.png" ;;
  576*)            X=720  Y=576  splash="/storage/.config/splash/splash-1080.png" ;;
  720p*)           X=1280 Y=720  splash="/storage/.config/splash/splash-1080.png" ;;
  *)               X=1920 Y=1080 splash="/storage/.config/splash/splash-1080.png" ;;
esac
echo "$splash"
}

#Check special system = "LIBRETRO" "REICAST" "ADVMAME" "PSP"
function check_system(){
#1 = Special System
	local item
    for item in $SYSTEM; do
	if [[ "$1" -eq "$item" ]]; then
		echo "Stand-alone System: $item" >> $LOG
		return 1
	fi
	done
}
#Get and append cfg of rom
function retroarch_append_config() {
local romcfg="$ROMDIR/$1/$2.cfg"
if [[ -e "$romcfg" ]]; then
   echo "$romcfg"
   else
   return 0
fi
}
#Get core
function get_core() {
local pat
local core
local emu_conf="$CONFIGDIR/all/emulators.cfg"
#Get core. 1 find in all(by game). 2. find in system patch
#1. emu_conf='/storage/.config/configs/all/emulators.cfg'
#system_romclean = "core"
pat="s|\s*$1_$2) = \"\(.*\)\"|\1|p"
core=$(sed -n "$pat" "$emu_conf")
#2. emu_conf='/storage/.config/configs/system/emulators.cfg'
#default = "core"
if [ -z "${core}" ]; then
	emu_conf="$CONFIGDIR/$1/emulators.cfg"
	pat="s|\s*default = \"\(.*\)\"|\1|p"
	core=$(sed -n "$pat" "$emu_conf")
fi
echo "${core}"
}
function get_params() {
local runcommand
local romcfg
local emulatorscfg="$CONFIGDIR/$1/emulators.cfg"
local romclean
local core_name
local patchore
#Get name of rom "packed"
romclean=$(clean_name "$3")

#Check special system
if [[ $(check_system) = 1 ]]; then
	exit
fi

#Get core name
core_name=$(get_core "$1" "$romclean")

#Get command of core in emulators.cfg
#core_name = "command"
patchore="s|\s*$core_name = \"\(.*\)\"|\1|p" 
if [ -n "${patchore}" ]; then
	if [[ -e "$emulatorscfg" ]]; then
		runcommand=$(sed -n "$patchore" "$emulatorscfg")
#Change --config /storage/.config/configs/system/retroarch.cfg -> --config /storage/.config/configs/tmp/retroarch.cfg
		runcommand=$(tmp_cfg "$1" "$runcommand")
		if [[ -z "$runcommand" ]]; then
			return 1
		fi
	fi

#Append Rom confing. %ROM% -> --appendconfig /storage/roms/system/romclean.cfg %ROM%"
	romcfg=$(retroarch_append_config "$1" "$romclean")
	if [ -n "$romcfg" ]; then
	runcommand=${runcommand//%ROM%/--appendconfig $romcfg %ROM%}
	fi

#Set ROM name
	runcommand=${runcommand//%ROM%/\"$2\"}
	echo $runcommand
else
#Default runcommand
	return 1
fi 

#Default RUNTHIS
if [ -z "${runcommand}" ]; then
return 1
fi
}
#Create temp files
function tmp_cfg() {
local cdir="$CONFIGDIR/$1/retroarch.cfg"
local cdirtmp="$CONFIGDIR/tmp/retroarch.cfg"
local tmprun="$2"
# make sure tmp folder
mkdir "$CONFIGDIR/tmp"
#delete tmp file
if [ -e "${cdirtmp}" ]; then
	mv "$cdirtmp"
fi
#Copy file to tmp dir
cp "$cdir" "$cdirtmp" 
#Change directory temp
tmprun=${tmprun//\/$1\//\/tmp\/}
echo "${tmprun}"
}
#Delete temp files
function tmp_del() {
local cdirtmp="$CONFIGDIR/tmp"
if [ -e "${cdirtmp}" ]; then
	rm -rf "$cdirtmp"/*
fi
}
#Clean ROM name. 3-D WorldRunner (USA)-> 3-DWorldRunnerUSA
function clean_name() {
    local name="$1"
    name="${name//\//_}"
    name="${name//[^a-zA-Z0-9_\-]/}"
    echo "${name}"
}

#Main
# Clear the log file
rm -f "$LOG"
echo "Sx05RE Run Log" >> $LOG
RUNTHIS=$(get_params "$@")

#Default RUNTHIS
if [[ -z "${RUNTHIS}" ]]; then
	CFG="/storage/.emulationstation/es_settings.cfg"
	PAT="s|\s*<string name=\"Sx05RE_$1_CORE\" value=\"\(.*\)\" />|\1|p"
	EMU=$(sed -n "$PAT" "$CFG")
	RUNTHIS='/storage/.kodi/addons/script.sx05re.launcher/bin/retroarch -L /storage/.config/retroarch/cores/${EMU}_libretro.so "$2"'
fi

# Else, read the first argument to see if its LIBRETRO, REICAST, MAME or PSP
case $1 in
"LIBRETRO")
   RUNTHIS='/storage/.kodi/addons/script.sx05re.launcher/bin/retroarch -L /storage/.kodi/addons/script.sx05re.launcher/lib/libretro/$2_libretro.so "$3"'
         ;;
"REICAST")
   RUNTHIS='/storage/.kodi/addons/script.sx05re.launcher/bin/reicast.sh "$2"'
         ;;
"ADVMAME")
   RUNTHIS='/storage/.kodi/addons/script.sx05re.launcher/bin/advmame.sh "$2"'
         ;;
"PSP")
      if [ "$EMU" = "PPSSPPSA" ]; then
   #PPSSPP can run at 32BPP but only with buffered rendering, some games need non-buffered and the only way they work is if I set it to 16BPP
   /storage/.kodi/addons/script.sx05re.launcher/bin/setres.sh 16
   RUNTHIS='/storage/.kodi/addons/script.sx05re.launcher/bin/ppsspp.sh "$2"'
      fi
        ;;
esac


# Splash screen, not sure if this is the best way to do it, but it works so far, but not as good as I want it too with PPSSPPSDL and advmame :(
(
  echo "" #fbi $(Set_framebuffer) -noverbose > /dev/null 2>&1
)&

# Write the command to the log file.
echo "1st parameter: $1" >> $LOG 
echo "2nd Parameter: $2" >> $LOG 
echo "3rd Parameter: $3" >> $LOG 
echo "4th Parameter: $4" >> $LOG 
echo "Run Command is:" >> $LOG 
eval echo  ${RUNTHIS} >> $LOG 

# Exceute the command and try to output the results to the log file if it was not dissabled.
if [ "$3" == "NOLOG" ] || [ "$4" == "NOLOG" ]; then
   echo "Emulator log was dissabled" >> $LOG
   eval ${RUNTHIS}
else
   echo "Emulator Output is:" >> $LOG
   eval ${RUNTHIS} >> $LOG 2>&1
fi 

#Delete temp files
$(tmp_del)

# Return to default mode
/storage/.kodi/addons/script.sx05re.launcher/bin/setres.sh
