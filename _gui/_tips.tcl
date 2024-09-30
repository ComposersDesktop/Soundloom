#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD 30 June 2013
# ... fixup button rectangles

########
# TIPS #
########

#------ Display of tips for when stuck

proc Tips {where} {
	global prtips ftips_display tips sl_real evv
	set f .tips
	if [Dlg_Create $f "Tips" "set prtips 1" -borderwidth $evv(SBDR)] {
		set b [frame $f.buttons -borderwidth $evv(SBDR)]
		set tips [Scrolled_Listbox $f.props -width 120 -height 20]
		pack $f.buttons $f.props -side top -fill x
		button $b.ok -text OK -command {set prtips 1} -highlightbackground [option get . background {}]
		pack $b.ok -side top
		bind .tips <ButtonRelease-1> {HideWindow %W %x %y prtips}
		wm resizable $f 1 1
		bind $f <Return> {set prtips 1}
		bind $f <Escape> {set prtips 1}
		bind $f <Key-space> {set prtips 1}
	}
	$tips delete 0 end
	switch -- $where {
		"ppg" {
			if {!$sl_real} {
				$tips insert end "In This Demonstration Version Of The Soundloom"
				$tips insert end "Most Processes Are Inactive, And Their Menus Appear with No Text to identify them."
				$tips insert end ""
				$tips insert end "FOR AN OVERVIEW OF ALL THE PROCESSES ON A SINGLE MENU...."
				$tips insert end "Click on the 'Info' button, if you can see it."
				$tips insert end "Click on the radio-button labelled 'menu'."
				$tips insert end "Select any menu, to see a listing of the processes on that menu."
				$tips insert end ""
				$tips insert end "TO FIND OUT WHAT EACH PROCESS DOES....."
				$tips insert end "Click on the 'Info' button, if you can see it."
				$tips insert end "Click on the radio-button labelled 'process'."
				$tips insert end "Select any menu, and any item on that menu,"
				$tips insert end "for a brief description of the process."
			} else {
				$tips insert end "PROCESSES YOU EXPECT TO USE ARE NOT ACTIVE"
				$tips insert end ""
				$tips insert end "1)  Did you move the files you want to process to the chosen files list?"
				$tips insert end "2)  Try 'Refresh File Data' on the 'Play:Props' menu, above the Chosen Files list on the Workspace?"
				$tips insert end "         If this does not work....."
				$tips insert end "3)  Do the input files have the properties you think they have?"
				$tips insert end "4)  Does the process you want to use work with such files?"
				$tips insert end "5)  If there is more than one file, are they are in the correct order?"
				$tips insert end "6)  If OK, on the workspace highlight the chosen files, & select 'Update Data' from 'Selected Files' menu"
				$tips insert end "7)  If this fails and you are absolutely certain the process should be available, try restarting the Sound Loom."
			}
		}
		"ins" {
			$tips insert end "USING FILENAMES AS PARAMETERS WHEN CREATING INSTRUMENTS"
			$tips insert end ""
			$tips insert end "When creating an instrument AVOID, where possible, using filenames as input values to the instrument."
			$tips insert end "Once the instrument is defined, you can always USE filenames as instrument parameters (where appropriate)."
			$tips insert end ""
			$tips insert end "A filename used during the CREATION of an instrument would become the default value for the Instrument variable."
			$tips insert end "If you later delete or move that file to a new directory, if the file was used as a variable (displayed) parameter"
			$tips insert end "the instrument will always give a warning message before defaulting to the standard parameter default value."
			$tips insert end "However, if the file was a fixed (hidden) parameter, the instrument will cease to function."
			$tips insert end ""
			$tips insert end "CREATING INSTRUMENTS USING SPECTRAL PROCESSES"
			$tips insert end ""
			$tips insert end "When NOT using spectral processes, if the output of your instrument (at any stage) is not what you want, you can simply"
			$tips insert end "1)  rerun the process with new parameters or"
			$tips insert end "2)  choose a new process"
			$tips insert end "and then continue building your Instrument."
			$tips insert end ""
			$tips insert end "However, to get a soundfile from an Instrument using a spectal process, you must resynthesize the spectral output of the previous process."
			$tips insert end "Once you have done this, but find that you don't like the result,"
			$tips insert end "you cannot then back-track to the previous (spectral) process."
			$tips insert end ""
			$tips insert end "To avoid this problem, proceed as follows when creating an instrument using a spectral process..."
			$tips insert end ""
			$tips insert end "1)  When running the spectral process, ensure that any parameter you may later wish to alter"
			$tips insert end "          is ticked as 'variable' (on the right of the parameter display)."
			$tips insert end "2)  Otherwise, make your instrument in the normal way."
			$tips insert end "3)  If you do not like the final (resynthesized) output sound, SAVE IT anyway, and SAVE THE INSTRUMENT."
			$tips insert end "4)  Delete the unwanted sound output."
			$tips insert end "5)  RUN the Instrument you have created. This time enter better values as parameters TO THE INSTRUMENT."
		}
		"ted" {
			$tips insert end "SAVING TABLE AS A FILE WITH THE SAME NAME AS THE INPUT TABLE FILE"
			$tips insert end ""
			$tips insert end "You cannot use the original-input-file-name (named above the input table)"
			$tips insert end "as the name of the output file (the Sound Loom prevents you from doing this)."
			$tips insert end ""
			$tips insert end "To get around this, once you are ready to save, choose (any) different file"
			$tips insert end "from the list of files on the left."
			$tips insert end "You can now use the name of the original input file for the output file."
		}
	}
	set prtips 0
	raise $f
	My_Grab 0 $f prtips $tips
	tkwait variable prtips
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#------ Text Display to Hold on deSktop

proc BareText {} {
	global pr_bare evv pa wl bare wstk
	set memfile [file join $evv(URES_DIR) permdisp$evv(CDP_EXT)]
	set f .baretxt
	if {[winfo exists .baretxt]} {
		set pr_bare 0
		set newfile 0
		raise $f
	} else {
		set newfile 1
		if {[file exists $memfile]} {
			if [catch {open $memfile "r"} zit] {
				set msg "Cannot open file $memfile to find permanent display file : get new file from workspace ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					catch {file delete $memfile}
					catch {unset bare(rememd)}
					return
				}
			} else {
				gets $zit fnam
				close $zit
				set fnam [string trim $fnam]
				if {[string length $fnam] <= 0} {
					set msg "No data in file $memfile : get new file from workspace ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						catch {file delete $memfile}
						catch {unset bare(rememd)}
						return
					}
				} elseif {![file exists $fnam]} {
					set msg "File $fnam no longer exists : get new file from workspace ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						catch {file delete $memfile}
						catch {unset bare(rememd)}
						return
					}
				} else {
					set ftyp [FindFileType $fnam]
					if {!($ftyp & $evv(IS_A_TEXTFILE))} {
						set msg "File $fnam is not a valid textfile : get new file from workspace ??"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							catch {file delete $memfile}
							catch {unset bare(rememd)}
							return
						}
					} else {
						set newfile 2
						set bare(rememd) 1
					}
				}
			}
		}
	}
	if {$newfile} {
		if {$newfile == 1} {
			set i [$wl curselection]
			if {![info exists i] || ([llength $i] != 1) || ($i == -1)} {
				Inf "Select a single textfile"
				return
			}
			set fnam [$wl get $i]
			if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
				Inf "Select a textfile"
				return
			}
		}
		if [info exists bare] {
			foreach nam [array names bare] {
				catch {unset $nam}
			}
		}
		destroy .baretxt
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot open file $fnam"
			return
		}
		catch {unset bare(lines)}
		while {[gets $zit line] >= 0} {
			if {[string length [string trim $line]] <= 0} {
				lappend bare(lines) $line
				continue
			}
			set len [string length $line]
			set len_less_one [expr $len - 1]
			set n 0
			while {$n < $len_less_one} {
				if {[string match [string index $line $n] "\t"]} {
					set linea ""
					if {$n > 0} {
						append linea [string range $line 0 [expr $n - 1]]
					}
					append linea "    " [string range $line [expr $n + 1] end]
					incr n 3
					incr len_less_one 3
					set line $linea
				}
				incr n
			}
			lappend bare(lines) $line
		}
		close $zit
		if {![info exists bare(lines)]} {
			Inf "No text to display"
			return
		}
		if [Dlg_Create .baretxt "DISPLAY" "set pr_bare 1" -borderwidth $evv(BBDR)] {
			frame $f.0
			button $f.0.q -text "Close Display" -command "set pr_bare 0" -width 56 -highlightbackground [option get . background {}]
			button $f.0.n -text "Replace Display" -command "set pr_bare 2" -width 15 -highlightbackground [option get . background {}]
			button $f.0.s -text "Return" -command "set pr_bare 1" -highlightbackground [option get . background {}]
			button $f.0.h -text "Help" -command "PermanentHelp" -bg $evv(HELP) -highlightbackground [option get . background {}]
			pack $f.0.s $f.0.h $f.0.n $f.0.q -side left -padx 2
			pack $f.0 -side top -fill x -expand true
			frame $f.00
			label $f.00.pg -text "\"Control-P\" = Play selected : \"Control-G\" = Grab to Workspace" -fg $evv(SPECIAL)
			pack $f.00.pg -side left
			pack $f.00 -side top -fill x -expand true
			frame $f.1
			label $f.1.tot -text "FILE   :   "
			label $f.1.tit -text [file rootname [file tail $fnam]] -fg $evv(SPECIAL)
			pack $f.1.tot $f.1.tit -side left -pady 2
			pack $f.1 -side top -fill x -expand true
			frame $f.2
			Scrolled_Listbox $f.2.ll -width 180 -height 48 -selectmode single
			pack $f.2.ll -side top -pady 2
			pack $f.2 -side top -pady 2 -fill x -expand true
			bind $f <Control-Key-P> {UniversalPlay xlist .baretxt.2.ll.list}
			bind $f <Control-Key-p> {UniversalPlay xlist .baretxt.2.ll.list}
			bind $f <Control-Key-G> {UniversalGrab .baretxt.2.ll.list}
			bind $f <Control-Key-g> {UniversalGrab .baretxt.2.ll.list}
			bind $f <Escape> {set pr_bare 0}
			bind $f <Return> {set pr_bare 1}
		}
		.baretxt.2.ll.list delete 0 end
		foreach line $bare(lines) {
			.baretxt.2.ll.list insert end $line
		}
		set pr_bare 0
		raise $f
		update idletasks
		StandardPosition3 $f
	}
	.baretxt.0.q config -text "Close Display" -bg [option get . background {}]
	Simple_Grab 0 $f pr_bare
	tkwait variable pr_bare
	if {$pr_bare == 2} {
		if [catch {file delete $memfile} zit] {
			Inf "Cannot delete file $memfile to forget your current permanent display text\ndelete outside workspace to get rid of it"
		}
		catch {unset bare(rememd)}
		set bazoogled 1
		set pr_bare 0
	}
	if {$pr_bare == 0}  {
		if {![info exists bare(rememd)] && ![info exists bazoogled] && [info exists fnam]} {
			set msg "Remember this file ??"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "yes"} {
				if [catch {open $memfile "w"} zit] {
					Inf "Cannot open file $memfile to remember this display file : $zit"
				} else {
					puts $zit $fnam
					close $zit
				}
			}
		}
		if [info exists bare] {
			foreach nam [array names bare] {
				if {![string match $nam rememd]} {
					catch {unset $nam}
				}
			}
		}
	}
	.baretxt.0.q config -text "To Close, 1st ReSelect from Wkspace with \"Display\"" -bg red
	catch {Simple_Release_to_Dialog .baretxt}
	if {$pr_bare == 0}  {
		destroy .baretxt
	}
	return
}

