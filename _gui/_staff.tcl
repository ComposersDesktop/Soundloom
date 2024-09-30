#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD 30 June 2013
# ... fixup button rectangles

##################
# STAFF NOTATION #
##################

#------ Create a column from staff notation graphics

proc StaffToMidi {isnote} {
	global docol_OK outlines tedit_message last_oc tot_inlines coltype rcolno orig_incolget evv
	global last_cr col_ungapd_numeric tot_outlines lmo orig_inlines insitu record_temacro temacro temacrop
	global opm_numidilist tabed

	HaltCursCop

  	set d "disabled"
  	set n "normal"

	if {[info exists tot_inlines] && ($tot_inlines > 0)} {
		SetInout 1
	}
	set lmo "STM"
	lappend lmo $col_ungapd_numeric $isnote

	set tb $tabed.bot

	set tedit_message ""
	ForceVal $tabed.message.e $tedit_message
 	$tabed.message.e config -bg [option get . background {}]

	if {$insitu} {
		set ll $tb.icframe.l.list
		set lins "inlines"
		set zfile $evv(COLFILE1)
	} else {
		set ll $tb.ocframe.l.list
		set lins "outlines"
		set zfile $evv(COLFILE2)
	}
	if {!$insitu} {
		set last_oc [$ll get 0 end]
		set last_cr $col_ungapd_numeric
		$tb.kcframe.e config -state $d
		$tb.kcframe.oko config -state $d
		$tb.kcframe.okr config -state $d
		$tb.kcframe.okk config -state $d
		$tb.kcframe.oki config -state $d
		$tb.kcframe.oky config -state $d
		$tb.kcframe.okz config -state $d
		$tb.kcframe.ok config -state $d
	}
	$ll delete 0 end		;#	Clear existing listing of column
	set $lins 0				;#	Set col linecnt to zero

	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz 0
		lappend zxz 0
		lappend temacrop $zxz
	}
	set docol_OK 0
	DoTbankPitchDisplay
	if {[info exists opm_numidilist] && ([llength $opm_numidilist] > 0)} {
		set docol_OK 1
	}
	if {$docol_OK} {
		foreach item $opm_numidilist {
			$ll insert end $item
		}
		catch {close $fileoc}
		if [catch {open $zfile "w"} fileoc] {
			ForceVal $tabed.message.e  "Cannot open temporary file $zfile to write new column data"
		 	$tabed.message.e config -bg $evv(EMPH)
			$ll delete 0 end		;#	Clear existing listing of output column
			set $lins ""
		} else {
			set $lins 0
			foreach line [$ll get 0 end] {
				puts $fileoc $line
				incr $lins
			}
			close $fileoc						;#	Write data to file

			if {!$insitu} {
				$tb.kcframe.oky config -state $n
				$tb.kcframe.okz config -state $n
				if {[info exists tot_inlines] && ($tot_inlines > 0)} {
					if {$outlines == $orig_inlines} {
						SetKCState "o"
						ForceVal $tb.kcframe.e $rcolno
					} elseif {$outlines == $tot_inlines} {
						set coltype "i"
						$tb.kcframe.oki config -state $n
						$tb.kcframe.oko config -state $d
						$tb.kcframe.okr config -state $n
						set rcolno $orig_incolget
						ForceVal $tb.kcframe.e $rcolno
						$tb.kcframe.e config -state $n
					} else {
						SetKCState "k"
					}
				} elseif {[info exists tot_outlines] && ($tot_outlines > 0) && ($outlines == $tot_outlines)} {
					SetKCState "i"
				} else {
					SetKCState "k"
				}
				$tb.kcframe.okk config -state $n
				$tb.kcframe.ok config -state $n
			} else {
				set orig_incolget ""
				if {($outlines > 0) && ($coltype == "o")} {
					SetKCState "i"
				}
			}
		}
	} else {
		$ll delete 0 end		;#	Clear existing listing of output 
		set $lins ""
	}
}

#-------- Graphic entry of Pitches buy clicking on staff

