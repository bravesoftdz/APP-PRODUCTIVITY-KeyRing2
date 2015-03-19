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

/*:VRX         HatCounterTimer_Trigger
*/
Hatcountertimer_trigger:
    Time = Time + 1
    Ok = Vrset("Working", "SiblingOrder", 1)
    Ok = Vrset( "TT_1", "Caption", Time )
    IF Time = 1 THEN DO
        Ok = Vrmethod("Application", "PostQueue", 0, 1, "call HatReady" )
    END
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
    Appname = Initargs.2
    Ininame = Initargs.3
    Langname = Initargs.4

    IF Langname = "" THEN DO
        Langname = "ENGLISH.MSG"
    END
    Ok = Vlopenlang(Langname, Langname)
    CALL Working_langinit

    /* check registration mode */
    if KRFN3(2) = 1 then do
        /* if demo mode then display warning message with days remaining */
        ok = VRSet( "TT_2", "Caption", VLSMsg(366) /* This database file will expire in  */|| KRGetPageIndex() ||VLSMsg(367) /*  days! */ )
    end
    else do
        ok = VRSet( "TT_2", "Caption", "" )
    end

    Window = Vrwindow()
    CALL Vrmethod Window, "CenterWindow"
    CALL Vrset Window, "Visible", 1
    CALL Vrmethod Window, "Activate"
    Ok = Vrset(Window, "SiblingOrder", 1)

    DROP Window
    Time=0
    Ok = Vrset( "HatCounterTimer", "Enabled", 1 )
RETURN

/*:VRX         Quit
*/
Quit:
    Ok = Vrset( "HatCounterTimer", "Enabled", 0)
    Window = Vrwindow()
    CALL Vrset Window, "Shutdown", 1
    DROP Window
RETURN

/*:VRX         Working_Close
*/
Working_close:
    CALL Quit
RETURN

/*:VRX         Working_Help
*/
Working_help:
    CALL Infhelp(Vrinfo("Source"))
RETURN



/*:VRX         Working_LangException
*/
Working_LangException: 

return

/*:VRX         Working_LangInit
*/
Working_LangInit:

    /* ------------------------------------------------ */
    /* Language internationalization code autogenerated */
    /* by VXNation v1.0, Copyright 1999, IDK, Inc.      */
    /*          http://www.idk-inc.com                  */
    /* Autogenerated: 03/06/2000 19:27:15             */
    /* ------------------------------------------------ */
    /* Warning! This code gets overwritten by VXNation! */
    /* Do not make modifications here!                  */
    /* ------------------------------------------------ */

    /* KeyRing/2 Working */
    Ok = VRSet("Working", "WindowListTitle", VLSMsg(175))

    /* Encrypting/Decrypting... */
    Ok = VRSet("Working", "Caption", VLSMsg(176))

    /* Timer */
    Ok = VRSet("HatCounterTimer", "Caption", VLSMsg(66))

    /* 1 */
    Ok = VRSet("TT_1", "Caption", VLSMsg(177))

    /* Working... */
    Ok = VRSet("DT_1", "Caption", VLSMsg(178))

    /* Text */
    Ok = VRSet("TT_2", "Caption", VLSMsg(365))

    call Working_LangException
    DROP Ok

RETURN

