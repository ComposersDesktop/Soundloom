#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD 30 June 2013
# ... fixup button rectangles

##########################################
# RUNNING PROCESS or INSTRUMENT: DISPLAY #
##########################################

#------ Running program or ins display page
#
#	 ----------------------------------------------------------------------
#	|				    PROGRAM-NAME or INSTRUMENT_NAME					   |
#	|----------------------------------------------------------------------|
#	|																	   |
#	| Info displayed in black											   |
#	| Warnings displayed in blue										   |
#	| Errors displayed in red											   |
#	|																	   |
#	|~~~~~~~~---~~~~~~~~---~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|-----|
#	|Process| N |Out of| C |\\\\\\\\B\\\\\\\\\\\|				   	 |ABORT| THIS LINE OMITTED IN USAGE-ONLY MODE
#	|~~~~~~~~---~~~~~~~~---~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|-----|
#	  N = No. of processes (ins only)
#	  C = Process Counter (ins only)
#	  B = Progres Bar
#

proc Create_Running_Process_Display {} {
	global running running_program_title ins rundisplay bulk ref evv readonlyfg readonlybg

	set f .running
	eval {toplevel $f} -borderwidth $evv(SBDR)
	wm protocol $f WM_DELETE_WINDOW "VerySeriousTermination $f"
#	wm resizable $f 0 0
	if {$ins(run)} {													;#	Window title
		set ins_title [string toupper $ins(name)]
		wm title $f "Running $ins_title"
	} else {
		GetProgramName
		wm title $f "Running $running_program_title"
	}

	set ft [frame $f.t -borderwidth $evv(BBDR)]						;#	Frame for start button 
	set fi [frame $f.i -borderwidth $evv(BBDR)]						;#	Frame for info box 
	set fd [frame $f.d -height $evv(PBAR_SEPARATOR_HEIGHT)]		 			;#	Dividing line
	set fp [frame $f.p -borderwidth $evv(BBDR)]						;#	frame for progress-bar
																			
	pack $f.t $f.i $f.d $f.p -side top -fill x

	if {$evv(NEWUSER_HELP)} {
		button $ft.starthelp -text "New User Help" -command "GetNewUserHelp run"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
	}
	button $ft.ok  -text "Run" -command "DoRun $f" -bg $evv(EMPH) -highlightbackground [option get . background {}]
	button $ft.ksh -text "K" -bg $evv(HELP) -command "Shortcuts run" -width 2 -highlightbackground [option get . background {}]
	button $ft.sv  -text "" -width 8 -command "SaveRunMessages $f" -bg [option get . background {}] -bd 0 -highlightbackground [option get . background {}]
# JUNE 2000
 	button $ft.ref -text "" -width 42 -state disabled -bd 0 -command "RefStore run" -highlightbackground [option get . background {}]
	entry  $ft.ree -textvariable ref(text) -width 32 -state readonly -borderwidth 0 -readonlybackground [option get . background {}]
 	button $ft.okk -text "" -width 4 -command {} -state disabled -bd 0 -highlightbackground [option get . background {}]
 	button $ft.no -text "" -width 4 -command {} -state disabled -bd 0 -highlightbackground [option get . background {}]

	if {$evv(NEWUSER_HELP)} {
		pack $ft.starthelp -side right
	}
	pack $ft.ok $ft.ref $ft.ree $ft.okk $ft.no -side left
	pack $ft.ksh $ft.sv -side right
																				;#	INFOBOX DETAILS
	set t [text $fi.info -setgrid true -wrap word -width 120 -height 24 \
											-yscrollcommand "$fi.sy set"]
	$t tag configure warning -foreground $evv(WARN_COLR)   			;#	Text-colors for various messagetypes
	$t tag configure error   -foreground $evv(ERR_COLR) -background $evv(EMPH)
	$t tag configure info    -foreground $evv(INF_COLR)
	scrollbar $fi.sy -orient vertical -command "$fi.info yview"
	pack $fi.sy -side right -fill y
	pack $fi.info -side left -fill both -expand true	
	if {$ins(run) || $bulk(run)} {
		set fpc [frame $fp.cnt -borderwidth $evv(BBDR)]				;#	Frame for cnt of completed processes
	}
	frame $fp.sbar -borderwidth $evv(SBDR) -width $evv(PBAR_ENDSIZE) -height 2 \
			-bg $evv(PBAR_ENDCOLOR)		;#	Frame for start of progress-bar
	set fpb [frame $fp.bar -borderwidth $evv(BBDR) -width $evv(PBAR_LENGTH) -height 2 \
			-bg $evv(PBAR_NOTDONECOLOR)]
	frame $fp.ebar -borderwidth $evv(BBDR) -width $evv(PBAR_ENDSIZE) -height 2 \
			 -bg $evv(PBAR_ENDCOLOR)				;#	Frame for end of progress-bar

	button $fp.abort -text "Abort" -command "VerySeriousTermination $f" -highlightbackground [option get . background {}]
	label $fp.abortlab -text "If program CRASHES,\nuse ABORT (and NOT 'OK')"

	if {$ins(run) || $bulk(run)} {
		grid $fp.cnt $fp.sbar $fp.bar $fp.ebar $fp.abort $fp.abortlab
		grid $fp.sbar -sticky ns
		grid $fp.ebar -sticky ns
		grid $fp.bar -sticky ns
		if {$ins(run)} {
			entry $fpc.e0 -textvariable rundisplay(processnm) -width 20 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		}
		label $fpc.lab1 -text "Process"										;#	Display process-cnt for ins
		entry $fpc.e1 -textvariable rundisplay(processno) -width 3 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $fpc.lab2 -text "Out of"
		entry $fpc.e2 -textvariable ins(process_length) -width 3 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		if {$ins(run)} {
			grid $fpc.e0 $fpc.lab1 $fpc.e1 $fpc.lab2 $fpc.e2
		} else {
			grid $fpc.lab1 $fpc.e1 $fpc.lab2 $fpc.e2
		}
	} else {
		grid $fp.sbar $fp.bar $fp.ebar $fp.abort $fp.abortlab
		grid $fp.sbar -sticky ns
		grid $fp.ebar -sticky ns
		grid $fp.bar -sticky ns
	}
	set i 0
	set rundisplay(done) [frame $fpb.done -width 0 -height $evv(PBAR_HEIGHT) \
				-bg $evv(PBAR_DONECOLOR) -borderwidth 0]
	if {$ins(run) || $bulk(run)} {
		ForceVal .running.p.cnt.e1 ""
	}
	if {$ins(run)} {
		ForceVal .running.p.cnt.e0 ""
	}
	pack propagate $fpb false
	pack $fpb.done -side left	;#	ProgessBar, fixed to left,and fills height of frame
	bind .running <Return> "KeyRun .running.t.ok"
	bind .running <Escape> "VerySeriousTermination .running"
	return $f
}