proc DoTbankPitchDisplay {} {
	global pr_tbp tbankgrafix pm_numidilist tpm_numidilist opm_numidilist evv

	if {![info exists tpm_numidilist]} {
		set tpm_numidilist {}
	}
	if {[info exists pm_numidilist]} {
		set orig_pm_numidilist $pm_numidilist
	} else {
		set orig_pm_numidilist {}
	}
	set pm_numidilist $tpm_numidilist
	set f .tbank_pitches
	if [Dlg_Create $f "PITCH DISPLAY" "set pr_tbp 0" -width 120 -borderwidth $evv(SBDR)] {
		set b [frame $f.b -borderwidth $evv(SBDR)]
		set s [frame $f.s -borderwidth $evv(SBDR)]
		set d [frame $f.d -borderwidth $evv(SBDR)]
		button $b.kee -text "Keep" -command "set pr_tbp 1" -highlightbackground [option get . background {}]
		button $b.cle -text "Clear" -command ClearTbank -highlightbackground [option get . background {}]
		button $b.aba -text "Abandon" -command "set pr_tbp 0" -highlightbackground [option get . background {}]
		pack $b.kee -side left -pady 2
		pack $b.aba $b.cle -side right -padx 12
		label $s.ll -text "Click Mouse on Display to Add Pitch\nShift Click for Flats\nControl-Click for Delete" \
			-fg $evv(SPECIAL)
		pack $s.ll -side top -pady 2
		set tbankgrafix [EstablishPmarkDisplay $d]
		pack $tbankgrafix -side top
		pack $b $s $d -side top -fill x -expand true -pady 1
#		wm resizable $f 0 0
		bind $tbankgrafix <ButtonRelease-1> {PgrafixAddPitch $tbankgrafix %x %y 0}
		bind $tbankgrafix <Shift-ButtonRelease-1> {PgrafixAddPitch $tbankgrafix %x %y 1}
		bind $tbankgrafix <Control-ButtonRelease-1> {PgrafixDelPitch $tbankgrafix %x %y}
		bind $f <Return> {set pr_tbp 1}
		bind $f <Escape> {set pr_tbp 0}
	}
	raise $f
	set pr_tbp 0
	My_Grab 0 $f pr_tbp $tbankgrafix
	tkwait variable pr_tbp
	set tpm_numidilist $pm_numidilist
	set pm_numidilist $orig_pm_numidilist
	if {$pr_tbp} {
		set opm_numidilist $tpm_numidilist 
	} else {
		set opm_numidilist {}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#-------- Clear Pitches Display

proc ClearTbank {} {
	global tbankgrafix pm_numidilist
	ClearPitchGrafix $tbankgrafix
	set pm_numidilist {}
}

#------ Convert screen position to MIDI value

proc MidiFromNoteGraphic {w xx yy} {
	global nscreen nscreenval nscreencnt nscrlist

	set obj [$nscreen find closest $xx $yy]
	set coords [$nscreen coords $obj]
	set x [expr int([lindex $coords 0])]
	set y [expr int([lindex $coords 1])]
	switch -- $x {
		100 {
			switch -- $y {
				17	{ $nscrlist insert end 108 ; set nscreenval 108 }
				167	{ $nscrlist insert end 84  ; set nscreenval 84  }
			}
		}
		112 {
			switch -- $y {
				22	{ $nscrlist insert end 107 ; set nscreenval 107 }
				172	{ $nscrlist insert end 83  ; set nscreenval 83  }
			}
		}
		128 {
			switch -- $y {
				22	{ $nscrlist insert end 106 ; set nscreenval 106 }
				172	{ $nscrlist insert end 82  ; set nscreenval 82  }
			}
		}
		140 {
			switch -- $y {
				27	{ $nscrlist insert end 105 ; set nscreenval 105 }
				177	{ $nscrlist insert end 81  ; set nscreenval 81  }
			}
		}
		156 {
			switch -- $y {
				27	{ $nscrlist insert end 104 ; set nscreenval 104 }
				177	{ $nscrlist insert end 80  ; set nscreenval 80  }
			}
		}
		168 {
			switch -- $y {
				32	{ $nscrlist insert end 103 ; set nscreenval 103 }
				182	{ $nscrlist insert end 79  ; set nscreenval 79  }
			}
		}
		184 {
			switch -- $y {
				32	{ $nscrlist insert end 102 ; set nscreenval 102 }
				182	{ $nscrlist insert end 78  ; set nscreenval 78  }
			}
		}
		198 {
			switch -- $y {
				37	{ $nscrlist insert end 101 ; set nscreenval 101 }
				187	{ $nscrlist insert end 77  ; set nscreenval 77  }
			}
		}
		210 {
			switch -- $y {
				42	{ $nscrlist insert end 100 ; set nscreenval 100 }
				192	{ $nscrlist insert end 76  ; set nscreenval 76  }
			}
		}
		226 {
			switch -- $y {
				42	{ $nscrlist insert end 99 ; set nscreenval 99 }
				192	{ $nscrlist insert end 75 ; set nscreenval 75 }
			}
		}
		238 {
			switch -- $y {
				47	{ $nscrlist insert end 98 ; set nscreenval 98 }
				197	{ $nscrlist insert end 74 ; set nscreenval 74 }
			}
		}
		254 {
			switch -- $y {
				47	{ $nscrlist insert end 97 ; set nscreenval 97 }
				197	{ $nscrlist insert end 73 ; set nscreenval 73 }
			}
		}
		268 {
			switch -- $y {
				52	{ $nscrlist insert end 96 ; set nscreenval 96 }
				202	{ $nscrlist insert end 72 ; set nscreenval 72 }
			}
		}
		280 {
			switch -- $y {
				57	{ $nscrlist insert end 95 ; set nscreenval 95 }
				207	{ $nscrlist insert end 71 ; set nscreenval 71 }
			}
		}
		296 {
			switch -- $y {
				57	{ $nscrlist insert end 94 ; set nscreenval 94 }
				207	{ $nscrlist insert end 70 ; set nscreenval 70 }
			}
		}
		308 {
			switch -- $y {
				62	{ $nscrlist insert end 93 ; set nscreenval 93 }
				212	{ $nscrlist insert end 69 ; set nscreenval 69 }
			}
		}
		324 {
			switch -- $y {
				62	{ $nscrlist insert end 92 ; set nscreenval 92 }
				212	{ $nscrlist insert end 68 ; set nscreenval 68 }
			}
		}
		336 {
			switch -- $y {
				67	{ $nscrlist insert end 91 ; set nscreenval 91 }
				217	{ $nscrlist insert end 67 ; set nscreenval 67 }
			}
		}
		352 {
			switch -- $y {
				67	{ $nscrlist insert end 90 ; set nscreenval 90 }
				217	{ $nscrlist insert end 66 ; set nscreenval 66 }
			}
		}
		365 {
			switch -- $y {
				72	{ $nscrlist insert end 89 ; set nscreenval 89 }
				222	{ $nscrlist insert end 65 ; set nscreenval 65 }
			}
		}
		378 {
			switch -- $y {
				77	{ $nscrlist insert end 88 ; set nscreenval 88 }
				227	{ $nscrlist insert end 64 ; set nscreenval 64 }
			}
		}
		394 {
			switch -- $y {
				77	{ $nscrlist insert end 87 ; set nscreenval 87 }
				227	{ $nscrlist insert end 63 ; set nscreenval 63 }
			}
		}
		406 {
			switch -- $y {
				82	{ $nscrlist insert end 86 ; set nscreenval 86 }
				232	{ $nscrlist insert end 62 ; set nscreenval 62 }
			}
		}
		422 {
			switch -- $y {
				82	{ $nscrlist insert end 85 ; set nscreenval 85 }
				232	{ $nscrlist insert end 61 ; set nscreenval 61 }
			}
		}
		435 {
			switch -- $y {
				87	{ $nscrlist insert end 84 ; set nscreenval 84 }
				237	{ $nscrlist insert end 60 ; set nscreenval 60 }
				387	{ $nscrlist insert end 36 ; set nscreenval 36 }
			}
		}
		448 {
			switch -- $y {
				242	{ $nscrlist insert end 59 ; set nscreenval 59 }
				392	{ $nscrlist insert end 35 ; set nscreenval 35 }
			}
		}
		464 {
			switch -- $y {
				242	{ $nscrlist insert end 58 ; set nscreenval 58 }
				392	{ $nscrlist insert end 34 ; set nscreenval 34 }
			}
		}
		476 {
			switch -- $y {
				247	{ $nscrlist insert end 57 ; set nscreenval 57 }
				397	{ $nscrlist insert end 33 ; set nscreenval 33 }
			}
		}
		492 {
			switch -- $y {
				247	{ $nscrlist insert end 56 ; set nscreenval 56 }
				397	{ $nscrlist insert end 32 ; set nscreenval 32 }
			}
		}
		504 {
			switch -- $y {
				252	{ $nscrlist insert end 55 ; set nscreenval 55 }
				402	{ $nscrlist insert end 31 ; set nscreenval 31 }
			}
		}
		520 {
			switch -- $y {
				252	{ $nscrlist insert end 54 ; set nscreenval 54 }
				402	{ $nscrlist insert end 30 ; set nscreenval 30 }
			}
		}
		533 {
			switch -- $y {
				257	{ $nscrlist insert end 53 ; set nscreenval 53 }
				407	{ $nscrlist insert end 29 ; set nscreenval 29 }
			}
		}
		546 {
			switch -- $y {
				262	{ $nscrlist insert end 52 ; set nscreenval 52 }
				412	{ $nscrlist insert end 28 ; set nscreenval 28 }
			}
		}
		562 {
			switch -- $y {
				262	{ $nscrlist insert end 51 ; set nscreenval 51 }
				412	{ $nscrlist insert end 27 ; set nscreenval 27 }
			}
		}
		574 {
			switch -- $y {
				267	{ $nscrlist insert end 50 ; set nscreenval 50 }
				417	{ $nscrlist insert end 26 ; set nscreenval 26 }
			}
		}
		590 {
			switch -- $y {
				267	{ $nscrlist insert end 49 ; set nscreenval 49 }
				417	{ $nscrlist insert end 25 ; set nscreenval 25 }
			}
		}
		603 {
			switch -- $y {
				272	{ $nscrlist insert end 48 ; set nscreenval 48 }
				422	{ $nscrlist insert end 24 ; set nscreenval 24 }
			}
		}
		616 {
			switch -- $y {
				277	{ $nscrlist insert end 47 ; set nscreenval 47 }
				427	{ $nscrlist insert end 23 ; set nscreenval 23 }
			}
		}
		632 {
			switch -- $y {
				277	{ $nscrlist insert end 46 ; set nscreenval 46 }
				427	{ $nscrlist insert end 22 ; set nscreenval 22 }
			}
		}
		644 {
			switch -- $y {
				282	{ $nscrlist insert end 45 ; set nscreenval 45 }
				432	{ $nscrlist insert end 21 ; set nscreenval 21 }
			}
		}
		660 {
			switch -- $y {
				282	{ $nscrlist insert end 44 ; set nscreenval 44 }
				432	{ $nscrlist insert end 20 ; set nscreenval 20 }
			}
		}
		672 {
			switch -- $y {
				287	{ $nscrlist insert end 43 ; set nscreenval 43 }
				437	{ $nscrlist insert end 19 ; set nscreenval 19 }
			}
		}
		688 {
			switch -- $y {
				287	{ $nscrlist insert end 42 ; set nscreenval 42 }
				437	{ $nscrlist insert end 18 ; set nscreenval 18 }
			}
		}
		701 {
			switch -- $y {
				292	{ $nscrlist insert end 41 ; set nscreenval 41 }
				442	{ $nscrlist insert end 17 ; set nscreenval 17 }
			}
		}
		714 {
			switch -- $y {
				297	{ $nscrlist insert end 40 ; set nscreenval 40 }
				447	{ $nscrlist insert end 16 ; set nscreenval 16 }
			}
		}
		730 {
			switch -- $y {
				297	{ $nscrlist insert end 39 ; set nscreenval 39 }
				447	{ $nscrlist insert end 15 ; set nscreenval 15 }
			}
		}
		742 {
			switch -- $y {
				302	{ $nscrlist insert end 38 ; set nscreenval 38 }
				452	{ $nscrlist insert end 14 ; set nscreenval 14 }
			}
		}
		758 {
			switch -- $y {
				302	{ $nscrlist insert end 37 ; set nscreenval 37 }
				452	{ $nscrlist insert end 13 ; set nscreenval 13 }
			}
		}
		770 {
			switch -- $y {
				307	{ $nscrlist insert end 36 ; set nscreenval 36 }
				457	{ $nscrlist insert end 12 ; set nscreenval 12 }
			}
		}
	}
	incr nscreencnt
	$nscrlist yview moveto 1.0
}

#------ Convert screen position to NOTE name

proc NoteFromNoteGraphic {w xx yy} {
	global nscreen nscreenval nscreencnt nscrlist

	set obj [$nscreen find closest $xx $yy]
	set coords [$nscreen coords $obj]
	set x [expr int([lindex $coords 0])]
	set y [expr int([lindex $coords 1])]
	switch -- $x {
		100 {
			switch -- $y {
				17	{ $nscrlist insert end C4 ; set nscreenval C4 }
				167	{ $nscrlist insert end C2 ; set nscreenval C2 }
			}
		}
		112 {
			switch -- $y {
				22	{ $nscrlist insert end B3 ; set nscreenval B3 }
				172	{ $nscrlist insert end B1 ; set nscreenval B1 }
			}
		}
		128 {
			switch -- $y {
				22	{ $nscrlist insert end Bb3 ; set nscreenval Bb3 }
				172	{ $nscrlist insert end Bb1 ; set nscreenval Bb1 }
			}
		}
		140 {
			switch -- $y {
				27	{ $nscrlist insert end A3 ; set nscreenval A3 }
				177	{ $nscrlist insert end A1 ; set nscreenval A1 }
			}
		}
		156 {
			switch -- $y {
				27	{ $nscrlist insert end Ab3 ; set nscreenval Ab3 }
				177	{ $nscrlist insert end Ab1 ; set nscreenval Ab1 }
			}
		}
		168 {
			switch -- $y {
				32	{ $nscrlist insert end G3 ; set nscreenval G3 }
				182	{ $nscrlist insert end G1 ; set nscreenval G1 }
			}
		}
		184 {
			switch -- $y {
				32	{ $nscrlist insert end F#3 ; set nscreenval F#3 }
				182	{ $nscrlist insert end F#1 ; set nscreenval F#1 }
			}
		}
		198 {
			switch -- $y {
				37	{ $nscrlist insert end F3 ; set nscreenval F3 }
				187	{ $nscrlist insert end F1 ; set nscreenval F1 }
			}
		}
		210 {
			switch -- $y {
				42	{ $nscrlist insert end E3 ; set nscreenval E3 }
				192	{ $nscrlist insert end E1 ; set nscreenval E1 }
			}
		}
		226 {
			switch -- $y {
				42	{ $nscrlist insert end Eb3 ; set nscreenval Eb3 }
				192	{ $nscrlist insert end Eb1 ; set nscreenval Eb1 }
			}
		}
		238 {
			switch -- $y {
				47	{ $nscrlist insert end D3 ; set nscreenval D3 }
				197	{ $nscrlist insert end D1 ; set nscreenval D1 }
			}
		}
		254 {
			switch -- $y {
				47	{ $nscrlist insert end C#3 ; set nscreenval C#3 }
				197	{ $nscrlist insert end C#1 ; set nscreenval C#1 }
			}
		}
		268 {
			switch -- $y {
				52	{ $nscrlist insert end C3 ; set nscreenval C3 }
				202	{ $nscrlist insert end C1 ; set nscreenval C1 }
			}
		}
		280 {
			switch -- $y {
				57	{ $nscrlist insert end B2 ; set nscreenval B2 }
				207	{ $nscrlist insert end B0 ; set nscreenval B0 }
			}
		}
		296 {
			switch -- $y {
				57	{ $nscrlist insert end Bb2 ; set nscreenval Bb2 }
				207	{ $nscrlist insert end Bb0 ; set nscreenval Bb0 }
			}
		}
		308 {
			switch -- $y {
				62	{ $nscrlist insert end A2 ; set nscreenval A2 }
				212	{ $nscrlist insert end A0 ; set nscreenval A0 }
			}
		}
		324 {
			switch -- $y {
				62	{ $nscrlist insert end Ab2 ; set nscreenval Ab2 }
				212	{ $nscrlist insert end Ab0 ; set nscreenval Ab0 }
			}
		}
		336 {
			switch -- $y {
				67	{ $nscrlist insert end G2 ; set nscreenval G2 }
				217	{ $nscrlist insert end G0 ; set nscreenval G0 }
			}
		}
		352 {
			switch -- $y {
				67	{ $nscrlist insert end F#2 ; set nscreenval F#2 }
				217	{ $nscrlist insert end F#0 ; set nscreenval F#0 }
			}
		}
		365 {
			switch -- $y {
				72	{ $nscrlist insert end F2 ; set nscreenval F2 }
				222	{ $nscrlist insert end F0 ; set nscreenval F0 }
			}
		}
		378 {
			switch -- $y {
				77	{ $nscrlist insert end E2 ; set nscreenval E2 }
				227	{ $nscrlist insert end E0 ; set nscreenval E0 }
			}
		}
		394 {
			switch -- $y {
				77	{ $nscrlist insert end Eb2 ; set nscreenval Eb2 }
				227	{ $nscrlist insert end Eb0 ; set nscreenval Eb0 }
			}
		}
		406 {
			switch -- $y {
				82	{ $nscrlist insert end D2 ; set nscreenval D2 }
				232	{ $nscrlist insert end D0 ; set nscreenval D0 }
			}
		}
		422 {
			switch -- $y {
				82	{ $nscrlist insert end C#2 ; set nscreenval C#2 }
				232	{ $nscrlist insert end C#0 ; set nscreenval C#0 }
			}
		}
		435 {
			switch -- $y {
				87	{ $nscrlist insert end C2 ; set nscreenval C2 }
				237	{ $nscrlist insert end C0 ; set nscreenval C0 }
				387	{ $nscrlist insert end C-2 ; set nscreenval C-2 }
			}
		}
		448 {
			switch -- $y {
				242	{ $nscrlist insert end B-1 ; set nscreenval B-1 }
				392	{ $nscrlist insert end B-3 ; set nscreenval B-3 }
			}
		}
		464 {
			switch -- $y {
				242	{ $nscrlist insert end Bb-1 ; set nscreenval Bb-1 }
				392	{ $nscrlist insert end Bb-3 ; set nscreenval Bb-3 }
			}
		}
		476 {
			switch -- $y {
				247	{ $nscrlist insert end A-1 ; set nscreenval A-1 }
				397	{ $nscrlist insert end A-3 ; set nscreenval A-3 }
			}
		}
		492 {
			switch -- $y {
				247	{ $nscrlist insert end Ab-1 ; set nscreenval Ab-1 }
				397	{ $nscrlist insert end Ab-3 ; set nscreenval Ab-3 }
			}
		}
		504 {
			switch -- $y {
				252	{ $nscrlist insert end G-1 ; set nscreenval G-1 }
				402	{ $nscrlist insert end G-3 ; set nscreenval G-3 }
			}
		}
		520 {
			switch -- $y {
				252	{ $nscrlist insert end F#-1 ; set nscreenval F#-1 }
				402	{ $nscrlist insert end F#-3 ; set nscreenval F#-3 }
			}
		}
		533 {
			switch -- $y {
				257	{ $nscrlist insert end F-1 ; set nscreenval F-1 }
				407	{ $nscrlist insert end F-3 ; set nscreenval F-3 }
			}
		}
		546 {
			switch -- $y {
				262	{ $nscrlist insert end E-1 ; set nscreenval E-1 }
				412	{ $nscrlist insert end E-3 ; set nscreenval E-3 }
			}
		}
		562 {
			switch -- $y {
				262	{ $nscrlist insert end Eb-1 ; set nscreenval Eb-1 }
				412	{ $nscrlist insert end Eb-3 ; set nscreenval Eb-3 }
			}
		}
		574 {
			switch -- $y {
				267	{ $nscrlist insert end D-1 ; set nscreenval D-1 }
				417	{ $nscrlist insert end D-3 ; set nscreenval D-3 }
			}
		}
		590 {
			switch -- $y {
				267	{ $nscrlist insert end C#-1 ; set nscreenval C#-1 }
				417	{ $nscrlist insert end C#-3 ; set nscreenval C#-3 }
			}
		}
		603 {
			switch -- $y {
				272	{ $nscrlist insert end C-1 ; set nscreenval C-1 }
				422	{ $nscrlist insert end C-3 ; set nscreenval C-3 }
			}
		}
		616 {
			switch -- $y {
				277	{ $nscrlist insert end B-2 ; set nscreenval B-2 }
				427	{ $nscrlist insert end B-4 ; set nscreenval B-4 }
			}
		}
		632 {
			switch -- $y {
				277	{ $nscrlist insert end Bb-2 ; set nscreenval Bb-2 }
				427	{ $nscrlist insert end Bb-4 ; set nscreenval Bb-4 }
			}
		}
		644 {
			switch -- $y {
				282	{ $nscrlist insert end A-2 ; set nscreenval A-2 }
				432	{ $nscrlist insert end A-4 ; set nscreenval A-4 }
			}
		}
		660 {
			switch -- $y {
				282	{ $nscrlist insert end Ab-2 ; set nscreenval Ab-2 }
				432	{ $nscrlist insert end Ab-4 ; set nscreenval Ab-4 }
			}
		}
		672 {
			switch -- $y {
				287	{ $nscrlist insert end G-2 ; set nscreenval G-2 }
				437	{ $nscrlist insert end G-4 ; set nscreenval G-4 }
			}
		}
		688 {
			switch -- $y {
				287	{ $nscrlist insert end F#-2 ; set nscreenval F#-2 }
				437	{ $nscrlist insert end F#-4 ; set nscreenval F#-4 }
			}
		}
		701 {
			switch -- $y {
				292	{ $nscrlist insert end F-2 ; set nscreenval F-2 }
				442	{ $nscrlist insert end F-4 ; set nscreenval F-4 }
			}
		}
		714 {
			switch -- $y {
				297	{ $nscrlist insert end E-2 ; set nscreenval E-2 }
				447	{ $nscrlist insert end E-4 ; set nscreenval E-4 }
			}
		}
		730 {
			switch -- $y {
				297	{ $nscrlist insert end Eb-2 ; set nscreenval Eb-2 }
				447	{ $nscrlist insert end Eb-4 ; set nscreenval Eb-4 }
			}
		}
		742 {
			switch -- $y {
				302	{ $nscrlist insert end D-2 ; set nscreenval D-2 }
				452	{ $nscrlist insert end D-4 ; set nscreenval D-4 }
			}
		}
		758 {
			switch -- $y {
				302	{ $nscrlist insert end C#-2 ; set nscreenval C#-2 }
				452	{ $nscrlist insert end C#-4 ; set nscreenval C#-4 }
			}
		}
		770 {
			switch -- $y {
				307	{ $nscrlist insert end C-2 ; set nscreenval C-2 }
				457	{ $nscrlist insert end C-4 ; set nscreenval C-4 }
			}
		}
	}
	incr nscreencnt
	$nscrlist yview moveto 1.0
}

#------ Create a column from staff rhythm-notation graphics

proc StaffToBeats {sum} {
	global docol_OK outlines tedit_message last_oc tot_inlines coltype rcolno orig_incolget evv
	global last_cr col_ungapd_numeric tot_outlines lmo orig_inlines insitu record_temacro temacro temacrop
	global rscrlist_out atkrlist_out tabed issum inlines

	set issum $sum

	HaltCursCop

  	set d "disabled"
  	set n "normal"

	if {[info exists tot_inlines] && ($tot_inlines > 0) && ($issum != 2)} {
		SetInout 1
	}
	set lmo "STR"
	lappend lmo $col_ungapd_numeric $sum

	set tb $tabed.bot

	set tedit_message ""
	ForceVal $tabed.message.e $tedit_message
 	$tabed.message.e config -bg [option get . background {}]

	if {$insitu} {
		set ll $tb.icframe.l.list
		set lins "inlines"
		set zfile $evv(COLFILE1)
		if {$issum > 1} {
			set ll2  $tb.ocframe.l.list
			set lins2 "outlines"
			set zfile2 $evv(COLFILE2)
		}
	} else {
		set ll $tb.ocframe.l.list
		set lins "outlines"
		set zfile $evv(COLFILE2)
		if {$issum > 1} {
			set ll2  $tb.icframe.l.list
			set lins2 "inlines"
			set zfile2 $evv(COLFILE1)
		}
	}
	if {!$insitu} {
		set last_oc [$ll get 0 end]
		set last_cr $col_ungapd_numeric
		$tb.kcframe.e config -state $d
		$tb.kcframe.oko config -state $d
		$tb.kcframe.okr config -state $d
		$tb.kcframe.okk config -state $d
		$tb.kcframe.oki config -state $d
		$tb.kcframe.oky config -state $d
		$tb.kcframe.okz config -state $d
		$tb.kcframe.ok config -state $d
	}
	$ll delete 0 end		;#	Clear existing listing of column
	set $lins 0				;#	Set col linecnt to zero
	if {$issum > 1} {
		set orig_inlines 0
		$ll2 delete 0 end
		set $lins2 0
	}

	if {$record_temacro} {
		lappend temacro $lmo
		lappend zxz 0
		lappend zxz 0
		lappend temacrop $zxz
	}
	set docol_OK 0
	EstablishRhythmDisplay $issum
	if {$docol_OK} {
		foreach item $rscrlist_out {
			$ll insert end $item
		}
		if {$issum > 1} {
			foreach item $atkrlist_out {
				$ll2 insert end $item
			}
		}
		catch {close $fileoc}
		catch {close $fileoc2}
		if [catch {open $zfile "w"} fileoc] {
			ForceVal $tabed.message.e  "Cannot open temporary file $zfile to write new column data"
		 	$tabed.message.e config -bg $evv(EMPH)
			$ll delete 0 end		;#	Clear existing listing of output column
			set $lins ""
			if {$issum > 1} {
				$ll2 delete 0 end		;#	Clear existing listing of output column
				set $lins2 ""
			}
		} else {
			set $lins 0
			foreach line [$ll get 0 end] {
				puts $fileoc $line
				incr $lins
			}
			close $fileoc						;#	Write data to file


			if {$issum > 1} {
				if [catch {open $zfile2 "w"} fileoc2] {
					ForceVal $tabed.message.e  "Cannot open temporary file $zfile2 to write 2nd column data"
		 			$tabed.message.e config -bg $evv(EMPH)
					$ll2 delete 0 end		;#	Clear existing listing of output column
					set $lins2 ""
				} else {
					set $lins2 0
					foreach line [$ll2 get 0 end] {
						puts $fileoc2 $line
						incr $lins2
					}
					close $fileoc2
				}
			}
			if {!$insitu} {
				$tb.kcframe.oky config -state $n
				$tb.kcframe.okz config -state $n
				if {[info exists tot_inlines] && ($tot_inlines > 0)} {
					if {$outlines == $orig_inlines} {
						SetKCState "o"
						ForceVal $tb.kcframe.e $rcolno
					} elseif {$outlines == $tot_inlines} {
						set coltype "i"
						$tb.kcframe.oki config -state $n
						$tb.kcframe.oko config -state $d
						$tb.kcframe.okr config -state $n
						set rcolno $orig_incolget
						ForceVal $tb.kcframe.e $rcolno
						$tb.kcframe.e config -state $n
					} else {
						SetKCState "k"
					}
				} elseif {[info exists tot_outlines] && ($tot_outlines > 0) && ($outlines == $tot_outlines)} {
					SetKCState "i"
				} else {
					SetKCState "k"
				}
				$tb.kcframe.okk config -state $n
				$tb.kcframe.ok config -state $n
			} else {
				set orig_incolget ""
				if {($outlines > 0) && ($coltype == "o")} {
					SetKCState "i"
				}
			}
		}
	} else {
		$ll delete 0 end		;#	Clear existing listing of output 
		set $lins ""
		if {$issum > 1} {
			$ll2 delete 0 end		;#	Clear other existing listing
			set $lins2 ""
		}
	}
}

#------ Establish interactive rhythm-notation display

proc EstablishRhythmDisplay {issum} {
	global pr_rscreen rsrclist rscrlist_out rscreenval rfilename rscreen rscreencnt last_rscreencnt docol_OK evv
	global small_screen rstaff last_rscreensum rscreensum atkclist atkrlist_out 

	if [Dlg_Create .rhythmscreen "Notes to beat-counts convertor" "set pr_rscreen 0" -width 48 -borderwidth $evv(SBDR)] {

		if {$small_screen} {
			set can [Scrolled_Canvas .rhythmscreen.c -width $evv(SMALL_WIDTH) -height $evv(SMALL_HEIGHT) \
								-scrollregion "0 0 512 285"]
			pack .rhythmscreen.c -side top -fill x -expand true
			set f [frame $can.f -bd 0]
			$can create window 0 0 -anchor nw -window $f
			set rstaff $f
		} else {
			set rstaff .rhythmscreen
		}	
		set b [frame $rstaff.btns -borderwidth 0]
 
		set last_rscreencnt 0
		entry  $b.val	  -textvariable rscreenval -width 24 -state disabled
		button $b.abdn 	  -text "Close" 		  			-command "set pr_rscreen 0" -highlightbackground [option get . background {}]
		button $b.save 	  -text "Save Values" 				-command "set pr_rscreen 1" -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $b.restart -text "Start Again" 				-command "set pr_rscreen 2" -highlightbackground [option get . background {}]
		button $b.baktrak -text "Remove last value entered" -command "set pr_rscreen 3" -highlightbackground [option get . background {}]

		pack $b.abdn -side right -padx 2
		pack $b.save $b.val	$b.baktrak $b.restart -side left -padx 2

		#	CANVAS AND VALUE LISTING
		set sl [frame $rstaff.sl -borderwidth 0]
		set sl2 [frame $rstaff.sl2 -borderwidth 0]
		label $sl.title1 -text "BEAT/nLENGTH" -width 8 -bg $evv(EMPH)
		label $sl.title2 -text "vals" -width 6
		label $sl2.title1 -text "/n" -width 8
		label $sl2.title2 -text "" -width 8
		set rsrclist [Scrolled_Listbox $sl.l -width 6 -height 40 -selectmode single]
		set atkclist [Scrolled_Listbox $sl2.l -width 6 -height 40 -selectmode single]
		pack $sl.title1 $sl.title2 $sl.l -side top
		pack $sl2.title1 $sl2.title2 $sl2.l -side top

		set rscreen [canvas $rstaff.c -height 360 -width 500 -borderwidth 0 \
			-highlightthickness 1 -highlightbackground $evv(SPECIAL)]
		pack $rstaff.btns -side top -fill x 
		pack $rstaff.sl $rstaff.sl2 $rstaff.c -side left -fill both

		set semibreve  [$rscreen create oval 30 30 38 36 -fill [option get . background {}] -tag beats] 
		set minim      [$rscreen create oval 70 30 78 36 -fill [option get . background {}] -tag beats] 
		set crotchet   [$rscreen create oval 110 30 118 36 -fill black -tag beats] 
		set quaver     [$rscreen create oval 150 30 158 36 -fill black -tag beats] 
		set semiquaver [$rscreen create oval 190 30 198 36 -fill black -tag beats] 
		set demisemi   [$rscreen create oval 230 30 238 36 -fill black -tag beats] 

		$rscreen create line 78 33 78 13 -width 1
		$rscreen create line 118 33 118 13 -width 1
		$rscreen create line 158 33 158 13 -width 1
		$rscreen create line 198 33 198 13 -width 1
		$rscreen create line 238 33 238 13 -width 1

		$rscreen create line 158 13 163 20 -width 1
		$rscreen create line 198 13 203 20 -width 1
		$rscreen create line 198 16 203 23 -width 1
		$rscreen create line 238 13 243 20 -width 1
		$rscreen create line 238 16 243 23 -width 1
		$rscreen create line 238 19 243 26 -width 1

		set dsemibreve  [$rscreen create oval 30 60 38 66 -fill [option get . background {}] -tag beats] 
		set dminim      [$rscreen create oval 70 60 78 66 -fill [option get . background {}] -tag beats] 
		set dcrotchet   [$rscreen create oval 110 60 118 66 -fill black -tag beats] 
		set dquaver     [$rscreen create oval 150 60 158 66 -fill black -tag beats] 
		set dsemiquaver [$rscreen create oval 190 60 198 66 -fill black -tag beats] 

		$rscreen create line 78 63 78 43 -width 1
		$rscreen create line 118 63 118 43 -width 1
		$rscreen create line 158 63 158 43 -width 1
		$rscreen create line 198 63 198 43 -width 1

		$rscreen create oval 41 63 43 65 -fill black
		$rscreen create oval 81 63 83 65 -fill black
		$rscreen create oval 121 63 123 65 -fill black
		$rscreen create oval 161 63 163 65 -fill black
		$rscreen create oval 201 63 203 65 -fill black

		$rscreen create line 158 43 163 50 -width 1
		$rscreen create line 198 43 203 50 -width 1
		$rscreen create line 198 46 203 53 -width 1

		set ddsemibreve  [$rscreen create oval 30 90 38 96 -fill [option get . background {}] -tag beats] 
		set ddminim      [$rscreen create oval 70 90 78 96 -fill [option get . background {}] -tag beats] 
		set ddcrotchet   [$rscreen create oval 110 90 118 96 -fill black -tag beats] 
		set ddquaver     [$rscreen create oval 150 90 158 96 -fill black -tag beats] 

		$rscreen create line 78 93 78 73 -width 1
		$rscreen create line 118 93 118 73 -width 1
		$rscreen create line 158 93 158 73 -width 1

		$rscreen create oval 41 93 43 95 -fill black
		$rscreen create oval 81 93 83 95 -fill black
		$rscreen create oval 121 93 123 95 -fill black
		$rscreen create oval 161 93 163 95 -fill black

		$rscreen create oval 44 93 46 95 -fill black
		$rscreen create oval 84 93 86 95 -fill black
		$rscreen create oval 124 93 126 95 -fill black
		$rscreen create oval 164 93 166 95 -fill black

		$rscreen create line 158 73 163 80 -width 1

######## QUAVER BEAMS

		set bmquaver1a  [$rscreen create oval 30 130 38 136 -fill black -tag beats] 
		set bmquaver1b  [$rscreen create oval 45 130 53 136 -fill black -tag beats] 
		$rscreen create line 38 133 38 116 -width 1
		$rscreen create line 53 133 53 116 -width 1
		$rscreen create line 39 116 53 116 -width 2

		set bmquaver2a  [$rscreen create oval 70 130 78 136 -fill black -tag beats] 
		set bmquaver2b  [$rscreen create oval 90 130 98 136 -fill black -tag beats] 
		$rscreen create line 78 133 78 116 -width 1
		$rscreen create line 98 133 98 116 -width 1
		$rscreen create line 79 116 98 116 -width 2

		$rscreen create oval 81 133 83 135 -fill black
		$rscreen create line 94 119 98 119 -width 2

		set bmquaver3a  [$rscreen create oval 110 130 118 136 -fill black -tag beats] 
		set bmquaver3b  [$rscreen create oval 120 130 128 136 -fill black -tag beats] 
		$rscreen create line 118 133 118 116 -width 1
		$rscreen create line 128 133 128 116 -width 1
		$rscreen create line 119 116 128 116 -width 2

		$rscreen create oval 131 133 133 135 -fill black
		$rscreen create line 119 119 122 119 -width 2

		set bmquaver4a  [$rscreen create oval 150 130 158 136 -fill black -tag beats] 
		set bmquaver4b  [$rscreen create oval 165 130 173 136 -fill black -tag beats] 
		set bmquaver4c  [$rscreen create oval 175 130 183 136 -fill black -tag beats] 
		$rscreen create line 158 133 158 116 -width 1
		$rscreen create line 173 133 173 116 -width 1
		$rscreen create line 183 133 183 116 -width 1
		$rscreen create line 159 116 183 116 -width 2
		$rscreen create line 173 119 183 119 -width 2

		set bmquaver5a  [$rscreen create oval 200 130 208 136 -fill black -tag beats] 
		set bmquaver5b  [$rscreen create oval 210 130 218 136 -fill black -tag beats] 
		set bmquaver5c  [$rscreen create oval 225 130 233 136 -fill black -tag beats] 
		$rscreen create line 208 133 208 116 -width 1
		$rscreen create line 218 133 218 116 -width 1
		$rscreen create line 233 133 233 116 -width 1
		$rscreen create line 209 116 233 116 -width 2
		$rscreen create line 209 119 218 119 -width 2

		set bmquaver6a  [$rscreen create oval 250 130 258 136 -fill black -tag beats] 
		set bmquaver6b  [$rscreen create oval 260 130 268 136 -fill black -tag beats] 
		set bmquaver6c  [$rscreen create oval 275 130 283 136 -fill black -tag beats] 
		$rscreen create line 258 133 258 116 -width 1
		$rscreen create line 268 133 268 116 -width 1
		$rscreen create line 283 133 283 116 -width 1
		$rscreen create line 259 116 283 116 -width 2
		$rscreen create line 259 119 262 119 -width 2
		$rscreen create line 279 119 283 119 -width 2

		set bmquaver8a  [$rscreen create oval 370 130 378 136 -fill black -tag beats] 
		set bmquaver8b  [$rscreen create oval 380 130 388 136 -fill black -tag beats] 
		set bmquaver8c  [$rscreen create oval 390 130 398 136 -fill black -tag beats] 
		set bmquaver8c  [$rscreen create oval 400 130 408 136 -fill black -tag beats] 
		$rscreen create line 378 133 378 116 -width 1
		$rscreen create line 388 133 388 116 -width 1
		$rscreen create line 398 133 398 116 -width 1
		$rscreen create line 408 133 408 116 -width 1
		$rscreen create line 379 116 408 116 -width 2

######## SEMIQUAVER BEAMS

		set bmsquaver1a  [$rscreen create oval 30 170 38 176 -fill black -tag beats] 
		set bmsquaver1b  [$rscreen create oval 45 170 53 176 -fill black -tag beats] 
		$rscreen create line 38 173 38 153 -width 1
		$rscreen create line 53 173 53 153 -width 1
		$rscreen create line 39 156 53 156 -width 2
		$rscreen create line 39 153 53 153 -width 2

		set bmsquaver2a  [$rscreen create oval 70 170 78 176 -fill black -tag beats] 
		set bmsquaver2b  [$rscreen create oval 90 170 98 176 -fill black -tag beats] 
		$rscreen create line 78 173 78 153 -width 1
		$rscreen create line 98 173 98 153 -width 1
		$rscreen create line 79 156 98 156 -width 2
		$rscreen create line 79 153 98 153 -width 2

		$rscreen create oval 81 173 83 175 -fill black
		$rscreen create line 94 159 98 159 -width 2

		set bmsquaver3a  [$rscreen create oval 110 170 118 176 -fill black -tag beats] 
		set bmsquaver3b  [$rscreen create oval 120 170 128 176 -fill black -tag beats] 
		$rscreen create line 118 173 118 153 -width 1
		$rscreen create line 128 173 128 153 -width 1
		$rscreen create line 119 156 128 156 -width 2
		$rscreen create line 119 153 128 153 -width 2

		$rscreen create oval 131 173 133 175 -fill black
		$rscreen create line 119 159 122 159 -width 2

		set bmsquaver4a  [$rscreen create oval 150 170 158 176 -fill black -tag beats] 
		set bmsquaver4b  [$rscreen create oval 165 170 173 176 -fill black -tag beats] 
		set bmsquaver4c  [$rscreen create oval 175 170 183 176 -fill black -tag beats] 
		$rscreen create line 158 173 158 153 -width 1
		$rscreen create line 173 173 173 153 -width 1
		$rscreen create line 183 173 183 153 -width 1
		$rscreen create line 159 156 183 156 -width 2
		$rscreen create line 173 159 183 159 -width 2
		$rscreen create line 159 153 183 153 -width 2

		set bmsquaver5a  [$rscreen create oval 200 170 208 176 -fill black -tag beats] 
		set bmsquaver5b  [$rscreen create oval 210 170 218 176 -fill black -tag beats] 
		set bmsquaver5c  [$rscreen create oval 225 170 233 176 -fill black -tag beats] 
		$rscreen create line 208 173 208 153 -width 1
		$rscreen create line 218 173 218 153 -width 1
		$rscreen create line 233 173 233 153 -width 1
		$rscreen create line 209 156 233 156 -width 2
		$rscreen create line 209 159 218 159 -width 2
		$rscreen create line 209 153 233 153 -width 2

		set bmsquaver6a  [$rscreen create oval 250 170 258 176 -fill black -tag beats] 
		set bmsquaver6b  [$rscreen create oval 260 170 268 176 -fill black -tag beats] 
		set bmsquaver6c  [$rscreen create oval 275 170 283 176 -fill black -tag beats] 
		$rscreen create line 258 173 258 153 -width 1
		$rscreen create line 268 173 268 153 -width 1
		$rscreen create line 283 173 283 153 -width 1
		$rscreen create line 259 156 283 156 -width 2
		$rscreen create line 259 159 262 159 -width 2
		$rscreen create line 279 159 283 159 -width 2
		$rscreen create line 259 153 283 153 -width 2

		set bmsquaver8a  [$rscreen create oval 370 170 378 176 -fill black -tag beats] 
		set bmsquaver8b  [$rscreen create oval 380 170 388 176 -fill black -tag beats] 
		set bmsquaver8c  [$rscreen create oval 390 170 398 176 -fill black -tag beats] 
		set bmsquaver8c  [$rscreen create oval 400 170 408 176 -fill black -tag beats] 
		$rscreen create line 378 173 378 153 -width 1
		$rscreen create line 388 173 388 153 -width 1
		$rscreen create line 398 173 398 153 -width 1
		$rscreen create line 408 173 408 153 -width 1
		$rscreen create line 379 156 408 156 -width 2
		$rscreen create line 379 153 408 153 -width 2

######## QUAVER TRIPLET BEAMS

		set tbmquaver1a  [$rscreen create oval 30 220 38 226 -fill black -tag beats] 
		set tbmquaver1b  [$rscreen create oval 45 220 53 226 -fill black -tag beats] 
		set tbmquaver1c  [$rscreen create oval 60 220 68 226 -fill black -tag beats] 
		$rscreen create line 38 223 38 203 -width 1
		$rscreen create line 53 223 53 203 -width 1
		$rscreen create line 68 223 68 203 -width 1
		$rscreen create line 39 203 68 203 -width 2

		set tbmquaver2a  [$rscreen create oval 85  220 93  226 -fill black -tag beats] 
		set tbmquaver2b  [$rscreen create oval 115 220 123 226 -fill black -tag beats] 
		$rscreen create line 93  223 93  203 -width 1
		$rscreen create line 123 223 123 203 -width 1
		$rscreen create line 123 203 128 210 -width 1
		$rscreen create arc  83  193 133 243 -start 125 -extent -70 -style arc -outline black -width 1

		set tbmquaver3a  [$rscreen create oval 140 220 148 226 -fill black -tag beats] 
		set tbmquaver3b  [$rscreen create oval 155 220 163 226 -fill black -tag beats] 
		$rscreen create line 148 223 148 203 -width 1
		$rscreen create line 163 223 163 203 -width 1
		$rscreen create line 148 203 153 210 -width 1
		$rscreen create arc  133 193 188 243 -start 125 -extent -70 -style arc -outline black -width 1

		set tbmquaver4a  [$rscreen create oval 195 220 203 226 -fill black -tag beats] 
		set tbmquaver4b  [$rscreen create oval 215 220 223 226 -fill black -tag beats] 
		set tbmquaver4c  [$rscreen create oval 225 220 233 226 -fill black -tag beats] 
		$rscreen create line 203 223 203 203 -width 1
		$rscreen create line 223 223 223 203 -width 1
		$rscreen create line 233 223 233 203 -width 1
		$rscreen create line 204 203 233 203 -width 2

		$rscreen create oval 206 222 208 224 -fill black
		$rscreen create line 218 206 223 206 -width 2

		set tbmquaver5a  [$rscreen create oval 250 220 258 226 -fill black -tag beats] 
		set tbmquaver5b  [$rscreen create oval 260 220 268 226 -fill black -tag beats] 
		set tbmquaver5c  [$rscreen create oval 280 220 288 226 -fill black -tag beats] 
		$rscreen create line 258 223 258 203 -width 1
		$rscreen create line 268 223 268 203 -width 1
		$rscreen create line 288 223 288 203 -width 1
		$rscreen create line 259 203 288 203 -width 2

		$rscreen create oval 271 222 273 224 -fill black
		$rscreen create line 259 206 263 206 -width 2

		set tbmquaver6a  [$rscreen create oval 305 220 313 226 -fill black -tag beats] 
		set tbmquaver6b  [$rscreen create oval 320 220 328 226 -fill black -tag beats] 
		set tbmquaver6c  [$rscreen create oval 340 220 348 226 -fill black -tag beats] 
		$rscreen create line 313 223 313 203 -width 1
		$rscreen create line 328 223 328 203 -width 1
		$rscreen create line 348 223 348 203 -width 1
		$rscreen create line 314 203 348 203 -width 2

		$rscreen create oval 331 222 333 224 -fill black
		$rscreen create line 343 206 348 206 -width 2

		set tbmquaver7a  [$rscreen create oval 365 220 373 226 -fill black -tag beats] 
		set tbmquaver7b  [$rscreen create oval 385 220 393 226 -fill black -tag beats] 
		set tbmquaver7c  [$rscreen create oval 400 220 408 226 -fill black -tag beats] 
		$rscreen create line 373 223 373 203 -width 1
		$rscreen create line 393 223 393 203 -width 1
		$rscreen create line 408 223 408 203 -width 1
		$rscreen create line 374 203 408 203 -width 2

		$rscreen create oval 376 222 378 224 -fill black
		$rscreen create line 403 206 408 206 -width 2

		set tbmquaver8a  [$rscreen create oval 425 220 433 226 -fill black -tag beats] 
		set tbmquaver8b  [$rscreen create oval 435 220 443 226 -fill black -tag beats] 
		set tbmquaver8c  [$rscreen create oval 450 220 458 226 -fill black -tag beats] 
		$rscreen create line 433 223 433 203 -width 1
		$rscreen create line 443 223 443 203 -width 1
		$rscreen create line 458 223 458 203 -width 1
		$rscreen create line 434 203 458 203 -width 2

		$rscreen create oval 461 222 463 224 -fill black
		$rscreen create line 434 206 438 206 -width 2

######## SEMIQUAVER TRIPLET BEAMS

		set tbmsquaver1a  [$rscreen create oval 30 280 38 286 -fill black -tag beats] 
		set tbmsquaver1b  [$rscreen create oval 45 280 53 286 -fill black -tag beats] 
		set tbmsquaver1c  [$rscreen create oval 60 280 68 286 -fill black -tag beats] 
		$rscreen create line 38 283 38 260 -width 1
		$rscreen create line 53 283 53 260 -width 1
		$rscreen create line 68 283 68 260 -width 1
		$rscreen create line 39 263 68 263 -width 2
		$rscreen create line 39 260 68 260 -width 2

		set tbmsquaver2a  [$rscreen create oval 85  280 93  286 -fill black -tag beats] 
		set tbmsquaver2b  [$rscreen create oval 115 280 123 286 -fill black -tag beats] 
		$rscreen create line 93  283 93  260 -width 1
		$rscreen create line 123 283 123 260 -width 1
		$rscreen create line 94  260 123 260 -width 2
		$rscreen create line 118 263 123 263 -width 2

		set tbmsquaver3a  [$rscreen create oval 140 280 148 286 -fill black -tag beats] 
		set tbmsquaver3b  [$rscreen create oval 155 280 163 286 -fill black -tag beats] 
		$rscreen create line 148 283 148 260 -width 1
		$rscreen create line 163 283 163 260 -width 1
		$rscreen create line 149 260 163 260 -width 2
		$rscreen create line 149 263 153 263 -width 2

		set tbmsquaver4a  [$rscreen create oval 195 280 203 286 -fill black -tag beats] 
		set tbmsquaver4b  [$rscreen create oval 215 280 223 286 -fill black -tag beats] 
		set tbmsquaver4c  [$rscreen create oval 225 280 233 286 -fill black -tag beats] 
		$rscreen create line 203 283 203 260 -width 1
		$rscreen create line 223 283 223 260 -width 1
		$rscreen create line 233 283 233 260 -width 1
		$rscreen create line 204 263 233 263 -width 2
		$rscreen create line 204 260 233 260 -width 2

		$rscreen create oval 206 282 208 284 -fill black
		$rscreen create line 218 266 223 266 -width 2

		set tbmsquaver5a  [$rscreen create oval 250 280 258 286 -fill black -tag beats] 
		set tbmsquaver5b  [$rscreen create oval 260 280 268 286 -fill black -tag beats] 
		set tbmsquaver5c  [$rscreen create oval 280 280 288 286 -fill black -tag beats] 
		$rscreen create line 258 283 258 260 -width 1
		$rscreen create line 268 283 268 260 -width 1
		$rscreen create line 288 283 288 260 -width 1
		$rscreen create line 259 263 288 263 -width 2
		$rscreen create line 259 260 288 260 -width 2

		$rscreen create oval 271 282 273 284 -fill black
		$rscreen create line 259 266 263 266 -width 2

		set tbmsquaver6a  [$rscreen create oval 305 280 313 286 -fill black -tag beats] 
		set tbmsquaver6b  [$rscreen create oval 320 280 328 286 -fill black -tag beats] 
		set tbmsquaver6c  [$rscreen create oval 340 280 348 286 -fill black -tag beats] 
		$rscreen create line 313 283 313 260 -width 1
		$rscreen create line 328 283 328 260 -width 1
		$rscreen create line 348 283 348 260 -width 1
		$rscreen create line 314 263 348 263 -width 2
		$rscreen create line 314 260 348 260 -width 2

		$rscreen create oval 331 282 333 284 -fill black
		$rscreen create line 343 266 348 266 -width 2

		set tbmsquaver7a  [$rscreen create oval 365 280 373 286 -fill black -tag beats] 
		set tbmsquaver7b  [$rscreen create oval 385 280 393 286 -fill black -tag beats] 
		set tbmsquaver7c  [$rscreen create oval 400 280 408 286 -fill black -tag beats] 
		$rscreen create line 373 283 373 260 -width 1
		$rscreen create line 393 283 393 260 -width 1
		$rscreen create line 408 283 408 260 -width 1
		$rscreen create line 374 263 408 263 -width 2
		$rscreen create line 374 260 408 260 -width 2

		$rscreen create oval 376 282 378 284 -fill black
		$rscreen create line 403 266 408 266 -width 2

		set tbmsquaver8a  [$rscreen create oval 425 280 433 286 -fill black -tag beats] 
		set tbmsquaver8b  [$rscreen create oval 435 280 443 286 -fill black -tag beats] 
		set tbmsquaver8c  [$rscreen create oval 450 280 458 286 -fill black -tag beats] 
		$rscreen create line 433 283 433 260 -width 1
		$rscreen create line 443 283 443 260 -width 1
		$rscreen create line 458 283 458 260 -width 1
		$rscreen create line 434 263 458 263 -width 2
		$rscreen create line 434 260 458 260 -width 2

		$rscreen create oval 461 282 463 284 -fill black
		$rscreen create line 434 266 438 266 -width 2

###### 3rd-NOTE GROUPS. CROTCHETS

		set tbmtcrotch1a  [$rscreen create oval 30 350 38 356 -fill black -tag beats] 
		set tbmtcrotch1b  [$rscreen create oval 45 350 53 356 -fill black -tag beats] 
		set tbmtcrotch1c  [$rscreen create oval 60 350 68 356 -fill black -tag beats] 
		$rscreen create line 38 353 38 333 -width 1
		$rscreen create line 53 353 53 333 -width 1
		$rscreen create line 68 353 68 333 -width 1
		$rscreen create arc  28 315 78 351 -start 125 -extent -70 -style arc -outline black -width 1
		$rscreen create text 54 325 -text "3" -font {helvetica 9 normal} 

		set tbmtcrotch2a  [$rscreen create oval 85  350 93  356 -fill [option get . background {}] -tag beats] 
		set tbmtcrotch2b  [$rscreen create oval 115 350 123 356 -fill black -tag beats] 
		$rscreen create line 93  353 93  333 -width 1
		$rscreen create line 123 353 123 333 -width 1
		$rscreen create arc  83 315 133 351 -start 125 -extent -70 -style arc -outline black -width 1
		$rscreen create text 108 325 -text "3" -font {helvetica 9 normal} 

		set tbmtcrotch3a  [$rscreen create oval 140  350 148 356 -fill black -tag beats] 
		set tbmtcrotch3b  [$rscreen create oval 155 350  163 356 -fill [option get . background {}] -tag beats] 
		$rscreen create line 148 353 148 333 -width 1
		$rscreen create line 163 353 163 333 -width 1
		$rscreen create arc  138 315 188 351 -start 125 -extent -70 -style arc -outline black -width 1
		$rscreen create text 163 325 -text "3" -font {helvetica 9 normal} 

		set tbmtcrotch4a  [$rscreen create oval 195 350 203 356 -fill black -tag beats] 
		set tbmtcrotch4b  [$rscreen create oval 215 350 223 356 -fill black -tag beats] 
		set tbmtcrotch4c  [$rscreen create oval 225 350 233 356 -fill black -tag beats] 
		$rscreen create line 203 353 203 333 -width 1
		$rscreen create line 223 353 223 333 -width 1
		$rscreen create line 233 353 233 333 -width 1
		$rscreen create line 223 333 228 340 -width 1

		$rscreen create oval 206 352 208 354 -fill black

		$rscreen create arc  193 315 243 351 -start 125 -extent -70 -style arc -outline black -width 1
		$rscreen create text 218 325 -text "3" -font {helvetica 9 normal} 

		set tbmtcrotch5a  [$rscreen create oval 250 350 258 356 -fill black -tag beats] 
		set tbmtcrotch5b  [$rscreen create oval 260 350 268 356 -fill black -tag beats] 
		set tbmtcrotch5c  [$rscreen create oval 280 350 288 356 -fill black -tag beats] 
		$rscreen create line 258 353 258 333 -width 1
		$rscreen create line 268 353 268 333 -width 1
		$rscreen create line 288 353 288 333 -width 1
		$rscreen create line 258 333 263 340 -width 1

		$rscreen create oval 271 352 273 354 -fill black
		$rscreen create arc  248 315 298 351 -start 125 -extent -70 -style arc -outline black -width 1
		$rscreen create text 273 325 -text "3" -font {helvetica 9 normal} 

		set tbmtcrotch6a  [$rscreen create oval 305 350 313 356 -fill black -tag beats] 
		set tbmtcrotch6b  [$rscreen create oval 320 350 328 356 -fill black -tag beats] 
		set tbmtcrotch6c  [$rscreen create oval 340 350 348 356 -fill black -tag beats] 
		$rscreen create line 313 353 313 333 -width 1
		$rscreen create line 328 353 328 333 -width 1
		$rscreen create line 348 353 348 333 -width 1
		$rscreen create line 348 333 353 340 -width 1

		$rscreen create oval 331 352 333 354 -fill black
		$rscreen create arc  303 315 353 351 -start 125 -extent -70 -style arc -outline black -width 1
		$rscreen create text 328 325 -text "3" -font {helvetica 9 normal} 

		set tbmtcrotch7a  [$rscreen create oval 365 350 373 356 -fill black -tag beats] 
		set tbmtcrotch7b  [$rscreen create oval 385 350 393 356 -fill black -tag beats] 
		set tbmtcrotch7c  [$rscreen create oval 400 350 408 356 -fill black -tag beats] 
		$rscreen create line 373 353 373 333 -width 1
		$rscreen create line 393 353 393 333 -width 1
		$rscreen create line 408 353 408 333 -width 1
		$rscreen create line 408 333 413 340 -width 1

		$rscreen create oval 376 352 378 354 -fill black
		$rscreen create arc  363 315 413 351 -start 125 -extent -70 -style arc -outline black -width 1
		$rscreen create text 388 325 -text "3" -font {helvetica 9 normal} 

		set tbmtcrotch8a  [$rscreen create oval 425 350 433 356 -fill black -tag beats] 
		set tbmtcrotch8b  [$rscreen create oval 435 350 443 356 -fill black -tag beats] 
		set tbmtcrotch8c  [$rscreen create oval 450 350 458 356 -fill black -tag beats] 
		$rscreen create line 433 353 433 333 -width 1
		$rscreen create line 443 353 443 333 -width 1
		$rscreen create line 458 353 458 333 -width 1
		$rscreen create line 433 333 438 340 -width 1

		$rscreen create oval 461 352 463 354 -fill black
		$rscreen create arc  423 315 473 351 -start 125 -extent -70 -style arc -outline black -width 1
		$rscreen create text 448 325 -text "3" -font {helvetica 9 normal} 

###### 3rd-NOTE GROUPS

		set tbmtquaver1a  [$rscreen create oval 30 410 38 416 -fill black -tag beats] 
		set tbmtquaver1b  [$rscreen create oval 45 410 53 416 -fill black -tag beats] 
		set tbmtquaver1c  [$rscreen create oval 60 410 68 416 -fill black -tag beats] 
		$rscreen create line 38 413 38 393 -width 1
		$rscreen create line 53 413 53 393 -width 1
		$rscreen create line 68 413 68 393 -width 1
		$rscreen create line 39 393 68 393 -width 2
		$rscreen create arc  28 375 78 411 -start 125 -extent -70 -style arc -outline black -width 1
		$rscreen create text 54 385 -text "3" -font {helvetica 9 normal} 

		set tbmtquaver2a  [$rscreen create oval 85  410 93  416 -fill black -tag beats] 
		set tbmtquaver2b  [$rscreen create oval 115 410 123 416 -fill black -tag beats] 
		$rscreen create line 93  413 93  393 -width 1
		$rscreen create line 123 413 123 393 -width 1
		$rscreen create line 123 393 128 400 -width 1
		$rscreen create arc  83 375 133 411 -start 125 -extent -70 -style arc -outline black -width 1
		$rscreen create text 108 385 -text "3" -font {helvetica 9 normal} 

		set tbmtquaver3a  [$rscreen create oval 140  410 148 416 -fill black -tag beats] 
		set tbmtquaver3b  [$rscreen create oval 155 410  163 416 -fill black -tag beats] 
		$rscreen create line 148 413 148 393 -width 1
		$rscreen create line 163 413 163 393 -width 1
		$rscreen create line 148 393 153 400 -width 1
		$rscreen create arc  138 375 188 411 -start 125 -extent -70 -style arc -outline black -width 1
		$rscreen create text 163 385 -text "3" -font {helvetica 9 normal} 

		set tbmtquaver4a  [$rscreen create oval 195 410 203 416 -fill black -tag beats] 
		set tbmtquaver4b  [$rscreen create oval 215 410 223 416 -fill black -tag beats] 
		set tbmtquaver4c  [$rscreen create oval 225 410 233 416 -fill black -tag beats] 
		$rscreen create line 203 413 203 393 -width 1
		$rscreen create line 223 413 223 393 -width 1
		$rscreen create line 233 413 233 393 -width 1
		$rscreen create line 204 393 233 393 -width 2

		$rscreen create oval 206 412 208 414 -fill black
		$rscreen create line 218 396 222 396 -width 2
		$rscreen create arc  193 375 243 411 -start 125 -extent -70 -style arc -outline black -width 1
		$rscreen create text 218 385 -text "3" -font {helvetica 9 normal} 

		set tbmtquaver5a  [$rscreen create oval 250 410 258 416 -fill black -tag beats] 
		set tbmtquaver5b  [$rscreen create oval 260 410 268 416 -fill black -tag beats] 
		set tbmtquaver5c  [$rscreen create oval 280 410 288 416 -fill black -tag beats] 
		$rscreen create line 258 413 258 393 -width 1
		$rscreen create line 268 413 268 393 -width 1
		$rscreen create line 288 413 288 393 -width 1
		$rscreen create line 259 393 288 393 -width 2

		$rscreen create oval 271 412 273 414 -fill black
		$rscreen create line 259 396 263 396 -width 2
		$rscreen create arc  248 375 298 411 -start 125 -extent -70 -style arc -outline black -width 1
		$rscreen create text 273 385 -text "3" -font {helvetica 9 normal} 

		set tbmtquaver6a  [$rscreen create oval 305 410 313 416 -fill black -tag beats] 
		set tbmtquaver6b  [$rscreen create oval 320 410 328 416 -fill black -tag beats] 
		set tbmtquaver6c  [$rscreen create oval 340 410 348 416 -fill black -tag beats] 
		$rscreen create line 313 413 313 393 -width 1
		$rscreen create line 328 413 328 393 -width 1
		$rscreen create line 348 413 348 393 -width 1
		$rscreen create line 314 393 348 393 -width 2

		$rscreen create oval 331 412 333 414 -fill black
		$rscreen create line 343 396 348 396 -width 2
		$rscreen create arc  303 375 358 411 -start 125 -extent -70 -style arc -outline black -width 1
		$rscreen create text 328 385 -text "3" -font {helvetica 9 normal} 

		set tbmtquaver7a  [$rscreen create oval 365 410 373 416 -fill black -tag beats] 
		set tbmtquaver7b  [$rscreen create oval 385 410 393 416 -fill black -tag beats] 
		set tbmtquaver7c  [$rscreen create oval 400 410 408 416 -fill black -tag beats] 
		$rscreen create line 373 413 373 393 -width 1
		$rscreen create line 393 413 393 393 -width 1
		$rscreen create line 408 413 408 393 -width 1
		$rscreen create line 374 393 408 393 -width 2

		$rscreen create oval 376 412 378 414 -fill black
		$rscreen create line 403 396 408 396 -width 2
		$rscreen create arc  363 375 413 411 -start 125 -extent -70 -style arc -outline black -width 1
		$rscreen create text 388 385 -text "3" -font {helvetica 9 normal} 

		set tbmtquaver8a  [$rscreen create oval 425 410 433 416 -fill black -tag beats] 
		set tbmtquaver8b  [$rscreen create oval 435 410 443 416 -fill black -tag beats] 
		set tbmtquaver8c  [$rscreen create oval 450 410 458 416 -fill black -tag beats] 
		$rscreen create line 433 413 433 393 -width 1
		$rscreen create line 443 413 443 393 -width 1
		$rscreen create line 458 413 458 393 -width 1
		$rscreen create line 434 393 458 393 -width 2

		$rscreen create oval 461 412 463 414 -fill black
		$rscreen create line 434 396 438 396 -width 2
		$rscreen create arc  423 375 473 411 -start 125 -extent -70 -style arc -outline black -width 1
		$rscreen create text 448 385 -text "3" -font {helvetica 9 normal} 

###### 3rd-NOTE SEMIQ GROUPS

		set tbmtsquaver1a  [$rscreen create oval 30 470 38 476 -fill black -tag beats] 
		set tbmtsquaver1b  [$rscreen create oval 45 470 53 476 -fill black -tag beats] 
		set tbmtsquaver1c  [$rscreen create oval 60 470 68 476 -fill black -tag beats] 
		$rscreen create line 38 473 38 450 -width 1
		$rscreen create line 53 473 53 450 -width 1
		$rscreen create line 68 473 68 450 -width 1
		$rscreen create line 39 453 68 453 -width 2
		$rscreen create line 39 450 68 450 -width 2
		$rscreen create arc  28 432 78 468 -start 125 -extent -70 -style arc -outline black -width 1
		$rscreen create text 54 442 -text "3" -font {helvetica 9 normal} 

		set tbmtsquaver2a  [$rscreen create oval 85  470 93  476 -fill black -tag beats] 
		set tbmtsquaver2b  [$rscreen create oval 115 470 123 476 -fill black -tag beats] 
		$rscreen create line 93  473 93  450 -width 1
		$rscreen create line 123 473 123 450 -width 1
		$rscreen create line 94  450 123 450 -width 2
		$rscreen create line 118 453 123 453 -width 2
		$rscreen create arc  83 432 133 468 -start 125 -extent -70 -style arc -outline black -width 1
		$rscreen create text 108 442 -text "3" -font {helvetica 9 normal} 

		set tbmtsquaver3a  [$rscreen create oval 140 470 148 476 -fill black -tag beats] 
		set tbmtsquaver3b  [$rscreen create oval 155 470 163 476 -fill black -tag beats] 
		$rscreen create line 148 473 148 450 -width 1
		$rscreen create line 163 473 163 450 -width 1
		$rscreen create line 149 450 163 450 -width 2
		$rscreen create line 149 453 153 453 -width 2
		$rscreen create arc  138 432 188 468 -start 125 -extent -70 -style arc -outline black -width 1
		$rscreen create text 163 442 -text "3" -font {helvetica 9 normal} 

		set tbmtsquaver4a  [$rscreen create oval 195 470 203 476 -fill black -tag beats] 
		set tbmtsquaver4b  [$rscreen create oval 215 470 223 476 -fill black -tag beats] 
		set tbmtsquaver4c  [$rscreen create oval 225 470 233 476 -fill black -tag beats] 
		$rscreen create line 203 473 203 450 -width 1
		$rscreen create line 223 473 223 450 -width 1
		$rscreen create line 233 473 233 450 -width 1
		$rscreen create line 204 450 233 450 -width 2
		$rscreen create line 204 453 233 453 -width 2

		$rscreen create oval 206 472 208 474 -fill black
		$rscreen create line 218 456 222 456 -width 2
		$rscreen create arc  193 432 243 468 -start 125 -extent -70 -style arc -outline black -width 1
		$rscreen create text 218 442 -text "3" -font {helvetica 9 normal} 

		set tbmtsquaver5a  [$rscreen create oval 250 470 258 476 -fill black -tag beats] 
		set tbmtsquaver5b  [$rscreen create oval 260 470 268 476 -fill black -tag beats] 
		set tbmtsquaver5c  [$rscreen create oval 280 470 288 476 -fill black -tag beats] 
		$rscreen create line 258 473 258 450 -width 1
		$rscreen create line 268 473 268 450 -width 1
		$rscreen create line 288 473 288 450 -width 1
		$rscreen create line 259 450 288 450 -width 2
		$rscreen create line 259 453 288 453 -width 2

		$rscreen create oval 271 472 273 474 -fill black
		$rscreen create line 259 456 263 456 -width 2
		$rscreen create arc  248 432 298 468 -start 125 -extent -70 -style arc -outline black -width 1
		$rscreen create text 273 442 -text "3" -font {helvetica 9 normal} 

		set tbmtsquaver6a  [$rscreen create oval 305 470 313 476 -fill black -tag beats] 
		set tbmtsquaver6b  [$rscreen create oval 320 470 328 476 -fill black -tag beats] 
		set tbmtsquaver6c  [$rscreen create oval 340 470 348 476 -fill black -tag beats] 
		$rscreen create line 313 473 313 450 -width 1
		$rscreen create line 328 473 328 450 -width 1
		$rscreen create line 348 473 348 450 -width 1
		$rscreen create line 314 450 348 450 -width 2
		$rscreen create line 314 453 348 453 -width 2

		$rscreen create oval 331 472 333 474 -fill black
		$rscreen create line 343 456 348 456 -width 2
		$rscreen create arc  303 432 358 468 -start 125 -extent -70 -style arc -outline black -width 1
		$rscreen create text 328 442 -text "3" -font {helvetica 9 normal} 

		set tbmtsquaver7a  [$rscreen create oval 365 470 373 476 -fill black -tag beats] 
		set tbmtsquaver7b  [$rscreen create oval 385 470 393 476 -fill black -tag beats] 
		set tbmtsquaver7c  [$rscreen create oval 400 470 408 476 -fill black -tag beats] 
		$rscreen create line 373 473 373 450 -width 1
		$rscreen create line 393 473 393 450 -width 1
		$rscreen create line 408 473 408 450 -width 1
		$rscreen create line 374 450 408 450 -width 2
		$rscreen create line 374 453 408 453 -width 2

		$rscreen create oval 376 472 378 474 -fill black
		$rscreen create line 403 456 408 456 -width 2
		$rscreen create arc  363 432 413 468 -start 125 -extent -70 -style arc -outline black -width 1
		$rscreen create text 388 442 -text "3" -font {helvetica 9 normal} 

		set tbmtsquaver8a  [$rscreen create oval 425 470 433 476 -fill black -tag beats] 
		set tbmtsquaver8b  [$rscreen create oval 435 470 443 476 -fill black -tag beats] 
		set tbmtsquaver8c  [$rscreen create oval 450 470 458 476 -fill black -tag beats] 
		$rscreen create line 433 473 433 450 -width 1
		$rscreen create line 443 473 443 450 -width 1
		$rscreen create line 458 473 458 450 -width 1
		$rscreen create line 434 450 458 450 -width 2
		$rscreen create line 434 453 458 453 -width 2

		$rscreen create oval 461 472 463 474 -fill black
		$rscreen create line 434 456 438 456 -width 2
		$rscreen create arc  423 432 473 468 -start 125 -extent -70 -style arc -outline black -width 1
		$rscreen create text 448 442 -text "3" -font {helvetica 9 normal} 

		$rscreen create text 250 625 -text "Click On a notehead" -font {helvetica 14 normal}
		$rscreen create text 250 645 -text "to enter NOTE, or NOTEGROUP" -font {helvetica 14 normal}
		$rscreen create text 250 665 -text "Crotchet = 1 beat, in all cases" -font {helvetica 10 normal}

		bind $rscreen <ButtonRelease-1>				{BeatsFromNoteGraphic %W %x %y $issum}
		bind .rhythmscreen <Escape>  {set pr_rscreen 0}
	}	
	switch -- $issum {
		0 {
			wm title .rhythmscreen "Notation to note-lengths convertor"
			$rstaff.sl.title1 config -text "BEAT\nLENGTH"
			$rstaff.sl2.title1 config -text "\n" -bg [option get . background {}]
			catch {$rscreen delete unacc}
		}
		1 {
			wm title .rhythmscreen "Notation to attack-times convertor"
			$rstaff.sl.title1 config -text "BEAT\nTIME"
			$rstaff.sl2.title1 config -text "\n" -bg [option get . background {}]
			catch {$rscreen delete unacc}
		}
		2 {
			wm title .rhythmscreen "Notation to attack-times convertor"
			$rstaff.sl.title1 config -text "BEAT\nTIME"
			$rstaff.sl2.title1 config -text "ATTACK\nPATTERN" -bg $evv(EMPH)

			$rscreen create text 150 530 -text "Unaccented" -font {helvetica 12 normal} -tag unacc
			$rscreen create text 150 560 -text "Unaccented" -font {helvetica 12 normal} -tag unacc
			$rscreen create text 150 590 -text "Unaccented" -font {helvetica 12 normal} -tag unacc

			$rscreen create oval 230 530 238 536 -fill [option get . background {}] -tag unacc
			$rscreen create oval 270 530 278 536 -fill [option get . background {}] -tag unacc
			$rscreen create oval 310 530 318 536 -fill black -tag unacc
			$rscreen create oval 350 530 358 536 -fill black -tag unacc
			$rscreen create oval 390 530 398 536 -fill black -tag unacc
			$rscreen create oval 430 530 438 536 -fill black -tag unacc

			$rscreen create line 278 533 278 513 -width 1 -tag unacc
			$rscreen create line 318 533 318 513 -width 1 -tag unacc
			$rscreen create line 358 533 358 513 -width 1 -tag unacc
			$rscreen create line 398 533 398 513 -width 1 -tag unacc
			$rscreen create line 438 533 438 513 -width 1 -tag unacc

			$rscreen create line 358 513 363 520 -width 1 -tag unacc
			$rscreen create line 398 513 403 520 -width 1 -tag unacc
			$rscreen create line 398 516 403 523 -width 1 -tag unacc
			$rscreen create line 438 513 443 520 -width 1 -tag unacc
			$rscreen create line 438 516 443 523 -width 1 -tag unacc
			$rscreen create line 438 519 443 526 -width 1 -tag unacc

			$rscreen create oval 230 560 238 566 -fill [option get . background {}] -tag unacc
			$rscreen create oval 270 560 278 566 -fill [option get . background {}] -tag unacc
			$rscreen create oval 310 560 318 566 -fill black -tag unacc
			$rscreen create oval 350 560 358 566 -fill black -tag unacc
			$rscreen create oval 390 560 398 566 -fill black -tag unacc

			$rscreen create line 278 563 278 543 -width 1 -tag unacc
			$rscreen create line 318 563 318 543 -width 1 -tag unacc
			$rscreen create line 358 563 358 543 -width 1 -tag unacc
			$rscreen create line 398 563 398 543 -width 1 -tag unacc

			$rscreen create oval 241 563 243 565 -fill black -tag unacc
			$rscreen create oval 281 563 283 565 -fill black -tag unacc
			$rscreen create oval 321 563 323 565 -fill black -tag unacc
			$rscreen create oval 361 563 363 565 -fill black -tag unacc
			$rscreen create oval 401 563 403 565 -fill black -tag unacc

			$rscreen create line 358 543 363 550 -width 1 -tag unacc
			$rscreen create line 398 543 403 550 -width 1 -tag unacc
			$rscreen create line 398 546 403 553 -width 1 -tag unacc

			$rscreen create oval 230 590 238 596 -fill [option get . background {}] -tag unacc
			$rscreen create oval 270 590 278 596 -fill [option get . background {}] -tag unacc 
			$rscreen create oval 310 590 318 596 -fill black -tag unacc
			$rscreen create oval 350 590 358 596 -fill black -tag unacc 

			$rscreen create line 278 593 278 573 -width 1 -tag unacc
			$rscreen create line 318 593 318 573 -width 1 -tag unacc
			$rscreen create line 358 593 358 573 -width 1 -tag unacc

			$rscreen create oval 241 593 243 595 -fill black -tag unacc
			$rscreen create oval 281 593 283 595 -fill black -tag unacc
			$rscreen create oval 321 593 323 595 -fill black -tag unacc
			$rscreen create oval 361 593 363 595 -fill black -tag unacc

			$rscreen create oval 244 593 246 595 -fill black -tag unacc
			$rscreen create oval 284 593 286 595 -fill black -tag unacc
			$rscreen create oval 324 593 326 595 -fill black -tag unacc
			$rscreen create oval 364 593 366 595 -fill black -tag unacc

			$rscreen create line 358 573 363 580 -width 1 -tag unacc
		}
	}
	if {$small_screen} {
		set rstaff .rhythmscreen.c.canvas.f
	} else {
		set rstaff .rhythmscreen
	}	

	set rscreencnt 0
	set rscreenval ""
	set rfilename  ""
	$rsrclist delete 0 end
	$atkclist delete 0 end
	$rstaff.btns.abdn 	config -state normal
	$rstaff.btns.save 	config -state normal
	$rstaff.btns.restart config -state normal
	$rstaff.btns.baktrak config -state normal
	set rscreensum 0.0
	set last_rscreensum 0.0

	raise .rhythmscreen
	set pr_rscreen 0
	set finished 0
	My_Grab 0 .rhythmscreen pr_rscreen

	while {!$finished} {
		tkwait variable pr_rscreen
		switch -- $pr_rscreen {
			0 {
				set	docol_OK 0
				set finished 1
			}
			1 {
				if {$rscreencnt <= 0} {
					Inf "No values entered."
					continue
				}
				set	docol_OK 1
				set finished 1
			}
			2 {
				if {$rscreencnt > 0} {
					$rsrclist delete 0 end
					if {$issum > 1} {
						$atkclist delete 0 end
					}
					set rscreenval ""
					set rscreencnt 0 
					set last_rscreencnt 0 
					set rscreensum 0.0
					set last_rscreensum 0.0
				}
			}
			3 {
				if {$rscreencnt > 0} {
					catch {unset blom}
					foreach item [$rsrclist get 0 [expr $last_rscreencnt - 1]] {
						lappend blom $item
					}
					$rsrclist delete 0 end
					if {[info exists blom]} {
						foreach item $blom {
							$rsrclist insert end $item
						}
					}
					if {$issum > 1} {
						catch {unset blom}
						foreach item [$atkclist get 0 [expr $last_rscreencnt - 1]] {
							lappend blom $item
						}
						$atkclist delete 0 end
						if {[info exists blom]} {
							foreach item $blom {
								$atkclist insert end $item
							}
						}
					}
					set rscreenval ""
 					set rscreencnt $last_rscreencnt
					set rscreensum $last_rscreensum
				}
			}
		}
	}
	if {$docol_OK} {
		catch {unset rscrlist_out}
		foreach item [$rsrclist get 0 end] {
			lappend rscrlist_out $item
		}
		if {$issum > 1} {
			catch {unset atkrlist_out}
			foreach item [$atkclist get 0 end] {
				lappend atkrlist_out $item
			}
		}
	}
	My_Release_to_Dialog .rhythmscreen
	Dlg_Dismiss .rhythmscreen
}

#------ Convert screen position to MIDI value

proc BeatsFromNoteGraphic {w xx yy issum} {
	global rscreen rscreenval rscreencnt last_rscreencnt rsrclist atkclist rscreensum last_rscreensum

	set obj [$rscreen find closest $xx $yy]
	set coords [$rscreen coords $obj]
	set x [expr int([lindex $coords 0])]
	set y [expr int([lindex $coords 1])]

	switch -- $issum {
		0 {
			switch -- $x {
				30 {
					switch -- $y {
						30	{ $rsrclist insert end 4  ; set rscreenval 4 ; set last_rscreencnt $rscreencnt; incr rscreencnt}
						60	{ $rsrclist insert end 6  ; set rscreenval 6 ; set last_rscreencnt $rscreencnt; incr rscreencnt}
						90	{ $rsrclist insert end 7  ; set rscreenval 7 ; set last_rscreencnt $rscreencnt; incr rscreencnt}
						130 { 
							$rsrclist insert end .5 
							$rsrclist insert end .5
							set rscreenval ".5  .5"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						170 { 
							$rsrclist insert end .25 
							$rsrclist insert end .25
							set rscreenval ".25  .25"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						220 { 
							$rsrclist insert end .5 
							$rsrclist insert end .5 
							$rsrclist insert end .5
							set rscreenval ".5  .5  .5"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						280 { 
							$rsrclist insert end .25 
							$rsrclist insert end .25 
							$rsrclist insert end .25
							set rscreenval ".25  .25  .25"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						350 { 
							$rsrclist insert end .667 
							$rsrclist insert end .667 
							$rsrclist insert end .666
							set rscreenval ".667  .667  .666"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						410 { 
							$rsrclist insert end .334 
							$rsrclist insert end .333 
							$rsrclist insert end .333
							set rscreenval ".334  .333  .333"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						470 { 
							$rsrclist insert end .167
							$rsrclist insert end .167 
							$rsrclist insert end .166
							set rscreenval ".167  .167  .166"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
					}
				}
				45 {
					switch -- $y {
						130 { 
							$rsrclist insert end .5
							$rsrclist insert end .5
							set rscreenval ".5  .5"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						170 { 
							$rsrclist insert end .25
							$rsrclist insert end .25
							set rscreenval ".25  .25"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						220 { 
							$rsrclist insert end .5 
							$rsrclist insert end .5 
							$rsrclist insert end .5
							set rscreenval ".5  .5  .5"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						280 { 
							$rsrclist insert end .25 
							$rsrclist insert end .25 
							$rsrclist insert end .25
							set rscreenval ".25  .25  .25"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						350 { 
							$rsrclist insert end .667
							$rsrclist insert end .667
							$rsrclist insert end .666
							set rscreenval ".667  .667  .666"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						410 { 
							$rsrclist insert end .334 
							$rsrclist insert end .333
							$rsrclist insert end .333
							set rscreenval ".334  .333  .333"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						470 { 
							$rsrclist insert end .167 
							$rsrclist insert end .167 
							$rsrclist insert end .166
							set rscreenval ".167  .167  .166"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
					}
				}
				60 {
					switch -- $y {
						220 { 
							$rsrclist insert end .5 
							$rsrclist insert end .5 
							$rsrclist insert end .5
							set rscreenval ".5  .5  .5"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						280 { 
							$rsrclist insert end .25 
							$rsrclist insert end .25 
							$rsrclist insert end .25
							set rscreenval ".25  .25  .25"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						350 { 
							$rsrclist insert end .667
							$rsrclist insert end .667
							$rsrclist insert end .666
							set rscreenval ".667  .667  .666"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						410 { 
							$rsrclist insert end .334 
							$rsrclist insert end .333
							$rsrclist insert end .333
							set rscreenval ".334  .333  .333"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						470 { 
							$rsrclist insert end .167 
							$rsrclist insert end .167 
							$rsrclist insert end .166
							set rscreenval ".167  .167  .166"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
					}
				}
				70 {
					switch -- $y {
						30	{ $rsrclist insert end 2 ; set rscreenval 2 ; set last_rscreencnt $rscreencnt; incr rscreencnt}
						60	{ $rsrclist insert end 3 ; set rscreenval 3 ; set last_rscreencnt $rscreencnt; incr rscreencnt}
						90	{ $rsrclist insert end 3.5 ; set rscreenval 3.5 ; set last_rscreencnt $rscreencnt; incr rscreencnt}
						130	{
							$rsrclist insert end .75
							$rsrclist insert end .25
							set rscreenval ".75  .25"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						170	{
							$rsrclist insert end .375
							$rsrclist insert end .125
							set rscreenval ".375  .125"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
					}
				}
				85 -
				115 {
					switch -- $y {
						220	{
							$rsrclist insert end 1
							$rsrclist insert end .5
							set rscreenval "1  .5"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						280	{
							$rsrclist insert end .5
							$rsrclist insert end .25
							set rscreenval ".5  .25"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						350	{
							$rsrclist insert end 1.333
							$rsrclist insert end .667
							set rscreenval "1.333  .667"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						410 { 
							$rsrclist insert end .667
							$rsrclist insert end .333
							set rscreenval ".667  .333"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						470 { 
							$rsrclist insert end .333
							$rsrclist insert end .167
							set rscreenval ".333  .167"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
					}
				}
				90 {
					switch -- $y {
						130	{
							$rsrclist insert end .75
							$rsrclist insert end .25
							set rscreenval ".75  .25"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						170	{
							$rsrclist insert end .375
							$rsrclist insert end .125
							set rscreenval ".375  .125"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
					}
				}
				105 {
					switch -- $y {
						30	{ $rsrclist insert end 1 ; set rscreenval 1 ; set last_rscreencnt $rscreencnt; incr rscreencnt}
						60	{ $rsrclist insert end 1.5 ; set rscreenval 1.5 ; set last_rscreencnt $rscreencnt; incr rscreencnt}
						90	{ $rsrclist insert end 1.75 ; set rscreenval 1.75 ; set last_rscreencnt $rscreencnt; incr rscreencnt}
					}
				}
				110 {
					switch -- $y {
						30	{ $rsrclist insert end 1 ; set rscreenval 1 ; set last_rscreencnt $rscreencnt; incr rscreencnt}
						60	{ $rsrclist insert end 1.5 ; set rscreenval 1.5 ; set last_rscreencnt $rscreencnt; incr rscreencnt}
						90	{ $rsrclist insert end 1.75 ; set rscreenval 1.75 ; set last_rscreencnt $rscreencnt; incr rscreencnt}
						130	{ 
							$rsrclist insert end .25
							$rsrclist insert end .75
							set rscreenval ".25  .75"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						170	{ 
							$rsrclist insert end .125
							$rsrclist insert end .375
							set rscreenval ".125  .375"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
					}
				}
				120 {
					switch -- $y {
						130	{ 
							$rsrclist insert end .25
							$rsrclist insert end .75
							set rscreenval ".25  .75"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						170	{ 
							$rsrclist insert end .125
							$rsrclist insert end .375
							set rscreenval ".125  .375"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
					}
				}
				140 -
				155 {
					switch -- $y {
						220	{
							$rsrclist insert end .5
							$rsrclist insert end 1
							set rscreenval ".5  1"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						280	{
							$rsrclist insert end .25
							$rsrclist insert end .5
							set rscreenval ".25  .5"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						350	{
							$rsrclist insert end .667
							$rsrclist insert end 1.333
							set rscreenval ".667  1.333"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						410 { 
							$rsrclist insert end .333
							$rsrclist insert end .667
							set rscreenval ".333  .667"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						470 { 
							$rsrclist insert end .167
							$rsrclist insert end .333
							set rscreenval ".167  .333"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
					}
				}
				150 {
					switch -- $y {
						30	{ $rsrclist insert end .5   ; set rscreenval .5 ; set last_rscreencnt $rscreencnt; incr rscreencnt}
						60	{ $rsrclist insert end .75  ; set rscreenval .75 ; set last_rscreencnt $rscreencnt; incr rscreencnt}
						90	{ $rsrclist insert end .825 ; set rscreenval .825 ; set last_rscreencnt $rscreencnt; incr rscreencnt}
						130	{
							$rsrclist insert end .5
							$rsrclist insert end .25
							$rsrclist insert end .25
							set rscreenval ".5  .25  .25"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						170	{
							$rsrclist insert end .25
							$rsrclist insert end .125
							$rsrclist insert end .125
							set rscreenval ".25  .125  .125"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
					}
				}
				165 -
				175 {
					switch -- $y {
						130	{
							$rsrclist insert end .5
							$rsrclist insert end .25
							$rsrclist insert end .25
							set rscreenval ".5  .25  .25"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						170	{
							$rsrclist insert end .25
							$rsrclist insert end .125
							$rsrclist insert end .125
							set rscreenval ".25  .125  .125"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
					}
				}
				190 {
					switch -- $y {
						30	{ $rsrclist insert end .25   ; set rscreenval .25 ; set last_rscreencnt $rscreencnt; incr rscreencnt}
						60	{ $rsrclist insert end .325  ; set rscreenval .325 ; set last_rscreencnt $rscreencnt; incr rscreencnt}
					}
				}
				195 -
				215 {
					switch -- $y {
						220	{
							$rsrclist insert end .75
							$rsrclist insert end .25
							$rsrclist insert end .5
							set rscreenval ".75  .25  .5"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						280	{
							$rsrclist insert end .375
							$rsrclist insert end .125
							$rsrclist insert end .25
							set rscreenval ".375  .125  .25"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						350	{
							$rsrclist insert end 1
							$rsrclist insert end .333
							$rsrclist insert end .667
							set rscreenval "1  .333  .667"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						410 { 
							$rsrclist insert end .5
							$rsrclist insert end .167
							$rsrclist insert end .333
							set rscreenval ".5  .167  .333"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						470 { 
							$rsrclist insert end .25
							$rsrclist insert end .083
							$rsrclist insert end .167
							set rscreenval ".25  .083  .167"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
					}
				}
				200 -
				210 {
					switch -- $y {
						130	{
							$rsrclist insert end .25
							$rsrclist insert end .25
							$rsrclist insert end .5
							set rscreenval ".25  .25  .5"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						170	{
							$rsrclist insert end .125
							$rsrclist insert end .125
							$rsrclist insert end .25
							set rscreenval ".125  .125  .25"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
					}
				}
				225 {
					switch -- $y {
						130	{
							$rsrclist insert end .25
							$rsrclist insert end .25
							$rsrclist insert end .5
							set rscreenval ".25  .25  .5"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						170	{
							$rsrclist insert end .125
							$rsrclist insert end .125
							$rsrclist insert end .25
							set rscreenval ".125  .125  .25"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						220	{
							$rsrclist insert end .75
							$rsrclist insert end .25
							$rsrclist insert end .5
							set rscreenval ".75  .25  .5"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						280	{
							$rsrclist insert end .375
							$rsrclist insert end .125
							$rsrclist insert end .25
							set rscreenval ".375  .125  .25"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						350	{
							$rsrclist insert end 1
							$rsrclist insert end .333
							$rsrclist insert end .667
							set rscreenval "1  .333  .667"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						410 { 
							$rsrclist insert end .5
							$rsrclist insert end .167
							$rsrclist insert end .333
							set rscreenval ".5  .167  .333"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						470 { 
							$rsrclist insert end .25
							$rsrclist insert end .083
							$rsrclist insert end .167
							set rscreenval ".25  .083  .167"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
					}
				}
				230 {
					switch -- $y {
						30	{ $rsrclist insert end .125   ; set rscreenval .125 ; set last_rscreencnt $rscreencnt; incr rscreencnt}
					}
				}
				250 -
				260 {
					switch -- $y {
						130	{
							$rsrclist insert end .25
							$rsrclist insert end .5
							$rsrclist insert end .25
							set rscreenval ".25  .5  .25"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						170	{
							$rsrclist insert end .125
							$rsrclist insert end .25
							$rsrclist insert end .125
							set rscreenval ".125  .25  .125"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						220	{
							$rsrclist insert end .25
							$rsrclist insert end .75
							$rsrclist insert end .5
							set rscreenval ".25  .75  .5"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						280	{
							$rsrclist insert end .125
							$rsrclist insert end .375
							$rsrclist insert end .25
							set rscreenval ".125  .375  .25"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						350	{
							$rsrclist insert end .333
							$rsrclist insert end 1
							$rsrclist insert end .667
							set rscreenval ".333  1  .667"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						410 { 
							$rsrclist insert end .167
							$rsrclist insert end .5
							$rsrclist insert end .333
							set rscreenval ".167  .5  .333"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						470 { 
							$rsrclist insert end .083
							$rsrclist insert end .25
							$rsrclist insert end .167
							set rscreenval ".083  .25  .167"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
					}
				}
				275 {
					switch -- $y {
						130	{
							$rsrclist insert end .25
							$rsrclist insert end .5
							$rsrclist insert end .25
							set rscreenval ".25  .5  .25"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						170	{
							$rsrclist insert end .125
							$rsrclist insert end .25
							$rsrclist insert end .125
							set rscreenval ".125  .25  .125"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
					}
				}
				280 {
					switch -- $y {
						220	{
							$rsrclist insert end .25
							$rsrclist insert end .75
							$rsrclist insert end .5
							set rscreenval ".25  .75  .5"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						280	{
							$rsrclist insert end .125
							$rsrclist insert end .375
							$rsrclist insert end .25
							set rscreenval ".125  .375  .25"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						350	{
							$rsrclist insert end .333
							$rsrclist insert end 1
							$rsrclist insert end .667
							set rscreenval ".333  1  .667"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						410 { 
							$rsrclist insert end .167
							$rsrclist insert end .5
							$rsrclist insert end .333
							set rscreenval ".167  .5  .333"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						470 { 
							$rsrclist insert end .083
							$rsrclist insert end .25
							$rsrclist insert end .167
							set rscreenval ".083  .25  .167"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
					}
				}
				305 -
				320 -
				340 {
					switch -- $y {
						220	{
							$rsrclist insert end .5
							$rsrclist insert end .75
							$rsrclist insert end .25
							set rscreenval ".5  .75  .25"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						280	{
							$rsrclist insert end .25
							$rsrclist insert end .375
							$rsrclist insert end .125
							set rscreenval ".25  .375  .125"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						350	{
							$rsrclist insert end .667
							$rsrclist insert end 1
							$rsrclist insert end .333
							set rscreenval ".667  1  .333"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						410 { 
							$rsrclist insert end .333
							$rsrclist insert end .5
							$rsrclist insert end .167
							set rscreenval ".33  .5  .167"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						470 { 
							$rsrclist insert end .167
							$rsrclist insert end .25
							$rsrclist insert end .083
							set rscreenval ".167  .25  .083"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
					}
				}
				365 -
				385 {
					switch -- $y {
						220	{
							$rsrclist insert end .75
							$rsrclist insert end .5
							$rsrclist insert end .25
							set rscreenval ".75  .5  .25"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						280	{
							$rsrclist insert end .375
							$rsrclist insert end .25
							$rsrclist insert end .125
							set rscreenval ".375  .25  .125"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						350	{
							$rsrclist insert end 1
							$rsrclist insert end .667
							$rsrclist insert end .333
							set rscreenval "1  .667  .333"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						410 { 
							$rsrclist insert end .5
							$rsrclist insert end .333
							$rsrclist insert end .167
							set rscreenval ".5  .333  .167"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						470 { 
							$rsrclist insert end .25
							$rsrclist insert end .167
							$rsrclist insert end .083
							set rscreenval ".25  .167  .083"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
					}
				}
				370 -
				380 -
				390 {
					switch -- $y {
						130	{
							$rsrclist insert end .5
							$rsrclist insert end .5
							$rsrclist insert end .5
							$rsrclist insert end .5
							set rscreenval ".5  .5  .5  .5"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 4
						}
						170	{
							$rsrclist insert end .25
							$rsrclist insert end .25
							$rsrclist insert end .25
							$rsrclist insert end .25
							set rscreenval ".25  .25  .25  .25"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 4
						}
					}
				}
				400 {
					switch -- $y {
						130	{
							$rsrclist insert end .5
							$rsrclist insert end .5
							$rsrclist insert end .5
							$rsrclist insert end .5
							set rscreenval ".5  .5  .5  .5"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 4
						}
						170	{
							$rsrclist insert end .25
							$rsrclist insert end .25
							$rsrclist insert end .25
							$rsrclist insert end .25
							set rscreenval ".25  .25  .25  .25"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 4
						}
						220	{
							$rsrclist insert end .75
							$rsrclist insert end .5
							$rsrclist insert end .25
							set rscreenval ".75  .5  .25"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						280	{
							$rsrclist insert end .375
							$rsrclist insert end .25
							$rsrclist insert end .125
							set rscreenval ".375  .25  .125"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						350	{
							$rsrclist insert end 1
							$rsrclist insert end .667
							$rsrclist insert end .333
							set rscreenval "1  .667  .333"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						410 { 
							$rsrclist insert end .5
							$rsrclist insert end .333
							$rsrclist insert end .167
							set rscreenval ".5  .333  .167"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						470 { 
							$rsrclist insert end .25
							$rsrclist insert end .167
							$rsrclist insert end .083
							set rscreenval ".25  .167  .083"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
					}
				}
				425 -
				435 -
				450 {
					switch -- $y {
						220	{
							$rsrclist insert end .25
							$rsrclist insert end .5
							$rsrclist insert end .75
							set rscreenval ".25  .5  .75"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						280	{
							$rsrclist insert end .125
							$rsrclist insert end .25
							$rsrclist insert end .375
							set rscreenval ".125  .25  .375"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						350	{
							$rsrclist insert end .333
							$rsrclist insert end .667
							$rsrclist insert end 1
							set rscreenval ".333  .667  1"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						410 { 
							$rsrclist insert end .167
							$rsrclist insert end .333
							$rsrclist insert end .5
							set rscreenval ".167  .333  .5"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						470 { 
							$rsrclist insert end .083
							$rsrclist insert end .167
							$rsrclist insert end .25
							set rscreenval ".083  .167  .25"
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
					}
				}
			}
		}
		default {
			switch -- $x {
				30 {
					switch -- $y {
						30	{ 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							if {$issum > 1} {
								$atkclist insert end 1
							}
							set rscreensum [expr $rscreensum + 4.0]
							set rscreenval 4
							set last_rscreencnt $rscreencnt
							incr rscreencnt
						}
						60	{ 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							if {$issum > 1} {
								$atkclist insert end 1
							}
							set rscreensum [expr $rscreensum + 6.0]
							set rscreenval 6
							set last_rscreencnt $rscreencnt
							incr rscreencnt
						}
						90	{ 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							if {$issum > 1} {
								$atkclist insert end 1
							}
							set rscreensum [expr $rscreensum + 7.0]
							set rscreenval 7
							set last_rscreencnt $rscreencnt
							incr rscreencnt
						}
						130 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							set rscreenval ".5  .5"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						170 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							set rscreenval ".25  .25"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						220 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							set rscreenval ".5  .5  .5"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						280 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							set rscreenval ".25  .25  .25"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						350 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.667]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.667]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.666]
							set rscreenval ".667  .667  .666"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						410 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.334]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.333]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.333]
							set rscreenval ".334  .333  .333"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						470 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.167]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.167]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.166]
							set rscreenval ".167  .167  .166"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
					}
				}
				45 {
					switch -- $y {
						130 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							set rscreenval ".5  .5"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						170 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							set rscreenval ".25  .25"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						220 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							set rscreenval ".5  .5  .5"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						280 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							set rscreenval ".25  .25  .25"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						350 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.667]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.667]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.666]
							set rscreenval ".667  .667  .666"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						410 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.334]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.333]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.333]
							set rscreenval ".334  .333  .333"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						470 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.167]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.167]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.166]
							set rscreenval ".167  .167  .166"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
					}
				}
				60 {
					switch -- $y {
						220 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							set rscreenval ".5  .5  .5"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						280 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							set rscreenval ".25  .25  .25"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						350 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.667]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.667]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.666]
							set rscreenval ".667  .667  .666"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						410 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.334]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.333]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.333]
							set rscreenval ".334  .333  .333"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						470 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.167]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.167]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.166]
							set rscreenval ".167  .167  .166"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
					}
				}
				70 {
					switch -- $y {
						30	{ 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 2.0]
							set rscreenval 2
							if {$issum > 1} {
								$atkclist insert end 1
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt
						}
						60	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 3.0]
							set rscreenval 3
							if {$issum > 1} {
								$atkclist insert end 1
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt
						}
						90	{ 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 3.5]
							set rscreenval 3.5
							if {$issum > 1} {
								$atkclist insert end 1
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt
						}
						130	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.75]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							set rscreenval ".75  .25"
							set last_rscreencnt $rscreencnt
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
							}
							incr rscreencnt 2
						}
						170	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.375]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.125]
							set rscreenval ".375  .125"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
					}
				}
				85 -
				115 {
					switch -- $y {
						220	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 1.0]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							set rscreenval "1  .5"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						280	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							set rscreenval ".5  .25"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						350	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 1.333]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.667]
							set rscreenval "1.333  .667"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						410 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.667]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 1.333]
							set rscreenval ".667  .333"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						470 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.333]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.667]
							set rscreenval ".333  .167"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
					}
				}
				90 {
					switch -- $y {
						130	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.75]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							set rscreenval ".75  .25"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						170	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.375]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.125]
							set rscreenval ".375  .125"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
					}
				}
				105 {
					switch -- $y {
						30	{ 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 1.0]
							set rscreenval 1
							if {$issum > 1} {
								$atkclist insert end 1
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt
						}
						60	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 1.5]
							set rscreenval 1.5
							if {$issum > 1} {
								$atkclist insert end 1
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt
						}
						90	{ 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 1.75]
							set rscreenval 1.75
							if {$issum > 1} {
								$atkclist insert end 1
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt
						}
					}
				}
				110 {
					switch -- $y {
						30	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 1.0]
							set rscreenval 1
							if {$issum > 1} {
								$atkclist insert end 1
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt
						}
						60	{ 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 1.5]
							set rscreenval 1.5
							if {$issum > 1} {
								$atkclist insert end 1
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt
						}
						90	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 1.75]
							set rscreenval 1.75
							if {$issum > 1} {
								$atkclist insert end 1
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt
						}
						130	{ 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.75]
							set rscreenval ".25  .75"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						170	{ 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.125]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.375]
							set rscreenval ".125  .375"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
					}
				}
				120 {
					switch -- $y {
						130	{ 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.75]
							set rscreenval ".25  .75"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						170	{ 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.125]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.375]
							set rscreenval ".125  .375"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
					}
				}
				140 -
				155 {
					switch -- $y {
						220	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 1.0]
							set rscreenval ".5  1"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						280	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							set rscreenval ".25  .5"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						350	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.667]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 1.333]
							set rscreenval ".667  1.333"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						410 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.333]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.667]
							set rscreenval ".333  .667"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
						470 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.167]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.333]
							set rscreenval ".167  .333"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 2
						}
					}
				}
				150 {
					switch -- $y {
						30	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + .5]
							set rscreenval .5
							if {$issum > 1} {
								$atkclist insert end 1
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt
						}
						60	{ 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + .75]
							set rscreenval .75
							if {$issum > 1} {
								$atkclist insert end 1
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt
						}
						90	{ 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + .825]
							set rscreenval .825
							if {$issum > 1} {
								$atkclist insert end 1
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt
						}
						130	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							set rscreenval ".5  .25  .25"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						170	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.125]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.125]
							set rscreenval ".25  .125  .125"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
					}
				}
				165 -
				175 {
					switch -- $y {
						130	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							set rscreenval ".5  .25  .25"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						170	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.125]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.125]
							set rscreenval ".25  .125  .125"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
					}
				}
				190 {
					switch -- $y {
						30	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + .25]
							set rscreenval .25
							if {$issum > 1} {
								$atkclist insert end 1
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt
						}
						60	{ 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + .325]
							set rscreenval .325
							if {$issum > 1} {
								$atkclist insert end 1
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt
						}
					}
				}
				195 -
				215 {
					switch -- $y {
						220	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.75]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							set rscreenval ".75  .25  .5"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						280	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.375]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.125]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							set rscreenval ".375  .125  .25"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						350	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 1.0]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.333]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.667]
							set rscreenval "1  .333  .667"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						410 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.167]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.333]
							set rscreenval ".5  .167  .333"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						470 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.083]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.167]
							set rscreenval ".25  .083  .167"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
					}
				}
				200 -
				210 {
					switch -- $y {
						130	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							set rscreenval ".25  .25  .5"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						170	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.125]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.125]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							set rscreenval ".125  .125  .25"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
					}
				}
				225 {
					switch -- $y {
						130	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							set rscreenval ".25  .25  .5"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						170	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.125]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.125]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							set rscreenval ".125  .125  .25"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						220	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.75]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							set rscreenval ".75  .25  .5"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						280	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.375]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.125]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							set rscreenval ".375  .125  .25"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						350	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 1.0]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.333]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.667]
							set rscreenval "1  .333  .667"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						410 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.167]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.333]
							set rscreenval ".5  .167  .333"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						470 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.083]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.167]
							set rscreenval ".25  .083  .167"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
					}
				}
				230 {
					switch -- $y {
						30	{ 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + .125]
							set rscreenval .125
							if {$issum > 1} {
								$atkclist insert end 1
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt
						}
					}
					if {$issum > 1} {
						switch -- $y {
							530 {
								set last_rscreensum $rscreensum
								$rsrclist insert end $rscreensum
								set rscreensum [expr $rscreensum + 4]
								set rscreenval 4
								$atkclist insert end 0
								set last_rscreencnt $rscreencnt
								incr rscreencnt
							}
							560 {
								set last_rscreensum $rscreensum
								$rsrclist insert end $rscreensum
								set rscreensum [expr $rscreensum + 6]
								set rscreenval 6
								$atkclist insert end 0
								set last_rscreencnt $rscreencnt
								incr rscreencnt
							}
							590 {
								set last_rscreensum $rscreensum
								$rsrclist insert end $rscreensum
								set rscreensum [expr $rscreensum + 7]
								set rscreenval 7
								$atkclist insert end 0
								set last_rscreencnt $rscreencnt
								incr rscreencnt
							}
						}
					}
				}
				250 -
				260 {
					switch -- $y {
						130	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							set rscreenval ".25  .5  .25"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						170	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.125]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.125]
							set rscreenval ".125  .25  .125"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						220	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.75]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							set rscreenval ".25  .75  .5"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						280	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.125]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.375]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							set rscreenval ".125  .375  .25"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						350	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.333]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 1.0]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.667]
							set rscreenval ".333  1  .667"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						410 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.167]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.333]
							set rscreenval ".167  .5  .333"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						470 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.083]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.167]
							set rscreenval ".083  .25  .167"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
					}
				}
				270 {
					if {$issum > 1} {
						switch -- $y {
							530 {
								set last_rscreensum $rscreensum
								$rsrclist insert end $rscreensum
								set rscreensum [expr $rscreensum + 2]
								set rscreenval 2
								$atkclist insert end 0
								set last_rscreencnt $rscreencnt
								incr rscreencnt
							}
							560 {
								set last_rscreensum $rscreensum
								$rsrclist insert end $rscreensum
								set rscreensum [expr $rscreensum + 3]
								set rscreenval 3
								$atkclist insert end 0
								set last_rscreencnt $rscreencnt
								incr rscreencnt
							}
							590 {
								set last_rscreensum $rscreensum
								$rsrclist insert end $rscreensum
								set rscreensum [expr $rscreensum + 3.5]
								set rscreenval 3.5
								$atkclist insert end 0
								set last_rscreencnt $rscreencnt
								incr rscreencnt
							}
						}
					}
				}
				275 {
					switch -- $y {
						130	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							set rscreenval ".25  .5  .25"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						170	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.125]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.125]
							set rscreenval ".125  .25  .125"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
					}
				}
				280 {
					switch -- $y {
						220	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.75]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							set rscreenval ".25  .75  .5"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						280	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.125]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.375]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							set rscreenval ".125  .375  .25"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						350	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.333]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 1.0]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.667]
							set rscreenval ".333  1  .667"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						410 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.167]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.333]
							set rscreenval ".167  .5  .333"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						470 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.083]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.167]
							set rscreenval ".083  .25  .167"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
					}
				}
				305 -
				320 -
				340 {
					switch -- $y {
						220	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.75]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							set rscreenval ".5  .75  .25"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						280	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.375]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.125]
							set rscreenval ".25  .375  .125"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						350	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.667]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 1.0]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.333]
							set rscreenval ".667  1  .333"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						410 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.333]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.167]
							set rscreenval ".333  .5  .167"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						470 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.167]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.083]
							set rscreenval ".167  .25  .083"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
					}
				}
				310 {
					if {$issum > 1} {
						switch -- $y {
							530 {
								set last_rscreensum $rscreensum
								$rsrclist insert end $rscreensum
								set rscreensum [expr $rscreensum + 1]
								set rscreenval 1
								$atkclist insert end 0
								set last_rscreencnt $rscreencnt
								incr rscreencnt
							}
							560 {
								set last_rscreensum $rscreensum
								$rsrclist insert end $rscreensum
								set rscreensum [expr $rscreensum + 1.5]
								set rscreenval 1.5
								$atkclist insert end 0
								set last_rscreencnt $rscreencnt
								incr rscreencnt
							}
							590 {
								set last_rscreensum $rscreensum
								$rsrclist insert end $rscreensum
								set rscreensum [expr $rscreensum + 1.75]
								set rscreenval 1.75
								$atkclist insert end 0
								set last_rscreencnt $rscreencnt
								incr rscreencnt
							}
						}
					}
				}
				350 {
					if {$issum > 1} {
						switch -- $y {
							530 {
								set last_rscreensum $rscreensum
								$rsrclist insert end $rscreensum
								set rscreensum [expr $rscreensum + 0.5]
								set rscreenval 0.5
								$atkclist insert end 0
								set last_rscreencnt $rscreencnt
								incr rscreencnt
							}
							560 {
								set last_rscreensum $rscreensum
								$rsrclist insert end $rscreensum
								set rscreensum [expr $rscreensum + 0.75]
								set rscreenval 0.75
								$atkclist insert end 0
								set last_rscreencnt $rscreencnt
								incr rscreencnt
							}
							590 {
								set last_rscreensum $rscreensum
								$rsrclist insert end $rscreensum
								set rscreensum [expr $rscreensum + 0.375]
								set rscreenval 0.375
								$atkclist insert end 0
								set last_rscreencnt $rscreencnt
								incr rscreencnt
							}
						}
					}
				}
				365 -
				385 {
					switch -- $y {
						220	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.75]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							set rscreenval ".75  .5  .25"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						280	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.375]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.125]
							set rscreenval ".375  .25  .125"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						350	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 1.0]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.667]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.333]
							set rscreenval "1  .667  .333"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						410 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.333]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.667]
							set rscreenval ".5  .333  .167"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						470 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.167]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.083]
							set rscreenval ".25  .167  .083"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
					}
				}
				370 -
				380 {
					switch -- $y {
						130	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							set rscreenval ".5  .5  .5  .5"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 4
						}
						170	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							set rscreenval ".25  .25  .25  .25"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 4
						}
					}
				}
				390 {
					switch -- $y {
						130	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							set rscreenval ".5  .5  .5  .5"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 4
						}
						170	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							set rscreenval ".25  .25  .25  .25"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 4
						}
					}
					if {$issum > 1} {
						switch -- $y {
							530 {
								set last_rscreensum $rscreensum
								$rsrclist insert end $rscreensum
								set rscreensum [expr $rscreensum + 0.25]
								set rscreenval 0.25
								$atkclist insert end 0
								set last_rscreencnt $rscreencnt
								incr rscreencnt
							}
							560 {
								set last_rscreensum $rscreensum
								$rsrclist insert end $rscreensum
								set rscreensum [expr $rscreensum + 0.375]
								set rscreenval 0.375
								$atkclist insert end 0
								set last_rscreencnt $rscreencnt
								incr rscreencnt
							}
						}
					}
				}
				400 {
					switch -- $y {
						130	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							set rscreenval ".5  .5  .5  .5"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 4
						}
						170	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							set rscreenval ".25  .25  .25  .25"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 4
						}
						220	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.75]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							set rscreenval ".75  .5  .25"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						280	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.375]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.125]
							set rscreenval ".375  .25  .125"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						350	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 1.0]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.667]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.333]
							set rscreenval "1  .667  .333"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						410 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.333]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.167]
							set rscreenval ".5  .333  .167"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						470 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + .25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.167]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.083]
							set rscreenval ".25  .167  .083"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
					}
				}
				425 -
				435 -
				450 {
					switch -- $y {
						220	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + .25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.75]
							set rscreenval ".25  .5  .75"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						280	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + .125]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.375]
							set rscreenval ".125  .25  .375"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						350	{
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.333]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.667]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 1.0]
							set rscreenval ".333  .667  1"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						410 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + .167]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.333]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.5]
							set rscreenval ".167  .333  .5"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
						470 { 
							set last_rscreensum $rscreensum
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + .083]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.167]
							$rsrclist insert end $rscreensum
							set rscreensum [expr $rscreensum + 0.25]
							set rscreenval ".083  .167  .25"
							if {$issum > 1} {
								$atkclist insert end 1
								$atkclist insert end 0
								$atkclist insert end 0
							}
							set last_rscreencnt $rscreencnt
							incr rscreencnt 3
						}
					}
				}
				430 {
					if {$issum > 1} {
						switch -- $y {
							530 {
								set last_rscreensum $rscreensum
								$rsrclist insert end $rscreensum
								set rscreensum [expr $rscreensum + 0.125]
								set rscreenval 0.125
								$atkclist insert end 0
								set last_rscreencnt $rscreencnt
								incr rscreencnt
							}
						}
					}
				}
			}
		}
	}
	$rsrclist yview moveto 1.0
	if {$issum > 1} {
		$atkclist yview moveto 1.0
	}
}

