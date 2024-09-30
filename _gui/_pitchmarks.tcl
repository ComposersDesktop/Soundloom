#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD June 30 2013
# ... fixup button rectangles

###################################
# ADDING PITCH INFO TO SOUNDFILES #
###################################

#----- Load pitch marks used in last session(s)

proc LoadPitchMarks {} {
	global pitchmark evv

	set pfnam [file join $evv(URES_DIR) $evv(PITCHMARK)$evv(CDP_EXT)]
	if {[file exists $pfnam]} {
		if [catch {open $pfnam "r"} fId] {
			Inf "Failed to open file '$pfnam' to find existing Pitch markers"
			return
		}
		while {[gets $fId line] >= 0} {
			set line [string trim $line]
			if {[string length $line] > 0} {
				set line [split $line]
				set fnam [string trim [lindex $line 0]]
				if {([string length $fnam] < 0) || ![file exists $fnam]} {
					continue
				}
				if {![file exists $fnam]} {
					continue
				}
				set OK 1
				foreach item [lrange $line 1 end] {
					if {([string length [string trim $item]] <= 0) || [regexp {[^0-9]} $item]} {
						Inf "Spurious data in pitchmarks file, for soundfile '$fnam'\n\nFix in file '$pfnam' before proceeding"
						break
					}
					lappend pitchmark($fnam) $item
				}
			}
		}
	}
	catch {close $fId}
}

#--- Save pitchmarks to disk

proc StorePitchMarks {} {
	global pitchmark evv

	set pm_file [file join $evv(URES_DIR) $evv(PITCHMARK)$evv(CDP_EXT)]
	if {[info exists pitchmark]} {	
		foreach fnam [array names pitchmark] {
			if {![file exists $fnam]} {
				catch {unset pitchmark($fnam)}
			}
		}
	}
	if {![info exists pitchmark]} {	
		if {[file exists $pm_file]} {
			catch {file delete $pm_file}
		}
		return
	}
	if [catch {open $evv(DFLT_TMPFNAME)$evv(CDP_EXT) w} fId] {
		Inf "Cannot open temporary file to backup pitchmarks"
		return
	} else {
		foreach fnam [array names pitchmark] {
			catch {unset line}
			lappend line $fnam
			foreach item $pitchmark($fnam) {
				lappend line $item
			}
			puts $fId $line
		}
		close $fId
	}
	if [file exists $pm_file] {
		if [catch {file delete $pm_file} zorg] {
			Inf "Cannot delete existing pitch markers file, to write current pitch markers.\n\nData is in file '$evv(DFLT_TMPFNAME)$evv(CDP_EXT)'\n\nTo save this data\nRename this file (outside the CDP) as '$pm_file' Before Proceeding"
			return
		}
	}
	if [catch {file rename $evv(DFLT_TMPFNAME)$evv(CDP_EXT) $pm_file}] {
		ErrShow "Failed to save reference pitch markers data\n\nData is in file $evv(DFLT_TMPFNAME)$evv(CDP_EXT)\n\nTo save this data\nRename this file (outside the CDP) as $pm_file BEFORE PROCEEDING"
	}
}

#------- Create, Edit, or Delete Pitchmark

