#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD 30 June 2013
# ... fixup button rectangles

#	
# Box drawing works
#
# STILL TO DO
#
# Specify start and end times of anal display (via zoom??)
# SONOGRAM display!! AND grab FROM IT
#
# Zoom in to certain range of channels ***
#
# Tidy up all buttons etc.
#
# Needs coordinates (time, channels shown) on the display ?? (or on any box)
#

set evv(PLAY_MAXSAMP) 32768

set evv(PLAY_WIDTH) 900
set evv(PLAY_HEIGHT) 300
set evv(HALF_PLAY_HEIGHT) 150
set evv(PLAY_DISPLAY_MAX) [expr $evv(PLAY_WIDTH) - 1]
set evv(AXIS_MONO) 128

#set evv(AXIS_STEREO1) 64
#set evv(AXIS_STEREO2) 216

set evv(AXIS_STEREO1) 70
set evv(AXIS_STEREO2) 222

set evv(PLAY_MONO_MAX) 128
set evv(PLAY_STEREO_MAX) 64
set evv(PLAY_ZOOMIN) .25
set evv(PLAY_ZOOMOUT) 4

set evv(STERE01_EDGE) [expr $evv(PLAY_STEREO_MAX) + $evv(AXIS_STEREO1)]
set evv(STERE02_EDGE) [expr $evv(PLAY_STEREO_MAX) + $evv(AXIS_STEREO2)]

set evv(PLAY_BOXTOP) 10
set evv(PLAY_BOXBOT) 290

set evv(MONO_PLAY_HEIGHT) [expr $evv(AXIS_MONO) * 2]

set evv(PW_DFLT_EXP) 1.585

set evv(PW_LINGER) 0.2
set evv(PW_TURN) .117647

set evv(COLOR_SPECTRUM) 45

set evv(SONOGRAM_BKGD) white
set evv(SONOGRAM_FGD) DarkBlue

proc PlayWindow {} {
	global playw playc pr_playw playwsplice pwdataname playwsvalk playwevalk pwtimetyp wl pw_p pa wplaylen evv
	global pwseensampstart pwseensampend pwseensampdur 
	global pwseentimestart pwseentimeend pwseentimedur
	global pwmarksampstart pwmarksampend pwmarksampdur 
	global pwmarktimestart pwmarktimeend pwmarktimedur 
	global  pwtotalsamps pwtotaltime true_play_width pwsrate pwdur pwscalefact
	global maxpw storepw chanspw pwfnam pwvalscale pwsampval
	global pwslider pwtime pwismarked pwkeepwhole pwcutname pwlastaction
	global pwoutfnam pwoutfnam2 pwdisplaydata pwexp pwlastx pwfull pwstchan readonlyfg readonlybg

	set pwdataname "_temp"
	set pwcutname ""
	set pwlastaction ""

	set pwoutfnam $evv(DFLT_OUTNAME)
	append pwoutfnam 0 $evv(SNDFILE_EXT)
	set pwoutfnam2 $evv(DFLT_OUTNAME)
	append pwoutfnam2 1 $evv(SNDFILE_EXT)
	set pwdisplaydata $evv(DFLT_OUTNAME)
	append pwdisplaydata 00 $evv(TEXT_EXT)

	set pwscalefact 1
	set pwismarked 0
	catch {file delete $pwdisplaydata}

	set ilist [$wl curselection]
	if {![info exists ilist] || ([llength $ilist] <= 0)} {
		Inf "No File Selected"
		return
	}
	if {[llength $ilist] > 1} {
		Inf "Select Just One File"
		return
	}
	set pwfnam [$wl get [lindex $ilist 0]]
	if {![info exists pa($pwfnam,$evv(FTYP))]} {
		Inf "Cannot Retrieve Information About File '$pwfnam'"
		return
	}
	set ftyp $pa($pwfnam,$evv(FTYP))
	if {$ftyp != $evv(SNDFILE)} {
		Inf "File '$pwfnam' Is Not A Soundfile"
		return
	}
	if {[info exists pwfull] && ($pwfull != 1)} {
		destroy .playwindow
	}
	set pwfull 1
	Block "Creating Display Files"
	UnBlock
	set f .playwindow
	if [Dlg_Create $f "Select and Play" "set pr_playw 0" -borderwidth $evv(BBDR) -width $evv(PLAY_WIDTH)] {
		set fb [frame $f.button -borderwidth $evv(SBDR)]		;#	frame for buttons
		set fc [frame $f.canvas -borderwidth $evv(SBDR)]		;#	frame for canvas
		set fd [frame $f.info -borderwidth $evv(SBDR)]		;#	frame for info
		set fb0 [frame $fb.0 -borderwidth $evv(SBDR)]
		set fb0a [frame $fb.0a -bg [option get . foreground {}] -height 1]
		set fb1 [frame $fb.1 -borderwidth $evv(SBDR)]
		set fb1a [frame $fb.1a -bg [option get . foreground {}] -height 1]
		set fb2 [frame $fb.2 -borderwidth $evv(SBDR)]
		set fb3 [frame $fb.3 -bg [option get . foreground {}] -height 1]
		set fb4 [frame $fb.4 -borderwidth $evv(SBDR)]
		set fb5 [frame $fb.5 -bg [option get . foreground {}] -height 1]
		label  $fb0.view -text "VIEW: " -fg $evv(SPECIAL)
		button $fb0.zoom -text "Zoom in" -command {set pr_playw [ZoomIn]} -width 8 -highlightbackground [option get . background {}]
		button $fb0.zomo -text "Zoom out" -command {set pr_playw [ZoomOut]}  -width 8 -highlightbackground [option get . background {}]
		button $fb0.full -text "Full view" -command {set pr_playw [FullView 0]}  -width 8 -highlightbackground [option get . background {}]
		button $fb0.samp -text "Samples" -command {set pr_playw [SampleView]}  -width 8 -highlightbackground [option get . background {}]
		button $fb0.mag -text "Magnify" -command PwMagnify  -width 8 -highlightbackground [option get . background {}]	
		label $fb0.svl  -text "Val"
		entry  $fb0.sval -textvariable pwsampval -width 7 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label  $fb0.svs  -text "Sample" 
		entry  $fb0.svas -textvariable pwsamptime -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg 
		frame  $fb0.svt
		label  $fb0.svt.1  -text "Time in Sound  " 
		label  $fb0.svt.2  -text "Time in Display" 
		pack $fb0.svt.1 $fb0.svt.2
		frame $fb0.svat
		entry  $fb0.svat.1 -textvariable pwsampsecs -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		entry  $fb0.svat.2 -textvariable pwdispsecs -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $fb0.svat.1 $fb0.svat.2 -side top
		label  $fb0.svc  -text "Chan" 
		entry  $fb0.svac -textvariable pwstchan -width 2 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		button $fb0.sfwd -text "->F" -command {TellSampStep 1} -highlightbackground [option get . background {}]
		button $fb0.sbak -text "<-B" -command {TellSampStep -1} -highlightbackground [option get . background {}]
		button $fb0.quit -text Close -command "set pr_playw 0" -bg $evv(EMPH) -highlightbackground [option get . background {}]

		menubutton $fb0.mark -text "Mark" -menu $fb0.mark.menu -relief raised -width 8
		set sv [menu $fb0.mark.menu -tearoff 0]
		$sv add command -label "SET MARK" -command {} -foreground black
		$sv add separator
		$sv add command -label "...At Value In Reference Table" -command {RefGet pview} -foreground black
		$sv add separator
		$sv add command -label "...At Given Time in Sound" -command {PwMarkAt 0} -foreground black
		$sv add command -label "...At Given Time from Display Start" -command {PwMarkAt 1} -foreground black
		$sv add separator
		$sv add command -label "...At Maximum Value In Display" -command {PwMarktoMax} -foreground black
		$sv add command -label "...At Selection Box Start" -command {PwMarktoBox 0} -foreground black
		$sv add command -label "...At Selection Box End" -command {PwMarktoBox 1} -foreground black
		$sv add separator
		$sv add command -label "MOVE MARK" -command {} -foreground black
		$sv add separator
		$sv add command -label "One Value -> (Keyboard 'f')" -command {SampStep 1} -foreground black
		$sv add command -label "One Value <- (Keyboard 'f')" -command {SampStep -1} -foreground black
		$sv add separator
		$sv add command -label "MOVE DISPLAY" -command {} -foreground black
		$sv add separator
		$sv add command -label "Move Display-start to Mark" -command {PwPushSeen 0}   -foreground black
		$sv add command -label "Move Display-end to Mark" -command {PwPushSeen 1}   -foreground black
		$sv add separator
		$sv add command -label "EXPAND DISPLAY" -command {}  -foreground black
		$sv add separator
		$sv add command -label "...to Start At Mark" -command {set pr_play [PwExpandtoMark 0]} -foreground black
		$sv add command -label "...to End At Mark" -command {set pr_play [PwExpandtoMark 1]} -foreground black
		$sv add separator
		$sv add command -label "MARK:       Mouse-Click" -command {} -foreground $evv(SPECIAL)
		$sv add command -label "SCROLL:  Mouse-Drag" -command {} -foreground $evv(SPECIAL)
		$sv add command -label "REMOVE:  Control-Mouse-Click" -command {} -foreground $evv(SPECIAL)
		$sv add separator
		$sv add command -label "STEREO: click near channel wanted." -command {} -foreground $evv(SPECIAL)
		$sv add command -label "Except at sample scale, vals are AVERAGES." -command {} -foreground $evv(SPECIAL)

		pack $fb0.view \
			$fb0.zoom $fb0.zomo $fb0.full $fb0.samp $fb0.mag $fb0.mark \
			 $fb0.svl $fb0.sval $fb0.svs $fb0.svas $fb0.svt $fb0.svat $fb0.svc $fb0.svac $fb0.sfwd $fb0.sbak -side left -padx 2
		pack $fb0.quit -side right -padx 1

		label $fb1.cutlb0  -text "EDIT:" -fg $evv(SPECIAL)
		frame $fb1.x
		radiobutton $fb1.x.mrk -variable pwkeepwhole -text "Selected" -value 0 
		radiobutton $fb1.x.whl -variable pwkeepwhole -text "Whole     " -value 1
		pack $fb1.x.mrk $fb1.x.whl -side top
		button $fb1.play -text Play -command "PwAction play" -bg $evv(EMPH) -fg $evv(SPECIAL) -width 5 -height 2 -highlightbackground [option get . background {}]
		button $fb1.cut -text "CutKeep" -width 6 -command {PwAction edit} -highlightbackground [option get . background {}]
		frame $fb1.y
		button $fb1.y.exc -text "Excise" -width 4 -command {PwAction excise} -highlightbackground [option get . background {}]
		button $fb1.y.sil -text "Mask" -width 4 -command {PwAction mask} -highlightbackground [option get . background {}]
		pack $fb1.y.exc $fb1.y.sil
		label  $fb1.splv -text "Splice\n(ms)"
		entry  $fb1.splic -textvariable playwsplice -width 5

		button $fb1.zero -text "CutZero" -command {PwAction zerocut} -width 6 -highlightbackground [option get . background {}]
		button $fb1.dove -text "Dovetail" -command {PwAction dovetail} -width 6 -highlightbackground [option get . background {}]
		button $fb1.cur  -text "Curtail" -command {PwAction curtail} -width 6 -highlightbackground [option get . background {}]
		frame $fb1.z
		frame $fb1.z.a
		radiobutton $fb1.z.a.lin -variable pwexp -text "lin" -value 0
		radiobutton $fb1.z.a.exp -variable pwexp -text "exp" -value 1
		radiobutton $fb1.z.dbl -variable pwexp -text "double exp  " -value 2
		pack $fb1.z.a.lin $fb1.z.a.exp -side left
		pack $fb1.z.a $fb1.z.dbl -side top
		button $fb1.plo	-text "PlayOut"   -command PwPlayOutput -width 6 -highlightbackground [option get . background {}]
		button $fb1.snd	-text "SaveSnd"	   -command PwSaveSnd -width 6 -highlightbackground [option get . background {}]
		button $fb1.rec	-text "Recycle" -command PwRecycleSnd -width 6 -highlightbackground [option get . background {}]
		label  $fb1.nm    -text "Sound\nFilename"
		entry  $fb1.name  -textvariable pwcutname -width 16

		pack $fb1.cutlb0  $fb1.x $fb1.play $fb1.cut $fb1.y $fb1.splv $fb1.splic -side left -padx 2
		pack $fb1.zero $fb1.dove $fb1.cur $fb1.z -side left -padx 2
		pack $fb1.name $fb1.nm $fb1.rec $fb1.snd $fb1.plo -side right -padx 2

		label  $fb2.sel1 -text "KEEP\nDATA: " -fg $evv(SPECIAL)
		radiobutton $fb2.mrk -variable pwkeepwhole -text "Marked\nSegment" -value 0 
		radiobutton $fb2.whl -variable pwkeepwhole -text "Whole\nDisplay" -value 1
		checkbutton $fb2.sval -variable playwsvalk -text "Start"
		checkbutton $fb2.eval -variable playwevalk -text "End"
		radiobutton $fb2.ip -variable pwkeepwhole -text "Single\nPoint" -value 2 -command No_Ends
		label $fb2.kp -text "SAVE AS"
		radiobutton $fb2.gsamp -variable pwtimetyp -text "Samples" -value 0
		radiobutton $fb2.time  -variable pwtimetyp -text "Secs" -value 1
		button $fb2.nf -text "SaveData" -command {PwSave 0 0 0} -width 6 -highlightbackground [option get . background {}]
		button $fb2.af -text "AddToFile" -command {PwSave 1 0 0} -width 7 -highlightbackground [option get . background {}]
		button $fb2.ef -text "EditData" -command {PwDataEdit} -width 6 -highlightbackground [option get . background {}]

		label  $fb2.nm    -text "Data\nFilename"
		frame $fb2.zz
		entry  $fb2.zz.name  -textvariable pwdataname -width 16
		menubutton $fb2.zz.standard -text "Standard" -menu $fb2.zz.standard.menu -relief raised -borderwidth 2 -width 10
		set s [menu $fb2.zz.standard.menu -tearoff 0]
		MakeStandardNamesMenu $s $f.button.2.zz.name 0
		pack $fb2.zz.name $fb2.zz.standard -side top -pady 1
		pack $fb2.sel1 $fb2.mrk $fb2.whl $fb2.sval $fb2.eval $fb2.ip $fb2.kp $fb2.time $fb2.gsamp -side left -padx 2
		pack $fb2.zz $fb2.nm $fb2.ef $fb2.af $fb2.nf -side right -padx 2

		label  $fb4.move -text "MOVE: " -fg $evv(SPECIAL)
		button $fb4.next -text "Forward" -command {set pr_playw [NextPwBlock forward]}  -width 8 -highlightbackground [option get . background {}]
		button $fb4.last -text "Back" -command {set pr_playw [NextPwBlock back]}  -width 8 -highlightbackground [option get . background {}]
		button $fb4.stt -text "To Start" -command {set pr_playw [NextPwBlock start]}  -width 8 -highlightbackground [option get . background {}]
		button $fb4.end -text "To End" -command {set pr_playw [NextPwBlock end]}  -width 8 -highlightbackground [option get . background {}]
		button $fb4.goto -text "Go To" -command PwGoto -width 5 -highlightbackground [option get . background {}]
		menubutton $fb4.info -text Info -menu $fb4.info.menu -relief raised -width 6 ;# -background $evv(HELP)
		set m [menu $fb4.info.menu -tearoff 0]
		$m add command -label "EDITING PROCESSES" -command {} -foreground black
		$m add separator ;# -background $evv(HELP)
		$m add command -label "Cut & Keep:           Retains marked area only" -command {} -foreground black
		$m add separator
		$m add command -label "Excise:                  Deletes the marked area" -command {} -foreground black
		$m add separator
		$m add command -label "Mask:                     Replaces masked area by silence" -command {} -foreground black
		$m add separator
		$m add command -label "Cut At Zeros:" -command {} -foreground black
		$m add command -label "   Retains marked area only, cutting at zero-crossings" -command {} -foreground black
		$m add command -label "   Mono files only." -command {} -foreground $evv(SPECIAL)
		$m add separator
		$m add command -label "Dovetail To Box:" -command {} -foreground black
		$m add command -label "   Fade in from sound's start to marked area start" -command {} -foreground black
		$m add command -label "   & fade out from marked area end to sound's end" -command {} -foreground black
		$m add command -label "   LIN: linear fades           EXP: exponential fades" -command {} -foreground $evv(SPECIAL)
		$m add separator
		$m add command -label "Curtail On Box:" -command {} -foreground black
		$m add command -label "   Fade out from start of marked area to its end." -command {} -foreground black
		$m add command -label "   LIN: linear fade             EXP: exponential fade" -command {} -foreground $evv(SPECIAL)


		menubutton $fb4.box -text "Select" -menu $fb4.box.menu -relief raised -width 8
		set sb [menu $fb4.box.menu -tearoff 0]
		$sb add command -label "Expand Box To Start Of Display" -command {PwPushBox 0} -foreground black
		$sb add separator
		$sb add command -label "Expand Box To End Of Display" -command {PwPushBox 1} -foreground black
		$sb add separator
		$sb add command -label "Expand Box To Mark" -command {PwBoxtoMark} -foreground black
		$sb add separator
		$sb add command -label "Cut Off Box After Mark" -command {PwBoxCut 0} -foreground black
		$sb add separator
		$sb add command -label "Cut Off Box Before Mark" -command {PwBoxCut 1} -foreground black
		$sb add separator
		$sb add command -label "Select All File Before Box" -command {PwBoxNot 0} -foreground black
		$sb add separator
		$sb add command -label "Select All File After Box" -command {PwBoxNot 1} -foreground black
		$sb add separator
		$sb add command -label "SELECT A BOX:         Shift-Mouse-Drag" -command {} -foreground $evv(SPECIAL)
		$sb add command -label "REMOVE A BOX:       Control-Shift-Mouse-Click" -command {} -foreground $evv(SPECIAL)

		label $fb4.lab -text Time
		entry $fb4.time -textvariable pwtime -width 12
		label $fb4.0 -text "0"
		set pwslider [PwMakeScale $fb4.slid]
		label $fb4.r -text "" -width 9
		pack $fb4.move $fb4.next $fb4.last $fb4.stt $fb4.end -side left -padx 2
		pack $fb4.goto $fb4.lab $fb4.time $fb4.0 $pwslider $fb4.r $fb4.box $fb4.info -side left -padx 2


		set playc [Sound_Canvas $fc.c -width $evv(PLAY_WIDTH) -height $evv(PLAY_HEIGHT) \
									-scrollregion "0 0 $evv(PLAY_WIDTH) $evv(SCROLL_HEIGHT)"]
		pack $fc.c -side top
		set fdl [frame $fd.local -borderwidth $evv(SBDR)]
		frame $fd.dum0 -bg [option get . foreground {}] -width 1
		set fdm [frame $fd.marked -borderwidth $evv(SBDR)] 
		frame $fd.dum1 -bg [option get . foreground {}] -width 1
		set fdt [frame $fd.total -borderwidth $evv(SBDR)] 
		label $fdl.title -text "DISPLAY SEEN"
		label $fdl.subtit1 -text "In Samples"
		set fdl0 [frame $fdl.0 -borderwidth $evv(SBDR)]
		label $fdl.subtit2 -text "In Seconds"
		set fdl1 [frame $fdl.1 -borderwidth $evv(SBDR)]
		label $fdl0.lab0 -text "Start"
		entry $fdl0.e0 -textvariable pwseensampstart -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $fdl0.lab1 -text "End"
		entry $fdl0.e1 -textvariable pwseensampend -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $fdl0.lab2 -text "Duration"
		entry $fdl0.e2 -textvariable pwseensampd -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $fdl0.lab0 $fdl0.e0 $fdl0.lab1 $fdl0.e1 $fdl0.lab2 $fdl0.e2 -side left
		label $fdl1.lab0 -text "Start"
		entry $fdl1.e0 -textvariable pwseentimestart -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $fdl1.lab1 -text "End"
		entry $fdl1.e1 -textvariable pwseentimeend -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $fdl1.lab2 -text "Duration"
		entry $fdl1.e2 -textvariable pwseentimedur -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $fdl1.lab0 $fdl1.e0 $fdl1.lab1 $fdl1.e1 $fdl1.lab2 $fdl1.e2 -side left
		pack $fdl.title -side top
		pack $fdl.subtit1 $fdl0 $fdl.subtit2 $fdl1 -side top -fill x -expand true

		label $fdm.title -text "BOX SELECTED"
		label $fdm.subtit1 -text "In Samples"
		set fdm0 [frame $fdm.0 -borderwidth $evv(SBDR)]
		label $fdm.subtit2 -text "In Seconds"
		set fdm1 [frame $fdm.1 -borderwidth $evv(SBDR)]
		label $fdm0.lab0 -text "Start"
		entry $fdm0.e0 -textvariable pwmarksampstart -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $fdm0.lab1 -text "End"
		entry $fdm0.e1 -textvariable pwmarksampend -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $fdm0.lab2 -text "Duration"
		entry $fdm0.e2 -textvariable pwmarksampdur -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $fdm0.lab0 $fdm0.e0 $fdm0.lab1 $fdm0.e1 $fdm0.lab2 $fdm0.e2 -side left
		label $fdm1.lab0 -text "Start"
		entry $fdm1.e0 -textvariable pwmarktimestart -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $fdm1.lab1 -text "End"
		entry $fdm1.e1 -textvariable pwmarktimeend -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $fdm1.lab2 -text "Duration"
		entry $fdm1.e2 -textvariable pwmarktimedur -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $fdm1.lab0 $fdm1.e0 $fdm1.lab1 $fdm1.e1 $fdm1.lab2 $fdm1.e2 -side left
		pack $fdm.title -side top
		pack $fdm.subtit1 $fdm0 $fdm.subtit2 $fdm1 -side top -fill x -expand true

		label $fdt.title -text "WHOLE FILE"
		label $fdt.subtit1 -text ""
		set fdt0 [frame $fdt.0 -borderwidth $evv(SBDR)]
		label $fdt.subtit2 -text ""
		set fdt1 [frame $fdt.1 -borderwidth $evv(SBDR)]
		label $fdt0.lab -text "Total Samples"
		entry $fdt0.e -textvariable pwtotalsamps -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $fdt0.lab -side left
		pack $fdt0.e -side right
		label $fdt1.lab -text "Duration in Seconds"
		entry $fdt1.e -textvariable pwtotaltime -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $fdt1.lab -side left
		pack $fdt1.e -side right
		pack $fdt.title $fdt.subtit1 $fdt0 $fdt.subtit2 $fdt1 -side top -fill x -expand true

		pack $fd.local -side left -fill x -expand true
		pack $fd.dum0 -side left -fill y -expand true
		pack $fd.marked -side left -fill x -expand true
		pack $fd.dum1 -side left -fill y -expand true
		pack $fd.total -side left -fill x -expand true

		pack $fb0 -side top -pady 2 -fill x -expand true
		pack $fb0a -side top -pady 2 -fill x -expand true
		pack $fb4 -side top -pady 2 -fill x -expand true 
		pack $fb5 -side top -pady 2 -fill x -expand true
		pack $fb2 -side top -pady 2 -fill x -expand true
		pack $fb3 -side top -pady 2 -fill x -expand true
		pack $fb1 -side top -pady 2 -fill x -expand true
		pack $fb1a -side top -pady 2 -fill x -expand true
		pack $fb $fc $fd -side top -pady 2 -fill x -expand true
		set playwsplice 15

		bind $playc	<Shift-ButtonPress-1> 			{PwBoxBegin %x %y}
		bind $playc	<Shift-B1-Motion> 				{PwBoxDrag %x %y}
		bind $playc	<Shift-ButtonRelease-1>			{PwBoxGet}
		bind $playc	<Shift-Control-ButtonPress-1>	{DelBox; PwClearBoxTimes}
		bind $playc <ButtonPress-1>					{PwSampMark %x %y}
		bind $playc	<B1-Motion> 					{PwSampMarkDrag %x}
		bind $playc	<Control-ButtonPress-1>			{DelSampMark}
		bind $playc	<Key-space>						{PlaySndfile $pwfnam}
	
		bind $f <KeyPress> {
			if [string match {[bB]} %A] {
				SampStep -1
			} elseif [string match {[fF]} %A] {
				SampStep 1
			} 
		}
		set pwkeepwhole 1
		set pwtimetyp 1
		set playwsvalk 1
		set playwevalk 1
		bind $f <Escape> {set pr_playw 0}
	}
	wm resizable .playwindow 1 1
	wm title $f "View and Edit Sound (alt-Click on Wkspace Soundfile to launch):            $pwfnam"
	$f.button.1.plo config -bg [option get . background {}]
	set pwexp 2
	PwClearSampVals
	PwClearBoxTimes
	set pr_playw 0
	set chanspw $pa($pwfnam,$evv(CHANS))
	set pwtotaltime  $pa($pwfnam,$evv(DUR))
	switch -- $chanspw {
		1 {
			set evv(PW_FOOT) $evv(MONO_PLAY_HEIGHT)
		}
		2 {
			set evv(PW_FOOT) $evv(STERE02_EDGE)
		}
		default {
			Inf "This Function Does Not Work For File With More Than 2 Channels"
			Dlg_Dismiss $f
			return
		}
	}
	$f.button.4.r config -text $pwtotaltime
	set pwsrate $pa($pwfnam,$evv(SRATE))
	set pwtotalsamps [expr $pa($pwfnam,$evv(INSAMS)) / $pa($pwfnam,$evv(CHANS))]
	set pwdur $pa($pwfnam,$evv(DUR))

	set pwseensampstart 0
	set pwseensampend $pwtotalsamps

	if {![DisplayPwData]} {
		Dlg_Dismiss $f
		return
	}
	DisplayPwTotals

	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_playw
	while {!$finished} {
		tkwait variable pr_playw
		if {!$pr_playw} {
			break
		}
	}
	catch {file delete $pwdisplaydata}
	My_Release_to_Dialog $f
	destroy $f
}

#########################
# SPECIAL DISPLAY ITEMS #
#########################

#------ Sound Display Canvas

proc Sound_Canvas { c args } {
	global evv
	frame $c -borderwidth $evv(SBDR)
	eval {canvas $c.canvas -highlightthickness 2 -borderwidth 0} $args
	grid $c.canvas -sticky news
	return $c.canvas
}

#---- Slider