proc TheKeyboard {} {
	global kbdlist kbd_list kbdfnam kbdoform pr_kbd wstk mtf_snd chlist mtfmark pitchmark pa keybfile mu wl CDPcolour evv
	set f .kbd
	catch {unset kbdlist}
	if {![info exists chlist] || ([llength $chlist] <= 0)} {
		Inf "No Soundfile Selected"
		return
	}
	set mtf_snd [lindex $chlist 0]
	if {$pa($mtf_snd,$evv(FTYP)) != $evv(SNDFILE)} {
		Inf "'$mtf_snd' Is Not A Soundfile"
		return
	}
	foreach fnam [$wl get 0 end] {
		if {$pa($fnam,$evv(FTYP)) == $evv(SNDFILE)} {
			lappend kbdsnds $fnam
		}
	}
	if {![info exists kbdsnds]} {
		Inf "No Soundfiles On Workspace"
		return
	}
	set kbdoform 2
	set keybfile ""
	if [Dlg_Create $f "ASSOCIATE MIDI SEQUENCE WITH SOUND" "set pr_kbd 0" -width 120 -borderwidth $evv(SBDR)] {
		set b [frame $f.b -borderwidth $evv(SBDR)]
		set m 0
		frame $f.kb -borderwidth 0
		frame $f.kw -borderwidth 0
		frame $f.mc -borderwidth 0
		set kl [frame $f.kl -borderwidth $evv(SBDR)]
		set kz [frame $f.kz -borderwidth $evv(SBDR)]
		set sl [frame $f.sl -borderwidth $evv(SBDR)]
		set sk [frame $f.sk -borderwidth $evv(SBDR)]
		set fl [frame $f.fl -borderwidth $evv(SBDR)]
		set ss [frame $f.ss -borderwidth $evv(SBDR)]
		button $b.kee -text "Keep" -command "set pr_kbd 1" -highlightbackground [option get . background {}]
		label $b.nam -text "Filename"
		entry $b.fnam -textvariable kbdfnam -width 16
		label $b.for -text "OUTPUT FORMAT:"
		radiobutton $b.mtf -text "As Motif" -variable kbdoform -value 2
		radiobutton $b.node -text "As Pitchmark" -variable kbdoform -value 3
		radiobutton $b.line -text "As File (row)" -variable kbdoform -value 1
		radiobutton $b.list -text "As File (column)" -variable kbdoform -value 0
		button $b.aba -text "Close" -command "set pr_kbd 0" -highlightbackground [option get . background {}]
		pack $b.kee $b.for $b.mtf $b.node $b.line $b.list $b.fnam $b.nam -side left -padx 2
		pack $b.aba -side right -padx 2
		button $kz.cle -text "Clear" -command ClearKbdlist -highlightbackground [option get . background {}]
		pack $kz.cle -side left
		set kbd_list [text $kl.t -setgrid true -wrap word -width 84 -height 4 \
		-xscrollcommand "$kl.sx set" -yscrollcommand "$kl.sy set"]
		scrollbar $kl.sy -orient vert  -command "$f.kl.t yview"
		scrollbar $kl.sx -orient horiz -command "$f.kl.t xview"
		pack $kl.t -side left -fill both -expand true
		pack $kl.sy -side right -fill y
		set m 0
		if {$CDPcolour} {
			set chromatic slategrey
		} else {
			set chromatic black
		}
		while {$m < 5} {
			frame $f.kw.$m -bd 0
			if {$m < 4} {
				frame $f.kb.$m -bd 0
				set n 0
				while {$n < 28} {
					switch -- $n {
						0 -
						1 {
							button $f.kb.$m.$n -text "" -width 0 -bg $chromatic -command "AddToKbdList 37 $m" -highlightbackground [option get . background {}]
						}
						4 -
						5 {
							button $f.kb.$m.$n -text "" -width 0 -bg $chromatic -command "AddToKbdList 39 $m" -highlightbackground [option get . background {}]
						}
						12 -
						13 {
							button $f.kb.$m.$n -text "" -width 0 -bg $chromatic -command "AddToKbdList 42 $m" -highlightbackground [option get . background {}]
						}
						16 -
						17 {
							button $f.kb.$m.$n -text "" -width 0 -bg $chromatic -command "AddToKbdList 44 $m" -highlightbackground [option get . background {}]
						}
						20 - 
						21 {
							button $f.kb.$m.$n -text "" -width 0 -bg $chromatic -command "AddToKbdList 46 $m" -highlightbackground [option get . background {}]
						}
						default {
							button $f.kb.$m.$n -text "" -width 0 -bg [option get . background {}] -bd 0 -command {} -highlightbackground [option get . background {}]
						}
					}
					pack $f.kb.$m.$n -side left
					incr n
				}
				pack $f.kb.$m -side left
			}
			set n 0
			while {$n < 7} {
				switch -- $n {
					0 {
						set k [expr 36 + ($m * 12)]
						if {$k == 60} {
							button $f.kw.$m.$n -text "C" -width 2 -bg red -fg black -command "AddToKbdList 36 $m" -highlightbackground [option get . background {}]
						} else {
							button $f.kw.$m.$n -text "C" -width 2 -bg pink -fg black -command "AddToKbdList 36 $m" -highlightbackground [option get . background {}]
						}
					}
					1 {
						button $f.kw.$m.$n -text "D" -width 2 -bg white -fg black -command "AddToKbdList 38 $m" -highlightbackground [option get . background {}]
					}
					2 {
						button $f.kw.$m.$n -text "E" -width 2 -bg white -fg black -command "AddToKbdList 40 $m" -highlightbackground [option get . background {}]
					}
					3 {
						button $f.kw.$m.$n -text "F" -width 2 -bg white -fg black -command "AddToKbdList 41 $m" -highlightbackground [option get . background {}]
					}
					4 {
						button $f.kw.$m.$n -text "G" -width 2 -bg white -fg black -command "AddToKbdList 43 $m" -highlightbackground [option get . background {}]
					}
					5 {
						set k [expr 45 + ($m * 12)]
						if {$k == 69} {
							button $f.kw.$m.$n -text "A" -width 2 -bg $evv(HELP) -fg black -command "AddToKbdList 45 $m" -highlightbackground [option get . background {}]
						} else {
							button $f.kw.$m.$n -text "A" -width 2 -bg white -fg black -command "AddToKbdList 45 $m" -highlightbackground [option get . background {}]
						}
					}
					6 {
						button $f.kw.$m.$n -text "B" -width 2 -bg white -fg black -command "AddToKbdList 47 $m" -highlightbackground [option get . background {}]
					}
				}
				pack $f.kw.$m.$n -side left -padx 2
				if {$k >= 84} {
					break
				}
				incr n
			}
			pack $f.kw.$m -side left
			incr m
		}
		label $f.mc.m -text "Middle C"
		pack $f.mc.m -side top
		label $fl.0 -text "Input Motif Data:"
		button $fl.1 -text "Data from File" -command "set pr_kbd 2" -highlightbackground [option get . background {}]
		label $fl.2 -text "Filename  "
		entry $fl.3 -textvariable keybfile -width 48
		pack $fl.0 $fl.1 $fl.2 $fl.3 -side left
		pack $b -side top -fill x -expand true
		pack $f.kb $f.kw -side top
		label $sl.lab -text "Sound To Use"
		entry $sl.e -textvariable mtf_snd -width 36 -state readonly
		button $sl.play -text Play -bd 4 -command "MtfSndPlay" -width 8 -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $sl.a -text "A" -bd 4 -command "PlaySndfile $evv(TESTFILE_A) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
		pack $sl.play $sl.lab $sl.e $sl.a -side left -padx 2
		label $sk.snds -text "Possible Sounds (select with mouse)"
		pack $sk.snds -side top -pady 2
		Scrolled_Listbox $ss.l -width 84 -height 12 -selectmode single
		pack $ss.l -side top -fill x -expand true
		pack $f.mc $kz $kl $sl $fl $sk $ss -side top -fill x -expand true
#		wm resizable $f 0 0
		bind $ss.l.list <ButtonRelease-1> {GetMtfSnd}
		bind $f <Escape> {set pr_kbd 0}
		bind $f <Return> {set pr_kbd 1}
	}
	$f.ss.l.list delete 0 end
	foreach fnam $kbdsnds {
		$f.ss.l.list insert end $fnam
	}
	if {[llength $kbdsnds] == 1} {
		set mtf_snd [$f.ss.l.list get 0]
	}
	set finished 0 
	raise $f
	update idletasks
	StandardPosition2 $f
	set pr_kbd 0
	$kbd_list delete 1.0 end
	My_Grab 0 $f pr_kbd
	while {!$finished} {
		tkwait variable pr_kbd
		switch -- $pr_kbd {
			1 {
				catch {unset nulst}
				if {![info exists kbdlist]} {
					Inf "No Pitch Data To Save"
					continue
				}
				if {$kbdoform <= 1} {
					if {[string length $kbdfnam] <= 0} {
						Inf "No Filename Entered"
						continue
					}
					if {![ValidCDPRootname $kbdfnam]} {
						continue
					}
					set zfnam $kbdfnam$evv(TEXT_EXT)
					if {[file exists $zfnam]} {
						set msg "File '$zfnam' Already Exists. Overwrite  It ?"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							continue
						}
						if {![DeleteFileFromSystem $zfnam 0 1]} {
							continue
						}
						set i [LstIndx $zfnam $wl]
						if {$i >= 0} {
							RemoveAllRefsToFile $zfnam $i
						}
					}
					if [catch {open $zfnam "w"} zit] {
						Inf "Cannot Open File '$zfnam' To Write The Data"
						continue
					}
				} elseif {[string length $mtf_snd] <= 0} {
					Inf "No Sound Specified"
					continue
				}
				switch -- $kbdoform {
					0 {
						foreach item $kbdlist {
							puts $zit $item
						}
						close $zit
						FileToWkspace $zfnam 0 0 0 0 1
						set msg "Enter More Data ?"
					}
					1 {
						set out [lindex $kbdlist 0]
						foreach item [lrange $kbdlist 1 end] {
							append out  " " $item
						}
						puts $zit $out
						close $zit
						FileToWkspace $zfnam 0 0 0 0 1
						set msg "Enter More Data?"
					}
					2 {
						set mtfmark($mtf_snd) $kbdlist
						StoreMtfMarks
						set msg "Stored Motif Marker For '$mtf_snd'.  Enter More Data?"
					}
					3 {
						set pitchmark($mtf_snd) $kbdlist
						StorePitchMarks
						set msg "Stored Nodal Pitches Mark for '$mtf_snd'.  Enter More Data?"
					}
				}
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "yes"} {
					continue
				}
				break
			}
			2 {
				if {[string length $keybfile] <= 0} {
					Inf "No Filename Entered"
					continue
				}
				set zfnam [string tolower $keybfile]
				set extt [file extension $zfnam]
				if {[string length $extt] <= 0} {
					append zfnam $evv(TEXT_EXT)
				} elseif {![string match $extt $evv(TEXT_EXT)]} {
					Inf "Invalid Filename Extension"
					continue
				}
				if {![file exists $zfnam]} {
					Inf "File '$zfnam' Does Not Exist"
					continue
				}
				if [catch {open $zfnam "r"} zit] {
					Inf "Cannot Open File '$zfnam'"
					continue
				}
				catch {unset zvals}
				set OK 1
				while {[gets $zit line] >= 0} {
					set line [string trim $line]
					if {[string length $line] <= 0} {
						continue
					}
					set line [split $line]
					foreach item $line {
						set item [string trim $item]
						if {[string length $item] <= 0} {
							continue
						}
						if {![regexp {^[0-9]+$} $item]} {
							Inf "Invalid Data ($item) In File '$zfnam'"
							set OK 0
							break
						}
						if {($item < $mu(MIDIMIN)) || ($item > $mu(MIDIMAX))} {
							Inf "Midi Value ($item) Out Of Range In File '$zfnam'"
							set OK 0
							break
						}
						lappend zvals $item
					}
					if {!$OK} {
						break
					}
				}
				close $zit
				if {!$OK} {
					continue
				}
				if {![info exists zvals]} {
					Inf "No Data In File '$zfnam'"
					continue
				}
				$kbd_list delete 1.0 end
				set firstval [lindex $zvals 0]
				set kbdlist $firstval
				$kbd_list insert end $firstval
				foreach val [lrange $zvals 1 end] {
					lappend kbdlist $val
					$kbd_list insert end " "
					$kbd_list insert end $val
				}
			}
			0 {
				break
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

proc ClearKbdlist {} {
	global kbdlist kbd_list
	$kbd_list delete 1.0 end
	catch {unset kbdlist}
}

proc AddToKbdList {root m}  {
	global kbdlist kbd_list
	set k [expr $root + ($m * 12)]
	lappend kbdlist $k
	$kbd_list insert end " "
	$kbd_list insert end $k
}

proc GetMtfSnd {} {
	global mtf_snd
	set i [.kbd.ss.l.list curselection]
	if {$i >= 0} {
		set mtf_snd [.kbd.ss.l.list get $i]
		ForceVal .kbd.sl.e $mtf_snd
	}
}

proc ShowMotifs {} {
	global chlist mtfmark ismoremotifs mtflen mtflist pa evv
	catch {unset mtflist}
	if {![info exists mtfmark]} {
		Inf "No Motif Markers Exist"
		return
	}
	if {![info exists chlist] || ([llength $chlist] <= 0)} {
		Inf "No Files Chosen"
		return
	}
	foreach fnam $chlist {
		if {$pa($fnam,$evv(FTYP)) == $evv(SNDFILE)} {
			lappend kbdsnds $fnam
		}
	}
	if {![info exists kbdsnds]} {
		Inf "No Sound Files Chosen"
		return
	}
	foreach fnam $kbdsnds {
		if {[info exists mtfmark($fnam)]} {
			lappend mtflist $fnam
		}
	}
	if {![info exists mtflist]} {
		Inf "No Selected Files Have Motif Information"
		return
	}
	set mtflen [llength $mtflist] 
	if {$mtflen != [llength $kbdsnds]} {
		Inf "Some Of The Selected Files Do Not Have Associated Motif Information"
	}
	if [catch {eval {toplevel .mtfpage} -borderwidth $evv(BBDR)} zorg] {
		ErrShow "Failed to establish Motif Display Window"
		return
	}
	set lenmult [expr int(ceil($mtflen / 5.0))]
	wm protocol .mtfpage WM_DELETE_WINDOW "set pr_mtf 0"
	wm title .mtfpage "MOTIF DISPLAY"
	set pr_mtf 0
	set f .mtfpage
	frame $f.1

	button $f.1.c  -text "C"  -bd 4 -command "PlaySndfile $evv(TESTFILE_C)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.1.db -text "Db" -bd 4 -command "PlaySndfile $evv(TESTFILE_Db) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.1.d  -text "D"  -bd 4 -command "PlaySndfile $evv(TESTFILE_D)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.1.eb -text "Eb" -bd 4 -command "PlaySndfile $evv(TESTFILE_Eb) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.1.e  -text "E"  -bd 4 -command "PlaySndfile $evv(TESTFILE_E)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.1.f  -text "F"  -bd 4 -command "PlaySndfile $evv(TESTFILE_F)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.1.gb -text "Gb" -bd 4 -command "PlaySndfile $evv(TESTFILE_Gb) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.1.g  -text "G"  -bd 4 -command "PlaySndfile $evv(TESTFILE_G)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.1.ab -text "Ab" -bd 4 -command "PlaySndfile $evv(TESTFILE_Ab) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.1.a  -text "A"  -bd 4 -command "PlaySndfile $evv(TESTFILE_A)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.1.bb -text "Bb" -bd 4 -command "PlaySndfile $evv(TESTFILE_Bb) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.1.b  -text "B"  -bd 4 -command "PlaySndfile $evv(TESTFILE_B)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.1.c2 -text "C"  -bd 4 -command "PlaySndfile $evv(TESTFILE_C2) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	pack $f.1.c $f.1.db $f.1.d $f.1.eb $f.1.e $f.1.f $f.1.gb $f.1.g $f.1.ab $f.1.a $f.1.bb $f.1.b $f.1.c2 -side left -padx 3

	button $f.1.quit -text "Close" -command "set pr_mtf 0" -highlightbackground [option get . background {}]
	pack $f.1.quit -side right
	frame $f.2 -borderwidth $evv(SBDR)
	set can [Scrolled_Canvas $f.2.c -width [expr $evv(CANVAS_DISPLAYED_WIDTH) * 2] \
									-height $evv(CANVAS_DISPLAYED_HEIGHT) \
									-scrollregion "0 0 [expr $evv(CANVAS_DISPLAYED_WIDTH) * 2] [expr $evv(CANVAS_DISPLAYED_HEIGHT) * $lenmult]"]
	pack $f.2.c -fill both -expand true
	set n 0
	set m 0
	set mstep 110
	foreach fnam $mtflist {
		set k [expr $m + ($mstep/3)]
		set ff [frame $can.$n -borderwidth 2]
		$can create window 0 $k -width 200 -height 20 -anchor nw -window $ff
		label $ff.ll1 -text [file tail $fnam] -width 48
		pack $ff.ll1 -side left -padx 2
		EstablishMotifDisplay $can $m $fnam $n
		incr n
		incr m $mstep
	}
	pack $f.1 $f.2 -side top -fill x -expand true
	raise .mtfpage
	update idletasks
	StandardPosition2 .mtfpage
	My_Grab 0 $f pr_mtf
	tkwait variable pr_mtf
	My_Release_to_Dialog $f
	set k $n
	set n 0
	while {$n < $k} {
		set fnam cdptest0
		append fnam $n $evv(SNDFILE_EXT)
		if {[file exists $fnam]} {
			catch {file delete $fnam}
		}
		set fnam cdptest0
		append fnam $n $evv(TEXT_EXT)
		if {[file exists $fnam]} {
			catch {file delete $fnam}
		}
		set fnam cdptest00
		append fnam $n $evv(SNDFILE_EXT)
		if {[file exists $fnam]} {
			catch {file delete $fnam}
		}
		set fnam cdptest00
		append fnam $n $evv(TEXT_EXT)
		if {[file exists $fnam]} {
			catch {file delete $fnam}
		}
		set fnam cdptest000
		append fnam $n $evv(SNDFILE_EXT)
		if {[file exists $fnam]} {
			catch {file delete $fnam}
		}
		incr n
	}
	set fnam cdptest0000
	append fnam $evv(TEXT_EXT)
	if {[file exists $fnam]} {
		catch {file delete $fnam}
	}
	set fnam cdptest0000
	append fnam $evv(SNDFILE_EXT)
	if {[file exists $fnam]} {
		catch {file delete $fnam}
	}
	destroy $f
}

proc EstablishMotifDisplay {can m fnam n} {
	global mtfmark pitchmark evv

	#	CANVAS AND VALUE LISTING

	set topp [GetRangeLimitOfMmark $fnam 0]
	set botp [GetRangeLimitOfMmark $fnam 1]
	set inbass 0
	if {$topp <= 60} {
		set inbass 1
	} elseif {$topp <= 65} {
		if {$botp < 54} {
			set inbass 1
		} else {
			set inbass 0
		}
	} elseif {$botp >= 54} {
		set inbass 0
	} elseif {$topp <= 72} {
		set inbass -1
	} else {
		set range [expr $topp - $botp]
		$can create text 240 [expr 60 + $m] -anchor sw -text "RANGE TOO LARGE TO REPRESENT" -fill $evv(POINT)
		return
	}
	$can create line 230  [expr 40 + $m] 630 [expr 40 + $m] -tag notehite -fill $evv(POINT)	
	$can create line 230  [expr 50 + $m] 630 [expr 50 + $m] -tag {notehite flathite} -fill $evv(POINT) 
	$can create line 230  [expr 60 + $m] 630 [expr 60 + $m] -tag {notehite flathite} -fill $evv(POINT)
	$can create line 230  [expr 70 + $m] 630 [expr 70 + $m] -tag {notehite flathite} -fill $evv(POINT)
	$can create line 230  [expr 80 + $m] 630 [expr 80 + $m] -tag {notehite flathite} -fill $evv(POINT)

	$can create text 730 [expr 20 + $m] -anchor c -text "PLAY" -fill $evv(POINT)

	set f0 [frame $can.f0$m -borderwidth 0]			;#	Play Src, button
	$can create window 710 [expr 45 + $m] -anchor c -window $f0
	button $f0.button -text SRC -justify center -width 4 -command "PlaySndfile $fnam 0" -highlightbackground [option get . background {}]
	pack $f0.button -side top -fill both

	set f1 [frame $can.f1$m -borderwidth 0]			;#	Play Motif, button
	$can create window 750 [expr 45 + $m] -anchor c -window $f1
	button $f1.button -text MTF -justify center -width 4 -command "PlayMotif $fnam 0 $n" -highlightbackground [option get . background {}]
	pack $f1.button -side top -fill both

	set f2 [frame $can.f2$m -borderwidth 0]			;#	Play Both, button
	$can create window 710 [expr 75 + $m] -anchor c -window $f2
	button $f2.button -text BOTH -justify center -width 4 -command "PlayMotif $fnam 2 $n" -highlightbackground [option get . background {}]
	pack $f2.button -side top -fill both

	if {[info exists pitchmark($fnam)]} {
		set f3 [frame $can.f3$m -borderwidth 0]			;#	Play HF Button
		$can create window 750 [expr 75 + $m] -anchor c -window $f3
		button $f3.button -text HF -justify center -width 4 -command "PlayMotif $fnam 1 $n" -highlightbackground [option get . background {}]
		pack $f3.button -side top -fill both
	}
	set offset 266

	if {$inbass == 1} {
		#BASS CLEF
		set bclef2a [$can create arc 230 [expr 40 + $m] 257 [expr 75 + $m] -style arc -start 30 -extent 120 -width 1 -outline $evv(POINT)]
		set bclef2b [$can create arc 175 [expr 15 + $m] 255 [expr 85 + $m] -style arc -start 5 -extent -75 -width 1 -outline $evv(POINT)]
		set bclef2c [$can create oval 259 [expr 44 + $m] 261 [expr 46 + $m] -fill $evv(POINT) -outline $evv(POINT)]
		set bclef2d [$can create oval 259 [expr 54 + $m] 261 [expr 56 + $m] -fill $evv(POINT) -outline $evv(POINT)]
		foreach note $mtfmark($fnam) {
			set xpos1 $offset
			set xpos2	 [expr $xpos1 + $evv(NOTEWIDTH)]
			set xpos1leg [expr $xpos1 - $evv(LEDGE_OFFSET)]
			set xpos2leg [expr $xpos1leg + $evv(LEDGELEN)]

			set filled 0
			if [info exists pitchmark($fnam)] {
				set k [lsearch $pitchmark($fnam) $note]
				if {$k >= 0} {
					set filled 1
				}	
			}
			switch -- $note {
				65	{
					if {$filled} {
						$can create oval $xpos1 [expr 12 + $m] $xpos2 [expr 18 + $m] -fill $evv(POINT) -outline $evv(POINT)
					} else {
						$can create oval $xpos1 [expr 12 + $m] $xpos2 [expr 18 + $m] -outline $evv(POINT)
					}
					$can create line $xpos1leg [expr 20 + $m] $xpos2leg [expr 20 + $m] -fill $evv(POINT)
					$can create line $xpos1leg [expr 30 + $m] $xpos2leg [expr 30 + $m] -fill $evv(POINT)
				}
				64	{
					if {$filled} {
						$can create oval $xpos1 [expr 17 + $m] $xpos2 [expr 23 + $m] -fill $evv(POINT) -outline $evv(POINT)
					} else {
						$can create oval $xpos1 [expr 17 + $m] $xpos2 [expr 23 + $m] -outline $evv(POINT)
					}
					$can create line $xpos1leg [expr 20 + $m] $xpos2leg [expr 20 + $m] -fill $evv(POINT)
					$can create line $xpos1leg [expr 30 + $m] $xpos2leg [expr 30 + $m] -fill $evv(POINT)
				}
				63	{
					$can create text [expr $xpos1 - 4] [expr 24 + $m] -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT)
					if {$filled} {
						$can create oval $xpos1 [expr 17 + $m] $xpos2 [expr 23 + $m] -fill $evv(POINT) -outline $evv(POINT)
					} else {
						$can create oval $xpos1 [expr 17 + $m] $xpos2 [expr 23 + $m] -outline $evv(POINT)
					}
					$can create line $xpos1leg [expr 20 + $m] $xpos2leg [expr 20 + $m] -fill $evv(POINT)
					$can create line $xpos1leg [expr 30 + $m] $xpos2leg [expr 30 + $m] -fill $evv(POINT)
				}
				62	{
					if {$filled} {
						$can create oval $xpos1 [expr 22 + $m] $xpos2 [expr 28 + $m] -fill $evv(POINT) -outline $evv(POINT)
					} else {
						$can create oval $xpos1 [expr 22 + $m] $xpos2 [expr 28 + $m] -outline $evv(POINT)
					}
					$can create line $xpos1leg [expr 30 + $m] $xpos2leg [expr 30 + $m] -fill $evv(POINT)
				}
				61	{
					$can create text [expr $xpos1 - 4] [expr 29 + $m] -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT)
					if {$filled} {
						$can create oval $xpos1 [expr 22 + $m] $xpos2 [expr 28 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 22 + $m] $xpos2 [expr 28 + $m] -outline $evv(POINT) 
					}
					$can create line $xpos1leg [expr 30 + $m] $xpos2leg [expr 30 + $m] -fill $evv(POINT)
				}
				60	{
					if {$filled} {
						$can create oval $xpos1 [expr 27 + $m] $xpos2 [expr 33 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 27 + $m] $xpos2 [expr 33 + $m] -outline $evv(POINT) 
					}
					$can create line $xpos1leg [expr 30 + $m] $xpos2leg [expr 30 + $m] -fill $evv(POINT)
				}
				59	{
					if {$filled} {
						$can create oval $xpos1 [expr 32 + $m] $xpos2 [expr 38 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 32 + $m] $xpos2 [expr 38 + $m] -outline $evv(POINT) 
					}
				}
				58	{
					$can create text [expr $xpos1 - 4] [expr 39 + $m] -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT)
					if {$filled} {
						$can create oval $xpos1 [expr 32 + $m] $xpos2 [expr 38 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 32 + $m] $xpos2 [expr 38 + $m] -outline $evv(POINT) 
					}
				}
				57	{
					if {$filled} {
						$can create oval $xpos1 [expr 37 + $m] $xpos2 [expr 43 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 37 + $m] $xpos2 [expr 43 + $m] -outline $evv(POINT) 
					}
				}
				56 {
					$can create text [expr $xpos1 - 4] [expr 44 + $m] -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT)
					if {$filled} {
						$can create oval $xpos1 [expr 37 + $m] $xpos2 [expr 43 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 37 + $m] $xpos2 [expr 43 + $m] -outline $evv(POINT) 
					}
				}
				55	{
					if {$filled} {
						$can create oval $xpos1 [expr 42 + $m] $xpos2 [expr 48 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 42 + $m] $xpos2 [expr 48 + $m] -outline $evv(POINT) 
					}
				}
				54	{
					$can create text [expr $xpos1 - 4] [expr 49 + $m] -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT)
					if {$filled} {
						$can create oval $xpos1 [expr 42 + $m] $xpos2 [expr 48 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 42 + $m] $xpos2 [expr 48 + $m] -outline $evv(POINT) 
					}
				}
				53	{
					if {$filled} {
						$can create oval $xpos1 [expr 47 + $m] $xpos2 [expr 53 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 47 + $m] $xpos2 [expr 53 + $m] -outline $evv(POINT) 
					}
				}
				52	{
					if {$filled} {
						$can create oval $xpos1 [expr 52 + $m] $xpos2 [expr 58 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 52 + $m] $xpos2 [expr 58 + $m] -outline $evv(POINT) 
					}
				}
				51	{
					$can create text [expr $xpos1 - 4] [expr 59 + $m] -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT)
					if {$filled} {
						$can create oval $xpos1 [expr 52 + $m] $xpos2 [expr 58 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 52 + $m] $xpos2 [expr 58 + $m] -outline $evv(POINT) 
					}
				}
				50	{
					if {$filled} {
						$can create oval $xpos1 [expr 57 + $m] $xpos2 [expr 63 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 57 + $m] $xpos2 [expr 63 + $m] -outline $evv(POINT) 
					}
				}
				49	{
					$can create text [expr $xpos1 - 4] [expr 64 + $m] -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT)
					if {$filled} {
						$can create oval $xpos1 [expr 57 + $m] $xpos2 [expr 63 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 57 + $m] $xpos2 [expr 63 + $m] -outline $evv(POINT) 
					}
				}
				48	{
					if {$filled} {
						$can create oval $xpos1 [expr 62 + $m] $xpos2 [expr 68 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 62 + $m] $xpos2 [expr 68 + $m] -outline $evv(POINT) 
					}
				}
				47	{
					if {$filled} {
						$can create oval $xpos1 [expr 67 + $m] $xpos2 [expr 73 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 67 + $m] $xpos2 [expr 73 + $m] -outline $evv(POINT) 
					}
				}
				46	{
					$can create text [expr $xpos1 - 4] [expr 74 + $m] -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT)
					if {$filled} {
						$can create oval $xpos1 [expr 67 + $m] $xpos2 [expr 73 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 67 + $m] $xpos2 [expr 73 + $m] -outline $evv(POINT) 
					}
				}
				45	{
					if {$filled} {
						$can create oval $xpos1 [expr 72 + $m] $xpos2 [expr 78 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 72 + $m] $xpos2 [expr 78 + $m] -outline $evv(POINT) 
					}
				}
				44	{
					$can create text [expr $xpos1 - 4] [expr 79 + $m] -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT)
					if {$filled} {
						$can create oval $xpos1 [expr 72 + $m] $xpos2 [expr 78 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 72 + $m] $xpos2 [expr 78 + $m] -outline $evv(POINT) 
					}
				}
				43	{
					if {$filled} {
						$can create oval $xpos1 [expr 77 + $m] $xpos2 [expr 83 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 77 + $m] $xpos2 [expr 83 + $m] -outline $evv(POINT) 
					}
				}
				42	{
					$can create text [expr $xpos1 - 4] [expr 84 + $m] -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT)
					if {$filled} {
						$can create oval $xpos1 [expr 77 + $m] $xpos2 [expr 83 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 77 + $m] $xpos2 [expr 83 + $m] -outline $evv(POINT) 
					}
				}
				41	{
					if {$filled} {
						$can create oval $xpos1 [expr 82 + $m] $xpos2 [expr 88 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 82 + $m] $xpos2 [expr 88 + $m] -outline $evv(POINT) 
					}
				}
				40	{
					if {$filled} {
						$can create oval $xpos1 [expr 87 + $m] $xpos2 [expr 93 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 87 + $m] $xpos2 [expr 93 + $m] -outline $evv(POINT) 
					}
					$can create line $xpos1leg [expr 90 + $m] $xpos2leg [expr 90 + $m] -fill $evv(POINT)
				}
				39	{
					$can create text [expr $xpos1 - 4] [expr 94 + $m] -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT)
					if {$filled} {
						$can create oval $xpos1 [expr 87 + $m] $xpos2 [expr 93 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 87 + $m] $xpos2 [expr 93 + $m] -outline $evv(POINT) 
					}
					$can create line $xpos1leg [expr 90 + $m] $xpos2leg [expr 90 + $m] -fill $evv(POINT)
				}
				38	{
					if {$filled} {
						$can create oval $xpos1 [expr 92 + $m] $xpos2 [expr 98 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 92 + $m] $xpos2 [expr 98 + $m] -outline $evv(POINT) 
					}
					$can create line $xpos1leg [expr 90 + $m] $xpos2leg [expr 90 + $m] -fill $evv(POINT)
				}
				37	{
					$can create text [expr $xpos1 - 4] [expr 99 + $m] -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT)
					if {$filled} {
						$can create oval $xpos1 [expr 92 + $m] $xpos2 [expr 98 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 92 + $m] $xpos2 [expr 98 + $m] -outline $evv(POINT) 
					}
					$can create line $xpos1leg [expr 90 + $m] $xpos2leg [expr 90 + $m] -fill $evv(POINT)
				}
				36	{
					if {$filled} {
						$can create oval $xpos1 [expr 97 + $m] $xpos2 [expr 103 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 97 + $m] $xpos2 [expr 103 + $m] -outline $evv(POINT) 
					}
					$can create line $xpos1leg [expr 90 + $m] $xpos2leg [expr 90 + $m] -fill $evv(POINT)
					$can create line $xpos1leg [expr 100 + $m] $xpos2leg [expr 100 + $m] -fill $evv(POINT)
				}
			}
			incr offset [expr $evv(LEDGELEN) + 4]
		}
	} else {
		if {$inbass == -1} {
			$can create text 237 [expr 110 + $m] -anchor sw -text "8" -font bigfnt -fill $evv(POINT)
		}

		#TREBLE CLEF
		set clef1a [$can create line 240  [expr 30 + $m] 240 [expr 95 + $m] -width 1 -fill $evv(POINT)]
		set clef1b [$can create arc 240 [expr 24 + $m] 252 [expr 36 + $m] -style arc -start 180 -extent -230 -width 1 -outline $evv(POINT)]
		set clef1c [$can create line 248  [expr 35 + $m] 230 [expr 70 + $m] -width 1 -fill $evv(POINT)]
		set clef1d [$can create arc 230 [expr 60 + $m] 250 [expr 80 + $m] -style arc -start 180 -extent 270 -width 1 -outline $evv(POINT)]

		foreach note $mtfmark($fnam) {
			set xpos1 $offset
			set xpos2	 [expr $xpos1 + $evv(NOTEWIDTH)]
			set xpos1leg [expr $xpos1 - $evv(LEDGE_OFFSET)]
			set xpos2leg [expr $xpos1leg + $evv(LEDGELEN)]
			set filled 0
			if [info exists pitchmark($fnam)] {
				set k [lsearch $pitchmark($fnam) $note]
				if {$k >= 0} {
					set filled 1
				}	
			}
			if {$inbass == -1} {
				set note [expr $note + 12]
			}
			switch -- $note {
				86	{
					if {$filled} {
						$can create oval $xpos1 [expr 12 + $m] $xpos2 [expr 18 + $m] --fill $evv(POINT) -outline $evv(POINT)
					} else {
						$can create oval $xpos1 [expr 12 + $m] $xpos2 [expr 18 + $m] -outline $evv(POINT)
					}
					$can create line $xpos1leg [expr 20 + $m] $xpos2leg [expr 20 + $m] -fill $evv(POINT)
					$can create line $xpos1leg [expr 30 + $m] $xpos2leg [expr 30 + $m] -fill $evv(POINT)
				}
				85	{
					$can create text [expr $xpos1 - 4] [expr 19 + $m] -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT)
					if {$filled} {
						$can create oval $xpos1 [expr 12 + $m] $xpos2 [expr 18 + $m] --fill $evv(POINT) -outline $evv(POINT)
					} else {
						$can create oval $xpos1 [expr 12 + $m] $xpos2 [expr 18 + $m] -outline $evv(POINT)
					}
					$can create line $xpos1leg [expr 20 + $m] $xpos2leg [expr 20 + $m] -fill $evv(POINT)
					$can create line $xpos1leg [expr 30 + $m] $xpos2leg [expr 30 + $m] -fill $evv(POINT)
				}
				84	{
					if {$filled} {
						$can create oval $xpos1 [expr 17 + $m] $xpos2 [expr 23 + $m] -fill $evv(POINT) -outline $evv(POINT)
					} else {
						$can create oval $xpos1 [expr 17 + $m] $xpos2 [expr 23 + $m] -outline $evv(POINT)
					}
					$can create line $xpos1leg [expr 20 + $m] $xpos2leg [expr 20 + $m] -fill $evv(POINT)
					$can create line $xpos1leg [expr 30 + $m] $xpos2leg [expr 30 + $m] -fill $evv(POINT)
				}
				83	{
					if {$filled} {
						$can create oval $xpos1 [expr 22 + $m] $xpos2 [expr 28 + $m] --fill $evv(POINT) -outline $evv(POINT)
					} else {
						$can create oval $xpos1 [expr 22 + $m] $xpos2 [expr 28 + $m] -outline $evv(POINT)
					}
					$can create line $xpos1leg [expr 30 + $m] $xpos2leg [expr 30 + $m] -fill $evv(POINT)
				}
				82	{
					$can create text [expr $xpos1 - 4] [expr 29 + $m] -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT)
					if {$filled} {
						$can create oval $xpos1 [expr 22 + $m] $xpos2 [expr 28 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 22 + $m] $xpos2 [expr 28 + $m] -outline $evv(POINT) 
					}
					$can create line $xpos1leg [expr 30 + $m] $xpos2leg [expr 30 + $m] -fill $evv(POINT)
				}
				81	{
					if {$filled} {
						$can create oval $xpos1 [expr 27 + $m] $xpos2 [expr 33 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 27 + $m] $xpos2 [expr 33 + $m] -outline $evv(POINT) 
					}
					$can create line $xpos1leg [expr 30 + $m] $xpos2leg [expr 30 + $m] -fill $evv(POINT)
				}
				80	{
					$can create text [expr $xpos1 - 4] [expr 34 + $m] -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT)
					if {$filled} {
						$can create oval $xpos1 [expr 27 + $m] $xpos2 [expr 33 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 27 + $m] $xpos2 [expr 33 + $m] -outline $evv(POINT) 
					}
					$can create line $xpos1leg [expr 30 + $m] $xpos2leg [expr 30 + $m] -fill $evv(POINT)
				}
				79	{
					if {$filled} {
						$can create oval $xpos1 [expr 32 + $m] $xpos2 [expr 38 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 32 + $m] $xpos2 [expr 38 + $m] -outline $evv(POINT) 
					}
				}
				78	{
					$can create text [expr $xpos1 - 4] [expr 39 + $m] -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT)
					if {$filled} {
						$can create oval $xpos1 [expr 32 + $m] $xpos2 [expr 38 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 32 + $m] $xpos2 [expr 38 + $m] -outline $evv(POINT) 
					}
				}
				77	{
					if {$filled} {
						$can create oval $xpos1 [expr 37 + $m] $xpos2 [expr 43 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 37 + $m] $xpos2 [expr 43 + $m] -outline $evv(POINT) 
					}
				}
				76	{
					if {$filled} {
						$can create oval $xpos1 [expr 42 + $m] $xpos2 [expr 48 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 42 + $m] $xpos2 [expr 48 + $m] -outline $evv(POINT) 
					}
				}
				75	{
					$can create text [expr $xpos1 - 4] [expr 49 + $m] -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT)
					if {$filled} {
						$can create oval $xpos1 [expr 42 + $m] $xpos2 [expr 48 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 42 + $m] $xpos2 [expr 48 + $m] -outline $evv(POINT) 
					}
				}
				74	{
					if {$filled} {
						$can create oval $xpos1 [expr 47 + $m] $xpos2 [expr 53 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 47 + $m] $xpos2 [expr 53 + $m] -outline $evv(POINT) 
					}
				}
				73	{
					$can create text [expr $xpos1 - 4] [expr 54 + $m] -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT)
					if {$filled} {
						$can create oval $xpos1 [expr 47 + $m] $xpos2 [expr 53 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 47 + $m] $xpos2 [expr 53 + $m] -outline $evv(POINT) 
					}
				}
				72	{
					if {$filled} {
						$can create oval $xpos1 [expr 52 + $m] $xpos2 [expr 58 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 52 + $m] $xpos2 [expr 58 + $m] -outline $evv(POINT) 
					}
				}
				71	{
					if {$filled} {
						$can create oval $xpos1 [expr 57 + $m] $xpos2 [expr 63 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 57 + $m] $xpos2 [expr 63 + $m] -outline $evv(POINT) 
					}
				}
				70	{
					$can create text [expr $xpos1 - 4] [expr 64 + $m] -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT)
					if {$filled} {
						$can create oval $xpos1 [expr 57 + $m] $xpos2 [expr 63 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 57 + $m] $xpos2 [expr 63 + $m] -outline $evv(POINT) 
					}
				}
				69	{
					if {$filled} {
						$can create oval $xpos1 [expr 62 + $m] $xpos2 [expr 68 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 62 + $m] $xpos2 [expr 68 + $m] -outline $evv(POINT) 
					}
				}
				68	{
					$can create text [expr $xpos1 - 4] [expr 69 + $m] -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT)
					if {$filled} {
						$can create oval $xpos1 [expr 62 + $m] $xpos2 [expr 68 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 62 + $m] $xpos2 [expr 68 + $m] -outline $evv(POINT) 
					}
				}
				67	{
					if {$filled} {
						$can create oval $xpos1 [expr 67 + $m] $xpos2 [expr 73 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 67 + $m] $xpos2 [expr 73 + $m] -outline $evv(POINT) 
					}
				}
				66	{
					$can create text [expr $xpos1 - 4] [expr 74 + $m] -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT)
					if {$filled} {
						$can create oval $xpos1 [expr 67 + $m] $xpos2 [expr 73 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 67 + $m] $xpos2 [expr 73 + $m] -outline $evv(POINT) 
					}
				}
				65	{
					if {$filled} {
						$can create oval $xpos1 [expr 72 + $m] $xpos2 [expr 78 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 72 + $m] $xpos2 [expr 78 + $m] -outline $evv(POINT) 
					}
				}
				64	{
					if {$filled} {
						$can create oval $xpos1 [expr 77 + $m] $xpos2 [expr 83 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 77 + $m] $xpos2 [expr 83 + $m] -outline $evv(POINT) 
					}
				}
				63	{
					$can create text [expr $xpos1 - 4] [expr 84 + $m] -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT)
					if {$filled} {
						$can create oval $xpos1 [expr 77 + $m] $xpos2 [expr 83 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 77 + $m] $xpos2 [expr 83 + $m] -outline $evv(POINT) 
					}
				}
				62	{
					if {$filled} {
						$can create oval $xpos1 [expr 82 + $m] $xpos2 [expr 88 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 82 + $m] $xpos2 [expr 88 + $m] -outline $evv(POINT) 
					}
				}
				61	{
					$can create text [expr $xpos1 - 4] [expr 89 + $m] -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT)
					if {$filled} {
						$can create oval $xpos1 [expr 82 + $m] $xpos2 [expr 88 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 82 + $m] $xpos2 [expr 88 + $m] -outline $evv(POINT) 
					}
				}
				60	{
					if {$filled} {
						$can create oval $xpos1 [expr 87 + $m] $xpos2 [expr 93 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 87 + $m] $xpos2 [expr 93 + $m] -outline $evv(POINT) 
					}
					$can create line $xpos1leg [expr 90 + $m] $xpos2leg [expr 90 + $m] -fill $evv(POINT)
				}
				59	{
					if {$filled} {
						$can create oval $xpos1 [expr 92 + $m] $xpos2 [expr 98 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 92 + $m] $xpos2 [expr 98 + $m] -outline $evv(POINT) 
					}
					$can create line $xpos1leg [expr 90 + $m] $xpos2leg [expr 90 + $m] -fill $evv(POINT)
				}
				58	{
					$can create text [expr $xpos1 - 4] [expr 99 + $m] -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT)
					if {$filled} {
						$can create oval $xpos1 [expr 92 + $m] $xpos2 [expr 98 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 92 + $m] $xpos2 [expr 98 + $m] -outline $evv(POINT) 
					}
					$can create line $xpos1leg [expr 90 + $m] $xpos2leg [expr 90 + $m] -fill $evv(POINT)
				}
				57	{
					if {$filled} {
						$can create oval $xpos1 [expr 97 + $m] $xpos2 [expr 103 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 97 + $m] $xpos2 [expr 103 + $m] -outline $evv(POINT) 
					}
					$can create line $xpos1leg [expr 90 + $m] $xpos2leg [expr 90 + $m] -fill $evv(POINT)
					$can create line $xpos1leg [expr 100 + $m] $xpos2leg [expr 100 + $m] -fill $evv(POINT)
				}
				56	{
					$can create text [expr $xpos1 - 4] [expr 104 + $m] -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT)
					if {$filled} {
						$can create oval $xpos1 [expr 97 + $m] $xpos2 [expr 103 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 97 + $m] $xpos2 [expr 103 + $m] -outline $evv(POINT) 
					}
					$can create line $xpos1leg [expr 90 + $m] $xpos2leg [expr 90 + $m] -fill $evv(POINT)
					$can create line $xpos1leg [expr 100 + $m] $xpos2leg [expr 100 + $m] -fill $evv(POINT)
				}
				55	{
					if {$filled} {
						$can create oval $xpos1 [expr 102 + $m] $xpos2 [expr 108 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 102 + $m] $xpos2 [expr 108 + $m] -outline $evv(POINT) 
					}
					$can create line $xpos1leg [expr 90 + $m] $xpos2leg [expr 90 + $m] -fill $evv(POINT)
					$can create line $xpos1leg [expr 100 + $m] $xpos2leg [expr 100 + $m] -fill $evv(POINT)
				}
				54	{
					$can create text [expr $xpos1 - 4] [expr 109 + $m] -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT)
					if {$filled} {
						$can create oval $xpos1 [expr 102 + $m] $xpos2 [expr 108 + $m] -fill $evv(POINT) -outline $evv(POINT) 
					} else {
						$can create oval $xpos1 [expr 102 + $m] $xpos2 [expr 108 + $m] -outline $evv(POINT) 
					}
					$can create line $xpos1leg [expr 90 + $m] $xpos2leg [expr 90 + $m] -fill $evv(POINT)
					$can create line $xpos1leg [expr 100 + $m] $xpos2leg [expr 100 + $m] -fill $evv(POINT)
				}
			}
			incr offset [expr $evv(LEDGELEN) + 2]
		}
	}
}

