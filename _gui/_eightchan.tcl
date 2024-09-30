#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD 30 June 2013
# ... fixup button rectangles

############################
# 8 CHANNEL SPATIALISATION #
############################

#--- Arranging channels of mono, stereo, quad or 8-chan source files on the octaphonic stage.

proc SetStage {} {
	global total_stage_outchans stage_outchans stage_outstage stagcan stage_inchans pr_stage is_stage1 stage_inchans_set stage_done_chans stagecnt stage_eight_done 
	global stagemix pa chlist wstk stage_last axcolor stage_infile_cnt stage_outfile_cnt stage_fnam stage_chans stage_outlines chchans pr2 evv
	global stage_outbal stage_outlevels readonlybg readonlyfg mchanqikfnam stage_output_chans disstage_last stage_this_standard

	catch {unset stage_this_standard}

	catch {unset disstage_last}
	if {![info exists chlist] || ([llength $chlist] < 1)} {
		Inf "No Files Selected"
		return
	}
	catch {unset chchans}
	catch {unset stage_eight_done}
	catch {unset stage_outlines}
	catch {unset stage_standard_saved}
	foreach fnam $chlist {
		if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
			Inf "Not All Selected Files Are Soundfiles"
			return
		}
		if {$pa($fnam,$evv(CHANS)) > 8} {
			Inf "Program Only Handles Files With Maximum Of 8 Input Channels: File '$fnam' Has Too Many Channels"
			return
		}
		lappend chchans $pa($fnam,$evv(CHANS))
	}
	set stage_output_chans 0
	set stage_infile_cnt [llength $chlist]
	set stage_outfile_cnt 0
	set axcolor(1) red
	set axcolor(2) orange
	set axcolor(3) yellow
	set axcolor(4) green
	set axcolor(5) "\{dark green\}"
	set axcolor(6) "\{dark blue\}"
	set axcolor(7) blue
	set axcolor(8) magenta
	set stage_fnam [lindex $chlist 0]
	catch {unset stage_inchans}
	catch {unset stage_outchans}
	set stage_outstage {}
	set total_stage_outchans {}
	set is_stage1 {}
	set stage_done_chans {}
	set stage_inchans_set 0
	set stagecnt 1
	set stage_chans [lindex $chchans 0]
	set f .octagon
	if [Dlg_Create $f "SETUP SOUNDFILE(S) ON MULTICHANNEL STAGE" "set pr_stage 0" -width 184 -borderwidth $evv(SBDR)] {
		frame $f.0
		frame $f.1 -bg black -width 1
		frame $f.2
		frame $f.2.1
		frame $f.2.2 -bg black -width 1
		frame $f.2.3
		frame $f.2.4 -bg black -width 1
		frame $f.2.1.1
		frame $f.2.1.2
		frame $f.2.5
	
		button $f.0.help -text "Help" -command HelpOctStage -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.0.do -text "Output Staging"   -command "set pr_stage 1" -highlightbackground [option get . background {}]
		button $f.0.qk -text "QikEdit Staging" -command "set pr_stage 7" -highlightbackground [option get . background {}]
		button $f.0.rs -text "Start File Again" -command "set pr_stage 2" -highlightbackground [option get . background {}]
		entry $f.0.e -textvariable stagemix -width 16
		label $f.0.le -text "OutputMix Name"
		button $f.0.b -text "Get Existing Mix" -command GetStageMix -width 23 -highlightbackground [option get . background {}]
		menubutton $f.0.mb -text "STANDARD FORMATS" -menu $f.0.mb.menu -relief raised -width 24
		menu .octagon.0.mb.menu -tearoff 0
		bind .octagon.0.mb <ButtonRelease-1> {CheckStageDisplayed}

		button $f.0.q  -text "Quit"  -command "set pr_stage 0" -highlightbackground [option get . background {}]
		pack $f.0.help -side left
		pack $f.0.do $f.0.qk $f.0.rs $f.0.e $f.0.le $f.0.b $f.0.mb -side left -padx 2
		pack $f.0.q -side right
		pack $f.0 -side top -fill x -expand true
		pack $f.1 -side top -fill x -expand true -pady 4

		label $f.2.1.1.ic -text ""
		pack $f.2.1.1.ic -side top
		pack $f.2.1.1 -side top -fill x -expand true -anchor w
		set n 1
		while {$n <= 8} {
			button $f.2.1.2.b$n -text "" -width 2 -command {} -bd 0 -highlightbackground [option get . background {}]
			pack $f.2.1.2.b$n -side left
			incr n
		}
		pack $f.2.1.2 -side top
		button $f.2.1.3 -text "" -command {} -bd 0 -width 48 -highlightbackground [option get . background {}]
		frame $f.2.1.4
		button $f.2.1.4.ok -text "" -command {} -bd 0 -width 4 -highlightbackground [option get . background {}]
		button $f.2.1.4.no -text "" -command {} -bd 0 -width 4 -highlightbackground [option get . background {}]
		pack $f.2.1.4.ok $f.2.1.4.no -side left
		pack $f.2.1.3 $f.2.1.4 -side top -pady 2
		pack $f.2.1 -side left
		pack $f.2.2 -side left -fill y -expand true -padx 4

		set stagcan [canvas $f.2.3.c -height 400 -width 400 -borderwidth 0 -highlightthickness 1 -highlightbackground $evv(SPECIAL)]

		$stagcan create text 50 14 -text "Output Stage" -fill $evv(POINT) -tag setup
		frame $stagcan.ff -bd 0
		$stagcan create window 14 20 -anchor w -window $stagcan.ff
		button $stagcan.ff.5 -text 5 -width 2 -command "EstablishOutputStageDisplay 5" -highlightbackground [option get . background {}]
		button $stagcan.ff.7 -text 7 -width 2 -command "EstablishOutputStageDisplay 7" -highlightbackground [option get . background {}]
		button $stagcan.ff.81 -text 8 -width 2 -command "EstablishOutputStageDisplay 8" -highlightbackground [option get . background {}]
		button $stagcan.ff.8 -text "8s" -width 2 -command "EstablishOutputStageDisplay 8s" -highlightbackground [option get . background {}]
		pack $stagcan.ff.5 $stagcan.ff.7 $stagcan.ff.81 $stagcan.ff.8 -side left

		pack $f.2.3.c -side left
		pack $f.2.3 -side left
		pack $f.2.4 -side left -fill y -expand true -padx 4
		frame $f.2.5.0
		label $f.2.5.0.0 -text "" -width 32
		button $f.2.5.0.1 -text "" -command {} -width 6 -bd 0 -highlightbackground [option get . background {}]
		pack $f.2.5.0.0 $f.2.5.0.1 -side left -padx 2 
		pack $f.2.5.0 -side top -pady 1
		set n 1
		while {$n <= 8} {
			frame $f.2.5.$n
			entry $f.2.5.$n.e -textvariable stage_outbal($n) -width 4 -state readonly -foreground $readonlyfg -readonlybackground [option get . background {}] -bd 0
			label $f.2.5.$n.ll -text "" -width 10
			pack $f.2.5.$n.e $f.2.5.$n.ll -side left
			pack $f.2.5.$n -side top -pady 1 
			incr n
		}
		pack $f.2.5 -side left
		pack $f.1 $f.2 -side top -pady 2
		wm resizable $f 1 1
		bind $f <Return> {set pr_stage 1}
		bind $f <Escape> {set pr_stage 0}
	}
	set stagemix ""
	set pr_stage 0
	raise .octagon
	update idletasks
	StandardPosition .octagon
	My_Grab 0 .octagon pr_stage						;#	Create brkfile, and give it a name
	set finished 0
	while {!$finished} {
		tkwait variable pr_stage
		if {($pr_stage > 0) && ($stage_output_chans == 0)} {
			Inf "Select Output Stage First"
			continue
		}
		switch -- $pr_stage {
			0 {
				if {[llength $total_stage_outchans] > 0} {
					set msg "Exit Without Saving Any Staging Data ??"
					set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
					if {$choice == "no"} {
						continue
					}
				}
				set stage_outstage {}
				set finished 1
			}
			1 {
				if {[string length $stagemix] <= 0} {
					Inf "No Output Mixfile Name Entered"
					continue
				}
				set rname [file rootname [file tail $stagemix]]
				if {![ValidCDPRootname $rname]} {
					continue
				}
				if {![info exists stage_outlines]} {
					Inf "Data (Verified) Incomplete"
					continue
				}
				set stagemixout [string tolower $stagemix]
				if {![info exists stage_eight_done]} {
					set msg "Staging Not Complete : Save And Quit Anyway ??"
					set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
					if {$choice == "no"} {
						continue
					}
				}
				set do_standard 0
				if {[info exists stage_standard_saved]} {
					set k [lsearch $stage_standard_saved $stagemixout]
					if {$k < 0} {
						set do_standard 1
					}
				} else  {
					set do_standard 1
				}
				if {$do_standard} {
					if {![info exists stage_this_standard]} {
						set msg "Retain as a standard format ??"
						set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
						if {$choice == "yes"} {
							if {![SaveStandardStage]} {
								continue
							}
						}
					}
				}
				if {[string length [file extension $stagemixout]] <= 0} {
					append stagemixout [GetTextfileExtension mmx]
				}
				if {[file exists $stagemixout]} {
					set msg "Append Lines To Existing File '$stagemixout' ??"
					set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
					if {$choice == "no"} {
						set msg "Overwrite Existing File '$stagemixout' ??"
						set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
						if {$choice == "no"} {
							Inf "Waiting For You To Input New Output Mixfile Name"	
							continue
						} else {
							if {![DeleteNonSndfileFromSystem $stagemixout]} {
								Inf "Cannot Delete Existing Mixfile '$stagemixout'"
								continue
							}
							if [catch {open $stagemixout "w"} zit] {
								Inf "Cannot Open Mixfile '$stagemixout' To Write Data"
								continue
							}
							set line $stage_output_chans
							puts $zit $line
						}
					} else {
						if [catch {open $stagemixout "a"} zit] {
							Inf "Cannot Open Mixfile '$stagemixout' To Append Data"
							continue
						}
					}
				} else {
					if [catch {open $stagemixout "w"} zit] {
						Inf "Cannot Open Mixfile '$stagemixout' To Write Data"
						continue
					}
					set line $stage_output_chans
					puts $zit $line
				}
				foreach line $stage_outlines {
					puts $zit $line
				}
				close $zit
				FileToWkspace $stagemixout 0 0 0 0 0
				if {[MixMUpdate $stagemixout 0]} {
					MixMStore
				}
				Inf "File '$stagemixout' Is On The Workspace"
				set finished 1
			}
			2 {
				if {$stage_outfile_cnt == 0} {
					Inf "No Data Saved Yet"
				}
				set stage_outstage {}
				set total_stage_outchans {}
				set stage_done_chans {}
				DeselectStageIchans $stage_chans
				catch {unset stage_outchans}
				catch {unset stage_inchans}
				set is_stage1 {}
				ResetOctagon
				set n 1
				while {$n <= $stage_chans} {
					.octagon.2.1.2.b$n config -state normal
					incr n
				}
				if {$stage_chans == 1} {
					$f.2.1.2.b1 config -background $evv(EMPH)
					set stage_inchans 1
					.octagon.2.1.3 config -text "Finished Assigning Outputs to the Input Channel" -command "set pr_stage 3" -bd 2
					set stage_inchans_set 1
				} else {
					.octagon.2.1.3 config -text "" -command {} -bd 0
					set stage_inchans_set 0
				}
				set n 1
				while {$n <= $stagecnt} {
					catch {$stagcan delete axes$n}
					incr n
				}
				incr stage_outfile_cnt -1
			}
			3 {
				if {![info exists stage_outchans] || ([llength $stage_outchans] <= 0)} {
					Inf "No Output Channels Assigned Yet"
					continue
				}
				if {[llength $stage_outchans] > 1} {
					DisplayStageOutputLevels
				} else {
					.octagon.2.1.4.ok config -text "OK" -command   "set pr_stage 4" -bd 2
					.octagon.2.1.4.no config -text "Redo" -command "set pr_stage 5" -bd 2
				}
			}
			4 {
				.octagon.2.1.4.ok config -text "" -command {} -bd 0
				.octagon.2.1.4.no config -text "" -command {} -bd 0
				if {[lindex $stage_outchans 0] != [lindex $stage_outchans end]} {		;#	COMPLETE THE GRAPHICS
					set axcoords [concat [LspkrToOctagonCoords [lindex $stage_outchans end]] [LspkrToOctagonCoords [lindex $stage_outchans 0]]]
					eval {$stagcan create line} $axcoords {-width 4} {-tag axes$stagecnt} -fill $axcolor($stagecnt)
				}
				if {[llength $stage_outchans] == 1} {
					set stage_outlevels 1
				} else {
					set stage_outchans [lsort $stage_outchans] 
				}
				foreach oc $stage_outchans lev $stage_outlevels {						;# (ADD) INFO TO OUTPUT DATA
					lappend total_stage_outchans [lindex $stage_inchans 0] $oc $lev
				}
				if {$stage_chans == 1} {														;#	IF ONLY 1 INPUT CHAN, WE'VE FINISHED ANYWAY			
					set stage_outstage $total_stage_outchans
					set msg "All Channels Assigned For File [file rootname [file tail $stage_fnam]]"
					incr stage_outfile_cnt
					SaveStageData 0
					if {$stage_outfile_cnt == $stage_infile_cnt} {
						append msg "\n\nSave Data If Happy With This Staging"
						Inf $msg
						set stage_eight_done 1
					} else {
						ResetForNextFileEntry
						append msg ": Proceeding To File '[file rootname [file tail $stage_fnam]]'"
						Inf $msg
					}
					continue
				}
				foreach chan $stage_inchans {
					lappend stage_done_chans $chan
					.octagon.2.1.2.b$chan config -state disabled
				}
				incr stagecnt
				set still_to_do 0
				if {$stage_chans > 1} {
					set n 1
					while {$n <= $stage_chans} {
						if {[lsearch $stage_done_chans $n] < 0} {
							.octagon.2.1.2.b$n config -state normal -bg [option get . background {}]
							set still_to_do 1
						}
						incr n
					}
					set stage_inchans_set 0
					.octagon.2.1.3 config -text "" -command {} -bd 0
				}
				catch {unset stage_outchans}												;#	RESET FOR FURTHER DATA ENTRY
				catch {unset stage_inchans}
				catch {unset stage_levels}
				set is_stage1 {}
				if {!$still_to_do} {
					set msg "All Channels Assigned For File '[file rootname [file tail $stage_fnam]]'"
					incr stage_outfile_cnt
					SaveStageData 0
					if {$stage_outfile_cnt == $stage_infile_cnt} {
						append msg "\n\nSave Data If Happy With This Staging"
						Inf $msg
						set stage_eight_done 1
					} else {
						ResetForNextFileEntry
						append msg ": Proceeding To File '[file rootname [file tail $stage_fnam]]'"
						Inf $msg
					}
				}
			}
			5 {
				.octagon.2.1.4.ok config -text "" -command {} -bd 0
				.octagon.2.1.4.no config -text "" -command {} -bd 0
				catch {unset outused}
				$stagcan delete axes$stagecnt
				foreach {in out} $total_stage_outchans {
					lappend inused $in
					lappend outused $out
				}
				if {[info exists outused]} {
					foreach channo $stage_inchans lspkrno $stage_outchans {
						if {[lsearch $outused $lspkrno] < 0} {
							set obj [$stagcan find withtag k$lspkrno]
							$stagcan itemconfig $obj -fill [option get . background {}]
						}
# GETTING RID OF UNWANTED OUT-CHAN NUMBERS
						set obj [$stagcan find withtag outo$lspkrno]
						set thisstr [$stagcan itemcget $obj -text]
						set thisstr [split $thisstr ","]
						set len [llength $thisstr]
						set n $len
						incr n -1
						while {$n >= 0} {
							set chan [lindex $thisstr $n]
							if {[lsearch $inused $chan] < 0} {
								set thisstr [lreplace $thisstr $n $n]
							}
							incr n -1
						}
						set thisstr [join $thisstr ","]
						$stagcan itemconfig $obj -text $thisstr
					}
				} else {
					foreach obj [$stagcan find withtag lspkr] {
						$stagcan itemconfig $obj -fill [option get . background {}]
					}
# GETTING RID OF UNWANTED OUT-CHAN NUMBERS
					foreach obj [$stagcan find withtag outo] {
						$stagcan itemconfig $obj -text ""
					}
				}
				if {$stage_chans > 1} {
					set n 1
					while  {$n <= $stage_chans} {
						if {[lsearch $stage_done_chans $n] < 0} {
							.octagon.2.1.2.b$n config -state normal -bg [option get . background {}]
						}
						incr n
					}
					set stage_inchans_set 0
					.octagon.2.1.3 config -text "" -command {} -bd 0
					catch {unset stage_inchans}
				}
				catch {unset stage_outchans}											;#	RESET FOR FURTHER DATA ENTRY
				catch {unset stage_outlevels}
				set is_stage1 {}
			}
			6 {
				catch {unset stage_outlevels}
				set n 1
				while {$n <= $stage_output_chans} {
					if {[string length $stage_outbal($n)] > 0} {
						lappend stage_outlevels $stage_outbal($n)
					}
					incr n
				}
				HideStageOutputLevels
				.octagon.2.1.4.ok config -text "OK" -command   "set pr_stage 4" -bd 2 -state normal
				.octagon.2.1.4.no config -text "Redo" -command "set pr_stage 5" -bd 2 -state normal
			}
			7 {
				if {[string length $stagemix] <= 0} {
					Inf "No Output Mixfile Name Entered"
					continue
				}
				set rname [file rootname [file tail $stagemix]]
				if {![ValidCDPRootname $rname]} {
					continue
				}
				if {![info exists stage_outlines]} {
					Inf "Data (Verified) Incomplete"
					continue
				}
				if {![info exists stage_eight_done]} {
					set msg "Staging Not Complete : Save And Go To Qik-Edit Anyway ??"
					set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
					if {$choice == "no"} {
						continue
					}
				}
				set stagemixout [string tolower $stagemix]
				if {[string length [file extension $stagemixout]] <= 0} {
					append stagemixout [GetTextfileExtension mmx]
				}
				if {[file exists $stagemixout]} {
					set msg "Append Lines To Existing File '$stagemixout' ??"
					set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
					if {$choice == "no"} {
						set msg "Overwrite Existing File '$stagemixout' ??"
						set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
						if {$choice == "no"} {
							Inf "Waiting For You To Input New Output Mixfile Name"	
							continue
						} else {
							if {![DeleteNonSndfileFromSystem $stagemixout]} {
								Inf "Cannot Delete Existing Mixfile '$stagemixout'"
								continue
							}
							if [catch {open $stagemixout "w"} zit] {
								Inf "Cannot Open Mixfile '$stagemixout' To Write Data"
								continue
							}
							set line $stage_output_chans
							puts $zit $line
						}
					} else {
						if [catch {open $stagemixout "a"} zit] {
							Inf "Cannot Open Mixfile '$stagemixout' To Append Data"
							continue
						}
					}
				} else {
					if [catch {open $stagemixout "w"} zit] {
						Inf "Cannot Open Mixfile '$stagemixout' To Write Data"
						continue
					}
					set line $stage_output_chans
					puts $zit $line
				}
				foreach line $stage_outlines {
					puts $zit $line
				}
				close $zit
				FileToWkspace $stagemixout 0 0 0 0 0
				if {[MixMUpdate $stagemixout 0]} {
					MixMStore
				}
				Inf "File '$stagemixout' Is On The Workspace"
				set mchanqikfnam $stagemixout
				EditSrcMixfile mix3
				set finished 1
			}
			8 {
				catch {unset stage_outchans}	;#	STANDARD STAGING HAS BEEN ASSIGNED; RESET FOR FURTHER DATA ENTRY
				catch {unset stage_inchans}
				catch {unset stage_levels}
				set is_stage1 {}
				ConfigureOctInterface 0 $stage_fnam
				set msg "All Channels Assigned For File '[file rootname [file tail $stage_fnam]]'"
				incr stage_outfile_cnt
				SaveStageData 1
				if {$stage_outfile_cnt == $stage_infile_cnt} {
					append msg "\n\nSave Data If Happy With This Staging"
					Inf $msg
					set stage_eight_done 1
				} else {
					ResetForNextFileEntry
					append msg ": Proceeding To File '[file rootname [file tail $stage_fnam]]'"
					Inf $msg
				}
			}
		}
	}
	My_Release_to_Dialog .octagon
	Dlg_Dismiss .octagon
	destroy $f
	set stage_last 1
	set pr2 3
}