proc PwMakeScale {where} {
	global pwssss evv
	set scale_len $evv(SCALELEN)
	incr scale_len $evv(SLIDERSIZE)
	set w [canvas $where -height $evv(SLIDERSIZE) -width $scale_len -highlightthickness 0]
	$w create rect 0 0 $scale_len $evv(SLIDERSIZE) -fill [option get . troughColor {}] -tag slide
	$w create rect 0 0 $evv(SLIDERSIZE) $evv(SLIDERSIZE) -fill $evv(PBAR_DONECOLOR) -width 2 -tag slider
	set pwssss 0
	$w bind slider <Button-1> "PwScaleMark %W %x"
	$w bind slider <Button1-Motion> "PwScaleDrag %W %x"
	$w bind slide <ButtonRelease-1> "PwScaleChange %W %x"
	return $w
}

#------ Note position of slider when mouse is first pressed

proc PwScaleMark {w x} {
	global pwssss pwsmark
	set pwsmark $pwssss
}

#------ Move slider on display, and reset val in entrybox

proc PwScaleDrag {w x} {
	global pwssss pwsmark pwtime evv
	set x1 $pwsmark
	set pwsmark $x
	set dx [expr $x - $x1]
	if {$pwssss + $dx < 0} {
		set dx -$pwssss
	} elseif {$pwssss + $dx > $evv(SCALELEN)} {
		set dx [expr $evv(SCALELEN) - $pwssss]
	}
	$w move slider $dx 0
	incr pwssss $dx
	set pwtime [PwSetValFromSlider]
}

#------ Move slider on display, and reset val in entrybox

proc PwScaleChange {w x} {
	global pwtime pwssss evv
	if {$x > $evv(SCALELEN)} {
		set x $evv(SCALELEN)
	}
	set dx [expr $x - $pwssss]
	$w move slider $dx 0
	set pwssss  $x
	set pwtime [PwSetValFromSlider]
}

#------ Set scale value from entrybox

proc PwSetScale {} {
	global pwssss pwsmark pwslider pwtotaltime pwtime evv
	if [info exists pwslider] {
		set	val [expr double($pwtime) / double($pwtotaltime)]
		set val [expr round($val * $evv(SCALELEN))]
		$pwslider move slider [expr $val - $pwssss] 0
		set pwssss $val
		set pwsmark $val
	}
}

#------ Set entrybox value from scale

proc PwSetValFromSlider {} {
	global pwtotaltime pwssss evv

	set val [expr double($pwssss) / $evv(SCALELEN)]
	set val [expr $val * $pwtotaltime]
	return $val
}

#------ Display value to 5 dec places

proc FiveDecPlaces {val} {
	set vallen [string length $val] 
	set vallen_less_one [expr $vallen - 1]
	set pp [string first "." $val]
	if {$pp < 0} {
		return $val
	}
	if {$pp == $vallen_less_one} {
		set val [string range $val 0 [expr $vallen_less_one - 1]]
		return $val
	}
	set postlen [expr $vallen_less_one - $pp]
	if {$postlen < 5} {
		return $val
	}
	incr pp 5
	return [string range $val 0 $pp]
}

#########################
# GENERATE DISPLAY DATA #
#########################

proc GenerateDisplayData {fnam start end} {
	global CDPidrun do_data data_msg evv
	set data_msg ""
	set cmd [file join $evv(CDPROGRAM_DIR) pview]
#FEB 13
	set fnam [OmitSpaces $fnam]
	set cmd [concat $cmd $fnam $start $end]
	if [catch {open "|$cmd"} CDPidrun] {
		return "  $CDPidrun"
   	} else {
   		fileevent $CDPidrun readable "PviewReports"
		vwait do_data
   	}
	if {!$do_data} {
		return $data_msg
	}
	return ""
}

proc PviewReports {} {
	global CDPidrun do_data data_msg evv

	if [eof $CDPidrun] {
		set do_data 1
		catch {close $CDPidrun}
		return
	} else {
		gets $CDPidrun line
		set line [string trim $line]
		if {[string length $line] <= 0} {
			return
		}
		if [string match ERROR:* $line] {
			set data_msg [string range $line 7 end] 
			set do_data 0
			catch {close $CDPidrun}
			return
		}
	}
	update idletasks
}

proc CreatePwMagnified {} {
	global maxpw storepw storepw2 chanspw ismagpw magstorepw magstorepw2 
	global pwfnam pwscalefact pwsilence evv

	catch {unset magstorepw}
	catch {unset magstorepw2}
	set ismagpw 0
	set pwsilence 0
	if {[Flteq $maxpw 0.0]} {
		set pwsilence 1
		return
	}
	switch -- $chanspw {
		1 {
			if {$maxpw < $evv(PLAY_MONO_MAX)} {
				set scaler [expr double($evv(PLAY_MONO_MAX) - 1)/double($maxpw)]
				set magstorepw {}
				if {$pwscalefact == 1} {
					foreach {a b} $storepw {
						set b [expr $b - $evv(AXIS_MONO)]
#
#						set b [expr int(round($b * $scaler))]
#
						set b [expr $b * $scaler]
						set b [expr $evv(AXIS_MONO) + $b]
						lappend magstorepw $a $b
					}
				} else {
					foreach {a b c d} $storepw {
						set b [expr $b - $evv(AXIS_MONO)]
#
#						set b [expr int(round($b * $scaler))]
#
						set b [expr $b * $scaler]
						set d [expr $evv(AXIS_MONO) - $b]
						set b [expr $evv(AXIS_MONO) + $b]
						lappend magstorepw $a $b $c $d
					}
				}
			} else {
				return
			}
		}
		2 {
			if {$maxpw < $evv(PLAY_STEREO_MAX)} {
				set scaler [expr double($evv(PLAY_STEREO_MAX) - 1)/double($maxpw)]
				set magstorepw {}
				set magstorepw2 {}
				if {$pwscalefact == 1} {
					foreach {a b } $storepw {
						set b [expr $b - $evv(AXIS_STEREO1)]
#
#						set b [expr int(round($b * $scaler))]
#
						set b [expr $b * $scaler]
						set b [expr $evv(AXIS_STEREO1) + $b]
						lappend magstorepw $a $b
					}
					foreach {a b } $storepw2 {
						set b [expr $b - $evv(AXIS_STEREO2)]
#
#						set b [expr int(round($b * $scaler))]
#
						set b [expr $b * $scaler]
						set b [expr $evv(AXIS_STEREO2) + $b]
						lappend magstorepw2 $a $b
					}
				} else {
					foreach {a b c d e f g h} $storepw {
						set b [expr $b - $evv(AXIS_STEREO1)]
#
#						set b [expr int(round($b * $scaler))]
#
						set b [expr $b * $scaler]
						set d [expr $evv(AXIS_STEREO1) - $b]
						set b [expr $evv(AXIS_STEREO1) + $b]
						set f [expr $f - $evv(AXIS_STEREO2)]
#
#						set f [expr int(round($f * $scaler))]
#
						set f [expr $f * $scaler]
						set h [expr $evv(AXIS_STEREO2) - $f]
						set f [expr $evv(AXIS_STEREO2) + $f]
						lappend magstorepw $a $b $c $d $e $f $g $h
					}
				}
			} else {
				return
			}
		}
	}
}

###########################
# DISPLAY THE SOUND IMAGE #
###########################

proc DisplayPwData {} {
	global maxpw storepw pwscalefact playc wplaylen chanspw pwseensampstart pwseensampend pa evv
	global pwismarked pwfnam storepw2 pwvalscale truestorepw truestorepw2 pwbox pwdisplaydata 
	global pwlastx pw_effective_width pw_effective_max

	set msg [GenerateDisplayData $pwfnam $pwseensampstart $pwseensampend]
	if {[string length $msg] > 0} {
		Inf $msg
		return 0
	}
	if [catch {open $pwdisplaydata r} zit] {
		Inf "Cannot Open testdisplay File"
		return 0
	}
	set stereo [expr $chanspw - 1]
	ReconfigureSampleLabels $stereo	

	set gotzoom 0
	set maxpw 0
	set wplaylen 0
	set storepw {}
	set storepw2 {}
	set truestorepw {}
	set truestorepw2 {}
	catch {$playc delete vsound} in		;#	destroy any existing points
	catch {$playc delete axis} in
	catch {$playc delete sampval} in
	set even 1
	while {[gets $zit line] >= 0 } {
		set line [string trim $line]
		set line [split $line]
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {!$gotzoom} {
				set pwscalefact $item
				set gotzoom 1
				continue
			}
			if {$even} {
				switch -- $stereo {
					0	{ ;# MONO
						lappend truestorepw $item
					}
					1	{ ;# LEFT
						lappend truestorepw $item
					}
					2	{ ;# RIGHT
						lappend truestorepw2 $item
					}
				}
			} else {
				if {$pwscalefact == 1} {
					set absitem [expr abs($item)]
					if {$stereo} {
						if {![IsNumeric $item] || ($absitem > $evv(PLAY_STEREO_MAX))} {
							Inf "Invalid Data ($item) In display File"
							close $zit
							return 0
						}
					} else {
						if {![IsNumeric $item] || ($absitem > $evv(PLAY_MONO_MAX))} {
							Inf "Invalid Data ($item) In display File"
							close $zit
							return 0
						}
					}
					if {$absitem > $maxpw} {
						set maxpw $absitem
					}
					switch -- $stereo {
						0	{ ;# MONO
							set a [expr $evv(AXIS_MONO) - $item]
							lappend storepw $wplaylen $a
							incr wplaylen
						}
						1	{ ;# LEFT
							set a [expr $evv(AXIS_STEREO1) - $item]
							lappend storepw $wplaylen $a
							set stereo 2
						}
						2	{ ;# RIGHT
							set a [expr $evv(AXIS_STEREO2) - $item]
							lappend storepw2 $wplaylen $a
							incr wplaylen
							set stereo 1
						}
					}
				} else {
					if {$stereo} {
						if {![IsNumeric $item] || ($item < 0) || ($item > $evv(PLAY_STEREO_MAX))} {
							Inf "Invalid Data ($item) In display File"
							close $zit
							return 0
						}
					} else {
						if {![IsNumeric $item] || ($item < 0) || ($item > $evv(PLAY_MONO_MAX))} {
							Inf "Invalid Data ($item) In display File"
							close $zit
							return 0
						}
					}
					if {$item > $maxpw} {
						set maxpw $item
					}
					switch -- $stereo {
						0	{ ;# MONO
							set a [expr $evv(AXIS_MONO) + $item]
							set b [expr $evv(AXIS_MONO) - $item]
							$playc create line $wplaylen $a $wplaylen $b -fill $evv(GRAFSND) -tag vsound 
							incr wplaylen
						}
						1	{ ;# LEFT
							set a [expr $evv(AXIS_STEREO1) + $item]
							set b [expr $evv(AXIS_STEREO1) - $item]
							$playc create line $wplaylen $a $wplaylen $b -fill $evv(GRAFSND) -tag vsound 
							set stereo 2
						}
						2	{ ;# RIGHT
							set a [expr $evv(AXIS_STEREO2) + $item]
							set b [expr $evv(AXIS_STEREO2) - $item]
							$playc create line $wplaylen $a $wplaylen $b -fill $evv(GRAFSND) -tag vsound 
							incr wplaylen
							set stereo 1
						}
					}
					set storepw [concat $storepw $wplaylen $a $wplaylen $b]
				}
			}
			set even [expr !$even]
		}
	}
	set pw_effective_width [llength $truestorepw]
	set pw_effective_max [expr $pw_effective_width - 1]
	set pwseensampdur [expr $pwseensampend - $pwseensampstart]
	if {$pw_effective_width < $evv(PLAY_WIDTH)} {
		set thisratio [expr double($pw_effective_width) / double($evv(PLAY_WIDTH))]
		set pwseensampdur [expr int(round(double($pwseensampdur) * $thisratio))]
		set pwseensampend [expr $pwseensampstart + $pwseensampdur]
	}

	if {$stereo} {
		$playc create line 0 $evv(AXIS_STEREO1) $wplaylen $evv(AXIS_STEREO1) -fill $evv(GRAF) -tag axis 
		$playc create line 0 $evv(AXIS_STEREO2) $wplaylen $evv(AXIS_STEREO2) -fill $evv(GRAF) -tag axis
	} else {
		$playc create line 0 $evv(AXIS_MONO) $wplaylen $evv(AXIS_MONO) -fill $evv(GRAF) -tag axis 
	}
	if {$pwscalefact == 1} {
		if {$stereo} {
			eval {$playc create line} $storepw {-fill $evv(GRAFSND) -tag vsound}
			eval {$playc create line} $storepw2 {-fill $evv(GRAFSND) -tag vsound}
		} else {
			eval {$playc create line} $storepw {-fill $evv(GRAFSND) -tag vsound}
		}
	}
	if {$stereo} {
		set pwvalscale [expr $evv(PLAY_MAXSAMP) / $evv(PLAY_STEREO_MAX)]
	} else {
		set pwvalscale [expr $evv(PLAY_MAXSAMP) / $evv(PLAY_MONO_MAX)]
	}
	DoTail
	close $zit
	CreatePwMagnified
	RefreshPwSeenTimes
	ResetBlockMoveButtons
	catch {$playc delete $pwbox(last)}
	if {$pwismarked} {
		DelBox
		set pwismarked [PwRedrawBox]
	} else {
		DelBox
		PwClearBoxTimes
	}
	set pwlastx -1
}

proc DoTail {} {
	global wplaylen playc chanspw evv
	set endpw $wplaylen
	set stereo [expr $chanspw - 1]
	while {$endpw < $evv(PLAY_WIDTH)} {
		switch -- $stereo {
			0	{ ;# MONO
				$playc create line $endpw $evv(AXIS_MONO) $endpw $evv(AXIS_MONO) -fill $evv(GRAF) -tag axis 
				incr endpw
			}
			1	{ ;# LEFT
				$playc create line $endpw $evv(AXIS_STEREO1) $endpw $evv(AXIS_STEREO1) -fill $evv(GRAF) -tag axis 
				set stereo 2
			}
			2	{ ;# RIGHT
				$playc create line $endpw $evv(AXIS_STEREO2) $endpw $evv(AXIS_STEREO2) -fill $evv(GRAF) -tag axis 
				incr endpw
				set stereo 1
			}
		}
	}
}

##################
# MODIFY DISPLAY #
##################

proc PwMagnify {} {
	global storepw storepw2 magstorepw magstorepw2 pwmag_exists ismagpw pwscalefact playc chanspw pwsilence evv

	if {$pwsilence} {
		Inf "Silence Only In This Window"
		return
	}
	switch -- $ismagpw {
		0 {
			if {[info exists magstorepw] && ([llength $magstorepw] > 0)} {
				catch {$playc delete vsound} in
				catch {$playc delete axis} in
				if {$pwscalefact == 1} {
					if {$chanspw == 1} {
						$playc create line 0 $evv(AXIS_MONO) $evv(PLAY_WIDTH) $evv(AXIS_MONO) -fill $evv(GRAF) -tag axis 
						eval {$playc create line} $magstorepw {-fill $evv(GRAFSND) -tag vsound}
					} else {
						$playc create line 0 $evv(AXIS_STEREO1) $evv(PLAY_WIDTH) $evv(AXIS_STEREO1) -fill $evv(GRAF) -tag axis
						$playc create line 0 $evv(AXIS_STEREO2) $evv(PLAY_WIDTH) $evv(AXIS_STEREO2) -fill $evv(GRAF) -tag axis
						eval {$playc create line} $magstorepw {-fill $evv(GRAFSND) -tag vsound}
						eval {$playc create line} $magstorepw2 {-fill $evv(GRAFSND) -tag vsound}
					}
				} else {
					foreach {a b c d} $magstorepw {
						$playc create line $a $b $c $d -fill $evv(GRAFSND) -tag vsound 
					}
					if {$chanspw == 1} {
						$playc create line 0 $evv(AXIS_MONO) $evv(PLAY_WIDTH) $evv(AXIS_MONO) -fill $evv(GRAF) -tag axis
					} else {
						$playc create line 0 $evv(AXIS_STEREO1) $evv(PLAY_WIDTH) $evv(AXIS_STEREO1) -fill $evv(GRAF) -tag axis
						$playc create line 0 $evv(AXIS_STEREO2) $evv(PLAY_WIDTH) $evv(AXIS_STEREO2) -fill $evv(GRAF) -tag axis
					}
				}
				DoTail
				.playwindow.button.0.mag config -text "1-to-1"
				set ismagpw 1
			}
		}
		1 {
			catch {$playc delete vsound} in
			catch {$playc delete axis} in
			if {$pwscalefact == 1} {
				if {$chanspw == 1} {
					$playc create line 0 $evv(AXIS_MONO) $evv(PLAY_WIDTH) $evv(AXIS_MONO) -fill $evv(GRAF) -tag axis 
					eval {$playc create line} $storepw {-fill $evv(GRAFSND) -tag vsound}
				} else {
					$playc create line 0 $evv(AXIS_STEREO1) $evv(PLAY_WIDTH) $evv(AXIS_STEREO1) -fill $evv(GRAF) -tag axis 
					$playc create line 0 $evv(AXIS_STEREO2) $evv(PLAY_WIDTH) $evv(AXIS_STEREO2) -fill $evv(GRAF) -tag axis 
					eval {$playc create line} $storepw {-fill $evv(GRAFSND) -tag vsound}
					eval {$playc create line} $storepw2 {-fill $evv(GRAFSND) -tag vsound}
				}
			} else {
				foreach {a b c d} $storepw {
					$playc create line $a $b $c $d -fill $evv(GRAFSND) -tag vsound 
				}
			}
			DoTail
			.playwindow.button.0.mag config -text "Magnify"
			set ismagpw 0
		}
	}
}

proc ZoomIn {} {
	global pwseensampstart pwseensampend pwtotalsamps ismagpw evv
	global pwmarksampstart pwmarksampend pwscalefact pwismarked

	if {$pwscalefact == 1} {
		return 1
	}
	if {$pwismarked} {
		if {($pwmarksampstart == $pwseensampstart) && ($pwmarksampend == $pwseensampend)} {
			return 1
		} else {
			set pwseensampstart $pwmarksampstart
			set pwseensampend $pwmarksampend 
			if {[expr $pwseensampend - $pwseensampstart] < $evv(PLAY_WIDTH)}  {
				set pwseensampend [expr $pwseensampstart + $evv(PLAY_WIDTH)]
				if {$pwseensampend > $pwtotalsamps} {
					set pwseensampend $pwtotalsamps
					set pwseensampstart [expr $pwseensampend - $evv(PLAY_WIDTH)]
				}
			}
			PwClearBoxTimes
		}
	} else {
		set pwseensampend [expr round($pwseensampend * $evv(PLAY_ZOOMIN))]
	}
	if {[expr $pwseensampend - $pwseensampstart] < $evv(PLAY_WIDTH)}  {
		set pwseensampend [expr $pwseensampstart + $evv(PLAY_WIDTH)]
	}
	set pwismarked 0
	return [DisplayPwData]
}

proc ZoomOut {} {
	global pwseensampstart pwseensampend pwtotalsamps pwismarked ismagpw evv
	global pwmarksampstart pwmarksampend

	set diff [expr $pwseensampend - $pwseensampstart]
	if {$diff == $pwtotalsamps} {
		return 1
	}
	if {$pwismarked} {
		if {$pwseensampstart == 0} {
			set pwseensampend [expr $diff * $evv(PLAY_ZOOMOUT)]
			if {$pwseensampend > $pwtotalsamps} {
				set pwseensampend $pwtotalsamps
			}
		} elseif {$pwseensampend == $pwtotalsamps} {
			set diff [expr $diff * $evv(PLAY_ZOOMOUT)]
			set pwseensampstart [expr $pwseensampend - $diff]
			if {$pwseensampstart < 0} {
				set pwseensampstart 0
			}
		} else {
			set mdiff [expr $pwmarksampend - $pwmarksampstart]
			set mhdiff [expr int(round($mdiff/2))]
			set diff [expr $diff * $evv(PLAY_ZOOMOUT)]
			set nuhdiff [expr int(round($diff/2))]
			set pwseensampstart [expr $pwmarksampstart + $mhdiff - $nuhdiff]
			if {$pwseensampstart < 0} {
				set pwseensampstart 0
			}
			set pwseensampend [expr $pwseensampstart + $diff]
			if {$pwseensampend > $pwtotalsamps} {
				set pwseensampend $pwtotalsamps
			}
		}
## ????
		if {$pwmarksampstart < $pwseensampstart} {
			set pwmarksampstart $pwseensampstart
		}
## ????
		if {$pwmarksampend > $pwseensampend} {
			set pwmarksampend $pwseensampend
		}
	} else {
		if {$pwseensampstart == 0} {
			set pwseensampend [expr $diff * $evv(PLAY_ZOOMOUT)]
			if {$pwseensampend > $pwtotalsamps} {
				set pwseensampend $pwtotalsamps
			}
		} elseif {$pwseensampend == $pwtotalsamps} {
			set diff [expr $diff * $evv(PLAY_ZOOMOUT)]
			set pwseensampstart [expr $pwseensampend - $diff]
			if {$pwseensampstart < 0} {
				set pwseensampstart 0
			}
		} else {
			set hdiff [expr int(round($diff/2))]
			set diff [expr $diff * $evv(PLAY_ZOOMOUT)]
			set nuhdiff [expr int(round($diff/2))]
			set pwseensampstart [expr $pwseensampstart + $hdiff - $nuhdiff]
			if {$pwseensampstart < 0} {
				set pwseensampstart 0
			}
			set pwseensampend [expr $pwseensampstart + $diff]
			if {$pwseensampend > $pwtotalsamps} {
				set pwseensampend $pwtotalsamps
			}
		}
	}
	if {($pwseensampstart > 0) && ($pwseensampend  < $pwtotalsamps)} {
		EdgeCases
	}
	return [DisplayPwData]
}

proc FullView {redraw} {
	global pwseensampstart pwseensampend pwtotalsamps

	if {($pwseensampstart == 0) && ($pwseensampend == $pwtotalsamps)} {
		if {$redraw} {
			return [DisplayPwData]
		}
		return 1
	}
	set pwseensampstart 0
	set pwseensampend $pwtotalsamps 
	return [DisplayPwData]
}

proc SampleView {} {
	global pwseensampstart pwseensampend pwtotalsamps ismagpw evv
	global pwmarksampstart pwmarksampend pwismarked

	set diff [expr $pwseensampend - $pwseensampstart]
	if {$diff <= $evv(PLAY_WIDTH)} {
		return 1
	}
	if {$pwismarked} {
		set pwseensampstart $pwmarksampstart 
		set pwseensampend [expr $pwmarksampstart + $evv(PLAY_WIDTH)]
	} else {
		set pwseensampend [expr $pwseensampstart + $evv(PLAY_WIDTH)]
	}
	if {$pwseensampend  > $pwtotalsamps} {
		set pwseensampend $pwtotalsamps
		set pwseensampstart [expr $pwseensampend - $evv(PLAY_WIDTH)]  
	}
	set pwismarked 0
	return [DisplayPwData]
}

##################################
# MOVE TO NEW TIME AND REDISPLAY #
##################################

proc NextPwBlock {where} {
	global pwseensampstart pwseensampend pwtotalsamps evv

	if {($where == "back") || ($where == "start")} {
		if {$pwseensampstart == 0} {
			Inf "At Start Of File"
			return 1
		}
	} elseif {(($where == "forward") || ($where == "end")) && ($pwseensampend >= $pwtotalsamps)} {
		Inf "At End Of File"
		return 1
	}
	if {$pwtotalsamps <= $evv(PLAY_WIDTH)} {
		Inf "File Too Small To Move"
		return 1
	}
	set diff [expr $pwseensampend - $pwseensampstart]
	set x [expr double($diff) / double($evv(PLAY_WIDTH))]
	set y [expr double(ceil($x))]
	set diff [expr int(round((double($diff) * $y) / $x))]
	set hdiff [expr int(round($diff/2))]
	switch -- $where {
		"back" {
			set pwseensampstart [expr $pwseensampstart - $hdiff]
			if {$pwseensampstart < 0} {
				set pwseensampstart 0
			}
			set pwseensampend [expr $pwseensampstart + $diff]
		}
		"forward" {
			set pwseensampend [expr $pwseensampend + $hdiff]
			if {$pwseensampend > $pwtotalsamps} {
				set pwseensampend $pwtotalsamps
			}
			set pwseensampstart [expr $pwseensampend - $diff]
		}
		"start" {
			set pwseensampstart 0
			set pwseensampend [expr $pwseensampstart + $diff]
			if {$pwseensampend > $pwtotalsamps} {
				set pwseensampend $pwtotalsamps
			}
		}
		"end" {
			set pwseensampend $pwtotalsamps
			set pwseensampstart [expr $pwseensampend - $diff]
			if {$pwseensampstart < 0} {
				set pwseensampstart 0
			}
		}
	}
	if {($pwseensampstart > 0) && ($pwseensampend  < $pwtotalsamps)} {
		EdgeCases
	}
	return [DisplayPwData]
}

proc PwGoto {} {
	global pwfnam pwtime pwsrate pwscalefact pwseensampstart pwseensampend pwtotalsamps pwtotaltime pa evv 

	if {![info exists pwtime] || ![IsNumeric $pwtime] || ($pwtime < 0)} {
		Inf "No Valid Time Value Given"
		return 1
	} elseif {$pwtime > $pwtotaltime} {
		Inf "Time Out Of Range"
		return 1
	}
	set herestart $pwseensampstart
	set pwseensampstart [expr int(round($pwtime * $pwsrate))]
	if {$herestart == $pwseensampstart} {
		return 1
	}
	set diff [expr $evv(PLAY_WIDTH) * $pwscalefact]
	set pwseensampend [expr $pwseensampstart + $diff]
	if {$pwseensampend > $pwtotalsamps} {
		set pwseensampend $pwtotalsamps
	}
	set diff [expr $pwseensampend - $pwseensampstart]
	if {$diff < $evv(PLAY_WIDTH)} {
		set pwseensampstart [expr $pwseensampend - $evv(PLAY_WIDTH)]
		if {$pwseensampstart < 0} {
			set pwseensampstart 0
		}
	}
	return [DisplayPwData]
}

proc EdgeCases {} {
	global pwseensampend pwseensampstart pwtotalsamps

	set diff [expr $pwseensampend - $pwseensampstart]
	set enddiff [expr $pwtotalsamps - $pwseensampend]
	set ratiopw [expr double($diff)/double($pwseensampstart)]
	set endratiopw   [expr double($diff)/double($enddiff)]
	if {$ratiopw > 8} {
		set pwseensampstart 0
		set pwseensampend $diff
		if {$pwseensampend >= $pwtotalsamps} {
			set pwseensampend $pwtotalsamps
		} else {
			set enddiff [expr $pwtotalsamps - $pwseensampend]
			set endratiopw   [expr double($diff)/double($enddiff)]
			if {$ratiopw > 8} {
				set pwseensampend $pwtotalsamps
			}
		}
	} else {
		if {$endratiopw > 8} {
			set pwseensampend $pwtotalsamps
			set pwseensampstart [expr $pwseensampend - $diff]
			if {$pwseensampstart <= 0} {
				set pwseensampstart 0
			} else {
				set diff [expr $pwseensampend - $pwseensampstart]
				set ratiopw [expr double($diff)/double($pwseensampstart)]
				if {$ratiopw > 8} {
					set pwseensampstart 0
				}
			}
		}
	}
}

