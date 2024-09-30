#
# SOUND LOOM RELEASE mac version 17.0.4
#
# RWD 30 June 2013
# ... fixup button rectangles

proc DisplayResonanceWk {isfrq compare} {
	global wl evv pa
	set ilist [$wl curselection]
	if {$compare} {
		if {[llength $ilist] != 2} {
			Inf "Select Two Filter Data Files"
			return
		}
		set fnam [$wl get [lindex $ilist 0]]
		if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
			Inf "Select Filter Data Files"
			return
		}
		set fnam2 [$wl get [lindex $ilist 1]]
		if {!($pa($fnam2,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
			Inf "Select Filter Data Files"
			return
		}
		DisplayResonance $fnam $isfrq $fnam2
	} else {
		if {[llength $ilist] != 1} {
			Inf "Select A Single Filter Data File"
			return
		}
		set fnam [$wl get $ilist]
		if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
			Inf "Select A Single Filter Data File"
				return
		}
		DisplayResonance $fnam $isfrq 0
	}
}

proc DisplayResonance {fnam isfrq fnam2} {
	global pr_res small_screen resdisp res_screen resext last_resext respk last_respk orig_res res_peakcnt 
	global pr_res_chosen res_savefile wstk res_midilist no_respk rescnt_offset res evv
	global res_startpos res_step

	set secondfile 0
	if {![string match $fnam2 "0"]} {
		set secondfile 1
	}
	set pr_res_chosen 0
	catch {unset no_respk}
	catch {unset rescnt_offset}
	set evv(RES_WIDTH)	1000
	set evv(RES_HEIGHT) 360
	if {![file exists $fnam] || [file isdirectory $fnam]} {
		Inf "Bad File Name"
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File $fnam"
		return
	}
	set cnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		catch {unset nuline}
		set line [split $line]
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend nuline $item
			}
		}
		if {![info exists nuline]} {
			continue
		}
		switch -- $cnt {
			0 {
				set lcnt [llength $nuline]
				set firstline $nuline
			}
			default {
				if {$lcnt != [llength $nuline]} {
					Inf "$fnam Is Not A Valid Varibank-Filter File"
					close $zit
					return
				}
				foreach item1 [lrange $firstline 1 end] item2 [lrange $nuline 1 end] {
					if {![string match $item1 $item2]} {
						Inf "$fnam Is Not A Fixed Resonance Filter"
						close $zit
						return
					}
				}
			}
		}
		incr cnt
	}
	close $zit
	set firstline [lrange $firstline 1 end]
	set maxmidi 0.0
	set len [llength $firstline]
	set n 0
	while {$n < $len} {
		if [IsEven $n] {
			set midi [lindex $firstline $n]
			if {$isfrq} {
				set midi [HzToMidi $midi]		;# CONVERT TO MIDI QUANTISED TO QTONES
			}
			set midi [expr int(round($midi * 2.0))]	;#	QUANTISE TO QUARTER-TONES
			set midi [DecPlaces [expr $midi/2.0] 1]
			set firstline [lreplace $firstline $n $n $midi]
			if {$midi > $maxmidi} {
				set maxmidi $midi
			}
		}
		incr n
	}
	set maxmidi [expr int(round($maxmidi * 2.0))]
	set maxmidi [expr $maxmidi/2.0]

	set cnt 0
	set len [llength $firstline]
	while {$cnt < $len} {						;#	SQUEEZE OUT DUPLICATED QTONES
		set midi [lindex $firstline $cnt]
		set ampcnt [expr $cnt + 1]
		set amp [lindex $firstline $ampcnt]
		if {$cnt==0} {
			set lastmidi $midi
			set lastamp $amp
		} else {
			if {$midi == $lastmidi} {
				set amp [expr $amp + $lastamp]
				set firstline [lreplace $firstline $ampcnt $ampcnt $amp]
				set firstline [lreplace $firstline [expr $cnt - 2] [expr $cnt - 1]]
				incr cnt -2
				incr len -2
			}
			set lastmidi $midi
			set lastamp $amp
		}
		incr cnt 2
	}
	set len [llength $firstline]
	set cnt 1
	set maxamp 0.0
	while {$cnt < $len} {						;#	NORMALISE
		set amp [lindex $firstline $cnt]
		if {$amp > $maxamp} {
			set maxamp $amp
		}
		incr cnt 2
	}
	if {$maxamp <= 0.0} {
		Inf "No Significant Level In File $fnam"
		return
	}
	set orig_res $firstline
	set firstmidi [lindex $firstline 0]		;#	ENSURE SEQUENCE STARTS WITH A QTONE (NOT AT A SEMITONE)
	if {![IsNotAtSemitone $firstmidi]} {
		set midi [DecPlaces [expr $firstmidi - 0.5] 1]
		set amp 0.0
		set firstline [linsert $firstline 0 $midi $amp]
	}

	set cnt 1
	while {$cnt < $len} {
		set amp [lindex $firstline $cnt]
		set amp [expr $amp / $maxamp]
		set firstline [lreplace $firstline $cnt $cnt $amp]
		incr cnt 2
	}
	set cnt 0
	set len [llength $firstline]
	while {$cnt < $len} {						;#	INSERT MISSING QTONES
		set midi [lindex $firstline $cnt]
		if {$cnt == 0} {
			set midilo [expr int(round($midi * 2.0))]
			set midilo [expr $midilo / 2.0]				;# round to nearest qtone
			if {$midilo == [expr floor($midilo)]} {		;# if on a semitone
				set midilo [expr $midilo - 0.5]			;# force onto qtone below
			}
		} else {
			if {$midi != $nextmidi} {
				set midi $nextmidi
				set firstline [linsert $firstline $cnt 0.0]
				set firstline [linsert $firstline $cnt $midi]
				incr len 2
			}
		}
		set nextmidi [DecPlaces [expr $midi + .5] 1]
		incr cnt 2
	}

	if {$secondfile} {
		if [catch {open $fnam2 "r"} zit] {
			Inf "Cannot Open File '$fnam2'"
			return
		}
		set cnt 0
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			catch {unset nuline}
			set line [split $line]
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] > 0} {
					lappend nuline $item
				}
			}
			if {![info exists nuline]} {
				continue
			}
			switch -- $cnt {
				0 {
					set lcnt [llength $nuline]
					set secondline $nuline
				}
				default {
					if {$lcnt != [llength $nuline]} {
						Inf "'$fnam2' Is Not A Valid Varibank-Filter File"
						close $zit
						return
					}
					foreach item1 [lrange $secondline 1 end] item2 [lrange $nuline 1 end] {
						if {![string match $item1 $item2]} {
							Inf "'$fnam2' Is Not A Fixed Resonance Filter"
							close $zit
							return
						}
					}
				}
			}
			incr cnt
		}
		close $zit
		set secondline [lrange $secondline 1 end]
		set maxmidi 0.0
		set len [llength $secondline]
		set n 0
		while {$n < $len} {
			if [IsEven $n] {
				set midi [lindex $secondline $n]
				if {$isfrq} {
					set midi [HzToMidi $midi]		;# CONVERT TO MIDI QUANTISED TO QTONES
				}
				set midi [expr int(round($midi * 2.0))]	;#	QUANTISE TO QUARTER-TONES
				set midi [DecPlaces [expr $midi/2.0] 1]
				set secondline [lreplace $secondline $n $n $midi]
				if {$midi > $maxmidi} {
					set maxmidi $midi
				}
			}
			incr n
		}
		set maxmidi [expr int(round($maxmidi * 2.0))]
		set maxmidi [expr $maxmidi/2.0]

		set cnt 0
		set len [llength $secondline]
		while {$cnt < $len} {						;#	SQUEEZE OUT DUPLICATED QTONES
			set midi [lindex $secondline $cnt]
			set ampcnt [expr $cnt + 1]
			set amp [lindex $secondline $ampcnt]
			if {$cnt==0} {
				set lastmidi $midi
				set lastamp $amp
			} else {
				if {$midi == $lastmidi} {
					set amp [expr $amp + $lastamp]
					set secondline [lreplace $secondline $ampcnt $ampcnt $amp]
					set secondline [lreplace $secondline [expr $cnt - 2] [expr $cnt - 1]]
					incr cnt -2
					incr len -2
				}
				set lastmidi $midi
				set lastamp $amp
			}
			incr cnt 2
		}
		set len [llength $secondline]
		set cnt 1
		set maxamp 0.0
		while {$cnt < $len} {						;#	NORMALISE
			set amp [lindex $secondline $cnt]
			if {$amp > $maxamp} {
				set maxamp $amp
			}
			incr cnt 2
		}
		if {$maxamp <= 0.0} {
			Inf "No Significant Level In File '$fnam2'"
			return
		}
		set orig_res $secondline
		set firstmidi [lindex $secondline 0]		;#	ENSURE SEQUENCE STARTS WITH A QTONE (NOT AT A SEMITONE)
		if {![IsNotAtSemitone $firstmidi]} {
			set midi [DecPlaces [expr $firstmidi - 0.5] 1]
			set amp 0.0
			set secondline [linsert $secondline 0 $midi $amp]
		}

		set cnt 1
		while {$cnt < $len} {
			set amp [lindex $secondline $cnt]
			set amp [expr $amp / $maxamp]
			set secondline [lreplace $secondline $cnt $cnt $amp]
			incr cnt 2
		}
		set cnt 0
		set len [llength $secondline]
		while {$cnt < $len} {						;#	INSERT MISSING QTONES
			set midi [lindex $secondline $cnt]
			if {$cnt == 0} {
				set midilo [expr int(round($midi * 2.0))]
				set midilo [expr $midilo / 2.0]				;# round to nearest qtone
				if {$midilo == [expr floor($midilo)]} {		;# if on a semitone
					set midilo [expr $midilo - 0.5]			;# force onto qtone below
				}
			} else {
				if {$midi != $nextmidi} {
					set midi $nextmidi
					set secondline [linsert $secondline $cnt 0.0]
					set secondline [linsert $secondline $cnt $midi]
					incr len 2
				}
			}
			set nextmidi [DecPlaces [expr $midi + .5] 1]
			incr cnt 2
		}
	}

	catch {unset res_midilist}
	if [Dlg_Create .resscreen "Resonance" "set pr_res 0" -width 48 -borderwidth $evv(SBDR)] {

		if {$small_screen} {
			set can [Scrolled_Canvas .resscreen.c -width $evv(SMALL_WIDTH) -height $evv(SMALL_HEIGHT) \
								-scrollregion "0 0 512 285"]
			pack .resscreen.c -side top -fill x -expand true
			set f [frame $can.f -bd 0]
			$can create window 0 0 -anchor nw -window $f
			set resdisp $f
		} else {
			set resdisp .resscreen
		}	
		set b [frame $resdisp.btns -borderwidth 0]
		frame $resdisp.b1 -bg [option get . foreground {}] -height 1
		set d [frame $resdisp.d -borderwidth 0]
		frame $resdisp.d1 -bg [option get . foreground {}] -height 1
		set e [frame $resdisp.e -borderwidth 0]
		frame $resdisp.e1 -bg [option get . foreground {}] -height 1
		set e2 [frame $resdisp.e2 -borderwidth 0]

		#	DISPLAY TYPE
		button $b.abdn 	  -text "Close" -command "set pr_res 0" -highlightbackground [option get . background {}]
		radiobutton $b.midi -text "Midi" -variable resext -value 0 -command "set pr_res 1"
		radiobutton $b.freq -text "Freq" -variable resext -value 1 -command "set pr_res 1"
		label $b.s -text "semitones" -foreground $evv(SPECIAL) -font {helvetica 9 normal}
		label $b.q -text "quartertones" -foreground $evv(QUIT_COLOR) -font {helvetica 9 normal}
		label $b.z1 -text "File Two  " -foreground [option get . background {}]
		label $b.z2 -text "semitones" -foreground [option get . background {}] -font {helvetica 9 normal}
		label $b.z3 -text "quartertones" -foreground [option get . background {}] -font {helvetica 9 normal}
		pack $b.abdn -side right -padx 2
		pack $b.midi $b.freq $b.s $b.q $b.z1 $b.z2 $b.z3 -side left -padx 2

		label $d.disp -text "DISPLAY TEXT AS ...  "
		radiobutton $d.norm -text "Semitones" -variable respk -value 0 -command "set pr_res 2"
		radiobutton $d.whol  -text "Major 2nds" -variable respk -value 2 -command "set pr_res 2"
		radiobutton $d.m3    -text "Minor 3rds" -variable respk -value 3 -command "set pr_res 2"
		radiobutton $d.peak -text "Peaks Only" -variable respk -value 1 -command "set pr_res 2"

		pack $d.disp $d.norm $d.whol $d.m3 $d.peak -side left -padx 2

		#	DISPLAY EDIT
		label $e.ll -text "EDIT THE FILTER ....." 
		button $e.whol -text "Major 2nds"   -width 12 -command "set pr_res 7" -highlightbackground [option get . background {}]
		button $e.m3   -text "Minor 3rds"   -width 12 -command "set pr_res 8" -highlightbackground [option get . background {}]
		button $e.pks  -text "Peaks Only"   -width 12 -command "set pr_res 3" -highlightbackground [option get . background {}]
		button $e.npk  -text "N Peaks only"	-width 12 -command "set pr_res 4" -highlightbackground [option get . background {}]
		label $e.ll2 -text "N = "
		entry $e.nn -textvariable res_peakcnt -width 4
		label $e.ll3 -text "     "
		button $e.cpk -text "Specific Peaks"  -width 14 -command "set pr_res 5" -highlightbackground [option get . background {}]
		label $e.ll4 -text "       ENVELOPE"
		button $e.brk -text "Draw"  -width 6 -command "set pr_res 9" -highlightbackground [option get . background {}]
		button $e.env -text "Apply" -width 6 -command "set pr_res 10" -highlightbackground [option get . background {}]
		button $e.all -text "ORIGINAL VALUES"	-command "set pr_res 1" -highlightbackground [option get . background {}]
		pack $e.ll $e.whol $e.m3 $e.pks $e.npk $e.ll2 $e.nn $e.ll3 $e.cpk $e.ll4 $e.brk $e.env -side left -padx 2
		pack $e.all -side right -padx 2

		label $e2.ll -text "SAVE NEW FILTER ... "
		button $e2.sav -text "Save" -width 12 -command "set pr_res 6" -highlightbackground [option get . background {}]
		label $e2.ll3 -text "in file"
		entry $e2.save -textvariable res_savefile -width 16
		label $e2.mous -text ""
		pack $e2.ll $e2.sav $e2.ll3 $e2.save -side left -padx 2
		pack $e2.mous -side right

		#	CANVAS AND VALUE LISTING
		set res_screen [canvas $resdisp.c -height $evv(RES_HEIGHT) -width $evv(RES_WIDTH) -borderwidth 0 \
			-highlightthickness 1 -highlightbackground $evv(SPECIAL)]
		pack $resdisp.btns -side top -fill x -expand true
		pack $resdisp.b1 -side top -fill x -expand true
		pack $resdisp.d -side top -fill x -expand true
		pack $resdisp.d1 -side top -fill x -expand true
		pack $resdisp.e -side top -fill x -expand true
		pack $resdisp.e1 -side top -fill x -expand true
		pack $resdisp.e2 -side top -fill x -expand true
		pack $resdisp.c -side top -expand true -fill both

		;# CHOSEN PEAKS BUTTON ARRAY
		set zz1 [frame $resdisp.f]
		button $zz1.c -text "" -command "set pr_res_chosen 1" -bd 0 -state disabled -highlightbackground [option get . background {}]
		label $zz1.ll -text "" -width 60
		button $zz1.q -text "" -command "set pr_res_chosen 0" -bd 0 -state disabled -highlightbackground [option get . background {}]
		pack $zz1.c $zz1.ll $zz1.q -side left
		pack $zz1 -side top -fill x -expand true
		set zz2 [frame $resdisp.g]
		set cnt 0
		set k 0
		set done 0
		while {$k < 11} {
			frame $zz2.$k
			set n 0
			while {$n < 24} {
				button $zz2.$k.$n -text "" -width 4 -command "HiliteResBut $zz2.$k.$n" -bd 0 -state disabled -highlightbackground [option get . background {}]
				pack $zz2.$k.$n -side left
				incr n
				incr cnt
				if {$cnt >= 254} {
					set done 1
					break
				}
			}
			if {!$done || ($cnt != 0)} {
				pack $zz2.$k -side top -fill x -expand true
				incr k
			}
		}
		pack $zz2 -side top -fill x -expand true
		wm resizable .resscreen 0 0
		bind .resscreen <Escape> {set pr_res 0}
	}
	set resext $isfrq
	set respk 0 
	set last_respk $respk 
	catch {$res_screen delete bars}
	catch {$res_screen delete typ}
	catch {$res_screen delete note}
	set effective_heigth [expr $evv(RES_HEIGHT) - 30]
	set step [expr int(round(($maxmidi - $midilo) * 2.0))]	
	incr step	
	set step [expr $evv(RES_WIDTH) / $step]
	set startpos [expr $step  / 2.0]
	set res_startpos $startpos
	set res_step $step
	set cnt 0
	if [info exists secondline]  {
		$resdisp.btns.q config -foreground $evv(SPECIAL)
		$resdisp.btns.z1 config -foreground [option get . foreground {}]
		$resdisp.btns.z2 config -foreground $evv(QUIT_COLOR)
		$resdisp.btns.z3 config -foreground $evv(QUIT_COLOR)
		set midi [lindex $firstline 0]
		set midi [expr int(round($midi + 0.5)) * 2]
		set midi [lindex $secondline 0]
		set mid2 [expr int(round($midi + 0.5)) * 2]
		if {$mid2 < $midi} {
			set midi $mid2
			set rescnt_offset $midi
		}
		$resdisp.btns.midi config -text "" -bd 0 -state disabled
		$resdisp.btns.freq config -text "" -bd 0 -state disabled
		$resdisp.d.disp config -text ""
		$resdisp.d.norm config -text "" -bd 0 -state disabled
		$resdisp.d.whol config -text "" -bd 0 -state disabled
		$resdisp.d.m3   config -text "" -bd 0 -state disabled
		$resdisp.d.peak config -text "" -bd 0 -state disabled
		$resdisp.e.ll   config -text "" 
		$resdisp.e.whol config -text "" -bd 0 -state disabled
		$resdisp.e.m3   config -text "" -bd 0 -state disabled
		$resdisp.e.pks  config -text "" -bd 0 -state disabled
		$resdisp.e.npk  config -text "" -bd 0 -state disabled
		$resdisp.e.ll2  config -text ""
		$resdisp.e.nn   config			-bd 0 -state disabled
		$resdisp.e.cpk  config -text "" -bd 0 -state disabled
		$resdisp.e.ll4  config -text ""
		$resdisp.e.brk  config -text "" -bd 0 -state disabled
		$resdisp.e.env  config -text "" -bd 0 -state disabled
		$resdisp.e.all  config -text "" -bd 0 -state disabled
		$resdisp.e2.ll  config -text ""
		$resdisp.e2.sav config -text "" -bd 0 -state disabled
		$resdisp.e2.ll3 config -text ""
		$resdisp.e2.save config			-bd 0 -state disabled
	} else {
		$resdisp.btns.q config -foreground $evv(QUIT_COLOR)
		$resdisp.btns.z1 config -foreground [option get . background {}]
		$resdisp.btns.z2 config -foreground [option get . background {}]
		$resdisp.btns.z3 config -foreground [option get . background {}]

		$resdisp.btns.midi config -text "Midi"		   -bd 2 -state normal
		$resdisp.btns.freq config -text "Freq"		   -bd 2 -state normal
		$resdisp.d.disp config -text "DISPLAY TEXT AS ...  "
		$resdisp.d.norm config -text "Semitones"	   -bd 2 -state normal
		$resdisp.d.whol config -text "Major 2nds"	   -bd 2 -state normal
		$resdisp.d.m3   config -text "Minor 3rds"	   -bd 2 -state normal
		$resdisp.d.peak config -text "Peaks Only"	   -bd 2 -state normal
		$resdisp.e.ll   config -text "EDIT THE FILTER ....." 
		$resdisp.e.whol config -text "Major 2nds"      -bd 2 -state normal
		$resdisp.e.m3   config -text "Minor 3rds"      -bd 2 -state normal
		$resdisp.e.pks  config -text "Peaks Only"      -bd 2 -state normal
		$resdisp.e.npk  config -text "N Peaks only"    -bd 2 -state normal
		$resdisp.e.ll2  config -text "N = "
		$resdisp.e.nn   config -bd 0 -state normal
		$resdisp.e.cpk  config -text "Specific Peaks"  -bd 2 -state normal
		$resdisp.e.ll4  config -text "       ENVELOPE"
		$resdisp.e.brk  config -text "Draw"			   -bd 2 -state normal
		$resdisp.e.env  config -text "Apply"		   -bd 2 -state normal
		$resdisp.e.all  config -text "ORIGINAL VALUES" -bd 2 -state normal
		$resdisp.e2.ll  config -text "SAVE NEW FILTER ... "
		$resdisp.e2.sav config -text "Save"			   -bd 2 -state normal
		$resdisp.e2.ll3 config -text "in file"
		$resdisp.e2.save config						   -bd 2 -state normal
	}
	foreach {midi amp} $firstline {
		if {($cnt == 0) && ![info exists rescnt_offset]} {
			set rescnt_offset [expr int(round($midi + 0.5)) * 2]
		}
		set res_sparse [GetResSparse $firstline $cnt $step $amp]
		set thispos [expr int(round($startpos))]
		set thisheight [expr int(round($amp * $effective_heigth))]
		set thistop [expr $evv(RES_HEIGHT) - $thisheight]
		if {[IsEven $cnt]} {	;# QTONES
			if {$thisheight > 0} {
				if {[info exists secondline]} {
					$res_screen create line $thispos $evv(RES_HEIGHT) $thispos $thistop -width 3 -fill $evv(SPECIAL) -tag bars
				} else {
					$res_screen create line $thispos $evv(RES_HEIGHT) $thispos $thistop -width 3 -fill $evv(QUIT_COLOR) -tag bars
				}
			}
			if {$res_sparse} {
				set thistext [MidiToNote [expr int(floor($midi))]]
				append thistext "+"
				$res_screen create text $thispos  [expr $thistop - 8]  -text $thistext -fill $evv(SPECIAL) -font {helvetica 9 normal} -tag note
				set res_sparse_done 1
			}
			set lasttop $thistop
		} else {
			if {$thisheight > 0} {
				$res_screen create line $thispos $evv(RES_HEIGHT) $thispos $thistop -width 3 -fill $evv(SPECIAL) -tag bars
			}
			set midi [expr int(round($midi))]
			set thistext [MidiToNote $midi]
			if {$amp <= 0.0} {
				if {![info exists res_sparse_done]} {
					set thistop $lasttop	;# i.e. PUT TEXT relating to previous qtone HIGH UP ON DISPLAY WHEN CHANNEL IS ZEROED , if text not previously displayed
				}
			}
			if {![Flteq $thistop $evv(RES_HEIGHT)]} {
				$res_screen create text $thispos  [expr $thistop - 8]  -text $thistext -fill $evv(SPECIAL) -font {helvetica 9 normal} -tag note
				if {$resext} {
					set midi [DecPlaces [MidiToHz $midi] 1]
					$res_screen create text $thispos  [expr $thistop - 22]  -text $midi -fill $evv(SPECIAL) -font {helvetica 7 normal} -tag typ
				} else {
					$res_screen create text $thispos  [expr $thistop - 22]  -text $midi -fill $evv(SPECIAL) -font {helvetica 8 normal} -tag typ
				}
			}
			catch {unset res_sparse_done}
		}
		set startpos [expr $startpos + $step]
		incr cnt
	}
	if [info exists secondline] {
		set startpos [expr ($step  / 4.0) * 3.0]
		set res_startpos $startpos
		set res_step $step
		set cnt 0
		foreach {midi amp} $secondline {
			set res_sparse [GetResSparse $firstline $cnt $step $amp]
			set thispos [expr int(round($startpos))]
			set thisheight [expr int(round($amp * $effective_heigth))]
			set thistop [expr $evv(RES_HEIGHT) - $thisheight]
			if {[IsEven $cnt]} {	;# QTONES
				if {$thisheight > 0} {
					$res_screen create line $thispos $evv(RES_HEIGHT) $thispos $thistop -width 3 -fill $evv(QUIT_COLOR) -tag bars
				}
				if {$res_sparse} {
					set thistext [MidiToNote [expr int(floor($midi))]]
					append thistext "+"
					$res_screen create text $thispos  [expr $thistop - 8]  -text $thistext -fill $evv(QUIT_COLOR) -font {helvetica 9 normal} -tag note
					set res_sparse_done 1
				}
				set lasttop $thistop
			} else {
				if {$thisheight > 0} {
					$res_screen create line $thispos $evv(RES_HEIGHT) $thispos $thistop -width 3 -fill $evv(QUIT_COLOR) -tag bars
				}
				set midi [expr int(round($midi))]
				set thistext [MidiToNote $midi]
				if {$amp <= 0.0} {
					if {![info exists res_sparse_done]} {
						set thistop $lasttop	;# i.e. PUT TEXT relating to previous qtone HIGH UP ON DISPLAY WHEN CHANNEL IS ZEROED , if text not previously displayed
					}
				}
				if {![Flteq $thistop $evv(RES_HEIGHT)]} {
					$res_screen create text $thispos  [expr $thistop - 8]  -text $thistext -fill $evv(QUIT_COLOR) -font {helvetica 9 normal} -tag note
					if {$resext} {
						set midi [DecPlaces [MidiToHz $midi] 1]
						$res_screen create text $thispos  [expr $thistop - 22]  -text $midi -fill $evv(QUIT_COLOR) -font {helvetica 7 normal} -tag typ
					} else {
						$res_screen create text $thispos  [expr $thistop - 22]  -text $midi -fill $evv(QUIT_COLOR) -font {helvetica 8 normal} -tag typ
					}
				}
				catch {unset res_sparse_done}
			}
			set startpos [expr $startpos + $step]
			incr cnt
		}
	}
	catch {unset res_sparse_done}
	set last_resext $resext
	raise .resscreen
	update idletasks
	StandardPosition2 .resscreen
	set pr_res 0
	set finished 0
	My_Grab 0 .resscreen pr_res
	while {!$finished} {
		tkwait variable pr_res
		switch -- $pr_res {
			0 {
				set finished 1
			}
			1 {
				catch {unset nufile}
				catch {$res_screen delete cline}
				catch {$res_screen delete points}
				if {[info exists res(brkadjusted)] || [info exists no_respk] || ($last_resext != $resext)} {
					catch {UnbindRes}
					catch {unset no_respk}
					catch {$res_screen delete bars}
					catch {$res_screen delete typ}
					catch {$res_screen delete note}
					if {$respk == 1} {
						if {![info exists res_pks_xtracted]} {
							set res_pks_xtracted [ExtractResPeaks $firstline]
						}
					}
					set startpos [expr $step / 2.0]
					set cnt 0
					foreach {midi amp} $firstline {
						if {$respk == 0} {
							set res_sparse [GetResSparse $firstline $cnt $step $amp]
						} else {
							set res_sparse 0
						}
						set thispos [expr int(round($startpos))]
						set thisheight [expr int(round($amp * $effective_heigth))]
						set thistop [expr $evv(RES_HEIGHT) - $thisheight]
						if {[IsEven $cnt]} {	
							if {$thisheight > 0} {
								$res_screen create line $thispos $evv(RES_HEIGHT) $thispos $thistop -width 3 -fill $evv(QUIT_COLOR) -tag bars
							}
							if {(($respk == 1) && ([lsearch $res_pks_xtracted $cnt] >=0)) || $res_sparse} {

								set thistext [MidiToNote [expr int(floor($midi))]]
								append thistext "+"
								$res_screen create text $thispos  [expr $thistop - 8]  -text $thistext -fill $evv(SPECIAL) -font {helvetica 9 normal} -tag note
								if {$resext} {
									set midi [DecPlaces [MidiToHz $midi] 1]
									$res_screen create text $thispos  [expr $thistop - 22] -text $midi -fill $evv(SPECIAL) -font {helvetica 7 normal} -tag typ
								} else {
									$res_screen create text $thispos  [expr $thistop - 22] -text $midi -fill $evv(SPECIAL) -font {helvetica 8 normal} -tag typ
								}
								if {$res_sparse} {
									set res_sparse_done 1
								}
							} else {
								set lasttop $thistop
							}
						} else {
							if {$thisheight > 0} {
								$res_screen create line $thispos $evv(RES_HEIGHT) $thispos $thistop -width 3 -fill $evv(SPECIAL) -tag bars
							}
							if {$amp <= 0.0} {
								if {![info exists res_sparse_done]} {
									set thistop $lasttop
								}
							}
							if {![Flteq $thistop $evv(RES_HEIGHT)]} {
								switch -- $respk {
									1 {
										if {[lsearch $res_pks_xtracted $cnt] < 0} {
											set startpos [expr $startpos + $step]
											incr cnt
											catch {unset res_sparse_done}
											continue
										}
									}
									2 {
										if {[expr $cnt % 4] == 3} {
											set startpos [expr $startpos + $step]
											incr cnt
											continue
										}
									}
									3 {
										set kq [expr $cnt % 6] 
										if {($kq == 3) || ($kq == 5)} {
											set startpos [expr $startpos + $step]
											incr cnt
											continue
										}
									}
								}
								set thistext [MidiToNote [expr int(round($midi))]]
								$res_screen create text $thispos  [expr $thistop - 8]  -text $thistext -fill $evv(SPECIAL) -font {helvetica 9 normal} -tag note
								if {$resext} {
									set midi [DecPlaces [MidiToHz $midi] 1]
									$res_screen create text $thispos  [expr $thistop - 22] -text $midi -fill $evv(SPECIAL) -font {helvetica 7 normal} -tag typ
								} else {
									set midi [expr int(round($midi))]
									$res_screen create text $thispos  [expr $thistop - 22] -text $midi -fill $evv(SPECIAL) -font {helvetica 8 normal} -tag typ
								}
							}
							catch {unset res_sparse_done}
						}
						set startpos [expr $startpos + $step]
						incr cnt
					}
					set last_resext $resext
					catch {unset res_sparse_done}
				}
			}
			2 {
				catch {unset res(brkadjusted)}
				catch {$res_screen delete cline}
				catch {$res_screen delete points}
				UnbindRes
				catch {unset nufile}
				if {[info exists no_respk] || ($last_respk != $respk)} {
					catch {unset no_respk}
					catch {$res_screen delete bars}
					catch {$res_screen delete typ}
					catch {$res_screen delete note}
					if {$respk == 1} {
						if {![info exists res_pks_xtracted]} {
							set res_pks_xtracted [ExtractResPeaks $firstline]
						}
					}
					set startpos [expr $step / 2.0]
					set cnt 0
					foreach {midi amp} $firstline {
						if {$respk == 0} {
							set res_sparse [GetResSparse $firstline $cnt $step $amp]
						} else {
							set res_sparse 0
						}
						set thispos [expr int(round($startpos))]
						set thisheight [expr int(round($amp * $effective_heigth))]
						set thistop [expr $evv(RES_HEIGHT) - $thisheight]
						if {[IsEven $cnt]} {	
							if {$thisheight > 0} {
								$res_screen create line $thispos $evv(RES_HEIGHT) $thispos $thistop -width 3 -fill $evv(QUIT_COLOR) -tag bars
							}
							if {(($respk == 1) && ([lsearch $res_pks_xtracted $cnt] >=0)) || $res_sparse} {
								set thistext [MidiToNote [expr int(floor($midi))]]
								append thistext "+"
								$res_screen create text $thispos  [expr $thistop - 8]  -text $thistext -fill $evv(SPECIAL) -font {helvetica 9 normal} -tag note
								if {$resext} {
									set midi [DecPlaces [MidiToHz $midi] 1]
									$res_screen create text $thispos  [expr $thistop - 22] -text $midi -fill $evv(SPECIAL) -font {helvetica 7 normal} -tag typ
								} else {
									$res_screen create text $thispos  [expr $thistop - 22] -text $midi -fill $evv(SPECIAL) -font {helvetica 8 normal} -tag typ
								}
								if {$res_sparse} {
									set res_sparse_done 1
								}
							} else {
								set lasttop $thistop
							}
						} else {
							if {$thisheight > 0} {
								$res_screen create line $thispos $evv(RES_HEIGHT) $thispos $thistop -width 3 -fill $evv(SPECIAL) -tag bars
							}
							if {$amp <= 0.0} {
								if {![info exists res_sparse_done]} {
									set thistop $lasttop
								}
							}
							if {![Flteq $thistop $evv(RES_HEIGHT)]} {
								switch -- $respk {
									1 {
										if {[lsearch $res_pks_xtracted $cnt] < 0} {
											set startpos [expr $startpos + $step]
											incr cnt
											catch {unset res_sparse_done}
											continue
										}
									}
									2 {
										if {[expr $cnt % 4] == 3} {
											set startpos [expr $startpos + $step]
											incr cnt
											continue
										}
									}
									3 {
										set kq [expr $cnt % 6] 
										if {($kq == 3) || ($kq == 5)} {
											set startpos [expr $startpos + $step]
											incr cnt
											continue
										}
									}
								}
								set thistext [MidiToNote [expr int(round($midi))]]
								$res_screen create text $thispos  [expr $thistop - 8]  -text $thistext -fill $evv(SPECIAL) -font {helvetica 9 normal} -tag note
								if {$resext} {
									set midi [DecPlaces [MidiToHz $midi] 1]
									$res_screen create text $thispos  [expr $thistop - 22] -text $midi -fill $evv(SPECIAL) -font {helvetica 7 normal} -tag typ
								} else {
									set midi [expr int(round($midi))]
									$res_screen create text $thispos  [expr $thistop - 22] -text $midi -fill $evv(SPECIAL) -font {helvetica 8 normal} -tag typ
								}
							}
							catch {unset res_sparse_done}
						}
						set startpos [expr $startpos + $step]
						incr cnt
					}
					catch {unset res_sparse_done}
					set last_respk $respk
				}
			}
			3 {
				catch {unset res(brkadjusted)}
				if {![info exists res_pks_xtracted]} {
					set res_pks_xtracted [ExtractResPeaks $firstline]
				}
				if {[llength res_pks_xtracted] <= 0} {
					Inf "No Peaks Found"
					continue
				}
				catch {$res_screen delete cline}
				catch {$res_screen delete points}
				UnbindRes
				catch {unset nufile}
				catch {$res_screen delete bars}
				catch {$res_screen delete typ}
				catch {$res_screen delete note}
				set startpos [expr $step / 2.0]
				set cnt 0
				foreach {midi amp} $firstline {
					set thispos [expr int(round($startpos))]
					set thisheight [expr int(round($amp * $effective_heigth))]
					set thistop [expr $evv(RES_HEIGHT) - $thisheight]
					if {[lsearch $res_pks_xtracted $cnt] >=0} {
						lappend nufile $midi $amp
						set thistext [MidiToNote [expr int(floor($midi))]]
						if {[IsEven $cnt]} {
							append thistext "+"
							if {$thisheight > 0} {
								$res_screen create line $thispos $evv(RES_HEIGHT) $thispos $thistop -width 3 -fill $evv(QUIT_COLOR) -tag bars
							}
						} else {
							if {$thisheight > 0} {
								$res_screen create line $thispos $evv(RES_HEIGHT) $thispos $thistop -width 3 -fill $evv(SPECIAL) -tag bars
							}
						}
						$res_screen create text $thispos  [expr $thistop - 8]  -text $thistext -fill $evv(SPECIAL) -font {helvetica 9 normal} -tag note
						$res_screen create text $thispos  [expr $thistop - 22] -text $midi -fill $evv(SPECIAL) -font {helvetica 7 normal} -tag typ
					}
					set startpos [expr $startpos + $step]
					incr cnt
				}
				set no_respk 1
			}
			4 {
				catch {unset res(brkadjusted)}
				catch {unset nupks}
				if {![info exists res_pks_xtracted]} {
					set res_pks_xtracted [ExtractResPeaks $firstline]
				}
				if {[llength res_pks_xtracted] <= 0} {
					Inf "No Peaks Found"
					continue
				}
				if {[string length $res_peakcnt] <= 0} {
					Inf "No Peakcnt (N) Entered"
					continue
				}
				if {![regexp {^[0-9]+$} $res_peakcnt] || ($res_peakcnt <= 0)} {
					Inf "Invalid Peakcnt (N) Entered"
					continue
				}
				if {$res_peakcnt > [llength $res_pks_xtracted]} {
					Inf "There Are Only [llength $res_pks_xtracted] Available"
					continue
				}
				catch {$res_screen delete cline}
				catch {$res_screen delete points}
				UnbindRes
				catch {unset nufile}
				set cnt 0
				foreach {midi amp} $firstline {
					if {[lsearch $res_pks_xtracted $cnt] >= 0} {
						lappend nufile $midi $amp
						lappend nupks $cnt
					}
					incr cnt
				}
				set k [expr [llength $res_pks_xtracted] - $res_peakcnt]
				while {$k > 0} {		;#	REMOVE EXCESS PEAKS
					set maxxamp 100000.0
					set cnt 0
					foreach {midi amp} $nufile {
						if {$amp < $maxxamp} {
							set maxxamp $amp
							set j $cnt
						}
						incr cnt
					}
					set nupks [lreplace $nupks $j $j]
					set j [expr $j * 2]
					set jj $j
					incr jj
					set nufile [lreplace $nufile $j $jj]
					incr k -1
				}
				catch {$res_screen delete bars}
				catch {$res_screen delete typ}
				catch {$res_screen delete note}
				set startpos [expr $step / 2.0]
				set cnt 0
				foreach {midi amp} $firstline {
					set thispos [expr int(round($startpos))]
					set thisheight [expr int(round($amp * $effective_heigth))]
					set thistop [expr $evv(RES_HEIGHT) - $thisheight]
					if {[lsearch $nupks $cnt] >= 0} {
						set thistext [MidiToNote [expr int(floor($midi))]]
						if {[IsEven $cnt]} {
							if {$thisheight > 0} {
								$res_screen create line $thispos $evv(RES_HEIGHT) $thispos $thistop -width 3 -fill $evv(QUIT_COLOR) -tag bars
							}
							append thistext "+"
						} else {
							if {$thisheight > 0} {
								$res_screen create line $thispos $evv(RES_HEIGHT) $thispos $thistop -width 3 -fill $evv(SPECIAL) -tag bars
							}
						}
						$res_screen create text $thispos  [expr $thistop - 8]  -text $thistext -fill $evv(SPECIAL) -font {helvetica 9 normal} -tag note
						$res_screen create text $thispos  [expr $thistop - 22] -text $midi -fill $evv(SPECIAL) -font {helvetica 7 normal} -tag typ
					}
					set startpos [expr $startpos + $step]
					incr cnt
				}
				set no_respk 1
			}
			5 {
				catch {unset res(brkadjusted)}
				if {![info exists res_pks_xtracted]} {
					set res_pks_xtracted [ExtractResPeaks $firstline]
				}
				if {[llength res_pks_xtracted] <= 0} {
					Inf "No Peaks Found"
					continue
				}
				catch {$res_screen delete cline}
				catch {$res_screen delete points}
				UnbindRes
				set cnt 0
				catch {unset res_midilist}
				foreach {midi amp} $firstline {
					if {[lsearch $res_pks_xtracted $cnt] >= 0} {
						lappend res_midilist $midi
					}
					incr cnt
				}
				set res_midilist [ChooseResPeaks $res_midilist]
				if {[llength $res_midilist] <= 0} {
					continue
				}
				catch {unset nufile}
				catch {$res_screen delete bars}
				catch {$res_screen delete typ}
				catch {$res_screen delete note}
				set startpos [expr $step / 2.0]
				set cnt 0
				foreach {midi amp} $firstline {
					set thispos [expr int(round($startpos))]
					set thisheight [expr int(round($amp * $effective_heigth))]
					set thistop [expr $evv(RES_HEIGHT) - $thisheight]
					if {[lsearch $res_midilist $cnt] >=0} {
						lappend nufile $midi $amp
						set thistext [MidiToNote [expr int(floor($midi))]]
						if {[IsEven $cnt]} {
							append thistext "+"
							if {$thisheight > 0} {
								$res_screen create line $thispos $evv(RES_HEIGHT) $thispos $thistop -width 3 -fill $evv(QUIT_COLOR) -tag bars
							}
						} else {
							if {$thisheight > 0} {
								$res_screen create line $thispos $evv(RES_HEIGHT) $thispos $thistop -width 3 -fill $evv(SPECIAL) -tag bars
							}
						}
						$res_screen create text $thispos  [expr $thistop - 8]  -text $thistext -fill $evv(SPECIAL) -font {helvetica 9 normal} -tag note
						$res_screen create text $thispos  [expr $thistop - 22] -text $midi -fill $evv(SPECIAL) -font {helvetica 7 normal} -tag typ
					}
					set startpos [expr $startpos + $step]
					incr cnt
				}
				set no_respk 1
			}
			6 {
				if {![info exists nufile]} {
					Inf "No New Data To Save"
					continue
				}
				if {[string length $res_savefile] <= 0} {
					Inf "No Filename Entered"
					continue
				}
				if {![ValidCDPRootname $res_savefile]} {
					continue
				}
				set nufnam [string tolower $res_savefile]
				append nufnam $evv(TEXT_EXT)
				if {[file exists $nufnam]} {
					set msg "File $nufnam Already Exists: Overwrite It ??"
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
				}
				if [catch {open $nufnam "w"} zit] {
					Inf "Cannot Open File $nufnam"
					continue
				}
				set line 0
				set line [concat $line $nufile]
				puts $zit $line
				set line 10000
				set line [concat $line $nufile]
				puts $zit $line
				close $zit
				if {[FileToWkspace $nufnam 0 0 0 0 1] > 0} {
					Inf "File $res_savefile Is Now On The Workspace"
				}
				UnbindRes
				catch {$res_screen delete cline}
				catch {$res_screen delete points}
			}
			7 -
			8 {
				catch {unset res(brkadjusted)}
				catch {$res_screen delete cline}
				catch {$res_screen delete points}
				UnbindRes
				catch {unset nufile}
				catch {$res_screen delete bars}
				catch {$res_screen delete typ}
				catch {$res_screen delete note}
				set startpos [expr $step / 2.0]
				set cnt 0
				foreach {midi amp} $firstline {
					set thispos [expr int(round($startpos))]
					set thisheight [expr int(round($amp * $effective_heigth))]
					set thistop [expr $evv(RES_HEIGHT) - $thisheight]
					if {$pr_res == 7} {
						set kk 4
						set jj 3		;#	Every 4th item is a Tone
					} else {
						set kk 6
						set jj 5		;# Every 6th item is a minor 3rd
					}
					if {([expr $cnt % $kk] == $jj) && ![Flteq $thistop $evv(RES_HEIGHT)]} {
						lappend nufile $midi $amp
						if {$thisheight > 0} {
							$res_screen create line $thispos $evv(RES_HEIGHT) $thispos $thistop -width 3 -fill $evv(SPECIAL) -tag bars
						}
						set thistext [MidiToNote [expr int(round($midi))]]
						$res_screen create text $thispos  [expr $thistop - 8]  -text $thistext -fill $evv(SPECIAL) -font {helvetica 9 normal} -tag note
						set midi [expr int(round($midi))]
						$res_screen create text $thispos  [expr $thistop - 22] -text $midi -fill $evv(SPECIAL) -font {helvetica 8 normal} -tag typ
					}
					set startpos [expr $startpos + $step]
					incr cnt
				}
				set no_respk 1
			}
			9 {
				catch {unset res}
				catch {$res_screen delete cline}
				catch {$res_screen delete points}
				bind $res_screen <ButtonRelease-1> 				{CreateResPoint %W %x %y}
				bind $res_screen <Control-ButtonRelease-1>		{DeleteResPoint %W %x %y}
				bind $res_screen <Shift-ButtonPress-1> 			{MarkResPoint %W %x %y}
				bind $res_screen <Shift-B1-Motion> 				{DragResPoint %W %x %y}
				bind $res_screen <Shift-ButtonRelease-1>		{RelocateResPoint %W}
				bind $res_screen <Control-Command-ButtonRelease-1>	{DeleteResPoints}
				$resdisp.e2.mous config -text "CREATE POINT Click : DELETE Cntrl Clk : DRAG Shft Clk : RESTART Cntrl Command Clk"
			}
			10 {
				catch {unset res(brkadjusted)}
				if {![info exists res] || ![info exists res(disp)] || ([llength res(disp)] <= 0)} {
					Inf "No Breakpoint Data"
					continue
				}
				AdjustBarsToBrkpnt
				UnbindRes
				set res(brkadjusted) 1
			}
		}
	}
	UnbindRes
	My_Release_to_Dialog .resscreen
	Dlg_Dismiss .resscreen
}

