#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

;Hotkey for testing.
F1::
{
	IniSettingsEditor("Example", "example-config.ini")
	return
}

;-----------------------------------------------------------------------------------------
;Copy everything below into your v2 AHK. Call "IniSettingsEditor" function to open editor.
;See included example config file to learn more about options.
;-----------------------------------------------------------------------------------------
;#############   Edit ini file settings in a GUI   #############################
;  A function that can be used to edit settings in an ini file within it's own
;  GUI. Just plug this function into your script.
;
;  by Rajat, mod by toralf, v2 rework by AbbieDoobie (including numerous snippets from other guides and projects)
;
;   Tested OS: Windows 11 (V1: Windows XP Pro SP2)
;   AHK_version= 2.0.19 (V1: 1.0.44.09)
;   Language: English
;   Date: 2025-05-02 (V1: 2006-08-23)
;
;   Version: 1.0 (V1: 6)
; changes since 6:
; - rework for ahk v2
; changes since 5:
; - add key type "checkbox" with custom control name
; - added key field options (will only apply in Editor window)
; - whole sections can be set hidden
; - reorganized code in Editor and Creator
; - some fixes and adjustments
; changes since 1.4
; - Creator and Editor GUIs are resizeable (thanks Titan). The shortened Anchor function
;    is added with a long name, to avoid nameing conflicts and avoid dependencies.
; - switched from 1.x version numbers to full integer version numbers
; - requires AHK version 1.0.44.09
; - fixed blinking of description field
; changes since 1.3:
; - added field option "Hidden" (thanks jballi)
; - simplified array naming
; - shorted the code
; changes since 1.2:
; - fixed a bug in the description (thanks jaballi and robiandi)
; changes since 1.1:
; - added statusbar (thanks rajat)
; - fixed a bug in Folder browsing
; changes since 1.0:
; - added default value (thanks rajat)
; - fixed error with DisableGui=1 but OwnedBy=0 (thanks kerry)
; - fixed some typos
;  
; format:
; =======
;   IniSettingsEditor(ProgName, IniFile[, OwnedBy = 0, DisableGui = false, Help = 0])
;
; with
;   ProgName - A string used in the GUI as text to describe the program 
;   IniFile - that ini file name (with path if not in script directory)
;   OwnedBy - GUI object (or id) of the calling GUI, will make the settings GUI owned
;   DisableGui - 1=disables calling GUI during editing of settings
;
; example to call in script:
;   IniSettingsEditor("Hello World", "Settings.ini", MyGui)
;
; Include function with:
;   #Include <IniSettingsEditor>
;
; No global variables needed.
;
; features:
; =========
; - the calling script will wait for the function to end, thus till the settings
;     GUI gets closed. 
; - Gui ID for the settings GUI is not hard coded, first free ID will be used 
; - multiple description lines (comments) for each key and section possible 
; - all characters are allowed in section and key names
; - when settings GUI is started first key in first section is pre-selected and
;     first section is expanded
; - tree branches expand when items get selected and collapse when items get
;     unselected
; - key types besides the default "Text" are supported 
;    + "File" and "Folder", will have a browse button and its functionality 
;    + "Float" and "Integer" with consistency check 
;    + "Hotkey" with its own hotkey control 
;    + "DateTime" with its own datetime control and custom format, default is
;        "dddd MMMM d, yyyy HH:mm:ss tt"
;    + "DropDown" with its own dropdown control, list of choices has to be given
;        list is pipe "|" separated 
;    + "Checkbox" where the name of the checkbox can be customized
; - default value can be specified for each key 
; - keys can be set invisible (hidden) in the tree
; - to each key control additional AHK specific options can be assigned  
;
; format of ini file:
; ===================
;     (optional) descriptions: to help the script's users to work with the settings 
;     add a description line to the ini file following the relevant 'key' or 'section'
;     line, put a semi-colon (starts comment), then the name of the key or section
;     just above it and a space, followed by any descriptive helpful comment you'd
;     like users to see while editing that field. 
;     
;     e.g.
;     [SomeSection]
;     ;somesection This can describe the section. 
;     Somekey=SomeValue 
;     ;somekey Now the descriptive comment can explain this item. 
;     ;somekey More then one line can be used. As many as you like.
;     ;somekey [Type: key type] [format/list] 
;     ;somekey [Default: default key value] 
;     ;somekey [Hidden:] 
;     ;somekey [Options: AHK options that apply to the control] 
;     ;somekey [CheckboxName: Name of the checkbox control] 
;     
;     (optional) key types: To limit the choice and get correct input a key type can
;     be set or each key. Identical to the description start an extra line put a
;     semi-colon (starts comment), then the name of the key with a space, then the
;     string "Type:" with a space followed by the key type. See the above feature
;     list for available key types. Some key types have custom formats or lists,
;     they are written after the key type with a space in-between.
;     
;     (optional) default key value: To allow a easy and quick way back to a 
;     default value, you can specify a value as default. If no default is given,
;     users can go back to the initial key value of that editing session.
;     Format: Identical to the description start an extra line, put a semi-colon
;     (starts comment line), then the name of the key with a space, then the
;     string "Default:" with a space followed by the default value.
;
;     (optional) hide key in tree: To hide a key from the user, a key can be set 
;     hidden.
;     Format: Identical to the description start an extra line, put a semi-colon
;     (starts comment line), then the name of the key with a space, then the
;     string "Hidden:".
;
;     (optional) add additional AHK options to key controls. To limit the input
;     or enforce a special input into the key controls in the GUI, additional 
;     AHK options can be specified for each control.
;     Format: Identical to the description start an extra line, put a semi-colon
;     (starts comment line), then the name of the key with a space, then the
;     string "Options" with a space followed by a list of AHK options for that
;     AHK control (all separated with a space).
;
;     (optional) custom checkbox name: To have a more relavant name then e.g.
;     "status" a custom name for the checkbox key type can be specified.
;     Format: Identical to the description start an extra line, put a semi-colon
;     (starts comment line), then the name of the key with a space, then the
;     string "CheckboxName:" with a space followed by the name of the checkbox.
;
;
; limitations:
; ============
; - ini file has to exist and created manually or with the IniFileCreator script
; - section lines have to start with [ and end with ]. No comments allowed on
;     same line
; - ini file must only contain settings. Scripts can't be used to store setting,
;     since the file is read and interpret as a whole. 
; - code: can't use g-labels for tree or edit fields, since the arrays are not
;     visible outside the function, hence inside the g-label subroutines. 