#---- Mark the clicked-near loudspeaker to receive the current input channel

proc MarkLspkr {w x y} {
	global is_stage1 total_stage_outchans stage_outchans stage_inchans thisstagecolor 
	global stage_inchans_set stage_done_chans stagecnt stagcan axcolor wstk evv
	global stage_infile_cnt stage_outfile_cnt stage_fnam stage_chans stage_eight_done
	global stage_output_chans eightchan_stereo_centred

	if {![info exists stage_inchans]} {
		Inf "Choose Input Channel(s) First"
		return
	}
	set still_to_do 1
	if {!$stage_inchans_set} {
		if {[llength $stage_inchans] == 1} {
			.octagon.2.1.3 config -text "Finished Assigning Outputs to This Input Channel" -command "set pr_stage 3" -bd 2
		} else {
			.octagon.2.1.3 config -text "" -command {} -bd 0
		}
		set stage_inchans_set 1
		set n 1
		while {$n <= $stage_chans} {
			.octagon.2.1.2.b$n config -state disabled
			incr n
		}
	}
	set displaylist [$w find withtag lspkr]	;#	List all objects which are loudspeakers
	set mindiff 100000								;#	Find closest point
	foreach thisobj $displaylist {
		set coords [$w coords $thisobj]
		set xx [lindex $coords 0]
		set yy [lindex $coords 1]
		set diff [expr abs($x - $xx) + abs($y - $yy)]
		if {$diff < $mindiff} {
			set yyy $yy
			set xxx $xx
			set mindiff $diff
		}
	}
	if {![info exists yyy]} {
		Inf "No Loudspeaker Found At Mouse Click"
		return
	}
	set xxx [expr int(round($xxx))]
	set yyy [expr int(round($yyy))]
	switch -- $stage_output_chans {
		8 {
			if {$eightchan_stereo_centred} {
				switch -- $xxx {
					147 {
						if {$yyy == 37} {
							set lspkrno 1 
						} else {
							set lspkrno 6 
						}
					}
					247 {
						if {$yyy == 37} {
							set lspkrno 2 
						} else {
							set lspkrno 5 
						}
					}
					317 {
						if {$yyy == 107} {
							set lspkrno 3
						} else {
							set lspkrno 4
						}
					}
					77  {
						if {$yyy == 207} {
							set lspkrno 7
						} else {
							set lspkrno 8
						}
					}
				}
			} else {
				switch -- $xxx {
					197 {
						if {$yyy == 37} {
							set lspkrno 1 
						} else {
							set lspkrno 5 
						}
					}
					277 {
						if {$yyy == 87} {
							set lspkrno 2 
						} else {
							set lspkrno 4 
						}
					}
					327 {
						set lspkrno 3 
					}
					117 {
						if {$yyy == 247} {
							set lspkrno 6 
						} else {
							set lspkrno 8 
						}
					}
					67 {
						set lspkrno 7
					}
				}
			}
		}
		7 {
			switch -- $xxx {
				197 {
					set lspkrno 1 
				}
				117 {
					set lspkrno 2 
				}
				277 {
					set lspkrno 3
				}
				77  {
					if {$yyy == 207} {
						set lspkrno 4
					} else {
						set lspkrno 6
					}
				}
				317 {
					if {$yyy == 207} {
						set lspkrno 5
					} else {
						set lspkrno 7
					}
				}
			}
		}
		5 {
			switch -- $xxx {
				197 {
					set lspkrno 1 
				}
				117 {
					set lspkrno 2 
				}
				277 {
					set lspkrno 3
				}
				77  {
					set lspkrno 4
				}
				317 {
					set lspkrno 5
				}
			}
		}
	}
	if {[llength $stage_inchans] == 1} {
		if {[info exists stage_outchans] && ([lsearch $stage_outchans $lspkrno] >= 0)} {
			Inf "This Channel Has Already Been Assigned"
			return
		}
	}
	foreach obj [$w find withtag k$lspkrno] {
		$w itemconfig $obj -fill $evv(POINT)
	}
	if {[llength $stage_inchans] == 1} {
		set io 0
	} else {
		if {![info exists stage_outchans] || ([llength $stage_outchans]) <= 0} {
			set io 0
		} else {
			set io [llength $stage_outchans]		;#	HOW MANY OUTCHANS ALREADY SPECIFIED
		}
	}
#ADDING THE INPUT CHAN INFO TO DIAGRAM, WORKS .... NEED TO NOW DELETE IT !!!
	set ichan [lindex $stage_inchans $io]
	set obj [$w find withtag outo$lspkrno]
	set thisstr [$w itemcget $obj -text]
	set thisstr [split $thisstr ","]
	if {[lsearch $thisstr $ichan] < 0} {
		lappend thisstr $ichan
	}
	set thisstr [join $thisstr ","]
	$w itemconfig $obj -text $thisstr

	set xc [expr $xxx + 3]
	set yc [expr $yyy + 3]
	if {[llength $is_stage1] > 0} {
		set axcoords [concat $is_stage1 $xc $yc]
		eval {$w create line} $axcoords {-width 4} {-tag axes$stagecnt} -fill $axcolor($stagecnt)
	}
	set is_stage1 [list $xc $yc]
	lappend stage_outchans $lspkrno

	if {[llength $stage_inchans] > 1} {
		if {[llength $stage_outchans] >= [llength $stage_inchans]} {
			if {[lindex $stage_outchans 0] != [lindex $stage_outchans end]} {
				set axcoords [concat [LspkrToOctagonCoords [lindex $stage_outchans end]] [LspkrToOctagonCoords [lindex $stage_outchans 0]]]
				eval {$w create line} $axcoords {-width 4} {-tag axes$stagecnt} -fill $axcolor($stagecnt)
			}
			set msg "All Channels Have Been Assigned To Stage."
			append msg "\nAre You Happy With This Assignment ??"
			set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
			if {$choice == "no"} {
				catch {$stagcan delete -tag axes$stagecnt}
				catch {unset outused}
				foreach {in out} $total_stage_outchans {
					lappend inused $in
					lappend outused $out
				} 
				if {[info exists outused]} {
					foreach channo $stage_inchans lspkrno $stage_outchans {
						if {[lsearch $outused $lspkrno] < 0} {
							set obj [$stagcan find withtag k$lspkrno]
							$stagcan itemconfig $obj -fill [option get . background {}]
						}
# GETTING RID OF UNWANTED OUT-CHAN NUMBERS
						set obj [$w find withtag outo$lspkrno]
						set thisstr [$w itemcget $obj -text]
						set thisstr [split $thisstr ","]
						set len [llength $thisstr]
						set n $len
						incr n -1
						while {$n >= 0} {
							set chan [lindex $thisstr $n]
							if {[lsearch $inused $chan] < 0} {
								set thisstr [lreplace $thisstr $n $n]
							}
							incr n -1
						}
						set thisstr [join $thisstr ","]
						$w itemconfig $obj -text $thisstr
					}

				} else {
					foreach obj [$stagcan find withtag lspkr] {
						$stagcan itemconfig $obj -fill [option get . background {}]
					}
					foreach obj [$stagcan find withtag outo] {
						$stagcan itemconfig $obj -text ""
					}
				}
				catch {unset stage_outchans}
				if {$stage_chans > 1} {
					set n 1
					while  {$n <= $stage_chans} {
						if {[lsearch $stage_done_chans $n] < 0} {
							.octagon.2.1.2.b$n config -state normal -bg [option get . background {}]
						}
						incr n
					}
					catch {unset stage_inchans}
					set stage_inchans_set 0
				}
				set is_stage1 {}
			} else {
				foreach ic $stage_inchans oc $stage_outchans {
					lappend total_stage_outchans $ic $oc 1.0
					lappend stage_done_chans $ic
				}
				set still_to_do 0
				set n 1
				if {$stage_chans > 1} {
					set n 1
					while {$n <= $stage_chans} {
						if {[lsearch $stage_done_chans $n] < 0} {
							.octagon.2.1.2.b$n config -state normal -background [option get . background {}]
							set still_to_do 1
						} else {
							.octagon.2.1.2.b$n config -state disabled
						}
						incr n
					}
				}
				catch {unset stage_outchans}
				catch {unset stage_inchans}
				set is_stage1 {}
				incr stagecnt
			}
		}
	}
	if {!$still_to_do} {
		set msg "All Channels Assigned For File '[file rootname [file tail $stage_fnam]]'"
		incr stage_outfile_cnt
		SaveStageData 0
		if {$stage_outfile_cnt == $stage_infile_cnt} {
			append msg "\n\nSave Data If Happy With This Staging"
			set stage_eight_done 1
			Inf $msg
		} else {
			ResetForNextFileEntry
			append msg ": Proceeding To File '[file rootname [file tail $stage_fnam]]'"
			Inf $msg
		}
	}
}

#---- Reset Octagon canvas to pristine state

proc ResetOctagon {} {
	global stagcan stagecnt

	foreach obj [$stagcan find withtag lspkr] {
		$stagcan itemconfig $obj -fill [option get . background {}]
	}
	foreach obj [$stagcan find withtag outo] {
		$stagcan itemconfig $obj -text ""
	}
	set n 1
	while {$n <= $stagecnt} {
		catch {$stagcan delete axes$n}
		incr n
	}
	set stagecnt 1
}

#--- Switch between selected and unselected state, for input channel buttons

proc SetStageIchan {n} {
	global stage_inchans stage_inchans_set evv
	
	set thisbkgd [.octagon.2.1.2.b$n cget -background]
	if {[string match $thisbkgd $evv(EMPH)]} {
		if {[info exists stage_inchans]} {
			if {[llength $stage_inchans] > 1} {
				.octagon.2.1.2.b$n config -background [option get . background {}]
				set k [lsearch $stage_inchans $n]
				if {$k >= 0} {
					set stage_inchans [lreplace $stage_inchans $k $k]
				}
			}
		}
	} else {
		.octagon.2.1.2.b$n config -background $evv(EMPH)
		lappend stage_inchans $n
	}
	set stage_inchans_set 0
	if {[llength $stage_inchans] == 0} {
		unset stage_inchans
	}
}

#--- Put input channels in unselected-state

proc DeselectStageIchans {chans} {
	global stage_inchans
	set stage_inchans {}
	set n 1
	while {$n <= $chans} {
		.octagon.2.1.2.b$n config -background [option get . background {}]
		incr n
	}
}

#---- Get coords of centre of lspkr