proc MidiToNote {midi} {
	set note [expr $midi % 12]
	switch -- $note {
		0  { set note "C" }
		1  { set note "C#" }
		2  { set note "D" }
		3  { set note "Eb" }
		4  { set note "E" }
		5  { set note "F" }
		6  { set note "F#" }
		7  { set note "G" }
		8  { set note "Ab" }
		9  { set note "A" }
		10 { set note "Bb" }
		11 { set note "B" }
		default {
			return 0
		}
	}
	return $note
}

#---- Extract peaks from resonance data
#
# (1) Go through orig res data quantised onto qtone vals...
#	  A peak is higher than 2 amps on either side 
# (2) (except near edges of data)
# (3) Store the Midi values at those places
# (4) Compare peak midi vals with list of midi values in the FINAL resdata (which contains all qtones in rising sequence)
# (5) Store the item numbers of the peak values

proc ExtractResPeaks {vals} {
	global orig_res
	set len [llength $orig_res]
	set len [expr $len / 2]			;#	length in midi-amp pairs
	if {$len <= 2} {
		return {}
	}
	set len_less_one [expr $len - 1]
	set zzz {}
	set cnt 0
	foreach {Midi amp} $orig_res {						;#  (1)
		 switch -- $cnt {
			0 -
			1 {
				set midi($cnt) $Midi
				set ampp($cnt) $amp
			}
			2 {
				set midi($cnt) $Midi
				set ampp($cnt) $amp
				if {($ampp(0) > $ampp(1)) && ($ampp(1) > $ampp(2))} {
					lappend zzz $midi(0)				;#	(2)
				} elseif {$cnt == $len_less_one} {		;#	3 values only in orig resonance
					if {($ampp(1) > $ampp(0)) && ($ampp(1) > $ampp(2))} {
						lappend zzz $midi(1)			;#	(2)
					} elseif {($ampp(2) > $ampp(1)) && ($ampp(1) > $ampp(0))} {
						lappend zzz $midi(2)			;#	(2)
					} elseif {($ampp(2) > $ampp(1)) && ($ampp(1) < $ampp(0))} {
						lappend zzz $midi(0)			;#	(2)
						lappend zzz $midi(2)			;#	(2)
					} 
				}
			}
			3 {
				set midi($cnt) $Midi
				set ampp($cnt) $amp
				if {($ampp(1) > $ampp(0)) \
				&&  ($ampp(1) > $ampp(2)) && ($ampp(2) > $ampp(3))} {
					lappend zzz $midi(1)				;#	(2)
				} elseif {$cnt == $len_less_one} {		;#	4 values only in orig resonance
					if {[llength $zzz] == 1} {			;#  If peak at start 
						if {$ampp(3) > $ampp(2)} {
							lappend zzz $midi(3)		;#	(2)
						}
					} elseif {($ampp(3) > $ampp(2)) && ($ampp(2) > $ampp(1))} {
						if {$ampp(0) > $ampp(1)} {		;#	(2)
							lappend zzz $midi(0)
						}
						lappend zzz $midi(3)			;#	(2)
					} elseif {($ampp(2) > $ampp(1)) && ($ampp(2) > $ampp(3))} {
						if {$ampp(0) > $ampp(1)} {
							lappend zzz $midi(0)		;#	(2)
						}
						lappend zzz $midi(2)			;#	(2)
					} elseif {($ampp(1) > $ampp(0)) && ($ampp(1) > $ampp(2)) \
					&& ($ampp(3) > $ampp(2))} {
						lappend zzz $midi(1) $midi(3)
					}
				}
			}
			default {
				set midi(4) $Midi
				set ampp(4) $amp
				if {($ampp(2) > $ampp(1)) && ($ampp(1) > $ampp(0)) \
				&&  ($ampp(2) > $ampp(3)) && ($ampp(3) > $ampp(4))} {
					lappend zzz $midi(2)		;#  (3)
				} elseif {$cnt == $len_less_one} {
					if {($ampp(3) > $ampp(2)) && ($ampp(2) > $ampp(1)) \
					&&  ($ampp(3) > $ampp(4))} {
						lappend zzz $midi(3)	;#	(2)
					} elseif {($ampp(4) > $ampp(3)) && ($ampp(3) > $ampp(2)) } {
						lappend zzz $midi(4)	;#	(2)
					}
				}
				set n 0
				set m 1
				while {$n < 4} {
					set midi($n) $midi($m)
					set ampp($n) $ampp($m)
					incr n
					incr m
				}
			}
		}
		incr cnt
	}
	if {[llength $zzz] <= 0}  {
		return {}
	}
	set cnt 0
	set yyy {}
	foreach {Midi amp} $vals {
		if {[lsearch $zzz $Midi] >= 0} {		;#  (4)
			lappend yyy $cnt					;#  (5)
		}
		incr cnt
	}
	return $yyy
}

