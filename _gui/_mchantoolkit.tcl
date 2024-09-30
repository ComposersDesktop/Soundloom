#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD 30 June 2013
# ... fixup button rectangles

#######################################
# RWD'S MULTICHANNEL TOOLKIT, ON LOOM #
#######################################

#---- Names for prog-running bar, for exceptional progs (not accessed from normal prg-array

proc MchanToolKitNames {prg} {
	global evv
	switch -regexp -- $prg \
		^$evv(ABFPAN)$ {
			set thistext "1st Order Ambisonic Pan"
		} \
		^$evv(ABFPAN2)$ {
			set thistext "2nd Order Ambisonic Pan"
		} \
		^$evv(ABFPAN2P)$ {
			set thistext "2nd Order Periphonic Pan"
		} \
		^$evv(CHANNELX)$ {
			set thistext "Extract All Chans from mchan file"
		} \
		^$evv(CHORDER)$ {
			set thistext "Reorder Soundfile Channels"
		} \
		^$evv(INTERLX)$ {
			set thistext "Interleave chans (various formats)"
		} \
		^$evv(CHXFORMAT)$ {
			set thistext "Change WAVEX lpkr position mask"
		} \
		^$evv(CHXFORMATM)$ {
			set thistext "See WAVEX lspkr position mask"
		} \
		^$evv(CHXFORMATG)$ {
			set thistext "Remove chan-position info"
		} \
		^$evv(COPYSFX)$ {
			set thistext "Copy/Convert Sndfile Format"
		} \
		^$evv(FMDCODE)$ {
			set thistext "Decode Ambisonic File"
		} \
		^$evv(NJOIN)$ {
			set thistext "Concatenate files (for CD)"
		} \
		^$evv(NJOINCH)$ {
			set thistext "File compatibility"
		} \
		^$evv(NMIX)$ {
			set thistext "Mix two (mchan) files"
		} \
		^$evv(RMSINFO)$ {
			set thistext "Get RMS level info"
		} \
		^$evv(SFEXPROPS)$ {
			set thistext "See props of WAVEX file"
		}

	return $thistext
}

#---- Program for mchantoolkit

proc GetMchanToolKitProgname {prg} {
	global evv
	switch -regexp -- $prg \
		^$evv(ABFPAN)$ {
			set progname "abfpan"
		} \
		^$evv(ABFPAN2)$ {
			set progname "abfpan2"
		} \
		^$evv(ABFPAN2P)$ {
			set progname "abfpan2"
		} \
		^$evv(CHANNELX)$ {
			set progname "channelx"
		} \
		^$evv(CHORDER)$ {
			set progname "chorder"
		} \
		^$evv(CHXFORMAT)$ {
			set progname "chxformat"
		} \
		^$evv(CHXFORMATM)$ {
			set progname "chxformat"
		} \
		^$evv(CHXFORMATG)$ {
			set progname "chxformat"
		} \
		^$evv(COPYSFX)$ {
			set progname "copysfx"
		} \
		^$evv(FMDCODE)$ {
			set progname "fmdcode"
		} \
		^$evv(INTERLX)$ {
			set progname "interlx"
		} \
		^$evv(NJOINCH)$ - \
		^$evv(NJOIN)$ {
			set progname "njoin"
		} \
		^$evv(NMIX)$ {
			set progname "nmix"
		} \
		^$evv(RMSINFO)$ {
			set progname "rmsinfo"
		} \
		^$evv(SFEXPROPS)$ {
			set progname "sfprops"
		}

	return $progname
}

#---- Program gives WAVEX Ambisonic Output

proc AmbisonicOut {prg} {
	global notwavexambisonic saved_cmd evv
	switch -regexp -- $prg \
		^$evv(ABFPAN)$ {
			if {[info exists notwavexambisonic]} {
				unset notwavexambisonic
			} else {
				return 1
			}
		} \
		^$evv(ABFPAN2)$ - \
		^$evv(ABFPAN2P)$ {
			if {[info exists notwavexambisonic]} {
				unset notwavexambisonic
			} else {
				return 1
			}
		} \
		^$evv(CHXFORMATG)$ {
			return 1
		} \
		^$evv(CHXFORMAT)$ {
			return 0
		} \
		^$evv(CHORDER)$ {
			if {[info exists notwavexambisonic]} {
				unset notwavexambisonic
			} else {
				return 1
			}
		} \
		^$evv(INTERLX)$ - \
		^$evv(COPYSFX)$ {
			if {[lsearch $saved_cmd "-t5"] > 0} {
				return 1
			}
		} \
		^$evv(NJOIN)$ {
			set len [llength $saved_cmd]
			incr len -2
			set infile [lindex $saved_cmd $len]
			if [catch {open $infile "r"} zit] {
				return 0
			}
			set returnval 0
			while {[gets $zit line] >= 0} {
				set line [string trim $line]
				if {[string length $line] <= 0} {
					continue
				}
				if {[string match [file extension $line] ".amb"]} {
					set returnval 1
				}
			}
			close $zit
			return $returnval
		} \
		^$evv(NMIX)$ {
			set len [llength $saved_cmd]
			incr len -3
			set returnval 0
			set n 0
			while {$n < 2} {
				set infile [lindex $saved_cmd $len]
				if {[string match [file extension $infile] ".amb"]} {
					set returnval 1
					break
				}
				incr len
				incr n
			}
			return $returnval
		}

	return 0
}

#------ Recognise Standalone Program for History Display

proc IsMchanToolkitProgname {str} {
	switch -- [file tail $str] {
		"abfpan"	{ return 1 }
		"abfpan2"	{ return 1 }
		"channelx"	{ return 1 }
		"chorder"	{ return 1 }
		"fmdcode"	{ return 1 }
		"chxformat"	{ return 1 }
		"interlx"	{ return 1 }
		"copysfx"	{ return 1 }
		"njoin"		{ return 1 }
		"njoin"		{ return 1 }
		"nmix"		{ return 1 }
		"rmsinfo"	{ return 1 }
		"sfprops"	{ return 1 }
	}
	return 0
}

#------ Recognise Standalone Program for History Display

proc HaveRunMchanToolkitProgWithOutputs {str} {
	global saved_cmd standopos
	if {![info exists standopos] || !$standopos} {
		return 0
	}
	set str [file rooname [file tail [lindex $saved_cmd 0]]]
	switch -- [file tail $str] {
		"abfpan"	{ return 1 }
		"abfpan2"	{ return 1 }
		"channelx"	{ return 1 }
		"chorder"	{ return 1 }
		"fmdcode"	{ return 1 }
		"chxformat"	{ return 1 }
		"interlx"	{ return 1 }
		"copysfx"	{ return 1 }
		"njoin"		{ return 1 }
		"nmix"		{ return 1 }
	}
	return 0
}

#---- Convert data in textfile from CDP form of CHANNELX to parameters on line, for cmdline version

proc ExtractChannelDataAndModifyCmdline {cmd} {
	global pa evv
	set fnam [lindex $cmd 1]
	set flagdval "-o"
	append flagdval [file rootname $fnam]
	set fnam [lindex $cmd 2]
	set inchan $pa($fnam,$evv(CHANS))
	set fnam [lindex $cmd 3]
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File '$fnam' To Read Output Channels"
		return ""
	}
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
				Inf "Invalid Data In File '$fnam'"
				return ""
			}
			if {($item < 1) || ($item > $inchan)} {
				Inf "Invalid Channel Number ($item) In File '$fnam' (Input file has only $inchans channels)"
				return ""
			}
			lappend outchans $item
		}
	}
	set outchans [RemoveDuplicatesInList $outchans]
	close $zit
	set cmd [concat [lrange $cmd 0 2] $outchans]
	set cmd [lreplace $cmd 1 1 $flagdval]
	return $cmd
}

#------- Is a prog from MchanToolkit

proc IsMchanToolkit {prg} {
	global evv
	if {($prg >= $evv(ABFPAN)) && ($prg <= $evv(ABFPAN2P))} {
		return 1
	}
	return 0
}

#----- Retrieve data on file extensions to use for ambisonic files

proc GetWavAmb {} {
	global wavambisonic_to_wxyz ambisonic_to_wav evv
	set fnam [file join $evv(URES_DIR) ambwxyz$evv(CDP_EXT)]
	if {[file exists $fnam]} {
		set wavambisonic_to_wxyz 1
	} else {
		set wavambisonic_to_wxyz 0
	}
	set fnam [file join $evv(URES_DIR) ambwav$evv(CDP_EXT)]
	if {[file exists $fnam]} {
		set ambisonic_to_wav 1
	} else {
		set ambisonic_to_wav 0
	}
}