proc PermanentHelp {} {
	set msg "The \"Display\" Window\n"
	append msg "\n"
	append msg "\"Close Display\" :\n"
	append msg "Closes the Display window.\n"
	append msg "\n"
	append msg "\"Return\" :    Returns focus to the Workspace \n"
	append msg "(or whichever window is currently being used)\n"
	append msg "so you can proceed with sound processing,\n"
	append msg "but the \"Display\" window remains on your desktop.\n"
	append msg "\n"
	append msg "Note that you cannot USE or CLOSE the Workspace\n"
	append msg "unless you \"Return\" from or \"Close\" the Display.\n"
	append msg "\n"
	append msg "On selecting \"Return\", the \"Close\" button changes to\n"
	append msg "\"To Close, 1st Reselect From Wkspace with \"Display\"\".\n"
	append msg "\n"
	append msg "To Close, 1st Reselect From Wkspace with \"Display\":\n"
	append msg "If this (Red) button has replaced the \"Close Display\" button\n"
	append msg "but you wish to Close the Display window,\n"
	append msg "first select \"Display\" on the Workspace\n"
	append msg "whereupon the \"Close Display\" button will re-appear\n"
	append msg "in the \"Display\" window.\n"
	append msg "\n"
	append msg "\"Replace Display\" :\n"
	append msg "The Display window Remembers which file you are displaying.\n"
	append msg "If (after the window has been closed) you hit \"Display\" again\n"
	append msg "the Remembered File is displayed.\n"
	append msg "\n"
	append msg "To display a Different File, use \"Replace Display\".\n"
	append msg "This causes the Display to Forget the Remembered file.\n"
	append msg "On calling \"Display\" again, a new textfile will be displayed\n"
	append msg "(provided you've selected such a file on the Workspace)."
	append msg "\n"

	Inf $msg
}