proc IsNotAtSemitone {midi} {

	set xxx [expr int(round($midi * 2.0))]
	set xxx [expr $xxx / 2]
	if {$xxx != $midi} {
		return 1
	}
	return 0
}

proc GetResSparse {firstline cnt step amp} {

	if {$amp == 0} {
		return 0
	}
	set len [llength $firstline]
	set len [expr $len / 2]
	incr len -1				;#	Index of last pair in data
	if {$cnt == 0} {
		set zcnt $cnt
		set thisdist 0		;#	measure display space before next piece of displayed (non-zero) data
		while {$zcnt < $len} {
			incr zcnt
			set thisdist [expr $thisdist + $step]
			set indx [expr ($zcnt * 2) + 1]
			set amp [lindex $firstline $indx]
			if {$amp > 0.0} {
				break
			} 
		}
		set totdist	$thisdist
	} elseif {$cnt == $len} {
		set zcnt $cnt
		set thisdist 0
		while {$zcnt > 0} {
			incr zcnt -1
			set thisdist [expr $thisdist + $step]
			set indx [expr ($zcnt * 2) + 1]
			set amp [lindex $firstline $indx]
			if {$amp > 0.0} {
				break
			} 
		}
		set totdist	$thisdist
	} else {
		set zcnt $cnt
		set thisdist 0
		while {$zcnt < $len} {
			incr zcnt
			set thisdist [expr $thisdist + $step]
			set indx [expr ($zcnt * 2) + 1]
			set amp [lindex $firstline $indx]
			if {$amp > 0.0} {
				break
			} 
		}
		set totdist	$thisdist

		set zcnt $cnt
		set thisdist 0
		while {$zcnt > 0} {
			incr zcnt -1
			set thisdist [expr $thisdist + $step]
			set indx [expr ($zcnt * 2) + 1]
			set amp [lindex $firstline $indx]
			if {$amp > 0.0} {
				break
			} 
		}
		set totdist [expr $totdist + $thisdist]
	}
	if {$totdist > 30} {	;#	If enough space to display text, return 1
		return 1
	}
	return 0
}