##########################
# MARK INDIVIDUAL SAMPLE #
##########################

proc PwSampMark {x y} {
	global pwlastx pwlineanchor
	PwShowVal $x $y
	if {$pwlastx < 0 } {
		return
	}
	set pwlineanchor $x
}

proc PwSampMarkDrag {x} {
	global pwlastx pwlineanchor pw_effective_max evv
	if {$pwlastx < 0 } {
		return
	}
	if {($x >= 0) && ($x < $pw_effective_max)} {
		if {$x > $pwlineanchor} {
			SampStep 1
		} elseif {$x < $pwlineanchor} {
			SampStep -1
		}
		set pwlineanchor $x
	}
}

proc SampStep {step} {
	global pwlastx pwscalefact pwseensampend chanspw pwsampval truestorepw truestorepw2 pwstchan playc evv
	global pwtotalsamps pwsamptime pwseensampdur pwseensampstart pwsampsecs pwsrate pwseentimestart
	global pw_effective_max pw_effective_width pwdispsecs

	if {$pwlastx < 0} {
		set pwlastx -1
		return
	} elseif {$pwlastx == 0} {
		if {$step == -1} {
			return
		}
	} elseif {$pwlastx >= $pw_effective_max} {
		if {$step == 1} {
			return
		}
	} elseif {($pwscalefact == 1) && ($pwseensampend <= $evv(PLAY_WIDTH)) && ($pwlastx >= $pwseensampend)} {
		set pwlastx -1
		return
	}
	incr pwlastx $step
	switch -- $chanspw {
		1 {
			set pwsampval [lindex $truestorepw $pwlastx]
		}
		2 {
			if {$pwstchan == 2} {
				set pwsampval [lindex $truestorepw2 $pwlastx]
			} else {
				set pwsampval [lindex $truestorepw $pwlastx]
			}
		}
	}
	if {$pwtotalsamps <= $evv(PLAY_WIDTH)} {
		set pwsamptime $pwlastx
	} else {
		set val	[expr double($pwlastx)/double($pw_effective_width)]
		set val [expr int(round($pwseensampdur * $val))]
		set pwsamptime [expr $pwseensampstart + $val]
	} 
	set pwsampsecs [FiveDecPlaces [expr double($pwsamptime) / double($pwsrate)]]
	set pwdispsecs [FiveDecPlaces [expr $pwsampsecs - $pwseentimestart]]
	$playc delete sampval
	$playc create line $pwlastx 0 $pwlastx $evv(PLAY_HEIGHT) -fill $evv(GRAF) -tag sampval
}

proc DelSampMark {} {
	global playc
	$playc delete sampval
	PwClearSampVals
}

proc PwShowVal {x y} {
	global playc pwsampval ismagpw pwvalscale chanspw pwscalefact truestorepw truestorepw2 evv
	global pwstchan pwsamptime pwsampsecs pwtotalsamps pwseensampdur pwseensampstart pwsrate
	global pwseensampend pwlastx pw_effective_width pwseentimestart pwdispsecs

	if {$x >= $pw_effective_width} {
		return
	}
	catch {$playc delete sampval} in
	if {($pwscalefact == 1) && ($x > $pwseensampend)} {
		PwClearSampVals
		return
	}
	$playc create line $x 0 $x $evv(PLAY_HEIGHT) -fill $evv(GRAF) -tag sampval
	switch -- $chanspw {
		1 {
			set pwsampval [lindex $truestorepw $x]
			set pwstchan 1
		}
		2 {
			if {$y > $evv(STERE01_EDGE)} {
				set pwsampval [lindex $truestorepw2 $x]
				set pwstchan 2
			} else {
				set pwsampval [lindex $truestorepw $x]
				set pwstchan 1
			}
		}
	}
	if {[string length $pwsampval] <= 0} {
		set pwsamptime ""
		set pwsampsecs ""
		set pwdispsecs ""
		set pwstchan ""
	} else {
		if {$pwtotalsamps <= $evv(PLAY_WIDTH)} {
			set pwsamptime $x
		} else {
			set val	[expr double($x)/double($pw_effective_width)]
			set val [expr int(round($pwseensampdur * $val))]
			set pwsamptime [expr $pwseensampstart + $val]
		} 
		set pwsampsecs [FiveDecPlaces [expr double($pwsamptime) / double($pwsrate)]]
		set pwdispsecs [FiveDecPlaces [expr $pwsampsecs - $pwseentimestart]]
		set pwlastx $x
	}
	ForceVal .playwindow.button.0.sval $pwsampval
	ForceVal .playwindow.button.0.svas $pwsamptime
	ForceVal .playwindow.button.0.svat.1 $pwsampsecs
	ForceVal .playwindow.button.0.svat.2 $pwdispsecs
	ForceVal .playwindow.button.0.svac $pwstchan
}

proc PwPushSeen {end} {
	global pwsamptime pwseensampend pwseensampstart pwtotalsamps pwseensampdur evv

	if {[string length $pwsamptime] <= 0} {
		Inf "No Individual Sample Marked"
		return
	}
	if {$end} {
		if {$pwsamptime == $pwseensampend} {
			return
		}
		set newstart [expr $pwsamptime - $pwseensampdur]
		if {$newstart < 0} {
			Inf "Too Near To Start Of Sound"
			return
		} else {
			set pwseensampend $pwsamptime
			set pwseensampstart $newstart
		}
	 } else {
		if {$pwsamptime == $pwseensampstart} {
			return
		}
		set newend [expr $pwsamptime + $pwseensampdur]
		if {$newend > $pwtotalsamps} {
			Inf "Too Near To End Of Sound"
			return
		} else {
			set pwseensampstart $pwsamptime
			set pwseensampend $newend
		}
	}
	return [DisplayPwData]
}

proc PwMarkAt {indisplay} {
	global pwfnam pwtime pwseentimestart pwseentimeend pwseentimedur pw_effective_max 

	if {![info exists pwtime] || ![IsNumeric $pwtime] || ($pwtime < 0)} {
		Inf "No Valid Time Value Given"
		return
	}
	if {$indisplay} {
		if {$pwtime >= $pwseentimedur} {
			Inf "Time Not Within Range Of Display"
			return
		}
		set val [expr $pwtime / $pwseentimedur]
	} else {
		if {($pwtime <= $pwseentimestart) || ($pwtime >= $pwseentimeend)} {
			Inf "Time Not Within Range Of Display"
			return
		}
		set val [expr ($pwtime - $pwseentimestart) / $pwseentimedur]
	}
	set x [expr int(round($val * double($pw_effective_max)))]
	PwShowVal $x 0
}

############################################
# MOUSE & OTHER OPERATIONS ON BOX OF SOUND #
############################################

proc PwBoxBegin {x y} {
	global pwbox playc
	PwClearBoxTimes
	DelBox
	set pwbox(anchor) [list $x $y]
}

proc PwBoxDrag {x y} {
	global pwbox playc evv
	if {![info exists pwbox(anchor)]} {
		return
	}
	if {($x >= 0) && ($x <= $evv(PLAY_WIDTH))} {
		catch {$playc delete $pwbox(last)}
		set pwbox(last) [eval {$playc create rect} $pwbox(anchor) {$x $y -tag box -outline $evv(GRAF)}]
	}
}

proc PwBoxGet {} {
	global playc pwtotalsamps pwseensampdur pwseensampstart pwmarksampend pwmarksampstart evv
	global pwsrate pwbox pwismarked pwkeepwhole pw_effective_width

	set thisbox [$playc find withtag box]
	set coords [$playc coords $thisbox]
	if {[llength $coords] <= 0} {
		return
	}
	set coords [lreplace $coords 1 1 $evv(PLAY_BOXTOP)]
	set coords [lreplace $coords 3 3 $evv(PLAY_BOXBOT)]

	if {[lindex $coords 2] > $pw_effective_width} {
		set coords [lreplace $coords 2 2 $pw_effective_width]
	}
	catch {$playc delete $pwbox(last)}
	set pwbox(last) [eval {$playc create rect} $coords {-stipple gray12 -fill $evv(GRAFSND) -outline $evv(GRAF) -tag box}]

	set val1 [lindex $coords 0]
	set val2 [lindex $coords 2]
	set val $val1
	if {$val1 > $val2} {
		set val $val2
		set $val2 $val1
	}
	if {$pwtotalsamps > $evv(PLAY_WIDTH)} {
		set val [expr double($val)/double($evv(PLAY_WIDTH))]
		set val [expr int(round($pwseensampdur * $val))]
		set pwmarksampstart [expr $pwseensampstart + $val]
	} else {
		set pwmarksampstart $val
	}
	set val $val2
	if {$pwtotalsamps > $evv(PLAY_WIDTH)} {
		set val [expr double($val)/double($evv(PLAY_WIDTH))]
		set val [expr int(round($pwseensampdur * $val))]
		set pwmarksampend [expr $pwseensampstart + $val]
	} else {
		set pwmarksampend $val
	}
	set pwmarksampdur [expr $pwmarksampend - $pwmarksampstart]
	PwDisplayMarkTimes
	set pwismarked 1
	set pwkeepwhole 0
}

proc PwRedrawBox {} {
	global pwseensampdur pwseensampstart pwseensampend pwmarksampstart pwmarksampend pwmarksampdur pwismarked
	global pwmarktimestart pwmarktimeend pwmarktimedur pwtotalsamps playc pwsrate pwkeepwhole pw_effective_width evv

	if {$pwmarksampend <= $pwseensampstart} {
		PwClearBoxTimes
		return 0
	}
	if {$pwmarksampstart >= $pwseensampend} {
		PwClearBoxTimes
		return 0
	}
	DelBox
	if {$pwmarksampstart < $pwseensampstart} {
		set pwmarksampstart $pwseensampstart
	}
	if {$pwmarksampend > $pwseensampend} {
		set pwmarksampend $pwseensampend
	}
	set a [expr $pwmarksampstart - $pwseensampstart]
	set a [expr double($a)/double($pwseensampdur)]
	if {$pwtotalsamps <= $evv(PLAY_WIDTH)} {
		set a [expr int(round($a * $pwseensampdur))]
	} else {
		set a [expr int(round($a * $pw_effective_width))]
	}
	set b [expr $pwmarksampend - $pwseensampstart]
	set b [expr double($b)/double($pwseensampdur)]
	if {$pwtotalsamps <= $evv(PLAY_WIDTH)} {
		set b [expr int(round($b * $pwseensampdur))]
	} else {
		set b [expr int(round($b * $pw_effective_width))]
	}
#DANGEROUS ???
#	if {$b > $pw_effective_width} {
#		set b $pw_effective_width
#	}

	set coords [list $a $evv(PLAY_BOXTOP) $b $evv(PLAY_BOXBOT)]
	set pwbox(last) [eval {$playc create rect} $coords {-stipple gray12 -fill $evv(GRAFSND) -outline $evv(GRAF) -tag box}]
	set pwmarksampdur [expr $pwmarksampend - $pwmarksampstart]
	PwDisplayMarkTimes
	set pwkeepwhole 0
	return 1
}

proc DelBox {} {
	global playc pwbox
	catch {$playc delete $pwbox(last)}
	catch {$playc delete box}
	catch {unset pwbox(last)}
}

proc PwPushBox {end} {
	global pwmarksampstart pwmarksampend pwseensampstart pwseensampend pwtotalsamps

	if {[string length $pwmarksampstart] <= 0} {
		Inf "No Marked Area"
		return
	}
	if {$end} {
		if {$pwmarksampend != $pwseensampend} {
			if {($pwmarksampstart == 0) && ($pwseensampend == $pwtotalsamps)} {
				Inf "This Would Mark The Entire File"
				return
			}
			set pwmarksampend $pwseensampend
		}
	} elseif {$pwmarksampstart != $pwseensampstart} {
		if {($pwseensampstart == 0) && ($pwmarksampend == $pwtotalsamps)} {
			Inf "This Would Mark The Entire File"
			return
		}
		set pwmarksampstart $pwseensampstart
	}
	PwRedrawBox
}

proc PwBoxtoMark {} {
	global pwsamptime pwmarksampstart pwmarksampend 

	if {[string length $pwmarksampstart] <= 0} {
		Inf "No Box Drawn"
		return
	}
	if {[string length $pwsamptime] <= 0} {
		Inf "No Mark Set"
		return
	}
	if {$pwsamptime < $pwmarksampstart} {
		set pwmarksampstart $pwsamptime
		PwRedrawBox
		return
	} elseif {$pwsamptime > $pwmarksampend} {
		set pwmarksampend $pwsamptime
		PwRedrawBox
		return
	}
	Inf "Mark Is Not Outside Box"
	return
}

proc PwMarktoBox {end} {
	global pwsamptime pwmarksampstart pwmarksampend playc

	if {[string length $pwmarksampstart] <= 0} {
		Inf "No Box Drawn"
		return
	}
	set thisbox [$playc find withtag box]
	set coords [$playc coords $thisbox]
	if {[llength $coords] <= 0} {
		return
	}
	if {[string length $pwsamptime] > 0} {
		DelSampMark
	}
	if {$end} {
		set x [expr int([lindex $coords 2])]
	} else {
		set x [expr int([lindex $coords 0])]
	}
	set pwlastx $x
	PwShowVal $x 0
}



proc PwBoxCut {before} {
	global pwmarksampstart pwsamptime pwmarksampend 

	if {[string length $pwmarksampstart] <= 0} {
		Inf "No Box Drawn"
		return
	}
	if {[string length $pwsamptime] <= 0} {
		Inf "No Mark Set"
		return
	}
	if {($pwsamptime >= $pwmarksampend) || ($pwsamptime <= $pwmarksampstart) }  {
		Inf "Mark Is Not Inside Box"
		return
	}
	if {$before} {
		set pwmarksampstart $pwsamptime
	} else {
		set pwmarksampend $pwsamptime
	}
	PwRedrawBox
}

proc PwMarktoMax {} {
	global truestorepw truestorepw2 chanspw pwscalefact pw_effective_max evv

	set valmax -10000000.0
	set valmaxch 1
	set cnt 0
	if {$pwscalefact == 1} {
		foreach val $truestorepw {
			set y [expr abs($val)]
			if {$y > $valmax} {
				set valmax $y
				set valpos $cnt
			}
			incr cnt
		}
	} else {
		foreach val $truestorepw {
			if {$val > $valmax} {
				set valmax $val
				set valpos $cnt
			}
			incr cnt
		}
	}
	if {$chanspw == 2} {
		set cnt 0
		if {$pwscalefact == 1} {
			foreach val $truestorepw2 {
				set y [expr abs($val)]
				if {$y > $valmax} {
					set valmax $y
					set valpos $cnt
					set valmaxch 2
				}
				incr cnt
			}
		} else {
			foreach val $truestorepw2 {
				if {$val > $valmax} {
					set valmax $val
					set valpos $cnt
					set valmaxch 2
				}
				incr cnt
			}
		}
	}
	if {![info exists valpos]} {
		Inf "Can't Find Max Value"
		return
	}
	if {$valmaxch == 2} {
		set y $evv(AXIS_STEREO2)
	} else {
		set y 0
	}
	PwShowVal $valpos $y
}

proc PwBoxNot {after} {
	global pwmarksampstart pwmarksampend pwtotalsamps pwseensampstart pwseensampend

	if {[string length $pwmarksampstart] <= 0} {
		Inf "No Box Exists"
		return 
	}
	if {$after} {
		if {$pwmarksampend >= $pwtotalsamps} {
			Inf "Already At End Of File"
			return 
		}
		set pwmarksampstart $pwmarksampend
		set pwmarksampend $pwtotalsamps

	} else {
		if {$pwmarksampstart == 0} {
			Inf "Already At Start Of File"
		}
		set pwmarksampend $pwmarksampstart
		set pwmarksampstart 0
	}
	FullView 1
}

##############################################
# SET OR CLEAR VALUE DISPLAYS OR THEIR NAMES #
##############################################

proc PwClearBoxTimes {} {
	global pwmarksampstart pwmarksampend pwmarksampdur 
	global pwmarktimestart pwmarktimeend pwmarktimedur pwkeepwhole
	set pwmarksampstart ""
	set pwmarksampend ""
	set pwmarksampdur ""
	set pwmarktimestart ""
	set pwmarktimeend ""
	set pwmarktimedur ""
	ForceVal .playwindow.info.marked.0.e0 $pwmarksampstart
	ForceVal .playwindow.info.marked.0.e1 $pwmarksampend
	ForceVal .playwindow.info.marked.0.e2 $pwmarksampdur
	ForceVal .playwindow.info.marked.1.e0 $pwmarktimestart
	ForceVal .playwindow.info.marked.1.e1 $pwmarktimeend
	ForceVal .playwindow.info.marked.1.e2 $pwmarktimedur
	set pwkeepwhole 1
}

proc PwDisplayMarkTimes {} {
	global pwmarksampstart pwmarksampend pwmarksampdur 
	global pwmarktimestart pwmarktimeend pwmarktimedur pwsrate pwkeepwhole

	set pwmarksampdur [expr $pwmarksampend - $pwmarksampstart]
	ForceVal .playwindow.info.marked.0.e0 $pwmarksampstart
	ForceVal .playwindow.info.marked.0.e1 $pwmarksampend
	ForceVal .playwindow.info.marked.0.e2 $pwmarksampdur
	set pwmarktimestart [FiveDecPlaces [expr double($pwmarksampstart)/double($pwsrate)]]
	set pwmarktimeend   [FiveDecPlaces [expr double($pwmarksampend)/double($pwsrate)]]
	set pwmarktimedur   [FiveDecPlaces [expr $pwmarktimeend - $pwmarktimestart]]
	ForceVal .playwindow.info.marked.1.e0 $pwmarktimestart
	ForceVal .playwindow.info.marked.1.e1 $pwmarktimeend
	ForceVal .playwindow.info.marked.1.e2 $pwmarktimedur
	set pwkeepwhole 0
}

proc PwClearSampVals {} {
	global pwsampval pwsamptime pwsampsecs pwdispsecs pwstchan

	set pwsampval ""
	set pwsamptime ""
	set pwsampsecs ""
	set pwdispsecs ""
	set pwstchan ""
}

proc RefreshPwSeenTimes {} {
	global pwseensampstart pwseensampend pwseensampdur pwseentimestart pwseentimeend pwseensampdur 
	global wplaylen pwsrate pwdur playc pwscalefact evv

	set pwseensampdur   [expr $pwseensampend - $pwseensampstart]
	set pwseentimestart [FiveDecPlaces [expr double($pwseensampstart)/double($pwsrate)]]
	set pwseentimeend   [FiveDecPlaces [expr double($pwseensampend)/double($pwsrate)]]
	set pwseentimedur   [expr $pwseentimeend - $pwseentimestart]
	ForceVal .playwindow.info.local.0.e0 $pwseensampstart
	ForceVal .playwindow.info.local.0.e1 $pwseensampend
	ForceVal .playwindow.info.local.0.e2 $pwseensampdur
	ForceVal .playwindow.info.local.1.e0 $pwseentimestart
	ForceVal .playwindow.info.local.1.e1 $pwseentimeend
	ForceVal .playwindow.info.local.1.e2 $pwseentimedur
}

proc ResetBlockMoveButtons {} {
	global pwseensampstart pwseensampend pwtotalsamps ismagpw 

	if {($pwseensampstart == 0) && ($pwseensampend == $pwtotalsamps)} {
		.playwindow.button.4.next config -state disabled
		.playwindow.button.4.last config -state disabled
		.playwindow.button.4.stt  config -state disabled
		.playwindow.button.4.end  config -state disabled
	} else {
		.playwindow.button.4.next config -state normal
		.playwindow.button.4.last config -state normal
		.playwindow.button.4.stt  config -state normal
		.playwindow.button.4.end  config -state normal
	}
	.playwindow.button.0.mag config -text "Magnify"
	set ismagpw 0
	PwClearSampVals
}

proc DisplayPwTotals {} {
	global pwtotalsamps pwtotaltime 

	ForceVal .playwindow.info.total.0.e $pwtotalsamps
	ForceVal .playwindow.info.total.1.e $pwtotaltime
}

proc ReconfigureSampleLabels {stereo} {
	global pwfull
	if {$stereo} {
		if {$pwfull == 1} {
			.playwindow.button.1.zero config -text "" -bd 0 -state disabled
		}
		.playwindow.info.local.subtit1 config -text "In Stereo Samples"
		.playwindow.info.marked.subtit1 config -text "In Stereo Samples"
		.playwindow.info.total.0.lab config -text "Total Stereo Samples"
	} else {
		if {$pwfull == 1} {
			.playwindow.button.1.zero config -text "CutZero" -bd 2 -state normal
		}
 		.playwindow.info.local.subtit1 config -text "In Samples"
		.playwindow.info.marked.subtit1 config -text "In Samples"
		.playwindow.info.total.0.lab config -text "Total Samples"
	}
}

###################
# SAVE DATA ITEMS #
###################

proc PwSave {add brkdata export} {
	global pwkeepwhole playwsvalk playwevalk pwtimetyp pwdataname wstk wl evv
	global pwmarksampstart pwmarksampend pwmarktimestart pwmarktimeend pwtotaltime
	global pwseensampstart pwseensampend pwseentimestart pwseentimeend grafixbrk
	global pwsamptime pwsampsecs pwb pwbrkpnts pwbrkbot pwbrktop pw_effective_width

	if {$brkdata} {
		if {![info exists pwbrkpnts]}  {
			Inf "No Breakpoints Drawn"
			return
		}
		if {![IsNumeric $pwbrkbot] || ![IsNumeric $pwbrktop]} {
			Inf "Invalid Range Value(s)"
			return
		}
		if {$pwbrkbot > $pwbrktop} {
			Inf "Range Values Inverted"
			return
		} elseif {[Flteq $pwbrkbot $pwbrktop]} {
			Inf "No Significant Range Of Values"
			return
		}
		set pwb(ew) [expr double($pw_effective_width)]
		set pwb(rang) [expr $pwbrktop - $pwbrkbot]
	} else {
		switch -- $pwkeepwhole {
			0 {
				if {[string length $pwmarksampstart] <= 0} {
					Inf "There Is No Marked Area"
					return
				}
				if {!$playwsvalk && !$playwevalk} {
					Inf "Neither Start Not End Time Has Been Selected"
					return
				}
			}
			1 {
				if {!$playwsvalk && !$playwevalk} {
					Inf "Neither Start Not End Time Has Been Selected"
					return
				}
			}
			2 {
				if {[string length $pwsamptime] <= 0} {
					Inf "There Is No Selected Point"
					return
				}
			}
		}
	}
	if {$export != "0"} {
		if {$brkdata} { 
			set cnt 0
			foreach {x y} $pwbrkpnts {
				set outcoords [PwGetReals $x $y]
				set lastval [lindex $outcoords 1]
				if {($cnt == 0) && ([lindex $outcoords 0] != 0.0)} {
					set out 0.00000
					append out " " $lastval
					$export insert end "$out\n"
				}
				set out [lindex $outcoords 0]
				append out " " [lindex $outcoords 1]
				$export insert end "$out\n"
				incr cnt
			}
			set last_tim [lindex $out 0]
			set last_val [lindex $out 1]
			if {$last_tim < $pwtotaltime} {
				set out $pwtotaltime 
				append out " " $last_val
				$export insert end "$out\n"
			}
			Inf "Breakpoint Values Exported"
		} else {
			set outvals ""
			switch -- $pwkeepwhole {
				0 {		;# MARKED
					switch -- $pwtimetyp {
						0 {  ;#	SAMPLES
							if {$playwsvalk} {
								append outvals $pwmarksampstart "  " 
							}
							if {$playwevalk} {
								append outvals $pwmarksampend
							}
						}
						1 {  ;#	SECONDS
							if {$playwsvalk} {
								append outvals $pwmarktimestart "  " 
							}
							if {$playwevalk} {
								append outvals $pwmarktimeend
							}
						}
					}
				}
				1 {		;# WHOLE
					switch -- $pwtimetyp {
						0 {  ;#	SAMPLES
							if {$playwsvalk} {
								append outvals $pwseensampstart "  " 
							}
							if {$playwevalk} {
								append outvals $pwseensampend
							}
						}
						1 {  ;#	SECONDS
							if {$playwsvalk} {
								append outvals $pwseentimestart "  " 
							}
							if {$playwevalk} {
								append outvals $pwseentimeend
							}
						}
					}
				}
				2 {		;# SINGLE POINT
					switch -- $pwtimetyp {
						0 {  ;#	SAMPLES
							set outvals $pwsamptime 
						}
						1 {  ;#	SECONDS
							set outvals $pwsampsecs 
						}
					}
				}
			}
			set outvals [string trim $outvals]
			$export insert end "$outvals\n"
			Inf "$outvals Exported"
		}
		return
	}
	if {[string length $pwdataname] <= 0} {
		Inf "No Data Filename Entered"
		return
	}
	set fnam [string tolower $pwdataname]
	set fnamext [file extension $pwdataname]
	if {([string length $fnamext] > 0) && ![string match $fnamext $evv(TEXT_EXT)]} {
		Inf "You Must Save To A Text File"
		return
	}
	if {[string length $fnamext] == 0} {
		append fnam $evv(TEXT_EXT)
	}
	set rootfnam [file rootname [file tail $fnam]]
	if {![ValidCDPRootname $rootfnam]} {
		return
	}
	switch -- $add {
		1 {
			if {![file exists $fnam]} {
				Inf "File '$fnam' Does Not Exist"
				return
			}
			if [catch {open $fnam "a"} zit] {
				Inf "Cannot Open File '$fnam' To Add Data"
				return
			}
		}
		0 {
			if {[file exists $fnam]} {
				set msg "File '$fnam' Already Exist: Overwrite It?"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					return
				}
			}
			if [catch {open $fnam "w"} zit] {
				Inf "Cannot Open File '$fnam' To Write Data"
				return
			}
		}
	}
	if {$brkdata} { 
		set cnt 0
		foreach {x y} $pwbrkpnts {
			set outcoords [PwGetReals $x $y]
			set lastval [lindex $outcoords 1]
			if {($cnt == 0) && ([lindex $outcoords 0] != 0.0)} {
				set extracoords 0.00000
				append extracoords " " $lastval
				puts $zit $extracoords
			}
			puts $zit $outcoords
			incr cnt
		}
		set last_tim [lindex $outcoords 0]
		if {$last_tim < $pwtotaltime} {
			set extracoords $pwtotaltime 
			append extracoords " " $lastval
			puts $zit $extracoords
		}
	} else {
		set outvals ""
		switch -- $pwkeepwhole {
			0 {		;# MARKED
				switch -- $pwtimetyp {
					0 {  ;#	SAMPLES
						if {$playwsvalk} {
							append outvals $pwmarksampstart "  " 
						}
						if {$playwevalk} {
							append outvals $pwmarksampend
						}
					}
					1 {  ;#	SECONDS
						if {$playwsvalk} {
							append outvals $pwmarktimestart "  " 
						}
						if {$playwevalk} {
							append outvals $pwmarktimeend
						}
					}
				}
			}
			1 {		;# WHOLE
				switch -- $pwtimetyp {
					0 {  ;#	SAMPLES
						if {$playwsvalk} {
							append outvals $pwseensampstart "  " 
						}
						if {$playwevalk} {
							append outvals $pwseensampend
						}
					}
					1 {  ;#	SECONDS
						if {$playwsvalk} {
							append outvals $pwseentimestart "  " 
						}
						if {$playwevalk} {
							append outvals $pwseentimeend
						}
					}
				}
			}
			2 {		;# SINGLE POINT
				switch -- $pwtimetyp {
					0 {  ;#	SAMPLES
						set outvals $pwsamptime 
					}
					1 {  ;#	SECONDS
						set outvals $pwsampsecs 
					}
				}
			}
		}
		set outvals [string trim $outvals]
		puts $zit $outvals 
	}
	close $zit
	if {$add} {
		if {[LstIndx $fnam $wl] >= 0} {
			if {[DoParse $fnam $wl 0 0] <= 0} {
				return
			}
			if {$brkdata == 2} {
				set grafixbrk $fnam
				ValToParam .playwindow pr_playw
			}
		}
	} else {
		Inf "Values Written to File '$fnam'"
		FileToWkspace $fnam 0 0 0 0 1
		if {$brkdata == 2} {
			set grafixbrk $fnam
			ValToParam .playwindow pr_playw
		}
	}
}