proc LspkrToOctagonCoords {n} {
	global stage_output_chans eightchan_stereo_centred
	switch -- $stage_output_chans {
		8 {
			if {$eightchan_stereo_centred} {
				switch -- $n {
					1 {set coords [list 150 40]}
					2 {set coords [list 250 40]}
					3 {set coords [list 320 110]}
					4 {set coords [list 320 210]}
					5 {set coords [list 250 280]}
					6 {set coords [list 150 280]}
					7 {set coords [list 80  210]}
					8 {set coords [list 80  110]}
				}
			} else {
				switch -- $n {
					1 {set coords [list 200 40]}
					2 {set coords [list 280 90]}
					3 {set coords [list 330 170]}
					4 {set coords [list 280 250]}
					5 {set coords [list 200 300]}
					6 {set coords [list 120 250]}
					7 {set coords [list 70  170]}
					8 {set coords [list 120 90]}
				}
			}
		}
		7 {
			switch -- $n {
				1 {set coords [list 200 60]}
				2 {set coords [list 120 110]}
				3 {set coords [list 280 110]}
				4 {set coords [list 80 210]}
				5 {set coords [list 320 210]}
				6 {set coords [list 80 310]}
				7 {set coords [list 320 310]}
			}
		}
		5 {
			switch -- $n {
				1 {set coords [list 200 60]}
				2 {set coords [list 120 110]}
				3 {set coords [list 280 110]}
				4 {set coords [list 80 210]}
				5 {set coords [list 320 210]}
			}
		}
	}
	return $coords
}

#---- Get an existing multichannel mixfile