proc MultiRotate {} {
	global wl chlist pa wstk evv prg_dun prg_abortd simple_program_messages CDPidrun pr_multrot multrot mrotpatches
	global maxsamp_line done_maxsamp CDPmaxId

	set files_found 0
	if {[info exists chlist] && ([llength $chlist] > 1)} {
		set files_found 1
		foreach fnam $chlist {
			if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) != 1)} {
				set files_found 0
				break
			}
		}
		if {$files_found} {
			set multrot(fnams) $chlist
		}
	}
	if {!$files_found} {
		set ilist [$wl curselection]
		if {[info exists ilist] && ([llength $ilist] > 1)} {
			set files_found 1
			foreach i $ilist {
				set fnam [$wl get $i]
				if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) != 1)} {
					set files_found 0
					break
				}
				lappend fnams $fnam
			}
			if {$files_found} {
				set multrot(fnams) $fnams
			}
		}
	}
	if {!$files_found} {
		Inf "Select two or more mono soundfiles"
		return
	}
	set f .multrot
	if [Dlg_Create $f "MULTIPLE ROTATION (IN 8 CHANS)" "set pr_multrot 0" -width 80 -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.q -text "Abandon"		-command "set pr_multrot 0" -highlightbackground [option get . background {}]
		button $f.0.s -text "Do Rotations"	-command "set pr_multrot 1" -highlightbackground [option get . background {}]
		button $f.0.sv -text "Save Patch"	-command "set pr_multrot 2" -highlightbackground [option get . background {}]
		pack $f.0.s $f.0.sv -side left -padx 2
		pack $f.0.q -side right
		pack $f.0 -side top -fill x -expand true
		set n 1
		foreach fnam $multrot(fnams) {
			frame $f.$n
			label $f.$n.nam -text "[file rootname [file tail $fnam]] : " -width 20
			label $f.$n.stt -text "Start Channel"
			entry $f.$n.est -textvariable multrot(stt,$n) -width 2
			label $f.$n.spd -text "Cycles per sec"
			entry $f.$n.esp -textvariable multrot(spd,$n) -width 8
			checkbutton $f.$n.anti -variable multrot(anti,$n) -text "Anticlockwise"
			pack $f.$n.nam $f.$n.stt $f.$n.est $f.$n.spd $f.$n.esp $f.$n.anti -side left
			pack $f.$n -side top -fill x -expand true
			incr n
		}
		set fcnt $n
		frame $f.$n
		label $f.$n.nam -text "Outfile Name"
		entry $f.$n.onm -textvariable multrot(ofnam) -width 20
		pack $f.$n.nam $f.$n.onm -side left -padx 2
		pack $f.$n -side top -fill x -expand true
		wm resizable $f 0 0
		set k 0
		set n 1
		set m 2
		foreach fnam $multrot(fnams) {
			bind $f.$n.est <Down> "focus $f.$n.esp" 
			if {$m == $fcnt} {
				bind $f.$n.est <Down> "focus $f.$m.onm" 
				bind $f.$n.esp <Down> "focus $f.$m.onm" 
			} else {
				bind $f.$n.est <Down> "focus $f.$m.est" 
				bind $f.$n.esp <Down> "focus $f.$m.esp" 
			}
			bind $f.$n.est <Right> "focus $f.$n.esp" 
			bind $f.$n.esp <Left>  "focus $f.$n.est" 
			if {$k == 0} {
				bind $f.$n.est <Up> "focus $f.$fcnt.onm" 
				bind $f.$n.esp <Up> "focus $f.$fcnt.onm" 
			} else {
				bind $f.$n.est <Up> "focus $f.$k.est"
				bind $f.$n.esp <Up> "focus $f.$k.esp"
			}
			incr k
			incr n
			incr m
		}
		set k [expr $fcnt - 1]
		bind $f.$fcnt.onm <Down> "focus $f.1.est" 
		bind $f.$fcnt.onm <Up>   "focus $f.$k.est" 
		bind $f <Escape> {set pr_multrot 0}
		bind $f <Return> {set pr_multrot 1}
	}
	foreach fnam $multrot(fnams) {
		set rotfile [file rootname [file tail $fnam]]
		append rotfile "_rot" $evv(SNDFILE_EXT)
		if {[file exists $rotfile]} {
			Inf "File $rotfile already exists : please rename or remove before proceeding"
			return
		}
		lappend rotfiles $rotfile
	}

	set pr_multrot 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_multrot $f.1.est
	while {!$finished} {
		tkwait variable pr_multrot
		switch -- $pr_multrot  {
			1 -
			2 {
				set n 1
				set OK 1
				set patch {}
				foreach fnam $multrot(fnams) {
					if {([string length $multrot(stt,$n)] <= 0) || ![regexp {^[0-9]+$} $multrot(stt,$n)] || ($multrot(stt,$n) < 1) || ($multrot(stt,$n) > 8)} {
						Inf "Invalid start channel for file [file rootname [file tail $fnam]] (range 1 to 8)"
						set OK 0
						break
					}
					if {([string length $multrot(spd,$n)] <= 0) || ![IsNumeric $multrot(spd,$n)] || ($multrot(spd,$n) < 0.0) || ($multrot(spd,$n) > 64)} {
						Inf "Invalid rotation speed for file [file rootname [file tail $fnam]] (range 0 to 64)"
						set OK 0
						break
					}
					incr n
				}
				if {!$OK} {
					continue
				}
				if {[string length $multrot(ofnam)] <= 0} {
					Inf "No output filename entered"
					continue
				}
				if {![ValidCDPRootname $multrot(ofnam)]} {
					continue
				}
				set ofnam [string tolower $multrot(ofnam)]
				if {$pr_multrot == 2}  {
					if {[info exists mrotpatches]} {
						set k 0
						foreach mrotpatch $mrotpatches {
							set pnam [lindex $mrotpatch 0]
							if {[string match $pnam $ofnam]} {
								set msg "Patch $ofnam already exists : overwrite it ??"
								set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
								if {$choice == "no"} {
									set OK 0
									break
								} else {
									set mrotpatches [lreplace $mrotpatches $k $k]
									if {[llength $mrotpatches] <= 0} {
										unset mrotpatches
										break
									}
								}
							}
							incr k
						}
						if {!$OK} {
							continue
						}
					}
					set mrotpatch $ofnam
					set n 1
					foreach fnam $multrot(fnams) {
						lappend mrotpatch $multrot(stt,$n) $multrot(spd,$n)  $multrot(anti,$n) 
						incr n
					}
					if {[SaveRotpatch $mrotpatch]} {
						lappend mrotpatches $mrotpatch
					}
					continue
				}
				set mfnam $ofnam
				append ofnam $evv(SNDFILE_EXT)
				append mfnam [GetTextfileExtension mmx]
				if {[file exists $ofnam]} {
					Inf "A file with the name $ofnam already exists : please remove or rename"
					continue
				}
				if {[file exists $mfnam]} {
					Inf "A file with the name $mfnam already exists : please remove or rename"
					continue
				}
				Block "ROTATING THE FILE"
				set rotfile [lindex $rotfiles 0]
				set n 1
				catch {unset mixlines}
				foreach fnam $multrot(fnams) {
					set basfnam [file rootname [file tail $fnam]]
					wm title .blocker "PLEASE WAIT:        ROTATING FILE $basfnam"
					set cmd [file join $evv(CDPROGRAM_DIR) mchanpan]
					lappend cmd mchanpan 9 $fnam $rotfile 8 $multrot(stt,$n) $multrot(spd,$n) 1
					if {$multrot(anti,$n)} {
						lappend cmd -a
					}
					catch {unset simple_program_messages}
					set CDPidrun 0
					set prg_dun 0
					set prg_abortd 0
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "Can't run process to rotate file $basfnam : $CDPidrun"
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
						Inf "Failed to rotate file $basfnam"
						set OK 0
						break
					}
					if {![file exists $rotfile]} {
						Inf "No rotated file created from $basfnam"
						set OK 0
						break
					}
					FileToWkspace $rotfile 0 0 0 0 1
					set rotfile [lindex $rotfiles $n]
					incr n
				}
				if {!$OK} {
					UnBlock
					continue
				}
				set line [list 8]
				lappend lines $line
				foreach rotfile $rotfiles {
					set line [list $rotfile 0.0 8 1:1 1 2:2 1 3:3 1 4:4 1 5:5 1 6:6 1 7:7 1 8:8 1]
					lappend lines $line
				}
				if [catch {open $mfnam "w"} zit] {
					Inf "Cannot open file $mfnam to write the mixing data"
					UnBlock
					continue
				}
				foreach line $lines {
					puts $zit $line
				}
				close $zit
				set maxsampOK 0
				while {$OK} {
					wm title .blocker "PLEASE WAIT:        MIXING ROTATED FILES"
					set cmd [file join $evv(CDPROGRAM_DIR) newmix]
					lappend cmd multichan $mfnam $ofnam
					catch {unset simple_program_messages}
					set CDPidrun 0
					set prg_dun 0
					set prg_abortd 0
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "Can't run mix process to mix rotated files : $CDPidrun"
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
						Inf "Failed to mix rotated files"
						set OK 0
						break
					}
					if {![file exists $ofnam]} {
						Inf "No rotated files mix created"
						set OK 0
						break
					}
					set done 0				
					while {!$done} {
						wm title .blocker "PLEASE WAIT:        CHECKING LEVEL"
						set cmd2 [file join $evv(CDPROGRAM_DIR) maxsamp2]
						catch {unset maxsamp_line}
						set done_maxsamp 0
						lappend cmd2 $ofnam
						if [catch {open "|$cmd2"} CDPmaxId] {
							Inf "Failed to find maximum level of output: outfile could be distorted"
							set done 1
							break
						}
						fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
						vwait done_maxsamp
						if {![info exists maxsamp_line]} {
							Inf "Cannot retrieve maximum level information: outfile could be distorted"
							set done 1
							break
						}
						set maxoutsamp [lindex $maxsamp_line 0]
						if {$maxoutsamp <= 0.95} {
							set done 1
							break
						}
						if [catch {file delete $ofnam} zit] {
							Inf "CANNOT DELETE THE DISTORTED OUTPUT FILE"
							break
						}
						wm title .blocker "PLEASE WAIT:        RECREATING MIX TO ASSESS BEST LEVEL"
						lappend cmd -g0.1
						set prg_dun 0
						set prg_abortd 0
						catch {unset simple_program_messages}
						if [catch {open "|$cmd"} CDPidrun] {
							catch {unset CDPidrun}
							ErrShow "CANNOT DO REMIX OF SOUNDS: $CDPidrun"
							catch {file delete $ofnam}
							break
						} else {
							fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
						}
						vwait prg_dun
						if {$prg_abortd} {
							set prg_dun 0
						}
						if {!$prg_dun} {
							set msg "Failed to remix sounds:"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							catch {file delete $ofnam}
							break
						}
						if {![file exists $ofnam]} {
							set msg "Failed to generate new output sound:"
							set msg [Addsimplemessages $msg]
							ErrShow $msg
							catch {file delete $ofnam}
							break
						}
						wm title .blocker "PLEASE WAIT:        2ND LEVEL CHECK"
						catch {unset maxsamp_line}
						set done_maxsamp 0
						if [catch {open "|$cmd2"} CDPmaxId] {
							Inf "Failed to find max level on second check"
							break
						}
						fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
						vwait done_maxsamp
						if {![info exists maxsamp_line]} {
							Inf "Cannot retrieve max level of attenuated mix"
							break
						}
						set maxoutsamp [lindex $maxsamp_line 0]
						set nulevel [expr 0.1 * 0.95/$maxoutsamp]
						set cmd [lreplace $cmd end end -g$nulevel]
						if [catch {file delete $ofnam} zit] {
							Inf "Cannot delete the test output file, to do final mix"
							break
						}
						wm title .blocker "PLEASE WAIT:        FINAL REMIX"
						set prg_dun 0
						set prg_abortd 0
						catch {unset simple_program_messages}
						if [catch {open "|$cmd"} CDPidrun] {
							catch {unset CDPidrun}
							ErrShow "CANNOT DO FINAL REMIX OF SOUNDS: $CDPidrun"
							catch {file delete $ofnam}
							break
						} else {
							fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
						}
						vwait prg_dun
						if {$prg_abortd} {
							set prg_dun 0
						}
						if {!$prg_dun} {
							set msg "Failed to do final remix of sounds:"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							catch {file delete $ofnam}
							break
						}
						if {![file exists $ofnam]} {
							set msg "Failed to generate final output sound:"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							catch {file delete $ofnam}
							break
						}
						set done 1
					}
					if {!$done} {
						set OK 0
					}
					break
				}
				if {!$OK} {
					UnBlock
					continue
				}
				FileToWkspace $mfnam 0 0 0 0 1
				FileToWkspace $ofnam 0 0 0 0 1
				if {![MixMUpdate $mfnam 1]} {
					Inf "Failed to update mix management information"
				}
				Inf "Output files are on the workspace"
				UnBlock
				set finished 1
			} 0 {
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

proc CycConcat {} {
	global wl chlist pa wstk evv prg_dun prg_abortd simple_program_messages CDPidrun pr_cycconc cycconc
	set files_found 0
	if {[info exists chlist] && ([llength $chlist] > 1)} {
		set files_found 1
		set inchans $pa([lindex $chlist 0],$evv(CHANS))
		foreach fnam $chlist {
			if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) != $inchans) || ($pa($fnam,$evv(DUR)) <= 0.03)} {
				set files_found 0
				break
			}
		}
		if {$files_found} {
			set cycconc(fnams) $chlist
		}
	}
	if {!$files_found} {
		set ilist [$wl curselection]
		if {[info exists ilist] && ([llength $ilist] > 1)} {
			set inchans $pa([$wl get [lindex $ilist 0]],$evv(CHANS))
			set files_found 1
			foreach i $ilist {
				set fnam [$wl get $i]
				if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) != $inchans) || ($pa($fnam,$evv(DUR)) <= 0.03)} {
					set files_found 0
					break
				}
				lappend fnams $fnam
			}
			if {$files_found} {
				set cycconc(fnams) $fnams
			}
		}
	}
	if {!$files_found} {
		Inf "Select two or more soundfiles with same number of channels & all longer than 0.03 seconds"
		return
	}
	set fcnt [llength $cycconc(fnams)]
	set f .cycconc
	if [Dlg_Create $f "CYCLICALLY CONCATENATE" "set pr_cycconc 0" -width 80 -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.q -text "Abandon"		-command "set pr_cycconc 0" -highlightbackground [option get . background {}]
		button $f.0.s -text "Concatenate"	-command "set pr_cycconc 1" -highlightbackground [option get . background {}]
		pack $f.0.s -side left
		pack $f.0.q -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.nam -text "Generic Outfilename"
		entry $f.1.onm -textvariable cycconc(ofnam) -width 20
		pack $f.1.nam $f.1.onm -side left -padx 2
		pack $f.1 -side top -fill x -expand true
		wm resizable $f 0 0
		bind $f <Escape> {set pr_cycconc 0}
		bind $f <Return> {set pr_cycconc 1}
	}
	set pr_cycconc 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_cycconc $f.1.nam
	while {!$finished} {
		tkwait variable pr_cycconc
		switch -- $pr_cycconc  {
			1 {
				if {[string length $cycconc(ofnam)] <= 0} {
					Inf "No output filename entered"
					continue
				}
				if {![ValidCDPRootname $cycconc(ofnam)]} {
					continue
				}
				set ofnam [string tolower $cycconc(ofnam)]
				set OK 1
				set n 1
				catch {unset ofnams}
				foreach fnam $cycconc(fnams) {
					set thisofnam $ofnam
					append thisofnam "_$n" $evv(SNDFILE_EXT)
					if {[file exists $thisofnam]} {
						Inf "File $thisofnam exists : please choose a different generic name"
						set OK 0
						break
					}
					lappend ofnams $thisofnam
					incr n
				}
				if {!$OK} {
					continue
				}
				Block "DOING CONCATENATE"
				set n 0
				set m 1
				set cyclist $cycconc(fnams)
				while {$n < $fcnt} {
					wm title .blocker "PLEASE WAIT:        DOING CONCATENATION $m"
					set ofnam [lindex $ofnams $n]
					set cmd [file join $evv(CDPROGRAM_DIR) sfedit]
					lappend cmd join
					set cmd [concat $cmd $cyclist]
					lappend cmd $ofnam
					catch {unset simple_program_messages}
					set CDPidrun 0
					set prg_dun 0
					set prg_abortd 0
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "Can't run concatenation $m : $CDPidrun"
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
						Inf "Failed to do concatenation $m"
						set OK 0
						break
					}
					if {![file exists $ofnam]} {
						Inf "No concatenated file $ofnam created"
						set OK 0
						break
					}
					FileToWkspace $ofnam 0 0 0 0 1
					set cyclist [NuRotateList $cyclist]
					incr n
					incr m
				}
				if {!$OK} {
					UnBlock
					continue
				}
				Inf "Output files are on the workspace"
				UnBlock
				set finished 1
			} 0 {
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

proc NuRotateList {thislist} {
	set k [llength $thislist]
	lappend newlist [lindex $thislist end]
	incr k -1
	set n 0
	while {$n < $k} {
		lappend newlist [lindex $thislist $n]
		incr n
	}
	return $newlist
}


proc CycConcatHelp {} {
	set msg "Cyclically Concatenate\n"
	append msg "\n"
	append msg "Takes a list of soundfiles\n"
	append msg "(all soundfiles having same number of channels).\n"
	append msg "\n"
	append msg "Let these be the 5 files    A   B   C   D   &   E\n"
	append msg "\n"
	append msg "Join them to produce 5 different joined-up-files ...\n"
	append msg "\n"
	append msg "A-B-C-D-E\n"
	append msg "E-A-B-C-D\n"
	append msg "D-E-A-B-C\n"
	append msg "C-D-E-A-B\n"
	append msg "B-C-D-E-A\n"
	append msg "\n"
	Inf $msg
}	

proc SaveRotpatch {mrotpatch} {
	global evv
	set fnam [file join $evv(URES_DIR) mrotpatches$evv(CDP_EXT)]
	if {[file exists $fnam]} {
		if [catch {open $fnam "a"} zit] {
			Inf "Cannot open existing rotation patches file $fnam to append new patch"
			return 0
		}
	} else {
		if [catch {open $fnam "w"} zit] {
			Inf "Cannot open file $fnam to save patch"
			return 0
		}
	}
	puts $zit $mrotpatch
	close $zit
	Inf "Patch [lindex $mrotpatch 0] saved"
	return 1
}

proc LoadRotpatches {} {
	global mrotpatches evv
	set fnam [file join $evv(URES_DIR) mrotpatches$evv(CDP_EXT)]
	if {![file exists $fnam]} {
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot open rotation patches file $fnam to read patches"
		return
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		set line [split $line]
		set cnt 0
		set patch {}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			lappend patch $item
			incr cnt
		}
		if {[llength $patch] <= 0} {
			continue
		}
		incr cnt -1
		set q [expr $cnt/3]
		set q [expr $q * 3]
		if {$q != $cnt} {
			Inf "Bad rotation patch [lindex $patch 0] found in rotation patches file $fnam"
			continue
		}
		lappend mrotpatches $patch
	}
	close $zit
}

#--- Remix stereo file so it is revealed from mono and remerges to mono

proc StereoReveal {} {
	global wl chlist pa wstk evv prg_dun prg_abortd simple_program_messages CDPidrun pr_streveal streveal
	global maxsamp_line done_maxsamp CDPmaxId

	set files_found 0
	if {[info exists chlist] && ([llength $chlist] == 1)} {
		set files_found 1
		set fnam [lindex $chlist 0]
		if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) != 2)} {
			set files_found 0
		}
		if {$files_found} {
			set streveal(fnam) $fnam
		}
	}
	if {!$files_found} {
		set i [$wl curselection]
		if {[info exists i] && ([llength $i] == 1) && ($i != -1)} {
			set files_found 1
			set fnam [$wl get $i]
			if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) != 2)} {
				set files_found 0
			}
			if {$files_found} {
				set streveal(fnam) $fnam
			}
		}
	}
	if {!$files_found} {
		Inf "Select a stereo soundfile"
		return
	}
	set streveal(fnam) $fnam
	set f .streveal
	if [Dlg_Create $f "STEREO REVEAL" "set pr_streveal 0" -width 80 -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.s -text "Do Reveal"	 -command "set pr_streveal 1" -highlightbackground [option get . background {}]
		button $f.0.sv -text "Sound View" -command "SnackDisplay $evv(SN_TIMESLIST) reveal $evv(TIME_OUT) 0" -bg $evv(SNCOLOR) -highlightbackground [option get . background {}]
		button $f.0.h -text "Help" -command "HelpReveal" -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.0.q -text "Abandon"	 -command "set pr_streveal 0" -highlightbackground [option get . background {}]
		pack $f.0.s $f.0.h $f.0.sv -side left -padx 2
		pack $f.0.q -side right
		frame $f.1
		label $f.1.ll -text "Start of reveal" -width 15
		entry $f.1.stt -textvariable streveal(stt) -width 20
		pack $f.1.ll $f.1.stt -side left -padx 2
		frame $f.2
		label $f.2.ll -text "End of reveal" -width 15
		entry $f.2.stt -textvariable streveal(end) -width 20
		pack $f.2.ll $f.2.stt -side left -padx 2
		frame $f.3
		label $f.3.ll -text "Start of merge" -width 15
		entry $f.3.stt -textvariable streveal(mstt) -width 20
		pack $f.3.ll $f.3.stt -side left -padx 2
		frame $f.4
		label $f.4.ll -text "End of merge" -width 15
		entry $f.4.stt -textvariable streveal(mend) -width 20
		pack $f.4.ll $f.4.stt -side left -padx 2
		frame $f.5
		label $f.5.ll -text "Pan prescale" -width 15
		entry $f.5.stt -textvariable streveal(prescale) -width 20
		pack $f.5.ll $f.5.stt -side left -padx 2
		frame $f.6
		label $f.6.ll -text "Reveal from  "
		radiobutton $f.6.rl -variable streveal(frmright) -text "Left" -value 0
		radiobutton $f.6.rr -variable streveal(frmright) -text "Right" -value 1
		label $f.6.ll2 -text "Merge to  "
		radiobutton $f.6.mr -variable streveal(toleft) -text "Left" -value 1
		radiobutton $f.6.ml -variable streveal(toleft) -text "Right" -value 0
		pack $f.6.ll $f.6.rl $f.6.rr $f.6.ll2 $f.6.mr $f.6.ml -side left -padx 2
		frame $f.7
		label $f.7.nam -text "Outfilename"
		entry $f.7.onm -textvariable streveal(ofnam) -width 20
		pack $f.7.nam $f.7.onm -side left -padx 2
		pack $f.0 $f.1 $f.2 $f.3 $f.4 $f.5 $f.6 $f.7 -side top -fill x -expand true -pady 2
		wm resizable $f 0 0
		bind $f.1.stt <Down> "focus $f.2.stt"
		bind $f.2.stt <Down> "focus $f.3.stt"
		bind $f.3.stt <Down> "focus $f.4.stt"
		bind $f.4.stt <Down> "focus $f.5.stt"
		bind $f.5.stt <Down> "focus $f.7.onm"
		bind $f.7.onm <Down> "focus $f.1.stt"
		bind $f.1.stt <Up> "focus $f.7.onm"
		bind $f.2.stt <Up> "focus $f.1.stt"
		bind $f.3.stt <Up> "focus $f.2.stt"
		bind $f.4.stt <Up> "focus $f.3.stt"
		bind $f.5.stt <Up> "focus $f.4.stt"
		bind $f.7.onm <Up> "focus $f.5.stt"
		bind $f <Escape> {set pr_streveal 0}
		bind $f <Return> {set pr_streveal 1}
	}
	if {![info exists streveal(frmright)] || ($streveal(frmright) < 0) || ($streveal(frmright) > 1)} {
		set streveal(frmright) 0
	}
	if {![info exists streveal(toleft)] || ($streveal(toleft) < 0) || ($streveal(toleft) > 1)} {
		set streveal(toleft) 0
	}
	set dur $pa($fnam,$evv(DUR))
	set cfnam $evv(DFLT_OUTNAME) 
	append cfnam $evv(SNDFILE_EXT)
	set c1fnam $evv(DFLT_OUTNAME) 
	append c1fnam "_c1" $evv(SNDFILE_EXT)
	set c2fnam $evv(DFLT_OUTNAME) 
	append c2fnam "_c2" $evv(SNDFILE_EXT)
	set co1fnam $evv(DFLT_OUTNAME) 
	append co1fnam "1" $evv(SNDFILE_EXT)
	set co2fnam $evv(DFLT_OUTNAME) 
	append co2fnam "2" $evv(SNDFILE_EXT)
	set leftpanfile $evv(DFLT_OUTNAME) 
	append leftpanfile "1" $evv(TEXT_EXT)
	set rightpanfile $evv(DFLT_OUTNAME) 
	append rightpanfile "2" $evv(TEXT_EXT)
	set mfnam $evv(DFLT_OUTNAME) 
	append mfnam 3 [GetTextfileExtension mix]

	set pr_streveal 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_streveal $f.1.stt
	DeleteAllTemporaryFiles
	while {!$finished} {
		DeleteAllTemporaryFiles
		tkwait variable pr_streveal
		switch -- $pr_streveal  {
			1 {
				set OK 1
				if {[string length $streveal(ofnam)] <= 0} {
					Inf "No output filename entered"
					continue
				}
				if {![ValidCDPRootname $streveal(ofnam)]} {
					continue
				}
				set ofnam [string tolower $streveal(ofnam)]
				append ofnam $evv(SNDFILE_EXT)
				if {[file exists $ofnam]} {
					Inf "File $ofnam exists : please choose a different name"
					continue
				}
				if {([string length $streveal(stt)] < 0) || ![IsNumeric $streveal(stt)] || ($streveal(stt) >= $dur) || ($streveal(stt) < 0.0)} {
					Inf "Invalid time for Start of reveal (range 0 to $dur)"
					continue
				}
				if {([string length $streveal(end)] < 0) || ![IsNumeric $streveal(end)] || ($streveal(end) < $streveal(stt)) || ($streveal(end) > $dur)} {
					Inf "Invalid time for End of reveal (range $streveal(stt) to $dur)"
					continue
				}
				if {([string length $streveal(mstt)] < 0) || ![IsNumeric $streveal(mstt)] || ($streveal(mstt) < $streveal(end)) || ($streveal(mstt) > $dur)} {
					Inf "Invalid time for Start of merge (range $streveal(end) to $dur)"
					continue
				}
				if {([string length $streveal(mend)] < 0) || ![IsNumeric $streveal(mend)] || ($streveal(mend) < $streveal(mstt)) || ($streveal(mend) > $dur)} {
					Inf "Invalid time for End of merge (range $streveal(mstt) to $dur)"
					continue
				}
				if {[string length $streveal(prescale)] < 0} {
					set streveal(prescale) 1.0
				} elseif {![IsNumeric $streveal(prescale)] || ($streveal(prescale) < 0.1) || ($streveal(prescale) > 1.0)} {
					Inf "Invalid pan prescale (range 0.1 to 1)"
					continue
				}
				set reveal_from -1
				if {$streveal(frmright)} {
					set reveal_from 1
				}
				set merge_to 1
				if {$streveal(toleft)} {
					set merge_to -1
				}
				Block "DOING REVEAL"

				wm title .blocker "PLEASE WAIT:        WRITING PANNING DATA FILES"

				set panlist_left {}
				set panlist_right {}
				if {$streveal(end) > 0.0} {
					if {$streveal(stt) > 0.0} {									
						lappend panlist_left  [list 0.0 $reveal_from]			;#	IF reveal starts after zero, put in zero pan position
						lappend panlist_right [list 0.0 $reveal_from]	
					}
					lappend panlist_left  [list $streveal(stt) $reveal_from]	;#	Put in pan positions at reveal start
					lappend panlist_right [list $streveal(stt) $reveal_from]
				}	
				lappend panlist_left [list $streveal(end) -1]					;#	Put in pan positions at reveal end
				lappend panlist_right [list $streveal(end) 1]

				if {$streveal(mstt) < $dur} {
					lappend panlist_left  [list $streveal(mstt) -1]				;#	Put in pan positions at merge start
					lappend panlist_right [list $streveal(mstt) 1]				
					lappend panlist_left  [list $streveal(mend) $merge_to]		;#	Put in pan positions at merge end
					lappend panlist_right [list $streveal(mend) $merge_to]
				}
				set lastpan  [lindex $panlist_left end]
				set lastime  [lindex $lastpan 0]
				if {$lastime < $dur} {
					set lastime [expr $dur + 10.0]
					set lastpos [lindex $lastpan 1]
					set lastline [list $lastime $lastpos]
					lappend panlist_left $lastline
					set lastpos [lindex [lindex $panlist_right end] 1]
					set lastline [list $lastime $lastpos]
					lappend panlist_right $lastline
				}
				if [catch {open $leftpanfile "w"} zit] {
					Inf "Cannot open left-panning data file $leftpanfile : $zit"
					UnBlock
					continue
				}
				foreach line $panlist_left {
					puts $zit $line
				}
				close $zit
				if [catch {open $rightpanfile "w"} zit] {
					Inf "Cannot open right-panning data file $rightpanfile : $zit"
					UnBlock
					continue
				}
				foreach line $panlist_right {
					puts $zit $line
				}
				close $zit
				catch {unset lines}
				set line [list $co1fnam 0.0 2 1]
				lappend lines $line
				set line [list $co2fnam 0.0 2 1]
				lappend lines $line
				if [catch {open $mfnam "w"} zit] {
					Inf "Cannot open temporary mixfile $mfnam to write final mix data"
					UnBlock
					continue
				}
				foreach line $lines {
					puts $zit $line
				}
				close $zit

				wm title .blocker "PLEASE WAIT:        COPYING THE INPUT FILE"

				set cmd [file join $evv(CDPROGRAM_DIR) housekeep]
				lappend cmd copy 1 $fnam $cfnam
				catch {unset simple_program_messages}
				set CDPidrun 0
				set prg_dun 0
				set prg_abortd 0
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "Can't copy input file : $CDPidrun"
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
					Inf "Failed to copy input file"
					UnBlock
					continue
				}
				if {![file exists $cfnam]} {
					Inf "No copy of input file created"
					UnBlock
					continue
				}
				wm title .blocker "PLEASE WAIT:        EXTRACTING CHANNELS"

				set cmd [file join $evv(CDPROGRAM_DIR) housekeep]
				lappend cmd chans 2 $cfnam
				catch {unset simple_program_messages}
				set CDPidrun 0
				set prg_dun 0
				set prg_abortd 0
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "Can't extract channels of input file : $CDPidrun"
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
					Inf "Failed to extract channels of input file"
					UnBlock
					continue
				}
				if {![file exists $c1fnam]} {
					Inf "No extracted channel 1 of input file created"
					UnBlock
					continue
				}
				if {![file exists $c2fnam]} {
					Inf "No extracted channel 2 of input file created"
					UnBlock
					continue
				}

				wm title .blocker "PLEASE WAIT:        REPANNING LEFT CHANNEL"

				set cmd [file join $evv(CDPROGRAM_DIR) modify]
				lappend cmd space 1 $c1fnam $co1fnam $leftpanfile 
				if {$streveal(prescale) < 1.0} {
					lappend cmd $streveal(prescale)
				}
				catch {unset simple_program_messages}
				set CDPidrun 0
				set prg_dun 0
				set prg_abortd 0
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "Can't re-pan the left channel of the input file : $CDPidrun"
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
					Inf "Failed to re-pan the left channel of the input file"
					UnBlock
					continue
				}
				if {![file exists $co1fnam]} {
					Inf "No re-panned left channel of the input file created"
					UnBlock
					continue
				}

				wm title .blocker "PLEASE WAIT:        REPANNING RIGHT CHANNEL"

				set cmd [file join $evv(CDPROGRAM_DIR) modify]
				lappend cmd space 1 $c2fnam $co2fnam $rightpanfile 
				if {$streveal(prescale) < 1.0} {
					lappend cmd $streveal(prescale)
				}
				catch {unset simple_program_messages}
				set CDPidrun 0
				set prg_dun 0
				set prg_abortd 0
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "Can't re-pan the right channel of the input file : $CDPidrun"
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
					Inf "Failed to re-pan the right channel of the input file"
					UnBlock
					continue
				}
				if {![file exists $co2fnam]} {
					Inf "No re-panned right channel of the input file created"
					UnBlock
					continue
				}
				while {$OK} {
					wm title .blocker "PLEASE WAIT:        MIXING RE-PANNED FILES"
					set cmd [file join $evv(CDPROGRAM_DIR) submix]
					lappend cmd mix $mfnam $ofnam
					catch {unset simple_program_messages}
					set CDPidrun 0
					set prg_dun 0
					set prg_abortd 0
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "Can't run mix process to mix re-panned files : $CDPidrun"
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
						Inf "Failed to mix re-panned files"
						set OK 0
						break
					}
					if {![file exists $ofnam]} {
						Inf "No re-panned files mix created"
						set OK 0
						break
					}
					set done 0				
					while {!$done} {
						wm title .blocker "PLEASE WAIT:        CHECKING LEVEL"
						set cmd2 [file join $evv(CDPROGRAM_DIR) maxsamp2]
						catch {unset maxsamp_line}
						set done_maxsamp 0
						lappend cmd2 $ofnam
						if [catch {open "|$cmd2"} CDPmaxId] {
							Inf "Failed to find maximum level of output: outfile could be distorted"
							set done 1
							break
						}
						fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
						vwait done_maxsamp
						if {![info exists maxsamp_line]} {
							Inf "Cannot retrieve maximum level information: outfile could be distorted"
							set done 1
							break
						}
						set maxoutsamp [lindex $maxsamp_line 0]
						if {$maxoutsamp <= 0.95} {
							set done 1
							break
						}
						if [catch {file delete $ofnam} zit] {
							Inf "Cannot delete the distorted output file"
							break
						}
						wm title .blocker "PLEASE WAIT:        RECREATING MIX TO ASSESS BEST LEVEL"
						lappend cmd -g0.1
						set prg_dun 0
						set prg_abortd 0
						catch {unset simple_program_messages}
						if [catch {open "|$cmd"} CDPidrun] {
							catch {unset CDPidrun}
							ErrShow "Cannot do remix of sounds: $CDPidrun"
							catch {file delete $ofnam}
							break
						} else {
							fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
						}
						vwait prg_dun
						if {$prg_abortd} {
							set prg_dun 0
						}
						if {!$prg_dun} {
							set msg "Failed to remix sounds:"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							catch {file delete $ofnam}
							break
						}
						if {![file exists $ofnam]} {
							set msg "Failed to generate new output sound:"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							catch {file delete $ofnam}
							break
						}
						wm title .blocker "PLEASE WAIT:        2ND LEVEL CHECK"
						catch {unset maxsamp_line}
						set done_maxsamp 0
						if [catch {open "|$cmd2"} CDPmaxId] {
							Inf "Failed to find max level on second check"
							break
						}
						fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
						vwait done_maxsamp
						if {![info exists maxsamp_line]} {
							Inf "Cannot retrieve max level of attenuated mix"
							break
						}
						set maxoutsamp [lindex $maxsamp_line 0]
						set nulevel [expr 0.1 * 0.95/$maxoutsamp]
						set cmd [lreplace $cmd end end -g$nulevel]
						if [catch {file delete $ofnam} zit] {
							Inf "Cannot delete the test output file, to do final mix"
							break
						}
						wm title .blocker "PLEASE WAIT:        FINAL REMIX"
						set prg_dun 0
						set prg_abortd 0
						catch {unset simple_program_messages}
						if [catch {open "|$cmd"} CDPidrun] {
							catch {unset CDPidrun}
							ErrShow "Cannot do final remix of sounds: $CDPidrun"
							catch {file delete $ofnam}
							break
						} else {
							fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
						}
						vwait prg_dun
						if {$prg_abortd} {
							set prg_dun 0
						}
						if {!$prg_dun} {
							set msg "Failed to do final remix of sounds:"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							catch {file delete $ofnam}
							break
						}
						if {![file exists $ofnam]} {
							set msg "Failed to generate final output sound:"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							catch {file delete $ofnam}
							break
						}
						set done 1
					}
					if {!$done} {
						set OK 0
					}
					break
				}
				if {!$OK} {
					UnBlock
					continue
				}
				FileToWkspace $ofnam 0 0 0 0 1
				Inf "Output file is on the workspace"
				UnBlock
				set finished 1
			} 0 {
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc HelpReveal {} {
	set msg "                              Stereo Reveal\n"
	append msg "\n"
	append msg "Cause stereo sound to emerge from a mono mix\n"
	append msg "(in one channel only), and/or merge to a mono mix\n"
	append msg "in the same or the other channel.\n"
	append msg "\n"
	append msg "Parameters .....\n"
	append msg "\n"
	append msg "Start of reveal\n"
	append msg "     Before this time, sound is mixed to mono in right or left channel.\n"
	append msg "\n"
	append msg "End of reveal\n"
	append msg "     By this time, sound has become fully stereo.\n"
	append msg "     You can start in stereo and simply do a merge-to-mono\n"
	append msg "     by setting \"END OF REVEAL\" to zero.\n"
	append msg "\n"
	append msg "Start of merge\n"
	append msg "     Before this time, sound is fully stereo.\n"
	append msg "     You can start in stereo and IMMEDIATELY merge-to-mono\n"
	append msg "     by setting \"START OF MERGE\" to zero.\n"
	append msg "\n"
	append msg "End of merge\n"
	append msg "     By this time, sound has fully merged to mono, in right or left channel.\n"
	append msg "\n"
	append msg "\n"
	append msg "The \"Sound View\" window can be used to graphically enter the above 4 times.\n"
	append msg "\n"
	append msg "\n"
	append msg "Pan prescale\n"
	append msg "     Possibly attenuate the input to avoid overload in the panned output.\n"
	append msg "\n"
	append msg "Reveal from Left/Right\n"
	append msg "     Stereo signal emerges from mono in either left or right channel.\n"
	append msg "\n"
	append msg "Merge to Left/Right\n"
	append msg "     Stereo signal merges to mono in either left or right channel.\n"
	append msg "\n"
	Inf $msg
}

