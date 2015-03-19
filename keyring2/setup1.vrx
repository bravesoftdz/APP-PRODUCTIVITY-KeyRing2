/*:VRX         Main
*/
/*  Main
~nokeywords~
*/
Main:
/*  Process the arguments.
    Get the parent window.
*/
    PARSE SOURCE . Calledas .
    Parent = ""
    Argcount = ARG()
    Argoff = 0
    IF( Calledas \= "COMMAND" )THEN DO
        IF Argcount >= 1 THEN DO
            Parent = ARG(1)
            Argcount = Argcount - 1
            Argoff = 1
        END
    END
        ELSE DO
            CALL Vroptions 'ImplicitNames'
            CALL Vroptions 'NoEchoQuit'
        END
    Initargs.0 = Argcount
    IF( Argcount > 0 )THEN DO I = 1 TO Argcount
        Initargs.i = ARG( I + Argoff )
    END
    DROP Calledas Argcount Argoff

/*  Load the windows
*/
    CALL Vrinit
    PARSE SOURCE . . Spec
    _vreprimarywindowpath = ,
        Vrparsefilename( Spec, "dpn" ) || ".VRW"
    _vreprimarywindow = ,
        Vrload( Parent, _vreprimarywindowpath )
    DROP Parent Spec
    IF( _vreprimarywindow == "" )THEN DO
        CALL Vrmessage "", "Cannot load window:" Vrerror(), ,
            "Error!"
        _vrereturnvalue = 32000
        SIGNAL _vreleavemain
    END

/*  Process events
*/
    CALL Init
    SIGNAL ON HALT
    DO While( \ Vrget( _vreprimarywindow, "Shutdown" ) )
        _vreevent = Vrevent()
        INTERPRET _vreevent
    END
_vrehalt:
    _vrereturnvalue = Fini()
    CALL Vrdestroy _vreprimarywindow
_vreleavemain:
    CALL Vrfini
    EXIT _vrereturnvalue

Vrloadsecondary:
    __vrlswait = ABBREV( 'WAIT', TRANSLATE(ARG(2)), 1 )
    IF __vrlswait THEN DO
        CALL Vrflush
    END
    __vrlshwnd = Vrload( Vrwindow(), Vrwindowpath(), ARG(1) )
    IF __vrlshwnd = '' THEN SIGNAL __vrlsdone
    IF __vrlswait \= 1 THEN SIGNAL __vrlsdone
    CALL Vrset __vrlshwnd, 'WindowMode', 'Modal'
    __vrlstmp = __vrlswindows.0
    IF( DATATYPE(__vrlstmp) \= 'NUM' ) THEN DO
        __vrlstmp = 1
    END
        ELSE DO
            __vrlstmp = __vrlstmp + 1
        END
    __vrlswindows.__vrlstmp = Vrwindow( __vrlshwnd )
    __vrlswindows.0 = __vrlstmp
    DO While( Vrisvalidobject( Vrwindow() ) = 1 )
        __vrlsevent = Vrevent()
        INTERPRET __vrlsevent
    END
    __vrlstmp = __vrlswindows.0
    __vrlswindows.0 = __vrlstmp - 1
    CALL Vrwindow __vrlswindows.__vrlstmp
    __vrlshwnd = ''
__vrlsdone:
RETURN __vrlshwnd

/*:VRX         __VXREXX____APPENDS__
*/
__VXREXX____APPENDS__:
/*
*/
return
/*:VRX         AppPageName_ContextMenu
*/
Apppagename_contextmenu:
    CALL Setpghint(2)
RETURN

/*:VRX         BrowserNameField_ContextMenu
*/
Browsernamefield_contextmenu:
    CALL Browsersearchbutton_click
RETURN

/*:VRX         BrowserSearchButton_Click
*/
Browsersearchbutton_click:
    Filename = Vrfiledialog( Vrwindow(), Vlsmsg(277) /* Browser EXE */, "Open", "*.EXE", , , )
    Ok = Vrset( "BrowserNameField", "Value", Filename )
RETURN

/*:VRX         ComboPageName_ContextMenu
*/
Combopagename_contextmenu:
    CALL Setpghint(4)
RETURN

/*:VRX         CustomFontCB_Click
*/
Customfontcb_click:
    Ok = Vrsetini( Appname, Vrget(Vrinfo("Object"), "Name"), Vrget(Vrget(Vrinfo("Object"), "Name"), "Set"), Ininame )
RETURN

/*:VRX         DB1_Click
*/
Db1_click:
    CALL Downclick(1)

RETURN

/*:VRX         DB2_Click
*/
Db2_click:
    CALL Downclick(2)

RETURN

/*:VRX         DB3_Click
*/
Db3_click:
    CALL Downclick(3)

RETURN

/*:VRX         DB4_Click
*/
Db4_click:
    CALL Downclick(4)

RETURN

/*:VRX         DB5_Click
*/
Db5_click:
    CALL Downclick(5)

RETURN

/*:VRX         DB6_Click
*/
Db6_click:
    CALL Downclick(6)

RETURN

