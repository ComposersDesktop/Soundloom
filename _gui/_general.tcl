#
# SOUND LOOM RELEASE mac version 17.0.4
#

# RWD Version for OS X Feb 04
#  setup for MAC assumes only OSX, we have no interest in earlier MacOS!
# Line 227 set directory separators etc	 ; see also startup.tcl
# Line 516 prevent freeze

#RWD 28 June 2013
# ... moved to using tcltk 8.5.x, don't need ResetButtonState(), so converted to no-op (instant return)
# ... fixup button rectangles

#############
#  GENERAL	#
#############

#####################################
# OVERALL MANAGEMENT OF PROCESSES	#
#####################################

#------ On going to a new infile, erase memory related to previous infile

proc ClearInfileDependentItems {} {
	global brk brkfrm origbrk origbrkfrm baktrak baktemp lastbrk maskedge
	catch {unset brk}
	catch {unset brkfrm}
	catch {unset origbrk}
	catch {unset origbrkfrm}
	catch {unset lastbrk}
}

#------ On going to a new process, erase memory of previous process

proc ClearProcessDependentItems {} {
	global pstore lastrangetype

	catch {unset lastrangetype}
	catch {unset pstore}

}

#------ Change name to external representation (strips '_' separators)

proc StripName {name} {
	set name [string trim $name]
	set name [split $name "_"] 
	return $name
}

#------ Test for a numeric string	(-)123.123	: (-).123 : (-)123. (-)123 : but not (-).

proc IsNumeric {str} {
	if {![regexp {^\-?[0-9]*\.?[0-9]*$} $str] || ![regexp {[0-9]+} $str]} {
		return 0
	}
	return 1
}

#------ Test for a numeric string	(-)123.123	: (-).123 : (-)123. (-)123 : but not (-).

proc IsNumericOrE {str checkms} {
	global ismS
	set is_ms 0
	if {$checkms}  {
		set sstr [string tolower $str]
		set k [string first "ms" $sstr]
		if {$k > 0} {
			incr k -1
			set is_ms 1
			set str [string range $str 0 $k]
		}
	}
	if {![regexp {^\-?[0-9]*\.?[0-9]*(e\-[0-9]+)?$} $str] || ![regexp {[0-9]+} $str]} {
		return 0
	}
	if {$is_ms} {
		set ismS 1
	}
	return 1
}

#------ Check entered val is +ve number

proc IsPositiveNumber {str} {
	if {[string length $str] <= 0} {
		return 0
	}
	if [regexp {^[0-9\.]+$} $str] {		;#	Numbers and dec point only
		if {![regexp {[0-9]+} $str]} {		;#	No integers, bad
			return 0
		}
		if [regexp {\..*\.} $str] {			;#	i.e. a dec point followed by 0 or more of any character + a dec point
			return 0						;#   i.e. >1 dec point, bad
		}
		if [regexp {^[0\.]+$} $str] {		;#	ZERO
			return 0
		}
		return 1
	}
	return 0
}

#------ Is an integer val even or odd ??

proc IsEven {val} {
	set newval	[expr int($val / 2)]
	incr newval $newval
	if {$val == $newval} {
		return 1
	}
	return 0
}

#------ Decide if two float vals are "equal"

proc Flteq {a b} {
	global evv
	set hibound [expr $a + $evv(FLTERR)]	
	set lobound [expr $a - $evv(FLTERR)]
	if {($b < $lobound) || ($b > $hibound)} {
		return 0
	}
	return 1
}

#------ Scrolled Canvas, to display, and operate on, Instrument-Tree

proc Scrolled_Canvas { c args } {
	global evv
	frame $c -borderwidth $evv(SBDR)
	eval {canvas $c.canvas -xscrollcommand [list $c.xscroll set] \
						   -yscrollcommand [list $c.yscroll set] \
						   -highlightthickness 2 -borderwidth 0} $args
	scrollbar $c.xscroll -orient horizontal -command [list $c.canvas xview]
	scrollbar $c.yscroll -orient vertical   -command [list $c.canvas yview]
	grid $c.canvas $c.yscroll -sticky news
	grid $c.xscroll -sticky ew
	grid rowconfigure $c 0 -weight 1 		;#	i.e. the scollbars keep their width
	grid columnconfigure $c 0 -weight 1
	return $c.canvas
}

#------ Force entered text to be single (non-empty) word, with no trailing spaces, and no special chars

proc FixTxt {str var} {
	set str "[string trim $str]"
	set len [string length $str]
	if {$len <= 0} {
		Inf "No $var entered"
		return ""
	}
	if {[regexp {[^A-Za-z0-9_:\.\-]} $str]} {		;# Alphanumeric, decimal point, underscore, -ve(or dash), colon
		Inf "'$var' contains invalid characters"
		return ""
	}
	return $str
}

#------ Force entered text to be single (non-empty) word, with no trailing spaces, and no special chars