#----- Allow user to choose if extension on standard wav sndfiles containing ambisonic data, is ".wav" or ".wxyz"

proc AmbWxyzExt {} {
	global wavambisonic_to_wxyz wstk evv
	set fnam [file join $evv(URES_DIR) ambwxyz$evv(CDP_EXT)]
	if {[file exists $fnam]} {
		set msg "Change File Extension For Standard Wavfiles Containing Ambisonic Data: To \"wav\" ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			set wavambisonic_to_wxyz 0
			if [catch {file delete $fnam} zit] {
				Inf "Cannot Destroy File 'fnam' To Remember, For Future Sessions, The Extension You're Using\n(Will Revert To '.wxyz')"
			}
		}
	} else {
		set msg "Change File Extension For Standard Wavfiles Containing Ambisonic Data: To \"wxyz\" ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			set wavambisonic_to_wxyz 1
			if [catch {open $fnam "w"} zit] {
				Inf "Cannot Create File 'fnam' To Remember, For Future Sessions, The Extension You're Using\n(Will Revert To '.wav')"
			} else {
				close $zit
			}
		}
	}
}

#----- Allow user to choose if extension on WAVEX ambisonic data, is ".wav" or ".amb"

proc AmbWavExt {} {
	global ambisonic_to_wav wstk evv
	set fnam [file join $evv(URES_DIR) ambwav$evv(CDP_EXT)]
	if {![file exists $fnam]} {
		set msg "Change File Extension For Wavex Containing Ambisonic Data: To \"wav\" ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			set ambisonic_to_wav 1
			if [catch {open $fnam "w"} zit] {
				Inf "Cannot Create File 'fnam' To Remember, For Future Sessions, The Extension You're Using\n(Will Revert To '.amb')"
			} else {
				close $zit
			}
		}
	} else {
		set msg "Change File Extension For Standard Wavfiles Containing Ambisonic Data: To \"amb\" ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			set ambisonic_to_wav 0
			if [catch {file delete $fnam} zit] {
				Inf "Cannot Destroy File 'fnam' To Remember, For Future Sessions, The Extension You're Using\n(Will Revert To '.wav')"
			}
		}
	}
}

###################
# REDUNDANT STUFF #
###################

