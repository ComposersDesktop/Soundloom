#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD June 30 2013
# ... fixup button rectangles

#------ Save List of Private Directories to File

proc SavePrivateDirs {} {

	global private_directories evv

	set pd_file [file join $evv(URES_DIR) $evv(PRIVATE)$evv(CDP_EXT)]
	if {![info exists private_directories] || ([llength $private_directories] <= 0)} {
		if [catch {file delete $pd_file} zorg] {
			Inf "Cannot Delete The Old Existing Private Directories File '$pd_file'\n\nYou Must Delete It Outside The CDP"
		}
		return
	}
	set fnam [file join $evv(URES_DIR) $evv(DFLT_TMPFNAME)$evv(CDP_EXT)]
	set rescue_msg "\nYOU MUST EDIT (OR CREATE) IT IN A SIMPLE TEXT EDITOR (NOT A Word Processor)\nADDING YOUR NEW YOUR PRIVATE DIRECTORIES\nOR DELETING THOSE YOU WISH TO REMOVE"
	if [catch {open $fnam "w"} zit] {
		set msg "Cannot Open File '$fnam' To Begin Writing New Private Directories Information\n"
		append msg $rescue_msg
		Inf $msg
		return
	}
	foreach pd $private_directories {
		puts $zit $pd
	}
	close $zit
	if [file exists $pd_file] {
		if [catch {file delete $pd_file} zorg] {
			set msg "Cannot Delete The Old Existing Private Directories File '$pd_file'\n"
			append msg $rescue_msg
			Inf $msg
			catch {file delete $fnam}
			return
		}
	}
	if [catch {file rename $fnam $pd_file}] {
		set msg "Failed To Save New Private Directories Information To File '$pd_file'\n"
		append msg $rescue_msg
		Inf $msg
		catch {file delete $fnam}
	}
}

#------ Load List of Private Directories

proc LoadPrivateDirs {} {
	global private_directories evv

	set pd_file [file join $evv(URES_DIR) $evv(PRIVATE)$evv(CDP_EXT)]
	if {![file exists $pd_file]} {
		return
	}
	if [catch {open $pd_file "r"} zit] {
		Inf "Cannot Open File '$fnam' To Read Private Directories Information\n"
		return
	}
	while {[gets $zit thisdir] >= 0} {
		if {![file isdirectory $thisdir]} {
			Inf "Directory '$thisdir' Listed In Private Directories File '$pd_file' No Longer Exists"
			continue
		}
		lappend private_directories $thisdir
	}
	close $zit
}

#------ Change List of Private Directories

proc SetPrivate {} {
	global private_directories pr_private thisprivate evv

	set f .private
	if [Dlg_Create  $f "Private Directories" "set pr_private 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.ok -text "Keep New List" -command "set pr_private 0" -width 15 -highlightbackground [option get . background {}]
		button $f.0.ab -text "Abandon Changes" -command "set pr_private -1" -width 15 -highlightbackground [option get . background {}]
		pack $f.0.ok $f.0.ab -side right -padx 2
		button $f.0.rem -text "Remove" -command "set pr_private 1" -width 6 -highlightbackground [option get . background {}]
		button $f.0.add -text "Add" -command "set pr_private 2" -width 6 -highlightbackground [option get . background {}]
		pack $f.0.add $f.0.rem -side left -padx 2
		label $f.1 -text "SET UP PRIVATE DIRECTORIES"
		frame $f.1a
		button $f.1a.1 -text "Find Directory" -command {DoListingOfDirectories .private.3} -width 16 -highlightbackground [option get . background {}]
		button $f.1a.2 -text "Recent Directory" -command {ListRecentDirs .private.3} -width 16 -highlightbackground [option get . background {}]
		pack $f.1a.1 $f.1a.2 -side left -padx 2
		label $f.2 -text "New Private Directory"
		entry $f.3 -textvariable thisprivate -width 48
		label $f.4 -text "Existing Private Directories"
		Scrolled_Listbox $f.5 -width 48 -height 24 -selectmode single
		pack $f.0 -side top -pady 1 -fill x -expand true
		pack $f.1 $f.1a $f.2 $f.3 $f.4 $f.5 -side top -pady 2
		bind $f <Escape> {set pr_private -1}
		bind $f <Return> {set pr_private 0}
	}
	$f.5.list delete 0 end
	if {[info exists private_directories]} {
		foreach pd $private_directories {
			$f.5.list insert end $pd
		}
	}
	set thisprivate ""
	raise $f
	set finished 0
	set pr_private 0
	My_Grab 0 $f pr_private
	while {!$finished} {
		tkwait variable pr_private
		switch -- $pr_private {
			-1 {
				set finished 1
			}
			0 {
				catch {unset new_pd}
				foreach item [$f.5.list get 0 end] {
					lappend new_pd $item
				}
				if {[info exists new_pd]} {
					set private_directories $new_pd
				} else {
					catch {unset private_directories}
				}
				SavePrivateDirs
				set finished 1
			}
			1 {
				set i [$f.5.list curselection]
				if {![info exists i] || $i < 0} {
					Inf "No item selected"
					continue
				}
				if {[AreYouSure]} {
					$f.5.list delete $i
				}
			}
			2 {
				if {[string length $thisprivate] <= 0} {
					Inf "No directory name entered"
					continue
				}
				if {![file isdirectory $thisprivate]} {
					Inf "Directory $thisprivate does not exist."
					continue
				}
				if {[CDP_Restricted_Directory $thisprivate 0]} {
					continue
				}
				$f.5.list insert end $thisprivate
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

######################
# LOGISTICS EQUATION #
######################

proc LogisticMotifs {} {
	global chlist wl wstk evv pa logi mix_perm pr_logistic logi logierr
	global CDPidrun prg_dun prg_abortd simple_program_messages last_outfile

	catch {unset logi(infiles)}
	catch {unset logi(textfnams)}
	catch {unset logi(outfiles)}
	catch {unset logi(durs)}
	InitialiseLogiErr
	if {[info exists chlist] && ([llength $chlist] >= 1)} {
		set logi(infiles) $chlist
	} else {
		set ilist [$wl curselection]
		if {([llength $ilist] == 1) && ($ilist == -1)} {
			break
		}
		foreach i $ilist {
			lappend logi(infiles) [$wl get $i]
		}
	}
	if {![info exists logi(infiles)]} {
		Inf "No source soundfiles selected"
		return
	}
	foreach fnam $logi(infiles) {
		if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) != 1)} {
			Inf "Use mono soundfiles only"
			return
		}
	}
	if {[llength $logi(infiles)] > 1} {
		set fnam [lindex $logi(infiles) 0]
		set srate $pa($fnam,$evv(SRATE))
		foreach fnam [lrange $logi(infiles) 1 end] {
			if {$pa($fnam,$evv(SRATE)) != $srate} {
				Inf "Input files are not at same sample rate"
				return
			}
		}
	}
	set logi(infilecnt) [llength $logi(infiles)]

	DeleteAllTemporaryFiles

	set rlogifnam $evv(DFLT_OUTNAME)
	append rlogifnam 000 $evv(TEXT_EXT)
	set slogifnam $evv(DFLT_OUTNAME)
	append slogifnam 001 $evv(TEXT_EXT)

	set logi(tempfnam) $evv(DFLT_OUTNAME)

	set f .logistic
	if [Dlg_Create $f "CREATE LOGISTIC EQUATION PITCHLINES" "set pr_logistic 0" -borderwidth $evv(SBDR)] {
		set f0  [frame $f.0] 
		set f01  [frame $f.01] 
		set f00 [frame $f.00] 
		set f02 [frame $f.02] 
		set f1  [frame $f.1] 
		set f03 [frame $f.03] 
		set f04 [frame $f.04] 
		set f2  [frame $f.2] 
		set f3  [frame $f.3] 
		set f4  [frame $f.4] 
		set f5  [frame $f.5] 
		set f6  [frame $f.6] 
		set f7  [frame $f.7] 
		set f8  [frame $f.8] 
		set f9  [frame $f.9] 
		set f10 [frame $f.10] 
		set f11 [frame $f.11] 
		set f12 [frame $f.12] 
		set f13 [frame $f.13] 
		set f14 [frame $f.14] 
		set f15 [frame $f.15] 
		set f16 [frame $f.16] 
		set f17 [frame $f.17] 
		set f18 [frame $f.18] 
		set f19 [frame $f.19] 
		set f20 [frame $f.20] 
		button $f0.0 -text "Create Sounds" -command "set pr_logistic 1" -bg $evv(EMPH)
		button $f0.hh -text "Help" -command "HelpLogistic" -bg $evv(HELP)
		button $f0.1 -text "Abandon"   -command "set pr_logistic 0"
		pack $f0.0 $f0.hh -side left -padx 2
		pack $f0.1 -side right
		pack $f0 -side top -fill x -expand true -pady 2
		button $f01.0 -text "Save Patch" -command "set pr_logistic 2"
		button $f01.1 -text "Load Patch" -command "set pr_logistic 3"
		pack $f01.0 $f01.1 -side left -padx 4
		pack $f01 -side top -pady 2
		label $f00.0 -text "WHICH CYCLIC AREA ?" -fg $evv(SPECIAL)
		pack $f00.0 -side left
		pack $f00 -side top -fill x -expand true -pady 2
		radiobutton $f1.1  -variable logi(cyccnt) -text "1"  -value 1 -command LogiRange
		radiobutton $f1.2  -variable logi(cyccnt) -text "2"  -value 2 -command LogiRange
		radiobutton $f1.4  -variable logi(cyccnt) -text "4"  -value 4 -command LogiRange
		radiobutton $f1.8  -variable logi(cyccnt) -text "8"  -value 8 -command LogiRange
		radiobutton $f1.16 -variable logi(cyccnt) -text "16" -value 16 -command LogiRange
		radiobutton $f1.32 -variable logi(cyccnt) -text "32" -value 32 -command LogiRange
		radiobutton $f1.ch -variable logi(cyccnt) -text "chaotic" -value -1 -command LogiRange
		radiobutton $f03.rr -variable logi(cyccnt) -text "specify range of constant (>0-4)" -value 10000 -command LogiRange
		pack $f1.1 $f1.2 $f1.4 $f1.8 $f1.16 $f1.32 $f1.ch -side left
		pack $f1 -side top -fill x -expand true
		pack $f03.rr -side left
		pack $f03 -side top -fill x -expand true
		entry $f04.e -textvariable logi(lor) -width 4
		label $f04.ll -text " to "
		entry $f04.e2 -textvariable logi(hir) -width 4
		pack $f04.e $f04.ll $f04.e2 -side left -padx 2 
		pack $f04 -side top -fill x -expand true
		label $f2.ll -text "LINE PARAMETERS" -fg $evv(SPECIAL)
		pack $f2.ll -side left -padx 2 
		pack $f2 -side top -fill x -expand true -pady 2
		entry $f3.e -textvariable logi(cnt) -width 8
		label $f3.ll -text "Number of output lines"
		pack $f3.e $f3.ll -side left -padx 2 
		pack $f3 -side top -fill x -expand true -pady 2
		entry $f4.e -textvariable logi(tail) -width 8
		label $f4.ll -text "Event tail duration"
		pack $f4.e $f4.ll -side left -padx 2 
		pack $f4 -side top -fill x -expand true -pady 2
		entry $f5.e -textvariable logi(efade) -width 8
		label $f5.ll -text "Event fade duration (shorter than tail)"
		pack $f5.e $f5.ll -side left -padx 2 
		pack $f5 -side top -fill x -expand true -pady 2
		entry $f6.e -textvariable logi(limit) -width 8
		label $f6.ll -text "Maximum line duration (longer than tail: and >= 0.02)"
		pack $f6.e $f6.ll -side left -padx 2 
		pack $f6 -side top -fill x -expand true -pady 2

		label $f7.ll -text "NOTE PARAMETERS" -fg $evv(SPECIAL)
		pack $f7.ll -side left -padx 2 
		pack $f7 -side top -fill x -expand true -pady 2
		entry $f8.e -textvariable logi(minstep) -width 8
		label $f8.ll -text "Min Timestep between Note-entries (>= 0.02)"
		pack $f8.e $f8.ll -side left -padx 2 
		pack $f8 -side top -fill x -expand true -pady 2
		entry $f9.e -textvariable logi(maxstep) -width 8
		label $f9.ll -text "Max Timestep between Note-entries (>= Min Timestep)"
		pack $f9.e $f9.ll -side left -padx 2 
		pack $f9 -side top -fill x -expand true -pady 2
		entry $f10.e -textvariable logi(nrand) -width 8
		label $f10.ll -text "Note-time Randomisation (0 to <1)"
		pack $f10.e $f10.ll -side left -padx 2 
		pack $f10 -side top -fill x -expand true -pady 2
		entry $f11.e -textvariable logi(minmidi) -width 8
		label $f11.ll -text "Minimum pitch of MIDI range (0-127)"
		pack $f11.e $f11.ll -side left -padx 2 
		pack $f11 -side top -fill x -expand true -pady 2
		entry $f12.e -textvariable logi(maxmidi) -width 8
		label $f12.ll -text "Maximum pitch of MIDI range (0-127)"
		pack $f12.e $f12.ll -side left -padx 2 
		pack $f12 -side top -fill x -expand true -pady 2
		entry $f13.e -textvariable logi(nup) -width 8
		label $f13.ll -text "Note infade duration (0 to 1sec : curtailed if too long)"
		pack $f13.e $f13.ll -side left -padx 2 
		pack $f13 -side top -fill x -expand true -pady 2
		entry $f14.e -textvariable logi(nfade) -width 8
		label $f14.ll -text "Note outfade duration (0 to 1sec : curtailed if too long)"
		pack $f14.e $f14.ll -side left -padx 2 
		pack $f14 -side top -fill x -expand true -pady 2
		entry $f15.e -textvariable logi(mingap) -width 8
		label $f15.ll -text "Min proportion of note duration which is silent (0-1)"
		pack $f15.e $f15.ll -side left -padx 2 
		pack $f15 -side top -fill x -expand true -pady 2
		entry $f16.e -textvariable logi(maxgap) -width 8
		label $f16.ll -text "Max proportion of note duration which is silent (0-1)"
		pack $f16.e $f16.ll -side left -padx 2 
		pack $f16 -side top -fill x -expand true -pady 2
		label $f17.ll -text "GLOBAL PARAMETERS" -fg $evv(SPECIAL)
		pack $f17.ll -side left 
		pack $f17 -side top -fill x -expand true -pady 2
		entry $f18.e -textvariable logi(seed) -width 8
		label $f18.ll -text "Seed for random numbers (integer > 0)"
		pack $f18.e $f18.ll -side left -padx 2 
		pack $f18 -side top -fill x -expand true -pady 2
		checkbutton $f20.ch -variable logi(err) -text "See any error report"
		pack $f20.ch -side left
		checkbutton $f20.see -variable logi(tell) -text "See which srcs used"
		pack $f20.see -side left
		pack $f20 -side top -fill x -expand true -pady 2
		entry $f19.e -textvariable logi(ofnam) -width 24
		label $f19.ll -text "Generic outfile name"
		pack $f19.ll $f19.e -side left -padx 2 
		pack $f19 -side top -pady 2
		set logi(err) 0
		wm resizable $f 0 0
		bind $f <Escape> {set pr_logistic 0}
		bind $f <Return> {set pr_logistic 1}
		bind $f3.e  <Down> "focus $f4.e"
		bind $f4.e  <Down> "focus $f5.e"
		bind $f5.e  <Down> "focus $f6.e"
		bind $f6.e  <Down> "focus $f8.e"
		bind $f8.e  <Down> "focus $f9.e"
		bind $f9.e  <Down> "focus $f10.e"
		bind $f10.e <Down> "focus $f11.e"
		bind $f11.e <Down> "focus $f12.e"
		bind $f12.e <Down> "focus $f13.e"
		bind $f13.e <Down> "focus $f14.e"
		bind $f14.e <Down> "focus $f15.e"
		bind $f15.e <Down> "focus $f16.e"
		bind $f16.e <Down> "focus $f18.e"
		bind $f18.e <Down> "focus $f19.e"
		bind $f19.e <Down> "focus $f3.e"
		bind $f3.e  <Up> "focus $f19.e"
		bind $f4.e  <Up> "focus $f3.e"
		bind $f5.e  <Up> "focus $f4.e"
		bind $f6.e  <Up> "focus $f5.e"
		bind $f8.e  <Up> "focus $f6.e"
		bind $f9.e  <Up> "focus $f8.e"
		bind $f10.e <Up> "focus $f9.e"
		bind $f11.e <Up> "focus $f10.e"
		bind $f12.e <Up> "focus $f11.e"
		bind $f13.e <Up> "focus $f12.e"
		bind $f14.e <Up> "focus $f13.e"
		bind $f15.e <Up> "focus $f14.e"
		bind $f16.e <Up> "focus $f15.e"
		bind $f18.e <Up> "focus $f16.e"
		bind $f19.e <Up> "focus $f18.e"
	}
	set logi(tell) 0
	if {![info exists logi(cyccnt)]} {
		set logi(cyccnt) 0
	}
	LogiRange
	set pr_logistic 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_logistic $f.3.e
	while {!$finished} {
		tkwait variable pr_logistic
		switch -- $pr_logistic {
			1 - 
			2 {
				;#	Check parameters

				if {$logi(cyccnt) == 0} {
					Inf "NO CYCLE COUNT SELECTED"
					continue
				}
				if {([string length $logi(lor)] > 0) ||  ([string length $logi(hir)] > 0)} {
					if {[string length $logi(lor)] > 0} {
						if {![IsNumeric $logi(lor)] || ($logi(lor) <= 0.0) || ($logi(lor) > 4.0)} {
							Inf "Invalid value for bottom of range-of-constant"
							continue
						}
						if {[string length $logi(hir)] <= 0} {
							Inf "No value enterd for top of range-of-constant"
							continue 
						}
					}
					if {[string length $logi(hir)] > 0} {
						if {![IsNumeric $logi(hir)] || ($logi(hir) <= 0.0) || ($logi(hir) > 4.0)} {
							Inf "Invalid value for top range-of-constant"
							continue
						}
						if {[string length $logi(lor)] <= 0} {
							Inf "No value enterd for bottom of range-of-constant"
							continue 
						}
					}
					if {$logi(hir) < $logi(lor)} {
						set temp $logi(hir)
						set logi(hir) $logi(lor)
						set logi(lor) $temp
					}
				}
				if {$logi(cyccnt) == 0} {
					Inf "No cycle count selected"
					continue
				}

				if {[string length $logi(cnt)] <= 0} {
					Inf "Number of output lines not given"
					continue
				}
				if {![regexp {^[0-9]+$} $logi(cnt)] || ($logi(cnt) < 1)} {
					Inf "Invalid number of output lines given"
					continue
				}
				if {[string length $logi(tail)] <= 0} {
					Inf "Event tail duration not given"
					continue
				}
				if {![IsNumeric $logi(tail)] || ($logi(tail) < 0)} {
					Inf "Invalid event tail duration "
					continue
				}
				if {[string length $logi(efade)] <= 0} {
					Inf "Event fade duration not given"
					continue
				}
				if {![IsNumeric $logi(efade)] || ($logi(efade) < 0)} {
					Inf "Invalid event fade duration "
					continue
				}
				if {$logi(efade) > $logi(tail)} {
					Inf "Line fade cannot be longer than line tail"
					continue
				}

				if {[string length $logi(limit)] <= 0} {
					Inf "Event duration limit not given"
					continue
				}
				if {![IsNumeric $logi(limit)] || ($logi(limit) < 0.02)} {
					Inf "Invalid event duration limit"
					continue
				}
				if {$logi(limit) <= $logi(tail)} {
					Inf "Event duration limit cannot be less than or equal to line tail"
					continue
				}

				if {[string length $logi(minstep)] <= 0} {
					Inf "Min timestep between note-entries not given"
					continue
				}
				if {![IsNumeric $logi(minstep)] || ($logi(minstep) <= 0.02)} {
					Inf "Invalid min timestep between note-entries"
					continue
				}
				if {[string length $logi(maxstep)] <= 0} {
					Inf "Max timestep between note-entries not given"
					continue
				}
				if {![IsNumeric $logi(maxstep)] || ($logi(maxstep) <= 0.02)} {
					Inf "Invalid max timestep between note-entries"
					continue
				}
				if {$logi(minstep) > $logi(maxstep)} {
					Inf "Max timestep must be >= min timestep"
					continue
				}
				set logi(steprange) [expr $logi(maxstep) - $logi(minstep)]
				if {[string length $logi(nrand)] <= 0} {
					Inf "Note-time randomisation not given"
					continue
				}
				if {![IsNumeric $logi(nrand)] || ($logi(nrand) < 0.0) || ($logi(nrand) > 1.0)} {
					Inf "Invalid note-time randomisation"
					continue
				}
				if {[string length $logi(minmidi)] <= 0} {
					Inf "Minimum pitch of midi range not given"
					continue
				}
				if {![IsNumeric $logi(minmidi)] || ($logi(minmidi) < 0) || ($logi(minmidi) > 127)} {
					Inf "Invalid minimum pitch of midi range"
					continue
				}
				if {[string length $logi(maxmidi)] <= 0} {
					Inf "Maximum pitch of midi range not given"
					continue
				}
				if {![IsNumeric $logi(maxmidi)] || ($logi(maxmidi) < 0) || ($logi(maxmidi) > 127)} {
					Inf "Invalid maximum pitch of midi range"
					continue
				}
				if {$logi(maxmidi) < $logi(minmidi)} {
					set temp $logi(maxmidi)
					set logi(maxmidi) $logi(minmidi)
					set logi(minmidi) $temp
				}
				if {[string length $logi(nup)] <= 0} {
					Inf "Note infade duration not given"
					continue
				}
				if {![IsNumeric $logi(nup)] || ($logi(nup) < 0) || ($logi(nup) > 1)} {
					Inf "Invalid note infade duration"
					continue
				}
				if {[string length $logi(nfade)] <= 0} {
					Inf "Note outfade duration not given"
					continue
				}
				if {![IsNumeric $logi(nfade)] || ($logi(nfade) < 0) || ($logi(nfade) > 1)} {
					Inf "Invalid note outfade duration"
					continue
				}
				if {[string length $logi(mingap)] <= 0} {
					Inf "Minimum silence proportion not given"
					continue
				}
				if {![IsNumeric $logi(mingap)] || ($logi(mingap) < 0) || ($logi(mingap) > 1)} {
					Inf "Invalid minimum silence proportion"
					continue
				}
				if {[string length $logi(maxgap)] <= 0} {
					Inf "Maximum silence proportion not given"
					continue
				}
				if {![IsNumeric $logi(maxgap)] || ($logi(maxgap) < 0) || ($logi(maxgap) > 1)} {
					Inf "Invalid maximum silence proportion"
					continue
				}
				if {$logi(maxgap) < $logi(mingap)} {
					set temp $logi(maxgap)
					set logi(maxgap) $logi(mingap)
					set logi(mingap) $temp
				}
				if {[string length $logi(seed)] <= 0} {
					Inf "Random seed value not given"
					continue
				}
				if {![regexp {^[0-9]+$} $logi(seed)] || ($logi(seed) < 1)} {
					Inf "Invalid random seed value"
					continue
				}

				if {$pr_logistic == 2} {
					SaveLogisticPatch
					continue
				}
			;#	CHECK ALL FILENAMES THAT WILL BE GENERATED

				if {[string length $logi(ofnam)] <= 0} {
					Inf "No output filename entered"
					continue
				}
				if {![ValidCDPRootname $logi(ofnam)]} {
					continue
				}
				set OK 1
				Block "CHECKING OUTPUT FILENAMES"
				set ofnam [string tolower $logi(ofnam)]
				if {[regexp {[0-9]} [string index $ofnam end]]} {
					set separ "_"
				} else {
					set separ ""
				}
				append ofnam $separ
				set n 1
				while {$n <= $logi(cnt)} {
					set thisofnam $ofnam
					append thisofnam $n $evv(SNDFILE_EXT)
					if {[file exists $thisofnam]} {
						Inf "File $thisofnam already exists: please choose a different generic name"
						set OK 0
						break
					}
					set thisofnam $ofnam
					append thisofnam $n $evv(TEXT_EXT)
					if {[file exists $thisofnam]} {
						Inf "File $thisofnam already exists: please choose a different generic name"
						set OK 0
						break
					}
					incr n
				}
				if {!$OK} {
					UnBlock
					continue
				}

				;#	DECIDE ON RANGE OF CONSTANT "R", DEPENDING ON WHICH CYCLE WE'RE IN

				switch -- $logi(cyccnt) {
					1 {
						set r_start 0
						set r_end	2.893  
					}
					2 {
						set r_start 2.894
						set r_end	3.398  
					}
					4 {
						set r_start 3.399
						set r_end	3.527  
					}
					8 {
						set r_start 3.528
						set r_end	3.560  
					}
					16 {
						set r_start 3.561
						set r_end	3.567  
					}
					32 {
						set r_start 3.568
						set r_end	3.570  
					}
					"-1" {
						set r_start 3.571
						set r_end	4.000  
					}
					10000 {
						if {![info exists logi(lor)] || ![IsNumeric $logi(lor)] || ($logi(lor) <= 0.0) || ($logi(lor) > 4.0) \
						||  ![info exists logi(hir)] || ![IsNumeric $logi(hir)] || ($logi(hir) <= 0.0) || ($logi(hir) > 4.0) \
						|| ($logi(lor) > $logi(hir))} {
							Inf "Invalid \"R\"-range values given"
							UnBlock
							continue
						}
						set r_start $logi(lor)
						set r_end   $logi(hir)
					}
				}
				set line $r_start
				lappend line $r_end
				if [catch {open $rlogifnam "w"} zit] {
					Inf "Cannot open temporary file	$rlogifnam to write constant \"R\" values"
					UnBlock
					continue
				}
				puts $zit $line
				close $zit

				if {[flteq $logi(maxstep) $logi(minstep)]} {
					set step $logi(maxstep)
				} else {
					set line $logi(minstep)
					lappend line $logi(maxstep)
					if [catch {open $slogifnam "w"} zit] {
						Inf "Cannot open temporary file	$slogifnam to write timestep values"
						UnBlock
						continue
					}
					puts $zit $line
					close $zit
					set step $slogifnam
				}
				set cmd [file join $evv(CDPROGRAM_DIR) logistic]
				lappend cmd $ofnam $rlogifnam $step $logi(nrand) $logi(tail) $logi(limit) $logi(cnt) $logi(seed) $logi(minmidi) $logi(maxmidi) -c

				;#	 logistic ofnam     R   timestep timerand     taillen     limitdur    datacount    seed         pmin           pmax		   -c
				;#					  (FILE) (FILE)

				set CDPidrun 0
				set prg_dun 0
				set prg_abortd 0
				catch {unset simple_program_messages}
				wm title .blocker "PLEASE WAIT:        GENERATING THE MOTIF DATA"
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "$CDPidrun : Failed to generate motif data"
					UnBlock
					continue
   				} else {
 					fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				catch {unset logi(textfnams)}
				set ofnam [string tolower $logi(ofnam)]
				append ofnam $separ
				set n 1
				set outcnt 0
				while {$n <= $logi(cnt)} {
					set thisofnam $ofnam
					append thisofnam $n $evv(TEXT_EXT)
					if {[file exists $thisofnam]} {
						lappend logi(textfnams) $thisofnam 
						incr outcnt
					}
					incr n
				}
				if {!$prg_dun} {
					set msg "Failed to generate motif data"
					set msg [AddSimpleMessages $msg]
					Inf $msg
					if {[info exists logi(textfnams)]} {
						ClearLogisticTextfileOutputs
					}
					UnBlock
					continue
				}
				if {![info exists logi(textfnams)]} {
					set msg "Failed to generate any motif data"
					Inf $msg
					UnBlock
					continue
				}

				;#	CHECK HOW MANY MOTIF TEXTFILES WE HAVE GENERATED

				catch {close $CDPidrun}
				if {$outcnt != $logi(cnt)} {
					set msg "Only $outcnt of intended $logi(cnt) motifs generated: continue making sounds ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						ClearLogisticTextfileOutputs
						UnBlock
						continue
					}
				}

				;#	SET UP PERMUTATION OF INPUT FILES

				if {$logi(infilecnt) == 1} {
					set logi(srcs) [lindex $logi(infiles) 0]
					set permcnt 0
					set doperm 0
				} else {
					catch {unset logi(srcs)}
					RandomiseOrder $logi(infilecnt)
					set n 0
					while {$n < $logi(infilecnt)} {
						lappend logi(srcs) [lindex $logi(infiles) $mix_perm($n)]
						incr n
					}
					set permcnt 0 
					set doperm 1
				}

				;#	EXTRACT EVENT DURATION FROM MOTIF FILES

				set badfiles 0
				set OK 1
				catch {unset logi(durs)}
				wm title .blocker "PLEASE WAIT:        FINDING MOTIF DURATIONS"
				foreach motif $logi(textfnams) {
					if [catch {open $motif "r"} zit] {
						Inf "Cannot open file $motif to read total duration"
						set OK 0
						break
					}
					catch {unset lasttime}
					catch {unset penulttime}
					while {[gets $zit line] >= 0} {
						set line [string trim $line]
						if {[string length $line] <= 0} {
							continue
						}
						if {[string match [string index $line 0] ";"]} {
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
								if {[info exists lasttime]} {
									set penulttime $lasttime
								}
								set lasttime $item
							}
							incr cnt
						}
						if {$cnt != 2} {
							Inf "Problem in reading motif data (not correctly paired) in file $motif"
							set OK 0
							break
						}
					}
					close $zit
					if {!$OK} {
						break
					}
					if {![info exists penulttime] || ![info exists lasttime]} {
						Inf "Failed to find one or both of last times in file $motif"
						set OK 0
						break
					}
					set laststep [expr $lasttime - $penulttime]
					if {$laststep <= 0.0} {
						Inf "Invalid final timestep in file $motif"
						set OK 0
						break
					}
					set lasttime [expr $lasttime + $laststep + 0.1]
					lappend logi(durs) $lasttime
				}
				if {!$OK} {
					set msg "Halted procedure : delete any existing motif textfiles ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						ClearLogisticTextfileOutputs
					}
					UnBlock
					continue
				}
		
				;#	INITIALISE PROCESS VARIABLES

				set susrange [expr $logi(maxgap) - $logi(mingap)]
				catch {unset badmotifs}
				catch {unset logi(outfiles)}

				;#	FOR EVERY MOTIF TEXTFILE GENERATE THE SOUND OUTPUT

				set outcnt 0
				catch {unset outinfo}
				foreach motif $logi(textfnams) dur $logi(durs) {
					incr outcnt
					set motifnam [file rootname [file tail $motif]]
					wm title .blocker "PLEASE WAIT:        GENERATING MOTIF $motifnam"
					set sndfnam $motifnam$evv(SNDFILE_EXT)				;#	Get soundfile name same as textfile
					set tempsndfnam $logi(tempfnam)						;#	Generate numbered names of temporary intermediate sndfiles
					append tempsndfnam $outcnt $evv(SNDFILE_EXT)

					;#	SELECT THE SOUND-SOURCE

					set infnam [lindex $logi(srcs) $permcnt] 
					if {$doperm} {
						incr permcnt
						if {$permcnt >= $logi(infilecnt)} {
							catch {unset logi(srcs)}
							RandomiseOrder $logi(infilecnt)
							set n 0
							while {$n < $logi(infilecnt)} {
								lappend logi(srcs) [lindex $logi(infiles) $mix_perm($n)]
								incr n
							}
							set permcnt 0 
						}
					}

					;#	GENERATE THE SUSTAIN PARAMETER

					set separation [expr rand() * $susrange]
					set separation [expr $separation + $logi(mingap)]

					;#	SET CMDLINE

					set cmd [file join $evv(CDPROGRAM_DIR) iterfof]
					lappend cmd iterfof 4 $infnam $tempsndfnam $motif $dur -F$logi(nup) -f$logi(nfade) -S$separation -s$logi(seed)
					;#  iterfof iterfof 1-4 infile outfile    linedata dur [-Fupfade] [-ffade]       [-Sseparation] [-sseed]

					;#	RUN CMDLINE

					catch {close $CDPidrun}
					set CDPidrun 0
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					if [catch {open "|$cmd"} CDPidrun] {
						lappend badmotifs $motifnam
						lappend logierr(open_iterfof) $cmd
						continue
   					} else {
 						fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
					}
					vwait prg_dun
					if {$prg_abortd} {
						set prg_dun 0
					}
					if {!$prg_dun} {
						lappend badmotifs $motifnam
						lappend logierr(run_iterfof) $cmd
						continue
					}
					if {![file exists $tempsndfnam]} {
						lappend badmotifs $motifnam
						lappend logierr(output_of_iterfof) $cmd
						continue
					}

					wm title .blocker "PLEASE WAIT:        ENVELOPING MOTIF $motifnam"

					set dur [DoDurParse $tempsndfnam]
					if {$dur <= 0.0} {
						lappend badmotifs $motifnam
						lappend logierr(cdparse_for_duration) $cmd
						continue
					}
					set endove $logi(efade)
					if {$endove > $dur} {
						set endove $dur
					}
					set cmd [file join $evv(CDPROGRAM_DIR) envel]
					lappend cmd dovetail 2 $tempsndfnam $sndfnam 0 $endove -t0
					set CDPidrun 0
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					if [catch {open "|$cmd"} CDPidrun] {
						lappend badmotifs $motifnam
						lappend logierr(open_dovetailing) $cmd
						continue
   					} else {
 						fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
					}
					vwait prg_dun
					if {$prg_abortd} {
						set prg_dun 0
					}
					if {!$prg_dun} {
						lappend badmotifs $motifnam
						lappend logierr(run_dovetailing) $cmd
						continue
					}
					if {![file exists $sndfnam]} {
						lappend badmotifs $motifnam
						lappend logierr(output_dovetailing) $cmd
						continue
					}
					lappend logi(outfiles) $sndfnam
					set line [list $infnam $sndfnam]
					lappend outinfo $line
				}
				catch {close $CDPidrun}
				if {![info exists logi(outfiles)]} {
					set msg "No sounds generated : delete all motif textfiles ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						ClearLogisticTextfileOutputs
					}
					set finished 1
				} elseif {[info exists badmotifs]} {
					set msg "[llength $badmotifs] motifs failed to be generated: keep the others ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						set msg "Are you sure you want to delete the sounds generated ??"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "yes"} {
							ClearLogisticSndfileOutputs
							set msg "Delete all motif textfiles ??"
							set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
							if {$choice == "yes"} {
								ClearLogisticTextfileOutputs
							}
							set finished 1
						}
					} else {
						set msg "Delete textfiles associated with failed outputs ??"
						if {$choice == "yes"} {
							ClearUnrealisedTextfileOutputs
						}
						set finished 1
					}
				}
				if {[info exists badmotifs] && $logi(err)} {
					LogisticErrorReport
				}
				if {[info exists logi(textfnams)] || [info exists logi(outfiles)]} {
					wm title .blocker "PLEASE WAIT:        PUTTING OUTPUT FILES ON WORKSPACE"
					if {[info exists logi(textfnams)]} {
						set logi(textfnams) [ReverseList $logi(textfnams)]
						foreach fnam $logi(textfnams) {
							FileToWkspace $fnam 0 0 0 0 1
						}
					}
					if {[info exists logi(outfiles)]} {
						if {$logi(tell)} {
							OutputLogiSrcInfo $outinfo
						}
						set last_outfile $logi(outfiles)
						set logi(outfiles) [ReverseList $logi(outfiles)]
						foreach fnam $logi(outfiles) {
							FileToWkspace $fnam 0 0 0 0 1
						}
					}
				}
				DeleteAllTemporaryFiles
				UnBlock
				break
			}
			3 {
				LoadLogisticPatch
			}
			0 {
				if {[info exists logi(outfiles)] || [info exists logi(textfnams)]} {
					set msg "Delete the files already made ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						if {[info exists logi(outfiles)]} {
							ClearLogisticSndfileOutputs
						}
						if {[info exists logi(textfnams)]} {
							ClearLogisticTextfileOutputs
						}
					}
				}
				DeleteAllTemporaryFiles
				set finished 1
			}
		}
	}

	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- Purge all last-pass produced logistics datafiles

proc ClearLogisticTextfileOutputs {} {
	global logi
	foreach fnam $logi(textfnams) {
		if [catch {file delete $fnam} zit] {
			lappend badfiles $fnam
		}
	}
	catch {unset logi(textfnams)}
	if {[info exists badfiles]} {
		Inf "Some textfile outputs named [string tolower $logi(ofnam)] still exist.\nQuit process and delete these before proceeding\n"
	}
}

#---- Purge all last-pass produced logistics datafiles which have no corresponding outpuyt soundfile

proc ClearUnrealisedTextfileOutputs {} {
	global logi evv
	foreach fnam $logi(textfnams) {
		set sndfnam [file rootname [file tail $fnam]]
		append sndfnam $evv(SNDFILE_EXT)
		if {![file exists $sndfnam]} {
			if [catch {file delete $fnam} zit] {
				lappend badfiles $fnam
			}
			lappend delfiles $fnam
		}
	}
	if {[info exists badfiles]} {
		Inf "Some invalid motif textfile still exist"
	}
	if {[info exists delfiles]} {
		foreach fnam $delfiles {
			set k [lsearch $logi(textfnams) $fnam]
			if {$k >= 0} {
				set logi(textfnams) [lreplace $logi(textfnams) $k $k]
			}
		}
	}
}

#---- Purge all last-pass produced logistics sndfiles

proc ClearLogisticSndfileOutputs {} {
	global logi
	foreach fnam $logi(outfiles) {
		if [catch {file delete $fnam} zit] {
			lappend badfiles $fnam
		}
	}
	catch {unset logi(outfiles)}
	catch {unset logi(durs)}
	if {[info exists badfiles]} {
		Inf "Some soundfile outputs named [string tolower $logi(ofnam)] still exist.\nQuit process and delete these before proceeding.\n"
	}
}

#------ Parse the file (using cdparse) merely to find the duration

proc DoDurParse {fnam} {
	global CDPid parse_error infile_rejected pa propslist props_got is_input_parse evv
	set parse_error 0
	set props_got 0
	set infile_rejected 0
	set is_input_parse 0

	set CDPid 0
	set cmd [file join $evv(CDPROGRAM_DIR) cdparse]
	set zzfnam [OmitSpaces $fnam]
	lappend cmd $zzfnam 0
	if [catch {open "|$cmd"} CDPid] {
		catch {unset CDPid}
		return 0
	} else {
		set propslist ""
		fileevent $CDPid readable AccumulateFileProps
	}
	vwait props_got
	if {$parse_error || $infile_rejected || ![info exists propslist] || ([llength $propslist] < 1)} {
		return 0
	}
	set dur [lindex $propslist 11]
	return $dur
}

#--- Deal with Errors in Logistics processing

proc LogisticErrorReport {} {
	global logierr
	if {![info exists logierr]} {
		return
	}
	set msg ""
	foreach name [array names logierr] {
		append msg "[llength $logierr($name)] failures at $name\n"
		foreach item $logierr($name) {
			append msg "$item\n"
		}
	}
	Inf $msg
}

proc InitialiseLogiErr {} {
	global logierr
	catch {unset logierr(open_iterfof)}
	catch {unset logierr(run_iterfof)}
	catch {unset logierr(output_of_iterfof)}
	catch {unset logierr(cdparse_for_duration)}
	catch {unset logierr(open_dovetailing)}
	catch {unset logierr(run_dovetailing)}
	catch {unset logierr(output_dovetailing)}
}

#---- Save parameter vals from Logistics window to a named patch

proc SaveLogisticPatch {} {
	global logi pr_savelogi evv wstk logipatch
	set thispatch $logi(cyccnt) 
	lappend thispatch $logi(cnt) $logi(tail) $logi(efade) $logi(limit) $logi(minstep) $logi(maxstep) $logi(nrand) $logi(minmidi)
	lappend thispatch $logi(maxmidi) $logi(nup) $logi(nfade) $logi(mingap) $logi(maxgap) $logi(seed) $logi(lor) $logi(hir)

	set ppfnam [file join $evv(URES_DIR) logipatches$evv(CDP_EXT)]

	foreach nam [array names logipatch] {
		lappend patchlist $nam
	}
	set f .savelogi
	if [Dlg_Create $f "SAVE LOGISTIC PATCH" "set pr_savelogi 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.load -text "Save Patch" -command "set pr_savelogi 1" -bg $evv(EMPH)
		button $f.0.q -text "Quit" -command "set pr_savelogi 0"
		pack $f.0.load -side left
		pack $f.0.q -side right
		pack $f.0 -side top -fill x -expand true -pady 2
		frame $f.1
		label $f.1.ll -text "Patchname" 
		entry $f.1.e -textvariable logi(patchnam) -width 24
		set logi(patchnam) ""
		pack $f.1.e $f.1.ll -side left -pady 2
		pack $f.1 -side top -pady 2
		wm resizable $f 0 0
		bind $f <Escape> {set pr_savelogi 0}
		bind $f <Return> {set pr_savelogi 1}
	}
	set pr_savelogi 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_savelogi $f.1.e
	while {!$finished} {
		tkwait variable pr_savelogi
		switch -- $pr_savelogi {
			1 {
				if {[string length $logi(patchnam)] <= 0} {
					Inf "No patch name entered"
					continue
				}
				if {![regexp {^[A-Za-z0-9\-\_]+$} $logi(patchnam)]} {
					Inf "Invalid patchname (use letters, numbers, hyphens and underscores only)"
					continue
				}
				if {[info exists patchlist]} {
					set OK 1
					foreach nam $patchlist {
						if {[string match $nam $logi(patchnam)]} {
							set msg "This name is already in use: overwrite existing patch ??"
							set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
							if {$choice == "no"} {
								set OK 0
								break
							}
						}
					}
					if {!$OK} {
						continue
					}
				}
				set logipatch($logi(patchnam)) $thispatch
				if {[file exists $ppfnam]} {
					if [catch {file delete $ppfnam} zit] {
						Inf "Cannot replace existing logisitic-patch data file $ppfnam"
						continue
					}
				}
				SaveLogiPatches
				set finished 1
			}
			 0 {
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Load an existing logisitics patch

proc LoadLogisticPatch {} {
	global pr_loadlogi logi logipatch evv

	if {![info exists logipatch]} {
		Inf "NO LOGISITIC PATCHES EXIST"
		return
	}
	foreach nam [array names logipatch] {
		lappend patchlist $nam
	}
	set ppfnam [file join $evv(URES_DIR) logipatches$evv(CDP_EXT)]
	set f .loadlogi
	if [Dlg_Create $f "LOAD LOGISTIC PATCH" "set pr_loadlogi 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.load -text "Select Patch" -command "set pr_loadlogi 1" -bg $evv(EMPH)
		button $f.0.del -text "Delete Patch" -command "set pr_loadlogi 2"
		button $f.0.q -text "Quit" -command "set pr_loadlogi 0"
		pack $f.0.load -side left
		pack $f.0.q $f.0.del -side right -padx 6
		pack $f.0 -side top -fill x -expand true -pady 2
		frame $f.1
		label $f.1.tit -text "Existing Logistic Patches" -fg $evv(SPECIAL)
		Scrolled_Listbox $f.1.ll -width 80 -height 24 -selectmode single
		pack $f.1.tit $f.1.ll -side top -pady 2
		pack $f.1 -side top -fill x -expand true -pady 2
		wm resizable $f 0 0
		bind $f <Escape> {set pr_loadlogi 0}
		bind $f <Return> {set pr_loadlogi 1}
	}
	$f.1.ll.list delete 0 end
	set patchcnt 0
	foreach patch $patchlist {
		$f.1.ll.list insert end $patch
		incr patchcnt
	}
	set pr_loadlogi 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_loadlogi
	while {!$finished} {
		tkwait variable pr_loadlogi
		switch -- $pr_loadlogi {
			1 {
				if {$patchcnt == 1} {
					set thispatch [$f.1.ll.list get 0]
				} else {
					set i [$f.1.ll.list curselection]
					if {$i < 0} {
						Inf "No item selected"
						continue
					}
					set thispatch [$f.1.ll.list get $i]
				}
				set thispatch $logipatch($thispatch)
				set logi(cyccnt)	[lindex $thispatch 0]
				LogiRange
				set logi(cnt)		[lindex $thispatch 1]
				set logi(tail)		[lindex $thispatch 2]
				set logi(efade)		[lindex $thispatch 3]
				set logi(limit)		[lindex $thispatch 4]
				set logi(minstep)	[lindex $thispatch 5]
				set logi(maxstep)	[lindex $thispatch 6]
				set logi(nrand)		[lindex $thispatch 7]
				set logi(minmidi)	[lindex $thispatch 8]
				set logi(maxmidi)	[lindex $thispatch 9]
				set logi(nup)		[lindex $thispatch 10]
				set logi(nfade) 	[lindex $thispatch 11]
				set logi(mingap)	[lindex $thispatch 12]
				set logi(maxgap)	[lindex $thispatch 13]
				set logi(seed)		[lindex $thispatch 14]
				set logi(lor)		[RemoveCurlies [lindex $thispatch 15]]
				set logi(hir)		[RemoveCurlies [lindex $thispatch 16]]
				break
			}
			2 {
				if {$patchcnt == 1} {
					set thispatch [$f.1.ll.list get 0]
					set i 0
				} else {
					set i [$f.1.ll.list curselection]
					if {$i < 0} {
						Inf "No item selected"
						continue
					}
					set thispatch [$f.1.ll.list get $i]
				}
				set msg "Are you sure you want to delete patch $thispatch ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				catch {unset logipatch($thispatch)}
				$f.1.ll.list delete $i
				incr patchcnt -1
				if {$patchcnt <= 0} {
					catch {unset logipatch}
				} 
				catch {file delete $ppfnam}
				if {$patchcnt > 0} {
					SaveLogiPatches
				}
			}
			0 {
				break
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Bakup logistics patches to file

proc SaveLogiPatches {} {
	global logipatch evv
	if {![info exists logipatch]} {
		return
	}
	set fnam [file join $evv(URES_DIR) logipatches$evv(CDP_EXT)]
	if [catch {open $fnam "w"} zit] {
		Inf "Cannot open file $fnam to save the logisitic patch data"
		return
	}
	foreach nam [array names logipatch] {
		set line $nam
		foreach val $logipatch($nam) {
			lappend line $val
		}
		puts $zit $line
	}
	close $zit
}

#--- Grab logistics patches from file

proc LoadLogiPatches {} {
	global evv logipatch
	set fnam [file join $evv(URES_DIR) logipatches$evv(CDP_EXT)]
	if {![file exists $fnam]} {
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot open file $fnam to read the logisitic patch data"
		return
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
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
				set thisnam $item
			} else {
				lappend logipatch($thisnam) $item
			}
			incr cnt
		}
		if {$cnt != 18} {
			catch {unset logipatch($thisnam)}
			Inf "Warning: corrupted logistic patch data for patch $thisnam"
		}
	}
	close $zit
}

;#-----	Allow (flip-between) cycle-type or absolute range to be used as params to logisitics process

proc LogiRange {} {
	global logi
	if {$logi(cyccnt) == 10000} {
		.logistic.04.e  config -state normal -bd 2 -width 4
		.logistic.04.ll config -text " to "
		.logistic.04.e2 config -state normal -bd 2 -width 4
		if {[info exists logi(lastlor)]} {
			set logi(lor) $logi(lastlor)
		}
		if {[info exists logi(lasthir)]} {
			set logi(hir) $logi(lasthir)
		}
	} else {
		set logi(lastlor) $logi(lor)
		set logi(lasthir) $logi(hir)
		set logi(lor) ""
		set logi(hir) ""
		.logistic.04.e  config -width 0 -bd 0 -state disabled
		.logistic.04.ll config -text ""
		.logistic.04.e2 config -width 0 -bd 0 -state disabled
	}
}

;#-----	Output info on which srcs generate which outputs

proc OutputLogiSrcInfo {outinfo} {
	global evv
	if {![info exists outinfo] || ([llength $outinfo] <= 0)} {
		return
	}
	foreach pair $outinfo {
		set ifnam [lindex $pair 0]
		set ofnam [lindex $pair 1]
		set line [list $ofnam USES $ifnam]
		lappend lines $line
	}
	set fnam logistics_info$evv(TEXT_EXT)
	if [file exists $fnam] {
		if [catch {file delete $fnam} zit] {
			Inf "Cannot delete existing $fnam file: cannot output current logisitics process information"
			return
		}
	}
	if [catch {open $fnam "w"} zit] {
		Inf "Cannot open $fnam file to output logisitics process information"
		return
	}
	foreach line $lines {
		puts $zit $line
	}
	close $zit
	FileToWkspace $fnam 0 0 0 0 1
}

;#	WHEN WE'VE DONE ALL THIS, SET UP LEVELS, AND SPATIAL POSITIONS AND MIXFILES

#STAGE 2 PARAMETERS
#
#LATER PARAMS
#Time-step between entries + randomisation
#Range of levels
#Position
#Panning (NB problem of pan-speed as some events short, some long)
#Possibly early fading ??

# Requires mixing routine that
#	(1) Does panning in relation to dur and loudness of sound ??? (	ONLY IF WE DECIDE TO PAN)
#	(2) Creates mixfile
#	(3)	If ness splits mixfile into shorter files (if too many srcs)


########################################
# RANDOM MOTIONS IN MULTICHANNEL SPACE #
########################################

proc MchRandRotate {} {
	global rrot chlist wl pa evv pr_rrot mix_perm 
	global CDPidrun CDPmaxId prg_dun prg_abortd simple_program_messages
	global maxsamp_line done_maxsamp wstk last_outfile

	catch {unset rrot(infiles)}
	catch {unset rrot(remix)}
	if {[info exists chlist] && ([llength $chlist] >= 1)} {
		set rrot(infiles) $chlist
	} else {
		set ilist [$wl curselection]
		if {([llength $ilist] == 1) && ($ilist == -1)} {
			break
		}
		foreach i $ilist {
			lappend rrot(infiles) [$wl get $i]
		}
	}
	if {![info exists rrot(infiles)]} {
		Inf "No source soundfiles selected"
		return
	}
	foreach fnam $rrot(infiles) {
		if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) != 1)} {
			Inf "Use mono soundfiles only"
			return
		}
	}
	set rrot(infilecnt) [llength $rrot(infiles)]

	if {$rrot(infilecnt) > 995} {
		Inf "Too many input files to handle"
		return
	} elseif {$rrot(infilecnt) < 2} {
		Inf "This process should be applied to more than one input file"
		return
	}
	DeleteAllTemporaryFiles

	set rrot(tempfnam) $evv(DFLT_OUTNAME)
	set rrot(mixfnam) $evv(DFLT_OUTNAME)
	append rrot(mixfnam) 0 [GetTextfileExtension mmx]

	set f .rrot
	if [Dlg_Create $f "CREATE RANDOM ROTATIONS IN MULTICHANNEL SPACE" "set pr_rrot 0" -borderwidth $evv(SBDR)] {
		set f0  [frame $f.0] 
		set f01 [frame $f.01] 
		set f1  [frame $f.1] 
		set f2  [frame $f.2] 
		set f3  [frame $f.3] 
		set f4  [frame $f.4] 
		set f5  [frame $f.5] 
		set f6  [frame $f.6] 
		set f7  [frame $f.7] 
		set f8  [frame $f.8] 
		set f9  [frame $f.9] 
		set f10 [frame $f.10] 
		set f11 [frame $f.11] 
		set f12 [frame $f.12] 
		set f13 [frame $f.13] 
		button $f0.0 -text "Rotate Sounds" -command "set pr_rrot 1" -bg $evv(EMPH) -width 13
		button $f0.1 -text "Abandon" -command "set pr_rrot 0"
		pack $f0.0 -side left
		pack $f0.1 -side right
		pack $f0 -side top -fill x -expand true -pady 2
		button $f01.0 -text "Save Patch" -command "set pr_rrot 2"
		button $f01.1 -text "Load Patch" -command "set pr_rrot 3"
		pack $f01.0 $f01.1 -side left -padx 4
		pack $f01 -side top -pady 2
		entry $f1.e -textvariable rrot(chans) -width 8
		label $f1.ll -text "Number of output channels (3-16)"
		pack $f1.e $f1.ll -side left -padx 2 
		pack $f1 -side top -fill x -expand true -pady 2
		entry $f2.e -textvariable rrot(focus) -width 8
		label $f2.ll -text "Focus into lpskr (0 - 1)"
		pack $f2.e $f2.ll -side left -padx 2 
		pack $f2 -side top -fill x -expand true -pady 2
		entry $f3.e -textvariable rrot(minspeed) -width 8
		label $f3.ll -text "Minimum rotation speed (cycles per sec)"
		pack $f3.e $f3.ll -side left -padx 2 
		pack $f3 -side top -fill x -expand true -pady 2
		entry $f4.e -textvariable rrot(maxspeed) -width 8
		label $f4.ll -text "Maximum rotation speed (cycles per sec)"
		pack $f4.e $f4.ll -side left -padx 2 
		pack $f4 -side top -fill x -expand true -pady 2
		label $f5.ll -text "LEVEL RELATED TO SPEED" -fg $evv(SPECIAL) -width 22
		radiobutton $f5.0 -variable rrot(depth) -text "Yes" -value 1
		radiobutton $f5.1 -variable rrot(depth) -text "No" -value 0
		set rrot(depth) -1
		pack $f5.ll $f5.0 $f5.1 -side left -padx 2 
		entry $f6.e -textvariable rrot(minlevel) -width 8
		label $f6.ll -text "Minimum level (0-1)"
		pack $f6.e $f6.ll -side left -padx 2 
		pack $f6 -side top -fill x -expand true -pady 2
		entry $f7.e -textvariable rrot(maxlevel) -width 8
		label $f7.ll -text "Maximum level (0-1)"
		pack $f7.e $f7.ll -side left -padx 2 
		pack $f7 -side top -fill x -expand true -pady 2
		pack $f5 -side top -fill x -expand true -pady 2
		label $f8.ll -text "ROTATION DISTRIBUTION" -fg $evv(SPECIAL) -width 22
		radiobutton $f8.0 -variable rrot(type) -text "Clockwise" -value 1
		radiobutton $f8.1 -variable rrot(type) -text "Anticlock" -value 2
		radiobutton $f8.2 -variable rrot(type) -text "Alternate" -value 3
		radiobutton $f8.3 -variable rrot(type) -text "Random" -value 4
		set rrot(type) 0
		pack $f8.ll $f8.0 $f8.1 $f8.2 $f8.3 -side left -padx 2 
		pack $f8 -side top -fill x -expand true -pady 2
		entry $f9.e -textvariable rrot(timestep) -width 8
		label $f9.ll -text "Timestep between entries (Range 0 - 300 secs)"
		pack $f9.e $f9.ll -side left -padx 2 
		pack $f9 -side top -fill x -expand true -pady 2
		entry $f10.e -textvariable rrot(timerand) -width 8
		label $f10.ll -text "Randomisation of timesteps (Range 0 - 1)"
		pack $f10.e $f10.ll -side left -padx 2 
		pack $f10 -side top -fill x -expand true -pady 2
		entry $f11.e -textvariable rrot(ubergain) -width 8
		label $f11.ll -text "Overall gain (Range >0 - 1)"
		pack $f11.e $f11.ll -side left -padx 2 
		pack $f11 -side top -fill x -expand true -pady 2
		entry $f12.e -textvariable rrot(seed) -width 8
		label $f12.ll -text "Random seed (integer >= 1)"
		pack $f12.e $f12.ll -side left -padx 2 
		pack $f12 -side top -fill x -expand true -pady 2
		entry $f13.e -textvariable rrot(ofnam) -width 24
		label $f13.ll -text "Outfile name"
		pack $f13.ll $f13.e -side left -padx 2 
		pack $f13 -side top -pady 2
		wm resizable $f 0 0
		bind $f <Escape> {set pr_rrot 0}
		bind $f <Return> {set pr_rrot 1}
		bind $f1.e  <Down> "focus $f2.e"
		bind $f2.e  <Down> "focus $f3.e"
		bind $f3.e  <Down> "focus $f4.e"
		bind $f4.e  <Down> "focus $f6.e"
		bind $f6.e  <Down> "focus $f7.e"
		bind $f7.e  <Down> "focus $f9.e"
		bind $f9.e  <Down> "focus $f10.e"
		bind $f10.e  <Down> "focus $f11.e"
		bind $f11.e  <Down> "focus $f12.e"
		bind $f12.e  <Down> "focus $f13.e"
		bind $f13.e  <Down> "focus $f1.e"
		bind $f1.e  <Up> "focus $f13.e"
		bind $f2.e  <Up> "focus $f1.e"
		bind $f3.e  <Up> "focus $f2.e"
		bind $f4.e  <Up> "focus $f3.e"
		bind $f6.e  <Up> "focus $f4.e"
		bind $f7.e  <Up> "focus $f6.e"
		bind $f9.e  <Up> "focus $f7.e"
		bind $f10.e  <Up> "focus $f9.e"
		bind $f11.e  <Up> "focus $f10.e"
		bind $f12.e  <Up> "focus $f11.e"
		bind $f13.e  <Up> "focus $f12.e"
	}
	set rrot(ubergain) 1.0
	set pr_rrot 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_rrot $f.1.e
	while {!$finished} {
		tkwait variable pr_rrot
		switch -- $pr_rrot {
			1 -
			2 {
				if {![info exists rrot(remix)]} {
					DeleteAllTemporaryFiles
				}
				if {$rrot(chans) == 0} {
					Inf "No output channel count given"
					continue
				}
				if {![regexp {^[0-9]+$} $rrot(chans)] || ($rrot(chans) < 3) || ($rrot(chans) > 16) } {
					Inf "Invalid number of output channels (range 3-16)"
					continue
				}
				if {[string length $rrot(focus)] <= 0} {
					Inf "No focus value given"
					continue
				}
				if {![IsNumeric $rrot(focus)] || ($rrot(focus) < 0) || ($rrot(focus) > 1)} {
					Inf "Invalid focus value"
					continue
				}
				if {[string length $rrot(minspeed)] <= 0} {
					Inf "No minimum speed given"
					continue
				}
				if {![IsNumeric $rrot(minspeed)] || ($rrot(minspeed) < 0) || ($rrot(minspeed) > 64)} {
					Inf "Invalid minimum speed value"
					continue
				}
				if {[string length $rrot(maxspeed)] <= 0} {
					Inf "No maximum speed given"
					continue
				}
				if {![IsNumeric $rrot(maxspeed)] || ($rrot(maxspeed) < 0) || ($rrot(maxspeed) > 64)} {
					Inf "Invalid maximum  speed value"
					continue
				}
				if {$rrot(maxspeed) < $rrot(minspeed)} {
					set temp $rrot(maxspeed)
					set rrot(maxspeed) $rrot(minspeed)
					set rrot(minspeed) $temp
				}
				set rrot(speedrange) [expr $rrot(maxspeed) - $rrot(minspeed)]
				if {$rrot(depth) < 0} {
					Inf "Is loudness linked to rotation speed, or not ??"
					continue
				}
				if {[string length $rrot(minlevel)] <= 0} {
					Inf "No minimum level given"
					continue
				}
				if {![IsNumeric $rrot(minlevel)] || ($rrot(minlevel) < $evv(FLTERR)) || ($rrot(minlevel) > 1)} {
					Inf "Invalid minimum level value"
					continue
				}
				if {[string length $rrot(maxlevel)] <= 0} {
					Inf "No maximum level given"
					continue
				}
				if {![IsNumeric $rrot(maxlevel)] || ($rrot(maxlevel) < $evv(FLTERR)) || ($rrot(maxlevel) > 1)} {
					Inf "Invalid maximum level value"
					continue
				}
				if {$rrot(maxlevel) < $rrot(minlevel)} {
					set temp $rrot(maxlevel)
					set rrot(maxlevel) $rrot(minlevel)
					set rrot(minlevel) $temp
				}
				set rrot(levelrange) [expr $rrot(maxlevel) - $rrot(minlevel)]
				if {$rrot(type) == 0} {
					Inf "No rotation type selected"
					continue
				}
				if {[string length $rrot(seed)] <= 0} {
					Inf "Random seed value not given"
					continue
				}
				if {![regexp {^[0-9]+$} $rrot(seed)] || ($rrot(seed) < 1)} {
					Inf "Invalid random seed value"
					continue
				}
				expr srand($rrot(seed))

				if {[string length $rrot(timestep)] <= 0} {
					Inf "No timestep given"
					continue
				}
				if {![IsNumeric $rrot(timestep)] || ($rrot(timestep) < 0) || ($rrot(timestep) > 300)} {
					Inf "Invalid timestep level value"
					continue
				}
				if {[string length $rrot(timerand)] <= 0} {
					Inf "No timestep randomisation given"
					continue
				}
				if {![IsNumeric $rrot(timerand)] || ($rrot(timerand) < 0) || ($rrot(timerand) > 1)} {
					Inf "Invalid timestep randomisation value"
					continue
				}
				if {[string length $rrot(ubergain)] <= 0} {
					Inf "No overall gain given"
					continue
				}
				if {![IsNumeric $rrot(ubergain)] || ($rrot(ubergain) <= $evv(FLTERR)) || ($rrot(ubergain) > 1.0)} {
					Inf "Invalid overall gain value"
					continue
				}
				if {$pr_rrot == 2} {
					SaveRrotPatch
					continue
				}
				if {[string length $rrot(ofnam)] <= 0} {
					Inf "No output filename entered"
					continue
				}
				if {![ValidCDPRootname $rrot(ofnam)]} {
					continue
				}
				set outfnam [string tolower $rrot(ofnam)]
				append outfnam $evv(SNDFILE_EXT)
				if {[file exists $outfnam]} {
					Inf "File $outfnam already exists: please choose a different name"
					continue
				}

				if {![info exists rrot(remix)]} {

					if {$rrot(type) == 3} {			;#	IF rotation type is "alternating", randomly set initial direction
						set x [expr rand()]
						if {$x >= 0.5} {
							set rrot(clockwise) 1
						} else {
							set rrot(clockwise) 0
						}
					}

					;#	INITIALISE RANDOM SEQUENCE OF ROTATION START-POSITIONS ... ALL SOUNDS START AT SPECIFIC LOUDSPEAKER POSITION

					catch {unset rrot(chanorder)}
					RandomiseOrder $rrot(chans)
					set n 0
					while {$n < $rrot(chans)} {
						lappend rrot(chanorder) [expr $mix_perm($n) + 1]
						incr n
					}
					set permcnt 0 

					set cnt 0
					set OK 1
					catch {unset rrot(outfiles)}
					catch {unset rrot(levels)}


					;#	ROTATE EACH FILE IN TURN

					Block "ROTATING THE SOUNDS"

					foreach fnam $rrot(infiles) {

						;#	CREATE TEMP OUTFILE FILENAME

						set ofnam $rrot(tempfnam)
						append ofnam $cnt $evv(SNDFILE_EXT)
					
						;#	RANDOMLY SET SPEED

						set thisrand [expr rand()]
						set speed [expr $thisrand * $rrot(speedrange)]
						set speed [expr $speed + $rrot(minspeed)]

						;#	SET LOUDNESS (USED IN NEXT (MIX) PROCESS ... BUT MAY BE RELATED TO ROTATION SPEED)

						if {!$rrot(depth)} {			;#	Depth NOT related to speed, set a random value of loudness
							set thisrand [expr rand()]	;#	Else initial randval for speed also sets depth: 
						}								;#	...high val -> fast & close : lowval -> slow & far 
														;#	(i.e. angular velocity lower at greater distance, implying "real" velocity simil)
						set level [expr $thisrand * $rrot(levelrange)]
						set level [expr $level + $rrot(minspeed)]
						lappend rrot(levels) $level

						;#	SELECT DIRECTION (CLOCK/ANTICLOCK)

						switch -- $rrot(type) {
							1 { set rrot(clockwise) 1 }
							2 { set rrot(clockwise) 0 }
							3 { set rrot(clockwise) [expr !$rrot(clockwise)] }
							4 {
								set x [expr rand()]
								if {$x >= 0.5} {
									set rrot(clockwise) 1
								} else {
									set rrot(clockwise) 0
								}
							}
						}

						;#	SET START CHANNEL (PERMUTE ORDER AT RANDOM)

						set startchan [lindex $rrot(chanorder) $permcnt]
						incr permcnt
						if {$permcnt >= $rrot(chans)} {
							catch {unset rrot(chanorder)}
							RandomiseOrder $rrot(chans)
							set n 0
							while {$n < $rrot(chans)} {
								lappend rrot(chanorder) [expr $mix_perm($n) + 1]
								incr n
							}
							set permcnt 0 
						}

						;#	CREATE COMMANDLINE

						wm title .blocker "PLEASE WAIT:        ROTATING FILE $fnam"

						set cmd [file join $evv(CDPROGRAM_DIR) mchanpan]
						lappend cmd mchanpan 9 $fnam $ofnam $rrot(chans) $startchan $speed $rrot(focus) 
						if {!$rrot(clockwise)} {
							lappend cmd "-a"
						}
						set CDPidrun 0
						set prg_dun 0
						set prg_abortd 0
						catch {unset simple_program_messages}
						if [catch {open "|$cmd"} CDPidrun] {
							Inf "$CDPidrun : Failed to rotate file $fnam"
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
							Inf "$CDPidrun : Rotating file $fnam failed"
							set OK 0
							break
						}
						if {![file exists $ofnam]} {
							Inf "Rotating file $fnam was not created"
							set OK 0
							break
						}
						lappend rrot(outfiles) $ofnam
						incr cnt
					}
					if {!$OK} {
						DeleteAllTemporaryFiles
						UnBlock
						continue
					}
					wm title .blocker "PLEASE WAIT:        CREATING THE OUTPUT MIXFILE"
					if [catch {open $rrot(mixfnam) "w"} zit] {
						Inf "Cannot open mixfile $rrot(mixfnam) to mix the rotated sounds"
						DeleteAllTemporaryFiles
						UnBlock
						continue
					}
					set time 0.0
					set thistime $time
					set line $rrot(chans)
					puts $zit $line
					foreach fnam $rrot(outfiles) level $rrot(levels) {
						set line [list $fnam $thistime $rrot(chans)]
						set n 1
						while {$n <= $rrot(chans)} {
							set rout $n
							append rout ":" $n
							lappend line $rout $level
							incr n
						}
						puts $zit $line
						set time [expr $time + $rrot(timestep)]
						if {$rrot(timerand) > 0.0} {
							set timeoffset [expr (rand() * 2.0) - 1.0]				;#	Range -1 to +1
							set timeoffset [expr $timeoffset/2.0]					;#	Range -1/2 to +1/2
							set timeoffset [expr $timeoffset * $rrot(timerand)]		;#	Range scaled to randomisation value
							set timeoffset [expr $timeoffset * $rrot(timestep)]		;#	Offset is a fraction of timestep
							set thistime [expr $time + $timeoffset]
						} else {
							set thistime $time
						}
					}
					close $zit
				}
				set OK 1
				if {[info exists rrot(remix)]} {
					Block "REMIXING THE ROTATED FILES"
				} else {
					wm title .blocker "PLEASE WAIT:        MIXING THE ROTATED FILES"
				}
				catch {unset rrot(remix)}
				while {$OK} {
					set cmd [file join $evv(CDPROGRAM_DIR) newmix]
					lappend cmd multichan $rrot(mixfnam) $outfnam -g$rrot(ubergain)
					set CDPidrun 0
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "$CDPidrun : Failed to mix rotated files"
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
						Inf "$CDPidrun : Mixing rotated file failed"
						set OK 0
						break
					}
					if {![file exists $outfnam]} {
						Inf "Rotated files mix was not created"
						set OK 0
						break
					}
					
					wm title .blocker "PLEASE WAIT:        CHECKING MIX OUTPUT LEVEL"
					catch {unset CDPmaxId}
					catch {unset maxsamp_line}
					set done_maxsamp 0
					set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
					lappend cmd $outfnam
					lappend cmd 1		;#	1 flag added to FORCE read of maxsample
					if [catch {open "|$cmd"} CDPmaxId] {
						Inf "Finding maximum level of mix output: process failed"
						set OK 0
						break
	   				} else {
	   					fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
					}
	 				vwait done_maxsamp
					if {[info exists maxsamp_line]} {
						set rrot(maxsamp) [lindex $maxsamp_line 0]
					} else {
						Inf "Failed to find maximum level of mix output"
						set OK 0
						break
					}
					if {$rrot(maxsamp) > 0.95} {
						set msg "Mixfile has overloaded: you can reset overall gain and remix it.\n\n do a remix ???"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							set OK 0
							break
						}
						if [catch {file delete $outfnam} zit] {
							Inf "Cannot delete the existing output soundfile"
							set OK 0
							break
						}
						set rrot(remix) 1
						break
					}
					if {$OK} {
						break
					}
				}
				RrotRemixReset
				if {!$OK} {
					DeleteAllTemporaryFiles
					if {[file exists $outfnam]} {
						if [catch {file delete $outfnam} zit] {
							Inf "Cannot delete spurious output file $outfnam"
						}
					}
					UnBlock
					continue
				}
				if {[info exists rrot(remix)]} {
					UnBlock
					continue
				}
				set last_outfile $outfnam
				FileToWkspace $outfnam 0 0 0 0 1
				DeleteAllTemporaryFiles
				Inf "File $outfnam is on the workspace"
				UnBlock
				set finished 1
			}
			3 {
				LoadRrotPatch
			}
			0 {
				DeleteAllTemporaryFiles
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc MchRandDrift {} {
	Inf "MchRandDrift NOT YET WRITTEN"
}

#---- Save parameter vals from random rotations window to a named patch

proc SaveRrotPatch {} {
	global rrot pr_saverrot evv wstk rrotpatch

	set thispatch $rrot(chans)
	lappend thispatch $rrot(focus) $rrot(minspeed) $rrot(maxspeed) $rrot(depth) $rrot(minlevel) $rrot(maxlevel)
	lappend thispatch $rrot(type) $rrot(timestep) $rrot(timerand) $rrot(ubergain) $rrot(seed)

	set ppfnam [file join $evv(URES_DIR) rrotpatches$evv(CDP_EXT)]

	foreach nam [array names rrotpatch] {
		lappend patchlist $nam
	}
	set f .saverrot
	if [Dlg_Create $f "SAVE RANDOM-ROTATION PATCH" "set pr_saverrot 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.load -text "Save Patch" -command "set pr_saverrot 1" -bg $evv(EMPH)
		button $f.0.q -text "Quit" -command "set pr_saverrot 0"
		pack $f.0.load -side left
		pack $f.0.q -side right
		pack $f.0 -side top -fill x -expand true -pady 2
		frame $f.1
		label $f.1.ll -text "Patchname" 
		entry $f.1.e -textvariable rrot(patchnam) -width 24
		set rrot(patchnam) ""
		pack $f.1.e $f.1.ll -side left -pady 2
		pack $f.1 -side top -pady 2
		wm resizable $f 0 0
		bind $f <Escape> {set pr_saverrot 0}
		bind $f <Return> {set pr_saverrot 1}
	}
	set pr_saverrot 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_saverrot $f.1.e
	while {!$finished} {
		tkwait variable pr_saverrot
		switch -- $pr_saverrot {
			1 {
				if {[string length $rrot(patchnam)] <= 0} {
					Inf "No patch name entered"
					continue
				}
				if {![regexp {^[A-Za-z0-9\-\_]+$} $rrot(patchnam)]} {
					Inf "Invalid patchname (use letters, numbers, hyphens and underscores only)"
					continue
				}
				if {[info exists patchlist]} {
					set OK 1
					foreach nam $patchlist {
						if {[string match $nam $rrot(patchnam)]} {
							set msg "This name is already in use: overwrite existing patch ??"
							set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
							if {$choice == "no"} {
								set OK 0
								break
							}
						}
					}
					if {!$OK} {
						continue
					}
				}
				set rrotpatch($rrot(patchnam)) $thispatch
				if {[file exists $ppfnam]} {
					if [catch {file delete $ppfnam} zit] {
						Inf "Cannot replace existing random-rotation-patch datafile $ppfnam"
						continue
					}
				}
				SaveRrotPatches
				set finished 1
			}
			 0 {
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Load an existing random-rotation patch

proc LoadRrotPatch {} {
	global pr_loadrrot rrot rrotpatch evv

	if {![info exists rrotpatch]} {
		Inf "No random-rotation patches exist"
		return
	}
	foreach nam [array names rrotpatch] {
		lappend patchlist $nam
	}
	set ppfnam [file join $evv(URES_DIR) rrotpatches$evv(CDP_EXT)]
	set f .loadrrot
	if [Dlg_Create $f "LOAD RAND-ROTATE PATCH" "set pr_loadrrot 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.load -text "Select Patch" -command "set pr_loadrrot 1" -bg $evv(EMPH)
		button $f.0.del -text "Delete Patch" -command "set pr_loadrrot 2"
		button $f.0.q -text "Quit" -command "set pr_loadrrot 0"
		pack $f.0.load -side left
		pack $f.0.q $f.0.del -side right -padx 6
		pack $f.0 -side top -fill x -expand true -pady 2
		frame $f.1
		label $f.1.tit -text "Existing Random Rotation Patches" -fg $evv(SPECIAL)
		Scrolled_Listbox $f.1.ll -width 80 -height 24 -selectmode single
		pack $f.1.tit $f.1.ll -side top -pady 2
		pack $f.1 -side top -fill x -expand true -pady 2
		wm resizable $f 0 0
		bind $f <Escape> {set pr_loadrrot 0}
		bind $f <Return> {set pr_loadrrot 1}
	}
	$f.1.ll.list delete 0 end
	set patchcnt 0
	foreach patch $patchlist {
		$f.1.ll.list insert end $patch
		incr patchcnt
	}
	set pr_loadrrot 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_loadrrot
	while {!$finished} {
		tkwait variable pr_loadrrot
		switch -- $pr_loadrrot {
			1 {
				if {$patchcnt == 1} {
					set thispatch [$f.1.ll.list get 0]
				} else {
					set i [$f.1.ll.list curselection]
					if {$i < 0} {
						Inf "No item selected"
						continue
					}
					set thispatch [$f.1.ll.list get $i]
				}
				set thispatch $rrotpatch($thispatch)
				set rrot(chans)		[lindex $thispatch 0]
				set rrot(focus)		[lindex $thispatch 1]
				set rrot(minspeed)	[lindex $thispatch 2]
				set rrot(maxspeed)	[lindex $thispatch 3]
				set rrot(depth)		[lindex $thispatch 4]
				set rrot(minlevel)	[lindex $thispatch 5]
				set rrot(maxlevel)	[lindex $thispatch 6]
				set rrot(type)		[lindex $thispatch 7]
				set rrot(timestep)	[lindex $thispatch 8]
				set rrot(timerand)	[lindex $thispatch 9]
				set rrot(ubergain)	[lindex $thispatch 10]
				set rrot(seed) 		[lindex $thispatch 11]
				break
			}
			2 {
				if {$patchcnt == 1} {
					set thispatch [$f.1.ll.list get 0]
					set i 0
				} else {
					set i [$f.1.ll.list curselection]
					if {$i < 0} {
						Inf "No item selected"
						continue
					}
					set thispatch [$f.1.ll.list get $i]
				}
				set msg "Are you sure you want to delete patch $thispatch ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				catch {unset rrotpatch($thispatch)}
				$f.1.ll.list delete $i
				incr patchcnt -1
				if {$patchcnt <= 0} {
					catch {unset rrotpatch}
				} 
				catch {file delete $ppfnam}
				if {$patchcnt > 0} {
					SaveRrotPatches
				}
			}
			0 {
				break
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Bakup random rotation patches to file

proc SaveRrotPatches {} {
	global rrotpatch evv
	if {![info exists rrotpatch]} {
		return
	}
	set fnam [file join $evv(URES_DIR) rrotpatches$evv(CDP_EXT)]
	if [catch {open $fnam "w"} zit] {
		Inf "Cannot open file $fnam to save the random-rotation patch data"
		return
	}
	foreach nam [array names rrotpatch] {
		set line $nam
		foreach val $rrotpatch($nam) {
			lappend line $val
		}
		puts $zit $line
	}
	close $zit
}

#--- Grab random-rotation patches from file

proc LoadRrotPatches {} {
	global evv rrotpatch
	set fnam [file join $evv(URES_DIR) rrotpatches$evv(CDP_EXT)]
	if {![file exists $fnam]} {
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot open file $fnam to read the random rotation data"
		return
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
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
				set thisnam $item
			} else {
				lappend rrotpatch($thisnam) $item
			}
			incr cnt
		}
		if {$cnt != 13} {
			catch {unset rrotpatch($thisnam)}
			Inf "Warning: corrupted random-rotation patch data for patch $thisnam"
		}
	}
	close $zit
}

#------ Reset interface for remixing

proc RrotRemixReset {} {
	global rrot
	if {[info exists rrot(remix)]} {
		.rrot.0.0  config -text "Remix Sounds"
		.rrot.1.e  config -state disabled
		.rrot.2.e  config -state disabled
		.rrot.3.e  config -state disabled
		.rrot.4.e  config -state disabled
		.rrot.5.0  config -state disabled
		.rrot.5.1  config -state disabled
		.rrot.6.e  config -state disabled
		.rrot.7.e  config -state disabled
		.rrot.8.0  config -state disabled
		.rrot.8.1  config -state disabled
		.rrot.8.2  config -state disabled
		.rrot.8.3  config -state disabled
		.rrot.9.e  config -state disabled
		.rrot.10.e config -state disabled
		.rrot.11.e config -bg $evv(EMPH)
		.rrot.12.e config -state disabled
		.rrot.13.e config -state disabled
	} else {
		.rrot.0.0  config -text "Rotate Sounds"
		.rrot.1.e  config -state normal
		.rrot.2.e  config -state normal
		.rrot.3.e  config -state normal
		.rrot.4.e  config -state normal
		.rrot.5.0  config -state normal
		.rrot.5.1  config -state normal
		.rrot.6.e  config -state normal
		.rrot.7.e  config -state normal
		.rrot.8.0  config -state normal
		.rrot.8.1  config -state normal
		.rrot.8.2  config -state normal
		.rrot.8.3  config -state normal
		.rrot.9.e  config -state normal
		.rrot.10.e config -state normal
		.rrot.11.e config -bg [option get . background {}]
		.rrot.12.e config -state normal
		.rrot.13.e config -state normal
	}
}

#####################
#	COUETTE FLOW	#
#####################

#	 PARAMETER INDEXING
#	Dummy initial index (0), so that reading patches from file uses same indexing as checking parameters
#	(PI = parameter index NI = name and range index)
#
#	param			PI	NI	coufullnam						rangebot	rangetop
#	[DUMMY]			0
#	cou(dur)		1	1	DURATION							0.1			3600 
#	cou(bands)		2	2	BAND COUNT							1			16 
#	cou(threads)	3	3	THREAD COUNT						2			100 
#	cou(tstep)		4	4	TIMESTEP							1			500 
#	cou(bot)		5	5	LOWPITCH LIMIT						0			127 
#	cou(top)		6	6	HIGH PITCH LIMIT					0			127 
#	cou(twist)		7	7	TWIST FREQENCY						0			10 
#	cou(rand)		8	8	TWISTFRQ RANDOMISATION				0			1 
#	cou(warp)		9	9	TWIST WARPING						0			1 
#	cou(vamp)		10	10	WAVINESS AMPLITUDE					0			1 
#	cou(vmin)		11	11	MIN WAVINESS FRQ					0			4 
#	cou(vmax)		12	12	MAX WAVINESS FRQ					0			4 
#	cou(turb)		13	13	TURBULENCE							0			2 
#	cou(gap)		14	14	PITCH INTERVAL SEPARATING BANDS		0			12 
#	cou(minband)	15	15	MIN PITCHWIDTH OF BANDS				1			24 
#	cou(3d)			16	16	3D ORIENTATION						-1			1  

#	cou(partials1)	17	17	PARTIALS DATA						[xx]		[xx] 
#	cou(minrise1)	18	18	MIN RISE TIME						.002		.2   
#	cou(maxrise1)	19	19	MAX RISE TIME						.002		.2    
#	cou(minsus1)	20	20	MIN SUSTAIN							0			.2 
#	cou(maxsus1)	21	21	MAX SUSTAIN							0			.2 
#	cou(mindecay1)	22	22	MIN DECAYTIME						.02			2	  
#	cou(maxdecay1)	23	23	MAX DECAYTIME						.02			2	  
#	cou(speed1)		24	24	PACKET SPEED						.05			1	  
#	cou(scat1)		25	25	PACKET TIME RANDOMISATION			0			1 
#	cou(expr1)		26	26	SLOPE OF PACKET ONSET				.25			4   
#	cou(expd1)		27	27	SLOPE OF PACKET DECAY				.25			4   
#	cou(pscat1)		28	28	PITCH-SCATTERING OF PACKETS			0			1 
#	cou(ascat1)		29	29	AMPLITUDE SCATTERING OF PACKETS		0			1 
#	cou(octav1)		30	30	OCTAVIATION OF PACKETS				0			1 
#	cou(bend1)		31	31	PITCHBEND OF PACKETS				0			24 	

#-------------------------------------------------------------------------------
#	param			PI	param			PI	param			PI	

#	cou(partials2)	32	cou(partials3)	47	cou(partials4)	62	(USE NAMES AND RANGES AS ABOVE)
#	cou(minrise2)	33	cou(minrise3)	48	cou(minrise4)	63
#	cou(maxrise2)	34	cou(maxrise3)	49	cou(maxrise4)	64
#	cou(minsus2)	35	cou(minsus3)	50	cou(minsus4)	65
#	cou(maxsus2)	36	cou(maxsus3)	51	cou(maxsus4)	66
#	cou(mindecay2)	37	cou(mindecay3)	52	cou(mindecay4)	67
#	cou(maxdecay2)	38	cou(maxdecay3)	53	cou(maxdecay4)	68
#	cou(speed2)		39	cou(speed3)		54	cou(speed4)		69
#	cou(scat2)		40	cou(scat3)		55	cou(scat4)		70
#	cou(expr2)		41	cou(expr3)		56	cou(expr4)		71
#	cou(expd2)		42	cou(expd3)		57	cou(expd4)		72
#	cou(pscat2)		43	cou(pscat3)		58	cou(pscat4)		73
#	cou(ascat2)		44	cou(ascat3)		59	cou(ascat4)		74
#	cou(octav2)		45	cou(octav3)		60	cou(octav4)		75
#	cou(bend2)		46	cou(bend3)		61	cou(bend4)		76

#-------------------------------------------------------------------------------
#	param			PI	NI		rangebot	rangetop

#	cou(seed)		77	32			0		256 	 
#	cou(rot1)		78	33			0		4
#	cou(rot2)		79
#	cou(rot3)		80
#	cou(rot4)		81
#	cou(rstt1)		82
#	cou(rstt2)		83
#	cou(rstt3)		84
#	cou(rstt4)		85
#	cou(rinc1)		86
#	cou(rinc2)		87
#	cou(rinc3)		88
#	cou(rinc4)		89

#	cou(chans)		90
#	cou(fx)			91
#	cou(sz)			92
#	cou(echos)		93
#	cou(maxrev)		94
#	cou(prev)		95

#	cou(ratio)		97
#	cou(rfstep)		98
#	cou(rfrand)		99
#	cou(rfoff)		100
#	cou(rfend)		101
#	cou(rftyp)		102
#	cou(rfnot)		103

#	cou(bal1)		104
#	cou(bal2)		105
#	cou(bal3)		106
#	cou(bal4)		107
#
proc CouetteFlow {} {
	global evv pa wstk pr_couette readonlyfg readonlybg cou CDPidrun prg_dun prg_abortd simple_program_messages
	global CDPmaxId done_maxsamp maxsamp_line chlist

	if {![FindCouettePartialsFiles]} {
		return
	}
	set cou(dump) 0
	set cou(srate)	44100.0
	set cou(activebands) 0
	set cou(nar) 1
	catch {unset cou(bandsset)}

	set cou(samedata) 0
	set cou(lastkpcd) 0
	set cou(lastonly) -1	;#	Indicates there are no previous runs in this session

	set counam [list XX dur bands threads tstep bot top twist rand warp vamp vmin vmax turb gap minband 3d]
	lappend counam partials1 minrise1 maxrise1 minsus1 maxsus1 mindecay1 maxdecay1 speed1 scat1 expr1 expd1 pscat1 ascat1 octav1 bend1
	lappend counam partials2 minrise2 maxrise2 minsus2 maxsus2 mindecay2 maxdecay2 speed2 scat2 expr2 expd2 pscat2 ascat2 octav2 bend2
	lappend counam partials3 minrise3 maxrise3 minsus3 maxsus3 mindecay3 maxdecay3 speed3 scat3 expr3 expd3 pscat3 ascat3 octav3 bend3
	lappend counam partials4 minrise4 maxrise4 minsus4 maxsus4 mindecay4 maxdecay4 speed4 scat4 expr4 expd4 pscat4 ascat4 octav4 bend4
	lappend counam seed rot1 rot2 rot3 rot4 rstt1 rstt2 rstt3 rstt4 rinc1 rinc2 rinc3 rinc4 chans fx

	set coufullnam [list XX "DURATION" "BAND COUNT" "THREAD COUNT" "TIMESTEP" "LOWPITCH LIMIT" "HIGH PITCH LIMIT" "TWIST FREQENCY" "TWISTFRQ RANDOMISATION" "TWIST WARPING"]
	lappend coufullnam "WAVINESS AMPLITUDE" "MIN WAVINESS FRQ" "MAX WAVINESS FRQ" "TURBULENCE"
	lappend coufullnam "PITCH INTERVAL SEPARATING BANDS" "MIN PITCHWIDTH OF BANDS" "3D ORIENTATION"
	lappend coufullnam "PARTIALS DATA" "MIN RISE TIME" "MAX RISE TIME" "MIN SUSTAIN" "MAX SUSTAIN" "MIN DECAYTIME" "MAX DECAYTIME" 
	lappend coufullnam "PACKET SPEED" "PACKET TIME RANDOMISATION" "SLOPE OF PACKET ONSET" "SLOPE OF PACKET DECAY"
	lappend coufullnam "PITCH-SCATTERING OF PACKETS" "LOUDNESS SCATTERING OF PACKETS" "LOWER OCTAVE REINFORCEMENT" "PITCHBEND OF PACKETS"

	set cou(courbot) [list xx 0.1  1  2   1   24 24 0  0 0	 0 0 0 0 0 1  -1 xx .002 .002 0  0  .02 .02 .05 0 .25 .25 0 0 0 0	 0	 0]	;#	Range limits for variable testing
	set cou(courtop) [list xx 3600 16 100 500 96 96 10 1 0.5 1 4 4 2 12 24 1 xx .2   .2   .2 .2  2	2	1	1 4   4   1 1 1 24   256 4]

	if {![info exists cou(paramfiles7)]} {
		GetCouParamFiles
	}

	set sofnam $evv(DFLT_OUTNAME)
	set refocfnam $sofnam
	append refocfnam "000"
	set revfnam $evv(MACH_OUTFNAME)

	set f .couette
	if [Dlg_Create $f "BANDED FLOW" "set pr_couette 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		frame $f.0.f0
		button $f.0.f0.h -text "Help" -command "CouetteHelp" -bg $evv(HELP)
		button $f.0.f0.ff -text "Create Flow" -command "set pr_couette 1" -bg $evv(EMPH) -width 20
		pack $f.0.f0.h $f.0.f0.ff -side left -padx 2
		frame $f.0.f1
		button $f.0.f1.uu -text "Packet Presets" -command "UnsetFineVariation"
		label $f.0.f1.tit -text "PATCHES"
		button $f.0.f1.ss -text "Save" -command "SaveCouettePatch"		-width 5
		button $f.0.f1.ll -text "Load" -command "GetCouettePatch 0"		-width 5
		button $f.0.f1.dd -text "Delete" -command "GetCouettePatch 1"	-width 5
		button $f.0.f1.cc -text "Clear" -command "ClearCouettePatch 0"	-width 5
		button $f.0.f1.st -text "Startv" -command "CouetteEndState 1"	-width 5
		button $f.0.f1.ee -text "Endval" -command  "CouetteEndState 0"	-width 5
		button $f.0.f1.mm -text "Merge" -command "MergeCouettePatches"	-width 5
		button $f.0.f1.ts -text "Timewp" -command "CouTimewarp"			-width 5
		pack $f.0.f1.uu $f.0.f1.tit $f.0.f1.ss $f.0.f1.ll $f.0.f1.dd $f.0.f1.cc $f.0.f1.st $f.0.f1.ee $f.0.f1.mm $f.0.f1.ts -side left -padx 2 
		frame $f.0.f2
		label $f.0.f2.ll -text "Output filename"
		entry $f.0.f2.e -textvariable cou(ofnam) -width 20
		pack $f.0.f2.ll $f.0.f2.e -side left -padx 2

		button $f.0.play -text "" -command {} -bd 0 -width 12

		frame $f.0.f3
		label $f.0.f3.ss -text "Also save ..... "
		frame $f.0.f3.ch
		frame $f.0.f3.ch.1
		frame $f.0.f3.ch.2
		checkbutton $f.0.f3.ch.1.th -text "Threads" -variable cou(kpth) -width 12
		checkbutton $f.0.f3.ch.1.tr -text "Rotated threads" -variable cou(kprth) -width 12
		checkbutton $f.0.f3.ch.2.tm -text "Threads mix" -variable cou(kpmix)
		checkbutton $f.0.f3.ch.2.cd -text "Control data" -variable cou(kpcd)
		pack $f.0.f3.ch.1.th $f.0.f3.ch.1.tr -side left 
		pack $f.0.f3.ch.2.tm $f.0.f3.ch.2.cd -side left 
		pack $f.0.f3.ch.1 $f.0.f3.ch.2 -side top
		pack $f.0.f3.ss $f.0.f3.ch -side left 
		checkbutton $f.0.ch -variable cou(input) -text "Input control data"
		button $f.0.qq -text "Quit" -command "set pr_couette 0"
		pack $f.0.f0 $f.0.f1 $f.0.f2 $f.0.play $f.0.f3 -side left -padx 6
		pack $f.0.qq $f.0.ch -side right -padx 6
		pack $f.0 -side top -fill x -expand true -pady 2
		frame $f.1
		set flux [frame $f.1.0]
		set snds [frame $f.1.1]
		set partials [frame $f.1.2]

		label $flux.0 -text "BANDING" -fg $evv(SPECIAL)
		pack $flux.0 -side top -pady 2 -anchor w

		label $flux.dum -text "(Cntrl-Clk box: list brkfiles : Command-Clk See file)"
		pack $flux.dum -side top -anchor w

		frame $flux.1
		entry $flux.1.e -textvariable cou(dur) -width 12
		label $flux.1.ll -text Duration
		pack $flux.1.e $flux.1.ll -side left -padx 2 -fill x -expand true
		pack $flux.1 -side top -pady 2 -anchor w

		frame $flux.2
		entry $flux.2.e -textvariable cou(bands) -width 12
		label $flux.2.ll -text "Number of bands"
		pack $flux.2.e $flux.2.ll -side left -padx 2 
		pack $flux.2 -side top -pady 2 -anchor w

		frame $flux.3
		entry $flux.3.e -textvariable cou(threads) -width 12
		label $flux.3.ll -text "Number of threads"
		pack $flux.3.e $flux.3.ll -side left -padx 2 
		pack $flux.3 -side top -pady 2 -anchor w

		frame $flux.4
		entry $flux.4.e -textvariable cou(tstep) -width 12
		label $flux.4.ll -text "Timestep between data-points (mS)"
		pack $flux.4.e $flux.4.ll -side left -padx 2 
		pack $flux.4 -side top -pady 2 -anchor w

		frame $flux.5
		entry $flux.5.e -textvariable cou(bot) -width 12
		label $flux.5.ll -text "Bottom of pitchrange (MIDI)"
		pack $flux.5.e $flux.5.ll -side left -padx 2  
		pack $flux.5 -side top -pady 2 -anchor w

		frame $flux.6
		entry $flux.6.e -textvariable cou(top) -width 12
		label $flux.6.ll -text "Top of pitchrange (MIDI)"
		pack $flux.6.e $flux.6.ll -side left -padx 2  
		pack $flux.6 -side top -pady 2 -anchor w

		frame $flux.7
		entry $flux.7.e -textvariable cou(twist) -width 12
		label $flux.7.ll -text "Twist rotation speed (Hz)"
		pack $flux.7.e $flux.7.ll -side left -padx 2  
		pack $flux.7 -side top -pady 2 -anchor w

		frame $flux.8
		entry $flux.8.e -textvariable cou(rand) -width 12
		label $flux.8.ll -text "Speed randomisation (0-1)"
		pack $flux.8.e $flux.8.ll -side left -padx 2  
		pack $flux.8 -side top -pady 2 -anchor w

		frame $flux.9
		entry $flux.9.e -textvariable cou(warp) -width 12
		label $flux.9.ll -text "Thread cycle warping (0-1)"
		pack $flux.9.e $flux.9.ll -side left -padx 2  
		pack $flux.9 -side top -pady 2 -anchor w

		frame $flux.10
		entry $flux.10.e -textvariable cou(vamp) -width 12
		label $flux.10.ll -text "Amplitude of band waviness (0-1)"
		pack $flux.10.e $flux.10.ll -side left -padx 2  
		pack $flux.10 -side top -pady 2 -anchor w

		frame $flux.11
		entry $flux.11.e -textvariable cou(vmin) -width 12
		label $flux.11.ll -text "Minimum waviness frq"
		pack $flux.11.e $flux.11.ll -side left -padx 2  
		pack $flux.11 -side top -pady 2 -anchor w

		frame $flux.12
		entry $flux.12.e -textvariable cou(vmax) -width 12
		label $flux.12.ll -text "Maximum waviness frq" 
		pack $flux.12.e $flux.12.ll -side left -padx 2  
		pack $flux.12 -side top -pady 2 -anchor w

		frame $flux.13
		entry $flux.13.e -textvariable cou(turb) -width 12
		label $flux.13.ll -text "Turbulence (0-2)" 
		pack $flux.13.e $flux.13.ll -side left -padx 2  
		pack $flux.13 -side top -pady 2 -anchor w

		frame $flux.14
		entry $flux.14.e -textvariable cou(gap) -width 12
		label $flux.14.ll -text "Min pitch interval between bands"
		pack $flux.14.e $flux.14.ll -side left -padx 2  
		pack $flux.14 -side top -pady 2 -anchor w

		frame $flux.15
		entry $flux.15.e -textvariable cou(minband) -width 12
		label $flux.15.ll -text "Minimum pitch width of bands"
		pack $flux.15.e $flux.15.ll -side left -padx 2  
		pack $flux.15 -side top -pady 2 -anchor w

		frame $flux.16
		entry $flux.16.e -textvariable cou(seed) -width 12
		label $flux.16.ll -text "Random seed (0 = none: vals 1-256)"
		pack $flux.16.e $flux.16.ll -side left -padx 2 -anchor w 
		pack $flux.16 -side top -pady 2 -anchor w

		set cou(3d)	-2

		label $flux.rr -text "RADIAL DISTANCE CUES" -fg $evv(SPECIAL)
		pack $flux.rr -side top -pady 2 -anchor w

		frame $flux.17
		radiobutton $flux.17.1 -variable cou(3d) -text "None" -value 0
		radiobutton $flux.17.2 -variable cou(3d) -text "Lowest UP at front" -value 1
		radiobutton $flux.17.3 -variable cou(3d) -text "DOWN" -value -1
		pack $flux.17.1 $flux.17.2 $flux.17.3 -side left -padx 2  
		pack $flux.17 -side top -pady 2 -anchor w

		frame $flux.18
		entry $flux.18.e -textvariable cou(fx) -width 8
		label $flux.18.ll -text "Reverb-in-mix range (0 - 1)"
		pack $flux.18.e $flux.18.ll -side left -padx 2 -anchor w 
		pack $flux.18 -side top -pady 2 -anchor w

		frame $flux.19
		entry $flux.19.e -textvariable cou(sz) -width 8
		label $flux.19.ll -text "... stadium size (0.01 to 1)"
		pack $flux.19.e $flux.19.ll -side left -padx 2 -anchor w 
		pack $flux.19 -side top -pady 2 -anchor w

		frame $flux.20
		entry $flux.20.e -textvariable cou(echos) -width 8
		label $flux.20.ll -text "... echo count (Range 8 - 1000)"
		pack $flux.20.e $flux.20.ll -side left -padx 2 -anchor w 
		pack $flux.20 -side top -pady 2 -anchor w

		frame $flux.21
		entry $flux.21.e -textvariable cou(maxrev) -width 8
		label $flux.21.ll -text "Max reverb in sound"
		pack $flux.21.e $flux.21.ll -side left -padx 2 -anchor w 
		pack $flux.21 -side top -pady 2 -anchor w

		frame $flux.22
		entry $flux.22.e -textvariable cou(prev) -width 8
		label $flux.22.ll -text "Partials in reverbd sound"
		pack $flux.22.e $flux.22.ll -side left -padx 2 -anchor w 
		pack $flux.22 -side top -pady 2 -anchor w

		frame $flux.23
		label $flux.23.ll -text "PATCHFILES "
		button $flux.23.bt -text "Grab to Wksp" -command CouPatchFilesToWkspace -width 12
		button $flux.23.bh -text "See on Wksp" -command CouHilitePatchFiles -width 12
		button $flux.23.br -text "Refresh" -command GetCouParamFiles -width 10
		pack $flux.23.ll $flux.23.bt $flux.23.bh $flux.23.br -side left -padx 2 -anchor w 
		pack $flux.23 -side top -pady 2 -anchor w

		label $snds.0 -text "PACKETS" -fg $evv(SPECIAL)
		pack $snds.0 -side top -pady 2 -anchor w

		frame $snds.00
		label $snds.00.1 -text "BAND 1" -width 16
		label $snds.00.2 -text "BAND 2" -width 8
		radiobutton $snds.00.2b -text Copy  -variable cou(cop2) -value 1 -width 5 -command "CopyPacketParams 2"
		label $snds.00.3 -text "BAND 3" -width 8
		radiobutton $snds.00.3b -text Copy  -variable cou(cop3) -value 1 -width 5 -command "CopyPacketParams 3"
		label $snds.00.4 -text "BAND 4" -width 8
		radiobutton $snds.00.4b -text Copy  -variable cou(cop4) -value 1 -width 5 -command "CopyPacketParams 4"
		pack  $snds.00.1 $snds.00.2 $snds.00.2b $snds.00.3 $snds.00.3b $snds.00.4 $snds.00.4b -side left -fill x -expand true 
		pack $snds.00 -side top -pady 2 -anchor w

		frame $snds.000
		radiobutton $snds.000.only1  -text Solo  -variable cou(only)  -value 1 -width 3 -command "IgnoreRefocus 1"
		radiobutton $snds.000.clear1 -text Clear -variable cou(clear) -value 1 -command "ClearCouettePatch 1" -width 3
		radiobutton $snds.000.only2  -text Solo  -variable cou(only)  -value 2 -width 3 -command "IgnoreRefocus 1"
		radiobutton $snds.000.clear2 -text Clear -variable cou(clear) -value 2 -command "ClearCouettePatch 2" -width 4
		radiobutton $snds.000.only3  -text Solo  -variable cou(only)  -value 3 -width 3 -command "IgnoreRefocus 1"
		radiobutton $snds.000.clear3 -text Clear -variable cou(clear) -value 3 -command "ClearCouettePatch 3" -width 3
		radiobutton $snds.000.only4  -text Solo  -variable cou(only)  -value 4 -width 3 -command "IgnoreRefocus 1"
		radiobutton $snds.000.clear4 -text Clear -variable cou(clear) -value 4 -command "ClearCouettePatch 4" -width 4
		radiobutton $snds.000.only0  -text Tutti -variable cou(only)  -value 0 -width 3 -command "IgnoreRefocus 0"
		radiobutton $snds.000.only5  -text "+Bands" -variable cou(only)  -value 5 -width 5 -command "IgnoreRefocus 2"
		pack $snds.000.only1  $snds.000.clear1 $snds.000.only2 $snds.000.clear2 $snds.000.only3 $snds.000.clear3 \
			$snds.000.only4 $snds.000.clear4 $snds.000.only0 $snds.000.only5 -side left -padx 2
		pack $snds.000 -side top -pady 2 -anchor w

		frame $snds.1
		entry $snds.1.e1 -textvariable cou(partials1) -width 16 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg 
		entry $snds.1.e2 -textvariable cou(partials2) -width 16 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg 
		entry $snds.1.e3 -textvariable cou(partials3) -width 16 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg 
		entry $snds.1.e4 -textvariable cou(partials4) -width 16 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg 
		label $snds.1.ll -text "Partials Files (from list)"
		radiobutton $snds.1.cc -variable cou(pclear) -text "Clear" -value 1 -command ClearPartialFilesEntries

		pack $snds.1.e1 $snds.1.e2 $snds.1.e3 $snds.1.e4 $snds.1.ll $snds.1.cc -side left -padx 2  
		pack $snds.1 -side top -pady 2 -anchor w

		frame $snds.2
		entry $snds.2.e1 -textvariable cou(minrise1) -width 16
		entry $snds.2.e2 -textvariable cou(minrise2) -width 16
		entry $snds.2.e3 -textvariable cou(minrise3) -width 16
		entry $snds.2.e4 -textvariable cou(minrise4) -width 16
		label $snds.2.ll -text "Minimum risetime of packets"
		pack $snds.2.e1 $snds.2.e2 $snds.2.e3 $snds.2.e4 $snds.2.ll -side left -padx 2  
		pack $snds.2 -side top -pady 2 -anchor w

		frame $snds.3
		entry $snds.3.e1 -textvariable cou(maxrise1) -width 16
		entry $snds.3.e2 -textvariable cou(maxrise2) -width 16
		entry $snds.3.e3 -textvariable cou(maxrise3) -width 16
		entry $snds.3.e4 -textvariable cou(maxrise4) -width 16
		label $snds.3.ll -text "Maximum risetime of packets"
		pack $snds.3.e1 $snds.3.e2 $snds.3.e3 $snds.3.e4 $snds.3.ll -side left -padx 2  
		pack $snds.3 -side top -pady 2 -anchor w

		frame $snds.4
		entry $snds.4.e1 -textvariable cou(minsus1) -width 16
		entry $snds.4.e2 -textvariable cou(minsus2) -width 16
		entry $snds.4.e3 -textvariable cou(minsus3) -width 16
		entry $snds.4.e4 -textvariable cou(minsus4) -width 16
		label $snds.4.ll -text "Minimum sustain of packets"
		pack $snds.4.e1 $snds.4.e2 $snds.4.e3 $snds.4.e4 $snds.4.ll -side left -padx 2  
		pack $snds.4 -side top -pady 2 -anchor w

		frame $snds.5
		entry $snds.5.e1 -textvariable cou(maxsus1) -width 16
		entry $snds.5.e2 -textvariable cou(maxsus2) -width 16
		entry $snds.5.e3 -textvariable cou(maxsus3) -width 16
		entry $snds.5.e4 -textvariable cou(maxsus4) -width 16
		label $snds.5.ll -text "Maximum sustain of packets"
		pack $snds.5.e1 $snds.5.e2 $snds.5.e3 $snds.5.e4 $snds.5.ll -side left -padx 2  
		pack $snds.5 -side top -pady 2 -anchor w

		frame $snds.6
		entry $snds.6.e1 -textvariable cou(mindecay1) -width 16
		entry $snds.6.e2 -textvariable cou(mindecay2) -width 16
		entry $snds.6.e3 -textvariable cou(mindecay3) -width 16
		entry $snds.6.e4 -textvariable cou(mindecay4) -width 16
		label $snds.6.ll -text "Minimum decaytime of packets"
		pack $snds.6.e1 $snds.6.e2 $snds.6.e3 $snds.6.e4 $snds.6.ll -side left -padx 2  
		pack $snds.6 -side top -pady 2 -anchor w

		frame $snds.7
		entry $snds.7.e1 -textvariable cou(maxdecay1) -width 16
		entry $snds.7.e2 -textvariable cou(maxdecay2) -width 16
		entry $snds.7.e3 -textvariable cou(maxdecay3) -width 16
		entry $snds.7.e4 -textvariable cou(maxdecay4) -width 16
		label $snds.7.ll -text "Maximum decaytime of packets"
		pack $snds.7.e1 $snds.7.e2 $snds.7.e3 $snds.7.e4 $snds.7.ll -side left -padx 2  
		pack $snds.7 -side top -pady 2 -anchor w

		frame $snds.8
		entry $snds.8.e1 -textvariable cou(speed1) -width 16
		entry $snds.8.e2 -textvariable cou(speed2) -width 16
		entry $snds.8.e3 -textvariable cou(speed3) -width 16
		entry $snds.8.e4 -textvariable cou(speed4) -width 16
		label $snds.8.ll -text "Average time between packets"
		pack $snds.8.e1 $snds.8.e2 $snds.8.e3 $snds.8.e4 $snds.8.ll -side left -padx 2  
		pack $snds.8 -side top -pady 2 -anchor w

		frame $snds.9
		entry $snds.9.e1 -textvariable cou(scat1) -width 16
		entry $snds.9.e2 -textvariable cou(scat2) -width 16
		entry $snds.9.e3 -textvariable cou(scat3) -width 16
		entry $snds.9.e4 -textvariable cou(scat4) -width 16
		label $snds.9.ll -text "Packet time randomisation (0-1)"
		pack $snds.9.e1 $snds.9.e2 $snds.9.e3 $snds.9.e4 $snds.9.ll -side left -padx 2  
		pack $snds.9 -side top -pady 2 -anchor w

		frame $snds.10
		entry $snds.10.e1 -textvariable cou(expr1) -width 16
		entry $snds.10.e2 -textvariable cou(expr2) -width 16
		entry $snds.10.e3 -textvariable cou(expr3) -width 16
		entry $snds.10.e4 -textvariable cou(expr4) -width 16
		label $snds.10.ll -text "Attack slope (.25 to 4)"
		pack $snds.10.e1 $snds.10.e2 $snds.10.e3 $snds.10.e4 $snds.10.ll -side left -padx 2  
		pack $snds.10 -side top -pady 2 -anchor w

		frame $snds.11
		entry $snds.11.e1 -textvariable cou(expd1) -width 16
		entry $snds.11.e2 -textvariable cou(expd2) -width 16
		entry $snds.11.e3 -textvariable cou(expd3) -width 16
		entry $snds.11.e4 -textvariable cou(expd4) -width 16
		label $snds.11.ll -text "Decay slope (.25 to 4)"
		pack $snds.11.e1 $snds.11.e2 $snds.11.e3 $snds.11.e4 $snds.11.ll -side left -padx 2  
		pack $snds.11 -side top -pady 2 -anchor w

		frame $snds.12
		entry $snds.12.e1 -textvariable cou(pscat1) -width 16
		entry $snds.12.e2 -textvariable cou(pscat2) -width 16
		entry $snds.12.e3 -textvariable cou(pscat3) -width 16
		entry $snds.12.e4 -textvariable cou(pscat4) -width 16
		label $snds.12.ll -text "Pitch scattering (0-1)"
		pack $snds.12.e1 $snds.12.e2 $snds.12.e3 $snds.12.e4 $snds.12.ll -side left -padx 2  
		pack $snds.12 -side top -pady 2 -anchor w

		frame $snds.13
		entry $snds.13.e1 -textvariable cou(ascat1) -width 16
		entry $snds.13.e2 -textvariable cou(ascat2) -width 16
		entry $snds.13.e3 -textvariable cou(ascat3) -width 16
		entry $snds.13.e4 -textvariable cou(ascat4) -width 16
		label $snds.13.ll -text "Loudness scattering (0-1)"
		pack $snds.13.e1 $snds.13.e2 $snds.13.e3 $snds.13.e4 $snds.13.ll -side left -padx 2  
		pack $snds.13 -side top -pady 2 -anchor w

		frame $snds.14
		entry $snds.14.e1 -textvariable cou(octav1) -width 16
		entry $snds.14.e2 -textvariable cou(octav2) -width 16
		entry $snds.14.e3 -textvariable cou(octav3) -width 16
		entry $snds.14.e4 -textvariable cou(octav4) -width 16
		label $snds.14.ll -text "Lower octave reinforcement (0-1)"
		pack $snds.14.e1 $snds.14.e2 $snds.14.e3 $snds.14.e4 $snds.14.ll -side left -padx 2  
		pack $snds.14 -side top -pady 2 -anchor w

		frame $snds.15
		entry $snds.15.e1 -textvariable cou(bend1) -width 16
		entry $snds.15.e2 -textvariable cou(bend2) -width 16
		entry $snds.15.e3 -textvariable cou(bend3) -width 16
		entry $snds.15.e4 -textvariable cou(bend4) -width 16
		label $snds.15.ll -text "Pitch bending (0-1)"
		pack $snds.15.e1 $snds.15.e2 $snds.15.e3 $snds.15.e4 $snds.15.ll -side left -padx 2  
		pack $snds.15 -side top -pady 2 -anchor w

		label $snds.rr -text "ANGULAR ROTATION" -fg $evv(SPECIAL)
		pack $snds.rr -side top -pady 2 -anchor w

		frame $snds.rrc
		entry $snds.rrc.e -textvariable cou(chans) -width 8
		label $snds.rrc.ll -text "Output channel count"
		pack $snds.rrc.e $snds.rrc.ll -side left -padx 2
		pack $snds.rrc -side top -pady 2 -anchor w

		frame $snds.16
		entry $snds.16.e1 -textvariable cou(rot1) -width 16
		entry $snds.16.e2 -textvariable cou(rot2) -width 16
		entry $snds.16.e3 -textvariable cou(rot3) -width 16
		entry $snds.16.e4 -textvariable cou(rot4) -width 16
		label $snds.16.ll -text "Rotation speed"
		pack $snds.16.e1 $snds.16.e2 $snds.16.e3 $snds.16.e4 $snds.16.ll -side left -padx 2
		pack $snds.16 -side top -pady 2 -anchor w

		frame $snds.17
		entry $snds.17.e1 -textvariable cou(rstt1) -width 16
		entry $snds.17.e2 -textvariable cou(rstt2) -width 16
		entry $snds.17.e3 -textvariable cou(rstt3) -width 16
		entry $snds.17.e4 -textvariable cou(rstt4) -width 16
		label $snds.17.ll -text "Rotation StartChan (lowest thread)"
		pack $snds.17.e1 $snds.17.e2 $snds.17.e3 $snds.17.e4 $snds.17.ll -side left -padx 2
		pack $snds.17 -side top -pady 2 -anchor w

		frame $snds.18
		entry $snds.18.e1 -textvariable cou(rinc1) -width 16
		entry $snds.18.e2 -textvariable cou(rinc2) -width 16
		entry $snds.18.e3 -textvariable cou(rinc3) -width 16
		entry $snds.18.e4 -textvariable cou(rinc4) -width 16
		label $snds.18.ll -text "Rotation StartChan Offset-per-thread"
		pack $snds.18.e1 $snds.18.e2 $snds.18.e3 $snds.18.e4 $snds.18.ll -side left -padx 2
		pack $snds.18 -side top -pady 2 -anchor w

		label $snds.bb -text "BAND BALANCE" -fg $evv(SPECIAL)
		pack $snds.bb -side top -pady 2 -anchor w

		frame $snds.19
		entry $snds.19.e1 -textvariable cou(bal1) -width 16
		entry $snds.19.e2 -textvariable cou(bal2) -width 16
		entry $snds.19.e3 -textvariable cou(bal3) -width 16
		entry $snds.19.e4 -textvariable cou(bal4) -width 16
		label $snds.19.ll -text "Mix balance"
		pack $snds.19.e1 $snds.19.e2 $snds.19.e3 $snds.19.e4 $snds.19.ll -side left -padx 2
		pack $snds.19 -side top -pady 2 -anchor w


		frame $partials.ll
		label $partials.ll.ll	-text "PARTIALS FILES (click-select) FOR BAND" -fg $evv(SPECIAL)
		radiobutton $partials.ll.b1 -variable cou(which) -text 1 -value 1 -command GetCouPartialsFileX
		radiobutton $partials.ll.b2 -variable cou(which) -text 2 -value 2 -command GetCouPartialsFileX
		radiobutton $partials.ll.b3 -variable cou(which) -text 3 -value 3 -command GetCouPartialsFileX
		radiobutton $partials.ll.b4 -variable cou(which) -text 4 -value 4 -command GetCouPartialsFileX
		radiobutton $partials.ll.cc -variable cou(which) -text "See" -value 0
		pack $partials.ll.ll $partials.ll.b1 $partials.ll.b2 $partials.ll.b3 $partials.ll.b4 $partials.ll.cc -side left
		set cou(parlist) [Scrolled_Listbox $partials.pp -width 60 -height 24 -selectmode single]
		bind $cou(parlist) <ButtonRelease> {GetCouPartialsFile %y}

		frame $partials.ff
		frame $partials.ff.ll
		label $partials.ff.ll.ll -text "BAND FOCUS SHIFTING" -fg $evv(SPECIAL)
		checkbutton $partials.ff.ll.ch -variable cou(refocus) -command CouDoRefocus
		label $partials.ff.ll.l2 -text "IGNORED FOR SINGLE BAND" -fg red
		pack $partials.ff.ll.ll $partials.ff.ll.ch $partials.ff.ll.l2 -side left
		pack $partials.ff.ll -side top -pady 2 -anchor w

		frame $partials.ff.1
		entry $partials.ff.1.e -textvariable cou(ratio) -width 8
		label $partials.ff.1.ll -text "Focusing ratio (>1)"
		pack $partials.ff.1.e $partials.ff.1.ll -side left -padx 2 -anchor w 
		pack $partials.ff.1 -side top -pady 2 -anchor w

		frame $partials.ff.2
		entry $partials.ff.2.e -textvariable cou(rfstep) -width 8
		label $partials.ff.2.ll -text "Refocusing timestep"
		pack $partials.ff.2.e $partials.ff.2.ll -side left -padx 2 -anchor w 
		pack $partials.ff.2 -side top -pady 2 -anchor w

		frame $partials.ff.3
		entry $partials.ff.3.e -textvariable cou(rfrand) -width 8
		label $partials.ff.3.ll -text "Randomisation of timestep"
		pack $partials.ff.3.e $partials.ff.3.ll -side left -padx 2 -anchor w 
		pack $partials.ff.3 -side top -pady 2 -anchor w

		frame $partials.ff.4
		entry $partials.ff.4.e -textvariable cou(rfoff) -width 8
		label $partials.ff.4.ll -text "Refocusing offset"
		pack $partials.ff.4.e $partials.ff.4.ll -side left -padx 2 -anchor w 
		pack $partials.ff.4 -side top -pady 2 -anchor w

		frame $partials.ff.5
		entry $partials.ff.5.e -textvariable cou(rfend) -width 8
		label $partials.ff.5.ll -text "Refocusing end"
		pack $partials.ff.5.e $partials.ff.5.ll -side left -padx 2 -anchor w 
		pack $partials.ff.5 -side top -pady 2 -anchor w

		frame $partials.ff.6
		entry $partials.ff.6.e -textvariable cou(rftyp) -width 8
		label $partials.ff.6.ll -text "Refocusing type"
		pack $partials.ff.6.e $partials.ff.6.ll -side left -padx 2 -anchor w 
		pack $partials.ff.6 -side top -pady 2 -anchor w

		frame $partials.ff.7
		checkbutton $partials.ff.7.ch -variable cou(rfnot)
		label $partials.ff.7.ll -text "Don't emphasize top band"
		pack $partials.ff.7.ch $partials.ff.7.ll -side left -padx 2 -anchor w 
		pack $partials.ff.7 -side top -pady 2 -anchor w
		set cou(rfnot) 0

		frame $partials.zz
		label $partials.zz.ll -text "Save Strands Cmd" -fg $evv(SPECIAL)
		checkbutton $partials.zz.dump -variable cou(dump)
		label $partials.zz.ll2 -text "Run Strands Only" -fg $evv(SPECIAL)
		checkbutton $partials.zz.strtest -variable cou(strandtest) -command "set cou(pdump) 0"
		label $partials.zz.ll3 -text "Get A Pulser Cmd" -fg $evv(SPECIAL)
		checkbutton $partials.zz.pktest -variable cou(pdump) -command "set cou(strandtest) 0"
		pack $partials.zz.ll $partials.zz.dump $partials.zz.ll2 $partials.zz.strtest $partials.zz.ll3 $partials.zz.pktest -side left

		pack $partials.ll $partials.pp $partials.ff $partials.zz -side top -pady 2 -anchor w

		pack $flux $snds $partials -side left -padx 2 -anchor n
		pack $f.1 -side top  -pady 2

		set n 1
		set m 2
		set k 5
		set j 15
		while {$n < 7} {
			bind $partials.ff.$n.e <Down> "focus $partials.ff.$m.e"
			bind $partials.ff.$n.e <Up>	  "focus $partials.ff.$k.e"
			bind $partials.ff.$n.e <Left> "focus $snds.$j.e4"
			incr n
			if {$n > 3} {
				incr j
			}
			incr m
			if {$m > 6} {
				set m 1
			}
			incr k
			if {$k > 6} {
				set k 1
			}
		}
		set n 2
		set m 1
		set k 3
		while {$n <= 21} {
			if {$n != 17} {
				bind $flux.$n.e <Down>   "focus .couette.1.0.$k.e"
				bind $flux.$n.e <Up>     "focus .couette.1.0.$m.e"
			}
			incr n
			incr m
			incr k
		}
		bind $flux.1.e <Up>		{focus .couette.1.0.22.e}
		bind $flux.1.e <Down>	{focus .couette.1.0.2.e}
		bind $flux.22.e <Up>	{focus .couette.1.0.21.e}
		bind $flux.22.e <Down>	{focus .couette.1.0.1.e}

		set n 1
		while {$n <= 22} {
			if {$n != 17} {
				bind $flux.$n.e <Right>	{focus .couette.1.1.2.e1}
			}
			incr n
		}
		set n 3
		set m 2
		set k 4
		while {$n <= 14} {
			bind $snds.$n.e1 <Up> "focus .couette.1.1.$m.e1"
			bind $snds.$n.e2 <Up> "focus .couette.1.1.$m.e2"
			bind $snds.$n.e3 <Up> "focus .couette.1.1.$m.e3"
			bind $snds.$n.e4 <Up> "focus .couette.1.1.$m.e4"
			bind $snds.$n.e1 <Down>	"focus .couette.1.1.$k.e1"
			bind $snds.$n.e2 <Down>	"focus .couette.1.1.$k.e2"
			bind $snds.$n.e3 <Down>	"focus .couette.1.1.$k.e3"
			bind $snds.$n.e4 <Down>	"focus .couette.1.1.$k.e4"
			incr n
			incr m
			incr k
		}
		set n 1
		while {$n <= 4} {
			bind $snds.2.e$n  <Up>	 "focus .couette.1.1.19.e$n"
			bind $snds.2.e$n  <Down> "focus .couette.1.1.3.e$n"
			bind $snds.15.e$n <Down> "set cou(nar) $n; focus .couette.1.1.rrc.e"
			bind $snds.16.e$n <Down> "focus .couette.1.1.17.e$n"
			bind $snds.17.e$n <Down> "focus .couette.1.1.18.e$n"
			bind $snds.18.e$n <Down> "focus .couette.1.1.19.e$n"
			bind $snds.19.e$n <Down> "focus .couette.1.1.2.e$n"

			bind $snds.15.e$n <Up>   "focus .couette.1.1.14.e$n"
			bind $snds.16.e$n <Up>   "set cou(nar) $n; focus .couette.1.1.rrc.e"
			bind $snds.17.e$n <Up>	 "focus .couette.1.1.16.e$n"
			bind $snds.18.e$n <Up>	 "focus .couette.1.1.17.e$n"
			bind $snds.19.e$n <Up>	 "focus .couette.1.1.18.e$n"
			incr n
		}
		bind $snds.rrc.e  <Up>	 {focus .couette.1.1.15.e$cou(nar)}
		bind $snds.rrc.e  <Down> {focus .couette.1.1.16.e$cou(nar)}
		bind $snds.rrc.e  <Left>  {focus .couette.1.0.1.e}

		set n 2
		while {$n <= 14} {
			bind $snds.$n.e1 <Left>  "focus .couette.1.0.1.e"
			bind $snds.$n.e2 <Left>  "focus .couette.1.1.$n.e1"
			bind $snds.$n.e3 <Left>  "focus .couette.1.1.$n.e2"
			bind $snds.$n.e4 <Left>  "focus .couette.1.1.$n.e3"

			bind $snds.$n.e1 <Right>  "focus .couette.1.1.$n.e2"
			bind $snds.$n.e2 <Right>  "focus .couette.1.1.$n.e3"
			bind $snds.$n.e3 <Right>  "focus .couette.1.1.$n.e4"
			bind $snds.$n.e4 <Right>  "focus .couette.1.1.$n.e1"
			incr n
		}
		while {$n <= 19} {
			bind $snds.$n.e1 <Left>  "focus .couette.1.0.1.e"
			bind $snds.$n.e2 <Left>  "focus .couette.1.1.$n.e1"
			bind $snds.$n.e3 <Left>  "focus .couette.1.1.$n.e2"
			bind $snds.$n.e4 <Left>  "focus .couette.1.1.$n.e3"

			bind $snds.$n.e1 <Right>  "focus .couette.1.1.$n.e2"
			bind $snds.$n.e2 <Right>  "focus .couette.1.1.$n.e3"
			bind $snds.$n.e3 <Right>  "focus .couette.1.1.$n.e4"
			incr n
		}
		set n 15
		while {$n <= 19} {
			bind $snds.$n.e4 <Right>  "DoCouBind $n"
			incr n
		}

		set n 1
		while {$n <= 4} {
			bind $snds.1.e$n <Command-ButtonRelease> "ShowPartials $n"
			incr n
		}
		bind $flux.3.e <Control-ButtonRelease> "ListCouParamFiles 3"
		bind $flux.3.e <Command-ButtonRelease>     "DisplayParamFile 3"
		set n 7
		while {$n <= 13} {
			bind $flux.$n.e <Control-ButtonRelease> "ListCouParamFiles $n"
			bind $flux.$n.e <Command-ButtonRelease> "DisplayParamFile $n"
			incr n
		}
		set n 1
		set m 78
		while {$n <= 4} {
			bind $snds.16.e$n <Control-ButtonRelease> "ListCouParamFiles $m"
			bind $snds.16.e$n <Command-ButtonRelease> "DisplayParamFile $m"
			incr n
			incr m
		}


 		set cou(ratio)	""
		set cou(rfstep)	""
		set cou(rfrand)	""
		set cou(rfoff)	""
		set cou(rfend)	""
		set cou(rftyp)	""
		set cou(refocus) 0
		CouDoRefocus
		catch {unset cou(outsnd)}
		wm resizable $f 0 0
		bind $f <space>  {PlayCouOutput}
		bind $f <Escape> {set pr_couette 0}
		bind $f <Return> {set pr_couette 1}
	}
	.couette.0.f0.ff config -text "Create Flow"
	set cou(strandtest) 0
	IgnoreRefocus 0
	set cou(input) 0
	set cou(pclear) 0
	set cou(cop2) 0
	set cou(cop3) 0
	set cou(cop4) 0
	set cou(which) 0
	set cou(only) 0
	catch {unset cou(multibands)}
	set cou(clear) -1
	$cou(parlist) delete 0 end
	foreach pfile $cou(pfiles) {
		$cou(parlist) insert end $pfile
	}
	set pr_couette 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_couette
	while {!$finished} {
		if {[info exists cou(multibands)]} {
			set cou(only) 5
		}
		tkwait variable pr_couette
		if {$pr_couette} {

			;#		CHECK VALIDITY OF ALL PARAMETERS

			if {[info exists cou(outsnd)] && [file exists $cou(outsnd)]} {
				.couette.0.play config -text "Play output" -command "PlayCouOutput" -bd 2 -bg $evv(EMPH)
			}
			set n 1
			set OK 1
			while {$n < 16} {
				if {$n == 3} {
					catch {unset cou(multithreads)}
					set thisvar $cou([lindex $counam $n])
					if {[string length $thisvar] <= 0} {
						Inf "No entry for [lindex $coufullnam $n]"
						set OK 0
						break
					} elseif {[IsNumeric $thisvar]} {
						if {($thisvar < [lindex $cou(courbot) $n]) || ($thisvar > [lindex $cou(courtop) $n])} {
							Inf "Value for [lindex $coufullnam $n] is out of range ([lindex $cou(courbot) $n] to [lindex $cou(courtop) $n])"
							set OK 0
							break
						}
					} else {
						if {![file exists $thisvar]} {
							Inf "File $thisvar does not exist"
							set OK 0
							break
						}
						if [catch {open $thisvar "r"} zit] {
							Inf "Cannot open file $thisvar to read thread counts for bands"
							set OK 0
							break
						}
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
								if {![IsNumeric $item] || ![regexp {^[0-9]+$} $item] || ($item < [lindex $cou(courbot) $n]) || ($item > [lindex $cou(courtop) $n])} {
									Inf "Inappropriate data ($item) in file $fnam for thread counts of bands"
									set OK 0
									break
								}
								lappend cou(multithreads) $item
							}
							if {!$OK} {
								break
							}
						}
						close $zit
						if {$OK} {
							if {[llength $cou(multithreads)] < $cou(bands)} {
								Inf "Insufficient thread-counts listed in file $thisvar for the $cou(bands) specified"
								set OK 0
							}
						}
						if {!$OK} {
							catch {unset cou(multithreads)}
							break
						}
						set cou(threadcnt) 0
						foreach item $cou(multithreads) {
							incr cou(threadcnt) $item
						} 
					}
				} else {
					set thisvar $cou([lindex $counam $n])
					if {[IsNumeric $thisvar]} {
						if {($thisvar < [lindex $cou(courbot) $n]) || ($thisvar > [lindex $cou(courtop) $n])} {
							Inf "Value for [lindex $coufullnam $n] is out of range ([lindex $cou(courbot) $n] to [lindex $cou(courtop) $n])"
							set OK 0
							break
						}
						if {$n == 7} {
							set maxtwist $thisvar
						}
					} elseif {($n >= 7) && ($n <= 13)} {
						if {![file exists $thisvar]} {
							Inf "File $thisvar for [lindex $coufullnam $n] does not exist"
							set OK 0
							break
						} elseif {![info exists pa($thisvar,$evv(FTYP))]} {
							set ftyp [FindFileType $thisvar]
							if {![IsABrkfile $ftyp]} {
								Inf "File $thisvar for [lindex $coufullnam $n] is of wrong type"
								set OK 0
								break
							} elseif {[FileToWkspace $thisvar 0 0 0 0 1] <= 0} {
								set OK 0
								break
							}
						}
						if {![IsABrkfile $pa($thisvar,$evv(FTYP))]} {
							Inf "File $thisvar for [lindex $coufullnam $n] is of wrong type"
							set OK 0
							break
						} elseif {($pa($thisvar,$evv(MINBRK)) < [lindex $cou(courbot) $n]) || ($pa($thisvar,$evv(MAXBRK)) > [lindex $cou(courtop) $n]) } {
							Inf "File $thisvar for [lindex $coufullnam $n] has out of range values"
							set OK 0
							break
						}
						if {$n == 7} {
							set maxtwist $pa($thisvar,$evv(MAXBRK))
						}
					} else {
						Inf "INVALID DATA FOR [lindex $coufullnam $n]"
						set OK 0
						break
					}
				}
				incr n
			}
			if {!$OK} {
				continue
			}
			if {$cou(strandtest)} {
				set thisvar $cou([lindex $counam 77])		;#	SEED VALUE (77)
				if {[IsNumeric $thisvar]} {
					if {($thisvar < [lindex $cou(courbot) 32]) || ($thisvar > [lindex $cou(courtop) 32])} {
						Inf "Value for random seed is out of range ([lindex $cou(courbot) 32] to [lindex $cou(courtop) 32])"
						continue
					}
				} else {
					Inf "Invalid data for random seed"
					continue
				}
				CouResetParamsForTest 0
				set cou(samedata) 0
				catch {unset cou(multibands)}
			} else {
				set thisvar $cou([lindex $counam $n])		;#	3D MOTION
				if {[IsNumeric $thisvar]} {
					if {($thisvar < [lindex $cou(courbot) $n]) || ($thisvar > [lindex $cou(courtop) $n])} {
						Inf "No value set for [lindex $coufullnam $n]"
						continue
					}
				} else {
					Inf "No value set for [lindex $coufullnam $n]"
					continue
				}
				if {($maxtwist <= 0.0) && $cou(3d)} {
					set msg "No 3d motion possible if twist rotation speed is zero\nignore 3d parameters ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						set cou(3d) 0
						set cou(fx) 0.0
					} else {
						continue
					}
				}
				incr n
															;#	If we're reducing number of bands from previous pass,
															;#  may want to preserve the data (expecially from other bands) from previous pass,

				if {$cou(activebands) && ($cou(bands) < $cou(activebands))} {
					set msg "Reducing the nuber of bands in use : do you want to save the previous patch ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						set cou(bandsset) $cou(bands)		;#	Remember how many bands (cou(bands)) set in current patch.
						set cou(bands) $cou(activebands)	;#	Reset number of bands to that in previous patch (so it will be correctly saved).
						Inf "Save the patch now"			;#	exit loop so last-patch-save can be executed.
						continue							;#	(patch save itself resets cou(bands) to the curent value).
					}
				}
				set cou(activebands) $cou(bands)			;#	Remeber how many bands we're using in this pass
				if {$cou(activebands)} {
					if {$cou(activebands) < 4} {
						set cou(partials4) ""
						set cou(minrise4)  ""
						set cou(maxrise4)  ""
						set cou(minsus4)   ""
						set cou(maxsus4)   ""
						set cou(mindecay4) ""
						set cou(maxdecay4) ""
						set cou(speed4)    ""
						set cou(scat4)     ""
						set cou(expr4)     ""
						set cou(expd4)     ""
						set cou(pscat4)    ""
						set cou(ascat4)    ""
						set cou(octav4)    ""
						set cou(bend4)     ""
						set cou(bal4)      ""
					}
					if {$cou(activebands) < 3} {
						set cou(partials3) ""
						set cou(minrise3)  ""
						set cou(maxrise3)  ""
						set cou(minsus3)   ""
						set cou(maxsus3)   ""
						set cou(mindecay3) ""
						set cou(maxdecay3) ""
						set cou(speed3)    ""
						set cou(scat3)     ""
						set cou(expr3)     ""
						set cou(expd3)     ""
						set cou(pscat3)    ""
						set cou(ascat3)    ""
						set cou(octav3)    ""
						set cou(bend3)     ""
						set cou(bal3)      ""
					}
					if {$cou(activebands) < 2} {
						set cou(partials2) ""
						set cou(minrise2)  ""
						set cou(maxrise2)  ""
						set cou(minsus2)   ""
						set cou(maxsus2)   ""
						set cou(mindecay2) ""
						set cou(maxdecay2) ""
						set cou(speed2)    ""
						set cou(scat2)     ""
						set cou(expr2)     ""
						set cou(expd2)     ""
						set cou(pscat2)    ""
						set cou(ascat2)    ""
						set cou(octav2)    ""
						set cou(bend2)     ""
						set cou(bal2)      ""
					}
				}
				if {$cou(only) == 5} {		;#	multibands set
					set cou(only) 0
				}
				if {$cou(only) > $cou(bands)} {
					Inf "Band $cou(only) is not active in this patch"
					continue
				}
				set kk 1
				set cou(minpartials) $cou(pcnt$kk)
				incr kk
				while {$kk <= $cou(activebands)} {
					if {$cou(pcnt$kk) < $cou(minpartials)} {
						set cou(minpartials) $cou(pcnt$kk)
					}
					incr kk
				}
				set m 17
				set OK 1
				while {$n <= 76} {		;#	PACKET PARAMETERS FOR 4 BANDS	( ... TO 76)
					set thisband [expr (($n - 17)/15) + 1]
					if {$thisband > $cou(bands)} {			;#	ONLY CHECK PARAMS FOR NUMBER OF BANDS SPECIFIED
						set n 77
						break
					}
					if {$m == 17} {			;#	FIND NUMBER OF PARTIALS
						if {$cou(3d)} {
							set partialrange($thisband) [CountPartials $thisband]
							if {$partialrange($thisband) == 0} {
								set msg "Continue without 3-d effects ??"
								set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
								if {$choice == "yes"} {
									set cou(3d) 0
								} else {
									set OK 0
									break
								}
							}
						}
					} else {
						set thisvar $cou([lindex $counam $n])
						if {[IsNumeric $thisvar]} {
							if {($thisvar < [lindex $cou(courbot) $m]) || ($thisvar > [lindex $cou(courtop) $m])} {
								Inf "Value for [lindex $coufullnam $m] (band $thisband) is out of range ([lindex $cou(courbot) $m] to [lindex $cou(courtop) $m])"
								set OK 0
								break
							}
						} elseif {($m >= 23) && ($m <= 30)} {
							if {![file exists $thisvar]} {
								Inf "File $thisvar for [lindex $coufullnam $m] (band $thisband) does not exist"
								set OK 0
								break
							} elseif {![info exists pa($thisvar,$evv(FTYP))]} {
								set ftyp [FindFileType $thisvar]
								if {![IsABrkfile $ftyp]} {
									Inf "File $thisvar for [lindex $coufullnam $m] (band $thisband) is of wrong type"
									set OK 0
									break
								} elseif {[FileToWkspace $thisvar 0 0 0 0 1] <= 0} {
									set OK 0
									break
								}
							}
							if {![IsABrkfile $pa($thisvar,$evv(FTYP))]} {
								Inf "File $thisvar for [lindex $coufullnam $m] (band $thisband) is of wrong type"
								set OK 0
								break
							} elseif {($pa($thisvar,$evv(MINBRK)) < [lindex $cou(courbot) $m]) || ($pa($thisvar,$evv(MAXBRK)) > [lindex $cou(courtop) $m]) } {
								Inf "File $thisvar for [lindex $coufullnam $m] (band $thisband) has out of range values"
								set OK 0
								break
							}
						} else {
							Inf "Invalid data for [lindex $coufullnam $m] (band $thisband)"
							set OK 0
							break
						}
					}
					if {!$OK} {
						break
					}
					incr n
					incr m
					if {$m > 31} {
						set m 17
					}
				}
				if {!$OK} {
					continue
				}
				set thisvar $cou([lindex $counam $n])		;#	SEED VALUE (77)
				if {[IsNumeric $thisvar]} {
					if {($thisvar < [lindex $cou(courbot) 32]) || ($thisvar > [lindex $cou(courtop) 32])} {
						Inf "Value for random seed is out of range ([lindex $cou(courbot) 32] to [lindex $cou(courtop) 32])"
						continue
					}
				} else {
					Inf "Invalid data for random seed"
					continue
				}
				incr n
				set bandno 1
				while {$n <= 81} {		;#	ROTATION SPEEDS
					set thisvar $cou([lindex $counam $n])
					if {[IsNumeric $thisvar]} {
						if {($thisvar < [lindex $cou(courbot) 33]) || ($thisvar > [lindex $cou(courtop) 33])} {
							Inf "Value for rotation-speed band $bandno is out of range ([lindex $cou(courbot) 33] to [lindex $cou(courtop) 33])"
							set OK 0
							break
						}
					} elseif {[file exists $thisvar]} {

						if {![info exists pa($thisvar,$evv(FTYP))]} {
							set ftyp [FindFileType $thisvar]
							if {![IsABrkfile $ftyp]} {
								Inf "File $thisvar for rotation-speed (band $bandno) is of wrong type"
								set OK 0
								break
							} elseif {[FileToWkspace $thisvar 0 0 0 0 1] <= 0} {
								set OK 0
								break
							}
						}
						if {![IsABrkfile $pa($thisvar,$evv(FTYP))]} {
							Inf "File $thisvar for rotation-speed (band $bandno) is of wrong type"
							set OK 0
							break
						} elseif {($pa($thisvar,$evv(MINBRK)) < [lindex $cou(courbot) 33]) || ($pa($thisvar,$evv(MAXBRK)) > [lindex $cou(courtop) 33]) } {
							Inf "File $thisvar for rotation-speed (band $bandno) has out of range values (range [lindex $cou(courbot) 33] to [lindex $cou(courtop) 33])"
							set OK 0
							break
						}
					} else {
						Inf "Invalid data for rotation-speed band $bandno"
						set OK 0
						break
					}
					incr n
					incr bandno
					if {$bandno > $cou(bands)} {
						set n 82
						break
					}
				}
				if {!$OK} {
					continue
				}
				if {![regexp {^[0-9]+$} $cou(chans)] || ($cou(chans) < 2) || ($cou(chans) > 16)} {
					Inf "Invalid value for output channel count"
					set OK 0
					continue
				}

				set bandno 1
				while {$n <= 85} {		;#	ROTATION START CHANS
					set thisvar $cou([lindex $counam $n])
					if {[regexp {^[0-9]+$} $thisvar]} {
						if {($thisvar < 1) || ($thisvar > $cou(chans))} {
							Inf "Value for rotation start channel $bandno is out of range (1 to $cou(chans))"
							set OK 0
							break
						}
					} else {
						Inf "Invalid data for rotation start channel : band $bandno"
						set OK 0
						break
					}
					incr n
					incr bandno
					if {$bandno > $cou(bands)} {
						set n 86
						break
					}
				}
				if {!$OK} {
					continue
				}
				set bandno 1
				while {$n <= 89} {		;#	ROTATION STARTCHAN INCRS
					set thisvar $cou([lindex $counam $n])
					if {[regexp {^[0-9]+$} $thisvar]} {
						if {($thisvar < 0) || ($thisvar > [expr $cou(chans) - 1])} {
							Inf "Value for rotation start channel increment $bandno is out of range (0 to [expr $cou(chans) - 1])"
							set OK 0
							break
						}
					} else {
						Inf "Invalid data for rotation start channel increment : band $bandno"
						set OK 0
						break
					}
					incr n
					incr bandno
					if {$bandno > $cou(bands)} {
						set n 90
						break
					}
				}
				if {!$OK} {
					continue
				}

				if {![IsNumeric $cou(fx)] || ($cou(fx) < 0) || ($cou(fx) > 1)} {
					Inf "Invalid value for reverb mix range (value range 0-1)"
					set OK 0
					continue
				}
				if {($cou(fx) > 0.0) && ($cou(3d) == 0)} {
					set msg "Reverb mix not operational if 3d option not set : reset mix range to zero ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						set cou(fx) 0.0
					} else {
						set OK 0
						continue
					}
				}
				if {![IsNumeric $cou(sz)] || ($cou(sz) < 0.1) || ($cou(sz) > 1)} {
					Inf "Invalid value for reverb stadium size multiplier (range 0.01 to 1)"
					set OK 0
					continue
				}

				if {![IsNumeric $cou(echos)] || ($cou(echos) < 8) || ($cou(echos) > 1000)} {
					Inf "Invalid value for reverb echoes count (range 0.01 to 1000)"
					set OK 0
					continue
				}

				if {![IsNumeric $cou(maxrev)] || ($cou(maxrev) < $cou(fx)) || ($cou(maxrev) > 1.0)} {
					Inf "Invalid value for max reverb in mix, with specified reverb range (range $cou(fx) to 1)"
					set OK 0
					continue
				}
				if {![IsNumeric $cou(prev)] || ($cou(prev) < 1) || ($cou(prev) > $cou(minpartials))} {
					Inf "Invalid value for partials in reverbd threads, with specified partials files (range 1 to $cou(minpartials))"
					set OK 0
					continue
				}

				if {$cou(refocus)} {
 					if {![IsNumeric $cou(ratio)] || ($cou(ratio) <= 1.0) || ($cou(ratio) > 64)} {
						Inf "Invalid value for refocus ratio (range > 1 to 64)"
						set OK 0
						continue
					}
 					if {![IsNumeric $cou(rfstep)] || ($cou(rfstep) <= 0.01) || ($cou(rfstep) > 3600)} {
						Inf "Invalid value for refocus timestep (range > 0.01 to 3600)"
						set OK 0
						continue
					}
					if {![IsNumeric $cou(rfrand)] || ($cou(rfrand) < 0) || ($cou(rfrand) > 1)} {
						Inf "Invalid value for refocus timestep randomisation (range > 0.01 to 3600)"
						set OK 0
						continue
					}
					if {![IsNumeric $cou(rfoff)] || ($cou(rfoff) < 0) || ($cou(rfoff) >= $cou(dur))} {
						Inf "Invalid value for refocus offset (range 0 to less than duration $cou(dur))"
						set OK 0
						continue
					}
					if {![IsNumeric $cou(rfend)] || ($cou(rfend) < 0) || ($cou(rfend) > $cou(dur))} {
						Inf "Invalid value for refocus offset (range 0 to less than duration $cou(dur))"
						set OK 0
						continue
					}
					if {($cou(rfend) > 0.0) && ($cou(rfend) <= $cou(rfoff))} {
						Inf "Refocus offset and reset end incompatible"
						set OK 0
						continue
					}
					if {![regexp {^[0-9]$} $cou(rftyp)] || ($cou(rftyp) < 1) || ($cou(rftyp) > 5)} {
						Inf "Invalid value for refocus type (range > 1 to 5)"
						set OK 0
						continue
					}
				}

				set b 1
				while {$b <= $cou(bands)} {
					if {![IsNumeric $cou(bal$b)] || ($cou(bal$b) <= 0) || ($cou(bal$b) > 1)} {
						Inf "Invalid value for balance for band $b (range >0 to 1)"
						set OK 0
						break
					}
					if {!$OK} {
						break
					}
					incr b
				}
			}
			if {$cou(input)} {
				if {![info exists chlist]} {
					Inf "Input data was specified, but none has been supplied"
					set cou(input) 0
					continue
				}
				if {[info exists cou(multithreads)]} {
					set indatacnt $cou(threadcnt)
				} else {
					set indatacnt [expr $cou(bands) * $cou(threads)]
				}
				if $cou(3d) {
					set totalindatacnt [expr $indatacnt  * 3]
				} else {
					set totalindatacnt $indatacnt
					}
				if {[llength $chlist] != $totalindatacnt} {
					set msg "Input data was specified, but number of input files ($totalindatacnt) is incorrect"
					append msg "\nfor $cou(bands) bands, "
					if {[info exists cou(multithreads)]} {
						append msg "with a total of $cou(threadcnt) threads "
					} else {
						append msg "each with $cou(threads) threads "
					}
					if $cou(3d) {
						append msg "\nand 2 further sets of control data for the 3d motion"
					}
					Inf $msg
					continue
				}
				set n 0
				while {$n < $indatacnt} {
					lappend cou(threaddatafiles) [lindex $chlist $n]
					incr n
				}
				if {$cou(3d)} {
					set m 0
					while {$m < $indatacnt} {
						lappend cou(controlfiles1) [lindex $chlist $n]
						incr n
						incr m
					}
					set m 0
					while {$m < $indatacnt} {
						lappend cou(controlfiles2) [lindex $chlist $n]
						incr n
						incr m
					}
				}
				set cou(samedata) 0
				set cou(kpcd) 0		;#	No need to keep control data, as it's input
			}
			if {$cou(samedata)} {
				if {![IsSameCouThreadData]} {
					set cou(samedata) 0
				}
			}

			;#	CHECK POTENTIAL FILENAMES

			if {![ValidCDPRootname $cou(ofnam)]} {
				continue
			}
			set ofnam [string tolower $cou(ofnam)]
			append ofnam $evv(SNDFILE_EXT)
			if {[file exists $ofnam]} {
				Inf "File $ofnam aready exists: please choose a different name"
				continue
			}
			if {[info exists cou(multibands)]} {
				set OK  1
				set b 1
				while {$b <= $cou(bands)} {
					set mbofnam($b) [string tolower $cou(ofnam)]
					append mbofnam($b) "_b$b" $evv(SNDFILE_EXT)
					if {[file exists $mbofnam($b)]} {
						Inf "File $mbofnam($b) for band $b aready exists: please choose a different name"
						set OK 0
						break
					}
					incr b
				}
				if {!$OK} {
					continue
				}
			}
			if {$cou(dump)} {
				set dumpfnam [string tolower $cou(ofnam)]
				append dumpfnam "_strands" $evv(BATCH_EXT)
				if {[file exists $dumpfnam]} {
					Inf "Cannot save strands cmdline : as a file with the name $dumpfnam already exists"
					set OK 0
					break
				}
			}
			if {$cou(pdump)} {
				set pdumpfnam [string tolower $cou(ofnam)]
				append pdumpfnam "_pulser" $evv(BATCH_EXT)
				if {[file exists $pdumpfnam]} {
					Inf "Cannot save packets cmdline : as a file with the name $pdumpfnam already exists"
					set OK 0
					break
				}
				CouResetParamsForTest 0
			}
			if {$cou(kpth)} {	;#	CHECK NAMES OF EXISTING THREAD FILES
				set OK 1
				set b 1
				while {$b <= $cou(bands)} {
					set t 1
					if {[info exists cou(multithreads)]} {
						set threadlim [lindex $cou(multithreads) [expr $b - 1]]
					} else {
						set threadlim $cou(threads)
					}
					while {$t <= $threadlim} {
						set thofnam [string tolower $cou(ofnam)]
						append thofnam "_b" $b t $t $evv(SNDFILE_EXT)
						if {[file exists $thofnam]} {
							Inf "Thread filename $thofnam aready exists:\nplease choose a different name, or delete existing threads"
							set OK 0
							break
						}
						incr t
					}
					if {!$OK} {
						break
					}
					incr b
				}
				if {!$OK} {
					continue
				}
			}

			if {$cou(kprth)} {		;#	CHECK NAMES OF EXISTING ROTATING THREAD FILES
				set OK 1
				set b 1
				while {$b <= $cou(bands)} {
					set t 1
					if {[info exists cou(multithreads)]} {
						set threadlim [lindex $cou(multithreads) [expr $b - 1]]
					} else {
						set threadlim $cou(threads)
					}
					while {$t <= $threadlim} {
						set thofnam [string tolower $cou(ofnam)]
						append thofnam "_b" $b t $t rot $evv(SNDFILE_EXT)
						if {[file exists $thofnam]} {
							Inf "Rotating thread filename $thofnam aready exists:\nplease choose a different name, or delete existing threads"
							set OK 0
							break
						}
						incr t
					}
					if {!$OK} {
						break
					}
					incr b
				}
				if {!$OK} {
					continue
				}
			}
			if {$cou(kpmix)} {		;#	CHECK NAMES OF EXISTING MIXFILES
				set OK 1
				set thofnam [string tolower $cou(ofnam)]
				append thofnam [GetTextfileExtension mmx]
				if {[file exists $thofnam]} {
					Inf "Mix file $thofnam aready exists:\nplease choose a different name, or delete existing mixfile"
					continue
				}
			}
									;#	CHECK NAMES OF EXISTING CONTROL DATA FILES, IF NOT RETAINING PREVIOUS ONES

			if {$cou(kpcd) && !($cou(samedata) && $cou(lastkpcd))} {	;#	If keeping control params, check filenames not already in use UNLESS
				set OK 1												;#	we're retaining params from previous run AND we kept the params on that run
				set b 1
				while {$b <= $cou(bands)} {
					set t 1
					if {[info exists cou(multithreads)]} {
						set threadlim [lindex $cou(multithreads) [expr $b - 1]]
					} else {
						set threadlim $cou(threads)
					}
					while {$t <= $threadlim} {
						set thofnam [string tolower $cou(ofnam)]
						append thofnam "_b" $b t $t con1 $evv(TEXT_EXT)
						if {[file exists $thofnam]} {
							Inf "Control data filename $thofnam aready exists:\nplease choose a different name, or delete existing control data files"
							set OK 0
							break
						}
						set thofnam [string tolower $cou(ofnam)]
						append thofnam "_b" $b t $t con2 $evv(TEXT_EXT)
						if {[file exists $thofnam]} {
							Inf "Control data filename $thofnam aready exists:\nplease choose a different name, or delete existing control data files"
							set OK 0
							break
						}
						incr t
					}
					if {!$OK} {
						break
					}
					incr b
				}
				if {!$OK} {
					continue
				}
			}

			;#	HAVING CHECKED ALL PARAMS ETC. DELETE THE APPROPRIATE Temporary FILES

			set cou(samethreads) 0 
			set cou(samerefocus) 0 
			set cou(samerotation) 0 
			set cou(samebalance) 0 

			if {$cou(samedata)} {										;#	IF THREAD PARAMETERS ARE SAME AS LAST TIME		

				set keeplist [CouGetRetainedTempFiles]						;#	Mark the pitch and control data files as NOT for deletion

				if {[IsSameCouSound]} {										;#	Are thread sounds same as lasttime ?	
					set cou(samethreads) 1
				}															;#	Are refocusing params same as last time ?
				if {[IsSameCouRefocus]} {
					set cou(samerefocus) 1
				}
				if {[IsSameCouRotation]} {
					set cou(samerotation) 1
				}
				if {[IsSameCouBalance]} {
					set cou(samebalance) 1
				}
				if {$cou(samethreads) && $cou(samerefocus) && $cou(samerotation) && $cou(samebalance) && ($cou(lastonly) == $cou(only))} {		
					set msg "Parameters are identical to last run: run again ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
				} 
				if {$cou(samethreads)} {									;#	If sounds have not been changed (but refocusing has),
					set keeplist [concat $keeplist $cou(origthreadnams)]	;#	mark sounds NOT for deletion.
					if {[info exists cou(lastkpth)] && $cou(lastkpth)} {	;#	(and if threads were previously retained,
						set cou(kpth) 0										;#	don't try to retain them again).
					}
				} 
				if {$cou(samerefocus)} {
					set keeplist2 [concat $keeplist $cou(rfenvs)]			;#	mark refocusing-envelope files NOT for deletion
					set keeplist [concat $keeplist $keeplist2]
				}
				if {[llength $keeplist] > 0} {								;#	Delete only appropriate temporary files
					set TsDeleteCmd DeleteAbsolutelyAllTemporaryFilesExcept
					foreach zfnam $keeplist {
						lappend TsDeleteCmd $zfnam
					}
					catch {eval $TsDeleteCmd}
				}
			} else {												;#	OTHERWISE DELETE ALL TEMPORARY FILES	
				catch {unset cou(controlfiles1)}
				catch {unset cou(controlfiles2)}
				catch {unset cou(threaddatafiles)}
				DeleteAllTemporaryFiles
				DeleteAllOtherFormatTemporaryFiles		;#	Removes all intermediate reverb-mix files, starting with "_out"
			}

			;#	CREATE THE THREAD DATA FILES

			if {[info exists cou(multibands)]} {
				set cou(only) 0							;#	Ensure ALL threads are made
			}
			if {[info exists cou(multithreads)]} {
				set threadcount $cou(threadcnt)
			} else {
				set threadcount [expr $cou(bands) * $cou(threads)]
			}
			set OK 1
			while {$OK} {
				Block "CREATING ALL STRANDS"
				if {!$cou(samedata) && !$cou(input)} {
					set cmd [file join $evv(CDPROGRAM_DIR) strands]
					lappend cmd strands 
					if {[info exists cou(multithreads)]} {
						lappend cmd 3 $sofnam $cou(threads) $cou(dur) $cou(bands) 
					} else {
						lappend cmd 1 $sofnam $cou(dur) $cou(bands) $cou(threads) 
					}
					lappend cmd $cou(tstep) $cou(bot) $cou(top) $cou(twist) 
					lappend cmd $cou(rand) $cou(warp) $cou(vamp) $cou(vmin) $cou(vmax) $cou(turb) $cou(seed) -g$cou(gap) -m$cou(minband) -f$cou(3d)
					set CDPidrun 0
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "$CDPidrun : Failed to create stranding data\ncmd = $cmd"
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
						Inf "$CDPidrun : Creating stranding data failed\ncmd = $cmd"
						set OK 0
						break
					}

					;#	CHECK ALL DATA FILES EXIST

					set n 0
					set txtoutcnt $threadcount
					while {$n < $txtoutcnt} {
						set thisfnam $sofnam
						append thisfnam $n $evv(TEXT_EXT)
						if {![file exists $thisfnam]} {
							Inf "Not all of stranding data was created\ncmd = $cmd"
							set OK 0
							break
						}
						lappend cou(threaddatafiles) $thisfnam
						incr n
					}
					if {!$OK} {
						break
					}
					if {$cou(3d)} {
						set origtxtoutcnt $txtoutcnt
						set txtoutcnt [expr $origtxtoutcnt * 2]
						while {$n < $txtoutcnt} {
							set thisfnam $sofnam
							append thisfnam $n $evv(TEXT_EXT)
							if {![file exists $thisfnam]} {
								Inf "Not all of stranding data was created\ncmd = $cmd"
								set OK 0
								break
							}
							lappend cou(controlfiles1) $thisfnam
							incr n
						}
						set txtoutcnt [expr $origtxtoutcnt * 3]
						while {$n < $txtoutcnt} {
							set thisfnam $sofnam
							append thisfnam $n $evv(TEXT_EXT)
							if {![file exists $thisfnam]} {
								Inf "Not all of stranding data was created\ncmd = $cmd"
								set OK 0
								break
							}
							lappend cou(controlfiles2) $thisfnam
							incr n
						}
					}
					if {!$OK} {
						break
					}

					if {$cou(dump)} {
						if [catch {open $dumpfnam "w"} zit] {
							Inf "Cannot create batchfile to write \"strands\" cmdline"
						} else {
							puts $zit $cmd
							close $zit
							FileToWkspace $dumpfnam 0 0 0 0 1
						}
					}

					;#	IF CONTROL DATA 1 TO BE USED TO CONTROL PARTIAL-CNT IN PACKETS, RECALCULATE RANGE

					if {$cou(3d)} {
						set OK 1										;#	indices 0 to txtoutcnt ( = $threadcount * 3) are already in use 
																		;#	for pitch, control1,control2 temp-datafile names
						set k $txtoutcnt								;#	k indexes new set of control files
						set n 0											;#	n counts files to be processed
						set b 1											;#	b indexes bands
						set t 1											;#	t indexes threads
						if {[info exists cou(multithreads)]} {
							set threadlim [lindex $cou(multithreads) [expr $b - 1]]
						} else {
							set threadlim $cou(threads)
						}
						while {$n < $threadcount} {
							set thisfnam [lindex $cou(controlfiles1) $n]
							if [catch {open $thisfnam "r"} zit] {
								Inf "Cannot open control data 1 file $thisfnam"
								set OK 0
							}
							catch {unset nulines}
							while {[gets $zit line] >= 0} {
								set line [string trim $line]
								if {[string length $line] <= 0} {
									continue
								}
								if {[string match [string index $line 0] ";"]} {
									continue
								}
								set line [split $line]
								set cnt 0
								catch {unset nuline}
								foreach item $line {
									set item [string trim $item]
									if {[string length $item] <= 0} {
										continue
									}
									if {$cnt==1} {
										set item [expr $item * $partialrange($b)]	;#	Scale control data to appropriate range
										set item [expr $item + 1]					;#	which is 1 to (partialrange+1)
									}
									lappend nuline $item
									incr cnt
								}
								if {$cnt != 2} {
									Inf "Problem with control data 1 file $thisfnam"
									set OK 0
									break
								}
								lappend nulines $nuline
							}
							close $zit
							if {!$OK} {
								break
							}
							set thisfnam $sofnam								;#	Create the replacement control file
							append thisfnam $k $evv(TEXT_EXT)					;#	k indexes NEW control files
							if [catch {open $thisfnam "w"} zit] {
								Inf "Cannot open new control data 1 file $thisfnam"
								set OK 0
								break
							} else {
								foreach line $nulines {
									puts $zit $line
								}												;#	Substitute it in list of files
								close $zit
								set cou(controlfiles1) [lreplace $cou(controlfiles1) $n $n $thisfnam] 
							}
							incr n
							incr k
							incr t
							if {$t > $threadlim} {
								set t 1
								incr b
								if {[info exists cou(multithreads)]} {
									set threadlim [lindex $cou(multithreads) [expr $b - 1]]
								}
							}
						}
						if {!$OK} {
							set msg "Continue without 3-d effects ??"
							set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
							if {$choice == "yes"} {
								set cou(3d) 0
							} else {
								break
							}
						}
						set txtoutcnt $k
					}

					;#	IF CONTROL DATA 2 TO BE USED TO CONTROL MIXING TO REVERBD OUTPUT, ALTER RANGE NOW
					
					if {$cou(3d) && ($cou(fx) > 0.0)} {
						set OK2 1										;#	indices 0 to txtoutcnt( = $threadcount * 4) are already in use 
																		;#	for pitch, control1, control2, control1a, temp-datafile names
						set k $txtoutcnt								;#	k indexes new set of control files
						set n 0											;#	n counts files to be processed
						set b 1											;#	b indexes bands
						set t 1											;#	t indexes threads
						if {[info exists cou(multithreads)]} {
							set threadlim [lindex $cou(multithreads) [expr $b - 1]]
						} else {
							set threadlim $cou(threads)
						}
						while {$n < $threadcount} {
							set thisfnam [lindex $cou(controlfiles2) $n]
							if [catch {open $thisfnam "r"} zit] {
								Inf "Cannot open control data 2 file $thisfnam"
								set OK2 0
							}
							catch {unset nulines}
							while {[gets $zit line] >= 0} {
								set line [string trim $line]
								if {[string length $line] <= 0} {
									continue
								}
								if {[string match [string index $line 0] ";"]} {
									continue
								}
								set line [split $line]
								set cnt 0
								catch {unset nuline}
								foreach item $line {
									set item [string trim $item]
									if {[string length $item] <= 0} {
										continue
									}
									if {$cnt==1} {
										set item [expr $item * $cou(fx)]					;#	Scale controldata2 to appropriate range (avoid zeroing reverb e.g.)
										set item [expr $item + ($cou(maxrev) -  $cou(fx))]	;#	which is (maxrev - $cou(fx)) to maxrev  
																							;#	... e.g. val 0.6, maxrev 0.8  range = 0.2 to 0.8
										set item [TranslateExpRepresentation $item]
									}
									lappend nuline $item
									incr cnt
								}
								if {$cnt != 2} {
									Inf "Problem with control data 2 file $thisfnam"
									set OK2 0
									break
								}
								lappend nulines $nuline
							}
							close $zit
							if {!$OK2} {
								break
							}
							set thisfnam $sofnam								;#	Create the replacement control file
							append thisfnam $k $evv(TEXT_EXT)					;#	k indexes NEW control files
							if [catch {open $thisfnam "w"} zit] {
								Inf "Cannot open new control 2 data file $thisfnam"
								set OK2 0
								break
							} else {
								foreach line $nulines {
									puts $zit $line
								}												;#	Substitute it in list of files
								close $zit
								set cou(controlfiles2) [lreplace $cou(controlfiles2) $n $n $thisfnam] 
							}
							incr n
							incr k
							incr t
							if {$t > $threadlim} {
								set t 1
								incr b
								if {[info exists cou(multithreads)]} {
									set threadlim [lindex $cou(multithreads) [expr $b - 1]]
								}
							}
						}
						if {!$OK2} {
							set msg "Continue without reverb mix ??"
							set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
							if {$choice == "yes"} {
								set cou(fx) 0
							} else {
								set OK 0										;#	Forces exit from larger loop
								break
							}
						}
						set txtoutcnt $k
					}

					;#	IF KEEPING THREAD CONTROL FILES, COPY THEM NOW

					if {$cou(kpcd)} {
						catch {unset cou(datafiles)}
						set k 0
						set b 1
						if {[info exists cou(multithreads)]} {
							set threadlim [lindex $cou(multithreads) [expr $b - 1]]
						} else {
							set threadlim $cou(threads)
						}
						while {$b <= $cou(bands)} {
							set t 1
							while {$t <= $threadlim} {
								set thofnam [string tolower $cou(ofnam)]
								append thofnam "_b" $b t $t $evv(TEXT_EXT)		;#	Desired name
								set cdatanam [lindex $cou(threaddatafiles) $k]		;#	Existing tempname
								if [catch {file copy $cdatanam $thofnam} zit] {
									Inf "Cannot copy temporary thread data file $k to $thofnam to preserve the data"
								}
								lappend cou(datafiles) $thofnam
								incr k
								incr t
							}
							incr b
							if {[info exists cou(multithreads)]} {
								set threadlim [lindex $cou(multithreads) [expr $b - 1]]
							}
						}
						if {$cou(3d)} {
							set k 0
							set b 1
							if {[info exists cou(multithreads)]} {
								set threadlim [lindex $cou(multithreads) [expr $b - 1]]
							} else {
								set threadlim $cou(threads)
							}
							while {$b <= $cou(bands)} {
								set t 1
								while {$t <= $threadlim} {
									set thofnam [string tolower $cou(ofnam)]
									append thofnam "_b" $b t $t con1 $evv(TEXT_EXT)	;#	Desired name
									set cdatanam [lindex $cou(controlfiles1) $k]			;#	Existing tempname
									if [catch {file copy $cdatanam $thofnam} zit] {
										Inf "Cannot copy temporary thread data file $k to $thofnam to preserve the data"
									}
									lappend cou(datafiles) $thofnam
									incr k
									incr t
								}
								incr b
								if {[info exists cou(multithreads)]} {
									set threadlim [lindex $cou(multithreads) [expr $b - 1]]
								}
							}
							set k 0
							set b 1
							if {[info exists cou(multithreads)]} {
								set threadlim [lindex $cou(multithreads) [expr $b - 1]]
							} else {
								set threadlim $cou(threads)
							}
							while {$b <= $cou(bands)} {
								set t 1
								while {$t <= $threadlim} {
									set thofnam [string tolower $cou(ofnam)]
									append thofnam "_b" $b t $t con2 $evv(TEXT_EXT)	;#	Desired name
									set cdatanam [lindex $cou(controlfiles2) $k]			;#	Existing tempname
									if [catch {file copy $cdatanam $thofnam} zit] {
										Inf "Cannot copy temporary thread data file $k to $thofnam to preserve the data"
									}
									lappend cou(datafiles) $thofnam
									incr k
									incr t
								}
								incr b
								if {[info exists cou(multithreads)]} {
									set threadlim [lindex $cou(multithreads) [expr $b - 1]]
								}
							}
						}
					}
				}

				if {$cou(strandtest)} {
					break
				}

				;#	SYNTHESIZE THE THREADS

				if {!$cou(samethreads)} {
					catch {unset ofnams}
					catch {unset cou(origthreadnams)}
					set thr 0
					if {$cou(only)} {		;#	If a single band ... reset counters
						set b $cou(only)
						if {[info exists cou(multithreads)]} {
							set threadlim [lindex $cou(multithreads) [expr $b - 1]]
							set totalthreads $threadlim
							set ccnt 0
							if {$b > 1} {
								set kk 1
								while {$kk < $b} {
									incr ccnt [lindex $cou(multithreads) [expr $kk - 1]]
									incr kk
								}
							}
						} else {
							set threadlim $cou(threads)
							set totalthreads $threadlim
							set ccnt [expr ($b - 1) * $cou(threads)]
						}
					} else {
						set b 1
						set totalthreads $threadcount
						if {[info exists cou(multithreads)]} {
							set threadlim [lindex $cou(multithreads) 0]
						} else {
							set threadlim $cou(threads)
						}
						set ccnt 0
					}
					set t 1
					while {$thr < $totalthreads} {
						wm title .blocker "PLEASE WAIT:        GENERATING BAND $b THREAD $t"
						if {$cou(kpth) && !($cou(3d) && ($cou(fx) > 0.0))} {	;#	If we want to keep the thread sounds
																				;#	AND  we're not going to subsequently add reverb 
							set thisofnam [string tolower $cou(ofnam)]			;#	give them an output name at this point
							append thisofnam "_b" $b t $t $evv(SNDFILE_EXT)	
						} else {
							set thisofnam $sofnam 
							append thisofnam $thr $evv(SNDFILE_EXT)
						}
						set cmd [file join $evv(CDPROGRAM_DIR) pulser]
						lappend cmd synth 
						if {$cou(multptyp$b)} {
							lappend cmd 2
						} else {
							lappend cmd 1 
						}
						lappend cmd $thisofnam 
						lappend cmd $cou(partials$b) $cou(dur) [lindex $cou(threaddatafiles) $ccnt] $cou(minrise$b) $cou(maxrise$b) $cou(minsus$b) $cou(maxsus$b) $cou(mindecay$b) $cou(maxdecay$b) 
						lappend cmd $cou(speed$b) $cou(scat$b) -e$cou(expr$b) -E$cou(expd$b) 
						if {$cou(pscat$b) > 0.0} {
							lappend cmd -p$cou(pscat$b) 
						}
						if {$cou(ascat$b) > 0.0} {
							lappend cmd -a$cou(ascat$b) 
						}
						if {$cou(octav$b) > 0.0} {
							lappend cmd -o$cou(octav$b) 
						}
						if {$cou(bend$b) > 0.0} {
							lappend cmd -b$cou(bend$b) 
						}
						lappend cmd -s$cou(seed) -S$cou(srate)
						if {$cou(3d) != 0} {
							lappend cmd -c[lindex $cou(controlfiles1) $ccnt]
						}
						set CDPidrun 0
						set prg_dun 0
						set prg_abortd 0
						catch {unset simple_program_messages}
						if [catch {open "|$cmd"} CDPidrun] {
							Inf "$CDPidrun : Failed to run generation of band $b thread $t\n$cmd"
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
							Inf "$CDPidrun : Generating band $b thread $t failed\n$cmd"
							set OK 0
							break
						}
						if {![file exists $thisofnam]} {
							Inf "$CDPidrun : Failed to generate band $b thread $t\n$cmd"
							set OK 0
							break
						}
						if {$cou(pdump)} {
							if [catch {open $pdumpfnam "w"} zit] {
								Inf "Cannot create batchfile to write \"pulser\" cmdline"
							} else {
								set cmd [lreplace $cmd 6 6 [lindex $cou(datafiles) $ccnt]]
								puts $zit $cmd
								close $zit
								FileToWkspace $pdumpfnam 0 0 0 0 1
								set thesefiles [ReverseList $cou(datafiles)]
								foreach fnam $thesefiles {
									FileToWkspace $fnam 0 0 0 0 1
								}
								set finished 1
							}
							CouResetParamsForTest 1
							set cou(pdump) 0
							set OK 0
							break
						}
						lappend ofnams $thisofnam			;#	Collect names of all output sounds
						incr ccnt
						incr thr
						incr t
						if {$t > $threadlim} {
							incr b
							set t 1
							if {[info exists cou(multithreads)]} {
								set threadlim [lindex $cou(multithreads) [expr $b - 1]]
							}
						}
					}
					if {!$OK} {
						break
					}
					set sndoutcnt $thr

					;#	IF 3D REVERB OPTION: 

					if {$cou(3d) && ($cou(fx) > 0.0)} {

						catch {unset prerevfnams}
						catch {unset prerevfnams}
						catch {unset revfnams}
						catch {unset mrevfnams}
						catch {unset postrevnams}

						set thr 0
						if {$cou(only)} {		;#	If a single band ... reset counters
							set b $cou(only)
							if {[info exists cou(multithreads)]} {
								set threadlim [lindex $cou(multithreads) [expr $b - 1]]
								set ccnt 0
								if {$b > 1} {
									set kk 1
									while {$kk < $b} {
										incr ccnt [lindex $cou(multithreads) [expr $kk - 1]]
										incr kk
									}
								}
							} else {
								set threadlim $cou(threads)
								set ccnt [expr ($b - 1) * $cou(threads)]
							}
							set totalthreads $threadlim
						} else {
							set b 1
							set totalthreads $threadcount
							if {[info exists cou(multithreads)]} {
								set threadlim [lindex $cou(multithreads) [expr $b - 1]]
							} else {
								set threadlim $cou(threads)
							}
							set ccnt 0
						}
						set t 1
						while {$thr < $totalthreads} {

					;#	(1)	IF PARTIALS IN REVERBD-THREAD < PARTIALS IN THREAD, CREATE LOW-PARTIAL VERSION OF THREAD


							if {$cou(prev) < $cou(pcnt$b)} {	

								wm title .blocker "PLEASE WAIT:        SYNTHESIZING REVERBABLE VERSION BAND $b THREAD $t"

								set thisofnam $revfnam
								append thisofnam $thr $evv(SNDFILE_EXT)

								set cmd [file join $evv(CDPROGRAM_DIR) pulser]
								lappend cmd synth 
								if {$cou(multptyp$b)} {
									lappend cmd 2
								} else {
									lappend cmd 1 
								}
								lappend cmd $thisofnam 
								lappend cmd $cou(partials$b) $cou(dur) [lindex $cou(threaddatafiles) $ccnt] $cou(minrise$b) $cou(maxrise$b) $cou(minsus$b) $cou(maxsus$b) $cou(mindecay$b) $cou(maxdecay$b) 
								lappend cmd $cou(speed$b) $cou(scat$b) -e$cou(expr$b) -E$cou(expd$b) -p$cou(pscat$b) -a$cou(ascat$b) -o$cou(octav$b) -b$cou(bend$b) -s$cou(seed) -S$cou(srate)
								if {$cou(3d) != 0} {
									lappend cmd -c$cou(prev)		;#	DIFFERENT NUMBER OF PARTIALS
								}
								set CDPidrun 0
								set prg_dun 0
								set prg_abortd 0
								catch {unset simple_program_messages}
								if [catch {open "|$cmd"} CDPidrun] {
									Inf "$CDPidrun : Failed to run generation of reverbable band $b thread $t\n$cmd"
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
									Inf "$CDPidrun : Generating reverbable band $b thread $t failed\n$cmd"
									set OK 0
									break
								}
								if {![file exists $thisofnam]} {
									Inf "$CDPidrun : Failed to generate reverbable band $b thread $t\n$cmd"
									set OK 0
									break
								}
								lappend prerevfnams $thisofnam			;#	Collect names of all output sounds

					;#	BUT IF NOT, JUST LIST THE EXISTING THREAD FOR REVERBERATING
							
							} else {
								lappend prerevfnams [lindex $ofnams $thr]
							}
							incr thr
							incr ccnt
							incr t
							if {$t > $threadlim} {
								incr b
								set t 1
								if {[info exists cou(multithreads)]} {
									set threadlim [lindex $cou(multithreads) [expr $b - 1]]
								}
							}
						}
						if {!$OK} {
							break
						}

						set machoutcnt $thr		;#	machoutcnt remembers the name-indexing of the reverb-related sounds

					;#	(2) CREATE THE REVERB VERSIONS OF THE THREADS prerevfnams = revfnam(0-n(=machoutcnt)) --> revfnams

						set thr 0
						if {$cou(only)} {			;#	If a single band ... reset counters
							set b $cou(only)
							if {[info exists cou(multithreads)]} {
								set threadlim [lindex $cou(multithreads) [expr $b - 1]]
							} else {
								set threadlim $cou(threads)
							}
							set totalthreads $threadlim
						} else {
							set b 1
							set totalthreads $threadcount
							if {[info exists cou(multithreads)]} {
								set threadlim [lindex $cou(multithreads) [expr $b - 1]]
							} else {
								set threadlim $cou(threads)
							}
						}
						set t 1
						while {$thr < $totalthreads} {
							wm title .blocker "PLEASE WAIT:        REVERBING BAND $b THREAD $t"
							set thisifnam [lindex $prerevfnams $thr]
							set thisofnam $revfnam
							append thisofnam $machoutcnt $evv(SNDFILE_EXT)
							incr machoutcnt
							set cmd [file join $evv(CDPROGRAM_DIR) modify]
							lappend cmd revecho 3 $thisifnam $thisofnam -g.5 -r1 -s$cou(sz) -e$cou(echos) -n
							set CDPidrun 0
							set prg_dun 0
							set prg_abortd 0
							catch {unset simple_program_messages}
							if [catch {open "|$cmd"} CDPidrun] {
								Inf "$CDPidrun : Failed to reverb band $b thread $t\n$cmd"
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
								Inf "$CDPidrun : Reverbing band $b thread $t failed\n$cmd"
								set OK 0
								break
							}
							if {![file exists $thisofnam]} {
								Inf "$CDPidrun : Failed to generate reverbed band $b thread $t\n$cmd"
								set OK 0
								break
							}
							lappend revfnams $thisofnam			;#	Collect names of all output sounds
							incr thr
							incr t
							if {$t > $threadlim} {
								incr b
								set t 1
								if {[info exists cou(multithreads)]} {
									set threadlim [lindex $cou(multithreads) [expr $b - 1]]
								}
							}
						}
						if {!$OK} {
							break
						}

					;#	(3) CREATE MONO VERSIONS OF REVERBD THREADS revfnams = revfnam(0-n) --> mrevfnams

						set thr 0
						if {$cou(only)} {			;#	If a single band ... reset counters
							set b $cou(only)
							if {[info exists cou(multithreads)]} {
								set threadlim [lindex $cou(multithreads) [expr $b - 1]]
							} else {
								set threadlim $cou(threads)
							}
							set totalthreads $threadlim
						} else {
							set b 1
							set totalthreads $threadcount
							if {[info exists cou(multithreads)]} {
								set threadlim [lindex $cou(multithreads) [expr $b - 1]]
							} else {
								set threadlim $cou(threads)
							}
						}
						set t 1
						while {$thr < $totalthreads} {
							wm title .blocker "PLEASE WAIT:        CONVERTING REVERB BAND $b THREAD $t TO MONO"
							set thisifnam [lindex $revfnams $thr]
							set thisofnam $revfnam
							append thisofnam $machoutcnt $evv(SNDFILE_EXT)
							incr machoutcnt
							set cmd [file join $evv(CDPROGRAM_DIR) housekeep]
							lappend cmd chans 4 $thisifnam $thisofnam
							set CDPidrun 0
							set prg_dun 0
							set prg_abortd 0
							catch {unset simple_program_messages}
							if [catch {open "|$cmd"} CDPidrun] {
								Inf "$CDPidrun : Failed to run conversion to mono of reverb band $b thread $t\n$cmd"
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
								Inf "$CDPidrun : Converting reverb band $b thread $t to mono failed\n$cmd"
								set OK 0
								break
							}
							if {![file exists $thisofnam]} {
								Inf "$CDPidrun : Failed to convert reverb band $b thread $t to mono\n$cmd"
								set OK 0
								break
							}
							lappend mrevfnams $thisofnam		;#	Collect names of all output sounds
							incr thr
							incr t
							if {$t > $threadlim} {
								incr b
								set t 1
								if {[info exists cou(multithreads)]} {
									set threadlim [lindex $cou(multithreads) [expr $b - 1]]
								}
							}
						}
						if {!$OK} {
							break
						}

					;#	(4) CREATE MIX WITH THE NON-REVERB VERSION	ofnams + revfnams  --> postrevnams = revfnam(2n-3n)

						set thr 0
						if {$cou(only)} {		;#	If a single band ... reset counters
							set b $cou(only)
							if {[info exists cou(multithreads)]} {
								set threadlim [lindex $cou(multithreads) [expr $b - 1]]
								set ccnt 0
								if {$b > 1} {
									set kk 1
									while {$kk < $b} {
										incr ccnt [lindex $cou(multithreads) [expr $kk - 1]]
										incr kk
									}
								}
							} else {
								set threadlim $cou(threads)
								set ccnt [expr ($b - 1) * $cou(threads)]
							}
							set totalthreads $threadlim
						} else {
							set b 1
							set totalthreads $threadcount
							if {[info exists cou(multithreads)]} {
								set threadlim [lindex $cou(multithreads) [expr $b - 1]]
							} else {
								set threadlim $cou(threads)
							}
							set ccnt 0
						}
						set t 1
						while {$thr < $totalthreads} {
							wm title .blocker "PLEASE WAIT:        MIXING ORIG & REVERB BAND $b THREAD $t"
							set thisifnam1 [lindex $ofnams $thr]			;#	Find appropriate original file: thr indexes files being processed
							set thisifnam2 [lindex $mrevfnams $thr]			;#	Find matching reverbd file
							if {$cou(kpth)} {									;#	If keeping the individual thread sounds
								set thisofnam [string tolower $cou(ofnam)]		;#	give them an output name at this point
								append thisofnam "_b" $b t $t $evv(SNDFILE_EXT)	
							} else {											;#	Else
								set thisofnam $revfnam							;#	Create temporary outfile name, using machoutcnt
								append thisofnam $machoutcnt $evv(SNDFILE_EXT)	;#	to index the (2nd) set of temporary output-sndfilenames
							}
							set balancefile [lindex $cou(controlfiles2) $ccnt]	;#	ccnt indexes the (complete) set of cotrolfiles2

							set cmd [file join $evv(CDPROGRAM_DIR) submix]
							lappend cmd balance $thisifnam2 $thisifnam1 $thisofnam -k$balancefile
							set CDPidrun 0
							set prg_dun 0
							set prg_abortd 0
							catch {unset simple_program_messages}
							if [catch {open "|$cmd"} CDPidrun] {
								Inf "$CDPidrun : Failed to run mix of orig & reverb band $b thread $t\n$cmd"
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
								Inf "$CDPidrun : Mixing orig & reverb band $b thread $t failed\n$cmd"
								set OK 0
								break
							}
							if {![file exists $thisofnam]} {
								Inf "$CDPidrun : Failed to mix orig & reverb band $b thread $t\n$cmd"
								set OK 0
								break
							}
							lappend postrevnams $thisofnam			;#	Collect names of all output sounds
						
							incr thr			;#	Index of threads actually being processed
							incr machoutcnt		;#	Index of temporary-filename's numbering
							incr ccnt			;#	Index of relevant mixbalance control-files
							incr t				;#	Index of threads within bands
							if {$t > $threadlim} {
								incr b			;#	Index of bands
								set t 1
								if {[info exists cou(multithreads)]} {
									set threadlim [lindex $cou(multithreads) [expr $b - 1]]
								}
							}
						}
						if {!$OK} {
							break
						}

					;#	(5)	SUBSTITUTE NEW FILES AS THE ofnams	(postrevfnams overwrites ofnams)

						set ofnams $postrevnams

					}
					if {!$OK} {
						break
					}

					set cou(origthreadnams) $ofnams		;#	retain these names for possible saving or deletion later

					;#	cou(origthreadnams) retains names of original thread files, before any refocusing
					;#	ofnams will eventually contain names of threads (refocused or not) prior to rotation
				}

				;#	REFOCUS THE THREADS, ONLY IF NECESSARY
				;#	!cou(only) : No point in doing refocus if only one band
				;#	!(cou(samethreads) && $cou(samerefocus)) : No point in doing refocus if using exactly same threads and focus

				if {$cou(refocus) && !$cou(only) && !($cou(samethreads) && $cou(samerefocus))} {

					;#	GENERATE THE REFOCUSING ENVELOPES

					set rfOK 1
					while {$rfOK} {
						if {!$cou(samerefocus)} {		;#	Only recreate the refocusing envelopes if necessary

							wm title .blocker "PLEASE WAIT:        CREATING REFOCUSING ENVELOPES"
							set cmd [file join $evv(CDPROGRAM_DIR) refocus]
							lappend cmd refocus $cou(rftyp) $refocfnam $cou(dur) $cou(bands) $cou(ratio) $cou(rfstep) $cou(rfrand) 
							if {$cou(rfoff) > 0.0} {
								lappend cmd -o$cou(rfoff)
							}
							if {$cou(rfend) > 0.0} {
								lappend cmd -e$cou(rfend)
							} 
							if {$cou(rfnot) > 0.0} {
								lappend cmd -n1
							}
							if {$cou(seed) > 0} {
								lappend cmd -s$cou(seed)
							}
							set CDPidrun 0
							set prg_dun 0
							set prg_abortd 0
							catch {unset simple_program_messages}
							if [catch {open "|$cmd"} CDPidrun] {
								Inf "$CDPidrun : Failed to run refocusing envelope generation\n$cmd"
								set rfOK 0
								break
   							} else {
 								fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
							}
							vwait prg_dun
							if {$prg_abortd} {
								set prg_dun 0
							}
							if {!$prg_dun} {
								Inf "$CDPidrun : Generating refocusing envelopes failed\n$cmd"
								set rfOK 0
								break
							}
							set b 0
							catch {unset cou(rfenvs)}
							while {$b < $cou(bands)} {
								set thisofnam $refocfnam
								append thisofnam $b$evv(TEXT_EXT)
								if {![file exists $thisofnam]} {
									Inf "$CDPidrun : Failed to generate all refocusing envelopes\n$cmd"
									catch {unset cou(rfenvs)}
									set rfOK 0
									break
								}
								lappend cou(rfenvs) $thisofnam
								incr b
							}
							if {!$rfOK} {
								break
							}									;#	Remember setttings for "refocus"
							RememberCouRefocusState				;#	So we don't need to create refocusing envelopes
																;#	on any later run with exactly same params
						}
						set thr 0				;#	indexes ALL threads
						set j 0					;#	Indexes band envelope files
						set b 1					;#	Indexes bands
						set t 1					;#	indexes threads within bands
						if {[info exists cou(multithreads)]} {
							set threadlim [lindex $cou(multithreads) [expr $b - 1]]
						} else {
							set threadlim $cou(threads)
						}
						catch {unset refocfnams}
						while {$thr < $threadcount} {
							wm title .blocker "PLEASE WAIT:        REFOCUSING BAND $b THREAD $t"
							set thisifnam [lindex $cou(origthreadnams) $thr]
							set thisofnam $sofnam
							append thisofnam $sndoutcnt $evv(SNDFILE_EXT)
							incr sndoutcnt
							set cmd [file join $evv(CDPROGRAM_DIR) modify]
							lappend cmd loudness 1 $thisifnam $thisofnam
							lappend cmd [lindex $cou(rfenvs) $j]							;#	Get envelope appropriate to band
							set CDPidrun 0
							set prg_dun 0
							set prg_abortd 0
							catch {unset simple_program_messages}
							if [catch {open "|$cmd"} CDPidrun] {
								Inf "$CDPidrun : Failed to refocus band $b thread $t\n$cmd"
								set rfOK 0
								break
   							} else {
 								fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
							}
							vwait prg_dun
							if {$prg_abortd} {
								set prg_dun 0
							}
							if {!$prg_dun} {
								Inf "$CDPidrun : Refocusing band $b thread $t failed\n$cmd"
								set rfOK 0
								break
							}
							if {![file exists $thisofnam]} {
								Inf "$CDPidrun : Failed to generate refocused band $b thread $t\n$cmd"
								set rfOK 0
								break
							}
							lappend refocfnams $thisofnam
							incr thr
							incr t
							if {$t > $threadlim} {
								incr b
								incr j
								set t 1
								if {[info exists cou(multithreads)]} {
									set threadlim [lindex $cou(multithreads) [expr $b - 1]]
								}
							}
						}
						break								;#	Break from refocusing loop
					}
					if {!$rfOK} {
						set msg "Continue without refocus ???"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "yes"} {
							break			;#	breaks out of inner loop
						} else {
							set OK 0		;#	will force break out of outer loop
							break
						}
					}
					set ofnams $refocfnams				;#	Replace list of existing threads by the list of refocused threads	
				}

				;#	ROTATING THE THREADS

				while {$OK} {

					if {[info exists cou(multibands)]} {
						set cou(lastonly) 0									;#	These 2 flags tell this multiband loop that all bands already exist
						set cou(samethreads) 1
																								;#	cou(multibands) is initialised to 0
						incr cou(multibands)													;#	after incr: it ranges from 1 to bandcnt
						set cou(multibands) [expr $cou(multibands) % [expr $cou(bands) + 1]]	;#	When it exceeds bandcnt, it gets 0
						set cou(only) $cou(multibands)
						if {$cou(only) != 0} {
							set thismbofnam $mbofnam($cou(only))		;#	Bands get their own names
						} else {
							set thismbofnam $ofnam						;#	Mix of all bands gets original outname
						}
					}

					catch {unset rofnams}
					set thr 0
					if {$cou(only)} {						;#	If a single band ... reset counters
						set b $cou(only)

						if {[info exists cou(multithreads)]} {
							set threadlim [lindex $cou(multithreads) [expr $b - 1]]
						} else {
							set threadlim $cou(threads)
						}
						set totalthreads $threadlim
						set cntbas 0										;#	If completely new single thread: or same single-thread as last-time: index from 0
						if {($cou(lastonly) == 0) && $cou(samethreads)} {	;#	BUT if, last time, all threads were made and we still have same threads,
							if {$b > 1} {									;#	and we're not using lowest band,
								if {[info exists cou(multithreads)]} {		;#	index into all the threads
									set kk 1
									while {$kk < $b} {
										incr cntbas [lindex $cou(multithreads) [expr $kk - 1]]
										incr kk
									}
								} else {
									set cntbas [expr ($b - 1) * $cou(threads)]
								}
							}
						}
					} else {
						set b 1
						set totalthreads $threadcount
						if {[info exists cou(multithreads)]} {
							set threadlim [lindex $cou(multithreads) [expr $b - 1]]
						} else {
							set threadlim $cou(threads)
						}
					}
					set t 1
					set brotstart [expr $cou(rstt$b) - 1]							;#	Rotation start channel of lowest thread in band, indexed from ZERO
					while {$thr < $totalthreads} {
						set throtstart [expr $brotstart + (($t-1) * $cou(rinc$b))]	;#	Rotation start channel of thread, indexing from ZERO
						set throtstart [expr $throtstart % $cou(chans)]
						incr throtstart												;#	Rotation start channel of thread, indexing from ONE

						wm title .blocker "PLEASE WAIT:        ROTATING BAND $b THREAD $t"
						if {$cou(only)} {
							set thisifnam [lindex $cou(origthreadnams) [expr $thr + $cntbas]]	;#	If a single band, no need to use any refocusing
						} else {
							set thisifnam [lindex $ofnams $thr]						;#	Otherwise use final thread state (refocused or not)
						}
						if {$cou(kprth)} {
							set thisofnam [string tolower $cou(ofnam)]				;#	If keeping rotated threads, name appropriately
							append thisofnam "_b" $b t $t rot $evv(SNDFILE_EXT)
						} else {
							set thisofnam $sofnam									;#	Else index temp files with new names
							append thisofnam $sndoutcnt $evv(SNDFILE_EXT)
							incr sndoutcnt
						}
						set cmd [file join $evv(CDPROGRAM_DIR) mchanpan]
						lappend cmd mchanpan 9 $thisifnam $thisofnam $cou(chans) $throtstart 1 1

						set CDPidrun 0
						set prg_dun 0
						set prg_abortd 0
						catch {unset simple_program_messages}
						if [catch {open "|$cmd"} CDPidrun] {
							Inf "$CDPidrun : Failed to rotate band $b thread $t\n$cmd"
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
							Inf "$CDPidrun : Rotating band $b thread $t failed\n$cmd"
							set OK 0
							break
						}
						if {![file exists $thisofnam]} {
							Inf "$CDPidrun : Failed to generate rotated band $b thread $t\n$cmd"
							set OK 0
							break
						}
						lappend rofnams $thisofnam			;#	Collect names of all output sounds
						incr thr
						incr t
						if {$t > $threadlim} {
							incr b
							if {$b <= $cou(bands)} {
								set brotstart [expr $cou(rstt$b) - 1]
							}
							set t 1
							if {[info exists cou(multithreads)]} {
								set threadlim [lindex $cou(multithreads) [expr $b - 1]]
							}
						}
					}
					if {!$OK} {
						break
					}
										
					;#	CREATE THE MIXFILE

					wm title .blocker "PLEASE WAIT:        CREATING THE MIXFILE"

					if {$cou(kpmix)} {
						set mixfnam [string tolower $cou(ofnam)]
						if {[info exists cou(multibands)] && ($cou(only) > 0)} {
							append mixfnam "_b$cou(only)"
						}
						append mixfnam [GetTextfileExtension mmx]
						if {![info exists cou(multibands)] || ($cou(only) == 0)} {		;#	If flagged to keep mixfile, store name
							set cou(mixfnam) $mixfnam									;#	or, if multibands, keep ONLY name of 1st (all bands) mixfile
						}														
					} else {
						set mixfnam $sofnam
						if {[info exists cou(multibands)] && ($cou(only) > 0)} {
							append mixfnam "000$cou(only)"
						}
						append mixfnam [GetTextfileExtension mmx]
						catch {unset cou(mixfnam)}
					}

					set thr 0
					if {$cou(only)} {		;#	If a single band ... reset counters
						set b $cou(only)
						if {[info exists cou(multithreads)]} {
							set thisthreadcount [lindex $cou(multithreads) [expr $b - 1]]
						} else {
							set thisthreadcount $cou(threads)
						}
						set lev 1.0
					} else {
						set b 1
						set thisthreadcount $threadcount
						set lev $cou(bal$b)
						if {[info exists cou(multithreads)]} {
							set threadlim [lindex $cou(multithreads) [expr $b - 1]]
						} else {
							set threadlim $cou(threads)
						}
					}
					set t 1
					catch {unset mixlines}
					while {$thr < $thisthreadcount} {
						set line [lindex $rofnams $thr]
						lappend line 0 $cou(chans)
						set n 1
						while {$n <= $cou(chans)} {
							set rout $n
							append rout ":$n"
							lappend line $rout $lev
							incr n
						}
						lappend mixlines $line
						incr thr
						incr t
						if {$t > $threadlim} {
							if {$b < $cou(bands)} {
								incr b
								if {[info exists cou(multithreads)]} {
									set threadlim [lindex $cou(multithreads) [expr $b - 1]]
								}
								set lev $cou(bal$b)
							}
							set t 1
						}
					}
					if [catch {open $mixfnam "w"} zit] {
						Inf "Cannot open mixfile to mix rotated threads"
						set OK 0
						break
					}
					puts $zit $cou(chans)
					foreach line $mixlines {
						puts $zit $line
					}
					close $zit

					;#	DOING THE MIX 

					set cou(remix) 1
					set cou(mixlevel) 1.0
					while {$cou(remix)} {

						set tempofnam $sofnam
						append tempofnam $sndoutcnt $evv(SNDFILE_EXT)
						incr sndoutcnt
						if {$cou(remix) > 1} {
							wm title .blocker "PLEASE WAIT:        REMIXING THE ROTATED THREADS"
						} else {
							wm title .blocker "PLEASE WAIT:        MIXING THE ROTATED THREADS"
						}
						set cmd [file join $evv(CDPROGRAM_DIR) newmix]
						lappend cmd multichan $mixfnam $tempofnam -g$cou(mixlevel)
						set CDPidrun 0
						set prg_dun 0
						set prg_abortd 0
						catch {unset simple_program_messages}
						if [catch {open "|$cmd"} CDPidrun] {
							Inf "$CDPidrun : Failed to mix the rotated threads : mix $cou(remix)\n$cmd"
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
							Inf "$CDPidrun : Mixing rotated threads failed : mix $cou(remix)"
							set OK 0
							break
						}
						if {![file exists $tempofnam]} {
							Inf "$CDPidrun : FAILED TO GENERATE MIX OF ROTATED THREADS : MIX $cou(remix)\n$cmd"
							set OK 0
							break
						}

						wm title .blocker "PLEASE WAIT:        CHECKING MIX OUTPUT LEVEL  : MIX $cou(remix)"

						catch {unset CDPmaxId}
						catch {unset maxsamp_line}
						set done_maxsamp 0
						set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
						lappend cmd $tempofnam
						lappend cmd 1		;#	1 flag added to FORCE read of maxsample
						if [catch {open "|$cmd"} CDPmaxId] {
							Inf "Finding maximum level of mix output: process failed\n$cmd"
							set OK 0
							break
	   					} else {
	   						fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
						}
	 					vwait done_maxsamp
						if {[info exists maxsamp_line]} {
							set cou(maxsamp) [lindex $maxsamp_line 0]
						} else {
							Inf "Failed to find maximum level of mix output\n$cmd"
							set OK 0
							break
						}
						if {$cou(maxsamp) <= 0.0} {
							Inf "Mix output has zero level\n$cmd"
							set OK 0
							break
						}
						if {$cou(maxsamp) > 0.95} {			;#	On first mix(es), reduce level by factor of 10
							if {$cou(remix) == 1} {			;#	This enables true mix level to be tested
								set cou(mixlevel) [expr $cou(mixlevel) * 0.1]
							}
							incr cou(remix)
						} elseif {$cou(maxsamp) < 0.9} {	;#	Once level falls below 0.9, attempt to adjust upwards
							set cou(mixlevel) [expr 0.9/$cou(maxsamp)]
							if {$cou(mixlevel) > 1.0} {
								set cou(remix) 0
							} else {
								incr cou(remix)
							}
						} else {
							set cou(remix) 0
						}
					}
					if {!$OK} {
						break
					}
					if {[info exists cou(multibands)]} {	;#	For multiband situation (creates each band, and the mix of all bands)
						if [catch {file rename $tempofnam $thismbofnam} zit] {
							Inf "Cannot rename the temporary outfile $tempofnam to $thismbofnam\ndo this now, outside the loom, before proceeding"
							set OK 0
							break							;#	Each band is appropriately named
						}
						if {$cou(only) != 0} {				;#	for individual bands, save to workspace here, and continue round ROTATIONS loop
							FileToWkspace $thismbofnam 0 0 0 0 1
						} else {							;#	Final (all-bands) mix will be saved to workspace outside this rotations loop
							break							;#	which we now break out of.
						}
					} else {									
						if [catch {file rename $tempofnam $ofnam} zit] {
							Inf "Cannot rename the temporary outfile $tempofnam to $ofnam\ndo this now, outside the loom, before proceeding"
							set OK 0
						}									;#	For a single pass of rotations loop, if reached end here, break out
						break
					}
				}
				break										;#	Once out of inner loop, break out of outer "make strands" loop to proceed
			}
			if {!$OK} {
				UnBlock
				catch {unset badfiles2}
				if {$cou(kpcd) && [info exists cou(datafiles)]} {
					catch {unset badfiles}
					foreach zfnam $cou(datafiles) {
						if {[file exists $zfnam]} {
							lappend badfiles $zfnam
						}
					}
					if {[info exists badfiles]} {
						set nam $cou(ofnam)
						append nam bNtN $evv(TEXT_EXT)
						set msg "Delete the thread data files, named $nam ??"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						foreach zfnam $badfiles {
							if {$choice == "yes"} {
								if [catch {file delete $zfnam} zit] {
									lappend badfiles2
								}
							} else {
								FileToWkspace $zfnam 0 0 0 0 1
							}
						}
					}
				}	
				if {$cou(kpth) && [info exists cou(origthreadnams)]} {
					catch {unset badfiles}
					foreach zfnam $cou(origthreadnams) {
						if {[file exists $zfnam]} {
							lappend badfiles $zfnam
						}
					}
					if {[info exists badfiles]} {
						set nam $cou(ofnam)
						append nam bNtN $evv(SNDFILE_EXT)
						set msg "Delete the thread soundfiles generated, named $nam ??"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						foreach zfnam $badfiles {
							if {$choice == "yes"} {
								if [catch {file delete $zfnam} zit] {
									lappend badfiles2
								}
							} else {
								FileToWkspace $zfnam 0 0 0 0 1
							}
						}
					}
				}
				if {$cou(kprth) && [info exists rofnams]} {
					catch {unset badfiles}
					foreach zfnam $rofnams {
						if {[file exists $zfnam]} {
							lappend badfiles $zfnam
						}
					}
					if {[info exists badfiles]} {
						set nam $cou(ofnam)
						append nam bNtNrot $evv(SNDFILE_EXT)
						set msg "Delete the rotated thread files generated, named $nam ??"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						foreach zfnam $badfiles {
							if {$choice == "yes"} {
								if [catch {file delete $zfnam} zit] {
									lappend badfiles2
								}
							} else {
								FileToWkspace $zfnam 0 0 0 0 1
							}
						}
					}
				}
				if {$cou(kpmix) && [file exists $cou(mixfnam)]} {
					set msg "Delete 8-chan mix file $cou(mixfnam) ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						if [catch {file delete $cou(mixfnam)} zit] {
							lappend badfiles2
						}
					} else {
						FileToWkspace $cou(mixfnam) 0 0 0 0 1
					}
				}
				if {[info exists badfiles2]} {
					set kkk 0
					set msg "Failed to delete the files\n"
					foreach zfnam $badfiles2 {
						append msg "$zfnam\n"
						incr kkk
						if {$kkk >= 20} {
							append msg "and more"
							break
						}
					}
					Inf $msg
				}
				continue
			}
			set otherfiles 0
			if {$cou(kpcd) && !($cou(samedata) && $cou(lastkpcd))} {
				set otherfiles 1
				set thesefiles [ReverseList $cou(datafiles)]
				foreach fnam $thesefiles {
					FileToWkspace $fnam 0 0 0 0 1
				}
				if {$cou(strandtest)} {
					CouResetParamsForTest 1
					set cou(strandtest) 0
					Inf "Strands process has run : data in files beginning [string tolower $cou(ofnam)]"
					UnBlock
					continue
				}
			}
			if {$cou(kpth)} {
				set otherfiles 1
				set thesefiles [ReverseList $cou(origthreadnams)]
				foreach fnam $thesefiles {
					FileToWkspace $fnam 0 0 0 0 1
				}
			}
			if {$cou(kprth)} {
				set otherfiles 1
				set thesefiles [ReverseList $rofnams]
				foreach fnam $thesefiles {
					FileToWkspace $fnam 0 0 0 0 1
				}
			}
			if {$cou(kpmix) && [file exists $cou(mixfnam)]} {
				FileToWkspace $cou(mixfnam) 0 0 0 0 1
				set otherfiles 1
			}
			if {[info exists cou(multibands)]} {
				set otherfiles 1
			}
			FileToWkspace $ofnam 0 0 0 0 1
			set cou(outsnd) $ofnam
			RememberCouState
			.couette.0.play config -text "Play output" -command "PlayCouOutput" -bd 2 -bg $evv(EMPH)
			UnBlock
			set msg "FILE $ofnam"
			if {$otherfiles} {
				append msg ", and others, are "
			} else {
				append msg " IS "
			}
			append msg "on the Workspace"
			Inf $msg
			set cou(samedata) 1
			.couette.0.f0.ff config -text "Create Another Flow"
		} else {
			set finished 1
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- Find appropriate textfiles, containing partials data

proc FindCouettePartialsFiles {} {
	global wl evv pa cou
	catch {unset cou(pfiles)}
	foreach fnam [$wl get 0 end] {
		set cnt [IsAVariPartialFile $fnam]
		if {$cnt > 0}  {
			lappend cou(pfiles) $fnam
			lappend cou(partialscnt) $cnt	;#	Stores number of partials in partials file
			lappend cou(multpartyp) 1		;#	Flags a varipartials file
		} elseif [IsABrkfile $pa($fnam,$evv(FTYP))] {
			if [catch {open $fnam "r"} zit] {
				continue
			}
			set OK 1
			set linecnt 0
			while {[gets $zit line] >= 0} {
				set line [string trim $line]
				if {[string length $line] <= 0} {
					continue
				}
				if {[string match [string index $line 0] ";"]} {
					continue
				}
				set line [split $line]
				set cnt 0
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] <= 0} {
						continue
					}
					switch -- $cnt {
						0 {
							if {$linecnt == 0} {
								if {$item != 1} {
									set OK 0
								}
							} elseif {$item < 1 || $item > 64} {
								set OK 0
							}
						} 
						1 {
							if {$item <= 0} {
								set OK 0
							}
						}
						default {
							set OK 0
						}
					}
					if {!$OK} {
						break
					}
					incr cnt
				}
				if {($cnt != 2) || (!$OK)} {
					break
				}
				incr linecnt
			}
			close $zit
			if {$OK} {
				lappend cou(pfiles) $fnam
				lappend cou(partialscnt) $linecnt	;#	Stores number of partials in partials file
				lappend cou(multpartyp) 0			;#	Flags partials filetype
			}
		}
	}
	if {![info exists cou(pfiles)]} {
		Inf "NO SUITABLE PARTIAL-DATA FILES EXIST"
		return 0
	}
	return 1
}

#---- Find textfiles, containing partials data

proc GetCouettePartialsFilesNotOnWkspace {fnam bandno} {
	global cou
	if {[FileToWkspace $fnam 0 0 0 0 1] <= 0} {
		return 0
	}
	if {[lsearch $cou(pfiles) $fnam] < 0} {
		set cnt [IsAVariPartialFile $fnam]
		if {$cnt <= 0}  {
			Inf "File $fnam is not a partials file"
			return 0
		} else {
			lappend cou(pfiles) $fnam
			lappend cou(partialscnt) $cnt	;#	Stores number of partials in partials file
			set cou(pcnt$bandno) $cnt
			lappend cou(multpartyp) 1		;#	Flags a varipartials file
			$cou(parlist) insert end $fnam
		}
	}
	return 1
}

#----- Get name of existing soundfile listing from display

proc GetCouPartialsFile {y} {
	global cou
	set i [$cou(parlist) nearest $y]
	if {$i < 0} {
		return
	}
	set fnam [$cou(parlist) get $i]
	if {$cou(which) <= 0} {
		ShowPartialsFile $fnam
		return
	}
	set n $cou(which)
	set cou(partials$n) $fnam
	set cou(pcnt$n) [lindex $cou(partialscnt) $i]
	set cou(multptyp$n) [lindex $cou(multpartyp) $i]
}

#----- Get name of existing soundfile listing from display

proc GetCouPartialsFileX {} {
	global cou
	set i [$cou(parlist) curselection]
	set n $cou(which)
	if {($i < 0) || ($n <= 0)} {
		return
	}
	set fnam [$cou(parlist) get $i]
	set cou(partials$n) $fnam
	set cou(pcnt$n) [lindex $cou(partialscnt) $i]
	set cou(multptyp$n) [lindex $cou(multpartyp) $i]
}

#--- Neutralise fine-detail params of packets

proc UnsetFineVariation {} {
	global cou
	set cou(pscat1) 0
	set cou(ascat1) 0
	set cou(octav1) 0
	set cou(bend1)  0
	set cou(pscat2) 0
	set cou(ascat2) 0
	set cou(octav2) 0
	set cou(bend2)  0
	set cou(pscat3) 0
	set cou(ascat3) 0
	set cou(octav3) 0
	set cou(bend3)  0
	set cou(pscat4) 0
	set cou(ascat4) 0
	set cou(octav4) 0
	set cou(bend4)  0
	set cou(bal1)  1
	set cou(bal2)  1
	set cou(bal3)  1
	set cou(bal4)  1
}

#---- Save params from Couette

proc SaveCouettePatch {} {
	global evv pr_savecou savecoufnam cou

	set fnam [file join $evv(URES_DIR) couette$evv(CDP_EXT)]

	set f .savecou
	if [Dlg_Create $f "SAVE PARAMETERS" "set pr_savecou 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.save -text "Save" -command "set pr_savecou 1" -bg $evv(EMPH)
		button $f.0.quit -text "Quit" -command "set pr_savecou 0"
		pack $f.0.save -side left
		pack $f.0.quit -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Patch name"
		entry $f.1.e -textvariable savecoufnam -width 20
		pack $f.1.ll $f.1.e -side left -padx 2
		pack $f.1 -side top
		wm resizable $f 0 0
		bind $f <Escape> {set pr_savecou 0}
		bind $f <Return> {set pr_savecou 1}
	}
	set savecoufnam $cou(ofnam)
	set pr_savecou 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_savecou
	while {!$finished} {
		tkwait variable pr_savecou
		if {!$pr_savecou} {
			break
		}
		if {![ValidCDPRootname $savecoufnam]} {
			continue
		}
		set thisnam [string tolower $savecoufnam] 
		if {[info exists cou(patches)]} {
			set OK 1
			foreach pp $cou(patches) {
				set nam [lindex $pp 0]
				if {[string match $nam $thisnam]} {
					Inf "This patchname already in use: chose a different name"
					set OK 0
					break
				}
			}
			if {!$OK} {
				continue
			}
		}
		set thispatch $thisnam
		lappend thispatch $cou(dur) $cou(bands) $cou(threads) $cou(tstep) $cou(bot) $cou(top) $cou(twist) $cou(rand) $cou(warp) 
		lappend thispatch $cou(vamp) $cou(vmin) $cou(vmax) $cou(turb) $cou(gap) $cou(minband) $cou(3d)
		lappend thispatch $cou(partials1) $cou(minrise1) $cou(maxrise1) $cou(minsus1) $cou(maxsus1) $cou(mindecay1) $cou(maxdecay1) $cou(speed1)
		lappend thispatch $cou(scat1) $cou(expr1) $cou(expd1) $cou(pscat1) $cou(ascat1) $cou(octav1) $cou(bend1)
		lappend thispatch $cou(partials2) $cou(minrise2) $cou(maxrise2) $cou(minsus2) $cou(maxsus2) $cou(mindecay2) $cou(maxdecay2) $cou(speed2)
		lappend thispatch $cou(scat2) $cou(expr2) $cou(expd2) $cou(pscat2) $cou(ascat2) $cou(octav2) $cou(bend2)
		lappend thispatch $cou(partials3) $cou(minrise3) $cou(maxrise3) $cou(minsus3) $cou(maxsus3) $cou(mindecay3) $cou(maxdecay3) $cou(speed3)
		lappend thispatch $cou(scat3) $cou(expr3) $cou(expd3) $cou(pscat3) $cou(ascat3) $cou(octav3) $cou(bend3) 
		lappend thispatch $cou(partials4) $cou(minrise4) $cou(maxrise4) $cou(minsus4) $cou(maxsus4) $cou(mindecay4) $cou(maxdecay4) $cou(speed4)
		lappend thispatch $cou(scat4) $cou(expr4) $cou(expd4) $cou(pscat4) $cou(ascat4) $cou(octav4) $cou(bend4)
		lappend thispatch $cou(seed) $cou(rot1) $cou(rot2) $cou(rot3) $cou(rot4)
		lappend thispatch $cou(rstt1) $cou(rstt2) $cou(rstt3) $cou(rstt4) $cou(rinc1) $cou(rinc2) $cou(rinc3) $cou(rinc4) $cou(chans)
		lappend thispatch $cou(fx) $cou(sz) $cou(echos) $cou(maxrev) $cou(prev)
		lappend thispatch $cou(refocus) $cou(ratio) $cou(rfstep) $cou(rfrand) $cou(rfoff) $cou(rfend) $cou(rftyp) $cou(rfnot)
		lappend thispatch $cou(bal1) $cou(bal2) $cou(bal3) $cou(bal4)
		lappend cou(patches) $thispatch
		.getcou.1.pp.list insert end $thisnam

		if {[file exists $fnam]} {
			if [catch {open $fnam "a"} zit] {
				Inf "Cannot open patch storage file $fnam"
				continue
			} 
		} else {
			if [catch {open $fnam "w"} zit] {
				Inf "Cannot create patch storage file $fnam"
				continue
			}
		}
		puts $zit $thispatch
		close $zit
		set cou(stored_patches) $cou(patches)
		set finished 1
	}
	if {[info exists cou(bandsset)]} {			;#	Value of cou(bands) has been reset to previous value , so previous patch can be saved
		set cou(bands) $cou(bandsset)			;#	Once finished saving (or not saving) reset the true value of cou(bands)
	}
	catch {unset cou(bandsset)}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#----- Load a parameter-set for couette

proc GetCouettePatch {delete} {
	global evv pr_getcou cou wstk wl
	set cou(rewrite) 0
	set fnam [file join $evv(URES_DIR) couette$evv(CDP_EXT)]

	if {!$delete} {		;#	If final- or start- value in any brkfiles are being displayed (instead of actual brkfile names)
		set restore 0	;#	Restore brkfile-names as params in display
		set nams [list twist rand warp vamp vmin vmax turb rot1 rot2 rot3 rot4]
		foreach nam $nams {
			set lastnam $nam
			append lastnam _last
			if {[info exists cou($lastnam)]} {
				set restore 1
				break
			}
		}
		if {$restore} {
			foreach nam $nams {
				set lastnam $nam
				append lastnam _last
				if {[info exists cou($lastnam)]} {
					set cou($nam) $cou($lastnam)
					unset cou($lastnam)
				}
			}
			return
		}
	}	
	set f .getcou
	if [Dlg_Create $f "GET PARAMETER PATCH" "set pr_getcou 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.save -text "Use" -command "set pr_getcou 1" -bg $evv(EMPH) -width 7
		button $f.0.quit -text "Quit" -command "set pr_getcou 0" -width 7
		pack $f.0.save -side left -padx 4
		pack $f.0.quit -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll	-text "PATCH NAMES" -fg $evv(SPECIAL)
		Scrolled_Listbox $f.1.pp -width 32 -height 24 -selectmode single
		pack $f.1.ll $f.1.pp -side top -pady 2
		pack $f.1 -side top
		wm resizable $f 0 0
		bind $f <Escape> {set pr_getcou 0}
	}
	if {$delete} {
		.getcou.0.save config -text "Delete" -command "set pr_getcou 2" -bd 2 -bg [option get . background {}]
		bind $f <Return> {}
	} else {
		.getcou.0.save config -text "Use" -command "set pr_getcou 1" -bd 2 -bg $evv(EMPH)
		bind $f <Return> {set pr_getcou 1}
	}
	.getcou.1.pp.list delete 0 end
	if {[info exists cou(patches)]} {
		foreach pp $cou(patches) {
			.getcou.1.pp.list insert end [lindex $pp 0]
		}
	}
	set pr_getcou 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_getcou
	while {!$finished} {
		tkwait variable pr_getcou
		switch -- $pr_getcou {
			1 {
				set i [.getcou.1.pp.list curselection]
				if {$i < 0}  {
					Inf "No patch selected"
					continue
				}
				PurgeCouBrkStateMem
				set thispatch [lindex $cou(patches) $i]
				set cou(dur)		[lindex $thispatch 1]
				set cou(bands)		[lindex $thispatch 2]
				set cou(threads)	[lindex $thispatch 3]
				set cou(tstep)		[lindex $thispatch 4]
				set cou(bot)		[lindex $thispatch 5]
				set cou(top)		[lindex $thispatch 6]
				set cou(twist)		[lindex $thispatch 7]
				set cou(rand)		[lindex $thispatch 8]
				set cou(warp)		[lindex $thispatch 9]
				set cou(vamp)		[lindex $thispatch 10]
				set cou(vmin)		[lindex $thispatch 11]
				set cou(vmax)		[lindex $thispatch 12]
				set cou(turb)		[lindex $thispatch 13]
				set cou(gap)		[lindex $thispatch 14]
				set cou(minband)	[lindex $thispatch 15]
				set cou(3d)			[lindex $thispatch 16]
				set cou(partials1)	[lindex $thispatch 17]
				set cou(minrise1)	[lindex $thispatch 18]
				set cou(maxrise1)	[lindex $thispatch 19]
				set cou(minsus1)	[lindex $thispatch 20]
				set cou(maxsus1)	[lindex $thispatch 21]
				set cou(mindecay1)	[lindex $thispatch 22]
				set cou(maxdecay1)	[lindex $thispatch 23]
				set cou(speed1)		[lindex $thispatch 24]
				set cou(scat1)		[lindex $thispatch 25]
				set cou(expr1)		[lindex $thispatch 26]
				set cou(expd1)		[lindex $thispatch 27]
				set cou(pscat1)		[lindex $thispatch 28]
				set cou(ascat1)		[lindex $thispatch 29]
				set cou(octav1)		[lindex $thispatch 30]
				set cou(bend1)		[lindex $thispatch 31]

				set cou(partials2)	[lindex $thispatch 32]
				set cou(minrise2)	[lindex $thispatch 33]
				set cou(maxrise2)	[lindex $thispatch 34]
				set cou(minsus2)	[lindex $thispatch 35]
				set cou(maxsus2)	[lindex $thispatch 36]
				set cou(mindecay2)	[lindex $thispatch 37]
				set cou(maxdecay2)	[lindex $thispatch 38]
				set cou(speed2)		[lindex $thispatch 39]
				set cou(scat2)		[lindex $thispatch 40]
				set cou(expr2)		[lindex $thispatch 41]
				set cou(expd2)		[lindex $thispatch 42]
				set cou(pscat2)		[lindex $thispatch 43]
				set cou(ascat2)		[lindex $thispatch 44]
				set cou(octav2)		[lindex $thispatch 45]
				set cou(bend2)		[lindex $thispatch 46]

				set cou(partials3)	[lindex $thispatch 47]
				set cou(minrise3)	[lindex $thispatch 48]
				set cou(maxrise3)	[lindex $thispatch 49]
				set cou(minsus3)	[lindex $thispatch 50]
				set cou(maxsus3)	[lindex $thispatch 51]
				set cou(mindecay3)	[lindex $thispatch 52]
				set cou(maxdecay3)	[lindex $thispatch 53]
				set cou(speed3)		[lindex $thispatch 54]
				set cou(scat3)		[lindex $thispatch 55]
				set cou(expr3)		[lindex $thispatch 56]
				set cou(expd3)		[lindex $thispatch 57]
				set cou(pscat3)		[lindex $thispatch 58]
				set cou(ascat3)		[lindex $thispatch 59]
				set cou(octav3)		[lindex $thispatch 60]
				set cou(bend3)		[lindex $thispatch 61]

				set cou(partials4)	[lindex $thispatch 62]
				set cou(minrise4)	[lindex $thispatch 63]
				set cou(maxrise4)	[lindex $thispatch 64]
				set cou(minsus4)	[lindex $thispatch 65]
				set cou(maxsus4)	[lindex $thispatch 66]
				set cou(mindecay4)	[lindex $thispatch 67]
				set cou(maxdecay4)	[lindex $thispatch 68]
				set cou(speed4)		[lindex $thispatch 69]
				set cou(scat4)		[lindex $thispatch 70]
				set cou(expr4)		[lindex $thispatch 71]
				set cou(expd4)		[lindex $thispatch 72]
				set cou(pscat4)		[lindex $thispatch 73]
				set cou(ascat4)		[lindex $thispatch 74]
				set cou(octav4)		[lindex $thispatch 75]
				set cou(bend4)		[lindex $thispatch 76]

				set cou(seed)		[lindex $thispatch 77]

				set cou(rot1)		[lindex $thispatch 78]
				set cou(rot2)		[lindex $thispatch 79]
				set cou(rot3)		[lindex $thispatch 80]
				set cou(rot4)		[lindex $thispatch 81]

				set cou(rstt1)		[lindex $thispatch 82]
				set cou(rstt2)		[lindex $thispatch 83]
				set cou(rstt3)		[lindex $thispatch 84]
				set cou(rstt4)		[lindex $thispatch 85]

				set cou(rinc1)		[lindex $thispatch 86]
				set cou(rinc2)		[lindex $thispatch 87]
				set cou(rinc3)		[lindex $thispatch 88]
				set cou(rinc4)		[lindex $thispatch 89]

				set cou(chans)		[lindex $thispatch 90]
				set cou(fx)			[lindex $thispatch 91]
				set cou(sz)			[lindex $thispatch 92]
				set cou(echos)		[lindex $thispatch 93]
				set cou(maxrev)		[lindex $thispatch 94]
				set cou(prev)		[lindex $thispatch 95]

				set cou(refocus)	[lindex $thispatch 96]
				CouDoRefocus
				set cou(ratio)		[lindex $thispatch 97]
				set cou(rfstep)		[lindex $thispatch 98]
				set cou(rfrand)		[lindex $thispatch 99]
				set cou(rfoff)		[lindex $thispatch 100]
				set cou(rfend)		[lindex $thispatch 101]
				set cou(rftyp)		[lindex $thispatch 102]
				set cou(rfnot)		[lindex $thispatch 103]

				set cou(bal1)		[lindex $thispatch 104]
				set cou(bal2)		[lindex $thispatch 105]
				set cou(bal3)		[lindex $thispatch 106]
				set cou(bal4)		[lindex $thispatch 107]

				set msg ""
				set k 1

				while {$k <= 4} {
					if {[string length $cou(partials$k)] > 0} {
						if {![file exists $cou(partials$k)]} {
							append msg "Partials file $cou(partials$k) no longer exists\n"
							set cou(partials$k) ""
						} else {
							set gotit 0
							set n 0
							foreach fnam [$cou(parlist) get 0 end] {
								if {[string match $cou(partials$k) $fnam]} {
									set cou(pcnt$k) [lindex $cou(partialscnt) $n]
									set cou(multptyp$k) [lindex $cou(multpartyp) $n]
									set gotit 1
									break
								}
								incr n
							}
							if {!$gotit} {
								if [GetCouettePartialsFilesNotOnWkspace $cou(partials$k) $k] {
									set gotit 1
								}
							}
							if {!$gotit} {
								append msg "File $cou(partials$k) is no longer a valid partials file\n"
								set cou(partials$k) ""
							}
						}
					}
					incr k
				}
				if {[string length $msg] > 0} {
					Inf $msg
				}
				set cou(ofnam) [lindex $thispatch 0]
				set finished 1
			}
			2 {
				set i [.getcou.1.pp.list curselection]
				if {$i < 0}  {
					Inf "No patch selected"
					continue
				}
				set msg "Are you sure you want to delete this patch ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				set pzfnam [.getcou.1.pp.list get $i]
				append pzfnam "_merge"										;#	Look for mergefiles assocd with a (merged) patch
				foreach zfnam [glob -nocomplain $pzfnam*] {
					if {[file exists $zfnam]} {								;#	If they exist
						set inpatches [IsFileInACouettePatch $zfnam]		;#	How many patches are they in ??
						if {[llength $inpatches] != 1} {					;#	If they're in no patches, or in more than one patch, ignore
							continue
						} elseif {$inpatches != $i} {						;#	If they're in one patch but NOT this one (impossible??), ignore		
							continue
						}
						set ii [LstIndx $zfnam $wl]							;#	Otherwise delete them
						if {$ii >= 0} {
							WkspCnt [$wl get $ii] -1
							$wl delete $ii
						}
						DeleteFileFromSystem $zfnam 1 1
					}
				}
				.getcou.1.pp.list delete $i
				set cou(patches) [lreplace $cou(patches) $i $i]
				if {[llength $cou(patches)] <= 0} {
					unset cou(patches)
					catch {file delete $fnam}
					catch {unset cou(stored_patches)}
					set finished 1
				} else {
					set cou(rewrite) 1
				}
			}
			0 {
				set finished 1
			}
		}
	}
	if {$cou(rewrite)} {
		if [catch {open $fnam "w"} zit] {
			Inf "Cannot rewrite patches in datafile $fnam : they will still load at next session"
		} else {
			foreach thispatch $cou(patches) {
				puts $zit $thispatch
			}
			close $zit
			set cou(stored_patches) $cou(patches)
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- Clear (most of) parameters for couette

proc ClearCouettePatch {band} {
	global cou wstk
	if {$band} {
		set cou(partials$band)	""
		set cou(minrise$band)	""
		set cou(maxrise$band)	""
		set cou(minsus$band)	""
		set cou(maxsus$band)	""
		set cou(mindecay$band)	""
		set cou(maxdecay$band)	""
		set cou(speed$band)		""
		set cou(scat$band)		""
		set cou(expr$band)		""
		set cou(expd$band)		""
		set cou(pscat$band)		""
		set cou(ascat$band)		""
		set cou(octav$band)		""
		set cou(bend$band)		""
		set cou(rot$band)		""
		set cou(bal$band)		""
	} else {
		set cou(dur)		""
		set cou(bands)		""
		set cou(threads)	""
		set cou(tstep)		""
		set cou(bot)		""
		set cou(top)		""
		set cou(twist)		""
		set cou(rand)		""
		set cou(warp)		""
		set cou(vamp)		""
		set cou(vmin)		""
		set cou(vmax)		""
		set cou(turb)		""
		set cou(gap)		""
		set cou(minband)	""
		set cou(3d)	-2
		set n 1
		while {$n <= 4} {
			set cou(partials$n)	""
			set cou(minrise$n)	""
			set cou(maxrise$n)	""
			set cou(minsus$n)	""
			set cou(maxsus$n)	""
			set cou(mindecay$n)	""
			set cou(maxdecay$n)	""
			set cou(speed$n)	""
			set cou(scat$n)		""
			set cou(expr$n)		""
			set cou(expd$n)		""
			set cou(pscat$n)	""
			set cou(ascat$n)	""
			set cou(octav$n)	""
			set cou(bend$n)		""
			set cou(bal$n)		""
			incr n
		}
		set cou(seed)		""
		set n 1
		while {$n <= 4} {
			set cou(rot$n)		""
			set cou(rstt$n)		""
			set cou(rinc$n)		""
			incr n
		}
		set cou(fx)			""
	}
}

#---- Load any existing couette patches

proc LoadCouettePatches {} {
	global cou evv
	set warned 0
	catch {unset cou(stored_patches)}
	set fnam [file join $evv(URES_DIR) couette$evv(CDP_EXT)]
	if {![info exists cou(patches)]} {
		if {![file exists $fnam]} {
			return
		}
		if [catch {open $fnam "r"} zit] { 
			Inf "Cannot open couette patches file $fnam to read patches"
			return
		}
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			if {[string match [string index $line 0] ";"]} {
				continue
			}
			catch {unset nuline}
			set line [split $line]
			set cnt 0
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				if {[IsCurlies $item]} {
					lappend nuline ""
				} else {
					lappend nuline $item
				}
				incr cnt
			}
			if {[llength $nuline] != 108} {
				if {!$warned} {
					Inf "Corrupted data in couette patches file $fnam"
					set warned 1
				}
				continue
			}
			lappend cou(patches) $nuline
			set cou(patches) [lsort -dictionary $cou(patches)]
		}
		set cou(stored_patches) $cou(patches)		
		close $zit
	}
}

#------- Find number of partials

proc CountPartials {bandno} {
	global cou wl
	if {[string length $cou(partials$bandno)] <= 0} {
		Inf "No partial file entered for band $bandno"
		return 0
	}
	if {![file exists $cou(partials$bandno)]} {
		Inf "Partials file $cou(partials$bandno) does not exist"
		return 0
	}
	if {[LstIndx $cou(partials$bandno) $wl] < 0} {
		if {![GetCouettePartialsFilesNotOnWkspace $cou(partials$bandno) $bandno]} {
			return 0
		}
	}
	if [catch {open $cou(partials$bandno) "r"} zit] {
		Inf "Cannot open partials file $cou(partials$bandno) to read number of partials for band $bandno: ignoring 3d data"
		return 0
	}
	set linecnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		set cnt 0
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			incr cnt
		}
		if {$cnt} {
			incr linecnt
		}
	}
	close $zit
	if {!$linecnt} {
		Inf "Cannot count partials in partials file $fnam"
		return 0
	}
	set partialrange [expr $linecnt - 1]		;#	Set range of partial counting

	return $partialrange
}

#---- Clear all partials-file parameters

proc ClearPartialFilesEntries {} {
	global cou
	set n 1
	while {$n <= 4} {
		set cou(partials$n) ""
		incr n
	}
}

#--- Locate empty string marked by "{}" in a file and replace it by "" in the list-object
#--- (Direct download of "{}" from a file, leads to "{{}}" inside list-object)

proc IsCurlies {str} {
	if {[regexp {^\{} $str]} {
		return 1
	}
	return  0
}

proc CouetteHelp {} {
	global evv pr_couhelp
	set f .couhelp
	if [Dlg_Create $f "COUETTE HELP" "set pr_couhelp 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.cou -text "Overview"		-command "Couette_Help" -width 15
		button $f.0.str -text "Banded Flow"     -command "CDP_Specific_Usage $evv(STRANDS) 1" -width 15
		button $f.0.dff -text "Different Bands" -command "CDP_Specific_Usage $evv(STRANDS) 3" -width 15
		button $f.0.pul -text "Packet Stream"   -command "CDP_Specific_Usage $evv(PULSER) 1"  -width 15
		button $f.0.rfc -text "Focus Layers"    -command "CDP_Specific_Usage $evv(REFOCUS) 1" -width 15
		button $f.0.pat -text "Patch Ops"		-command "CouettePatchOps" -width 15
		button $f.0.quit -text "Quit"  -command "set pr_couhelp 1" -width 15
		pack $f.0.cou $f.0.str $f.0.dff $f.0.pul $f.0.rfc $f.0.pat -side left -padx 2
		pack $f.0.quit -side right -padx 8
		pack $f.0 -side top -fill x -expand true
		wm resizable $f 0 0
		bind $f <Escape> {set pr_couhelp 0}
		bind $f <Return> {set pr_couhelp 1}
	}
	set pr_couhelp 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_couhelp
	tkwait variable pr_couhelp
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#------ Help for Couette Flow

proc Couette_Help {} {
	set msg "TAYLOR-COUETTE FLOW\n"	
	append msg "\n"
	append msg "Synthesis of several musical lines (pitch-threads), organised into groups (bands).\n"
	append msg "The threads in a band (can) spiral around one another.\n"
	append msg "Adjacent bands spiral in opposite directions.\n"
	append msg "\n"
	append msg "For more details, see the synthesis process \"BANDED FLOW\".\n"
	append msg "or (for bands with different numbers of threads) \"DIFFERENT BANDS\"\n"
	append msg "\n"
	append msg "Up to 4 bands can be specified, each containing up to 100 threads.\n"
	append msg "\n"
	append msg "Pitch data is used to control the synthesis of pulsing lines.\n"
	append msg "\n"
	append msg "For more details, see the synthesis process \"PACKET STREAM\"\n"
	append msg "\n"
	append msg "The output bands are rotated around an N-channel output space\n"
	append msg "at a specified speed (rotations-per-second).\n"
	append msg "\n"
	append msg "The start spatial-location of the 1st thread in the band can be specified.\n"
	append msg "The start locations of the other threads in the band are offset from this\n"
	append msg "by the number of channels specified (\"Rotation StartChan Offset-per-thread\").\n"
	append msg "\n"
	append msg "With \n"RADIAL DISTANCE CUES\" set as \"None\" bands will only move in the plane of the lspkrs.\n"
	append msg "\n"
	append msg "Otherwise bands are \"3D\", ALSO rotating (apparently) in the near-far direction.\n"
	append msg "\n"
	append msg "In this case, you must set \"Reverb-in-mix range\n" and the other \"3D\" parameters.\n"
	append msg "and the process outputs two extra data-sets....\n"
	append msg "(1)  The 1st set of control files can control the partials count during synthesis.\n"
	append msg "          (for varying the brightness of the source with distance from the listener)."\n"
	append msg "(2)  The 2nd set can control the varying level of reverb applied to the threads as they rotate.\n"
	append msg "\n"
	append msg "If the reverb range is zero, no reverb is used.\n"
	append msg "Otherwise,\n"
	append msg "(1)  The balance of the reverb file in the mix\n"
	append msg "        runs from \"max reverb\" DOWNWARDS by the range specified.\n"
	append msg "        So a max of 0.8 and a range of 0.6 runs from 0.8 down to 0.2\n"
	append msg "(2)  \"size\" is the Stadium size multiplier (0.01 to 1)\n"
	append msg "(3)  \"echoes\" is the Number of echoes (8 to 1000).\n"
	append msg "\n"
	append msg "The reverbd sound is mixed with the original\n"
	append msg "their mutual level controlled by the appropriate data file.\n"
	append msg "\n"
	append msg "The \"Partials in reverbd sound\" parameter allows a set of complementary threads\n"
	append msg "with (possibly) fewer partials than the original threads, to be created.\n"
	append msg "Any reverb is then applied to these complementary threads\n"
	append msg "but the resulting sound is finally mixed with the original threads.\n"
	append msg "\n"
	append msg "If the control files are saved (\"Also save... Control Data\")\n"
	append msg "these can be submitted as input files (on Chosen Files list)\n"
	append msg "and re-utilised (tick the \"Input control data\" box).\n"
	append msg "\n"
	append msg "REFOCUS brings each band in turn into focus\n"
	append msg "For more details see the envelope process \"FOCUS LAYERS\".\n"
	append msg "\n"
	Inf $msg
}


proc CouettePatchOps {} {
	set msg "TAYLOR-COUETTE PATCH OPERATIONS\n"	
	append msg "\n"
	append msg "SAVE:    Saves the current values on the display as a (named) patch.\n"
	append msg "\n"
	append msg "LOAD:    Loads a previously saved (and named) patch to the display.\n"
	append msg "\n"
	append msg "DELETE:  Allows specific saved (named) patches to be deleted.\n"
	append msg "\n"
	append msg "CLEAR:   Clears most of the parameters in the display.\n"
	append msg "\n"
	append msg "STARTV:  Displays values at time zero in any brkpoint-file parameters.\n"
	append msg "                      (Redisplay with brkfile names, by hitting \"LOAD\").\n"
	append msg "\n"
	append msg "ENDVAL:  Displays values at last times in any brkpoint-file parameters.\n"
	append msg "                      (Redisplay with brkfile names, by hitting \"LOAD\").\n"
	append msg "\n"
	append msg "MERGE:   Allows a sequence of patches to be time-abutted,\n"
	append msg "                      to make a combined patch.\n"
	append msg "\n"
	append msg "TIMEWP:  Timewarp (brkfiles etc. of) a particular patch.\n"
	append msg "\n"
	Inf $msg
}

#---- Convert exponential-type number-representations to decimals
#
#	8.9e-005 --> 0.000089
#	3.9e-005 --> 0.000039
#	1e-005   --> 0.00001

proc TranslateExpRepresentation {val} {

	set nuval "0.000000"
	set k [string first "e" $val]
	if {$k < 0} {
		return $val
	}
	incr k 2												;#	k at 005
	if {[string match [string index $val $k] "0"]} {		;#	if exponent < e100
		incr k												;#	k at 05
		if {[string match [string index $val $k] "0"]} {	;#	if expoment < e010
			incr k											;#	k at 5			
			set zerocnt [string index $val $k]
			if {$zerocnt < 7} {								;#	if exponent < e007
				incr zerocnt -1								;#	no of zeros after dec place
				set nuval "0."
				set j 0
				while {$j < $zerocnt} {
					append nuval "0"
					incr j
				}
				set k 0
				set digit [string index $val $k]			;#	k at 8.9e
				while {![string match $digit "e"]} {
					if {![string match $digit "."]} {
						append nuval $digit
					}
					incr k
					set digit [string index $val $k]
				}
			}
		}
	}
	return $nuval
}

#-- Display a partials file

proc ShowPartialsFile {fnam} {
	set linecnt 0
	if [catch {open $fnam "r"} zit] {
		return
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		incr linecnt
		lappend lines $line
	}
	close $zit
	if {$linecnt} {
		set msg [lindex $lines 0]
		set n 1
		while {$n < $linecnt} {
			append msg "\n[lindex $lines $n]"
			incr n
		}
		Inf $msg
	}
}

#--- Copy all band params across from a lower band

proc CopyPacketParams {band} {
	global cou
	set n [expr $band - 1]
	while {$n >= 1} {
		set OK 1
		while {$OK} {
			if {[string length [string trim $cou(partials$n)]] == 0} {
				set OK 0
				break
			}
			if {[string length [string trim $cou(minrise$n)]] == 0} {
				set OK 0
				break
			}
			if {[string length [string trim $cou(maxrise$n)]] == 0} {
				set OK 0
				break
			}
			if {[string length [string trim $cou(minsus$n)]] == 0} {
				set OK 0
				break
			}
			if {[string length [string trim $cou(maxsus$n)]] == 0} {
				set OK 0
				break
			}
			if {[string length [string trim $cou(mindecay$n)]] == 0} {
				set OK 0
				break
			}
			if {[string length [string trim $cou(maxdecay$n)]] == 0} {
				set OK 0
				break
			}
			if {[string length [string trim $cou(speed$n)]] == 0} {
				set OK 0
				break
			}
			if {[string length [string trim $cou(scat$n)]] == 0} {
				set OK 0
				break
			}
			if {[string length [string trim $cou(expr$n)]] == 0} {
				set OK 0
				break
			}
			if {[string length [string trim $cou(expd$n)]] == 0} {
				set OK 0
				break
			}
			if {[string length [string trim $cou(pscat$n)]] == 0} {
				set OK 0
				break
			}
			if {[string length [string trim $cou(ascat$n)]] == 0} {
				set OK 0
				break
			}
			if {[string length [string trim $cou(octav$n)]] == 0} {
				set OK 0
				break
			}
			if {[string length [string trim $cou(bend$n)]] == 0} {
				set OK 0
			}
			if {[string length [string trim $cou(bal$n)]] == 0} {
				set OK 0
			}
			break
		}
		if {$OK} {
			set cou(partials$band)	$cou(partials$n)
			set cou(minrise$band)	$cou(minrise$n)
			set cou(maxrise$band)	$cou(maxrise$n)
			set cou(minsus$band)	$cou(minsus$n)
			set cou(maxsus$band)	$cou(maxsus$n)
			set cou(mindecay$band)	$cou(mindecay$n)
			set cou(maxdecay$band)	$cou(maxdecay$n)
			set cou(speed$band)		$cou(speed$n)
			set cou(scat$band)		$cou(scat$n)
			set cou(expr$band)		$cou(expr$n)
			set cou(expd$band)		$cou(expd$n)
			set cou(pscat$band)		$cou(pscat$n)
			set cou(ascat$band)		$cou(ascat$n)
			set cou(octav$band)		$cou(octav$n)
			set cou(bend$band)		$cou(bend$n)
			set cou(bal$band)		$cou(bal$n)
			break
		}
		incr n -1
	}
	set cou(cop$band) 0
}

#---- Find names of temporary files that are being retained

proc CouGetRetainedTempFiles {} {
	global cou evv
	set fnams {}
	if {[info exists cou(threaddatafiles)]} {
		set fnam [lindex $cou(threaddatafiles) 0]
		if {[string first $evv(DFLT_OUTNAME) $fnam] == 0} {
			foreach fnam $cou(threaddatafiles) {
				lappend fnams $fnam
			}
		}
	}

	if {[info exists cou(controlfiles1)]} {
		set fnam [lindex $cou(controlfiles1) 0]
		if {[string first $evv(DFLT_OUTNAME) $fnam] == 0} {
			foreach fnam $cou(controlfiles1) {
				lappend fnams $fnam
			}
		}
	}
	if {[info exists cou(controlfiles2)]} {
		set fnam [lindex $cou(controlfiles2) 0]
		if {[string first $evv(DFLT_OUTNAME) $fnam] == 0} {
			foreach fnam $cou(controlfiles2) {
				lappend fnams $fnam
			}
		}
	}
	return $fnams
}

proc CouGetRetainedRefocusFiles {} {
	global cou
	set fnams {}
	if {[info exists cou(rfenvs)]} {
		foreach fnam $cou(rfenvs) {
			lappend fnams $fnam
		}
	}
	return $fnams
}

#----- Delete (various categories of) temporary files which are NOT outputs of CDP processes.

proc DeleteAllOtherFormatTemporaryFiles {} {
	global evv
	set outfname $evv(MACH_OUTFNAME)
	set fnams [glob -nocomplain "$outfname*"]
	foreach fnam $fnams {
		catch {file delete -force $fnam}
	}
}

#--- Display partials in file in response to mouse click

proc ShowPartials {band} {
	set fval [.couette.1.1.1.e$band cget -textvariable]
	upvar $fval fnam
	if {[string length $fnam] > 0} {
		ShowPartialsFile $fnam
	}
}

#--- Find potential parameter files

proc GetCouParamFiles {} {
	global wl pa evv cou
	set n 7
	while {$n <= 13} {
		set cou(paramfiles$n) {}
		foreach fnam [$wl get 0 end] {
			if {[IsABrkfile $pa($fnam,$evv(FTYP))]} {
				if {($pa($fnam,$evv(MINBRK)) >= [lindex $cou(courbot) $n]) && ($pa($fnam,$evv(MAXBRK)) <= [lindex $cou(courtop) $n]) } {
					lappend cou(paramfiles$n) $fnam
				}
			}
		}
		if {[llength $cou(paramfiles$n)] > 1} {
			set cou(paramfiles$n) [lsort -dictionary $cou(paramfiles$n)]
		}
		incr n
	}
	set cou(paramfiles3) {}
	foreach fnam [$wl get 0 end] {
		if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
			if {($pa($fnam,$evv(MINNUM)) >= [lindex $cou(courbot) 3]) && ($pa($fnam,$evv(MAXNUM)) <= [lindex $cou(courtop) 3]) } {
				lappend cou(paramfiles3) $fnam
			}
		}
	}
	if {[llength $cou(paramfiles3)] > 1} {
		set cou(paramfiles3) [lsort -dictionary $cou(paramfiles3)]
	}
	set n 78
	while {$n <= 81} {
		set cou(paramfiles$n) {}
		foreach fnam [$wl get 0 end] {
			if {[IsABrkfile $pa($fnam,$evv(FTYP))]} {
				if {($pa($fnam,$evv(MINBRK)) >= [lindex $cou(courbot) 33]) && ($pa($fnam,$evv(MAXBRK)) <= [lindex $cou(courtop) 33]) } {
					lappend cou(paramfiles$n) $fnam
				}
			}
		}
		if {[llength $cou(paramfiles$n)] > 1} {
			set cou(paramfiles$n) [lsort -dictionary $cou(paramfiles$n)]
		}
		incr n
	}
}

#--- Display potential parameter files in response to Control-Click

proc ListCouParamFiles {n} {
	global cou wl pa evv pr_coupshow
	if {[llength $cou(paramfiles$n)] <= 0} {
		return
	}
	set f .coupshow
	if [Dlg_Create $f "POSSIBLE PARAMETER FILES" "set pr_coupshow 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.ok -text "Select" -command "set pr_coupshow 1" -width 8
		button $f.0.sort -text "Sort" -command "set pr_coupshow 2" -width 8
		button $f.0.restore -text "Unsort"  -command "set pr_coupshow 3" -width 8
		button $f.0.refresh -text "Refresh" -command "set pr_coupshow 4" -width 8
		button $f.0.quit -text "Quit"  -command "set pr_coupshow 0"
		pack $f.0.ok $f.0.sort $f.0.restore $f.0.refresh -side left -padx 2
		pack $f.0.quit -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1 
		label $f.1.ll -text	"" -fg $evv(SPECIAL)
		label $f.1.ll2 -text "Command-Click on Filename to see contents"
		Scrolled_Listbox $f.1.pp -width 32 -height 24 -selectmode single
		pack $f.1.ll $f.1.ll2 $f.1.pp -side top -pady 2
		pack $f.1 -side top
		wm resizable $f 0 0
		bind $f <Escape> {set pr_coupshow 0}
		bind $f <Return> {set pr_coupshow 1}
		bind $f.1.pp.list <Command-ButtonRelease> {ShowCouParamFile}
	}
	switch -- $n {
		3 {
			.coupshow.1.ll config -text "Thread count"
		}
		7 {
			.coupshow.1.ll config -text "Twist speed"
		}
		8 {
			.coupshow.1.ll config -text "Twist randomise"
		}
		9 {
			.coupshow.1.ll config -text "Twist warp"
		}
		10 {
			.coupshow.1.ll config -text "Waviness size"
		}
		11 {
			.coupshow.1.ll config -text "Waviness minfrq"
		}
		12 {
			.coupshow.1.ll config -text "Waviness maxfrq"
		}
		13 {
			.coupshow.1.ll config -text "Turbulence"
		}
		default {
			.coupshow.1.ll config -text "Rotation speed"
		}
	}
	.coupshow.1.pp.list delete 0 end
	foreach fnam $cou(paramfiles$n) {
		.coupshow.1.pp.list insert end $fnam
	}

	set pr_coupshow 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_coupshow
	set finished 0
	while {!$finished} {
		tkwait variable pr_coupshow
		switch -- $pr_coupshow {
			1 {
				set i [.coupshow.1.pp.list curselection]
				if {![info exists i] || ([string length $i] < 0)} {
					if {[.coupshow.1.pp.list index end] == 1} {
						set fnam [.coupshow.1.pp.list get 0]
					} else {
						continue
					}
				} else {
					set fnam [.coupshow.1.pp.list  get $i]
				}
				switch -- $n {
					3  { set cou(threads) $fnam}
					7  { set cou(twist) $fnam }
					8  { set cou(rand)  $fnam }
					9  { set cou(warp)  $fnam }
					10 { set cou(vamp)  $fnam }
					11 { set cou(vmin)  $fnam }
					12 { set cou(vmax)  $fnam }
					13 { set cou(turb)  $fnam }
					78 { set cou(rot1)  $fnam }
					79 { set cou(rot2)  $fnam }
					80 { set cou(rot3)  $fnam }
					81 { set cou(rot4)  $fnam }
				}
				if {$i != 0} {
					set cou(paramfiles$n) [lreplace $cou(paramfiles$n) $i $i]
					set cou(paramfiles$n) [concat $fnam $cou(paramfiles$n)]
				}
				set finished 1
			}
			0 {
				set finished 1
			}
			2 {
				set origorder $cou(paramfiles$n)
				set cou(paramfiles$n) [lsort -dictionary $cou(paramfiles$n)]
				.coupshow.1.pp.list delete 0 end
				foreach fnam $cou(paramfiles$n) {
					.coupshow.1.pp.list insert end $fnam
				}
			}
			3 {
				if {[info exists origorder]} {
					.coupshow.1.pp.list delete 0 end
					foreach fnam $origorder {
						.coupshow.1.pp.list insert end $fnam
					}
					unset origorder
				}
			} 4 {
				GetCouParamFiles
				.coupshow.1.pp.list delete 0 end
				foreach fnam $cou(paramfiles$n) {
					.coupshow.1.pp.list insert end $fnam
				}
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Display parameter file in response to Command-Click on FIle-selection window

proc ShowCouParamFile {} {
	set i [.coupshow.1.pp.list curselection]
	if {![info exists i] || ([string length $i] <= 0)} {
		if {[.coupshow.1.pp.list index end] == 1} {
			set i 0
		} else {
			return
		}
	}
	ShowPartialsFile [.coupshow.1.pp.list get $i]
}

#--- Display parameter file in response to Command-Click on Main Couette window

proc DisplayParamFile {n} {
	global cou wl pa evv pr_coupshow
	switch -- $n {
		3  { set fnam $cou(threads)}
		7  { set fnam $cou(twist)  }
		8  { set fnam $cou(rand)   }
		9  { set fnam $cou(warp)   }
		10 { set fnam $cou(vamp)   }
		11 { set fnam $cou(vmin)   }
		12 { set fnam $cou(vmax)   }
		13 { set fnam $cou(turb)   }
		78 { set fnam $cou(rot1)   }
		79 { set fnam $cou(rot2)   }
		80 { set fnam $cou(rot3)   }
		81 { set fnam $cou(rot4)   }
	 }
	if {([llength $fnam] <= 0) || [IsNumeric $fnam]} {
		return
	}
	if {![file exists $fnam]} {
		Inf "File $fnam does not exist"
		return
	}
	ShowPartialsFile $fnam
}

#--- Display (or not) the refocus parameters block

proc CouDoRefocus {} {
	global cou
	if {$cou(refocus)} {
		.couette.1.2.ff.1.e config -state normal -bd 2
		.couette.1.2.ff.1.ll config -text "Focusing ratio (>1)"
		.couette.1.2.ff.2.e config -state normal -bd 2
		.couette.1.2.ff.2.ll config -text "Refocusing timestep"
		.couette.1.2.ff.3.e config -state normal -bd 2
		.couette.1.2.ff.3.ll config -text "Randomisation of timestep"
		.couette.1.2.ff.4.e config -state normal -bd 2
		.couette.1.2.ff.4.ll config -text "Refocusing offset"
		.couette.1.2.ff.5.e config -state normal -bd 2
		.couette.1.2.ff.5.ll config -text "Refocusing end"
		.couette.1.2.ff.6.e config -state normal -bd 2
		.couette.1.2.ff.6.ll config -text "Refocusing type"
		.couette.1.2.ff.7.ch config -state normal -bd 2
		.couette.1.2.ff.7.ll config -text "Don't emphasize top band"
		if {[info exists cou(wasratio)]} { 
			set cou(ratio) $cou(wasratio)
		}
		if {[info exists cou(wasrfstep)]} { 
			set cou(rfstep) $cou(wasrfstep)
		}
		if {[info exists cou(wasrfrand)]} { 
			set cou(rfrand) $cou(wasrfrand)
		}
		if {[info exists cou(wasrfoff)]} { 
			set cou(rfoff) $cou(wasrfoff)
		}
		if {[info exists cou(wasrfend)]} { 
			set cou(rfend) $cou(wasrfend)
		}
		if {[info exists cou(wasrftyp)]} { 
			set cou(rftyp) $cou(wasrftyp)
		}
		if {[info exists cou(wasrfnot)]} { 
			set cou(rfnot) $cou(wasrfnot)
		}
	} else {
		set cou(wasratio) $cou(ratio)
		set cou(wasrfstep) $cou(rfstep)
		set cou(wasrfrand) $cou(rfrand)
		set cou(wasrfoff) $cou(rfoff)
		set cou(wasrfend) $cou(rfend)
		set cou(wasrftyp) $cou(rftyp)
		set cou(wasrfnot) $cou(rfnot)
		set cou(ratio)	""
		set cou(rfstep)	""
		set cou(rfrand)	""
		set cou(rfoff)	""
		set cou(rfend)	""
		set cou(rftyp)	""
		set cou(rfnot)	0
		.couette.1.2.ff.1.e config -disabledbackground [option get . background {}] -state disabled -bd 0
		.couette.1.2.ff.1.ll config -text ""
		.couette.1.2.ff.2.e config -disabledbackground [option get . background {}] -state disabled -bd 0
		.couette.1.2.ff.2.ll config -text ""
		.couette.1.2.ff.3.e config -disabledbackground [option get . background {}] -state disabled -bd 0
		.couette.1.2.ff.3.ll config -text ""
		.couette.1.2.ff.4.e config -disabledbackground [option get . background {}] -state disabled -bd 0
		.couette.1.2.ff.4.ll config -text ""
		.couette.1.2.ff.5.e config -disabledbackground [option get . background {}] -state disabled -bd 0
		.couette.1.2.ff.5.ll config -text ""
		.couette.1.2.ff.6.e config -disabledbackground [option get . background {}] -state disabled -bd 0
		.couette.1.2.ff.6.ll config -text ""
		.couette.1.2.ff.7.ch config -state disabled -bd 0
		.couette.1.2.ff.7.ll config -text ""
	}
}

#--- Conditional bindings for refocus boxes

proc DoCouBind {n} {
	global cou
	switch -- $n {
		15 {
			if {$cou(refocus)} {
				focus .couette.1.2.ff.1.e
			} else {
				focus .couette.1.1.15.e1
			}
		}
		16 {
			if {$cou(refocus)} {
				focus .couette.1.2.ff.4.e
			} else {
				focus .couette.1.1.16.e1
			}
		}
		17 {
			if {$cou(refocus)} {
				focus .couette.1.2.ff.5.e
			} else {
				focus .couette.1.1.17.e1
			}
		}
		18 {
			if {$cou(refocus)} {
				focus .couette.1.2.ff.6.e
			} else {
				focus .couette.1.1.18.e1
			}
		}
		19 {
			if {$cou(refocus)} {
				focus .couette.1.2.ff.6.e
			} else {
				focus .couette.1.1.19.e1
			}
		}
	}
}

#---- Remember and check changes in parameter states

proc RememberCouRefocusState {} {
	global coulastrf cou
	set coulastrf(refocus)	$cou(refocus)
	set coulastrf(ratio)	$cou(ratio)
	set coulastrf(rfstep)	$cou(rfstep)
	set coulastrf(rfrand)	$cou(rfrand)
	set coulastrf(rfoff)	$cou(rfoff)
	set coulastrf(rfend)	$cou(rfend)
	set coulastrf(rftyp)	$cou(rftyp)
	set coulastrf(rfnot)	$cou(rfnot)
}

proc RememberCouState {} {
	global cou coulastthr coulastpak coulastrot coulastrf
	set coulastthr(dur)		$cou(dur)
	set coulastthr(bands)	$cou(bands)
	set coulastthr(threads) $cou(threads)
	set coulastthr(tstep)	$cou(tstep)
	set coulastthr(bot)		$cou(bot)
	set coulastthr(top)		$cou(top)
	set coulastthr(twist)	$cou(twist)
	set coulastthr(rand)	$cou(rand)
	set coulastthr(warp)	$cou(warp)
	set coulastthr(vamp)	$cou(vamp)
	set coulastthr(vmin)	$cou(vmin)
	set coulastthr(vmax)	$cou(vmax)
	set coulastthr(turb)	$cou(turb)
	set coulastthr(gap)		$cou(gap)
	set coulastthr(minband) $cou(minband)
	set coulastthr(3d)	  	$cou(3d)
	set coulastthr(seed)	$cou(seed)

	set cou(lastkpcd)		$cou(kpcd)
	set cou(lastkpth)		$cou(kpth)
															;#	If in the previous run we created all the bands (cou(lastonly) == 0),
	if {($cou(lastonly) == 0) && $cou(samethreads)} {		;#	and in the current run we have changed no bands,
		set cou(lastonly) 0									;#	then retain the indication that all bands still exist

	} else {												;#	If in the previous run we had NOT created all the bands,
		set cou(lastonly)		$cou(only)					;#	and in the current run we created a specific band
	}														;#	remember which band it is that exists.

	set coulastpak(partials1)	$cou(partials1)
	set coulastpak(minrise1)	$cou(minrise1)
	set coulastpak(maxrise1)	$cou(maxrise1)
	set coulastpak(minsus1)		$cou(minsus1)
	set coulastpak(maxsus1)		$cou(maxsus1)
	set coulastpak(mindecay1)	$cou(mindecay1)
	set coulastpak(maxdecay1)	$cou(maxdecay1)
	set coulastpak(speed1)		$cou(speed1)
	set coulastpak(scat1)		$cou(scat1)
	set coulastpak(expr1)		$cou(expr1)
	set coulastpak(expd1)		$cou(expd1)
	set coulastpak(pscat1)		$cou(pscat1)
	set coulastpak(ascat1)		$cou(ascat1)
	set coulastpak(octav1)		$cou(octav1)
	set coulastpak(bend1)		$cou(bend1)

	set coulastpak(partials2)	$cou(partials2)
	set coulastpak(minrise2)	$cou(minrise2)
	set coulastpak(maxrise2)	$cou(maxrise2)
	set coulastpak(minsus2)		$cou(minsus2)
	set coulastpak(maxsus2)		$cou(maxsus2)
	set coulastpak(mindecay2)	$cou(mindecay2)
	set coulastpak(maxdecay2)	$cou(maxdecay2)
	set coulastpak(speed2)		$cou(speed2)
	set coulastpak(scat2)		$cou(scat2)
	set coulastpak(expr2)		$cou(expr2)
	set coulastpak(expd2)		$cou(expd2)
	set coulastpak(pscat2)		$cou(pscat2)
	set coulastpak(ascat2)		$cou(ascat2)
	set coulastpak(octav2)		$cou(octav2)
	set coulastpak(bend2)		$cou(bend2)

	set coulastpak(partials3)	$cou(partials3)
	set coulastpak(minrise3)	$cou(minrise3)
	set coulastpak(maxrise3)	$cou(maxrise3)
	set coulastpak(minsus3)		$cou(minsus3)
	set coulastpak(maxsus3)		$cou(maxsus3)
	set coulastpak(mindecay3)	$cou(mindecay3)
	set coulastpak(maxdecay3)	$cou(maxdecay3)
	set coulastpak(speed3)		$cou(speed3)
	set coulastpak(scat3)		$cou(scat3)
	set coulastpak(expr3)		$cou(expr3)
	set coulastpak(expd3)		$cou(expd3)
	set coulastpak(pscat3)		$cou(pscat3)
	set coulastpak(ascat3)		$cou(ascat3)
	set coulastpak(octav3)		$cou(octav3)
	set coulastpak(bend3)		$cou(bend3)

	set coulastpak(partials4)	$cou(partials4)
	set coulastpak(minrise4)	$cou(minrise4)
	set coulastpak(maxrise4)	$cou(maxrise4)
	set coulastpak(minsus4)		$cou(minsus4)
	set coulastpak(maxsus4)		$cou(maxsus4)
	set coulastpak(mindecay4)	$cou(mindecay4)
	set coulastpak(maxdecay4)	$cou(maxdecay4)
	set coulastpak(speed4)		$cou(speed4)
	set coulastpak(scat4)		$cou(scat4)
	set coulastpak(expr4)		$cou(expr4)
	set coulastpak(expd4)		$cou(expd4)
	set coulastpak(pscat4)		$cou(pscat4)
	set coulastpak(ascat4)		$cou(ascat4)
	set coulastpak(octav4)		$cou(octav4)
	set coulastpak(bend4)		$cou(bend4)

	set coulastpak(fx)		$cou(fx)
	set coulastpak(sz)		$cou(sz)
	set coulastpak(echos)	$cou(echos)
	set coulastpak(maxrev)	$cou(maxrev)
	set coulastpak(prev)	$cou(prev)

	set coulastrot(rot1)	$cou(rot1)
	set coulastrot(rot2)	$cou(rot2)
	set coulastrot(rot3)	$cou(rot3)
	set coulastrot(rot4)	$cou(rot4)
	set coulastrot(rstt1)	$cou(rstt1)
	set coulastrot(rstt2)	$cou(rstt2)
	set coulastrot(rstt3)	$cou(rstt3)
	set coulastrot(rstt4)	$cou(rstt4)
	set coulastrot(rinc1)	$cou(rinc1)
	set coulastrot(rinc2)	$cou(rinc2)
	set coulastrot(rinc3)	$cou(rinc3)
	set coulastrot(rinc4)	$cou(rinc4)
	set coulastrot(chans)	$cou(chans)

	set coulastbal(bal1)	$cou(bal1)
	set coulastbal(bal2)	$cou(bal2)
	set coulastbal(bal3)	$cou(bal3)
	set coulastbal(bal4)	$cou(bal4)
	RememberCouRefocusState
}

#---- Have thread pitch parameters been changed ??

proc IsSameCouThreadData {} {
	global cou coulastthr
	if {![info exists coulastthr]} {
		return 0
	}
	foreach nam [array names coulastthr] {
		if {![string match $coulastthr($nam) $cou($nam)]} {
			return 0
		}
	}
	return 1
}

#---- Are thread sounds different

proc IsSameCouSound {} {
	global cou coulastpak
	if {![IsSameCouThreadData]} {								;#	Are the pitch lines the same
		return 0
	}
	if {![info exists coulastpak]} {
		return 0
	}
	foreach nam [array names coulastpak] {						;#	Is the packeting the same
		if {![string match $coulastpak($nam) $cou($nam)]} {
			return 0
		}
	}
	if {![info exists cou(origthreadnams)]} {					;#	Do the original sound threads exist
		return 0
	}
	if {[info exists cou(multithreads)]} {
		set threadcount $cou(threadcnt)
	} else {
		set threadcount [expr $cou(bands) * $cou(threads)]
	}
	if {[llength $cou(origthreadnams)] != $threadcount} {		;#	If all bands exist, no worries.
		if {$cou(only) != $cou(lastonly)} {						;#	else if band number has changed, required sound threads not yet made
			return 0
		}
	}
	return 1
}

#---- Are thread sounds different

proc IsSameCouRotation {} {
	global cou coulastrot
	if {![info exists coulastrot]} {
		return 0
	}
	foreach nam [array names coulastrot] {
		if {![string match $coulastrot($nam) $cou($nam)]} {
			return 0
		}
	}
	return 1
}

#---- Is balance of bands different

proc IsSameCouBalance {} {
	global cou coulastbal
	if {![info exists coulastbal]} {
		return 0
	}
	foreach nam [array names coulastbal] {
		if {![string match $coulastbal($nam) $cou($nam)]} {
			return 0
		}
	}
	return 1
}

#---- Check if refocus params have changed

proc IsSameCouRefocus {} {
	global cou coulastrf

	if {![info exists coulastrf(refocus)]} {		;#	No previous refocusing values have been set
		return 0
	}
	foreach nam [array names coulastrf] {			;#	Current refocusing values differ from previous ones
		if {![string match $coulastrf($nam) $cou($nam)]} {
			return 0
		}
	}
	if {![info exists cou(rfenvs)]} {				;#	No previous refocusing envelopes exist
		return 0
	}
	if {[llength $cou(rfenvs)] != $cou(bands)} {	;#	Number of existing refocusing envelopes does not tally with current number of bands.
		return 0
	}
	foreach fnam $cou(rfenvs) {
		if {![file exists $fnam]} {					;#	Not every refocusing envelope that should exist does exist.
			return 0
		}
	}
	return 1
}

#----- Delete all temporary files (whichever name used) EXCEPT those excluded from deletion

proc DeleteAbsolutelyAllTemporaryFilesExcept {args} {
	global evv
	set outfname $evv(DFLT_OUTNAME)
	set fnams [glob -nocomplain "$outfname*"]
	set outfname $evv(MACH_OUTFNAME)
	set fnams2 [glob -nocomplain "$outfname*"]
	set fnams [concat $fnams $fnams2]
	foreach fnam $fnams {
		set dodelete 1
		foreach ifnam $args {
			if {[string match $fnam $ifnam]} {
				set dodelete 0
				break
			}
		}
		if {$dodelete} {
			catch {file delete -force $fnam}
		}
	}
}

proc PlayCouOutput {} {
	global cou wstk evv
	if {![info exists cou(outsnd)]} {
		return
	}
	set ofnam [string tolower $cou(ofnam)]
	append ofnam $evv(SNDFILE_EXT)
	if {![string match $cou(outsnd) $ofnam]} {
		set msg "New sound ($ofnam) not completed: play the previous output ($cou(outsnd)) ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		}
	}
	PlaySndfile $cou(outsnd) 0
}

#--- Alter message on refocus param, and seetup multiband parameter

proc IgnoreRefocus {typ} {
	global cou
	switch -- $typ {
		1 {
			catch {unset cou(multibands)}
			.couette.1.2.ff.ll.l2 config -text "IGNORED FOR SINGLE BAND"
		}
		0 {
			catch {unset cou(multibands)}
			.couette.1.2.ff.ll.l2 config -text ""
		}
		2 {
			set cou(multibands) 0
			.couette.1.2.ff.ll.l2 config -text ""
		}
	}
}

#--- Find files mentioned in patches, and load to workspace

proc CouPatchFilesToWkspace {} {
	global cou wstk wl

	set badpatches {}
	set done 0
	set OK 0
	foreach thispatch $cou(patches) {
		foreach item [lrange $thispatch 1 end] {
			if {([string length $item] <= 0) || [IsNumeric $item]} {
				continue
			}
			if {![file exists $item]} {
				lappend badfiles $item
				if {[lsearch $badpatches $thispatch] < 0} {
					lappend badpatches $thispatch
				}
			} elseif {[LstIndx $item $wl] < 0} {
				FileToWkspace $item 0 0 1 1 0
				set done 1
			} else {
				set OK 1
			}
		}
	}
	if {$done} {
		Inf "Files loaded to workspace"
	}
	if {[info exists badfiles]} {
		set msg "These files found in patches no longer exist\n"
		set cnt 0
		foreach fnam $badfiles {
			append msg "$fnam\n"
			incr cnt
			if {$cnt >= 20} {
				append msg "AND MORE"
				break
			}
		}
		Inf $msg
		set msg "Delete the associated patches ???"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			foreach thispatch $badpatches {
				set k [lsearch $cou(patches) $thispatch]
				if {$k >= 0} {
					set cou(patches) [lreplace $cou(patches) $k $k]
				}
			}

		}
	} elseif {$OK} {
		Inf "Files already on workspace"
	}
}

#---- Sort and hilite patch files on workspace

proc CouHilitePatchFiles {} {
	global cou wl wstk pr_couette
	set goodfiles {}
	foreach thispatch $cou(patches) {
		foreach item $thispatch {
			if {([string length $item] <= 0) || [IsNumeric $item] || ![file exists $item]} {
				continue
			} 
			set OK 1
			if {[LstIndx $item $wl] < 0} {
				if {[FileToWkspace $item 0 0 1 1 0] <= 0} {
					set OK 0
				}
			}
			if {$OK} {
				if {[lsearch $goodfiles $item] < 0} {
					lappend goodfiles $item
				}
			}
		}
	}
	set len [llength $goodfiles]
	if {$len <= 0} {
		return
	}
	foreach fnam $goodfiles {
		lappend ilist [LstIndx $fnam $wl]
	}	
	set j 0 
	foreach fnam [$wl get 0 end] {
		if {[lsearch -exact $ilist $j] < 0} {
			lappend remnant [$wl get $j]
		}
		incr j
	}
	if {![info exists remnant]} {
		return
	}
	$wl delete 0 end
	set newlist [concat $goodfiles $remnant]
	foreach fnam $newlist {
		$wl insert end $fnam
	}
	$wl selection clear 0 end
	set j 0
	while {$j < $len} {
		$wl selection set $j
		incr j
	}
	set pr_couette 0
}

#---- Before running test, store params : After running test, restore params

proc CouResetParamsForTest {restore} {
	global cou
	if {$restore} {
		if {![info exists cou(xtest)]} {
			return
		}
		set cou(3d)		[lindex $cou(xtest) 0]
		set cou(only)	[lindex $cou(xtest) 1]
		set cou(kpth)	[lindex $cou(xtest) 2]
		set cou(kprth)	[lindex $cou(xtest) 3]
		set cou(kpmix)	[lindex $cou(xtest) 4]
		set cou(kpcd)	[lindex $cou(xtest) 5]
		if {[lindex $cou(xtest) 6] >= 0} {
			set cou(multibands) [lindex $cou(xtest) 6] 
		}
		unset cou(xtest)

	} else {

		set cou(xtest) [list $cou(3d) $cou(only) $cou(kpth) $cou(kprth) $cou(kpmix) $cou(kpcd)]
		if {[info exists cou(multibands)]} {
			lappend cou(xtest) $cou(multibands)
		} else {
			lappend cou(xtest) -1
		}
		set cou(3d) 0
		set cou(only) 0
		set cou(kpth) 0
		set cou(kprth) 0
		set cou(kpmix) 0
		set cou(kpcd) 1
	}
}

#---- Test for a varipartials file

proc IsAVariPartialFile {fnam} {
	global evv pa
	set ftyp	$pa($fnam,$evv(FTYP))
	if {![IsNotMixText $ftyp]} {
		return 0
	}
	set numsize $pa($fnam,$evv(NUMSIZE))
	set linecnt $pa($fnam,$evv(LINECNT))
	set kk [expr $numsize / $linecnt]
	if {([expr $kk * $linecnt] != $numsize) || [IsEven $kk]}  {
		return 0
	}
	if [catch {open $fnam "r"} zit] {
		return 0
	}
	set OK 1
	set linecnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}				
		set line [split $line]
		set cnt 0
		set lastpartial -1
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {![IsNumeric $item]} {
				set OK 0
				break
			}
			if {$cnt == 0} {
				if {$linecnt == 0} {
					if {$item != 0.0} {
						set OK 0
					}
				} elseif {$item <= $lasttime} {
					set OK 0
				}
				set lasttime $item
			} elseif {[IsEven $cnt]} {
				if {($item < 0) || ($item > 1)} {
					set OK 0
					break
				}
			} else {
				if {($item < 1) || ($item > 64) || ($item < $lastpartial)} {
					set OK 0
					break
				}
				set lastpartial $item
			}
			incr cnt
		}
		if {$linecnt == 0} {
			if {[IsEven $cnt] || ($cnt < 3)} {
				set OK 0
			}
			set lastcnt $cnt
		} elseif {$cnt != $lastcnt} {
			set OK 0
		}
		if {!$OK} {
			break
		}
		incr linecnt
	}
	close $zit
	if {!$OK} {
		return 0
	}
	set partialcnt [expr ($cnt - 1)/2]
	return $partialcnt
}

#----- Merge parameter-sets for couette, and load

proc MergeCouettePatches {} {
	global evv pr_mergecou cou wstk readonlyfg readonlybg

	set fnam [file join $evv(URES_DIR) couette$evv(CDP_EXT)]
	catch {unset cou(mergelist)}
	set cou(mergecnt) 0
	set f .mergecou
	if [Dlg_Create $f "MERGE PARAMETER PATCH" "set pr_mergecou 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.save -text "Merge" -command "set pr_mergecou 1" -bg $evv(EMPH)
		button $f.0.rstt  -text "Restart" -command "set pr_mergecou 2"
		button $f.0.quit -text "Abandon" -command "set pr_mergecou 0"
		pack $f.0.save $f.0.rstt -side left -padx 4
		pack $f.0.quit -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.00
		label $f.00.ll -text "Merged Patch Name"
		entry $f.00.e -textvariable cou(mergenam)
		label $f.00.ll2 -text "Items in Merge" 
		entry $f.00.e2 -textvariable cou(mergecnt) -state readonly -foreground $readonlyfg -readonlybackground $readonlybg -width 3
		pack $f.00.ll $f.00.e $f.00.ll2 $f.00.e2 -side left -padx 2
		pack $f.00 -side top -pady 2 
		frame $f.1
		label $f.1.ll -text "PATCH NAMES (Select in order of merging)" -fg $evv(SPECIAL)
		Scrolled_Listbox $f.1.pp -width 32 -height 24 -selectmode single
		pack $f.1.ll $f.1.pp -side top -pady 2
		pack $f.1 -side top
		wm resizable $f 0 0
		bind $f <Escape> {set pr_mergecou 0}
		bind $f <Return> {set pr_mergecou 1}
		bind $f.1.pp.list <ButtonRelease> {ToCouMergeList %y}
	}
	.mergecou.1.pp.list delete 0 end
	if {[info exists cou(patches)]} {
		foreach pp $cou(patches) {
			.mergecou.1.pp.list insert end [lindex $pp 0]
		}
	}
	set pr_mergecou 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_mergecou
	while {!$finished} {
		tkwait variable pr_mergecou
		switch -- $pr_mergecou {
			1 {
				if {$cou(mergecnt) == 0} {
					Inf "No merge list selected"
					continue
				}
				if {$cou(mergecnt) < 2} {
					Inf "Only one patch on merge list"
					continue
				}
				if {![ValidCDPRootname $cou(mergenam)]} {
					continue
				}
				set cou(mergenam) [string tolower $cou(mergenam)] 
				if {[info exists cou(patches)]} {
					set OK 1
					foreach pp $cou(patches) {
						set nam [lindex $pp 0]
						if {[string match $nam $cou(mergenam)]} {
							Inf "This patchname already in use: chose a different name"
							set OK 0
							break
						}
					}
					if {!$OK} {
						continue
					}
				}
				if {![CouMergePatches]} {
					continue
				}
				set msg "Merged patch $cou(mergenam) created : load to interface ???"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "yes"} {
					set thispatch [lindex $cou(patches) end]
					set cou(dur)		[lindex $thispatch 1]
					set cou(bands)		[lindex $thispatch 2]
					set cou(threads)	[lindex $thispatch 3]
					set cou(tstep)		[lindex $thispatch 4]
					set cou(bot)		[lindex $thispatch 5]
					set cou(top)		[lindex $thispatch 6]
					set cou(twist)		[lindex $thispatch 7]
					set cou(rand)		[lindex $thispatch 8]
					set cou(warp)		[lindex $thispatch 9]
					set cou(vamp)		[lindex $thispatch 10]
					set cou(vmin)		[lindex $thispatch 11]
					set cou(vmax)		[lindex $thispatch 12]
					set cou(turb)		[lindex $thispatch 13]
					set cou(gap)		[lindex $thispatch 14]
					set cou(minband)	[lindex $thispatch 15]
					set cou(3d)			[lindex $thispatch 16]
					set cou(partials1)	[lindex $thispatch 17]
					set cou(minrise1)	[lindex $thispatch 18]
					set cou(maxrise1)	[lindex $thispatch 19]
					set cou(minsus1)	[lindex $thispatch 20]
					set cou(maxsus1)	[lindex $thispatch 21]
					set cou(mindecay1)	[lindex $thispatch 22]
					set cou(maxdecay1)	[lindex $thispatch 23]
					set cou(speed1)		[lindex $thispatch 24]
					set cou(scat1)		[lindex $thispatch 25]
					set cou(expr1)		[lindex $thispatch 26]
					set cou(expd1)		[lindex $thispatch 27]
					set cou(pscat1)		[lindex $thispatch 28]
					set cou(ascat1)		[lindex $thispatch 29]
					set cou(octav1)		[lindex $thispatch 30]
					set cou(bend1)		[lindex $thispatch 31]

					set cou(partials2)	[lindex $thispatch 32]
					set cou(minrise2)	[lindex $thispatch 33]
					set cou(maxrise2)	[lindex $thispatch 34]
					set cou(minsus2)	[lindex $thispatch 35]
					set cou(maxsus2)	[lindex $thispatch 36]
					set cou(mindecay2)	[lindex $thispatch 37]
					set cou(maxdecay2)	[lindex $thispatch 38]
					set cou(speed2)		[lindex $thispatch 39]
					set cou(scat2)		[lindex $thispatch 40]
					set cou(expr2)		[lindex $thispatch 41]
					set cou(expd2)		[lindex $thispatch 42]
					set cou(pscat2)		[lindex $thispatch 43]
					set cou(ascat2)		[lindex $thispatch 44]
					set cou(octav2)		[lindex $thispatch 45]
					set cou(bend2)		[lindex $thispatch 46]

					set cou(partials3)	[lindex $thispatch 47]
					set cou(minrise3)	[lindex $thispatch 48]
					set cou(maxrise3)	[lindex $thispatch 49]
					set cou(minsus3)	[lindex $thispatch 50]
					set cou(maxsus3)	[lindex $thispatch 51]
					set cou(mindecay3)	[lindex $thispatch 52]
					set cou(maxdecay3)	[lindex $thispatch 53]
					set cou(speed3)		[lindex $thispatch 54]
					set cou(scat3)		[lindex $thispatch 55]
					set cou(expr3)		[lindex $thispatch 56]
					set cou(expd3)		[lindex $thispatch 57]
					set cou(pscat3)		[lindex $thispatch 58]
					set cou(ascat3)		[lindex $thispatch 59]
					set cou(octav3)		[lindex $thispatch 60]
					set cou(bend3)		[lindex $thispatch 61]

					set cou(partials4)	[lindex $thispatch 62]
					set cou(minrise4)	[lindex $thispatch 63]
					set cou(maxrise4)	[lindex $thispatch 64]
					set cou(minsus4)	[lindex $thispatch 65]
					set cou(maxsus4)	[lindex $thispatch 66]
					set cou(mindecay4)	[lindex $thispatch 67]
					set cou(maxdecay4)	[lindex $thispatch 68]
					set cou(speed4)		[lindex $thispatch 69]
					set cou(scat4)		[lindex $thispatch 70]
					set cou(expr4)		[lindex $thispatch 71]
					set cou(expd4)		[lindex $thispatch 72]
					set cou(pscat4)		[lindex $thispatch 73]
					set cou(ascat4)		[lindex $thispatch 74]
					set cou(octav4)		[lindex $thispatch 75]
					set cou(bend4)		[lindex $thispatch 76]

					set cou(seed)		[lindex $thispatch 77]

					set cou(rot1)		[lindex $thispatch 78]
					set cou(rot2)		[lindex $thispatch 79]
					set cou(rot3)		[lindex $thispatch 80]
					set cou(rot4)		[lindex $thispatch 81]

					set cou(rstt1)		[lindex $thispatch 82]
					set cou(rstt2)		[lindex $thispatch 83]
					set cou(rstt3)		[lindex $thispatch 84]
					set cou(rstt4)		[lindex $thispatch 85]

					set cou(rinc1)		[lindex $thispatch 86]
					set cou(rinc2)		[lindex $thispatch 87]
					set cou(rinc3)		[lindex $thispatch 88]
					set cou(rinc4)		[lindex $thispatch 89]

					set cou(chans)		[lindex $thispatch 90]
					set cou(fx)			[lindex $thispatch 91]
					set cou(sz)			[lindex $thispatch 92]
					set cou(echos)		[lindex $thispatch 93]
					set cou(maxrev)		[lindex $thispatch 94]
					set cou(prev)		[lindex $thispatch 95]

					set cou(refocus)	[lindex $thispatch 96]
					CouDoRefocus
					set cou(ratio)		[lindex $thispatch 97]
					set cou(rfstep)		[lindex $thispatch 98]
					set cou(rfrand)		[lindex $thispatch 99]
					set cou(rfoff)		[lindex $thispatch 100]
					set cou(rfend)		[lindex $thispatch 101]
					set cou(rftyp)		[lindex $thispatch 102]
					set cou(rfnot)		[lindex $thispatch 103]

					set cou(bal1)		[lindex $thispatch 104]
					set cou(bal2)		[lindex $thispatch 105]
					set cou(bal3)		[lindex $thispatch 106]
					set cou(bal4)		[lindex $thispatch 107]

					set msg ""
					set k 1
					while {$k <= 4} {
						if {[string length $cou(partials$k)] > 0} {
							if {![file exists $cou(partials$k)]} {
								append msg "Partials file $cou(partials$k) no longer exists\n"
								set cou(partials$k) ""
							} else {
								set gotit 0
								set n 0
								foreach fnam [$cou(parlist) get 0 end] {
									if {[string match $cou(partials$k) $fnam]} {
										set cou(pcnt$k) [lindex $cou(partialscnt) $n]
										set cou(multptyp$k) [lindex $cou(multpartyp) $n]
										set gotit 1
										break
									}
									incr n
								}
								if {!$gotit} {
									append msg "File $cou(partials$k) is no longer a valid partials file\n"
									set cou(partials$k) ""
								}
							}
						}
						incr k
					}
					if {[string length $msg] > 0} {
						Inf $msg
					}
					set cou(ofnam) [lindex $thispatch 0]
					set finished 1
				}
			}
			2 {
				catch {unset cou(mergelist)}
				set cou(mergecnt) 0
			}
			0 {
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--------- Join together a set of patches

proc CouMergePatches {} {
	global cou coulist evv wstk
	if {![info exists cou(mergelist)] || ([llength $cou(mergelist)]  <= 0)} {
		Inf "No merge list exists"
		return 0
	}
	set patchname $cou(mergenam)
	catch {unset coulist}
	set n 0
	foreach item $cou(mergelist) {
		set patch [lindex $cou(patches) $item]
		catch {unset badmatch}
		if {$n == 0} {
			set newpatch $patch
			set olddur [lindex $newpatch 1]						;#	1	DURATION
			set k 7
			while {$k <= 81} {
				if {(($k >= 7) && ($k <= 10)) || ($k == 13) || (($k >= 78) && ($k <= 81))} {	;#	7	TWIST	8 TWRAND	9	TWWARP	10	WAVIAMP		13	TURBULENCE	
					set oldval [lindex $patch $k]												;#	78-81 ROTATION SPEEDS	
					if {[IsNumeric $oldval]} {
						set coulist($k) [list 0 $oldval $olddur $oldval]
					} else {
						set oldvals [GetOldCouVals $oldval]
						if {[llength $oldvals] == 0} {
							return 0
						}
						foreach {time val} $oldvals {
							lappend coulist($k) $time $val
						}
					}
				}
				incr k
			}
		} else {
			set patch_name [lindex $patch 0]
			set olddur [lindex $newpatch 1]						;#	1	DURATION
			set nxtdur [lindex $patch 1]
			set newdur [expr $olddur + $nxtdur]
			set newpatch [lreplace $newpatch 1 1 $newdur]		;#	Sum total dur
			set k 2
			while {$k < 108} {
				set newval [lindex $patch $k]
				if {(($k >= 7) && ($k <= 10)) || ($k == 13) || (($k >= 78) && ($k <= 81))} {	;#	7	TWIST	8 TWRAND	9	TWWARP	10	WAVIAMP		13	TURBULENCE
					if {[IsNumeric $newval]} {													;#	78-81 ROTATION SPEEDS	
						lappend coulist($k) $olddur $newval
						lappend coulist($k) $newdur $newval
					} else {
						set oldvals [GetOldCouVals $newval]
						if {[llength $oldvals] == 0} {
							return 0
						}
						foreach {time val} $oldvals {
							set time [expr $time + $olddur]
							lappend coulist($k) $time $val
						}
					}
				} else {
					if {![string match $newval [lindex $newpatch $k]]} {
						if {$k <= 15} {
							set badmatch(other_strands_parameters) 1
						} elseif {$k == 16} {
							set badmatch(3d_settings) 1
						} elseif {$k < 77} {
							set badmatch(packet_structure) 1
						} elseif {$k == 77} {
							set badmatch(seed_value) 1
						} elseif {$k <= 90} {
							set badmatch(rotation) 1
						} elseif {$k <= 95} {
							set badmatch(3d_settings) 1
						} elseif {$k <= 103} {
							set badmatch(band_refocusing) 1
						} else {
							set badmatch(band_balance) 1
						}
					}
				}
				incr k
			}
			if {[info exists badmatch]} {
				set msg "Patch $patch_name does not correspond with previous patches for\n"
				foreach nam [array names badmatch] {
					append msg "$nam\n"
				}
				append msg "Override discrepancies ???"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					return 0
				}
			}
		}
		incr n
	}
	set k 7
	while {$k < 82} {
		if {(($k >= 7) && ($k <= 10)) || ($k == 13) || (($k >= 78) && ($k <= 81))} {	;#	7	TWIST	8 TWRAND	9	TWWARP	10	WAVIAMP		13	TURBULENCE
			set coulist($k) [RationaliseCouParam $coulist($k)]							;#	78-81 ROTATION SPEEDS	
			set newval [WriteNewCouParam $k]
			if {[string length $newval] <= 0} {
				return 0
			}
			set newpatch [lreplace $newpatch $k $k $newval]
		}
		incr k
	}
	set newpatch [lreplace $newpatch 0 0 $cou(mergenam)]
	set fnam [file join $evv(URES_DIR) couette$evv(CDP_EXT)]
	if {[file exists $fnam]} {
		if [catch {open $fnam "a"} zit] {
			Inf "Cannot open patch storage file $fnam"
			return 0
		} 
	} else {
		if [catch {open $fnam "w"} zit] {
			Inf "Cannot create patch storage file $fnam"
			return 0
		}
	}
	puts $zit $newpatch
	close $zit
	lappend cou(patches) $newpatch
	.getcou.1.pp.list insert end [lindex $newpatch 0]
	set cou(stored_patches) $cou(patches)
	return 1
}

#---- Rationalise times and values in a brkpoint file

proc RationaliseCouParam {paramlist} {
	set n 0
	set m 0
	set len [llength $paramlist]
	while {$m < $len} {
		set time [lindex $paramlist $m]
		incr m
		set val [lindex $paramlist $m]
		incr m
		if {$n > 0} {
			if {[Flteq $time $lasttime]} {										;#	Eliminate time-coincident entries
				set paramlist [lreplace $paramlist [expr $m - 4] [expr $m - 3]]	;#	m-4 m-3 | m-2 m-1 | m   (time m-4 == m-2)
				incr m -2														;#	xxxxxxxx
				incr len -2
				incr n -1
			}
		}
		if {$n > 1} {
			if {[Flteq $val $lastval] && [Flteq $lastval $lastlastval]} {		;#	Eliminate central item of 3 identical vals
				set paramlist [lreplace $paramlist [expr $m - 4] [expr $m - 3]]	;#	m-6 m-5 | m-4 m-3 | m-2 m-1 | m
				incr m -2														;#			 xxxxxxxxx		
				incr len -2
				incr n -1
			}
		}
		set lasttime $time
		set lastval $val
		if {$n > 0} {
			set lastlastval [lindex $paramlist [expr $m - 4]]
		}
		incr n
	}
	return $paramlist
}

#--- Get existing vals in a brkpnt file

proc GetOldCouVals {fnam} {
	
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot open data file $fnam"
		return {}
	}
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
			lappend vals $item
		}
	}
	close $zit
	return $vals
}

#----- Create concatenated data file

proc WriteNewCouParam {k} {
	global cou coulist evv wstk

	set val [lindex $coulist($k) 1]
	if {([llength $coulist($k)] == 4) && ([lindex $coulist($k) 3] == $val)} {	;#	Constant, return numeric val
		return $val
	}
	set fnam [string tolower $cou(mergenam)]
	switch -- $k {
		7 {
			append fnam _mergetwists
		}
		8 {
			append fnam _mergetwrand
		}
		9 {
			append fnam _mergetwwarp
		}
		10 {
			append fnam _mergewavy
		}
		13 {
			append fnam _mergeturbs
		}
		78 {
			append fnam _merge1rot
		}
		79 {
			append fnam _merge2rot
		}
		80 {
			append fnam _merge3rot
		}
		81 {
			append fnam _merge4rot
		}
	}
	append fnam $evv(TEXT_EXT)
	if {[file exists $fnam]} {
		set msg "File $fnam already exists : overwrite it ???"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return {}
		}
	}
	if [catch {open $fnam "w"} zit] {
		Inf "Cannot open file $fnam"
		return {}
	}
	foreach {time val} $coulist($k) {
		set line [list $time $val]
		puts $zit $line
	}
	close $zit
	FileToWkspace $fnam 0 0 0 0 1
	return $fnam
}

#----- Add cou patch to list of patches to splice

proc ToCouMergeList {y} {
	global cou
	set i [.mergecou.1.pp.list nearest $y]
	if {$i < 0} {
		return
	}
	lappend cou(mergelist) $i
	incr cou(mergecnt)
}

#--- Save any changes to couette patches

proc FinalSaveCouettePatches {} {
	global cou evv wstk
	set rewrite 0
	set fnam [file join $evv(URES_DIR) couette$evv(CDP_EXT)]
	if {![info exists cou(patches)] && [file exists $fnam]} {
		set msg "There are no couette patches currently on the system: remove the file $fnam ???"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			catch {file delete $fnam}
		}
		return
	}
	if {[info exists cou(stored_patches)]} {
		if {[llength $cou(patches)] != [llength $cou(stored_patches)]} {
			set rewrite 1
		} else {
			foreach sp $cou(stored_patches) pp $cou(patches) {
				foreach spitem $sp ppitem $pp {
					if {![string match $spitem $ppitem]} {
						set rewrite 1
						break
					}
				}
				if {$rewrite} {
					break
				}
			}
		}
	} elseif {[info exists cou(patches)]} {
		set rewrite 1
	}
	if {!$rewrite} {
		return
	}
	if [catch {open $fnam "w"} zit] {
		Inf "Cannot open file $fnam to write updated couette data"
		return
	}
	foreach thispatch $cou(patches) {
		puts $zit $thispatch
	}
	close $zit
}

#---- Delete couette patches using deleted brkfiles

proc CouettePatchesDelete {couettelist} {
	global cou evv wstk development_version
	if {!$development_version || ![info exists cou(patches)] || ([llength $cou(patches)] <= 0)} {
		return
	}
	foreach fnam $couettelist {
		set ftyp [FindFileType $fnam]
		if {[IsABrkfile $ftyp]} {
			lappend fnams $fnam
		}
	}
	if {![info exists fnams]} {
		return
	}
	set done 0
	foreach fnam $fnams {
		set inpatches [IsFileInACouettePatch $fnam]
		if {[llength $inpatches] < 0} {
			continue
		}
		set inpatches [ReverseList $inpatches]
		foreach n $inpatches {
			set cou(patches) [lreplace $cou(patches) $n $n] 
			set done 1
		}
		if {[llength $cou(patches)] <= 0} {
			unset cou(patches)
			break
		}
	}
	if {$done} {
		set fnam [file join $evv(URES_DIR) couette$evv(CDP_EXT)]
		if {[info exists cou(patches)]} {
			if [catch {open $fnam "w"} zit] {
				Inf "Cannot open file $fnam to write updated couette data"
				return
			}
			foreach thispatch $cou(patches) {
				puts $zit $thispatch
			}
			close $zit
			set cou(stored_patches) $cou(patches)
		} else {
			catch {unset cou(stored_patches)}
			if {[file exists $fnam]} {
				catch {file delete $fnam}
			}
		}
		ClearCouettePatch 0
	}
}

#---- Deal with renaming of files used in Couette patches

proc CouetteManage {typ couettelist} {
	global development_version cou evv wstk
	if {!$development_version || ![info exists cou(patches)] || ([llength $cou(patches)] <= 0)} {
		return
	}
	set done 0
	foreach {fnam1 fnam2} $couettelist {
		set ftyp [FindFileType $fnam1]
		if {![IsABrkfile $ftyp]} {
			continue
		}
		switch -- $typ {
			rename {
				set inpatches [IsFileInACouettePatch $fnam1]
				if {[llength $inpatches] <= 0} {
					continue
				}
				foreach n $inpatches {
					if {[CouettePatchesFileRename $n $fnam1 $fnam2]} {
						set done 1
					}
				}
			}
			swap  {
				set inpatches1 [IsFileInACouettePatch $fnam1]
				set inpatches2 [IsFileInACouettePatch $fnam2]
				set inpatches [concat $inpatches1 $inpatches2]
				set inpatches [RemoveDuplicatesInList $inpatches]
				set inpatches [lsort -integer -increasing $inpatches]
				if {[llength $inpatches] <= 0} {
					continue
				}
				foreach n $inpatches {
					if {[CouettePatchesFilenameSwap $n $fnam1 $fnam2]} {
						set done 1
					}
				}
			}
		}
	}
	if {$done} {
		set fnam [file join $evv(URES_DIR) couette$evv(CDP_EXT)]
		if {[info exists cou(patches)]} {
			if [catch {open $fnam "w"} zit] {
				Inf "Cannot open file $fnam to write updated couette data"
				return
			}
			foreach thispatch $cou(patches) {
				puts $zit $thispatch
			}
			close $zit
			set cou(stored_patches) $cou(patches)
		} else {
			catch {unset cou(stored_patches)}
			if {[file exists $fnam]} {
				catch {file delete $fnam}
			}
		}
		ClearCouettePatch 0
	}
}

#---- is brkfile used in any couette patch ??

proc IsFileInACouettePatch {fnam} {
	global cou
	set inpatches {}
	set patchcnt 0
	foreach pp $cou(patches) {
		foreach item [lrange $pp 1 end]  {
			if {[string match $item $fnam]} {
				lappend inpatches $patchcnt
				break
			}
		}
		incr patchcnt
	}
	return $inpatches
}

#---- Rename file in a couette patch

proc CouettePatchesFileRename {patchcnt fnam1 fnam2} {
	global cou
	set done 0
	set thispatch [lindex $cou(patches) $patchcnt]
	set thisnam [lindex $thispatch 0]
	set thispatch [lrange $thispatch 1 end]
	set k 0
	while {$k >= 0} {
		set k [lsearch $thispatch $fnam1]
		if {$k >= 0} {
			set thispatch [lreplace $thispatch $k $k $fnam2]
			set done 1
		}
	}
	if {$done} {
		set thispatch [concat $thisnam $thispatch]
		set cou(patches) [lreplace $cou(patches) $patchcnt $patchcnt $thispatch]
	}
	return $done
}

proc CouettePatchesFilenameSwap {patchcnt fnam1 fnam2} {
	global cou
	set done 0
	set list1 {}
	set list2 {}
	set thispatch [lindex $cou(patches) $patchcnt]
	set thisnam [lindex $thispatch 0]
	set thispatch [lrange $thispatch 1 end]
	set n 0
	foreach item $thispatch {
		if {[string match $item $fnam1]} {
			lappend list1 $n
		} elseif {[string match $item $fnam2]} {
			lappend list2 $n
		}
		incr n
	}
	if {[llength $list1] > 0} {
		foreach n $list1 {
			set thispatch [lreplace $thispatch $n $n $fnam2]
		}
		set done 1
	}
	if {[llength $list2] > 0} {
		foreach n $list2 {
			set thispatch [lreplace $thispatch $n $n $fnam1]
		}
		set done 1
	}
	if {$done} {
		set thispatch [concat $thisnam $thispatch]
		set cou(patches) [lreplace $cou(patches) $patchcnt $patchcnt $thispatch]
	}
	return $done
}

#---- Check if a file about to be deleted or overwritten is part of a couette patch

proc CouetteAllowsDelete {fnam} {
	global development_version cou evv wstk
	if {!$development_version || ![info exists cou(patches)] || ([llength $cou(patches)] <= 0)} {
		return 1
	}
	set ftyp [FindFileType $fnam]
	if {![IsABrkfile $ftyp]} {
		return 1
	}
	set inpatches [IsFileInACouettePatch $fnam]
	if {[llength $inpatches] <= 0} {
		return 1
	}
	set msg "Deleting or overwriting file $fnam may invalidate these couette patches\n"
	set cnt 0
	foreach patchno $inpatches {
		append msg "[lindex [lindex $cou(patches) $patchno] 0]\n"
		incr cnt
		if {$cnt >= 20} {
			append msg "AND MORE\n"
			break
		}
	}
	append msg "\nProceed with the deletion or the overwrite ??"
	set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
	if {$choice == "yes"} {
		return 1
	}
	return 0
}	

#----- Get the final (or initial) state of the currently loaded patch
#----- i.e. values at the end of any brkpntfiles

proc CouetteEndState {initial} {
	global cou
	set nams [list twist rand warp vamp vmin vmax turb rot1 rot2 rot3 rot4]
	foreach nam $nams {
		set lastnam $nam
		append lastnam _last
		if {[info exists cou($lastnam)]} {
			set fnam $cou($lastnam)
		} else {
			set fnam $cou($nam)
		}
		if {[file exists $fnam]} {
			set ftyp [FindFileType $fnam]
			if {[IsABrkfile $ftyp]} {
				set cou($nam) [CouLastBrkVal $fnam $initial $nam]
			}
		}
	}
}

proc CouLastBrkVal {fnam initial nam} {
	global cou
	if [catch {open $fnam "r"} zit] {
		return $fnam
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		set lastline $line
		if {$initial} {
			break
		}
	}
	if {![info exists lastline]} {
		return $fnam
	}
	set line [split $lastline]
	set cnt 0
	foreach item $line {
		set item [string trim $item]
		if {[string length $item] <= 0} {
			continue
		}
		incr cnt
	}
	close $zit
	if {$cnt != 2} {
		return $fnam
	}
	append nam _last
	set cou($nam) $fnam
	return $item
}

proc PurgeCouBrkStateMem {} {
	global cou 
	set nams [list twist rand warp vamp vmin vmax turb rot1 rot2 rot3 rot4]
	foreach nam $nams {
		set lastnam $nam
		append lastnam _last
		catch {unset cou($lastnam)}
	}
}

proc CouTimewarp {} {
	global cou evv wstk pr_coupwarp
	if {![ValidCDPRootname $cou(ofnam)]} {
		return
	}
	set thispatchnam [string tolower $cou(ofnam)] 
	foreach pp $cou(patches) {
		set nam [lindex $pp 0]
		if {[string match $nam $thispatchnam]} {
			Inf "Choose a (new) outfile name for the time-warped patch"
			return
		}
	}
	set dofiles {}
	set nams [list twist rand warp vamp vmin vmax turb rot1 rot2 rot3 rot4]
	foreach nam $nams {
		set fnam $cou($nam)
		if {[file exists $fnam]} {
			set ftyp [FindFileType $fnam]
			if {[IsABrkfile $ftyp]} {
				lappend dofiles $nam $fnam
			}
		}
	}
	set n 1
	while {$n <= 4} {
		if {![file exists $cou(partials$n)]} {
			Inf "Incomplete patch: (partials file $n missing)"
			return
		}
		lappend dofiles partials$n $cou(partials$n)
		incr n
	}
	set f .couwarp
	if [Dlg_Create $f "TIMEWARP COUETTE PATCH" "set pr_coupwarp 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.save -text "Warp" -command "set pr_coupwarp 1" -bg $evv(EMPH)
		button $f.0.quit -text "Abandon" -command "set pr_coupwarp 0"
		pack $f.0.save -side left -padx 4
		pack $f.0.quit -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Timewarp factor" -width 16
		entry $f.1.e -textvariable cou(timewarp) -width 16
		pack $f.1.ll $f.1.e -side left -padx 2
		pack $f.1 -side top -pady 2 
		frame $f.2
		label $f.2.ll -text "Filename suffix"  -width 16
		entry $f.2.e -textvariable cou(timewarpsuffix) -width 16
		pack $f.2.ll $f.2.e -side left -padx 2
		pack $f.2 -side top -pady 2 
		wm resizable $f 0 0
		bind $f <Escape> {set pr_coupwarp 0}
		bind $f <Return> {set pr_coupwarp 1}
	}
	set pr_coupwarp 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_coupwarp
	while {!$finished} {
		tkwait variable pr_coupwarp
		if {$pr_coupwarp} {
			if {![IsNumeric $cou(timewarp)] || ($cou(timewarp) <= 0)} {
				Inf "Invalid timewarp value"
				continue
			}
			if {![ValidCDPRootname $cou(timewarpsuffix)]} {
				continue
			}
			set outsuffix [string tolower $cou(timewarpsuffix)] 
			set OK 1
			catch {unset outfiles}
			foreach {nam fnam} $dofiles {
				set ext [file extension $fnam]
				set fnam [file rootname $fnam]
				append fnam "_" $outsuffix $ext
				if {[file exists $fnam]} {
					Inf "File with name $fnam already exists"
					set OK 0
					break
				}
				lappend outfiles $fnam
			}
			if {!$OK} {
				continue
			}
			foreach {nam fnam} $dofiles ofnam $outfiles {
				set cou($nam) [CouTimeWarp $fnam $ofnam]
			}
			set cou(dur) [expr $cou(dur) * $cou(timewarp)]
			set msg "Save timewarped patch ??"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "yes"} {
				set fnam [file join $evv(URES_DIR) couette$evv(CDP_EXT)]
				set thispatch $thispatchnam
				lappend thispatch $cou(dur) $cou(bands) $cou(threads) $cou(tstep) $cou(bot) $cou(top) $cou(twist) $cou(rand) $cou(warp) 
				lappend thispatch $cou(vamp) $cou(vmin) $cou(vmax) $cou(turb) $cou(gap) $cou(minband) $cou(3d)
				lappend thispatch $cou(partials1) $cou(minrise1) $cou(maxrise1) $cou(minsus1) $cou(maxsus1) $cou(mindecay1) $cou(maxdecay1) $cou(speed1)
				lappend thispatch $cou(scat1) $cou(expr1) $cou(expd1) $cou(pscat1) $cou(ascat1) $cou(octav1) $cou(bend1)
				lappend thispatch $cou(partials2) $cou(minrise2) $cou(maxrise2) $cou(minsus2) $cou(maxsus2) $cou(mindecay2) $cou(maxdecay2) $cou(speed2)
				lappend thispatch $cou(scat2) $cou(expr2) $cou(expd2) $cou(pscat2) $cou(ascat2) $cou(octav2) $cou(bend2)
				lappend thispatch $cou(partials3) $cou(minrise3) $cou(maxrise3) $cou(minsus3) $cou(maxsus3) $cou(mindecay3) $cou(maxdecay3) $cou(speed3)
				lappend thispatch $cou(scat3) $cou(expr3) $cou(expd3) $cou(pscat3) $cou(ascat3) $cou(octav3) $cou(bend3) 
				lappend thispatch $cou(partials4) $cou(minrise4) $cou(maxrise4) $cou(minsus4) $cou(maxsus4) $cou(mindecay4) $cou(maxdecay4) $cou(speed4)
				lappend thispatch $cou(scat4) $cou(expr4) $cou(expd4) $cou(pscat4) $cou(ascat4) $cou(octav4) $cou(bend4)
				lappend thispatch $cou(seed) $cou(rot1) $cou(rot2) $cou(rot3) $cou(rot4)
				lappend thispatch $cou(rstt1) $cou(rstt2) $cou(rstt3) $cou(rstt4) $cou(rinc1) $cou(rinc2) $cou(rinc3) $cou(rinc4) $cou(chans)
				lappend thispatch $cou(fx) $cou(sz) $cou(echos) $cou(maxrev) $cou(prev)
				lappend thispatch $cou(refocus) $cou(ratio) $cou(rfstep) $cou(rfrand) $cou(rfoff) $cou(rfend) $cou(rftyp) $cou(rfnot)
				lappend thispatch $cou(bal1) $cou(bal2) $cou(bal3) $cou(bal4)
				lappend cou(patches) $thispatch
				.getcou.1.pp.list insert end $thispatchnam

				set OK 1
				if {[file exists $fnam]} {
					if [catch {open $fnam "a"} zit] {
						Inf "Cannot open patch storage file $fnam"
						set OK 0
					} 
				} else {
					if [catch {open $fnam "w"} zit] {
						Inf "Cannot create patch storage file $fnam"
						set OK 0
					}
				}
				if {$OK} {
					puts $zit $thispatch
					close $zit
					set cou(stored_patches) $cou(patches)
				}
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc CouTimeWarp {fnam ofnam} {
	global cou pa evv wl rememd wkspace_newfile
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot open file $fnam to do timewarp"
		return $fnam
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		catch {unset nuline}
		set line [split $line]
		set cnt 0
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {$cnt == 0} {
				set item [expr $item * $cou(timewarp)]
			}
			lappend nuline $item
			incr cnt
		}
		lappend nulines $nuline
	}
	close $zit
	if [catch {open $ofnam "w"} zit] {
		Inf "Cannot open file $ofnam to write timewarped data"
		return $fnam
	}
	foreach line $nulines {
		puts $zit $line
	}
	close $zit
	if {[DoParse $ofnam 0 0 0] > 0} {
		set filetype $pa($ofnam,$evv(FTYP))
		$wl insert 0 $ofnam
		WkspCnt $ofnam 1
		catch {unset rememd}
		set wkspace_newfile 1
	}
	return $ofnam
}

##################
# RHYTHMIC KNOTS #
##################

proc RhythmicKnotsHelp {} {
	set msg "RHYTHM CELLS AND PATTERNS\n"
	append msg "\n"
	append msg "A cell is a basic rhythmic pattern. Cells can be combined in sequence (via abutt or repeat) to get larger patterns.\n"
	append msg "\n"
	append msg "Rhythmic patterns contain either \"time index level\" information (TIL) (where \"index\" is a marker for a sound)\n"
	append msg "or \"time index level position\" information (TILP), where \"position\" is a location in multichannel space.\n"
	append msg "\n"
	append msg "Patterns used should have a final event that marks the DURATION of the pattern\n"
	append msg "but does not constitute part of the pattern itself. In TILP patterns, use a unique \"index\" value in such lines. \n"
	append msg "If the pattern has an anacrusis, the 1st event should mark the starttime of the \"bar\" containing the anacrusis.\n"
	append msg "Such marker events are given the sound index \"0\" and will be ignored when the pattern is converted to a sound mix.\n"
	append msg "\n"
	append msg "~~~~  TIL patterns  ~~~~\n"
	append msg "\n"
	append msg "TIL patterns can be joined (ABUTT) or repeated and/or scaled in time (REPEAT/SCALE)\n"
	append msg "These patterns can then be combined and positioned in multichannel space, to give a TILP pattern.\n"
	append msg "\n"
	append msg "~~~~  TILP patterns  ~~~~\n"
	append msg "\n"
	append msg "TILP patterns can be similarly abutted or repeated/scaled.\n"
	append msg "They can also be MORPHED into one another, even if they have different numbers of elements.\n"
	append msg "    but if the number of elements changes you must provide a \"BRIDGING\" file.\n"
	append msg "The final rhythmic cell of any evolving pattern can be extracted with \"Snip\"\n"
	append msg "to become the start element for a new morph.\n"
	append msg "\n"
	append msg "All these processes on TILP patterns generate 3 types of associated files.\n"
	append msg "\n"
	append msg "(1)  A MAP FILE (\"patname_map.txt\") mapping where each cell-element recurs in the extended pattern.\n"
	append msg "(2)  A STEND FILE (\"patname_stend.txt\") storing the start and end times of the final cell in a pattern.\n"
	append msg "(3)  A LINK FILE (\"patname_link.txt\") relates to a morphing pattern that grows or shrinks in cell-size.\n" 
	append msg "\n"
	append msg "~~~~  BRIDGING FILES Format  ~~~~\n"
	append msg "\n"
	append msg "When creating a morph between patterns of different sizes, a \"BRIDGING\" file must be used.\n"
	append msg "Initially you must provide this data in the correct format.\n"
	append msg "\n"
	append msg "----- Branching Growth (and Merging contraction) -----\n"
	append msg "\n"
	append msg "Where any single event in the smaller pattern BRANCHES to more than one event in the larger,\n"
	append msg "the bridging file associates each line in the smaller cell with 1 or more lines in the larger.\n"
	append msg "\n"
	append msg "It has data-lines with the format.\n"
	append msg "sml big1 \[big2 ......\]\n"
	append msg "Where \"sml\" refers to a line-number in the smaller cell\n"
	append msg "and \"bigN\" refer to the corresponding line-number(s) in the bigger cell.\n"
	append msg "\n"
	append msg "e.g. \"2 3 7\" implies that the event at line 2 in the smaller event\n"
	append msg "branches into the events at lines 3 and 7 in the larger pattern.\n"
	append msg "\n"
	append msg "----- Growth by Adding new events -----\n"
	append msg "\n"
	append msg "Where new events are gradually ADDED to a pattern,\n"
	append msg "the bridging file associates EVERY event in the smaller cell with just 1 event in the larger,\n"
	append msg "(but there will be events in the larger pattern, the inserted events, which are not represented).\n"
	append msg "\n"
	append msg "Here data-lines have the format \"sml big\"  e.g. \"2 3\"\n"
	append msg "Where \"sml\" refers to a line-number in the smaller cell\n"
	append msg "and \"big\" refers to the corresponding line-number in the bigger cell.\n"
	append msg "\n"
	append msg "IN BOTH CASES\n"
	append msg "(1)  \"sml\" line-numbers, on succesive lines of the bridging file, must be numbered upwards from 1 (with no gaps).\n"
	append msg "(2)  \"big\" line-numbers, on each line of the bridging file, must be in increasing order.\n"
	append msg "(3)  Lines, in larger and smaller cells, associated in this way MUST have the same sound-index numbers.\n"
	append msg "(4)  The \"index\" value in the final (duration-marker) lines must also match.\n"
	Inf $msg	
}

proc RhythmicKnotsTILHelp {} {
	set msg "\n"
	append msg "These processes use Rhythm pattern files in the \"Time Index Level\" (TIL) format.\n"
	append msg "\n"
	append msg "\"Index\" is a non-negative integer, value, and could be a MIDI value.\n"
	append msg "So \"TIL\" data can be made using Loom's MIDI input, grabbing \"Time : Pitch(Midi) : Level(Gain)\" options only.\n"
	append msg "but a final (pattern-duration marker event must be added, with sound-index zero).\n"
	append msg "\n"
	append msg "REPEAT/SCALE RHYTHM PATTERN\n"
	append msg "\n"
	append msg "Takes a \"Time Index Level\" (TIL) input file\n"
	append msg "and generates N repetitions of the pattern at time-multiples of the pattern duration.\n"
	append msg "The last (duration_marker) event of the last repeat should normally be retained (others are discarded).\n"
	append msg "\n"
	append msg "JOIN (ABUTT) RHYTHM PATTERNS\n"
	append msg "\n"
	append msg "Takes \"Time Index Level\" (TIL) input files\n"
	append msg "and joins them tail to head. Final (marker) events are dropped from all pattern-ends except last.\n"
	append msg "\n"
	append msg "POSITION RHYTHM PATTERN\n"
	append msg "\n"
	append msg "Takes a \"Time Index Level\" (TIL) input file and adds a spatial position in the range 0-8(max),\n"
	append msg "Generating format \"Time Index Level Position\" (TILP).\n"
	append msg "\n"
	append msg "COUNT DISTINCT SOUND-INDEX VALUES\n"
	append msg "\n"
	append msg "Takes a \"TIL\" input file and counts the number of distinct \"Index\" values used.\n"
	append msg "\n"
	Inf $msg
}

proc RhythmicKnotsTILPHelp {} {
	set msg "\n"
	append msg "REPEAT/SCALE RHYTHM PATTERN\n"
	append msg "\n"
	append msg "Takes a \"Time Index Level Position\" (TILP) input file\n"
	append msg "and generates N repetitions of the pattern at time-multiples of the pattern duration.\n"
	append msg "\n"
	append msg "JOIN (ABUTT) RHYTHM PATTERNS\n"
	append msg "Takes \"Time Index Level Position\" (TILP) input files\n"
	append msg "and joins them tail to head. Final (marker) events are dropped from all pattern-ends except last.\n"
	append msg "\n"
	append msg "MORPH BETWEEN 2 RHYTHMIC CELLS\n"
	append msg "Takes 2 \"Time Index Level Position\" (TILP) input files and morphs between them.\n"
	append msg "Patterns can have different numbers of events, and have different duration.\n"
	append msg "\n"
	append msg "In ALL the above processes, a \"_stend\" file will be generated for the combined-pattern,\n"
	append msg "containing start & end times of last cell used.\n"
	append msg "If the last-pattern used already has a \"_stend\" file, this data is updated for the new \"_stend\" file.\n"
	append msg "If NO corresponding \"_stend\" file exists, the assumption is made that the pattern is a single rhythmic cell\n"
	append msg "so the new \"_stend\" file contains the (new) start and endtimes of the whole of this last cell\n"
	append msg "in the combined pattern.\n"
	append msg "\n"
	append msg "COUNT DISTINCT SOUND-INDEX VALUES\n"
	append msg "Counts the number of distinct \"Index\" values used.\n"
	append msg "\n"
	append msg "LAYER POSITIONED RHYTHM PATTERNS\n"
	append msg "Takes \"TILP\" input files, and combines then simultaneously (all starting at zero time)\n"
	append msg "sorting events into the correct (increasing) time order.\n"
	append msg "The final event marker of the output is taken to be the final event marker of the longest pattern.\n"
	append msg "\n"
	append msg "OTHER RHYTHM PATTERN PERMUTATIONS\n"
	append msg "See \"Help\" on individual pages.\n"
	append msg "\n"
	append msg "\n"
	append msg "\"TILP\" files can also be CONVERTED TO MIXFILES, and hence to sound output.\n"
	Inf $msg
}

#---- Position a RHYTHM DATA file in an 8-channel space

proc KnotPosition {} {
	global chlist evv pa wstk pr_knotposition knot_position knot_position_suffix last_outfile wl TILPlist

	if {![info exists chlist] || ([llength $chlist] <= 0)} {
		Inf "Select one \"time-index-level\" format file"
		return
	}
	set ifnam [lindex $chlist 0]
	set ftyp $pa($ifnam,$evv(FTYP))
	if {![IsAListofNumbers $ftyp]} {
		Inf "Select a \"time  index  level\" format file"
		return
	}
	if [catch {open $ifnam "r"} zit] {
		Inf "Cannot open file $ifnam"
		return
	}
	set linecnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		incr linecnt
		catch {unset nuline}
		set line [split $line]
		set cnt 0
		set OK 1
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			switch -- $cnt {
				0 {
					if {$linecnt == 1} {
						if {$item != 0.0} {
							Inf "Initial time in input file must be zero"
							set OK 0
							break
						}
					} elseif {$item < $lasttime} {
						Inf "Times in input file do not increase at line $linecnt"
						set OK 0
						break
					}
					set lasttime $item	
				}
				1 {
					if {![regexp {^[0-9]+$} $item] || ![IsNumeric $item]} {
						Inf "Invalid sound-index value on line $linecnt"
						set OK 0
						break
					}
				}
				2 {
					if {($item < 0.0) || ($item > 1.0)} {
						Inf "Invalid level value on line $linecnt"
						set OK 0
						break
					}
				}
			}					
			lappend nuline $item
			incr cnt
		}
		if {!$OK} {
			break
		}
		if {$cnt != 3} {
			Inf "Wrong number of values ($cnt) on line ($linecnt): requires 3 values"
			set OK 0
			break
		}
		lappend lines $nuline

	}
	close $zit
	if {!$OK} {
		return
	}
	if {$linecnt < 1} {
		Inf "No data found in file $ifnam"
		return
	}
	set f .knotposition
	if [Dlg_Create $f "POSITION RHYTHM IN SPACE" "set pr_knotposition 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.save -text "Position" -command "set pr_knotposition 1" -bg $evv(EMPH)
		button $f.0.quit -text "Abandon" -command "set pr_knotposition 0"
		pack $f.0.save -side left -padx 4
		pack $f.0.quit -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Position (0 - 8)" -width 16
		label $f.1.dum -text "" -width 24 
		entry $f.1.e -textvariable knot_position -width 16
		pack $f.1.ll $f.1.e $f.1.dum -side left -padx 2
		pack $f.1 -side top -pady 2 
		frame $f.2
		label $f.2.ll -text "Filename suffix"  -width 16
		entry $f.2.e -textvariable knot_position_suffix -width 16
		set knot_position_suffix ""
		pack $f.2.ll $f.2.e -side left -padx 2
		pack $f.2 -side top -pady 2 -anchor w
		wm resizable $f 0 0
		bind $f <Escape> {set pr_knotposition 0}
		bind $f <Return> {set pr_knotposition 1}
	}
	set pr_knotposition 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_knotposition
	while {!$finished} {
		tkwait variable pr_knotposition
		if {$pr_knotposition} {
			if {![IsNumeric $knot_position] ||  ($knot_position < 0.0) || ($knot_position > 8)} {
				Inf "Invalid position value entered (range 0 - 8)"
				continue
			}
			if {![ValidCDPRootname $knot_position_suffix]} {
				continue
			}
			set outsuffix [string tolower $knot_position_suffix] 
			set ext [file extension $ifnam]
			set ofnam [file rootname $ifnam]
			append ofnam "_" $outsuffix $ext
			if {[file exists $ofnam]} {
				set msg "File $ofnam already exists : overwrite it ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				if {![CouetteAllowsDelete $ofnam]} {
					continue
				}
				if [catch {file delete -force $ofnam} in] {
					Inf "Cannot delete the existing file."
					continue
				} else {											;# Copy only takes place from Dirlist to Wkspace.
					DataManage delete $ofnam
					CouettePatchesDelete $ofnam
					DeleteFileFromSrcLists $ofnam					;# File created is a wkspace file.
					set ftyp $pa($ofnam,$evv(FTYP))
					RemoveFromChosenlist $ofnam
					PurgeArray $ofnam
					DummyHistory $ofnam "OVERWRITTEN"
					set i [LstIndx $ofnam $wl]
					if {$i >= 0} {
						$wl delete $i
					}
				}
			}
			catch {unset nulines}
			foreach line $lines {
				lappend line $knot_position
				lappend nulines $line
			}
			if [catch {open $ofnam "w"} zit] {
				Inf "Cannot open output file $ofnam"
				continue
			}
			foreach line $nulines {
				puts $zit $line
			}
			close $zit
			if {[FileToWkspace $ofnam 0 0 0 0 1] > 0} {
				Inf "File $ofnam is on the workspace"
				set last_outfile $ofnam
			} else {
				Inf "File $ofnam has been created"
			}
			lappend TILPlist $ofnam		
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- Convert a "Time Index Level Position" datfile to a mixfile

proc KnotMidiToMix {howmany doplay} {
	global chlist evv pa wstk pr_knottomix knot_mixfile last_outfile wl mixnoend
	global knot CDPidrun prg_dun prg_abortd simple_program_messages CDPidrun CDPmaxId maxsamp_line done_maxsamp 

	set startmsg "SELECT ONE \"Time  Index  Level Position\" FORMAT TEXTFILE\n\nFOLLOWED BY EITHER\n\n"
	append startmsg "(A)  2 OR MORE MONO SOUNDFILES (1st sound Silent)\n\nOR\n\n"
	append startmsg "(B)  1 SOUND ASSIGNMENT TEXTFILE  : Format \"Number Soundfile\"\n"
	append startmsg "       (First assignment being to a Silent File)"

	if {$doplay} {
		set tempofnam(0) $evv(DFLT_OUTNAME)
		append tempofnam(0) "0" $evv(SNDFILE_EXT)
	}
	if {![info exists chlist]} {
		Inf $startmsg
		return
	}
	set len [llength $chlist]
	if {$howmany} {
		if {$len < 1} {
			Inf $startmsg
			return
		}
		set mode howmany
	} else {
		if {$len < 2} {
			Inf $startmsg
			return
		}
		set ftyp $pa([lindex $chlist 1],$evv(FTYP)) 
		if {$ftyp == $evv(SNDFILE)} {
			if {[llength $chlist] < 3} {
				Inf $startmsg
			}
			set sndcnt 1
			foreach sfnam [lrange $chlist 1 end] {
				if {($pa($sfnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($sfnam,$evv(CHANS)) != 1)} {
					Inf "File $sfnam is not a mono sound file"
					return
				}
				lappend sfnams $sfnam
				if {$sndcnt == 1} {
					set srate $pa($sfnam,$evv(SRATE))
				} elseif {$srate != $pa($sfnam,$evv(SRATE))} {
					Inf "File $fnam has different sample rate to earlier files"
					return
				}
				incr sndcnt
			}
			set mode snds
		} else {
			if {[llength $chlist] > 2} {
				Inf $startmsg
			}
			set data [IsASndIndexingFile [lindex $chlist 1]]
			if {[llength $data] < 2} {
				return
			}
			set sndiii [lindex $data 0]
			set sfnams [lindex $data 1]
			set mode indices
		}
	}
	set ifnam [lindex $chlist 0]
	set ftyp $pa($ifnam,$evv(FTYP))
	if {![IsAListofNumbers $ftyp]} {
		if {$howmany} {
			Inf "Select a \"time  index  level\" format file\nor a \"time  index  level position\" format file"
			return
		} else {
			Inf "Select a \"time  index  level position\" format file as first item on chosen files list"
			return
		}
	}
	if [catch {open $ifnam "r"} zit] {
		Inf "Cannot open file $ifnam"
		return
	}
	set linecnt 0
	set midivals {}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		incr linecnt
		catch {unset nuline}
		set line [split $line]
		set cnt 0
		set OK 1
		set domixsort 0
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			switch -- $cnt {
				0 {
					if {$linecnt == 1} {
						if {$item != 0.0} {
							Inf "Initial time in input data file $ifnam must be zero"
							set OK 0
							break
						}
					} elseif {$item < $lasttime} {
						set domixsort 1
					}
					set lasttime $item	
				}
				1 {
					if {![regexp {^[0-9]+$} $item] || ![IsNumeric $item]} {
						Inf "Invalid sound-index value on line $linecnt of file $ifnam"
						set OK 0
						break
					}
					if {[lsearch $midivals $item] < 0} {
						lappend midivals $item
					}
					set lastindex $item
				}
				2 {
					if {($item < 0.0) || ($item > 1.0)} {
						Inf "Invalid level value on line $linecnt of file $ifnam"
						set OK 0
						break
					}
				}
				3 {
					if {($item < 0.0) || ($item > 8.0)} {
						Inf "Invalid position value on line $linecnt of file $ifnam"
						set OK 0
						break
					}
				}
			}
			lappend nuline $item
			incr cnt
		}
		if {!$OK} {
			break
		}
		if {$linecnt == 1} {
			set totcnt $cnt
		}
		if {$howmany} {
			if {($cnt < 3) || ($cnt > 4)} {
				Inf "Wrong number of values ($cnt) on line ($linecnt) of file $ifnam: requires either 3 or 4 values"
				set OK 0
				break
			}
		} else {
			if {$cnt != 4} {
				Inf "Wrong number of values ($cnt) on line ($linecnt) of file $ifnam: requires 4 values"
				set OK 0
				break
			}
		}
		if {($linecnt > 1) && ($cnt != $totcnt)} {
			Inf "Wrong number of values ($cnt) on line ($linecnt) of file $ifnam: 1st line has $totcnt values"
			set OK 0
			break
		}
		if {$lastindex > 0 || $lasttime == 0.0} {	;#	Omit silent files NOT at time zero
			lappend lines $nuline
		}
	}
	close $zit
	if {!$OK} {
		return
	}
	set inlines [llength $lines]

	if {$domixsort} {
		set inlines_less_one [expr $inlines - 1]
		set n 0
		while {$n < $inlines_less_one} {
			set n_line [lindex $lines $n]
			set n_time [lindex $n_line 0]
			set m $n
			incr m
			while {$m < $inlines} {
				set m_line [lindex $lines $m]
				set m_time [lindex $m_line 0]
				if {$m_time < $n_time} {
					set lines [lreplace $lines $n $n $m_line]
					set lines [lreplace $lines $m $m $n_line]
					set n_line $m_line
					set n_time $m_time
				}
				incr m
			}
			incr n
		}
	}
	if {$inlines > 998} {
		set outmixes [expr $inlines / 998]
		if {[expr $outmixes * 998] < $inlines} {
			incr outmixes
		}
	} else {
		set outmixes 1
	}
	if {$doplay} {
		set n 1
		while {$n <= $outmixes} {
			set tempofnam($n) $evv(DFLT_OUTNAME)
			append tempofnam($n) $n $evv(SNDFILE_EXT)
			incr n
		}
		if {$outmixes > 1} {
			set ubermixnam $evv(DFLT_OUTNAME)
			append ubermixnam [GetTextfileExtension mmx]
		}
	}
	if {!$OK} {
		return
	}
	if {$linecnt < 1} {
		Inf "No data found in file $ifnam"
		return
	}
	if {$mode != "indices"} {
		set midivals [lsort -integer -increasing $midivals]		;#	sounds will correspond to Index-vals-in-increasing-order
	} else {
		if {![MidiValuesTally $midivals $sndiii]} {
			return
		}
	}
	set len [llength $midivals]
	if {$howmany} {
		set msg "File has $len index values\n"
		set msg2 [lindex $midivals 0]
		if {$len > 1} {
			foreach val [lrange $midivals 1 end] {
				append msg2 "  $val"
			}
		}
		append msg $msg2
		Inf $msg
		return
	}
	set tallies 1
	if {[lsearch $midivals "0"] >= 0} {			;#	If a silent file is used in mix
		set extrasilence 0						;#	an additional silent file is not required
		if {[llength $sfnams] < $len} {		;#	number of sndfiles entered should equal number of Index vals in mix
			set tallies 0
		}
	} else {									;#	If a silent file is NOT used in mix	
		set extrasilence 1						;#	an ADDITIONAL silent file IS required
		if {[llength $sfnams] < [expr $len + 1]} {
			set tallies 0						;#	number of sndfiles is 1 greater than number of Index vals in mix
		}
	}
	if {!$tallies} {
		set msg "Number of soundfiles "
		if {$extrasilence} {
			append msg "(plus additional silent file) "
		}
		append msg "is insufficient for number of sound-index values in data file $ifnam\n"
		append msg "\n(first file must be a silent file)"
		Inf $msg
		return
	}
	set silfil [lindex $sfnams 0]
	if {![info exists pa($silfil,$evv(MAXSAMP))]} {
		Block "CHECKING 1ST SOUND FILE IS SILENT"
		while {$OK} {
			catch {unset CDPmaxId}
			catch {unset maxsamp_line}
			set done_maxsamp 0
			set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
			lappend cmd $silfil
			lappend cmd 1		;#	1 flag added to FORCE read of maxsample
			if [catch {open "|$cmd"} CDPmaxId] {
				Inf "Finding maximum level of 1st soundfile: process failed\n$cmd"
				set OK 0
				break
	   		} else {
	   			fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
			}
	 		vwait done_maxsamp
			if {[info exists maxsamp_line]} {
				set pa($silfil,$evv(MAXSAMP)) [lindex $maxsamp_line 0]
				set pa($silfil,$evv(MAXLOC))  [lindex $maxsamp_line 1]
				set pa($silfil,$evv(MAXREP))  [lindex $maxsamp_line 2]
			} else {
				Inf "Failed to find maximum level of 1st soundfile\n$cmd"
				set OK 0
			}
			break
		}
	}
	if {!$OK} {
		set msg "Proceed anyway ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		}
	} elseif {$pa($silfil,$evv(MAXSAMP)) > 0.0} {
		Inf "Needs a silent file as 1st sndfile: 1st file here does not appear to be silent\n\nif in doubt run \"recaculate max sample\" from workspace"
		return
	}
	set f .knottomix
	if [Dlg_Create $f "RHYTHM TO MIXFILE" "set pr_knottomix 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.save -text "Convert" -command "set pr_knottomix 1" -bg $evv(EMPH)
		button $f.0.quit -text "Abandon" -command "set pr_knottomix 0"
		pack $f.0.save -side left -padx 4
		pack $f.0.quit -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		checkbutton $f.1.ne -text "Treat end event as duration-marker : Ignore it" -variable mixnoend -width 48
		set mixnoend 0
		pack $f.1.ne -side left
		pack $f.1 -side top -pady 2 
		frame $f.2
		label $f.2.ll -text "Output Filename"  -width 16
		entry $f.2.e -textvariable knot_mixfile -width 16
		pack $f.2.ll $f.2.e -side left -padx 2
		pack $f.2 -side top -pady 2 
		wm resizable $f 0 0
		bind $f <Escape> {set pr_knottomix 0}
		bind $f <Return> {set pr_knottomix 1}
	}
	set knot_mixfile [file rootname [file tail $ifnam]]
	set pr_knottomix 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_knottomix
	while {!$finished} {
		DeleteAllTemporaryFiles
		tkwait variable pr_knottomix
		if {$pr_knottomix} {
			if {![ValidCDPRootname $knot_mixfile]} {
				continue
			}
			set ofnam [string tolower $knot_mixfile] 
			if {$doplay} {
				set sndfnam $ofnam 
				append sndfnam $evv(SNDFILE_EXT)
			}
			set n 1
			set OK 1
			while {$n <= $outmixes} {
				set mixfnam($n) $ofnam
				if {$outmixes > 1} {
					append mixfnam($n) _$n
				}
				append mixfnam($n) [GetTextfileExtension mmx]
				set overwritedat 0
				set overwritesnd 0
				if {[file exists $mixfnam($n)]} {
					if {($n == 1) && $doplay && [file exists $sndfnam]} {
						set msg "Files $mixfnam($n) and $sndfnam already exists : overwrite them ??"
						set overwritesnd 1
					} else {
						set msg "File $mixfnam($n) already exists : overwrite it ??"
					}
					set overwritedat 1
				} elseif {($n == 1) && $doplay && [file exists $sndfnam]} {
					set msg "File $sndfnam already exists : overwrite it ??"
					set overwritesnd 1
				}
				if {$overwritedat || $overwritesnd} {
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						set OK 0
						break
					}
					if {$overwritedat} {
						if {![CouetteAllowsDelete $mixfnam($n)]} {
							set OK 0
							break
						}
						if [catch {file delete -force $mixfnam($n)} in] {
							Inf "Cannot delete the existing file $mixfnam($n)."
							set OK 0
							break
						} else {											;# Copy only takes place from Dirlist to Wkspace.
							DataManage delete $mixfnam($n)
							DeleteFileFromSrcLists $mixfnam($n)					;# File created is a wkspace file.
							RemoveFromChosenlist $mixfnam($n)
							PurgeArray $mixfnam($n)
							DummyHistory $mixfnam($n) "OVERWRITTEN"
							set i [LstIndx $mixfnam($n) $wl]
							if {$i >= 0} {
								$wl delete $i
							}
						}
					}
					if {$overwritesnd} {
						if [catch {file delete -force $sndfnam} in] {
							Inf "Cannot delete the existing file $sndfnam."
							set OK 0
							break
						} else {											;# Copy only takes place from Dirlist to Wkspace.
							DataManage delete $sndfnam
							DeleteFileFromSrcLists $sndfnam					;# File created is a wkspace file.
							RemoveFromChosenlist $sndfnam
							PurgeArray $sndfnam
							DummyHistory $sndfnam "OVERWRITTEN"
							set i [LstIndx $sndfnam $wl]
							if {$i >= 0} {
								$wl delete $i
							}
						}
					}
				}
				incr n
			}
			if {!$OK} {
				continue
			}
			if {$lastindex == 0} {							;#	If the last entry was silent, it will be omitted from mixfile anyway
				set mix_noend 0
			} else {										;#	Otherwise, omit last line if flagged to do so
				set mix_noend $mixnoend 
			}
			set inlinecnt 0					;#	Count input lines processed
											;#	Count input lines still to process
			set lines_remaining [expr $inlines	- $mix_noend]
			set outlinecnt 0				;#	Count mix entries
			set mixcnt 1					;#	Count output mixfiles
			set nulines [list 8]			;#	Establish first line of multichan mixfile									
			while {$lines_remaining > 0} {
				set line [lindex $lines $inlinecnt]
				foreach {time midi level pos} $line {
					if {$mode == "snds"} {
						set k [lsearch $midivals $midi]					;#	Which Index value (in ascending order list of Index vals)
					} else {
						set k [lsearch $sndiii $midi]					;#	Which SND associated with midi value, in indexed list
					}
					incr k $extrasilence								;#	(if extra silent file in list, skip it in count)
					set snd [lindex $sfnams $k]							;#	Which sound corresponds to this Index val
					set lpos [expr int(floor($pos))]					;#	Find appropriate loudspeaker pair in ring
					set stereopos [expr $pos - $lpos]					;#	Find inter-lspkr position
					if {$lpos == 0} {
						set lpos 8
					}
					set rpos [expr $lpos + 1]
					if {$rpos > 8} {
						set rpos 1
					}
					if {[Flteq $stereopos 0.0]} {
						set routing [list 1:$lpos 1.0]
					} else {
						set xpos [expr ($stereopos * 2.0) - 1.0]		;#	Convert 0-1 range to -1 to +1 range
						if {$xpos < 0.0} {
							set relpos [expr -$xpos]					;#	Get position relative to midpoint
						} else {
							set relpos $xpos
						}												;#	Do hole in middle compensation
						set temp [expr 1.0 + ($relpos * $relpos)]
						set	reldist [expr $evv(ROOT2) / sqrt($temp)]
						set rlevel [expr $stereopos * $reldist]
						set llevel [expr (1.0 - $stereopos) * $reldist]	;#	Set appopriate left and right levels
						set routing [list 1:$lpos $llevel 1:$rpos $rlevel]
					}
					catch {unset nurouting}
					foreach {rout lev} $routing {						;#	Scale to INPUT level
						set lev [expr $level * $lev]
						lappend nurouting $rout $lev
					}
					set nuline [list $snd $time 1]
					set nuline [concat $nuline $nurouting]
					
				}
				lappend nulines $nuline
				incr inlinecnt
				incr lines_remaining -1
				incr outlinecnt
				if {($outlinecnt >= 998) && ($lines_remaining > 0)} {	;#	If maximum mixsize is exceeded, and there are still lines to process
					if [catch {open $mixfnam($mixcnt) "w"} zit] {		;#	Write the current mix
						Inf "Cannot open output file $mixfnam($mixcnt)"
						set OK 0
						break
					}
					foreach line $nulines {
						puts $zit $line
					}
					close $zit
					set nulines [list 8]								;#	And start a new mixfile
					set outlinecnt 0									;#	Restart count of entries in mixfile
					set snd [lindex $sfnams 0]							;#	Adding a silent file in first line
					set nuline [list $snd 0 1 "1:1" 1]					;#	To generate necessary time offset in output	
					lappend nulines $nuline
					incr outlinecnt
					incr mixcnt
				}
			}
			if {!$OK} {
				continue
			}
			if [catch {open $mixfnam($mixcnt) "w"} zit] {
				Inf "Cannot open output file $mixfnam($mixcnt)"
				continue
			}
			foreach line $nulines {
				puts $zit $line
			}
			close $zit
			set outmsg ""
			if {$doplay} {
				while {$OK} {

				;#	DOING THE MIX 

					;#	TEST FOR ANY MIX TOO LOUD

					set tooloud 0
					set n 1
					set knot(mixlevel) 1.0
					while {$n <= $mixcnt} {
						set OK 1
						if {$n == 1} {
							Block "TEST MIXING THE SOUNDS IN $mixfnam($n)"
						} else {
							if [catch {file delete $tempofnam(0)} zit] {
								Inf "CANNOT DELETE TEMPORARY SNDFILE $tempofnam(0) GENERATED ON LAST MIX PASS"
								set OK 0
								break
							}
							wm title .blocker "PLEASE WAIT:        TEST MIXING THE SOUNDS IN $mixfnam($n)"
						}
						set cmd [file join $evv(CDPROGRAM_DIR) newmix]
						lappend cmd multichan $mixfnam($n) $tempofnam(0) -g$knot(mixlevel)
						set CDPidrun 0
						set prg_dun 0
						set prg_abortd 0
						catch {unset simple_program_messages}
						if [catch {open "|$cmd"} CDPidrun] {
							Inf "$CDPidrun : Failed to test mix the sounds in $mixfnam($n):\n$cmd"
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
							Inf "$CDPidrun : Test mixing sounds in $mixfnam($n)failed :"
							set OK 0
							break
						}
						if {![file exists $tempofnam(0)]} {
							Inf "$CDPidrun : Failed to generate test mix of sounds in $mixfnam($n): \n$cmd"
							set OK 0
							break
						}

						wm title .blocker "PLEASE WAIT:        CHECKING TEST MIX LEVEL IN $mixfnam($n)"

						catch {unset CDPmaxId}
						catch {unset maxsamp_line}
						set done_maxsamp 0
						set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
						lappend cmd $tempofnam(0)
						lappend cmd 1		;#	1 flag added to FORCE read of maxsample
						if [catch {open "|$cmd"} CDPmaxId] {
							Inf "Finding maximum level of test mix $mixfnam($n) output: process failed\n$cmd"
							set OK 0
							break
	   					} else {
	   						fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
						}
	 					vwait done_maxsamp
						if {[info exists maxsamp_line]} {
							set knot(maxsamp) [lindex $maxsamp_line 0]
						} else {
							Inf "Failed to find maximum level of test mix $mixfnam($n) output\n$cmd"
							set OK 0
							break
						}
						if {$knot(maxsamp) > 0.95} {
							set tooloud 1
							break
						}
						incr n
					}
					if {!$OK} {
						UnBlock
						break
					}

					;#	IF NESS, REMIX, AND TEST FOR LEVEL TOO QUIET

					if {$tooloud} {						;#	If any mix too loud
						set knot(mixlevel) 0.1			;#	On first mix(es), reduce level by factor of 10
						set toolow -1
						while {$n <= $mixcnt} {
							if [catch {file delete $tempofnam(0)} zit] {
								Inf "Cannot delete sound $tempofnam(0) generated on earlier mix pass"
								set OK 0
								break
							}
							wm title .blocker "PLEASE WAIT:        2nd TEST MIX OF SOUNDS IN $mixfnam($n)"
							set cmd [file join $evv(CDPROGRAM_DIR) newmix]
							lappend cmd multichan $mixfnam($n) $tempofnam(0) -g$knot(mixlevel)
							set CDPidrun 0
							set prg_dun 0
							set prg_abortd 0
							catch {unset simple_program_messages}
							if [catch {open "|$cmd"} CDPidrun] {
								Inf "$CDPidrun : Failed to do 2nd test mix of sounds in $mixfnam($n) :\n$cmd"
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
								Inf "$CDPidrun : 2nd test mix of sounds in $mixfnam($n) failed"
								set OK 0
								break
							}
							if {![file exists $tempofnam(0)]} {
								Inf "$CDPidrun : Failed to generate 2nd test mix of sounds in $mixfnam($n) :\n$cmd"
								set OK 0
								break
							}

							wm title .blocker "PLEASE WAIT:        LEVEL CHECK 2nd TESTMIX $mixfnam($n)"

							catch {unset CDPmaxId}
							catch {unset maxsamp_line}
							set done_maxsamp 0
							set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
							lappend cmd $tempofnam(0)
							lappend cmd 1		;#	1 flag added to FORCE read of maxsample
							if [catch {open "|$cmd"} CDPmaxId] {
								Inf "Finding maxlevel 2nd test mix of $mixfnam($n): process failed\n$cmd"
								set OK 0
								break
	   						} else {
	   							fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
							}
	 						vwait done_maxsamp
							if {[info exists maxsamp_line]} {
								set knot(maxsamp) [lindex $maxsamp_line 0]
							} else {
								Inf "Failed to find maxlevel of 2nd testmix of $mixfnam($n)\n$cmd"
								set OK 0
								break
							}
							if {$knot(maxsamp) > $toolow} {	;#	Find level of LOUDEST mixfile
								set toolow $knot(maxsamp)
							}
							incr n
						}
						if {!$OK} {
							break
						}

						if {$toolow < 0.9} {	;#	If level falls below 0.9, attempt to adjust upwards
							set knot(mixlevel) [expr $knot(mixlevel) * (0.9/$toolow)]
						}
					}
					if {!$OK} {
						UnBlock
						break
					}
					set n 1
					while {$n <= $mixcnt} {
						wm title .blocker "PLEASE WAIT:        MIXING THE SOUNDS IN $mixfnam($n)"
						set cmd [file join $evv(CDPROGRAM_DIR) newmix]
						lappend cmd multichan $mixfnam($n) $tempofnam($n) -g$knot(mixlevel)
						set CDPidrun 0
						set prg_dun 0
						set prg_abortd 0
						catch {unset simple_program_messages}
						if [catch {open "|$cmd"} CDPidrun] {
							Inf "$CDPidrun : Failed to mix the sounds in $mixfnam($n) :\n$cmd"
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
							Inf "$CDPidrun : Mixing sounds in $mixfnam($n) failed :\n$cmd"
							set OK 0
							break
						}
						if {![file exists $tempofnam($n)]} {
							Inf "$CDPidrun : Failed to generate mix of sounds in $mixfnam($n) :\n$cmd"
							set OK 0
							break
						}
						incr n
					}
					if {!$OK} {
						break
					}
					if {$mixcnt > 1} {
						wm title .blocker "PLEASE WAIT:        MIXING THE VARIOUS OUTPUTS"
						if [catch {file delete $tempofnam(0)} zit] {
							Inf "Cannot delete sound $tempofnam(0) generated on earlier mix pass"
							set OK 0
							break
						}
						catch {unset nulines}
						set line [list 8]
						lappend nulines $line
						set n 1
						while {$n <= $mixcnt} {
							set line [list $tempofnam($n) 0.0 8 1:1 1 2:2 1 3:3 1 4:4 1 5:5 1 6:6 1 7:7 1 8:8 1]
							lappend nulines $line
							incr n
						} 
						if [catch {open $ubermixnam "w"} zit] {
							Inf "Cannot open file $ubermixnam to mix the various sound outputs"
							set OK 0
							break
						}
						foreach line $nulines {
							puts $zit $line
						}
						close $zit
						set cmd [file join $evv(CDPROGRAM_DIR) newmix]
						lappend cmd multichan $ubermixnam $tempofnam(0)
						set CDPidrun 0
						set prg_dun 0
						set prg_abortd 0
						catch {unset simple_program_messages}
						if [catch {open "|$cmd"} CDPidrun] {
							Inf "$CDPidrun : Failed to mix the various outputs :\n$cmd"
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
							Inf "$CDPidrun : Mixing various output sounds failed :\n$cmd"
							set OK 0
							break
						}
						if {![file exists $tempofnam(0)]} {
							Inf "$CDPidrun : Failed to generate mix of various output sounds:\n$cmd"
							set OK 0
							break
						}
					}
					break
				}
				UnBlock
				if {!$OK} {
					continue
				}
				if [catch {file rename $tempofnam(0) $sndfnam} zit] {
					Inf "Cannot rename temporary outfile $tempofnam(0) to $sndfnam\ndo this outside the loom before proceeding"
				} elseif {[FileToWkspace $sndfnam 0 0 0 0 1] > 0} {
					append outmsg "File $sndfnam is on the workspace\n"
					set last_outfile $sndfnam
				} else {
					append outmsg "File $sndfnam has been created\n"
				}		
			} elseif {$mixcnt > 1} {
				Inf "Output consists of $mixcnt mixes : output of these mixes should be mixed in sync"
			}
			set n 1
			catch {unset lastfiles}
			while {$n <= $mixcnt} {
				FileToWkspace $mixfnam($n) 0 0 0 0 1
				lappend lastfiles $mixfnam($n)
				incr n
			}
			if {!$doplay} { 
				set last_outfile $lastfiles
			}
			if {$mixcnt > 1} {
				set msg "Mixfiles are "
			} else {
				set msg "Mixfile is "
			}
			if {$doplay} { 
				append msg "also "
			}
			append msg "on the Workspace"
			append outmsg $msg
			Inf $outmsg
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#----- Repeat (and possibly rescale) a pattern

proc KnotExtend {} {
	global chlist evv pa wstk pr_knotextend knot_extend knot_scale knot_extend_fnam last_outfile wl knot_end knot_stt TILPlist

	if {![info exists chlist] || ([llength $chlist] <= 0)} {
		Inf "Select one \"time-index-level\"  or \"time-index-level position\" format file"
		return
	}
	set ifnam [lindex $chlist 0]
	set ftyp $pa($ifnam,$evv(FTYP))
	if {![IsAListofNumbers $ftyp]} {
		Inf "Select a \"time  index  level\" format file"
		return
	}
	if [catch {open $ifnam "r"} zit] {
		Inf "Cannot open file $ifnam"
		return
	}
	set linecnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		incr linecnt
		catch {unset nuline}
		set line [split $line]
		set cnt 0
		set OK 1
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			switch -- $cnt {
				0 {
					if {$linecnt == 1} {
						if {$item != 0.0} {
							Inf "Initial time in input file must be zero"
							set OK 0
							break
						}
					} elseif {$item < $lasttime} {
						Inf "Times ($lasttime $item) in input file do not increase at line $linecnt"
						set OK 0
						break
					}
					lappend pattern_times $item
					set lasttime $item	
				}
				1 {
					if {![regexp {^[0-9]+$} $item] || ![IsNumeric $item]} {
						Inf "Invalid sound-index value on line $linecnt"
						set OK 0
						break
					}
				}
				2 {
					if {($item < 0.0) || ($item > 1.0)} {
						Inf "Invalid level value on line $linecnt"
						set OK 0
						break
					}
				}
				3 {
					if {($item < 0.0) || ($item > 8.0)} {
						Inf "Invalid position value on line $linecnt of file $ifnam"
						set OK 0
						break
					}
				}
			}					
			lappend nuline $item
			incr cnt
		}
		if {!$OK} {
			break
		}
		if {$linecnt == 1} {
			set line_len $cnt
		} elseif {$cnt != $line_len} {
			Inf "Wrong number of values ($cnt) on line ($linecnt): line 1 has $line_len values"
			set OK 0
			break
		}
		if {($cnt < 3) || ($cnt > 4)} {
			Inf "Wrong number of values ($cnt) on line ($linecnt): requires 3 or 4 values"
			set OK 0
			break
		}
		lappend lines $nuline

	}
	;#	Reuse existing "STEND" info

	if {$line_len == 4} {
		set stendfnam [file rootname $ifnam]
		append stendfnam "_stend" $evv(TEXT_EXT)
		if {[file exists $stendfnam]} {
			set stendata [GetLastCellData $stendfnam]
			if {[llength $stendata] != 2} {
				set msg "Invalid data in file $stendfnam: ignore it ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					return
				}
				unset stendata
			}
		}
		if {[info exists stendata]} {
			set stttime [lindex $stendata 0]
		}
		set rhypos 1
	}

	close $zit
	if {!$OK} {
		return
	}
	if {$linecnt < 1} {
		Inf "No data found in file $ifnam"
		return
	}
	set pattern_dur [lindex $pattern_times end]
	set f .knotextend
	if [Dlg_Create $f "REPEAT/RESCALE RHYTHM" "set pr_knotextend 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.save -text "Generate" -command "set pr_knotextend 1" -bg $evv(EMPH)
		button $f.0.quit -text "Abandon" -command "set pr_knotextend 0"
		pack $f.0.save -side left -padx 4
		pack $f.0.quit -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Repetitions"
		label $f.1.dum -text "" -width 24
		entry $f.1.e -textvariable knot_extend -width 16
		pack $f.1.e $f.1.ll $f.1.dum -side left -padx 2
		pack $f.1 -side top -pady 2 -fill x -expand true
		frame $f.2
		label $f.2.ll -text "Rescale Duration"
		entry $f.2.e -textvariable knot_scale -width 16
		pack $f.2.e $f.2.ll -side left -padx 2
		pack $f.2 -side top -pady 2 -fill x -expand true -anchor w
		frame $f.3
		checkbutton $f.3.knotend -variable knot_end -text "Keep marker at end of final pattern "
		checkbutton $f.3.knotstt -variable knot_stt -text "Remove start of pattern events"
		pack $f.3.knotend $f.3.knotstt -side top -padx 2 -anchor w
		pack $f.3 -side top -pady 2 -anchor w
		frame $f.4
		label $f.4.ll -text "Output Filename"
		entry $f.4.e -textvariable knot_extend_fnam -width 16
		pack $f.4.e $f.4.ll -side left -padx 2 
		pack $f.4 -side top -pady 2 -fill x -expand true -anchor w
		wm resizable $f 0 0
		bind $f <Escape> {set pr_knotextend 0}
		bind $f <Return> {set pr_knotextend 1}
	}
	set knot_end 1
	set knot_stt 0
	set knot_extend_fnam ""
	set knot_scale $pattern_dur
	set pr_knotextend 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_knotextend
	while {!$finished} {
		tkwait variable pr_knotextend
		if {$pr_knotextend} {
			if {![regexp {^[0-9]+$} $knot_extend] ||  ($knot_extend < 1)} {
				Inf "Invalid repetitions value entered"
				continue
			}
			if {![IsNumeric $knot_scale] || ($knot_scale <= $evv(FLTERR))} {
				Inf "Invalid rescale duration entered"
				continue
			}
			if {[Flteq $knot_scale $pattern_dur] && ($knot_extend == 1) && ($knot_end == 1) && ($knot_stt == 0)} {
				Inf "No modification to original pattern"
				continue
			}
			if {$knot_stt && [info exists rhypos]} {
				set msg "Mapping not possible if start of pattern events removed : proceed anyway ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				} else {
					unset rhypos
				}
			}
			if {![ValidCDPRootname $knot_extend_fnam]} {
				continue
			}
			set ofnam [string tolower $knot_extend_fnam] 
			set stendofnam [file rootname $ofnam]
			append stendofnam "_stend" $evv(TEXT_EXT)
			set mapofnam [file rootname $ofnam]
			append mapofnam "_map" $evv(TEXT_EXT)
			append ofnam $evv(TEXT_EXT)
			set do_overwrite 0
			if {[file exists $ofnam]} {
				set msg "File $ofnam already exists : overwrite it ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				if {![CouetteAllowsDelete $ofnam]} {
					continue
				}
				if [catch {file delete -force $ofnam} in] {
					Inf "Cannot delete the existing file."
					continue
				} else {											;# Copy only takes place from Dirlist to Wkspace.
					DataManage delete $ofnam
					CouettePatchesDelete $ofnam
					DeleteFileFromSrcLists $ofnam					;# File created is a wkspace file.
					set ftyp $pa($ofnam,$evv(FTYP))
					RemoveFromChosenlist $ofnam
					PurgeArray $ofnam
					DummyHistory $ofnam "OVERWRITTEN"
					set i [LstIndx $ofnam $wl]
					if {$i >= 0} {
						$wl delete $i
					}
				}
				set do_overwrite 1
			}
			if {[file exists $stendofnam]} {
				if {!$do_overwrite} {
					set msg "File $stendofnam already exists : overwrite it ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
				}
				if {![CouetteAllowsDelete $stendofnam]} {
					continue
				}
				if [catch {file delete -force $stendofnam} in] {
					Inf "Cannot delete the existing file $stendofnam."
					continue
				} else {											;# Copy only takes place from Dirlist to Wkspace.
					DataManage delete $stendofnam
					CouettePatchesDelete $stendofnam
					DeleteFileFromSrcLists $stendofnam					;# File created is a wkspace file.
					set ftyp $pa($stendofnam,$evv(FTYP))
					RemoveFromChosenlist $stendofnam
					PurgeArray $stendofnam
					DummyHistory $stendofnam "OVERWRITTEN"
					set i [LstIndx $stendofnam $wl]
					if {$i >= 0} {
						$wl delete $i
					}
				}
			}
			if {[file exists $mapofnam]} {
				if {!$do_overwrite} {
					set msg "File $mapofnam already exists : overwrite it ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
				}
				if {![CouetteAllowsDelete $mapofnam]} {
					continue
				}
				if [catch {file delete -force $mapofnam} in] {
					Inf "Cannot delete the existing file $mapofnam."
					continue
				} else {											;# Copy only takes place from Dirlist to Wkspace.
					DataManage delete $mapofnam
					CouettePatchesDelete $mapofnam
					DeleteFileFromSrcLists $mapofnam					;# File created is a wkspace file.
					set ftyp $pa($mapofnam,$evv(FTYP))
					RemoveFromChosenlist $mapofnam
					PurgeArray $mapofnam
					DummyHistory $mapofnam "OVERWRITTEN"
					set i [LstIndx $mapofnam $wl]
					if {$i >= 0} {
						$wl delete $i
					}
				}
			}
			set scaler [expr double($knot_scale)/double($pattern_dur)]
			catch {unset nulines}
			if {[Flteq $scaler 1.0]} {
				set nulines $lines
			} else {
				if {[info exists rhypos]} {
					foreach line $lines {
						foreach {time midi level pos} $line {		;#	Scale the original 4-pattern
							set time [expr $time * $scaler]
						}
						set nuline [list $time $midi $level $pos]
						lappend nulines $nuline
					}
				} else {
					foreach line $lines {
						foreach {time midi level} $line {			;#	Scale the original 3-pattern
							set time [expr $time * $scaler]
						}
						set nuline [list $time $midi $level]
						lappend nulines $nuline
					}
				}
			}
			if {$knot_end} {									;#	If endofpattern marker to be retained
				set endline [lindex $nulines end]				;#	Remember it
			}
			set len [llength $nulines]							;#	Drop the end-of-pattern marker from repeated unit
			incr len -2
			set nulines [lrange $nulines 0 $len]
			catch {unset nunulines}
			set n 0 
			if {[info exists rhypos]} {
				set mapline 1
				catch {unset thismap}
			}
			while {$n < $knot_extend} {							;#	Repeat the (rescaled) pattern
				set basetime [expr double($n) * $knot_scale]
				set linecnt 0
				foreach line $nulines {
					if {$knot_stt && ($linecnt == 0)} {			;#	If first line of pattern, && start event NOT to be retained
						if {$n == 0} {							
							if {[info exists rhypos]} {
								foreach {time midi level pos} $line {	;#	If first event, add a dummy (silent) entry				
									set midi 0
								}
							} else { 
								foreach {time midi level} $line {	;#	If first event, add a dummy (silent) entry				
									set midi 0
								}
							}
						} else {								;#	if NOT first line of pattern, skip this entry
							incr linecnt
							continue
						}				
					} else {				
						if {[info exists rhypos]} {
							foreach {time midi level pos} $line {
								set time [expr $time + $basetime]
							}
						} else {
							foreach {time midi level} $line {
								set time [expr $time + $basetime]
							}
						}
					}
					if {[info exists rhypos]} {
						set nunuline [list $time $midi $level $pos]
						lappend thismap($n) $mapline
						incr mapline
					} else {
						set nunuline [list $time $midi $level]
					}
					lappend nunulines $nunuline
					incr linecnt
				}
				set lastpatternstart $basetime
				incr n
			}
			set endtime [expr double($n) * $knot_scale]
			if {$knot_end} {									;#	If requested, add the (new) endofpattern marker
				set endline [lreplace $endline 0 0 $endtime]
				lappend nunulines $endline
			}
			if {[info exists rhypos]} {
				if [catch {open $mapofnam "w"} zit] {
					set msg "Cannot open output map-file $mapofnam : proceed anyway ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
				} else {
					set line ";MAPPING OF CORRESPONDING EVENTS ACROSS THE REPEATS"
					puts $zit $line
					set m 0
					while {$m < $linecnt} {
						catch {unset line}
						set n 0 
						while {$n < $knot_extend} {
							lappend line [lindex $thismap($n) $m]
							incr n
						}
						puts $zit $line
						incr m
					}
					close $zit
					FileToWkspace $mapofnam 0 0 0 0 1
				}

				if {[info exists stendata]} {
					if {![Flteq $scaler 1.0]} {
						set stttime [expr $stttime * $scaler]
					}
					set stttime [expr $lastpatternstart + $stttime]
				} else {
					set stttime $lastpatternstart
				}
				if [catch {open $stendofnam "w"} zit] {
					set msg "Cannot open output stend-file $stendofnam : proceed anyway ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
				} else {
					set line [list $stttime $endtime]
					puts $zit $line
					close $zit
					FileToWkspace $stendofnam 0 0 0 0 1
				}
			}
			if [catch {open $ofnam "w"} zit] {
				Inf "Cannot open output file $ofnam"
				continue
			}
			foreach line $nunulines {
				puts $zit $line
			}
			close $zit
			if {[FileToWkspace $ofnam 0 0 0 0 1] > 0} {
				Inf "File $ofnam is on the workspace"
				set last_outfile $ofnam
			} else {
				Inf "File $ofnam has been created"
			}		
			if {$rhypos} {
				set hline "REPEAT-RESCALE [file rootname $ifnam] TO [file rootname $ofnam] :"
				append hline " repeated $knot_extend times: rescaled by $knot_scale"
				DoRhythmHistory $hline
				lappend TILPlist $ofnam
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#----- Abutt Rhythm-patterns

proc KnotJoin {} {
	global chlist evv pa wstk pr_knotjoin knot_join_fnam last_outfile wl knot_end knot_stt TILPlist
	if {![info exists chlist] || ([llength $chlist] < 2)} {
		Inf "Select two or more \"time-index-level\" or \"time-index-level-position\" format files"
		return
	}
	foreach ifnam $chlist {
		set ftyp $pa($ifnam,$evv(FTYP))
		if {![IsAListofNumbers $ftyp]} {
			Inf "Select a \"time  index  level\" or \"time  index  level position\"format file"
			return
		}
		if [catch {open $ifnam "r"} zit] {
			Inf "Cannot open file $ifnam"
			return
		}
		set linecnt 0
		catch {unset lines}
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			if {[string match [string index $line 0] ";"]} {
				continue
			}
			incr linecnt
			catch {unset nuline}
			set line [split $line]
			set cnt 0
			set OK 1
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				switch -- $cnt {
					0 {
						if {$linecnt == 1} {
							if {$item != 0.0} {
								Inf "Initial time in input file must be zero"
								set OK 0
								break
							}
						} elseif {$item < $lasttime} {
							Inf "Times ($lasttime $item) in input file do not increase at line $linecnt"
							set OK 0
							break
						}
						set lasttime $item	
					}
					1 {
						if {![regexp {^[0-9]+$} $item] || ![IsNumeric $item]} {
							Inf "Invalid sound-index value on line $linecnt"
							set OK 0
							break
						}
					}
					2 {
						if {($item < 0.0) || ($item > 1.0)} {
							Inf "Invalid level value on line $linecnt"
							set OK 0
							break
						}
					}
					3 {
						if {($item < 0.0) || ($item > 8.0)} {
							Inf "Invalid position value on line $linecnt of file $ifnam"
							set OK 0
							break
						}
					}
				}					
				lappend nuline $item
				incr cnt
			}
			if {!$OK} {
				break
			}
			if {$linecnt == 1} {
				set line_len $cnt
			} elseif {$cnt != $line_len} {
				Inf "Wrong number of values ($cnt) on line ($linecnt): first line had $line_len values"
				set OK 0
				break
			}
			if {($cnt < 3) || ($cnt > 4)} {
				Inf "Wrong number of values ($cnt) on line ($linecnt): requires 3 or 4 values"
				set OK 0
				break
			}
			lappend lines $nuline

		}
		close $zit
		if {!$OK} {
			return
		}
		if {$linecnt < 1} {
			Inf "No data found in file $ifnam"
			return
		}
		lappend patterns $lines
	}

	;#	Reuse existing "STEND" info

	if {$line_len == 4} {
		set stendfnam [file rootname $ifnam]
		append stendfnam "_stend" $evv(TEXT_EXT)
		if {[file exists $stendfnam]} {
			set stendata [GetLastCellData $stendfnam]
			if {[llength $stendata] != 2} {
				set msg "Invalid data in file $stendfnam: ignore it ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					return
				}
				unset stendata
			}
		}
		if {[info exists stendata]} {
			set stttime [lindex $stendata 0]
		}
		set rhypos 1
	}
	set f .knotjoin
	if [Dlg_Create $f "ABUTT RHYTHMS" "set pr_knotjoin 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.save -text "Join" -command "set pr_knotjoin 1" -bg $evv(EMPH)
		button $f.0.quit -text "Abandon" -command "set pr_knotjoin 0"
		pack $f.0.save -side left -padx 4
		pack $f.0.quit -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Output Filename"  -width 16
		entry $f.1.e -textvariable knot_join_fnam -width 16
		pack $f.1.ll $f.1.e -side left -padx 2 
		pack $f.1 -side top -pady 2 -fill x -expand true
		wm resizable $f 0 0
		bind $f <Escape> {set pr_knotjoin 0}
		bind $f <Return> {set pr_knotjoin 1}
	}
	set knot_join_fnam ""
	set pr_knotjoin 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_knotjoin
	while {!$finished} {
		tkwait variable pr_knotjoin
		if {$pr_knotjoin} {
			if {![ValidCDPRootname $knot_join_fnam]} {
				continue
			}
			set ofnam [string tolower $knot_join_fnam] 
			set stendofnam $ofnam
			append stendofnam "_stend" $evv(TEXT_EXT)
			append ofnam $evv(TEXT_EXT)
			set do_overwrite 0
			if {[file exists $ofnam]} {
				set msg "File $ofnam already exists : overwrite it ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				if {![CouetteAllowsDelete $ofnam]} {
					continue
				}
				if [catch {file delete -force $ofnam} in] {
					Inf "Cannot delete the existing file $ofnam."
					continue
				} else {											;# Copy only takes place from Dirlist to Wkspace.
					DataManage delete $ofnam
					CouettePatchesDelete $ofnam
					DeleteFileFromSrcLists $ofnam					;# File created is a wkspace file.
					set ftyp $pa($ofnam,$evv(FTYP))
					RemoveFromChosenlist $ofnam
					PurgeArray $ofnam
					DummyHistory $ofnam "OVERWRITTEN"
					set i [LstIndx $ofnam $wl]
					if {$i >= 0} {
						$wl delete $i
					}
				}
				set do_overwrite 1
			}
			if {[file exists $stendofnam]} {
				if {!$do_overwrite} {
					set msg "File $stendofnam already exists : overwrite it ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
				}
				if {![CouetteAllowsDelete $stendofnam]} {
					continue
				}
				if [catch {file delete -force $stendofnam} in] {
					Inf "Cannot delete the existing file $stendofnam."
					continue
				} else {											;# Copy only takes place from Dirlist to Wkspace.
					DataManage delete $stendofnam
					CouettePatchesDelete $stendofnam
					DeleteFileFromSrcLists $stendofnam					;# File created is a wkspace file.
					set ftyp $pa($stendofnam,$evv(FTYP))
					RemoveFromChosenlist $stendofnam
					PurgeArray $stendofnam
					DummyHistory $stendofnam "OVERWRITTEN"
					set i [LstIndx $stendofnam $wl]
					if {$i >= 0} {
						$wl delete $i
					}
				}
			}
			catch {unset nulines}
			set cnt 0
			foreach pattern $patterns {
				set endline [lindex $pattern end]
				set endtime [lindex $endline 0]					;#	Get endevent time (endtime marker) of pattern
				set len [llength $pattern]
				incr len -2										;#	Jettison final event (endmarker)
				if {$cnt == 0} {
					foreach line [lrange $pattern 0 $len] {		
						lappend nulines $line
					}
					set starttime 0
				} else {
					foreach line [lrange $pattern 0 $len] {
						set time [lindex $line 0]
						set time [expr $time + $starttime]		;#	push pattern forward in time by duration of previous pattern
						set line [lreplace $line 0 0 $time]
						lappend nulines $line
					}
				}
				set thisstarttime $starttime  					;#	Remember starttime of current pattern
				set starttime [expr $starttime + $endtime]	    ;#	use endtime of previous pattern as starttime of next pattern
				incr cnt
			}													;#	Reinsert the (new) endtime of final patttern
			set time [expr $endtime + $thisstarttime]			;#	Incrementing its endtime
			set endline [lreplace $endline 0 0 $time]			;#	and inserting new endtime-marker line
			lappend nulines $endline

			if {[info exists rhypos]} {
				set endtime [expr $endtime + $thisstarttime]
				if {[info exists stendata]} {
					set stttime [expr $stttime + $thisstarttime]	;#	Stend data is advance by starttime of final pattern in abutt list
				} else {
					set stttime $thisstarttime						;#	Stend data is simply start and end of last pattern used
				}
				if [catch {open $stendofnam "w"} zit] {
					set msg "Cannot open output file $stendofnam : proceed anyway ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
				} else {
					set line [list $stttime $endtime]
					puts $zit $line
					close $zit
					FileToWkspace $stendofnam 0 0 0 0 1
				}
			}
			if [catch {open $ofnam "w"} zit] {
				Inf "Cannot open output file $ofnam"
				continue
			}
			foreach line $nulines {
				puts $zit $line
			}
			close $zit
			if {[FileToWkspace $ofnam 0 0 0 0 1] > 0} {
				Inf "File $ofnam is on the workspace"
				set last_outfile $ofnam
			} else {
				Inf "File $ofnam has been created"
			}		
			if {$rhypos} {
				set line "ABUTT creates [file rootname $ofnam] FROM"
				foreach ifnam $chlist {
					append line "  [file rootname $ifnam]"
				}
				DoRhythmHistory $line
				lappend TILPlist $ofnam
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Combine midifiles with position info, into sequential order

proc KnotLayer {} {
	global chlist evv pa wstk pr_unknot knot_layer_fnam last_outfile wl pr_knotlayer TILPlist
	if {![info exists chlist] || ([llength $chlist] < 2)} {
		Inf "Select two or more \"time  index  level position\" format files"
		return
	}
	set total_linecnt 0
	foreach ifnam $chlist {
		set ftyp $pa($ifnam,$evv(FTYP))
		if {![IsAListofNumbers $ftyp]} {
				Inf "File $ifnam does not have the correct \"time  index  level position\" format"
				return
		}
		if [catch {open $ifnam "r"} zit] {
			Inf "Cannot open file $ifnam"
			return
		}
		set linecnt 0
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			if {[string match [string index $line 0] ";"]} {
				continue
			}
			incr linecnt
			catch {unset nuline}
			set line [split $line]
			set cnt 0
			set OK 1
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				switch -- $cnt {
					0 {
						if {$linecnt == 1} {
							if {$item != 0.0} {
								Inf "Initial time in input data file $ifnam must be zero"
								set OK 0
								break
							}
						} elseif {$item < $lasttime} {
							Inf "Times ($lasttime $item) in input data file $ifnam do not increase at line $linecnt"
							set OK 0
							break
						}
						set lasttime $item	
						lappend times $item
					}
					1 {
						if {![regexp {^[0-9]+$} $item] || ![IsNumeric $item]} {
							Inf "Invalid sound-index value on line $linecnt of file $ifnam"
							set OK 0
							break
						}
					}
					2 {
						if {($item < 0.0) || ($item > 1.0)} {
							Inf "Invalid level value on line $linecnt of file $ifnam"
							set OK 0
							break
						}
					}
					3 {
						if {($item < 0.0) || ($item > 8.0)} {
							Inf "Invalid position value on line $linecnt of file $ifnam"
							set OK 0
							break
						}
					}
				}					
				lappend nuline $item
				incr cnt
			}
			if {!$OK} {
				break
			}
			if {$cnt != 4} {
				Inf "Wrong number of values ($cnt) on line ($linecnt) of file $ifnam: requires 4 values"
				set OK 0
				break
			}
			lappend lines $nuline
			incr total_linecnt
		}
		close $zit
		if {!$OK} {
			return
		}
		if {$linecnt < 1} {
			Inf "No data found in file $ifnam"
			return
		}
		lappend lasttimes $lasttime						;#	Endtimes in each pattern
		lappend end_lines [expr $total_linecnt - 1]		;#	Endlines in each pattern, as they are numbered when all concatenated together
	}				

	;#	ELIMINATE ALL BUT THE MAX-DURATION FINAL-MARKER FILE

	set maxtime -1
	set n 0	
	foreach ifnam $chlist {
		if {[lindex $lasttimes $n] > $maxtime} {
			set maxtime [lindex $lasttimes $n]
			set maxtimelineno [lindex $end_lines $n]
		}
		incr n
	}
	set end_lines [ReverseList $end_lines]
	foreach lineno $end_lines {
		if {$lineno != $maxtimelineno} {
			set lines [lreplace $lines $lineno $lineno]
			set times [lreplace $times $lineno $lineno]
		}
	}

	;#	SORT LINES INTO TIME ORDER

	set len [llength $times]
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set time_n [lindex $times $n]
		set line_n [lindex $lines $n]
		set m $n
		incr m
		while {$m < $len} {
			set time_m [lindex $times $m]
			if {$time_m < $time_n} {
				set line_m [lindex $lines $m]
				set lines [lreplace $lines $n $n $line_m]
				set lines [lreplace $lines $m $m $line_n]
				set times [lreplace $times $n $n $time_m]
				set times [lreplace $times $m $m $time_n]
				set line_n $line_m
				set time_n $time_m
			}
			incr m
		}
		incr n
	}
	
	;#	ELIMINATE DUPLICATE SILENT-FILES (INDEX 0) AT START

	set line [lindex $lines 0]
	set midival [lindex $line 1]
	if {$midival == 0} {
		set m 1
		while {$m < $len} {
			set line [lindex $lines $m]
			set midival [lindex $line 1]
			if {$midival == 0} {
				set lines [lreplace $lines $m $m]
				incr len -1
			} else {
				incr m
			}
		}
	}
	set f .knotlayer
	if [Dlg_Create $f "LAYER RHYTHMS" "set pr_knotlayer 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.save -text "Layer" -command "set pr_knotlayer 1" -bg $evv(EMPH)
		button $f.0.quit -text "Abandon" -command "set pr_knotlayer 0"
		pack $f.0.save -side left -padx 4
		pack $f.0.quit -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Output Filename"  -width 16
		entry $f.1.e -textvariable knot_layer_fnam -width 16
		pack $f.1.ll $f.1.e -side left -padx 2 
		pack $f.1 -side top -pady 2 -fill x -expand true
		wm resizable $f 0 0
		bind $f <Escape> {set pr_knotlayer 0}
		bind $f <Return> {set pr_knotlayer 1}
	}
	set pr_knotlayer 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_knotlayer
	while {!$finished} {
		tkwait variable pr_knotlayer
		if {$pr_knotlayer} {
			if {![ValidCDPRootname $knot_layer_fnam]} {
				continue
			}
			set ofnam [string tolower $knot_layer_fnam] 
			append ofnam $evv(TEXT_EXT)
			if {[file exists $ofnam]} {
				set msg "File $ofnam already exists : overwrite it ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				if {![CouetteAllowsDelete $ofnam]} {
					continue
				}
				if [catch {file delete -force $ofnam} in] {
					Inf "Cannot delete the existing file."
					continue
				} else {											;# Copy only takes place from Dirlist to Wkspace.
					DataManage delete $ofnam
					CouettePatchesDelete $ofnam
					DeleteFileFromSrcLists $ofnam					;# File created is a wkspace file.
					set ftyp $pa($ofnam,$evv(FTYP))
					RemoveFromChosenlist $ofnam
					PurgeArray $ofnam
					DummyHistory $ofnam "OVERWRITTEN"
					set i [LstIndx $ofnam $wl]
					if {$i >= 0} {
						$wl delete $i
					}
				}
			}
			if [catch {open $ofnam "w"} zit] {
				Inf "Cannot open file $ofnam"
				continue
			}
			foreach line $lines {
				puts $zit $line
			}
			close $zit
			if {[FileToWkspace $ofnam 0 0 0 0 1] > 0} {
				Inf "File $ofnam is on the workspace"
				set last_outfile $ofnam
			} else {
				Inf "File $ofnam has been created"
			}		
			lappend TILPlist $ofnam
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc UnKnot {} {
	global chlist evv pa wstk pr_unknot unknot_fnam last_outfile wl knot unknot_save readonlybg readonlyfg
	global CDPidrun prg_dun prg_abortd simple_program_messages knotcnt_line knotcnt_warning knot_cnt TILPlist

	set evv(DO_UNKNOT)	1
	set evv(DO_KNOT)	2
	set evv(KNOTCNT)	3

	if {![info exists chlist] || ([llength $chlist] < 2)} {
		Inf "Select two or more \"time  index  level position\" format files"
		return
	}
	foreach ifnam $chlist {
		set ftyp $pa($ifnam,$evv(FTYP))
		if {![IsAListofNumbers $ftyp]} {
				Inf "File $ifnam does not have the correct \"time  index  level position\" format"
				return
		}
		if [catch {open $ifnam "r"} zit] {
			Inf "Cannot open file $ifnam"
			return
		}
		set linecnt 0
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			if {[string match [string index $line 0] ";"]} {
				continue
			}
			incr linecnt
			catch {unset nuline}
			set line [split $line]
			set cnt 0
			set OK 1
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				if {[string match [string index $item 0] ";"]} {
					continue
				}
				switch -- $cnt {
					0 {
						if {$linecnt == 1} {
							if {$item != 0.0} {
								Inf "Initial time in input data file $ifnam must be zero"
								set OK 0
								break
							}
						} elseif {$item < $lasttime} {
							Inf "Times ($lasttime $item) in input data file $ifnam do not increase at line $linecnt"
							set OK 0
							break
						}
						set lasttime $item	
						lappend times $item
					}
					1 {
						if {![regexp {^[0-9]+$} $item] || ![IsNumeric $item]} {
							Inf "Invalid sound-index value on line $linecnt of file $ifnam"
							set OK 0
							break
						}
					}
					2 {
						if {($item < 0.0) || ($item > 1.0)} {
							Inf "Invalid level value on line $linecnt of file $ifnam"
							set OK 0
							break
						}
					}
					3 {
						if {($item < 0.0) || ($item > 8.0)} {
							Inf "Invalid position value on line $linecnt of file $ifnam"
							set OK 0
							break
						}
					}
				}					
				lappend nuline $item
				incr cnt
			}
			if {!$OK} {
				break
			}
			if {$cnt != 4} {
				Inf "Wrong number of values ($cnt) on line ($linecnt) of file $ifnam: requires 4 values"
				set OK 0
				break
			}
			lappend lines $nuline
		}
		close $zit
		if {!$OK} {
			return
		}
		if {$linecnt < 1} {
			Inf "No data found in file $ifnam"
			return
		}
	}				

	;#	SORT LINES INTO TIME ORDER

	set len [llength $times]
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set time_n [lindex $times $n]
		set line_n [lindex $lines $n]
		set m $n
		incr m
		while {$m < $len} {
			set time_m [lindex $times $m]
			if {$time_m < $time_n} {
				set line_m [lindex $lines $m]
				set lines [lreplace $lines $n $n $line_m]
				set lines [lreplace $lines $m $m $line_n]
				set times [lreplace $times $n $n $time_m]
				set times [lreplace $times $m $m $time_n]
				set line_n $line_m
				set time_n $time_m
			}
			incr m
		}
		incr n
	}
	
	;#	ELIMINATE DUPLICATE SILENT-FILES (SOUND-INDEX 0) AT START

	set line [lindex $lines 0]
	set midival [lindex $line 1]
	if {$midival == 0} {
		set m 1
		while {$m < $len} {
			set line [lindex $lines $m]
			set midival [lindex $line 1]
			if {$midival == 0} {
				set lines [lreplace $lines $m $m]
				incr len -1
			} else {
				incr m
			}
		}
	}

#	NB Sync end-of_pattern markers, and eliminate them (saving the duration)
	
#	params:
#	#	Initial number of repetitions of each pattern
#	#	Initial sequence of pattern-groupings (e.g. [for 4 patterns] 12, 34 or 12,13,14,23,24,34, or 123,124,234) Can be empty
#	#	No of Repetitions of each pattern-grouping
#	#	No of Repetitions of combined patterns (1234)
#	#	No of Repetitions of each unknotting step
#	#	No of Repetitions of unknotted pattern
#	#	No of extra steps towards final equispaced unknot (timesmoothingphase)
#	#	Checkbutton, does spatial smoothing begin (1) at start of unknotting, (2) at end of unknotting
#		Final spatial distribution of smoothed pattern 
#			(Mono?), Tutti, Mono-on-chansXY...,
#			Alternating on chans X,Y, or A,B,C,D etc 
#			Rotating clock, anticlock, between A and B
#			Rotating clock, anticlock, between A and B, more than one circuit
#			Rotating clock-then-anticlock, or vv

	set knot(warning) ""
	set f .unknot
	if [Dlg_Create $f "UNKNOT RHYTHMS" "set pr_unknot 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.doit -text "Unknot" -command "set pr_unknot 1" -bg $evv(EMPH) -width 6
		button $f.0.help -text "Help" -command "UnknotHelp" -bg $evv(HELP)
		label $f.0.pp -text "Patch"
		button $f.0.load -text "Load" -command "GetKnotPatch 0"
		button $f.0.save -text "Save" -command "set pr_unknot 3"
		button $f.0.del  -text "Delete" -command "GetKnotPatch 1"
		button $f.0.uks -text "How many unknot steps?" -command "set pr_unknot 2" -bg $evv(HELP)
		label $f.0.ll -text "Outfile name"
		entry $f.0.e -textvariable knot(ofnam) -width 16
		label $f.0.dum -text "" -width 8
		set knot(knk) 0
		button $f.0.quit -text "Quit" -command "set pr_unknot 0"
		pack $f.0.doit $f.0.help $f.0.pp $f.0.load $f.0.save $f.0.del $f.0.uks $f.0.ll $f.0.e $f.0.dum -side left -padx 2
		pack $f.0.quit -side right
		pack $f.0 -side top -fill x -expand true

		frame $f.0w
		entry $f.0w.w -textvariable knot(warning) -state readonly -readonlybackground [option get . background {}] -fg red -bd 0 -width 80
		pack $f.0w.w -side left -padx 2
		pack $f.0w -side top -pady 4

 		frame $f.0a
		checkbutton $f.0a.knk -text "To Knot" -command "KnotUnknot" -variable knot(knk) -width 10
		checkbutton $f.0a.inf -text "Add Descriptive info to output data" -variable knot(showinfo)
		pack $f.0a.knk $f.0a.inf -side left -padx 2
		pack $f.0a -side top -fill x -expand true

		frame $f.00
		label $f.00.ll -text "NUMBER OF REPETITIONS OF ......" -fg $evv(SPECIAL)
		pack $f.00.ll -side left -padx 2
		pack $f.00 -side top -pady 2 -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Each separate pattern, at start" 
		entry $f.1.e -textvariable knot(reps) -width 16
		pack $f.1.e $f.1.ll -side left -padx 2 
		pack $f.1 -side top -pady 2 -fill x -expand true

		frame $f.2
		label $f.2.ll -text "Each pattern-grouping at start"
		entry $f.2.e -textvariable knot(groupingreps) -width 16
		pack $f.2.e $f.2.ll -side left -padx 2
		pack $f.2 -side top -pady 2 -fill x -expand true

		frame $f.3
		label $f.3.ll -text "All patterns combined"
		entry $f.3.e -textvariable knot(allreps) -width 16
		pack $f.3.e $f.3.ll -side left -padx 2
		pack $f.3 -side top -pady 2 -fill x -expand true

		frame $f.4
		label $f.4.ll -text "Each unknotting step"
		entry $f.4.e -textvariable knot(unksteprep) -width 16
		pack $f.4.e $f.4.ll -side left -padx 2
		pack $f.4 -side top -pady 2 -fill x -expand true

		frame $f.5
		label $f.5.ll -text "Unknotted pattern"
		entry $f.5.e -textvariable knot(unkreps) -width 16
		pack $f.5.e $f.5.ll -side left -padx 2
		pack $f.5 -side top -pady 2 -fill x -expand true

		frame $f.8a
		label $f.8a.ll -text "PATTERN-GROUPINGS TO USE" -fg $evv(SPECIAL)
		pack $f.8a.ll -side left -padx 2
		pack $f.8a -side top -pady 2 -fill x -expand true

		frame $f.8
		button $f.8.b  -text "Pattern Files" -width 14 -command "FindPatternGroupingsFiles"
		entry $f.8.e -textvariable knot(groupings) -width 32
		pack $f.8.e $f.8.b -side left -padx 4
		pack $f.8 -side top -pady 2 -fill x -expand true

		frame $f.6a
		label $f.6a.ll -text "UNKNOTTING PARAMETERS" -fg $evv(SPECIAL)
		pack $f.6a.ll -side left -padx 2
		pack $f.6a -side top -pady 2 -fill x -expand true

		frame $f.6
		label $f.6.ll -text "Min time deviation from regular pulse, in unknotted state"
		entry $f.6.e -textvariable knot(mindev) -width 16
		pack $f.6.e $f.6.ll -side left -padx 2
		pack $f.6 -side top -pady 2 -fill x -expand true

		frame $f.7
		label $f.7.ll -text "Number of pattern events to shift at each unknotting step (1-16)"
		entry $f.7.e -textvariable knot(clip) -width 16
		pack $f.7.e $f.7.ll -side left -padx 2
		pack $f.7 -side top -pady 2 -fill x -expand true

		frame $f.9
		label $f.9.ll -text "SPATIAL REDISTRIBUTION BEGINS AT..." -fg $evv(SPECIAL)
		frame $f.9.1
		radiobutton $f.9.1.1  -variable knot(respacestt) -text "unknotting start" -value 1 -width 20
		radiobutton $f.9.1.2  -variable knot(respacestt) -text "unknotting end"   -value 2 -width 20
		set knot(respacestt) 0
		pack $f.9.1.1 $f.9.1.2 -side left -expand true -pady 2
		pack $f.9.ll $f.9.1 -side top -padx 2 -anchor w
		pack $f.9 -side top -pady 2 -fill x -expand true

		frame $f.10
		label $f.10.ll -text "FINAL SPATIAL DISTRIBUTION..." -fg $evv(SPECIAL)
		radiobutton $f.10.0  -variable knot(respace) -text "No respatialsation"  -value 0 -command "KnotChansShow 0"
		radiobutton $f.10.1  -variable knot(respace) -text "Mono"  -value 1 -command "KnotChansShow 1"
		radiobutton $f.10.2  -variable knot(respace) -text "Tutti" -value 2 -command "KnotChansShow 2"
		radiobutton $f.10.3  -variable knot(respace) -text "Tutti on specific channels" -value 3 -command "KnotChansShow 3"
		radiobutton $f.10.4  -variable knot(respace) -text "Alternating between channels...." -value 4 -command "KnotChansShow 4"
		radiobutton $f.10.5  -variable knot(respace) -text "Rotate clockwise between channels...." -value 5 -command "KnotChansShow 5"
		radiobutton $f.10.6  -variable knot(respace) -text "Rotate anticlock between channels...." -value 6 -command "KnotChansShow 6"
		radiobutton $f.10.7  -variable knot(respace) -text "Rotate clock-anticlock between channels...." -value 7 -command "KnotChansShow 7"
		radiobutton $f.10.8  -variable knot(respace) -text "Rotate anticlock-clock between channels...." -value 8 -command "KnotChansShow 8"
		set knot(respace) -1

		pack $f.10.ll $f.10.0 $f.10.1 $f.10.2 $f.10.3 $f.10.4 $f.10.5 $f.10.6 $f.10.7 $f.10.8 -side top -padx 2 -anchor w
		pack $f.10 -side top -pady 2 -fill x -expand true

		frame $f.11
		label $f.11.ll -text "OVER CHANNELS...." -fg $evv(SPECIAL)
		pack $f.11.ll -side top -pady 2 -anchor w
		pack $f.11 -side top -pady 2 -fill x -expand true
		set n 1
		frame $f.12
		while {$n <= 8} {
			checkbutton $f.12.$n  -variable knot(rspchan$n) -text "$n" -command "KnotChanCheck $n"
			pack $f.12.$n -side left -padx 2
			incr n
		}
		while {$n <= 8} {
			set knot(rspchan$n) 0
			incr n
		}
		pack $f.12 -side top -pady 2 -fill x -expand true

		wm resizable $f 0 0
		bind .unknot.0.e <Down> {focus .unknot.1.e }
		bind .unknot.1.e <Down> {focus .unknot.2.e }
		bind .unknot.2.e <Down> {focus .unknot.3.e }
		bind .unknot.3.e <Down> {focus .unknot.4.e }
		bind .unknot.4.e <Down> {focus .unknot.5.e }
		bind .unknot.5.e <Down> {focus .unknot.8.e }
		bind .unknot.8.e <Down> {focus .unknot.6.e }
		bind .unknot.6.e <Down> {focus .unknot.7.e }
		bind .unknot.7.e <Down> {focus .unknot.0.e }
		bind .unknot.0.e <Up> {focus .unknot.7.e }
		bind .unknot.1.e <Up> {focus .unknot.0.e }
		bind .unknot.2.e <Up> {focus .unknot.1.e }
		bind .unknot.3.e <Up> {focus .unknot.2.e }
		bind .unknot.4.e <Up> {focus .unknot.3.e }
		bind .unknot.5.e <Up> {focus .unknot.4.e }
		bind .unknot.8.e <Up> {focus .unknot.5.e }
		bind .unknot.6.e <Up> {focus .unknot.8.e }
		bind .unknot.7.e <Up> {focus .unknot.6.e }
		bind $f <Escape> {set pr_unknot 0}
		bind $f <Return> {set pr_unknot 1}
	}
	KnotChansShow $knot(respace)
	set pr_unknot 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_unknot $f.0.e
	while {!$finished} {
		tkwait variable pr_unknot
		set unknot_save 0
		if {$pr_unknot == 3} {
			set unknot_save 1
			set pr_unknot 1
		}
		switch -- $pr_unknot {
			1 -
			2 {
				set mode $evv(DO_UNKNOT)
				if {$pr_unknot == 2} {
					set mode $evv(KNOTCNT)
				} elseif {$knot(knk)} {
					set mode $evv(DO_KNOT)
				}
		
				;#	CHECK ALL PARAMS (except outfnam)

				if {$mode != $evv(KNOTCNT)} {
					if {![IsNumeric $knot(reps)] || ![regexp {^[0-9]+$} $knot(reps)] || ($knot(reps) < 0)} {
						Inf "Invalid entry for \"repetitions of each separate pattern\" (range >= 0)"	
						continue
					}
					if {![IsNumeric $knot(groupingreps)] || ![regexp {^[0-9]+$} $knot(groupingreps)] || ($knot(groupingreps) < 0)} {
						Inf "Invalid entry for \"repetitions of each pattern-grouping\" (range >= 0)"	
						continue
					}
					if {![IsNumeric $knot(allreps)] || ![regexp {^[0-9]+$} $knot(allreps)] || ($knot(allreps) < 0)} {
						Inf "Invalid entry for \"repetitions of combined-pattern\" (range >= 0)"	
						continue
					}
					if {![IsNumeric $knot(unksteprep)] || ![regexp {^[0-9]+$} $knot(unksteprep)] || ($knot(unksteprep) < 0)} {
						Inf "Invalid entry for \"repetitions of each unknotting step\" (range >= 0)"	
						continue
					}
					if {![IsNumeric $knot(unkreps)] || ![regexp {^[0-9]+$} $knot(unkreps)] || ($knot(unkreps) < 0)} {
						Inf "Invalid entry for \"repetitions of each unknotted pattern\" (range >= 0)"	
						continue
					}
					if {$knot(groupingreps) > 0} {
						if {[string match $knot(groupings) "0"] || ([string length $knot(groupings)] <= 0)} {
							Inf "No pattern file specified"	
							continue
						} elseif {![file exists $knot(groupings)] || ![KnotPatternGroupingFileTest $knot(groupings)]} {
							Inf "Invalid pattern file"	
							continue
						}
					} elseif {[string length $knot(groupings)] <= 0} {
						set knot(groupings) 0
					}
				}
				if {![IsNumeric $knot(mindev)] || ($knot(mindev) < 0.0) || ($knot(mindev) > 1)} {
					Inf "Invalid entry for \"min time deviation\" (range 0-1 secs)"	
					continue
				}
				if {![IsNumeric $knot(clip)] || ![regexp {^[0-9]+$} $knot(clip)] || ($knot(clip) < 1) || ($knot(clip) > 16)} {
					Inf "Invalid entry for \"number of pattern events to shift\" (range 1 - 16)"	
					continue
				}
				if {$mode != $evv(KNOTCNT)} {
					if {![KnotSpacetypeGet]} {
						continue
					}
					if {$knot(spactyp)} {
						catch {unset knot(chanlims)}
						set n 1
						set cnt 0
						while {$n <= 8} {
							if {$knot(rspchan$n)} {
								lappend knot(chanlims) $n			;#	NB, get chan lim params from here
								incr cnt
							}
							incr n
						}
						if {$cnt != 2} {
							Inf "Two channels must be set for this spatial redistribution type"
							continue
						}
					} else {
						set knot(chanlims) [list 0 0]		;#	DUMMY: Vals not used by program
					}
					if {$unknot_save} {
						SaveKnotPatch $mode
						continue
					}
	
					;#	CHECK OUTFILE NAME

					if {![ValidCDPRootname $knot(ofnam)]} {
						continue
					}
					set ofnam [string tolower $knot(ofnam)] 
					append ofnam $evv(TEXT_EXT)
					if {[file exists $ofnam]} {
						set msg "File $ofnam already exists : overwrite it ??"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							continue
						}
						if {![CouetteAllowsDelete $ofnam]} {
							continue
						}
						if [catch {file delete -force $ofnam} in] {
							Inf "Cannot delete the existing file."
							continue
						} else {											;# Copy only takes place from Dirlist to Wkspace.
							DataManage delete $ofnam
							CouettePatchesDelete $ofnam
							DeleteFileFromSrcLists $ofnam					;# File created is a wkspace file.
							set ftyp $pa($ofnam,$evv(FTYP))
							RemoveFromChosenlist $ofnam
							PurgeArray $ofnam
							DummyHistory $ofnam "OVERWRITTEN"
							set i [LstIndx $ofnam $wl]
							if {$i >= 0} {
								$wl delete $i
							}
						}
					}
				}
				switch -regexp -- $mode \
					^$evv(DO_UNKNOT)$ {
						set knottype "UNKNOTTING"
					} \
					^$evv(DO_KNOT)$ {
						set knottype "KNOTTING"
					} \
					^$evv(KNOTCNT)$ {
						set knottype "COUNTING UNKNOTS"
					}

				Block $knottype
				set cmd [file join $evv(CDPROGRAM_DIR) unknot]
				lappend cmd unknot $mode 
				foreach fnam $chlist {
					lappend cmd $fnam
				}
				if {$mode != $evv(KNOTCNT)} {	;#	no output file for counting mode
					lappend cmd $ofnam $knot(groupings) $knot(reps) $knot(groupingreps)
					lappend cmd $knot(allreps) $knot(unksteprep) $knot(unkreps) $knot(spactyp)
					set cmd [concat $cmd $knot(chanlims)]
				}
				lappend cmd -m$knot(mindev) -c$knot(clip)
				if {$knot(respacestt) == 2} {
					lappend cmd "-e"
				}
				if {$knot(showinfo)} {
					lappend cmd "-t"
				}
				set CDPidrun 0
				set prg_dun 0
				set prg_abortd 0
				catch {unset simple_program_messages}
				catch {unset knotcnt_line}
				catch {unset knotcnt_warning}
				set knot(warning) ""
				.unknot.0w.w config -readonlybackground [option get . background {}]
				catch {unset knot_cnt}
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "$CDPidrun : failed to run $knottype process\n$cmd"
					UnBlock
					continue
   				} else {
					if {$mode == $evv(KNOTCNT)} {
 						fileevent $CDPidrun readable "Knotcnt_Info"
					} else {
 						fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsAndWarningsDisplayed"
					}
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				if {[info exists knotcnt_warning]} {
					set knot(warning) "     $knotcnt_warning"
					.unknot.0w.w config -readonlybackground white
					unset knotcnt_warning
				}
				if {!$prg_dun} {
					Inf "$CDPidrun : $knottype process failed\n$cmd"
					UnBlock
					continue
				}
				if {$mode == $evv(KNOTCNT)} {
					set OK 1
					if {![info exists knotcnt_line]} {
						Inf "$CDPidrun : Failed to count knots"
						set OK 0
					} else {
						set line [string trim $knotcnt_line]
						if {[string length $line] <= 0} {
							set OK 0
						} else {
							set line [split $line]
							set cnt 0
							foreach item $line {
								set item [string trim $item]
								if {[string length $item] > 0} {
									if {$cnt == 1} {
										if {![IsNumeric $item] || ![regexp {^[0-9]+$} $item]} {
											set OK 0
										}
										break
									}
									incr cnt
								}
							}
							if {$cnt != 1} {
								set OK 0
							}
						}
					}
					if {!$OK} {
						Inf "Failed to get knotcount information"
					} else {
						Inf "[string range $knotcnt_line 6 end]"
					}
				} elseif {![file exists $ofnam]} {
					Inf "$CDPidrun : Failed to do $knottype\n$cmd"
					set OK 0
				}
				UnBlock
				if {!$OK} {
					continue
				}
				if {$mode != $evv(KNOTCNT)} {
					if {[FileToWkspace $ofnam 0 0 0 0 1] > 0} {
						Inf "File $ofnam is on the workspace"
					} else {
						Inf "File $ofnam has been created"
					}
					lappend TILPlist $ofnam
				}
			}
			0 {
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc UnknotHelp {} {
	set msg "UNKNOT\n"
	append msg "\n"
	append msg "Takes a set of rhythm-patterns, already positioned in (up to)8-channel space,\n"
	append msg "and gradually reduces the rhythm to a steady-pulse stream\n"
	append msg "over a simple spatial trajectory.\n"
	append msg "\n"
	append msg "Initially..\n"
	append msg "(1) Each pattern can be output separately.\n"
	append msg "(2) Each (specified) combination of patterns can (then) be output.\n"
	append msg "(3) The combination of all the patterns can (then) be output.\n"
	append msg "\n"
	append msg "A number of repetitions can be specified for each of these.\n"
	append msg "\n"
	append msg "Pattern combinations to use can also be specified.\n"
	append msg "\n"
	append msg "The combined pattern is then rhythmically modified (unknotted).\n"
	append msg "(and each step of the unknotting can be repeated).\n"
	append msg "\n"
	append msg "The unknotted pattern can then also be repeated.\n"
	append msg "\n"
	append msg "The spatial smoothing of the pattern can begin\n"
	append msg "(a) as the unknotting begins.\n"
	append msg "(b) as the unknotting ends.\n"
	append msg "\n"
	append msg "The final spatial patterning can be specified\n"
	append msg "(and any specific channels involved, where this is necessary).\n"
	append msg "\n"
	append msg "The output can later be converted to a mixfile, to generate sound.\n"
	append msg "\n"
	append msg "KNOT\n"
	append msg "\n"
	append msg "Selecting the \"Knot\" option, the process is reversed.\n"
	append msg "Options (2) and (1) now taking place at the end of the output.\n"
	append msg "\n"
	Inf $msg
}

#------ Reconfigure Channels display for output spatial types

proc KnotChansShow {typ} {
	global knot
	set n 1
	if {$typ <= 3} {
		set knot(spactyp) 0
		.unknot.11.ll config -text ""
		while {$n <= 8} {
			if {$typ >= 0} {
				set knot(lastrspchan$n) $knot(rspchan$n)
			}
			set knot(rspchan$n) 0
			.unknot.12.$n  config -text "" -state disabled
			incr n
		}
		if {$typ > 0} {
			set msg "CREATE MONO REDUCTION OF OUTPUT"
			if {$typ == 2} {
				append msg ", DUPLICATE TO ALL CHANNELS,"
			} elseif {$typ == 3} {
				append msg ", DUPLICATE TO APPROPRIATE CHANNELS,"
			}
			append msg " THEN CROSSFADE"
			Inf $msg
		}
	} else {
		set knot(spactyp) [expr $typ - 3]
		.unknot.11.ll config -text "OVER CHANNELS...."
		while {$n <= 8} {
			.unknot.12.$n  config -text "$n" -state normal
			if {[info exists knot(lastrspchan$n)]} {
				set knot(rspchan$n) $knot(lastrspchan$n)
				unset knot(lastrspchan$n)
			}
			incr n
		}
	}
}

#------- Get channels (and check "spatial redistribution start") for spatialisation

proc KnotSpacetypeGet {} {
	global knot
	set n 1
	set typ $knot(respace)
	if {$typ > 3} {
		if {$knot(respacestt) == 0} {
			Inf "Where does spatial redistribution begin?"
			return 0
		} else {
			set knot(spactyp) [expr $typ - 3]
		}
	}
	return 1
}

#--- Get a file listing pattern-groupings

proc FindPatternGroupingsFiles {} {
	global evv knot pr_knotgroupings knot_i readonlyfg readonlybg
	if {![LoadAppropriatePatternGroupingsFiles]} {
		Inf "No appropriate files on workspace"
		return
	}
	set f .knotgroupings
	if [Dlg_Create $f "POSSIBLE KNOT GROUPINGS FILES" "set pr_knotgroupings 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.save -text "Select" -command "set pr_knotgroupings 1" -bg $evv(EMPH)
		button $f.0.quit -text "Abandon" -command "set pr_knotgroupings 0"
		pack $f.0.save -side left -padx 4
		pack $f.0.quit -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Selected File"
		entry $f.1.e -textvariable knot_i -width 48 -fg $readonlyfg -readonlybackground $readonlybg -state readonly
		set knot_i ""
		pack $f.1.ll $f.1.e -side left -padx 2
		pack $f.1 -side top -fill x -expand true
		frame $f.2
		label $f.2.ll -text "Select file with mouse-click" -fg $evv(SPECIAL)
		Scrolled_Listbox $f.2.pp -width 64 -height 24 -selectmode single
		pack $f.2.ll $f.2.pp -side top -pady 2
		pack $f.2 -side top
		wm resizable $f 0 0
		bind .knotgroupings.2.pp.list <ButtonRelease> {GetKnotGroupingFile %y}
		bind $f <Escape> {set pr_knotgroupings 0}
		bind $f <Return> {set pr_knotgroupings 1}
	}
	.knotgroupings.2.pp.list delete 0 end
	foreach fnam $knot(groupingfiles) {
		.knotgroupings.2.pp.list insert end $fnam
	}
	if {[llength $knot(groupingfiles)] == 1} {
		set knot_i [lindex $knot(groupingfiles) 0]
	}
	set pr_knotgroupings 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_knotgroupings
	while {!$finished} {
		tkwait variable pr_knotgroupings
		if {$pr_knotgroupings} {
			if {[string length $knot_i] <= 0} {
				Inf "No file selected"
				continue
			}
			set knot(groupings) $knot_i
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Search workspace for pattern-grouping files appropriate to current list of patterns-to-knot

proc LoadAppropriatePatternGroupingsFiles {} {
	global wl pa evv knot chlist
	foreach fnam [$wl get 0 end] {
		set ftyp $pa($fnam,$evv(FTYP))
		if {[IsAListofNumbers $ftyp]} {
			if {($pa($fnam,$evv(MINNUM)) >= 1) && ($pa($fnam,$evv(MAXNUM)) <= [llength $chlist])} {
				lappend templist $fnam
			}
		}
	}
	if {![info exists templist]} {
		return 0
	}
	foreach fnam $templist {
		set OKfile 1
		if {[KnotPatternGroupingFileTest $fnam]} {
			lappend outlist $fnam
		}
	}
	if {![info exists outlist]} {
		return 0
	}
	set knot(groupingfiles) $outlist
	return 1
}

proc GetKnotGroupingFile {y} {
	global knot_i
	set i [.knotgroupings.2.pp.list nearest $y]
	if {$i >= 0} {
		set knot_i [.knotgroupings.2.pp.list get $i]
	}
}

proc KnotUnknot {} {
	global knot
	if {$knot(knk)} {
		.unknot.0.doit config -text "Knot"
		.unknot.0a.knk config -text "Unknot"
		.unknot.1.ll config -text "Each separate pattern, at end"
		.unknot.2.ll config -text "Each pattern-grouping, before end"
		.unknot.3.ll config -text "Unknotted pattern"
		.unknot.4.ll config -text "Each knotting step"
		.unknot.5.ll config -text "Knotted pattern"

		.unknot.9.1.1 config -text "knotting start"
		.unknot.9.1.2 config -text "knotting end"
		wm title .unknot "KNOT RHYTHM PATTERNS"
	} else {
		.unknot.0.doit config -text "Unknot"
		.unknot.0a.knk config -text "Knot"
		.unknot.1.ll config -text "Each separate pattern, at start"
		.unknot.2.ll config -text "Each pattern-grouping, after start"
		.unknot.3.ll config -text "All patterns combined"
		.unknot.4.ll config -text "Each unknotting step"
		.unknot.5.ll config -text "Unknotted pattern"

		.unknot.9.1.1 config -text "unknotting start"
		.unknot.9.1.2 config -text "unknotting end"
		wm title .unknot "UNKNOT RHYTHM PATTERNS"
	}
}

proc KnotChanCheck {k} {
	global knot
	set n 1
	set cnt 0
	while {$n <= 8} {
		if {$n != $k} {
			if {$knot(rspchan$n)} {
				incr cnt
			}
			if {$cnt > 1} {
				set knot(rspchan$n) 0
				break
			}
		}
		incr n
	}
}

#--- Test textfile to see if it represnets pattern groupings (each line >1 entry, no duplicate entries on line, no. of entries on line <= patterncnt)

proc KnotPatternGroupingFileTest {fnam} {

	if [catch {open $fnam "r"} zit] {
		return 0
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		set cnt 0
		set OK 1
		catch {unset nuline}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {![regexp {^[0-9]+$} $item] || ![IsNumeric $item]} {
				set OK 0
				break
			}
			lappend nuline $item
			incr cnt
		}
		if {!$OK} {
			break
		}
		if {$cnt < 2} {
			set OK 0
			break
		}
		set len [llength $nuline]
		set len_less_one [expr $len - 1]
		set n 0
		set OK 1
		while {$n < $len_less_one} {
			set m $n
			incr m
			while {$m < $len} {
				if {[lindex $nuline $n] == [lindex $nuline $m]} {
					set OK 0
					break
				}
				incr m
			}
			if {!$OK} {
				break
			}
			incr n
		}
		if {!$OK} {
			break
		}
	}
	if {!$OK} {
		return 0
	}
	return 1
}

#------ Get knotcount from program

proc Knotcnt_Info {} {
	global CDPidrun prg_dun knotcnt_line knotcnt_warning

	if {[info exists CDPidrun] && [eof $CDPidrun]} {
		catch {close $CDPidrun}
		set prg_dun 1
		return
	} else {
		gets $CDPidrun line
		set line [string trim $line]
		if {[string length $line] <= 0} {
			return
		} elseif [string match WARNING:* $line] {
			set knotcnt_warning $line
			return
		} elseif [string match INFO:* $line] {
			set knotcnt_line $line
			set prg_dun 1
			return
		}
	}
	update idletasks
}			

proc SaveKnotPatch {mode} {
	global knot evv knotsavenam pr_knotsave
	set fnam [file join $evv(URES_DIR) unknot$evv(CDP_EXT)]
	set thispatch $mode
	lappend thispatch $knot(reps) $knot(groupingreps) $knot(allreps) $knot(unksteprep) $knot(unkreps) $knot(groupings) $knot(mindev) $knot(clip) $knot(spactyp) $knot(respacestt)
	if {$knot(spactyp) > 0} {
		foreach item $knot(chanlims) {
			lappend thispatch $item
		}
	}
	set f .knotsave
	if [Dlg_Create $f "SAVE (UN)KNOT PATCH" "set pr_knotsave 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.save -text "Save" -command "set pr_knotsave 1" -bg $evv(EMPH)
		button $f.0.quit -text "Abandon" -command "set pr_knotsave 0"
		pack $f.0.save -side left -padx 4
		pack $f.0.quit -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Patch Name"
		entry $f.1.e -textvariable knotsavenam -width 24
		pack $f.1.ll $f.1.e -side left -padx 2
		pack $f.1 -side top -fill x -expand true
		frame $f.2
		label $f.2.ll -text "Existing patches" -fg $evv(SPECIAL)
		Scrolled_Listbox $f.2.pp -width 64 -height 24 -selectmode single
		pack $f.2.ll $f.2.pp -side top -pady 2
		pack $f.2 -side top
		wm resizable $f 0 0
		bind $f <Escape> {set pr_knotsave 0}
		bind $f <Return> {set pr_knotsave 1}
	}
	.knotsave.2.pp.list delete 0 end
	if {[info exists knot(patches)]} {
		foreach patch $knot(patches) {
			set pnam [lindex $patch 0]
			.knotsave.2.pp.list insert end $pnam
		}
	}
	set pr_knotsave 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_knotsave $f.1.e
	while {!$finished} {
		tkwait variable pr_knotsave
		if {$pr_knotsave} {
			if {![ValidCDPRootname $knotsavenam]} {
				continue
			}
			set patchnam [string tolower $knotsavenam] 
			set OK 1
			if {[info exists knot(patches)]} {
				foreach pnam [.knotsave.2.pp.list get 0 end] {
					if {[string match $pnam $patchnam]} {
						Inf "Patch name already used: please choose a different patch name"
						set OK 0
						break
					}
				}
				if {!$OK} {
					continue
				}
			}
			set outpatch [concat $patchnam $thispatch]
			lappend knot(patches) $outpatch
			.knotsave.2.pp.list insert end $patchnam
			if {[file exists $fnam]} {
				if [catch {open $fnam "a"} zit] {
					Inf "Cannot open file $fnam to save patch data"
					set OK 0
				}
			} else {
				if [catch {open $fnam "w"} zit] {
					Inf "Cannot open file $fnam to save patch data"
					set OK 0
				}
			}
			if {$OK} {
				puts $zit $outpatch
				close $zit
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Get or Delete an existing patch

proc GetKnotPatch {del} {
	global knot evv knotgetnam pr_knotget readonlybg readonlyfg wstk
	set fnam [file join $evv(URES_DIR) unknot$evv(CDP_EXT)]
	set f .knotget
	if [Dlg_Create $f "GET (UN)KNOT PATCH" "set pr_knotget 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.save -text "Get Patch" -command "set pr_knotget 1" -bg $evv(EMPH) -width 12
		button $f.0.quit -text "Quit" -command "set pr_knotget 0"
		pack $f.0.save -side left -padx 4
		pack $f.0.quit -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Patch Name"
		entry $f.1.e -textvariable knotgetnam -width 24 -readonlybackground $readonlybg -fg $readonlyfg -state readonly
		pack $f.1.ll $f.1.e -side left -padx 2
		pack $f.1 -side top -fill x -expand true
		frame $f.2
		label $f.2.ll -text "Select patch with mouse-click" -fg $evv(SPECIAL)
		Scrolled_Listbox $f.2.pp -width 64 -height 24 -selectmode single
		pack $f.2.ll $f.2.pp -side top -pady 2
		pack $f.2 -side top
		wm resizable $f 0 0
		bind .knotget.2.pp.list <ButtonRelease> {GetUnknotPatch %y} 
		bind $f <Escape> {set pr_knotget 0}
		bind $f <Return> {set pr_knotget 1}
	}
	if {$del} {
		wm title .knotget "DELETE UNKNOTTING PATCH"
		$f.0.save config -text "Delete Patch"
	} else {
		wm title .knotget "GET UNKNOTTING PATCH"
		$f.0.save config -text "Get Patch"
	}	
	.knotget.2.pp.list delete 0 end
	if {[info exists knot(patches)]} {
		foreach patch $knot(patches) {
			set pnam [lindex $patch 0]
			.knotget.2.pp.list insert end $pnam
		}
	}
	set pr_knotget 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_knotget
	while {!$finished} {
		tkwait variable pr_knotget
		if {$pr_knotget} {
			if {[string length $knotgetnam] <= 0} {
				Inf "No patch selected"
				continue
			}
			set n 0
			foreach patch $knot(patches) {
				if {[string match $knotgetnam [lindex $patch 0]]} {
					set thispatch $patch
					break
				}
				incr n
			}
			if {![info exists thispatch]} {
				Inf "Problem!!"
				continue
			}
			if {$del} {
				set msg "Are you sre you want to ~~delete~~ patch $knotgetnam ???"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				set knot(patches) [lreplace $knot(patches) $n $n]
				.knotget.2.pp.list delete $n
				if [file exists $fnam] {
					if {[llength $knot(patches)] <= 0} {
						catch {file delete $fnam}
						unset knot(patches)
					} elseif [catch {open $fnam "w"} zit] {
						Inf "Cannot open file $fnam to update patch info"
					} else {
						foreach patch $knot(patches) {
							puts $zit $patch
						}
						close $zit
					}
				}
				continue
			} else {
				set mode [lindex $thispatch 1]
				if {$mode == $evv(DO_KNOT)} {
					set knot(knk) 1
				} else {
					set knot(knk) 0
				}
				KnotUnknot
				set thispatch [lrange $thispatch 2 end]
				set knot(reps)			[lindex $thispatch 0]
				set knot(groupingreps)	[lindex $thispatch 1]
				set knot(allreps)		[lindex $thispatch 2]
				set knot(unksteprep)	[lindex $thispatch 3]
				set knot(unkreps)		[lindex $thispatch 4]
				set knot(groupings)		[lindex $thispatch 5]
				set knot(mindev)		[lindex $thispatch 6]
				set knot(clip)			[lindex $thispatch 7]
				set knot(spactyp)		[lindex $thispatch 8]
				if {$knot(spactyp) > 0} {
					set knot(respace) [expr $knot(spactyp) + 3]
					KnotChansReShow 0
					set knot(respacestt) [lindex $thispatch 9]
					set chana			 [lindex $thispatch 10]	
					set chanb			 [lindex $thispatch 11]
					set n 1
					while {$n <= 8} {
						if {($n == $chana) || ($n == $chanb)} {
							set knot(rspchan$n) 1
						} else {
							set knot(rspchan$n) 0
						}
						incr n
					}
				} else {
					KnotChansReShow 1
					set knot(respacestt) 0
					set n 1
					while {$n <= 8} {
						set knot(rspchan$n) 0
						incr n
					}
				}
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc GetUnknotPatch {y} {
	global knotgetnam
	set i [.knotget.2.pp.list nearest $y]
	if {$i >= 0} {
		set knotgetnam [.knotget.2.pp.list get $i]
	}
}

proc LoadUnknotPatches {} {
	global evv knot
	set fnam [file join $evv(URES_DIR) unknot$evv(CDP_EXT)]
	if {![file exists $fnam]} {
		return
	}
	if [catch {open $fnam "r"} zit] {
		return
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		lappend knot(patches) $line
	}
	close $zit
}

#------ Reconfigure Channels display for output spatial types

proc KnotChansReShow {off} {
	global knot
	set n 1
	if {$off} {
		while {$n <= 8} {
			.unknot.12.$n  config -text "" -state disabled
			set knot(rspchan$n) ""
			incr n
		}
	} else {
		while {$n <= 8} {
			.unknot.12.$n  config -text "$n" -state normal
			incr n
		}
	}
}

#---- Divide a TILP pattern into two, equal duration patterns.

proc RhythmSplit {} {
	global chlist evv pa wl wstk pr_rhysplit rhysplit_fnam
	if {![info exists chlist] || ([llength $chlist] != 1)} {
		Inf "Select	one \"tilp\" rhythmic pattern file"
		return
	}
	set fnam [lindex $chlist 0]
	if {![IsATILPFile $fnam 1]} {
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot open file $fnam"
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		lappend lines $line
	}
	close $zit
	set f .rhysplit
	if [Dlg_Create $f "SPLIT RHYTHMIC PATTERN" "set pr_rhysplit 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.save -text "Do Split" -command "set pr_rhysplit 1" -bg $evv(EMPH)
		button $f.0.quit -text "Abandon" -command "set pr_rhysplit 0"
		pack $f.0.save -side left -padx 2
		pack $f.0.quit -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Generic Output Name"
		entry $f.1.e -textvariable rhysplit_fnam -width 24
		pack $f.1.ll $f.1.e -side left -padx 2
		pack $f.1 -side top -fill x -expand true
		frame $f.2
		label $f.2.ll -text "Pattern" -fg $evv(SPECIAL)
		label $f.2.ll2 -text "Select lines to separate out (but not last line)." -fg $evv(SPECIAL)
		Scrolled_Listbox $f.2.pp -width 64 -height 24 -selectmode extended
		pack $f.2.ll $f.2.ll2 $f.2.pp -side top -pady 2
		pack $f.2 -side top
		wm resizable $f 0 0
		bind $f <Escape> {set pr_rhysplit 0}
		bind $f <Return> {set pr_rhysplit 1}
	}
	.rhysplit.2.ll config -text "Pattern [file rootname [file tail $fnam]]"
	.rhysplit.2.pp.list delete 0 end
	set linecnt 0
	foreach line $lines {
		.rhysplit.2.pp.list insert end $line
		incr linecnt
	}
	set maxline [expr $linecnt -1]
	set pr_rhysplit 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_rhysplit $f.1.e
	while {!$finished} {
		tkwait variable pr_rhysplit
		if {$pr_rhysplit} {
			set ilist [.rhysplit.2.pp.list curselection]
			if {![info exists ilist] || ([llength $ilist] < 1)} {
				Inf "No lines selected to separate out"
				continue
			}
			set firstlineselected 0
			set len [llength $ilist]
			if {$len == $linecnt} {
				Inf "Too many lines selected"
				continue
			}
			set n 0
			set OK 1
			while {$n < $len} {
				set i [lindex $ilist $n]
				if {$i == 0} {
					set firstlineselected 1
				}
				if {$i == $maxline} {
					set ilist [lreplace $ilist $n $n]
					if {[llength $ilist] <= 0} {
						Inf "No valid lines selected"
						set OK 0
						break
					}
				}
				incr n
			}
			if {!$OK} {
				continue
			}
			if {![ValidCDPRootname $rhysplit_fnam]} {
				continue
			}
			set ofnambas [string tolower $rhysplit_fnam]
			set ofnam1 $ofnambas
			append ofnam1 "1" $evv(TEXT_EXT)
			set ofnam2 $ofnambas
			append ofnam2 "2" $evv(TEXT_EXT)
			if {[file exists $ofnam1] || [file exists $ofnam2] } {
				set msg "File $ofnam1 or $ofnam2 already exists: overwrite existing files ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				if {([file exists $ofnam1] && ![CouetteAllowsDelete $ofnam1]) || ([file exists $ofnam2] && ![CouetteAllowsDelete $ofnam2])} {
					continue
				}
				if {[file exists $ofnam1] && [catch {file delete -force $ofnam1} in]} {
					Inf "Cannot delete the existing file $ofnam1"
					continue
				} elseif {[file exists $ofnam2] && [catch {file delete -force $ofnam2} in]} {
					Inf "Cannot delete the existing file $ofnam2"
					continue
				} else {
					if [file exists $ofnam1] {
						DataManage delete $ofnam1
						CouettePatchesDelete $ofnam1
						DeleteFileFromSrcLists $ofnam1
						set ftyp $pa($ofnam1,$evv(FTYP))
						RemoveFromChosenlist $ofnam1
						PurgeArray $ofnam1
						DummyHistory $ofnam1 "OVERWRITTEN"
						set i [LstIndx $ofnam1 $wl]
						if {$i >= 0} {
							$wl delete $i
						}
					}
					if [file exists $ofnam2] {
						DataManage delete $ofnam2
						CouettePatchesDelete $ofnam2
						DeleteFileFromSrcLists $ofnam2
						set ftyp $pa($ofnam2,$evv(FTYP))
						RemoveFromChosenlist $ofnam2
						PurgeArray $ofnam2
						DummyHistory $ofnam2 "OVERWRITTEN"
						set i [LstIndx $ofnam2 $wl]
						if {$i >= 0} {
							$wl delete $i
						}
					}
				}
			}
			set firstline [list [list 0.0 0 0 1]]				;#	A silent line at time zero, start marker
			set iszerotime 0
			catch {unset pat1}
			catch {unset pat2}
			if {$firstlineselected} {
				foreach i $ilist {								;#	For pattern 1	
					lappend pat1 [.rhysplit.2.pp.list get $i]	;#	Get all selected lines, including first
				}
				lappend pat1 [.rhysplit.2.pp.list get end]		;#	Add end (marker) line

				set i 0											;#	For pattern 2										
				foreach line [.rhysplit.2.pp.list get 0 end] {	;#	Get all unselected lines
					if {([lsearch $ilist $i] < 0) && ($i != $maxline)} {	;#	EXCEPT the last line
						set time [lindex [split $line] 0]
						if {$time == 0.0} {
							set iszerotime 1
						}
						lappend pat2 $line
					}
					incr i
				}
				lappend pat2 [.rhysplit.2.pp.list get end]		;#	Add end (marker) line
				if {!$iszerotime} {								;#	If there is no line at time zero
					set pat2 [concat $firstline $pat2]			;#	Force a silent line at time zero
				}
			} else {											;#	For pattern 1
				foreach i $ilist {	
					set line [.rhysplit.2.pp.list get $i]		;#	Get all selected lines (not including first)
					set time [lindex [split $line] 0]
					if {$time == 0.0} {
						set iszerotime 1
					}
					lappend pat1 $line
				}
				lappend pat1 [.rhysplit.2.pp.list get end]		;#	Add end (marker) line
				if {!$iszerotime} {								;#	If there is no line at time zero
					set pat1 [concat $firstline $pat1]			;#	Force a silent line at time zero
				}
				
				set i 0											;#	For pattern 2										
				foreach line [.rhysplit.2.pp.list get 0 end] {	;#	Get all unselected lines, including first
					if {([lsearch $ilist $i] < 0) && ($i != $maxline)} {	;#	but NOT the last
						lappend pat2 $line
					}
					incr i
				}
				lappend pat2 [.rhysplit.2.pp.list get end]		;#	Add end (marker) line

			}
			if [catch {open $ofnam1 "w"} zit1] {
				Inf "Cannot open file $ofnam1 to write 1st new split pattern"
				continue
			}
			if [catch {open $ofnam2 "w"} zit2] {
				Inf "Cannot open file $ofnam2 to write 2nd new split pattern"
				catch {close $zit1}
				continue
			}
			foreach line $pat1 {
				puts $zit1 $line
			}
			close $zit1
			foreach line $pat2 {
				puts $zit2 $line
			}
			close $zit2
			FileToWkspace $ofnam1 0 0 0 0 1
			FileToWkspace $ofnam2 0 0 0 0 1
			Inf "Files $ofnam1 and $ofnam2 are on the workspace"
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#------ Display info returned by running-unknot

proc HandleProcessOutputWithOnlyErrorsAndWarningsDisplayed {} {
	global CDPidrun prg_dun prg_abortd simple_program_messages knotcnt_warning

	if [eof $CDPidrun] {
		set prg_dun 1
		catch {close $CDPidrun}
		return
	} else {
		gets $CDPidrun line
		set line [string trim $line]
		if [string match ERROR:* $line] {
			lappend simple_program_messages $line
			set prg_abortd 1
			return
		} elseif [string match WARNING:* $line] {
			set knotcnt_warning $line
			return
		} elseif [string match ERROR:* $line] {
			set knotcnt_warning $line
			return
		} elseif [string match END:* $line] {
			set prg_dun 1
			return
		}
	}
	update idletasks
}

#################
# RHYTHM MORPHS #
#################

#---- Test a list of pattern files on chosen files list, and return total list of patterns

proc TestPatternFiles {} {
	global chlist pa evv
	set linesets {}
	foreach ifnam $chlist {
		catch {unset lines}
		set ftyp $pa($ifnam,$evv(FTYP))
		if {![IsAListofNumbers $ftyp]} {
				Inf "File $ifnam does not have the correct \"time  index  level position\" format"
				return
		}
		if [catch {open $ifnam "r"} zit] {
			Inf "Cannot open file $ifnam"
			return
		}
		set linecnt 0
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			if {[string match [string index $line 0] ";"]} {
				continue
			}
			incr linecnt
			catch {unset nuline}
			set line [split $line]
			set cnt 0
			set OK 1
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				switch -- $cnt {
					0 {
						if {$linecnt == 1} {
							if {$item != 0.0} {
								Inf "Initial time in input data file $ifnam must be zero"
								set OK 0
								break
							}
						} elseif {$item < $lasttime} {
							Inf "Times ($lasttime $item) in input data file $ifnam do not increase at line $linecnt"
							set OK 0
							break
						}
						set lasttime $item	
					}
					1 {
						if {![regexp {^[0-9]+$} $item] || ![IsNumeric $item]} {
							Inf "Invalid sound-index value on line $linecnt of file $ifnam"
							set OK 0
							break
						}
					}
					2 {
						if {($item < 0.0) || ($item > 1.0)} {
							Inf "Invalid level value on line $linecnt of file $ifnam"
							set OK 0
							break
						}
					}
					3 {
						if {($item < 0.0) || ($item > 8.0)} {
							Inf "Invalid position value on line $linecnt of file $ifnam"
							set OK 0
							break
						}
					}
				}					
				lappend nuline $item
				incr cnt
			}
			if {!$OK} {
				break
			}
			if {$cnt != 4} {
				Inf "Wrong number of values ($cnt) on line ($linecnt) of file $ifnam: requires 4 values"
				set OK 0
				break
			}
			lappend lines $nuline
		}
		close $zit
		if {!$OK} {
			break
		}
		lappend linesets $lines
	}
	if {!$OK} {
		set linesets {}
	}
	return $linesets
}

#----- Randmise a rhythm pattern

proc RhythmPatternRand {} {
	global chlist rhrand rhrando pr_rhrand rhrandfnam mix_perm rhrandx rhrande evv wstk wl pa
	if {![info exists chlist] || ([llength $chlist] != 1)} {
		Inf "One textfile needed on chosen file list with line-format \"time index level position\""
		return
	}
	set linesets [TestPatternFiles]
	if {[llength $linesets] != 1} {
		return
	}
	set inlines [lindex $linesets 0]
	set linecnt [llength $inlines]
	set n 0
	set f .rhrand
	if [Dlg_Create $f "RANDOMISE RHYTHM" "set pr_rhrand 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.save -text "Randomise" -command "set pr_rhrand 1" -bg $evv(EMPH) -width 12
		button $f.0.quit -text "Quit" -command "set pr_rhrand 0"
		pack $f.0.save -side left -padx 4
		pack $f.0.quit -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "New Patch Name"
		entry $f.1.e -textvariable rhrandfnam -width 24
		pack $f.1.ll $f.1.e -side left -padx 2
		pack $f.1 -side top -fill x -expand true
		frame $f.2
		label $f.2.ll -text "PATTERN REORDER ..." -fg $evv(SPECIAL)
		pack $f.2.ll -side left
		pack $f.2 -side top -fill x -expand true -anchor w
		frame $f.3
		radiobutton $f.3.1 -variable rhrand -text "instruments only"		  -value 1 -command "PatRandSet 1"
		radiobutton $f.3.2 -variable rhrand -text "levels only"				  -value 2 -command "PatRandSet 2"
		radiobutton $f.3.3 -variable rhrand -text "position only"			  -value 3 -command "PatRandSet 3"
		radiobutton $f.3.4 -variable rhrand -text "instruments with level"	  -value 4 -command "PatRandSet 4"
		radiobutton $f.3.5 -variable rhrand -text "instruments with position" -value 5 -command "PatRandSet 5"
		radiobutton $f.3.6 -variable rhrand -text "instruments with level and position"	-value 6 -command "PatRandSet 6"
		radiobutton $f.3.7 -variable rhrand -text "level and position only"	  -value 7 -command "PatRandSet 7"
		pack $f.3.1 $f.3.2 $f.3.3 $f.3.4 $f.3.5 $f.3.6 $f.3.7 -side top -anchor w
		pack $f.3 -side top -fill x -expand true
		frame $f.4
		label $f.4.ll -text "CONSTRAINTS ..." -fg $evv(SPECIAL)
		pack $f.4.ll -side left
		pack $f.4 -side top -fill x -expand true -anchor w
		frame $f.5
		checkbutton $f.5.ch1 -variable rhrandx -text "Don't permute first item in pattern"
		checkbutton $f.5.ch2 -variable rhrande -text "Don't permute last item in pattern"
		pack $f.5.ch1 $f.5.ch2 -side top -anchor w 
		pack $f.5 -side top -fill x -expand true
		set rhrand 0
		set rhrandx 1
		set rhrande 1
		wm resizable $f 0 0
		bind $f <Escape> {set pr_rhrand 0}
		bind $f <Return> {set pr_rhrand 1}
	}
	set pr_rhrand 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_rhrand
	while {!$finished} {
		tkwait variable pr_rhrand
		if {$pr_rhrand} {
			if {![ValidCDPRootname $rhrandfnam]} {
				continue
			}
			set ofnam [string tolower $rhrandfnam]
			append ofnam $evv(TEXT_EXT)
			if {[file exists $ofnam]} {
				set msg "File $ofnam exists: overwrite existing file ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				if {![CouetteAllowsDelete $ofnam]} {
					continue
				}
				if [catch {file delete -force $ofnam} in] {
					Inf "Cannot delete the existing file."
					continue
				} else {											;# Copy only takes place from Dirlist to Wkspace.
					DataManage delete $ofnam
					CouettePatchesDelete $ofnam
					DeleteFileFromSrcLists $ofnam					;# File created is a wkspace file.
					set ftyp $pa($ofnam,$evv(FTYP))
					RemoveFromChosenlist $ofnam
					PurgeArray $ofnam
					DummyHistory $ofnam "OVERWRITTEN"
					set i [LstIndx $ofnam $wl]
					if {$i >= 0} {
						$wl delete $i
					}
				}
			}
			if {$rhrand == 0} {
				Inf "No reordering type chosen"
				continue
			}
			if {$rhrandx} {
				set firstline [lindex $inlines 0]
				set inlines [lrange $inlines 1 end]
				incr linecnt -1
			}
			if {$rhrande} {
				set lastline [lindex $inlines end]
				set k $linecnt
				incr k -2
				set inlines [lrange $inlines 0 $k] 
				incr linecnt -1
			}
			RandomiseOrder $linecnt
			if {$rhrandx} {
				incr linecnt
				set m [expr $linecnt - 1]
				set n $m
				incr n -1
				while {$n >= 0} {
					set mix_perm($m) [expr $mix_perm($n) + 1]
					incr m -1
					incr n -1
				}
				set mix_perm(0) 0
				set inlines [concat $firstline $inlines]
			}
			if {$rhrande} {
				set mix_perm($linecnt) $linecnt
				set inlines [concat $inlines $lastline]
				incr linecnt
			}
			catch {unset oldpat}
			foreach line $inlines {
				foreach item $line {
					lappend oldpat $item
				}
			}
			set n 0
			while {$n < $linecnt} {
				set m $mix_perm($n)
				set k_orig [expr $n * 4]	;#	point to original 4-value set
				set k_perm [expr $m * 4]	;#	point to 4-value set at permutation position
				set cnt 0
				while {$cnt < 4} {			;#	4 the set of 4 values
					if {[lsearch $rhrando $cnt] >= 0} {
						lappend newpat [lindex $oldpat $k_perm]	;#	Put permuted item into new pattern
					} else {
						lappend newpat [lindex $oldpat $k_orig]	;#	Put original (non-permuted) item into new pattern
					}
					incr k_orig
					incr k_perm
					incr cnt
				}
				incr n
			}
			if [catch {open $ofnam "w"} zit] {
				Inf "Cannot open file $ofnam to write new data"
				continue
			}
			foreach {time midi level pos} $newpat {
				set line [list $time $midi $level $pos]
				puts $zit $line
			}
			close $zit
			FileToWkspace $ofnam 0 0 0 0 1
			Inf "File $ofnam is on the workspace"
			set finished 1
		} else {
			set finished 1
		}			
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- setup pattern randomisation type

proc PatRandSet {typ} {
	global rhrando
	switch -- $typ {
		1 {	set rhrando [list 1] }
		2 { set rhrando [list 2] }
		3 { set rhrando [list 3] }
		4 { set rhrando [list 1 2] }
		5 { set rhrando [list 1 3] }
		6 { set rhrando [list 1 2 3] }
		7 { set rhrando [list 2 3] }
	}
}

#---- Check textfile has "Number Sndfile" format, assigning sounds to sound-indeces

proc IsASndIndexingFile {fnam} {
	global pa evv wl maxsamp_line done_maxsamp CDPmaxId

	set ftyp $pa($fnam,$evv(FTYP))
	if {!($ftyp & $evv(IS_A_TEXTFILE)) || [IsAListofNumbers $ftyp] || [IsASndlist $ftyp]} {
		Inf "$fnam is not a valid sound-assignment file"
		return {}
	}
	if {[expr $pa($fnam,$evv(LINECNT)) * 2] != $pa($fnam,$evv(ALL_WORDS))} {
		Inf "$fnam is not a valid sound-assignment file "
		return {}
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot open file $fnam"
		return {}
	}
	set OK 1
	set linecnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		incr linecnt
		set line [split $line]
		set cnt 0
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			switch -- $cnt {
				0 {
					if {![regexp {^[0-9]+$} $item] || ![IsNumeric $item]} {
						Inf "Non-integer entry for first item in line $linecnt"
						set OK 0
						break
					}
					if {($linecnt == 1) && ($item != 0)} {
						Inf "First snd must have index zero, and be a silent file"
						set OK 0
						break
					}
					lappend sndindex $item
				} 
				1 {
					if {![file exists $item]} {
						Inf "Entry 2 ($item) on line $linecnt is not an existing soundfile"
						set OK 0
						break
					}
					set ftyp [FindFileType $item]
					if {$ftyp != $evv(SNDFILE)} {
						Inf "2nd entry ($item) on line $linecnt is not a soundfile"
						set OK 0
						break
					}
					if {[LstIndx $item $wl] < 0} {
						if {[FileToWkspace $item 0 0 0 1 0] <= 0} {
							set OK 0
							break
						}
					}
					if {$pa($item,$evv(CHANS)) != 1} {
						Inf "File $item on line $linecnt is not a mono soundfile"
						set OK 0
						break
					}
					if {$linecnt == 1} {
						set srate $pa($item,$evv(SRATE))
						catch {unset maxsamp_line}
						set done_maxsamp 0
						set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
						lappend cmd $item
						lappend cmd 1		;#	1 flag added to FORCE read of maxsample
						if [catch {open "|$cmd"} CDPmaxId] {
							ErrShow "$CDPmaxId"
							continue
						} else {
	   						fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
						}
						vwait done_maxsamp
						if {[info exists maxsamp_line]} {
							if {[lindex $maxsamp_line 0] > 0.0} {
								Inf "First sound in list must be a silent file"
								set OK 0
								break
							}
						} else {
							Inf "Cannot get max sample information for first sound in list"
							set OK 0
							break
						}

					} elseif {$srate != $pa($item,$evv(SRATE))} {
						Inf "Soundfile ($item) on line $linecnt has different sample rate to earlier soundfiles"
						set OK 0
						break
					}
					lappend sfnams $item
				}
				default {
					incr cnt
					break
				}
			}
			incr cnt
		}
		if {!$OK} {
			break
		}
		if {$cnt != 2} {
			Inf "Wrong number of entries ($cnt) on line $linecnt (should be \"number sndfile\")"
			set OK 0
			break
		}
	}
	close $zit
	if {!$OK} {
		return {}
	}
	return [list $sndindex $sfnams]
}

#---- Check INDEX values used in data each have an entry in sound-assignment file

proc MidiValuesTally {midivals sndiii} {
	global chlist
	foreach midival $midivals {
		set gotit 0
		foreach sndii $sndiii {
			if {$midival == $sndii} {
				set gotit 1
				break
			}
		}
		if {!$gotit} {
			Inf "Sound-index value $midival in input data [lindex $chlist 0] not listed in sound-assignment file [lindex $chlist 1]"
			return 0
		}
	}
	return 1
}

#--- Morphing between rhythm patterns, either with same number of events OR different numbers of events

proc RhythmMorph {} {
	global chlist evv pa wstk pr_rym rym_fnam last_outfile wl rym rym_save readonlybg readonlyfg
	global CDPidrun prg_dun prg_abortd simple_program_messages rymcnt_line rym_cnt development_version

	catch {unset rym(patterns)}
	set evv(DO_RYM)	1
	set evv(DO_RYMEXP)	2
	set evv(DO_RYMSHR)	3
	set evv(DO_RYMINJ)	4
	if {![info exists chlist] || ([llength $chlist] != 2)} {
		Inf "Select two \"time  index  level position\" format files"
		return
	}
	foreach ifnam $chlist {
		set ftyp $pa($ifnam,$evv(FTYP))
		if {![IsAListofNumbers $ftyp]} {
				Inf "File $ifnam does not have the correct \"time  index  level position\" format"
				return
		}
		if [catch {open $ifnam "r"} zit] {
			Inf "Cannot open file $ifnam"
			return
		}
		set linecnt 0
		set lasttime -1
		catch {unset lines}
		catch {unset times}
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			if {[string match [string index $line 0] ";"]} {
				continue
			}
			incr linecnt
			catch {unset nuline}
			set line [split $line]
			set cnt 0
			set OK 1
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				switch -- $cnt {
					0 {
						if {$linecnt == 1} {
							if {$item != 0.0} {
								Inf "Initial time in input data file $ifnam must be zero"
								set OK 0
								break
							}
						} elseif {$item < $lasttime} {
							Inf "Times ($lasttime $item) in input data file $ifnam do not increase at line $linecnt"
							set OK 0
							break
						}
						set lasttime $item	
						lappend times $item
					}
					1 {
						if {![regexp {^[0-9]+$} $item] || ![IsNumeric $item]} {
							Inf "Invalid sound-index value on line $linecnt of file $ifnam"
							set OK 0
							break
						}
					}
					2 {
						if {($item < 0.0) || ($item > 1.0)} {
							Inf "Invalid level value on line $linecnt of file $ifnam"
							set OK 0
							break
						}
					}
					3 {
						if {($item <= 0.0) || ($item > 8.0)} {
							Inf "Invalid position value on line $linecnt of file $ifnam"
							set OK 0
							break
						}
					}
				}					
				lappend nuline $item
				incr cnt
			}
			if {!$OK} {
				break
			}
			if {$cnt != 4} {
				Inf "Wrong number of values ($cnt) on line ($linecnt) of file $ifnam: requires 4 values"
				set OK 0
				break
			}
			lappend lines $nuline
		}
		close $zit
		if {!$OK} {
			return
		}
		lappend rym(patterns) $lines
		lappend timelists $times
		if {$linecnt < 1} {
			Inf "No data found in file $ifnam"
			return
		}
	}				

	;#	SORT LINES INTO TIME ORDER

	foreach lines $rym(patterns) times $timelists {
		set len [llength $times]
		set len_less_one [expr $len - 1]
		set n 0
		while {$n < $len_less_one} {
			set time_n [lindex $times $n]
			set line_n [lindex $lines $n]
			set m $n
			incr m
			while {$m < $len} {
				set time_m [lindex $times $m]
				if {$time_m < $time_n} {
					set line_m [lindex $lines $m]
					set lines [lreplace $lines $n $n $line_m]
					set lines [lreplace $lines $m $m $line_n]
					set times [lreplace $times $n $n $time_m]
					set times [lreplace $times $m $m $time_n]
					set line_n $line_m
					set time_n $time_m
				}
				incr m
			}
			incr n
		}
		lappend nupatterns $lines
	}
	set rym(patterns) $nupatterns

	if {[llength [lindex $rym(patterns) 0]] == [llength [lindex $rym(patterns) 1]]} {
		set rym(knk) 0
		set rym(typ) $evv(DO_RYM)
	} else {
		set rym(knk) 1
		catch {unset rym(pat1sndindices)}
		catch {unset rym(pat2sndindices)}
		foreach line [lindex $rym(patterns) 0] {
			lappend rym(pat1sndindices) [lindex $line 1]
		}
		foreach line [lindex $rym(patterns) 1] {
			lappend rym(pat2sndindices) [lindex $line 1]
		}
		if {[llength [lindex $rym(patterns) 1]] > [llength [lindex $rym(patterns) 0]]} {
			set rym(typ) $evv(DO_RYMEXP)
		} else {
			set rym(typ) $evv(DO_RYMSHR)
		}
	}
	set f .rym
	catch {unset rym(lastbridges)}
	if [Dlg_Create $f "MORPH RHYTHM" "set pr_rym 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.doit -text "Morph" -command "set pr_rym 1" -bg $evv(EMPH) -width 6
		button $f.0.help -text "Help" -command "RymorphHelp" -bg $evv(HELP)
		label $f.0.pp -text "Patch"
		button $f.0.load -text "Load" -command "GetRymPatch 0"
		button $f.0.save -text "Save" -command "set pr_rym 2"
		button $f.0.del  -text "Delete" -command "GetRymPatch 1"
		label $f.0.ll -text "Outfile name"
		entry $f.0.e -textvariable rym(ofnam) -width 16
		label $f.0.dum -text "" -width 8
		button $f.0.quit -text "Quit" -command "set pr_rym 0"
		pack $f.0.doit $f.0.help $f.0.pp $f.0.load $f.0.save $f.0.del $f.0.ll $f.0.e $f.0.dum -side left -padx 2
		pack $f.0.quit -side right
		pack $f.0 -side top -fill x -expand true

		label $f.00a -text ""
		pack $f.00a -side top
		
 		frame $f.0a
		checkbutton $f.0a.inf -text "Add Descriptive info to output data" -variable rym(info)
		button $f.0a.show -text "See Patterns & Bridging" -command ShowPatternsAndBridgingData
		if {$development_version} {
			checkbutton $f.0a.cmd -text "Show Cmdline" -variable rym(showcmd)
			pack $f.0a.inf $f.0a.show $f.0a.cmd -side left -padx 10
		} else {
			pack $f.0a.inf $f.0a.show -side left -padx 10
		}
		set rym(showcmd) 0
		pack $f.0a -side top -fill x -expand true
		set rym(info) 0

		frame $f.0b
		checkbutton $f.0b.noend -text "Don't add endmarker event to output" -variable rym(noend)
		pack $f.0b.noend -side left
		pack $f.0b -side top -fill x -expand true
		set rym(noend) 0

		frame $f.00
		label $f.00.ll -text "NUMBER OF REPETITIONS OF ......" -fg $evv(SPECIAL)
		pack $f.00.ll -side left -padx 2
		pack $f.00 -side top -pady 2 -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Starting pattern (Dbl-click to see)." 
		entry $f.1.e -textvariable rym(startreps) -width 16
		pack $f.1.e $f.1.ll -side left -padx 2 
		pack $f.1 -side top -pady 2 -fill x -expand true

		frame $f.2
		label $f.2.ll -text "Each morphing step."
		entry $f.2.e -textvariable rym(mphsteprep) -width 16
		pack $f.2.e $f.2.ll -side left -padx 2
		pack $f.2 -side top -pady 2 -fill x -expand true

		frame $f.3
		label $f.3.ll -text "Final pattern (Dbl-click to see)."
		entry $f.3.e -textvariable rym(endreps) -width 16
		pack $f.3.e $f.3.ll -side left -padx 2
		pack $f.3 -side top -pady 2 -fill x -expand true

		frame $f.3a
		label $f.3a.ll -text "MORPHING PARAMETERS" -fg $evv(SPECIAL)
		pack $f.3a.ll -side left -padx 2
		pack $f.3a -side top -pady 2 -fill x -expand true

		frame $f.4
		label $f.4.ll -text "Number of morphing steps."
		entry $f.4.e -textvariable rym(steps) -width 16
		pack $f.4.e $f.4.ll -side left -padx 2
		pack $f.4 -side top -pady 2 -fill x -expand true

		frame $f.4a
		label $f.4a.ll -text "PATTERN-BRIDGING FILE TO USE (Dbl-click to see Bridgings)" -fg $evv(SPECIAL)
		pack $f.4a.ll -side left -padx 2
		pack $f.4a -side top -pady 2 -fill x -expand true

		frame $f.5
		button $f.5.b  -text "Bridging Files" -width 14 -command "FindPatternBridgingFiles"
		entry $f.5.e -textvariable rym(bridges) -width 32 -fg $readonlyfg -readonlybackground $readonlybg
		pack $f.5.e $f.5.b -side left -padx 4
		pack $f.5 -side top -pady 2 -fill x -expand true

		frame $f.5a
		label $f.5a.ll -text "WHERE ELEMENTS MIGRATE IN TIME WITHIN PATTERN, THEY MOVE..." -fg $evv(SPECIAL)
		pack $f.5a.ll -side left -padx 2
		pack $f.5a -side top -pady 2 -fill x -expand true

		frame $f.6
		radiobutton $f.6.0 -variable rym(mode) -text "Within pattern."	  -value 1
		radiobutton $f.6.1 -variable rym(mode) -text "Forwards."		  -value 2
		radiobutton $f.6.2 -variable rym(mode) -text "Backwards."		  -value 3
		radiobutton $f.6.3 -variable rym(mode) -text "by Shortest route." -value 4
		radiobutton $f.6.4 -variable rym(mode) -text "by Longest route."  -value 5
		label $f.6.ll2 -text "OR (WITH NO CHANGE IN SEQUENCE OF ELEMENTS) ..." -fg $evv(SPECIAL)
		radiobutton $f.6.5 -variable rym(mode) -text "New element(s) injected (fade in from silence)." -value 6
		set rym(mode) 0
		pack $f.6.0 $f.6.1 $f.6.2 $f.6.3 $f.6.4 $f.6.ll2 $f.6.5 -side top -anchor w
		pack $f.6 -side top -pady 2 -fill x -expand true

		frame $f.6a
		label $f.6a.ll -text "ELEMENT SPATIAL REPOSITIONING" -fg $evv(SPECIAL)
		pack $f.6a.ll -side left -padx 2
		pack $f.6a -side top -pady 2 -fill x -expand true

		frame $f.7
		radiobutton $f.7.1 -variable rym(respace) -text "None during morph." -value 0
		radiobutton $f.7.2 -variable rym(respace) -text "by Shortest route." -value 1
		radiobutton $f.7.3 -variable rym(respace) -text "by Longest route."	-value 2
		set rym(respace) -1
		pack $f.7.1 $f.7.2 $f.7.3  -side top -anchor w
		pack $f.7 -side top -pady 2 -fill x -expand true
		
		frame $f.7a
		label $f.7a.ll -text "ELEMENT LEVEL CHANGING" -fg $evv(SPECIAL)
		pack $f.7a.ll -side top -padx 2 -anchor w
		pack $f.7a -side top -pady 2 -fill x -expand true

		frame $f.8
		checkbutton $f.8.lev -text "Interpolate event levels." -variable rym(lev)
		pack $f.8.lev  -side top -anchor w
		pack $f.8 -side top -pady 2 -fill x -expand true
		set rym(lev) 0

		frame $f.8a
		label $f.8a.i1 -text "If levels interpolated, accent sequence at morph end = accent sequence at start."
		label $f.8a.i2 -text "If not, individual events retain their starting level after they move."
		label $f.8a.i3 -text "(There may be intermediate level shifts during the morph)."
		label $f.8a.i4 -text ""


		pack $f.8a.i1 $f.8a.i2 $f.8a.i3 $f.8a.i4 -side top -padx 2 -anchor w
		pack $f.8a -side top -pady 2 -fill x -expand true

		wm resizable $f 0 0
		bind .rym.0.e <Down> {focus .rym.1.e }
		bind .rym.1.e <Down> {focus .rym.2.e }
		bind .rym.2.e <Down> {focus .rym.3.e }
		bind .rym.3.e <Down> {focus .rym.4.e }
		bind .rym.4.e <Down> {focus .rym.5.e }
		bind .rym.5.e <Down> {focus .rym.0.e }
		bind .rym.0.e <Up> {focus .rym.5.e }
		bind .rym.1.e <Up> {focus .rym.0.e }
		bind .rym.2.e <Up> {focus .rym.1.e }
		bind .rym.3.e <Up> {focus .rym.2.e }
		bind .rym.4.e <Up> {focus .rym.3.e }
		bind .rym.5.e <Up> {focus .rym.4.e }
		bind .rym.1.ll <Double-1> {ShowCell 0}  
		bind .rym.3.ll <Double-1> {ShowCell 1}  
		bind .rym.5.e <Double-1> {ShowBridgeData}
		bind $f <Escape> {set pr_rym 0}
		bind $f <Return> {set pr_rym 1}
	}
	RymRym
	set pr_rym 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_rym $f.0.e
	while {!$finished} {
		tkwait variable pr_rym
		set rym_save 0
		switch -- $pr_rym {
			1 -
			2 {
				;#	CHECK ALL PARAMS (except outfnam)

				if {![IsNumeric $rym(startreps)] || ![regexp {^[0-9]+$} $rym(startreps)] || ($rym(startreps) < 0)} {
					Inf "Invalid entry for \"repetitions of start-pattern\" (range >= 0)"	
					continue
				}
				if {![IsNumeric $rym(mphsteprep)] || ![regexp {^[0-9]+$} $rym(mphsteprep)] || ($rym(mphsteprep) < 1)} {
					Inf "Invalid entry for \"repetitions of each morphing step\" (range >= 0)"	
					continue
				}
				if {![IsNumeric $rym(endreps)] || ![regexp {^[0-9]+$} $rym(endreps)] || ($rym(endreps) < 0)} {
					Inf "Invalid entry for \"repetitions of each morphed pattern\" (range >= 0)"	
					continue
				}
				if {![IsNumeric $rym(steps)] || ![regexp {^[0-9]+$} $rym(steps)] || ($rym(steps) < 2)} {
					Inf "Invalid entry for \"number of morphing steps\" (range >= 2)"	
					continue
				}
				if {$rym(mode) <= 0} {
					Inf "Time-migration type not set"
					continue
				}
				if {$rym(mode) == 6} {
					if {$rym(typ) != $evv(DO_RYMINJ)} {
						if {$rym(typ) != $evv(DO_RYMEXP)} {
							Inf "2nd pattern must be larger than first, in this mode"
							continue
						}
					}
					set rym(typ) $evv(DO_RYMINJ)
				} elseif {$rym(typ) == $evv(DO_RYMINJ)} {
					set rym(typ) $evv(DO_RYMEXP)
				}
				if {$rym(knk)} {
					if {[string length $rym(bridges)] <= 0} {
						Inf "No entry for pattern-bridging file"	
						continue
					}
					if {![RymBridgingFileTest $rym(bridges) 2]} {
						continue
					}
					if {$rym(mode) == 6} {
						set OK 1
						foreach line $rym(bridgedata) {
							if {[llength $line] != 2} {
								Inf "Bridging file incompatible with chosen (injection) mode"
								set OK 0
								break
							}
						}
						if {!$OK} {
							continue
						}
					}
				}
				if {$rym(respace) < 0} {
					Inf "Spatial redistribution type not set"
					continue
				}
				if {$pr_rym == 2} {
					SaveRymPatch
					continue
				}

				;#	CHECK OUTFILE NAME

				if {![ValidCDPRootname $rym(ofnam)]} {
					continue
				}
				set ofnam [string tolower $rym(ofnam)] 
				set linkofnam $ofnam
				append linkofnam _link$evv(TEXT_EXT)
				set mapofnam $ofnam
				append mapofnam _map$evv(TEXT_EXT)
				set stendofnam $ofnam
				append stendofnam _stend$evv(TEXT_EXT)
				append ofnam $evv(TEXT_EXT)
				set OK 1
				if {$rym(knk)} {
					set testfnams [list $ofnam $mapofnam $stendofnam $linkofnam]
				} else {
					set testfnams [list $ofnam $mapofnam $stendofnam]
				}
				set n 0
				foreach zfnam $testfnams {
					foreach chfnam $chlist {
						if {[string match $chfnam $zfnam]} {
							set msg "Output "
							switch -- $n {
								0 { append msg "PATTERNFILE "		}
								1 { append msg "MAPFILE "			}
								2 { append msg "LASTCELLTIME-FILE " }
								3 { append msg "LINKFILE "			}
							}
							append msg "Name ($zfnam) cannot be same as any of input files"
							Inf $msg
							set OK 0
							break
						}
					}
					if {!$OK} {
						break
					}
					incr n
				}
				if {!$OK} {
					continue
				}
				foreach zfnam $testfnams {
					if {[file exists $zfnam]} {
						set msg "File $zfnam already exists : overwrite it ??"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							set OK 0
							break
						}
					}
				}
				if {!$OK} {
					continue
				}
				foreach zfnam $testfnams {
					if {[file exists $zfnam]} {
						if {![CouetteAllowsDelete $zfnam]} {
							set OK 0
							break
						}
						if [catch {file delete -force $zfnam} in] {
							Inf "Cannot delete the file $zfnam."
							set OK 0
							break
						} else {
							DataManage delete $zfnam
							CouettePatchesDelete $zfnam
							DeleteFileFromSrcLists $zfnam
							RemoveFromChosenlist $zfnam
							PurgeArray $zfnam
							DummyHistory $zfnam "OVERWRITTEN"
							set i [LstIndx $zfnam $wl]
							if {$i >= 0} {
								$wl delete $i
							}
						}
					}
				}
				if {!$OK} {
					continue
				}
				switch -regexp -- $rym(typ) \
					^$evv(DO_RYM)$ {
						set rymtype "MORPHING"
						set cmd [file join $evv(CDPROGRAM_DIR) rhymorph]
						lappend cmd rhymorph
					} \
					^$evv(DO_RYMEXP)$ {
						set rymtype "EXPANDING MORPH"
						set cmd [file join $evv(CDPROGRAM_DIR) rhymorph2]
						lappend cmd rhymorph2
					} \
					^$evv(DO_RYMSHR)$ {
						set rymtype "CONTRACTING MORPH"
						set cmd [file join $evv(CDPROGRAM_DIR) rhymorph2]
						lappend cmd rhymorph2
					} \
					^$evv(DO_RYMINJ)$ {
						set rymtype "INSERTION MORPH"
						set cmd [file join $evv(CDPROGRAM_DIR) rhymorph2]
						lappend cmd rhymorph2
					}

				lappend cmd $rym(mode)
				foreach fnam $chlist {
					lappend cmd $fnam
				}
				lappend cmd $ofnam
				if {$rym(knk)} {
					lappend cmd $rym(bridges)
				}
				lappend cmd $rym(startreps) $rym(mphsteprep) $rym(endreps) $rym(steps)
				if {$rym(respace)} {
					lappend cmd -s$rym(respace)
				}
				if {$rym(lev)} {
					lappend cmd "-l"
				}
				if {$rym(info)} {
					lappend cmd "-t"
				}
				if {$rym(noend)} {
					lappend cmd "-e"
				}
				if {$rym(showcmd)} {
					Inf "cmd = \n$cmd"
				}
				switch -regexp -- $rym(typ) \
					^$evv(DO_RYM)$ - \
					^$evv(DO_RYMEXP)$ - \
					^$evv(DO_RYMSHR)$ {
						set hline "$ofnam is MORPH "
					} \
					^$evv(DO_RYMINJ)$ {
						set hline "$ofnam is MORPH "
					}
				
				append hline " [file rootname [lindex $chlist 0]] TO [file rootname [lindex $chlist 1]] in $rym(steps) steps "

				switch -- $rym(mode) {
					1 {
						append hline "Within pattern "
					}
					2 {
						append hline "Forwards "
					}
					3 {
						append hline "Backwards "
					}
					4 {
						append hline "by Shortest route "
					}
					5 {
						append hline "by Longest route "
					}
				}
				append hline "WITH REPEATS OF startpat $rym(startreps) morphsteps $rym(mphsteprep) endpat $rym(endreps) "
				switch -- $rym(respace) {
					0 {
						append hline " and no spacemoves"
					}
					1 {
						append hline " and spacemoves-shortest"
					}
					2 {
						append hline " and spacemoves-longest"
					}
				}
				if {$rym(lev)} {
					append hline " interpolating-event-levels"
				}
				DoRhythmHistory $hline
				Block $rymtype
				set CDPidrun 0
				set prg_dun 0
				set prg_abortd 0
				catch {unset simple_program_messages}
				catch {unset rymcnt_line}
				catch {unset rym_cnt}
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "$CDPidrun : \nfailed to run $rymtype process\n$cmd"
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
					Inf "$CDPidrun : \n$rymtype process failed\n$cmd"
					UnBlock
					continue
				}
				if {![file exists $ofnam]} {
					Inf "$CDPidrun : \nfailed to do $rymtype\n$cmd"
					set OK 0
				}
				UnBlock
				if {!$OK} {
					continue
				}
				if {[file exists $linkofnam]} {
					FileToWkspace $linkofnam 0 0 0 0 1
				}
				if {[file exists $mapofnam]} {
					FileToWkspace $mapofnam 0 0 0 0 1
				}
				if {[file exists $stendofnam]} {
					FileToWkspace $stendofnam 0 0 0 0 1
				}
				if {[FileToWkspace $ofnam 0 0 0 0 1] > 0} {
					Inf "File $ofnam is on the workspace"
				} else {
					Inf "File $ofnam has been created"
				}
			}
			0 {
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc RymorphHelp {} {
	set msg "MORPH RHYTHM CELLS\n"
	append msg "\n"
	append msg "Takes a pair of rhythm-cells, in the \"Time  Index  Level  Position\" format,\n"
	append msg "and gradually morphs the first rhythm cell into the second.\n"
	append msg "\n"
	append msg "The number of morphing steps can be specified.\n"
	append msg "\n"
	append msg "(1) The initial cell can be repeated a specified number of times.\n"
	append msg "(2) Each morphing stage can be repeated a specified number of times.\n"
	append msg "(3) The goal cell can be repeated a specified number of times.\n"
	append msg "\n"
	append msg "cells can morph by\n"
	append msg "1) Moving each element forward in the cell to its new beat-location.\n"
	append msg "2) Moving each element backwards in the cell to its new beat-location.\n"
	append msg "3) Moving each element to its new beat-location via the shortest route.\n"
	append msg "4) Moving each element to its new beat-location via the longest route.\n"
	append msg "\n"
	append msg "In addition....\n"
	append msg "\n"
	append msg "The spatial position of morphing elements can....\n"
	append msg "(1) not change.\n"
	append msg "(2) take the shortest routes to move to their new positions.\n"
	append msg "(3) take the longest routes to move to their new positions.\n"
	append msg "\n"
	append msg "The level of morphing elements can....\n"
	append msg "(1) Interpolate from start value to end value (final accent sequence same as at start).           \n"
	append msg "(2) Not interpolate. (events retain their loudness as they move).\n"
	append msg "\n"
	append msg "Titles and spacing can be added to the output data to identify morphing stages.\n"
	append msg "\n"
	append msg "The output can later be converted to a mixfile, to generate sound.\n"
	append msg "\n"
	append msg "TYPES OF MORPH\n"
	append msg "\n"
	append msg "(1) Morph between 2 cells with the same number of events in each cell.\n"
	append msg "(3) Morph between 2 cells with less events in the goal cell, merging existing events .\n"
	append msg "(2) Morph between 2 cells with more events in the goal cell, splitting existing events.\n"
	append msg "(4) Morph between 2 cells with more events in the goal cell, injecting new events.\n"
	append msg "\n"
	append msg "Where the number of cell events changes during the morph (types 2, 3 & 4)\n"
	append msg "a file specifying the \"bridging\" is required.\n"
	append msg "\n"
	append msg "For types 2 & 3 ....\n"
	append msg "This associates each event in the smaller cell with 1 or more event in the larger.\n"
	append msg "and has data-lines with the format.\n"
	append msg "sml big1 \[big2 ......\]\n"
	append msg "Where \"sml\" refers to a line-number in the smaller cell\n"
	append msg "and \"bigN\" refer to the corresponding line-number(s) in the bigger cell.\n"
	append msg "\n"
	append msg "Bridged lines (e.g. \"sml big1 big2\" as \"2 3 7\") must have same sound-index numbers.\n"
	append msg "\n"
	append msg "For type 4 ....\n"
	append msg "This associates each event in the smaller cell with just 1 event in the larger,\n"
	append msg "(but not with every line).\n"
	append msg "and has data-lines with the format.\n"
	append msg "sml big\n"
	append msg "Where \"sml\" refers to a line-number in the smaller cell\n"
	append msg "and \"big\" refers to a corresponding line-number in the bigger cell.\n"
	append msg "\n"
	append msg "Bridged lines (e.g. \"sml big\") must have same sound-index numbers.\n"
	append msg "\"sml\" lines must be numbered upwards from 1 (with no gaps).\n"
	append msg "\"big\" lines must be in increasing order.\n"
	Inf $msg
}

#--- Rhythm Morphing patches: load, get, save

proc SaveRymPatch {} {
	global rym evv rymsavenam pr_rymsave
	set fnam [file join $evv(URES_DIR) rym$evv(CDP_EXT)]
	set thispatch $rym(typ)
	lappend thispatch $rym(mode) $rym(startreps) $rym(mphsteprep) $rym(endreps) $rym(steps)
	lappend thispatch $rym(respace) $rym(lev) $rym(info)
	if {$rym(typ) != $evv(DO_RYM)} {
		lappend thispatch $rym(bridges)
	}
	set f .rymsave
	if [Dlg_Create $f "SAVE RHYTHM MORPH PATCH" "set pr_rymsave 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.save -text "Save" -command "set pr_rymsave 1" -bg $evv(EMPH)
		button $f.0.quit -text "Abandon" -command "set pr_rymsave 0"
		pack $f.0.save -side left -padx 4
		pack $f.0.quit -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Patch Name"
		entry $f.1.e -textvariable rymsavenam -width 24
		pack $f.1.ll $f.1.e -side left -padx 2
		pack $f.1 -side top -fill x -expand true
		frame $f.2
		label $f.2.ll -text "Existing patches" -fg $evv(SPECIAL)
		Scrolled_Listbox $f.2.pp -width 64 -height 24 -selectmode single
		pack $f.2.ll $f.2.pp -side top -pady 2
		pack $f.2 -side top
		wm resizable $f 0 0
		bind $f <Escape> {set pr_rymsave 0}
		bind $f <Return> {set pr_rymsave 1}
	}
	.rymsave.2.pp.list delete 0 end
	if {[info exists rym(patches)]} {
		foreach patch $rym(patches) {
			set pnam [lindex $patch 0]
			.rymsave.2.pp.list insert end $pnam
		}
	}
	set pr_rymsave 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_rymsave $f.1.e
	while {!$finished} {
		tkwait variable pr_rymsave
		if {$pr_rymsave} {
			if {![ValidCDPRootname $rymsavenam]} {
				continue
			}
			set patchnam [string tolower $rymsavenam] 
			set OK 1
			if {[info exists rym(patches)]} {
				foreach pnam [.rymsave.2.pp.list get 0 end] {
					if {[string match $pnam $patchnam]} {
						Inf "Patch name already used: please choose a different patch name"
						set OK 0
						break
					}
				}
				if {!$OK} {
					continue
				}
			}
			set outpatch [concat $patchnam $thispatch]
			lappend rym(patches) $outpatch
			.rymsave.2.pp.list insert end $patchnam
			if {[file exists $fnam]} {
				if [catch {open $fnam "a"} zit] {
					Inf "Cannot open file $fnam to save patch data"
					set OK 0
				}
			} else {
				if [catch {open $fnam "w"} zit] {
					Inf "Cannot open file $fnam to save patch data"
					set OK 0
				}
			}
			if {$OK} {
				puts $zit $outpatch
				close $zit
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Get or Delete an existing patch

proc GetRymPatch {del} {
	global rym evv rymgetnam pr_rymget readonlybg readonlyfg wstk
	set fnam [file join $evv(URES_DIR) rym$evv(CDP_EXT)]

	if {[info exists rym(patches)]} {
		foreach patch $rym(patches) {
			set typ [lindex $patch 1]
			if {$rym(typ) == $typ} {
				lappend patchnamelist [lindex $patch 0]
			}
		}
	}
	if {![info exists patchnamelist]} {
		Inf "No appropriate patches exist for a rhythm-cell pair of this type"
		return
	}
	set f .rymget
	if [Dlg_Create $f "GET RHYTHM MORPH PATCH" "set pr_rymget 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.save -text "Get Patch" -command "set pr_rymget 1" -bg $evv(EMPH) -width 12
		button $f.0.quit -text "Quit" -command "set pr_rymget 0"
		pack $f.0.save -side left -padx 4
		pack $f.0.quit -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Patch Name"
		entry $f.1.e -textvariable rymgetnam -width 24 -readonlybackground $readonlybg -fg $readonlyfg -state readonly
		pack $f.1.ll $f.1.e -side left -padx 2
		pack $f.1 -side top -fill x -expand true
		frame $f.2
		label $f.2.ll -text "Select patch with mouse-click" -fg $evv(SPECIAL)
		Scrolled_Listbox $f.2.pp -width 64 -height 24 -selectmode single
		pack $f.2.ll $f.2.pp -side top -pady 2
		pack $f.2 -side top
		wm resizable $f 0 0
		bind .rymget.2.pp.list <ButtonRelease> {GetTheRymPatch %y} 
		bind $f <Escape> {set pr_rymget 0}
		bind $f <Return> {set pr_rymget 1}
	}
	if {$del} {
		wm title .rymget "DELETE RHYTHM MORPHING PATCH"
		$f.0.save config -text "Delete Patch"
	} else {
		wm title .rymget "GET RHYTHM MORPHING PATCH"
		$f.0.save config -text "Get Patch"
	}	
	.rymget.2.pp.list delete 0 end
	if {[info exists rym(patches)]} {
		foreach pnam $patchnamelist {
			.rymget.2.pp.list insert end $pnam
		}
	}
	set pr_rymget 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_rymget
	while {!$finished} {
		tkwait variable pr_rymget
		if {$pr_rymget} {
			if {[string length $rymgetnam] <= 0} {
				Inf "No patch selected"
				continue
			}
			set n 0
			foreach patch $rym(patches) {
				if {[string match $rymgetnam [lindex $patch 0]]} {
					set thispatch $patch
					break
				}
				incr n
			}
			if {![info exists thispatch]} {
				Inf "PROBLEM!!"
				continue
			}
			if {$del} {
				set msg "Are you sure you want to ~~delete~~ patch $rymgetnam ???"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				set rym(patches) [lreplace $rym(patches) $n $n]
				.rymget.2.pp.list delete $n
				if [file exists $fnam] {
					if {[llength $rym(patches)] <= 0} {
						catch {file delete $fnam}
						unset rym(patches)
					} elseif [catch {open $fnam "w"} zit] {
						Inf "Cannot open file $fnam to update patch info"
					} else {
						foreach patch $rym(patches) {
							puts $zit $patch
						}
						close $zit
					}
				}
				continue
			} else {
				set thispatch [lrange $thispatch 1 end]
				set cnt 0
				set rym(typ)  [lindex $thispatch $cnt]
				if {$rym(typ) != $evv(DO_RYM)} {
					set rym(knk) 1
				} else {
					set rym(knk) 0
				}
				RymRym
				incr cnt
				set rym(mode)		[lindex $thispatch $cnt]
				incr cnt
				set rym(startreps)	[lindex $thispatch $cnt]
				incr cnt
				set rym(mphsteprep) [lindex $thispatch $cnt]
				incr cnt
				set rym(endreps)	[lindex $thispatch $cnt]
				incr cnt
				set rym(steps)		[lindex $thispatch $cnt]
				incr cnt
				set rym(respace)	[lindex $thispatch $cnt]
				incr cnt
				set rym(lev)		[lindex $thispatch $cnt]
				incr cnt
				set rym(info)		[lindex $thispatch $cnt]
				incr cnt
				if {$rym(typ) != $evv(DO_RYM)} {
					set rym(bridges)  [lindex $thispatch $cnt]
				}
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc GetTheRymPatch {y} {
	global rymgetnam
	set i [.rymget.2.pp.list nearest $y]
	if {$i >= 0} {
		set rymgetnam [.rymget.2.pp.list get $i]
	}
}

proc LoadRymPatches {} {
	global evv rym
	set fnam [file join $evv(URES_DIR) rym$evv(CDP_EXT)]
	if {![file exists $fnam]} {
		return
	}
	if [catch {open $fnam "r"} zit] {
		return
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		lappend rym(patches) $line
	}
	close $zit
}

proc RymRym {} {
	global rym readonlybg
	if {$rym(knk)} {
		.rym.4a.ll config -text "PATTERN-BRIDGING FILE TO USE (Dbl-click to see bridgings)"
		.rym.5.b config -text "Bridging Files" -bd 2 -command FindPatternBridgingFiles -state normal
		.rym.5.e config -bd 2 -readonlybackground $readonlybg
		bind .rym.5.e <Double-1> {ShowBridgeData}
		if {[info exists rym(lastbridges)]} {
			set rym(bridges) $rym(lastbridges)
		}
		bind .rym.4.e <Down> {focus .rym.5.e }
		bind .rym.0.e <Up>	 {focus .rym.5.e }
	} else {
		.rym.4a.ll config -text ""
		.rym.5.b config -text "" -bd 0 -command {} -state disabled
		set rym(lastbridges) $rym(bridges)
		set rym(bridges) ""
		.rym.5.e config -bd 0 -readonlybackground [option get . background {}]
		bind .rym.5.e <Double-1> {}
		bind .rym.4.e <Down> {focus .rym.0.e }
		bind .rym.0.e <Up>   {focus .rym.4.e }
	}
}

#--- Get a file listing pattern-bridgings

proc FindPatternBridgingFiles {} {
	global evv rym pr_rymbridges bridge_i readonlyfg readonlybg
	if {![LoadAppropriatePatternBridgingFiles]} {
		Inf "No appropriate files on workspace"
		return
	}
	set f .rymbridges
	if [Dlg_Create $f "POSSIBLE BRIDGING FILES" "set pr_rymbridges 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.save -text "Select" -command "set pr_rymbridges 1" -bg $evv(EMPH)
		button $f.0.quit -text "Abandon" -command "set pr_rymbridges 0"
		pack $f.0.save -side left -padx 4
		pack $f.0.quit -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Selected File"
		entry $f.1.e -textvariable bridge_i -width 48 -fg $readonlyfg -readonlybackground $readonlybg -state readonly
		set bridge_i ""
		pack $f.1.ll $f.1.e -side left -padx 2
		pack $f.1 -side top -fill x -expand true
		frame $f.2
		label $f.2.ll -text "Select file with mouse-click" -fg $evv(SPECIAL)
		Scrolled_Listbox $f.2.pp -width 64 -height 24 -selectmode single
		pack $f.2.ll $f.2.pp -side top -pady 2
		pack $f.2 -side top
		wm resizable $f 0 0
		bind .rymbridges.2.pp.list <ButtonRelease> {GetBridgingFile %y}
		bind $f <Escape> {set pr_rymbridges 0}
		bind $f <Return> {set pr_rymbridges 1}
	}
	.rymbridges.2.pp.list delete 0 end
	foreach fnam $rym(bridgingfiles) {
		.rymbridges.2.pp.list insert end $fnam
	}
	if {[llength $rym(bridgingfiles)] == 1} {
		set bridge_i [lindex $rym(bridgingfiles) 0]
	}
	set pr_rymbridges 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_rymbridges
	while {!$finished} {
		tkwait variable pr_rymbridges
		if {$pr_rymbridges} {
			if {[string length $bridge_i] <= 0} {
				Inf "No file selected"
				continue
			}
			set rym(bridges) $bridge_i
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc GetBridgingFile {y} {
	global bridge_i
	set i [.rymbridges.2.pp.list nearest $y]
	if {$i >= 0} {
		set bridge_i [.rymbridges.2.pp.list get $i]
	}
}

#--- Search workspace for pattern-bridging files appropriate to current list of patterns-to-bridge

proc LoadAppropriatePatternBridgingFiles {} {
	global wl pa evv rym chlist
	foreach fnam [$wl get 0 end] {
		set ftyp $pa($fnam,$evv(FTYP))
		if {$ftyp & $evv(IS_A_TEXTFILE)} {
			lappend templist $fnam
		}
	}
	if {![info exists templist]} {
		return 0
	}
	foreach fnam $templist {
		if {[RymBridgingFileTest $fnam 0]} {
			lappend outlist $fnam
		}
	}
	if {![info exists outlist]} {
		return 0
	}
	set rym(bridgingfiles) $outlist
	return 1
}

#--- Test textfile to see if it represents pattern groupings
#
#	Format is start-cell-event goal-cell-event-1 [goal-cell-event-2 ....]
#	All lines in both small cell and large cell must be represented
#	All lines which are mapped must use SAME sound-index value
#

proc RymBridgingFileTest {fnam load} {
	global evv rym
	if {[string length $fnam] <= 0} {
		if {$load == 1} {
			Inf "No bridging file selected"
		}
		return 0
	}
	if {![file exists $fnam]} {
		if {$load} {
			Inf "Bridging file $fnam does not exist"
		}
		return 0
	}
	set ftyp [FindFileType $fnam]
	if {!($ftyp & $evv(IS_A_TEXTFILE))} {
		if {$load} {
			Inf "Bridging file $fnam is not a textfile"
		}
		return 0
	}
	if [catch {open $fnam "r"} zit] {
		if {$load} {
			Inf "Cannot open bridging file $fnam"
		}
		return 0
	}
	set srcevent  {}
	set goalevent {}
	set len1 [llength $rym(pat1sndindices)]
	set smallsndindeces $rym(pat1sndindices)
	set smallen $len1
	set len2 [llength $rym(pat2sndindices)]
	set bigsndindeces $rym(pat2sndindices)
	set biglen $len2
	set srccnt  0
	set goalcnt 0
	if {$len2 < $len1} {
		set smallen $len2
		set smallsndindeces $rym(pat2sndindices)
		set biglen $len1
		set bigsndindeces $rym(pat1sndindices)
	}
	set linecnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		incr linecnt
		set line [split $line]
		set cnt 0
		set OK 1
		catch {unset nuline}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {![regexp {^[0-9]+$} $item] || ![IsNumeric $item]} {
				if {$load} {
					Inf "Bridging file $fnam contains non-numeric data"
				}
				set OK 0
				break
			}
			if {$item < 1} {
				if {$load} {
					Inf "Bridging file $fnam contains a line-number ($item) that does not exist"
				}
				set OK 0
				break
			}
			if {$cnt == 0} {
				set srcsndidx [lindex $smallsndindeces [expr $item - 1]]
				if {[lsearch $srcevent $item] >= 0} {	;#	Mapped-from indices cannot be duplicated
					if {$load} {
						Inf "Smaller-pattern line-number $item in bridging file $fnam is duplicated"
					}
					set OK 0
					break
				}
				if {$item > $smallen} {
					if {$load} {
						Inf "Smaller-pattern line-number $item in bridging file $fnam refers to a line that does not exist"
					}
					set OK 0
					break
				}
				lappend srcevent $item					;#	Store all Mapped-from indices
				incr srccnt
			} else {
				set othersndidx [lindex $bigsndindeces [expr $item - 1]]
				if {$srcsndidx != $othersndidx} {
					if {$load} {
						Inf "Attempt to map between lines with different sound indices ($srcsndidx & $othersndidx) in bridging file $fnam"
					}
					set OK 0
					break
				}
				if {[lsearch $goalevent $item] >= 0} {	;#	Mapped-to indices cannot be duplicated
					if {$load} {
						Inf "Larger-pattern line-number $item in file $fnam is duplicated"
					}
					set OK 0
					break
				}
				if {$item > $biglen} {
					if {$load} {
						Inf "Larger-pattern line-number $item in file $fnam refers to a line that does not exist"
					}
					set OK 0
					break
				}
				lappend goalevent $item					;#	Store all Mapped-to indices
				incr goalcnt
			}
			lappend nuline $item
			incr cnt
		}
		if {!$OK} {
			close $zit
			return 0
		}
		if {$cnt < 2} {
			if {$load} {
				Inf "Insufficient entries (< 2) on line $linecnt in bridging file $fnam"
			}
			close $zit
			return 0

		}
		lappend nulines $nuline
	}
	close $zit
	if {$srccnt != $smallen} {
		if {$load} {
			Inf "Not all smaller-pattern line-numbers used in bridging file $fnam"
		}
		return 0
	}
	if {$goalcnt != $biglen} {
		if {$load} {
			Inf "Not all larger-pattern line-numbers used in bridging file $fnam"
		}
		return 0
	}
	if {$load > 1} {
		set rym(bridgedata) $nulines
	}
	return 1
}

#--- Display data in rhymorph2 bridgefile

proc ShowBridgeData {} {
	global rym
	if {[string length $rym(bridges)] <= 0} {
		return
	}
	RymBridgingFileTest $rym(bridges) 2
}

#---- Display rhythm cell being used in rhythm-morphing

proc ShowCell {end} {
	global chlist rym
	if {$end} {
		set lines [lindex $rym(patterns) 1]
	} else {
		set lines [lindex $rym(patterns) 0]
	}
	set msg "[lindex $lines 0]"
	foreach line [lrange $lines 1 end] {
		append msg "\n$line"
	}
	Inf $msg
}

#---- Show patterns and bridging data

proc ShowPatternsAndBridgingData {} {
	global pr_patbridgeshow rym evv chlist
	set bridging_selected 1
	if {![RymBridgingFileTest $rym(bridges) 2]} {
		set bridging_selected 0
	}
	if {![info exists rym(patterns)]} {
		return
	}
	set f .patbridgeshow
	if [Dlg_Create $f "RHYTHM MORPH : PATTERNS AND BRIDGING" "set pr_patbridgeshow 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.quit -text "Quit" -command "set pr_patbridgeshow 0"
		pack $f.0.quit -side right
		frame $f.1
		frame $f.1.1
		frame $f.1.2
		frame $f.1.3
		Scrolled_Listbox $f.1.1.pp1 -width 64 -height 48 -selectmode single
		pack $f.1.1.pp1 -side top -pady 2 -anchor n
		Scrolled_Listbox $f.1.2.pp2 -width 64 -height 48 -selectmode single
		pack $f.1.2.pp2 -side top -pady 2 -anchor n
		Scrolled_Listbox $f.1.3.lnk -width 64 -height 48 -selectmode single
		pack $f.1.3.lnk -side top -pady 2 -anchor n
		pack $f.1.1 $f.1.2 $f.1.3 -side left -anchor n
		pack $f.1 -side top
		wm resizable $f 0 0
		bind $f <Escape> {set pr_patbridgeshow 0}
		bind $f <Return> {set pr_patbridgeshow 0}
	}
	.patbridgeshow.1.1.pp1.list delete 0 end
	set title "PATTERN 1 ([file rootname [file tail [lindex $chlist 0]]])"
	.patbridgeshow.1.1.pp1.list insert end $title
	set linespace ""
	.patbridgeshow.1.1.pp1.list insert end $linespace
	foreach line [lindex $rym(patterns) 0] {
		.patbridgeshow.1.1.pp1.list insert end $line
	}
	.patbridgeshow.1.2.pp2.list delete 0 end
	set title "PATTERN 2 ([file rootname [file tail [lindex $chlist 1]]])"
	.patbridgeshow.1.2.pp2.list insert end $title
	set linespace ""
	.patbridgeshow.1.2.pp2.list insert end $linespace
	foreach line [lindex $rym(patterns) 1] {
		.patbridgeshow.1.2.pp2.list insert end $line
	}
	.patbridgeshow.1.3.lnk.list delete 0 end
	if {$bridging_selected} {
		set title "BRIDGING ([file rootname [file tail $rym(bridges)]])"
		.patbridgeshow.1.3.lnk.list insert end $title
		set linespace ""
		.patbridgeshow.1.3.lnk.list insert end $linespace
		foreach line $rym(bridgedata) {
			.patbridgeshow.1.3.lnk.list insert end $line
		}
	} else {
		set title "NO BRIDGING-FILE SELECTED"
		.patbridgeshow.1.3.lnk.list insert end $title
	}
	set pr_patbridgeshow 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_patbridgeshow
	tkwait variable pr_patbridgeshow
	My_Release_to_Dialog $f
	destroy $f
}

############################
# SOUND-INDEX SUBSTITUTION #
############################

#--- Substitute new sound-indices in existing pattern

proc RhythmSoundSubstitute {} {
	global chlist evv pa rym rymsubfnam pr_rymsub wl wstk readonlyfg readonlybg
	if {![info exists chlist] || ([llength $chlist] != 1)} {
		Inf "SELECT ONE \"Time  Index  Level Position\" FORMAT FILE"
		return
	}
	set ifnam [lindex $chlist 0]
	set ftyp $pa($ifnam,$evv(FTYP))
	if {![IsAListofNumbers $ftyp]} {
		Inf "File $ifnam does not have the correct \"time  index  level position\" format"
		return
	}
	set mfnam [file rootname $ifnam]
	append mfnam _map$evv(TEXT_EXT)
	if {![file exists $mfnam]} {
		Inf "The associated map file $mfnam does not exist"
		return
	}
	set ftyp $pa($mfnam,$evv(FTYP))
	if {![IsAListofNumbers $ftyp]} {
			Inf "File $mfnam does not have the correct map format"
			return
	}
	set dostend 0
	set stendifnam [file rootname $ifnam]
	append stendifnam _stend$evv(TEXT_EXT)
	if {[file exists $stendifnam]} {
		set dostend 1
	}
	if [catch {open $ifnam "r"} zit] {
		Inf "Cannot open file $ifnam"
		return
	}
	set linecnt 0
	set lasttime -1
	catch {unset lines}
	catch {unset times}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		incr linecnt
		catch {unset nuline}
		set line [split $line]
		set cnt 0
		set OK 1
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			switch -- $cnt {
				0 {
					if {$linecnt == 1} {
						if {$item != 0.0} {
							Inf "Initial time in input data file $ifnam must be zero"
							set OK 0
							break
						}
					} elseif {$item < $lasttime} {
						Inf "Times ($lasttime $item) in input data file $ifnam do not increase at line $linecnt"
						set OK 0
						break
					}
					set lasttime $item	
					lappend times $item
				}
				1 {
					if {![regexp {^[0-9]+$} $item] || ![IsNumeric $item]} {
						Inf "Invalid sound-index value on line $linecnt of file $ifnam"
						set OK 0
						break
					}
				}
				2 {
					if {($item < 0.0) || ($item > 1.0)} {
						Inf "Invalid level value on line $linecnt of file $ifnam"
						set OK 0
						break
					}
				}
				3 {
					if {($item < 0.0) || ($item > 8.0)} {
						Inf "Invalid position value on line $linecnt of file $ifnam"
						set OK 0
						break
					}
				}
			}					
			lappend nuline $item
			incr cnt
		}
		if {!$OK} {
			break
		}
		if {$cnt != 4} {
			Inf "Wrong number of values ($cnt) on line ($linecnt) of file $ifnam: requires 4 values"
			set OK 0
			break
		}
		lappend lines $nuline
	}
	close $zit
	if {!$OK} {
		return
	}
	set rym(patterns) [list $lines]
	set rym(patcnt) [llength $lines]

	if [catch {open $mfnam "r"} zit] {
		Inf "Cannot open file $mfnam"
		return
	}
	set linecnt 0
	catch {unset lines}
	set mapvals {}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		incr linecnt
		catch {unset nuline}
		set line [split $line]
		set OK 1
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {![regexp {^[0-9]+$} $item] || ![IsNumeric $item] || ($item < 1)} {
				Inf "Invalid line-number on line $linecnt of map file $mfnam"
				set OK 0
				break
			}
			if {[lsearch $mapvals $item] >= 0} {
				Inf "Line-number $item duplicated in map file $mfnam"
				set OK 0
				break
			}
			lappend mapvals $item
			lappend nuline $item
		}
		if {!$OK} {
			break
		}
		lappend maps $nuline
	}
	close $zit
	if {!$OK} {
		return
	}

	if {[llength $mapvals] != $rym(patcnt)} {
		set msg "Does pattern have an end-marker element ?"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -default yes -message $msg]
		if {$choice == "yes"} {
			incr rym(patcnt) -1
		}
		if {[llength $mapvals] != $rym(patcnt)} {
			Inf "Insufficient map entries in file $mfnam for pattern in file $ifnam"
			return
		}
	}
	set n 1
	while {$n <= $rym(patcnt)} {
		set gotit 0
		foreach map $maps {
			foreach item $map {
				if {$item == $n} {
					set gotit 1
					break
				}
			}
			if {$gotit} {
				break
			}
		}
		if {!$gotit} {
			break
		}
		incr n
	}
	if {!$gotit} {
		Inf "Maps in $mfnam do not contain all lines in pattern $ifnam"
		return
	}
	set f .rymsub
	if [Dlg_Create $f "INDEX SUBSTITUTION" "set pr_rymsub 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.save -text "Substitute" -command "set pr_rymsub 1" -bg $evv(EMPH)
		button $f.0.help -text "Help" -command "RymSubHelp" -bg $evv(HELP)
		button $f.0.quit -text "Abandon" -command "set pr_rymsub 0"
		pack $f.0.save $f.0.help -side left -padx 2
		pack $f.0.quit -side right
		pack $f.0 -side top -fill x -expand true

 		frame $f.0a
		button $f.0a.show -text "See Pattern & Substitution data" -command ShowPatternAndSubstitutionData
		pack $f.0a.show -side left
		pack $f.0a -side top -fill x -expand true -pady 2

		frame $f.1
		label $f.1.ll -text "Select Substitution File via \"Files\" Button" -fg $evv(SPECIAL)
		pack $f.1.ll -side left
		pack $f.1 -side top -pady 2 -fill x -expand true
		frame $f.2
		button $f.2.b  -text "Files" -command "FindPatternSubstitutionFiles 0"
		button $f.2.c  -text "Hilite" -command {FindPatternSubstitutionFiles 1; set pr_rymsub 0}
		entry $f.2.e -textvariable rym(subs) -width 32 -fg $readonlyfg -readonlybackground $readonlybg -state readonly
		pack $f.2.e $f.2.b $f.2.c -side left -padx 2
		pack $f.2 -side top -pady 2 -fill x -expand true -pady 2
		frame $f.3
		label $f.3.ll -text "Start line of substitution"
		entry $f.3.e -textvariable rym(substtline) -width 32
		pack $f.3.e $f.3.ll -side left -padx 2
		pack $f.3 -side top -fill x -expand true -pady 2
		frame $f.4
		label $f.4.ll -text "End line of substitution"
		entry $f.4.e -textvariable rym(subendline) -width 32
		pack $f.4.e $f.4.ll -side left -padx 2
		pack $f.4 -side top -fill x -expand true -pady 2
		frame $f.5
		label $f.5.ll -text "Output Filename"
		entry $f.5.e -textvariable rymsubfnam -width 32
		pack $f.5.e $f.5.ll -side left -padx 2
		pack $f.5 -side top -fill x -expand true -pady 2
		wm resizable $f 0 0
		bind .rymsub.3.e <Down> {focus .rymsub.4.e}
		bind .rymsub.4.e <Down> {focus .rymsub.5.e}
		bind .rymsub.5.e <Down> {focus .rymsub.3.e}
		bind .rymsub.3.e <Up> {focus .rymsub.5.e}
		bind .rymsub.4.e <Up> {focus .rymsub.3.e}
		bind .rymsub.5.e <Up> {focus .rymsub.4.e}
		bind $f <Escape> {set pr_rymsub 0}
		bind $f <Return> {set pr_rymsub 1}
	}
	set pr_rymsub 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_rymsub $f.3.e
	while {!$finished} {
		tkwait variable pr_rymsub
		if {$pr_rymsub} {
			if {![IsNumeric $rym(substtline)] || ![regexp {^[0-9]+$} $rym(substtline)] || ($rym(substtline) < 0)} {
				Inf "Invalid substitution- start line number ($rym(substtline))"
				continue
			}
			if {$rym(substtline) == 0} {
				set rym(substtline) 1
			}
			if {![IsNumeric $rym(subendline)] || ![regexp {^[0-9]+$} $rym(subendline)] || ($rym(subendline) < $rym(substtline))} {
				Inf "Invalid substitution-end line number  ($rym(subendline))"
				continue
			}
			if {$rym(substtline) > $rym(subendline)} {
				Inf "Incompatible start and end lines for substitution"
				continue
			}
			if {![ValidCDPRootname $rymsubfnam]} {
				continue
			}
			set ofnam [string tolower $rymsubfnam] 
			set stendofnam [file rootname $ofnam]
			append stendofnam _stend$evv(TEXT_EXT)
			append ofnam $evv(TEXT_EXT)
			set do_overwrite 0
			if {[file exists $ofnam]} {
				set msg "File $ofnam already exists : overwrite it ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				if {![CouetteAllowsDelete $ofnam]} {
					continue
				}
				if [catch {file delete -force $ofnam} in] {
					Inf "Cannot delete the existing file."
					continue
				} else {											;# Copy only takes place from Dirlist to Wkspace.
					DataManage delete $ofnam
					CouettePatchesDelete $ofnam
					DeleteFileFromSrcLists $ofnam					;# File created is a wkspace file.
					RemoveFromChosenlist $ofnam
					PurgeArray $ofnam
					DummyHistory $ofnam "OVERWRITTEN"
					set i [LstIndx $ofnam $wl]
					if {$i >= 0} {
						$wl delete $i
					}
				}
				set do_overwrite 1
			}
			if {$dostend && [file exists $stendofnam]} {
				if {!$do_overwrite} {
					set msg "File $stendofnam already exists : overwrite it ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
				}
				if {![CouetteAllowsDelete $stendofnam]} {
					continue
				}
				if [catch {file delete -force $stendofnam} in] {
					Inf "Cannot delete the existing file $stendofnam."
					continue
				} else {											;# Copy only takes place from Dirlist to Wkspace.
					DataManage delete $stendofnam
					CouettePatchesDelete $stendofnam
					DeleteFileFromSrcLists $stendofnam					;# File created is a wkspace file.
					set ftyp $pa($stendofnam,$evv(FTYP))
					RemoveFromChosenlist $stendofnam
					PurgeArray $stendofnam
					DummyHistory $stendofnam "OVERWRITTEN"
					set i [LstIndx $stendofnam $wl]
					if {$i >= 0} {
						$wl delete $i
					}
				}
			}
			set patternlines [lindex $rym(patterns) 0]
			if {![RymSubstitutionFileTest $rym(subs) load]} {
				continue
			}
			set OK 1
			catch {unset newidx}
			catch {unset substp}
			catch {unset sublin}
			foreach line $rym(substituter) {
				set subidx	[lindex $line 0]					;#	Index specified in substitution file
				set lineno	[lindex $line 1]					;#	Lineno specified in substitution file
				set zlineno $lineno	
				incr zlineno -1									;#	Lineno in 0 to N-1 frame
				lappend sublin $lineno
				lappend newidx [lindex $line 2]
				lappend substp [lindex $line 3]
				set thisline [lindex $patternlines $zlineno]	;#	The specified line in substitution pattern
				set idx [lindex $thisline 1]					;#	Index specified in the specified pattern-line
				if {$subidx != $idx} {
					Inf "Pattern line $lineno has index $idx : doesn't correspond to specified substitution index ($subidx)"
					set msg "Edit substitution data ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						set i [LstIndx $rym(subs) $wl]
						$wl selection clear 0 end
						$wl selection set $i
						set j [$wl index end]
						set ij [expr double($i)/double($j)]
						$wl yview moveto $ij
						set finished 1
					}
					set OK 0
					break
				}
			}
			if {!$OK} {
				continue
			}
			set cnt 0
			set nuindexes {}
			foreach lineno $sublin {						;#	Foreach lineno specified in substitution data(RANGE 1-N)
				set gotit 0
				foreach map $maps {							;#	Find in which map the line occurs (RANGE 1-N)
					foreach item $map {
						if {$item == $lineno} {
							set thismap $map
							set gotit 1
							break
						}
					}
					if {$gotit} {
						break
					}
				}
				if {!$gotit} {
					incr lineno
					Inf "Problem finding line $lineno in maps"
					return
				}
				set subcnt 0								;#	Count the substitutions made in this line
				set thisnuidx [lindex $newidx $cnt]			;#	Initial value of the new index
				set thissubstp [lindex $substp $cnt]		;#	Step at which new index is incremented
				lappend nuindexes $thisnuidx
				foreach lineno $thismap {
					set zlineno [expr $lineno - 1]			;#	lineno in range 0 to N-1
					if {$lineno < $rym(substtline)} {		;#	Read through map until we get to the lines to be substituted
						continue
					}
					if {$lineno <= $rym(subendline)} {		;#	If within range of lines to be substituted
						if {($subcnt > 0) && ([expr $subcnt % $thissubstp] == 0)} {
							incr thisnuidx					;#	If we've progressed by the incr-step, increment the new index value
							lappend nuindexes $thisnuidx
						}									;#	Get the pattern-line
						set thisline [lindex $patternlines $zlineno]
						set thisline [lreplace $thisline 1 1 $thisnuidx]						;#	Replace index in original line
						set patternlines [lreplace $patternlines $zlineno $zlineno $thisline]	;#	Replace line in pattern

						incr subcnt							;#	Count the index-substitutions made
					} else {
						break								;#	If beyond lines to be substituted, stop
					}
				}
				incr cnt
			}
			set len [llength $nuindexes]
			set len_less_one [expr $len - 1]
			set n 0
			set OK 1
			while {$n < $len_less_one} {
				set nui_n [lindex $nuindexes $n]
				set m $n
				incr m
				while {$m < $len} {
					set nui_m [lindex $nuindexes $m]
					if {$nui_n == $nui_m} {
						set msg "Substituted index values (e.g. $nui_n) are duplicated in different substitution streams: is this ok ??"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							set OK 0
							break
						}
					}	
					incr m
				}
				if {!$OK} {
					break
				}
				incr n
			}
			if {!$OK} {
				continue
			}
	
			if [catch {open $ofnam "w"} zit] {
				Inf "Cannot open output file $ofnam"
				continue
			}
			foreach line $patternlines {
				puts $zit $line
			}
			close $zit
			if {$dostend} {
				if [catch {file copy $stendifnam $stendofnam} zit] {
					Inf "Cannot generate corresponding stend file"
				} else {
					FileToWkspace $stendofnam 0 0 0 0 1
				}
			}
			FileToWkspace $ofnam 0 0 0 0 1
			Inf "File $ofnam is on the workspace"
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Get a file listing pattern-snndindexs-substitutiona

proc FindPatternSubstitutionFiles {hilite} {
	global evv rym pr_rymsubfiles sub_i readonlyfg readonlybg wl
	if {![LoadAppropriatePatternSubstitutionFiles]} {
		Inf "No appropriate files on workspace"
		return
	}
	if {$hilite} {
		foreach fnam $rym(subfiles) {
			lappend ilist [LstIndx $fnam $wl]
		}
		$wl selection clear 0 end
		foreach i $ilist {
			$wl selection set $i
		}
		set i [lindex $ilist 0]
		set j [$wl index end]
		set ij [expr double($i)/double($j)]
		$wl yview moveto $ij
		return
	}
	set f .rymsubfiles
	if [Dlg_Create $f "POSSIBLE SUBSTITUTION FILES" "set pr_rymsubfiles 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.save -text "Select" -command "set pr_rymsubfiles 1" -bg $evv(EMPH)
		button $f.0.quit -text "Abandon" -command "set pr_rymsubfiles 0"
		pack $f.0.save -side left -padx 4
		pack $f.0.quit -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Selected File"
		entry $f.1.e -textvariable sub_i -width 48 -fg $readonlyfg -readonlybackground $readonlybg -state readonly
		set sub_i ""
		pack $f.1.ll $f.1.e -side left -padx 2
		pack $f.1 -side top -fill x -expand true
		frame $f.2
		label $f.2.ll -text "Select file with mouse-click" -fg $evv(SPECIAL)
		Scrolled_Listbox $f.2.pp -width 64 -height 24 -selectmode single
		pack $f.2.ll $f.2.pp -side top -pady 2
		pack $f.2 -side top
		wm resizable $f 0 0
		bind .rymsubfiles.2.pp.list <ButtonRelease> {GetSubstitutionFile %y}
		bind $f <Escape> {set pr_rymsubfiles 0}
		bind $f <Return> {set pr_rymsubfiles 1}
	}
	.rymsubfiles.2.pp.list delete 0 end
	foreach fnam $rym(subfiles) {
		.rymsubfiles.2.pp.list insert end $fnam
	}
	if {[llength $rym(subfiles)] == 1} {
		set sub_i [lindex $rym(subfiles) 0]
	}
	set pr_rymsubfiles 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_rymsubfiles
	while {!$finished} {
		tkwait variable pr_rymsubfiles
		if {$pr_rymsubfiles} {
			if {[string length $sub_i] <= 0} {
				Inf "No file selected"
				continue
			}
			set rym(subs) $sub_i
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc GetSubstitutionFile {y} {
	global sub_i
	set i [.rymsubfiles.2.pp.list nearest $y]
	if {$i >= 0} {
		set sub_i [.rymsubfiles.2.pp.list get $i]
	}
}

#--- Search workspace for pattern-substitution files appropriate to current pattern

proc LoadAppropriatePatternSubstitutionFiles {} {
	global wl pa evv rym chlist
	foreach fnam [$wl get 0 end] {
		set ftyp $pa($fnam,$evv(FTYP))
		if {$ftyp & $evv(IS_A_TEXTFILE)} {
			lappend templist $fnam
		}
	}
	if {![info exists templist]} {
		return 0
	}
	foreach fnam $templist {
		if {[RymSubstitutionFileTest $fnam 0]} {
			lappend outlist $fnam
		}
	}
	if {![info exists outlist]} {
		return 0
	}
	set rym(subfiles) $outlist
	return 1
}

#--- Test textfile to see if it represents pattern snd-index substitutions
#
#	Format is A B C D
#	A	=  start-pattern-sndindex
#	B	=  line-no of item in pattern (to remove ambiguity where different lines use same sndindex in source pattern)
#	C	=  new-indices-start-at-number
#	D	=  substep
#
#	start-pattern-sndindex must exist in start pattern
#	starttime-in-pattern must lie at start or within pattern (before endtime of pattern)
#	end-time-in-pattern must lie at or after endtime of pattern
#	new-indices-start-at-number is reliant on the correct input : needs option to view highest inde used so far
#	substep is the number of src events before next substitution value is used
#	Need option to add (i.e. shufflup) values
#
#	NB new indices are added prefixwise e.g. 127 -> 1127 2127 3127 : 12 -> 1012 2012 3012 : 1 -> 1001 2001 3001
#

proc RymSubstitutionFileTest {fnam load} {
	global evv rym
	if {[string length $fnam] <= 0} {
		if {$load == 1} {
			Inf "No snd-index-sub file selected"
		}
		return 0
	}
	if {![file exists $fnam]} {
		if {$load} {
			Inf "Snd-index-sub file $fnam does not exist"
		}

		return 0
	}
	set ftyp [FindFileType $fnam]
	if {!($ftyp & $evv(IS_A_TEXTFILE))} {
		if {$load} {
			Inf "Snd-index-sub file $fnam is not a textfile"
		}
		return 0
	}
	if [catch {open $fnam "r"} zit] {
		if {$load} {
			Inf "Cannot open snd-index-sub file $fnam"
		}
		return 0
	}
	set linecnt 0
	set patternlines [lindex $rym(patterns) 0]
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		incr linecnt
		set line [split $line]
		set cnt 0
		set OK 1
		catch {unset nuline}
		set linenos {}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {![regexp {^[0-9]+$} $item] || ![IsNumeric $item]} {
				if {$load} {
					Inf "Snd-index-sub file $fnam contains non-integer data for one of 1st 4 values in line $linecnt"
				}
				set OK 0
				break
			}
			switch -- $cnt {
				0 {						;#	start-pattern-sndindex
					set thissndindex $item
				}
				1 {						;#	line-no
					if {($item < 1) || ($item > $rym(patcnt))} {
						set OK 0		;#	line must exist
						break
					}					;#	sndindex on line must be entered item here
					set zitem $item		;#	Line-no in 0 to N-1 range
					incr zitem -1




					set patternline [lindex $patternlines $zitem]
					set sndindexinpatternline [lindex $patternline 1]
					set plen [string length $sndindexinpatternline]
					if {$plen > 3} {
						set sndindexinpatternline [string range $sndindexinpatternline [expr $plen - 3] end]
						if {[string match [string index $sndindexinpatternline 0] "0"]} {
							set sndindexinpatternline [string range $sndindexinpatternline 1 end]
							if {[string match [string index $sndindexinpatternline 0] "0"]} {
								set sndindexinpatternline [string range $sndindexinpatternline 1 end]
							}
						}
					}
					if {$sndindexinpatternline != $thissndindex} {
						set OK 0
						break
					}					;#	line-nos cannot be duplicated
					if {[lsearch $linenos $item] >= 0} {
						set OK 0
						break
					}
					lappend linenos $item
				}
				3 {						;#	substep
					if {($item < 1) || ($item > $rym(patcnt))} {
						set OK 0
						break
					}
				}
			}
			lappend nuline $item
			incr cnt
		}
		if {!$OK} {
			break
		}
		if {$cnt < 4} {
			if {$load} {
				Inf "Insufficient entries (< 4) on line $linecnt in snd-index-sub file $fnam"
			}
			set OK 0
			break
		}
		lappend nulines $nuline
	}
	close $zit
	if {!$OK} {
		return 0
	}
	if {$load > 1} {
		set rym(substituter) $nulines
	}
	return 1
}

#--- Display data in rhythm pattern sndindex-substitution file

proc ShowSubstitutionData {} {
	global rym
	if {[string length $rym(subs)] <= 0} {
		return
	}
	RymSubstitutionFileTest $rym(subs) 2
}

#---- Show pattern and snd-index substitution data

proc ShowPatternAndSubstitutionData {} {
	global pr_patsub rym evv chlist
	set subs_selected 1
	if {![RymSubstitutionFileTest $rym(subs) 2]} {
		set subs_selected 0
	}
	if {![info exists rym(patterns)]} {
		return
	}
	set f .patsub
	if [Dlg_Create $f "RHYTHM PATTERN : INDEX SUBSTITUTION" "set pr_patsub 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.quit -text "Quit" -command "set pr_patsub 0"
		pack $f.0.quit -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		frame $f.1.1
		frame $f.1.2
		Scrolled_Listbox $f.1.1.pp1 -width 64 -height 48 -selectmode single
		pack $f.1.1.pp1 -side top -pady 2 -anchor n
		Scrolled_Listbox $f.1.2.lnk -width 64 -height 48 -selectmode single
		pack $f.1.2.lnk -side top -pady 2 -anchor n
		pack $f.1.1 $f.1.2 -side left -anchor n
		pack $f.1 -side top
		wm resizable $f 0 0
		bind $f <Escape> {set pr_patsub 0}
		bind $f <Return> {set pr_patsub 0}
	}
	.patsub.1.1.pp1.list delete 0 end
	set title "PATTERN ([file rootname [file tail [lindex $chlist 0]]])"
	.patsub.1.1.pp1.list insert end $title
	set linespace ""
	.patsub.1.1.pp1.list insert end $linespace
	set n 1
	foreach line [lindex $rym(patterns) 0] {
		set thisline "\[$n\] "
		if {$n < 100} {
			append thisline " "
		} 
		if {$n < 1000} {
			append thisline " "
		}
		append thisline $line
		.patsub.1.1.pp1.list insert end $thisline
		incr n
	}
	.patsub.1.2.lnk.list delete 0 end
	if {$subs_selected} {
		set title "SUBSTITUTION ([file rootname [file tail $rym(subs)]])"
		.patsub.1.2.lnk.list insert end $title
		set linespace ""
		.patsub.1.2.lnk.list insert end $linespace
		foreach line $rym(substituter) {
			.patsub.1.2.lnk.list insert end $line
		}
	} else {
		set title "NO SUBSTITUTION-FILE SELECTED"
		.patsub.1.2.lnk.list insert end $title
	}
	set pr_patsub 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_patsub
	tkwait variable pr_patsub
	My_Release_to_Dialog $f
	destroy $f
}

proc RymSubHelp {} {
	set msg "RHYTHM PATTERN SOUND-INDEX SUBSTITUTION\n"
	append msg "\n"
	append msg "Takes a rhythm pattern file, format \"Time  Sound-index  Level  Position\"             \n"
	append msg "and substitutes new snd-indeces for the existing ones.\n"
	append msg "\n"
	append msg "The substitution-data-file has data in the format \"A B C D\" on each line.\n"
	append msg "\n"
	append msg "A = a sound-index of an event in the existing pattern.\n"
	append msg "B = the line number of this item in the existing pattern.\n"
	append msg "C = The start index of the NEW numbers.\n"
	append msg "D = Step : a new number is substituted after every \"step\" occcurence\n"
	append msg "           of the evolving event (with sound-index \"A\")in the original pattern,\n"
	append msg "           with the new numbers incrementing progressively from \"C\".\n"
	append msg "\n"
	append msg "Note that ...\n"
	append msg "\n"
	append msg "(1)  In a rhythmic cell where 2 (or more) elements have the SAME index\n"
	append msg "        specifying A AND B ensures that\n"
	append msg "        only those elements evolving from the specified line will be recoloured\n"
	append msg "\n"
	append msg "(2)  All line numbers (B) in the substitution-data-file must be different.\n"
	append msg "\n"
	Inf $msg
}

proc RhythmicIndexModHelp {} {
	set msg "~~~~~~  RHYTHM PATTERN SOUND-INDEX MODIFICATION ~~~~~~\n"
	append msg "\n"
	append msg "Patternfiles contain rhythmic cells which repeat and evolve.\n"
	append msg "The sequence of all these cells is a \"pattern\".\n"
	append msg "\n"
	append msg "Once a rhythmic pattern (in a patternfile) or\n"
	append msg "a series of evolving patterns (patternfiles) have been made,\n"
	append msg "the sound-indeces in the pattern may be REPLACED,\n"
	append msg "by (a sequence of) alternative sound-indices.\n"
	append msg "\n"
	append msg "This can be done in two ways ....\n"
	append msg "\n"
	append msg "(1) RHYTHM PATTERN SOUND-INDEX SUBSTITUTION\n"
	append msg "\n"
	append msg "       Works with any pattern\n"
	append msg "       using index-subsitution instructions in a special type of file.\n"
	append msg "\n"
	append msg "(2) RHYTHM PATTERN SOUND-INDEX TRANSFER\n"
	append msg "\n"
	append msg "       Works with 2 patterns, where pattern 1 follows on from pattern 2\n"
	append msg "       (i.e. the final cell of pattern 1 is the same as the first cell of pattern 2).\n"
	append msg "       Starting with the 2 patterns with their original sound-indices,\n"
	append msg "       a recolouring is applied to pattern 1.\n"
	append msg "       The final cell of (the recoloured) pattern 1 is then \"snipped off\"\n"
	append msg "       and its sound-index information transferred to pattern 2.\n"
	append msg "       Pattern 2 can be recoloured, and so on.\n"
	append msg "\n"
	Inf $msg
}

#--- Substitute new sound-indices in existing pattern
#--- REDUNDANT if we can always use SNIP and TRANSFER

proc RhythmSoundSubstituteLink {} {
	global chlist evv pa rym rymlisubfnam pr_rymlisub wl wstk readonlyfg readonlybg
	if {![info exists chlist] || ([llength $chlist] < 4) || ([llength $chlist] > 5)} {
		set msg "Select\n"
		append msg "two \"time  index  level position\" format file\n"
		append msg "two map_files, one associated with each pattern"
		append msg "and (only where patterns do not have same number of map threads).\n"
		append msg "one associated link-file\n"
		return
	}
	set inlen [llength $chlist]
	set ifnam1 [lindex $chlist 0]
	set ftyp $pa($ifnam1,$evv(FTYP))
	if {![IsAListofNumbers $ftyp]} {
			Inf "File $ifnam1 does not have the correct \"time  index  level position\" format"
			return
	}
	set ifnam2 [lindex $chlist 1]
	set ftyp $pa($ifnam2,$evv(FTYP))
	if {![IsAListofNumbers $ftyp]} {
			Inf "File $ifnam2 does not have the correct \"time  index  level position\" format"
			return
	}
	set othermfnam [lindex $chlist 2]
	set ftyp $pa($othermfnam,$evv(FTYP))
	if {![IsAListofNumbers $ftyp]} {
			Inf "File $othermfnam does not have the correct map format"
			return
	}
	set mfnam [lindex $chlist 3]
	set ftyp $pa($mfnam,$evv(FTYP))
	if {![IsAListofNumbers $ftyp]} {
			Inf "File $mfnam does not have the correct map format"
			return
	}
	if {$inlen > 4} {
		set lfnam [lindex $chlist 4]
		set ftyp $pa($lfnam,$evv(FTYP))
		if {![IsAListofNumbers $ftyp]} {
				Inf "File $lfnam does not have the correct link format"
				return
		}
	}

	;#	OPEN FIRST PATTERN FILE

	if [catch {open $ifnam1 "r"} zit] {
		Inf "Cannot open file $ifnam1"
		return
	}
	set linecnt 0
	set lasttime -1
	catch {unset lines}
	catch {unset times}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		incr linecnt
		catch {unset nuline}
		set line [split $line]
		set cnt 0
		set OK 1
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			switch -- $cnt {
				0 {
					if {$linecnt == 1} {
						if {$item != 0.0} {
							Inf "Initial time in input data file $ifnam1 must be zero"
							set OK 0
							break
						}
					} elseif {$item < $lasttime} {
						Inf "Times ($lasttime $item) in input data file $ifnam1 do not increase at line $linecnt"
						set OK 0
						break
					}
					set lasttime $item	
					lappend times $item
				}
				1 {
					if {![regexp {^[0-9]+$} $item] || ![IsNumeric $item]} {
						Inf "Invalid sound-index value on line $linecnt of file $ifnam1"
						set OK 0
						break
					}
				}
				2 {
					if {($item < 0.0) || ($item > 1.0)} {
						Inf "Invalid level value on line $linecnt of file $ifnam1"
						set OK 0
						break
					}
				}
				3 {
					if {($item < 0.0) || ($item > 8.0)} {
						Inf "Invalid position value on line $linecnt of file $ifnam1"
						set OK 0
						break
					}
				}
			}					
			lappend nuline $item
			incr cnt
		}
		if {!$OK} {
			break
		}
		if {$cnt != 4} {
			Inf "Wrong number of values ($cnt) on line ($linecnt) of file $ifnam1: requires 4 values"
			set OK 0
			break
		}
		lappend lines $nuline
	}
	close $zit
	if {!$OK} {
		return
	}
	set rym(patterns)   [list $lines]
	set rym(patcnt1) [llength $lines]

	;#	OPEN SECOND PATTERN FILE

	if [catch {open $ifnam2 "r"} zit] {
		Inf "Cannot open file $ifnam2"
		return
	}
	set linecnt 0
	set lasttime -1
	catch {unset lines}
	catch {unset times}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		incr linecnt
		catch {unset nuline}
		set line [split $line]
		set cnt 0
		set OK 1
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			switch -- $cnt {
				0 {
					if {$linecnt == 1} {
						if {$item != 0.0} {
							Inf "Initial time in input data file $ifnam2 must be zero"
							set OK 0
							break
						}
					} elseif {$item < $lasttime} {
						Inf "Times ($lasttime $item) in input data file $ifnam2 do not increase at line $linecnt"
						set OK 0
						break
					}
					set lasttime $item	
					lappend times $item
				}
				1 {
					if {![regexp {^[0-9]+$} $item] || ![IsNumeric $item]} {
						Inf "Invalid sound-index value on line $linecnt of file $ifnam2"
						set OK 0
						break
					}
				}
				2 {
					if {($item < 0.0) || ($item > 1.0)} {
						Inf "Invalid level value on line $linecnt of file $ifnam2"
						set OK 0
						break
					}
				}
				3 {
					if {($item < 0.0) || ($item > 8.0)} {
						Inf "Invalid position value on line $linecnt of file $ifnam2"
						set OK 0
						break
					}
				}
			}					
			lappend nuline $item
			incr cnt
		}
		if {!$OK} {
			break
		}
		if {$cnt != 4} {
			Inf "Wrong number of values ($cnt) on line ($linecnt) of file $ifnam2: requires 4 values"
			set OK 0
			break
		}
		lappend lines $nuline
	}
	close $zit
	if {!$OK} {
		return
	}
	lappend rym(patterns) $lines
	set rym(patcnt2) [llength $lines]

#################

	;#	GET 1ST PATTERN MAPFILE DATA

	if [catch {open $othermfnam "r"} zit] {
		Inf "Cannot open file $othermfnam"
		return
	}
	set linecnt 0
	catch {unset lines}
	set mapvals {}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		incr linecnt
		catch {unset nuline}
		set line [split $line]
		set OK 1
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {![regexp {^[0-9]+$} $item] || ![IsNumeric $item] || ($item < 1)} {
				Inf "Invalid line-number on line $linecnt of map file $othermfnam"
				set OK 0
				break
			}
			if {[lsearch $mapvals $item] >= 0} {
				Inf "Line-number $item duplicated in map file $othermfnam"
				set OK 0
				break
			}
			lappend mapvals $item
			lappend nuline $item
		}
		if {!$OK} {
			break
		}
		lappend maps $nuline
	}
	close $zit
	if {!$OK} {
		return
	}

	if {[llength $mapvals] != $rym(patcnt1)} {
		set msg "Does pattern 1 have an end-marker element ?"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -default yes -message $msg]
		if {$choice == "yes"} {
			incr rym(patcnt1) -1
		}
		if {[llength $mapvals] != $rym(patcnt1)} {
			Inf "Number of map entries in file $othermfnam does not correspond to number of events in file $ifnam1"
			return
		}
	}
	set n 1
	while {$n <= $rym(patcnt1)} {
		set gotit 0
		foreach map $maps {
			foreach item $map {
				if {$item == $n} {
					set gotit 1
					break
				}
			}
			if {$gotit} {
				break
			}
		}
		if {!$gotit} {
			break
		}
		lappend mapends [lindex $map end]
		incr n
	}
	if {!$gotit} {
		Inf "Maps in $othermfnam do not contain all lines in pattern $ifnam1"
		return
	}
	set mapcnt1 $linecnt

#################

	;#	GET MAPFILE DATA FOR 2ND PATTERN

	if [catch {open $mfnam "r"} zit] {
		Inf "Cannot open file $mfnam"
		return
	}
	set linecnt 0
	catch {unset lines}
	set mapvals {}
	catch {unset maps}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		incr linecnt
		catch {unset nuline}
		set line [split $line]
		set OK 1
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {![regexp {^[0-9]+$} $item] || ![IsNumeric $item] || ($item < 1)} {
				Inf "Invalid line-number on line $linecnt of map file $mfnam"
				set OK 0
				break
			}
			if {[lsearch $mapvals $item] >= 0} {
				Inf "Line-number $item duplicated in map file $mfnam"
				set OK 0
				break
			}
			lappend mapvals $item
			lappend nuline $item
		}
		if {!$OK} {
			break
		}
		lappend maps $nuline
	}
	close $zit
	if {!$OK} {
		return
	}

	if {[llength $mapvals] != $rym(patcnt2)} {
		set msg "Does pattern 2 have an end-marker element ?"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -default yes -message $msg]
		if {$choice == "yes"} {
			incr rym(patcnt2) -1
		}
		if {[llength $mapvals] != $rym(patcnt2)} {
			Inf "No of map entries in file $mfnam does not correspond to number of events in file $ifnam2"
			return
		}
	}
	set n 1
	while {$n <= $rym(patcnt2)} {
		set gotit 0
		foreach map $maps {
			foreach item $map {
				if {$item == $n} {

					set gotit 1
					break
				}
			}
			if {$gotit} {
				break
			}
		}
		if {!$gotit} {
			break
		}
		incr n
	}
	if {!$gotit} {
		Inf "Maps in $mfnam do not contain all lines in pattern $ifnam2"
		return
	}
	set rym(maps) $maps
	set mapcnt2 $linecnt

	if {$mapcnt1 > $mapcnt2} {
		Inf "Cannot recolour from a larger pattern to a smaller pattern"
		return
	}

	set linkvals {}
	if {$inlen == 5} {

		;#	GET LINKFILE DATA

		if [catch {open $lfnam "r"} zit] {
			Inf "Cannot open file $lfnam"
			return
		}
		set linecnt 0
		catch {unset lines}
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			if {[string match [string index $line 0] ";"]} {
				continue
			}
			incr linecnt
			catch {unset nuline}
			set line [split $line]
			set cnt 0
			set OK 1
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				if {![regexp {^[0-9]+$} $item] || ![IsNumeric $item] || ($item < 1)} {
					Inf "Invalid line-number on line $linecnt of link file $lfnam"
					set OK 0
					break
				}
				if {$item > $mapcnt1} {
					if {$item != $mapcnt1 + 1} {		;#	Ignore map of last line
						Inf "Stream-number $item in link file $lfnam is not present in first map"
						set OK 0
						break
					}
				}
				incr cnt
			}
			if {$cnt > 1} {
				Inf "Too many entries on line $linecnt in link file $lfnam"
				set OK 0
				break
			}
			lappend linkvals $item
			incr linecnt
		}
		close $zit
		if {!$OK} {
			return
		}
	} else {		;#	IF NO LINK FILE SUPPLIED ,ASSUME BOTH PATTERNS HAVE SAME COUNT OF EVENT-STREAMS

		if {$mapcnt1 != $mapcnt2} {
			Inf "If no linkfile is supplied, input patterns must have same number of mapped streams"
			return
		}
		set n 1
		while {$n <= $mapcnt1} {
			lappend linkvals $n
		}			
	}
	set rym(linkvals) $linkvals

	set f .rymlisub
	if [Dlg_Create $f "INDEX LINK SUBSTITUTION" "set pr_rymlisub 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.save -text "Link" -command "set pr_rymlisub 1" -bg $evv(EMPH)
		button $f.0.quit -text "Abandon" -command "set pr_rymlisub 0"
		pack $f.0.save -side left
		pack $f.0.quit -side right
		pack $f.0 -side top -fill x -expand true

 		frame $f.0a
		button $f.0a.show -text "See Patterns, Maps & Linking data" -command ShowPatternsMapsAndLinks
		pack $f.0a.show -side left
		pack $f.0a -side top -fill x -expand true -pady 2

		frame $f.1
		label $f.1.ll -text "Output Filename"
		entry $f.1.e -textvariable rymlisubfnam -width 32
		pack $f.1.e $f.1.ll -side left -padx 2
		pack $f.1 -side top -fill x -expand true -pady 2
		wm resizable $f 0 0
		bind $f <Escape> {set pr_rymlisub 0}
		bind $f <Return> {set pr_rymlisub 1}
	}
	set pr_rymlisub 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_rymlisub $f.1.e
	while {!$finished} {
		tkwait variable pr_rymlisub
		if {$pr_rymlisub} {
			if {![ValidCDPRootname $rymlisubfnam]} {
				continue
			}
			set ofnam [string tolower $rymlisubfnam] 
			append ofnam $evv(TEXT_EXT)
			if {[file exists $ofnam]} {
				set msg "File $ofnam already exists : overwrite it ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				if {![CouetteAllowsDelete $ofnam]} {
					continue
				}
				if [catch {file delete -force $ofnam} in] {
					Inf "Cannot delete the existing file."
					continue
				} else {											;# Copy only takes place from Dirlist to Wkspace.
					DataManage delete $ofnam
					CouettePatchesDelete $ofnam
					DeleteFileFromSrcLists $ofnam					;# File created is a wkspace file.
					RemoveFromChosenlist $ofnam
					PurgeArray $ofnam
					DummyHistory $ofnam "OVERWRITTEN"
					set i [LstIndx $ofnam $wl]
					if {$i >= 0} {
						$wl delete $i
					}
				}
			}
			set pat1 [lindex $rym(patterns) 0]
			set pat2 [lindex $rym(patterns) 1]
			set map2stream 0
			set OK 1
			foreach map1stream $rym(linkvals) {						;#	Find stream in first map assocd with stream in 2nd
				set zmap1stream [expr $map1stream - 1]				;#	Streams(=lines) numbered from 1: indexing lines counts from zero
				set thismapend [lindex $mapends $zmap1stream]		;#	Find lastline in that stream in 1st map
				set iline [lindex $pat1 [expr $thismapend - 1]]		;#	Get the line in 1st pattern
				set iidx  [lindex $iline 1]							;#	Get index in first pattern
				set srcidx $iidx									;#	Get base index of this
				if {$srcidx > 999} {
					set ilen [string length $iidx]
					set srcidx [string range $iidx [expr $ilen - 3] end]
					if {[string match [string index $srcidx 0] "0"]} {
						set srcidx [string range $srcidx 1 end]
						if {[string match [string index $srcidx 0] "0"]} {
							set srcidx [string range $srcidx 1 end]
						}
					}
				}
				set thismap2 [lindex $rym(maps) $map2stream]		;#	Get associated 2nd map
				foreach lineno $thismap2 {							;#	Look at every stream(=line) in 2nd map
					set zlineno [expr $lineno - 1]					;#	Streams(=lines) numbered from 1: indexing lines counts from zero
					set oline [lindex $pat2 $zlineno]				;#	Get line in 2nd pattern
					set oidx  [lindex $oline 1]						;#	Get index in 2nd pattern
					if {$oidx != $srcidx} {
						Inf "Map snd-indices do not correspond ($srcidx $oidx) in 2nd mapstream [expr $map2stream + 1]"
						set OK 0
						break
					}
					set oline [lreplace $oline 1 1 $iidx]			;#	Replace index in 2nd-pattern-line with (new) index from 1st
					set pat2 [lreplace $pat2 $zlineno $zlineno $oline]	;#	Replace line in pattern2
				}
				if {!$OK} {
					break
				}
				incr map2stream 
			}
			if {!$OK} {
				continue
			}
			if [catch {open $ofnam "w"} zit] {
				Inf "Cannot open output file $ofnam"
				continue
			}
			foreach line $pat2 {
				puts $zit $line
			}
			close $zit
			FileToWkspace $ofnam 0 0 0 0 1
			Inf "File $ofnam is on the workspace"
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- Show pattern and snd-index substitution data

proc ShowPatternsMapsAndLinks {} {
	global pr_patsubli rym evv chlist
	set subs_selected 1
	if {![info exists rym(patterns)]} {
		return
	}
	set f .patsubli
	if [Dlg_Create $f "RHYTHM PATTERN : INDEX LINK SUBSTITUTION" "set pr_patsubli 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.quit -text "Quit" -command "set pr_patsubli 0"
		pack $f.0.quit -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		frame $f.1.1
		frame $f.1.2
		frame $f.1.3
		frame $f.1.4
		Scrolled_Listbox $f.1.1.pp1 -width 50 -height 48 -selectmode single
		pack $f.1.1.pp1 -side top -pady 2 -anchor n
		Scrolled_Listbox $f.1.2.pp2 -width 50 -height 48 -selectmode single
		pack $f.1.2.pp2 -side top -pady 2 -anchor n
		Scrolled_Listbox $f.1.3.map -width 50 -height 48 -selectmode single
		pack $f.1.3.map -side top -pady 2 -anchor n
		Scrolled_Listbox $f.1.4.lnk -width 24 -height 48 -selectmode single
		pack $f.1.4.lnk -side top -pady 2 -anchor n
		pack $f.1.1 $f.1.2 $f.1.3 $f.1.4 -side left -anchor n
		pack $f.1 -side top
		wm resizable $f 0 0
		bind $f <Escape> {set pr_patsubli 0}
		bind $f <Return> {set pr_patsubli 0}
	}
	.patsubli.1.1.pp1.list delete 0 end
	set title "PATTERN 1 ([file rootname [file tail [lindex $chlist 0]]])"
	.patsubli.1.1.pp1.list insert end $title
	set linespace ""
	.patsubli.1.1.pp1.list insert end $linespace
	set n 1
	foreach line [lindex $rym(patterns) 0] {
		set thisline "\[$n\] "
		if {$n < 100} {
			append thisline " "
		} 
		if {$n < 1000} {
			append thisline " "
		}
		append thisline $line
		.patsubli.1.1.pp1.list insert end $thisline
		incr n
	}
	set title "PATTERN 2 ([file rootname [file tail [lindex $chlist 1]]])"
	.patsubli.1.2.pp2.list insert end $title
	set linespace ""
	.patsubli.1.2.pp2.list insert end $linespace
	set n 1
	foreach line [lindex $rym(patterns) 1] {
		set thisline "\[$n\] "
		if {$n < 100} {
			append thisline " "
		} 
		if {$n < 1000} {
			append thisline " "
		}
		append thisline $line
		.patsubli.1.2.pp2.list insert end $thisline
		incr n
	}
	.patsubli.1.3.map.list delete 0 end
	set title "MAP OF FILE 2 ([file rootname [file tail [lindex $chlist 3]]])"
	.patsubli.1.3.map.list insert end $title
	set linespace ""
	.patsubli.1.3.map.list insert end $linespace
	foreach line $rym(maps) {
		.patsubli.1.3.map.list insert end $line
	}

	.patsubli.1.4.lnk.list delete 0 end
	set title "LINK ([file rootname [file tail [lindex $chlist 4]]])"
	.patsubli.1.4.lnk.list insert end $title
	set linespace ""
	.patsubli.1.4.lnk.list insert end $linespace
	set n 1
	foreach line $rym(linkvals) {
		set thisline "\[$n\] "
		append thisline $line
		.patsubli.1.4.lnk.list insert end $thisline
	}
	set pr_patsubli 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_patsubli
	tkwait variable pr_patsubli
	My_Release_to_Dialog $f
	destroy $f
}

#---- Create new rhythmic cell by snipping off final cell of existing pattern

proc RhythmSnip {} {
	global chlist wl pa evv pr_rhysnip fnam_rhysnip wstk

	if {![info exists chlist] || ([llength $chlist] != 1)} {
		Inf "Select one rhythm-pattern textfile, for which corresponding \"stend\" data file exist"
		return
	}
	set fnam [lindex $chlist 0]
	set linesets [TestPatternFiles]
	if {[llength $linesets] != 1} {
		return
	}
	set inlines [lindex $linesets 0]

	set stendfnam [file rootname $fnam]
	append stendfnam "_stend" $evv(TEXT_EXT)
	if {![file exists $stendfnam]} {
		Inf "Corresponding \"stend\" data file ($stendfnam) for $fnam does not exist"
		return
	}
	set lastcelldata [GetLastCellData $stendfnam]
	if {[llength $lastcelldata] != 2} {
		return
	}
	set stttime [lindex $lastcelldata 0]
	set endtime [lindex $lastcelldata 1]

	set f .rhysnip
	if [Dlg_Create  $f "SNIP-OFF FINAL CELL OF RHYTHMIC PATTERN" "set pr_rhysnip 0" -width 64 -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.ok -text "Snip" -command "set pr_rhysnip 1" -width 8
		button $f.0.ab -text "Abandon" -command "set pr_rhysnip 0" -width 8
		pack $f.0.ok -side left
		pack $f.0.ab -side right
		pack $f.0 -side top -pady 1 -fill x -expand true
		frame $f.1
		label $f.1.ll -text "New Rhythmic Cell Name"
		entry $f.1.e -textvariable fnam_rhysnip -width 48
		pack $f.1.e $f.1.ll -side left
		pack $f.1 -side top -pady 2
		bind $f <Escape> {set pr_rhysnip 0}
		bind $f <Return> {set pr_rhysnip 1}
	}
	set finished 0
	set pr_rhysnip 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_rhysnip $f.1.e
	while {!$finished} {
		tkwait variable pr_rhysnip
		if {$pr_rhysnip} {

			if {![ValidCDPRootname $fnam_rhysnip]} {
				continue
			}
			set ofnam [string tolower $fnam_rhysnip] 
			append ofnam $evv(TEXT_EXT)
			if {[file exists $ofnam]} {
				set msg "File $ofnam already exists : overwrite it ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				if {![CouetteAllowsDelete $ofnam]} {
					continue
				}
				if [catch {file delete -force $ofnam} in] {
					Inf "Cannot delete the existing file."
					continue
				} else {											;# Copy only takes place from Dirlist to Wkspace.
					DataManage delete $ofnam
					CouettePatchesDelete $ofnam
					DeleteFileFromSrcLists $ofnam					;# File created is a wkspace file.
					RemoveFromChosenlist $ofnam
					PurgeArray $ofnam
					DummyHistory $ofnam "OVERWRITTEN"
					set i [LstIndx $ofnam $wl]
					if {$i >= 0} {
						$wl delete $i
					}
				}
			}
			catch {unset nulines}
			foreach line $inlines {
				set thistime [lindex $line 0]
				if {$thistime >= $stttime} {
					lappend nulines $line
				}
			}
			if {![info exists nulines]} {
				Inf "No data found in source pattern at specified final-cell times"
				continue
			}
			set len [llength $nulines]
			set n 0
			while {$n < $len} {
				set line [lindex $nulines $n]
				set thistime [lindex $line 0]
				set thistime [expr $thistime - $stttime]
				if {$thistime < 0.0} {
					set thistime 0.0	;#	SAFETY
				}
				set line [lreplace $line 0 0 $thistime]
				set nulines [lreplace $nulines $n $n $line]
				incr n
			}
			set firstline [lindex $nulines 0]
			set firsttime [lindex $firstline 0]
			if {$firsttime > 0.0} {		;#	If pattern's initial line NOT at zero, insert dummy start-line
				set firstline [list 0.0 0 0 0]
				set nulines [linsert $nulines 0 $firstline]
			}
			if [catch {open $ofnam "w"} zit] {
				Inf "Cannot open output data file $ifnam"
				continue
			}			
			foreach line $nulines {
				puts $zit $line
			}
			close $zit
			FileToWkspace $ofnam 0 0 0 0 1
			Inf "File $ofnam is on the workspace"
			set hline "SNIP OFF END OF [file rootname $fnam] TO MAKE [file rootname $ofnam]"
			DoRhythmHistory $hline
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc RhythmConcat {} {
	global chlist wl pa evv pr_rhyconcat fnam_rhyconcat wstk

	if {![info exists chlist] || ([llength $chlist] < 2)} {
		Inf "Select at least two soundfiles, for which corresponding \"stend\" data files exist"
		return
	}
	set cnt 0
	foreach fnam $chlist {
		set ftyp $pa($fnam,$evv(FTYP))
		if {$ftyp != $evv(SNDFILE)} {
			Inf "File $fnam is not a soundfile"
			return
		}
		if {$cnt == 0} {
			set srate $pa($fnam,$evv(SRATE))
			set chans $pa($fnam,$evv(CHANS))
		} else {
			if {$srate != $pa($fnam,$evv(SRATE))} {
				Inf "File $fnam has different sample rate to previous files"
				return
			}
			if {$chans != $pa($fnam,$evv(CHANS))} {
				Inf "File $fnam has different channel count to previous files"
				return
			}
		}
		lappend fnams $fnam
		set stendfnam [file rootname $fnam]
		append stendfnam "_stend" $evv(TEXT_EXT)
		if {![file exists $stendfnam]} {
			Inf "Timing data file $stendfnam does not exist for soundfile $fnam"
			return
		}
		lappend stenddata $stendfnam
		incr cnt
	}
	set f .rhyconcat
	if [Dlg_Create  $f "CONCATENATE PATTERNS" "set pr_rhyconcat 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.ok -text "Generate Mixfile" -command "set pr_rhyconcat 1" -width 15
		button $f.0.h -text "Help" -command RhyconcatHelp -bg $evv(HELP)
		button $f.0.ab -text "Abandon" -command "set pr_rhyconcat 0" -width 15
		pack $f.0.ok $f.0.h -side left -padx 2
		pack $f.0.ab -side right
		pack $f.0 -side top -pady 1 -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Mixfile Name"
		entry $f.1.e -textvariable fnam_rhyconcat -width 48
		pack $f.1.e $f.1.ll -side left
		pack $f.1 -side top -pady 2
		bind $f <Escape> {set pr_rhyconcat 0}
		bind $f <Return> {set pr_rhyconcat 1}
	}
	set finished 0
	set pr_rhyconcat 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_rhyconcat $f.1.e
	while {!$finished} {
		tkwait variable pr_rhyconcat
		if {$pr_rhyconcat} {
			if {[string length $fnam_rhyconcat] <= 0} {
				Inf "No output filename entered"
				continue
			}
			if {![ValidCDPRootname $fnam_rhyconcat]} {
				continue
			}
			set ofnam [string tolower $fnam_rhyconcat] 
			append ofnam [GetTextfileExtension mmx]
			if {[file exists $ofnam]} {
				set msg "File $ofnam already exists : overwrite it ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				if {![CouetteAllowsDelete $ofnam]} {
					continue
				}
				if [catch {file delete -force $ofnam} in] {
					Inf "Cannot delete the existing file."
					continue
				} else {											;# Copy only takes place from Dirlist to Wkspace.
					DataManage delete $ofnam
					CouettePatchesDelete $ofnam
					DeleteFileFromSrcLists $ofnam					;# File created is a wkspace file.
					RemoveFromChosenlist $ofnam
					PurgeArray $ofnam
					DummyHistory $ofnam "OVERWRITTEN"
					set i [LstIndx $ofnam $wl]
					if {$i >= 0} {
						$wl delete $i
					}
				}
			}
			set len [llength $stenddata]
			set filecnt 0
			set OK 1
			set sum 0.0
			while {$filecnt < $len} {
				set stendfnam [lindex $stenddata $filecnt]
				if [catch {open $stendfnam "r"} zit] {
					Inf "Cannot open data file $stendfnam"
					set OK 0
					break
				}
				catch {unset dur}
				while {[gets $zit line] >= 0} {
					set line [string trim $line]
					if {[string length $line] <= 0} {
						continue
					}
					if {[string match [string index $line 0] ";"]} {
						continue
					}
					set line [split $line]
					set cnt 0
					set OK 1
					foreach item $line {
						set item [string trim $item]
						if {[string length $item] <= 0} {
							continue
						}
						if {![IsNumeric $item] || ($item < 0.0)} {
							Inf "Invalid data ($item) in file $stendfnam"
							set OK 0
							break
						}
						switch -- $cnt {
							0 {
								set lasttime $item
							}
							1 {
								if {$item <= $lasttime} {
									Inf "Invalid time order in file $stendfnam"
									set OK 0
									break
								}
								set dur $item
							} 
							default {
								Inf "Too many entries in file $stendfnam"
								set OK 0
								break
							}
						}
						incr cnt
					}
					if {!$OK} {
						break
					}
				}
				close $zit
				if {![info exists dur] || !$OK} {
					break
				}											;#	Replace datafile names by file-durations contained therein
				set sum [expr $sum + $dur]
				set stenddata [lreplace $stenddata $filecnt $filecnt $sum]
				incr filecnt
			}
			if {!$OK} {
				continue
			}
			set stenddata [concat 0.0 $stenddata]			;#	Add zero-time to start of file durations
			set stenddata [lreplace $stenddata end end]		;#	Delete not-needed final duration
			

	
			if [catch {open $ofnam "w"} zit] {
				Inf "Cannot open file $ofnam to write mix data"
				continue
			}
			puts $zit $chans
			foreach fnam $fnams time $stenddata {
				set line [list $fnam $time $chans]
				set n 1
				while {$n <= $chans} {
					set rout $n
					append rout ":" $n
					lappend line $rout 1
					incr n
				}
				puts $zit $line
			}
			close $zit
			FileToWkspace $ofnam 0 0 0 0 1
			Inf "File $ofnam is on the workspace"
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc RhyconcatHelp {} {
	set msg "RHYTHM-PATTERN SOUND-OUTPUT CONCATENATION\n"
	append msg "\n"
	append msg "Expects a list of soundfiles,\n"
	append msg "ALL of which are the sound-outputs from rhythm-pattern generation,\n"
	append msg "and all of which will have the same number of channels.\n"
	append msg "\n"
	append msg "Also expects the corresponding \"_stend\" data-files to exist.\n"
	append msg "\n"
	append msg "For the soundfile \"thissnd.wav\", the data should be stored\n"
	append msg "in the file named \"thissnd_stend.txt\"\n"
	append msg "and the corresponding sound and data files must be in the SAME DIRECTORY.\n"
	append msg "\n"
	append msg "The operation of the process relies on a strict naming convention\n"
	append msg "where timing data file \"xxx_stend.txt\"\n"
	append msg "is generated alongside rhythm data file \"xxx.txt\"\n"
	append msg "which in turn creates mixdata file \"xxx.mmx\"\n"
	append msg "which generates soundfile \"xxx.wav\"\n"
	Inf $msg
}

#------ Read data from a "stend" file and output it.

proc GetLastCellData {stendfnam} {

	if [catch {open $stendfnam "r"} zit] {
		Inf "Cannot open file $stendfnam"
		return {}
	}
	set linecnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		set cnt 0
		set OK 1
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {![IsNumeric $item] || ($item < 0.0)} {
				Inf "Invalid data in file $stendfnam"
				set OK 0
				break
			}
			switch -- $cnt {
				0 {
					set stttime $item
				}
				1 {
					set endtime $item
					if {$endtime <= $stttime} {
						Inf "Invalid data in file $stendfnam"
						set OK 0
						break
					}
				}
				default {
					Inf "Too much data in file $stendfnam"
					set OK 0
					break
				}
			}
			if {!$OK} {
				break
			}
			incr cnt
		}
		if {!$OK || ($cnt != 2)} {
			break
		}
		incr linecnt						
		if {$linecnt > 1} {
			set OK 0
			break
		}
	}
	close $zit
	if {!$OK} {
		return {}
	}
	set stendata [list $stttime $endtime]
	return $stendata
}

#------- Take an exisiting rhythmic pattern with FIXED colours (no index substitution yet used)
#------- And recolour it in line with the cell presented

proc ForwardRecolorRhythmPattern {} {
	global chlist wl pa evv pr_recolor fnam_recolor wstk

	if {![info exists chlist] || ([llength $chlist] < 2)} {
		Inf "Select at least two rhythm pattern files, first corresponding to start cell of second"
		return
	}
	set ifnam [lindex $chlist 1]

	set dolink 0
	set linkifnam [file rootname $ifnam]
	append linkifnam _link$evv(TEXT_EXT)

	if {[file exists $linkifnam]} {
		if [catch {open $linkifnam "r"} zit] {
			Inf "Cannot open link file to read link data"
			return
		}
		;#	GET LINKFILE DATA

		if [catch {open $linkifnam "r"} zit] {
			Inf "Cannot open file $linkifnam"
			return
		}
		set linecnt 0
		set contracted 0
		catch {unset lines}
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			if {[string match [string index $line 0] ";"]} {
				if {[string first "LINE-LINKAGE FROM END" $line] == 1} {
					set contracted 1
					break
				} else {
					continue
				}
			}
			incr linecnt
			catch {unset nuline}
			set line [split $line]
			set cnt 0
			set OK 1
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				if {![regexp {^[0-9]+$} $item] || ![IsNumeric $item] || ($item < 1)} {
					Inf "Invalid line-number on line $linecnt of link file $linkifnam"
					set OK 0
					break
				}
				incr cnt
			}
			if {$cnt > 1} {
				Inf "Too many entries on line $linecnt in link file $linkifnam"
				set OK 0
				break
			}
			lappend linkvals $item
			incr linecnt
		}
		close $zit
		if {!$OK} {
			return
		}
		if {!$contracted} {
			set dolink [expr [llength $linkvals] - 1]	;#	set "dolink" to length of links-data LESS final (end-marker) link
		}
	} 

	set mapifnam [file rootname $ifnam]
	append mapifnam _map$evv(TEXT_EXT)

	set ismap 0
	if {![file exists $mapifnam]} {
		set msg "Map file associated with [file tail $ifnam] does not exist: proceed anyway ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		}
	} else {
		set ismap 1
	}

	set linesets [TestPatternFiles]
	if {[llength $linesets] != 2} {
		return
	}
	set recolpat [lindex $linesets 0]
	set goalpat  [lindex $linesets 1]

	set recolen [llength $recolpat]
	set goallen [llength $goalpat]

	if {$goallen < $recolen} {
		Inf "The first pattern should be the shorter, recoloured, pattern"
		return
	}

	set stendifnam [file rootname $ifnam]
	append stendifnam _stend$evv(TEXT_EXT)

	set isstend 0
	if {![file exists $stendifnam]} {
		set msg "Final-cell-time data-file $stendifnam for rhythm pattern $ifnam does not exist: proceed anyway ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		}
	} else {
		set isstend 1
	}
	incr recolen -1		;#	Ignore final end-markers
	incr goallen -1
	set n 0
	while {$n < $recolen} {
		set line [lindex $recolpat $n]
		set color [lindex $line 1]
		lappend recol_colors $color
		incr n
	}
	if {$dolink} {
		set n 0
		while {$n < $dolink} {							;#	For each line in (goal) large pattern in (expanding)pattern file,
			set val [lindex $linkvals $n]				;#	Get line in (original) small pattern from which it originates
			incr val -1									;#	Change from 1toN (line numbering in files) to 0toN-1 frame for indexing lines
			set thiscolor [lindex $recol_colors $val]	;#	Get new colour of that line	
			lappend link_colors $thiscolor				;#	Append this color to a list of new colours for the large pattern
			incr n
		}
		set recol_colors $link_colors					;#	Replace the original (small) recoloring scheme by the expanded (large) recoloring scheme
		set recolen [llength $recol_colors]
	}
	set n 0
	while {$n < $recolen} {								;#	Get the current colours of the first rhythm-cell in the patternfile.
		set line [lindex $goalpat $n]
		set color [lindex $line 1]
		lappend goalpat_colors $color
		incr n
	}

	while {$n < $goallen} {								;#	For rest of pattern, check no other colours used
		set line [lindex $goalpat $n]
		set color [lindex $line 1]
		if {[lsearch $goalpat_colors $color] < 0} {
			Inf "Large pattern has more snd-indeces than those found in first $recolen lines (e.g. $color)"
			return
		}
		incr n
	}
	set n 0
	while {$n < $goallen} {
		set line [lindex $goalpat $n]					;#	For every line in the patternfile
		set color [lindex $line 1]						;#	find its original colour
		set indx [lsearch $goalpat_colors $color]		;#	Find which colour it corresponds to in the first (goal-pattern) cell
		set color [lindex $recol_colors $indx]			;#	Find the new colour being assigned to that cell
		set line [lreplace $line 1 1 $color]			;#	Replace the colour in the line by the new color
		set goalpat [lreplace $goalpat $n $n $line]		;#	Replace the goal-pattern line by its recolored version
		incr n
	}
	set f .recolor
	if [Dlg_Create  $f "TRANSFER RECOLOUR" "set pr_recolor 0" -width 64 -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.ok -text "Recolour" -command "set pr_recolor 1" -width 15
		button $f.0.h -text "Help" -command RhyrecolorHelp -bg $evv(HELP)
		button $f.0.ab -text "Abandon" -command "set pr_recolor 0" -width 15
		pack $f.0.ok $f.0.h -side left -padx 2
		pack $f.0.ab -side right
		pack $f.0 -side top -pady 1 -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Mixfile Name"
		entry $f.1.e -textvariable fnam_recolor -width 48
		pack $f.1.e $f.1.ll -side left
		pack $f.1 -side top -pady 2
		bind $f <Escape> {set pr_recolor 0}
		bind $f <Return> {set pr_recolor 1}
	}
	set finished 0
	set pr_recolor 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_recolor $f.1.e
	while {!$finished} {
		tkwait variable pr_recolor
		if {$pr_recolor} {
			if {[string length $fnam_recolor] <= 0} {
				Inf "No output filename entered"
				continue
			}
			if {![ValidCDPRootname $fnam_recolor]} {
				continue
			}
			catch {unset testofnams}
			set ofnam [string tolower $fnam_recolor] 
			if {$isstend} {
				set stendofnam [file rootname $ofnam]
				append stendofnam _stend$evv(TEXT_EXT)
				lappend testofnams $stendofnam
			}
			if {$ismap} {
				set mapofnam [file rootname $ofnam]
				append mapofnam _map$evv(TEXT_EXT)
				lappend testofnams $mapofnam
			}
			append ofnam $evv(TEXT_EXT)
			lappend testofnams $ofnam
			set OK 1
			foreach fnam $testofnams {
				if {[file exists $fnam]} {
					Inf "File $fnam already exists : please choose a diffent filename"
					set OK 0
					break
				}
			}
			if {!$OK} {
				continue
			}
			if [catch {open $ofnam "w"} zit] {
				Inf "Cannot open file $ofnam to write recoloured pattern"
				continue
			}
			foreach line $goalpat {
				puts $zit $line
			}
			close $zit
			if {$isstend} {
				if [catch {file copy $stendifnam $stendofnam} zit] {
					set msg "Cannot copy file $stendifnam to $stendofnam: do this now outside the loom, before proceeding" 
				} 
				catch {FileToWkspace $stendofnam 0 0 0 0 1}
			}
			if {$ismap} {
				if [catch {file copy $mapifnam $mapofnam} zit] {
					set msg "Cannot copy file $mapifnam to $mapofnam: do this now outside the loom, before proceeding" 
				} 
				catch {FileToWkspace $mapofnam 0 0 0 0 1}
			}
			FileToWkspace $ofnam 0 0 0 0 1
			Inf "File $ofnam is on the workspace"
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc RhyrecolorHelp {} {
	set msg "RHYTHM PATTERN SOUND-INDEX TRANSFER\n"	
	append msg "\n"
	append msg "Patterns can have there sound indeces progressively changed\n"
	append msg "by index-substitution.\n"
	append msg "\n"
	append msg "If 2 patterns are to succeed each other in a final mix,\n"
	append msg "AND the 2nd pattern begins with the same cell that ended the 1st pattern,\n"
	append msg "This process allows the recolouring applied to pattern 1\n"
	append msg "to be carried over into pattern 2.\n"
	append msg "\n"
	append msg "The final cell of the first (recoloured) pattern can be detached\n"
	append msg "(using \"SNIP\") and this cell used to recolour pattern 2\n"
	append msg "consistently with the new end-colours of pattern 1.\n"
	append msg "\n"
	append msg "The 2nd pattern can then itself be progressivly recoloured, and so on.\n"
	append msg "\n"
	append msg "This process requires a snipped cell (from the recoloured pattern-1)\n"
	append msg "and a full pattern (pattern-2) as its inputs,\n"
	append msg "in that order.\n"
	append msg "\n"
	append msg "Where pattern-2 involves an increase in cell-size,\n"
	append msg "there will be a link file associated with pattern2 (patname_link.txt)\n"
	append msg "which will be picked up and used automatically,\n"
	append msg "so that the entries in patterns 1 and 2 tally correctly.\n"
	append msg "\n"
	append msg "Where pattern-2 involves a decrease in cell-size,\n"
	append msg "the snipped final-cell will need to be \"Squeezed\"\n"
	append msg "to reduce it to the original smaller-cell format.\n"
	append msg "\n"
	append msg "Alternatively \"RHYTHM PATTERN INDEX-SUBSTITUTION\" can be used directly.\n"
	Inf $msg
}

proc Rhystory {} {
	global rhystory rhyhist rhyhistlist pr_rhystory rhystcur rhystip rhystdisplay rhystsel rhystnew readonlyfg readonlybg rhystsearch rhyselected
	global wstk evv 

	set f .rhyhistory
	if [Dlg_Create  $f "MANAGE RHYTHM HISTORIES" "set pr_rhystory 0" -width 64 -borderwidth $evv(SBDR)] {
		frame $f.0
		label $f.0.tit -text "START & END HISTORIES   " -width 24 -fg $evv(SPECIAL)
		radiobutton $f.0.1 -variable rhystip -text "Start New History"	 -value 1 -command "set pr_rhystory 1" -width 24
		radiobutton $f.0.2 -variable rhystip -text "End Current History" -value 2 -command "set pr_rhystory 1" -width 24
		label $f.0.ll -text "  Name for New History  "
		entry $f.0.e -textvariable rhystnew -width 32
		button $f.0.ab -text "Quit" -command "set pr_rhystory 0" -width 10
		pack $f.0.tit $f.0.1 $f.0.2 $f.0.ll $f.0.e -side left
		pack $f.0.ab -side right
		pack $f.0 -side top -anchor w -pady 1 -fill x -expand true
		frame $f.0b -bg black
		pack $f.0b -side top -fill x -expand true -pady 8
		frame $f.00
		label $f.00.tit2 -text "SELECTED HISTORY        " -width 24 -fg $evv(SPECIAL)
		radiobutton $f.00.3 -variable rhystip -text "Display Selected History" -value 3 -command "set pr_rhystory 1" -width 24
		radiobutton $f.00.5 -variable rhystip -text "Clear Selected History"   -value 5 -command "set pr_rhystory 1" -width 24
		radiobutton $f.00.4 -variable rhystip -text "Search Selected History for .."  -value 4 -command "set pr_rhystory 1"
		entry $f.00.ss -textvariable rhystsearch -width 20
		pack $f.00.tit2 $f.00.3 $f.00.5 $f.00.4 $f.00.ss -side left
		pack $f.00 -side top -anchor w -pady 1 -fill x -expand true
		frame $f.000
		radiobutton $f.000.6 -variable rhystip -text "~ DESTROY ~ Selected History"  -value 6 -command "set pr_rhystory 1" -width 24
		pack $f.000.6 -side right
		pack $f.000 -side top -anchor w -pady 1 -fill x -expand true
		frame $f.000b -bg black
		pack $f.000b -side top -fill x -expand true -pady 3
		frame $f.1
		set fa [frame $f.1.a]
		set fb [frame $f.1.b]
		frame $fa.1
		label $fa.1.ll -text "HISTORIES" -fg $evv(SPECIAL)
		frame $fa.1.1
		label $fa.1.1.ll -text "Current" -width 8
		entry $fa.1.1.e -textvariable rhystcur -width 32 -fg $readonlyfg -readonlybackground $readonlybg -state readonly
		pack $fa.1.1.ll $fa.1.1.e -side left -fill x -expand true
		frame $fa.1.2
		label $fa.1.2.ll -text "Selected" -width 8
		entry $fa.1.2.e -textvariable rhystsel -width 32 -fg $readonlyfg -readonlybackground $readonlybg -state readonly
		pack $fa.1.2.ll $fa.1.2.e -side left -fill x -expand true 
		pack $fa.1.ll $fa.1.1 $fa.1.2 -side top -pady 2
		pack $fa.1 -side top -pady 2
		frame $fa.3
		label $fa.3.tit -text "EXISTING RHYTHM HISTORIES" -fg $evv(SPECIAL)
		label $fa.3.tit2 -text "(Select with mouse)" -fg $evv(SPECIAL)
		Scrolled_Listbox $fa.3.hh -width 32 -height 24 -selectmode single
		pack $fa.3.tit $fa.3.tit2 $fa.3.hh -side top -pady 2
		pack $fa.3 -side top
		bind $fa.3.hh.list <ButtonRelease> {GetRhythmHistory %y}
		label $fb.tit -text "SELECTED RHYTHM HISTORY" -fg $evv(SPECIAL)
		Scrolled_Listbox $fb.hh -width 120 -height 30 -selectmode single
		pack $fb.tit $fb.hh -side top -pady 2

		pack $fa $fb -side left -padx 4
		pack $f.1 -side top
		bind $f <Escape> {set pr_rhystory 0}
		bind $f <Return> {set pr_rhystory 1}
	}
	set rhystip 0
	set finished 0
	set pr_rhystory 0
	if [info exists rhystory] {
		set rhystcur $rhystory
	} else {
		set rhystcur ""
	}
	set rhystnew ""
	set rhystsel ""
	set rhyhistlist {}
	$f.1.a.3.hh.list delete 0 end
	if [info exists rhyhist] {
		foreach nam [array names rhyhist] {		;#	get all rhythm-histories
			lappend rhyhistlist $nam
			$f.1.a.3.hh.list insert end $nam
		}
	}
	.rhyhistory.1.b.hh.list delete 0 end		;#	display any existing history-display in 2nd display window
	if {[info exists rhystdisplay] && [info exists rhyhist($rhystdisplay)]} {
		foreach line $rhyhist($rhystdisplay) {
			.rhyhistory.1.b.hh.list insert end $line
		}
	}
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_rhystory $f.0.e
	while {!$finished} {
		tkwait variable pr_rhystory
		if {$pr_rhystory} {
			switch -- $rhystip {
				0 {
					Inf "No action selected"
					continue
				}
				1 {		;#	CREATE					
					if {[string length $rhystnew] <= 0} {
						Inf "No name entered for new history"
						set rhystip 0
						continue
					}
					if {![regexp {^[a-zA-Z0-9\-\_]+$} $rhystnew]} {
						Inf "Invalid name entered for new history (alphanumeric with hyphens or underscores)"
						set rhystip 0
						continue
					}
					set rhystnew [string tolower $rhystnew]
					if [info exists rhyhist] {
						set OK 1
						set n 0
						set iscurhy 0
						foreach nam $rhyhistlist {
							if {[string match $nam $rhystnew]} {
								if {[string match $rhystcur $rhystnew]} {
									set iscurhy 1
									set msg "This is the name of the current history : overwrite it ??"
								} else {
									set msg "This history already exists: overwrite it ??"
								}
								set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
								if {$choice == "no"} {
									set rhystnew ""
									set OK 0
								} else {
									if {![DeleteRymHistoryFile $nam]} {				;#	Delete existing history file
										set OK 0
										break
									}
									DeleteRymHistory $nam $iscurhy
								}
								break
							}
							incr n
						}
						if {!$OK} {
							set rhystip 0
							continue
						}
					}
					set rhystory $rhystnew
					set rhystcur $rhystory
					lappend rhyhistlist $rhystory

					set fnam [file join $evv(URES_DIR) rhystcur$evv(CDP_EXT)]
					if [catch {open $fnam "w"} zit] {
						Inf "Cannot open file $fnam to store name of current history"
					} else {
						puts $zit $rhystory
						close $zit
					}
					set rhystip 0
				}
				2 {		;#	COMPLETE
					set msg "Are you sure you want to end the current history $rhystory ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						set rhystip 0
						continue
					}
					catch {unset rhystory}
					set rhystcur ""
					set fnam [file join $evv(URES_DIR) rhystcur$evv(CDP_EXT)]
					if {[file exists $fnam]} {
						if [catch {file delete $fnam} zit] {
							Inf "Cannot delete file $fnam storing name of current rhythm history"
						}
					}
					set rhystip 0
				}
				3 {		;#	DISPLAY
					if {[string length $rhystsel] <= 0} {
						Inf "No name entered for (selected) history to display"
						set rhystip 0
						continue
					}
					set rhystdisplay $rhystsel
					.rhyhistory.1.b.hh.list delete 0 end
					foreach line $rhyhist($rhystdisplay) {
						.rhyhistory.1.b.hh.list insert end $line
					}
					set rhystip 0
				}
				4 {		;#	SEARCH DISPLAYED HISTORY
					if {![info exists rhystdisplay]} {
						Inf "No history display to search"
						set rhystip 0
						continue
					}
					if {[string length $rhystsearch] <= 0} {
						Inf "No search string entered"
						set rhystip 0
						continue
					}
					set rhystsearch [string tolower $rhystsearch]
					if {![ValidCDPRootname $rhystsearch]} {
						Inf "Invalid search string"
						set rhystip 0
						continue
					}
					if [info exists rhyselected] {		;#	Check if search string has changed
						foreach nam [array names rhyselected] {
							if {$nam != $rhystsearch} {
								catch {unset rhyselected($nam)}
							}							;#	If it has, delete any existing "rhyselected" param 
						}
					}
					set len [llength $rhyhist($rhystdisplay)]
					if [info exists rhyselected($rhystsearch)] {
						set n $rhyselected($rhystsearch)
						incr n
					} else {
						set n 0
					}
					set j [.rhyhistory.1.b.hh.list index end]
					while {$n < $len} {
						set line [string tolower [lindex $rhyhist($rhystdisplay) $n]]
						if {[string first $rhystsearch $line] >= 0} {
							.rhyhistory.1.b.hh.list selection clear 0 end
							.rhyhistory.1.b.hh.list selection set $n
							if {($n > 29) && ($j > 29)} {
								set nj [expr double($n)/double($j)]
								.rhyhistory.1.b.hh.list yview moveto $nj
							}
							set rhyselected($rhystsearch) $n
							break
						}
						incr n
					}
					if {$n >= $len} {
						if {[info exists rhyselected($rhystsearch)]} {
							set msg "Reached end of displayed history : restart search at start ??"
							set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
							if {$choice == "no"} {
								set rhystip 0
								continue
							}
							unset rhyselected($rhystsearch)
							unset rhyselected
						} else {
							Inf "Item cannot be found in the displayed history"
						}
					}
					set rhystip 0
				}
				5 {		;#	CLEAR DISPLAY
					.rhyhistory.1.b.hh.list delete 0 end
					catch {unset rhystdisplay}
					set rhystip 0
				}
				6 {		;#	DELETE
					if {[string length $rhystsel] <= 0} {
						Inf "No name entered for (selected) history to delete"
						set rhystip 0
						continue
					}
					set msg "Are you sure you want to destroy history $rhystsel ??"
					set iscurhy 0
					if {[info exists rhystory] && [string match $rhystory $rhystsel]} {
						set msg "Are you sure you want to destroy the ~~current~~ history ??"
						set iscurhy 1
					}
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						set rhystip 0
						continue
					}
					if {![DeleteRymHistoryFile $rhystsel]} {			;#	Delete selected history file
						set rhystip 0
						continue
					}
					DeleteRymHistory $rhystsel $iscurhy
					set rhystsel ""										;#	Remove name of selected	file
					set rhystip 0
				}
			}
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- AT session start, load any existing rhythm-histories

proc LoadRymHistories {} {
	global evv rhyhist rhystory
	set rhystbasfnam [file join $evv(URES_DIR) rhyst_]

	set len [string length $rhystbasfnam]

	foreach fnam [glob -nocomplain "$rhystbasfnam*"] {
		if {![string match [file extension $fnam] $evv(CDP_EXT)]} {
			continue
		}
		if [catch {open $fnam "r"} zit] {
			continue
		}
		set nam [file rootname [string range $fnam $len end]]
		catch {unset lines}		
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			if {[string match [string index $line 0] ";"]} {
				continue
			}
			lappend lines $line
		}
		close $zit
		set rhyhist($nam) $lines
	}
	if {![info exists rhyhist]} {
		return
	}
	set fnam [file join $evv(URES_DIR) rhystcur$evv(CDP_EXT)]
	if {[file exists $fnam]} {
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot open file $fnam to read name of current rhythm history"
			return
		}
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			if {[string match [string index $line 0] ";"]} {
				continue
			} else {
				break
			}
		}
		close $zit
		foreach nam [array names rhyhist] {		;#	Search all rhythm-histories
			if {[string match $nam $line]} {	;#	If current named-history is in list
				set rhystory $line				;#	set "rhystory" variable to rhyhist-name
				break
			}
		}
	}
}

#------- Save action to a named Rhythm history

proc SaveRymHistory {nam data} {
	global evv rhyhist
	set fnam [file join $evv(URES_DIR) rhyst]
	append fnam "_" $nam $evv(CDP_EXT)
	if {![file exists $fnam]} {
		if [catch {open $fnam "w"} zit] {
			Inf "Cannot open file $fnam to start saving rhythm history"
			return 0
		}
	} elseif [catch {open $fnam "a"} zit] {
		Inf "Cannot open file $fnam to append rhythm history"
		return 0
	}
	puts $zit $data
	close $zit
	return 1
}

#------- Delete a named Rhythm history file

proc DeleteRymHistoryFile {nam} {
	global evv
	set fnam [file join $evv(URES_DIR) rhyst]
	append $fnam "_" $nam $evv(CDP_EXT)
	if {![file exists $fnam]} {
		return 1
	}
	if [catch {file delete $fnam} zit] {
		Inf "Cannot delete rhythm-history file $fnam"
		return 0
	}
	return 1
}

#------- Remove a named Rhythm history file

proc DeleteRymHistory {nam iscurhy} {
	global rhyhist rhyhistlist rhystory rhystcur rhystdisplay evv
	catch {unset rhyhist($nam)}							;#	Remove history from loaded histories store
	set n [lsearch $rhyhistlist $nam]
	if {$n >= 0} {
		set rhyhistlist [lreplace $rhyhistlist $n $n]	;#	Remove history name from window-displayed list of history-names
		.rhyhistory.1.a.3.hh.list delete 0 end
		if {[llength $rhyhistlist] > 0} {
			foreach nam $rhyhistlist {
				.rhyhistory.1.a.3.hh.list insert end $nam
			}
		}
	}
	if {$iscurhy} {										;#	If it is current history being deleted
		catch {unset rhystory}							;#	Remove current history		
		set rhystcur ""									;#	and related file
		set fnam [file join $evv(URES_DIR) rhystcur$evv(CDP_EXT)]
		if {[file exists $fnam]} {
			if [catch {file delete $fnam} zit] {
				Inf "Cannot delete file $fnam storing name of current rhythm history"
			}
		}
	}													;#	If history being deleted is also displayed in 2nd window, delete display
	if {[info exists rhystdisplay] && [string match $rhystdisplay $nam]} {
		.rhyhistory.1.b.hh.list delete 0 end
	}
}

#------- Select a Rhythm history file

proc GetRhythmHistory {y} {
	global rhystsel
	set i [.rhyhistory.1.a.3.hh.list nearest $y]
	if {$i >= 0} {
		set rhystsel [.rhyhistory.1.a.3.hh.list get $i]
	}
}

proc DoRhythmHistory {line} {
	global rhyhist rhystory 
	if {[info exists rhystory]} {		
		lappend rhyhist($rhystory) $line
		SaveRymHistory $rhystory $line
	}
}

#---- Compare rhythm patterns, for morphing

proc RhyCompare {} {
	global chlist pa evv
	if {![info exists chlist] || ([llength $chlist] != 2)} {
		Inf "Select two rhythm pattern files, in the order they might be used"
		return
	}
	set n 0
	foreach fnam $chlist {
		set ftyp $pa($fnam,$evv(FTYP))
		if {![IsAListofNumbers $ftyp]} {
			Inf "File $fnam is not a rhythm file"
			return
		}
		set linecnt($n) $pa($fnam,$evv(LINECNT))
		set numsize $pa($fnam,$evv(NUMSIZE))
		set entrycnt($n) [expr $numsize /  $linecnt($n)]
		if {($entrycnt($n) < 3) || ($entrycnt($n) > 4)} {
			Inf "File $fnam is not a rhythm file"
			return
		}
		if {($entrycnt($n) * $linecnt($n)) != $numsize} {
			Inf "File $fnam is not a rhythm file"
			return
		}
		incr n
	}
	if {$entrycnt(0) != $entrycnt(1)} {
		Inf "Rhythm files are not of same type (must both be \"til\" or both \"tilp\")"
		return
	}
	set n 0
	foreach fnam $chlist {
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot open file $fnam"
			return
		}
		set this_linecnt 1
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			if {[string match [string index $line 0] ";"]} {
				continue
			}
			set line [split $line]
			set cnt 0
			set OK 1
			catch {unset nuline}
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				switch -- $cnt {
					0 {
						if {$this_linecnt == 1} {
							if {$item != 0.0} {
								Inf "Initial time in input data file $fnam must be zero"
								set OK 0
								break
							}
						} elseif {$item < $lasttime} {
							Inf "Times ($lasttime $item) in input data file $fnam do not increase at line $this_linecnt"
							set OK 0
							break
						}
						set lasttime $item	
					}
					1 {
						if {![regexp {^[0-9]+$} $item] || ![IsNumeric $item]} {
							Inf "Invalid sound-index value on line $this_linecnt of file $fnam"
							set OK 0
							break
						} else {
							lappend indeces($n) $item
						}
					}
					2 {
						if {($item < 0.0) || ($item > 1.0)} {
							Inf "Invalid level value on line $this_linecnt of file $fnam"
							set OK 0
							break
						}
					}
					3 {
						if {($item < 0.0) || ($item > 8.0)} {
							Inf "Invalid position value on line $this_linecnt of file $fnam"
							set OK 0
							break
						}
					}
				}					
				incr cnt
			}
			if {!$OK} {
				break
			}
			if {$cnt < 3} {
				set OK 0
				break
			}
			incr this_linecnt
		}
		close $zit
		if {!$OK} {
			return
		}
		set len [llength $indeces($n)]
		incr len -2
		set indeces($n) [lrange $indeces($n) 0 $len]		;#	Ignore index of final (end-marker) event
		incr n
	}

	if {$linecnt(0) > $linecnt(1)} {				;#	First pattern larger
		foreach item $indeces(0) {
			if {[lsearch $indeces(1) $item] < 0} {	;#	Events in larger pattern which are not in smaller
				set order_reversal 1				;#	Patterns only compatible if order reversed (smaller fist) and new indeces injected through morph
				break
			}
		}
		if {[info exists order_reversal]} {
			foreach item $indeces(1) {				;#	Events in smaller pattern which are not in larger : not permitted
				if {[lsearch $indeces(0) $item] < 0} {
					lappend badevents $item
				}
			}
			if {[info exists badevents]} {
				set msg "Patterns incompatible\n(smaller pattern has events ("
				foreach item $badevents {
					append msg $item " "
				}
				append msg ") not occuring in larger pattern).\n"
				Inf $msg
				return
			}
			set msg "Events in larger pattern which are not in smaller.\n" 
			append msg "morph-compatible only if order reversed (smaller first)\n"
			append msg "and new indeces injected through the morph."
			Inf $msg


		} else {
			Inf "Pattern shrinks : bridging-data required for any morph.\n"
		}
	} elseif {$linecnt(1) > $linecnt(0)} {
		foreach item $indeces(1) {
			if {[lsearch $indeces(0) $item] < 0} {
				lappend insert_events $item
			}
		}
		foreach item $indeces(0) {
			if {[lsearch $indeces(1) $item] < 0} {
				lappend badevents $item
			}
		}
		if {[info exists badevents]} {
			set msg "Patterns incompatible\n(smaller pattern has events ("
			foreach item $badevents {
				append msg $item " "
			}
			append msg ") not occuring in larger pattern).\n"
			Inf $msg
			return
		}
		if {[info exists insert_events]} {
			set msg "Patterns compatible & growing in size.\nnew items "
			foreach item $insert_events {
				append msg $item " "
			}
			append msg "would be inserted during any morph.\n"
			Inf $msg
		} else {
			set msg "Patterns compatible & growing in size.\n"
		}
		append msg "Bridging data required.\n"
		Inf $msg
	} else {
		foreach item $indeces(1) {
			if {[lsearch $indeces(0) $item] < 0} {
				lappend badevents $item
			}
		}
		if {[info exists badevents]} {
			set msg "Patterns incompatible\n(1st pattern has events ("
			foreach item $badevents {
				append msg $item " "
			}
			append msg ") not occuring in 2nd pattern).\n"
			Inf $msg
			return
		}
		foreach item $indeces(0) {
			if {[lsearch $indeces(1) $item] < 0} {
				lappend badevents $item
			}
		}
		if {[info exists badevents]} {
			set msg "Patterns incompatible\n(2nd pattern has events ("
			foreach item $badevents {
				append msg $item " "
			}
			append msg ") not occuring in 1st pattern).\n"
			Inf $msg
			return
		}
		Inf "Patterns compatible (no bridging-data required).\n"
	}
	return
}

proc RhythmHistoryHelp {} {
	set msg "RHYTHM HISTORIES\n"
	append msg "\n"
	append msg "With TILP patterns (ONLY)\n"
	append msg "and for the following operations (ONLY)\n"
	append msg "\n"
	append msg "REPEAT/RESCALE\n"
	append msg "ABUTT\n"
	append msg "SNIP\n"
	append msg "MORPH\n"
	append msg "\n"
	append msg "A (named) \"History\" of actions-taken can be created and later displayed,\n"
	append msg "to trace the provenance of any pattern or pattern source.\n"
	append msg "\n"
	append msg "Histories can also be searched (for named patterns), and deleted.\n"
	append msg "\n"
	Inf $msg
}

#---- Where a snipped off end-cell has duplicated entires (due to pattern contraction) - squeeze to sinfgle entries

proc RhySqueeze {} {
	global pr_rhysq fnam_rhysq chlist pa evv wstk wl
	if {![info exists chlist] || ([llength $chlist] != 1)} {
		Inf "Select a single rhythm cell"
		return
	}
	set ifnam [lindex $chlist 0]
	set ftyp $pa($ifnam,$evv(FTYP))
	if {![IsAListofNumbers $ftyp]} {
		Inf "File $ifnam is not a rhythm file"
		return
	}
	set linecnt $pa($ifnam,$evv(LINECNT))
	set numsize $pa($ifnam,$evv(NUMSIZE))
	set entrycnt [expr $numsize /  $linecnt]
	if {($entrycnt * $linecnt) != $numsize} {
		Inf "File $ifnam is not a rhythm file"
		return
	}
	if {$entrycnt != 4} {
		Inf "File $ifnam is not a tilp rhythm file"
		return
	}
	if [catch {open $ifnam "r"} zit] {
		Inf "Cannot open file $ifnam"
		return
	}
	set linecnt 1
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		set cnt 0
		set OK 1
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			switch -- $cnt {
				0 {
					if {$linecnt == 1} {
						if {$item != 0.0} {
							Inf "Initial time in input data file $ifnam must be zero"
							set OK 0
							break
						}
					} elseif {$item < $endtime} {
						Inf "Times ($lasttime $item) in input data file $ifnam do not increase at line $linecnt"
						set OK 0
						break
					}
					lappend times $item
					set endtime $item	
				}
				1 {
					if {![regexp {^[0-9]+$} $item] || ![IsNumeric $item]} {
						Inf "Invalid sound-index value on line $linecnt of file $ifnam"
						set OK 0
						break
					}
					lappend indeces $item
					set endindx $item	
				}
				2 {
					if {($item < 0.0) || ($item > 1.0)} {
						Inf "Invalid level value on line $linecnt of file $ifnam"
						set OK 0
						break
					}
					lappend levels $item
					set endlevl $item	
				}
				3 {
					if {($item < 0.0) || ($item > 8.0)} {
						Inf "Invalid position value on line $linecnt of file $fnam"
						set OK 0
						break
					}
					lappend positions $item
					set endposi $item	
				}
			}					
			incr cnt
		}
		if {!$OK} {
			break
		}
		if {$cnt < 3} {
			set OK 0
			break
		}
		incr linecnt
	}
	close $zit
	if {!$OK} {
		return
	}
	set endmarker_line [list $endtime $endindx $endlevl $endposi]

	set line ";SQUEEZED VERSION OF [file rootname $ifnam]"					;#	Make and save title comment
	lappend nulines $line
																			;#	For line-processsing
	set datalen [llength $levels]
	incr datalen -1															;#	Ignore endmarker line
	set n 0 
	set started 0
	while {$n < $datalen} {
		set time [lindex $times $n]
		set indx [lindex $indeces $n]
		set levl [lindex $levels $n]
		set posi [lindex $positions $n]
		if {!$started} {
			set levlsum $levl												;#	Start accumulating levels of successive lines
			set started 1
		} else {															;#	Looks for identical val lines
			if {($time == $lasttime) && ($indx == $lastindx) && ($posi == $lastposi)} {	
				set levlsum [expr $levlsum + $levl]							;#	and sums their levels		

			} else {														;#	Once a different line appears
				if {$levlsum > 1.0} {										;#	Check previous levlsum is not overloaded
					set levlsum 1.000000														
				} else {													;#	Output accumulation of previous identical-lines
					set levlsum [Zeropad $levlsum 6]
				}
				set line [list $lasttime $lastindx $levlsum $lastposi]
				lappend nulines $line
				set levlsum $levl											;#	Start new accumulation of level
			}
		}
		set lasttime $time													;#	Remember values of current line
		set lastindx $indx
		set lastposi $posi
		incr n
	}
	if {$levlsum > 1.0} {													;#	Write the final accumulated line
		set levlsum 1.000000
	} else {
		set levlsum [Zeropad $levlsum 6]
	}
	set line [list $lasttime $lastindx $levlsum $lastposi]
	lappend nulines $line
	lappend nulines $endmarker_line											;#	Add the endmarker

	set f .rhysq
	if [Dlg_Create  $f "TRANSFER RECOLOUR" "set pr_rhysq 0" -width 64 -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.ok -text "Squeeze" -command "set pr_rhysq 1" -width 15
		button $f.0.ab -text "Abandon" -command "set pr_rhysq 0" -width 15
		pack $f.0.ok -side left
		pack $f.0.ab -side right
		pack $f.0 -side top -pady 1 -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Output Filename"
		entry $f.1.e -textvariable fnam_rhysq -width 48
		pack $f.1.e $f.1.ll -side left
		pack $f.1 -side top -pady 2
		bind $f <Escape> {set pr_rhysq 0}
		bind $f <Return> {set pr_rhysq 1}
	}
	set finished 0
	set pr_rhysq 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_rhysq $f.1.e
	while {!$finished} {
		tkwait variable pr_rhysq
		if {$pr_rhysq} {
			if {[string length $fnam_rhysq] <= 0} {
				Inf "No filename entered"
				continue
			}
			if {![ValidCDPRootname $fnam_rhysq]} {
				continue
			}
			set ofnam [string tolower $fnam_rhysq]
			append ofnam $evv(TEXT_EXT)
			if {[file exists $ofnam]} {
				set msg "File $ofnam already exists : overwrite it ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				if {![CouetteAllowsDelete $ofnam]} {
					continue
				}
				if [catch {file delete -force $ofnam} in] {
					Inf "Cannot delete the existing file."
					continue
				} else {											;# Copy only takes place from Dirlist to Wkspace.
					DataManage delete $ofnam
					CouettePatchesDelete $ofnam
					DeleteFileFromSrcLists $ofnam					;# File created is a wkspace file.
					RemoveFromChosenlist $ofnam
					PurgeArray $ofnam
					DummyHistory $ofnam "OVERWRITTEN"
					set i [LstIndx $ofnam $wl]
					if {$i >= 0} {
						$wl delete $i
					}
				}
			}
			if [catch {open $ofnam "w"} zit] {
				Inf "Cannot open file $ofnam"
				continue
			}
			foreach line $nulines {
				puts $zit $line
			}
			close $zit
			FileToWkspace $ofnam 0 0 0 0 1
			Inf "File $ofnam is on the workspace"
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Pad value to 6 decimal places (if not already greater)

proc Zeropad {val decplaces} {
	set decpoint [string first "." $val]
	if {$decpoint < 0} {
		append val ".000000"
		return 
	}
	incr decpoint 							;#	Pad level values with zeros (to 6 decplaces)
	set len [string length $val]
	set current_decplaces [expr $len - $decpoint]
	set pad [expr $decplaces - $current_decplaces]
	if {$pad > 0} {
		set k 0
		while {$k < $pad} {
			append val "0"
			incr k
		}
	}
	return $val
}

proc RhySnipHelp {} {
	set msg "SOUND-INDEX TRANSFER\n"	
	append msg "\n"
	append msg "Patterns can have their sound indeces progressively changed\n"
	append msg "by index-substitution.\n"
	append msg "\n"
	append msg "If 2 patterns are to succeed each other in a final mix,\n"
	append msg "AND pattern-2 begins with the same cell that ended pattern-1,\n"
	append msg "TRANSFER allows the recolouring applied to pattern-1\n"
	append msg "to be carried over into pattern-2.\n"
	append msg "\n"
	append msg "First the final cell of the (recoloured) pattern-1 must be \"snipped off\".\n"
	append msg "\n"
	append msg "The \"Chosen Files\" listing has the snipped file followed by pattern-2,\n"
	append msg "and pattern-2 will be recoloured consistently with\n"
	append msg "the new end-colours of the recoloured pattern-1. \n"
	append msg "\n"
	append msg "~~~~ SNIP ~~~~\n"
	append msg "\n"
	append msg "The final cell of the (recoloured) pattern-1 can be detached\n"
	append msg "(using \"SNIP\").\n"
	append msg "\n"
	append msg "~~~~ SQUEEZE ~~~~\n"
	append msg "\n"
	append msg "The transfer procedure works\n"
	append msg "even if pattern-2 increases or decreases in cell-size.\n"
	append msg "\n"
	append msg "Where pattern-2 involves an increase in cell-size,\n"
	append msg "there should be a link file associated with pattern2 (patname_link.txt)\n"
	append msg "which will be picked up and used automatically,\n"
	append msg "so that the entries in the snipped file and pattern 2 tally correctly.\n"
	append msg "\n"
	append msg "The transfer procedure works\n"
	append msg "even if pattern-1 increases in cell-size.\n"
	append msg "\n"
	append msg "However, where pattern-1 involves a decrease in cell-size,\n"
	append msg "the snipped final-cell will need to be \"Squeezed\"\n"
	append msg "to reduce it to the original smaller-cell format starting pattern-2.\n"
	append msg "\n"
	append msg "If in doubt, look at the data.\n"
	Inf $msg
}

proc RhythmicIndexSubstitionHelp {} {
	set msg "~~~~~~  RHYTHM PATTERN SOUND-INDEX SUBSTITUTION  ~~~~~~\n"
	append msg "\n"
	append msg "Patternfiles contain rhythmic cells which repeat and evolve.\n"
	append msg "The sequence of all these cells is a \"pattern\".\n"
	append msg "The evolution of each cell-element in the pattern is tracked\n"
	append msg "by an associated \"_map\" file.\n"
	append msg "The (start and end) time(s) of the final cell in a pattern\n"
	append msg "is stored in an associated \"_stend\" file.\n"
	append msg "\n"
	append msg "Once a rhythmic pattern (in a patternfile) or\n"
	append msg "a series of evolving patterns (patternfiles) have been made,\n"
	append msg "the sound-indeces in the pattern may be REPLACED,\n"
	append msg "by (a sequence of) alternative sound-indices.\n"
	append msg "\n"
	append msg "On the \"Chosen Files\" list, a pattern is required.\n"
	append msg "(THE ASSOCIATED \"_map\" FILE MUST EXIST).\n"
	append msg "\n"
	append msg "The index-substitution is defined by a special file\n"
	append msg "and is called up from the \"RHYTHM PATTERN INDEX-SUBSTITUTION\" window.\n"
	append msg "\n"
	append msg "An index-substitution file appropriate to the chosen map\n"
	append msg "can be called up automatically (and set for editing) from this window.\n"
	append msg "\n"
	append msg "~~~~ FORMAT OF SOUND-SUBSTITUTION FILES ~~~~\n"
	append msg "\n"
	append msg "(This information can also be found on the \"Help\" info on the\n"
	append msg "\"RHYTHM PATTERN INDEX-SUBSTITUTION\" window.)\n"
	append msg "\n"
	append msg "This file tells us how to ...\n"
	append msg "\n"
	append msg "(1)  replace all occurences of a GIVEN INDEX\n"
	append msg "(2)  at and after a SPECIFIED LINE\n"
	append msg "(3)  by a NEW INDEX\n"
	append msg "(4)  which itself may increment in value after every STEP occurences.\n"
	append msg "\n"
	append msg "NB In a rhythm-pattern where 2 (or more) evolving elements start with the SAME index\n"
	append msg "specifying (1) AND (2) means that\n"
	append msg "only those elements evolving from the specified line will be recoloured\n"
	append msg "\n"
	append msg "The substitution-data-file has data-lines in the format \"A B C D\".\n"
	append msg "\n"
	append msg "A = a sound-index of an event in the existing pattern.\n"
	append msg "B = the line number of A in the existing pattern where substitution is to start.\n"
	append msg "           (No line number should be duplicated).\n"
	append msg "C = The (initial value of the) NEW sound-index.\n"
	append msg "D = The Step (number of occurences of A) before the substituted index (C)\n"
	append msg "     is incremented in value.\n"
	append msg "\n"
	Inf $msg
}

proc TilpToMixHelp {} {
	set msg "~~~~~~~~~~~~ SOUND INDEXING FILES ~~~~~~~~~~~~\n"
	append msg "\n"
	append msg "Textfile assigning named soundfiles to the index-numbers in a rhythm-pattern file.\n"
	append msg "Each line in the file has just 2 entries, \"INDEX-NUMBER    SNDFILE-NAME\".\n"
	append msg "The first line must have index-number \"0\" and the name of a ~SILENT~ Soundfile.\n"
	append msg "\n"
	append msg "\n"
	append msg "~~~~ CONVERT RHYTHM TO MIXFILE AND MIX TO SND ~~~~\n"
	append msg "\n"
	append msg "Converts \"TILP\" information into a mixfile format to generate sound.\n"
	append msg "\n"
	append msg "The first file on the \"Chosen Files\" list must be A \"TILP\" file.\n"
	append msg "This must be followed by EITHER of ....\n"
	append msg "\n"
	append msg "(1) A sound-indexing textfile, (see above).\n"
	append msg "       Sounds are assigned to Index values as indicated by the assignment here.\n"
	append msg "\n"
	append msg "(2) The appropriate number of mono soundfiles \n"
	append msg "       (one for each different sound-index value used in the \"TILP\" file).\n"
	append msg "       Sounds are assigned to the Index values in \"TILP\" file\n"
	append msg "       in order of increasing Index value.\n"
	append msg "\n"
	append msg "In either case, the first soundfile in the assigned sounds should be a SILENT FILE.\n"
	append msg "\n"
	append msg "If the \"TILP\" file ITSELF contains a silent file (by convention indicated by Index value 0)\n"
	append msg "    Where soundfiles are input directly...\n"
	append msg "        1st sound in list (the silent file) is assigned to lowest Index value (here 0);\n"
	append msg "        next sound in list to next lowest Index value; and so on.\n"
	append msg "Number of assigned sound files should be equal to number of different Index values in \"TILP\" file.\n"
	append msg "\n"
	append msg "If the \"TILP\" file DOES NOT ITSELF contain a silent file,\n"
	append msg "    Where soundfiles are input directly...\n"
	append msg "        1st sound in list should still be a silent file;\n"
	append msg "        2nd sound in list is assigned to lowest Index value;\n"
	append msg "        next sound in list to next lowest Index value; and so on.\n"
	append msg "Number of assigned sound files must be 1 greater then number of different Index values in \"TILP\" file.\n"
	append msg "\n"
	append msg "\n"
	append msg "~~~~ CONVERT MIXFILE TO RHYTHM ~~~~\n"
	append msg "\n"
	append msg "Should only be used to convert a MULTICHANNEL mixfile representation of a rhythmic CELL,\n"
	append msg "into a \"TILP\" format file.\n"
	append msg "\n"
	append msg "Mixfile can use mono and/or stereo files. If stereo files are used,\n"
	append msg "\"TILP\" file treats each channel of a stereo-input as a separate (indexed) entity.\n"
	append msg "\n"
	append msg "The process outputs a \"TILP\" file \"filename.txt\"\n"
	append msg "and also a file \"filename_idx.txt\" showing how each (channel of each) soundfile\n"
	append msg "relates to the index values in the \"TILP\" file.\n"
	append msg "\n"
	Inf $msg
}

proc TilpSindexHelp {} {
	set msg "~~~~~~~~~~~~ SOUND INDEXING FILES ~~~~~~~~~~~~\n"
	append msg "\n"
	append msg "Textfile assigning named soundfiles to the index-numbers in a rhythm-pattern file.\n"
	append msg "Each line in the file has just 2 entries, \"INDEX-NUMBER    SNDFILE-NAME\".\n"
	append msg "The first line must have index-number \"0\" and the name of a ~SILENT~ Soundfile.\n"
	append msg "\n"
	append msg "\n"
	append msg "~~~~ MODIFY A SOUND-INDEXING FILE ~~~~\n"
	append msg "\n"
	append msg "Edit entires in a sound-indexing file.\n"
	append msg "\n"
	append msg "\n"
	append msg "~~~~ CHANGE DIR INSIDE SND-INDEXING FILE ~~~~\n"
	append msg "\n"
	append msg "Move all \"sounds\" listed in a sound-indexing file to a new directory.\n"
	append msg "\n"
	append msg "\n"
	append msg "~~~~ CONCATENATE RHYTHM-PATTERN SOUND-OUTPUTS ~~~~\n"
	append msg "\n"
	append msg "Where a sequence of related pattern files have been generated,\n"
	append msg "with the intention that one pattern should follow on from another,\n"
	append msg "and sound output has been generated from each of them ...\n"
	append msg "\n"
	append msg "then SO LONG AS the strict naming convention has been adhered to such that\n"
	append msg "\n"
	append msg "      each soundfile \"myname.wav\"\n"
	append msg "      is derived from a rhythm file \"myname.txt\"\n"
	append msg "      with an associated \"myname_stend.txt\"\n"
	append msg "      (which contains information on the endtime of the pattern)\n"
	append msg "\n"
	append msg "then the sound outputs can be directly concatenated.\n"
	append msg "\n"
	Inf $msg
}

#---- Create an indexed table of snds (Format "INDEX SND")

proc CreateSndIndex {} {
	global chlist evv pa wstk wl pr_creatsindex fnam_creatsindex sindex_stt maxsamp_line CDPmaxId done_maxsamp

	set startmsg "SELECT A SILENT MONO FILE FOLLOWED BY EITHER\n"
	append startmsg "MONO SOUNDFILES OR\n"
	append startmsg "A TEXTFILE LISTING MONO SOUNDFILES"

	if {![info exists chlist] || ([llength $chlist] <= 1)} {
		Inf $startmsg
		return
	}
	if {[llength $chlist] == 2} {
		set fnam0 [lindex $chlist 0]
		set fnam1 [lindex $chlist 1]
		if {$pa($fnam0,$evv(FTYP)) != $evv(SNDFILE)} {
			Inf $startmsg
			return
		}
		set ftyp $pa($fnam1,$evv(FTYP))
		if {($ftyp == $evv(SNDFILE))} {
			set infnams $chlist
		} elseif {[IsASndlist $ftyp]} {
			set infnams $fnam0
			if [catch {open $fnam1 "r"} zit] {
				Inf "Cannot open file $fnam1"
				return
			}
			set cnt 0
			while {[gets $zit line] >= 0} {
				set line [string trim $line]
				if {[string length $line] <= 0} {
					continue
				}
				if {[string match [string index $line 0] ";"]} {
					continue
				}
				set line [split $line]
				set OK 1
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] <= 0} {
						continue
					}
					if {![file exists $item]} {
						Inf "File $item no longer exists"
						set OK 0
						break
					}
					if {![info exists pa($item,$evv(FTYP))]} {
						if {[DoParse $item 0 0 0] <= 0} {
							Inf "Cannot parse file $item"
							set OK 0
							break
						}
					}
					if {$cnt == 0} {
						set srate $pa($item,$evv(SRATE))
					} elseif {$pa($item,$evv(SRATE)) != $srate } {
						Inf "Sounds with different sample rates in listing"
						set OK 0
					}
					if {$pa($item,$evv(CHANS)) != 1 } {
						Inf "Not all sounds in listing are mono"
						set OK 0
					}
					lappend infnams $item
					incr cnt
				}
				if {!$OK} {
					break
				}
			}
			close $zit
			if {!$OK} {
				return
			}
		} else {
			Inf $startmsg
			return
		}
	} else {
		set infnams $chlist
	}

	foreach fnam $infnams {
		if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
			Inf $startmsg
			return
		}
		if {$pa($fnam,$evv(CHANS)) != 1} {
			Inf $startmsg
			return
		}
		lappend fnams $fnam
	}
	set silfnam [lindex $fnams 0]

	catch {unset maxsamp_line}
	set done_maxsamp 0
	set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
	lappend cmd $silfnam
	lappend cmd 1		;#	1 flag added to FORCE read of maxsample
	if [catch {open "|$cmd"} CDPmaxId] {
		ErrShow "$CDPmaxId"
		continue
	} else {
	   	fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
	}
	vwait done_maxsamp
	if {[info exists maxsamp_line]} {
		set pa($silfnam,$evv(MAXSAMP)) [lindex $maxsamp_line 0]
		if {$pa($silfnam,$evv(MAXSAMP)) > 0.0} {
			Inf "First sound in list must be a silent file"
			return
		}
	} else {
		Inf "Cannot get max sample information for first sound in list"
		return
	}
	set f .creatsindex
	if [Dlg_Create  $f "CREATE SND INDEX FILE" "set pr_creatsindex 0" -width 64 -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.ok -text "Create" -command "set pr_creatsindex 1" -width 15
		button $f.0.ab -text "Abandon" -command "set pr_creatsindex 0" -width 15
		pack $f.0.ok -side left
		pack $f.0.ab -side right
		pack $f.0 -side top -pady 1 -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Start Index"
		entry $f.1.e -textvariable sindex_stt -width 12
		pack $f.1.e $f.1.ll -side left
		pack $f.1 -side top -pady 2 -fill x -expand true

		frame $f.2
		label $f.2.ll -text "Output Filename"
		entry $f.2.e -textvariable fnam_creatsindex -width 48
		pack $f.2.e $f.2.ll -side left
		pack $f.2 -side top -pady 2
		bind $f <Up> {set pr_creatsindex 2}
		bind $f <Down> {set pr_creatsindex 3}
		bind $f <Escape> {set pr_creatsindex 0}
		bind $f <Return> {set pr_creatsindex 1}
	}
	set sindex_stt 1
	set finished 0
	set pr_creatsindex 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_creatsindex $f.1.e
	while {!$finished} {
		tkwait variable pr_creatsindex
		switch -- $pr_creatsindex {
			0 {
				set finished 1
			}
			1 {
				if {![regexp {^[0-9]+$} $sindex_stt] || ![IsNumeric $sindex_stt] || ($sindex_stt <= 0)} {
					Inf "Invalid start index (must be integer greater than 0)"
					continue
				}
				if {![ValidCDPRootname $fnam_creatsindex]} {
					continue
				}
				set ofnam [string tolower $fnam_creatsindex]
				append ofnam $evv(TEXT_EXT)
				if {[file exists $ofnam]} {
					set msg "File $ofnam already exists : overwrite it ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
					if {![CouetteAllowsDelete $ofnam]} {
						continue
					}
					if [catch {file delete -force $ofnam} in] {
						Inf "Cannot delete the existing file."
						continue
					} else {
						DataManage delete $ofnam
						CouettePatchesDelete $ofnam
						DeleteFileFromSrcLists $ofnam
						PurgeArray $ofnam
						DummyHistory $ofnam "OVERWRITTEN"
						set i [LstIndx $ofnam $wl]
						if {$i >= 0} {
							$wl delete $i
						}
					}
				}
				catch {unset lines}
				set line [list 0 $silfnam]	;#	Put silent file at start
				lappend lines $line
				set n $sindex_stt
				foreach fnam [lrange $fnams 1 end] {	# consecutively index rest of files
					set line [list $n $fnam]
					lappend lines $line
					incr n
				}
				if [catch {open $ofnam "w"} zit] {
					Inf "Cannot open file $ofnam to write data"
					continue
				}
				foreach line $lines {
					puts $zit $line
				}
				close $zit
				FileToWkspace $ofnam 0 0 0 0 1
				Inf "File $ofnam is on the workspace"
				set finished 1
			}
			2 {
				if {![regexp {^[0-9]+$} $sindex_stt] || ![IsNumeric $sindex_stt]} {
					continue
				}
				incr sindex_stt
			}
			3 {
				if {![regexp {^[0-9]+$} $sindex_stt] || ![IsNumeric $sindex_stt] || ($sindex_stt <= 1)} {
					continue
				}
				incr sindex_stt -1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- Modify an indexed table of snds (Format "INDEX SND"): first snd must be index zero and a silent file

proc ModifySndIndex {} {
	global chlist evv pa wstk wl pr_modsindex fnam_modsindex modsindex_stt sndindexdata

	set startmsg "SELECT ONE SOUND-INDEX FILE\nWITH OR WITHOUT SOME MONO SNDFILES OF SAME SAMPLERATE AS SNDS IN INDEXING FILE\n"
	set with_snds 0

	if {![info exists chlist] || ([llength $chlist] <= 0)} {
		Inf $startmsg
		return
	}
	set sifnam [lindex $chlist 0]
	set srate [IsASndIndexingFileWithSrate $sifnam]
	if {![info exists sndindexdata] || ($srate <= 0)} {
		Inf $startmsg
		return
	}

	;#	CREATE LIST OF INDECES ONLY

	foreach line $sndindexdata {
		lappend indxs [lindex $line 0]
	}

	;#	SORT INTO ASCENDING ORDER OF INDICES

	set len [llength $indxs]
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set n_indx [lindex $indxs $n]
		set m $n
		incr m
		while {$m < $len} {
			set m_indx [lindex $indxs $m]
			if {$m_indx < $n_indx} {	
				set indxs [lreplace $indxs $n $n $m_indx]
				set indxs [lreplace $indxs $m $m $n_indx]
				set sndindexdata_n [lindex $sndindexdata $n]
				set sndindexdata_m [lindex $sndindexdata $m]
				set sndindexdata [lreplace $sndindexdata $n $n $sndindexdata_m]
				set sndindexdata [lreplace $sndindexdata $m $m $sndindexdata_n]
			}
			incr m
		}
		incr n
	}

	;#	CREATE LIST OF SNDS ONLY

	foreach line $sndindexdata {
		lappend snds [lindex $line 1]
	}

	set orig_sndindexdata $sndindexdata
	set orig_snds $snds
	set orig_indxs $indxs

	;#	GET AND TEST ANY OTHER INPUTTED FILES

	if {[llength $chlist] > 1} {
		foreach fnam [lrange $chlist 1 end] {
			if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
				Inf "$fnam is not a soundfile"
				return
			}
			if {$pa($fnam,$evv(CHANS)) != 1} {
				Inf "Soundfile $fnam is not mono"
				return
			}
			if {$pa($fnam,$evv(SRATE)) != $srate} {
				Inf "Soundfile $fnam has wrong sample rate (must be $srate with snd-index file [file rootname [file tail $sifnam]])"
				return
			}
			lappend fnams $fnam
		}
		set with_snds 1
	}

	set f .modsindex
	if [Dlg_Create  $f "MODIFY SND INDEX LISTING" "set pr_modsindex 0" -width 64 -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.ss -text "Save Mods" -command "set pr_modsindex 1" -width 10
		button $f.0.ab -text "Abandon" -command "set pr_modsindex 0" -width 10
		pack $f.0.ss -side left
		pack $f.0.ab -side right
		pack $f.0 -side top -pady 1 -fill x -expand true
		frame $f.1
		button $f.1.r -text "Restore Original" -command "set pr_modsindex 4" -width 21
		button $f.1.a -text "See All Duplicates" -command "set pr_modsindex 6" -width 21
		button $f.1.d -text "Dupls of Selected Snd" -command "set pr_modsindex 5" -width 21
		button $f.1.u -text "Clear Selection" -command "set pr_modsindex 7" -width 21
		pack $f.1.r $f.1.a $f.1.d $f.1.u -side left -padx 2 
		pack $f.1 -side top -pady 1
		frame $f.2
		button $f.2.d -text "Delete Selected" -command "set pr_modsindex 8" -width 21
		button $f.2.r -text "Renumber Selected" -command "set pr_modsindex 9" -width 21
		button $f.2.ra -text "Renumber All" -command "set pr_modsindex 10" -width 21
		button $f.2.rr -text "Reverse Snd Order" -command "set pr_modsindex 13" -width 21
		button $f.2.ia -text "Insert Snds at" -command "set pr_modsindex 11" -width 21
		button $f.2.ir -text "Insert Snds & Renum" -command "set pr_modsindex 12" -width 21
		pack $f.2.d $f.2.r $f.2.ra $f.2.rr $f.2.ia $f.2.ir -side left -padx 2 
		pack $f.2 -side top -pady 1

		frame $f.3
		label $f.3.ll -text "Start Index"
		entry $f.3.e -textvariable modsindex_stt -width 12
		pack $f.3.e $f.3.ll -side left
		label $f.3.ll2 -text "Output Filename"
		entry $f.3.e2 -textvariable fnam_modsindex -width 48
		pack $f.3.ll2 $f.3.e2 -side right
		pack $f.3 -side top -pady 2 -fill x -expand true

		frame $f.4
		label $f.4.tit -text "SOUND INDEX LIST" -fg $evv(SPECIAL)
		Scrolled_Listbox $f.4.ll -width 120 -height 30 -selectmode extended
		pack $f.4.tit $f.4.ll -side top -pady 2
		pack $f.4 -side top -pady 2

		bind $f <Up> {set pr_modsindex 2}
		bind $f <Down> {set pr_modsindex 3}
		bind $f <Escape> {set pr_modsindex 0}
		bind $f <Return> {set pr_modsindex 1}
	}
	$f.4.ll.list delete 0 end
	foreach item $sndindexdata {
		$f.4.ll.list insert end $item
	}
	set modsindex_stt 1
	if {$with_snds} {
		$f.2.ia config -text "Insert Snds at" -bd 2 -command "set pr_modsindex 11"
		$f.2.ir config -text "Insert Snds & Renum" -bd 2 -command "set pr_modsindex 12"
	} else {
		$f.2.ia config -text "" -bd 0 -command {}
		$f.2.ir config -text "" -bd 0 -command {}
	}
	$f.0.ss config -text "" -command {} -bd 0 -bg [option get . background {}]

	set modsindex_stt 0
	set finished 0
	set pr_modsindex 0
	set is_modified 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_modsindex $f.3.e
	while {!$finished} {
		tkwait variable pr_modsindex
		switch -- $pr_modsindex {
			0 {
				set finished 1
			}
			4 {	
				set sndindexdata $orig_sndindexdata
				set snds $orig_snds
				set indxs $orig_indxs
				.modsindex.4.ll.list delete 0 end
				foreach indxlisting $sndindexdata {
					.modsindex.4.ll.list insert end $indxlisting
				}
				set is_modified 0
				$f.0.ss config -text "" -command {} -bd 0 -bg [option get . background {}]
			}
			5 {
				set ilist [.modsindex.4.ll.list curselection]
				if {![info exists ilist] || ([llength $ilist] == 0) || (([llength $ilist] == 1) && ($ilist == -1))} {
					Inf "No item selected"
					continue
				}
				if {[llength $ilist] > 1} {
					Inf "Select just one item, to find its duplicates"
					continue
				}
				$f.4.ll.list selection clear 0 end
				set thissnd [lindex $snds $ilist]
				set cnt 0
				set n 0
				while {$n < $len} {
					set snd_n [lindex $snds $n]
					if {[string match $snd_n $thissnd]} {
						$f.4.ll.list selection set $n
						incr cnt
					}
					incr n
				}
				if {$cnt <= 1} {
					Inf "No duplicates of sound [file rootname [file tail $thissnd]]"
				}
			}
			6 {
				set isdupls 0
				$f.4.ll.list selection clear 0 end
				set len [llength $snds]
				set len_less_one [expr $len - 1]
				set n 0
				while {$n < $len_less_one} {
					set snd_n [lindex $snds $n]
					set m $n
					incr m
					while {$m < $len} {
						set snd_m [lindex $snds $m]
						if {[string match $snd_m $snd_n]} {
							$f.4.ll.list selection set $m
							$f.4.ll.list selection set $n
							set isdupls 1
						}
						incr m
					}
					incr n
				}
				if {!$isdupls} {
					Inf "No duplicates sounds found"
				}
			}
			7 {
				$f.4.ll.list selection clear 0 end
			}
			8  -
			9  -
			10 -
			11 -
			12 {

				if {$pr_modsindex == 8 || $pr_modsindex == 9} {

					;#	DELETION OR RENUMBER-SELECTED (need to select item/position in list)

					set ilist [.modsindex.4.ll.list curselection]
					if {![info exists ilist] || ([llength $ilist] == 0) || (([llength $ilist] == 1) && ($ilist == -1))} {
						Inf "No item or position-in-list selected"
						continue
					}
					set ilist [lsort -integer -increasing $ilist]
					if {[lindex $ilist 0] == 0} {
						Inf "You cannot modify silent file at index zero"
						continue
					}
				}
				if {$pr_modsindex != 8} {

					;#	RENUMBERING OR INSERTION (but not DELETION) (need to specify a remumbering scheme)

					if {![regexp {^[0-9]+$} $modsindex_stt] || ![IsNumeric $modsindex_stt] || ($modsindex_stt <= 0)} {
						Inf "Invalid renumbering index"
						continue
					}
				}
				switch -- $pr_modsindex {
					8 {
						
						;#	DELETION
						
						set msg "Are you sure you want to delete these items ??"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							continue
						}
						set ilist [ReverseList $ilist]
						foreach i $ilist {
							set sndindexdata [lreplace $sndindexdata $i $i]
							set indxs [lreplace $indxs $i $i]
							set snds [lreplace $snds $i $i]
						}
					} 
					9 {

						;#	RENUMBERING
						
						catch {unset indxstoreplace} 
						catch {unset indxsnu} 
						foreach i $ilist {								;#	Assemble list of indeces to replace
							lappend indxstoreplace [lindex $indxs $i]
						}
 						set len [llength $ilist]
						set n 0
						set m $modsindex_stt
						while {$n < $len} {								;#	Assemble list of new index values
							lappend indxsnu $m
							incr m
							incr n
						}
						set OK 1
						foreach indx $indxs {
							if {[lsearch $indxstoreplace $indx] < 0} {	;#	If index is not one that will be replaced
								if {[lsearch $indxsnu $indx] >= 0} {	;#	If it is equal to one of the replacement-index-values
									Inf "Index $indx already exists elsewhere in the listing"
									set OK 0
									break
								}
							}
						}
						if {!$OK} {
							continue
						}
						foreach i $ilist nuindx $indxsnu {
							set indxlisting [lindex $sndindexdata $i]
							set indxlisting [lreplace $indxlisting 0 0 $nuindx]
							set sndindexdata [lreplace $sndindexdata $i $i $indxlisting ]
							set indxs [lreplace $indxs $i $i $nuindx]
						}
					} 
					10 {

						;#		RENUMBER ALL (EXCEPT FIRST)

 						set len [llength $sndindexdata]
						set n 0			;#	INCR OF INDICES
						set m 1			;#	COUNT OF ENTRIES
						while {$m < $len} {
							set nuindx [expr $modsindex_stt + $n]
							set indxlisting [lindex $sndindexdata $m]
							set indxlisting [lreplace $indxlisting 0 0 $nuindx]
							set sndindexdata [lreplace $sndindexdata $m $m $indxlisting]
							set indxs [lreplace $indxs $m $m $nuindx]
							incr n
							incr m
						}
					} 
					11 -
					12 {
						catch {unset nuindxdata}

						if {$pr_modsindex == 11} {

							;#	INSERTING SOUND(S) AT GIVEN INDEX(es), Check new index(es) don't already exist elsewhere in list

							set OK 1
							set n $modsindex_stt
							foreach fnam $fnams {
								if {[lsearch $indxs $n] >= 0} {						
									Inf "New sound index $n (for snd $fnam) already exists"
									set OK 0
									break
								}
								lappend nuindxdata [list $n $fnam]
								incr n
							}
							if {!$OK} {
								continue
							}

						} else { ;#	pr_modsindex == 12

							;#	IF INSERTING SOUND(S) AT GIVEN INDEX, AND RENUMBERING, MOVE ANY SNDS THAT MIGHT BE OVERWRITTEN

							set max_insert [expr $modsindex_stt + [llength $fnams]]
							set push 0
							foreach indx $indxs {
								if {($indx >= $modsindex_stt) && ($indx < $max_insert)} {	;#	Find fist index lying in "overwritten" area
									set push [expr $max_insert - $indx]						;#	Calc how far to push indexing up, to avoid overwrite
									break
								}
							}
							if {$push} {			;#	Inf ness, renumber the original sndindexdata
								set n 0
								foreach indx $indxs {
									set indxlisting [lindex $sndindexdata $n]
									if {$indx >= $modsindex_stt} {
										incr indx $push
									}
									set indxlisting [lreplace $indxlisting 0 0 $indx]
									set sndindexdata [lreplace $sndindexdata $n $n $indxlisting]
									incr n
								}							
							}
							catch {unset nuindxdata}
							set n $modsindex_stt
							foreach fnam $fnams {
								lappend nuindxdata [list $n $fnam]
								incr n
							}
						}

						;#	ADD THE NEW DATA, IN CORRECT ORDER

						catch {unset nusndindexdata}
						set len [llength $sndindexdata]
						set n 0
						set is_added 0
						while {$n < $len} {
							set indxlisting [lindex $sndindexdata $n]
							set indx [lindex $indxlisting 0]
							if {($indx > $modsindex_stt) && !$is_added} {
								foreach nuindxlisting $nuindxdata {
									lappend nusndindexdata $nuindxlisting
								}
								set is_added 1
							}
							lappend nusndindexdata $indxlisting
							incr n
						}
						if {!$is_added} {
							foreach nuindxlisting $nuindxdata {
								lappend nusndindexdata $nuindxlisting
							}
						}
						set sndindexdata $nusndindexdata
						catch {unset indxs}
						catch {unset snds}
						foreach line $sndindexdata {
							lappend indxs [lindex $line 0]
							lappend snds  [lindex $line 1]
						}
					}
				}				
				;#	MODIFY THE DISPLAY AND ACTIVATE THE "save mods" BUTTON

				.modsindex.4.ll.list delete 0 end
				foreach indxlisting $sndindexdata {
					.modsindex.4.ll.list insert end $indxlisting 
				}
				set is_modified 1
				$f.0.ss config -text "Save Mods" -command "set pr_modsindex 1" -bd 2 -bg $evv(EMPH)
			}
			13 {
				set ilist [.modsindex.4.ll.list curselection]
				if {![info exists ilist] || ([llength $ilist] < 2)} {
					Inf "Select at least 2 items"
					continue
				}
				set ilist [lsort -integer -increasing $ilist]
				set i [lindex $ilist 0]
				if {[lindex $indxs $i] == 0} {
					Inf "You cannot renumber the silent file at index zero"
					continue
				}
				catch {unset nuindxs}
				catch {unset orisnds}
				foreach i $ilist {
					lappend nuindxs [lindex $indxs $i]
					lappend orisnds [lindex $snds $i]
				}
				set nuindxs [ReverseList $nuindxs]
				foreach i $ilist nuindx $nuindxs orisnd $orisnds {
					set indxs [lreplace $indxs $i $i $nuindx]
					set indxlisting [list $nuindx $orisnd]
					set sndindexdata [lreplace $sndindexdata $i $i $indxlisting]
				}
				set n [llength $indxs]
				set len_less_one [expr $len - 1]
				set n 0
				while {$n < $len_less_one} {
					set indx_n [lindex $indxs $n]
					set snd_n  [lindex $snds  $n]
					set indxlisting_n [lindex $sndindexdata $n]
					set m $n
					incr m
					while {$m < $len} {
						set indx_m [lindex $indxs $m]
						set snd_m  [lindex $snds  $m]
						set indxlisting_m [lindex $sndindexdata $m]
						if {$indx_m < $indx_n} {
							set sndindexdata [lreplace $sndindexdata $m $m $indxlisting_n]
							set sndindexdata [lreplace $sndindexdata $n $n $indxlisting_m]
							set snds  [lreplace $snds $m $m $snd_n]
							set snds  [lreplace $snds $n $n $snd_m]
							set indxs [lreplace $indxs $m $m $indx_n]
							set indxs [lreplace $indxs $n $n $indx_m]
							set indx_n $indx_m
							set snd_n  $snd_m
							set indxlisting_n $indxlisting_m
						}
						incr m
					}
					incr n
				}
				.modsindex.4.ll.list delete 0 end
				foreach line $sndindexdata {
					.modsindex.4.ll.list insert end $line
				}
				set is_modified 1
				$f.0.ss config -text "Save Mods" -command "set pr_modsindex 1" -bd 2 -bg $evv(EMPH)
			}
			1 {
				if {!$is_modified} {
					Inf "No change in the sound-index data"
					continue
				}
				if {![ValidCDPRootname $fnam_modsindex]} {
					continue
				}
				set ofnam [string tolower $fnam_modsindex]
				append ofnam $evv(TEXT_EXT)
				if {[string match $ofnam $sifnam]} {
					Inf "You cannot overwrite the input snd-index file here"
					continue
				}
				if {[file exists $ofnam]} {
					set msg "FILE $ofnam ALREADY EXISTS : OVERWRITE IT ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
					if {![CouetteAllowsDelete $ofnam]} {
						continue
					}
					if [catch {file delete -force $ofnam} in] {
						Inf "Cannot delete the existing file."
						continue
					} else {
						DataManage delete $ofnam
						CouettePatchesDelete $ofnam
						DeleteFileFromSrcLists $ofnam
						PurgeArray $ofnam
						DummyHistory $ofnam "OVERWRITTEN"
						set i [LstIndx $ofnam $wl]
						if {$i >= 0} {
							$wl delete $i
						}
					}
				}
				if [catch {open $ofnam "w"} zit] {
					Inf "Cannot open file $ofnam to write new data"
					continue
				}
				foreach line $sndindexdata {
					puts $zit $line
				}
				close $zit
				FileToWkspace $ofnam 0 0 0 0 1
				Inf "File $ofnam is on the workspace"
				set finished 1
			}
			2 {
				if {![regexp {^[0-9]+$} $modsindex_stt] || ![IsNumeric $modsindex_stt]} {
					continue
				}
				incr modsindex_stt
			}
			3 {
				if {![regexp {^[0-9]+$} $modsindex_stt] || ![IsNumeric $modsindex_stt] || ($modsindex_stt <= 1)} {
					continue
				}
				incr modsindex_stt -1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Check sndindexing file for syntax, get its srate, and check first snd is index zer0 and silent

proc IsASndIndexingFileWithSrate {fnam} {
	global sndindexdata pa evv wl maxsamp_line done_maxsamp CDPmaxId
	catch {unset sndindexdata}
	set ftyp $pa($fnam,$evv(FTYP))
	if {!($ftyp & $evv(IS_A_TEXTFILE)) || [IsAListofNumbers $ftyp] || [IsASndlist $ftyp]} {
		Inf "$fnam is not a valid sound-indexing file"
		return 0
	}
	if {[expr $pa($fnam,$evv(LINECNT)) * 2] != $pa($fnam,$evv(ALL_WORDS))} {
		Inf "$fnam is not a valid sound-indexing file "
		return 0
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot open file $fnam"
		return 0
	}
	set OK 1
	set linecnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		catch {unset nuline}
		incr linecnt
		set line [split $line]
		set cnt 0
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			switch -- $cnt {
				0 {
					if {![regexp {^[0-9]+$} $item] || ![IsNumeric $item]} {
						Inf "Non-integer entry for first item in line $linecnt"
						set OK 0
						break
					}
					if {($linecnt == 1) && ($item != 0)} {
						Inf "First sound in list must have index zero, and be a silent file"
						set OK 0
						break
					}
					lappend nuline $item
				} 
				1 {
					if {![file exists $item]} {
						Inf "Entry 2 ($item) on line $linecnt is not an existing soundfile"
						set OK 0
						break
					}
					set ftyp [FindFileType $item]
					if {$ftyp != $evv(SNDFILE)} {
						Inf "2nd entry ($item) on line $linecnt is not a soundfile"
						set OK 0
						break
					}
					if {[LstIndx $item $wl] < 0} {
						if {[FileToWkspace $item 0 0 0 1 0] <= 0} {
							set OK 0
							break
						}
					}
					if {$pa($item,$evv(CHANS)) != 1} {
						Inf "File $item on line $linecnt is not a mono soundfile"
						set OK 0
						break
					}
					if {$linecnt == 1} {
						set srate $pa($item,$evv(SRATE))

						set silfnam $item
						catch {unset maxsamp_line}
						set done_maxsamp 0
						set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
						lappend cmd $silfnam
						lappend cmd 1		;#	1 flag added to FORCE read of maxsample
						if [catch {open "|$cmd"} CDPmaxId] {
							ErrShow "$CDPmaxId"
							continue
						} else {
	   						fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
						}
						vwait done_maxsamp
						if {[info exists maxsamp_line]} {
							set pa($silfnam,$evv(MAXSAMP)) [lindex $maxsamp_line 0]
							if {$pa($silfnam,$evv(MAXSAMP)) > 0.0} {
								Inf "First sound in list must be a silent file"
								set OK 0
								break
							}
						} else {
							Inf "Cannot get max sample information for first sound in list"
							set OK 0
							break
						}
					} elseif {$srate != $pa($item,$evv(SRATE))} {
						Inf "Soundfile ($item) on line $linecnt has different sample rate to earlier soundfiles"
						set OK 0
						break
					}
					lappend nuline $item
				}
			}
			incr cnt
		}
		if {!$OK} {
			break
		}
		if {$cnt != 2} {
			Inf "Wrong number of entries ($cnt) on line $linecnt (should be \"number sndfile\")"
			set OK 0
			break
		}
		lappend nulines $nuline
	}
	close $zit
	if {!$OK} {
		return 0
	}
	if {![info exists nulines]} {
		Inf "No data found in file $fnam"
		return 0
	}
	set sndindexdata $nulines
	return $srate
}

#########################
#	MANAGE TILP FILES	#
#########################

#---- Find all TILP files on workspace

proc FindTILPfiles {force} {
	global TILPlist wl pa evv
	set i 0
	if {$force} {							;#	Use this to set up or check the TILP list
		if {[info exists TILPlist]} {
			foreach fnam $TILPlist {		;#	Check existing TILPlist
				if {![file exists $fnam]} {	;#	for deleted files
					lappend badfiles $fnam
				} else {					;#	and files that are no longer TILP files
					if {[LstIndx $fnam $wl] < 0} {
						set pa($fnam,$evv(FTYP)) [FindFileType $fnam]
						if {![IsATILPFile $fnam 0]} {
							lappend badfiles $fnam
						}
						unset pa($fnam,$evv(FTYP))
					} elseif {![IsATILPFile $fnam 0]} {
						lappend badfiles $fnam
					}
				}
			}
			if {[info exists badfiles]} {	;#	and remove them
				foreach fnam $badfiles {
					set k [lsearch $TILPlist $fnam]
					set TILPlist [lreplace $TILPlist $k $k]
				}
			}
			if {[llength $TILPlist] <= 0} {
				unset TILPlist
			}
		}
		foreach fnam [$wl get 0 end] {		;#	FInd TILP files on the workspace
			if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
				if {[IsATILPFile $fnam 0]} {
					lappend tilpfiles $fnam
				}
			}
			incr i
		}
		if {[info exists tilpfiles]} {		;#	if ness, add these to the TILPlist
			if {[info exists TILPlist]} {
				foreach fnam $tilpfiles {
					if {[lsearch $TILPlist $fnam] < 0} {
						lappend TILPlist $fnam
					}
				}
			} else {
				set TILPlist $tilpfiles
			}
		}
		if {[info exists TILPlist]} {
			set TILPlist [lsort -dictionary $TILPlist]
		}
	} else {								;#	Use TILPlist to hilite TILP files on workspace
		if {[info exists TILPlist]} {
			$wl selection clear 0 end
			foreach fnam [$wl get 0 end] {
				if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
					if {[lsearch $TILPlist $fnam] >= 0} {
						$wl selection set $i
					}
				}				
				incr i
			}
		}
	}
}

#---- Test for TILP file

proc IsATILPFile {fnam inform} {
	global pa evv 
	set ftyp $pa($fnam,$evv(FTYP))
	if {![IsAListofNumbers $ftyp]} {
		if {$inform} {
			Inf "File $ifnam is not a numeric textfile"
		}
		return 0
	}
	if [catch {open $fnam "r"} zit] {
		if {$inform} {
			Inf "Cannot open file $ifnam"
		}
		return 0
	}
	set linecnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		incr linecnt
		catch {unset nuline}
		set line [split $line]
		set cnt 0
		set OK 1
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			switch -- $cnt {
				0 {
					if {$linecnt == 1} {
						if {$item != 0.0} {
							if {$inform} {
								Inf "Initial time in input data file $ifnam must be zero"
							}
							set OK 0
							break
						}
					} elseif {$item < $lasttime} {
						if {$inform} {
							Inf "Times ($lasttime $item) in input data file $ifnam do not increase at line $linecnt"
						}
						set OK 0
						break
					}
					set lasttime $item	
				}
				1 {
					if {![regexp {^[0-9]+$} $item] || ![IsNumeric $item]} {
						if {$inform} {
							Inf "Invalid sound-index value on line $linecnt of file $ifnam"
						}
						set OK 0
						break
					}
					set lastindex $item
				}
				2 {
					if {($item < 0.0) || ($item > 1.0)} {
						if {$inform} {
							Inf "Invalid level value on line $linecnt of file $ifnam"
						}
						set OK 0
						break
					}
				}
				3 {
					if {($item < 0.0) || ($item > 8.0)} {
						if {$inform} {
							Inf "Invalid position value on line $linecnt of file $ifnam"
						}
						set OK 0
						break
					}
				}
			}
			lappend nuline $item
			incr cnt
		}
		if {!$OK} {
			break
		}
		if {$cnt != 4} {
			if {$inform} {
				Inf "Wrong number of values ($cnt) on line ($linecnt) of file $ifnam: requires 4 values"
			}
			set OK 0
			break
		}
	}
	close $zit
	if {!$OK} {
		return 0
	}
	return 1
}

proc LoadTILPfiles {} {
	global TILPlist evv
	set tilpfnam [file join $evv(URES_DIR) tilp$evv(CDP_EXT)]
	if {![file exists $tilpfnam]} {
		return
	}
	if [catch {open $tilpfnam "r"} zit] {
		return
	}
	while {[gets $zit line] >= 0} {
		if {[file exists $line]} {
			lappend TILPlist $line
		}
	}
	close $zit
}

proc SaveTILPfiles {} {
	global TILPlist evv
	if {![info exists TILPlist]} {
		return
	}
	set tilpfnam [file join $evv(URES_DIR) tilp$evv(CDP_EXT)]
	if [catch {open $tilpfnam "w"} zit] {
		return
	}
	foreach fnam $TILPlist {
		puts $zit $fnam
	}
	close $zit
}

#---- Count occurences of each index in a pattern file

proc CountSndIndeces {} {
	global chlist evv pa wstk wl

	if {![info exists chlist] || ([llength $chlist] != 1)} {
		Inf "Select one \"tilp\" rhythm pattern file"
		return
	}
	set ifnam [lindex $chlist 0]
	set outfnam [file rootname [file tail $ifnam]]
	append outfnam _cnt $evv(TEXT_EXT)
	if {[file exists $outfnam]} {
		set msg "COUNT FILE $outfnam ALREADY EXISTS : OVERWRITE IT ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		} elseif [catch {file delete $outfnam} zit] {
			Inf "CANNOT DELETE EXISTING FILE $outfnam"
			return
		} else {
			DataManage delete $outfnam
			CouettePatchesDelete $outfnam
			DeleteFileFromSrcLists $outfnam
			PurgeArray $outfnam
			DummyHistory $outfnam "OVERWRITTEN"
			set i [LstIndx $outfnam $wl]
			if {$i >= 0} {
				$wl delete $i
			}
		}
	}
	set ftyp $pa($ifnam,$evv(FTYP))
	if {![IsAListofNumbers $ftyp]} {
			Inf "File $ifnam does not have the correct \"time  index  level position\" format"
			return
	}
	if [catch {open $ifnam "r"} zit] {
		Inf "Cannot open file $ifnam"
		return
	}
	set linecnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		incr linecnt
		set line [split $line]
		set cnt 0
		set OK 1
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			switch -- $cnt {
				0 {
					if {$linecnt == 1} {
						if {$item != 0.0} {
							Inf "Initial time in input data file $ifnam must be zero"
							set OK 0
							break
						}
					} elseif {$item < $lasttime} {
						Inf "Times ($lasttime $item) in input data file $ifnam do not increase at line $linecnt"
						set OK 0
						break
					}
					set lasttime $item	
				}
				1 {
					if {![regexp {^[0-9]+$} $item] || ![IsNumeric $item]} {
						Inf "Invalid sound-index value on line $linecnt of file $ifnam"
						set OK 0
						break
					}
					if {![info exists idx($item)]} {
						set idx($item) 1
					} else {
						incr idx($item)
					}
				}
				2 {
					if {($item < 0.0) || ($item > 1.0)} {
						Inf "Invalid level value on line $linecnt of file $ifnam"
						set OK 0
						break
					}
				}
				3 {
					if {($item < 0.0) || ($item > 8.0)} {
						Inf "Invalid position value on line $linecnt of file $ifnam"
						set OK 0
						break
					}
				}
			}					
			incr cnt
		}
		if {!$OK} {
			break
		}
		if {$cnt != 4} {
			Inf "Wrong number of values ($cnt) on line ($linecnt) of file $ifnam: requires 4 values"
			set OK 0
			break
		}
	}
	close $zit
	if {!$OK} {
		return
	}
	if {![info exists idx]} {
		return
	}

	;#	SORT INDECES

	foreach nam [array names idx] {
		set line [list $nam $idx($nam)]
		lappend lines $line
	}
	set len [llength $lines]
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set n_line [lindex $lines $n]
		set nval [lindex $n_line 0]
		set m $n
		incr m
		while {$m < $len} {
			set m_line [lindex $lines $m]
			set mval [lindex $m_line 0]
			if {$mval < $nval}  {
				set lines [lreplace $lines $n $n $m_line]
				set lines [lreplace $lines $m $m $n_line]
				set nval $mval
			}
			incr m
		}
		incr n
	}
	if [catch {open $outfnam "w"} zit] {
		Inf "Cannot open counting file $outfnam"
	} else {
		foreach line $lines {
			puts $zit $line
		}
		close $zit
		FileToWkspace $outfnam 0 0 0 0 1
	}

	set msg "[lindex $lines 0]\n"
	set cnt 0
	foreach line [lrange $lines 1 end] {
		append msg "$line\n"
		incr cnt
		if {$cnt >= 20} {
			append msg "and more\n"
			break
		}
	}
	if {[file exists $outfnam]} {
		append msg "\nSee file $outfnam"
	}
	Inf $msg
}

#--- Concatenate Sound-Indexing files

proc ConcatSndIndex {} {
	global chlist pa evv ccindex_fnam pr_ccindex maxsamp_line done_maxsamp CDPmaxId
	
	set startmsg "SELECT TWO OR MORE SOUND-INDEXING FILES"
	if {![info exists chlist] || ([llength $chlist] < 2)} {
		Inf $startmsg 
		return
	}
	set filecnt 0
	set sndfilecnt 0
	Block "CHECKING FILES"
	foreach fnam $chlist {
		wm title .blocker "PLEASE WAIT:        CHECKING FILE [file rootname [file tail $fnam]]"
		if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
			Inf $startmsg 
			UnBlock
			return
		}
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot open file $fnam"
			UnBlock
			return
		}
		set linecnt 0
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			incr linecnt
			if {[string match [string index $line 0] ";"]} {
				continue
			}
			set line [split $line]
			set cnt 0
			set OK 1
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				switch -- $cnt {
					0 {
						if {$linecnt == 1} {
							if {$item != 0.0} {
								Inf "Initial index in input file $fnam must be zero"
								set OK 0
								break
							} elseif {$filecnt == 0} {
								lappend indxs $item
							}
						} else {
							if {[lsearch $indxs $item] >= 0} {
								Inf "All sound indeces must be distinct ($item occurs more than once)"
								set OK 0
								break
							}
							lappend indxs $item
						}
					}
					1 {
						if {$linecnt == 1} {
							if {$filecnt == 0} {
								if {![file exists $item]} {
									Inf "File $index no longer exists"
									set OK 0
									break
								}
								if {![info exists pa($item,$evv(FTYP))]} {
									if {[DoParse $item 0 0 0] <= 0} {
										Inf "Cannot parse file $item"
										set OK 0
										break
									}
								}
								set srate $pa($item,$evv(SRATE))
								set chans $pa($item,$evv(CHANS))
								catch {unset maxsamp_line}
								set done_maxsamp 0
								set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
								lappend cmd $item
								lappend cmd 1		;#	1 flag added to FORCE read of maxsample
								if [catch {open "|$cmd"} CDPmaxId] {
									ErrShow "$CDPmaxId"
									continue
								} else {
	   								fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
								}
								vwait done_maxsamp
								if {[info exists maxsamp_line]} {
									set pa($item,$evv(MAXSAMP)) [lindex $maxsamp_line 0]
									if {$pa($item,$evv(MAXSAMP)) > 0.0} {
										Inf "First sound in list in file $fnam must be a silent file"
										set OK 0
										break
									}
								} else {
									Inf "Cannot get max sample information for file $item in index-file $fnam"
									set OK 0
									break
								}
								lappend sndfiles $item
								incr sndfilecnt
							} else {
								;#	IGNORE
							}
						} else {
							if {![info exists pa($item,$evv(FTYP))]} {
								if {[DoParse $item 0 0 0] <= 0} {
									Inf "Cannot parse file $item in index-file $fnam"
									set OK 0
									break
								}
							}
							if {$pa($item,$evv(SRATE)) != $srate } {
								Inf "Sounds with different sample rates in listings"
								set OK 0
							}
							if {$pa($item,$evv(CHANS)) != $chans } {
								Inf "Not all sounds in have same number of channels"
								set OK 0
							}
							lappend sndfiles $item
							incr sndfilecnt
						}
					}
					default {
						Inf TOo many items on line $linecnt in file $fnam"
						set OK 0
						break
					}
				}
				incr cnt
			}
			if {!$OK} {
				break
			}
			if {$cnt < 2} {
				Inf "Too few items on line $linecnt in file $fnam"
				set OK 0
				break
			}
		}
		close $zit
		if {!$OK} {
			UnBlock
			return
		}
		incr filecnt
	}
	if {[llength $indxs] != $sndfilecnt} {
		Inf "Problem in file accounting"
		UnBlock
		return
	}
	foreach indx $indxs fnam $sndfiles {
		set line [list $indx $fnam]
		lappend lines $line
	}
	set len [llength $indxs]
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set line_n [lindex $lines $n]
		set indx_n [lindex $line_n 0]
		set m $n
		incr m
		while {$m < $len} {
			set line_m [lindex $lines $m]
			set indx_m [lindex $line_m 0]
			if {$indx_m < $indx_n} {
				set lines [lreplace $lines $n $n $line_m]
				set lines [lreplace $lines $m $m $line_n]
				set line_n $line_m
				set indx_n $indx_m
			}
			incr m
		}
		incr n
	}
	UnBlock
	set f .ccindex
	if [Dlg_Create  $f "CONCATENATE SND INDEX LISTINGS" "set pr_ccindex 0" -width 64 -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.ss -text "Concatenate" -command "set pr_ccindex 1" -width 10
		button $f.0.ab -text "Abandon" -command "set pr_ccindex 0" -width 10
		pack $f.0.ss -side left
		pack $f.0.ab -side right
		pack $f.0 -side top -pady 1 -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Output Filename"
		entry $f.1.e -textvariable ccindex_fnam -width 12
		pack $f.1.ll $f.1.e -side right
		pack $f.1 -side top -pady 2
		bind $f <Escape> {set pr_ccindex 0}
		bind $f <Return> {set pr_ccindex 1}
	}
	set finished 0
	set pr_ccindex 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_ccindex $f.1.e
	while {!$finished} {
		tkwait variable pr_ccindex
		if {$pr_ccindex} {
			if {![ValidCDPRootname $ccindex_fnam]} {
				continue
			}
			set ofnam [string tolower $ccindex_fnam]
			append ofnam $evv(TEXT_EXT)
			if {[file exists $ofnam]} {
				Inf "File $ofnam already exists : please choose a different name"
				continue
			}
			if [catch {open $ofnam "w"} zit] {
				Inf "Cannot open file $ofnam to write new data"
				continue
			}
			foreach line $lines {
				puts $zit $line
			}
			close $zit
			FileToWkspace $ofnam 0 0 0 0 1
			Inf "File $ofnam is on the workspace"
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#----------- Change directory of sounds inside a sound-indexing file

proc NewDirSndIndex {} {
	global chlist pa evv wl wksp_dirname

	DeleteAllTemporaryFiles

	set tempofnam $evv(DFLT_OUTNAME)
	append tempofnam $evv(TEXT_EXT)

	set startmsg "SELECT A FILE THAT HAS BEEN A SOUND-INDEXING FILE"

	if {![info exists chlist] || ([llength $chlist] != 1)} {
		Inf $startmsg 
		return
	}
	set ifnam [lindex $chlist 0]

	if {![info exists wksp_dirname] || ([string length $wksp_dirname] <= 0)} {
		Inf "No new directory specified"
		return
	}
	if {![file exists $wksp_dirname] || ![file isdirectory $wksp_dirname]} {
		Inf "$wksp_dirname is not an existing directory"
		return
	}
	set thisdir $wksp_dirname

	if {!($pa($ifnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
		Inf $startmsg 
		return
	}
	if [catch {open $ifnam "r"} zit] {
		Inf "Cannot open file $ifnam"
		return
	}
	set linecnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		incr linecnt
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		set cnt 0
		set OK 1
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			switch -- $cnt {
				0 {
					if {$linecnt == 1} {
						if {$item != 0.0} {
							Inf "Initial index must be zero"
							set OK 0
							break
						} else {
							lappend indxs $item
						}
					} else {
						if {[lsearch $indxs $item] >= 0} {
							Inf "All sound indeces must be distinct ($item occurs more than once)"
							set OK 0
							break
						}
						lappend indxs $item
					}
				}
				1 {
					lappend sndfiles $item
				}
				default {
					Inf TOo many items on line $linecnt"
					set OK 0
					break
				}
			}
			incr cnt
		}
		if {!$OK} {
			break
		}
		if {$cnt < 2} {
			Inf "Too few items on line $linecnt"
			set OK 0
			break
		}
	}
	close $zit
	if {!$OK} {
		return
	}
	set n 0
	foreach fnam $sndfiles {
		set nufnam [file join $thisdir $fnam]
		if {![file exists $nufnam]} {
			Inf	"File $nufnam does not exist"
			return
		}
		if {![info exists pa($nufnam,$evv(FTYP))]} {
			if {[DoParse $nufnam 0 0 0] <= 0} {
				Inf "Cannot parse file $nufnam"
				set OK 0
				break
			}
		}
		if {$n == 0} {
			set srate $pa($nufnam,$evv(SRATE))
			set chans $pa($nufnam,$evv(CHANS))
		} else {
			if {$pa($nufnam,$evv(SRATE)) != $srate } {
				Inf "Sounds with different sample rates are listed"
				return
			}
			if {$pa($nufnam,$evv(CHANS)) != $chans } {
				Inf "Not all listed sounds have same number of channels"
				return
			}
		}
		lappend nufnams $nufnam
		incr n
	}
	foreach indx $indxs fnam $nufnams {
		set line [list $indx $fnam]
		lappend lines $line
	}
	if [catch {open $tempofnam "w"} zit] {
		Inf "Cannot open temporary file to write new values"
		return
	}
	foreach line $lines {
		puts $zit $line
	}
	close $zit
	if [catch {file delete $ifnam} zit] {
		Inf "Cannot delete existing file $ifnam"
		return
	} else {
		DataManage delete $ifnam
		CouettePatchesDelete $ifnam
		DeleteFileFromSrcLists $ifnam
		PurgeArray $ifnam
		DummyHistory $ifnam "OVERWRITTEN"
		set i [LstIndx $ifnam $wl]
		if {$i >= 0} {
			$wl delete $i
		}
	}
	if [catch {file rename $tempofnam $ifnam} zit] {
		Inf "Cannot rename temporary file $tempofnam to $ifnam\ndo this now, outside the loom, before proceeding."
	} else {
		FileToWkspace $ifnam 0 0 0 0 1
	}
}

#--- Get snds in snd-index file to workspace and hilite them

proc GetSndSndIndex {} {
	global chlist wl sndindexdata

	set startmsg "Select a sound-index file\n"

	if {![info exists chlist] || ([llength $chlist] <= 0)} {
		Inf $startmsg
		return
	}
	set sifnam [lindex $chlist 0]
	set srate [IsASndIndexingFileWithSrate $sifnam]
	if {![info exists sndindexdata] || ($srate <= 0)} {
		Inf $startmsg
		return
	}

	;#	CREATE LIST OF SOUNDS ONLY

	foreach line $sndindexdata {
		lappend fnams [lindex $line 1]
	}
	
	;#		ELIMINATE DUPLICATES
	set len [llength $fnams]
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set fnam_n [lindex $fnams $n]
		set m $n
		incr m
		while {$m < $len} {
			set fnam_m [lindex $fnams $m]
			if {$fnam_n == $fnam_m} {
				set fnams [lreplace $fnams $m $m]
				incr len -1
				incr len_less_one -1
			} else {
				incr m
			}
		}
		incr n
	}
	set fnams [ReverseList $fnams]
	foreach fnam $fnams {
		set i [LstIndx $fnam $wl] 
		if {$i < 0} {
			if {[FileToWkspace $fnam 0 0 0 0 1] <= 0} {
				lappend badfiles $fnam
			}
		} else {
			$wl delete $i 
			$wl insert 0 $fnam
		}
	}
	if {[info exists badfiles]} {
		set k [llength $badfiles]
		incr len -$k
	}
	$wl selection clear 0 end
	set i 0
	while {$i < $len} {
		$wl selection set $i
		incr i
	}
}

proc HelpLogistic {} {
	set msg "THE LOGISTIC EQUATION\n"
	append msg "\n"
	append msg "This process outputs pitched-lines which map the outputs of the Logistic equation.\n"
	append msg "\n"
	append msg "The logistic equation is a very simplified model of the relationship between \n"
	append msg "the population size of a predator species (P) and that of its prey (p),\n"
	append msg "and is a very simple model of a potentially chaotic system.\n"
	append msg "The predator population size is expressed as a fraction \"F\" of its maximum possible size.\n"
	append msg "\n"
	append msg "With a large prey population, food is abundant and F grows in size. But eventually there is\n"
	append msg "insufficient food to go round, so F begins to fall. (The prey population varies in an inverse way).\n"
	append msg "Thus the predator population size fluctuates from generation to generation.\n"
	append msg "\n"
	append msg "The iterations of the logistic equation map these population changes from one generation to another.\n"
	append msg "A constant, \"R\", in the equation, determines the nature of this fluctuation.\n"
	append msg "With a small value of \"R\", whatever the initial value of \"F\", after several iterations\n"
	append msg "the population always reaches the same constant value (where predator and prey are in equilibrium).\n"
	append msg "With higher values of \"R\", \"F\" gravitates towards cycling between 2 or more different stable values.\n"
	append msg "With very high \"R\", \"F\" varies chaotically from one generation to the next.\n"
	append msg "\n"
	append msg "~~~ CONVERSION TO SOUND ~~~\n"
	append msg "\n"
	append msg "The process takes an input sound & generates pitched output-lines, each starting at a random pitch.\n"
	append msg "(Output is generated by delay-with-feedback, and will not be obviously related in sonority to the input).\n"
	append msg "The pitch contour in any output-line follows the fluctuation in population size from generation to generation.\n"
	append msg "\n"
	append msg "\"WHICH CYCLIC AREA ?\" specifies which of the cyclic or chaotic behaviours\n"
	append msg "the output pitch-lines will gravitate towards, or which range of behaviours they will follow.\n"
	append msg "\n"
	append msg "~~~ LINE PARAMETERS ~~~\n"
	append msg "\n"
	append msg "(1) NUMBER OF OUTPUT LINES : determines how many pitch-lines are output.\n"
	append msg "\n"
	append msg "(2) EVENT TAIL DURATION : determines how long the lines will continue, AFTER the population they represent\n"
	append msg "        has become stable (fixed pitch) or cyclic (alternating between fixed pitches).\n"
	append msg "\n"
	append msg "(3) EVENT FADE DURATION : determines the length of the fade-to-zero at the end of each line.\n"
	append msg "\n"
	append msg "(4) MAXIMUM LINE DURATION : determines the maximum duration of any line.\n"
	append msg "        (Necessary as, with chaotic behaviour, no stable pitch or pitch-cycle is ever reached).\n"
	append msg "\n"
	append msg "~~~ NOTE PARAMETERS ~~~\n"
	append msg "(Parameters of events within the lines)\n"
	append msg "\n"
	append msg "(1) MIN/MAX TIMESTEP BETWEEN NOTE ENTRIES: minimum and maximum timestep between events in the line.\n"
	append msg "\n"
	append msg "(2) NOTE TIME RANDOMISATION : Randomisation of timing of events in line.\n"
	append msg "\n"
	append msg "(3) MINIMUM/MAXIMUM PITCH OF MIDI RANGE : Limits of range of pitches to be used for the output lines.\n"
	append msg "\n"
	append msg "(4) NOTE INFADE/OUTFADE DURATION : The attack and decay times of the events in the lines.\n"
	append msg "\n"
	append msg "(5) MIN/MAX PROPORTION OF NOTE DURATION WHICH IS SILENT: \n"
	append msg "        Determines the amount of (silence) separation between events in the lines.\n"
	append msg "\n"
	append msg "(6) SEED : A non-zero value generates the same output (from an identical parameter set) on each pass.\n"
	append msg "        A ZERO value generates randomly different outputs from an identical parameter set on each pass.\n"
	Inf $msg
}