##############
# EDIT SOUND #
##############

#---- Edit and play output (keep output in case want to save)

proc PwAction {action} {
	global pwfnam pwoutfnam pwoutfnam2 pwkeepwhole pwmarksampstart pwtotalsamps evv
	global pwmarksampend pwseensampstart pwseensampend wstk pwlastaction pwseensampend

	set pwplayall 0
	if {$pwkeepwhole > 1} {
		Inf "No Region Specified"
		return
	}
	switch -- $action {
		"play" -
		"play0" {
			if {$pwkeepwhole == 0} {
				if {[string length $pwmarksampstart] <= 0} {
					Inf "No Marked Area"
					return
				}
			} elseif {($pwseensampstart == 0) && ($pwseensampend == $pwtotalsamps)} {
				set pwplayall 1
			}
		}
		default {
			if {[string length $pwmarksampstart] <= 0} {
				Inf "No Marked Area"
				return
			} elseif {($pwmarksampstart == 0) && ($pwmarksampend == $pwtotalsamps)} {
				Inf "Complete File Marked: No Action Possible"
				return
			}
		}
	}
	if {($action == "play") || ($action == "play0")} {
		if {!$pwplayall} {
			catch {file delete $pwoutfnam}
			if {[file exists $pwoutfnam]} {
				Inf "Cannot Delete Temporary File '$pwoutfnam': Is It Still Open For Play?"
				return
			}
			set cmd [PwEditCmd $action $pwoutfnam]
			set action "play"
		}
	} else {
		catch {file delete $pwoutfnam2}
		if {[file exists $pwoutfnam2]} {
			Inf "Cannot Delete Temporary File '$pwoutfnam2': Is It Still Open For Play?"
			return
		}
		switch -- $action {
			"edit"	   { set cmd [PwEditCmd edit $pwoutfnam2] }
			"dovetail" { set cmd [PwDovetailCmd] }
			"curtail"  { set cmd [PwCurtailCmd]  }
			"zerocut"  { set cmd [PwZerocutCmd]  }
			"excise"   { set cmd [PwExciseCmd]  }
			"mask"     { set cmd [PwMaskCmd]  }
		}
	}
	if {$pwplayall} {
		PlaySndfile $pwfnam	0		;# PLAY INPUT
		set pwlastaction ""
		return
	}
	DoPwAction $cmd				;# ATTEMPT TO RUN ACTION
	switch -- $action {
		"play" {
			if {![file exists $pwoutfnam]} {
				Inf "Edit Process Failed"
				return
			}
			PlaySndfile $pwoutfnam 0		;# PLAY OUTPUT
		}
		default {
			if {![file exists $pwoutfnam2]} {
				Inf "Edit Process Failed"
				return
			}
			 Inf "Done $action"
			.playwindow.button.1.plo config -bg $evv(EMPH)
		}
	}
	set pwlastaction $action
}

proc DoPwAction {cmd} {
	global CDPidrun prg_dun prg_abortd evv
	Block "Edit"
	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	if [catch {open "|$cmd"} CDPidrun] {
		UnBlock
		return
   	} else {
   		fileevent $CDPidrun readable "Display_Play_Running_Info"
	}
	vwait prg_dun
	if {$prg_abortd} {
		UnBlock
		return
	}
	if {!$prg_dun} {
		UnBlock
		return
	}
	UnBlock
	return
}

proc Display_Play_Running_Info {} {
	global CDPidrun rundisplay prg_dun prg_abortd program_messages evv
	global bulk super_abort

	if {[info exists CDPidrun] && [eof $CDPidrun]} {
		set prg_dun 1
		catch {close $CDPidrun}
		return
	} else {
		gets $CDPidrun line
		set line [string trim $line]
		if {[string length $line] <= 0} {
			return
		}
		if [string match ERROR:* $line] {
			Inf "$line"
			set prg_abortd 1
			set prg_dun 0
			return
		} elseif [string match END:* $line] {
			set prg_dun 1
			return
		} else {
			return
		}
	}
	update idletasks
}


proc PwPlayOutput {} {
	global pwoutfnam2
	if {![file exists $pwoutfnam2]} {
		Inf "No Output File To Play"
		return
	}
	PlaySndfile $pwoutfnam2 0
}

proc PwSaveSnd {} {
	global pwcutnme wstk pwoutfnam2 pwlastaction pwsaved pwcutname pwfnam wl rememd evv

	if {![file exists $pwoutfnam2]} {
		Inf "No Outfile To Save"
		return
	}
	if {[string length $pwcutname] <= 0} {
		Inf "No Sound Filename Entered"
		return
	}
	set fnam [string tolower $pwcutname]
	if {![ValidCDPRootname $fnam]} {
		return
	}
	append fnam $evv(SNDFILE_EXT)
	if {[file exists $fnam]} {
		set msg "File '$fnam' Already Exist: Overwrite It?"
		set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		} else {
			if [DeleteFileFromSystem $fnam 1 1] {
				DummyHistory $fnam "DESTROYED"
				set i [LstIndx $fnam $wl]
				if {$i >= 0} {
					WkspCnt [$wl get $i] -1
					$wl delete $i
					catch {unset rememd}
				}
			} else {
				Inf "Cannot Overwrite Existing File"
				return
			}
		}
	}
	if [catch {file rename $pwoutfnam2 $fnam} in] {
		Inf "$in : Cannot Save File: Is File Open For Playing ?"
		return
	}
	if {[FileToWkspace $fnam 0 0 0 0 1] <= 0} {
		Inf "Cannot Put File '$fnam' On The Workspace."
	}
	DummyHistory  $fnam "was edited from $pwfnam"
	set pwlastaction ""
	.playwindow.button.1.plo config -bg [option get . background {}]
	set pwsaved $fnam
	Inf "File '$fnam' Saved"
}

proc PwRecycleSnd {} {
	global pwfnam pwsaved pwsampval pwsamptime pwsampsecs chanspw pa evv
	global pwtotaltime pwsrate pwtotalsamps pwdur pwseensampstart pwseensampend pwdisplaydata
	global chlist ch

	if {![info exists pwsaved]} {
		Inf "No Output File Saved"
		return
	}
	set pwdataname "_temp"
	set pwcutname ""
	set pwlastaction ""
	set pwscalefact 1
	set pwismarked 0
	catch {file delete $pwdisplaydata}
	set pwfnam $pwsaved
	wm title .playwindow "View and Edit Sound (alt-Click on Wkspace Soundfile to launch):            $pwfnam"
	.playwindow.button.1.plo config -bg [option get . background {}]
	PwClearSampVals
	PwClearBoxTimes
	set chanspw $pa($pwfnam,$evv(CHANS))
	set pwtotaltime  $pa($pwfnam,$evv(DUR))
	.playwindow.button.4.r config -text $pwtotaltime
	set pwsrate $pa($pwfnam,$evv(SRATE))
	set pwtotalsamps [expr $pa($pwfnam,$evv(INSAMS)) / $pa($pwfnam,$evv(CHANS))]
	set pwdur $pa($pwfnam,$evv(DUR))
	set pwseensampstart 0
	set pwseensampend $pwtotalsamps
	if {![DisplayPwData]} {
		Dlg_Dismiss .playwindow
		return
	}
	DisplayPwTotals
	unset pwsaved
	set pwkeepwhole 1

	DoChoiceBak
	ClearWkspaceSelectedFiles
	set chlist $pwfnam
	set chcnt 1
	$ch insert end $pwfnam
}

##########################
# GENERATE EDIT COMMANDS #
##########################

proc PwEditCmd {action outnam} {
	global pwfnam playwsplice pa evv
	global pwkeepwhole pwmarksampstart pwmarksampend pwseensampstart pwseensampend 

	set cmd [file join $evv(CDPROGRAM_DIR) sfedit]
	lappend cmd cut 3 $pwfnam $outnam
	switch -- $action {
		"play" {
			if {$pwkeepwhole == 0} {	;# MARKED
				lappend cmd $pwmarksampstart $pwmarksampend
			} else {					;# WHOLE
				lappend cmd $pwseensampstart $pwseensampend
			}
		}
		"play0" {
			if {$pwkeepwhole == 0} {	;# MARKED
				lappend cmd $pwmarksampstart $pwmarksampend
				set sampdur [expr $pwmarksampend - $pwmarksampstart]
			} else {					;# WHOLE
				lappend cmd $pwseensampstart $pwseensampend
				set sampdur [expr $pwseensampend - $pwseensampstart]
			}
			set maxsplen [expr double($sampdur) / $pa($pwfnam,$evv(SRATE))]
			set maxsplen [expr ($maxsplen / 2.0) * 999.0] ;# convert to msecs & subtract margin of error
			if {$maxsplen < $playwsplice} {
				set playwsplice $maxsplen
			}
		}
		"edit" {
			lappend cmd $pwmarksampstart $pwmarksampend
		}
	}
	if {([string length $playwsplice] > 0) && [IsNumeric $playwsplice] && ($playwsplice >= 0)} {
		set splice -w
		append splice $playwsplice
		lappend cmd $splice
	}
	if {$action == "play0"} {
		set playwsplice 15
	}
	return $cmd
}

proc PwDovetailCmd {} {
	global pwexp pwfnam pwoutfnam2 pwmarksampstart pwmarksampend pwtotalsamps evv

	set cmd [file join $evv(CDPROGRAM_DIR) envel]
	lappend cmd dovetail 
	switch -- $pwexp  {
		0 {
			lappend cmd 1 $pwfnam $pwoutfnam2 $pwmarksampstart [expr $pwtotalsamps - $pwmarksampend] 0 0 -t2
		}
		1 {	
			lappend cmd 1 $pwfnam $pwoutfnam2 $pwmarksampstart [expr $pwtotalsamps - $pwmarksampend] 1 1 -t2
		}
		2 {	
			lappend cmd 2 $pwfnam $pwoutfnam2 $pwmarksampstart [expr $pwtotalsamps - $pwmarksampend] -t2
		}
	}
	return $cmd
}

proc PwCurtailCmd {} {
	global pwexp pwfnam pwoutfnam2 pwmarksampstart pwmarksampend pwmarktimestart pwmarktimeend evv

	set cmd [file join $evv(CDPROGRAM_DIR) envel]
	lappend cmd curtail
	switch -- $pwexp  {
		0 {
			lappend cmd 1 $pwfnam $pwoutfnam2 $pwmarksampstart $pwmarksampend 0 -t2
		}
		1 {	
			lappend cmd 1 $pwfnam $pwoutfnam2 $pwmarksampstart $pwmarksampend 1 -t2
		}
		2 {	
			lappend cmd 4 $pwfnam $pwoutfnam2 $pwmarktimestart $pwmarktimeend -t0
		}
	}
	return $cmd
}

proc PwZerocutCmd {} {
	global pwexp pwfnam pwoutfnam2 pwmarktimestart pwmarktimeend evv

	set cmd [file join $evv(CDPROGRAM_DIR) sfedit]
	lappend cmd zcut 1 $pwfnam $pwoutfnam2 $pwmarktimestart $pwmarktimeend
	return $cmd
}

proc PwExciseCmd {} {
	global pwexp pwfnam pwoutfnam2 pwmarksampstart pwmarksampend playwsplice evv

	set cmd [file join $evv(CDPROGRAM_DIR) sfedit]
	lappend cmd excise 3 $pwfnam $pwoutfnam2 $pwmarksampstart $pwmarksampend
	if {([string length $playwsplice] > 0) && [IsNumeric $playwsplice] && ($playwsplice >= 0)} {
		set splice -w
		append splice $playwsplice
		lappend cmd $splice
	}
	return $cmd
}

proc PwMaskCmd {} {
	global pwexp pwfnam pwoutfnam2 pwmarksampstart pwmarksampdur playwsplice evv

	set cmd [file join $evv(CDPROGRAM_DIR) sfedit]
	lappend cmd insil 3 $pwfnam $pwoutfnam2 $pwmarksampstart $pwmarksampdur
	if {([string length $playwsplice] > 0) && [IsNumeric $playwsplice] && ($playwsplice >= 0)} {
		set splice -w
		append splice $playwsplice
		lappend cmd $splice
	}
	lappend cmd -o -s
	return $cmd
}

proc PwExpandtoMark {end} {
	global pwscalefact pwsamptime pwseensampstart pwseensampend evv

	if {[string length $pwsamptime] <= 0} {
		Inf "No Sample Marked"
		return
	}
	if {$pwscalefact == 1} {
		Inf "Maximum Resolution: Cannot Expand Display"
		return
	}
	if {($pwsamptime < $pwseensampstart) || ($pwsamptime > $pwseensampend)} {
		return		;# SAFETY, SHOULD BE IMPOSSIBLE
	}
	if {$end} { ;#  EXPAND Display to End at Mark
		if {[expr $pwsamptime - $pwseensampstart] <= $evv(PLAY_WIDTH)} {
			Inf "Cannot Expand Display To This Mark: Exceeds Maximum Resolution"
			return
		}
		set pwseensampend $pwsamptime
	} else {	;# EXPAND Display to Start at Mark
		if {[expr $pwseensampend - $pwsamptime] <= $evv(PLAY_WIDTH)} {
			Inf "Cannot Expand Display To This Mark: Exceeds Maximum Resolution"
			return
		}
		set pwseensampstart $pwsamptime
	}
	DelSampMark
	return [DisplayPwData]
}

proc PwDataEdit {} {
	global pwdataname evv
	set fnam [string tolower $pwdataname]
	if {[string length $pwdataname] <= 0} {
		Inf "No Data File Name"
		return
	}
	set fnamext [file extension $pwdataname]
	if {([string length $fnamext] > 0) && ![string match $fnamext $evv(TEXT_EXT)]} {
		Inf "You Must Open A Text File"
		return
	}
	if {[string length $fnamext] == 0} {
		append fnam $evv(TEXT_EXT)
	}
	set rootfnam [file rootname [file tail $fnam]]
	if {![ValidCDPRootname $rootfnam]} {
		return
	}
	if {![file exists $fnam]} {
		Inf "File '$fnam' Does Not Exist"
		return
	}
	DisplayTextfile $fnam
}


#--------- Restricted play window