/*:VRX         DefaultFieldName_Click
*/
DefaultFieldName_Click: 
    Src = Vrinfo("Source")
    S = Vrget( Src, "Selected" )
    if s = 0 then do
        Buttons.1 = Vlsmsg(124)                                    /* ~Ok */
        Buttons.0 = 1
        id = VRMessage( VRWindow(), VLSMsg(328) /* No item selected for reverting */, VLSMsg(120) /* Warning! */, "Warning", "Buttons.", 1, 1 )
        return        
    end

    Ok = Vrmethod( Src, "GetStringList", "AllStrings." )
    Ok = Vrmethod( Src, "GetItemDataList", "Alldata." )

    PARSE VAR Alldata.s E "�" Flag "�" Curhint
    SELECT
        WHEN Flag = "I" THEN DO
            Value = VLSMsg(99)
        END
        WHEN Flag = "D" THEN DO
            Value = VLSMsg(100)
        END
        WHEN Flag = "N" THEN DO
            Value = VLSMsg(101)
        END
        WHEN Flag = "P" THEN DO
            Value = VLSMsg(102)
        END
        WHEN Flag = "S" THEN DO
            Value = VLSMsg(103)
        END
        WHEN Flag = "L" THEN DO
            Value = VLSMsg(104)
        END
        WHEN Flag = "E" THEN DO
            Value = VLSMsg(105)
        END
        WHEN Flag = "U" THEN DO
            Value = VLSMsg(106)
        END
        WHEN Flag = "W" THEN DO
            Value = VLSMsg(107)
        END
    END

    N = Getdefaultflagindex(Flag)
    /* look up the hint for the natural index */    H = Getdefaulthinttext(N)
    /* rebuild the flag with a new hint, enabled, old flag */
    Columndata.j = "1�" || Flag || "�" || H
    /* set default column name based on order flag */
    Columnnames.j = "+" || Value

    Ok = Vrmethod(Src, "Reset" )
    Ok = Vrmethod(Src, "AddStringList", "ColumnNames.", 1 )
    Ok = Vrmethod(Src, "SetItemDataList", "ColumnData." )
return

/*:VRX         DownClick
*/
Downclick:
    Col = "LB" || ARG(1)
    
    S = Vrget( Col, "Selected" )
    if S = 0 THEN DO 
        Ok = BEEP( 2000, 500 )
        RETURN
    END

    IF S < 9 THEN DO
        Ok = Vrmethod( Col, "GetStringList", Allnames. )
        Ok = Vrmethod( Col, "GetItemDataList", Alldata. )

        N = S + 1

        Tempname = Allnames.n
        Tempdata = Alldata.n

        Allnames.n = Allnames.s
        Alldata.n = Alldata.s

        Allnames.s = Tempname
        Alldata.s = Tempdata

        Ok = Vrmethod( Col, "Reset" )
        Ok = Vrmethod( Col, "AddStringList", Allnames., 1, Alldata. )
        Ok = Vrset( Col, "Selected", N )
    END
    ELSE DO
        Ok = BEEP( 2000, 500 )
    END
RETURN

/*:VRX         EditColName
*/
Editcolname: PROCEDURE
    N = ARG(1)
    List = "LB" || N
    Ok = Vrmethod( List, "GetStringList", "AllStrings." )
    Ok = Vrmethod( List, "GetItemDataList", "Alldata." )
    S = Vrget( List, "Selected" )

    Buttons.1 = Vlsmsg(124)                                    /* ~Ok */
    Buttons.2 = Vlsmsg(218)                                 /* Cancel */
    Buttons.0 = 2
    Value = SUBSTR(Allstrings.s,2)
    Vset = SUBSTR(Allstrings.s, 1,1)

    PARSE VAR Alldata.s E "�" Flag "�" Curhint "�" CurSlide

    SELECT
        WHEN Flag = "P" THEN DO
            Prompt = Vlsmsg(314)                          /* Password */
        END
        WHEN Flag = "I" THEN DO
            Prompt = Vlsmsg(315)                              /* Icon */
        END
        WHEN Flag = "E" THEN DO
            Prompt = Vlsmsg(316)                   /* Expiration Date */
        END
        WHEN Flag = "L" THEN DO
            Prompt = Vlsmsg(317)                       /* Last Update */
        END
        WHEN Flag = "U" THEN DO
            Prompt = Vlsmsg(318)                               /* URL */
        END
        OTHERWISE DO
            Prompt = ""
        END
    END

    Id = Vrprompt( Vrwindow(), Vlsmsg(319) /* Edit the column name */, "Value", Prompt || Vlsmsg(320) /* Column Name */, "Buttons.", 1, 2 )
    IF Id = 1 THEN DO
        Allstrings.s = Vset||Value
        Ok = Vrmethod( List, "Reset" )
        Ok = Vrmethod( List, "AddStringList", "AllStrings.", 1 )
        IF Prompt <> "" THEN DO
            P = Vlsmsg(321) /* Hint for  */ || Prompt
        END
        ELSE DO
            P = Vlsmsg(322) /* Hint */
        END
        Id = Vrprompt( Vrwindow(), Vlsmsg(323) /* Edit the column hint */, "CurHint", P, "Buttons.", 1, 2 )
        IF Id = 1 THEN DO
            PARSE VAR Alldata.s E "�" Flag "�" Oldhint "�" OldSlide
            Alldata.s = E || "�" || Flag || "�" || Curhint "�" OldSlide
        END

    Value = SUBSTR(Allstrings.s,2)
    SELECT
        WHEN Flag = "D" THEN DO
            APrompt = Value
        END
        WHEN Flag = "L" THEN DO
            APrompt = Value
        END
        WHEN Flag = "N" THEN DO
            APrompt = Value
        END
        WHEN Flag = "S" THEN DO
            APrompt = Value
        END
        WHEN Flag = "P" THEN DO
            APrompt = Value
        END
        WHEN Flag = "I" THEN DO
            APrompt = Value
        END
        OTHERWISE DO
            APrompt = ""
        END
    END
