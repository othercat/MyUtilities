#!/bin/bash
#   Auto Plist Increment Version Script
#
#   @(#)  Increment the version number in the project plist.
#   Note: The project plist could be in directory "Resources" or the project root.
#         Personally, I avoid clutter in the project root.
#               
# Enjoy! xaos@xm5design.com verified with Xcode 3.2.2
# modify by othercat@gmail.com at 2012/05/30
#
# Found here: http://davedelong.com/blog/2009/04/15/incrementing-build-numbers-xcode
# Set the paths to the build and settings Plist

GIT=git
#GITOPTIONS='--pretty=oneline --abbrev-commit'
CUT=/usr/bin/cut
PLIST=/usr/libexec/PlistBuddy

PROJECTMAIN=$(pwd)
PROJECT_NAME=$(basename "${PROJECTMAIN}")

conf=${CONFIGURATION}
arch=${ARCHS:0:4}
# Only increase the build number on Device and AdHoc/AppStore build
#if [ $conf != "Debug" ] && [ $conf != "Release" ] && [ $arch != "i386" ]

if [[ "${INFOPLIST_PATH}" = "" ]]
then
      	if    	[[ -f "${PROJECTMAIN}/Resources/${TARGETNAME}-Info.plist" ]]
      	then  
				buildPlist="${PROJECTMAIN}/Resources/${TARGETNAME}-Info.plist"
      	elif  	[[ -f "${PROJECTMAIN}/${TARGETNAME}-Info.plist" ]]
      	then
           		buildPlist="${PROJECTMAIN}/${TARGETNAME}-Info.plist"
      	else
           		echo -e "Can't find the plist: ${TARGETNAME}-Info.plist"
            	exit 1
      	fi
else
		buildPlist="${TARGET_BUILD_DIR}/${INFOPLIST_PATH}"
fi

echo -e "build plst location is \"${buildPlist}\""

buildVersion=$($PLIST -c "Print CFBundleVersion" "${buildPlist}" 2>/dev/null)
buildShortVersion=$($PLIST -c "Print CFBundleShortVersionString" "${buildPlist}" 2>/dev/null)
#buildNumber=$($PLIST -c "Print CFBuildNumber" "${buildPlist}" 2>/dev/null)

if [[ "${buildVersion}" = "" ]]
then
		echo -e "\"${buildPlist}\" does not contain key: \"CFBundleVersion\""
		exit 1
#else
#		echo -e "build version is \"${buildVersion}\""
fi

IFS='.'
set $buildVersion
if 	[[ "${1}" = "" ]]
then
	major_1=0
else
	major_1=${1}
fi
if 	[[ "${2}" = "" ]]
then
	major_2=0
else
	major_2=${2}
fi
if 	[[ "${3}" = "" ]]
then
	major_3=0
else
	major_3=${3}
fi
if 	[[ "${4}" = "" ]]
then
	major_4=0
else
	major_4=${4}
fi
MAJOR_VERSION="${major_1}.${major_2}.${major_3}"
MINOR_VERSION="${major_1}" #${major_4}
buildNumber=$(($MINOR_VERSION + 1))
buildNewVersion="${buildShortVersion}.${buildNumber}"

if    	[[ -f ${buildPlist} ]]
then  
		echo -e "found the plist"
else
   		echo -e "Can't find the plist"
    	exit 1
fi

echo -e "${TARGETNAME}: Old version number: ${buildShortVersion}.${buildVersion} New Version Number: ${buildNewVersion}"

$PLIST -c "Set :CFBundleVersion ${buildNumber}" ${TARGET_BUILD_DIR}/${TARGETNAME}.framework/Versions/A/Resources/Info.plist

#This just extracted the subversion revision number and inserted it into a key named BuildRevision in the targets Info.plist file

buildRevision=$(${GIT} log -1 --pretty=oneline --abbrev-commit | ${CUT} -c1-7  2>/dev/null)

echo -e "$PLIST -c \"Set :BuildRevision ${buildRevision}\" ${TARGET_BUILD_DIR}/${TARGETNAME}.framework/Versions/A/Resources/Info.plist"
#pwd

$PLIST -c "Set :BuildRevision ${buildRevision}" ${TARGET_BUILD_DIR}/${TARGETNAME}.framework/Versions/A/Resources/Info.plist

# Set the version numbers in the settingsPlist (Your path to the key you store your version number may vary, mine is in item 0)
#if [[ -f "Settings.bundle/Root.plist" ]]
#then
# settingsPlist="Settings.bundle/Root.plist"
# /usr/libexec/PlistBuddy -c "Set :PreferenceSpecifiers:0:DefaultValue $buildVersion.$buildNumber" ${settingsPlist}
#fi