proc PlayWindow2 {fnam export} {
	global playw playc pr_playw playwsplice pwdataname playwsvalk playwevalk pwtimetyp wl pw_p pa wplaylen evv
	global pwseensampstart pwseensampend pwseensampdur 
	global pwseentimestart pwseentimeend pwseentimedur
	global pwmarksampstart pwmarksampend pwmarksampdur 
	global pwmarktimestart pwmarktimeend pwmarktimedur 
	global  pwtotalsamps pwtotaltime true_play_width pwsrate pwdur pwscalefact
	global maxpw storepw chanspw pwfnam pwvalscale pwsampval pwstchan
	global pwslider pwtime pwismarked pwkeepwhole pwcutname pwlastaction
	global pwoutfnam pwdisplaydata pwlastx pwfull pwbrktop pwbrkbot pwbrkset pwbrktime pwbrkval readonlyfg readonlybg
	global pwlinger pwturn pwexpon

	set pwdataname "_temp"
	set pwcutname ""
	set pwlastaction ""

	set pwoutfnam $evv(DFLT_OUTNAME)
	append pwoutfnam 0 $evv(SNDFILE_EXT)
	set pwoutfnam2 $evv(DFLT_OUTNAME)
	append pwoutfnam2 1 $evv(SNDFILE_EXT)
	set pwdisplaydata $evv(DFLT_OUTNAME)
	append pwdisplaydata 00 $evv(TEXT_EXT)

	set pwscalefact 1
	set pwismarked 0
	catch {file delete $pwdisplaydata}

	set pwfnam $fnam

	if {[info exists pwfull] && ($pwfull != 0)} {
		destroy .playwindow
	}
	set pwfull 0

	Block "Creating Display Files"
	UnBlock
	set f .playwindow
	if [Dlg_Create $f "Select and Play" "set pr_playw 0" -borderwidth $evv(BBDR) -width $evv(PLAY_WIDTH)] {
		set fb [frame $f.button -borderwidth $evv(SBDR)]		;#	frame for buttons
		set fc [frame $f.canvas -borderwidth $evv(SBDR)]		;#	frame for canvas
		set fd [frame $f.info -borderwidth $evv(SBDR)]		;#	frame for info
		set fb0 [frame $fb.0 -borderwidth $evv(SBDR)]
		set fb0a [frame $fb.0a -bg [option get . foreground {}] -height 1]
		set fb1 [frame $fb.1 -borderwidth $evv(SBDR)]
		set fb1a [frame $fb.1a -bg [option get . foreground {}] -height 1]
		set fb2 [frame $fb.2 -borderwidth $evv(SBDR)]
		set fb3 [frame $fb.3 -bg [option get . foreground {}] -height 1]
		set fb4 [frame $fb.4 -borderwidth $evv(SBDR)]
		set fb5 [frame $fb.5 -bg [option get . foreground {}] -height 1]
		label  $fb0.view -text "VIEW: " -fg $evv(SPECIAL)
		button $fb0.zoom -text "Zoom In" -command {set pr_playw [ZoomIn]} -width 8 -highlightbackground [option get . background {}]
		button $fb0.zomo -text "Zoom Out" -command {set pr_playw [ZoomOut]}  -width 8 -highlightbackground [option get . background {}]
		button $fb0.full -text "Full View" -command {set pr_playw [FullView 0]}  -width 8 -highlightbackground [option get . background {}]
		button $fb0.samp -text "Samples" -command {set pr_playw [SampleView]}  -width 8 -highlightbackground [option get . background {}]
		button $fb0.mag -text "Magnify" -command PwMagnify  -width 8	 -highlightbackground [option get . background {}]
		label $fb0.svl  -text "Val"
		entry  $fb0.sval -textvariable pwsampval -width 7 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label  $fb0.svs  -text "Sample" 
		entry  $fb0.svas -textvariable pwsamptime -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		frame  $fb0.svt
		label  $fb0.svt.1  -text "Time in Sound  " 
		label  $fb0.svt.2  -text "Time in Display" 
		pack $fb0.svt.1 $fb0.svt.2
		frame $fb0.svat
		entry  $fb0.svat.1 -textvariable pwsampsecs -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		entry  $fb0.svat.2 -textvariable pwdispsecs -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $fb0.svat.1 $fb0.svat.2 -side top
		label  $fb0.svc  -text "Chan" 
		entry  $fb0.svac -textvariable pwstchan -width 2 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		button $fb0.sfwd -text "->F" -command {TellSampStep 1} -highlightbackground [option get . background {}]
		button $fb0.sbak -text "<-B" -command {TellSampStep -1} -highlightbackground [option get . background {}]
		button $fb0.quit -text Close -command "set pr_playw 0" -bg $evv(EMPH) -highlightbackground [option get . background {}]

		menubutton $fb0.mark -text "Mark" -menu $fb0.mark.menu -relief raised -width 8
		set sv [menu $fb0.mark.menu -tearoff 0]
		$sv add command -label "Move Mark One Value ->" -command {SampStep 1} -foreground black
		$sv add separator
		$sv add command -label "............... One Value <-" -command {SampStep -1} -foreground black
		$sv add separator
		$sv add command -label "Set Mark at Time in Sound" -command {PwMarkAt 0} -foreground black
		$sv add separator
		$sv add command -label "................ Time from Display Start" -command {PwMarkAt 1} -foreground black
		$sv add separator
		$sv add command -label "................ Maximum Value In Display" -command {PwMarktoMax} -foreground black
		$sv add separator
		$sv add command -label "................ Selection Box Start" -command {PwMarktoBox 0} -foreground black
		$sv add separator
		$sv add command -label "................ Selection Box End" -command {PwMarktoBox 1} -foreground black
		$sv add separator
		$sv add command -label "Move Display-start to Mark" -command {PwPushSeen 0}   -foreground black
		$sv add separator
		$sv add command -label "....... Display-end to Mark" -command {PwPushSeen 1}   -foreground black
		$sv add separator
		$sv add command -label "Expand Display to Start At Mark" -command {set pr_play [PwExpandtoMark 0]} -foreground black
		$sv add separator
		$sv add command -label ".......... .......... to END AT MARK" -command {set pr_play [PwExpandtoMark 1]} -foreground black
		$sv add separator
		$sv add command -label "BREAKPOINTS" -command {}  -foreground black
		$sv add separator
		$sv add command -label "Set Breakpoints Around Mark" -command {PwBrkpnts 2} -foreground black

		pack $fb0.view \
			$fb0.zoom $fb0.zomo $fb0.full $fb0.samp $fb0.mag $fb0.mark \
			 $fb0.svl $fb0.sval $fb0.svs $fb0.svas $fb0.svt $fb0.svat $fb0.svc $fb0.svac $fb0.sfwd $fb0.sbak -side left -padx 2
		pack $fb0.quit -side right -padx 1

		label $fb1.tit -text "BREAK\nPNTS:" -fg $evv(SPECIAL)
		frame $fb1.draw
		button $fb1.draw.draw -text Draw -command {PwBrkpnts 1} -highlightbackground [option get . background {}]
		button $fb1.draw.load -text Load -command {PwBrkpnts 4} -highlightbackground [option get . background {}]
		pack $fb1.draw.draw $fb1.draw.load -side top
		button $fb1.erase -text Erase -command {PwBrkpnts 0} -highlightbackground [option get . background {}]
		frame $fb1.btl
		frame $fb1.btl.0
		frame $fb1.btl.1
		label $fb1.btl.0.1 -text "Lo"
		entry $fb1.btl.0.2 -textvariable pwbrkbot -width 4
		pack $fb1.btl.0.1 $fb1.btl.0.2 -side left -fill x -expand true
		label $fb1.btl.1.1 -text "Hi"
		entry $fb1.btl.1.2 -textvariable pwbrktop -width 4
		pack $fb1.btl.1.1 $fb1.btl.1.2 -side left -fill x -expand true
		pack $fb1.btl.0 $fb1.btl.1 -side top -pady 1
		frame $fb1.nrm 
		label $fb1.nrm.rng -text "RANGE"
		radiobutton $fb1.nrm.nrm -text "0-1" -value 1 -command {set pwbrktop 1; set pwbrkbot 0} -variable pwbrkset
		pack $fb1.nrm.rng $fb1.nrm.nrm -side top -pady 1
		frame $fb1.pan 
		radiobutton $fb1.pan.pan -text Pan -value 2 -command {set pwbrktop 1; set pwbrkbot -1} -variable pwbrkset
		radiobutton $fb1.pan.other -text Other -value 0 -command {set pwbrktop ""; set pwbrkbot ""} -variable pwbrkset
		pack $fb1.pan.pan $fb1.pan.other -side top
		button $fb1.aba -text Abandon -command {PwBrkpnts -1} -highlightbackground [option get . background {}]
		button $fb1.see -text SeeBrk -command {PwSeeBrkpnts} -highlightbackground [option get . background {}]
		button $fb1.sav -text SaveBrk -command {PwSave 0 1 0} -highlightbackground [option get . background {}]
		button $fb1.use -text UseBrk -command {PwSave 0 2 0} -highlightbackground [option get . background {}]
		frame $fb1.bt
		frame $fb1.bt.1
		label $fb1.bt.1.bt -text "time "
		entry $fb1.bt.1.btt -textvariable pwbrktime -width 7 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $fb1.bt.1.bt $fb1.bt.1.btt -side left
		frame $fb1.bt.2
		label $fb1.bt.2.bv -text value 
		entry $fb1.bt.2.bvv -textvariable pwbrkval -width 7 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $fb1.bt.2.bv $fb1.bt.2.bvv -side left 
		pack $fb1.bt.1 $fb1.bt.2 -side top
		button $fb1.smoo -text "Smooth" -command {PwSmooth} -highlightbackground [option get . background {}]
		frame $fb1.smot
		frame $fb1.smot.1
		frame $fb1.smot.2
		label $fb1.smot.1.1 -text "linger"
		entry $fb1.smot.1.2 -textvariable pwlinger -width 8
		pack $fb1.smot.1.1 $fb1.smot.1.2 -side left -fill x -expand true
		label $fb1.smot.2.1 -text "turn  "
		entry $fb1.smot.2.2 -textvariable pwturn -width 8
		pack $fb1.smot.2.1 $fb1.smot.2.2 -side left -fill x -expand true
		pack $fb1.smot.1 $fb1.smot.2 -side top -pady 1
		button $fb1.exp  -text "Concave" -command {PwExponentiate 0} -highlightbackground [option get . background {}]
		button $fb1.exp2  -text "Convex" -command {PwExponentiate 1} -highlightbackground [option get . background {}]
		frame $fb1.exp3
		label $fb1.exp3.1 -text "Exponent"
		entry $fb1.exp3.2 -textvariable pwexpon -width 8
		pack $fb1.exp3.1 $fb1.exp3.2 -side top -pady 1

		pack $fb1.tit $fb1.draw $fb1.erase $fb1.aba $fb1.btl \
			$fb1.nrm $fb1.pan $fb1.smoo $fb1.smot $fb1.exp $fb1.exp2 $fb1.exp3 $fb1.see $fb1.sav $fb1.use $fb1.bt -side left -padx 2
		label  $fb2.sel1 -text "KEEP  \nDATA: " -fg $evv(SPECIAL)
		button $fb2.play -text Play -command "PwAction play0" -bg $evv(EMPH) -fg $evv(SPECIAL) -width 5 -height 2 -highlightbackground [option get . background {}]
		radiobutton $fb2.mrk -variable pwkeepwhole -text "Marked\nSegment" -value 0 
		radiobutton $fb2.whl -variable pwkeepwhole -text "Whole\nDisplay" -value 1
		checkbutton $fb2.sval -variable playwsvalk -text "Start"
		checkbutton $fb2.eval -variable playwevalk -text "End"
		radiobutton $fb2.ip -variable pwkeepwhole -text "Single\nPoint" -value 2
		label $fb2.kp -text "SAVE AS"
		radiobutton $fb2.gsamp -variable pwtimetyp -text "Samples" -value 0
		radiobutton $fb2.time  -variable pwtimetyp -text "Secs" -value 1
		button $fb2.nf -text "SaveData" -command {PwSave 0 0 0} -width 6 -highlightbackground [option get . background {}]
		button $fb2.af -text "AddToFile" -command {PwSave 1 0 0} -width 7 -highlightbackground [option get . background {}]
		button $fb2.ef -text "EditData" -command {PwDataEdit} -width 6 -highlightbackground [option get . background {}]

		label  $fb2.nm    -text "Data\nFilename"
		frame $fb2.zz
		entry  $fb2.zz.name  -textvariable pwdataname -width 16
		menubutton $fb2.zz.standard -text "Standard" -menu $fb2.zz.standard.menu -relief raised -borderwidth 2 -width 10
		set s [menu $fb2.zz.standard.menu -tearoff 0]
		MakeStandardNamesMenu $s $f.button.2.zz.name 0
		pack $fb2.zz.name $fb2.zz.standard -side top -pady 1
		pack $fb2.sel1 $fb2.play $fb2.mrk $fb2.whl $fb2.sval $fb2.eval $fb2.ip $fb2.kp $fb2.time $fb2.gsamp -side left -padx 2
		pack $fb2.zz $fb2.nm $fb2.ef $fb2.af $fb2.nf -side right -padx 2

		label  $fb4.move -text "MOVE: " -fg $evv(SPECIAL)
		button $fb4.next -text "Forward" -command {set pr_playw [NextPwBlock forward]}  -width 8 -highlightbackground [option get . background {}]
		button $fb4.last -text "Back" -command {set pr_playw [NextPwBlock back]}  -width 8 -highlightbackground [option get . background {}]
		button $fb4.stt -text "To Start" -command {set pr_playw [NextPwBlock start]}  -width 8 -highlightbackground [option get . background {}]
		button $fb4.end -text "To End" -command {set pr_playw [NextPwBlock end]}  -width 8 -highlightbackground [option get . background {}]
		button $fb4.goto -text "Go To" -command PwGoto -width 5 -highlightbackground [option get . background {}]


		menubutton $fb4.box -text "Select" -menu $fb4.box.menu -relief raised -width 7
		set sb [menu $fb4.box.menu -tearoff 0]
		$sb add command -label "Expand Box To Start Of Display" -command {PwPushBox 0} -foreground black
		$sb add separator
		$sb add command -label "Expand Box To End Of Display" -command {PwPushBox 1} -foreground black
		$sb add separator
		$sb add command -label "Expand Box To Mark" -command {PwBoxtoMark} -foreground black
		$sb add separator
		$sb add command -label "Cut Off Box After Mark" -command {PwBoxCut 0} -foreground black
		$sb add separator
		$sb add command -label "Cut Off Box Before Mark" -command {PwBoxCut 1} -foreground black
		$sb add separator
		$sb add command -label "Select All File Before Box" -command {PwBoxNot 0} -foreground black
		$sb add separator
		$sb add command -label "Select All File After Box" -command {PwBoxNot 1} -foreground black
		$sb add separator
		$sb add command -label "BREAKPOINTS" -command {}  -foreground black
		$sb add separator
		$sb add command -label "Set Breakpoints Around Box" -command {PwBrkpnts 3} -foreground black

		menubutton $fb4.info -text "Info" -menu $fb4.info.menu -relief raised -width 6 ;# -background $evv(HELP)
		set m [menu $fb4.info.menu -tearoff 0]
		$m add command -label "IN ANY MODE" -command {}  -foreground black
		$m add separator ;# -background $evv(HELP)
		$m add command -label "Select A Box:      Shift-Mouse-Drag" -command {} -foreground black
		$m add separator
		$m add command -label "Remove A Box:    Control-Shift-Mouse-Click" -command {} -foreground black
		$m add separator
		$m add command -label "     Also see 'SELECT' menu" -command {} -foreground $evv(SPECIAL)
		$m add separator ;# -background $evv(HELP)
		$m add command -label "WHEN NOT IN BREAKPOINT MODE" -command {}  -foreground black
		$m add separator ;# -background $evv(HELP)
		$m add command -label "Mark,see Val:     Mouse-Click" -command {} -foreground black
		$m add command -label "     in STEREO click near channel wanted." -command {} -foreground $evv(SPECIAL)
		$m add command -label "     Except at sample scale, vals are AVERAGES." -command {} -foreground $evv(SPECIAL)
		$m add separator
		$m add command -label "Move Mark:         Mouse-Drag" -command {} -foreground black
		$m add separator
		$m add command -label "Remove Mark:     Control-Mouse-Click" -command {} -foreground black
		$m add separator
		$m add command -label "     Also see 'MARK' menu" -command {} -foreground $evv(SPECIAL)
		$m add separator ;# -background $evv(HELP)
		$m add command -label "IN BREAKPOINT MODE ONLY" -command {}  -foreground black
		$m add separator ;# -background $evv(HELP)
		$m add command -label "Create Brkpnt:  Mouse-Click" -command {} -foreground black
		$m add separator
		$m add command -label "Remove Brkpnt:  Control-Mouse-Click" -command {} -foreground black
		$m add separator
		$m add command -label "Remove Several: Create Box: Hit 'Delete'" -command {} -foreground black
		$m add separator
		$m add command -label "See Brkpnt Val:   Command-Mouse-Click" -command {} -foreground black
		$m add separator
		$m add command -label "Drag Vertically: Command-Mouse-Drag" -command {} -foreground black
		$m add separator
		$m add command -label "Drag Anyway:      Command-Shift-Mouse-Drag" -command {} -foreground black
		$m add separator
		$m add command -label "Concave/Cnvex: Draw box around endpoint to use" -command {} -foreground black
		$m add command -label "     Exponent determines slope of curve. (Range >1 - 10)" -command {} -foreground $evv(SPECIAL)
		$m add separator
		$m add command -label "Smooth Turns:   For pan files" -command {} -foreground black
		$m add command -label "     Linger: proportion pantime spent turning (Range .05 - .9)" -command {} -foreground $evv(SPECIAL)
		$m add command -label "     Turn:   proportion panwidth used to turn (Range .05 - .9)" -command {} -foreground $evv(SPECIAL)
		$m add separator
		$m add command -label "     Brkpnts can only be drawn over displayed area." -command {} -foreground $evv(SPECIAL)
		$m add command -label "     Initial brkpnt val in display is extended to sound start." -command {} -foreground $evv(SPECIAL)
		$m add command -label "     Final brkpnt val in display  is extended to sound end." -command {} -foreground $evv(SPECIAL)

		label $fb4.lab -text Time
		entry $fb4.time -textvariable pwtime -width 12
		label $fb4.0 -text "0"
		set pwslider [PwMakeScale $fb4.slid]
		label $fb4.r -text "" -width 9
		pack $fb4.move $fb4.next $fb4.last $fb4.stt $fb4.end -side left -padx 2
		pack $fb4.goto $fb4.lab $fb4.time $fb4.0 $pwslider $fb4.r $fb4.box $fb4.info -side left -padx 2

		set playc [Sound_Canvas $fc.c -width $evv(PLAY_WIDTH) -height $evv(PLAY_HEIGHT) \
									-scrollregion "0 0 $evv(PLAY_WIDTH) $evv(SCROLL_HEIGHT)"]
		pack $fc.c -side top
		set fdl [frame $fd.local -borderwidth $evv(SBDR)]
		frame $fd.dum0 -bg [option get . foreground {}] -width 1
		set fdm [frame $fd.marked -borderwidth $evv(SBDR)] 
		frame $fd.dum1 -bg [option get . foreground {}] -width 1
		set fdt [frame $fd.total -borderwidth $evv(SBDR)] 
		label $fdl.title -text "DISPLAY SEEN"
		label $fdl.subtit1 -text "In Samples"
		set fdl0 [frame $fdl.0 -borderwidth $evv(SBDR)]
		label $fdl.subtit2 -text "In Seconds"
		set fdl1 [frame $fdl.1 -borderwidth $evv(SBDR)]
		label $fdl0.lab0 -text "Start"
		entry $fdl0.e0 -textvariable pwseensampstart -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $fdl0.lab1 -text "End"
		entry $fdl0.e1 -textvariable pwseensampend -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $fdl0.lab2 -text "Duration"
		entry $fdl0.e2 -textvariable pwseensampd -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $fdl0.lab0 $fdl0.e0 $fdl0.lab1 $fdl0.e1 $fdl0.lab2 $fdl0.e2 -side left
		label $fdl1.lab0 -text "Start"
		entry $fdl1.e0 -textvariable pwseentimestart -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $fdl1.lab1 -text "End"
		entry $fdl1.e1 -textvariable pwseentimeend -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $fdl1.lab2 -text "Duration"
		entry $fdl1.e2 -textvariable pwseentimedur -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $fdl1.lab0 $fdl1.e0 $fdl1.lab1 $fdl1.e1 $fdl1.lab2 $fdl1.e2 -side left
		pack $fdl.title -side top
		pack $fdl.subtit1 $fdl0 $fdl.subtit2 $fdl1 -side top -fill x -expand true

		label $fdm.title -text "BOX SELECTED"
		label $fdm.subtit1 -text "In Samples"
		set fdm0 [frame $fdm.0 -borderwidth $evv(SBDR)]
		label $fdm.subtit2 -text "In Seconds"
		set fdm1 [frame $fdm.1 -borderwidth $evv(SBDR)]
		label $fdm0.lab0 -text "Start"
		entry $fdm0.e0 -textvariable pwmarksampstart -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $fdm0.lab1 -text "End"
		entry $fdm0.e1 -textvariable pwmarksampend -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $fdm0.lab2 -text "Duration"
		entry $fdm0.e2 -textvariable pwmarksampdur -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $fdm0.lab0 $fdm0.e0 $fdm0.lab1 $fdm0.e1 $fdm0.lab2 $fdm0.e2 -side left
		label $fdm1.lab0 -text "Start"
		entry $fdm1.e0 -textvariable pwmarktimestart -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $fdm1.lab1 -text "End"
		entry $fdm1.e1 -textvariable pwmarktimeend -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $fdm1.lab2 -text "Duration"
		entry $fdm1.e2 -textvariable pwmarktimedur -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $fdm1.lab0 $fdm1.e0 $fdm1.lab1 $fdm1.e1 $fdm1.lab2 $fdm1.e2 -side left
		pack $fdm.title -side top
		pack $fdm.subtit1 $fdm0 $fdm.subtit2 $fdm1 -side top -fill x -expand true

		label $fdt.title -text "WHOLE FILE"
		label $fdt.subtit1 -text ""
		set fdt0 [frame $fdt.0 -borderwidth $evv(SBDR)]
		label $fdt.subtit2 -text ""
		set fdt1 [frame $fdt.1 -borderwidth $evv(SBDR)]
		label $fdt0.lab -text "Total Samples"
		entry $fdt0.e -textvariable pwtotalsamps -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $fdt0.lab -side left
		pack $fdt0.e -side right
		label $fdt1.lab -text "Duration in Seconds"
		entry $fdt1.e -textvariable pwtotaltime -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $fdt1.lab -side left
		pack $fdt1.e -side right
		pack $fdt.title $fdt.subtit1 $fdt0 $fdt.subtit2 $fdt1 -side top -fill x -expand true

		pack $fd.local -side left -fill x -expand true
		pack $fd.dum0 -side left -fill y -expand true
		pack $fd.marked -side left -fill x -expand true
		pack $fd.dum1 -side left -fill y -expand true
		pack $fd.total -side left -fill x -expand true

		pack $fb0 -side top -pady 2 -fill x -expand true
		pack $fb0a -side top -pady 2 -fill x -expand true
		pack $fb4 -side top -pady 2 -fill x -expand true 
		pack $fb5 -side top -pady 2 -fill x -expand true
		pack $fb2 -side top -pady 2 -fill x -expand true
		pack $fb1a -side top -pady 2 -fill x -expand true
		pack $fb1 -side top -pady 2 -fill x -expand true
		pack $fb3 -side top -pady 2 -fill x -expand true
		pack $fb $fc $fd -side top -pady 2 -fill x -expand true
		set playwsplice 15

		bind $playc	<Shift-ButtonPress-1> 			{PwBoxBegin %x %y}
		bind $playc	<Shift-B1-Motion> 				{PwBoxDrag %x %y}
		bind $playc	<Shift-ButtonRelease-1>			{PwBoxGet}
		bind $playc	<Shift-Control-ButtonPress-1>	{DelBox; PwClearBoxTimes}
		bind $playc <ButtonPress-1>					{PwSampMark %x %y}
		bind $playc	<B1-Motion> 					{PwSampMarkDrag %x}
		bind $playc	<Control-ButtonPress-1>			{DelSampMark}

		bind $f <KeyPress> {
			if [string match {[bB]} %A] {
				SampStep -1
			} elseif [string match {[fF]} %A] {
				SampStep 1
			} 
		}
		set pwkeepwhole 1
		set pwtimetyp 1
		set playwsvalk 1
		set playwevalk 1
		bind $f <Escape> {set pr_playw 0}
	}
	if {$export == "0"} {
		$f.button.1.sav config -text "SaveBrk" -command {PwSave 0 1 0} 
		$f.button.1.use config -text "UseBrk" -bd 2 -state normal
		$f.button.2.nf config -text "SaveData"  -command {PwSave 0 0 0}
		$f.button.2.af config -text "AddToFile" -state normal -bd 2
		$f.button.2.ef config -text "EditData" -state normal -bd 2
		$f.button.2.zz.name config -bd 2 -state normal
		$f.button.2.zz.standard config -text "Standard" -bd 2 -state normal -width 10
		$f.button.2.nm config -text "Filename"
		set pwdataname "_temp"
	} else {
		set pwdataname ""
		$f.button.1.sav config -text "ExportBrk" -command "PwSave 0 1 $export"
		$f.button.1.use config -text "" -bd 0 -state disabled
		$f.button.2.nf config -text "ExportData"  -command "PwSave 0 0 $export"
		$f.button.2.af config -text "" -state disabled -bd 0
		$f.button.2.ef config -text "" -state disabled -bd 0
		$f.button.2.zz.name config -bd 0 -state disabled
		$f.button.2.zz.standard config -text "" -bd 0 -state disabled
		$f.button.2.nm config -text ""
	}
	wm resizable .playwindow 1 1
	wm title $f "View and Edit Sound (alt-Click on Wkspace Soundfile to launch):            $pwfnam"
	PwBrkpnts -1
	set pwlinger $evv(PW_LINGER)
	set pwturn $evv(PW_TURN)
	set pwexpon $evv(PW_DFLT_EXP)
	PwClearSampVals
	PwClearBoxTimes
	set pr_playw 0
	set chanspw $pa($pwfnam,$evv(CHANS))
	set pwtotaltime  $pa($pwfnam,$evv(DUR))
	switch -- $chanspw {
		1 {
			set evv(PW_FOOT) $evv(MONO_PLAY_HEIGHT)
		}
		2 {
			set evv(PW_FOOT) $evv(STERE02_EDGE)
		}
		default {
			Inf "This Function Does Not Work For File With More Than 2 Channels"
			return
		}
	}
	$f.button.4.r config -text $pwtotaltime
	set pwsrate $pa($pwfnam,$evv(SRATE))
	set pwtotalsamps [expr $pa($pwfnam,$evv(INSAMS)) / $pa($pwfnam,$evv(CHANS))]
	set pwdur $pa($pwfnam,$evv(DUR))

	set pwseensampstart 0
	set pwseensampend $pwtotalsamps

	if {![DisplayPwData]} {
		Dlg_Dismiss $f
		return
	}
	if {$export != "0"} {
		set pwkeepwhole 2
		set playwsvalk 0
		set playwevalk 0
	}
	DisplayPwTotals
	set pwbrkset 1
	set pwbrktop "1"
	set pwbrkbot "0"
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_playw
	while {!$finished} {
		tkwait variable pr_playw
		if {!$pr_playw} {
			break
		}
	}
	catch {file delete $pwdisplaydata}
	My_Release_to_Dialog $f
	destroy $f
}

proc PwBrkpnts {typ} {
	global pwbrkpnts playc pwb pwbrktime pwbrkval pwchans pw_effective_width pwsamptime pwtotalsamps evv
	global pwmarksampstart pwmarksampend

	switch -- $typ {
		0 {
			catch {$playc delete bline}
			catch {$playc delete bpoint}
			set pwbrkpnts [list 0 0 $pw_effective_width 0]
			set pwb(isgrabbed) 0

		}
		1 -
		2 -
		3 -
		4 {
			;# ENABLE BRKPNT DRAW, DISABLE and BOX DRAW ... LINK BRKPNT DRAW TO VALUE SET In BOX ABOVE
			;# Need to delete existing brkpoints seen, and those in any lists....
			switch -- $typ {
				2 {
					if {![info exists pwsamptime] || ([string length $pwsamptime] <= 0)} {
						Inf "No Point Marked"
						return
					}
					set mark_time [expr int(round((double($pwsamptime) / double($pwtotalsamps)) * double($pw_effective_width)))]
				}
				3 {
					if {![info exists pwmarksampstart] || ([string length $pwmarksampstart] <= 0) \
					||  ![info exists pwmarksampend]   || ([string length $pwmarksampend] <= 0)} {
						Inf "No Box Drawn"
						return
					}
					set mark_time [expr int(round((double($pwmarksampstart) / double($pwtotalsamps)) * double($pw_effective_width)))]
					set mark_time2 [expr int(round((double($pwmarksampend) / double($pwtotalsamps)) * double($pw_effective_width)))]
				}
				4 {
					set qwq [LoadBrkfileForGraf]
					if {[llength $qwq] <= 0} {
						return
					}
				}
			}
			.playwindow.button.0.zoom config -state disabled
			.playwindow.button.0.zomo config -state disabled
			.playwindow.button.0.full config -state disabled
			.playwindow.button.0.samp config -state disabled
			.playwindow.button.0.mag config -state disabled
			.playwindow.button.0.sfwd config -state disabled
			.playwindow.button.0.sbak config -state disabled
			.playwindow.button.4.next config -state disabled
			.playwindow.button.4.last config -state disabled
			.playwindow.button.4.stt config -state disabled
			.playwindow.button.4.end config -state disabled
			.playwindow.button.4.goto config -state disabled
			.playwindow.button.0.mark config -state disabled -text ""
			.playwindow.button.4.box config -state disabled -text ""

			bind $playc <ButtonPress-1>			{}
			bind $playc	<B1-Motion> 			{}
			bind $playc	<Control-ButtonPress-1>	{}

			catch {$playc delete box}
			catch {$playc delete sampval}
			catch {$playc delete brk}
			catch {$playc delete bline}
			catch {$playc delete bpoint}
			.playwindow.button.1.bt.1.btt config -state normal
			.playwindow.button.1.bt.2.bvv config -state normal

			bind $playc <ButtonPress-1> 			{PwCreatePoint %W %x %y}
			bind $playc <Control-ButtonPress-1>		{PwDeletePoint %W %x %y}
			bind $playc <Command-Shift-ButtonPress-1>	{PwMarkPoint %W %x %y}
			bind $playc <Command-Shift-B1-Motion> 		{PwDragPoint %W %x %y}
			bind $playc <Command-ButtonPress-1> 		{PwMarkPoint %W %x %y}
			bind $playc <Command-B1-Motion> 			{PwDragPointVert %W %x %y}
			bind .playwindow <Delete> {DelBrkpntsInBox}

			bind .playwindow <ButtonRelease-1>		{PwTopEdgeCreatePoint %W %x %y}

			set pwb(isgrabbed) 0
			switch -- $typ {
				1 {
					set pwbrkpnts [list 0 0 $pw_effective_width 0]
				}
				2 {
					set pwbrkpnts [list 0 0 $mark_time $evv(HALF_PLAY_HEIGHT) $pw_effective_width 0]
				}
				3 {
					set pwbrkpnts [list 0 0 $mark_time $evv(HALF_PLAY_HEIGHT) $mark_time2 $evv(HALF_PLAY_HEIGHT) $pw_effective_width 0]
				}
				4 {
					set pwbrkpnts $qwq
				}
			}
			PwDrawGrafLine
			set zz $pwbrkpnts 
			set pwbrkpnts [list 0 0 $pw_effective_width 0]
			set pwbrkpnts $zz
		}
		-1 {
			.playwindow.button.0.zoom config -state normal
			.playwindow.button.0.zomo config -state normal
			.playwindow.button.0.full config -state normal
			.playwindow.button.0.samp config -state normal
			.playwindow.button.0.mag  config -state normal
			.playwindow.button.0.sfwd config -state normal
			.playwindow.button.0.sbak config -state normal
			.playwindow.button.4.next config -state normal
			.playwindow.button.4.last config -state normal
			.playwindow.button.4.stt  config -state normal
			.playwindow.button.4.end  config -state normal
			.playwindow.button.4.goto config -state normal
			.playwindow.button.0.mark config -state normal -text "Mark"
			.playwindow.button.4.box  config -state normal -text "Select"

			bind $playc <ButtonPress-1> 			{}
			bind $playc <Control-ButtonPress-1>		{}
			bind $playc <Command-ButtonPress-1> 		{}
			bind $playc <Command-B1-Motion> 			{}
			bind $playc <Command-Shift-ButtonPress-1> 	{}
			bind $playc <Command-Shift-B1-Motion> 		{}
			bind .playwindow <Delete> {}

			bind $playc <ButtonPress-1>					{PwSampMark %x %y}
			bind $playc	<B1-Motion> 					{PwSampMarkDrag %x}
			bind $playc	<Control-ButtonPress-1>			{DelSampMark}

			bind .playwindow <ButtonPress-1>		{}

			catch {$playc delete brk}
			catch {$playc delete bline}
			catch {$playc delete bpoint}
			catch {unset pwbrkpnts} 
			.playwindow.button.1.bt.1.btt config -state normal
			.playwindow.button.1.bt.2.bvv config -state normal
			set pwbrktime ""
			set pwbrkval ""
			.playwindow.button.1.bt.1.btt config -state disabled
			.playwindow.button.1.bt.2.bvv config -state disabled
			set pwb(isgrabbed) 0
			DelBox
		}
	}
}

proc PwCreatePoint {w x y} {
	global pw_effective_width pwb pwbrktime pwbrkval chanspw evv

	if {$pwb(isgrabbed)} {						;# Don't create point, if we are dragging a point
		set pwb(isgrabbed) 0
		return
	}
	if {($x <= 0) || ($x >= $pw_effective_width)} {
		Inf "Move Edge Points By Dragging Them"
		return
	}
	set pwb(rang) [GetPwRange]
	if {$pwb(rang) < 0} {
		return
	}
	set pwb(ew) [expr double($pw_effective_width)]
	if {$y < 0} {
		set y 0								 	 ;#	-> Top edge
	} elseif {$y > $evv(PW_FOOT)} {
		set y $evv(PW_FOOT)					;#	-> Bottom edge
	}
	if {![PwInjectPointIntoLists $x $y]} {
		return
	}
	set pwbrkreals [PwGetReals $x $y]
	set pwbrktime [lindex $pwbrkreals 0]
	set pwbrkval [lindex $pwbrkreals 1]
	PwDrawGrafLine
}

#------ Crate a '1.0' brkpnt val when click is above window

proc PwTopEdgeCreatePoint {w x y} {
	global pw_effective_width pwb pwbrktime pwbrkval chanspw evv

	if {($w != ".playwindow") || ($y < 230) || ($y > 240)} {
		return
	}
	set y 0
	set x [expr $x - 38]
	PwCreatePoint $w $x $y
}

#------ Put a newly created startpoint into the coords list

proc PwInjectStartPointIntoLists {y} {
	global pwbrkpnts

	if [string match [lindex $pwbrkpnts 1] $y] {
		return 0
	}
	set pwbrkpnts [lreplace $pwbrkpnts 1 1 $y]
	return 1
}

#------ Put a newly created endpoint into the coords list

proc PwInjectEndPointIntoLists {y} {
	global pwbrkpnts brkfrm brk

	set endd [llength $pwbrkpnts]
	incr endd -1
	if [string match [lindex $pwbrkpnts $endd] $y] {
		return 0
	}
	set pwbrkpnts [lreplace $pwbrkpnts $endd $endd $y]
	set pwbrkreals [PwGetReals $x $y]
	set pwbrkval [lindex $pwbrkreals 1]
	return 1
}

#------ Put a newly created point into the coords list

proc PwInjectPointIntoLists {x y} {
	global pwbrkpnts brk
	 
	set timindex 0

	foreach {xa ya} $pwbrkpnts {
		if [string match $x $xa] {
			return 0					;#	Cannot overwrite existing time
		} elseif {$xa < $x} {
			incr timindex 2
			continue
		}
		set pwbrkpnts [linsert $pwbrkpnts $timindex $x $y]
		return 1
		break
	}
	return 0
}

#------ Delete point closest to place where mouse clicks on inner-canvas

proc PwDeletePoint {w x y} {
	global playc pwbrkpnts pwbrktime pwbrkval evv

	set displaylist [$playc find withtag bpoint]	;#	List all objects which are points

	set mindiff 100000								;#	Find closest point
	foreach thisobj $displaylist {
		set coords [$playc coords $thisobj]
		set diff [expr abs($x - [lindex $coords 0])]
		if {$diff < $mindiff} {
			set obj $thisobj
			set mindiff $diff
		}
	}
	if {![info exists obj]} {
		return
	}
	set coords [$playc coords $obj]		 	 	;#	Only x-coord required, as can't have time-simultaneous points

	set x [expr round([lindex $coords 0])]			;#	Coords returns floats: convert to int

	set indx [PwFindForDelThisPointInList $x]

	if {$indx > 0} {							 ;#	Can't delete brktable endpoints
		set yindx [expr $indx + 1]
		catch {$playc delete $obj} in	 		 ;#	Delete it
		set pwbrkpnts [lreplace $pwbrkpnts $indx $yindx]
		PwDrawGrafLine
	}
	set pwbrktime ""
	set pwbrkval ""
}

