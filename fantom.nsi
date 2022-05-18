#
# Fantom installer
#
# Built with large strings build for 3.0b1 -> http://nsis.sourceforge.net/Special_Builds

!define VERSION "1.0.78"
!define AF_VERSION "1.0.78"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "etc\fantomBanner.bmp"
!define UNINST_REG_KEY	"Software\Microsoft\Windows\CurrentVersion\Uninstall\Fantom"

!define MULTIUSER_EXECUTIONLEVEL Highest
!define MULTIUSER_INSTALLMODE_DEFAULT_CURRENTUSER
!define MULTIUSER_INSTALLMODE_DEFAULT_REGISTRY_KEY			"${UNINST_REG_KEY}"
!define MULTIUSER_INSTALLMODE_DEFAULT_REGISTRY_VALUENAME	"InstallLocation"
!define MULTIUSER_INSTALLMODE_INSTDIR_REGISTRY_KEY			"${UNINST_REG_KEY}"
!define MULTIUSER_INSTALLMODE_INSTDIR_REGISTRY_VALUENAME	"InstallLocation"
!define MULTIUSER_MUI
!define MULTIUSER_INSTALLMODE_COMMANDLINE

# Uncomment for dev
#!define MUI_FINISHPAGE_NOAUTOCLOSE
#!define MUI_UNFINISHPAGE_NOAUTOCLOSE

!include "MultiUser.nsh"		; Multi-Users
!include "MUI2.nsh"				; Modern UI
!include "x64.nsh"				; 64 bit detection
!include "inc\EnvVarUpdate.nsh"	; 

Name 				"Fantom ${VERSION}"
OutFile 			"fantom-${AF_VERSION}.exe"
InstallDir 			"$PROGRAMFILES\fantom-${VERSION}\"

BrandingText		"NSIS Fantom Installer by Steve Eynon"
!define MUI_ICON	"etc\fantom.ico"
!define MUI_UNICON	"etc\uninstall.ico"

VIAddVersionKey "ProductName"		"Fantom"
VIAddVersionKey "Comments"			"NSIS Fantom Installer by Steve Eynon"
VIAddVersionKey "LegalCopyright"	"(c) 2011, Brian Frank and Andy Frank"
VIAddVersionKey "FileDescription"	"Installer for the Fantom Language"
VIAddVersionKey "FileVersion"		"${AF_VERSION}"
VIProductVersion "1.0.78.0"
VIFileVersion	 "1.0.78.0"

Var AF_ORIG_INSTDIR


# ---- Pages ------------------------------------------------------------------
!insertmacro MUI_PAGE_COMPONENTS
!define MUI_PAGE_CUSTOMFUNCTION_PRE 	multiuser_pre_func
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE	multiuser_post_func
!insertmacro MULTIUSER_PAGE_INSTALLMODE
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

!insertmacro MUI_LANGUAGE "English"

# see https://nsis-dev.github.io/NSIS-Forums/html/t-292340.html
Function multiuser_pre_func
	ClearErrors
	ReadRegStr $R1 SHCTX "${UNINST_REG_KEY}" "InstallLocation"
	${Unless} ${Errors}
		Abort
	${EndUnless}
FunctionEnd

Function multiuser_post_func
	${If} "$MultiUser.InstallMode" == "CurrentUser"
		StrCpy $INSTDIR "$LOCALAPPDATA\fantom-${VERSION}\"
	${Else}
		StrCpy $INSTDIR $AF_ORIG_INSTDIR
	${EndIf}
FunctionEnd