proc ChooseResPeaks {pkdata} {
	global resdisp res_chosen pr_res_chosen resext no_respk rescnt_offset evv

	set res_chosen {}
	if {![info exists no_respk] && $resext} {
		Inf "Put Display Into Midi Mode"
		return $res_chosen
	}
	set b $resdisp.btns
	set d $resdisp.d
	set e $resdisp.e
	set e2 $resdisp.e2
	set f $resdisp.f
	set g $resdisp.g
	$b.midi config -state disabled
	$b.freq config -state disabled
	$d.norm config -state disabled
	$d.whol config -state disabled
	$d.m3   config -state disabled
	$d.peak config -state disabled
	$e.whol config -state disabled
	$e.m3   config -state disabled
	$e.pks  config -state disabled
	$e.npk  config -state disabled
	$e.nn	config -state disabled
	$e.all	config -state disabled
	$e2.sav	config -state disabled
	$e2.save config -state disabled
	$f.c config -text "Choose"  -bd 2 -state normal
	$f.ll config -text "Press button to select (or deselect) peak"
	$f.q config -text "Abandon" -bd 2 -state normal
	set k 0
	set n 0
	foreach txt $pkdata {
		$g.$k.$n config -text $txt -bd 2 -state normal
		incr n
		if {$n >= 24} {
			incr k
			set n 0
		}
	}
	set pr_res_chosen 0
	set finished 0
	set finished 0
	while {!$finished} {
		tkwait variable pr_res_chosen
		catch {unset outlist}
		if {$pr_res_chosen} {
			set k 0
			set n 0
			set cnt 0
			set done 0
			while {$k < 13} {
				set n 0
				while {$n < 20} {
					set thisbutton $g.$k.$n
					if [string match [$thisbutton cget -state] "disabled"] {
						set done 1
						break
					} elseif [string match [$thisbutton cget -background] $evv(EMPH)] {
						set val [$thisbutton cget -text]
						set val [expr int(round($val * 2.0)) + 1]
						set val [expr $val - $rescnt_offset]
						lappend outlist $val

					}
					incr n
					incr cnt
					if {$cnt >= 254} {
						set done 1
						break
					}
				}
				if {$done} {
					break
				}
				incr k
			}
			if {![info exists outlist]} {
				Inf "No Peaks Selected"
				continue				
			}
			set res_chosen $outlist
		}
		set finished 1
	}
	$f.c config -text "" -bd 0 -state disabled
	$f.ll config -text ""
	$f.q config -text "" -bd 0 -state disabled
	set cnt 0
	set k 0
	set done 0
	while {$k < 11} {
		set n 0
		while {$n < 24} {
			if [string match [$g.$k.$n cget -state] "disabled"] {
				set done 1
				break
			}
			$g.$k.$n config -text "" -bd 0 -state disabled -bg [option get . background {}]
			incr n
			incr cnt
			if {$cnt >= 254} {
				set done 1
				break
			}
		}
		if {!$done || ($cnt != 0)} {
			incr k
		}
	}
	$b.midi config -state normal
	$b.freq config -state normal
	$d.norm config -state normal
	$d.whol config -state normal
	$d.m3   config -state normal
	$d.peak config -state normal
	$e.whol config -state normal
	$e.m3   config -state normal
	$e.pks  config -state normal
	$e.npk  config -state normal
	$e.nn	config -state normal
	$e.all	config -state normal
	$e2.sav	config -state normal
	$e2.save config -state normal
	return $res_chosen
}