/*
        if Aprompt <> "" THEN DO
            do forever
                Id = Vrprompt( Vrwindow(), Vlsmsg(385) /* Edit the Sort Slider abbreviation for  */ || APrompt, "CurSlide", P, "Buttons.", 1, 2 )
                if Id = 2 then do 
                    leave
                end
                if length(CurSlide) > 4 then do
                    id = VRMessage( VRWindow(), Vlsmsg(386) /* Maximum sort abbreviation length is 4 characters! */, "Warning", "Warning", "Buttons.", 1, 2 )
                    if id = 2 then do
                        leave
                    end
                end
                else do 
                    leave
                end
            end

            IF Id = 1 THEN DO
                PARSE VAR Alldata.s E "�" Flag "�" Oldhint "�" OldSlide
                Alldata.s = E || "�" || Flag || "�" || Oldhint || "�" || CurSlide
            END
        end;
*/
        Ok = Vrmethod( List, "SetItemDataList", "AllData.")
    END
RETURN

/*:VRX         EF_1_ContextMenu
*/
EF_1_ContextMenu: 

    Types.1 = "MIDI"
    Types.2 = "WAV"
    Types.3 = "VOC"
    Types.4 = "_AU"
    Types.5 = "AU"
    Types.6 = "AIF"
    Types.7 = "SND"
    Types.0 = 7

    FileName = VRGetIni(AppName, "SoundFile", IniName)
    FileName = VRFileDialog( VRWindow(), VLSMsg(364) /* Select a multimedia file to play at startup */, "Open", Filename, , , "Types." )
    ok = VRSet( "EF_1", "Value", Filename )
    if Filename <> "" then do
        Ok = VRSetIni(AppName, "SoundFile", Filename, IniName)
        Ok = KRKillIntro()
        Ok = KRPlayIntro(Filename)
    end
    else do
        ok = VRSet( "SoundEnable", "Set", 0 )
    end
    drop types.
return


/*:VRX         ExitButton_Click
*/
Exitbutton_click:
    CALL Quit
RETURN

/*:VRX         Fini
*/
Fini:
    Window = Vrwindow()
    CALL Vrset Window, "Visible", 0
    DROP Window
RETURN 0

/*:VRX         GetDefaultFlagIndex
*/
Getdefaultflagindex: PROCEDURE EXPOSE Defflgs.
    /* return the index of this flag, using the default (natural) order */
    Flag = ARG(1)
    DO Inx = 1 TO 9
        IF Flag = Defflgs.inx THEN DO
            RETURN Inx
        END
    END
RETURN 0

/*:VRX         GetDefaultHintText
*/
Getdefaulthinttext: PROCEDURE
    Indx = ARG(1)
    SELECT
        WHEN Indx = 1 THEN DO
            RETURN Vlsmsg(157)/* Drop an icon here, or right click for options */
        END
        WHEN Indx = 2 THEN DO
            RETURN Vlsmsg(142)     /* Description of this secret info */
        END
        WHEN Indx = 3 THEN DO
            RETURN Vlsmsg(144)   /* Your name, alias, login name, Etc */
        END
        WHEN Indx = 4 THEN DO
            RETURN Vlsmsg(148)/* Password for this application, web page, login, Etc. */
        END
        WHEN Indx = 5 THEN DO
            RETURN Vlsmsg(146)/* Serial number, combination, PIN number, Etc for this secret */
        END
        WHEN Indx = 6 THEN DO
            RETURN ""                                 /* <lastupdate> */
        END
        WHEN Indx = 7 THEN DO
            RETURN Vlsmsg(154)/* Days to password expiration (warning only) */
        END
        WHEN Indx = 8 THEN DO
            RETURN Vlsmsg(151)                 /* URL for this secret */
        END
        WHEN Indx = 9 THEN DO
            RETURN Vlsmsg(152)                /* Note for this secret */
        END
        OTHERWISE DO
            RETURN "YYYY"                  /* <should never get here> */
        END
    END
RETURN

/*:VRX         GetPageHint
*/
Getpagehint:
    Value = Krgetpagehint(ARG(2))
    IF Value = "" THEN DO
        Value = Vlsmsg(ARG(1))
    END
RETURN Value

/*:VRX         Halt
*/
Halt:
    SIGNAL _vrehalt
RETURN