proc GetRangeLimitOfMmark {fnam bottom} {
	global mtfmark
	set lim [lindex $mtfmark($fnam) 0]
	foreach pp [lrange $mtfmark($fnam) 1 end] {
		if {$bottom} {
			if {$pp < $lim} {
				set lim $pp
			}
		} elseif {$pp > $lim} {
			set lim $pp
		}
	}
	return $lim
}

proc DeleteMotifs {all} {
	global mtfmark chlist wstk pa evv
	if {![info exists mtfmark]} {
		Inf "No Motif Markers Exist"
		return
	}
	if {$all} {
		set msg "Are You Sure You Want To Delete All Existing Motif Marks ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		}
		catch {unset mtfmark}
	} else {
		if {![info exists chlist] || ([llength $chlist] <= 0)} {
			Inf "No Files Chosen"
			return
		}
		foreach fnam $chlist {
			if {$pa($fnam,$evv(FTYP)) == $evv(SNDFILE)} {
				lappend kbdsnds $fnam
			}
		}
		if {![info exists kbdsnds]} {
			Inf "No Sound Files Chosen"
			return
		}
		foreach fnam $kbdsnds {
			if {[info exists mtfmark($fnam)]} {
				lappend mtflist $fnam
			}
		}
		if {![info exists mtflist]} {
			Inf "No Selected Files Have Motif Information"
			return
		}
		set msg "Delete Motifs Associated With The Following Files\n"
		set cnt 0
		foreach fnam $mtflist {
			append msg "$fnam\n"
			incr cnt
			if {$cnt >= 20} {
				append msg "\nAND MORE"
				break
			}
		}
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		}
		foreach fnam $mtflist {
			catch {unset mtfmark($fnam)}
		}
	}
	if {![info exists mtfmark]} {	
		set fnam [file join $evv(URES_DIR) $evv(MTFMARK)$evv(CDP_EXT)]
		if {[file exists $fnam]} {
			if [catch {file delete $fnam} zit] {
				Inf "Cannot Delete File '$fnam' Containing Current Motif-Mark Data\nDelete By Hand To Ensure Data Does Not Reload In Next Session"
			}
		}
		return
	}
	StoreMtfMarks
}

