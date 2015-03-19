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
    IF( Argcount > 0 )THEN
        DO I = 1 TO Argcount
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
        CALL Vrmessage "", "Cannot load window: " Vrerror(), , " Error! "
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
    IF __vrlshwnd = '' THEN
        SIGNAL __vrlsdone
    IF __vrlswait \= 1 THEN
        SIGNAL __vrlsdone
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

/*:VRX         Fini
*/
Fini:
    Window = Vrwindow()
    CALL Vrset Window, "Visible", 0
    DROP Window
RETURN 0

/*:VRX         Halt
*/
Halt:
    SIGNAL _vrehalt
RETURN

/*:VRX         INFHelp
*/
Infhelp:
    ADDRESS Cmd 'start view kr2.inf' Vrget(ARG(1), "UserData")
RETURN

/*:VRX         Init
*/
Init:
    Ok = RXFUNCADD("VLLoadFuncs", "VLMSG", "VLLoadFuncs")/* do not modify or move this line! It must be on line #2 of this function */
    CALL Vlloadfuncs/* do not modify or move this line! It must be on line #3 of this function */

    Ok = Vrredirectstdio("On", "keyring2.err")
    Appname = Initargs.1
    Ininame = Initargs.2

    Langname = Vrgetini( Appname, "LANGUAGE", Ininame )
    IF Langname = "" THEN DO
        Langname = "ENGLISH.MSG"
    END
    Ok = Vlopenlang(Langname, Langname)   
    CALL Nagger_langinit
    if InitArgs.3 = 1 then do 
        ok = VRSet( "DT_2", "Caption", "Your license is for a previous version of KeyRing/2.")
        ok = VRSet( "DT_3", "Caption", "Please upgrade (pay) to remove this screen.")
        Ok = VRSet( "DT_4", "Caption", "The program will continue to work normally without other limitations." )
    end
    else do
        ok = VRSet( "DT_2", "Caption", "You can: Register and this screen will go away!" )
        ok = VRSet( "DT_3", "Caption", " " )
        ok = VRSet( "DT_4", "Caption", " " )
    end
    Window = Vrwindow()
    CALL Vrmethod Window, "CenterWindow"
    CALL Vrset Window, "Visible", 1
    CALL Vrmethod Window, "Activate"
    DROP Window
    CALL WaitMouse
RETURN

/*:VRX         Nagger_Close
*/
Nagger_close:
    CALL Quit
RETURN

/*:VRX         Nagger_Create
*/
Nagger_create:
    Cdval = 10
    Ok = Vrset( "PB_1", "Caption", Cdval )
    call normalmouse
RETURN

/*:VRX         Nagger_Help
*/
Nagger_help:
    CALL Infhelp(Vrinfo("Source"))
RETURN



/*:VRX         Nagger_LangException
*/
Nagger_LangException: 

return

/*:VRX         Nagger_LangInit
*/
Nagger_LangInit:

    /* ------------------------------------------------ */
    /* Language internationalization code autogenerated */
    /* by VXNation v1.0, Copyright 1999, IDK, Inc.      */
    /*          http://www.idk-inc.com                  */
    /* Autogenerated: 03/06/2000 19:25:48             */
    /* ------------------------------------------------ */
    /* Warning! This code gets overwritten by VXNation! */
    /* Do not make modifications here!                  */
    /* ------------------------------------------------ */

    /* Unregistered Product Nag Screen */
    Ok = VRSet("Nagger", "Caption", VLSMsg(205))

    /* Timer */
    Ok = VRSet("NotebookTabber", "Caption", VLSMsg(66))

    /* Make it stop!  Make it stop! */
    Ok = VRSet("DT_1", "Caption", VLSMsg(206))

    /* You can:  Register, and this screen will go away! */
    Ok = VRSet("DT_2", "Caption", VLSMsg(207))

    /* 5 */
    Ok = VRSet("PB_1", "Caption", VLSMsg(208))

    /* ~How do I Register? */
    Ok = VRSet("PB_2", "Caption", VLSMsg(209))

    /* Register ~Now! */
    Ok = VRSet("PB_3", "Caption", VLSMsg(359))

    call Nagger_LangException
    DROP Ok

RETURN

/*:VRX         NormalMouse
*/
Normalmouse:
    CALL Vrset Vrwindow(), "Pointer", "<default>" /* show "Normal" mouse pointer */
RETURN

/*:VRX         NotebookTabber_Trigger
*/
Notebooktabber_trigger:
    Cdval = Cdval - 1
    IF Cdval > 0 THEN do
        Rc = Vrset( "PB_1", "Caption", Cdval )
    end
    ELSE DO
            Rc = Vrset( "PB_1", "Caption", Vlsmsg(124) /* ~Ok */ )
            Rc = Vrset( "PB_1", "Enabled", 1 )
            Rc = Vrset( "NotebookTabber", "Enabled", 0 )
            call normalmouse
    END
RETURN

/*:VRX         PB_1_Click
*/
Pb_1_click:
    CALL Quit
RETURN

/*:VRX         PB_2_Click
*/
Pb_2_click:
    ADDRESS Cmd 'start view kr2.inf' 'register'
RETURN

/*:VRX         PB_3_Click
*/
PB_3_Click: 
    Ok = About(VRWindow(), AppName, ININame)
return

/*:VRX         Quit
*/
Quit:
    CALL Saveprops
    Window = Vrwindow()
    CALL Vrset Window, "Shutdown", 1
    DROP Window
RETURN

/*:VRX         RestoreProps
*/
Restoreprops:
RETURN
    Ok = Vrmethod( Vrget(Vrwindow(), "name"), "ListChildren", "child." )

    Lastchild=Child.0+1
    Child.lastchild= Vrget(Vrwindow(), "name")
    Child.0=Lastchild
    Initstring=""
    DO X=1 TO Child.0
        Value = Vrgetini( "KR2", Vrget(Child.x, Name), "KR2.INI", "NOCLOSE" )
        PARSE VAR VALUE Font "�" Fore "�" Back
        Ok = Vrset(Child.x, "font", Font)
        Ok = Vrset(Child.x, "forecolor", Fore)
        Ok = Vrset(Child.x, "backcolor", Back)
    END

RETURN

/*:VRX         SaveProps
*/
Saveprops:
RETURN
    Ok = Vrmethod( Vrget(Vrwindow(), "name"), "ListChildren", "child." )

    Lastchild=Child.0+1
    Child.lastchild = Vrget(Vrwindow(), "name")
    Child.0 = Lastchild
    Initstring = ""
    DO X = 1 TO Child.0
        IF Vrmethod( "Application", "SupportsProperty", Child.x , "font" ) = 1 THEN DO
            IF Vrmethod( "Application", "SupportsProperty", Child.x , "forecolor" ) = 1 THEN DO
                IF Vrmethod( "Application", "SupportsProperty", Child.x , "backcolor" ) = 1 THEN DO
                    Initstrg = Vrget(Child.x, "font") || "�" Vrget(Child.x, "forecolor") || "�" Vrget(Child.x, "backcolor")
                    Ok = Vrsetini( "KR2", Vrget(Child.x, "Name"), Initstrg, "KR2.INI", "NOCLOSE" )
                END
            END
        END
    END


RETURN

/*:VRX         WaitMouse
*/
Waitmouse:
    CALL Vrset Vrwindow(), "Pointer", "Wait"/* show "Busy" mouse pointer */
RETURN