/*:VRX         HideClick
*/
Hideclick:
    Col = "LB" || ARG(1)
    S = Vrget( Col, "Selected" )
    IF S = 0 THEN DO
        Ok = BEEP( 2000, 500 )
        RETURN
    END

    Ok = Vrmethod( Col, "GetStringList", Allnames. )
    Ok = Vrmethod( Col, "GetItemDataList", Alldata. )

    PARSE VAR Alldata.s Enb "�" Flag
    IF Enb <> 1 THEN DO
        Enb = 1
    END
        ELSE DO
            Enb = 0
        END

    String = SUBSTR(Allnames.s, 2)
    IF Enb = 0 THEN DO
        String = "-" || String
    END
        ELSE DO
            String = "+" || String
        END

    Allnames.s = String
    Alldata.s = Enb || "�" || Flag

    Ok = Vrmethod( Col, "Reset" )
    Ok = Vrmethod( Col, "AddStringList", Allnames., 1, Alldata. )
    IF S < 9 THEN DO
        Ok = Vrset( Col, "Selected", S+1 )
    END
        ELSE DO
            Ok = Vrset( Col, "Selected", 1 )
        END
RETURN

/*:VRX         HS1_Click
*/
Hs1_click:
    CALL Hideclick(1)
RETURN

/*:VRX         HS2_Click
*/
Hs2_click:
    CALL Hideclick(2)

RETURN

/*:VRX         HS3_Click
*/
Hs3_click:
    CALL Hideclick(3)

RETURN

/*:VRX         HS4_Click
*/
Hs4_click:
    CALL Hideclick(4)

RETURN

/*:VRX         HS5_Click
*/
Hs5_click:
    CALL Hideclick(5)

RETURN

/*:VRX         HS6_Click
*/
Hs6_click:
    CALL Hideclick(6)

RETURN

/*:VRX         Init
*/
Init:
    Ok = RXFUNCADD("VLLoadFuncs", "VLMSG", "VLLoadFuncs")/* do not modify or move this line! It must be on line #2 of this function */
    CALL Vlloadfuncs/* do not modify or move this line! It must be on line #3 of this function */

    Ok = Vrredirectstdio("On", "keyring2.err")
    Appname = Initargs.1
    Ininame = Initargs.2

    /* NB page prefixes for containers */
    Contnames.1 = "WWW"
    Contnames.2 = "App"
    Contnames.3 = "PIN"
    Contnames.4 = "Combo"
    Contnames.5 = "Other1"
    Contnames.6 = "Other2"
    Contnames.0 = 6

    /* NB Page names for columns */
    Colnames.1 = "Icon"
    Colnames.2 = "Desc"
    Colnames.3 = "Password"
    Colnames.4 = "Userid"
    Colnames.5 = "SN"
    Colnames.6 = "LastUpdate"
    Colnames.7 = "ExpDate"
    Colnames.8 = "URL"
    Colnames.9 = "Note"

    /* flags in default order */
    Defflgs.1 = "I"
    Defflgs.2 = "D"
    Defflgs.3 = "N"
    Defflgs.4 = "P"
    Defflgs.5 = "S"
    Defflgs.6 = "L"
    Defflgs.7 = "E"
    Defflgs.8 = "U"
    Defflgs.9 = "W"
    Defflgs.10 = "O"

    DO I = 1 TO 6
        Pghint.i = Getpagehint(277+I, I)
    END

    Langname = Vrgetini( Appname, "LANGUAGE", Ininame )
    IF Langname = "" THEN DO
        Langname = "ENGLISH.MSG"
    END
    Ok = Vlopenlang(Langname, Langname)

    /* set window location */
    Value = Vrgetini( Appname, "SETUPTOP", Ininame )
    IF Value = "" THEN do
        Value = 964
    end
    Setuptop = Value

    Value = Vrgetini( Appname, "SETUPLEFT", Ininame )
    IF Value = "" THEN do
        Value =145
    end
    Setupleft = Value

    Value = Vrgetini( Appname, "SETUPHYT", Ininame )
    IF Value = "" THEN do
        Value = 5300
    end
    Setuphyt = Value

    Value = Vrgetini( Appname, "SETUPWID", Ininame )
    IF Value = "" THEN do
        Value = 9118
    end
    Setupwidth = Value

    Ok = Vrset( "SETUP1", "Top", Setuptop )
    Ok = Vrset( "SETUP1", "Left", Setupleft )
    Ok = Vrset( "SETUP1", "Height", Setuphyt )
    Ok = Vrset( "SETUP1", "Width", Setupwidth )

    DO I = 1 TO 6
        Value = Krgetpagename(I)
        IF Value = "" THEN DO
            Value = Vlsmsg(240+I)
        END
        Ok = Vrset( Contnames.i || "PageName", "Value", Value )

        DO J = 1 TO 9
            Value = Krgetcolumnname(I, J)
            IF Value = "" THEN DO
                Value = Vlsmsg(98+J)              /* use default name */
            END
            Colenb = Krgetcolumnenable(I, J)
            PARSE VAR Colenb Enb "�" Flag "�" Hint "�" Abbrev
            Columndata.j = Colenb

            IF Enb = 1 THEN DO
                Columnnames.j = "+" || Value
            END
                ELSE DO
                    Columnnames.j = "-" || Value
                END
        END
        Columnnames.0 = 9
        Columndata.0 = 9

        Obj = "LB" || I
        Ok = Vrmethod( Obj, "Reset" )
        Ok = Vrmethod( Obj, "AddStringList", Columnnames., 1, Columndata.)
    END

    Ok = Vrset( "BrowserNameField", "Value", Vrgetini( Appname, "BrowserApp", Ininame) )
    Ok = Vrset("CustomFontCB","Set", Vrgetini(Appname, "CustomFontCB", Ininame))
    I = Vrgetini( Appname, "BackupGenerationSpinner", Ininame )
    Ok = Vrset( "BackupGenerationSpinner", "Value", I )
    Value = Vrgetini( Appname, "SoundEnable", Ininame)
    IF Value = "" then
        Value = 1
    Ok = Vrset( "SoundEnable", "Set", Value )
    ok = VRSet( "EF_1", "Value", VRGetIni(AppName, "SoundFile", IniName) )
    

    CALL Normalmouse
    DROP X Ok Child I J
    CALL Setup1_langinit

    /* ~Use defaults */
    Ok = VRSet("DummyText", "Caption", VLSMsg(310))

    Window = Vrwindow()
    CALL Vrset Window, "Visible", 1
    CALL Vrmethod Window, "Activate"

    ButtonWidth = VRGet( "DummyText", "Width" )

    BoxWidth = VRGet("SETUP1", "Width")
    ok = VRSet( "UseDefaultsButton", "Left", (BoxWidth-ButtonWidth)-200)
   
    DROP Window