proc MtfSndPlay {} {
	global mtf_snd evv
	if {[string length $mtf_snd] <= 0} {
		Inf "No Sound File Selected"
	} elseif {![file exists $mtf_snd]} {
		Inf "The Sound '$mtf_snd' Does Not Exist"
	} elseif {[FindFileType $mtf_snd] != $evv(SNDFILE)} {
		Inf "'$mtf_snd' Is Not A Soundfile"
	} else {
		PlaySndfile $mtf_snd 0
	}
}

proc TheMelodyFixer {} {
	global chlist mtfmark pmotifcan pa pr_mel mu motdelnotes pm_times pm_vals mtf_insnd_fnam mtf_fnam last_delnotes last_chord_notes evv
	global mtf_skew last_mtf_skew mtf_width motif_ms mtf_mstt mtf_mend last_mtf_mend last_mtf_mstt start_pm_vals start_pm_times mtfext
	global orig_pm_times orig_pm_vals
	if {![info exists chlist] || ([llength $chlist] != 2)} {
		Inf "Put Sndfile And Its Pitchdata Textfile On Chosen List"
		return
	}
	set motdelnotes {}
	catch {unset last_delnotes}
	catch {unset last_chord_notes}
	catch {unset last_mtf_skew}
	catch {unset last_mtf_mend}
	catch {unset last_mtf_mstt}
	catch {unset orig_pm_times}
	catch {unset orig_pm_vals}
	set mtf_insnd_fnam [lindex $chlist 0]
	if {$pa($mtf_insnd_fnam,$evv(FTYP)) != $evv(SNDFILE)} {
		set gotsnd 0
		set fnamm $mtf_insnd_fnam
		if {![IsABrkfile $pa($fnamm,$evv(FTYP))] \
		|| ($pa($fnamm,$evv(MINBRK)) < $mu(MIDIMIN)) || ($pa($fnamm,$evv(MAXBRK)) > $mu(MIDIMAX))} {
			Inf "1st File Is Neither A Soundfile Nor A Midi Data File"
			return
		}
	} else {
		set gotsnd 1
	}
	if {$gotsnd} {
		set fnamm [lindex $chlist 1]
		if {![IsABrkfile $pa($fnamm,$evv(FTYP))] \
		|| ($pa($fnamm,$evv(MINBRK)) < $mu(MIDIMIN)) || ($pa($fnamm,$evv(MAXBRK)) > $mu(MIDIMAX))} {
			Inf "2nd Chosen File Is Not Midi Data File"
			return
		}
	} else {
		set mtf_insnd_fnam [lindex $chlist 1]
		if {$pa($mtf_insnd_fnam,$evv(FTYP)) != $evv(SNDFILE)} {
			Inf "2nd Chosen File Is Not A Soundfile"
			return
		}
	}
	if [catch {open $fnamm "r"} zit] {
		Inf "Cannot Open File '$fnamm'"
		return
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		set line [split $line]
		set cnt 0
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {$cnt == 0} {
				lappend times $item
			} else {
				lappend vals [expr int(round($item))]
			}
			incr cnt
		}
	}
	close $zit
	if {[llength $times] != [llength $vals]} {
		Inf "The Input Textfile Is Not A Timed Midi-Data File"
		return
	}
	if [catch {eval {toplevel .melpage} -borderwidth $evv(BBDR)} zorg] {
		ErrShow "Failed to establish Motif Display Window"
		return
	}
	wm protocol .melpage WM_DELETE_WINDOW "set pr_mel 0"
	wm title .melpage "TIMED MIDI DATA WORKSHOP"
	set pr_mel 0
	set f .melpage
	frame $f.0
	frame $f.00
	frame $f.1
	frame $f.2
	frame $f.3
	frame $f.4
	frame $f.4x
	frame $f.4y
	frame $f.4a -bg $evv(POINT) -height 1
	frame $f.5
	frame $f.5y -bg $evv(POINT) -height 1
	frame $f.5a
	frame $f.5b
	button $f.0.quit -text "Close" -command "set pr_mel 0" -highlightbackground [option get . background {}]
	button $f.0.c  -text "C"  -bd 4 -command "PlaySndfile $evv(TESTFILE_C)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.0.db -text "Db" -bd 4 -command "PlaySndfile $evv(TESTFILE_Db) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.0.d  -text "D"  -bd 4 -command "PlaySndfile $evv(TESTFILE_D)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.0.eb -text "Eb" -bd 4 -command "PlaySndfile $evv(TESTFILE_Eb) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.0.e  -text "E"  -bd 4 -command "PlaySndfile $evv(TESTFILE_E)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.0.f  -text "F"  -bd 4 -command "PlaySndfile $evv(TESTFILE_F)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.0.gb -text "Gb" -bd 4 -command "PlaySndfile $evv(TESTFILE_Gb) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.0.g  -text "G"  -bd 4 -command "PlaySndfile $evv(TESTFILE_G)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.0.ab -text "Ab" -bd 4 -command "PlaySndfile $evv(TESTFILE_Ab) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.0.a  -text "A"  -bd 4 -command "PlaySndfile $evv(TESTFILE_A)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.0.bb -text "Bb" -bd 4 -command "PlaySndfile $evv(TESTFILE_Bb) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.0.b  -text "B"  -bd 4 -command "PlaySndfile $evv(TESTFILE_B)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.0.c2 -text "C"  -bd 4 -command "PlaySndfile $evv(TESTFILE_C2) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	label $f.0.play -text "" -width 14
	label $f.00.play -text "PLAY" -width 14

	label $f.0.ss -text "Src File: "
	label $f.0.sn -text [file tail $mtf_insnd_fnam] -width 48 -bg $evv(EMPH)

	pack $f.00.play -padx 2 -side left
	pack $f.0.quit $f.0.sn $f.0.ss $f.0.c2 $f.0.b $f.0.bb $f.0.a $f.0.ab $f.0.g $f.0.gb $f.0.f $f.0.e $f.0.eb $f.0.d $f.0.db $f.0.c -side right -padx 2

	button $f.1.pls -text "Source" -command "PlaySndfile $mtf_insnd_fnam 0" -width 13 -highlightbackground [option get . background {}]
	pack $f.1.pls -side left -padx 2

	radiobutton $f.1.r -text "Use Source Sound name" -variable dummy -value 1 -command UseSrcName
	pack $f.1.r -side right -padx 36

	radiobutton $f.1.r0 -text "Add 'mtf' to name " -variable mtfext -value 0 -command "MtfNameTypeAdd" -width 16
	radiobutton $f.1.r1 -text "Add 'midi' to name" -variable mtfext -value 1 -command "MtfNameTypeAdd" -width 16
	radiobutton $f.1.r2 -text "Add 'frq' to name " -variable mtfext -value 2 -command "MtfNameTypeAdd" -width 16
	pack $f.1.r2 $f.1.r1 $f.1.r0 -side right


	button $f.2.plm -text "Notation" -command "PlayNotation 0 1" -width 13 -highlightbackground [option get . background {}]
	label $f.2.save -text "Save  "
	button $f.2.s0 -text "As Motif Marker" -command "SaveUntimedMidiMotifData 0" -width 16 -highlightbackground [option get . background {}]
	label $f.2.s1 -text " As File "
	button $f.2.s2 -text "Untimed Midi List" -command "SaveUntimedMidiMotifData 1" -width 18 -highlightbackground [option get . background {}]
	button $f.2.s3 -text "Timed Midi Display" -command "SaveTimedMidiMotifData" -width 18 -highlightbackground [option get . background {}]
	button $f.2.s4 -text "Resynthesis Frqs" -command "SaveTimedFrqMotifData" -width 18 -highlightbackground [option get . background {}]
	label $f.2.ll -text "Filename"
	entry $f.2.e -textvariable mtf_fnam -width 16
	pack $f.2.plm $f.2.save $f.2.s0 $f.2.s1 $f.2.s2 $f.2.s3 $f.2.s4 $f.2.ll $f.2.e -side left -padx 2

	button $f.3.mm -text "Src+Notation" -command "PlayMotifAndSrc" -width 13 -highlightbackground [option get . background {}]
	label $f.3.ll -text "                Relative source level (1 - 8) "
	entry $f.3.e -textvariable mtf_skew -width 8
	label $f.3.bb -text "Start mix at"
	entry $f.3.be -textvariable mtf_mstt -width 8
	label $f.3.ss -text "Stop mix at"
	entry $f.3.bs -textvariable mtf_mend -width 8
	pack $f.3.mm $f.3.ll $f.3.e $f.3.bb $f.3.be $f.3.ss $f.3.bs -side left -padx 2

	button $f.4.ch -text "As Chord" -command "PlayNotation 1 1" -width 13 -highlightbackground [option get . background {}]
	label $f.4.save -text "Save  "
	button $f.4.sa -text "As Pitchmark" -command "SaveMotifAsPmark 0" -width 16 -highlightbackground [option get . background {}]
	label $f.4.s1 -text " As File "
	button $f.4.sb -text "HF Midi List" -command "SaveMotifAsPmark 1" -width 16 -highlightbackground [option get . background {}]
	button $f.4.sbb -text "HF Frq List" -command "SaveMotifAsPmark 2" -width 16 -highlightbackground [option get . background {}]
	radiobutton $f.4.r -text "Add 'hf' to name " -variable mtfext -value 3 -command "MtfNameTypeAdd" -width 16
	pack $f.4.ch $f.4.save $f.4.sa $f.4.s1 $f.4.sb $f.4.sbb -side left -padx 2
	pack $f.4.r -side left -padx 36

	button $f.4x.pm -text "Existing Pmark" -command "PlayPmark 1" -width 13 -highlightbackground [option get . background {}]
	button $f.4y.pm -text "Src + Pmark" -command "PlaySrcAndPmark" -width 13 -highlightbackground [option get . background {}]
	pack $f.4x.pm -side left -padx 2
	pack $f.4y.pm -side left -padx 2


	label $f.5.ll -text "DELETING NOTE : CLICK on Note to DELETE:                CONTROL-Click to RESTORE DELETES:              SHIFT-Click to RESTORE ALL DELETES:"
	pack $f.5.ll -side left
	label $f.5a.ll -text "MOVING NOTES  : ALT-Click SELECTS A NOTE TO MOVE:"
	pack $f.5a.ll -side left
	radiobutton $f.5b.ms0 -text "Delete/Restore Notes" -variable motif_ms -value 0 -command "MotifMouseSwitch 0"
	radiobutton $f.5b.ms1 -text "Move Marked Note" -variable motif_ms -value 1 -command "MotifMouseSwitch 1"
	radiobutton $f.5b.ms2 -text "Insert New Note" -variable motif_ms -value 2 -command "MotifMouseSwitch 2"
	pack $f.5b.ms0 $f.5b.ms1 $f.5b.ms2 -side left

	button $f.5b.lock -text "Keep New Motif" -command LockMotif -highlightbackground [option get . background {}]
	label $f.5b.dum -text "      "
	button $f.5b.restore -text "Restore Motif" -command RestoreOrigMotif -highlightbackground [option get . background {}]
	label $f.5b.dum0 -text "      "
	button $f.5b.origf -text "Initial Motif" -command RestoreStartMotif -highlightbackground [option get . background {}]
	pack $f.5b.lock $f.5b.dum $f.5b.restore $f.5b.dum0 $f.5b.origf -side right

	frame $f.6 -borderwidth $evv(SBDR)
	set width [expr $evv(CANVAS_DISPLAYED_WIDTH) * 2]
	set height [expr $evv(CANVAS_DISPLAYED_HEIGHT) / 3]
	set can [Scrolled_Canvas $f.6.c -width [expr $width + 50] -height $height -scrollregion "0 0 $width $height"]
	pack $f.6.c -fill both -expand true
	set mtfext -1
	set mtf_width $width
	set pm_times $times
	set pm_vals $vals
	set start_pm_times $pm_times
	set start_pm_vals $pm_vals
	set pmotifcan [EstablishEditableMotifDisplay $can $times $vals $width]
	bind $pmotifcan <ButtonRelease-1> "MgrafixDelPitch $pmotifcan %x %y"
	bind $pmotifcan <Control-ButtonRelease-1> "MgrafixRestorePitch $pmotifcan $width"
	bind $pmotifcan <Shift-ButtonRelease-1> "MgrafixRestorePitches $pmotifcan $width"
	bind $pmotifcan <Control-Shift-ButtonRelease-1> {}
	bind $pmotifcan <Command-ButtonRelease-1> "MgrafixMark $pmotifcan %x %y"
	pack $f.0 $f.00 $f.1 $f.2 $f.3 $f.4 $f.4x $f.4y -side top -fill x -expand true
	pack $f.4a -side top -pady 2 -fill x -expand true
	pack $f.5  -side top -fill x -expand true
	pack $f.5a -side top -fill x -expand true
	pack $f.5y -side top -pady 2 -fill x -expand true
	pack $f.5b -side top -fill x -expand true
	pack $f.6 -side top -fill x -expand true
	set mtf_fnam ""
	set mtf_mstt "start"
	set mtf_mend "end"
	set motif_ms 0
	set mtf_skew 1
	raise .melpage
	update idletasks
	StandardPosition2 .melpage
	My_Grab 0 $f pr_mel $pmotifcan
	tkwait variable pr_mel
	if {[file exists cdptest00$evv(SNDFILE_EXT)]} {
		if [catch {file delete cdptest00$evv(SNDFILE_EXT)} zit] {
			Inf "Cannot Delete Temporary File 'cdptest00$evv(SNDFILE_EXT)'"
		}
	}
	if {[file exists cdptest00$evv(TEXT_EXT)]} {
		if [catch {file delete cdptest00$evv(TEXT_EXT)} zit] {
			Inf "Cannot Delete Temporary File 'cdptest00$evv(TEXT_EXT)'"
		}
	}
	if {[file exists cdptest01$evv(SNDFILE_EXT)]} {
		if [catch {file delete cdptest01$evv(SNDFILE_EXT)} zit] {
			Inf "Cannot Delete Temporary File 'cdptest01$evv(SNDFILE_EXT)'"
		}
	}
	if {[file exists cdptest01$evv(TEXT_EXT)]} {
		if [catch {file delete cdptest01$evv(TEXT_EXT)} zit] {
			Inf "Cannot Delete Temporary File 'cdptest01$evv(TEXT_EXT)'"
		}
	}
	if {[file exists cdptest02$evv(SNDFILE_EXT)]} {
		if [catch {file delete cdptest02$evv(SNDFILE_EXT)} zit] {
			Inf "Cannot Delete Temporary File 'cdptest02$evv(SNDFILE_EXT)'"
		}
	}
	if {[file exists cdptest03$evv(SNDFILE_EXT)]} {
		if [catch {file delete cdptest03$evv(SNDFILE_EXT)} zit] {
			Inf "Cannot Delete Temporary File 'cdptest03$evv(SNDFILE_EXT)'"
		}
	}
	if {[file exists cdptest03$evv(TEXT_EXT)]} {
		if [catch {file delete cdptest03$evv(TEXT_EXT)} zit] {
			Inf "Cannot Delete Temporary File 'cdptest03$evv(TEXT_EXT)'"
		}
	}
	if {[file exists cdptest04$evv(SNDFILE_EXT)]} {
		if [catch {file delete cdptest04$evv(SNDFILE_EXT)} zit] {
			Inf "Cannot Delete Temporary File 'cdptest04$evv(SNDFILE_EXT)'"
		}
	}
	if {[file exists cdptest05$evv(SNDFILE_EXT)]} {
		if [catch {file delete cdptest05$evv(SNDFILE_EXT)} zit] {
			Inf "CANNOT DELETE TEMPORARY FILE 'cdptest05$evv(SNDFILE_EXT)'"
		}
	}
	if {[file exists cdptest0000$evv(TEXT_EXT)]} {
		if [catch {file delete cdptest0000$evv(TEXT_EXT)} zit] {
			Inf "Cannot Delete Temporary File 'cdptest0000$evv(TEXT_EXT)'"
		}
	}
	if {[file exists cdptest0000$evv(SNDFILE_EXT)]} {
		if [catch {file delete cdptest0000$evv(SNDFILE_EXT)} zit] {
			Inf "Cannot Delete Temporary File 'cdptest0000$evv(SNDFILE_EXT)'"
		}
	}
	My_Release_to_Dialog $f
	destroy $f
}

