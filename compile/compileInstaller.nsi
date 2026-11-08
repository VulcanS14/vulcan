!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "WordFunc.nsh"
!insertmacro VersionCompare

!define MUI_ICON "vulcan.ico"
!define MUI_UNICON "unvulcan.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_LEFT
!define MUI_HEADERIMAGE_BITMAP "vulcanheader.bmp"
!define MUI_HEADERIMAGE_UNBITMAP "unvulcanheader.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "vulcanwizard.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "unvulcanwizard.bmp"
!define MUI_ABORTWARNING

!define PROJECT_REG_UNINSTALL_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\Vulcan"
!define PROJECT_UNINSTALL_EXE "uninstall.exe"

!define NEW_VERSION "1.0.1.0"

Name "Vulcan"
InstallDir "$PROGRAMFILES\Symple\Vulcan"
OutFile "VulcanSetup.exe"

VIProductVersion "1.0.1.0"
VIAddVersionKey "ProductName" "Vulcan 1.0.1"
VIAddVersionKey "Comments" "Vulcan is a powerful Scratch 1.4 modification."
VIAddVersionKey "CompanyName" "Symple Studios"
VIAddVersionKey "LegalTrademarks" "Vulcan and the Vulcan wordmark are owned by Roxanne Lee and Symple Studios, 2026. Scratch is owned and copyrighted by the MIT Media Lab, 2007-2026."
VIAddVersionKey "LegalCopyright" "Vulcan was/is created, owned, and developed by Roxanne Lee, 2026. Additionally, Vulcan is developed with the help of Vulcan contributors."
VIAddVersionKey "FileDescription" "Vulcan is a powerful Scratch 1.4 modification."
VIAddVersionKey "FileVersion" "1.0.1.0"
VIAddVersionKey "ProductVersion" "1.0.1.0"
BrandingText "Vulcan 1.0.1 - Made with NSIS"

!define MUI_WELCOMEPAGE_TEXT "This wizard will guide you through the installation of Vulcan 1.0.1.$\n$\nPlease make sure previous installations of Vulcan are not running before starting the installation process.$\n$\nClick the Next button to continue."
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_COMPONENTS

!define MUI_LICENSEPAGE_CHECKBOX
!define MUI_LICENSEPAGE_CHECKBOX_TEXT "I agree to the terms and conditions detailed in the license above"
!insertmacro MUI_PAGE_LICENSE "licenses.txt"

!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

!define MUI_FINISHPAGE_RUN "$INSTDIR\Vulcan.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Run Vulcan now"
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

!insertmacro MUI_LANGUAGE "English"

XPStyle on

!macro UninstallExisting exitcode uninstcommand
Push `${uninstcommand}`
Call UninstallExisting
Pop ${exitcode}
!macroend
Function UninstallExisting
Exch $1 ; uninstcommand
Push $2 ; Uninstaller
Push $3 ; Len
StrCpy $3 ""
StrCpy $2 $1 1
StrCmp $2 '"' qloop sloop
sloop:
	StrCpy $2 $1 1 $3
	IntOp $3 $3 + 1
	StrCmp $2 "" +2
	StrCmp $2 ' ' 0 sloop
	IntOp $3 $3 - 1
	Goto run
qloop:
	StrCmp $3 "" 0 +2
	StrCpy $1 $1 "" 1 ; Remove initial quote
	IntOp $3 $3 + 1
	StrCpy $2 $1 1 $3
	StrCmp $2 "" +2
	StrCmp $2 '"' 0 qloop
run:
	StrCpy $2 $1 $3 ; Path to uninstaller
	StrCpy $1 161 ; ERROR_BAD_PATHNAME
	GetFullPathName $3 "$2\.." ; $InstDir
	IfFileExists "$2" 0 +4
	ExecWait '"$2" /S _?=$3' $1 ; This assumes the existing uninstaller is a NSIS uninstaller, other uninstallers don't support /S nor _?=
	IntCmp $1 0 "" +2 +2 ; Don't delete the installer if it was aborted
	Delete "$2" ; Delete the uninstaller
	RMDir "$3" ; Try to delete $InstDir
	RMDir "$3\.." ; (Optional) Try to delete the parent of $InstDir
Pop $3
Pop $2
Exch $1 ; exitcode
FunctionEnd

Function .onInit

	; Read the installed version from the Windows Uninstall registry key
    ReadRegStr $0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Vulcan" "DisplayVersion"

    ; Compare the installed version ($0) with the new version
    ${VersionCompare} "$0" "${NEW_VERSION}" $1

    ; If $1 = 0 (Equal) or $1 = 1 (Installed is newer)
    ${If} $1 = 0
    ${OrIf} $1 = 1
        MessageBox MB_ICONSTOP|MB_OK "The version of Vulcan found on your device ($0) is either the same or a newer version of Vulcan as/than the one this installer provides (${NEW_VERSION}). Setup will now close."
        Abort
    ${EndIf}
	
	ReadRegStr $0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Vulcan" "UninstallString"
	${If} $0 != ""
	${AndIf} ${Cmd} `MessageBox MB_YESNO|MB_ICONQUESTION "A previous version of Vulcan was found. Do you want to uninstall that version before installing this one?" /SD IDYES IDYES`
		!insertmacro UninstallExisting $0 $0
		${If} $0 <> 0
			MessageBox MB_YESNO|MB_ICONSTOP "Failed to uninstall, continue anyway?" /SD IDYES IDYES +2
				Abort
		${EndIf}
	${EndIf}