#------ Get progname associated with menu

proc GetProgramName {} {
	global evv prg pprg mmod running_program_title

	if [IsMchanToolkit $pprg] {
		set running_program_title [MchanToolKitNames $pprg]
	} else {
		set running_program_title [lindex $prg($pprg) $evv(UMBREL_INDX)]
		set running_program_title [concat [string toupper $running_program_title] " " [lindex $prg($pprg) $evv(PROGNAME_INDEX)]]
		set modecnt [lindex $prg($pprg) $evv(MODECNT_INDEX)]
		if {$modecnt > 0} {
			set i $evv(MODECNT_INDEX)
			incr i $mmod
			set running_program_title [concat $running_program_title ":" [lindex $prg($pprg) $i]]
		}
	}
	return
}

#------ Set progress-bar to zero, for next process

proc ResetProgressBar {} {
	global rundisplay
	$rundisplay(done) config -width 0
}

#------ Terminating a CDP process or ins

proc VerySeriousTermination {rpd} {
	global CDPidrun ins prg_abortd prg_dun after_error ins evv
	 
	.running.i.info insert end "TERMINATING THE PROCESS: Please wait.\n" {error}
	if [string match $evv(SYSTEM) "MAC"] {
		.running.i.info insert end "\n" {warning}
		.running.i.info insert end "IF PROCESS FAILS TO END SOON\n" {warning}
		.running.i.info insert end "You Should Stop The CDP Program That Is Running\n" {error}
		.running.i.info insert end "By Going To The 'APPLE' Menu, And Selecting 'FORCE QUIT',\n" {error}
		.running.i.info insert end "Then Selecting The Current CDP Process From The List Which Appears.\n" {warning}
		.running.i.info insert end "\n" {warning}
		.running.i.info insert end "No Data Will Be Lost (Apart From The File Being Created).\n" {warning}
		.running.i.info insert end "\n" {warning}
		.running.i.info insert end "You Should Then Click On The 'ABORT' Button\n" {error}
		.running.i.info insert end "Which should return you to the Parameters Page\n" {warning}
		.running.i.info insert end "\n" {warning}
		.running.i.info insert end "IF ALL ELSE FAILS You Should Stop The Sound Loom, In The Same Manner\n" {error}
		.running.i.info insert end "Selecting The 'WISH' Program To Be Terminated.\n" {error}
		.running.i.info insert end "\n" {error}
		.running.i.info insert end "You Can Then  Restart The Soundloom.\n" {warning}

	}
	update idletasks
	if {![catch {pid $CDPidrun} pids]} {
		foreach pid $pids {
			catch {exec $killcmd $pid}				;#	Terminate any processes associated with the pipe
		}
	}
	if [info exists CDPidrun] {
		catch {close $CDPidrun}
		catch {unset CDPidrun}
	}
	set prg_abortd 1
	set prg_dun 0
	My_Release_to_Dialog $rpd
	destroy $rpd
}