proc RegulariseEnteredParamText {str name gdg_type pcnt gcnt} {
	global resetsuck evv
	set str "[string trim $str]"
	set len [string length $str]
	if {$len <= 0} {
		Inf "No $name entered"
		return ""
	}
### MAR 2007
	if {[string match $str "*"]} {
		Suckit $pcnt $gcnt
		return $resetsuck
	}

	if {[string match $gdg_type $evv(STRING_C)]
	||	[string match $gdg_type $evv(STRING_D)]} {

		if {[regexp {[^A-Za-z0-9_:\.\#\-]} $str]} {		;# Alphanumeric,dec.point,underscore,-ve(or dash),colon,'#'
			Inf "$name ($str) contains invalid characters"
			return ""
		}
	} else {
		if {[regexp {[^A-Za-z0-9_:/\.\\\-]} $str]} {	;# Alphanumeric, decimal point, underscore, -ve(or dash), colon
			Inf "$name ($str) contains invalid characters"	;#	Or backslash
			return ""
		}
	}
	set strlist [split $str \\]		   					;#	Convert to TK directory representation

	if {[llength $strlist] > 1} {
		set newstr ""
		foreach item $strlist {
			append newstr $item "/"
		}
		set len [string length $newstr]
		incr len -2
		set str [string range $newstr 0 $len]
	}
	return $str
}

#------ as FixTxt, but allows directory names

proc CheckDirectoryName {str var user_entered mustexist} {
	global evv
	set str "[string trim $str]"
	set len [string length $str]
	if {($len <= 0) && $mustexist} {
		Inf "No $var entered"
		return ""
	}
#JUNE 30 UC-LC FIX

	set str [string tolower $str]

	if {$user_entered} {
		switch -- $evv(SYSTEM) {
			SGI {
				if {[regexp {[^A-Za-z0-9_/\.\-]} $str]} {		;#	Allows directory separator '/'
					Inf "$var contains invalid characters"
					return ""
				}
			}
			PC {					
				set OK 1
				set origstr $str
				set colontest [string first ":" $str]
				if {$colontest == 1} {								;#	Allows (e.g.) "c:" at start of filename
					if {[regexp {[^A-Za-z]} [string range $str 0 0]]} {
						set OK 0
					} else {
						set str [string range $str 2 end]
						if {[string length $str] <= 0} { 			;#	But not ONLY "c:"
							Inf "$var is incomplete"
							return ""
						}
					}
				} elseif {$colontest >= 0} {						;#	Disallows ":" elsewhere in filename
					set OK 0
				}
				if {$OK} {
					set str [RegulariseDirectoryRepresentation $str]
					if {[regexp {[^A-Za-z\ 0-9_/\.\-]} $str]} {	;#	Allows directory separator '\',
						set OK 0									;#	 and spaces in dirnames
					}
				}
				if {$OK == 0} {
					Inf "$var contains invalid characters"
					return ""
				}
				if {$colontest == 1} {
					set newstr [string range $origstr 0 1]
					append newstr $str
					set str $newstr
				}
				set str [AdjustDirname $str]
			}
			MAC {
				if {[regexp {[^~A-Za-z\ 0-9_/\.\-]} $str]} {		;#	RWD: OS X only! Allows directory separator '/' and ~ 
					Inf "$var contains invalid characters"
					return ""
				}
			}
			LINUX {
				Inf "Directory separator for linux not known: CheckDirectoryName"
				return ""
			}
		}
	}
	if {[CDP_Restricted_Directory $str 1]} {
		if {$user_entered} {
			Inf "This is a reserved CDP directory"
		}
		return ""
	}
	return $str
}

#------ Convert backslash to forward slash in directory paths

proc RegulariseDirectoryRepresentation {str} {
#JUNE 30 UC-LC FIX
	set str [string tolower $str]
#
#	if {[regexp {[\\]} $str] && ![regexp {[/]} $str]} {
#	}
#
	if {[regexp {[\\]} $str]} {
		set strlist [split $str \\]		   			;#	Convert to TK directory representation
		if {[llength $strlist] > 1} {
			set newstr ""
			foreach item $strlist {
				append newstr $item "/"
			}
			set len [string length $newstr]
			incr len -2
			set str [string range $newstr 0 $len]
		}
	}
	return $str
}

#------ Hide window if mouse clicks outside it													   

proc HideWindow {w x y args} {

	set wlist [split $w "."]
	set w "."
	append w [lindex $wlist 1]
	set xyxy [winfo geometry $w]
	set w_c [split $xyxy x+]
	set xa  [lindex $w_c 0]
	set ya  [lindex $w_c 1]
	if {$x < 0 || $x > $xa} {
		foreach prompt $args {
			upvar $prompt pp
			set pp 0
		}
		return
	}
	if {$y < 0 || $y > $ya} {
		foreach prompt $args {
			upvar $prompt pp
			set pp 0
		}
		return
	}
}

#------ Hide window if mouse clicks outside it													   

proc RaiseWindow {w x y args} {

	set wlist [split $w "."]
	set w "."
	append w [lindex $wlist 1]
	set xyxy [winfo geometry $w]
	set w_c [split $xyxy x+]
	set xa  [lindex $w_c 0]
	set ya  [lindex $w_c 1]
	if {$x < 0 || $x > $xa} {
		raise $w
		return
	}
	if {$y < 0 || $y > $ya} {
		raise $w
	}
}

#------ My version of library Dlg_Create (p. 437-8 in Welch) [added no-window-nuke]

proc Dlg_Create {top title protocol args} {
	global dialog
	if [winfo exists $top] {
		switch -- [wm state $top] {
			normal {
				# Raise a buried window
				raise $top
			}
			withdrawn -
			iconified {
				# Open and restore geometry
				wm deiconify $top
				catch {wm geometry $top $dialog(geo,$top) }
			}
		}
		return 0
	} else {
		eval {toplevel $top} $args
		wm protocol $top WM_DELETE_WINDOW $protocol
		wm title $top $title
		return 1
	}
}

#------ Library version of Dlg_Dismiss (p.438 in Welch)

proc Dlg_Dismiss {top} {
	global dialog
	# save current size and position
	catch {
		# window may have been deleted
		set dialog{geo,$top} [wm geometry $top]
		wm withdraw $top
	}
}

#------ Grab Focus for dialog, save old focus

proc My_Grab {wait_for_visibility top varName {where_to_focus {}}} {
	global wstk window_stack_index

	upvar $varName var
	bind $top <Destroy>	[list set $varName $var]	;#	Poke variable if user nukes window
	if {[string length $where_to_focus] == 0} {
		set where_to_focus $top				;#	Set 'where_to_focus' as whole top window, if no smaller unit specified
	}

# ADD CURRENT WINDOW TO STACK OF WINDOWS

	set oldwindow [lindex $wstk end]
	lappend wstk $top					;#	Update listing of window hierarchy
	incr window_stack_index
	focus $where_to_focus					;#	Set focus to new widget
	if {$wait_for_visibility} {
		catch {tkwait visibility $top}		;#	Wait for new widget to be fully drawn
	}
	catch {grab $top}						;#	Grab focus (exclusive) for new widget
	catch {wm withdraw $oldwindow}
	ResetButtonState $top $top 1
}

#------ Grab Focus for dialog, save old focus

proc Simple_Grab {wait_for_visibility top varName {where_to_focus {}}} {
	global old_window
    global last_stack_window wstk

	upvar $varName var
	bind $top <Destroy>	[list set $varName $var]	;#	Poke variable if user nukes window
	if {[string length $where_to_focus] == 0} {
		set where_to_focus $top				;#	Set 'where_to_focus' as whole top window, if no smaller unit specified
	}

	catch {set last_stack_window [lindex $wstk end]}

	set old_window [focus -displayof $top]

	focus $where_to_focus					;#	Set focus to new widget

	if {$wait_for_visibility} {
		catch {tkwait visibility $top}		;#	Wait for new widget to be fully drawn
	}
	catch {grab $top}						;#	Grab focus (exclusive) for new widget
}

#------ Release focus on dialog, restore focus to previous dialog

proc Simple_Release_to_Dialog {top} {
	global old_window
	catch {grab release $top}
	catch {focus $old_window}
}

#------ Release focus on dialog, restore focus to previous dialog

proc My_Release_to_Dialog {top} {
	global wstk window_stack_index evv
	incr window_stack_index -1

	if {$window_stack_index < 0} {
		ErrShow "Error in window accounting"
	}
	set done 0

#	GO DOWN THE WINDOW STACK UNTIL AN UNDELETED WINDOW IS FOUND, AND FOCUS ON IT

	if [info exists wstk] {
		while {!$done} {
			set wstk [lrange $wstk 0 $window_stack_index]
			set thiswindow [lindex $wstk end]
			if {![winfo exists $thiswindow]} {
				incr window_stack_index -1
				if {$window_stack_index < 0} {
					exit
				}
				continue
			}
			catch {grab release $top}
			focus $thiswindow
			set done 1
		}
		if {![catch {set st [wm state $thiswindow]}]} {
			switch -- $st {
				normal {
					# Raise a buried window
					raise $thiswindow
				}
				withdrawn -
				iconified {
					# Open and restore geometry
					wm deiconify $thiswindow
					catch {wm geometry $thiswindow $dialog(geo,$thiswindow)}
					if {!($evv(SYSTEM) == "MAC")} {			#RWD this seem to be the sticking point on OSX
						tkwait visibility $thiswindow
					}
				}
			}
		}
		raise $thiswindow
		catch {grab $thiswindow}				;#	Grab focus (exclusive) for previous widget
		ResetButtonState $top $thiswindow 0
	}
}

#------ Temporarily  stall user intervention

proc Block {mymessage} {
	global blocker message_stack message_maxindex pr_block is_blocked evv
	set f .blocker														

	if [Dlg_Create $f "" "set pr_block 1" -borderwidth 10 -height 0 -width 600] {  ;#	IF NO BLOCKER EXISTS
		frame $f.f -height 1 -width 600
		pack propagate $f.f false
		pack $f.f -side top -fill x -expand true
		set message_stack "$mymessage"									;#	Start message stack
		set message_maxindex 0											;# 	Start index to message_stack
		wm resizable $f 1 1
	} else {															;#	SUBSEQUENTLY
		lappend message_stack "$mymessage"								;#	Add message to stack
		incr message_maxindex											;#	Increment maxindex of message stack
	}
	wm title $f "PLEASE WAIT :      [string toupper $mymessage]"
	set pr_block 0
	raise $f
	set is_blocked 1
 	My_Grab 1 $f pr_block											;#	Grab Focus for blocking message
}

#------ Re-enable user intervention

proc UnBlock {} {
	global blocker message_stack message_maxindex is_blocked
	incr message_maxindex -1											;#	Move down the message stack
	if {$message_maxindex < 0} {										;#	IF NO MESSAGES REMAIN
		My_Release_to_Dialog .blocker									;#	Destroy the blocker dialog
		destroy .blocker											 
	} else {														 	;#	OTHERWISE
		set message_stack [lrange $message_stack 0 $message_maxindex]	;#	Shorten the message stack by one
		wm title .blocker "PLEASE WAIT [lindex $message_stack end]"		;#	Put the previous message in blocker
		My_Release_to_Dialog .blocker									;#	Go back to calling dialog
		Dlg_Dismiss .blocker											;#	(Which may be the blocker!!)
	}
	catch {unset is_blocked}
}

#------ Puts scrollbars in place (p.347 in Welch)

proc Scroll_Set {scrollbar geoCmd offset size} {
	if {$offset != 0.0 || $size != 1.0} {
		eval $geoCmd	;#	MAke sure it is visible
	}
	$scrollbar set $offset $size
}

#------ Library version of Scrolled_Listbox (p.348 in Welch)

proc Scrolled_Listbox { f args } {
	frame $f
	listbox $f.list \
		-xscrollcommand [list Scroll_Set $f.xscroll \
			[list grid $f.xscroll -row 1 -column 0 -sticky we]] \
		-yscrollcommand [list Scroll_Set $f.yscroll \
			[list grid $f.yscroll -row 0 -column 1 -sticky ns]]
	eval {$f.list configure} $args
	scrollbar $f.xscroll -orient horizontal \
		-command [list $f.list xview]
	scrollbar $f.yscroll -orient vertical \
		-command [list $f.list yview]
	grid $f.list -sticky news
	grid rowconfigure $f 0 -weight 1
	grid columnconfigure $f 0 -weight 1
	return $f.list
}

#------ Error message dialog box : errors in the program itself

proc ErrShow {errmessage} {
	global wstk
#	tk_messageBox -type ok -message "$errmessage" -icon error -parent [lindex $wstk end]
	tk_messageBox -type ok -message "$errmessage" -icon error
}

#------ Information dialog box: information, or user-error

proc Inf {errmessage} {
	global wstk normalfnt
#	tk_messageBox -type ok -message "$errmessage" -icon info -parent [lindex $wstk end]
	tk_messageBox -type ok -message "$errmessage" -icon info
}

#------ Information dialog box: information, or user-error

proc WarningShow {errmessage} {
	global wstk normalfnt
#	tk_messageBox -type ok -message "$errmessage" -icon warning -parent [lindex $wstk end]
	tk_messageBox -type ok -message "$errmessage" -icon warning
}

#------ Force return to topmost level, on program failure

proc BombOut {} {
	global pr1 pr2 pr3 bombout ins pr_ins evv
	set bombout  1
	set pr1  0
	set pr2  0
	set pr3  0
	if {$ins(create)} {
		set pr_ins $evv(INS_ABORTED)
	}
}

#------ Check for invalid extension (when working on workspace)

proc is_CDP_Reserved_Extension {file_extension} {
	global evv
	set is_sndsysfile 0
	foreach ext $evv(SNDFILE_EXTS) {	;#	If a sndfile extension But not the valid one
		if [string match $file_extension $ext] {
			set is_sndsysfile 1
			break
		}
	}
	if {$is_sndsysfile && ![string match $file_extension $evv(SNDFILE_EXT)]} {	
		return 1
	}
	return 0
}

#------ Test a new filerootname for CDP validity
#	*** IF this is changed, FILES STILL CANNOT begin with evv(NUM_MARK) ****
#

proc ValidCdpFilename {filerootname inform} {
	global allow_numeric_filenames evv
#JAN 2006
	global checkspace
	if {[string first [string tolower [file rootname $evv(SOUNDLOOM)]] [string tolower $filerootname]] == 0} { 
		if {$inform} {
			Inf "Invalid CDP filename."
		}
		return 0
	}
	if {!$allow_numeric_filenames} {

		if {![regexp {^[a-zA-Z_]} $filerootname]} {	;#	Filenames must start with alphabet character or '_'
			if {$inform} {
				Inf "Invalid CDP filename. Must start with alphabetic character, or underscore"
			}
			return 0
		}
	} else {
		if {[regexp {^[\-]} $filerootname]} {	;#	Filenames cannot start with '-' (interpreted as a flag!!)
			if {$inform} {
				Inf "Invalid CDP filename. Filenames cannot start with '-'"
			}
			return 0
		}
	}
#JAN 2006
	if {[info exists checkspace]} {
		if {![regexp {^[a-zA-Z0-9_\-\ ]+$} $filerootname] } {
			if {$inform} {
				Inf "Invalid CDP filename. Use alphabetic characters, numbers, underscore and hyphen only."	;#	Filename must be alphanumeric, with or without '_' and '-'
			}
			return 0
		}
	} else {
		if {![regexp {^[a-zA-Z0-9_\-]+$} $filerootname] } {
			if {$inform} {
				Inf "Invalid CDP filename. Use alphabetic characters, numbers, underscore and hyphen only."	;#	Filename must be alphanumeric, with or without '_' and '-'
			}
			return 0
		}
	}
	if {[string match $evv(DFLT_TMPFNAME) $filerootname]} {
		if {$inform} {
			Inf "Reserved CDP filename."	;#	Filename can't be a CDP default temporary filename
		}
		return 0
	}
	if {[string match $evv(DFLT_OUTNAME)* $filerootname]} {
		if {$inform} {
			Inf "Reserved CDP filename."	;#	Filename can't be a CDP default temporary output filename
		}
		return 0
	}
	if {[string match $evv(MACH_OUTFNAME)* $filerootname]} {
		if {$inform} {
			Inf "Reserved CDP filename."	;#	Filename can't be a CDP default temporary output filename
		}
		return 0
	}
	if {[string match $evv(GUI_NAME)* $filerootname]} {
		if {$inform} {
			Inf "Reserved CDP filename."	;#	Filename can't be a CDP default temporary output filename
		}
		return 0
	}
	if {[string match $evv(CDP_TEMPDIR)* $filerootname]} {
		if {$inform} {
			Inf "Reserved CDP filename."	;#	Filename can't be a CDP temporary directory
		}
		return 0
	}
	if {[string match __* $filerootname]} {
		if {$inform} {
			Inf "Reserved CDP filename."	;#	Filename can't be a CDP temporary directory
		}
		return 0
	}
	return 1
}

#------ Check no directory path, or extension, used. Check it's a valid CDPfilename

proc ValidCDPRootname {newname} {
	set fullname $newname
	set newname [file tail $newname]
	if {![string match $newname $fullname]} {
		Inf "You cannot use directory paths in the filename, here"
		return 0
	}
	set newrootname [file rootname $newname]
	if {![string match $newname $newrootname]} {
		Inf "You cannot use extensions in the filename, here"
		return 0
	}
	if {![ValidCdpFilename $newname 1]} {
		return 0
	}
	return 1
}		

#------ Force a value set elsewhere, into entrybox display, where display may be disabled

proc ForceVal {e val} {
	set origstate [$e cget -state]
	$e config -state normal
	$e delete 0 end
	$e insert 0 $val
	$e xview moveto 1.0
	$e config -state $origstate
}

#------ Strip trailing zeros from a decimal number

proc StripTrailingZeros {str} {
	set indx [string first "." $str]
	if {$indx >= 0} {											;#	If there's a decimal point
		set indx [string length $str]							;#	get string length
		incr indx -1											;# 	point to last item
		while {[string match "0" [string index $str $indx]]} {	;#	and cut off any trailing zeros
			incr indx -1										;#	recursively
			set str [string range $str 0 $indx]
		}
	}
	return $str
}

#------ Get the integer part of string between start (or minus sign) and decimal point (if any)
#
#	CARE: only works with vals >= 1 or <= 1
#

proc GetAbsoluteIntegerPartOf {str} {
	set begin 0									;#	Set begin at string start
	set finish [string length $str]				
	incr finish -1								;#	Set finish at string end
	set ns [string first "-" $str]
	if {$ns >=0 } {								;#	If ness, adjust begin to after minus sign
		set begin $ns
		incr begin
	}
	set dp [string first "." $str]				;#	If ness, adjust finsih to before decimal point
	if {$dp >= 0} {
		set finish $dp
		incr finish -1
	} 			
	set str [string range $str $begin $finish]	;#	Get the (abs) integer part of string
}

#------ Put new window over Right-Half of existing window

proc ToRightHalf {basewin newwin} {
	set geo_a [split [wm geometry $basewin] x+]
	set geo_b [split [wm geometry $newwin] x+]

	set halfwidth [expr [lindex $geo_a 0] / 2]
	set topright [expr [lindex $geo_a 2] + $halfwidth]
	set newgeo $halfwidth
	append newgeo "x" [lindex $geo_a 1] "+" $topright "+" [lindex $geo_a 3]
	return $newgeo
}

#------ Put new window over Right-Third of existing window

proc ToRightThird {basewin newwin} {
	set geo_a [split [wm geometry $basewin] x+]
	set geo_b [split [wm geometry $newwin] x+]

	set thirdwidth [expr [lindex $geo_a 0] / 3]
	set twothirdswidth $thirdwidth
	incr twothirdswidth $thirdwidth
	set topright [expr [lindex $geo_a 2] + $twothirdswidth]
	set newgeo $thirdwidth
	append newgeo "x" [lindex $geo_a 1] "+" $topright "+" [lindex $geo_a 3]
	return $newgeo
}

#------ Put new window over Right-Half of top of existing window

proc ToRightHalfTop {basewin newwin} {
	set geo_a [split [wm geometry $basewin] x+]
	set geo_b [split [wm geometry $newwin] x+]

	set halfwidth [expr [lindex $geo_a 0] / 2]
	set topright [expr [lindex $geo_a 2] + $halfwidth]
	set newgeo $halfwidth
	append newgeo "x" 60 "+" $topright "+" [lindex $geo_a 3]
	return $newgeo
}

#------ Protocls when user tries to kill CDP windows

proc PreventExit {} {
#	does nothing, and also, fails to exit!!
}

#------ Put window in screen centre

proc ScreenCentre {f} {
	wm geometry $f 400x100+300+300	  	;#	SCREEN SIZE DEPENDENT (SORRY! LAST MINUTE THING : NEEDS FIXING)
}

#------ Put window in screen centre

proc ScreenCentreBigger {f} {
	wm geometry $f 600x100+300+300	  	;#	SCREEN SIZE DEPENDENT (SORRY! LAST MINUTE THING : NEEDS FIXING)
}

#------ Put window in screen centre

proc ScreenCentreSmall {f} {
	wm geometry $f 200x100+300+300	  	;#	SCREEN SIZE DEPENDENT (SORRY! LAST MINUTE THING : NEEDS FIXING)
}

#------ Dialogbox to allow user to abort a process.

proc AreYouSure {} {
	global wstk normalfnt evv
	set choice [tk_messageBox -type yesno -default yes -message "ARE YOU SURE ???" -icon question]
	switch -- $choice {
		yes	{return 1}
		no	{return 0}
	}
}

#------ Trap for programs called which are not on user's system

proc ProgMissing {progname str} {
	global sl_real evv

	set thisname [string tolower [file tail $progname]]]
	switch -- [file tail $progname] {
		analjoin  -
		blur	  -
		brkdur	  -
		cdparams  -
		cdparse   -
		columns	  -
		combine	  -
		diskspace -
		distort	  -
		envel	  -
		envnu	  -
		extend	  -
		filter	  -
		flutter	  -
		focus	  -
		formants  -
		frame     -
		gate	  -
		get_partials -
		getcol    -
		gobo	  -
		gobosee	  -
		grain	  -
		hfperm	  -
		hilite	  -
		histconv  -
		housekeep -
		hover     -
		hover2    -
		listdate  -
		lucier	  -
		manysil   -
		maxsamp2  -
		mchanpan  -
		mchanrev  -
		mchshred  -
		mchzig    -
		mchiter   -
		mchstereo -
		modify	  -
		morph	  -
		mton	  -
		multimix  -
		newmix	  -
		oneform	  -
		paudition -
		pdisplay  -
		peak      -
		pitch	  -
		pitchinfo -
		pmodify   -
		prefix	  -
		progmach  -
		psow	  -
		ptobrk	  -
		pview	  -
		pagrab	  -
		paview	  -
		putcol    -
		pvoc	  -
		repitch	  -
		retime    -
		rmresp    -
		rmverb    -
		search    -
		sfedit	  -
		sndinfo	  -
		spec	  -
		specinfo  -
		specnu	  -
		specross  -
		strange	  -
		strans	  -
		stretch	  -
		submix	  -
		synth	  -
		tapdelay  -
		texmchan  -
		timetap	  -
		texture	  -
		vectors   -
		iterfof   -
		pulser    -
		chirikov  -
		speculate -
		spectune  -
		repair    -
		distshift -
		quirk	  -
		rotor	  -
		tesselate -
		crystal   -
		waveform  -
		dvdwind   -
		cascade   -
		synspline -
		fractal   -
		fracspec  -
		splinter  -
		repeater  -
		verges    -
		motor     -
		stutter	  -
		scramble  -
		impulse   -
		tweet     -
		brownian  -
		spin	  -
		sorter    -
		specfnu   -
		flatten   -
		caltrain  -
		specenv  -
		wrappage  {			;#	CORE CDP PROGRAMS
			if {![file exists $progname$evv(EXEC)]} {
				Inf "The program [string toupper [file tail $progname]$evv(EXEC)] is not on your system\nor is not in the directory [file dirname $progname]."
				return 1
			}
		}
		cdparsyn  {			;#	CDP DEMO PROGRAM
			if {![file exists $progname$evv(EXEC)]} {
				Inf "The program [string toupper [file tail $progname]$evv(EXEC)] (needed for the demo) is not on your system\nor is not in the directory [file dirname $progname]."
				return 1
			}
		}
		default {
			if {![file exists $progname$evv(EXEC)]} {
				Inf "The program [file tail $progname]$evv(EXEC) is not on your system\n or is not in the directory [file dirname $progname].\n\n$str."
				return 1
			}
		}
	}
	return 0
}

#---- Fix Root dirname 'anomalies' for PC

proc AdjustDirname {dirname} {
	global evv

	if {$evv(SYSTEM) == "PC"} {
		set k [string first ":" $dirname]
		if {$k > 0} {
			set kk $k
			incr kk
			if {![string match "/" [string index $dirname $kk]]} {
				set zurb [string range $dirname 0 $k]
				append zurb	"/"
				append zurb [string range $dirname $kk end]
				set dirname $zurb
			}
		}
	}
	return $dirname
}

proc CDP_Restricted_Directory {str private}  {
	global private_directories evv

	set matchstr [file tail $evv(CDPRESOURCE_DIR)]
	set matchstr "*$matchstr*"
	if [string match $matchstr $str] {
		return 1
	}
	set matchstr [file tail $evv(CDP_TEMPDIR)]
	set matchstr "*$matchstr*"
	if [string match $matchstr $str] {
		return 1
	}
	set matchstr [file tail $evv(CDPROGRAM_DIR)]
	set matchstr "*$matchstr*"
	if [string match $matchstr $str] {
		return 1
	}
	set matchstr [file tail $evv(CDPGUI_DIR)]
	set matchstr "*$matchstr*"
	if [string match $matchstr $str] {
		return 1
	}
	set matchstr [file tail $evv(PATCH_DIRECTORY)]
	set matchstr "*$matchstr*"
	if [string match $matchstr $str] {
		return 1
	}
	set matchstr [file tail $evv(SUBPATCH_DIRECTORY)]
	set matchstr "*$matchstr*"
	if [string match $matchstr $str] {
		return 1
	}
	set matchstr [file tail $evv(INS_DIR)]
	set matchstr "*$matchstr*"
	if [string match $matchstr $str] {
		return 1
	}
	set matchstr [file tail $evv(MACRO_DIR)]
	set matchstr "*$matchstr*"
	if [string match $matchstr $str] {
		return 1
	}
	set matchstr [file tail $evv(URES_DIR)]
	set matchstr "*$matchstr*"
	if [string match $matchstr $str] {
		return 1
	}
	set matchstr [file tail $evv(LOGDIR)]
	set matchstr "*$matchstr*"
	if [string match $matchstr $str] {
		return 1
	}
	if {$private} {
		if {[info exists private_directories]} {
			foreach matchstr $private_directories {
				if [string match $matchstr* $str] {
					return 1
				}
			}
		}
	}
	return 0
}

#------ Temporarily  stall user intervention in an inconspicuous way

proc NuBlock {} {
	global pr_nublock is_blocked evv
	set f .nublocker														

	if [Dlg_Create $f "FILE TYPE" "set pr_nublock 1" -borderwidth 10 -height 0 -width 60] {  ;#	IF NO BLOCKER EXISTS
		frame $f.f -height 1 -width 60
		pack propagate $f.f false
		pack $f.f -side top -fill x -expand true
		wm resizable $f 1 1
	}
	set pr_nublock 0
 	Simple_Grab 1 $f pr_nublock											;#	Grab Focus for blocking message
}

#------ Re-enable user intervention after a NuBlock

proc UnNuBlock {} {
	global blocker message_stack message_maxindex is_blocked
	destroy .nublocker
}

#------ Display value to N decimal places

proc DisplayToDecPlace {val places} {

	set k [string first "." $val]
	if {$k < 0} {
		append val "."
		set n 0
		while {$n < $places} {
			append val "0"
			incr n
		}
		return $val
	}
	incr k
	if {$k == [string length $val]} {
		set n 0
		while {$n < $places} {
			append val "0"
			incr n
		}
		return $val
	}
	set j [string length [string range $val $k end]]
	if {$j <= $places} {
		incr places -$j
		set n 0
		while {$n < $places} {
			append val "0"
			incr n
		}
		return $val
	}
	set val [string range $val 0 [expr $k + $places - 1]]
	return $val
}

#----- USe NAME of program to extract FIRST NUMBER in version number string

proc GetVersion {progname} {
	global evv CDPmaxId done_version prog_version
	catch {unset prog_version}
	set done_version 0
	set cmd [file join $evv(CDPROGRAM_DIR) $progname]
	lappend cmd "--version"
	if [catch {open "|$cmd"} CDPmaxId] {
		return
	} else {
	   	fileevent $CDPmaxId readable "Get_Version"
	}
	vwait done_version
	if {[info exists prog_version]} {
		set prog_version [split $prog_version "."]
		set prog_version [lindex $prog_version 0]
		if {![regexp {^[0-9]+$} $prog_version]} {
			set prog_version 0
		}
	} else {
		set prog_version 0
	}
	return $prog_version
}

proc Get_Version {} {
	global CDPmaxId done_version prog_version
	if [eof $CDPmaxId] {
		catch {close $CDPmaxId}
		set done_version 1
		return
	} else {
		gets $CDPmaxId line
		set line [string trim $line]
		if {[string length $line] <= 0} {
			return
		}
		set prog_version $line
		catch {close $CDPmaxId}
		set done_version 1
		return
	}
	update idletasks
}			

#----- USe NUMBER of program to extract THE ENTIRE version number string

proc GetVersionNumber {ppg} {
	global prg evv CDPid gotvers versno
	set gotvers 0
	set versno 0.0.0
	set cmd [file join $evv(CDPROGRAM_DIR) [lindex $prg($ppg) 0]]
	append cmd $evv(EXEC)
	lappend cmd "--version"
	if [catch {open "|$cmd"} CDPid] {
		ErrShow "CANNOT FIND PROGRAM VERSION NUMBER"
		return $versno
	} else {
		fileevent $CDPid readable GetVers
		if {!$gotvers} {
			vwait gotvers
		}
	}
	return $versno
}

proc GetVers {} {
	global CDPid gotvers versno
	if [eof $CDPid] {
		set gotvers 1
		catch {close $CDPid}
		return
	} else {
		while {[gets $CDPid line] >= 0} {
			set line [string trim $line]
			set thislen [string length $line]
			if {$thislen > 0} {
				set versno $line
				set gotvers 1
				catch {close $CDPid}
				return
			}
		}
	}
}			

proc VersionExceeds {baseversion thisversion} {

	set baseversion [split $baseversion "."]
	set thisversion [split $thisversion "."]
	if {[lindex $thisversion 0] > [lindex $baseversion 0]} {
		return 1
	}
	if {[lindex $thisversion 0] == [lindex $baseversion 0]} {
		if {[lindex $thisversion 1] > [lindex $baseversion 1]} {
			return 1
		}
		if {[lindex $thisversion 1] == [lindex $baseversion 1]} {
			if {[lindex $thisversion 2] > [lindex $baseversion 2]} {
				return 1
			}
		}
	}
	return 0
}

#----- Setup List of Windows with

proc SetupMacFix {} {
	global macfix
	lappend macfix ".inspage"
	lappend macfix ".menupage"
	lappend macfix ".ppg"
	lappend macfix ".running"
	lappend macfix ".workspace"
	lappend macfix ".mixdisplay2"
}	

#---- Reset Button State on MAC windows, when they return to top

proc ResetButtonState {top thiswindow up} {
    return
	global pr_macfix wstk is_terminating macfix refrwksp
	if {[info exists is_terminating] && $is_terminating} {
		return
	}
	if {![info exists macfix]} {
		return
	}
	if {([lsearch $macfix $top] < 0) && ([lsearch $macfix $thiswindow] < 0)} {	;#	Only check major windows
		return
	}
	if {($thiswindow == ".mixdisplay2") && ($top != ".snack")} {					;# Syncing lines on Qikedit, via Snack
		return
	}
	if {$up} {
		if {$top == ".running"} {
			return
		}
	} elseif {($top == ".blocker") && ($thiswindow == ".workspace")} {	;# After chosen-files check, go direct to process-page
		if {[info exists refrwksp]} {									;# After Refreshing Workspace, need to ResetButtons	
			unset refrwksp
		} else {
			return
		}
	} elseif {$top == ".snmix"} {
		if {($thiswindow == ".workspace") || ($thiswindow == ".ppg")} {	;# After selecting file to view, go direct to sview-page
			return
		}
	}
	set f .macfix
	set pr_macfix 0
	set callcentre [GetCentre [lindex $wstk end]]
	if [Dlg_Create $f "" "set pr_macfix 0" -height 3] {
		button $f.ok -text "Hit \"Return\" or \"Escape\"" -command "set pr_macfix 0" -highlightbackground [option get . background {}]
		pack $f.ok -side top
		bind $f <Return> "set pr_macfix 0"
		bind $f <Escape> "set pr_macfix 0"
	}
	set oldbinde [bind $thiswindow <Escape>]
	set oldbindr [bind $thiswindow <Return>]
	bind $thiswindow <Return> "set pr_macfix 0"	;#	Forces window-being-returned-to to act on macfix window
	bind $thiswindow <Escape> "set pr_macfix 0"
	raise $f
	update idletasks
	set geo [CentreOnCallingWindow $f $callcentre]
	Simple_Grab 0 $f pr_macfix
	wm geometry $f $geo
	tkwait variable pr_macfix
	Simple_Release_to_Dialog $f
	bind $thiswindow <Escape> $oldbinde			;#	Restores bindings of window-being-returned-to
	bind $thiswindow <Return> $oldbindr			;#	Restores bindings of window-being-returned-to
	destroy $f
}