FunctionEnd

!macro VerifyUserIsAdmin
  UserInfo::GetAccountType
  pop $0
  ${If} $0 != "admin" ;Require admin rights on NT4+
	messageBox mb_iconstop "To perform this action, you must have administritive rights."
	setErrorLevel 740 ;ERROR_ELEVATION_REQUIRED
	quit
  ${EndIf}
  !macroend
  
SectionGroup "Vulcan" vulcan
	Section "!Required files" required
		SectionIn RO
		SetOutPath "$INSTDIR\"
	
		WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Vulcan" "DisplayName" "Vulcan"
		WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Vulcan" "DisplayVersion" "1.0.1.0"
		WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Vulcan" "Publisher" "Symple Studios"
		WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Vulcan" "DisplayIcon" "$INSTDIR\Icons\vulcanIcon.ico"
		WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Vulcan" "NoModify" 1
		WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Vulcan" "NoRepair" 1
		WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Vulcan" "UninstallString" '"$INSTDIR\uninstall.exe"'
		WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Vulcan" "QuietUninstallString" '"$INSTDIR\uninstall.exe" /S'
		WriteRegStr HKLM "Software\Classes\.vup" "" "Vulcan Project"
		WriteRegStr HKLM "Software\Classes\Vulcan Project\shell\open\command" "" "$INSTDIR\Vulcan.exe $\"$INSTDIR\Vulcan.image$\" $\"%1$\""
		WriteRegStr HKLM "Software\Classes\.vus" "" "Vulcan Sprite"
		WriteRegStr HKLM "Software\Classes\Vulcan Sprite\shell\open\command" "" "$INSTDIR\Vulcan.exe $\"$INSTDIR\Vulcan.image$\" $\"%1$\""
	
		File /x "Vulcan.changes" /x "SqueakV2.sources" /x "ScratchSkin\*.*" "C:\vulcanRes\vulcanWin\dev\*.*"
		File /r "C:\vulcanRes\vulcanWin\dev\Icons"
	
		CreateDirectory $SMPROGRAMS\Vulcan
		CreateShortcut $SMPROGRAMS\Vulcan\Vulcan.lnk $INSTDIR\Vulcan.exe
	
		WriteUninstaller "$INSTDIR\uninstall.exe"
	SectionEnd
	SectionGroup "Media" media
		Section "Backdrops" backgrounds
			SetOutPath "$INSTDIR\Media\"
			File /r "C:\vulcanRes\vulcanWin\dev\Media\Backgrounds"
		SectionEnd
		Section "Costumes" costumes
			SetOutPath "$INSTDIR\Media\"
			File /r "C:\vulcanRes\vulcanWin\dev\Media\Costumes"
		SectionEnd
		Section "Sounds" sounds
			SetOutPath "$INSTDIR\Media\"
			File /r "C:\vulcanRes\vulcanWin\dev\Media\Sounds"
		SectionEnd
	SectionGroupEnd
	Section "Help files" help
		SetOutPath "$INSTDIR\"
		File /r "C:\vulcanRes\vulcanWin\dev\Help"
	SectionEnd
	Section "Sample Projects" sampprojects
		SetOutPath "$INSTDIR\"
		File /r "C:\vulcanRes\vulcanWin\dev\Projects"
	SectionEnd
SectionGroupEnd

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
	!insertmacro MUI_DESCRIPTION_TEXT ${vulcan} "The Vulcan software itself."
	!insertmacro MUI_DESCRIPTION_TEXT ${required} "Required files and registry keys for Vulcan to function and appear properly on your setting app's application page."
	!insertmacro MUI_DESCRIPTION_TEXT ${help} "Optional help files such as block definitions and manuals."
	!insertmacro MUI_DESCRIPTION_TEXT ${media} "Optional sample media for you to use in your Vulcan projects."
	!insertmacro MUI_DESCRIPTION_TEXT ${backgrounds} "Optional sample backgrounds for you to use in your Vulcan projects."
	!insertmacro MUI_DESCRIPTION_TEXT ${costumes} "Optional sample costumes for you to use in your Vulcan projects."
	!insertmacro MUI_DESCRIPTION_TEXT ${sounds} "Optional sample sounds for you to use in your Vulcan projects."
	!insertmacro MUI_DESCRIPTION_TEXT ${sampprojects} "Optional sample projects for you to 1. study and see how they work; and 2. modify to create your own project."
!insertmacro MUI_FUNCTION_DESCRIPTION_END

function un.onInit		
	# Verify the uninstaller - last chance to back out
	MessageBox MB_OKCANCEL "Are you sure you want to uninstall Vulcan?" IDOK next
		Abort
	next:
	!insertmacro VerifyUserIsAdmin
  functionEnd

Section "Uninstall"
	RMDir /r "$INSTDIR"
	Delete $SMPROGRAMS\Vulcan\Vulcan.lnk
	RMDir $SMPROGRAMS\Vulcan
	IfFileExists $DESKTOP\Vulcan.lnk 0 +2
	Delete $DESKTOP\Vulcan.lnk
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Vulcan"
	DeleteRegKey HKLM "Software\Classes\.vup"
	DeleteRegKey HKLM "Software\Classes\Vulcan Project"
	DeleteRegKey HKLM "Software\Classes\.vus"
	DeleteRegKey HKLM "Software\Classes\Vulcan Sprite"
SectionEnd