proc HiliteResBut {but} {
	global evv
	set bgstate [$but cget -background]
	if {[string match $bgstate $evv(EMPH)]} {
		$but config -bg [option get . background {}]
	} else {
		$but config -bg $evv(EMPH)
	}
}

proc UnbindRes {} {
	global resdisp res_screen res
	catch {unset res}
	bind $res_screen <ButtonRelease-1> 				{}
	bind $res_screen <Control-ButtonRelease-1>		{}
	bind $res_screen <Shift-ButtonPress-1> 			{}
	bind $res_screen <Shift-B1-Motion> 				{}
	bind $res_screen <Shift-ButtonRelease-1>		{}
	bind $res_screen <Delete> 						{}
	$resdisp.e2.mous config -text ""
}


proc CreateResPoint {w x y} {
	global res evv

	set	timedgepoint 0
	if {$x <= 0} {						 
		set	timedgepoint -1
		set x 0
		if {$y < 0} {
			set y 0
		} elseif {$y > $evv(RES_HEIGHT)} {
			set y $evv(RES_HEIGHT)
		}									 
	} elseif {$x >= $evv(RES_WIDTH)} {
		set	timedgepoint 1
		set x $evv(RES_WIDTH)
		if {$y < 0} {
			set y 0
		} elseif {$y > $evv(RES_HEIGHT)} {
			set y $evv(RES_HEIGHT)
		}
	} elseif {$y < 0} {
		set y 0
	} elseif {$y > $evv(RES_HEIGHT)} {
		set y $evv(RES_HEIGHT)
	}
	if {![info exists res]} {
		CreateInitialResPoint $x $y
		return
	}
	switch -- $timedgepoint {	
		-1 {
			if {![InjectStartPointIntoResLists $y]} {
				return
			} else {
				set redrawpoints 1
			}
		}
		1 {
			if {![InjectEndPointIntoResLists $y]} {
				return
			} else {
				set redrawpoints 1
			}
		}
		default {
			if {![InjectPointIntoResLists $x $y]} {
				return
			} else {
				set redrawpoints 0
			}
		}
	}
	if {$redrawpoints} {
		DisplayResBrkline
	} else {
		DrawResPoint $x $y
		DrawResLine
	}
}