proc Abfpan {} {
	global pr_abfpan evv abfpan_stt abfpan_rot abfpan_chans abfpan_ambi abfpan_wavx abfpan_fnam
	global prg_dun prg_abortd simple_program_messages pr2
	set fnam [CheckSelectedFile]
	if {[string length $fnam] <= 0} {
		return
	}
	set f .abfpan 
	if [Dlg_Create $f "1st ORDER AMBISONIC PAN" "set pr_abfpan 0" -borderwidth $evv(BBDR)] {
		frame $f.1		
		button $f.1.ok -text "Do" -command "set pr_abfpan 1" -highlightbackground [option get . background {}]
		button $f.1.about -text "About" -command CreditRWD -bg white -highlightbackground [option get . background {}]
		button $f.1.qq -text "Quit" -command "set pr_abfpan 0" -highlightbackground [option get . background {}]
		pack $f.1.ok $f.1.about -side left -padx 2
		pack $f.1.qq -side right
		pack $f.1 -side top -pady 2 -fill x -expand true
		frame $f.2		
		label $f.2.start -text "Start Position "
		entry $f.2.stt -textvariable abfpan_stt -width 4
		pack $f.2.start $f.2.stt -side left -padx 2
		pack $f.2 -side top -pady 2
		frame $f.3		
		label $f.3.end -text "Rotation	Count "
		entry $f.3.ee -textvariable abfpan_rot -width 4
		pack $f.3.end $f.3.ee -side left -padx 2
		pack $f.3 -side top -pady 2
		frame $f.4		
		label $f.4.num -text "No. of B-Format Output Channels"
		entry $f.4.no -textvariable abfpan_chans -width 4
		pack $f.4.num $f.4.no -side left -padx 2
		pack $f.4 -side top -pady 2
		frame $f.5
		checkbutton $f.5.b -variable abfpan_ambi -text "Horizontal B-Format output"
		checkbutton $f.5.x -variable abfpan_wavx -text "B-Format (WAVE_EX) output"
		pack $f.5.b $f.5.x -side left
		pack $f.5 -side top -pady 2
		frame $f.6
		label $f.6.nam -text "Outfile Name"
		entry $f.6.nn -textvariable abfpan_fnam -width 24
		pack $f.6.nam $f.6.nn -side left -padx 2
		pack $f.6 -side top -pady 2
		set abfpan_ambi 0
		set abfpan_wavx 0
		set abfpan_stt 0
		set abfpan_rot 1
		set abfpan_chans 4
		wm resizable .abfpan 1 1
		bind $f <Escape> {set pr_abfpan 0}
		bind $f <Return> {set pr_abfpan 1}
	}
	set abfpan_fnam ""
	raise $f
	set pr_abfpan 0
	set finished 0
	My_Grab 0 $f pr_abfpan $f.2.stt
	while {!$finished} {
		tkwait variable pr_abfpan
		if {$pr_abfpan} {
			if {([string length $abfpan_stt] <= 0) || ![IsNumeric $abfpan_stt] || ($abfpan_stt < 0.0) || ($abfpan_stt > 1.0)} {
				Inf "Invalid Start Position (Range 0 - 1)"
				continue
			}
			if {([string length $abfpan_rot] <= 0) || ![IsNumeric $abfpan_rot]} {
				Inf "Invalid Rotation Count (must be -ve or -ve number)"
				continue
			}
			if {([string length $abfpan_chans] <= 0) || ![regexp {^[3,4]$} $abfpan_chans]} {
				Inf "Invalid Number Of Output Channels (3 or 4 channels only)"
				continue
			}
			if {[string length $abfpan_fnam] <= 0} {
				Inf "No Output Filename Given"
				continue
			}
			set outfnam [string tolower $abfpan_fnam]
			if {![ValidCDPRootname $outfnam]} {
				continue
			}
			if {$abfpan_ambi || $abfpan_wavx} {
				append outfnam ".amb"
			} else {
				append outfnam $evv(SNDFILE_EXT)
			}
			if {[file exists $outfnam]} {
				Inf "File '$outfnam' Already Exists: Please Choose A Different Name"
				continue
			}
			set cmd [file join $evv(CDPROGRAM_DIR) abfpan]
			if {$abfpan_ambi} {
				lappend cmd -b
			}
			if {$abfpan_wavx} {
				lappend cmd -x
			}
			lappend cmd -o$abfpan_chans $fnam $outfnam $abfpan_stt $abfpan_rot
			catch {unset simple_program_messages}
			set prg_dun 0
			set prg_abortd 0
			if [catch {open "|$cmd"} CDPidrun] {
				ErrShow "FAILED TO RUN PROGRAM"
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
				set msg "Process Failed"
				set msg [AddSimpleMessages $msg]
				ErrShow $msg
				continue
			}
			if {![file exists $outfnam]} {
				Inf "Process Failed"
				continue
			}
			FileToWkspace $outfnam 0 0 0 0 1
			set msg "File '$outfnam' Is On The Workspace"
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc Abfpan2 {} {
	global pr_abfpan2 evv abfpan_stt abfpan_rot abfpan_gain abfpan_wav abfpan_peri abfpan_hite abfpan_fnam
	global prg_dun prg_abortd simple_program_messages
	set fnam [CheckSelectedFile]
	if {[string length $fnam] <= 0} {
		return
	}
	set f .abfpan2 
	if [Dlg_Create $f "2nd ORDER AMBISONIC PAN" "set pr_abfpan2 0" -borderwidth $evv(BBDR)] {
		frame $f.1
		button $f.1.ok -text "Do" -command "set pr_abfpan2 1" -highlightbackground [option get . background {}]
		button $f.1.about -text "About" -command CreditRWD -bg white -highlightbackground [option get . background {}]
		button $f.1.qq -text "Quit" -command "set pr_abfpan2 0" -highlightbackground [option get . background {}]
		pack $f.1.ok $f.1.about -side left -padx 2
		pack $f.1.qq -side right
		pack $f.1 -side top -pady 2 -fill x -expand true
		frame $f.2		
		label $f.2.start -text "Start Position "
		entry $f.2.stt -textvariable abfpan_stt -width 4
		pack $f.2.start $f.2.stt -side left -padx 2
		pack $f.2 -side top -pady 2
		frame $f.3		
		label $f.3.end -text "Rotation Count "
		entry $f.3.ee -textvariable abfpan_rot -width 4
		pack $f.3.end $f.3.ee -side left -padx 2
		pack $f.3 -side top -pady 2
		frame $f.4		
		label $f.4.gain -text "Input Gain"
		entry $f.4.gg -textvariable abfpan_gain -width 4
		pack $f.4.gain $f.4.gg -side left -padx 2
		pack $f.4 -side top -pady 2
		frame $f.5
		checkbutton $f.5.w -variable abfpan_wav -text "'.wav' output (Default B-Format)"
		pack $f.5.w -side left
		pack $f.5 -side top -pady 2
		frame $f.6
		checkbutton $f.6.w -variable abfpan_peri -text "9-chan Output (Dflt: 5 chan horizontal-only)"
		label $f.6.hite -text "Heigth (-180 to 180)"
		entry $f.6.hh -textvariable abfpan_hite -width 4
		pack $f.6.w $f.6.hite $f.6.hh -side left
		pack $f.6 -side top -pady 2
		frame $f.7
		label $f.7.nam -text "Outfile Name"
		entry $f.7.nn -textvariable abfpan_fnam -width 24
		pack $f.7.nam $f.7.nn -side left -padx 2
		pack $f.7 -side top -pady 2
		set abfpan_stt 0
		set abfpan_rot 1
		wm resizable .abfpan2 1 1
		bind $f <Escape> {set pr_abfpan2 0}
		bind $f <Return> {set pr_abfpan2 1}
	}
	set abfpan_gain 1.0
	set abfpan_peri 0
	set abfpan_hite ""
	set abfpan_wav 0
	set abfpan_fnam ""
	raise $f
	set pr_abfpan2 0
	set finished 0
	My_Grab 0 $f pr_abfpan2 $f.2.stt
	while {!$finished} {
		tkwait variable pr_abfpan2
		if {$pr_abfpan2} {
			if {([string length $abfpan_stt] <= 0) || ![IsNumeric $abfpan_stt] || ($abfpan_stt < 0.0) || ($abfpan_stt > 1.0)} {
				Inf "Invalid Start Position (Range 0 - 1)"
				continue
			}
			if {([string length $abfpan_rot] <= 0) || ![IsNumeric $abfpan_rot]} {
				Inf "Invalid Rotation Count (must be -ve or -ve number)"
				continue
			}
			if {([string length $abfpan_gain] <= 0) || ![IsNumeric $abfpan_gain] || ($abfpan_gain <= 0.0)} {
				Inf "Invalid Input Gain (> 0.0)"
				continue
			}
			if {[string length $abfpan_hite] > 0} {
				if {!$abfpan_peri} {				
					Inf "Height Information Only Valid With 9-Channel Output Set"
					continue
				} 
				if {![IsNumeric $abfpan_hite] || ($abfpan_hite < -180.0) || ($abfpan_hite > 180.0)} {
					Inf "Invalid Height Value"
					continue
				}
				set hite $abfpan_hite
			} else {
				set hite 0
			}
			if {[string length $abfpan_fnam] <= 0} {
				Inf "No Output Filename Given"
				continue
			}
			set outfnam [string tolower $abfpan_fnam]
			if {![ValidCDPRootname $outfnam]} {
				continue
			}
			if {$abfpan_wav} {
				append outfnam $evv(SNDFILE_EXT)
			} else {
				append outfnam ".amb"
			}
			if {[file exists $outfnam]} {
				Inf "File '$outfnam' Already Exists: Please Choose A Different Name"
				continue
			}
			set cmd [file join $evv(CDPROGRAM_DIR) abfpan2]
			if {![Flteq $abfpan_gain 1.0]} {
				lappend cmd -g$abfpan_gain
			}
			if {$abfpan_wav} {
				lappend cmd -w
			}
			if {$abfpan_peri} {
				if {![Flteq $hite 0.0]} {
					lappend cmd -p$hite
				} else {
					lappend cmd -p
				}
			}
			lappend cmd $fnam $outfnam $abfpan_stt $abfpan_rot
			catch {unset simple_program_messages}
			set prg_dun 0
			set prg_abortd 0
			if [catch {open "|$cmd"} CDPidrun] {
				ErrShow "Failed To Run Program"
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
				set msg "Process Failed"
				set msg [AddSimpleMessages $msg]
				ErrShow $msg
				continue
			}
			if {![file exists $outfnam]} {
				Inf "Process Failed"
				continue
			}
			FileToWkspace $outfnam 0 0 0 0 1
			set msg "File '$outfnam' Is On The Workspace"
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc Fmdcode {} {
	global pr_fmdcode evv fmdcode_layout fmdcode_wav fmdcode_pos fmdcode_fnam
	global prg_dun prg_abortd simple_program_messages
	set fnam [CheckSelectedFile]
	if {[string length $fnam] <= 0} {
		return
	}
	set f .fmdcode 
	if [Dlg_Create $f "DECODE AMBISONIC FORMAT" "set pr_fmdcode 0" -borderwidth $evv(BBDR)] {
		frame $f.1
		button $f.1.ok -text "Do" -command "set pr_fmdcode 1" -highlightbackground [option get . background {}]
		button $f.1.about -text "About" -command CreditRWD -bg white -highlightbackground [option get . background {}]
		button $f.1.qq -text "Quit" -command "set pr_fmdcode 0" -highlightbackground [option get . background {}]
		pack $f.1.ok $f.1.about -side left -padx 2
		pack $f.1.qq -side right
		pack $f.1 -side top -pady 2 -fill x -expand true
		frame $f.2		
		label $f.2.lay -text "Layout"
		entry $f.2.ly -textvariable fmdcode_layout -width 4
		button $f.2.help -text Help -command FmcodeHelp -bg $evv(HELP) -highlightbackground [option get . background {}]
		pack $f.2.lay $f.2.ly $f.2.help -side left -padx 2
		pack $f.2 -side top -pady 2
		frame $f.3
		checkbutton $f.3.w -variable fmdcode_wav -text "Standard 'wav' Output (default WAVEX)" -command ResetsetFmdcodePos
		checkbutton $f.3.x -variable fmdcode_pos -text "Write WAVEX lspkr positions to Header" -command ResetsetFmdcodeWav
		pack $f.3.w $f.3.x -side left
		pack $f.3 -side top -pady 2
		frame $f.4
		label $f.4.nam -text "Outfile Name"
		entry $f.4.nn -textvariable fmdcode_fnam -width 24
		pack $f.4.nam $f.4.nn -side left -padx 2
		pack $f.4 -side top -pady 2
		set fmdcode_layout 10
		set fmdcode_wav 0
		set fmdcode_pos 0
		wm resizable .fmdcode 1 1
		bind $f <Escape> {set pr_fmdcode 0}
		bind $f <Return> {set pr_fmdcode 1}
	}
	set fmdcode_fnam ""
	raise $f
	set pr_fmdcode 0
	set finished 0
	My_Grab 0 $f pr_fmdcode $f.2.ly
	while {!$finished} {
		tkwait variable pr_fmdcode
		if {$pr_fmdcode} {
			if {([string length $fmdcode_layout] <= 0) || ![regexp {^[0-9]+$} $fmdcode_layout] || ($fmdcode_layout < 1) || ($fmdcode_layout > 12)} {
				Inf "Invalid Layout (Range 1 - 12)"
				continue
			}
			if {[string length $fmdcode_fnam] <= 0} {
				Inf "No Output Filename Given"
				continue
			}
			set outfnam [string tolower $fmdcode_fnam]
			if {![ValidCDPRootname $outfnam]} {
				continue
			}
			if {($fmdcode_layout == 3) || ($fmdcode_layout == 5)  || ($fmdcode_layout == 8) \
			||  ($fmdcode_layout == 9) || ($fmdcode_layout == 10) || ($fmdcode_layout == 11)} {
				if {$fmdcode_pos} {
					Inf "This Layout Must Use 'wav' Output Format"
					continue
				}
			}
			if {$fmdcode_wav && $fmdcode_pos} {
				Inf "Cannot Write WAVEX Lpskr Positions Into A Plain \".wav\" File"
				continue
			}
			append outfnam $evv(SNDFILE_EXT)
			if {[file exists $outfnam]} {
				Inf "File '$outfnam' Already Exists: Please Choose A Different Name"
				continue
			}
			set cmd [file join $evv(CDPROGRAM_DIR) fmdcode]
			if {$fmdcode_wav} {
				lappend cmd -w
			}
			if {$fmdcode_pos} {
				lappend cmd -x
			}
			lappend cmd $fnam $outfnam $fmdcode_layout

			catch {unset simple_program_messages}
			set prg_dun 0
			set prg_abortd 0
			if [catch {open "|$cmd"} CDPidrun] {
				ErrShow "Failed To Run Program"
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
				set msg "Process Failed"
				set msg [AddSimpleMessages $msg]
				ErrShow $msg
				continue
			}
			if {![file exists $outfnam]} {
				Inf "Process Failed"
				continue
			}
			FileToWkspace $outfnam 0 0 0 0 1
			set msg "File '$outfnam' Is On The Workspace"
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc Chxformat {} {
	global pr_chxformat evv chxformat_guid chxformat_mask chxformat_test chxformat_seemask chxformat_list
	global prg_dun prg_abortd simple_program_messages
	set fnam [CheckSelectedFile]
	if {[string length $fnam] <= 0} {
		return
	}
	set f .chxformat 
	if [Dlg_Create $f "CHANGE SPEAKER LAYOUT IN WAVE_EX FORMAT" "set pr_chxformat 0" -borderwidth $evv(BBDR)] {
		frame $f.1
		button $f.1.ok -text "Do" -command "set pr_chxformat 1" -highlightbackground [option get . background {}]
		button $f.1.about -text "About" -command CreditRWD -bg white -highlightbackground [option get . background {}]
		button $f.1.help -text Help -command ChxformatHelp -bg $evv(HELP) -highlightbackground [option get . background {}]
		label $f.1.ll -text "WARNING: This process overwrites the existing file" -fg $evv(SPECIAL)
		button $f.1.qq -text "Quit" -command "set pr_chxformat 0" -highlightbackground [option get . background {}]
		pack $f.1.ok $f.1.about  $f.1.help $f.1.ll -side left -padx 2
		pack $f.1.qq -side right
		pack $f.1 -side top -pady 2 -fill x -expand true
		frame $f.2		
		label $f.2.guid -text "Change GUID type between PCM and AMB"
		entry $f.2.gg -textvariable chxformat_guid -width 4
		pack $f.2.guid $f.2.gg -side left -padx 2
		pack $f.2 -side top -pady 2
		frame $f.3		
		label $f.3.mask -text "Change speaker position mask"
		entry $f.3.mm -textvariable chxformat_mask -width 4
		pack $f.3.mask $f.3.mm -side left -padx 2
		pack $f.3 -side top -pady 2
		frame $f.4		
		checkbutton $f.4.sm -variable chxformat_seemask -text "See list of WAVEX mask values." -command ResetChxformat
		checkbutton $f.4.tt -variable chxformat_test -text "See GUID type and speaker mask"
		pack $f.4.sm $f.4.tt -side left -padx 2
		pack $f.4 -side top -pady 2
		frame $f.5
		set chxformat_list [Scrolled_Listbox $f.5.ll -width 60 -height 20 -selectmode single]
		pack $f.5.ll -side top
		pack $f.5 -side top -pady 2
		wm resizable .chxformat 1 1
		bind $f <Escape> {set pr_chxformat 0}
		bind $f <Return> {set pr_chxformat 1}
	}
	set rms_infobox $chxformat_list
	$rms_infobox  delete 0 end
	set chxformat_guid ""
	set chxformat_mask ""
	set chxformat_seemask 0
	set chxformat_test 0
	raise $f
	set pr_chxformat 0
	set finished 0
	My_Grab 0 $f pr_chxformat
	while {!$finished} {
		tkwait variable pr_chxformat
		if {$pr_chxformat} {
			if {[string length $chxformat_guid] > 0} {
				if {![regexp {^[1,2]$} $chxformat_guid]} {
					Inf "Invalid GUID Change Type (1 or 2)"
					continue
				} else {
					set guid $chxformat_guid
				}
			} else {
				set guid 0
			}
			if {[string length $chxformat_mask] > 0} {
				if {![regexp {^[0-9]+$} $chxformat_mask] && ![regexp {^0x[0-9A-F]+$} $chxformat_mask]} {
					Inf "Invalid Mask (Integer or hex Integer)"
					continue
				} else {
					set mask $chxformat_mask
				}
			} else {
				set mask 0
			}
			if {!$chxformat_seemask && !$chxformat_test && ($guid <= 0) && ([string length $chxformat_mask] <= 0)} {					
				Inf "No Parameters Set"
				continue
			}
			set cmd [file join $evv(CDPROGRAM_DIR) chxformat]
			if {$chxformat_seemask} {
				lappend cmd -m
			} else {
				if {$chxformat_test} {					
					lappend cmd -t
				}
				if {$guid > 0} {
					lappend cmd -g$guid
				}
				if {[string length $chxformat_mask] > 0} {
					lappend cmd -s$mask
				}
			}
			lappend cmd $fnam
			catch {unset simple_program_messages}
			set prg_dun 0
			set prg_abortd 0
			if [catch {open "|$cmd"} CDPidrun] {
				ErrShow "Failed To Run Program"
				catch {unset CDPidrun}
				continue
			} else {
				fileevent $CDPidrun readable "ShowRmsInfo"
			}
			vwait prg_dun
			if {$prg_abortd} {
				set prg_dun 0
			}
			if {!$prg_dun} {
				set msg "Process Failed"
				set msg [AddSimpleMessages $msg]
				ErrShow $msg
				continue
			}
			if {![file exists $outfnam]} {
				Inf "Process Failed"
				continue
			}
			set msg "File '$fnam' Has Been Modified"
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc Chorder {} {
	global pr_chorder evv chorder_string chorder_fnam pa
	global prg_dun prg_abortd simple_program_messages
	set fnam [CheckSelectedFile]
	if {[string length $fnam] <= 0} {
		return
	}
	set f .chorder 
	if [Dlg_Create $f "REORDER OUTPUT CHANNELS" "set pr_chorder 0" -borderwidth $evv(BBDR)] {
		frame $f.1
		button $f.1.ok -text "Do" -command "set pr_chorder 1" -highlightbackground [option get . background {}]
		button $f.1.about -text "About" -command CreditRWD -bg white -highlightbackground [option get . background {}]
		button $f.1.qq -text "Quit" -command "set pr_chorder 0" -highlightbackground [option get . background {}]
		pack $f.1.ok $f.1.about -side left -padx 2
		pack $f.1.qq -side right
		pack $f.1 -side top -pady 2 -fill x -expand true
		frame $f.2		
		label $f.2.order -text "Reorder String"
		button $f.2.help -text Help -command "ChorderHelp" -bg $evv(HELP) -highlightbackground [option get . background {}]
		entry $f.2.str -textvariable chorder_string -width 24
		pack $f.2.order $f.2.str $f.2.help -side left -padx 2
		pack $f.2 -side top -pady 2
		frame $f.3
		label $f.3.nam -text "Outfile Name"
		entry $f.3.nn -textvariable chorder_fnam -width 24
		pack $f.3.nam $f.3.nn -side left -padx 2
		pack $f.3 -side top -pady 2
		wm resizable .chorder 1 1
		bind $f <Escape> {set pr_chorder 0}
		bind $f <Return> {set pr_chorder 1}
	}
	set chorder_string ""
	set chorder_fnam ""
	raise $f
	set pr_chorder 0
	set finished 0
	My_Grab 0 $f pr_chorder $f.2.str
	while {!$finished} {
		tkwait variable pr_chorder
		if {$pr_chorder} {
			if {[string length $chorder_string] <= 0} {
				Inf "No Reorder String Entered"
				continue
			}
			if {![ValidChorderString $chorder_string]} {
				Inf "Invalid Reorder String Entered"
				continue
			}
			set maxchan [MaxChorderChan $chorder_string]
			if {$maxchan > $pa($fnam,$evv(CHANS))} {
				Inf "Input File Has Too Few Channels For The Reorder String Entered"
				continue
			}
			if {[string length $chorder_fnam] <= 0} {
				Inf "No Output Filename Given"
				continue
			}
			set outfnam [string tolower $chorder_fnam]
			if {![ValidCDPRootname $outfnam]} {
				continue
			}
			append outfnam [file extension $fnam]
			if {[file exists $outfnam]} {
				Inf "File '$outfnam' Already Exists: Please Choose A Different Name"
				continue
			}
			set cmd [file join $evv(CDPROGRAM_DIR) chorder]
			lappend cmd $fnam $outfnam $chorder_string
			catch {unset simple_program_messages}
			set prg_dun 0
			set prg_abortd 0
			if [catch {open "|$cmd"} CDPidrun] {
				ErrShow "Failed To Run Program"
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
				set msg "Process Failed"
				set msg [AddSimpleMessages $msg]
				ErrShow $msg
				continue
			}
			if {![file exists $outfnam]} {
				Inf "Process Failed"
				continue
			}
			FileToWkspace $outfnam 0 0 0 0 1
			set msg "File '$outfnam' Is On The Workspace"
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc Interlx {} {
	global chlist pr_interlx pa evv interlx_format interlx_fnam
	global prg_dun prg_abortd simple_program_messages

	if {![info exists chlist] || ([llength $chlist] < 2)} {
		Inf "Put Several Files On The Chosen List"
		return
	}
	if {[llength $chlist] > 16} {
		Inf "Too Many Input Files (Max 16)"	
		return
	}
	set len 0
	foreach fnam $chlist {
		if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
			Inf "Not All The Chosen Files Are Soundfiles"
			return
		}
		incr len
	}
	set chans $pa([lindex $chlist 0],$evv(CHANS)) 
	set srate $pa([lindex $chlist 0],$evv(SRATE)) 
	foreach fnam [lrange $chlist 1 end] {
		if {($pa($fnam,$evv(CHANS)) != $chans) || ($pa($fnam,$evv(SRATE)) != $srate)} {
			Inf "Not All The Chosen Files Have The Same Channel Count And Sample Rate"
			return
		}
	}
	set f .interlx 
	if [Dlg_Create $f "INTERLEAVE CHANNELS" "set pr_interlx 0" -borderwidth $evv(BBDR)] {
		frame $f.1
		button $f.1.ok -text "Do" -command "set pr_interlx 1" -highlightbackground [option get . background {}]
		button $f.1.about -text "About" -command CreditRWD -bg white -highlightbackground [option get . background {}]
		button $f.1.qq -text "Quit" -command "set pr_interlx 0" -highlightbackground [option get . background {}]
		pack $f.1.ok $f.1.about -side left -padx 2
		pack $f.1.qq -side right
		pack $f.1 -side top -pady 2 -fill x -expand true
		frame $f.2
		label $f.2.for -text "Outfile Format"
		entry $f.2.ff -textvariable interlx_format -width 24
		button $f.2.help -text Help -command InterlxHelp -bg $evv(HELP) -highlightbackground [option get . background {}]
		pack $f.2.for $f.2.ff $f.2.help -side left -padx 2
		pack $f.2 -side top -pady 2
		frame $f.3
		label $f.3.nam -text "Outfile Name"
		entry $f.3.nn -textvariable interlx_fnam -width 24
		pack $f.3.nam $f.3.nn -side left -padx 2
		pack $f.3 -side top -pady 2
		wm resizable .interlx 1 1
		bind $f <Escape> {set pr_interlx 0}
		bind $f <Return> {set pr_interlx 1}
	}
	set interlx_fnam "" 
	set interlx_format 0
	raise $f
	set pr_interlx 0
	set finished 0
	My_Grab 0 $f pr_interlx $f.2.ff
	while {!$finished} {
		tkwait variable pr_interlx
		if {$pr_interlx} {
			if {[string length $interlx_format] > 0} {

				if {![regexp {^[0-9]+$} $interlx_format] || ($interlx_format < 0) || ($interlx_format > 8)} {
					Inf "Invalid Format (Range 0 -8)"
					continue
				} else {
					set format $interlx_format
				}
			} else {
				set format 0
			}
			switch -- $format {
				3 {
					if {$chans != 4} {
						Inf "Format 3 Only Works With Files with 4 Input Channels"
						continue
					}
				}
				4 {
					if {$chans != 6} {
						Inf "Format 4 Only Works With Files with 6 Input Channels"
						continue
					}
				}
				6 {
					if {$chans != 5} {
						Inf "Format 6 Only Works With Files with 5 Input Channels"
						continue
					}
				}
				7 -
				8 {
					if {$chans != 5} {
						Inf "Formats 7 & 8 Only Works Files with With 8 Input Channels"
						continue
					}
				}
			}
			if {[string length $interlx_fnam] <= 0} {
				Inf "No Output Filename Given"
				continue
			}
			set outfnam [string tolower $interlx_fnam]
			if {![ValidCDPRootname $outfnam]} {
				continue
			}
			if {$interlx_format == 5} {
				append outfnam ".amb"
			} else {
				append outfnam $evv(SNDFILE_EXT)
			}
			if {[file exists $outfnam]} {
				Inf "File '$outfnam' Already Exists: Please Choose A Different Name"
				continue
			}
			set cmd [file join $evv(CDPROGRAM_DIR) interlx]
			if {$format > 0} {
				lappend cmd -t$format
			}
			lappend cmd $outfnam
			foreach fnam $chlist {
				lappend cmd $fnam
			}

			catch {unset simple_program_messages}
			set prg_dun 0
			set prg_abortd 0
			if [catch {open "|$cmd"} CDPidrun] {
				ErrShow "Failed To Run Program"
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
				set msg "Process Failed"
				set msg [AddSimpleMessages $msg]
				ErrShow $msg
				continue
			}
			if {![file exists $outfnam]} {
				Inf "Process Failed"
				continue
			}
			FileToWkspace $outfnam 0 0 0 0 1
			set msg "File '$outfnam' Is On The Workspace"
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc Copysfx {} {
	global pr_copysfx evv copysfx_stype copysfx_format copysfx_fnam copysfx_minhd wstk pa
	global prg_dun prg_abortd simple_program_messages

	set fnam [CheckSelectedFile]
	if {[string length $fnam] <= 0} {
		return
	}
	set chans $pa($fnam,$evv(CHANS))
	set f .copysfx 
	if [Dlg_Create $f "COPY, CHANGING FORMAT" "set pr_copysfx 0" -borderwidth $evv(BBDR)] {
		frame $f.1
		button $f.1.ok -text "Do" -command "set pr_copysfx 1" -highlightbackground [option get . background {}]
		button $f.1.about -text "About" -command CreditRWD -bg white -highlightbackground [option get . background {}]
		label $f.1.ll -text "where format or samptype not set, input format or samptype used"
		button $f.1.qq -text "Quit" -command "set pr_copysfx 0" -highlightbackground [option get . background {}]
		pack $f.1.ok $f.1.about $f.1.ll -side left -padx 2
		pack $f.1.qq -side right
		pack $f.1 -side top -pady 2 -fill x -expand true
		frame $f.2
		label $f.2.sam -text "Sample Type"
		entry $f.2.ss -textvariable copysfx_stype -width 4
		button $f.2.help -text Help -command CopysfxTypeHelp -bg $evv(HELP) -highlightbackground [option get . background {}]
		pack $f.2.sam $f.2.ss $f.2.help -side left -padx 2
		pack $f.2 -side top -pady 2
		frame $f.3
		label $f.3.for -text "Output File Format"
		entry $f.3.ff -textvariable copysfx_format -width 4
		button $f.3.help -text Help -command InterlxHelp -bg $evv(HELP) -highlightbackground [option get . background {}]
		pack $f.3.for $f.3.ff $f.3.help -side left -padx 2
		pack $f.3 -side top -pady 2
		checkbutton $f.4 -variable copysfx_minhd -text "Write Minimal Header"
		pack $f.4 -side top -pady 2
		frame $f.5
		label $f.5.nam -text "Outfile Name"
		entry $f.5.nn -textvariable copysfx_fnam -width 24
		pack $f.5.nam $f.5.nn -side left -padx 2
		pack $f.5 -side top -pady 2
		wm resizable .copysfx 1 1
		bind $f <Escape> {set pr_copysfx 0}
		bind $f <Return> {set pr_copysfx 1}
	}
	set copysfx_fnam ""
	set copysfx_stype "" 
	set copysfx_format "" 
	set copysfx_minhd 0
	raise $f
	set pr_copysfx 0
	set finished 0
	My_Grab 0 $f pr_copysfx $f.3.ff
	while {!$finished} {
		tkwait variable pr_copysfx
		if {$pr_copysfx} {
			if {[string length $copysfx_stype] > 0} {
				if {![regexp {^[0-9]+$} $copysfx_stype] || ($copysfx_stype < 1) || ($copysfx_stype > 4)} {
					Inf "Invalid Sample Type (Range 1-4)"
					continue
				} else {
					set stype $copysfx_stype
				}
			} else {
				set stype 0
			}
			if {[string length $copysfx_format] > 0} {
				if {![regexp {^[0-9]+$} $copysfx_format] || ($copysfx_format < 0) || ($copysfx_format > 8)} {
					Inf "Invalid Format Type (Range 0-8)"
					continue
				} else {
					set format $copysfx_format
				}
			} else {
				set format -1
			}
			if {[string length $copysfx_fnam] <= 0} {
				Inf "No Output Filename Given"
				continue
			}
			if {($copysfx_minhd == 0) && ($format < 0) && ($stype == 0)} {
				set msg "No Change To Input File: Continue To Make A Copy ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
			}
			switch -- $copysfx_format {
				3 {
					if {$chans != 4} {
						Inf "Format 3 Only Works With 4 Channel Input Files"
						continue
					}
				}
				4 {
					if {$chans != 6} {
						Inf "Format 4 Only Works With 6 Channel Input Files"
						continue
					}
				}
				6 {
					if {$chans != 5} {
						Inf "Format 6 Only Works With 5 Channel Input Files"
						continue
					}
				}
				7 -
				8 {
					if {$chans != 5} {
						Inf "Formats 7 & 8 Only Works With 8 Channel Input Files"
						continue
					}
				}
			}
			set outfnam [string tolower $copysfx_fnam]
			if {![ValidCDPRootname $outfnam]} {
				continue
			}
			if {$copysfx_format == 5} {
				append outfnam ".amb"
			} else {
				append outfnam $evv(SNDFILE_EXT)
			}
			if {[file exists $outfnam]} {
				Inf "File '$outfnam' Already Exists: Please Choose A Different Name"
				continue
			}
			set cmd [file join $evv(CDPROGRAM_DIR) copysfx]
			if {$copysfx_minhd} {
				lappend cmd -h
			}
			if {$stype > 0} {
				lappend cmd -s$stype
			}
			if {$format >= 0} {
				lappend cmd -t$format
			}
			lappend cmd $fnam $outfnam
			catch {unset simple_program_messages}
			set prg_dun 0
			set prg_abortd 0
			if [catch {open "|$cmd"} CDPidrun] {
				ErrShow "Failed To Run Program"
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
				set msg "Process Failed"
				set msg [AddSimpleMessages $msg]
				ErrShow $msg
				continue
			}
			if {![file exists $outfnam]} {
				Inf "Process Failed"
				continue
			}
			FileToWkspace $outfnam 0 0 0 0 1
			set msg "File '$outfnam' Is On The Workspace"
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc Njoin {} {
	global pr_njoin evv pa chlist njoin_sil njoin_qikstt njoin_cue njoin_fnam
	global prg_dun prg_abortd simple_program_messages

	if {![info exists chlist] || ([llength $chlist] != 1)} {
		Inf "Put A Soundfile-List On The Chosen List"
		return
	}
	set listfnam [lindex $chlist 0]
	if {![IsASndlist $pa($listfnam,$evv(FTYP))]} {
		Inf "Put A Textfile, Listing The Soundfiles You Want To Use, On The Chosen Files List"
		return
	}
	if [catch {open $listfnam "r"} zit] {
		Inf "Cannot Open File '$fnam'"
		return
	}
	while {[gets $zit line] >= 0} {
		catch {unset nuline}
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		lappend fnams $line
	}
	close $zit
	set n 0
	foreach fnam $fnams {
		if {![info exists pa($fnam,$evv(CHANS))]} {
			Inf "File '$fnam' Is Not On The Workspace : Grab All Listed Files To Workspace (^g) Before Proceeding"
			return
		}
		if {$n == 0} {
			set chans $pa($fnam,$evv(CHANS))
			set srate $pa($fnam,$evv(SRATE))
		} else {
			if {($chans != $pa($fnam,$evv(CHANS))) || ($srate != $pa($fnam,$evv(SRATE)))} {
				Inf "Files Are Of Different Type, Cannot Proceed"
				return
			}
		}
		incr n
	}
	set f .njoin 
	if [Dlg_Create $f "CONCENATE FILES (POSSIBLY FOR CD BURN)" "set pr_njoin 0" -borderwidth $evv(BBDR)] {
		frame $f.1
		button $f.1.ok -text "Do" -command "set pr_njoin 1" -highlightbackground [option get . background {}]
		button $f.1.about -text "About" -command CreditRWD -bg white -highlightbackground [option get . background {}]
		button $f.1.qq -text "Quit" -command "set pr_njoin 0" -highlightbackground [option get . background {}]
		pack $f.1.ok $f.1.about -side left -padx 2
		pack $f.1.qq -side right
		pack $f.1 -side top -pady 2 -fill x -expand true
		frame $f.2
		label $f.2.sil -text "Silence between files (secs)"
		entry $f.2.ss -textvariable njoin_sil -width 4
		pack $f.2.sil $f.2.ss -side left -padx 2
		pack $f.2 -side top -pady 2
		checkbutton $f.3 -variable njoin_qikstt -text "No silence at start"
		pack $f.3 -side top -pady 2
		frame $f.4
		label $f.4.cue -text "Name of cuelist file (if any)"
		entry $f.4.cc -textvariable njoin_cue -width 4
		pack $f.4.cue $f.4.cc -side left -padx 2
		pack $f.4 -side top -pady 2
		frame $f.5
		label $f.5.nam -text "Outfile Name"
		entry $f.5.nn -textvariable njoin_fnam -width 24
		pack $f.5.nam $f.5.nn -side left -padx 2
		pack $f.5 -side top -pady 2
		wm resizable .njoin 1 1
		bind $f <Escape> {set pr_njoin 0}
		bind $f <Return> {set pr_njoin 1}
	}
	set njoin_sil 0
	set njoin_qikstt 1
	set njoin_cue ""
	set njoin_fnam ""
	raise $f
	set pr_njoin 0
	set finished 0
	My_Grab 0 $f pr_njoin $f.2.ss
	while {!$finished} {
		tkwait variable pr_njoin
		catch {unset cuefnam}
		if {$pr_njoin} {
			if {[string length $njoin_sil] > 0} {
				if {![IsNumeric $njoin_sil] || ($njoin_sil < 0)} {
					Inf "Invalid Silence Duration Between Files (Range >= 0)"
					continue
				} else {
					set silgap $njoin_sil
				}
			} else {
				set silgap 0
			}
			if {[string length $njoin_cue] > 0} {
				set cuefnam [string tolower $njoin_cue]
				if {![ValidCDPRootname $cuefnam]} {
					continue
				}
				append cuefnam $evv(TEXT_EXT)
				if {[file exists $cuefnam]} {
					Inf "File '$cuefnam' Already Exists: Please Choose A Different Name"
					continue
				}
			}
			if {[string length $njoin_fnam] <= 0} {
				Inf "No Output Filename Entered"
				continue
			}
			set outfnam [string tolower $njoin_fnam]
			if {![ValidCDPRootname $outfnam]} {
				continue
			}
			append outfnam [file extension $fnam]
			if {[file exists $outfnam]} {
				Inf "File '$outfnam' Already Exists: Please Choose A Different Name"
				continue
			}
			set cmd [file join $evv(CDPROGRAM_DIR) njoin]
			if {$silgap > 0} {
				if {$njoin_qikstt} {
					lappend cmd -S$silgap
				} else {
					lappend cmd -s$silgap
				}
			}
			if {[info exists cuefnam]} {
				lappend cmd -c$cuefnam
			}
			lappend cmd $listfnam $outfnam

			catch {unset simple_program_messages}
			set prg_dun 0
			set prg_abortd 0
			if [catch {open "|$cmd"} CDPidrun] {
				ErrShow "Failed To Run Program"
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
				set msg "Process Failed"
				set msg [AddSimpleMessages $msg]
				ErrShow $msg
				continue
			}
			if {![file exists $outfnam]} {
				Inf "Process Failed"
				continue
			}
			if {[info exists cuefnam]} {
				FileToWkspace $cuefnam 0 0 0 0 1
			}
			FileToWkspace $outfnam 0 0 0 0 1
			if {[info exists cuefnam]} {
				set msg "Files '$outfnam' And '$cuefnam' Are On The Workspace"
			} else {
				set msg "Files '$outfnam' Is On The Workspace"
			}
			Inf $msg
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc Rmsinfo {} {
	global pr_rmsinfo evv rmsinfo_stt rmsinfo_end rmsinfo_odbfs rms_infobox rmsinfo_list pa
	global prg_dun prg_abortd simple_program_messages

	set fnam [CheckSelectedFile]
	if {[string length $fnam] <= 0} {
		return
	}
	set f .rmsinfo 
	if [Dlg_Create $f "RMS POWER AND LEVEL STATS" "set pr_rmsinfo 0" -borderwidth $evv(BBDR)] {
		frame $f.1
		button $f.1.ok -text "Do" -command "set pr_rmsinfo 1" -highlightbackground [option get . background {}]
		button $f.1.about -text "About" -command CreditRWD -bg white -highlightbackground [option get . background {}]
		button $f.1.qq -text "Quit" -command "set pr_rmsinfo 0" -highlightbackground [option get . background {}]
		pack $f.1.ok $f.1.about -side left -padx 2
		pack $f.1.qq -side right
		pack $f.1 -side top -pady 2 -fill x -expand true
		frame $f.2
		label $f.2.start -text "Start scan at"
		entry $f.2.stt -textvariable rmsinfo_stt -width 12
		pack $f.2.start $f.2.stt -side left -padx 2
		pack $f.2 -side top -pady 2
		frame $f.3
		label $f.3.end -text "End scan at "
		entry $f.3.ee -textvariable rmsinfo_end -width 12
		pack $f.3.end $f.3.ee -side left -padx 2
		pack $f.3 -side top -pady 2
		checkbutton $f.4 -variable rmsinfo_odbfs -text "Show equivalent 0dBFS-normalised values."
		pack $f.4 -side top -pady 2
		frame $f.5
		set rmsinfo_list [Scrolled_Listbox $f.5.ll -width 60 -height 20 -selectmode single]
		pack $f.5.ll -side top -pady 2
		pack $f.5 -side top -pady 2
		wm resizable .rmsinfo 1 1
		bind $f <Escape> {set pr_rmsinfo 0}
		bind $f <Return> {set pr_rmsinfo 1}
	}
	set rms_infobox $rmsinfo_list
	set rmsinfo_stt 0.0
	set rmsinfo_end $pa($fnam,$evv(DUR))
	set rmsinfo_odbfs 0
	set rmsinfo_fnam ""
	$rms_infobox delete 0 end
	raise $f
	set pr_rmsinfo 0
	set finished 0
	My_Grab 0 $f pr_rmsinfo $f.2.stt
	while {!$finished} {
		tkwait variable pr_rmsinfo
		if {$pr_rmsinfo} {
			if {![IsNumeric $rmsinfo_stt] || ($rmsinfo_stt < 0) || ($rmsinfo_stt >= $pa($fnam,$evv(DUR)))} {
				Inf "Invalid Start Scan Time"
				continue
			}
			if {![IsNumeric $rmsinfo_end] || ($rmsinfo_end <= 0) || ($rmsinfo_end > $pa($fnam,$evv(DUR)))} {
				Inf "Invalid End Scan Time"
				continue
			}
			if {$rmsinfo_stt >= $rmsinfo_end} {
				Inf "Scan Start And End Times Are Too Close Or In The Wrong Order"
				continue
			}
			set cmd [file join $evv(CDPROGRAM_DIR) rmsinfo]
			if {$rmsinfo_odbfs} {
				lappend cmd -n
			}
			lappend cmd $fnam $rmsinfo_stt $rmsinfo_end
			catch {unset simple_program_messages}
			set prg_dun 0
			set prg_abortd 0
			if [catch {open "|$cmd"} CDPidrun] {
				ErrShow "Failed To Run Program"
				catch {unset CDPidrun}
				continue
			} else {
				fileevent $CDPidrun readable "ShowRmsInfo"
			}
			vwait prg_dun
			if {$prg_abortd} {
				set prg_dun 0
			}
			if {!$prg_dun} {
				set msg "Process Failed"
				set msg [AddSimpleMessages $msg]
				ErrShow $msg
			}
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc Sfprops {} {
	global pr_sfprops evv 
	global prg_dun prg_abortd simple_program_messages rms_infobox sfprops_list

	set fnam [CheckSelectedFile]
	if {[string length $fnam] <= 0} {
		return
	}
	set f .sfprops 
	if [Dlg_Create $f "MULTICHAN PROPERTIES DISPLAY" "set pr_sfprops 0" -borderwidth $evv(BBDR)] {
		frame $f.1
		button $f.1.ok -text "Do" -command "set pr_sfprops 1" -highlightbackground [option get . background {}]
		button $f.1.about -text "About" -command CreditRWD -bg white -highlightbackground [option get . background {}]
		button $f.1.qq -text "Quit" -command "set pr_sfprops 0" -highlightbackground [option get . background {}] 
		pack $f.1.ok $f.1.about -side left -padx 2
		pack $f.1.qq -side right
		pack $f.1 -side top -pady 2 -fill x -expand true
		frame $f.2
		set sfprops_list [Scrolled_Listbox $f.2.ll -width 60 -height 20 -selectmode single]
		pack $f.2.ll -side top
		pack $f.2 -side top -pady 2
		wm resizable .sfprops 1 1
		bind $f <Return> {set pr_sfprops 1}
		bind $f <Escape> {set pr_sfprops 0}
	}
	set rms_infobox $sfprops_list
	$rms_infobox delete 0 end
	raise $f
	set pr_sfprops 0
	set finished 0
	My_Grab 0 $f pr_sfprops
	while {!$finished} {
		tkwait variable pr_sfprops
		if {$pr_sfprops} {
			set cmd [file join $evv(CDPROGRAM_DIR) sfprops]
			lappend cmd $fnam
			catch {unset simple_program_messages}
			set prg_dun 0
			set prg_abortd 0
			if [catch {open "|$cmd"} CDPidrun] {
				ErrShow "Failed To Run Program"
				catch {unset CDPidrun}
				continue
			} else {
				fileevent $CDPidrun readable "ShowRmsInfo"
			}
			vwait prg_dun
			if {$prg_abortd} {
				set prg_dun 0
			}
			if {!$prg_dun} {
				set msg "Process Failed"
				set msg [AddSimpleMessages $msg]
				ErrShow $msg
			}
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#----- Get Selected File

proc CheckSelectedFile {} {
	global wl chlist pa evv
	set i [$wl curselection]
	if {![info exists i] || ([llength $i] <= 0)} {
		if {[info exists chlist] && [llength $chlist] == 1} {
			set k [LstIndx [lindex $chlist 0] $wl]
			$wl selection clear 0 end
			$wl selection set $k
			set i [$wl curselection]
		}
	}
	if {![info exists i] || ([llength $i] !=1)} {
		Inf "SELECT (JUST) ONE SOUNDFILE"
		return ""
	}
	set fnam [$wl get $i]
	if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
		Inf "SELECT A SOUNDFILE"
		return ""
	}
	return $fnam
}

proc FmcodeHelp {} {
	set msg "           POSSIBLE LAYOUT VALUES\n"
	append msg "\n"
	append msg "1   : MONO\n"
	append msg "2   : STEREO\n"
	append msg "3* : SQUARE\n"
	append msg "4   : QUAD (in order Front Left, Front Right, Read LEft, Rear Right)\n"
	append msg "5* : PENTAGON\n"
	append msg "6   : 5.0 SURROUND\n"
	append msg "7   : 5.1 SURROUND\n"
	append msg "8* : HEXAGON\n"
	append msg "9* : OCTAGON 1 (front pair)\n"
	append msg "10*: OCTAGON 2 (front centre speaker)\n"
	append msg "11*: CUBE (as 3, interleaved, C-Sound compatible)\n"
	append msg "12  : CUBE (as 4, low quad followed by high quad)\n"
	append msg "\n"
	append msg "Items marked \"*\" only work with \".wav\" format output.\n"
	Inf $msg
}

proc ChxformatHelp {} {
	set msg "           MODIFYING GUID AND MASK\n"
	append msg "\n"
	append msg "Change GUID type between PCM and AMB\n"
	append msg "\n"
	append msg "1 : For Plain WAVEX\n"
	append msg "2 : For AMB\n"
	append msg "\n"
	append msg "Change speaker position mask\n"
	append msg "\n"
	append msg "0 : Unset Channel mask\n"
	append msg "Default: Your Mask, as Decimal or Hexadecimal representation.\n"
	append msg "\n"
	Inf $msg
}


proc ChorderHelp {} {
	set msg "           REORDER STRING FORMAT\n"
	append msg "\n"
	append msg "Any combination of the characters a-z, and '0'\n"
	append msg "\n"
	append msg "Infile channels are represented in order a=1, b=2, c=3 etc.\n"
	append msg "0 creates a silent output channel \n"
	append msg "\n"
	append msg "String \"bca\" for example, then  assigns\n"
	append msg "channel 2(= b) to output 1\n"
	append msg "channel 3(= c) to output 2\n"
	append msg "channel 1(= a) to output 3\n"
	append msg "\n"
	append msg "String \"bbc0a\" for example, assigns\n"
	append msg "channel 2(= b) to output 1\n"
	append msg "channel 2(= b) to output 2\n"
	append msg "channel 3(= c) to output 3\n"
	append msg "silent channel at output 4\n"
	append msg "channel 1(= a) to output 5\n"
	append msg "\n"
	Inf $msg
}

proc ValidChorderString {str} {
	if {![regexp {^[a-z,0]+$} $str]} {
		return 0
	}
	if {[string length $str] > 26} {
		return 0
	}
	return 1
}

proc InterlxHelp {} {
	set msg "           POSSIBLE FORMAT VALUES\n"
	append msg "\n"
	append msg "0 : Standard Soundfile\n"
	append msg "1 : Generic WAVE_EX (no speaker assignments)\n"
	append msg "2 : WAVE_EX mono/stereo/quad (Front L,R Rear L,R)\n"
	append msg "3 : WAVE_EX quad surround (L,C,R,S) (infile must be 4-channel)\n"
	append msg "4 : WAVE_EX 5.1 format surround (infile must be 6-channel)\n"
	append msg "5 : WAVE_EX Ambisonic B-Format (W,X,Y,Z), supports \".amb\"\n"
	append msg "6 : WAVE_EX 5.0 Surround  (infile must be 5-channel)\n"
	append msg "7 : WAVE_EX 7.1 Surround  (infile must be 8-channel)\n"
	append msg "8 : WAVE_EX Cube Surround (infile must be 8-channel)\n"
	Inf $msg
}

proc ShowRmsInfo {} {
	global CDPidrun prg_dun prg_abortd rms_infobox

	if [eof $CDPidrun] {
		set prg_dun 1
		catch {close $CDPidrun}
		return
	} else {
		gets $CDPidrun line
		set line [string trim $line]
		if {[string length $line] <= 0} {
			return
		} elseif [string match INFO:* $line] {
			$rms_infobox insert end $line
		} elseif [string match WARNING:* $line] {
			return
		} elseif [string match ERROR:* $line] {
			Inf $line
			set prg_abortd 1
			return
		} elseif [string match END:* $line] {
			set prg_dun 1
			return
		} else {
			Inf $line
			set prg_abortd 1
			return
		}
	}
	update idletasks
}

proc CreditRWD {} {
 	set msg "MULTICHANNEL TOOLKIT PROGRAM\n"	
	append msg "\n"
	append msg "Created by Richard Dobson\n"
	append msg "\n"
	Inf $msg
}

proc ResetsetFmdcodeWav {} {
	global fmdcode_wav fmdcode_pos
	if {$fmdcode_pos} {
		set fmdcode_wav 0
	}
}

proc ResetsetFmdcodePos {} {
	global fmdcode_wav fmdcode_pos
	if {$fmdcode_wav} {
		set fmdcode_pos 0
	}
}

proc ResetChxformat {} {
	global chxformat_seemask chxformat_test chxformat_mask chxformat_guid
	global old_chxformat_test old_chxformat_mask old_chxformat_guid
	if {$chxformat_seemask} {
		set old_chxformat_test $chxformat_test
		set old_chxformat_mask $chxformat_mask
		set old_chxformat_guid $chxformat_guid
		set chxformat_test 0
		set chxformat_mask ""
		set chxformat_guid ""
	} else {
		if [info exists old_chxformat_test] {
			set chxformat_test $old_chxformat_test
		}
		if [info exists old_chxformat_mask] {
			set chxformat_mask $old_chxformat_mask
		}
		if [info exists old_chxformat_guid] {
			set chxformat_guid $old_chxformat_guid
		}
	}
}

proc MaxChorderChan {str} {
	set len [string length $str]
	set n 0
	set maxchan 0
	while {$n < $len} {
		set char [string index $str $n]
		switch -- $char {
			"a" {
				set chan 1
				if {$chan > $maxchan} {
					set maxchan $chan
				}
			}
			"b" {
				set chan 2
				if {$chan > $maxchan} {
					set maxchan $chan
				}
			}
			"c" {
				set chan 3
				if {$chan > $maxchan} {
					set maxchan $chan
				}
			}
			"d" {
				set chan 4
				if {$chan > $maxchan} {
					set maxchan $chan
				}
			}
			"e" {
				set chan 5
				if {$chan > $maxchan} {
					set maxchan $chan
				}
			}
			"f" {
				set chan 6
				if {$chan > $maxchan} {
					set maxchan $chan
				}
			}
			"g" {
				set chan 7
				if {$chan > $maxchan} {
					set maxchan $chan
				}
			}
			"h" {
				set chan 8
				if {$chan > $maxchan} {
					set maxchan $chan
				}
			}
			"i" {
				set chan 9
				if {$chan > $maxchan} {
					set maxchan $chan
				}
			}
			"j" {
				set chan 10
				if {$chan > $maxchan} {
					set maxchan $chan
				}
			}
			"k" {
				set chan 11
				if {$chan > $maxchan} {
					set maxchan $chan
				}
			}
			"l" {
				set chan 12
				if {$chan > $maxchan} {
					set maxchan $chan
				}
			}
			"m" {
				set chan 13
				if {$chan > $maxchan} {
					set maxchan $chan
				}
			}
			"n" {
				set chan 14
				if {$chan > $maxchan} {
					set maxchan $chan
				}
			}
			"o" {
				set chan 15
				if {$chan > $maxchan} {
					set maxchan $chan
				}
			}
			"p" {
				set chan 16
				if {$chan > $maxchan} {
					set maxchan $chan
				}
			}
			"q" {
				set chan 17
				if {$chan > $maxchan} {
					set maxchan $chan
				}
			}
			"r" {
				set chan 18
				if {$chan > $maxchan} {
					set maxchan $chan
				}
			}
			"s" {
				set chan 19
				if {$chan > $maxchan} {
					set maxchan $chan
				}
			}
			"t" {
				set chan 20
				if {$chan > $maxchan} {
					set maxchan $chan
				}
			}
			"u" {
				set chan 21
				if {$chan > $maxchan} {
					set maxchan $chan
				}
			}
			"v" {
				set chan 22
				if {$chan > $maxchan} {
					set maxchan $chan
				}
			}
			"w" {
				set chan 23
				if {$chan > $maxchan} {
					set maxchan $chan
				}
			}
			"x" {
				set chan 24
				if {$chan > $maxchan} {
					set maxchan $chan
				}
			}
			"y" {
				set chan 25
				if {$chan > $maxchan} {
					set maxchan $chan
				}
			}
			"z" {
				set chan 26
				if {$chan > $maxchan} {
					set maxchan $chan
				}
			}
		}
		incr n
	}
	return $maxchan
}

proc CopysfxTypeHelp {} {
	set msg "SAMPLE TYPES\n"	
	append msg "\n"
	append msg "1  :  16 bit integers (shorts)\n"
	append msg "2  :  32 bit integers (longs)\n"
	append msg "3  :  32 bit floating-point\n"
	append msg "4  :  24 bit integer 'packed'\n"
	append msg "\n"
	append msg "Defaults to sample-type of input file.\n"
	Inf $msg
}

proc CopysfxFormatHelp {} {
	set msg "OUTFILE FORMATS\n"	
	append msg "\n"
	append msg "0  :  16 bit integers (shorts)\n"
	append msg "1  :  16 bit integers (shorts)\n"
	append msg "2  :  32 bit integers (longs)\n"
	append msg "3  :  32 bit floating-point\n"
	append msg "4  :  24 bit integer 'packed'\n"
	append msg "5  :  16 bit integers (shorts)\n"
	append msg "6  :  32 bit integers (longs)\n"
	append msg "7  :  32 bit floating-point\n"
	append msg "8  :  24 bit integer 'packed'\n"
	append msg "\n"
	append msg "Defaults to sample-type of input file.\n"
	Inf $msg
}