RETURN

/*:VRX         LB1_ContextMenu
*/
LB1_ContextMenu: 
    CALL Vrmethod "FldNameMenu", "popup"
return

/*:VRX         LB1_DoubleClick
*/
Lb1_doubleclick:
    CALL Editcolname(1)
RETURN

/*:VRX         LB1_DragDrop
*/
LB1_DragDrop: 
    Srcfile = Vrinfo( "SourceFile" )
    Suffix = Translate(VRParseFileName( SrcFile, "E" ))
    if Suffix <> "BMP" THEN DO
        Buttons.1 = "Ok"
        Buttons.0 = 1
        id = VRMessage( VRWindow(), "Invalid file type!  You must use OS/2 BMP files!", "Warning", "Warning", "Buttons.", 1, 1 )
    end
    ok = VRSetIni( "KR2", "PG1BMP", SrcFile, "KR2.INI" )
return

/*:VRX         LB2_ContextMenu
*/
LB2_ContextMenu: 
    CALL Vrmethod "FldNameMenu", "popup"
return

/*:VRX         LB2_DoubleClick
*/
Lb2_doubleclick:
    CALL Editcolname(2)
RETURN

/*:VRX         LB2_DragDrop
*/
LB2_DragDrop: 
    Srcfile = Vrinfo( "SourceFile" )
    Suffix = Translate(VRParseFileName( SrcFile, "E" ))
    if Suffix <> "BMP" THEN DO
        Buttons.1 = "Ok"
        Buttons.0 = 1
        id = VRMessage( VRWindow(), "Invalid file type!  You must use OS/2 BMP files!", "Warning", "Warning", "Buttons.", 1, 1 )
    end
    ok = VRSetIni( "KR2", "PG2BMP", SrcFile, "KR2.INI" )
return

/*:VRX         LB3_ContextMenu
*/
LB3_ContextMenu: 
    CALL Vrmethod "FldNameMenu", "popup"

return

/*:VRX         LB3_DoubleClick
*/
Lb3_doubleclick:
    CALL Editcolname(3)

RETURN

/*:VRX         LB3_DragDrop
*/
LB3_DragDrop: 
    Srcfile = Vrinfo( "SourceFile" )
    Suffix = Translate(VRParseFileName( SrcFile, "E" ))
    if Suffix <> "BMP" THEN DO
        Buttons.1 = "Ok"
        Buttons.0 = 1
        id = VRMessage( VRWindow(), "Invalid file type!  You must use OS/2 BMP files!", "Warning", "Warning", "Buttons.", 1, 1 )
    end
    ok = VRSetIni( "KR2", "PG3BMP", SrcFile, "KR2.INI" )
return

/*:VRX         LB4_ContextMenu
*/
LB4_ContextMenu: 
    CALL Vrmethod "FldNameMenu", "popup"

return

/*:VRX         LB4_DoubleClick
*/
Lb4_doubleclick:
    CALL Editcolname(4)

RETURN

/*:VRX         LB4_DragDrop
*/
LB4_DragDrop: 
    Srcfile = Vrinfo( "SourceFile" )
    Suffix = Translate(VRParseFileName( SrcFile, "E" ))
    if Suffix <> "BMP" THEN DO
        Buttons.1 = "Ok"
        Buttons.0 = 1
        id = VRMessage( VRWindow(), "Invalid file type!  You must use OS/2 BMP files!", "Warning", "Warning", "Buttons.", 1, 1 )
    end
    ok = VRSetIni( "KR2", "PG4BMP", SrcFile, "KR2.INI" )

return

/*:VRX         LB5_ContextMenu
*/
LB5_ContextMenu: 
    CALL Vrmethod "FldNameMenu", "popup"

return

/*:VRX         LB5_DoubleClick
*/
Lb5_doubleclick:
    CALL Editcolname(5)

RETURN

