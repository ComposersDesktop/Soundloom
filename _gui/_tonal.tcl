#
# SOUND LOOM RELEASE mac version 17.0.4
#
# RWD 30 June 2013
# ... fixup button rectangles

##########################
# TONAL HARMONY WORKSHOP # 
##########################

proc PitchManips {from_tabed} {
	global pr_pbp pbankgrafix pm_key pm_inkey pm_semit pm_midilist pm_numidilist pm_lastmidilist pm_zz0 pm_invtype pm_mode tabed lmo evv
	global col_ungapd_numeric wstk pm_outfile incols
	global CDPidrun prg_dun prg_abortd program_messages

	catch {destroy .pmark}
	set lmo "pm"
	lappend lmo $col_ungapd_numeric $from_tabed
	set pm_outfile ""
	set pm_inkey 0
	set pm_midilist {}
	if {$from_tabed} {
		switch -- $from_tabed {
			1  {
				if {$incols <= 0} {
					set msg "No input table"
				} elseif {$incols != 1} {
					set msg "This option only works with single column tables"
				}
				if {[info exists msg]} {
					ForceVal $tabed.message.e  $msg
 					$tabed.message.e config -bg $evv(EMPH)
					return
				}
				set thistab $tabed.bot.itframe.l.list
			}
			2 { set thistab $tabed.bot.icframe.l.list }
		}
		foreach val [$thistab get 0 end] {
			if {![IsNumeric $val]} {
				set msg "MIDI data only."
				break
			} elseif {($val > $evv(MAX_TONAL)) || ($val < $evv(MIN_TONAL))} {
				set msg "Only MIDI values in range $evv(MIN_TONAL) to $evv(MAX_TONAL) can be graphically represented here."
				break
			}
			lappend zlines [expr int(round($val))]
		}
		if {![info exists zlines] && ![info exists msg]} {
			set msg "No column data to use."
		}
		if {[info exists msg]} {
			ForceVal $tabed.message.e  $msg
 			$tabed.message.e config -bg $evv(EMPH)
			return
		}	
		set pm_midilist $zlines
	}
	set pm_numidilist [lsort -integer -increasing $pm_midilist]
	set pm_midilist $pm_numidilist
	set pm_lastmidilist $pm_numidilist
	set g .pbank_pitches
	if [Dlg_Create $g "TONAL HARMONY WORKSHOP" "set pr_pbp 0" -width 120 -borderwidth $evv(SBDR)] {
		set f [frame $g.0 -borderwidth $evv(SBDR)]
		set z [frame $g.1 -width 1  -bg $evv(POINT)]
		set q [frame $g.2 -borderwidth $evv(SBDR)]
		set a [frame $f.a -borderwidth $evv(SBDR)]
		set aa [frame $f.aa -width 1 -bg $evv(POINT)]
		set b [frame $f.b -borderwidth $evv(SBDR)]
		set bb [frame $f.bb -width 1 -bg $evv(POINT)]
		set d [frame $f.d -borderwidth $evv(SBDR)]
		set c [frame $f.c -borderwidth $evv(SBDR)]
		set cc [frame $f.cc -width 1 -bg $evv(POINT)]
		set c0 [frame $f.c0 -borderwidth $evv(SBDR)]
		set c1 [frame $f.c1 -borderwidth $evv(SBDR)]
		set c2 [frame $f.c2 -borderwidth $evv(SBDR)]
		set c3 [frame $f.c3 -borderwidth $evv(SBDR)]
		set c3c [frame $f.c3c -width 1 -bg $evv(POINT)]
		set c4 [frame $f.c4 -borderwidth $evv(SBDR)]
		set c4c [frame $f.c4c -width 1 -bg $evv(POINT)]
		set c5 [frame $f.c5 -borderwidth $evv(SBDR)]
		set c6 [frame $f.c6 -borderwidth $evv(SBDR)]
		set c7 [frame $f.c7 -borderwidth $evv(SBDR)]
		set c7c [frame $f.c7c -width 1 -bg $evv(POINT)]
		set c8 [frame $f.c8 -borderwidth $evv(SBDR)]
		set c8c [frame $f.c8c -width 1 -bg $evv(POINT)]
		button $a.quit -text "Abandon" -command "set pr_pbp 0" -width 7 -highlightbackground [option get . background {}]
		button $a.play -text "Play" -command "set pr_pbp 2" -width 7 -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $a.supe -text "Superimpose" -command "set pr_pbp 3" -width 14 -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $a.import -text "Import MIDI File (Range $evv(MIN_TONAL)-$evv(MAX_TONAL) only)" -command "PmImport" -highlightbackground [option get . background {}]
		pack $a.play $a.supe $a.import -side left -padx 2
		pack $a.quit -side right
		button $b.keep -text "Keep Pitch Set" -command "set pr_pbp 1" -highlightbackground [option get . background {}]
		label $b.fnam -text "Output Filename" -width 15
		entry $b.e -textvariable pm_outfile -width 16
		pack $b.keep $b.fnam $b.e -side left -pady 4
		label $q.do -text "Add Pitches by clicking mouse on stave.\nUse Shift-Click for flat-notes\nUse Control-Click to Delete Notes" -fg $evv(SPECIAL)
		pack $q.do -side top -pady 2
		radiobutton $c.tra -variable pm_zz0 -value 1 -text "Transpose" -command "Pmdo transpose"
		radiobutton $c.trz -variable pm_zz0 -value 5 -text "Add Transposed Set" -command "Pmdo transpose+"
		radiobutton $c.mod -variable pm_zz0 -value 2 -text "Maj<->Min" -command "Pmdo mode"
		radiobutton $c.inv -variable pm_zz0 -value 3 -text "Invert" -command "Pmdo invert"
		radiobutton $c.com -variable pm_zz0 -value 4 -text "Complement" -command "Pmdo complement"
		pack $c.tra $c.trz $c.mod $c.inv $c.com -side left -padx 1
		checkbutton $c0.key -text "In Key" -variable pm_inkey -command "Set_PmKey2"
		pack $c0.key -side top
		button $c1.c  -text "C"		-width 5 -command "set pm_key 1; Hilite_PmKey c" -highlightbackground [option get . background {}]
		button $c1.cc -text "C#/Db" -width 5 -command "set pm_key 2; Hilite_PmKey cc" -highlightbackground [option get . background {}]
		button $c1.d  -text "D"		-width 5 -command "set pm_key 3; Hilite_PmKey d" -highlightbackground [option get . background {}]
		button $c1.dd -text "D#/Eb"	-width 5 -command "set pm_key 4; Hilite_PmKey dd" -highlightbackground [option get . background {}]
		button $c1.e  -text "E"		-width 5 -command "set pm_key 5; Hilite_PmKey e" -highlightbackground [option get . background {}]
		button $c1.f  -text "F"		-width 5 -command "set pm_key 6; Hilite_PmKey f" -highlightbackground [option get . background {}]
		button $c1.ff -text "F#/Gb"	-width 5 -command "set pm_key 7; Hilite_PmKey ff" -highlightbackground [option get . background {}]
		button $c1.g  -text "G"		-width 5 -command "set pm_key 8; Hilite_PmKey g" -highlightbackground [option get . background {}]
		button $c1.gg -text "G#/Ab"	-width 5 -command "set pm_key 9; Hilite_PmKey gg" -highlightbackground [option get . background {}]
		button $c1.a  -text "A"		-width 5 -command "set pm_key 10; Hilite_PmKey a" -highlightbackground [option get . background {}]
		button $c1.aa -text "A#/Bb"	-width 5 -command "set pm_key 11; Hilite_PmKey aa" -highlightbackground [option get . background {}]
		button $c1.b  -text "B"		-width 5 -command "set pm_key 12; Hilite_PmKey b" -highlightbackground [option get . background {}]
		pack $c1.c $c1.cc $c1.d $c1.dd $c1.e $c1.f $c1.ff $c1.g $c1.gg $c1.a $c1.aa $c1.b -side left
		radiobutton $c2.maj -text major -variable pm_mode -value 1 -command ModeMap
		radiobutton $c2.min -text "harmonic minor" -variable pm_mode -value 2 -command ModeMap
		radiobutton $c2.amm -text "ascending melodic minor" -variable pm_mode -value 3 -command ModeMap
		radiobutton $c2.dmm -text "descending melodic minor" -variable pm_mode -value 4 -command ModeMap
		pack $c2.maj $c2.min $c2.amm $c2.dmm -side left -padx 2

		radiobutton $c3.dor -text dorian -variable pm_mode -value 5 -command ModeMap
		radiobutton $c3.phr -text phrygian -variable pm_mode -value 6 -command ModeMap
		radiobutton $c3.lyd -text lydian -variable pm_mode -value 7 -command ModeMap
		radiobutton $c3.mix -text mixolydian -variable pm_mode -value 8 -command ModeMap
		radiobutton $c3.aeo -text ionian -variable pm_mode -value 9 -command ModeMap
		radiobutton $c3.ion -text aeolian -variable pm_mode -value 10 -command ModeMap
		pack $c3.dor $c3.phr $c3.lyd $c3.mix $c3.aeo $c3.ion -side left -padx 2
		radiobutton $c4.cur -text "special mode" -variable pm_mode -value 11 -command ModeMap
		radiobutton $c4.set -text "set current pitches as special mode" -variable pm_mode -value 12 -command ModeMap 
		radiobutton $c4.non -text "total chromatic" -variable pm_mode -value 0 -command "set pm_inkey 0; Set_PmKey2"
		pack $c4.cur $c4.set $c4.non -side left
		label $c5.by -text "Transpose By"
		entry $c5.e -textvariable pm_semit -width 4 -bg $evv(EMPH) -disabledbackground [option get . background {}]
		label $c5.sem -text "Semitones"
		pack $c5.by $c5.e $c5.sem -side left -padx 2
		label $c6.di -text "Do Inversion"
		radiobutton $c6.abs -text "In Place" -value 1 -variable pm_invtype -width 8
		radiobutton $c6.up -text "Around Bass" -value 2 -variable pm_invtype -width 11
		radiobutton $c6.dn -text "Around Top" -value 3 -variable pm_invtype -width 10
		pack $c6.di $c6.abs $c6.up $c6.dn -side left
		button $c7.doit -text "Do It" -command Pmdoit -width 7 -bd 4 -highlightbackground [option get . background {}]
		pack $c7.doit -side left
		button $c8.rup -text "Rotate Up" -command "Pmdo rotup" -width 14 -highlightbackground [option get . background {}]
		button $c8.rdn -text "Rotate Down" -command "Pmdo rotdn" -width 14 -highlightbackground [option get . background {}]
		button $c8.sqz -text "Contract Set" -command "Pmdo contract" -width 14 -highlightbackground [option get . background {}]
		button $c8.sqc -text "Contract Chord" -command "Pmdo contract_chord" -width 14 -highlightbackground [option get . background {}]
		button $c8.spr -text "Spread Chord" -command "Pmdo spread" -width 14 -highlightbackground [option get . background {}]
		pack $c8.rup $c8.rdn $c8.sqz $c8.sqc $c8.spr -side left -padx 8
		button $d.rep -text "Repeat Action" -command Pm_Again -width 14 -highlightbackground [option get . background {}]
		button $d.pre -text "Previous Set" -command "Pmdo last" -width 14 -highlightbackground [option get . background {}]
		button $d.res -text "Get Original" -command "Pmdo restore" -width 14 -highlightbackground [option get . background {}]
		pack $d.rep -side left -padx 2
		pack $d.res $d.pre -side right -padx 2
		set pbankgrafix [EstablishPmarkDisplay $q]
		pack $pbankgrafix -side top

		pack $a -side top -pady 16 -fill x -expand true
		pack $aa -side top -fill x -expand true
		pack $b -side top
		pack $bb -side top -fill x -expand true
		pack $c -side top -pady 1
		pack $cc -side top -fill x -expand true -pady 4
		pack $c0 $c1 $c2 $c3 -side top -pady 1
		pack $c3c -side top -fill x -expand true
		pack $c4 -side top -pady 1
		pack $c4c -side top -fill x -expand true -pady 4
		pack $c5 $c6 $c7 -side top -pady 1
		pack $c7c -side top -fill x -expand true -pady 4
		pack $c8 -side top -pady 1 -padx 16
		pack $c8c -side top -fill x -expand true -pady 4
		pack $d -side top -pady 1 -fill x -expand true

		pack $f -side left
		pack $z -side left -fill y -expand true
		pack $q -side left
		wm resizable $g 1 1
		set pm_key 0
		set pm_mode 0

		bind $pbankgrafix <ButtonRelease-1> {PgrafixAddPitch $pbankgrafix %x %y 0}
		bind $pbankgrafix <Shift-ButtonRelease-1> {PgrafixAddPitch $pbankgrafix %x %y 1}
		bind $pbankgrafix <Control-ButtonRelease-1> {PgrafixDelPitch $pbankgrafix %x %y}

		bind $g <Escape> {set pr_pbp 0}
	}
	if {$from_tabed} {
		.pbank_pitches.0.b.fnam config -text ""
		.pbank_pitches.0.b.e config -bd 0 -state disabled
		.pbank_pitches.0.a.quit config -text "Abandon"
		.pbank_pitches.0.a.import config -text "" -bd 0 -state disabled
		.pbank_pitches.0.d.res config -text "Get Original"
		$g.0.a.supe config -text "" -command {} -bd 0
	} else {
		.pbank_pitches.0.b.fnam config -text "Output Filename"
		.pbank_pitches.0.b.e config -bd 2 -state normal
		.pbank_pitches.0.a.quit config -text "Close"
		.pbank_pitches.0.a.import config -text "Import MIDI File (Range $evv(MIN_TONAL)-$evv(MAX_TONAL) only)" -bd 2 -state normal
		.pbank_pitches.0.d.res config -text "Clear"
		$g.0.a.supe config -text "Superimpose" -command "set pr_pbp 3" -bd 2
	}
	Pmtrans 0
	PmInvert 0
	set pm_zz 0
	.pbank_pitches.0.c7.doit config -text "" -bd 0 -state disabled -bg [option get . background {}]
	set pm_inkey 0
	Set_PmKey 0
	set pm_mode 0
	ClearPitchGrafix $pbankgrafix
	InsertPitchGrafix $pm_midilist $pbankgrafix
	raise $g
	update idletasks
	StandardPosition $g
	set finished 0
	set pr_pbp 0
	My_Grab 0 $g pr_pbp
	while {!$finished} {
		tkwait variable pr_pbp
		switch -- $pr_pbp {
			0 {
				set finished 1
			}
			1 {
				if {[info exists pm_numidilist] && [llength $pm_numidilist] > 0} {
					switch -- $from_tabed {
						0 {
							if {[string length $pm_outfile] <= 0} {
								Inf "No Filename Entered"
								continue
							}
							if {![ValidCDPRootname $pm_outfile]} {
								continue
							}
							set fnam $pm_outfile$evv(TEXT_EXT)
							if {[file exists $fnam]} {
								set msg "A File With This Name Exists: Overwrite Existing File ?"
								set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
								if {$choice == "no"} {
									continue
								}
							}							
							if [catch {open $fnam "w"} zit] {
								Inf "Cannot Open File '$fnam'"
								continue
							}
							foreach val $pm_numidilist {
								puts $zit $val
							}
							close $zit
							if {[FileToWkspace $fnam 0 0 0 0 1] > 0} {
								Inf "New File '$fnam' Put On Workspace"
							}
						}
						1 {
							$tabed.bot.otframe.l.list delete 0 end
							foreach val $pm_numidilist {
								$tabed.bot.otframe.l.list insert end $val
							}
							if {[WriteOutputTable $evv(LINECNT_RESET)]} {
								EnableOutputTableOptions 0 1
							}
							set finished 1
						}
						2 {
							$tabed.bot.ocframe.l.list delete 0 end
							foreach val $pm_numidilist {
								$tabed.bot.ocframe.l.list insert end $val
							}
							WriteOutputColumn $evv(COLFILE2) $tabed.bot.ocframe.l.list outlines 1 0 0
							set finished 1
						}
					}
				}
			}
			2 -
			3 {
				if {[info exists pm_numidilist] && [llength $pm_numidilist] > 0} {
					if {$from_tabed} {
						$tabed.bot.ocframe.l.list delete 0 end
						foreach val $pm_numidilist {
							$tabed.bot.ocframe.l.list insert end $val
						}
						WriteOutputColumn $evv(COLFILE2) $tabed.bot.ocframe.l.list outlines 1 0 0
					} else {
						set fnam $evv(COLFILE2) 
						if [catch {open $fnam "w"} zit] {
							Inf "Cannot Open Temporary File '$fnam'"
							continue
						}
						foreach val $pm_numidilist {
							puts $zit $val
						}
						close $zit
					}
					if {$pr_pbp == 2} {
						PlayChordset $evv(COLFILE2) 0
					} else {
						PlayChordsetAndFile $evv(COLFILE2)
					}
				}
			}
		}
	}
	set pm_numidilist {}
	My_Release_to_Dialog $g
	Dlg_Dismiss $g
}

proc PgrafixAddPitch {w x y flat} {
	global pbankgrafix tbankgrafix pmgrafix bpbankgrafix pm_numidilist pm_lastmidilist pm_key pm_mode pm_special_mode
	set check_key 1
	if {([info exists tbankgrafix] && ($w == $tbankgrafix)) \
	||  ([info exists pmgrafix] && ($w == $pmgrafix)) \
	||  ([info exists bpbankgrafix] && ($w == $bpbankgrafix))} {
		set check_key 0
	}
	if {$check_key && $pm_key} {
		if {$pm_mode <= 0} {
			Inf "Must Specify Major,minor or Mode, If A Key Is Specified For Entering Notes."
			return
		}
	}
	if {$flat} {
		set displaylist [$w find withtag flathite]	;#	List all objects which are points
	} else {
		set displaylist [$w find withtag notehite]	;#	List all objects which are points
	}
	set mindiff 100000								;#	Find closest point
	foreach thisobj $displaylist {
		set coords [$w coords $thisobj]
		set yy [lindex $coords 1]
		set diff [expr abs($y - $yy)]
		if {$diff < $mindiff} {
			set yyy $yy
			set mindiff $diff
		}
	}
	if {![info exists yyy]} {
		Inf "No Note Position Found At Mouse Click"
		return
	}
	set thismidi [GetNuPitchFromMouseClikHite [expr int(round($yyy))]]
	if {$thismidi < 0} {
		Inf "Unknown Pitch"
		return
	}
	if {$check_key && ($pm_key || ($pm_mode == 11))} {
		set thismidi [ConfineToKey $thismidi]
		if {$thismidi < 0} {
			return
		}
	} elseif {$flat} {
		incr thismidi -1
	}
	if {[info exists pm_numidilist]} {
		set pm_lastmidilist $pm_numidilist
	} else {
		set pm_lastmidilist {}
	}
	lappend pm_numidilist $thismidi
	set pm_numidilist [lsort -integer -increasing $pm_numidilist]
	set pm_numidilist [EliminateDuplicates $pm_numidilist]
	ClearPitchGrafix $w
	InsertPitchGrafix $pm_numidilist $w
	if {[info exists pmgrafix] && ($w == $pmgrafix)} {
		.pmark.d.d.ll.list delete 0 end
		foreach item $pm_numidilist {
			.pmark.d.d.ll.list insert end $item
		}
	}
}

proc ConfineToKey {midi} {
	global pm_template pm_numidilist
	set oct [expr $midi / 12]
	set midi [expr $midi % 12]
	set mindiff 24
	set mindiffdn 23
	set outvallo {}
	set outvalhi {}
	foreach val $pm_template {
 		set thisdiff [expr abs($midi - $val)]
		if {$midi == 0} {
			set otherdiff [expr abs(12 - $val)]
			if {$otherdiff < $thisdiff} {
				set thisdiff $otherdiff
			}
		}
		if {$val == 0} {
			set otherdiff [expr abs(12 - $midi)]
			if {$otherdiff < $thisdiff} {
				set thisdiff $otherdiff
			}
		}
		if {$thisdiff < $mindiffdn} {
			if {[expr $mindiffdn - $thisdiff] == 1} {
				set outvalhi $outvallo
				set outvallo $val
			} else {
				set outvalhi $val
				set outvallo {}
			}
			set mindiff $thisdiff
			set mindiffdn [expr $mindiff - 1]
		} elseif {$thisdiff == $mindiffdn} {
			lappend outvallo $val
		} elseif {$thisdiff == $mindiff} {
			lappend outvalhi $val
		}

	}
	set outval [concat $outvallo $outvalhi]
	set cnt 0
	while {$cnt < [llength $outval]} {
		set val [lindex $outval $cnt]
		set octincr 0
		set diff [expr $val - $midi]
		if {$diff > 6} {
			set octincr -1
		} elseif {$diff < -6} {
			set octincr 1
		}
		incr oct $octincr
		incr val [expr $oct * 12]
		incr oct -$octincr
		if {[lsearch $pm_numidilist $val] < 0} {
			return $val
		}
		incr cnt
	}
	return -1
}

proc PgrafixDelPitch {w x y} {
	global pm_numidilist pm_lastmidilist pmgrafix
	set displaylist [$w find withtag notes]	;#	List all objects which are notes
	set flatlist    [$w find withtag flat]	;#	List all objects which are flats

	set mindiffx 100000								;#	Find closest note
	set mindiffy 100000
	foreach thisobj $displaylist {
		set coords [$w coords $thisobj]
		set xx [lindex $coords 0]
		set yy [lindex $coords 1]
		set diff [expr abs($y - ($yy + 3))]
		if {$diff < $mindiffy} {
			set yyy $yy
			if {[lsearch -exact $flatlist $thisobj] >= 0} {			;#	If the note is flat
				set flat 1
			} else {
				set flat 0
			}
			set mindiffy $diff
			set mindiffx [expr abs($x - $xx)]
		} elseif {$diff == $mindiffy} {
			set diff [expr abs($x - $xx)]
			if {$diff < $mindiffx} {
				set mindiffx $diff
				set yyy $yy
				if {[lsearch -exact $flatlist $thisobj] >= 0} {			;#	If the note is flat
					set flat 1
				} else {
					set flat 0
				}
			}
		}
	}
	if {![info exists yyy]} {
		Inf "No Note Found At Mouse Click"
		return
	}
	set thismidi [GetNoteObjectHite [expr int(round($yyy))]]
	if {$thismidi < 0} {
		Inf "Unknown Pitch"
		return
	}
	if {$flat} {
		incr thismidi -1
	}
	set k [lsearch $pm_numidilist $thismidi]
	if {$k < 0} {
		Inf "Unknown Pitch"
		return
	}
	if {[info exists pm_numidilist]} {
		set pm_lastmidilist $pm_numidilist
	} else {
		set pm_lastmidilist {}
	}
	set pm_numidilist [lreplace $pm_numidilist $k $k]
	set pm_numidilist [EliminateDuplicates $pm_numidilist]
	ClearPitchGrafix $w
	InsertPitchGrafix $pm_numidilist $w
	if {[info exists pmgrafix] && ($w == $pmgrafix)} {
		.pmark.d.d.ll.list delete 0 end
		foreach item $pm_numidilist {
			.pmark.d.d.ll.list insert end $item
		}
	}
}

proc GetNuPitchFromMouseClikHite {hite} {
	global shortwindows
	if {[info exists shortwindows]} {
		switch -- $hite {
			20  { return 108 }
			25  { return 107 }
			30  { return 105 }
			35  { return 103 }
			40  { return 101 }
			45  { return 100 }
			50  { return 98	 }
			55  { return 96	 }
			60  { return 95	 }
			65  { return 93	 }
			70  { return 91	 }
			75  { return 89	 }
			80  { return 88	 }
			85  { return 86	 }
			90  { return 84	 }
			140 { return 84	 } 
			145 { return 83	 } 
			150 { return 81	 } 
			155 { return 79	 } 
			160 { return 77	 }
			165 { return 76	 }
			170 { return 74	 }
			175 { return 72	 }
			180 { return 71	 }
			185 { return 69	 }
			190 { return 67	 }
			195 { return 65	 }
			200 { return 64	 }
			205 { return 62	 }
			210 { return 60	 }
			215 { return 59	 }
			220 { return 57	 }
			225 { return 55	 }
			230 { return 53	 }
			235 { return 52	 }
			240 { return 50	 }
			245 { return 48	 } 
			250 { return 47	 } 
			255 { return 45	 }
			260 { return 43	 }
			265 { return 41	 }
			270 { return 40	 }
			275 { return 38	 }
			280 { return 36	 }
			330 { return 36	 }
			335 { return 35	 }
			340 { return 33	 }
			345 { return 31	 }
			350 { return 29	 }
			355 { return 28	 }
			360 { return 26	 } 
			365 { return 24	 }
			370 { return 23	 }
			375 { return 21	 }
			380 { return 19	 }
			385 { return 17	 }
			390 { return 16	 }
			395 { return 14	 }
			400 { return 12	 }
		}
		return -1
	} else {
		switch -- $hite {
			20  { return 108 }
			25  { return 107 }
			30  { return 105 }
			35  { return 103 }
			40  { return 101 }
			45  { return 100 }
			50  { return 98	 }
			55  { return 96	 }
			60  { return 95	 }
			65  { return 93	 }
			70  { return 91	 }
			75  { return 89	 }
			80  { return 88	 }
			85  { return 86	 }
			90  { return 84	 }
			170 { return 84	 } 
			175 { return 83	 } 
			180 { return 81	 } 
			185 { return 79	 } 
			190 { return 77	 }
			195 { return 76	 }
			200 { return 74	 }
			205 { return 72	 }
			210 { return 71	 }
			215 { return 69	 }
			220 { return 67	 }
			225 { return 65	 }
			230 { return 64	 }
			235 { return 62	 }
			240 { return 60	 }
			245 { return 59	 }
			250 { return 57	 }
			255 { return 55	 }
			260 { return 53	 }
			265 { return 52	 }
			270 { return 50	 }
			275 { return 48	 } 
			280 { return 47	 } 
			285 { return 45	 }
			290 { return 43	 }
			295 { return 41	 }
			300 { return 40	 }
			305 { return 38	 }
			310 { return 36	 }
			390 { return 36	 }
			395 { return 35	 }
			400 { return 33	 }
			405 { return 31	 }
			410 { return 29	 }
			415 { return 28	 }
			420 { return 26	 } 
			425 { return 24	 }
			430 { return 23	 }
			435 { return 21	 }
			440 { return 19	 }
			445 { return 17	 }
			450 { return 16	 }
			455 { return 14	 }
			460 { return 12	 }
		}
		return -1
	}
}

proc GetNoteObjectHite {hite} {
	global shortwindows
	if {[info exists shortwindows]} {
		switch -- $hite {
			17  { return 108 }
			22  { return 107 }
			27  { return 105 }
			32  { return 103 }
			37  { return 101 }
			42  { return 100 }
			47  { return 98  }
			52  { return 96  }
			57  { return 95  }
			62  { return 93  }
			67  { return 91  }
			72  { return 89  }
			77  { return 88  }
			82  { return 86  }
			87	{ return 84  }
			142 { return 83  }
			147 { return 81  }
			152 { return 79  }
			157 { return 77  }
			162 { return 76  }
			167 { return 74  }
			172 { return 72  }
			177 { return 71  }
			182 { return 69  }
			187 { return 67  }
			192 { return 65  }
			197 { return 64  }
			202 { return 62  }
			207 { return 60  }
			212 { return 59  }
			217 { return 57  }
			222 { return 55  }
			227 { return 53  }
			232 { return 52  }
			237 { return 50  }
			242 { return 48  }
			247 { return 47  }
			252 { return 45  }
			257 { return 43  }
			262 { return 41  }
			267 { return 40  }
			272 { return 38  }
			277 { return 36  }
			332 { return 35  }
			337 { return 33  }
			342 { return 31  }
			347 { return 29  }
			352 { return 28  }
			357 { return 26  }
			362 { return 24  }
			367 { return 23  }
			372 { return 21  }
			377 { return 19  }
			382 { return 17  }
			387 { return 16  }
			392 { return 14  }
			397 { return 12  }
		}
		return -1
	} else {
		switch -- $hite {
			17  { return 108 }
			22  { return 107 }
			27  { return 105 }
			32  { return 103 }
			37  { return 101 }
			42  { return 100 }
			47  { return 98  }
			52  { return 96  }
			57  { return 95  }
			62  { return 93  }
			67  { return 91  }
			72  { return 89  }
			77  { return 88  }
			82  { return 86  }
			87	{ return 84  }
			172 { return 83  }
			177 { return 81  }
			182 { return 79  }
			187 { return 77  }
			192 { return 76  }
			197 { return 74  }
			202 { return 72  }
			207 { return 71  }
			212 { return 69  }
			217 { return 67  }
			222 { return 65  }
			227 { return 64  }
			232 { return 62  }
			237 { return 60  }
			242 { return 59  }
			247 { return 57  }
			252 { return 55  }
			257 { return 53  }
			262 { return 52  }
			267 { return 50  }
			272 { return 48  }
			277 { return 47  }
			282 { return 45  }
			287 { return 43  }
			292 { return 41  }
			297 { return 40  }
			302 { return 38  }
			307 { return 36  }
			392 { return 35  }
			397 { return 33  }
			402 { return 31  }
			407 { return 29  }
			412 { return 28  }
			417 { return 26  }
			422 { return 24  }
			427 { return 23  }
			432 { return 21  }
			437 { return 19  }
			442 { return 17  }
			447 { return 16  }
			452 { return 14  }
			457 { return 12  }
		}
		return -1
	}
}

proc Pmtrans {on} {
	global pm_semit pm_key pm_mode pm_zz0 evv

	if {$on} {
		.pbank_pitches.0.c5.by config -text "By"
		if {$pm_key || ($pm_mode == 11)} {
			.pbank_pitches.0.c5.sem config -text "Scale Steps"
		} else {
			.pbank_pitches.0.c5.sem config -text "Semitones"
		}
		.pbank_pitches.0.c5.e config -bd 2 -state normal -bg $evv(EMPH)
		set pm_semit "??"
		focus .pbank_pitches.0.c5.e
		.pbank_pitches.0.c7.doit config -text "Do It" -bd 4 -state normal -bg $evv(EMPH)
	} else {
		set pm_zz0 0
		set pm_semit ""
		.pbank_pitches.0.c5.by config -text ""
		.pbank_pitches.0.c5.sem config -text ""
		.pbank_pitches.0.c5.e config -bd 0 -state disabled -bg [option get . background {}]
	}
}

proc PmInvert {on} {
	global pm_invtype pm_zz0 evv

	if {$on} {
		.pbank_pitches.0.c6.abs config -text "In Place" -state normal
		.pbank_pitches.0.c6.up config -text "Around Bass" -state normal
		.pbank_pitches.0.c6.dn config -text "Around Top" -state normal
		.pbank_pitches.0.c7.doit config -text "Do It" -bd 4 -state normal -bg $evv(EMPH)
		set pm_invtype 1
	} else {
		set pm_invtype 0
		set pm_zz0 0
		.pbank_pitches.0.c6.di config -text ""
		.pbank_pitches.0.c6.abs config -text "" -state disabled
		.pbank_pitches.0.c6.up config -text "" -state disabled
		.pbank_pitches.0.c6.dn config -text "" -state disabled
	}
}

proc Set_PmKey2 {} {
	global pm_inkey
	Set_PmKey [expr $pm_inkey]
}

proc Set_PmKey {on} {
	global pm_key pm_inkey pm_mode
	switch -- $on {
		0 - 
		-1 {
			set pm_key 0
			Dehilite_PmKey
			.pbank_pitches.0.c1.c  config -state disabled -text "c"	
			.pbank_pitches.0.c1.cc config -state disabled -text "c#/db"
			.pbank_pitches.0.c1.d  config -state disabled -text "d"	
			.pbank_pitches.0.c1.dd config -state disabled -text "d#/eb"
			.pbank_pitches.0.c1.e  config -state disabled -text "e"	
			.pbank_pitches.0.c1.f  config -state disabled -text "f"	
			.pbank_pitches.0.c1.ff config -state disabled -text "f#/gb"
			.pbank_pitches.0.c1.g  config -state disabled -text "g"	
			.pbank_pitches.0.c1.gg config -state disabled -text "g#/ab"
			.pbank_pitches.0.c1.a  config -state disabled -text "a"	
			.pbank_pitches.0.c1.aa config -state disabled -text "a#/bb"
			.pbank_pitches.0.c1.b  config -state disabled -text "b"	
			set pm_mode $on
			.pbank_pitches.0.c2.maj  config -state disabled -text ""
			.pbank_pitches.0.c2.min  config -state disabled -text ""
			.pbank_pitches.0.c2.amm  config -state disabled -text ""
			.pbank_pitches.0.c2.dmm  config -state disabled -text ""
			.pbank_pitches.0.c3.dor  config -state disabled -text ""
			.pbank_pitches.0.c3.phr  config -state disabled -text ""
			.pbank_pitches.0.c3.lyd  config -state disabled -text ""
			.pbank_pitches.0.c3.mix  config -state disabled -text ""
			.pbank_pitches.0.c3.aeo  config -state disabled -text ""
			.pbank_pitches.0.c3.ion  config -state disabled -text ""
			if {[string length [.pbank_pitches.0.c5.sem cget -text]] > 0} {
				.pbank_pitches.0.c5.sem config -text "Semitones"
			}
		}
		1 {
			.pbank_pitches.0.c1.c  config -state normal -text "C"	
			.pbank_pitches.0.c1.cc config -state normal -text "C#/Db"
			.pbank_pitches.0.c1.d  config -state normal -text "D"	
			.pbank_pitches.0.c1.dd config -state normal -text "D#/Eb"
			.pbank_pitches.0.c1.e  config -state normal -text "E"	
			.pbank_pitches.0.c1.f  config -state normal -text "F"	
			.pbank_pitches.0.c1.ff config -state normal -text "F#/Gb"
			.pbank_pitches.0.c1.g  config -state normal -text "G"	
			.pbank_pitches.0.c1.gg config -state normal -text "G#/Ab"
			.pbank_pitches.0.c1.a  config -state normal -text "A"	
			.pbank_pitches.0.c1.aa config -state normal -text "A#/Bb"
			.pbank_pitches.0.c1.b  config -state normal -text "B"	
			set pm_mode -1
			.pbank_pitches.0.c2.maj  config -state normal -text "major"
			.pbank_pitches.0.c2.min  config -state normal -text "harmonic minor"
			.pbank_pitches.0.c2.amm  config -state normal -text "ascending melodic minor"
			.pbank_pitches.0.c2.dmm  config -state normal -text "descending melodic minor"
			.pbank_pitches.0.c3.dor  config -state normal -text "dorian"
			.pbank_pitches.0.c3.phr  config -state normal -text "phrygian"
			.pbank_pitches.0.c3.lyd  config -state normal -text "lydian"
			.pbank_pitches.0.c3.mix  config -state normal -text "mixolydian"
# RWD 2023 corrected assignment
			.pbank_pitches.0.c3.ion  config -state normal -text "ionian" 
			.pbank_pitches.0.c3.aeo  config -state normal -text "aeolian"
			if {[string length [.pbank_pitches.0.c5.sem cget -text]] > 0} {
				.pbank_pitches.0.c5.sem config -text "Scale Steps"
			}
		}
	}
}

proc Dehilite_PmKey {} {
	.pbank_pitches.0.c1.c  config -bg [option get . background {}] -text "c"	
	.pbank_pitches.0.c1.cc config -bg [option get . background {}] -text "c#/db"
	.pbank_pitches.0.c1.d  config -bg [option get . background {}] -text "d"	
	.pbank_pitches.0.c1.dd config -bg [option get . background {}] -text "d#/eb"
	.pbank_pitches.0.c1.e  config -bg [option get . background {}] -text "e"	
	.pbank_pitches.0.c1.f  config -bg [option get . background {}] -text "f"	
	.pbank_pitches.0.c1.ff config -bg [option get . background {}] -text "f#/gb"
	.pbank_pitches.0.c1.g  config -bg [option get . background {}] -text "g"	
	.pbank_pitches.0.c1.gg config -bg [option get . background {}] -text "g#/ab"
	.pbank_pitches.0.c1.a  config -bg [option get . background {}] -text "a"	
	.pbank_pitches.0.c1.aa config -bg [option get . background {}] -text "a#/bb"
	.pbank_pitches.0.c1.b  config -bg [option get . background {}] -text "b"	
}

proc Hilite_PmKey {val} {
	global evv
	Dehilite_PmKey 
	switch -- $val {
		"c"	 { .pbank_pitches.0.c1.c  config -bg $evv(EMPH) -text "C"	 }
		"cc" { .pbank_pitches.0.c1.cc config -bg $evv(EMPH) -text "C#/Db"}
		"d"  { .pbank_pitches.0.c1.d  config -bg $evv(EMPH) -text "D"	 }
		"dd" { .pbank_pitches.0.c1.dd config -bg $evv(EMPH) -text "D#/Eb"}
		"e"  { .pbank_pitches.0.c1.e  config -bg $evv(EMPH) -text "E"	 }
		"f"  { .pbank_pitches.0.c1.f  config -bg $evv(EMPH) -text "F"	 }
		"ff" { .pbank_pitches.0.c1.ff config -bg $evv(EMPH) -text "F#/Gb"}
		"g"  { .pbank_pitches.0.c1.g  config -bg $evv(EMPH) -text "G"	 }
		"gg" { .pbank_pitches.0.c1.gg config -bg $evv(EMPH) -text "G#/Ab"}
		"a"  { .pbank_pitches.0.c1.a  config -bg $evv(EMPH) -text "A"	 }
		"aa" { .pbank_pitches.0.c1.aa config -bg $evv(EMPH) -text "A#/Bb"}
		"b"  { .pbank_pitches.0.c1.b  config -bg $evv(EMPH) -text "B"	 }
	}
}

proc Hilite_PmAction {action} {
	global evv
	DeHilite_PmAction
	switch -- $action {
		"transpose" {
			.pbank_pitches.0.c.tra config -bg $evv(EMPH)
		}
		"transpose+" {
			.pbank_pitches.0.c.trz config -bg $evv(EMPH)
		}
		"mode" {
			.pbank_pitches.0.c.mod config -bg $evv(EMPH)
		}
		"invert" {
			.pbank_pitches.0.c.inv config -bg $evv(EMPH)
		}
		"complement" {
			.pbank_pitches.0.c.com config -bg $evv(EMPH)
		}
		"rotup" {
			.pbank_pitches.0.c8.rup config -bg $evv(EMPH)
		}
		"rotdn" {
			.pbank_pitches.0.c8.rdn config -bg $evv(EMPH)
		}
		"contract" {
			.pbank_pitches.0.c8.sqz config -bg $evv(EMPH)
		}
		"contract_chord" {
			.pbank_pitches.0.c8.sqc config -bg $evv(EMPH)
		}
		"spread" {
			.pbank_pitches.0.c8.spr config -bg $evv(EMPH)
		}
		"last" {
			.pbank_pitches.0.d.pre config -bg $evv(EMPH)
		}
		"restore" {
			.pbank_pitches.0.d.res config -bg $evv(EMPH)
		}
	}
}

proc DeHilite_PmAction {} {
	.pbank_pitches.0.c.tra  config -bg [option get . background {}]
	.pbank_pitches.0.c.trz  config -bg [option get . background {}]
	.pbank_pitches.0.c.mod  config -bg [option get . background {}]
	.pbank_pitches.0.c.inv  config -bg [option get . background {}]
	.pbank_pitches.0.c.com  config -bg [option get . background {}]
	.pbank_pitches.0.c8.rup config -bg [option get . background {}]
	.pbank_pitches.0.c8.rdn config -bg [option get . background {}]
	.pbank_pitches.0.c8.sqz config -bg [option get . background {}]
	.pbank_pitches.0.c8.sqc config -bg [option get . background {}]
	.pbank_pitches.0.c8.spr config -bg [option get . background {}]
	.pbank_pitches.0.d.pre config -bg [option get . background {}]
	.pbank_pitches.0.d.res config -bg [option get . background {}]
}

proc Remember_PmKey {} {
	global pmkey_memory pmkey pm_key pm_inkey pm_mode pm_invtype
	catch {unset pmkey_memory}
	lappend pmkey_memory [.pbank_pitches.0.c1.c cget -state]
	lappend pmkey_memory [.pbank_pitches.0.c1.c cget -bg]
	lappend pmkey_memory [.pbank_pitches.0.c1.c cget -text]
	lappend pmkey_memory [.pbank_pitches.0.c1.cc cget -state]
	lappend pmkey_memory [.pbank_pitches.0.c1.cc cget -bg]
	lappend pmkey_memory [.pbank_pitches.0.c1.cc cget -text]
	lappend pmkey_memory [.pbank_pitches.0.c1.d  cget -state]
	lappend pmkey_memory [.pbank_pitches.0.c1.d  cget -bg]
	lappend pmkey_memory [.pbank_pitches.0.c1.d  cget -text]
	lappend pmkey_memory [.pbank_pitches.0.c1.dd cget -state]
	lappend pmkey_memory [.pbank_pitches.0.c1.dd cget -bg]
	lappend pmkey_memory [.pbank_pitches.0.c1.dd cget -text]
	lappend pmkey_memory [.pbank_pitches.0.c1.e  cget -state]
	lappend pmkey_memory [.pbank_pitches.0.c1.e  cget -bg]
	lappend pmkey_memory [.pbank_pitches.0.c1.e  cget -text]
	lappend pmkey_memory [.pbank_pitches.0.c1.f  cget -state]
	lappend pmkey_memory [.pbank_pitches.0.c1.f  cget -bg]
	lappend pmkey_memory [.pbank_pitches.0.c1.f  cget -text]
	lappend pmkey_memory [.pbank_pitches.0.c1.ff cget -state]
	lappend pmkey_memory [.pbank_pitches.0.c1.ff cget -bg]
	lappend pmkey_memory [.pbank_pitches.0.c1.ff cget -text]
	lappend pmkey_memory [.pbank_pitches.0.c1.g  cget -state]
	lappend pmkey_memory [.pbank_pitches.0.c1.g  cget -bg]
	lappend pmkey_memory [.pbank_pitches.0.c1.g  cget -text]
	lappend pmkey_memory [.pbank_pitches.0.c1.gg cget -state]
	lappend pmkey_memory [.pbank_pitches.0.c1.gg cget -bg]
	lappend pmkey_memory [.pbank_pitches.0.c1.gg cget -text]
	lappend pmkey_memory [.pbank_pitches.0.c1.a  cget -state]
	lappend pmkey_memory [.pbank_pitches.0.c1.a  cget -bg]
	lappend pmkey_memory [.pbank_pitches.0.c1.a  cget -text]
	lappend pmkey_memory [.pbank_pitches.0.c1.aa cget -state]
	lappend pmkey_memory [.pbank_pitches.0.c1.aa cget -bg]
	lappend pmkey_memory [.pbank_pitches.0.c1.aa cget -text]
	lappend pmkey_memory [.pbank_pitches.0.c1.b  cget -state]
	lappend pmkey_memory [.pbank_pitches.0.c1.b  cget -bg]
	lappend pmkey_memory [.pbank_pitches.0.c1.b  cget -text]
	lappend pmkey_memory [.pbank_pitches.0.c2.maj  cget -state]
	lappend pmkey_memory [.pbank_pitches.0.c2.maj  cget -text]
	lappend pmkey_memory [.pbank_pitches.0.c2.min  cget -state]
	lappend pmkey_memory [.pbank_pitches.0.c2.min  cget -text]
	lappend pmkey_memory [.pbank_pitches.0.c2.amm  cget -state]
	lappend pmkey_memory [.pbank_pitches.0.c2.amm  cget -text]
	lappend pmkey_memory [.pbank_pitches.0.c2.dmm  cget -state]
	lappend pmkey_memory [.pbank_pitches.0.c2.dmm  cget -text]
	lappend pmkey_memory [.pbank_pitches.0.c3.dor  cget -state]
	lappend pmkey_memory [.pbank_pitches.0.c3.dor  cget -text]
	lappend pmkey_memory [.pbank_pitches.0.c3.phr  cget -state]
	lappend pmkey_memory [.pbank_pitches.0.c3.phr  cget -text]
	lappend pmkey_memory [.pbank_pitches.0.c3.lyd  cget -state]
	lappend pmkey_memory [.pbank_pitches.0.c3.lyd  cget -text]
	lappend pmkey_memory [.pbank_pitches.0.c3.mix  cget -state]
	lappend pmkey_memory [.pbank_pitches.0.c3.mix  cget -text]
	lappend pmkey_memory [.pbank_pitches.0.c3.aeo  cget -state]
	lappend pmkey_memory [.pbank_pitches.0.c3.aeo  cget -text]
	lappend pmkey_memory [.pbank_pitches.0.c3.ion  cget -state]
	lappend pmkey_memory [.pbank_pitches.0.c3.ion  cget -text]
	lappend pmkey_memory [.pbank_pitches.0.c4.cur  cget -state]
	lappend pmkey_memory [.pbank_pitches.0.c4.cur  cget -text]
	lappend pmkey_memory [.pbank_pitches.0.c4.set  cget -state]
	lappend pmkey_memory [.pbank_pitches.0.c4.set  cget -text]
	lappend pmkey_memory [.pbank_pitches.0.c4.non  cget -state]
	lappend pmkey_memory [.pbank_pitches.0.c4.non  cget -text]
	lappend pmkey_memory [.pbank_pitches.0.c5.sem  cget -text]
	lappend pmkey_memory $pm_mode
	lappend pmkey_memory $pm_inkey
	lappend pmkey_memory $pm_key
}

proc Restore_PmKey {} {
	global pmkey_memory pm_key pm_inkey pm_mode pm_invtype
	.pbank_pitches.0.c1.c config -state [lindex $pmkey_memory 0]
	.pbank_pitches.0.c1.c config -bg [lindex $pmkey_memory 1]
	.pbank_pitches.0.c1.c config -text [lindex $pmkey_memory 2]
	.pbank_pitches.0.c1.cc config -state [lindex $pmkey_memory 3]
	.pbank_pitches.0.c1.cc config -bg [lindex $pmkey_memory 4]
	.pbank_pitches.0.c1.cc config -text [lindex $pmkey_memory 5]
	.pbank_pitches.0.c1.d  config -state [lindex $pmkey_memory 6]
	.pbank_pitches.0.c1.d  config -bg [lindex $pmkey_memory 7]
	.pbank_pitches.0.c1.d  config -text [lindex $pmkey_memory 8]
	.pbank_pitches.0.c1.dd config -state [lindex $pmkey_memory 9]
	.pbank_pitches.0.c1.dd config -bg [lindex $pmkey_memory 10]
	.pbank_pitches.0.c1.dd config -text [lindex $pmkey_memory 11]
	.pbank_pitches.0.c1.e  config -state [lindex $pmkey_memory 12]
	.pbank_pitches.0.c1.e  config -bg [lindex $pmkey_memory 13]
	.pbank_pitches.0.c1.e  config -text [lindex $pmkey_memory 14]
	.pbank_pitches.0.c1.f  config -state [lindex $pmkey_memory 15]
	.pbank_pitches.0.c1.f  config -bg [lindex $pmkey_memory 16]
	.pbank_pitches.0.c1.f  config -text [lindex $pmkey_memory 17]
	.pbank_pitches.0.c1.ff config -state [lindex $pmkey_memory 18]
	.pbank_pitches.0.c1.ff config -bg [lindex $pmkey_memory 19]
	.pbank_pitches.0.c1.ff config -text [lindex $pmkey_memory 20]
	.pbank_pitches.0.c1.g  config -state [lindex $pmkey_memory 21]
	.pbank_pitches.0.c1.g  config -bg [lindex $pmkey_memory 22]
	.pbank_pitches.0.c1.g  config -text [lindex $pmkey_memory 23]
	.pbank_pitches.0.c1.gg config -state [lindex $pmkey_memory 24]
	.pbank_pitches.0.c1.gg config -bg [lindex $pmkey_memory 25]
	.pbank_pitches.0.c1.gg config -text [lindex $pmkey_memory 26]
	.pbank_pitches.0.c1.a  config -state [lindex $pmkey_memory 27]
	.pbank_pitches.0.c1.a  config -bg [lindex $pmkey_memory 28]
	.pbank_pitches.0.c1.a  config -text [lindex $pmkey_memory 29]
	.pbank_pitches.0.c1.aa config -state [lindex $pmkey_memory 30]
	.pbank_pitches.0.c1.aa config -bg [lindex $pmkey_memory 31]
	.pbank_pitches.0.c1.aa config -text [lindex $pmkey_memory 32]
	.pbank_pitches.0.c1.b  config -state [lindex $pmkey_memory 33]
	.pbank_pitches.0.c1.b  config -bg [lindex $pmkey_memory 34]
	.pbank_pitches.0.c1.b  config -text [lindex $pmkey_memory 35]
	.pbank_pitches.0.c2.maj config -state [lindex $pmkey_memory 36]
	.pbank_pitches.0.c2.maj config -text [lindex $pmkey_memory 37]
	.pbank_pitches.0.c2.min config -state [lindex $pmkey_memory 38]
	.pbank_pitches.0.c2.min config -text [lindex $pmkey_memory 39]
	.pbank_pitches.0.c2.amm config -state [lindex $pmkey_memory 40]
	.pbank_pitches.0.c2.amm config -text [lindex $pmkey_memory 41]
	.pbank_pitches.0.c2.dmm config -state [lindex $pmkey_memory 42]
	.pbank_pitches.0.c2.dmm config -text [lindex $pmkey_memory 43]
	.pbank_pitches.0.c3.dor config -state [lindex $pmkey_memory 44]
	.pbank_pitches.0.c3.dor config -text [lindex $pmkey_memory 45]
	.pbank_pitches.0.c3.phr config -state [lindex $pmkey_memory 46]
	.pbank_pitches.0.c3.phr config -text [lindex $pmkey_memory 47]
	.pbank_pitches.0.c3.lyd config -state [lindex $pmkey_memory 48]
	.pbank_pitches.0.c3.lyd config -text [lindex $pmkey_memory 49]
	.pbank_pitches.0.c3.mix config -state [lindex $pmkey_memory 50]
	.pbank_pitches.0.c3.mix config -text [lindex $pmkey_memory 51]
	.pbank_pitches.0.c3.aeo config -state [lindex $pmkey_memory 52]
	.pbank_pitches.0.c3.aeo config -text [lindex $pmkey_memory 53]
	.pbank_pitches.0.c3.ion config -state [lindex $pmkey_memory 54]
	.pbank_pitches.0.c3.ion config -text [lindex $pmkey_memory 55]
	.pbank_pitches.0.c4.cur config -state [lindex $pmkey_memory 56]
	.pbank_pitches.0.c4.cur config -text [lindex $pmkey_memory 57]
	.pbank_pitches.0.c4.set config -state [lindex $pmkey_memory 58]
	.pbank_pitches.0.c4.set config -text [lindex $pmkey_memory 59]
	.pbank_pitches.0.c4.non config -state [lindex $pmkey_memory 60]
	.pbank_pitches.0.c4.non config -text [lindex $pmkey_memory 61]
	.pbank_pitches.0.c5.sem config -text  [lindex $pmkey_memory 62]
	set pm_mode [lindex $pmkey_memory 63]
	set pm_inkey [lindex $pmkey_memory 64]
	set pm_key [lindex $pmkey_memory 65]
	if {$pm_key} {
		set pm_inkey 1
	}
	unset pmkey_memory
}

proc Pmdo {what} {
	global pm_dowhat pmkey_memory pm_inkey pm_key pm_dowhat pm_semit pm_invtype pm_last_invtype evv 
	switch -- $what {
		"rotup" -
		"rotdn" -
		"last" -
		"restore" -
		"spread" -
		"contract_chord" -
		"contract" {
			Pmtrans 0
			PmInvert 0
			.pbank_pitches.0.c7.doit config -text "" -bd 0 -state disabled -bg [option get . background {}]
			if {![info exists pmkey_memory]} {
				Remember_PmKey
			}
			set pm_inkey 0
			Set_PmKey -1
			Hilite_PmAction $what
			set pm_dowhat $what
			Pmdoit
		}
		default {
			Hilite_PmAction $what
			if {[info exists pmkey_memory]} {
				Restore_PmKey
			}
			if {($what == "transpose") || ($what == "transpose+")} {
				Pmtrans 1
				PmInvert 0
			} else {
				Pmtrans 0
			}
			if {$what == "invert"} {
				PmInvert 1
				if {[info exists pm_last_invtype]} {
					set pm_invtype $pm_last_invtype 
				}
				Pmtrans 0
			} else {
				PmInvert 0
			}
			if {$pm_key} {
				set pm_inkey 1
			}
			.pbank_pitches.0.c7.doit config -text "Do It" -bd 4 -state normal -bg $evv(EMPH)
			set pm_dowhat $what
		}
	}
}

proc Pmdoit {} {
	global pm_dowhat pm_midilist pm_numidilist pm_lastmidilist pm_key pm_inkey pm_mode 
	global pm_invtype pm_template pm_semit pm_zz0 pm_lastaction pbankgrafix
	global pm_last_invtype evv

	if {([llength $pm_numidilist] <= 0) && ($pm_dowhat != "restore") && ($pm_dowhat != "last")} {
		Inf "No Pitches To Work On"
		return
	}
	set ok 1
	switch -- $pm_dowhat {
		"transpose+" -
		"transpose" {
			set pm_semit [string trim $pm_semit]
			if {[string length $pm_semit] <= 0} {
				Inf "No Transposition Value Entered"
				return
			} elseif {![regexp {^[0-9\-]+$} $pm_semit] || ![IsNumeric $pm_semit]} {
				Inf "Invalid Transposition Value: Must Be Whole Number Of Semitones"
				return
			}
			if {$pm_key} {
				set pm_inkey 1
				if {$pm_mode <= 0} {
					Inf "Must Specify Major,minor or Mode, If A Key Is Specified For This Operation"
					return
				}
			} else {
				set pm_inkey 0
			}
			if {$pm_key || ($pm_mode == 11)} {
				set modelist [MapToMode $pm_numidilist]
				if {[llength $modelist] <= 0} {
					set ok 0
				}
				set thislist $modelist
			} else {
				set thislist $pm_numidilist
			}
			if {$ok} {
				foreach val $thislist {
					set qq [expr int(round($val + $pm_semit))]
					if {$pm_key || ($pm_mode == 11)} {
						set qq [InverseModeMap $qq]
					}
					if {($qq > $evv(MAX_TONAL)) || ($qq < $evv(MIN_TONAL))} {
						Inf "Cannot Graphically Represent MIDI Vals Below $evv(MIN_TONAL) Or Above $evv(MAX_TONAL)" 
						set ok 0
						break
					}
					lappend zz $qq
				}
				if {$ok} {
					set pm_lastmidilist $pm_numidilist
					if {$pm_dowhat == "transpose+"} {
						set zz [concat $zz $pm_numidilist]
						set zz [lsort -integer -increasing $zz]
						set pm_numidilist [EliminateDuplicates $zz]
					} else {
						set pm_numidilist [lsort -integer -increasing $zz]
					}
				}
			}
		}
		"mode" {
			if {!$pm_key} {
				Inf "Must Specify A Key, For This Operation"
				set pm_inkey 0
				return
			} elseif {$pm_mode < 1 || $pm_mode > 4} {
				Inf "Must Specify Major or Minor, For This Operation"
				return
			} else {
				set zz [PmChangeMode]
				if {[llength $zz] > 0} {
					set pm_lastmidilist $pm_numidilist
					set pm_numidilist [lsort -integer -increasing $zz]
				} else {
					set ok 0
				}
			}
		}
		"invert" {
			if {$pm_invtype <= 0} {
				Inf "Inversion Type Not Selected" 
				return
			} elseif {$pm_key} {
				set pm_inkey 1
				if {$pm_mode <= 0} {
					Inf "Must Specify Major,minor or Mode, If A Key Is Specified For This Operation"
					return
				} 
			} else {
				set pm_inkey 0
			}
			if {$pm_key || ($pm_mode == 11)} {
				set modelist [MapToMode $pm_numidilist]
				if {[llength $modelist] <= 0} {
					set ok 0
				}
				set thislist $modelist
			} else {
				set thislist $pm_numidilist
			}
			if {$ok} {
				set lastval [lindex $thislist 0]
				foreach val [lrange $thislist 1 end] {
					lappend ints [expr $val - $lastval]
					set lastval $val
				}
				switch -- $pm_invtype {
					1 {
						set val [lindex $thislist end]
						if {$pm_key || ($pm_mode == 11)} {
							set kval $val
							set val [InverseModeMap $kval]
						}
					}
					2 {
						set val [lindex $thislist 0]
						if {$pm_key || ($pm_mode == 11)} {
							set kval $val
							set val [InverseModeMap $kval]
						}
					}
					3 {
						set val [lindex $thislist end]
						set range [expr $val - [lindex $thislist 0]]
						incr val $range
						if {$pm_key || ($pm_mode == 11)} {
							set kval $val
							set val [InverseModeMap $kval]
						}
						if {$val > $evv(MAX_TONAL)} {
							Inf "Out Of Range"
							set ok 0
						}
					}
				}
				if {$ok} {
					set zz $val
					foreach int $ints {
						if {$pm_key || ($pm_mode == 11)} {
							set kval [expr $kval - $int]
							set val [InverseModeMap $kval]
						} else {
							set val [expr $val - $int]
						}
						if {$val < $evv(MIN_TONAL)} {
							Inf "Out Of Range"
							set ok 0
							break
						}
						lappend zz $val
					}
					if {$ok} {
						set pm_lastmidilist $pm_numidilist
						set pm_numidilist [lsort -integer -increasing $zz]
					}
					set pm_last_invtype $pm_invtype
				}
			}				
		}
		"complement" {
			if {$pm_key || ($pm_mode == 11)} {
				if {$pm_mode <= 0} {
					Inf "Must Specify Major, Minor or Mode, If A Key Is Specified For This Operation"
					return
				} else {
					set template $pm_template
				}
			} else {
				set template [list 0 1 2 3 4 5 6 7 8 9 10 11]
				set pm_inkey 0
			}
			set klist {}
			foreach val $pm_numidilist {
				set val [expr $val % 12]
				set k [lsearch $template $val]
				if {$k >= 0} {
					if {[lsearch $klist $k] < 0} {
						lappend klist $k
					}
				} else {
					Inf "Notes Do Not Lie In The Designated Key Or Mode"
					return
				}
			}
			set klist [lsort -integer -decreasing $klist]
			foreach k $klist {
				set template [lreplace $template $k $k]
			}
			if {[llength $template] <= 0} {
				Inf "No Other Notes Available"
				set ok 0
			} else {
				set pm_lastmidilist $pm_numidilist
				foreach val $template {
					lappend zz [expr $val + 60]
				}
				set pm_numidilist [lsort -integer -increasing $zz]
			}
		}
		"rotup" {
			set val [lindex $pm_numidilist 0]
			set maxval [lindex $pm_numidilist end]
			while {$val < $maxval} {
				incr val $evv(MIN_TONAL)
				if {$val > $evv(MAX_TONAL)} {
					Inf "Out Of Range"
					return
				}
			}
			set pm_lastmidilist $pm_numidilist
			set pm_numidilist [lrange $pm_numidilist 1 end]
			lappend pm_numidilist $val
		}
		"rotdn" {
			set val [lindex $pm_numidilist end]
			set minval [lindex $pm_numidilist 0]
			while {$val > $minval} {
				incr val -12
				if {$val < $evv(MIN_TONAL)} {
					Inf "Out Of Range"
					return
				}
			}
			set pm_lastmidilist $pm_numidilist
			set len [llength $pm_numidilist]
			incr len -1
			set pm_numidilist [linsert $pm_numidilist 0 $val]
			set pm_numidilist [lrange $pm_numidilist 0 $len]
		}
		"contract_chord" -
		"contract" {
			set pm_lastmidilist $pm_numidilist
			if {$pm_dowhat == "contract_chord"} {
				set root [expr [lindex $pm_numidilist 0] % 12]
				set nulist $root
				foreach val [lrange $pm_numidilist 1 end] {
					set val [expr $val % 12]
					if {$val < $root} {
						incr val 12
					}
					lappend nulist $val
				}
				set pm_numidilist $nulist
			} else {
				set nulist {}
				set n 0
				set minrange 128
				while {$n < 12} {
					set val [expr ([lindex $pm_numidilist 0] + $n) % 12]
					set nuvals $val
					set maxval $val
					set minval $val
					foreach val [lrange $pm_numidilist 1 end] {
						set val [expr ($val + $n) % 12]
						lappend nuvals $val
						if {$val > $maxval} {
							set maxval $val
						}
						if {$val < $minval} {
							set minval $val
						}
					}
					set range [expr $maxval - $minval]
					if {$range  < $minrange} {
						set minrange $range
						set wanted $nuvals
						set wanted_n $n
					}
					incr n
				}
				set transpos [expr [lindex $pm_numidilist 0] - [lindex $wanted 0]]
				set pm_numidilist {}
				set finished 0
				set redo 0
				while {!$finished} {
					foreach val $wanted {
						set val [expr $val + $transpos]
						if {$val > $evv(MAX_TONAL)} {
							set redo -1
							break
						} elseif {$val < 12} {
							set redo 1
							break
						} else {
							if {[lsearch $pm_numidilist $val] < 0} {
								lappend pm_numidilist $val
							}
						}
					}
					if {$redo == 0} {
						set finished 1
					} else {
						 set pm_numidilist {}
						 set transpos [expr $transpos + ($redo * 12)]
					}
				}
			}
			set pm_numidilist [lsort -integer -increasing $pm_numidilist]				
			set transposall 0						;# CENTRE OUTPUT IN MIDI REGISTER
			set footgap [expr [lindex $pm_numidilist 0] - $evv(MIN_TONAL)]
			set topgap [expr $evv(MAX_TONAL) - [lindex $pm_numidilist end]]
			if {$topgap > $footgap} {				;#	SHOULD BE NEAREST TO  BOTTOM BY NATURE OF PITCHSET'S CONSTRUCTION
				set lastdiff [expr abs($footgap - $topgap)]
				while {$topgap >= 0} {
					incr footgap 12
					incr topgap -12
					if {$topgap < 0} {
						break
					}
					set diff [expr abs($footgap - $topgap)]
					if {$diff >= $lastdiff} {
						break
					}
					set lastdiff $diff
					incr transposall 12
				}
			}
			if {$transposall > 0} {
				set nulist {}
				foreach val $pm_numidilist {
					incr val $transposall
					lappend nulist $val
				}
				set pm_numidilist $nulist
			}
		}
		"spread" {
			set root [expr [lindex $pm_numidilist 0] % 12]
			set nupitchlist $root
			set intervallist 0
			foreach val [lrange $pm_numidilist 1 end] {
				set val [expr $val % 12]
				if {$val < $root} {
					incr val 12
				}
				set int [expr $val - $root]
				if {[lsearch $intervallist $int] < 0} {
					lappend intervallist $int
				}
			}
			set intervallist [OrderIntList $intervallist]
			set lastpitch $root
			set cnt 0
			set len [llength $intervallist]
			while {$cnt < $len} {
				set int [lindex $intervallist $cnt]
				set pitch [expr $root + $int]
				while {$pitch < $lastpitch} {
					incr pitch 12
				}
				set hi_int  [expr $pitch - $lastpitch]
				if {[info exists half_last_hi_int]} {
					if {($hi_int < $half_last_hi_int) && !([expr $hi_int + 12] > $dbl_last_hi_int)} {
						incr hi_int 12
					}
				}
				set pitch [expr $lastpitch + $hi_int]
				lappend nu_intervallist $hi_int
				set half_last_hi_int [expr (double($hi_int) / 7.0) * 3.0]
				set dbl_last_hi_int  [expr $hi_int * 2]
				lappend nupitchlist $pitch
				set lastpitch $pitch
				incr cnt
			}
			set evv(MIN_PLAYABLE) 31
			while {[lindex $nupitchlist 0] < $evv(MIN_PLAYABLE)} {	
					catch {unset zlist}
					foreach val $nupitchlist {
					incr val 12
					lappend zlist $val
				}
				set nupitchlist $zlist
			}
			set len [llength $nu_intervallist]
			set plen [expr $len + 1]
			set k [expr $len - 1]
			while {[lindex $nupitchlist end] > $evv(MAX_TONAL)} {	;# SHRINK OUTPUT TO FIT IN MIDI REGISTER, IF IT DOESN'T
				if {$k == 0} {
					while {[lindex $nupitchlist end] > $evv(MAX_TONAL)} {
						catch {unset zlist}
						foreach val $nupitchlist {
							incr val -12
							lappend zlist $val
						}
						set nupitchlist $zlist
					}
					if {[lindex $nupitchlist 0] < $evv(MIN_TONAL)} {
						Inf "Scaling Transposition Failed"
						return
					}
				}
				while {$k >= 0} {
					if {[lindex $nu_intervallist $k] > 12} {
						set j $k
						incr j
						while {$j < $plen} {
							set val [expr [lindex $nupitchlist $j] - 12]
							set nupitchlist [lreplace $nupitchlist $j $j $val]
							incr j
						}
						incr k -1
						break
					}
					incr k -1
				}
			}
			set transposall 0						;# CENTRE OUTPUT IN MIDI REGISTER
			set footgap [expr [lindex $nupitchlist 0] - $evv(MIN_PLAYABLE)]
			set topgap [expr $evv(MAX_TONAL) - [lindex $nupitchlist end]]
			if {$topgap > $footgap} {				;#	SHOULD BE NEAREST TO  BOTTOM BY NATURE OF PITCHSET'S CONSTRUCTION
				set lastdiff [expr abs($footgap - $topgap)]
				while {$topgap >= 0} {
					incr footgap 12
					incr topgap -12
					if {$topgap < 0} {
						break
					}
					set diff [expr abs($footgap - $topgap)]
					if {$diff >= $lastdiff} {
						break
					}
					set lastdiff $diff
					incr transposall 12
				}
			}
			set pm_lastmidilist $pm_numidilist
			set pm_numidilist {}
			if {$transposall > 0} {
				foreach val $nupitchlist {
					lappend pm_numidilist [expr $val + $transposall]
				}
			} else {
				set pm_numidilist  $nupitchlist
			}
		}
		"last" {
			set temp $pm_lastmidilist
			set pm_lastmidilist $pm_numidilist
			set pm_numidilist $temp
			
		}
		"restore" {
			set pm_lastmidilist $pm_numidilist
			set pm_numidilist $pm_midilist
			if {[llength $pm_numidilist] <= 0} {
				set pm_mode 0
			}
		}
	}
	if {$ok} {
		ClearPitchGrafix $pbankgrafix
		InsertPitchGrafix $pm_numidilist $pbankgrafix
	}
	set pm_lastaction [list $pm_dowhat $pm_key $pm_mode $pm_invtype $pm_semit]
	DeHilite_PmAction
	Pmtrans 0
	PmInvert 0
	set pm_zz0 0
	.pbank_pitches.0.c7.doit config -text "" -bd 0 -state disabled -bg [option get . background {}]
}

proc EliminateDuplicates {zz} {
	set len [llength $zz]
	set lenlessone [expr $len - 1]
	set n 0
	set m 1
	set j 2
	while {$n < $lenlessone} {
		if {[lindex $zz $n] == [lindex $zz $m]} {
			if {$n == 0} {
				set newlist	[lrange $zz 1 end]
			} else {
				set newlist [lrange $zz 0 $n]
				if {$j < $len} {
					set newlist [concat $newlist [lrange $zz $j end]]
				}
			}
			set zz $newlist
			incr lenlessone -1
		} else {
			incr j
			incr m
			incr n
		}
	}
	return $zz
}

proc Pm_Again {} {
	global pm_dowhat pm_key pm_mode pm_invtype pm_semit pm_lastaction
	if {![info exists pm_lastaction]} {
		Inf "No Previous Action"
		return
	}
	set pm_dowhat	[lindex $pm_lastaction 0]
	set pm_key		[lindex $pm_lastaction 1]
	set pm_mode		[lindex $pm_lastaction 2]
	set pm_invtype	[lindex $pm_lastaction 3]
	set pm_semit	[lindex $pm_lastaction 4]
	Pmdoit
} 

proc ModeMap {} {
	global pm_template pm_mode pm_key pm_numidilist pm_modelen pm_special_template

	if {$pm_mode <= 0} {
		Inf "No Mode Defined"
		return
	}
	if {($pm_mode == 11) && [info exists pm_special_template]} {
		set pm_template $pm_special_template
	} elseif {($pm_mode == 11) || ($pm_mode == 12)} {
		if {[llength $pm_numidilist] <= 0} {
			if {$pm_mode == 12} {
				Inf "No Notes Entered To Define Mode"
			} else {
				Inf "No Special Mode Defined Yet"
			}
			set pm_mode -1
			return
		}
		set nutemplate {}
		foreach val $pm_numidilist {
			lappend nutemplate [expr $val % 12]
			set nutemplate [EliminateDuplicates $nutemplate]

		}
		set pm_template [lsort -integer -increasing $nutemplate]
		set pm_modelen [llength $pm_template]
		set pm_special_template $pm_template
		set pm_mode 11
	} else {
		if {!$pm_key} {
			Inf "No Key Defined"
			set pm_mode -1
			return
		}
		switch -- $pm_mode {
			1  { set template [list 0 2 4 5 7 9 11] }
			2  { set template [list 0 2 3 5 7 8 11] }
			3  { set template [list 0 2 3 5 7 9 11] }
			4  { set template [list 0 2 3 5 7 8 10] }
			5  { set template [list 0 2 3 5 7 9 10] }
			6  { set template [list 0 1 3 5 7 8 10] }
			7  { set template [list 0 2 4 6 7 9 11] }
			8  { set template [list 0 2 4 5 7 9 10] }
			9  { set template [list 0 2 3 5 7 8 10] }
			10 { set template [list 0 1 3 5 6 8 10] }
		}
		foreach val $template {
			lappend nutemplate [expr ($val + $pm_key - 1) % 12]
		}
		set pm_template [lsort -integer -increasing $nutemplate]
	}
	set pm_modelen [llength $pm_template]
}

proc MapToMode {mlist} {
	global pm_template pm_modelen
	foreach val $mlist {
		set oct [expr $val / 12]
		set val [expr $val % 12]
		set k [lsearch $pm_template $val]
		if {$k < 0} {
			Inf "Chord Does Not Lie In The Key Or Mode Specified"
			return {}
		}
		lappend modelist [expr ($oct * $pm_modelen) + $k]
	}
	return $modelist
}

proc InverseModeMap {kval} {
	global pm_template pm_modelen

	set oct [expr $kval / $pm_modelen]
	set kval [expr $kval % $pm_modelen]
	set kval [lindex $pm_template $kval]
	return [expr $kval + ($oct * 12)]
}

proc InverseModeMapAll {modelist} {
	global pm_template pm_modelen

	foreach kval $modelist {
		set oct [expr $kval / $pm_modelen]
		set kval [expr $kval % $pm_modelen]
		set kval [lindex $pm_template $kval]
		set kval [expr $kval + ($oct * 12)]
		lappend nuvals $kval
	}	
	return $nuvals
}

proc PmChangeMode {} {
	global pm_numidilist pm_mode pm_template
	set orig_pm_mode $pm_mode
	set pm_mode 1
	set ok 0
	while {$pm_mode <= 4} {
		ModeMap
		set ok 1
		foreach val $pm_numidilist {
			set val [expr $val % 12]
			if {[lsearch $pm_template $val] < 0} {
				set ok 0
				break
			}
		}
		if {$ok} {
			set modelist [MapToMode $pm_numidilist]
			if {[llength $modelist] <= 0} {
				set ok 0
				break
			}
			set pm_mode $orig_pm_mode
			ModeMap
			set zz [InverseModeMapAll $modelist]
			break
		}
		incr pm_mode
	}
	set pm_mode $orig_pm_mode
	if {!$ok} {
		Inf "Pitch Set Is Not In The Key Specified"
		return {}
	}
	return $zz
}

proc OrderIntList {intlist} {

	set ipl [list 4 3 7 10 8 9 6 5 2 11 1]	;# INTERVAL PREFERENCE LIST, 3,m3, 5,b7,m6,6,#4,4,2,7,m2
	foreach int $ipl {
		set k [lsearch $intlist $int]
		if {$k > 0} {
			lappend nulist $int
		} else {
			lappend nulist 0
		}
	}
	if {([lindex $nulist 0] > 0) && ([lindex $nulist 1] > 0)} {	;# MAJ + MIN 3rd
		set nulist [MoveValueBy_N_SignigPlacesAndSuffleOthersDown $nulist 1 2]	;# MOVE m3 BY TWO PLACES
	}
	if {(([lindex $nulist 4] > 0) && ([lindex $nulist 5] > 0)) \
	||  (([lindex $nulist 3] > 0) && ([lindex $nulist 5] > 0))} {		;# MAJ + MIN 6th  OR  MAJ 6th + MIN 7th
		set nulist [MoveValueBy_N_SignigPlacesAndSuffleOthersDown $nulist 5 1]	;# MOVE MAJ 6 BY ONE PLACE
	}
	if {([lindex $nulist 3] > 0) && ([lindex $nulist 9] > 0)} {			;# MAJ + MIN 7th
		set nulist [MoveValueBy_N_SignigPlacesAndSuffleOthersDown $nulist 9 1]	;# MOVE MAJ 7 BY ONE PLACE
	}
	set len [llength $nulist]
	set n 0
	while {$n < $len} {													;#	ELIMINATE EMPTY SLOTS
		if {[lindex $nulist $n] == 0} {
			set nulist [lreplace $nulist $n $n]
			incr n -1
			incr len -1
		}
		incr n
	}
	set loint [lindex $nulist 0]

	set lastint [lindex $nulist 0]
	set n 1
	while {$n < $len} {													;# MOVE (upwards) INTERVAL ADJACENT TO ANOTHER ONLY A SEMITONE DIFFERENT
		set thisint [lindex $nulist $n]									;# (WHICH WOULD CREATE m2s IN OUTPUT PITCHSET)
		if {[expr abs($thisint - $lastint)] == 1} {
			set m [expr $n + 1]
			if {$m < $len} {
				set nextint [lindex $nulist $m]
				if {[expr abs($nextint - $thisint)] != 1} {				;# IF NEXT INT NOT semitone AWAY
					set nulist [lreplace $nulist $n $n $nextint]		;# SWAP INTS AROUND
					set nulist [lreplace $nulist $m $m $thisint]
				} else {												;# THERE CAN'T BE MORE THAN 2 INTERVALS, A SEMITONE AWAY FROM ANOTHER
					set k [expr $m + 1]									;# SO MOVE INTERVAL 2 STEPS UP AND SHUFFLE DOWN 2 (NOW) BELOW 
					if {$m < $len} {
						set farint [lindex $nulist $k]
						set nulist [lreplace $nulist $n $n $nextint]
						set nulist [lreplace $nulist $m $m $farint]
						set nulist [lreplace $nulist $k $k $thisint]
					}
				}
			}
		}
		set lastint [lindex $nulist $n]
		incr n
	}
	if {$loint < 8} {				;#	REPLACE SMALL CONCORDANT INTERVALS ABOVE ROOT WITH LARGE ONES
		incr loint 12
		set nulist [lreplace $nulist 0 0 $loint]
	}
	return $nulist
}

proc MoveValueBy_N_SignigPlacesAndSuffleOthersDown {nulist valueat moveby} {

	set listlen [llength $nulist]
	set q [lindex $nulist $valueat]
	set k [expr $valueat + 1] 
	set j 0
	incr moveby -1
	while {$j < $moveby} {
		while {[lindex $nulist $k] == 0} {	;#  SKIP EMPTY ENTRIES
			incr k
			if {$k == $listlen} {
				break
			}
		}
		if {$k < $listlen} {				;# SKIP REAL ENTRY
			incr k
		}
		if {$k == $listlen} {
			break
		}
		incr j
	}
	if {$k == $listlen} {
		lappend nulist $q
	} else {
		while {[lindex $nulist $k] == 0} {	;#  SKIP EMPTY ENTRIES
			incr k
			if {$k == $listlen} {
				lappend nulist $q
				break
			}
		}
		if {$k < $listlen} {				;# SKIP REAL ENTRY
			incr k
			if {$k == $listlen} {
				lappend nulist $q
			} else {
				set nulist [linsert $nulist $k $q]
			}
		}
	}
	set startlist [lrange $nulist 0 [expr $valueat - 1]]
	set endlist   [lrange $nulist [expr $valueat + 1] end]
	set nulist [concat $startlist $endlist]
	return $nulist
}

proc PmImport {} {
	global wl pa pr_inp evv
	set are_bad_midi 0
	foreach fnam [$wl get 0 end] {
		if {($pa($fnam,$evv(MAXNUM)) <= $evv(MAX_TONAL)) && ($pa($fnam,$evv(MINNUM)) >= $evv(MIN_TONAL))} {
			lappend flist $fnam
		}
	}
	if {![info exists flist]} {
		Inf "No (Possible) MIDI Files On The Workspace"
		return
	}
	if {[llength $flist] == 1} {
		set fnam [lindex $flist 0]
		Inf "Getting File '$fnam'"
		PostpPmPitches $fnam
		return
	}
	set f .pm_input
	if [Dlg_Create $f "POSSIBLE MIDI_FILES" "set pr_inp 0" -width 60 -borderwidth $evv(SBDR)] {
		set a [frame $f.a -borderwidth $evv(SBDR)]
		set b [frame $f.b -borderwidth $evv(SBDR)]
		button $a.quit -text Close -command "set pr_inp 0" -highlightbackground [option get . background {}]
		pack $a.quit -side top -pady 2
		Scrolled_Listbox $b.ll -width 60 -height 16 -selectmode single
		pack $b.ll -side top
		pack $a $b -side top
		bind $f.b.ll.list <ButtonRelease-1> {PostPmFile %W ; set pr_inp 1} 
		wm resizable $f 1 1
		bind $f <Return> {set pr_inp 0}
		bind $f <Escape> {set pr_inp 0}
		bind $f <Key-space> {set pr_inp 0}
	}
	$f.b.ll.list delete 0 end
	foreach fnam $flist {
		$f.b.ll.list insert end $fnam
	}
	raise $f
	set pr_inp 0
	My_Grab 0 $f pr_inp
	tkwait variable pr_inp
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc PostPmFile {w} {
	set i [$w curselection]
	if {$i < 0} {
		return
	}
	set fnam [.pm_input.b.ll.list get $i]
	PostpPmPitches $fnam
}

proc PostpPmPitches {fnam} {
	global pm_numidilist pbankgrafix 
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File '$fnam' To Read MIDI Data"
		return 
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
#FEB 2022
		if {[string length $line] <= 0} {
			continue
		} elseif {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		foreach val $line {
			set val [string trim $val]
			if {[string length $val] > 0} {
				lappend midilist $val
			}
		}
	}
	close $zit
	if {![info exists midilist]} {
		Inf "No Data Found In File '$fnam'"
		return
	}
	set midilist [lsort -integer -increasing $midilist]
	ClearPitchGrafix $pbankgrafix
	InsertPitchGrafix $midilist $pbankgrafix
	set pm_numidilist $midilist
}

#########################
# FREE HARMONY WORKSHOP #
#########################

proc PreNTHarmony {} {
	global pr_prent nt_sr nt_bs fhbitsize evv
	set f .prent
	set fhbitsize 16
	if [Dlg_Create $f "SET SRATE" "set pr_prent 0" -borderwidth $evv(SBDR)] {
# RWD new version from TW Feb 23 eliminate bit stuff
		label $f.sll -text "Output sample rate"
		radiobutton $f.sr44 -text 44100 -variable nt_sr -value 0 -command {DoNonTonalHarmony 44100.0 $fhbitsize; set pr_prent 0}
		radiobutton $f.sr48 -text 48000 -variable nt_sr -value 1 -command {DoNonTonalHarmony 48000.0 $fhbitsize; set pr_prent 0}
		radiobutton $f.sr96 -text 96000 -variable nt_sr -value 2 -command {DoNonTonalHarmony 96000.0 $fhbitsize; set pr_prent 0}
		pack $f.sll $f.sr44 $f.sr48 $f.sr96 -side left -padx 2
		set nt_sr -1
		wm resizable $f 1 1
		bind $f <Return> {set pr_prent 0}
		bind $f <Escape> {set pr_prent 0}
		bind $f <Key-space> {set pr_prent 0}
	}
	set finished 0
	set pr_prent 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_prent
	tkwait variable pr_prent
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

#---- Free Harmony Workshop

proc DoNonTonalHarmony {srate bitsize} {
	global pr_nt nt_fftab nt_aftab nt_frqtab nt_amptab nt_partab nt_pftab nt_save nt_clear nt_clall nt_rest nt_restp
	global nt_d nt_q nt_j nt_jj nt_h nt_r nt_bakuphr nt_filtfile_given nt_hcnt nt_g
	global wstk o_nam wl pa evv
	global nt_chordfile nt_newname nt_newfname nt_filtfile nt_dataname nt_indataname nt_transpos nt_orig nt_pprg nt_maxpar

	set nyq [expr $srate / 2.0]
	set nt_filtfile_given 0
	set f .nt
	set nt_orig {}
	if [Dlg_Create $f "CREATE FREE HARMONY" "set pr_nt 0" -borderwidth $evv(SBDR)] {
		set a [frame $f.a]
		set aa [frame $f.aa]
		set aax [frame $f.aax -height 1 -bg $evv(POINT)]
		set bb0 [frame $f.bb0]
		set bb [frame $f.bb]
		set bbx [frame $f.bbx -height 1 -bg $evv(POINT)]
		set bby [frame $f.bby -height 1 -bg $evv(POINT)]
		set b [frame $f.b]
		set d [frame $f.d]
		set dx [frame $f.dx -height 1 -bg $evv(POINT)]
		set cx [frame $f.cx -height 1 -bg $evv(POINT)]
		set c [frame $f.c]
		button $a.qu -text "Close" -command "set pr_nt 0" -highlightbackground [option get . background {}]
		button $a.do -text "Create & Play" -command "set pr_nt 1" -highlightbackground [option get . background {}]
		label $a.dum -text "" -width 10
		button $a.sa -text "Save Output"   -command "set pr_nt 2" -highlightbackground [option get . background {}]
		label $a.ll -text "  With Name "
		entry $a.e -textvariable nt_newname -width 24 -disabledbackground [option get . background {}]
		button $a.sa2 -text "Save Filtdata"   -command "set pr_nt 3" -highlightbackground [option get . background {}]
		label $a.ll2 -text "  With Name "
		entry $a.e2 -textvariable nt_newfname -width 24 -disabledbackground [option get . background {}]
		pack $a.do $a.dum -side left
		pack $a.sa $a.ll $a.e $a.sa2 $a.ll2 $a.e2 -side left
		pack $a.qu -side right
		label $aa.ll -text "SELECT FILE OF FREQS: (may also select \[A\] file of Amps (of each frq) &/or \[B\] file of Partial-Nos paired with partial-amps)" -fg $evv(SPECIAL)
		pack $aa.ll -side left
		label $bb0.dll -text "Duration (0.2 - 7200 secs)"
		entry $bb0.de -textvariable nt_d -width 4
		label $bb.ds -text "Data State:  " -fg $evv(SPECIAL)
		label $bb.ple -text "" -width 24
		button $bb.pl -text "Load" -command "NTDatafileList $nyq $srate" -highlightbackground [option get . background {}]
		checkbutton $bb.ps -text "Save" -command "DoNTSaveParams 0" -variable nt_save
		label $bb.tf -text "To file "
		entry $bb.tfe -textvariable nt_dataname -width 32
		checkbutton $bb.cl -text "Clear Prms" -command "DoNTClearParams 0" -variable nt_clear
		checkbutton $bb.restp -text "Restore Prms" -command "DoNTRestore 1" -variable nt_restp
		checkbutton $bb.clall -text "Clear All" -command "DoNTClearParams 1" -variable nt_clall
		checkbutton $bb.rest -text "Restore" -command "DoNTRestore 0" -variable nt_rest
		pack $bb0.dll $bb0.de -side left
		pack $bb.ds $bb.ple $bb.pl $bb.ps $bb.tf $bb.tfe $bb.cl $bb.restp $bb.clall $bb.rest -side left

		label $b.ss -text "COLOUR:         " -fg $evv(SPECIAL)
		label $b.qll -text " Q (10-10000)"
		entry $b.qe -textvariable nt_q -width 4
		label $b.jll -text " pitch drift\n(0-6) semit"
		entry $b.je -textvariable nt_j -width 4
		label $b.jjll -text " drift rate\n(0-10 secs)"
		entry $b.jje -textvariable nt_jj -width 4
		label $b.hll -text " max hmncs (>0)"
		entry $b.he -textvariable nt_h -width 4 -disabledbackground [option get . background {}]
		label $b.rll -text " rolloff (0 to -96dB)"
		entry $b.re -textvariable nt_r -width 4 -disabledbackground [option get . background {}]
		label $b.gll -text "gain"
		entry $b.ga -textvariable nt_g -width 4
		label $b.gmm -text "possible\nouput gain"
		entry $b.gm -textvariable nt_m -width 12
		pack $b.ss $b.qll $b.qe $b.jll $b.je $b.jjll $b.jje $b.hll $b.he $b.rll $b.re $b.gll $b.ga -side left
		pack $b.gmm $b.gm -side right

		label $d.ss -text "FRQ LAYOUT: " -fg $evv(SPECIAL)
		button $d.ro -text "RotDn" -command {} -highlightbackground [option get . background {}]
		button $d.or -text "RotUp" -command {} -highlightbackground [option get . background {}]
		button $d.in -text "Invt" -command {} -highlightbackground [option get . background {}]
		button $d.sq -text "Sqz" -command {} -highlightbackground [option get . background {}]
		button $d.tr -text "Trnsp" -command {} -highlightbackground [option get . background {}]
		button $d.de -text "Del" -command {} -highlightbackground [option get . background {}]
		label $d.by -text " by "
		entry $d.e -textvariable nt_transpos -width 8
		label $d.se -text " semitones "
		button $d.re -text "Last" -command {} -highlightbackground [option get . background {}]
		button $d.rl -text "Orig" -command {} -highlightbackground [option get . background {}]
		pack $d.ss $d.ro $d.or $d.in $d.sq $d.de $d.tr $d.by $d.e $d.se $d.re $d.rl -side left -padx 2

		set c1 [frame $c.c1]
		set c2 [frame $c.c2]
		set c3 [frame $c.c3]
		set c0 [frame $c.c0 -width 1 -bg $evv(POINT)]
		set c4 [frame $c.c4]
		set c40 [frame $c.c4.0]
		set c41 [frame $c.c4.1]
		set c411 [frame $c41.1]
		set c412 [frame $c41.2]
		set c413 [frame $c41.3]

		button $c40.create -text "Create Data File" -command CreateFreeHarmonyData -highlightbackground [option get . background {}]
		pack $c40.create -side left

		label  $c1.a -text "FRQS"
		label $c1.cl -text ""
		set nt_frqtab [Scrolled_Listbox $c1.ll -width 12 -height 23 -selectmode single]
		pack $c1.a -side top -pady 2
		pack $c1.cl -side top -pady 6
		pack $c1.ll -side top -pady 2
		label $c2.a -text "AMPS"
		frame $c2.cl
		button $c2.cl.cl -text "Clr" -command "NTClear amp" -highlightbackground [option get . background {}]
		button $c2.cl.re -text "Rst" -command "NTRestore amp" -highlightbackground [option get . background {}]
		pack $c2.cl.cl $c2.cl.re -side left 
		set nt_amptab [Scrolled_Listbox $c2.ll -width 12 -height 23 -selectmode single]
		pack $c2.a $c2.cl $c2.ll -side top -pady 2
		label $c3.a -text "PARTIALS"
		frame $c3.cl
		button $c3.cl.cl -text "Clr" -command "NTClear par" -highlightbackground [option get . background {}]
		button $c3.cl.re -text "Rst" -command "NTRestore par" -highlightbackground [option get . background {}]
		pack $c3.cl.cl $c3.cl.re -side left 
		set nt_partab [Scrolled_Listbox $c3.ll -width 16 -height 23 -selectmode single]
		pack $c3.a $c3.cl $c3.ll -side top -pady 2
		label  $c411.a -text "Frq Files: Click On"
		set nt_fftab [Scrolled_Listbox $c411.ll -width 32 -height 24 -selectmode single]
		pack $c411.a $c411.ll -side top -pady 2
		label $c412.a -text "Amp Files: Click On"
		set nt_aftab [Scrolled_Listbox $c412.ll -width 32 -height 24 -selectmode single]
		pack $c412.a $c412.ll -side top -pady 2
		label $c413.a -text "Partials Files: Click On"
		set nt_pftab [Scrolled_Listbox $c413.ll -width 32 -height 24 -selectmode single]
		pack $c413.a $c413.ll -side top -pady 2
		pack $c1 $c2 $c3 -side left -padx 2
		pack $c0 -side left -padx 12 -fill y -expand true
		pack $c411 $c412 $c413 -side left -padx 2
		pack $c40 $c41 -side top
		pack $c4 -side left
		pack $a -side top -fill x -expand true
		pack $aa -side top -pady 2
		pack $aax -side top -fill x -expand true -pady 4 
		pack $bb0 -side top -pady 2
		pack $bbx -side top -fill x -expand true -pady 4 
		pack $bb -side top  -fill x -expand true -pady 2
		pack $bby -side top -fill x -expand true -pady 4 
		pack $b -side top -fill x -expand true -pady 4
		pack $dx -side top -fill x -expand true -pady 4 
		pack $d -side top -fill x -expand true -pady 2
		pack $cx -side top -fill x -expand true -pady 4 
		pack $c -side top -fill x -expand true -pady 2
		bind $nt_fftab <ButtonRelease-1> {NTGet $nt_fftab $nt_frqtab %y}
		bind $nt_aftab <ButtonRelease-1> {NTGet $nt_aftab $nt_amptab %y}
		bind $nt_pftab <ButtonRelease-1> {NTGet $nt_pftab $nt_partab %y}
		wm resizable $f 1 1
		set nt_d 4
		set nt_q 120
		set nt_j 0
		set nt_jj 0
		set nt_h 200
		set nt_r 0
		DoNTLoadParams 1 $srate

		bind .nt.b.qe  <Right> {focus .nt.b.je}
		bind .nt.b.je  <Right> {focus .nt.b.jje}
		bind .nt.b.jje <Right> {LocFoc .nt 0 1}
		bind .nt.b.he  <Right> {LocFoc .nt 0 0}
		bind .nt.b.re  <Right> {focus .nt.b.qe}
		bind .nt.b.qe  <Left> {LocFoc .nt 1 1}
		bind .nt.b.je  <Left> {focus .nt.b.qe}
		bind .nt.b.jje <Left> {focus .nt.b.je}
		bind .nt.b.he  <Left> {focus .nt.b.jje}
		bind .nt.b.re  <Left> {LocFoc .nt 1 0}
		set nt_g 1
		set nt_m ""
		bind $f <Escape> {set pr_nt 0}
	} else {
		foreach frq [$nt_frqtab get 0 end] {
			lappend nt_orig $frq
		}
	}
	$f.d.ro config -command "NTDo [list rotatedn $nt_orig $srate]"
	$f.d.or config -command "NTDo [list rotateup $nt_orig $srate]"
	$f.d.in config -command "NTDo [list invert $nt_orig $srate]"
	$f.d.sq config -command "NTDo [list squeeze $nt_orig $srate]"
	$f.d.tr config -command "NTDo [list transpose $nt_orig $srate]"
	$f.d.de config -command "NTDo [list delete $nt_orig $srate]"
	$f.d.re config -command "NTDo [list restore $nt_orig $srate]"
	$f.d.rl config -command "NTDo [list restoreorig $nt_orig $srate]"
	if {[$nt_partab index end] > 0} {
		NTClearSaveMaxharmRolloff
		if {[IsNumeric $nt_h] && [IsNumeric $nt_r]} {
			catch {unset nt_bakuphr}
			set nt_bakuphr [list $nt_h $nt_r]
		}
		set nt_h ""
		set nt_r ""
	} else {
		NTRestoreMaxharmRolloff
	}
	set nt_orig {}
	set nt_save 0
	set nt_clear 0
	set nt_clall 0
	.nt.a.sa config -text "" -bd 0 -state disabled
	.nt.a.ll config -text ""
	set nt_newname ""
	.nt.a.e  config -bd 0 -state disabled
	.nt.a.sa2 config -text "" -bd 0 -state disabled
	.nt.a.ll2 config -text ""
	set nt_newfname ""
	.nt.a.e2  config -bd 0 -state disabled
	$nt_fftab delete 0 end
	$nt_aftab delete 0 end
	$nt_pftab delete 0 end
	foreach fnam [$wl get 0 end] {
		set ftyp [NTFileType $fnam $nyq]
		switch -- $ftyp {
			"frq" {
				$nt_fftab insert end $fnam
			}
			"amp" {
				$nt_aftab insert end $fnam
			}
			"par" {
				$nt_pftab insert end $fnam
			}
		}
	}
	raise $f
	update idletasks
	StandardPosition $f
	set finished 0
	set pr_nt 0
	My_Grab 0 $f pr_nt $nt_fftab
	while {!$finished} {
		tkwait variable pr_nt
		switch -- $pr_nt {
			2 {
				if {![file exists $nt_chordfile]} {
					Inf "No Sound Made Yet"
					continue
				}
				if {[string length $nt_newname] <= 0} {
					Inf "No Filename Entered"
					continue
				}
				if {![ValidCDPRootname $nt_newname]} {
					continue
				}
				set zfnam [string tolower $nt_newname$evv(SNDFILE_EXT)]
				if {[file exists $zfnam]} {
					Inf "File Exists: Please Choose A Different Name"
					continue
				}
				if {[SaveNTFile $zfnam]} {
					.nt.a.sa config -text "" -bd 0 -state disabled
					.nt.a.ll config -text ""
					set nt_newname ""
					.nt.a.e  config -bd 0 -state disabled
				}
			}
			3 {
				if {![file exists $nt_filtfile]} {
					Inf "No Filter Data Created Yet"
					continue
				}
				if {[string length $nt_newfname] <= 0} {
					Inf "No Filename Entered"
					continue
				}
				if {![ValidCDPRootname $nt_newfname]} {
					continue
				}
				set zfnam [string tolower $nt_newfname$evv(TEXT_EXT)]
				if {[file exists $zfnam]} {
					Inf "File Exists: Please Choose A Different Name"
					continue
				}
				if {[SaveNTFiltFile $zfnam]} {
					.nt.a.sa2 config -text "" -bd 0 -state disabled
					.nt.a.ll2 config -text ""
					set nt_newfname ""
					.nt.a.e2  config -bd 0 -state disabled
				}
			}
			1 {
				.nt.a.sa config -text "" -bd 0 -state disabled
				.nt.a.ll config -text ""
				set nt_newname ""
				.nt.a.e  config -bd 0 -state disabled
				.nt.a.sa2 config -text "" -bd 0 -state disabled
				.nt.a.ll2 config -text ""
				set nt_newfname ""
				.nt.a.e2  config -bd 0 -state disabled
				DeleteIntermediateTempFiles
				if {[$nt_frqtab index end] <= 0} {
					Inf "No Frequency Data Given"
					continue
				}
				if {([string length $nt_d] <= 0) || ![IsNumeric $nt_d]} {
					Inf "Invalid Duration Given"
					continue
				}
				if {($nt_d < 0.2) || ($nt_d > 3600)} {
					Inf "Duration Out Of Range (0.2secs - 1 hour)"
					continue
				}
				if {([string length $nt_q] <= 0) || ![IsNumeric $nt_q]} {
					Inf "Invalid Q-Value Given"
					continue
				}
				if {($nt_q < 10) || ($nt_q > 10000)} {
					Inf "Q-Value Out Of Range (10 - 10000)"
					continue
				}
				if {([string length $nt_j] <= 0) || ![IsNumeric $nt_j]} {
					Inf "Invalid Pitch Drift Value Given"
					continue
				}
				if {($nt_j < 0) || ($nt_j > 6)} {
					Inf "Pitch Drift Out Of Range (0 - 6 semitones)"
					continue
				}
				if {([string length $nt_jj] <= 0) || ![IsNumeric $nt_jj]} {
					Inf "Invalid Drift Rate Value Given"
					continue
				}
				if {($nt_jj < 0) || ($nt_jj > 100)} {
					Inf "Drift Rate Out Of Range (0 - 100 secs)"
					continue
				}
				if {!$nt_filtfile_given || ($nt_pprg == "varibank")} {
					if {[$nt_partab index end] <= 0} {
						if {([string length $nt_h] <= 0) || ![IsNumeric $nt_h]} {
							Inf "Invalid Max Harmonic Count Given"
							continue
						}
						if {($nt_h < 1) || ($nt_h > 200)} {
							Inf "Max Harmonic Count Out Of Range (1 - 200)"
							continue
						}
						if {([string length $nt_r] <= 0) || ![IsNumeric $nt_r]} {
							Inf "Invalid Rolloff Value Given"
							continue
						}
						if {($nt_r > 0) || ($nt_r < -96)} {
							Inf "Rolloff Of Range (0 to -96 dB)"
							continue
						}
					}
				}
				if {![IsNumeric $nt_g] || ($nt_g < 0)} {
					Inf "Invalid Gain Value"
					continue
				}
				if {!$nt_filtfile_given} {
					catch {unset infrqs}
					catch {unset inamps}
					catch {unset inpars}
					set maxfrq_of_fundamentals -1
					foreach val [$nt_frqtab get 0 end] {
						if {$val > $maxfrq_of_fundamentals} {
							set maxfrq_of_fundamentals $val
						}
						lappend infrqs $val
					}
					set len [llength $infrqs]

					if {[$nt_partab index end] > 0} {
						if {![NTValidPartialData]} {
							$nt_partab delete 0 end
							NTRestoreMaxharmRolloff
							continue
						}
						set pdata [NTLimitMaxPartial $maxfrq_of_fundamentals $nyq]
						if {[llength $pdata] <= 0} {
							$nt_partab delete 0 end
							NTRestoreMaxharmRolloff
							continue
						}
					}
					if {[$nt_amptab index end] <= 0} {
						foreach val $infrqs {
							lappend inamps 1
						}
					} else {
						foreach val [$nt_amptab get 0 end] {
							lappend inamps $val
						}
						set alen [llength $inamps]
						if {$alen == 1} {
							set ampa [lindex $inamps 0]
							foreach val [lrange $infrqs 1 end] {
								lappend inamps $ampa
							}
						} elseif {$alen > $len} {
							set inamps [lrange $inamps 0 [expr $len - 1]]
						} elseif {$alen < $len} {
							set msg "Insufficient Amplitude Values: Use Final Value For Remaining Frequencies ?"
							set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
							if {$choice == "no"} {
								continue
							}
							set ampa [lindex $inamps end]
							while {[llength $inamps] < $len} {
								lappend inamps $ampa
							}
						}
					}
					if {[$nt_partab index end] > 0} {
						set hcnt 0
						set maxfrq [expr ($nyq - 1.0) / $nt_maxpar]
						set nt_pprg "varibank2"
					} else {
						set hcnt [expr int(floor($nyq / $maxfrq_of_fundamentals))]
						if {$hcnt < 1} {
							Inf "Frequency Too High"
							continue
						}
						if {$nt_h < $hcnt} {
							set hcnt $nt_h
						}
						set maxfrq [expr ($nyq - 1.0) / $hcnt]
						set nt_pprg "varibank"
					}
					set o_nam $evv(DFLT_OUTNAME)
					set nt_filtfile $o_nam
					append nt_filtfile "00" $evv(TEXT_EXT)
					if [catch {open $nt_filtfile "w"} zit] {
						Inf "Cannot Open Filter Data File"
						continue
					}
					set line "0"
					foreach frq $infrqs amp $inamps {
						append line "  " [DecPlaces $frq 3] "  " [DecPlaces $amp 3]
					}
					puts $zit $line
					set jitrate [expr $nt_jj * 2.0 / 3.0]
					if {$nt_j > 0} {
						Block "Creating Filter Data"
						set timelim [expr $nt_d - 0.1]
						set semij [expr pow($evv(SEMITONE_RATIO),$nt_j)]
						set time 0
						while {$time < $nt_d} {
							set timeincr [expr (rand() * $jitrate) + $jitrate]
							set time [DecPlaces [expr $time + $timeincr] 3]
							if {$time >= $timelim} {
								break
							}
							set line $time
							foreach frq $infrqs amp $inamps {
								set jitter [expr rand() * $nt_j]
								set trans [expr pow($evv(SEMITONE_RATIO),$jitter)]
								set thisfrq [DecPlaces [expr $frq * $trans] 3]
								if {$thisfrq >= $maxfrq} {
									set thisfrq [DecPlaces [expr $frq / $trans] 3]
								}
								set jitter [expr rand() * ($nt_j/6.0)]
								set jitter [expr 1.0 - $jitter]
								if {[$nt_amptab index end] <= 0} {
									set thisamp 1
								} else {
									set thisamp [DecPlaces [expr $amp * $jitter] 3]
								}
								append line "  " $thisfrq "  " $thisamp
							}
							puts $zit $line
						}
						set line $nt_d
						foreach frq $infrqs amp $inamps {
							append line "  " [DecPlaces $frq 3] "  " [DecPlaces $amp 3]
						}
						puts $zit $line
						UnBlock
					}
					set line [expr $nt_d + 100]
					foreach frq $infrqs amp $inamps {
						append line "  " [DecPlaces $frq 3] "  " [DecPlaces $amp 3]
					}
					puts $zit $line
					if {$nt_pprg == "varibank2"} {
						set line "#"
						puts $zit $line
						set line [lindex $pdata 0]
						set line [join $line "  "]
						puts $zit $line
						set line [lindex $pdata 1]
						set line [join $line "  "]
						puts $zit $line
					}
					close $zit
				} else {
					set hcnt $nt_hcnt
				}
				set ampfile $o_nam
				append ampfile "01" $evv(TEXT_EXT)
				if [catch {open $ampfile "w"} zit] {
					Inf "Cannot Open Envelope File To Shape Output"
					DeleteIntermediateTempFiles
					set nt_filtfile_given 0
					continue
				}
				set j [expr $nt_d / 3.0]
				if {$j > .5} {
					set j .5
				}
				set line "0  0"
				puts $zit $line
				set line "$j .8"
				puts $zit $line
				set time [expr $nt_d - $j]
				set line "$time  .8"
				puts $zit $line
				set line "$nt_d  0"
				puts $zit $line
				set time [expr $nt_d + 100]
				set line "$time  0"
				puts $zit $line
				close $zit
				CreateNonTonalHarmony $nt_d $nt_q $srate $bitsize $hcnt $nt_filtfile $ampfile $nt_r
				set nt_filtfile_given 0
			} 
			0 {
				break
			}
		}
	}
	DeleteIntermediateTempFiles
	DoNTSaveParams 1
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- Create and Play Free Harmony

proc CreateNonTonalHarmony {outdur q srate bitsize hcnt filtfile ampfile rolloff} {
	global CDPidrun prg_dun prg_abortd program_messages wstk o_nam nt_chordfile nt_pprg nt_filtfile_given nt_g nt_m evv
    global playcmd_dummy
    
	set gain [expr [GetNTGain $q] * $nt_g]
	set o_nam $evv(DFLT_OUTNAME)
	set noisfile $o_nam
	append noisfile "00" $evv(SNDFILE_EXT)
	set nt_chordfile $o_nam
	append nt_chordfile "01"
	if {$bitsize == 16} {
		set CDP_cmd [list [file join $evv(CDPROGRAM_DIR) synth] noise $noisfile $srate 1 $outdur -a$ampfile]
	} else {
		set CDP_cmd [list [file join $evv(CDPROGRAM_DIR) newsynth] wave 5 $noisfile $srate 1 $outdur -a$ampfile -b$bitsize]
	}
	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	Block "Creating Noise Substrate"
	if [catch {open "|$CDP_cmd"} CDPidrun] {
		Inf "$CDPidrun :\nCan't Create Noise Substrate"
		UnBlock
		DeleteIntermediateTempFiles
		return
	} else {
	   	fileevent $CDPidrun readable "Display_Score_Batch_Running_Info"
	}
	vwait prg_dun
	if {$prg_abortd} {
		if [info exists program_messages] {
			Inf "$program_messages"
		}
		set prg_dun 0
	}
	if {!$prg_dun} {
		set errorline "Can't Create Noise Substrate"
	}
	if [info exists errorline] {
		Inf "$errorline"
		unset errorline
		UnBlock
		DeleteIntermediateTempFiles
		return
	}
	if [info exists program_messages] {
		Inf "$program_messages"
		unset program_messages
	}
	UnBlock
	Block "Creating Harmony"
	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	if {$nt_pprg == "varibank"} {
		set CDP_cmd [list [file join $evv(CDPROGRAM_DIR) filter] $nt_pprg 1 $noisfile $nt_chordfile $filtfile $q $gain -t1 -h$hcnt -r$rolloff -d]
	} else {
		set CDP_cmd [list [file join $evv(CDPROGRAM_DIR) filter] $nt_pprg 1 $noisfile $nt_chordfile $filtfile $q $gain -t1 -d]
	}
	if [catch {open "|$CDP_cmd"} CDPidrun] {
		Inf "$CDPidrun :\nCan't Create Harmony"
		UnBlock
		DeleteIntermediateTempFiles
		return
	} else {
	   	fileevent $CDPidrun readable "Display_Score_Batch_Running_Info"
	}
	vwait prg_dun
	if {$prg_abortd} {
		if [info exists program_messages] {
			Inf "$program_messages"
		}
		set prg_dun 0
	}
	if {!$prg_dun} {
		set errorline "Can't Create Harmony"
	}
	if [info exists errorline] {
		Inf "$errorline"
		unset errorline
		UnBlock
		DeleteIntermediateTempFiles
		return
	}
	if [info exists program_messages] {
		Inf "$program_messages"
		unset program_messages
	}
	UnBlock
	append nt_chordfile $evv(SNDFILE_EXT)
	if {[file exists $nt_chordfile]} {
		set choice "yes"
		while {$choice == "yes"} {
			set is_playing 1
			PlaySndfile $nt_chordfile 0			;# PLAY OUTPUT
			set msg "HEAR IT AGAIN ?"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		}
		if {$is_playing && ($playcmd_dummy != "pvplay")} {
			Inf "IF THERE IS A PLAY-PROGRAM DISPLAY\nYOU MUST CLOSE IT BEFORE PROCEEDING!!"
		}
	}
	.nt.a.sa config -text "Save Sound Output" -state normal -bd 2
	.nt.a.ll config -text "  With Name "
	.nt.a.e  config -bd 2 -state normal
	if {!$nt_filtfile_given} {
		.nt.a.sa2 config -text "Keep Filter Format" -state normal -bd 2
		.nt.a.ll2 config -text "  With Name "
		.nt.a.e2  config -bd 2 -state normal
	}
	set nt_m [FH_Maxsamp $nt_chordfile]
	if {[string length $nt_m] > 0} {
		set nt_m [DecPlaces [expr 1.0/$nt_m] 1]
	}
}

#---- Delete temp files

proc DeleteIntermediateTempFiles {} {
	global o_nam

	set fnams [glob -nocomplain "$o_nam*"]
	if {[llength $fnams] > 0} {
		foreach fnam $fnams {
			file stat $fnam filestatus
			if {$filestatus(ino) >= 0} {
				catch {close $filestatus(ino)}
			}
# RWD 2023 from PC code, added -force
			if [catch {file delete -force $fnam} result] {
				ErrShow "Cannot delete temporary file $fnam"
				return 0
			}
		}
	}
}

#---- Get filetypes to select for listing in Free Harmony page

proc NTFileType {fnam nyq} {
	global evv pa
	if {[info exists pa($fnam,$evv(FTYP))]} {
		set ftyp $pa($fnam,$evv(FTYP))
		if {[IsAListofNumbers $ftyp]} {
			if {($pa($fnam,$evv(MINNUM)) >= 9.0) && ($pa($fnam,$evv(MAXNUM)) <= $nyq)} {
				return frq
			} elseif {($pa($fnam,$evv(MINNUM)) >= 0.0) && ($pa($fnam,$evv(MAXNUM)) <= 1.0)} {
				return amp
			}
			if {$pa($fnam,$evv(NUMSIZE)) == [expr 2 * $pa($fnam,$evv(LINECNT))]} {
				if {($pa($fnam,$evv(MINNUM)) >= 0.0) && ($pa($fnam,$evv(MAXNUM)) <= 200)} {
					if [catch {open $fnam "r"} zit] {
						return ""
					}
					while {[gets $zit line] >= 0} {
						set line [string trim $line]
						if {([string length $line] <= 0) || [string match ";" [string index $line 0]]} {
							continue
						}
						set line [split $line]
						foreach item $line {
							if {[string length $item] > 0} {
								lappend testlist $item
							}
						}
					}
					close $zit
					if {![info exists testlist] || ![IsEven [llength $testlist]]} {
						return ""
					}
					foreach {pno amp} $testlist {
						if {($pno < 1.0) || ($pno > 200.0)} {
							return ""
						}
						if {($amp < 0.0) || ($amp > 1.0)} {
							return ""
						}
					}
					return "par"
				}
			}
		}
	}
	return ""
}

#---- Get contents of file selected on Free Harmony page

proc NTGet {listing1 listing2 y} {
	global nt_pftab
	set i [$listing1 nearest $y]
	if {$i < 0} {
		return
	}
	set i [$listing1 curselection]
	set fnam [$listing1 get $i]
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File '$fnam'"
		return
	}
	$listing2 delete 0 end
	set cleared 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		if {[string match $listing1 $nt_pftab]}  {
			set line [split $line]
			set cnt 0
			catch {unset thisline}
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] > 0} {
					if {$cnt == 0} {
						set thisline $item
						incr cnt
					} else {
						append thisline " " $item
					}
				}
			}
			if {[info exists thisline]} {
				$listing2 insert end $thisline
				if {!$cleared} {
					NTClearSaveMaxharmRolloff
					set cleared 1
				}
			}
		} else {
			set line [split $line]
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] > 0} {
					$listing2 insert end [DecPlaces $item 3]
				}
			}
		}
	}
	close $zit
}

#---- Convert Q val to appropriate gain for filter output

proc GetNTGain {q} {
	set g [expr (log10($q)/0.90309) * 0.5]	;# 0.90309 ='= log10(8) --> log8($q)
	return $g
}

#------ Keep sound output from Free Harmony Workshop

proc SaveNTFile {fnam} {
	global nt_chordfile nt_normfile nt_newname wl rememd wstk
	if [catch {file rename $nt_chordfile $fnam} zit] {
		Inf "Cannot Save File"
		return 0
	}
	if {[FileToWkspace $fnam 0 0 0 0 1] > 0} {
		Inf "Saved File '$fnam' To Workspace"
	}
	.nt.a.sa config -text "" -bd 0 -state disabled
	.nt.a.ll config -text ""
	set nt_newname ""
	.nt.a.e  config -bd 0 -state disabled
	return 1
}

#------ Keep filter data file from Free Harmony Workshop

proc SaveNTFiltFile {fnam} {
	global nt_filtfile nt_newfname wl rememd wstk
	if [catch {file rename $nt_filtfile $fnam} zit] {
		Inf "Cannot Save Filter Data File"
		return 0
	}
	if {[FileToWkspace $fnam 0 0 0 0 1] > 0} {
		Inf "Saved File '$fnam' To Workspace"
	}
	.nt.a.sa2 config -text "" -bd 0 -state disabled
	.nt.a.ll2 config -text ""
	set nt_newfname ""
	.nt.a.e2  config -bd 0 -state disabled
	return 1
}

#------ Save Params from Free Harmony Workshop, either to a file, or to backup at end of session

proc DoNTSaveParams {end} {
	global nt_frqtab nt_amptab nt_partab nt_d nt_q nt_j nt_jj nt_h nt_r wl nt_save nt_dataname wstk nt_bakuphr evv
	if {[$nt_frqtab index end] <= 0} {
		if {!$end} {
			Inf "No Frequency Data Given"
		}
		set nt_save 0
		return
	}
	if {([string length $nt_d] <= 0) || ![IsNumeric $nt_d]} {
		if {!$end} {
			Inf "Invalid Duration Given"
		}
		set nt_save 0
		return
	}
	if {($nt_d < 0.2) || ($nt_d > 3600)} {
		if {!$end} {
			Inf "Duration Out Of Range (0.2secs - 1 hour)"
		}
		set nt_save 0
		return
	}
	if {([string length $nt_q] <= 0) || ![IsNumeric $nt_q]} {
		if {!$end} {
			Inf "Invalid Q-Value Given"
		}
		set nt_save 0
		return
	}
	if {($nt_q < 10) || ($nt_q > 10000)} {
		if {!$end} {
			Inf "Q-Value Out Of Range (10 - 10000)"
		}
		set nt_save 0
		return
	}
	if {([string length $nt_j] <= 0) || ![IsNumeric $nt_j]} {
		if {!$end} {
			Inf "Invalid Pitch Drift Value Given"
		}
		set nt_save 0
		return
	}
	if {($nt_j < 0) || ($nt_j > 6)} {
		if {!$end} {
			Inf "Pitch Drift Out Of Range (0 - 6 semitones)"
		}
		set nt_save 0
		return
	}
	if {([string length $nt_jj] <= 0) || ![IsNumeric $nt_jj]} {
		if {!$end} {
			Inf "Drift Rate Value Given"
		}
		set nt_save 0
		return
	}
	if {($nt_jj < 0) || ($nt_jj > 100)} {
		if {!$end} {
			Inf "Drift Rate Out Of Range (0 - 100 secs)"
		}
		set nt_save 0
		return
	}
	if {[$nt_partab index end] > 0} {
		if {[info exists nt_bakuphr]} {
			set nt_h [lindex $nt_bakuphr 0]
			set nt_r [lindex $nt_bakuphr 1]
		} else {
			set nt_h 200
			set nt_r 0
		}
	}
	if {([string length $nt_h] <= 0) || ![IsNumeric $nt_h]} {
		if {!$end} {
			Inf "Invalid Max Harmonic Count Given"
		}
		set nt_save 0
		return
	}
	if {($nt_h < 1) || ($nt_h > 200)} {
		if {!$end} {
			Inf "Max Harmonic Count Out Of Range (1 - 200)"
		}
		set nt_save 0
		return
	}
	if {([string length $nt_r] <= 0) || ![IsNumeric $nt_r]} {
		if {!$end} {
			Inf "Invalid Rolloff Value Given"
		}
		set nt_save 0
		return
	}
	if {($nt_r > 0) || ($nt_r < -96)} {
		if {!$end} {
			Inf "Rolloff Of Range (0 to -96 dB)"
		}
		set nt_save 0
		return
	}
	set outlist {}

	lappend outlist $nt_d
	lappend outlist $nt_q
	lappend outlist $nt_j
	lappend outlist $nt_jj
	lappend outlist $nt_h
	lappend outlist $nt_r
	set len [$nt_frqtab index end]
	lappend outlist $len
	foreach val [$nt_frqtab get 0 end] {
		lappend outlist $val
	}
	set len [$nt_amptab index end]
	lappend outlist $len
	if {$len > 0} {
		foreach val [$nt_amptab get 0 end] {
			lappend outlist $val
		}
	}
	set len [$nt_partab index end]
	lappend outlist $len
	if {$len > 0} {
		foreach val [$nt_partab get 0 end] {
			lappend outlist $val
		}
	}
	if {$end} {
		set fnam [file join $evv(URES_DIR) $evv(FREE)$evv(CDP_EXT)]
		if [catch {open $fnam "w"} zit] {
			return
		}
	} else {
		if {[string length $nt_dataname] <= 0} {
			Inf "No Datafile Name Entered"
			set nt_save 0
			return
		}
		set fnam [file rootname $nt_dataname]
		if {![ValidCDPRootname $fnam]} {
			set nt_save 0
			return
		}
		append fnam $evv(TEXT_EXT)
		if {[file exists $fnam]} {
			set msg "File '$fnam' Exists: Overwrite ?"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				set nt_save 0
				return
			}
		}
		if [catch {open $fnam "w"} zit] {
			Inf "Cannot Open File '$fnam' To Save Data"
			set nt_save 0
			return
		}
	}
	foreach item $outlist {
		puts $zit $item
	}
	close $zit
	if {!$end} {
		FileToWkspace $fnam 0 0 0 0 1
		Inf "Saved Parameters To '$fnam'"
	}
	.nt.bb.ple config -text $nt_dataname
	set nt_save 0
}

#------ Load Params to Free Harmony Workshop, either from a file, or from backup at start of session

proc DoNTLoadParams {start srate} {
	global nt_frqtab nt_amptab nt_partab nt_d nt_q nt_j nt_jj nt_h nt_r wl nt_indataname nt_orig nt_bakuphr evv

	set nyq [expr $srate / 2.0]
	if {$start} {
		set fnam [file join $evv(URES_DIR) $evv(FREE)$evv(CDP_EXT)]
		if {![file exists $fnam]} {
			return 0
		}
	} else {
		if {[string length $nt_indataname] <= 0} {
			Inf "No Datafile Name Entered"
			return 0
		}
		set fnam $nt_indataname
		set ext [file extension $fnam]
		if {[string length $ext] <= 0} {
			append fnam $evv(TEXT_EXT)
		} elseif {![string match $ext $evv(TEXT_EXT)]} {
			Inf "Invalid Datafile Name Entered"
			return 0
		}
		if {![file exists $fnam]} {
			Inf "Datafile '$fnam' Does Not Exist"
			return 0
		}
	}
	if [catch {open $fnam "r"} zit] {
		if {!$start} {
			Inf "Cannot Retrieve Saved Values From File '$fnam'"
		}
			return 0
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
#FEB 2022
		if {[string length $line] <= 0} {
			continue
		} elseif {[string match [string index $line 0] ";"]} {
			continue
		}
		lappend outlist $line
	}
	close $zit
	set haspar [HasNTSyntax $outlist $nyq $start]
	if {$haspar < 0} {
		return 0
	}
	set n 0
	foreach val $outlist {
		switch -- $n {
			0 {set nt_d $val}
			1 {set nt_q $val}
			2 {set nt_j $val}
			3 {set nt_jj $val}
			4 {
				if {$haspar}  {
					catch {unset nt_bakuphr}
					lappend nt_bakuphr $val
					NTClearMaxharmRolloff
				} else {
					set nt_h $val
				}
			}
			5 {
				if {$haspar}  {
					lappend nt_bakuphr $val
				} else {
					set nt_r $val
				}
			}
			6 {
				set len $val
				incr n
				set m 0
				$nt_frqtab delete 0 end
				while {$m < $len} {
					set val [lindex $outlist $n]
					$nt_frqtab insert end [DecPlaces $val 3]
					incr n
					incr m
				}
				set len [lindex $outlist $n]
				$nt_amptab delete 0 end
				incr n
				if {$len > 0} {
					set m 0
					while {$m < $len} {
						set val [lindex $outlist $n]
						$nt_amptab insert end [DecPlaces $val 3]
						incr n
						incr m
					}
				}
				set len [lindex $outlist $n]
				$nt_partab delete 0 end
				incr n
				if {$len > 0} {
					set m 0
					while {$m < $len} {
						set val [lindex $outlist $n]
						$nt_partab insert end $val
						incr n
						incr m
					}
				} else {
					NTClearSaveMaxharmRolloff
				}
				break
			}
		}
		incr n
	}
	catch {unset nt_orig}
	foreach frq [$nt_frqtab get 0 end] {
		lappend nt_orig $frq
	}
	if {!$start} {
		.nt.d.ro config -command "NTDo [list rotatedn $nt_orig $srate]"
		.nt.d.or config -command "NTDo [list rotateup $nt_orig $srate]"
		.nt.d.in config -command "NTDo [list invert $nt_orig $srate]"
		.nt.d.sq config -command "NTDo [list squeeze $nt_orig $srate]"
		.nt.d.tr config -command "NTDo [list transpose $nt_orig $srate]"
		.nt.d.de config -command "NTDo [list delete $nt_orig $srate]"
		.nt.d.re config -command "NTDo [list restore $nt_orig $srate]"
		.nt.d.rl config -command "NTDo [list restoreorig $nt_orig $srate]"
	}
	return 1
}

#------ Clear PArams, or params and frq:amp listings in Free Harmony Workshop

proc DoNTClearParams {all} {
	global nt_frqtab nt_amptab nt_partab nt_d nt_q nt_j nt_jj nt_h nt_r 
	global nt_clear nt_clall nt_origall nt_origparams evv
	
	if {[NTnothingToClear $all]} {
		set nt_clear 0
		set nt_clall 0
		return
	}
	set save_params 1
	if {$all} {
		if {[NTnothingToClear 0]} {
			set save_params 0
		}
	}
	if {$save_params} {
		catch {unset nt_origparams}
		lappend nt_origparams $nt_d
		lappend nt_origparams $nt_q
		lappend nt_origparams $nt_j
		lappend nt_origparams $nt_jj
		lappend nt_origparams $nt_h
		lappend nt_origparams $nt_r
	}
	set nt_clear 0
	if {$all} {
		catch {unset nt_origall}
		lappend nt_origall $nt_d
		lappend nt_origall $nt_q
		lappend nt_origall $nt_j
		lappend nt_origall $nt_jj
		lappend nt_origall $nt_h
		lappend nt_origall $nt_r
		lappend nt_origall [$nt_frqtab index end]
		foreach frq [$nt_frqtab get 0 end] {
			lappend nt_origall $frq
		}
		lappend nt_origall [$nt_amptab index end]
		foreach amp [$nt_amptab get 0 end] {
			lappend nt_origall $amp
		}
		lappend nt_origall [$nt_partab index end]
		foreach par [$nt_partab get 0 end] {
			lappend nt_origall $par
		}
		$nt_frqtab delete 0 end
		$nt_amptab delete 0 end
		$nt_partab delete 0 end
		NTRestoreMaxharmRolloff
		set nt_clall 0
	}
	set nt_d ""
	set nt_q ""
	set nt_j ""
	set nt_jj ""
	set nt_h ""
	set nt_r ""
}

#------ Restore Params, or params and frq:amp listings in Free Harmony Workshop

proc DoNTRestore {params_only} {
	global nt_frqtab nt_amptab nt_partab nt_d nt_q nt_j nt_jj nt_h nt_r nt_origall nt_origparams nt_rest nt_restp evv
	
	if {$params_only} {
		if {![info exists nt_origparams]} {
			Inf "No Cleared Params To Restore"
			set nt_restp 0
			return
		}
		set nt_d [lindex $nt_origparams 0]
		set nt_q [lindex $nt_origparams 1]
		set nt_j [lindex $nt_origparams 2]
		set nt_jj [lindex $nt_origparams 3]
		if {[string match [.nt.b.he cget -state] "normal"]} {
			set nt_h [lindex $nt_origparams 4]
			set nt_r [lindex $nt_origparams 5]
		}
		set nt_restp 0
		return
	} elseif {![info exists nt_origall]} {
		Inf "No Cleared Data To Restore"
		set nt_rest 0
		return
	}
	set totlen [llength $nt_origall]
	set nt_d [lindex $nt_origall 0]
	set nt_q [lindex $nt_origall 1]
	set nt_j [lindex $nt_origall 2]
	set nt_jj [lindex $nt_origall 3]
	set k [lindex $nt_origall 6]
	set kk [expr $k + 6]
	set k 7
	$nt_frqtab delete 0 end
	foreach frq [lrange $nt_origall $k $kk] {
		$nt_frqtab insert end $frq
	}
	incr kk
	set k $kk
	set len [lindex $nt_origall $k]
	set kk [expr $len + $k]
	incr k
	$nt_amptab delete 0 end
	foreach amp [lrange $nt_origall $k $kk] {
		$nt_amptab insert end $amp
	}
	incr kk
	set k $kk
	set len [lindex $nt_origall $k]
	set kk [expr $len + $k]
	incr k
	$nt_partab delete 0 end
	foreach par [lrange $nt_origall $k $kk] {
		$nt_partab insert end $par
	}
	if {[$nt_partab index end] > 0} {
		NTClearSaveMaxharmRolloff
	}
	if {[string match [.nt.b.he cget -state] "normal"]} {
		set nt_h [lindex $nt_origall 4]
		set nt_r [lindex $nt_origall 5]
	}
	set nt_rest 0
}

#------ Massage Data in Free Harmony Workshop

proc NTDo {what nt_orig srate} {
	global nt_frqtab nt_lastfrqs nt_transpos evv

	set nyq [expr $srate / 2.0]
	switch -- $what {
		"restore" {
			if {![info exists nt_lastfrqs]} {
				Inf "No Previous Frequency Data To Restore"
				return
			}
			set current_frqset {}
			foreach item [$nt_frqtab get 0 end] {
				lappend current_frqset $item
			}
			$nt_frqtab delete 0 end
			foreach item $nt_lastfrqs {
				$nt_frqtab insert end $item
			}
			set nt_lastfrqs $current_frqset
			return
		}
		"restoreorig" {
			set current_frqset {}
			foreach item [$nt_frqtab get 0 end] {
				lappend current_frqset $item
			}
			set OK 1
			if {[llength $current_frqset] == [llength $nt_orig]} {
				set OK 0
				foreach frq $current_frqset frqo $nt_orig {
					if {![string match $frq $frqo]} {
						set OK 1
						break
					}
				}
			}
			if {$OK} {
				$nt_frqtab delete 0 end
				foreach frq $nt_orig {
					$nt_frqtab insert end $frq
				}
				set nt_lastfrqs $current_frqset
			}
			return
		}
		"delete" {
			foreach item [$nt_frqtab get 0 end] {
				lappend current_frqset $item
			}
			if {![info exists current_frqset]} {
				return
			}
			set i [$nt_frqtab curselection]
			if {$i < 0} {
				Inf "No Frequency Selected"
				return
			} 
			$nt_frqtab delete $i
			set nt_lastfrqs $current_frqset
			return
		}
	}
	if {[$nt_frqtab index end] <= 0} {
		Inf "No Frequency Data Displayed"
		return
	}
	set len 0
	foreach item [$nt_frqtab get 0 end] {
		lappend current_frqset $item
		incr len
	}
	set maxfrq 0
	set minfrq $srate
	set n 0
	foreach frq $current_frqset {
		if {$frq > $maxfrq} {
			set maxfrq $frq
			set maxpos  $n
		}
		if {$frq < $minfrq} {
			set minfrq $frq
			set minpos  $n
		}
		incr n
	}
	switch -- $what {
		"rotatedn" {
			while {$maxfrq > $minfrq} {
				set maxfrq [expr $maxfrq / 2.0]
				if {$maxfrq < 9.0} {
					Inf "Cannot Rotate Down Further"
					return
				}
			}
			set nuset [lreplace $current_frqset $maxpos $maxpos [DecPlaces $maxfrq 5]]
		}
		"rotateup" {
			while {$minfrq < $maxfrq} {
				set minfrq [expr $minfrq * 2.0]
				if {$minfrq >= $nyq} {
					Inf "Cannot Rotate Up Further"
					return
				}
			}
			set nuset [lreplace $current_frqset $minpos $minpos [DecPlaces $minfrq 5]]
		}
		"invert" {
			foreach frq $current_frqset {
				lappend ratios [expr $minfrq / double($frq)]	;#	Inverse of interval above lowest frq
			}
			foreach ratio $ratios {
				lappend nuset [DecPlaces [expr $maxfrq * $ratio] 5]
			}
		}
		"transpose" {
			if {([string length $nt_transpos] <= 0) || ![IsNumeric $nt_transpos]} {
				Inf "Invalid Transposition Data"
				return
			}
			if {($nt_transpos < -48) || ($nt_transpos > 48)} { 
				Inf "Transposition Out Of Range (4 octaves)"
				return
			}
			set trans [expr pow($evv(SEMITONE_RATIO),$nt_transpos)]
			if {$trans > 1.0} {
				if {[expr $maxfrq * $trans] >= $nyq} {
					Inf "Transposition Takes Some Frequencies Out Of Range"
					return
				}
			} elseif {[expr $minfrq * $trans] < 9.0} {
				Inf "Transposition Takes Some Frequencies Out Of Range"
				return
			}
			foreach frq $current_frqset {
				lappend nuset [DecPlaces [expr $frq * $trans] 5]
			}
		}
		"squeeze" {
			set sum 0
			foreach frq $current_frqset {
				set sum [expr $sum + [HzToMidi $frq]]
			}
			set mean [MidiToHz [expr $sum / double($len)]]
			set cnt 0
			foreach frq $current_frqset {
				if {$frq > $mean} {
					set lastratio [expr $frq / double($mean)]
					set isgreater 1
				} else {
					set lastratio [expr $mean / double($frq)]
					set isgreater 0
				}
				set finished 0
				while {!$finished} {
					if {$isgreater} {
						set nufrq [expr $frq / 2.0]
					} else {
						set nufrq [expr $frq * 2.0]
					}
					if {$nufrq > $mean} {
						set thisratio [expr $nufrq / double($mean)]
						set isgreater 1
					} else {
						set thisratio [expr $mean / double($nufrq)]
						set isgreater 0
					}
					if {$thisratio < $lastratio} {
						set frq $nufrq
						set lastratio $thisratio
						incr cnt					
					} else {
						lappend nuset [DecPlaces $frq 5]
						set finished 1
					}
				}
			}
			if {$cnt == 0} {
				return
			}
		}
	}
	$nt_frqtab delete 0 end
	foreach item $nuset {
		$nt_frqtab insert end $item
	}
	set nt_lastfrqs $current_frqset
}

proc NTValidPartialData {} {
	global nt_partab
	set cnt 1
	foreach line [$nt_partab get 0 end] {
		set line [split $line]
		set nuline {}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend nuline $item
			}
		}
		if {[llength $nuline] != 2} {
			Inf "Bad Data Line Among Partials Data"
			return 0
		}
		set pno  [lindex $nuline 0]		
		set pamp [lindex $nuline 1]
		if {$pno < 1} {
			Inf "Partial Number ($pno) Less Than 1 On Line $cnt"
			return 0
		}
		if {$pno > 200} {
			Inf "Partial Number ($pno) Greater Than Max (200) On Line $cnt"
			return 0
		}
		if {$pamp < 0} {
			Inf "Partial Amplitude ($pamp) Less Than Zero On Line $cnt"
			return 0
		}
		if {$pamp > 1} {
			Inf "Partial Amplitude ($pamp) Greater Than Max (1) On Line $cnt"
			return 0
		}
		incr cnt
	}
	return 1
}

proc NTLimitMaxPartial {maxfrq nyq} {
	global nt_partab nt_maxpar
	set nt_maxpar 0
	set line1 0
	foreach line [$nt_partab get 0 end] {
		set line [split $line]
		set cnt 0
		foreach val $line {
			set val [string trim $val]
			if {[string length $val] > 0} {
				switch -- $cnt {
					0 {
						if {$val > $nt_maxpar} {
							if {[expr $maxfrq * $val] >= $nyq} {
								lappend badpartials $val
								break
							}
							set nt_maxpar $val
						}
						lappend line1 [DecPlaces $val 3]
					}
					1 {
						lappend line1 [DecPlaces $val 3]
					}
				}
				incr cnt
			}
		}
	}
	if {[llength $line1] <= 1} {
		Inf "All Partials Are Too High For Some Of The Given Frq Values"
		return {}
	}
	if {[info exists badpartials]} {
		set msg "The Following Partials Are Too High For Some Frq Values Given, And Have Been Removed\n"
		set cnt 0
		foreach val $badpartials {
			incr cnt
			if {$cnt > 20} {
				append msg "\nAnd More"
				break
			}
			append msg "$val    "
		}
		Inf $msg
	}
	set line2 [lreplace $line1 0 0 10000]
	set outlines [list $line1 $line2]
	return $outlines
}

proc NTClear {what} {
	global nt_partab nt_amptab nt_origamp nt_origpar
	switch -- $what {
		"amp" {
			if {[$nt_amptab index end] <= 0} {
				return
			}
			set nt_origamp {}
			foreach val [$nt_amptab get 0  end] {
				lappend nt_origamp $val
			}
			$nt_amptab delete 0 end
		}
		"par" {
			if {[$nt_partab index end] <= 0} {
				return
			}
			set nt_origpar {}
			foreach val [$nt_partab get 0  end] {
				lappend nt_origpar $val
			}
			$nt_partab delete 0 end
			NTRestoreMaxharmRolloff
		}
	}
}

proc NTRestore {what} {
	global nt_partab nt_amptab nt_origamp nt_origpar
	switch -- $what {
		"amp" {
			if {![info exists nt_origamp] || ([llength $nt_origamp] <= 0)} {
				return
			}
			$nt_amptab delete 0 end
			foreach val $nt_origamp {
				$nt_amptab insert end $val
			}
		}
		"par" {
			if {![info exists nt_origpar] || ([llength $nt_origpar] <= 0)} {
				return
			}
			$nt_partab delete 0 end
			foreach val $nt_origpar {
				$nt_partab insert end $val
			}
			NTClearSaveMaxharmRolloff
		}
	}
}

proc NTClearSaveMaxharmRolloff {} {
	global nt_bakuphr nt_h nt_r
	if {[string match [.nt.b.he cget -state] "disabled"]} {
		return
	}
	set qnt_h [.nt.b.he get]			;#	CURRENT ENTERED VALUE
	set qnt_r [.nt.b.re get]
	if {[string length $qnt_h] <= 0} {	;#	PREVIOUSLY EXISTING VALUE
		set qnt_h $nt_h		
	}
	if {[string length $qnt_r] <= 0} {
		set qnt_r $nt_r
	}
	if {[string length $qnt_h] <= 0} {	;#	DEFAULT VALUE
		set qnt_h 200
	}
	if {[string length $qnt_r] <= 0} {
		set qnt_r 0
	}
	set nt_bakuphr [list $qnt_h $qnt_r]
	set nt_h ""
	set nt_r ""
	.nt.b.hll config -text ""
	.nt.b.he  config -bd 0 -state disabled
	.nt.b.rll config -text ""
	.nt.b.re  config -bd 0 -state disabled
}

proc NTRestoreMaxharmRolloff {} {
	global nt_bakuphr nt_h nt_r
	if {[string match [.nt.b.he cget -state] "normal"]} {
		return
	}
	.nt.b.hll config -text " max hmncs (>0)"
	.nt.b.he  config -bd 2 -state normal
	.nt.b.rll config -text " rolloff (0 to -96dB)"
	.nt.b.re  config -bd 2 -state normal
	if {[info exists nt_bakuphr]} {
		set nt_h [lindex $nt_bakuphr 0]
		set nt_r [lindex $nt_bakuphr 1]
	} else {
		set nt_h 200
		set nt_r 0
	}
}

proc NTClearMaxharmRolloff {} {
	global nt_h nt_r
	set nt_h ""
	set nt_r ""
	.nt.b.hll config -text ""
	.nt.b.he  config -bd 0 -state disabled
	.nt.b.rll config -text ""
	.nt.b.re  config -bd 0 -state disabled
}

proc NTnothingToClear {all} {
	global nt_d nt_q nt_j nt_jj nt_h nt_r nt_frqtab nt_amptab nt_partab

	set test $nt_d
	append test $nt_q $nt_j $nt_jj $nt_h $nt_r
	if {$all} {
		foreach frq [$nt_frqtab get 0 end] {
			append test $frq
		}
		foreach amp [$nt_amptab get 0 end] {
			append test $amp
		}
		foreach par [$nt_partab get 0 end] {
			append test $par
		}
		if {[string length $test] <= 0} {
			return 1
		}
	} elseif {[string length $test] <= 0} {
		return 1
	}
	return 0
}

proc NTDatafileList {nyq srate} {
	global nt_indataname wl pa pr_ntload nt_g ntloadlist ntloadflist nt_posfdats evv
	Block "Checking data"
	foreach fnam [$wl get 0 end] {
		if {[info exists pa($fnam,$evv(FTYP))]} {
			if {[IsAListofNumbers $pa($fnam,$evv(FTYP))] \
			&& ($pa($fnam,$evv(MINNUM)) >= -96) && ($pa($fnam,$evv(MAXNUM)) <= $nyq)} {
				lappend posdats $fnam
			}
		}
	}
	catch {unset nt_posfdats}
	foreach fnam [$wl get 0 end] {
		if {[info exists pa($fnam,$evv(FTYP))]} {
			if {$pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)} {
				set zoot [NTCheckFiltValidity $fnam $nyq]
				if {[string length $zoot] > 0}  {
					set zz [list $fnam $zoot]
					lappend nt_posfdats $zz
				}
			}
		}
	}
	UnBlock
	if {![info exists posdats] || ![info exists nt_posfdats]} {
		Inf "No Potential Data Files On Workspace"
		return
	}
	set nt_indataname ""
	set f .ntload
	if [Dlg_Create $f "POSSIBLE DATA FILES" "set pr_ntload 0" -borderwidth $evv(SBDR)] {
		frame $f.1
		frame $f.2
		frame $f.2.1
		label $f.1.qu -text ""
		label $f.1.se -text "DATA FILES\nSelect a file with mouse\nto load data to Free Harmony workshop" -fg $evv(SPECIAL)
		set ntloadlist [Scrolled_Listbox $f.1.ll -width 48 -height 24 -selectmode single]
		button $f.2.1.qu -text Close -command "set pr_ntload 1" -highlightbackground [option get . background {}]
		pack $f.2.1.qu -side right
		label $f.2.se -text "FILTER FILES\nSelect a file with mouse\nTo run filter immediately" -fg $evv(SPECIAL)
		set ntloadflist [Scrolled_Listbox $f.2.ll -width 48 -height 24 -selectmode single]
		pack $f.1.qu $f.1.se -side top -pady 2
		pack $f.1.ll -side top -pady 2 -fill both -expand true
		pack $f.2.1 -side top -pady 2 -fill x -expand true
		pack $f.2.se -side top -pady 2
		pack $f.2.ll -side top -pady 2 -fill both -expand true
		pack $f.1 $f.2 -side left -padx 3
		bind $ntloadlist <ButtonRelease-1> "NTTryDataLoad $ntloadlist %y $srate"
		bind $ntloadflist <ButtonRelease-1> "NTRunFilter $ntloadflist %y"
		bind $f <Return> {set pr_ntload 0}
		bind $f <Escape> {set pr_ntload 0}
		bind $f <Key-space> {set pr_ntload 0}
	}
	$ntloadlist delete 0 end
	foreach fnam $posdats {
		$ntloadlist insert end $fnam
	}	
	$ntloadflist delete 0 end
	foreach zz $nt_posfdats {
		set fnam [lindex $zz 0]
		$ntloadflist insert end $fnam
	}	
	set nt_g 1
	raise $f
	set pr_ntload 0
	My_Grab 0 $f pr_ntload $f.1.ll.list
	tkwait variable pr_ntload
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#----- Try to Load a Free Harmony Data File

proc NTTryDataLoad {listing y srate} {
	global nt_indataname pr_ntload
	set i [$listing nearest $y]
	if {$i < 0} {
		return 0
	}
	set i [$listing curselection]
	set nt_indataname [$listing get $i]
	if {![DoNTLoadParams 0 $srate]} {
		set nt_indataname ""
		.nt.bb.ple config -text $nt_indataname
		return
	}
	.nt.bb.ple config -text $nt_indataname
	set pr_ntload 1
}

#----- Check text file for Free Harmony Data Syntax

proc HasNTSyntax {outlist nyq start} {
	set haspar 1
	set n 0
	foreach val $outlist {
		switch -- $n {
			0 {
				if {![IsNumeric $val] || ($val < 0.2) || ($val > 3600)} {
					if {!$start} {
						Inf "Not A Valid Data File"
					}
					return -1
				}
			}
			1 {
				if {![IsNumeric $val] || ($val < 10) || ($val > 10000)} {
					if {!$start} {
						Inf "Not A Valid Data File"
					}
					return -1
				}
			}
			2 {
				if {![IsNumeric $val] || ($val < 0) || ($val > 6)} {
					if {!$start} {
						Inf "Not A Valid Data File"
					}
					return -1
				}
			}
			3 {	
				if {![IsNumeric $val] || ($val < 0) || ($val > 100)} {
					if {!$start} {
						Inf "Not A Valid Data File"
					}
					return -1
				}
			}
			4 {
				if {![IsNumeric $val] || ($val < 1) || ($val > 200)} {
					if {!$start} {
						Inf "Not A Valid Data File"
					}
					return -1
				}
			}
			5 {
				if {![IsNumeric $val] || ($val > 0) || ($val < -96)} {
					if {!$start} {
						Inf "Not A Valid Data File"
					}
					return -1
				}
			}
			6 {
				if {![IsNumeric $val] || ($val < 1)} {
					if {!$start} {
						Inf "Not A Valid Data File"
					}
					return -1
				}
				set len $val
				set lenleft [expr [llength $outlist] - $n - 1]
				if {$val > [expr $lenleft - 2]} {
					if {!$start} {
						Inf "Not A Valid Data File"
					}
					return -1
				}
				incr n
				set m 0
				while {$m < $len} {
					set val [lindex $outlist $n]
					if {![IsNumeric $val] || ($val < 6.0) || ($val >= $nyq)} {
						if {!$start} {
							Inf "Not A Valid Data File"
						}
						return -1
					}
					incr n
					incr m
				}
				set val [lindex $outlist $n]
				if {![IsNumeric $val] || ($val < 0)} {
					if {!$start} {
						Inf "Not A Valid Data File"
					}
					return -1
				}
				set len $val
				set lenleft [expr [llength $outlist] - $n - 1]
				if {$val > [expr $lenleft - 1]} {
					if {!$start} {
						Inf "Not A Valid Data File"
					}
					return -1
				}
				incr n
				set m 0
				while {$m < $len} {
					set val [lindex $outlist $n]
					if {![IsNumeric $val] || ($val < 0.0) || ($val > 1.0)} {
						if {!$start} {
							Inf "Not A Valid Data File"
						}
						return -1
					}
					incr n
					incr m
				}
				set val [lindex $outlist $n]
				if {![IsNumeric $val] || ($val < 0)} {
					if {!$start} {
						Inf "Not A Valid Data File"
					}
					return -1
				}
				set len $val
				set lenleft [expr [llength $outlist] - $n - 1]
				if {$lenleft != $val} {
					if {!$start} {
						Inf "Not A Valid Data File"
					}
					return -1
				}
				if {$len > 0} {
					incr n
					set m 0
					while {$m < $len} {
						set val [lindex $outlist $n]
						if {[llength $val] != 2} { 
							if {!$start} {
								Inf "Not A Valid Data File"
							}
						}
						set pno [lindex $val 0]		
						if {![IsNumeric $pno] || ($pno < 1) || ($pno > 200)} {
							if {!$start} {
								Inf "Not A Valid Data File"
							}
							return -1
						}
						set pamp [lindex $val 1]		
						if {![IsNumeric $pamp] || ($pamp < 0) || ($pamp > 1)} {
							if {!$start} {
								Inf "Not A Valid Data File"
							}
							return -1
						}
						incr n
						incr m
					}
				} else {
					set haspar 0
				}
				break
			}
		}
		incr n
	}
	return $haspar
}

#---- Attempt to run Free Harmony Workshop with loaded filter.

proc NTRunFilter {listing y} {
	global nt_pprg nt_filtfile nt_filtfile_given nt_posfdats pr_ntload pr_nt
	set i [$listing nearest $y]
	if {$i < 0} {
		return
	}
	set filt_data [lindex $nt_posfdats $i]
	set nt_filtfile [lindex $filt_data 0]
	set nt_pprg [lindex $filt_data 1]
	set nt_filtfile_given 1
	set pr_ntload 1
	set pr_nt 1
}

#----- Check validity of varibank or varibank2 filter

proc NTCheckFiltValidity {fnam nyq} {
	global nt_hcnt nt_h

	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open Filter Data File '$fnam'"
		return ""
	}
	set filtcnt 0
	set partcnt -1
	set is_partials 0
	set partials_cnt 0
	set linecnt 1
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {([llength $line] <= 0) || [string match [string index $line 0] ";"]} {
			incr linecnt
			continue
		}
		set line [split $line]
		catch {unset nuline}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend nuline $item
			}
		}
		if {![info exists nuline]} {
			continue
		}
		if {[string match "#" [string index $line 0]]} {
			if {$partcnt > 0} {
				;#	NOT A VALID FILTER DATA FILE: Spurious '#' line found
				close $zit
				return ""
			}
			if {$filtcnt < 2} {
				;#	NOT A VALID FILTER DATA FILE: Insufficient filter data
				close $zit
				return ""
			}
			set partcnt 0
			set is_partials 1
			incr linecnt
			continue
		} elseif {$filtcnt == 0 || $partcnt == 0} {
			set baslen [llength $nuline]
			if {[IsEven $baslen]} {
				;#	NOT A VALID FILTER DATA FILE: Wrong number of entries
				close $zit
				return ""
			}
			set lasttime [lindex $nuline 0]
			if {![IsNumeric $lasttime] || ($lasttime != 0.0)} {
				;#	NOT A VALID FILTER DATA FILE: Invalid time value
				close $zit
				return ""
			}
		} else {
			if {[llength $nuline] != $baslen} {
				;#	NOT A VALID FILTER DATA FILE: LINE OF INCORRECT LENGTH
				close $zit
				return ""
			}
			set time [lindex $nuline 0]
			if {$time <= $lasttime} {
				;#	NOT A VALID FILTER DATA FILE: TIMES OUT OF SEQUENCE At LINE
				close $zit
				return ""
			}
		}
		set isfrq 1
		foreach item [lrange $nuline 1 end] {
			if {$isfrq} {
				if {$is_partials} {
					if {$item < 1.0 || [expr $item * $maxfrq] > $nyq} {
						;#	NOT A VALID FILTER DATA FILE: Partial out of range
						close $zit
						return ""
					}
					if {$partcnt == 0} {
						incr partials_cnt
					}
				} else {
					if {$item < 9.0 || $item >= $nyq} {
						;#	NOT A VALID FILTER DATA FILE: Frq out of range
						close $zit
						return ""
					}
					if {$filtcnt == 0} {
						set maxfrq $item
					} elseif {$item > $maxfrq} {
						set maxfrq $item
					}
				}
			} else {
				if {$item < 0.0 || $item > 1.0} {
					;#	NOT A VALID FILTER DATA FILE: Amplitude out of range (0-1)
					close $zit
					return ""
				}
			}
			set isfrq [expr !$isfrq]
		}
		if {$is_partials} {
			incr partcnt
		} else {
			incr filtcnt
		}
		incr linecnt
	}
	close $zit
	if {$partcnt == 0} {
		set nt_hcnt [expr int(floor($nyq / $maxfrq))]
		if {$nt_hcnt < 1} {
			;#	"FREQUENCY TOO HIGH"
			return ""
		}
		if {[info exists nt_h] && [Is_Numeric $nt_h] && ($nt_h < $hcnt)} {
			set nt_hcnt $nt_h
		}
		return "varibank"
	}
	set nt_hcnt 0
	return "varibank2"
}

proc FH_Maxsamp {fnam} {
	global maxsamp_line evv CDPmaxId done_maxsamp
	catch {unset maxsamp_line}
	set done_maxsamp 0
	set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
	lappend cmd $fnam
	if [catch {open "|$cmd"} CDPmaxId] {
		ErrShow "$CDPmaxId"
		return
	} else {
	   	fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
	}
	vwait done_maxsamp
	catch {close $CDPmaxId}
	if {[info exists maxsamp_line]} {
		set max_samp [lindex $maxsamp_line 0]
		if {$max_samp <= 0.0} {
			Inf "Output has zero level"
			return ""
		}
		return [lindex $maxsamp_line 0]
	}
	Inf "No maximum sample information retrieved"
	return ""
}

#------ Display info returned by maxsamp

proc Display_Maxsamp_Info2 {} {
	global CDPmaxId done_maxsamp maxsamp_line

	if [eof $CDPmaxId] {
		catch {close $CDPmaxId}
		set done_maxsamp 1
		return
	} else {
		gets $CDPmaxId line
		set line [string trim $line]
		if {[string length $line] <= 0} {
			return
		}
		if [string match KEEP:* $line] {
			set maxsamp_line $line
			set done_maxsamp 1
		}
	}
	update idletasks
}

#------- Superimpose synthd chordset on chosen file

proc PlayChordsetAndFile {fnam} {
	global CDPidrun prg_dun prg_abortd program_messages wstk pa chlist evv

	if {![info exists chlist] || ([llength $chlist] <= 0)} {
		Inf "No file on chosen list"
		return
	}
	set infnam [lindex $chlist 0]
	if {![info exists pa($infnam,$evv(FTYP))] || ($pa($infnam,$evv(FTYP)) != $evv(SNDFILE))} {
		Inf "Chosen file is not a Soundfile"
		return
	}
	if {![info exists pa($infnam,$evv(MAXSAMP))]} {
		Inf "Need to get maxsamp of  file '$infnam' to run this process"
		return
	}
	set srate $pa($infnam,$evv(SRATE))
	catch {file delete cdptest00.wav}
	catch {file delete cdptest01.wav}
	Block "CREATING CHORD"
	set CDP_cmd [list synth chord 1 cdptest00.wav $fnam $srate 1 4 -a.3 -t4096]
	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	set firstword [lindex $CDP_cmd 0]
	set firstword [file join $evv(CDPROGRAM_DIR) $firstword]
	set CDP_cmd [lreplace $CDP_cmd 0 0 $firstword]
	if [catch {open "|$CDP_cmd"} CDPidrun] {
		Inf "$CDPidrun :\nCAN'T CREATE CHORD"
		UnBlock
		return
	} else {
	   	fileevent $CDPidrun readable "Display_Score_Batch_Running_Info"
	}
	vwait prg_dun
	if {$prg_abortd} {
		if [info exists program_messages] {
			Inf "$program_messages"
		}
		set prg_dun 0
	}
	if {!$prg_dun} {
		set errorline "CREATE CHORD PROCESS FAILED"
	}
	if [info exists errorline] {
		Inf "$errorline"
	}
	if [info exists program_messages] {
		Inf "$program_messages"
		unset program_messages
	}
	UnBlock
	Block "CREATING COMPARISON MIX"
	set skew $pa($infnam,$evv(MAXSAMP))
	set firstword [file join $evv(CDPROGRAM_DIR) submix]
	set CDP_cmd [list $firstword merge cdptest00.wav $infnam cdptest01.wav -k$skew]
	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	if [catch {open "|$CDP_cmd"} CDPidrun] {
		Inf "$CDPidrun :\nCan't Create Mix"
		UnBlock
		return
	} else {
	   	fileevent $CDPidrun readable "Display_Score_Batch_Running_Info"
	}
	vwait prg_dun
	if {$prg_abortd} {
		if [info exists program_messages] {
			Inf "$program_messages"
		}
		set prg_dun 0
	}
	if {!$prg_dun} {
		set errorline "Create Chord Process Failed"
	}
	if [info exists errorline] {
		Inf "$errorline"
	}
	if [info exists program_messages] {
		Inf "$program_messages"
		unset program_messages
	}
	UnBlock
	if {[file exists "cdptest01.wav"]} {
		set choice "yes"
		while {$choice == "yes"} {
			set is_playing 1
			PlaySndfile cdptest01.wav 0			;# PLAY OUTPUT
			set msg "Hear It Again ?"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		}
		if {$is_playing} {
			Inf "If There Is A Play-Program Display\nYou Must Close It Before Proceeding!!"
		}
	}
}

proc CreateFreeHarmonyData {} {
	global pr_fhd pr_fhd2 fhd_name wstk nt_fftab nt_aftab nt_pftab freeharm evv

	set f .fhd
	set freeharm 1
	if [Dlg_Create $f "FREE HARMONY DATA" "set pr_fhd 0" -width 60 -borderwidth $evv(SBDR)] {
		set f1 [frame $f.1]
		set f2 [frame $f.2]
		button $f1.quit -text "Close" -command {set pr_fhd 0} -highlightbackground [option get . background {}]
		pack $f1.quit -side right
		button $f2.frq -text "Frequency Data" -command "Dlg_MakeTextfile 0 0; set pr_fhd 1" -width 14 -highlightbackground [option get . background {}]
		button $f2.amp -text "Amplitude Data" -command "Dlg_MakeTextfile 0 0; set pr_fhd 2" -width 14 -highlightbackground [option get . background {}]
		button $f2.par -text "Partials Data" -command  "Dlg_MakeTextfile 0 0; set pr_fhd 3" -width 14 -highlightbackground [option get . background {}]
		pack $f2.frq $f2.amp $f2.par -side left -padx 2 
		pack $f1 -side top -fill x -expand true
		pack $f2 -side top -pady 2
		wm resizable $f 1 1
		bind $f <Escape>  {set pr_fhd 0}
	}
	set fhd_name ""
	raise $f
	update idletasks
	StandardPosition $f
	set finished 0
	set pr_fhd 0
	My_Grab 0 $f pr_fhd
	while {!$finished} {
		tkwait variable pr_fhd
		if {$pr_fhd} {
			if {[string length $fhd_name] <= 0} {
				continue
			}
			if [catch {open $fhd_name "r"} zit] {
				Inf "Cannot Open File '$fhd_name' To Test Values"
				continue
			}
			set cnt 0
			set OK 1
			while {[gets $zit line] >= 0} {
				if {[string length $line] <= 0} {
					continue
				}
				set line [string trim $line]
#FEB 2022
				if {[string length $line] <= 0} {
					continue
				} elseif {[string match [string index $line 0] ";"]} {
					continue
				}
				set line [split $line]
				catch {unset nuline}
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] > 0} {
						lappend nuline $item
					}
				}
				if {![info exists nuline]} {
					continue
				}
				foreach item $nuline {
					if {![IsNumeric $item]} {
						Inf "Invalid Data ($item) In Data File"
						set OK 0
						break
					}
					switch -- $pr_fhd {
						1 {
							if {$item < 9.0 || $item > 6000.0} {
								Inf "Frq Value ($item) Out Of Range"
								set OK 0
							}
						}
						2 {
							if {$item < $evv(FLTERR) || $item > 1.0} {
								Inf "Amp Value ($item) Out Of Range"
								set OK 0
							}
						}
						3 {
							if {[IsEven $cnt]} {
								if {$item < 1.0} {
									Inf "Invalid Partial No. ($item)"
									set OK 0
								}
							} elseif {$item < $evv(FLTERR) || $item > 1.0} {
								Inf "Partial Amplitude Value ($item) Out Of Range"
								set OK 0
							}
						}
					}
					if {!$OK} {
						break
					}
					incr cnt
				}
				if {!$OK} {
					break
				}
			}
			close $zit
			if {!$OK} {			
				continue
			}
			switch -- $pr_fhd  {
				1 {	set ll $nt_fftab }
				2 { set ll $nt_aftab }
				3 { set ll $nt_pftab }
			}
			foreach fnam [$ll get 0 end] {
				if {[string match $fnam $fhd_name]} {
					set OK 0
					break
				}
			}
			if {$OK} {
				$ll insert end $fhd_name
			}
			break
		} else {
			break
		}
	}
	unset freeharm
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

######################
#  PITCH CORRECTION  #
######################

proc CorrectPitch {} {
	global pr_pcorr pcorr_outfnam pcorr_oct wl chlist wstk zbankgrafix pcorrlist pcorr_outshow pcorr_inlines pcorr_outlines pa evv 
	global set pm_key pm_mode pm_numidilist pcorr_fnam pcorr_lastmaxfrq pcorr_last_partialcnt pcorr_infnam p_corr_src pcorr_smoothed
	global pcorrfnam_anal pcorrfnam_pichsnd pcorrfnam_preenv_pichsnd p_corr_env pcorr_lo pcorr_hi pcorr_last_smooth pcorr_previous
	global pcorr_no_sibil pcorrfnam_srcpitch_snd_stored pcorrfnam_pich_stored pcorrfnam_bothsnd_stored pcorrfnam_bothsnd_toplay 
	global pcorr_last_smoothed_file_used_with_src pcorrfnam_frq pcorrfnam_spec pcorrfnam_psuedosrc pcorr_recyc
	global pcorr_frq pcorr_asmidi pcorr_nudge pcorr_blokstartval pcorr_blokendval pcorrblokstart pcorrblokend pcorr_limits
	global pcorr_blokstartval pcorr_blokendval orig_pcorr_startval orig_pcorr_endval final_pcorr_startval final_pcorr_endval pcorr_nujd
	global pcorr_last_outstate_played pcorr_last_smooth_played pcorr_prevch pcorr_njshift pcorr_njset pcorr_wl pcorr_indexlist
	global pcoorr_postlist pcorr_recall pcorr_pm_numidilist pcorr2_pm_numidilist pcorrfnam_temppichsnd pcorr_intermediate
	global pcorr_orig_inlines	

	if {![info exists pcorr_previous]} {
		PcorrLoad
	}
	set pcorr_last_smooth $evv(PCR_ORIGINAL)
	catch {unset pcorr_recyc}
	catch {unset pcorr_last_smoothed_file_used_with_src}
	catch {unset pcorr_last_outstate_played}
	catch {unset p_corr_src}
	catch {unset pcorr_infnam}
	catch {unset pcorr_last_smooth_played}
	set pm_key 0
	set pm_mode 0
	catch {unset pm_numidilist}
	catch {unset pcorr_pm_numidilist}
	catch {unset pcorr2_pm_numidilist}
	catch {ClearPitchGrafix $zbankgrafix}
	catch {unset pcorr_lastmaxfrq}
	catch {unset pcorr_last_partialcnt}
	catch {unset pcorr_frq}
	catch {unset pcorr_outlines}
	catch {unset pcorr_indexlist}
	catch {unset pcoorr_postlist}

	set final_pcorr_startval -1
	set final_pcorr_endval -1
	set orig_pcorr_startval -1
	set orig_pcorr_endval -1
	set pcorr_smoothed 0
	set pcorr_asmidi 0
	set pcorr_nujd 0

	set pcorrfnam_anal $evv(DFLT_OUTNAME)
# RWD 2023 was ANALFILE_EXT
	append pcorrfnam_anal "1" $evv(ANALFILE_OUT_EXT)

	set pcorrfnam_pichsnd $evv(DFLT_OUTNAME)
	append pcorrfnam_pichsnd "2" $evv(SNDFILE_EXT)

	set pcorrfnam_temppichsnd $evv(DFLT_OUTNAME)
	append pcorrfnam_temppichsnd "3" $evv(SNDFILE_EXT)

	set p_corr_env $evv(DFLT_OUTNAME)
	append p_corr_env "3" $evv(TEXT_EXT)

	set pcorrfnam_srcpitch_snd_stored $evv(DFLT_OUTNAME)
	append pcorrfnam_srcpitch_snd_stored "4" $evv(SNDFILE_EXT)

	set pcorrfnam_pich_stored $evv(DFLT_OUTNAME)
	append pcorrfnam_pich_stored "5" $evv(SNDFILE_EXT)

	set pcorrfnam_bothsnd_stored $evv(DFLT_OUTNAME)
	append pcorrfnam_bothsnd_stored "6" $evv(SNDFILE_EXT)

	set pcorrfnam_bothsnd_toplay $evv(DFLT_OUTNAME)
	append pcorrfnam_bothsnd_toplay "7" $evv(SNDFILE_EXT)

	set pcorrfnam_psuedosrc $evv(DFLT_OUTNAME)
	append pcorrfnam_psuedosrc "8" $evv(TEXT_EXT)

	set pcorrfnam_frq $evv(DFLT_OUTNAME)
	append pcorrfnam_frq "0" $evv(PITCHFILE_EXT)

	set pcorrfnam_spec $evv(DFLT_OUTNAME)
	append pcorrfnam_spec "1" $evv(TEXT_EXT)

	set pcorr_intermediate $evv(DFLT_OUTNAME)
	append pcorr_intermediate "8" $evv(TEXT_EXT)

	set ilist [$wl curselection]
	if {[llength $ilist] != 2} {
		set pcorr_wl -1
		if {[info exists chlist] && ([llength $chlist] == 2)} {
			set fnam0 [lindex $chlist 0]
			set fnam1 [lindex $chlist 1]
		} else {
			Inf "Select A Pitch Data File & The (Mono) Sndfile From Which The Pitch Was Extracted"
			return
		}
	} else {
		set fnam0 [$wl get [lindex $ilist 0]]
		set fnam1 [$wl get [lindex $ilist 1]]
		set pcorr_wl $ilist
	}
	set ftyp0 $pa($fnam0,$evv(FTYP))
	set ftyp1 $pa($fnam1,$evv(FTYP))
	if {($ftyp0 & $evv(IS_A_PITCH_BRKFILE)) || ($ftyp0 & $evv(IS_AN_UNRANGED_BRKFILE)) || ($ftyp0 == $evv(PITCHFILE))} {
		set pcorr_infnam $fnam0
		if {($ftyp1 == $evv(SNDFILE)) && ($pa($fnam1,$evv(CHANS)) == 1)} {
			set p_corr_src $fnam1
		}
	} elseif {($ftyp1 & $evv(IS_A_PITCH_BRKFILE)) || ($ftyp1 & $evv(IS_AN_UNRANGED_BRKFILE)) || ($ftyp1 == $evv(PITCHFILE))} {
		set pcorr_infnam $fnam1
		if {($ftyp0 == $evv(SNDFILE)) && ($pa($fnam0,$evv(CHANS)) == 1)} {
			set p_corr_src $fnam0
		}
	}
	if {![info exist pcorr_infnam] || ![info exist p_corr_src]} {
		Inf "You Must Use A Pitchdata File And The (Mono) Sound File From Which The Pitch Is Extracted"
		return
	}
	if {$pa($pcorr_infnam,$evv(FTYP)) == $evv(PITCHFILE)} {
		if {![PcorrPtobrk]} {
			return 
		}
	}
	if [catch {open $pcorr_infnam "r"} zit] {
		Inf "Cannot Open File '$pcorr_infnam' To Read Pitch Data"
		return
	}
	while {[gets $zit line] >= 0} {
		lappend lines $line
	}
	close $zit
	foreach line $lines {
		set line [string trim $line]
#FEB 2022
		if {[string length $line] <= 0} {
			continue
		} elseif {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		catch {unset nuline}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend nuline $item
			}
		}
		set val [lindex $nuline 0]
		if {($val < 0) && ($val != -1) && ($val != -2)} {
			Inf "File '$pcorr_infnam' Is Not A Pitchdata File"
			return
		}
		if {[llength $nuline] != 2} {
			Inf "Anomaly In Data: Not Corectly Paired"
			return
		}
		lappend nulines $nuline
	}
	if {![info exists nulines]} {
		Inf "No Data Found In Pitchdata File"
		return
	}
	set pcorr_orig_infnam $pcorr_infnam
	set pcorr_inlines $nulines
	set pcorr_orig_inlines $pcorr_inlines

	set pcorr_fnam $evv(DFLT_OUTNAME)
	append pcorr_fnam "0" $evv(TEXT_EXT)

	set pcorr_outshow 0

	set f .p_corr
	if [Dlg_Create $f "PITCH CORRECTION" "set pr_pcorr 0" -width 60 -borderwidth $evv(SBDR)] {
		set ftop [frame $f.0]
		frame $f.00 -height 1 -bg [option get . foreground {}]
		set fmid [frame $f.m]
		frame $f.01 -height 1 -bg [option get . foreground {}]
		set fbot [frame $f.1]
		set fa [frame $fbot.a]
		set fb [frame $fbot.b -width 1 -bg [option get . foreground {}]]
		set fc [frame $fbot.c]
		set fx [frame $fa.x -height 1 -bg [option get . foreground {}]]
		set f0 [frame $fa.0]
		set f1 [frame $fa.1]
		set f2 [frame $fa.2]
		set f2a [frame $fa.2a]
		set f3 [frame $fa.3]
		set f4 [frame $fa.4]
		button $ftop.help -text "Help" -bg $evv(HELP) -command PitchCorrHelp -highlightbackground [option get . background {}]
		button $ftop.keep -text "Save Data Displayed to File" -command "set pr_pcorr 2" -highlightbackground [option get . background {}]
		label $ftop.ll -text "outfile name  "
		entry $ftop.e -textvariable pcorr_outfnam -width 16
		label $ftop.mono -text "SOURCE FILES MUST BE MONO" -fg $evv(SPECIAL)
		button $ftop.quit -text "Abandon" -command "set pr_pcorr 0" -highlightbackground [option get . background {}]
		pack $ftop.help $ftop.keep $ftop.ll $ftop.e -side left -padx 2
		pack $ftop.mono -side left -padx 2
		pack $ftop.quit -side right
		pack $ftop -side top -fill x -expand true
		pack $f.00 -side top -pady 6 -fill x -expand true
		button $fmid.playpsrc -text "Play Pitch" -command "PlayPcorr" -bg $evv(HELP) -width 14 -highlightbackground [option get . background {}]
		button $fmid.playsrc  -text "Play Source" -command "PlaySndfile $p_corr_src 0" -bg $evv(HELP) -width 14 -highlightbackground [option get . background {}]
		button $fmid.playwith -text "Play Both" -command "PlayPcorrWith 0" -bg $evv(HELP) -width 14 -highlightbackground [option get . background {}]
		button $fmid.kandr -text "Output Vals as Input" -command "set pr_pcorr 3" -highlightbackground [option get . background {}]
		button $fmid.sndv -text "Sound View" -command "PlayPcorrWith 1" -bg $evv(SNCOLOR) -width 14 -highlightbackground [option get . background {}]
		pack $fmid.playpsrc $fmid.playsrc $fmid.playwith $fmid.kandr -side left -padx 2
		pack $fmid.sndv -side right -padx 2
		pack $fmid -side top -fill x -expand true
		pack $f.01 -side top  -pady 4 -fill x -expand true
		label $f0.sm -text "SMOOTH ALL DATA" -fg $evv(SPECIAL)
		pack $f0.sm -side top -pady 2
		button $f1.do -text "Do Smoothing" -command "set pr_pcorr 1" -highlightbackground [option get . background {}]
		button $f1.save -text "Save Last Params Used" -command PcorrSave -highlightbackground [option get . background {}]
		button $f1.load -text "Load Params" -command PcorrGet -highlightbackground [option get . background {}]
		pack $f1.do -side left
		pack $f1.load $f1.save -side right -padx 2
		label $f2.ll -text "Initial 8va correction "
		entry $f2.e -textvariable pcorr_oct -width 4
		pack $f2.e $f2.ll -side left -padx 2
		checkbutton $f2.sibil -text "\"Noise\" Flags to \"No Signal\" Flags" -variable pcorr_no_sibil
		pack $f2.sibil -side right
		label $f3.ini -text "VALUES IN INPUT DATA FILE" -fg $evv(SPECIAL)
		set pcorrlist [Scrolled_Listbox $f3.ll -width 48 -height 24 -selectmode extended]
		frame $f3.radio
		radiobutton $f3.radio.in  -text "Show Input Values" -value 0 -variable pcorr_outshow -width 14 -command ShowPcorr 
		radiobutton $f3.radio.out -text "Show Output Values" -value 1 -variable pcorr_outshow -width 14 -command ShowPcorr  
		pack $f3.radio.in $f3.radio.out -side left
		pack $f3.radio -side top
		pack $f3.ini $f3.ll -side top -pady 2 -fill both -expand true
		pack $f0 $f1 $f2 $f2a -side top -pady 2 -fil x -expand true
		pack $fx -side top  -pady 4 -fill x -expand true
		pack $f3 -side top -pady 2
		label $f4.lab -text "CHANGE HIGHLIGHTED DATA" -fg $evv(SPECIAL)
		frame $f4.0 -height 1 -bg [option get . foreground {}]
		frame $f4.zz
		checkbutton $f4.zz.midi -text "Show brkpnt display as MIDI" -variable pcorr_asmidi -command "PcorrMidi"
		radiobutton $f4.zz.prev -text "Set Highlighting as previously" -variable pcorr_prevch -command "PcorrHilitePrevious"
		pack $f4.zz.midi $f4.zz.prev -side left
		frame $f4.1
		frame $f4.1.nuj1 
		label $f4.1.nuj1.nuj -text "SET MOVE-STEP AS  "
		radiobutton $f4.1.nuj1.1 -text "1/8 tone" -variable pcorr_njshift -value 0
		radiobutton $f4.1.nuj1.2 -text "semitone" -variable pcorr_njshift -value 1 
		radiobutton $f4.1.nuj1.3 -text "octave"   -variable pcorr_njshift -value 2 
		label $f4.1.nuj1.use -text "USING UP-DOWN KEYS"
		pack $f4.1.nuj1.nuj $f4.1.nuj1.1 $f4.1.nuj1.2 $f4.1.nuj1.3 $f4.1.nuj1.use -side left
		label $f4.1.nuj2 -text "MOVE START Pitch Only - CONTROL Up-Down  :  MOVE END Pitch Only - SHIFT Up-Down"
		frame $f4.1.line -height 1 -bg [option get . foreground {}]
		frame $f4.1.zet
		label $f4.1.zet.1 -text "RESET LIMITS FROM STAFF DISPLAY"
		radiobutton $f4.1.zet.2 -text "Highest at Start" -variable pcorr_njset -value 1 -command "PcorrNjSet 0"
		radiobutton $f4.1.zet.3 -text "Highest at End" -variable pcorr_njset -value 1 -command "PcorrNjSet 1"
		pack $f4.1.zet.1 $f4.1.zet.2 $f4.1.zet.3 -side left
		pack $f4.1.nuj1 $f4.1.nuj2 -side top -pady 2 
		pack $f4.1.line -side top -fill x -expand true
		pack $f4.1.nuj1 $f4.1.nuj2 $f4.1.zet -side top -pady 2 
		label $f4.2 -text "THE LIMIT PITCHES AT START AND END OF HIGHLIGHTED BLOCK (AS MIDI)"
		frame $f4.3
		radiobutton $f4.3.show -text "Show " -value 1 -variable pcorr_limits -width 14 -command ShowPcorrLims
		label $f4.3.stt -text " Start "
		set pcorrblokstart [entry $f4.3.e -textvariable pcorr_blokstartval -width 14 -state disabled -disabledforeground [option get . foreground {}]]
		label $f4.3.end -text " End "
		set pcorrblokend [entry $f4.3.e2 -textvariable pcorr_blokendval -width 14 -state disabled -disabledforeground [option get . foreground {}]]
		label $f4.3.move -text "               Move " -width 12
		radiobutton $f4.3.radio -value 1 -variable pcorr_reset -command ResetPcorrLims

		pack $f4.3.show $f4.3.stt $f4.3.e $f4.3.end $f4.3.e2 $f4.3.move $f4.3.radio -side left -padx 2
		pack $f4.0 -side top -fill x -expand true
		pack $f4.lab $f4.zz -side top -pady 2
		frame $f4.4 -height 1 -bg [option get . foreground {}]
		pack $f4.2 $f4.3 -side top -pady 2
		pack $f4.4 -side top -fill x -expand true
		pack $f4.1 -side top -pady 2 -fill x -expand true
		pack $f4 -side top
		label $fc.range -text "EXPECTED RANGE"
		label $fc.mouse1 -text "Add Note: Click      Add Flat: Shift-Click"
		label $fc.mouse2 -text "Delete Note: Control-Click"
		set zbankgrafix [EstablishPmarkDisplay $fc]
		frame $fc.zet0
		label $fc.zet0.1 -text "CLEAR STAFF"
		radiobutton $fc.zet0.2 -variable pcorr_recall -value 0 -command "PcorrClearStaff"
		pack $fc.zet0.1 $fc.zet0.2 -side left
		frame $fc.zet1
		label $fc.zet1.1 -text "RECALL START/END LIMIT PITCHES"
		radiobutton $fc.zet1.2 -variable pcorr_recall -value 1 -command "PcorrStaffRecall staff"
		pack $fc.zet1.1 $fc.zet1.2 -side left
		frame $fc.zet2
		label $fc.zet2.1 -text "RECALL SMOOTHING-RANGE PITCHES"
		radiobutton $fc.zet2.2 -variable pcorr_njset -value 2 -command "PcorrStaffRecall smoothing"
		pack $fc.zet2.1 $fc.zet2.2 -side left
		pack $fc.range $fc.mouse1 $fc.mouse2 $zbankgrafix -side top -pady 2 -fill both -expand true
		pack $fc.zet0 $fc.zet1 $fc.zet2 -side top -pady 2
		pack $fa -side left
		pack $fb -side left -fill y -expand true -padx 2
		pack $fc -side left
		pack $fbot -side top -fill x -expand true
		wm resizable $f 1 1
		bind $zbankgrafix <ButtonRelease-1>			{PgrafixAddPitch $zbankgrafix %x %y 0}
		bind $zbankgrafix <Shift-ButtonRelease-1>	{PgrafixAddPitch $zbankgrafix %x %y 1}
		bind $zbankgrafix <Control-ButtonRelease-1> {PgrafixDelPitch $zbankgrafix %x %y}
		bind .p_corr <Up>	{IncrPcorr 0 1}
		bind .p_corr <Down> {IncrPcorr 0 0}
		bind .p_corr <Control-Up>	{IncrPcorr 1 1}
		bind .p_corr <Control-Down> {IncrPcorr 1 0}
		bind .p_corr <Shift-Up>	  {IncrPcorr 2 1}
		bind .p_corr <Shift-Down> {IncrPcorr 2 0}
		bind $f <Escape> {set pr_pcorr 0}
	}
	catch {ClearPitchGrafix $zbankgrafix}
	set pcorr_recall 0
	set pcorr_njset 1
	set pcorr_njshift 1
	set pcorr_blokstartval ""
	set pcorr_blokendval ""
	ForceVal $pcorrblokstart $pcorr_blokstartval
	ForceVal $pcorrblokend $pcorr_blokendval
	.p_corr.0.keep config -bg [option get . background {}]
	.p_corr.m.kandr config -bg [option get . background {}]
	set pcorr_no_sibil 0
	ClearPitchGrafix $zbankgrafix
	$pcorrlist delete 0 end
	foreach line $pcorr_inlines {
		$pcorrlist insert end $line
	}
	set pcorr_outfnam ""
	set pcorr_oct 0
	set pcorr_lo 0
	set recycled_and_saved 0
	set pcorr_hi 127
	raise $f
	update idletasks
	StandardPosition $f
	set finished 0
	set pr_pcorr 0
	My_Grab 0 $f pr_pcorr
	while {!$finished} {
		tkwait variable pr_pcorr
		switch -- $pr_pcorr {
			0 {
				break
			}
			1 {
				.p_corr.0.keep config -bg [option get . background {}]
				.p_corr.m.kandr config -bg [option get . background {}]
				set pcorr_oct [string trim $pcorr_oct]
				if {[string length $pcorr_oct] == 0} {
					set pcorr_oct 0
				}
				set num $pcorr_oct
				if {[string match [string index $pcorr_oct 0] "-"]} {
					set num [string range $pcorr_oct 1 end]
				}
				if {![regexp {^[0-9]+$} $num] || ($num > 8)} {
					Inf "Invalid Octave Transposition (Must be whole number between -8 & 8)"
					continue
				}
				set pcorr_lo 0
				set pcorr_hi 127
				if {[info exists pm_numidilist]} {
					set len [llength $pm_numidilist]
					if {($len > 0) && ($len != 2)} {
						Inf "Range Should Be Specified By 2 (And Only 2) Pitches"
						continue
					}
					if {$len > 0} {
						set pcorr_lo [lindex $pm_numidilist 0]
						set pcorr_hi [lindex $pm_numidilist 1]
						if {$pcorr_hi < $pcorr_lo} {
							set temp $pcorr_hi
							set pcorr_hi $pcorr_lo
							set pcorr_lo $temp
						}
						if {[expr $pcorr_hi - $pcorr_lo] < 12} {
							Inf "Range Should Be At Least One Octave"
							continue
						}
					} else {
						unset pm_numidilist
					}
				}
				set kk [$pcorrlist curselection] 
				set len [llength $kk]
				if {[PitchCorrection $pcorr_oct 1 $pcorr_inlines]} {
					set pcorr_outshow 1
					ShowPcorr
				}
				if {($len > 0) && ([lindex $kk 0] != -1)} {
					$pcorrlist selection clear 0 end
					foreach k $kk {
						$pcorrlist selection set $k
					}
				}
				PcorrEraseNujParams
				set pcorr_nujd 0
				.p_corr.0.keep config -bg $evv(EMPH)
				.p_corr.m.kandr config -bg $evv(EMPH)
				set pcorr_last_smooth [list $pcorr_outshow $pcorr_oct $pcorr_lo $pcorr_hi $pcorr_no_sibil $pcorr_nujd]
				set pcorr_last_smooth [concat $pcorr_last_smooth $evv(PCR_NULL_NUDGE)]
				if {[info exists pm_numidilist]} {
					set pcorr2_pm_numidilist $pm_numidilist
				}
			}
			2 {
				set save_input 0
				if {!$pcorr_outshow} {
					foreach linea $pcorr_inlines lineb $pcorr_orig_inlines {
						set not_orig 0
						set vala [lindex $linea 1]
						set valb [lindex $lineb 1]
						if {![string match $vala $valb]} {
							set not_orig 1
							break
						} 
					}
					if {$not_orig} {
						set msg "You Are Saving The Input Lines"
						if {[info exists pcorr_recyc]} {
							append msg " (Which Have Been Changed From The Original)\n"
						}
						append msg "And *Not* The Lines Output By The Last Change You Made\n\n"
						append msg "Is This Ok ??"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							continue
						} else {
							set save_input 1
							set orig_pcorr_outlines $pcorr_outlines
							set pcorr_outlines $pcorr_inlines
						}
					} else {
						if {[info exists pcorr_outlines]} {
							set msg "You Are Displaying The Original Input\n\n"
							append msg "Do You Want To Save The *Changed* Data ??\n"
							set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
							if {$choice == "no"} {
								Inf "The Data On Display Is Already In The Input File"
								continue
							}
						} else {
							Inf "The Data On Display Is Already In The Input File"
							continue
						}
					}
				}
				if {![info exists pcorr_outlines] && ![info exists pcorr_recyc]} {
					Inf "No New Data Has Been Generated"
					continue
				}
				if {[info exists pcorr_recyc]} {
					set recycled_and_saved 1
					if {[info exists pcorr_outlines]} {
						foreach linea $pcorr_outlines lineb $pcorr_intermediate {
							set vala [lindex $linea 1]
							set valb [lindex $lineb 1]
							if {![string match $vala $valb]} {
								set recycled_and_saved 0
								break
							}
						}
					}
					if {$recycled_and_saved && ![file exists $pcorr_intermediate]} {
						set pcorr_outlines $pcorr_intermediate
						set recycled_and_saved 0
					}
				}
				if {[string length $pcorr_outfnam] <= 0} {
					Inf "NO FILENAME ENTERED"
					if {$save_input} {
						set pcorr_outlines $orig_pcorr_outlines
					}
					continue
				}
				if {![ValidCDPRootname $pcorr_outfnam]} {
					if {$save_input} {
						set pcorr_outlines $orig_pcorr_outlines
					}
					continue
				}
				if {[string match $pcorr_outfnam [file rootname $pcorr_orig_infnam]]} {
					Inf "You Cannot Overwrite The Input Pitchfile '$pcorr_orig_infnam' Here"
					if {$save_input} {
						set pcorr_outlines $orig_pcorr_outlines
					}
					continue
				} 
				set ext [GetTextfileExtension brk]
				set zfnam [string tolower $pcorr_outfnam$ext]
				if {[file exists $zfnam]} {
					set msg "File '$zfnam' Already Exists: Overwrite It ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						if {$save_input} {
							set pcorr_outlines $orig_pcorr_outlines
						}
						continue
					}
				}
				if {$recycled_and_saved} {
					if [catch {file rename $pcorr_intermediate $zfnam} zit] {
						set recycled_and_saved 0
					}
				}
				if {!$recycled_and_saved} {
					if [catch {open $zfnam "w"} zit] {
						Inf "Cannot Open File '$zfnam' To Write New Pitch Data"
						if {$save_input} {
							set pcorr_outlines $orig_pcorr_outlines
						}
						continue
					}
					foreach line $pcorr_outlines {
						puts $zit $line
					}
					close $zit
				}
				if {[FileToWkspace $zfnam 0 0 0 0 1] > 0} {
					Inf "New Data In '$zfnam' On Workspace"
				}
				break
			}
			3 {
				if {![info exists pcorr_outlines]} {
					Inf "No New Data Has Been Generated"
					.p_corr.m.kandr config -bg [option get . background {}]
					return
				}
				if {[file exists $pcorr_intermediate]} {
					if [catch {file delete $pcorr_intermediate} zit] {
						Inf "Cannot Delete Existing Recycle File '$pcorr_intermediate'"
						continue
					}
				}
				if [catch {open $pcorr_intermediate "w"} zit] {
					Inf "Cannot Open File '$pcorr_intermediate' To Write New Pitch Data"
					continue
				}
				foreach line $pcorr_outlines {
					puts $zit $line
				}
				close $zit
				set pcorr_infnam $pcorr_intermediate
				set pcorr_recyc $pcorr_outlines
				if {[file exists $pcorr_fnam] && [catch {file delete $pcorr_fnam} zit]} {
					Inf "Cannot Delete File '$pcorr_fnam'"
					break
				}
				if {[file exists $pcorrfnam_anal] && [catch {file delete $pcorrfnam_anal} zit]} {
					Inf "Cannot Delete File '$pcorrfnam_anal'"
					break
				}
				if {[file exists $pcorrfnam_frq] && [catch {file delete $pcorrfnam_frq} zit]} {
					Inf "Cannot Delete File '$pcorrfnam_frq'"
					break
				}
				if {[file exists $pcorrfnam_spec] && [catch {file delete $pcorrfnam_spec} zit]} {
					Inf "Cannot Delete File '$pcorrfnam_spec'"
					break
				}
				if {[file exists $pcorrfnam_pichsnd] && [catch {file delete $pcorrfnam_pichsnd} zit]} {
					Inf "Cannot Delete File '$pcorrfnam_pichsnd'"
					break
				}
				if {[file exists $pcorrfnam_temppichsnd] && [catch {file delete $pcorrfnam_temppichsnd} zit]} {
					Inf "Cannot Delete File '$pcorrfnam_temppichsnd'"
					break
				}
				if {[file exists $pcorrfnam_srcpitch_snd_stored] && [catch {file delete $pcorrfnam_srcpitch_snd_stored} zit]} {
					Inf "Cannot Delete File '$pcorrfnam_srcpitch_snd_stored'"
					break
				}
				if {[file exists $pcorrfnam_pich_stored] && [catch {file delete $pcorrfnam_pich_stored} zit]} {
					Inf "Cannot Delete File '$pcorrfnam_pich_stored'"
					break
				}
				if {[file exists $pcorrfnam_bothsnd_stored] && [catch {file delete $pcorrfnam_bothsnd_stored} zit]} {
					Inf "Cannot Delete File '$pcorrfnam_bothsnd_stored'"
					break
				}
				if {[file exists $p_corr_env] && [catch {file delete $p_corr_env} zit]} {
					Inf "Cannot Delete File '$p_corr_env'"
					break
				}
				PcorrSave
				catch {unset pcorr_last_smoothed_file_used_with_src}
				$pcorrlist delete 0 end
				set pcorr_inlines $pcorr_outlines
				foreach line $pcorr_inlines {
					$pcorrlist insert end $line
				}
				unset pcorr_outlines
				.p_corr.1.a.3.ini config -text "VALUES IN INPUT DATA FILE"
				.p_corr.m.kandr config -bg [option get . background {}]
				set pcorr_outshow 0
				set pcorr_smoothed 0
				catch {unset pm_numidilist}
				ClearPitchGrafix $zbankgrafix
				catch {unset pcorr_last_smooth}
				catch {unset pcorr_lastmaxfrq}
				catch {unset pcorr_last_partialcnt}
				catch {unset pcorr_frq}
				set pcorr_asmidi 0
				set pcorr_no_sibil 0
				set pcorr_outfnam ""
				set pcorr_oct 0
				set pcorr_lo 0
				set pcorr_hi 127
			}
		}
	}
	catch {unset pm_numidilist}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	DeleteAllTemporaryFiles
	catch {unset pcorr_lastmaxfrq}
	catch {unset pcorr_last_partialcnt}
	catch {unset pcorr_outlines}
	catch {unset pcorr_frq}
	if {$pcorr_wl >= 0} {
		$wl selection clear 0 end
		foreach i $pcorr_wl {
			$wl selection set $i
		}
	}
}

#---- Correctpitch of pitch-text data

proc PitchCorrection {initial_transposition_in_octaves withmsgs lines} {
	global pcorr_outlines pcorr_lo pcorr_hi pcorr_no_sibil evv
	set corrections 0
	foreach line $lines {
		lappend times	[lindex $line 0]
		lappend pitches [lindex $line 1]
	}
	set ratio 1.0
	if {$initial_transposition_in_octaves !=0} {
		set ratio [expr pow(2.0,$initial_transposition_in_octaves)]
	}
	set origpitches $pitches
	foreach pitch $pitches {
		if {$pitch <  0} {
			if {$pcorr_no_sibil} {
				set newpitch -2
			} else {
				set newpitch $pitch
			}
		} else {
			set newpitch [expr $pitch * $ratio]
			set newpitch [UnconstrainedHzToMidi $newpitch]
		}
		lappend newpitches $newpitch
	}
	set pitches $newpitches
	unset newpitches
	set len [llength $pitches]
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set thatpitch [lindex $pitches $n]
		set m [expr $n + 1]
		set thispitch [lindex $pitches $m]
		if {($thatpitch < 0) || ($thispitch < 0)} {
			incr n
			continue
		}
		set startpitch $thispitch
		set interval [expr abs($thispitch - $thatpitch)]
		set done 0
		while {!$done} {
			set newpitch [expr $thispitch + $evv(SEMITONES_PER_OCTAVE)]
			set newinterval [expr abs($newpitch - $thatpitch)]
			if {$newinterval >= $interval} {
				set done 1
			} else {
				set interval $newinterval
				set thispitch $newpitch
			}
		}
		if {$thispitch == $startpitch} {
			set done 0
			while {!$done} {
				set newpitch [expr $thispitch - $evv(SEMITONES_PER_OCTAVE)]
				set newinterval [expr abs($newpitch - $thatpitch)]
				if {$newinterval >= $interval} {
					set done 1
				} else {
					set interval $newinterval
					set thispitch $newpitch
				}
			}
		}
		if {$thispitch != $startpitch} {
			incr corrections
			set pitches [lreplace $pitches $m $m $thispitch]
		}
		incr n
	}
	foreach pitch $pitches {
		if {$pitch >= 0} {
			while {$pitch < $pcorr_lo} {
				set pitch [expr $pitch + $evv(SEMITONES_PER_OCTAVE)] 
				set corrections 1
			} 
			while {$pitch > $pcorr_hi} {
				set pitch [expr $pitch - $evv(SEMITONES_PER_OCTAVE)] 
				set corrections 1
			}
			set newpitch [MidiToHz $pitch]
		} else {
			set newpitch $pitch
		}
		lappend newpitches $newpitch
	}
	if {!$corrections && !$initial_transposition_in_octaves} {
		if {$withmsgs} {
			Inf "No Pitch Correction Made"
		}
		return 0
	}
	catch {unset pcorr_outlines}
	foreach time $times pitch $newpitches {
		set line [list $time $pitch]
		lappend pcorr_outlines $line
	}
	return 1
}

#---- display list of pitch text-data

proc ShowPcorr {} {
	global pcorr_outshow pcorrlist pcorr_inlines pcorr_outlines pcorr_asmidi
	set kk [$pcorrlist curselection]
	set len [llength $kk]
	if {$pcorr_outshow} {
		if {![info exists pcorr_outlines]} {
			Inf "No Pitch-Corrected Data Generated Yet"
			set pcorr_outshow 0
			return
		}
		$pcorrlist delete 0 end
		foreach line $pcorr_outlines {
			$pcorrlist insert end $line
		}
		.p_corr.1.a.3.ini config -text "CORRECTED PITCH DATA"
	} else {
		$pcorrlist delete 0 end
		foreach line $pcorr_inlines {
			$pcorrlist insert end $line
		}
		.p_corr.1.a.3.ini config -text "VALUES IN INPUT DATA FILE"
	}
	set pcorr_asmidi 0
	if {([llength $kk] > 0) && ([lindex $kk 0] != -1)} {
		$pcorrlist selection clear 0 end
		foreach k $kk {
			$pcorrlist selection set $k
		}
	}
}

#---- play pitch text-data

proc PlayPcorr {} {
	global pcorrfnam_anal pcorrfnam_pichsnd pcorrfnam_srcpitch_snd_stored pcorrfnam_pich_stored

	set orig [Pcorr_CheckDisplayedParams]
	if {$orig < 0} {
		return
	}
	if {![PcorrCreatePlayfile $orig]} {
		return
	}
	if {$orig} {
		if {![file exists $pcorrfnam_srcpitch_snd_stored]} {		;# Keep sndfile from orig data, once made
			catch {file copy $pcorrfnam_pichsnd $pcorrfnam_srcpitch_snd_stored}
		}
	} else {
		if {![file exists $pcorrfnam_pich_stored]} {		;# Keep sndfile from smoothed data, once made
			catch {file copy $pcorrfnam_pichsnd $pcorrfnam_pich_stored}
		}
	}
	PlaySndfile $pcorrfnam_pichsnd 0
}

#---- create necessary file (& intermediates) to play text pitchfile contour

proc PcorrCreatePlayfile {orig} {
	global pcorr_infnam CDPidrun prg_dun prg_abortd program_messages pcorr_fnam pcorr_smoothed pcorr_last_outstate_played
	global pcorr_lastmaxfrq pcorr_last_partialcnt pcorr_inlines pcorr_outlines pcorrfnam_anal pcorrfnam_pichsnd pcorrfnam_temppichsnd
	global pcorr_outshow pcorr_oct pcorr_lo pcorr_hi pcorrlist pcorrfnam_srcpitch_snd_stored pcorrfnam_pich_stored p_corr_env pcorr_last_smooth_played
	global pcorr_last_smooth pcorr_no_sibil pcorr_asmidi pcorr_frq pcorr_nujdb pcorrfnam_frq pcorrfnam_spec
	global final_pcorr_startval final_pcorr_endval orig_pcorr_startval orig_pcorr_endval pcorr_nujd wstk evv

			;#	AVOID RECREATING THE PLAYFILE IF NOT NECESSARY

	if {[info exists pcorr_last_outstate_played]} {		
		set done 1
		while {$done} {
			if {[string match [lindex $pcorr_last_outstate_played $evv(PCR_OUTSHOW)] $pcorr_outshow]} {
				if {$pcorr_outshow == 0} {

			;# EXISTING PLAYFILE IS OF SOURCE PITCH, WHICH IS ALSO ON DISPLAY, DON'T REMAKE
					
					break
				}

			;# EXISTING PLAYFILE IS OF DATA ON DISPLAY BUT IS NOT THE SOURCE PITCH

			} else {

			;# EXISTING PLAYFILE IS NOT OF DATA ON DISPLAY : REMAKE
			
				set done 0
				break
			}								
			;#	IF WE GET TO HERE, EXISTING PLAYFILE AND DISPLAY ARE OF SMOOTHED OR NUJD DATA, BUT NOT NECESSARILY OF SAME DATA
												
			if {[lindex $pcorr_last_outstate_played $evv(PCR_NUJD)]} {

			;#	LAST PLAYFILE WAS NUJD. ARE NUJ PARAMS SAME ??

				if {![PcorrSameAsLastNujStateMade]} {

			;#	IF NOT, REMAKE

					set done 0					
				}
				break
			}
			;#	LAST PLAYFILE WAS SMOOTHED. ARE SMOOTHING PARAMS SAME ??

			if {![string match [lindex $pcorr_last_outstate_played $evv(PCR_OCTCORR)] $pcorr_oct]} {
				set done 0					;#	Existing playfile does not use octave-correction currently set
				break
			}
			if {![string match [lindex $pcorr_last_outstate_played $evv(PCR_LO)] $pcorr_lo]} {
				set done 0					;#	Existing playfile does not range low-limit currently set
				break
			}
			if {![string match [lindex $pcorr_last_outstate_played $evv(PCR_HI)] $pcorr_hi]} {
				set done 0					;#	Existing playfile does not range high-limit currently set
				break
			}
			if {![string match [lindex $pcorr_last_outstate_played $evv(PCR_NOSIBIL)] $pcorr_no_sibil]} {
				set done 0					;#	Existing playfile does not range high-limit currently set
				break
			}
			break
		}
		if {$done} {

			;#	EXISTING PLAYFILE CORRESPONDS TO DISPLAYED DATA

			return 1
		}
	}	
		;#	IF FILE TO PLAY IS SOURCE PITCH, AND THAT SNDFILE ALREADY MADE, USE IT

	if {$orig} {
		if {[file exists $pcorrfnam_srcpitch_snd_stored]} {		;#	If playing orig pitch, and sndfile still exists, use it
			set OK2 1
			while {$OK2} {
				if {![file exists $pcorrfnam_pichsnd]} {
					break
				}
				if {[catch {file delete $pcorrfnam_pichsnd}]} {
					set OK2 0
					break
				}
				break
			}
			if {$OK2} {
				if {![catch {file copy $pcorrfnam_srcpitch_snd_stored $pcorrfnam_pichsnd}]} {
					set pcorr_last_outstate_played [list $pcorr_outshow $pcorr_oct $pcorr_lo $pcorr_hi $pcorr_no_sibil $pcorr_nujd]
					lappend pcorr_last_outstate_played $final_pcorr_startval $final_pcorr_endval $orig_pcorr_startval $orig_pcorr_endval
					return 1
				}
			}
		}
		;#	IF FILE TO PLAY IS SMOOTHED/NUJD PITCH AND 
		;#	PARAMS FOR LAST SMOOTHED/NUJD-DATA CREATED CORRESPOND TO PARAMS FOR LAST SMOOTHED/NUJD-DATA PLAYED 
		;#	USE EXISTING SNDFILE

	} elseif {[info exists pcorr_last_smooth] && [info exists pcorr_last_smooth_played] && [file exists $pcorrfnam_pich_stored]} {
		set OK 1
		foreach a $pcorr_last_smooth b $pcorr_last_smooth_played {
			if {![string match $a $b]} {
				set OK 0
				break
			}
		}
		if {$OK} {
			set OK2 1
			while {$OK2} {
				if {![file exists $pcorrfnam_pichsnd]} {
					break
				}
				if {[catch {file delete $pcorrfnam_pichsnd}]} {
					set OK2 0
					break
				}
				break
			}
			if {$OK2} {
				if {![catch {file copy $pcorrfnam_pich_stored $pcorrfnam_pichsnd}]} {
					set pcorr_last_outstate_played [list $pcorr_outshow $pcorr_oct $pcorr_lo $pcorr_hi $pcorr_no_sibil $pcorr_nujd]
					lappend pcorr_last_outstate_played $final_pcorr_startval $final_pcorr_endval $orig_pcorr_startval $orig_pcorr_endval
					set pcorr_last_smooth_played $pcorr_last_outstate_played

			;#	CHECK IF DISPLAYED PARAMETERS ARE STILL SAME AS WHEN LAST USED

					if {![PcorrSndCorresSondsToDisplayedParams]} {
						set msg "Smoothed Sound Does Not Correspond To Parameters Now In Display.\n\n"
						append msg "You Must 'Do Smoothing' Before You Can Play The Data With The Displayed Parameters.\n\n"
						append msg "Do You Want To Smooth Before Playing ?"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "yes"} {
							return 0
						}
					}
					return 1
				}
			}
		}
	}

		;#	SYNTH THE FILE

	if {[file exists $pcorrfnam_frq]} {
		if [catch {file delete $pcorrfnam_frq} zit] {
			Inf "Cannot Delete Existing Temporary Pitch Binary File"
			return 0
		}
	}
	if {[file exists $pcorrfnam_anal]} {
		if [catch {file delete $pcorrfnam_anal} zit] {
			Inf "Cannot Delete Existing Temporary Analysis File"
			return 0
		}
	}
	if {[file exists $pcorrfnam_pichsnd]} {
		if [catch {file delete $pcorrfnam_pichsnd} zit] {
			Inf "Cannot Delete Existing Temporary Soundfile"
			return 0
		}
	}

	set dflt_partial_cnt 4
	set dflt_nyquist 22050
	set maxfrq 0
		
		;#	FIND MAXIMUM PARTIAL POSSIBLE FOR SYNTH

	foreach line $pcorr_inlines {
		set frq [lindex $line 1]
		if {$frq > $maxfrq} {
			set maxfrq $frq
		}
	}
	if {[info exists pcorr_outlines]} {
		foreach line $pcorr_outlines {
			set frq [lindex $line 1]
			if {$frq > $maxfrq} {
				set maxfrq $frq
			}
		}
	}
	if {![info exists pcorr_lastmaxfrq] || ($maxfrq < $pcorr_lastmaxfrq)} {
		set partial_cnt 2
		while {[expr $partial_cnt * $maxfrq] < $dflt_nyquist} {
			incr partial_cnt
			if {$partial_cnt > $dflt_partial_cnt} {
				break
			}
		}
		incr partial_cnt -1

		if {![info exists pcorr_last_partialcnt] || ($partial_cnt != $pcorr_last_partialcnt)} {

	;#	WRITE FILE DEFINING SPECTRUM OF RESYNTH

			if {[file exists $pcorrfnam_spec]} {
				if [catch {file delete $pcorrfnam_spec} zit] {
					Inf "Cannot Delete Existing Spectrum Data File"
					return 0
				}
			}
			if [catch {open $pcorrfnam_spec "w"} zit] {
				Inf "Cannot Open File To Define Spectrum Of Pitch Soundfile"
				return 0
			}
			set n 1
			while {$n <= $partial_cnt} {
				puts $zit 1
				incr n
			} 
			close $zit
		}
		set pcorr_last_partialcnt $partial_cnt
	}
	set pcorr_lastmaxfrq $maxfrq
	if {$orig} {
		set file_to_play $pcorr_infnam
	} else {

	;#	WRITE FILE DEFINING PITCH DATA

		if [catch {open $pcorr_fnam "w"} zit] {
			Inf "Cannot Open File '$pcorr_fnam' To Write New Pitch Data"
			return 0
		}
		if {$pcorr_asmidi} {
			foreach line $pcorr_frq {
				puts $zit $line
			}
		} else {
			foreach line [$pcorrlist get 0 end] {
				puts $zit $line
			}
		}
		close $zit
		set file_to_play $pcorr_fnam
	}

	;# DEAL WITH SILENCES, CREATE ENVELOPE FILE IF NECESSARY

	if {$pcorr_asmidi} {
		$pcorrlist delete 0 end
		foreach frq $pcorr_frq {
			$pcorrlist insert end $frq
		}
		set pcorr_asmidi 0
		unset pcorr_frq
	}
	foreach line [$pcorrlist get 0 end] {
		set line [split $line]
		lappend times [lindex $line 0]
		set frq [lindex $line 1]
		if {$frq < 0} {
			set is_envel 1
			lappend vals 0
		} else {
			set not_silent 1
			lappend vals 1
		}
	}
	set env [lindex $times 0]
	lappend env [lindex $vals 0]
	lappend envel $env
	foreach time [lrange $times 1 end] val [lrange $vals 1 end] {
		if {$val == $env} {
			continue
		} else {
			set env $time
			lappend env $val
			lappend envel $env
		}
	}
	set lastenv [lindex $envel end]
	set lastenvtime [lindex $lastenv 0]
	set lasttime [lindex $times end]
	if {$lastenvtime != $lasttime} {
		set env [lreplace $env 0 0 $lasttime]
		lappend envel $env
	}
	if {![info exists not_silent]} {
		Inf "No Siginificant Pitch In Data"
		return 0
	}
	if {[info exists is_envel]} {
		if [catch {open $p_corr_env "w"} zit] {
			Inf "Cannot Create Envelope File"
		} else {
			foreach env $envel {
				puts $zit $env
			}
			close $zit
		}
	} else {
		catch {delete file $p_corr_env}
	}

	;#	CREATE BINARY PITCH FILE

	set CDP_cmd [file join $evv(CDPROGRAM_DIR) brktopi]
	lappend CDP_cmd brktopi $file_to_play $pcorrfnam_frq

	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	catch {unset program_messages}
	Block "Creating Binary Pitch Data"
	if [catch {open "|$CDP_cmd"} CDPidrun] {
		Inf "$CDPidrun :\nCan't Create Sound File"
		UnBlock
		return 0
	} else {
	   	fileevent $CDPidrun readable "Display_Score_Batch_Running_Info"
	}
	vwait prg_dun
	if {$prg_abortd} {
		if [info exists program_messages] {
			Inf "$program_messages"
		}
		set prg_dun 0
	}
	if {!$prg_dun} {
		Inf "Failed To Create Pitch Binary File"
		UnBlock
		return 0
	}

	;#	CREATE ANALYSIS FILE

	set CDP_cmd [file join $evv(CDPROGRAM_DIR) repitch]
	lappend CDP_cmd synth $pcorrfnam_frq $pcorrfnam_anal $pcorrfnam_spec

	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	catch {unset program_messages}
	if [catch {open "|$CDP_cmd"} CDPidrun] {
		Inf "$CDPidrun :\nCan't Create Sound File"
		UnBlock
		return 0
	} else {
	   	fileevent $CDPidrun readable "Display_Score_Batch_Running_Info"
	}
	vwait prg_dun
	if {$prg_abortd} {
		if [info exists program_messages] {
			Inf "$program_messages"
		}
		set prg_dun 0
	}
	if {!$prg_dun} {
		Inf "Failed To Create Analysis File"
		UnBlock
		return 0
	}
	if {![Pcorr_DoSndfileRoute]} {
		UnBlock
		return 0
	}
	if {[file exists $p_corr_env]} {
		if {[file exists $pcorrfnam_temppichsnd] && [catch {file delete $pcorrfnam_temppichsnd} zit]} {
			Inf "Cannot Delete Temporary File '$pcorrfnam_temppichsnd'"
			UnBlock
			return 0
		}
		if [catch {file rename $pcorrfnam_pichsnd $pcorrfnam_temppichsnd} zit] {
			Inf "Cannot Rename Temporary File '$pcorrfnam_pichsnd'"
			UnBlock
			return 0
		}
		if {![Pcorr_Envelope]} {
			UnBlock
			return 0
		}
	}
	UnBlock
	if {$orig} {
		set pcorr_smoothed 0
	} else {
		set pcorr_smoothed 1
	}
	set pcorr_last_outstate_played [list $pcorr_outshow $pcorr_oct $pcorr_lo $pcorr_hi $pcorr_no_sibil $pcorr_nujd]
	lappend pcorr_last_outstate_played $final_pcorr_startval $final_pcorr_endval $orig_pcorr_startval $orig_pcorr_endval
	if {$pcorr_outshow} {
		set pcorr_last_smooth_played $pcorr_last_outstate_played
	}
	return 1
}

#---- create wav file from anal file

proc Pcorr_DoSndfileRoute {} {
	global CDP_cmd CDPidrun prg_dun prg_abortd program_messages pcorrfnam_anal pcorrfnam_pichsnd evv

	UnBlock
	Block "CREATING SOUNDFILE"
	set CDP_cmd [file join $evv(CDPROGRAM_DIR) pvoc]
	lappend CDP_cmd synth $pcorrfnam_anal $pcorrfnam_pichsnd

	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	catch {unset program_messages}
	if [catch {open "|$CDP_cmd"} CDPidrun] {
		Inf "$CDPidrun :\nCan't Create Sound File"
		return 0
	} else {
	   	fileevent $CDPidrun readable "Display_Score_Batch_Running_Info"
	}
	vwait prg_dun
	if {$prg_abortd} {
		if [info exists program_messages] {
			Inf "$program_messages"
		}
		set prg_dun 0
	}
	if {!$prg_dun} {
		Inf "Failed To Create Soundfile To Play"
		return 0
	}
	return 1
}

#---- create wav file from anal file

proc Pcorr_Envelope {} {
	global CDP_cmd CDPidrun prg_dun prg_abortd program_messages pcorrfnam_pichsnd pcorrfnam_temppichsnd p_corr_env evv

	UnBlock
	Block "CREATING ENVELOPE"
	set CDP_cmd [file join $evv(CDPROGRAM_DIR) modify]
	lappend CDP_cmd loudness 1 $pcorrfnam_temppichsnd $pcorrfnam_pichsnd $p_corr_env

	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	catch {unset program_messages}
	if [catch {open "|$CDP_cmd"} CDPidrun] {
		Inf "$CDPidrun :\nCan't Create Sound File"
		return 0
	} else {
	   	fileevent $CDPidrun readable "Display_Score_Batch_Running_Info"
	}
	vwait prg_dun
	if {$prg_abortd} {
		if [info exists program_messages] {
			Inf "$program_messages"
		}
		set prg_dun 0
	}
	if {!$prg_dun} {
		Inf "failed To Envelope The Soundfile"
		if [catch {file rename $pcorrfnam_temppichsnd $pcorrfnam_pichsnd} zit] {
			inf "failed To Recover Soundfile To Play"
			return 0
		}
	}
	return 1
}

#---- play text pitchfile contour with the original source sound

proc PlayPcorrWith {sndview} {
	global p_corr_src pr_pcorr_wk CDP_cmd CDPidrun prg_dun prg_abortd program_messages pcorrfnam_anal pcorrfnam_pichsnd pcorrfnam_bothsnd_stored 
	global pcorr_last_smooth pcorr_smoothed pcorr_last_smooth_played pcorr_outshow
	global pcorr_last_smoothed_file_used_with_src pcorrfnam_bothsnd_toplay wl pa wstk evv

	if {[file exists $pcorrfnam_bothsnd_toplay]} {
		if [catch {file delete $pcorrfnam_bothsnd_toplay} zit] {
			Inf "Cannot Delete Existing Temporary File '$pcorrfnam_bothsnd_toplay'"
			return
		}
	}
	set redoit 0
	if {$pcorr_outshow} {
		if {[info exists pcorr_last_smooth] && [info exists pcorr_last_smooth_played]} {
			set OK 1
			foreach a $pcorr_last_smooth b $pcorr_last_smooth_played {
				if {![string match $a $b]} {
					set OK 0
					break
				}
			}
			if {$OK} {
				if {![PcorrSndCorresSondsToDisplayedParams]} {
					set msg "Smoothed Sound Does Not Correspond To Parameters Now In Display.\n\n"
					append msg "You Must 'Do Smoothing' Before You Can Play The Data With The Displayed Parameters.\n\n"
					append msg "Do You Want To Smooth Before Playing ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						return 0
					}
				}
				if {[file exists $pcorrfnam_bothsnd_stored]} {
					set OK 1
					foreach a $pcorr_last_smoothed_file_used_with_src b $pcorr_last_smooth {
						if {![string match $a $b]} {
							set OK 0
							break
						}
						if {$OK} {
							if {$sndview} {
								PcorrSoundView $pcorrfnam_bothsnd_stored
							} else {
								PlaySndfile $pcorrfnam_bothsnd_stored 0
							}
							return 1
						}
					}
				} 
			}
			set redoit 1
		}
	}
	if {$redoit || ![file exists $pcorrfnam_pichsnd] || ($pcorr_outshow != $pcorr_smoothed)} {
		set orig [Pcorr_CheckDisplayedParams]
		if {$orig < 0} {
			return
		}
		if {![PcorrCreatePlayfile $orig]} {		;#	i.e. no reconstructed sound has been made
			return								;#	i.e. reconstructed sound does not correspond to displayed data
		}
	} else {
		if {[Pcorr_CheckDisplayedParams] < 0} {
			return
		}
	}
	Block "CREATING MIXED FILE TO PLAY"
	set CDP_cmd [file join $evv(CDPROGRAM_DIR) submix]
	lappend CDP_cmd interleave $pcorrfnam_pichsnd $p_corr_src $pcorrfnam_bothsnd_toplay

	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	catch {unset program_messages}
	if [catch {open "|$CDP_cmd"} CDPidrun] {
		Inf "$CDPidrun :\nCan't Create Sound File"
		UnBlock
		return 0
	} else {
	   	fileevent $CDPidrun readable "Display_Score_Batch_Running_Info"
	}
	vwait prg_dun
	if {$prg_abortd} {
		if [info exists program_messages] {
			Inf "$program_messages"
		}
		set prg_dun
	}
	if {!$prg_dun} {
		Inf "Failed To Create Soundfile To Play"
		UnBlock
		return
	}
	if {[file exists $pcorrfnam_bothsnd_stored]} {
		if [catch {file delete $pcorrfnam_bothsnd_stored} zit] {
			Inf "Failed To Delete File 'pcorrfnam_bothsnd_stored'\n$zit"
			return 0
		}
		if [catch {file copy $pcorrfnam_bothsnd_toplay $pcorrfnam_bothsnd_stored} zit] {
			Inf "Failed To Copy '$pcorrfnam_bothsnd_toplay' To '$pcorrfnam_bothsnd_stored'\n$zit"
			return 0
		}
	}
	UnBlock
	if {$pcorr_outshow} {
		set pcorr_last_smoothed_file_used_with_src $pcorr_last_smooth 
	} else {
		set pcorr_last_smoothed_file_used_with_src $evv(PCR_ORIGINAL)
	}
	if {$sndview} {
		PcorrSoundView $pcorrfnam_bothsnd_toplay
	} else {
		PlaySndfile $pcorrfnam_bothsnd_toplay 0
	}
}

#---- Check whether created pitch-contour playable file corresponds to parameters actually displayed currently

proc Pcorr_CheckDisplayedParams {} {
	global pcorr_outshow pcorr_last_smooth pcorr_oct pcorr_lo pcorr_hi pcorr_no_sibil pcoorr_postlist pcorr_indexlist
	global wstk zbankgrafix pm_numidilist pcorrlist pcorr_asmidi evv

	if {$pcorr_outshow == 0} {
		return 1	;#	FLAGS SRC-PITCH IS IN USE, (PARAMETERS IRRELEVANT)
	} else {
		set OK 1
		set wasnujd 0
		while {$OK} {
			if {[lindex $pcorr_last_smooth $evv(PCR_NUJD)]} {

		;#	IF SOUND WAS NUJD, ARE CURRENT NUJ PARAMS THE SAME AS THOSE USED IN PLAYABLE FILE

				set wasnujd 1					;#	Last file was nujd
				if {![PcorrSameAsNujStateDisplayed pcorr_last_smooth]} {

					set OK 0
					break
				}
			} else {

		;#	IF SOUND WAS SMOOTHED, ARE CURRENT SMOOTHING PARAMS THE SAME AS THOSE USED IN PLAYABLE FILE

				if {![string match [lindex $pcorr_last_smooth $evv(PCR_OCTCORR)] $pcorr_oct]} {
					set OK 0					;#	Existing display does not show octave-correction last used
					break
				}
				if {![string match [lindex $pcorr_last_smooth $evv(PCR_NOSIBIL)] $pcorr_no_sibil]} {
					set OK 0					;#	Existing display does not show range high-limit last used
					break
				}
				if {[lindex $pcorr_last_smooth $evv(PCR_LO)] != 0} {
					if {![info exists pm_numidilist] || ([llength $pm_numidilist] != 2)} {
						set OK 0
						break
					} elseif {![string match [lindex $pcorr_last_smooth $evv(PCR_LO)] [lindex $pm_numidilist 0]]} {
						set OK 0
						break
					} elseif {![string match [lindex $pcorr_last_smooth $evv(PCR_HI)] [lindex $pm_numidilist 1]]} {
						set OK 0
						break
					}
				} elseif {[info exists pm_numidilist] && ([llength $pm_numidilist] != 0)} {
					set OK 0
					break
				}
			}
			break
		}
		if {!$OK} {		;#	PARAMS ARE NOT THE SAME


			set msg "Existing Smoothed File Does Not Correspond To Parameters On The Display.\n\nRestore Original Params ??"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				return -1
			} else {
				if {$wasnujd} {
					if {[llength $pcorr_indexlist] <= 0} {
						Inf "Can't Find Original Parameters"
						return -1
					}
					foreach n $pcorr_indexlist {
						if {$pcorr_asmidi} {
							set line [lindex $pcorr_frq $n]
						} else {
							set line [$pcorrlist get $n]
						}
						lappend tempset [lindex $line 0] [lindex $line 1]
						incr n
					}
					foreach a $tempset b $pcoorr_postlist {
						if {$a != $b} {
							Inf "Value Block No Longer Corresponds To That In Original Action"
							return -1
						}
					}
					$pcorrlist selection clear 0 end
					foreach n $pcorr_indexlist {
						$pcorrlist selection set $n
					}
					set pcorr_blokstartval [lindex $pcorr_last_smooth $evv(PCR_STARTVAL)]
					set pcorr_blokendval [lindex $pcorr_last_smooth $evv(PCR_ENDVAL)]
					set pcorr_oct	 0
					set pcorr_lo 0
					set pcorr_hi 127
					set pcorr_no_sibil 0
					ClearPitchGrafix $zbankgrafix
					catch {unset pm_numidilist}
				} else {
					set pcorr_oct	 [lindex $pcorr_last_smooth $evv(PCR_OCTCORR)]
					set pcorr_lo [lindex $pcorr_last_smooth $evv(PCR_LO)]
					set pcorr_hi [lindex $pcorr_last_smooth $evv(PCR_HI)]
					set pcorr_no_sibil [lindex $pcorr_last_smooth $evv(PCR_NOSIBIL)]
					ClearPitchGrafix $zbankgrafix
					if {$pcorr_lo == 0 && $pcorr_hi == 127} {
						catch {unset pm_numidilist}
					} else {
						set pm_numidilist [list $pcorr_lo $pcorr_hi]
						InsertPitchGrafix $pm_numidilist $zbankgrafix
					}
				}
			}
		}
	}
	return 0	;#	FLAGS SMOOTHED/NUJD-PITCH IS IN USE, AND PARAMETERS CORRESPOND TO THOSE ON DISPLAY
}

#---- Save to file last parameters used to smooth the data

proc PcorrSave {} {
	global pcorr_last_smooth pcorr_previous evv
	if {![info exists pcorr_last_smooth]} {
		Inf "No Parameters To Save"
		return
	}
	set pcorr_previous $pcorr_last_smooth
	set fnam [file join $evv(CDPRESOURCE_DIR) pcorr$evv(CDP_EXT)]
	if [catch {open $fnam "w"} zit] {
		Inf "Cannot Open File '$fnam' To Save Parameters"
		unset pcorr_previous
		return
	}
	puts $zit $pcorr_previous
	close $zit
}

#---- Get the last parameters used to smooth the data

proc PcorrGet {} {
	global pcorr_previous pcorr_oct pcorr_lo pcorr_hi pcorr_no_sibil zbankgrafix pm_numidilist
	if {![info exists pcorr_previous]} {
		Inf "No Previous Parameters Exist"
		return
	}
	set pcorr_oct [lindex $pcorr_previous 1]
	set pcorr_lo [lindex $pcorr_previous 2]
	set pcorr_hi [lindex $pcorr_previous 3]
	set pcorr_no_sibil [lindex $pcorr_previous 4]
	ClearPitchGrafix $zbankgrafix
	if {$pcorr_lo == 0 && $pcorr_hi == 127} {
		catch {unset pm_numidilist}
	} else {
		set pm_numidilist [list $pcorr_lo $pcorr_hi]
		InsertPitchGrafix $pm_numidilist $zbankgrafix
	}
}

#---- Load from disk the last parameters used to smooth the data (if they exist)

proc PcorrLoad {} {
	global pcorr_previous evv
	set fnam [file join $evv(CDPRESOURCE_DIR) pcorr$evv(CDP_EXT)]
	if {[file exists $fnam]} {
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot Open File '$fnam' To Read Pitch-Correction Parameters"
			return
		}
	 } else {
		return
	}
	gets $zit pcorr_previous
	close $zit
}

#---- Check if existing smoothed-pitch sndfile correspond to the parameters displayed on interface

proc PcorrSndCorresSondsToDisplayedParams {} {
	global pcorr_last_outstate_played pcorr_oct pcorr_lo pcorr_hi pcorr_no_sibil pm_numidilist evv

	if {[lindex $pcorr_last_outstate_played $evv(PCR_NUJD)]} {
		if {![PcorrSameAsNujStateDisplayed pcorr_last_outstate_played]} {
			return 0
		}
	}
	if {![string match [lindex $pcorr_last_outstate_played $evv(PCR_OCTCORR)] $pcorr_oct]} {
		return 0
	}
	if {![string match [lindex $pcorr_last_outstate_played $evv(PCR_NOSIBIL)] $pcorr_no_sibil]} {
		return 0
	}
	if {[lindex $pcorr_last_outstate_played $evv(PCR_LO)] != 0} {
		if {![info exists pm_numidilist] || ([llength $pm_numidilist] != 2)} {
			return 0
		} elseif {![string match [lindex $pcorr_last_outstate_played $evv(PCR_LO)] [lindex $pm_numidilist 0]]} {
			return 0
		} elseif {![string match [lindex $pcorr_last_outstate_played $evv(PCR_HI)] [lindex $pm_numidilist 1]]} {
			return 0
		}
	} elseif {[info exists pm_numidilist] && ([llength $pm_numidilist] != 0)} {
		return 0
	}
	return 1
}

#---- Use the 'Up' and 'Down' keys to alter 8va-correction value

proc IncrOctcorr {up} {
	global pcorr_oct
	if {![IsNumeric $pcorr_oct] || [regexp {\.} $pcorr_oct]} {
		return
	}
	if {$up} {
		if {$pcorr_oct < 8} {
			incr pcorr_oct
		}
	} else {
		if {$pcorr_oct > -8} {
			incr pcorr_oct -1
		}
	}
}

#---- Highlight block of pitchdata liners corresponding to marked area on Sound View

proc PcorrSoundView {fnam} {
	global pcorr_start pcorr_end pcorrlist pcorr_asmidi evv
	set nstart -1
	catch {unset pcorr_start}
	catch {unset pcorr_end}
	SnackDisplay $evv(SN_TIMEPAIRS) pchdata $fnam 0
	if {[info exists pcorr_start] && [info exists pcorr_end]} {
		$pcorrlist selection clear 0 end
		set n 0
		foreach line [$pcorrlist get 0 end] {
			set time [lindex $line 0]
			set val [lindex $line 1]
			if {$time >= $pcorr_start} {
				if {$time <= $pcorr_end} {
					$pcorrlist selection set $n
					if {$nstart < 0} {
						set nstart $n
					}
				} else {
					break
				}
			}
			incr n
		}	
		$pcorrlist yview moveto [expr double($nstart)/double([$pcorrlist index end])]
	}
}

#---- Display data as MIDI vals

proc PcorrMidi {} {
	global pcorr_asmidi pcorr_frq pcorrlist
	set kk [$pcorrlist curselection]
	set len [llength $kk]
	switch -- $pcorr_asmidi {
		1 {
			catch {unset pcorr_frq}
			foreach line [$pcorrlist get 0 end] {
				lappend pcorr_frq $line
				set time [lindex $line 0]
				set val [lindex $line 1]
				if {$val > 0} {
					set val [UnconstrainedHzToMidi $val]
				}
				set nuline $time
				lappend nuline $val
				lappend nulines $nuline
			}
			$pcorrlist delete 0 end
			foreach line $nulines {
				$pcorrlist insert end $line
			}
		}
		0 {
			$pcorrlist delete 0 end
			foreach line $pcorr_frq {
				$pcorrlist insert end $line
			}
			catch {unset pcorr_frq}
		}
	}
	if {($len > 0) && ([lindex $kk 0] != -1)} {
		set kbase [lindex $kk 0]
		if {$kbase >= 0} {	
			foreach k $kk {
				$pcorrlist selection set $k
			}
			$pcorrlist yview moveto [expr double($kbase)/double([$pcorrlist index end])]
		}
	}
}

#---- Display the start and end values of a highlighted block of data

proc ShowPcorrLims {} {
	global pcorrlist pcorr_blokstartval pcorr_blokendval pcorrblokstart pcorrblokend orig_pcorr_startval orig_pcorr_endval pcorr_asmidi
	global pcorr_time1 pcorr_time2 pcorr_indexlist orig_pcorr_state pcorr_outshow pcorr_limits_set
	set ilist [$pcorrlist curselection]
	set len [llength $ilist] 
	if {($len <= 0) || (($len == 1) && ($ilist < 0))} {
		Inf "No Data Highlighted"
		ForceVal $pcorrblokstart ""
		ForceVal $pcorrblokend ""
		return
	}
	set pcorr_indexlist $ilist
	set k 0
	set val -1.0
	while {$val < 0} {
		set i [lindex $ilist $k]
		set line [$pcorrlist get $i]
		set time [expr double([lindex $line 0])]
		set val	 [expr double([lindex $line 1])]
		if {$val > 0.0} {
			break
		}
		incr k
		if {$k >= $len} {
			Inf "No True Pitches Highlighted"
			ForceVal $pcorrblokstart ""
			ForceVal $pcorrblokend ""
			return
		}
	}
	set pcorr_time1 $time
	if {!$pcorr_asmidi} {
		set val [UnconstrainedHzToMidi $val]
	}
	set pcorr_blokstartval $val
	set orig_pcorr_startval $val
	set orig_pcorr_state $pcorr_outshow
	set j $k
	set k [expr $len - 1]
	set val -1.0
	while {$val < 0} {
		set i [lindex $ilist $k]
		set line [$pcorrlist get $i]
		set time [expr double([lindex $line 0])]
		set val [expr double([lindex $line 1])]
		if {$val > 0.0} {
			break
		}
		incr k -1
	}
	set pcorr_time2 $time
	if {!$pcorr_asmidi} {
		set val [UnconstrainedHzToMidi $val]
	}
	set pcorr_blokendval $val
	set orig_pcorr_endval $val
	ForceVal $pcorrblokstart $pcorr_blokstartval	
	ForceVal $pcorrblokend $pcorr_blokendval
	set pcorr_limits 1
	set pcorr_limits_set 1
}

#---- Reset pitch of highlighted block of data between given limits

proc ResetPcorrLims {} {
	global pcorrlist pcorr_blokstartval orig_pcorr_startval pcorr_blokendval orig_pcorr_endval
	global pcoorr_postlist pcorr_indexlist final_pcorr_startval final_pcorr_endval pcorr_frq
	global pcorr_oct pcorr_lo pcorr_hi pcorr_no_sibil zbankgrafix pm_numidilist pcorr_nujd
	global pcorr_asmidi pcorr_time1 pcorr_time2 pcorr_outlines pcorr_outshow orig_pcorr_state
	global pcorrblokstart pcorrblokend pcorr_limits pcorr_limits_set pcorr_pm_numidilist
	global pcorr_last_smooth

	if {!$pcorr_limits_set} {
		Inf "Use \"SHOW\" Button First"
	}
	set ilist [$pcorrlist curselection]
	set len [llength $ilist] 
	if {($len <= 0) || (($len == 1) && ($ilist < 0))} {
		Inf "No Data Highlighted"
		return
	}
	if {[info exists orig_pcorr_state]} {
		if {$pcorr_outshow == $orig_pcorr_state} {
			if {[Flteq $pcorr_blokstartval $orig_pcorr_startval] && [Flteq $pcorr_blokendval $orig_pcorr_endval]} {
				Inf "No Change In Pitch"
				return
			}
		}
	}
	foreach a $ilist b $pcorr_indexlist {
		if {$a != $b} {
			Inf "Current Highlighted Block Does Not Correspond To Originally Marked Block\n\nUse \"SHOW\" Button Again"
			return
		}
	}
	set initial_shift [expr double($pcorr_blokstartval) - $orig_pcorr_startval]
	set final_shift   [expr double($pcorr_blokendval) - $orig_pcorr_endval]
	if {[flteq $initial_shift 0.0] && [Flteq $final_shift 0.0]} {
		if {!$pcorr_outshow} {
			Inf "Data Already Available: See \"Output Values\" Display"
		} else  {
			Inf "Data Already Moved"
		}
		return
	}
	set shiftdiff	  [expr $final_shift - $initial_shift]
	set timediff	  [expr $pcorr_time2 - $pcorr_time1]
	foreach i $ilist {
		set line [$pcorrlist get $i]
		set time [lindex $line 0]		
		set val  [lindex $line 1]		
		if {$val > 0.0} {
			if {!$pcorr_asmidi} {
				set val [UnconstrainedHzToMidi $val]
			}
			set ratio [expr double ($time) / $timediff]
			set shift [expr $shiftdiff * $ratio]
			set shift [expr $shift + $initial_shift]
			set val [expr $val + $shift]
			if {!$pcorr_asmidi} {
				set val [MidiToHz $val]
			}
		}
		set nuline [list $time $val]
		lappend nulines $nuline
	}
	set pcoorr_postlist $nulines
	foreach i $ilist nuline $nulines {
		$pcorrlist delete $i
		$pcorrlist insert $i $nuline
	}
		;#	IF DISPLAYED DATA IS MIDI, NEED TO UPDATE BAKDUP FRQ-REPRESENTATION, IN CASE IT IS RESTORED
	if {$pcorr_asmidi && [info exists pcorr_frq]} {
		foreach i $ilist nuline $nulines {
			set time [lindex $nuline 0]
			set val  [lindex $nuline 1]
			set val [MidiToHz $val]
			set line [list $time $val]
			set pcorr_frq [lreplace $pcorr_frq $i $i $line]
		}
	}
	set final_pcorr_startval $pcorr_blokstartval
	set final_pcorr_endval $pcorr_blokendval

	set pcorr_oct 0		;#	RESET ALL SMOOTHING PARAMS TO ZERO
	set pcorr_lo 0
	set pcorr_hi 127
	set pcorr_no_sibil 0
	ClearPitchGrafix $zbankgrafix
	set pcorr_pm_numidilist $pm_numidilist
	catch {unset pm_numidilist}
	set pcorr_nujd 1
	set pcorr_outshow 1

	set pcorr_last_smooth [list $pcorr_outshow $pcorr_oct $pcorr_lo $pcorr_hi $pcorr_no_sibil $pcorr_nujd]
	lappend pcorr_last_smooth $final_pcorr_startval $final_pcorr_endval $orig_pcorr_startval $orig_pcorr_endval
	$pcorrlist selection clear 0 end
	foreach i $pcorr_indexlist {
		$pcorrlist selection set $i
	}
	catch {unset pcorr_outlines}
	foreach line [$pcorrlist get 0 end] {
		lappend pcorr_outlines $line
	}
	set pcorr_limits_set 0
}

#--- Is last nudged data made same as last nudged data played

proc PcorrSameAsLastNujStateMade {} {
	global pcorr_last_smooth pcorr_last_outstate_played evv

	if {![string match [lindex $pcorr_last_smooth $evv(PCR_STARTVAL)] [lindex $pcorr_last_outstate_played $evv(PCR_STARTVAL)]]} {
		return 0
	}
	if {![string match [lindex $pcorr_last_smooth $evv(PCR_ENDVAL)] [lindex $pcorr_last_outstate_played $evv(PCR_ENDVAL)]]} {
		return 0
	}
	if {![string match [lindex $pcorr_last_smooth $evv(PCR_ORIGSTARTVAL)] [lindex $pcorr_last_outstate_played $evv(PCR_ORIGSTARTVAL)]]} {
		return 0
	}
	if {![string match [lindex $pcorr_last_smooth $evv(PCR_ORIGENDVAL)] [lindex $pcorr_last_outstate_played $evv(PCR_ORIGENDVAL)]]} {
		return 0
	}
	return 1
}

#--- Is nudge data same as current nudge parameters displayed

proc PcorrSameAsNujStateDisplayed {pcorrmem} {
	global pcorr_last_outstate_played pcorr_last_smooth pcorrlist
	global pcorr_blokstartval pcorr_blokendval pcorr_outshow evv

	upvar $pcorrmem thislist
	if {([string length $pcorr_blokstartval] <= 0) || ([string length $pcorr_blokendval] <= 0)} {
		return 0
	}
	if {![string match [lindex $thislist $evv(PCR_STARTVAL)] $pcorr_blokstartval]} {
		return 0
	}
	if {![string match [lindex $thislist $evv(PCR_ENDVAL)] $pcorr_blokendval]} {
		return 0
	}
	return 1
}

#---- Modify the pitch limits for a nuj

proc IncrPcorr {which up} {
	global pcorr_blokstartval pcorr_blokendval  pcorr_njshift mu
	if {([string length $pcorr_blokstartval] <= 0) || ([string length $pcorr_blokendval] <= 0)} {
		return
	}
	set start $pcorr_blokstartval
	set end $pcorr_blokendval
	switch -- $pcorr_njshift {
		0 { set shift 0.25 }
		1 { set shift 1.0 }
		2 { set shift 12.0 }
	}
	if {!$up} {
		set shift [expr -$shift]
	}
	switch -- $which {
		0 {		;# ALL
			set pcorr_blokstartval [expr $pcorr_blokstartval + $shift]
			set pcorr_blokendval   [expr $pcorr_blokendval + $shift]
		}
		1 {		;# STARTVAL
			set pcorr_blokstartval [expr $pcorr_blokstartval + $shift]
		}	
		2 {		;# ENDVAL
			set pcorr_blokendval   [expr $pcorr_blokendval + $shift]
		}
	}
	if {($pcorr_blokendval > $mu(MIDIMAX)) || ($pcorr_blokendval > $mu(MIDIMAX))} {
		Inf "Out Of Range"
		set pcorr_blokstartval $start
		set pcorr_blokendval $end
	}
}

#---- Set all Nuj params to non-operational, and force entry boxes to be empty.

proc PcorrEraseNujParams {} {
	global pcorr_nujd final_pcorr_startval final_pcorr_endval orig_pcorr_startval orig_pcorr_endval pcorrblokstart pcorrblokend
	global pcorr_indexlist pcorrlist orig_pcorr_state

	set pcorr_nujd 0
	set final_pcorr_startval -1
	set final_pcorr_endval -1
	set orig_pcorr_startval -1
	set orig_pcorr_endval -1
	set pcorr_blokstartval ""
	set pcorr_blokendval ""
	ForceVal $pcorrblokstart $pcorr_blokstartval
	ForceVal $pcorrblokend $pcorr_blokendval
	catch {unset orig_pcorr_state}
}

#---- Select lines previously highlighted

proc PcorrHilitePrevious {} {
	global pcorr_prevch pcorr_indexlist pcorr_oldlist pcorrlist
	if {![info exists pcorr_indexlist] && ![info exists pcorr_oldlist]} {
		Inf "No Lines Previously Highlighted"	
		return
	}
	if {[info exists pcorr_oldlist]} {
		$pcorrlist selection clear 0 end
		foreach i $pcorr_oldlist {
			$pcorrlist selection set $i
		}
		unset pcorr_oldlist
	} else {
		set ilist [$pcorrlist curselection]
		set len [llength $ilist]
		if {($len > 0) && ([lindex $ilist 0] != -1)} {
			set pcorr_oldlist $ilist
		}
		$pcorrlist selection clear 0 end
		foreach i $pcorr_indexlist {
			$pcorrlist selection set $i
		}
	}
	set pcorr_prevch 1
}

#---- Set Nuj params from Staff display

proc PcorrNjSet {hiatend} {
	global pm_numidilist pcorrblokstart pcorrblokend pcorr_blokstartval pcorr_blokendval pcorr_indexlist
	if {![info exists pcorr_indexlist]} {
		Inf "Use \"SHOW\" First"
		return
	}
	if {![info exist pm_numidilist]} {
		Inf "No Pitches Specified On The Staff"
		return
	}
	set len [llength $pm_numidilist]
	if {$len  != 2} {
		if {$len == 1} {
			set val [lindex $pm_numidilist 0]
			lappend pm_numidilist $val
		} else {
			Inf "SPECIFY TWO PITCHES ON STAFF"
			return
		}
	}
	set loval [lindex $pm_numidilist 0]
	set hival [lindex $pm_numidilist 1]
	append loval ".0"
	append hival ".0"
	if {$hiatend} {
		set pcorr_blokstartval $loval
		set pcorr_blokendval   $hival
	} else {
		set pcorr_blokstartval $hival
		set pcorr_blokendval   $loval
	}
	ForceVal $pcorrblokstart $pcorr_blokstartval
	ForceVal $pcorrblokend $pcorr_blokendval
}

#---- Recall Staff display for a Smooth or a Nuj

proc PcorrStaffRecall {type} {
	global pcorr_pm_numidilist pcorr2_pm_numidilist pm_numidilist zbankgrafix
	if {$type == "staff"} {
		if {![info exists pcorr_pm_numidilist]} {
			Inf "No Previous Staff Display For Pitch Block Start And End"
			return
		}
		set pm_numidilist $pcorr_pm_numidilist
	} else {
		if {![info exists pcorr2_pm_numidilist]} {
			Inf "No Previous Staff Display For Smoothing Range"
			return
		}
		set pm_numidilist $pcorr2_pm_numidilist
	}
	ClearPitchGrafix $zbankgrafix
	InsertPitchGrafix $pm_numidilist $zbankgrafix
}

#---- Clear Staff display

proc PcorrClearStaff {} {
	global pm_numidilist zbankgrafix
	catch {unset pm_numidilist}
	ClearPitchGrafix $zbankgrafix
}

proc PcorrPtobrk {} {
	global pcorrfnam_psuedosrc pcorr_infnam CDPidrun prg_dun prg_abortd program_messages evv

	Block "CREATING TEXTDATA FILE"
	set CDP_cmd [file join $evv(CDPROGRAM_DIR) ptobrk]
	lappend CDP_cmd withzeros $pcorr_infnam $pcorrfnam_psuedosrc 20.0

	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	catch {unset program_messages}
	if [catch {open "|$CDP_cmd"} CDPidrun] {
		Inf "$CDPidrun :\nCan't Create Pitch Text-data File"
		UnBlock
		return 0
	} else {
	   	fileevent $CDPidrun readable "Display_Score_Batch_Running_Info"
	}
	vwait prg_dun
	if {$prg_abortd} {
		if [info exists program_messages] {
			Inf "$program_messages"
		}
		set prg_dun
	}
	if {!$prg_dun} {
		Inf "Failed To Create Pitch Text-Data File"
		UnBlock
		return 0
	}
	UnBlock
	set pcorr_infnam $pcorrfnam_psuedosrc
	return 1
}

proc PitchCorrHelp {} {
	set msg "PITCH DATA SMOOTHING\n"
	append msg "\n"
	append msg "On this page we can\n"
	append msg "1)   Smooth the entire set of pitch data.\n"
	append msg "2)   Smooth highlighted blocks of pitch data.\n"
	append msg "\n"
	append msg "SMOOTHING THE WHOLE DATA SET\n"
	append msg "\n"
	append msg "1)   We can move entire data to a new 8va by setting a value for \"initial 8va correction\"\n"
	append msg "2)   and/or set a limiting range (at least one 8va) by entering (2) notes on the staff display. \n"
	append msg "3)   Then press the \"Do Smooting\" button.\n"
	append msg "\n"
	append msg "SMOOTHING PART OF THE DATA SET\n"
	append msg "\n"
	append msg "1)   Select part of the set by highlighting with the mouse.\n"
	append msg "2)   Display the start value and end value of the highlighted  block (as MIDI) : Press\"Show\"\n"
	append msg "3)   Adjust the start and end values with Up/Down arrow keys\n"
	append msg "4)   OR enter new start and end limits by clicking on staff display (2 notes) then hitting\n"
	append msg "             \"RESET LIMITS FROM STAFF DISPLAY\"\n"
	append msg "5)   Adjust highlighted block to lie between those limits : Press \"Move\".\n"
	append msg "             The new values are interpolated between the limit values given.\n"
	append msg "\n"
	append msg "COMPARE THE NEW AND OLD VALUES\n"
	append msg "\n"
	append msg "1)   See them, by pressing the \"Show Input Values\" or \"Show Output values\" buttons.\n"
	append msg "2)   Hear whichever set we have displayed, by pressing \"Play Pitch\"\n"
	append msg "3)   Compare with the source (play alongside source) by pressing \"Play Both\" or \"Sound View\"\n"
	append msg "\n"
	append msg "WE CAN DO THE SMOOTHING IN STAGES\n"
	append msg "\n"
	append msg "Recycle the output of one smooting process as input to the next, using \"Outputs Vals as Input\"\n"
	append msg "\n"
	append msg "WE CAN ALSO HEAR THE SOURCE SOUND ON ITS OWN\n"
	append msg "\n"
	append msg "Use \"Play Source\"\n"
	Inf $msg
}

#----- Extract pitch data (as text) from a list of (MONO) sndfiles

proc BulkPitchExtract {} {
	global ch chlist pa evv pcorr_outlines pr_bulkp bulkp_lo bulkp_hi pcorr_lo pcorr_lom pcorr_hi pcorr_him bulkp_oct bulkp_ext
	global CDPidrun prg_dun prg_abortd pcorr_no_sibil mu bpbankgrafix pm_numidilist pbulk_staff pbulk_quant pbulk_sustainformat
	global simple_program_messages

	set pcorr_no_sibil 0

	if {![info exists chlist] || ([llength $chlist] <= 0)} {
		Inf "No Sounds Selected On Chosen List"
		return
	}
	foreach fnam $chlist {
		if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
			Inf "Not All The Selected Files Are Sounds"
			return
		}
		if {$pa($fnam,$evv(CHANS)) != 1} {
			Inf "Not All The Selected Files Are Mono"
			return
		}
	}
	set analfnam $evv(DFLT_OUTNAME)
# 2023,   RWD was ANALFILE_EXT
	append analfnam 0 $evv(ANALFILE_OUT_EXT)	
	set dumfnam $evv(DFLT_OUTNAME)			;#	This is the analysis outfile from pitch-extraction, to be destroyed
;# 2023
	append dumfnam 1 $evv(ANALFILE_OUT_EXT)	
	set tempfnam1 $evv(DFLT_OUTNAME)
	append tempfnam1 $evv(TEXT_EXT)	
	set prequantfnam $evv(DFLT_OUTNAME)
	append prequantfnam 0 $evv(TEXT_EXT)	
	set cnt 0

	set bulkp_lo $evv(VOCALLO_MIDI)		;#	SUGGESTED DEFAULT LIMITS FOR HUMAN VOICE IN INITIAL EXTRACTION PROCESS
	set bulkp_hi $evv(VOCALHI_MIDI)
	set do_smooth 0
	set pcorr_lom ""
	set pcorr_him ""
	set f .bulkp
	catch {unset pm_numidilist}
	if [Dlg_Create $f "BULK PITCH EXTRACT" "set pr_bulkp 0" -width 60 -borderwidth $evv(SBDR)] {
		frame $f.a
		frame $f.a0 -bg black -height 1
		frame $f.b
		button $f.a.do -text "Extract Pitch" -command {set pr_bulkp 1} -highlightbackground [option get . background {}]
		button $f.a.quit -text "Close" -command {set pr_bulkp 0} -highlightbackground [option get . background {}]
		pack $f.a.do -side left
		pack $f.a.quit -side right
		pack $f.a -side top -fill x -expand true
		pack $f.a0 -side top -fill x -expand true -pady 2
		frame $f.b.0
		frame $f.b.00 -bg black -width 1
		frame $f.b.1
		frame $f.b.0.0
		frame $f.b.0.1
		frame $f.b.0.2
		frame $f.b.0.3
		frame $f.b.0.4
		label $f.b.0.00 -text "PITCH EXTRACTION"
		pack $f.b.0.00 -side top -pady 4
		label $f.b.0.1.plol -text "Min Pitch (MIDI) "
		entry $f.b.0.1.plo -textvariable bulkp_lo -width 6
		label $f.b.0.1.phil -text "Max Pitch "
		entry $f.b.0.1.phi -textvariable bulkp_hi -width 6
		pack $f.b.0.1.plol $f.b.0.1.plo $f.b.0.1.phil $f.b.0.1.phi -side left
		pack $f.b.0.1 -side top
		frame $f.b.0.1a -bg black -height 1
		pack $f.b.0.1a -side top -fill x -expand true -pady 4
		label $f.b.0.11 -text "PITCH SMOOTHING (OPTIONAL)"
		pack $f.b.0.11 -side top -pady 4
		label $f.b.0.2.ll -text "initial transposition (8vas)"
		entry $f.b.0.2.e -textvariable bulkp_oct -width 2
		pack $f.b.0.2.ll $f.b.0.2.e  -side left
		pack $f.b.0.2 -side top
		label $f.b.0.3.plol -text "Range Min (MIDI) "
		entry $f.b.0.3.plo -textvariable pcorr_lom -width 6
		label $f.b.0.3.phil -text "Range Max "
		entry $f.b.0.3.phi -textvariable pcorr_him -width 6
		pack $f.b.0.3.plol $f.b.0.3.plo $f.b.0.3.phil $f.b.0.3.phi -side left
		pack $f.b.0.3 -side top
		frame $f.b.0.3a -bg black -height 1
		pack $f.b.0.3a -side top -fill x -expand true -pady 4

		label $f.b.0.xx -text "PITCH QUANTISATION (OPTIONAL)"
		pack $f.b.0.xx -side top -pady 4
		checkbutton $f.b.0.yy1 -text Quantise -variable pbulk_quant
		pack $f.b.0.yy1 -side top
		frame $f.b.0.yy2 
		label $f.b.0.yy2.0 -text "Output Format"
		radiobutton $f.b.0.yy2.1 -text "Frq Brkpnt" -variable pbulk_sustainformat -value 0
		radiobutton $f.b.0.yy2.2 -text "Midi Brkpnt" -variable pbulk_sustainformat -value 1
		radiobutton $f.b.0.yy2.3 -text "Midi Sustain" -variable pbulk_sustainformat -value 2
		pack $f.b.0.yy2.0 $f.b.0.yy2.1 $f.b.0.yy2.2 $f.b.0.yy2.3 -side left
		label $f.b.0.yy3 -text "FRQ BRKPNT format produces frq curve for synth (or filter)"
		label $f.b.0.yy4 -text "MIDI BRKPNT format produces midi curve for filters"
		label $f.b.0.yy5 -text "SUSTAIN format produces time-midi pairs for sequencer"
		pack $f.b.0.yy2 $f.b.0.yy3 $f.b.0.yy4 $f.b.0.yy5 -side top
		frame $f.b.0.zz -bg black -height 1
		pack $f.b.0.zz -side top -fill x -expand true -pady 4

		label $f.b.1.range -text "EXPECTED RANGE"
		label $f.b.1.mouse1 -text "Add Note: Click      Add Flat: Shift-Click"
		label $f.b.1.mouse2 -text "Delete Note: Control-Click"
		set bpbankgrafix [EstablishPmarkDisplay $f.b.1]
		frame $f.b.1.zet0
		label $f.b.1.zet0.1 -text "CLEAR STAFF"
		radiobutton $f.b.1.zet0.2 -variable pbulk_staff -value 0 -command "PbulkSetRange 0"
		pack $f.b.1.zet0.1 $f.b.1.zet0.2 -side left
		frame $f.b.1.zet1
		label $f.b.1.zet1.1 -text "SET PITCH EXTRACTION RANGE FROM STAFF"
		radiobutton $f.b.1.zet1.2 -variable pbulk_staff -value 1 -command "PbulkSetRange extract"
		pack $f.b.1.zet1.1 $f.b.1.zet1.2 -side left
		frame $f.b.1.zet2
		label $f.b.1.zet2.1 -text "SET SMOOTHING RANGE FROM STAFF"
		radiobutton $f.b.1.zet2.2 -variable pbulk_staff -value 2 -command "PbulkSetRange smooth"
		pack $f.b.1.zet2.1 $f.b.1.zet2.2 -side left
		pack $f.b.1.range $f.b.1.mouse1 $f.b.1.mouse2 $bpbankgrafix -side top -pady 2 -fill both -expand true
		pack $f.b.1.zet0 $f.b.1.zet1 $f.b.1.zet2 -side top -pady 2
		pack $f.b.0 -side left -fill y -expand true
		pack $f.b.00 -side left -fill y -expand true  -padx 4
		pack $f.b.1 -side left
		pack $f.b -side top -fill x -expand true
		bind $bpbankgrafix <ButtonRelease-1>		{PgrafixAddPitch $bpbankgrafix %x %y 0}
		bind $bpbankgrafix <Shift-ButtonRelease-1>	{PgrafixAddPitch $bpbankgrafix %x %y 1}
		bind $bpbankgrafix <Control-ButtonRelease-1> {PgrafixDelPitch $bpbankgrafix %x %y}
		wm resizable $f 1 1
		bind $f <Return> {set pr_bulkp 1}
		bind $f <Escape> {set pr_bulkp 0}
	}
	set pbulk_quant 0
	set pbulk_sustainformat 0
	set pbulk_staff -1
	set bulkp_ext $evv(FEX_TAG)
	raise $f
	update idletasks
	StandardPosition $f
	set finished 0
	set pr_bulkp 0
	My_Grab 0 $f pr_bulkp
	while {!$finished} {
		tkwait variable pr_bulkp
		if {$pr_bulkp} {
			set OK 1
			foreach fnam $chlist {
				set outfnam [file rootname [file tail $fnam]]
				append outfnam $bulkp_ext $evv(TEXT_EXT)
				if {[file exists $outfnam]} {
					set msg "A File With The Name '$outfnam' Already Exists\n"
					append msg "Remove (Or Rename) All Textfiles With Names Corresponding To The Input Soundfile Names"
					Inf $msg
					set OK 0
					break
				}
			}
			if {!$OK} {
				continue
			}
			if {[string length $bulkp_lo] <= 0} {
				Inf "No Pitch Extraction Low Limit Entered"
				continue
			}
			if {![IsNumeric $bulkp_lo] || ($bulkp_lo < $mu(MIDIMIN)) || ($bulkp_lo > $mu(MIDIMAX))} {
				Inf "Invalid Or Out Of Range Pitch Extraction Low Limit Entered"
				continue
			}
			if {[string length $bulkp_hi] <= 0} {
				Inf "No Pitch Extraction High Limit Entered"
				continue
			}
			if {![IsNumeric $bulkp_hi] || ($bulkp_hi < $mu(MIDIMIN)) || ($bulkp_hi > $mu(MIDIMAX))} {
				Inf "Invalid Or Out Of Range Pitch Extraction High Limit Entered"
				continue
			}
			if {$bulkp_hi <= $bulkp_lo} {
				Inf "Incompatible Range Limits For Pitch Extraction"
				continue
			}
			set bulkp_lofrq [MidiToHz $bulkp_lo]
			set bulkp_hifrq [MidiToHz $bulkp_hi]
			set do_smooth 0
			if {[string length $bulkp_oct] > 0} {
				if {[string match [string index $bulkp_oct] "-"]} {
					set val [string range $bulkp_oct 1 end]
				} else {
					set val $bulkp_oct
				}
				if {![regexp {^[0-9]+$} $val]} {
					Inf "Invalid \"Initial Transposition\" Entered"
					continue
				}
				if {$val > 4} {
					Inf "\"Initial Transposition\" Out Of Range"
					continue
				}
				set bulkp_octave $bulkp_oct
			} else {
				set bulkp_octave 0
			}
			if {[string length $pcorr_lom] > 0} {
				if {[string length $pcorr_him] <= 0} {
					Inf "Only One Smoothing Range Limit Entered"
					continue
				}
				if {![IsNumeric $pcorr_lom] || ($pcorr_lom < $mu(MIDIMIN)) || ($pcorr_lom > $mu(MIDIMAX))} {
					Inf "Invalid Or Out Of Range Low Smoothing Limit Entered"
					continue
				}
				if {![IsNumeric $pcorr_him] || ($pcorr_him < $mu(MIDIMIN)) || ($pcorr_him > $mu(MIDIMAX))} {
					Inf "Invalid Or Out Of Range High Smoothing Limit Entered"
					continue
				}
				if {$pcorr_lom >= $pcorr_him} {
					Inf "Incompatible Range Limits For Smoothing"
					continue
				}
				set pcorr_lo [MidiToHz $pcoor_lom]
				set pcorr_hi [MidiToHz $pcoor_him]
				set do_smooth 1
			} else {
				if {[string length $pcorr_him] > 0} {
					Inf "Only One Smoothing Range Limit Entered"
					continue
				}
				if {$bulkp_octave != 0} {
					set pcorr_lo $mu(MIDIMIN)
					set pcorr_hi $mu(MIDIMAX)
					set do_smooth 1
				}
			}
			Block "Extracting pitch data"
			foreach fnam $chlist {
				DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
				set outfnam [file rootname [file tail $fnam]]
				append outfnam $bulkp_ext $evv(TEXT_EXT)
				set cmd [file join $evv(CDPROGRAM_DIR) pvoc]
				lappend cmd anal 1 $fnam $analfnam -c1024 -o3
				set prg_dun 0
				set prg_abortd 0
				catch {unset simple_program_messages}
				if [catch {open "|$cmd"} CDPidrun] {
					ErrShow "CANNOT ANALYSE FILE $fnam: $CDPidrun"
					catch {unset CDPidrun}
					continue
				} else {
					fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				if {!$prg_dun} {
					set msg "Cannot Analyse File $fnam: $CDPidrun"
					set msg [AddSimpleMessages $msg]
					ErrShow $msg
					continue
				}
				if {!$do_smooth && !$pbulk_quant} {
					set out_fnam $outfnam
				} else {
					set out_fnam $tempfnam1
				}
				set cmd [file join $evv(CDPROGRAM_DIR) repitch]
				lappend cmd getpitch 2 $analfnam $dumfnam $out_fnam -t1 -g2 -s80 -n5 -l$bulkp_lofrq -h$bulkp_hifrq -d.25
				set prg_dun 0
				set prg_abortd 0
				catch {unset simple_program_messages}
				if [catch {open "|$cmd"} CDPidrun] {
					ErrShow "Cannot Get Pitch From Analysis File $fnam: $CDPidrun"
					catch {unset CDPidrun}
					continue
				} else {
					fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				if {!$prg_dun} {
					set msg "Cannot Get Pitch From Analysis File $fnam: $CDPidrun"
					set msg [AddSimpleMessages $msg]
					ErrShow $msg
					catch {file delete $out_fnam}
					continue
				}
				if {$do_smooth} {
					if [catch {open $tempfnam1 "r"} zit] {
						Inf "Cannot Open File '$tempfnam1' To Do Smoothing"
					} else {	
						catch {unset nulines}
						while {[gets $zit line] >= 0} {
							if {[string length $line] <= 0} {
								continue
							}
							set line [string trim $line]
							set line [split $line]
							catch {unset nuline}
							foreach item $line {
								set item [string trim $item]
								if {[string length $item] > 0} {
									lappend nuline $item
								}
							}
							if {![info exists nuline] || ([llength $nuline] != 2)} {
								Inf "Problem With Initial Text Data In '$tempfnam1' : Cannot Do Smoothing"
								catch {unset nulines}
								break
							}
							lappend nulines $nuline
						}
						close $zit
					}
					catch {unset pcorr_outlines}
					if {[info exists nulines]} {
						PitchCorrection $bulkp_octave 0 $nulines
					}
					if {[info exists pcorr_outlines]} {
						if {$pbulk_quant} {
							set out_fnam $tempfnam2
						} else {
							set out_fnam $outfnam
						}
						if [catch {open $out_fnam "w"} zit] {
							Inf "Cannot Open File '$out_fnam' To Write Pitch Data"
							continue
						}
						foreach line $pcorr_outlines {
							puts $zit $line
						}
						close $zit
					} else {
						Inf "Non-Massaged Pitch_output For File '$fnam'"
						if [catch {file rename $tempfnam1 $outfnam} zit] {
							Inf "Cannot Rename File '$tempfnam1' TO '$outfnam'"
							continue
						}
					}
				}
				if {$pbulk_quant} {
					if {$do_smooth} {
						set infnam $tempfnam2
					} else {
						set infnam $tempfnam1
					}	
					if [catch {open $infnam "r"} zit] {
						Inf "Cannot Open File '$infnam' To Do Quantisation"
					} else {	
						catch {unset nulines}
						while {[gets $zit line] >= 0} {
							if {[string length $line] <= 0} {
								continue
							}
							set line [string trim $line]
							set line [split $line]
							catch {unset nuline}
							foreach item $line {
								set item [string trim $item]
								if {[string length $item] > 0} {
									lappend nuline $item
								}
							}
							if {![info exists nuline] || ([llength $nuline] != 2)} {
								Inf "Problem With Initial Text Data In '$infnam' : Cannot Do Quantisation"
								catch {unset nulines}
								break
							}
							lappend nulines $nuline
						}
						close $zit
					}
					if {![info exists nulines]} {
						continue
					}
					set nulines [QuantiseToRange $bulkp_lo $bulkp_hi $pbulk_sustainformat $nulines]
					if [catch {open $outfnam "w"} zit] {
						Inf "Cannot Open File '$outfnam' To Write Quantised Data"
						continue
					}
					foreach line $nulines {
						puts $zit $line
					}
					close $zit
				}
				FileToWkspace $outfnam 0 0 0 0 1
			}
			UnBlock
			Inf "Any Pitch Data Files Created Are Now On The Workspace, Tagged With \"$evv(FEX_TAG)\""
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

proc PbulkSetRange {what} {
	global bpbankgrafix pm_numidilist pbulk_staff bulkp_lo bulkp_hi pcorr_lom pcorr_him
	if {$what == "0"} {
		catch {unset pm_numidilist}
		ClearPitchGrafix $bpbankgrafix
		return
	}
	if {![info exists pm_numidilist] || ([llength $pm_numidilist] !=2)} {
		Inf "Select Two Pitches (Only) To Define Range"
		return
	}
	set lo [lindex $pm_numidilist 0]
	set hi [lindex $pm_numidilist 1]
	if {$lo > $hi} {
		set temp $lo
		set lo $hi
		set hi $temp
	}
	switch -- $what {
		"extract" {
			set bulkp_lo $lo
			set bulkp_hi $hi
		}
		"smooth" {
			set pcorr_lom $lo
			set pcorr_him $hi
		}
	}
	set pbulk_staff -1
}

#---- Takes pitchdata as frq and outputs quantised data in various formats

proc QuantiseToRange {ranglo ranghi sustainformat pchdata} {

	foreach valpair $pchdata {				;# CONVERT TO QUANTISED MIDI
		set time [lindex $valpair 0]
		set val  [lindex $valpair 1]
		lappend nulines $time [expr int(round([HzToMidi $val]))]
	}
	set ccnt 0
	foreach {time val} $nulines {				;#	REMOVE CONSECUTIVE DUPLICATED VALS
		if {$ccnt == 0} {
			lappend nuvals $time $val
		} else {
			if {[Flteq $val $lastval]} {
				set sustained 1
			} else {
				if {[info exists sustained]} {
					lappend nuvals $lasttime $lastval
					unset sustained
				}
				lappend nuvals $time $val
			}
		}
		set lasttime $time
		set lastval $val
		incr ccnt
	}
	if {[info exists sustained]} {
		lappend nuvals $lasttime $lastval
	}			
	set nulines $nuvals
	catch {unset nuvals}
	set ccnt 0
	foreach {time val} $nulines {		;#	SMOOTH OUTPUT VALUES (REMOVE BRIEF PITCH DIGRESSIONS)
		if {$ccnt > 1} {
			set step   [expr $val - $lastval]
			set lastep [expr $lastval - $lalastval]
			if {(($step > 0) && ($lastep < 0)) \
			||  (($step < 0) && ($lastep > 0))} {
				if {[expr $time - $lasttime] < 0.05} {
					if {$step < 0} {
						set step [expr -$step]
					}
					if {$lastep < 0} {
						set lastep [expr -$lastep]
					}
					if {$step > $lastep} {
						set lastval $lalastval
					} else {
						set lastval $val
					}
				}
			}
		}
		if {$ccnt > 0} {
			set lalastval $lastval
			lappend nuvals $lasttime $lastval
		}
		set lastval $val
		set lasttime $time
		incr ccnt
	}
	lappend nuvals $lasttime $lastval

	set ccnt 0						;#	REMOVE CONSECUTIVE DUPLICATES (AGAIN)
	foreach {time val} $nuvals {
		if {$ccnt > 0} {
			if {[Flteq $val $lastval]} {
				set waiting 1
			} else {
				if {[info exists waiting]} {
					lappend out_vals $lasttime $lastval
					unset waiting
				}
				lappend out_vals $time $val
			}
		} else {
			lappend out_vals $time $val
		}
		set lastval $val
		set lasttime $time
		incr ccnt
	}
	if {[info exists waiting]} {
		lappend out_vals $lasttime $lastval
	}
	set ccnt 0						;#	REMOVE BAD RANGE (POSSIBLY REDUNDANT HERE)
	catch {unset sustained}
	catch {unset nuvals}
	foreach {time val} $out_vals {
		if {($val < $ranglo ) || ($val > $ranghi)} {
			if {![info exists sustained]} {
				set sustained 1
				if {$ccnt == 0} {
					set startsustain 0.0
				} else {
					set startsustain $lasttime
					set valsustain $lastval
				}
			}
		} else {
			if [info exists sustained] {
				if {$startsustain == 0.0} {
					lappend nuvals 0.0 $val
				} else {
					set timegap [expr $time - $startsustain]
					if {$timegap > 0.1} {
						set midtime [expr $startsustain + ($timegap/2.0)]
						lappend nuvals [expr $midtime - 0.025] $valsustain
						lappend nuvals [expr $midtime + 0.025] $val
					}
				}
				catch [unset sustained]
			}
			lappend nuvals $time $val
		}
		set lasttime $time
		set lastval $val
		incr ccnt
	}

	if [info exists sustained] {
		if {![info exists nuvals]} {
			return $pchdata
		}
		lappend nuvals $lasttime $valsustain
	}
	set out_vals $nuvals
	unset nuvals
	set ccnt 0
	catch {unset sustain}
	foreach {time val} $out_vals {			;#	REMOVE CONSECUTIVE DUPLICATES
		if {$ccnt == 0} {
			lappend nuvals $time $val
		} else {
			if {[Flteq $val $lastval]} {
				set sustain 1
			} else {
				if {[info exists sustain]} {
					lappend nuvals $lasttime $lastval
					unset sustain
				}
				lappend nuvals $time $val
			}
		}
		set lasttime $time
		set lastval $val
		incr ccnt
	}
	if {[info exists sustain]} {
		lappend nuvals $lasttime $lastval
		unset sustain
	}
	set out_vals $nuvals
	

	switch -- $sustainformat {
		0 {											;#	FRQ BRKPNT
			catch {unset nuvals} 
			foreach {time val} $out_vals {
				lappend nuvals $time [MidiToHz $val]
			}
		}				
		2 {
			set ccnt 0								;#  CHANGE TO IMPLIED-SUSTAIN FORMAT (MIDI)
			catch {unset nuvals}
			foreach {time val} $out_vals {
				if {$ccnt == 0} {
					lappend nuvals $time $val
				} elseif {![Flteq $val $lastval]} {
					lappend nuvals $time $val
				}
				set lastval $val
				incr ccnt
			}
		}
	}
	catch {unset nulines}
	foreach {time val} $nuvals {
		set nuline [list $time $val]
		lappend nulines $nuline
	}
	return $nulines
}

proc MidiTrim {} {
	global pr_miditrim wl chlist mu pa evv trim_max trim_min trim_fnam propfiles_list wstk rememd intrim_frq outtrim_frq
	set i [$wl curselection]
	if {([llength $i] != 1) || ($i == -1)} {
		if {![info exists chlist] || ([llength $chlist] != 1)} {
			Inf "Select One Pitch Data Textfile"
			return
		} else {
			set fnam [lindex $chlist 0]
		}
	} else {
		set fnam [$wl get $i]
	}
	if {![IsABrkfile $pa($fnam,$evv(FTYP))]} {
		Inf "Select One Pitch Data Textfile"
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File '$fnam' To Get Pitch Data"
		return
	}
	catch {unset nulines}
	while {[gets $zit line] >= 0} {
	    set line [string trim $line]
#FEB 2022
		if {[string length $line] <= 0} {
			continue
		} elseif {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		catch {unset nuline}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend nuline $item
			}
		}
		if {![info exists nuline] || ([llength $nuline] != 2)} {
			Inf "Problem With Initial Text Data In '$fnam' : Cannot Do Trimming"
			close $zit
			return
		}
		lappend nulines $nuline
	}
	close $zit
	set pr_miditrim 0
	set f .miditrim
	if [Dlg_Create $f "TRIM MIDI DATA" "set pr_miditrim 0" -width 60 -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0]
		set f1 [frame $f.1]
		set f1a [frame $f.1a]
		set f2 [frame $f.2]
		set f3 [frame $f.3]
		button $f0.quit -text "Abandon" -command {set pr_miditrim 0} -highlightbackground [option get . background {}]
		button $f0.ok  -text "Do Trim" -command {set pr_miditrim 1} -highlightbackground [option get . background {}]
		pack $f0.quit -side right
		pack $f0.ok -side left
		pack $f.0 -side top -fill x -expand true
		label $f.1.in -text "Input Data "
		radiobutton $f.1.inm -text "MIDI" -variable intrim_frq -value 0
		radiobutton $f.1.inf -text "FREQ" -variable intrim_frq -value 1
		pack $f.1.in $f.1.inm $f.1.inf  -side left
		pack $f.1 -side top
		label $f.1a.out -text "Output Data "
		radiobutton $f.1a.outm -text "MIDI" -variable outtrim_frq -value 0
		radiobutton $f.1a.outf -text "FREQ" -variable outtrim_frq -value 1
		pack $f.1a.out $f.1a.outm $f.1a.outf -side left
		pack $f.1a -side top
		label $f2.ill -text "Min Midi"
		entry $f2.min -textvariable trim_min -width 4
		label $f2.all -text "Max Midi"
		entry $f2.max -textvariable trim_max  -width 4
		pack $f2.ill $f2.min $f2.all $f2.max -side left
		label $f3.ll -text "Output Filename "
		entry $f3.e -textvariable trim_fnam -width 16
		pack $f3.ll $f3.e -side left
		pack $f.1 $f.2 $f.3 -side top
		wm resizable $f 1 1
		bind $f <Return> {set pr_miditrim 1}
		bind $f <Escape> {set pr_miditrim 0}
	}
	set trim_min ""
	set trim_max ""
	raise $f
	update idletasks
	StandardPosition $f
	set finished 0
	set pr_miditrim 0
	My_Grab 0 $f pr_miditrim
	while {!$finished} {
		tkwait variable pr_miditrim
		if {$pr_miditrim} {
			if {$intrim_frq} {
				if {($pa($fnam,$evv(MAXBRK)) > [MidiToHz $mu(MIDIMAX)]) \
				||  ($pa($fnam,$evv(MINBRK)) < [MidiToHz $mu(MIDIMIN)]) } {
					Inf "Invalid Input Data"
					continue
				}
			} else {
				if {($pa($fnam,$evv(MAXBRK)) > $mu(MIDIMAX)) || ($pa($fnam,$evv(MINBRK)) < $mu(MIDIMIN))} {
					Inf "Invalid Input Data"
					continue
				}
			}
			if {[string length $trim_fnam] <= 0} {
				Inf "No Output Filename Entered"
				continue
			}
			if {![ValidCDPRootname $trim_fnam]} {
				continue
			}
			set outfnam [string tolower $trim_fnam]
			append outfnam [GetTextfileExtension brk]
			if {[file exists $outfnam]} {
				set ftyp [FindFileType $outfnam]
				if {[IsAMixfile $ftyp]} {
					Inf "You Cannot Delete This Mixfile"
					continue
				} elseif {[info exists propfiles_list] && ([lsearch $propfiles_list $outfnam] >= 0)} {
					Inf "You Cannot Delete This Properties File"
					continue
				} else {
					set msg "File '$outfnam' Already Exists: Overwrite It ?"
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
					set i [LstIndx $outfnam $wl]
					if {![DeleteFileFromSystem $outfnam 0 1]} {
						Inf "Cannot Delete Existing File '$outfnam'"
						continue
					} else {
						DummyHistory $outfnam "DESTROYED"
						if {$i >= 0} {
							WkspCnt [$wl get $i] -1
							$wl delete $i
							catch {unset rememd}
						}
					}
				}
			}
			if {[string length $trim_max] <= 0} {
				set maxtrim 127
			} elseif {![IsNumeric $trim_max] || ($trim_max < $mu(MIDIMIN)) || ($trim_max > $mu(MIDIMAX))} {
				Inf "Invalid Max Trim Value (0-127)"
				continue
			} else {
				set maxtrim $trim_max
			}
			if {[string length $trim_min] <= 0} {
				set mintrim 0
			} elseif {![IsNumeric $trim_min] || ($trim_min < $mu(MIDIMIN)) || ($trim_min > $mu(MIDIMAX))} {
				Inf "Invalid Min Trim Value (0-127)"
				continue
			} else {
				set mintrim $trim_min
			}
			if {$mintrim > $maxtrim} {
				set temp $maxtrim
				set maxtrim $mintrim
				set mintrim $temp
			}
			set lastvalid -1
			set restart -1
			set badstart 0
			set n 0
			foreach line $nulines {
				set time [lindex $line 0]
				set val  [lindex $line 1]
				if {($val < $mintrim) || ($val > $maxtrim)} {
					if {$lastvalid >= 0} {
						set val $lastvalid
					} else {
						set badstart 1
					}
				} else {
					if {$badstart} {
						set restart $n	
						set badstart 0
					}
					set lastvalid $val
				}
				set line [list $time $val]
				lappend outvals $line
				incr n
			}
			if {$badstart} {
				Inf "Cannot Trim Data Within These Limits"
				continue
			} elseif {$restart >= 0} {
				set newvals $outvals
				set startval [lindex [lindex $outvals $restart] 1]
				set startline [list 0.0 $startval]
				set outvals [list $startline]
				foreach line [lrange $newvals $restart end] {
					lappend outvals $line
				} 
			}
			if {$outtrim_frq} {
				set lines $outvals
				unset outvals
				foreach line $lines {
					set time [lindex $line 0]
					set val  [lindex $line 1]
					set val  [MidiToHz $val]
					set line [list $time $val]
					lappend outvals $line
				}
			}
			if [catch {open $outfnam "w"} zit] {
				Inf "Cannot Open File '$outfnam' To Write Data"
				continue
			}
			foreach line $outvals {
				puts $zit $line
			}
			close $zit
			FileToWkspace $outfnam 0 0 0 0 1
			Inf "File '$outfnam' Is On The Workspace"
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

#---- Convert between Frq breakpnt, CDP sequencing file, and CDP varibank file formats (for tempered pitch data) 
#
#			fromseq		frq		flt
# SEQ->FRQ		1		1		0
# SEQ->FILT		1		0		1
# FRQ->SEQ		0		1		0
# FRQ->FILT		0		1		1
#

proc MidiBrkSeq {seqtobrk frq filt} {
	global wl chlist pr_seqtobrk seqtobrkfnam rememd wstk mu pa evv
	set i [$wl curselection]
	if {([llength $i] != 1) || ($i == -1)} {
		if {![info exists chlist] || ([llength $chlist] != 1)} {
			Inf "Select One Midi Data File"
			return
		}
		set fnam [lindex $chlist 0]
	} else {
		set fnam [$wl get $i]
	}
	if {!$seqtobrk && $frq} {
		set is_a_sequence 0
		if {![IsABrkfile $pa($fnam,$evv(FTYP))] || ($pa($fnam,$evv(MAXBRK)) > [MidiToHz $mu(MIDIMAX)]) || ($pa($fnam,$evv(MINBRK)) < [MidiToHz $mu(MIDIMIN)])} {
			Inf "Select A Frequency Brkpnt File"
			return
		}
	} else {
		set is_a_sequence 1
		if {![IsABrkfile $pa($fnam,$evv(FTYP))] && ![IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
			Inf "Select A Midi Sequence File"
			return
		}
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File '$fnam' To Get Data"
		break
	}
	set cnt 1
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
#FEB 2022
		if {[string length $line] <= 0} {
			continue
		} elseif {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		catch {unset nuline}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend nuline $item
			}
		}
		if {$is_a_sequence} {
			if {![info exists nuline] || ([llength $nuline] != 3)} {
				Inf "Lines Do Not Have 3 Data Items In '$fnam'"
				return
			}
			foreach {time val level} $nuline {
				if {$cnt == 1} {
					if {![Flteq $time 0.0]} {
						Inf "Problem With Data In '$fnam' : First Entry Is Not At Time Zero"
						return
					}
				} elseif {$time <= $lasttime} {
					Inf "Problem With Data In '$fnam' : Times Do Not Increase On Line $cnt"
					return
				}
				if {($val > 48) || ($val < -48)} {
					Inf "Problem With Data In '$fnam' : Transposition Out Of Range On Line $cnt"
					return
				}
				if {($level > 1.0) || ($level < 0.0)} {
					Inf "Problem With Data In '$fnam' : Level Out Of Range On Line $cnt"
					return
				}
				set lasttime $time
				incr cnt
			}
		} elseif {![info exists nuline] || ([llength $nuline] != 2)} {
			Inf "Problem With Initial Text Data In '$fnam' : Cannot Do Conversion"
			catch {unset nulines}
			return
		}
		lappend nulines $nuline
	}
	if {![info exists nulines]} {
		Inf "No Data In File '$fnam'"
		return
	}
	set f .seqtobrk
	if [Dlg_Create $f "CONVERT MIDI DATA" "set pr_seqtobrk 0" -width 60 -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0]
		set f1 [frame $f.1]
		button $f0.quit -text "Abandon" -command {set pr_seqtobrk 0} -highlightbackground [option get . background {}]
		button $f0.ok  -text "Convert" -command {set pr_seqtobrk 1} -highlightbackground [option get . background {}]
		pack $f0.quit -side right
		pack $f0.ok -side left
		pack $f.0 -side top -fill x -expand true
		label $f1.ll -text "Output Filename "
		entry $f1.e -textvariable seqtobrkfnam -width 16
		pack $f1.ll $f1.e -side left
		pack $f.1 -side top -pady 6
		if {$seqtobrk} {
			label $f.2 -text "Last event will get duration of penultimate event" -fg $evv(SPECIAL)
			pack $f.2 -side top -pady 2
		}
		wm resizable $f 1 1
		bind $f <Return> {set pr_seqtobrk 1}
		bind $f <Escape> {set pr_seqtobrk 0}
	}
	if {!$seqtobrk && $frq} {
		wm title $f "CONVERT FREQUENCY DATA"
	} else {
		wm title $f "CONVERT MIDI DATA"
	}
	set seqtobrkfnam ""
	raise $f
	update idletasks
	StandardPosition $f
	set finished 0
	set pr_seqtobrk 0
	My_Grab 0 $f pr_seqtobrk $f.1.e
	while {!$finished} {
		tkwait variable pr_seqtobrk
		if {$pr_seqtobrk} {
			if {[string length $seqtobrkfnam] <= 0} {
				Inf "No Output Filename Entered"
				continue
			}
			if {![ValidCDPRootname $seqtobrkfnam]} {
				continue
			}
			set outfnam [string tolower $seqtobrkfnam]
			append outfnam [GetTextfileExtension brk]
			if {[file exists $outfnam]} {
				if {[string match $fnam $outfnam]} {
				Inf "You Cannot Overwrite The Input Data File"
					continue
				}
				set msg "File '$outfnam' Already Exists: Overwrite It ?"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				set i [LstIndx $outfnam $wl]
				if {![DeleteFileFromSystem $outfnam 0 1]} {
					Inf "Cannot Delete Existing File '$outfnam'"
					continue
				} else {
					DummyHistory $outfnam "DESTROYED"
					if {$i >= 0} {
						WkspCnt [$wl get $i] -1
						$wl delete $i
						catch {unset rememd}
					}
				}
			}
			if {![info exists outvals]} {
				set backstep 0.05
				set dlbstep 0.1
				if {$seqtobrk} {		;#	INSERT SMALL GLIDES BETWEEN PITCH ONSETS  0 A 1 B -->  0 A 0.95 A 1 B
					set firstline [lindex $nulines 0]
					set lasttime [lindex $firstline 0]
					set lastval  [lindex $firstline 1]
					set lastval [expr $lastval + 60]
					lappend outvals	[list $lasttime $lastval]
					foreach line [lrange $nulines 1 end] {
						set time [lindex $line 0]
						set val  [lindex $line 1]
						set val [expr $val + 60]
						set advance [expr $time - $lasttime]
						if {$advance < $dlbstep} {
							set anacru [expr $advance / 2.0]
						} else {
							set anacru $backstep
						}
						set anacruline [list [expr $time - $anacru] $lastval]
						lappend outvals $anacruline
						lappend outvals [list $time $val]
						set timestep [expr $time - $lasttime]
						set lasttime $time
						set lastval $val
					}
					set line [list [expr $time + $timestep] $val]	;#	LAST EVENT GIVEN (ARBITRARILY) THE DURATION OF PENULT EVENT
					lappend outvals $line
					if {$frq} {
						set zoutvals $outvals
						unset outvals
						foreach line $zoutvals {
							set time [lindex $line 0]
							set val [MidiToHz [lindex $line 1]]
							set line [list $time $val]
							lappend outvals $line
						}
					}
					if {$filt} {
						set zoutvals $outvals
						unset outvals
						foreach line $zoutvals {
							lappend line 1
							lappend outvals $line
						}
					}
				} else {					;#	AABBCC --> ABC
					set firstline [lindex $nulines 0]
					set time [lindex $firstline 0]
					set val  [lindex $firstline 1]
					if {$frq} {
						set val [expr int(round([HzToMidi $val]))]
					}
					set lastval $val
					if {$filt} { ;#	FRQ --> FILT (level 1)
						set outval $val
					} else {	;#	FRQ --> SEQ (level 1)
						set outval [expr $val - 60]
					}
					lappend outvals	[list $time $outval 1]
					foreach line [lrange $nulines 1 end] {
						set time [lindex $line 0]
						set val  [lindex $line 1]
						if {$frq} {
							set val [expr int(round([HzToMidi $val]))]
						}
						if {$filt} { ;#	FRQ --> FILT (level 1)
							set outval $val
						} else {	;#	FRQ --> SEQ (level 1)
							set outval [expr $val - 60]
						}
						set line [list $time $outval 1]
						if {$filt} {						;#	FRQ/MIDI --> FILT : ALL LINES KEPT
							lappend outvals $line
						} elseif {$val != $lastval} {		;#	FRQ/MIDI --> SEQ , KEEP ONLY NOTE ONSETS
							lappend outvals $line
						}
						set lastval $val
					}
				}
			}
			if [catch {open $outfnam "w"} zit] {
				Inf "Cannot Open File '$outfnam' To Write Data"
				continue
			}
			foreach line $outvals {
				puts $zit $line
			}
			close $zit
			FileToWkspace $outfnam 0 0 0 0 1
			Inf "File '$outfnam' Is Now On The Workspace"
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

#------ Assign Tempered pitches to specific times in sndfile.

proc MelodyAssign {fromprop} {
	global pa wl chlist massign_fnam evv pm_numidilist massign_srate massign_invsrate massign_dur massign_chans pr_massign
	global massign_isseq asgrafix massignoutfnam symasamps massign_sequence wstk rememd massign_pdatafile massignsnd massignboth
	global nuaddpsnd nuaddpval nuaddp_vals adp_propnames adp_sndfiles adp_props_list prg_dun prg_abortd CDPidrun tp_props_list
	global simple_program_messages melwidth melstaveleft

	if {$fromprop} {
		set massign_fnam $nuaddpsnd
		if {![info exists pa($massign_fnam,$evv(SRATE))]} {
			Inf "File '$massign_fnam' Is Not On The Workspace: Cannot Proceed"
			return
		}
		catch {unset pm_numidilist}
	} else {
		set i [$wl curselection]
		if {([llength $i] != 1) || ($i == -1)} {
			if {![info exists chlist] || ([llength $chlist] != 1)} {
				Inf "Select One Soundfile"
				return
			}
			set massign_fnam [lindex $chlist 0]
		} else {
			set massign_fnam [$wl get $i]
		}
		if {$pa($massign_fnam,$evv(FTYP)) != $evv(SNDFILE)} {
			Inf "Select A Soundfile"
			return
		}
		catch {unset pm_numidilist}
	}
	set massign_srate $pa($massign_fnam,$evv(SRATE))
	set massign_invsrate [expr 1.0 / double($massign_srate)]
	set massign_dur $pa($massign_fnam,$evv(DUR))
	set massign_chans $pa($massign_fnam,$evv(CHANS))
	set massign_pdatafile $evv(DFLT_OUTNAME)
	append massign_pdatafile $evv(TEXT_EXT)	
	set massignsnd $evv(DFLT_OUTNAME)
	append  massignsnd 0 $evv(SNDFILE_EXT)
	set massignboth $evv(DFLT_OUTNAME)
	append  massignboth 1 $evv(SNDFILE_EXT)
	set massignenv $evv(DFLT_OUTNAME)
	append  massignenv 0 $evv(TEXT_EXT)
	set f .massign
	if [Dlg_Create $f "ASSOCIATE PITCHLINE" "set pr_massign 0" -width 60 -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0]
		set f1 [frame $f.1]
		set f2 [frame $f.2]
		set f3 [frame $f.3]
		set f4 [frame $f.4]
		set f5 [frame $f.5]
		set f6 [frame $f.6]
		set f6g [frame $f.6g]
		set f7 [frame $f.7]
		button $f0.quit -text "Quit" -command {set pr_massign 0} -width 10 -highlightbackground [option get . background {}]
		button $f0.ok  -text "Save Data" -command {set pr_massign 1} -width 10 -highlightbackground [option get . background {}]
		button $f0.dum -text "" -command {} -width 23 -bd 0 -highlightbackground [option get . background {}]
		button $f0.src -text "Play Src" -command "PlaySndfile $massign_fnam 0" -bg $evv(HELP) -width 10 -highlightbackground [option get . background {}]
		button $f0.sndv -text "Sound View" -command "SnackDisplay $evv(SN_TIMESLIST) syncmarks 0 $massign_fnam" -bg $evv(SNCOLOR) -width 10 -highlightbackground [option get . background {}]
		button $f0.pch -text "Play Pitch" -command "PlayAssign 0" -bg $evv(HELP) -width 10 -highlightbackground [option get . background {}]
		if {$massign_chans == 1} {
			button $f0.both -text "Play Both" -command "PlayAssign 1" -bg $evv(HELP) -width 10 -highlightbackground [option get . background {}]
		}
		pack $f0.ok $f0.sndv $f0.dum $f0.src $f0.pch -side left -padx 2
		if {$massign_chans == 1} {
			pack $f0.both -side left -padx 2
		}
		pack $f.0 -side top -fill x -expand true
		pack $f0.quit -side right

		button $f.1.c  -text "C"  -bd 4 -command "PlaySndfile $evv(TESTFILE_C)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.1.db -text "C#" -bd 4 -command "PlaySndfile $evv(TESTFILE_Db) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.1.d  -text "D"  -bd 4 -command "PlaySndfile $evv(TESTFILE_D)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.1.eb -text "Eb" -bd 4 -command "PlaySndfile $evv(TESTFILE_Eb) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.1.e  -text "E"  -bd 4 -command "PlaySndfile $evv(TESTFILE_E)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.1.f  -text "F"  -bd 4 -command "PlaySndfile $evv(TESTFILE_F)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.1.gb -text "F#" -bd 4 -command "PlaySndfile $evv(TESTFILE_Gb) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.1.g  -text "G"  -bd 4 -command "PlaySndfile $evv(TESTFILE_G)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.1.ab -text "Ab" -bd 4 -command "PlaySndfile $evv(TESTFILE_Ab) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.1.a  -text "A"  -bd 4 -command "PlaySndfile $evv(TESTFILE_A)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.1.bb -text "Bb" -bd 4 -command "PlaySndfile $evv(TESTFILE_Bb) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.1.b  -text "B"  -bd 4 -command "PlaySndfile $evv(TESTFILE_B)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.1.c2 -text "C"  -bd 4 -command "PlaySndfile $evv(TESTFILE_C2) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
		pack $f.1.c $f.1.db $f.1.d $f.1.eb $f.1.e $f.1.f $f.1.gb $f.1.g $f.1.ab $f.1.a $f.1.bb $f.1.b $f.1.c2 -side left
		pack $f.1 -side top -pady 2
		label $f.2.ll -text "Assign Note Times from \"Sound View\" : Click on Staff to create Notes : Control-Click to Delete" -fg $evv(SPECIAL)
		pack $f.2.ll -side top
		pack $f.2 -side top
		button $f.3.clear -text "Clear Display" -command "AsgrafixClear 1" -highlightbackground [option get . background {}]
		pack $f.3.clear -side top -pady 4
		set asgrafix [EstablishMelodyEntryDisplay $f.3]
		pack $asgrafix -side top -pady 1
		pack $f.3 -side top -fill both -expand true
		if {!$fromprop} {
			label $f.4.ll -text "Output Format "
			button $f.4.h -text "Format Info" -bg $evv(HELP) -command MidiBrkSeqHelp2 -highlightbackground [option get . background {}]
			pack $f.4.ll $f.4.h -side left
			pack $f.4 -side top
			label $f.5.llm -text "AS MIDI : "
			radiobutton $f.5.midi -text "Sequence" -variable massign_isseq -value $evv(ASSIGN_SEQ)
			radiobutton $f.5.zero -text "offset Sequence" -variable massign_isseq -value $evv(ASSIGN_SEQ_OFFSET)
			radiobutton $f.5.flt  -text "varibank filter data" -variable massign_isseq -value $evv(ASSIGN_FILTDATA)
			pack $f.5.llm $f.5.midi $f.5.zero $f.5.flt -side left
			pack $f.5 -side top
			label $f.6.llf -text "AS FRQ : "
			radiobutton $f.6.frq  -text "Breakpnt" -variable massign_isseq -value $evv(ASSIGN_FRQBRK)
			radiobutton $f.6.frqo -text "offset Breakpnt" -variable massign_isseq -value $evv(ASSIGN_FBRK_OFFSET)
			radiobutton $f.6.flt  -text "varibank filter data" -variable massign_isseq -value $evv(ASSIGN_FRQFILTDATA)
			pack $f.6.llf $f.6.frq $f.6.frqo $f.6.flt -side left
			pack $f.6 -side top
			label $f.6g.llf -text "AS GLISS : "
			radiobutton $f.6g.frq  -text "Frq Brk" -variable massign_isseq -value $evv(ASSIGN_FRQBRK_GLISS)
			radiobutton $f.6g.frqo -text "offset Frq Brk" -variable massign_isseq -value $evv(ASSIGN_FBRK_OFFSET_GLISS)
			radiobutton $f.6g.frqff -text "varibank (frq)" -variable massign_isseq -value $evv(ASSIGN_FRQFILTDATA_GLISS)
			radiobutton $f.6g.frqfm -text "varibank (midi)" -variable massign_isseq -value $evv(ASSIGN_FILTDATA_GLISS)
			pack $f.6g.llf $f.6g.frq $f.6g.frqo $f.6g.frqff $f.6g.frqfm -side left
			pack $f.6g -side top
			label $f7.ll -text "Output Filename "
			entry $f7.e -textvariable massignoutfnam -width 16
			pack $f7.ll $f7.e -side left
			pack $f.7 -side top -pady 6
		}
		wm resizable $f 1 1
		label $f.8 -text "CARE!!! CLOSE \"Sound View\" window BEFORE hitting \"Save Data\"" -fg $evv(SPECIAL)
		pack $f.8 -side top -pady 4	 
		set massign_isseq 0
		bind $asgrafix <ButtonRelease-1> {AsgrafixAddPitch $asgrafix %x %y 0}
		bind $asgrafix <Shift-ButtonRelease-1> {AsgrafixAddPitch $asgrafix %x %y 1}
		bind $asgrafix <Control-ButtonRelease-1> {AsgrafixDelPitch $asgrafix %x %y}
		bind $f <Return> {set pr_massign 1}
		bind $f <Escape> {set pr_massign 0}
	}
	wm title $f "ASSOCIATE PITCHLINE WITH FILE $massign_fnam"
	;# Timemarks are read INTO symasamps(0) from Sound View

	catch {unset symasamps(0)}
	set massignoutfnam ""
	raise $f
	update idletasks
	StandardPosition $f
	set finished 0
	set pr_massign 0
	My_Grab 0 $f pr_massign $f.1.e
	while {!$finished} {
		tkwait variable pr_massign
		if {$pr_massign} {
			if {![info exists symasamps(0)]} {
				Inf "No Timemarks Specified"
				continue
			} elseif {[llength $symasamps(0)] < 2} {
				Inf "Motif Must Have At Least Two Notes"
				continue
			}
			if {![info exists pm_numidilist]} {
				Inf "No Pitch-Sequence Specified"
				continue
			}
			if {[llength $pm_numidilist] != [llength $symasamps(0)]} {
				Inf "Not Every Time Mark Has Been Assigned A Pitch"
				continue
			}
			catch {unset massign_sequence}
			catch {unset symatimes(0)}
			foreach samptime $symasamps(0) midival $pm_numidilist {
				set time [expr double($samptime) * $massign_invsrate]
				lappend symatimes(0) $time
				lappend massign_sequence $time $midival
			}
			set massign_sequence [lreplace $massign_sequence 0 0 0.0]	;#	EXTEND TO TIME ZERO
			if {$fromprop} {
				set outfnamseq [file rootname $massign_fnam]
				append outfnamseq $evv(SEQ_TAG) $evv(TEXT_EXT)
				if {[file exists $outfnamseq]} {
					set msg "File '$outfnamseq' Already Exists: Overwrite It ?"
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
					set i [LstIndx $outfnamseq $wl]
					if {![DeleteFileFromSystem $outfnamseq 0 1]} {
						Inf "Cannot Delete Existing File '$outfnamseq'"
						continue
					} else {
						DummyHistory $outfnamseq "DESTROYED"
						if {$i >= 0} {
							WkspCnt [$wl get $i] -1
							$wl delete $i
							catch {unset rememd}
						}
					}
				}
				set outfnamflt [file rootname $massign_fnam]
				append outfnamflt $evv(FILT_TAG) $evv(TEXT_EXT)
				if {[file exists $outfnamflt]} {
					set msg "File '$outfnamflt' Already Exists: Overwrite It ?"
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
					set i [LstIndx $outfnamflt $wl]
					if {![DeleteFileFromSystem $outfnamflt 0 1]} {
						Inf "Cannot Delete Existing File '$outfnamflt'"
						continue
					} else {
						DummyHistory $outfnamflt "DESTROYED"
						if {$i >= 0} {
							WkspCnt [$wl get $i] -1
							$wl delete $i
							catch {unset rememd}
						}
					}
				}
				set outfnamfrq [file rootname $massign_fnam]
				append outfnamfrq $evv(PCH_TAG) [GetTextfileExtension brk]
				if {[file exists $outfnamfrq]} {
					set msg "File '$outfnamfrq' Already Exists: Overwrite It ?"
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
					set i [LstIndx $outfnamfrq $wl]
					if {![DeleteFileFromSystem $outfnamfrq 0 1]} {
						Inf "Cannot Delete Existing File '$outfnamfrq'"
						continue
					} else {
						DummyHistory $outfnamfrq "DESTROYED"
						if {$i >= 0} {
							WkspCnt [$wl get $i] -1
							$wl delete $i
							catch {unset rememd}
						}
					}
				}

				;#	OFFSET SEQUENCE (SO ZERO IN SEQ = FIRST TIMEMARK IN SRC)

				set orig_massign_sequence $massign_sequence			;#	OFFSET SEQUENCE
				unset massign_sequence
				set offset [lindex $symasamps(0) 0]
				set offset [expr double($offset) * $massign_invsrate]
				foreach {time val} $orig_massign_sequence {
					set time [expr $time - $offset]
					lappend massign_sequence $time $val
				}

				;#	INSERT THE OFFSET PROP IN PROPS FILE, IF SUCH A PROP EXISTS

				set kk 0											;#	INSERT THE OFFSET PROP IN PROPS FILE, IF SUCH A PROP EXISTS
				set k -1
				foreach nam $adp_propnames {
					if {[string match -nocase $nam "offset"]} {
						set k $kk
						break
					}
					incr kk
				}
				if {$k >= 0} {
					incr k		;#	POSITION OF 'OFFSET' PROPERTY ON SNDLINE
					set j [lsearch $adp_sndfiles $nuaddpsnd]
					if {$j >= 0} {
						set line [lindex $adp_props_list $j]
						set line [lreplace $line $k $k $offset]
						set adp_props_list [lreplace $adp_props_list $j $j $line]
						incr k -1
						$nuaddp_vals delete $k
						$nuaddp_vals insert $k $offset
					}
				}													;#	WRITE SYNTH BRKPNT DATA
				
				;#	INSERT THE HF PROP IN PROPS FILE, IF SUCH A PROP EXISTS

				set kk 0
				set k -1
				foreach nam $adp_propnames {
					if {[string match -nocase $nam "HF"]} {
						set k $kk
						break
					}
					incr kk
				}
				if {$k >= 0} {
					incr k			;#	Position of 'HF' property on sndline
					set j [lsearch $adp_sndfiles $nuaddpsnd]
					if {$j >= 0} {
						set nuhf [CreateTempHFData $massign_sequence]
						if {[string length $nuhf] > 0} {
							set line [lindex $adp_props_list $j]
							set line [lreplace $line $k $k $nuhf]
							set adp_props_list [lreplace $adp_props_list $j $j $line]
							incr k -1
							$nuaddp_vals delete $k
							$nuaddp_vals insert $k $nuhf
						}
					}
				}
				
				;#	GET LOUDNESSES AT TIMEMARKS IN ORDER TO WRITE SEQ FILE

				set cmd [file join $evv(CDPROGRAM_DIR) envel]
				lappend cmd extract 2 $massign_fnam $massignenv 50 -d0
				set prg_dun 0
				set prg_abortd 0
				catch {unset simple_program_messages}
				if [catch {open "|$cmd"} CDPidrun] {
					ErrShow "Cannot Extract Envelope From Source: $CDPidrun"
					catch {unset CDPidrun}
					continue
				} else {
					fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				if {!$prg_dun} {
					set msg "Cannot Extract Envelope From Source $fnam: $CDPidrun"
					set msg [AddSimpleMessages $msg]
					ErrShow $msg
					catch {file delete $out_fnam}
					continue
				}
				set levels [GetTimemarkLevels $massignenv $symatimes(0) $massign_dur]
				if {[llength $levels] > 0} {

					;#	WRITE SEQUENCE DATA, ASSUMING SEQ SRC HAS PITCH 60

					if [catch {open $outfnamseq "w"} zit] {
						Inf "Cannot Open File '$outfnamseq' To Write Sequence Data"
						continue
					}
					set massign_sequence [lreplace $massign_sequence 0 0 0.0]
					foreach {time midival} $massign_sequence level $levels {
						set line [list $time [expr $midival - 60] $level]
						puts $zit $line
					}
					close $zit
				} else {
					Inf "Cannot Create Sequence File"
				}
					;#	WRITE SYNTH BRKPNT DATA

				ConvertMassignSeqToFrqBrkpntAndSaveToFile $massign_sequence $outfnamfrq 1

				;#	WRITE FILTER DATA, WHICH IS NOT OFFSET, AS FILTER DATA MAY BE APPLIED TO SRC SND

				set massign_sequence $orig_massign_sequence			;#	WRITE FILTER DATA
				ConvertMassignSeqToFilterDataAndSaveToFile $massign_sequence $outfnamflt 0
				set nuaddpval "got_motif"
				UpdateBakupLog $outfnamseq create 0
				UpdateBakupLog $outfnamfrq create 0
				UpdateBakupLog $outfnamflt create 1
				FilesToWkspace $outfnamseq $outfnamfrq $outfnamflt
				set finished 1
			} else {

				;# CALLED FROM WORKSPACE, VARIOUS KINDS OF FILES MAY BE (INDEPENDENTLY) CREATED

				if {$massign_isseq <= 0} {
					Inf "No Output Filetype Specified"
					continue
				}
				if {[string length $massignoutfnam] <= 0} {
					Inf "No Output Filename Entered"
					continue
				}
				if {![ValidCDPRootname $massignoutfnam]} {
					continue
				}
				set outfnam [string tolower $massignoutfnam]
				if {($massign_isseq == $evv(ASSIGN_FILTDATA)) || ($massign_isseq == $evv(ASSIGN_FRQFILTDATA))} {
					append outfnam $evv(TEXT_EXT)
				} else {
					append outfnam [GetTextfileExtension brk]
				}
				if {[file exists $outfnam]} {
					set msg "File '$outfnam' Already Exists: Overwrite It ?"
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
					set i [LstIndx $outfnam $wl]
					if {![DeleteFileFromSystem $outfnam 0 1]} {
						Inf "Cannot Delete Existing File '$outfnam'"
						continue
					} else {
						DummyHistory $outfnam "DESTROYED"
						if {$i >= 0} {
							WkspCnt [$wl get $i] -1
							$wl delete $i
							catch {unset rememd}
						}
					}
				}
				if {($massign_isseq == $evv(ASSIGN_SEQ_OFFSET)) || ($massign_isseq == $evv(ASSIGN_FBRK_OFFSET))} {
					set orig_massign_sequence $massign_sequence
					unset massign_sequence
					set starttime [lindex $symasamps(0) 0]
					set starttime [expr double($starttime) * $massign_invsrate]
					foreach {time val} $orig_massign_sequence {
						set time [expr $time - $starttime]
						lappend massign_sequence $time $val
					}
					set massign_sequence [lreplace $massign_sequence 0 0 0.0]
				}
				switch -regexp -- $massign_isseq \
					^$evv(ASSIGN_SEQ)$ - \
					^$evv(ASSIGN_SEQ_OFFSET)$ {

						;#	GET LOUDNESSES AT TIMEMARKS IN ORDER TO WRITE SEQ FILE
						
						set cmd [file join $evv(CDPROGRAM_DIR) envel]
						lappend cmd extract 2 $massign_fnam $massignenv 50 -d0
						set prg_dun 0
						set prg_abortd 0
						catch {unset simple_program_messages}
						if [catch {open "|$cmd"} CDPidrun] {
							ErrShow "Cannot Extract Envelope From Source: $CDPidrun"
							catch {unset CDPidrun}
							continue
						} else {
							fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
						}
						vwait prg_dun
						if {$prg_abortd} {
							set prg_dun 0
						}
						if {!$prg_dun} {
							set msg "Cannot Extract Envelope From Source $fnam: $CDPidrun"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							catch {file delete $out_fnam}
							continue
						}
						set levels [GetTimemarkLevels $massignenv $symatimes(0) $massign_dur]
						if {[llength $levels] > 0} {
							if [catch {open $outfnam "w"} zit] {
								Inf "Cannot Open File '$outfnam' To Write Pitch Data"
								continue
							}
							foreach {time midival} $massign_sequence level $levels {
								set line [list $time [expr $midival - 60] $level]
								puts $zit $line
							}
							close $zit
						} else {
							Inf "Cannot Write Sequence File: No Peaks Data"
						}
					} \
					^$evv(ASSIGN_FRQBRK)$ - \
					^$evv(ASSIGN_FBRK_OFFSET)$ {
						if {![ConvertMassignSeqToFrqBrkpntAndSaveToFile $massign_sequence $outfnam 1]} {
							continue
						}
					} \
					^$evv(ASSIGN_FRQBRK_GLISS)$ - \
					^$evv(ASSIGN_FBRK_OFFSET_GLISS)$ {
						if {![ConvertMassignSeqToFrqGlisBrkpntAndSaveToFile $massign_sequence $outfnam 1]} {
							continue
						}
					} \
					^$evv(ASSIGN_FILTDATA)$ {
						if {![ConvertMassignSeqToFilterDataAndSaveToFile $massign_sequence $outfnam 0]} {
							continue
						}
					} \
					^$evv(ASSIGN_FRQFILTDATA)$ {
						if {![ConvertMassignSeqToFilterDataAndSaveToFile $massign_sequence $outfnam 1]} {
							continue
						}
					} \
					^$evv(ASSIGN_FILTDATA_GLISS)$ {
						if {![ConvertMassignSeqToGlisFilterDataAndSaveToFile $massign_sequence $outfnam 0]} {
							continue
						}
					} \
					^$evv(ASSIGN_FRQFILTDATA_GLISS)$ {
						if {![ConvertMassignSeqToGlisFilterDataAndSaveToFile $massign_sequence $outfnam 1]} {
							continue
						}
					}
									
				if {[info exists orig_massign_sequence]} {
					set massign_sequence $orig_massign_sequence
					unset orig_massign_sequence
				}
				UpdateBakupLog $outfnam create 1
				FileToWkspace $outfnam 0 0 0 0 1
				Inf "File '$outfnam' Is On The Workspace"
			}
		} else {
			set finished 1
		}
	}
	DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

#---- play text pitchfile contour (possibly with the original source sound)

proc PlayAssign {both} {
	global symasamps pm_numidilist massign_sequence massignsnd massign_pdatafile massign_srate massign_invsrate massign_dur 
	global prg_dun prg_abortd CDPidrun massign_last_sequence massignboth massign_fnam evv wstk pa evv
	global simple_program_messages

	if {![info exists symasamps(0)]} {
		Inf "No Timemarks Assigned To Source: Use \"Sound View\""
		return
	}
	if {![info exists pm_numidilist]} {
		Inf "No Pitches Assigned To Source"
		return
	}
	if {[llength $symasamps(0)] != [llength $pm_numidilist]} {
		Inf "Notes Not Assigned To Every Timemark"
		return
	}
	catch {unset massign_sequence}								;#	CONSTRUCT MELODY FROM MIDILIST AND TIMELIST
	foreach samptime $symasamps(0) midival $pm_numidilist {
		set time [expr double($samptime) * $massign_invsrate]
		lappend massign_sequence $time $midival
	}
	set massign_sequence [lreplace $massign_sequence 0 0 0.0]	;#	EXTEND TO TIME ZERO
	if {[MelodyHasChanged]} {
		if {[file exists $massignsnd]} {
			if [catch {file delete $massignsnd} zit] {
				Inf "Cannot Delete Existing Temporary Pitch File"
				return
			}
		}
		set cmd [file join $evv(CDPROGRAM_DIR) synth]
		if {![ConvertMassignSeqToFrqBrkpntAndSaveToFile $massign_sequence $massign_pdatafile 1]} {
			return
		}
		lappend cmd wave 1 $massignsnd $massign_srate 1 $massign_dur $massign_pdatafile -a0.25 -t256 
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		if [catch {open "|$cmd"} CDPidrun] {
			ErrShow "Cannot Generate Pitch From Displayed Melody: $CDPidrun"
			catch {unset CDPidrun}
			return
		} else {
			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			set msg "Cannot Generate Pitch From Displayed Melody: $CDPidrun"
			set msg [AddSimpleMessages $msg]
			ErrShow $msg
			return
		}
	}
	if {$both} {
		if {[MelodyHasChanged]} {
			if {[file exists $massignboth]} {
				if [catch {file delete $massignboth} zit] {
					Inf "Cannot Delete Existing Src+Pitch Sndfile"
					return
				}
			}
		}
		set is_stereo 0
		if {![file exists $massignboth]} {
			if {$pa($massign_fnam,$evv(CHANS)) == 2} {
				set is_stereo 1
				catch {unset mlines}
				set mline [list $massignsnd 0.0 1 0.5 C]
				lappend mlines $mline
				set mline [list $massign_fnam 0.0 2 0.5]
				lappend mlines $mline
				set mfnam $evv(DFLT_OUTNAME)
				append mfnam [GetTextfileExtension mix]
				if [catch {open $mfnam "w"} zit] {
					Inf "Cannot open temporary mixfile $mfnam"
					return
				}
				foreach mline $mlines {
					puts $zit $mline
				}
				close $zit
			}
			set cmd [file join $evv(CDPROGRAM_DIR) submix]
			if {$is_stereo} {
				lappend cmd mix $mfnam $massignboth
			} else {	
				lappend cmd interleave $massign_fnam $massignsnd $massignboth
			}
			set prg_dun 0
			set prg_abortd 0
			catch {unset simple_program_messages}
			if [catch {open "|$cmd"} CDPidrun] {
				ErrShow "Cannot mix pitchline sound with source: $CDPidrun"
				catch {unset CDPidrun}
				if {[file exists $mfnam]} {
					catch {file delete $mfnam}
				}
				return
			} else {
				fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
			}
			vwait prg_dun
			if {$prg_abortd} {
				set prg_dun 0
			}
			if {!$prg_dun} {
				set msg "Cannot mix pitchline sound with source: $CDPidrun"
				set msg [AddSimpleMessages $msg]
				ErrShow $msg
				if {[file exists $mfnam]} {
					catch {file delete $mfnam}
				}
				return
			}
		}
	}
	set massign_last_sequence $massign_sequence
	if {$both} {	
			PlaySndfile $massignboth 0
	} else {
		PlaySndfile $massignsnd 0
	}
}

#----- Has Melody Assigned to Soundfile changed ?

proc MelodyHasChanged {} {
	global massign_last_sequence massign_sequence
	if {![info exists massign_last_sequence]} {
		return 1
	}
	if {[llength $massign_last_sequence] != [llength $massign_sequence]} { 
		return 1
	}
	foreach note1 $massign_last_sequence note2 $massign_sequence {
		if {$note1 != $note2} {
			return 1
		}
	}
	return 0
}

#---- Clear grafix note display for Assign Pitchdata

proc AsgrafixClear {all} {
	global asgrafix pm_numidilist
	catch {$asgrafix delete notes}
	catch {$asgrafix delete flats}
	catch {$asgrafix delete ledger}
	if {$all} {
		catch {unset pm_numidilist}
	}
}
	
#---- Add note to grafix note display for Assign Pitchdata

proc AsgrafixAddPitch {w x y flat} {
	global symasamps pm_numidilist melwidth melstaveleft evv

	if {![info exists symasamps(0)]} {
		Inf "Assign Timemarks To File First"
		return
	}
	if {[info exists pm_numidilist]} {
		if {[llength $pm_numidilist] >= [llength $symasamps(0)]} {
			Inf "More Notes Than Timemarks"
			return
		}
	}
	if {$flat} {
		set displaylist [$w find withtag flathite]	;#	List all objects which are points
	} else {
		set displaylist [$w find withtag notehite]	;#	List all objects which are points
	}
	set notelist [$w find withtag notes]

	set mindiffy 100000								;#	Find closest pitch or flat-pitch value
	foreach thisobj $displaylist {
		set coords [$w coords $thisobj]
		set yy [lindex $coords 1]
		set diff [expr abs($y - $yy)]
		if {$diff < $mindiffy} {
			set yyy $yy
			set mindiffy $diff
		}
	}
	if {![info exists yyy]} {
		return
	}
	set thismidi [GetAssignPitchFromMouseClikHite [expr int(round($yyy))]]
	if {$thismidi < 0} {
		return
	}
	if {$flat} {
		incr thismidi -1
		if {$thismidi < $evv(VOCALLO_MIDI)} {
			return
		}
	}
	set mindiffx 100000					
	if {![info exists pm_numidilist] || ([llength $pm_numidilist] <= 0)} {
		lappend pm_numidilist $thismidi
	} else {

		foreach thisobj $notelist {
			set coords [$w coords $thisobj]
			lappend xlist [lindex $coords 0]
		}
		set xlist [lsort -increasing $xlist]
		set k 0
		catch {unset newpos}
		foreach xx $xlist {						;#	 insert new note in correct order-position in list
			if {$x < $xx} {
				if {$k > 0} {
					incr k -1
					set newpos [lrange $pm_numidilist 0 $k] 
					incr k
				}
				lappend newpos $thismidi
				set newpos [concat $newpos [lrange $pm_numidilist $k end]]
				set pm_numidilist $newpos
				break
			}
			incr k
		}
		if {![info exists newpos]} {
			lappend pm_numidilist $thismidi
		}
	}
	AsgrafixClear 0
	set len [llength $pm_numidilist]
	incr len 4
	set notestep [expr int(round(double($melwidth) / double($len)))]	
	set xpos [expr $melstaveleft + ($notestep * 2)]
	foreach midival $pm_numidilist {
		if {![InsertAssignPitchGrafix $xpos $midival]} {
			break
		}
		incr xpos $notestep
	}
}

proc AsgrafixDelPitch {w x y} {
	global pm_numidilist melwidth melstaveleft
	set displaylist [$w find withtag notes]	;#	List all objects which are notes

	if {[llength $displaylist] <= 0} {
		return
	}
	set mindiffx 100000								;#	Find closest note
	foreach thisobj $displaylist {
		set coords [$w coords $thisobj]
		set xx [lindex $coords 0]
		lappend xlist $xx
		set diff [expr abs($x - $xx)]
		if {$diff < $mindiffx} {
			set mindiffx $diff
			set xxx $xx
			set delobj $thisobj
		}
	}
	if {![info exists xxx]} {
		Inf "No Note Found At Mouse Click"
		return
	}
	set xlist [lsort -increasing $xlist]
	set k [lsearch $xlist $xxx]
	if {$k >= 0} {
		set pm_numidilist [lreplace $pm_numidilist $k $k]
	} else {
		Inf "Can't Determine Which Note Found At Mouse Click"
		return
	}
	AsgrafixClear 0
	set len [llength $pm_numidilist]
	incr len 4
	set notestep [expr int(round(double($melwidth) / double($len)))]	
	set xpos [expr $melstaveleft + ($notestep * 2)]
	foreach midival $pm_numidilist {
		InsertAssignPitchGrafix $xpos $midival
		incr xpos $notestep
	}
}

#--- Convert sequence info to breakfile format and write to data file

proc ConvertMassignSeqToFrqBrkpntAndSaveToFile {sequence outfile tofrq} {
	global massign_dur massign_pdatafile
	set backstep 0.05
	set dlbstep 0.1
	set lasttime [lindex $sequence 0]
	set lastval  [lindex $sequence 1]
	lappend outvals	[list $lasttime $lastval]
	set len [llength $sequence]
	set n 2
	set m 3
	while {$n < $len} {
		set time [lindex $sequence $n]
		set val  [lindex $sequence $m]
		set advance [expr $time - $lasttime]
		if {$advance < $dlbstep} {
			set anacru [expr $advance / 2.0]
		} else {
			set anacru $backstep
		}
		set anacruline [list [expr $time - $anacru] $lastval]
		lappend outvals $anacruline
		lappend outvals [list $time $val]
		set lasttime $time
		set lastval $val
		incr n 2
		incr m 2
	}
	set line [list $massign_dur $val]
	lappend outvals $line
	if {$tofrq} {
		foreach line $outvals {
			set time [lindex $line 0]
			set frq [MidiToHz [lindex $line 1]]
			lappend frqoutoutvals [list $time $frq]
		}
		set outvals $frqoutoutvals
	}
	if [catch {open $outfile "w"} zit] {
		Inf "Cannot Open File '$outfile'"
		return 0
	}
	foreach line $outvals {
		puts $zit $line
	}
	close $zit
	return 1
}

#--- Convert sequence info to breakfile format with glissi and write to data file

proc ConvertMassignSeqToFrqGlisBrkpntAndSaveToFile {sequence outfile tofrq} {
	global massign_dur massign_pdatafile
	foreach {time val} $sequence {
		if {$tofrq} {
			set val [MidiToHz $val]
		}
		lappend outvals [list $time $val]
	}
	if [catch {open $outfile "w"} zit] {
		Inf "Cannot Open File '$outfile'"
		return 0
	}
	foreach line $outvals {
		puts $zit $line
	}
	close $zit
	return 1
}

#--- Convert sequence info to varibank filter format and write to data file

proc ConvertMassignSeqToFilterDataAndSaveToFile {sequence outfile tofrq} {
	global massign_dur massign_pdatafile
	set backstep 0.05
	set dlbstep 0.1
	set lasttime [lindex $sequence 0]
	set lastval  [lindex $sequence 1]
	lappend outvals	[list $lasttime $lastval 1]
	set len [llength $sequence]
	set n 2
	set m 3
	while {$n < $len} {
		set time [lindex $sequence $n]
		set val  [lindex $sequence $m]
		set advance [expr $time - $lasttime]
		if {$advance < $dlbstep} {
			set anacru [expr $advance / 2.0]
		} else {
			set anacru $backstep
		}
		set anacruline [list [expr $time - $anacru] $lastval 1]
		lappend outvals $anacruline
		lappend outvals [list $time $val 1]
		set lasttime $time
		set lastval $val
		incr n 2
		incr m 2
	}
	set line [list $massign_dur $val 1]
	lappend outvals $line
	if {$tofrq} {
		foreach line $outvals {
			set time [lindex $line 0]
			set frq [MidiToHz [lindex $line 1]]
			lappend frqoutoutvals [list $time $frq 1]
		}
		set outvals $frqoutoutvals
	}
	if [catch {open $outfile "w"} zit] {
		Inf "Cannot Open File '$outfile'"
		return 0
	}
	foreach line $outvals {
		puts $zit $line
	}
	close $zit
	return 1
}

#--- Convert sequence info to glisd varibank filter format and write to data file

proc ConvertMassignSeqToGlisFilterDataAndSaveToFile {sequence outfile tofrq} {
	global massign_dur massign_pdatafile
	foreach {time val} $sequence {
		if {$tofrq} {
			set val [MidiToHz $val]
		}
		lappend outvals [list $time $val 1]
	}
	if [catch {open $outfile "w"} zit] {
		Inf "Cannot Open File '$outfile'"
		return 0
	}
	foreach line $outvals {
		puts $zit $line
	}
	close $zit
	return 1
}

#------ Establish interactive pstaff notation display

proc EstablishMelodyEntryDisplay {pstaff} {
	global evv melstaveleft melstaveright melwidth

	#	CANVAS AND VALUE LISTING

	set melscreen [canvas $pstaff.c -height 200 -width 800 -borderwidth 0 \
		-highlightthickness 1 -highlightbackground $evv(SPECIAL)]

	set melstaveleft 120
	set melstaveright 760
	set melwidth [expr $melstaveright - $melstaveleft]

	#TREBLE CLEF
	set clef1a [$melscreen create line 90 30 90  95 -width 1 -fill $evv(POINT)]
	set clef1b [$melscreen create arc  90 24 102 36 -style arc -start 180 -extent -230 -width 1 -outline $evv(POINT)]
	set clef1c [$melscreen create line 98 35 80  70 -width 1 -fill $evv(POINT)]
	set clef1d [$melscreen create arc  80 60 100 80 -style arc -start 180 -extent 270 -width 1 -outline $evv(POINT)]

	$melscreen create line 80  20 780 20 -tag notehite -fill [option get . background {}]
	$melscreen create line 80  25 780 25 -tag {notehite flathite} -fill [option get . background {}]
	$melscreen create line 80  30 780 30 -tag {notehite flathite} -fill [option get . background {}]
	$melscreen create line 80  35 780 35 -tag {notehite flathite} -fill [option get . background {}]
	$melscreen create line 80  40 780 40 -tag notehite -fill $evv(POINT)
	$melscreen create line 80  45 780 45 -tag {notehite flathite} -fill [option get . background {}]
	$melscreen create line 80  50 780 50 -tag {notehite flathite} -fill $evv(POINT)
	$melscreen create line 80  55 780 55 -tag notehite -fill [option get . background {}]
	$melscreen create line 80  60 780 60 -tag {notehite flathite} -fill $evv(POINT)
	$melscreen create line 80  65 780 65 -tag {notehite flathite} -fill [option get . background {}]
	$melscreen create line 80  70 780 70 -tag {notehite flathite} -fill $evv(POINT)
	$melscreen create line 80  75 780 75 -tag notehite -fill [option get . background {}]
	$melscreen create line 80  80 780 80 -tag {notehite flathite} -fill $evv(POINT)
	$melscreen create line 80  85 780 85 -tag {notehite flathite} -fill [option get . background {}]
	$melscreen create line 80  90 780 90 -tag notehite -fill [option get . background {}]

	$melscreen create line 80  95 80  245 -tag {notehite flathite} -fill [option get . background {}]
	$melscreen create line 80  100 780 100 -tag {notehite flathite} -fill $evv(POINT)
	$melscreen create line 80  105 780 105 -tag {notehite flathite} -fill [option get . background {}]
	$melscreen create line 80  110 780 110 -tag notehite -fill $evv(POINT)
	$melscreen create line 80  115 780 115 -tag {notehite flathite} -fill [option get . background {}]
	$melscreen create line 80  120 780 120 -tag {notehite flathite} -fill $evv(POINT)
	$melscreen create line 80  125 780 125 -tag notehite -fill [option get . background {}]
	$melscreen create line 80  130 780 130 -tag {notehite flathite} -fill $evv(POINT)
	$melscreen create line 80  135 780 135 -tag {notehite flathite} -fill [option get . background {}]
	$melscreen create line 80  140 780 140 -tag {notehite flathite} -fill $evv(POINT)
	$melscreen create line 80  145 780 145 -tag notehite -fill [option get . background {}]
	$melscreen create line 80  150 780 150 -tag {notehite flathite} -fill [option get . background {}]
	$melscreen create line 80  155 780 155 -tag {notehite flathite} -fill [option get . background {}]
	$melscreen create line 80  160 780 160 -tag notehite -fill [option get . background {}]

	#BASS CLEF
	set bclef2a [$melscreen create arc  80  100 107 135 -style arc -start 30 -extent 120 -width 1 -outline $evv(POINT)]
	set bclef2b [$melscreen create arc  25  75  105 145 -style arc -start 5 -extent -75 -width 1 -outline $evv(POINT)]
	set bclef2c [$melscreen create oval 109 104 111 106 -fill $evv(POINT) -outline $evv(POINT)]
	set bclef2d [$melscreen create oval 109 114 111 116 -fill $evv(POINT) -outline $evv(POINT)]

	return $melscreen
}

#----- Draw note on assign-pitch-data graphics display

proc InsertAssignPitchGrafix {xx midival} {
	global asgrafix evv

	if {($midival < $evv(VOCALLO_MIDI)) || ($midival > $evv(VOCALHI_MIDI))} {
		Inf "Out Of Range" 
		return 0
	}
	set xpos1 $xx
	set xpos2	 [expr $xpos1 + $evv(NOTEWIDTH)]
	set xpos1leg [expr $xpos1 - $evv(LEDGE_OFFSET)]
	set xpos2leg [expr $xpos1leg + $evv(LEDGELEN)]
								;#	draw note heads
	switch -- $midival {	
		84	{
				set noteC2  [$asgrafix create oval $xpos1 17 $xpos2 23 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
				$asgrafix create line $xpos1leg 20 $xpos2leg 20 -fill $evv(POINT)							  -tag ledger 
				$asgrafix create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT)							  -tag ledger
		}
		83	{
				set noteB1  [$asgrafix create oval $xpos1 22 $xpos2 28 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				$asgrafix create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT)							  -tag ledger
		}
		82	{	
				$asgrafix create text [expr $xpos1 - 4] 29 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag flats
				set noteBb1 [$asgrafix create oval $xpos1 22 $xpos2 28 -fill $evv(POINT) -outline $evv(POINT)    -tag {notes flat $xpos1}] 
				$asgrafix create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT)								 -tag ledger
		}
		81	{	
				set noteA1  [$asgrafix create oval $xpos1 27 $xpos2 33 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
				$asgrafix create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT)							  -tag ledger
		}
		80	{	
				$asgrafix create text [expr $xpos1 - 4] 34 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag flats
				set noteAb1 [$asgrafix create oval $xpos1 27 $xpos2 33 -fill $evv(POINT) -outline $evv(POINT)    -tag {notes flat $xpos1}] 
				$asgrafix create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT)							     -tag ledger
			}
		79	{
				set noteG1  [$asgrafix create oval $xpos1 32 $xpos2 38 -fill $evv(POINT) -outline $evv(POINT)  -tag notes]
		}
		78	{	
				$asgrafix create text [expr $xpos1 - 4] 39 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag flats
				set noteGb1 [$asgrafix create oval $xpos1 32 $xpos2 38 -fill $evv(POINT) -outline $evv(POINT)    -tag {notes flat}] 
			}
		77	{
				set noteF1  [$asgrafix create oval $xpos1 37 $xpos2 43 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
		}
		76	{
				set noteE1  [$asgrafix create oval $xpos1 42 $xpos2 48 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
		}
		75	{	
				$asgrafix create text [expr $xpos1 - 4] 49 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag flats
				set noteEb1 [$asgrafix create oval $xpos1 42 $xpos2 48 -fill $evv(POINT) -outline $evv(POINT)    -tag {notes flat}] 
			}
		74	{
				set noteD1  [$asgrafix create oval $xpos1 47 $xpos2 53 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
		}
		73	{	
				$asgrafix create text [expr $xpos1 - 4] 54 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag flats
				set noteDb1 [$asgrafix create oval $xpos1 47 $xpos2 53 -fill $evv(POINT) -outline $evv(POINT)    -tag {notes flat}] 
			}
		72	{
				set noteC1  [$asgrafix create oval $xpos1 52 $xpos2 58 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
		}
		71	{
				set noteB0  [$asgrafix create oval $xpos1 57 $xpos2 63 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
		}
		70	{	
				$asgrafix create text [expr $xpos1 - 4] 64 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag flats
				set noteBb0 [$asgrafix create oval $xpos1 57 $xpos2 63 -fill $evv(POINT) -outline $evv(POINT)    -tag {notes flat}] 
			}
		69	{
				set noteA0  [$asgrafix create oval $xpos1 62 $xpos2 68 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
		}
		68	{	
				$asgrafix create text [expr $xpos1 - 4] 69 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag flats
				set noteAb0 [$asgrafix create oval $xpos1 62 $xpos2 68 -fill $evv(POINT) -outline $evv(POINT)    -tag {notes flat}] 
			}
		67	{
				set noteG0  [$asgrafix create oval $xpos1 67 $xpos2 73 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
		}
		66	{	
				$asgrafix create text [expr $xpos1 - 4] 74 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag flats
				set noteGb0 [$asgrafix create oval $xpos1 67 $xpos2 73 -fill $evv(POINT) -outline $evv(POINT)    -tag {notes flat}] 
			}
		65	{
				set noteF0  [$asgrafix create oval $xpos1 72 $xpos2 78 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
		}
		64	{
				set noteE0  [$asgrafix create oval $xpos1 77 $xpos2 83 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
		}
		63	{	
				$asgrafix create text [expr $xpos1 - 4] 84 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag flats
				set noteEb0 [$asgrafix create oval $xpos1 77 $xpos2 83 -fill $evv(POINT) -outline $evv(POINT)    -tag {notes flat}] 
			}
		62	{
				set noteD0  [$asgrafix create oval $xpos1 82 $xpos2 88 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
		}
		61	{	
				$asgrafix create text [expr $xpos1 - 4] 89 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag flats
				set noteDb0 [$asgrafix create oval $xpos1 82 $xpos2 88 -fill $evv(POINT) -outline $evv(POINT)    -tag {notes flat}] 
		}
		60	{
				set noteC0  [$asgrafix create oval $xpos1 87 $xpos2 93 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
				$asgrafix create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT)							  -tag ledger
		}
		59	{
				set noteB-1  [$asgrafix create oval $xpos1 92 $xpos2 98 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
		}
		58	{	
				$asgrafix create text [expr $xpos1 - 4] 99 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag flats
				set noteBb-1 [$asgrafix create oval $xpos1 92 $xpos2 98 -fill $evv(POINT) -outline $evv(POINT)   -tag {notes flat}] 
			}
		57	{
				set noteA-1  [$asgrafix create oval $xpos1 97 $xpos2 103 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
		}
		56	{	
				$asgrafix create text [expr $xpos1 - 4] 104 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag flats
				set noteAb-1 [$asgrafix create oval $xpos1 97 $xpos2 103 -fill $evv(POINT) -outline $evv(POINT)  -tag {notes flat}] 
			}
		55	{
				set noteG-1  [$asgrafix create oval $xpos1 102 $xpos2 108 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
		}
		54	{	
				$asgrafix create text [expr $xpos1 - 4] 109 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag flats
				set noteGb-1 [$asgrafix create oval $xpos1 102 $xpos2 108 -fill $evv(POINT) -outline $evv(POINT)  -tag {notes flat}] 
			}
		53	{
				set noteF-1  [$asgrafix create oval $xpos1 107 $xpos2 113 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
		}
		52	{
				set noteE-1  [$asgrafix create oval $xpos1 112 $xpos2 118 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
		}
		51	{	
				$asgrafix create text [expr $xpos1 - 4] 119 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag flats
				set noteEb-1 [$asgrafix create oval $xpos1 112 $xpos2 118 -fill $evv(POINT) -outline $evv(POINT)  -tag {notes flat}] 
			}
		50	{
				set noteD-1  [$asgrafix create oval $xpos1 117 $xpos2 123 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
		}
		49	{	
				$asgrafix create text [expr $xpos1 - 4] 124 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag flats
				set noteDb-1 [$asgrafix create oval $xpos1 117 $xpos2 123 -fill $evv(POINT) -outline $evv(POINT)  -tag {notes flat}] 
			}
		48	{
				set noteC-1  [$asgrafix create oval $xpos1 122 $xpos2 128 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
		}
		47	{
				set noteB-2  [$asgrafix create oval $xpos1 127 $xpos2 133 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
		}
		46	{	
				$asgrafix create text [expr $xpos1 - 4] 134 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag flats
				set noteBb-2 [$asgrafix create oval $xpos1 127 $xpos2 133 -fill $evv(POINT) -outline $evv(POINT)  -tag {notes flat}] 
			}
		45	{
				set noteA-2  [$asgrafix create oval $xpos1 132 $xpos2 138 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
		}
		44	{	
				$asgrafix create text [expr $xpos1 - 4] 139 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag flats
				set noteAb-2 [$asgrafix create oval $xpos1 132 $xpos2 138 -fill $evv(POINT) -outline $evv(POINT)  -tag {notes flat}] 
			}
		43	{
				set noteG-2  [$asgrafix create oval $xpos1 137 $xpos2 143 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
		}
		42	{	
				$asgrafix create text [expr $xpos1 - 4] 144 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag flats
				set noteGb-2 [$asgrafix create oval $xpos1 137 $xpos2 143 -fill $evv(POINT) -outline $evv(POINT)  -tag {notes flat}] 
			}
		41	{
				set noteF-2  [$asgrafix create oval $xpos1 142 $xpos2 148 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
		}
		40	{
				set noteE-2  [$asgrafix create oval $xpos1 147 $xpos2 153 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
				$asgrafix create line $xpos1leg 150 $xpos2leg 150 -fill $evv(POINT)								 -tag ledger
		}
		39	{	
				$asgrafix create text [expr $xpos1 - 4] 154 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag flats
				set noteEb-2 [$asgrafix create oval $xpos1 147 $xpos2 153 -fill $evv(POINT) -outline $evv(POINT) -tag {notes flat}] 
				$asgrafix create line $xpos1leg 150 $xpos2leg 150 -fill $evv(POINT)								  -tag ledger
			}
		38	{	
				set noteD-2  [$asgrafix create oval $xpos1 152 $xpos2 158 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
				$asgrafix create line $xpos1leg 150 $xpos2leg 150 -fill $evv(POINT)								 -tag ledger
		}
		37	{	
				$asgrafix create text [expr $xpos1 - 4] 159 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag flats
				set noteDb-2 [$asgrafix create oval $xpos1 152 $xpos2 158 -fill $evv(POINT) -outline $evv(POINT)  -tag {notes flat}] 
				$asgrafix create line $xpos1leg 150 $xpos2leg 150 -fill $evv(POINT) 							  -tag ledger
			}
		36	{	
				set noteC-2  [$asgrafix create oval $xpos1 157 $xpos2 163 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
				$asgrafix create line $xpos1leg 150 $xpos2leg 150 -fill $evv(POINT) 							 -tag ledger
				$asgrafix create line $xpos1leg 160 $xpos2leg 160 -fill $evv(POINT) 							 -tag ledger
		}
	}
	return 1
}

proc GetAssignPitchFromMouseClikHite {y} {
	set y [expr int(round(double($y) / 5.0))]	;#	ROUND TO NEAREST MULTIPLE OF 5
	set y [expr $y * 5]
	switch -- $y {
		20	{set midi 84}
		25  {set midi 83}
		30	{set midi 81}
		35	{set midi 79}
		40	{set midi 77}
		45	{set midi 76}
		50	{set midi 74}
		55	{set midi 72}
		60	{set midi 71}
		65	{set midi 69}
		70	{set midi 67}
		75	{set midi 65}
		80	{set midi 64}
		85	{set midi 62}
		90	{set midi 60}
		95	{set midi 59}
		100	{set midi 57}
		105	{set midi 55}
		110	{set midi 53}
		115	{set midi 52}
		120	{set midi 50}
		125	{set midi 48}
		130	{set midi 47}
		135	{set midi 45}
		140	{set midi 43}
		145	{set midi 41}
		150	{set midi 40}
		155	{set midi 38}
		160 {set midi 36}
		default {
			set midi -1
		}
	}
	return $midi
}

proc MidiBrkSeqHelp2 {} {
	set msg "                          BRKPNTS AND SEQUENCES\n"
	append msg "\n"
	append msg "MIDI SEQUENCE file contains onset times of samples\n"
	append msg "their semitone transpositions, and levels (0-1).\n"
	append msg "and can be used in \"extend sequence\".\n"
	append msg "They assume default pitch 60 for sample used.\n"
	append msg "(You can transpose sequence file for other pitches).\n"
	append msg "\n"
	append msg "VARIBANK FILTER DATA file contains filter data\n"
	append msg "following the pitch specified.\n"
	append msg "\n"
	append msg "FRQ BRKPNT file contains data to control synthesis\n"
	append msg "or might be converted to varibank filter format.\n"
	append msg "\n"
	append msg "ALL data formats adjusted so that the pitch at\n"
	append msg "1st specified timemark is extended to begin at zero\n"
	append msg "in the output data (and the rest of the pattern\n"
	append msg "remains in sync with the source).\n"
	append msg "\n"
	append msg "However, If the pattern is OFFSET..\n"
	append msg "it starts at time of the first timemark in srcfile.\n"
	append msg "Otherwise, 1st event extended to start at time zero.\n"
	append msg "(Filter data is NOT offset).\n"
	append msg "\n"
	append msg "If the pattern is GLISS.\n"
	append msg "the output data glisses from pitch to pitch.\n"
	append msg "Default is that pitches are sustained until the next pitch begins.\n"
	append msg "'Play' always plays the NON-glissed pitches.\n"
	Inf $msg
}

#------ Put several files TEXTFILES (NOT PROPFILES) on wkspace (PREVIOUSLY CHECKED for validity!!) WHICH ARE NOT ALREADY ON THE WORKSPACE

proc FilesToWkspace {args} {
	global wl do_parse_report rememd wkspace_newfile
	foreach fnam $args {
		set do_parse_report 1
		switch -- [DoParse $fnam $wl 2 0] {
			0		{}						
			-1		{}						
			default	{
				$wl insert 0 $fnam
				WkspCnt $fnam 1
				catch {unset rememd}
			}
		}
		set wkspace_newfile 1
	}
}

#------ Get levels at timemarks from an envelope data file

proc GetTimemarkLevels {envfile tmarks dur} {

	if [catch {open $envfile "r"} zit] {
		Inf "Cannot Open Envelope Data File To Process It"
		return {}
	}
	set envdata {}
	while {[gets $zit line] >= 0} {
#FEB 2022
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		} elseif {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		catch {unset nuline}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend nuline $item
			}
		}
		if {[llength $nuline] != 2} {
			Inf "Anomalous Data In Envelope File '$envfile'"
			return {}
		}
		set envdata [concat $envdata $nuline]
	}
	close $zit
	if {![info exists envdata]} {
		Inf "NO DATA IN ENVELOPE FILE '$envfile'"
		return {}
	}
	set tmlen [llength $tmarks]
	if {$tmlen == 1} {
		return 1.0	;# NORMALISED
	}														;#	TMARKS AT |     @		@		@	|
	set lasttime [lindex $tmarks 0]							;#	CHUNKS AT ----------_________--------
	foreach time [lrange $tmarks 1 end] {					;#
		set gap [expr $time - $lasttime]					;#	FIND MAX IN EACH CHUNK AND ASSIGN TO TMARK					
		lappend chunkends [expr $lasttime + ($gap / 2.0)]
		set lasttime $time
	}
	lappend chunkends $dur
	set n 0
	set maxval -1
	foreach {time val} $envdata {
		if {$time < [lindex $chunkends $n]} {
			if {$val > $maxval} {
				set maxval $val
			}
		} else {
			lappend levels $maxval
			set maxval -1
			incr n
			if {$n >= $tmlen} {
				break
			}
		}
	}
	if {[llength $levels] != $tmlen} {
		Inf "Anomaly In Count Of Timemark Levels"
		return {}
	}
	set maxval -1
	foreach val $levels {
		if {$val > $maxval} {
			set maxval $val
		}
	}
	if {$maxval <= 0} {
		Inf "No Signal Level Found In Source File"
		return {}
	}
	if {$maxval < 1.0} {		;#	NORMALISE
		set origlevs $levels
		unset levels
		foreach val $origlevs {
			lappend levels [expr $val / $maxval]
		}
	}
	return $levels
}

#------ Transpose a default sequencer file (from PRops motif) to work on src of pitch other than 60

proc TransposeC60SequenceFileToGivenPitch {} {
	global pr_seqtran seqtranfnam seqtranmidi evv mu wl chlist pa

	set i [$wl curselection]
	if {([llength $i] != 1) || ($i == -1)} {
		if {![info exists chlist] || ([llength $chlist] != 1)} {
			Inf "Select One Sequence File"
			return
		}
		set seqfile [lindex $chlist 0]
	} else {
		set seqfile [$wl get $i]
	}
	if {![IsABrkfile $pa($seqfile,$evv(FTYP))] && ![IsAListofNumbers $pa($seqfile,$evv(FTYP))]} {
		Inf "Select A Sequence Data File"
		return
	}
	set seqdata {}
	if [catch {open $seqfile "r"} zit] {
		Inf "Cannot Open File '$seqfile' To Read Data"
		return
	}
	set cnt 1
	while {[gets $zit line] >= 0} {
#FEB 2022
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		} elseif {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		catch {unset nuline}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend nuline $item
			}
		}
		if {[llength $nuline] != 3} {
			Inf "Anomalous Data In Sequence File (Lines Are Not Value-Triples)"
			return
		}
		foreach {time val level} $nuline {
			if {$cnt == 1} {
				if {![Flteq $time 0.0]} {
					Inf "Problem With Data In '$fnam' : First Entry Is Not At Time Zero"
					return
				}
			} elseif {$time <= $lasttime} {
				Inf "Problem With Data In '$fnam' : Times Do Not Increase On Line $cnt"
				return
			}
			if {($val > 48) || ($val < -48)} {
				Inf "Problem With Data In '$fnam' : Transposition Out Of Range On Line $cnt"
				return
			}
			if {($level > 1.0) || ($level < 0.0)} {
				Inf "Problem With Data In '$fnam' : Level Out Of Range On Line $cnt"
				return
			}
			set lasttime $time
			incr cnt
		}
		set seqdata [concat $seqdata $nuline]
	}
	close $zit
	set f .seqtran
	if [Dlg_Create $f "TRANSPOSE SEQUENCE DATA" "set pr_seqtran 0" -width 60 -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0]
		set f1 [frame $f.1]
		set f2 [frame $f.2]
		set f3 [frame $f.3]
		button $f0.quit -text "Abandon" -command {set pr_seqtran 0} -highlightbackground [option get . background {}]
		button $f0.ok  -text "Transpose" -command {set pr_seqtran 1} -highlightbackground [option get . background {}]
		pack $f0.quit -side right
		pack $f0.ok -side left
		pack $f.0 -side top -fill x -expand true -pady 3
		label $f.1.1 -text "Process assumes INPUT sequencer file is set up"		-fg $evv(SPECIAL)
		label $f.1.2 -text "to work on src of default MIDI pitch 60 (middle C)" -fg $evv(SPECIAL)
		label $f.1.3 -text "(e.g. sequencer outputfile from 'motif' property)"  -fg $evv(SPECIAL)
		pack $f.1.1 $f.1.2 $f.1.3 -side top
		 pack $f.1 -side top -pady 3
		label $f2.ll -text "MIDI pitch of the soruce sound "
		entry $f2.e -textvariable seqtranmidi -width 16
		pack $f2.ll $f2.e -side left
		pack $f.2 -side top -pady 6 -pady 3
		label $f3.ll -text "Output Filename "
		entry $f3.e -textvariable seqtranfnam -width 16
		pack $f3.ll $f3.e -side left
		pack $f.3 -side top -pady 6 -pady 3
		bind $f2.e <Up>		{IncrSeqtranMidi 1}
		bind $f2.e <Down>	{IncrSeqtranMidi 1}
		wm resizable $f 1 1
		bind $f <Return> {set pr_seqtran 1}
		bind $f <Escape> {set pr_seqtran 0}
	}
	wm title $f "TRANSPOSE SEQUENCE DATA $seqfile"
	set seqtranmidi 60
	set seqtranfnam ""
	raise $f
	update idletasks
	StandardPosition $f
	set finished 0
	set pr_seqtran 0
	My_Grab 0 $f pr_seqtran $f.2.e
	while {!$finished} {
		tkwait variable pr_seqtran
		if {$pr_seqtran} {
			if {[string length $seqtranmidi] <= 0} {
				Inf "No Source Midi Pitch Entered"
				continue
			}
			if {![regexp {^[0-9]+$} $seqtranmidi] || ($seqtranmidi > 127)} {
				Inf "Invalid Source Midi Pitch Entered"
				continue
			}
			if {[string length $seqtranfnam] <= 0} {
				Inf "No Output Filename Entered"
				continue
			}
			if {![ValidCDPRootname $seqtranfnam]} {
				continue
			}
			set outfnam [string tolower $seqtranfnam]
			append outfnam $evv(TEXT_EXT)
			if {[file exists $outfnam]} {
				Inf "File '$outfnam' Already Exists: Choose Another Name"
				continue
			}
			if [catch {open $outfnam "w"} zit] {
				Inf "Cannot Open File '$outfnam' To Write New Data"
				continue
			}
			catch {unset nulines}
			foreach {time transpos level} $seqdata {
				set transpos [expr (60 - $seqtranmidi) + $transpos]
				set line [list $time $transpos $level]
				puts $zit $line
			}
			close $zit
			FileToWkspace $outfnam 0 0 0 0 1
			Inf "File '$outfnam' Is Now On The Workspace"
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

#------ Incr or decr MIDI value with Up Down keys.

proc IncrSeqtranMidi {up} {
	global seqtranmidi
	if {![regexp {^[0-9]+$} $seqtranmidi]} {
		return
	}
	if {$up} {
		if {$seqtranmidi < 127} {
			incr seqtranmidi
		}
	} else {
		if {$seqtranmidi > 0} {
			incr seqtranmidi -1
		}
	}
}

#----- Tempered frq brkpnt data (from props perhaps) + list of peak levels for each note
#----- converted to a sequencer control file based on default sample-pitch of 60(middleC)

proc ConvertFrqbrkpntDataAndPeakLevelDataToSequencer60Data {} {
	global pr_seqpk seqpkfnam evv wl chlist pa mu
	set ilist [$wl curselection]
	if {[llength $ilist] != 2} {
		if {![info exists chlist] || ([llength $chlist] != 2)} {
			Inf "Select One Sequence File"
			return
		}
		set pkfile  [lindex $chlist 0]
		set frqfile [lindex $chlist 1]
	} else {
		set pkfile  [$wl get [lindex $ilist 0]]
		set frqfile [$wl get [lindex $ilist 1]]
	}
	set frqdata {}
	set pkdata {}
	set ftyp $pa($pkfile,$evv(FTYP))
	if {![IsABrkfile $ftyp] && ![IsAListofNumbers $ftyp]} {
		Inf "Use One Frq Brkpnt File And One Corresponding List Peak Levels"
		return
	}
	set ftyp $pa($frqfile,$evv(FTYP))
	if {![IsABrkfile $ftyp] && ![IsAListofNumbers $ftyp]} {
		Inf "Use One Frq Brkpnt File And One Corresponding List Peak Levels"
		return
	}
	if [catch {open $pkfile "r"} zit] {
		Inf "Cannot Open File $pkfile To Read Data"
		return
	}
	while {[gets $zit line] >= 0} {
#FEB 2022
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		} elseif {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend pkdata $item
			}
		}
	}
	close $zit
	if [catch {open $frqfile "r"} zit] {
		Inf "Cannot Open File $frqfile To Read Data"
		return
	}
	while {[gets $zit line] >= 0} {
#FEB 2022
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		} elseif {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend frqdata $item
			}
		}
	}
	close $zit
	if {[llength $pkdata] > [llength $frqdata]} {
		set temp    $pkdata
		set pkdata  $frqdata
		set frqdata $temp
		set temp    $pkfile
		set pkfile  $frqfile
		set frqfile $temp
	}
	if {([llength $pkdata] * 4) != [llength $frqdata]} {
		Inf "Inappropriate Data Files : Lengths Of Data Do Not Correspond"
		return
	}
	if {![IsABrkfile $pa($frqfile,$evv(FTYP))] || ($pa($frqfile,$evv(MAXBRK)) > [MidiToHz $mu(MIDIMAX)]) || ($pa($frqfile,$evv(MINBRK)) < [MidiToHz $mu(MIDIMIN)])} {
		Inf "Inappropriate Data For A Frequency Brkpnt File"
		return
	}
	if {![IsABrkfile $pa($pkfile,$evv(FTYP))] && ![IsAListofNumbers $pa($pkfile,$evv(FTYP))]} {
		Inf "Inappropriate Data For Peaks"
		return
	}
	set cnt 1
	foreach val $pkdata {
		if {($val > 1.0) || ($val < 0.0)} {
			Inf "Problem With Data In '$fnam' : Level Out Of Range On Line $cnt"
			return
		}
		incr cnt
	}
	set f .seqpk
	if [Dlg_Create $f "GENERATE SEQUENCE DATA" "set pr_seqpk 0" -width 60 -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0]
		set f1 [frame $f.1]
		button $f0.quit -text "Abandon"   -command {set pr_seqpk 0} -highlightbackground [option get . background {}]
		button $f0.ok  -text "Create Seq" -command {set pr_seqpk 1} -highlightbackground [option get . background {}]
		pack $f0.quit -side right
		pack $f0.ok -side left
		pack $f.0 -side top -fill x -expand true -pady 3
		label $f1.ll -text "Output Filename "
		entry $f1.e -textvariable seqpkfnam -width 16
		pack $f1.ll $f1.e -side left
		pack $f.1 -side top -pady 6 -pady 3
		wm resizable $f 1 1
		bind $f <Return> {set pr_seqpk 1}
		bind $f <Escape> {set pr_seqpk 0}
	}
	wm title $f "GENERATE SEQUENCE DATA"
	set seqpkfnam ""
	raise $f
	update idletasks
	StandardPosition $f
	set finished 0
	set pr_seqpk 0
	My_Grab 0 $f pr_seqpk $f.1.e
	while {!$finished} {
		tkwait variable pr_seqpk
		if {$pr_seqpk} {
			if {[string length $seqpkfnam] <= 0} {
				Inf "No Output Filename Entered"
				continue
			}
			if {![ValidCDPRootname $seqpkfnam]} {
				continue
			}
			set outfnam [string tolower $seqpkfnam]
			append outfnam $evv(TEXT_EXT)
			if {[file exists $outfnam]} {
				Inf "File '$outfnam' Already Exists: Choose Another Name"
				continue
			}
			if [catch {open $outfnam "w"} zit] {
				Inf "Cannot Open File '$outfnam' To Write New Data"
				continue
			}

			;#	WRITE SEQUENCE DATA, ASSUMING SEQ SRC HAS PITCH 60

			foreach {time frq time2 frq2} $frqdata level $pkdata {
				set midi [expr int(round([HzToMidi $frq]))]
				set line [list $time [expr $midi - 60] $level]
				puts $zit $line
			}
			close $zit
			FileToWkspace $outfnam 0 0 0 0 1
			Inf "File $outfnam Is Now On The Workspace"
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

#---- Convert between Frq breakpnt and Standard MIDI  binary file

proc FrqBrkToStandardMidi {staccato} {
	global tcl_platform wl chlist pr_fbrktomidi rememd wstk mu pa evv
	global prg_dun prg_abortd CDPidrun simple_program_messages
	set ilist [$wl curselection]
	if {[llength $ilist] != 2} {
		if {![info exists chlist] || ([llength $chlist] != 2)} {
			Inf "Select One Freq Brkpnt File And One List Of Peak Levels"
			return
		}
		set pkfile  [lindex $chlist 0]
		set frqfile [lindex $chlist 1]
	} else {
		set pkfile  [$wl get [lindex $ilist 0]]
		set frqfile [$wl get [lindex $ilist 1]]
	}
	set ftyp $pa($pkfile,$evv(FTYP))
	if {![IsABrkfile $ftyp] && ![IsAListofNumbers $ftyp]} {
		Inf "Use One Frq Brkpnt File And One Corresponding List Peak Levels"
		return
	}
	set ftyp $pa($frqfile,$evv(FTYP))
	if {![IsABrkfile $ftyp] && ![IsAListofNumbers $ftyp]} {
		Inf "Use One Frq Brkpnt File And One Corresponding List Peak Levels"
		return
	}
	if [catch {open $pkfile "r"} zit] {
		Inf "Cannot Open File $pkfile To Read Data"
		return
	}
	set pkdatacnt 0
	while {[gets $zit line] >= 0} {
#FEB 2022
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		} elseif {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				incr pkdatacnt
				lappend pkdata $item
			}
		}
	}
	close $zit
	set frqdatacnt 0
	if [catch {open $frqfile "r"} zit] {
		Inf "Cannot Open File $frqfile To Read Data"
		return
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
#FEB 2022
		if {[string length $line] <= 0} {
			continue
		} elseif {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				incr frqdatacnt
				lappend frqdata $item
			}
		}
	}
	close $zit
	if {$pkdatacnt > $frqdatacnt} {
		set temp	   $pkdatacnt
		set pkdatacnt  $frqdatacnt
		set frqdatacnt $temp

		set pkdata	$frqdata

		set temp	$pkfile
		set pkfile  $frqfile
		set frqfile $temp
	}
	set infiledatalen $pkdatacnt
	if {$frqdatacnt != ($infiledatalen * 4)} {
		Inf "Inappropriate Data Files : Lengths Of Data Do Not Correspond"
		return
	}
	if {![IsABrkfile $pa($frqfile,$evv(FTYP))] || ($pa($frqfile,$evv(MAXBRK)) > [MidiToHz $mu(MIDIMAX)]) || ($pa($frqfile,$evv(MINBRK)) < [MidiToHz $mu(MIDIMIN)])} {
		Inf "Inappropriate Data For A Frequency Brkpnt File"
		return
	}
	if {![IsABrkfile $pa($pkfile,$evv(FTYP))] && ![IsAListofNumbers $pa($pkfile,$evv(FTYP))]} {
		Inf "Inappropriate Data For Peaks"
		return
	}
	set cnt 1
	foreach val $pkdata {
		if {($val > 1.0) || ($val < 0.0)} {
			Inf "Problem With Data In '$fnam' : Level Out Of Range On Line $cnt"
			return
		}
		incr cnt
	}
	set f .fbrktomidi
	if [Dlg_Create $f "CONVERT FREQUENCY DATA" "set pr_fbrktomidi 0" -width 60 -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0]
		set f1 [frame $f.1]
		button $f0.quit -text "Abandon" -command {set pr_fbrktomidi 0} -highlightbackground [option get . background {}]
		button $f0.ok  -text "Convert" -command {set pr_fbrktomidi 1} -highlightbackground [option get . background {}]
		pack $f0.quit -side right
		pack $f0.ok -side left
		pack $f.0 -side top -fill x -expand true
		wm resizable $f 1 1
		bind $f <Return> {set pr_fbrktomidi 1}
		bind $f <Escape> {set pr_fbrktomidi 0}
	}
	raise $f
	update idletasks
	StandardPosition $f
	set finished 0
	set pr_fbrktomidi 0
	My_Grab 0 $f pr_fbrktomidi
	while {!$finished} {
		tkwait variable pr_fbrktomidi
		if {$pr_fbrktomidi} {
			set outfnam [file rootname [file tail $frqfile]]
			append outfnam $evv(MIDI_EXT)
			if {[file exists $outfnam]} {
				set msg "File '$outfnam' Already Exists: Overwrite It ?"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				set i [LstIndx $outfnam $wl]
				if {![DeleteFileFromSystem $outfnam 0 1]} {
					Inf "Cannot Delete Existing File '$outfnam'"
					continue
				} else {
					DummyHistory $outfnam "DESTROYED"
					if {$i >= 0} {
						WkspCnt [$wl get $i] -1
						$wl delete $i
						catch {unset rememd}
					}
				}
			}
			switch -- $tcl_platform(platform) {
				"windows" {	set header 1}
				"unix"	  { set header 0}
			}
			set cmd [file join $evv(CDPROGRAM_DIR) convert_to_midi]
			lappend cmd $frqfile $pkfile $infiledatalen $staccato $outfnam $header
			set prg_dun 0
			set prg_abortd 0
			catch {unset simple_program_messages}
			if [catch {open "|$cmd"} CDPidrun] {
				ErrShow "Cannot Mix Pitchline Sound With Source: $CDPidrun"
				catch {unset CDPidrun}
				continue
			} else {
				fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
			}
			vwait prg_dun
			if {$prg_abortd} {
				set prg_dun 0
			}
			if {!$prg_dun} {
				set msg "Cannot Mix Pitchline Sound With Source: $CDPidrun"
				set msg [AddSimpleMessages $msg]
				ErrShow $msg
				continue
			}
			if {[file exists $outfnam]} {
				Inf "File $outfnam Has Been Created"
				set finished 1
			}
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

#------ Adjust Tempered pitches which have been assigned to specific times in sndfile, on a graphic display, and warp the sndfile.

proc MelodyAdjust {tohf} {
	global wl chlist pa evv madjust_hf mu madjust_origmidi pm_numidilist massign_srate massign_invsrate wstk rememd 
	global massign_dur massign_chans pr_madjust madjust_tag asgrafix prg_dun prg_abortd CDPidrun madjform madjhf symasamps
	global massignsnd massignboth massign_pdatafile massign_sequence massign_fnam simple_program_messages

	catch {unset symasamps(0)}
	if {$tohf} {
		set ilist [$wl curselection]
		if {[llength $ilist] != 2} {
			if {![info exists chlist] || ([llength $chlist] != 2)} {
				Inf "Select One Soundfile And One Harmonic-Field File (List Of Midi Pitches)"
				return
			}
			set massign_fnam [lindex $chlist 0]
			set madjust_hf [lindex $chlist 1]
		} else {
			set massign_fnam [$wl get [lindex $ilist 0]]
			set madjust_hf [$wl get [lindex $ilist 1]]
		}
		if {($pa($massign_fnam,$evv(FTYP)) != $evv(SNDFILE))} {
			if {($pa($madjust_hf,$evv(FTYP)) != $evv(SNDFILE))} {
				Inf "Select One Soundfile And One Harmonic-Field File (List Of Midi Pitches)"
				return
			} else {
				set temp $massign_fnam
				set massign_fnam $madjust_hf
				set madjust_hf $massign_fnam
			}
		}
		if {![IsAListofNumbers $pa($madjust_hf,$evv(FTYP))]} {
			Inf "Data File Must Be A Harmonic-Field File (List Of Midi Pitches)"
			return
		} elseif {($pa($madjust_hf,$evv(MAXNUM)) > $mu(MIDIMAX)) || ($pa($madjust_hf,$evv(MINNUM)) < $mu(MIDIMIN))} {
			Inf "Data File Must Be A Harmonic-Field File (List Of Midi Pitches) : Values Out Of Range"
			return
		}
	} else {
		set i [$wl curselection]
		if {([llength $i] != 1) || ($i == -1)} {
			if {![info exists chlist] || ([llength $chlist] != 1)} {
				Inf "Select One Soundfile"
				return
			}
			set massign_fnam [lindex $chlist 0]
		} else {
			set massign_fnam [$wl get $i]
		}
		if {$pa($massign_fnam,$evv(FTYP)) != $evv(SNDFILE)} {
			Inf "Select A Soundfile"
			return
		}
	}
	set infrqdata [file rootname $massign_fnam]
	append infrqdata $evv(PCH_TAG) [GetTextfileExtension brk]
	if {![file exists $infrqdata]} {
		Inf "Freq Data File ($infrqdata) Does Not Exist For This Sound"
		return
	}
	if [catch {open $infrqdata "r"} zit] {
		Inf "Cannot Open Frqdata File ($infrqdata) To Read Original Pitchline"
		return
	}
	while {[gets $zit line] >= 0} {
		catch {unset nuline}
		set line [string trim $line]
#FEB 2022
		if {[string length $line] <= 0} {
			continue
		} elseif {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		set cnt 0
		foreach item $line {
			if {[string length $item] <= 0} {
				continue
			}
			lappend origfrqbrk $item
		}
	}
	close $zit
	if {![info exists origfrqbrk]} {
		Inf "No Data In File $infrqdata"
		return
	}
	set cnt 0
	if {![IsEven [llength $origfrqbrk]]} {
		Inf "Invalid Data In File $infrqdata"
		return
	}
	foreach {time val} $origfrqbrk {
		if {$cnt == 0} {
			if {![Flteq $time 0.0]} {
				Inf "Times Do Not Start At Zero In File $infrqdata"
				return
			}
		} else {
			if {$time <= $lasttime} {
				Inf "Times Do Not Always Increase In File $infrqdata"
				return
			}
		}
		set lasttime $time
		if {($val > $mu(MAXMFRQ)) || ($val < $mu(MINMFRQ))} {
			Inf "Frequencies Outside Midi Range In File $infrqdata"
			return
		}
		if {[IsEven $cnt]} {
			lappend ontimes $time
		} else {
			if {$val != $lastval} {
				Inf "Frequency Ons And Offs Not Paired Correctly In File $infrqdata"
				return
			}
		}
		set lastval $val
		incr cnt
	}
	if {$tohf} {
		if [catch {open $madjust_hf "r"} zit] {
			Inf "Cannot Open File $madjust_hf To Read Harmonic Field"
			return
		}
		while {[gets $zit line] >= 0} {
			catch {unset nuline}
			set line [string trim $line]
#FEB 2022
			if {[string length $line] <= 0} {
				continue
			} elseif {[string match [string index $line 0] ";"]} {
				continue
			}
			set line [split $line]
			set cnt 0
			foreach item $line {
				if {[string length $item] <= 0} {
					continue
				}
				lappend madjhf [expr int(round($item))]
			}
		}
		close $zit

		foreach hfnote $madjhf {
			while {$hfnote >= 0} {
				incr hfnote -12
			}
			incr hfnote 12			;#	SET TO LOWEST OCTAVE
			lappend hfnotes $hfnote
		}
		set madjhf $hfnotes
	}

	catch {unset madjust_origmidi}
	foreach {time val time2 val2} $origfrqbrk {
		set midi [expr int(round([HzToMidi $val]))]
		lappend madjust_origmidi $midi
	}
	set pm_numidilist $madjust_origmidi
	 
	set massign_srate $pa($massign_fnam,$evv(SRATE))
	set massign_invsrate [expr 1.0 / double($massign_srate)]
	set massign_dur $pa($massign_fnam,$evv(DUR))
	set massign_chans $pa($massign_fnam,$evv(CHANS))

	foreach time $ontimes {
		lappend symasamps(0) [expr int(round($time * double($massign_srate)))]
	}

	set analfnam $evv(DFLT_OUTNAME)
;# 2023, RWD was ANALFILE_EXT
	append analfnam 0 $evv(ANALFILE_OUT_EXT)
	set transfnam $evv(DFLT_OUTNAME)
;# 2023  RWD ditto
	append transfnam 1 $evv(ANALFILE_OUT_EXT)
	set transdata $evv(DFLT_OUTNAME)
	append transdata 0 $evv(TEXT_EXT)

	set massign_pdatafile $evv(DFLT_OUTNAME)
	append massign_pdatafile $evv(TEXT_EXT)	
	set massignsnd $evv(DFLT_OUTNAME)
	append  massignsnd 2 $evv(SNDFILE_EXT)	;#		USED FOR PLAYING THE PITCHDATA
	set massignboth $evv(DFLT_OUTNAME)
	append  massignboth 3 $evv(SNDFILE_EXT)

	DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0

	set f .madjust
	if [Dlg_Create $f "ADJUST PITCHLINE" "set pr_madjust 0" -width 60 -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0]
		set f1 [frame $f.1]
		set f2 [frame $f.2]
		set f3 [frame $f.3]
		button $f0.quit -text "Quit" -command {set pr_madjust 0} -width 10 -highlightbackground [option get . background {}]
		button $f0.ok  -text "Transpose" -command {set pr_madjust 1} -width 10 -highlightbackground [option get . background {}]
		checkbutton $f0.chk -text "Attempt to retain formants " -variable madjform
		button $f0.src -text "Play Src" -command "PlaySndfile $massign_fnam 0" -bg $evv(HELP) -width 10 -highlightbackground [option get . background {}]
		button $f0.pch -text "Play Pitch" -command "PlayAssign 0" -bg $evv(HELP) -width 10 -highlightbackground [option get . background {}]
		if {$massign_chans == 1} {
			button $f0.both -text "Play Both" -command "PlayAssign 1" -bg $evv(HELP) -width 10 -highlightbackground [option get . background {}]
		}
		pack $f0.ok $f0.chk $f0.src $f0.pch -side left -padx 2
		if {$massign_chans == 1} {
			pack $f0.both -side left -padx 2
		}
		pack $f.0 -side top -fill x -expand true
		pack $f0.quit -side right

		label $f.1.ll -text "Adjust pitches by moving notes with mouse" -fg $evv(SPECIAL)
		label $f.1.ll2 -text "Click to move DOWN : Shift-Click to move UP" -fg $evv(SPECIAL)
		pack $f.1.ll $f.1.ll2 -side top
		if {$tohf} {
			button $f.1.hf -text "Impose HF" -command MadjustToHF -highlightbackground [option get . background {}]
			pack $f.1.hf -side top
		}
		pack $f.1 -side top
		label $f.2.ll -text "Output tag (added to end on input filename) "
		entry $f.2.e -textvariable madjust_tag -width 6
		pack $f.2.ll $f.2.e -side left
		pack $f.2 -side top
		button $f.3.reset -text "Reset Display" -command "MadgrafixReset" -highlightbackground [option get . background {}]
		set asgrafix [EstablishMelodyEntryDisplay $f.3]
		pack $f.3.reset -side top -pady 4
		pack $asgrafix -side top -pady 1
		pack $f.3 -side top -fill both -expand true
		wm resizable $f 1 1
		bind $asgrafix <ButtonRelease-1>		{MoveAsgrafixPitch %x %y 0}
		bind $asgrafix <Shift-ButtonRelease-1>	{MoveAsgrafixPitch %x %y 1}
		bind $f <Return> {set pr_madjust 1}
		bind $f <Escape> {set pr_madjust 0}
	}
	wm title $f "ADJUST PITCH OF FILE $massign_fnam"
	MadgrafixDrawNotes
	set madjust_tag ""
	set madjform 1
	raise $f
	update idletasks
	StandardPosition $f
	set finished 0
	set pr_madjust 0
	My_Grab 0 $f pr_madjust $f.2.e
	while {!$finished} {
		tkwait variable pr_madjust
		if {$pr_madjust} {
			if {[string length $madjust_tag] <= 0} {
				Inf "No Filename Tag Entered"
				continue
			}
			set outfnam [file rootname [file tail $massign_fnam]]
			append outfnam "_" $madjust_tag
			if {![ValidCDPRootname $outfnam]} {
				continue
			}
			append outfnam $evv(SNDFILE_EXT)
			if {[file exists $outfnam]} {
				set msg "File '$outfnam' Already Exists: Overwrite It ?"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				set i [LstIndx $outfnam $wl]
				if {![DeleteFileFromSystem $outfnam 0 1]} {
					Inf "Cannot Delete Existing File '$outfnam'"
					continue
				} else {
					DummyHistory $outfnam "DESTROYED"
					if {$i >= 0} {
						WkspCnt [$wl get $i] -1
						$wl delete $i
						catch {unset rememd}
					}
				}
			}
			set adjusted 0
			foreach val $pm_numidilist origval $madjust_origmidi {
				if {$val != $origval} {
					set adjusted 1
					break
				}
			}
			if {!$adjusted } {
				Inf "No New Pitch-Sequence Specified"
				continue
			}
			catch {unset transposs}
			catch {unset nulines}
			foreach val $pm_numidilist {time frq} $origfrqbrk {
				set val [MidiToHz $val]
				set transpos [expr $val / $frq]
				lappend transposs $transpos
			}
			foreach transpos $transposs {time frq time2 frq2} $origfrqbrk {
				set nuline [list $time $transpos]
				lappend nulines $nuline			
				set nuline [list $time2 $transpos]
				lappend nulines $nuline			
			}
			if [catch {open $transdata "w"} zit] {
				Inf "Failed To Open Temporary File To Write Transposition Data"
				continue
			}
			foreach line $nulines {
				puts $zit $line
			}
			close $zit

			Block "PITCH WARPING THE SOUND"

			;#	ANALYSE THE FILE TO BE WARPED

			set cmd [file join $evv(CDPROGRAM_DIR) pvoc]
			lappend cmd anal 1 $massign_fnam $analfnam -c1024 -o3
			set prg_dun 0
			set prg_abortd 0
			catch {unset simple_program_messages}
			if [catch {open "|$cmd"} CDPidrun] {
				ErrShow "Cannot Create Analysis File From [file rootname [file tail $massign_fnam]]: $CDPidrun"
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
				set msg "Cannot Create Analysis File From [file rootname [file tail $massign_fnam]]"
				set msg [AddSimpleMessages $msg]
				ErrShow $msg
				UnBlock
				continue
			}
			if {![file exists $analfnam]} {
				ErrShow "Cannot Create Analysis File From [file rootname [file tail $massign_fnam]]"
				UnBlock
				continue
			}

			;#	DO THE FREQUENCY WARPING

			set cmd [file join $evv(CDPROGRAM_DIR) repitch]
			if {$madjform} {
				lappend cmd transposef 1 $analfnam $transfnam -p4 $transdata -l5 -h22050  
			} else {
				lappend cmd transpose 1 $analfnam $transfnam $transdata -l5 -h22050 
			}
			set prg_dun 0
			set prg_abortd 0
			catch {unset simple_program_messages}
			if [catch {open "|$cmd"} CDPidrun] {
				ErrShow "Failed To Transpose File [file rootname [file tail $massign_fnam]]: $CDPidrun"
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
				set msg "Failed To Transpose File [file rootname [file tail $massign_fnam]]"
				set msg [AddSimpleMessages $msg]
				ErrShow $msg
				UnBlock
				continue
			}
			if {![file exists $transfnam]} {
				ErrShow "Failed To Transpose File [file rootname [file tail $massign_fnam]]"
				UnBlock
				continue
			}
	
			;#	DO THE FINAL RESYNTHESIS

			set cmd [file join $evv(CDPROGRAM_DIR) pvoc]
			lappend cmd synth $transfnam $outfnam
			set prg_dun 0
			set prg_abortd 0
			catch {unset simple_program_messages}
			if [catch {open "|$cmd"} CDPidrun] {
				ErrShow "Failed To Resynth Transposed Analysis File For [file rootname [file tail $massign_fnam]]: $CDPidrun"
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
				set msg "Failed To Resynth Transposed Analysis File For [file rootname [file tail $massign_fnam]]"
				set msg [AddSimpleMessages $msg]
				ErrShow $msg
				UnBlock
				continue
			}
			if {![file exists $outfnam]} {
				ErrShow "Failed To Resynth Transposed Analysis File For [file rootname [file tail $massign_fnam]]"
				UnBlock
				continue
			}
			UnBlock
			FileToWkspace $outfnam 0 0 0 0 1
			Inf "File $outfnam Is On The Workspace"
			DeleteAllTemporaryFilesWhichAreNotCDPOutput except $analfnam
		} else {
			set finished 1
		}
	}
	DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

proc MadgrafixClear {} {
	global asgrafix
	catch {$asgrafix delete notes}
	catch {$asgrafix delete flats}
	catch {$asgrafix delete ledger}
}

proc MadgrafixReset {} {
	global pm_numidilist madjust_origmidi
	MadgrafixClear
	if {![info exists madjust_origmidi]} {
		Inf "Error In Program Logic: No Original Midi List Found"
		return
	}
	set pm_numidilist $madjust_origmidi
	MadgrafixDrawNotes
}

proc MadgrafixDrawNotes {} {
	global pm_numidilist melwidth melstaveleft asgxposs asgleftpos asgnotestep
	set len [llength $pm_numidilist]
	incr len 4
	set asgnotestep [expr int(round(double($melwidth) / double($len)))]	
	set xpos [expr $melstaveleft + ($asgnotestep * 2)]
	set asgleftpos $xpos
	catch {unset asgxposs}
	foreach midival $pm_numidilist {
		InsertAssignPitchGrafix $xpos $midival
		lappend asgxposs $xpos
		incr xpos $asgnotestep
	}
}


#----- Adjust motfi display to be in HF

proc MadjustToHF {} {
	global pm_numidilist madjhf mu

	set n 0
	set changed 0
	set len [llength $pm_numidilist]
	while {$n < $len} {
		set note [lindex $pm_numidilist $n]
		set mindiff 1000000
		foreach hfnote $madjhf {
			while {$hfnote <= $mu(MIDIMAX)} {
				set diff [expr abs($note - $hfnote)]
				if {$diff < $mindiff} {
					set mindiff $diff
					set closest $hfnote
				}
				incr hfnote 12
			}
		}
		if {$note != $closest} {
			set changed 1
			set pm_numidilist [lreplace $pm_numidilist $n $n $closest]
		}
		incr n
	}
	if {!$changed} {
		Inf "Motif Is Already In The Harmonic Field"
		return
	}
	MadgrafixClear	
	MadgrafixDrawNotes
}

#------ Mark point closest to place where mouse shift-clicks on inner-canvas

proc MoveAsgrafixPitch {x y up} {
	global asg asgrafix asgxposs asgleftpos asgnotestep pm_numidilist evv
	set mindist 1000000
	set displaylist [$asgrafix find withtag notes]		;#	List all objects which are notes
	foreach obj $displaylist {							;#	For each point
		set coords [$asgrafix coords $obj]				;#	Only x-coord needed: can't have time-simultaneous points
		set objx [expr round([lindex $coords 0])]		;#	Only x-coord needed: can't have time-simultaneous points
		set objy [expr round([lindex $coords 1])]		;#	Only x-coord needed: can't have time-simultaneous points
		set thisdist [expr abs($x - $objx)]
		if {$thisdist < $mindist} {
			set xpos $objx
			set ypos $objy
			set mindist $thisdist
			set closest_obj $obj
		}
	}
	if {![info exists xpos]} {
		return
	}
	set isflat 0
	set thetags [$asgrafix gettags $closest_obj]
	if {[lsearch $thetags "flat"] >= 0} {
		set isflat 1
	}
	set midival [MadjGetMidiFromYcoord $ypos $isflat]
	set listpos [lsearch $asgxposs $xpos]
	set midival [lindex $pm_numidilist $listpos]
	if {$up} {
		if {$midival < 84} {
			incr midival 
		}
	} else {	
		if {$midival > 36} {
			incr midival -1
		}
	}
	set pm_numidilist [lreplace $pm_numidilist $listpos $listpos $midival]
	MadgrafixClear
	MadgrafixDrawNotes
}

#----- Draw note on assign-pitch-data graphics display

proc MadjGetMidiFromYcoord {y isflat} {
	switch -- $y {	
		17 { set midi 84 }
		22 {	
			if {$isflat} { 
				set midi 82 
			} else { 
				set midi 83 
			}
		}
		27 {
			if {$isflat} { 
				set midi 80 
			} else { 
				set midi 81 
			}
		}
		32 {
			if {$isflat} { 
				set midi 78 
			}  else { 
				set midi 79 
			}
		}
		37 { set midi 77 }
		42 {
			if {$isflat} { 
				set midi 75 
			}  else { 
				set midi 76 
			}
		}
		47 {
			if {$isflat} { 
				set midi 73 
			}  else { 
				set midi 74 
			}
		}
		52 { set midi 72 }
		57 {
			if {$isflat} { 
				set midi 70 
			}  else { 
				set midi 71 
			}
		}
		62 {
			if {$isflat} { 
				set midi 68 
			}  else { 
				set midi 69 
			}
		}
		67 {
			if {$isflat} { 
				set midi 66 
			}  else { 
				set midi 67 
			}
		}
		72 { set midi 65 }
		77 {
			if {$isflat} { 
				set midi 63 
			}  else { 
				set midi 64 
			}
		}
		82 {
			if {$isflat} { 
				set midi 61 
			}  else { 
				set midi 62 
			}
		}
		87 { set midi 60 }
		92 {
			if {$isflat} { 
				set midi 58 
			}  else { 
				set midi 59 
			}
		}
		97 {
			if {$isflat} { 
				set midi 56 
			}  else { 
				set midi 57 
			}
		}
		102 {
			if {$isflat} { 
				set midi 54 
			}  else { 
				set midi 55 
			}
		}
		107 { set midi 53 }
		112 {
			if {$isflat} { 
				set midi 51 
			}  else { 
				set midi 52 
			}
		}
		117 {
			if {$isflat} { 
				set midi 49 
			}  else { 
				set midi 50 
			}
		}
		122 { set midi 48 }
		127 {
			if {$isflat} { 
				set midi 46 
			}  else { 
				set midi 47 
			}
		}
		132 {
			if {$isflat} { 
				set midi 44 
			}  else { 
				set midi 45 
			}
		}
		137 {
			if {$isflat} { 
				set midi 42 
			}  else { 
				set midi 43 
			}
		}
		142 { set midi 41 }
		147 {
			if {$isflat} { 
				set midi 39 
			}  else { 
				set midi 40 
			}
		}
		152 {
			if {$isflat} { 
				set midi 37 
			}  else { 
				set midi 38 
			}
		}
		157	{ set midi 36 }
	}
	return $midi
}

#------ Convert Motif MIDI-Pitch data into HF representation

proc CreateTempHFData {midilist} {
	set nuhf {}
	foreach {time val} $midilist {
		if {[lsearch $nuhf $val] < 0} {
			lappend nuhf $val
		}
	}
	set len [llength $nuhf]
	if {$len <= 0} {
		return ""
	}
	set nuhf [lsort -integer -increasing $nuhf]
	set minval [lindex $nuhf 0]
	while {$minval < 53} {
		incr minval 12
	}
	set nuhf [lreplace $nuhf 0 0 $minval]
	set n 1
	set lastval $minval
	while {$n < $len} {
		set thisval [lindex $nuhf $n]
		while {$thisval < $lastval} {
			incr thisval 12
		}
		set nuhf [lreplace $nuhf $n $n $thisval]
		set lastval $thisval
		incr n
	}
	set outstr ""
	foreach val $nuhf {
		switch -- $val {
			53 { set outval F }
			54 { set outval F# }
			55 { set outval G }
			56 { set outval G# }
			57 { set outval A }
			58 { set outval A# }
			59 { set outval B }
			60 { set outval C }
			61 { set outval C# }
			62 { set outval D }
			63 { set outval D# }
			64 { set outval E }
			65 { set outval F }
			66 { set outval F# }
			67 { set outval G }
			68 { set outval G# }
			69 { set outval A }
			70 { set outval A# }
			71 { set outval B }
			72 { set outval C }
			73 { set outval C# }
			74 { set outval D }
			75 { set outval D# }
			76 { set outval E }
			77 { set outval F }
			78 { set outval F# }
			79 { set outval G }
			80 { set outval G# }
			81 { set outval A }
			82 { set outval A# }
			83 { set outval B }
			84 { set outval C }
			85 { set outval C# }
			86 { set outval D }
			87 { set outval D# }
			88 { set outval E }
		}
		append outstr $outval
	}
	return $outstr
}

#--- Play an Existing propsfile Motif

proc PlayExistingPropMotif {srate dur both} {
	global massign_fnam prg_dun prg_abortd CDPidrun simple_program_messages tp_propnames tp_props_list pa evv
	set sndbasnam [file rootname [file tail $massign_fnam]]
	set outname "__snd_"
	set outname2 "__snd_both_"
	append outname $sndbasnam $evv(SNDFILE_EXT)
	append outname2 $sndbasnam $evv(SNDFILE_EXT)
	set silfil $evv(DFLT_OUTNAME)
	append silfil 0 $evv(SNDFILE_EXT)
	set tempfil $evv(DFLT_OUTNAME)
	append tempfil 1 $evv(SNDFILE_EXT)
	set datafnam [file rootname $massign_fnam]
	append datafnam $evv(PCH_TAG) [GetTextfileExtension brk]
	if {![file exists $outname]} {
		if {![file exists $datafnam]} {
			Inf "Cannot Find Pitchdata File '$datafnam'"
			return
		}
		set cmd [file join $evv(CDPROGRAM_DIR) synth]
		lappend cmd wave 1 $outname $srate 1 $dur $datafnam -a0.25 -t256 
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		if [catch {open "|$cmd"} CDPidrun] {
			ErrShow "Cannot Synthesize The Pitchline: $CDPidrun"
			catch {unset CDPidrun}
			return
		} else {
			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			set msg "Cannot Synthesize The Pitchline"
			set msg [AddSimpleMessages $msg]
			ErrShow $msg
			return
		}
	}
	if {$both} {
		if {![file exists $outname2]} {
			set k [lsearch $tp_propnames "offset"]
			if {$k >= 0} {
				incr k
				foreach line $tp_props_list {
					if {[string match [lindex $line 0] $massign_fnam]} {
						set offset [lindex $line $k]
						if {![IsNumeric $offset] || ($offset < 0.0)} {
							Inf "Invalid Offset Value ($offset) Found In Properties"
							unset offset
						}
						break
					}
				}
			}
			if [info exists offset] {
				set srate $pa($massign_fnam,$evv(SRATE))
				set cmd [file join $evv(CDPROGRAM_DIR) synth]
				lappend cmd silence $silfil $srate 1 $offset
				set prg_dun 0
				set prg_abortd 0
				catch {unset simple_program_messages}
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "Cannot Create Silence For Offset"
					catch {unset CDPidrun}
					unset offset					
				} else {
					fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
					vwait prg_dun
					if {$prg_abortd} {
						set prg_dun 0
					}
					if {!$prg_dun} {
						Inf "Cannot Create Silence For Offset"
						unset offset					
					}
				}
			}
			if [info exists offset] {
				set cmd [file join $evv(CDPROGRAM_DIR) sfedit]
				lappend cmd join $silfil $outname $tempfil -w0
				set prg_dun 0
				set prg_abortd 0
				catch {unset simple_program_messages}
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "Cannot Create Time-Offset For Pitchline File"
					catch {unset CDPidrun}
					unset offset					
				} else {
					fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
					vwait prg_dun
					if {$prg_abortd} {
						set prg_dun 0
					}
					if {!$prg_dun} {
						Inf "Cannot Create Time-Offset For Pitchline File"
						catch {file delete $tempfil}
						unset offset					
					}
				}
			}
			catch {file delete $silfil}
			set cmd [file join $evv(CDPROGRAM_DIR) submix]
			if [info exists offset] { 
				lappend cmd interleave $tempfil $massign_fnam $outname2
			} else {
				lappend cmd interleave $outname $massign_fnam $outname2
			}
			set prg_dun 0
			set prg_abortd 0
			catch {unset simple_program_messages}
			if [catch {open "|$cmd"} CDPidrun] {
				ErrShow "Cannot Mix Source And Pitchline: $CDPidrun"
				catch {unset CDPidrun}
				return
			} else {
				fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
			}
			vwait prg_dun
			if {$prg_abortd} {
				set prg_dun 0
			}
			if {[file exists $tempfil]} {
				catch {file delete $tempfil}
			}
			if {!$prg_dun} {
				set msg "Cannot Mix Source And Pitchline"
				set msg [AddSimpleMessages $msg]
				ErrShow $msg
				return
			}
		}
	}
	if {$both} {
		PlaySndfile $outname2 0
	} else {
		PlaySndfile $outname 0
	}
}

proc PlaySampleWithNormalisedMidiSeq {} {
	global pr_nseq nseq_midi nseq_fnam nseq_trim nseq_attn prg_dun prg_abortd CDPidrun readonlyfg readonlybg chlist wl pa wstk evv
	global blist_change background_listing rememd

	if {![info exists chlist] || ([llength $chlist] != 2)} {
		set ilist [$wl curselection]
		if {[llength $ilist] != 2} {
			Inf "Select A Soundfile And A Sequence File"
			return
		}
		set sndfnam [$wl get [lindex $ilist 0]]
		set seqfnam [$wl get [lindex $ilist 1]]
	} else {
		set sndfnam [lindex $chlist 0]
		set seqfnam [lindex $chlist 1]
	}
	if {$pa($sndfnam,$evv(FTYP)) != $evv(SNDFILE)} {
		set temp $sndfnam
		set sndfnam $seqfnam
		set seqfnam $temp
		if {$pa($sndfnam,$evv(FTYP)) != $evv(SNDFILE)} {
			Inf "Select A Soundfile And A Sequence File"
			return
		}
	}
	if [catch {open $seqfnam "r"} zit] {
		Inf "Cannot Open '$seqfnam' To Read Sequence Data"
		return
	}
	set lasttime -1
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
#FEB 2022
		if {[string length $line] <= 0} {
			continue
		} elseif {[string match [string index $line 0] ";"]} {
			continue
		}
		catch {unset nuline}
		set line [split $line]
		set cnt 0
		foreach item $line {
			if {[string length $item] <= 0} {
				continue
			}
			switch -- $cnt {
				0	{
					if {![IsNumeric $item] || ($item < 0.0) || ($item <= $lasttime)} {
						Inf "Invalid Time In Sequence File"	
						close $zit
						return
					}
					set lasttime $item
				}
				1 {
					if {![IsNumeric $item] || ![regexp {^[0-9\-]+$} $item] || ($item > 127) || ($item < -127)} {
						Inf "Invalid Transposition In Sequence File"	
						close $zit
						return
					}
				}
				2 {
					if {![IsNumeric $item] || ($item > 1.0) || ($item < $evv(FLTERR))} {
						Inf "Invalid Loudness In Sequence File"	
						close $zit
						return
					}
				}
			}
			lappend nuline $item
			incr cnt
		}
		if {$cnt != 3} {
			Inf "Invalid Data In Sequence File"
			close $zit
			return
		}
		lappend origseq $nuline
	}
	close $zit
	set sampdur $pa($sndfnam,$evv(DUR))
	set chans $pa($sndfnam,$evv(CHANS))
	set canplayorig 0
	set k [string first $evv(SEQ_TAG) $seqfnam]
	if {$k > 0} {
		incr k -1
		set origofseq [string range [file rootname $seqfnam] 0 $k]
		append origofseq $evv(SNDFILE_EXT)
		if {[file exists $origofseq]} {
			set canplayorig 1
		} 
	}
	set f .nseq
	if [Dlg_Create $f "GENERATE SEQUENCE FROM SAMPLE" "set pr_nseq 0" -width 60 -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0]
		set f1 [frame $f.1]
		set f2 [frame $f.2]
		set f4 [frame $f.4]
		button $f0.quit -text "Abandon" -command {set pr_nseq 0} -highlightbackground [option get . background {}]
		button $f0.ok  -text "Generate" -command {set pr_nseq 1} -highlightbackground [option get . background {}]
		button $f0.playi -text "Play Input" -command "PlaySndfile $sndfnam 0" -bg $evv(HELP) -width 11 -highlightbackground [option get . background {}]
		button $f0.playa -text "C" -command "PlaySndfile $evv(TESTFILE_C) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
		pack $f0.quit -side right
		pack $f0.ok $f0.playi $f0.playa -side left
		if {$canplayorig} {
			button $f0.plays -text "Play Sequence Src" -command "PlaySndfile $origofseq 0" -bg $evv(HELP) -width 17 -highlightbackground [option get . background {}]
			pack $f0.plays -side left -padx 10
		}
		pack $f.0 -side top -fill x -expand true
		button $f1.playo -text "Play Output" -command {set pr_nseq 2} -bg $evv(HELP) -width 11 -highlightbackground [option get . background {}]
		button $f1.save  -text "Save Output" -command {set pr_nseq 3} -highlightbackground [option get . background {}]
		pack $f1.save -side right
		pack $f1.playo -side left
		pack $f.1 -side top -fill x -expand true -pady 2
		label $f2.ll -text "Midi pitch of sample (Up/Dn arrow keys)"
		entry $f2.mid -textvariable nseq_midi -width 6 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $f2.ll2 -text "Attenuation (Left/Right arrow keys)"
		entry $f2.att -textvariable nseq_attn -width 4 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $f2.ll $f2.mid $f2.ll2 $f2.att -side left -padx 2
		pack $f.2 -side top -pady 2
		checkbutton $f.3 -text "Truncate sample-durs to note-separation" -variable nseq_trim
		pack $f.3 -side top -pady 2 -fill x -expand true
		label $f4.ll -text "Outfile Name"
		entry $f4.fnam -textvariable nseq_fnam -width 16
		pack $f4.ll $f4.fnam -side left
		pack $f.4 -side top -pady 2
		wm resizable $f 1 1
		bind $f <Up> {NseqMidi 0}
		bind $f <Down> {NseqMidi 1}
		bind $f <Right> {NseqAtt 0}
		bind $f <Left> {NseqAtt 1}
		bind $f <Return> {set pr_nseq 1}
		bind $f <Escape> {set pr_nseq 0}
	}
	set nseq_midi 60.0
	set nseq_attn 1.0
	set nseq_trim 0
	raise $f
	update idletasks
	StandardPosition $f
	set finished 0
	set pr_nseq 0
	My_Grab 0 $f pr_nseq
	set seqofnam $evv(DFLT_OUTNAME)
	append seqofnam 0 $evv(SNDFILE_EXT)
	set seqtempfnam $evv(DFLT_OUTNAME)
	append seqtempfnam 0 $evv(TEXT_EXT)
	set mixfnam $evv(DFLT_OUTNAME)
	append mixfnam 1 $evv(TEXT_EXT)
	while {!$finished} {
		tkwait variable pr_nseq
		switch -- $pr_nseq {
			0 {
				set finished 1
			}
			1 {
				DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
				set dotrim 0
				catch {unset outseq}
				catch {unset trimsamps}
				set cnt 0
				foreach line $origseq {
					set transp [lindex $line 1]
					set transp [expr $transp + (60.0 - $nseq_midi)]
					set line [lreplace $line 1 1 $transp]
					lappend outseq $line
					if {$nseq_trim} {
						set time [lindex $line 0]
						set transp [lindex $line 1]
						set tratio [expr $transp/12.0]
						set tratio [expr pow(2.0,$tratio)]
						if {$cnt > 0} {
							set step [expr $time - $lasttime]
							set outdur [expr $sampdur / $last_tratio]
							if {$step < $outdur} {
								set dotrim 1
								lappend trimsamps $step
							} else {
								lappend trimsamps 0
							}
						}
						set last_tratio $tratio
						set lasttime $time
					}
					incr cnt
				}
				if {$dotrim} {
					lappend trimsamps 0
					catch {unset mixlines}
					Block "Generating Truncated Samples"
					set k 0
					foreach line $outseq dur $trimsamps {
						set time [lindex $line 0]
						set transp [lindex $line 1]
						set amp [lindex $line 2]
						set outsnd [GenerateTruncatedSample $sndfnam $k $transp $dur]
						if {[string length $outsnd] <= 0} {
							DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
							UnBlock
							continue
						}
						incr k
						set line $outsnd
						append line " " $time " " $chans " " [expr $nseq_attn * $amp]
						if {$chans > 1} {
							append line " " C
						}
						lappend mixlines $line
					}
					UnBlock
					if [catch {open $mixfnam "w"} zit] {
						Inf "Cannot Open File '$mixfnam' For Sequence With Truncated Samples"	
						DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
						continue
					}
					foreach line $mixlines {
						puts $zit $line
					}
					close $zit		
					set cmd [file join $evv(CDPROGRAM_DIR) submix]
					lappend cmd mix $mixfnam $seqofnam
				} else {
					set cmd [file join $evv(CDPROGRAM_DIR) extend]
					if {$nseq_midi == 60.0} {
						lappend cmd sequence $sndfnam $seqofnam $seqfnam $nseq_attn
					} else {
						if [catch {open $seqtempfnam "w"} zit] {
							Inf "Cannot Open Temporary File '$seqtempfnam' To Write New Sequence Data"
							continue
						}
						foreach line $outseq {
							puts $zit $line
						}
						close $zit
						lappend cmd sequence $sndfnam $seqofnam $seqtempfnam $nseq_attn 
					}
				}
				set prg_dun 0
				set prg_abortd 0
				catch {unset simple_program_messages}
				if [catch {open "|$cmd"} CDPidrun] {
					ErrShow "Cannot Generate The Sequence: $CDPidrun"
					catch {unset CDPidrun}
					continue
				} else {
					fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				if {!$prg_dun} {
					set msg "Cannot Generate The Sequence"
					set msg [AddSimpleMessages $msg]
					ErrShow $msg
					continue
				}
				Inf "Sequence Generated"
			}
			2 {
				if {![file exists $seqofnam]} {
					Inf "No Output File To Play"
					continue
				}
				PlaySndfile $seqofnam 0
			}
			3 {
				if {[string length $nseq_fnam] <= 0} {
					Inf "No Output Filename Entered"
					continue
				}
				if {![ValidCDPRootname $nseq_fnam]} {
					continue
				}
				set outfnam $nseq_fnam
				append outfnam $evv(SNDFILE_EXT)
				if {[file exists $outfnam]} {
					set msg "File '$outfnam' Already Exists: Overwrite It ?"
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					} else {
						set i [LstIndx $outfnam $wl]
						set blist_change 0
						if {![DeleteFileFromSystem $outfnam 0 1]} {
							Inf "Cannot Delete Existing File '$outfnam'"
							continue
						} else {
							DummyHistory $outfnam "DESTROYED"
							if {[IsInAMixfile $outfnam]} {
								if {[MixM_ManagedDeletion $outfnam]} {
									MixMStore
								}
							}
							if {$blist_change} {
								SaveBL $background_listing
							}
							if {$i >= 0} {
								WkspCnt [$wl get $i] -1
								$wl delete $i
								catch {unset rememd}
							}
						}
					}
				}
				if [catch {file rename $seqofnam $outfnam} zit] {
					Inf "Cannot Rename The Output File"
					continue
				}
				if {[FileToWkspace $outfnam 0 0 0 0 1] > 0 } {
					Inf "File '$outfnam' Is On The Workspace"
				} else {
					Inf "File '$outfnam' Has Been Created"
				}
				set finished 1
			}
		}
	}
	DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
} 

proc NseqMidi {down} {
	global nseq_midi
	if {$down} {
		if {$nseq_midi <= 0} {
			return
		}
		set nseq_midi [DecPlaces [expr $nseq_midi - 0.5] 1]
	} else {
		if {$nseq_midi >= 127} {
			return
		}
		set nseq_midi [DecPlaces [expr $nseq_midi + 0.5] 1]
	}
}

proc NseqAtt {down} {
	global nseq_attn
	if {$down} {
		if {$nseq_attn <= 0} {
			return
		}
		set nseq_attn [expr $nseq_attn - 0.01]
	} else {
		if {$nseq_attn >= 1.0} {
			return
		}
		set nseq_attn [expr $nseq_attn + 0.01]
	}
}

proc GenerateTruncatedSample {infnam k transp dur} {
	global prg_dun prg_abortd CDPidrun evv
	set outfnam2 $evv(MACH_OUTFNAME)
	append outfnam2 $evv(SNDFILE_EXT)
	set outfnam $evv(MACH_OUTFNAME)
	append outfnam $k $evv(SNDFILE_EXT)
	if {$dur > 0} {
		set thisoutfnam $outfnam2
	} else {
		set thisoutfnam $outfnam
	}
	if {[file exists $thisoutfnam]} {
		if [catch {file delete $thisoutfnam} zit] {
			Inf "Cannot Delete Existing Temporary File '$thisoutfnam'"
			return ""
		}
	}
	set cmd [file join $evv(CDPROGRAM_DIR) modify]
	lappend cmd speed 2 $infnam $thisoutfnam $transp
	set prg_dun 0
	set prg_abortd 0
	catch {unset simple_program_messages}
	if [catch {open "|$cmd"} CDPidrun] {
		ErrShow "Cannot Generate Transposed Source [expr $k + 1]: $CDPidrun"
		catch {unset CDPidrun}
		return ""
	} else {
		fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
	}
	vwait prg_dun
	if {$prg_abortd} {
		set prg_dun 0
	}
	if {!$prg_dun} {
		set msg "Cannot Generate Transposed Source [expr $k + 1]"
		set msg [AddSimpleMessages $msg]
		ErrShow $msg
		return ""
	}
	if {$dur > 0} {
		if {[file exists $outfnam]} {
			if [catch {file delete $outfnam} zit] {
				Inf "Cannot Delete Existing Temporary File '$outfnam'"
				return ""
			}
		}
		set cmd [file join $evv(CDPROGRAM_DIR) sfedit]
		lappend cmd cut 1 $thisoutfnam $outfnam 0 $dur
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		if [catch {open "|$cmd"} CDPidrun] {
			ErrShow "Cannot Cut Truncated Source [expr $k + 1]: $CDPidrun"
			catch {unset CDPidrun}
			return ""
		} else {
			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			set msg "Cannot Cut Truncated Source [expr $k + 1]"
			set msg [AddSimpleMessages $msg]
			ErrShow $msg
			return ""
		}
	}
	return $outfnam
}

#------ Get average of time-changing filters

proc PollOfFilters {durwise} {
	global chlist wl rememd wstk pa evv pr_pollfilts pollfnam
#  RWD NB in 17.0.6 - new code here

	if {![info exists chlist] || ([llength $chlist] < 1)} {
		set ilist [$wl curselection]
		if {([llength $ilist] < 1) || ($ilist == -1)} {
			Inf "Select At Least One Midi Filter Data File (Only The First Pitch In Each Line Will Be Used)"
			return
		}
		set n 0
		foreach i $ilist {
			set fnam($n) [$wl get $i]
			incr n
		}
	} else {
		set n 0
		foreach ffnam $chlist {
			set fnam($n) $ffnam
			incr n
		}
	}
	set fcnt $n
	set n 0
	set tottime -1
	while {$n < $fcnt} {
		if {!($pa($fnam($n),$evv(FTYP)) & $evv(IS_A_TEXTFILE))}  {
			Inf "Not All Selected Files Are Textfiles"
			return
		}
		if [catch {open $fnam($n) "r"} zit] {
			Inf "Cannot Open File '$fnam($n)' To Read Data"
			return
		}
		set lasttime -1
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
#FEB 2022
			if {[string length $line] <= 0} {
				continue
			} elseif {[string match [string index $line 0] ";"]} {
				continue
			}
			set line [split $line]
			set cnt 0
			foreach item $line {
				if {[string length $item] <= 0} {
					continue
				}
				switch -- $cnt {
					0	{
						if {![IsNumeric $item] || ($item < 0.0) || ($item <= $lasttime)} {
							Inf "Invalid Time ($item) In Midi Filter File"	
							close $zit
							return
						}
						if {$durwise} {
							if {$cnt == 0} {
								set dur $item
							} else {
								set dur [expr $item - $lasttime]
							}
						}
						set lasttime $item
					}
					1 {
						if {![IsNumeric $item] || ($item > 127) || ($item < 0)} {
							Inf "Invalid Midival ($item) In Midi Filter File"	
							close $zit
							return
						}
						if {$durwise} {
							if {[info exists poll($item)]} {
								set poll($item) [expr $poll($item) + $dur]
							} else {
								set poll($item) $dur
							}
						} else {
							if {[info exists poll($item)]} {
								incr poll($item)
							} else {
								set poll($item) 1
							}
						}
					}
				}
				incr cnt
				if {$cnt >= 2} {
					break
				}
			}
			if {$cnt != 2} {
				Inf "Invalid Midival In Midi Filter File"	
				close $zit
				return
			}
		}
		close $zit
		if {$lasttime > $tottime} {
			set tottime $lasttime
		}
		incr n
	}
	set pollmax -1
	foreach name [array names poll] {
		if {$poll($name) > $pollmax} {
			set pollmax $poll($name)
		}
	}
	if {$pollmax <= 0.0} {
		Inf "Invalid Midival In Midi Filter File"	
		close $zit
		return
	}
	set nuline 0
	foreach name [array names poll] {
		lappend nuline $name [expr double($poll($name))/double($pollmax)]
	}
	lappend nulines $nuline
	set nuline [lreplace $nuline 0 0 $tottime]
	lappend nulines $nuline
	set f .pollfilts
	if [Dlg_Create $f "POLL FILTERS" "set pr_pollfilts 0" -width 60 -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0]
		set f1 [frame $f.1]
		button $f0.quit -text "Abandon" -command {set pr_pollfilts 0} -highlightbackground [option get . background {}]
		button $f0.ok  -text "Generate" -command {set pr_pollfilts 1} -highlightbackground [option get . background {}]
		pack $f0.quit -side right
		pack $f0.ok -side left
		label $f1.ll -text "Output filter filename "
		entry $f1.e -textvariable pollfnam -width 24
		pack $f1.ll $f1.e -side left
		pack $f.0 $f.1 -side top -fill x -expand true -padx 2 -pady 2
		wm resizable $f 1 1
		bind $f <Return> {set pr_pollfilts 1}
		bind $f <Escape> {set pr_pollfilts 0}
	}
	if {$fcnt == 1} {
		set pollfnam $fnam(0)		;#	If polling a single file, use its name as a default basis-name for output file
	}
	raise $f
	update idletasks
	StandardPosition $f
	set finished 0
	set pr_pollfilts 0
	My_Grab 0 $f pr_pollfilts
	while {!$finished} {
		tkwait variable pr_pollfilts
		if {$pr_pollfilts} {
			if {[string length $pollfnam] <= 0} {
				Inf "No Output Filename Entered"
				continue
			}
			if {![ValidCDPRootname $pollfnam]} {
				continue
			}
			set outfnam $pollfnam
			append outfnam $evv(TEXT_EXT)
			if {[file exists $outfnam]} {
				set msg "File '$outfnam' Already Exists: Overwrite It ?"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				} else {
					set i [LstIndx $outfnam $wl]
					if {![DeleteFileFromSystem $outfnam 0 1]} {
						Inf "Cannot Delete Existing File '$outfnam'"
						continue
					} else {
						DummyHistory $outfnam "DESTROYED"
						if {$i >= 0} {
							WkspCnt [$wl get $i] -1
							$wl delete $i
							catch {unset rememd}
						}
					}
				}
			}
			if [catch {open $outfnam "w"} zit] {
				Inf "Cannot Open Output File"
				continue
			}
			foreach line $nulines {
				puts $zit $line
			}
			close $zit
			if {[FileToWkspace $outfnam 0 0 0 0 1] > 0 } {
				Inf "File '$outfnam' Is On The Workspace"
			} else {
				Inf "File '$outfnam' Has Been Created"
			}
			set finished 1
		} else {
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

########################

#------ Divide pitch-following filter into set of filters on each note
#------ Divide sound into corresponding segments
#------ Create batchfile to filterbeach segment with its own pitch, then remix filtered segs
#------ in originsl ordrrt and timing.

proc FilterDivideByPitch {} {
	global pr_filtdbp filtdbp_q filtdbp_g filtdbp_t filtdbp_h wl chlist evv pa wstk rememd filtdbp_outfnam

	set splicelen 0.015
	if {![info exists chlist] || ([llength $chlist] != 2)} {
		set ilist [$wl curselection]
		if {[llength $ilist] != 2} {
			Inf "Select A Mono Soundfile And A Time-Varying Midi Varibank Filter."
			return
		}
		set fnam  [$wl get [lindex $ilist 0]]
		set ffnam [$wl get [lindex $ilist 1]]
	} else {
		set fnam  [lindex $chlist 0]
		set ffnam [lindex $chlist 1]
	}
	if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
		set temp $ffnam
		set ffnam $fnam
		set fnam $temp
		if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
			Inf "Select A Mono Soundfile And A Time-Varying Midi Varibank Filter."
			return
		}
	}
	if {!($pa($ffnam,$evv(FTYP)) & $evv(IS_A_NUMBER_LINELIST))} {
			Inf "Select A Mono Soundfile And A Time-Varying Midi Varibank Filter."
		return
	}
	set dur $pa($fnam,$evv(DUR))

	;#	READ FILTER DATA -> filt

	if [catch {open $ffnam "r"} zit] {
		Inf "Cannot Open Filter Data File ($ffnam)"
		return
	}
	set lastime -1.0
	set ccnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		} elseif {[string match ";" [string index $line 0]]} {
			continue
		}
		set line [split $line]
		catch {unset nuline}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend nuline $item
			}
		}
		if {![info exists nuline]} {
			continue
		}
		set len [llength $nuline]
		if {($len < 3) || [IsEven $len]} {
			Inf "Inappropriate Filter Data For This Procedure\n($line)"
			close $zit
			return
		}
		if {$ccnt == 0} {
			set lcnt $len
		} else {
			if {$len != $lcnt} {
				Inf "Inappropriate Data File For This Procedure\n($line)"
				close $zit
				return
			}
		}
		set time [lindex $line 0]
		if {($time < 0.0) || ($time <= $lastime)} {
			Inf "Invalid Time Value\n($line)"
			close $zit
			return
		}
		set out_line $time
		foreach {midi levl} [lrange $line 1 end] {
			if {($midi < 0) || ($midi > 127)} {
				Inf "Invalid Midi Value\n($line)"
				close $zit
				return
			}
			if {![IsNumeric $levl] || ($levl < 0.0)} {
				Inf "Invalid Level Value\n($line)"
				close $zit
				return
			}
			lappend out_line $midi $levl
		}
		lappend filt $out_line
		set lastime $time
		incr ccnt
	}
	close $zit
	if {![info exists filt] || ([llength $filt] < 2)} {
		Inf "No Time-Changing Filter Data Found"
		return
	}
	set midicnt [expr ($lcnt - 1)/2]
	set n 0
	while {$n < $midicnt} {
		lappend lastmidiset -1
		incr n
	}
	set n 0
	set time 0.0
	foreach line $filt {
		catch {unset midiset}
		foreach {val levl} [lrange $line 1 end] {
			lappend thismidiset $val
		}
		foreach thismidi $thismidiset lastmidi $lastmidiset {
			if {$thismidi != $lastmidi} {
				lappend cuttimes [lindex $line 0]
				set line [lreplace $line 0 0 0.0]
				lappend outfilt($n) $line 
				set line [lreplace $line 0 0 100.0]
				lappend outfilt($n) $line 
				set lastmidiset $thismidiset
				incr n
				break
			}
		}
	}
	set outfilecnt $n
	if {$outfilecnt < 2} {
		Inf "Filter Data Does Not Change Through Time"
		return
	}
	set endtime [lindex $cuttimes end]
	if {[expr $endtime + $splicelen] < $dur} {
		lappend cuttimes $dur
	} else {
		set cuttimes [lreplace $cuttimes end end $dur]
		incr outfilecnt -1
	}
	set cuttimes [lreplace $cuttimes 0 0 0.0]
	set len [llength $cuttimes]
	set m 0
	set n 1
	while {$n < $len} {
		set line [list [lindex $cuttimes $m] [lindex $cuttimes $n]]
		lappend nulines $line
		incr n
		incr m
	}
	if {[llength $nulines] != $outfilecnt} {
		Inf "Error In File Accounting"
		return
	}
	set cuttimes $nulines
	set outnam [file rootname [file tail $fnam]]
	set n 0
	while {$n < $outfilecnt} {
		set outnamseg($n) $outnam
		append outnamseg($n) "_" $n "_env" $evv(SNDFILE_EXT)
		if [file exists $outnamseg($n)] {
			lappend badfiles $outnamseg($n)
		}
		lappend outfileslist $outnamseg($n)
		set outnamflt($n) $outnam
		append outnamflt($n) "_" $n "_flt" $evv(TEXT_EXT)
		if [file exists $outnamflt($n)] {
			lappend badfiles $outnamflt($n)
		}
		lappend outfileslist $outnamflt($n)
		set outnamfltsnd($n) $outnam
		append outnamfltsnd($n) "_seg_" $n "_flt" $evv(SNDFILE_EXT)
		if [file exists $outnamfltsnd($n)] {
			lappend badfiles $outnamfltsnd($n)
		}
		lappend outfileslist $outnamfltsnd($n)
		incr n
	}
	set outnammix $outnam
	append outnammix "_fltmix" [GetTextfileExtension mix]
	if [file exists $outnammix] {
		lappend badfiles $outnammix
	}
	lappend outfileslist $outnammix
	set outnambat $outnam
	append outnambat "_fltmix.bat"
	if [file exists $outnambat] {
		lappend badfiles $outnambat
	}
	lappend outfileslist $outnambat
	if {[info exists badfiles]} {
		set msg "The Following Files (Which Will Be Generated By This Process) Already Exist\n"
		set cnt 0
		foreach bf $badfiles {
			append msg "$bf\n"
			incr cnt
			if {$cnt >= 20} {
				append msg "AND MORE\n"
				break
			}
		}
		append msg "\nTo Proceed You Must Delete All Of These ..... Delete ??"
		set choice [tk_messageBox -type yesno -message $msg -icon question -parent [lindex $wstk end]]
		if [string match $choice "no"] {
			return
		}
		set save_mixmanage 0
		foreach bf $badfiles {
			set i [LstIndx $bf $wl]	;#	remove from workspace listing
			if {![DeleteFileFromSystem $bf 1 1]} {
				lappend worsefiles $bf
				continue
			}
			if {[IsInAMixfile $bf]} {
				lappend delete_mixmanage $bf
			}
			if {$i >= 0} {
				$wl delete $i
				WkspCntSimple -1
				catch {unset rememd}
			}
		}
		if {[info exists delete_mixmanage]} {
			MixM_ManagedDeletion $delete_mixmanage
			MixMStore
		}
		if {[info exists worsefiles]} {
			Inf "Cannot Delete All Of These Files"	
			return
		}
	}
	catch {unset badfiles}
	set f .filtdbp
	if [Dlg_Create $f "Extend Files" "set pr_filtdbp 0" -borderwidth $evv(SBDR)] {
		frame $f.1
		frame $f.2
		frame $f.3
		button $f.1.run  -text "Run" -command "set pr_filtdbp 1" -highlightbackground [option get . background {}]
		button $f.1.quit -text "Quit" -command "set pr_filtdbp 0" -highlightbackground [option get . background {}]
		pack $f.1.run -side left
		pack $f.1.quit -side right
		label $f.2.qll -text "Filter Q (10-10000)"
		entry $f.2.q -textvariable filtdbp_q -width 6
		label $f.2.gll -text "Filter Gain "
		entry $f.2.g -textvariable filtdbp_g -width 6
		label $f.2.tll -text "Filter Tail (secs) "
		entry $f.2.t -textvariable filtdbp_t -width 6
		label $f.2.hll -text "Harmonics Cnt (1-200) "
		entry $f.2.h -textvariable filtdbp_h -width 6
		pack $f.2.qll $f.2.q $f.2.gll $f.2.g $f.2.tll $f.2.t $f.2.hll $f.2.h -side left -padx 2
		label $f.3.ll -text "Outfile Name "
		entry $f.3.e -textvariable filtdbp_outfnam -width 24
		pack $f.3.ll $f.3.e -side left -padx 2
		pack $f.1 $f.2 $f.3 -side top -pady 2 -fill x -expand true
		bind $f <Return> {set pr_filtdbp 1}
		bind $f <Escape> {set pr_filtdbp 0}
	}
	set pr_filtdbp 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition2 .filtdbp
	My_Grab 0 $f pr_filtdbp $f.2.q
	while {!$finished} {
		tkwait variable pr_filtdbp
		if {$pr_filtdbp} {
			if {![IsNumeric $filtdbp_q] || ($filtdbp_q < 10) || ($filtdbp_q > 10000)} {
				Inf "Invalid Q Value"
				continue
			}
			if {![IsNumeric $filtdbp_g] || ($filtdbp_g < 0.001) || ($filtdbp_g > 10000)} {
				Inf "Invalid Gain Value"
				continue
			}
			if {![IsNumeric $filtdbp_t] || ($filtdbp_t < 0) || ($filtdbp_t > 20)} {
				Inf "Invalid Tail Duration"
				continue
			}
			if {![regexp {^[0-9]+$} $filtdbp_h] || ($filtdbp_h < 1) || ($filtdbp_h > 200)} {
				Inf "Invalid Harmonics Count"
				continue
			}
			if {[string length $filtdbp_outfnam] <= 0} {
				Inf "No Outfile Name Entered"
				continue
			}
			if {![ValidCDPRootname $filtdbp_outfnam]} {
				continue
			}
			set outffnam [string tolower $filtdbp_outfnam]
			append outffnam $evv(SNDFILE_EXT)
			if {[file exists $outffnam]} {
				set msg "File '$outffnam' Already Exists: Overwrite It ?"
				set choice [tk_messageBox -type yesno -message $msg -icon question -parent [lindex $wstk end]]
				if [string match $choice "no"] {
					continue
				}
				set i [LstIndx $outffnam $wl]
				if {![DeleteFileFromSystem $outffnam 1 1]} {
					Inf "Cannot Delete File '$outffnam'"
					continue
				}
				if {[IsInAMixfile $outffnam]} {
					MixM_ManagedDeletion $outffnam
					MixMStore
				}
				if {$i >= 0} {
					$wl delete $i
					WkspCntSimple -1
					catch {unset rememd}
				}
			}
			set n 0
			catch {unset mixlines}
			foreach line $cuttimes {
				set stt  [lindex $line 0]
				set endd [lindex $line 1]
				catch {unset envlines}
				set prestt [expr $stt - $splicelen]
				set postend [expr $endd + $splicelen]
				if {$prestt <= 0.0} {
					set prestt 0.0
					set line [list 0.0 1.0]
					lappend envlines $line
				} else {
					set line [list 0.0 0.0]
					lappend envlines $line
					set line [list $prestt 0.0]
					lappend envlines $line
					set line [list $stt 1.0]
					lappend envlines $line
				}
				set line [list $endd 1.0]
				lappend envlines $line
				set line [list $postend 0.0]
				lappend envlines $line
				set line [list 100.0 0.0]
				lappend envlines $line

				;#	WRITE FILTER FILE

				if [catch {open $outnamflt($n) "w"} zit] {
					Inf "Cannot Open File '$outnamflt($n)' To Write Filter Data For Segment $n"
					continue
				}
				foreach line $outfilt($n) {
					puts $zit $line
				}
				close $zit
				FileToWkspace $outnamflt($n) 0 0 0 0 1

				set mixline [list $outnamfltsnd($n) $prestt 1 1.0 C]
				lappend mixlines $mixline
				incr n
			}

			;#	WRITE MIX FILE

			if [catch {open $outnammix "w"} zit] {
				Inf "Cannot Open File '$outnammix' To Write Mixfile For Filtered Segments"
				continue
			}
			foreach line $mixlines {
				puts $zit $line
			}
			close $zit
			FileToWkspace $outnammix 0 0 0 0 1

				;#	WRITE BATCH FILE

			set n 0
			while {$n < $outfilecnt} {
				set cmd sfedit
				lappend cmd cut 1 $fnam $outnamseg($n) 
				set cmd [concat $cmd [lindex $cuttimes $n]]
				lappend batch $cmd
				set cmd filter
				lappend cmd varibank 2 $outnamseg($n) $outnamfltsnd($n) $outnamflt($n) $filtdbp_q $filtdbp_g -t$filtdbp_t -h$filtdbp_h -r0.0 -d
				lappend batch $cmd
				incr n
			}
			set cmd submix
			lappend cmd mix $outnammix $outffnam
			lappend batch $cmd

			if [catch {open $outnambat "w"} zit] {
				Inf "Cannot Open File '$outnambat' To Write Batchfile For Filtered Segments"
				continue
			}
			foreach line $batch {
				puts $zit $line
			}
			close $zit
			FileToWkspace $outnambat 0 0 0 0 1
			Inf "The Batchfile, And All The Data Files Are Now On The Workspace"
			set finished 1
		} else {
			foreach fnam $outfileslist {
				if {[file exists $fnam]} {
					set msg "Do You Wish To Delete The Data Files Already Created ??"
					set choice [tk_messageBox -type yesno -message $msg -icon question -parent [lindex $wstk end]]
					if [string match $choice "yes"] {
						foreach xfnam $outfileslist {
							if {[file exists $xfnam]} {
								if [catch {file delete $xfnam} zit] {
									lappend badfiles $xfnam
								}
							}
						}
						if {[info exists badfiles]} {
							Inf "Not All The Data Files Could Be Deleted"
						}
					}
					break
				}
			}
			set finished 1
		}				
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
	return
}

proc FilterDivideByPitchHelp {} {
	set msg "TIME AVERAGE FILTER\n"
	append msg "\n"
	append msg "Combines all filter vals in time-varying filter,\n"
	append msg "to a single static filter.\n"
	append msg "'Weighing' gives greater amplitude to filter vals\n"
	append msg "which persist longer in original t-varying filter.\n"
	append msg "\n"
	append msg "\n"
	append msg "DIVIDE FILTER TO SUBFILTERS\n"
	append msg "\n"
	append msg "Input a sound & a time-varying varibank MIDI datafile.\n"
	append msg "\n"
	append msg "Process finds filter vals at each time in input data.\n"
	append msg "\n"
	append msg "Generates set of non-time-varying filters based on these.\n"
	append msg "\n"
	append msg "Generates batchfile (and associated datafiles) which will\n"
	append msg "a) Cut source into segments corresponding to times at which\n"
	append msg "each filter data-set is operational in original filter-file.\n"
	append msg "b) Filter each of segments with appropriate new filter-data.\n"
	append msg "\n"
	append msg "Generates mixfile which joins up these filtered segments\n"
	append msg "in same time-sequence as in the original source.\n"
	Inf $msg
}

#---- Takes set of sound, and associated pitch-tracing data, and generates batchfile
#---- which will cut out areas having (only) certain specified pitches.

proc ExtractSpecificPitchedMaterial {} {
	global pr_pichop pichop_m pichop_dir pichop_sdir readonlyfg readonlybg pichop_midiset pichop_midishow pichop_typ pichop_sust
	global pichop_min pichop_nmin pichop_outfnam pichop_le pichop_te wl rememd pichop_fty pichop_f pichop_samedir wstk pa evv

	set f .pichop
	if [Dlg_Create $f "Extract Specific Pitched material from Sounds" "set pr_pichop 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		frame $f.00
		frame $f.000
		frame $f.1
		frame $f.2
		set f3 [frame $f.3]
		set f4 [frame $f.4]
		set f5 [frame $f.5]
		set f6 [frame $f.6]
		frame $f.7
		frame $f.8
		frame $f.9
		frame $f.10
		frame $f.11
		frame $f.12
		button $f.0.run  -text "Run" -command "set pr_pichop 1" -highlightbackground [option get . background {}]
		button $f.0.quit -text "Quit" -command "set pr_pichop 0" -highlightbackground [option get . background {}]
		pack $f.0.run -side left
		pack $f.0.quit -side right
		pack $f.0 -side top -pady 2 -fill x -expand true
		label $f.00.dll -text "Directory for pitch data"
		entry $f.00.d -textvariable pichop_dir
		label $f.00.dum -text "               "
		pack $f.00.dll $f.00.d $f.00.dum -side left
		pack $f.00 -side top -pady 2
		label $f.000.dll -text "Directory for sound files"
		entry $f.000.d -textvariable pichop_sdir
		checkbutton $f.000.s -text Same -variable pichop_samedir -command ResetPichopDir
		pack $f.000.dll $f.000.d $f.000.s -side left
		pack $f.000 -side top -pady 2
		label $f.2.is -text "Pitch data is "
		radiobutton $f.2.0 -variable pichop_fty -value 0 -text "varibank midi" -command {set pichop_f _flt.txt}
		radiobutton $f.2.1 -variable pichop_fty -value 1 -text "frq breakpnt" -command {set pichop_f _pch.brk}
		pack $f.2.is $f.2.0 $f.2.1 -side left
		pack $f.2 -side top -pady 2
		label $f.1.ll -text "SELECT PITCHES TO SEARCH FOR"
		pack $f.1.ll -side top
		pack $f.0 $f.1 -side top -pady 2
		radiobutton $f3.36 -variable pichop_m -value 36 -text "C-2" -command "SetPichop"
		radiobutton $f3.37 -variable pichop_m -value 37 -text "C#-2" -command "SetPichop"
		radiobutton $f3.38 -variable pichop_m -value 38 -text "D-2" -command "SetPichop"
		radiobutton $f3.39 -variable pichop_m -value 39 -text "Eb-2" -command "SetPichop"
		radiobutton $f3.40 -variable pichop_m -value 40 -text "E-2" -command "SetPichop"
		radiobutton $f3.41 -variable pichop_m -value 41 -text "F-2" -command "SetPichop"
		radiobutton $f3.42 -variable pichop_m -value 42 -text "F#-2" -command "SetPichop"
		radiobutton $f3.43 -variable pichop_m -value 43 -text "G-2" -command "SetPichop"
		radiobutton $f3.44 -variable pichop_m -value 44 -text "Ab-2" -command "SetPichop"
		radiobutton $f3.45 -variable pichop_m -value 45 -text "A-2" -command "SetPichop"
		radiobutton $f3.46 -variable pichop_m -value 46 -text "Bb-2" -command "SetPichop"
		radiobutton $f3.47 -variable pichop_m -value 47 -text "B-2" -command "SetPichop"

		pack $f3.36 $f3.37 $f3.38 $f3.39 $f3.40 $f3.41 $f3.42 $f3.43 $f3.44 $f3.45 $f3.46 $f3.47 -side left

		radiobutton $f4.48 -variable pichop_m -value 48 -text "C-1" -command "SetPichop"
		radiobutton $f4.49 -variable pichop_m -value 49 -text "C#-1" -command "SetPichop"
		radiobutton $f4.50 -variable pichop_m -value 50 -text "D-1" -command "SetPichop"
		radiobutton $f4.51 -variable pichop_m -value 51 -text "Eb-1" -command "SetPichop"
		radiobutton $f4.52 -variable pichop_m -value 52 -text "E-1" -command "SetPichop"
		radiobutton $f4.53 -variable pichop_m -value 53 -text "F-1" -command "SetPichop"
		radiobutton $f4.54 -variable pichop_m -value 54 -text "F#-1" -command "SetPichop"
		radiobutton $f4.55 -variable pichop_m -value 55 -text "G-1" -command "SetPichop"
		radiobutton $f4.56 -variable pichop_m -value 56 -text "Ab-1" -command "SetPichop"
		radiobutton $f4.57 -variable pichop_m -value 57 -text "A-1" -command "SetPichop"
		radiobutton $f4.58 -variable pichop_m -value 58 -text "Bb-1" -command "SetPichop"
		radiobutton $f4.59 -variable pichop_m -value 59 -text "B-1" -command "SetPichop"

		pack $f4.48 $f4.49 $f4.50 $f4.51 $f4.52 $f4.53 $f4.54 $f4.55 $f4.56 $f4.57 $f4.58 $f4.59 -side left

		radiobutton $f5.60 -variable pichop_m -value 60 -text "C0 " -command "SetPichop"
		radiobutton $f5.61 -variable pichop_m -value 61 -text "C#0 " -command "SetPichop"
		radiobutton $f5.62 -variable pichop_m -value 62 -text "D0 " -command "SetPichop"
		radiobutton $f5.63 -variable pichop_m -value 63 -text "Eb0 " -command "SetPichop"
		radiobutton $f5.64 -variable pichop_m -value 64 -text "E0 " -command "SetPichop"
		radiobutton $f5.65 -variable pichop_m -value 65 -text "F0 " -command "SetPichop"
		radiobutton $f5.66 -variable pichop_m -value 66 -text "F#0 " -command "SetPichop"
		radiobutton $f5.67 -variable pichop_m -value 67 -text "G0 " -command "SetPichop"
		radiobutton $f5.68 -variable pichop_m -value 68 -text "Ab0 " -command "SetPichop"
		radiobutton $f5.69 -variable pichop_m -value 69 -text "A0 " -command "SetPichop"
		radiobutton $f5.70 -variable pichop_m -value 70 -text "Bb0 " -command "SetPichop"
		radiobutton $f5.71 -variable pichop_m -value 71 -text "B0 " -command "SetPichop"

		pack $f5.60 $f5.61 $f5.62 $f5.63 $f5.64 $f5.65 $f5.66 $f5.67 $f5.68 $f5.69 $f5.70 $f5.71 -side left

		radiobutton $f6.72 -variable pichop_m -value 72 -text "C1 " -command "SetPichop"
		radiobutton $f6.73 -variable pichop_m -value 73 -text "C#1 " -command "SetPichop"
		radiobutton $f6.74 -variable pichop_m -value 74 -text "D1 " -command "SetPichop"
		radiobutton $f6.75 -variable pichop_m -value 75 -text "Eb1 " -command "SetPichop"
		radiobutton $f6.76 -variable pichop_m -value 76 -text "E1 " -command "SetPichop"
		radiobutton $f6.77 -variable pichop_m -value 77 -text "F1 " -command "SetPichop"
		radiobutton $f6.78 -variable pichop_m -value 78 -text "F#1 " -command "SetPichop"
		radiobutton $f6.79 -variable pichop_m -value 79 -text "G1 " -command "SetPichop"
		radiobutton $f6.80 -variable pichop_m -value 80 -text "Ab1 " -command "SetPichop"
		radiobutton $f6.81 -variable pichop_m -value 81 -text "A1 " -command "SetPichop"
		radiobutton $f6.82 -variable pichop_m -value 82 -text "Bb1 " -command "SetPichop"
		radiobutton $f6.83 -variable pichop_m -value 83 -text "B1 " -command "SetPichop"

		pack $f6.72 $f6.73 $f6.74 $f6.75 $f6.76 $f6.77 $f6.78 $f6.79 $f6.80 $f6.81 $f6.82 $f6.83 -side left
		pack $f.3 $f.4 $f.5 $f.6 -side top -pady 2 -fill x

		label $f.7.ll -text "MIDI pitches to search for "
		entry $f.7.e -textvariable pichop_midishow -width 20 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		button $f.7.cl -text "Clear" -command {set pichop_m -1; SetPichop} -highlightbackground [option get . background {}]
		pack $f.7.ll $f.7.e $f.7.cl -side left

		label $f.7a -text "CUT SEGMENTS CONTAINING"

		radiobutton $f.8.all  -variable pichop_typ -value 0 -text "all"
		radiobutton $f.8.any  -variable pichop_typ -value 1 -text "any of"
		radiobutton $f.8.1st  -variable pichop_typ -value 2 -text "at least 1st"
		radiobutton $f.8.st1  -variable pichop_typ -value 3 -text "begins with 1st"
		radiobutton $f.8.end  -variable pichop_typ -value 4 -text "ends with last"
		pack $f.8.all $f.8.any $f.8.1st $f.8.st1 $f.8.end  -side left

		radiobutton $f.9.two  -variable pichop_typ -value 5 -text "at least 2 of"
		radiobutton $f.9.1st2 -variable pichop_typ -value 6 -text "at least 1st 2"
		radiobutton $f.9.st2  -variable pichop_typ -value 7 -text "begins with 1st 2"
		radiobutton $f.9.end2 -variable pichop_typ -value 8 -text "ends with last 2"
		pack $f.9.two $f.9.1st2 $f.9.st2 $f.9.end2 -side left

		label $f.9a -text "OR SELECT SOUNDS"

		frame $f.9b 
		radiobutton $f.9b.9 -variable  pichop_typ -value 9 -text "sound dominated by these pitches"
		radiobutton $f.9b.10 -variable pichop_typ -value 10 -text "pitch sustained in sound"
		label $f.9b.for -text "for "
		entry $f.9b.sus -textvariable pichop_sust -width 4
		label $f.9b.sec -text " secs"
		pack $f.9b.9 $f.9b.10 $f.9b.for $f.9b.sus $f.9b.sec -side left

		pack $f.7 $f.7a $f.8 $f.9 $f.9a $f.9b -side top -pady 2

		frame $f.9c -height 1 -bg black
		pack $f.9c -side top -fill x -expand true -pady 4

		label $f.10.lell -text "Leading edge to keep (secs) "
		entry $f.10.le -textvariable pichop_le -width 6
		label $f.10.tell -text "Trailing edge to keep (secs) "
		entry $f.10.te -textvariable pichop_te -width 6
		pack $f.10.lell $f.10.le $f.10.tell $f.10.te -side left
		pack $f.10 -side top -pady 2
		label $f.11.shll -text "Reject segments less than (secs) "
		entry $f.11.sh -textvariable pichop_min -width 6
		label $f.11.sh2ll -text "      Reject notes within segments less than (secs) "
		entry $f.11.sh2 -textvariable pichop_nmin -width 6
		pack $f.11.shll $f.11.sh $f.11.sh2ll $f.11.sh2 -side left
		pack $f.11 -side top -pady 2

		frame $f.11a -height 1 -bg black
		pack $f.11a -side top -fill x -expand true -pady 4

		label $f.12.ll -text "Output File Name "
		entry $f.12.e -textvariable pichop_outfnam -width 24
		pack $f.12.ll $f.12.e -side left -padx 2
		pack $f.12 -side top -pady 4
		bind $f <Return> {set pr_pichop 1}
		bind $f <Escape> {set pr_pichop 0}
	}
	set pichop_samedir 0

	if {![info exists pichop_midiset]} {
		set pichop_midiset {}
		set pichop_midishow ""
	}
	if {![info exists pichop_typ] || ![regexp {^[0-9]+$} $pichop_typ]} {
		set pichop_typ 0
	}
	if {![info exists pichop_fty] || (($pichop_fty != 0) && ($pichop_fty != 1))} {
		set pichop_fty 0
	}
	if {![info exists pichop_f] || ([string length $pichop_f] <= 0)} {
		set pichop_f _flt.txt
	}
	if {![info exists pichop_min] || ![IsNumeric $pichop_min] || ($pichop_min < 0.0)} {
		set pichop_min 0.0
	}
	if {![info exists pichop_nmin] || ![IsNumeric $pichop_nmin] || ($pichop_min < 0.0)} {
		set pichop_nmin 0.0
	}
	if {![info exists pichop_le] || ![IsNumeric $pichop_le] || ($pichop_le < 0.0)} {
		set pichop_le 0.0
	}
	if {![info exists pichop_te] || ![IsNumeric $pichop_te] || ($pichop_te < 0.0)} {
		set pichop_te 0.0
	}
	if {![info exists pichop_sust] || ![IsNumeric $pichop_sust] || ($pichop_sust < 0.0)} {
		set pichop_sust 0.0
	}
	set pichop_m -1
	set pr_pichop 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition2 .pichop
	My_Grab 0 $f pr_pichop $f.12.e
	while {!$finished} {
		tkwait variable pr_pichop
		if {$pr_pichop} {
			if {[llength $pichop_midiset] <= 0} {
				Inf "NO PITCHES CHOSEN"
				continue
			}
			set penult -1
			if {($pichop_typ >= 5) && ($pichop_typ <= 8)} {
				if {[llength $pichop_midiset] <= 2} {
					Inf "Insufficient Pitches Chosen For This Option (Minimum 2)"
					continue
				}
				set penult [expr [llength $pichop_midiset] - 2]
			} elseif {$pichop_typ == 10} {
				if {[llength $pichop_midiset] > 1} {
					Inf "Too Many Pitches Chosen For This Option (Maximum 1)"
					continue
				}
				if {![IsNumeric $pichop_sust] || ($pichop_sust <= 0)} {
					Inf "Invalid Sustain Time"
					continue
				}
			}
			if {[string length $pichop_le] <= 0} {
				set pichop_le 0.0
			}
			if {![IsNumeric $pichop_le] || ($pichop_le < 0)} {
				Inf "Invalid Leading Edge Value"
				continue
			}
			if {[string length $pichop_te] <= 0} {
				set pichop_te 0.0
			}
			if {![IsNumeric $pichop_te] || ($pichop_te < 0)} {
				Inf "Invalid Trailing Edge Value"
				continue
			}
			if {[string length $pichop_min] <= 0} {
				set pichop_min 0.0
			}
			if {![IsNumeric $pichop_min] || ($pichop_min < 0)} {
				Inf "Invalid Minimum Segment Size"
				continue
			}
			if {[string length $pichop_nmin] <= 0} {
				set pichop_nmin 0.0
			}
			if {![IsNumeric $pichop_nmin] || ($pichop_nmin < 0)} {
				Inf "Invalid Minimum Size For Note Within Segment"
				continue
			}
			if {([string length $pichop_dir] <= 0) || ![file exists $pichop_dir] || ![file isdirectory $pichop_dir]} {
				Inf "Invalid Input Directory For Pitch Data Files"
				continue
			}
			if {([string length $pichop_sdir] <= 0) || ![file exists $pichop_sdir] || ![file isdirectory $pichop_sdir]} {
				Inf "Invalid Input Directory For Sounds"
				continue
			}
			if {[string length $pichop_outfnam] <= 0} {
				Inf "No Outfile Name Entered"
				continue
			}
			if {![ValidCDPRootname $pichop_outfnam]} {
				continue
			}
			set outnambat [string tolower $pichop_outfnam]
			if {($pichop_typ == 9) || ($pichop_typ == 10)} {
				append outnambat [GetTextfileExtension sndlist]
			} else {
				append outnambat $evv(BATCH_EXT)
			}
			if {[file exists $outnambat]} {
				set msg "File '$outnambat' Already Exists: Overwrite It ?"
				set choice [tk_messageBox -type yesno -message $msg -icon question -parent [lindex $wstk end]]
				if [string match $choice "no"] {
					continue
				}
				set i [LstIndx $outnambat $wl]
				if {![DeleteFileFromSystem $outnambat 1 1]} {
					Inf "Cannot Delete File '$outnambat'"
					continue
				}
				if {$i >= 0} {
					$wl delete $i
					WkspCntSimple -1
					catch {unset rememd}
				}
			}
			catch {unset infiles}
			foreach fnam [glob -nocomplain [file join $pichop_dir *$pichop_f]] {
				set k [string first $pichop_f $fnam]
				incr k -1
				set sndfnam [string range $fnam 0 $k]
				set sndfnam [file tail $sndfnam]
				set outfnam $sndfnam
				set sndfnam [file join $pichop_sdir $sndfnam]
				append outfnam "_cut_"
				append sndfnam $evv(SNDFILE_EXT)
				if {[file exists $sndfnam]} {
					catch {unset outlist}
					foreach ofnam [glob -nocomplain $outfnam*] {
						lappend outlist $ofnam
						break
					}
					if {![info exists outlist]} {
						lappend infiles $fnam
					} else {
						Inf "Previous Files Of Form \"$outlist\" Already Exist: Delete These Before Proceeding"
						set finished 1
						break
					}
				}
				if {($pichop_typ == 9) || ($pichop_typ == 10)} {
					if {![info exists pa($sndfnam,$evv(DUR))]} {
						Inf "Soundfiles '$sndfnam' etc. Must Be On The Workspace, For This Option."
						set finished 1
						break
					}
					lappend durs $pa($sndfnam,$evv(DUR))
				}
			}
			if {$finished} {
				break
			}
			if {![info exists infiles]} {
				Inf "Either No Data, Or No Sounds Corresponding To Any Of Data, In These Directories"
				continue
			}
			set kk 0
			foreach fnam $infiles {
				if [catch {open $fnam "r"} zit] {
					continue
				}
				set inmidi 0
				catch {unset cutpairs}
				catch {unset inmidiset}
				catch {unset inmiditime}
				set penultmidi -1
				catch {unset lastmidi}
				catch {unset lasttime}
				while {[gets $zit line] >= 0} {
					set line [string trim $line]
					if {[string length $line] <= 0} {
						continue
					} elseif {[string match ";" [string index $line 0]]} {
						continue
					}
					set line [split $line]
					catch {unset nuline}
					foreach item $line {
						set item [string trim $item]
						if {[string length $item] > 0} {
							lappend nuline $item
						}
					}
					if {[llength $line] < 2} {
						continue
					}
					set time [lindex $nuline 0]
					set midi [lindex $nuline 1]
					if {$pichop_fty} {
						set midi [expr int(round([HzToMidi $midi]))]
					}
					if {($pichop_typ == 9) || ($pichop_typ == 10)} {
						lappend inmidiset $midi
						lappend inmiditime $time
						continue
					}
					if {[lsearch $pichop_midiset $midi] >= 0} {
						if {[info exists lastmidi]} {
							if {$midi != $lastmidi} {
								set penultmidi $lastmidi
							}
						}
						set lastmidi $midi
						if {!$inmidi} {
							catch {unset inmidiset}
							catch {unset inmiditime}
							set inmidi 1
							set stt $time
							lappend inmidiset $midi
							lappend inmiditime $time
						} else {
							if {[lsearch $inmidiset $midi] < 0} {
								lappend inmidiset $midi
								lappend inmiditime $time
							}
						}
					} else {
						if {$inmidi} {
							lappend inmiditime $time
							if {$pichop_nmin > 0.0} {
								set inmidiset [TimeTestPitchDataPitchSet $inmidiset $inmiditime $pichop_nmin]
							}
							if {[llength $inmidiset] > 0} {
								if [TestPitchDataPitchSet $inmidiset $lastmidi $penult $penultmidi] {
									set endd $time
									lappend cutpairs $stt $endd
								}
							}
							set inmidi 0
							catch {unset inmidiset}
							catch {unset inmiditime}
						}
					}
				}
				close $zit
				if {($pichop_typ == 9) || ($pichop_typ == 10)} {
					set dur [lindex $durs $kk]
					if {$time < $dur} {
						lappend inmidiset [lindex $inmidiset end]
						lappend inmiditime $dur
					}
				}
				if {$inmidi} {
					lappend inmiditime $time
					if {$pichop_nmin > 0.0} {
						set inmidiset [TimeTestPitchDataPitchSet $inmidiset $inmiditime $pichop_nmin]
					}
					if {[llength $inmidiset] > 0} {
						if [TestPitchDataPitchSet $inmidiset $lastmidi $penult $penultmidi] {
							set endd $time
							lappend cutpairs $stt $endd
						}
					}
				}
				if {[info exists cutpairs]} {
					set cutno 1
					set k [string first $pichop_f $fnam]
					incr k -1
					set sndfnam [string range $fnam 0 $k]
					set basoutfnam [file tail $sndfnam]
					set sndfnam [file join $pichop_sdir $basoutfnam]
					append sndfnam $evv(SNDFILE_EXT)
					if {$pichop_te > 0.0} {
						if {![info exists pa($sndfnam,$evv(DUR))]} {
							Inf "Soundfiles '$sndfnam' Etc. Must Be On The Workspace, If A Trailing Edge Is Specified."
							set finished 1
							break
						}
						set dur $pa($sndfnam,$evv(DUR))
					}
					foreach {stt endd} $cutpairs {
						if {[expr $endd - $stt] < $pichop_min} {
							continue
						}
						set stt [expr $stt - $pichop_le]
						if {$stt < 0.0} {
							set stt 0.0
						}
						if {$pichop_te > 0.0} {
							set endd [expr $endd + $pichop_te]
							if {$endd > $dur} {
								set endd $dur
							}
						}
						set outfnam $basoutfnam
						append outfnam "_cut_" $cutno
						append outfnam $evv(SNDFILE_EXT)
						set cmd sfedit
						lappend cmd cut 1 $sndfnam $outfnam $stt $endd
						lappend batch $cmd
						incr cutno
					}
				}
				if {$pichop_typ == 9} {
					if [AreDominantPitches $inmidiset $inmiditime] {
						set k [string first $pichop_f $fnam]
						incr k -1
						set sndfnam [string range $fnam 0 $k]
						set basoutfnam [file tail $sndfnam]
						set sndfnam [file join $pichop_sdir $basoutfnam]
						append sndfnam $evv(SNDFILE_EXT)
						lappend batch $sndfnam
					}
				} elseif {$pichop_typ == 10} {
					if [PitchPersists $inmidiset $inmiditime] {
						set k [string first $pichop_f $fnam]
						incr k -1
						set sndfnam [string range $fnam 0 $k]
						set basoutfnam [file tail $sndfnam]
						set sndfnam [file join $pichop_sdir $basoutfnam]
						append sndfnam $evv(SNDFILE_EXT)
						lappend batch $sndfnam
					}
				}
				incr kk
			}
			if {$finished} {
				break
			}
			if {![info exists batch]} {
				if {($pichop_typ == 9) || ($pichop_typ == 10)} {
					Inf "No Appropriate Sounds Found"
				} else {
					Inf "No Appropriate Sound Segments Found"
				}
				continue
			}
			if [catch {open $outnambat "w"} zit] {
				if {($pichop_typ == 9) || ($pichop_typ == 10)} {
					Inf "Cannot Open File '$outnambat' To Write List Of Selected Sounds"
				} else {
					Inf "Cannot Open File '$outnambat' To Write Batchfile For Filtered Segments"
				}
				continue
			}
			foreach line $batch {
				puts $zit $line
			}
			close $zit
			if {[FileToWkspace $outnambat 0 0 0 0 1] > 0} {
				Inf "File '$outnambat' Is On The Workspace"
			}
			break
		} else {
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return
}

proc SetPichop {} {
	global pichop_m pichop_midiset pichop_midishow
	if {$pichop_m < 0} {
		set pichop_midiset {}
		set pichop_midishow ""
		return
	}
	if {[lsearch $pichop_midiset $pichop_m] < 0} {
		lappend pichop_midiset $pichop_m
		set pichop_midiset [lsort $pichop_midiset]
	}
	set k [lindex $pichop_midiset 0]
	foreach val [lrange $pichop_midiset 1 end] {
		append k "  " $val
	}
	set pichop_midishow $k
}

proc ResetPichopDir {} {
	global pichop_samedir pichop_sdir pichop_dir
	if {$pichop_samedir} {
		set pichop_sdir $pichop_dir
	} else {
		set pichop_sdir ""
	}
}

proc SaveExtraxtSpecificPitchedMaterialParams {} {
	global pichop_typ pichop_fty pichop_f pichop_min pichop_nmin pichop_le pichop_te pichop_midiset pichop_midishow evv
	global pichop_dir pichop_sdir pichop_sust
	if {![info exists pichop_typ]  || ![regexp {^[0-9]+$} $pichop_typ] \
	||  ![info exists pichop_fty]  || (($pichop_fty != 0) && ($pichop_fty != 1)) \
	||  ![info exists pichop_f]    || ([string length $pichop_f] <= 0) \
	||  ![info exists pichop_min]  || ![IsNumeric $pichop_min]  || ($pichop_min  < 0.0) \
	||  ![info exists pichop_nmin] || ![IsNumeric $pichop_nmin] || ($pichop_nmin < 0.0) \
	||  ![info exists pichop_le]   || ![IsNumeric $pichop_le]   || ($pichop_le   < 0.0) \
	||  ![info exists pichop_te]   || ![IsNumeric $pichop_te]   || ($pichop_te   < 0.0) \
	||  ![info exists pichop_midiset]  || ([llength $pichop_midiset] <= 0) \
	||  ![info exists pichop_midishow] || ([string length $pichop_midishow] <= 0) \
	||  ![info exists pichop_dir]  || ![file isdirectory $pichop_dir] \
	||  ![info exists pichop_sdir] || ![file isdirectory $pichop_sdir] \
	||  ![info exists pichop_sust]  || ![IsNumeric $pichop_sust]  || ($pichop_sust  < 0.0) } {
		return
	}
	set fnam [file join $evv(URES_DIR) pextract]
	append fnam $evv(CDP_EXT)
	if [catch {open $fnam "w"} zit] {
		return
	}
	puts $zit $pichop_typ
	puts $zit $pichop_fty
	puts $zit $pichop_f
	puts $zit $pichop_min
	puts $zit $pichop_nmin
	puts $zit $pichop_le
	puts $zit $pichop_te
	puts $zit $pichop_midiset
	puts $zit $pichop_midishow 
	puts $zit "$pichop_dir"
	puts $zit "$pichop_sdir" 
	puts $zit $pichop_sust
	close $zit
}

proc LoadExtraxtSpecificPitchedMaterialParams {} {
	global pichop_typ pichop_fty pichop_f pichop_min pichop_nmin pichop_le pichop_te pichop_midiset pichop_midishow evv
	global pichop_dir pichop_sdir pichop_sust
	set fnam [file join $evv(URES_DIR) pextract]
	append fnam $evv(CDP_EXT)
	if {![file exists $fnam]} {
		return
	}
	if [catch {open $fnam "r"} zit] {
		return
	}
	set cnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		switch -- $cnt {
			0 { set pichop_typ $line }
			1 { set pichop_fty $line }
			2 { set pichop_f $line }
			3 { set pichop_min $line }
			4 { set pichop_nmin $line }
			5 { set pichop_le $line }
			6 { set pichop_te $line }
			7 { 
				set line [split $line]
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] > 0} {
						lappend pichop_midiset $item
					}
				}
			}
			8 { set pichop_midishow $line }
			9 { set pichop_dir $line }
			10 { set pichop_sdir $line }
			11 { set pichop_sust $line }
		}
		incr cnt
	}
	close $zit
	if {$cnt != 12} {
		Inf "Error Reading Pitchdata-Extract-Segs Datafile"
		catch {unset pichop_typ}
		catch {unset pichop_fty}
		catch {unset pichop_f}
		catch {unset pichop_min}
		catch {unset pichop_nmin}
		catch {unset pichop_le}
		catch {unset pichop_te}
		catch {unset pichop_midiset}
		catch {unset pichop_midishow}
		catch {unset pichop_dir}
		catch {unset pichop_sdir}
		catch {unset pichop_sust}
	}
	return
}

#--- Does set of MIDI values found meet the criteria ?

proc TestPitchDataPitchSet {inmidiset lastmidi penult penultmidi} {
	global pichop_midiset pichop_typ

	switch -- $pichop_typ {
		0 {	;# ALL
			if {[llength $pichop_midiset] == [llength $inmidiset]} {
				return 1
			}
		}
		1 {	;#	ANY OF
			return 1
		}
		2 {	;# CONTAINS AT LEAST FIRST
			if {[lsearch $inmidiset [lindex $pichop_midiset 0]] >= 0} {
				return 1	
			}
		}
		3 {	;# BEGINS WITH FIRST
			if {[lindex $pichop_midiset 0] == [lindex $inmidiset 0]} {
				return 1	
			}
		}
		4 {	;# ENDS WITH LAST
			if {[lindex $pichop_midiset end] == $lastmidi} {
				return 1	
			}
		}
		5 {	;#	AT LEAST TWO OF
			if {[llength $inmidiset] >= 2} {
				return 1	
			}
		}
		6 {	;# CONTAINS AT LEAST FIRST TWO
			if {[llength $inmidiset] > 1} {
				if {([lsearch $inmidiset [lindex $pichop_midiset 0]] >= 0) \
				&&  ([lsearch $inmidiset [lindex $pichop_midiset 1]] >= 0)} {
					return 1	
				}
			}
		}
		7 {	;# BEGINS WITH FIRST TWO
			if {[llength $inmidiset] > 1} {
				if {([lindex $pichop_midiset 0] == [lindex $inmidiset 0]) \
				&&  ([lindex $pichop_midiset 1] == [lindex $inmidiset 1])} {
					return 1	
				}
			}
		}
		8 {	;# ENDS WITH LAST TWO
			if {([llength $inmidiset] > 1) && ($penultmidi >= 0)} {
				if {([lindex $pichop_midiset end] == $lastmidi) \
				&&  ([lindex $pichop_midiset $penult] == $penultmidi)} {
					return 1	
				}
			}
		}
	}
	return 0
}

#--- Check if any midi note is too short

proc TimeTestPitchDataPitchSet {midiset miditime mindur} {
	set tlen [llength $miditime]
	set mlen [llength $midiset]
	if {[expr $mlen + 1] != $tlen} {
		Inf "Programming Error In Time-Test"
		return $midiset
	}
	set lasttime [lindex $miditime 0]
	set n 1
	while {$n < $tlen} {
		set thistime [lindex $miditime $n]
		set dur [expr $thistime - $lasttime]
		lappend durs $dur
		set lasttime $thistime
		incr n
	}
	set n 0 
	while {$n < $mlen} {
		set dur [lindex $durs $n]
		set midi [lindex $midiset $n]
		if {$dur < $mindur} {
			set durs [lreplace $durs $n $n]
			set midiset [lreplace $midiset $n $n]
			incr mlen -1
		} else {
			incr n
		}
	}
	return $midiset
}

proc AreDominantPitches {midiset miditime} {
	global pichop_midiset
	set totaldur [lindex $miditime end]
	set selectdur 0.0
	set lastmidi [lindex $midiset 0]
	set lasttime [lindex $miditime 0]
	foreach midi [lrange $midiset 1 end] time [lrange $miditime 1 end] {
		if {$midi == $lastmidi} {
			if {$time >= $totaldur} {
				if {[lsearch $pichop_midiset $lastmidi] >= 0} {
					set dur [expr $time - $lasttime]
					set selectdur [expr $selectdur + $dur]
				}
				break
			}				
			continue
		} else {
			if {[lsearch $pichop_midiset $lastmidi] >= 0} {
				set dur [expr $time - $lasttime]
				set selectdur [expr $selectdur + $dur]
			}				
			set lastmidi $midi
			set lasttime $time
		}
	}
	set ratio [expr $selectdur / $totaldur]
	if {$ratio > 0.66666} {
		return 1
	}
	return 0
}

proc PitchPersists {midiset miditime} {
	global pichop_midiset pichop_sust
	set totaldur [lindex $miditime end]
	set selectdur 0.0
	set lastmidi [lindex $midiset 0]
	set lasttime [lindex $miditime 0]
	foreach midi [lrange $midiset 1 end] time [lrange $miditime 1 end] {
		if {$midi == $lastmidi} {
			if {$time >= $totaldur} {
				if {[lsearch $pichop_midiset $lastmidi] >= 0} {
					set dur [expr $time - $lasttime]
					if {$dur >= $pichop_sust} {
						return 1
					}
				}
				break
			}				
			continue
		} else {
			if {[lsearch $pichop_midiset $lastmidi] >= 0} {
				set dur [expr $time - $lasttime]
				if {$dur >= $pichop_sust} {
					return 1
				}
			}				
			set lastmidi $midi
			set lasttime $time
		}
	}
	return 0
}

######################

#---- Takes set of sound, and associated pitch-tracing data, and generates batchfile
#---- which will cut out areas having (only) certain specified pitches.

proc IntervalStats {} {
	global pr_intstats intstats_fty intstats_f intstats_stats intstats_min intstats_disp wstk intstats_outfnam evv
	global intstats_no_2 intstats_no_m2 rememd wl tp_props_list

	catch {unset mset}
	set instats_dir [file dirname [lindex [lindex $tp_props_list 0] 0]]
	set f .intstats
	if [Dlg_Create $f "Statistics on Pitch Intervals Within Sounds" "set pr_intstats 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		frame $f.1
		frame $f.2
		frame $f.3
		frame $f.4
		frame $f.5
		button $f.0.run  -text "Run" -command "set pr_intstats 1" -highlightbackground [option get . background {}]
		button $f.0.pri  -text "" -command {} -width 13 -bd 0 -highlightbackground [option get . background {}]
		button $f.0.quit -text "Quit" -command "set pr_intstats 0" -highlightbackground [option get . background {}]
		pack $f.0.run $f.0.pri -side left -padx 8
		pack $f.0.quit -side right
		pack $f.0 -side top -pady 2 -fill x -expand true
		label $f.1.is -text "Pitch data is "
		radiobutton $f.1.0 -variable intstats_fty -value 0 -text "varibank midi" -command {set intstats_f _flt.txt}
		radiobutton $f.1.1 -variable intstats_fty -value 1 -text "frq breakpnt" -command {set intstats_f _pch.brk}
		pack $f.1.is $f.1.0 $f.1.1 -side left
		pack $f.1 -side top -pady 2
		label $f.2.ll -text "Minimum no. of occurences to record "
		entry $f.2.e -textvariable intstats_min
		pack $f.2.ll $f.2.e -side left -padx 2
		pack $f.2 -side top
		label $f.3.ll -text "Output Name "
		entry $f.3.e -textvariable intstats_outfnam -width 24
		pack $f.3.ll $f.3.e -side left -padx 2
		pack $f.3 -side top
		label $f.4.ll -text "Omit "
		checkbutton $f.4.min -text "minor 2nds" -variable intstats_no_m2
		checkbutton $f.4.maj -text "major 2nds" -variable intstats_no_2
		pack $f.4.ll $f.4.min $f.4.maj -side left -padx 2
		pack $f.4 -side top
		set intstats_disp [Scrolled_Listbox $f.5.ll -width 30 -height 24 -selectmode single]
		pack $f.5.ll -side top -fill both -expand true
		pack $f.5 -side top
		bind $f <Return> {set pr_intstats 1}
		bind $f <Escape> {set pr_intstats 0}
	}
	$intstats_disp delete 0 end
	if [info exists intstats_stats] {
		foreach line $intstats_stats {
			$intstats_disp insert end $line
		}
	}
	set intstats_no_m2 0
	set intstats_no_2 0
	set intstats_min 2
	set pr_intstats 0
	set intstats_fty 0
	set intstats_f _flt.txt
	set finished 0
	raise $f
	update idletasks
	StandardPosition2 .intstats
	My_Grab 0 $f pr_intstats $f.3.e
	while {!$finished} {
		tkwait variable pr_intstats
		if {$pr_intstats} {
			if {$pr_intstats == 2} {
				if {![info exists intstats_stats]} {
					Inf "No Stats To Output"
					continue
				}
				if {[string length $intstats_outfnam] <= 0} {
					Inf "No Outfile Name Entered"
					continue
				}
				if {![ValidCDPRootname $intstats_outfnam]} {
					continue
				}
				set outnamstats [string tolower $intstats_outfnam]
				append outnamstats $evv(TEXT_EXT)
				if {[file exists $outnamstats]} {
					set msg "File '$outnamstats' Already Exists: Overwrite It ?"
					set choice [tk_messageBox -type yesno -message $msg -icon question -parent [lindex $wstk end]]
					if [string match $choice "no"] {
						continue
					}
					set i [LstIndx $outnamstats $wl]
					if {![DeleteFileFromSystem $outnamstats 1 1]} {
						Inf "Cannot Delete File '$outnamstats'"
						continue
					}
					if {$i >= 0} {
						$wl delete $i
						WkspCntSimple -1
						catch {unset rememd}
					}
				}
				if [catch {open $outnamstats "w"} zit] {
					Inf "Cannot Open File To Write Stats"
					continue
				}
				foreach line $intstats_stats {
					puts $zit $line
				}
				close $zit
				if {[FileToWkspace $outnamstats 0 0 0 0 1] > 0} {
					Inf "File '$outnamstats' Is On The Workspace"
				}
				break
			}
			catch {unset intstats_stats}
			catch {unset infiles}
			foreach fnam [glob -nocomplain [file join $intstats_dir *$intstats_f]] {
				set k [string first $intstats_f $fnam]
				incr k -1
				set sndfnam [string range $fnam 0 $k]
				append sndfnam $evv(SNDFILE_EXT)
				if {[file exists $sndfnam]} {
					lappend infiles $fnam
				}
			}
			if {![info exists infiles]} {
				Inf "Either No Data, Or No Sounds Corresponding To Any Of The Data"
				continue
			}
			if {![regexp {^[0-9]+$} $intstats_min] || ($intstats_min < 2)} {
				Inf "Invalid Value For Minimum Count To Record (>= 2)"	
				continue
			}
			Block "Finding all Pitches Used"
			set basmidiset {}
			foreach fnam $infiles {
				if [catch {open $fnam "r"} zit] {
					continue
				}
				set inmidi 0
				while {[gets $zit line] >= 0} {
					set line [string trim $line]
					if {[string length $line] <= 0} {
						continue
					} elseif {[string match ";" [string index $line 0]]} {
						continue
					}
					set line [split $line]
					catch {unset nuline}
					foreach item $line {
						set item [string trim $item]
						if {[string length $item] > 0} {
							lappend nuline $item
						}
					}
					if {[llength $line] < 2} {
						continue
					}
					set midi [lindex $nuline 1]
					if {$intstats_fty} {
						set midi [expr int(round([HzToMidi $midi]))]
					}
					if {[lsearch $basmidiset $midi] < 0} {
							lappend basmidiset $midi
					}
				}
				close $zit
			}
			UnBlock
			set len [llength $basmidiset]
			if {$len < 4} {
				Inf "Total Midi Pitches Found Too Small (<4)"
				continue
			}
			Block "Doing Statistics"
			set len_less_one [expr $len - 1]
			set len_less_two [expr $len - 2]
			set len_less_thr [expr $len - 3]
			set n 0
			while {$n < $len_less_thr} {
				set midi_n [lindex $basmidiset $n]
				set m $n
				incr m
				while {$m < $len_less_two} {
					set midi_m [lindex $basmidiset $m]
					set thisnam [lsort [list $midi_n $midi_m]]
					set OK 1
					if {$intstats_no_m2} {
						if {[expr abs($midi_n - $midi_m)] <= 1} {
							set OK 0
						}
					}
					if {$intstats_no_2} {
						if {[expr abs($midi_n - $midi_m)] <= 2} {
							set OK 0
						}
					}
					if {$OK} {
						set mset($thisnam) 0 
					}
					set k $m
					incr k
					while {$k < $len_less_one} {
						set midi_k [lindex $basmidiset $k]
						set thisnam [lsort [list $midi_n $midi_m $midi_k]]
						set OK 1
						if {$intstats_no_m2} {
							if {([expr abs($midi_m - $midi_k)] <= 1) || ([expr abs($midi_n - $midi_k)] <= 1) } {
								set OK 0
							}
						}
						if {$intstats_no_2} {
							if {([expr abs($midi_m - $midi_k)] <= 2) || ([expr abs($midi_n - $midi_k)] <= 2) } {
								set OK 0
							}
						}
						if {$OK} {
							set mset($thisnam) 0 
						}
						set j $k
						incr j
						while {$j < $len} {
							set midi_j [lindex $basmidiset $j]
							set thisnam [lsort [list $midi_n $midi_m $midi_k $midi_j]]
							set OK 1
							if {$intstats_no_m2} {
								if {([expr abs($midi_k - $midi_j)] <= 1) || ([expr abs($midi_m - $midi_j)] <= 1) || ([expr abs($midi_n - $midi_j)] <= 1)} {
									set OK 0
								}
							}
							if {$intstats_no_2} {
								if {([expr abs($midi_k - $midi_j)] <= 2) || ([expr abs($midi_m - $midi_j)] <= 2) || ([expr abs($midi_n - $midi_j)] <= 2)} {
									set OK 0
								}
							}
							if {$OK} {
								set mset($thisnam) 0 
							}
							incr j
						}
						incr k
					}
					incr m
				}
				incr n
			}
			foreach fnam $infiles {
				if [catch {open $fnam "r"} zit] {
					continue
				}
				catch {unset midivals}
				while {[gets $zit line] >= 0} {
					set line [string trim $line]
					if {[string length $line] <= 0} {
						continue
					} elseif {[string match ";" [string index $line 0]]} {
						continue
					}
					set line [split $line]
					catch {unset nuline}
					foreach item $line {
						set item [string trim $item]
						if {[string length $item] > 0} {
							lappend nuline $item
						}
					}
					if {[llength $line] < 2} {
						continue
					}
					lappend midivals [lindex $line 1]
				}
				close $zit
				foreach nam [array names mset]	{
					set intstats_midiset $nam
					set inmidi 0
					catch {unset inmidiset}
					foreach midi $midivals {
						if {$intstats_fty} {
							set midi [expr int(round([HzToMidi $midi]))]
						}
						if {[lsearch $intstats_midiset $midi] >= 0} {
							if {!$inmidi} {
								catch {unset inmidiset}
								set inmidi 1
								lappend inmidiset $midi
							} else {
								if {[lsearch $inmidiset $midi] < 0} {
									lappend inmidiset $midi
								}
							}
						} else {
							if {$inmidi} {
								if {[llength $intstats_midiset] == [llength $inmidiset]} {
									incr mset($nam)
								}
								set inmidi 0
								catch {unset inmidiset}
							}
						}
					}
				}
			}
			set cnt 0
			foreach nam [array names mset] {
				if {$mset($nam) < $intstats_min} {
					unset mset($nam)
				} else {
					incr cnt
				}
			}
			if {$cnt == 0} {
				Inf "No Significant Data Found"
				UnBlock
				break
			}
			foreach nam [array names mset] {
				lappend namlist $nam
			}
			set len [llength $namlist]
			set len_less_one [expr $len - 1]
			set n 0
			while {$n < $len_less_one} {
				set nam_n [lindex $namlist $n]
				set m $n
				incr m
				while {$m < $len} {
					set nam_m [lindex $namlist $m]
					if {$mset($nam_m) > $mset($nam_n)} {
						set namlist [lreplace $namlist $n $n $nam_m]
						set namlist [lreplace $namlist $m $m $nam_n]
						set nam_n $nam_m
					}
					incr m
				}
				incr n
			}
			UnBlock
			catch {unset intstats_stats}
			$intstats_disp delete 0 end
			foreach nam $namlist {
				set val [lindex $nam 0]
				set not [MidiToNote_IS $val]
				set line $not
				set line2 $val
				foreach val [lrange $nam 1 end] {
					set not [MidiToNote_IS $val]
					append line "," $not
					append line2 "," $val
				}
				append line " : "
				append line $line2 
				append line " : "
				append line $mset($nam)
				lappend intstats_stats $line 
			}
			foreach line $intstats_stats {
				$intstats_disp insert end $line

			}
			$f.0.pri config -text "Output Stats" -command "set pr_intstats 2" -bd 2
		} else {
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
	return
}

proc MidiToNote_IS {midi} {
	switch -- $midi {
		36 { return "C-2" }
		37 { return "C#-2" }
		38 { return "D-2" }
		39 { return "Eb-2" }
		40 { return "E-2" }
		41 { return "F-2" }
		42 { return "F#-2" }
		43 { return "G-2" }
		44 { return "Ab-2" }
		45 { return "A-2" }
		46 { return "Bb-2" }
		47 { return "B-2" }
		48 { return "C-1" }
		49 { return "C#-1" }
		50 { return "D-1" }
		51 { return "Eb-1" }
		52 { return "E-1" }
		53 { return "F-1" }
		54 { return "F#-1" }
		55 { return "G-1" }
		56 { return "Ab-1" }
		57 { return "A-1" }
		58 { return "Bb-1" }
		59 { return "B-1" }
		60 { return "C0" }
		61 { return "C#0" }
		62 { return "D0" }
		63 { return "Eb0" }
		64 { return "E0" }
		65 { return "F0" }
		66 { return "F#0" }
		67 { return "G0" }
		68 { return "Ab0" }
		69 { return "A0" }
		70 { return "B0" }
		71 { return "Bb0" }
		72 { return "C1" }
		73 { return "C#1" }
		74 { return "D1" }
		75 { return "Eb1" }
		76 { return "E1" }
		77 { return "F1" }
		78 { return "F#1" }
		79 { return "G1" }
		80 { return "Ab1" }
		81 { return "A1" }
		82 { return "B1" }
		83 { return "Bb1" }
	}
	return ""
}

proc FreeHarmonyHelp {} {
	set msg "CREATE FREE HARMONY\n"
	append msg "\n"
	append msg "\"CREATE DATA FILE :\" CREATING YOUR BASIC HARMONIC FIELD\n"
	append msg "\n"
	append msg "Free Harmonies are created by band-filtering noise\n"
	append msg "to produce a specific sets of pitches, a Harmonic Field.\n"
	append msg "\n"
	append msg "You need to set values for FRQ (and optionally AMPS, PARTIALS) of the constituents of this Harmonic Field.\n"
	append msg "\n"
	append msg "This can ONLY be done from the \"CREATE DATA FILE\" button.\n"
	append msg "(if Free Harmony Workshop has been run before, previous values may appear in the listings)\n"
	append msg "\n"
	append msg "Using this button, select which type of file (Frequency Data, Amplitude Data, Partials Data)\n"
	append msg "you wish to create.\n"
	append msg "\n"
	append msg "\"Frequency Data\" is a list of (fundamental) frequencies, in Hz.\n"
	append msg "\n"
	append msg "\"Amplitude Data\" is a list of amplitudes (>0 to 1) for each Frequency constituent.\n"
	append msg "\n"
	append msg "\"Partials\" lists pairs of values for partial-number : amplitude.\n"
	append msg "Partials are whole numbers, and if too high are ignored and a warning given.\n"
	append msg "This info applies to ALL frequency constituents, allowing you to suppress/emphasize specific partials.\n"
	append msg "\n"
	append msg "This (combined) information forms the \"chord\" basis of the sound.\n"
	append msg "\n"
	append msg "\n"
	append msg "\"COLOUR :\" MODIFYING THE SOUND OF YOUR HARMONIC FIELD\n"
	append msg "\n"
	append msg "Q\n"
	append msg "        This determines the tightness of the filter.\n"
	append msg "        A high value produces \"pure\" tones, a low value noisy tones.\n"
	append msg "pitch drift\n"
	append msg "        The interval by which the individual pitches may drift, as time passes.\n"
	append msg "drift rate\n"
	append msg "        The rate of pitch-drifting.\n"
	append msg "(The following 3 parameters correspond to those in \"varifilt\").\n"
	append msg "max no of harmonics (>0)\n"
	append msg "        Max no of harmonics of the pitch to be created.\n"
	append msg "        (If you load a previous patch using NO harmonics, this parameter isn't displayed).\n"
	append msg "rolloff (0 to -96dB)\n"
	append msg "        The gradual reduction of level of higher harmonics (dB).\n"
	append msg "        (If you load a previous patch using NO harmonics, this parameter isn't displayed).\n"
	append msg "gain\n"
	append msg "        The overall gain in the output signal.\n"
	append msg "possible output gain\n"
	append msg "        Once you run the process : this box will display\n"
	append msg "        the maximum gain you COULD apply in the previous box.\n"
	append msg "\n"
	append msg "\n"
	append msg "\"FRQ LAYOUT :\" CHANGING THE HARMONIC FIELD OF YOUR OUTPUT\n"
	append msg "\n"
	append msg "Once you have established a set of frequencies (amplitudes, partials)\n"
	append msg "these button will allow you to modify the pitch structure you created.\n"
	append msg "(changes are displayed in the tables at top left).\n"
	append msg "To hear the changes you must rerun the synthesis.\n"
	append msg "\n"
	append msg "\n"
	append msg "\"DATA STATE :\"   SAVING/RECYCLING YOUR DATA\n"
	append msg "\n"
	append msg "Here you can SAVE the DATA you have used, or LOAD previosuly saved data.\n"
	append msg "\n"
	append msg "\n"
	append msg "CREATE & PLAY\n"
	append msg "\n"
	append msg "Once your parameters are set, press this button to create & play the output.\n"
	append msg "\n"
	append msg "\n"
	append msg "SAVING YOUR SOUND OUTPUT\n"
	append msg "\n"
	append msg "Once the process has run, a button appears to allow you to SAVE  the output sound\n"
	append msg "(and another to enable you to save the filter frqs used).\n"
	append msg "\n"
	Inf $msg
}