#------ Redisplay the brkpnt line

proc DisplayResBrkline {} {
	DrawResPoints
	DrawResLine
}	

#------ Put a newly created start point into the coords list

proc InjectStartPointIntoResLists {y} {
	global res
	set valindex 1
	if [string match [lindex $res(disp) $valindex] $y] {
		return 0
	}
	set res(disp) [lreplace $res(disp) $valindex $valindex $y]
	return 1
}

#------ Put a newly created end point into the coords list

proc InjectEndPointIntoResLists {y} {
	global res
	set valindex $res(bkend)
	incr valindex
	if [string match [lindex $res(disp) $valindex] $y] {
		return 0
	}
	set res(disp) [lreplace $res(disp) $valindex $valindex $y]
	return 1
}

#------ Put a newly created point into the coords list

proc InjectPointIntoResLists {x y} {
	global res
	 
	set timindex 0

	foreach {xa ya} $res(disp) {
		if [string match $x $xa] {
			return 0					;#	Cannot overwrite existing x
		} elseif {$xa < $x} {
			incr timindex 2
			continue
		}
		set res(disp) [linsert $res(disp) $timindex $x $y]
		incr res(bkend) 2
		return 1
	}
	return 0
}

#------ Create first point

proc CreateInitialResPoint {x y} {
	global res evv

	catch {unset res}
	lappend res(disp) 0 $y
	set res(bkend) 0
	if {$x > 0} {
		lappend res(disp) $x $y
		incr res(bkend) 2
	}
	if {$x  < [expr $evv(RES_WIDTH)]} {
		lappend res(disp) $evv(RES_WIDTH) $y
		incr res(bkend) 2
	}
	DrawResPoints
	DrawResLine
}				  				