/*:VRX         LB5_DragDrop
*/
LB5_DragDrop: 
    Srcfile = Vrinfo( "SourceFile" )
    Suffix = Translate(VRParseFileName( SrcFile, "E" ))
    if Suffix <> "BMP" THEN DO
        Buttons.1 = "Ok"
        Buttons.0 = 1
        id = VRMessage( VRWindow(), "Invalid file type!  You must use OS/2 BMP files!", "Warning", "Warning", "Buttons.", 1, 1 )
    end
    ok = VRSetIni( "KR2", "PG5BMP", SrcFile, "KR2.INI" )

return

/*:VRX         LB6_ContextMenu
*/
LB6_ContextMenu: 
    CALL Vrmethod "FldNameMenu", "popup"

return

/*:VRX         LB6_DoubleClick
*/
Lb6_doubleclick:
    CALL Editcolname(6)

RETURN

/*:VRX         LB6_DragDrop
*/
LB6_DragDrop: 
    Srcfile = Vrinfo( "SourceFile" )
    Suffix = Translate(VRParseFileName( SrcFile, "E" ))
    if Suffix <> "BMP" THEN DO
        Buttons.1 = "Ok"
        Buttons.0 = 1
        id = VRMessage( VRWindow(), "Invalid file type!  You must use OS/2 BMP files!", "Warning", "Warning", "Buttons.", 1, 1 )
    end
    ok = VRSetIni( "KR2", "PG6BMP", SrcFile, "KR2.INI" )

return

/*:VRX         NormalMouse
*/
Normalmouse:
    CALL Vrset Vrwindow(), "Pointer", "<default>"/* show "normal" mouse pointer */
RETURN

/*:VRX         Other1PageName_ContextMenu
*/
Other1pagename_contextmenu:
    CALL Setpghint(5)
RETURN

/*:VRX         Other2PageName_ContextMenu
*/
Other2pagename_contextmenu:
    CALL Setpghint(6)
RETURN

/*:VRX         PINPageName_ContextMenu
*/
Pinpagename_contextmenu:
    CALL Setpghint(3)
RETURN

/*:VRX         Quit
*/
Quit:
    Ok = Vrsetini( Appname, "SETUPTOP", Vrget("Setup1", "Top" ), Ininame)
    Ok = Vrsetini( Appname, "SETUPLEFT", Vrget("Setup1", "Left" ), Ininame)
    Ok = Vrsetini( Appname, "SETUPHYT", Vrget("Setup1", "Height" ), Ininame)
    Ok = Vrsetini( Appname, "SETUPWID", Vrget("Setup1", "Width" ), Ininame)

    CALL Savefields
    Window = Vrwindow()
    CALL Vrset Window, "Shutdown", 1
    DROP Window
RETURN

/*:VRX         SaveFields
*/
Savefields:
    CALL Waitmouse
    Value = Vrget( "BrowserNameField", "Value" )
    Ok = Vrsetini( Appname, "BrowserApp", Value, Ininame, "NOCLOSE" )
    Ok = Vrsetini( Appname, "CustomFontCB", Vrget( "CustomFontCB", "Set" ), Ininame , "NOCLOSE")
    Ok = Vrsetini( Appname, "BackupGenerationSpinner", Vrget( "BackupGenerationSpinner", "Value", "NOCLOSE" ), Ininame )
    Ok = Vrsetini( Appname, "SoundEnable", VRGet( "SoundEnable", "Set" ), Ininame, "NOCLOSE")

    DO I = 1 TO 6
        Ok = Krputpagename(I, Vrget( Contnames.i || "PageName", "Value" ))
        Ok = Krputpagehint(I, Pghint.i)
        Ok = Vrmethod( "LB" || I, "GetStringList", "ColNames." )
        Ok = Vrmethod( "LB" || I, "GetItemDataList", "ColData." )
        DO J = 1 TO 9
            Ok = Krputcolumnname(I, J, SUBSTR(Colnames.j, 2))
            Enb = 0
            IF SUBSTR(Colnames.j, 1,1) = "+" THEN DO
                Enb = 1
            END
            PARSE VAR Coldata.j E "�" Flag "�" Hint "�" Abbrev
            Ok = Krputcolumnenable(I, J, Enb, Flag, Hint, SUBSTR(Colnames.j, 2))
        END
    END
    CALL Normalmouse
RETURN

/*:VRX         SetPgHint
*/
Setpghint:
    Pg = ARG(1)
    Oldhint = Pghint.pg
    Buttons.1 = Vlsmsg(80)                                      /* Ok */
    Buttons.2 = Vlsmsg(218)                                 /* Cancel */
    Buttons.0 = 2
    Id = Vrprompt( Vrwindow(), Vlsmsg(324) /* Enter hint for page  */ || Pg, "OldHint", "Enter", "Buttons.", 1, 2 )
    IF Id = 1 THEN DO
        Pghint.pg = Oldhint
    END
RETURN

/*:VRX         SETUP1_Close
*/
Setup1_close:
    CALL Quit
RETURN


/*:VRX         SETUP1_LangException
*/
SETUP1_LangException: 

return