proc EstablishEditableMotifDisplay {can times vals width} {
	global pm_inbass evv

	#	CANVAS AND VALUE LISTING

	set maxtime [lindex $times end]
	set topp [lindex $vals 0]
	set botp [lindex $vals 0]
	foreach val [lrange $vals 1 end] {
		if {$val > $topp} {
			set topp $val
		} elseif {$val < $botp} {
			set botp $val
		}
	}
	if {$botp < 36} {
		$can create text 240 60 -anchor sw -text "RANGE TOO LOW TO REPRESENT" -fill $evv(POINT)
		return ""
	} elseif {$topp > 84} {
		$can create text 240 60 -anchor sw -text "RANGE TOO HIGH TO REPRESENT" -fill $evv(POINT)
		return ""
	}
	set pm_inbass 0
	if {$topp <= 60} {
		set pm_inbass 1
	} elseif {$topp <= 65} {
		if {$botp < 54} {
			set pm_inbass 1
		} else {
			set pm_inbass 0
		}
	} elseif {$botp >= 54} {
		set pm_inbass 0
	} elseif {$topp <= 74} {
		set pm_inbass -1
	} elseif {$botp >= 48 && $topp <= 84} {
		set pm_inbass 0
	} else {
		set range [expr $topp - $botp]
		$can create text 240 60 -anchor sw -text "RANGE ($botp to $topp) TOO LARGE TO REPRESENT" -fill $evv(POINT)
		return ""
	}
	$can create line 0  40 830 40 -tag notehite -fill $evv(POINT)	
	$can create line 0  50 830 50 -tag {notehite flathite} -fill $evv(POINT) 
	$can create line 0  60 830 60 -tag {notehite flathite} -fill $evv(POINT)
	$can create line 0  70 830 70 -tag {notehite flathite} -fill $evv(POINT)
	$can create line 0  80 830 80 -tag {notehite flathite} -fill $evv(POINT)

	set offset $evv(MTF_OFFSET)

	set width [expr $width - $offset]
	set width [expr $width - $evv(NOTEWIDTH)]

	if {$maxtime < 100.0} {
		$can create line $offset 150 830 150 -fill $evv(POINT) -tag tline
		set k 0.0
		set cnt 0
		set maxlim [expr $maxtime * 1.1]
		while {$k <= $maxlim} {
			set j [expr $k / $maxtime]
			set j [expr int(round($j * $width))]
			set pos [expr $offset + $j]
			set textpos [expr $pos - 4]
			if {$maxtime < 3.0} {
				if {[expr $cnt % 5] == 0} {
					$can create line $pos 140 $pos 155 -fill $evv(POINT) -tag tline
					set no [DecPlaces $k 1]
					$can create text $textpos 165 -anchor sw -text $no -font tiny_fnt -fill $evv(POINT) -tag tline
				} else {
					$can create line $pos 155 $pos 160 -fill $evv(POINT) -tag tline
				}
			} elseif {[expr $cnt % 2] == 0} {
				$can create line $pos 140 $pos 155 -fill $evv(POINT) -tag tline
				set no [DecPlaces $k 1]
				$can create text $textpos 165 -anchor sw -text $no -font tiny_fnt -fill $evv(POINT) -tag tline
			} else {
				$can create line $pos 155 $pos 160 -fill $evv(POINT) -tag tline
			}
			if {$maxtime < 3.0} {
				set k [expr $k + 0.1]
			} elseif {$maxtime < 10.0} {
				set k [expr $k + 0.5]
			} elseif {$maxtime < 100.0} {
				set k [expr $k + 5]
			}
			incr cnt
		}
	}
	if {$pm_inbass == 1} {
		#BASS CLEF
		set bclef2a [$can create arc 0 40 27 75 -style arc -start 30 -extent 120 -width 1 -outline $evv(POINT)]
		set bclef2b [$can create arc -55 15 25 85 -style arc -start 5 -extent -75 -width 1 -outline $evv(POINT)]
		set bclef2c [$can create oval 29 44 31 46 -fill $evv(POINT) -outline $evv(POINT)]
		set bclef2d [$can create oval 29 54 31 56 -fill $evv(POINT) -outline $evv(POINT)]
		set cnt 0
		foreach note $vals {
			set xpos1 [expr [lindex $times $cnt] / $maxtime]
			set xpos1 [expr int(round($xpos1 * $width))]
			set xpos1 [expr $xpos1 + $offset]
			set xpos2	 [expr $xpos1 + $evv(NOTEWIDTH)]
			set xpos1leg [expr $xpos1 - $evv(LEDGE_OFFSET)]
			set xpos2leg [expr $xpos1leg + $evv(LEDGELEN)]

			switch -- $note {
				65	{
					$can create oval $xpos1 12 $xpos2 18 -outline $evv(POINT) -tag " 65 note no$cnt"
					$can create line $xpos1leg 20 $xpos2leg 20 -fill $evv(POINT) -tag " 65 no$cnt"
					$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 65 no$cnt"
				}
				64	{
					$can create oval $xpos1 17 $xpos2 23 -outline $evv(POINT) -tag " 64 note no$cnt"
					$can create line $xpos1leg 20 $xpos2leg 20 -fill $evv(POINT) -tag " 64 no$cnt"
					$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 64 no$cnt"
				}
				63	{
					$can create text [expr $xpos1 - 4] 24 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 63 no$cnt"
					$can create oval $xpos1 17 $xpos2 23 -outline $evv(POINT) -tag " 63 note no$cnt"
					$can create line $xpos1leg 20 $xpos2leg 20 -fill $evv(POINT) -tag " 63 no$cnt"
					$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 63 no$cnt"
				}
				62	{
					$can create oval $xpos1 22 $xpos2 28 -outline $evv(POINT) -tag " 62 note no$cnt"
					$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 62 no$cnt"
				}
				61	{
					$can create text [expr $xpos1 - 4] 29 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 61 no$cnt"
					$can create oval $xpos1 22 $xpos2 28 -outline $evv(POINT)  -tag " 61 note no$cnt"
					$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 61 no$cnt"
				}
				60	{
					$can create oval $xpos1 27 $xpos2 33 -outline $evv(POINT) -tag " 60 note no$cnt"
					$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 60 no$cnt"
				}
				59	{
					$can create oval $xpos1 32 $xpos2 38 -outline $evv(POINT) -tag " 59 note no$cnt"
				}
				58	{
					$can create text [expr $xpos1 - 4] 39 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 58 no$cnt"
					$can create oval $xpos1 32 $xpos2 38 -outline $evv(POINT)  -tag " 58 note no$cnt"
				}
				57	{
					$can create oval $xpos1 37 $xpos2 43 -outline $evv(POINT)  -tag " 57 note no$cnt"
				}
				56 {
					$can create text [expr $xpos1 - 4] 44 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 56 no$cnt"
					$can create oval $xpos1 37 $xpos2 43 -outline $evv(POINT)  -tag " 56 note no$cnt"
				}
				55	{
					$can create oval $xpos1 42 $xpos2 48 -outline $evv(POINT)  -tag " 55 note no$cnt"
				}
				54	{
					$can create text [expr $xpos1 - 4] 49 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 54 no$cnt"
					$can create oval $xpos1 42 $xpos2 48 -outline $evv(POINT)  -tag " 54 note no$cnt"
				}
				53	{
					$can create oval $xpos1 47 $xpos2 53 -outline $evv(POINT)  -tag " 53 note no$cnt"
				}
				52	{
					$can create oval $xpos1 52 $xpos2 58 -outline $evv(POINT)  -tag " 52 note no$cnt"
				}
				51	{
					$can create text [expr $xpos1 - 4] 59 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 51 no$cnt"
					$can create oval $xpos1 52 $xpos2 58 -outline $evv(POINT)  -tag " 51 note no$cnt"
				}
				50	{
					$can create oval $xpos1 57 $xpos2 63 -outline $evv(POINT)  -tag " 50 note no$cnt"
				}
				49	{
					$can create text [expr $xpos1 - 4] 64 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 49 no$cnt"
					$can create oval $xpos1 57 $xpos2 63 -outline $evv(POINT)  -tag " 49 note no$cnt"
				}
				48	{
					$can create oval $xpos1 62 $xpos2 68 -outline $evv(POINT)  -tag " 48 note no$cnt"
				}
				47	{
					$can create oval $xpos1 67 $xpos2 73 -outline $evv(POINT)  -tag " 47 note no$cnt"
				}
				46	{
					$can create text [expr $xpos1 - 4] 74 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 46 no$cnt"
					$can create oval $xpos1 67 $xpos2 73 -outline $evv(POINT)  -tag " 46 note no$cnt"
				}
				45	{
					$can create oval $xpos1 72 $xpos2 78 -outline $evv(POINT)  -tag " 45 note no$cnt"
				}
				44	{
					$can create text [expr $xpos1 - 4] 79 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 44 no$cnt"
					$can create oval $xpos1 72 $xpos2 78 -outline $evv(POINT)  -tag " 44 note no$cnt"
				}
				43	{
					$can create oval $xpos1 77 $xpos2 83 -outline $evv(POINT)  -tag " 43 note no$cnt"
				}
				42	{
					$can create text [expr $xpos1 - 4] 84 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 42 no$cnt"
					$can create oval $xpos1 77 $xpos2 83 -outline $evv(POINT)  -tag " 42 note no$cnt"
				}
				41	{
					$can create oval $xpos1 82 $xpos2 88 -outline $evv(POINT)  -tag " 41 note no$cnt"
				}
				40	{
					$can create oval $xpos1 87 $xpos2 93 -outline $evv(POINT)  -tag " 40 note no$cnt"
					$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 40 no$cnt"
				}
				39	{
					$can create text [expr $xpos1 - 4] 94 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 39 no$cnt"
					$can create oval $xpos1 87 $xpos2 93 -outline $evv(POINT)  -tag " 39 note no$cnt"
					$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 39 no$cnt"
				}
				38	{
					$can create oval $xpos1 92 $xpos2 98 -outline $evv(POINT)  -tag " 38 note no$cnt"
					$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 38 no$cnt"
				}
				37	{
					$can create text [expr $xpos1 - 4] 99 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 37 no$cnt"
					$can create oval $xpos1 92 $xpos2 98 -outline $evv(POINT)  -tag " 37 note no$cnt"
					$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 37 no$cnt"
				}
				36	{
					$can create oval $xpos1 97 $xpos2 103 -outline $evv(POINT)  -tag " 36 note no$cnt"
					$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 36 no$cnt"
					$can create line $xpos1leg 100 $xpos2leg 100 -fill $evv(POINT) -tag " 36 no$cnt"
				}
			}
			incr cnt
		}
	} elseif {$pm_inbass == -1} {
		#TREBLE CLEF DOWN 8va
		set clef1a [$can create line 10 30 10 95 -width 1 -fill $evv(POINT)]
		set clef1b [$can create arc  10 24 22 36 -style arc -start 180 -extent -230 -width 1 -outline $evv(POINT)]
		set clef1c [$can create line 18 35 0  70 -width 1 -fill $evv(POINT)]
		set clef1d [$can create arc  0  60 20 80 -style arc -start 180 -extent 270 -width 1 -outline $evv(POINT)]
		$can create text 7 110 -anchor sw -text "8" -font bigfnt -fill $evv(POINT)
		set cnt 0
		foreach note $vals {
			set xpos1 [expr [lindex $times $cnt] / $maxtime]
			set xpos1 [expr int(round($xpos1 * $width))]
			set xpos1 [expr $xpos1 + $offset]
			set xpos2	 [expr $xpos1 + $evv(NOTEWIDTH)]
			set xpos1leg [expr $xpos1 - $evv(LEDGE_OFFSET)]
			set xpos2leg [expr $xpos1leg + $evv(LEDGELEN)]
			switch -- $note {
				74	{
					$can create oval $xpos1 12 $xpos2 18 -outline $evv(POINT) -tag " 74 note no$cnt"
					$can create line $xpos1leg 20 $xpos2leg 20 -fill $evv(POINT) -tag " 74 no$cnt"
					$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 74 no$cnt"
				}
				73	{
					$can create text [expr $xpos1 - 4] 19 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 73 no$cnt"
					$can create oval $xpos1 12 $xpos2 18 -outline $evv(POINT) -tag " 73 note no$cnt"
					$can create line $xpos1leg 20 $xpos2leg 20 -fill $evv(POINT) -tag " 73 no$cnt"
					$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 73 no$cnt"
				}
				72	{
					$can create oval $xpos1 17 $xpos2 23 -outline $evv(POINT) -tag " 72 note no$cnt"
					$can create line $xpos1leg 20 $xpos2leg 20 -fill $evv(POINT) -tag " 72 no$cnt"
					$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 72 no$cnt"
				}
				71	{
					$can create oval $xpos1 22 $xpos2 28 -outline $evv(POINT) -tag " 71 note no$cnt"
					$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 71 no$cnt"
				}
				70	{
					$can create text [expr $xpos1 - 4] 29 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 70 no$cnt"
					$can create oval $xpos1 22 $xpos2 28 -outline $evv(POINT)  -tag " 70 note no$cnt"
					$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 70 no$cnt"
				}
				69	{
					$can create oval $xpos1 27 $xpos2 33 -outline $evv(POINT)  -tag " 69 note no$cnt"
					$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 69 no$cnt"
				}
				68	{
					$can create text [expr $xpos1 - 4] 34 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 68 no$cnt"
					$can create oval $xpos1 27 $xpos2 33 -outline $evv(POINT)  -tag " 68 note no$cnt"
					$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 68 no$cnt"
				}
				67	{
					$can create oval $xpos1 32 $xpos2 38 -outline $evv(POINT)  -tag " 67 note no$cnt"
				}
				66	{
					$can create text [expr $xpos1 - 4] 39 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 66 no$cnt"
					$can create oval $xpos1 32 $xpos2 38 -outline $evv(POINT)  -tag " 66 note no$cnt"
				}
				65	{
					$can create oval $xpos1 37 $xpos2 43 -outline $evv(POINT)  -tag " 65 note no$cnt"
				}
				64	{
					$can create oval $xpos1 42 $xpos2 48 -outline $evv(POINT)  -tag " 64 note no$cnt"
				}
				63	{
					$can create text [expr $xpos1 - 4] 49 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 63 no$cnt"
					$can create oval $xpos1 42 $xpos2 48 -outline $evv(POINT)  -tag " 63 note no$cnt"
				}
				62	{
					$can create oval $xpos1 47 $xpos2 53 -outline $evv(POINT)  -tag " 62 note no$cnt"
				}
				61	{
					$can create text [expr $xpos1 - 4] 54 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 61 no$cnt"
					$can create oval $xpos1 47 $xpos2 53 -outline $evv(POINT)  -tag " 61 note no$cnt"
				}
				60	{
					$can create oval $xpos1 52 $xpos2 58 -outline $evv(POINT)  -tag " 60 note no$cnt"
				}
				59	{
					$can create oval $xpos1 57 $xpos2 63 -outline $evv(POINT)  -tag " 59 note no$cnt"
				}
				58	{
					$can create text [expr $xpos1 - 4] 64 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 58 no$cnt"
					$can create oval $xpos1 57 $xpos2 63 -outline $evv(POINT)  -tag " 58 note no$cnt"
				}
				57	{
					$can create oval $xpos1 62 $xpos2 68 -outline $evv(POINT)  -tag " 57 note no$cnt"
				}
				56	{
					$can create text [expr $xpos1 - 4] 69 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 56 no$cnt"
					$can create oval $xpos1 62 $xpos2 68 -outline $evv(POINT)  -tag " 56 note no$cnt"
				}
				55	{
					$can create oval $xpos1 67 $xpos2 73 -outline $evv(POINT)  -tag " 55 note no$cnt"
				}
				54	{
					$can create text [expr $xpos1 - 4] 74 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 54 no$cnt"
					$can create oval $xpos1 67 $xpos2 73 -outline $evv(POINT)  -tag " 54 note no$cnt"
				}
				53	{
					$can create oval $xpos1 72 $xpos2 78 -outline $evv(POINT)  -tag " 53 note no$cnt"
				}
				52	{
					$can create oval $xpos1 77 $xpos2 83 -outline $evv(POINT)  -tag " 52 note no$cnt"
				}
				51	{
					$can create text [expr $xpos1 - 4] 84 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 51 no$cnt"
					$can create oval $xpos1 77 $xpos2 83 -outline $evv(POINT)  -tag " 51 note no$cnt"
				}
				50	{
					$can create oval $xpos1 82 $xpos2 88 -outline $evv(POINT)  -tag " 50 note no$cnt"
				}
				49	{
					$can create text [expr $xpos1 - 4] 89 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 49 no$cnt"
					$can create oval $xpos1 82 $xpos2 88 -outline $evv(POINT)  -tag " 49 note no$cnt"
				}
				48	{
					$can create oval $xpos1 87 $xpos2 93 -outline $evv(POINT)  -tag " 48 note no$cnt"
					$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 48 no$cnt"
				}
				47	{
					$can create oval $xpos1 92 $xpos2 98 -outline $evv(POINT)  -tag " 47 note no$cnt"
					$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 47 no$cnt"
				}
				46	{
					$can create text [expr $xpos1 - 4] 99 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 46 no$cnt"
					$can create oval $xpos1 92 $xpos2 98 -outline $evv(POINT)  -tag " 46 note no$cnt"
					$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 46 no$cnt"
				}
				45	{
					$can create oval $xpos1 97 $xpos2 103 -outline $evv(POINT)  -tag " 45 note no$cnt"
					$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 45 no$cnt"
					$can create line $xpos1leg 100 $xpos2leg 100 -fill $evv(POINT) -tag " 45 no$cnt"
				}
				44	{
					$can create text [expr $xpos1 - 4] 104 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 44 no$cnt"
					$can create oval $xpos1 97 $xpos2 103 -outline $evv(POINT)  -tag " 44 note no$cnt"
					$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 44 no$cnt"
					$can create line $xpos1leg 100 $xpos2leg 100 -fill $evv(POINT) -tag " 44 no$cnt"
				}
				43	{
					$can create oval $xpos1 102 $xpos2 108 -outline $evv(POINT)  -tag " 43 note no$cnt"
					$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 43 no$cnt"
					$can create line $xpos1leg 100 $xpos2leg 100 -fill $evv(POINT) -tag " 43 no$cnt"
				}
				42	{
					$can create text [expr $xpos1 - 4] 109 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 42 no$cnt"
					$can create oval $xpos1 102 $xpos2 108 -outline $evv(POINT)  -tag " 42 note no$cnt"
					$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 42 no$cnt"
					$can create line $xpos1leg 100 $xpos2leg 100 -fill $evv(POINT) -tag " 42 no$cnt"
				}
			}
			incr cnt
		}
	} else {
		#TREBLE CLEF
		set clef1a [$can create line 10 30 10 95 -width 1 -fill $evv(POINT)]
		set clef1b [$can create arc  10 24 22 36 -style arc -start 180 -extent -230 -width 1 -outline $evv(POINT)]
		set clef1c [$can create line 18 35 0  70 -width 1 -fill $evv(POINT)]
		set clef1d [$can create arc  0  60 20 80 -style arc -start 180 -extent 270 -width 1 -outline $evv(POINT)]
		set cnt 0
		foreach note $vals {
			set xpos1 [expr [lindex $times $cnt] / $maxtime]
			set xpos1 [expr int(round($xpos1 * $width))]
			set xpos1 [expr $xpos1 + $offset]
			set xpos2	 [expr $xpos1 + $evv(NOTEWIDTH)]
			set xpos1leg [expr $xpos1 - $evv(LEDGE_OFFSET)]
			set xpos2leg [expr $xpos1leg + $evv(LEDGELEN)]
			switch -- $note {
				84	{
					$can create oval $xpos1 17 $xpos2 23 -outline $evv(POINT) -tag " 84 note no$cnt"
					$can create line $xpos1leg 20 $xpos2leg 20 -fill $evv(POINT) -tag " 84 no$cnt"
					$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 84 no$cnt"
				}
				83	{
					$can create oval $xpos1 22 $xpos2 28 -outline $evv(POINT) -tag " 83 note no$cnt"
					$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 83 no$cnt"
				}
				82	{
					$can create text [expr $xpos1 - 4] 29 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 82 no$cnt"
					$can create oval $xpos1 22 $xpos2 28 -outline $evv(POINT)  -tag " 82 note no$cnt"
					$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 82 no$cnt"
				}
				81	{
					$can create oval $xpos1 27 $xpos2 33 -outline $evv(POINT)  -tag " 81 note no$cnt"
					$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 81 no$cnt"
				}
				80	{
					$can create text [expr $xpos1 - 4] 34 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 80 no$cnt"
					$can create oval $xpos1 27 $xpos2 33 -outline $evv(POINT)  -tag " 80 note no$cnt"
					$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 80 no$cnt"
				}
				79	{
					$can create oval $xpos1 32 $xpos2 38 -outline $evv(POINT)  -tag " 79 note no$cnt"
				}
				78	{
					$can create text [expr $xpos1 - 4] 39 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 78 no$cnt"
					$can create oval $xpos1 32 $xpos2 38 -outline $evv(POINT)  -tag " 78 note no$cnt"
				}
				77	{
					$can create oval $xpos1 37 $xpos2 43 -outline $evv(POINT)  -tag " 77 note no$cnt"
				}
				76	{
					$can create oval $xpos1 42 $xpos2 48 -outline $evv(POINT)  -tag " 76 note no$cnt"
				}
				75	{
					$can create text [expr $xpos1 - 4] 49 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 75 no$cnt"
					$can create oval $xpos1 42 $xpos2 48 -outline $evv(POINT)  -tag " 75 note no$cnt"
				}
				74	{
					$can create oval $xpos1 47 $xpos2 53 -outline $evv(POINT)  -tag " 74 note no$cnt"
				}
				73	{
					$can create text [expr $xpos1 - 4] 54 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 73 no$cnt"
					$can create oval $xpos1 47 $xpos2 53 -outline $evv(POINT)  -tag " 73 note no$cnt"
				}
				72	{
					$can create oval $xpos1 52 $xpos2 58 -outline $evv(POINT)  -tag " 72 note no$cnt"
				}
				71	{
					$can create oval $xpos1 57 $xpos2 63 -outline $evv(POINT)  -tag " 71 note no$cnt"
				}
				70	{
					$can create text [expr $xpos1 - 4] 64 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 70 no$cnt"
					$can create oval $xpos1 57 $xpos2 63 -outline $evv(POINT)  -tag " 70 note no$cnt"
				}
				69	{
					$can create oval $xpos1 62 $xpos2 68 -outline $evv(POINT)  -tag " 69 note no$cnt"
				}
				68	{
					$can create text [expr $xpos1 - 4] 69 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 68 no$cnt"
					$can create oval $xpos1 62 $xpos2 68 -outline $evv(POINT)  -tag " 68 note no$cnt"
				}
				67	{
					$can create oval $xpos1 67 $xpos2 73 -outline $evv(POINT)  -tag " 67 note no$cnt"
				}
				66	{
					$can create text [expr $xpos1 - 4] 74 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 66 no$cnt"
					$can create oval $xpos1 67 $xpos2 73 -outline $evv(POINT)  -tag " 66 note no$cnt"
				}
				65	{
					$can create oval $xpos1 72 $xpos2 78 -outline $evv(POINT)  -tag " 65 note no$cnt"
				}
				64	{
					$can create oval $xpos1 77 $xpos2 83 -outline $evv(POINT)  -tag " 64 note no$cnt"
				}
				63	{
					$can create text [expr $xpos1 - 4] 84 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 63 no$cnt"
					$can create oval $xpos1 77 $xpos2 83 -outline $evv(POINT)  -tag " 63 note no$cnt"
				}
				62	{
					$can create oval $xpos1 82 $xpos2 88 -outline $evv(POINT)  -tag " 62 note no$cnt"
				}
				61	{
					$can create text [expr $xpos1 - 4] 89 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 61 no$cnt"
					$can create oval $xpos1 82 $xpos2 88 -outline $evv(POINT)  -tag " 61 note no$cnt"
				}
				60	{
					$can create oval $xpos1 87 $xpos2 93 -outline $evv(POINT)  -tag " 60 note no$cnt"
					$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 60 no$cnt"
				}
				59	{
					$can create oval $xpos1 92 $xpos2 98 -outline $evv(POINT)  -tag " 59 note no$cnt"
					$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 59 no$cnt"
				}
				58	{
					$can create text [expr $xpos1 - 4] 99 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 58 no$cnt"
					$can create oval $xpos1 92 $xpos2 98 -outline $evv(POINT)  -tag " 58 note no$cnt"
					$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 58 no$cnt"
				}
				57	{
					$can create oval $xpos1 97 $xpos2 103 -outline $evv(POINT)  -tag " 57 note no$cnt"
					$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 57 no$cnt"
					$can create line $xpos1leg 100 $xpos2leg 100 -fill $evv(POINT) -tag " 57 no$cnt"
				}
				56	{
					$can create text [expr $xpos1 - 4] 104 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 56 no$cnt"
					$can create oval $xpos1 97 $xpos2 103 -outline $evv(POINT)  -tag " 56 note no$cnt"
					$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 56 no$cnt"
					$can create line $xpos1leg 100 $xpos2leg 100 -fill $evv(POINT) -tag " 56 no$cnt"
				}
				55	{
					$can create oval $xpos1 102 $xpos2 108 -outline $evv(POINT)  -tag " 55 note no$cnt"
					$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 55 no$cnt"
					$can create line $xpos1leg 100 $xpos2leg 100 -fill $evv(POINT) -tag " 55 no$cnt"
				}
				54	{
					$can create text [expr $xpos1 - 4] 109 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 54 no$cnt"
					$can create oval $xpos1 102 $xpos2 108 -outline $evv(POINT)  -tag " 54 note no$cnt"
					$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 54 no$cnt"
					$can create line $xpos1leg 100 $xpos2leg 100 -fill $evv(POINT) -tag " 54 no$cnt"
				}
				53	{
					$can create oval $xpos1 107 $xpos2 113 -outline $evv(POINT)  -tag " 53 note no$cnt"
					$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 53 no$cnt"
					$can create line $xpos1leg 100 $xpos2leg 100 -fill $evv(POINT) -tag " 53 no$cnt"
					$can create line $xpos1leg 110 $xpos2leg 110 -fill $evv(POINT) -tag " 53 no$cnt"
				}
				52	{
					$can create oval $xpos1 112 $xpos2 118 -outline $evv(POINT)  -tag " 52 note no$cnt"
					$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 52 no$cnt"
					$can create line $xpos1leg 100 $xpos2leg 100 -fill $evv(POINT) -tag " 52 no$cnt"
					$can create line $xpos1leg 110 $xpos2leg 110 -fill $evv(POINT) -tag " 52 no$cnt"
				}
				51	{
					$can create text [expr $xpos1 - 4] 119 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 51 no$cnt"
					$can create oval $xpos1 112 $xpos2 118 -outline $evv(POINT)  -tag " 51 note no$cnt"
					$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 51 no$cnt"
					$can create line $xpos1leg 100 $xpos2leg 100 -fill $evv(POINT) -tag " 51 no$cnt"
					$can create line $xpos1leg 110 $xpos2leg 110 -fill $evv(POINT) -tag " 51 no$cnt"
				}
				50	{
					$can create oval $xpos1 117 $xpos2 123 -outline $evv(POINT)  -tag " 50 note no$cnt"
					$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 50 no$cnt"
					$can create line $xpos1leg 100 $xpos2leg 100 -fill $evv(POINT) -tag " 50 no$cnt"
					$can create line $xpos1leg 110 $xpos2leg 110 -fill $evv(POINT) -tag " 50 no$cnt"
					$can create line $xpos1leg 120 $xpos2leg 120 -fill $evv(POINT) -tag " 50 no$cnt"
				}
				49	{
					$can create text [expr $xpos1 - 4] 124 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 49 no$cnt"
					$can create oval $xpos1 117 $xpos2 123 -outline $evv(POINT)  -tag " 49 note no$cnt"
					$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 49 no$cnt"
					$can create line $xpos1leg 100 $xpos2leg 100 -fill $evv(POINT) -tag " 49 no$cnt"
					$can create line $xpos1leg 110 $xpos2leg 110 -fill $evv(POINT) -tag " 49 no$cnt"
					$can create line $xpos1leg 120 $xpos2leg 120 -fill $evv(POINT) -tag " 49 no$cnt"
				}
				48	{
					$can create oval $xpos1 122 $xpos2 128 -outline $evv(POINT)  -tag " 48 note no$cnt"
					$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 48 no$cnt"
					$can create line $xpos1leg 100 $xpos2leg 100 -fill $evv(POINT) -tag " 48 no$cnt"
					$can create line $xpos1leg 110 $xpos2leg 110 -fill $evv(POINT) -tag " 48 no$cnt"
					$can create line $xpos1leg 120 $xpos2leg 120 -fill $evv(POINT) -tag " 48 no$cnt"
				}
			}
			incr cnt
		}

	}
	return $can
}

proc MgrafixDelPitch {w x y} {
	global motdelnotes mtfnote_marked mtfnote_time mtfnote_pich mtfnote_lotime mtfnote_hitime

	set displaylist [$w find withtag note]	;#	List all objects which are notes

	set mindiffx 100000								;#	Find closest note
	set mindiffy 100000
	set finished 0
	foreach thisobj $displaylist {
		set coords [$w coords $thisobj]
		set xx [lindex $coords 0]
		set yy [lindex $coords 1]
		set diff [expr abs($x - ($xx + 4))]
		if {$diff < $mindiffx} {
			set gotobj $thisobj
			set mindiffx $diff
			set mindiffy [expr abs($y - ($yy + 3))]
		} elseif {$diff == $mindiffx} {
			set diff [expr abs($y - ($yy + 3))]
			if {$diff < $mindiffy} {
				set mindiffy $diff
				set gotobj $thisobj
			}
		}
	}
	if {![info exists gotobj]} {
		Inf "No Note Found At Mouse Click"
		return
	}
	set tag_list [$w gettags $gotobj]
	set noteno [lindex $tag_list end]
	if {$noteno == "current"} {
		Inf "Try Again"
		return
	}
	set nunote [string range $noteno 2 end]
	set k [lsearch $motdelnotes $nunote]
	if {$k < 0} {
		lappend motdelnotes $nunote
	}
	$w delete withtag $noteno
	MotifMouseSwitch 0
}

proc MgrafixRestorePitch {w width} {
	global motdelnotes pm_times pm_vals
	if {![info exists motdelnotes] || ([llength $motdelnotes] <= 0)} {
		Inf "No Notes Deleted"
		return
	}
	set delnote [lindex $motdelnotes end]
	set time [lindex $pm_times $delnote]	
	set note [lindex $pm_vals $delnote]
	RedrawMgrafixPitch $time $note $w $width $delnote
	set len [llength $motdelnotes] 
	if {$len == 1} {
		set motdelnotes {}
	} else {
		incr len -2
		set motdelnotes [lrange $motdelnotes 0 $len]
	}
}

proc MgrafixRestorePitches {w width} {
	global motdelnotes pm_times pm_vals
	if {![info exists motdelnotes] || ([llength $motdelnotes] <= 0)} {
		Inf "No Notes Deleted"
		return
	}
	foreach delnote $motdelnotes {
		set time [lindex $pm_times $delnote]	
		set note [lindex $pm_vals $delnote]
		RedrawMgrafixPitch $time $note $w $width $delnote
		set len [llength $motdelnotes] 
		if {$len == 1} {
			set motdelnotes {}
		} else {
			incr len -2
			set motdelnotes [lrange $motdelnotes 0 $len]
		}
	}
}