proc DoPitchmark {fnam type} {
	global pr_pm b_l pm_var pmgrafix pitchmark lastpmfnam pmarkref last_plist sl_real pm_numidilist evv

	if {[info exists pm_numidilist]} {
		set orig_pm_midilist $pm_numidilist
	} else {
		set orig_pm_midilist {}
	}
	if {$type != $evv(COMPARE_PMARK)} {
		set pmarkref ""
	}
	if {[string length $fnam] > 0} {
		if {![info exists pitchmark($fnam)]} {
			switch -regexp -- $type \
				$evv(DEL_PMARK) {
					Inf "There Is No Existing Pitch Marker For '$fnam'"
					return
				} \
				$evv(SHOW_PMARK) {
					return
				} \
				^$evv(CREATE_PMARK)$ {
					set pm_numidilist {}
				}
		} else {
			set pm_numidilist $pitchmark($fnam)
		}
	} else {
		set pm_numidilist {}
	}
	set f .pmark
	if [Dlg_Create $f "CREATE OR EDIT PITCH MARK" "set pr_pm 0" -width 120 -borderwidth $evv(SBDR)] {
		set b [frame $f.b -borderwidth $evv(SBDR)]
		set b0 [frame $f.b0 -height 1 -bg $evv(POINT)]
		set c [frame $f.c -borderwidth $evv(SBDR)]
		set c0 [frame $f.c0 -height 1 -bg $evv(POINT)]
		set e [frame $f.e -borderwidth $evv(SBDR)]
		set e0 [frame $f.e0 -height 1 -bg $evv(POINT)]
		set d [frame $f.d -borderwidth $evv(SBDR)]
		button $b.k -text "Keep" -command "set pr_pm 5" -highlightbackground [option get . background {}]
		button $b.d -text "" -command {} -width 14 -highlightbackground [option get . background {}]
		button $b.d2 -text "" -command {} -width 14 -highlightbackground [option get . background {}]
		button $b.d3 -text "" -command {} -width 14 -highlightbackground [option get . background {}]
		button $b.d4 -text "" -command {} -width 4 -highlightbackground [option get . background {}]
		button $b.q -text "No Change" -command "set pr_pm 0" -width 9 -highlightbackground [option get . background {}]
		pack $b.k $b.d -side left -padx 2
		pack $b.d2 $b.d4 $b.d3 -side left -padx 2
		pack $b.q -side right -padx 2
		button $c.p -text Play -command "PlaySndfile $fnam 0" -width 4 -bd 4  -highlightbackground [option get . background {}]
		label $c.l -text "\n\n\n\n" -width 35
		if {!$sl_real} {
			button $c.a -text A -command TellA -width 2 -bd 4  -highlightbackground [option get . background {}];# -bg $evv(HELP)
		} else {
			button $c.a -text A -command {PlaySndfile $evv(TESTFILE_A) 0} -width 2 -bd 4  -highlightbackground [option get . background {}];# -bg $evv(HELP)
		}
		pack $c.p $c.l $c.a -side left -fill x -expand true -anchor center
		label $e.l -text "SOUND FILE" -width 12
		entry $e.e -textvariable pm_var -width 48 -state disabled -bg $evv(EMPH)
		pack $e.l $e.e -side left -fill x -anchor center
		set dd [frame $d.d -borderwidth $evv(SBDR)]
		set dd2 [frame $d.d2 -borderwidth $evv(SBDR)]
		label $dd.l -text "PITCH MARK"
		label $dd2.l -text ""
		Scrolled_Listbox $dd.ll -width 20 -height 20 -selectmode single
		set pmgrafix [EstablishPmarkDisplay $d.d2]
		pack $dd.l $dd.ll -side top -pady 1
		pack $dd2.l $pmgrafix -side top -pady 1
		pack $dd $dd2 -side left -fill x -expand true
		pack $b -side top -fill x -expand true -pady 1
		pack $b0 -side top -fill x -expand true -pady 4
		pack $e -side top -fill x -expand true -pady 1
		pack $e0 -side top -fill x -expand true -pady 4
 		pack $c -side top -fill x -expand true -pady 1
		pack $c0 -side top -fill x -expand true -pady 4
		pack $d -side top -fill x -expand true -pady 1
		wm resizable $f 1 1
		bind .pmark <Control-Key-P> "UniversalPlay pmark $fnam"
		bind .pmark <Control-Key-p> "UniversalPlay pmark $fnam"
		bind .pmark <Key-space>		"UniversalPlay pmark $fnam"
		bind $pmgrafix <ButtonRelease-1> {}
		bind $pmgrafix <Shift-ButtonRelease-1> {}
		bind $pmgrafix <Control-ButtonRelease-1> {}
	}
	if {$type == $evv(SHOW_PMARK)} {
		wm geometry $f [ToRightHalf .workspace $f]
		bind .pmark <Control-=> {destroy .pmark}
	} else {
		bind .pmark <Control-=> {}
	}
	ForceVal $f.e.e $fnam
	switch -regexp -- $type \
		^$evv(CREATE_PMARK)$ {
			wm title $f "CREATE OR EDIT PITCH MARK"
			$f.b.k config -text "Keep" -command "set pr_pm 5" -bd 2 -state normal -bg $evv(EMPH)
			$f.b.q config -text "Abandon" -command "set pr_pm 0" -bd 2 -state normal
			$f.b.d config -text "" -command {} -bd 0 -state disabled
			$f.b.d2 config -text "" -command {} -bd 0 -state disabled
			$f.b.d3 config -text "Previous" -command "set pr_pm 3" -bd 2 -state normal
			$f.b.d4 config -text "Clear" -command "set pr_pm 4" -bd 2 -state normal -state normal
			$f.c.l config -text "Click on Stave TO ADD VALUES\nShift-Click TO ADD FLAT VALUES\n\nTO REMOVE VALUES Control-Click\n"
			$f.c.p config -text Play -command "PlaySndfile $fnam 0" -width 4 -bd 4 -state normal
			if {!$sl_real} {
				$f.c.a config -text A -command TellA -width 2 -bd 4 ;# -bg $evv(HELP)
			} else {
				$f.c.a config -text A -command {PlaySndfile $evv(TESTFILE_A) 0} -width 2 -bd 4 -state normal ;# -bg $evv(HELP)
			}
			bind $pmgrafix <ButtonRelease-1> {PgrafixAddPitch $pmgrafix %x %y 0}
			bind $pmgrafix <Shift-ButtonRelease-1> {PgrafixAddPitch $pmgrafix %x %y 1}
			bind $pmgrafix <Control-ButtonRelease-1> {PgrafixDelPitch $pmgrafix %x %y}
		} \
		^$evv(SETUP_PMARK)$ {
			wm title $f "REFERENCE PITCH MARK"
			$f.b.k config -text "" -command {} -bd 0 -state disabled -bg [option get . background {}]
			$f.b.q config -text "Abandon" -command "set pr_pm 0" -bd 2 -state normal
			$f.b.d config -text "Original" -command "set pr_pm 3" -bd 2 -state normal
			$f.b.d2 config -text "" -command {} -bd 0 -state disabled
			$f.b.d3 config -text "Compare" -command "set pr_pm 2" -bd 2 -state normal
			$f.b.d4 config -text "" -command {} -bd 0 -state disabled
			$f.c.l config -text "Click on Stave TO ADD VALUES\nShift-Click TO ADD FLAT VALUES\n\nTO REMOVE VALUES Control-Click\n"
			$f.c.p config -text Play -command "PlaySndfile $fnam 0" -width 4 -bd 4 -state normal
			if {!$sl_real} {
				$f.c.a config -text A -command TellA -width 2 -bd 4 ;# -bg $evv(HELP)
			} else {
				$f.c.a config -text A -command {PlaySndfile $evv(TESTFILE_A) 0} -width 2 -bd 4 -state normal ;# -bg $evv(HELP)
			}
			bind $pmgrafix <ButtonRelease-1> {PgrafixAddPitch $pmgrafix %x %y 0}
			bind $pmgrafix <Shift-ButtonRelease-1> {PgrafixAddPitch $pmgrafix %x %y 1}
			bind $pmgrafix <Control-ButtonRelease-1> {PgrafixDelPitch $pmgrafix %x %y}
		} \
		^$evv(DEL_PMARK)$ {
			wm title $f "DESTROY PITCH MARK"
			$f.b.k config -text "" -command {} -bd 0 -state disabled -bg [option get . background {}]
			$f.b.q config -text "Abandon" -command "set pr_pm 0" -bd 2 -state normal
			$f.b.d config -text "Destroy" -command "set pr_pm 1" -bd 2 -state normal
			$f.b.d2 config -text "" -command {} -bd 0 -state disabled
			$f.b.d3 config -text "" -command {} -bd 0 -state disabled
			$f.b.d4 config -text "" -command {} -bd 0 -state disabled
			$f.c.l config -text "\n\n\n\n"
			$f.c.p config -text Play -command "PlaySndfile $fnam 0" -width 4 -bd 4 -state normal
			if {!$sl_real} {
				$f.c.a config -text A -command TellA -width 2 -bd 4 ;# -bg $evv(HELP)
			} else {
				$f.c.a config -text A -command {PlaySndfile $evv(TESTFILE_A) 0} -width 2 -bd 4 -state normal ;# -bg $evv(HELP)
			}
		} \
		^$evv(SHOW_PMARK)$ {
			wm title $f "SOUNDFILE PITCH MARK"
			$f.b.k config -text "" -command {} -bd 0 -state disabled -bg [option get . background {}]
			$f.b.q config -text "" -command {} -bd 0 -state disabled
			$f.b.d config -text "" -command {} -bd 0 -state disabled
			$f.b.d2 config -text "" -command {} -bd 0 -state disabled
			$f.b.d3 config -text "" -command {} -bd 0 -state disabled
			$f.b.d4 config -text "" -command {} -bd 0 -state disabled
			$f.c.l config -text "\nTO REMOVE THIS DISPLAY\nUSE THE WORKSPACE MENU\n\n(OR SELECT A FILE WITH NO PITCH MARK)"
			$f.c.p config -text ""  -command {} -bd 0 -state disabled
			$f.c.a config -text ""  -command {} -bd 0  -bg [option get . background {}] -state disabled
		} \
		^$evv(COMPARE_PMARK)$ {
			wm title $f "PITCH MARK COMPARISON"
			$f.b.k config -text "" -command {} -bd 0 -state disabled -bg [option get . background {}]
			$f.b.q config -text " OK " -command "set pr_pm 0" -bd 2 -state normal
			$f.b.d config -text "" -command {} -bd 0 -state disabled
			$f.b.d2 config -text "" -command {} -bd 0 -state disabled
			$f.b.d3 config -text "" -command {} -bd 0 -state disabled
			$f.b.d4 config -text "" -command {} -bd 0 -state disabled
			$f.c.l config -text "\n\n\n\n"
			$f.c.p config -text ""  -command {} -bd 0 -state disabled
			$f.c.a config -text ""  -command {} -bd 0  -bg [option get . background {}] -state disabled
		} \
		^$evv(DISPLAY_PMARK)$ {
			wm title $f "SOUNDFILE PITCH MARK"
			$f.b.k config -text "" -command {} -bd 0 -state disabled -bg [option get . background {}]
			$f.b.q config -text " OK " -command "set pr_pm 0" -bd 2 -state normal
			$f.b.d config -text "" -command {} -bd 0 -state disabled
			$f.b.d2 config -text "" -command {} -bd 0 -state disabled
			$f.b.d3 config -text "" -command {} -bd 0 -state disabled
			$f.b.d4 config -text "" -command {} -bd 0 -state disabled
			$f.c.l config -text "\n\n\n\n"
			$f.c.p config -text ""  -command {} -bd 0 -state disabled
			$f.c.a config -text ""  -command {} -bd 0  -bg [option get . background {}] -state disabled
		}

	$f.e.l config -text "SOUND FILE"
	if {[string length $fnam] <= 0} {
		ClearPmarkGrafix
		$f.c.p config -text ""  -command {} -bd 0 -state disabled
		$f.e.l config -text ""
	} elseif {![string match $fnam $lastpmfnam]} {
		ClearPmarkGrafix
	}
	set thisplist {}
	$f.d.d.ll.list delete 0 end
	if {$type == $evv(COMPARE_PMARK)} {
		foreach item $pmarkref {
			$f.d.d.ll.list insert end $item
			lappend thisplist $item
		}
	} elseif {([string length $fnam] > 0) && [info exists pitchmark($fnam)]} {
		foreach item $pitchmark($fnam) {
			$f.d.d.ll.list insert end $item
			lappend thisplist $item
		}
	}
	InsertPmarkGrafix $thisplist
	raise $f
	if {$type == $evv(SHOW_PMARK)} {
		return
	}
	update idletasks
	StandardPosition $f
	set pr_pm 0
	set listing_altered 0
	set finished 0
	My_Grab 0 $f pr_pm $f.d.d.ll.list
	while {!$finished} {
		tkwait variable pr_pm
		switch -- $pr_pm {
			0 {											;#	QUIT
				set finished 1
			}
			1 {											;# DELETE PMARK
				if {[AreYouSure]} {
					catch {unset pitchmark($fnam)}
					catch {$pmgrafix delete notes}
					catch {$pmgrafix delete flats}
					catch {$pmgrafix delete ledger}
					set listing_altered 1
					set finished 1
				}
			}
			2 {											;#	KEEP AS REFERENCE
				catch {unset pmarkref}
				foreach item [$f.d.d.ll.list get 0 end] {
					lappend pmarkref $item
				}
				if {![info exists pmarkref] || ([llength $pmarkref] <= 0)} {
					Inf "No Pitches To Compare"
					continue
				}
				set finished 1
			}
			3 {
				if {$type == $evv(CREATE_PMARK)} {
					if {![info exists last_plist]} {
						Inf "Previous Pitch Marker Has Not Been Called, Or Has Been Deleted"
						continue
					}
					set thisplist $last_plist
				} elseif {$type == $evv(SETUP_PMARK)} {
					if {[string length $fnam] <= 0} {
						set pm_numidilist {}
						ClearPmarkGrafix
						$f.d.d.ll.list delete 0 end
						continue
					}
					set pm_numidilist $pitchmark($fnam)
					set thisplist $pitchmark($fnam)
				}
				$f.d.d.ll.list delete 0 end
				foreach item $thisplist {
					$f.d.d.ll.list insert end $item
				}
				InsertPmarkGrafix $thisplist
			}
			4 {
				set thisplist {}
				$f.d.d.ll.list delete 0 end
				ClearPmarkGrafix
				if {$type == $evv(CREATE_PMARK)} {				
					set newplist {}
				}
			}
			5 {
				if {$type == $evv(CREATE_PMARK)} {
					set newplist {}
					foreach item [$f.d.d.ll.list get 0 end] {
						lappend newplist $item
					}
					set newplist [lsort -real -decreasing $newplist]
					if [info exists newplist] {
						if {[llength $newplist] <= 0} {
							if [info exists pitchmark($fnam)] {
								unset pitchmark($fnam)
								catch {unset last_plist}
								set listing_altered 1
							}
						} else {
							set same 0
							if [info exists pitchmark($fnam)] {
								set same 1
								if {[llength $pitchmark($fnam)] != [llength $newplist]} {
									set same 0
								} else {
									foreach item1 $pitchmark($fnam) item2 $newplist {
										if {![string match $item1 $item2]} {
											set same 0
											break
										}
									}
								}
							}
							if {!$same} {
								set pitchmark($fnam) $newplist
								set listing_altered 1
							}
							set last_plist $newplist
						}
					} elseif [info exists pitchmark($fnam)] {
						set last_plist $pitchmark($fnam)
					}
					
					set finished 1
				}
			}
		}
	}
	if {$listing_altered} {
		if {[info exists pitchmark]} {
			StorePitchMarks
		} else {
			set pm_file [file join $evv(URES_DIR) $evv(PITCHMARK)$evv(CDP_EXT)]
			if [file exists $pm_file] {
				if [catch {file delete $pm_file} zorg] {
					Inf "Cannot delete now-redundant pitch markers file\n\nDelete this file outside the CDP"
				}
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#------ Establish interactive pstaff notation display

proc EstablishPmarkDisplay {pstaff} {
	global pr_pnscreen pnscrlist pnscrlist_out pnscreenval pnfilename pnscreencnt evv shortwindows

	#	CANVAS AND VALUE LISTING

	if {[info exists shortwindows]} {
		set pnscreen [canvas $pstaff.c -height 400 -width 250 -borderwidth 0 \
			-highlightthickness 1 -highlightbackground $evv(SPECIAL)]

		set octsup [$pnscreen create text 40 70 -text "16va up" -font {helvetica 14 bold} -fill $evv(GRAF)]

		$pnscreen create line 80  20 280 20 -tag notehite -fill [option get . background {}]
		$pnscreen create line 80  25 280 25 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  30 280 30 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  35 280 35 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  40 280 40 -tag notehite -fill $evv(POINT)	
		$pnscreen create line 80  45 280 45 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  50 280 50 -tag {notehite flathite} -fill $evv(POINT) 
		$pnscreen create line 80  55 280 55 -tag notehite -fill [option get . background {}]
		$pnscreen create line 80  60 280 60 -tag {notehite flathite} -fill $evv(POINT)
		$pnscreen create line 80  65 280 65 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  70 280 70 -tag {notehite flathite} -fill $evv(POINT)
		$pnscreen create line 80  75 280 75 -tag notehite -fill [option get . background {}]
		$pnscreen create line 80  80 280 80 -tag {notehite flathite} -fill $evv(POINT)
		$pnscreen create line 80  85 280 85 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  90 280 90 -tag notehite -fill [option get . background {}]

		#TREBLE CLEF
		set clef1a [$pnscreen create line 90  30 90 95 -width 1 -fill $evv(POINT)]
		set clef1b [$pnscreen create arc 90 24 102 36 -style arc -start 180 -extent -230 -width 1 -outline $evv(POINT)]
		set clef1c [$pnscreen create line 98  35 80 70 -width 1 -fill $evv(POINT)]
		set clef1d [$pnscreen create arc 80 60 100 80 -style arc -start 180 -extent 270 -width 1 -outline $evv(POINT)]

		$pnscreen create line 80  140 280 140 -tag notehite -fill [option get . background {}]
		$pnscreen create line 80  145 280 145 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  150 280 150 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  155 280 155 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  160 280 160 -tag notehite -fill $evv(POINT)
		$pnscreen create line 80  165 280 165 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  170 280 170 -tag {notehite flathite} -fill $evv(POINT)
		$pnscreen create line 80  175 280 175 -tag notehite -fill [option get . background {}]
		$pnscreen create line 80  180 280 180 -tag {notehite flathite} -fill $evv(POINT)
		$pnscreen create line 80  185 280 185 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  190 280 190 -tag {notehite flathite} -fill $evv(POINT)
		$pnscreen create line 80  195 280 195 -tag notehite -fill [option get . background {}]
		$pnscreen create line 80  200 280 200 -tag {notehite flathite} -fill $evv(POINT)
		$pnscreen create line 80  205 280 205 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  210 280 210 -tag notehite -fill [option get . background {}]

		#TREBLE CLEF2
		set clef2a [$pnscreen create line 90  150 90 215 -width 1 -fill $evv(POINT)]
		set clef2b [$pnscreen create arc 90 144 102 156 -style arc -start 180 -extent -230 -width 1 -outline $evv(POINT)]
		set clef2c [$pnscreen create line 98  155 80 190 -width 1 -fill $evv(POINT)]
		set clef2d [$pnscreen create arc 80 180 100 200 -style arc -start 180 -extent 270 -width 1 -outline $evv(POINT)]

		$pnscreen create line 80  215 280 215 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  220 280 220 -tag {notehite flathite} -fill $evv(POINT)
		$pnscreen create line 80  225 280 225 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  230 280 230 -tag notehite -fill $evv(POINT)
		$pnscreen create line 80  235 280 235 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  240 280 240 -tag {notehite flathite} -fill $evv(POINT)
		$pnscreen create line 80  245 280 245 -tag notehite -fill [option get . background {}]
		$pnscreen create line 80  250 280 250 -tag {notehite flathite} -fill $evv(POINT)
		$pnscreen create line 80  255 280 255 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  260 280 260 -tag {notehite flathite} -fill $evv(POINT)
		$pnscreen create line 80  265 280 265 -tag notehite -fill [option get . background {}]
		$pnscreen create line 80  270 280 270 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  275 280 275 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  280 280 280 -tag notehite -fill [option get . background {}]

		#BASS CLEF2
		set bclef2a [$pnscreen create arc 80 220 107 255 -style arc -start 30 -extent 120 -width 1 -outline $evv(POINT)]
		set bclef2b [$pnscreen create arc 25 195 105 265 -style arc -start 5 -extent -75 -width 1 -outline $evv(POINT)]
		set bclef2c [$pnscreen create oval 109 224 111 226 -fill $evv(POINT) -outline $evv(POINT)]
		set bclef2d [$pnscreen create oval 109 234 111 236 -fill $evv(POINT) -outline $evv(POINT)]

		$pnscreen create line 80  330 280 330 -tag notehite -fill [option get . background {}]
		$pnscreen create line 80  335 280 335 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  340 280 340 -tag {notehite flathite} -fill $evv(POINT)
		$pnscreen create line 80  345 280 345 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  350 280 350 -tag notehite -fill $evv(POINT)
		$pnscreen create line 80  355 280 355 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  360 280 360 -tag {notehite flathite} -fill $evv(POINT)
		$pnscreen create line 80  365 280 365 -tag notehite -fill [option get . background {}]
		$pnscreen create line 80  370 280 370 -tag {notehite flathite} -fill $evv(POINT)
		$pnscreen create line 80  375 280 375 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  380 280 380 -tag {notehite flathite} -fill $evv(POINT)
		$pnscreen create line 80  385 280 385 -tag notehite -fill [option get . background {}]
		$pnscreen create line 80  390 280 390 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  395 280 395 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  400 280 400 -tag notehite -fill [option get . background {}]

		set octsdn [$pnscreen create text 50 370 -text "16va down" -font {helvetica 14 bold} -fill $evv(GRAF)]

		#BASS CLEF3
		set bclef3a [$pnscreen create arc 80 340 107 375 -style arc -start 30 -extent 120 -width 1 -outline $evv(POINT)]
		set bclef3b [$pnscreen create arc 25 315 105 385 -style arc -start 5 -extent -75 -width 1 -outline $evv(POINT)]
		set bclef3c [$pnscreen create oval 109 344 111 346 -fill $evv(POINT) -outline $evv(POINT)]
		set bclef3d [$pnscreen create oval 109 354 111 356 -fill $evv(POINT) -outline $evv(POINT)]

	} else {
		set pnscreen [canvas $pstaff.c -height 500 -width 250 -borderwidth 0 \
			-highlightthickness 1 -highlightbackground $evv(SPECIAL)]

		set octsup [$pnscreen create text 40 70 -text "16va up" -font {helvetica 14 bold} -fill $evv(GRAF)]

		$pnscreen create line 80  20 280 20 -tag notehite -fill [option get . background {}]
		$pnscreen create line 80  25 280 25 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  30 280 30 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  35 280 35 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  40 280 40 -tag notehite -fill $evv(POINT)	
		$pnscreen create line 80  45 280 45 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  50 280 50 -tag {notehite flathite} -fill $evv(POINT) 
		$pnscreen create line 80  55 280 55 -tag notehite -fill [option get . background {}]
		$pnscreen create line 80  60 280 60 -tag {notehite flathite} -fill $evv(POINT)
		$pnscreen create line 80  65 280 65 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  70 280 70 -tag {notehite flathite} -fill $evv(POINT)
		$pnscreen create line 80  75 280 75 -tag notehite -fill [option get . background {}]
		$pnscreen create line 80  80 280 80 -tag {notehite flathite} -fill $evv(POINT)
		$pnscreen create line 80  85 280 85 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  90 280 90 -tag notehite -fill [option get . background {}]

		#TREBLE CLEF
		set clef1a [$pnscreen create line 90  30 90 95 -width 1 -fill $evv(POINT)]
		set clef1b [$pnscreen create arc 90 24 102 36 -style arc -start 180 -extent -230 -width 1 -outline $evv(POINT)]
		set clef1c [$pnscreen create line 98  35 80 70 -width 1 -fill $evv(POINT)]
		set clef1d [$pnscreen create arc 80 60 100 80 -style arc -start 180 -extent 270 -width 1 -outline $evv(POINT)]

		$pnscreen create line 80  170 280 170 -tag notehite -fill [option get . background {}]
		$pnscreen create line 80  175 280 175 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  180 280 180 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  185 280 185 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  190 280 190 -tag notehite -fill $evv(POINT)
		$pnscreen create line 80  195 280 195 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  200 280 200 -tag {notehite flathite} -fill $evv(POINT)
		$pnscreen create line 80  205 280 205 -tag notehite -fill [option get . background {}]
		$pnscreen create line 80  210 280 210 -tag {notehite flathite} -fill $evv(POINT)
		$pnscreen create line 80  215 280 215 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  220 280 220 -tag {notehite flathite} -fill $evv(POINT)
		$pnscreen create line 80  225 280 225 -tag notehite -fill [option get . background {}]
		$pnscreen create line 80  230 280 230 -tag {notehite flathite} -fill $evv(POINT)
		$pnscreen create line 80  235 280 235 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  240 280 240 -tag notehite -fill [option get . background {}]

		#TREBLE CLEF2
		set clef2a [$pnscreen create line 90  180 90 245 -width 1 -fill $evv(POINT)]
		set clef2b [$pnscreen create arc 90 174 102 186 -style arc -start 180 -extent -230 -width 1 -outline $evv(POINT)]
		set clef2c [$pnscreen create line 98  185 80 220 -width 1 -fill $evv(POINT)]
		set clef2d [$pnscreen create arc 80 210 100 230 -style arc -start 180 -extent 270 -width 1 -outline $evv(POINT)]

		$pnscreen create line 80  245 280 245 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  250 280 250 -tag {notehite flathite} -fill $evv(POINT)
		$pnscreen create line 80  255 280 255 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  260 280 260 -tag notehite -fill $evv(POINT)
		$pnscreen create line 80  265 280 265 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  270 280 270 -tag {notehite flathite} -fill $evv(POINT)
		$pnscreen create line 80  275 280 275 -tag notehite -fill [option get . background {}]
		$pnscreen create line 80  280 280 280 -tag {notehite flathite} -fill $evv(POINT)
		$pnscreen create line 80  285 280 285 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  290 280 290 -tag {notehite flathite} -fill $evv(POINT)
		$pnscreen create line 80  295 280 295 -tag notehite -fill [option get . background {}]
		$pnscreen create line 80  300 280 300 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  305 280 305 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  310 280 305 -tag notehite -fill [option get . background {}]

		#BASS CLEF2
		set bclef2a [$pnscreen create arc 80 250 107 285 -style arc -start 30 -extent 120 -width 1 -outline $evv(POINT)]
		set bclef2b [$pnscreen create arc 25 225 105 295 -style arc -start 5 -extent -75 -width 1 -outline $evv(POINT)]
		set bclef2c [$pnscreen create oval 109 254 111 256 -fill $evv(POINT) -outline $evv(POINT)]
		set bclef2d [$pnscreen create oval 109 264 111 266 -fill $evv(POINT) -outline $evv(POINT)]

		$pnscreen create line 80  390 280 390 -tag notehite -fill [option get . background {}]
		$pnscreen create line 80  395 280 395 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  400 280 400 -tag {notehite flathite} -fill $evv(POINT)
		$pnscreen create line 80  405 280 405 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  410 280 410 -tag notehite -fill $evv(POINT)
		$pnscreen create line 80  415 280 415 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  420 280 420 -tag {notehite flathite} -fill $evv(POINT)
		$pnscreen create line 80  425 280 425 -tag notehite -fill [option get . background {}]
		$pnscreen create line 80  430 280 430 -tag {notehite flathite} -fill $evv(POINT)
		$pnscreen create line 80  435 280 435 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  440 280 440 -tag {notehite flathite} -fill $evv(POINT)
		$pnscreen create line 80  445 280 445 -tag notehite -fill [option get . background {}]
		$pnscreen create line 80  450 280 450 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  455 280 455 -tag {notehite flathite} -fill [option get . background {}]
		$pnscreen create line 80  460 280 460 -tag notehite -fill [option get . background {}]

		set octsdn [$pnscreen create text 50 430 -text "16va down" -font {helvetica 14 bold} -fill $evv(GRAF)]

		#BASS CLEF3
		set bclef3a [$pnscreen create arc 80 400 107 435 -style arc -start 30 -extent 120 -width 1 -outline $evv(POINT)]
		set bclef3b [$pnscreen create arc 25 375 105 445 -style arc -start 5 -extent -75 -width 1 -outline $evv(POINT)]
		set bclef3c [$pnscreen create oval 109 404 111 406 -fill $evv(POINT) -outline $evv(POINT)]
		set bclef3d [$pnscreen create oval 109 414 111 416 -fill $evv(POINT) -outline $evv(POINT)]
	}
	return $pnscreen
}

#----- Draw note on pitchmark graphics display

proc InsertPmarkGrafix {plist} {
	global pmgrafix	pgrafix_tagno maxpcol colmin evv shortwindows

	if {[llength $plist] <= 0} {
		return
	}
	set informed 0
	set maxpcol -1
	catch {unset colmin}
	ClearPmarkGrafix
	set n 0
	set pgrafix_tagno 0
	foreach item $plist {
		set midival [expr round($item)]
		if {$midival > $evv(MAX_TONAL)} {
			if {!$informed} {
				set informed 1
				Inf "Cannot Graphically Represent Midi Vals Above $evv(MAX_TONAL)" 
			}
			incr pgrafix_tagno
			continue
		} elseif {$midival < $evv(MIN_TONAL)} {
			Inf "Cannot Graphically Represent Midi Vals Below $evv(MIN_TONAL)" 
			break
		}
		set col [GetXpos $midival]	;#	Find position of notes (allowing for other notes on staff)
		switch -- $col {
			0 { set xpos1 128 }
			1 { set xpos1 156 }
			2 { set xpos1 184 }
			3 { set xpos1 212 }
			default {
				Inf "Error in display : Unknown column position"
			}
		}
		set xpos2	 [expr $xpos1 + $evv(NOTEWIDTH)]
		set xpos1leg [expr $xpos1 - $evv(LEDGE_OFFSET)]
		set xpos2leg [expr $xpos1leg + $evv(LEDGELEN)]
								;#	draw note heads
#
# NB: MAC "b"-flat-signs y-position are 2 > PC "b" flat positions
#
		if {[info exists shortwindows]} {

			switch -- $midival {	

				108	{
						set noteC4  [$pmgrafix create oval $xpos1 17 $xpos2 23 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 17
						$pmgrafix create line $xpos1leg 20 $xpos2leg 20 -tag ledger0 -tag ledger -fill $evv(POINT)
						$pmgrafix create line $xpos1leg 30 $xpos2leg 30 -tag ledger1 -tag ledger -fill $evv(POINT)
				}
				107	{
						set noteB3  [$pmgrafix create oval $xpos1 22 $xpos2 28 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 22
						catch {$pmgrafix delete ledger1}
						$pmgrafix create line $xpos1leg 30 $xpos2leg 30 -tag ledger1 -tag ledger -fill $evv(POINT)
				}
				106	{
						$pmgrafix create text [expr $xpos1 - 7] 31 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteBb3 [$pmgrafix create oval $xpos1 22 $xpos2 28 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 22
						catch {$pmgrafix delete ledger1}
						$pmgrafix create line $xpos1leg 30 $xpos2leg 30 -tag ledger1 -tag ledger -fill $evv(POINT)
				}
				105	{
						set noteA3  [$pmgrafix create oval $xpos1 27 $xpos2 33 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 27
						catch {$pmgrafix delete ledger1}
						$pmgrafix create line $xpos1leg 30 $xpos2leg 30 -tag ledger1 -tag ledger -fill $evv(POINT)
				}
				104	{
						$pmgrafix create text [expr $xpos1 - 7] 36 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteAb3 [$pmgrafix create oval $xpos1 27 $xpos2 33 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 27
						catch {$pmgrafix delete ledger1}
						$pmgrafix create line $xpos1leg 30 $xpos2leg 30 -tag ledger1 -tag ledger -fill $evv(POINT)
				}
				103	{
						set noteG3  [$pmgrafix create oval $xpos1 32 $xpos2 38 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 32
				}
				102	{
						$pmgrafix create text [expr $xpos1 - 7] 41 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteGb3 [$pmgrafix create oval $xpos1 32 $xpos2 38 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 32
				}
				101	{
						set noteF3  [$pmgrafix create oval $xpos1 37 $xpos2 43 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 37
				}
				100	{
						set noteE3  [$pmgrafix create oval $xpos1 42 $xpos2 48 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 42
				}
				99	{
						$pmgrafix create text [expr $xpos1 - 7] 51 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteEb3 [$pmgrafix create oval $xpos1 42 $xpos2 48 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 42
					}
				98	{
						set noteD3  [$pmgrafix create oval $xpos1 47 $xpos2 53 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 47
				}
				97	{
						$pmgrafix create text [expr $xpos1 - 7] 56 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteDb3 [$pmgrafix create oval $xpos1 47 $xpos2 53 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 47
					}
				96	{
						set noteC3  [$pmgrafix create oval $xpos1 52 $xpos2 58 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 52
				}
				95	{
						set noteB2  [$pmgrafix create oval $xpos1 57 $xpos2 63 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 57
				}
				94	{
						$pmgrafix create text [expr $xpos1 - 7] 66 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteBb2 [$pmgrafix create oval $xpos1 57 $xpos2 63 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 57
					}
				93	{
						set noteA2  [$pmgrafix create oval $xpos1 62 $xpos2 68 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 62
				}
				92	{
						$pmgrafix create text [expr $xpos1 - 7] 71 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteAb2 [$pmgrafix create oval $xpos1 62 $xpos2 68 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 62
				}
				91	{
						set noteG2  [$pmgrafix create oval $xpos1 67 $xpos2 73 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 67
				}
				90	{
						$pmgrafix create text [expr $xpos1 - 7] 76 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteGb2 [$pmgrafix create oval $xpos1 67 $xpos2 73 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 67
					}
				89	{
						set noteF2  [$pmgrafix create oval $xpos1 72 $xpos2 78 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 72
				}
				88	{
						set noteE2  [$pmgrafix create oval $xpos1 77 $xpos2 83 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 77
				}
				87	{	
						$pmgrafix create text [expr $xpos1 - 7] 86 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteEb2 [$pmgrafix create oval $xpos1 77 $xpos2 83 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 77
					}
				86	{
						set noteD2  [$pmgrafix create oval $xpos1 82 $xpos2 88 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 82
				}
				85	{	
						$pmgrafix create text [expr $xpos1 - 7] 91 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteDb2 [$pmgrafix create oval $xpos1 82 $xpos2 88 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 82
					}
				84	{	
						set noteC2  [$pmgrafix create oval $xpos1 137 $xpos2 143 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 137
						$pmgrafix create line $xpos1leg 140 $xpos2leg 140 -tag ledger2 -tag ledger -fill $evv(POINT)
						$pmgrafix create line $xpos1leg 100 $xpos2leg 150 -tag ledger3 -tag ledger -fill $evv(POINT)
				}
				83	{
						set noteB1  [$pmgrafix create oval $xpos1 142 $xpos2 148 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 142
						catch {$pmgrafix delete ledger3}
						$pmgrafix create line $xpos1leg 150 $xpos2leg 150 -tag ledger3 -tag ledger -fill $evv(POINT)
				}
				82	{	
						$pmgrafix create text [expr $xpos1 - 7] 151 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteBb1 [$pmgrafix create oval $xpos1 142 $xpos2 148 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 142
						catch {$pmgrafix delete ledger3}
						$pmgrafix create line $xpos1leg 150 $xpos2leg 150 -tag ledger3 -tag ledger -fill $evv(POINT)
					}
				81	{	
						set noteA1  [$pmgrafix create oval $xpos1 147 $xpos2 153 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 147
						catch {$pmgrafix delete ledger3}
						$pmgrafix create line $xpos1leg 150 $xpos2leg 150 -tag ledger3 -tag ledger -fill $evv(POINT)
				}
				80	{	
						$pmgrafix create text [expr $xpos1 - 7] 156 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteAb1 [$pmgrafix create oval $xpos1 147 $xpos2 153 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 147
						catch {$pmgrafix delete ledger3}
						$pmgrafix create line $xpos1leg 150 $xpos2leg 150 -tag ledger3 -tag ledger -fill $evv(POINT)
					}
				79	{
						set noteG1  [$pmgrafix create oval $xpos1 152 $xpos2 158 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 152
				}
				78	{	
						$pmgrafix create text [expr $xpos1 - 7] 161 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteGb1 [$pmgrafix create oval $xpos1 152 $xpos2 158 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 152
					}
				77	{
						set noteF1  [$pmgrafix create oval $xpos1 157 $xpos2 163 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 157
				}
				76	{
						set noteE1  [$pmgrafix create oval $xpos1 162 $xpos2 168 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 162
				}
				75	{	
						$pmgrafix create text [expr $xpos1 - 7] 171 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteEb1 [$pmgrafix create oval $xpos1 162 $xpos2 168 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 162
					}
				74	{
						set noteD1  [$pmgrafix create oval $xpos1 167 $xpos2 173 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 167
				}
				73	{	
						$pmgrafix create text [expr $xpos1 - 7] 176 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteDb1 [$pmgrafix create oval $xpos1 167 $xpos2 173 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 167
					}
				72	{
						set noteC1  [$pmgrafix create oval $xpos1 172 $xpos2 178 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 172
				}
				71	{
						set noteB0  [$pmgrafix create oval $xpos1 177 $xpos2 183 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 177
				}
				70	{	
						$pmgrafix create text [expr $xpos1 - 7] 186 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteBb0 [$pmgrafix create oval $xpos1 177 $xpos2 183 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 177
					}
				69	{
						set noteA0  [$pmgrafix create oval $xpos1 182 $xpos2 188 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 182
				}
				68	{	
						$pmgrafix create text [expr $xpos1 - 7] 191 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteAb0 [$pmgrafix create oval $xpos1 182 $xpos2 188 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 182
					}
				67	{
						set noteG0  [$pmgrafix create oval $xpos1 187 $xpos2 193 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 187
				}
				66	{	
						$pmgrafix create text [expr $xpos1 - 7] 196 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteGb0 [$pmgrafix create oval $xpos1 187 $xpos2 193 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 187
					}
				65	{
						set noteF0  [$pmgrafix create oval $xpos1 192 $xpos2 198 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 192
				}
				64	{
						set noteE0  [$pmgrafix create oval $xpos1 197 $xpos2 203 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 197
				}
				63	{	
						$pmgrafix create text [expr $xpos1 - 7] 206 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteEb0 [$pmgrafix create oval $xpos1 197 $xpos2 203 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 197
					}
				62	{
						set noteD0  [$pmgrafix create oval $xpos1 202 $xpos2 208 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 202
				}
				61	{	
						$pmgrafix create text [expr $xpos1 - 7] 211 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteDb0 [$pmgrafix create oval $xpos1 202 $xpos2 208 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 202
				}
				60	{
						set noteC0  [$pmgrafix create oval $xpos1 207 $xpos2 213 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 207
						$pmgrafix create line $xpos1leg 210 $xpos2leg 210 -tag ledger3 -tag ledger -fill $evv(POINT)
				}
				59	{
						set noteB-1  [$pmgrafix create oval $xpos1 212 $xpos2 218 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 212
				}
				58	{	
						$pmgrafix create text [expr $xpos1 - 7] 221 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteBb-1 [$pmgrafix create oval $xpos1 212 $xpos2 218 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 212
					}
				57	{
						set noteA-1  [$pmgrafix create oval $xpos1 217 $xpos2 223 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 217
				}
				56	{	
						$pmgrafix create text [expr $xpos1 - 7] 226 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteAb-1 [$pmgrafix create oval $xpos1 217 $xpos2 223 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 217
					}
				55	{
						set noteG-1  [$pmgrafix create oval $xpos1 222 $xpos2 228 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 222
				}
				54	{	
						$pmgrafix create text [expr $xpos1 - 7] 231 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteGb-1 [$pmgrafix create oval $xpos1 222 $xpos2 228 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 222
					}
				53	{
						set noteF-1  [$pmgrafix create oval $xpos1 227 $xpos2 233 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 227
				}
				52	{
						set noteE-1  [$pmgrafix create oval $xpos1 232 $xpos2 238 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 232
				}
				51	{	
						$pmgrafix create text [expr $xpos1 - 7] 241 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteEb-1 [$pmgrafix create oval $xpos1 232 $xpos2 238 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 232
					}
				50	{
						set noteD-1  [$pmgrafix create oval $xpos1 237 $xpos2 243 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 237
				}
				49	{	
						$pmgrafix create text [expr $xpos1 - 7] 246 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteDb-1 [$pmgrafix create oval $xpos1 237 $xpos2 243 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 237
					}
				48	{
						set noteC-1  [$pmgrafix create oval $xpos1 242 $xpos2 248 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 242
				}
				47	{
						set noteB-2  [$pmgrafix create oval $xpos1 247 $xpos2 253 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 247
				}
				46	{	
						$pmgrafix create text [expr $xpos1 - 7] 256 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteBb-2 [$pmgrafix create oval $xpos1 247 $xpos2 253 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 247
					}
				45	{
						set noteA-2  [$pmgrafix create oval $xpos1 252 $xpos2 258 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 252
				}
				44	{	
						$pmgrafix create text [expr $xpos1 - 7] 261 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteAb-2 [$pmgrafix create oval $xpos1 252 $xpos2 258 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 252
					}
				43	{
						set noteG-2  [$pmgrafix create oval $xpos1 257 $xpos2 263 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 257
				}
				42	{	
						$pmgrafix create text [expr $xpos1 - 7] 266 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteGb-2 [$pmgrafix create oval $xpos1 257 $xpos2 263 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 257
					}
				41	{
						set noteF-2  [$pmgrafix create oval $xpos1 262 $xpos2 268 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 262
				}
				40	{
						set noteE-2  [$pmgrafix create oval $xpos1 267 $xpos2 273 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 267
						$pmgrafix create line $xpos1leg 270 $xpos2leg 270 -tag ledger4 -tag ledger -fill $evv(POINT)
				}
				39	{	
						$pmgrafix create text [expr $xpos1 - 7] 276 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteEb-2 [$pmgrafix create oval $xpos1 267 $xpos2 273 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 267
						catch {$pmgrafix delete ledger4}
						$pmgrafix create line $xpos1leg 270 $xpos2leg 270 -tag ledger4 -tag ledger -fill $evv(POINT)
					}
				38	{	
						set noteD-2  [$pmgrafix create oval $xpos1 272 $xpos2 278 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 272
						catch {$pmgrafix delete ledger4}
						$pmgrafix create line $xpos1leg 270 $xpos2leg 270 -tag ledger4 -tag ledger -fill $evv(POINT)
				}
				37	{	
						$pmgrafix create text [expr $xpos1 - 7] 281 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteDb-2 [$pmgrafix create oval $xpos1 272 $xpos2 278 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 272
						catch {$pmgrafix delete ledger4}
						$pmgrafix create line $xpos1leg 270 $xpos2leg 270 -tag ledger4 -tag ledger -fill $evv(POINT)
					}
				36	{	
						set noteC-2  [$pmgrafix create oval $xpos1 277 $xpos2 283 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 277
						catch {$pmgrafix delete ledger4}
						$pmgrafix create line $xpos1leg 270 $xpos2leg 270 -tag ledger4 -tag ledger -fill $evv(POINT)
						$pmgrafix create line $xpos1leg 280 $xpos2leg 280 -tag ledger5 -tag ledger -fill $evv(POINT)
				}
				35	{
						set noteB-3  [$pmgrafix create oval $xpos1 332 $xpos2 338 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 332
				}
				34	{	
						$pmgrafix create text [expr $xpos1 - 7] 341 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteBb-3 [$pmgrafix create oval $xpos1 332 $xpos2 338 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 332
					}
				33	{	
						set noteA-3  [$pmgrafix create oval $xpos1 337 $xpos2 343 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 337
				}
				32	{	
						$pmgrafix create text [expr $xpos1 - 7] 346 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteAb-3 [$pmgrafix create oval $xpos1 337 $xpos2 343 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 337
					}
				31	{
						set noteG-3  [$pmgrafix create oval $xpos1 342 $xpos2 348 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 342
				}
				30	{	
						$pmgrafix create text [expr $xpos1 - 7] 351 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteGb-3 [$pmgrafix create oval $xpos1 342 $xpos2 348 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 342
					}
				29	{
						set noteF-3  [$pmgrafix create oval $xpos1 347 $xpos2 353 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 347
				}
				28	{
						set noteE-3  [$pmgrafix create oval $xpos1 352 $xpos2 358 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 352
				}
				27	{	
						$pmgrafix create text [expr $xpos1 - 7] 361 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteEb-3 [$pmgrafix create oval $xpos1 352 $xpos2 358 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 352
					}
				26	{
						set noteD-3  [$pmgrafix create oval $xpos1 357 $xpos2 363 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 357
				}
				25	{	
						$pmgrafix create text [expr $xpos1 - 7] 366 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteDb-3 [$pmgrafix create oval $xpos1 357 $xpos2 363 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 357
					}
				24	{
						set noteC-3  [$pmgrafix create oval $xpos1 362 $xpos2 368 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 362
				}
				23	{
						set noteB-4  [$pmgrafix create oval $xpos1 367 $xpos2 373 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 367
				}
				22	{	
						$pmgrafix create text [expr $xpos1 - 7] 376 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteBb-4 [$pmgrafix create oval $xpos1 367 $xpos2 373 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 367
					}
				21	{
						set noteA-4  [$pmgrafix create oval $xpos1 372 $xpos2 378 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 372
				}
				20	{	
						$pmgrafix create text [expr $xpos1 - 7] 381 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteAb-4 [$pmgrafix create oval $xpos1 372 $xpos2 378 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 372
					}
				19	{
						set noteG-4  [$pmgrafix create oval $xpos1 377 $xpos2 383 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 377
				}
				18	{	
						$pmgrafix create text [expr $xpos1 - 7] 386 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteGb-4 [$pmgrafix create oval $xpos1 377 $xpos2 383 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 377
					}
				17	{
						set noteF-4  [$pmgrafix create oval $xpos1 382 $xpos2 388 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 382
				}
				16	{	
						set noteE-4  [$pmgrafix create oval $xpos1 387 $xpos2 393 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 387
						$pmgrafix create line $xpos1leg 390 $xpos2leg 390 -tag ledger6 -tag ledger -fill $evv(POINT)
				}
				15	{	
						$pmgrafix create text [expr $xpos1 - 7] 398 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteEb-4 [$pmgrafix create oval $xpos1 387 $xpos2 393 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 387
						catch {$pmgrafix delete ledger6}
						$pmgrafix create line $xpos1leg 390 $xpos2leg 390 -tag ledger6 -tag ledger -fill $evv(POINT)
					}
				14	{	
						set noteD-4  [$pmgrafix create oval $xpos1 392 $xpos2 398 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 392
						catch {$pmgrafix delete ledger6}
						$pmgrafix create line $xpos1leg 390 $xpos2leg 390 -tag ledger6 -tag ledger -fill $evv(POINT)
				 }
				13	{	
						$pmgrafix create text [expr $xpos1 - 7] 401 -anchor sw -text "b" -font general_fnt -tag flats -fill $evv(POINT)
						set noteDb-4 [$pmgrafix create oval $xpos1 392 $xpos2 398 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 392
						catch {$pmgrafix delete ledger6}
						$pmgrafix create line $xpos1leg 390 $xpos2leg 390 -tag ledger6 -tag ledger -fill $evv(POINT)
				}
				12	{	
						set noteC-4  [$pmgrafix create oval $xpos1 397 $xpos2 403 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 397
						catch {$pmgrafix delete ledger6}
						$pmgrafix create line $xpos1leg 390 $xpos2leg 390 -tag ledger6 -tag ledger -fill $evv(POINT)
						$pmgrafix create line $xpos1leg 400 $xpos2leg 400 -tag ledger7 -tag ledger -fill $evv(POINT)
				}
				default {
					Inf "CANNOT GRAPHICALLY REPRESENT MIDIVALS BELOW $evv(MIN_TONAL) or ABOVE $evv(MAX_TONAL)"
				}
			}

		} else {

			switch -- $midival {	

				108	{
						set noteC4  [$pmgrafix create oval $xpos1 17 $xpos2 23 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 17
						$pmgrafix create line $xpos1leg 20 $xpos2leg 20 -tag ledger0 -tag ledger -fill $evv(POINT)
						$pmgrafix create line $xpos1leg 30 $xpos2leg 30 -tag ledger1 -tag ledger -fill $evv(POINT)
				}
				107	{
						set noteB3  [$pmgrafix create oval $xpos1 22 $xpos2 28 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 22
						catch {$pmgrafix delete ledger1}
						$pmgrafix create line $xpos1leg 30 $xpos2leg 30 -tag ledger1 -tag ledger -fill $evv(POINT)
				}
				106	{
						$pmgrafix create text [expr $xpos1 - 7] 31 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteBb3 [$pmgrafix create oval $xpos1 22 $xpos2 28 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 22
						catch {$pmgrafix delete ledger1}
						$pmgrafix create line $xpos1leg 30 $xpos2leg 30 -tag ledger1 -tag ledger -fill $evv(POINT)
				}
				105	{
						set noteA3  [$pmgrafix create oval $xpos1 27 $xpos2 33 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 27
						catch {$pmgrafix delete ledger1}
						$pmgrafix create line $xpos1leg 30 $xpos2leg 30 -tag ledger1 -tag ledger -fill $evv(POINT)
				}
				104	{
						$pmgrafix create text [expr $xpos1 - 7] 36 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteAb3 [$pmgrafix create oval $xpos1 27 $xpos2 33 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 27
						catch {$pmgrafix delete ledger1}
						$pmgrafix create line $xpos1leg 30 $xpos2leg 30 -tag ledger1 -tag ledger -fill $evv(POINT)
				}
				103	{
						set noteG3  [$pmgrafix create oval $xpos1 32 $xpos2 38 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 32
				}
				102	{
						$pmgrafix create text [expr $xpos1 - 7] 41 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteGb3 [$pmgrafix create oval $xpos1 32 $xpos2 38 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 32
				}
				101	{
						set noteF3  [$pmgrafix create oval $xpos1 37 $xpos2 43 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 37
				}
				100	{
						set noteE3  [$pmgrafix create oval $xpos1 42 $xpos2 48 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 42
				}
				99	{
						$pmgrafix create text [expr $xpos1 - 7] 51 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteEb3 [$pmgrafix create oval $xpos1 42 $xpos2 48 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 42
					}
				98	{
						set noteD3  [$pmgrafix create oval $xpos1 47 $xpos2 53 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 47
				}
				97	{
						$pmgrafix create text [expr $xpos1 - 7] 56 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteDb3 [$pmgrafix create oval $xpos1 47 $xpos2 53 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 47
					}
				96	{
						set noteC3  [$pmgrafix create oval $xpos1 52 $xpos2 58 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 52
				}
				95	{
						set noteB2  [$pmgrafix create oval $xpos1 57 $xpos2 63 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 57
				}
				94	{
						$pmgrafix create text [expr $xpos1 - 7] 66 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteBb2 [$pmgrafix create oval $xpos1 57 $xpos2 63 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 57
					}
				93	{
						set noteA2  [$pmgrafix create oval $xpos1 62 $xpos2 68 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 62
				}
				92	{
						$pmgrafix create text [expr $xpos1 - 7] 71 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteAb2 [$pmgrafix create oval $xpos1 62 $xpos2 68 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 62
				}
				91	{
						set noteG2  [$pmgrafix create oval $xpos1 67 $xpos2 73 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 67
				}
				90	{
						$pmgrafix create text [expr $xpos1 - 7] 76 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteGb2 [$pmgrafix create oval $xpos1 67 $xpos2 73 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 67
					}
				89	{
						set noteF2  [$pmgrafix create oval $xpos1 72 $xpos2 78 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 72
				}
				88	{
						set noteE2  [$pmgrafix create oval $xpos1 77 $xpos2 83 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 77
				}
				87	{	
						$pmgrafix create text [expr $xpos1 - 7] 86 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteEb2 [$pmgrafix create oval $xpos1 77 $xpos2 83 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 77
					}
				86	{
						set noteD2  [$pmgrafix create oval $xpos1 82 $xpos2 88 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 82
				}
				85	{	
						$pmgrafix create text [expr $xpos1 - 7] 91 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteDb2 [$pmgrafix create oval $xpos1 82 $xpos2 88 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 82
					}
				84	{	
						set noteC2  [$pmgrafix create oval $xpos1 167 $xpos2 173 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 167
						$pmgrafix create line $xpos1leg 170 $xpos2leg 170 -tag ledger2 -tag ledger -fill $evv(POINT)
						$pmgrafix create line $xpos1leg 180 $xpos2leg 180 -tag ledger3 -tag ledger -fill $evv(POINT)
				}
				83	{
						set noteB1  [$pmgrafix create oval $xpos1 172 $xpos2 178 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 172
						catch {$pmgrafix delete ledger3}
						$pmgrafix create line $xpos1leg 180 $xpos2leg 180 -tag ledger3 -tag ledger -fill $evv(POINT)
				}
				82	{	
						$pmgrafix create text [expr $xpos1 - 7] 181 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteBb1 [$pmgrafix create oval $xpos1 172 $xpos2 178 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 172
						catch {$pmgrafix delete ledger3}
						$pmgrafix create line $xpos1leg 180 $xpos2leg 180 -tag ledger3 -tag ledger -fill $evv(POINT)
					}
				81	{	
						set noteA1  [$pmgrafix create oval $xpos1 177 $xpos2 183 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 177
						catch {$pmgrafix delete ledger3}
						$pmgrafix create line $xpos1leg 180 $xpos2leg 180 -tag ledger3 -tag ledger -fill $evv(POINT)
				}
				80	{	
						$pmgrafix create text [expr $xpos1 - 7] 186 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteAb1 [$pmgrafix create oval $xpos1 177 $xpos2 183 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 177
						catch {$pmgrafix delete ledger3}
						$pmgrafix create line $xpos1leg 180 $xpos2leg 180 -tag ledger3 -tag ledger -fill $evv(POINT)
					}
				79	{
						set noteG1  [$pmgrafix create oval $xpos1 182 $xpos2 188 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 182
				}
				78	{	
						$pmgrafix create text [expr $xpos1 - 7] 191 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteGb1 [$pmgrafix create oval $xpos1 182 $xpos2 188 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 182
					}
				77	{
						set noteF1  [$pmgrafix create oval $xpos1 187 $xpos2 193 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 187
				}
				76	{
						set noteE1  [$pmgrafix create oval $xpos1 192 $xpos2 198 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 192
				}
				75	{	
						$pmgrafix create text [expr $xpos1 - 7] 201 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteEb1 [$pmgrafix create oval $xpos1 192 $xpos2 198 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 192
					}
				74	{
						set noteD1  [$pmgrafix create oval $xpos1 197 $xpos2 203 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 197
				}
				73	{	
						$pmgrafix create text [expr $xpos1 - 7] 206 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteDb1 [$pmgrafix create oval $xpos1 197 $xpos2 203 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 197
					}
				72	{
						set noteC1  [$pmgrafix create oval $xpos1 202 $xpos2 208 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 202
				}
				71	{
						set noteB0  [$pmgrafix create oval $xpos1 207 $xpos2 213 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 207
				}
				70	{	
						$pmgrafix create text [expr $xpos1 - 7] 216 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteBb0 [$pmgrafix create oval $xpos1 207 $xpos2 213 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 207
					}
				69	{
						set noteA0  [$pmgrafix create oval $xpos1 212 $xpos2 218 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 212
				}
				68	{	
						$pmgrafix create text [expr $xpos1 - 7] 221 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteAb0 [$pmgrafix create oval $xpos1 212 $xpos2 218 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 212
					}
				67	{
						set noteG0  [$pmgrafix create oval $xpos1 217 $xpos2 223 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 217
				}
				66	{	
						$pmgrafix create text [expr $xpos1 - 7] 226 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteGb0 [$pmgrafix create oval $xpos1 217 $xpos2 223 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 217
					}
				65	{
						set noteF0  [$pmgrafix create oval $xpos1 222 $xpos2 228 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 222
				}
				64	{
						set noteE0  [$pmgrafix create oval $xpos1 227 $xpos2 233 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 227
				}
				63	{	
						$pmgrafix create text [expr $xpos1 - 7] 236 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteEb0 [$pmgrafix create oval $xpos1 227 $xpos2 233 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 227
					}
				62	{
						set noteD0  [$pmgrafix create oval $xpos1 232 $xpos2 238 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 232
				}
				61	{	
						$pmgrafix create text [expr $xpos1 - 7] 241 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteDb0 [$pmgrafix create oval $xpos1 232 $xpos2 238 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 232
				}
				60	{
						set noteC0  [$pmgrafix create oval $xpos1 237 $xpos2 243 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 237
						$pmgrafix create line $xpos1leg 240 $xpos2leg 240 -tag ledger3 -tag ledger -fill $evv(POINT)
				}
				59	{
						set noteB-1  [$pmgrafix create oval $xpos1 242 $xpos2 248 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 242
				}
				58	{	
						$pmgrafix create text [expr $xpos1 - 7] 251 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteBb-1 [$pmgrafix create oval $xpos1 242 $xpos2 248 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 242
					}
				57	{
						set noteA-1  [$pmgrafix create oval $xpos1 247 $xpos2 253 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 247
				}
				56	{	
						$pmgrafix create text [expr $xpos1 - 7] 256 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteAb-1 [$pmgrafix create oval $xpos1 247 $xpos2 253 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 247
					}
				55	{
						set noteG-1  [$pmgrafix create oval $xpos1 252 $xpos2 258 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 252
				}
				54	{	
						$pmgrafix create text [expr $xpos1 - 7] 261 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteGb-1 [$pmgrafix create oval $xpos1 252 $xpos2 258 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 252
					}
				53	{
						set noteF-1  [$pmgrafix create oval $xpos1 257 $xpos2 263 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 257
				}
				52	{
						set noteE-1  [$pmgrafix create oval $xpos1 262 $xpos2 268 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 262
				}
				51	{	
						$pmgrafix create text [expr $xpos1 - 7] 271 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteEb-1 [$pmgrafix create oval $xpos1 262 $xpos2 268 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 262
					}
				50	{
						set noteD-1  [$pmgrafix create oval $xpos1 267 $xpos2 273 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 267
				}
				49	{	
						$pmgrafix create text [expr $xpos1 - 7] 276 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteDb-1 [$pmgrafix create oval $xpos1 267 $xpos2 273 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 267
					}
				48	{
						set noteC-1  [$pmgrafix create oval $xpos1 272 $xpos2 278 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 272
				}
				47	{
						set noteB-2  [$pmgrafix create oval $xpos1 277 $xpos2 283 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 277
				}
				46	{	
						$pmgrafix create text [expr $xpos1 - 7] 286 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteBb-2 [$pmgrafix create oval $xpos1 277 $xpos2 283 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 277
					}
				45	{
						set noteA-2  [$pmgrafix create oval $xpos1 282 $xpos2 288 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 282
				}
				44	{	
						$pmgrafix create text [expr $xpos1 - 7] 291 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteAb-2 [$pmgrafix create oval $xpos1 282 $xpos2 288 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 282
					}
				43	{
						set noteG-2  [$pmgrafix create oval $xpos1 287 $xpos2 293 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 287
				}
				42	{	
						$pmgrafix create text [expr $xpos1 - 7] 296 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteGb-2 [$pmgrafix create oval $xpos1 287 $xpos2 293 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 287
					}
				41	{
						set noteF-2  [$pmgrafix create oval $xpos1 292 $xpos2 298 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 292
				}
				40	{
						set noteE-2  [$pmgrafix create oval $xpos1 297 $xpos2 303 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 297
						$pmgrafix create line $xpos1leg 300 $xpos2leg 300 -tag ledger4 -tag ledger -fill $evv(POINT)
				}
				39	{	
						$pmgrafix create text [expr $xpos1 - 7] 306 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteEb-2 [$pmgrafix create oval $xpos1 297 $xpos2 303 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 297
						catch {$pmgrafix delete ledger4}
						$pmgrafix create line $xpos1leg 300 $xpos2leg 300 -tag ledger4 -tag ledger -fill $evv(POINT)
					}
				38	{	
						set noteD-2  [$pmgrafix create oval $xpos1 302 $xpos2 308 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 302
						catch {$pmgrafix delete ledger4}
						$pmgrafix create line $xpos1leg 300 $xpos2leg 300 -tag ledger4 -tag ledger -fill $evv(POINT)
				}
				37	{	
						$pmgrafix create text [expr $xpos1 - 7] 311 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteDb-2 [$pmgrafix create oval $xpos1 302 $xpos2 308 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 302
						catch {$pmgrafix delete ledger4}
						$pmgrafix create line $xpos1leg 300 $xpos2leg 300 -tag ledger4 -tag ledger -fill $evv(POINT)
					}
				36	{	
						set noteC-2  [$pmgrafix create oval $xpos1 307 $xpos2 313 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 307
						catch {$pmgrafix delete ledger4}
						$pmgrafix create line $xpos1leg 300 $xpos2leg 300 -tag ledger4 -tag ledger -fill $evv(POINT)
						$pmgrafix create line $xpos1leg 310 $xpos2leg 310 -tag ledger5 -tag ledger -fill $evv(POINT)
				}
				35	{
						set noteB-3  [$pmgrafix create oval $xpos1 392 $xpos2 398 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 392
				}
				34	{	
						$pmgrafix create text [expr $xpos1 - 7] 401 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteBb-3 [$pmgrafix create oval $xpos1 392 $xpos2 398 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 392
					}
				33	{	
						set noteA-3  [$pmgrafix create oval $xpos1 397 $xpos2 403 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 397
				}
				32	{	
						$pmgrafix create text [expr $xpos1 - 7] 406 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteAb-3 [$pmgrafix create oval $xpos1 397 $xpos2 403 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 397
					}
				31	{
						set noteG-3  [$pmgrafix create oval $xpos1 402 $xpos2 408 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 402
				}
				30	{	
						$pmgrafix create text [expr $xpos1 - 7] 411 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteGb-3 [$pmgrafix create oval $xpos1 402 $xpos2 408 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 402
					}
				29	{
						set noteF-3  [$pmgrafix create oval $xpos1 407 $xpos2 413 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 407
				}
				28	{
						set noteE-3  [$pmgrafix create oval $xpos1 412 $xpos2 418 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 412
				}
				27	{	
						$pmgrafix create text [expr $xpos1 - 7] 421 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteEb-3 [$pmgrafix create oval $xpos1 412 $xpos2 418 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 412
					}
				26	{
						set noteD-3  [$pmgrafix create oval $xpos1 417 $xpos2 423 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 417
				}
				25	{	
						$pmgrafix create text [expr $xpos1 - 7] 426 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteDb-3 [$pmgrafix create oval $xpos1 417 $xpos2 423 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 417
					}
				24	{
						set noteC-3  [$pmgrafix create oval $xpos1 422 $xpos2 428 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 422
				}
				23	{
						set noteB-4  [$pmgrafix create oval $xpos1 427 $xpos2 433 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 427
				}
				22	{	
						$pmgrafix create text [expr $xpos1 - 7] 436 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteBb-4 [$pmgrafix create oval $xpos1 427 $xpos2 433 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 427
					}
				21	{
						set noteA-4  [$pmgrafix create oval $xpos1 432 $xpos2 438 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 432
				}
				20	{	
						$pmgrafix create text [expr $xpos1 - 7] 441 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteAb-4 [$pmgrafix create oval $xpos1 432 $xpos2 438 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 432
					}
				19	{
						set noteG-4  [$pmgrafix create oval $xpos1 437 $xpos2 443 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 437
				}
				18	{	
						$pmgrafix create text [expr $xpos1 - 7] 446 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteGb-4 [$pmgrafix create oval $xpos1 437 $xpos2 443 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 437
					}
				17	{
						set noteF-4  [$pmgrafix create oval $xpos1 442 $xpos2 448 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 442
				}
				16	{	
						set noteE-4  [$pmgrafix create oval $xpos1 447 $xpos2 453 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 447
						$pmgrafix create line $xpos1leg 450 $xpos2leg 450 -tag ledger6 -tag ledger -fill $evv(POINT)
				}
				15	{	
						$pmgrafix create text [expr $xpos1 - 7] 456 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteEb-4 [$pmgrafix create oval $xpos1 447 $xpos2 453 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 447
						catch {$pmgrafix delete ledger6}
						$pmgrafix create line $xpos1leg 450 $xpos2leg 450 -tag ledger6 -tag ledger -fill $evv(POINT)
					}
				14	{	
						set noteD-4  [$pmgrafix create oval $xpos1 452 $xpos2 458 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 452
						catch {$pmgrafix delete ledger6}
						$pmgrafix create line $xpos1leg 450 $xpos2leg 450 -tag ledger6 -tag ledger -fill $evv(POINT)
				 }
				13	{	
						$pmgrafix create text [expr $xpos1 - 7] 461 -anchor sw -text "b" -tag flats -font general_fnt -fill $evv(POINT) ;#-font tiny_fnt -tag flats
						set noteDb-4 [$pmgrafix create oval $xpos1 452 $xpos2 458 -fill $evv(POINT) -outline $evv(POINT) -tag notes] 
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 452
						catch {$pmgrafix delete ledger6}
						$pmgrafix create line $xpos1leg 450 $xpos2leg 450 -tag ledger6 -tag ledger -fill $evv(POINT)
				}
				12	{	
						set noteC-4  [$pmgrafix create oval $xpos1 457 $xpos2 463 -fill $evv(POINT) -outline $evv(POINT) -tag notes]
						$pmgrafix addtag mno$pgrafix_tagno closest [expr $xpos1 + $evv(HALF_NOTEWIDTH)] 457
						catch {$pmgrafix delete ledger6}
						$pmgrafix create line $xpos1leg 450 $xpos2leg 450 -tag ledger6 -tag ledger -fill $evv(POINT)
						$pmgrafix create line $xpos1leg 460 $xpos2leg 460 -tag ledger7 -tag ledger -fill $evv(POINT)
				}
				default {
					Inf "Cannot Graphically Represent Midivals Below $evv(MIN_TONAL) or Above $evv(MAX_TONAL)"
				}
			}
		}
		incr pgrafix_tagno
	}
	set n 0								;# Add tags to noteheads, so they select their midival in the adjacent list
	while {$n < $pgrafix_tagno} {				;# When notehead is clicked on.
		$pmgrafix bind mno$n <ButtonRelease-1> {}
		$pmgrafix bind mno$n <ButtonRelease-1> ".pmark.d.d.ll.list selection clear 0 end; .pmark.d.d.ll.list selection set $n"
		incr n
	}
}

#--- Find the horizontal position of the next note, taking into account where previous notes are placed

proc GetXpos {midival} {
	global colmin maxpcol

	set i 0
	set pclass [expr $midival % 12]
	if {($pclass == 1) || ($pclass == 6) || ($pclass == 8)} {	;# Ab, Gb, Db
		set pclass "flat"
	} elseif {($pclass == 4) || ($pclass == 11)} {
		set pclass "EB"
	}
	set n 0
	set col -1
	while {$n <= $maxpcol} {
		set val $colmin($n)
		switch -- $pclass {
			"flat" {
				if {[expr $val - $midival] > 3} {
					set col $n
					break
				}
			}
			"EB" {
				if {[expr $val - $midival] > 1} {
					set col $n
					break
				}
			}
			default {
				if {[expr $val - $midival] > 2} {
					set col $n
					break
				}
			}
		}
		incr n
	}
	if {$col < 0} {
		incr maxpcol
		set col $maxpcol
	}
	set colmin($col) $midival
	return $col
}

#---- Clear all notes from PmarkGrafix display

proc ClearPmarkGrafix {} {
	global pmgrafix
	catch {$pmgrafix delete notes}
	catch {$pmgrafix delete flats}
	catch {$pmgrafix delete ledger}
}

#---- Hilite Pmarks on listing

proc HilitePmarks {ll} {
	global pitchmark pa evv

	if {![info exists pitchmark]} {
		Inf "There Are No Existing Pitch Markers"
		return
	}
	set i 0
	foreach fnam [$ll get 0 end] {
		set ftyp [FindFileType $fnam]
		if {$ftyp == $evv(SNDFILE)} {
			lappend ilist $i
		}
		incr i
	}
	if {![info exists ilist]} {
		Inf "There Are No Soundfiles In This Listing"
		return
	}
	set cnt 0
	$ll selection clear 0 end
	foreach i $ilist {
		set fnam [$ll get $i]
		if {[info exists pitchmark($fnam)]} {
			$ll selection set $i $i
			incr cnt
		}
	}
	if {$cnt == 0} {
		Inf "There Are No Pitch-Marked Files In This Listing"
	}
}

#---- Set pitchmarking program in motion

proc Do_Pitchmark {ll type} {
	global pa pitchmark evv sl_real wl dl chlist hidden_dir only_for_mix

	if {!$sl_real} {
		switch -regexp -- $ll \
			^$wl$ {
				set dum "WORKSPACE"
			} \
			^$dl$ {
				set dum "DIRECTORY LISTING"
			}

		switch -- $type {
			0 { Inf "Create Or Edit A Pitchmark\nFor The File Highlighted\nOn The $dum" }
			1 { Inf "Delete The Pitchmark(s) Of The File(s)\nHighlighted On The $dum" }
		}
		return
	}
	if {![string match $ll $dl] && (($type == $evv(CREATE_PMARK)) || ($type == $evv(DEL_PMARK)))} {
		if {[info exists only_for_mix]} {
			Inf "Duplicate Files On Chosen Files List: Cannot Proceed"
			return
		}
	}
	set is_hidden_dir 0
	if {[string match $ll $dl] && ([string length $hidden_dir] > 0)} {
		set is_hidden_dir 1
	}
	if {[string match $ll $wl]} {
		if {[$ll curselection] < 0} {
			if {[info exists chlist]} {
				foreach item $chlist {
					set k [LstIndx $item $wl]
					if {$k >= 0} {
						lappend klist $k
					}
				}
				if {[info exists klist]} {
					$wl selection clear 0 end
					foreach i $klist {
						$wl selection set $i
					}
				}
			}
		}
	}
	set ilist [$ll curselection]
	if {($type != $evv(CREATE_PMARK)) && ![info exists pitchmark]} {
		Inf "No Pitch Markers Exist"
		return
	}
	if {![info exists ilist] || ([llength $ilist] <= 0)} {
		Inf "No File Selected"
		return
	} elseif {[llength $ilist] > 1} {
		if {$type == $evv(SHOW_PMARK)} {
			catch {destroy .pmark}
		} else {
			Inf "Select A Single File"
		}
		return
	}
	set fnam [$ll get [lindex $ilist 0]]
	if {$is_hidden_dir} {
		set fnam [file join $hidden_dir $fnam]
	}
	set ftyp [FindFileType $fnam]
	if {$ftyp < 0} {
		return
	}
	if {$ftyp != $evv(SNDFILE)} {
		if {$type == $evv(SHOW_PMARK)} {
			catch {destroy .pmark}
		} else {
			Inf "This Is Not A Soundfile"
		}
		return
	} elseif {![info exists pitchmark($fnam)]} {
		if {$type == $evv(SHOW_PMARK)} {
			catch {destroy .pmark}
			return 
		} elseif {$type == $evv(DISPLAY_PMARK)} {
			Inf "No Pitch Marker Exists"
			return
		}
	}
	DoPitchmark $fnam $type
}

#--- Hilite Pitchmakred files in a Background Listing

proc ShowBlistPmarks {y} {
	global bln_var b_l last_bl_name2

	.bln.e.e config -state normal
	set i [.bln.d.d.ll.list nearest $y]
	set nnam [.bln.d.d.ll.list get $i]
	if {[info exists b_l]} {
		.bln.d.d2.ll.list delete 0 end
		foreach index [array names b_l] {
			if {[string match $index $nnam]} {
				foreach item $b_l($nnam) {
					.bln.d.d2.ll.list insert end $item
				}
				break
			}
		}
	}
	set bln_var $nnam
	set last_bl_name2 $bln_var
	.bln.e.e config -state disabled
	HilitePmarks .bln.d.d2.ll.list
}

#--- Does file have a pitchmark

proc HasPmark {fnam} {
	global pa pitchmark evv
	
	set ftyp [FindFileType $fnam]
	if {($ftyp == $evv(SNDFILE)) && [info exists pitchmark($fnam)]} {
		return 1
	}
	return 0
}

#--- Copy an existing pitchmark to a new file

proc CopyPmark {fnam nufnam} {
	global pitchmark
	set pitchmark($nufnam) $pitchmark($fnam)
	StorePitchMarks
}

#--- Delete a pitchmark : use only if you KNOW the file has a pitchmark (and is therefore a sndfile)
#--- otherwise may be deleting pitchmark of sndfile, when a same-named textfile is being deleted (& not the sndfile)


proc DelPmark {fnam} {
	global pitchmark
	catch {unset pitchmark($fnam)}
	StorePitchMarks
}

#--- Change name of pitchmark when file is renamed (automatically overwrites any pmark of any file overwritten by rename)

proc MovePmark {fnam nufnam} {
	global pitchmark
	set pitchmark($nufnam) $pitchmark($fnam)
	catch {unset pitchmark($fnam)}
	StorePitchMarks
}

#--- Change binding on wkspace mouse-click, so Pitchmark of any Soundfile with a pmark, is displayed OVER right of Wkspace

proc SetShowPmarks {} {
	global wl ww showing_pmarks sl_real pitchmark evv

	if {$showing_pmarks} {
		set qqq [bind $wl <ButtonRelease-1>]
		set k [string first "ShowPitchmark" {$qqq}]
		if {$k >= 0} {
			if {$k == 0} {
				set qqq ""
			} else {
				incr k -3
				set qqq [string range $qqq 0 $k]
			}
			bind $wl <ButtonRelease-1> {}
			bind $wl <ButtonRelease-1> $qqq
		}
		set showing_pmarks 0
		catch {destroy .pmark}
		$ww.1.a.endd.l.new.all.menu entryconfigure 28 -label "Display Pitch Marks With File Selection"
	} else {
		if {!$sl_real} {
			Inf "If Pitchmarks Have Been Assigned To Soundfiles\nIt Is Possible To Have These Displayed\nWhenever A Pitchmarked Soundfile Is\nSelected On The Workspace."
			return
		}
		if {![info exists pitchmark]} {
			Inf "No Pitch Marks Exist"
			return
		}
		set qqq [bind $wl <ButtonRelease-1>]
		set k [string first "ShowPitchmark" {$qqq}]
		if {$k < 0} {
			if {[string length $qqq] > 0} {
				append qqq "; "
			}
			append qqq "ShowPitchmark %y"
			bind $wl <ButtonRelease-1> {}
			bind $wl <ButtonRelease-1> $qqq
		}
		set showing_pmarks 1
		$ww.1.a.endd.l.new.all.menu entryconfigure 28 -label "Stop Displaying Pitch Marks"
		set ilist [$wl curselection]
		if {[info exists ilist]} {
			set i [lindex $ilist 0]
			if {$i >= 0} {
				$wl selection clear 0 end
				$wl selection set $i
				Do_Pitchmark $wl $evv(SHOW_PMARK)
			}
		}
	}
}

#--- Display a pitchmark, when sound file selected on workspace

proc ShowPitchmark {y} {
	global wl showing_pmarks pr_pmcomp evv
	if {$showing_pmarks} {
		Do_Pitchmark $wl $evv(SHOW_PMARK)
	}
}

#--- Compare Pitchmarks, and do something as a result

proc ManipulatePmarks {ll sel} {
	global pmarkref pmc pmcq0 pmcq1 pmcq2 CANNOThaveNONREFnotes lastpmc lastpmcq0 lastpmcq1 lastpmcq2 lastchnrn
	global pmarknotes pmarkroots pmclist wl chlist pmcomplist pmarkfnam evv sl_real

	set pmarkfnam ""
	if {!$sl_real && $sel} {
		Inf "Compare The Pitchmark Of The Selected File\nWith All The Pitchmarks Used By Other Files"
		return
	}
	if {$sel} {
		if {[string match $ll $wl]} {
			if {[$ll curselection] < 0} {
				if {[info exists chlist]} {
					foreach item $chlist {
						set k [LstIndx $item $wl]
						if {$k >= 0} {
							lappend klist $k
						}
					}
					if {[info exists klist]} {
						$wl selection clear 0 end
						foreach i $klist {
							$wl selection set $i
						}
					}
				}
			}
		}
		set ilist [$ll curselection]
		if {![info exists ilist] || ([llength $ilist] <= 0)} {
			Inf "No File Selected"
			return
		}
		if {[llength $ilist] > 1} {
			Inf "More Than One File Selected"
			return
		}
		set pmarkfnam [$ll get [lindex $ilist 0]]
		if {![HasPmark $pmarkfnam]} {
			Inf "File Is Not Pitch Marked"
			return
		}
	}
	DoPitchmark $pmarkfnam $evv(SETUP_PMARK)
	if {[string length $pmarkref] <= 0} {
		return
	}

	set f .pmarkcomp
	if [Dlg_Create $f "COMPARE PITCH MARKS" "set pr_pmcomp 0" -width 120 -borderwidth $evv(SBDR)] {
		set zz0 [frame $f.zz0  -bd $evv(SBDR)]
		set zz1 [frame $f.zz1  -bd $evv(SBDR)]
		set z0 [frame $zz0.z0  -bd $evv(SBDR)]
		set z1 [frame $zz0.z1  -bd $evv(SBDR)]
		set a  [frame $z0.a  -bd $evv(SBDR)]
		set a1 [frame $z0.a1 -bd $evv(SBDR)]
		set aa0 [frame $a1.0 -bd $evv(SBDR)]
		set aa1 [frame $a1.1 -bd $evv(SBDR)]
		set b  [frame $z0.b  -bd $evv(SBDR)]
		set b1 [frame $z0.b1 -bd $evv(SBDR)]
		set bb0 [frame $b1.0 -bd $evv(SBDR)]
		set bb1 [frame $b1.1 -bd $evv(SBDR)]
		set c  [frame $z1.c  -bd $evv(SBDR)]
		set c1 [frame $z1.c1 -bd $evv(SBDR)]
		set cc0 [frame $c1.0 -bd $evv(SBDR)]
		set cc1 [frame $c1.1 -bd $evv(SBDR)]
		set d  [frame $z1.d  -bd $evv(SBDR)]
		set d1 [frame $z1.d1 -bd $evv(SBDR)]
		set dd0 [frame $d1.0 -bd $evv(SBDR)]
		set dd1 [frame $d1.1 -bd $evv(SBDR)]
		set e  [frame $zz1.e  -bd $evv(SBDR)]
		set e0  [frame $e.0  -bd $evv(SBDR)]
		set e1  [frame $e.1  -bd $evv(SBDR)]
		set g	[frame $f.g  -bd $evv(SBDR)]
		set h	[frame $f.h  -bd $evv(SBDR)]
		set h1	[frame $h.1  -bd $evv(SBDR)]
		set h2	[frame $h.2  -bd $evv(SBDR)]
		set ii  [frame $h2.ii -bd $evv(SBDR)]
		set j	[frame $h2.j  -bd $evv(SBDR)]
		set j0	[frame $h2.j.0 -bd $evv(SBDR)]
		set j1	[frame $h2.j.1 -bd $evv(SBDR)]
		set j3	[frame $h2.j.3 -bd $evv(SBDR)]
		;# LINES
		set z01 [frame $zz0.z01 -width 1 -bg $evv(POINT)]
		set a01 [frame $z0.a01 -height 1 -bg $evv(POINT)]
		set a02 [frame $z0.a02 -height 1 -bg $evv(POINT)]
		set b01 [frame $z0.b01 -height 1 -bg $evv(POINT)]
		set b02 [frame $z0.b02 -height 1 -bg $evv(POINT)]
		set c01 [frame $z1.c01 -height 1 -bg $evv(POINT)]
		set c02 [frame $z1.c02 -height 1 -bg $evv(POINT)]
		set d01 [frame $z1.d01 -height 1 -bg $evv(POINT)]
		set d02 [frame $z1.d02 -height 1 -bg $evv(POINT)]
		set e01 [frame $zz1.e01 -height 1 -bg $evv(POINT)]
		set e02 [frame $zz1.e02 -height 1 -bg $evv(POINT)]

		button $f.qu -text "Close" -command "set pr_pmcomp 0" -highlightbackground [option get . background {}]
		label $f.la -text "WHAT REFERENCE NOTES ARE FOUND IN THE SEARCHED FILES ??" -fg $evv(SPECIAL)

		radiobutton $a.0 -variable pmc -value 0 -command {DisablePmark a} \
			-text "Exact Note-Matching                                                    "
		radiobutton $b.0 -variable pmc -value 1  -command {DisablePmark b} -justify left \
			-text "Match Lowest Note + 8va Equivalents Of Others"
		radiobutton $c.0 -variable pmc -value 2 \
			-text "8va Equivalence                                                               " -command {DisablePmark c}
		radiobutton $d.0 -variable pmc -value 3 -command {DisablePmark d} -justify left \
			-text "8va Equivalence Except Lowest Note                  "

		radiobutton $aa0.0 -variable pmcq0 -value 0 -text "All Notes" -command {DisablePmark dNdR}
		radiobutton $aa1.1 -variable pmcq0 -value 1 -text "Some Notes Or More" -command {DisablePmark eNdR}
		radiobutton $aa1.2 -variable pmcq0 -value 2 -text "No More Than Some Notes" -command {DisablePmark eNdR}

		radiobutton $bb0.0 -variable pmcq1 -value 0 -text "Single Lowest Note" -command {DisablePmark dR}
		radiobutton $bb0.1 -variable pmcq1 -value 1 -text "Several Lowest Notes" -command {DisablePmark eR}
		radiobutton $bb1.2 -variable pmcq2 -value 0 -text "All Other Notes" -command {DisablePmark dN}
		radiobutton $bb1.3 -variable pmcq2 -value 1 -text "Some Other Notes" -command {DisablePmark eN}

		radiobutton $cc0.0 -variable pmcq0 -value 0 -text "All Notes" -command {DisablePmark dNdR}
		radiobutton $cc1.1 -variable pmcq0 -value 1 -text "Some Notes Or More" -command {DisablePmark eNdR}
		radiobutton $cc1.2 -variable pmcq0 -value 2 -text "No More Than Some Notes" -command {DisablePmark eNdR}

		radiobutton $dd0.0 -variable pmcq1 -value 0 -text "Single Lowest Note" -command {DisablePmark dR}
		radiobutton $dd0.1 -variable pmcq1 -value 1 -text "Several Lowest Notes" -command {DisablePmark eR}
		radiobutton $dd1.2 -variable pmcq2 -value 0 -text "All Other Notes" -command {DisablePmark dN}
		radiobutton $dd1.3 -variable pmcq2 -value 1 -text "Some Other Notes" -command {DisablePmark eN}

		label $e0.0 -text "How Many OTHER NOTES ?" 
		entry $e0.1 -textvariable pmarknotes -width 6
		label $e1.2 -text "How Many LOWER NOTES ?" 
		entry $e1.3 -textvariable pmarkroots -width 6

		set bq [frame $f.bq]
		set bq1 [frame $f.bq1 -height 1 -bg $evv(POINT)]
		label $bq.1 -text "CAN FILES CONTAIN NOTES *NOT* IN THE REFERENCE FILE ??" -fg $evv(SPECIAL)
		radiobutton $bq.2 -variable CANNOThaveNONREFnotes -value 1 -text "NO  "
		radiobutton $bq.3 -variable CANNOThaveNONREFnotes -value 0 -text "YES"
		pack $bq.3 $bq.1 -side left
		pack $bq.2 -side right

		pack $f.qu $f.la -side top -pady 1

		pack $a01 -side top -fill x -expand true 
		pack $a.0 -side left
		pack $a -side top -fill x -expand true
		pack $a02 -side top -fill x -expand true 
		pack $aa0.0 -side top -anchor w  
		pack $aa1.1 $aa1.2 -side top -anchor w  
		pack $aa0 $aa1 -side left -fill x -expand true
		pack $a1 -side top -fill x -expand true

		pack $b01 -side top -fill x -expand true 
		pack $b.0 -side left
		pack $b -side top -fill x -expand true
		pack $b02 -side top -fill x -expand true 
		pack $bb0.0 $bb0.1 -side top -anchor w 
		pack $bb1.2 $bb1.3 -side top -anchor w 
		pack $bb0 $bb1 -side left -fill x -expand true
		pack $b1 -side top -fill x -expand true

		pack $c01 -side top -fill x -expand true 
		pack $c.0 -side left
		pack $c -side top -fill x -expand true
		pack $c02 -side top -fill x -expand true 
		pack $cc0.0 -side top -anchor w 
		pack $cc1.1 $cc1.2 -side top -anchor w 
		pack $cc0 $cc1 -side left -fill x -expand true
		pack $c1 -side top -fill x -expand true

		pack $d01 -side top -fill x -expand true 
		pack $d.0 -side left
		pack $d -side top -fill x -expand true
		pack $d02 -side top -fill x -expand true 
		pack $dd0.0 $dd0.1 -side top -anchor w 
		pack $dd1.2 $dd1.3 -side top -anchor w 
		pack $dd0 $dd1 -side left -fill x -expand true
		pack $d1 -side top -fill x -expand true

		pack $z0 -side left -fill x -expand true
		pack $z01 -side left -fill y -expand true
		pack $z1 -side right -fill x -expand true

		pack $e01 -side top -fill x -expand true 
		pack $e0.0 $e0.1 -side left -padx 2
		pack $e1.3 $e1.2 -side right -padx 2
		pack $e0 -side left -fill x -anchor w -expand true
		pack $e1 -side right -fill x -anchor e -expand true
		pack $e -side top -fill x -expand true
		pack $e02 -side top -fill x -expand true 

		button $g.get -text "Get Matching Files" -command {GetPmatchingFiles} -bg $evv(EMPH) -highlightbackground [option get . background {}]
		pack $g.get -side top

		button $ii.play -text "Play" -command {PlayPmatchingFile} -highlightbackground [option get . background {}]
		button $ii.hili -text "Hilite Matching Files On Listing" -command {set pr_mcomp [HilitePmatchingFiles]} -highlightbackground [option get . background {}]

		pack $ii.play $ii.hili -side top -pady 2

		frame $j0.li -height 1 -bg $evv(POINT)
		pack $j0.li -side top -fill x -expand true -pady 2

		label $j0.gr0 -text "ALL MATCHING FILES" -fg $evv(SPECIAL)
		button $j0.gr1 -text "Grab To Original List" -command {} -bd 2 -width 25 -highlightbackground [option get . background {}]
		button $j0.gr2 -text "Grab To Background List" -command {} -bd 2 -width 25 -highlightbackground [option get . background {}]
		pack $j0.gr0 $j0.gr1 $j0.gr2 -side top -pady 2

		set j2 [frame $j.2 -height 1 -bg $evv(POINT)]

		label $j3.gr0 -text "ALL EXCEPT COMPARISON FILE" -fg $evv(SPECIAL)
		button $j3.gr2 -text "Grab To Background List" -command {} -bd 2 -width 25 -highlightbackground [option get . background {}]
		pack $j3.gr0 $j3.gr2 -side top -pady 2

		set j4 [frame $j.4 -height 1 -bg $evv(POINT)]

		label $j1.gr0 -text "SELECTED MATCHING FILES" -fg $evv(SPECIAL)
		button $j1.gr1 -text "Grab To Original List" -command {} -bd 2 -width 25 -highlightbackground [option get . background {}]
		button $j1.gr2 -text "Grab To Background List" -command {} -bd 2 -width 25 -highlightbackground [option get . background {}]
		pack $j1.gr0 $j1.gr1 $j1.gr2 -side top -pady 2
		
		set pmclist [Scrolled_Listbox $h1.ll -width 60 -height 16 -selectmode single]
		pack $h1.ll -side top -fill both -expand true
		pack $h1 -side left -fill both -expand true
		pack $h2 -side right -fill both -expand true
		pack $zz0 $zz1 -side top -fill x -expand true
		pack $bq -side top
		pack $g -side top -fill x -expand true
		pack $bq1 $ii $h -side top -fill x -expand true
		pack $j0 -side top -fill both -expand true
		pack $j4 -side top -fill x -expand true
		pack $j3 -side top -fill both -expand true -padx 2
		pack $j2 -side top -fill x -expand true -padx 2
		pack $j1 -side top -fill both -expand true
		pack $j -side top -fill both -expand true

		wm resizable $f 1 1
		bind $f <Escape> {set pr_pmcomp 0}
	}
	$f.h.2.j.0.gr1 config -command "GrabPmatchingFiles $ll 0 0 0"
	$f.h.2.j.0.gr2 config -command "GrabPmatchingFiles $ll 1 0 0"
	$f.h.2.j.3.gr2 config -command "GrabPmatchingFiles $ll 1 0 1"
	$f.h.2.j.1.gr1 config -command "GrabPmatchingFiles $ll 0 1 0"
	$f.h.2.j.1.gr2 config -command "GrabPmatchingFiles $ll 1 1 0"
	if {$ll == $wl} {
		$f.h.2.ii.hili config -text "Hilite Matching Files On Workspace" -command {set pr_pmcomp [HilitePmatchingFiles]} -bd 2
	} else {
		$f.h.2.ii.hili config -text "" -command {} -bd 0
	}
	SetupPmarkState
	$pmclist delete 0 end
	raise $f
	update idletasks
	StandardPosition $f
	set pr_pmcomp 0
	set finished 0
	My_Grab 0 $f pr_pmcomp
	while {!$finished} {
		tkwait variable pr_pmcomp
		switch -- $pr_pmcomp {
			1 {

			}
			0 {
				set finished 1
			}
		}
	}
	set lastpmc $pmc   
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- Change response of Pmark Comparison window

proc DisablePmark {str} {
	global pmcq0 pmcq1 pmcq2 lastpmc lastpmcq0 lastpmcq1 lastpmcq2 lastchnrn pmarknotes pmarkroots evv 

	set a	 .pmarkcomp.zz0.z0.a
	set b	 .pmarkcomp.zz0.z0.b
	set c	 .pmarkcomp.zz0.z1.c
	set d	 .pmarkcomp.zz0.z1.d
	set aa0  .pmarkcomp.zz0.z0.a1.0
	set aa1  .pmarkcomp.zz0.z0.a1.1
	set bb0  .pmarkcomp.zz0.z0.b1.0
	set bb1  .pmarkcomp.zz0.z0.b1.1
	set cc0  .pmarkcomp.zz0.z1.c1.0
	set cc1  .pmarkcomp.zz0.z1.c1.1
	set dd0  .pmarkcomp.zz0.z1.d1.0
	set dd1  .pmarkcomp.zz0.z1.d1.1
	set e0   .pmarkcomp.zz1.e.0
	set e1   .pmarkcomp.zz1.e.1
	if {$str == "0"} {
		set pmc -1
		set CANNOThaveNONREFnotes -1
		set pmcq0 0
		set pmcq1 0
		set pmcq2 0
	}

	switch -- $str {
		"0" -
		"a" -
		"b" -
		"c" -
		"d" {
			$e0.0 config -text ""
			set pmarknotes ""
			$e0.1 config -state disabled -bd 0
			$e1.2 config -text ""
			set pmarkroots ""
			$e1.3 config -state disabled -bd 0
			$aa0.0 config -state disabled
			$aa1.1 config -state disabled
			$aa1.2 config -state disabled
			$bb0.0 config -state disabled
			$bb0.1 config -state disabled
			$bb1.2 config -state disabled
			$bb1.3 config -state disabled
			$cc0.0 config -state disabled
			$cc1.1 config -state disabled
			$cc1.2 config -state disabled
			$dd0.0 config -state disabled
			$dd0.1 config -state disabled
			$dd1.2 config -state disabled
			$dd1.3 config -state disabled
			$a config -bg [option get . background {}]
			$b config -bg [option get . background {}]
			$c config -bg [option get . background {}]
			$d config -bg [option get . background {}]
			$a.0 config -bg [option get . background {}]
			$b.0 config -bg [option get . background {}]
			$c.0 config -bg [option get . background {}]
			$d.0 config -bg [option get . background {}]
			set pmcq0 0
			set pmcq1 0
			set pmcq2 0
		}
	}
	switch -- $str {
		"a" {
			$a config -bg $evv(EMPH)
			$a.0 config -bg $evv(EMPH)
			$aa0.0 config -state normal
			$aa1.1 config -state normal
			$aa1.2 config -state normal
		}
		"b" {
			$b config -bg $evv(EMPH)
			$b.0 config -bg $evv(EMPH)
			$bb0.0 config -state normal
			$bb0.1 config -state normal
			$bb1.2 config -state normal
			$bb1.3 config -state normal
		}
		"c" {
			$c config -bg $evv(EMPH)
			$c.0 config -bg $evv(EMPH)
			$cc0.0 config -state normal
			$cc1.1 config -state normal
			$cc1.2 config -state normal
		}
		"d" {
			$d config -bg $evv(EMPH)
			$d.0 config -bg $evv(EMPH)
			$dd0.0 config -state normal
			$dd0.1 config -state normal
			$dd1.2 config -state normal
			$dd1.3 config -state normal
		}
		"dNdR" {
			$e0.0 config -text ""
			set pmarknotes ""
			$e0.1 config -state disabled -bd 0
			$e1.2 config -text ""
			set pmarkroots ""
			$e1.3 config -state disabled -bd 0
		}
		"eNdR" {
			$e0.0 config -text "How Many NOTES ?"
			set pmarknotes ""
			$e0.1 config -state normal -bd 2
			$e1.2 config -text ""
			set pmarkroots ""
			$e1.3 config -state disabled -bd 0
		}
		"dN" {
			$e0.0 config -text ""
			set pmarknotes ""
			$e0.1 config -state disabled -bd 0
		}
		"eN" {
			$e0.0 config -text "How Many OTHER NOTES ?"
			set pmarknotes ""
			$e0.1 config -state normal -bd 2
		}
		"dR" {
			$e1.2 config -text ""
			set pmarkroots ""
			$e1.3 config -state disabled -bd 0
		}
		"eR" {
			$e1.2 config -text "How Many LOWER NOTES ?"
			set pmarkroots ""
			$e1.3 config -state normal -bd 2
		}
	}
}

proc HilitePmatchingFiles {} {
	global pmcomplist wl
	if {![info exists pmcomplist] || ([llength $pmcomplist] <= 0)} {
		Inf "There Are No Matching Files Yet"
		return 2
	}
	set hilist {}
	foreach fnam $pmcomplist {
		set j [LstIndx $fnam $wl]
		if {$j >= 0} {
			lappend hilist $j
		}
	}
	if {[llength $hilist] <= 0} {
		Inf "None Of These Files Are On The Workspace"
		return 2
	}
	$wl selection clear 0 end
	foreach j $hilist {
		$wl selection set $j $j
	}
	return 0
}

proc GrabPmatchingFiles {ll tobkgd selected notorig} {
	global pmcomplist pmclist bln_var b_l wstk pr_pmcomp orig_refmark wl background_listing

	if {![info exists pmcomplist] || ([llength $pmcomplist] <= 0)} {
		Inf "There Are No Matching Files Yet"
		return
	}
	if {$selected} {
		set ilist [$pmclist curselection]
		if {![info exists ilist] || ([llength $ilist] <= 0)} {
			Inf "No Matching Files Have Been Selected"
			return
		}
		foreach i $ilist {
			lappend choslist [$pmclist get $i]
		}
	} else {
		set choslist $pmcomplist
	}
	if {$notorig && ([string length $orig_refmark] > 0)} {
		set j [lsearch $choslist $orig_refmark]
		if {$j >= 0} {
			set choslist [lreplace $choslist $j $j]
			if {[llength $choslist] <= 0} {
				Inf "There Are No Saveable Matching Files"
				return
			}
		}
	}
	if {$tobkgd || ($ll == ".bln.d.d2.ll.list")} {
		foreach fnam $choslist {
			if {[string match $fnam [file tail $fnam]]} {
				set warn 1
			} else {
				lappend getlist $fnam
			}
		}
		if {![info exists getlist]} {
			Inf "All The Found Files Are In The Home Directory, And Cannot Be Placed In A Background Listing"
			return
		}
		if {[info exists warn]} {
			Inf "Some Of The Found Files Are In The Home Directory.\n\Those Files Cannot Be Placed In A Background Listing."
		}
		set choslist $getlist
	}
	set getlist {}
	if {$tobkgd} {
		if {$ll == ".bln.d.d2.ll.list"} {
			set orig_bln_var $bln_var
		}
		GetBLName 0
		if {[string length $bln_var] <= 0} {
			if [info exists orig_bln_var] {
				RestoreBlist $ll $orig_bln_var
				set bln_var $orig_bln_var
			}
			return
		}
		if [info exists b_l($bln_var)] {
			foreach fnam $choslist {
				set j [lsearch $b_l($bln_var) $fnam]
				if {$j < 0} {
					lappend getlist $fnam
				}
			}
		} else {
			set getlist $choslist
		}
	} else {
		foreach fnam $choslist {
			set j [LstIndx $fnam $ll]
			if {$j < 0} {
				lappend getlist $fnam
			}
		}
	}
	if {[llength $getlist] <= 0} {
		Inf "All Of These Files Are Already On The Listing"
		if [info exists orig_bln_var] {
			set bln_var $orig_bln_var
		}
		return
	}
	if {$tobkgd} {
		foreach fnam $getlist {
			lappend b_l($bln_var) $fnam
		}
		SaveBL $background_listing
		Inf "Files Have Been Added To The Background Listing '$bln_var'"
		if [info exists orig_bln_var] {
			RestoreBlist $ll $orig_bln_var
			set bln_var $orig_bln_var
		}
	} else {
		foreach fnam $getlist {
			$ll insert end $fnam
		}
		if {$ll == ".bln.d.d2.ll.list"} {
			foreach fnam $getlist {
				lappend b_l($bln_var) $fnam
			}
			SaveBL $background_listing
		}
		Inf "Files Have Been Transferred To The Listing"
	}
	return
}

#--- Play a sndfile on the pitchmark-matching listing

proc PlayPmatchingFile {} {
	global pmcomplist pmclist bln_var

	if {![info exists pmcomplist] || ([llength $pmcomplist] <= 0)} {
		Inf "There Are No Matching Files Yet"
		return
	}
	set ilist [$pmclist curselection]
	if {![info exists ilist] || ([llength $ilist] <= 0)} {
		Inf "No File Has Been Selected"
		return
	}
	PlaySndfile [$pmclist get [lindex $ilist 0]] 0
}

#--- Get files matching the pmark reference

proc GetPmatchingFiles {} {
	global pmc pmcq0 pmcq1 pmcq2 pitchmark pmarkref CANNOThaveNONREFnotes pmarkroots pmarknotes
	global pmcomplist pmclist pmarkfnam orig_refmark

	set orig_refmark ""
	if {$pmc < 0} {
		Inf "Please Specify The Search Type"
		return
	}
	if {$CANNOThaveNONREFnotes < 0} {
		Inf "Please Specify Whether Files Can Contain Notes *NOT* In The Reference File ?"
		return
	}
	set outlist {}
	set reflen [llength $pmarkref]
	if {$pmcq0 > 0} {
		if {[string length $pmarknotes] <= 0} {
			Inf "No Entry For Number Of Notes"
			return
		}
		if [regexp {[^0-9]} $pmarknotes] {
			Inf "Invalid Entry For Number Of Notes"
			return
		}
	}
	if {$pmcq1 > 0} {
		if {[string length $pmarkroots] <= 0} {
			Inf "No Entry For Number Of Lower Notes"
			return
		}
		if [regexp {[^0-9]} $pmarkroots] {
			Inf "Invalid Entry For Number Of Lower Notes"
			return
		}
	}
	if {$pmcq2 > 0} {
		if {[string length $pmarknotes] <= 0} {
			Inf "No Entry For Number Of Other Notes"
			return
		}
		if [regexp {[^0-9]} $pmarknotes] {
			Inf "Invalid Entry For Number Of Other Notes"
			return
		}
	}
	foreach fnam [array names pitchmark] {
		set flen [llength $pitchmark($fnam)]
		set OK 1
		set cnt 0
		switch -- $pmc {
			0	{			;#	ABS
				switch -- $pmcq0 {
					0	{		;#	ALL
							
						if {$CANNOThaveNONREFnotes} {
							if {$flen != $reflen} {
								continue
							}
							set OK 1
							foreach val2 $pitchmark($fnam) val1 $pmarkref {
								if {$val2 != $val1} {
									set OK 0
									break
								}
							}
						} else {
							if {$flen < $reflen} {
								continue
							}
							set OK 1
							foreach val1 $pmarkref {
								set ismatch 0
								foreach val2 $pitchmark($fnam)  {
									if {$val2 == $val1} {
										set ismatch 1
										break
									}
								}
								if {!$ismatch} {
									set OK 0
									break
								}
							}
						}
					}
					1	{		;#	SOME OR MORE
						set OK 0
						set cnt 0
						if {$flen < $pmarknotes} {
							continue
						}
						foreach val2 $pitchmark($fnam) {
							set ismatch 0
							foreach val1 $pmarkref {
								if {$val2 == $val1} {
									set ismatch 1
									incr cnt
									if {$cnt >= $pmarknotes} {
										set OK 1
									}
									break
								}
							}
							if {$CANNOThaveNONREFnotes} {
								if {!$ismatch} {
									set OK 0
									break
								}
							} elseif {$OK} {
								break
							}
						}
					}
					2	{		;#	SOME OR LESS
						set OK 1
						set cnt 0
						foreach val2 $pitchmark($fnam) {
							set ismatch 0
							foreach val1 $pmarkref {
								if {$val2 == $val1} {
									set ismatch 1	
									incr cnt
									if {$cnt > $pmarknotes} {
										set OK 0
									}
									break
								}
							}
							if {$CANNOThaveNONREFnotes} {
								if {!$ismatch} {
									set OK 0
									break
								}
							} elseif {!$OK} {
								break
							}
						}
					}
				}
			}
			1	{			;#	ABS LOWS + 8va EQUIVS
				switch -- $pmcq1 {
					0	{		;#	SINGLE LOW
						switch -- $pmcq2 {
							0	{		;#	ALL OTHER
								if {$CANNOThaveNONREFnotes} {
									if {$flen != $reflen} {
										continue
									}
								} elseif {$flen < $reflen} {
									continue
								}
								set lo1 [lindex $pmarkref end]
								set lo2 [lindex $pitchmark($fnam) end]
								if {$lo1 != $lo2} {
									continue
								}
								set OK 1
								if {$CANNOThaveNONREFnotes} {
									foreach val2 $pitchmark($fnam) val1 $pmarkref {
										if {[expr $val2 % 12] != [expr $val1 % 12]} {
											set OK 0
											break
										}
									}
								} else {
									foreach val1 $pmarkref {
										set ismatch 0
										foreach val2 $pitchmark($fnam) {
											if {[expr $val2 % 12] == [expr $val1 % 12]} {
												set ismatch 1
												break
											}
										}
										if {!$ismatch} {
											set OK 0
											break
										}
									}
								}
							}
							1	{		;#	SOME OTHER
								if {[expr $pmarknotes + 1] > $reflen} {
									Inf "There Are Insufficient Notes In The Reference Field"
									return
								}
								set len2 $flen
								if {[expr $pmarknotes + 1] > $len2} {
									continue
								}
								set lo1 [lindex $pmarkref end]
								set lo2 [lindex $pitchmark($fnam) end]
								if {$lo1 != $lo2} {
									continue
								}
								set OK 1
								incr len2 -2
								set len1 $reflen
								incr len1 -2
								if {$len1 < 0} {
									if {$pmarknotes > 0} {
										continue
									}
									if {$CANNOThaveNONREFnotes} {
										if {$len2 > $len1} {
											set OK 0
										} else {
											set OK 1
										}
									}
								} elseif {$len2 < 0} {
									if {$pmarknotes > 0} {
										continue
									}
								} else {
									set OK 0
									set cnt 0
									foreach val2 [lrange $pitchmark($fnam) 0 $len2] {
										set ismatch 0
										 foreach val1 [lrange $pmarkref 0 $len1] {
											if {[expr $val2 % 12] == [expr $val1 % 12]} {
												incr cnt
												set ismatch 1
												if {$cnt >= $pmarknotes} {
													set OK 1
												}
												break
											}
										}
										if {$CANNOThaveNONREFnotes} {
											if {!$ismatch} {
												set OK 0
												break
											}
										} elseif {$OK} {
											break
										}
									}
								}
							}
						}
					}
					1	{		;#	MANY LOW
						switch -- $pmcq2 {

							0	{		;#	ALL OTHER

								if {$CANNOThaveNONREFnotes} {
									if {$flen != $reflen} {
										continue
									}
								} elseif {$flen < $reflen} {
									continue
								}
								set len1 [expr $reflen - $pmarkroots]
								set len2 [expr $flen - $pmarkroots]
								if {$len1 < 0} {
									Inf "There Are Insufficient Notes In The Reference Pitch Mark"
									return
								}
								if {$len2 < 0} {
									continue
								}
								set OK 1
								foreach val2 [lrange $pitchmark($fnam) $len2 end] val1 [lrange $pmarkref $len1 end] {
									if {$val2 != $val1} {
										set OK 0
										break
									}
								}
								if {$OK} {
									incr len1 -1
									incr len2 -1
									if {$len1 >= 0} {
										if {$CANNOThaveNONREFnotes} {
											foreach val2 [lrange $pitchmark($fnam) 0 $len1] val1 [lrange $pmarkref 0 $len1] {
												if {[expr $val2 % 12] != [expr $val1 % 12]} {
													set OK 0
													break
												}
											}
										} else {
											foreach val2 [lrange $pmarkref 0 $len1] {
												set ismatch 0
												foreach val1 [lrange $pitchmark($fnam) 0 $len2] {
													if {[expr $val2 % 12] == [expr $val1 % 12]} {
														set ismatch 1
														break
													}
												}
												if {!$ismatch} {
													set OK 0
													break
												}
											}
										}
									}
								}
							}
							1	{		;#	SOME OTHER

								set len1 [expr $reflen - $pmarkroots]
								if {$len1 < 0} {
									Inf "There Are Insufficient Notes In The Reference Field"
									return
								}
								set len2 [expr $flen - $pmarkroots]
								if {$len2 < 0} {
									continue
								}
								set OK 1
								foreach val2 [lrange $pitchmark($fnam) $len2 end] val1 [lrange $pmarkref $len1 end] {
									if {$val2 != $val1} {
										set OK 0
										break
									}
								}
								if {$OK} {
									if {$len1 <= 0} {
										if {$pmarknotes > 0} {
											continue
										}
										if {$CANNOThaveNONREFnotes} {
											if {$len2 > 0} {
												set OK 0
											}
										}
									} elseif {$len2 <= 0} {
										if {$pmarknotes > 0} {
											continue
										}
									} else {
										incr len1 -1
										incr len2 -1
										set OK 0

										foreach val2 [lrange $pitchmark($fnam) 0 $len2] {
											set ismatch 0
											foreach val1 [lrange $pmarkref 0 $len1] {
												if {[expr $val2 % 12] == [expr $val1 % 12]} {
													incr cnt
													set ismatch 1
													if {$cnt >= $pmarknotes} {
														set OK 1
													}
													break
												}
											}
											if {$CANNOThaveNONREFnotes} {
												if {!$ismatch} {
													set OK 0
													break
												}
											} elseif {$OK} {
												break
											}
										}
									}
								}
							}
						}
					}
				}
			}
			2	{			;#	8va EQUIVS
				switch -- $pmcq0 {

					0	{		;#	ALL

						set OK 1
						if {$CANNOThaveNONREFnotes} {
							if {$flen != $reflen} {
								continue
							}
							foreach val2 $pitchmark($fnam) val1 $pmarkref {
								if {[expr $val2 % 12] != [expr $val1 % 12]} {
									set OK 0
									break
								}
							}
						} else {
							if {$flen < $reflen} {
								continue
							}
							foreach val1 $pmarkref {
								set ismatch 0
								foreach val2 $pitchmark($fnam) { 
									if {[expr $val2 % 12] == [expr $val1 % 12]} {
										set ismatch 1
										break
									}
								}
								if {!$ismatch} {
									set OK 0
									break
								}
							}
						}
					}
					1	{		;#	SOME

						set OK 0
						set cnt 0
						if {$flen < $pmarknotes} {
							continue
						}
						foreach val2 $pitchmark($fnam) {
							set ismatch 0
							foreach val1 $pmarkref {
								if {[expr $val2 % 12] == [expr $val1 % 12]} {
									incr cnt
									set ismatch 1
									if {$cnt >= $pmarknotes} {
										set OK 1
									}
									break
								}
							}
							if {$CANNOThaveNONREFnotes} {
								if {!$ismatch} {
									set OK 0
									break
								}
							} elseif {$OK} {
								break
							}
						}
					}
					2	{		;#	SOME OR LESS
						set OK 1
						set cnt 0
						foreach val2 $pitchmark($fnam) {
							set ismatch 0
							foreach val1 $pmarkref {
								if {[expr $val2 % 12] == [expr $val1 % 12]} {
									incr cnt
									set ismatch 1
									if {$cnt > $pmarknotes} {
										set OK 0
										break
									}
								}
							}
							if {$CANNOThaveNONREFnotes} {
								if {!$ismatch} {
									set OK 0
									break
								}
							} elseif {!$OK} {
								break
							}
						}
					}
				}
			}
			3	{				;#	8va EQUIVS EXCEPT LOWEST

				switch -- $pmcq1 {
					0	{		;#	SINGLE LOW
						switch -- $pmcq2 {
							0	{		;#	ALL OTHER
								set len2 $flen
								if {$CANNOThaveNONREFnotes} {
									if {$len2 != $reflen} {
										continue
									}
								} elseif {$len2 < $reflen} {
									continue
								}
								set lo1 [lindex $pmarkref end]
								set lo2 [lindex $pitchmark($fnam) end]
								if {$lo1 == $lo2} {
									continue
								}
								set OK 1
								set len1 $reflen
								incr len1 -2
								if {$len1 >= 0} {
									incr len2 -2
									if {$len2 >= 0} {
										if {$CANNOThaveNONREFnotes} {
											foreach val2 [lrange $pitchmark($fnam) 0 $len2] val1 [lrange $pmarkref 0 $len2] {
												if {[expr $val2 % 12] != [expr $val1 % 12]} {
													set OK 0
													break
												}
											}
										} else {
											foreach val1 [lrange $pmarkref 0 $len1] {
												set ismatch 0
												foreach val2 [lrange $pitchmark($fnam) 0 $len2]  {
													if {[expr $val2 % 12] == [expr $val1 % 12]} {
														set ismatch 1
														break
													}
												}
												if {!$ismatch} {
													set OK 0
													break
												}
											}
										}
									}
								}
							}
							1	{		;#	SOME OTHER
								if {[expr $pmarknotes + 1] > $reflen} {
									Inf "There Are Insufficient Notes In The Reference Field"
									return
								}
								set len2 $flen
								if {[expr $pmarknotes + 1] > $len2} {
									continue
								}
								set len1 $reflen
								set lo1 [lindex $pmarkref end]
								set lo2 [lindex $pitchmark($fnam) end]
								if {$lo1 == $lo2} {
									continue
								}
								set OK 1
								incr len2 -2
								incr len1 -2
								if {$len1 < 0} {
									if {$pmarknotes > 0} {
										continue
									}
									if {$CANNOThaveNONREFnotes} {
										if {$len2 > $len1} {
											set OK 0
										}
									}
								} elseif {$len2 < 0} {
									if {$pmarknotes > 0} {
										continue
									}
								} else {
									set OK 0
									set cnt 0
									foreach val2 [lrange $pitchmark($fnam) 0 $len2] {
										set ismatch 0
										foreach val1 [lrange $pmarkref 0 $len1] {
											if {[expr $val2 % 12] == [expr $val1 % 12]} {
												incr cnt
												set ismatch 1
												if {$cnt >= $pmarknotes} {
													set OK 1
													break
												}
											}
										}
										if {$CANNOThaveNONREFnotes} {
											if {!$ismatch} {
												set OK 0
												break
											}
										} elseif {$OK} {
											break
										}
									}
								}
							}
						}
					}
					1	{		;#	MANY LOW
						switch -- $pmcq2 {
							0	{		;#	ALL OTHER
								set len2 $flen
								if {$CANNOThaveNONREFnotes} {
									if {$len2 != $reflen} {
										continue
									}
								} elseif {$len2 < $reflen} {
									continue
								}
								set len1 [expr $reflen - $pmarkroots]
								if {$len1 < 0} {
									Inf "There Are Insufficient Notes In The Reference Field"
									return
								}
								set len2 [expr $len2 - $pmarkroots]
								set OK 1
								foreach val2 [lrange $pitchmark($fnam) $len2 end] val1 [lrange $pmarkref $len1 end] {
									if {$val2 == $val1} {
										set OK 0
										break
									}
								}
								if {$OK} {
									incr len1 -2
									incr len2 -2
									if {$len1 >= 0} {
										if {$CANNOThaveNONREFnotes} {
											foreach val1 [lrange $pmarkref 0 $len1] val2 [lrange $pitchmark($fnam) 0 $len1] {
												if {[expr $val2 % 12] != [expr $val1 % 12]} {
													set OK 0
													break
												}
											}
										} else {
											foreach val1 [lrange $pmarkref 0 $len1] {
												foreach val2 [lrange $pitchmark($fnam) 0 $len2] {
													if {[expr $val2 % 12] != [expr $val1 % 12]} {
														set OK 0
														break
													}
												}
											}
										}
									}
								}
							}
							1	{		;#	SOME OTHER
								set len1 [expr $reflen - $pmarkroots]
								if {$len1 < 0} {
									Inf "There Are Insufficient Notes In The Reference Field"
									return
								}
								set len2 [expr $flen - $pmarkroots]
								if {$len2 < 0} {
									continue
								}
								set OK 1
								foreach val2 [lrange $pitchmark($fnam) $len2 end] val1 [lrange $pmarkref $len1 end] {
									if {$val2 == $val1} {
										set OK 0
										break
									}
								}
								if {$OK} {
									if {$len1 <= 0} {
										if {$CANNOThaveNONREFnotes} {
											if {$len2 > 0} {
												set OK 0
											}
										} elseif {$pmarknotes > 0} {
											continue
										}
									} elseif {$len2 <= 0} {
										if {$pmarknotes > 0} {
											continue
										}
									} else {
										incr len1 -1
										incr len2 -1
										set OK 0

										foreach val2 [lrange $pitchmark($fnam) 0 $len2] { 
											set ismatch 0
											foreach val1 [lrange $pmarkref 0 $len1] {
												if {[expr $val2 % 12] == [expr $val1 % 12]} {
													incr cnt
													set ismatch 1
													if {$cnt >= $pmarknotes} {
														set OK 1
														break
													}
												}
											}
											if {$CANNOThaveNONREFnotes} {
												if {!$ismatch} {
													set OK 0
													break
												}
											} elseif {$OK} {
												break
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
		if {$OK} {
			lappend outlist $fnam
		}
	}
	if {([string length $pmarkfnam] > 0) && ([llength $outlist] > 0)} {
		set j [lsearch $outlist $pmarkfnam]
		if {$j >= 0} {
			set outlist [lreplace $outlist $j $j]
			set newlist $pmarkfnam
			set outlist [concat $newlist $outlist]
			set orig_refmark $pmarkfnam
		}
	}
	catch {unset pmcomplist}
	$pmclist delete 0 end
	if {[llength $outlist] <= 0} {
		set msg "There Are No Matching Files"
		if {[string length $pmarkfnam] > 0} {
			append msg " FOR $pmarkfnam"
		}
		Inf $msg
	} else {
		foreach fnam $outlist {
			$pmclist insert end $fnam
			lappend pmcomplist $fnam
		}
	}
}

#--- Configure state of Pmark Dilaog switches

proc SetupPmarkState {} {
	global lastpmc pmc pmcq0 pmcq1 pmcq2 2

	if [info exists lastpmc] {
		switch -- $pmc {
			0 {	DisablePmark a }
			1 {	DisablePmark b }
			2 {	DisablePmark c }
			3 {	DisablePmark d }
		}
		switch -- $pmc {
			0 -
			2 {
				switch -- $pmcq0 {
					0 { DisablePmark dNdR }
					1 { DisablePmark eNdR }
					2 { DisablePmark eNdR }
				}
			}
			1 -
			3 {
				switch -- $pmcq1 {
					0 { DisablePmark dR }
					1 { DisablePmark eR }
				}
				switch -- $pmcq2 {
					0 { DisablePmark dN }
					1 { DisablePmark eN }
				}
			}
		}
	} else {
		DisablePmark 0
	}
}

#--- Restore blisting where it's been altered by saving to a different blist!!

proc RestoreBlist {ll fnam} {
	global b_l
	.bln.d.d2.ll.list delete 0 end
	foreach fnam $b_l($fnam) {
		.bln.d.d2.ll.list  insert end $fnam
	}
}


#--- Compare two pitchmarks

proc PmarkCompare {ll} {
	global pitchmark pmarkref pr_pmcomp2 pmtype1 pmtype2 chlist wl pa evv sl_real

	if {!$sl_real} {
		Inf "Compare The Pitchmarks Of The Two Selected Files"
		return
	}
	if {[string match $ll $wl]} {
		if {[$ll curselection] < 0} {
			if {[info exists chlist]} {
				foreach item $chlist {
					set k [LstIndx $item $wl]
					if {$k >= 0} {
						lappend klist $k
					}
				}
				if {[info exists klist]} {
					$wl selection clear 0 end
					foreach i $klist {
						$wl selection set $i
					}
				}
			}
		}
	}
	set ilist [$ll curselection]
	if {![info exists ilist] || ([llength $ilist] <= 0)} {
		Inf "No File Selected"
		return
	}
	if {[llength $ilist] != 2} {
		Inf "Select Two Files"
		return
	}
	set fnam(0) [$ll get [lindex $ilist 0]]
	set fnam(1) [$ll get [lindex $ilist 1]]
	set n 0
	while {$n < 2} {
		if {![HasPmark $fnam($n)]} {
			Inf "File '$fnam($n)' Has No Pitch Mark"
			return
		}
		incr n
	}
	set f .pmarkcomp2
	if [Dlg_Create $f "COMPARISON OF 2 PITCH MARKS" "set pr_pmcomp2 0" -width 80 -borderwidth $evv(SBDR)] {
		label $f.tit -text "TYPE OF COMPARISON"
		set top [frame $f.top -bd $evv(SBDR)]
		button $top.co -text "Do It" -command {set pr_pmcomp2 1} -width 5 -highlightbackground [option get . background {}]
		button $top.qu -text "Close"  -command {set pr_pmcomp2 0} -width 5 -highlightbackground [option get . background {}]
		pack $top.co -side left -pady 2
		pack $top.qu -side right -pady 2
		set a [frame $f.a -bd $evv(SBDR)]
		set a0 [frame $f.a0 -height 1 -bg $evv(POINT)]
		set b [frame $f.b -bd $evv(SBDR)]
		radiobutton $a.0 -variable pmtype1 -value 0 -text "8va Equivalence"
		radiobutton $a.1 -variable pmtype1 -value 1 -text "Absolute Values"
		pack $a.1 -side left -padx 1
		pack $a.0 -side right -padx 1
		radiobutton $b.0 -variable pmtype2 -value 0 -text "(A=B)  Is 1st Mark Equal To To 2nd Mark ?"
		radiobutton $b.1 -variable pmtype2 -value 1 -text "(A>B)  Does 1st Mark Completely Contains 2nd Mark ?"
		radiobutton $b.2 -variable pmtype2 -value 2 -text "(A<B)  Is 1st Mark Completely Contained By 2nd Mark ?"
		radiobutton $b.3 -variable pmtype2 -value 3 -text "(A+B)  What Is Combination Of 1st Mark and 2nd Mark ?"
		radiobutton $b.6 -variable pmtype2 -value 6 -text "(AuB)  Which Notes Are Common To Both Marks ?"
		radiobutton $b.4 -variable pmtype2 -value 4 -text "(A-B)  Which Notes Are Unique To 1st Mark ?"
		radiobutton $b.5 -variable pmtype2 -value 5 -text "(B-A)  Which Notes Are Unique To 2nd Mark ?"
		radiobutton $b.7 -variable pmtype2 -value 7 -text "(Lo=)  Do Marks Have Same Bottom Note ?"
		radiobutton $b.8 -variable pmtype2 -value 8 -text "(Hi=)  Do Marks Have Same Top Note ?"

		pack $b.0 $b.1 $b.2 $b.3 $b.6 $b.4 $b.5 $b.7 $b.8 -side top -anchor w -pady 2

		pack $f.tit -side top -pady 2
		pack $f.top -side top -fill x -expand true
		pack $a -side top -fill x -expand true
		pack $a0 -side top -fill x -expand true
		pack $b -side top -fill x -expand true
		wm resizable $f 1 1
		bind $f <Escape> {set pr_pmcomp2 0}
		bind $f <Return> {set pr_pmcomp2 1}
	}
	raise $f
	update idletasks
	StandardPosition $f
	set pr_pmcomp2 0
	set finished 0
	set pmtype1 -1
	set pmtype2 -2
	My_Grab 0 $f pr_pmcomp2 
	while {!$finished}  {
		tkwait variable pr_pmcomp2 
		catch {unset tempmark}
		if {$pr_pmcomp2} {
			switch -- $pmtype1 {
				0 {
					foreach val $pitchmark($fnam(0)) {
						set valoct [expr ($val % 12) + 60]
						if {[info exists tempmark(0)]} {
							if {[lsearch $tempmark(0) $valoct] < 0} {
								lappend tempmark(0) $valoct
							}
						} else {
							lappend tempmark(0) $valoct
						}
					}
					foreach val $pitchmark($fnam(1)) {
						set valoct [expr ($val % 12) + 60]
						if {[info exists tempmark(1)]} {
							if {[lsearch $tempmark(1) $valoct] < 0} {
								lappend tempmark(1) $valoct
							}
						} else {
							lappend tempmark(1) $valoct
						}
					}
				}
				1 {
					set tempmark(0) $pitchmark($fnam(0))
					set tempmark(1) $pitchmark($fnam(1))
				}
				default {
					Inf "Absolute Values Or 8va Equivalence?"
					continue
				}
			}
			switch -- $pmtype2 {
				0 {
					if {[llength $tempmark(0)] != [llength $tempmark(1)]} {
						Inf "NO"
						continue
					}
					set OK 1
					foreach val1 $tempmark(0) val2 $tempmark(1) {
						if {$val1 != $val2} {
							Inf "NO"
							set OK 0
							break
						}
					}
					if {$OK} {
						Inf "YES"
					}
				}
				1 {
					if {[llength $tempmark(0)] > [llength $tempmark(1)]} {
						Inf "NO"
						continue
					}
					set OK 1
					foreach val1 $tempmark(0) {
						set ismatch 0
						foreach val2 $tempmark(1) {
							if {$val1 == $val2} {
								set ismatch 1
								break
							}
						}
						if {!$ismatch} {
							set OK 0
							Inf "NO"
							break
						}
					}
					if {$OK} {
						Inf "YES"
					}
				}
				2 {
					if {[llength $tempmark(1)] > [llength $tempmark(0)]} {
						Inf "NO"
						continue
					}
					set OK 1
					foreach val1 $tempmark(1) {
						set ismatch 0
						foreach val2 $tempmark(0) {
							if {$val1 == $val2} {
								set ismatch 1
								break
							}
						}
						if {!$ismatch} {
							set OK 0
							Inf "NO"
							break
						}
					}
					if {$OK} {
						Inf "YES"
					}
				}
				3 {
					catch {unset extras}
					foreach val1 $tempmark(0) {
						if {[lsearch $tempmark(1) $val1] < 0} {
							lappend extras $val1
						}
					}
					if {[info exists extras]} {
						set tempmark(1) [lsort -real -decreasing [concat $tempmark(1) $extras]]
					}
					set pmarkref $tempmark(1)
					DoPitchmark "" $evv(COMPARE_PMARK)
					set pmarkref ""
				}
				4 {
					set i 0
					catch {unset extras}
					foreach val1 $tempmark(0) {
						if {[lsearch $tempmark(1) $val1] >= 0} {
							lappend extras $i
						}
						incr i
					}
					if {[info exists extras]} {
						set extras [lsort -integer -decreasing $extras]
						foreach i $extras {
							set tempmark(0) [lreplace $tempmark(0) $i $i]
						}
					}
					if {[llength $tempmark(0)] <= 0} {
						Inf "No Notes Are Unique To The 1st Mark"
					} else {
						set pmarkref $tempmark(0)
						DoPitchmark "" $evv(COMPARE_PMARK)
						set pmarkref ""
					}
				}
				5 {
					set i 0
					catch {unset extras}
					foreach val1 $tempmark(1) {
						if {[lsearch $tempmark(0) $val1] >= 0} {
							lappend extras $i
						}
						incr i
					}
					if {[info exists extras]} {
						set extras [lsort -integer -decreasing $extras]
						foreach i $extras {
							set tempmark(1) [lreplace $tempmark(1) $i $i]
						}
					}
					if {[llength $tempmark(1)] <= 0} {
						Inf "No Notes Are Unique To The 2nd Mark"
					} else {
						set pmarkref $tempmark(1)
						DoPitchmark "" $evv(COMPARE_PMARK)
						set pmarkref ""
					}
				}
				6 {
					catch {unset extras}
					foreach val1 $tempmark(1) {
						if {[lsearch $tempmark(0) $val1] >= 0} {
							lappend extras $val1
						}
					}
					if {![info exists extras]} {
						Inf "No Notes Are Common To Both Marks"
					} else {
						set pmarkref $extras
						DoPitchmark "" $evv(COMPARE_PMARK)
						set pmarkref ""
					}
				}
				7 {
					set x(0) [lindex $pitchmark($fnam(0)) end]
					set x(1) [lindex $pitchmark($fnam(1)) end]
					if {(($pmtype1 == 0) && ([expr $x(0) % 12] == [expr $x(1) % 12])) \
					|| (($pmtype1 == 1) && ($x(0) == $x(1)))} {
						Inf "YES"
					} else {
						Inf "NO"
					}
				}
				8 {
					set x(0) [lindex $pitchmark($fnam(0)) 0]
					set x(1) [lindex $pitchmark($fnam(1)) 0]
					if {(($pmtype1 == 0) && ([expr $x(0) % 12] == [expr $x(1) % 12])) \
					|| (($pmtype1 == 1) && ($x(0) == $x(1)))} {
						Inf "YES"
					} else {
						Inf "NO"
					}
				}
				default {
					Inf "What Type Of Comparison?"
				}
			}
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc DisplayPmark {ll} {
	global sl_real evv

	if {!$sl_real} {
		Inf "If A Pitchmark Has Been Assigned To A Soundfile,\nIts Pitchmark Can Be Displayed Here"
		return
	}
	set ilist [$ll curselection] 
	if {![info exists ilist] || ([llength $ilist] <= 0)} {
		Inf "No File Selected"
		return
	}
	if {[llength $ilist] > 1} {
		Inf "Select just one file"
		return
	}
	set fnam [$ll get [lindex $ilist 0]]
	if {![IsSound $fnam]} {
		Inf "'$fnam' Is Not A Soundfile"
		return
	}
	if {![HasPmark $fnam]} {
		Inf "'$fnam' Has No Pitch Mark"
		return
	}
	DoPitchmark $fnam $evv(DISPLAY_PMARK)
}

#--- Test if a file (not necessarily on the Workspace) is a soundfile

proc IsSound {fnam} {
	global pa evv

	set ftyp [FindFileType $fnam]
	if {$ftyp == $evv(SNDFILE)} {
		return 1
	}
	return 0
}

proc TellA {} {
	Inf "This Button Plays Concert A"
	return
}

#--- Does file have a motif mark

proc HasMmark {fnam} {
	global pa mtfmark evv
	
	set ftyp [FindFileType $fnam]
	if {($ftyp == $evv(SNDFILE)) && [info exists mtfmark($fnam)]} {
		return 1
	}
	return 0
}

#--- Copy an existing motif mark to a new file

proc CopyMmark {fnam nufnam} {
	global mtfmark
	set mtfmark($nufnam) $mtfmark($fnam)
	StoreMtfMarks
}

#--- Delete a motif mark : use only if you KNOW the file has a motif mark (and is therefore a sndfile)
#--- otherwise may be deleting motif mark of sndfile, when a same-named textfile is being deleted (& not the sndfile)

proc DelMmark {fnam} {
	global mtfmark
	catch {unset mtfmark($fnam)}
	StoreMtfMarks
}

#----- Load motif marks used in last session(s)

proc LoadMtfMarks {} {
	global mtfmark evv

	set pfnam [file join $evv(URES_DIR) $evv(MTFMARK)$evv(CDP_EXT)]
	if {[file exists $pfnam]} {
		if [catch {open $pfnam "r"} fId] {
			Inf "Failed To Open File '$pfnam' To Find Existing Motif Markers"
			return
		}
		while {[gets $fId line] >= 0} {
			set line [string trim $line]
			if {[string length $line] > 0} {
				set line [split $line]
				set fnam [string trim [lindex $line 0]]
				if {([string length $fnam] < 0) || ![file exists $fnam]} {
					continue
				}
				if {![file exists $fnam]} {
					continue
				}
				set OK 1
				foreach item [lrange $line 1 end] {
					if {([string length [string trim $item]] <= 0) || [regexp {[^0-9]} $item]} {
						Inf "Spurious Data In Motif Marks File, For Soundfile '$fnam'\n\nFix In File '$pfnam' Before Proceeding"
						break
					}
					lappend mtfmark($fnam) $item
				}
			}
		}
	}
	catch {close $fId}
}

#--- Save motif marks to disk

proc StoreMtfMarks {} {
	global mtfmark evv

	set mm_file [file join $evv(URES_DIR) $evv(MTFMARK)$evv(CDP_EXT)]
	if {[info exists mtfmark]} {	
		foreach fnam [array names mtfmark] {
			if {![file exists $fnam]} {
				catch {unset mtfmark($fnam)}
			}
		}
	}
	if {![info exists mtfmark]} {	
		if {[file exists $mm_file]} {
			catch {file delete $mm_file}
		}
		return
	}
	if [catch {open $evv(DFLT_TMPFNAME)$evv(CDP_EXT) w} fId] {
		Inf "Cannot Open Temporary File To Backup Motif Marks"
		return
	} else {
		foreach fnam [array names mtfmark] {
			catch {unset line}
			lappend line $fnam
			foreach item $mtfmark($fnam) {
				lappend line $item
			}
			puts $fId $line
		}
		close $fId
	}
	if [file exists $mm_file] {
		if [catch {file delete -force $mm_file} zorg] {
			Inf "Cannot Delete Existing Motif Markers File, To Write Current Motif Markers.\n\ndata Is In File $evv(DFLT_TMPFNAME)$evv(CDP_EXT)\n\nTo Save This Data\nRename This File (outside The CDP) As '$mm_file' BEFORE PROCEEDING"
			return
		}
	}
	if [catch {file rename -force $evv(DFLT_TMPFNAME)$evv(CDP_EXT) $mm_file}] {
		ErrShow "Failed To Save Motif Markers Data\n\ndata Is In File $evv(DFLT_TMPFNAME)$evv(CDP_EXT)\n\nTo Save This Data\nRename This File (outside The CDP) As $mm_file BEFORE PROCEEDING"
	}
}

#--- Change name of motifmark when file is renamed (automatically overwrites any pmark of any file overwritten by rename)

proc MoveMmark {fnam nufnam} {
	global mtfmark
	set mtfmark($nufnam) $mtfmark($fnam)
	catch {unset mtfmark($fnam)}
	StoreMtfMarks
}

#--- Display the combined Harmonic Field from several pitchmarks

proc CombinePmarks {} {
	global wl chlist pitchmark pmgrafix pa evv
	if {![info exists pitchmark]} {
		Inf "No Pitchmarks Exist"
		return
	}
	if {[info exists chlist] && ([llength $chlist] >= 2)} {
		set fnams $chlist
		foreach fnam $chlist {
			if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ![info exists pitchmark($fnam)]} {
				catch {unset harm}
				break
			}
			lappend harm $pitchmark($fnam)
		}
	}
	if {![info exists harm]} {
		set ilist [$wl curselection]
		if {![info exists ilist] || ([llength $ilist] < 2)} {
			Inf "Select At Least 2 Soundfiles Which Have Pitchmarks"
			return
		}
		foreach i $ilist {
			lappend fnams [$wl get $i]
		}
		foreach fnam $fnams {
			if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ![info exists pitchmark($fnam)]} {
				Inf "Select At Least 2 Soundfiles Which Have Pitchmarks"
				return
			}
			lappend harm $pitchmark($fnam)
		}
	}
	set f .pmark_combo
	if [Dlg_Create $f "COMBINED PITCH MARKS" "set pr_pmcombo 0" -width 120 -borderwidth $evv(SBDR)] {
		set b [frame $f.b -borderwidth $evv(SBDR)]
		set d [frame $f.d -borderwidth $evv(SBDR)]
		button $b.q -text "OK" -command "set pr_pmcombo 0"
		pack $b.q -side left -padx 2
		set dd [frame $d.d -borderwidth $evv(SBDR)]
		set dd2 [frame $d.d2 -borderwidth $evv(SBDR)]
		label $dd.l -text "PITCH MARK"
		label $dd2.l -text ""
		Scrolled_Listbox $dd.ll -width 20 -height 20 -selectmode single
		set pmgrafix [EstablishPmarkDisplay $d.d2]
		pack $dd.l $dd.ll -side top -pady 1
		pack $dd2.l $pmgrafix -side top -pady 1
		pack $dd $dd2 -side left -fill x -expand true
		pack $b -side top -fill x -expand true -pady 1
		pack $d -side top -fill x -expand true -pady 1
		wm resizable $f 0 0
		bind $f <Return> {set pr_pmcombo 0}
		bind $f <Escape> {set pr_pmcombo 0}
	}
	ClearPmarkGrafix
	set thisplist {}
	$f.d.d.ll.list delete 0 end
	foreach item $harm {
		$f.d.d.ll.list insert end $item
		lappend thisplist $item
	}
	set len [llength $thisplist]	;#	Eliminate duplicates
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set m $n
		incr m 
		while {$m < $len} {
			if {[lindex $thisplist $n] == [lindex $thisplist $m]} {
				set thisplist [lreplace $thisplist $m $m]
				incr len -1
				incr len_less_one -1
			} else {
				incr m
			}
		}
		incr n
	}
	set len [llength $thisplist]	;#	Sort list into descending order
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set p_n [lindex $thisplist $n]
		set m $n
		incr m 
		while {$m < $len} {
			set p_m [lindex $thisplist $m]
			if {$p_n < $p_m} {
				set thisplist [lreplace $thisplist $n $n $p_m]
				set thisplist [lreplace $thisplist $m $m $p_n]
				set p_n $p_m
			}
			incr m
		}
		incr n
	}


	InsertPmarkGrafix $thisplist
	raise $f
	update idletasks
	StandardPosition $f
	set pr_pmcombo 0
	set finished 0
	My_Grab 0 $f pr_pmcombo
	tkwait variable pr_pmcombo
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

#--- Sort pitchmarked files into descending pitch order

proc SortOnPmarks {} {
	global wl chlist pitchmark pa evv
	if {![info exists pitchmark]} {
		Inf "No Pitchmarks Exist"
		return
	}
	if {[info exists chlist] && ([llength $chlist] >= 2)} {
		set fnams $chlist
		foreach fnam $chlist {
			if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ![info exists pitchmark($fnam)]} {
				catch {unset harm}
				break
			}
			lappend ilist [LstIndx $fnam $wl]
			lappend harm $pitchmark($fnam)
		}
	}
	if {![info exists harm]} {
		set ilist [$wl curselection]
		if {![info exists ilist] || ([llength $ilist] < 2)} {
			Inf "Select Soundfiles Which Have Pitchmarks"
			return
		}
		foreach i $ilist {
			lappend fnams [$wl get $i]
		}
		foreach fnam $fnams {
			if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ![info exists pitchmark($fnam)]} {
				Inf "Select Soundfiles Which Have Pitchmarks"
				return
			}
			lappend harm $pitchmark($fnam)
		}
	}
	set len [llength $harm]
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set p_n [lindex $harm $n]
		set f_n [lindex $fnams $n]
		set m $n
		incr m
		while {$m < $len} {
			set p_m [lindex $harm $m]
			set f_m [lindex $fnams $m]
			if {$p_n > $p_m} {				;#	Sort into ascending order
				set harm [lreplace $harm $n $n $p_m]
				set harm [lreplace $harm $m $m $p_n]
				set fnams [lreplace $fnams $n $n $f_m]
				set fnams [lreplace $fnams $m $m $f_n]
				set p_n $p_m
				set f_n $f_m
			}
			incr m
		}
		incr n
	}
	foreach i $ilist fnam $fnams {
		$wl delete $i
		$wl insert $i $fnam
	}
	$wl selection clear 0 end
	foreach i $ilist {
		$wl selection set $i
	}
}

#--- Hilight all chosen workspace files which lie in specified Harmonic Set

proc InSetPmarks {in_hf} {
	global wl chlist pitchmark pa evv pm_numidilist pr_pm_inset pmgrafix total_wksp_cnt
	if {![info exists pitchmark]} {
		Inf "No Pitchmarks Exist"
		return
	}
	if {[info exists chlist] && ([llength $chlist] >= 2)} {
		set fnams $chlist
		foreach fnam $chlist {
			if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ![info exists pitchmark($fnam)]} {
				catch {unset harm}
				break
			}
			lappend harm $pitchmark($fnam)
		}
	}
	if {![info exists harm]} {
		set ilist [$wl curselection]
		if {![info exists ilist] || ([llength $ilist] < 2)} {
			Inf "Select Soundfiles Which Have Pitchmarks"
			return
		}
		foreach i $ilist {
			lappend fnams [$wl get $i]
		}
		foreach fnam $fnams {
			if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ![info exists pitchmark($fnam)]} {
				Inf "Select Soundfiles Which Have Pitchmarks"
				return
			}
			lappend harm $pitchmark($fnam)
		}
	}
	set f .pmark
	catch {	destroy $f}
	if [Dlg_Create $f "SPECIFY HARMONIC SET" "set pr_pm_inset 0" -width 120 -borderwidth $evv(SBDR)] {
		set b [frame $f.b -borderwidth $evv(SBDR)]
		set b0 [frame $f.b0 -height 1 -bg $evv(POINT)]
		set d [frame $f.d -borderwidth $evv(SBDR)]
		button $b.k -text "Show Files" -command "set pr_pm_inset 1" -bg $evv(EMPH)
		button $b.d -text "Clear" -command "set pr_pm_inset 2" -bd 2
		button $b.q -text "Quit" -command "set pr_pm_inset 0"
		pack $b.k -side left
		pack $b.q $b.d -side right -padx 4
		set dd [frame $d.d -borderwidth $evv(SBDR)]
		set dd2 [frame $d.d2 -borderwidth $evv(SBDR)]
		label $dd.l -text "PITCH MARK"
		label $dd2.l -text ""
		Scrolled_Listbox $dd.ll -width 20 -height 20 -selectmode single
		set pmgrafix [EstablishPmarkDisplay $d.d2]
		pack $dd.l $dd.ll -side top -pady 1
		pack $dd2.l $pmgrafix -side top -pady 1
		pack $dd $dd2 -side left -fill x -expand true
		pack $b -side top -fill x -expand true -pady 1
		pack $b0 -side top -fill x -expand true -pady 4
		pack $d -side top -fill x -expand true -pady 1
		wm resizable $f 0 0
		bind $pmgrafix <ButtonRelease-1> {PgrafixAddPitch $pmgrafix %x %y 0}
		bind $pmgrafix <Shift-ButtonRelease-1> {PgrafixAddPitch $pmgrafix %x %y 1}
		bind $pmgrafix <Control-ButtonRelease-1> {PgrafixDelPitch $pmgrafix %x %y}
		bind $f <Return> {set pr_pm_inset 1}
		bind $f <Escape> {set pr_pm_inset 0}
		catch {unset pm_numidilist}
	}
	if {$in_hf} {
		wm title $f "Specify Harmonic Field"
	} else {
		wm title $f "Specify Harmonic Set"
	}
	ClearPmarkGrafix
	update idletasks
	StandardPosition $f
	set pr_pm_inset 0
	set finished 0
	My_Grab 0 $f pr_pm_inset $f.d.d.ll.list
	while {!$finished} {
		tkwait variable pr_pm_inset
		switch -- $pr_pm_inset {
			1 {
				if {![info exists pm_numidilist] || ([llength $pm_numidilist] <= 0)} {
					if {$in_hf} {
						Inf "No Harmonic Field Specified"
					} else {
						Inf "No Harmonic Set Specified"
					}
					continue
				}
				if {$in_hf} {
					set checklist {}
					foreach pp $pm_numidilist {
						if {[lsearch $checklist $pp] < 0} {
							lappend checklist $pp
						}
						set origpp $pp
						incr pp -12
						while {$pp >= 0} {
							if {[lsearch $checklist $pp] < 0} {
								lappend checklist $pp
							}
							incr pp -12
						}
						set pp $origpp
						incr pp 12
						while {$pp <= 127} {
							if {[lsearch $checklist $pp] < 0} {
								lappend checklist $pp
							}
							incr pp 12
						}
					}
				} else {
					set checklist $pm_numidilist
				}
				catch {unset nufnams}
				foreach fnam $fnams {
					if {[lsearch $checklist $pitchmark($fnam)] >= 0} {
						lappend nufnams $fnam
					}
				}
				if {![info exists nufnams]} {
					if {$in_hf} {
						Inf "None Of These Files Lie In The Specified Harmonic Field"
					} else {
						Inf "None Of These Files Lie In The Specified Harmonic Set"
					}
					continue
				} else {
					set imin $total_wksp_cnt
					$wl selection clear 0 end
					foreach nufnam $nufnams {
						set i [LstIndx $nufnam $wl]
						$wl selection set $i
						if {$i < $imin} {
							set imin $i
						}
					}
					if {[expr $imin + [llength $nufnams]] >= 24} {
						$wl yview moveto [expr double($imin)/double($total_wksp_cnt)]
					}
				}
				set finished 1
			}
			2 {
				catch {unset pm_numidilist}
				$f.d.d.ll.list delete 0 end
				ClearPmarkGrafix
			} 
			0	{
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}