# -----------------------------------------------------------------------------
Section "Application Files" applicationFiles
	SectionIn RO

	SetOutPath "$INSTDIR"
	File	fantom\readme.html
	File	fantom\readme.md

	SetOutPath "$INSTDIR\bin"
	File	/r fantom\bin\*.*
	File	etc\fantom.ico

	SetOutPath "$INSTDIR\etc"
	File	/r fantom\etc\*.*

	SetOutPath "$INSTDIR\lib"
	File	/r /x ext "fantom\lib\*.*"
	
	${If} "$MultiUser.InstallMode" == "AllUsers"
		WriteRegStr HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "FAN_HOME" "$INSTDIR"
		${EnvVarUpdate} $0 "PATH" 		"A" HKLM "%FAN_HOME%\bin"
	${Else}
		WriteRegStr HKCU "Environment" "FAN_HOME" "$INSTDIR"
		${EnvVarUpdate} $0 "PATH" 		"A" HKCU "%FAN_HOME%\bin"
	${EndIf}
	
	WriteUninstaller "$INSTDIR\Uninstall.exe"

	# see http://nsis.sourceforge.net/Add_uninstall_information_to_Add/Remove_Programs#With_a_MultiUser_Installer
	${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
	IntFmt $0 "0x%08X" $0
	WriteRegDWORD	SHCTX "${UNINST_REG_KEY}" "EstimatedSize"		"$0"
	WriteRegStr		SHCTX "${UNINST_REG_KEY}" "InstallLocation"		"$INSTDIR"
	WriteRegStr		SHCTX "${UNINST_REG_KEY}" "DisplayName" 		"Fantom ${VERSION}"
	WriteRegStr		SHCTX "${UNINST_REG_KEY}" "Publisher" 			"Fantom-Factory"
	WriteRegStr		SHCTX "${UNINST_REG_KEY}" "DisplayVersion"		"${VERSION}"
	WriteRegStr		SHCTX "${UNINST_REG_KEY}" "DisplayIcon" 		"$INSTDIR\bin\fantom.ico"
	WriteRegStr		SHCTX "${UNINST_REG_KEY}" "UninstallString" 	"$\"$INSTDIR\Uninstall.exe$\" /$MultiUser.InstallMode"
	WriteRegStr 	SHCTX "${UNINST_REG_KEY}" "QuietUninstallString" "$\"$INSTDIR\Uninstall.exe$\" /$MultiUser.InstallMode /S"
SectionEnd



# -----------------------------------------------------------------------------
Section "Admin Tools" adminTools
	SetOutPath "$INSTDIR\adm"
	File	/r extras\adm\*.*
SectionEnd



# -----------------------------------------------------------------------------
Section ".NET Runtime" dotnetRuntime
	SetOutPath "$INSTDIR\lib\dotnet"
	File	/r extras\dotnet\*.*
SectionEnd



# -----------------------------------------------------------------------------
Section "Examples" examples
	SetOutPath "$INSTDIR\examples"
	File	/r extras\examples\*.*
SectionEnd



# -----------------------------------------------------------------------------
Section "Source Files" sourceFiles
	SetOutPath "$INSTDIR\src"
	File	/r extras\src\*.*
SectionEnd



# -----------------------------------------------------------------------------
Section "SWT" swt
	SetOutPath "$INSTDIR\lib\java"
	File	/r extras\swt\*.*
SectionEnd



LangString DESC_applicationFiles	${LANG_ENGLISH} "Core Fantom libraries"
LangString DESC_adminTools 			${LANG_ENGLISH} "Admin scripts and text editor configutaion files"
LangString DESC_dotnetRuntime		${LANG_ENGLISH} ".NET Runtime"
LangString DESC_examples			${LANG_ENGLISH} "Fantom examples"
LangString DESC_sourceFiles			${LANG_ENGLISH} "Fantom source files"
LangString DESC_swt					${LANG_ENGLISH} "Standard Widgit Toolkit"
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${applicationFiles}	$(DESC_applicationFiles)
!insertmacro MUI_DESCRIPTION_TEXT ${adminTools} 		$(DESC_adminTools)
!insertmacro MUI_DESCRIPTION_TEXT ${dotnetRuntime}		$(DESC_dotnetRuntime)
!insertmacro MUI_DESCRIPTION_TEXT ${examples}			$(DESC_examples)
!insertmacro MUI_DESCRIPTION_TEXT ${sourceFiles}		$(DESC_sourceFiles)
!insertmacro MUI_DESCRIPTION_TEXT ${swt}				$(DESC_swt)
!insertmacro MUI_FUNCTION_DESCRIPTION_END



# -----------------------------------------------------------------------------
Function .onInit
	StrCpy $INSTDIR "$PROGRAMFILES32\fantom-${VERSION}\"
	${If} ${RunningX64}
		StrCpy $INSTDIR "$PROGRAMFILES64\fantom-${VERSION}\"
	${EndIf}
	StrCpy $AF_ORIG_INSTDIR $INSTDIR
	
	!insertmacro MULTIUSER_INIT

	# AddSize doesn't work (reports wrong sizes) with the large strings build
	SectionSetSize ${applicationFiles}	7917
	SectionSetSize ${adminTools}		 143
	SectionSetSize ${dotnetRuntime}		 188
	SectionSetSize ${examples}			 122
	SectionSetSize ${sourceFiles} 		9668	
	SectionSetSize ${swt}		 		3900
FunctionEnd

Function un.onInit
	!insertmacro MULTIUSER_UNINIT
FunctionEnd



# -----------------------------------------------------------------------------
Section "Uninstall"
	Delete "$INSTDIR\readme.html"
	Delete "$INSTDIR\readme.md"
	Delete "$INSTDIR\Uninstall.exe"

	RMDir /r /REBOOTOK "$INSTDIR\adm"
	RMDir /r /REBOOTOK "$INSTDIR\bin"
	RMDir /r /REBOOTOK "$INSTDIR\etc"
	RMDir /r /REBOOTOK "$INSTDIR\examples"
	RMDir /r /REBOOTOK "$INSTDIR\lib"
	RMDir /r /REBOOTOK "$INSTDIR\src"

	${If} "$MultiUser.InstallMode" == "AllUsers"
		DeleteRegValue HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" "FAN_HOME"
		${un.EnvVarUpdate} $0 "PATH" 	"R" HKLM "%FAN_HOME%\bin"		
	${Else}
		DeleteRegValue HKCU "Environment" "FAN_HOME"
		${un.EnvVarUpdate} $0 "PATH" 	"R" HKCU "%FAN_HOME%\bin"
	${EndIf}

#	${If} "$MultiUser.InstallMode" == "AllUsers"
#		StrCpy $1 "HKLM"
#	${Else}
#		StrCpy $1 "HKCU"
#	${EndIf}
#
#	${un.EnvVarUpdate} $0 "PATH" 		"R" $1 "%FAN_HOME%\bin"
#	${un.EnvVarUpdate} $0 "FAN_HOME"	"R" $1 "$\"%$INSTDIR$\""

	DeleteRegKey SHCTX "${UNINST_REG_KEY}"
SectionEnd