#------ Mark point closest to place where mouse shift-clicks on inner-canvas

proc PwMarkPoint {w x y} {
	global pwb pwbrkpnts playc pwbrktime pwbrkval pw_effective_width evv
	set pwb(rang) [GetPwRange]
	if {$pwb(rang) < 0} {
		return
	}
	set pwb(ew) [expr double($pw_effective_width)]
	set pwb(isgrabbed) 0														
	set displaylist [$playc find withtag bpoint]		;#	List all objects which are points

	set mindiff 100000
	foreach thisobj $displaylist {
		set coords [$playc coords $thisobj]
		set diff [expr abs($x - [lindex $coords 0])]
		if {$diff < $mindiff} {
			set myobj $thisobj
			set mindiff $diff
		}
	}
	if {![info exists myobj]} {
		return
	}
	set pwb(obj) $myobj
	set coords [$playc coords $pwb(obj)]		 	 	
	set pwb(x) [expr round([lindex $coords 0])]			;#	Coords returns floats: convert to int
	set pwb(y) [expr round([lindex $coords 1])]			;#	as can't have time-simultaneous points

	set pwb(mx) $x							 			;# 	Save coords of mouse
	set pwb(my) $y

	set pwb(lastx) $pwb(x)							;#	Remember coords of point
	set pwb(lasty) $pwb(y)						

	set endd [llength $pwbrkpnts]
	incr endd -2
	set pwb(timindex) 0
	set preindex -2
	set postindex 2
	foreach {x y} $pwbrkpnts {
		if [string match $x $pwb(x)] {
			set pwb(leftstop)  [expr [lindex $pwbrkpnts $preindex] + 1]
			set pwb(rightstop) [expr [lindex $pwbrkpnts $postindex] -1]
			break
		}
		incr pwb(timindex) 2
		incr preindex 2
		incr postindex 2
	}
	if {($pwb(timindex) <= 0) || ($pwb(timindex) >= $endd)} {
		set pwb(isgrabbed) 2
	} else {
		set pwb(isgrabbed) 1											;#	Flag that a point is marked
	}
	set pwb(valindex) [expr $pwb(timindex) + 1]
	set pwbrkreals [PwGetReals $pwb(x) $pwb(y)]
	set pwbrktime [lindex $pwbrkreals 0]
	set pwbrkval [lindex $pwbrkreals 1]
}

#------ Drag marked point, with shift and mouse pressed down

proc PwDragPoint {w x y} {
	global pwb playc pwbrkpnts pwbrktime pwbrkval evv

	switch -- $pwb(isgrabbed) {
		0 {
			return
		}
		2 {
			PwDragEdgePoint $w $y
			return
		}
	}
	set dx [expr $x - $pwb(mx)]				;#	Find distance from last marked position of mouse
	set dy [expr $y - $pwb(my)]
	incr pwb(x) $dx								;#	Get coords of dragged point

	if {$pwb(x) >= $pwb(rightstop)} {			;#	Check for drag too far right, and, if ness
		set pwb(x) $pwb(rightstop)				;#	adjust coords of point
		set dx [expr $pwb(x) - $pwb(lastx)]		;#	and adjust drag-distance
	} elseif {$pwb(x) <= $pwb(leftstop)} {		;#	Check for drag too far left, and, if ness
		set pwb(x) $pwb(leftstop)				;#	adjust coords of point
		set dx [expr $pwb(x) - $pwb(lastx)]		;#	and adjust drag-distance
	}
	set pwb(lastx) $pwb(x)						;#	Remember new x coord
  
	incr pwb(y) $dy									
	if {$pwb(y) > $evv(PW_FOOT)} {				;#	Check for drag too far down, and, if ness
		set pwb(y) $evv(PW_FOOT)				;#	adjust coords of point
		set dy [expr $pwb(y) - $pwb(lasty)]		;#	and adjust drag-distance
	} elseif {$pwb(y) < 0} {
		set pwb(y) 0							;#	adjust coords of point
		set dy [expr $pwb(y) - $pwb(lasty)]		;#	and adjust drag-distance
	}

	set pwb(lasty) $pwb(y)						;#	Remember new y coord

	$w move $pwb(obj) $dx $dy				 	;#	Move object to new position
	set pwb(mx) $x							 	;#  Store new mouse coords
	set pwb(my) $y
	set pwbrkpnts [lreplace $pwbrkpnts $pwb(timindex) $pwb(valindex) $pwb(x) $pwb(y)]
	set pwbrkreals [PwGetReals $pwb(x) $pwb(y)]
	set pwbrktime [lindex $pwbrkreals 0]
	set pwbrkval [lindex $pwbrkreals 1]
	PwDrawGrafLine
}

#------ Drag marked point, with shift and mouse pressed down

proc PwDragPointVert {w x y} {
	global pwb
	if {$pwb(isgrabbed)} {
		PwDragEdgePoint $w $y
	}
}

#------ Find given point in coords list

proc PwFindForDelThisPointInList {xa} {
	global pwbrkpnts
	set endd [llength $pwbrkpnts]
	if {$endd <= 4} {
		return -1
	}
	incr endd -3
	set timindex 2
	foreach {x y} [lrange $pwbrkpnts 2 $endd] { ;# CAN'T DEL ENDPOINTS
		if [string match $x $xa] {
			return $timindex
		}
		incr timindex 2
	}
	return -1
}

#------ Draw line on graf

proc PwDrawGrafLine {} {
	global pwbrkpnts playc
	catch {$playc delete bline}
	catch {$playc delete bpoint}
	foreach {x y} $pwbrkpnts {
		lappend line_c $x $y
		$playc create rect $x $y $x $y -fill red -tag bpoint
	}
	eval {$playc create line} $line_c {-fill red} {-tag bline}
}

proc PwDragEdgePoint {w y} {
	global pwb playc pwbrkpnts pwbrkval evv

	set dy [expr $y - $pwb(my)]
  
	incr pwb(y) $dy									
	if {$pwb(y) > $evv(PW_FOOT)} {				;#	Check for drag too far down, and, if ness
		set pwb(y) $evv(PW_FOOT)				;#	adjust coords of point
		set dy [expr $pwb(y) - $pwb(lasty)]		;#	and adjust drag-distance
	} elseif {$pwb(y) < 0} {
		set pwb(y) 0							;#	adjust coords of point
		set dy [expr $pwb(y) - $pwb(lasty)]		;#	and adjust drag-distance
	}

	set pwb(lasty) $pwb(y)						;#	Remember new y coord

	$w move $pwb(obj) 0 $dy					 	;#	Move object to new position
	set pwb(my) $y
	set pwbrkpnts [lreplace $pwbrkpnts $pwb(timindex) $pwb(valindex) $pwb(x) $pwb(y)]
	set pwbrkreals [PwGetReals $pwb(x) $pwb(y)]
	set pwbrkval [lindex $pwbrkreals 1]
	PwDrawGrafLine
}