IniSettingsEditor(ProgName, IniFile, OwnedBy:=0, DisableGui:=False, HelpText:="") {
	IniSettingsEditor.SetDefault := False
    Static pos
    
    SettingsGui := Gui("+Resize")
	SettingsGui.OnEvent("Size", GuiIniSettingsEditorSize)
	SettingsGui.Exit := (GuiObj, Params*) => ( SetTimer(HotUpdater, 0), GuiObj.Destroy(), 0)
	SettingsGui.OnEvent("Close", SettingsGui.Exit)

    ;apply options to settings GUI 
    If OwnedBy {
        SettingsGui.Opt("+ToolWindow +Owner" (OwnedBy is Gui ? OwnedBy.Hwnd : OwnedBy))
        If DisableGui {
            If OwnedBy is Gui
				OwnedBy.Opt("+Disabled")
			Else
				DllCall(A_PtrSize=8 ? "SetWindowLongPtr" : "SetWindowLong", "Ptr", SettingsGui.Hwnd, "Int", -8, "Ptr", OwnedBy, "Ptr")
		}
	} Else {
        DisableGui := False
	}
    
    SettingsGui.Opt("+Resize")
    If OwnedBy
        SettingsGui.Opt("+OwnDialogs")
    ;create GUI (order of the two edit controls is crucial, since ClassNN is order dependent) 
    SB := SettingsGui.Add("Statusbar")
	SB.XYWH := "w"
    TV := SettingsGui.Add("TreeView", "x16 y75 w180 h242 0x400")
	TV.XYWH := "wh"
	ValueControls := Map()
    C := ValueControls["Text"] := SettingsGui.Add("Edit", "x215 y114 w340 h20")
	C.ToolTip := "Value of the key"
	C.XYWH := "x"

    C := SettingsGui.Add("Edit", "x215 y174 w340 h120 ReadOnly vDescription")
	C.ToolTip := "Details about the key"
	C.XYWH := "xh"

    C := SettingsGui.Add("Button", "x250 y335 w70 h30", "E&xit")
	C.OnEvent("Click", ExitSettings)
	C.ToolTip := "Exit the settings editor"
	C.XYWH := "x0.5y"

    C := SettingsGui.Add("Button", "x215 y294", "&Restore")
	C.OnEvent("Click", BtnDefaultValue)
	C.ToolTip := "Restores Value to default (if specified), else restores it to initial value before change"
	C.XYWH := "xy"

    C := ValueControls["BrowseButton"] := SettingsGui.Add("Button", "x505 y88 Hidden", "B&rowse")
	C.OnEvent("Click", BtnBrowseKeyValue)
	C.ToolTip := "Select the file/folder for the key"
	C.XYWH := "x"

    C := (ValueControls["DateTime"] := SettingsGui.Add("DateTime", "x215 y114 w340 h20 Hidden"))
	C.XYWH := "x"
	C.ToolTip := "Date/time of the key"
    C := ValueControls["Hotkey"] := SettingsGui.Add("Hotkey", "x215 y114 w340 h20 Hidden")
	C.ToolTip := "Hotkey of the item"
	C.XYWH := "x"
    C := ValueControls["DropDown"] := SettingsGui.Add("DropDownList", "x215 y114 w340 h120 Hidden")
	C.ToolTip := "Options of the item"
	C.XYWH := "x"
    C := ValueControls["CheckBox"] := SettingsGui.Add("CheckBox", "x215 y114 w340 h20 Hidden")
	C.ToolTip := "Value of the item"
	C.XYWH := "x"
	
    GB := SettingsGui.Add("GroupBox", "x4 y63 w560 h263")
	GB.XYWH := "wh"
    SettingsGui.SetFont("Bold")
    ValueText := SettingsGui.Add("Text", "x215 y93", "Value")
	ValueText.XYWH := "x"
    DescText := SettingsGui.Add("Text", "x215 y154", "Description")
	DescText.XYWH := "x"
    HelpTip := "( All changes are Auto-Saved )"
    if (HelpText != "")
    {
        HelpTip := "( All changes are Auto-Saved - Press F1 for Help )"
        HotIfWinActive(ProgName " Settings")
        Hotkey("F1", ShowHelp)
        Hotkey("F1", "On")
    }
    HelpTipText := SettingsGui.Add("Text", "x45 y48 w480 h20 +Center", HelpTip)
	HelpTipText.XYWH := "w"
    SettingsGui.SetFont("S16 CDefault Bold", "Verdana")
    HeadingText := SettingsGui.Add("Text", "x45 y13 w480 h35 +Center", "Settings for " . ProgName)
	HeadingText.XYWH := "w"
  
	TV_Items := Map(), Def := Map(), Def.Default := "", TV_Items.Default := Def
    ;read data from ini file, build tree and store values and description in maps 
    Loop Read, IniFile
      { 
        CurrLine := A_LoopReadLine
        CurrLineLength := StrLen(CurrLine)
    
        ;blank line 
        If IsSpace(CurrLine)
            Continue

        ;description (comment) line 
        If ( InStr(CurrLine, ";") = 1 ) {
            chk2 := SubStr(CurrLine, 1, (CurrLength ?? 0) + 2)
            Des := SubStr(CurrLine, ((CurrLength ?? 0) + 2)+1)
            ;description of key
            If ( !CurrData["Sec"] AND ";" (CurrKey ?? "") A_Space = chk2) { 
                ;handle key types
                If ( InStr(Des, "Type: ") = 1 ) { 
                    Typ := SubStr(Des, (6)+1)
                    Typ := Typ
                    ;the next line modded to hide the Type: from description
					Des := ""
                    ;Des := ";`n" Des     ;add an extra line to the type definition in the description control
                    
                    ;handle format or list  
                    If (InStr(Typ, "DropDown ") = 1) {
                        Format := SubStr(Typ, (9)+1)
                        CurrData["For"] := Format
                        Typ := "DropDown"
                        Des := ""
                    }Else If (InStr(Typ, "DateTime") = 1) {
                        Format := SubStr(Typ, (9)+1)
                        if IsSpace(Format)
                            Format := "dddd MMMM d, yyyy HH:mm:ss tt"
                        CurrData["For"] := Format
                        Typ := "DateTime"
                        Des := ""
                    }
                    ;set type
                    CurrData["Typ"] := Typ
                ;remember default value
                }Else If ( InStr(Des, "Default: ") = 1 ){ 
                    Def := SubStr(Des, (9)+1)
                    CurrData["Def"] := Def
                ;remember custom options  
                }Else If ( InStr(Des, "Options: ") = 1 ){ 
                    Opt := SubStr(Des, (9)+1)
                    CurrData["Opt"] := Opt
                    Des := ""
                ;remove hidden keys from tree
                }Else If ( InStr(Des, "Hidden:") = 1 ){  
                    TV.Delete(CurrID)
                    Des := ""
                    CurrID := ""
                ;handle checkbox name
                }Else If ( InStr(Des, "CheckboxName: ") = 1 ){  
                    ChkN := SubStr(Des, (14)+1)
                    CurrData["ChkN"] := ChkN
                    Des := ""
                }
                If IsSet(CurrID)
					CurrData["Des"] .= "`n" Des
            ;description of section 
            } Else If ( !!CurrData["Sec"] AND ";" CurrSec A_Space = chk2 ){
                ;remove hidden section from tree
                If ( InStr(Des, "Hidden:") = 1 ){  
                    TV.Delete(CurrID)
                    Des := ""
                    CurrSecID := ""
                  }
                ;set description
                CurrData["Des"] .= "`n" Des
            }
            ;remove leading and trailing whitespaces and new lines
			If IsSet(CurrID)
				CurrData["Des"] := Trim(CurrData["Des"], "`r`n`s`t")
            Continue 
          } 
    
        ;section line 
        If InStr(CurrLine, "[") = 1 And InStr(CurrLine, "]",, -1) = CurrLineLength { 
            ;extract section name
            CurrSec := SubStr(CurrLine, (1)+1)
            CurrSec := SubStr(CurrSec, 1, -1*(1))
            CurrSec := CurrSec
            CurrLength := StrLen(CurrSec)  ;to easily trim name off of following comment lines
            
            ;add to tree
            CurrSecID := TV.Add(CurrSec)
            CurrID := CurrSecID
			CurrData := Map() ; -------------- Init of the current data map --------------
			CurrData.Default := ""
            CurrData["Sec"] := True
			TV_Items[CurrID] := CurrData
            CurrKey := ""
            Continue 
          } 
    
        ;key line 
        Pos := InStr(CurrLine, "=") 
        If ( Pos AND (CurrSecID ?? "") ){ 
            ;extract key name and its value
            CurrKey := SubStr(CurrLine, 1, Pos - 1)
            CurrVal := SubStr(CurrLine, (Pos)+1)
            CurrKey := CurrKey             ;remove whitespaces
            CurrVal := CurrVal
            CurrLength := StrLen(CurrKey)
            
            ;add to tree and store value
            CurrID := TV.Add(CurrKey, (CurrSecID ?? ""))
			CurrData := Map() ; -------------- Init of the current data map --------------
			CurrData.Default := ""
            CurrData["Val"] := CurrVal
            CurrData["Sec"] := False
			TV_Items[CurrID] := CurrData
            
            ;store initial value as default for restore function
            ;will be overwritten if default is specified later on comment line
            CurrData["Def"] := CurrVal
          } 
      } 
  
    ;select first key of first section and expand section
    TV.Modify(TV.GetChild(TV.GetNext()), "Select")
  
    ;show Gui and get UniqueID
    SettingsGui.Title := ProgName . " Settings"
	HotUpdater()
    SettingsGui.Show("w570 h400")
    SettingsGui.Opt("+LastFound")

    ;check for changes in GUI and save to INI
	SetTimer HotUpdater, 100
    HotUpdater() {
		Static LastID := 0, ControlUsed := "", ValChanged := false
        ;get current tree selection
        CurrID := TV.GetSelection()
		
		CurrData := TV_Items[CurrID]
	
        
        If IniSettingsEditor.SetDefault {
            CurrData["Val"] := CurrData["Def"]
            LastID := 0
            IniSettingsEditor.SetDefault := False
            ValChanged := True
          } 

        MouseGetPos , , &AWinID, &ACtrlID, 2
        If (AWinID = SettingsGui.Hwnd && IsNumber(ACtrlID)) {
			Control := GuiCtrlFromHwnd(ACtrlID)
			If (Control is Gui.Control AND Control.HasProp("Tooltip"))
				SB.SetText(Control.Tooltip)
			Else
				SB.SetText("")
        } Else
            SB.SetText("")

        ;change GUI content if tree selection changed 
        If (CurrID != LastID) {
            ;remove custom options from last control
            Loop Parse, InvertedOptions ?? "", A_Space
                ValueControls[ControlUsed].%A_Loopfield%()
			
			Typ := CurrData["Typ"]
			If Typ = ""
				Typ := "Text"
			ControlUsed := Typ

            ;set the needed value control depending on key type
            If (Typ = "DateTime")
                ControlUsed := "DateTime"
            Else If ( Typ = "Hotkey" )
                ControlUsed := "Hotkey"
            Else If ( Typ = "DropDown")
                ControlUsed := "DropDown"
            Else If ( Typ = "CheckBox")
                ControlUsed := "CheckBox"
            Else ;e.g. Text,File,Folder,Float,Integer or No Tyo (e.g. Section) 
                ControlUsed := "Text"

            ;hide/show the value controls
            ;Controls := "SysDateTimePick321,msctls_hotkey321,ComboBox1,Button4,Edit1"
            For Name, Control in ValueControls
				Control.Visible := Name = ControlUsed

			;hide/show browse button depending on key type
			If (Typ = "File" || Typ = "Folder") {
				ValueControls["BrowseButton"].Visible := True
				ValueControls["BrowseButton"].Enabled := True
			} Else {
				ValueControls["BrowseButton"].Visible := False
				ValueControls["BrowseButton"].Enabled := False
			}

            If ControlUsed = "CheckBox"
                ValueControls["CheckBox"].Text := CurrData["ChkN"]

            ;get current options
            CurrOpt := CurrData["Opt"]
            ;apply current custom options to current control and memorize them inverted
            InvertedOptions := ""
            Loop Parse, CurrOpt, A_Space
              {
                ;get actual option name
                chk := SubStr(A_LoopField, 1, 1)
                chk2 := SubStr(A_LoopField, (1)+1)
                if (chk ~= "^(?i:\+|-)$")
                  {
                    ValueControls[ControlUsed].%A_LoopField%()
                    If (chk = "+")
                        InvertedOptions := InvertedOptions . " -" . chk2
                    Else
                        InvertedOptions := InvertedOptions . " +" . chk2
                }Else {
                    ValueControls[ControlUsed].Opt("+" A_LoopField)
                    InvertedOptions := InvertedOptions . " -" . A_LoopField
                  }
              }

            If !!CurrData["Sec"] {                      ;section got selected
                CurrVal := ""
                ValueControls["Text"].Value := ""
                ValueControls["Text"].Enabled := false
            } Else {                               ;new key got selected
                CurrVal := CurrData["Val"]   ;get current value
				Switch ControlUsed {
					Case "DateTime":
						ValueControls["DateTime"].Value := ""
						ValueControls["DateTime"].SetFormat(CurrData["For"])
						ValueControls["DateTime"].Value := CurrVal
					Case "Hotkey":
						ValueControls["Hotkey"].Value := CurrVal
					Case "DropDown":
						ValueControls["DropDown"].Delete()
						ValueControls["DropDown"].Add(StrSplit(CurrData["For"], "|"))
						ValueControls["DropDown"].Choose(CurrVal)
					Case "CheckBox":
						ValueControls["CheckBox"].Value := CurrVal
					Default:
						ValueControls["Text"].Enabled := true
						ValueControls["Text"].Value := CurrVal
				}
			 }
			SettingsGui["Description"].Value := CurrData["Des"] 
          }
        LastID := CurrID                   ;remember last selection
		;ToolTip ValueControls["BrowseButton"].visible

        ;if key is selected (not section), get value
        If (!CurrData["Sec"]) {
            Control := ValueControls[ControlUsed]
            If Control is Gui.List
				NewVal := Control.Text
			Else
				NewVal := Control.Value
            ;save key value when it has been changed 
            If ( NewVal != CurrVal OR ValChanged ) {
                ValChanged := False
                
                ;consistency check if type is integer or float
                If (Typ = "Integer")
                  if !IsSpace(NewVal)
                    if !isInteger(NewVal)
                      {
                        ValueControls["Text"].Value := CurrVal
                        Return
                      }
                If (Typ = "Float")
                  if !IsSpace(NewVal)
                    if !isInteger(NewVal)
                      If (NewVal != ".")
                        if !isFloat(NewVal)
                          {
                            ValueControls["Text"].Value := CurrVal
                            Return
                          }
                
                ;set new value and save it to INI      
                CurrData["Val"] := NewVal 
                CurrVal := NewVal
                PrntID := TV.GetParent(CurrID)
                SelSec := TV.GetText(PrntID) 
                SelKey := TV.GetText(CurrID) 
                If (SelSec AND SelKey) 
                    IniWrite(NewVal, IniFile, SelSec, SelKey)
              } 
          } 
      } 

    ;Exit button got pressed 
    ExitSettings(*) 
	{
		If DisableGui {
			SettingsGui.Opt("-Disabled")
			SettingsGui.Show()
		}
		SettingsGui.Exit()
		If (HelpText != "")
			Hotkey("F1", "Off")
	}
    
    ;browse button got pressed
    BtnBrowseKeyValue(A_GuiEvent := "", GuiCtrlObj := "", Info := "", *) 
    ;get current value
	{
      StartVal := ValueControls["Text"].Value
      SettingsGui.Opt("+OwnDialogs")
      
      ;Select file or folder depending on key type
      If (Typ = "File"){ 
          ;get StartFolder
          if FileExist(A_ScriptDir "\" StartVal)
              StartFolder := A_ScriptDir
          Else If FileExist(StartVal)
              SplitPath(StartVal, , &StartFolder)
          Else 
              StartFolder := ""

          ;select file
          Selected := FileSelect("", StartFolder, "Select file for " (SelSec ?? "") " - " (SelKey ?? ""), "Any file (*.*)")
      }Else If (Typ = "Folder"){ 
          ;get StartFolder
          if FileExist(A_ScriptDir "\" StartVal)
              StartFolder := A_ScriptDir . "\" . StartVal
          Else           if FileExist(StartVal)
              StartFolder := StartVal
          Else 
              StartFolder := ""
          
          ;select folder
          Selected := SelectFolderEx("*" StartFolder, "Select folder for " (SelSec ?? "") " - " (SelKey ?? ""), SettingsGui.Hwnd)
          
          ;remove last backslash "\" if any
          LastChar := SubStr(Selected, -1*(1))
          if (LastChar = "\")
               Selected := SubStr(Selected, 1, -1*(1))
        } 
      ;If file or folder got selected, remove A_ScriptDir (since it's redundant) and set it into GUI
      If Selected { 
          Selected := StrReplace(Selected, A_ScriptDir "\",,,, 1)
          ValueControls["Text"].Value := Selected
          CurrData["Val"] := Selected 
        } 
    Return  ;end of browse button subroutine
	}

    ;default button got pressed
    BtnDefaultValue(*)
	{
		IniSettingsEditor.SetDefault := True
    }
    
    ;gui got resized, adjust control sizes
    GuiIniSettingsEditorSize(*) {
      For , Control in SettingsGui {
		If !Control.HasProp("XYWH")
			Continue
		AutoXYWH(Control.XYWH, Control)
		Control.Redraw()
	  }
	}

    ShowHelp(*) {
        SettingsGui.Opt("+OwnDialogs")
        MsgBox(HelpText, ProgName " Settings Help", 64)
    }

}  ;end of function

AutoXYWH(DimSize, cList*) {
	Static cInfo := Map()
	If DimSize = 'reset'
		Return cInfo := Map()
	For Ctrl in cList
	{
		Ctrl.Gui.GetPos(,, &gw, &gh)
		If !cInfo.Has(Ctrl)
		{
			Ctrl.GetPos(&x, &y, &w, &h)
			fx := fy := fw := fh := 0
			For dim in StrSplit(RegExReplace(DimSize, 'i)[^xywh]'))
				f%dim% := RegExMatch(DimSize, 'i)' dim '\s*\K[\d.-]+', &m) ? m[] : 1
			If InStr(DimSize, 't')
			{
				Hwnd := DllCall('GetParent', 'Ptr', Ctrl.Hwnd, 'Ptr')
				DllCall('GetWindowRect', 'Ptr', Hwnd, 'Ptr', RECT := Buffer(16, 0))
				DllCall('MapWindowPoints', 'Ptr', 0, 'Ptr', DllCall('GetParent', 'Ptr', Hwnd, 'Ptr'), 'Ptr', RECT, 'UInt', 2)
				x -= NumGet(RECT, 'Int') * 96 // A_ScreenDPI
				y -= NumGet(RECT, 4, 'Int') * 96 // A_ScreenDPI
			}
			cInfo[Ctrl] := Map('x', x, 'fx', fx, 'y', y, 'fy', fy, 'w', w, 'fw', fw, 'h', h, 'fh', fh, 'gw', gw, 'gh', gh, 'm', !!InStr(DimSize, '*'))
		}
		Else
		{
			dgw := gw - cInfo[Ctrl]['gw'], dgh := gh - cInfo[Ctrl]['gh']
			Ctrl.Move(cInfo[Ctrl]['fx'] ? dgw * cInfo[Ctrl]['fx'] + cInfo[Ctrl]['x'] : unset
				, cInfo[Ctrl]['fy'] ? dgh * cInfo[Ctrl]['fy'] + cInfo[Ctrl]['y'] : unset
				, cInfo[Ctrl]['fw'] ? dgw * cInfo[Ctrl]['fw'] + cInfo[Ctrl]['w'] : unset
				, cInfo[Ctrl]['fh'] ? dgh * cInfo[Ctrl]['fh'] + cInfo[Ctrl]['h'] : unset)
			If cInfo[Ctrl]['m']
				Ctrl.Redraw()
		}
	}
}

SelectFolderEx(startingFolder?, prompt?, ownerHwnd := 0, okBtnLabel?) {
    static CLSID_FileOpenDialog := '{DC1C5A9C-E88A-4DDE-A5A1-60F82A20AEF7}'
         , IID_IFileDialog      := '{42F85136-DB7E-439C-85F1-E4075D135FC8}'
         , IID_IShellItem       := '{43826D1E-E718-42EE-BC55-A1E261C37BFE}'
         , FILEOPENDIALOGOPTIONS := (FOS_CREATEPROMPT := 0x2000) | (FOS_PICKFOLDERS := 0x0020) | (FOS_NOCHANGEDIR := 0x0008)
         , _ := ({}.DefineProp)(ComValue.Prototype, '__Call', { Call: (s, n, p) => (p.InsertAt(2, s), ComCall(p*)) })
         , cv := ObjBindMethod(ComValue, 'Call', VT_UNKNOWN := 13), SIGDN_DESKTOPABSOLUTEPARSING := 0x80028000

    IFileDialog := ComObject(CLSID_FileOpenDialog, IID_IFileDialog)
    IFileDialog.SetOptions(9, 'UInt', FILEOPENDIALOGOPTIONS)
    if IsSet(startingFolder) {
        DllCall('Ole32\IIDFromString', 'Str', IID_IShellItem, 'Ptr', riid := Buffer(16))
        hr := DllCall('Shell32\SHCreateItemFromParsingName', 'Str', startingFolder, 'Ptr', 0, 'Ptr', riid, 'Ptr*', IShellItem := cv(0))
        if (hr = 0) {
            IFileDialog.SetFolder(12, 'Ptr', IShellItem)
        }
    }
    IsSet(prompt)     && IFileDialog.SetTitle(17, 'Str', prompt)
    IsSet(okBtnLabel) && IFileDialog.SetOkButtonLabel(18, 'Str', okBtnLabel)
    try IFileDialog.Show(3, 'Ptr', ownerHwnd)
    catch {
        return ''
    }
    IFileDialog.GetResult(20, 'Ptr*', IShellItem := cv(0))
    IShellItem.GetDisplayName(5, 'UInt', SIGDN_DESKTOPABSOLUTEPARSING, 'Ptr*', &pszName := 0)
    selectedFolderPath := StrGet(pszName)
    DllCall('Ole32\CoTaskMemFree', 'Ptr', pszName)
    return selectedFolderPath
}