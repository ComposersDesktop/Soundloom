#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD June 30 2013
# ... fixup button rectangles

#--- Graphically edit a Pitch Data file

proc DoPitchDisplay {fnam} {
 	global pdw pdc evv mu pa pdisplay_hlp_actv pdisplay_actv small_screen pdisplay_emph wstk
	global pr_pdisplay pr_2 pwinpos ptimpos psmppos pdisval pdismid
	global wstk window_stack_index new_cdp_extensions

	set pdc(es) 0
	catch {destroy .pdisplay}
	catch {unset pdisplay_emph}

	if {![PdGrab]} {
		return
	}
 	set w_edges 60
 	set h_edges 120
 	set pdc(ymargin) 16
 	set pdc(-ymargin) -16
 	set pdc(xmargin) 32
 	set pdc(-xmargin) -32
	set pdc(width) [expr $evv(LARGE_WIDTH) - ($w_edges * 2)]
	set pdc(width) [expr ($pdc(width) / 2) * 2]				;#	Force it to be EVEN
	set pdc(effective_width) [expr $pdc(width) - (2 * $pdc(xmargin))]
	set pdc(bloksize) [expr $pdc(effective_width)/2.0]
	set pdc(endblok) [expr int(floor($pa($fnam,$evv(WLENGTH)) / $pdc(bloksize)))]
	if {$pdc(endblok) > 0} {
		incr pdc(endblok) -1
	}
	set pdc(fnam) $fnam
	set pdc(texttemp) $evv(DFLT_OUTNAME)
	append pdc(texttemp) 0 $evv(TEXT_EXT)

	if {$new_cdp_extensions} {
		set pdc(pichtemp) $evv(DFLT_OUTNAME)
		append pdc(pichtemp) 0 $evv(PITCHFILE_EXT)
		set pdc(analtemp) $evv(DFLT_OUTNAME)
		append pdc(analtemp) 1 $evv(ANALFILE_EXT)
		set pdc(sndtemp) $evv(DFLT_OUTNAME)
		append pdc(sndtemp) 2 $evv(SNDFILE_EXT)
	} else {
		set pdc(pichtemp) $evv(DFLT_OUTNAME)
		append pdc(pichtemp) 0 $evv(SNDFILE_EXT)
		set pdc(analtemp) $evv(DFLT_OUTNAME)
		append pdc(analtemp) 1 $evv(SNDFILE_EXT)
		set pdc(sndtemp) $evv(DFLT_OUTNAME)
		append pdc(sndtemp) 2 $evv(SNDFILE_EXT)
	}
	set pdc(zoomed) 0
 	set pdc(stretched) 0
 	set pdc(last) ""
 	set pdc(mark) 0
	set pdc(datano) 0
	set pdc(saveno) -1
	set pdc(zoomratio) 1
	set f .pdisplay
	if [Dlg_Create .pdisplay "PITCH DISPLAY" "set pr_pdisplay 0" -borderwidth $evv(BBDR)] {
		set pdc(height) [expr $evv(LARGE_HEIGHT) - ($h_edges * 2)]
		set pdc(effective_height) [expr $pdc(height) - (2 * $pdc(ymargin))]
		set pdc(scaler) [expr double($pdc(effective_height)) / double($mu(MIDIMAX))]
		set pdc(lowlim) [expr $pdc(effective_height) + $pdc(ymargin)]
		set pdc(lowlim_with_grace) [expr $pdc(lowlim) + 2]
		set pdc(hilim_with_grace) [expr $pdc(ymargin) - 2]
		set pdisplay_hlp_actv 0
		set pdisplay_actv 1

		if {$small_screen} {
			set can [Scrolled_Canvas $f.c -width $evv(SMALL_WIDTH) -height $evv(SMALL_HEIGHT) \
								-scrollregion "0 0 $evv(LARGE_WIDTH) $evv(SCROLL_HEIGHT)"]
			pack $f.c -side top -fill x -expand true
			set k [frame $can.f -bd 0]
			$can create window 0 0 -anchor nw -window $k
			set pdw $k
		} else {
			set pdw $f
		}	

		#	HELP AND QUIT

		set help [frame $pdw.help -borderwidth $evv(SBDR)]
		pack $help -side top -fill x -expand true
		button $help.hlp -text "Help" -command "ActivateHelp $pdw.help" -width 4 ;# -bg $evv(HELP) -highlightbackground [option get . background {}]
		label  $help.conn -text "" -width 13
		button $help.con -text "" -borderwidth 0 -state disabled -width 8 -highlightbackground [option get . background {}]
		label $help.help -width 84 -text "$evv(HELP_DEFAULT)" -fg [option get . foreground {}]
		if {$evv(NEWUSER_HELP)} {
			button $help.starthelp -text "New User Help" -command "GetNewUserHelp pdisplay"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
		}
		button $help.quit -text "End Session" -command "set pdc(es) 1 ; set pr_pdisplay 0"  -highlightbackground [option get . background {}];# -bg $evv(QUIT_COLOR)
		bind $pdw <Control-Command-Escape> "set pdc(es) 1 ; set pr_pdisplay 0"
#MOVED TO LEFT
		pack $help.quit -side left
		if {$evv(NEWUSER_HELP)} {
			pack $help.hlp $help.conn $help.con $help.help $help.starthelp -side left
		} else {
			pack $help.hlp $help.conn $help.con $help.help -side left
		}
#MOVED TO LEFT
#		pack $help.quit -side right

		#	BUTTONS

		set sfbb0 [frame $pdw.btns0 -borderwidth 0]
		label  $sfbb0.tot -text "Final Block" -width 10
		entry  $sfbb0.toe -textvariable pdc(endblok) -width 3 -state disabled
		label  $sfbb0.tsh -text "Block Shown" -width 10
		entry  $sfbb0.tse -textvariable pdc(lastblok) -width 3 -state disabled
		label  $sfbb0.tts -text "Block Wanted" -width 10
		entry  $sfbb0.tte -textvariable pdc(thisblok) -width 3 -state disabled
		button $sfbb0.up  -text ">" -command "IncrPdBlok 1" -highlightbackground [option get . background {}]
		button $sfbb0.dn  -text "<" -command "IncrPdBlok -1" -highlightbackground [option get . background {}]
		button $sfbb0.dis -text "Display Blk" -command "set pr_pdisplay 1" -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $sfbb0.zoo -text "Zoom" -command "PdZoom" -width 4 -highlightbackground [option get . background {}]
		button $sfbb0.str -text "Stretch" -command "PdStretch" -width 5 -highlightbackground [option get . background {}]
		label $sfbb0.dm1 -text "W"
		entry $sfbb0.dum1 -textvariable pwinpos -width 6 -state disabled
		label $sfbb0.dm2 -text "T"
		entry $sfbb0.dum2 -textvariable ptimpos -width 7 -state disabled
		label $sfbb0.dm3 -text "S"
		entry $sfbb0.dum3 -textvariable psmppos -width 10 -state disabled
		label $sfbb0.dm4 -text "M"
		entry $sfbb0.dum4 -textvariable pdisval -width 5 -state disabled
		label $sfbb0.dm5 -text "P"
		entry $sfbb0.dum5 -textvariable pdismid -width 5 -state disabled

		set sfbb0x [frame $pdw.btns0x -borderwidth 0]
		button $sfbb0x.pla -text "Play" -width 5 -command "PdPlay $fnam" -highlightbackground [option get . background {}]
		button $sfbb0x.und -text "Undo" -width 5 -command "PdUndo" -highlightbackground [option get . background {}]
		button $sfbb0x.res -text "Restart" -width 8 -command "PdRestart" -highlightbackground [option get . background {}]
		button $sfbb0x.qui -text "Close" -command "set pr_pdisplay 0" -width 5 -highlightbackground [option get . background {}]

		pack $sfbb0.tot $sfbb0.toe $sfbb0.tsh $sfbb0.tse -side left -padx 1 -pady 4
		pack $sfbb0.tts $sfbb0.tte $sfbb0.up $sfbb0.dn $sfbb0.dis $sfbb0.zoo $sfbb0.str  -side left -padx 1 -pady 4
		pack $sfbb0.dm1 $sfbb0.dum1 $sfbb0.dm2 $sfbb0.dum2 $sfbb0.dm3 $sfbb0.dum3 -side left -pady 4
		pack $sfbb0.dm4 $sfbb0.dum4 $sfbb0.dm5 $sfbb0.dum5 -side left -pady 4

		pack $sfbb0x.pla -side left -padx 1 -pady 4
		pack $sfbb0x.qui $sfbb0x.res $sfbb0x.und -side right -padx 1 -pady 4

		frame $pdw.z0 -bg $evv(POINT) -height 1
		frame $pdw.z0x -bg $evv(POINT) -height 1
		frame $pdw.z1 -bg $evv(POINT) -height 1
		frame $pdw.z2 -bg $evv(POINT) -height 1
		frame $pdw.z5 -bg $evv(POINT) -height 1

		set sfbb1 [frame $pdw.btns1 -borderwidth 0]
		button $sfbb1.smo -text "Smooth" -width 8 -command "PdSmooth 0" -bg $evv(EMPH) -highlightbackground [option get . background {}]

		radiobutton $sfbb1.fla -variable pdc(curve) -text "linear" -value 0 -command HideCurve -width 4
		radiobutton $sfbb1.cav -variable pdc(curve) -text "concave" -value 1 -command ShowCurve -width 5
		radiobutton $sfbb1.vex -variable pdc(curve) -text "convex" -value -1 -command ShowCurve -width 5
		entry $sfbb1.cur -textvariable pdc(curval) -width 2 -bd 2
		button $sfbb1.cup -text "^" -width 1 -command "Curvup 1" -state disabled -highlightbackground [option get . background {}]
		button $sfbb1.cdn -text "v" -width 1 -command "Curvup -1" -state disabled -highlightbackground [option get . background {}]

		label  $sfbb1.dum -text "curve"
		button $sfbb1.ins -text "Insert" -width 8 -command "PdSmooth 1" -bg $evv(EMPH) -highlightbackground [option get . background {}]

		frame  $sfbb1.z3 -width 1

		button $sfbb1.tra -text "Transpose" -width 8 -command "PdTranspose" -bg $evv(EMPH) -highlightbackground [option get . background {}]
		entry  $sfbb1.tre -textvariable pdc(transpose) -width 3
		label  $sfbb1.sem -text semitones
		button $sfbb1.tze  -text "0"  -width 1 -command "Transup 0" -highlightbackground [option get . background {}]
		button $sfbb1.tup  -text "^ " -width 1 -command "Transup 1" -highlightbackground [option get . background {}]
		button $sfbb1.tdn  -text "v " -width 1 -command "Transup -1" -highlightbackground [option get . background {}]
		button $sfbb1.tup8 -text "^8" -width 1 -command "Transup 12" -highlightbackground [option get . background {}]
		button $sfbb1.tdn8 -text "v8" -width 1 -command "Transup -12" -highlightbackground [option get . background {}]
		set sfbb1x [frame $pdw.btns1x -borderwidth 0]
		label  $sfbb1x.bb2 -text "Modify Data" -width 12
		button $sfbb1x.app -text "Apply" -width 8 -command "PdApply" -highlightbackground [option get . background {}]
		button $sfbb1x.sav -text "Save As" -width 8 -command "PdSave $fnam" -highlightbackground [option get . background {}]
		entry  $sfbb1x.sae -textvariable pdc(outfile) -width 16

		pack $sfbb1.smo $sfbb1.fla $sfbb1.cav $sfbb1.vex -side left -pady 4
		pack $sfbb1.cup $sfbb1.cdn $sfbb1.cur $sfbb1.dum $sfbb1.ins -side left -pady 4

		pack $sfbb1.z3 -side left -fill y -padx 4 -expand true

		pack $sfbb1.tra $sfbb1.tre $sfbb1.sem -side left -pady 4
		pack $sfbb1.tze $sfbb1.tup $sfbb1.tdn $sfbb1.tup8 $sfbb1.tdn8 -side left -pady 4

		pack $sfbb1x.bb2 -side left -pady 4
		pack $sfbb1x.sae $sfbb1x.sav $sfbb1x.app -side right -pady 4 -padx 2
		#	CANVAS AND VALUE LISTING

		set pdc(can) [canvas $pdw.c -height $pdc(height) -width $pdc(width) -borderwidth 0 \
			-highlightthickness 1 -highlightbackground $evv(SPECIAL)]

		pack $pdw.z0 -side top -fill x -expand true
		pack $pdw.btns0 -side top -fill x 
		pack $pdw.z0x -side top -fill x -expand true
		pack $pdw.btns0x -side top -fill x 
		pack $pdw.z1 -side top -fill x -expand true
		pack $pdw.btns1x -side top -fill x 
		pack $pdw.btns1 -side top -fill x 
		pack $pdw.z2 -side top -fill x -expand true -pady 2
		pack $pdw.c -side top -fill both

		bind $pdc(can) <ButtonPress-1> 			{BoxBegin %W %x}
		bind $pdc(can) <B1-Motion> 				{BoxDrag %W %x}
		bind $pdc(can) <Control-ButtonPress-1> 	{LineMark %W %x}
		bind $pdc(can) <Shift-ButtonPress-1> 	{IpointMark %W %x %y}
		bind $pdc(can) <ButtonRelease-1> 		{BoxDelete %W %x}
		bind $pdc(can) <Control-Command-ButtonRelease-1> 		{LineWhere %W %x}

	 	lappend pdisplay_emph $sfbb0.dis $sfbb1.smo $sfbb1.tra
		bind $f <Escape> {set pr_pdisplay 0}
	}
 	set pwinpos ""
	ForceVal $pdw.btns0.dum1 $pwinpos
	set ptimpos ""
	ForceVal $pdw.btns0.dum2 $ptimpos
	set psmppos ""
 	ForceVal $pdw.btns0.dum3 $psmppos
	set pdisval ""
	ForceVal $pdw.btns0.dum4 $pdisval
 	set pdismid ""
 	ForceVal $pdw.btns0.dum5 $pdismid
	set pdc(curval) ""
 	set pdc(curve) 0
	set pdc(thisblok) 0
	ForceVal $pdw.btns0.toe $pdc(endblok)
	ForceVal $pdw.btns0.tte $pdc(thisblok)
	set pdc(lastblok) ""
	ForceVal $pdw.btns0.tse $pdc(lastblok)
	set pdc(transpose) 12
	SetGridParams
	Draw_A_Grid
	set pr_pdisplay 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_pdisplay
	PDisplayData
	while {!$finished} {
		tkwait variable pr_pdisplay
		if {$pr_pdisplay} {	   						;# GET DISPLAY
			if {[string length $pdc(thisblok)] <= 0} {
				Inf "No data block specified"
				continue
			} elseif {([string length $pdc(lastblok)] > 0) && ($pdc(thisblok) == $pdc(lastblok))} {
				Inf "The window has not changed"
				continue
			}
			PDisplayData
		} else {
			set finished 1
		}
	}
	if [file exists $pdc(texttemp)] {
		if [catch {file delete $pdc(texttemp)} zog] {
			Inf "Cannot delete temporary file $pdc(texttemp)\n\nFor Safety, Delete It Now, Outside The CDP."
		}
	}
	if [file exists $pdc(analtemp)] {
		if [catch {file delete $pdc(analtemp)} zog] {
			Inf "Cannot delete temporary file $pdc(analtemp)\n\nFor Safety, Delete It Now, Outside The CDP."
		}
	}
	if [file exists $pdc(sndtemp)] {
		if [catch {file delete $pdc(sndtemp)} zog] {
			Inf "Cannot delete temporary file $pdc(sndtemp)\n\nFor Safety, Delete It Now, Outside The CDP."
		}
	}
	set es 0
	if {$pdc(es)} {
		set es 1
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	if {$es} {
		DoWkspaceQuit 0 0
	}
	catch {unset pdc}
}		

#--- Increment the number of the blok to be displayed

proc IncrPdBlok {up} {
	global pdc pdw

	if {$up == 1} {
		if {$pdc(thisblok) < $pdc(endblok)} {
			incr pdc(thisblok)
			ForceVal $pdw.btns0.tte $pdc(thisblok)
		} else {
			Inf "This is the last block of data."
		}
	} else {
		if {$pdc(thisblok) > 0} {
			incr pdc(thisblok) -1
			ForceVal $pdw.btns0.tte $pdc(thisblok)
		} else {
			Inf "This is the first block of data."
		}
	}
}

#--- Start drawing a box on the display

proc BoxBegin {w x} {
	global pdc

	if {![info exists pdc(lcoords)]} {
		Inf "You must display a block of data, before marking a canvas area."
		return
	}
	set pdc(mark) 0
	set pdc(anchor) [list $x 0]
	catch {unset pdc(box)}
	catch {unset pdc(ipoint)}
	catch {$pdc(can) delete ipoint}
}

#--- Draw a box on the display

proc BoxDrag {w x} {
	global pdc evv

	if {![info exists pdc(lcoords)] || ![info exists pdc(anchor)]} {
		return
	}
	catch {$pdc(can) delete box}
	set pdc(box) [eval {$w create rect} $pdc(anchor) {$x $pdc(height) -fill $evv(EMPH) -tag box}]
	eval {$pdc(can) create line} $pdc(lcoords) {-fill $evv(BOX)} {-tag line}
}

#--- Delete any box on the display

#--- Delete any box on the display

proc BoxDelete {w x} {
	global pdc

	if {![info exists pdc(anchor)]} {
		return
	}
	if {!$pdc(mark)} {	
		if {$x == [lindex $pdc(anchor) 0]} {
			catch {$pdc(can) delete box}
			catch {$pdc(can) delete ipoint}
			catch {unset pdc(box)}
			catch {unset pdc(ipoint)}
			catch {unset pdc(xi)}
		} else {
			Draw_A_Grid
		}
	}
}

#--- Mark one point on the display

proc LineMark {w x} {
	global pdc evv

	set pdc(mark) 1
	catch {$pdc(can) delete box}
	set pdc(box) [eval {$w create rect $x 0 $x $pdc(height) -tag box -fill $evv(POINT)}]

}

#--- Mark one point INSIDE BOX on the display

proc IpointMark {w x y} {
	global pdc evv

	if {($y < $pdc(ymargin)) || ($y > $pdc(lowlim))} {
		return
	}
	if {![info exists pdc(box)]} {
		Inf "You must Mark An Area, before drawing an Insert Point"
		return
	}
	if [info exists pdc(ipoint)] {
		catch {$pdc(can) delete ipoint}
		unset pdc(ipoint)
	}
	set xd $x 
	incr xd $pdc(-xmargin)					;# Adjust for margins
	if $pdc(stretched) {		  			;#	And stretch
		set xd [expr int(round(($xd / $pdc(lenscale)) + $pdc(leftedge)))]		
	}
	set edges [BoxEdges]
	if {($xd <= [lindex $edges 0]) || ($xd >= [lindex $edges 1])} {
		Inf "Insert point must be (fully) Inside the marked area"
		return
	}
	set pdc(xi) $xd
	set pdc(yi) $y

	set pdc(ix_coord) $x
	set pdc(iy_coord) $y
	set xa [expr $x + $evv(PWIDTH)]
	set pdc(ixa_coord) $xa
	set ya [expr $y + $evv(PWIDTH)]
	set pdc(i_coords) [list $x $y $xa $ya]
	set pdc(ipoint) [eval {$w create rect} $pdc(i_coords) { -fill $evv(POINT) -tag ipoint}]
}

#--- Display a block of data

proc PDisplayData {} {
	global pdc pdw mu silence evv

	set start [expr int($pdc(thisblok) * $pdc(bloksize))]
	set end [expr int($start + $pdc(effective_width))]
	incr end -1
	if {$end > $pdc(dataend)} {
		set end $pdc(dataend)
	}
	set pdc(length) [expr $end - $start + 1]
	set pdc(newdata) [lrange $pdc(data) $start $end]
	if {[llength $pdc(newdata)] <= 0} {
		Inf "No further data"
		return
	}
	set pdc(zoomed) 0
	set pdc(origdata) $pdc(newdata)
	set pdc(lastdata) $pdc(newdata)

	catch {$pdc(can) delete line}
	catch {$pdc(can) delete silence}

	catch {unset pdc(newline)}
	set x 0
	set pdc(maxmidi) 0
	set pdc(minmidi) $mu(MIDIMAX)
	catch {unset silence}
	foreach frq $pdc(newdata) {
		if [string match "-1.*" $frq] {
			set frq -1.0
			lappend silence 2
		} elseif [string match "-2.*" $frq] {
			lappend silence 1
		} else {
			lappend silence 0
		}
		set midi [HzToMidi $frq]
		if {$midi > $pdc(maxmidi)} {
			set pdc(maxmidi) $midi
		} elseif {$midi < $pdc(minmidi)} {
			set pdc(minmidi) $midi
		}
		set y [expr int(round($midi * $pdc(scaler)))]
		set y [expr $pdc(effective_height) - $y]
		incr y $pdc(ymargin) 
		set xd [expr $x + $pdc(xmargin)]
		lappend pdc(newline) $xd $y	
		incr x
	}	
	incr x -1
	set pdc(miny) [expr $pdc(minmidi) * $pdc(scaler)]
	set pdc(prange) [expr $pdc(maxmidi) - $pdc(minmidi)]
	set pdc(orig,maxmidi) $pdc(maxmidi)
	set pdc(orig,minmidi) $pdc(minmidi)
	set pdc(orig,miny) $pdc(miny)
	set pdc(orig,prange) $pdc(prange)
	set pdc(last,maxmidi) $pdc(maxmidi)
	set pdc(last,minmidi) $pdc(minmidi)
	set pdc(last,miny) $pdc(miny)
	set pdc(last,prange) $pdc(prange)
	set pdc(lcoords) $pdc(newline)
	eval {$pdc(can) create line} $pdc(newline) {-fill $evv(GRAF)} {-tag line}
	DrawSilence
	set pdc(origline) $pdc(newline)
	set pdc(lastline) $pdc(newline)
	set pdc(lastblok) $pdc(thisblok)
	ForceVal $pdw.btns0.tse $pdc(lastblok)
	set pdc(endx) $x
	catch {$pdc(can) delete timeline}
	DrawPTimeline
	Draw_A_Grid
}

#--- Convert Hz data to Pitch (MIDI) data

proc HzToMidi {frq} {
	global mu evv
	if {$frq < $evv(LOW_A)} {
		set frq $evv(LOW_A)
	}
   	set midi [expr $frq / $evv(LOW_A)]
	set midi [expr (log10($midi) * $evv(CONVERT_LOG10_TO_LOG2) * 12.0) - 3.0]
	if {$midi > $mu(MIDIMAX)} {
		set midi $mu(MIDIMAX)
	} elseif {$midi < 0} {
		set midi 0
	}
	return $midi
}

#--- Convert Pitch (MIDI) data to Hz data

proc MidiToHz {midi} {
	global evv
	set frq [expr ($midi + 3.0) / 12.0]
	set frq [expr pow(2.0,$frq) * $evv(LOW_A)]
	return $frq
}

#--- Smooth the pitch data at a point or through a window drawn on canvas

proc PdSmooth {insert} {
	global pdc pdw evv

	if {![info exists pdc(newline)]} {
		Inf "No pitch data is displayed"
		return
	}
	if {![info exists pdc(box)]} {
		Inf "No pitches have been marked with the mouse"
		return
	}
	if {$insert} {
		if {![info exists pdc(xi)]} {
			Inf "No insert point has been marked with the mouse"
			return
		}
	}
	if {([string length $pdc(curval)] > 0)} {
		if {![regexp {[1-9]+} $pdc(curval)]} {
			Inf "Invalid curvature value: must be numeric, and >= 1"
			return
		}		
		if {$pdc(curval) > $evv(MAXCURVE)} {
			Inf "Curvature value is too extreme (max $evv(MAXCURVE))"
			return
		}		
		set curvature 1
	}
	set edges [BoxEdges]
	set x1 [lindex $edges 0]
	set x2 [lindex $edges 1]
	if {$x1 < 0} {
		set x1 0
	}
	if {$x2 > $pdc(endx)} {
		set x2 $pdc(endx)
	}
	if  {!$insert && [string match "smoothed" [lindex $pdc(last) 0]]} {
		if {($pdc(thisblok) == [lindex $pdc(last) 1]) \
		&& ($x1 == [lindex $pdc(last) 2]) && ($x2 == [lindex $pdc(last) 3])} {
			return			;#	Prevent double takes of same operation: messes up UNDO 
		}
	} elseif {$insert && [string match "inserted" [lindex $pdc(last) 0]]} {
		if {($pdc(thisblok) == [lindex $pdc(last) 1]) \
		&& ($x1 == [lindex $pdc(last) 2]) && ($x2 == [lindex $pdc(last) 3])\
		&& ($pdc(xi) == [lindex $pdc(last) 4]) && ($pdc(yi) == [lindex $pdc(last) 5]) \
		&& ($pdc(curval) == [lindex $pdc(last) 6]) && ($pdc(curve) == [lindex $pdc(last) 7])} {
			return			;#	Prevent double takes of same operation: messes up UNDO 
		}
	}

	set endindx [llength $pdc(newline)]
	set endindx [expr ($endindx/2) - 1]
	if {$x1 > $endindx} {
		Inf "marked area is not over pitch"
		return
	}
	set coords $pdc(newline)
	if {$x1 == $x2} {
		if {$x1 == 0} {		;# DEAL WITH SINGLE SMOOTHED VAL AT START OF DISPLAY
			if {$endindx == 0} {
				Inf "Sorry: no data to smooth to!!"
				return
			}
			set pdc(last) [list smoothed $pdc(thisblok) $x1 $x2]
			set xc1 3
			set rval [lindex $coords $xc1]
			set pdc(lastline) $pdc(newline)
			set pdc(newline) [lreplace $pdc(newline) 1 1 $rval]
			set xc1 -2
			set xc2 $xc1
		} elseif {$x1 >= $endindx} {	;# DEAL WITH SINGLE SMOOTHED VAL AT END OF DISPLAY
			set pdc(last) [list smoothed $pdc(thisblok) $x1 $x2]
			set xc1 [expr (($x1 - 1) * 2) + 1]
			set lval [lindex $coords $xc1]
			set pdc(lastline) $pdc(newline)
			set pdc(newline) [lreplace $pdc(newline) end end $lval]
			incr xc1 2
			set xc2 $xc1
		} else {			;# DEAL WITH SINGLE SMOOTHED VAL IN MIDST OF DISPLAY
			set pdc(last) [list smoothed $pdc(thisblok) $x1 $x2]
			incr x1 -1
			set xc1 [expr ($x1 * 2) + 1]
			set lval [lindex $coords $xc1]
			incr x1 2
			set xc2 [expr ($x1 * 2) + 1]
			set rval [lindex $coords $xc2]
			set newval [expr ($rval + $lval) / 2.0]
			incr x1 -1
			set xc1 [expr ($x1 * 2) + 1]
			set xc2 $xc1
			set pdc(lastline) $pdc(newline)
			set pdc(newline) [lreplace $pdc(newline) $xc1 $xc2 $rval]
		}
	} else {
		set step [expr $x2 - $x1]			;#	Find distance between them
		set xc1 [expr ($x1 * 2) + 1]
		set xc2 [expr ($x2 * 2) + 1]
		if {$insert} {
			set pdc(last) [list inserted $pdc(thisblok) $x1 $x2 $pdc(xi) $pdc(yi) $pdc(curval) $pdc(curve)]
		} else {
			set pdc(last) [list smoothed $pdc(thisblok) $x1 $x2]
		}
		incr x1 $pdc(xmargin)				;#	Convert to real frame for comparison with line coords
		incr x2 $pdc(xmargin)
											;#	Get coords of line
		set lval [lindex $coords $xc1]		;#	Find y coords at edges of box
		set rval [lindex $coords $xc2]
		set range [expr $rval - $lval]

		set pdc(lastline) $pdc(newline)
		unset pdc(newline)

		if {$insert} {
			set kmax -1
			set kmin 10000
			set xc3 [expr ($pdc(xi) * 2) + 1]
			set newmidi [expr ($pdc(effective_height) - $pdc(yi) + $pdc(ymargin)) / $pdc(scaler)]
			if {$pdc(zoomed)} {
				set newmidi [expr ($newmidi / $pdc(zoomratio)) + $pdc(minmidi)]	
				set pdc(yi) [expr $pdc(effective_height) - ($newmidi * $pdc(scaler)) + $pdc(ymargin)]
			}
			set ival $pdc(yi)
			set xi [expr int($pdc(xi) + $pdc(xmargin))]
			set range1 [expr $ival - $lval]
			set range2 [expr $rval - $ival]
			set step1 [expr $xi - $x1]
			set step2 [expr $x2 - $xi]
			set r1 0
			set r2 0
			set r1up 0
			set r2up 0
			if {([expr abs($range1)] > $evv(FLTERR))} {
				set r1 1
				if {$range1 > 0.0} {
					set r1up 1
				}
			}
			if {([expr abs($range2)] > $evv(FLTERR))} {
				set r2 1
				if {$range2 > 0.0} {
					set r2up 1
				}
			}
			if {$r1 || $r2} {			;#	IF AT LEAST ONE RANGE IS NON-ZERO
				if [info exists curvature] {	;# IF SMOOTH IS NOT LINEAR
					set i 1
					set j 1
					if {!$r1} {			;#	IF RANGE OF FIRST IS ZERO, CURVE 2nd
						if {(($pdc(curve) > 0) && ($range2 > 0)) \
						||  (($pdc(curve) < 0) && ($range2 < 0)) } {
							set curvature [expr 1.0 / $pdc(curval)]
						} else { 
							set curvature $pdc(curval)
						}
						foreach {x y} $coords {
							if {($x > $x1) && ($x < $xi)} {
								set y $ival
							} elseif {($x > $xi) && ($x < $x2)} {
								set thistep [expr pow((double($j) / double($step2)),$curvature)]
								set y [expr $ival + ($thistep * $range2)]
								incr j 
							}
							if {$y > $kmax} {
								set kmax $y
							} elseif {$y < $kmin} {
								set kmin $y
							}
							lappend pdc(newline) $x $y
						}
					} elseif {!$r2} {	;#	IF RANGE OF 2ND IS ZERO, CURVE 1st
						if {(($pdc(curve) > 0) && ($range1 > 0)) \
						||  (($pdc(curve) < 0) && ($range1 < 0)) } {
							set curvature [expr 1.0 / $pdc(curval)]
						} else { 
							set curvature $pdc(curval)
						}
						foreach {x y} $coords {
							if {($x > $x1) && ($x < $xi)} {
								set thistep [expr pow((double($i) / double($step1)),$curvature)]
								set y [expr $lval + ($thistep * $range1)]
								incr i 
							}
							if {$y > $kmax} {
								set kmax $y
							} elseif {$y < $kmin} {
								set kmin $y
							}
							lappend pdc(newline) $x $y
						}
					} else {				;#	IF RANGE OF NEITHER IS ZERO
						set spline 0
						if {$r1up && !$r2up} {			;#	IF PEAKS IN CENTRE
							if {$pdc(curve) > 0} {
								set curvature [expr 1.0 / $pdc(curval)]
							} else { 
								set curvature $pdc(curval)
							}
						} elseif {!$r1up && $r2up} {	;#	IF DIPS IN CENTRE
							if {$pdc(curve) < 0} {
								set curvature $pdc(curval)
							} else { 
								set curvature [expr 1.0 / $pdc(curval)]
							}
						} else {						;#	OTHERWISE, SPLINE THEME
							set xincr [expr double($step1) / double($step)]
							set yincr [expr double($range1) / double($range)]
							set curvature [expr log($yincr) / log($xincr)]						
							set spline 1
						}
						if {$spline} {
							foreach {x y} $coords {
								if {($x > $x1) && ($x < $x2)} {
									set thistep [expr pow((double($i) / double($step)),$curvature)]
									set y [expr $lval + ($thistep * $range)]
									incr i 
								}
								if {$y > $kmax} {
									set kmax $y
								} elseif {$y < $kmin} {
									set kmin $y
								}
								lappend pdc(newline) $x $y
							}
						} else {
							foreach {x y} $coords {
								if {($x > $x1) && ($x < $xi)} {
									set thistep [expr pow((double($i) / double($step1)),$curvature)]
									set y [expr $lval + ($thistep * $range1)]
									incr i 
								} elseif {$x == $xi} {
									set thistep [expr pow((double($i) / double($step1)),$curvature)]
									set y [expr $lval + ($thistep * $range1)]
									set curvature [expr 1.0 / $curvature]
								} elseif {($x > $xi) && ($x < $x2)} {
									set thistep [expr pow((double($j) / double($step2)),$curvature)]
									set y [expr $ival + ($thistep * $range2)]
									incr j 
								}
								if {$y > $kmax} {
									set kmax $y
								} elseif {$y < $kmin} {
									set kmin $y
								}
								lappend pdc(newline) $x $y
							}
						}
					}
				} else {					;#	CURVE IS FLAT
					set incr1 [expr double($range1) / double($step1)]
					set incr2 [expr double($range2) / double($step2)]
					set thisincr1 $incr1		   			;#	Find the 1st val-by-val incr to create smooth link
					set thisincr2 $incr2		   			;#	Find the 2nd
					foreach {x y} $coords {
						if {($x > $x1) && ($x <= $xi)} {
							set y [expr $lval + $thisincr1]
							set thisincr1 [expr $thisincr1 + $incr1]
						} elseif {($x > $xi) && ($x < $x2)} {
							set y [expr $ival + $thisincr2]
							set thisincr2 [expr $thisincr2 + $incr2]
						}
						if {$y > $kmax} {
							set kmax $y
						} elseif {$y < $kmin} {
							set kmin $y
						}
						lappend pdc(newline) $x $y
					}
				}
			}
		} elseif {[expr abs($range)] > $evv(FLTERR)} {
			if [info exists curvature] {
				set i 1
				if {(($pdc(curve) > 0) && ($range > 0)) \
				||  (($pdc(curve) < 0) && ($range < 0)) } {
					set curvature [expr 1.0 / $pdc(curval)]
				} else { 
					set curvature $pdc(curval)
				}
				foreach {x y} $coords {
					if {($x > $x1) && ($x < $x2)} {
						set thistep [expr pow((double($i) / double($step)),$curvature)]
						set y [expr $lval + ($thistep * $range)]
						incr i 
					}
					lappend pdc(newline) $x $y
				}
			} else {
				set incr [expr double($range) / (double($step))]
				set thisincr $incr		   			;#	Find the val-by-val incr to create smooth link
				foreach {x y} $coords {
					if {($x > $x1) && ($x < $x2)} {
						set y [expr $lval + $thisincr]
						set thisincr [expr $thisincr + $incr]
					}
					lappend pdc(newline) $x $y
				}
			}
		} else {			;#	MIDI value is same at start and end
			set firsttime 1
			foreach {x y} $coords {
				if {($x > $x1) && ($x < $x2)} {
					if {$firsttime} {
						set yflat $y
						set firsttime 0
					}
					set y $yflat
				}
				lappend pdc(newline) $x $y
			}
		}
	}
	catch {$pdc(can) delete line}
	set pdc(lcoords) $pdc(newline)
	if {$pdc(stretched)} {
		catch {$pdc(can) delete box}
		set pdc(box) [$pdw.c create rect $x1 0 $x2 $pdc(height) -fill $evv(EMPH) -tag box]
	}
	if {[info exists pdc(ipoint)] && ($pdc(stretched) || $pdc(zoomed))} {
		if {![info exists xi]} {
			set xi [expr int($pdc(xi) + $pdc(xmargin))]
		}
		set xa [expr $xi + $evv(PWIDTH)]
		set ya [expr $pdc(yi) + $evv(PWIDTH)]
		set pdc(ix_coord) $xi
		set pdc(ixa_coord) $xa
		set pdc(iy_coord) $pdc(yi)
		catch {$pdc(can) delete ipoint}
		set pdc(ipoint) [$pdw.c create rect $xi $pdc(yi) $xa $ya  -fill $evv(POINT) -tag ipoint]
	}
	if {$insert} {
		set pdc(last,maxmidi) $pdc(maxmidi)
		set pdc(last,minmidi) $pdc(minmidi)
		set pdc(last,miny) 	  $pdc(miny)
		set pdc(last,prange)  $pdc(prange)
		set pdc(miny) [expr $pdc(effective_height) - $kmax + $pdc(ymargin)]
		set pdc(minmidi) [expr $pdc(miny) / $pdc(scaler)]
		set pdc(maxy) [expr $pdc(effective_height) - $kmin + $pdc(ymargin)]
		set pdc(maxmidi) [expr $pdc(maxy) / $pdc(scaler)]
		set pdc(prange) [expr $pdc(maxmidi) - $pdc(minmidi)]
	}
	set pdc(stretched) 0
	set pdc(zoomed) 0
	catch {$pdc(can) delete silence}
	DrawSilence
	Draw_A_Grid
	eval {$pdc(can) create line} $pdc(newline) {-fill $evv(GRAF)} {-tag line}
}
	
#--- Tranpose the pitch data in a window drawn on canvas

proc PdTranspose {} {
	global pdc pdw evv

	set kmax -1
	set kmin 10000
	if {![info exists pdc(newline)]} {
		Inf "No pitch data is displayed"
		return
	}
	if {![info exists pdc(box)]} {
		Inf "No pitches have been marked with the mouse"
		return
	}
	if {([string length $pdc(transpose)] <= 0) || ![IsNumeric $pdc(transpose)]} {
		Inf "No valid transposition has been proposed"
		return
	} elseif {$pdc(transpose) > $evv(MAXTRANSP)} {
		set pdc(transpose) $evv(MAXTRANSP)
	} elseif {$pdc(transpose) < $evv(MINTRANSP)} {
		set pdc(transpose) $evv(MINTRANSP)
	}
	set edges [BoxEdges]
	set x1 [lindex $edges 0]
	set x2 [lindex $edges 1]
	set endindx [llength $pdc(newline)]
	set endindx [expr ($endindx/2) - 1]
	if {$x1 > $endindx} {
		Inf "marked area is not over pitch line"
		return
	}
	set transp [expr -($pdc(transpose) * $pdc(scaler))]

	set coords $pdc(newline)
	set pdc(lastline) $pdc(newline)
	unset pdc(newline)
	set pdc(last) transposed
	incr x1 $pdc(xmargin)				;#	Convert to real frame for comparison with line coords
	incr x2 $pdc(xmargin)
	foreach {x y} $coords {
		if {($x >= $x1) && ($x <= $x2)} {
			set y [expr $y + $transp]
			if {$y > $pdc(lowlim)} {
				set y $pdc(lowlim)
			} elseif {$y < $pdc(ymargin)} {
				set y $pdc(ymargin)
			}
		}
		if {$y > $kmax} {
			set kmax $y
		} elseif {$y < $kmin} {
			set kmin $y
		}
		lappend pdc(newline) $x $y
	}
	catch {$pdc(can) delete line}
	set pdc(lcoords) $pdc(newline)
	if {$pdc(stretched)} {
		catch {$pdc(can) delete box}
		set pdc(box) [$pdw.c create rect $x1 0 $x2 $pdc(height) -fill $evv(EMPH) -tag box]
		if [info exists pdc(ipoint)] {
			catch {$pdc(can) delete ipoint}
		}
	}
	catch {$pdc(can) delete ipoint}
	catch {unset pdc(ipoint)}
	set pdc(zoomed) 0
 	if {$pdc(stretched)} {
		catch {$pdc(can) delete silence}
		DrawSilence
	}
	set pdc(stretched) 0
	Draw_A_Grid
	eval {$pdc(can) create line} $pdc(newline) {-fill $evv(GRAF)} {-tag line}
	set pdc(last,maxmidi) $pdc(maxmidi)
	set pdc(last,minmidi) $pdc(minmidi)
	set pdc(last,miny) 	  $pdc(miny)
	set pdc(last,prange)  $pdc(prange)
	set pdc(miny) [expr $pdc(effective_height) - $kmax + $pdc(ymargin)]
	set pdc(minmidi) [expr $pdc(miny) / $pdc(scaler)]
	set pdc(maxy) [expr $pdc(effective_height) - $kmin + $pdc(ymargin)]
	set pdc(maxmidi) [expr $pdc(maxy) / $pdc(scaler)]
	set pdc(prange) [expr $pdc(maxmidi) - $pdc(minmidi)]
}

#--- Undo last action on canvas

proc PdUndo {} {
	global pdc evv

	if {![info exists pdc(newline)]} {
		return
	}
	catch {$pdc(can) delete line}
	catch {$pdc(can) delete ipoint}
	catch {unset pdc(ipoint)}
	set pdc(newline) $pdc(lastline)
	set pdc(lcoords) $pdc(newline)
	set pdc(zoomed) 0
 	if {$pdc(stretched)} {
		catch {$pdc(can) delete silence}
		DrawSilence
	}
	set pdc(stretched) 0
	Draw_A_Grid
	eval {$pdc(can) create line} $pdc(newline) {-fill $evv(GRAF)} {-tag line}
	set pdc(last) ""
	set pdc(maxmidi) $pdc(last,maxmidi)
	set pdc(minmidi) $pdc(last,minmidi)
	set pdc(miny) 	 $pdc(last,miny)
	set pdc(prange)  $pdc(last,prange)
}

#--- Return to where you started with this blok of data

proc PdRestart {} {
	global pdc evv

	if {![info exists pdc(newline)]} {
		return
	}
	catch {$pdc(can) delete line}
	catch {$pdc(can) delete ipoint}
	catch {unset pdc(ipoint)}
	set pdc(lastline) $pdc(newline)
	set pdc(newline) $pdc(origline)
	set pdc(lcoords) $pdc(newline)
	set pdc(zoomed) 0
	set pdc(stretched) 0
	catch {$pdc(can) delete silence}
	DrawSilence
	Draw_A_Grid
	eval {$pdc(can) create line} $pdc(newline) {-fill $evv(GRAF)} {-tag line}
	set pdc(last) ""
	set pdc(maxmidi) $pdc(orig,maxmidi)
	set pdc(minmidi) $pdc(orig,minmidi)
	set pdc(miny) 	 $pdc(orig,miny)
	set pdc(prange)  $pdc(orig,prange)
}


#--- update the text pitchdata

proc PdApply {} {
	global pdc

	if {![info exists pdc(newline)]} {
		Inf "No data is displayed"
		return
	}
	set start [expr $pdc(thisblok) * $pdc(effective_width)]
	set end [expr $start + $pdc(effective_width)]
	incr end -1
	if {$end > $pdc(dataend)} {
		set end $pdc(dataend)
	}
	if {$start > 0} {
		set newerdata [lrange $pdc(data) 0 [expr $start - 1]]
	}
	foreach {x y} $pdc(newline) {oldfrq} $pdc(newdata) {
		if [string match "-1.*" $oldfrq] {
			set oldfrq -1.0
		}
		if [string match "-2.*" $oldfrq] {
			set frq -2.0
		} else {
			set y [expr $y + $pdc(-ymargin)]			;#	Remove effect of margins
			set y [expr $pdc(effective_height) - $y]	;#	Invert Display
			set midi [expr $y/$pdc(scaler)]				;#	Scale to MIDI value
			if [flteq $midi 0.0] {
				set frq -1.0
			} else {
				set frq [MidiToHz $midi]				;#	Convert to Frq
			}
		}
		lappend newerdata $frq
	}
	if {$end < $pdc(dataend)} {
		incr end
		set pdc(data) [concat $newerdata [lrange $pdc(data) $end $pdc(dataend)]]
	} else {
		set pdc(data) $newerdata
	}
	incr pdc(datano)
}

#--- Create new pitchdata file

proc PdSave {fnam} {
	global pdc pr_pdisplay wl last_outfile CDPidrun pa done_pdisplayput new_cdp_extensions evv

	if {![info exists pdc(outfile)] || [string length $pdc(outfile)] <= 0} {
		Inf "No outfilename given"
		return
	}		
	if {![ValidCDPRootname $pdc(outfile)]} {
		return
	}
	if {$new_cdp_extensions} {
		set nufnam $pdc(outfile)$evv(PITCHFILE_EXT)
	} else {
		set nufnam $pdc(outfile)$evv(SNDFILE_EXT)
	}

	if {[LstIndx $nufnam $wl] >= 0} {
		Inf "File already exists on workspace : Cannot overwrite it here."
		return
	}		
	if {[file exists $pdc(pichtemp)] && ($pdc(datano) == $pdc(saveno))} {
		if {[file exists $nufnam]} {
			if {![catch {file rename -force $pdc(pichtemp) $nufnam} zog]} {
				return
			}
		} else {
			if {![catch {file rename $pdc(pichtemp) $nufnam} zog]} {
				return
			}
		}
	}
	if [catch {open $pdc(texttemp) w} fId] {
		Inf "Cannot open temporary file $pdc(texttemp) to write new pitch data."
		return
	}
	foreach item $pdc(data) {
		puts $fId $item
	}
	catch {close $fId}
	set done_pdisplayput 0
	set cmd [file join $evv(CDPROGRAM_DIR) pmodify]

	if [ProgMissing $cmd "Program to write new pitch data is missing"] {
		return
	}
	lappend cmd $pdc(texttemp) $nufnam
	lappend cmd $pa($fnam,$evv(ORIGCHANS)) $pa($fnam,$evv(ORIGSTYPE)) $pa($fnam,$evv(ORIGRATE))
	lappend cmd $pa($fnam,$evv(ARATE)) $pa($fnam,$evv(MLEN)) $pa($fnam,$evv(DFAC)) 
	lappend cmd $pa($fnam,$evv(SRATE)) $pa($fnam,$evv(CHANS))

	if [catch {open "|$cmd"} CDPidrun] {
		ErrShow "$CDPidrun"
		ErrShow "Cannot run process to write new pitch data"
		return
	} else {
   		fileevent $CDPidrun readable "PDisplayPut"
	}
	vwait done_pdisplayput
	if {$done_pdisplayput} {
		if {[FileToWkspace $nufnam 0 0 0 1 1] <= 0} {
			Inf "Cannot put the file $nufnam on the workspace, but it is in the home directory."
		}
		AddNameToNameslist $nufnam 0
		set last_outfile $nufnam
	}
	if {!$done_pdisplayput} {
		return
	}
	set pdc(saveno) $pdc(datano)
	set pr_pdisplay 0
	return
}

#------ Transfer all pitch data to internal array

proc PdGrab {} {
	global done_pdisplayget chlist pdc onam CDPidrun evv

	set cmd [file join $evv(CDPROGRAM_DIR) pdisplay]

	if [ProgMissing $cmd "Program to grab the pitch data is missing"] {
		return 0
	}
	set fnam [lindex $chlist 0]
	lappend cmd $fnam

	catch {unset pdc(data)}
	if [catch {open "|$cmd"} CDPidrun] {
		ErrShow "$CDPidrun"
		ErrShow "Cannot run process to display pitch data"
		return 0
	} else {
   		fileevent $CDPidrun readable "PDisplayGet"
	}
	vwait done_pdisplayget
	if {$done_pdisplayget} {
		set pdc(dataend) [expr ([llength $pdc(data)] - 1)]
	}
	return $done_pdisplayget
}

#------ Grab pitch data for pitch display

proc PDisplayGet {} {
	global CDPidrun done_pdisplayget pdc

	if [eof $CDPidrun] {
		catch {close $CDPidrun}
		set done_pdisplayget 1
		return
	} else {
		gets $CDPidrun line
		set line [string trim $line]
		if {[string length $line] <= 0} {
			return
		}
		if [string match INFO:* $line] {
			set line [string range $line 6 end] 
			lappend pdc(data) "$line"
			return
		} elseif [string match ERROR:* $line] {
			set line [string range $line 7 end] 
			Inf "$line"
			set done_pdisplayget 0
			catch {close $CDPidrun}
			return
		}
	}
	update idletasks
}

#------ Put pitch data from pitch display to binary file

proc PDisplayPut {} {
	global CDPidrun done_pdisplayput

	if [eof $CDPidrun] {
		set done_pdisplayput 1
		catch {close $CDPidrun}
		return
	} else {
		gets $CDPidrun line
		set line [string trim $line]
		if {[string length $line] <= 0} {
			return
		} elseif [string match WARNING:* $line] {
			set line [string range $line 9 end] 
			Inf "$line"
			return
		} elseif [string match ERROR:* $line] {
			set line [string range $line 7 end] 
			Inf "$line"
			set done_pdisplayput 0
			catch {close $CDPidrun}
			return
		}
	}
	update idletasks
}


#--- Zoom in on pitch-display

proc PdZoom {} {
	global pdc mu evv

	if {![info exists pdc(newline)]} {
		Inf "No pitch data is displayed"
		return
	}
	catch {$pdc(can) delete line}
	if {$pdc(zoomed)} {
		set pdc(zoomed) 0
		Draw_A_Grid
		if {$pdc(stretched)} {
			set pdc(lcoords) $pdc(stretch)
			eval {$pdc(can) create line} $pdc(stretch) {-fill $evv(GRAF)} {-tag line}
		} else {
			set pdc(lcoords) $pdc(newline)
			eval {$pdc(can) create line} $pdc(newline) {-fill $evv(GRAF)} {-tag line}
		}
		if [info exists pdc(ipoint)] {
			UnZoomPoint
		}
		set pdc(zoomratio) 1
	} else {
		set pdc(zoomratio) [expr $mu(MIDIMAX) / $pdc(prange)]
		foreach {x y} $pdc(newline) {
			set y [expr $y + $pdc(-ymargin)]				;# Remove margin
			set y [expr $pdc(effective_height) - $y]		;# Invert Display
			set midi [expr $y/$pdc(scaler)]					;# Scale to MIDI value
			set y [expr $midi - $pdc(minmidi)]					;# Rescale within max-min range
			set y [expr $y * $pdc(zoomratio)]				;# and blow up to max MIDI range
			set y [expr int(round($y * $pdc(scaler)))]		;# scale to display
			set y [expr $pdc(effective_height) - $y]		;# invert
			incr y $pdc(ymargin) 							;# add margin
			lappend zoom $x $y
		}
		set pdc(zoom) $zoom
		if $pdc(stretched) {
			catch {unset zoom}
			foreach {x y} $pdc(stretch) {
				set y [expr $y + $pdc(-ymargin)]				;# Remove margin
				set y [expr $pdc(effective_height) - $y]		;# Invert Display
				set midi [expr $y/$pdc(scaler)]					;# Scale to MIDI value
				set y [expr $midi - $pdc(minmidi)]					;# Rescale within max-min range
				set y [expr $y * $pdc(zoomratio)]				;# and blow up to max MIDI range
				set y [expr int(round($y * $pdc(scaler)))]		;# scale to display
				set y [expr $pdc(effective_height) - $y]		;# incert
				incr y $pdc(ymargin) 							;# add margin
				lappend zoom $x $y
			}
		}
		set pdc(lcoords) $zoom
	 	set pdc(zoomed) 1
		SetZoomGridParams
		Draw_A_Grid
		eval {$pdc(can) create line} $zoom {-fill $evv(GRAF)} {-tag line}
		if [info exists pdc(ipoint)] {
			ZoomPoint
		}
	}
}

#--- End Session from Pdisplay

proc DoPdisplayQuit {} {
	My_Release_To_Dialog .pdisplay
	Dlg_Dismiss .pdisplay
	set pr_2 0
	DoWkspaceQuit 0 0
}

#--- Time-stretch pitch-display

proc PdStretch {} {
	global pdc mu silence evv
	if {![info exists pdc(newline)]} {
		Inf "No pitch data is displayed"
		return
	}
	if {[info exists pdc(box)]} {
		catch {$pdc(can) delete box}
		set pdc(mark) 0
		catch {unset pdc(box)}
	}
	catch {$pdc(can) delete line}
	if {$pdc(stretched) && ![info exists pdc(box)]} {		;#	UNSTRETCH
		if {$pdc(zoomed)} {
			set pdc(lcoords) $pdc(zoom)
			eval {$pdc(can) create line} $pdc(zoom) {-fill $evv(GRAF)} {-tag line}
		} else {
			set pdc(lcoords) $pdc(newline)
			eval {$pdc(can) create line} $pdc(newline) {-fill $evv(GRAF)} {-tag line}
		}
	 	set pdc(stretched) 0
		catch {$pdc(can) delete silence}
		DrawSilence
		catch {$pdc(can) delete timeline}
		DrawPTimeline
		return
	} elseif {[info exists pdc(box)]} {						;#	STRETCH CONTENTS OF BOX
		set edges [BoxEdges]
		set x1 [lindex $edges 0]
		set x2 [lindex $edges 1]
		set pdc(leftedge) $x1
		set pdc(rightedge) $x2
		set pdc(trange) [expr $x2 - $x1 + 1]
		set pdc(lenscale) [expr double($pdc(effective_width)) / double($pdc(trange))]
	} else {												;#	STRETCH DISPLAY NOT FILLING SCREEN
		if {$pdc(effective_width) == $pdc(length)} {
			Inf "Display is already at full width"
		}
		set pdc(leftedge) 0
		set pdc(rightedge) $pdc(length)
		set pdc(lenscale) [expr double($pdc(effective_width)) / double($pdc(length))]
	}
	set leftlim [expr $pdc(leftedge) + $pdc(xmargin)]
	set rightlim [expr $pdc(rightedge) + $pdc(xmargin)]
	set stepedge $pdc(lenscale)

	set i 0
	set stepedge $pdc(lenscale)

	foreach {x y} $pdc(newline) {
		if {$x < $leftlim} {
			continue
		}
		if {$x > $rightlim} {
			break
		}
		set istepedge [expr round($stepedge)]
		while {$i < $istepedge} {
			set xd [expr $i	+ $pdc(xmargin)]
			lappend stretch $xd $y
			incr i
		}
		set stepedge [expr $stepedge + $pdc(lenscale)]
	}
	set pdc(stretch) $stretch

	if {$pdc(zoomed)} {
		unset stretch
		set i 0
		set stepedge $pdc(lenscale)
		foreach {x y} $pdc(zoom) {
			if {$x < $leftlim} {
				continue
			}
			if {$x > $rightlim} {
				break
			}
			set istepedge [expr round($stepedge)]
			while {$i < $istepedge} {
				set xd [expr $i	+ $pdc(xmargin)]
				lappend stretch $xd $y
				incr i
			}
			set stepedge [expr $stepedge + $pdc(lenscale)]
		}
	}
	catch {$pdc(can) delete box}
	catch {unset pdc(box)}
	catch {$pdc(can) delete ipoint}
	catch {unset pdc(ipoint)}
	set pdc(lcoords) $stretch
	eval {$pdc(can) create line} $stretch {-fill $evv(GRAF)} {-tag line}
	catch {$pdc(can) delete silence}
	set orig_silence $silence
	if {!$pdc(stretched)} {
		set silence [CreateNewSilence $silence $pdc(lenscale)]
	}
	DrawSilence
	set silence $orig_silence
 	set pdc(stretched) 1
	Draw_A_Grid
}

#--- Get L and R edges of box, relative to effective pitch-data display

proc BoxEdges {} {
	global pdc

	set coords [$pdc(can) coords $pdc(box)]
	set x1 [expr int([lindex $coords 0])]	;# Get LR edges of box
	set x2 [expr int([lindex $coords 2])]
	incr x1 $pdc(-xmargin)					;# Adjust for margins
	incr x2 $pdc(-xmargin)
	if {$x1 > $x2} {
		set temp $x1						;# Put in order
		set x1 $x2
		set x2 $temp
	}
	if $pdc(stretched) {
		set x1 [expr int(round($x1 / $pdc(lenscale)))]		
		incr x1 $pdc(leftedge)
		set x2 [expr int(round($x2 / $pdc(lenscale)))]
		incr x2 $pdc(leftedge)
	}
	set edges [list $x1 $x2]
	return $edges
}

#---- Display curve value in box, and make box and buttions active

proc ShowCurve {} {
	global pdw pdc
	$pdw.btns1.cur config -state normal
	$pdw.btns1.cup config -state normal
	$pdw.btns1.cdn config -state normal
	set pdc(curval) 1
}

#---- Delete curve value in box, and disable box and buttons

proc HideCurve {} {
	global pdw pdc
	$pdw.btns1.cur config -state disabled
	$pdw.btns1.cup config -state disabled
	$pdw.btns1.cdn config -state disabled
	set pdc(curval) ""
}

#---- Change value in 'curve' box

proc Curvup {up} {
	global pdc evv
	if {$up > 0} {
		set curv [expr $pdc(curval) + 1]
		if {$curv >= $evv(MAXCURVE)} {
			set pdc(curval) $evv(MAXCURVE)
			return
		} else {
			set curvi [expr int(round($curv))]
		}
	} else {
		set curv [expr $pdc(curval) - 1]
		if {$curv < 1.0} {
			set pdc(curval) 1
			return
		} else {
			set curvi [expr int(round($curv))]
		}
	}
	if [string match $curvi $curv] {
		set pdc(curval) $curvi
	} else { 
		set pdc(curval) $curv
	}
}

#---- Change value in Transpose box

proc Transup {up} {
	global pdc evv

	if {$up == 0} {
		set pdc(transpose) 0
		return
	}		
	set t [expr $pdc(transpose) + $up]
	if {$t >= $evv(MAXTRANSP)} {
		set pdc(transpose) $evv(MAXTRANSP)
		return
	} elseif {$t <= $evv(MINTRANSP)} {
		set pdc(transpose) $evv(MINTRANSP)
		return
	} else {
		set ti [expr int(round($t))]
	}
	if [string match $ti $t] {
		set pdc(transpose) $ti
	} else { 
		set pdc(transpose) $t
	}
}

#---- Draw a pitch grid

proc Draw_A_Grid {} {
	global pdc
	
	set i 0
	catch {$pdc(can) delete grid}
	catch {$pdc(can) delete gridno}
	if {$pdc(zoomed)} {
		DrawZoomGrid
	} else {
		DrawGrid
	}
}

#---- Establish parameters for normal pitchgrid

proc SetGridParams {} {
	global pdc mu

 	set pdc(submargin) 4
	set pdc(gridoffset) [expr $pdc(effective_height) + $pdc(ymargin)]
	set pdc(gridedge) [expr $pdc(effective_width) + $pdc(xmargin)]
	set thisline 12
	set i 0
	set j -4
	while {$thisline < $mu(MIDIMAX)} {
		set pdc(grid,$i) [expr $pdc(gridoffset) - ($thisline * $pdc(scaler))]
		set pdc(gridno,$i) C$j
		set pdc(gridfq,$i) [GetGridFrq $pdc(gridno,$i)]
		incr i
		incr j
		incr thisline 12
	}
	set pdc(gridcnt) $i
}	

#---- Establish parameters for zoomed pitchgrid

proc SetZoomGridParams {} {
	global pdc mu

	set thisline 12
	set i 0
	set j -4
	set pdc(zgridmax) -1
	while {$thisline < $mu(MIDIMAX)} {
		if {$thisline  > $pdc(maxmidi)} {
			break
		}
		if {$thisline  > $pdc(minmidi)} {
			if {$pdc(zgridmax) < 0} {
				set pdc(zgridmin) $i
			}
			set pdc(zgridmax) $i
			set y [expr ($thisline - $pdc(minmidi)) * $pdc(zoomratio) * $pdc(scaler)]
			set pdc(zgrid,$i) [expr $pdc(effective_height) - $y + $pdc(ymargin)]
		}
		incr i
		incr j
		incr thisline 12
	}
}

#---- Draw a normal pitchgrid

proc DrawGrid {} {
	global pdc evv
	set i 0
	while {$i < $pdc(gridcnt)} {
		$pdc(can) create text $pdc(submargin) [expr $pdc(grid,$i) - 4] -text $pdc(gridno,$i) -fill $evv(PGRID) -anchor w -tag gridno
		$pdc(can) create text [expr $pdc(gridedge) + 4] [expr $pdc(grid,$i) - 4] -text $pdc(gridfq,$i) -fill $evv(PGRID) -anchor w -tag gridno
		set coords [list $pdc(xmargin) $pdc(grid,$i) $pdc(gridedge) $pdc(grid,$i)]
		eval {$pdc(can) create line} $coords {-fill $evv(PGRID)} {-tag grid}
		incr i
	}				
	catch {$pdc(can) delete timeline}
	DrawPTimeline
}

#---- Draw a zoomed pitchgrid

proc DrawZoomGrid {} {
	global pdc evv
	
	if {$pdc(zgridmax) < 0} {
		return
	}
	set i $pdc(zgridmin)
	while {$i <= $pdc(zgridmax)} {
		$pdc(can) create text $pdc(submargin) [expr $pdc(zgrid,$i) - 4] -text $pdc(gridno,$i) -fill $evv(PGRID) -anchor w -tag gridno
		$pdc(can) create text [expr $pdc(gridedge) + 4] [expr $pdc(zgrid,$i) - 4] -text $pdc(gridfq,$i) -fill $evv(PGRID) -anchor w -tag gridno
		set coords [list $pdc(xmargin) $pdc(zgrid,$i) $pdc(gridedge) $pdc(zgrid,$i)]
		eval {$pdc(can) create line} $coords {-fill $evv(PGRID)} {-tag grid}
		incr i
	}				
	catch {$pdc(can) delete timeline}
	DrawPTimeline
}

#----- Reposition point on zoomed display

proc ZoomPoint {} {
	global evv pdc

	set y [expr $pdc(effective_height) - $pdc(iy_coord) + $pdc(ymargin)]
	set y [expr ($y - $pdc(miny)) * $pdc(zoomratio)]
	set y [expr $pdc(effective_height) - $y  + $pdc(ymargin)]
	if {($y < $pdc(hilim_with_grace)) || ($y > $pdc(lowlim_with_grace))} {
		catch {$pdc(can) delete ipoint}
		return
	}
	set pdc(iyz_coord) $y
	set pdc(iyza_coord) [expr $y + $evv(PWIDTH)]
	catch {$pdc(can) delete ipoint}
	set pdc(i_coords) [list $pdc(ix_coord) $pdc(iyz_coord) $pdc(ixa_coord) $pdc(iyza_coord)]
	set pdc(ipoint) [eval {$pdc(can) create rect} $pdc(i_coords) { -fill $evv(POINT) -tag ipoint}]
}

#----- Reposition point on unzoomed display

proc UnZoomPoint {} {
	global evv pdc
	catch {$pdc(can) delete ipoint}
	set ya [expr $pdc(iy_coord) + $evv(PWIDTH)]
	set pdc(i_coords) [list $pdc(ix_coord) $pdc(iy_coord) $pdc(ixa_coord) $ya]
	set pdc(ipoint) [eval {$pdc(can) create rect} $pdc(i_coords) { -fill $evv(POINT) -tag ipoint}]
}

#--- Play the currently saved pitch data

proc PdPlay {fnam} {
	global pdc pr_pdisplay wl last_outfile CDPidrun pa done_pdisplayput evv

	if {[file exists $pdc(sndtemp)] && ($pdc(datano) == $pdc(saveno))} {
		PlaySndfile $pdc(sndtemp) 0
		return
	}
	set cmd [file join $evv(CDPROGRAM_DIR) pmodify]

	if [ProgMissing $cmd "Program to write new pitch data is missing"] {
		return
	}
	if [file exists $pdc(pichtemp)] {
		if [catch {file delete $pdc(pichtemp)} zub] {
			Inf "Cannot delete temporary data file $pdc(pichtemp): Cannot play"	
			return
		}
	}	
	if [file exists $pdc(analtemp)] {
		if [catch {file delete $pdc(analtemp)} zub] {
			Inf "Cannot delete temporary data file $pdc(pichtemp): Cannot play"	
			return
		}
	}	
	if [file exists $pdc(sndtemp)] {
		if [catch {file delete $pdc(sndtemp)} zub] {
			Inf "Cannot delete temporary data file $pdc(sndtemp): Cannot play"	
			return
		}
	}	
	if [catch {open $pdc(texttemp) w} fId] {
		Inf "Cannot open temporary file $pdc(texttemp) to write new pitch data."
		return
	}
	Block "Preparing pitchfile to play"
	foreach item $pdc(data) {
		puts $fId $item
	}
	catch {close $fId}
	set done_pdisplayput 0

	lappend cmd $pdc(texttemp) $pdc(pichtemp)
	lappend cmd $pa($fnam,$evv(ORIGCHANS)) $pa($fnam,$evv(ORIGSTYPE)) $pa($fnam,$evv(ORIGRATE))
	lappend cmd $pa($fnam,$evv(ARATE)) $pa($fnam,$evv(MLEN)) $pa($fnam,$evv(DFAC)) 
	lappend cmd $pa($fnam,$evv(SRATE)) $pa($fnam,$evv(CHANS))

	if [catch {open "|$cmd"} CDPidrun] {
		ErrShow "$CDPidrun"
		ErrShow "Cannot run process to write new pitch data"
		UnBlock
		return
	} else {
   		fileevent $CDPidrun readable "PDisplayPut"
	}
	vwait done_pdisplayput
	if {!$done_pdisplayput} {
		UnBlock
		return
	}
	incr pdc(saveno)

	#	SO FAR WE'VE SAVED THE PITCH DATA TO A TEMPORARY FILE

	set done_pdisplayput 0
	set cmd [file join $evv(CDPROGRAM_DIR) paudition]

	if [ProgMissing $cmd "Program to write new pitch data is missing"] {
		UnBlock
		return
	}
	lappend cmd $pdc(pichtemp) $pdc(analtemp) $pdc(sndtemp)
	lappend cmd $pa($fnam,$evv(ORIGCHANS)) $pa($fnam,$evv(ORIGSTYPE)) $pa($fnam,$evv(ORIGRATE))
	lappend cmd $pa($fnam,$evv(ARATE)) $pa($fnam,$evv(MLEN)) $pa($fnam,$evv(DFAC)) 
	lappend cmd $pa($fnam,$evv(SRATE)) $pa($fnam,$evv(CHANS))

	if [catch {open "|$cmd"} CDPidrun] {
		ErrShow "$CDPidrun"
		ErrShow "Cannot run process to write and play new pitch data"
		UnBlock
		return
	} else {
   		fileevent $CDPidrun readable "PDisplayPut"
	}
	vwait done_pdisplayput
	if {!$done_pdisplayput} {
		UnBlock
		return
	}
	PlaySndfile	$pdc(sndtemp) 0
	UnBlock
	return
}

proc flteq {a b} {
	global evv

	set upbnd [expr $a + $evv(FLTERR)]
	set lobnd [expr $a - $evv(FLTERR)]
	if {($b > $lobnd) && ($b < $upbnd)} {
		return 1
	}
	return 0
}

proc LineWhere {w x} {
	global pwinpos ptimpos psmppos pdisval pdismid pdc pdw pa evv

	set x_valid 1
	set y_valid 1
	if {![info exists pdc(lcoords)]} {
		return
	}
	if {$x < $pdc(xmargin) || $x > $pdc(effective_width)} {
		set pwinpos ""
		ForceVal $pdw.btns0.dum1 $pwinpos
		set ptimpos ""
		ForceVal $pdw.btns0.dum2 $ptimpos
		set psmppos ""
		ForceVal $pdw.btns0.dum3 $psmppos
		set pdisval ""
		ForceVal $pdw.btns0.dum4 $pdisval
		set pdismid ""
		ForceVal $pdw.btns0.dum5 $pdismid
		return
	}
	if {$x_valid} {
		incr x $pdc(-xmargin)
		set thiswindow [expr $x  + ($pdc(thisblok) * $pdc(bloksize))]
		if {$pdc(stretched)} {
			set thiswindow [expr int(round(double($thiswindow) /$pdc(lenscale)))]
		}
		if {$thiswindow > $pdc(dataend)} {
			set thiswindow $pdc(dataend)
		}
		set pwinpos $thiswindow
		ForceVal $pdw.btns0.dum1 $pwinpos
		set ptimpos [expr $thiswindow / $pa($pdc(fnam),$evv(ARATE))]
		ForceVal $pdw.btns0.dum2 $ptimpos
		set psmppos [expr int(round($ptimpos * $pa($pdc(fnam),$evv(ORIGRATE))))]
		ForceVal $pdw.btns0.dum3 $psmppos

		incr x $x	;# Find index of coordinate pair
		incr x		;# Find y-coord
		set y [lindex $pdc(lcoords) $x]

		set y [expr ($pdc(effective_height) - $y + $pdc(ymargin)) / $pdc(scaler)]
		if {$pdc(zoomed)} {
			set y [expr ($y / $pdc(zoomratio)) + $pdc(minmidi)]	
		}
		set y [MyPrecision $y 2]
		set pdisval $y
		ForceVal $pdw.btns0.dum4 $pdisval
		if {$y > 0} {
			set y [expr fmod($y,12.0)]
			set y [expr int(round($y))]
			switch -- $y {
				0	{set pdismid "C"}	
				1	{set pdismid "C#|Db"}
				2	{set pdismid "D"}
				3	{set pdismid "D#|Eb"}
				4	{set pdismid "E"}
				5	{set pdismid "F"}
				6	{set pdismid "F#|Gb"}
				7	{set pdismid "G"}
				8	{set pdismid "G#|Ab"}
				9	{set pdismid "A"}
				10	{set pdismid "A#|Bb"}
				11	{set pdismid "B"}
			}
		} else {
			set pdismid ""
		}
		ForceVal $pdw.btns0.dum5 $pdismid
	}		
}			
			
proc MyPrecision {val precision} {

	set mult [expr pow(10,$precision)]
	set div	 [expr pow(10,-$precision)]
	set val [expr round($val * $mult)]
	set val [expr $val * $div]
	set j [string length $val]
	set k [string first "." $val]
	if {$k >= 0} {
		incr k $precision
		if {$k < $j} {
			set val [string range $val 0 $k]
		}
	}
	return $val
}

proc CreateNewSilence {silence lenscale} {
	global pdc
	set len [llength $silence]
	set inhole 0
	set n $pdc(xmargin)
	set lastpos $n
	foreach hole $silence {
		set m [expr $n - $pdc(xmargin)]
		set m [expr int(round(double($m) * $lenscale))]
		incr m $pdc(xmargin)
		if {$m > $lastpos} {
			set k $lastpos
			if {$hole} {
				if {$inhole} {
					while {$k <= $m} {
						lappend nusilence $hole
						incr k
					}
				} else {
					while {$k < $m} {
						lappend nusilence 0
						incr k
					}
					lappend nusilence $hole
				}
				set inhole 1
			} else {
				if {$inhole} {
					while {$k < $m} {
						lappend nusilence $lastval
						incr k
					}
					lappend nusilence 0
				} else {
					while {$k < $m} {
						lappend nusilence 0
						incr k
					}
				}
				set inhole 0
			}
			set lastval $hole
			set lastpos $m
		}
		incr n
	}
	return $nusilence
}

proc DrawSilence {} {
	global silence pdc
	set n $pdc(xmargin)
	foreach hole $silence {
		if {$hole} {
			if {$hole > 1} {
				eval {$pdc(can) create line $n $pdc(ymargin) $n $pdc(lowlim)} {-fill grey} {-tag silence}
			} else {
				eval {$pdc(can) create line $n $pdc(ymargin) $n $pdc(lowlim)} {-fill red} {-tag silence}
			}
		}
		incr n
	}
}

proc DrawPTimeline {} {
	global pdc evv pa 
	set arate $pa($pdc(fnam),$evv(ARATE))
	set val [expr $pdc(gridoffset) - 4]
	set vallo [expr $pdc(gridoffset) + 2]
	set valhi [expr $val - 12]
	set figoff 6
	$pdc(can) create text $pdc(submargin) [expr $val - 6] -text TIME -fill $evv(PGRID) -anchor w -tag timeline
	set coords [list $pdc(xmargin) $val $pdc(gridedge) $val]
	eval {$pdc(can) create line} $coords {-fill $evv(PGRID)} {-tag grid}
	set x $pdc(xmargin)

	set startwin [expr $pdc(thisblok) * $pdc(bloksize)]
	set endwin [expr int($startwin + $pdc(effective_width))]
	incr endwin -1
	if {$endwin > $pdc(dataend)} {
		set endwin $pdc(dataend)
	}
	set winstep [expr $arate/10.0]
	set winpos 0
	while {$winpos < $startwin} {
		set winpos [expr $winpos + $winstep]
	}
	set z [expr $winpos / $arate] 
	set k [string first "." $z]
	incr k
	set z [string range $z 0 $k]
	while {$winpos <= $endwin} {
		set x [expr $winpos - $startwin + $pdc(xmargin)]
		set thiswindow [expr $x + $pdc(-xmargin) + ($pdc(thisblok) * $pdc(bloksize))]
		set ptimpos [expr $thiswindow / $arate]
		if {$pdc(stretched)} {
			set x [expr (($x  - $pdc(xmargin)) * $pdc(lenscale)) + $pdc(xmargin)]
		}
		$pdc(can) create text [expr $x - $figoff] $vallo -text $z -fill $evv(PGRID) -anchor w -tag timeline
		$pdc(can) create line $x $val $x $valhi -fill $evv(PGRID) -tag timeline
		set z [expr $z + 0.1]
		set k [string first "." $z]
		incr k
		set z [string range $z 0 $k]
		set winpos [expr $winpos + $winstep]
	}
}

proc GetGridFrq {note} {
	set val [string range $note 1 end]
	set val [expr pow(2.0,$val)]
	set middle_C 261.625565
	set val [expr $middle_C * $val]
	set k [string first "." $val]
	set j [expr $k - 3]
	if {$j > 0} {
		incr k -$j
	}
	incr k 3
	set lastdig [string index $val $k] 
	incr k
	if {[string index $val $k] >= 5} {
		incr lastdig
	}
	incr k -2
	set nuval [string range $val 0 $k]
	append nuval $lastdig " " Hz
	return $nuval
}

#################################
# CHORDS FROM NON-VOCAL SAMPLES #
#################################

proc TransposChord {} {
	global pr_trchd evv wl pa chlist wstk prg_dun prg_abortd simple_program_messages CDPidrun trchd
	global set done_maxsamp maxsamp_line CDPmaxId

	if {![info exists chlist] || ([llength $chlist] != 1)} {
		set i [$wl curselection]
		if {([llength $i] > 1) || ($i < 0)} {
			Inf "Select a single mono soundfile"
			return
		} else {
			set fnam [$wl get $i]
		}
	} else {
		set fnam [lindex $chlist 0]
	}
	if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) != 1)} {
		Inf "Select a single mono soundfile"
		return
	}
	set infnam $fnam
	set indur $pa($infnam,$evv(DUR))
	if {$indur < 0.15} {
		Inf "Sample too short : must be longer than 0.15 secs (150ms)"
		continue
	}
	set afnam $evv(DFLT_OUTNAME)
	append afnam 0 $evv(ANALFILE_EXT)
	set afnam2 $evv(DFLT_OUTNAME)
	append afnam2 1 $evv(ANALFILE_EXT)
	set mfnam $evv(DFLT_OUTNAME)
	append mfnam 0 [GetTextfileExtension mix]
	set sfnam $evv(DFLT_OUTNAME)
	append sfnam 0 $evv(TEXT_EXT)

	set f .trchd
	if [Dlg_Create $f "CREATE CHORD" "set pr_trchd 0" -borderwidth 2 -width 120] {
		frame $f.0
		button $f.0.cc -text "Create" -command "set pr_trchd 1"
		button $f.0.hh -text "Help" -command TransposChordHelp -bg $evv(HELP)
		button $f.0.qq -text "Quit"   -command "set pr_trchd 0"
		frame $f.0.midi
		button $f.0.save -text "Save Chord" -command "SaveTrchd"
		button $f.0.clear -text "Clear MIDI" -command "ClearTrchd"
		frame $f.1
		label $f.1.sp -text "Sample pitch" -width 15 -anchor w
		entry $f.1.pp -textvariable trchd(pitch) -width 12
		pack $f.1.sp $f.1.pp -side left -padx 2
		frame $f.2
		label $f.2.cd -text "Output Duration" -width 15 -anchor w
		entry $f.2.dd -textvariable trchd(dur) -width 12
		pack $f.2.cd $f.2.dd -side left -padx 2
		frame $f.2a
		label $f.2a.cd -text "Outfile Name" -width 15 -anchor w
		entry $f.2a.dd -textvariable trchd(ofnam) -width 48
		pack $f.2a.cd $f.2a.dd -side left -padx 2
		frame $f.3
		frame $f.3.1
		label $f.3.1.tit -text "Possible midi data files" -fg $evv(SPECIAL)
		set trchd(list) [Scrolled_Listbox $f.3.1.ll -width 80 -height 24 -selectmode single]
		pack $f.3.1.tit $f.3.1.ll -side top -fill both -expand true -pady 2

		frame $f.3.2
		label $f.3.2.tit -text "Chord midi list" -fg $evv(SPECIAL)
		set trchd(vals) [text $f.3.2.t -setgrid true -wrap word -width 16 -height 24 -xscrollcommand "$f.3.2.sx set" -yscrollcommand "$f.3.2.sy set"]
		scrollbar $f.3.2.sy -orient vert  -command "$f.3.2.t yview"
		scrollbar $f.3.2.sx -orient horiz -command "$f.3.2.t xview"
		pack $f.3.2.tit $f.3.2.t -side top -fill both -expand true

		MakeKeyboardKey $f.0.midi $evv(MIDIPITCHES) $trchd(vals)
		pack $f.0.cc $f.0.hh -padx 2 -side left
		pack $f.0.midi $f.0.save $f.0.clear -padx 16 -side left
		pack $f.0.qq -side right
		pack $f.0 -side top -fill x -expand true
		pack $f.1 -side top -fill x -expand true
		pack $f.2 -side top -fill x -expand true
		pack $f.2a -side top -fill x -expand true

		pack $f.3.1 $f.3.2 -side left -padx 2
		pack $f.3 -side top -fill x -expand true

		wm resizable $f 0 0
		bind $trchd(list) <ButtonRelease-1> {TrchdGetMidivals %y}
		bind $f.1.pp <Down> {focus .trchd.2.dd}
		bind $f.2.dd <Down> {focus .trchd.2a.dd}
		bind $f.2a.dd <Down> {focus .trchd.1.pp}
		bind $f.1.pp <Up> {focus .trchd.2a.dd}
		bind $f.2.dd <Up> {focus .trchd.1.pp}
		bind $f.2a.dd <Up> {focus .trchd.2.dd}
		bind $f <Return> {TrchdGo}
		bind $f <Escape> {set pr_trchd 0}
	}
	$trchd(vals) delete 1.0 end
	if {[info exists trchd(midi)]} {
		foreach val $trchd(midi) {
			$trchd(vals) insert end "$val\n"
		}
	}
	$trchd(list) delete 0 end
	set trch(listing) {}
	foreach fnam [$wl get 0 end] {
		if {[IsAListofNumbers $pa($fnam,$evv(FTYP))] && ($pa($fnam,$evv(MAXNUM)) <= 127) && ($pa($fnam,$evv(MINNUM)) >= 0)} {
			$trchd(list) insert end $fnam
		}
	}
	set finished 0
	set pr_trchd 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_trchd $f.1.pp
	set trchd(stretch) 0
	while {!$finished} {
		tkwait variable pr_trchd
		DeleteAllTemporaryFiles
		if {$pr_trchd} {
			if {([string length $trchd(pitch)] <= 0) || ![IsNumeric $trchd(pitch)] || ($trchd(pitch) < 0) || ($trchd(pitch) > 127)} {
				Inf "Invalid input sample midi-pitch (range 0 to 127)"
				continue
			}
			if {([string length $trchd(dur)] <= 0) || ![IsNumeric $trchd(dur)] || ($trchd(dur) < 0.1)} {
				Inf "Invalid chord duration value (must be > 100 ms = 0.1 secs)"
				continue
			}
			if {$trchd(stretch) == 0.0} {
				if {$indur < $trchd(dur)} {
					set msg "Output duration too long for input sample : stretch sample to size ???"
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
					if [string match "no" $choice] {
						continue
					} else {
						set trchd(stretch) [expr ($trchd(dur) + 0.02)/($indur - 0.12)]
					}
				}
			} 
			if {![ValidCDPRootname $trchd(ofnam)]} {
				continue
			}
			set ofnam [string tolower $trchd(ofnam)]
			append ofnam $evv(SNDFILE_EXT)
			if {[file exists $ofnam]} {
				Inf "File $ofnam already exists: please choose a different name"
				continue
			}
			set lines [$trchd(vals) get 1.0 end]
			set lines "[split $lines \n]"
			set OK 1
			set domidi {}
			foreach line $lines {
				set vals [split $line]				;#	split line into single-space separated items
				if {[string match [string index $line 0] ";"]} {
					continue
				}
				foreach item $vals {
					set item [string trim $item]
					if {[string length $item] > 0} {
						if {![IsNumeric $item] || ($item < 0) || ($item > 127)} {
							Inf "Invalid chord midi-pitch value ($item) found (range 0 to 127)"
							set OK 0
							break
						}
						lappend domidi $item
					}
				}
				if {!$OK} {
					continue
				}
			}
			if {[llength $domidi] <= 1} {
				Inf "Insufficient midi values found (must be at least 2)"
				continue
			}
			set trchd(midi) $domidi
			set trns {}
			foreach val $domidi {
				lappend trns [expr $val - $trchd(pitch)]
			}
			Block "PROCESSING THE SAMPLE"

			wm title .blocker "PLEASE WAIT:        EXTRACTING SPECTRUM OF SAMPLE"

			set cmd [file join $evv(CDPROGRAM_DIR) pvoc]
			lappend cmd anal 1 $infnam $afnam -c1024 -o3
			set prg_dun 0
			set prg_abortd 0
			catch {unset simple_program_messages}
			if [catch {open "|$cmd"} CDPidrun] {
				ErrShow "Cannot create analysis file: $CDPidrun"
				catch {unset CDPidrun}
				UnBlock
				continue
			} else {
				fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
			}
			vwait prg_dun
			if {$prg_abortd} {
				set prg_dun 0
			}
			if {!$prg_dun} {
				set msg "Failed to create analysis file"
				set msg [AddSimpleMessages $msg]
				ErrShow $msg
				UnBlock
				continue
			}
			if {![file exists $afnam]} {
				Inf "No output from analysis of sample"
				UnBlock
				continue
			}
			if {$trchd(stretch) > 1.0} {
				wm title .blocker "PLEASE WAIT:        TIME-STRETCHING THE SAMPLE"
				set vals [list 0.0 1.0]
				lappend vals 0.1 1
				lappend vals 0.12 $trchd(stretch)
				lappend vals 10000 $trchd(stretch)
				if [catch {open $sfnam "w"} zit] {
					Inf "Cannot open temporary file to write time-stretching data"
					UnBlock
					continue
				}
				foreach val $vals {
					puts $zit $val
				}
				close $zit
				set cmd [file join $evv(CDPROGRAM_DIR) stretch]
				lappend cmd time 1 $afnam $afnam2 $sfnam
				set prg_dun 0
				set prg_abortd 0
				catch {unset simple_program_messages}
				if [catch {open "|$cmd"} CDPidrun] {
					ErrShow "Cannot create time=stretched input file: $CDPidrun"
					catch {unset CDPidrun}
					UnBlock
					continue
				} else {
					fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				if {!$prg_dun} {
					set msg "Failed to create time-stretched input file"
					set msg [AddSimpleMessages $msg]
					ErrShow $msg
					UnBlock
					continue
				}
				if {![file exists $afnam2]} {
					Inf "No output from time-stretch process"
					UnBlock
					continue
				}
				set aafnam $afnam2
			} else {
				set aafnam $afnam
			}
			set cnt 0
			catch {unset ofnams}
			foreach trn $trns {
				wm title .blocker "PLEASE WAIT:        TRANSPOSING SAMPLE TO [lindex $domidi $cnt]"
				set afnamout $evv(MACH_OUTFNAME)
				append afnamout $cnt $evv(ANALFILE_EXT)
				set fnamout $evv(MACH_OUTFNAME)
				append fnamout $cnt $evv(SNDFILE_EXT)
				set cmd [file join $evv(CDPROGRAM_DIR) repitch]
				lappend cmd transpose 3 $aafnam $afnamout $trn
				set prg_dun 0
				set prg_abortd 0
				catch {unset simple_program_messages}
				if [catch {open "|$cmd"} CDPidrun] {
					ErrShow "Cannot transpose sample to [lindex $domidi $cnt]: $CDPidrun"
					catch {unset CDPidrun}
					set OK 0
					break
				} else {
					fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				if {!$prg_dun} {
					set msg "Failed to transpose sample to [lindex $domidi $cnt]"
					set msg [AddSimpleMessages $msg]
					ErrShow $msg
					set OK 0
					break
				}
				if {![file exists $afnamout]} {
					Inf "No output for transposition to [lindex $domidi $cnt]"
					set OK 0
					break
				}
				wm title .blocker "PLEASE WAIT:        GETTING WAVEFORM OF SAMPLE TRANSPOSED TO [lindex $domidi $cnt]"
				set cmd [file join $evv(CDPROGRAM_DIR) pvoc]
				lappend cmd synth $afnamout $fnamout
				set prg_dun 0
				set prg_abortd 0
				catch {unset simple_program_messages}
				if [catch {open "|$cmd"} CDPidrun] {
					ErrShow "Cannot convert sample transposed to [lindex $domidi $cnt], to wavfile: $CDPidrun"
					catch {unset CDPidrun}
					set OK 0
					break
				} else {
					fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				if {!$prg_dun} {
					set msg "Failed to convert sample transposed to [lindex $domidi $cnt], to wavfile"
					set msg [AddSimpleMessages $msg]
					ErrShow $msg
					set OK 0
					break
				}
				if {![file exists $fnamout]} {
					Inf "No output wavfile for transposition to [lindex $domidi $cnt]"
					set OK 0
					break
				}
				lappend ofnams $fnamout
				incr cnt
			}
			if {!$OK} {
				UnBlock
				continue
			}
			wm title .blocker "PLEASE WAIT:        CREATING MIXFILE FOR CHORD"
			set cmd [file join $evv(CDPROGRAM_DIR) submix]
			lappend cmd dummy 1 
			foreach oofnam $ofnams {
				lappend cmd $oofnam
			}
			lappend cmd $mfnam
			set prg_dun 0
			set prg_abortd 0
			catch {unset simple_program_messages}
			if [catch {open "|$cmd"} CDPidrun] {
				ErrShow "Cannot create mixfile for transposed samples: $CDPidrun"
				catch {unset CDPidrun}
				UnBlock
				continue
			} else {
				fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
			}
			vwait prg_dun
			if {$prg_abortd} {
				set prg_dun 0
			}
			if {!$prg_dun} {
				set msg "Failed to create mixfile for transposed samples"
				set msg [AddSimpleMessages $msg]
				ErrShow $msg
				UnBlock
				continue
			}
			if {![file exists $mfnam]} {
				Inf "Mixfile for transposed samples was not created"
				UnBlock
				continue
			}
			set gain 1.0
			set passcnt 1
			set cmd [file join $evv(CDPROGRAM_DIR) submix]
			lappend cmd mix $mfnam $ofnam
			set origcmd $cmd
			set gainOK 0
			while {!$gainOK} {
				if {$passcnt > 1} {
					wm title .blocker "PLEASE WAIT:        REMIXING THE CHORD FOR BETTER LEVEL: PASS $passcnt"
				} else {
					wm title .blocker "PLEASE WAIT:        MIXING THE CHORD : PASS $passcnt"
				}
				catch {file delete $ofnam}
				set prg_dun 0
				set prg_abortd 0
				catch {unset simple_program_messages}
				if [catch {open "|$cmd"} CDPidrun] {
					ErrShow "Cannot mix transposed samples (pass $passcnt): $CDPidrun"
					catch {unset CDPidrun}
					set OK 0
					break
				} else {
					fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				if {!$prg_dun} {
					set msg "Failed to mix transposed samples (pass $passcnt)"
					set msg [AddSimpleMessages $msg]
					ErrShow $msg
					set OK 0
					break
				}
				if {![file exists $ofnam]} {
					Inf "Mixing transposed samples produced no output (pass $passcnt)"
					set OK 0
					break
				}
				wm title .blocker "PLEASE WAIT:        CHECKING LEVEL OF OUTPUT"
				set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
				lappend cmd $ofnam
				set prg_dun 0
				set prg_abortd 0
				set done_maxsamp 0
				catch {unset maxsamp_line}
				if [catch {open "|$cmd"} CDPmaxId] {
					catch {unset CDPmaxId}
					Inf "Failed to find (and adjust) maximum level of output : $CDPmaxId"
					set OK 0
					break
				} else {
					fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
				}
				vwait done_maxsamp
				if {!$done_maxsamp || ![info exists maxsamp_line]} {
					set msg "Failure to find (and adjust) maximum level of output"
					ErrShow $msg
					set OK 0
					break
				}
				catch {close CDPmaxId}
				set maxlev [lindex $maxsamp_line 0]
				if {$maxlev <= 0.0} {
					set msg "Output has level zero"
					ErrShow $msg
					set OK 0
					break
				}
				if {$maxlev > .98} {	;#	GAIN CLOSE TO 1.0 INDICATES OUTPUT HAS OVERLOADAD
					set gain 0.1
					set cmd $origcmd
					lappend cmd -g$gain
 				} elseif {$maxlev <= 0.9} {	
					set gain [expr (0.95/$maxlev) * $gain]
					set cmd $origcmd
					lappend cmd -g$gain
				} else {
					set gainOK 1
				}
				incr passcnt
			}
			if {!$OK} {
				UnBlock
				continue
			}
			FileToWkspace $ofnam 0 0 0 0 1
			Inf "File $ofnam is on the workspace"
			DeleteAllTemporaryFiles
			UnBlock
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc TrchdGetMidivals {y} {
	global trchd
	set i [$trchd(list) nearest $y]
	if {$i < 0} {
		return 
	}
	set fnam [$trchd(list) get $i]
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot open file $fnam"
		return
	}
	catch {unset midivals}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {![IsNumeric $item] || ($item > 127) || ($item < 0)} {
				Inf "Invalid midi value ($item) in file $fnam"
				close $zit
				return
			}
			lappend midivals $item
		}
	}
	close $zit
	if {![info exists midivals]} {
		Inf "No midi vals found in file $fnam"
		return
	}
	set trchd(midi) $midivals
	$trchd(vals) delete 1.0 end
	foreach val $trchd(midi) {
		$trchd(vals) insert end "$val\n"
	}
}

proc TransposChordHelp {} {

	set msg "CHORDS FROM NON-VOCAL SAMPLE\n"
	append msg "\n"
	append msg "Input should be a (non-vocal) sample.\n"
	append msg "\n"
	append msg "You must ...\n"
	append msg "(1)  specify (as a MIDI value) the pitch of the sample.\n"
	append msg "\n"
	append msg "(2) Specify a chord as a set of MIDI values in a textfile.\n"
	append msg "\n"
	append msg "(3) Specify the duration of the output.\n"
	append msg "\n"
	Inf $msg
}

proc TrchdGo {} {
	global pr_trchd
	if {![string match [focus] .trchd.3.2.t]} {
		set pr_trchd 1
	}
}

proc SaveTrchd {} {
	global trchd evv
	set lines [$trchd(vals) get 1.0 end]
	set lines "[split $lines \n]"
	set OK 1
	set domidi {}
	foreach line $lines {
		set vals [split $line]				;#	split line into single-space separated items
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		foreach item $vals {
			set item [string trim $item]
			if {[string length $item] > 0} {
				if {![IsNumeric $item] || ($item < 0) || ($item > 127)} {
					Inf "Invalid chord midi-pitch value ($item) found (range 0 to 127)"
					set OK 0
					break
				}
				lappend domidi $item
			}
		}
		if {!$OK} {
			continue
		}
	}
	if {![info exists domidi]} {
		Inf "No midi data to save"
		return
	}
	set trchd(midi) $domidi

	if {![ValidCDPRootname $trchd(ofnam)]} {
		Inf "No valid data file name"
		return
	}
	set dfnam [string tolower $trchd(ofnam)]
	set ofnam $dfnam
	append dfnam $evv(TEXT_EXT)
	append ofnam $evv(SNDFILE_EXT)
	if {[file exists $ofnam] || [file exists $dfnam]} {
		Inf "Files with this name already exist: please choose a different name"
		return
	}
	if [catch {open $dfnam "w"} zit] {
		Inf "Cannot open file $dfnam"
		return
	}
	foreach val $trchd(midi) {	
		puts $zit $val
	}
	close $zit
	if {[FileToWkspace $dfnam 0 0 0 0 1] > 0} {
		$trchd(list) insert end $dfnam
	}
}

proc ClearTrchd {} {
	global trchd
	$trchd(vals) delete 1.0 end
}