proc PwSeeBrkpnts {} {
	global pwbrkpnts pwbrkbot pwbrktop pwseentimestart pwseentimedur pw_effective_width pwseebrk pr_pwseebrk evv
	global pwb pwtotaltime wstk

	if {![info exists pwbrkpnts]}  {
		Inf "No Breakpoints Drawn"
		return
	}
	if {![IsNumeric $pwbrkbot] || ![IsNumeric $pwbrktop]} {
		Inf "Invalid Range Value(s)"
		return
	}
	if {$pwbrkbot > $pwbrktop} {
		Inf "Range Values Inverted"
		return
	} elseif {[Flteq $pwbrkbot $pwbrktop]} {
		Inf "No Significant Range Of Values"
		return
	}
	set pwb(ew) [expr double($pw_effective_width)]
	set pwb(rang) [expr $pwbrktop - $pwbrkbot]
	set callcentre [GetCentre [lindex $wstk end]]
	set f .pwseebrk
	if [Dlg_Create $f "BREAKPOINT VALUES" "set pr_pwseebrk 1" -borderwidth $evv(BBDR)] {
		button $f.ok -text "OK" -command "set pr_pwseebrk 1" -highlightbackground [option get . background {}]
		set pwseebrk [Scrolled_Listbox $f.ll -width 60 -height 20 -selectmode single]
		pack $f.ok $f.ll -side top -pady 2
		bind $f <Return> {set pr_pwseebrk 1}
		bind $f <Escape> {set pr_pwseebrk 1}
		bind $f <Key-space> {set pr_pwseebrk 1}
	}

	$pwseebrk delete 0 end
	set cnt 0
	foreach {x y} $pwbrkpnts {
		set outcoords [PwGetReals $x $y]
		set lastval [lindex $outcoords 1]
		if {($cnt == 0) && ([lindex $outcoords 0] != 0.0)} {
			set extracoords 0.00000
			lappend extracoords $lastval
			$pwseebrk insert end $extracoords
		}
		$pwseebrk insert end $outcoords
		incr cnt
	}
	set last_time [lindex $outcoords 0]
	if {$last_time < $pwtotaltime} {
		set extracoords $pwtotaltime
		lappend extracoords $lastval
		$pwseebrk insert end $extracoords
	}
	wm resizable .pwseebrk 1 1
	set pr_pwseebrk 0
	raise $f
	update idletasks
	set geo [CentreOnCallingWindow $f $callcentre]
	My_Grab 0 $f pr_pwseebrk
	wm geometry $f $geo
	tkwait variable pr_pwseebrk
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc PwGetReals {x y} {
	global pwseentimedur pwseentimestart pwbrkbot pwb evv

	set x [expr (double($x) / $pwb(ew)) * $pwseentimedur]
	set x [expr $x + $pwseentimestart]
	set x [FiveDecPlaces $x]
	set y [expr $evv(PW_FOOT) - $y]
	set y [expr double($y) / double($evv(PW_FOOT))]
	set y [expr ($pwb(rang) * $y) + $pwbrkbot]
	set y [FiveDecPlaces $y]
	set out $x
	lappend out $y
	return $out
}

proc GetPwRange {} {
	global pwbrkbot pwbrktop 

	if {![IsNumeric $pwbrkbot] || ![IsNumeric $pwbrktop]} {
		Inf "Invalid Range Value(s)"
		return -1
	}
	if {$pwbrkbot > $pwbrktop} {
		Inf "Range Values Inverted"
		return -1
	} elseif {[Flteq $pwbrkbot $pwbrktop]} {
		Inf "No Significant Range Of Values"
		return -1
	}
	set rang [expr $pwbrktop - $pwbrkbot]
	return $rang
}

proc DelBrkpntsInBox {} {
	global pwbrkpnts playc pwbrktime pwbrkval pw_effective_width

	if {![info exists pwbrkpnts]} {
		return
	}
	set obj [$playc find withtag box]
	if {![info exists obj] || ([llength $obj] <= 0)} {
		return
	}
	set len [llength $pwbrkpnts]
	if {$len <= 4} {
		return
	}
	incr len -2
	set coords [$playc coords $obj]
	set minx [lindex $coords 0]
	set maxx [lindex $coords 2]
	set cnt 2
	set ycnt 3
	while {$cnt < $len} {
		set x [lindex $pwbrkpnts $cnt]
		if {($x > $minx) && ($x < $maxx)} {
			set pwbrkpnts [lreplace $pwbrkpnts $cnt $ycnt]
			incr len -2
		} else {
			incr cnt 2
			incr ycnt 2
		}
	}
	set pwbrktime ""
	set pwbrkval ""
	DelBox
	PwDrawGrafLine
}

proc PwSmooth {} {
	global pwbrkpnts pwlinger pwturn evv

	if {![info exists pwbrkpnts]} {
		return
	}
	set len [llength $pwbrkpnts]
	if {$len <= 6} {
		return
	}
	if {![IsNumeric $pwlinger] || ($pwlinger < .05) || ($pwlinger > .9)} {
		Inf "Invalid 'Linger' Value\n\nlinger Is The Proportion Of The Pan Duration Spent Turning\n\nRange .05 to 9"
		return
	}
	if {![IsNumeric $pwturn] || ($pwturn < .05) || ($pwturn > .9)} {
		Inf "Invalid 'Turn' Value\n\nturn Is The Proportion Of The Pan Width Used For Turning\n\nRange .05 to 9"
		return
	}
	set xcnt 2
	set ycnt 3
	set nextxcnt 4
	set nextycnt 5
	set lastx [lindex $pwbrkpnts 0]
	set lasty [lindex $pwbrkpnts 1]
	set x [lindex $pwbrkpnts 2]
	set y [lindex $pwbrkpnts 3]
	while {$nextxcnt < $len} {
		set nextx [lindex $pwbrkpnts $nextxcnt]
		set nexty [lindex $pwbrkpnts $nextycnt]
		set prestep [expr $y - $lasty]
		set postep  [expr $nexty - $y]
		set doinsert 0
		if {$prestep < 0} {
			if {$postep > 0} {
				set doinsert 1
			} 
		} elseif {$prestep > 0} {
			if {$postep < 0} {
				set doinsert 1
			}
		}
		if {$doinsert} {
			set pretimstep [expr $x - $lastx]
			set postimstep [expr $nextx - $x]
			set pretimstep [expr int(round($pretimstep * $pwlinger))]
			if {$pretimstep > 0} {
				set newpretime [expr $x - $pretimstep]
				set postimstep [expr int(round($postimstep * $pwlinger))]
				if {$postimstep > 0} {
					set newpostime [expr $x + $postimstep]
					set prestep [expr int(round($prestep * $pwturn))]	
					if {[expr abs($prestep)] > 0} {
						set newpreval [expr $y - $prestep]
						set postep [expr int(round($postep * $pwturn))]	
						if {[expr abs($postep)] > 0} {
							set newpostval [expr $y + $postep]
							set pwbrkpnts [linsert $pwbrkpnts $xcnt $newpretime $newpreval]
							incr xcnt 4
							set pwbrkpnts [linsert $pwbrkpnts $xcnt $newpostime $newpostval]
							incr ycnt 4
							incr nextxcnt 4
							incr nextycnt 4
							incr len 4
						}
					}
				}
			}
		}
		set lastx $x
		set lasty $y
		set x $nextx
		set y $nexty
		incr xcnt 2
		incr ycnt 2
		incr nextxcnt 2
		incr nextycnt 2
	}
	PwDrawGrafLine
}

proc PwExponentiate {convex} {
	global pwbrkpnts pwb playc pw_effective_width pwexpon evv

	if {![info exists pwbrkpnts]} {
		return
	}
	set obj [$playc find withtag box]
	if {![info exists obj] || ([llength $obj] <= 0)} {
		return
	}
	set len [llength $pwbrkpnts]
	if {$len < 4} {
		return
	}
	if {![IsNumeric $pwexpon] || ($pwexpon <= 1.0) || ($pwexpon > 10.0)} {
		Inf "Invalid 'Exponent' Value\n\nExponent Describes The Steepness Of The Curve To Apply\n\nRange >1 to 10"
		return
	}
	set coords [$playc coords $obj]
	set minx [lindex $coords 0]
	set maxx [lindex $coords 2]
	set getpoint -1
	set cnt 0
	set ycnt 1
	while {$cnt < $len} {
		set x [lindex $pwbrkpnts $cnt]
		if {($x > $minx) && ($x < $maxx)} {
			set getpoint $cnt
		}
		incr cnt 2
		incr ycnt 2
	}
	if {$getpoint == 0} {
		Inf "Can't Exponentiate Before First Breakpoint"
		return
	} elseif {$getpoint < 0} {
		if {$maxx >= [expr $pw_effective_width - 1]} {
			incr cnt -2
			incr ycnt -2
			set x [lindex pwbrkpnts $xcnt]
			set y [lindex pwbrkpnts $ycnt]
		} else {
			Inf "Failed To Find Point For Exponentiation"
			return
		}
	} else {
		set cnt $getpoint
		set x [lindex $pwbrkpnts $getpoint]
		incr getpoint
		set y [lindex $pwbrkpnts $getpoint]
	}
	incr cnt -2
	set lastx [lindex $pwbrkpnts $cnt]
	incr cnt
	set lasty [lindex $pwbrkpnts $cnt]
	incr cnt
	set timestep [expr $x - $lastx]
	set timestep [expr int(round(double($timestep) / 8.0))]
	if {$timestep <= 0} {
		Inf "Insufficient Display Resolution To Insert New Points"
		return
	}
	set valstep  [expr $y - $lasty]
	set isneg 0
	if {$valstep > 0} {	;# NB Display is upside down relative to users values!!
		set isneg 1
	}
	set valstep [expr abs($valstep)]
	set n 0
	set time [expr $x - $timestep]
	if {$isneg} {
		if {$convex} {
			set valmove .825
		} else {
			set valmove .125
		}
	} else {
		if {$convex} {
			set valmove .125
		} else {
			set valmove .875
		}
	}
	set valmovestep .125

	while {$n < 7} {
		set val [expr $valstep * pow($valmove,$pwexpon)]
		if {$convex} {
			if {$isneg} {
				set val [expr $lasty + $val]
				set valmove [expr $valmove - $valmovestep]
			} else {
				set val [expr $y + $val]
				set valmove [expr $valmove + $valmovestep]
			}
		} else {
			if {$isneg} {
				set val [expr $y - $val]
				set valmove [expr $valmove + $valmovestep]
			} else {
				set val [expr $lasty - $val]
				set valmove [expr $valmove - $valmovestep]
			}
		}
		set pwbrkpnts [linsert $pwbrkpnts $cnt $time $val]
		set time [expr $time - $timestep]
		incr n
	}
	PwDrawGrafLine
}

############# EXPTL ##################

#----------- Analysis File Display Options

proc AnalysisDisplayOptions {fnam} {
	global pw_ado wstk evv

	set f .ado
	set callcentre [GetCentre [lindex $wstk end]]
	if [Dlg_Create $f "TYPE OF ANALYSIS FILE DISPLAY" "set pw_ado 1" -borderwidth $evv(BBDR)] {
		button $f.ok -text "Close" -command "set pw_ado 0" -highlightbackground [option get . background {}]
		button $f.sono -text "Sonogram Display" -command "set pw_ado 1" -highlightbackground [option get . background {}]
		button $f.spec -text "Spectral Display" -command "set pw_ado 2" -highlightbackground [option get . background {}]
		pack $f.ok $f.sono $f.spec -side left -pady 2
	}
	wm resizable .ado 1 1
	set pw_ado 0
	set finished 0
	raise $f
	update idletasks
	set geo [CentreOnCallingWindow $f $callcentre]
	My_Grab 0 $f pw_ado
	wm geometry $f $geo
	tkwait variable pw_ado
	switch -- $pw_ado {
		1 {
			AnalysisDisplay $fnam 1
		}
		2 {
			AnalysisDisplay $fnam 0
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--------- Analysis File Display

proc AnalysisDisplay {fnam is_sonogram} {
	global playw playc pr_playw pwdataname playwsvalk playwevalk pwtimetyp wl pw_p pa evv
	global pwseenwinstart pwseenwinend pwseenwindur 
	global pwseentimestart pwseentimeend pwseentimedur 
	global pwmarkwinstart pwmarkwinend pwmarkwindur 
	global pwmarktimestart pwmarktimeend pwmarktimedur 
	global  pwtotalwins true_play_width pwarate pwdur pwscalefact
	global maxpw storepw chanspw pwfnam pwvalscale pwwinval pwwintime pwstchan pwstfrq pwchanval
	global pwslider pwtime pwismarked pwkeepwhole pwcutname pwlastaction pwhzwidth pwoutfnam2
	global pwoutfnam pwdisplaydata pwlastx pwfull pwbrktop pwbrkbot pwbrkset pwbrktime pwbrkval
	global pwlinger pwturn pwexpon sonogram pw_ado pwaspect wincntpw pwendchan pwstartchan
	global pw_start_chan_in_val pw_end_chan_in_val pw_start_time_in_val pw_end_time_in_val readonlyfg readonlybg

	set pwdataname "_temp"
	set pwcutname ""
	set pwlastaction ""

	set pwdisplaydata $evv(DFLT_OUTNAME)
	append pwdisplaydata 00 $evv(TEXT_EXT)
	set pwoutfnam2 $evv(DFLT_OUTNAME)
	append pwoutfnam2 1 $evv(SNDFILE_EXT)

	set pwscalefact 1
	set pwismarked 0
	catch {file delete $pwdisplaydata}
	set pwfnam $fnam

	if {[info exists pwfull] && ($pwfull != 2)} {
		destroy .playwindow
	}
	set pwfull 2

	Block "Creating Display Files"
	UnBlock
	set f .playwindow
	if [Dlg_Create $f "Select and Play" "set pr_playw 0" -borderwidth $evv(BBDR) -width $evv(PLAY_WIDTH)] {
		set fb [frame $f.button -borderwidth $evv(SBDR)]		;#	frame for buttons
		set fc [frame $f.canvas -borderwidth $evv(SBDR)]		;#	frame for canvas
		set fd [frame $f.info -borderwidth $evv(SBDR)]		;#	frame for info
		set fb0 [frame $fb.0 -borderwidth $evv(SBDR)]
		set fb0a [frame $fb.0a -bg [option get . foreground {}] -height 1]
		set fb1 [frame $fb.1 -borderwidth $evv(SBDR)]
		set fb3 [frame $fb.3 -bg [option get . foreground {}] -height 1]
		set fb4 [frame $fb.4 -borderwidth $evv(SBDR)]
		set fb5 [frame $fb.5 -bg [option get . foreground {}] -height 1]
		label  $fb0.view -text "VIEW: " -fg $evv(SPECIAL)
		button $fb0.zoom -text "Zoom To Box" -command {set pr_playw [AnalZoomIn 0]} -width 12 -highlightbackground [option get . background {}]
		button $fb0.zomo -text "Zoom To Vals" -command {set pr_playw [AnalZoomIn 1]}  -width 12 -highlightbackground [option get . background {}]
		button $fb0.full -text "Full View" -command {set pr_playw [AnalFullView]}  -width 8 -highlightbackground [option get . background {}]
		button $fb0.mag -text "Magnify" -command AnalPwMagnify  -width 8 -highlightbackground [option get . background {}]	
		label $fb0.svl  -text "Window"
		entry  $fb0.sval -textvariable pwwinval -width 7 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label  $fb0.svs  -text "Time" 
		entry  $fb0.svas -textvariable pwwintime -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label  $fb0.svc  -text "Chan" 
		entry  $fb0.svac -textvariable pwstchan -width 4 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label  $fb0.svc2  -text "Centre Frq" 
		entry  $fb0.svac2 -textvariable pwstfrq -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label  $fb0.svt  -text "Value" 
		entry  $fb0.svat -textvariable pwchanval -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		button $fb0.sfwd -text "->" -command {WinStep 1} -highlightbackground [option get . background {}]
		button $fb0.sbak -text "<-" -command {WinStep -1} -highlightbackground [option get . background {}]

		pack $fb0.view \
			$fb0.zoom $fb0.zomo $fb0.full $fb0.mag \
			 $fb0.svl $fb0.sval $fb0.sfwd $fb0.sbak $fb0.svs $fb0.svas $fb0.svc $fb0.svac $fb0.svc2 $fb0.svac2 $fb0.svt $fb0.svat -side left -padx 2

		label $fb1.rng -text "TYPE"
		radiobutton $fb1.nrm -text "Spectrum" -value 0 -variable sonogram -state disabled -command "RedrawAnal 0"
		radiobutton $fb1.pan -text "Sonogram" -value 1 -variable sonogram -state disabled -command "RedrawAnal 1"

		menubutton $fb1.box -text "Select" -menu $fb1.box.menu -relief raised -width 7
		set sb [menu $fb1.box.menu -tearoff 0]
		$sb add command -label "Expand Box To Start Of Display" -command {PwAnalPushBox 0} -foreground black
		$sb add separator
		$sb add command -label "Expand Box To End Of Display" -command {PwAnalPushBox 1} -foreground black
		$sb add separator
		$sb add command -label "Expand Box To Mark" -command {PwAnalBoxtoMark} -foreground black
		$sb add separator
		$sb add command -label "Cut Off Box After Mark" -command {PwAnalBoxCut 0} -foreground black
		$sb add separator
		$sb add command -label "Cut Off Box Before Mark" -command {PwAnalBoxCut 1} -foreground black

		menubutton $fb1.info -text "Info" -menu $fb1.info.menu -relief raised -width 6 ;# -background $evv(HELP)
		set m [menu $fb1.info.menu -tearoff 0]
		$m add command -label "IN ANY MODE" -command {}  -foreground black
		$m add separator ;# -background $evv(HELP)
		$m add command -label "Select A Box:      Shift-Mouse-Drag" -command {} -foreground black
		$m add separator
		$m add command -label "Remove A Box:    Control-Shift-Mouse-Click" -command {} -foreground black
		$m add separator
		$m add command -label "     Also see 'SELECT' menu" -command {} -foreground $evv(SPECIAL)
		$m add separator
		$m add command -label "Mark,See Val:     Mouse-Click" -command {} -foreground black
		$m add separator
		$m add command -label "Move Mark:         Mouse-Drag" -command {} -foreground black
		$m add separator
		$m add command -label "Remove Mark:     Control-Mouse-Click" -command {} -foreground black

		pack $fb1.info $fb1.rng $fb1.nrm $fb1.pan -side left -padx 1

		label $fb1.user -text "Selection Limit Values : "
		label $fb1.schlo -text "Channel  Lo"
		entry $fb1.schloe -textvariable pw_start_chan_in_val -width 5
		label $fb1.schhi -text "Hi"
		entry $fb1.schhie -textvariable pw_end_chan_in_val -width 5
		label $fb1.stlo -text "Time Start"
		entry $fb1.stloe -textvariable pw_start_time_in_val -width 12
		label $fb1.sthi -text "End"
		entry $fb1.sthie -textvariable pw_end_time_in_val -width 12

		button $fb1.quit -text Close -command "set pr_playw 0" -bg $evv(EMPH) -highlightbackground [option get . background {}]
		label $fb1.dum -text "        "
		pack $fb1.quit $fb1.dum $fb1.sthie $fb1.sthi $fb1.stloe $fb1.stlo $fb1.schhie $fb1.schhi $fb1.schloe $fb1.schlo $fb1.user $fb1.box -side right -padx 1

		set playc [Sound_Canvas $fc.c -width $evv(PLAY_WIDTH) -height $evv(PLAY_HEIGHT) \
									-scrollregion "0 0 $evv(PLAY_WIDTH) $evv(SCROLL_HEIGHT)"]
		pack $fc.c -side top
		set fdl [frame $fd.local -borderwidth $evv(SBDR)]
		frame $fd.dum0 -bg [option get . foreground {}] -width 1
		set fdm [frame $fd.marked -borderwidth $evv(SBDR)] 
		frame $fd.dum1 -bg [option get . foreground {}] -width 1
		set fdt [frame $fd.total -borderwidth $evv(SBDR)] 
		label $fdl.title -text "DISPLAY SEEN"
		label $fdl.subtit1 -text "In Windows"
		set fdl0 [frame $fdl.0 -borderwidth $evv(SBDR)]
		label $fdl.subtit2 -text "In Seconds"
		set fdl1 [frame $fdl.1 -borderwidth $evv(SBDR)]
		label $fdl0.lab0 -text "Start"
		entry $fdl0.e0 -textvariable pwseenwinstart -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $fdl0.lab1 -text "End"
		entry $fdl0.e1 -textvariable pwseenwinend -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $fdl0.lab2 -text "Duration"
		entry $fdl0.e2 -textvariable pwseenwindur -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $fdl0.lab0 $fdl0.e0 $fdl0.lab1 $fdl0.e1 $fdl0.lab2 $fdl0.e2 -side left
		label $fdl1.lab0 -text "Start"
		entry $fdl1.e0 -textvariable pwseentimestart -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $fdl1.lab1 -text "End"
		entry $fdl1.e1 -textvariable pwseentimeend -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $fdl1.lab2 -text "Duration"
		entry $fdl1.e2 -textvariable pwseentimedur -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $fdl1.lab0 $fdl1.e0 $fdl1.lab1 $fdl1.e1 $fdl1.lab2 $fdl1.e2 -side left
		pack $fdl.title -side top
		pack $fdl.subtit1 $fdl0 $fdl.subtit2 $fdl1 -side top -fill x -expand true

		label $fdm.title -text "BOX SELECTED"
		label $fdm.subtit1 -text "In Windows"
		set fdm0 [frame $fdm.0 -borderwidth $evv(SBDR)]
		label $fdm.subtit2 -text "In Seconds"
		set fdm1 [frame $fdm.1 -borderwidth $evv(SBDR)]
		label $fdm0.lab0 -text "Start"
		entry $fdm0.e0 -textvariable pwmarkwinstart -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $fdm0.lab1 -text "End"
		entry $fdm0.e1 -textvariable pwmarkwinend -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $fdm0.lab2 -text "Duration"
		entry $fdm0.e2 -textvariable pwmarkwindur -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $fdm0.lab0 $fdm0.e0 $fdm0.lab1 $fdm0.e1 $fdm0.lab2 $fdm0.e2 -side left
		label $fdm1.lab0 -text "Start"
		entry $fdm1.e0 -textvariable pwmarktimestart -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $fdm1.lab1 -text "End"
		entry $fdm1.e1 -textvariable pwmarktimeend -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $fdm1.lab2 -text "Duration"
		entry $fdm1.e2 -textvariable pwmarktimedur -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $fdm1.lab0 $fdm1.e0 $fdm1.lab1 $fdm1.e1 $fdm1.lab2 $fdm1.e2 -side left
		pack $fdm.title -side top
		pack $fdm.subtit1 $fdm0 $fdm.subtit2 $fdm1 -side top -fill x -expand true

		label $fdt.title -text "WHOLE FILE"
		label $fdt.subtit1 -text ""
		set fdt0 [frame $fdt.0 -borderwidth $evv(SBDR)]
		label $fdt.subtit2 -text ""
		set fdt1 [frame $fdt.1 -borderwidth $evv(SBDR)]
		label $fdt0.lab -text "Total Windows"
		entry $fdt0.e -textvariable pwtotalwins -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $fdt0.lab -side left
		pack $fdt0.e -side right
		label $fdt1.lab -text "Duration in Seconds"
		entry $fdt1.e -textvariable pwdur -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $fdt1.lab -side left
		pack $fdt1.e -side right
		pack $fdt.title $fdt.subtit1 $fdt0 $fdt.subtit2 $fdt1 -side top -fill x -expand true

		pack $fd.local -side left -fill x -expand true
		pack $fd.dum0 -side left -fill y -expand true
		pack $fd.marked -side left -fill x -expand true
		pack $fd.dum1 -side left -fill y -expand true
		pack $fd.total -side left -fill x -expand true

		label  $fb4.edit -text "EDIT: " -fg $evv(SPECIAL)
		button $fb4.syn -text "Keep Selection" -command {PwGrab 0}   -width 16 -highlightbackground [option get . background {}]
		button $fb4.del -text "Delete Selection" -command {PwGrab 1} -width 16 -highlightbackground [option get . background {}]
		label $fb4.lab -text outfilename
		entry $fb4.e -textvariable pwcutname -width 16
		button $fb4.cyc -text "View New File" -command {PwRecycleAnal} -width 16 -highlightbackground [option get . background {}]
		pack $fb4.edit $fb4.syn $fb4.del $fb4.lab $fb4.e $fb4.cyc -side left -padx 1
		
		pack $fb1 -side top -pady 2 -fill x -expand true
		pack $fb3 -side top -pady 2 -fill x -expand true
		pack $fb0 -side top -pady 2 -fill x -expand true
		pack $fb0a -side top -pady 2 -fill x -expand true
		pack $fb4 -side top -pady 2 -fill x -expand true
		pack $fb5 -side top -pady 2 -fill x -expand true
		pack $fb $fc $fd -side top -pady 2 -fill x -expand true
		bind $playc	<Shift-ButtonPress-1> 			{PwAnalBoxBegin %x %y}
		bind $playc	<Shift-B1-Motion> 				{PwBoxDrag %x %y}
		bind $playc	<Shift-ButtonRelease-1>			{PwAnalBoxGet}
		bind $playc	<Shift-Control-ButtonPress-1>	{DelAnalBox; PwAnalClearBoxTimes}
		bind $playc <ButtonPress-1>					{PwAnalSampMark %x %y}
		bind $playc	<B1-Motion> 					{PwAnalSampMarkDrag %x}
		bind $playc	<Control-ButtonPress-1>			{DelAnalSampMark}

		set pwkeepwhole 1
		set pwtimetyp 1
		set playwsvalk 1
		set playwevalk 1
		bind $f <Escape> {set pr_playw 0}
	}
	.playwindow.button.1.nrm config -state normal
	.playwindow.button.1.pan config -state normal
	set sonogram $is_sonogram
	.playwindow.button.1.nrm config -state disabled
	.playwindow.button.1.pan config -state disabled
	wm resizable .playwindow 1 1
	wm title $f "SPECTRAL DISPLAY:                                       $pwfnam"
	PwAnalClearSampVals
	PwAnalClearBoxTimes
	set pr_playw 0
	set chanspw $pa($pwfnam,$evv(CHANS))
    set wincntpw [expr $pa($pwfnam,$evv(INSAMS)) / $pa($pwfnam,$evv(CHANS))]

#
#	$f.button.4.r config -text $pwdur
#
	set pwarate $pa($pwfnam,$evv(ARATE))
	set pwtotalwins [expr $pa($pwfnam,$evv(INSAMS)) / $pa($pwfnam,$evv(CHANS))]
	set pwdur $pa($pwfnam,$evv(DUR))

	set pwseentimestart 0
	set pwseentimeend $pwdur
	set pwseentimedur $pwdur
	set pwstartchan 0
	set pwendchan [expr (($chanspw)/2) - 1]

	set nyquist [expr double($pa($pwfnam,$evv(ORIGRATE))) / 2.0]
	set pwhzwidth [expr $nyquist / $pwendchan]

	if {![DisplayPwAnalData $sonogram]} {
		Dlg_Dismiss $f
		return
	}
	.playwindow.button.1.nrm config -state normal
	.playwindow.button.1.pan config -state normal
	set pwbrkset 1
	set pwbrktop "1"
	set pwbrkbot "0"
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_playw
	while {!$finished} {
		tkwait variable pr_playw
		if {!$pr_playw} {
			break
		}
	}
	catch {file delete $pwdisplaydata}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

##############################
# DISPLAY THE SPECTRAL IMAGE #
##############################

proc DisplayPwAnalData {sonogram} {
	global maxpw storepw pwscalefact playc pwseentimestart pwseentimeend evv
	global pwismarked pwfnam storepw2 pwvalscale truestorepw truestorepw2 pwbox pwdisplaydata 
	global pwlastx pw_effective_width pw_effective_max pwthiscol pw_wcnt pwstartchan pwendchan
	global pwseenwinstart pwseenwinend pwseenwindur
	global pwspeclines pwarate

	catch {$playc delete vsound} in		;#	destroy any existing points
	DelAnalSampMark
	DelAnalBox
	PwAnalClearBoxTimes
	Block "Calculating Analysis File Display"

	set msg [GenerateAnalDisplayData $pwfnam $pwseentimestart $pwseentimeend $sonogram $pwstartchan $pwendchan]
	if {[string length $msg] > 0} {
		Inf $msg
		UnBlock
		return 0
	}
	if [catch {open $pwdisplaydata r} zit] {
		Inf "Cannot Open testdisplay File"
		UnBlock
		return 0
	}
	UnBlock
	if {$sonogram} {
		Block "DRAWING THE SONOGRAM DISPLAY: MAY TAKE SOME TIME"
		set rgb [winfo rgb .playwindow $evv(SONOGRAM_BKGD)]
		set rgb2 [winfo rgb .playwindow $evv(SONOGRAM_FGD)]

		set r0 [lindex $rgb 0]
		set g0 [lindex $rgb 1]
		set b0 [lindex $rgb 2]
		set r1 [lindex $rgb2 0]
		set g1 [lindex $rgb2 1]
		set b1 [lindex $rgb2 2]
		set difr [expr $r1 - $r0]
		set difg [expr $g1 - $g0]
		set difb [expr $b1 - $b0]
		set thiscolor(0) $rgb
		set n 1
		set m 0
		while {$n <= $evv(COLOR_SPECTRUM)} {
			set pwthiscol($m) [format "#%04x%04x%04x" [lindex $thiscolor($m) 0] [lindex $thiscolor($m) 1] [lindex $thiscolor($m) 2]]
			set thiscolor($n) [ColorChange $r0 $g0 $b0 $difr $difg $difb $n]
			incr m
			incr n
		}
		set pwthiscol($m) [format "#%04x%04x%04x" [lindex $thiscolor($m) 0] [lindex $thiscolor($m) 1] [lindex $thiscolor($m) 2]]
	} else {
		Block "DRAWING THE DISPLAY"
	}
	set x 0
	set winoffset 0
	set y2 $evv(PLAY_HEIGHT)
	set y3 $y2
	incr y3
	set y3bas $y3
	set pw_wcnt 0
	catch {unset pwspeclines}
	while {[gets $zit line] >= 0 } {
		set line [split $line]
		catch {unset nuline}
		foreach val $line {
			if {[IsNumeric $val]} {
				lappend nuline $val
			}
		}
		set line $nuline
		set y2 $evv(PLAY_HEIGHT)				;# reset chan display to bottom
		set y3 $y3bas
		lappend	pwspeclines $line
		if {$sonogram} {
			foreach val $line {
				set coords [list $x $y2 $x $y3]
				if {$val < 0} {
					set $val 0
				} elseif {$val > $evv(COLOR_SPECTRUM)} {
					set val $evv(COLOR_SPECTRUM)
				}
				eval {$playc create line} $coords {-fill $pwthiscol($val) -tag vsound}
				incr y2 -1
				incr y3 -1
			}
			incr x
		} else {
			foreach val $line {
				set y [expr $y2 - $val]
				set coords [list $x $y2 $x $y]
				eval {$playc create line} $coords {-fill $evv(GRAFSND) -tag vsound}
				set y [expr $y - 1.0]
				lappend qqq $x $y
				incr x
				incr y2 -1
			}
			eval {$playc create line} $qqq {-fill $evv(HELP) -tag vsound}	;# DRAWS OUTLINE ROUND EACH WINDOW-SLATE
			unset {qqq}
			incr winoffset 2						
			set x $winoffset						;# reset window displaystart to left
		}
		incr pw_wcnt
	}
	close $zit
	UnBlock
	.playwindow.info.local.0.e0 config -state normal
	.playwindow.info.local.0.e1 config -state normal
	.playwindow.info.local.0.e2 config -state normal
	set pwseenwinstart [expr int(round($pwseentimestart * $pwarate))]
	set pwseenwinend   [expr int(round($pwseentimeend * $pwarate))]
	set pwseenwindur [expr $pwseenwinend - $pwseenwinstart]
	.playwindow.info.local.0.e0 config -state disabled
	.playwindow.info.local.0.e1 config -state disabled
	.playwindow.info.local.0.e2 config -state disabled
	return 1
}

proc GenerateAnalDisplayData {fnam start end sonogram startchan endchan} {
	global CDPidrun do_data data_msg evv
	set data_msg ""
	set cmd [file join $evv(CDPROGRAM_DIR) paview]
	set fnam [OmitSpaces $fnam]
	set cmd [concat $cmd $fnam $start $end $sonogram $startchan $endchan]
	if [catch {open "|$cmd"} CDPidrun] {
		return "  $CDPidrun"
   	} else {
   		fileevent $CDPidrun readable "PviewReports"
		vwait do_data
   	}
	if {!$do_data} {
		return $data_msg
	}
	return ""
}

proc ColorChange {r g b difr difg difb n} {
	global evv
	set frac [expr double($n)/double($evv(COLOR_SPECTRUM))]
	set difr [expr int(round($difr * $frac))]
	set difg [expr int(round($difg * $frac))]
	set difb [expr int(round($difb * $frac))]
	incr r $difr
	incr g $difg
	incr b $difb
	return [list $r $g $b]
}

proc RedrawAnal {sonogram} {

	.playwindow.button.1.nrm config -state disabled
	.playwindow.button.1.pan config -state disabled

	if {![DisplayPwAnalData $sonogram]} {
		My_Release_to_Dialog .playwindow
		Dlg_Dismiss .playwindow
	}
	.playwindow.button.1.nrm config -state normal
	.playwindow.button.1.pan config -state normal
}

proc PwAnalBoxGet {} {
	global playc evv
	global pwbox pwismarked sonogram pwfnam pw_wcnt wincntpw pwarate
	global pwstartchan pwendchan start_chan_in_box end_chan_in_box pwmarkwinstart pwmarkwinend
	global pw_start_chan_in_val pw_end_chan_in_val pw_start_time_in_val pw_end_time_in_val pwmarkwindur
	global pwmarktimestart pwmarktimeend

	set thisbox [$playc find withtag box]
	set coords [$playc coords $thisbox]
	if {[llength $coords] <= 0} {
		return
	}
	if {$sonogram} {
		set maxwidth $pw_wcnt
		if {[lindex $coords 2] > $maxwidth} {
			set coords [lreplace $coords 2 2 $maxwidth]
		}
	} else {	
		set maxwidth [expr $pw_wcnt * 2]
	}
	catch {$playc delete $pwbox(last)}
	set x1 [lindex $coords 0]
	set y1 [lindex $coords 1]
	set x2 [lindex $coords 2]
	set y2 [lindex $coords 3]
	if {$x2 < $x1} {
		set z $x1
		set x1 $x2
		set x2 $z
	}
	if {$y1 > $y2} {
		set z $y1
		set y1 $y2
		set y2 $z
	}
	set chans [expr $pwendchan - $pwstartchan]

	if {$sonogram} {
		set pwbox(last) [eval {$playc create rect} $coords {-stipple gray12 -fill red -outline $evv(GRAF) -tag box}]
		set start_chan_in_box [expr double($evv(PLAY_HEIGHT) - $y2) / double($evv(PLAY_HEIGHT))]
		set start_chan_in_box [expr int(round($start_chan_in_box * $chans)) + $pwstartchan]
		if {$start_chan_in_box < $pwstartchan} {
			set start_chan_in_box $pwstartchan
		}
		set end_chan_in_box   [expr double($evv(PLAY_HEIGHT) - $y1) / double($evv(PLAY_HEIGHT))]
		set end_chan_in_box   [expr int(round($end_chan_in_box * $chans)) + $pwstartchan]
		if {$end_chan_in_box > $pwendchan} {
			set end_chan_in_box $pwendchan
		}
		set pwmarkwinstart  [expr double($x1) / double($maxwidth)]
		set pwmarkwinstart  [expr int(round($pwmarkwinstart * $wincntpw))]
		set pwmarkwinend    [expr double($x2) / double($maxwidth)]
		set pwmarkwinend    [expr int(round($pwmarkwinend * $wincntpw))]
		PwAnalDisplayMarkTimes
	} else {
		if {$y1 < $evv(HALF_PLAY_HEIGHT)} {
			set y1 $evv(HALF_PLAY_HEIGHT)
		}
		if {$y2 < $evv(HALF_PLAY_HEIGHT)} {
			set y2 $evv(HALF_PLAY_HEIGHT)
		}
		set height [expr $evv(PLAY_HEIGHT) - $y1]
		set lean $height
		set height [expr $evv(PLAY_HEIGHT) - $y2]
		set lean2 $height
		if {$x1 > $maxwidth + $lean2} {
			return
		}
		if {$x2 > $maxwidth + $lean2} {
			set x2 [expr $maxwidth + $lean2]
		}
		set x1a [expr $x1 + $lean - $lean2]
		set x2a [expr $x2 + $lean - $lean2]
		set coords [list $x1 $y2 $x2 $y2 $x2a $y1 $x1a $y1]
		set pwbox(last) [eval {$playc create poly} $coords {-stipple gray12 -fill red -outline $evv(GRAF) -tag box}]
		set start_chan_in_box [expr double($evv(PLAY_HEIGHT) - $y2) / double($evv(HALF_PLAY_HEIGHT))]
		set start_chan_in_box [expr int(round($start_chan_in_box * $chans)) + $pwstartchan]
		if {$start_chan_in_box < $pwstartchan} {
			set start_chan_in_box $pwstartchan
		}
		set end_chan_in_box   [expr double($evv(PLAY_HEIGHT) - $y1) / double($evv(HALF_PLAY_HEIGHT))]
		set end_chan_in_box   [expr int(round($end_chan_in_box * $chans)) + $pwstartchan]
		if {$end_chan_in_box > $pwendchan} {
			set end_chan_in_box $pwendchan
		}
		set pwmarkwinstart  [expr double($x1) / double($maxwidth)]
		set pwmarkwinstart  [expr int(round($pwmarkwinstart * $wincntpw))]
		set pwmarkwinend    [expr double($x2) / double($maxwidth)]
		set pwmarkwinend    [expr int(round($pwmarkwinend * $wincntpw))]
		PwAnalDisplayMarkTimes
	}
	set pw_start_time_in_val $pwmarktimestart
	set pw_end_time_in_val   $pwmarktimeend
	set pw_start_chan_in_val $start_chan_in_box
	set pw_end_chan_in_val	  $end_chan_in_box

	set pwismarked 1
}

proc AnalZoomIn {vals} {
	global pwstartchan pwendchan pwseentimestart pwseentimeend pwseentimedur sonogram chanspw playc pwdur
	global start_chan_in_box end_chan_in_box pwmarktimestart pwmarktimeend
	global pw_start_chan_in_val pw_end_chan_in_val pw_start_time_in_val pw_end_time_in_val

	catch {$playc delete vsound} in
	catch {$playc delete box} in
	if {$vals} {
		set maxchans [expr (($chanspw)/2) - 1]
		if {![IsNumeric $pw_start_chan_in_val] || ![IsNumeric $pw_end_chan_in_val] || ![IsNumeric $pw_start_time_in_val] || ![IsNumeric $pw_end_time_in_val]} {
			Inf "Entered Values Are Not All Valid"
			return 1
		}
		if {$pw_end_chan_in_val > $maxchans} {
			set pw_end_chan_in_val $maxchans
		}
		if {$pw_start_chan_in_val < 0} {
			set pw_start_chan_in_val 0
		}
		if {$pw_start_chan_in_val > $pw_end_chan_in_val} {
			set z $pw_start_chan_in_val
			set pw_start_chan_in_val $pw_end_chan_in_val
			set pw_end_chan_in_val $z
		}
		if {$pw_start_time_in_val < 0.0} {
			set pw_start_time_in_val 0.0
		}
		if {$pw_end_time_in_val > $pwdur} {
			set pw_end_time_in_val $pwdur
		}
		if {$pw_end_time_in_val < $pw_start_time_in_val} {
			set z $pw_start_time_in_val
			set pw_start_time_in_val $pw_end_time_in_val
			set pw_end_time_in_val $z
		}
		set pwstartchan $pw_start_chan_in_val
		set pwendchan $pw_end_chan_in_val
		set pwseentimestart $pw_start_time_in_val
		set pwseentimeend $pw_end_time_in_val
	} else {
		set pwstartchan $start_chan_in_box
		set pwendchan $end_chan_in_box
		set pwseentimestart $pwmarktimestart
		set pwseentimeend $pwmarktimeend
	}
	set pwseentimedur [expr $pwseentimeend - $pwseentimestart]

	.playwindow.button.1.nrm config -state disabled
	.playwindow.button.1.pan config -state disabled

	if {![DisplayPwAnalData $sonogram]} {
		return 0
	}
	.playwindow.button.1.nrm config -state normal
	.playwindow.button.1.pan config -state normal
	return 1
}

proc AnalFullView {} {
	global pwstartchan pwendchan chanspw pwseentimestart pwseentimeend pwseentimedur sonogram pwdur playc 

	catch {$playc delete vsound} in
	catch {$playc delete box} in

	set pwstartchan 0
	set pwendchan [expr (($chanspw)/2) - 1]
	set pwseentimestart 0.0
	set pwseentimeend $pwdur
	set pwseentimedur $pwdur

	.playwindow.button.1.nrm config -state disabled
	.playwindow.button.1.pan config -state disabled

	if {![DisplayPwAnalData $sonogram]} {
		return 0
	}
	.playwindow.button.1.nrm config -state normal
	.playwindow.button.1.pan config -state normal
	DelAnalBox
	DelAnalSampMark
	return 1
}

proc AnalPwMagnify {} {
	global pwspeclines playc sonogram evv

	if {$sonogram} {
		Inf "Only Available With Spectral Display"
		return
	}
	if {![info exists pwspeclines]} {
		return
	}
	set was_already_magnified 0
	if {[string match [.playwindow.button.0.mag cget -text] "1-to-1"]} {
		set was_already_magnified 1
	}
	catch {$playc delete vsound} in
	catch {$playc delete box} in
	set x 0
	set winoffset 0
	set y2 $evv(PLAY_HEIGHT)
	foreach line $pwspeclines {
		set line [split $line]
		catch {unset nuline}
		foreach val $line {
			if {[IsNumeric $val]} {
				if {!$was_already_magnified} {
					set val [expr $val * 2]
				}
				lappend nuline $val
			}
		}
		set line $nuline
		set y2 $evv(PLAY_HEIGHT)
		foreach val $line {
			set y [expr $y2 - $val]
			set coords [list $x $y2 $x $y]
			eval {$playc create line} $coords {-fill $evv(GRAFSND) -tag vsound}
			set y [expr $y - 1.0]
			lappend qqq $x $y
			incr x
			incr y2 -1
		}
		eval {$playc create line} $qqq {-fill $evv(HELP) -tag vsound}
		unset {qqq}
		incr winoffset 2						
		set x $winoffset
	}
	if {$was_already_magnified} {		;# i.e. it was, but it no longer is!!
		.playwindow.button.0.mag config -text "Magnify"
	} else {
		.playwindow.button.0.mag config -text "1-to-1"
	}
}

proc WinStep {step} {
	global sonogram pw_wcnt pwlastx pwseentimeend pwseentimestart pwfnam playc pwwintime pwwinval pwarate evv 
	global pwchanval pwstchan

	if {$sonogram} {
		set maxwidth $pw_wcnt
	} else {	
		set maxwidth [expr $pw_wcnt * 2]
	}
	if {$pwlastx < 0} {
		set pwlastx -1
		return
	} elseif {$pwlastx == 0} {
		if {$step == -1} {
			return
		}
	} elseif {$pwlastx >= $maxwidth} {
		if {$step == 1} {
			return
		}
	}
	incr pwlastx $step
	set diff [expr $pwseentimeend  - $pwseentimestart]
	set pwwintime [FiveDecPlaces [expr (double($pwlastx)/double($maxwidth)) * $diff]]
	set pwwintime [expr $pwwintime + $pwseentimestart]
	set pwwinval [expr int(round($pwwintime * $pwarate))]
	if {$sonogram} {
		set pwchanval ""
		set pwstchan ""
	}
	catch {$playc delete sampval}
	$playc create line $pwlastx 0 $pwlastx $evv(PLAY_HEIGHT) -fill $evv(GRAF) -tag sampval
}

proc PwAnalSampMark {x y} {
	global pwlastx pwlineanchor
	PwAnalShowVal $x $y
	if {[info exist pwlastx] && ($pwlastx < 0)} {
		return
	}
	set pwlineanchor $x
}

proc PwAnalSampMarkDrag {x} {
	global pwlastx sonogram pw_wcnt pwlineanchor

	if {![info exists pwlastx] || ($pwlastx < 0) } {
		return
	}
	if {$sonogram} {
		set maxwidth $pw_wcnt
	} else {	
		set maxwidth [expr $pw_wcnt * 2]
	}
	if {($x >= 0) && ($x < $maxwidth)} {
		if {$x > $pwlineanchor} {
			WinStep 1
		} elseif {$x < $pwlineanchor} {
			WinStep -1
		}
		set pwlineanchor $x
	}
}

proc PwAnalShowVal {x y} {
	global sonogram pw_wcnt pwseentimeend pwseentimestart pwwintime pwwinval pwlastx pwchanval pwspeclines pwstchan pwstfrq
	global playc pwarate pwstartchan pwendchan pwhzwidth evv

	if {$sonogram} {
		set maxwidth $pw_wcnt
	} else {	
		set maxwidth [expr $pw_wcnt * 2]
	}
	if {$x >= $maxwidth} {
		return
	}
	catch {$playc delete sampval} in
	$playc create line $x 0 $x $evv(PLAY_HEIGHT) -fill $evv(GRAF) -tag sampval

	set diff [expr $pwseentimeend  - $pwseentimestart]
	set pwwintime [FiveDecPlaces [expr (double($x)/double($maxwidth)) * $diff]]
	set pwwintime [expr $pwwintime + $pwseentimestart]
	set pwwinval [expr int(round($pwwintime * $pwarate))]
	set pwlastx $x
	if {$sonogram} {
		set pwchanval [PwGetChanVal $x $y]
		set diff [expr $pwendchan  - $pwstartchan]
		set yy [expr double($evv(PLAY_HEIGHT) - $y) / double($evv(PLAY_HEIGHT))]
		set pwstchan [expr int(round(double($yy) * $diff)) + $pwstartchan]
		set pwstfrq [expr $pwstchan * $pwhzwidth]
	} else {
		set pwchanval ""
		set pwstchan ""
		set pwstfrq ""
	}
}

proc PwAnalClearSampVals {} {
	global pwwintime pwwinval pwchanval pwstchan pwstfrq

	set pwwintime ""
	set pwwinval ""
	set pwchanval ""
	set pwstchan ""
	set pwstfrq ""
}

proc DelAnalSampMark {} {
	global playc
	catch {$playc delete sampval}
	PwAnalClearSampVals
}

proc PwAnalClearBoxTimes {} {
	global pwmarkwinstart pwmarkwinend pwmarkwindur 
	global pwmarktimestart pwmarktimeend pwmarktimedur pwkeepwhole
	set pwmarkwinstart ""
	set pwmarkwinend ""
	set pwmarkwindur ""
	set pwmarktimestart ""
	set pwmarktimeend ""
	set pwmarktimedur ""
	ForceVal .playwindow.info.marked.0.e0 $pwmarkwinstart
	ForceVal .playwindow.info.marked.0.e1 $pwmarkwinend
	ForceVal .playwindow.info.marked.0.e2 $pwmarkwindur
	ForceVal .playwindow.info.marked.1.e0 $pwmarktimestart
	ForceVal .playwindow.info.marked.1.e1 $pwmarktimeend
	ForceVal .playwindow.info.marked.1.e2 $pwmarktimedur
	set pwkeepwhole 1
}

proc PwAnalDisplayMarkTimes {} {
	global pwmarkwinstart pwmarkwinend pwmarkwindur 
	global pwmarktimestart pwmarktimeend pwmarktimedur pwarate pwkeepwhole

	set pwmarkwindur [expr $pwmarkwinend - $pwmarkwinstart]
	ForceVal .playwindow.info.marked.0.e0 $pwmarkwinstart
	ForceVal .playwindow.info.marked.0.e1 $pwmarkwinend
	ForceVal .playwindow.info.marked.0.e2 $pwmarkwindur
	set pwmarktimestart [FiveDecPlaces [expr double($pwmarkwinstart) / double($pwarate)]]
	set pwmarktimeend   [FiveDecPlaces [expr double($pwmarkwinend) / double($pwarate)]]
	set pwmarktimedur   [FiveDecPlaces [expr $pwmarktimeend - $pwmarktimestart]]
	ForceVal .playwindow.info.marked.1.e0 $pwmarktimestart
	ForceVal .playwindow.info.marked.1.e1 $pwmarktimeend
	ForceVal .playwindow.info.marked.1.e2 $pwmarktimedur
	set pwkeepwhole 0
}

proc PwAnalBoxBegin {x y} {
	global pwbox playc
	PwAnalClearBoxTimes
	DelAnalBox
	set pwbox(anchor) [list $x $y]
}

proc DelAnalBox {} {
	global playc pwbox pw_start_chan_in_val pw_end_chan_in_val pw_start_time_in_val pw_end_time_in_val

	catch {$playc delete $pwbox(last)}
	catch {$playc delete box}
	catch {unset pwbox(last)}
	set pw_start_chan_in_val ""
	set pw_end_chan_in_val ""
	set pw_start_time_in_val ""
	set pw_end_time_in_val ""
}

proc PwGetChanVal {x y} {
	global pwspeclines pw_wcnt evv
	if {($y < 0) || ($y >= $evv(PLAY_HEIGHT)) || ($x < 0) || ($x >= $pw_wcnt)} {
		return
	}
	set y [expr $evv(PLAY_HEIGHT) - $y]
	set val [lindex [lindex $pwspeclines $x] $y]
	if {[string length $val] <= 0} {
		return
	}
	set val [expr double($val) / double($evv(COLOR_SPECTRUM))]
	set val [expr $val * 3.0]
	set val [expr pow(10.0,$val)]
	set val [FiveDecPlaces [expr ($val - 1.0) / 999.0]]
	return $val
}

proc PwAnalBoxtoMark {} {
	global pwmarkwinstart pwwinval playc pwseenwindur sonogram pwmarkwinend pw_wcnt pwbox pwendchan pwstartchan
	global pwseenwinstart

	set x1 0	;# defaults to pass to Redraw func, if not generated internally
	set x2 0
	set y1 0
	set y2 0
	if {[string length $pwmarkwinstart] <= 0} {
		Inf "No Box Drawn"
		return
	}
	if {[string length $pwwinval] <= 0} {
		Inf "No Mark Set"
		return
	}
	set thisbox [$playc find withtag box]
	set coords [$playc coords $thisbox]
	if {[llength $coords] <= 0} {
		return
	}
	if {$sonogram} {
		set maxwidth $pw_wcnt
	} else {	
		set maxwidth [expr $pw_wcnt * 2]
	}
	set a [expr double($pwwinval - $pwseenwinstart) / double($pwseenwindur)]
	set a [expr int(round($a * double($maxwidth)))]
	if {$sonogram} {
		set x1 [lindex $coords 0]
		set y1 [lindex $coords 1]
		set x2 [lindex $coords 2]
		set y2 [lindex $coords 3]
		if {$x2 < $x1} {
			set z $x1
			set x1 $x2
			set x2 $z
		}
		if {$y1 > $y2} {
			set z $y1
			set y1 $y2
			set y2 $z
		}
	}
	if {$pwwinval < $pwmarkwinstart} {
		if {$sonogram} {
			set x1 $a
			set coords [list $x1 $y1 $x2 $y2]
		} else {
			set x4 [lindex $coords 6]
			set diff [expr $x4 - $a]
			set coords [lreplace $coords  6 6 $a]
			set x1 [lindex $coords 0]
			set x1 [expr $x1 - $diff]
			set coords [lreplace $coords 0 0 $x1]
		}
		set pwmarkwinstart $pwwinval

	} elseif {$pwwinval > $pwmarkwinend} {
		if {$sonogram} {
			set x2 $a
			set coords [list $x1 $y1 $x2 $y2]
		} else {
			set x3 [lindex $coords 4]
			set diff [expr $a - $x3]
			set coords [lreplace $coords  4 4 $a]
			set x2 [lindex $coords 2]
			set x2 [expr $x2 + $diff]
			set coords [lreplace $coords 2 2 $x2]
		}
		set pwmarkwinend $pwwinval
	} else {
		Inf "Mark Is Inside Box"
		return
	}
	catch {$playc delete $pwbox(last)}
	set chans [expr $pwendchan - $pwstartchan]

	RedrawAnalBox $coords $x1 $x2 $y1 $y2 $chans $maxwidth
}

proc PwAnalPushBox {end} {
	global playc pwmarkwinstart pwmarkwinend pwseenwinend pwtotalwins pwseenwinstart sonogram pw_wcnt
	global pwbox pwendchan pwstartchan 

	if {[string length $pwmarkwinstart] <= 0} {
		Inf "No Box Drawn"
		return
	}
	set x1 0	;# defaults to pass to Redraw func, if not generated internally
	set x2 0
	set y1 0
	set y2 0
	set thisbox [$playc find withtag box]
	set coords [$playc coords $thisbox]
	if {[llength $coords] <= 0} {
		return
	}
	if {[string length $pwmarkwinstart] <= 0} {
		Inf "No Marked Area"
		return
	}
	if {$end} {
		if {$pwmarkwinend != $pwseenwinend} {
			set pwmarkwinend $pwseenwinend
		}
	} elseif {$pwmarkwinstart != $pwseenwinstart} {
		set pwmarkwinstart $pwseenwinstart
	}
	if {$sonogram} {
		set maxwidth $pw_wcnt
	} else {	
		set maxwidth [expr $pw_wcnt * 2]
	}
	catch {$playc delete $pwbox(last)}
	set chans [expr $pwendchan - $pwstartchan]

	if {$sonogram} {
		set x1 [lindex $coords 0]
		set y1 [lindex $coords 1]
		set x2 [lindex $coords 2]
		set y2 [lindex $coords 3]
		if {$x2 < $x1} {
			set z $x1
			set x1 $x2
			set x2 $z
		}
		if {$y1 > $y2} {
			set z $y1
			set y1 $y2
			set y2 $z
		}
		if {$end} {
			set x2 $maxwidth
		} else {
			set x1 0
		}
		set coords [list $x1 $y1 $x2 $y2]
	} else {
		if {$end} {
			set x3 [lindex $coords 4]
			set diff [expr $maxwidth - $x3]
			set coords [lreplace $coords 4 4 $maxwidth]
			set x2 [lindex $coords 2]
			set x2 [expr $x2 + $diff]
			set coords [lreplace $coords 2 2 $x2]
		} else {
			set x4 [lindex $coords 6]
			set coords [lreplace $coords 6 6 0]
			set x1 [lindex $coords 0]
			set x1 [expr $x1 - $x4]
			set coords [lreplace $coords 0 0 $x1]
		}
	}
	if {$end} {
		set pwmarkwinend $pwseenwinend
	} else {
		set pwmarkwinstart $pwseenwinstart
	}
	RedrawAnalBox $coords $x1 $x2 $y1 $y2 $chans $maxwidth
}

proc RedrawAnalBox {coords x1 x2 y1 y2 chans maxwidth} {
	global sonogram pwbox playc start_chan_in_box evv pwstartchan end_chan_in_box pwendchan 
	global pwmarkwinstart wincntpw pwmarkwinend pwendchan pwaspect pw_wcnt
	global pw_start_time_in_val pwmarktimestart pw_end_time_in_val pwmarktimeend 
	global pw_start_chan_in_val pw_end_chan_in_val pwismarked

	if {$sonogram} {
		set pwbox(last) [eval {$playc create rect} $coords {-stipple gray12 -fill red -outline $evv(GRAF) -tag box}]
		set start_chan_in_box [expr double($evv(PLAY_HEIGHT) - $y2) / double($evv(PLAY_HEIGHT))]
		set start_chan_in_box [expr int(round($start_chan_in_box * $chans)) + $pwstartchan]
		if {$start_chan_in_box < $pwstartchan} {
			set start_chan_in_box $pwstartchan
		}
		set end_chan_in_box   [expr double($evv(PLAY_HEIGHT) - $y1) / double($evv(PLAY_HEIGHT))]
		set end_chan_in_box   [expr int(round($end_chan_in_box * $chans)) + $pwstartchan]
		if {$end_chan_in_box > $pwendchan} {
			set end_chan_in_box $pwendchan
		}
		PwAnalDisplayMarkTimes
	} else {
		set pwaspect [expr double($pw_wcnt) / double($evv(PLAY_HEIGHT))]
		set height [expr $evv(PLAY_HEIGHT) - $y2]
		set lean [expr int(round($height * $pwaspect))]
		set pwbox(last) [eval {$playc create poly} $coords {-stipple gray12 -fill red -outline $evv(GRAF) -tag box}]
		set start_chan_in_box [expr double($evv(PLAY_HEIGHT) - $y2) / double($evv(HALF_PLAY_HEIGHT))]
		set start_chan_in_box [expr int(round($start_chan_in_box * $chans)) + $pwstartchan]
		if {$start_chan_in_box < $pwstartchan} {
			set start_chan_in_box $pwstartchan
		}
		set end_chan_in_box   [expr double($evv(PLAY_HEIGHT) - $y1) / double($evv(HALF_PLAY_HEIGHT))]
		set end_chan_in_box   [expr int(round($end_chan_in_box * $chans)) + $pwstartchan]
		if {$end_chan_in_box > $pwendchan} {
			set end_chan_in_box $pwendchan
		}
		PwAnalDisplayMarkTimes


	}
	set pw_start_time_in_val $pwmarktimestart
	set pw_end_time_in_val   $pwmarktimeend
	set pw_start_chan_in_val $start_chan_in_box
	set pw_end_chan_in_val	  $end_chan_in_box

	set pwismarked 1
}

proc PwAnalBoxCut {before} {
	global pwmarkwinstart pwwintime pwwinval pwmarkwinend playc sonogram pw_wcnt pwbox pwendchan pwstartchan pwmarkwindur
	global pwmarkwinend pwseenwinstart pwseenwindur

	set x1 0	;# defaults to pass to Redraw func, if not generated internally
	set x2 0
	set y1 0
	set y2 0
	if {[string length $pwmarkwinstart] <= 0} {
		Inf "No Box Drawn"
		return
	}
	if {[string length $pwwinval] <= 0} {
		Inf "No Mark Set"
		return
	}
	if {($pwwinval >= $pwmarkwinend) || ($pwwinval <= $pwmarkwinstart) }  {
		Inf "Mark Is Not Inside Box"
		return
	}
	set thisbox [$playc find withtag box]
	set coords [$playc coords $thisbox]
	if {[llength $coords] <= 0} {
		return
	}
	if {$sonogram} {
		set maxwidth $pw_wcnt
	} else {	
		set maxwidth [expr $pw_wcnt * 2]
	}

 	catch {$playc delete $pwbox(last)}
	set chans [expr $pwendchan - $pwstartchan]
	set a [expr double($pwwinval - $pwseenwinstart) / double($pwseenwindur)]
	set a [expr int(round($a * double($maxwidth)))]
	if {$sonogram} {
		set x1 [lindex $coords 0]
		set y1 [lindex $coords 1]
		set x2 [lindex $coords 2]
		set y2 [lindex $coords 3]
		if {$x2 < $x1} {
			set z $x1
			set x1 $x2
			set x2 $z
		}
		if {$y1 > $y2} {
			set z $y1
			set y1 $y2
			set y2 $z
		}
		if {$before} {
			set x1 $a
		} else {
			set x2 $a
		}
		set coords [list $x1 $y1 $x2 $y2]
	} else {
		if {$before} {
			set x4 [lindex $coords 6]
			set diff [expr $a - $x4]
			set coords [lreplace $coords 6 6 $a]
			set x1 [lindex $coords 0]
			set x1 [expr $x1 + $diff]
			set coords [lreplace $coords 0 0 $x1]
		} else {
			set x3 [lindex $coords 4]
			set diff [expr $x3 - $a]
			set coords [lreplace $coords 4 4 $a]
			set x2 [lindex $coords 2]
			set x2 [expr $x2 - $diff]
			set coords [lreplace $coords 2 2 $x2]
		}
	}
	if {$before} {
		set pwmarkwinstart $pwwinval
	} else {
		set pwmarkwinend $pwwinval
	}
	RedrawAnalBox $coords $x1 $x2 $y1 $y2 $chans $maxwidth
}

proc PwGrab {del} {
	global pwcutname new_cdp_extensions pwoutfnam2 pwlastaction pwsaved wstk wl evv
	global pwmarkwinstart pwmarkwinend end start_chan_in_box end_chan_in_box chanspw pwfnam
	global pwmarktimestart pwmarktimeend rememd

	if {[string length $pwmarkwinstart] <= 0} {
		Inf "No Selection Box Drawn"
		return
	}
	if {([string length $start_chan_in_box] <= 0) || ([string length $end_chan_in_box] <= 0)} {
		Inf "Channel Limits Not Defined"
		return
	}
	set pwmaxchan [expr (($chanspw)/2) - 1]
	set chanlo $start_chan_in_box
	set chanhi $end_chan_in_box
	if {$chanhi == $chanlo} {
		if {$chanhi >= $pwmaxchan} {
			incr chanlo -1
		} else {
			incr chanhi 1
		}
	}			
	if {[string length $pwcutname] <= 0} {
		Inf "No Output Filename Given"
		return
	}
	set fnam [string tolower $pwcutname]
	if {![ValidCDPRootname $fnam]} {
		return
	}
	if {$new_cdp_extensions} {
		append fnam $evv(ANALFILE_EXT)
	} else {
		append fnam $evv(SNDFILE_EXT)
	}
	if {[file exists $fnam]} {
		set msg "File '$fnam' Already Exist: Overwrite It?"
		set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		} else {
			if [DeleteFileFromSystem $fnam 1 1] {
				DummyHistory $fnam "DESTROYED"
				set i [LstIndx $fnam $wl]
				if {$i >= 0} {
					WkspCnt [$wl get $i] -1
					$wl delete $i
					catch {unset rememd}
				}
			} else {
				Inf "Cannot Overwrite Existing File"
				return
			}
		}
	}
	set cmd [file join $evv(CDPROGRAM_DIR) pagrab]
	lappend cmd $pwfnam $pwmarktimestart $pwmarktimeend $pwoutfnam2 $chanlo $chanhi $del
	DoPwAction $cmd
	if {![file exists $pwoutfnam2]} {
		Inf "Editing Process Failed"
		return
	}
	if [catch {file rename $pwoutfnam2 $fnam} in] {
		Inf "$in : Cannot Save File As '$fnam'"
		return
	}
	set pwlastaction ""
	if {[FileToWkspace $fnam 0 0 0 0 1] <= 0} {
		return
	} else {
		set pwsaved $fnam
		Inf "File '$fnam' Saved"
	}
}

proc PwRecycleAnal {} {
	global pwsaved pwdisplaydata pwfnam pr_playw chanspw pa evv wincntpw pwarate pwtotalwins pwdur
	global pwseentimestart pwseentimeend pwstartchan pwendchan pwhzwidth sonogram
	global pwbrkset pwbrktop pwbrkbot pwdataname pwcutname pwlastaction pwscalefact pwismarked pwkeepwhole
	global chlist chcnt pr_playw ch

	if {![info exists pwsaved]} {
		Inf "No Output File Saved"
		return
	}
	catch {file delete $pwdisplaydata}
	set pwfnam $pwsaved
	wm title .playwindow "SPECTRAL DISPLAY:                                       $pwfnam"
	PwAnalClearSampVals
	PwAnalClearBoxTimes
	DelAnalBox
	set pr_playw 0
	set chanspw $pa($pwfnam,$evv(CHANS))
    set wincntpw [expr $pa($pwfnam,$evv(INSAMS)) / $pa($pwfnam,$evv(CHANS))]
	set pwarate $pa($pwfnam,$evv(ARATE))
	set pwtotalwins [expr $pa($pwfnam,$evv(INSAMS)) / $pa($pwfnam,$evv(CHANS))]
	set pwdur $pa($pwfnam,$evv(DUR))

	set pwseentimestart 0
	set pwseentimeend $pwdur
	set pwstartchan 0
	set pwendchan [expr (($chanspw)/2) - 1]

	set nyquist [expr double($pa($pwfnam,$evv(ORIGRATE))) / 2.0]
	set pwhzwidth [expr $nyquist / $pwendchan]

	if {![DisplayPwAnalData $sonogram]} {
		Dlg_Dismiss .playwindow
		return
	}
	.playwindow.button.1.nrm config -state normal
	.playwindow.button.1.pan config -state normal
	set pwbrkset 1
	set pwbrktop "1"
	set pwbrkbot "0"
	set pwdataname "_temp"
	set pwcutname ""
	set pwlastaction ""
	set pwscalefact 1
	set pwismarked 0
	unset pwsaved
	set pwkeepwhole 1
	DoChoiceBak
	ClearWkspaceSelectedFiles
	set chlist $pwfnam
	set chcnt 1
	$ch insert end $pwfnam
	set pr_playw 1
}

proc No_Ends {} {
	global playwsvalk playwevalk 
	set playwsvalk 0
	set playwevalk 0
}

proc TellSampStep {dir} {
	if {$dir > 0} {
		Inf "Advance Cursor By Using 'f' Key,\nOr Single-step Using Option On 'Mark' Menu"
	} else {
		Inf "Move Cursor Backwards By Using 'b' Key,\nor Single-step Using Option on 'Mark' Menu"
	}
}

proc LoadBrkfileForGraf {} {
	 global pr_lbfgraf pwget_finished pwget_started wl pa outlist pwb wstk evv 
	global pwbrktop pwbrkbot

	set outlist {}
	if {$pwbrktop <= $pwbrkbot} {
		Inf "Breakpoint Range Inverted Or Zero"
		return $outlist
	}
	foreach fnam [$wl get 0 end] {
		if {([IsABrkfile $pa($fnam,$evv(FTYP))]) && ($pa($fnam,$evv(NUMSIZE)) >= 4)} {
			if {($pa($fnam,$evv(MINBRK)) >= $pwbrkbot) && ($pa($fnam,$evv(MAXBRK)) <= $pwbrktop)} { 
				lappend brklist $fnam
			}
		}
	}
	if {![info exists brklist]} {
		if {($pwbrktop == 1) && ($pwbrkbot == 0)} {
			Inf "There Are No Normalised Breakpoint On The Workspace"
		} else {
			Inf "There Are No Breakpoint Files Within The Specified Range On The Workspace"
		}
		return $outlist
	}
	set callcentre [GetCentre [lindex $wstk end]]
	set f .lbfgraf
	if [Dlg_Create $f "Select a Breakpointfile" "set pr_lbfgraf 1" -borderwidth $evv(SBDR)] {
		frame $f.1 -borderwidth $evv(SBDR)
		frame $f.2 -borderwidth $evv(SBDR)
		frame $f.3 -borderwidth $evv(SBDR)
		button $f.1.load -text Load -command "set pr_lbfgraf 1" -highlightbackground [option get . background {}]
		button $f.1.quit -text Close -command "set pr_lbfgraf 0" -highlightbackground [option get . background {}]
		pack $f.1.load -side left
		pack $f.1.quit -side right
		label $f.2.lab -text "Select a Brkfile from the list"
		pack $f.2.lab -side right
		Scrolled_Listbox $f.3.ll -width 60 -height 20 -selectmode single
		pack $f.3.ll -side top -fill both -expand true
		pack $f.1 $f.2 $f.3 -side top -pady 3 -fill x -expand true
		bind $f <Return> {set pr_lbfgraf 1}
		bind $f <Escape> {set pr_lbfgraf 0}
	}
	wm resizable .lbfgraf 1 1
	$f.3.ll.list delete 0 end
	foreach fnam $brklist {
		$f.3.ll.list insert end $fnam
	}
	set pr_lbfgraf 0
	set finished 0
	raise $f
	update idletasks
	set geo [CentreOnCallingWindow $f $callcentre]
	My_Grab 0 $f pr_lbfgraf
	wm geometry $f $geo
	while {!$finished} {
		tkwait variable pr_lbfgraf
		set outlist {}
		if {$pr_lbfgraf} {
			set k [$f.3.ll.list curselection]
			if {$k < 0} {
				Inf "No file selected"
				continue
			}
			set fnam [$f.3.ll.list get $k]
			set outlist [GetPWData_FromAFile $fnam]
			if {[llength $outlist] <= 0} {
				continue
			}
			break
		} else {
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	set outlist [RoundOutlist $outlist]
	return $outlist
}

proc PwGetDisplayVals {x y botrang rangmult} {
	global pwb pw_effective_width pwseentimestart lastpw_time lastpw_val pwget_started evv
	global pwseentimedur pwseentimeend pwget_finished
	set out {}
	set pwb(ew) [expr double($pw_effective_width)]
	if {$x < $pwseentimestart} {
		set lastpw_time $x
		set lastpw_val $y
		return
	} elseif {![info exists pwget_started]} {
		set pwget_started 1
		if {$x > $pwseentimestart} {
			set xs 0.0
			set ratio [expr ($pwseentimestart - $lastpw_time)/($x - $lastpw_time)]
			set ys [expr ($y - $lastpw_val) * $ratio]
			set ys [expr $ys + $lastpw_val]
			set lastpw_time $pwseentimestart
			set lastpw_val $ys
			set ys [expr (double($ys) - $botrang) * $rangmult]
			set ys [expr double($ys) * double($evv(PW_FOOT))]
			set ys [expr $evv(PW_FOOT) - $ys]
			lappend out $xs $ys
		}
	}
	if {$x > $pwseentimeend} {
		set ratio [expr ($pwseentimeend - $lastpw_time)/($x - $lastpw_time)]
		set x $pwseentimeend
		set y [expr ($y - $lastpw_val) * $ratio]
		set y [expr $y + $lastpw_val]
		set pwget_finished 1
	}
	set lastpw_time $x
	set lastpw_val $y
	set x [expr ($x - $pwseentimestart) / $pwseentimedur]
	set x [expr $x  * $pwb(ew)]
	set y [expr (double($y) - $botrang) * $rangmult]
	set y [expr double($y) * double($evv(PW_FOOT))]
	set y [expr $evv(PW_FOOT) - $y]
	lappend out $x $y
	return $out
}

proc GetPWData_FromAFile {fnam} {
	global pwget_finished pwget_started pwb
	global pwbrktop pwbrkbot

	if [catch {open $fnam "r"} zit] {
		Inf "Cannot read file '$fnam'"
		return {}
	}
	set istime 1
	set OK 1
	set cnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {([string length $line] <= 0) || [string match ";" [string index $line 0]]} {
			continue
		}
		set line [split $line]
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			} elseif {![IsNumeric $item]} {
				Inf "Non-numeric data in file '$fnam'"
				set OK 0
				break
			} elseif {$istime} {
				if {$cnt == 0} {
					if {$item != 0.0} {
						Inf "Bad first time in file '$fnam'"
						set OK 0
						break
					}
					set lasttime $item
				} elseif {$item <= $lasttime} {
					Inf "Bad time sequence in file '$fnam'"
					set OK 0
					break
				}
			} else {
				if {($item < $pwbrkbot) || ($item > $pwbrktop)} {
					Inf "Value Out Of Range ($pwbrkbot - $pwbrktop) In File $fnam"
					set OK 0
					break
				}
			}
			set istime [expr !$istime]
			lappend brkdata $item
			incr cnt
		}
		if {!$OK} {
			break
		}
	}
	close $zit
	if {!$OK} {
		return {}
	}
	if {$cnt == 0} {
		Inf "No data in file '$fnam'"
		return {}
	}
	if {![IsEven $cnt]} {
		Inf "Missing final value in file '$fnam'"
		return {}
	}
	set rang [expr $pwbrktop - $pwbrkbot]
	set rangmult [expr 1.0 / double($rang)]
	set pwget_finished 0
	catch {unset pwget_started}
	set outlist {}
	foreach {time val} $brkdata {
		set vals [PwGetDisplayVals $time $val $pwbrkbot $rangmult]
		set outlist [concat $outlist $vals]
		if {$pwget_finished} {
			break
		}
	}
	if {!$pwget_finished} {
		set k [llength $outlist]
		incr k -1
		set y [lindex $outlist $k]
		set x $pwb(ew)
		lappend outlist $x $y
	}
	return $outlist
}

#---- Set marker to a time grabbed from References Listing

proc SetPviewMark {x} {
	global pwseentimestart pwseentimeend pwseentimedur pw_effective_width
	if {![IsNumeric $x]} {
		Inf "Non-Numeric Value"
		return
	}
	if {($x < $pwseentimestart) || ($x > $pwseentimeend)} {
		Inf "Value Out Of (time) Range Of Display"
		return
	}
	set x [expr $x - $pwseentimestart]
	set x [expr $x / $pwseentimedur]
	set x [expr int(round($x * $pw_effective_width))]
	PwSampMark $x 0
}

#---- Round values calculated for loaded brktable, for display purposes

proc RoundOutlist {outlist} {
	foreach val $outlist {
		lappend nulist [expr int(round($val))]
	}
	return $nulist
}