proc RedrawMgrafixPitch {time note can width cnt} {
	global pm_inbass pm_times evv
	set maxtime [lindex $pm_times end]
	set offset $evv(MTF_OFFSET)
	set width [expr $width - $offset]
	set width [expr $width - $evv(NOTEWIDTH)]
	if {$pm_inbass == 1} {
		set xpos1 [expr $time / $maxtime]
		set xpos1 [expr int(round($xpos1 * $width))]
		set xpos1 [expr $xpos1 + $offset]
		set xpos2	 [expr $xpos1 + $evv(NOTEWIDTH)]
		set xpos1leg [expr $xpos1 - $evv(LEDGE_OFFSET)]
		set xpos2leg [expr $xpos1leg + $evv(LEDGELEN)]
		switch -- $note {
			65	{
				$can create oval $xpos1 12 $xpos2 18 -outline $evv(POINT) -tag " 65 note no$cnt"
				$can create line $xpos1leg 20 $xpos2leg 20 -fill $evv(POINT) -tag " 65 no$cnt"
				$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 65 no$cnt"
			}
			64	{
				$can create oval $xpos1 17 $xpos2 23 -outline $evv(POINT) -tag " 64 note no$cnt"
				$can create line $xpos1leg 20 $xpos2leg 20 -fill $evv(POINT) -tag " 64 no$cnt"
				$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 64 no$cnt"
			}
			63	{
				$can create text [expr $xpos1 - 4] 24 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 63 no$cnt"
				$can create oval $xpos1 17 $xpos2 23 -outline $evv(POINT) -tag " 63 note no$cnt"
				$can create line $xpos1leg 20 $xpos2leg 20 -fill $evv(POINT) -tag " 63 no$cnt"
				$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 63 no$cnt"
			}
			62	{
				$can create oval $xpos1 22 $xpos2 28 -outline $evv(POINT) -tag " 62 note no$cnt"
				$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 62 no$cnt"
			}
			61	{
				$can create text [expr $xpos1 - 4] 29 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 61 no$cnt"
				$can create oval $xpos1 22 $xpos2 28 -outline $evv(POINT)  -tag " 61 note no$cnt"
				$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 61 no$cnt"
			}
			60	{
				$can create oval $xpos1 27 $xpos2 33 -outline $evv(POINT) -tag " 60 note no$cnt"
				$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 60 no$cnt"
			}
			59	{
				$can create oval $xpos1 32 $xpos2 38 -outline $evv(POINT) -tag " 59 note no$cnt"
			}
			58	{
				$can create text [expr $xpos1 - 4] 39 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 58 no$cnt"
				$can create oval $xpos1 32 $xpos2 38 -outline $evv(POINT)  -tag " 58 note no$cnt"
			}
			57	{
				$can create oval $xpos1 37 $xpos2 43 -outline $evv(POINT)  -tag " 57 note no$cnt"
			}
			56 {
				$can create text [expr $xpos1 - 4] 44 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 56 no$cnt"
				$can create oval $xpos1 37 $xpos2 43 -outline $evv(POINT)  -tag " 56 note no$cnt"
			}
			55	{
				$can create oval $xpos1 42 $xpos2 48 -outline $evv(POINT)  -tag " 55 note no$cnt"
			}
			54	{
				$can create text [expr $xpos1 - 4] 49 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 54 no$cnt"
				$can create oval $xpos1 42 $xpos2 48 -outline $evv(POINT)  -tag " 54 note no$cnt"
			}
			53	{
				$can create oval $xpos1 47 $xpos2 53 -outline $evv(POINT)  -tag " 53 note no$cnt"
			}
			52	{
				$can create oval $xpos1 52 $xpos2 58 -outline $evv(POINT)  -tag " 52 note no$cnt"
			}
			51	{
				$can create text [expr $xpos1 - 4] 59 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 51 no$cnt"
				$can create oval $xpos1 52 $xpos2 58 -outline $evv(POINT)  -tag " 51 note no$cnt"
			}
			50	{
				$can create oval $xpos1 57 $xpos2 63 -outline $evv(POINT)  -tag " 50 note no$cnt"
			}
			49	{
				$can create text [expr $xpos1 - 4] 64 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 49 no$cnt"
				$can create oval $xpos1 57 $xpos2 63 -outline $evv(POINT)  -tag " 49 note no$cnt"
			}
			48	{
				$can create oval $xpos1 62 $xpos2 68 -outline $evv(POINT)  -tag " 48 note no$cnt"
			}
			47	{
				$can create oval $xpos1 67 $xpos2 73 -outline $evv(POINT)  -tag " 47 note no$cnt"
			}
			46	{
				$can create text [expr $xpos1 - 4] 74 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 46 no$cnt"
				$can create oval $xpos1 67 $xpos2 73 -outline $evv(POINT)  -tag " 46 note no$cnt"
			}
			45	{
				$can create oval $xpos1 72 $xpos2 78 -outline $evv(POINT)  -tag " 45 note no$cnt"
			}
			44	{
				$can create text [expr $xpos1 - 4] 79 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 44 no$cnt"
				$can create oval $xpos1 72 $xpos2 78 -outline $evv(POINT)  -tag " 44 note no$cnt"
			}
			43	{
				$can create oval $xpos1 77 $xpos2 83 -outline $evv(POINT)  -tag " 43 note no$cnt"
			}
			42	{
				$can create text [expr $xpos1 - 4] 84 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 42 no$cnt"
				$can create oval $xpos1 77 $xpos2 83 -outline $evv(POINT)  -tag " 42 note no$cnt"
			}
			41	{
				$can create oval $xpos1 82 $xpos2 88 -outline $evv(POINT)  -tag " 41 note no$cnt"
			}
			40	{
				$can create oval $xpos1 87 $xpos2 93 -outline $evv(POINT)  -tag " 40 note no$cnt"
				$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 40 no$cnt"
			}
			39	{
				$can create text [expr $xpos1 - 4] 94 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 39 no$cnt"
				$can create oval $xpos1 87 $xpos2 93 -outline $evv(POINT)  -tag " 39 note no$cnt"
				$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 39 no$cnt"
			}
			38	{
				$can create oval $xpos1 92 $xpos2 98 -outline $evv(POINT)  -tag " 38 note no$cnt"
				$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 38 no$cnt"
			}
			37	{
				$can create text [expr $xpos1 - 4] 99 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 37 no$cnt"
				$can create oval $xpos1 92 $xpos2 98 -outline $evv(POINT)  -tag " 37 note no$cnt"
				$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 37 no$cnt"
			}
			36	{
				$can create oval $xpos1 97 $xpos2 103 -outline $evv(POINT)  -tag " 36 note no$cnt"
				$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 36 no$cnt"
				$can create line $xpos1leg 100 $xpos2leg 100 -fill $evv(POINT) -tag " 36 no$cnt"
			}
		}
	} elseif {$pm_inbass == -1} {
		set xpos1 [expr $time / $maxtime]
		set xpos1 [expr int(round($xpos1 * $width))]
		set xpos1 [expr $xpos1 + $offset]
		set xpos2	 [expr $xpos1 + $evv(NOTEWIDTH)]
		set xpos1leg [expr $xpos1 - $evv(LEDGE_OFFSET)]
		set xpos2leg [expr $xpos1leg + $evv(LEDGELEN)]
		switch -- $note {
			74	{
				$can create oval $xpos1 12 $xpos2 18 -outline $evv(POINT) -tag " 74 note no$cnt"
				$can create line $xpos1leg 20 $xpos2leg 20 -fill $evv(POINT) -tag " 74 no$cnt"
				$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 74 no$cnt"
			}
			73	{
				$can create text [expr $xpos1 - 4] 19 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 73 no$cnt"
				$can create oval $xpos1 12 $xpos2 18 -outline $evv(POINT) -tag " 73 note no$cnt"
				$can create line $xpos1leg 20 $xpos2leg 20 -fill $evv(POINT) -tag " 73 no$cnt"
				$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 73 no$cnt"
			}
			72	{
				$can create oval $xpos1 17 $xpos2 23 -outline $evv(POINT) -tag " 72 note no$cnt"
				$can create line $xpos1leg 20 $xpos2leg 20 -fill $evv(POINT) -tag " 72 no$cnt"
				$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 72 no$cnt"
			}
			71	{
				$can create oval $xpos1 22 $xpos2 28 -outline $evv(POINT) -tag " 71 note no$cnt"
				$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 71 no$cnt"
			}
			70	{
				$can create text [expr $xpos1 - 4] 29 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 70 no$cnt"
				$can create oval $xpos1 22 $xpos2 28 -outline $evv(POINT)  -tag " 70 note no$cnt"
				$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 70 no$cnt"
			}
			69	{
				$can create oval $xpos1 27 $xpos2 33 -outline $evv(POINT)  -tag " 69 note no$cnt"
				$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 69 no$cnt"
			}
			68	{
				$can create text [expr $xpos1 - 4] 34 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 68 no$cnt"
				$can create oval $xpos1 27 $xpos2 33 -outline $evv(POINT)  -tag " 68 note no$cnt"
				$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 68 no$cnt"
			}
			67	{
				$can create oval $xpos1 32 $xpos2 38 -outline $evv(POINT)  -tag " 67 note no$cnt"
			}
			66	{
				$can create text [expr $xpos1 - 4] 39 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 66 no$cnt"
				$can create oval $xpos1 32 $xpos2 38 -outline $evv(POINT)  -tag " 66 note no$cnt"
			}
			65	{
				$can create oval $xpos1 37 $xpos2 43 -outline $evv(POINT)  -tag " 65 note no$cnt"
			}
			64	{
				$can create oval $xpos1 42 $xpos2 48 -outline $evv(POINT)  -tag " 64 note no$cnt"
			}
			63	{
				$can create text [expr $xpos1 - 4] 49 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 63 no$cnt"
				$can create oval $xpos1 42 $xpos2 48 -outline $evv(POINT)  -tag " 63 note no$cnt"
			}
			62	{
				$can create oval $xpos1 47 $xpos2 53 -outline $evv(POINT)  -tag " 62 note no$cnt"
			}
			61	{
				$can create text [expr $xpos1 - 4] 54 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 61 no$cnt"
				$can create oval $xpos1 47 $xpos2 53 -outline $evv(POINT)  -tag " 61 note no$cnt"
			}
			60	{
				$can create oval $xpos1 52 $xpos2 58 -outline $evv(POINT)  -tag " 60 note no$cnt"
			}
			59	{
				$can create oval $xpos1 57 $xpos2 63 -outline $evv(POINT)  -tag " 59 note no$cnt"
			}
			58	{
				$can create text [expr $xpos1 - 4] 64 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 58 no$cnt"
				$can create oval $xpos1 57 $xpos2 63 -outline $evv(POINT)  -tag " 58 note no$cnt"
			}
			57	{
				$can create oval $xpos1 62 $xpos2 68 -outline $evv(POINT)  -tag " 57 note no$cnt"
			}
			56	{
				$can create text [expr $xpos1 - 4] 69 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 56 no$cnt"
				$can create oval $xpos1 62 $xpos2 68 -outline $evv(POINT)  -tag " 56 note no$cnt"
			}
			55	{
				$can create oval $xpos1 67 $xpos2 73 -outline $evv(POINT)  -tag " 55 note no$cnt"
			}
			54	{
				$can create text [expr $xpos1 - 4] 74 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 54 no$cnt"
				$can create oval $xpos1 67 $xpos2 73 -outline $evv(POINT)  -tag " 54 note no$cnt"
			}
			53	{
				$can create oval $xpos1 72 $xpos2 78 -outline $evv(POINT)  -tag " 53 note no$cnt"
			}
			52	{
				$can create oval $xpos1 77 $xpos2 83 -outline $evv(POINT)  -tag " 52 note no$cnt"
			}
			51	{
				$can create text [expr $xpos1 - 4] 84 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 51 no$cnt"
				$can create oval $xpos1 77 $xpos2 83 -outline $evv(POINT)  -tag " 51 note no$cnt"
			}
			50	{
				$can create oval $xpos1 82 $xpos2 88 -outline $evv(POINT)  -tag " 50 note no$cnt"
			}
			49	{
				$can create text [expr $xpos1 - 4] 89 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 49 no$cnt"
				$can create oval $xpos1 82 $xpos2 88 -outline $evv(POINT)  -tag " 49 note no$cnt"
			}
			48	{
				$can create oval $xpos1 87 $xpos2 93 -outline $evv(POINT)  -tag " 48 note no$cnt"
				$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 48 no$cnt"
			}
			47	{
				$can create oval $xpos1 92 $xpos2 98 -outline $evv(POINT)  -tag " 47 note no$cnt"
				$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 47 no$cnt"
			}
			46	{
				$can create text [expr $xpos1 - 4] 99 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 46 no$cnt"
				$can create oval $xpos1 92 $xpos2 98 -outline $evv(POINT)  -tag " 46 note no$cnt"
				$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 46 no$cnt"
			}
			45	{
				$can create oval $xpos1 97 $xpos2 103 -outline $evv(POINT)  -tag " 45 note no$cnt"
				$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 45 no$cnt"
				$can create line $xpos1leg 100 $xpos2leg 100 -fill $evv(POINT) -tag " 45 no$cnt"
			}
			44	{
				$can create text [expr $xpos1 - 4] 104 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 44 no$cnt"
				$can create oval $xpos1 97 $xpos2 103 -outline $evv(POINT)  -tag " 44 note no$cnt"
				$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 44 no$cnt"
				$can create line $xpos1leg 100 $xpos2leg 100 -fill $evv(POINT) -tag " 44 no$cnt"
			}
			43	{
				$can create oval $xpos1 102 $xpos2 108 -outline $evv(POINT)  -tag " 43 note no$cnt"
				$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 43 no$cnt"
				$can create line $xpos1leg 100 $xpos2leg 100 -fill $evv(POINT) -tag " 43 no$cnt"
			}
			42	{
				$can create text [expr $xpos1 - 4] 109 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 42 no$cnt"
				$can create oval $xpos1 102 $xpos2 108 -outline $evv(POINT)  -tag " 42 note no$cnt"
				$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 42 no$cnt"
				$can create line $xpos1leg 100 $xpos2leg 100 -fill $evv(POINT) -tag " 42 no$cnt"
			}
		}
	} else {
		set xpos1 [expr $time/ $maxtime]
		set xpos1 [expr int(round($xpos1 * $width))]
		set xpos1 [expr $xpos1 + $offset]
		set xpos2	 [expr $xpos1 + $evv(NOTEWIDTH)]
		set xpos1leg [expr $xpos1 - $evv(LEDGE_OFFSET)]
		set xpos2leg [expr $xpos1leg + $evv(LEDGELEN)]
		switch -- $note {
			84	{
				$can create oval $xpos1 17 $xpos2 23 -outline $evv(POINT) -tag " 84 note no$cnt"
				$can create line $xpos1leg 20 $xpos2leg 20 -fill $evv(POINT) -tag " 84 no$cnt"
				$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 84 no$cnt"
			}
			83	{
				$can create oval $xpos1 22 $xpos2 28 -outline $evv(POINT) -tag " 83 note no$cnt"
				$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 83 no$cnt"
			}
			82	{
				$can create text [expr $xpos1 - 4] 29 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 82 no$cnt"
				$can create oval $xpos1 22 $xpos2 28 -outline $evv(POINT)  -tag " 82 note no$cnt"
				$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 82 no$cnt"
			}
			81	{
				$can create oval $xpos1 27 $xpos2 33 -outline $evv(POINT)  -tag " 81 note no$cnt"
				$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 81 no$cnt"
			}
			80	{
				$can create text [expr $xpos1 - 4] 34 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 80 no$cnt"
				$can create oval $xpos1 27 $xpos2 33 -outline $evv(POINT)  -tag " 80 note no$cnt"
				$can create line $xpos1leg 30 $xpos2leg 30 -fill $evv(POINT) -tag " 80 no$cnt"
			}
			79	{
				$can create oval $xpos1 32 $xpos2 38 -outline $evv(POINT)  -tag " 79 note no$cnt"
			}
			78	{
				$can create text [expr $xpos1 - 4] 39 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 78 no$cnt"
				$can create oval $xpos1 32 $xpos2 38 -outline $evv(POINT)  -tag " 78 note no$cnt"
			}
			77	{
				$can create oval $xpos1 37 $xpos2 43 -outline $evv(POINT)  -tag " 77 note no$cnt"
			}
			76	{
				$can create oval $xpos1 42 $xpos2 48 -outline $evv(POINT)  -tag " 76 note no$cnt"
			}
			75	{
				$can create text [expr $xpos1 - 4] 49 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 75 no$cnt"
				$can create oval $xpos1 42 $xpos2 48 -outline $evv(POINT)  -tag " 75 note no$cnt"
			}
			74	{
				$can create oval $xpos1 47 $xpos2 53 -outline $evv(POINT)  -tag " 74 note no$cnt"
			}
			73	{
				$can create text [expr $xpos1 - 4] 54 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 73 no$cnt"
				$can create oval $xpos1 47 $xpos2 53 -outline $evv(POINT)  -tag " 73 note no$cnt"
			}
			72	{
				$can create oval $xpos1 52 $xpos2 58 -outline $evv(POINT)  -tag " 72 note no$cnt"
			}
			71	{
				$can create oval $xpos1 57 $xpos2 63 -outline $evv(POINT)  -tag " 71 note no$cnt"
			}
			70	{
				$can create text [expr $xpos1 - 4] 64 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 70 no$cnt"
				$can create oval $xpos1 57 $xpos2 63 -outline $evv(POINT)  -tag " 70 note no$cnt"
			}
			69	{
				$can create oval $xpos1 62 $xpos2 68 -outline $evv(POINT)  -tag " 69 note no$cnt"
			}
			68	{
				$can create text [expr $xpos1 - 4] 69 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 68 no$cnt"
				$can create oval $xpos1 62 $xpos2 68 -outline $evv(POINT)  -tag " 68 note no$cnt"
			}
			67	{
				$can create oval $xpos1 67 $xpos2 73 -outline $evv(POINT)  -tag " 67 note no$cnt"
			}
			66	{
				$can create text [expr $xpos1 - 4] 74 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 66 no$cnt"
				$can create oval $xpos1 67 $xpos2 73 -outline $evv(POINT)  -tag " 66 note no$cnt"
			}
			65	{
				$can create oval $xpos1 72 $xpos2 78 -outline $evv(POINT)  -tag " 65 note no$cnt"
			}
			64	{
				$can create oval $xpos1 77 $xpos2 83 -outline $evv(POINT)  -tag " 64 note no$cnt"
			}
			63	{
				$can create text [expr $xpos1 - 4] 84 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 63 no$cnt"
				$can create oval $xpos1 77 $xpos2 83 -outline $evv(POINT)  -tag " 63 note no$cnt"
			}
			62	{
				$can create oval $xpos1 82 $xpos2 88 -outline $evv(POINT)  -tag " 62 note no$cnt"
			}
			61	{
				$can create text [expr $xpos1 - 4] 89 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 61 no$cnt"
				$can create oval $xpos1 82 $xpos2 88 -outline $evv(POINT)  -tag " 61 note no$cnt"
			}
			60	{
				$can create oval $xpos1 87 $xpos2 93 -outline $evv(POINT)  -tag " 60 note no$cnt"
				$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 60 no$cnt"
			}
			59	{
				$can create oval $xpos1 92 $xpos2 98 -outline $evv(POINT)  -tag " 59 note no$cnt"
				$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 59 no$cnt"
			}
			58	{
				$can create text [expr $xpos1 - 4] 99 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 58 no$cnt"
				$can create oval $xpos1 92 $xpos2 98 -outline $evv(POINT)  -tag " 58 note no$cnt"
				$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 58 no$cnt"
			}
			57	{
				$can create oval $xpos1 97 $xpos2 103 -outline $evv(POINT)  -tag " 57 note no$cnt"
				$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 57 no$cnt"
				$can create line $xpos1leg 100 $xpos2leg 100 -fill $evv(POINT) -tag " 57 no$cnt"
			}
			56	{
				$can create text [expr $xpos1 - 4] 104 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 56 no$cnt"
				$can create oval $xpos1 97 $xpos2 103 -outline $evv(POINT)  -tag " 56 note no$cnt"
				$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 56 no$cnt"
				$can create line $xpos1leg 100 $xpos2leg 100 -fill $evv(POINT) -tag " 56 no$cnt"
			}
			55	{
				$can create oval $xpos1 102 $xpos2 108 -outline $evv(POINT)  -tag " 55 note no$cnt"
				$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 55 no$cnt"
				$can create line $xpos1leg 100 $xpos2leg 100 -fill $evv(POINT) -tag " 55 no$cnt"
			}
			54	{
				$can create text [expr $xpos1 - 4] 109 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 54 no$cnt"
				$can create oval $xpos1 102 $xpos2 108 -outline $evv(POINT)  -tag " 54 note no$cnt"
				$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 54 no$cnt"
				$can create line $xpos1leg 100 $xpos2leg 100 -fill $evv(POINT) -tag " 54 no$cnt"
			}
			53	{
				$can create oval $xpos1 107 $xpos2 113 -outline $evv(POINT)  -tag " 53 note no$cnt"
				$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 53 no$cnt"
				$can create line $xpos1leg 100 $xpos2leg 100 -fill $evv(POINT) -tag " 53 no$cnt"
				$can create line $xpos1leg 110 $xpos2leg 110 -fill $evv(POINT) -tag " 53 no$cnt"
			}
			52	{
				$can create oval $xpos1 112 $xpos2 118 -outline $evv(POINT)  -tag " 52 note no$cnt"
				$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 52 no$cnt"
				$can create line $xpos1leg 100 $xpos2leg 100 -fill $evv(POINT) -tag " 52 no$cnt"
				$can create line $xpos1leg 110 $xpos2leg 110 -fill $evv(POINT) -tag " 52 no$cnt"
			}
			51	{
				$can create text [expr $xpos1 - 4] 119 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 51 no$cnt"
				$can create oval $xpos1 112 $xpos2 118 -outline $evv(POINT)  -tag " 51 note no$cnt"
				$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 51 no$cnt"
				$can create line $xpos1leg 100 $xpos2leg 100 -fill $evv(POINT) -tag " 51 no$cnt"
				$can create line $xpos1leg 110 $xpos2leg 110 -fill $evv(POINT) -tag " 51 no$cnt"
			}
			50	{
				$can create oval $xpos1 117 $xpos2 123 -outline $evv(POINT)  -tag " 50 note no$cnt"
				$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 50 no$cnt"
				$can create line $xpos1leg 100 $xpos2leg 100 -fill $evv(POINT) -tag " 50 no$cnt"
				$can create line $xpos1leg 110 $xpos2leg 110 -fill $evv(POINT) -tag " 50 no$cnt"
				$can create line $xpos1leg 120 $xpos2leg 120 -fill $evv(POINT) -tag " 50 no$cnt"
			}
			49	{
				$can create text [expr $xpos1 - 4] 124 -anchor sw -text "b" -font tiny_fnt -fill $evv(POINT) -tag " 49 no$cnt"
				$can create oval $xpos1 117 $xpos2 123 -outline $evv(POINT)  -tag " 49 note no$cnt"
				$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 49 no$cnt"
				$can create line $xpos1leg 100 $xpos2leg 100 -fill $evv(POINT) -tag " 49 no$cnt"
				$can create line $xpos1leg 110 $xpos2leg 110 -fill $evv(POINT) -tag " 49 no$cnt"
				$can create line $xpos1leg 120 $xpos2leg 120 -fill $evv(POINT) -tag " 49 no$cnt"
			}
			48	{
				$can create oval $xpos1 122 $xpos2 128 -outline $evv(POINT)  -tag " 48 note no$cnt"
				$can create line $xpos1leg 90 $xpos2leg 90 -fill $evv(POINT) -tag " 48 no$cnt"
				$can create line $xpos1leg 100 $xpos2leg 100 -fill $evv(POINT) -tag " 48 no$cnt"
				$can create line $xpos1leg 110 $xpos2leg 110 -fill $evv(POINT) -tag " 48 no$cnt"
				$can create line $xpos1leg 120 $xpos2leg 120 -fill $evv(POINT) -tag " 48 no$cnt"
			}
		}
	}
}

proc PlayNotation {aschord doplay} {
	global pm_times pm_vals motdelnotes last_delnotes last_chord_notes pa evv
	global program_messages CDPidrun prg_dun prg_abortd mtf_endtime mtf_insnd_fnam 
	global mtf_mstt mtf_mend lastg_mtf_mstt lastgmtf_mend

	set doenv 0
	set doit 1
	if {$aschord} {
		set outfile cdptest01$evv(SNDFILE_EXT)
		set ccnt 0
		foreach val $pm_vals {								;#	Construct visible pitches list
			if {[info exists motdelnotes]} {
				set k [lsearch $motdelnotes $ccnt]
				if {$k >= 0} {
					incr ccnt
					continue
				}
			}
			if {[info exists nuvals]} {						;#	Omitting all duplicates
				set k [lsearch $nuvals $val]
				if {$k < 0} {
					lappend nuvals $val
				}
			} else {
				lappend nuvals $val
			}
			incr ccnt
		}
		if {![info exists nuvals]} {
			Inf "No Notes To Play"	
			return 0
		}
		if {[file exists $outfile]} {
			if {[info exists last_chord_notes] && ([string length $nuvals] == [string length $last_chord_notes])} {
				set doit 0
				foreach val $nuvals {							;#	If no change, don't remake outfile
					set k [lsearch $last_chord_notes $val]
					if {$k < 0} {
						set doit 1
						break
					}
				}
			}
		}
		if {$doit} {
			set ofnam cdptest01$evv(TEXT_EXT)
			if [catch {open $ofnam "w"} zit] {
				Inf "Cannot Open File '$ofnam' To Write Data For Synthesis"
				return 0
			}
			foreach val $nuvals {
				puts $zit $val
			}
			close $zit
		}
	} else {
		set outfile cdptest00$evv(SNDFILE_EXT)
		if {[file exists $outfile]} {
			if {[info exists last_delnotes] && ([llength $last_delnotes] == [llength $motdelnotes])} {
				set doit 0
				foreach val0 $motdelnotes val1 $last_delnotes {	;#	If no change, don't remake outfile
					if {![string match $val0 $val1]} {
						set doit 1
						break
					}
				}
			}
		}
		if {$doit} {
			set ccnt 0
			foreach time $pm_times val $pm_vals {				;#	Construct visible pitches list
				if {[info exists motdelnotes]} {
					set k [lsearch $motdelnotes $ccnt]
					if {$k >= 0} {
						incr ccnt
						continue
					}
				}
				lappend nulines $time $val
				incr ccnt
			}
			if {![info exists nulines]} {
				Inf "No Notes To Play"	
				return 0
			}
			set len [llength $nulines]
			incr len -2
			set lasttime [lindex $nulines $len]
			set mtf_endtime [expr $lasttime + 0.2]
			set ccnt 0
			foreach {time val} $nulines {						;#	Convert to playable form
				if {$ccnt == 0} {
					lappend nuvals $time [MidiToHz $val]
					lappend evals $time 1.0
				} else {
					if {![Flteq $val $lastval]} {
						set midtime [expr $time - $evv(MTF_PGLIDE)]
						if {$midtime > $lasttime} {
							lappend nuvals $midtime [MidiToHz $lastval]
						}
					} else {
						set etime [expr $time - $evv(MTF_PGLIDE)]
						set eetime [expr $etime - (2 * $evv(MTF_PGLIDE))]
						if {$eetime > [expr $lasttime + $evv(MTF_PGLIDE)]} {
							lappend evals $eetime 1.0
							set eetime [expr $eetime + $evv(MTF_PGLIDE)]
							lappend evals $eetime 0.0
							lappend evals $etime 0.0
							lappend evals $time 1.0
							set doenv 1
						}

					}
					lappend nuvals $time [MidiToHz $val]
				}
				set lasttime $time
				set lastval $val
				incr ccnt
			}
			lappend nuvals $mtf_endtime [MidiToHz $lastval]
			lappend evals $mtf_endtime 1.0
			if {![Flteq [lindex $nuvals 0] 0.0]} {
				if {([llength $nuvals] >= 4) && [Flteq [lindex $nuvals 1] [lindex $nuvals 3]]} {
					set nuvals [lreplace $nuvals 0 0 0.0]
				} else {
					set zz 0.0
					lappend zz [lindex $nuvals 1]
					set nuvals [concat $zz $nuvals]
				}
			}
			set ofnam cdptest00$evv(TEXT_EXT)
			if [catch {open $ofnam "w"} zit] {
				Inf "Cannot Open File '$ofnam' To Write Motif Data For Synthesis"
				return 0
			}
			foreach {time val} $nuvals {
				set line $time
				lappend line $val
				puts $zit $line
			}
			close $zit
			if {$doenv} {
				set oefnam cdptest0000$evv(TEXT_EXT)
				if [catch {open $oefnam "w"} zit] {
					Inf "Cannot Open File '$oefnam' To Write Envelope Data For Synthesis"
					return 0
				}
				foreach {time val} $evals {
					set line $time
					lappend line $val
					puts $zit $line
				}
				close $zit
			}
		}
	}
	if {$doit} {
		if {[file exists $outfile]} {
			if [catch {file delete $outfile} zit] {
				Inf "Cannot Delete Existing Motif File '$outfile'"
				return 0
			}
		}
		set srate $pa($mtf_insnd_fnam,$evv(SRATE))
		Block "CREATING NEW MOTIF SOUNDFILE"
		catch {unset CDPidrun}
		catch {unset program_messages}
		set prg_dun 0
		set prg_abortd 0
		set CDPidrun 0
		if {$aschord}  {
			set CDP_cmd [file join $evv(CDPROGRAM_DIR) synth]
			lappend CDP_cmd chord 1 $outfile $ofnam $srate 1 4 -a.3 -t4096
		} else {
			set CDP_cmd [file join $evv(CDPROGRAM_DIR) synth]
			lappend CDP_cmd wave 1 $outfile $srate 1 $mtf_endtime $ofnam -a.3 -t4096
		}
		if [catch {open "|$CDP_cmd"} CDPidrun] {
			Inf "$CDPidrun :\nCan't Synthesize Output"
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
			set errorline "Synthesis Failed"
		}
		if [info exists errorline] {
			Inf "$errorline"
		}
		if [info exists program_messages] {
			Inf "$program_messages"
			unset program_messages
		}
		UnBlock
		if {!$prg_dun} {
			return 0
		}
		if {$doenv} {
			Block "ENVELOPING SYNTHESIZED SOUND"
			catch {unset CDPidrun}
			catch {unset program_messages}
			set prg_dun 0
			set prg_abortd 0
			set CDPidrun 0
			set CDP_cmd [file join $evv(CDPROGRAM_DIR) envel]
			lappend CDP_cmd impose 3 $outfile $oefnam cdptest0000$evv(SNDFILE_EXT)
			if [catch {open "|$CDP_cmd"} CDPidrun] {
				Inf "$CDPidrun :\nCan't Envelope Synthesize Output"
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
				set errorline "Enveloping Failed"
			}
			if [info exists errorline] {
				Inf "$errorline"
			}
			if [info exists program_messages] {
				Inf "$program_messages"
				unset program_messages
			}
			UnBlock
			if {!$prg_dun} {
				return 0
			}
			if {[catch {file delete $outfile} zit]} {
				Inf "Cannot Delete Un-Enveloped Synth Sound: No Enveloping"
			} elseif {[catch {file rename cdptest0000$evv(SNDFILE_EXT) $outfile} zit]} {
				Inf "Failed To Rename Enveloped Synth File"
				return 0
			}
		}
		if {$aschord} {
			set last_chord_notes $motdelnotes
		} else {
			set last_delnotes $motdelnotes
		}
	}
	if {!$aschord} {
		set OK 1
		while {$OK} {
			set prg_dun 0
			set prg_abortd 0
			catch {unset program_messages}
			set CDP_cmd [file join $evv(CDPROGRAM_DIR) cdparse]
			lappend CDP_cmd $outfile 0
			if [catch {open "|$CDP_cmd"} CDPidrun] {
				Inf "$CDPidrun :\nCan't Parse Output File To Find Duration"
				break
			} else {
  				fileevent $CDPidrun readable "Read_Duration"
			}
			vwait prg_dun
			if {$prg_abortd} {
				if [info exists program_messages] {
					Inf "$program_messages"
				}
				set prg_dun 0
			}
			if {!$prg_dun} {
				set errorline "Parsing Failed"
			}
			if [info exists errorline] {
				Inf "$errorline"
			}
			if [info exists program_messages] {
				if {!$prg_dun} {
					Inf "$program_messages"
					break
				} else {
					set endtime [lindex $program_messages 11]
				}
				unset program_messages
			}
			if {[string length $mtf_mstt] <= 0} {
				set mtf_mstt "start"
			} 
			if {[string length $mtf_mend] <= 0} {
				set mtf_mend "end"
			} 
			if {[info exists lastg_mtf_mstt] && [info exists lastg_mtf_mend]} {
				if {[string match $lastg_mtf_mstt $mtf_mstt] && [string match $lastg_mtf_mend $mtf_mend]} {
					break
				}
			}
			if {[string match $mtf_mstt "start"]} {
				set sttt 0
			} elseif {![IsNumeric $mtf_mstt]} {
				Inf "Invalid Starttime: Playing Whole Duration"
				set mtf_mstt "start"
				break
			} elseif {$mtf_mstt < 0.0} {
				set mtf_mstt "start"
				set sttt 0.0
			} else {
				set sttt $mtf_mstt
			}
			if {[string match $mtf_mend "end"]} {
				set endd $endtime
			} elseif {![IsNumeric $mtf_mend]} {
				Inf "Invalid Endtime: Playing Whole Duration"
				set mtf_mend "end"
				break
			} elseif {$mtf_mend > $endtime} {
				set mtf_mend "end"
				set endd $endtime
			} else {
				set endd $mtf_mend
			}
			if {[Flteq $sttt 0.0] && [Flteq $endd $endtime]} {
				break
			}
			set zubafile cdptest05$evv(SNDFILE_EXT)
			if {[file exists $zubafile] } {
				if [catch {file delete $zubafile} zit] {
					Inf "Cannot Delete Existing Short File: Playing entire duration"
					break
				}
			}
			set prg_dun 0
			set prg_aborted 0
			catch {unset errorline}
			catch {unset program_messages}
			set CDP_cmd [file join $evv(CDPROGRAM_DIR) sfedit]
			lappend CDP_cmd cut 1 $outfile $zubafile $sttt $endd
			if [catch {open "|$CDP_cmd"} CDPidrun] {
				Inf "$CDPidrun :\nCan't Edit Output File to required size"
				break
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
				set errorline "Editing Failed: Playing Whole Duration"
			}
			if [info exists errorline] {
				Inf "$errorline"
			}
			if [info exists program_messages] {
				Inf "$program_messages"
				unset program_messages
			}
			if {!$prg_dun} {
				break
			}
			set outfile $zubafile
			set lastg_mtf_mstt $mtf_mstt
			set lastg_mtf_mend $mtf_mend
			break
		}
	}
	if {$doplay} {
		PlaySndfile $outfile 0
	}
	return 1
}

proc PlayMotifAndSrc {} {
	global last_delnotes motdelnotes mtf_insnd_fnam pa evv
	global program_messages CDPidrun prg_dun prg_abortd mtf_skew last_mtf_skew pm_times
	global mtf_mstt mtf_mend last_mtf_mstt last_mtf_mend

	set doit 1
	set outfile cdptest02$evv(SNDFILE_EXT)
	set endtime $pa($mtf_insnd_fnam,$evv(DUR))
	if {[file exists cdptest00$evv(SNDFILE_EXT)]} {
		if {[file exists $outfile]} {
			if {![info exists last_delnotes]} {
				set doit 0
			} elseif {[llength $last_delnotes] == [llength $motdelnotes]} {
				set doit 0
				foreach val0 $motdelnotes val1 $last_delnotes {	;#	If no change, don't remake outfile
					if {![string match $val0 $val1]} {
						set doit 1
						break
					}
				}
			}
		}
		if {!$doit} {
			if {[info exists last_mtf_skew]} {
				if {![Flteq $last_mtf_skew $mtf_skew]} {
					set doit $evv(REDOMIX)
				}
			}
		}
	}
	if {[IsNumeric $mtf_mend]} {
		if {($mtf_mend < $endtime) && ($mtf_mend > 0.0)} {
			set withend $mtf_mend
			if {!$doit} {
				set doit $evv(NEWMLEN)
			}
		} elseif {$mtf_mend >= $endtime} {
			set mtf_mend "end"
		}
	} elseif {[string length $mtf_mend] <= 0} {
		set mtf_mend "end"
	} elseif {![string match $mtf_mend "end"]} {
		Inf "Invalid Mix Endtime Value: Resetting To End Of Source"
		set mtf_mend "end"
	}
	if {[IsNumeric $mtf_mstt]} {
		if {($mtf_mstt > 0.0) && ($mtf_mstt < $endtime)} {
			set withstt $mtf_mstt
			if {!$doit} {
				set doit $evv(NEWMLEN)
			}
		} elseif {[Flteq $mtf_mstt 0.0]} {
			set mtf_mstt "start"
		}
	} elseif {[string length $mtf_mstt] <= 0} {
		set mtf_mstt "start"
	} elseif {![string match $mtf_mstt "start"]} {
		Inf "Invalid Mix Starttime Value: Resetting To Zero"
		set mtf_mstt "start"
	}
	if {[info exists withstt] && [info exists withend]} {
		if {$mtf_mend <= $mtf_mstt} {
			Inf "Incompatible Start And End Times For Mix"
			return 0
		}
	}
	if {[info exists last_mtf_mend]} {
		if {[string match $last_mtf_mend $mtf_mend] && [string match $last_mtf_mstt $mtf_mstt]} {
			if {$doit == $evv(NEWMLEN)} {
				set doit 0
			}
		} else {
			if {!$doit} {
				set doit $evv(REDOMIX)
			}
		}
	}
	if {$doit} {
		if {[file exists $outfile]} {
			if [catch {file delete $outfile} zit] {
				Inf "Cannot Delete Existing Mixed File '$outfile'"
				return 0
			}
		}
		if {$doit != $evv(REDOMIX)} {
			if {![PlayNotation 0 0]} {
				return
			}
		}
		set ofnam cdptest00$evv(SNDFILE_EXT)
		if {[info exists pa($mtf_insnd_fnam,$evv(MAXSAMP))] && ($pa($mtf_insnd_fnam,$evv(MAXSAMP)) > 0.0)} {
			set skew [expr 1.0 / $pa($mtf_insnd_fnam,$evv(MAXSAMP))]
		} else {
			set skew 1.0
		}
		if {![IsNumeric $mtf_skew]} {
			Inf "Relative Source Level: Invalid Value: Resetting To 1"
			set mtf_skew 1.0
		} elseif {($mtf_skew < 1.0) || ($mtf_skew > 8.0)} {
			Inf "Relative Source Level Out Of Range: Resetting To 1"
			set mtf_skew 1.0
		}
		set skew [expr $skew * $mtf_skew]
		Block "MIXING SOUNDS"
		catch {unset CDPidrun}
		catch {unset program_messages}
		set prg_dun 0
		set prg_abortd 0
		set CDPidrun 0
		set CDP_cmd [file join $evv(CDPROGRAM_DIR) submix]
		lappend CDP_cmd merge $mtf_insnd_fnam $ofnam $outfile -k$skew
		if {[info exists withstt]} {
			lappend CDP_cmd -b$withstt
		}
		if {[info exists withend]} {
			lappend  CDP_cmd -e$withend
		}
		if [catch {open "|$CDP_cmd"} CDPidrun] {
			Inf "$CDPidrun :\nCan't Mix Sounds"
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
			set errorline "Mixing Failed"
		}
		if [info exists errorline] {
			Inf "$errorline"
		}
		if [info exists program_messages] {
			Inf "$program_messages"
			unset program_messages
		}
		UnBlock
		if {!$prg_dun} {
			return 0
		}
	}
	set last_mtf_mend $mtf_mend
	set last_mtf_mstt $mtf_mstt
	set last_mtf_skew $mtf_skew
	PlaySndfile $outfile 0
}

proc SaveTimedFrqMotifData {} {
	global last_delnotes motdelnotes mtf_fnam pm_times pm_vals wstk mtf_endtime mtf_insnd_fnam wl evv
	if {[string length $mtf_fnam] <= 0} {
		Inf "No Output Filename Entered"
		return
	}
	set mtf_fnam [string tolower $mtf_fnam]
	if {![ValidCDPRootname $mtf_fnam]} {
		return
	}
	set out_fnam $mtf_fnam
	append out_fnam [GetTextfileExtension brk]
	if {[file exists $out_fnam]} {
		set msg "File '$out_fnam' Exists. Overwrite It ?"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		} else {
			if {[DeleteFileFromSystem $out_fnam 0 1] <= 0} {
				return
			}
			set i [LstIndx $out_fnam $wl]
			if {$i >= 0} {
				RemoveAllRefsToFile $out_fnam $i
			}
		}	
	}
	set ofnam cdptest00$evv(TEXT_EXT)
	set doit 1
	if {[file exists $ofnam]} {
		if {[info exists last_delnotes] && ([llength $last_delnotes] == [llength $motdelnotes])} {
			set doit 0
			foreach val0 $motdelnotes val1 $last_delnotes {	;#	If no change, don't remake outfile
				if {![string match $val0 $val1]} {
					set doit 1
					break
				}
			}
		}
	}
	if {$doit} {
		set ccnt 0
		foreach time $pm_times val $pm_vals {				;#	Construct visible pitches list
			if {[info exists motdelnotes]} {
				set k [lsearch $motdelnotes $ccnt]
				if {$k >= 0} {
					incr ccnt
					continue
				}
			}
			lappend nulines $time $val
			incr ccnt
		}
		if {![info exists nulines]} {
			Inf "No Notes To Save"	
			return 0
		}
		set len [llength $nulines]
		incr len -2
		set lasttime [lindex $nulines $len]
		set mtf_endtime [expr $lasttime + 0.2]
		set ccnt 0
		foreach {time val} $nulines {						;#	Convert to playable form
			if {$ccnt == 0} {
				lappend nuvals $time [MidiToHz $val]
			} else {
				if {![Flteq $val $lastval]} {
					set midtime [expr $time - $evv(MTF_PGLIDE)]
					if {$midtime > $lasttime} {
						lappend nuvals $midtime [MidiToHz $lastval]
					}
				}
				lappend nuvals $time [MidiToHz $val]
			}
			set lasttime $time
			set lastval $val
			incr ccnt
		}
		lappend nuvals $mtf_endtime [MidiToHz $lastval]
		if {![Flteq [lindex $nuvals 0] 0.0]} {
			if {([llength $nuvals] >= 4) && [Flteq [lindex $nuvals 1] [lindex $nuvals 3]]} {
				set nuvals [lreplace $nuvals 0 0 0.0]
			} else {
				set zz 0.0
				lappend zz [lindex $nuvals 1]
				set nuvals [concat $zz $nuvals]
			}
		}
		if [catch {open $ofnam "w"} zit] {
			Inf "Cannot Open File '$ofnam' To Write Frq Data For Synthesis"
			return 0
		}
		foreach {time val} $nuvals {
			set line $time
			lappend line $val
			puts $zit $line
		}
		close $zit
	}
	if [catch {file rename $ofnam $out_fnam} zit] {
		Inf "Cannot Rename The Output Data File"
		return
	}
	FileToWkspace $out_fnam 0 0 0 0 1
	Inf "File '$out_fnam' Is Now On The Workspace"
}