#------

proc SaveRunMessages {f} {
	global pprg evv

	if {$pprg == $evv(INFO_MAXSAMP)} {
		set istime 0
		foreach word [$f.i.info get 1.0 end] {
			if {[string match $word "time:"]} {
				set istime 1
			} elseif {$istime} {
				if {[IsNumeric $word]} {
					set time [ConvDurToHrs $word]
					Inf "$time"
					break
				}
			}
		}
		return
	}
	set fnam [file join $evv(URES_DIR) $evv(RUNMSGS)$evv(CDP_EXT)]
	if [catch {open $fnam "w"} fId] {
		Inf "Cannot open file '$evv(RUNMSGS)' to save data"
		return
	}
	puts $fId [$f.i.info get 1.0 end]
	catch {close $fId}
	Inf "Run information is in the file\n\n'$evv(RUNMSGS)'\n\naccessible from 'System' menu on Workspace"
}

#---------

proc SeeRunMessages {} {
	global pr_runmsg sl_real evv

	if {!$sl_real} {
		Inf "Display The Information Shown In The Run-window\nOf The Last Process You Ran"
		return
	}

	set fnam [file join $evv(URES_DIR) $evv(RUNMSGS)$evv(CDP_EXT)]
	if {![file exists $fnam]} {
		Inf "No information on previous process runs"
		return
	}
	if [catch {open $fnam "r"} fId] {
		Inf "Cannot open file '$evv(RUNMSGS)' to read data"
		return
	}
	set f .runmsg
	eval {toplevel $f} -borderwidth $evv(BBDR)
	wm protocol $f WM_DELETE_WINDOW {set pr_runmsg 1}
#	wm resizable $f 0 0
	wm title $f "Messages from Last Process Run"

	set head [frame $f.head -borderwidth $evv(BBDR)]
	button $head.qu	 -text "OK" -command "set pr_runmsg 1" -highlightbackground [option get . background {}]
	pack $head.qu -side top
	pack $f.head -side top
	set prev [frame $f.prev -borderwidth $evv(BBDR)]
	pack $f.prev -side left -fill both

	label  $prev.lab -text "WARNING: THIS MESSAGE IS THE LAST RUN-INFO you SAVED\ni.e. not necessarily info from the last run you MADE" -width 17 -justify center  -fg $evv(SPECIAL)

	set ll [Scrolled_Listbox $prev.ll -width 24 -height 20 -selectmode single]

	set t [text $prev.info -setgrid true -wrap word -width 120 -height 24 \
											-yscrollcommand "$prev.sy set"]
	scrollbar $prev.sy -orient vertical -command "$prev.info yview"
	pack $prev.sy -side right -fill y
	pack $prev.info -side left -fill both -expand true	

	set qq 0
	while {[gets $fId line] >= 0} {
		if {$qq > 0} {
			$prev.info insert end "\n"
		}
		$prev.info insert end "$line"
		incr qq
	}
	catch {close $fId}
	set pr_runmsg 0
	raise $f
	My_Grab 0 $f pr_runmsg
	tkwait variable pr_runmsg
	My_Release_to_Dialog $f
	destroy $f
}