#------ Draw points on graf, from stored coords

proc DrawResPoints {} {
	global res_screen res
	catch {$res_screen delete points} in		;#	destroy any existing points
	foreach {x y} $res(disp) {
		DrawResPoint $x $y
	}
}

#------ Draw point on display

proc DrawResPoint {x y} {
	global evv res_screen
	set xa [expr int($x - $evv(PWIDTH))]
	set ya [expr int($y - $evv(PWIDTH))]
	set xb [expr int($x + $evv(PWIDTH))]
	set yb [expr int($y + $evv(PWIDTH))]
	$res_screen create rect $xa $ya $xb $yb -fill $evv(POINT) -tag points
}

#------ Draw line on display

proc DrawResLine {} {
	global res_screen res evv	
	catch {$res_screen delete cline}
	foreach {x y} $res(disp) {
		lappend line_c $x $y
	}
	eval {$res_screen create line} $line_c {-fill $evv(GRAF)} {-tag cline}
}

#------ Delete point closest to place where mouse clicks on canvas

proc DeleteResPoint {w x y} {
	global res res_screen evv

	set obj [GetClosestResPoint $x $y]
	set coords [$res_screen coords $obj]		 	 	;#	Only x-coord required, as can't have time-simultaneous points

	set x [expr round([lindex $coords 0])]			;#	Coords returns floats: convert to int

	#	CONVERT TO CENTRE OF POINT

	incr x $evv(PWIDTH)

	set indx [FindThisPointInResList $x]

	if {$indx > 0 && $indx < $res(bkend) } {	 ;#	Can't delete brktable endpoints
		catch {$res_screen delete $obj} in	 ;#	Delete it
		if [RemovePointFromResLists $indx] { ;#	and remove from listings
			DrawResLine
		}
	}
}