proc GetStageMix {} {
	global wl stagemix pr_stagemix evv wl pa
	foreach fnam [$wl get 0 end] {
		if {$pa($fnam,$evv(FTYP)) == $evv(MIX_MULTI)} {
			lappend posibs $fnam
		}
	}
	if {![info exists posibs]} {
		Inf "No Existing Multi-Channel Mixfiles On The Workspace"
		return
	}
	if {[llength $posibs] == 1} {
		set stagemix [lindex $posibs 0]
		return
	}
	set f .stage_mix
	if [Dlg_Create $f "MULTI-CHAN MIXFILES ON WORKSPACE" "set pr_stagemix 0" -width 80 -borderwidth $evv(SBDR)] {
		frame $f.0
		frame $f.2
		button $f.0.u -text "Use File" -command "set pr_stagemix 1" -highlightbackground [option get . background {}]
		button $f.0.q -text "Quit" -command "set pr_stagemix 0" -highlightbackground [option get . background {}]
		pack $f.0.u -side left
		pack $f.0.q -side right
		pack $f.0 -side top -fill x -expand true
		label $f.1 -text "SELECT FILE WITH MOUSE" -fg $evv(SPECIAL)
		pack $f.1 -side top -pady 4
		Scrolled_Listbox $f.2.ll -width 64 -height 24 -selectmode single
		pack $f.2.ll -side top -fill both -expand true
		pack $f.2 -side top
		wm resizable $f 1 1
		bind $f <Return> {set pr_stagemix 1}
		bind $f <Escape> {set pr_stagemix 0}
	}
	$f.2.ll.list delete 0 end
	foreach fnam $posibs {
		$f.2.ll.list insert end $fnam
	}
	raise $f
	update idletasks
	StandardPosition2 $f
	set pr_stagemix 0
	set finished 0
	My_Grab 0 $f pr_stagemix
	while {!$finished} {
		tkwait variable pr_stagemix
		if {$pr_stagemix} {
			set i [$f.2.ll.list curselection]
			if {([llength $i] != 1) || ($i == -1)} {
				Inf "Select A Filename"
				continue
			}
			set stagemix [$f.2.ll.list get $i]
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc HelpOctStage {} {
	set msg "DISTRIBUTING INPUT SOUNDFILE ON MULTICHANNEL STAGE\n"
	append msg "\n"
	append msg "1) First select a multichannel output format.\n"
	append msg "      5 = \"5.1\"\n"
	append msg "      7 = \"7.1\"\n"
	append msg "      8 = ring of 8 lspkrs, with 1 lspkr at front centre-stage.\n"
	append msg "      8s = ring of 8 lpskrs with 2 at front (front-left and front-right).\n"
	append msg "\n"
	append msg "2)  If the input file has more than 1 channel,\n"
	append msg "           select One or More input channels, using the buttons on the left.\n"
	append msg "3)  Assign input(s) to output channels by clicking on the Multichannel diagram.\n"
	append msg "\n"
	append msg "NOTE THAT\n"
	append msg "\n"
	append msg "a)  If you choose more than 1 input-channel, these will be assigned, 1 at a time,\n"
	append msg "           to the output channels you select.\n"
	append msg "\n"
	append msg "b)  If you choose a single channel, it can be assigned to any number of outputs.\n"
	append msg "         (To assign e.g. a stereo signal to more than 2 outputs, assign each channel in turn.)\n"
	append msg "\n"
	append msg "c)  Once all output channels (for a particular input) are set, Click on \"Finished Assigning\".\n"
	append msg "\n"
	append msg "d)  If you have assigned one channel to several outputs, new buttons appears at the right\n"
	append msg "       where you can set relative levels to the output channels.\n"
	append msg "       The default is level 1.0 on all channels,\n"
	append msg "       Click the \"Done\" button on the RH panel when levels are set.\n"
	append msg "\n"
	append msg "e)  The \"OK\" and \"Redo\" buttons will now appear at the left.\n"
	append msg "       Click on \"OK\" to accept this data\n"
	append msg "       Click on \"Redo\" to reject the data for this (choice of) input channel(s).\n"
	append msg "\n"
	append msg "The output from this process is a multi-channel mixfile.\n"
	Inf $msg
}

proc ConfigureOctInterface {chans fnam} {
	global pr_stage stage_inchans_set stage_inchans stage_chans stagcan stage_output_chans evv
	switch -- $chans {
		0 {
			set n 1
			while {$n <= $stage_output_chans} {
				.octagon.2.1.2.b$n config -state disabled -background grey
				incr n
			}
			.octagon.2.1.3 config -text "" -command {} -bd 0
		}
		1 {	
			.octagon.2.1.2.b1 config -state normal -background $evv(EMPH)
			set n 2
			while {$n <= $stage_output_chans} {
				.octagon.2.1.2.b$n config -state disabled -background grey
				incr n
			}
			set stage_inchans 1
			.octagon.2.1.1.ic config -text ""
			.octagon.2.1.3 config -text "Finished Assigning Outputs to This Input Channel" -command "set pr_stage 3" -bd 2
			set stage_inchans_set 1
			.octagon.2.1.2.b1 config -command {}
		}
		default {
			set n 1
			if {$chans <= $stage_output_chans} { 
				while {$n <= $chans} {
					.octagon.2.1.2.b$n config -state normal -background [option get . background {}] -highlightbackground $evv(EMPH)
					incr n
				}
				while {$n <= $stage_output_chans} {
					.octagon.2.1.2.b$n config -state disabled -background grey
					incr n
				}
				while {$n < 8} {
					.octagon.2.1.2.b$n config -state normal -background [option get . background {}] -command {} -bd 0 -text "" -highlightbackground [option get . background {}]
					incr n
				}
			} else {
				while {$n <= $chans} {
					.octagon.2.1.2.b$n config -state normal -background [option get . background {}] -command "SetStageIchan $n" -bd 2 -text $n -highlightbackground $evv(EMPH)
					incr n
				}
			}
			.octagon.2.1.2.b1 config -command "SetStageIchan 1"
			.octagon.2.1.1.ic config -text "Select Input Channel(s) to Assign to Stage"
		}
	}
	set obj [$stagcan find withtag filename]
	$stagcan itemconfig $obj -text "FILE:  [file rootname [file tail $fnam]]  --- $stage_chans CHANNELS"
}

proc ResetForNextFileEntry {} {
	global stage_chans stage_fnam chlist stage_outfile_cnt stage_inchans stage_outchans stage_outstage total_stage_outchans
	global is_stage1 stage_done_chans stage_inchans_set stagecnt chchans stage_outlevels stagcan

	DeselectStageIchans $stage_chans
	set stage_fnam [lindex $chlist $stage_outfile_cnt]
	set stage_chans [lindex $chchans $stage_outfile_cnt]
	set n 1
	while {$n <= $stagecnt} {
		catch {$stagcan delete axes$n}
		incr n
	}
	catch {unset stage_inchans}
	catch {unset stage_outchans}
	catch {unset stage_outlevels}
	set stage_outstage {}
	set total_stage_outchans {}
	set is_stage1 {}
	set stage_done_chans {}
	set stage_inchans_set 0
	set stagecnt 1
	ResetOctagon
	ConfigureOctInterface $stage_chans $stage_fnam
}

proc SaveStageData {standard} {
	global stage_fnam stage_chans total_stage_outchans stage_outlines stage_standard_to_use
	if {$standard} {
		set line $stage_standard_to_use
	} else {
		set line $stage_fnam
		lappend line 0.0 $stage_chans
		foreach {in out lev} $total_stage_outchans {
			lappend line $in:$out $lev
		}
		set line [split $line]
	}
	lappend stage_outlines $line
}

proc HideStageOutputLevels {} {
	global stage_outbal stage_output_chans
	.octagon.2.5.0.0  config -text ""
	.octagon.2.5.0.1  config -text "" -bd 0 -command {}
	set n 1
	while {$n <= $stage_output_chans} {
		.octagon.2.5.$n.e  config -bd 0 -width 0
		.octagon.2.5.$n.ll config -text ""
		set stage_outbal($n) ""
		incr n
	}
}

proc DisplayStageOutputLevels {} {
	global stage_outchans stage_outbal pr_stage
	.octagon.2.5.0.0 config -text "RELATIVE LEVELS (USE Up/Down KEYS)"
	.octagon.2.5.0.1 config -text "Done" -bd 2 -command "set pr_stage 6" -width 4
	foreach n $stage_outchans {
		.octagon.2.5.$n.e  config -bd 2 -width 4
		.octagon.2.5.$n.ll config -text "Channel $n"
		set stage_outbal($n) 1.0
	}
}

proc IncrStageBalance {which down} {
	global stage_outbal
	if {[string length $stage_outbal($which)] > 0} {
		if {$down} {
			if {$stage_outbal($which) > 0.0} {
				set stage_outbal($which) [DecPlaces [expr $stage_outbal($which) - 0.05] 2]
			}
		} else {
			if {$stage_outbal($which) < 1.0} {
				set stage_outbal($which) [DecPlaces [expr $stage_outbal($which) + 0.05] 2]
			}
		}
	}
}

#---- Save this format for multi-Staging as a standard 

proc SaveStandardStage {} {
	global stagemix stage_inchans stage_outlines stage_output_chans wstk stage_standard_saved chchans evv format_nam
	if {![info exists stage_outlines]} {
		Inf "Staging Data Incomplete"
		return 0
	}
	if {[llength $chchans] > 1} {
		Inf "Standard Formats Can Only Be Saved For Single Input Files."
		return
	}
	catch {unset format_nam}
	set ident "stst_"
	append ident $stage_output_chans "_" [lindex $chchans 0] "_"
	set use_outfile_name 1
	if {[info exists stagemix] && ([string length $stagemix] > 0)} { 
		set msg "Save format using the name of the output file ($stagemix) ??"
		set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
		if {$choice == "no"} {
			set use_outfile_name 0
		}
	} else {
		set use_outfile_name 0
	}
	if {$use_outfile_name} {
		set format_nam [string tolower [file rootname [file tail $stagemix]]]
	} else {
		GetFormatName $ident
	}
	if {![info exists format_nam]} {
		return 0
	}
	set standardname [file join $evv(URES_DIR) $ident]
	append standardname $format_nam $evv(CDP_EXT)
	if {[file exists $standardname]} {
		set msg "A Standard Format With This Name Already Exists: Overwrite It ??"
		set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
		if {$choice == "no"} {
			Inf "Waiting For A New Name"
			return 0
		} else {
			if [catch {file delete $standardname} zit] {
				set msg "Cannot Delete Existing Standard Format: Try A New Name ??"
				set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
				if {$choice == "yes"} {
					return 0
				}
				return 1
			}
		}
	}
	if [catch {open $standardname "w"} zit] {
		Inf "Cannot Open File To Write Standard Format"
		return 1
	}
	set line 2
	puts $zit $line
	foreach line $stage_outlines {
		puts $zit $line
	}
	close $zit
	set stage_standard_saved $stagemix
	return 1
}

#---- Get an existing standard format Staging

proc GetStandardStage {} {
	global stage_this_standard stage_output_chans standard_stages pr_standard_stage stage_fnam wstk evv
	global stagemix stage_last stage_chans stage_standard_to_use pr_stage

	set standard_stages {}
	catch {unset stage_this_standard}
	set ident "stst_"
	append ident $stage_output_chans "_" $stage_chans "_"
	set identlen [string length $ident]
	foreach fnam [glob -nocomplain [file join $evv(URES_DIR) $ident*]] {
		lappend standard_stages $fnam
	}
	set slen [llength $standard_stages]
	if {$slen == 0} {
		Inf "No Standard Formats For Staging $stage_chans Channels To $stage_output_chans"
		return 0
	}
	set f .standard_stage
	if [Dlg_Create $f "STANDARD FORMATS FOR STAGING $stage_chans CHANNELS TO $stage_output_chans" "set pr_standard_stage 0" -width 80 -borderwidth $evv(SBDR)] {
		frame $f.0
		frame $f.2
		button $f.0.u -text "Get Format" -command "set pr_standard_stage 1" -highlightbackground [option get . background {}]
		button $f.0.q -text "Abandon" -command "set pr_standard_stage 0" -highlightbackground [option get . background {}]
		pack $f.0.u -side left
		pack $f.0.q -side right
		pack $f.0 -side top -fill x -expand true
		label $f.1 -text "Select Format With Mouse" -fg $evv(SPECIAL)
		pack $f.1 -side top -pady 4
		Scrolled_Listbox $f.2.ll -width 64 -height 8 -selectmode single
		pack $f.2.ll -side top -fill both -expand true
		pack $f.2 -side top
		wm resizable $f 1 1
		bind $f <Return> {set pr_standard_stage 1}
		bind $f <Escape> {set pr_standard_stage 0}
	}
	wm title $f "STANDARD FORMATS FOR STAGING $stage_chans CHANNELS TO $stage_output_chans"
	$f.2.ll.list delete 0 end
	foreach fnam $standard_stages {
		$f.2.ll.list insert end [string range [file rootname [file tail $fnam]] $identlen end]
	}
	raise $f
	update idletasks
	StandardPosition2 $f
	set pr_standard_stage 0
	set finished 0
	My_Grab 0 $f pr_standard_stage
	while {!$finished} {
		tkwait variable pr_standard_stage
		if {$pr_standard_stage} {
			if {[$f.2.ll.list index end] == 1} {
				set i 0
			} else {
				set i [$f.2.ll.list curselection]
			}
			if {![info exists i] || ($i < 0)} {
				Inf "No Item Selected"
				continue
			}
			set stage_this_standard [lindex $standard_stages $i]
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
	if {![info exists stage_this_standard]} {
		return
	} elseif [catch {open $stage_this_standard "r"} zit] {
		set msg "Failed To Open Standard-Format Datafile"
		return
	} else {
		set linecnt 0
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] < 0} {
				continue
			}
			if {$linecnt == 1} {
				set nuline [split $line]
				set nuline [lreplace $line 0 0 $stage_fnam]
				break
			}
			incr linecnt
		}
		close $zit
		if {![info exists nuline]} {
			Inf "Corrupted Data In Standard Format Datafile"
			return
		}
		set stage_standard_to_use [lreplace $nuline 0 0 $stage_fnam]
		Inf "Copied Standard Format [string range [file rootname [file tail $stage_this_standard]] $identlen end] For File $stage_fnam"
		set pr_stage 8
	}
}

#--- Delete a standard-format file for multichannel-staging

proc RemoveStandardStage {} {
	global pr_standard_delstage stage_output_chans wstk evv

	set standard_delstages {}
	set ident "stst_"
	append ident $stage_output_chans "_"
	set identlen [string length $ident]
	foreach fnam [glob -nocomplain [file join $evv(URES_DIR) $ident*]] {
		lappend standard_delstages $fnam
	}
	set slen [llength $standard_delstages]
	if {$slen == 0} {
		Inf "No Standard Formats For Staging To $stage_output_chans"
		return
	}
	set f .standard_delstage
	if [Dlg_Create $f "REMOVE STANDARD FORMAT FOR STAGING TO $stage_output_chans" "set pr_standard_delstage 0" -width 80 -borderwidth $evv(SBDR)] {
		frame $f.0
		frame $f.2
		button $f.0.u -text "Delete Format" -command "set pr_standard_delstage 1" -highlightbackground [option get . background {}]
		button $f.0.q -text "Quit" -command "set pr_standard_delstage 0" -highlightbackground [option get . background {}]
		pack $f.0.u -side left
		pack $f.0.q -side right
		pack $f.0 -side top -fill x -expand true
		label $f.1 -text "Select Format With Mouse" -fg $evv(SPECIAL)
		pack $f.1 -side top -pady 4
		Scrolled_Listbox $f.2.ll -width 64 -height 8 -selectmode single
		pack $f.2.ll -side top -fill both -expand true
		pack $f.2 -side top
		wm resizable $f 1 1
		bind $f <Return> {set pr_standard_delstage 1}
		bind $f <Escape> {set pr_standard_delstage 0}
	}
	$f.2.ll.list delete 0 end
	foreach fnam $standard_delstages {
		$f.2.ll.list insert end [string range [file rootname [file tail $fnam]] $identlen end]
	}
	raise $f
	update idletasks
	StandardPosition2 $f
	set pr_standard_delstage 0
	set finished 0
	My_Grab 0 $f pr_standard_delstage
	while {!$finished} {
		tkwait variable pr_standard_delstage
		if {$pr_standard_delstage} {
			set i [$f.2.ll.list curselection]
			if {![info exists i] || ($i < 0)} {
				Inf "No Item Selected"
				continue
			}
			set nam [$f.2.ll.list get $i]
			set msg "Are You Sure You Want To Delete Standard Format '$nam' ??"
			set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
			if {$choice == "no"} {
				continue
			}
			set fnam [lindex $standard_delstages $i]
			if [catch {file delete $fnam} zit] {
				Inf "Failed To Delete Standard Format '$nam' In File '$fnam'"
				continue
			}
			$f.2.ll.list delete $i
			set standard_delstages [lreplace $standard_delstages $i $i]
			if {[llength $standard_delstages] <= 0} {
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

#---- Draw appropriate output stage

proc EstablishOutputStageDisplay {n} {
	global stagcan stage_output_chans stage_chans stage_fnam eightchan_stereo_centred evv
	set eightchan_stereo_centred 0
	if {[string match $n "8s"]} {
		set n 8
		set eightchan_stereo_centred 1
	}
	set stage_output_chans $n
	set obj [$stagcan find withtag setup]
	$stagcan itemconfig $obj -text ""
	$stagcan.ff.5 config -text "" -bd 0 -command {}
	$stagcan.ff.7 config -text "" -bd 0 -command {}
	$stagcan.ff.8 config -text "" -bd 0 -command {}
	$stagcan.ff.81 config -text "" -bd 0 -command {}

	switch --  $stage_output_chans {
		8 {
			if {$eightchan_stereo_centred} {
				$stagcan create line 150 40 250 40 320 110 320 210 250 280 150 280 80 210 80 110 150 40 -width 1 -fill $evv(POINT)
				$stagcan create rect 147 37  153 43  -fill [option get . background {}] -tag {lspkr k1} -outline $evv(POINT)
				$stagcan create text 140 30 -text "1" -fill $evv(POINT) 
				$stagcan create text 130 10 -text "" -fill red -tag {outo outo1}
				$stagcan create rect 247 37  253 43  -fill [option get . background {}] -tag {lspkr k2} -outline $evv(POINT)
				$stagcan create text 260 30 -text "2" -fill $evv(POINT)
				$stagcan create text 270 10 -text "" -fill red -tag {outo outo2}
				$stagcan create rect 317 107 323 113 -fill [option get . background {}] -tag {lspkr k3} -outline $evv(POINT)
				$stagcan create text 330 110 -text "3" -fill $evv(POINT)
				$stagcan create text 340 120 -text "" -fill red -tag {outo outo3} -anchor w
				$stagcan create rect 317 207 323 213 -fill [option get . background {}] -tag {lspkr k4} -outline $evv(POINT)
				$stagcan create text 330 210 -text "4" -fill $evv(POINT)
				$stagcan create text 340 220 -text "" -fill red -tag {outo outo4} -anchor w
				$stagcan create rect 247 277 253 283 -fill [option get . background {}] -tag {lspkr k5} -outline $evv(POINT)
				$stagcan create text 260 290 -text "5" -fill $evv(POINT)
				$stagcan create text 270 310 -text "" -fill red -tag {outo outo5}
				$stagcan create rect 147 277 153 283 -fill [option get . background {}] -tag {lspkr k6} -outline $evv(POINT)
				$stagcan create text 140 290 -text "6" -fill $evv(POINT)
				$stagcan create text 130 310 -text "" -fill red -tag {outo outo6}
				$stagcan create rect 77  207 83  213 -fill [option get . background {}] -tag {lspkr k7} -outline $evv(POINT)
				$stagcan create text 70 210 -text "7" -fill $evv(POINT)
				$stagcan create text 60 220 -text "" -fill red -tag {outo outo7} -anchor e
				$stagcan create rect 77  107 83  113 -fill [option get . background {}] -tag {lspkr k8} -outline $evv(POINT)
				$stagcan create text 70 110 -text "8" -fill $evv(POINT)
				$stagcan create text 60 120 -text "" -fill red -tag {outo outo8} -anchor e
				$stagcan create text 200 370 -text "" -fill $evv(POINT) -tag filename
			} else {
				$stagcan create line 200 40 280 90 330 170 280 250 200 300 120 250 70 170 120 90 200 40 -width 1 -fill $evv(POINT)
				$stagcan create rect 197 37 203 43  -fill [option get . background {}] -tag {lspkr k1} -outline $evv(POINT)
				$stagcan create text 200 27 -text "1" -fill $evv(POINT) 
				$stagcan create text 200 12 -text "" -fill red -tag {outo outo1}
				$stagcan create rect 277 87  283 93  -fill [option get . background {}] -tag {lspkr k2} -outline $evv(POINT)
				$stagcan create text 290 85 -text "2" -fill $evv(POINT)
				$stagcan create text 300 80 -text "" -fill red -tag {outo outo2} -anchor w
				$stagcan create rect 327 167 333 173 -fill [option get . background {}] -tag {lspkr k3} -outline $evv(POINT)
				$stagcan create text 340 170 -text "3" -fill $evv(POINT)
				$stagcan create text 350 170 -text "" -fill red -tag {outo outo3} -anchor w
				$stagcan create rect 277 247 283 253 -fill [option get . background {}] -tag {lspkr k4} -outline $evv(POINT)
				$stagcan create text 290 255 -text "4" -fill $evv(POINT)
				$stagcan create text 300 260 -text "" -fill red -tag {outo outo4} -anchor w
				$stagcan create rect 197 297 203 303 -fill [option get . background {}] -tag {lspkr k5} -outline $evv(POINT)
				$stagcan create text 200 313 -text "5" -fill $evv(POINT)
				$stagcan create text 200 328 -text "" -fill red -tag {outo outo5}
				$stagcan create rect 117 247 123 253 -fill [option get . background {}] -tag {lspkr k6} -outline $evv(POINT)
				$stagcan create text 110 255 -text "6" -fill $evv(POINT)
				$stagcan create text 100 260 -text "" -fill red -tag {outo outo6} -anchor e
				$stagcan create rect 67 167 73 173 -fill [option get . background {}] -tag {lspkr k7} -outline $evv(POINT)
				$stagcan create text 60 170 -text "7" -fill $evv(POINT)
				$stagcan create text 50 170 -text "" -fill red -tag {outo outo7} -anchor e
				$stagcan create rect 117 87 123 93 -fill [option get . background {}] -tag {lspkr k8} -outline $evv(POINT)
				$stagcan create text 110 85 -text "8" -fill $evv(POINT)
				$stagcan create text 100 80 -text "" -fill red -tag {outo outo8} -anchor e
				$stagcan create text 200 370 -text "" -fill $evv(POINT) -tag filename
			}
		}
		7 {
			$stagcan create line 80 310 80 210 120 110 200 60 280 110 320 210 320 310 -width 1 -fill $evv(POINT)
			$stagcan create rect 77 307  83 313  -fill [option get . background {}] -tag {lspkr k6} -outline $evv(POINT)
			$stagcan create text 70 310 -text "6" -fill $evv(POINT) 
			$stagcan create text 60 310 -text "" -fill red -tag {outo outo6} -anchor e
			$stagcan create rect 77 207  83 213  -fill [option get . background {}] -tag {lspkr k4} -outline $evv(POINT)
			$stagcan create text 70 205 -text "4" -fill $evv(POINT)
			$stagcan create text 60 205 -text "" -fill red -tag {outo outo4} -anchor e
			$stagcan create rect 117 107 123 113 -fill [option get . background {}] -tag {lspkr k2} -outline $evv(POINT)
			$stagcan create text 110 100 -text "2" -fill $evv(POINT)
			$stagcan create text 100 85 -text "" -fill red -tag {outo outo2} -anchor e
			$stagcan create rect 197  57  203  63 -fill [option get . background {}] -tag {lspkr k1} -outline $evv(POINT)
			$stagcan create text 200 50 -text "1" -fill $evv(POINT) -anchor c
			$stagcan create text 200 35 -text "" -fill red -tag {outo outo1}
			$stagcan create rect 277 107 283 113 -fill [option get . background {}] -tag {lspkr k3} -outline $evv(POINT)
			$stagcan create text 290 100 -text "3" -fill $evv(POINT)
			$stagcan create text 300 85 -text "" -fill red -tag {outo outo3} -anchor w
			$stagcan create rect 317 207 323 213 -fill [option get . background {}] -tag {lspkr k5} -outline $evv(POINT)
			$stagcan create text 330 205 -text "5" -fill $evv(POINT)
			$stagcan create text 340 205 -text "" -fill red -tag {outo outo5} -anchor w
			$stagcan create rect 317 307 323 313 -fill [option get . background {}] -tag {lspkr k7} -outline $evv(POINT)
			$stagcan create text 330 310 -text "7" -fill $evv(POINT)
			$stagcan create text 340 310 -text "" -fill red -tag {outo outo7} -anchor w
			$stagcan create text 200 370 -text "" -tag filename -fill $evv(POINT) 
		}
		5 {
			$stagcan create line 80 210 120 110 200 60 280 110 320 210 -width 1 -fill $evv(POINT)
			$stagcan create rect 77 207  83 213  -fill [option get . background {}] -tag {lspkr k4} -outline $evv(POINT)
			$stagcan create text 70 205 -text "4" -fill $evv(POINT)
			$stagcan create text 60 205 -text "" -fill red -tag {outo outo4} -anchor e
			$stagcan create rect 117 107 123 113 -fill [option get . background {}] -tag {lspkr k2} -outline $evv(POINT)
			$stagcan create text 110 100 -text "2" -fill $evv(POINT)
			$stagcan create text 100 85 -text "" -fill red -tag {outo outo2} -anchor e
			$stagcan create rect 197  57  203  63 -fill [option get . background {}] -tag {lspkr k1} -outline $evv(POINT)
			$stagcan create text 200 50 -text "1" -fill $evv(POINT)
			$stagcan create text 200 35 -text "" -fill red -tag {outo outo1}
			$stagcan create rect 277 107 283 113 -fill [option get . background {}] -tag {lspkr k3} -outline $evv(POINT)
			$stagcan create text 290 100 -text "3" -fill $evv(POINT)
			$stagcan create text 300 85 -text "" -fill red -tag {outo outo3} -anchor w
			$stagcan create rect 317 207 323 213 -fill [option get . background {}] -tag {lspkr k5} -outline $evv(POINT)
			$stagcan create text 330 205 -text "5" -fill $evv(POINT)
			$stagcan create text 340 205 -text "" -fill red -tag {outo outo5} -anchor w
			$stagcan create text 200 370 -text "" -tag filename -fill $evv(POINT) 
		}
	}
	set n 1
	while {$n <= $stage_output_chans} {
		.octagon.2.1.2.b$n config -text $n -command "SetStageIchan $n" -bd 2

		.octagon.2.5.$n.e config -bd 0 -width 0
		.octagon.2.5.$n.ll config -text ""
		set stage_outbal($n) ""
		bind .octagon.2.5.$n.e <Up>   "IncrStageBalance $n 0"
		bind .octagon.2.5.$n.e <Down> "IncrStageBalance $n 1"
		incr n
	}
	set mfb .octagon.0.mb.menu
	$mfb add command -label "Get Standard Staging Format" -command "GetStandardStage" -foreground black
	$mfb add separator 
	$mfb add command -label "Retain as Standard Format" -command "SaveStandardStage" -foreground black
	$mfb add separator
	$mfb add command -label "Rename Standard Format" -command "RenameStandardStage 0" -foreground black
	$mfb add separator 
	$mfb add command -label "Remove Standard Format" -command "RemoveStandardStage" -foreground black
	bind .octagon.0.mb <ButtonRelease-1> {}
	ConfigureOctInterface $stage_chans $stage_fnam
	ResetForNextFileEntry
	bind $stagcan <ButtonRelease-1> "MarkLspkr $stagcan %x %y"
}

proc CheckStageDisplayed {} {
	global stage_output_chans
	if {$stage_output_chans == 0} {
		Inf "Select Output Stage First"
	}
}

#########################
# 8 CHANNEL CONTRACTION #
#########################

#--- Arranging channels of 8-chan on a stereo stage

proc SetDisStage {} {
	global total_stuge_outpositions stugcan stuge_inchan pr_stuge stugecnt stuge_all_done stuge_inchans_assigned stuge_standard_saved
	global stugemix pa chlist wstk stuge_fnam stuge_outlines pr2 evv
	global stuge_outbal stuge_outlevels readonlybg readonlyfg stuge_opposite stuge_outpos stuge_total_inchans disstage_last stage_last

	catch {unset stage_last}
	if {![info exists chlist]} {
		Inf "No File Selected"
		return
	}
	if {[llength $chlist] != 1} {
		Inf "Select A Single File"
		return
	}
	catch {unset stuge_outlevels}
	catch {unset stuge_all_done}
	catch {unset stuge_outlines}
	catch {unset stuge_inchans_assigned}
	catch {unset stuge_inchan}
	catch {unset stuge_outpos}
	catch {stuge_standard_saved}
	set stuge_fnam [lindex $chlist 0]
	if {$pa($stuge_fnam,$evv(FTYP)) != $evv(SNDFILE)} {
		Inf "Selected File Is Not A Soundfile"
		return
	}
	set stuge_total_inchans $pa($stuge_fnam,$evv(CHANS))
	set total_stuge_outpositions {}
	set stugecnt 0
	set f .disoctagon
	if [Dlg_Create $f "REDUCE STAGE TO STEREO" "set pr_stuge 0" -width 180 -borderwidth $evv(SBDR)] {
		frame $f.0
		frame $f.1 -bg black -width 1
		frame $f.1a
		frame $f.1b -bg black -width 1
		frame $f.2
		frame $f.2.3
		frame $f.2.4 -bg black -width 1
		frame $f.1a.1
		frame $f.1a.2
		frame $f.2.5
	
		button $f.0.help -text "Help" -command "HelpDisOctStage $stuge_total_inchans" -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.0.do -text "Output Staging Data"   -command "set pr_stuge 1" -highlightbackground [option get . background {}]
		button $f.0.rs -text "Start Again" -command "set pr_stuge 2" -highlightbackground [option get . background {}]
		label $f.0.ll -text "Input is $stuge_total_inchans channel"
		entry $f.0.e -textvariable stugemix -width 16
		label $f.0.le -text "Output Mixfile Name"
		button $f.0.b -text  "Get Mixfile To Overwrite" -command GetUnStageMix -width 24 -highlightbackground [option get . background {}]
		menubutton $f.0.mb -text "STANDARD FORMATS" -menu $f.0.mb.menu -relief raised -width 24
		set mfb [menu $f.0.mb.menu -tearoff 0]
		$mfb add command -label "Get Standard Mix Format" -command "GoGetStandardUnstage" -foreground black
		$mfb add separator 
		$mfb add command -label "Retain as Standard Format" -command "SaveStandardUnstage" -foreground black
		$mfb add separator 
		$mfb add command -label "Rename Standard Format" -command "RenameStandardStage 1" -foreground black
		$mfb add separator
		$mfb add command -label "Remove Standard Format" -command "RemoveStandardUnstage" -foreground black
		button $f.0.q  -text "Quit"  -command "set pr_stuge 0" -highlightbackground [option get . background {}]
		pack $f.0.help -side left
		pack $f.0.do $f.0.rs $f.0.ll $f.0.e $f.0.le $f.0.b -side left -padx 2
		pack $f.0.mb -side left -padx 120
		pack $f.0.q -side right
		pack $f.0 -side top -fill x -expand true
		pack $f.1 -side top -fill x -expand true -pady 4

		label $f.1a.1.ic -text "Select Stereo Output Position to Assign to an Input Channel"
		pack $f.1a.1.ic -side top
		pack $f.1a.1 -side top -fill x -expand true
		set n 1
		set panval -1.00
		set panincr 0.05
		while {$n <= 41} {
			button $f.1a.2.b$n -width 3 -command "SetStageOPos $n" -text $panval -font microfnt -highlightbackground [option get . background {}]
			pack $f.1a.2.b$n -side left
			incr n
			set panval [DecPlaces [expr $panval + $panincr] 2]
		}
		$f.1a.2.b1 config -text "L" -font userfnt -bd 10
		$f.1a.2.b21 config -text "C" -font userfnt -bd 10
		$f.1a.2.b41 config -text "R" -font userfnt -bd 10
		pack $f.1a.2 -side top
		button $f.1a.3 -text "Finished Assigning" -command "set pr_stuge 3" -highlightbackground [option get . background {}]
		frame $f.1a.4
		button $f.1a.4.ok -text "OK" -command   "set pr_stuge 4" -width 4 -highlightbackground [option get . background {}]
		button $f.1a.4.no -text "Redo" -command "set pr_stuge 5" -width 4 -highlightbackground [option get . background {}]
		pack $f.1a.4.ok $f.1a.4.no -side left
		pack $f.1a.3 $f.1a.4 -side top -pady 2
		pack $f.1a -side top
		pack $f.1b -side top -fill x -expand true
		set stugcan [canvas $f.2.3.c -height 400 -width 400 -borderwidth 0 -highlightthickness 1 -highlightbackground $evv(SPECIAL)]
		
		switch -- $stuge_total_inchans {
			8 {
				$stugcan create line 150 40 250 40 320 110 320 210 250 280 150 280 80 210 80 110 150 40 -width 1 -fill $evv(POINT)
				$stugcan create rect 147 37  153 43  -fill [option get . background {}] -tag {lspkr k1} -outline $evv(POINT)
				$stugcan create text 140 30 -text "1" -fill $evv(POINT) 
				$stugcan create rect 247 37  253 43  -fill [option get . background {}] -tag {lspkr k2} -outline $evv(POINT)
				$stugcan create text 260 30 -text "2" -fill $evv(POINT)
				$stugcan create rect 317 107 323 113 -fill [option get . background {}] -tag {lspkr k3} -outline $evv(POINT)
				$stugcan create text 330 110 -text "3" -fill $evv(POINT)
				$stugcan create rect 317 207 323 213 -fill [option get . background {}] -tag {lspkr k4} -outline $evv(POINT)
				$stugcan create text 340 210 -text "4" -fill $evv(POINT)
				$stugcan create rect 247 277 253 283 -fill [option get . background {}] -tag {lspkr k5} -outline $evv(POINT)
				$stugcan create text 260 290 -text "5" -fill $evv(POINT)
				$stugcan create rect 147 277 153 283 -fill [option get . background {}] -tag {lspkr k6} -outline $evv(POINT)
				$stugcan create text 140 290 -text "6" -fill $evv(POINT)
				$stugcan create rect 77  207 83  213 -fill [option get . background {}] -tag {lspkr k7} -outline $evv(POINT)
				$stugcan create text 70 210 -text "7" -fill $evv(POINT)
				$stugcan create rect 77  107 83  113 -fill [option get . background {}] -tag {lspkr k8} -outline $evv(POINT)
				$stugcan create text 70 110 -text "8" -fill $evv(POINT)
				$stugcan create text 200 320 -text "Click to Select Output Channel to Reposition in Stereo" -fill $evv(POINT) 
				$stugcan create text 200 350 -text "" -tag filename -fill $evv(POINT) 
			}
			7 {
				$stugcan create line 80 310 80 210 120 110 200 60 280 110 320 210 320 310 -width 1 -fill $evv(POINT)
				$stugcan create rect 77 307  83 313  -fill [option get . background {}] -tag {lspkr k6} -outline $evv(POINT)
				$stugcan create text 70 310 -text "6" -fill $evv(POINT) 
				$stugcan create rect 77 207  83 213  -fill [option get . background {}] -tag {lspkr k4} -outline $evv(POINT)
				$stugcan create text 70 205 -text "4" -fill $evv(POINT)
				$stugcan create rect 117 107 123 113 -fill [option get . background {}] -tag {lspkr k2} -outline $evv(POINT)
				$stugcan create text 110 100 -text "2" -fill $evv(POINT)
				$stugcan create rect 197  57  203  63 -fill [option get . background {}] -tag {lspkr k1} -outline $evv(POINT)
				$stugcan create text 200 50 -text "1" -fill $evv(POINT)
				$stugcan create rect 277 107 283 113 -fill [option get . background {}] -tag {lspkr k3} -outline $evv(POINT)
				$stugcan create text 290 100 -text "3" -fill $evv(POINT)
				$stugcan create rect 317 207 323 213 -fill [option get . background {}] -tag {lspkr k5} -outline $evv(POINT)
				$stugcan create text 330 205 -text "5" -fill $evv(POINT)
				$stugcan create rect 317 307 323 313 -fill [option get . background {}] -tag {lspkr k7} -outline $evv(POINT)
				$stugcan create text 330 310 -text "7" -fill $evv(POINT)
				$stugcan create text 200 340 -text "Click to Select Output Channel to Reposition in Stereo" -fill $evv(POINT) 
				$stugcan create text 200 370 -text "" -tag filename -fill $evv(POINT) 
			}
			5 {
				$stugcan create line 80 210 120 110 200 60 280 110 320 210 -width 1 -fill $evv(POINT)
				$stugcan create rect 77 207  83 213  -fill [option get . background {}] -tag {lspkr k4} -outline $evv(POINT)
				$stugcan create text 70 205 -text "4" -fill $evv(POINT)
				$stugcan create rect 117 107 123 113 -fill [option get . background {}] -tag {lspkr k2} -outline $evv(POINT)
				$stugcan create text 110 100 -text "2" -fill $evv(POINT)
				$stugcan create rect 197  57  203  63 -fill [option get . background {}] -tag {lspkr k1} -outline $evv(POINT)
				$stugcan create text 200 50 -text "1" -fill $evv(POINT)
				$stugcan create rect 277 107 283 113 -fill [option get . background {}] -tag {lspkr k3} -outline $evv(POINT)
				$stugcan create text 290 100 -text "3" -fill $evv(POINT)
				$stugcan create rect 317 207 323 213 -fill [option get . background {}] -tag {lspkr k5} -outline $evv(POINT)
				$stugcan create text 330 205 -text "5" -fill $evv(POINT)
				$stugcan create text 200 340 -text "Click to Select Output Channel to Reposition in Stereo" -fill $evv(POINT) 
				$stugcan create text 200 370 -text "" -tag filename -fill $evv(POINT) 
			}
		}
		pack $f.2.3.c -side left
		pack $f.2.3 -side left
		pack $f.2.4 -side left -fill y -expand true -padx 4
		frame $f.2.5.0
		label $f.2.5.0.0 -text "RELATIVE LEVEL OUTPUT CHANNELS" -width 32
		button $f.2.5.0.1 -text OK -command "set pr_stuge 6" -width 2 -highlightbackground [option get . background {}]
		pack $f.2.5.0.0 $f.2.5.0.1 -side left -padx 2 
		pack $f.2.5.0 -side top -pady 1 
		set n 1
		while {$n <= $stuge_total_inchans} {
			frame $f.2.5.$n
			entry $f.2.5.$n.e -textvariable stuge_outbal($n) -width 4 -state readonly -foreground $readonlyfg -readonlybackground [option get . background {}]
			label $f.2.5.$n.ll -text "Channel $n" -width 10
			pack $f.2.5.$n.e $f.2.5.$n.ll -side left
			pack $f.2.5.$n -side top -pady 1 
			bind $f.2.5.$n.e <Up> "IncrStugeBalance $n 0"
			bind $f.2.5.$n.e <Down> "IncrStugeBalance $n 1"
			incr n
		}
		pack $f.2.5 -side left
		pack $f.1 $f.2 -side top -pady 2
		wm resizable $f 1 1
		bind $stugcan <ButtonRelease-1> "MarkStugLspkr $stugcan %x %y"
		bind $f <Escape> {set pr_stuge 0}
	}
	wm title $f "REDUCE $stuge_total_inchans CHANNEL STAGE TO STEREO"
	.disoctagon.1a.4.ok config -text "" -command {} -bd 0
	.disoctagon.1a.4.no config -text "" -command {} -bd 0
	ConfigureDisOctInterface $stuge_fnam
	HideStugeOutputLevels
	set stugemix [file rootname [file tail $stuge_fnam]]
	append stugemix "_tostereo"
	set pr_stuge 0
	raise .disoctagon
	update idletasks
	QikeditPosition .disoctagon
	My_Grab 0 .disoctagon pr_stuge						;#	Create brkfile, and give it a name
	set finished 0
	while {!$finished} {
		tkwait variable pr_stuge
		switch -- $pr_stuge {
			0 {
				if {[info exists total_stuge_outpositions] && ([llength $total_stuge_outpositions] > 0)} {
					set msg "Exit Without Saving Any Re-Staging Data ??"
					set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
					if {$choice == "no"} {
						continue
					}
				}
				set finished 1
			}
			1 {
				if {[string length $stugemix] <= 0} {
					Inf "No Output Mixfile Name Entered"
					continue
				}
				set rname [file rootname [file tail $stugemix]]
				if {![ValidCDPRootname $rname]} {
					continue
				}
				if {![info exists stuge_outlines]} {
					Inf "Data (Verified) Incomplete"
					continue
				}
				set stugemixout [string tolower $stugemix]
				if {![info exists stuge_all_done]} {
					set msg "Re-Staging Not Complete"
					continue
				} else {
					set do_standard 0
					if {[info exists stuge_standard_saved]} {
						set k [lsearch $stuge_standard_saved $stugemixout]
						if {$k < 0} {
							set do_standard 1
						}
					} else  {
						set do_standard 1
					}
					if {$do_standard} {
						set msg "Retain As A Standard Format ??"
						set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
						if {$choice == "yes"} {
							if {![SaveStandardUnstage]} {
								continue
							}
						}
					}
				}
				if {[string length [file extension $stugemixout]] <= 0} {
					append stugemixout [GetTextfileExtension mmx]
				}
				if {[file exists $stugemixout]} {
					set msg "Overwrite Existing File '$stugemixout' ??"
					set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
					if {$choice == "no"} {
						Inf "Waiting For You To Input New Output Mixfile Name"	
						continue
					} else {
						if {![DeleteNonSndfileFromSystem $stugemixout]} {
							Inf "Cannot Delete Existing Mixfile '$stugemixout'"
							continue
						}
						if [catch {open $stugemixout "w"} zit] {
							Inf "Cannot Open Mixfile '$stugemixout' To Write Data"
							continue
						}
					}
				} else {
					if [catch {open $stugemixout "w"} zit] {
						Inf "Cannot Open Mixfile '$stugemixout' To Write Data"
						continue
					}
				}
				set line 2
				puts $zit $line
				foreach line $stuge_outlines {
					puts $zit $line
				}
				close $zit
				FileToWkspace $stugemixout 0 0 0 0 1
				if {[MixMUpdate $stugemixout 0]} {
					MixMStore
				}
				Inf "File '$stugemixout' Is On The Workspace"
				set finished 1
			}
			2 {
				#REMOVE FILLS ON STAGE DIAGRAM
				if {[info exists stuge_inchans_assigned]} {
					foreach inchan $stuge_inchans_assigned {
						set obj [$stugcan find withtag k$inchan]
						$stugcan itemconfig $obj -fill [option get . background {}]
					}
					unset stuge_inchans_assigned
				}
				#REMOVE ASSIGNMENTS ON BUTTONS
				set n 1
				set panval -1.00
				set panincr 0.05
				while {$n <= 41} {
					.disoctagon.1a.2.b$n config -bg [option get . background {}]
					.disoctagon.1a.2.b$n config -text $panval -font microfnt
					set panval [DecPlaces [expr $panval + $panincr] 2]
					incr n
				}
				.disoctagon.1a.2.b1 config -text "L" -font userfnt -bd 10
				.disoctagon.1a.2.b21 config -text "C" -font userfnt -bd 10
				.disoctagon.1a.2.b41 config -text "R" -font userfnt -bd 10
				.disoctagon.1a.4.ok config -text "" -command {} -bd 0
				.disoctagon.1a.4.no config -text "" -command {} -bd 0
				catch {unset stuge_outpos}
				catch {unset stuge_inchan}
				catch {unset total_stuge_outpositions}
				HideStugeOutputLevels
				set stugecnt 0
			}
			3 {
				if {![info exists stuge_inchan]} {
					Inf "No Input Channel Assigned Yet"
					continue
				}
				if {![info exists stuge_outpos]} {
					Inf "No Output Position Assigned Yet"
					continue
				}
				.disoctagon.1a.4.ok config -text "OK" -command   "set pr_stuge 4" -bd 2
				.disoctagon.1a.4.no config -text "Redo" -command "set pr_stuge 5" -bd 2
			}
			4 {
				.disoctagon.1a.4.ok config -text "" -command {} -bd 0
				.disoctagon.1a.4.no config -text "" -command {} -bd 0
										;# (ADD) INFO TO OUTPUT DATA
				catch {unset do_append}
				if {[info exists total_stuge_outpositions]} {
					foreach {in out} $total_stuge_outpositions {
						if {$out == $stuge_outpos} {
							set do_append 1
							break
						}
					}
				}
				lappend total_stuge_outpositions $stuge_inchan $stuge_outpos
				if {[info exists do_append]} {
					set thistext [.disoctagon.1a.2.b$stuge_outpos cget -text]
					append thistext $stuge_inchan
				} else {
					set thistext $stuge_inchan
				}
				.disoctagon.1a.2.b$stuge_outpos config -background red -text $thistext -font userfnt
				set obj [$stugcan find withtag k$stuge_inchan]
				$stugcan itemconfig $obj -fill red
				incr stugecnt
				catch {unset stuge_outpos}												;#	RESET FOR FURTHER DATA ENTRY
				catch {unset stuge_inchan}
				if {$stugecnt >= $stuge_total_inchans} {
					set msg "All Channels Assigned For File '[file rootname [file tail $stuge_fnam]]'"
					DisplayStugeOutputLevels
				} elseif {[info exists stuge_opposite]} {
					set stuge_outpos $stuge_opposite
					set b_g [.disoctagon.1a.2.b$stuge_opposite cget -background]
					if {![string match $b_g "red"]} {
						.disoctagon.1a.2.b$stuge_opposite config -background lightblue
					}
					unset stuge_opposite
				}
			}
			5 {
				#REMOVE FILL ON OCT DIAGRAM
				set obj [$stugcan find withtag k$stuge_inchan]
				$stugcan itemconfig $obj -fill [option get . background {}]
				if {[info exists stuge_inchans_assigned]} {
					set k [lsearch $stuge_inchans_assigned $stuge_inchan]
					set stuge_inchans_assigned [lreplace $stuge_inchans_assigned $k $k]
					if {[llength $stuge_inchans_assigned] == 0} {
						unset stuge_inchans_assigned
					}
				}
				#REMOVE ASSIGNMENT ON BUTTON
				catch {unset stuge_outpos}
				if {[info exists stuge_opposite]} {
					set stuge_outpos $stuge_opposite
				}
				catch {unset stuge_inchan}
				.disoctagon.1a.4.ok config -text "" -command {} -bd 0
				.disoctagon.1a.4.no config -text "" -command {} -bd 0
			}
			6 {
				set n 1
				while {$n <= $stuge_total_inchans} {
					lappend stuge_outlevels $stuge_outbal($n)
					incr n
				}
				HideStugeOutputLevels
				SaveUnStageData
				catch {unset stuge_outlevels}
				set stuge_all_done 1
			}
		}
	}
	My_Release_to_Dialog .disoctagon
	Dlg_Dismiss .disoctagon
	destroy $f
	set disstage_last 1
	set pr2 3
}

#---- Mark the clicked-near loudspeaker as the current output channel

proc MarkStugLspkr {w x y} {
	global stuge_inchans_assigned stuge_inchan stuge_total_inchans evv

	set displaylist [$w find withtag lspkr]	;#	List all objects which are loudspeakers
	set mindiff 100000								;#	Find closest point
	foreach thisobj $displaylist {
		set coords [$w coords $thisobj]
		set xx [lindex $coords 0]
		set yy [lindex $coords 1]
		set diff [expr abs($x - $xx) + abs($y - $yy)]
		if {$diff < $mindiff} {
			set yyy $yy
			set xxx $xx
			set mindiff $diff
		}
	}
	if {![info exists yyy]} {
		Inf "No Loudspeaker Found At Mouse Click"
		return
	}
	set xxx [expr int(round($xxx))]
	set yyy [expr int(round($yyy))]
	switch -- $stuge_total_inchans {
		8 {
			switch -- $xxx {
				147 {
					if {$yyy == 37} {
						set lspkrno 1 
					} else {
						set lspkrno 6 
					}
				}
				247 {
					if {$yyy == 37} {
						set lspkrno 2 
					} else {
						set lspkrno 5 
					}
				}
				317 {
					if {$yyy == 107} {
						set lspkrno 3
					} else {
						set lspkrno 4
					}
				}
				77  {
					if {$yyy == 207} {
						set lspkrno 7
					} else {
						set lspkrno 8
					}
				}
			}
		}
		7 {
			switch -- $xxx {
				197 {
					set lspkrno 1 
				}
				117 {
					set lspkrno 2 
				}
				277 {
					set lspkrno 3
				}
				77  {
					if {$yyy == 207} {
						set lspkrno 4
					} else {
						set lspkrno 6
					}
				}
				317 {
					if {$yyy == 207} {
						set lspkrno 5
					} else {
						set lspkrno 7
					}
				}
			}
		}
		5 {
			switch -- $xxx {
				197 {
					set lspkrno 1 
				}
				117 {
					set lspkrno 2 
				}
				277 {
					set lspkrno 3
				}
				77  {
					set lspkrno 4
				}
				317 {
					set lspkrno 5
				}
			}
		}
	}
	if {[info exists stuge_inchans_assigned] && ([lsearch $stuge_inchans_assigned $lspkrno] >= 0)} {
		Inf "This Channel Has Already Been Assigned"
		return
	}
	if {[info exists stuge_inchan]} {
		set obj [$w find withtag k$stuge_inchan]
		$w itemconfig $obj -fill [option get . background {}]
		set k [lsearch $stuge_inchans_assigned $stuge_inchan]
		set stuge_inchans_assigned [lreplace $stuge_inchans_assigned $k $k]
		if {[llength $stuge_inchans_assigned] <= 0} {
			unset stuge_inchans_assigned
		}
	}
	set obj [$w find withtag k$lspkrno]
	$w itemconfig $obj -fill $evv(POINT)

	set stuge_inchan $lspkrno
	lappend stuge_inchans_assigned $lspkrno
	return 1
}

#--- Switch betwen selected and unselected state, for input channel buttons

proc SetStageOPos {pos} {
	global total_stuge_outpositions stuge_opposite stuge_outpos wstk evv
	
	set already_set 0
	if {[info exists total_stuge_outpositions]} {
		foreach {in out} $total_stuge_outpositions {
			if {$out == $pos} {
				set msg "This Position Has Already Been Assign To Channel $in : Use It Again ??"
				set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
				if {$choice == "no"} {
					return
				} else {
					set already_set 1
				}
				break
			}
		}
	}
	set n 1
	while {$n <= 41} {
		set b_g [.disoctagon.1a.2.b$n cget -background]
		if {[string match $b_g $evv(EMPH)] || [string match $b_g "lightblue"]} {
			.disoctagon.1a.2.b$n config -background [option get . background {}]
		}
		incr n
	}
	if {!$already_set} {
		.disoctagon.1a.2.b$pos config -background $evv(EMPH)
	}
	if {$pos != 21} {
		set stuge_opposite [expr -($pos - 21) + 21]
	}
	set stuge_outpos $pos
}

#---- Get an existing multichannel mixfile

proc GetUnStageMix {} {
	global wl stugemix stuge_total_inchans pr_stugemix evv wl wstk pa
	foreach fnam [$wl get 0 end] {
		if {($pa($fnam,$evv(FTYP)) == $evv(MIX_MULTI))} {
			lappend posibs $fnam
		}
	}
	if {![info exists posibs]} {
		Inf "No Existing Multi-Channel Mixfiles On The Workspace"
		return
	}
	if {[llength $posibs] == 1} {
		set stugemix [lindex $posibs 0]
		return
	}
	set f .stuge_mix
	if [Dlg_Create $f "MULTI-CHAN MIXFILES ON WORKSPACE" "set pr_stugemix 0" -width 80 -borderwidth $evv(SBDR)] {
		frame $f.0
		frame $f.2
		button $f.0.u -text "Overwrite File" -command "set pr_stugemix 1" -highlightbackground [option get . background {}]
		button $f.0.q -text "Quit" -command "set pr_stugemix 0" -highlightbackground [option get . background {}]
		pack $f.0.u -side left
		pack $f.0.q -side right
		pack $f.0 -side top -fill x -expand true
		label $f.1 -text "SELECT FILE WITH MOUSE" -fg $evv(SPECIAL)
		pack $f.1 -side top -pady 4
		Scrolled_Listbox $f.2.ll -width 64 -height 24 -selectmode single
		pack $f.2.ll -side top -fill both -expand true
		pack $f.2 -side top
		wm resizable $f 1 1
		bind $f <Return> {set pr_stugemix 1}
		bind $f <Escape> {set pr_stugemix 0}
	}
	$f.2.ll.list delete 0 end
	foreach fnam $posibs {
		$f.2.ll.list insert end $fnam
	}
	raise $f
	update idletasks
	StandardPosition2 $f
	set pr_stugemix 0
	set finished 0
	My_Grab 0 $f pr_stugemix
	while {!$finished} {
		tkwait variable pr_stugemix
		if {$pr_stugemix} {
			set i [$f.2.ll.list curselection]
			if {([llength $i] != 1) || ($i == -1)} {
				Inf "Select A Filename"
				continue
			}
			set fnam [$f.2.ll.list get $i]
			set msg "Overwrite File '$fnam' ??"
			set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
			if {$choice == "no"} {
				continue
			}
			if {![DeleteNonSndfileFromSystem $fnam]} {
				Inf "Cannot Delete Existing Mixfile '$fnam'"
				continue
			}
			set stugemix $fnam
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc HelpDisOctStage {chans} {
	set msg "REDUCING $chans CHANNEL STAGE TO STEREO\n"
	append msg "\n"
	append msg "1)  Select position on stereo stage, using buttons at top.\n"
	append msg "2)  Assign to input channel by clicking on Diagram below.\n"
	append msg "3)  Once both are set, Click on \"Finished Assigning\".\n"
	append msg "4)  Confirm your decision by Clicking on \"OK\".\n"
	append msg "5)  Once all channels assigned, new buttons appear at right\n"
	append msg "       where you can set relative levels for input channels.\n"
	append msg "       The default is level 1.0 on all channels,\n"
	append msg "6) Click \"Done\" button on the RH panel when levels are set.\n"
	append msg "7) If you want to save staging as \"Standard Format\"\n"
	append msg "       for future use (see below), do this now.\n"
	append msg "8)  Enter an output mixfile name in the entry box\n"
	append msg "9)  Click on \"Output Staging Data\n"
	append msg "\n"
	append msg "OUTPUT from process is $chans-chan mixfile, mixing to stereo.\n"
	append msg "\n"
	append msg "To SAVE FORMAT you're creating, for future use.\n"
	append msg "1)  Put FORMAT name (not output mix name) in name box.\n"
	append msg "2)  Click on \"Standard Formats\"\n"
	append msg "3)  Select \"Retain as Standard Fomat\".\n"
	append msg "\n"
	append msg "To USE AN EXISTING FORMAT\n"
	append msg "1)  Set name of outmix - NOT name of format - in entry box.\n"
	append msg "2)  Click on  \"Standard Formats\"\n"
	append msg "3)  Select \"Get Standard Mix Format\"\n"
	append msg "      (a) If you have a single format, this will be used:\n"
	append msg "      (b) With many formats, you're offered a choice.\n"
	append msg "      (c) If there are no standard formats, nothing happens.\n"
	Inf $msg
}

proc ConfigureDisOctInterface {fnam} {
	global stugcan evv
	set n 1
	set panval -1.0
	set panincr 0.05
	while {$n <= 41} {
		.disoctagon.1a.2.b$n config -text $panval -font microfnt
		incr n
		set panval [DecPlaces [expr $panval + $panincr] 2]
	}
	.disoctagon.1a.2.b1 config -text "L" -font userfnt -bd 10
	.disoctagon.1a.2.b21 config -text "C" -font userfnt -bd 10
	.disoctagon.1a.2.b41 config -text "R" -font userfnt -bd 10

	.disoctagon.1a.1.ic config -text "Select Stereo Output Position to Assign to an Input Channel"
	set obj [$stugcan find withtag filename]
	$stugcan itemconfig $obj -text "FILE:  [file rootname [file tail $fnam]]"
}

proc SaveUnStageData {} {
	global stuge_fnam stuge_total_inchans total_stuge_outpositions stuge_outlines stuge_outlevels
	set line $stuge_fnam
	lappend line 0.0 $stuge_total_inchans
	foreach {in out} $total_stuge_outpositions {
		set lev [lindex $stuge_outlevels [expr $in - 1]]
		set pos [expr (($out - 1)/ 40.0)]
		set levels [HoleInMiddle $pos]
		set llev [expr [lindex $levels 0] * $lev]
		set rlev [expr [lindex $levels 1] * $lev]
		lappend line $in:1 $llev $in:2 $rlev
	}
	set line [split $line]
	lappend stuge_outlines $line
}

proc HideStugeOutputLevels {} {
	global stuge_outbal stuge_total_inchans
	.disoctagon.2.5.0.0  config -text ""
	.disoctagon.2.5.0.1  config -text "" -bd 0 -command {}
	set n 1
	while {$n <= $stuge_total_inchans} {
		.disoctagon.2.5.$n.e  config -bd 0 -width 0
		.disoctagon.2.5.$n.ll config -text ""
		set stuge_outbal($n) ""
		incr n
	}
}

proc DisplayStugeOutputLevels {} {
	global stuge_total_inchans stuge_outbal pr_stuge
	.disoctagon.2.5.0.0 config -text "RELATIVE LEVELS (USE Up/Down KEYS)"
	.disoctagon.2.5.0.1 config -text "Done" -bd 2 -command "set pr_stuge 6" -width 4
	set val 1
	while {$val <= $stuge_total_inchans} {
		.disoctagon.2.5.$val.e  config -bd 2 -width 4
		.disoctagon.2.5.$val.ll config -text "Channel $val"
		set stuge_outbal($val) 1.0
		incr val
	}
}

proc IncrStugeBalance {which down} {
	global stuge_outbal
	if {[string length $stuge_outbal($which)] > 0} {
		if {$down} {
			if {$stuge_outbal($which) > 0.0} {
				set stuge_outbal($which) [DecPlaces [expr $stuge_outbal($which) - 0.05] 2]
			}
		} else {
			if {$stuge_outbal($which) < 1.0} {
				set stuge_outbal($which) [DecPlaces [expr $stuge_outbal($which) + 0.05] 2]
			}
		}
	}
}

proc HoleInMiddle {position} {

	set pos [expr ($position * 2.0) - 1.0]		;#	Range -1 to 1
	if {$pos < 0} {
		set toleft 1
		set relpos [expr -$pos]
	} else {
		set toleft 0
		set relpos $pos
	}
	if {$relpos <= 1.0} {				;#	between the speakers
		set temp [expr 1.0 + ($relpos * $relpos)]
		set reldist [expr 1.4142136 / sqrt($temp)]
		set rightgain [expr $position * $reldist]
		set leftgain  [expr (1.0 - $position) * $reldist]
	} else {							;#	outside the speakers
		set temp [expr ($relpos * $relpos) + 1.0]
		set reldist [expr sqrt($temp) / 1.4142136]  ;#	relative distance to source
		set invsquare [expr 1.0 / ($reldist * $reldist)]
		if {$toleft} {
			set leftgain $invsquare
			set rightgain 0.0
		} else {
			set rightgain $invsquare
			set leftgain 0.0
		}
	}
	return [list [DecPlaces $leftgain 4] [DecPlaces $rightgain 4]]
}

#---- Save this format for mixing-down-to-stereo as a standard 

proc SaveStandardUnstage {} {
	global stugemix stuge_total_inchans stuge_outlines wstk stuge_standard_saved evv format_nam
	if {![info exists stuge_outlines]} {
		Inf "Mix Format Not Created Yet"
		return 0
	}
	set ident "st_st_"
	append ident $stuge_total_inchans "_" 
	catch {unset format_nam}
	set use_outfile_name 1
	if {[info exists stugemix] && ([string length $stugemix] > 0)} { 
		set msg "Save format using the name of the output file ($stugemix) ??"
		set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
		if {$choice == "no"} {
			set use_outfile_name 0
		}
	} else {
		set use_outfile_name 0
	}
	if {$use_outfile_name} {
		set format_nam [string tolower [file rootname [file tail $stugemix]]]
	} else {
		GetFormatName $ident
	}
	if {![info exists format_nam]} {
		return 0
	}
	set standardname [file join $evv(URES_DIR) $ident]
	append standardname $format_nam $evv(CDP_EXT)
	if {[file exists $standardname]} {
		set msg "A Standard Format With This Name Already Exists: Overwrite It ??"
		set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
		if {$choice == "no"} {
			Inf "Waiting For A New Name"
			return 0
		}
		if [catch {file delete $standardname} zit] {
			set msg "Cannot Delete Existing Standard Format: Try A New Name ??"
			set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
			if {$choice == "yes"} {
				return 0
			}
			return 1
		}
	}
	if [catch {open $standardname "w"} zit] {
		Inf "Cannot Open File To Write Standard Format"
		return 1
	}
	set line 2
	puts $zit $line
	foreach line $stuge_outlines {
		puts $zit $line
	}
	close $zit
	set stuge_standard_saved $stugemix
	return 1
}

#---- Get an existing standard format for mixing down to stereo, and quit the de-stage page

proc GoGetStandardUnstage {} {
	global pr_stuge
	if {[GetStandardUnstage]} {
		set pr_stuge 0
	}
}

#---- Get an existing standard format for mixing down to stereo

proc GetStandardUnstage {} {
	global stuge_this_standard stuge_total_inchans standard_distages pr_standard_distage stuge_fnam wstk evv
	global stugemix disstage_last

	set standard_distages {}
	catch {unset stuge_this_standard}
	set ident "st_st_"
	append ident $stuge_total_inchans "_"
	set identlen [string length $ident]
	foreach fnam [glob -nocomplain [file join $evv(URES_DIR) $ident*]] {
		lappend standard_distages $fnam
	}
	set slen [llength $standard_distages]
	if {$slen == 0} {
		Inf "No Standard Formats For Mixing From $stuge_total_inchans Channels To Stereo"
		return 0
	}
	if {[string length $stugemix] <= 0} {
		Inf "Enter A Name For The Output Mixfile First"
		return 0
	}
	set rname [file rootname [file tail $stugemix]]
	if {![ValidCDPRootname $rname]} {
		return 0
	}
	set stugemixout [string tolower $stugemix]
	if {[string length [file extension $stugemixout]] <= 0} {
		append stugemixout [GetTextfileExtension mmx]
	}
	if {[file exists $stugemixout]} {
		set msg "Overwrite Existing File '$stugemixout' ??"
		set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
		if {$choice == "no"} {
			Inf "Waiting For You To Input New Output Mixfile Name"	
			return 0
		} else {
			if {![DeleteNonSndfileFromSystem $stugemixout]} {
				Inf "Cannot Delete Existing Mixfile '$stugemixout'"
				return 0
			}
		}
	}
	if {$slen == 1} {
		set stuge_this_standard [lindex $standard_distages 0]
	} else {
		set f .standard_distage
		if [Dlg_Create $f "STANDARD FORMATS FOR $stuge_total_inchans CHANNELS TO STEREO" "set pr_standard_distage 0" -width 80 -borderwidth $evv(SBDR)] {
			frame $f.0
			frame $f.2
			button $f.0.u -text "Get Format" -command "set pr_standard_distage 1" -highlightbackground [option get . background {}]
			button $f.0.q -text "Abandon" -command "set pr_standard_distage 0" -highlightbackground [option get . background {}]
			pack $f.0.u -side left
			pack $f.0.q -side right
			pack $f.0 -side top -fill x -expand true
			label $f.1 -text "SELECT FORMAT WITH MOUSE" -fg $evv(SPECIAL)
			pack $f.1 -side top -pady 4
			Scrolled_Listbox $f.2.ll -width 64 -height 8 -selectmode single
			pack $f.2.ll -side top -fill both -expand true
			pack $f.2 -side top
			wm resizable $f 1 1
			bind $f <Return> {set pr_standard_distage 1}
			bind $f <Escape> {set pr_standard_distage 0}
		}
		$f.2.ll.list delete 0 end
		foreach fnam $standard_distages {
			$f.2.ll.list insert end [string range [file rootname [file tail $fnam]] $identlen end]
		}
		raise $f
		update idletasks
		StandardPosition2 $f
		set pr_standard_distage 0
		set finished 0
		My_Grab 0 $f pr_standard_distage
		while {!$finished} {
			tkwait variable pr_standard_distage
			if {$pr_standard_distage} {
				set i [$f.2.ll.list curselection]
				if {![info exists i] || ($i < 0)} {
					Inf "No Item Selected"
					continue
				}
				set stuge_this_standard [lindex $standard_distages $i]
				set finished 1
			} else {
				set finished 1
			}
		}
		My_Release_to_Dialog $f
		Dlg_Dismiss $f
		destroy $f
	}
	if {![info exists stuge_this_standard]} {
		set bum 1
	} elseif [catch {open $stuge_this_standard "r"} zit] {
		set msg "Failed To Open Standard-Format Datafile"
		set bum 1
	} else {
		set linecnt 0
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] < 0} {
				continue
			}
			if {$linecnt == 1} {
				set line [split $line]
				set line [lreplace $line 0 0 $stuge_fnam]
			}
			lappend lines $line
			incr linecnt
		}
		close $zit
		if [catch {open $stugemixout "w"} zit] {
			set msg "Could Not Open File '$stugemixout' To Write Mix Data"
			set bum 1
		} else {
			foreach line $lines {
				puts $zit $line
			}
			close $zit
		}
	}
	if {[info exists bum]} {
		if {[info exists msg]} {
			Inf $msg
		}
		return 0
	}
	Inf "Copied Standard Format [string range [file rootname [file tail $stuge_this_standard]] $identlen end]"
	FileToWkspace $stugemixout 0 0 0 0 0
	if {[MixMUpdate $stugemixout 0]} {
		MixMStore
	}
	Inf "FILE '$stugemixout' Is On The Workspace"
	return 1
}

#--- Delete a standard-format file for stereo-restaging

proc RemoveStandardUnstage {} {
	global pr_standard_delunstage stuge_total_inchans wstk evv

	set standard_delunstages {}
	set ident "st_st_"
	append ident $stuge_total_inchans "_"
	set identlen [string length $ident]
	foreach fnam [glob -nocomplain [file join $evv(URES_DIR) $ident*]] {
		lappend standard_delunstages $fnam
	}
	set slen [llength $standard_delunstages]
	if {$slen == 0} {
		Inf "No Standard Formats For Mixing From $stuge_total_inchans Channels To Stereo"
		return
	}
	set f .standard_delunstage
	if [Dlg_Create $f "REMOVE STANDARD FORMAT FOR $stuge_total_inchans CHANNELS TO STEREO" "set pr_standard_delunstage 0" -width 80 -borderwidth $evv(SBDR)] {
		frame $f.0
		frame $f.2
		button $f.0.u -text "Delete Format" -command "set pr_standard_delunstage 1" -highlightbackground [option get . background {}]
		button $f.0.q -text "Quit" -command "set pr_standard_delunstage 0" -highlightbackground [option get . background {}]
		pack $f.0.u -side left
		pack $f.0.q -side right
		pack $f.0 -side top -fill x -expand true
		label $f.1 -text "SELECT FORMAT WITH MOUSE" -fg $evv(SPECIAL)
		pack $f.1 -side top -pady 4
		Scrolled_Listbox $f.2.ll -width 64 -height 8 -selectmode single
		pack $f.2.ll -side top -fill both -expand true
		pack $f.2 -side top
		wm resizable $f 1 1
		bind $f <Return> {set pr_standard_delunstage 1}
		bind $f <Escape> {set pr_standard_delunstage 0}
	}
	$f.2.ll.list delete 0 end
	foreach fnam $standard_delunstages {
		$f.2.ll.list insert end [string range [file rootname [file tail $fnam]] $identlen end]
	}
	raise $f
	update idletasks
	StandardPosition2 $f
	set pr_standard_delunstage 0
	set finished 0
	My_Grab 0 $f pr_standard_delunstage
	while {!$finished} {
		tkwait variable pr_standard_delunstage
		if {$pr_standard_delunstage} {
			set i [$f.2.ll.list curselection]
			if {![info exists i] || ($i < 0)} {
				Inf "No Item Selected"
				continue
			}
			set nam [$f.2.ll.list get $i]
			set msg "Are You Sure You Want To Delete Standard Format '$nam' ??"
			set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
			if {$choice == "no"} {
				continue
			}
			set fnam [lindex $standard_delunstages $i]
			if [catch {file delete $fnam} zit] {
				Inf "Failed To Delete Standard Format '$nam' In File '$fnam'"
				continue
			}
			$f.2.ll.list delete $i
			set standard_delunstages [lreplace $standard_delunstages $i $i]
			if {[llength $standard_delunstages] <= 0} {
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

#----- Apply Standard collapse-to-stereo to existing line in a multichannel file
#
#	Original routing must be monopolar i.e. input channels must go to SINGLE output channels.

proc QikDoStandardUnstage {} {
	global stuge_this_standard standard_distages pr_standard_distage evv wstk
	global hilitecheck m_list_restore m_previous_yview m_list mlst previous_linestore mix_outchans mlsthead
	global mixd2

	set allsame 0

	set ilist [$m_list curselection]
	if {([llength $ilist] < 1) || (([llength $ilist] == 1) && ($ilist == -1))} {
		Inf "Select One Or More Mixfile Lines"
		return
	}
	foreach i $ilist { 
		set line [lindex $mlst $i]
		if {[string first ";" $line] < 0} {
			lappend nuilist $i
		}
	}
	if {![info exists nuilist]} {
		Inf "Select One Or More Active Mixfile Lines"
		return
	}
	set ilist $nuilist

	set previous_linestore $mlst

	;# CHECK ROUTES AND LEVELS FROM MIXFILE LINES

	foreach i $ilist {
		catch {unset srcchin}
		catch {unset srcchout}
		catch {unset srclev}
		set line [lindex $mlst $i]
		set cnt 0
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			switch -- $cnt {
				0 {
					set snd $item
				}
				1 {
					set tim $item
				}
				2 {
					set src_outchans $item
				}
				default {
					if {![IsEven $cnt]} {
						set item [split $item  ":"]
						set thischin  [lindex $item 0]
						set thischout [lindex $item 1]
						lappend srcchin  $thischin
						lappend srcchout $thischout
					} else {
						lappend srclev $item
					}
				}
			}
			incr cnt
		}
		if {[IsEven $cnt]} {
			Inf "Bad Item Count In Selected Mixfile Line [expr $i + 1]"
			return
		}

		;# CHECK OUTPUT IS MONOPOLAR

		set len [llength $srcchin]
		set len_less_one [expr $len - 1]
		set n 0
		while {$n < $len_less_one} {
			set chin_n [lindex $srcchin $n]
			set m $n
			incr m
			while {$m < $len} {
				set chin_m [lindex $srcchin $m]
				if {$chin_n == $chin_m} {
					Inf "All Mixfile-Line Inputs Do Not Go To Different Outputs  In Line [expr $i + 1]"
					return
				}
				incr m
			}
			incr n
		}
	}

	;# PROCESS EACH LINE IN TURN 

	foreach i $ilist {
		set line [lindex $mlst $i]

		;#	EXTRACT THE EXISTING ROUTES AND LEVELS

		catch {unset srcchin}
		catch {unset srcchout}
		catch {unset srclev}
		set cnt 0
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			switch -- $cnt {
				0 {
					set snd $item
				}
				1 {
					set tim $item
				}
				2 {
					set src_outchans $item
				}
				default {
					if {![IsEven $cnt]} {
						set item [split $item  ":"]
						set thischin  [lindex $item 0]
						set thischout [lindex $item 1]
						lappend srcchin  $thischin
						lappend srcchout $thischout
					} else {
						lappend srclev $item
					}
				}
			}
			incr cnt
		}

	;#  GET AN EXISTING STANDARD STEREO-COLLAPSE FORMAT, AND TEST ITS COMPATIBILITY WITH MIXFILE LINE
	;#	(DON'T REPEAT THIS IF THE SAME FORMAT IS TO BE USED FOR AL SELECTED LINES)

		if {!$allsame} {

			set standard_distages {}
			catch {unset stuge_this_standard}
			set ident "st_st_"
			append ident $src_outchans "_"
			set identlen [string length $ident]
			foreach fnam [glob -nocomplain [file join $evv(URES_DIR) $ident*]] {
				lappend standard_distages $fnam
			}
			set slen [llength $standard_distages]
			if {$slen == 0} {
				Inf "No Standard Formats For Mixing From Line [expr $i + 1], With $src_outchans Channels, To Stereo"
				continue
			}
			if {$slen == 1} {
				set stuge_this_standard [lindex $standard_distages 0]
			} else {
				set f .standard_distage
				if [Dlg_Create $f "FORMATS FOR $src_outchans->STEREO : SELECTED LINE [expr $i+1]" "set pr_standard_distage 0" -width 120 -borderwidth $evv(SBDR)] {
					frame $f.0
					frame $f.2
					button $f.0.u -text "Get Format" -command "set pr_standard_distage 1" -highlightbackground [option get . background {}]
					button $f.0.q -text "Abandon" -command "set pr_standard_distage 0" -highlightbackground [option get . background {}]
					pack $f.0.u -side left
					pack $f.0.q -side right
					pack $f.0 -side top -fill x -expand true
					label $f.1 -text "SELECT FORMAT WITH MOUSE" -fg $evv(SPECIAL)
					pack $f.1 -side top -pady 4
					Scrolled_Listbox $f.2.ll -width 120 -height 8 -selectmode single
					pack $f.2.ll -side top -fill both -expand true
					pack $f.2 -side top
					wm resizable $f 1 1
					bind $f <Return> {set pr_standard_distage 1}
					bind $f <Escape> {set pr_standard_distage 0}
				}
				$f.2.ll.list delete 0 end
				foreach fnam $standard_distages {
					$f.2.ll.list insert end [string range [file rootname [file tail $fnam]] $identlen end]
				}
				raise $f
				update idletasks
				StandardPosition2 $f
				set pr_standard_distage 0
				set finished 0
				My_Grab 0 $f pr_standard_distage
				while {!$finished} {
					tkwait variable pr_standard_distage
					if {$pr_standard_distage} {
						set j [$f.2.ll.list curselection]
						if {![info exists j] || ($j < 0)} {
							Inf "No Item Selected"
							continue
						}
						set stuge_this_standard [lindex $standard_distages $j]
						set finished 1
					} else {
						set finished 1
					}
				}
				My_Release_to_Dialog $f
				Dlg_Dismiss $f
				destroy $f
			}
			if {![info exists stuge_this_standard]} {
				if {$i != [lindex $ilist end]} {
					set msg "Process The Remaining Lines ??"
					set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
					if {$choice == "yes"} {
						continue
					}
				}
				return
			} elseif [catch {open $stuge_this_standard "r"} zit] {
				set msg "Failed To Open Standard-Format Datafile For Line [expr $i + 1]"
				if {$i != [lindex $ilist end]} {
					append msg "\n\nProcess The Remaining Lines ??"
					set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
					if {$choice == "yes"} {
						continue
					}
				} else {
					Inf $msg
				}
				return
			}
			set linecnt 0
			set OK 1
			catch {unset chin}
			catch {unset chout}
			catch {unset levs}
			while {[gets $zit line] >= 0} {
				set line [string trim $line]
				if {[string length $line] < 0} {
					continue
				}
				if {$linecnt == 1} {
					set line [split $line]
					set cnt 0
					foreach item $line {
						set item [string trim $item]
						if {[string length $item] <= 0} {
							continue
						}
						switch -- $cnt {
							0 -
							1 {
							}
							2 {
								if {$item != $src_outchans} {
									set msg "This Stereo-Collapse Data Is For The Wrong Number ($chn) Of Input Channels On Line [$i + 1]"
									set OK 0
									break
								}
							}
							default {
								if {![IsEven $cnt]} {
									set item [split $item  ":"]
									if {[llength $item] != 2} {
										set msg "Corrupted Data In Standard-Format Datafile For Line [$i + 1]"
										set OK 0
										break
									}
									set thischin  [lindex $item 0]
									set thischout [lindex $item 1]
									if {![regexp {^[0-9]+$} $thischin] || ![regexp {^[0-9]+$} $thischout]} {
										set msg "Non-Numeric Data For Channels In Standard-Format Datafile For Line [$i + 1]"
										set OK 0
										break
									}
									lappend chin  $thischin
									lappend chout $thischout
								} else {
									lappend levs $item
								}
							}
						}
						incr cnt
					}
					if {!$OK} {
						break
					}
					if {[IsEven $cnt]} {
						set msg "Bad Item Count In Standard-Format Datafile Line For Line [$i + 1]"
						set OK 0
						break
					}
					if {![info exists chin] || ![info exists levs]} {
						set msg "Failed To Extract Routing Info From Standard-Format Datafile For Line [$i + 1]"
						set OK 0
						break
					}
					break
				}
				incr linecnt
			}
			close $zit
			if {$linecnt != 1} {
				set msg "Corrupted Data (Bad Linecnt) in Standard-Format Datafile For Line [$i + 1]"
				set OK 0
			}
			if {!$OK} {
				if {$i != [lindex $ilist end]} {
					append msg "\n\nProcess The Remaining Lines ??"
					set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
					if {$choice == "yes"} {
						continue
					}
				} else {
					Inf $msg
				}
				return
			}
			if {$i != [lindex $ilist end]} {
				set msg "Use This Format For All The Selected Lines ?"
				set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
				if {$choice == "yes"} {
					set allsame 1
				}
			}
		}

		;# CHECK STANDARD-ROUTING DATA DEALS WITH ALL OUTPUT CHANS OF SOURCE

		catch {unset badchans}
		foreach thisout $srcchout {
			set OK 0
			foreach reroutout $chin {
				if {$thisout == $reroutout} {
					set OK 1
					break
				}
			}
			if {!$OK} {
				lappend badchans $thisout
			}
		}
		if {[info exists badchans]} {
			set msg "Standard Routing Does Not Deal With Output Channels $badchans In Mixfile Line Line [$i + 1]"
			if {$i != [lindex $ilist end]} {
				append msg "\n\nProcess The Remaining Lines ??"
				set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
				if {$choice == "yes"} {
					continue
				}
			} else {
				Inf $msg
			}
			return
		}

		;# FIND DESTINATION OF ORIGINAL ROUTING, AND REROUTE AS PER STEREO STANDARD-FORMAT FOR THAT OUTPUT
		;# CONCATENATE (MULTIPLY) THE LEVEL CHANGES 

		catch {unset nuroutings}
		catch {unset nu_ins}
		catch {unset nu_outs}
		foreach origin $srcchin origout $srcchout origlev $srclev {
			foreach in $chin out $chout lev $levs {
				if {$origout == $in} {
					set nurout $origin
					append nurout ":" $out
					set nulev [expr $origlev * $lev]
					lappend nuroutings [list $nurout $nulev]
					lappend nu_ins  $origin
					lappend nu_outs $out
				}
			}
		}

		;#	LOGICALLY ORDER THE NEW ROUTINGS

		set len [llength $nuroutings]
		set len_less_one [expr $len - 1]
		set n 0
		while {$n < $len_less_one} {
			set chin_n  [lindex $nu_ins $n]
			set chout_n [lindex $nu_outs $n]
			set rout_n  [lindex $nuroutings $n]
			set m $n
			incr m
			while {$m < $len} {
				set doit 0
				set chin_m  [lindex $nu_ins $m]
				set chout_m [lindex $nu_outs $m]
				set rout_m  [lindex $nuroutings $m]
				if {$chin_m < $chin_n} {
					set doit 1
				} elseif {($chin_n == $chin_m) && ($chout_m < $chout_n)} {
					set doit 1
				}
				if {$doit} {
					set nuroutings [lreplace $nuroutings $n $n $rout_m] 
					set nuroutings [lreplace $nuroutings $m $m $rout_n] 
					set nu_ins [lreplace $nu_ins $n $n $chin_m] 
					set nu_ins [lreplace $nu_ins $m $m $chin_n] 
					set nu_outs [lreplace $nu_outs $n $n $chout_m] 
					set nu_outs [lreplace $nu_outs $m $m $chout_n] 
					set rout_n $rout_m
					set chin_n $chin_m
					set chout_n $chout_m
				}
				incr m
			}
			incr n
		}

		;#	CREATE THE OUTPUT LINE

		set nuline [list $snd $tim $src_outchans]
		foreach nurout $nuroutings {
			set rout [lindex $nurout 0]
			set lev  [lindex $nurout 1]
			lappend nuline $rout $lev
		}

		set mlst [lreplace $mlst $i $i $nuline]

	}
	;#	REDISPLAY MIXLIST

	catch {unset hilitecheck}
	catch {unset m_list_restore}
	catch {unset m_previous_yview}

	set mlst [lreplace $mlst $i $i $nuline]
	DisplayMixlist 0

	;#	CHECK FOR STEREO-ONLY OUTPUT

	if {$mix_outchans > 2} {
		set stereo_out 1
		foreach line $mlst {
			if {[string first ";" $line] >= 0} {
				continue
			}
			set line [split $line]
			set cnt 0
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				if {($cnt > 2) && ![IsEven $cnt]} {
					set outrout [lindex [split $item ":"] 1]
					if {$outrout > 2} {
						set stereo_out 0
						break
					}
				}
				incr cnt
			}
			if {!$stereo_out} {
				break
			}
		}
		if {$stereo_out} {
			set msg "Output Of This Mix Is Entirely On Channels 1 & 2:\n\nConvert From $mix_outchans Channel Output To Stereo Output ??"
			set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
			if {$choice == "yes"} {
				set mix_outchans 2
				set mlsthead 2
				Inf "Output Channel-Count Changed To $mix_outchans"
				$mixd2.1.title.title  config -text "MULTI-CHANNEL MIXFILE : $mix_outchans chans"
			}
			catch {unset previous_linestore}
		}
	}
}

#--- Rename a standard-format file for multichannel-staging

proc RenameStandardStage {unstage} {
	global pr_standard_rnmstage pr_prernm stuge_total_inchans stage_output_chans chchans standard_rnm wstk evv prernm rnam_chans
	catch {unset rnam_chans}
	if {$unstage} {
		set ident "st_st_"
		append ident $stuge_total_inchans "_"
	} else {
		set msg "PROCESS ASSUMES THAT THE ~~INPUT~~ CHANNEL-COUNT OF ANY RESTAGING YOU WISH TO FIND (AND RENAME)\n"
		append msg "IS THE SAME AS THE CHANNEL-COUNT OF THE CHOSEN-FILE YOU ARE USING."
		Inf $msg
		set f .prernm
		if [Dlg_Create $f "SPECIFY CHANNEL-OUTPUT-COUNT OF RESTAGING" "set pr_prernm 0" -width 80 -borderwidth $evv(SBDR)] {
			frame $f.0
			button $f.0.go -text "Select Output Channel Count" -command "set pr_prernm 1"
			button $f.0.quit -text "Abandon" -command "set pr_prernm 0"
			pack $f.0.go -side left
			pack $f.0.quit  -side right
			pack $f.0 -side top -fill x -expand true
			frame $f.1
			radiobutton $f.1.4  -text 4  -value 4  -variable prernm -width 6
			radiobutton $f.1.5  -text 5  -value 5  -variable prernm -width 6
			radiobutton $f.1.7  -text 7  -value 7  -variable prernm -width 6
			radiobutton $f.1.8  -text 8  -value 8  -variable prernm -width 6
			radiobutton $f.1.16 -text 16 -value 16 -variable prernm -width 6
			pack $f.1.4 $f.1.5 $f.1.7 $f.1.8 $f.1.16 -side left
			pack $f.1 -side top 
			bind $f <Return> {set pr_prernm 1}
			bind $f <Escape> {set pr_prernm 0}
		}
		set prernm 0
		raise $f
		update idletasks
		StandardPosition2 $f
		set pr_prernm 0
		set finished 0
		My_Grab 0 $f pr_prernm
		while {!$finished} {
			tkwait variable pr_prernm
			switch -- $pr_prernm {
				1 {
					if {$prernm <= 0} {
						Inf "NO STAGING OUTPUT-CHANNEL-COUNT ENTERED"
						continue
					}
					set rnam_chans $prernm
					set finshed 1
				}
				0 {
					set finshed 1
				}
			}
		}
		if {![info exists rnam_chans]} {
			My_Release_to_Dialog $f
			Dlg_Dismiss $f
			destroy $f
			return
		} else {			
			My_Release_to_Dialog $f
			Dlg_Dismiss $f
		}
		set ident "stst_"
		append ident $rnam_chans "_"
		append [lindex $chchans 0] "_"
	}
	set identlen [string length $ident]
	set standard_rnmstages {}
	foreach fnam [glob -nocomplain [file join $evv(URES_DIR) $ident*]] {
		lappend standard_rnmstages $fnam
	}
	set slen [llength $standard_rnmstages]
	if {$slen == 0} {
		if {[info exists rnam_chans]} {
			Inf "THERE ARE NO STANDARD FORMATS FOR STAGING TO $rnam_chans CHANNELS"
			catch {destroy .prernm}
		} else {
			Inf "THERE ARE NO STANDARD FORMATS FOR REDUCTION TO STEREO"
		}
		return
	}
	set f .standard_rnmstage
	if [Dlg_Create $f "RENAME STANDARD FORMAT" "set pr_standard_rnmstage 0" -width 80 -borderwidth $evv(SBDR)] {
		frame $f.0
		frame $f.00
		frame $f.2
		button $f.0.u -text "Rename" -command "set pr_standard_rnmstage 1"
		button $f.0.q -text "Quit" -command "set pr_standard_rnmstage 0"
		pack $f.0.u -side left
		pack $f.0.q -side right
		pack $f.0 -side top -fill x -expand true
		label $f.00.ll -text "New Format Name"
		entry $f.00.e -textvariable standard_rnm -width 40
		pack $f.00.e $f.00.ll -side left
		pack $f.00 -side top -pady 2
		label $f.1 -text "SELECT FORMAT TO RENAME WITH MOUSE" -fg $evv(SPECIAL)
		pack $f.1 -side top -pady 4
		Scrolled_Listbox $f.2.ll -width 64 -height 8 -selectmode single
		pack $f.2.ll -side top -fill both -expand true
		pack $f.2 -side top
		wm resizable $f 0 0
		bind $f <Return> {set pr_standard_rnmstage 1}
		bind $f <Escape> {set pr_standard_rnmstage 0}
	}
	$f.2.ll.list delete 0 end
	foreach fnam $standard_rnmstages {
		$f.2.ll.list insert end [string range [file rootname [file tail $fnam]] $identlen end]
	}
	raise $f
	update idletasks
	StandardPosition2 $f
	set pr_standard_rnmstage 0
	set finished 0
	My_Grab 0 $f pr_standard_rnmstage
	while {!$finished} {
		tkwait variable pr_standard_rnmstage
		switch -- $pr_standard_rnmstage {
			1 {
				if {[string length $standard_rnm] <= 0} {
					Inf "NO FORMAT NAME GIVEN"
					continue
				}
				if {![ValidCDPRootname $standard_rnm]} {
					Inf "INVALID FORMAT NAME"
					continue
				}
				set new_listnam [string tolower $standard_rnm]

				set i [$f.2.ll.list curselection]
				if {![info exists i] || ($i < 0)} {
					Inf "NO ITEM SELECTED FOR RENAMING"
					continue
				}
				set nam [$f.2.ll.list get $i]

				set oldfnam $ident
				append oldfnam $nam $evv(CDP_EXT)
				set oldfnam [file join $evv(URES_DIR) $oldfnam]

				set newfnam $ident
				append newfnam $new_listnam $evv(CDP_EXT)
				set newfnam [file join $evv(URES_DIR) $newfnam]

				if {[file exists $newfnam]} {
					Inf "A STANDARD FORMAT WITH THIS NAME ALREADY EXISTS: PLEASE CHOOSE A NEW NAME"
					continue
				}
				if [catch {file rename $oldfnam $newfnam} zit] {
					Inf "CANNOT RENAME THE FORMAT $nam"
					continue
				}
				$f.2.ll.list delete $i
				$f.2.ll.list insert $i $new_listnam
				$f.2.ll.list selection clear 0 end
				set msg "RENAME ANOTHER (OR THE SAME) FILE ???"
				set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
				if {$choice == "yes"} {
					set standard_rnm ""
					continue
				}
				set finished 1
			}
			0 {
				set finished 1
			}
			2 {
				set msg "RENAME ANOTHER (OR THE SAME) FILE ???"
				set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
				if {$choice == "yes"} {
					set standard_rnm ""
					set finished 1
				} else {
					set finished 1
				}
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
	if {[winfo exists .prernm]} {
		destroy .prernm
	}
}

#----Name the staging format

proc GetFormatName {ident} {
	global evv wstk standard_nam format_nam pr_stagform
	set f .stagform
	if [Dlg_Create $f "Name standard format" "set pr_stagform 0" -width 80 -borderwidth $evv(SBDR)] {
		frame $f.0
		frame $f.1
		button $f.0.u -text "Rename" -command "set pr_stagform 1" -highlightbackground [option get . background {}]
		button $f.0.q -text "Quit" -command "set pr_stagform 0" -highlightbackground [option get . background {}]
		pack $f.0.u -side left
		pack $f.0.q -side right
		pack $f.0 -side top -fill x -expand true
		label $f.1.ll -text "New Format Name"
		entry $f.1.e -textvariable standard_nam -width 40
		pack $f.1.e $f.1.ll -side left
		pack $f.1 -side top -pady 2
		bind $f <Return> {set pr_stagform 1}
		bind $f <Escape> {set pr_stagform 0}
	}
	raise $f
	update idletasks
	StandardPosition2 $f
	set pr_stagform 0
	set finished 0
	My_Grab 0 $f pr_stagform
	while {!$finished} {
		tkwait variable pr_stagform
		switch -- $pr_stagform {
			1 {
				if {[string length $standard_nam] <= 0} {
					Inf "No format name given"
					continue
				}
				if {![ValidCDPRootname $standard_nam]} {
					Inf "Invalid format name"
					continue
				}
				set outname [string tolower $standard_nam]
				set standardname [file join $evv(URES_DIR) $ident]
				append standardname $outname $evv(CDP_EXT)
				if {[file exists $standardname]} {
					set msg "A standard format with this name already exists: overwrite it ??"
					set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
					if {$choice == "no"} {
						Inf "Waiting for a new name"
						continue
					}
					if [catch {file delete $standardname} zit] {
						set msg "Cannot delete existing standard format: try a new name ??"
						set choice [tk_messageBox -type yesno -icon question -message $msg -parent [lindex $wstk end]]
						if {$choice == "yes"} {
							continue
						}
					}
				} else {
					set format_nam $outname
				}
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