/*:VRX         SETUP1_LangInit
*/
SETUP1_LangInit:

    /* ------------------------------------------------ */
    /* Language internationalization code autogenerated */
    /* by VXNation v1.0, Copyright 1999, IDK, Inc.      */
    /*          http://www.idk-inc.com                  */
    /* Autogenerated: 03/06/2000 19:26:17             */
    /* ------------------------------------------------ */
    /* Warning! This code gets overwritten by VXNation! */
    /* Do not make modifications here!                  */
    /* ------------------------------------------------ */

    /* KeyRing/2 Setup */
    Ok = VRSet("SETUP1", "WindowListTitle", VLSMsg(179))

    /* KeyRing/2 Setup */
    Ok = VRSet("SETUP1", "Caption", VLSMsg(179))

    /* Notebook Pg 6 */
    Ok = VRSet("DT_7", "Caption", VLSMsg(298))

    /* Double click column names to edit them */
    Ok = VRSet("LB6", "HintText", VLSMsg(299))

    /* Click to move column name to left */
    Ok = VRSet("UB6", "HintText", VLSMsg(307))

    /* Hide/Show this column name */
    Ok = VRSet("HS6", "HintText", VLSMsg(301))

    /* Click to move selected column name to right */
    Ok = VRSet("DB6", "HintText", VLSMsg(302))

    /* Notebook Pg 5 */
    Ok = VRSet("DT_6", "Caption", VLSMsg(303))

    /* Double click column names to edit them */
    Ok = VRSet("LB5", "HintText", VLSMsg(299))

    /* Click to move column name to left */
    Ok = VRSet("UB5", "HintText", VLSMsg(307))

    /* Hide/Show this column name */
    Ok = VRSet("HS5", "HintText", VLSMsg(301))

    /* Click to move selected column name to right */
    Ok = VRSet("DB5", "HintText", VLSMsg(302))

    /* Notebook Pg 4 */
    Ok = VRSet("DT_5", "Caption", VLSMsg(304))

    /* Double click column names to edit them */
    Ok = VRSet("LB4", "HintText", VLSMsg(299))

    /* Click to move column name to left */
    Ok = VRSet("UB4", "HintText", VLSMsg(307))

    /* Hide/Show this column name */
    Ok = VRSet("HS4", "HintText", VLSMsg(301))

    /* Click to move selected column name to right */
    Ok = VRSet("DB4", "HintText", VLSMsg(302))

    /* Notebook Pg 3 */
    Ok = VRSet("DT_3", "Caption", VLSMsg(305))

    /* Double click column names to edit them */
    Ok = VRSet("LB3", "HintText", VLSMsg(299))

    /* Click to move column name to left */
    Ok = VRSet("UB3", "HintText", VLSMsg(307))

    /* Hide/Show this column name */
    Ok = VRSet("HS3", "HintText", VLSMsg(301))

    /* Click to move selected column name to right */
    Ok = VRSet("DB3", "HintText", VLSMsg(302))

    /* Notebook Pg 1 */
    Ok = VRSet("DT_1", "Caption", VLSMsg(306))

    /* Double click column names to edit them */
    Ok = VRSet("LB1", "HintText", VLSMsg(299))

    /* Click to move selected column name to left */
    Ok = VRSet("UB1", "HintText", VLSMsg(307))

    /* Hide/Show this column name */
    Ok = VRSet("HS1", "HintText", VLSMsg(301))

    /* Click to move selected column name to right */
    Ok = VRSet("DB1", "HintText", VLSMsg(302))

    /* Enter browser path/filename and command line parameters */
    Ok = VRSet("BrowserNameField", "HintText", VLSMsg(180))

    /* Netscape Location */
    Ok = VRSet("DT_4", "Caption", VLSMsg(181))

    /* Search */
    Ok = VRSet("BrowserSearchButton", "Caption", VLSMsg(182))

    /* Click here to pop up file dialog */
    Ok = VRSet("BrowserSearchButton", "HintText", VLSMsg(183))

    /* Custom Fonts */
    Ok = VRSet("CustomFontCB", "Caption", VLSMsg(264))

    /* Turns on drag/dropped fonts (slower startup) */
    Ok = VRSet("CustomFontCB", "HintText", VLSMsg(265))

    /* Number of backup PWX files to keep */
    Ok = VRSet("BackupGenerationSpinner", "HintText", VLSMsg(308))

    /* Backup Generations */
    Ok = VRSet("DT_8", "Caption", VLSMsg(309))

    /* Sound */
    Ok = VRSet("SoundEnable", "Caption", VLSMsg(360))

    /* Enable Multimedia Sounds */
    Ok = VRSet("SoundEnable", "HintText", VLSMsg(361))

    /* Enter a sound file to play at startup - right click for file dialog */
    Ok = VRSet("EF_1", "HintText", VLSMsg(326))

    /* Play this file: */
    Ok = VRSet("DT_9", "Caption", VLSMsg(362))

    /* Exit */
    Ok = VRSet("ExitButton", "Caption", VLSMsg(203))

    /* Save changes and quit */
    Ok = VRSet("ExitButton", "HintText", VLSMsg(204))

    /* ~Use defaults */
    Ok = VRSet("UseDefaultsButton", "Caption", VLSMsg(310))

    /* Reset field and page names to defaults */
    Ok = VRSet("UseDefaultsButton", "HintText", VLSMsg(311))

    /* Enter the page name; Right click to change page hint */
    Ok = VRSet("WWWPageName", "HintText", VLSMsg(312))

    /* Enter the page name; Right click to change page hint */
    Ok = VRSet("PINPageName", "HintText", VLSMsg(312))

    /* Enter the page name; Right click to change page hint */
    Ok = VRSet("ComboPageName", "HintText", VLSMsg(312))

    /* Notebook Pg 2 */
    Ok = VRSet("DT_2", "Caption", VLSMsg(313))

    /* Double click column names to edit them */
    Ok = VRSet("LB2", "HintText", VLSMsg(299))

    /* Click to move column name to left */
    Ok = VRSet("UB2", "HintText", VLSMsg(307))

    /* Hide/Show this column name */
    Ok = VRSet("HS2", "HintText", VLSMsg(301))

    /* Click to move selected column name to right */
    Ok = VRSet("DB2", "HintText", VLSMsg(302))

    /* Enter the page name; Right click to change page hint */
    Ok = VRSet("AppPageName", "HintText", VLSMsg(312))

    /* Enter the page name; Right click to change page hint */
    Ok = VRSet("Other1PageName", "HintText", VLSMsg(312))

    /* Enter the page name; Right click to change page hint */
    Ok = VRSet("Other2PageName", "HintText", VLSMsg(312))

    /* FldNameMenu */
    Ok = VRSet("FldNameMenu", "Caption", VLSMsg(363))

    /* ~Revert to default */
    Ok = VRSet("DefaultFieldName", "Caption", VLSMsg(327))

    call SETUP1_LangException
    DROP Ok