proc SaveUntimedMidiMotifData {isfile} {
	global motdelnotes pm_vals mtf_insnd_fnam mtf_fnam mtfmark wstk wl evv

	set ccnt 0	
	foreach val $pm_vals {				;#	Construct visible pitches list
		if {[info exists motdelnotes]} {
			set k [lsearch $motdelnotes $ccnt]
			if {$k >= 0} {
				incr ccnt
				continue
			}
		}
		lappend nuvals $val
		incr ccnt
	}
	if {![info exists nuvals]} {
		Inf "No Notes To Save"
		return 0
	}
	if {$isfile} {
		if {[string length $mtf_fnam] <= 0} {
			Inf "No Output Filename Entered"
			return
		}
		set mtf_fnam [string tolower $mtf_fnam]
		if {![ValidCDPRootname $mtf_fnam]} {
			return
		}
		set out_fnam $mtf_fnam
		append out_fnam $evv(TEXT_EXT)
		if {[file exists $out_fnam]} {
			set msg "File '$out_fnam' Exists. Overwrite It ?"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				return
			} elseif {[DeleteFileFromSystem $out_fnam 0 1] <= 0} {
				return
			}	
			set i [LstIndx $out_fnam $wl]
			if {$i >= 0} {
				RemoveAllRefsToFile $out_fnam $i
			}
		}
		if [catch {open $out_fnam "w"} zit] {
			Inf "Cannot Open File '$out_fnam' To Write Motif Data For Synthesis"
			return 0
		}
		foreach val $nuvals {
			puts $zit $val
		}
		close $zit
		FileToWkspace $out_fnam 0 0 0 0 1
		Inf "File '$out_fnam' Is Now On The Workspace"
		return
	}
	set mtfmark($mtf_insnd_fnam) $nuvals
	StoreMtfMarks
	Inf "Stored Motif Mark for '$mtf_insnd_fnam'"
}

proc SaveMotifAsPmark {asfile} {
	global last_chord_notes motdelnotes mtf_fnam mtf_insnd_fnam wstk pm_vals wl pitchmark evv

	if {$asfile} {
		if {[string length $mtf_fnam] <= 0} {
			Inf "No Output Filename Entered"
			return
		}
		set mtf_fnam [string tolower $mtf_fnam]
		if {![ValidCDPRootname $mtf_fnam]} {
			return
		}
		set out_fnam $mtf_fnam
		append out_fnam $evv(TEXT_EXT)
		if {[file exists $out_fnam]} {
			set msg "File '$out_fnam' Exists. Overwrite It ?"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				return
			} elseif {[DeleteFileFromSystem $out_fnam 0 1] <= 0} {
				return
			}	
			set i [LstIndx $out_fnam $wl]
			if {$i >= 0} {
				RemoveAllRefsToFile $out_fnam $i
			}
		}
		set ofnam cdptest01$evv(TEXT_EXT)
	}
	set doit 1
	set ccnt 0
	foreach val $pm_vals {								;#	Construct visible pitches list
		if {[info exists motdelnotes]} {
			set k [lsearch $motdelnotes $ccnt]
			if {$k >= 0} {
				incr ccnt
				continue
			}
		}
		if {[info exists nuvals]} {						;#	Omitting all duplicates
			set k [lsearch $nuvals $val]
			if {$k < 0} {
				lappend nuvals $val
			}
		} else {
			lappend nuvals $val
		}
		incr ccnt
	}
	if {![info exists nuvals]} {
		Inf "No Notes To Save"	
		return
	}
	set nuvals [lsort -integer -decreasing $nuvals]
	if {!$asfile} {
		set pitchmark($mtf_insnd_fnam) $nuvals
		StorePitchMarks
		Inf "Stored Pitchmark for '$mtf_insnd_fnam'"
		return
	}
	if {[file exists $ofnam]} {
		if {[info exists last_chord_notes] && ([string length $nuvals] == [string length $last_chord_notes])} {
			set doit 0
			foreach val $nuvals {							;#	If no change, don't remake outfile
				set k [lsearch $last_chord_notes $val]
				if {$k < 0} {
					set doit 1
					break
				}
			}
		}
	}
	if {$doit} {
		if [catch {open $out_fnam "w"} zit] {
			Inf "Cannot Open File '$out_fnam' To Write Motif Data"
			return 0
		}
		foreach val $nuvals {
			if {$asfile > 1} {
				set val [MidiToHz $val]
			}
			puts $zit $val
		}
		close $zit
	} else {
		if [catch {file rename $ofnam $out_fnam} zit] {
			Inf "Cannot Rename The Output Data File"
			return
		}
	}
	FileToWkspace $out_fnam 0 0 0 0 1
	Inf "File '$out_fnam' Is Now On The Workspace"
	catch {delete file cdptest03$evv(SNDFILE_EXT)}
	catch {delete file cdptest03$evv(TEXT_EXT)}
}

proc SaveTimedMidiMotifData {} {
	global motdelnotes mtf_fnam mtf_insnd_fnam pm_times pm_vals wstk wl evv

	if {[string length $mtf_fnam] <= 0} {
		Inf "No Output Filename Entered"
		return
	}
	set mtf_fnam [string tolower $mtf_fnam]
	if {![ValidCDPRootname $mtf_fnam]} {
		return
	}
#	set zzz [file dirname $mtf_insnd_fnam]
#	if {[string length $zzz] > 1} {
#		set out_fnam [file join $zzz $mtf_fnam]
#	} else {
#		set out_fnam $mtf_fnam
#	}
	set out_fnam $mtf_fnam
	append out_fnam [GetTextfileExtension brk]
	if {[file exists $out_fnam]} {
		set msg "FILE '$out_fnam' Exists. Overwrite It ?"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		} elseif {[DeleteFileFromSystem $out_fnam 0 1] <= 0} {
			return
		}	
		set i [LstIndx $out_fnam $wl]
		if {$i >= 0} {
			RemoveAllRefsToFile $out_fnam $i
		}
	}
	set ccnt 0
	foreach time $pm_times val $pm_vals {				;#	Construct visible pitches list
		if {[info exists motdelnotes]} {
			set k [lsearch $motdelnotes $ccnt]
			if {$k >= 0} {
				incr ccnt
				continue
			}
		}
		lappend nulines $time $val
		incr ccnt
	}
	if {![info exists nulines]} {
		Inf "No Notes To Save"	
		return 0
	}
	if {![Flteq [lindex $nulines 0] 0.0]} {
		set nulines [lreplace $nulines 0 0 0.0]
	}
	if [catch {open $out_fnam "w"} zit] {
		Inf "Cannot Open File '$out_fnam' To Write Frq Data For Synthesis"
		return 0
	}
	foreach {time val} $nulines {
		set line $time
		lappend line $val
		puts $zit $line
	}
	close $zit
	FileToWkspace $out_fnam 0 0 0 0 1
	Inf "File '$out_fnam' Is Now On The Workspace"
}

proc LockMotif {} {
	global motdelnotes pm_vals pm_times
	if {[llength $motdelnotes] <= 0} {
		return
	}
	set ccnt 0
	set oldlen [llength $pm_vals]
	foreach time $pm_times val $pm_vals {
		set k [lsearch $motdelnotes $ccnt]
		if {$k >= 0} {
			incr ccnt
			continue
		}
		lappend nuvals $time $val
		incr ccnt
	}
	unset pm_times
	unset pm_vals
	foreach {time val} $nuvals {
		lappend pm_times $time
		lappend pm_vals $val
	}
	ReDrawNewMotifs $oldlen
}

proc SaveOrigMotif {} {
	global pm_times pm_vals orig_pm_times orig_pm_vals
	catch {unset orig_pm_times}
	catch {unset orig_pm_vals}
	foreach time $pm_times val $pm_vals {
		lappend orig_pm_times $time
		lappend orig_pm_vals $val
	}
}

proc RestoreOrigMotif {} {
	global pm_times pm_vals orig_pm_times orig_pm_vals

	if {![info exists orig_pm_times]} {
		return
	}
	set oldlen [llength $pm_vals]

	catch {unset pm_times}
	catch {unset pm_vals}
	foreach time $orig_pm_times val $orig_pm_vals {
		lappend pm_times $time
		lappend pm_vals $val
	}
	ReDrawNewMotifs $oldlen
}

proc RestoreStartMotif {} {
	global pm_times pm_vals start_pm_times start_pm_vals

	set oldlen [llength $pm_vals]

	catch {unset pm_times}
	catch {unset pm_vals}
	foreach time $start_pm_times val $start_pm_vals {
		lappend pm_times $time
		lappend pm_vals $val
	}
	ReDrawNewMotifs $oldlen
}

proc ReDrawNewMotifs {len} {
	global pmotifcan pm_times pm_vals mtf_width
	global motdelnotes last_delnotes last_chord_notes last_mtf_skew last_mtf_mstt last_mtf_mend
	global mtfnote_marked mtfnote_time mtfnote_pich mtfnote_lotime mtfnote_hitime
	set n 0
	while {$n < $len} {
		set noteno "no"
		append noteno $n
		catch {$pmotifcan delete withtag $noteno}
		incr n
	}
	set ccnt 0
	foreach time $pm_times note $pm_vals {
		RedrawMgrafixPitch $time $note $pmotifcan $mtf_width $ccnt
		incr ccnt
	}
	RedrawMotifTimeline
	set motdelnotes {}
	catch {unset last_delnotes}
	catch {unset last_chord_notes}
	catch {unset last_mtf_skew}
	catch {unset last_mtf_mstt}
	catch {unset last_mtf_mend}
	MotifMouseSwitch 0
}

proc MgrafixMark {w x y} {
	global motdelnotes mtfnote_marked mtfnote_time mtfnote_pich mtfnote_lotime mtfnote_hitime pm_times pm_vals evv

	catch {unset mtfnote_marked}
	catch {unset mtfnote_time}
	catch {unset mtfnote_pich} 
	catch {unset mtfnote_lotime} 
	catch {unset mtfnote_hitime}
	set displaylist [$w find withtag note]	;#	List all objects which are notes
	set mindiffx 100000								;#	Find closest note
	set mindiffy 100000
	set finished 0
	foreach thisobj $displaylist {
		set coords [$w coords $thisobj]
		set xx [lindex $coords 0]
		set yy [lindex $coords 1]
		set diff [expr abs($x - ($xx + 4))]
		if {$diff < $mindiffx} {
			set gotobj $thisobj
			set mindiffx $diff
			set mindiffy [expr abs($y - ($yy + 3))]
		} elseif {$diff == $mindiffx} {
			set diff [expr abs($y - ($yy + 3))]
			if {$diff < $mindiffy} {
				set mindiffy $diff
				set gotobj $thisobj
			}
		}
	}
	if {![info exists gotobj]} {
		Inf "No Note Found At Mouse Click"
		MotifMouseSwitch 0
		return
	}
	set tag_list [$w gettags $gotobj]
	set noteno [lindex $tag_list end]
	if {$noteno == "current"} {
		Inf "Try Again"
		MotifMouseSwitch 0
		return
	}
	set len [llength $pm_times]
	incr len -1
	set nunote [string range $noteno 2 end]
	set mtfnote_marked $nunote
	set mtfnote_time [lindex $pm_times $nunote]
	if {$nunote == 0} {
		set mtfnote_lotime $mtfnote_time
	} else {
		set mtfnote_lotime [lindex $pm_times [expr $nunote - 1]]
		set mtfnote_lotime [expr $mtfnote_lotime + $evv(MTF_HLFNUDGE)]
	}
	if {$nunote == $len} {
		set mtfnote_hitime $mtfnote_time
	} else {
		set mtfnote_hitime [lindex $pm_times [expr $nunote + 1]]
		set mtfnote_hitime [expr $mtfnote_hitime - $evv(MTF_HLFNUDGE)]
	}
	set mtfnote_pich [expr int(round([lindex $pm_vals $nunote]))]
	SaveOrigMotif
	if {[info exists motdelnotes] && ([llength $motdelnotes] > 0)} {
		set k 0
		foreach n $motdelnotes {
			if {$n < $mtfnote_marked} {
				incr k
			}
		}
		set k [expr $mtfnote_marked - $k]
		incr k
	} else {
		set k [expr $mtfnote_marked + 1]
	}
	MotifMouseSwitch 1
	Inf "Marked Note $k"
}

proc MoveMotifNote {how} {
	global mtfnote_pich mtfnote_time mtfnote_lotime mtfnote_hitime pmotifcan pm_vals pm_times mtf_width mtfnote_marked evv
	global pm_inbass
	if {![info exists mtfnote_marked]} {
		Inf "No Note Chosen"
		return
	}
	switch -- $how {
		"up" - 
		"down" {
			switch -- $pm_inbass {
				0  {
					set lolim 48
					set hilim 84
				}
				1  { 
					set lolim 36
					set hilim 65
				}
				-1 {  
					set lolim 42
					set hilim 72
				}
			}
			switch -- $how {
				"up" {
					incr mtfnote_pich
					if {$mtfnote_pich > $hilim} {
						incr mtfnote_pich -1
						return
					}
				}
				"down" {
					incr mtfnote_pich -1
					if {$mtfnote_pich < $lolim} {
						incr mtfnote_pich 1
						return
					}	
				}
			}
			set pm_vals [lreplace $pm_vals $mtfnote_marked $mtfnote_marked $mtfnote_pich]
			set noteno "no"
			append noteno $mtfnote_marked
			$pmotifcan delete withtag $noteno
			set time [lindex $pm_times $mtfnote_marked]
			RedrawMgrafixPitch $time $mtfnote_pich $pmotifcan $mtf_width $mtfnote_marked
			catch {file delete cdptest00$evv(SNDFILE_EXT)}
			catch {file delete cdptest01$evv(SNDFILE_EXT)}
			catch {file delete cdptest02$evv(SNDFILE_EXT)}
			catch {file delete cdptest04$evv(SNDFILE_EXT)}
			catch {file delete cdptest05$evv(SNDFILE_EXT)}
		}
		"left" - 
		"right" {
			set starttime $mtfnote_time
			switch -- $how {
				"left" {
					set mtfnote_time [expr $mtfnote_time - $evv(MTF_NUDGE)]
					if {$mtfnote_time < $mtfnote_lotime} {
						set mtfnote_time $starttime
						return
					}
				}
				"right" {
					set mtfnote_time [expr $mtfnote_time + $evv(MTF_NUDGE)]
					if {$mtfnote_time > $mtfnote_hitime} {
						set mtfnote_time $starttime
						return
					}
				}
			}
			set pm_times [lreplace $pm_times $mtfnote_marked $mtfnote_marked $mtfnote_time]
			set noteno "no"
			append noteno $mtfnote_marked
			$pmotifcan delete withtag $noteno
			set val [lindex $pm_vals $mtfnote_marked]
			RedrawMgrafixPitch $mtfnote_time $val $pmotifcan $mtf_width $mtfnote_marked
			catch {file delete cdptest00$evv(SNDFILE_EXT)}
			catch {file delete cdptest02$evv(SNDFILE_EXT)}
			catch {file delete cdptest04$evv(SNDFILE_EXT)}
			catch {file delete cdptest05$evv(SNDFILE_EXT)}
		}
	}
}

proc MotifMouseSwitch {val} {
	global motif_ms pmotifcan mtf_width mtfnote_marked motdelnotes last_delnotes last_chord_notes last_mtf_skew 
	global last_mtf_mstt last_mtf_mend
	switch -- $val {
		2 {
			if {[info exists motdelnotes] && ([llength $motdelnotes] > 0)} {
				Inf "You Must 'Keep New Motif' Before Adding Notes"
				return
			}
			catch {unset last_delnotes}
			catch {unset last_chord_notes}
			catch {unset last_mtf_skew}
			catch {unset last_mtf_mstt}
			catch {unset last_mtf_mend}
			catch {unset mtfnote_marked}
			catch {unset mtfnote_time}
			catch {unset mtfnote_pich} 
			catch {unset mtfnote_lotime} 
			catch {unset mtfnote_hitime}
			bind $pmotifcan <ButtonRelease-1> {}
			bind $pmotifcan <Control-ButtonRelease-1> {}
			bind $pmotifcan <Shift-ButtonRelease-1> {}
			bind $pmotifcan <Control-Shift-ButtonRelease-1> {}
			bind $pmotifcan <ButtonRelease-1> {MotifInsertNote %x}
			.melpage.5.ll config -text "ADD PITCH WHERE MOUSE CLICKS"
			.melpage.5a.ll config -fg [option get . background {}]
			set motif_ms 2
		}
		1 {
			if {![info exists mtfnote_marked]} {
				set motif_ms 0
				return
			} 
			bind $pmotifcan <ButtonRelease-1> {}
			bind $pmotifcan <Control-ButtonRelease-1> {}
			bind $pmotifcan <Shift-ButtonRelease-1> {}
			bind $pmotifcan <Control-Shift-ButtonRelease-1> {}
			bind $pmotifcan <ButtonRelease-1> "MoveMotifNote up"
			bind $pmotifcan <Control-ButtonRelease-1> "MoveMotifNote down"
			bind $pmotifcan <Shift-ButtonRelease-1> "MoveMotifNote left"
			bind $pmotifcan <Control-Shift-ButtonRelease-1> "MoveMotifNote right"
			.melpage.5.ll config -text "CLICK = PITCH UP:       CONTROL-Clk = PITCH DOWN:        SHIFT-Clk = NOTE LEFT:        CONTROL-SHIFT-Clk = NOTE RIGHT"
			.melpage.5a.ll config -fg [option get . background {}]
			set motif_ms 1
		}
		0 {
			catch {unset mtfnote_marked}
			catch {unset mtfnote_time}
			catch {unset mtfnote_pich} 
			catch {unset mtfnote_lotime} 
			catch {unset mtfnote_hitime}
			bind $pmotifcan <ButtonRelease-1> {}
			bind $pmotifcan <Control-ButtonRelease-1> {}
			bind $pmotifcan <Shift-ButtonRelease-1> {}
			bind $pmotifcan <Control-Shift-ButtonRelease-1> {}
			bind $pmotifcan <ButtonRelease-1> "MgrafixDelPitch $pmotifcan %x %y"
			bind $pmotifcan <Control-ButtonRelease-1> "MgrafixRestorePitch $pmotifcan $mtf_width"
			bind $pmotifcan <Shift-ButtonRelease-1> "MgrafixRestorePitches $pmotifcan $mtf_width"
			.melpage.5.ll config -text "DELETING NOTE : CLICK on Note to DELETE:                CONTROL-Click to RESTORE DELETES:              SHIFT-Click to RESTORE ALL DELETES:"
			.melpage.5a.ll config -fg [option get . foreground {}]
			set motif_ms 0
		}
	}
}

proc RedrawMotifTimeline {} {
	global mtf_width pm_times pmotifcan evv

	set offset $evv(MTF_OFFSET)
	set maxtime [lindex $pm_times end]
	set width [expr $mtf_width - $offset]
	set width [expr $width - $evv(NOTEWIDTH)]
	$pmotifcan delete withtag tline
	if {$maxtime < 100.0} {
		$pmotifcan create line $offset 150 830 150 -fill $evv(POINT) -tag tline
		set k 0.0
		set cnt 0
		set maxlim [expr $maxtime * 1.1]
		while {$k <= $maxlim} {
			set j [expr $k / $maxtime]
			set j [expr int(round($j * $width))]
			set pos [expr $offset + $j]
			set textpos [expr $pos - 4]
			if {$maxtime < 3.0} {
				if {[expr $cnt % 5] == 0} {
					$pmotifcan create line $pos 140 $pos 155 -fill $evv(POINT) -tag tline
					set no [DecPlaces $k 1]
					$pmotifcan create text $textpos 165 -anchor sw -text $no -font tiny_fnt -fill $evv(POINT) -tag tline
				} else {
					$pmotifcan create line $pos 155 $pos 160 -fill $evv(POINT) -tag tline
				}
			} elseif {[expr $cnt % 2] == 0} {
				$pmotifcan create line $pos 140 $pos 155 -fill $evv(POINT) -tag tline
				set no [DecPlaces $k 1]
				$pmotifcan create text $textpos 165 -anchor sw -text $no -font tiny_fnt -fill $evv(POINT) -tag tline
			} else {
				$pmotifcan create line $pos 155 $pos 160 -fill $evv(POINT) -tag tline
			}
			if {$maxtime < 3.0} {
				set k [expr $k + 0.1]
			} elseif {$maxtime < 10.0} {
				set k [expr $k + 0.5]
			} elseif {$maxtime < 100.0} {
				set k [expr $k + 5]
			}
			incr cnt
		}
	}
}

proc MotifInsertNote {x} {
	global pmotifcan pm_times pm_vals mtf_width pm_inbass evv

	set displaylist [$pmotifcan find withtag note]	;#	List all objects which are notes
	if {![info exists displaylist] || ([llength $displaylist] <= 0)} {
		return
	}
	set maxtime [lindex $pm_times end]
	foreach thisobj $displaylist {
		set xx [lindex [$pmotifcan coords $thisobj] 0]
		set diff [expr abs($x - ($xx + 4))]
		if {$diff <= $evv(MTF_HLFNUDGE)} {
			Inf "Too Close To An Existing Note"
			return
		}
	}
	if {$x >= [expr $mtf_width + $evv(MTF_OFFSET)]} {
		Inf "Cannot Add Notes Beyond End Of Motif"
		return
	} elseif {$x < $evv(MTF_OFFSET)} {
		Inf "Cannot Add Notes Before Time Zero"
		return
	}
	SaveOrigMotif
	set width [expr $mtf_width - $evv(MTF_OFFSET)]
	set width [expr $width - $evv(NOTEWIDTH)]
	set thistime [expr double($x - $evv(MTF_OFFSET)) / double($width)]
	set thistime [expr $thistime * $maxtime]
	switch -- $pm_inbass {
		0 {
			set thisval 72
		}
		1  { 
			set thisval 48
		}
		-1 {  
			set thisval 60
		}
	}
	set oldlen [llength $pm_times]
	set ccnt 0
	foreach time $pm_times {
		if {$time > $thistime} {
			break
		}
		incr ccnt
	}
	incr ccnt -1
	set times [lrange $pm_times 0 $ccnt]
	set vals  [lrange $pm_vals  0 $ccnt]
	incr ccnt
	set endtimes [lrange $pm_times $ccnt end]
	set endvals  [lrange $pm_vals  $ccnt end]
	set pm_times [concat $times $thistime $endtimes]
	set pm_vals  [concat $vals  $thisval  $endvals ]
	ReDrawNewMotifs $oldlen
	MotifMouseSwitch 0
}

proc PlayPmark {play} {
	global pitchmark mtf_insnd_fnam pa evv
	global CDPidrun program_messages prg_dun prg_abortd

	if {![info exists pitchmark($mtf_insnd_fnam)]} {
		Inf "No Pitchmark Exists For This Soundfile"
		return 0
	}
	set srate $pa($mtf_insnd_fnam,$evv(SRATE))
	set outdur $pa($mtf_insnd_fnam,$evv(DUR))
	set outfile cdptest03$evv(SNDFILE_EXT)
	if {![file exists $outfile]} {
		set ofnam cdptest03$evv(TEXT_EXT)
		if {![file exists $ofnam]} {
			if [catch {open $ofnam "w"} zit] {
				Inf "Cannot Open File '$ofnam' To Write Data For Synthesis"
				return 0
			}
			foreach val $pitchmark($mtf_insnd_fnam) {
				puts $zit $val
			}
			close $zit
		}
		set srate $pa($mtf_insnd_fnam,$evv(SRATE))
		Block "CREATING SOUNDFILE"
		catch {unset CDPidrun}
		catch {unset program_messages}
		set prg_dun 0
		set prg_abortd 0
		set CDPidrun 0
		set CDP_cmd [file join $evv(CDPROGRAM_DIR) synth]
		lappend CDP_cmd chord 1 $outfile $ofnam $srate 1 $outdur -a.3 -t4096
		if [catch {open "|$CDP_cmd"} CDPidrun] {
			Inf "$CDPidrun :\nCan't Synthesize Output"
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
			set errorline "Synthesis Failed"
		}
		if [info exists errorline] {
			Inf "$errorline"
		}
		if [info exists program_messages] {
			Inf "$program_messages"
			unset program_messages
		}
		UnBlock
		if {!$prg_dun} {
			return 0
		}
	}
	if {$play} {
		if [file exists $outfile] {
			PlaySndfile $outfile 0
		}
	}
	return 1
}

proc PlaySrcAndPmark {} {
	global mtf_insnd_fnam pa evv
	global CDPidrun program_messages prg_dun prg_abortd

	set outfile cdptest04$evv(SNDFILE_EXT)
	set infile  cdptest03$evv(SNDFILE_EXT)
	if {![file exists $outfile]} {
		if {![PlayPmark 0]} {
			return
		}
		if {![info exists pa($mtf_insnd_fnam,$evv(MAXSAMP))] || [Flteq $pa($mtf_insnd_fnam,$evv(MAXSAMP)) 0.0]} {
			set skew 1.0
		} else {
			set skew [expr 1.0 / $pa($mtf_insnd_fnam,$evv(MAXSAMP))]
		}
		Block "MIXING SOUNDS"
		catch {unset CDPidrun}
		catch {unset program_messages}
		set prg_dun 0
		set prg_abortd 0
		set CDPidrun 0
		set CDP_cmd [file join $evv(CDPROGRAM_DIR) submix]
		lappend CDP_cmd merge $mtf_insnd_fnam $infile $outfile -k$skew
		if [catch {open "|$CDP_cmd"} CDPidrun] {
			Inf "$CDPidrun :\nCan't Mix Sounds"
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
			set errorline "Mixing Failed"
		}
		if [info exists errorline] {
			Inf "$errorline"
		}
		if [info exists program_messages] {
			Inf "$program_messages"
			unset program_messages
		}
		UnBlock
		if {!$prg_dun} {
			return 0
		}
	}
	if [file exists $outfile] {
		PlaySndfile $outfile 0
	}
}

proc MtfNameTypeAdd {} {
	global mtfext mtf_fnam
	if {[string length $mtf_fnam] <= 0} {
		Inf "No Name To Add To"
		return
	}
	set fnam [file rootname $mtf_fnam]
	set k [string last "_" $fnam]
	if {$k > 0} {
		incr k
		set ending [string range $fnam $k end]
		switch -- $ending {
			"mtf"  -
			"midi" -
			"frq"  -
			"hf"   {
				incr k -2
				set fnam [string range $fnam 0 $k]
			}
		}
	}
	append fnam "_"
	switch -- $mtfext {
		0 { append fnam "mtf"} 
		1 { append fnam "midi"} 
		2 { append fnam "frq"} 
		3 { append fnam "hf"} 
	}
	set mtf_fnam $fnam
	.melpage.2.e xview moveto 1.0
}

proc PlayMotif {fnam aschord n} {
	global mtfmark pitchmark pa CDPidrun program_messages prg_dun prg_abortd evv
	set doenv 0
	set domix 0
	switch -- $aschord {
		2 {
			set moutfile cdptest000
			append moutfile $n $evv(SNDFILE_EXT)
			if {![file exists $moutfile]} {
				set outfile cdptest0
				append outfile $n $evv(SNDFILE_EXT)
				set nufnam [file rootname $fnam]
				append nufnam "_frq" $evv(TEXT_EXT)
				if {[file exists $nufnam]} {
					set ofnam $nufnam
				} else {
					set ofnam cdptest0
					append ofnam $n $evv(TEXT_EXT)
				}
				set aschord 0
			}
			set domix 1
		}
		1 {
			set outfile cdptest00
			append outfile $n $evv(SNDFILE_EXT)
			set ofnam cdptest00
			append ofnam $n $evv(TEXT_EXT)
		}
		0 {
			set outfile cdptest0
			append outfile $n $evv(SNDFILE_EXT)
			set nufnam [file rootname $fnam]
			append nufnam "_frq" $evv(TEXT_EXT)
			if {[file exists $nufnam]} {
				set ofnam $nufnam
			} else {
				set ofnam cdptest0
				append ofnam $n $evv(TEXT_EXT)
			}
		}
	}
	if {!($domix && [file exists $moutfile])} {
		if {![file exists $outfile]} {
			if {![file exists $ofnam]} {
				set ccnt 0
				set time 0.0
				if {$aschord} {
					if [catch {open $ofnam "w"} zit] {
						Inf "Cannot Open File '$ofnam' To Write Motif Data For Synthesis"
						return
					}
					foreach val $pitchmark($fnam) {
						puts $zit $val
					}
					close $zit
				} else {
					foreach val $mtfmark($fnam) {				;#	Construct visible pitches list
						if {$ccnt == 0} {
							lappend nuvals $time [MidiToHz $val]
							lappend evals $time 1.0
						} else {
							if {![Flteq $val $lastval]} {
								set midtime [expr $time - $evv(MTF_PGLIDE)]
								if {$midtime > $lasttime} {
									lappend nuvals $midtime [MidiToHz $lastval]
								}
							} else {
								set etime [expr $time - $evv(MTF_PGLIDE)]
								set eetime [expr $etime - (2 * $evv(MTF_PGLIDE))]
								if {$eetime > [expr $lasttime + $evv(MTF_PGLIDE)]} {
									lappend evals $eetime 1.0
									set eetime [expr $eetime + $evv(MTF_PGLIDE)]
									lappend evals $eetime 0.0
									lappend evals $etime 0.0
									lappend evals $time 1.0
									set doenv 1
								}
							}
							lappend nuvals $time [MidiToHz $val]
						}
						set lasttime $time
						set time [expr $time + 0.33]
						set lastval $val
						incr ccnt
					}
					lappend nuvals $time [MidiToHz $lastval]
					lappend evals $time 1.0
					if [catch {open $ofnam "w"} zit] {
						Inf "Cannot Open File '$ofnam' To Write Motif Data For Synthesis"
						return
					}
					foreach {time val} $nuvals {
						set line $time
						lappend line $val
						puts $zit $line
					}
					close $zit
					if {$doenv} {
						set oefnam cdptest0000$evv(TEXT_EXT)
						if [catch {open $oefnam "w"} zit] {
							Inf "Cannot Open File '$oefnam' To Write Envelope Data For Synthesis"
							return 0
						}
						foreach {time val} $evals {
							set line $time
							lappend line $val
							puts $zit $line
						}
						close $zit
					}
				}
			}
			set srate $pa($fnam,$evv(SRATE))
			if {$aschord} {
				Block "CREATING NEW SOUNDFILE"
			} else {
				if {![string match $ofnam cdptest0$n$evv(TEXT_EXT)]} {
					set dur $pa($fnam,$evv(DUR))
					Block "CREATING NEW SOUNDFILE USING DATA IN '$ofnam'"
				} else {
					set dur [expr [llength $mtfmark($fnam)] * 0.33]
					Block "CREATING NEW SOUNDFILE"
				}
			}
			catch {unset CDPidrun}
			catch {unset program_messages}
			set prg_dun 0
			set prg_abortd 0
			set CDPidrun 0
			set CDP_cmd [file join $evv(CDPROGRAM_DIR) synth]
			if {$aschord} {
				lappend CDP_cmd chord 1 $outfile $ofnam $srate 1 4 -a.3 -t4096
			} else {
				lappend CDP_cmd wave 1 $outfile $srate 1 $dur $ofnam -a.3 -t4096
			}
			if [catch {open "|$CDP_cmd"} CDPidrun] {
				Inf "$CDPidrun :\nCan't Synthesize Output"
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
				set errorline "Synthesis Failed"
			}
			if [info exists errorline] {
				Inf "$errorline"
			}
			if [info exists program_messages] {
				Inf "$program_messages"
				unset program_messages
			}
			UnBlock
			if {!$prg_dun} {
				return
			}
			if {$doenv} {
				Block "ENVELOPING SYNTHESIZED SOUND"
				catch {unset CDPidrun}
				catch {unset program_messages}
				set prg_dun 0
				set prg_abortd 0
				set CDPidrun 0
				set CDP_cmd [file join $evv(CDPROGRAM_DIR) envel]
				lappend CDP_cmd impose 3 $outfile $oefnam cdptest0000$evv(SNDFILE_EXT)
				if [catch {open "|$CDP_cmd"} CDPidrun] {
					Inf "$CDPidrun :\nCan't Envelope Synthesized Output"
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
					set errorline "Enveloping Failed"
				}
				if [info exists errorline] {
					Inf "$errorline"
				}
				if [info exists program_messages] {
					Inf "$program_messages"
					unset program_messages
				}
				UnBlock
				if {!$prg_dun} {
					return
				}
				if {[catch {file delete $outfile} zit]} {
					Inf "Cannot Delete Un-Enveloped Synth Sound: No Enveloping"
				} elseif {[catch {file rename cdptest0000$evv(SNDFILE_EXT) $outfile} zit]} {
					Inf "Failed To Rename Enveloped Synth File"
					return
				}
			}
		}
	}
	if {$domix} {
		if {![file exists $moutfile]} {
			Block "MIXING SOUNDS"
			if {[info exists pa($fnam,$evv(MAXSAMP))]} {
				set skew [expr 1.0 / $pa($fnam,$evv(MAXSAMP))]
			} else {
				set skew 1.0
			}
			set CDP_cmd [file join $evv(CDPROGRAM_DIR) submix]
			lappend CDP_cmd merge $fnam $outfile $moutfile -k$skew
			if [catch {open "|$CDP_cmd"} CDPidrun] {
				Inf "$CDPidrun :\nCan't Mix Sounds"
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
				set errorline "Mixing Failed"
			}
			if [info exists errorline] {
				Inf "$errorline"
			}
			if [info exists program_messages] {
				Inf "$program_messages"
				unset program_messages
			}
			UnBlock
			if {!$prg_dun} {
				return 0
			}
		}
		set outfile $moutfile
	}
	if {[file exists $outfile]} {
		PlaySndfile $outfile 0
	}
}

proc Read_Duration {} {
	global CDPidrun rundisplay prg_dun prg_abortd program_messages evv
	global bulk super_abort

	if {[info exists CDPidrun] && [eof $CDPidrun]} {
		set prg_dun 1
		catch {close $CDPidrun}
		unset CDPidrun
		return
	} else {
		gets $CDPidrun line
		set line [string trim $line]
		if {[string length $line] <= 0} {
			return
		}
		if [string match ERROR:* $line] {
			set program_messages "$line"
			set prg_abortd 1
			set prg_dun 0
			return
		} elseif [string match END* $line] {
			set prg_dun 1
			catch {close $CDPidrun}
			unset CDPidrun
			return
		} else {
			set program_messages "$line"
			return
		}
	}
	update idletasks
}

proc UseSrcName {} {
	global mtf_fnam mtf_insnd_fnam
	catch {unset mtf_fnam}
	set mtf_fnam [ReplaceSpaces [file rootname [file tail $mtf_insnd_fnam]]]
}

proc ReplaceSpaces {fnam} {
	set zfnam [string trim $fnam]
	set extt  [file extension $fnam]
	set zfnam [file rootname $zfnam]
	set zfnam [split $zfnam]
	set k [llength $zfnam]
	if {$k > 1} {
		set nufnam ""
		foreach item $zfnam {
			set item [string trim $item]
			if {[string length $item] > 0} {
				append nufnam $item "_"
			}
		}
		set len [string length $nufnam]
		incr len -2
		set fnam [string range $nufnam 0 $len]
		append fnam $extt
	}
	return $fnam
}

proc ReplaceDots {fnam} {
	set pointatend 0
	set zfnam [string trim $fnam]
	set extt  [file extension $fnam]
	set zfnam [file rootname $zfnam]
	if {[string match [string index $zfnam 0] "."]} {
		set nufnam "p"
	} else {
		set nufnam ""
	}
	if {[string match [string index $zfnam end] "."]} {
		set pointatend 1
	}
	set zfnam [split $zfnam "."]
	set k [llength $zfnam]
	if {$k > 1} {
		foreach item $zfnam {
			set item [string trim $item]
			if {[string length $item] > 0} {
				append nufnam $item "p"
			}
		}
		if {$pointatend} {
			set fnam $nufnam
		} else {
			set len [string length $nufnam]
			incr len -2
			set fnam [string range $nufnam 0 $len]
		}
		append fnam $extt
	}
	return $fnam
}