proc GetClosestResPoint {x y} {
	global evv res_screen
	incr x -$evv(PWIDTH)
	incr y -$evv(PWIDTH)
	set mindist $evv(RES_WIDTH)
	incr mindist $evv(RES_WIDTH)
	set displaylist [$res_screen find withtag points]	;#	List all objects which are points
	foreach obj $displaylist {							;#	For each point
		set coords [$res_screen coords $obj]			;#	Only x-coord needed: can't have time-simultaneous points
		set objx [expr round([lindex $coords 0])]		;#	Only x-coord needed: can't have time-simultaneous points
		set thisdist [expr abs($x - $objx)]
		if {$thisdist < $mindist} {
			set mindist $thisdist
			set closest_obj $obj
			set objy [expr round([lindex $coords 1])]
			set thatydist [expr abs($y - $objy)]
		} elseif {$thisdist == $mindist} {
			if {[info exists thisydist]} {
				set objy [expr round([lindex $coords 1])]
				set thisydist [expr abs($y - $objy)]
				if {$thisydist < $thatydist} {
					set thatydist $thisydist
					set closest_obj $obj
				}
			}
		} else {
			catch {unset thisydist}
		}
	}
	return $closest_obj
}

#------ Find given point in coords list

proc FindThisPointInResList {xa} {
	global res
	set timindex 0
	foreach {x y} $res(disp) {
		if [string match $x $xa] {
			return $timindex
		}
		incr timindex 2
	}
	return -1
}

#------ Delete a point from the coords list

proc RemovePointFromResLists {timindex} {
	global res
	set valindex $timindex
	incr valindex
	set res(disp) [lreplace $res(disp) $timindex $valindex]			
	incr res(bkend) -2
	return 1
}

#------ Mark point closest to place where mouse shift-clicks on inner-canvas

proc MarkResPoint {w x y} {
	global res res_screen evv
	set res(ismarked) 0														
#MARCH 7 2005
	set res(obj) [GetClosestResPoint $x $y]
	set coords [$res_screen coords $res(obj)]		 	 	
	set res(x) [expr round([lindex $coords 0])]			;#	Coords returns floats: convert to int
	set res(y) [expr round([lindex $coords 1])]			;#	as can't have time-simultaneous points

#	CONVERT TO CENTRE OF POINT

	incr res(x) $evv(PWIDTH)
	incr res(y) $evv(PWIDTH)

	set res(mx) $x							 				;# 	Save coords of mouse
	set res(my) $y

	set res(lastx) $res(x)									;#	Remember coords of point
	set res(lasty) $res(y)						

	set res(origx) $res(x)
	set res(origy) $res(y)

	set res(timindex) [FindMotionLimitsInResTimeDimension $res(x)]
	if {$res(timindex) < 0} {
		return
	}
	set res(ismarked) 1											;#	Flag that a point is marked
}

#------ Drag marked point, with shift and mouse pressed down

proc DragResPoint {w x y} {
	global res resrightstop resleftstop evv

	if {!$res(ismarked)} {
		return
	}
	set mx $x									 		;#	Map from mouse-coords to canvas-coords
	set my $y						 	
	set dx [expr $mx - $res(mx)]				 		;#	Find distance from last marked position of mouse
	set dy [expr $my - $res(my)]
	incr res(x) $dx										;#	Get coords of dragged point

	if {$res(x) > $resrightstop} {						;#	Check for drag too far right, and, if ness
		set res(x) $resrightstop						;#	adjust coords of point
		set dx [expr $res(x) - $res(lastx)]				;#	and adjust drag-distance
	} elseif {$res(x) < $resleftstop} {					;#	Check for drag too far left, and, if ness
		set res(x) $resleftstop							;#	adjust coords of point
		set dx [expr $res(x) - $res(lastx)]				;#	and adjust drag-distance
	}
	set res(lastx) $res(x)								;#	Remember new x coord
  
	incr res(y) $dy									
	if {$res(y) > $evv(RES_HEIGHT)} {					;#	Check for drag too far down, and, if ness
		set res(y) $evv(RES_HEIGHT)						;#	adjust coords of point
		set dy [expr $res(y) - $res(lasty)]				;#	and adjust drag-distance
	} elseif {$res(y) < 0} {
		set res(y) 0									;#	adjust coords of point
		set dy [expr $res(y) - $res(lasty)]				;#	and adjust drag-distance
	}

	set res(lasty) $res(y)								;#	Remember new y coord

	$w move $res(obj) $dx $dy				 			;#	Move object to new position
	set res(mx) $mx							 			;#  Store new mouse coords
	set res(my) $my
	set valindex $res(timindex)
	incr valindex
	set res(disp) [lreplace $res(disp) $res(timindex) $valindex $res(x) $res(y)]
	DrawResLine
}

#------ Register position of dragged point, in the coordinates lists

proc RelocateResPoint {w} {
	global res
	set res(ismarked) 0
}

#------ Find adjacent points to a given point in coords list

proc FindMotionLimitsInResTimeDimension {xa} {
	global res resrightstop resleftstop evv
	set preindex -2
	set timindex 0
	set postindex 2
	foreach {x y} $res(disp) {
		if [string match $x $xa] {
			if {$timindex == 0} {
				set resleftstop  0
				set resrightstop 0
			} elseif {$timindex == $res(bkend)} {
				set resleftstop  [lindex $res(disp) $res(bkend)]
				set resrightstop [lindex $res(disp) $res(bkend)]
			} else {
				set resleftstop  [lindex $res(disp) $preindex]
				incr resleftstop
				set resrightstop [lindex $res(disp) $postindex]
				incr resrightstop -1
			}
			return $timindex
		}
		incr preindex 2
		incr timindex 2
		incr postindex 2
	}
#
#	ErrShow "Got NO-point: Impossible"
#
	return -1
}

proc DeleteResPoints {} {
	global res res_screen
	catch {$res_screen delete cline}
	catch {$res_screen delete points}
	catch {unset res}
}


proc AdjustBarsToBrkpnt {} {
	global nufile res res_screen res_startpos res_step rescnt_offset evv
	catch {unset nufile}
	set effective_heigth [expr $evv(RES_HEIGHT) - 30]
	set displaylist [$res_screen find withtag bars]

	foreach obj $displaylist {							;#	For each point
		set coords [$res_screen coords $obj]			;#	Only x-coord needed
		set color  [$res_screen itemcget $obj -fill]	;#	and colour
		set objx [expr round([lindex $coords 0])]
		set objy [expr round([lindex $coords 3])]
		foreach {x y} $res(disp) {
			if {$x > $objx} {
				break
			} else {
				set lastx $x
				set lasty $y
			}
		}
		set ratio [expr double($objx - $lastx)/double($x - $lastx)]
		set ystep [expr $y - $lasty]
		set ynew [expr int(round($ystep * $ratio)) + $lasty]
		lappend newcoords $objx $ynew
		lappend newfill $color
	}
	catch {$res_screen delete bars} in
	foreach {x y} $newcoords {color} $newfill {
		$res_screen create line $x $evv(RES_HEIGHT) $x $y -width 3 -fill $color -tag bars
	}
	set notlist [$res_screen find withtag note]
	set typlist [$res_screen find withtag typ]
	foreach obj $typlist {									;#	For each numeric value on display ... move it
		set coords [$res_screen coords $obj]
		set objx [expr round([lindex $coords 0])]
		foreach {x y} $newcoords {
			if {$x == $objx} {
				set midi  [$res_screen itemcget $obj -text]
				set ffont [$res_screen itemcget $obj -font]
				catch {$res_screen delete $obj} in
				$res_screen create text $x  [expr $y - 22] -text $midi -fill $evv(SPECIAL) -font $ffont -tag typ
				break
			}

		}
	}
	foreach obj $notlist {									;#	For each note notation on display ... move it
		set coords [$res_screen coords $obj]
		set objx [expr round([lindex $coords 0])]
		foreach {x y} $newcoords {
			if {$x == $objx} {
				set note  [$res_screen itemcget $obj -text]
				set ffont [$res_screen itemcget $obj -font]
				catch {$res_screen delete $obj} in
				$res_screen create text $x  [expr $y - 8] -text $note -fill $evv(SPECIAL) -font $ffont -tag note
				break
			}
		}
	}
	foreach {x y} $newcoords {								;#	Store resulting appropriate midi /amp vals
		set midi [expr double($x) - $res_startpos]
		set midi [expr int(round($midi / $res_step))]
		set midi [expr $midi + $rescnt_offset]
		incr midi -1
		set midi [DecPlaces [expr double($midi) / 2.0] 1]
		set amp [expr double($evv(RES_HEIGHT) - $y) / double($effective_heigth)]
		lappend nufile $midi $amp
	}
}