RETURN

/*:VRX         UB1_Click
*/
Ub1_click:
    CALL Upclick(1)
RETURN

/*:VRX         UB2_Click
*/
Ub2_click:
    CALL Upclick(2)

RETURN

/*:VRX         UB3_Click
*/
Ub3_click:
    CALL Upclick(3)

RETURN

/*:VRX         UB4_Click
*/
Ub4_click:
    CALL Upclick(4)

RETURN

/*:VRX         UB5_Click
*/
Ub5_click:
    CALL Upclick(5)

RETURN

/*:VRX         UB6_Click
*/
Ub6_click:
    CALL Upclick(6)

RETURN

/*:VRX         UpClick
*/
Upclick:
    Col = "LB" || ARG(1)
    S = Vrget( Col, "Selected" )
    IF S > 1 THEN DO
        Ok = Vrmethod( Col, "GetStringList", Allnames. )
        Ok = Vrmethod( Col, "GetItemDataList", Alldata. )

        N = S - 1

        Tempname = Allnames.n
        Tempdata = Alldata.n

        Allnames.n = Allnames.s
        Alldata.n = Alldata.s

        Allnames.s = Tempname
        Alldata.s = Tempdata

        Ok = Vrmethod( Col, "Reset" )
        Ok = Vrmethod( Col, "AddStringList", Allnames., 1, Alldata. )
        Ok = Vrset( Col, "Selected", N )
    END
    ELSE DO
        Ok = BEEP( 2000, 500 )
    END
RETURN

/*:VRX         UseDefaultsButton_Click
*/
Usedefaultsbutton_click: PROCEDURE EXPOSE Contnames. Defflgs.
    Buttons.1 = Vlsmsg(124)                                    /* ~Ok */
    Buttons.2 = Vlsmsg(218)                                 /* Cancel */
    Buttons.0 = 2

    Id = Vrmessage( Vrwindow(), Vlsmsg(1) /* Are you sure you want to lose all your changes (if any)? */, Vlsmsg(86) /* Warning */, "Warning", "Buttons.", 2, 2 )
    IF Id = 1 THEN DO
        DO I = 1 TO 6
            List = "LB" || I
            Ok = Vrset( Contnames.i || "PageName", "Value", Vlsmsg(240+I) )
            Ok = Vrmethod(List, "GetItemDataList", "ColumnData." )

            DO J = 1 TO 9
                /* get the old flag */
                PARSE VAR Columndata.j Enb "�" Flg "�" H "�" A
                /* look up the natural index number for this flag */
                N = Getdefaultflagindex(Flg)
                /* look up the hint for the natural index */
                H = Getdefaulthinttext(N)
                /* rebuild the flag with a new hint, enabled, old flag */
                Columndata.j = "1�" || Flg || "�" || H || "�" A
                /* set default column name based on order flag */
                Columnnames.j = "+" || Vlsmsg(98+N)/* use default name */
            END
            Columnnames.0 = 9
            Columndata.0 = 9
            Ok = Vrmethod(List, "Reset" )
            Ok = Vrmethod(List, "AddStringList", "ColumnNames.", 1 )
            Ok = Vrmethod(List, "SetItemDataList", "ColumnData." )
            Pghint.i = Vlsmsg(I + 277)
        END
    END
RETURN

/*:VRX         WaitMouse
*/
Waitmouse:
    CALL Vrset Vrwindow(), "Pointer", "Wait"/* show "Busy" mouse pointer */
RETURN

/*:VRX         WWWPageName_ContextMenu
*/
Wwwpagename_contextmenu:
    CALL Setpghint(1)
RETURN


