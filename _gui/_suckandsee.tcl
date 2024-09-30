#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD 30 June 2013
# ... fixup button rectangles

#*******************************************************
#*	TRYING OUT PROGRAMS, USING A RANGE OF PARAM VALUES *
#*******************************************************

proc Suckit {pcnt gcnt} {
	global pr_suck pprg mmod prm parname actvlo actvhi sucklo suckhi suckstep suckfile wstk evv 
	global sucklist suckcopies suckcopynames ins bulk gdg_typeflag resetsuck sucklog suckno sucklogratio
	global CDPidrun prg_dun prg_abortd program_messages prmgrd chlist oldsuckfile

	set origsuckstep ""
	set sucklog 0
	set resetsuck ""
	catch {unset sucklogratio}
	catch {unset oldsuckfile}
	if {$ins(create) || $ins(run)} {
		Inf "\"*\" Cannot Be Used With Instruments"
		return
	}
	if {$bulk(run)} {
		Inf "\"*\" Cannot Be Used In Bulk Processing Mode"
		return
	}
	if {[IsStandalonePrognoWithNonCDPFormat $pprg]} {
		Inf "\"*\" Cannot Be Used With This Program (Program Cmdline Has Non-CDP Format)"
		return
	}
	switch -regexp -- $gdg_typeflag($gcnt) \
		^$evv(CHECKBUTTON)$ - \
		^$evv(TIMETYPE)$ - \
		^$evv(SRATE_GADGET)$ - \
		^$evv(MIDI_GADGET)$ - \
		^$evv(OCT_GADGET)$ - \
		^$evv(CHORD_GADGET)$ - \
		^$evv(DENSE_GADGET)$ - \
		^$evv(TWOFAC)$ - \
		^$evv(WAVETYPE)$ - \
		$evv(GENERICNAME)$ - \
		^$evv(VOWELS)$ - \
		^$evv(STRING_A)$ - \
		^$evv(STRING_B)$ - \
		^$evv(STRING_C)$ - \
		^$evv(STRING_D)$ - \
		^$evv(STRING_E)$ - \
		^$evv(FILENAME)$ - \
		^$evv(OPTIONAL_FILE)$ - \
		^$evv(SWITCHED)$ {
			Inf "\"*\" Cannot Be Used In Parameter [StripName $parname($gcnt)]"
			return
		}

	if {![CheckOtherParamsForSuck $gcnt]} {
		return
	}
	catch {unset suckcopies}
	catch {unset suckcopynames}
	set f .suck
	if [Dlg_Create $f "Suck It and See" "set pr_suck 0" -borderwidth $evv(BBDR) -width 56] {
		frame $f.0
		button $f.0.quit -text Close -command "set pr_suck 0" -highlightbackground [option get . background {}]
		button $f.0.run  -text Run -command "set pr_suck 1"
		pack $f.0.run -side left
		pack $f.0.quit -side right
		pack $f.0 -side top -fill x -expand true -pady 1
		frame $f.00
		button $f.00.play -text "Play Selected File" -command PlaySuck -highlightbackground [option get . background {}]
		button $f.00.ksnd -text "Keep Sound" -command GetSuckSound -highlightbackground [option get . background {}]
		button $f.00.keep -text "Use Param Val" -command "GetSuckParam $pcnt $gcnt" -highlightbackground [option get . background {}]
		button $f.00.list -text "Add Param Val to List" -command ListSuckParam -highlightbackground [option get . background {}]
		label $f.00.lname -text "Filename "
		entry $f.00.snam -textvariable suckfile -width 24
		button $f.00.kall -text "Keep All Snds" -command GetAllSuckSounds -highlightbackground [option get . background {}]
		pack $f.00.play $f.00.ksnd $f.00.keep $f.00.list $f.00.lname $f.00.snam $f.00.kall -side left -pady 2 -padx 4
		pack $f.00 -side top -fill x -expand true -pady 2

		frame $f.1
		label $f.1.pnam -text "" -width 120
		pack $f.1.pnam -side top
		pack $f.1 -side top -pady 1
		frame $f.2
		label $f.2.lo -text "Min Val " 
		entry $f.2.elo -textvariable sucklo -width 12
		label $f.2.hi -text " Max Val " 
		entry $f.2.ehi -textvariable suckhi -width 12
		pack $f.2.lo $f.2.elo $f.2.hi $f.2.ehi -side left -padx 2
		pack $f.2 -side top -pady 1
		frame $f.3
		label $f.3.step -text "Size of Step between values" 
		entry $f.3.estep -textvariable suckstep -width 12
		checkbutton $f.3.log -variable sucklog -text "Logarithmic"
		pack $f.3.step $f.3.estep $f.3.log -side left -pady 2 -padx 2
		pack $f.3 -side top -pady 1
		frame $f.4
		set sucklist [Scrolled_Listbox $f.4.listing -width 24 -height 32 -selectmode single]
		pack $f.4.listing -side top -fill both -expand true
		pack $f.4 -side top -pady 1
#		wm resizable $f 0 0
		bind $f <Return> {set pr_suck 1}
		bind $f <Escape> {set pr_suck 0}
	}
	if {($gdg_typeflag($gcnt) == $evv(LOG)) || ($gdg_typeflag($gcnt) == $evv(PLOG)) || ($gdg_typeflag($gcnt) == $evv(LOGNUMERIC))} {
		$f.3.step config -text "NUMBER of STEPS between values"
		$f.3.log config -state normal
		set sucklog 1
		set suckno 1
	} else {
		$f.3.step config -text "SIZE of STEPS between values"
		$f.3.log config -state normal
		set sucklog 0
		$f.3.log config -state disabled
		set suckno 0
	}
	$sucklist delete 0 end
	$f.0.run config -state normal -command "set pr_suck 1" -text "Run"
	$f.00.play config -text "" -bd 0 -state disabled
	$f.00.keep config -text "" -bd 0 -state disabled
	$f.00.ksnd config -text "" -bd 0 -state disabled
	$f.00.list config -text "" -bd 0 -state disabled
	$f.00.lname config -text ""
	$f.00.snam config -bd 0 -state disabled -disabledbackground [option get . activebackground {}]
	$f.00.kall config -text "" -bd 0 -state disabled
	set minval $actvlo($pcnt)
	set maxval $actvhi($pcnt)
	set name [string trim $parname($gcnt)]
	set name [string range $name 0 31]
	set name [split $name "_"]
	$f.1.pnam config -text "$name"
	set sucklo $minval
	set suckhi $maxval
	wm deiconify $f
	raise $f
	update idletasks
	StandardPosition2 $f
	set pr_suck 0
	set finished 0
	My_Grab 0 $f pr_suck $f.3.estep 
	while {!$finished} {
		set suckstep $origsuckstep
		tkwait variable pr_suck
		switch -- $pr_suck {
			2 {
				DeleteAllTemporaryFiles
				$sucklist delete 0 end
				$f.0.run config -text Run -command "set pr_suck 1"
				$f.00.play config -text "" -bd 0 -state disabled
				$f.00.keep config -text "" -bd 0 -state disabled
				$f.00.ksnd config -text "" -bd 0 -state disabled
				$f.00.list config -text "" -bd 0 -state disabled
				$f.00.lname config -text ""
				$f.00.snam config -bd 0 -state disabled
				$f.00.kall config -text "" -bd 0 -state disabled
				if {[string length $suckfile] >= 0} {
					set oldsuckfile $suckfile
					set suckfile ""
				} else {
					catch {unset oldsuckfile}
				}
				catch {unset suckcopies}				
				catch {unset suckcopynames}
				continue
			}
			1 {
				if {([string length $suckhi] <= 0) || ![IsNumeric $suckhi]} {
					Inf "Invalid Max Value"
					continue
				}
				if {($suckhi > $maxval) || ($suckhi < $minval) } {
					Inf "Max Value Out Of Range"
					continue
				}
				if {([string length $sucklo] <= 0) || ![IsNumeric $sucklo]} {
					Inf "Invalid Min Value"
					continue
				}
				if {($sucklo > $maxval) || ($sucklo < $minval) } {
					Inf "Min Value Out Of Range"
					continue
				}
				if {[Flteq $suckhi $sucklo]} {
					Inf "Max And Min Values Are Equal"
					continue
				}
				if {$suckhi < $sucklo} {
					set temp $suckhi
					set suckhi $sucklo
					set sucklo $temp
				}
				set diff [expr $suckhi - $sucklo]
				set origsuckstep $suckstep 
				if {([string length $suckstep] <= 0) || ![IsNumeric $suckstep]} {
					Inf "Invalid Step Value"
					continue
				}
				if {$suckno} {
					if {![regexp {^[0-9]+$} $suckstep] || ($suckstep < 2)} {
						Inf "Invalid Number Of Steps"
						continue
					}
					set outest $suckno
					if {!$sucklog} {
						set origsuckstep $suckstep
						set suckstep [expr double($diff) / double($suckstep)]
					}
				} else { 
					if {$suckstep > $diff} {
						Inf "Step Value Too Large For Max And Min Given"
						continue
					}
					if {$suckstep <= $evv(FLTERR)} {
						Inf "Invalid Step Value"
						continue
					}
					set outest [expr int(round(double($diff)/double($suckstep))) + 1]
				}
				if {$outest > 100} {
					set msg "This Will Produce $outest Outfiles: Do You Want To Proceed ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
				}
				set file_ext [GetProcessOutfileExtension $pprg $mmod]
				set cmd [AssembleGenericCmdline]
				if {[string length $cmd] <= 0} {
					continue
				}
				set outfilepos [lindex $cmd 0]
				set parampos [lindex $cmd 1]
				set cmd [lrange $cmd 2 end]
				set cnt 0
				set val $sucklo
				Block "Creating Files"
				while {$val < $suckhi} {
					if {($val <= 0.0) && [ZeroOutfileDuration $pcnt]} {
						set val [GetNextSuckVal $val $suckstep $sucklog]
						continue
					}
					set thisparam [lindex $cmd $parampos]
					set k [string first "\*" $thisparam]
					if {$k > 0} {
						incr k -1
						set thisparam [string range $thisparam 0 $k]
						append thisparam $val
					} else {
						set thisparam $val
					}
					set thiscmd [lreplace $cmd $parampos $parampos $thisparam]
					set ofnam $evv(DFLT_OUTNAME)
					append ofnam $cnt $file_ext
					set thiscmd [lreplace $thiscmd $outfilepos $outfilepos $ofnam]
					set CDPidrun 0
					set prg_dun 0
					set prg_abortd 0
					wm title .blocker "PLEASE WAIT:     Creating File [expr $cnt + 1] of $outest"
					if [catch {open "|$thiscmd"} CDPidrun] {
						Inf "$CDPidrun :\nCan't Run Program For Value $val"
						$sucklist insert end "#"
						set val [expr $val + $suckstep]
`						incr cnt
						continue
					} else {
	   					fileevent $CDPidrun readable "Display_Score_Batch_Running_Info"
					}
					vwait prg_dun
					if {$prg_abortd} {
						set prg_dun 0
					}
					if {!$prg_dun} {
						$sucklist insert end "#"
						Inf "Can't Create Output For Value $val"
						set bobo 1
					}
					if [info exists program_messages] {
						Inf "$program_messages"
						unset program_messages
					}
					if {![info exists bobo]} {
						$sucklist insert end $val
					} else {
						unset bobo
					}
					set val [GetNextSuckVal $val $suckstep $sucklog]
					incr cnt
				}
				UnBlock
				$f.00.play config -text "Play Selected File" -bd 2 -state normal
				$f.00.keep config -text "Use Param Val" -bd 2 -state normal
				$f.00.ksnd config -text "Keep Sound" -bd 2 -state normal
				$f.00.list config -text "Add Param Val to List" -bd 2 -state normal
				$f.00.lname config -text "Filename "
				$f.00.snam config -bd 2 -state normal
				if {![info exists oldsuckfile]} {
					if {[info exists chlist] && ([llength $chlist] == 1)} {
						set suckfile [file rootname [file tail [lindex $chlist 0]]] 
					}
				} else {
					set suckfile $oldsuckfile
				}
				$f.00.kall config -text "Keep All Snds" -bd 2 -state normal
				$f.0.run config -text "ReStart" -command "set pr_suck 2"
				continue
			}
			0 {
				set finished 1
			}
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc PlaySuck {} {
	global sucklist evv
	set i [$sucklist curselection]
	if {![info exists i] || ($i < 0)} {
		Inf "No Value Selected"
		return
	}
	if {[string match "#" [$sucklist get $i]]} {
		Inf "No Value Selected"
		return
	}
	set fnam $evv(DFLT_OUTNAME)
	append fnam $i $evv(SNDFILE_EXT)
	if {![file exists $fnam]} {
		Inf "File Corresponding To This Param Value Does Not Exist"
		return
	}
	PlaySndfile $fnam 0
}

proc GetSuckParam {pcnt gcnt} {
	global prm pr_suck sucklist prmgrd resetsuck
	set i [$sucklist curselection]
	if {![info exists i] || ($i < 0)} {
		Inf "No Value Selected"
		return
	}
	set val [$sucklist get $i]
	if {[string match "#" $val]} {
		Inf "No Value Selected"
		return
	}
	set resetsuck $val
	set pr_suck 0
}

proc GetSuckSound {} {
	global sucklist suckfile suckcopies suckcopynames wstk evv last_outfile
	set i [$sucklist curselection]
	if {![info exists i] || ($i < 0)} {
		Inf "No Value Selected"
		return
	}
	if {[string match "#" [$sucklist get $i]]} {
		Inf "No Value Selected"
		return
	}
	if {[info exists suckcopies]} {
		set k [lsearch $suckcopies $i]
		if {$k >= 0} {
			Inf "You Have Already Copied This Sound As [lindex $suckcopynames $k]"
			return
		}
	}
	set fnam $evv(DFLT_OUTNAME)
	append fnam $i $evv(SNDFILE_EXT)
	if {![file exists $fnam]} {
		Inf "File Corresponding To This Param Value Does Not Exist"
		return
	}
	if {[string length $suckfile] <= 0} {
		Inf "No Filename Entered"
		return
	}
	if {![ValidCDPRootname $suckfile]} { 
		return
	}
	set nufnam [string tolower $suckfile]
	append nufnam $evv(SNDFILE_EXT)
	if {[file exists $nufnam]} {
		Inf "File With This Name Already Exists: Please Choose A Different Name"
		return
	}
	if [catch {file copy $fnam $nufnam} zit] {
		Inf "Cannot Save The File With This Name"
		return
	}
	FileToWkspace $nufnam 0 0 0 0 1
	set last_outfile $nufnam
	Inf "File $nufnam Is Now On The Workspace"
	lappend suckcopies $i
	lappend suckcopynames $nufnam
}

proc GetAllSuckSounds {} {
	global sucklist suckfile suckcopies suckcopynames pr_suck pa wstk evv last_outfile

	if {[string length $suckfile] <= 0} {
		Inf "No Filename Entered"
		return
	}
	if {![ValidCDPRootname $suckfile]} { 
		return
	}
	set i 0
	set badfiles 0
	while {$i < [$sucklist index end]} {
		set fnam $evv(DFLT_OUTNAME)
		append fnam $i 
		if {$i == 0} {
			foreach zfnam [glob -nocomplain $fnam*] {
				set ext [file extension $zfnam]
				break
			}
		}
		append fnam $ext
		if {![file exists $fnam]} {
			incr badfiles
		} else {
			lappend orignames $fnam
			lappend parvals [$sucklist get $i]
		}
		incr i
	}
	if {![info exists orignames]} {
		Inf "No Files To Save"
		return
	}
	if {$badfiles > 0} {
		if {$badfile == 1} {
			set msg "One File, Corresponding To A Particular Param Value, Does Not Exist\n\nSave The Rest ??"
		} else {
			set msg "$badfiles Files, Corresponding To Particular Param Values, Do Not Exist\n\nSave The Rest ??"
		}
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		}
	}
	set len [llength $parvals]
	set n 0
	while {$n < $len} {
		set parval [lindex $parvals $n]
		set plen [string length $parval]
		set k 0
		set nupar ""
		while {$k < $plen} {
			set thischar [string index $parval $k]
			if {[string match "." $thischar]} {
				set thischar "p"
			}
			append nupar $thischar
			incr k
		}
		set parvals [lreplace $parvals $n $n $nupar]
		incr n
	}
	set firstfile [lindex $orignames 0]
	set pa($firstfile,$evv(FTYP)) [FindFileType $firstfile]
	set ext [GetFileExtension $firstfile]
	unset pa($firstfile,$evv(FTYP))
	foreach fnam $orignames parval $parvals {
		set nuname $suckfile
		append nuname "_" $parval $ext
		if [file exists $nuname] {
			Inf "Some Files Exist Using Some Of These Names: Chose A Different Generic Name"
			return
		}
		lappend nunames $nuname
	}
	Block "Saving Files"
	foreach fnam $orignames nufnam $nunames {
		wm title .blocker "PLEASE WAIT:      SAVING FILE '$nufnam'"
		if [catch {file copy $fnam $nufnam} zit] {
			Inf "Cannot Save File $nufnam"
		} else {
			FileToWkspace $nufnam 0 0 0 0 1
			lappend outts $nufnam
		}
	}
	if {[info exists outts]} {
		set last_outfile $outts
	}
	UnBlock
	Inf "Output Files Are Now On The Workspace"
	set suckfile ""
	set pr_suck 0
}

proc ListSuckParam {} {
	global sucklist suckfile wstk evv
	set i [$sucklist curselection]
	if {![info exists i] || ($i < 0)} {
		Inf "No Value Selected"
		return
	}
	if {[string match "#" [$sucklist get $i]]} {
		Inf "No Value Selected"
		return
	}
	if {[string length $suckfile] <= 0} {
		Inf "No Filename Entered"
		return
	}
	if {![ValidCDPRootname $suckfile]} { 
		return
	}
	set nufnam [string tolower $suckfile]
	append nufnam $evv(TEXT_EXT)
	if {[file exists $nufnam]} {
		set msg "Append Param Value To Values In Existing File $nufnam ?"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		}
		if [catch {open $nufnam a} fileId] {
			Inf "Cannot Open File To Append Param Value"
			return
		}
	} else {
		if [catch {open $nufnam w} fileId] {
			Inf "Cannot Open File To Write Param Value"
			return
		}
		FileToWkspace $nufnam 0 0 0 0 1
		Inf "File $nufnam Is Now On The Workspace"
	}
	puts $fileId [$sucklist get $i]
	close $fileId
}

proc CheckOtherParamsForSuck {g_cnt} {
	global parname gdg_typeflag gdg_cnt prm evv
	global zz_secs_lo zz_samps_lo zz_stsamps_lo zz_srate_here
	global zz_chans_here zz_secs_hi	zz_samps_hi	zz_stsamps_hi timetype_altered timetype
	global actvlo actvhi

	set pcnt 0 
	set gcnt 0
	set timetype_altered 0

	while {$gcnt < $gdg_cnt} {
		if {[IsDeadParam $gcnt]} {
			incr gcnt
			incr pcnt
			continue
		}
		set gtype $gdg_typeflag($gcnt)
		if {$gcnt != $g_cnt} {
			set par_name [StripName	$parname($gcnt)]
 			if {![CheckRecalledParamValSuck $pcnt $gcnt $gtype $par_name]} {
				return 0
			}
			if {$timetype_altered} {				;#	Reset ranges of affected params
				switch -regexp -- $timetype \
					^$evv(EDIT_SECS)$    {ResetFadeRanges $zz_secs_lo    $zz_secs_hi    $zz_srate_here $zz_chans_here secs 0} \
					^$evv(EDIT_SAMPS)$   {ResetFadeRanges $zz_samps_lo   $zz_samps_hi   $zz_srate_here $zz_chans_here samps 1} \
					^$evv(EDIT_STSAMPS)$ {ResetFadeRanges $zz_stsamps_lo $zz_stsamps_hi $zz_srate_here $zz_chans_here stsmps 2}

				set i 0
				while {$i < $gdg_cnt} {							;#	Reset values of affected params
					if {($gtype == $evv(NUMERIC)) && [string match *FADE* $parname($i)]} {
						if  {$prm($i) < $actvlo($i) || $prm($i) > $actvhi($i)} {
							Inf "parameter $parname($i) ($prm($i)) out of range"
							return 0
						}
					}
					incr i
				}
			}
		}
		if {$gtype == $evv(SWITCHED)} {
			incr pcnt
		}
		incr gcnt
		incr pcnt
	}
	return 1
}

proc CheckRecalledParamValSuck {pcnt gcnt gtype par_name} {
	global prm dfault1 dfault2 actvhi actvlo lo hi sublo subhi wl
	global canhavefiles timetype_altered pprg pa evv
	global timetype zz_secs_lo zz_samps_lo zz_stsamps_lo zz_srate_here
	global zz_chans_here zz_secs_hi	zz_samps_hi	zz_stsamps_hi
	global secslo sampslo stsampslo sratehere chanshere secshi sampshi stsampshi

	switch -regexp -- $gtype \
		^$evv(CHECKBUTTON)$ {
			switch -- $prm($pcnt) {
				0 -
				1 {}
				default {
					Inf "Parameter $par_name : Invalid Switch Value ($prm($pcnt))."
					return 0
				}
			}
		} \
		^$evv(TIMETYPE)$ {
			switch -- $prm($pcnt) {
				0	-
				1	-
				2	{}
				default {
					Inf "Parameter $par_name : Invalid Switch Parameter Value ($prm($pcnt))."
					return 0
				}
			}
			set timetype 		$prm($pcnt)		;#	set the timetype flag
			set timetype_altered 1
			set zz_secs_lo		$secslo($pcnt)		;#	and remember the relevant variables
			set zz_samps_lo		$sampslo($pcnt)
			set zz_stsamps_lo	$stsampslo($pcnt)
			set zz_srate_here	$sratehere($pcnt)
			set zz_chans_here	$chanshere($pcnt)
			set zz_secs_hi		$secshi($pcnt)
			set zz_samps_hi		$sampshi($pcnt)
			set zz_stsamps_hi	$stsampshi($pcnt)
		} \
		^$evv(SRATE_GADGET)$ {
			set here [string first  "." $prm($pcnt)] 		;#	Deal with SRATE expressed as a double
			if {$here > 0} {
				incr here -1
				set prm($pcnt) [string range $prm($pcnt) 0 $here]
			}
			switch -- $prm($pcnt) {
				16000 -
				22050 -
				24000 -
				32000 -
				44100 -
				48000 {}
				default {
					Inf "Parameter $par_name : Invalid value ($prm($pcnt))."
					return 0
				}
			}
		} \
		^$evv(MIDI_GADGET)$ {
			set here [string first  "." $prm($pcnt)] 		;#	Deal with MIDIVAL expressed as a double
			if {$here > 0} {
				incr here -1
				set prm($pcnt) [string range $prm($pcnt) 0 $here]
			}
			if {$prm($pcnt) < 0 || $prm($pcnt) > 11} {
				Inf "Parameter $par_name : Invalid Value ($prm($pcnt))."
				return 0
			}
		} \
		^$evv(OCT_GADGET)$ {
			set here [string first  "." $prm($pcnt)] 		;#	Deal with OCTVAL expressed as a double
			if {$here > 0} {
				incr here -1
				set prm($pcnt) [string range $prm($pcnt) 0 $here]
			}
			if {$prm($pcnt) < -4 || $prm($pcnt) > 4} {
				Inf "Parameter $par_name : Invalid Value ($prm($pcnt))."
				return 0
			}
		} \
		^$evv(CHORD_GADGET)$ {
			set here [string first  "." $prm($pcnt)] 		;#	Deal with CHORDVAL expressed as a double
			if {$here > 0} {
				incr here -1
				set prm($pcnt) [string range $prm($pcnt) 0 $here]
			}
			if {$prm($pcnt) < 0 || $prm($pcnt) > 9} {
				Inf "Parameter $par_name : Invalid Value ($prm($pcnt))."
				return 0
			}
		} \
		^$evv(DENSE_GADGET)$ {
			set here [string first  "." $prm($pcnt)] 		;#	Deal with CHORDVAL expressed as a double
			if {$here > 0} {
				incr here -1
				set prm($pcnt) [string range $prm($pcnt) 0 $here]
			}
			if {$prm($pcnt) < 0 || $prm($pcnt) > 3} {
				Inf "Parameter $par_name : Invalid Value ($prm($pcnt))."
				return 0
			}
		} \
		^$evv(TWOFAC)$ {
			set here [string first  "." $prm($pcnt)] 		;#	Deal with TWOFAC expressed as a double
			if {$here > 0} {
				incr here -1
				set prm($pcnt) [string range $prm($pcnt) 0 $here]
			}
			switch -- $prm($pcnt) {
				1  -
				2  -
				4  -
				8  -
				16 -
				32 {}
				default {
					Inf "Parameter $par_name : Invalid Value ($prm($pcnt))."
					return 0
				}
			}
		} \
		^$evv(POWTWO)$ {
			set here [string first  "." $prm($pcnt)] 		;#	Deal with TWOFAC expressed as a double
			if {$here > 0} {
				incr here -1
				set prm($pcnt) [string range $prm($pcnt) 0 $here]
			}
			switch -- $prm($pcnt) {
				1  -
				2  -
				4  -
				8  -
				16 -
				32 -
				64 -
				128 -
				256 -
				512 -
				1024 -
				2048 -
				4096 -
				8192 -
				16380 {}
				default {
					Inf "Parameter $par_name : Invalid Value ($prm($pcnt))."
					return 0
				}
			}
		} \
		^$evv(WAVETYPE)$ {
			set here [string first  "." $prm($pcnt)] 		;#	Deal with WAVETYPE expressed as a double
			if {$here > 0} {
				incr here -1
				set prm($pcnt) [string range $prm($pcnt) 0 $here]
			}
			switch -- $prm($pcnt) {
				1 -
				2 -
				3 -
				4 {}
				default {
					Inf "Parameter $par_name : Invalid Value ($prm($pcnt))."
					return 0
				}
			}
		} \
		$evv(GENERICNAME)$ {
			set prm($pcnt) [string tolower $prm($pcnt)]
			if {![ValidCDPRootname $prm($pcnt)]} {
				Inf "Parameter $par_name : Invalid Filename $prm($pcnt)."
				return 0
			}
		} \
		^$evv(VOWELS)$ {
			set prm($pcnt) [string tolower $prm($pcnt)]
			if {![ValidVowelName $prm($pcnt)]} {
				if {![file exists $prm($pcnt)] || [file isdirectory $prm($pcnt)]} { 
					Inf "Parameter $par_name : Invalid Vowel-Name, Or Non-Existent File $prm($pcnt)."
					return 0
				}
			}
		} \
		^$evv(STRING_A)$ {
			if {![ValidStringA $prm($pcnt) $gcnt]} {
				return 0
			}
		} \
		^$evv(STRING_B)$ {
			if {![ValidStringB $prm($pcnt) $gcnt]} {
				return 0
			}
		} \
		^$evv(STRING_C)$ {
			if {![ValidStringC $prm($pcnt) $gcnt]} {
				return 0
			}
		} \
		^$evv(STRING_D)$ {
			if {![ValidStringD $prm($pcnt) $gcnt]} {
				return 0
			}
		} \
		^$evv(STRING_E)$ {
			if {![ValidStringE $prm($pcnt) $gcnt]} {
				return 0
			}
		} \
		^$evv(LINEAR)$ 		-	\
		^$evv(LOG)$ 		-	\
		^$evv(PLOG)$ 		-	\
		^$evv(FILE_OR_VAL)$ -	\
		^$evv(LOGNUMERIC)$ -	\
		^$evv(NUMERIC)$ {
			if [IsNumeric $prm($pcnt)] {
				if {($prm($pcnt) > $actvhi($pcnt)) || ($prm($pcnt) < $actvlo($pcnt))} {
					Inf "Parameter $par_name : Value ($prm($pcnt)) Is Out Of Range."
					return 0
				}
			} elseif {$canhavefiles($pcnt)} {
				set prm($pcnt) [string tolower $prm($pcnt)]
				set thisfilename $prm($pcnt)
				if {![file exists $thisfilename] || [file isdirectory $thisfilename]} {
					Inf "Parameter $par_name : File $prm($pcnt) No Longer Exists."
					return 0											
				} elseif {![string match $gtype $evv(FILE_OR_VAL)]} {
					if {[set ii [LstIndx $prm($pcnt) $wl]] < 0} {
						Inf "Parameter $par_name : The File $prm($pcnt) Is Not Loaded On The Workspace."
						return 0
					} elseif {$pa($prm($pcnt),$evv(MAXBRK)) > $actvhi($pcnt) ||  $pa($prm($pcnt),$evv(MINBRK)) < $actvlo($pcnt)} {
						Inf "Parameter $par_name : Values In File $prm($pcnt) Are Out Of Range."
						return 0
					}
				}
			} else {
				Inf "Parameter $par_name : Numeric Values Only."
				return 0
			}
		} \
		^$evv(FILENAME)$ {
			set prm($pcnt) [string tolower $prm($pcnt)]
			set thisfilename $prm($pcnt)
			if {($pprg == $evv(P_INVERT)) && [string match $prm($pcnt) "0"]} {
				return 1
			} elseif {![file exists $thisfilename] || [file isdirectory $thisfilename]} {
				Inf "Parameter $par_name : File $prm($pcnt) No Longer Exists."
				return 0
			}
		} \
		^$evv(OPTIONAL_FILE)$ {
			set prm($pcnt) [string tolower $prm($pcnt)]
			set thisfilename $prm($pcnt)
			if {[string match $prm($pcnt) "0"]} {
				return 1
			} elseif {![file exists $thisfilename] || [file isdirectory $thisfilename]} {
				Inf "Parameter $par_name : File $prm($pcnt) No Longer Exists."
				return 0
			}
		} \
		^$evv(SWITCHED)$ {
			set wasbadswitch 0
			switch -- $prm($pcnt) {
				0 -
				1 {}
				default {
					Inf "Parameter $par_name : Invalid Switch Value."
					return 0
				}
			}
			set paramswitch $pcnt
			set origswitchstate prm($paramswitch)
			incr pcnt
			set origval $prm($pcnt)
			ToggleGadget $gcnt $paramswitch $pcnt $lo($pcnt) $hi($pcnt) $dfault1($pcnt) $sublo($pcnt) $subhi($pcnt) $dfault2($pcnt)	
			if {($origval > $actvhi($pcnt)) || ($origval < $actvlo($pcnt))} {
				set prm($paramswitch) [expr !$origswitchstate]
				ToggleGadget $gcnt $paramswitch $pcnt $lo($pcnt) $hi($pcnt) $dfault1($pcnt) $sublo($pcnt) $subhi($pcnt) $dfault2($pcnt)	
				if {($origval > $actvhi($pcnt)) || ($origval < $actvlo($pcnt))} {
					Inf "$par_name value ($origval) is out of range in this case."
				} else {
					Inf "$par_name value ($origval) is out of range for the switch option chosen."
				}
				set prm($paramswitch) $origswitchstate
				ToggleGadget $gcnt $paramswitch $pcnt $lo($pcnt) $hi($pcnt) $dfault1($pcnt) $sublo($pcnt) $subhi($pcnt) $dfault2($pcnt)	
				set prm($pcnt) $origval
				return 0
			} else {
				set prm($pcnt) $origval
			}
		}

	return 1
}

#------ Create a generic cmdline for the SuckSee operations

proc AssembleGenericCmdline {} {
	global prg pprg mmod chlist prm pmcnt if float_out evv submixversion filter_version

	if {$pprg == $evv(MIXBALANCE)} {
		if {$submixversion < 7} {
			set dur $pa([lindex $chlist 0],$evv(DUR))
			set maxdur $dur
			foreach fnam [lrange $chlist 1 end] {
				if {$pa($fnam,$evv(DUR)) > $maxdur} {
					set maxdur $pa($fnam,$evv(DUR))
					set maxfile $fnam
				}
			}
			if {$maxdur > $dur} {
				Inf "For This Process, Put The Longest File ($maxfile) First In The List Of Files."
				return ""
			}
		}
	}
	set cmdcnt 0
	set cmd [file join $evv(CDPROGRAM_DIR) [string tolower [lindex $prg($pprg) $evv(UMBREL_INDX)]]]
	incr cmdcnt
	if [ProgMissing $cmd "CANNOT PERFORM THIS PROCESS"] {
		return ""
	}
	set progname [GetBatchProgname $pprg]
	lappend cmd $progname								;#	Program number
	incr cmdcnt
	if {$mmod > 0} {
		lappend cmd $mmod		 						;#	Mode number
		incr cmdcnt
	}
	if [info exists chlist] {
		set infilecnt [llength $chlist]					;#	Number of input files 
	} else {
		set infilecnt 0
	}
	set bailout [CheckCrypto]
	if {$bailout} {
		set infilecnt 1
	}
	if {$infilecnt > 0} {								;#	If there are any infiles
		foreach fnam [lrange $chlist 0 end] { 			;# 	And Names of all the input files
			lappend cmd $fnam
			incr cmdcnt
			if {$bailout} {
				break
			}
		}
	}
	set outfilepos $cmdcnt
	if {$float_out} {
		set out_name $evv(FLOAT_OUT)
		append out_name $evv(DFLT_OUTNAME)
	} else {
		set out_name $evv(DFLT_OUTNAME)
	}
	lappend cmd $out_name
	incr cmdcnt
	if {$pmcnt > 0} {
		set i 0
		while {$i < $pmcnt} {
			set len [string length $prm($i)]
			incr len -1
			set kk [string first "\*" $prm($i)]
			if {($kk >= 0) && ($kk == $len)} {
				if {[info exists parampos]} {
					Inf "Programming Problem (1) IN AssembleGenericCmdline()"
					return ""
				}
				set parampos $cmdcnt
			}
 			lappend cmd $prm($i)
			incr i
			incr cmdcnt
		}
	}
	if {![info exists parampos]} { 
		Inf "Programming Problem (2) IN AssembleGenericCmdline()"
		return ""
	}
	if {$pprg == $evv(FLTBANKV)} {		;#	Extra SLOOM Param from dropout on overflow, lose it for batchfiling
		set len [llength $cmd]
		if {$filter_version < 7} {
			incr len -3
			set cmd [lrange $cmd 0 $len]
		}
	}
	set cmd [SetupBatchcmdFlagLetters $cmd]		;#	Get correct flags
	set cmd [SetupFormantFlagLettersEtc $cmd]
	return [concat $outfilepos $parampos $cmd]	;# Positions of outfilename && "*" are added to start of constructed cmdline
}

proc ZeroOutfileDuration {pcnt} {
	global pprg mmod evv
	set thismode $mmod
	incr thismode -1
	switch -regexp -- $pprg \
		^$evv(DRUNK)$ {
			if {$pcnt == 0} {
				return 1
			}
		} \
		^$evv(ENV_CURTAILING)$ {
			if {$pcnt == 1} {
				switch -- $thismode {
					0 -
					1 -
					3 -
					4 {
						return 1
					}
				}
			}
		} \
		^$evv(LOOP)$ {
			if {($thismode == 1) && ($pcnt == 0)} {
				return 1
			}
		} \
		^$evv(SCRAMBLE)$ {
			if {$pcnt == 2} {
				return 1
			}
		} \
		^$evv(SIMPLE_TEX) - \
		^$evv(TEX_MCHAN)  - \
		^$evv(GROUPS)	  - \
		^$evv(DECORATED)  - \
		^$evv(PREDECOR)	  - \
		^$evv(POSTDECOR)  - \
		^$evv(ORNATE)	  - \
		^$evv(PREORNATE)  - \
		^$evv(POSTORNATE) - \
		^$evv(MOTIFS)	  - \
		^$evv(MOTIFSIN)	  - \
		^$evv(TIMED)	  - \
		^$evv(TGROUPS)	  - \
		^$evv(TMOTIFS)	  - \
		^$evv(TMOTIFSIN) {
			if {$pcnt == 1} {
				return 1
			}
		}

	return 0
}

proc GetNextSuckVal {val step log} {
	global sucklogratio suckhi sucklo
	if {!$log} {
		return [expr $val + $step]
	}
	if {![info exists sucklogratio]} {
		set logdiff [expr log(double($suckhi)/double($sucklo))]
		set sucklogratio [expr exp($logdiff / double($step))]
	}	
	return [expr $val * $sucklogratio]
}

#######################
#      FEATURES       #
#######################

proc Features {} {
	global wl pa evv feattype pr_feat featcan
	global featlo feathi featstep featscanwin featpkcnt featmin featmax featerr featurecnt feattail featsplic featlong featwcnt featend featinfile
	global lastfeatlo lastfeathi lastfeatstep lastfeatscanwin lastfeatpkcnt lastfeatmin lastfeatmax feattime
	global lastfeaterr lastfeaturecnt lastfeattail lastfeatsplic lastfeatwcnt lastfeatend featlist fe_maxwlen
	global CDPidrun prg_dun prg_abortd featscram speechmode fechwidth fecdiv fecolor featshow fe_pfval fe_pswi fesortbuf

	set featinfile [ValidFeatureFiles]
	if {[string length $featinfile] <= 0} {
		return
	}
	set fe_pfval ""
	set fe_pswi -1
	set speechmode 0
	set evv(FEATURES_WIDTH)	 900
	set evv(FEATURES_HEIGHT) 350
	set evv(DISPLAY_HEIGHT)  300
	set evv(FEMARK_HEIGHT)   4
	set evv(FEPKTOP_OFFSET) [expr $evv(FEMARK_HEIGHT) * 3]
	set evv(FEPKTXT_OFFSET) [expr $evv(FEPKTOP_OFFSET) / 2]
	set evv(FEMARK_TOP) [expr $evv(FEATURES_HEIGHT) - $evv(FEMARK_HEIGHT)]
	set evv(FETEXT_POS) [expr $evv(FEMARK_TOP) - $evv(FEMARK_HEIGHT)]
	set evv(FEOCT_POS)  [expr $evv(FETEXT_POS) - ($evv(FEMARK_HEIGHT) * 3)]
	set evv(FEFRQ_POS)  [expr $evv(FETEXT_POS) - ($evv(FEMARK_HEIGHT) * 6)]

	set evv(FEATSCANWIN_LIM)	[expr $evv(SEMITONES_PER_OCTAVE) * 2]

	;# default vals for params

	set evv(MIN_FE_DUR)		 10		;#	minimum feature length (mS)
	set evv(DFLT_MAX_FE_LEN) 600	;#	default maximum feature length (mS)
	set evv(DFLT_PEAKS_CNT)	 3
	set evv(DFLT_PK_ERROR)	 2.0
	set evv(FE_CNT_TYPICAL)	 40
	set evv(FE_TAILDUR)		 MIN_FE_DUR
	set evv(FE_SPLICELEN)	 5
	set evv(MAJOR_3RD)		 4.0
	set evv(SEMITONE)		 1.0
	set evv(MIDIMINFRQ)		 8.175799
	set evv(MIDIMAXFRQ)		 12543.853951
	set evv(MIDDLE_C_FRQ)	 261.625565
	set evv(FE_MAXWINCNT)	 14
	set evv(FE_DFLTSTEP)	 .25

	;# program modes

	set evv(FE_BEST)	0
	set evv(FE_EVERY)	1
	set evv(FE_ENVEL)	2
	set evv(FE_WINDOWS)	3
	set evv(FE_AVERAGE)	4
	set evv(FE_CHECK)	5

	;#	display colours

	set fecolor(0)	Black 
	set fecolor(1)	grey18
	set fecolor(2)	grey25
	set fecolor(3)	grey31
	set fecolor(4)	grey38
	set fecolor(5)	grey44
	set fecolor(6)	grey51
	set fecolor(7)	grey57
	set fecolor(8)	grey64
	set fecolor(9)	grey72
	set fecolor(10)	grey85
	set fecolor(11)	grey91
	set fecolor(12)	grey96
	set fecolor(13)	grey100


	UnsetFeatureVariables
	set featlong 0
	set feattype -1
	set clength [expr $pa($featinfile,$evv(WANTED))/2]
	set origrate $pa($featinfile,$evv(ORIGRATE))
	set fecdiv [expr $clength - 1]
	;#	there are e.g. 511 full size and 2 half-size chans (clength = 513) : this makes a set of 512 (fecdiv) equal blocks
	set nyq $pa($featinfile,$evv(NYQUIST))
	set fechwidth [expr double($nyq)/$fecdiv]

	set outdata $evv(DFLT_OUTNAME)
	append outdata 0
	append outdata $evv(TEXT_EXT)

	set f .features
#RWD 2023 was "set pr_suck" ...?
	if [Dlg_Create $f "FEATURE EXTRATION" "set pr_feat 0" -borderwidth $evv(BBDR)] {
		frame $f.0
		frame $f.00 -height 1 -bg [option get . foreground {}]
		frame $f.1
		frame $f.11 -height 1 -bg [option get . foreground {}]
		frame $f.2
		frame $f.22 -height 1 -bg [option get . foreground {}]
		frame $f.3
		frame $f.4
		button $f.0.help  -text "Help" -command "TellFeature" -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.0.run   -text "RUN EXTRACTION" -command "set pr_feat 1" -width 24 -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $f.0.test  -text "GO TO DATA TESTING" -command "FeaturesRunOrTest 1" -width 24 -highlightbackground [option get . background {}]
		button $f.0.reset -text "Reset Variables"    -command "ResetFeatureVariables" -width 16 -highlightbackground [option get . background {}]
		button $f.0.dflt  -text "Set Default Vals"   -command "SetFeaturesDefaults" -width 16 -highlightbackground [option get . background {}]
		button $f.0.dfld  -text "Default Durations"  -command "SetFeaturesDurDefaults" -width 16 -highlightbackground [option get . background {}]
		button $f.0.spk   -text "Set Speech Mode" -command "SetSpeechMode" -width 16 -highlightbackground [option get . background {}]
		label $f.0.spk2 -text "SPEECH" -fg [option get . background {}]
		pack $f.0.help $f.0.run $f.0.test $f.0.reset $f.0.dflt $f.0.dfld $f.0.spk $f.0.spk2 -side left -padx 4
		button $f.0.quit -text "Close" -command "set pr_feat 0" -highlightbackground [option get . background {}]
		pack $f.0.quit -side right
		pack $f.0 $f.00 -side top -fill x -expand true -pady 1

		label $f.1.lab -text "EXTRACT FEATURES"
		radiobutton $f.1.best  -text "BEST Example of Each Feature"   -variable feattype -value $evv(FE_BEST)  -command "LongFeatures"
		radiobutton $f.1.all   -text "ALL Examples of (N) Feature(s)" -variable feattype -value $evv(FE_EVERY) -command "LongFeatures"
		radiobutton $f.1.env   -text "SILENCE all except Features"	  -variable feattype -value $evv(FE_ENVEL) -command "LongFeatures"
		pack $f.1.lab $f.1.best $f.1.all $f.1.env -side left
		pack $f.1 -side top -pady 1
		pack $f.11 -side top -fill x -expand true -pady 1
		frame $f.2.1
		frame $f.2.2
		frame $f.2.3
		frame $f.2.1.1
		entry $f.2.1.1.e -textvariable featlo -width 12
		label $f.2.1.1.lab -text "Lowest Frq to search (Hz)"
		pack $f.2.1.1.e $f.2.1.1.lab -side left -anchor w
		frame $f.2.1.2
		entry $f.2.1.2.e -textvariable feathi -width 12
		label $f.2.1.2.lab -text "Highest Frq to search (Hz)"
		pack $f.2.1.2.e $f.2.1.2.lab -side left -anchor w
		frame $f.2.1.3
		entry $f.2.1.3.e -textvariable featstep -width 12
#EQUAL PITCH
#		label $f.2.1.3.lab -text "Step in peak-search (semitones)"
#EQUAL FRQ
		label $f.2.1.3.lab -text "Step in peak-search (Hz)"
		pack $f.2.1.3.e $f.2.1.3.lab -side left -anchor w
		frame $f.2.1.4
		entry $f.2.1.4.e -textvariable featscanwin -width 12
#EQUAL PITCH
#		label $f.2.1.4.lab -text "scan-window size for peak-search (semitones)"
#EQUAL FRQ
		label $f.2.1.4.lab -text "scan-window size for peak-search (Hz)"
		pack $f.2.1.4.e $f.2.1.4.lab -side left -anchor w
		frame $f.2.1.5
		entry $f.2.1.5.e -textvariable featpkcnt -width 12
		label $f.2.1.5.lab -text "Number of peaks to find"
		pack $f.2.1.5.e $f.2.1.5.lab -side left -anchor w
		pack $f.2.1.1  $f.2.1.2  $f.2.1.3  $f.2.1.4  $f.2.1.5 -side top -anchor w

		bind .features.2.1.1.e <Down> "focus .features.2.1.2.e"
		bind .features.2.1.2.e <Down> "focus .features.2.1.3.e"
		bind .features.2.1.3.e <Down> "focus .features.2.1.4.e"
		bind .features.2.1.4.e <Down> "focus .features.2.1.5.e"
		bind .features.2.1.5.e <Down> "focus .features.2.1.1.e"

		bind .features.2.1.1.e <Up>   "focus .features.2.1.5.e"
		bind .features.2.1.2.e <Up>   "focus .features.2.1.1.e"
		bind .features.2.1.3.e <Up>   "focus .features.2.1.2.e"
		bind .features.2.1.4.e <Up>   "focus .features.2.1.3.e"
		bind .features.2.1.5.e <Up>   "focus .features.2.1.4.e"

		frame $f.2.2.1
		entry $f.2.2.1.e -textvariable featmin -width 12
		label $f.2.2.1.lab -text "Minimum size of features to find (mS)"
		pack $f.2.2.1.e $f.2.2.1.lab -side left -anchor w
		frame $f.2.2.2
		entry $f.2.2.2.e -textvariable featmax -width 12
		label $f.2.2.2.lab -text "Maximim size of features to find (mS)"
		pack $f.2.2.2.e $f.2.2.2.lab -side left -anchor w
		frame $f.2.2.3
		entry $f.2.2.3.e -textvariable featerr -width 12
		label $f.2.2.3.lab -text "Acceptable Error in equating peaks (semitones)"
		pack $f.2.2.3.e $f.2.2.3.lab -side left -anchor w
		frame $f.2.2.4
		entry $f.2.2.4.e -textvariable featurecnt -width 12
		label $f.2.2.4.lab -text "Maximum number of features to find"
		pack $f.2.2.4.e $f.2.2.4.lab -side left -anchor w
		frame $f.2.2.5
		entry $f.2.2.5.e -textvariable feattail -width 12
		label $f.2.2.5.lab -text "Sound to keep before & after feature (mS)"
		pack $f.2.2.5.e $f.2.2.5.lab -side left -anchor w
		frame $f.2.2.6
		entry $f.2.2.6.e -textvariable featsplic -width 12
		label $f.2.2.6.lab -text "Splice length for cutting features (mS)"
		pack $f.2.2.6.e $f.2.2.6.lab -side left -anchor w
		pack  $f.2.2.1  $f.2.2.2  $f.2.2.3  $f.2.2.4  $f.2.2.5 $f.2.2.6 -side top -anchor w

		bind .features.2.2.1.e <Down> "focus .features.2.2.2.e"
		bind .features.2.2.2.e <Down> "focus .features.2.2.3.e"
		bind .features.2.2.3.e <Down> "focus .features.2.2.4.e"
		bind .features.2.2.4.e <Down> "focus .features.2.2.5.e"
		bind .features.2.2.5.e <Down> "focus .features.2.2.6.e"
		bind .features.2.2.6.e <Down> "focus .features.2.2.1.e"

		bind .features.2.2.1.e <Up>   "focus .features.2.2.6.e"
		bind .features.2.2.2.e <Up>   "focus .features.2.2.1.e"
		bind .features.2.2.3.e <Up>   "focus .features.2.2.2.e"
		bind .features.2.2.4.e <Up>   "focus .features.2.2.3.e"
		bind .features.2.2.5.e <Up>   "focus .features.2.2.4.e"
		bind .features.2.2.6.e <Up>   "focus .features.2.2.5.e"

		checkbutton $f.2.2.7 -variable featlong -text "Use Longest Features"

		pack  $f.2.2.1  $f.2.2.2  $f.2.2.3  $f.2.2.4  $f.2.2.5 $f.2.2.6 $f.2.2.7 -side top -anchor w

		checkbutton $f.2.3.0 -variable fesortbuf -text "Sort analdata to frq order"
		frame $f.2.3.1
		entry $f.2.3.1.e -textvariable feattime -width 12
		label $f.2.3.1.lab -text "Time at which to extract peaks"
		pack $f.2.3.1.e $f.2.3.1.lab -side left -anchor w
		frame $f.2.3.2
		entry $f.2.3.2.e -textvariable featwcnt  -width 12
		label $f.2.3.2.lab -text "Number of windows to display"
		pack $f.2.3.2.e $f.2.3.2.lab -side left -anchor w
		button $f.2.3.3 -text "" -command {} -bd 0 -highlightbackground [option get . background {}]
		label $f.2.3.4 -text "" -width 16
		frame $f.2.3.5
		radiobutton $f.2.3.5.1 -text "Pitch->Frq" -command "FePitchToFrq" -val 0 -variable fe_pswi
		radiobutton $f.2.3.5.2 -text "Frq->Pitch" -command "FePitchToFrq" -val 1 -variable fe_pswi
		entry $f.2.3.5.3 -textvariable fe_pfval -width 12
		pack $f.2.3.5.1 $f.2.3.5.2 $f.2.3.5.3  -side left -anchor w

		bind .features.2.3.1.e <Down> "focus .features.2.3.2.e"
		bind .features.2.3.2.e <Down> "focus .features.2.3.1.e"
		bind .features.2.3.1.e <Up> "focus .features.2.3.2.e"
		bind .features.2.3.2.e <Up> "focus .features.2.3.1.e"

		pack  $f.2.3.0 $f.2.3.1  $f.2.3.2 $f.2.3.3 $f.2.3.4 $f.2.3.5 -side top -anchor w

		pack $f.2.1 $f.2.2 $f.2.3 -side left -fill x -expand true

		pack $f.2 -side top -fill x -expand true -pady 1
		pack $f.22 -side top -fill x -expand true -pady 1

		set featcan [Sound_Canvas $f.3.c -width $evv(FEATURES_WIDTH) -height $evv(FEATURES_HEIGHT) \
									-scrollregion "0 0 $evv(FEATURES_WIDTH) $evv(FEATURES_HEIGHT)"]

		pack $f.3.c -side top
		pack $f.3 -side top -fill both -expand true

		set featlist [Scrolled_Listbox $f.4.l -width 150 -height 6 -selectmode single]
		pack $f.4.l -side top -fill both -expand true
		pack $f.4 -side top -pady 1

#		wm resizable $f 0 0
		bind $f <Return> {set pr_feat 1}
		bind $f <Escape> {set pr_feat 0}
	}
#EQUAL FRQ
	set featstep $fechwidth
	set featscanwin $evv(FE_WINSIZ_DFLT)
	set feattime $pa($featinfile,$evv(FRAMETIME))
	set fe_maxwlen [expr $pa($featinfile,$evv(WLENGTH)) - 1]
	set featwcnt $fe_maxwlen

#END
	set fesortbuf 1
	$f.2.3.4 config -text "" -bg [option get . background {}]
	FeaturesRunOrTest 0
	$featlist delete 0 end
	catch {$featcan delete drawn} in		;#	destroy any existing graphics
	set pr_feat 0
	raise $f
	update idletasks
	StandardPosition2 $f
	set finished 0
	My_Grab 0 $f pr_feat
	while {!$finished} {
		tkwait variable pr_feat
		if {$pr_feat} {
			catch {$featcan delete drawn} in		;#	destroy any existing graphics
			if {$feattype < 0} {
				Inf "No Process Selected"
				continue
			}
			if {([string length $featlo] <= 0) || ![IsNumeric $featlo]} {
				Inf "No Valid Lowest Frequency Value Entered"
				continue
			}
			if {($featlo <= $evv(MIDIMINFRQ)) || ($featlo >= $evv(MIDIMAXFRQ))} {
				Inf "Invalid Lowest Frequency : Range $evv(MIDIMINFRQ) To $evv(MIDIMAXFRQ)"
				continue
			}
			if {([string length $feathi] <= 0) || ![IsNumeric $feathi] } {
				Inf "No Valid Highest Frequency Value Entered"
				continue
			}
			if {($feathi <= $evv(MIDIMINFRQ)) || ($feathi >= $evv(MIDIMAXFRQ))} {
				Inf "Invalid Highest Frequency : Range $evv(MIDIMINFRQ) To $evv(MIDIMAXFRQ)"
				continue
			}
			if {[expr $feathi - $featlo] < [expr $fechwidth * 2.0]} {
				Inf "Low Frequency And High Frequency Limits Of Search Are Too Close."
				continue
			}
			if {([string length $featstep] <= 0) || ![IsNumeric $featstep]} {
				Inf "No Valid Peak-Search Step Entered"
				continue
			}
#EQUAL PITCH
#			if {($featstep < 0.1) || ($featstep > $evv(SEMITONES_PER_OCTAVE))} {
#				Inf "Peak-search Step Out Of Range (0.1 To $evv(SEMITONES_PER_OCTAVE))"
#				continue
#			}
#EQUAL FRQ
			if {($featstep < $fechwidth) || ($featstep >= $nyq)} {
				Inf "Peak-search Step Out Of Range ($fechwidth To $nyq)"
				continue
			}
#END

#EQUAL PITCH
#			set k [expr ($featstep * 2.0)/$evv(SEMITONES_PER_OCTAVE)]
#			if {[expr $feathi/$featlo] < [expr pow(2.0,$k)]} {
#				Inf "Low Frequency And High Frequency Limits Of Search Too Close For Stepsize Specified."
#				continue
#			}
#EQUAL FRQ
			if {[expr $feathi - $featlo] < $featstep} {
				Inf "Low Frequency And High Frequency Limits Of Search Too Close For Stepsize Specified."
				continue
			}
#END

			if {([string length $featscanwin] <= 0) || ![IsNumeric $featscanwin]} {
				Inf "No Valid Peak-Search Step Entered"
				continue
			}

#EQUAL PITCH
#			if {($featscanwin < 0.1) || ($featscanwin > $evv(FEATSCANWIN_LIM))} {
#				Inf "Scan Windowsize Out Of Range (0.1 To $evv(FEATSCANWIN_LIM))"
#				continue
#			}
#EQUAL FRQ
			if {($featscanwin <$fechwidth) || ($featscanwin >= $nyq)} {
				Inf "Scan Windowsize Out Of Range ($fechwidth To $nyq)"
				continue
			}
#END

			if {[string length $featpkcnt] <= 0} {
				Inf "Number Of Peaks To Find Not Entered"
				continue
			}
			if {![regexp {^[0-9]+$} $featpkcnt]} {
				Inf "Invalid Number Of Peaks To Find Entered"
				continue
			}
			if {![regexp {^[0-9]+$} $featpkcnt] || ($featpkcnt < 1) || ($featpkcnt > 6)} {
				Inf "Number Of Peaks To Find, Out Of Range (1 TO 6)"
				continue
			}
			set pkmode [expr $feattype + 1]
			switch -regexp -- $feattype \
				^$evv(FE_BEST)$ - \
				^$evv(FE_EVERY)$ -\
				^$evv(FE_ENVEL)$ {
					if {([string length $featmin] <= 0) || ![IsNumeric $featmin]} {
						Inf "No Valid Minimum Feature Size Entered"
						continue
					}
					if {($featmin < [expr $pa($featinfile,$evv(FRAMETIME)) * $evv(SECS_TO_MS)]) || ($featmin > [expr $pa($featinfile,$evv(DUR)) * $evv(SECS_TO_MS)])} {
						Inf "Invalid Minimum Feature Size : Range [expr $pa($featinfile,$evv(FRAMETIME)) * $evv(SECS_TO_MS)] TO [expr $pa($featinfile,$evv(DUR)) * $evv(SECS_TO_MS)]"
						continue
					}
					if {([string length $featmax] <= 0) || ![IsNumeric $featmax]} {
						Inf "No Valid Maximum Feature Size Entered"
						continue
					}
					if {($featmax < [expr $pa($featinfile,$evv(FRAMETIME)) * $evv(SECS_TO_MS)]) || ($featmax > [expr $pa($featinfile,$evv(DUR)) * $evv(SECS_TO_MS)])} {
						Inf "Invalid Maximum Feature Size : Range [expr $pa($featinfile,$evv(FRAMETIME)) * $evv(SECS_TO_MS)] TO [expr $pa($featinfile,$evv(DUR))* $evv(SECS_TO_MS)]"
						continue
					}
					if {([string length $featerr] <= 0) || ![IsNumeric $featerr]} {
						Inf "No Valid Acceptable Error Entered"
						continue
					}
					if {($featerr < 0) || ($featerr > $evv(SEMITONES_PER_OCTAVE))} {
						Inf "Invalid Acceptable Error Size : Range 0 To $evv(SEMITONES_PER_OCTAVE)"
						continue
					}
					if {([string length $featurecnt] <= 0) || ![regexp {^[0-9]+$} $featurecnt]} {
						Inf "No Valid Feature Count Entered"
						continue
					}
					if {($featurecnt < 1) || ($featurecnt > 1000)} {
						Inf "Invalid Feature Count : Range 1 To 1000"
						continue
					}
					if {([string length $feattail] <= 0) || ![IsNumeric $feattail]} {
						Inf "No Valid Sound-To-Keep Value Entered"
						continue
					}
					if {($feattail < 0.0) || ($feattail > 1000)} {
						Inf "Invalid Sound-To-Keep Value: Range 0.0 To 1000.0)"
						continue
					}
					if {([string length $featsplic] <= 0) || ![IsNumeric $featsplic]} {
						Inf "No Valid Splice Length Entered"
						continue
					}
					if {($featsplic < 1.0) || ($featsplic > 50)} {
						Inf "Invalid Splice Length: Range 1.0 To 50.0)"
						continue
					}
					set cmd [file join $evv(CDPROGRAM_DIR) features]
					lappend cmd get $pkmode $featinfile $outdata
					lappend cmd $featlo $feathi $featstep $featscanwin $featpkcnt $featmin $featmax $featerr
					lappend cmd $featurecnt $feattail $featsplic
					if {($feattype == 0) && $featlong} {
						append cmd "-d"
					}
				} \
				^$evv(FE_WINDOWS)$ - \
				^$evv(FE_AVERAGE)$ - \
				^$evv(FE_CHECK)$ {
					if {([string length $feattime] <= 0) || ![IsNumeric $feattime]} {
						Inf "No Valid Time Entered"
						continue
					}
					if {($feattime < 0.0) || ($feattime > $pa($featinfile,$evv(DUR)))} {
						Inf "Invalid Time Entered: Range 0.0 To $pa($featinfile,$evv(DUR))"
						continue
					}
					if {($feattype == $evv(FE_CHECK)) && ($feattime == 0)} {
						Inf "There Is No Data To Display At Time Zero"
						continue
					}
					set cmd [file join $evv(CDPROGRAM_DIR) features]
					lappend cmd get $pkmode $featinfile
					lappend cmd $featlo $feathi $featstep $featscanwin $featpkcnt
					switch -regexp -- $feattype \
						^$evv(FE_WINDOWS)$ {
							if {([string length $featwcnt] <= 0) || ![regexp {^[0-9]+$} $featwcnt]} {
								Inf "No Valid Window Count Entered"
								continue
							}
							if {($featwcnt < 1) || ($featwcnt > $fe_maxwlen)} {
								Inf "Invalid Window Count : Range 1 To $fe_maxwlen"
								continue
							}
							set k [expr int(round($feattime / $pa($featinfile,$evv(FRAMETIME))))]
							set wremain [expr $pa($featinfile,$evv(WLENGTH)) - $k]
							if {$wremain <= 0} {
								Inf "No More Windows At The Time Specified"
								continue
							}
							if {$featwcnt > $wremain} {
								set featwcnt $wremain
							}
							lappend cmd $featwcnt $feattime
							set k [expr $featwcnt * $pa($featinfile,$evv(FRAMETIME))]
							set k [expr int(round($k * $evv(SECS_TO_MS)))]
							set msg "Dur $k mS"
							.features.2.3.4 config -text $msg -bg $evv(EMPH)
						} \
						^$evv(FE_AVERAGE)$ {
							if {([string length $featend] <= 0) || ![IsNumeric $featend]} {
								Inf "No Valid Time Entered"
								continue
							}
							if {($featend < 0.0) || ($featend > $pa($featinfile,$evv(DUR)))} {
								Inf "Invalid Time Entered: Range 0.0 TO $pa($featinfile,$evv(DUR))"
								continue
							}
							if {$featend < $feattime} {
								Inf "Start And End Times Are Incompatible."
								continue
							}
							lappend cmd $feattime $featend
							set k [expr ($featend - $feattime)/$pa($featinfile,$evv(FRAMETIME))]
							set k [expr int(round($k))]
							set msg "$k Windows"
							.features.2.3.4 config -text $msg -bg $evv(EMPH)
							$featlist insert end $msg
							set k [expr int(round($k))]
							if {($k <2) && $feattime} {
								Inf "There Is No Data To Display At Time Zero"
								continue
							}
					if {($feattype == $evv(FE_CHECK)) && ($feattime == 0)} {
						Inf "There Is No Data To Display At Time Zero"
						continue
					}

						} \
						^$evv(FE_CHECK)$ {
							lappend cmd $feattime
						}
					}
	
			if {$fesortbuf} {
				lappend cmd "-s"
			}
			set CDPidrun 0
			set prg_dun 0
			set prg_abortd 0
			set returnval 1
			$featlist delete 0 end
			Block "Extracting Features"
			set finished2 0
			set featscram {}
			while {!$finished2} {
				if [catch {open "|$cmd"} CDPidrun] {
					set line "$CDPidrun : CAN'T RUN PROCESS."
					$featlist insert end $line
					set returnval 0
					set finished2 1
					break
				} else {
	   				fileevent $CDPidrun readable "Display_Features_Info $featlist"
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				if {!$prg_dun} {
					set line "Process Failed"
					$featlist insert end $line
					set returnval 0
					set finished2 1
					break
				}
				if {$returnval} {
					$featlist insert end "Completed"
				} 
				set finished2 1
			}
			UnBlock
			$featlist yview moveto 1.0
			if {$returnval} {
				if {($feattype == $evv(FE_WINDOWS)) || ($feattype == $evv(FE_AVERAGE)) || ($feattype == $evv(FE_CHECK))} {
					if {[llength $featscram] <= 0} {
						Inf "No Data Returned From Features Data Test"
						continue
					}
					catch {unset nuitems}
					foreach item $featscram {
						if {[llength $item] > 1} {
							foreach subitem $item {
								lappend nuitems $subitem
							}
						} elseif {[string length $item] > 0} {
							lappend nuitems $item
						}
					}
					if {![info exists nuitems]} {
						Inf "No Valid Data Returned From Features Data Test"
						continue
					}
					set featscram $nuitems
				}
				switch -regexp -- $feattype \
					^$evv(FE_WINDOWS)$ {	;# outputs principal peaks in a series of N windows
						set len [llength $featscram]
						if {![CreateFoundPeaksData $origrate]} {
							continue
						}
						SnackDisplay $evv(SN_FEATURES_PEAKS) features 0 0

					} \
					^$evv(FE_AVERAGE)$ {	;# Displays statistics on peakfrqs over given time-wadge
						set len [llength $featscram]
						if {$len < 4} {
							Inf "Insufficient Data Returned From Features Data Test"
							continue
						}
						set pkminf	[lindex $featscram 0]
						set pkmaxf	[lindex $featscram 1]
						set pkdata  [lrange $featscram 2 end]

						set frqwidth [expr $pkmaxf - $pkminf]
						set pmin [expr int(ceil([UnconstrainedHzToMidi $pkminf]))]
						set pmax [expr int(floor([UnconstrainedHzToMidi $pkmaxf]))]
						set lastppos -10
						set lastoct -60
						while {$pmin < $pmax} {
							set thisoct [expr $pmin/12]
							set fthis [MidiToHz $pmin]
							set canvxpos [expr ($fthis - $pkminf) / $frqwidth]
							set canvxpos [expr $canvxpos * double($evv(FEATURES_WIDTH))]
							set pos [expr int(round($canvxpos))]
							if {[expr $pos - $lastppos] > 12} {
								set coords [list $pos $evv(FEATURES_HEIGHT) $pos $evv(FEMARK_TOP)]
								$featcan create line $coords -width 1 -fill black -tag drawn
								set coords [list $pos $evv(FETEXT_POS)]
								set note [MidiToNote $pmin]
								$featcan create text $coords -text $note -font treefnt -tag drawn
								set lastppos $pos
								if {$thisoct > $lastoct} {
									set coords [list $pos $evv(FEOCT_POS)]
									$featcan create text $coords -text [expr $thisoct - 5] -font treefnt -tag drawn
									set coords [list $pos $evv(FEFRQ_POS)]
									$featcan create text $coords -text [expr int(round($fthis))] -font treefnt -tag drawn
									set lastoct $thisoct
								}
							}
							incr pmin
						}
						foreach {frq stat} $pkdata {
							set canvxpos [expr ($frq - $pkminf) / $frqwidth]
							set canvxpos [expr double($evv(FEATURES_WIDTH)) * $canvxpos]
							set pos [expr int(round($canvxpos))]
							set hite [expr int(round(double($evv(DISPLAY_HEIGHT)) * $stat))]
							set hite [expr $evv(DISPLAY_HEIGHT) - $hite]
							set coords [list $pos $evv(DISPLAY_HEIGHT) $pos $hite]
							$featcan create line $coords -width 1 -fill black -tag drawn
						}
						.features.2.3.3 config -text "Display Pitchwise" -command "FeaturesPitchwise 1" -bd 2
					} \
					^$evv(FE_CHECK)$ {		;# Displays single anal window + peaks found (red)
						set peakcnt [lindex $featscram 0]
						set peakend [expr $peakcnt + 1]
						if {[llength $featscram] < [expr $peakcnt + 1]} {
							Inf "Invalid Data (wrong Number Of Peaks) Returned From Features Data Test"
							continue
						}
						set peaks [lrange $featscram 1 $peakcnt]
						set analdata [lrange $featscram $peakend end]
						set anallen [llength $analdata] 
						if {$anallen != $clength} {
							Inf "Analysis Data (length [llength $analdata]) Is Not The Correct Length ($clength)"
						}
						set pkminf $evv(MIDIMINFRQ)
						if {$speechmode} {
							set pkmaxf $evv(MIDIMAXFRQ)
							set frqwidth $evv(MIDIMAXFRQ)
						} else {
							set pkmaxf $pa($featinfile,$evv(NYQUIST))
							set frqwidth $pa($featinfile,$evv(NYQUIST))
						}
						set pmin [expr int(ceil([UnconstrainedHzToMidi $pkminf]))]
						set pmax [expr int(floor([UnconstrainedHzToMidi $pkmaxf]))]
						set lastppos -10
						set lastoct -60
						while {$pmin < $pmax} {
							set thisoct [expr $pmin/12]
							set fthis [MidiToHz $pmin]
							set canvxpos [expr ($fthis - $pkminf) / $frqwidth]
							set canvxpos [expr $canvxpos * double($evv(FEATURES_WIDTH))]
							set pos [expr int(round($canvxpos))]
							if {[expr $pos - $lastppos] > 12} {
								set coords [list $pos $evv(FEATURES_HEIGHT) $pos $evv(FEMARK_TOP)]
								$featcan create line $coords -width 1 -fill black -tag drawn
								set coords [list $pos $evv(FETEXT_POS)]
								set note [MidiToNote $pmin]
								$featcan create text $coords -text $note -font treefnt -tag drawn
								set lastppos $pos
								if {$thisoct > $lastoct} {
									set coords [list $pos $evv(FEOCT_POS)]
									$featcan create text $coords -text [expr $thisoct - 5] -font treefnt -tag drawn
									set coords [list $pos $evv(FEFRQ_POS)]
									$featcan create text $coords -text [expr int(round($fthis))] -font treefnt -tag drawn
									set lastoct $thisoct
								}
							}
							incr pmin
						}
						set canvxincr [expr double($evv(FEATURES_WIDTH))/double($fecdiv)]
						set canvxstart [expr $canvxincr / 2.0]
						set canvxpos $canvxstart
						set cc 0
						while {$cc < $fecdiv} {
							set pos [expr int(round($canvxpos))]
							set k [lindex $analdata $cc]
							set hite [expr double($evv(DISPLAY_HEIGHT)) * $k]
							set hite [expr int(round($hite))]
							set hite [expr $evv(DISPLAY_HEIGHT) - $hite]
							set coords [list $pos $evv(DISPLAY_HEIGHT) $pos $hite]
							$featcan create line $coords -width 1 -fill black -tag drawn
							incr cc
							if {$cc >= $anallen} {
								break
							}
							set canvxpos [expr $canvxpos + $canvxincr]
						}
						foreach pk $peaks {
							set canvxpos [expr $pk / $frqwidth]
							set canvxpos [expr $canvxpos * double($evv(FEATURES_WIDTH))]
							set canvxpos [expr $canvxpos + $canvxstart]
							set pos [expr int(round($canvxpos))]
							set coords [list $pos $evv(DISPLAY_HEIGHT) $pos $evv(FEPKTOP_OFFSET)]
							$featcan create line $coords -width 1 -fill red -tag drawn
							set coords [list $pos $evv(FEPKTXT_OFFSET)]
							$featcan create text $coords -text [expr int(round($pk))] -font treefnt -fill red -tag drawn
						}
						.features.2.3.3 config -text "Display Pitchwise" -command "FeaturesPitchwise 1" -bd 2
					}
			}
		} else {
			set finished 1
		}
	}
	RememberFeatureVariables
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc LongFeatures {} {
	global feattype evv
	switch -regexp -- $feattype \
		^$evv(FE_BEST)$ {
			.features.2.2.7 config -state normal -text "Use Longest Features"
		} \
		default {
			.features.2.2.7 config -state disabled -text ""
		}

}

proc SetFeatureTestParams {} {
	global feattype featwcnt featend featinfile lastifeatwcnt lastifeatend feattime fe_maxwlen pa evv

	.features.1.best config -text "Display peaks against spectrum"	   -value 5
	.features.1.all  config -text "Display peaks over small timerange" -value 3
	.features.1.env  config -text "Statistical distribution of peaks"  -value 4
	.features.2.3.3 config -text "" -command {} -bd 0
	.features.2.3.4 config -text "" -bg [option get . background {}]

	bind .features.2.3.1.e <Down> "focus .features.2.3.2.e"
	bind .features.2.3.2.e <Down> "focus .features.2.3.1.e"
	bind .features.2.3.1.e <Up>	  "focus .features.2.3.2.e"
	bind .features.2.3.2.e <Up>   "focus .features.2.3.1.e"


	switch -regexp -- $feattype \
		^$evv(FE_WINDOWS)$ {		
			.features.2.3.2.e   config -bd 2 -textvariable featwcnt -width 12
			.features.2.3.2.lab config -text "Number of windows to display"
			if {[info exists lastifeatwcnt] && ([string length $lastifeatwcnt] > 0)} {
				set featwcnt $lastifeatwcnt
			} else {
				set feattime 0
				set featwcnt $fe_maxwlen
			}
		} \
		^$evv(FE_AVERAGE)$ {
			.features.2.3.2.e   config -bd 2 -textvariable featend -width 12
			.features.2.3.2.lab config -text "End time at which to extract peaks"
			if {[info exists lastifeatend] && ([string length $lastifeatend] > 0)} {
				set featend $lastifeatend
			}
		} \
		^$evv(FE_CHECK)$ {
			RememberFeatureInterTestVariables
			.features.2.3.2.e   config -bd 0 -width 0
			set featwcnt ""
			set featend ""
			.features.2.3.2.lab config -text ""
			bind .features.2.3.1.e <Down> {}
			bind .features.2.3.2.e <Down> {}
			bind .features.2.3.1.e <Up>   {}
			bind .features.2.3.2.e <Up>   {}
		}

}

proc FeaturesRunOrTest {test} {
	global featinfile feattype evv
	global featmin featmax featerr featurecnt feattail featsplic feattime featend featwcnt
	global last_feattype last_testfeattype

	.features.2.3.4 config -text "" -bg [option get . background {}]

	if {$test} {

		wm title .features "TEST FEATURE EXTRACTION DATA: file '$featinfile'"

		RememberFeatureVariables

		set last_feattype $feattype
		if {[info exists last_testfeattype] && ([string length $last_testfeattype] > 0)} {
			set feattype $last_testfeattype
		} else {
			set feattype -1
		}	

		.features.1.lab  config -text "TEST THE DATA"
		.features.1.best config -text "Display peaks against spectrum"	   -value 5 -command SetFeatureTestParams
		.features.1.all  config -text "Display peaks over small timerange" -value 3 -command SetFeatureTestParams
		.features.1.env  config -text "Statistical distribution of peaks"  -value 4 -command SetFeatureTestParams

		.features.0.dfld config -text "Default Durations" -command "SetFeaturesDurDefaults" -bd 2

		.features.2.2.1.e   config -bd 0 -width 0
		set featmin ""
		.features.2.2.1.lab config -text ""
		.features.2.2.2.e   config -bd 0 -width 0
		set featmax ""
		.features.2.2.2.lab config -text ""
		.features.2.2.3.e   config -bd 0 -width 0
		set featerr ""
		.features.2.2.3.lab config -text ""
		.features.2.2.4.e   config -bd 0 -width 0
		set featurecnt ""
		.features.2.2.4.lab config -text ""
		.features.2.2.5.e   config -bd 0 -width 0
		set feattail ""
		.features.2.2.5.lab config -text ""
		.features.2.2.6.e   config -bd 0 -width 0
		set featsplic ""
		.features.2.2.6.lab config -text ""

		.features.2.2.7 config -text "" -state disabled
		
		.features.2.3.1.e   config -state normal -bd 2 -width 12
		.features.2.3.1.lab config -text "Time at which to extract peaks"

		if {$feattype == $evv(FE_WINDOWS)} {
			.features.2.3.2.e   config -state normal -bd 2 -width 12
			.features.2.3.2.lab config -text "Number of windows to display"
		} elseif {$feattype == $evv(FE_AVERAGE)} {
			.features.2.3.2.e   config -state normal -bd 2 -width 12
			.features.2.3.2.lab config -text "End time at which to extract peaks"
		} elseif {$feattype == $evv(FE_CHECK)} {
			.features.2.3.2.e   config -bd 0 -width 0
			.features.2.3.2.lab config -text ""
		}
		.features.0.run  config -text "RUN DATA TEST"
		.features.0.test config -text "GO TO FEATURE EXTRACTION" -command "FeaturesRunOrTest 0"

		if {[info exists last_testfeattype] && ([string length $last_testfeattype] > 0)} {
			ResetFeatureVariables
		}

	} else {
		wm title .features "FEATURE EXTRATION on file '$featinfile'"

		RememberFeatureTestVariables

		set last_testfeattype $feattype
		if {[info exists last_feattype] && ([string length $last_feattype] > 0)} {
			set feattype $last_feattype
		} else {
			set feattype -1
		}	

		.features.1.lab  config -text "EXTRACT FEATURES"
		.features.1.best config -text "BEST Examples of Each Feature"  -value 0 -command LongFeatures
		.features.1.all  config -text "ALL Examples of (N) Feature(s)" -value 1 -command LongFeatures
		.features.1.env  config -text "SILENCE all except Features"	   -value 2 -command LongFeatures

		.features.0.dfld config -text "" -command {} -bd 0

		.features.2.2.1.e   config -bd 2 -state normal -width 12
		.features.2.2.1.lab config -text "Minimum size of features to find (mS)"
		.features.2.2.2.e   config -bd 2 -state normal -width 12
		.features.2.2.2.lab config -text "Maximim size of features to find (mS)"
		.features.2.2.3.e   config -bd 2 -state normal -width 12
		.features.2.2.3.lab config -text "Acceptable Error in equating peaks (semitones)"
		.features.2.2.4.e   config -bd 2 -state normal -width 12
		.features.2.2.4.lab config -text "Maximum number of features to find"
		.features.2.2.5.e   config -bd 2 -state normal -width 12
		.features.2.2.5.lab config -text "Sound to keep before & after feature (mS)"
		.features.2.2.6.e   config -bd 2 -state normal -width 12
		.features.2.2.6.lab config -text "Splice length for cutting features (mS)"

		if {[info exists last_feattype] && ([string length $last_feattype] > 0)} {
			ResetFeatureVariables
		}

		.features.2.2.7 config -text "Use Longest Features" -state normal

		.features.2.3.1.e   config -bd 0 -width 0
		set feattime ""
		.features.2.3.1.lab config -text ""
		.features.2.3.2.e   config -bd 0 -width 0
		set featwcnt ""
		set featend  ""
		.features.2.3.2.lab config -text ""

		.features.0.run  config -text "RUN EXTRACTION"
		.features.0.test config -text "GO TO DATA TESTING" -command "FeaturesRunOrTest 1"

	}
}


proc TellFeature {} {
	set msg    "----------------------------------------------\n"
	append msg "            FEATURES EXTRACTION\n"
	append msg "----------------------------------------------\n"
	append msg "\n"
	append msg "FIND MOST PROMINENT FEATURES IN A SOUND, FROM AN ANALYSIS FILE.\n"
	append msg "\n"
	append msg "BEST EXAMPLE OF EACH FEATURE:\n"
	append msg "Create data file to use to cut best example of each prominent feature from sound source.\n"
	append msg "\n"
	append msg "ALL EXAMPLES OF (N) FEATURE(S):\n"
	append msg "Create data file(s) to use to cut out all examples of 1 (or more) prominent feature(s).\n"
	append msg "Creates 1 outfile per output feature.\n"
	append msg "\n"
	append msg "SILENCE ALL EXCEPT FEATURES:\n"
	append msg "Create envelope-files to envelope the source so only 1 feature remains.\n"
	append msg "Creates 1 envelope file per extracted feature.\n"
	append msg "\n"
	append msg "----------------------------------------------\n"
	append msg "             DATA TESTING\n"
	append msg "----------------------------------------------\n"
	append msg "\n"
	append msg "CHECK THE SPECTRAL DATA EXTRACTED BY THE FEATURE ANALYSIS.\n"
	append msg "\n"
	append msg "DISPLAY PEAKS AGAINST SPECTRUM:\n"
	append msg "Output a display of the spectrum + the peaks found.\n"
	append msg "Checks if the peaks found are credible.\n"
	append msg "\n"
	append msg "DISPLAY PEAKS OVER SMALL TIMERANGE:\n"
	append msg "Output peak data for 1 or more windows at a specified time in file.\n"
	append msg "This checks the variance of the peak-data over a small range of windows.\n"
	append msg "\n"
	append msg "STATISTICAL DISTRIBUTION OF PEAKS:\n"
	append msg "Output graph showing number of peaks found at each frequency.\n"
	append msg "Applied to a 'constant' sound, checks the variance of the peaks, as tracked by the process.\n"
	append msg "\n"
	Inf $msg
}

proc UnsetFeatureVariables {} {
	global featlo feathi featstep featscanwin featpkcnt featmin featmax 
	global featerr featurecnt feattail featsplic featwcnt featend

	set featlo ""
	set feathi ""
	set featstep ""
	set featscanwin ""
	set featpkcnt ""
	set featmin ""
	set featmax ""
	set featerr ""
	set featurecnt ""
	set feattail ""
	set featsplic ""
	set featwcnt ""
	set featend ""
}

proc ResetFeatureVariables {} {
	global featlo feathi featstep featscanwin featpkcnt featmin featmax feattype evv
	global featerr featurecnt feattail featsplic featwcnt feattime featend lastfeattime
	global lastfeatlo lastfeathi lastfeatstep lastfeatscanwin lastfeatpkcnt lastfeatmin lastfeatmax 
	global lastfeaterr lastfeaturecnt lastfeattail lastfeatsplic lastfeatwcnt lastfeatend

	switch -regexp -- $feattype \
		^$evv(FE_BEST)$ - \
		^$evv(FE_EVERY)$ - \
		^$evv(FE_ENVEL)$ {
			if {[info exists lastfeatmin] && ([string length $lastfeatmin] > 0)} {
				set featmin $lastfeatmin
			}
			if {[info exists lastfeatmax] && ([string length $lastfeatmax] > 0)} {
				set featmax $lastfeatmax
			}
			if {[info exists lastfeaterr] && ([string length $lastfeaterr] > 0)} {
				set featerr $lastfeaterr
			}
			if {[info exists lastfeaturecnt] && ([string length $lastfeaturecnt] > 0)} {
				set featurecnt $lastfeaturecnt
			}
			if {[info exists lastfeattail] && ([string length $lastfeattail] > 0)} {
				set feattail $lastfeattail
			}
			if {[info exists lastfeatsplic] && ([string length $lastfeatsplic] > 0)} {
				set featsplic $lastfeatsplic
			}
		} \
		^$evv(FE_WINDOWS)$ - \
		^$evv(FE_AVERAGE)$ - \
		^$evv(FE_CHECK)$ {
			if {[info exists lastfeattime] && ([string length $lastfeattime] > 0)} {
				set feattime $lastfeattime
			}
			if {$feattype == $evv(FE_AVERAGE)} {
				if {[info exists lastfeatend]} {
					set featend $lastfeatend
				}
			} elseif {$feattype == $evv(FE_WINDOWS)} {
				if {[info exists lastfeatwcnt]} {
					set featwcnt $lastfeatwcnt
				}
			}
		}

	if {[info exists lastfeatlo] && ([string length $lastfeatlo] > 0)} {
		set featlo $lastfeatlo
	}
	if {[info exists lastfeathi] && ([string length $lastfeathi] > 0)} {
		set feathi $lastfeathi
	}
	if {[info exists lastfeatstep] && ([string length $lastfeatstep] > 0)} {
		set featstep $lastfeatstep
	}
	if {[info exists lastfeatscanwin] && ([string length $lastfeatscanwin] > 0)} {
		set featscanwin $lastfeatscanwin
	}
	if {[info exists lastfeatpkcnt] && ([string length $lastfeatpkcnt] > 0)} {
		set featpkcnt $lastfeatpkcnt
	}
}

proc RememberFeatureVariables {} {
	global featlo feathi featstep featscanwin featpkcnt featmin featmax feattime
	global featerr featurecnt feattail featsplic featwcnt featend
	global lastfeatlo lastfeathi lastfeatstep lastfeatscanwin lastfeatpkcnt lastfeatmin lastfeatmax 
	global lastfeaterr lastfeaturecnt lastfeattail lastfeatsplic lastfeatwcnt lastfeatend lastfeattime

	if {[info exists featlo] && ([string length $featlo] > 0)} {
		set lastfeatlo $featlo
	}
	if {[info exists feathi] && ([string length $feathi] > 0)} {
		set lastfeathi $feathi
	}
	if {[info exists featstep] && ([string length $featstep] > 0)} {
		set lastfeatstep $featstep
	}
	if {[info exists featscanwin] && ([string length $featscanwin] > 0)} {
		set lastfeatscanwin $featscanwin
	}
	if {[info exists featpkcnt] && ([string length $featpkcnt] > 0)} {
		set lastfeatpkcnt $featpkcnt
	}
	if {[info exists featmin] && ([string length $featmin] > 0)} {
		set lastfeatmin $featmin
	}
	if {[info exists featmax] && ([string length $featmax] > 0)} {
		set lastfeatmax $featmax
	}
	if {[info exists featerr] && ([string length $featerr] > 0)} {
		set lastfeaterr $featerr
	}
	if {[info exists featurecnt] && ([string length $featurecnt] > 0)} {
		set lastfeaturecnt $featurecnt
	}
	if {[info exists feattail] && ([string length $feattail] > 0)} {
		set lastfeattail $feattail
	}
	if {[info exists featsplic] && ([string length $featsplic] > 0)} {
		set lastfeatsplic $featsplic
	}
	if {[info exists featwcnt] && ([string length $featwcnt] > 0)} {
		set lastfeatwcnt $featwcnt
	}
	if {[info exists feattime] && ([string length $feattime] > 0)} {
		set lastfeattime $feattime
	}
	if {[info exists featend] && ([string length $featend] > 0)} {
		set lastfeatend $featend
	}
}

proc RememberFeatureInterTestVariables {} {
	global featwcnt featend
	global lastifeatwcnt lastifeatend

	if {[info exists featwcnt] && ([string length $featwcnt] > 0)} {
		set lastifeatwcnt $featwcnt
	}
	if {[info exists featend] && ([string length $featend] > 0)} {
		set lastifeatend $featend
	}
}

proc RememberFeatureTestVariables {} {
	global featwcnt featend feattime
	global lastfeatwcnt lastfeattime lastfeatend

	if {[info exists featwcnt]} {
		set lastfeatwcnt $featwcnt
	}
	if {[info exists featend]} {
		set lastfeatend $featend
	}
	if {[info exists feattime]} {
		set lastfeattime $feattime
	}
}

proc ValidFeatureFiles {} {
	global chlist wl evv pa
	if {![info exists chlist] || ([llength $chlist] <= 0)} {
		set i [$wl curselection]
		set len [llength $i]
		if {($len <= 0) || (($len == 1) && ($i == -1))} {
			Inf "No File Selected"
			return ""
		} elseif {$len > 1} {
			Inf "Select Just One File"
			return ""
		}
		set fnam [$wl get $i]
	} else {
		set len [llength $chlist]
		if {$len > 1} {
			Inf "Select Just One File"
			return ""
		}
		set fnam [lindex $chlist 0]
	}		 
	set ftyp $pa($fnam,$evv(FTYP))
	if {$ftyp != $evv(ANALFILE)} {
		Inf "Select An Analysis File"
		return ""
	}
	return $fnam
}

#------ Display info returned by running-batchfile in the the program-running display

proc Display_Features_Info {f} {
	global CDPidrun rundisplay prg_dun prg_abortd featscram evv

	if [eof $CDPidrun] {
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
			set line [string range $line 7 end] 
			$f insert end $line
			set prg_abortd 1
			set prg_dun 0
			return
		} elseif [string match INFO:* $line] {
			set line [string range $line 6 end] 
			$f insert end $line
			return
		} elseif [string match END:* $line] {
			set prg_dun 1
			return
		} else {
			lappend featscram $line
			return
		}
	}
	update idletasks
}

proc SetFeaturesDefaults {} {
	global featlo feathi featstep featscanwin featpkcnt featwcnt featend feattime feattime feattime 
	global featmin featmax featerr featurecnt feattail featsplic evv pa feattype featinfile featlong

	if {$feattype < 0} {
		Inf "Choose A Process First"
		return
	}
	set featlo		$evv(MIDDLE_C_FRQ)
	set feathi		[expr $evv(MIDIMAXFRQ) - $evv(FLTERR)]
	set featstep	$evv(FE_DFLTSTEP)
	set featscanwin $evv(SEMITONE)
	set featpkcnt	$evv(DFLT_PEAKS_CNT)
	set featmin		""
	set featmax		""
	set featerr		""
	set featurecnt	""
	set feattail	""
	set featsplic	""
	switch -regexp -- $feattype \
		^$evv(FE_WINDOWS)$ - \
		^$evv(FE_AVERAGE)$ - \
		^$evv(FE_CHECK)$ {
		} \
		default {
			set featmin		$pa($featinfile,$evv(FRAMETIME))
			set featmax		$evv(DFLT_MAX_FE_LEN)
			set featerr		$evv(DFLT_PK_ERROR)
			set featurecnt	$evv(FE_CNT_TYPICAL)
			set feattail	$evv(FE_TAILDUR)
			set featsplic	$evv(FE_SPLICELEN)
			set featlong	0
		}

}

proc SetFeaturesDurDefaults {} {
	global featlo feathi featstep featscanwin featpkcnt featwcnt featend feattime feattime feattime 
	global featmin featmax featerr featurecnt feattail featsplic evv pa feattype featinfile featlong

	if {$feattype < 0} {
		Inf "Choose A Process First"
		return
	}
	set featwcnt	""
	set feattime    ""
	set featend		""
	switch -regexp -- $feattype \
		^$evv(FE_WINDOWS)$ {
			set feattime [expr $pa($featinfile,$evv(DUR))/2.0]
			set featwcnt 1
		} \
		^$evv(FE_AVERAGE)$ {
			set feattime 0.0
			set featend	 $pa($featinfile,$evv(DUR))
		} \
		^$evv(FE_CHECK)$ {
			set feattime [expr $pa($featinfile,$evv(DUR))/2.0]
		}

}

#--- Convert Hz data to Pitch (MIDI) data

proc UnconstrainedHzToMidi {frq} {
	global mu evv
   	set midi [expr $frq / $evv(LOW_A)]
	set midi [expr (log10($midi) * $evv(CONVERT_LOG10_TO_LOG2) * 12.0) - 3.0]
	return $midi
}

proc SetSpeechMode {} {
	global evv fechwidth fecdiv feathi speechmode
	global orig_fecdiv orig_midimaxfrq
	switch -- $speechmode {
		0 {
			set orig_fecdiv $fecdiv
			set orig_midimaxfrq $evv(MIDIMAXFRQ)
			set evv(MIDIMAXFRQ) 6000.0
			set k [expr $evv(MIDIMAXFRQ) - ($fechwidth/2.0)]
			set fecdiv [expr $k/double($fechwidth)]
			set fecdiv [expr $fecdiv + .5]
			.features.0.spk config -text "Full Spectrum Mode"
			.features.0.spk2 config -fg $evv(SPECIAL)
			set speechmode 1
		}
		1 {
			set fecdiv $orig_fecdiv 
			set evv(MIDIMAXFRQ) $orig_midimaxfrq
			.features.0.spk config -text "Set Speech Mode"
			.features.0.spk2 config -fg [option get . background {}]
			set speechmode 0
		}
	}
	set feathi	[expr $evv(MIDIMAXFRQ) - $evv(FLTERR)]
}

proc FeaturesPitchwise {pwise} {
	global featscram featcan fecolor feattype evv fechwidth speechmode featinfile pa fecdiv

	catch {$featcan delete drawn} in		;#	destroy any existing graphics
	switch -regexp -- $feattype \
		^$evv(FE_WINDOWS)$ {
			if {$pwise} {
				.features.2.3.3 config -text "Original Display" -command "FeaturesPitchwise 0"

				set pkcnt	[lindex $featscram 0]
				set pkwcnt	[lindex $featscram 1]
				set pkminf	[lindex $featscram 2]
				set pkmaxf	[lindex $featscram 3]
				set pkdata  [lrange $featscram 4 end]
				set datcnt [expr (($pkcnt * 2) * $pkwcnt) + 4]

				set frqwidth [expr $pkmaxf - $pkminf]
				set pbot [UnconstrainedHzToMidi $pkminf]
				set ptop [UnconstrainedHzToMidi $pkmaxf]
				set pwidth [expr $ptop - $pbot]
				set pmin [expr int(ceil([UnconstrainedHzToMidi $pkminf]))]
				set pmax [expr int(floor([UnconstrainedHzToMidi $pkmaxf]))]
				set lastppos -10
				set lastoct -60
				while {$pmin < $pmax} {
					set thisoct [expr $pmin/12]
					set fthis [MidiToHz $pmin]
					set canvxpos [expr ($pmin - $pbot) / $pwidth]
					set canvxpos [expr $canvxpos * double($evv(FEATURES_WIDTH))]
					set pos [expr int(round($canvxpos))]
					if {[expr $pos - $lastppos] > 12} {
						set coords [list $pos $evv(FEATURES_HEIGHT) $pos $evv(FEMARK_TOP)]
						$featcan create line $coords -width 1 -fill black -tag drawn
						set coords [list $pos $evv(FETEXT_POS)]
						set note [MidiToNote $pmin]
						$featcan create text $coords -text $note -font treefnt -tag drawn
						set lastppos $pos
						if {$thisoct > $lastoct} {
							set coords [list $pos $evv(FEOCT_POS)]
							$featcan create text $coords -text [expr $thisoct - 5] -font treefnt -tag drawn
							set coords [list $pos $evv(FEFRQ_POS)]
							$featcan create text $coords -text [expr int(round($fthis))] -font treefnt -tag drawn
							set lastoct $thisoct
						}
					}
					incr pmin
				}
				set offset 0
				set thiscolor $fecolor($offset)
				set cnt 0
				foreach {frq stat} $pkdata {
					if {$frq > 0.0} {
						set pthis [UnconstrainedHzToMidi $frq]
						set canvxpos [expr ($pthis - $pbot) / $pwidth]
						set canvxpos [expr double($evv(FEATURES_WIDTH)) * $canvxpos]
						set pos [expr int(round($canvxpos))]
						incr pos $offset
						set hite [expr int(round(double($evv(DISPLAY_HEIGHT)) * $stat))]
						set hite [expr $evv(DISPLAY_HEIGHT) - $hite]
						set coords [list $pos $evv(DISPLAY_HEIGHT) $pos $hite]
						$featcan create line $coords -width 1 -fill $thiscolor -tag drawn
					}
					incr cnt
					if {$cnt >= $pkcnt} {
						incr offset
						set thiscolor $fecolor([expr $offset % $evv(FE_MAXWINCNT)])
						set cnt 0
					}
				}
			} else {
				.features.2.3.3 config -text "Display Pitchwise" -command "FeaturesPitchwise 1"

				set pkcnt	[lindex $featscram 0]
				set pkwcnt	[lindex $featscram 1]
				set pkminf	[lindex $featscram 2]
				set pkmaxf	[lindex $featscram 3]
				set pkdata  [lrange $featscram 4 end]
				set datcnt [expr (($pkcnt * 2) * $pkwcnt) + 4]

				set frqwidth [expr $pkmaxf - $pkminf]
				set pmin [expr int(ceil([UnconstrainedHzToMidi $pkminf]))]
				set pmax [expr int(floor([UnconstrainedHzToMidi $pkmaxf]))]
				set lastppos -10
				set lastoct -60
				while {$pmin < $pmax} {
					set thisoct [expr $pmin/12]
					set fthis [MidiToHz $pmin]
					set canvxpos [expr ($fthis - $pkminf) / $frqwidth]
					set canvxpos [expr $canvxpos * double($evv(FEATURES_WIDTH))]
					set pos [expr int(round($canvxpos))]
					if {[expr $pos - $lastppos] > 12} {
						set coords [list $pos $evv(FEATURES_HEIGHT) $pos $evv(FEMARK_TOP)]
						$featcan create line $coords -width 1 -fill black -tag drawn
						set coords [list $pos $evv(FETEXT_POS)]
						set note [MidiToNote $pmin]
						$featcan create text $coords -text $note -font treefnt -tag drawn
						set lastppos $pos
						if {$thisoct > $lastoct} {
							set coords [list $pos $evv(FEOCT_POS)]
							$featcan create text $coords -text [expr $thisoct - 5] -font treefnt -tag drawn
							set coords [list $pos $evv(FEFRQ_POS)]
							$featcan create text $coords -text [expr int(round($fthis))] -font treefnt -tag drawn
							set lastoct $thisoct
						}
					}
					incr pmin
				}
				set offset 0
				set thiscolor $fecolor($offset)
				set cnt 0
				foreach {frq stat} $pkdata {
					set canvxpos [expr ($frq - $pkminf) / $frqwidth]
					set canvxpos [expr double($evv(FEATURES_WIDTH)) * $canvxpos]
					set pos [expr int(round($canvxpos))]
					incr pos $offset
					set hite [expr int(round(double($evv(DISPLAY_HEIGHT)) * $stat))]
					set hite [expr $evv(DISPLAY_HEIGHT) - $hite]
					set coords [list $pos $evv(DISPLAY_HEIGHT) $pos $hite]
					$featcan create line $coords -width 1 -fill $thiscolor -tag drawn
					incr cnt
					if {$cnt >= $pkcnt} {
						incr offset
						set thiscolor $fecolor([expr $offset % $evv(FE_MAXWINCNT)])
						set cnt 0
					}
				}
			}
		}  \
		^$evv(FE_AVERAGE)$ {
			if {$pwise} {
				.features.2.3.3 config -text "Original Display" -command "FeaturesPitchwise 0"

				set pkminf	[lindex $featscram 0]
				set pkmaxf	[lindex $featscram 1]
				set pkdata  [lrange $featscram 2 end]

				set frqwidth [expr $pkmaxf - $pkminf]
				set pbot [UnconstrainedHzToMidi $pkminf]
				set ptop [UnconstrainedHzToMidi $pkmaxf]
				set pwidth [expr $ptop - $pbot]
				set pmin [expr int(ceil([UnconstrainedHzToMidi $pkminf]))]
				set pmax [expr int(floor([UnconstrainedHzToMidi $pkmaxf]))]
				set lastppos -10
				set lastoct -60
				while {$pmin < $pmax} {
					set thisoct [expr $pmin/12]
					set fthis [MidiToHz $pmin]
					set canvxpos [expr ($pmin - $pbot) / $pwidth]
					set canvxpos [expr $canvxpos * double($evv(FEATURES_WIDTH))]
					set pos [expr int(round($canvxpos))]
					if {[expr $pos - $lastppos] > 12} {
						set coords [list $pos $evv(FEATURES_HEIGHT) $pos $evv(FEMARK_TOP)]
						$featcan create line $coords -width 1 -fill black -tag drawn
						set coords [list $pos $evv(FETEXT_POS)]
						set note [MidiToNote $pmin]
						$featcan create text $coords -text $note -font treefnt -tag drawn
						set lastppos $pos
						if {$thisoct > $lastoct} {
							set coords [list $pos $evv(FEOCT_POS)]
							$featcan create text $coords -text [expr $thisoct - 5] -font treefnt -tag drawn
							set coords [list $pos $evv(FEFRQ_POS)]
							$featcan create text $coords -text [expr int(round($fthis))] -font treefnt -tag drawn
							set lastoct $thisoct
						}
					}
					incr pmin
				}
				foreach {frq stat} $pkdata {
					if {$frq <= 0.0} {
						continue
					}
					set pthis [UnconstrainedHzToMidi $frq]
					set canvxpos [expr ($pthis - $pbot) / $pwidth]
					set canvxpos [expr double($evv(FEATURES_WIDTH)) * $canvxpos]
					set pos [expr int(round($canvxpos))]
					set hite [expr int(round(double($evv(DISPLAY_HEIGHT)) * $stat))]
					set hite [expr $evv(DISPLAY_HEIGHT) - $hite]
					set coords [list $pos $evv(DISPLAY_HEIGHT) $pos $hite]
					$featcan create line $coords -width 1 -fill black -tag drawn
				}
			} else {
				.features.2.3.3 config -text "Display Pitchwise" -command "FeaturesPitchwise 1"

				set pkminf	[lindex $featscram 0]
				set pkmaxf	[lindex $featscram 1]
				set pkdata  [lrange $featscram 2 end]

				set frqwidth [expr $pkmaxf - $pkminf]
				set pmin [expr int(ceil([UnconstrainedHzToMidi $pkminf]))]
				set pmax [expr int(floor([UnconstrainedHzToMidi $pkmaxf]))]
				set lastppos -10
				set lastoct -60
				while {$pmin < $pmax} {
					set thisoct [expr $pmin/12]
					set fthis [MidiToHz $pmin]
					set canvxpos [expr ($fthis - $pkminf) / $frqwidth]
					set canvxpos [expr $canvxpos * double($evv(FEATURES_WIDTH))]
					set pos [expr int(round($canvxpos))]
					if {[expr $pos - $lastppos] > 12} {
						set coords [list $pos $evv(FEATURES_HEIGHT) $pos $evv(FEMARK_TOP)]
						$featcan create line $coords -width 1 -fill black -tag drawn
						set coords [list $pos $evv(FETEXT_POS)]
						set note [MidiToNote $pmin]
						$featcan create text $coords -text $note -font treefnt -tag drawn
						set lastppos $pos
						if {$thisoct > $lastoct} {
							set coords [list $pos $evv(FEOCT_POS)]
							$featcan create text $coords -text [expr $thisoct - 5] -font treefnt -tag drawn
							set coords [list $pos $evv(FEFRQ_POS)]
							$featcan create text $coords -text [expr int(round($fthis))] -font treefnt -tag drawn
							set lastoct $thisoct
						}
					}
					incr pmin
				}
				foreach {frq stat} $pkdata {
					set canvxpos [expr ($frq - $pkminf) / $frqwidth]
					set canvxpos [expr double($evv(FEATURES_WIDTH)) * $canvxpos]
					set pos [expr int(round($canvxpos))]
					set hite [expr int(round(double($evv(DISPLAY_HEIGHT)) * $stat))]
					set hite [expr $evv(DISPLAY_HEIGHT) - $hite]
					set coords [list $pos $evv(DISPLAY_HEIGHT) $pos $hite]
					$featcan create line $coords -width 1 -fill black -tag drawn
				}
			}
		} \
		^$evv(FE_CHECK)$ {
			if {$pwise} {
				.features.2.3.3 config -text "Original Display" -command "FeaturesPitchwise 0"

				set peakcnt [lindex $featscram 0]
				set peakend [expr $peakcnt + 1]
				set peaks [lrange $featscram 1 $peakcnt]
				set analdata [lrange $featscram $peakend end]
				set anallen [llength $analdata] 
				set pkminf $evv(MIDIMINFRQ)
				if {$speechmode} {
					set pkmaxf $evv(MIDIMAXFRQ)
					set frqwidth $evv(MIDIMAXFRQ)
				} else {
					set pkmaxf $pa($featinfile,$evv(NYQUIST))
					set frqwidth $pa($featinfile,$evv(NYQUIST))
				}
				set pbot [UnconstrainedHzToMidi $pkminf]
				set ptop [UnconstrainedHzToMidi $pkmaxf]
				set pwidth [expr $ptop - $pbot]
				set pmin [expr int(ceil([UnconstrainedHzToMidi $pkminf]))]
				set pmax [expr int(floor([UnconstrainedHzToMidi $pkmaxf]))]
				set lastppos -10
				set lastoct -60
				while {$pmin < $pmax} {
					set thisoct [expr $pmin/12]
					set fthis [MidiToHz $pmin]
					set canvxpos [expr ($pmin - $pbot) / $pwidth]
					set canvxpos [expr $canvxpos * double($evv(FEATURES_WIDTH))]
					set pos [expr int(round($canvxpos))]
					if {[expr $pos - $lastppos] > 12} {
						set coords [list $pos $evv(FEATURES_HEIGHT) $pos $evv(FEMARK_TOP)]
						$featcan create line $coords -width 1 -fill black -tag drawn
						set coords [list $pos $evv(FETEXT_POS)]
						set note [MidiToNote $pmin]
						$featcan create text $coords -text $note -font treefnt -tag drawn
						set lastppos $pos
						if {$thisoct > $lastoct} {
							set coords [list $pos $evv(FEOCT_POS)]
							$featcan create text $coords -text [expr $thisoct - 5] -font treefnt -tag drawn
							set coords [list $pos $evv(FEFRQ_POS)]
							$featcan create text $coords -text [expr int(round($fthis))] -font treefnt -tag drawn
							set lastoct $thisoct
						}
					}
					incr pmin
				}
				set cc 0
				set botchan [expr int(round($pkminf/$fechwidth))]
				set thischan $botchan
				while {$cc < $anallen} {
					set fthis [expr $thischan * $fechwidth]
					if {$fthis <= 0.0} {
						set pos 0
					} elseif {$fthis > $pkmaxf} {
						break
					} else {
						set thisp [UnconstrainedHzToMidi $fthis]
						set canvxpos [expr $thisp / $pwidth]
						set canvxpos [expr $canvxpos * double($evv(FEATURES_WIDTH))]
						set pos [expr int(round($canvxpos))]
					}
					set k [lindex $analdata $cc]
					set hite [expr double($evv(DISPLAY_HEIGHT)) * $k]
					set hite [expr int(round($hite))]
					set hite [expr $evv(DISPLAY_HEIGHT) - $hite]
					set coords [list $pos $evv(DISPLAY_HEIGHT) $pos $hite]
					$featcan create line $coords -width 1 -fill black -tag drawn
					incr thischan
					incr cc
				}
				foreach pk $peaks {
					if {$pk > 0.0} {
						set thisp [UnconstrainedHzToMidi $pk]
						set canvxpos [expr $thisp / $pwidth]
						set canvxpos [expr $canvxpos * double($evv(FEATURES_WIDTH))]
						set pos [expr int(round($canvxpos))]
						set coords [list $pos $evv(DISPLAY_HEIGHT) $pos $evv(FEPKTOP_OFFSET)]
						$featcan create line $coords -width 1 -fill red -tag drawn
						set coords [list $pos $evv(FEPKTXT_OFFSET)]
						$featcan create text $coords -text [expr int(round($thisp))] -font treefnt -fill red -tag drawn
					}
				}
			} else  {
				.features.2.3.3 config -text "Display Pitchwise" -command "FeaturesPitchwise 1"

				set peakcnt [lindex $featscram 0]
				set peakend [expr $peakcnt + 1]
				set peaks [lrange $featscram 1 $peakcnt]
				set analdata [lrange $featscram $peakend end]
				set anallen [llength $analdata] 
				set pkminf $evv(MIDIMINFRQ)
				if {$speechmode} {
					set pkmaxf $evv(MIDIMAXFRQ)
					set frqwidth $evv(MIDIMAXFRQ)
				} else {
					set pkmaxf $pa($featinfile,$evv(NYQUIST))
					set frqwidth $pa($featinfile,$evv(NYQUIST))
				}
				set pmin [expr int(ceil([UnconstrainedHzToMidi $pkminf]))]
				set pmax [expr int(floor([UnconstrainedHzToMidi $pkmaxf]))]
				set lastppos -10
				set lastoct -60
				while {$pmin < $pmax} {
					set thisoct [expr $pmin/12]
					set fthis [MidiToHz $pmin]
					set canvxpos [expr ($fthis - $pkminf) / $frqwidth]
					set canvxpos [expr $canvxpos * double($evv(FEATURES_WIDTH))]
					set pos [expr int(round($canvxpos))]
					if {[expr $pos - $lastppos] > 12} {
						set coords [list $pos $evv(FEATURES_HEIGHT) $pos $evv(FEMARK_TOP)]
						$featcan create line $coords -width 1 -fill black -tag drawn
						set coords [list $pos $evv(FETEXT_POS)]
						set note [MidiToNote $pmin]
						$featcan create text $coords -text $note -font treefnt -tag drawn
						set lastppos $pos
						if {$thisoct > $lastoct} {
							set coords [list $pos $evv(FEOCT_POS)]
							$featcan create text $coords -text [expr $thisoct - 5] -font treefnt -tag drawn
							set coords [list $pos $evv(FEFRQ_POS)]
							$featcan create text $coords -text [expr int(round($fthis))] -font treefnt -tag drawn
							set lastoct $thisoct
						}
					}
					incr pmin
				}
				set canvxincr [expr double($evv(FEATURES_WIDTH))/double($fecdiv)]
				set canvxstart [expr $canvxincr / 2.0]
				set canvxpos $canvxstart
				set cc 0
				while {$cc < $fecdiv} {
					set pos [expr int(round($canvxpos))]
					set k [lindex $analdata $cc]
					set hite [expr double($evv(DISPLAY_HEIGHT)) * $k]
					set hite [expr int(round($hite))]
					set hite [expr $evv(DISPLAY_HEIGHT) - $hite]
					set coords [list $pos $evv(DISPLAY_HEIGHT) $pos $hite]
					$featcan create line $coords -width 1 -fill black -tag drawn
					incr cc
					if {$cc >= $anallen} {
						break
					}
					set canvxpos [expr $canvxpos + $canvxincr]
				}
				foreach pk $peaks {
					set canvxpos [expr $pk / $frqwidth]
					set canvxpos [expr $canvxpos * double($evv(FEATURES_WIDTH))]
					set canvxpos [expr $canvxpos + $canvxstart]
					set pos [expr int(round($canvxpos))]
					set coords [list $pos $evv(DISPLAY_HEIGHT) $pos $evv(FEPKTOP_OFFSET)]
					$featcan create line $coords -width 1 -fill red -tag drawn
					set coords [list $pos $evv(FEPKTXT_OFFSET)]
					$featcan create text $coords -text [expr int(round($pk))] -font treefnt -fill red -tag drawn
				}
			}
		}
}

proc FePitchToFrq {} {
	global fe_pfval fe_pswi evv pa featinfile

	if {([string length $fe_pfval] <= 0)} {
		Inf	"No Value Entered"
		return
	}
	if {![IsNumeric $fe_pfval] || ($fe_pfval < 0)} {
		Inf	"Invalid Value Entered"
		return
	}
	switch -- $fe_pswi {
		1 {	;# Frq To Pitch
			if {($fe_pfval < $evv(MIDIMINFRQ)) || ($fe_pfval >= $pa($featinfile,$evv(NYQUIST)))} {
				Inf	"Value Out Of Range For A Frequncy"
				return
			}
			set fe_pfval [UnconstrainedHzToMidi $fe_pfval]
		}
		0 {	;# Pitch To Frq
			if {($fe_pfval < 0) || ($fe_pfval >= [UnconstrainedHzToMidi $pa($featinfile,$evv(NYQUIST))])} {
				Inf	"Value Out Of Range For A Midi Pitch"
				return
			}
			set fe_pfval [MidiToHz $fe_pfval]
		}
	}
}



##################################################################################
# FILTERING A LIST OF SOUNDS (POSSIBLY FROM A MIXFILE) WITH DIFFERENT PARAMETERS #
##################################################################################

proc GroupFilter {} {
	global wl chlist evv pa wstk pr_grpfilt gpivec gpityp gpitplate gpiqqq grpfiltnorm gpifnam gpitail grpfiltinv gpi_endendgap gpi_infnamcnt gpiroot
	global prg_dun prg_abortd simple_program_messages CDPidrun

	;#	GET THE FILES TO PROCESS

	set mixin 0
	catch {unset gpi_endendgap}
	if {![info exists chlist] || ([llength $chlist] <= 0)} {
		Inf "Select A Mixfile Or A List Of Soundfiles"
		return
	}
	if {[llength $chlist] == 1} {
		set fnam [lindex $chlist 0]
		if {![IsAMixfile $pa($fnam,$evv(FTYP))]} {
			Inf "Select A Mixfile Or A List Of Soundfiles"
			return
		}
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot Open File $fnam"
			return
		}

		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {([string length $line] <= 0) || [string match ";" [string index $line 0]]} {
				continue
			}
			set line [split $line]
			set itemcnt 0
			catch {unset mixoutline}
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				if {$itemcnt == 0} {
					if {![file exists $item]} {
						Inf "Soundfile [file rootname [file tail $item]] (In Mixfile [file rootname [file tail $fnam]]) No Longer Exists"
						close $zit
						return
					}
					if {![info exists pa($item,$evv(FTYP))]} {
						if {[FileToWkspace $item 0 0 0 1 0] <= 0} {
							close $zit
							return
						}
					}
					lappend fnams $item
				}
				lappend mixoutline $item
				incr itemcnt
			}
			lappend mixoutlines $mixoutline
		}
		close $zit
		set mixin 1
	} else {
		set n 0 
		foreach fnam $chlist {
			if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
				Inf "Select A Mixfile Or A List Of Soundfiles"
				return
			}
			lappend fnams $fnam
		}
	}
	set origfnams $fnams
	set srate $pa([lindex $fnams 0],$evv(SRATE))
	set maxfrq [expr $srate / 2.0]
	set minfrq 9.0
	set gpi_infnamcnt [llength $fnams]

	set f .grpfilt	
	if [Dlg_Create $f "FILTER A SEQUENCE OF SOUNDS" "set pr_grpfilt 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0] 
		set f1 [frame $f.1] 
		set f2 [frame $f.2] 
		set f3 [frame $f.3] 
		set f4 [frame $f.4] 
		set f5 [frame $f.5] 
		set f5a [frame $f.5a] 
		set f6 [frame $f.6] 
		button $f0.ok -text "Do Filter" -command "set pr_grpfilt 1" -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $f0.hh -text "Help" -command "GrpFiltHelp" -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f0.ll -text "Load Patch" -command "set pr_grpfilt 3" -highlightbackground [option get . background {}]
		button $f0.ss -text "Save Patch" -command "set pr_grpfilt 2" -highlightbackground [option get . background {}]
		button $f0.quit -text "Abandon" -command "set pr_grpfilt 0"
		pack $f0.ok $f0.hh $f0.ll $f0.ss -side left -padx 2
		pack $f0.quit -side right
		pack $f0 -side top -fill x -expand true
		label $f1.ll -text "Pitch Vector" -width 20
		entry $f1.e -textvariable gpivec -width 32
		button $f1.bb -text "Get File" -command "GrpfiltGet pitch"  -highlightbackground [option get . background {}]
		pack $f1.ll $f1.e $f1.bb -side left
		pack $f1 -side top -fill x -expand true
		label $f2.ll -text "Q value or Q-vector" -width 20
		entry $f2.e -textvariable gpiqqq -width 32
		button $f2.bb -text "Get File" -command "GrpfiltGet q"  -highlightbackground [option get . background {}]
		pack $f2.ll $f2.e $f2.bb -side left
		pack $f2 -side top -fill x -expand true
		label $f3.ll -text "Filter Type" -width 20
		radiobutton $f3.1 -variable gpityp -text "Harmonic"                      -value 1 -command RenameTemplate
		radiobutton $f3.2 -variable gpityp -text "Inharmonic"					 -value 2 -command RenameTemplate
		radiobutton $f3.3 -variable gpityp -text "Inharmonic: Pitch Independent" -value 3 -command RenameTemplate
		set gpityp 0
		pack $f3.ll $f3.1 $f3.2 $f3.3 -side left
		pack $f3 -side top -fill x -expand true
		label $f4.ll -text "Filter Template" -width 20
		entry $f4.e -textvariable gpitplate -width 32
		button $f4.bb -text "Get File" -command "GrpfiltGet template"  -highlightbackground [option get . background {}]
		label $f.4.ll2 -text "Root level" -width 10
		entry $f4.e2 -textvariable gpiroot -width 4
		pack $f4.ll $f4.e $f4.bb $f.4.ll2 $f.4.e2 -side left
		pack $f4 -side top -fill x -expand true
		checkbutton $f.5.nn -text "Normalise Filter Output Levels" -variable grpfiltnorm
		set grpfiltnorm 1
		pack $f5.nn -side left
		pack $f5 -side top -fill x -expand true -pady 2
		checkbutton $f.5a.ii -text "Time Reversed Sources" -variable grpfiltinv
		button $f5a.bb -text "Get Timegaps File" -command "GrpfiltGet timegaps"  -highlightbackground [option get . background {}]
		pack $f5a.ii $f5a.bb -side left
		pack $f5a -side top -fill x -expand true -pady 2
		label $f6.ll -text "Generic Output Filename" -width 24
		entry $f6.e -textvariable gpifnam -width 32
		pack $f6.ll $f6.e -side left
		pack $f6 -side top -fill x -expand true
		wm resizable $f 0 0
		bind $f <Escape> {set pr_grpfilt 0}
		bind $f <Return> {set pr_grpfilt 1}
		bind $f1.e <Down> {focus .grpfilt.2.e}
		bind $f2.e <Down> {focus .grpfilt.4.e}
		bind $f4.e <Down> {focus .grpfilt.6.e}
		bind $f6.e <Down> {focus .grpfilt.1.e}

		bind $f1.e <Up> {focus .grpfilt.6.e}
		bind $f2.e <Up> {focus .grpfilt.1.e}
		bind $f4.e <Up> {focus .grpfilt.2.e}
		bind $f6.e <Up> {focus .grpfilt.4.e}
	}
	RenameTemplate
	set grpfiltinv 0
	if {$mixin} {
		$f.5a.ii config -state normal
		$f.5a.bb config -bd 2 -command "GrpfiltGet timegaps"
	} else {
		$f.5a.ii config -state disabled
		$f.5a.bb config -bd 0 -command {}
	}
	set pr_grpfilt 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_grpfilt $f.1.e
	while {!$finished} {
		tkwait variable pr_grpfilt
		DeleteAllTemporaryFiles
		set fnams $origfnams

		if {$pr_grpfilt > 0} {
			if {$pr_grpfilt == 3} {
				GetGpFiltParams
				continue
			}
			if {$gpityp == 0} {
				Inf "No Filter Type Set"
				continue
			}
			if {$grpfiltinv && ![info exists gpi_endendgap]} {
				Inf "No Time-Gap Values Set For Inverted Input Segments"
				continue
			}

			;#	OUTFILENAME CHECK

			if {$pr_grpfilt == 1} {
				if {[string length $gpifnam] <= 0} {
					Inf "No Output Filename Entered"
					continue
				}
				set outnam [string tolower $gpifnam]
				if {![ValidCDPRootname $outnam]} {
					continue
				}
				if {$mixin} {
					set mixoutnam $outnam
					append mixoutnam [GetTextfileExtension mix]
					if {[file exists $mixoutnam]} {
						Inf "File $mixoutnam Already Exists: Please Choose A Different Name"
						continue
					}
				}
				set n 0
				set OK 1
				set basnam $outnam
				foreach fnam $fnams {
					set ofnam($n) $basnam
					append ofnam($n) $n $evv(SNDFILE_EXT)
					if {[file exists $ofnam($n)]} {
						Inf "A File Named $ofnam($n) Already Exists: Please Choose A Different Generic Outfilename"
						set OK 0
						break
					}
					incr n
				}
				if {!$OK} {
					continue
				}		
			}
			;#	PITCH OR PITCH VECTOR

			if {[string length $gpivec] <= 0} {
				Inf "No Pitch Value Or Pitch Vector Entered"
				continue
			}
			if {![IsNumeric $gpivec]} {
				set xgpivec [string tolower $gpivec]
				if {[string length [file extension $xgpivec]] == 0} {
					append xgpivec ".txt"
				}
			}
			if {![IsNumeric $gpivec] && ![file exists $xgpivec]} {
				Inf "Invalid Pitch Value Entered"
				continue
			}
			catch {unset pvector}
			if {[IsNumeric $gpivec]} {
				if {($gpivec < 0) || ($gpivec > 127)} {
					Inf "Midi Pitch Value Out Of Range (0 - 127)"
					continue
				}
				foreach fn $fnams {
					lappend pvector $gpivec
				}
			} else {
				if {![info exists pa($xgpivec,$evv(FTYP))]} {
					if {[FileToWkspace $xgpivec 0 0 0 1 0] <= 0} {
						continue
					}
				}
				if {![IsAListofNumbers $pa($xgpivec,$evv(FTYP))] || ($pa($xgpivec,$evv(MINNUM)) < 0) || ($pa($xgpivec,$evv(MAXNUM)) > 127)} {
					Inf "File $xgpivec Is Not A List Of Midi Pitch Values (Range 0 - 127)"
					continue
				}
				if [catch {open $xgpivec "r"} zit] {
					Inf "Cannot Open File $xgpivec"
					continue
				}
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
						}
						lappend pvector $item
					}
				}
				close $zit
				if {[llength $pvector] != $gpi_infnamcnt} {
					Inf "Number Of Values In The Pitch-vector ([llength $pvector]) Does Not Correspond To Number Of Files $gpi_infnamcnt)"
					continue
				}
			}
			catch {unset pitchfrqs}
			foreach val $pvector {
				lappend pitchfrqs [MidiToHz $val]
			}

			;#	Q VALUE OR VECTOR

			if {[string length $gpiqqq] <= 0} {
				Inf "No Q Value Or Vector Entered"
				continue
			}
			if {![IsNumeric $gpiqqq]} {
				set xgpiqqq [string tolower $gpiqqq]
				if {[string length [file extension $xgpiqqq]] == 0} {
					append xgpiqqq ".txt"
				}
			}
			if {![IsNumeric $gpiqqq] && ![file exists $xgpiqqq]} {
				Inf "Invalid Pitch Value Entered"
				continue
			}
			catch {unset qvector}
			if {[IsNumeric $gpiqqq]} {
				if {($gpiqqq < 8) || ($gpiqqq > 10000)} {
					Inf "Q Value Out Of Range (8 - 10000)"
					continue
				}
				set cnt 0
				foreach fn $fnams {
					set qvector($cnt) $gpiqqq
					incr cnt
				}
			} else {
				if {![info exists pa($xgpiqqq,$evv(FTYP))]} {
					if {[FileToWkspace $xgpiqqq 0 0 0 1 0] <= 0} {
						continue
					}
				}
				if {![IsAListofNumbers $pa($xgpiqqq,$evv(FTYP))] || ($pa($xgpiqqq,$evv(MINNUM)) < 8) || ($pa($xgpiqqq,$evv(MAXNUM)) > 10000)} {
					Inf "File $xgpiqqq Is Not A List Of Valid Q Values (range 8 - 10000)"
					continue
				}
				if [catch {open $xgpiqqq "r"} zit] {
					Inf "Cannot Open File $xgpiqqq"
					continue
				}
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
						}
						set qvector($cnt) $item
					}
					incr cnt
				}
				close $zit
				if {$cnt != $gpi_infnamcnt} {
					Inf "Number Of Q Values In The Q-Vector ($cnt) Does Not Correspond To Number Of Files ($gpi_infnamcnt)"
					continue
				}
			}

			;#	FILTER TYPE 1 : HARMONICS COUNT

			if {$gpityp == 1} {
				if {[string length $gpitplate] <= 0} {
					Inf "No Harmonics Count Entered"
					continue
				}
				if {![regexp {^[0-9]+$} $gpitplate] || ($gpitplate < 1)} {
					Inf "Invalid Harmonics Count Entered"
					continue
				}
				set harmcnt $gpitplate

				catch {unset overfrqs}
				set kk 0
				foreach frq $pitchfrqs midival $pvector {
					set maxpartial [expr $frq * $harmcnt]
					if {$maxpartial >= $maxfrq} {
						lappend overfrqs $kk
					}
					incr kk
				}
				if {[info exists overfrqs]} {
					set minmaxmidi 130
					set maxmaxmidi -1
					foreach kk $overfrqs {
						set thismidi [lindex $pvector $kk]
						if {$thismidi < $minmaxmidi} {
							set minmaxmidi $thismidi
						}
						if {$thismidi > $maxmaxmidi} {
							set maxmaxmidi $thismidi
							set maxmaxfrq [lindex $pitchfrqs $kk]
				
						}
					}
					set maxpartial [expr int(floor($maxfrq/$maxmaxfrq))]

					set msg "Too Many Harmonics For Pitches At And Above Midi $minmaxmidi: Max No Of Harmonics Is $maxpartial"
					append msg "\n\nReset Harmonics To This Maximum Count And Continue ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					} else {
						set gpitplate $maxpartial
						set harmcnt $gpitplate
					}
				}
				if {$pr_grpfilt == 2} {
					SaveGpFiltParams
					continue
				}
				set OK 1
				set n 0
				Block "Creating Filter Data Files"
				foreach midival $pvector {
					set filtfnam($n) $evv(MACH_OUTFNAME)
					append filtfnam($n) $n $evv(TEXT_EXT)
					if [catch {open $filtfnam($n) "w"} zit] {
						Inf "Cannot Open Temporary Filter File $filtfnam($n)"
						set OK 0
						break
					}
					set line 0
					lappend line $midival 1.0
					puts $zit $line
					set line 1000
					lappend line $midival 1.0
					puts $zit $line
					close $zit
					incr n
				}
				if {!$OK} {
					UnBlock
					continue
				}
			} else {

				;#	FILTER TYPES 2-3 : PARTIALS TEMPLATE

				if {$gpityp == 3} {
					if {[string length $gpiroot] <= 0} {
						Inf "No Root Level Entered"
						continue
					}
					if {![IsNumeric $gpiroot] || ($gpiroot < 0.0) || ($gpiroot > 1.0)} {
						Inf "Invalid Root Level Entered"
						continue
					}
				}
	
				if {[string length $gpitplate] <= 0} {
					Inf "No Filter Template Entered"
					continue
				}
				set xgpitplate [string tolower $gpitplate]
				if {[string length [file extension $xgpitplate]] == 0} {
					append xgpitplate ".txt"
				}
				if {![file exists $xgpitplate]} {
					Inf "$xgpitplate Is Not A Filter Template File"
					continue
				}
				if [catch {open $xgpitplate "r"} zit] {
					Inf "Cannot Open Template File $xgpitplate"
					continue
				}

				;#	READ AND CHECK TEMPLATE DATA


				Block "Checking Template Data"
				set linecnt 0
				set OK 1
				catch {unset partialvals}
				catch {unset partialamps}
				while {[gets $zit line] >= 0} {
					set line [string trim $line]
					if {([string length $line] <= 0) || [string match ";" [string index $line 0]]} {
						continue
					}
					set line [split $line]
					set itemcnt 0
					foreach item $line {
						set item [string trim $item]
						if {[string length $item] <= 0} {
							continue
						}
						switch -- $itemcnt {
							0 {
								if {$linecnt == 0} {
									set lastitem $item
								} elseif {$item <= $lastitem} {
									Inf "Partial-Numbers Or Frequency Values, In Template File, Must Increase"
									set OK 0
									break
								}
								lappend partialvals $item
							}
							1 {
								if {$item < 0.0 || $item > 1.0} {
									Inf "Template Amplitudes Must Lie Between 0 And 1"
									set OK 0
									break
								}
								lappend partialamps $item
							}
						}
						incr itemcnt
					}
					if {!$OK} {
						break
					}
					if {$itemcnt != 2} {
						Inf "Lines In Template Must Consist Of Value-Amplitude Pairs"
						set OK 0
						break
					}
					incr linecnt
				}
				if {$pr_grpfilt == 2} {
					UnBlock
					SaveGpFiltParams
					continue
				}
				close $zit
				if {!$OK} {
					UnBlock
					continue
				}
				switch -- $gpityp {
					2 {

						;#	FILTER TYPE WITH SAME PARTIALS FOR ALL PITCHES :  

						set OK 1
						foreach val $partialvals {
							if {$val < 1.0} {
								Inf "Template Partial Numbers Must Be Equal Or Greater Than 1"
								set OK 0
								break
							} else {
								foreach frq $pitchfrqs {
									if {[expr $frq * $val] >= $maxfrq} {
										Inf	"Partial Number $val Is Too High For Frequency $frq"
										set OK 0
										break
									}
								}
								if {!$OK} {
									break
								}
							}
						}
						if {!$OK} {
							UnBlock
							continue
						}
	
						;#		CREATE FILTER DATA FILES RELATED TO SPECIFIC PITCHES WITH FIXED PARTIALS INFO
						
						set n 0
						set m 1
						foreach midival $pvector {
							wm title .blocker "PLEASE WAIT:        Creating Filter Data file $m"
							set filtfnam($n) $evv(MACH_OUTFNAME)
							append filtfnam($n) $n $evv(TEXT_EXT)
							if [catch {open $filtfnam($n) "w"} zit] {
								Inf "Cannot Open Temporary Filter File $filtfnam($n)"
								continue
							}
							set line1 0
							set line2 1000
							lappend line1 $midival 1.0
							lappend line2 $midival 1.0
							puts $zit $line1
							puts $zit $line2
							set line "#"
							puts $zit $line
							set line1 0
							set line2 1000
							foreach val $partialvals amp $partialamps {
								lappend line1 $val $amp
								lappend line2 $val $amp
							}
							puts $zit $line1
							puts $zit $line2
							close $zit
							incr n
							incr m
						}
					}
					3 {

						;#	FILTER TYPE WITH DIFFERENT PARTIALS FOR EACH PITCH

						set OK 1
						foreach val $partialvals {
							if {$val < $minfrq || $val > $maxfrq} {
								Inf "Partial Frequencies Must Lie Between $minfrq And $maxfrq"
								set OK 0
								break
							}
						}
						if {!$OK} {
							UnBlock
							continue
						}
						set OK 1
						set n 0
						catch {unset gpi_template}
						set badlines 0
						foreach frq $pitchfrqs midival $pvector {
							set line1 0.0
							set line2 1000.0
							set lim 1
							if {$gpiroot > 0} {
								lappend line1 1 $gpiroot
								lappend line2 1 $gpiroot
								set lim 3
							}
							foreach ptlfrq $partialvals ptlamp $partialamps {
								set partial_ratio [expr $ptlfrq/$frq]
								if {$partial_ratio >= 1.0} {
									lappend line1 $partial_ratio $ptlamp
									lappend line2 $partial_ratio $ptlamp
								}
							}
							if {[llength $line1] <= $lim} {
								lappend badlines $n
							}
							set gpi_template($n) [list $line1 $line2]					
							incr n
						}
						if {!$OK} {
							UnBlock
							continue
						}
						if {$badlines} {
							set msg "Warning: No Partials Lie Above Fundamental For These Midi-Pitches\n"
							foreach n $badlines {
								append msg "[lindex $pvector $n] "
							}
							Inf $msg
						}

						;#		CREATE FILTER DATA FILES RELATED TO SPECIFIC PITCHES WITH FIXED RESONANCE

						set n 0
						set m 1
						foreach frq $pitchfrqs midival $pvector {
							wm title .blocker "PLEASE WAIT:        Creating Filter Data file $m"
							set filtfnam($n) $evv(MACH_OUTFNAME)
							append filtfnam($n) $n $evv(TEXT_EXT)
							if [catch {open $filtfnam($n) "w"} zit] {
								Inf "Cannot Open Temporary Filter File $filtfnam($n)"
								set OK 0
								break
							}
							set line1 0
							set line2 1000
							lappend line1 $midival 1.0
							lappend line2 $midival 1.0
							puts $zit $line1
							puts $zit $line2
							set line "#"
							puts $zit $line
							foreach line $gpi_template($n) {
								puts $zit $line
							}
							close $zit
							incr n
							incr m
						}
						if {!$OK} {
							UnBlock
							continue
						}
					}
				}
			}
			if {$grpfiltinv} {
				set n 0
				foreach midival $pvector {
					set invfnam($n) $evv(MACH_OUTFNAME)			;#	We will first invert the inputs
					append invfnam($n) $n $evv(SNDFILE_EXT)
					set donefnam($n) $evv(DFLT_OUTNAME)			;#	Then filter them
					append donefnam($n) $n $evv(SNDFILE_EXT)	;#	Before re-reversing them	
					incr n
				}
			} else {												
				set n 0											;#	If NOT inverting sounds....
				foreach midival $pvector {						;#	Filter directly to output sounds
					set donefnam($n) $ofnam($n)
					incr n
				}
			}
			if {$grpfiltinv} {						;#	IF SPECIFIED, REVERSE THE INPUT FILES
				set n 0
				set OK 1
				catch {unset nufnams}
				while {$n < $gpi_infnamcnt} {
					set ifnam [lindex $fnams $n]
					set basifnam [file rootname [file tail $ifnam]]
					wm title .blocker "PLEASE WAIT:        Reversing File $basifnam"
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					catch {unset CDPidrun}
					set cmd	[file join $evv(CDPROGRAM_DIR) modify]
					lappend cmd radical 1 $ifnam $invfnam($n)
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "Cannot Reverse File $basifnam: $CDPidrun"
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
						set msg "Failed To Reverse File $basifnam :"
						set msg [AddSimpleMessages $msg]
						Inf $msg
						set OK 0
						break
					}
					if {![file exists $invfnam($n)]} {
						set msg "Reversing File $basifnam Failed :"
						set msg [AddSimpleMessages $msg]
						Inf $msg
						set OK 0
						break
					}
					lappend nufnams $invfnam($n)
					incr n
				}
				if {!$OK} {
					UnBlock
					break
				}
				set fnams $nufnams				;#	REPLACE LISTING OF INPUT FILES, BY LISTING OF REVERSED INPUT FILES
			}
			set n 0
			set OK 1
			while {$n < $gpi_infnamcnt} {
				set ifnam [lindex $fnams $n]
				set basifnam [file rootname [file tail [lindex $origfnams $n]]]
				wm title .blocker "PLEASE WAIT:        Filtering File $basifnam"
				set prg_dun 0
				set prg_abortd 0
				catch {unset simple_program_messages}
				catch {unset CDPidrun}
				set cmd	[file join $evv(CDPROGRAM_DIR) filter]
				switch -- $gpityp {
					1 {
						lappend cmd varibank 2 $ifnam $donefnam($n) $filtfnam($n) $qvector($n) 1 -t0 -h$harmcnt -r0 -d
					}
					2 -
					3 {
						lappend cmd varibank2 2 $ifnam $donefnam($n) $filtfnam($n) $qvector($n) 1 -t0 -d
					}
				}
				if {$grpfiltnorm} {
					lappend cmd -n
				}
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "Cannot Filter File $basifnam: $CDPidrun"
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
					set msg "Failed To Filter File $basifnam :"
					set msg [AddSimpleMessages $msg]
					Inf $msg
					set OK 0
					break
				}
				if {![file exists $donefnam($n)]} {
					set msg "Filtering File $basifnam Failed :"
					set msg [AddSimpleMessages $msg]
					Inf $msg
					set OK 0
					break
				}
				incr n
			}
			if {!$OK} {
				if {$n > 0} {
					set msg "Keep Any Filtered Files Made ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						set m 0
						wm title .blocker "PLEASE WAIT:        Deleting Filtered Files"
						while {$m < $n} {
							catch {file delete $donefnam($m)}
							incr m
						}
					} else {
						wm title .blocker "PLEASE WAIT:        Putting Filtered Files on Workspace"
						set m 0
						catch {unset the_outfiles}
						while {$m < $n} {
							lappend the_outfiles $donefnam($m)
							incr m
						}
						set the_outfiles [ReverseList $the_outfiles]
						foreach f_nam $the_outfiles {
							FileToWkspace $f_nam 0 0 0 0 1
						}
					}
				}
				UnBlock
				break
			}
			if {$grpfiltinv} {						;#	IF REVERSAL SPECIFIED, RE-REVERSE THE OUTPUT FILES
				set n 0
				while {$n < $gpi_infnamcnt} {
					set ifnam $donefnam($n)
					set basifnam [file rootname [file tail [lindex $origfnams $n]]]
					wm title .blocker "PLEASE WAIT:        Re-Reversing Filtered File $basifnam"
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					catch {unset CDPidrun}
					set cmd	[file join $evv(CDPROGRAM_DIR) modify]
					lappend cmd radical 1 $ifnam $ofnam($n)
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "Cannot Re-Reverse Filtered Version Of File $basifnam: $CDPidrun"
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
						set msg "Failed To Re-Reverse Filtered Version Of File $basifnam :"
						set msg [AddSimpleMessages $msg]
						Inf $msg
						set OK 0
						break
					}
					if {![file exists $ofnam($n)]} {
						set msg "Re-Reversing Of Filtered Version Of File $basifnam Failed :"
						set msg [AddSimpleMessages $msg]
						Inf $msg
						set OK 0
						break
					}
					incr n
				}
				if {!$OK} {
					if {$n > 0} {
						set msg "Keep The Filtered (Not Re-Reversed) Files ??"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							set m 0
							wm title .blocker "PLEASE WAIT:        Deleting Filtered Files"
							while {$m < $n} {
								catch {file delete $ofnam($m)}
								incr m
							}
							set n 0
							while {$n < $gpi_infnamcnt} {
								catch {file delete $donefnam($n)}
								incr n
							}
						} else {
							wm title .blocker "PLEASE WAIT:        Putting Filtered Files on Workspace"
							set m 0
							while {$m < $n} {
								catch {file delete $ofnam($m)}
								incr m
							}
							set n 0
							catch {unset the_outfiles}
							while {$n < $gpi_infnamcnt} {
								catch {file rename $donefnam($n) $ofnam($n)}
								lappend the_outfiles $ofnam($n)
							}
							set the_outfiles [ReverseList $the_outfiles]
							foreach f_nam $the_outfiles {
								FileToWkspace $f_nam 0 0 0 0 1
								incr n
							}
						}
					}
					UnBlock
					break
				}
			}
			set n 0
			catch {unset the_outfiles}
			while {$n < $gpi_infnamcnt} {
				lappend the_outfiles $ofnam($n)
				incr n
			}
			set OK 1
			set the_outfiles [ReverseList $the_outfiles]
			foreach f_nam $the_outfiles {
				if {[FileToWkspace $f_nam 0 0 0 0 1] <= 0} {
					if {$grpfiltinv && ![info exists failed]} {
						set failed $f_nam
						set OK 0
					}
				}
				incr n
			}
			if {$grpfiltinv && !$OK} {
				set msg "Failed To Parse Filtered File $failed\n\n"
				append msg "Therefore Cannot Construct Output Mixfile.\n\n"
				append msg "The Filtered Soundfiles File Should Now Be On The Workspace."
				Inf $msg
				break
			}
			if {$mixin} {
				wm title .blocker "PLEASE WAIT:        Creating Mixfile Output"
				set m -1
				set n 0
				set outtime 0.0								;#	Start of first sound in mix
				set thisendtime $pa($ofnam(0),$evv(DUR))	;#	End of first sound in mix
				catch {unset numixoutlines}
				while {$n < $gpi_infnamcnt} {
					set mixoutline [lindex $mixoutlines $n]
					set mixoutline [lreplace $mixoutline 0 0 $ofnam($n)]
					if {$grpfiltinv} {
						if {$n > 0} {						;#	Calculate correct position for next output file
							set dur $pa($ofnam($n),$evv(DUR))
							set thisendtime [expr $lastendtime + [lindex $gpi_endendgap $m]] 
							set outtime [expr $thisendtime - $dur]
						}						
						set mixoutline [lreplace $mixoutline 1 1 $outtime]
						set lastendtime $thisendtime
					}
					lappend numixoutlines $mixoutline
					incr n
					incr m
				}
				if {$grpfiltinv} {							;#	EnSure new mix does not start before time zero
					set mintime 0.0
					foreach line $numixoutlines {
						set time [lindex $line 1]
						if {$time < $mintime} {
							set mintime $time
						}
					}
					if {$mintime < 0.0} {
						set mixoutlines $numixoutlines
						unset numixoutlines
						foreach mixoutline $mixoutlines {
							set time [lindex $mixoutline 1]
							set time [expr $time - $mintime]
							set mixoutline [lreplace $mixoutline 1 1 $time]
							lappend numixoutlines $mixoutline
						}
					}
				}
				if [catch {open $mixoutnam "w"} zit] {
					Inf "Cannot Open Mixfile $mixoutnam To Write Output Mix Data"
					UnBlock
					break
				}
				foreach line $numixoutlines {
					puts $zit $line
				}
				close $zit
				FileToWkspace $mixoutnam 0 0 0 0 1
			}
			Inf "The Output Files Should Now Be On The Workspace"
			UnBlock
			set finished 1
		} else {
			set finished 1
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc GrpFiltHelp {} {
	set msg "FILTERING A SEQUENCE OF SOUNDS\n"
	append msg "\n"
	append msg "Apply different filter params to either.\n"
	append msg "\n"
	append msg "    (1) a sequence of sounds.\n"
	append msg "    (2) All the files (in order) in a mixfile.\n"
	append msg "\n"
	append msg "Filter \"Pitch\" may be entered as a value (the same Pitch for all filters)\n"
	append msg "or as a \"Pitch-vector\", specifying a different Pitch for each filter,\n"
	append msg "\n"
	append msg "Filter \"Q\" may be entered as a value (the same Q for all filters)\n"
	append msg "or as a \"Q-vector\", specifying a different Q for each filter.\n"
	append msg "\n"
	append msg "\"Normalise Filter Output Levels\" means that the filter output is amplified\n"
	append msg "so that it has the same level as the sound being filtered.\n"
	append msg "\n"
	append msg "\"Time Reversed Sources\" means that the source sounds are time-reversed.\n"
	append msg "These sources will be un-reversed, processed, and re-reversed.\n"
	append msg "As the filter-processing usually makes output sounds longer than the inputs\n"
	append msg "we will need more information to know how to position the processed events\n"
	append msg "in the output mix so they occur at the same times as those in the input.\n"
	append msg "An additional textfile is therefore required, listing the time-gaps\n"
	append msg "between the ENDS of the input sounds.\n"
	append msg "\n"
	append msg "Filters are all double-filtered and are of 3 possible types.\n"
	append msg "\n"
	append msg "    (1) Varibank filter focused on a single pitch\n"
	append msg "             using specified number of harmonics.\n"
	append msg "             (and no \"roll-off\").\n"
	append msg "\n"
	append msg "    (2) Varipartial filter\n"
	append msg "              where partials are those of the specified pitch.\n"
	append msg                A textfile list of partialno-amplitude pairs is required\n"
	append msg "              where partial nos are >= 1\n"
	append msg "              and amplitudes lie between 0 and 1.\n"
	append msg "\n"
	append msg "    (3) Varipartial filter\n"
	append msg "              where the partials are of FIXED frequency,\n"
	append msg "              regardless of the input pitch.\n"
	append msg                A textfile list of frq-amplitude pairs is required\n"
	append msg "              where amplitudes lie between 0 and 1.\n"
	append msg "\n"
	append msg "              The partial number \"1\" representing the root pitch\n"
	append msg "              will be added to the filter spec, and the amplitude\n"
	append msg "              of this root-pitch filter must be specified\n"
	append msg "              in the box which appears.\n"
	append msg "\n"
	append msg "The complete patch spec can be saved for later use\n"
	append msg "and loaded as a whole at a later time.\n"
	append msg "\n"
	Inf $msg
}

proc RenameTemplate {} {
	global gpityp gpitplate gpiroot
	switch -- $gpityp {
		0 -
		1 {
			.grpfilt.4.ll config -text "No of harmonics"
			if {![IsNumeric $gpitplate]} {
				set gpitplate ""
			}
			.grpfilt.4.ll2 config -text ""
			.grpfilt.4.e2 config -bd 0  -state disabled -disabledbackground [option get . activebackground {}]
			set gpiroot ""
			bind .grpfilt.4.e <Right> {}
			bind .grpfilt.4.e2 <Left> {}
			bind .grpfilt.4.e2 <Up>   {}
			bind .grpfilt.4.e2 <Down> {}
			if {[string match [focus] .grpfilt.4.e2]} {
				focus .grpfilt.4.e
			}
		}
		2 {
			.grpfilt.4.ll config -text "Filter Template"
			if {[IsNumeric $gpitplate]} {
				set gpitplate ""
			}
			.grpfilt.4.ll2 config -text ""
			.grpfilt.4.e2 config -bd 0  -state disabled -disabledbackground [option get . activebackground {}]
			set gpiroot ""
			bind .grpfilt.4.e <Right> {}
			bind .grpfilt.4.e2 <Left> {}
			bind .grpfilt.4.e2 <Up>   {}
			bind .grpfilt.4.e2 <Down> {}
			if {[string match [focus] .grpfilt.4.e2]} {
				focus .grpfilt.4.e
			}
		}
		3 {
			.grpfilt.4.ll config -text "Filter Template"
			if {[IsNumeric $gpitplate]} {
				set gpitplate ""
			}
			.grpfilt.4.ll2 config -text "Root level"
			.grpfilt.4.e2 config -bd 2  -state normal
			bind .grpfilt.4.e <Right> {focus .grpfilt.4.e2}
			bind .grpfilt.4.e2 <Left> {focus .grpfilt.4.e}
			bind .grpfilt.4.e2 <Up>	  {focus .grpfilt.2.e}
			bind .grpfilt.4.e2 <Down> {focus .grpfilt.6.e}
		}
	}
}

proc GrpfiltGet {typ} {
	global wl pa evv pr_grpfiltget gpivec gpiqqq gpitplate gpi_infnamcnt gpi_endendgap
	foreach fnam [$wl get 0 end] {
		set ftyp $pa($fnam,$evv(FTYP))
		if {!($ftyp & $evv(IS_A_TEXTFILE))} {
			continue
		}
		lappend fnams $fnam
	}
	if {![info exists fnams]} {
		Inf "No Textfiles On The Workspace"
		return
	}
	foreach fnam $fnams {
		set ftyp $pa($fnam,$evv(FTYP))
		switch -- $typ {
			"pitch" {
				if {[IsAListofNumbers $ftyp] && ($pa($fnam,$evv(MINNUM)) >= 0) && ($pa($fnam,$evv(MAXNUM)) <= 127)} {
					lappend outlist $fnam
				}
			}
			"q" {
				if {[IsAListofNumbers $ftyp] && ($pa($fnam,$evv(MINNUM)) >= 8) && ($pa($fnam,$evv(MAXNUM)) <= 10000)} {
					lappend outlist $fnam
				}
			}
			"template" {
				if {[IsAListofNumbers $ftyp] && [IsEven $pa($fnam,$evv(NUMSIZE))]} {
					lappend outlist $fnam
				}
			}
			"timegaps" {
				if {[IsAListofNumbers $ftyp] && ($pa($fnam,$evv(MINNUM)) > 0.0) && ($pa($fnam,$evv(NUMSIZE)) == [expr $gpi_infnamcnt - 1])} {
					lappend outlist $fnam
				}
			}
		}
	}
	if {![info exists outlist]} {
		Inf "No Appropriate Datafiles On The Workspace"
		return
	}

	set f .grpfiltget
	if [Dlg_Create $f "POSSIBLE DATA FILES" "set pr_grpfiltget 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0] 
		set f1 [frame $f.1] 
		set f2 [frame $f.2] 
		button $f0.ok -text "Select" -command "set pr_grpfiltget 1" -bg $evv(EMPH)  -highlightbackground [option get . background {}]
		button $f0.quit -text "Abandon" -command "set pr_grpfiltget 0"  -highlightbackground [option get . background {}]
		pack $f0.ok -side left
		pack $f0.quit -side right
		pack $f0 -side top -fill x -expand true
		label $f1.ll -text "Select File from List" -width 20 -fg $evv(SPECIAL)
		pack $f1.ll -side top -pady 2
		pack $f1 -side top -fill x -expand true
		Scrolled_Listbox $f2.ll -width 60 -height 20 -selectmode single
		pack $f2.ll -side top -fill x -expand true
		pack $f2 -side top -fill x -expand true
		bind $f <Escape> {set pr_grpfiltget 0}
		bind $f <Return> {set pr_grpfiltget 1}
		bind $f2.ll.list <Double-1> {PossiblyPlaySnd .grpfiltget.2.ll.list %y}
		wm resizable $f 0 0
	}
	$f.2.ll.list delete 0 end
	set cnt 0
	foreach fnam $outlist {
		$f.2.ll.list insert end $fnam
		incr cnt
	}
	switch -- $typ {
		"pitch" {
			wm title $f "POSSIBLE MIDI-PITCH DATA"
		}
		"q" {
			wm title $f "POSSIBLE FILTER-Q DATA"
		}
		"template" {
			wm title $f "POSSIBLE FILTER-TEMPLATE DATA"
		}
		"timegaps" {
			wm title $f "POSSIBLE TIME-GAP DATA"
		}
	}
	set pr_grpfiltget 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_grpfiltget $f.2.ll.list
	while {!$finished} {
		tkwait variable pr_grpfiltget
		if {$pr_grpfiltget} {
			if {$cnt == 1} {
				set i 0
			} else {
				set i [$f.2.ll.list curselection]
			}
			if {$i < 0} {
				Inf "No File Selected"
				continue
			} else {
				switch -- $typ {
					"pitch" {
						set gpivec [$f.2.ll.list get $i]
					}
					"q" {
						set gpiqqq [$f.2.ll.list get $i]
					}
					"template" {
						set gpitplate [$f.2.ll.list get $i]
					}
					"timegaps" {
						set fnam [$f.2.ll.list get $i]
						if [catch {open $fnam "r"} zit] {
							Inf "Cannot Open File $fnam"
							break
						}
						catch {unset gpi_endendgap}
						while {[gets $zit line] >= 0} {
							set line [string trim $line]
							if {([string length $line] <= 0) || [string match ";" [string index $line 0]]} {
								continue
							}
							lappend gpi_endendgap $line
						}
						close $zit
					}
				}
				set finished 1
			}
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- Save a particular groupfilt patch

proc SaveGpFiltParams {} {
	global gpivec gpityp gpitplate gpiqqq grpfiltnorm grpfiltinv pr_savegpfp gpfp_fnam evv wstk gpf_patches gpiroot

	set patchfile [file join $evv(URES_DIR) __gpf$evv(CDP_EXT)]
	set newpatchvals [list $gpivec $gpiqqq $gpityp $gpitplate $grpfiltnorm $grpfiltinv]
	if {$gpityp == 3} {
		lappend newpatchvals $gpiroot
	}
	set f .savegpfp
	if [Dlg_Create $f "SAVE THE PATCH" "set pr_savegpfp 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0] 
		set f1 [frame $f.1] 
		set f2 [frame $f.2] 
		button $f0.ok -text "Save" -command "set pr_savegpfp 1" -bg $evv(EMPH)  -highlightbackground [option get . background {}]
		button $f0.quit -text "Abandon" -command "set pr_savegpfp 0"  -highlightbackground [option get . background {}]
		pack $f0.ok -side left
		pack $f0.quit -side right
		pack $f0 -side top -fill x -expand true
		label $f1.ll -text "Patch Name  "
		entry $f1.e -textvariable gpfp_fnam -width 20
		pack $f1.ll $f1.e -side left -padx 2
		pack $f1 -side top -fill x -expand true
		bind $f <Escape> {set pr_savegpfp 0}
		bind $f <Return> {set pr_savegpfp 1}
		wm resizable $f 0 0
	}
	set pr_savegpfp 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_savegpfp $f.1.e
	while {!$finished} {
		tkwait variable pr_savegpfp
		if {$pr_savegpfp} {
			if {[string length $gpfp_fnam] <= 0} {
				Inf "No Patch Name Entered"
				continue
			}
			set patchname [string tolower $gpfp_fnam] 
			if {![ValidCDPRootname $patchname]} {
				continue
			}
			set newpatch [concat $patchname $newpatchvals]
			if [info exists gpf_patches] {
				set OK 1
				set n 0
				foreach patch $gpf_patches {
					set nam [lindex $patch 0]
					if {[string match $nam $patchname]} {
						set msg "A Patch With This Name Already Exists: Overwrite It ??"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							set OK 0
						} else {
							set gpf_patches [lreplace $gpf_patches $n $n]
						}
						break
					}
					incr n
				}
				if {!$OK} {
					continue
				}
				lappend gpf_patches $newpatch
				catch {unset nams}
				foreach patch $gpf_patches {
					lappend nams [lindex $patch 0]
				}
				set nams [lsort -dictionary $nams]
				catch {unset newpatcheslist}
				foreach nam $nams {
					foreach patch $gpf_patches {
						if {[string match $nam [lindex $patch 0]]} {
							lappend newpatcheslist $patch
							break
						}
					}
				}
				set gpf_patches $newpatcheslist
			} else {
				set gpf_patches [list $newpatch]
			}
			if [catch {open $patchfile "w"} zit] {
				Inf "Cannot Open File $patchfile To Write The New Patch"
				break
			}
			foreach line $gpf_patches {
				puts $zit $line
			}
			close $zit
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- Get a particular groupfilt patch

proc GetGpFiltParams {} {
	global gpivec gpityp gpitplate gpiqqq grpfiltnorm grpfiltinv pr_loadgpfp gpfp_fnam evv wstk gpf_patches gpiroot

	set patchfile [file join $evv(URES_DIR) __gpf$evv(CDP_EXT)]
	if {![info exists gpf_patches]} {
		Inf "No Previous Patches Exist"
		return
	}
	set f .getgpfp
	if [Dlg_Create $f "LOAD A PATCH" "set pr_loadgpfp 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0] 
		set f1 [frame $f.1] 
		set f2 [frame $f.2] 
		button $f0.ok -text "Load" -command "set pr_loadgpfp 1" -bg $evv(EMPH)  -highlightbackground [option get . background {}]
		button $f0.del -text "Delete" -command "set pr_loadgpfp 2"  -highlightbackground [option get . background {}]
		button $f0.quit -text "Abandon" -command "set pr_loadgpfp 0"  -highlightbackground [option get . background {}]
		pack $f0.ok -side left
		pack $f0.quit -side right
		pack $f0 -side top -fill x -expand true
		Scrolled_Listbox $f1.ll -width 60 -height 20 -selectmode single
		pack $f1.ll -side top -fill x -expand true
		pack $f1 -side top -fill x -expand true
		bind $f.1.ll.list <Double-1> {ShowGFPatch %y}
		bind $f <Escape> {set pr_loadgpfp 0}
		bind $f <Return> {set pr_loadgpfp 1}
		wm resizable $f 0 0
	}
	$f.1.ll.list delete 0 end
	foreach patch $gpf_patches {
		$f.1.ll.list insert end [lindex $patch 0]
	}
	set pr_loadgpfp 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_loadgpfp $f.1.ll.list
	while {!$finished} {
		tkwait variable pr_loadgpfp
		switch -- $pr_loadgpfp {
			1 {
				if {[llength $gpf_patches] == 1} {
					set i 0
				} else {
					set i [$f.1.ll.list curselection]
					if {$i < 0} {
						Inf "No Patch Name Selected"
						continue
					}
				}
				set patch [lindex $gpf_patches $i]
				set patch [lrange $patch 1 end]
				set n 0
				foreach item $patch {
					switch -- $n {
						0 { set xgpivec $item }
						1 { set xgpiqqq $item }
						2 { set xgpityp $item }
						3 { set xgpitplate $item }
						4 { set xgrpfiltnorm $item }
						5 { set xgrpfiltinv $item }
						6 { set xgpiroot $item}
					}
					incr n
				}
				if {(($n == 7) && ($xgpityp != 3)) || (($n == 6) && ($xgpityp == 3))}  {
					Inf "Corrupted Data In Patch File [$f.1.ll.list get $i]"
					continue
				}
				set gpityp $xgpityp
				RenameTemplate
				set gpivec $xgpivec
				set gpiqqq $xgpiqqq
				set gpitplate $xgpitplate
				set grpfiltnorm $xgrpfiltnorm
				set grpfiltinv $xgrpfiltinv
				if {$gpityp == 3} {
					set gpiroot $xgpiroot
				}
				set finished 1
			}
			2 {
				if {[llength $gpf_patches] == 1} {
					set i 0
				} else {
					set i [$f.1.ll.list curselection]
					if {$i < 0} {
						Inf "No Patch Name Selected"
						continue
					}
				}
				set msg "Are You Sure You Want To ~~DELETE~~ Patch [$f.1.ll.list get $i] ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				} else {
					set gpf_patches [lreplace $gpf_patches $i $i]
					if {[llength $gpf_patches] == 0} {
						catch {unset gpf_patches}
						catch {file delete $patchfile}
					}
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

#---- Load groupfilt patches at start of session

proc LoadGpFiltPatches {} {
	global evv gpf_patches

	set patchfile [file join $evv(URES_DIR) __gpf$evv(CDP_EXT)]
	if {![file exists $patchfile]} {
		return
	}
	if [catch {open $patchfile "r"} zit] {
		Inf "Cannot Open Filter-Sequence-Patches File $patchfile To Read Data"
		return
	}
	set badlines 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		set len [llength $line]
		if {$len < 7 || $len > 8} {
			incr badlines
			continue
		}
		lappend gpf_patches $line
	}
	close $zit
	if {![info exists gpf_patches]} {
		Inf "No Valid Patches In Filter-Sequence-Patches File $patchfile"
		return
	}
	if {$badlines > 0} {
		Inf "Warning: Some Invalid Patches In Filter-Sequence-Patches File $patchfile"
	}
	return
}

proc ShowGFPatch {y} {
	global gpf_patches
	set i [.getgpfp.1.ll.list nearest $y]
	if {$i < 0} {
		return
	}
	set patch [lindex $gpf_patches $i]
	Inf "$patch"
}

##################################################
# CREATE LARGE NUMBER OF VARIANTS ON INPUT SOUND #
##################################################

proc VariboxInit {} {
	global evv
	set evv(VBOX_SWEL_DFLT) [list 0.074 0.075]					;#	dovetail 
	set evv(VBOX_SOFT_DFLT) [list 0.024 0.125]					;#	dovetail 
	set evv(VBOX_HARD_DFLT) [list 0.009 0.14]					;#	dovetail 
	set evv(VBOX_CLIP_DFLT) [list 0.009 0.14 0.009 0.05]		;#	dovetail + curtail
	set evv(VBOX_VIBF_DFLT)  8
	set evv(VBOX_VIBFLO_DFLT)  0
	set evv(VBOX_VIBFHI_DFLT)  12
	set evv(VBOX_VIBD_DFLT)  .65
	set evv(VBOX_VIBDLO_DFLT)  0
	set evv(VBOX_VIBDHI_DFLT)  1

	set evv(VBOX_TRMF_DFLT)		8
	set evv(VBOX_TRMFLO_DFLT)	1
	set evv(VBOX_TRMFHI_DFLT)	12
	set evv(VBOX_TRMD_DFLT)		1
	set evv(VBOX_TRMDLO_DFLT)	0
	set evv(VBOX_TRMDHI_DFLT)	1

	set evv(VBOX_TRMSQMIN_DFLT)	1
	set evv(VBOX_TRMSQMAX_DFLT)	1
	set evv(VBOX_TRMSQRESMAX_DFLT)	10

	set evv(VBOX_REP_DFLT)		.1
	set evv(VBOX_REPLO_DFLT)	.05
	set evv(VBOX_REPHI_DFLT)	.2

	set evv(VBOX_SWELL)	 [list 0 0 .2 .25 .4 1 .6 1 .8 .25 1 0]
	set evv(VBOX_SOFT)	 [list 0 0 .2 1 .4 .25 .6 .1 1 0]	
	set evv(VBOX_STRONG) [list 0 0 .04 1 .3 .25 .6 .1 1 0]
	set evv(VBOX_ATK)    [list 0 0 .01 1 .1 .25 .4 .1 1 0]

	set evv(VBOX_DRIFT_DFLT)	1

	set evv(VBOX_FIXDVAL_DRIFT)  0.25
	set evv(VBOX_RAND_TSTEP)  0.25
	set evv(VBOX_SHENVLIST)	[list "swell" "soft" "hard" "clip"]

	set evv(VBOX_STAKMIN_DFLT) 4
	set evv(VBOX_STAKMAX_DFLT) 4
	set evv(VBOX_STAKLEAN_DFLT) 3
	set evv(VBOX_OVERSUP_DFLT) 0

	set evv(VBOX_PREVMAX_DFLT) 800
	set evv(VBOX_PREVMIN_DFLT) 80
}

#--- The works

proc Varibox {} {
	global chlist ch chcnt evv pa wstk pr_varibox vb variboxmsgs wl last_outfile shortwindows

	catch {unset variboxmsgs}

	set evv(VB_GENERL) 0
	set evv(VB_STEADY) 1
	set evv(VB_WOBBLY) 2
	set evv(VB_ITERED) 3
	set evv(VB_PULSED) 4
	set evv(VB_ATKRES) 5

	if {![info exists chlist] || ([llength $chlist] != 1)} {
		Inf "Choose One Sound File"
		return
	}
	set vb(ifnam) [lindex $chlist 0]
	if {$pa($vb(ifnam),$evv(FTYP)) != $evv(SNDFILE)} {
		Inf "Choose One Sound File"
		return
	}
	set vb(chans) $pa($vb(ifnam),$evv(CHANS))
	set vb(indur) $pa($vb(ifnam),$evv(DUR))

	set f .varibox
	if [Dlg_Create $f "VARIBOX" "set pr_varibox 0" -borderwidth $evv(SBDR)] {
		set fx1 [frame $f.1] 
		set fx2 [frame $f.2] 

		set f00 [frame $fx1.00] 
		set f000 [frame $fx1.000] 
		set f01 [frame $fx1.01] 
		set f02 [frame $fx1.02] 
		set f0 [frame $fx1.0] 
		set f1 [frame $fx1.1] 
		set f2 [frame $fx2.2] 
		set f3 [frame $fx2.3] 
		set f4 [frame $fx2.4] 

		button $f00.ok -text "Generate Variants" -command "set pr_varibox 1" -bg $evv(EMPH) -width 17  -highlightbackground [option get . background {}]
		button $f00.save -text "Save Outputs" -command "set pr_varibox 6" -width 12  -highlightbackground [option get . background {}]
		button $f00.hh -text "Help" -command VariboxHelp -bg $evv(HELP)	  -width 4  -highlightbackground [option get . background {}]
		button $f00.play -text "Play Texture of Ouputs" -command "set pr_varibox 7" -width 23  -highlightbackground [option get . background {}]
		button $f00.quit -text "Quit" -command "set pr_varibox 0"  -highlightbackground [option get . background {}]

		pack $f00.hh $f00.ok $f00.play $f00.save -side left -padx 4
		pack $f00.quit -side right
		pack $f00 -side top -fill x -expand true -pady 2

		button $f000.dflt  -text "Load Default Params (\^D)" -command "set pr_varibox 2" -width 25  -highlightbackground [option get . background {}]
		button $f000.clear -text "Clear (\^C)" -command "set pr_varibox 3" -width 15  -highlightbackground [option get . background {}]
		button $f000.save  -text "Save Patch (\^S)" -command "set pr_varibox 4" -width 15  -highlightbackground [option get . background {}]
		button $f000.load  -text "Load or Delete Patch (\^L)" -command "set pr_varibox 5" -width 25  -highlightbackground [option get . background {}]
		pack $f000.dflt $f000.clear $f000.save $f000.load -side left -padx 2
		pack $f000 -side top -pady 2

		label $f01.ll -text "Generic Output Filename" -width 24
		entry $f01.e -textvariable vb(ofnam) -width 30
		pack $f01.ll $f01.e -side left
		pack $f01 -side top -fill x -expand true -pady 6
		label $f02.ll -text "-------------------------------- STYLE --------------------------------" -fg $evv(SPECIAL)
		frame $f02.0
		radiobutton $f02.0.all    -text "General"  -variable vb(typ) -value 0 -command "VaribankTypeConfigure $evv(VB_GENERL)"
		radiobutton $f02.0.steady -text "Steady"   -variable vb(typ) -value 1 -command "VaribankTypeConfigure $evv(VB_STEADY)"
		radiobutton $f02.0.wobbly -text "Wobbly"   -variable vb(typ) -value 2 -command "VaribankTypeConfigure $evv(VB_WOBBLY)"
		radiobutton $f02.0.itered -text "Iterates" -variable vb(typ) -value 3 -command "VaribankTypeConfigure $evv(VB_ITERED)"
		radiobutton $f02.0.pulsed -text "Pulsed"   -variable vb(typ) -value 4 -command "VaribankTypeConfigure $evv(VB_PULSED)"
		radiobutton $f02.0.atkres -text "Atk-Res"  -variable vb(typ) -value 5 -command "VaribankTypeConfigure $evv(VB_ATKRES)"
		pack $f02.0.all $f02.0.steady $f02.0.wobbly $f02.0.itered $f02.0.pulsed $f02.0.atkres -side left
		pack $f02.ll $f02.0 -side top -pady 2
		pack $f02 -side top -pady 2

		label $f0.ll -text "---------------- SHORT SEGMENT SHAPE : params in secs ----------------" -fg $evv(SPECIAL)
		pack $f0.ll -side top -pady 2
		frame $f0.0
		frame $f0.0.a
		label $f0.0.a.ll -text "SWELL" -fg $evv(SPECIAL)
		checkbutton $f0.0.a.x -text "X" -variable vb(noshswell) -command "VBX short swell"
		pack $f0.0.a.ll $f0.0.a.x -side left -anchor c
		set vb(noshswell) 0
		frame $f0.0.0
		label $f0.0.0.ll -text "   Dovetail Up" -width 30 -anchor w
		entry $f0.0.0.e -textvariable vb(shswelup) -width 6
		pack $f0.0.0.e $f0.0.0.ll -side left -fill x -expand true
		frame $f0.0.1
		label $f0.0.1.ll -text "   Dovetail Down" -width 30 -anchor w
		entry $f0.0.1.e -textvariable vb(shsweldn) -width 6
		pack $f0.0.1.e $f0.0.1.ll -side left -fill x -expand true
		pack $f0.0.a -side top -pady 2
		pack $f0.0.0 $f0.0.1 -side top -fill x -expand true -pady 2


		frame $f0.0.b
		label $f0.0.b.ll2 -text "SOFT" -fg $evv(SPECIAL)
		checkbutton $f0.0.b.x -text "X" -variable vb(noshsoft) -command "VBX short soft"
		pack $f0.0.b.ll2 $f0.0.b.x -side left -anchor c
		set vb(noshsoft) 0
		frame $f0.0.2
		label $f0.0.2.ll -text "   Dovetail Up" -width 30 -anchor w
		entry $f0.0.2.e -textvariable vb(shsoftup) -width 6
		pack $f0.0.2.e $f0.0.2.ll -side left -fill x -expand true
		frame $f0.0.3
		label $f0.0.3.ll -text "   Dovetail Down" -width 30 -anchor w
		entry $f0.0.3.e -textvariable vb(shsoftdn) -width 6
		pack $f0.0.3.e $f0.0.3.ll -side left -fill x -expand true
		pack $f0.0.b -side top -pady 2
		pack $f0.0.2 $f0.0.3 -side top -fill x -expand true -pady 2

		frame $f0.0.c
		radiobutton $f0.0.c.tr3 -text "8va TRANSPOSE" -variable vb(tors) -value 0 -fg $evv(SPECIAL) -command "VBTorS 0"
		label $f0.0.c.ll3 -text " or "
		radiobutton $f0.0.c.st3 -text "STACK" -variable vb(tors) -value 1 -fg $evv(SPECIAL) -command "VBTorS 1"
		set vb(tors) 0
		checkbutton $f0.0.c.x -text "X" -variable vb(nostak)
		pack $f0.0.c.tr3 $f0.0.c.ll3 $f0.0.c.st3 $f0.0.c.x -side left -anchor c
		set vb(nostak) 0
		frame $f0.0.4
		label $f0.0.4.ll -text "   Max 8va-down transpose" -width 30 -anchor w
		entry $f0.0.4.e -textvariable vb(stakmin) -width 6
		pack $f0.0.4.e $f0.0.4.ll -side left -fill x -expand true
		frame $f0.0.5
		label $f0.0.5.ll -text "   Max 8va-up transpose" -width 30 -anchor w
		entry $f0.0.5.e -textvariable vb(stakmax) -width 6
		pack $f0.0.5.e $f0.0.5.ll -side left -fill x -expand true
		frame $f0.0.6
		label $f0.0.6.ll -text "   Max Stack Lean" -width 18 -anchor w
		entry $f0.0.6.e -textvariable vb(staklean) -width 6
		checkbutton $f0.0.6.ps -text PreStack -variable vb(prestak) -width 12
		pack $f0.0.6.e $f0.0.6.ll $f0.0.6.ps -side left -fill x -expand true
		pack $f0.0.c -side top -pady 2
		pack $f0.0.4 $f0.0.5 $f0.0.6 -side top -fill x -expand true -pady 2

		frame $f0.1
		frame $f0.1.d
		label $f0.1.d.ll -text "HARD" -fg $evv(SPECIAL)
		checkbutton $f0.1.d.x -text "X" -variable vb(noshhard) -command "VBX short hard"
		pack $f0.1.d.ll $f0.1.d.x -side left -anchor c
		set vb(noshhard) 0
		frame $f0.1.0
		label $f0.1.0.ll -text "   Dovetail Up" -width 30 -anchor w
		entry $f0.1.0.e -textvariable vb(shhardup) -width 6
		pack $f0.1.0.e $f0.1.0.ll -side left -fill x -expand true
		frame $f0.1.1
		label $f0.1.1.ll -text "   Dovetail Down" -width 30 -anchor w
		entry $f0.1.1.e -textvariable vb(shharddn) -width 6
		pack $f0.1.1.e $f0.1.1.ll -side left -fill x -expand true
		pack $f0.1.d -side top
		pack $f0.1.0 $f0.1.1 -side top -fill x -expand true -pady 2

		frame $f0.1.e
		label $f0.1.e.ll2 -text "CLIP" -fg $evv(SPECIAL)
		checkbutton $f0.1.e.x -text "X" -variable vb(noshclip) -command "VBX short clip"
		pack $f0.1.e.ll2 $f0.1.e.x -side left -anchor c
		set vb(noshclip) 0
		frame $f0.1.2
		label $f0.1.2.ll -text "   Dovetail Up" -width 30 -anchor w
		entry $f0.1.2.e -textvariable vb(shclipup) -width 6
		pack $f0.1.2.e $f0.1.2.ll -side left -fill x -expand true
		frame $f0.1.3
		label $f0.1.3.ll -text "   Dovetail Down" -width 30 -anchor w
		entry $f0.1.3.e -textvariable vb(shclipdn) -width 6
		pack $f0.1.3.e $f0.1.3.ll -side left -fill x -expand true
		frame $f0.1.4
		label $f0.1.4.ll -text "   Curtail Start" -width 30 -anchor w
		entry $f0.1.4.e -textvariable vb(shclipstt) -width 6
		pack $f0.1.4.e $f0.1.4.ll -side left -fill x -expand true
		frame $f0.1.5
		label $f0.1.5.ll -text "   Curtail End" -width 30 -anchor w
		entry $f0.1.5.e -textvariable vb(shclipend) -width 6
		pack $f0.1.5.e $f0.1.5.ll -side left -fill x -expand true

		pack $f0.1.e -side top -pady 2
		pack $f0.1.2 $f0.1.3 $f0.1.4 $f0.1.5 -side top -fill x -expand true -pady 2

		label $f0.1.ll3 -text "OVERLAP SUPPRESSION" -fg $evv(SPECIAL)
		frame $f0.1.6
		label $f0.1.6.ll -text "   Overlap Suppress (0-1)" -width 30 -anchor w
		entry $f0.1.6.e -textvariable vb(oversup) -width 6
		pack $f0.1.6.e $f0.1.6.ll -side left -fill x -expand true
		frame $f0.1.7
		label $f0.1.7.ll -text "" -width 30 -anchor w
		entry $f0.1.7.e -textvariable vb(preverbmax) -width 6 -state disabled -bd 0 -disabledbackground [option get . background {}]
		pack $f0.1.7.e $f0.1.7.ll -side left -fill x -expand true

		pack $f0.1.ll3 -side top -pady 2
		pack $f0.1.6 $f0.1.7 -side top -fill x -expand true -pady 2

		pack $f0.0 $f0.1 -side left -anchor n

		label $f1.ll -text "------- SHORT SEGMENT REPEATS ---------------------- LONG SEGMENT PARAMS -------" -fg $evv(SPECIAL)
		frame $f1.0
		frame $f1.0.0
		label $f1.0.0.ll -text "   Fixed delay" -width 17 -anchor w
		entry $f1.0.0.e -textvariable vb(repdel)  -width 6
		pack $f1.0.0.e $f1.0.0.ll -side left -fill x -expand true
		frame $f1.0.1
		label $f1.0.1.ll -text "   Min Vari-delay" -width 17 -anchor w
		entry $f1.0.1.e -textvariable vb(repdello)  -width 6
		pack $f1.0.1.e $f1.0.1.ll -side left -fill x -expand true
		frame $f1.0.2
		label $f1.0.2.ll -text "   Max Vari-delay" -width 17 -anchor w
		entry $f1.0.2.e -textvariable vb(repdelhi)  -width 6
		pack $f1.0.2.e $f1.0.2.ll -side left -fill x -expand true
		pack $f1.0.0 $f1.0.1 $f1.0.2 -side top -pady 2

		frame $f1.1
		frame $f1.1.0
		checkbutton $f1.1.0.x -text "X-fix" -variable vb(nofixd) -width 15 -command "VBX repeat fix"
		set vb(nofixd) 0
		label $f1.1.0.ll -text "   Min Duration (secs)" -width 25 -anchor w
		entry $f1.1.0.e -textvariable vb(mindur)  -width 6
		pack $f1.1.0.x $f1.1.0.e $f1.1.0.ll -side left
		frame $f1.1.1
		checkbutton $f1.1.1.x -text "X-acc" -variable vb(noacc) -width 15 -command "VBX repeat  acc"
		set vb(noacc) 0
		label $f1.1.1.ll -text "   Max Duration (secs)" -width 25 -anchor w
		entry $f1.1.1.e -textvariable vb(maxdur)  -width 6
		pack $f1.1.1.x $f1.1.1.e $f1.1.1.ll -side left
		frame $f1.1.2
		checkbutton $f1.1.2.x -text "X-rit" -variable vb(norit) -width 15 -command "VBX repeat  rit"
		set vb(norit) 0
		label $f1.1.2.ll -text "   Max Pitchdrift (semit)" -width 25 -anchor w
		entry $f1.1.2.e -textvariable vb(glisvalval)  -width 6
		pack $f1.1.2.x $f1.1.2.e $f1.1.2.ll -side left
		pack $f1.1.0 $f1.1.1 $f1.1.2 -side top -fill x -expand true -pady 2

		pack $f1.ll -side top -pady 2
		pack $f1.0 $f1.1 -side left -anchor n

		frame $f2.ll
		label $f2.ll.ll -text "------------------------------ LONG SEGMENT VIBRATO " -fg $evv(SPECIAL)
		checkbutton $f2.ll.x -text "X" -variable vb(novib) -width 5
		set vb(novib) 0
		label $f2.ll.ll2 -text " ------------------------------" -fg $evv(SPECIAL)
		pack $f2.ll.ll $f2.ll.x $f2.ll.ll2 -side left
		pack $f2.ll -side top -pady 2
		frame $f2.0
		label $f2.0.ll -text "FREQ (Hz)" -fg $evv(SPECIAL)
		frame $f2.0.0
		checkbutton $f2.0.0.x -text "X-fix" -variable vb(novffixd) -width 5 -command "VBX vibfrq fix"
		set vb(novffixd) 0
		label $f2.0.0.ll -text "   Fixed Frq" -width 30 -anchor w
		entry $f2.0.0.e -textvariable vb(vibfrq) -width 6
		pack $f2.0.0.x $f2.0.0.e $f2.0.0.ll -side left -fill x -expand true
		frame $f2.0.1
		checkbutton $f2.0.1.x -text "X-acc" -variable vb(novfacc) -width 5 -command "VBX vibfrq acc"
		set vb(novfacc) 0
		label $f2.0.1.ll -text "   Min Variable Frq" -width 30 -anchor w
		entry $f2.0.1.e -textvariable vb(vibfrqlo) -width 6
		pack $f2.0.1.x $f2.0.1.e $f2.0.1.ll -side left -fill x -expand true
		frame $f2.0.2
		checkbutton $f2.0.2.x -text "X-rit" -variable vb(novfrit) -width 5 -command "VBX vibfrq rit"
		set vb(novfrit) 0
		label $f2.0.2.ll -text "   Max Variable Frq" -width 30 -anchor w
		entry $f2.0.2.e -textvariable vb(vibfrqhi) -width 6
		pack $f2.0.2.x $f2.0.2.e $f2.0.2.ll -side left -fill x -expand true
		pack $f2.0.ll -side top -pady 2
		pack $f2.0.0 $f2.0.1 $f2.0.2 -side top -fill x -expand true -pady 2

		frame $f2.1
		label $f2.1.ll -text "DEPTH (semitones)" -fg $evv(SPECIAL)
		pack $f2.1.ll -side top -pady 2
		frame $f2.1.0
		checkbutton $f2.1.0.x -text "X-fix" -variable vb(novdfixd) -width 5 -command "VBX vibdep fix"
		set vb(novdfixd) 0
		label $f2.1.0.ll -text "   Fixed depth" -width 30 -anchor w
		entry $f2.1.0.e -textvariable vb(vibdep) -width 6
		pack $f2.1.0.x $f2.1.0.e $f2.1.0.ll -side left -fill x -expand true
		frame $f2.1.1
		checkbutton $f2.1.1.x -text "X-acc" -variable vb(novdacc) -width 5 -command "VBX vibdep acc"
		set vb(novdacc) 0
		label $f2.1.1.ll -text "   Min Variable Depth" -width 30 -anchor w
		entry $f2.1.1.e -textvariable vb(vibdeplo) -width 6
		pack $f2.1.1.x $f2.1.1.e $f2.1.1.ll -side left -fill x -expand true
		frame $f2.1.2
		checkbutton $f2.1.2.x -text "X-rit" -variable vb(novdrit) -width 5 -command "VBX vibdep rit"
		set vb(novdrit) 0
		label $f2.1.2.ll -text "   Max Variable Depth" -width 30 -anchor w
		entry $f2.1.2.e -textvariable vb(vibdephi) -width 6
		pack $f2.1.2.x $f2.1.2.e $f2.1.2.ll -side left -fill x -expand true
		pack $f2.1.0 $f2.1.1 $f2.1.2 -side top -fill x -expand true -pady 2

		pack $f2.0 $f2.1 -side left -padx 2 -expand true

		frame $f3.ll
		label $f3.ll.ll -text "------------------------------ LONG SEGMENT TREMOLO " -fg $evv(SPECIAL)
		checkbutton $f3.ll.x -text "X" -variable vb(notrm) -width 5
		set vb(notrm) 0
		label $f3.ll.ll2 -text " ------------------------------" -fg $evv(SPECIAL)
		pack $f3.ll.ll $f3.ll.x $f3.ll.ll2 -side left
		pack $f3.ll -side top -pady 2
		frame $f3.0
		label $f3.0.ll -text "FREQ (Hz)" -fg $evv(SPECIAL)
		frame $f3.0.0
		checkbutton $f3.0.0.x -text "X-fix" -variable vb(notffixd) -width 5 -command "VBX trmfrq fix"
		set vb(notffixd) 0
		label $f3.0.0.ll -text "   Fixed Frq" -width 22 -anchor w
		entry $f3.0.0.e -textvariable vb(trmfrq) -width 6
		pack $f3.0.0.x $f3.0.0.e $f3.0.0.ll -side left -fill x -expand true
		frame $f3.0.1
		checkbutton $f3.0.1.x -text "X-acc" -variable vb(notfacc) -width 5 -command "VBX trmfrq acc"
		set vb(notfacc) 0
		label $f3.0.1.ll -text "   Min Variable Frq" -width 22 -anchor w
		entry $f3.0.1.e -textvariable vb(trmfrqlo) -width 6
		pack $f3.0.1.x $f3.0.1.e $f3.0.1.ll -side left -fill x -expand true
		frame $f3.0.2
		checkbutton $f3.0.2.x -text "X-rit" -variable vb(notfrit) -width 5 -command "VBX trmfrq rit"
		set vb(trmfrqlo) 0
		label $f3.0.2.ll -text "   Max Variable Frq" -width 22 -anchor w
		entry $f3.0.2.e -textvariable vb(trmfrqhi) -width 6
		pack $f3.0.2.x $f3.0.2.e $f3.0.2.ll -side left -fill x -expand true
		pack $f3.0.ll -side top -pady 2
		pack $f3.0.0 $f3.0.1 $f3.0.2 -side top -fill x -expand true -pady 2

		frame $f3.1
		label $f3.1.ll -text "DEPTH (0-1)" -fg $evv(SPECIAL)
		pack $f3.1.ll -side top -pady 2
		frame $f3.1.0
		checkbutton $f3.1.0.x -text "X-fix" -variable vb(notdfixd) -width 5 -command "VBX trmdep fix"
		set vb(notdfixd) 0
		label $f3.1.0.ll -text "   Fixed depth" -width 22 -anchor w
		entry $f3.1.0.e -textvariable vb(trmdep) -width 6
		pack $f3.1.0.x $f3.1.0.e $f3.1.0.ll -side left -fill x -expand true
		frame $f3.1.1
		checkbutton $f3.1.1.x -text "X-acc" -variable vb(notdacc) -width 5 -command "VBX trmdep acc"
		set vb(notdacc) 0
		label $f3.1.1.ll -text "   Min Variable Depth" -width 22 -anchor w
		entry $f3.1.1.e -textvariable vb(trmdeplo) -width 6
		pack $f3.1.1.x $f3.1.1.e $f3.1.1.ll -side left -fill x -expand true
		frame $f3.1.2
		checkbutton $f3.1.2.x -text "X-rit" -variable vb(notdrit) -width 5 -command "VBX trmdep rit"
		set vb(notdrit) 0
		label $f3.1.2.ll -text "   Max Variable Depth" -width 22 -anchor w
		entry $f3.1.2.e -textvariable vb(trmdephi) -width 6
		pack $f3.1.2.x $f3.1.2.e $f3.1.2.ll -side left -fill x -expand true
		pack $f3.1.0 $f3.1.1 $f3.1.2 -side top -fill x -expand true -pady 2

		frame $f3.2
		label $f3.2.ll -text "NARROW (1-100)" -fg $evv(SPECIAL)
		pack $f3.2.ll -side top -pady 2
		frame $f3.2.0
		label $f3.2.0.ll -text "   Min" -width 10 -anchor w
		entry $f3.2.0.e -textvariable vb(trmsqmin) -width 6
		pack $f3.2.0.e $f3.2.0.ll -side left -fill x -expand true
		frame $f3.2.1
		label $f3.2.1.ll -text "   Max" -width 10 -anchor w
		entry $f3.2.1.e -textvariable vb(trmsqmax) -width 6
		pack $f3.2.1.e $f3.2.1.ll -side left -fill x -expand true
		pack $f3.2.0 $f3.2.1 -side top -fill both -expand true -pady 2

		pack $f3.0 $f3.1 $f3.2 -side left -padx 2 -expand true -anchor n

		frame $f4.ll
		label $f4.ll.ll -text "-------------- ENVELOPE FORMS ------------------------------------- POST-REVERB " -fg $evv(SPECIAL)
		checkbutton $f4.ll.x -text "X" -variable vb(norev) -command "VBenvX"
		set vb(norev) 1
		pack $f4.ll.ll $f4.ll.x -side left
		pack $f4.ll -side top -pady 2
		frame $f4.0
		frame $f4.0.0
		label $f4.0.0.ll -text "Swell" -width 10
		entry $f4.0.0.e -textvariable vb(swellval)  -width 6
		checkbutton $f4.0.0.x -text "X" -variable vb(noeswell) -width 5 -command "VBX env swell"
		set vb(noeswell) 0
		set vb(swellval) ""
		pack $f4.0.0.e $f4.0.0.ll $f4.0.0.x -side left
		frame $f4.0.1
		label $f4.0.1.ll -text "Soft" -width 10
		entry $f4.0.1.e -textvariable vb(softval)  -width 6
		checkbutton $f4.0.1.x -text "X" -variable vb(noesoft) -width 5 -command "VBX env soft"
		set vb(noesoft) 0
		set vb(softval) ""
		pack $f4.0.1.e $f4.0.1.ll $f4.0.1.x -side left
		frame $f4.0.2
		label $f4.0.2.ll -text "Strong" -width 10
		entry $f4.0.2.e -textvariable vb(strongval)  -width 6
		checkbutton $f4.0.2.x -text "X" -variable vb(noestrong) -width 5 -command "VBX env strong"
		set vb(noestrong) 0
		set vb(strongval) ""
		pack $f4.0.2.e $f4.0.2.ll $f4.0.2.x -side left
		frame $f4.0.3
		label $f4.0.3.ll -text "Attacked" -width 10
		entry $f4.0.3.e -textvariable vb(atkval)  -width 6
		checkbutton $f4.0.3.x -text "X" -variable vb(noeatk) -width 5 -command "VBX env atk"
		set vb(noeatk) 0
		set vb(atkval) ""
		pack $f4.0.3.e $f4.0.3.ll $f4.0.3.x -side left
		frame $f4.1
		radiobutton $f4.1.rrr -text "Apply envelopes at random"    -width 30 -variable vb(all) -value 0
		radiobutton $f4.1.all -text "Apply every env to every snd" -width 30 -variable vb(all) -value 1
		set vb(all) -1
		pack $f4.1.rrr $f4.1.all -side top -anchor c
		frame $f4.2
		frame $f4.2.0
		label $f4.2.0.ll -text "Min short (80-250)" -width 20
		entry $f4.2.0.e -textvariable vb(minlorev)  -width 6
		set vb(minlorev) ""
		pack $f4.2.0.e $f4.2.0.ll -side left
		frame $f4.2.1
		label $f4.2.1.ll -text "Max short (80-250)" -width 20
		entry $f4.2.1.e -textvariable vb(maxlorev)  -width 6
		set vb(maxlorev) ""
		pack $f4.2.1.e $f4.2.1.ll -side left
		frame $f4.2.2
		label $f4.2.2.ll -text "Min long (250-1000)" -width 20
		entry $f4.2.2.e -textvariable vb(minhirev)  -width 6
		set vb(minhirev) ""
		pack $f4.2.2.e $f4.2.2.ll -side left
		frame $f4.2.3
		label $f4.2.3.ll -text "Max long (250-1000)" -width 20
		entry $f4.2.3.e -textvariable vb(maxhirev)  -width 6
		set vb(maxhirev) ""
		pack $f4.2.3.e $f4.2.3.ll -side left
		pack $f4.2.0 $f4.2.1 $f4.2.2 $f4.2.3 -side top -fill x -expand true -pady 2
		frame $f4.2.4
		label $f4.2.4.ll -text "N = 1/N dry outputs" -width 20
		entry $f4.2.4.e -textvariable vb(dryrev)  -width 6
		pack $f4.2.4.e $f4.2.4.ll -side left
		pack $f4.2.0 $f4.2.1 $f4.2.2 $f4.2.3 $f4.2.4 -side top -fill both -pady 2

		pack $f4.0.0 $f4.0.1 $f4.0.2 $f4.0.3 -side top -expand true -pady 2

		pack $f4.0 $f4.1 $f4.2 -side left -fill both -expand true -anchor n

		pack $f0 $f1 -side top

		pack $f2 $f3 $f4 -side top

		if {[info exists shortwindows]} {
			pack $fx1 $fx2 -side left
		} else {
			pack $fx1 $fx2 -side top
		}

		bind $f <Escape> {set pr_varibox 0}
		bind $f <Return> {set pr_varibox 1}
		bind $f <Control-Key-d> {set pr_varibox 2}
		bind $f <Control-Key-D> {set pr_varibox 2}
		bind $f <Control-Key-c> {set pr_varibox 3}
		bind $f <Control-Key-C> {set pr_varibox 3}
		bind $f <Control-Key-s> {set pr_varibox 4}
		bind $f <Control-Key-S> {set pr_varibox 4}
		bind $f <Control-Key-l> {set pr_varibox 5}
		bind $f <Control-Key-L> {set pr_varibox 5}
		wm resizable $f 0 0

		bind .varibox.1.01.e    <Control-Down> {focus .varibox.1.0.0.0.e}
		bind .varibox.1.0.0.0.e <Control-Down> {focus .varibox.1.0.0.1.e}
		bind .varibox.1.0.0.1.e <Control-Down> {focus .varibox.1.0.0.2.e}
		bind .varibox.1.0.0.2.e <Control-Down> {focus .varibox.1.0.0.3.e}
		bind .varibox.1.0.0.3.e <Control-Down> {focus .varibox.1.0.0.4.e}
		bind .varibox.1.0.0.4.e <Control-Down> {focus .varibox.1.0.0.5.e}
		if {$vb(tors)} {
			bind .varibox.1.0.0.5.e <Control-Down> {focus .varibox.1.0.0.6.e}
			bind .varibox.1.0.0.6.e <Control-Down> {focus .varibox.1.1.0.0.e}
		} else {
			bind .varibox.1.0.0.5.e <Control-Down> {focus .varibox.1.1.0.0.e}
		}
		bind .varibox.1.0.1.0.e <Control-Down> {focus .varibox.1.0.1.1.e}
		bind .varibox.1.0.1.1.e <Control-Down> {focus .varibox.1.0.1.2.e}
		bind .varibox.1.0.1.2.e <Control-Down> {focus .varibox.1.0.1.3.e}
		bind .varibox.1.0.1.3.e <Control-Down> {focus .varibox.1.0.1.4.e}
		bind .varibox.1.0.1.4.e <Control-Down> {focus .varibox.1.0.1.5.e}
		bind .varibox.1.0.1.5.e <Control-Down> {focus .varibox.1.1.1.0.e}

		bind .varibox.1.1.0.0.e <Control-Down> {focus .varibox.1.1.0.1.e}
		bind .varibox.1.1.0.1.e <Control-Down> {focus .varibox.1.1.0.2.e}
		bind .varibox.1.1.0.2.e <Control-Down> {focus .varibox.2.2.0.0.e}

		bind .varibox.1.1.1.0.e <Control-Down> {focus .varibox.1.1.1.1.e}
		bind .varibox.1.1.1.1.e <Control-Down> {focus .varibox.1.1.1.2.e}
		bind .varibox.1.1.1.2.e <Control-Down> {focus .varibox.2.2.1.0.e}

		bind .varibox.2.2.0.0.e <Control-Down> {focus .varibox.2.2.0.1.e}
		bind .varibox.2.2.0.1.e <Control-Down> {focus .varibox.2.2.0.2.e}
		bind .varibox.2.2.0.2.e <Control-Down> {focus .varibox.2.3.0.0.e}

		bind .varibox.2.2.1.0.e <Control-Down> {focus .varibox.2.2.1.1.e}
		bind .varibox.2.2.1.1.e <Control-Down> {focus .varibox.2.2.1.2.e}
		bind .varibox.2.2.1.2.e <Control-Down> {focus .varibox.2.3.1.0.e}

		bind .varibox.2.3.0.0.e <Control-Down> {focus .varibox.2.3.0.1.e}
		bind .varibox.2.3.0.1.e <Control-Down> {focus .varibox.2.3.0.2.e}
		bind .varibox.2.3.0.2.e <Control-Down> {focus .varibox.2.4.0.0.e}

		bind .varibox.2.3.1.0.e <Control-Down> {focus .varibox.2.3.1.1.e}
		bind .varibox.2.3.1.1.e <Control-Down> {focus .varibox.2.3.1.2.e}
		bind .varibox.2.3.1.2.e <Control-Down> {focus .varibox.2.4.0.0.e}

		bind .varibox.2.3.2.0.e <Control-Down>  {focus .varibox.2.3.2.1.e}
		bind .varibox.2.3.2.0.e <Control-Up>    {focus .varibox.2.2.1.2.e}
		bind .varibox.2.3.2.1.e <Control-Up>    {focus .varibox.2.3.2.0.e}
		bind .varibox.2.3.2.0.e <Control-Left>  {focus .varibox.2.3.1.0.e}
		bind .varibox.2.3.2.1.e <Control-Left>  {focus .varibox.2.3.1.1.e}
		bind .varibox.2.3.1.0.e <Control-Right> {focus .varibox.2.3.2.0.e}
		bind .varibox.2.3.1.1.e <Control-Right> {focus .varibox.2.3.2.1.e}
		bind .varibox.2.3.1.2.e <Control-Right> {focus .varibox.2.3.2.1.e}

		bind .varibox.2.3.2.1.e <Control-Down>  {focus .varibox.2.4.2.0.e}
		bind .varibox.2.4.2.0.e <Control-Down>  {focus .varibox.2.4.2.1.e}
		bind .varibox.2.4.2.1.e <Control-Down>  {focus .varibox.2.4.2.2.e}
		bind .varibox.2.4.2.2.e <Control-Down>  {focus .varibox.2.4.2.3.e}
		bind .varibox.2.4.2.3.e <Control-Down>  {focus .varibox.2.4.2.4.e}
		bind .varibox.2.4.2.4.e <Control-Down>  {focus .varibox.1.01.e}
		bind .varibox.2.4.2.0.e <Control-Up>  {focus .varibox.2.3.2.1.e}
		bind .varibox.2.4.2.1.e <Control-Up>  {focus .varibox.2.4.2.0.e}
		bind .varibox.2.4.2.2.e <Control-Up>  {focus .varibox.2.4.2.1.e}
		bind .varibox.2.4.2.3.e <Control-Up>  {focus .varibox.2.4.2.2.e}
		bind .varibox.2.4.2.4.e <Control-Up>  {focus .varibox.2.4.2.3.e}

		bind .varibox.2.4.2.0.e <Control-Left>  {focus .varibox.2.4.0.0.e}
		bind .varibox.2.4.2.1.e <Control-Left>  {focus .varibox.2.4.0.1.e}
		bind .varibox.2.4.2.2.e <Control-Left>  {focus .varibox.2.4.0.2.e}
		bind .varibox.2.4.2.3.e <Control-Left>  {focus .varibox.2.4.0.2.e}
		bind .varibox.2.4.2.4.e <Control-Left>  {focus .varibox.2.4.0.3.e}
		bind .varibox.2.4.0.0.e <Control-Right> {focus .varibox.2.4.2.0.e}
		bind .varibox.2.4.0.1.e <Control-Right> {focus .varibox.2.4.2.1.e}
		bind .varibox.2.4.0.2.e <Control-Right> {focus .varibox.2.4.2.2.e}
		bind .varibox.2.4.0.3.e <Control-Right> {focus .varibox.2.4.2.3.e}

		bind .varibox.2.4.0.0.e <Control-Down> {focus .varibox.2.4.0.1.e}
		bind .varibox.2.4.0.1.e <Control-Down> {focus .varibox.2.4.0.2.e}
		bind .varibox.2.4.0.2.e <Control-Down> {focus .varibox.2.4.0.3.e}
		bind .varibox.2.4.0.3.e <Control-Down> {focus .varibox.1.01.e}

		bind .varibox.1.01.e    <Control-Up> {focus .varibox.2.4.0.3.e}
		bind .varibox.1.0.0.0.e <Control-Up> {focus .varibox.1.01.e}
		bind .varibox.1.0.0.1.e <Control-Up> {focus .varibox.1.0.0.0.e}
		bind .varibox.1.0.0.2.e <Control-Up> {focus .varibox.1.0.0.1.e}
		bind .varibox.1.0.0.3.e <Control-Up> {focus .varibox.1.0.0.2.e}
		bind .varibox.1.0.0.4.e <Control-Up> {focus .varibox.1.0.0.3.e}
		bind .varibox.1.0.0.5.e <Control-Up> {focus .varibox.1.0.0.4.e}
		bind .varibox.1.0.0.6.e <Control-Up> {focus .varibox.1.0.0.5.e}

		bind .varibox.1.0.1.0.e <Control-Up> {focus .varibox.1.01.e}
		bind .varibox.1.0.1.1.e <Control-Up> {focus .varibox.1.0.1.0.e}
		bind .varibox.1.0.1.2.e <Control-Up> {focus .varibox.1.0.1.1.e}
		bind .varibox.1.0.1.3.e <Control-Up> {focus .varibox.1.0.1.2.e}
		bind .varibox.1.0.1.4.e <Control-Up> {focus .varibox.1.0.1.3.e}
		bind .varibox.1.0.1.5.e <Control-Up> {focus .varibox.1.0.1.4.e}

		bind .varibox.1.1.0.0.e <Control-Up> {focus .varibox.1.0.0.3.e}
		bind .varibox.1.1.0.1.e <Control-Up> {focus .varibox.1.1.0.0.e}
		bind .varibox.1.1.0.2.e <Control-Up> {focus .varibox.1.1.0.1.e}

		bind .varibox.1.1.1.0.e <Control-Up> {focus .varibox.1.0.1.5.e}
		bind .varibox.1.1.1.1.e <Control-Up> {focus .varibox.1.1.1.0.e}
		bind .varibox.1.1.1.2.e <Control-Up> {focus .varibox.1.1.1.1.e}

		bind .varibox.2.2.0.0.e <Control-Up> {focus .varibox.1.1.0.2.e}
		bind .varibox.2.2.0.1.e <Control-Up> {focus .varibox.2.2.0.0.e}
		bind .varibox.2.2.0.2.e <Control-Up> {focus .varibox.2.2.0.1.e}

		bind .varibox.2.2.1.0.e <Control-Up> {focus .varibox.1.1.1.2.e}
		bind .varibox.2.2.1.1.e <Control-Up> {focus .varibox.2.2.1.0.e}
		bind .varibox.2.2.1.2.e <Control-Up> {focus .varibox.2.2.1.1.e}

		bind .varibox.2.3.0.0.e <Control-Up> {focus .varibox.2.2.0.2.e}
		bind .varibox.2.3.0.1.e <Control-Up> {focus .varibox.2.3.0.0.e}
		bind .varibox.2.3.0.2.e <Control-Up> {focus .varibox.2.3.0.1.e}

		bind .varibox.2.3.1.0.e <Control-Up> {focus .varibox.2.2.1.2.e}
		bind .varibox.2.3.1.1.e <Control-Up> {focus .varibox.2.3.1.0.e}
		bind .varibox.2.3.1.2.e <Control-Up> {focus .varibox.2.3.1.1.e}

		bind .varibox.2.4.0.0.e <Control-Up> {focus .varibox.2.3.0.2.e}
		bind .varibox.2.4.0.1.e <Control-Up> {focus .varibox.2.4.0.0.e}
		bind .varibox.2.4.0.2.e <Control-Up> {focus .varibox.2.4.0.1.e}

		bind .varibox.2.4.0.0.e <Control-Up> {focus .varibox.2.3.0.2.e}
		bind .varibox.2.4.0.1.e <Control-Up> {focus .varibox.2.4.0.0.e}
		bind .varibox.2.4.0.2.e <Control-Up> {focus .varibox.2.4.0.1.e}
		bind .varibox.2.4.0.3.e <Control-Up> {focus .varibox.2.4.0.2.e}

		bind .varibox.1.01.e <Control-Right> {focus .varibox.1.0.1.0.e}
		bind .varibox.1.01.e <Control-Left>  {focus .varibox.1.0.0.0.e}


		bind .varibox.1.0.0.0.e <Control-Right> {focus .varibox.1.0.1.0.e}
		bind .varibox.1.0.1.0.e <Control-Left>  {focus .varibox.1.0.0.0.e}
		bind .varibox.1.0.0.1.e <Control-Right> {focus .varibox.1.0.1.1.e}
		bind .varibox.1.0.1.1.e <Control-Left>  {focus .varibox.1.0.0.1.e}
		bind .varibox.1.0.0.2.e <Control-Right> {focus .varibox.1.0.1.2.e}
		bind .varibox.1.0.1.2.e <Control-Left>  {focus .varibox.1.0.0.2.e}
		bind .varibox.1.0.0.3.e <Control-Right> {focus .varibox.1.0.1.3.e}
		bind .varibox.1.0.1.3.e <Control-Left>  {focus .varibox.1.0.0.3.e}
		
		bind .varibox.1.0.0.4.e <Control-Right> {focus .varibox.1.0.1.4.e}
		bind .varibox.1.0.1.4.e <Control-Left>  {focus .varibox.1.0.0.4.e}
		bind .varibox.1.0.0.5.e <Control-Right> {focus .varibox.1.0.1.5.e}
		bind .varibox.1.0.1.5.e <Control-Left>  {focus .varibox.1.0.0.5.e}
		bind .varibox.1.0.0.6.e <Control-Right> {focus .varibox.1.0.1.5.e}

		bind .varibox.1.0.1.4.e <Control-Left>  {focus .varibox.1.0.0.3.e}
		bind .varibox.1.0.1.5.e <Control-Left>  {focus .varibox.1.0.0.3.e}

		bind .varibox.1.1.0.0.e <Control-Right> {focus .varibox.1.1.1.0.e}
		bind .varibox.1.1.1.0.e <Control-Left>  {focus .varibox.1.1.0.0.e}
		bind .varibox.1.1.0.1.e <Control-Right> {focus .varibox.1.1.1.1.e}
		bind .varibox.1.1.1.1.e <Control-Left>  {focus .varibox.1.1.0.1.e}
		bind .varibox.1.1.0.2.e <Control-Right> {focus .varibox.1.1.1.2.e}
		bind .varibox.1.1.1.2.e <Control-Left>  {focus .varibox.1.1.0.2.e}

		bind .varibox.2.2.0.0.e <Control-Right> {focus .varibox.2.2.1.0.e}
		bind .varibox.2.2.1.0.e <Control-Left>  {focus .varibox.2.2.0.0.e}
		bind .varibox.2.2.0.1.e <Control-Right> {focus .varibox.2.2.1.1.e}
		bind .varibox.2.2.1.1.e <Control-Left>  {focus .varibox.2.2.0.1.e}
		bind .varibox.2.2.0.2.e <Control-Right> {focus .varibox.2.2.1.2.e}
		bind .varibox.2.2.1.2.e <Control-Left>  {focus .varibox.2.2.0.2.e}

		bind .varibox.2.3.0.0.e <Control-Right> {focus .varibox.2.3.1.0.e}
		bind .varibox.2.3.1.0.e <Control-Left>  {focus .varibox.2.3.0.0.e}
		bind .varibox.2.3.0.1.e <Control-Right> {focus .varibox.2.3.1.1.e}
		bind .varibox.2.3.1.1.e <Control-Left>  {focus .varibox.2.3.0.1.e}
		bind .varibox.2.3.0.2.e <Control-Right> {focus .varibox.2.3.1.2.e}
		bind .varibox.2.3.1.2.e <Control-Left>  {focus .varibox.2.3.0.2.e}
	}
	.varibox.1.00.play config -bd 0 -text "" -state disabled
	.varibox.1.00.save config -bd 0 -text "" -state disabled

	if {![info exists vb(typ)] || ([string length $vb(typ)] == 0)} {
		set vb(typ) $evv(VB_GENERL)
	}
	VaribankTypeConfigure $vb(typ)
	set pr_varibox 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_varibox $f.1.01.e
	while {!$finished} {
		tkwait variable pr_varibox
		switch -- $pr_varibox {
			0 {
				if {![info exists real_outputs] && [info exists variboxouts]} {
					set msg "Save The Files Generated ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						VariBoxSaveOutput $variboxouts
					} else {
						VariBoxRemoveOutputs $variboxouts 0
					}
				}
				catch {file delete $vb(sample)}
				catch {file delete $vb(notedata)}
				set finished 1
			}
			1 {

				catch {unset variboxouts}
				catch {unset real_outputs}
				if {[info exists vb(sample)] && [file exists $vb(sample)]} {
					if [catch {file delete $vb(sample)} zit] {
						Inf "Cannot Delete Existing Output-Sample Sound"
					}
				}
				if {[info exists vb(notedata)] && [file exists $vb(notedata)]} {
					if [catch {file delete $vb(notedata)} zit] {
						Inf "Cannot Delete Existing Output-Sample Texture Data File"
					}
				}

				;#	REMOVE OUTPUTS OF ANY PREVIOUS FAILED PASS

				if {[info exists variboxmsgs]} {
					DoVariboxErrorReport
					unset variboxmsgs
				}
				if {[info exists vb(outs)]} {
					foreach f_nam $vb(outs) {
						catch {file delete $fnam}
					}
				}
				DeleteAllTemporaryFiles

				;#	OUTFILE NAME

				set OK 1
				set outfnam [string tolower $vb(ofnam)]
				if {![ValidCDPRootname $outfnam]} {
					continue
				}
				set len [string length $outfnam]
				foreach fnam [glob -nocomplain *] {
					if {[file isdirectory $fnam]} {
						continue
					}
					if {[string first $outfnam $fnam] == 0} {
						if {[regexp {^[0-9]$} [string index $fnam $len]]} {
							set OK 0
							break
						}
					}
				}
				if {!$OK} {
					set msg "Files Using Generic Name $vb(ofnam) Already Exist: Overwrite Them ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
					catch {unset badfiles}
					foreach fnam [glob -nocomplain *] {
						if {[file isdirectory $fnam]} {
							continue
						}
						set ext [file extension $fnam]
						set rfnam [file rootname [file tail $fnam]]
						if {[string match $ext $evv(SNDFILE_EXT)]} {
							if {[string first $outfnam $rfnam] == 0} {
								if {[regexp {^[0-9]$} [string index $rfnam $len]]} {
									lappend badfiles $fnam
								}
							}
						}
					}
					if {[info exists badfiles]} {
						if {![VariBoxRemoveOutputs $badfiles 1]} {
							continue
						}
					}
				}
				if {$vb(typ) == $evv(VB_ATKRES)} {
					set vb(swell) $evv(VBOX_SWELL)
					set vb(soft) $evv(VBOX_SOFT)
					set vb(strong) $evv(VBOX_STRONG)
					set vb(atk) $evv(VBOX_ATK)
				} else {

					;#	READ LARGE-SCALE ENVELOPES

					if {$vb(all) < 0} {
						Inf "You Must Choose Whether Or Not To Apply The Final Envelopes At Random"
						continue
					}

					set envlist {}

					if {!$vb(noeswell)} {
						set vb(swellval) [string trim $vb(swellval)]
						if {[string length $vb(swellval)] <= 0} {
							set vb(swell) $evv(VBOX_SWELL)
						} else {
							if {![file exists $vb(swellval)]} {
								Inf "File $vb(swellval) Does Not Exist"
								continue
							}
							if [catch {open $vb(swellval) "r"} zit] {
								Inf "Cannot Open File $vb(swellval)"
								continue
							}
							set cnt 0
							set OK 1
							catch {unset vb(swell)}
							while {[gets $zit line] >= 0} {
								set line [string trim $line]
								if {[string length $line] == 0} {
									continue
								} elseif {[string match [string index $line 0] ";"]} {
									continue
								}
								set line [split $line]
								foreach item $line {
									set item [string trim $item]
									if {[string length $item] <= 0} {
										continue
									}
									if {$cnt == 0} {
										if {$item != 0.0} {
											Inf "Times Do Not Start At Zero In Envelope File $vb(swellval)"
											set OK 0
											break	
										}
										set lasttime $item
									} elseif {[IsEven $cnt]} {
										if {$item <= $lasttime} {
											Inf "Times Do Not Increase In Envelope File $vb(swellval)"
											set OK 0
											break	
										}
										set lasttime $item
									} elseif {$item < 0.0 || $item > 1.0} {
										Inf "Values Out Of Range (0-1) In Envelope File $vb(swellval)"
										set OK 0
										break	
									}
									lappend vb(swell) $item
								}
								if {!$OK} {
									break
								}
							}
							if {![info exists vb(swell)] || ![IsEven [llength $vb(swell)]]} {
								set OK 0
							}
							if {[lindex $vb(swell) end] != 0.0} {
								Inf "Final Value Is Not Zero In Envelope File $vb(swellval)"
								set OK 0
							}
							if {!$OK} {
								continue
							}
						}	
						lappend envlist $vb(swell)
					}
					if {!$vb(noesoft)} {
						set vb(softval) [string trim $vb(softval)]
						if {[string length $vb(softval)] <= 0} {
							set vb(soft) $evv(VBOX_SOFT)
						} else {
							if {![file exists $vb(softval)]} {
								Inf "File $vb(softval) Does Not Exist"
								continue
							}
							if [catch {open $vb(softval) "r"} zit] {
								Inf "Cannot Open File $vb(softval)"
								continue
							}
							set cnt 0
							set OK 1
							catch {unset vb(soft)}
							while {[gets $zit line] >= 0} {
								set line [string trim $line]
								if {[string length $line] == 0} {
									continue
								} elseif {[string match [string index $line 0] ";"]} {
									continue
								}
								set line [split $line]
								foreach item $line {
									set item [string trim $item]
									if {[string length $item] <= 0} {
										continue
									}
									if {$cnt == 0} {
										if {$item != 0.0} {
											Inf "Times Do Not Start At Zero In Envelope File $vb(softval)"
											set OK 0
											break	
										}
										set lasttime $item
									} elseif {[IsEven $cnt]} {
										if {$item <= $lasttime} {
											Inf "Times Do Not Increase In Envelope File $vb(softval)"
											set OK 0
											break	
										}
										set lasttime $item
									} elseif {$item < 0.0 || $item > 1.0} {
										Inf "Values Out Of Range (0-1) In Envelope File $vb(softval)"
										set OK 0
										break	
									}
									lappend vb(soft) $item
								}
								if {!$OK} {
									break
								}
							}
							if {![info exists vb(soft)] || ![IsEven [llength $vb(soft)]]} {
								set OK 0
							}
							if {[lindex $vb(soft) end] != 0.0} {
								Inf "Final Value Is Not Zero In Envelope File $vb(softval)"
								set OK 0
							}
							if {!$OK} {
								continue
							}		
						}
						lappend envlist $vb(soft)
					}
					if {!$vb(noestrong)} {
						set vb(strongval) [string trim $vb(strongval)]
						if {[string length $vb(strongval)] <= 0} {
							set vb(strong) $evv(VBOX_STRONG)
						} else {
							if {![file exists $vb(strongval)]} {
								Inf "File $vb(strongval) Does Not Exist"
								continue
							}
							if [catch {open $vb(strongval) "r"} zit] {
								Inf "Cannot Open File $vb(strongval)"
								continue
							}
							set cnt 0
							set OK 1
							catch {unset vb(strong)}
							while {[gets $zit line] >= 0} {
								set line [string trim $line]
								if {[string length $line] == 0} {
									continue
								} elseif {[string match [string index $line 0] ";"]} {
									continue
								}
								set line [split $line]
								foreach item $line {
									set item [string trim $item]
									if {[string length $item] <= 0} {
										continue
									}
									if {$cnt == 0} {
										if {$item != 0.0} {
											Inf "Times Do Not Start At Zero In Envelope File $vb(strongval)"
											set OK 0
											break	
										}
										set lasttime $item
									} elseif {[IsEven $cnt]} {
										if {$item <= $lasttime} {
											Inf "Times Do Not Increase In Envelope File $vb(strongval)"
											set OK 0
											break	
										}
										set lasttime $item
									} elseif {$item < 0.0 || $item > 1.0} {
										Inf "Values Out Of Range (0-1) In Envelope FILE $vb(strongval)"
										set OK 0
										break	
									}
									lappend vb(strong) $item
								}
								if {!$OK} {
									break
								}
							}
							if {![info exists vb(strong)] || ![IsEven [llength $vb(strong)]]} {
								set OK 0
							}
							if {[lindex $vb(strong) end] != 0.0} {
								Inf "Final Value Is Not Zero In Envelope File $vb(strongval)"
								set OK 0
							}
							if {!$OK} {
								continue
							}		
						}
						lappend envlist $vb(strong)
					}
					if {!$vb(noeatk)} {
						set vb(atkval) [string trim $vb(atkval)]
						if {[string length $vb(atkval)] <= 0} {
							set vb(atk) $evv(VBOX_ATK)
						} else {
							if {![file exists $vb(atkval)]} {
								Inf "File $vb(atkval) Does Not Exist"
								continue
							}
							if [catch {open $vb(atkval) "r"} zit] {
								Inf "Cannot Open File $vb(atkval)"
								continue
							}
							set cnt 0
							set OK 1
							catch {unset vb(atk)}
							while {[gets $zit line] >= 0} {
								set line [string trim $line]
								if {[string length $line] == 0} {
									continue
								} elseif {[string match [string index $line 0] ";"]} {
									continue
								}
								set line [split $line]
								foreach item $line {
									set item [string trim $item]
									if {[string length $item] <= 0} {
										continue
									}
									if {$cnt == 0} {
										if {$item != 0.0} {
											Inf "Times Do Not Start At Zero In Envelope File $vb(atkval)"
											set OK 0
											break	
										}
										set lasttime $item
									} elseif {[IsEven $cnt]} {
										if {$item <= $lasttime} {
											Inf "Times Do Not Increase In Envelope File $vb(atkval)"
											set OK 0
											break	
										}
										set lasttime $item
									} elseif {$item < 0.0 || $item > 1.0} {
										Inf "Values Out Of Range (0-1) In Envelope File $vb(atkval)"
										set OK 0
										break	
									}
									lappend vb(atk) $item
								}
								if {!$OK} {
									break
								}
							}
							if {![info exists vb(atk)] || ![IsEven [llength $vb(atk)]]} {
								set OK 0
							}
							if {[lindex $vb(atk) end] != 0.0} {
								Inf "Final Value Is Not Zero In Envelope File $vb(atkval)"
								set OK 0
							}
							if {!$OK} {
								continue
							}
						}
						lappend envlist $vb(atk)
					}

					;#	READ POST-REVERB VALUES AND TEST

					if {!$vb(norev)} {
						if {([string length $vb(maxhirev)] <= 0) || ![IsNumeric $vb(maxhirev)]} {
							Inf "No Valid High Value Entered For Long Reverb"
							continue
						}
						if {([string length $vb(minhirev)] <= 0) || ![IsNumeric $vb(minhirev)]} {
							Inf "No Valid Low Value Entered For Long Reverb"
							continue
						}
						if {($vb(maxhirev) < 250) || ($vb(maxhirev) > 1000)} {
							Inf "High Value For Long Reverb Out Of Range"
							continue
						}
						if {($vb(minhirev) < 250) || ($vb(minhirev) > 1000)} {
							Inf "Low Value For Long Reverb Out Of Range"
							continue
						}
						if {$vb(minhirev) > $vb(maxhirev)} {
							Inf "Values For Long Reverb Incompatible"
							continue
						}
						if {([string length $vb(maxlorev)] <= 0) || ![IsNumeric $vb(maxlorev)]} {
							Inf "No Valid High Value Entered For Short Reverb"
							continue
						}
						if {([string length $vb(minlorev)] <= 0) || ![IsNumeric $vb(minlorev)]} {
							Inf "No Valid Low Value Entered For Short Reverb"
							continue
						}
						if {($vb(maxlorev) < 80) || ($vb(maxlorev) > 250)} {
							Inf "High Value For Short Reverb Out Of Range"
							continue
						}
						if {($vb(minlorev) < 80) || ($vb(minlorev) > 250)} {
							Inf "Low Value For Short Reverb Out Of Range"
							continue
						}
						if {$vb(minlorev) > $vb(maxlorev)} {
							Inf "Values For Short Reverb Incompatible"
							continue
						}
						if {([string length $vb(dryrev)] <= 0) || ![regexp {^[0-9]+$} $vb(dryrev)]} {
							Inf "No Valid Value Entered For Proportion Of Dry Reverb"
							continue
						}
						if {$vb(dryrev) != 0} {
							if {($vb(dryrev) < 3) || [IsEven $vb(dryrev)]} {
								Inf "Non-Zero Dry Reverb Proportion Must Be An Odd Value >= 3 (Corresponding To Proportion Of 1/3 Etc)"
								continue
							}
							set vb(halfdry) [expr $vb(dryrev)/2]
						} else {
							set vb(halfdry) 1
						}
					}
				}
				;#	CHECK ALL PARAM RANGES

				if {$vb(typ) == $evv(VB_ATKRES)} {
					set durrem 1000000
				} else {
					if {([string length $vb(maxdur)] <= 0) || ![IsNumeric $vb(maxdur)]} {
						Inf "No Valid Value Entered For Maximum Duration"
						continue
					}
					if {([string length $vb(mindur)] <= 0) || ![IsNumeric $vb(mindur)]} {
						Inf "No Valid Value Entered For Minimum Duration"
						continue
					}
					if {($vb(maxdur) < 0.001) || ($vb(maxdur) > $vb(indur))} {
						Inf "VAlue Entered For Maximum Duration Is Out Of Range  (0.001 to input dur $vb(indur))"
						continue
					}
					if {($vb(mindur) < 0.001) || ($vb(mindur) > $vb(maxdur))} {
						Inf "Value Entered For Minmum Duration Is Out Of Range (0.001 to max)"
						continue
					}
					set durrem [expr $vb(indur) - 0.0009]
				}
				if {!$vb(noshswell)} {
					if {([string length $vb(shswelup)] <= 0) || ![IsNumeric $vb(shswelup)]} {
						Inf "No Valid Value Entered For Swell Dovetail-Up"
						continue
					}
					if {([string length $vb(shsweldn)] <= 0) || ![IsNumeric $vb(shsweldn)]} {
						Inf "No Valid Value Entered For Swell Dovetail-Down"
						continue
					}
					if {($vb(shswelup) < 0.001) || ($vb(shswelup) > $durrem)} {
						Inf "Value Entered For Swell Dovetail-Up ($vb(shswelup)) Is Out Of Range (0.001 - $durrem)"
						continue
					}
					if {($vb(shsweldn) < 0.001) || ($vb(shsweldn) > $durrem)} {
						Inf "Value Entered For Swell Dovetail-down ($vb(shsweldn)) Is Out Of Range (0.001 - $durrem)"
						continue
					}
				}
				if {!$vb(noshsoft)} {
					if {([string length $vb(shsoftup)] <= 0) || ![IsNumeric $vb(shsoftup)]} {
						Inf "No Valid Value Entered For Soft Dovetail-up"
						continue
					}
					if {([string length $vb(shsoftdn)] <= 0) || ![IsNumeric $vb(shsoftdn)]} {
						Inf "No Valid Value Entered For Soft Dovetail-down"
						continue
					}
					if {($vb(shsoftup) < 0.001) || ($vb(shsoftup) > $durrem)} {
						Inf "Value Entered For Soft Dovetail-up ($vb(shsoftup)) Is Out Of Range (0.001 - $durrem)"
						continue
					}
					if {($vb(shsoftdn) < 0.001) || ($vb(shsoftdn) > $durrem)} {
						Inf "Value Entered For Soft Dovetail-down ($vb(shsoftdn))Is Out Of Range (0.001 - $durrem)"
						continue
					}
				}
				if {!$vb(noshhard)} {
					if {([string length $vb(shhardup)] <= 0) || ![IsNumeric $vb(shhardup)]} {
						Inf "No Valid Value Entered For Hard Dovetail-up"
						continue
					}
					if {([string length $vb(shhardup)] <= 0) || ![IsNumeric $vb(shhardup)]} {
						Inf "No Valid Value Entered For Hard Dovetail-down"
						continue
					}
					if {($vb(shhardup) < 0.001) || ($vb(shhardup) > $durrem)} {
						Inf "Value Entered For Hard Dovetail-up ($vb(shhardup)) Is Out Of Range (0.001 - $durrem)"
						continue
					}
					if {($vb(shharddn) < 0.001) || ($vb(shharddn) > $durrem)} {
						Inf "Value Entered For Hard Dovetail-down ($vb(shharddn)) Is Out Of Range (0.001 - $durrem)"
						continue
					}
				}
				if {!$vb(noshclip)} {
					if {([string length $vb(shclipup)] <= 0) || ![IsNumeric $vb(shclipup)]} {
						Inf "No Valid Value Entered For Clip Dovetail-up"
						continue
					}
					if {([string length $vb(shclipdn)] <= 0) || ![IsNumeric $vb(shclipdn)]} {
						Inf "No Valid Value Entered For Clip Dovetail-down"
						continue
					}
					if {([string length $vb(shclipstt)] <= 0) || ![IsNumeric $vb(shclipstt)]} {
						Inf "No Valid Value Entered For Clip Curtail-start"
						continue
					}
					if {([string length $vb(shclipend)] <= 0) || ![IsNumeric $vb(shclipend)]} {
						Inf "No Valid Value Entered For Clip Curtail-end"
						continue
					}
					if {($vb(shclipup) < 0.001) || ($vb(shclipup) > $durrem)} {
						Inf "Value Entered For Clip Dovetail-up ($vb(shclipup)) Is Out Of Range (0.001 - $durrem)"
						continue
					}
					if {($vb(shclipdn) < 0.001) || ($vb(shclipdn) > $durrem)} {
						Inf "Value Entered For Clip Dovetail-down ($vb(shclipdn)) Is Out Of Range (0.001 - $durrem)"
						continue
					}
					if {($vb(shclipstt) < $vb(shclipup)) || ($vb(shclipstt) > $vb(indur))} {
						Inf "Value Entered For Clip Curtail-start Is Out Of Range"
						continue
					}
					if {($vb(shclipend) <= $vb(shclipstt)) || ($vb(shclipend) > $vb(indur))} {
						Inf "Value Entered For Clip Curtail-end Is Out Of Range"
						continue
					}
				}
				if {($vb(typ) != $evv(VB_STEADY)) && ($vb(typ) != $evv(VB_ITERED)) && ($vb(typ) != $evv(VB_PULSED))} {
					if {!$vb(novffixd)} {
						if {([string length $vb(vibfrq)] <= 0) || ![IsNumeric $vb(vibfrq)]} {
							Inf "No Valid Value Entered For Vibrato Fixed Frequency"
							continue
						}
						if {($vb(vibfrq) < 0) || ($vb(vibfrq) > 30)} {
							Inf "Value Entered For Vibrato Fixed Frequency Is Out Of Range"
							continue
						}
					}
					if {!($vb(novfacc) && $vb(novfrit))} {
						if {([string length $vb(vibfrqlo)] <= 0) || ![IsNumeric $vb(vibfrqlo)]} {
							Inf "No Valid Value Entered For Vibrato Min Frequency"
							continue
						}
						if {([string length $vb(vibfrqhi)] <= 0) || ![IsNumeric $vb(vibfrqhi)]} {
							Inf "No Valid Value Entered For Vibrato Max Frequency"
							continue
						}
						if {($vb(vibfrqlo) < 0) || ($vb(vibfrqlo) > 30)} {
							Inf "Value Entered For Vibrato Min Frequency Is Out Of Range"
							continue
						}
						if {($vb(vibfrqhi) < $vb(vibfrqlo)) || ($vb(vibfrqhi) > 30)} {
							Inf "Value Entered For Vibrato Max Frequency Is Out Of Range"
							continue
						}
					}
					if {!$vb(novdfixd)} {
						if {([string length $vb(vibdep)] <= 0) || ![IsNumeric $vb(vibdep)]} {
							Inf "No Valid Value Entered For Vibrato Fixed Depth"
							continue
						}
						if {($vb(vibdep) < 0) || ($vb(vibdep) > 1)} {
							Inf "Value Entered For Vibrato Fixed Depth Is Out Of Range"
							continue
						}
					}
					if {!($vb(novdacc) && $vb(novdrit))} {
						if {([string length $vb(vibdeplo)] <= 0) || ![IsNumeric $vb(vibdeplo)]} {
							Inf "No Valid Value Entered For Vibrato Min Depth"
							continue
						}
						if {([string length $vb(vibdephi)] <= 0) || ![IsNumeric $vb(vibdephi)]} {
							Inf "No Valid Value Entered For Vibrato Max Depth"
							continue
						}
						if {($vb(vibdeplo) < 0) || ($vb(vibdeplo) > 1)} {
							Inf "Value Entered For Vibrato Min Depth Is Out Of Range"
							continue
						}
						if {($vb(vibdephi) < $vb(vibdeplo)) || ($vb(vibdephi) > 2)} {
							Inf "Value Entered For Vibrato Max Depth Is Out Of Range"
							continue
						}
					}
				}
				if {($vb(typ) != $evv(VB_ITERED)) && ($vb(typ) != $evv(VB_PULSED)) && ($vb(typ) != $evv(VB_WOBBLY))} {
					if {!($vb(notfacc) && $vb(notfrit))} {
						if {([string length $vb(trmfrqlo)] <= 0) || ![IsNumeric $vb(trmfrqlo)]} {
							Inf "No Valid Value Entered For Tremolo Min Frequency"
							continue
						}
						if {([string length $vb(trmfrqhi)] <= 0) || ![IsNumeric $vb(trmfrqhi)]} {
							Inf "No Valid Value Entered For Tremolo Max Frequency"
							continue
						}
						if {($vb(trmfrqlo) < 0) || ($vb(trmfrqlo) > 30)} {
							Inf "Value Entered For Tremolo Min Frequency Is Out Of Range"
							continue
						}
						if {($vb(trmfrqhi) < $vb(trmfrqlo)) || ($vb(trmfrqhi) > 30)} {
							Inf "Value Entered For Tremolo Max Frequency Is Out Of Range"
							continue
						}
					}
					if {!$vb(notdfixd)} {
						if {([string length $vb(trmdep)] <= 0) || ![IsNumeric $vb(trmdep)]} {
							Inf "No Valid Value Entered For Tremolo Fixed Depth"
							continue
						}
						if {($vb(trmdep) < 0) || ($vb(trmdep) > 1)} {
							Inf "Value Entered For Tremolo Fixed Depth Is Out Of Range"
							continue
						}
					}
					if {!($vb(notdacc) && $vb(notdrit))} {
						if {([string length $vb(trmdeplo)] <= 0) || ![IsNumeric $vb(trmdeplo)]} {
							Inf "No Valid Value Entered For Tremolo Min Depth"
							continue
						}
						if {([string length $vb(trmdephi)] <= 0) || ![IsNumeric $vb(trmdephi)]} {
							Inf "No Valid Value Entered For Tremolo Max Depth"
							continue
						}
						if {($vb(trmdeplo) < 0) || ($vb(trmdeplo) > 1)} {
							Inf "Value Entered For Tremolo Min Depth Is Out Of Range"
							continue
						}
						if {($vb(trmdephi) < $vb(trmdeplo)) || ($vb(trmdephi) > 1)} {
							Inf "Value Entered For Tremolo Max Depth Is Out Of Range"
							continue
						}
					}
					if {([string length $vb(trmsqmin)] <= 0) || ![IsNumeric $vb(trmsqmin)]} {
						Inf "No Valid Value Entered For Min Tremolo Narrowing"
						continue
					}
					if {($vb(trmsqmin) < 1) || ($vb(trmsqmin) > 100)} {
						Inf "Value Entered For Min Tremolo Narrowing Is Out Of Range"
						continue
					}
					if {([string length $vb(trmsqmax)] <= 0) || ![IsNumeric $vb(trmsqmax)]} {
						Inf "No Valid Value Entered For Min Tremolo Narrowing"
						continue
					}
					if {($vb(trmsqmax) < $vb(trmsqmin)) || ($vb(trmsqmax) > 100)} {
						Inf "Value Entered For Max Tremolo Narrowing Is Out Of Range"
						continue
					}
					set vb(trmsqrange) [expr $vb(trmsqmax) - $vb(trmsqmin)]
					if {!$vb(notffixd)} {
						if {([string length $vb(trmfrq)] <= 0) || ![IsNumeric $vb(trmfrq)]} {
							Inf "No Valid Value Entered For Tremolo Fixed Frequency"
							continue
						}
						if {($vb(trmfrq) < 0) || ($vb(trmfrq) > 30)} {
							Inf "Value Entered For Tremolo Fixed Frequency Is Out Of Range"
							continue
						}
					}
				}
				if {$vb(typ) == $evv(VB_ITERED) || ($vb(typ) == $evv(VB_PULSED)) || ($vb(typ) == $evv(VB_ATKRES))} {
					if {!$vb(nostak)} {
						if {([string length $vb(stakmin)] <= 0) || ![regexp {^[0-9]+$} $vb(stakmin)]} {
							Inf "No Valid Value Entered For Transpose Or Stack Maximum Down Octave"
							continue
						}
						if {([string length $vb(stakmax)] <= 0) || ![regexp {^[0-9]+$} $vb(stakmax)]} {
							Inf "No Valid Value Entered For Transpose Or Stack Maximum Up Octave""
							continue
						}
						if {($vb(stakmin) < 0) || ($vb(stakmin) > 8)} {
							Inf "Value Entered For Transpose Or Stack Maximum Down Octave Is Out Of Range (0-8)"
							continue
						}
						if {($vb(stakmax) < 0) || ($vb(stakmax) > 8)} {
							Inf "Value Entered For Transpose Or Stack Maximum Up Octave Is Out Of Range (0-8)"
							continue
						}
						if {$vb(typ) == $evv(VB_ATKRES)} {
							if {[expr $vb(stakmin) + $vb(stakmax)] <= 0} {
								Inf "Stack Range Must Be Greater Than Zero For Attack-resonance Types"
								continue
							}
						}
						if {$vb(tors) || ($vb(typ) == $evv(VB_ATKRES))} {
							if {([string length $vb(staklean)] <= 0) || ![IsNumeric $vb(staklean)]} {
								Inf "No Valid Value Entered For Maximum Stack Lean"
								continue
							}
							if {($vb(staklean) < 1) || ($vb(staklean) > 100)} {
								Inf "Value Entered For Stacking Maximum Lean Is Out Of Range (1-100)"
								continue
							}
						}
						if {$vb(typ) != $evv(VB_ATKRES)} {
							set minshlen 1000000
							set orig_stakmax $vb(stakmax)
							set orig_stakmin $vb(stakmin)
							if {!$vb(noshswell)} {
								set len [GetVariboxUnitlen swell]
								if {$len < $minshlen} {
									set minshlen $len
								}
							}
							if {!$vb(noshsoft)} {
								set len [GetVariboxUnitlen soft]
								if {$len < $minshlen} {
									set minshlen $len
								}
							}
							if {!$vb(noshhard)} {
								set len [GetVariboxUnitlen hard]
								if {$len < $minshlen} {
									set minshlen $len
								}
							}
							if {!$vb(noshclip)} {
								set len [GetVariboxUnitlen clip]
								if {$len < $minshlen} {
									set minshlen $len
								}
							}
							set maxshrink [expr pow(2.0,$vb(stakmax))]
							set OK 1
							set trwarn 0
							set thestakmin [expr -$vb(stakmin)]
							while {$maxshrink > 1} {
								set minshdur [expr $vb(indur)/$maxshrink]
								if {$minshdur < $minshlen} {
									if {$vb(stakmax) <= $thestakmin} {
										set vb(stakmax) 0
										set vb(stakmin) 0
										break
									}
									incr vb(stakmax) -1
									set trwarn 1
									set maxshrink [expr pow(2.0,$vb(stakmax))]
								} else {
									break
								}
							}
							if {($vb(stakmax) == 0) && ($vb(stakmin) == 0) && (!($orig_stakmin == 0) && ($orig_stakmax == 0)) } {
								set msg "Transpositions Not Compatible With Short Event Parameters And Duration Of Input File: Proceed Anyway ??"
								set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
								if {$choice == "no"} {
									continue
								}
							} elseif {$trwarn} {
								set msg "Some Transpositions Not Compatible With Short Event Parameters And Duration Of Infile: Proceed Anyway ??"
								set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
								if {$choice == "no"} {
									continue
								}
							}
						}
						if {![CreateVariboxStaksList]} {
							Inf "Failed To Create Varibox Stacks List"
							continue
						}
					}
					if {$vb(typ) == $evv(VB_PULSED)} {
						if {([string length $vb(oversup)] <= 0) || ![IsNumeric $vb(oversup)]} {
							Inf "No Valid Value Entered For Overlap Suppresion"
							continue
						}
						if {($vb(oversup) < 0) || ($vb(oversup) > 1)} {
							Inf "Value Entered For Overlap Suppresion Is Out Of Range (0-1)"
							continue
						}
					} elseif {$vb(typ) == $evv(VB_ATKRES)} {
						if {([string length $vb(preverbmin)] <= 0) || ![IsNumeric $vb(preverbmin)]} {
							Inf "No Valid Value Entered For Pre-reverb Minimum"
							continue
						}
						if {($vb(preverbmin) < 80) || ($vb(preverbmin) > 250)} {
							Inf "Value Entered For Pre-reverb Minimum Is Out Of Range (80-250)"
							continue
						}
						if {([string length $vb(preverbmax)] <= 0) || ![IsNumeric $vb(preverbmax)]} {
							Inf "No Valid Value Entered For Pre-reverb Maximum"
							continue
						}
						if {($vb(preverbmax) < 80) || ($vb(preverbmax) > 800)} {
							Inf "Value Entered For Pre-reverb Maximum Is Out Of Range (80-800)"
							continue
						}
						if {$vb(preverbmax) < $vb(preverbmin)} {
							Inf "Value Entered For Pre-reverb Maximum And Minimum Are Incompatible"
							continue
						}
					}
				}
				if {$vb(typ) != $evv(VB_ATKRES)} {
					if {!$vb(nofixd)} {
						if {([string length $vb(repdel)] <= 0) || ![IsNumeric $vb(repdel)]} {
							Inf "No Valid Value Entered For Fixed Delay"
							continue
						}
						if {($vb(repdel) < 0.01) || ($vb(repdel) > 0.3)} {
							Inf "Value Entered For Fixed Delay Is Out Of Range (0.01 to 0.3)"
							continue
						}
					}
					if {!($vb(noacc) && $vb(norit))} {
						if {([string length $vb(repdello)] <= 0) || ![IsNumeric $vb(repdello)]} {
							Inf "No Valid Value Entered For Min Variable Delay"
							continue
						}
						if {([string length $vb(repdelhi)] <= 0) || ![IsNumeric $vb(repdelhi)]} {
							Inf "No Valid Value Entered For Max Variable Delay"
							continue
						}
						if {($vb(repdello) < 0.01) || ($vb(repdello) > 0.3)} {
							Inf "Value Entered For Min Variable Delay Is Out Of Range"
							continue
						}
						if {($vb(repdelhi) < 0.01) || ($vb(repdelhi) < $vb(repdello))} {
							Inf "Value Entered For Max Variable Delay Is Out Of Range"
							continue
						}
						set vb(repdelmean) [expr ($vb(repdelhi) + $vb(repdello))/2.0]		;#	Mean delay
						set vb(repdelhrng) [expr $vb(repdelhi) - $vb(repdelmean)]			;#	Half delay range
					}
				}
				catch {unset vb(shenvlist)} 
				if {!$vb(noshswell)} { 
					lappend vb(shenvlist) swell
				}
				if {!$vb(noshsoft)} {
					lappend vb(shenvlist) soft
				}
				if {!$vb(noshhard)} {
					lappend vb(shenvlist) hard
				}
				if {!$vb(noshclip)} {
					lappend vb(shenvlist) clip
				}
				if {$vb(typ) == $evv(VB_PULSED)} {
					if {$vb(oversup) <= 0} {
						set vb(minunit) 1000000				;#	Any overlap of units allowed	
					} elseif {$vb(oversup) >= 1} {
						if {!$vb(nofixd)} {
							set vb(minunit) $vb(repdel)
						} else {
							set vb(minunit) $vb(repdello)	;#	No overlap of units allowed
						}
					}									;#	In other cases, vb(minunit) is set at output creation time
				}

				if {($vb(typ) == $evv(VB_GENERL)) || ($vb(typ) == $evv(VB_WOBBLY))} {
					if {([string length $vb(glisvalval)] <= 0) || ![IsNumeric $vb(glisvalval)]} {
						Inf "Invalid Value Entered For Pitch Wander"
						continue
					}
					if {($vb(glisvalval) < 0) || ($vb(glisvalval) > 2)} {
						Inf "Value Entered For Pitch-wander Is Out Of Range (0-2 semitones)"
						continue
					}
				}

				# CREATE TABLES OF RAND-FLUCTUATIONS OF FIXED VALUES, AND OF CHANGING VALS

				if {$vb(typ) != $evv(VB_ATKRES)} {

				;#	ESTABLISH VIBRATO AND TREMOLO TABLES FOR SUSTAINED SOUNDS 

					CreateVariboxVibTremTables $vb(maxdur) 0

				;#	ESTABLISH ITERATATION PARAMS FOR SHORT SOUNDS
				
					set repdellist {}
					if {$vb(nofixd)} {
						lappend repdellist 0
					} else {
						lappend repdellist $vb(repdel)
					} 
					if {$vb(noacc)} {
						lappend repdellist 0
					} else {
						lappend repdellist 1
					} 
					if {$vb(norit)} {
						lappend repdellist 0
					} else {
						lappend repdellist 1
					} 

					# ESTABLISH OUTPUT NAMES

					set up 	$evv(DFLT_OUTNAME)
					append up 1 $evv(SNDFILE_EXT)
					set dn 	$evv(DFLT_OUTNAME)
					append dn 2 $evv(SNDFILE_EXT)				;#	0 1 2
				}

				set vb(tempfilcnt) 0

				catch {unset srclist}	;#	SRCLIST IS LIST OF SOUNDS TO FURTHER PROCESS

				;#	MAKE FLAT AND SLIGHTLY GLISSED LONG SOUNDS

				RememberVariboxDefaultParams

				.varibox.1.00.play config -bd 0 -text "" -state disabled
				.varibox.1.00.save config -bd 0 -text "" -state disabled

				Block "Creating Variants"

				if {($vb(typ) != $evv(VB_ITERED)) && ($vb(typ) != $evv(VB_PULSED)) && ($vb(typ) != $evv(VB_ATKRES))} {
					set vb(gotsrc) 1
					lappend srclist $vb(ifnam)
				} else {
					set vb(gotsrc) 0
				}
				if {($vb(typ) == $evv(VB_GENERL)) || ($vb(typ) == $evv(VB_WOBBLY))} {

					if {$vb(glisvalval) > 0} {
						if {![DoVariboxGlis up $vb(ifnam) $up $vb(glisvalval)]} {
							UnBlock
							continue
						}
						lappend srclist $up
						if {![DoVariboxGlis dn $vb(ifnam) $dn $vb(glisvalval)]} {
							UnBlock
							continue
						}
						lappend srclist $dn
					}
				}
				
				if {[info exists srclist]} {
					set vb(outs) $srclist		;#	OUTS IS LIST OF FINAL OUTPUTS

				;#	GENERATE VIBRATO AND TREMOLO VARIANTS FOR SUSTAINED (NON-ATKRES) SOUNDS

					if {($vb(typ) != $evv(VB_ITERED)) && ($vb(typ) != $evv(VB_PULSED)) && ($vb(typ) != $evv(VB_ATKRES))} {
						VariboxVibandTrem $srclist 0 0
					}
				}

				;#	GENERATE SHORT ELEMENTS	AND STACKS
				

				;#	OPTION 1: STACK (OR TRANSPOSE) SRC, BEFORE CUTTING SHORT ELEMENTS 

				if {$vb(prestak) || ((($vb(typ) == $evv(VB_ITERED)) || ($vb(typ) == $evv(VB_PULSED))) && ($vb(tors) == 0))} {
					if {[info exists vb(stakslist)] && ([llength $vb(stakslist)] > 0)} {
						catch {unset prestaksrclist}
						catch {unset stakunitdurs}
						catch {unset prestakunitdurs}
						catch {unset srclist}
						set stkcnt 1
						set stklen [llength $vb(stakslist)]
						set stakbasnam $evv(DFLT_OUTNAME)
						append stakbasnam 1
						foreach stak $vb(stakslist) {
							if {$vb(tors)} {

							;# CREATE A STACK BRKFILE, THEN STACK THE SOURCE vb(ifnam)

								set stakdatafilnam $evv(DFLT_OUTNAME)
								append stakdatafilnam $vb(tempfilcnt) $evv(TEXT_EXT)
								incr vb(tempfilcnt)
								wm title .blocker "PLEASE WAIT:        Creating Stack datafile $stkcnt of $stklen"
								if {[MakeVariboxStakBrkfile $stak $stakdatafilnam 0 0]} {		
									set siz [llength $stak]
									set stakfnam $stakbasnam
									append stakfnam $stkcnt $evv(SNDFILE_EXT)
									wm title .blocker "PLEASE WAIT:        Creating Source-based Stack $stkcnt of $stklen"
									if {[DoVariboxStak $vb(ifnam) $stakfnam $stakdatafilnam $siz 0 $stkcnt $stak]} {		
										lappend prestaksrclist $stakfnam
									}
									incr stkcnt
								} else {
									incr stklen -1
								}
							} else {

							;# CREATE TRANSPOSED VERSIONS OF THE SOURCE vb(ifnam)

								set stakfnam $stakbasnam
								append stakfnam $stkcnt $evv(SNDFILE_EXT)
								wm title .blocker "PLEASE WAIT:        Transposition of Source: $stkcnt of $stklen"
								if {[DoVariboxTranspose $vb(ifnam) $stakfnam $stkcnt $stak]} {		
									lappend prestaksrclist $stakfnam
									incr stkcnt
								} else {
									incr stklen -1
								}
							}
						}
					}

						;# ADD THE SOURCE ITSELF TO LIST OF SOUNDS TO BE CUT

					set origsrc $evv(DFLT_OUTNAME)
					append origsrc 9898 $evv(SNDFILE_EXT)
					if [catch {file copy $vb(ifnam) $origsrc} zit] {
						set msg "Failed To Copy Original Source, To Cut Short Events"
						UnBlock
						continue
					} elseif {[info exists prestaksrclist]} {
						set prestaksrclist [concat $origsrc $prestaksrclist]
					} else {
						set prestaksrclist $origsrc
					}

						;# CUT SHORT EVENTS FROM PRE-STACKED OR PRE-TRANSPOSED MATERIALS

					set shoutcnt 1
					set shlen [expr [llength $vb(shenvlist)] * [llength $prestaksrclist]] 
					catch {unset staksrclist}
					foreach src $prestaksrclist {
						set basnam [file rootname $src]
						append basnam 2929
						set shenvcnt 0
						foreach shenv $vb(shenvlist) {
							wm title .blocker "PLEASE WAIT:        Creating Short event $shoutcnt of $shlen"
							set shenvfnam $basnam							;#	+29290 +29291 +29292 etc.
							append shenvfnam $shenvcnt $evv(SNDFILE_EXT)
							if {[DoVariboxShenv $src $shenvfnam $shenv]} {		
								lappend staksrclist $shenvfnam
								if {($vb(typ) == $evv(VB_GENERL)) || ($vb(typ) == $evv(VB_STEADY))} {
									lappend vb(outs) $shenvfnam
								} elseif {$vb(typ) == $evv(VB_PULSED)} {
									lappend stakunitdurs $vb(unitlen)
								}
							}
							incr shenvcnt
							incr shoutcnt
						}
					}
					if {[info exists staksrclist]} {
						set srclist $staksrclist
					}

				;#	OPTION 2: CUT SHORT ELEMENTS BEFORE STACKING, (allows real attacks in src to be syncd)

				} else {

					;#	CUT SHORT ELEMENTS

					set shoutcnt 1
					set shlen [llength $vb(shenvlist)]
					catch {unset srclist}
					set basnam $evv(DFLT_OUTNAME)
					append basnam 0
					set shenvcnt 5										;#	Follows on from (max of) 6 vib+trem files names
					catch {unset envtypes}
					catch {unset unitlens}
					foreach shenv $vb(shenvlist) {
						wm title .blocker "PLEASE WAIT:        Creating Short event $shoutcnt of $shlen"
						incr shenvcnt
						set shenvfnam $basnam							;#	06 07 08 09
						append shenvfnam $shenvcnt $evv(SNDFILE_EXT)
						if {[DoVariboxShenv $vb(ifnam) $shenvfnam $shenv]} {		
							lappend srclist $shenvfnam
							if {($vb(typ) == $evv(VB_GENERL)) || ($vb(typ) == $evv(VB_STEADY))} {
								lappend vb(outs) $shenvfnam
							}
							lappend envtypes $shenv
							lappend unitlens $vb(unitlen)
						}
						incr shoutcnt
					}

					;#	ATK-RES TYPES: THE SHORT SOUNDS ARE REVERBD BEFORE STACKING

					if {$vb(typ) == $evv(VB_ATKRES)} {
						catch {unset nuenvtypes}
						if {![info exists srclist]} {
							Inf "No Short Sounds Generated"
							UnBlock
							continue
						}
						catch {unset atkresouts}
						set atkrescnt 1
						set atkreslen [llength $srclist]
						foreach src $srclist envtype $envtypes {
							set ofnam [file rootname $src]
							append ofnam 777 $evv(SNDFILE_EXT)
							set ofnam [DoVariboxReverb $src $ofnam $atkrescnt 1]
							if {[string length $ofnam] == 0} {
								incr atkreslen -1
							} else {
								lappend atkresouts $ofnam
								lappend nuenvtypes $envtype
								incr atkrescnt
							}
						}
						if {![info exists atkresouts]} {
							Inf "No Reverberated Sources Generated"
							UnBlock
							continue
						}
						set srclist $atkresouts
						set envtypes $nuenvtypes
					}

					;#	STACK THE SHORT SOUNDS, SYNCING AT THEIR ENVELOPE-MAXIMUM POINT

					if {[info exists vb(stakslist)] && ([llength $vb(stakslist)] > 0)} {
						if {(($vb(typ) == $evv(VB_ITERED)) || ($vb(typ) == $evv(VB_PULSED)) || ($vb(typ) == $evv(VB_ATKRES)))} {
							catch {unset staksrclist}
							catch {unset stakunitdurs}
							catch {unset atkresatks}
							set stkcnt 1
							set stklen [expr [llength $vb(stakslist)] * [llength $srclist]]
							set stakbasnam $evv(DFLT_OUTNAME)
							append stakbasnam 1
							foreach src $srclist envtype $envtypes unitlen $unitlens {
								foreach stak $vb(stakslist) {
									set stakdatafilnam $evv(DFLT_OUTNAME)
									append stakdatafilnam $vb(tempfilcnt) $evv(TEXT_EXT)
									incr vb(tempfilcnt)
									wm title .blocker "PLEASE WAIT:        Creating Stack datafile $stkcnt of $stklen"
									if {[MakeVariboxStakBrkfile $stak $stakdatafilnam $envtype $unitlen]} {		
										set siz [llength $stak]
										set stakfnam $stakbasnam
										append stakfnam $stkcnt $evv(SNDFILE_EXT)
										wm title .blocker "PLEASE WAIT:        Creating Stack $stkcnt of $stklen"
										if {[DoVariboxStak $src $stakfnam $stakdatafilnam $siz $envtype $stkcnt $stak]} {		
											lappend staksrclist $stakfnam
																				
						;#	ATKRES NEEDS TO KNOW WHERE ATTACK-POINT IS AFTER STACKING
											
											if {$vb(typ) == $evv(VB_ATKRES)} {
												lappend atkresatks [expr $vb(synctime) * $vb(stakexpand)]
											
						;#	PULSED NEEDS TO KNOW PULSE UNIT LENGTH, TO AVOID PULSE OVERLAP IN ITERATES (IF SET)
											
											} elseif {$vb(typ) == $evv(VB_PULSED)} {
												lappend stakunitdurs $vb(unitlen)
											}
										}
										incr stkcnt
									} else {
										incr stklen -1
									}
								}
							}
							if {[info exists staksrclist]} {
								if {$vb(typ) == $evv(VB_PULSED)} {				
								
						;#	PULSED NEEDS STAKUNITDURS TO CORRESPOND 1-TO-1 WITH NEW SRCLIST
								
									set nonstakvals {}
									foreach src $srclist {
										lappend nonstakvals 0
									}
									set stakunitdurs [concat $nonstakvals $stakunitdurs]
								}
								if {$vb(typ) == $evv(VB_ATKRES)} {
								
						;#	ATKRES USES STAKS ONLY
								
									set srclist $staksrclist
								} else {
								
						;#	OTHERS USE STAKS AND PRESTACKED SHORT SOUNDS
								
									set srclist [concat $srclist $staksrclist]
								}
							}
						}
					}
				}

				;#	ATKRES CAN NOW ADD TREMOLO OR VIBRATO, POST-ATK, IF SET
							
				if {$vb(typ) == $evv(VB_ATKRES)} {
					set variboxouts $srclist
					if {!($vb(novib) && $vb(notrm))} {
						set dlen [llength $srclist]
						set dcnt 1
						foreach src $srclist atkresatk $atkresatks {

				;#	ESTABLISH DURATION OF (REVERBD) SOURCES, SO VIB/TREM TABLES CAN BE CREATED

							wm title .blocker "PLEASE WAIT:        Getting length of staksnd $dcnt of $dlen"
							if {[VariboxGetSrcDur $src $dcnt]} {

				;#	ESTABLISH TABLES FOR POST-ATTACK TREMOLO &/OR VIBRATO FOR SPECIFIC OUTSOUND

								CreateVariboxVibTremTables $vb(atkreslen) $atkresatk

				;#	DO VIB AND TREM ON A SRC-BY-SRC BASIS

								VariboxVibandTrem $src $dcnt $dlen
								incr dcnt
							} else {
								incr dlen -1
							}
						}
						if {[info exists vb(outs)]} {
							set variboxouts [concat $variboxouts $vb(outs)]
						}
						catch {unset vb(outs)}
					}

				;#	RENAME ATKRES OUTPUTS

					set olen [llength $variboxouts]
					set ocnt 1
					foreach fnam $variboxouts {
					wm title .blocker "PLEASE WAIT:        Renaming Output file $ocnt of $olen"
							set ofval [file rootname $fnam]
						set k 0
						while {![regexp {^[0-9]$} [string index $ofval $k]]} {
							incr k
						}
						set ofval [string range $ofval $k end]
						set nunam $outfnam
						append nunam $ofval $evv(SNDFILE_EXT)
						if [catch {file rename $fnam $nunam} zit] {
							set msg "Cannot Rename Outputfile $fnam To $nunam"
							lappend variboxmsgs $msg
							incr olen -1
						} else {
							lappend vb(outs) $nunam
							incr ocnt
						}
					}
					if {![info exists vb(outs)]} {
						UnBlock
						continue
					} else {
						set variboxouts $vb(outs)
					}
				} else {

				;#	OTHERS COMBINE SHORT-ELEMENTS BY ITERATION )AND THEN APPLY LARGE-SCALE ENVELOPE)

					catch {unset durs}
					if {[info exists vb(outs)]} {
						foreach out $vb(outs) {
							lappend durs 0			;#	Flag "unknown duration" for existing outfiles
						}
					}
					if {[info exists srclist] && ([llength $srclist] > 0)} {
						set ioutcnt 1
						set repdelistlen 0
						set kk 0
						while {$kk < 3} {
							if {[lindex $repdellist $kk] != 0} {
								incr repdelistlen
							}
							incr kk
						}
						set ilen [expr [llength $srclist] * $repdelistlen]
						set nn 0 
						foreach src $srclist {
							set basnam [file rootname $src]
							set itercnt 0
							foreach delval $repdellist {
								if {[string match $delval "0"]} {		;#	Ignore excluded iterations
									incr itercnt
									continue
								}
								set durset 0
								if {$itercnt > 0} {						;#	For varying delay, randvary max and min delays
									set repdelhi [expr (rand() * $vb(repdelhrng)) + $vb(repdelmean)]
									set repdello [expr $vb(repdelmean) - (rand() * $vb(repdelhrng))]
									set dur [GetVariboxDur] 			;#	Make delay variation apply over entire FINAL duration
									set durset 1						;#	Mark that duration has been calculated
									if {$itercnt == 1} {				;#	Modify the delval brkvalues
										set delval [list 0.0 $repdelhi $dur $repdello]
									} else {
										set delval [list 0.0 $repdello $dur $repdelhi]
									}									;#	Calculate minunit on basis of new randvaried max and min delays
									if {$vb(typ) == $evv(VB_PULSED)} {	;#	If it has not already been set
										if {($vb(oversup) > 0) && ($vb(oversup) < 1)} {
											set vb(minunit) [expr 1.0 - $vb(oversup)]
											set vb(minunit) [expr int(round($vb(minunit) * 4.0))]
											set vb(minunit) [expr ((($vb(minunit) - 1) * $repdelhi) + $repdello)/$vb(minunit)]
										}
									}
								}
								if {$vb(typ) == $evv(VB_PULSED)} {
									set stakunitdur [lindex $stakunitdurs $nn]
									if {$stakunitdur > 0} {
										set OK 1
										switch -- $itercnt {
											0 {
												if {$vb(repdel) > $stakunitdur} {
													set OK 0
												}
											}
											1 -
											2 {
												if {$stakunitdur > $vb(minunit)} {
													set OK 0
												}
											}
										}
										if {!$OK} {
											incr itercnt
											continue
										}
									}
								}
								wm title .blocker "PLEASE WAIT:        Creating Iterated event $ioutcnt of $ilen"
								if {$itercnt == 0} {
									set delay $delval
								} else {
									set delay $evv(DFLT_OUTNAME)
									append delay $vb(tempfilcnt) $evv(TEXT_EXT)
									incr vb(tempfilcnt)
									if {![CreateVaribankDelayFile $delval $delay $itercnt $src]} {
										incr itercnt
										incr ioutcnt
										continue
									}
								}
								set iternam $basnam
								append iternam $itercnt $evv(SNDFILE_EXT)	;#	060 061 062 063, 070 071 etc
								if {[DoVariboxIterate $src $iternam $delay $itercnt]} {		
									lappend vb(outs) $iternam
									if {$durset} {
										lappend durs $dur	;#	Remember duration set
									} else {
										lappend durs 0		;#	Or flag duration as unknown
									}
								} else {
								}
								incr itercnt
								incr ioutcnt
							}
							incr nn
						}
					} else {
						set msg "NO Short-element Versions Generated"
						lappend variboxmsgs $msg
					}

					if {![info exists vb(outs)]} {
						Inf "No Iterated Short-elements Generated"
						UnBlock
						continue
					}

					;#	APPLY ENVELOPES TO ALL OUTPUT SOUNDS, (APART FROM ATKRES TYPES)
					
					catch {unset variboxouts}
					set eoutcnt 1

					;#	IF SRC SOUND IS AMONG THE LIST OF SOUNDS BEING PROCESSES, REMOVE IT AT THIS STAGE
					
					if {$vb(gotsrc)} {
						VariboxRemoveSrc
					}

					if {$vb(all)} {

					;#	EITHER APPLYING EVERY ENVELOPE IN TURN TO EVERY OUTPUT SOUND

						set elen [expr [llength $vb(outs)] * [llength $envlist]]
						set srccnt 0
						foreach src $vb(outs) {
							set basnam [file rootname $src]
							set envcnt 0
							foreach envel $envlist {
								wm title .blocker "PLEASE WAIT:        Enveloping output $eoutcnt of $elen"
								set envnam $basnam
								append envnam $envcnt
								set namend [string range $envnam 7 end]
								set namendlen [string len $namend]
								switch -- $namendlen {
									1 {
										while {[string length $namend] < 3} {
											append namend 8
										}
									}
									2 {
										while {[string length $namend] < 3} {
											append namend 9
										}
									}
								}
								if {$vb(norev)} {
									set envnam $outfnam
								} else {
									set envnam $evv(MACH_OUTFNAME)
								}
								append envnam $namend $evv(SNDFILE_EXT)
								set dur [lindex $durs $srccnt]
								if {$dur <= 0} {
									set dur [GetVariboxDur]
								}
								if {[DoVariboxEnvelope $src $envnam $envel $dur]} {
									lappend variboxouts $envnam
								}
								incr envcnt					;#	Counts the envelopes used, (used for numbering outfiles)
								incr eoutcnt				;#	Counts the total enveloped-sounds made, used for user display
							}
							incr srccnt						;#	Counts the sourcefiles being enveloped, and indexes their durations
						}
					} else {

					;#	OR APPLYING A RANDOM ENVELOPE TO EACH OUTPUT SOUND (FROM RANDOM PERMS OF ALL ENVELOPE TYPES)

						set elen [llength $vb(outs)]
						set thisenvlist [VariboxEnvperm $envlist]
						set srccnt 0
						set ecnt 0
						set envlen [llength $envlist]
						foreach src $vb(outs) {
							wm title .blocker "PLEASE WAIT:        Enveloping output $eoutcnt of $elen"
							set envel [lindex $thisenvlist $ecnt]
							set basnam [file rootname $src]
							set namend [string range $basnam 7 end]
							if {$vb(norev)} {
								set envnam $outfnam
							} else {
								set envnam $evv(MACH_OUTFNAME)
							}
							append envnam $namend $evv(SNDFILE_EXT)
							set dur [lindex $durs $srccnt]
							if {$dur <= 0} {
								set dur [GetVariboxDur]
							}
							if {[DoVariboxEnvelope $src $envnam $envel $dur]} {
								lappend variboxouts $envnam
							}
							incr ecnt					;#	Counts the envelopes used, and goes back to 1st once all envelopes used
							if {$ecnt == $envlen} {
								set thisenvlist [VariboxEnvperm $envlist]
								set ecnt 0
							}
							incr eoutcnt				;#	Counts the total enveloped-sounds made, used for user display
							incr srccnt					;#	Counts the sourcefiles being enveloped, and indexes their durations
						}
					}
					if {![info exists variboxouts]} {
						Inf "No Outputs Generated"
						UnBlock
						continue
					}
					if {!$vb(norev)} {

					;#	APPLY (IF REQUESTED) A RANDOMISED REVERB TO EACH OUTPUT SOUND

						set vb(outs) $variboxouts
						unset variboxouts
						set olen [llength $vb(outs)]
						set ocnt 1
						foreach src $vb(outs) {
							wm title .blocker "PLEASE WAIT:        Reverbing output $ocnt of $olen"
							set basnam [file rootname $src]
							set namend [string range $basnam 4 end]
							set revnam $outfnam
							append revnam $namend $evv(SNDFILE_EXT)
							set revnam [DoVariboxReverb $src $revnam $ocnt 0]
							if {[string length $revnam] == 0} {
								incr olen -1
							} else {
								lappend variboxouts $revnam
								incr ocnt
							}
						}
						if {![info exists variboxouts]} {
							Inf "No Outputs Generated"
						}
					}
				}
				UnBlock
				.varibox.1.00.ok config -bg [option get . background {}]
				.varibox.1.00.save config -bg $evv(EMPH)
				.varibox.1.00.play config -bd 2 -text "Play Texture of Ouputs" -state normal
				.varibox.1.00.save config -bd 2 -text "Save Outputs" -state normal
			}
			2 {
				SetVariboxDefaultParams
			}
			3 {
				ClearVariboxParams
			}
			4 {
				SaveVariboxParams
			}
			5 {
				GetVariboxParams
			}
			6 {
				if {[info exists real_outputs]} {
					Inf "Outputs Already Saved"
				} elseif {![info exists variboxouts]} {
					Inf "No Outputs To Save"
				} else {
					set real_outputs [VariBoxSaveOutput $variboxouts]
					.varibox.1.00.ok config -bg $evv(EMPH)
					.varibox.1.00.save config -bg [option get . background {}]
					if {[info exists vb(sample)] && [file exists $vb(sample)]} {
						if [catch {file delete $vb(sample)} zit] {
							Inf "Cannot Delete Existing Output-sample Sound"
						}
					}
					if {[info exists vb(notedata)] && [file exists $vb(notedata)]} {
						if [catch {file delete $vb(notedata)} zit] {
							Inf "Cannot Delete Existing Output-sample Texture Data File"
						}
					}
				}
			}
			7 {
				if {![info exists variboxouts]} {
					Inf "No Outputs To Sample"
				} else {
					VariboxPlayOutputSample $variboxouts
				}
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Set varibox defaults, specific to particular output-type

proc SetVariboxDefaultParams {} {
	global vb pa evv
	if {$vb(typ) < 0} {
		Inf "NO VARIBOX TYPE SET: ASSUMING GENERAL TYPE"
		set vb(typ) 0
	}
	set vb(shswelup) [lindex $evv(VBOX_SWEL_DFLT) 0]
	set vb(last_shswelup) $vb(shswelup) 
	set vb(shsweldn) [lindex $evv(VBOX_SWEL_DFLT) 1]
	set vb(last_shsweldn) $vb(shsweldn) 
	set vb(shsoftup) [lindex $evv(VBOX_SOFT_DFLT) 0]
	set vb(last_shsoftup) $vb(shsoftup) 
	set vb(shsoftdn) [lindex $evv(VBOX_SOFT_DFLT) 1]
	set vb(last_shsoftdn) $vb(shsoftdn) 
	set vb(shhardup) [lindex $evv(VBOX_HARD_DFLT) 0]
	set vb(last_shhardup) $vb(shhardup) 
	set vb(shharddn) [lindex $evv(VBOX_HARD_DFLT) 1]
	set vb(last_shharddn) $vb(shharddn) 
	set vb(shclipup)  [lindex $evv(VBOX_CLIP_DFLT) 0]
	set vb(last_shclipup)  $vb(shclipup)  
	set vb(shclipdn)  [lindex $evv(VBOX_CLIP_DFLT) 1]
	set vb(last_shclipdn)  $vb(shclipdn)  
	set vb(shclipstt) [lindex $evv(VBOX_CLIP_DFLT) 2]
	set vb(last_shclipstt) $vb(shclipstt) 
	set vb(shclipend) [lindex $evv(VBOX_CLIP_DFLT) 3]
	set vb(last_shclipend) $vb(shclipend) 

	if {($vb(typ) == $evv(VB_ITERED)) || ($vb(typ) == $evv(VB_PULSED)) || ($vb(typ) == $evv(VB_ATKRES))} {
		set vb(stakmin)  $evv(VBOX_STAKMIN_DFLT)
		set vb(stakmax)  $evv(VBOX_STAKMAX_DFLT)
		if {$vb(tors) || ($vb(typ) == $evv(VB_ATKRES))} {
			set vb(staklean) $evv(VBOX_STAKLEAN_DFLT)
			set vb(last_staklean) $vb(staklean)
		} else {
			catch {set vb(last_staklean) $vb(staklean)}
			set vb(staklean) ""
		}
		set vb(last_stakmin)  $vb(stakmin)
		set vb(last_stakmax)  $vb(stakmax)
		if {$vb(typ) == $evv(VB_PULSED)} {
			catch {set vb(last_preverbmax) $vb(preverbmax)}
			catch {set vb(last_preverbmin) $vb(preverbmin)}
			set vb(preverbmin) ""
			set vb(oversup) $evv(VBOX_OVERSUP_DFLT)
			set vb(last_oversup) $vb(oversup)
		} elseif {$vb(typ) == $evv(VB_ATKRES)} {
			catch {set vb(last_oversup) $vb(oversup)}
			set vb(preverbmax) $evv(VBOX_PREVMAX_DFLT)
			set vb(preverbmin) $evv(VBOX_PREVMIN_DFLT)
		} else {
			catch {set vb(last_preverbmax) $vb(preverbmax)}
			set vb(preverbmax) ""
			catch {set vb(last_preverbmin) $vb(preverbmin)}
			set vb(preverbmin) ""
			catch {set vb(last_oversup) $vb(oversup)}
			set vb(oversup) ""
		}
	} else {
		catch {set vb(last_stakmin)  $vb(stakmin)}
		catch {set vb(last_stakmax)  $vb(stakmax)}
		catch {set vb(last_staklean) $vb(staklean)}
		catch {set vb(last_oversup) $vb(oversup)}
		catch {set vb(last_preverbmax) $vb(preverbmax)}
		catch {set vb(last_preverbmin) $vb(preverbmin)}
		set vb(stakmin)  ""
		set vb(stakmax)  ""
		set vb(staklean) ""
		set vb(oversup) ""
		set vb(preverbmax) ""
		set vb(preverbmin) ""
	}

	if {($vb(typ) == $evv(VB_GENERL)) || ($vb(typ) == $evv(VB_WOBBLY))} {
		set vb(glisvalval) $evv(VBOX_DRIFT_DFLT)
		set vb(last_glisvalval) $vb(glisvalval) 
	} else {
		catch {set vb(last_glisvalval) $vb(glisvalval)}
		set vb(glisvalval) ""
	}

	if {($vb(typ) == $evv(VB_GENERL)) || ($vb(typ) == $evv(VB_WOBBLY)) || ($vb(typ) == $evv(VB_ATKRES))} {
		set vb(vibfrq)	 $evv(VBOX_VIBF_DFLT)
		set vb(last_vibfrq)	 $vb(vibfrq)	 
		set vb(vibfrqlo) $evv(VBOX_VIBFLO_DFLT) 
		set vb(last_vibfrqlo) $vb(vibfrqlo) 
		set vb(vibfrqhi) $evv(VBOX_VIBFHI_DFLT)
		set vb(last_vibfrqhi) $vb(vibfrqhi) 

		set vb(vibdep)   $evv(VBOX_VIBD_DFLT)
		set vb(last_vibdep)   $vb(vibdep)   
		set vb(vibdeplo) $evv(VBOX_VIBDLO_DFLT)
		set vb(last_vibdeplo) $vb(vibdeplo) 
		set vb(vibdephi) $evv(VBOX_VIBDHI_DFLT)
		set vb(last_vibdephi) $vb(vibdephi) 

	} else {
		catch {set set vb(last_vibfrq)	 $vb(vibfrq)}
		set vb(vibfrq)	 ""
		catch {set set vb(last_vibfrqlo) $vb(vibfrqlo)}
		set vb(vibfrqlo) ""
		catch {set set vb(last_vibfrqhi) $vb(vibfrqhi)}
		set vb(vibfrqhi) ""

		catch {set set vb(last_vibdep)   $vb(vibdep)}
		set vb(vibdep)   ""
		catch {set set vb(last_vibdeplo) $vb(vibdeplo)}
		set vb(vibdeplo) ""
		catch {set set vb(last_vibdephi) $vb(vibdephi)}
		set vb(vibdephi) ""
	}
	if {($vb(typ) != $evv(VB_ITERED)) && ($vb(typ) != $evv(VB_PULSED)) && ($vb(typ) != $evv(VB_WOBBLY))} {

		set vb(trmfrq)	 $evv(VBOX_TRMF_DFLT)
		set vb(last_trmfrq)	 $vb(trmfrq)	 
		set vb(trmfrqlo) $evv(VBOX_TRMFLO_DFLT) 
		set vb(last_trmfrqlo) $vb(trmfrqlo) 
		set vb(trmfrqhi) $evv(VBOX_TRMFHI_DFLT)
		set vb(last_trmfrqhi) $vb(trmfrqhi) 

		set vb(trmdep)   $evv(VBOX_TRMD_DFLT)
		set vb(last_trmdep)   $vb(trmdep)   
		set vb(trmdeplo) $evv(VBOX_TRMDLO_DFLT)
		set vb(last_trmdeplo) $vb(trmdeplo) 
		set vb(trmdephi) $evv(VBOX_TRMDHI_DFLT)
		set vb(last_trmdephi) $vb(trmdephi) 
	
		set vb(trmsqmin) $evv(VBOX_TRMSQMIN_DFLT)
		set vb(last_trmsqmin) $vb(trmsqmin)
		if {$vb(typ) != $evv(VB_ATKRES)} {
			set vb(trmsqmax) $evv(VBOX_TRMSQRESMAX_DFLT)
		} else {
			set vb(trmsqmax) $evv(VBOX_TRMSQMAX_DFLT)
		}
		set vb(last_trmsqmax) $vb(trmsqmax)

	}  else {
		catch {set vb(last_trmfrq)	 $vb(trmfrq)}
		set vb(trmfrq)	 ""
		catch {set vb(last_trmfrqlo) $vb(trmfrqlo)}
		set vb(trmfrqlo) ""
		catch {set vb(last_trmfrqhi) $vb(trmfrqhi)}
		set vb(trmfrqhi) ""

		catch {set vb(last_trmdep)	 $vb(trmdep)}
		set vb(trmdep)	 ""
		catch {set vb(last_trmdeplo) $vb(trmdeplo)}
		set vb(trmdeplo) ""
		catch {set vb(last_trmdephi) $vb(trmdephi)}
		set vb(trmdephi) ""

		catch {set vb(last_trmsqmin) $vb(trmsqmin)}
		set vb(trmsqmin) ""
		catch {set vb(last_trmsqmax) $vb(trmsqmax)}
		set vb(trmsqmax) ""
	}
	if {$vb(typ) == $evv(VB_ATKRES)} {
		catch {set vb(last_repdel)	 $vb(repdel)}
		set vb(repdel)	 ""
		catch {set vb(last_repdello) $vb(repdello)}
		set vb(repdello) ""
		catch {set vb(last_repdelhi) $vb(repdelhi)}
		set vb(repdelhi) ""
		catch {set vb(last_maxdur)	 $vb(maxdur)}
		set vb(maxdur)	""
		catch {set vb(last_mindur)	 $vb(mindur)}
		set vb(mindur)	""
		catch {set set vb(last_swell)	 $vb(swell)}
		set vb(swell)	""
		catch {set set vb(last_soft)	 $vb(soft)}
		set vb(soft)	""
		catch {set set vb(last_strong)	 $vb(strong)}
		set vb(strong)	""
		catch {set set vb(last_atk)		 $vb(atk)}
		set vb(atk)		""
	} else {
		set vb(repdel)	 $evv(VBOX_REP_DFLT)	
		set vb(last_repdel)	 $vb(repdel)	 
		set vb(repdello) $evv(VBOX_REPLO_DFLT)
		set vb(last_repdello) $vb(repdello) 
		set vb(repdelhi) $evv(VBOX_REPHI_DFLT)
		set vb(last_repdelhi) $vb(repdelhi) 
		set vb(maxdur)	$pa($vb(ifnam),$evv(DUR))
		set vb(last_maxdur)	$vb(maxdur)	
		set vb(mindur)	[expr $pa($vb(ifnam),$evv(DUR))/2.0]
		set vb(last_mindur)	$vb(mindur)	
		set vb(swell)	 $evv(VBOX_SWELL)
		set vb(last_swell)	 $vb(swell)	 
		set vb(soft)	 $evv(VBOX_SOFT)
		set vb(last_soft)	 $vb(soft)	 
		set vb(strong)	 $evv(VBOX_STRONG)
		set vb(last_strong)	 $vb(strong)	 
		set vb(atk)		 $evv(VBOX_ATK)
		set vb(last_atk)		 $vb(atk)		 
	}


	set vb(all) 1
	set vb(norev) 1
	set vb(minlorev) 80
	set vb(maxlorev) 250
	set vb(minhirev) 250
	set vb(maxhirev) 1000
	set vb(dryrev)   7
	if {$vb(typ) == $evv(VB_ATKRES)} {
		set vb(minlorev) ""
		set vb(maxlorev) ""
		set vb(minhirev) ""
		set vb(maxhirev) ""
		set vb(dryrev)   ""
	} else {
		set vb(minlorev) 80
		set vb(maxlorev) 250
		set vb(minhirev) 250
		set vb(maxhirev) 1000
		set vb(dryrev)   7
	}
	set vb(noshswell) 0
	set vb(noshsoft) 0
	set vb(nostak) 0
	set vb(noshhard) 0
	set vb(noshclip) 0
	set vb(nofixd) 0
	set vb(noacc) 0
	set vb(norit) 0
	set vb(novib) 0
	set vb(novffixd) 0
	set vb(novfacc) 0
	set vb(novfrit) 0
	set vb(novdfixd) 0
	set vb(novdacc) 0
	set vb(novdrit) 0
	set vb(notrm) 0
	set vb(notffixd) 0
	set vb(notfacc) 0
	set vb(notfrit) 0
	set vb(notdfixd) 0
	set vb(notdacc) 0
	set vb(notdrit) 0
	set vb(noeswell) 0
	set vb(noesoft) 0
	set vb(noestrong) 0
	set vb(noeatk) 0
}

#------- Remember parameters set, in case of reset

proc RememberVariboxDefaultParams {} {
	global vb pa evv
	catch {set vb(last_shswelup) $vb(shswelup) }
	catch {set vb(last_shsweldn) $vb(shsweldn) }
	catch {set vb(last_shsoftup) $vb(shsoftup) }
	catch {set vb(last_shsoftdn) $vb(shsoftdn) }
	catch {set vb(last_shhardup) $vb(shhardup) }
	catch {set vb(last_shharddn) $vb(shharddn) }
	catch {set vb(last_shclipup)  $vb(shclipup)  }
	catch {set vb(last_shclipdn)  $vb(shclipdn)  }
	catch {set vb(last_shclipstt) $vb(shclipstt) }
	catch {set vb(last_shclipend) $vb(shclipend) }

	if {($vb(typ) == $evv(VB_ITERED)) || ($vb(typ) == $evv(VB_PULSED)) || ($vb(typ) == $evv(VB_ATKRES))} {
		if {$vb(tors) || ($vb(typ) == $evv(VB_ATKRES))} {
			catch {set vb(last_staklean) $vb(staklean)}
		}
		catch {set vb(last_stakmin)  $vb(stakmin)}
		catch {set vb(last_stakmax)  $vb(stakmax)}
		if {$vb(typ) == $evv(VB_PULSED)} {
			catch {set vb(last_oversup) $vb(oversup)}
		} elseif {$vb(typ) == $evv(VB_ATKRES)} {
			catch {set vb(last_preverbmax) $vb(preverbmax)}
			catch {set vb(last_preverbmin) $vb(preverbmin)}
		}
	} else {
		catch {set vb(last_stakmin)  $vb(stakmin)}
		catch {set vb(last_stakmax)  $vb(stakmax)}
		catch {set vb(last_staklean) $vb(staklean)}
		catch {set vb(last_oversup) $vb(oversup)}
		catch {set vb(last_preverbmax) $vb(preverbmax)}
		catch {set vb(last_preverbmin) $vb(preverbmin)}
	}

	if {($vb(typ) == $evv(VB_GENERL)) || ($vb(typ) == $evv(VB_WOBBLY))} {
		catch {set set vb(last_glisvalval) $vb(glisvalval) }
	}

	if {($vb(typ) == $evv(VB_GENERL)) || ($vb(typ) == $evv(VB_WOBBLY)) || ($vb(typ) == $evv(VB_ATKRES))} {
		catch {set vb(last_vibfrq)	 $vb(vibfrq)	 }
		catch {set vb(last_vibfrqlo) $vb(vibfrqlo) }
		catch {set vb(last_vibfrqhi) $vb(vibfrqhi) }

		catch {set vb(last_vibdep)   $vb(vibdep)   }
		catch {set vb(last_vibdeplo) $vb(vibdeplo) }
		catch {set vb(last_vibdephi) $vb(vibdephi) }
	}
	if {($vb(typ) != $evv(VB_ITERED)) && ($vb(typ) != $evv(VB_PULSED)) && ($vb(typ) != $evv(VB_WOBBLY))} {

		catch {set vb(last_trmfrq)	 $vb(trmfrq)	 }
		catch {set vb(last_trmfrqlo) $vb(trmfrqlo) }
		catch {set vb(last_trmfrqhi) $vb(trmfrqhi) }

		catch {set vb(last_trmdep)   $vb(trmdep)   }
		catch {set vb(last_trmdeplo) $vb(trmdeplo) }
		catch {set vb(last_trmdephi) $vb(trmdephi) }

		catch {set vb(last_trmsqmin) $vb(trmsqmin) }
		catch {set vb(last_trmsqmax) $vb(trmsqmax) }

	}
	if {$vb(typ) == $evv(VB_ATKRES)} {
		catch {set vb(last_preverbmax) $vb(preverbmax)}
		catch {set vb(last_preverbmin) $vb(preverbmin)}
	} else {
		catch {set vb(last_repdel)	 $vb(repdel)	 }
		catch {set vb(last_repdello) $vb(repdello) }
		catch {set vb(last_repdelhi) $vb(repdelhi) }
		catch {set vb(last_maxdur)	$vb(maxdur)	}
		catch {set vb(last_mindur)	$vb(mindur)	}
		catch {set vb(last_swell)	 $vb(swell)	 }
		catch {set vb(last_soft)	 $vb(soft)	 }
		catch {set vb(last_strong)	 $vb(strong)	 }
		catch {set vb(last_atk)	 $vb(atk)		 }
		catch {set vb(last_all)		$vb(all)}
		catch {set vb(last_norev) $vb(norev)}
		catch {set vb(last_minlorev) $vb(minlorev)}
		catch {set vb(last_maxlorev) $vb(maxlorev)}
		catch {set vb(last_minhirev) $vb(minhirev)}
		catch {set vb(last_maxhirev) $vb(maxhirev)}
		catch {set vb(last_dryrev)  $vb(dryrev)}
	}
	catch {set vb(last_noshswell) $vb(noshswell)}
	catch {set vb(last_noshsoft) $vb(noshsoft)}
	catch {set vb(last_nostak) $vb(nostak)}
	catch {set vb(last_noshhard) $vb(noshhard)}
	catch {set vb(last_noshclip) $vb(noshclip)}
	catch {set vb(last_nofixd) $vb(nofixd)}
	catch {set vb(last_noacc) $vb(noacc)}
	catch {set vb(last_norit) $vb(norit)}
	catch {set vb(last_novib) $vb(novib)}
	catch {set vb(last_novffixd) $vb(novffixd)}
	catch {set vb(last_novfacc) $vb(novfacc)}
	catch {set vb(last_novfrit) $vb(novfrit)}
	catch {set vb(last_novdfixd) $vb(novdfixd)}
	catch {set vb(last_novdacc) $vb(novdacc)}
	catch {set vb(last_novdrit) $vb(novdrit)}
	catch {set vb(last_notrm) $vb(notrm)}
	catch {set vb(last_notffixd) $vb(notffixd)}
	catch {set vb(last_notfacc) $vb(notfacc)}
	catch {set vb(last_notfrit) $vb(notfrit)}
	catch {set vb(last_notdfixd) $vb(notdfixd)}
	catch {set vb(last_notdacc) $vb(notdacc)}
	catch {set vb(last_notdrit) $vb(notdrit)}
	catch {set vb(last_noeswell) $vb(noeswell)}
	catch {set vb(last_noesoft) $vb(noesoft)}
	catch {set vb(last_noestrong) $vb(noestrong)}
	catch {set vb(last_noeatk) $vb(noeatk)}
}

#---- Generate slightly Randomised series, around a fixed frq value

proc RandFrqSeq {val dur start} {
	global evv
	set tstep $evv(VBOX_RAND_TSTEP)
	set time 0
	set n 0
	set wander [expr $val * $evv(VBOX_FIXDVAL_DRIFT)]
	if {$start > 0.0} {
		set nuvals [list 0.0 0.0]
		lappend nuvals $start 0.0
		set time [expr $start + $tstep]
		set dur [expr $dur - $time]
	}
	set cnt [expr int(round($dur)/$tstep) + 1]
	while {$n < $cnt} {
		lappend nuvals $time
		set time [expr $time + $tstep]
		set stray [expr (rand() * 2.0) - 1.0]
		set stray [expr $stray * $wander]
		lappend nuvals [expr $val + $stray] 
		incr n
	}
	return $nuvals
}

proc RandDepSeq {val dur start} {
	global evv
	set tstep $evv(VBOX_RAND_TSTEP)
	set time 0
	set n 0
	if {$val >= 0.5} {
		set wander [expr (1.0 - $val) * $evv(VBOX_FIXDVAL_DRIFT)]
	} else {
		set wander [expr $val * $evv(VBOX_FIXDVAL_DRIFT)]
	}
	if {$start > 0.0} {
		set nuvals [list 0.0 0.0]
		lappend nuvals $start 0.0
		set time [expr $start + $tstep]
		set dur [expr $dur - $time]
	}
	set cnt [expr int(round($dur)/$tstep) + 1]
	while {$n < $cnt} {
		lappend nuvals $time
		set time [expr $time + $tstep]
		set stray [expr (rand() * 2.0) - 1.0]
		set stray [expr $stray * $wander]
		lappend nuvals [expr $val + $stray] 
		incr n
	}
	return $nuvals
}

#--- Do pitch glides

proc DoVariboxGlis {typ ifnam ofnam glisvalval} {
	global vb evv CDPidrun prg_dun prg_abortd simple_program_messages
	set maxglis $glisvalval
	set minglis [expr $glisvalval * 0.5]
	set range [expr $maxglis - $minglis]
	set wander [expr $range * rand()]
	set glisval [expr $minglis + $wander]
	if {$typ == "dn"} {
		set glisval [expr -$glisval]
	}
	set glisbrkvals [list 0.0 0 $vb(maxdur) $glisval]
	set brknam $evv(DFLT_OUTNAME)
	append brknam $vb(tempfilcnt) $evv(TEXT_EXT)
	incr vb(tempfilcnt)
	set typ [string toupper $typ]
	if [catch {open $brknam "w"} zit] {
		Inf "Cannot Open Temporary Breakpoint File For $typ Pitch Glide"
		return 0
	}
	foreach {time val} $glisbrkvals {
	set line [list $time $val]
		puts $zit $line
	}
	close $zit
	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	catch {unset simple_program_messages}
	set cmd	[file join $evv(CDPROGRAM_DIR) modify]
	lappend cmd speed 2 $ifnam $ofnam $brknam
	if [catch {open "|$cmd"} CDPidrun] {
		Inf "Cannot Create Pitch $typ Glide: $CDPidrun"
		catch {unset CDPidrun}
		return 0
	} else {
		fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
	}
	vwait prg_dun
	if {$prg_abortd} {
		set prg_dun 0
	}
	if {!$prg_dun} {
		set msg "Failed To Create Pitch $typ Glide :"
		set msg [AddSimpleMessages $msg]
		Inf $msg
		return 0
	}
	if {![file exists $ofnam]} {
		set msg "Create Pitch $typ Glide Failed :"
		set msg [AddSimpleMessages $msg]
		Inf $msg
		return 0
	}
	return 1
}

#--- Do vibrato processing

proc DoVariboxVib {ifnam ofnam vf vd typ} {
	global vb evv CDPidrun prg_dun prg_abortd simple_program_messages variboxmsgs
	set brkfnam $evv(DFLT_OUTNAME)
	append brkfnam $vb(tempfilcnt) $evv(TEXT_EXT)
	incr vb(tempfilcnt)
	set brkdnam $evv(DFLT_OUTNAME)
	append brkdnam $vb(tempfilcnt) $evv(TEXT_EXT)
	incr vb(tempfilcnt)
	if [catch {open $brkfnam "w"} zit] {
		set msg "Failed To Make Temporary $typ Frq Brkfile For $ofnam"
		lappend variboxmsgs $msg
		return 0
	}
	foreach {time val} $vf {
		set line [list $time $val]
		puts $zit $line
	}
	close $zit
	if [catch {open $brkdnam "w"} zit2] {
		set msg "Failed To Make Temporary $typ Depth Brkfile For $ofnam"
		lappend variboxmsgs $msg
		return 0
	}
	foreach {time val} $vd {
		set line [list $time $val]
		puts $zit2 $line
	}
	close $zit2
	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	catch {unset simple_program_messages}
	switch -- $typ {
		"vibrato" {
			set cmd	[file join $evv(CDPROGRAM_DIR) modify]
			lappend cmd speed 6 $ifnam $ofnam $brkfnam $brkdnam
		}
		"tremolo" {
			if {$vb(trmsqrange) > 0} {
				set shrink [expr rand() * $vb(trmsqrange)]
				set shrink [expr $val + $vb(trmsqmin)]
			} else {
				set shrink $vb(trmsqmin)
			}
			set cmd	[file join $evv(CDPROGRAM_DIR) tremolo]
			lappend cmd tremolo 1 $ifnam $ofnam $brkfnam $brkdnam 1.0 $shrink
		}
	}
	set typ [string toupper $typ]
	if [catch {open "|$cmd"} CDPidrun] {
		set msg "Cannot Create $typ File $ofnam: $CDPidrun"
		lappend variboxmsgs $msg
		catch {unset CDPidrun}
		return 0
	} else {
		fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
	}
	vwait prg_dun
	if {$prg_abortd} {
		set prg_dun 0
	}
	if {!$prg_dun} {
		set msg "Failed To Create $typ File $ofnam :"
		set msg [AddSimpleMessages $msg]
		lappend variboxmsgs $msg
		return 0
	}
	if {![file exists $ofnam]} {
		set msg "Create $typ File $ofnam FAILED :"
		set msg [AddSimpleMessages $msg]
		lappend variboxmsgs $msg
		return 0
	}
	return 1
}

#--- Envelope the short variants

proc DoVariboxShenv {ifnam ofnam typ} {
	global vb evv CDPidrun prg_dun prg_abortd simple_program_messages variboxmsgs
	switch -- $typ {
		"swell" {
			set shortfnam $evv(DFLT_OUTNAME)						;#	Does cut
			append shortfnam 0000 $vb(tempfilcnt) $evv(SNDFILE_EXT)	;#	Then dovetails
			incr vb(tempfilcnt)
			set outfnam $ofnam
			set vb(unitlen) [expr $vb(shswelup) + $vb(shsweldn) + 0.001]
			set doveup $vb(shswelup)
			set dovedn $vb(shsweldn)
		}
		"soft" {
			set shortfnam $evv(DFLT_OUTNAME)						;#	Does cut
			append shortfnam 0000 $vb(tempfilcnt) $evv(SNDFILE_EXT)	;#	Then dovetails
			incr vb(tempfilcnt) 
			set outfnam $ofnam
			set vb(unitlen) [expr $vb(shsoftup) + $vb(shsoftdn) + 0.001]
			set doveup $vb(shsoftup)
			set dovedn $vb(shsoftdn)
		}
		"hard" {
			set shortfnam $evv(DFLT_OUTNAME)						;#	Does cut
			append shortfnam 0000 $vb(tempfilcnt) $evv(SNDFILE_EXT)	;#	Then dovetails
			incr vb(tempfilcnt) 
			set outfnam $ofnam
			set vb(unitlen) [expr $vb(shhardup) + $vb(shharddn) + 0.001]
			set doveup $vb(shhardup)
			set dovedn $vb(shharddn)
		}
		"clip" {
			set shortfnam $ifnam								;#	Does dovtails
			set outfnam $evv(DFLT_OUTNAME)						;#	Does curtails
			append outfnam 0000 $vb(tempfilcnt) $evv(SNDFILE_EXT)
			incr vb(tempfilcnt) 
			set doveup $vb(shclipup)
			set dovedn $vb(shclipdn)
		}
	}
	switch -- $typ {
		"swell" -
		"soft"  -
		"hard" {				;#	DO CUTTING
			set splen 5
			if {$vb(unitlen) < 0.005} {
				set splen [expr ($vb(unitlen)/2.0) * $evv(SECS_TO_MS)]
			}

			set CDPidrun 0
			set prg_dun 0
			set prg_abortd 0
			catch {unset simple_program_messages}
			set cmd	[file join $evv(CDPROGRAM_DIR) sfedit]
			lappend cmd cut 1 $ifnam $shortfnam 0.0 $vb(unitlen) -w$splen
			set typ [string toupper $typ]
			if [catch {open "|$cmd"} CDPidrun] {
				set msg "Cannot Cut File To Make Short $typ Variants: $CDPidrun"
				lappend variboxmsgs $msg
				catch {unset CDPidrun}
				return 0
			} else {
				fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
			}
			vwait prg_dun
			if {$prg_abortd} {
				set prg_dun 0
			}
			if {!$prg_dun} {
				set msg "Failed To Cut File To Make Short $typ Variants :"
				set msg [AddSimpleMessages $msg]
				lappend variboxmsgs $msg
				return 0
			}
			if {![file exists $shortfnam]} {
				set msg "Cut File To Make Short $typ Variants Failed :"
				set msg [AddSimpleMessages $msg]
				lappend variboxmsgs $msg
				return 0
			}
		}
	}

	;#	DO DOVETAILING

	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	catch {unset simple_program_messages}
	set cmd	[file join $evv(CDPROGRAM_DIR) envel]
	lappend cmd dovetail 1 $shortfnam $outfnam $doveup $dovedn 1 1 -t0
	set typ [string toupper $typ]
	if [catch {open "|$cmd"} CDPidrun] {
		set msg "Cannot Do Dovetail To Make Short $typ Variants: $CDPidrun"
		lappend variboxmsgs $msg
		catch {unset CDPidrun}
		return 0
	} else {
		fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
	}
	vwait prg_dun
	if {$prg_abortd} {
		set prg_dun 0
	}
	if {!$prg_dun} {
		set msg "failed To Do Dovetail To Make Short $typ Variants :"
		set msg [AddSimpleMessages $msg]
		lappend variboxmsgs $msg
		return 0
	}
	if {![file exists $outfnam]} {
		set msg "Do Dovetail To Make Short $typ Variants Failed :"
		set msg [AddSimpleMessages $msg]
		lappend variboxmsgs $msg
		return 0
	}

	;#	DO CURTAILING

	if {$typ == "CLIP"} {
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		set cmd	[file join $evv(CDPROGRAM_DIR) envel]
		lappend cmd curtail 4 $outfnam $ofnam $vb(shclipstt) $vb(shclipend) -t0
		if [catch {open "|$cmd"} CDPidrun] {
			set msg "Cannot Do Curtail To Make Short $typ Variants: $CDPidrun"
			lappend variboxmsgs $msg
			catch {unset CDPidrun}
			return 0
		} else {
			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			set msg "Failed To Do Curtail To Make Short $typ Variants :"
			set msg [AddSimpleMessages $msg]
			lappend variboxmsgs $msg
			return 0
		}
		if {![file exists $ofnam]} {
			set msg "Do Curtail To Make Short $typ Variants Failed :"
			set msg [AddSimpleMessages $msg]
			lappend variboxmsgs $msg
			return 0
		}
		set vb(unitlen) $vb(shclipend)
	}
	return 1
}

#--- Envelope the short variants

proc GetVariboxUnitlen {typ} {
	global vb
	switch -- $typ {
		"swell" {
			set len [expr $vb(shswelup) + $vb(shsweldn) + 0.001]
		}
		"soft" {
			set len [expr $vb(shsoftup) + $vb(shsoftdn) + 0.001]
		}
		"hard" {
			set len [expr $vb(shhardup) + $vb(shharddn) + 0.001]
		}
		"clip" {
			set len $vb(shclipend)
		}
	}
	return $len
}

#--- Do iterations of short events

proc DoVariboxIterate {ifnam ofnam delay typ} {
	global vb evv CDPidrun prg_dun prg_abortd simple_program_messages variboxmsgs

	switch -- $typ {
		0 { set typ "REGULAR"	   } 
		1 { set typ "ACCELERATING" } 
		2 { set typ "DECELERATING" }
	}
	set seed [expr int(round(rand() * 256.0))]
	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	catch {unset simple_program_messages}
	set cmd	[file join $evv(CDPROGRAM_DIR) extend]
	lappend cmd iterate 1 $ifnam $ofnam $vb(maxdur) -d$delay
	lappend cmd -r0.1 
	switch -- $vb(typ) {
		0  -
		3 {	;#	GENERAL or PULSED
			lappend cmd -p0.3
		}
		1 {	;#	STEADY
			lappend cmd -p0.0
		}
		2 {	;#	WOBBLY
			lappend cmd -p1.5
		}
	}
	lappend cmd -a0.1 -s$seed
	set typ [string toupper $typ]
	if [catch {open "|$cmd"} CDPidrun] {
		set msg "Cannot Do $typ Iteration Of Short Sound $ifnam: $CDPidrun"
		lappend variboxmsgs $msg
		catch {unset CDPidrun}
		return 0
	} else {
		fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
	}
	vwait prg_dun
	if {$prg_abortd} {
		set prg_dun 0
	}
	if {!$prg_dun} {
		set msg "Failed To Do $typ Iteration Of Short Sound $ifnam"
		set msg [AddSimpleMessages $msg]
		lappend variboxmsgs $msg
		return 0
	}
	if {![file exists $ofnam]} {
		set msg "$typ Iteration Of Short Sound $ifnam Failed"
		set msg [AddSimpleMessages $msg]
		lappend variboxmsgs $msg
		return 0
	}
	return 1
}

#---- Do the (duration adjusted) envelopes on srcfiles

proc DoVariboxEnvelope {ifnam ofnam envel dur} {
	global vb evv CDPidrun prg_dun prg_abortd simple_program_messages variboxmsgs

	set lastlevel -1
	set gotit 0
	set linecnt 0
	foreach {time level} $envel {
		lappend times $time
		lappend levels $level
		if {!$gotit && ($level < $lastlevel)} {
			set startshrink $linecnt
			set gotit 1
		}
		set lastlevel $level
		incr linecnt
	}
	set envlen [llength $times]
	set totaldur [expr [lindex $times end] - [lindex $times 0]]
	set endlen [expr [lindex $times end] - [lindex $times $startshrink]]
	set sttlen [expr $totaldur - $endlen]
	if {$sttlen >= $dur} {
		set shrink [expr $dur/$totaldur]
		set n 0
		while {$n < $envlen} {
			set time [lindex $times $n]
			set time [expr $time * $shrink]
			set times [lreplace $times $n $n $time]
			incr n
		}
	} else {
		set nuendlen [expr $dur - $sttlen]
		set shrink [expr $nuendlen/$endlen]
		set n $startshrink
		while {$n < $envlen} {
			set time [lindex $times $n]
			set span [expr $time - $sttlen]
			set time [expr $time * $shrink]
			set time [expr $time + $sttlen]
			set times [lreplace $times $n $n $time]
			incr n
		}
	}
	set eofnam $evv(DFLT_OUTNAME)
	append eofnam $vb(tempfilcnt) $evv(TEXT_EXT)
	incr vb(tempfilcnt) 

	if [catch {open $eofnam "w"} zit] { 
		set line "Failed To Open File $eofnam To Write Duration-adjusted Envelope"
		lappend variboxmsgs $line
		return 0
	}
	foreach time $times level $levels {
		set line [list $time $level]
		puts $zit $line
	}
	close $zit

	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	catch {unset simple_program_messages}
	set cmd	[file join $evv(CDPROGRAM_DIR) envel]
	lappend cmd impose 3 $ifnam $eofnam $ofnam
	if [catch {open "|$cmd"} CDPidrun] {
		set msg "Cannot Do Envelope On File $ifnam: $CDPidrun"
		lappend variboxmsgs $msg
		catch {unset CDPidrun}
		return 0
	} else {
		fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
	}
	vwait prg_dun
	if {$prg_abortd} {
		set prg_dun 0
	}
	if {!$prg_dun} {
		set msg "Failed To Do Envelope On File $ifnam"
		set msg [AddSimpleMessages $msg]
		lappend variboxmsgs $msg
		return 0
	}
	if {![file exists $ofnam]} {
		set msg "Envelope On File $ifnam Failed"
		set msg [AddSimpleMessages $msg]
		lappend variboxmsgs $msg
		return 0
	}
	return 1
}

#----- Create temporary brkfile with iterate delay vals

proc CreateVaribankDelayFile {delvals ofnam typ src} {

	if {$typ == 1} {
		set typ "ACCELERATING"
	} else {
		set typ "DECELERATING"
	}
	if [catch {open $ofnam "w"} zit] {
		set msg "Failed To Create Temporary Brkfile For $typ Iterations Of $src"
		return 0
	}
	foreach {time val} $delvals {
	set line [list $time $val]
		puts $zit $line
	}
	close $zit
	return 1
}

#---- Randomise durations of varibox output files

proc GetVariboxDur {} {
	global vb
	set range [expr $vb(maxdur) - $vb(mindur)]
	set wander [expr rand() * $range]
	set dur [expr $vb(mindur) + $wander]
	return $dur
}

#---- Error report on Varibox pass

proc DoVariboxErrorReport {} {
	global variboxmsgs evv vb
	if {[llength $variboxmsgs] <= 20} {
		set msg [lindex $variboxmsgs 0]
		foreach line [lrange $variboxmsgs 1 end] {
			append msg "\n$line"
		}
		Inf $msg
	} else {
		set msgfile $vb(ofnam)
		append msgfile "0_report" $evv(TEXT_EXT)
		if [catch {open $msgfile "w"} zit] {
			set msg "Cannot Open Report File: Here Are A Few Of The Error Messages\n"
			set cnt 0
			foreach line $variboxmsgs {
				append msg "\n$line"
				incr cnt
				if {$cnt >= 20} {
					break
				}
			}
			Inf $msg
		} else {
			foreach line $variboxmsgs {
				puts $zit $line
			}
			close $zit
			Inf "Error Report In File $msgfile"
		}
	}
}

#---- Permute order if large-scale-envelopes in list of envelopes

proc VariboxEnvperm {envlist} {
	set permlen [llength $envlist]
	set seqperm {}
	set n 0
	set n_plus_1 1
	set endindex -1
	while {$n < $permlen} {
		set t [expr int(floor(rand() * $n_plus_1))]
		if {$t==$n} {
			set q [concat $n $seqperm]
			set seqperm $q
		} else {
			incr t
			if {$t > $endindex} {
				lappend seqperm $n
			} else {
				set seqperm [linsert $seqperm $t $n]
			}
		}
		incr n
		incr n_plus_1
		incr endindex
	}
	foreach n $seqperm {
		lappend nuenv [lindex $envlist $n]
	}
	return $nuenv
}

#------- Configure varibox interface for different type of output

proc VaribankTypeConfigure {typ} {
	global vb evv
	focus .varibox.1.01.e
	switch -regexp -- $typ \
		^$evv(VB_GENERL)$ {
			.varibox.1.1.ll     config -text "------- SHORT SEGMENT REPEATS ---------------------- LONG SEGMENT PARAMS -------"
			.varibox.1.1.0.0.ll config -text "   Fixed delay"
			.varibox.1.1.0.0.e  config -bd 2 -state normal
			catch {set vb(repdel) $vb(last_repdel)}
			.varibox.1.1.0.1.ll config -text "   Min Vari-delay"
			.varibox.1.1.0.1.e  config -bd 2 -state normal
			catch {set vb(repdello) $vb(last_repdello)}
			.varibox.1.1.0.2.ll config -text "   Max Vari-delay"
			.varibox.1.1.0.2.e  config -bd 2 -state normal
			catch {set vb(repdelhi) $vb(last_repdelhi)}
			.varibox.1.1.1.0.x  config -text "X-fix"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.1.1.1.0.ll config -text "   Min Duration (secs)"
			.varibox.1.1.1.0.e  config -bd 2 -state normal
			catch {set vb(mindur) $vb(last_mindur)}
			.varibox.1.1.1.1.x  config -text "X-acc"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.1.1.1.1.ll config -text "   Max Duration (secs)"
			.varibox.1.1.1.1.e  config -bd 2 -state normal
			catch {set vb(maxdur) $vb(last_maxdur)}
			.varibox.1.1.1.2.x  config -text "X-rit"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.1.1.1.2.ll config -text "   Max Pitchdrift (semit)"
			.varibox.1.1.1.2.e  config -bd 2 -state normal
			catch {set vb(glisvalval) $vb(last_glisvalval)}
			.varibox.2.2.ll.ll  config -text "------------------------------ LONG SEGMENT VIBRATO "
			.varibox.2.2.ll.x   config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}] 
			.varibox.2.2.ll.ll2 config -text " -----------------------------------"
			.varibox.2.2.0.ll config -text "FREQ (Hz)"
			.varibox.2.2.0.0.ll config -text "   Fixed Frq"
			.varibox.2.2.0.0.x config -text "X-fix" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.2.0.0.e config -bd 2 -state normal
			catch {set vb(vibfrq) $vb(last_vibfrq)}
			.varibox.2.2.0.1.ll config -text "   Min Variable Frq"
			.varibox.2.2.0.1.x config -text "X-acc" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.2.0.1.e config -bd 2 -state normal
			catch {set vb(vibfrqlo) $vb(last_vibfrqlo)}
			.varibox.2.2.0.2.ll config -text "   Max Variable Frq"
			.varibox.2.2.0.2.x config -text "X-rit" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.2.0.2.e config -bd 2 -state normal
			catch {set vb(vibfrqhi) $vb(last_vibfrqhi)}
			.varibox.2.2.1.ll config -text "DEPTH (semitones)"
			.varibox.2.2.1.0.ll config -text "   Fixed depth"
			.varibox.2.2.1.0.x config -text "X-fix" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.2.1.0.e config -bd 2 -state normal
			catch {set vb(vibdep) $vb(last_vibdep)}
			.varibox.2.2.1.1.ll config -text "   Min Variable Depth"
			.varibox.2.2.1.1.x config -text "X-acc" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.2.1.1.e config -bd 2 -state normal
			catch {set vb(vibdeplo) $vb(last_vibdeplo)}
			.varibox.2.2.1.2.ll config -text "   Max Variable Depth"
			.varibox.2.2.1.2.x config -text "X-rit" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.2.1.2.e config -bd 2 -state normal
			catch {set vb(vibdephi) $vb(last_vibdephi)}
			.varibox.2.3.ll.ll  config -text "------------------------------ LONG SEGMENT TREMOLO "
			.varibox.2.3.ll.x   config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}] 
			.varibox.2.3.ll.ll2 config -text " -----------------------------------"
			.varibox.2.3.0.ll config -text "FREQ (Hz)"
			.varibox.2.3.0.0.ll config -text "   Fixed Frq"
			.varibox.2.3.0.0.x config -text "X-fix" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.3.0.0.e config -bd 2 -state normal
			catch {set vb(trmfrq) $vb(last_trmfrq)}
			.varibox.2.3.0.1.ll config -text "   Min Variable Frq"
			.varibox.2.3.0.1.x config -text "X-acc" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.3.0.1.e config -bd 2 -state normal
			catch {set vb(trmfrqlo) $vb(last_trmfrqlo)}
			.varibox.2.3.0.2.ll config -text "   Max Variable Frq"
			.varibox.2.3.0.2.x config -text "X-rit" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.3.0.2.e config -bd 2 -state normal
			catch {set vb(trmfrqhi) $vb(last_trmfrqhi)}
			.varibox.2.3.1.ll config -text "DEPTH (0-1)"
			.varibox.2.3.1.0.ll config -text "   Fixed depth"
			.varibox.2.3.1.0.x config -text "X-fix" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.3.1.0.e config -bd 2 -state normal
			catch {set vb(trmdep) $vb(last_trmdep)}
			.varibox.2.3.1.1.ll config -text "   Min Variable Depth"
			.varibox.2.3.1.1.x config -text "X-acc" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.3.1.1.e config -bd 2 -state normal
			catch {set vb(trmdeplo) $vb(last_trmdeplo)}
			.varibox.2.3.1.2.ll config -text "   Max Variable Depth"
			.varibox.2.3.1.2.x config -text "X-rit" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.3.1.2.e config -bd 2 -state normal
			catch {set vb(trmdephi) $vb(last_trmdephi)}
			.varibox.2.3.2.ll  config -text "NARROW (1-100)"
			.varibox.2.3.2.0.ll config -text "   Min"
			.varibox.2.3.2.0.e config -bd 2 -state normal
			catch {set vb(trmsqmin) $vb(last_trmsqmin)}
			.varibox.2.3.2.1.ll config -text "   Max"
			.varibox.2.3.2.1.e config -bd 2 -state normal
			catch {set vb(trmsqmax) $vb(last_trmsqmax)}
			.varibox.1.0.0.c.ll3 config -text ""
			.varibox.1.0.0.c.tr3 config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}] 
			.varibox.1.0.0.c.st3 config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}] 
			.varibox.1.0.0.c.x config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			.varibox.1.0.0.4.ll config -text ""
			set vb(last_stakmin) $vb(stakmin)
			set vb(stakmin) ""
			.varibox.1.0.0.4.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.1.0.0.5.ll config -text ""
			set vb(last_stakmax) $vb(stakmax)
			set vb(stakmax) ""
			.varibox.1.0.0.5.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.1.0.0.6.ll config -text ""
			.varibox.1.0.0.6.ps config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			catch {set vb(last_staklean) $vb(staklean)}
			set vb(staklean) ""
			.varibox.1.0.0.6.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.1.0.1.ll3 config -text ""
			if {[string first "Overlap" [.varibox.1.0.1.6.ll config -text]] >= 0} {
				catch {set vb(last_oversup) $vb(oversup)}
				set vb(oversup) ""
			} elseif {[string first "Min" [.varibox.1.0.1.6.ll config -text]] >= 0} { 
				catch {set vb(last_preverbmin) $vb(preverbmin)}
				set vb(preverbmin) ""
				catch {set vb(last_preverbmax) $vb(preverbmax)}
				set vb(preverbmax) ""
			}
			.varibox.1.0.1.6.ll config -text ""
			.varibox.1.0.1.6.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.1.0.1.7.ll config -text ""
			catch {set vb(last_preverbmax) $vb(preverbmax)}
			set vb(preverbmax) ""
			.varibox.1.0.1.7.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			bind .varibox.1.0.0.3.e <Control-Down> {focus .varibox.1.1.0.0.e}
			bind .varibox.1.1.0.0.e <Control-Up>   {focus .varibox.1.0.0.3.e}
			bind .varibox.1.0.1.4.e <Control-Left> {focus .varibox.1.0.0.3.e}
			bind .varibox.1.0.1.4.e <Control-Left> {focus .varibox.1.0.0.3.e}
			bind .varibox.1.0.1.5.e <Control-Left> {focus .varibox.1.0.0.3.e}
			bind .varibox.1.1.0.2.e <Control-Right> {focus .varibox.1.1.1.2.e}
			bind .varibox.1.1.1.2.e <Control-Left>  {focus .varibox.1.1.0.2.e}
			bind .varibox.1.1.0.2.e <Control-Down> {focus .varibox.2.2.0.0.e}
			bind .varibox.2.2.0.0.e <Control-Up>   {focus .varibox.1.1.0.2.e}
			bind .varibox.1.1.1.1.e <Control-Down> {focus .varibox.1.1.1.2.e}
			bind .varibox.1.1.1.2.e <Control-Up>   {focus .varibox.1.1.1.1.e}
			bind .varibox.1.1.1.2.e <Control-Down> {focus .varibox.2.2.1.0.e}
			bind .varibox.2.2.1.0.e <Control-Up>   {focus .varibox.1.1.1.2.e}
			bind .varibox.2.2.0.2.e <Control-Down> {focus .varibox.2.3.0.0.e}
			bind .varibox.2.3.0.0.e <Control-Up>   {focus .varibox.2.2.0.2.e}
			bind .varibox.2.2.1.2.e <Control-Down> {focus .varibox.2.3.1.0.e}
			bind .varibox.2.3.1.0.e <Control-Up>   {focus .varibox.2.2.1.2.e}
			bind .varibox.2.3.0.2.e <Control-Down>  {focus .varibox.2.4.0.0.e}
			bind .varibox.2.3.1.2.e <Control-Down>  {focus .varibox.2.4.0.0.e}
		
			bind .varibox.2.3.2.0.e <Control-Down>  {focus .varibox.2.3.2.1.e}
			bind .varibox.2.3.2.0.e <Control-Up>  {focus .varibox.2.2.1.2.e}
			bind .varibox.2.3.2.1.e <Control-Up>  {focus .varibox.2.3.2.0.e}
			bind .varibox.2.3.2.0.e <Control-Left>  {focus .varibox.2.3.1.0.e}
			bind .varibox.2.3.2.1.e <Control-Left>  {focus .varibox.2.3.1.1.e}
			bind .varibox.2.3.1.1.e <Control-Right>  {focus .varibox.2.3.2.1.e}
			bind .varibox.2.3.1.1.e <Control-Right>  {focus .varibox.2.3.2.0.e}
			bind .varibox.2.3.1.2.e <Control-Right>  {focus .varibox.2.3.2.0.e}

			bind .varibox.2.3.2.1.e <Control-Down>  {focus .varibox.2.4.2.0.e}
			bind .varibox.2.4.0.0.e <Control-Up>    {focus .varibox.2.3.0.2.e}
			bind .varibox.2.4.2.0.e <Control-Up>    {focus .varibox.2.3.0.2.e}

			bind .varibox.1.0.1.5.e <Control-Down>  {focus .varibox.1.1.1.0.e} 
			bind .varibox.1.1.1.0.e <Control-Up>    {focus .varibox.1.0.1.5.e} 
			bind .varibox.1.0.0.6.e <Control-Right> {focus .varibox.1.0.1.5.e} 
			.varibox.2.4.ll.ll config -text "-------------- ENVELOPE FORMS ------------------------------------- POST-REVERB " -fg $evv(SPECIAL)
			.varibox.2.4.ll.x config -text "X" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			catch {set vb(norev) $vb(last_norev)}
			.varibox.2.4.2.0.ll config -text "Min short (80-250)"
			.varibox.2.4.2.0.e config -bd 2 -state normal
			.varibox.2.4.2.1.ll config -text "Max short (80-250)"
			.varibox.2.4.2.1.e config -bd 2 -state normal
			.varibox.2.4.2.2.ll config -text "Min long (250-1000)"
			.varibox.2.4.2.2.e config -bd 2 -state normal
			.varibox.2.4.2.3.ll config -text "Max long (250-1000)"
			.varibox.2.4.2.3.e config -bd 2 -state normal
			.varibox.2.4.2.4.ll config -text "N = 1/N dry outputs"
			.varibox.2.4.2.4.e config -bd 2 -state normal
			catch {set vb(minlorev) $vb(last_minlorev)}
			catch {set vb(maxlorev) $vb(last_maxlorev)}
			catch {set vb(minhirev) $vb(last_minhirev)}
			catch {set vb(maxhirev) $vb(last_maxhirev)}
			catch {set vb(dryrev) $vb(last_dryrev)}
			.varibox.2.4.0.0.ll config -text "Swell"
			.varibox.2.4.0.0.e  config -bd 2 -state normal
			catch {set vb(swellval) $vb(last_swellval)}
			.varibox.2.4.0.0.x  config -text "X"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.4.0.1.ll config -text "Soft"
			.varibox.2.4.0.1.e  config  -bd 2 -state normal
			catch {set vb(softval) $vb(last_softval)}
			.varibox.2.4.0.1.x  config -text "X"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.4.0.2.ll config -text "Strong"
			.varibox.2.4.0.2.e  config  -bd 2 -state normal
			catch {set vb(strongval) $vb(last_strongval)}
			.varibox.2.4.0.2.x  config -text "X"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.4.0.3.ll config -text "Attacked"
			.varibox.2.4.0.3.e  config -bd 2 -state normal 
			catch {set vb(atkval) $vb(last_atkval)}
			.varibox.2.4.0.3.x  config -text "X"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.4.1.rrr  config -text "Apply envelopes at random"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.4.1.all  config -text "Apply every env to every snd"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			catch {set vb(all) $vb(last_all)}
		} \
		^$evv(VB_STEADY)$ {
			.varibox.1.1.ll     config -text "------- SHORT SEGMENT REPEATS ---------------------- LONG SEGMENT PARAMS -------"
			.varibox.1.1.0.0.ll config -text "   Fixed delay"
			.varibox.1.1.0.0.e  config -bd 2 -state normal
			catch {set vb(repdel) $vb(last_repdel)}
			.varibox.1.1.0.1.ll config -text "   Min Vari-delay"
			.varibox.1.1.0.1.e  config -bd 2 -state normal
			catch {set vb(repdello) $vb(last_repdello)}
			.varibox.1.1.0.2.ll config -text "   Max Vari-delay"
			.varibox.1.1.0.2.e  config -bd 2 -state normal
			catch {set vb(repdelhi) $vb(last_repdelhi)}
			.varibox.1.1.1.0.x  config -text "X-fix"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.1.1.1.0.ll config -text "   Min Duration (secs)"
			.varibox.1.1.1.0.e  config -bd 2 -state normal
			catch {set vb(mindur) $vb(last_mindur)}
			.varibox.1.1.1.1.x  config -text "X-acc"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.1.1.1.1.ll config -text "   Max Duration (secs)"
			.varibox.1.1.1.1.e  config -bd 2 -state normal
			catch {set vb(maxdur) $vb(last_maxdur)}
			.varibox.2.2.ll.ll  config -text ""
			.varibox.2.2.ll.x   config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}] 
			.varibox.2.2.ll.ll2 config -text ""
			.varibox.2.2.0.ll config -text ""
			.varibox.2.2.0.0.ll config -text ""
			.varibox.2.2.0.0.x config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			set vb(last_vibfrq) $vb(vibfrq)
			set vb(vibfrq) ""
			.varibox.2.2.0.0.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.2.0.1.ll config -text ""
			.varibox.2.2.0.1.x config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			set vb(last_vibfrqlo) $vb(vibfrqlo)
			set vb(vibfrqlo) ""
			.varibox.2.2.0.1.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.2.0.2.ll config -text ""
			.varibox.2.2.0.2.x config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			set vb(last_vibfrqhi) $vb(vibfrqhi)
			set vb(vibfrqhi) ""
			.varibox.2.2.0.2.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.2.1.ll config -text ""
			.varibox.2.2.1.0.ll config -text ""
			.varibox.2.2.1.0.x config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			set vb(last_vibdep) $vb(vibdep)
			set vb(vibdep) ""
			.varibox.2.2.1.0.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.2.1.1.ll config -text ""
			.varibox.2.2.1.1.x config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			set vb(last_vibdeplo) $vb(vibdeplo)
			set vb(vibdeplo) ""
			.varibox.2.2.1.1.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.2.1.2.ll config -text ""
			.varibox.2.2.1.2.x config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			set vb(last_vibdephi) $vb(vibdephi)
			set vb(vibdephi) ""
			.varibox.2.2.1.2.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.1.1.1.2.ll config -text ""
			set vb(last_glisvalval) $vb(glisvalval)
			set vb(glisvalval) ""
			.varibox.1.1.1.2.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.3.ll.ll  config -text "------------------------------ LONG SEGMENT TREMOLO "
			.varibox.2.3.ll.x   config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}] 
			.varibox.2.3.ll.ll2 config -text " -----------------------------------"
			.varibox.2.3.0.ll config -text "FREQ (Hz)"
			.varibox.2.3.0.0.ll config -text "   Fixed Frq"
			.varibox.2.3.0.0.x config -text "X-fix" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.3.0.0.e config -bd 2 -state normal
			catch {set vb(trmfrq) $vb(last_trmfrq)}
			.varibox.2.3.0.1.ll config -text "   Min Variable Frq"
			.varibox.2.3.0.1.x config -text "X-acc" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.3.0.1.e config -bd 2 -state normal
			catch {set vb(trmfrqlo) $vb(last_trmfrqlo)}
			.varibox.2.3.0.2.ll config -text "   Max Variable Frq"
			.varibox.2.3.0.2.x config -text "X-rit" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.3.0.2.e config -bd 2 -state normal
			catch {set vb(trmfrqhi) $vb(last_trmfrqhi)}
			.varibox.2.3.1.ll config -text "DEPTH (0-1)"
			.varibox.2.3.1.0.ll config -text "   Fixed depth"
			.varibox.2.3.1.0.x config -text "X-fix" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.3.1.0.e config -bd 2 -state normal
			catch {set vb(trmdep) $vb(last_trmdep)}
			.varibox.2.3.1.1.ll config -text "   Min Variable Depth"
			.varibox.2.3.1.1.x config -text "X-acc" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.3.1.1.e config -bd 2 -state normal
			catch {set vb(trmdeplo) $vb(last_trmdeplo)}
			.varibox.2.3.1.2.ll config -text "   Max Variable Depth"
			.varibox.2.3.1.2.x config -text "X-rit" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.3.1.2.e config -bd 2 -state normal
			catch {set vb(trmdephi) $vb(last_trmdephi)}
			.varibox.2.3.2.ll  config -text "NARROW (1-100)"
			.varibox.2.3.2.0.ll config -text "   Min"
			.varibox.2.3.2.0.e config -bd 2 -state normal
			catch {set vb(trmsqmin) $vb(last_trmsqmin)}
			.varibox.2.3.2.1.ll config -text "   Max"
			.varibox.2.3.2.1.e config -bd 2 -state normal
			catch {set vb(trmsqmax) $vb(last_trmsqmax)}
			.varibox.1.0.0.c.ll3 config -text ""
			.varibox.1.0.0.c.tr3 config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}] 
			.varibox.1.0.0.c.st3 config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}] 
			.varibox.1.0.0.c.x config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			.varibox.1.0.0.4.ll config -text ""
			set vb(last_stakmin) $vb(stakmin)
			set vb(stakmin) ""
			.varibox.1.0.0.4.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.1.0.0.5.ll config -text ""
			set vb(last_stakmax) $vb(stakmax)
			set vb(stakmax) ""
			.varibox.1.0.0.5.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.1.0.0.6.ll config -text ""
			.varibox.1.0.0.6.ps config -text "" -state disabled -indicatoron 0 -bd 0 -bd 0 -selectcolor [option get . background {}]
			catch {set vb(last_staklean) $vb(staklean)}
			set vb(staklean) ""
			.varibox.1.0.0.6.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.1.0.1.ll3 config -text ""
			if {[string first "Overlap" [.varibox.1.0.1.6.ll config -text]] >= 0} {
				catch {set vb(last_oversup) $vb(oversup)}
				set vb(oversup) ""
			} elseif {[string first "Min" [.varibox.1.0.1.6.ll config -text]] >= 0} { 
				catch {set vb(last_preverbmin) $vb(preverbmin)}
				set vb(preverbmin) ""
				catch {set vb(last_preverbmax) $vb(preverbmax)}
				set vb(preverbmax) ""
			}
			.varibox.1.0.1.6.ll config -text ""
			.varibox.1.0.1.6.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			bind .varibox.1.0.0.3.e <Control-Down> {focus .varibox.1.1.0.0.e}
			bind .varibox.1.1.0.0.e <Control-Up>   {focus .varibox.1.0.0.3.e}
			bind .varibox.1.0.1.4.e <Control-Left> {focus .varibox.1.0.0.3.e}
			bind .varibox.1.0.1.5.e <Control-Left> {focus .varibox.1.0.0.3.e}
			bind .varibox.1.1.0.2.e <Control-Down> {focus .varibox.2.3.0.0.e}
			bind .varibox.2.3.0.0.e <Control-Up>	 {focus .varibox.1.1.0.2.e}
			bind .varibox.1.1.0.2.e <Control-Right> {focus .varibox.1.1.1.1.e}
			bind .varibox.1.1.1.1.e <Control-Down> {focus .varibox.2.3.1.0.e}
			bind .varibox.2.3.1.0.e <Control-Up>   {focus .varibox.1.1.1.1.e}
			bind .varibox.2.4.0.0.e <Control-Up>	  {focus .varibox.2.3.0.2.e}

			bind .varibox.2.3.2.0.e <Control-Down>  {focus .varibox.2.3.2.1.e}
			bind .varibox.2.3.2.1.e <Control-Down>  {focus .varibox.2.4.0.0.e}
			bind .varibox.2.3.2.0.e <Control-Up>  {focus .varibox.2.2.1.2.e}
			bind .varibox.2.3.2.1.e <Control-Up>  {focus .varibox.2.3.2.0.e}
			bind .varibox.2.3.2.0.e <Control-Left>  {focus .varibox.2.3.1.0.e}
			bind .varibox.2.3.2.1.e <Control-Left>  {focus .varibox.2.3.1.1.e}
			bind .varibox.2.3.1.1.e <Control-Right>  {focus .varibox.2.3.2.1.e}
			bind .varibox.2.3.1.1.e <Control-Right>  {focus .varibox.2.3.2.0.e}
			bind .varibox.2.3.1.2.e <Control-Right>  {focus .varibox.2.3.2.0.e}

			bind .varibox.2.3.2.1.e <Control-Down>  {focus .varibox.2.4.2.0.e}
			bind .varibox.2.4.2.0.e <Control-Down>  {focus .varibox.2.4.2.1.e}
			bind .varibox.2.4.2.1.e <Control-Down>  {focus .varibox.2.4.2.2.e}
			bind .varibox.2.4.2.2.e <Control-Down>  {focus .varibox.2.4.2.3.e}
			bind .varibox.2.4.2.3.e <Control-Down>  {focus .varibox.2.4.2.4.e}
			bind .varibox.2.4.2.4.e <Control-Down>  {focus .varibox.1.01.e}
			bind .varibox.2.4.2.0.e <Control-Up>  {focus .varibox.2.3.2.1.e}
			bind .varibox.2.4.2.1.e <Control-Up>  {focus .varibox.2.4.2.0.e}
			bind .varibox.2.4.2.2.e <Control-Up>  {focus .varibox.2.4.2.1.e}
			bind .varibox.2.4.2.3.e <Control-Up>  {focus .varibox.2.4.2.2.e}
			bind .varibox.2.4.2.4.e <Control-Up>  {focus .varibox.2.4.2.3.e}

			bind .varibox.2.4.2.0.e <Control-Left>  {focus .varibox.2.4.0.0.e}
			bind .varibox.2.4.2.1.e <Control-Left>  {focus .varibox.2.4.0.1.e}
			bind .varibox.2.4.2.2.e <Control-Left>  {focus .varibox.2.4.0.2.e}
			bind .varibox.2.4.2.3.e <Control-Left>  {focus .varibox.2.4.0.2.e}
			bind .varibox.2.4.2.4.e <Control-Left>  {focus .varibox.2.4.0.3.e}
			bind .varibox.2.4.0.0.e <Control-Right> {focus .varibox.2.4.2.0.e}
			bind .varibox.2.4.0.1.e <Control-Right> {focus .varibox.2.4.2.1.e}
			bind .varibox.2.4.0.2.e <Control-Right> {focus .varibox.2.4.2.2.e}
			bind .varibox.2.4.0.3.e <Control-Right> {focus .varibox.2.4.2.3.e}

			bind .varibox.1.0.1.5.e <Control-Down>  {focus .varibox.1.1.1.0.e} 
			bind .varibox.1.1.1.0.e <Control-Up>    {focus .varibox.1.0.1.5.e} 
			bind .varibox.1.0.0.6.e <Control-Right> {focus .varibox.1.0.1.5.e} 
			.varibox.2.4.ll.ll config -text "-------------- ENVELOPE FORMS ------------------------------------- POST-REVERB " -fg $evv(SPECIAL)
			.varibox.2.4.ll.x config -text "X" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			catch {set vb(norev) $vb(last_norev)}
			.varibox.2.4.2.0.ll config -text "Min short (80-250)"
			.varibox.2.4.2.0.e config -bd 2 -state normal
			.varibox.2.4.2.1.ll config -text "Max short (80-250)"
			.varibox.2.4.2.1.e config -bd 2 -state normal
			.varibox.2.4.2.2.ll config -text "Min long (250-1000)"
			.varibox.2.4.2.2.e config -bd 2 -state normal
			.varibox.2.4.2.3.ll config -text "Max long (250-1000)"
			.varibox.2.4.2.3.e config -bd 2 -state normal
			.varibox.2.4.2.4.ll config -text "N = 1/N dry outputs"
			.varibox.2.4.2.4.e config -bd 2 -state normal
			catch {set vb(minlorev) $vb(last_minlorev)}
			catch {set vb(maxlorev) $vb(last_maxlorev)}
			catch {set vb(minhirev) $vb(last_minhirev)}
			catch {set vb(maxhirev) $vb(last_maxhirev)}
			catch {set vb(dryrev) $vb(last_dryrev)}
			.varibox.2.4.0.0.ll config -text "Swell"
			.varibox.2.4.0.0.e  config -bd 2 -state normal
			catch {set vb(swellval) $vb(last_swellval)}
			.varibox.2.4.0.0.x  config -text "X"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.4.0.1.ll config -text "Soft"
			.varibox.2.4.0.1.e  config  -bd 2 -state normal
			catch {set vb(softval) $vb(last_softval)}
			.varibox.2.4.0.1.x  config -text "X"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.4.0.2.ll config -text "Strong"
			.varibox.2.4.0.2.e  config  -bd 2 -state normal
			catch {set vb(strongval) $vb(last_strongval)}
			.varibox.2.4.0.2.x  config -text "X"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.4.0.3.ll config -text "Attacked"
			.varibox.2.4.0.3.e  config -bd 2 -state normal 
			catch {set vb(atkval) $vb(last_atkval)}
			.varibox.2.4.0.3.x  config -text "X"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.4.1.rrr  config -text "Apply envelopes at random"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.4.1.all  config -text "Apply every env to every snd"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			catch {set vb(all) $vb(last_all)}
		} \
		^$evv(VB_WOBBLY)$ {
			.varibox.1.1.ll     config -text "------- SHORT SEGMENT REPEATS ---------------------- LONG SEGMENT PARAMS -------"
			.varibox.1.1.0.0.ll config -text "   Fixed delay"
			.varibox.1.1.0.0.e  config -bd 2 -state normal
			catch {set vb(repdel) $vb(last_repdel)}
			.varibox.1.1.0.1.ll config -text "   Min Vari-delay"
			.varibox.1.1.0.1.e  config -bd 2 -state normal
			catch {set vb(repdello) $vb(last_repdello)}
			.varibox.1.1.0.2.ll config -text "   Max Vari-delay"
			.varibox.1.1.0.2.e  config -bd 2 -state normal
			catch {set vb(repdelhi) $vb(last_repdelhi)}
			.varibox.1.1.1.0.x  config -text "X-fix"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.1.1.1.0.ll config -text "   Min Duration (secs)"
			.varibox.1.1.1.0.e  config -bd 2 -state normal
			catch {set vb(mindur) $vb(last_mindur)}
			.varibox.1.1.1.1.x  config -text "X-acc"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.1.1.1.1.ll config -text "   Max Duration (secs)"
			.varibox.1.1.1.1.e  config -bd 2 -state normal
			catch {set vb(maxdur) $vb(last_maxdur)}
			.varibox.1.1.1.2.x  config -text "X-rit"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.1.1.1.2.ll config -text "   Max Pitchdrift (semit)"
			.varibox.1.1.1.2.e  config -bd 2 -state normal
			catch {set vb(glisvalval) $vb(last_glisvalval)}
			.varibox.2.2.ll.ll  config -text "------------------------------ LONG SEGMENT VIBRATO "
			.varibox.2.2.ll.x   config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}] 
			.varibox.2.2.ll.ll2 config -text " -----------------------------------"
			.varibox.2.2.0.ll config -text "FREQ (Hz)"
			.varibox.2.2.0.0.ll config -text "   Fixed Frq"
			.varibox.2.2.0.0.x config -text "X-fix" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.2.0.0.e config -bd 2 -state normal
			catch {set vb(vibfrq) $vb(last_vibfrq)}
			.varibox.2.2.0.1.ll config -text "   Min Variable Frq"
			.varibox.2.2.0.1.x config -text "X-acc" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.2.0.1.e config -bd 2 -state normal
			catch {set vb(vibfrqlo) $vb(last_vibfrqlo)}
			.varibox.2.2.0.2.ll config -text "   Max Variable Frq"
			.varibox.2.2.0.2.x config -text "X-rit" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.2.0.2.e config -bd 2 -state normal
			catch {set vb(vibfrqhi) $vb(last_vibfrqhi)}
			.varibox.2.2.1.ll config -text "DEPTH (semitones)"
			.varibox.2.2.1.0.ll config -text "   Fixed depth"
			.varibox.2.2.1.0.x config -text "X-fix" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.2.1.0.e config -bd 2 -state normal
			catch {set vb(vibdep) $vb(last_vibdep)}
			.varibox.2.2.1.1.ll config -text "   Min Variable Depth"
			.varibox.2.2.1.1.x config -text "X-acc" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.2.1.1.e config -bd 2 -state normal
			catch {set vb(vibdeplo) $vb(last_vibdeplo)}
			.varibox.2.2.1.2.ll config -text "   Max Variable Depth"
			.varibox.2.2.1.2.x config -text "X-rit" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.2.1.2.e config -bd 2 -state normal
			catch {set vb(vibdephi) $vb(last_vibdephi)}
			.varibox.2.3.ll.ll  config -text ""
			.varibox.2.3.ll.x   config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}] 
			.varibox.2.3.ll.ll2 config -text ""
			.varibox.2.3.0.ll config -text ""
			.varibox.2.3.0.0.ll config -text ""
			.varibox.2.3.0.0.x config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			set vb(last_trmfrq) $vb(trmfrq)
			set vb(trmfrq) ""
			.varibox.2.3.0.0.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.3.0.1.ll config -text ""
			.varibox.2.3.0.1.x config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			set vb(last_trmfrqlo) $vb(trmfrqlo)
			set vb(trmfrqlo) ""
			.varibox.2.3.0.1.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.3.0.2.ll config -text ""
			.varibox.2.3.0.2.x config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			set vb(last_trmfrqhi) $vb(trmfrqhi)
			set vb(trmfrqhi) ""
			.varibox.2.3.0.2.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.3.1.ll config -text ""
			.varibox.2.3.1.0.ll config -text ""
			.varibox.2.3.1.0.x config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			set vb(last_trmdep) $vb(trmdep)
			set vb(trmdep) ""
			.varibox.2.3.1.0.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.3.1.1.ll config -text ""
			.varibox.2.3.1.1.x config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			set vb(last_trmdeplo) $vb(trmdeplo)
			set vb(trmdeplo) ""
			.varibox.2.3.1.1.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.3.1.2.ll config -text ""
			.varibox.2.3.1.2.x config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			set vb(last_trmdephi) $vb(trmdephi)
			set vb(trmdephi) ""
			.varibox.2.3.1.2.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.3.2.ll  config -text ""
			.varibox.2.3.2.0.ll config -text ""
			catch {set vb(last_trmsqmin) $vb(trmsqmin)}
			set vb(trmsqmin) ""
			.varibox.2.3.2.0.e config  -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.3.2.1.ll config -text ""
			catch {set vb(last_trmsqmax) $vb(trmsqmax)}
			set vb(trmsqmax) ""
			.varibox.2.3.2.1.e config  -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.1.0.0.c.ll3 config -text ""
			.varibox.1.0.0.c.tr3 config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}] 
			.varibox.1.0.0.c.st3 config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}] 
			.varibox.1.0.0.c.x config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			.varibox.1.0.0.4.ll config -text ""
			set vb(last_stakmin) $vb(stakmin)
			set vb(stakmin) ""
			.varibox.1.0.0.4.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.1.0.0.5.ll config -text ""
			set vb(last_stakmax) $vb(stakmax)
			set vb(stakmax) ""
			.varibox.1.0.0.5.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.1.0.0.6.ll config -text ""
			.varibox.1.0.0.6.ps config -text "" -state disabled -indicatoron 0 -bd 0 -bd 0 -selectcolor [option get . background {}]
			catch {set vb(last_staklean) $vb(staklean)}
			set vb(staklean) ""
			.varibox.1.0.0.6.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.1.0.1.ll3 config -text ""
			if {[string first "Overlap" [.varibox.1.0.1.6.ll config -text]] >= 0} {
				catch {set vb(last_oversup) $vb(oversup)}
				set vb(oversup) ""
			} elseif {[string first "Min" [.varibox.1.0.1.6.ll config -text]] >= 0} { 
				catch {set vb(last_preverbmin) $vb(preverbmin)}
				set vb(preverbmin) ""
				catch {set vb(last_preverbmax) $vb(preverbmax)}
				set vb(preverbmax) ""
			}
			.varibox.1.0.1.6.ll config -text ""
			.varibox.1.0.1.6.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.1.0.1.7.ll config -text ""
			.varibox.1.0.1.7.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			bind .varibox.1.0.0.3.e <Control-Down> {focus .varibox.1.1.0.0.e}
			bind .varibox.1.1.0.0.e <Control-Up>   {focus .varibox.1.0.0.3.e}
			bind .varibox.1.0.1.4.e <Control-Left> {focus .varibox.1.0.0.3.e}
			bind .varibox.1.0.1.5.e <Control-Left> {focus .varibox.1.0.0.3.e}
			bind .varibox.1.1.0.2.e <Control-Down> {focus .varibox.2.2.0.0.e}
			bind .varibox.2.2.0.0.e <Control-Up>	 {focus .varibox.1.1.0.2.e}
			bind .varibox.1.1.0.2.e <Control-Right> {focus .varibox.1.1.1.2.e}
			bind .varibox.1.1.1.1.e <Control-Down> {focus .varibox.1.1.1.2.e}
			bind .varibox.2.2.1.0.e <Control-Up>   {focus .varibox.1.1.1.2.e}
			bind .varibox.2.2.0.2.e <Control-Down>  {focus .varibox.2.4.0.0.e}
			bind .varibox.2.2.1.2.e <Control-Down>  {focus .varibox.2.4.0.0.e}
			bind .varibox.2.4.0.0.e <Control-Up>	  {focus .varibox.2.2.0.2.e}
			bind .varibox.1.0.1.5.e <Control-Down>  {focus .varibox.1.1.1.0.e} 
			bind .varibox.1.1.1.0.e <Control-Up>    {focus .varibox.1.0.1.5.e} 
			bind .varibox.1.0.0.6.e <Control-Right> {focus .varibox.1.0.1.5.e} 

			.varibox.2.4.ll.ll config -text "-------------- ENVELOPE FORMS ------------------------------------- POST-REVERB " -fg $evv(SPECIAL)
			.varibox.2.4.ll.x config -text "X" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			catch {set vb(norev) $vb(last_norev)}
			.varibox.2.4.2.0.ll config -text "Min short (80-250)"
			.varibox.2.4.2.0.e config -bd 2 -state normal
			.varibox.2.4.2.1.ll config -text "Max short (80-250)"
			.varibox.2.4.2.1.e config -bd 2 -state normal
			.varibox.2.4.2.2.ll config -text "Min long (250-1000)"
			.varibox.2.4.2.2.e config -bd 2 -state normal
			.varibox.2.4.2.3.ll config -text "Max long (250-1000)"
			.varibox.2.4.2.3.e config -bd 2 -state normal
			.varibox.2.4.2.4.ll config -text "N = 1/N dry outputs"
			.varibox.2.4.2.4.e config -bd 2 -state normal
			catch {set vb(minlorev) $vb(last_minlorev)}
			catch {set vb(maxlorev) $vb(last_maxlorev)}
			catch {set vb(minhirev) $vb(last_minhirev)}
			catch {set vb(maxhirev) $vb(last_maxhirev)}
			catch {set vb(dryrev) $vb(last_dryrev)}
			.varibox.2.4.0.0.ll config -text "Swell"
			.varibox.2.4.0.0.e  config -bd 2 -state normal
			catch {set vb(swellval) $vb(last_swellval)}
			.varibox.2.4.0.0.x  config -text "X"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.4.0.1.ll config -text "Soft"
			.varibox.2.4.0.1.e  config  -bd 2 -state normal
			catch {set vb(softval) $vb(last_softval)}
			.varibox.2.4.0.1.x  config -text "X"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.4.0.2.ll config -text "Strong"
			.varibox.2.4.0.2.e  config  -bd 2 -state normal
			catch {set vb(strongval) $vb(last_strongval)}
			.varibox.2.4.0.2.x  config -text "X"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.4.0.3.ll config -text "Attacked"
			.varibox.2.4.0.3.e  config -bd 2 -state normal 
			catch {set vb(atkval) $vb(last_atkval)}
			.varibox.2.4.0.3.x  config -text "X"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.4.1.rrr  config -text "Apply envelopes at random"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.4.1.all  config -text "Apply every env to every snd"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			catch {set vb(all) $vb(last_all)}
		} \
		^$evv(VB_ITERED)$ - \
		^$evv(VB_PULSED)$ {
			.varibox.1.1.ll     config -text "------- SHORT SEGMENT REPEATS ---------------------- LONG SEGMENT PARAMS -------"
			.varibox.1.1.0.0.ll config -text "   Fixed delay"
			.varibox.1.1.0.0.e  config -bd 2 -state normal
			catch {set vb(repdel) $vb(last_repdel)}
			.varibox.1.1.0.1.ll config -text "   Min Vari-delay"
			.varibox.1.1.0.1.e  config -bd 2 -state normal
			catch {set vb(repdello) $vb(last_repdello)}
			.varibox.1.1.0.2.ll config -text "   Max Vari-delay"
			.varibox.1.1.0.2.e  config -bd 2 -state normal
			catch {set vb(repdelhi) $vb(last_repdelhi)}
			.varibox.1.1.1.0.x  config -text "X-fix"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.1.1.1.0.ll config -text "   Min Duration (secs)"
			.varibox.1.1.1.0.e  config -bd 2 -state normal
			catch {set vb(mindur) $vb(last_mindur)}
			.varibox.1.1.1.1.x  config -text "X-acc"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.1.1.1.1.ll config -text "   Max Duration (secs)"
			.varibox.1.1.1.1.e  config -bd 2 -state normal
			catch {set vb(maxdur) $vb(last_maxdur)}
			.varibox.1.1.1.2.x  config -text "X-rit"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.2.ll.ll  config -text ""
			.varibox.2.2.ll.x   config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}] 
			.varibox.2.2.ll.ll2 config -text ""
			.varibox.2.2.0.ll config -text ""
			.varibox.2.2.0.0.ll config -text ""
			.varibox.2.2.0.0.x config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			set vb(last_vibfrq) $vb(vibfrq)
			set vb(vibfrq) ""
			.varibox.2.2.0.0.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.2.0.1.ll config -text ""
			.varibox.2.2.0.1.x config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			set vb(last_vibfrqlo) $vb(vibfrqlo)
			set vb(vibfrqlo) ""
			.varibox.2.2.0.1.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.2.0.2.ll config -text ""
			.varibox.2.2.0.2.x config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			set vb(last_vibfrqhi) $vb(vibfrqhi)
			set vb(vibfrqhi) ""
			.varibox.2.2.0.2.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.2.1.ll config -text ""
			.varibox.2.2.1.0.ll config -text ""
			.varibox.2.2.1.0.x config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			set vb(last_vibdep) $vb(vibdep)
			set vb(vibdep) ""
			.varibox.2.2.1.0.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.2.1.1.ll config -text ""
			.varibox.2.2.1.1.x config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			set vb(last_vibdeplo) $vb(vibdeplo)
			set vb(vibdeplo) ""
			.varibox.2.2.1.1.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.2.1.2.ll config -text ""
			.varibox.2.2.1.2.x config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			set vb(last_vibdephi) $vb(vibdephi)
			set vb(vibdephi) ""
			.varibox.2.2.1.2.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.1.1.1.2.ll config -text ""
			set vb(last_glisvalval) $vb(glisvalval)
			set vb(glisvalval) ""
			.varibox.1.1.1.2.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.3.ll.ll  config -text ""
			.varibox.2.3.ll.x   config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}] 
			.varibox.2.3.ll.ll2 config -text ""
			.varibox.2.3.0.ll config -text ""
			.varibox.2.3.0.0.ll config -text ""
			.varibox.2.3.0.0.x config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			set vb(last_trmfrq) $vb(trmfrq)
			set vb(trmfrq) ""
			.varibox.2.3.0.0.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.3.0.1.ll config -text ""
			.varibox.2.3.0.1.x config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			set vb(last_trmfrqlo) $vb(trmfrqlo)
			set vb(trmfrqlo) ""
			.varibox.2.3.0.1.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.3.0.2.ll config -text ""
			.varibox.2.3.0.2.x config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			set vb(last_trmfrqhi) $vb(trmfrqhi)
			set vb(trmfrqhi) ""
			.varibox.2.3.0.2.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.3.1.ll config -text ""
			.varibox.2.3.1.0.ll config -text ""
			.varibox.2.3.1.0.x config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			set vb(last_trmdep) $vb(trmdep)
			set vb(trmdep) ""
			.varibox.2.3.1.0.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.3.1.1.ll config -text ""
			.varibox.2.3.1.1.x config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			set vb(last_trmdeplo) $vb(trmdeplo)
			set vb(trmdeplo) ""
			.varibox.2.3.1.1.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.3.1.2.ll config -text ""
			.varibox.2.3.1.2.x config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			set vb(last_trmdephi) $vb(trmdephi)
			set vb(trmdephi) ""
			.varibox.2.3.1.2.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.3.2.ll  config -text ""
			.varibox.2.3.2.0.ll config -text ""
			catch {set vb(last_trmsqmin) $vb(trmsqmin)}
			set vb(trmsqmin) ""
			.varibox.2.3.2.0.e config  -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.3.2.1.ll config -text ""
			catch {set vb(last_trmsqmax) $vb(trmsqmax)}
			set vb(trmsqmax) ""
			.varibox.2.3.2.1.e config  -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.1.0.0.c.ll3 config -text "or"
			catch {set vb(tors) $vb(last_tors)}
			.varibox.1.0.0.c.tr3 config -text "8va TRANSPOSE" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.1.0.0.c.st3 config -text "STACK" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.1.0.0.c.x config -text "X" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			catch {set vb(nostak) $vb(last_nostak)}
			.varibox.1.0.0.4.ll config -text "   Max 8va-down transpose"
			.varibox.1.0.0.4.e config -bd 2 -state normal
			catch {set vb(stakmin) $vb(last_stakmin)}
			.varibox.1.0.0.5.ll config -text "   Max 8va-up transpose"
			.varibox.1.0.0.5.e config -bd 2 -state normal
			catch {set vb(stakmax) $vb(last_stakmax)}
			if {$vb(tors)} {
				.varibox.1.0.0.6.ll config -text "   Max Stack Lean"
				.varibox.1.0.0.6.e config -bd 2 -state normal
				catch {set vb(staklean) $vb(last_staklean)}
				.varibox.1.0.0.6.ps config -text "PreStack" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
				catch {set vb(prestak) $vb(last_prestak)}
			} else {
				catch {set set vb(last_staklean) $vb(staklean)}
				set vb(staklean) ""
				.varibox.1.0.0.6.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
				.varibox.1.0.0.6.ps config -text "" -state disabled -indicatoron 0 -bd 0 -bd 0 -selectcolor [option get . background {}]
			}
			if {[string first "Min" [.varibox.1.0.1.6.ll config -text]] >= 0} { 
				catch {set vb(last_preverbmin) $vb(preverbmin)}
				set vb(preverbmin) ""
				catch {set vb(last_preverbmax) $vb(preverbmax)}
				set vb(preverbmax) ""
			}
			if {$typ == $evv(VB_PULSED)} {
				.varibox.1.0.1.ll3 config -text "OVERLAP SUPPRESSION"
				.varibox.1.0.1.6.ll config -text "   Overlap Suppress (0-1)"
				.varibox.1.0.1.6.e config -bd 2 -state normal -textvariable vb(oversup)
				catch {set vb(oversup) $vb(last_oversup)}
			} else {
				.varibox.1.0.1.ll3 config -text ""
				.varibox.1.0.1.6.ll config -text ""
				if {[string first "Overlap" [.varibox.1.0.1.6.ll config -text]] >= 0} {
					catch {set vb(last_oversup) $vb(oversup)}
					set vb(oversup) ""
				}
				.varibox.1.0.1.6.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			}
			.varibox.1.0.1.7.ll config -text ""
			.varibox.1.0.1.7.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			bind .varibox.1.0.0.3.e <Control-Down> {focus .varibox.1.0.0.4.e}
			bind .varibox.1.0.0.4.e <Control-Down> {focus .varibox.1.0.0.5.e}
			if {$vb(tors)} {
				bind .varibox.1.0.0.5.e <Control-Down> {focus .varibox.1.0.0.6.e}
				bind .varibox.1.0.0.6.e <Control-Down> {focus .varibox.1.1.0.0.e}
				bind .varibox.1.1.0.0.e <Control-Up>   {focus .varibox.1.0.0.6.e}
			} else {
				bind .varibox.1.0.0.5.e <Control-Down> {focus .varibox.1.1.0.0.e}
				bind .varibox.1.1.0.0.e <Control-Up>   {focus .varibox.1.0.0.5.e}
			}
			bind .varibox.1.0.0.4.e <Control-Right> {focus .varibox.1.0.1.5.e}
			bind .varibox.1.0.1.5.e <Control-Left>  {focus .varibox.1.0.0.4.e}
			bind .varibox.1.0.0.5.e <Control-Right> {focus .varibox.1.0.1.5.e}
			bind .varibox.1.0.1.4.e <Control-Left> {focus .varibox.1.0.0.3.e}
			bind .varibox.1.1.0.2.e <Control-Down> {focus .varibox.2.2.0.0.e}
			bind .varibox.2.2.0.0.e <Control-Up>	 {focus .varibox.1.1.0.2.e}
			bind .varibox.1.1.0.2.e <Control-Right> {focus .varibox.1.1.1.1.e}
			bind .varibox.1.1.1.1.e <Control-Down> {focus .varibox.1.1.1.2.e}
			bind .varibox.2.2.1.0.e <Control-Up>   {focus .varibox.1.1.1.2.e}
			bind .varibox.2.4.0.0.e <Control-Up>	  {focus .varibox.1.1.0.2.e}
			bind .varibox.1.1.0.2.e <Control-Down>  {focus .varibox.2.4.0.0.e}
			bind .varibox.1.1.1.1.e <Control-Down>  {focus .varibox.2.4.0.0.e}
			if {$typ == $evv(VB_PULSED)} {
				bind .varibox.1.0.1.5.e <Control-Down>  {focus .varibox.1.0.1.6.e} 
				bind .varibox.1.0.1.6.e <Control-Up>    {focus .varibox.1.0.1.5.e} 
				if {$vb(tors)} {
					bind .varibox.1.0.1.6.e <Control-Left>  {focus .varibox.1.0.0.6.e} 
				} else {
					bind .varibox.1.0.1.6.e <Control-Left>  {focus .varibox.1.0.0.5.e} 
				}
				bind .varibox.1.0.0.6.e <Control-Right> {focus .varibox.1.0.1.6.e} 
				bind .varibox.1.1.1.0.e <Control-Up>    {focus .varibox.1.0.1.6.e} 
				bind .varibox.1.0.1.6.e <Control-Down>  {focus .varibox.1.1.1.0.e} 
			} else {
				bind .varibox.1.0.1.5.e <Control-Down>  {focus .varibox.1.1.1.0.e} 
				bind .varibox.1.1.1.0.e <Control-Up>    {focus .varibox.1.0.1.5.e} 
				bind .varibox.1.0.0.6.e <Control-Right> {focus .varibox.1.0.1.5.e} 
			}

			.varibox.2.4.ll.ll config -text "-------------- ENVELOPE FORMS ------------------------------------- POST-REVERB " -fg $evv(SPECIAL)
			.varibox.2.4.ll.x config -text "X" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			catch {set vb(norev) $vb(last_norev)}
			.varibox.2.4.2.0.ll config -text "Min short (80-250)"
			.varibox.2.4.2.0.e config -bd 2 -state normal
			.varibox.2.4.2.1.ll config -text "Max short (80-250)"
			.varibox.2.4.2.1.e config -bd 2 -state normal
			.varibox.2.4.2.2.ll config -text "Min long (250-1000)"
			.varibox.2.4.2.2.e config -bd 2 -state normal
			.varibox.2.4.2.3.ll config -text "Max long (250-1000)"
			.varibox.2.4.2.3.e config -bd 2 -state normal
			.varibox.2.4.2.4.ll config -text "N = 1/N dry outputs"
			.varibox.2.4.2.4.e config -bd 2 -state normal
			catch {set vb(minlorev) $vb(last_minlorev)}
			catch {set vb(maxlorev) $vb(last_maxlorev)}
			catch {set vb(minhirev) $vb(last_minhirev)}
			catch {set vb(maxhirev) $vb(last_maxhirev)}
			catch {set vb(dryrev) $vb(last_dryrev)}
			.varibox.2.4.0.0.ll config -text "Swell"
			.varibox.2.4.0.0.e  config -bd 2 -state normal
			catch {set vb(swellval) $vb(last_swellval)}
			.varibox.2.4.0.0.x  config -text "X"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.4.0.1.ll config -text "Soft"
			.varibox.2.4.0.1.e  config  -bd 2 -state normal
			catch {set vb(softval) $vb(last_softval)}
			.varibox.2.4.0.1.x  config -text "X"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.4.0.2.ll config -text "Strong"
			.varibox.2.4.0.2.e  config  -bd 2 -state normal
			catch {set vb(strongval) $vb(last_strongval)}
			.varibox.2.4.0.2.x  config -text "X"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.4.0.3.ll config -text "Attacked"
			.varibox.2.4.0.3.e  config -bd 2 -state normal 
			catch {set vb(atkval) $vb(last_atkval)}
			.varibox.2.4.0.3.x  config -text "X"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.4.1.rrr  config -text "Apply envelopes at random"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.4.1.all  config -text "Apply every env to every snd"  -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			catch {set vb(all) $vb(last_all)}
		} \
		^$evv(VB_ATKRES)$ {
			.varibox.1.1.ll     config -text ""
			.varibox.1.1.0.0.ll config -text ""
			if {[IsNumeric $vb(repdel)]} {
				catch {set vb(last_repdel) $vb(repdel)}
			}
			set vb(repdel) ""
			.varibox.1.1.0.0.e  config  -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.1.1.0.1.ll config -text ""
			if {[IsNumeric $vb(repdello)]} {
				catch {set vb(last_repdello) $vb(repdello)}
			}
			set vb(repdello) ""
			.varibox.1.1.0.1.e  config  -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.1.1.0.2.ll config -text ""
			if {[IsNumeric $vb(repdelhi)]} {
				catch {set vb(last_repdelhi) $vb(repdelhi)}
			}
			set vb(repdelhi) ""
			.varibox.1.1.0.2.e  config  -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.1.1.1.0.x  config -text ""  -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			.varibox.1.1.1.0.ll config -text ""
			if {[IsNumeric $vb(mindur)]} {
				catch {set vb(last_mindur) $vb(mindur)}
			}
			set vb(mindur) ""
			.varibox.1.1.1.0.e  config  -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.1.1.1.1.x  config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			.varibox.1.1.1.1.ll config -text ""
			if {[IsNumeric $vb(maxdur)]} {
				catch {set vb(last_maxdur) $vb(maxdur)}
			}
			set vb(maxdur) ""
			.varibox.1.1.1.1.e  config  -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.1.1.1.2.x  config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			.varibox.1.1.1.2.ll config -text ""
			if {[IsNumeric $vb(glisvalval)]} {
				catch {set vb(last_glisvalval) $vb(glisvalval)}
			}
			set vb(glisvalval) ""
			.varibox.1.1.1.2.e  config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.2.ll.ll  config -text "------------------------------ LONG SEGMENT VIBRATO "
			.varibox.2.2.ll.x   config -text "X" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.2.ll.ll2 config -text " -----------------------------------"
			.varibox.2.2.0.ll config -text "FREQ (Hz)"
			.varibox.2.2.0.0.ll config -text "   Fixed Frq"
			.varibox.2.2.0.0.x config -text "X-fix" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.2.0.0.e config -bd 2 -state normal
			catch {set vb(vibfrq) $vb(last_vibfrq)}
			.varibox.2.2.0.1.ll config -text "   Min Variable Frq"
			.varibox.2.2.0.1.x config -text "X-acc" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.2.0.1.e config -bd 2 -state normal
			catch {set vb(vibfrqlo) $vb(last_vibfrqlo)}
			.varibox.2.2.0.2.ll config -text "   Max Variable Frq"
			.varibox.2.2.0.2.x config -text "X-rit" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.2.0.2.e config -bd 2 -state normal
			catch {set vb(vibfrqhi) $vb(last_vibfrqhi)}
			.varibox.2.2.1.ll config -text "DEPTH (semitones)"
			.varibox.2.2.1.0.ll config -text "   Fixed depth"
			.varibox.2.2.1.0.x config -text "X-fix" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.2.1.0.e config -bd 2 -state normal
			catch {set vb(vibdep) $vb(last_vibdep)}
			.varibox.2.2.1.1.ll config -text "   Min Variable Depth"
			.varibox.2.2.1.1.x config -text "X-acc" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.2.1.1.e config -bd 2 -state normal
			catch {set vb(vibdeplo) $vb(last_vibdeplo)}
			.varibox.2.2.1.2.ll config -text "   Max Variable Depth"
			.varibox.2.2.1.2.x config -text "X-rit" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.2.1.2.e config -bd 2 -state normal
			catch {set vb(vibdephi) $vb(last_vibdephi)}
			.varibox.2.3.ll.ll  config -text "------------------------------ LONG SEGMENT TREMOLO "
			.varibox.2.3.ll.x   config -text "" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.3.ll.ll2 config -text " -----------------------------------"
			.varibox.2.3.0.ll config -text "FREQ (Hz)"
			.varibox.2.3.0.0.ll config -text "   Fixed Frq"
			.varibox.2.3.0.0.x config -text "X-fix" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.3.0.0.e config -bd 2 -state normal
			catch {set vb(trmfrq) $vb(last_trmfrq)}
			.varibox.2.3.0.1.ll config -text "   Min Variable Frq"
			.varibox.2.3.0.1.x config -text "X-acc" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.3.0.1.e config -bd 2 -state normal
			catch {set vb(trmfrqlo) $vb(last_trmfrqlo)}
			.varibox.2.3.0.2.ll config -text "   Max Variable Frq"
			.varibox.2.3.0.2.x config -text "X-rit" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.3.0.2.e config -bd 2 -state normal
			catch {set vb(trmfrqhi) $vb(last_trmfrqhi)}
			.varibox.2.3.1.ll config -text "DEPTH (0-1)"
			.varibox.2.3.1.0.ll config -text "   Fixed depth"
			.varibox.2.3.1.0.x config -text "X-fix" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.3.1.0.e config -bd 2 -state normal
			catch {set vb(trmdep) $vb(last_trmdep)}
			.varibox.2.3.1.1.ll config -text "   Min Variable Depth"
			.varibox.2.3.1.1.x config -text "X-acc" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.3.1.1.e config -bd 2 -state normal
			catch {set vb(trmdeplo) $vb(last_trmdeplo)}
			.varibox.2.3.1.2.ll config -text "   Max Variable Depth"
			.varibox.2.3.1.2.x config -text "X-rit" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			.varibox.2.3.1.2.e config -bd 2 -state normal
			catch {set vb(trmdephi) $vb(last_trmdephi)}
			.varibox.2.3.2.ll  config -text "NARROW (1-100)"
			.varibox.2.3.2.0.ll config -text "   Min"
			.varibox.2.3.2.0.e config -bd 2 -state normal
			catch {set vb(trmsqmin) $vb(last_trmsqmin)}
			.varibox.2.3.2.1.ll config -text "   Max"
			.varibox.2.3.2.1.e config -bd 2 -state normal
			catch {set vb(trmsqmax) $vb(last_trmsqmax)}
			.varibox.1.0.0.c.ll3 config -text ""
			set vb(tors) 1
			.varibox.1.0.0.c.tr3 config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}] 
			.varibox.1.0.0.c.st3 config -text "STACK" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
			catch {set vb(last_nostak) $vb(nostak)}
			set vb(nostak) 0
			.varibox.1.0.0.c.x config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			.varibox.1.0.0.4.ll config -text "   Max 8va-down transpose"
			.varibox.1.0.0.4.e config -bd 2 -state normal
			catch {set vb(stakmin) $vb(last_stakmin)}
			.varibox.1.0.0.5.ll config -text "   Max 8va-up transpose"
			.varibox.1.0.0.5.e config -bd 2 -state normal
			catch {set vb(stakmax) $vb(last_stakmax)}
			.varibox.1.0.0.6.ll config -text "   Max Stack Lean"
			.varibox.1.0.0.6.e config -bd 2 -state normal
			catch {set vb(staklean) $vb(last_staklean)}
			catch {set vb(last_prestak) $vb(prestak)}
			set vb(prestak) 0
			if {[string first "Overlap" [.varibox.1.0.1.6.ll config -text]] >= 0} {
				catch {set vb(last_oversup) $vb(oversup)}
			}
			.varibox.1.0.0.6.ps config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			.varibox.1.0.1.ll3 config -text "PRE-STAK REVERB (80-250)"
			.varibox.1.0.1.6.ll config -text "   Min Reverb"
			.varibox.1.0.1.6.e config -bd 2 -state normal -textvariable vb(preverbmin)
			catch {set vb(preverbmin) $vb(last_preverbmin)}
			.varibox.1.0.1.7.ll config -text "   Max Reverb"
			.varibox.1.0.1.7.e config -bd 2 -state normal -textvariable vb(preverbmax)
			catch {set vb(preverbmax) $vb(last_preverbmax)}

			bind .varibox.1.0.0.3.e <Control-Down> {focus .varibox.1.0.0.4.e}
			bind .varibox.1.0.0.4.e <Control-Down> {focus .varibox.1.0.0.5.e}
			bind .varibox.1.0.0.5.e <Control-Down> {focus .varibox.1.0.0.6.e}
			bind .varibox.1.0.0.6.e <Control-Down> {focus .varibox.1.1.0.0.e}
			bind .varibox.1.1.0.0.e <Control-Up>   {focus .varibox.1.0.0.6.e}
			bind .varibox.1.0.0.4.e <Control-Right> {focus .varibox.1.0.1.5.e}
			bind .varibox.1.0.1.5.e <Control-Left>  {focus .varibox.1.0.0.4.e}
			bind .varibox.1.0.0.5.e <Control-Right> {focus .varibox.1.0.1.5.e}
			bind .varibox.1.0.1.4.e <Control-Left> {focus .varibox.1.0.0.3.e}
			bind .varibox.1.1.0.2.e <Control-Down> {focus .varibox.2.2.0.0.e}
			bind .varibox.2.2.0.0.e <Control-Up>	 {focus .varibox.1.1.0.2.e}
			bind .varibox.1.1.0.2.e <Control-Right> {focus .varibox.1.1.1.1.e}
			bind .varibox.1.1.1.1.e <Control-Down> {focus .varibox.1.1.1.2.e}
			bind .varibox.2.2.1.0.e <Control-Up>   {focus .varibox.1.1.1.2.e}
			bind .varibox.1.1.0.2.e <Control-Down>  {focus .varibox.2.4.0.0.e}
			bind .varibox.1.1.1.1.e <Control-Down>  {focus .varibox.2.4.0.0.e}

			bind .varibox.1.0.1.5.e <Control-Down>  {focus .varibox.1.0.1.6.e} 
			bind .varibox.1.0.1.6.e <Control-Up>    {focus .varibox.1.0.1.5.e} 
			bind .varibox.1.0.1.6.e <Control-Down>  {focus .varibox.1.0.1.7.e} 
			bind .varibox.1.0.1.7.e <Control-Up>    {focus .varibox.1.0.1.6.e} 
			bind .varibox.1.0.1.7.e <Control-Down>  {focus .varibox.1.1.1.0.e} 
			bind .varibox.1.1.1.0.e <Control-Up>    {focus .varibox.1.0.1.7.e} 
			bind .varibox.1.0.1.6.e <Control-Left>  {focus .varibox.1.0.0.6.e} 
			bind .varibox.1.0.1.7.e <Control-Left>  {focus .varibox.1.0.0.6.e} 
			bind .varibox.1.0.0.6.e <Control-Right> {focus .varibox.1.0.1.6.e} 
			bind .varibox.1.01.e	  <Control-Up>    {focus .varibox.2.3.0.2.e }

			bind .varibox.2.2.0.0.e <Control-Up>   {focus .varibox.1.0.0.6.e}
			bind .varibox.1.0.0.6.e <Control-Down> {focus .varibox.2.2.0.0.e}
			bind .varibox.2.2.1.0.e <Control-Up>   {focus .varibox.1.0.1.7.e}
			bind .varibox.1.0.1.7.e <Control-Down> {focus .varibox.2.2.1.0.e}

			.varibox.2.4.ll.ll config -text ""
			catch {set vb(last_norev) $vb(norev)}
			set vb(norev) 1
			catch {set vb(last_minlorev) $vb(minlorev)}
			set vb(minlorev) ""
			catch {set vb(last_maxlorev) $vb(maxlorev)}
			set vb(maxlorev) ""
			catch {set vb(last_minhirev) $vb(minhirev)}
			set vb(minhirev) ""
			catch {set vb(last_maxhirev) $vb(maxhirev)}
			set vb(maxhirev) ""
			catch {set vb(last_dryrev) $vb(dryrev)}
			set vb(dryrev) ""
			.varibox.2.4.ll.x config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}]
			.varibox.2.4.2.0.ll config -text ""
			.varibox.2.4.2.0.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.4.2.1.ll config -text ""
			.varibox.2.4.2.1.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.4.2.2.ll config -text ""
			.varibox.2.4.2.2.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.4.2.3.ll config -text ""
			.varibox.2.4.2.3.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.4.2.4.ll config -text ""
			.varibox.2.4.2.4.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.4.0.0.ll config -text ""
			catch {set vb(last_swellval) $vb(swellval)}
			set vb(swellval) ""
			.varibox.2.4.0.0.e  config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.4.0.0.x  config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}] 
			.varibox.2.4.0.1.ll config -text ""
			catch {set vb(last_softval) $vb(softval)}
			set vb(softval) ""
			.varibox.2.4.0.1.e  config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.4.0.1.x  config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}] 
			.varibox.2.4.0.2.ll config -text ""
			catch {set vb(last_strongval) $vb(strongval)}
			set vb(strongval) ""
			.varibox.2.4.0.2.e  config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.4.0.2.x  config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}] 
			.varibox.2.4.0.3.ll config -text ""
			catch {set vb(last_atkval) $vb(atkval)}
			set vb(atkval) ""
			.varibox.2.4.0.3.e  config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.varibox.2.4.0.3.x  config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}] 
			catch {set vb(all) $vb(last_all)}
			.varibox.2.4.1.rrr  config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}] 
			.varibox.2.4.1.all  config -text "" -state disabled -indicatoron 0 -bd 0 -selectcolor [option get . background {}] 
	}
}

#---- Transposition data for stacks

proc CreateVariboxStaksList {} {
	global vb
	set vb(stakslist) {}
	if {($vb(stakmin) == 0) && ($vb(stakmax) == 0)} {
		return 1
	}
	if {$vb(tors)} {
		set range [expr $vb(stakmin) + $vb(stakmax)]

		set thisrange 1
		while {$thisrange <= $range} {
			set topstak $thisrange
			if {$topstak > $vb(stakmax)} {
				set topstak $vb(stakmax)
			}
			set botstak $thisrange
			if {$botstak > $vb(stakmin)} {
				set botstak $vb(stakmin)
			}
			if {$botstak != 0} {
				set botstak [expr -$botstak]
			}
			set thistakbas $botstak 
			while {$thistakbas <= 0} {
				if {[expr $thistakbas + $thisrange] > $vb(stakmax)} {
					break
				}
				set stakcnt 0
				set stakval $thistakbas
				catch {unset thistak}
				while {$stakcnt <= $thisrange} {
					lappend thistak $stakval
					incr stakval
					incr stakcnt
				}
				lappend vb(stakslist) $thistak
				incr thistakbas
			}
			incr thisrange
		}
	} else {		;#	TRANSPOSITIONS ONLY
		if {$vb(stakmin) != 0} {
			set botstak [expr -$vb(stakmin)]
		}
		while {$botstak <= $vb(stakmax)} {
			if {$botstak != 0} {
				lappend vb(stakslist) $botstak
			}
			incr botstak
		}
	}
	if {![info exists vb(stakslist)]} {
		return 0
	}
	return 1
}

#---- Produce 8va stacked versions of source short-sounds

proc MakeVariboxStakBrkfile {stak ofnam envtype unitlen} {
	global vb evv CDPidrun prg_dun prg_abortd simple_program_messages variboxmsgs

	if {!$vb(prestak)} {
		set instakmin [lindex $stak 0]
		set instakmax [lindex $stak end]
		if {$vb(typ) == $evv(VB_ATKRES)} {
			set maxoctdn [expr -$instakmin]
			set maxoctdn [expr int(round(pow(2,$maxoctdn)))]
			set vb(stakexpand) [expr $unitlen * $maxoctdn]
		} else {
			switch -- $envtype {
				"swell"  {
					if {$vb(stakmin) < 2} {	;#	Limit time-expansion of sloppy envels	
						if {$instakmin < -2} {
							return 0
						}
					}
				}
				"soft" {
					if {$vb(stakmin) < 2} {
						if {$instakmin < -2} {
							return 0
						}
					}
				}
				"hard" {
					if {$vb(stakmax) > 4} {	;#	Limit time-reduction of sharp envels
						if {$instakmax > 4} {
							return 0
						}
					}
				}
				"clip" {
					if {$vb(stakmax) > 4} {
						if {$instakmax > 4} {
							return 0
						}
					}
				}
			}
		}
		if {$vb(typ) == $evv(VB_PULSED)} {
			if {$instakmin == 0} {				
				set vb(unitlen) $unitlen
			} else {					;#	Find duration of iterated unit, after max transposition downwards
				set maxoctdn [expr -$instakmin]
				set maxoctdn [expr int(round(pow(2,$maxoctdn)))]
				set vb(unitlen) [expr $unitlen * $maxoctdn]
			}
		}
	}
	if [catch {open $ofnam "w"} zit] { 
		set line "Failed To Open File $ofnam To Write Stack Data"
		lappend variboxmsgs $line
		return 0
	}
	foreach val $stak {
		set val [expr $val * 12.0]
		puts $zit $val
	}
	close $zit
	return 1
}

#--- Stack the source (or the short segment of source)

proc DoVariboxStak {ifnam ofnam stakfile siz envtype stakcnt stak} {
	global vb evv CDPidrun prg_dun prg_abortd simple_program_messages variboxmsgs

	if {$vb(prestak)} {
		set vb(synctime) 0
		set instakmin [lindex $stak 0]
		if {$instakmin < 0.0} {
			set maxoctdn [expr -$instakmin]
			set maxoctdn [expr int(round(pow(2,$maxoctdn)))]
			set sndtomake [expr 1.0/double($maxoctdn)]
		} else {
			set sndtomake 1
		}
	} else {
		set sndtomake 1
		set vb(synctime) [GetVariboxSynctime $envtype]
	}
	set lean [expr (rand() * 2.0) - 1.0]
	set lean [expr $lean * $vb(staklean)]
	if {$lean < 0} {
		set lean [expr 1.0/(-$lean)]
	}
	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	catch {unset simple_program_messages}
	set cmd	[file join $evv(CDPROGRAM_DIR) modify]
	lappend cmd stack $ifnam $ofnam $stakfile $siz $lean $vb(synctime) 1 $sndtomake -n
	if [catch {open "|$cmd"} CDPidrun] {
		if {$vb(prestak)} {
			set msg "Cannot Create Stack $stakcnt On Input Sound: $CDPidrun"
		} else {
			set msg "Cannot Create Stack $stakcnt On $envtype Element: $CDPidrun"
		}
		lappend variboxmsgs $msg
		catch {unset CDPidrun}
		return 0
	} else {
		fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
	}
	vwait prg_dun
	if {$prg_abortd} {
		set prg_dun 0
	}
	if {!$prg_dun} {
		if {$vb(prestak)} {
			set msg "Failed To Create Stack $stakcnt On Input Sound"
		} else {
			set msg "Failed To Create Stack $stakcnt On $envtype Element"
		}
		set msg [AddSimpleMessages $msg]
		lappend variboxmsgs $msg
		return 0
	}
	if {![file exists $ofnam]} {
		if {$vb(prestak)} {
			set msg "Creating Stack $stakcnt On Input Sound Failed"
		} else {
			set msg "Creating Stack $stakcnt On $envtype Element Failed"
		}
		set msg [AddSimpleMessages $msg]
		lappend variboxmsgs $msg
		return 0
	}
	return 1
}

#--- Get synchronisation time from envelope max of input sound

proc GetVariboxSynctime {envtype} {
	global vb
	switch -- $envtype {
		"swell"  {
			set synctime $vb(shswelup)
		}
		"soft" {
			set synctime $vb(shsoftup)
		}
		"hard" {
			set synctime $vb(shhardup)
		}
		"clip" {
			set synctime $vb(shclipup)
		}
	}
	return $synctime
}
		
#--- Transpose the source

proc DoVariboxTranspose {ifnam ofnam stakcnt val} {
	global vb evv CDPidrun prg_dun prg_abortd simple_program_messages variboxmsgs

	set val [expr $val * 12.0]
	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	catch {unset simple_program_messages}
	set cmd	[file join $evv(CDPROGRAM_DIR) modify]
	lappend cmd speed 2 $ifnam $ofnam $val
	if [catch {open "|$cmd"} CDPidrun] {
		set msg "Cannot Do Transposition $stakcnt Of Input Sound: $Cdpidrun"
		lappend variboxmsgs $msg
		catch {unset CDPidrun}
		return 0
	} else {
		fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
	}
	vwait prg_dun
	if {$prg_abortd} {
		set prg_dun 0
	}
	if {!$prg_dun} {
		set msg "Failed To Do Transposition $stakcnt On Input Sound"
		set msg [AddSimpleMessages $msg]
		lappend variboxmsgs $msg
		return 0
	}
	if {![file exists $ofnam]} {
		set msg "Transposition $stakcnt On Input Sound Failed"
		set msg [AddSimpleMessages $msg]
		lappend variboxmsgs $msg
		return 0
	}
	return 1
}

#--- Add reverb to varibox outputs.

proc DoVariboxReverb {ifnam ofnam incnt tomono} {
	global vb evv CDPidrun prg_dun prg_abortd simple_program_messages variboxmsgs

	if {$vb(typ) == $evv(VB_ATKRES)} {
		set range [expr $vb(preverbmax) - $vb(preverbmin)]
		set val [expr int(round(rand() * $range))]
		set val [expr $vb(preverbmin) + $val]
	} else {
		if {$vb(dryrev) == 0} {
			set vb(rtyp) [expr int(floor(rand() * 2.0)) + 1]			;#	Value 1 or 2
		} else {
			set vb(rtyp) [expr int(floor(rand() * $vb(dryrev)))]		;#	Value 0,1,2,3,4....
		}
		if {$vb(rtyp) == 0} {											;#	Value 0, Dry
			return [DoVariboxReverbDry $ifnam $ofnam $incnt]
		} elseif {$vb(rtyp) <= $vb(halfdry)} {							
			set range [expr $vb(maxlorev) - $vb(minlorev)]
			set val [expr int(round(rand() * $range))]
			set val [expr $vb(minlorev) + $val]
		} else {
			set range [expr $vb(maxhirev) - $vb(minhirev)]
			set val [expr int(round(rand() * $range))]
			set val [expr $vb(minhirev) + $val]
		}
	}
	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	catch {unset simple_program_messages}
	set cmd	[file join $evv(CDPROGRAM_DIR) modify]
	lappend cmd revecho 3 $ifnam $ofnam -g1 -r1 -s0.1 -e$val -n
	if [catch {open "|$cmd"} CDPidrun] {
		set msg "Cannot Reverb Input Sound $incnt: $CDPidrun"
		lappend variboxmsgs $msg
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
		set msg "Failed To Reverb Insnd $incnt"
		set msg [AddSimpleMessages $msg]
		lappend variboxmsgs $msg
		return ""
	}
	if {![file exists $ofnam]} {
		set msg "Reverb Of Insnd $incnt Failed"
		set msg [AddSimpleMessages $msg]
		lappend variboxmsgs $msg
		return ""
	}
	if {$tomono} {
		set mnam [file rootname $ofnam]
		append mnam 0 $evv(SNDFILE_EXT)
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		set cmd	[file join $evv(CDPROGRAM_DIR) housekeep]
		lappend cmd chans 4 $ofnam $mnam
		if [catch {open "|$cmd"} CDPidrun] {
			set msg "Cannot Convert Reverbd Sound $incnt To Mono: $CDPidrun"
			lappend variboxmsgs $msg
			catch {unset CDPidrun}
			return $ofnam
		} else {
			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			set msg "Failed To Convert Reverbd Sound $incnt To Mono"
			set msg [AddSimpleMessages $msg]
			lappend variboxmsgs $msg
			return $ofnam
		}
		if {![file exists $mnam]} {
			set msg "Conversion To Mono Of Reverbd Sound $incnt Failed"
			set msg [AddSimpleMessages $msg]
			lappend variboxmsgs $msg
			return $ofnam
		}
		set ofnam $mnam
	}
	return $ofnam
}

#--- Find duration of am atk-res stak, before doing Vib or Trem (so brkpntfiles can be made)

proc VariboxGetSrcDur {ifnam incnt} {
	global vb evv CDPid variboxmsgs parse_error props_got propslist

	catch {unset propslist}
	set parse_error 0
	set props_got 0
	set cmd [file join $evv(CDPROGRAM_DIR) cdparse]
	lappend cmd $ifnam 0
	if [catch {open "|$cmd"} CDPid] {
		set msg "Finding Duration Of File $incnt Failed"
		lappend variboxmsgs $msg
		catch {unset CDPid}
		return 0
	} else {
		set propslist ""
		fileevent $CDPid readable VariboxAccumulateFileProps
	}
	vwait props_got
	if {$parse_error} {
		set msg "Finding Duration Of File $incnt Failed"
		lappend variboxmsgs $msg
		return 0
	}
	if {![info exists propslist] || ([llength $propslist] == 0)} {
		set msg "Failed To Get Properties Of File $incnt"
		lappend variboxmsgs $msg
		return 0
	}
	if {[llength $propslist] != ($evv(CDP_PROPS_CNT) + $evv(CDP_MAXSAMP_CNT))} {
		set msg "Wrong Number Of Props ([llength $propslist]) Returned For File $incnt"
		lappend variboxmsgs $msg
		return 0
	}
	set vb(atkreslen) [lindex $propslist $evv(DUR)]
	return 1
}

proc VariboxAccumulateFileProps {} {
	global CDPid parse_error propslist props_got
	if [eof $CDPid] {						
		catch {close $CDPid}
		set props_got 1
		return
	} else {
		gets $CDPid str
		set str [string trim $str]
		if {[llength $str] <= 0} {
			return
		}
		if [string match ERROR:* $str] {
			set parse_error 1
			catch {close $CDPid}				 
			set props_got 1
			return
		} elseif [string match INFO:* $str] {
			catch {close $CDPid}				 
			set props_got 1
			return
		} elseif [string match END* $str] {
			catch {close $CDPid}
			set props_got 1
			return
		} else {
			append propslist $str
			return
		}
	}
}

#--- Convert input to a stereofied mono, so it is compatible with stereo-reverbd outputs

proc DoVariboxReverbDry {ifnam ofnam incnt} {
	global vb evv CDPidrun prg_dun prg_abortd simple_program_messages variboxmsgs

	if {$vb(chans) > 1} {
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		set mfnam [file rootname $ofnam]
		append mfnam 0000 $evv(SNDFILE_EXT)
		catch {unset simple_program_messages}
		set cmd	[file join $evv(CDPROGRAM_DIR) housekeep]
		lappend cmd chans 4 $ifnam $mfnam
		if [catch {open "|$cmd"} CDPidrun] {
			set msg "Cannot Convert Input Sound $incnt To Mono: $CDPidrun"
			lappend variboxmsgs $msg
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
			set msg "Failed To Convert Input Sound $incnt To Mono"
			set msg [AddSimpleMessages $msg]
			lappend variboxmsgs $msg
			return ""
		}
		if {![file exists $ofnam]} {
			set msg "Conversion Input Sound $incnt To Mono Failed"
			set msg [AddSimpleMessages $msg]
			lappend variboxmsgs $msg
			return ""
		}
		set ifnam $mfnam
	}
	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	set mfnam [file rootname $ofnam]
	append mfnam 0000 $evv(SNDFILE_EXT)
	catch {unset simple_program_messages}
	set cmd	[file join $evv(CDPROGRAM_DIR) housekeep]
	lappend cmd chans 5 $ifnam $ofnam
	if [catch {open "|$cmd"} CDPidrun] {
		set msg "Cannot Convert Input Sound $incnt To Stereo: $CDPidrun"
		lappend variboxmsgs $msg
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
		set msg "Failed To Convert Input Sound $incnt To Stereo"
		set msg [AddSimpleMessages $msg]
		lappend variboxmsgs $msg
		return ""
	}
	if {![file exists $ofnam]} {
		set msg "Conversion Input Sound $incnt To Stereo Failed"
		set msg [AddSimpleMessages $msg]
		lappend variboxmsgs $msg
		return ""
	}
	return $ofnam
}

#--- Clear all parameters in Varibox  window

proc ClearVariboxParams {} {
	global vb pa evv
	if {$vb(typ) < 0} {
		Inf "NO VARIBOX TYPE SET: ASSUMING GENERAL TYPE"
		set vb(typ) 0
	}
	catch {set vb(last_shswelup)	$vb(shswelup)}
	set vb(shswelup) ""
	catch {set vb(last_noshswell)	$vb(noshswell)}
	catch {set vb(last_shswelup)	$vb(shswelup)}
	set vb(shswelup) ""
	catch {set vb(last_shsweldn)	$vb(shsweldn)}
	set vb(shsweldn) ""
	catch {set vb(last_noshsoft)	$vb(noshsoft)}
	catch {set vb(last_shsoftup)	$vb(shsoftup)}
	set vb(shsoftup) ""
	catch {set vb(last_shsoftdn)	$vb(shsoftdn)}
	set vb(shsoftdn) ""
	catch {set vb(last_tors)		$vb(tors)}
	set vb(tors) 0
	catch {set vb(last_nostak)		$vb(nostak)}
	catch {set vb(last_stakmin)		$vb(stakmin)}
	set vb(stakmin) ""
	catch {set vb(last_stakmax)		$vb(stakmax)}
	set vb(stakmax) ""
	catch {set vb(last_staklean)	$vb(staklean)}
	set vb(staklean) ""
	catch {set vb(last_prestak)		$vb(prestak)}
	set vb(prestak) ""
	catch {set vb(last_noshhard)	$vb(noshhard)}
	catch {set vb(last_shhardup)	$vb(shhardup)}
	set vb(shhardup) ""
	catch {set vb(last_shharddn)	$vb(shharddn)}
	set vb(shharddn) ""
	catch {set vb(last_noshclip)	$vb(noshclip)}
	catch {set vb(last_shclipup)	$vb(shclipup)}
	set vb(shclipup) ""
	catch {set vb(last_shclipdn)	$vb(shclipdn)}
	set vb(shclipdn) ""
	catch {set vb(last_shclipstt)	$vb(shclipstt)}
	set vb(shclipstt) ""
	catch {set vb(last_shclipend)	$vb(shclipend)}
	set vb(shclipend) ""
	catch {set vb(last_oversup)		$vb(oversup)}
	set vb(oversup) ""
	catch {set vb(last_preverbmin)	$vb(preverbmin)}
	set vb(preverbmin) ""
	catch {set vb(last_preverbmax)	$vb(preverbmax)}
	set vb(preverbmax) ""
	catch {set vb(last_repdel)		$vb(repdel)}
	set vb(repdel) ""
	catch {set vb(last_repdello)	$vb(repdello)}
	set vb(repdello) ""
	catch {set vb(last_repdelhi)	$vb(repdelhi)}
	set vb(repdelhi) ""
	catch {set vb(last_nofixd)		$vb(nofixd)}
	catch {set vb(last_mindur)		$vb(mindur)}
	set vb(mindur) ""
	catch {set vb(last_noacc)		$vb(noacc)}
	catch {set vb(last_maxdur)		$vb(maxdur)}
	set vb(maxdur) ""
	catch {set vb(last_norit)		$vb(norit)}
	catch {set vb(last_glisvalval)	$vb(glisvalval)}
	set vb(glisvalval) ""
	catch {set vb(last_novib)		$vb(novib)}
	catch {set vb(last_novffixd)	$vb(novffixd)}
	catch {set vb(last_vibfrq)		$vb(vibfrq)}
	set vb(vibfrq) ""
	catch {set vb(last_novfacc)		$vb(novfacc)}
	catch {set vb(last_vibfrqlo)	$vb(vibfrqlo)}
	set vb(vibfrqlo) ""
	catch {set vb(last_novfrit)		$vb(novfrit)}
	catch {set vb(last_vibfrqhi)	$vb(vibfrqhi)}
	set vb(vibfrqhi) ""
	catch {set vb(last_novdfixd)	$vb(novdfixd)}
	catch {set vb(last_vibdep)		$vb(vibdep)}
	set vb(vibdep) ""
	catch {set vb(last_novdacc)		$vb(novdacc)}
	catch {set vb(last_vibdeplo)	$vb(vibdeplo)}
	set vb(vibdeplo) ""
	catch {set vb(last_novdrit)		$vb(novdrit)}
	catch {set vb(last_vibdephi)	$vb(vibdephi)}
	set vb(vibdephi) ""
	catch {set vb(last_notrm)		$vb(notrm)}
	catch {set vb(last_notffixd)	$vb(notffixd)}
	catch {set vb(last_trmfrq)		$vb(trmfrq)}
	set vb(trmfrq) ""
	catch {set vb(last_notfacc)		$vb(notfacc)}
	catch {set vb(last_trmfrqlo)	$vb(trmfrqlo)}
	set vb(trmfrqlo) ""
	catch {set vb(last_trmfrqlo)	$vb(trmfrqlo)}
	set vb(trmfrqlo) ""
	catch {set vb(last_trmfrqhi)	$vb(trmfrqhi)}
	set vb(trmfrqhi) ""
	catch {set vb(last_notdfixd)	$vb(notdfixd)}
	catch {set vb(last_trmdep)		$vb(trmdep)}
	set vb(trmdep) ""
	catch {set vb(last_notdacc)		$vb(notdacc)}
	catch {set vb(last_trmdeplo)	$vb(trmdeplo)}
	set vb(trmdeplo) ""
	catch {set vb(last_notdrit)		$vb(notdrit)}
	catch {set vb(last_trmdephi)	$vb(trmdephi)}
	set vb(trmdephi) ""
	catch {set vb(last_trmsqmin)	$vb(trmsqmin)}
	set vb(trmsqmin) ""
	catch {set vb(last_trmsqmax)	$vb(trmsqmax)}
	set vb(trmsqmax) ""
	catch {set vb(last_norev)		$vb(norev)}
	catch {set vb(last_swellval)	$vb(swellval)}
	set vb(swellval) ""
	catch {set vb(last_noeswell)	$vb(noeswell)}
	catch {set vb(last_softval)		$vb(softval)}
	set vb(softval) ""
	catch {set vb(last_noesoft)		$vb(noesoft)}
	catch {set vb(last_strongval)	$vb(strongval)}
	set vb(strongval) ""
	catch {set vb(last_noestrong)	$vb(noestrong)}
	catch {set vb(last_atkval)		$vb(atkval)}
	set vb(atkval) ""
	catch {set vb(last_noeatk)		$vb(noeatk)}
	catch {set vb(last_noeatk)		$vb(noeatk)}
	catch {set vb(last_minlorev)	$vb(minlorev)}
	set vb(minlorev) ""
	catch {set vb(last_maxlorev)	$vb(maxlorev)}
	set vb(maxlorev) ""
	catch {set vb(last_minhirev)	$vb(minhirev)}
	set vb(minhirev) ""
	catch {set vb(last_maxhirev)	$vb(maxhirev)}
	set vb(maxhirev) ""
	catch {set vb(last_dryrev)		$vb(dryrev)}
	set vb(dryrev) ""
	catch {set vb(last_all)			$vb(all)}
	set vb(all) 1
}

#---- Save named patch from current Varibox settings

proc SaveVariboxParams {} {
	global vb evv wstk pr_vbsave vbsavenam
	if {$vb(typ) < 0} {
		Inf "NO VARIBOX TYPE SET"
		return
	}
	set list1  [list $vb(typ) $vb(noshswell) $vb(shswelup) $vb(shsweldn) $vb(noshsoft) $vb(shsoftup) $vb(shsoftdn)]
	set list2  [list $vb(tors) $vb(nostak) $vb(stakmin) $vb(stakmax) $vb(staklean)]
	set list3  [list $vb(prestak) $vb(noshhard) $vb(shhardup) $vb(shharddn) $vb(noshclip) $vb(shclipup) $vb(shclipdn) $vb(shclipstt) $vb(shclipend)]
	set list4  [list $vb(oversup) $vb(preverbmin) $vb(preverbmax) $vb(repdel) $vb(repdello) $vb(repdelhi)]
	set list5  [list $vb(nofixd) $vb(mindur) $vb(noacc) $vb(maxdur) $vb(norit) $vb(glisvalval)]
	set list6  [list $vb(novib) $vb(novffixd) $vb(vibfrq) $vb(novfacc)]
	set list7  [list $vb(vibfrqlo) $vb(novfrit) $vb(vibfrqhi) $vb(novdfixd) $vb(vibdep) $vb(novdacc) $vb(vibdeplo) $vb(novdrit) $vb(vibdephi)]
	set list8  [list $vb(notrm) $vb(notffixd) $vb(trmfrq) $vb(notfacc)]
	set list9  [list $vb(trmfrqlo) $vb(trmfrqlo) $vb(trmfrqhi) $vb(notdfixd) $vb(trmdep) $vb(notdacc) $vb(trmdeplo) $vb(notdrit) $vb(trmdephi)]
	set list10 [list $vb(trmsqmin) $vb(trmsqmax)]
	set list11 [list $vb(norev) $vb(swellval) $vb(noeswell) $vb(softval) $vb(noesoft) $vb(strongval) $vb(noestrong) $vb(atkval) $vb(noeatk)]
	set list12 [list $vb(noeatk) $vb(all) $vb(minlorev) $vb(maxlorev) $vb(minhirev) $vb(maxhirev) $vb(dryrev)]
	set vpatch [concat $list1 $list2 $list3 $list4 $list5 $list6 $list7 $list8 $list9 $list10 $list11 $list12]

	set f .vbsave
	if [Dlg_Create $f "SAVE VARIBOX PATCH" "set pr_vbsave 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0] 
		set f1 [frame $f.1] 
		set f2 [frame $f.2] 
		button $f0.ok -text "Save" -command "set pr_vbsave 1" -bg $evv(EMPH)  -highlightbackground [option get . background {}]
		button $f0.quit -text "Abandon" -command "set pr_vbsave 0"  -highlightbackground [option get . background {}]
		pack $f0.ok -side left
		pack $f0.quit -side right
		pack $f0 -side top -fill x -expand true
		label $f2.ll -text "Patch Name "
		entry $f2.nam -textvariable vbsavenam -width 16
		pack $f2.ll $f2.nam -side left -pady 2
		pack $f2 -side top
		label $f1.tit -text "Existing Patches" -fg $evv(SPECIAL)
		Scrolled_Listbox $f1.ll -width 60 -height 20 -selectmode single
		pack $f1.tit $f1.ll -side top -fill x -expand true -pady 2
		pack $f1 -side top -fill x -expand true
		bind $f <Escape> {set pr_vbsave 0}
		bind $f <Return> {set pr_vbsave 1}
		wm resizable $f 0 0
	}
	$f.1.ll.list delete 0 end
	if {[info exists vb(patchnames)]} {
		foreach patchname $vb(patchnames) {
			$f.1.ll.list insert end $patchname
		}
	}
	set pr_vbsave 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_vbsave $f.2.nam
	while {!$finished} {
		tkwait variable pr_vbsave
		if {$pr_vbsave} {
			if {[string length $vbsavenam] <= 0} {
				Inf "No Patch Name Entered"
				continue
			}
			set patchname [string tolower $vbsavenam] 
			if {![ValidCDPRootname $patchname]} {
				continue
			}
			if {[info exists vb(patches)]} {
				set OK 1
				set nn 0 
				foreach nam $vb(patchnames) {
					if {[string match $nam $vbsavenam]} {
						set msg "A Patch With This Name Already Exists: Overwrite It ??"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							set OK 0
						} else {
							set vpatch [concat $vbsavenam $vpatch]
							set vb(patches) [lreplace $vb(patches) $nn $nn $vpatch]
							set OK 2
						}
						break
					}
					incr nn
				}
				if {!$OK} {
					continue
				} elseif {$OK == 1} {
					set vpatch [concat $vbsavenam $vpatch]
					lappend vb(patches) $vpatch
					lappend vb(patchnames) $vbsavenam
				}
			} else {
				set vpatch [concat $vbsavenam $vpatch]
				lappend vb(patches) $vpatch
				lappend vb(patchnames) $vbsavenam
			}
			set patchfile [file join $evv(URES_DIR) vbox$evv(CDP_EXT)]
			if [catch {open $patchfile "w"} zit] {
				Inf "CANNOT OPEN FILE $patchfile TO WRITE NEW PATCH"
				continue
			}
			foreach patch $vb(patches) {
				puts $zit $patch
			}
			close $zit
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- Get an existing patch for Varibox

proc GetVariboxParams {} {
	global vb evv wstk pr_vbload readonlybg readonlyfg
	if {![info exists vb(patchnames)]} {
		Inf "There Are No Varibox Patches"
		return
	}
	set patchfile [file join $evv(URES_DIR) vbox$evv(CDP_EXT)]

	set f .vbload
	if [Dlg_Create $f "GET VARIBOX PATCH" "set pr_vbload 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0] 
		set f1 [frame $f.1] 
		set f2 [frame $f.2] 
		button $f0.ok -text "Load" -command "set pr_vbload 1" -bg $evv(EMPH)  -highlightbackground [option get . background {}]
		button $f0.del -text "Delete" -command "set pr_vbload 2"  -highlightbackground [option get . background {}]
		button $f0.quit -text "Abandon" -command "set pr_vbload 0"  -highlightbackground [option get . background {}]
		pack $f0.ok $f0.del -side left -pady 6
		pack $f0.quit -side right
		pack $f0 -side top -fill x -expand true
		label $f2.ll -text "Patch Name "
		entry $f2.nam -textvariable vb(getpnam) -width 16 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $f2.ll $f2.nam -side left -pady 2
		pack $f2 -side top
		label $f1.tit -text "Click on Patchname (below)" -fg $evv(SPECIAL)
		Scrolled_Listbox $f1.ll -width 60 -height 20 -selectmode single
		pack $f1.tit $f1.ll -side top -fill x -expand true -pady 2
		pack $f1 -side top -fill x -expand true
		bind $f1.ll.list <ButtonRelease-1> {VbPatchGetSelect %y}
		bind $f <Escape> {set pr_vbload 0}
		bind $f <Return> {set pr_vbload 1}
		wm resizable $f 0 0
	}
	set vb(getpnam) ""
	$f.1.ll.list delete 0 end
	foreach patchname $vb(patchnames) {
		$f.1.ll.list insert end $patchname
	}
	set pr_vbload 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_vbload $f.2.nam
	while {!$finished} {
		tkwait variable pr_vbload
		switch -- $pr_vbload {
			1 {
				if {[string length $vb(getpnam)] <= 0} {
					Inf "No Patch Name Selected"
					continue
				}
				set vpatch [lindex $vb(patches) $vb(loadpno)]
				set n 0
				foreach val $vpatch {
					switch -- $n {
						0	{}
						1	{ 
							set vb(typ) $val
							VaribankTypeConfigure $vb(typ)
						}
						2	{ set vb(noshswell)  $val}
						3	{ set vb(shswelup)   $val}
						4	{ set vb(shsweldn)   $val}
						5	{ set vb(noshsoft)   $val}
						6	{ set vb(shsoftup)   $val}
						7	{ set vb(shsoftdn)   $val}
						8	{ set vb(tors)	     $val}
						9	{ set vb(nostak)	 $val}
						10	{ set vb(stakmin)	 $val}
						11	{ set vb(stakmax)	 $val}
						12	{ set vb(staklean)	 $val}
						13	{ set vb(prestak)	 $val}
						14	{ set vb(noshhard)	 $val}
						15	{ set vb(shhardup)	 $val}
						16	{ set vb(shharddn)	 $val}
						17	{ set vb(noshclip)	 $val}
						18	{ set vb(shclipup)	 $val}
						19	{ set vb(shclipdn)	 $val}
						20	{ set vb(shclipstt)  $val}
						21	{ set vb(shclipend)  $val}
						22	{ set vb(oversup)	 $val}
						23	{ set vb(preverbmin) $val}
						24	{ set vb(preverbmax) $val}
						25	{ set vb(repdel)	 $val}
						26	{ set vb(repdello)	 $val}
						27	{ set vb(repdelhi)	 $val}
						28	{ set vb(nofixd)	 $val}
						29	{ set vb(mindur)	 $val}
						30	{ set vb(noacc)		 $val}
						31	{ set vb(maxdur)	 $val}
						32	{ set vb(norit)		 $val}
						33	{ set vb(glisvalval) $val}
						34	{ set vb(novib)		 $val}
						35	{ set vb(novffixd)	 $val}
						36	{ set vb(vibfrq)	 $val}
						37	{ set vb(novfacc)	 $val}
						38	{ set vb(vibfrqlo)	 $val}
						39	{ set vb(novfrit)	 $val}
						40	{ set vb(vibfrqhi)	 $val}
						41	{ set vb(novdfixd)	 $val}
						42	{ set vb(vibdep)	 $val}
						43	{ set vb(novdacc)	 $val}
						44	{ set vb(vibdeplo)	 $val}
						45	{ set vb(novdrit)	 $val}
						46	{ set vb(vibdephi)	 $val}
						47	{ set vb(notrm)		 $val}
						48	{ set vb(notffixd)	 $val}
						49	{ set vb(trmfrq)	 $val}
						50	{ set vb(notfacc)	 $val}
						51	{ set vb(trmfrqlo)	 $val}
						52	{ set vb(trmfrqlo)	 $val}
						53	{ set vb(trmfrqhi)	 $val}
						54	{ set vb(notdfixd)	 $val}
						55	{ set vb(trmdep)	 $val}
						56	{ set vb(notdacc)	 $val}
						57	{ set vb(trmdeplo)	 $val}
						58	{ set vb(notdrit)	 $val}
						59	{ set vb(trmdephi)	 $val}
						60	{ set vb(trmsqmin)	 $val}
						61	{ set vb(trmsqmax)	 $val}
						62	{ set vb(norev)		 $val}
						63	{ set vb(swellval)	 $val}
						64	{ set vb(noeswell)	 $val}
						65	{ set vb(softval)	 $val}
						66	{ set vb(noesoft)	 $val}
						67	{ set vb(strongval)  $val}
						68	{ set vb(noestrong)  $val}
						69	{ set vb(atkval)	 $val}
						70	{ set vb(noeatk)	 $val}
						71	{ set vb(noeatk)	 $val}
						72	{ set vb(all)		 $val}
						73	{ set vb(minlorev)	 $val}
						74	{ set vb(maxlorev)	 $val}
						75	{ set vb(minhirev)	 $val}
						76	{ set vb(maxhirev)	 $val}
						77	{ set vb(dryrev)	 $val}
					}
					incr n
				}
				set finished 1
			}
			2 {
				if {[string length $vb(getpnam)] <= 0} {
					Inf "No Patch Name Selected"
					continue
				}
				set msg "Are You Sure You Want To Delete Patch $vb(getpnam) ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				set vb(patches)    [lreplace $vb(patches) $vb(loadpno) $vb(loadpno)]
				set vb(patchnames) [lreplace $vb(patchnames) $vb(loadpno) $vb(loadpno)]
				$f.1.ll.list delete $vb(loadpno)
				if {[llength $vbpatches] <= 0} {
					unset vb(patches)
					unset vb(patchnames)
					if {[file exists $patchfile]} {
						catch {file delete $patchfile}
					}
					set finished 1
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

proc VbPatchGetSelect {y} {
	global vb
	set i [.vbload.1.ll.list nearest $y]
	if {$i < 0} {
		return
	}
	set vb(getpnam) [.vbload.1.ll.list get $i]
	set vb(loadpno) $i
}

#---- Save named patch from current Varibox settings

proc LoadVariboxPatches {} {
	global vb evv wstk pr_vbsave vbsavenam

	set patchfile [file join $evv(URES_DIR) vbox$evv(CDP_EXT)]
	if {![file exists $patchfile]} {
		return
	}
	if [catch {open $patchfile "r"} zit] {
		Inf "Cannot Open File $patchfile To Read Existing Varibox Patches"
		return
	}
	set patchcnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		catch {unset thispatch}
		set itemcnt 0
		set line [split $line]
		foreach item $line {
			set item [string trim $item]
			switch -- $itemcnt {
				0	{ 
					lappend vb(patchnames) $item
					lappend thispatch $item
				}
				default	{ 
					lappend thispatch $item
				}
			}
			incr itemcnt
		}
		if {$itemcnt != 78} {
			set	vb(patchnames) [lreplace $vb(patchnames) $patchcnt $patchcnt]	
		} else {
			lappend vb(patches) $thispatch
			incr patchcnt
		}
	}
	close $zit
}

#--- Prevents EVERY option being excluded, amongst a set of options

proc VBX {nam typ} {
	global vb
	switch -- $nam {
		"short" {
			if {[expr $vb(noshhard) + $vb(noshclip) + $vb(noshsoft) + $vb(noshswell)] == 4} {
				switch -- $typ {
					"swell" { set vb(noshswell) 0 }
					"soft"  { set vb(noshsoft) 0 }
					"hard"  { set vb(noshhard) 0  }
					"clip"  { set vb(noshclip) 0  }
				}		
			}
		}
		"repeat" {
			if {[expr $vb(nofixd) + $vb(noacc) + $vb(norit)] == 3} {
				switch -- $typ {
					"fix" { set vb(nofixd) 0 }
					"acc" { set vb(noacc) 0  }
					"rit" { set vb(norit) 0  }
				}		
			}
		}
		"vibfrq" {
			if {[expr $vb(novffixd) + $vb(novfacc) + $vb(novfrit)] == 3} {
				switch -- $typ {
					"fix" { set vb(novffixd) 0 }
					"acc" { set vb(novfacc) 0  }
					"rit" { set vb(novfrit) 0  }
				}		
			}
		}
		"vibdep" {
			if {[expr $vb(novdfixd) + $vb(novdacc) + $vb(novdrit)] == 3} {
				switch -- $typ {
					"fix" { set vb(novdfixd) 0 }
					"acc" { set vb(novdacc) 0  }
					"rit" { set vb(novdrit) 0  }
				}		
			}
		}
		"trmfrq" {
			if {[expr $vb(notffixd) + $vb(notfacc) + $vb(notfrit)] == 3} {
				switch -- $typ {
					"fix" { set vb(notffixd) 0 }
					"acc" { set vb(notfacc) 0  }
					"rit" { set vb(notfrit) 0  }
				}		
			}
		}
		"trmdep" {
			if {[expr $vb(notdfixd) + $vb(notdacc) + $vb(notdrit)] == 3} {
				switch -- $typ {
					"fix" { set vb(notdfixd) 0 }
					"acc" { set vb(notdacc) 0  }
					"rit" { set vb(notdrit) 0  }
				}		
			}
		}
		"env" {
			if {[expr $vb(noeswell) + $vb(noesoft) + $vb(noestrong) + $vb(noeatk)] == 4} {
				switch -- $typ {
					"swell"  { set vb(noeswell) 0  }
					"soft"   { set vb(noesoft) 0   }
					"strong" { set vb(noestrong) 0 }
					"atk"    { set vb(noeatk) 0    }
				}		
			}
		}
	}
}

#--- Toggle Stacking <-> Transposition

proc VBTorS {isstak} {
	global vb evv
	if {$isstak} {
		.varibox.1.0.0.6.ll config -text "   Max Stack Lean"
		.varibox.1.0.0.6.e config -state normal -bd 2
		catch {set vb(staklean) $vb(last_staklean)}
		bind .varibox.1.0.0.5.e <Control-Down> {focus .varibox.1.0.0.6.e}
		bind .varibox.1.0.0.6.e <Control-Down> {focus .varibox.1.1.0.0.e}
		bind .varibox.1.1.0.0.e <Control-Up>   {focus .varibox.1.0.0.6.e}
		bind .varibox.1.0.1.6.e <Control-Left> {focus .varibox.1.0.0.6.e} 
		.varibox.1.0.0.6.ll config -text "   Max Stack Lean"
		.varibox.1.0.0.6.e config -bd 2 -state normal
		catch {set vb(staklean) $vb(last_staklean)}
		.varibox.1.0.0.6.ps config -text "PreStack" -state normal -indicatoron 1 -bd 2 -selectcolor $evv(EMPH)
	} else {
		.varibox.1.0.0.6.ll config -text ""
		catch {set vb(last_staklean) $vb(staklean)}
		set vb(staklean) ""
		.varibox.1.0.0.6.e config -state disabled -bd 0
		bind .varibox.1.0.1.6.e <Control-Left> {focus .varibox.1.0.0.5.e} 
		bind .varibox.1.0.0.5.e <Control-Down> {focus .varibox.1.1.0.0.e}
		bind .varibox.1.1.0.0.e <Control-Up>   {focus .varibox.1.0.0.5.e}
		focus .varibox.1.01.e
		.varibox.1.0.0.6.ll config -text ""
		.varibox.1.0.0.6.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
		.varibox.1.0.0.6.ps config -text "" -state disabled -indicatoron 0 -bd 0 -bd 0 -selectcolor [option get . background {}]
		catch {set set vb(last_staklean) $vb(staklean)}
		set vb(staklean) ""
	}
}

#--- Create timed tables of variation of vibrato and tremolo frq and depth

proc CreateVariboxVibTremTables {dur start} {
	global vb evv
	set gotime [expr $start + $evv(VBOX_RAND_TSTEP)]
	if {($vb(typ) != $evv(VB_STEADY)) && ($vb(typ) != $evv(VB_ITERED)) && ($vb(typ) != $evv(VB_PULSED))} {
		if {!$vb(novffixd)} {
			set vibfrqbrkvals [RandFrqSeq $vb(vibfrq) $dur $start]
		}
		if {!$vb(novdfixd)} {
			set vibdepbrkvals [RandDepSeq $vb(vibdep) $dur $start]
		}
	}
	if {($vb(typ) != $evv(VB_ITERED)) && ($vb(typ) != $evv(VB_PULSED)) && ($vb(typ) != $evv(VB_WOBBLY))} {
		if {!$vb(notffixd)} {
			set trmfrqbrkvals [RandFrqSeq $vb(trmfrq) $dur $start]
		}
		if {!$vb(notdfixd)} {
			set trmdepbrkvals [RandDepSeq $vb(trmdep) $dur $start]
		}
	}

	# CREATE CHANGING VALS TIMED LIST

	if {($vb(typ) != $evv(VB_STEADY)) && ($vb(typ) != $evv(VB_ITERED)) && ($vb(typ) != $evv(VB_PULSED))} {
		if {!$vb(novfacc)} {
			if {$start > 0.0} {
				set vibfrqupbrkvals [list 0.0 0.0 $start 0.0 $gotime $vb(vibfrqlo) $dur $vb(vibfrqhi)]
			} else {
				set vibfrqupbrkvals [list 0.0 $vb(vibfrqlo) $dur $vb(vibfrqhi)]
			}
		}
		if {!$vb(novfrit)} {
			if {$start > 0.0} {
				set vibfrqdnbrkvals [list 0.0 0.0 $start 0.0 $gotime $vb(vibfrqhi) $dur $vb(vibfrqlo)]
			} else {
				set vibfrqdnbrkvals [list 0.0 $vb(vibfrqhi) $dur $vb(vibfrqlo)]
			}
		}
		if {!$vb(novdacc)} {
			if {$start > 0.0} {
				set vibdepupbrkvals [list 0.0 0.0 $start 0.0 $gotime $vb(vibdeplo) $dur $vb(vibdephi)]
			} else {
				set vibdepupbrkvals [list 0.0 $vb(vibdeplo) $dur $vb(vibdephi)]
			}
		}
		if {!$vb(novdrit)} {
			if {$start > 0.0} {
				set vibdepdnbrkvals [list 0.0 0.0 $start 0.0 $gotime $vb(vibdephi) $dur $vb(vibdeplo)]
			} else {
				set vibdepdnbrkvals [list 0.0 $vb(vibdephi) $dur $vb(vibdeplo)]
			}
		}
	}
	if {($vb(typ) != $evv(VB_ITERED)) && ($vb(typ) != $evv(VB_PULSED)) && ($vb(typ) != $evv(VB_WOBBLY))} {
		if {!$vb(notfacc)} {
			if {$start > 0.0} {
				set trmfrqupbrkvals [list 0.0 0.0 $start 0.0 $gotime $vb(trmfrqlo) $dur $vb(trmfrqhi)]
			} else {
				set trmfrqupbrkvals [list 0.0 $vb(trmfrqlo) $dur $vb(trmfrqhi)]
			}
		}
		if {!$vb(notfrit)} {
			if {$start > 0.0} {
				set trmfrqdnbrkvals [list 0.0 0.0 $start 0.0 $gotime $vb(trmfrqhi) $dur $vb(trmfrqlo)]
			} else {
				set trmfrqdnbrkvals [list 0.0 $vb(trmfrqhi) $dur $vb(trmfrqlo)]
			}
		}
		if {!$vb(notdacc)} {
			if {$start > 0.0} {
				set trmdepupbrkvals [list 0.0 0.0 $start 0.0 $gotime $vb(trmdeplo) $dur $vb(trmdephi)]
			} else {
				set trmdepupbrkvals [list 0.0 $vb(trmdeplo) $dur $vb(trmdephi)]
			}
		}
		if {!$vb(notdrit)} {
			if {$start > 0.0} {
				set trmdepdnbrkvals [list 0.0 0.0 $start 0.0 $gotime $vb(trmdephi) $dur $vb(trmdeplo)]
			} else {
				set trmdepdnbrkvals [list 0.0 $vb(trmdephi) $dur $vb(trmdeplo)]
			}
		}
		if {$vb(typ) == $evv(VB_ATKRES)} {
			if {!($vb(notfacc) || $vb(notfrit))} {
				if {$start > 0.0} {
					set time2 [expr ($dur - $gotime)/3.0]
					set time2 [expr $time2 + $gotime]
					set trmfrqbrkvals2 [list 0.0 0.0 $start 0.0 $gotime $vb(trmfrqlo) $time2 $vb(trmfrqhi) $dur $vb(trmfrqlo)]
					set trmfrqbrkvals3 [list 0.0 0.0 $start 0.0 $gotime $vb(trmfrqhi) $time2 $vb(trmfrqlo) $dur $vb(trmfrqhi)]
				} else {
					set time2 [expr $dur/3.0]
					set trmfrqbrkvals2 [list 0.0 $vb(trmfrqlo) $time2 $vb(trmfrqhi) $dur $vb(trmfrqlo)]
					set trmfrqbrkvals3 [list 0.0 $vb(trmfrqhi) $time2 $vb(trmfrqlo) $dur $vb(trmfrqhi)]
				}
			}
		}
	}

	# CREATE LISTS OF VALUES

	if {($vb(typ) != $evv(VB_STEADY)) && ($vb(typ) != $evv(VB_ITERED)) && ($vb(typ) != $evv(VB_PULSED))} {
		set vb(vibfrqlist) {}
		if {!$vb(novffixd)} {
			lappend vb(vibfrqlist) $vibfrqbrkvals
		}
		if {!$vb(novfacc)} {
			lappend vb(vibfrqlist) $vibfrqupbrkvals
		}
		if {!$vb(novfrit)} {
			lappend vb(vibfrqlist) $vibfrqdnbrkvals
		}
		set vb(vibdeplist) {}
		if {!$vb(novdfixd)} {
			lappend vb(vibdeplist) $vibdepbrkvals
		}
		if {!$vb(novdacc)} {
			lappend vb(vibdeplist) $vibdepupbrkvals
		}
		if {!$vb(novdrit)} {
			lappend vb(vibdeplist) $vibdepdnbrkvals
		}
	}
	if {($vb(typ) != $evv(VB_ITERED)) && ($vb(typ) != $evv(VB_PULSED)) && ($vb(typ) != $evv(VB_WOBBLY))} {
		set vb(trmfrqlist) {}
		if {!$vb(notffixd)} {
			lappend vb(trmfrqlist) $trmfrqbrkvals
		}
		if {!$vb(notfacc)} {
			lappend vb(trmfrqlist) $trmfrqupbrkvals
		}
		if {!$vb(notfrit)} {
			lappend vb(trmfrqlist) $trmfrqdnbrkvals
		}
		if {$vb(typ) == $evv(VB_ATKRES)} {
			if {!($vb(notfacc) || $vb(notfrit))} {
				lappend vb(trmfrqlist) $trmfrqbrkvals2
				lappend vb(trmfrqlist) $trmfrqbrkvals3
			}
		}

		set vb(trmdeplist) {}
		if {!$vb(notdfixd)} {
			lappend vb(trmdeplist) $trmdepbrkvals
		}
		if {!$vb(notdacc)} {
			lappend vb(trmdeplist) $trmdepupbrkvals
		}
		if {!$vb(notdrit)} {
			lappend vb(trmdeplist) $trmdepdnbrkvals
		}
	}
}

#----- Generate vibrato and tremolo variants

proc VariboxVibandTrem {srclist dcnt dlen} {
	global vb evv
	set voutcnt 1
	set toutcnt 1
	if {$vb(typ) != $evv(VB_STEADY)} {
		set vlen [expr [llength $srclist] * [llength $vb(vibfrqlist)] * [llength $vb(vibdeplist)]]
	}
	if {$vb(typ) != $evv(VB_WOBBLY)} {
		set tlen [expr [llength $srclist] * [llength $vb(trmfrqlist)] * [llength $vb(trmdeplist)]]
	}
	if {$dlen == 0} {
		set dcnt 1
		set dlen [llength $srclist]
	}
	foreach src $srclist {
		if {($vb(typ) != $evv(VB_STEADY)) && !$vb(novib)} {
	
			set basnam [file rootname $src]
			set vfcnt 0
			foreach vf $vb(vibfrqlist) {						;#	00 01 02, 10 11 12, ETC
				set vfnam $basnam
				append vfnam $vfcnt
				set vdcnt 0
				foreach vd $vb(vibdeplist) {					;#	000 001 002 010 011 012 020 021 022, ETC
					wm title .blocker "PLEASE WAIT:        Creating Vibrato Variant $voutcnt of $vlen : src $dcnt of $dlen"
					set vfdnam $vfnam
					append vfdnam $vdcnt $evv(SNDFILE_EXT)
					if {[DoVariboxVib $src $vfdnam $vf $vd vibrato]} {
						lappend vb(outs) $vfdnam
					}
					incr vdcnt
					incr voutcnt
				}
				incr vfcnt
			}
		}

;#	GENERATE TREMOLO VARIANTS

		if {($vb(typ) != $evv(VB_WOBBLY)) && !$vb(notrm)} {
			set basnam [file rootname $src]
			set tfcnt 3										;#	Follows on from (max of) 3 vib files names
			foreach tf $vb(trmfrqlist) {						;#	03 04 05, 13 14 15 ETC
				set tfnam $basnam
				append tfnam $tfcnt
				set tdcnt 0
				foreach td $vb(trmdeplist) {
					wm title .blocker "PLEASE WAIT:        Creating Tremolo Variant $toutcnt of $tlen : src $dcnt of $dlen"
					set tfdnam $tfnam						;#	030 031 032, 040 041 ETC
					append tfdnam $tdcnt $evv(SNDFILE_EXT)
					if {[DoVariboxVib $src $tfdnam $tf $td tremolo]} {
						lappend vb(outs) $tfdnam
					}
					incr tdcnt
					incr toutcnt
				}
				incr tfcnt
			}
		}
		incr dcnt
	}
}

#--- Remove src (if used) from list of outputs

proc VariboxRemoveSrc {} {
	global vb
	set n 0
	foreach fnam $vb(outs) {
		if {[string match $fnam $vb(ifnam)]} {
			set vb(outs) [lreplace $vb(outs) $n $n]
			break
		}
		incr n
	}
}

proc VBenvX {} {
	global vb
	set vb(last_norev) $vb(norev)
}

#--- Remove any previously created outputs

proc VariBoxRemoveOutputs {fnams onwksp} {
	global vb evv wl blist_change rememd background_listing

	Block "Removing previously created files"
	set blist_change 0
	set n 0
	if {$onwksp} {
		foreach fnam $fnams {
			set i [LstIndx $fnam $wl]
			if [DeleteFileFromSystem $fnam 0 1] {
				if {$i >= 0} {
					lappend deleted_files $i	;#	save the listing-index of each ACTUALLY deleted file
				}
				DummyHistory $fnam "DESTROYED"
			}
			incr n
		}
	} else {
		foreach fnam $fnams {
			if [catch {file delete $fnam} zit] {
				;#	
			} else {
				lappend deleted_files $n
			}
			incr n
		}
	}
	if [info exists deleted_files] {
		if {$onwksp} {
			if {$blist_change} {
				SaveBL $background_listing
			}
			foreach i [lsort -integer -decreasing $deleted_files] {
				WkspCnt [$wl get $i] -1
				$wl delete $i
			}
			catch {unset rememd}
		}
		if {[llength $deleted_files] != $n} {
			Inf "Some Previously Created Files Could Not Be Deleted"
			UnBlock
			return 0
		}
	} else {
		Inf "Previously Created Files Could Not Be Deleted"
		UnBlock
		return 0
	}
	UnBlock
	return 1
}

#---- Save sound outputs from Varibox

proc VariBoxSaveOutput {sndouts} {
	global last_outfile wstk chlist ch chcnt

	Block "Saving the output file"
	set badfiles 0
	set sndouts [ReverseList $sndouts]
	set finaloutcnt 0
	set fcnt 1
	set flen [llength $sndouts]
	foreach fnam $sndouts {
		wm title .blocker "PLEASE WAIT:        Parsing output file $fcnt of $flen"
		if {[FileToWkspace $fnam 0 0 0 0 1] <= 0} {
			incr badfiles
		} else {
			lappend real_outfiles $fnam
			incr finaloutcnt
		}
		incr fcnt
	}
	if {$finaloutcnt == 0} {
		Inf "No Valid Outputs Generated"
		UnBlock
		return {}
	}
	set last_outfile $real_outfiles
	set msg "$finaloutcnt Output Files Are Now On The Workspace"
	if {$badfiles} {
		append msg "\n\n($badfiles Invalid Files Were Also Created)"
	}
	append msg "\n\nPut Output Files On The Chosen List"
	set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
	if {$choice == "yes"} {
		ClearAndSaveChoice
		ClearWkspaceSelectedFiles
		set chlist [ReverseList $real_outfiles]
		foreach fnam $chlist {
			$ch insert end $fnam
			incr chcnt
		}
	}
	UnBlock
	return $real_outfiles
}

#--- Create texture of output sounds and play it

proc VariboxPlayOutputSample {snds} {
	global vb evv CDPidrun prg_dun prg_abortd simple_program_messages variboxmsgs
	if {![info exists vb(sample)]} {
		set basnam $evv(DFLT_OUTNAME)
		append basnam $vb(tempfilcnt)
		set vb(sample) $basnam
		append vb(sample) $evv(SNDFILE_EXT)
		set vb(notedata) $basnam
		append vb(notedata) $evv(TEXT_EXT)
		incr vb(tempfilcnt)
	}
	if {![file exists $vb(sample)]} {
		set line ""
		set sndcnt 0
		foreach snd $snds {
			incr sndcnt
			append line "60 "
		}
		if [catch {open $vb(notedata) "w"} zit] {
			Inf "Cannot Open File To Write Texture Data"
			return 0
		}
		puts $zit $line
		close $zit
		Block "Generating Output Texture"
		set cmd	[file join $evv(CDPROGRAM_DIR) texture]
		lappend cmd simple 5
		foreach snd $snds {
			lappend cmd $snd
		}
		lappend cmd $vb(sample)	$vb(notedata)
		lappend cmd 20 .5 2 0 1 $sndcnt 30 127 .016 1 60 60 -a.97 -p.5 -s1 -r0 -w -c -p

		if [catch {open "|$cmd"} CDPidrun] {
			Inf "Cannot Create Sample Texture To Play: $CDPidrun"
			catch {unset CDPidrun}
			catch {file delete $vb(sample)}
			UnBlock
			return
		} else {
			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			Inf "Failed To Create Sample Texture To Play"
			catch {file delete $vb(sample)}
			UnBlock
			return
		}
		if {![file exists $vb(sample)]} {
			Inf "Creating Sample Texture To Play Failed"
			UnBlock
			return
		}
		UnBlock
	}
	PlaySndfile $vb(sample) 0
}

#---- Help for Varibox

proc VariboxHelp {} {
	set msg "                                                                     VARIBOX\n"	
	append msg "\n"
	append msg "Generate a large number of variants of a source sound, (approximately) preserving the original pitch/spectrum.\n"
	append msg "(Once you have generated outputs, the \"Play Sample\" button appears and will play a sample-texture made from the outputs).\n" 
	append msg "\n"
	append msg "Variants are made through vibrato, tremolo, pitch drift, iteration of short cut-segments,\n"
	append msg "transposition or octave stacking of these segments, reverberation, with variation of the parameters of all of these,\n"
	append msg "followed by various envelopings of the final outputs.\n"
	append msg "\n"
	append msg "Some randomness is introduced into the parameterisation e.g.the durations of the output sounds,\n"
	append msg "the regularity of the iteration delays, the tremolo narrowing and so on,\n"
	append msg "so that the final output sounds differ in subtle ways.\n"
	append msg "\n"
	append msg "The final shaping envelopes can be of any form, but must each end with a zero value.\n"
	append msg "With no envelope filename entered, default values are used.\n"
	append msg "\n"
	append msg "Post-reverberation, if used, has its parameter values randomised before being applied to the outputs\n"
	append msg "(For consistent reverberation, apply a fixed reverberation, or none, to all of the (non-reverbd) outputs).\n"
	append msg "Parameter values refer to the number of echos, whose mean separation is 0.1 seconds.\n"
	append msg "The \"Dry outputs\" parameter can be zero (no dry outputs) or an odd number >= 3\n"
	append msg "where the proportion of dry outputs will be 1/N.\n"
	append msg "\n"
	append msg "There are 6 types of output\n"
	append msg "\n"
	append msg "(1) GENERAL: produces pitchdrift, vibrato, tremolo and iterates.\n"
	append msg "(2) STEADY:  has NO pitchdrift or vibrato.\n"
	append msg "(3) WOBBLY:  has NO tremolo, and iterates are more pitch-unstable.\n"
	append msg "(4) ITERATED: Uses iterates only, and a variety of 8va stackings.\n"
	append msg "(5) PULSED:  As \"Iterated\", but avoiding long iterate-elements that overlay one another.\n"
	append msg "(6) ATK-RES: Uses short events which are first reverberated, then stacked.\n"
	append msg "\n"
	append msg "      For Iterated, Pulsed and Atk-Res output,\n"
	append msg "      a maximum up and down transposition must be specified for the transpositions or stacks.\n"
	append msg "      Values are in 8vas, and are always positiver numbers. \n"
	append msg "      (To avoid all transposition or stacking, click on the \"X\" box nearby).\n"
	append msg "      Transposition ranges for particular impulse shapes are automatically limited by Varibox,\n"
	append msg "      to avoid envelopes becoming too steep or too long.\n"
	append msg "\n"
	append msg "      For Iterated, Pulsed and Atk-Res output stacks,a maximum value for the stack \"lean\" (L) is also needed.\n"
	append msg "      Vals are then generated at random between L and 1/L.\n"
	append msg "\n"
	append msg "      For Atk-Res output, stacks are reverberated before any vibrato or tremolo is added.\n"
	append msg "\n"
	append msg "      For Pulsed outputs, \"Overlap Suppression\" causes accelerating or decellerating iterates\n"
	append msg "      to be rejected if the length of the iterated unit is greater than a certain value.\n"
	append msg "      value 0: no iterates are rejected.\n"
	append msg "      value 1: rejects iterates with units longer than shortest delay (no overlap of units possible).\n"
	append msg "      Other values set a rejection threshold between these extremes.\n"
	append msg "\n"
	append msg "      In the \"Stack\" default case , the short-events cut from the source and then stacked\n"
	append msg "      are syncd at the envelope peak of the short-event.\n"
	append msg "      Alternatively, selecting \"PreStack\", the source can be stacked BEFORE it is cut.\n"
	append msg "      In this case, all stacked copies are synchronised at the sound start.\n"
	append msg "      (For \"Transpose\", transpositions are always made before the source is cut).\n"
	append msg "\n"
	append msg "Certain varibox options can be EXCLUDED, using the buttons marked \"X\" on the display. Also...\n"
	append msg "      X-fix excludes the fixed-value option.\n"
	append msg "      X-acc excludes the accelerando option.\n"
	append msg "      X-rit excludes the ritardando option.\n"
	append msg "(Note that, for any feature on the interface, you cannot exclude ALL its options at once).\n"
	append msg "\n"
	append msg "You can step between the parameter entry boxes using Control-Up/Down/Left/Right.\n"
	Inf $msg
}


#--- Generate a related zig file, same length as orig

proc ReZig {} {
	global pr_rezig rezig evv wl chlist pa wstk
	global  prg_dun prg_abortd simple_program_messages CDPidrun last_outfile

	set evv(REZIGERR) 0.0001

	if {[info exists chlist] && ([llength $chlist] == 1)} {
		set fnam $chlist
	} else {
		set ilist [$wl curselection]
		if {[llength $ilist] == 1} {
			if {$ilist != -1} {
				set fnam [$wl get $i]
			}
		}
	}
	if {![info exists fnam]} {
		Inf "Select One Soundfile"
		return
	}
	if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
		Inf "Select A Soundfile"
		return
	}
	set endtime $pa($fnam,$evv(DUR))

	set f .rezig
	if [Dlg_Create $f "CREATE RELATED ZIGZAG FILES" "set pr_rezig 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0] 
		set f1 [frame $f.1] 
		set f2 [frame $f.2] 
		set f3 [frame $f.3] 
		set f4 [frame $f.4] 
		set f5 [frame $f.5] 
		set f6 [frame $f.6] 
		set f7 [frame $f.7] 
		set f8 [frame $f.8] 
		set f9 [frame $f.9] 
		button $f0.ok -text "Create Zigfiles" -command "set pr_rezig 1" -bg $evv(EMPH)  -highlightbackground [option get . background {}]
		button $f0.hh -text "Help" -command "RezigHelp" -bg $evv(HELP)  -highlightbackground [option get . background {}]
		button $f0.sv -text "Sound View" -command "set pr_rezig 2" -bg $evv(SNCOLOR)  -highlightbackground [option get . background {}]
		label $f0.ll -text "Sound Duration " -width 32 -fg $evv(SPECIAL)
		button $f0.quit -text "Abandon" -command "set pr_rezig 0"  -highlightbackground [option get . background {}]
		pack $f0.ok $f0.hh $f0.sv -side left -padx 1
		pack $f0.ll -side left -padx 4
		pack $f0.quit -side right
		pack $f0 -side top -fill x -expand true

		label $f1.ll -text "Required output duration"
		entry $f1.e -textvariable rezig(odur) -width 24
		pack $f1.e $f1.ll -side left
		pack $f1 -side top -fill x -expand true -pady 2

		label $f2.ll -text "Splice length (mS) (2-50)"
		entry $f2.e -textvariable rezig(msspl) -width 24
		pack $f2.e $f2.ll -side left
		pack $f2 -side top -fill x -expand true -pady 2

		label $f3.ll -text "Number of files to generate (1-32)"
		entry $f3.e -textvariable rezig(cnt) -width 12
		pack $f3.e $f3.ll -side left -padx 2
		pack $f3 -side top -fill x -expand true -pady 2

		label $f4.ll -text "Min time in src for direction changes"
		entry $f4.e -textvariable rezig(mintime) -width 12
		pack $f4.e $f4.ll -side left -padx 2
		pack $f4 -side top -fill x -expand true -pady 2

		label $f5.ll -text "Max time in src for direction changes"
		entry $f5.e -textvariable rezig(maxtime) -width 12
		pack $f5.e $f5.ll -side left -padx 2
		pack $f5 -side top -fill x -expand true -pady 2

		label $f6.ll -text "Min zig length"
		entry $f6.e -textvariable rezig(min) -width 12
		pack $f6.e $f6.ll -side left -padx 2
		pack $f6 -side top -fill x -expand true -pady 2

		label $f7.ll -text "Max zig length"
		entry $f7.e -textvariable rezig(max) -width 12
		pack $f7.e $f7.ll -side left -padx 2
		pack $f7 -side top -fill x -expand true -pady 2

		label $f8.ll -text "Seed value (0-512)"
		entry $f8.e -textvariable rezig(seed) -width 12
		pack $f8.e $f8.ll -side left -padx 2
		pack $f8 -side top -fill x -expand true -pady 2

		label $f9.ll -text "Generic outputfile name"
		entry $f9.e -textvariable rezig(ofnam) -width 24
		label $f.9.store -text Patch
		button $f.9.get -text "Get" -command "GetRezigPatch" -width 4  -highlightbackground [option get . background {}]
		button $f.9.put -text "Save" -command "set pr_rezig 3" -width 4  -highlightbackground [option get . background {}]
		pack $f9.e $f9.ll -side left
		pack $f.9.get $f.9.put $f.9.store -side right -pady 2 
		pack $f9 -side top -fill x -expand true -pady 2

		wm resizable $f 0 0
		bind $f1.e <Down> "focus $f2.e"
		bind $f2.e <Down> "focus $f3.e"
		bind $f3.e <Down> "focus $f4.e"
		bind $f4.e <Down> "focus $f5.e"
		bind $f5.e <Down> "focus $f6.e"
		bind $f6.e <Down> "focus $f7.e"
		bind $f7.e <Down> "focus $f8.e"
		bind $f8.e <Down> "focus $f9.e"
		bind $f9.e <Down> "focus $f1.e"
		bind $f1.e <Up> "focus $f9.e"
		bind $f2.e <Up> "focus $f1.e"
		bind $f3.e <Up> "focus $f2.e"
		bind $f4.e <Up> "focus $f3.e"
		bind $f5.e <Up> "focus $f4.e"
		bind $f6.e <Up> "focus $f5.e"
		bind $f7.e <Up> "focus $f6.e"
		bind $f8.e <Up> "focus $f7.e"
		bind $f9.e <Up> "focus $f8.e"
		bind $f <Return> "set pr_rezig 1"
		bind $f <Escape> "set pr_rezig 0"
	}
	$f.0.ll config -text "Sound Duration $endtime secs"
	set rezig(mintime) 0.0
	set rezig(maxtime) $endtime
	set pr_rezig 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_rezig $f.1.e
	while {!$finished} {
		tkwait variable pr_rezig
		switch -- $pr_rezig  {
			1 - 
			3 {
				if {([string length $rezig(odur)] <= 0) || ![IsNumeric $rezig(odur)]} {
					Inf "Invalid Required Output Duration"
					continue
				}
				if {$rezig(odur) <= $endtime} {
					Inf "Output Duration Mnust Be Greater Than Length Of Input File"
					continue
				}
				if {([string length $rezig(cnt)] <= 0) || ![regexp {^[0-9]+$} $rezig(cnt)] || ($rezig(cnt) < 1) || ($rezig(cnt) > 32)} {
					Inf "Invalid Number Of Files To Generate"
					continue
				}
				if {([string length $rezig(msspl)] <= 0) || ![IsNumeric $rezig(msspl)]} {
					Inf "Invalid Splicelength"
					continue
				}
				if {($rezig(msspl) <= 2) || ($rezig(msspl) >= 50)} {
					Inf "Splicelength Out Of Range"
					continue
				}
				set rezig(splice) [expr $rezig(msspl) * $evv(MS_TO_SECS)]
				set rezig(dblsplice) [expr $rezig(splice) * 2.5]

				if {([string length $rezig(mintime)] <= 0) || ![IsNumeric $rezig(mintime)]} {
					Inf "Invalid Min Time For Direction Changes"
					continue
				}
				if {($rezig(mintime) < 0.0) || ($rezig(mintime) >= $endtime)} {
					Inf "Min Time For Direction Changes Is Out Of Range (0 to < $endtime)"
					continue
				}
				if {([string length $rezig(maxtime)] <= 0) || ![IsNumeric $rezig(maxtime)]} {
					Inf "Invalid Max Time For Direction Changes"
					continue
				}
				if {($rezig(maxtime) <= 0.0) || ($rezig(maxtime) > $endtime)} {
					Inf "Max Time For Direction Changes Is Out Of Range (> 0 to $endtime)"
					continue
				}
				if {$rezig(maxtime) <= [expr $rezig(mintime) + $evv(FLTERR)]} {
					Inf "Max And Min Times For Direction Changes Are Incompatible"
					continue
				}

				set outliers [expr $endtime - $rezig(maxtime) + $rezig(mintime)]
				set rezig(odur_inrange) [expr $rezig(odur) - $outliers]

				if {([string length $rezig(min)] <= 0) || ![IsNumeric $rezig(min)]} {
					Inf "Invalid Minimum Zig Length"
					continue
				}
				if {$rezig(min) < $rezig(splice)} {
					Inf "Min Zig Length Is Too Short For Splices"
					continue
				}
				if {$rezig(min) >= $rezig(odur_inrange)} {
					Inf "Min Zig Length Is Too Long For The Defined Zigzagging Range"
					continue
				}
				if {([string length $rezig(max)] <= 0) || ![IsNumeric $rezig(max)]} {
					Inf "Invalid Maximum Zig Length"
					continue
				}
				if {$rezig(max) >= $rezig(odur_inrange)} {
					Inf "Min Zig Length Is Too Long For The Defined Zigzagging Range"
					continue
				}
				if {$rezig(max) <= $rezig(min)} {
					Inf "Max And Min Zig Lengths Are Incompatible (must Differ)"
					continue
				}
				set rezig(range) [expr $rezig(max) - $rezig(min)]

				if {$rezig(odur_inrange) <= [expr $rezig(range) + (2 * $rezig(splice)) + $rezig(min)]} {
					Inf "Output Duration Not Long Enough To Permit Minimum Zig Specified"
					continue
				}

				if {([string length $rezig(seed)] <= 0) || ![regexp {^[0-9]+$} $rezig(seed)] || ($rezig(seed) > 512)} {
					Inf "Invalid Seed Value (Must Be Integer)"
					continue
				}

				if {![ValidCDPRootname $rezig(ofnam)]} {
					continue
				}
				if {$pr_rezig == 3} {
					StoreRezigPatch
					continue
				}
				set ofnam [string tolower $rezig(ofnam)]
				set n 1
				set OK 1
				while {$n <= $rezig(cnt)} {
					set thisofnam $ofnam
					append thisofnam $n $evv(TEXT_EXT)
					if {[file exists $thisofnam]} {
						Inf "File $thisofnam Already Exists: Please Choose A Different Generic Name"
						set OK 0
						break
					}
					set thisofnam $ofnam
					append thisofnam $n $evv(SNDFILE_EXT)
					if {[file exists $thisofnam]} {
						Inf "File $thisofnam Already Exists: Please Choose A Different Generic Name"
						set OK 0
						break
					}
					incr n
				}
				if {!$OK} {
					continue
				}

				set rezig(subgoal) [expr $rezig(odur_inrange) - $rezig(range)]	;#	Length of output to reach before we fall within reach of end of required output

				if {$rezig(max) >= $rezig(subgoal)} {
					set msg "With This Max Zig Length And The Specified Output Duration, Zigzagging Could Fail : Continue ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
				}
				expr srand($rezig(seed))

				set n 1
	
				Block "GENERATING ZIGZAG DATA FILES"

				while {$n <= $rezig(cnt)} {
					wm title .blocker "PLEASE WAIT:        GENERATING ZIGZAG DATA FILE $n"

					set rezig(totlen) 0.0		;#	Accumulating length of output file generated by zigzagging
					set rezig(zigzags) 0	;#	Zigzagging starts at time zero

					;#	DO INITIAL ZIG

					set dn 0				;#	Range limits within source file between which  first zigpoint falls
					set up $rezig(range)
					set thisrange [expr $up - $dn]

					set OK 0
					while {!$OK} {
						set len [expr rand() * $thisrange]
						if {($len > $rezig(dblsplice)) && ($len < $rezig(subgoal))} {			;#	Get first zig longer than splicelen
							set x $len
							set OK 1
						}
					}
					lappend rezig(zigzags) $x
					set up $x								;#	Current position becomes upper limit for zag	

					set rezig(totlen) [expr $rezig(totlen) + $len]	;#	Keep tally of total length attained
				
					while {$rezig(totlen) < $rezig(subgoal)} {

						;#	DO ZAG

						set rezig(lastlen) $rezig(totlen)
						set thisrange [expr $up - $dn]
						set OK 0
						while {!$OK} {
							set len [expr rand() * $thisrange]
							if {$len > $rezig(dblsplice)} {		;#	Get next zag longer than splicelen
								set x [expr $up - $len]
								if {$x < $evv(REZIGERR)} {
									set x 0.0
								}
								set OK 1
							}
						}
						lappend rezig(zigzags) $x
						set dn $x							;#	Current position becomes lower limit for zig
						set up $rezig(range)
						set rezig(totlen) [expr $rezig(totlen) + $len - $rezig(splice)]	;#	Keep tally of total length attained. taking into account splicing

						;#	DO ZIG

						set thisrange [expr $up - $dn]
						if {$thisrange <= $rezig(dblsplice)} {
							set up [expr $dn + ($rezig(dblsplice) * 1.1)]
							set thisrange [expr $up - $dn]
						}
						set OK 0
						while {!$OK} {
							set len [expr rand() * $thisrange]
							if {$len > $rezig(dblsplice)} {		;#	Get next zig longer than splicelen
								set x [expr $len + $dn]
								if {$x <= $rezig(range)} {
									set OK 1
								}
							}
						}
						lappend rezig(zigzags) $x
						set up $x							;#	Current position becomes upper limit for zag
						set dn 0
						set rezig(totlen) [expr $rezig(totlen) + $len - $rezig(splice)]	;#	Keep tally of total length attained. taking into account splicing
					}
					set endstep [expr $rezig(range) - $x]							;#	Distance in src from end of last zig to end of entire zigzag range
					set remainder [expr $rezig(odur_inrange) - $rezig(totlen)]		;#	Remaining duration still to be generated
		
					;#	If we've overshot the required duration																	
					;#	Or there is insufficient space to zag+zig before the end
					;#	Or final backsplice will be too short to meet ZIGZAG progs criterion that min len > 2 * splicelen
					;#	Or the bakstep takes the read-point too close to zero (Problem with small number dataq conversion!!)

					set doquit 0
					set testlen [expr ($remainder - $endstep + (2 * $rezig(splice)))/2.0]
					if {($remainder < 0) || ($endstep > [expr $remainder + ($rezig(splice) * 2)]) \
					||  ($testlen < $rezig(dblsplice)) || ([expr $x - $testlen] <= $evv(REZIGERR))} {
						set OK 0
						set cntlimit 100
						set cnt 1
						while {!$OK} {
							set OK [ReZigRecalcLastTwoVals]
							incr cnt
							if {!$OK && ($cnt >= $cntlimit)} {
								set msg "Problem Recalculating final value pair: $cnt attempts: Continue ??"
								set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
								if {$choice == "yes"} {
									incr cntlimit 100
								} else {
									set OK 1
									set doquit 1
								}
							}
						}
						set x  [lindex $rezig(zigzags) end]
						set up [lindex $rezig(zigzags) end]
					}
					if {$doquit} {
						set finished 1
						break
					}
					set endstep [expr $rezig(range) - $x]						;#	Distance in src from end of last zig to end of entire zigzag range
					set remainder [expr $rezig(odur_inrange) - $rezig(totlen)]		;#	Remaining duration still to be generated

					;#	Calculate an appropriate zag (bacK) to make up the necessary total duration

					set firststep [expr ($remainder - $endstep + (2 * $rezig(splice)))/2.0]

					set x [expr $up - $firststep]
					lappend rezig(zigzags) $x
					lappend rezig(zigzags) $rezig(range)	;#	Then go to end of range
				
					;#	SO FAR ZIGZAGS RUN OVER THE PERMITTED ZIGRANGE: CHANGE TO THE FRAME OF ENTIRE INPUT FILE BY

					;# Add rezig(mintime) to all vals

					set len [llength $rezig(zigzags)]
					set m 0
					while {$m < $len} {
						set val [lindex $rezig(zigzags) $m]
						set val [expr $val + $rezig(mintime)]
						set rezig(zigzags) [lreplace $rezig(zigzags) $m $m $val]
						incr m
					}

					;# Replace 1st time by time 0 (start of sound) and replace last val by endtime (end of sound)

					set rezig(zigzags) [lreplace $rezig(zigzags) 0 0 0.0]
					set rezig(zigzags) [lreplace $rezig(zigzags) end end $endtime]

					;#	WRITE TO DATAFILE OUTFILE

					set thisofnam $ofnam
					append thisofnam $n $evv(TEXT_EXT)
					if [catch {open $thisofnam "w"} zit] {
						Inf "Cannot Open File $thisofnam"
						incr n
						continue
					}
					foreach zigzag $rezig(zigzags) {
						puts $zit $zigzag
					}
					close $zit
					lappend outfiles $thisofnam
					incr n
				}
				if {![info exists outfiles]} {
					UnBlock
					Inf "No Data Generated"
					if {$doquit} {
						break
					}
					continue
				}
				foreach outfnam $outfiles {
					FileToWkspace $outfnam 0 0 0 0 1
				}
				set cnt 0
				catch {unset last_outfile}
				foreach zigfile $outfiles {
					set sndfnam [file rootname $zigfile]
					append sndfnam $evv(SNDFILE_EXT)
					set cmd [file join $evv(CDPROGRAM_DIR) extend]
					lappend cmd zigzag 2 $fnam $sndfnam $zigfile -s$rezig(msspl)
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					wm title .blocker "PLEASE WAIT:        GENERATING SOUND OUTPUT $sndfnam"
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "Cannot Create Sndfile $sndfnam"
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
						set msg "Failed To Create Soundfile $sndfnam"
						set msg [AddSimpleMessages $msg]
						Inf $msg
						catch {close $CDPidrun}
						continue
					}
					if {![file exists $sndfnam]} {
						set msg " Creating Soundfile $sndfnam Failed: "
						set msg [AddSimpleMessages $msg]
						Inf $msg
						catch {close $CDPidrun}
						continue
					}
					catch {close $CDPidrun}
					FileToWkspace $sndfnam 0 0 0 0 1
					lappend last_outfile $sndfnam
					incr cnt
				}
				UnBlock
				Inf "$cnt Soundfiles And [llength $outfiles] Datafiles Are On The Workspace"
				set finished 1
			}
			2 {
				SnackDisplay $evv(SN_TIMEPAIRS) rezig $evv(TIME_OUT) $fnam
			}
			0 {
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc ReZigRecalcLastTwoVals {} {
	global rezig evv
	set len [llength $rezig(zigzags)]
	incr len -3
	set rezig(zigzags) [lrange $rezig(zigzags) 0 $len]
	set up [lindex $rezig(zigzags) end]
	set dn 0
	set rezig(totlen) $rezig(lastlen)
	while {$rezig(totlen) < $rezig(subgoal)} {

		;#	DO ZAG

		set rezig(lastlen) $rezig(totlen)
		set thisrange [expr $up - $dn]
		set OK 0
		while {!$OK} {
			set len [expr rand() * $thisrange]
			if {$len > $rezig(dblsplice)} {		;#	Get next zag longer than splicelen
				set x [expr $up - $len]
				if {$x < $evv(REZIGERR)} {
					set x 0.0
				}
				set OK 1
			}
		}
		lappend rezig(zigzags) $x
		set dn $x							;#	Current position becomes lower limit for zig
		set up $rezig(range)
		set rezig(totlen) [expr $rezig(totlen) + $len - $rezig(splice)]	;#	Keep tally of total length attained. taking into account splicing

		;#	DO ZIG

		set thisrange [expr $up - $dn]
		set OK 0
		while {!$OK} {
			set len [expr rand() * $thisrange]
			if {$len > $rezig(dblsplice)} {		;#	Get next zig longer than splicelen
				set x [expr $dn + $len]
				set OK 1
			}
		}
		lappend rezig(zigzags) $x
		set up $x							;#	Current position becomes upper limit for zag
		set dn 0
		set rezig(totlen) [expr $rezig(totlen) + $len - $rezig(splice)]	;#	Keep tally of total length attained. taking into account splicing
	}
	set endstep [expr $rezig(range) - $x]							;#	Distance in src from end of last zig to end of entire zigzag range
	set remainder [expr $rezig(odur_inrange) - $rezig(totlen)]		;#	Remaining duration still to be generated
	set testlen [expr ($remainder - $endstep + (2 * $rezig(splice)))/2.0]
	if {($remainder < 0) || ($endstep > [expr $remainder + ($rezig(splice) * 2)]) \
	||  ($testlen < $rezig(dblsplice)) || ([expr $x - $testlen] <= $evv(REZIGERR))} {
		return 0
	}
	return 1	
}

proc RezigHelp {} {

	set msg "                              CREATE RELATED ZIGZAG FILES\n"
	append msg "\n"
	append msg "Create a set of zigzag-extended versions of a soundfile which are..\n"
	append msg "(1)  All different.\n"
	append msg "(2)  All of the same duration.\n"
	append msg "(If mixed together synced at their starts, they would all end in sync).\n"
	append msg "\n"
	append msg "Zigzag data files AND the zigzagged soundfiles are output.\n"
	append msg "\n"
	append msg "\"Required output duration\" is the total duration of each output sound.\n"
	append msg "\n"
	append msg "\"Splice length\" is the splice length in mS, used by the zigzag process.\n"
	append msg "\n"
	append msg "\"Min/Max time in src for direction changes\"\n"
	append msg "\n"
	append msg "The file is read from its start, forwards,\n"
	append msg "then, at the next specified time, the read direction is reversed,\n"
	append msg "and so on, and the back and forth reading continues\n"
	append msg "until the file end is reached.\n"
	append msg "The points in the file where the read-direction changes\n"
	append msg "will occur only in the region of the source defined by these limits,\n"
	append msg "(the \"read window\").\n"
	append msg "\n"
	append msg "These times can be entered from the \"Sound View\" window by\n"
	append msg "marking the defined area on the sound graphic, and outputting the data.\n"
	append msg "\n"
	append msg "\Min/Max zig length\"\n"
	append msg "are the minimum and maximum duration of any zig or zag\n"
	append msg "read from the src (apart from the initial and final reads).\n"
	append msg "\n"
	append msg "\"Seed value\"\n"
	append msg "Random lengths are used in generating the zigzags.\n"
	append msg "These will be IDENTICAL in a 2nd run if that run uses the SAME seed value.\n"
	append msg "\n"
	append msg "\"Generic outputfile name\"\n"
	append msg "is the common name given to all the data and sound output files.\n"
	append msg "Numbers are added to the name end, to differentiate different outputs.\n"
	append msg "Soundfile names correspond to datafile names.\n"
	append msg "\n"
	Inf $msg
}

proc StoreRezigPatch {} {
	global rezig pr_rezigstore evv wstk
	set newpatch [list $rezig(odur) $rezig(msspl) $rezig(cnt) $rezig(mintime) $rezig(maxtime) $rezig(min) $rezig(max) $rezig(seed) $rezig(ofnam)]
	set patchfile [file join $evv(URES_DIR) rezig$evv(CDP_EXT)]
	if {[file exists $patchfile] && ![info exists rezig(patches)]} {
		LoadRezigPatches
	}
	set f .rezigstore
	if [Dlg_Create $f "STORE ZIGZAG PATCH" "set pr_rezigstore 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0] 
		set f1 [frame $f.1] 
		set f2 [frame $f.2] 
		button $f0.ok -text "Save" -command "set pr_rezigstore 1" -bg $evv(EMPH)  -highlightbackground [option get . background {}]
		button $f0.del -text "Delete" -command "set pr_rezigstore 2"  -highlightbackground [option get . background {}]
		button $f0.quit -text "Abandon" -command "set pr_rezigstore 0"  -highlightbackground [option get . background {}]
		pack $f0.ok $f0.del -side left -pady 6
		pack $f0.quit -side right
		pack $f0 -side top -fill x -expand true
		label $f2.ll -text "Patch Name "
		entry $f2.nam -textvariable rezig(savpnam) -width 16
		pack $f2.ll $f2.nam -side left -pady 2
		pack $f2 -side top
		label $f1.tit -text "Select Patchname with mouse (below)" -fg $evv(SPECIAL)
		Scrolled_Listbox $f1.ll -width 60 -height 20 -selectmode single
		pack $f1.tit $f1.ll -side top -fill x -expand true -pady 2
		pack $f1 -side top -fill x -expand true
		bind $f1.ll.list <ButtonRelease-1> {RezigPatchGetSelect %y save}
		bind $f <Escape> {set pr_rezigstore 0}
		bind $f <Return> {set pr_rezigstore 1}
		wm resizable $f 0 0
	}
	set rezig(savpnam) ""
	$f.1.ll.list delete 0 end
	if {[info exists rezig(patches)]} {
		foreach patch $rezig(patches) {
			$f.1.ll.list insert end [lindex $patch 0]
		}
	}
	set pr_rezigstore 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_rezigstore $f.2.nam
	while {!$finished} {
		tkwait variable pr_rezigstore
		switch -- $pr_rezigstore {
			1 {
				if {[string length $rezig(savpnam)] <= 0} {
					Inf "No Patch Name Entered"
					continue
				}
				if {![ValidCDPRootname $rezig(savpnam)]} {
					continue
				}
				set rezig(savpnam) [string tolower $rezig(savpnam)]
				set OK 1
				if {[info exists rezig(patches)]} {
					foreach patch $rezig(patches) {
						if {[string match $rezig(savpnam) [lindex $patch 0]]} {
							Inf "Patch Name Already In Use"
							set OK 0
						}
					}
				}
				if {!$OK} {
					continue
				}
				set thispatch [concat $rezig(savpnam) $newpatch]
				lappend rezig(patches) $thispatch

				if [catch {open $patchfile "w"} zit] {
					Inf "Cannot Open File $patchfile To Write Rezig Patch Data"
					continue
				}
				foreach patch $rezig(patches) {
					puts $zit $patch
				}
				close $zit
				set finished 1
			}
			2 {
				if {![info exists rezig(patches)]} {
					Inf "No Existing Patches To Delete"
					continue
				}
				if {[string length $rezig(savpnam)] <= 0} {
					Inf "No Patch Name Entered"
					continue
				}
				if {![ValidCDPRootname $rezig(savpnam)]} {
					continue
				}
				set n 0
				set len [llength $rezig(patches)]
				foreach patch $rezig(patches) {
					if {[string match $rezig(savpnam) [lindex $patch 0]]} {
						break
					}
					incr n
				}
				if {$n == $len} {
					Inf "Patch $rezig(savpnam) Does Not Exist"
					continue
				} else {
					set msg "Are You Sure You Want To Delete Patch $rezig(savpnam) ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
					set rezig(patches) [lreplace $rezig(patches) $n $n]
					$f.1.ll.list delete $n
					if {[llength $rezig(patches)] <= 0} {
						catch {file delete $patchfile}
					} else {
						if [catch {open $patchfile "w"} zit] {
							Inf "Cannot Open File $patchfile To Write Revised Patch Data"
							continue
						}
						foreach patch $rezig(patches) {
							puts $zit $patch
						}
						close $zit
					}
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

proc RezigPatchGetSelect {y typ} {
	global rezig
	switch -- $typ {
		"save" {
			set i [.rezigstore.1.ll.list nearest $y]
			if {$i < 0} {
				return
			}
			set rezig(savpnam) [.rezigstore.1.ll.list get $i]
		}
		"get" {
			set i [.rezigget.1.ll.list nearest $y]
			if {$i < 0} {
				return
			}
			set rezig(getpnam) [.rezigget.1.ll.list get $i]
		}
	}
}

#---- Load patches for rezig

proc LoadRezigPatches {} {
	global rezig evv

	catch {unset rezig(patches)}
	set patchfile [file join $evv(URES_DIR) rezig$evv(CDP_EXT)]
	if {![file exists $patchfile]} {
		return 0
	}
	if [catch {open $patchfile "r"} zit] {
		Inf "Cannot Open File $patchfile To Read Existing Rezig Patches"
		return 0
	}
	set linecnt 1
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		catch {unset thispatch}
		set itemcnt 0
		set line [split $line]
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend thispatch $item
				incr itemcnt
			}
		}
		if {$itemcnt != 10} {
			Inf "Invalid Rezig Patch Data Encountered In File $patchfile At Line $linecnt"
			break
		}
		lappend rezig(patches) $thispatch
		incr linecnt
	}
	close $zit
	if {![info exists rezig(patches)]} {
		Inf "Failed To Load Any Rezig Patches"
		return 0
	}
	return 1
}

proc GetRezigPatch {} {
	global rezig pr_rezigget readonlyfg readonlybg evv wstk
	set patchfile [file join $evv(URES_DIR) rezig$evv(CDP_EXT)]
	if {[file exists $patchfile]} {
		if {![info exists rezig(patches)]} {
			if {![LoadRezigPatches]} {
				return
			}
		}
	} else {
		Inf "There Are No Existing Rezig Patches"
		return
	}
	set f .rezigget
	if [Dlg_Create $f "GET ZIGZAG PATCH" "set pr_rezigget 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0] 
		set f1 [frame $f.1] 
		set f2 [frame $f.2] 
		button $f0.ok -text "Get" -command "set pr_rezigget 1" -bg $evv(EMPH)  -highlightbackground [option get . background {}]
		button $f0.del -text "Delete" -command "set pr_rezigget 2"  -highlightbackground [option get . background {}]
		button $f0.quit -text "Abandon" -command "set pr_rezigget 0"  -highlightbackground [option get . background {}]
		pack $f0.ok $f0.del -side left -pady 6
		pack $f0.quit -side right
		pack $f0 -side top -fill x -expand true
		label $f2.ll -text "Patch Name "
		entry $f2.nam -textvariable rezig(getpnam) -width 16 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $f2.ll $f2.nam -side left -pady 2
		pack $f2 -side top
		label $f1.tit -text "Select Patchname with mouse (below)" -fg $evv(SPECIAL)
		Scrolled_Listbox $f1.ll -width 60 -height 20 -selectmode single
		pack $f1.tit $f1.ll -side top -fill x -expand true -pady 2
		pack $f1 -side top -fill x -expand true
		bind $f1.ll.list <ButtonRelease-1> {RezigPatchGetSelect %y get}
		bind $f <Escape> {set pr_rezigget 0}
		bind $f <Return> {set pr_rezigget 1}
		wm resizable $f 0 0
	}
	set rezig(getpnam) ""
	$f.1.ll.list delete 0 end
	if {[info exists rezig(patches)]} {
		foreach patch $rezig(patches) {
			$f.1.ll.list insert end [lindex $patch 0]
		}
	}
	set pr_rezigget 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_rezigget $f.2.nam
	while {!$finished} {
		tkwait variable pr_rezigget
		switch -- $pr_rezigget {
			1 {
				set i [.rezigget.1.ll.list curselection]
				if {$i < 0} {
					Inf "No Patch Selected"
					continue
				}
				set patch [lindex $rezig(patches) $i]
				set rezig(odur)    [lindex $patch 1]
				set rezig(msspl)   [lindex $patch 2]
				set rezig(cnt)     [lindex $patch 3]
				set rezig(mintime) [lindex $patch 4]
				set rezig(maxtime) [lindex $patch 5]
				set rezig(min)     [lindex $patch 6]
				set rezig(max)     [lindex $patch 7]
				set rezig(seed)    [lindex $patch 8]
				set rezig(ofnam)   [lindex $patch 9]
				set finished 1
			}
			2 {
				if {![info exists rezig(patches)]} {
					Inf "No Existing Patches To Delete"
					continue
				}
				if {[string length $rezig(getpnam)] <= 0} {
					Inf "No Patch Name Entered"
					continue
				}
				if {![ValidCDPRootname $rezig(getpnam)]} {
					continue
				}
				set n 0
				set len [llength $rezig(patches)]
				foreach patch $rezig(patches) {
					if {[string match $rezig(getpnam) [lindex $patch 0]]} {
						break
					}
					incr n
				}
				if {$n == $len} {
					Inf "Patch $rezig(getpnam) Does Not Exist"
					continue
				} else {
					set msg "Are You Sure You Want To Delete Patch $rezig(getpnam) ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
					set rezig(patches) [lreplace $rezig(patches) $n $n]
					$f.1.ll.list delete $n
					if {[llength $rezig(patches)] <= 0} {
						catch {file delete $patchfile}
					} else {
						if [catch {open $patchfile "w"} zit] {
							Inf "Cannot Open File $patchfile To Write Revised Patch Data"
							continue
						}
						foreach patch $rezig(patches) {
							puts $zit $patch
						}
						close $zit
					}
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

#---- Doppler pan a mono file acrtoss a pair of stereo lspkrs

proc DopplerPan {} {
	global wl chlist pr_doppler evv pa prg_dun prg_abortd simple_program_messages CDPidrun dopl

	set evv(DOPLMIN) 0.01

	if {[info exists chlist] && ([llength $chlist] == 1)} {
		set fnam $chlist
	} else {
		set ilist [$wl curselection]
		if {[llength $ilist] == 1} {
			if {$ilist != -1} {
				set fnam [$wl get $i]
			}
		}
	}
	if {![info exists fnam]} {
		Inf "Select One Mono Soundfile"
		return
	}
	if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) != 1)} {
		Inf "Select A Mono Soundfile"
		return
	}
	set endtime $pa($fnam,$evv(DUR))
	if {$endtime < $evv(DOPLMIN)} {
		Inf "Sound Too Short To Doppler-pan (Minimum $evv(DOPLMIN) secs)"
		return
	}
	set doplenvfnam $evv(DFLT_OUTNAME)
	append doplenvfnam 0 $evv(TEXT_EXT)

	set doplcrosfnam $evv(DFLT_OUTNAME)
	append doplcrosfnam 1 $evv(TEXT_EXT)

	set doplpanner $evv(DFLT_OUTNAME)
	append doplpanner 2 $evv(TEXT_EXT)

	set doplshiftfnam $evv(DFLT_OUTNAME)
	append doplshiftfnam 3 $evv(TEXT_EXT)

	set doplenveld $evv(DFLT_OUTNAME)
	append doplenveld 0 $evv(SNDFILE_EXT)

	set doplfiltd $evv(DFLT_OUTNAME)
	append doplfiltd 1 $evv(SNDFILE_EXT)

	set doplfiltdmx $evv(DFLT_OUTNAME)
	append doplfiltdmx 2 $evv(SNDFILE_EXT)

	set doplpand $evv(DFLT_OUTNAME)
	append doplpand 3 $evv(SNDFILE_EXT)

	set f .doppler
	if [Dlg_Create $f "CREATE DOPPLER PAN" "set pr_doppler 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0] 
		set f00 [frame $f.00] 
		set f1 [frame $f.1] 
		set f2 [frame $f.2] 
		set f3 [frame $f.3] 
		set f4 [frame $f.4] 
		set f5 [frame $f.5] 
		set f6 [frame $f.6] 
		set f7 [frame $f.7] 
		set f8 [frame $f.8] 
		button $f0.ok -text "Pan" -command "set pr_doppler 1" -bg $evv(EMPH)  -highlightbackground [option get . background {}]
		button $f0.sv -text "Sound View" -command "set pr_doppler 2" -bg $evv(SNCOLOR)  -highlightbackground [option get . background {}]
		button $f0.sav -text "Save Patch" -command "set pr_doppler 3"
		button $f0.lod -text "Load Patch" -command "LoadDopplerPatch"
		button $f0.quit -text "Quit" -command "set pr_doppler 0"  -highlightbackground [option get . background {}]
		pack $f0.ok $f0.sv $f0.sav $f0.lod -side left -pady 6 -padx 4
		pack $f0.quit -side right
		pack $f0 -side top -fill x -expand true

		radiobutton $f00.ll -text "Leftward" -width 12 -variable dopl(dir) -value -1
		radiobutton $f00.rr -text "Rightward" -width 12 -variable dopl(dir) -value 1
		radiobutton $f00.mm -text "Mono output" -width 12 -variable dopl(dir) -value 0
		set dopl(dir) -1
		pack $f00.ll $f00.rr $f00.mm -side left -padx 2
		pack $f00 -side top -fill x -expand true -pady 2

		label $f1.ll -text "Timing at centre-crossing (can mark on \"Sound View\")"
		entry $f1.e -textvariable dopl(time) -width 12
		pack $f1.e $f1.ll -side left -padx 2
		pack $f1 -side top -fill x -expand true -pady 2

		label $f2.ll -text "Time spent at centre (min $evv(DOPLMIN) secs)"
		entry $f2.e -textvariable dopl(dur) -width 12
		pack $f2.e $f2.ll -side left -padx 2
		pack $f2 -side top -fill x -expand true -pady 2

		label $f3.ll -text "Doppler shift (semitones : max 6)"
		entry $f3.e -textvariable dopl(shift) -width 12
		pack $f3.e $f3.ll -side left -padx 2
		pack $f3 -side top -fill x -expand true -pady 2

		label $f4.ll -text "Time spent doppler-shifting (min $evv(DOPLMIN) secs)"
		entry $f4.e -textvariable dopl(shdur) -width 12
		pack $f4.e $f4.ll -side left -padx 2
		pack $f4 -side top -fill x -expand true -pady 2

		label $f5.ll -text "Rise exponent on approach (Range 1-10) (0 = no envel/filter)"
		entry $f5.e -textvariable dopl(rise) -width 12
		pack $f5.e $f5.ll -side left -padx 2
		pack $f5 -side top -fill x -expand true -pady 2

		label $f6.ll -text "Decay exponent on departure (Range 1-10)"
		entry $f6.e -textvariable dopl(decay) -width 12
		pack $f6.e $f6.ll -side left -padx 2
		pack $f6 -side top -fill x -expand true -pady 2

		label $f7.ll -text "Frq of lopass distance filter (Range 50-5000 : 0 = no filtering)"
		entry $f7.e -textvariable dopl(stop) -width 12
		pack $f7.e $f7.ll -side left -padx 2
		pack $f7 -side top -fill x -expand true -pady 2

		label $f8.ll -text "Outputfile name"
		entry $f8.e -textvariable dopl(fnam) -width 20
		pack $f8.e $f8.ll -side left -padx 2
		pack $f8 -side top -pady 2

		bind $f <Escape> {set pr_doppler 0}
		bind $f <Return> {set pr_doppler 1}
		bind $f.1.e <Down> "focus $f.2.e"
		bind $f.2.e <Down> "focus $f.3.e"
		bind $f.3.e <Down> "focus $f.4.e"
		bind $f.4.e <Down> "focus $f.5.e"
		bind $f.5.e <Down> "focus $f.6.e"
		bind $f.6.e <Down> "focus $f.7.e"
		bind $f.7.e <Down> "focus $f.8.e"
		bind $f.8.e <Down> "focus $f.1.e"
		bind $f.1.e <Up> "focus $f.8.e"
		bind $f.2.e <Up> "focus $f.1.e"
		bind $f.3.e <Up> "focus $f.2.e"
		bind $f.4.e <Up> "focus $f.3.e"
		bind $f.5.e <Up> "focus $f.4.e"
		bind $f.6.e <Up> "focus $f.5.e"
		bind $f.7.e <Up> "focus $f.6.e"
		bind $f.8.e <Up> "focus $f.7.e"
		wm resizable $f 0 0
	}
	set pr_doppler 0
	set finished 0
	set dopl(fnam) [file rootname [file tail $fnam]]
	append dopl(fnam) "_dop"
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_doppler $f.1.e
	while {!$finished} {
		tkwait variable pr_doppler
		switch -- $pr_doppler {
			1 -
			3 {
				DeleteAllTemporaryFiles
				if {$pr_doppler == 1} {
					if {([string length $dopl(time)] <= 0) || ![IsNumeric $dopl(time)] || ($dopl(time) < 0.0) || ($dopl(time) >= $endtime)} {
						Inf "Invalid value for timing at centre-crossing"
						continue
					}
				}
				if {([string length $dopl(dur)] <= 0) || ![IsNumeric $dopl(dur)] || ($dopl(dur) < $evv(DOPLMIN)) || ($dopl(dur) > $endtime)} {
					Inf "Invalid Value For Time Spent At Centre"
					continue
				}
				set doplrisetime [expr $dopl(time) - ($dopl(dur)/2.0)]
				if {$doplrisetime < 0.0} {
					set doplrisetime 0.0
				}
				set doplfalltime [expr $endtime - ($doplrisetime + $dopl(dur))]
				if {([string length $dopl(shift)] <= 0) || ![IsNumeric $dopl(shift)] || ($dopl(shift) < 0.0) || ($dopl(shift) > 6.0)} {
					Inf "Invalid Value For Doppler Shift"
					continue
				}
				if {$dopl(shift) > 0.0} {
					set doplupshift [expr $dopl(shift)/2.0]
					set dopldnshift [expr -$doplupshift]
					set do_doppler 1
				} else {
					set do_doppler 0
				}

				if {([string length $dopl(shdur)] <= 0) || ![IsNumeric $dopl(shdur)] || ($dopl(shdur) < $evv(DOPLMIN)) || ($dopl(shdur) > $endtime)} {
					Inf "Invalid Value For Time Spent Doppler-shifting"
					continue
				}
				set doplshstart [expr $dopl(time) - ($dopl(shdur)/2.0)]
				if {$doplshstart  < 0.0} {
					set doplshstart 0.0
				}
				set doplshend [expr $doplshstart + $dopl(shdur)]

				if {([string length $dopl(rise)] <= 0) || ![IsNumeric $dopl(rise)]} {
					Inf "Invalid value for rise exponent on approach"
					continue
				}
				if {($dopl(rise) != 0) && (($dopl(rise) < 1.0) || ($dopl(rise) > 10.0))} {
					Inf "Invalid value for rise exponent on approach"
					continue
				}
				if {$dopl(rise) == 0} {
					set dopl(do_env) 0
					set dopl(decay) ""
					set dopl(stop) 0
				} else {
					set dopl(do_env) 1
				}
				if {$dopl(do_env)} {
					if {([string length $dopl(decay)] <= 0) || ![IsNumeric $dopl(decay)] || ($dopl(decay) < 1.0) || ($dopl(decay) > 10.0)} {
						Inf "Invalid value for decay exponent on departure"
						continue
					}
					if {([string length $dopl(stop)] <= 0) || ![IsNumeric $dopl(stop)]} {
						Inf "Invalid value for frq of lopass distance filter"
						continue
					}
				}
				if {$dopl(stop) == 0.0} {
					set do_filtering 0
				} else {
					if {($dopl(stop) < 50.0) || ($dopl(stop) > 5000.0)} {
						Inf "Invalid value for frq of lopass distance filter"
						continue
					}
					set do_filtering 1
					set doplpass [expr $dopl(stop)/2.0]
					set doplpass2 [expr $dopl(stop) - 100.0]
					if {$doplpass2 > $doplpass} {
						set doplpass $doplpass2
					}
				}
				if {[string length $dopl(fnam)] <= 0} {
					Inf "No output filename entered"
					continue
				}
				set outfnam [string tolower $dopl(fnam)]
				if {![ValidCDPRootname $outfnam]} {
					continue
				}
				if {$pr_doppler == 3} {
					set savelist [list $dopl(dir) $dopl(dur) $dopl(shift) $dopl(shdur) $dopl(rise)]
					if {$dopl(rise) > 0} {
						lappend savelist $dopl(decay) $dopl(stop)
					}
					set savefnam [file join $evv(URES_DIR) $outfnam]
					append savefnam ".dopl"
					if {[file exists $savefnam]} {
						set msg "File $savefnam already exists: overwrite it ??"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							continue
						} elseif [catch {file delete $savefnam} zit] {
							Inf "Cannot delete existing doppler data file $savefnam"
							continue
						}
					}
					if [catch {open $savefnam "w"} zit] {
						Inf "Cannot open doppler data file $savefnam to save patch data"
					} else {
						foreach item $savelist {
							puts $zit $item
						}
						close $zit
					}
					continue
				}
				append outfnam $evv(SNDFILE_EXT)
				if {[file exists $outfnam]} {
					Inf "File $outfnam Already Exists: Please Choose A Different Name"
					continue
				}
				Block "Creating Temporary Data Files"

				catch {unset lines}
				set now 0.0
				if {$dopl(do_env)} {
					while {$now < $doplrisetime} {
						set frac [expr $now/$doplrisetime]
						set frac [expr pow($frac,$dopl(rise))]
						set frac [NotExponential $frac]
						set line [list $now $frac]
						lappend lines $line
						set now [expr $now + 0.05]
					}
					set line [list $doplrisetime 1.0]
					lappend lines $line
					set now [expr $doplrisetime + $dopl(dur)]
					set line [list $now 1.0]
					lappend lines $line
					set now [expr $now + 0.05]
					set fadetime 0.05
					while {$fadetime < $doplfalltime} {
						set frac [expr ($doplfalltime - $fadetime)/$doplfalltime]
						set frac [expr pow($frac,$dopl(decay))]
						set frac [NotExponential $frac]
						set line [list $now $frac]
						lappend lines $line
						set now [expr $now + 0.05]
						set fadetime [expr $fadetime + 0.05]
					}
					if {$now < $endtime} {
						set line [list $endtime 0.0]
						lappend lines $line
					}
					if [catch {open $doplenvfnam "w"} zit] {
						Inf	"Cannot Open Temporary Envelope Data File $doplenvfnam"
						UnBlock
						continue
					}
					foreach line $lines {
						puts $zit $line
					}
					close $zit
				}

				if {$do_filtering} {
					catch {unset lines}
					set now 0.0
					while {$now < $doplrisetime} {
						set frac [expr $now/$doplrisetime]
						set frac [expr 1.0 - pow($frac,$dopl(rise))]
						set frac [NotExponential $frac]
						set line [list $now $frac]
						lappend lines $line
						set now [expr $now + 0.05]
					}
					set line [list $doplrisetime 0.0]
					lappend lines $line
					set now [expr $doplrisetime + $dopl(dur)]
					set line [list $now 0.0]
					lappend lines $line
					set now [expr $now + 0.05]
					set fadetime 0.05
					while {$fadetime < $doplfalltime} {
						set frac [expr ($doplfalltime - $fadetime)/$doplfalltime]
						set frac [expr 1.0 - pow($frac,$dopl(decay))]
						set frac [NotExponential $frac]
						set line [list $now $frac]
						lappend lines $line
						set now [expr $now + 0.05]
						set fadetime [expr $fadetime + 0.05]
					}
					if {$now < $endtime} {
						set line [list $endtime 1.0]
						lappend lines $line
					}

					if [catch {open $doplcrosfnam "w"} zit] {
						Inf	"Cannot Open Temporary Crossfade Data File $doplcrosfnam"
						UnBlock
						continue
					}
					foreach line $lines {
						puts $zit $line
					}
					close $zit
				}

				if {$dopl(dir) != 0} {
					if {$dopl(dir) > 0} {
						set mstart -1
						set mend 1
					} else {
						set mstart 1
						set mend -1
					}
					catch {unset lines}
					set line [list 0 $mstart]
					lappend lines $line
					set line [list $doplrisetime $mstart]
					lappend lines $line
					set line [list [expr $doplrisetime + $dopl(dur)] $mend]
					lappend lines $line
					set line [list $endtime $mend]
					lappend lines $line
					if [catch {open $doplpanner "w"} zit] {
						Inf	"Cannot Open Temporary Panning Data File $doplpanner"
						UnBlock
						continue
					}
					foreach line $lines {
						puts $zit $line
					}
					close $zit
				}

				if {$do_doppler} {
					catch {unset lines}
					set line [list 0 $doplupshift]
					lappend lines $line
					set line [list $doplshstart $doplupshift]
					lappend lines $line
					set line [list $doplshend $dopldnshift]
					lappend lines $line
					set line [list $endtime $dopldnshift]
					lappend lines $line

					if [catch {open $doplshiftfnam "w"} zit] {
						Inf	"Cannot Open Temporary Doppler Shift Data File $doplshiftfnam"
						UnBlock
						continue
					}
					foreach line $lines {
						puts $zit $line
					}
					close $zit
				}

				;#	DOING THE ENVELOPE

				if {$dopl(do_env)} {
					wm title .blocker "PLEASE WAIT:        ENVELOPING THE SOUND"

					set cmd [file join $evv(CDPROGRAM_DIR) envel]
					lappend cmd impose 3 $fnam $doplenvfnam $doplenveld
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					wm title .blocker "PLEASE WAIT:        ENVELOPING THE SOUND"
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "Cannot Create Enveloped Sndfile"
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
						set msg "Failed To Create Enveloped Soundfile"
						set msg [AddSimpleMessages $msg]
						Inf $msg
						catch {close $CDPidrun}
						UnBlock
						continue
					}
					if {![file exists $doplenveld]} {
						set msg " Creating Enveloped Soundfile Failed: "
						set msg [AddSimpleMessages $msg]
						Inf $msg
						catch {close $CDPidrun}
						UnBlock
						continue
					}
					catch {close $CDPidrun}
				} else {
					if [catch {file copy $fnam $doplenveld} zit] {
						Inf "Cannot copy source to file $doplenveld"
						UnBlock
						continue
					}
				}

				;#	DOING THE FILTERING

				if {$do_filtering} {
					set cmd [file join $evv(CDPROGRAM_DIR) filter]
					lappend cmd lohi 1 $doplenveld $doplfiltd -96 $doplpass $dopl(stop) -s.9
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					wm title .blocker "PLEASE WAIT:        FILTERING THE SOUND"
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "Cannot Create Filtered Sndfile"
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
						set msg "Failed To Create Filtered Soundfile"
						set msg [AddSimpleMessages $msg]
						Inf $msg
						catch {close $CDPidrun}
						UnBlock
						continue
					}
					if {![file exists $doplfiltd]} {
						set msg " Creating Filtered Soundfile Failed: "
						set msg [AddSimpleMessages $msg]
						Inf $msg
						catch {close $CDPidrun}
						UnBlock
						continue
					}
					catch {close $CDPidrun}

					;#	DOING THE FILTERMIX

					set cmd [file join $evv(CDPROGRAM_DIR) submix]
					lappend cmd balance $doplfiltd $doplenveld $doplfiltdmx -k$doplcrosfnam ;# -b0 -e$endtime
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					wm title .blocker "PLEASE WAIT:        MIXING WITH FILTERED SOUND"
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "Cannot Create Filtered Sndfile"
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
						set msg "Failed To Mix With Filtered Sound"
						set msg [AddSimpleMessages $msg]
						Inf $msg
						catch {close $CDPidrun}
						UnBlock
						continue
					}
					if {![file exists $doplfiltdmx]} {
						set msg " Mixing With Filtered Sound Failed: "
						set msg [AddSimpleMessages $msg]
						Inf $msg
						catch {close $CDPidrun}
						UnBlock
						continue
					}
					catch {close $CDPidrun}
				} else {
					if [catch {file rename $doplenveld $doplfiltdmx} zit] {
						Inf "Failed To Rename Temporary File $doplenveld To $doplfiltdmx"
						UnBlock
						continue
					}
				}


				if {$dopl(dir) != 0} {

					;#	DOING THE PANNING

					set cmd [file join $evv(CDPROGRAM_DIR) modify]
					lappend cmd space 1 $doplfiltdmx $doplpand $doplpanner -p.7
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					wm title .blocker "PLEASE WAIT:        PANNING THE SOUND SOUND"
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "Cannot Create Panned Sndfile"
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
						set msg "Failed To Create Panned Sndfile"
						set msg [AddSimpleMessages $msg]
						Inf $msg
						catch {close $CDPidrun}
						UnBlock
						continue
					}
					if {![file exists $doplpand]} {
						set msg " Creating Panned Sndfile Failed: "
						set msg [AddSimpleMessages $msg]
						Inf $msg
						catch {close $CDPidrun}
						UnBlock
						continue
					}
					catch {close $CDPidrun}
				} else {
					if [catch {file rename $doplfiltdmx $doplpand} zit] {
						Inf "Failed To Rename Temporary File $doplfiltdmx TO $doplpand"
						UnBlock
						continue
					}
				}

				;#	DOING THE DOPPLER SHIFT

				if {$do_doppler} {
					set cmd [file join $evv(CDPROGRAM_DIR) modify]
					lappend cmd speed 2 $doplpand $outfnam $doplshiftfnam
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					wm title .blocker "PLEASE WAIT:        DOPPLER-SHIFTING THE SOUND"
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "Cannot Create Doppler-shifted Sndfile"
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
						set msg "Failed To Create Doppler-shifted Sndfile"
						set msg [AddSimpleMessages $msg]
						Inf $msg
						catch {close $CDPidrun}
						UnBlock
						continue
					}
					if {![file exists $outfnam]} {
						set msg " Creating Doppler-shifted Sndfile Failed: "
						set msg [AddSimpleMessages $msg]
						Inf $msg
						catch {close $CDPidrun}
						UnBlock
						continue
					}
					catch {close $CDPidrun}
				} else {
					if [catch {file rename $doplpand $outfnam} zit] {
						Inf "Failed To Rename Temporary File $doplpand TO $outfnam"
						UnBlock
						continue
					}
				}
				FileToWkspace $outfnam 0 0 0 0 1
				Inf "File $outfnam Is On The Workspace"
				UnBlock
				set finished 1
			}
			2 {
				SnackDisplay $evv(SN_SINGLETIME) doppler $evv(TIME_OUT) $fnam
			}
			0 {
				set finished 1
			}
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}


proc LoadDopplerPatch {} {
	global evv pr_doplpatch dopl readonlyfg readonlybg
	catch {unset dopl(load)}
	foreach fnam [glob -nocomplain [file join $evv(URES_DIR) *]] {
		if {[string match [file extension $fnam] ".dopl"]} {
			lappend zfnams $fnam
		}
	}
	if {![info exists zfnams]} {
		Inf "No patches exist"
		return
	} elseif {[llength $zfnams] == 1} {
		set dopl(load) [lindex $zfnams 0]
	} else {
		set f .doplpatch
		if [Dlg_Create $f "DOPPLER PATCHES" "set pr_doplpatch 0" -borderwidth $evv(SBDR)] {
			set f0 [frame $f.0] 
			set f1 [frame $f.1] 
			set f2 [frame $f.2] 
			button $f0.ok -text "Select" -command "set pr_doplpatch 1" -bg $evv(EMPH)
			button $f0.del -text "Delete" -command "set pr_doplpatch 2"
			button $f0.quit -text "Abandon" -command "set pr_doplpatch 0"
			pack $f0.ok $f0.del -side left -pady 6
			pack $f0.quit -side right
			pack $f0 -side top -fill x -expand true
			label $f2.ll -text "Patch Name "
			entry $f2.nam -textvariable dopl(patchnam) -width 16 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
			pack $f2.ll $f2.nam -side left -pady 2
			pack $f2 -side top
			label $f1.tit -text "Select Patchname with mouse (below)" -fg $evv(SPECIAL)
			Scrolled_Listbox $f1.ll -width 60 -height 20 -selectmode single
			pack $f1.tit $f1.ll -side top -fill x -expand true -pady 2
			pack $f1 -side top -fill x -expand true
			bind $f1.ll.list <ButtonRelease-1> {DoplPatchSelect %y}
			bind $f <Escape> {set pr_doplpatch 0}
			bind $f <Return> {set pr_doplpatch 1}
			wm resizable $f 0 0
		}
		set dopl(patchnam) ""
		catch {unset patch_es}
		$f.1.ll.list delete 0 end
		if {[info exists zfnams]} {
			foreach patch $zfnams {
				lappend patch_es [file rootname [file tail $patch]]
			}
		}
		set patch_es [lsort -dictionary $patch_es]
		foreach patch $patch_es {
			$f.1.ll.list insert end $patch
		}
		set pr_doplpatch 0
		set finished 0
		raise $f
		update idletasks
		StandardPosition $f
		My_Grab 0 $f pr_doplpatch $f.2.nam
		while {!$finished} {
			tkwait variable pr_doplpatch
			switch -- $pr_doplpatch {
				1 {
					if {[string length $dopl(patchnam)] <= 0} {
						Inf "No patch selected"
						continue
					}
					set dopl(load) [file join $evv(URES_DIR) $dopl(patchnam)]
					append dopl(load) ".dopl"
					set finished 1
				}
				2 {
					set delfile [file join $evv(URES_DIR) $dopl(patchnam)]
					append delfile ".dopl"
					set msg "Are you sure you want to delete doppler patch $dopl(patchnam) ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					} elseif [catch {file delete $delfile} zit] {
						Inf "Cannot delete existing doppler patch $dopl(patchnam)"
						continue
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
	if {![info exists dopl(load)]} {
		Inf "No doppler patch selected"
		return
	}
	if [catch {open $dopl(load) "r"} zit] {
		Inf "Cannot open doppler patch file $dopl(load)"
		catch {unset dopl(load)}
		return
	}
	set linecnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		switch -- $linecnt {
			0 {
				set dopl(dir) $line
			}
			1 {
				set dopl(dur) $line
			}
			2 {
				set dopl(shift) $line
			}
			3 {
				set dopl(shdur) $line
			}
			4 {
				set dopl(rise) $line
				if {$dopl(rise) == 0.0} {
					break
				}
			}
			5 {
				set dopl(decay) $line
			}
			6 {
				set dopl(stop) $line
			}
			default {
				break
			}
		}
		incr linecnt
	}
	close $zit
}

proc DoplPatchSelect {y} {
	global dopl
	set i [.doplpatch.1.ll.list nearest $y]
	if {$i < 0} {
		return
	}
	set dopl(patchnam) [.doplpatch.1.ll.list get $i]
}

#---- Convert 7.03750878125e-005 TO 0.0000703750878125

proc NotExponential {val} {
	set k [string first "e" $val]
	if {$k > 0} {
		set kk [string range $val [expr $k + 2] end]
		set kk [StripLeadingZerosFromInteger $kk]
		set n 1
		set nuval "0."
		while {$n < $kk} {
			append nuval 0
			incr n
		}
		append nuval [string index $val 0]
		set kk 2
		while {$kk < $k} {
			append nuval [string index $val $kk]
			incr kk
		}
		set val $nuval
	}
	return $val
}

#------ Generate set of semitone transpositions

proc TransposSet {} {
	global chlist ch wl evv pa pr_transet transetfnam prg_dun prg_abortd simple_program_messages CDPidrun wstk

	if {[info exists chlist] && ([llength $chlist] == 1)} {
		set fnam $chlist
	} else {
		set i [$wl curselection]
		if {[llength $i] == 1} {
			if {$i != -1} {
				set fnam [$wl get $i]
			}
		}
	}
	if {![info exists fnam]} {
		Inf "Select One Mono Soundfile"
		return
	}
	if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) != 1)} {
		Inf "Select A Mono Soundfile"
		return
	}
	set transetsil $evv(DFLT_OUTNAME)
	append transetsil 0 $evv(SNDFILE_EXT)
	set transetlong $evv(DFLT_OUTNAME)
	append transetlong 1 $evv(SNDFILE_EXT)
	set transetspec $evv(DFLT_OUTNAME)
#RWD 2023 was ANALFILE_EXT, both cases
	append transetspec 2 $evv(ANALFILE_OUT_EXT)
	set transetspectrans $evv(DFLT_OUTNAME)
	append transetspectrans 3 $evv(ANALFILE_OUT_EXT)
	set transettrans $evv(DFLT_OUTNAME)
	append transettrans 4 $evv(SNDFILE_EXT)
	set f .transet
	if [Dlg_Create $f "CREATE TRANSPOSITION SET" "set pr_transet 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0] 
		set f1 [frame $f.1] 
		set f2 [frame $f.2] 
		label $f0.ll1 -text "Create set of upward and downward transpositions of the source" -fg $evv(SPECIAL)
		label $f0.ll2 -text "From 12 semitones down, to 12 semitones up" -fg $evv(SPECIAL)
		label $f0.ll3 -text "For use with \"iterate soundset on a pitchline\" process" -fg $evv(SPECIAL)
		pack $f0.ll1 $f0.ll2 $f0.ll3 -side top
		pack $f0 -side top -pady 2
		button $f1.ok -text "Create Files" -command "set pr_transet 1" -bg $evv(EMPH)  -highlightbackground [option get . background {}]
		button $f1.quit -text "Quit" -command "set pr_transet 0"  -highlightbackground [option get . background {}]
		pack $f1.ok -side left -pady 6
		pack $f1.quit -side right
		pack $f1 -side top -fill x -expand true

		label $f2.ll -text "Generic Name for Output Files"
		entry $f2.e -textvariable transetfnam -width 12
		pack $f2.e $f2.ll -side left -padx 2
		pack $f2 -side top -fill x -expand true -pady 2

		bind $f <Escape> {set pr_transet 0}
		bind $f <Return> {set pr_transet 1}
		wm resizable $f 0 0
	}
	set transetfnam [file rootname [file tail $fnam]]
	set pr_transet 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_transet $f.2.e
	while {!$finished} {
		tkwait variable pr_transet
		if {$pr_transet} {
			DeleteAllTemporaryFiles
			catch {unset outnams}
			if {[string length $transetfnam] <= 0} {
				Inf "No Output Filename Entered"
				continue
			}
			set outfnam [string tolower $transetfnam]
			if {![ValidCDPRootname $outfnam]} {
				continue
			}
			set extdn "dn"
			set extup "up"
			set transpos 12
			set n 0
			set OK 1
			while {$transpos > 0} {
				set outnam($n) $outfnam
				append outnam($n) $extdn $transpos $evv(SNDFILE_EXT)
				if {[file exists $outnam($n)]} {
					Inf "File $outnam($n) Already Exists: Please Choose A Different Generic Name"
					set OK 0
					break
				}
				incr transpos -1
				incr n
			}
			if {!$OK} {
				continue
			}
			set transpos 1
			while {$transpos <= 12} {
				set outnam($n) $outfnam
				append outnam($n) $extup $transpos $evv(SNDFILE_EXT)
				if {[file exists $outnam($n)]} {
					Inf "File $outnam($n) Already Exists: Please Choose A Different Generic Name"
					set OK 0
					break
				}
				incr transpos
				incr n
			}
			if {!$OK} {
				continue
			}

			Block "GENERATING SILENT EXTENSION FILE"

			;#	CREATE SILENCE EXTENSION FILE

			set cmd [file join $evv(CDPROGRAM_DIR) synth]
			lappend cmd silence $transetsil $pa($fnam,$evv(SRATE)) 1 0.2
			set prg_dun 0
			set prg_abortd 0
			catch {unset simple_program_messages}
			if [catch {open "|$cmd"} CDPidrun] {
				Inf "Cannot Create Silent Extension File"
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
				set msg "Failed To Generate Silent Extension File"
				set msg [AddSimpleMessages $msg]
				Inf $msg
				catch {close $CDPidrun}
				UnBlock
				continue
			}
			if {![file exists $transetsil]} {
				set msg " Generating Silent Extension File Failed: "
				set msg [AddSimpleMessages $msg]
				Inf $msg
				catch {close $CDPidrun}
				UnBlock
				continue
			}
			catch {close $CDPidrun}

			;#	EXTEND ORIGINAL FILE WITH SILENCE

			set cmd [file join $evv(CDPROGRAM_DIR) sfedit]
			lappend cmd join $fnam $transetsil $transetlong -w0.0
			set prg_dun 0
			set prg_abortd 0
			catch {unset simple_program_messages}
			wm title .blocker "PLEASE WAIT:        EXTENDING SOURCE FILE"
			if [catch {open "|$cmd"} CDPidrun] {
				Inf "Cannot Extend Source File"
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
				set msg "Failed To Extend Source File"
				set msg [AddSimpleMessages $msg]
				Inf $msg
				catch {close $CDPidrun}
				UnBlock
				continue
			}
			if {![file exists $transetlong]} {
				set msg " Extending Source File Failed: "
				set msg [AddSimpleMessages $msg]
				Inf $msg
				catch {close $CDPidrun}
				UnBlock
				continue
			}
			catch {close $CDPidrun}

			;#	ANALYSE

			set cmd [file join $evv(CDPROGRAM_DIR) pvoc]
			lappend cmd anal 1 $transetlong $transetspec -c1024 -o3
			set prg_dun 0
			set prg_abortd 0
			catch {unset simple_program_messages}
			wm title .blocker "PLEASE WAIT:        ANALYSING EXTENDED SOURCE FILE"
			if [catch {open "|$cmd"} CDPidrun] {
				Inf "Cannot Analyse Extended Source File"
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
				set msg "Failed To Analyse Extended Source File"
				set msg [AddSimpleMessages $msg]
				Inf $msg
				catch {close $CDPidrun}
				UnBlock
				continue
			}
			if {![file exists $transetspec]} {
				set msg " Analysing Extended Source File Failed: "
				set msg [AddSimpleMessages $msg]
				Inf $msg
				catch {close $CDPidrun}
				UnBlock
				continue
			}
			catch {close $CDPidrun}

			;#	FOR EACH REQUIRED TRANSPOSITION
			
			set OK 1
			set transpos -12
			set n 0
			while {$n < 24} {

				;#	TRANSPOSE SPECTRUM

				set cmd [file join $evv(CDPROGRAM_DIR) repitch]
				lappend cmd transposef 3 $transetspec $transetspectrans -p4 $transpos -l5.0 -h$pa($fnam,$evv(NYQUIST))
				set prg_dun 0
				set prg_abortd 0
				catch {unset simple_program_messages}
				wm title .blocker "PLEASE WAIT:        TRANSPOSING SPECTRUM BY $transpos SEMITONES"
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "Cannot Transposing Spectrum By $transpos Semitones"
					catch {close $CDPidrun}
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
					set msg "Failed To Transpose Spectrum By $transpos Semitones"
					set msg [AddSimpleMessages $msg]
					Inf $msg
					catch {close $CDPidrun}
					set OK 0
					break
				}
				if {![file exists $transetspectrans]} {
					set msg "Transposing Spectrum By $transpos Semitones Failed: "
					set msg [AddSimpleMessages $msg]
					Inf $msg
					catch {close $CDPidrun}
					set OK 0
					break
				}
				catch {close $CDPidrun}

				;#	SYNTHESIZE

				set cmd [file join $evv(CDPROGRAM_DIR) pvoc]
				lappend cmd synth $transetspectrans $transettrans
				set prg_dun 0
				set prg_abortd 0
				catch {unset simple_program_messages}
				wm title .blocker "PLEASE WAIT:        RESYNTHESIZING SOUND TRANSPOSED BY $transpos SEMITONES"
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "Cannot Resynthesize Sound Transposed By $transpos Semitones"
					catch {close $CDPidrun}
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
					set msg "Failed To Resynthesize Sound Transposed By $transpos Semitones"
					set msg [AddSimpleMessages $msg]
					Inf $msg
					catch {close $CDPidrun}
					set OK 0
					break
				}
				if {![file exists $transettrans]} {
					set msg "Resynthesizing Sound Transposed By $transpos Semitones Failed: "
					set msg [AddSimpleMessages $msg]
					Inf $msg
					catch {close $CDPidrun}
					set OK 0
					break
				}
				catch {close $CDPidrun}

				;#	TOP AND TAIL

				set cmd [file join $evv(CDPROGRAM_DIR) housekeep]
				lappend cmd extract 3 $transettrans $outnam($n)
				set prg_dun 0
				set prg_abortd 0
				catch {unset simple_program_messages}
				wm title .blocker "PLEASE WAIT:        TRIMMING SOUND TRANSPOSED BY $transpos SEMITONES"
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "Cannot Trim Sound Transposed By $transpos Semitones"
					catch {close $CDPidrun}
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
					set msg "Failed To Trim Sound Transposed By $transpos Semitones"
					set msg [AddSimpleMessages $msg]
					Inf $msg
					catch {close $CDPidrun}
					set OK 0
					break
				}
				if {![file exists $outnam($n)]} {
					set msg "Trimming  Sound Transposed By $transpos Semitones Failed: "
					set msg [AddSimpleMessages $msg]
					Inf $msg
					catch {close $CDPidrun}
					set OK 0
					break
				}
				catch {close $CDPidrun}
				catch {file delete $transetspectrans}
				catch {file delete $transettrans}
				lappend outnams $outnam($n)
				incr transpos
				if {$transpos == 0} {
					incr transpos
				}
				incr n
			}
			if {[info exists outnams]} {
				set outnams [ReverseList $outnams]
				foreach out_fnam $outnams {
					FileToWkspace $out_fnam 0 0 0 0 1
				}
			}
			UnBlock
			if {!$OK} {
				if {[info exists outnams]} {
					Inf "Some Files Created And Placed On Workspace: But Process Terminated Before Completion"
					break
				} else {
					Inf "No Files Have Been Created"
					continue
				}
			} else {
				set msg "Files Created Are On The Workspace: Put Transpose Set On Chosen List ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "yes"} {
					set outnams [ReverseList $outnams]
					set outnams [linsert $outnams 12 $fnam]
					DoChoiceBak
					set chlist $outnams
					$ch delete 0 end
					foreach item $chlist {
						$ch insert end $item
					}		
				}
				set finished 1
			}
		} else {
			set finished 1
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

	
#####################################################
# CREATE LARGE NUMBER OF VARIANTS ON INPUT SPECTRUM #
#####################################################

#---- Help for Varibox

proc VarispecHelp {} {
	set msg "                                                                     VARISPEC\n"	
	append msg "\n"
	append msg "Generate a large number of variants of a source spectrum.\n"
	append msg "(Best applied to a sound with a characteristic attack-resonance contour, as this is what will be preserved).\n"
	append msg "\n"
	append msg "(Once you have generated outputs, the \"Play Sample\" button appears and will play a sample-texture made from the outputs).\n" 
	append msg "\n"
	append msg "Variants are made through spectral stretch, squeeze and pivot.\n"
	append msg "\n"
	append msg "Paramters are selected at random from given ranges.\n"
	append msg "\n"
	append msg "There are 4 types of processing\n"
	append msg "\n"
	append msg "(1) SQUEEZE SPECTRUM: squeezes spectrum around a frequency, can produce large transpositions up or down (give frq limits).\n"
	append msg "(2) STRETCH SPECTRUM: stretches the entire spectrum upwards (8 variants).\n"
	append msg "(3) PIVOT SPECTRUM:   pivots spectrum about a given frequency.\n"
	append msg "(4) STRETCH TIME:     stretches tail of sound after (specified) attack-time.\n"
	append msg "\n"
	Inf $msg
}

proc Varispec {} {
	global vspec pr_vspec chlist pa evv mix_perm last_outfile
	global maxsamp_line done_maxsamp CDPmaxId prg_dun prg_abortd simple_program_messages CDPidrun

	if {![info exists chlist] || ([llength $chlist] != 1)} {
		Inf "Choose One Analysis File"
		return
	}
	set vspec(ifnam) [lindex $chlist 0]
	if {$pa($vspec(ifnam),$evv(FTYP)) != $evv(ANALFILE)} {
		Inf "Choose One Analysis File"
		return
	}
	set dur $pa($vspec(ifnam),$evv(DUR))
	set durlim [expr $dur - 0.04]
	set f .varispec
	if [Dlg_Create $f "VARISPEC" "set pr_vspec 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		frame $f.1
		frame $f.2
		frame $f.3
		frame $f.4
		frame $f.5
		frame $f.6
		frame $f.7
		button $f.0.hh -text Help -command VarispecHelp -bg $evv(HELP)  -highlightbackground [option get . background {}]
		button $f.0.sv -text SoundView -command "SnackDisplay $evv(SN_SINGLETIME) .varispec.6.e $evv(TIME_OUT) 1" -bg $evv(SNCOLOR)  -highlightbackground [option get . background {}]
		button $f.0.ok -text "Make Variants" -command "set pr_vspec 1"  -highlightbackground [option get . background {}]
		button $f.0.qq -text "Quit" -command "set pr_vspec 0"  -highlightbackground [option get . background {}]
		pack $f.0.hh $f.0.sv $f.0.ok -side left -padx 2
		pack $f.0.qq -side right
		pack $f.0 -side top -pady 2 -fill x -expand true
		label $f.1.ll1 -text "No of stretches"
		entry $f.1.e1 -textvariable vspec(strcnt) -width 8
		label $f.1.ll2 -text "squeezes"
		entry $f.1.e2 -textvariable vspec(sqzcnt) -width 8
		label $f.1.ll3 -text "pivots"
		entry $f.1.e3 -textvariable vspec(pivcnt) -width 8
		label $f.1.ll4 -text "time-stretches"
		entry $f.1.e4 -textvariable vspec(timcnt) -width 8
		pack $f.1.ll1 $f.1.e1 $f.1.ll2 $f.1.e2 $f.1.ll3 $f.1.e3 $f.1.ll4 $f.1.e4 -side left -padx 2
		pack $f.1 -side top -pady 2 -fill x -expand true
		label $f.11 -text "(If ONLY ONE of a variant is specified, its min-value is ignored)" -foreground $evv(SPECIAL)
		pack $f.11 -side top -pady 2
		label $f.2.ll -text "MIN"
		entry $f.2.e -textvariable vspec(sqz_lolim) -width 8
		label $f.2.ll2 -text "MAX"
		entry $f.2.e2 -textvariable vspec(sqz_hilim) -width 8
		label $f.2.ll3 -text "sqeeze-around frq (Range 55-11000)"
		pack $f.2.e $f.2.ll $f.2.e2 $f.2.ll2 $f.2.ll3 -side left -padx 2
		pack $f.2 -side top -pady 2 -fill x -expand true
		label $f.3.ll -text "MIN"
		entry $f.3.e -textvariable vspec(piv_lolim) -width 8
		label $f.3.ll2 -text "MAX"
		entry $f.3.e2 -textvariable vspec(piv_hilim) -width 8
		label $f.3.ll3 -text "pivot frq (Range 200-3200)"
		pack $f.3.e $f.3.ll $f.3.e2 $f.3.ll2 $f.3.ll3 -side left -padx 2
		pack $f.3 -side top -pady 2 -fill x -expand true
		label $f.4.ll -text "MIN"
		entry $f.4.e -textvariable vspec(str_lolim) -width 8
		label $f.4.ll2 -text "MAX"
		entry $f.4.e2 -textvariable vspec(str_hilim) -width 8
		label $f.4.ll3 -text "spectral stretch (Range 1 - 8)"
		pack $f.4.e $f.4.ll $f.4.e2 $f.4.ll2 $f.4.ll3 -side left -padx 2
		pack $f.4 -side top -pady 2 -fill x -expand true
		label $f.5.ll -text "MIN"
		entry $f.5.e -textvariable vspec(tim_lolim) -width 8
		label $f.5.ll2 -text "MAX"
		entry $f.5.e2 -textvariable vspec(tim_hilim) -width 8
		label $f.5.ll3 -text "time stretch (Range 1 - 8)"
		pack $f.5.e $f.5.ll $f.5.e2 $f.5.ll2 $f.5.ll3 -side left -padx 2
		pack $f.5 -side top -pady 2 -fill x -expand true
		label $f.6.ll -text "Attack-time in source"
		entry $f.6.e -textvariable vspec(atk_time) -width 8
		pack $f.6.e $f.6.ll -side left -padx 2
		pack $f.6 -side top -pady 2 -fill x -expand true
		label $f.7.ll -text "Output files generic name "
		entry $f.7.e -textvariable vspec(ofnam) -width 20
		pack $f.7.e $f.7.ll -side left -padx 2
		pack $f.7 -side top -pady 2
		bind	$f.1.e1 <Right> {focus .varispec.1.e2}
		bind	$f.1.e2 <Right> {focus .varispec.1.e3}
		bind	$f.1.e3 <Right> {focus .varispec.1.e4}
		bind	$f.1.e4 <Right> {focus .varispec.1.e1}
		bind	$f.1.e1 <Left> {focus .varispec.1.e4}
		bind	$f.1.e2 <Left> {focus .varispec.1.e1}
		bind	$f.1.e3 <Left> {focus .varispec.1.e2}
		bind	$f.1.e4 <Left> {focus .varispec.1.e3}

		bind	$f.1.e1 <Down> {focus .varispec.2.e}
		bind	$f.1.e2 <Down> {focus .varispec.2.e}
		bind	$f.1.e3 <Down> {focus .varispec.2.e}
		bind	$f.1.e4 <Down> {focus .varispec.2.e}

		bind	$f.1.e1 <Up> {focus .varispec.7.e}
		bind	$f.1.e2 <Up> {focus .varispec.7.e}
		bind	$f.1.e3 <Up> {focus .varispec.7.e}
		bind	$f.1.e4 <Up> {focus .varispec.7.e}

		bind	$f.2.e <Right> {focus .varispec.2.e2}
		bind	$f.2.e <Left>  {focus .varispec.2.e2}
		bind	$f.2.e <Down>  {focus .varispec.3.e}
		bind	$f.2.e <Up>  {focus .varispec.1.e1}

		bind	$f.3.e <Right> {focus .varispec.3.e2}
		bind	$f.3.e <Left>  {focus .varispec.3.e2}
		bind	$f.3.e <Down>  {focus .varispec.4.e}
		bind	$f.3.e <Up>  {focus .varispec.2.e}

		bind	$f.4.e <Right> {focus .varispec.4.e2}
		bind	$f.4.e <Left>  {focus .varispec.4.e2}
		bind	$f.4.e <Down>  {focus .varispec.5.e}
		bind	$f.4.e <Up>  {focus .varispec.3.e}

		bind	$f.5.e <Right> {focus .varispec.5.e2}
		bind	$f.5.e <Left>  {focus .varispec.5.e2}
		bind	$f.5.e <Down>  {focus .varispec.6.e}
		bind	$f.5.e <Up>	 {focus .varispec.4.e}

		bind	$f.2.e2 <Right> {focus .varispec.2.e}
		bind	$f.2.e2 <Left>  {focus .varispec.2.e}
		bind	$f.2.e2 <Down>  {focus .varispec.3.e2}
		bind	$f.2.e2 <Up>  {focus .varispec.1.e2}

		bind	$f.3.e2 <Right> {focus .varispec.3.e}
		bind	$f.3.e2 <Left>  {focus .varispec.3.e}
		bind	$f.3.e2 <Down>  {focus .varispec.4.e2}
		bind	$f.3.e2 <Up>  {focus .varispec.2.e2}

		bind	$f.4.e2 <Right> {focus .varispec.4.e}
		bind	$f.4.e2 <Left>  {focus .varispec.4.e}
		bind	$f.4.e2 <Down>  {focus .varispec.5.e2}
		bind	$f.4.e2 <Up>  {focus .varispec.3.e2}

		bind	$f.5.e2 <Right> {focus .varispec.5.e}
		bind	$f.5.e2 <Left>  {focus .varispec.5.e}
		bind	$f.5.e2 <Down>  {focus .varispec.6.e}
		bind	$f.5.e2 <Up>	 {focus .varispec.4.e2}

		bind	$f.6.e <Down>  {focus .varispec.7.e}
		bind	$f.6.e <Up>	 {focus .varispec.5.e}

		bind	$f.7.e <Down>  {focus .varispec.1.e1}
		bind	$f.7.e <Up>	 {focus .varispec.6.e}

		bind $f <Escape> {set pr_vspec 0}
		bind $f <Return> {set pr_vspec 1}
		wm resizable $f 0 0
	}
	set vspec(atk_time) ""
	set pr_vspec 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_vspec $f.1.e1
	while {!$finished} {
		tkwait variable pr_vspec
		if {$pr_vspec} {
			if {[string length $vspec(strcnt)] <= 0} {
				Inf "Number Of Stretch Variants Not Entered"
				continue
			}
			if {![IsNumeric $vspec(strcnt)] || ![regexp {^[0-9]+$} $vspec(strcnt)] || ($vspec(strcnt) < 0)} {
				Inf "Invalid Number Of Stretch Variants Entered"
				continue
			}
			if {[string length $vspec(sqzcnt)] <= 0} {
				Inf "Number Of Squeeze Variants Not Entered"
				continue
			}
			if {![IsNumeric $vspec(sqzcnt)] || ![regexp {^[0-9]+$} $vspec(sqzcnt)] || ($vspec(sqzcnt) < 0)} {
				Inf "Invalid Number Of Squeeze Variants Entered"
				continue
			}
			if {[string length $vspec(pivcnt)] <= 0} {
				Inf "Number Of Pivot Variants Not Entered"
				continue
			}
			if {![IsNumeric $vspec(pivcnt)] || ![regexp {^[0-9]+$} $vspec(pivcnt)] || ($vspec(pivcnt) < 0)} {
				Inf "Invalid Number Of Pivot Variants Entered"
				continue
			}
			if {[string length $vspec(timcnt)] <= 0} {
				Inf "Number Of Time-stretch Variants Not Entered"
				continue
			}
			if {![IsNumeric $vspec(timcnt)] || ![regexp {^[0-9]+$} $vspec(timcnt)] || ($vspec(timcnt) < 0)} {
				Inf "Invalid Number Of Time-stretch Variants Entered"
				continue
			}
			set varcnt  [expr $vspec(strcnt) + $vspec(sqzcnt) + $vspec(pivcnt)]
			if {$varcnt <= 0} {
				Inf "No Variants (apart From Time-stretches) Specified"
				continue
			}
			if {$vspec(timcnt) > 0} {
				if {[string length $vspec(atk_time)] <= 0} {
					Inf "No Attack-time Entered (needed If Time-stretching Used)"
					continue
				}
				if {![IsNumeric $vspec(atk_time)] || ($vspec(atk_time) < 0.0) || ($vspec(atk_time) >= $durlim)} {
					Inf "Invalid Attack-time : Cannot Be Beyond 40ms From End Of Source"
					continue
				}
				set varcnt [expr $varcnt * (1 + $vspec(timcnt))]	;#	Add an extra variant for every time-stretch value
			}
			if {$vspec(sqzcnt) > 0} {
				if {[string length $vspec(sqz_hilim)] <= 0} {
					Inf "Max Squeeze-around Frq Not Entered"
					continue
				}
				if {![IsNumeric $vspec(sqz_hilim)] || ($vspec(sqz_hilim) < 55) || ($vspec(sqz_hilim) > 11000)} {
					Inf "Invalid Max Squeeze-around Frq (range 55 - 11000)"
					continue
				}
				if {$vspec(sqzcnt) > 1} {
					if {[string length $vspec(sqz_lolim)] <= 0} {
						Inf "Min Squeeze-around Frq Not Entered"
						continue
					}
					if {![IsNumeric $vspec(sqz_lolim)] || ($vspec(sqz_lolim) < 55) || ($vspec(sqz_lolim) > 11000)} {
						Inf "Invalid Min Squeeze-around Frq (range 55 - 11000)"
						continue
					}
					if {$vspec(sqz_hilim) <= $vspec(sqz_lolim)} {
						Inf "Incompatible Min And Max Frequencies For Squeeze-around Frq"
						continue
					}
				}
			}
			if {$vspec(pivcnt) > 0} {
				if {[string length $vspec(piv_hilim)] <= 0} {
					Inf "Max Pivot Frq Not Entered"
					continue
				}
				if {![IsNumeric $vspec(piv_hilim)] || ($vspec(piv_hilim) < 200) || ($vspec(piv_hilim) > 3200)} {
					Inf "Invalid Max Pivot Frq (range 55 - 11000)"
					continue
				}
				if {$vspec(pivcnt) > 1} {
					if {[string length $vspec(piv_lolim)] <= 0} {
						Inf "Min Pivot Frq Not Entered"
						continue
					}
					if {![IsNumeric $vspec(piv_lolim)] || ($vspec(piv_lolim) < 200) || ($vspec(piv_lolim) > 3200)} {
						Inf "Invalid Min Pivot Frq (range 200 - 3200)"
						continue
					}
					if {$vspec(piv_hilim) <= $vspec(piv_lolim)} {
						Inf "Incompatible Min And Max Frequencies For Pivot Frq"
						continue
					}
				}
			}
			if {$vspec(strcnt) > 0} {
				if {[string length $vspec(str_hilim)] <= 0} {
					Inf "Max Spectral Stretch Not Entered"
					continue
				}
				if {![IsNumeric $vspec(str_hilim)] || ($vspec(str_hilim) <= 1) || ($vspec(str_hilim) > 8)} {
					Inf "Invalid Max Spectral Stretch (range >1 - 8)"
					continue
				}
				if {$vspec(strcnt) > 1} {
					if {[string length $vspec(str_lolim)] <= 0} {
						Inf "Min Spectral Stretch Not Entered"
						continue
					}
					if {![IsNumeric $vspec(str_lolim)] || ($vspec(str_lolim) <= 1) || ($vspec(str_lolim) > 8)} {
						Inf "Invalid Min Spectral Stretch (range >1 - 8)"
						continue
					}
					if {$vspec(str_hilim) <= $vspec(str_lolim)} {
						Inf "Incompatible Min And Max Values For Spectral Stretch"
						continue
					}
				}
			}
			if {$vspec(timcnt) > 0} {
				if {[string length $vspec(tim_hilim)] <= 0} {
					Inf "Max Time Stretch Not Entered"
					continue
				}
				if {![IsNumeric $vspec(tim_hilim)] || ($vspec(tim_hilim) < 1) || ($vspec(tim_hilim) > 8)} {
					Inf "Invalid Max Time Stretch (range 1 - 8)"
					continue
				}
				if {$vspec(timcnt) > 1} {
					if {[string length $vspec(tim_lolim)] <= 0} {
						Inf "Min Time Stretch Frq Not Entered"
						continue
					}
					if {![IsNumeric $vspec(tim_lolim)] || ($vspec(tim_lolim) < 1) || ($vspec(tim_lolim) > 8)} {
						Inf "Invalid Min Time Stretch (range 1 - 8)"
						continue
					}
					if {$vspec(tim_hilim) < $vspec(tim_lolim)} {
						Inf "Incompatible Min And Max Values For Time Stretch"
						continue
					}
				}
			}
			if {[string length $vspec(ofnam)] <= 0} {
				Inf "No Generic Output Filename Entered"
				continue
			}
			set fnambas [string tolower $vspec(ofnam)]
			if {![ValidCDPRootname $fnambas]} {
				continue
			}
			Block "CHECKING OUTPUT FILE NAMES"	
			set OK 1
			set n 1
			catch {unset ofnams}
			while {$n <= $varcnt} {
				set ofnam $fnambas
				append ofnam $n $evv(SNDFILE_EXT)
				if {[file exists $ofnam]} {
					Inf "File $ofnam Already Exists : Please Choose A Different Generic Name"
					set OK 0
					break
				}
				lappend ofnams $ofnam
				incr n
			}
			if {!$OK} {
				UnBlock
				continue
			}
			wm title .blocker "PLEASE WAIT:        ESTABLISHING WARP PARAMETERS"
			if {$vspec(pivcnt) > 0} {
				if {$vspec(pivcnt) == 1} {
					set pivfrqs $vspec(piv_hilim)
				} else {
					set lolim [HzToMidi $vspec(piv_lolim)]
					set hilim [HzToMidi $vspec(piv_hilim)]
					set n 0
					set diff [expr $hilim - $lolim]
					set step [expr $diff/double($vspec(pivcnt) - 1)]
					set sum $lolim
					while {$n < $vspec(pivcnt)} {
						lappend pivfrqs [MidiToHz $sum]
						set sum [expr $sum + $step]
						incr n
					}
				}
			}
			catch {unset sqzfrqs}
			if {$vspec(sqzcnt) > 0} {
				if {$vspec(sqzcnt) == 1} {
					set sqzfrqs $vspec(sqz_hilim)
				} else {
					set lolim [HzToMidi $vspec(sqz_lolim)]
					set hilim [HzToMidi $vspec(sqz_hilim)]
					set n 0
					set diff [expr $hilim - $lolim]
					set step [expr $diff/double($vspec(sqzcnt) - 1)]
					set sum $lolim
					while {$n < $vspec(sqzcnt)} {
						lappend sqzfrqs [MidiToHz $sum]
						set sum [expr $sum + $step]
						incr n
					}
				}
			}
			catch {unset strvals}
			if {$vspec(strcnt) > 0} {
				if {$vspec(strcnt) == 1} {
					set strvals $vspec(str_hilim)
				} else {
					set lolim $vspec(str_lolim)
					set hilim $vspec(str_hilim)
					set n 0
					set diff [expr $hilim - $lolim]
					set step [expr $diff/double($vspec(strcnt) - 1)]
					set sum $lolim
					while {$n < $vspec(strcnt)} {
						lappend strvals $sum
						set sum [expr $sum + $step]
						incr n
					}
				}
			}
			catch {unset timvals}
			if {$vspec(timcnt) > 0} {
				set OK 1
				if {$vspec(timcnt) == 1} {
					set timvals $vspec(tim_hilim)
				} else {
					set lolim $vspec(tim_lolim)
					set hilim $vspec(tim_hilim)
					set n 0
					set diff [expr $hilim - $lolim]
					set step [expr $diff/double($vspec(timcnt) - 1)]
					set sum $lolim
					while {$n < $vspec(timcnt)} {
						lappend timvals $sum
						set sum [expr $sum + $step]
						incr n
					}
				}
				set origtimvals $timvals
				if {$vspec(atk_time) > 0.0} {
					catch {unset nutimvals}
					set atk [expr $vspec(atk_time) + 0.02]
					set lim [expr $atk + 0.02]
					if {$lim >= $dur} {
						set brkend [expr $lim + 0.02]
					} else {
						set brkend [expr $dur + 0.02]
					}
					set subcnt 0
					foreach val $timvals {
						
						if {[Flteq $val 1.0]} {
							lappend nutimvals $val		;#	IF NO STRETCH: DON'T MAKE BRKPOINT FILE!!
							continue
						}

						;#	GENERATE BRKPNT FILES FOR TSTRETCH

						catch {unset lines}
						set line [list 0.0 1]
						lappend lines $line
						set line [list $atk 1]
						lappend lines $line
						set line [list $lim $val]
						lappend lines $line
						set line [list $brkend $val]
						lappend lines $line

						set outfnam $evv(DFLT_OUTNAME)
						append outfnam $subcnt $evv(TEXT_EXT)
						if [catch {open $outfnam "w"} zit] {
							Inf "Cannot Open Temporary Textfile $outfnam To Store Timestretch Data $val : $zit"
							set OK 0
							break
						}
						foreach line $lines {
							puts $zit $line
						}
						close $zit
						lappend nutimvals $outfnam
						incr subcnt
					}
					if {!$OK} {
						UnBlock
						continue
					}
					set timvals $nutimvals
				}
			}
			set cnt 0
			catch {unset outnames}
			if {[info exists pivfrqs]} {

				;#	DO FREQUENCY PIVOTS

				foreach frq $pivfrqs {
					set outfnam $evv(DFLT_OUTNAME)
#  RWD 2023 was ANALFILE_EXT
					append outfnam $cnt $evv(ANALFILE_OUT_EXT)
					incr cnt
					set cmd [file join $evv(CDPROGRAM_DIR) specnu]
					lappend cmd slice 5 $vspec(ifnam) $outfnam $frq

					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					wm title .blocker "PLEASE WAIT:        PIVOTING SPECTRUM AROUND $frq"
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "Cannot Pivot Spectrum  Around $frq"
						catch {close $CDPidrun}
						set OK 0
						continue
					} else {
						fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
					}
					vwait prg_dun
					if {$prg_abortd} {
						set prg_dun 0
					}
					if {!$prg_dun || ![file exists $outfnam]} {
						set msg "Failed To Pivot Spectrum Around $frq"
						set msg [AddSimpleMessages $msg]
						Inf $msg
						catch {close $CDPidrun}
						set OK 0
						continue
					}
					lappend outnames $outfnam
				}
			}
			if {[info exists strvals]} {

				;#	DO SPECTRAL STRETCHES

				foreach val $strvals {
					set outfnam $evv(DFLT_OUTNAME)
#RWD 2023 was ANALFILE_EXT
					append outfnam $cnt $evv(ANALFILE_OUT_EXT)
					incr cnt
					set cmd [file join $evv(CDPROGRAM_DIR) stretch]
					lappend cmd spectrum 1 $vspec(ifnam) $outfnam 5 $val .7

					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					wm title .blocker "PLEASE WAIT:        STRETCHING SPECTRUM BY $val"
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "Cannot Stretch Spectrum By $val"
						catch {close $CDPidrun}
						set OK 0
						continue
					} else {
						fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
					}
					vwait prg_dun
					if {$prg_abortd} {
						set prg_dun 0
					}
					if {!$prg_dun || ![file exists $outfnam]} {
						set msg "Failed To Stretch Spectrum By $val"
						set msg [AddSimpleMessages $msg]
						Inf $msg
						catch {close $CDPidrun}
						set OK 0
						continue
					}
					lappend outnames $outfnam
				}
			}
			if {[info exists sqzfrqs]} {
				set subcnt 0
				set i 0
				while {$i < 4} {
					set mix_perm($i) $i
					incr i
				}
				;#	DO SPECTRAL SQUEEZES

				foreach frq $sqzfrqs {
	
					;#	RANDOM PERMUTE SQUEEZING VALUES

					if {$subcnt == 0} {
						RandomiseOrder 4
					}
					set i $mix_perm($subcnt)
					switch -- $i {
						0 {	set sqzval .25 }
						1 {	set sqzval .5 }
						2 {	set sqzval .7 }
						3 {	set sqzval .9 }
					}
					set outfnam $evv(DFLT_OUTNAME)
# RWD 2023 was ANALFILE_EXT
					append outfnam $cnt $evv(ANALFILE_OUT_EXT)
					incr cnt
					set cmd [file join $evv(CDPROGRAM_DIR) specnu]
					lappend cmd squeeze $vspec(ifnam) $outfnam $frq $sqzval

					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					wm title .blocker "PLEASE WAIT:        SQUEEZING SPECTRUM AROUND $frq BY $sqzval"
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "Cannot Squeeze Spectrum Around $frq By $sqzval"
						catch {close $CDPidrun}
						set OK 0
						continue
					} else {
						fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
					}
					vwait prg_dun
					if {$prg_abortd} {
						set prg_dun 0
					}
					if {!$prg_dun || ![file exists $outfnam]} {
						set msg "Failed To Squeeze Spectrum Around $frq By $sqzval"
						set msg [AddSimpleMessages $msg]
						Inf $msg
						catch {close $CDPidrun}
						set OK 0
						continue
					}
					lappend outnames $outfnam
					incr subcnt
					if {$subcnt >= 4} {
						set subcnt 0
					}
				}
			}
			if {![info exists outnames]} {
				Inf "Produced No Outputs"
				UnBlock
				continue
			}
			if {[info exists timvals]} {

				;#	DO THE TIME-STRETCHED VERSIONS

				set onams $outnames		;#	REMEMBER ORIGINAL LIST OF WARPED SPECTRA

				foreach infnam $outnames {
					foreach tstr $timvals tstrval $origtimvals {
						if {[IsNumeric $tstr] && [Flteq $tstr 1.0]} {
							continue
						}
						set outfnam $evv(DFLT_OUTNAME)
# RWD 2023 was ANALFILE_EXT
						append outfnam $cnt $evv(ANALFILE_OUT_EXT)
						incr cnt
						set cmd [file join $evv(CDPROGRAM_DIR) stretch]
						lappend cmd time 1 $infnam $outfnam $tstr

						set prg_dun 0
						set prg_abortd 0
						catch {unset simple_program_messages}
						wm title .blocker "PLEASE WAIT:        TIME-STRETCHING $infnam BY $tstrval"
						if [catch {open "|$cmd"} CDPidrun] {
							Inf "Cannot Time-stretch $infnam By $tstrval"
							catch {close $CDPidrun}
							set OK 0
							continue
						} else {
							fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
						}
						vwait prg_dun
						if {$prg_abortd} {
							set prg_dun 0
						}
						if {!$prg_dun || ![file exists $outfnam]} {
							set msg "Failed To Time-stretch $infnam By $tstrval"
							set msg [AddSimpleMessages $msg]
							Inf $msg
							catch {close $CDPidrun}
							set OK 0
							continue
						}
						lappend onams $outfnam	;#	ADD TSTRETRCH VERSIONS TO ORIGINAL LISTS
					}
				}
				set outnames $onams		;#	REPLACE ORIGINAL LIST BY ORIGS+TSTRETCHED VERSIONS
			}
			catch {unset outputs}
			set outcnt 0
			foreach infnam $outnames {

				;#	CONVERT SPECTRA TO WAV FILES

				set ofnam [lindex $ofnams $outcnt]
				incr outcnt
				set outfnam [file rootname $infnam]
				append outfnam $evv(SNDFILE_EXT)
				set cmd [file join $evv(CDPROGRAM_DIR) pvoc]
				lappend cmd synth $infnam $outfnam
				set prg_dun 0
				set prg_abortd 0
				catch {unset simple_program_messages}
				wm title .blocker "PLEASE WAIT:        RESYNTHESIZING $ofnam"
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "Cannot Resynthesize $ofnam"
					catch {close $CDPidrun}
					set OK 0
					continue
				} else {
					fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				if {!$prg_dun || ![file exists $outfnam]} {
					set msg "Failed To Resynthesize $ofnam"
					set msg [AddSimpleMessages $msg]
					Inf $msg
					catch {close $CDPidrun}
					set OK 0
					continue
				}
				;#	FIND MAX SAMP

				wm title .blocker "PLEASE WAIT:        CHECKING LEVEL OF $ofnam"
				set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
				catch {unset maxsamp_line}
				set done_maxsamp 0
				lappend cmd $outfnam
				if [catch {open "|$cmd"} CDPmaxId] {
					Inf "Failed To Find Maximum Level Of $ofnam"
					continue
				}
				fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
				vwait done_maxsamp
				if {![info exists maxsamp_line]} {
					Inf "Cannot Retrieve Maximum Level Information For $ofnam"
					catch {close $CDPmaxId}
					continue
				}
				set maxsamp [lindex $maxsamp_line 0]
				if {$maxsamp <= 0.0} {
					Inf "$ofnam has zero level"
					catch {close $CDPmaxId}
					continue
				}

				if {$maxsamp < 0.9} {

					;#	NORMALISE

					set cmd [file join $evv(CDPROGRAM_DIR) modify]
					lappend cmd loudness 3 $outfnam $ofnam -l.9
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					wm title .blocker "PLEASE WAIT:        NORMALISING $ofnam"
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "Cannot Normalise $ofnam"
						catch {close $CDPidrun}
						set OK 0
						continue
					} else {
						fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
					}
					vwait prg_dun
					if {$prg_abortd} {
						set prg_dun 0
					}
					if {!$prg_dun || ![file exists $ofnam]} {
						set msg "Failed To NORMALISE $ofnam : (maxsamp = $maxsamp cmd = $cmd)"
						set msg [AddSimpleMessages $msg]
						Inf $msg
						catch {close $CDPidrun}
						set OK 0
						continue
					}
					lappend outputs $ofnam		;#	REMEMBER ALL OUTPUT FILES, NORMALISED

				} else {
					if [catch {file rename $outfnam $ofnam} zit] {
						Inf "Cannot Rename Temporary Outfile $outfnam To $ofnam"
					} else {
						lappend outputs $ofnam	;#	AND REMEMBER ALL OUTPUT FILES, NON-NORMALISED
					}
				}
			}
			if {![info exists outputs]} {
				Inf "No Files Generated"
				UnBlock
				continue
			} else {
				set last_outfile $outputs
				wm title .blocker "PLEASE WAIT:        PARSING OUTPUT FILES"
				set outputs [ReverseList $outputs]
				foreach fnam $outputs {
					FileToWkspace $fnam 0 0 0 0 1
				}
				UnBlock
				Inf "The Files Are On The Workspace"
				set finished 1
			}
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

######################################
#	SPECTUNE MULTIPLE INPUT  FILES	 #
######################################

proc TuneSet {} {
	global chlist pa evv pr_tuner tuner prg_dun prg_abortd simple_program_messages pitch_info_message CDPidrun wl sort_pitches last_outfile

	;#	DEFAULT VALS OF PARAMS

	set tuner(default_match)  5
	set tuner(default_lo)	  4
	set tuner(default_hi)	  127
	set tuner(default_intune) 1
	set tuner(default_wins)	  2
	set tuner(default_nois)	  80

	set tuner(analysis_done) 0
	catch {unset sort_pitches}

	catch {unset tuner(previous_mode)}

	#		GET CHOSEN FILES AND CHECK PROPS

	if {![info exists chlist] || ([llength $chlist] < 1)} {
		Inf "Choose Some Mono Soundfile(s)"
		return
	}
	set incnt 0
	foreach fnam $chlist {
		if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) > 2)} {
			Inf "Choose All Mono, Or All Stereo, Soundfiles Only"
			return
		}
		if {$incnt == 0} {
			set tuner(chans) $pa($fnam,$evv(CHANS))
		} else {
			if {$pa($fnam,$evv(CHANS)) != $tuner(chans)} {
				Inf "Choose All Mono, Or All Stereo, Soundfiles Only"
				return
			}
		}
		lappend infnams $fnam
		incr incnt
	}

	set tuner(infnams) $infnams			;#	REMEMBER INFILE-NAMES FOR USE IN OTHER FUNCTIONS

	DeleteAllTemporaryFiles
	set TunerDeleteCmd DeleteAllTemporaryFilesExcept
	if {$tuner(chans) > 1} {
		set n 0
		foreach fnam $infnams {
			set fnam $evv(MACH_OUTFNAME)
			append fnam $n
			set temp_ifnam $fnam
			append temp_ifnam $evv(SNDFILE_EXT)	;#	INFILE IS COPIED WITH TEMPNAME, AS  HOUSKEEP EXTRACT ADDS "_c1" ETC. TO THIS	
			lappend temp_ifnams $temp_ifnam
			set c1_fnam $fnam
			append c1_fnam "_c1" $evv(SNDFILE_EXT)
			lappend c1_ifnams $c1_fnam			;#	EXTRACTED CHAN 1 FILES
			set c2_fnam $fnam
			append c2_fnam "_c2" $evv(SNDFILE_EXT)
			lappend c2_ifnams $c2_fnam			;#	EXTRACTED CHAN 2 FILES
			incr n
		}
		set pvanal_ifnams [concat $c1_ifnams $c2_ifnams]	;#	INPUT TO ANALYSIS = ALL EXTRACTED MONO FILES CHAN 1 + CHAN 2

		foreach fnam $infnams {				;#	TEMPORARY CHANNEL1 OUTPUT SOUNDFILES
			set fnam $evv(MACH_OUTFNAME)
			append fnam $n $evv(SNDFILE_EXT)
			lappend c1_ofnams $fnam
			lappend pvsyn_ofnams $fnam
			incr n
		}
		foreach fnam $infnams {				;#	+ TEMPORARY CHANNEL2 OUTPUT SOUNDFILES
			set fnam $evv(MACH_OUTFNAME)
			append fnam $n $evv(SNDFILE_EXT)
			lappend c2_ofnams $fnam
			lappend pvsyn_ofnams $fnam		;#	pvsyn_ofnams ARE OUTPUT FILES FROM PVOC-RESYNTH PROCESS: 
			incr n							;#	IN STEREO CASE THESE ARE TEMPORARY FILES
		}
		set n 0
		foreach fnam $infnams {				;#	TEMPORARY OUTPUT ANALFILES FOR CHANNEL 1
			set fnam $evv(DFLT_OUTNAME)
#RWD 2023 was ANALFILE_EXT, all following cases
			append fnam $n $evv(ANALFILE_OUT_EXT)
			lappend pvanal_ofnams $fnam
			incr n
		}
		foreach fnam $infnams {				;#	TEMPORARY OUTPUT ANALFILES FOR CHANNEL 2
			set fnam $evv(DFLT_OUTNAME)
			append fnam $n $evv(ANALFILE_OUT_EXT)
			lappend pvanal_ofnams $fnam
			incr n
		}
		foreach fnam $pvanal_ofnams {		;#	PREVENT SOURCE ANAL FILES BEING DELETED IF "continue" HAPPENS
			lappend TunerDeleteCmd $fnam
		}

		foreach fnam $infnams {				;#	TEMPORARY TUNED ANALFILES FOR CHANNEL 1
			set fnam $evv(DFLT_OUTNAME)
			append fnam $n $evv(ANALFILE_OUT_EXT)
			lappend tuned_analfnams $fnam
			incr n
		}
		foreach fnam $infnams {				;#	TEMPORARY TUNED ANALFILES FOR CHANNEL 2
			set fnam $evv(DFLT_OUTNAME)
			append fnam $n $evv(ANALFILE_OUT_EXT)
			lappend tuned_analfnams $fnam
			incr n
		}
	} else {
		set pvanal_ifnams $infnams			;#	INPUTS TO ANALYSIS ARE JUST THE ORIGINAL INPUT MONO FILES
		set n 0
		foreach fnam $infnams {				;#	TEMPORARY OUTPUT ANALFILES
			set fnam $evv(DFLT_OUTNAME)
			append fnam $n $evv(ANALFILE_OUT_EXT)
			lappend pvanal_ofnams $fnam
			incr n
		}
		foreach fnam $pvanal_ofnams {		;#	PREVENT SOURCE ANAL FILES BEING DELETED IF "continue" HAPPENS
			lappend TunerDeleteCmd $fnam
		}
		foreach fnam $infnams {				;#	TEMPORARY TUNED ANALFILES
			set fnam $evv(DFLT_OUTNAME)
			append fnam $n $evv(ANALFILE_OUT_EXT)
			lappend tuned_analfnams $fnam
			incr n
		}
	}
	set f .tuner
	if [Dlg_Create $f "TUNE SOUNDS" "set pr_tuner 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0] 
		set f00 [frame $f.00] 
		set f1 [frame $f.1] 
		set f2 [frame $f.2] 
		set f3 [frame $f.3] 
		set f4 [frame $f.4] 
		set f5 [frame $f.5] 
		set f6 [frame $f.6] 
		set f8 [frame $f.8] 
		set f9 [frame $f.9] 
		set f10 [frame $f.10] 

		button $f0.ok -text "Tune Sounds" -command "set pr_tuner 1" -bg $evv(EMPH)  -highlightbackground [option get . background {}]
		button $f0.help -text "Help" -command "TunerHelp" -bg $evv(HELP)  -highlightbackground [option get . background {}]
		button $f0.quit -text "Quit" -command "set pr_tuner 0"  -highlightbackground [option get . background {}]
		pack $f0.ok $f0.help -side left -padx 4
		pack $f0.quit -side right
		pack $f0 -side top -fill x -expand true

		label $f.tit -text "\"HARMONIC SET\" tunes to MIDI \"Tuning Pitches\"  :::  \"HARMONIC FIELD\" tunes to \"Tuning Pitches\" & octave equivalents." -fg $evv(SPECIAL)
		pack $f.tit -side top -pady 2
	
		radiobutton $f00.tt -text "Concert-pitch Tempered" -width 20 -variable tuner(mode) -value 1 -command {SetTuningPitchEntry}
		radiobutton $f00.ss -text "Harmonic Set"   -width 14 -variable tuner(mode) -value 2 -command {SetTuningPitchEntry}
		radiobutton $f00.ff -text "Harmonic Field" -width 14 -variable tuner(mode) -value 3 -command {SetTuningPitchEntry}
		radiobutton $f00.oo -text "Other" -width 14 -variable tuner(mode) -value 4 -command {AlternativeTunings}
		label $f00.ll -text "Tuning Pitches file" -width  19 -anchor e
		entry $f00.e -textvariable tuner(tuning) -width 24
		button $f00.files -text "Find File" -command FindTuningFiles -width 10  -highlightbackground [option get . background {}]
		set tuner(mode) 0
		pack $f00.tt $f00.ss $f00.ff $f00.oo -side left
		pack $f00.ll $f00.e $f00.files -side left -padx 2
		pack $f00 -side top -fill x -expand true

		label $f.tit2 -text "To recall a previous \"Other\" setting, select \"Harmonic Field\"" -fg $evv(SPECIAL)
		pack $f.tit2 -side top -pady 2

		button $f.dflt -text "Set All Defaults" -width 16 -command "SetAllTunerDefaults"  -highlightbackground [option get . background {}]
		pack $f.dflt -side top -anchor w -pady 2

		label $f1.ll -text "LOWEST possible MIDI pitch (Range 4 to <127)."
		entry $f1.e -textvariable tuner(lo) -width 6
		button $f1.dflt -text "Set Default" -width 11 -command "set tuner(lo) $tuner(default_lo)"  -highlightbackground [option get . background {}]
		pack $f1.dflt $f1.e $f1.ll -side left -padx 2
		pack $f1 -side top -fill x -expand true

		label $f2.ll -text "HIGHEST possible MIDI pitch (Range >4 to 127)."
		entry $f2.e -textvariable tuner(hi) -width 6
		button $f2.dflt -text "Set Default" -width 11 -command "set tuner(hi) $tuner(default_hi)"  -highlightbackground [option get . background {}]
		pack $f2.dflt $f2.e $f2.ll -side left -padx 2
		pack $f2 -side top -fill x -expand true

		label $f3.ll -text "How many HARMONICS to guarantee pitch found  (Range 1 - 8)."
		entry $f3.e -textvariable tuner(match) -width 6
		button $f3.dflt -text "Set Default" -width 11 -command "set tuner(match) $tuner(default_match)"  -highlightbackground [option get . background {}]
		pack $f3.dflt $f3.e $f3.ll -side left -padx 2
		pack $f3 -side top -fill x -expand true

		label $f4.ll -text "How IN-TUNE must harmonics be (semitones)  (Range 0 - 6)."
		entry $f4.e -textvariable tuner(intune) -width 6
		button $f4.dflt -text "Set Default" -width 11 -command "set tuner(intune) $tuner(default_intune)"  -highlightbackground [option get . background {}]
		pack $f4.dflt $f4.e $f4.ll -side left -padx 2
		pack $f4 -side top -fill x -expand true

		label $f5.ll -text "How many CONSECUTIVE pitched WINDOWS to confirm true pitch found (Range 1 - 64)."
		entry $f5.e -textvariable tuner(wins) -width 6
		button $f5.dflt -text "Set Default" -width 11 -command "set tuner(wins) $tuner(default_wins)"  -highlightbackground [option get . background {}]
		pack $f5.dflt $f5.e $f5.ll -side left -padx 2
		pack $f5 -side top -fill x -expand true

		label $f6.ll -text "dB SIGNAL TO NOISE ratio (low level sig assumed unpitched) (Range >0 - 1000)."
		entry $f6.e -textvariable tuner(nois) -width 6
		button $f6.dflt -text "Set Default" -width 11 -command "set tuner(nois) $tuner(default_nois)"  -highlightbackground [option get . background {}]
		pack $f6.dflt $f6.e $f6.ll -side left -padx 2
		pack $f6 -side top -fill x -expand true

		label $f.6a -text ""
		pack $f.6a -side top

		label $f.7 -text "Set TIME LIMITS within (some) source(s) to search for pitch ??" -fg $evv(SPECIAL)
		pack $f.7 -side top -anchor w -pady 2

		radiobutton $f8.1 -text "Set time limits"   -variable tuner(tlims) -value 1 -command "SetTunerTimeLimits 1"
		radiobutton $f8.2 -text "Search whole file" -variable tuner(tlims) -value 0 -command "SetTunerTimeLimits 0"
		set tuner(tlims) 0

		pack $f8.1 $f8.2 -side left
		pack $f8 -side top -fill x -expand true

		label $f.8a -text ""
		pack $f.8a -side top

		checkbutton $f.8b -text "Tune by changing sampling rate (and duration)" -variable tuner(other) -command TuneOther
		pack $f.8b -side top -fill x -expand true
		set tuner(other) 0

		label $f.8c -text ""
		pack $f.8c -side top

		checkbutton $f9.ch -text "DON'T try to PRESERVE FORMANTS envelope" -variable tuner(noformants)
		checkbutton $f9.ii -text "IGNORE RELATIVE LOUDNESS of windows when assessing pitch" -variable tuner(ignore)
		checkbutton $f9.ss -text "SMOOTH the pitch data before assessing pitch" -variable tuner(smooth)
		checkbutton $f9.ana -text "RETAIN tuned ANALYSIS FILES, as well as soundfiles" -variable tuner(keepanal)
		frame $f9.rp
		checkbutton $f9.rp.ad -text "ADD TUNED PITCH TO OUTFILE NAME" -variable tuner(retain_pitch)
		checkbutton $f9.rp.sf -text "To TWO sigfig ONLY" -variable tuner(pitchinfo_curtail)
		checkbutton $f9.rp.nn -text "INCLUDE NOTE NAMES" -variable tuner(pitchinfo_names)
		pack $f9.rp.ad $f9.rp.sf $f9.rp.nn -side left
		label $f9.dum -text ""
		set tuner(retain_pitch) 1
		set tuner(pitchinfo_curtail) 1
		set tuner(pitchinfo_names) 0
		set tuner(noformants) 0
		set tuner(ignore) 0
		set tuner(smooth) 0
		set tuner(keepanal) 0
		SetTuningPitchEntry
		pack $f9.ch $f9.ii $f9.ss $f9.ana $f9.rp $f9.dum -side top -anchor w
		pack $f9 -side top -fill x -expand true -pady 2
		
		label $f10.ll -text "Generic Suffix for Outputfile Names"
		entry $f10.e -textvariable tuner(namext) -width 20
		pack $f10.ll $f10.e -side top -pady 2
		pack $f10 -side top

		label $f.10a -text ""
		pack $f.10a -side top

		set tuner(match)  $tuner(default_match)
		set tuner(lo)	  $tuner(default_lo)
		set tuner(hi)	  $tuner(default_hi)
		set tuner(intune) $tuner(default_intune)
		set tuner(wins)	  $tuner(default_wins)
		set tuner(nois)	  $tuner(default_nois)

		bind	$f1.e <Down> {focus .tuner.2.e}
		bind	$f2.e <Down> {focus .tuner.3.e}
		bind	$f3.e <Down> {focus .tuner.4.e}
		bind	$f4.e <Down> {focus .tuner.5.e}
		bind	$f5.e <Down> {focus .tuner.6.e}
		bind	$f6.e <Down> {focus .tuner.1.e}
		bind	$f1.e <Up> {focus .tuner.6.e}
		bind	$f2.e <Up> {focus .tuner.1.e}
		bind	$f3.e <Up> {focus .tuner.2.e}
		bind	$f4.e <Up> {focus .tuner.3.e}
		bind	$f5.e <Up> {focus .tuner.4.e}
		bind	$f6.e <Up> {focus .tuner.5.e}

		bind $f <Escape> {set pr_tuner 0}
		bind $f <Return> {set pr_tuner 1}
		wm resizable $f 0 0
	}
	set tuner(tlims) 0
	set pr_tuner 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_tuner $f.1.e
	while {!$finished} {
		tkwait variable pr_tuner
		if {$pr_tuner} {
			catch {eval $TunerDeleteCmd}				;#	Don't delete any of the pre-tuned analfiles
			if {$tuner(mode) <= 0} {
				Inf "NO TUNING TYPE SET"
				continue
			}
			;#	IF TUNING-SET NEEDED, TEST FILE PROPERTIES

			if {$tuner(mode) > 1} {
				if {[string length $tuner(tuning)] <= 0} {
					Inf "No Tuning Set Filename Entered"
					continue
				}
				if {![file exists $tuner(tuning)]} {
					Inf "Tuning Set File $tuner(tuning) Is Not On The Workspace"
					continue
				}
				set pfile $tuner(tuning)
				set ftyp $pa($pfile,$evv(FTYP))
				if {![IsAListofNumbers $ftyp]  || ($pa($pfile,$evv(MINNUM)) < 4) || ($pa($pfile,$evv(MAXNUM)) > 127)} {
					Inf "Tuning File Is Not Of The Correct Type (Numeric entries between 4 and 127 required)"
					continue
				}
			}

			if {[string length $tuner(lo)] <= 0} {
				Inf "Lowest Possible Midi Pitch Not Entered"
				continue
			}
			if {![IsNumeric $tuner(lo)] || ($tuner(lo) < 4) || ($tuner(lo) >= 127)} {
				Inf "Invalid Lowest Possible Midi Pitch (range 4 to <127)"
				continue
			}
			if {[string length $tuner(hi)] <= 0} {
				Inf "Highest Possible Midi Pitch Not Entered"
				continue
			}
			if {![IsNumeric $tuner(hi)] || ($tuner(hi) <= 4) || ($tuner(hi) > 127)} {
				Inf "Invalid Highest Possible Midi Pitch (range >4 to 127)"
				continue
			}
			if {$tuner(hi) <= $tuner(lo)} {
				Inf "Incompatible Lowest And Highest Midi Pitches"
				continue
			}

			if {[string length $tuner(match)] <= 0} {
				Inf "Number Of Harmonics Not Entered"
				continue
			}
			if {![IsNumeric $tuner(match)] || ![regexp {^[0-9]+$} $tuner(match)] || ($tuner(match) < 1) || ($tuner(match) > 8)} {
				Inf "Invalid Number Of Harmonics (integer between 1 and 8)"
				continue
			}
			if {[string length $tuner(intune)] <= 0} {
				Inf "In-tune Value Not Entered"
				continue
			}
			if {![IsNumeric $tuner(intune)] || ($tuner(intune) < 0) || ($tuner(intune) > 6)} {
				Inf "Invalid In-tune Value (range 0 - 6)"
				continue
			}
			if {[string length $tuner(wins)] <= 0} {
				Inf "Number Of Consecutive Windows Not Entered"
				continue
			}
			if {![IsNumeric $tuner(wins)] || ![regexp {^[0-9]+$} $tuner(wins)] || ($tuner(wins) < 1) || ($tuner(wins) > 16)} {
				Inf "Invalid Number Of Consecutive Windows (integer between 1 and 16)"
				continue
			}
			if {[string length $tuner(nois)] <= 0} {
				Inf "Signal To Noise Ratio Not Entered"
				continue
			}
			if {![IsNumeric $tuner(nois)] || ($tuner(nois) <= 0) || ($tuner(nois) > 1000)} {
				Inf "Invalid Signal To Noise Ratio (Range >0 - 1000)"
				continue
			}
			if {[string length $tuner(namext)] <= 0} {
				Inf "No Output Filename Suffix Entered"
				continue
			}
			if {![regexp {^[a-zA-Z0-9\-\_]+$} $tuner(namext)]} {
				Inf "Invalid Output Filename Suffix (Alphabenumeric)"
				continue
			}
			set nu_suffix [string tolower $tuner(namext)]

			set OK 1
			catch {unset final_outfnams}
			set OK 1
			foreach fnam $infnams {
				set fnam [file rootname [file tail $fnam]]
				append fnam "_" $nu_suffix
				set basnam $fnam
				append fnam $evv(SNDFILE_EXT)
				foreach zfnam [$wl get 0 end] {				
					if {[string match [file extension $zfnam] $evv(SNDFILE_EXT)] && ([string first $basnam $zfnam] == 0)} {
						Inf "File $fnam Already Exists: Please Chose A Different Filename Suffix"
						set OK 0
						break
					}
					if {!$OK} {
						break
					}
				}
				lappend final_outfnams $fnam
			}
			if {$tuner(chans) == 1} {
				set pvsyn_ofnams $final_outfnams	;#	WITH MONO INPUT, THE OUTPUT FROM RESYTHESIS IS THE TRUE OUTPUTS
			}										;#	IN STEREO CASE, OUTPUTS ARE TEMPORARY FILES, BEFORE CHANNELS MERGED
			if {!$OK} {
				continue
			}

			if {$tuner(keepanal)} {			;#	IF KEEPING THE TUNED ANALYSIS FILES, GIVE THESE UNIQUE NAMES BASED ON SRCS
				set orig_tuned_analfnams $tuned_analfnams
				unset tuned_analfnams
				catch {unset c1keepfnams}
				catch {unset c2keepfnams}
				foreach fnam $infnams {
					set fnam [file rootname [file tail $fnam]]
					append fnam $nu_suffix
					if {$tuner(chans) > 1} {
						set c1analfnam $fnam
#RWD 2023 was ANALFILE_EXT, presumably need to be consistent with previous settings abaove
						append c1analfnam _c1 $evv(ANALFILE_OUT_EXT)
						set c2analfnam $fnam
						append c2analfnam _c2 $evv(ANALFILE_OUT_EXT)
						if {[file exists $c1analfnam] || [file exists $c2analfnam]} {
							if {[file exists $c1analfnam]} {
								set msg "Analysis File $c1analfnam Already Exists\n\n"
							}  elseif {[file exists $c2analfnam]} {
								set msg "Analysis File $c2analfnam Already Exists\n\n"
							}
							append msg "If You Want To Retain The Analysis Files, Please Chose A Different Filename Extension"
							Inf $msg
							set tuned_analfnams $orig_tuned_analfnams
							set OK 0
							break
						}
						lappend c1keepfnams $c1analfnam
						lappend c2keepfnams $c2analfnam
					} else {
						append fnam $evv(ANALFILE_EXT)
						if {[file exists $fnam]} {
							set msg "Analysis File $fnam Already Exists\n\n"
							append msg "If You Want To Retain The Analysis Files, Please Chose A Different Filename Extension"
							Inf $msg
							set tuned_analfnams $orig_tuned_analfnams
							set OK 0
							break
						}
						lappend tuned_analfnams $fnam
					}
				}
				if {!$OK} {
					continue
				}
				if {$tuner(chans) > 1} {
					set pvkeepfnams $c1keepfnams
					set pvkeepfnams [concat $pvkeepfnams $c2keepfnams]
					set tuned_analfnams $pvkeepfnams 
				} else {
					set pvkeepfnams $tuned_analfnams
				}
			}

			;#	SET UP ANY OPTIONAL PARAMS NECESSARY
		
			set cmdparams {}
			if {($tuner(mode) > 1) && !$tuner(other)} {
				lappend cmdparams $tuner(tuning)			;#	TUNING FILE
			}
			if {![Flteq $tuner(lo) $tuner(default_lo)]} {
				lappend cmdparams -l$tuner(lo)				;#	LOW PITCH LIMIT
			}
			if {![Flteq $tuner(hi) $tuner(default_hi)]} {
				lappend cmdparams -h$tuner(hi)				;#	HIGH PITCH LIMIT
			}
			if {$tuner(match) != $tuner(default_match)} {
				lappend cmdparams -m$tuner(match)			;#	HARMONICS MATCH
			}
			if {![Flteq $tuner(intune) $tuner(default_intune)]} {
				lappend cmdparams -i$tuner(intune)			;#	HARMONICS IN-TUNE
			}
			if {$tuner(wins) != $tuner(default_wins)} {
				lappend cmdparams -w$tuner(wins)			;#	CONSECUTIVE PITCH WINDOWS
			}
			if {![Flteq $tuner(nois) $tuner(default_nois)]} {
				lappend cmdparams -n$tuner(nois)			;#	NOISE THRESHOLD
			}
			
			set other_mono 0

			Block "EXTRACTING SPECTRUM"	

			if {$tuner(other)} {
				wm title .blocker "PLEASE WAIT:        ASSEMBLING TUNING DATA"
				catch {unset tuner(tuneset)}
				if {$tuner(mode) > 1} {
					if [catch {open $tuner(tuning)} zit] {
						Inf "Cannot Open The Tuning File"
						UnBlock
						continue
					}
					set OK 1
					while {[gets $zit line] >= 0} {
						set line [string trim $line]
						if {[string length $line] <= 0} {
							continue
						}
						set itemcnt 0
						set line [split $line]
						foreach item $line {
							set item [string trim $item]
							if {[string length $item] > 0} {
								set thispitch $item
								incr itemcnt
							}
							if {![IsNumeric $thispitch] || ($thispitch < 4) || ($thispitch >127)} {
								Inf "Anomalous Tuning Data ($thispitch) In File $tuner(tuning) : Range 4-127"
								set OK 0
								break
							}
						}
						if {!$OK} {
							break
						}
						if {$itemcnt != 1} {
							Inf "Anomalous Tuning Data ($line) In File $tuner(tuning)"
							set OK 0
							break
						}
						lappend tuner(tuneset) $thispitch
					}
					if {!$OK} {
						UnBlock
						continue
					}
					set nupitches {}
					if {$tuner(mode) == 3} {		;#	HF
						foreach pp $tuner(tuneset) {
							set thispitch $pp
							while {$thispitch <= 127} {
								if {[lsearch $nupitches $thispitch] < 0} {
									lappend nupitches $thispitch
								}
								set thispitch [expr $thispitch + 12.0]
							}
							set thispitch [expr $pp - 12.0]
							while {$thispitch >= 4} {
								if {[lsearch $nupitches $thispitch] < 0} {
									lappend nupitches $thispitch
								}
								set thispitch [expr $thispitch - 12.0]
							}
						}
						set len [llength $nupitches]
						set len_less_one [expr $len - 1]
						set n 0
						while {$n < $len_less_one} {
							set n_pp [lindex $nupitches $n]
							set m $n
							incr m
							while {$m < $len} {
								set m_pp [lindex $nupitches $m]
								if {$m_pp  == $n_pp} {
									set nupitches [lreplace $nupitches $m $m]
									incr len -1
									incr len_less_one -1
								} else {
									if {$m_pp  < $n_pp} {
										set nupitches [lreplace $nupitches $n $n $m_pp]
										set nupitches [lreplace $nupitches $m $m $n_pp]
										set n_pp $m_pp
									}
									incr m
								}
							}
							incr n
						}
						set $tuner(tuneset) $nupitches
					}
				} else {
					set n 4
					while {$n <= 127} {
						lappend tuner(tuneset) $n
						incr n
					}
				}
			}

			if {!$tuner(analysis_done)} {

				if {$tuner(chans) > 1} {
					set OK 1
					if {$tuner(other)} {
						set OK 1
						foreach infnam $infnams outfnam $c1_ifnams {
							set cmd [file join $evv(CDPROGRAM_DIR) housekeep]
							lappend cmd chans 4 $infnam $outfnam
							set prg_dun 0
							set prg_abortd 0
							catch {unset simple_program_messages}
							wm title .blocker "PLEASE WAIT:        CONVERTING TO MONO, FILE $infnam"
							if [catch {open "|$cmd"} CDPidrun] {
								Inf "Cannot Convert To Mono File $origfnam"
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
								set msg "Failed To Convert To Mono File $infnam"
								set msg [AddSimpleMessages $msg]
								Inf $msg
								catch {close $CDPidrun}
								set OK 0
								break
							}
							if {![file exists $outfnam]} {
								set msg " Converting To Mono File $infnam Failed: "
								set msg [AddSimpleMessages $msg]
								Inf $msg
								catch {close $CDPidrun}
								set OK 0
								break
							}
						}
						if {!$OK} {
							UnBlock
							continue
						}
						set other_mono 1		;#	Now working with mono files
					} else {

						foreach infnam $infnams temp_ifnam $temp_ifnams {
							if [catch {file copy $infnam $temp_ifnam} zit] {
								Inf "Initial Copying Of Source File $infnam Failed"
								set OK 0
								break
							}
						}
						if {!$OK} {
							continue
						}

						catch {unset extractedc1}
						catch {unset extractedc2}
						set n 0
						foreach infnam $temp_ifnams outfnam $c1_ifnams {		;#	EXTRACT ALL CHANNEL 1s
							set origfnam [file rootname [file tail [lindex $infnams $n]]]
							incr n
							set cmd [file join $evv(CDPROGRAM_DIR) housekeep]
							lappend cmd chans 1 $infnam 1
							set prg_dun 0
							set prg_abortd 0
							catch {unset simple_program_messages}
							wm title .blocker "PLEASE WAIT:        EXTRACTING CHANNEL 1 from FILE $origfnam"
							if [catch {open "|$cmd"} CDPidrun] {
								Inf "Cannot Extract Channel 1 From File $origfnam"
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
								set msg "Failed To Extract Channel 1 From File $origfnam"
								set msg [AddSimpleMessages $msg]
								Inf $msg
								catch {close $CDPidrun}
								continue
							}
							if {![file exists $outfnam]} {
								set msg " Extracting Channel 1 From File $origfnam Failed: "
								set msg [AddSimpleMessages $msg]
								Inf $msg
								catch {close $CDPidrun}
								continue
							}
							catch {close $CDPidrun}
							lappend extractedc1 $outfnam
						}
						if {![info exists extractedc1] || ([llength $extractedc1] != $incnt)} {
							Inf "Failed To Do All Channel 1 Extraction"
							UnBlock
							continue
						}
						set n 0
						foreach infnam $temp_ifnams outfnam $c2_ifnams {		;#	EXTRACT ALL CHANNEL 2s
							set origfnam [file rootname [file tail [lindex $infnams $n]]]
							incr n
							set cmd [file join $evv(CDPROGRAM_DIR) housekeep]
							lappend cmd chans 1 $infnam 2
							set prg_dun 0
							set prg_abortd 0
							catch {unset simple_program_messages}
							wm title .blocker "PLEASE WAIT:        EXTRACTING CHANNEL 2 from FILE $origfnam"
							if [catch {open "|$cmd"} CDPidrun] {
								Inf "Cannot Extract Channel 2 From File $origfnam"
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
								set msg "Failed To Extract Channel 2 From File $origfnam"
								set msg [AddSimpleMessages $msg]
								Inf $msg
								catch {close $CDPidrun}
								continue
							}
							if {![file exists $outfnam]} {
								set msg " Extracting Channel 2 From File $origfnam Failed: "
								set msg [AddSimpleMessages $msg]
								Inf $msg
								catch {close $CDPidrun}
								continue
							}
							catch {close $CDPidrun}
							lappend extractedc2 $outfnam
						}
						if {![info exists extractedc2] || ([llength $extractedc2] != $incnt)} {
							Inf "Failed To Do All Channel 2 Extraction"
							UnBlock
							continue
						}
					}
				}
				set done 0
				set n 0
				foreach infnam $pvanal_ifnams outfnam $pvanal_ofnams {
					if {$other_mono} {				;#	OTHER ALGO HAS CONVERTED STEREO INFILES TO MONO
						set origfnam [file rootname [file tail [lindex $infnams $n]]]
						append origfnam _chan1
					} elseif {$tuner(chans) > 1} {
						if {$n < $incnt} {
							set origfnam [file rootname [file tail [lindex $infnams $n]]]
							append origfnam _chan1
						} else {
							set origfnam [file rootname [file tail [lindex $infnams [expr $n - $incnt]]]]
							append origfnam _chan2
						}
					} else {
						set origfnam [file rootname [file tail [lindex $infnams $n]]]
					}
					incr n
					set cmd [file join $evv(CDPROGRAM_DIR) pvoc]
					lappend cmd anal 1 $infnam $outfnam -c1024 -o3
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					wm title .blocker "PLEASE WAIT:        EXTRACTING SPECTRUM OF FILE $origfnam"
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "Cannot Extract Spectrum Of File $origfnam"
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
						set msg "Failed To Extract Spectrum Of File $origfnam"
						set msg [AddSimpleMessages $msg]
						Inf $msg
						catch {close $CDPidrun}
						continue
					}
					if {![file exists $outfnam]} {
						set msg " Extracting Spectrum Of File $origfnam Failed: "
						set msg [AddSimpleMessages $msg]
						Inf $msg
						catch {close $CDPidrun}
						continue
					}
					catch {close $CDPidrun}
					set done 1
					if {$other_mono && ($n >= $incnt)} {		;#		With alternative algo, stereos converted to mono, so quit
						break
					}
				}
				if {!$done} {
					Inf "Failed To Extract Any Spectra"
					UnBlock
					continue
				}
				set tuner(analysis_done) 1
			}
			set n 0
			set done 0
			set OK 1

			;#	DO THE TUNING

			while {$n < ($incnt * $tuner(chans))} {
				if {$other_mono} {
					set origfnam [file rootname [file tail [lindex $infnams $n]]]
					append origfnam _chan1
				} elseif {$tuner(chans) > 1} {
					if {$n < $incnt} {
						set origfnam [file rootname [file tail [lindex $infnams $n]]]
						append origfnam _chan1
					} else {
						set origfnam [file rootname [file tail [lindex $infnams [expr $n - $incnt]]]]
						append origfnam _chan2
					}
				} else {
					set origfnam [file rootname [file tail [lindex $infnams $n]]]
				}
				set infnam  [lindex $pvanal_ofnams $n]
				set outfnam [lindex $tuned_analfnams $n]
				if {$n >= $incnt} {
					set m [expr $n - $incnt]
					set m [expr $m * 2]
				} else {
					set m [expr $n * 2]			;#		THERE ARE 2 TIME-LIMIT PARAMS FOR EACH INPUT FILE
				}
				incr n
				if {[file exists $infnam]} {
					
					;#	SET UP FLAGGED PARAMS FOR EACH CMD IN TURN
					
					set thisparams $cmdparams						;#	MAY OR NOT BE EXISTING FLAGS
				
					;#	IF TIME PARAMS EXISTS, ADD FOR EACH FILE IN TURN

					if {[info exists tuner(timeparams)]} {			;#	IF AT LEAST SOME FILES HAVE RESTRICTED TIMERANGE FOR FINDING PITCH
						set starttime [lindex $tuner(timeparams) $m]
						if {![string match $starttime "X"]} {		;#	IF "TIME RESTRICTION" NOT FLAGGED FOR THIS FILE
							lappend thisparams -s$starttime			;#	ADD TIME-RANGE RESTRICTION FLAGS TO CMDLINE PARAMS
							incr m
							lappend thisparams -e[lindex $tuner(timeparams) $m]
						}
					}
					if {!$tuner(other)} {
						if {$tuner(noformants)} {					;#	TRANSPOSITION DOES NOT PRESERVE FORMANTS
							lappend thisparams "-f"
						}
					}
					if {$tuner(ignore)} {							;#	SEARCH-FOR-PITCH IGNORES RELATIVE-LOUDNESS OF PITCHED-WINDOWS
						lappend thisparams "-r"
					}
					if {$tuner(smooth)} {							;#	SMOOTH PITCH-DATA OUTPUT, BEFORE ASSESSING MOST PROMINENT PITCH
						lappend thisparams "-b"
					}
					set cmd [file join $evv(CDPROGRAM_DIR) spectune]
					lappend cmd tune 
					if {$tuner(other)} {
						lappend cmd 4 $infnam						;#	"Other" option does NOT output files, only tuning data
					} else {
						if {$tuner(mode) == 4} {					;#	"Mode 4" is an interface option to set up an alternative HF
							set tuner(mode) 3						;#	So revert to HF mode, 3
						}
						lappend cmd $tuner(mode) $infnam $outfnam
					}
					if {[llength $thisparams] > 0} {
						set cmd [concat $cmd $thisparams]
					}
					;#	RUN SPECTUNE CMDLINE FOR EACH ANALFILE

					set prg_dun 0
					set prg_abortd 0

					catch {unset simple_program_messages}
					catch {unset pitch_info_message}
					wm title .blocker "PLEASE WAIT:        TUNING FILE $origfnam"
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "Cannot Tune File $origfnam"
						catch {unset CDPidrun}
						continue
					} else {
						if {$tuner(other)} {
							fileevent $CDPidrun readable "HandleProcessOutputGrabingPitch "
						} else {
							fileevent $CDPidrun readable "HandleProcessOutputWithPitchValueOutput"
						}
					}
					vwait prg_dun
					if {$prg_abortd} {
						set prg_dun 0
					}
					if {!$prg_dun} {
						set msg "Failed To Tune File $origfnam"
						set msg [AddSimpleMessages $msg]
						Inf $msg
						catch {close $CDPidrun}
						continue
					}
					if {!$tuner(other)} {
						if {![file exists $outfnam]} {
							set msg " Tuning File $origfnam Failed: "
							set msg [AddSimpleMessages $msg]
							Inf $msg
							catch {close $CDPidrun}
							set msg "Stop The Process ??"
							set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
							if {$choice == "yes"} {
								set OK 0
								break
							}
							continue
						}
					}
					catch {close $CDPidrun}
					set done 1
				}						;#	"n" HAS ALREADY BEEN INCREMENTED.
				if {$n <= $incnt} {		;#	IF ADDING TUNED-PITCH TO NAME, ALTER OUTFILE NAMES HERE (IN CHANNEL 1 PASS ONLY, IF STEREO INPUT)
										;#	(IN STEREO CASE, WE ASSUME CHANNEL 1 & 2 RETUNINGS WILL BE THE SAME!!)
					if {$tuner(retain_pitch)} {
						catch {unset tuned_pitch}
						if {$tuner(other)} {
							if {[info exists sort_pitches]} {
								set true_pitch [lindex $sort_pitches [expr $n - 1]]
								set mmm 0
								foreach pp $tuner(tuneset) {
									set interval [expr abs($pp - $true_pitch)]
									if {$mmm == 0} {
										set min_interval $interval
										set tuned_pitch $pp
									} elseif {$interval < $min_interval} {
										set min_interval $interval
										set tuned_pitch $pp
									} else {				;#	interval increasing
										break
									}
									incr mmm
								}
							}
						} else {
							if {[info exists pitch_info_message]} {
								set tuned_pitch [GetTunedPitchData]
							}
						}
						if {[info exists tuned_pitch]} {
							if {[string length $tuned_pitch] > 0} {
								if {$tuner(pitchinfo_curtail)} {
									set decpos [string first "p" $tuned_pitch] 
									if {$decpos > 0} {
										set tpend [string length $tuned_pitch]
										incr tpend -1
										set nutpend [expr $decpos + 2]
										if {$nutpend < $tpend} {
											set tuned_pitch [string range $tuned_pitch 0 $nutpend] 
										}									
									}
								}		;#	IN TEMPERED SCALE MODE, POSSIBLY ADD NOTE NAMES
								if {($tuner(mode) == 1) && ($tuner(pitchinfo_names))} {
									set ppn [expr $tuned_pitch % 12]
									switch -- $ppn {
										0  { set pclass c}
										1  { set pclass db}
										2  { set pclass d}
										3  { set pclass eb}
										4  { set pclass e}
										5  { set pclass f}
										6  { set pclass gb}
										7  { set pclass g}
										8  { set pclass ab}
										9  { set pclass a}
										10 { set pclass bb}
										11 { set pclass b}
									}
									append pclass $tuned_pitch
									set tuned_pitch $pclass
								}
								set nn [expr $n - 1]
								set goalfnam [lindex $final_outfnams $nn]
								set ext [file extension $goalfnam]
								set goalfnam [file rootname $goalfnam]
								append goalfnam "_" $tuned_pitch $ext
								set final_outfnams [lreplace $final_outfnams $nn $nn $goalfnam]
							}
						}
					}
				}
				if {$other_mono && ($n >= $incnt)} {		;#		With alternative algo, stereos converted to mono, so quit
					break
				}
			}
			if {!$OK} {
				DeleteAllTemporaryFiles
				UnBlock
				break
			}
			if {$tuner(other)} {
				if {![info exists sort_pitches]} {
					Inf "No Pitch Data Detected"
					UnBlock
					continue
				}
				if {[llength $sort_pitches] != $incnt} {
					Inf "Anomaly In Number Of Pitches Detected"
					UnBlock
					continue
				}
				set badcnt 0
				foreach pp $sort_pitches {
					if {$pp == 0} {
						incr badcnt
					}
				}
				if {$badcnt == $incnt} {
					Inf "No Pitch Found For Any Of These Files"
					UnBlock
					continue
				}
				if {$badcnt} {
					Inf "No Pitch Found For $badcnt Files"
				}
			} elseif {$tuner(retain_pitch) && ($tuner(chans) == 1)} {
				set pvsyn_ofnams $final_outfnams
			}	
			if {!$done} {
				if {!$OK} {
					break
				}
				Inf "No Files Have Been Tuned"
				UnBlock
				continue
			}
			set n 0
			set done 0

			;#	RESYNTHESIS OR SPEED-CHANGE TRANSPOSITION

			if {$tuner(other)} {
				set outcnt 0
				while {$n < $incnt} {
					set infnam  [lindex $infnams $n]
					set outfnam [lindex $final_outfnams $n]
					set tuning [lindex $sort_pitches $n]
					if {$tuning == 0} {
						incr n
						continue
					}
					set m 0
					foreach pp $tuner(tuneset) {
						set interval [expr abs($pp - $tuning)]
						if {$m == 0} {
							set min_interval $interval
							set tunedpitch $pp
						} elseif {$interval < $min_interval} {
							set min_interval $interval
							set tunedpitch $pp
						} else {				;#	interval increasing
							break
						}
						incr m
					}
					set tuning [expr $tunedpitch - $tuning]
					set cmd [file join $evv(CDPROGRAM_DIR) modify]
					lappend cmd speed 2 $infnam $outfnam $tuning
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					wm title .blocker "PLEASE WAIT:        CHANGING PITCH OF $infnam"
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "Cannot Change Pitch Of $infnam"
						catch {unset CDPidrun}
						incr n
						continue
					} else {
						fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
					}
					vwait prg_dun
					if {$prg_abortd} {
						set prg_dun 0
					}
					if {!$prg_dun} {
						set msg "Failed To Change Pitch Of $infnam"
						set msg [AddSimpleMessages $msg]
						Inf $msg
						catch {close $CDPidrun}
						incr n
						continue
					}
					if {![file exists $outfnam]} {
						set msg " Changing Pitch Of $infnam Failed: "
						set msg [AddSimpleMessages $msg]
						Inf $msg
						catch {close $CDPidrun}
						incr n
						continue
					}
					catch {close $CDPidrun}
					incr outcnt
					incr n
				}
				if {$outcnt == 0} {
					Inf "Failed To Generate Any Tuned Files"
					UnBlock
					continue
				}
			} else {
				while {$n < ($incnt * $tuner(chans))} {
					set infnam [lindex $tuned_analfnams $n]
					set outfnam [lindex $pvsyn_ofnams $n]
					if {$tuner(chans) > 1} {
						if {$n < $incnt} {
							set origfnam [file rootname [file tail [lindex $final_outfnams $n]]]
							append origfnam "_chan1"
						} else {
							set origfnam [file rootname [file tail [lindex $final_outfnams [expr $n - $incnt]]]]
							append origfnam "_chan2"
						}
					} else {
						set origfnam [file rootname [file tail [lindex $final_outfnams $n]]]
					}
					incr n
					if {[file exists $infnam]} {
						set cmd [file join $evv(CDPROGRAM_DIR) pvoc]
						lappend cmd synth $infnam $outfnam
						set prg_dun 0
						set prg_abortd 0
						catch {unset simple_program_messages}
						wm title .blocker "PLEASE WAIT:        RESYNTHESIZING FILE $origfnam"
						if [catch {open "|$cmd"} CDPidrun] {
							Inf "Cannot Resynthesize File $origfnam"
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
							set msg "Failed To Resynthesize File $origfnam"
							set msg [AddSimpleMessages $msg]
							Inf $msg
							catch {close $CDPidrun}
							continue
						}
						if {![file exists $outfnam]} {
							set msg " Resynthesizing File $origfnam Failed: "
							set msg [AddSimpleMessages $msg]
							Inf $msg
							catch {close $CDPidrun}
							continue
						}
						catch {close $CDPidrun}
						set done 1
					}
				}
				if {!$done} {
					Inf "Failed To Generate Any Tuned Files"
					UnBlock
					continue
				}
				if {$tuner(chans) > 1} {
					set done 0
					foreach c1 $c1_ofnams c2 $c2_ofnams outfnam $final_outfnams {
						if {[file exists $c1] && [file exists $c2]} {
							set cmd [file join $evv(CDPROGRAM_DIR) submix]
							lappend cmd interleave $c1 $c2 $outfnam
							set prg_dun 0
							set prg_abortd 0
							catch {unset simple_program_messages}
							wm title .blocker "PLEASE WAIT:        MERGING CHANNELS OF $outfnam"
							if [catch {open "|$cmd"} CDPidrun] {
								Inf "Cannot Merge Channels Of $outfnam"
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
								set msg "Failed To Merge Channels Of $outfnam"
								set msg [AddSimpleMessages $msg]
								Inf $msg
								catch {close $CDPidrun}
								continue
							}
							if {![file exists $outfnam]} {
								set msg " Merging Channels Of $outfnam Failed: "
								set msg [AddSimpleMessages $msg]
								Inf $msg
								catch {close $CDPidrun}
								continue
							}
							catch {close $CDPidrun}
							set done 1
						}
					}
					if {!$done} {
						Inf "Failed To Produce Any Stereo Output Files"
						UnBlock
						continue
					}
				}
				if {$tuner(keepanal)} {
					set pvkeepfnams [ReverseList $pvkeepfnams]
					foreach ofnam $pvkeepfnams {
						if {[file exists $ofnam]} {
							FileToWkspace $ofnam 0 0 0 0 1
						}
					}
				}
			}
			set n 0
			set m 0
			set lastt {}
			set final_outfnams [ReverseList $final_outfnams]
			while {$n < $incnt} {
				set ofnam [lindex $final_outfnams $n]
				if {[file exists $ofnam]} {
					FileToWkspace $ofnam 0 0 0 0 1
					lappend lastt $ofnam
					incr m
				}
				incr n
			}
			if {$m != $n} {
				Inf "Failed To Generate [expr $n - $m] Tuned Files"
			}
			if {[llength $lastt] > 0} {
				set last_outfile [ReverseList $lastt]
			}
			Inf "Tuned Files Are On The Workspace"
			UnBlock
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Preset all the default values for the tuning program

proc SetAllTunerDefaults {} {
	global tuner
	set tuner(lo) $tuner(default_lo)
	set tuner(hi) $tuner(default_hi)
	set tuner(match) $tuner(default_match)
	set tuner(intune) $tuner(default_intune)
	set tuner(wins) $tuner(default_wins)
	set tuner(nois) $tuner(default_nois)
	set tuner(noformants) 0
	set tuner(ignore) 0
	set tuner(smooth) 0
	set tuner(tlims) 0
}

#--- Set up the entry-box for the tuning-set-file name, if necessary, remembering previous settings

proc SetTuningPitchEntry {} {
	global tuner
	if {$tuner(mode) <= 1} {
		.tuner.00.ll config -text ""
		.tuner.00.e  config -bd 0 -state disabled -disabledbackground [option get . background {}]
		.tuner.00.files config -text "" -command {} -bd 0
		if {$tuner(mode) == 0} {
			if {![info exists tuner(pitchinfo_oldnames)]} {
				set tuner(pitchinfo_oldnames) $tuner(pitchinfo_names)
			}
			set tuner(pitchinfo_names) 0
			.tuner.9.rp.nn config -text "" -state disabled
		} else {
			.tuner.9.rp.nn config -text "INCLUDE NOTE NAMES" -state normal
			if [info exists tuner(pitchinfo_oldnames)] {
				 set tuner(pitchinfo_names) $tuner(pitchinfo_oldnames)
				 unset tuner(pitchinfo_oldnames)
			}
		} 
		if {[info exists tuner(previous_mode)]} {
			switch -- $tuner(previous_mode) {
				2 {
					set tuner(hstuning) $tuner(tuning)
				}	
				3 -
				4 {
					set tuner(hftuning) $tuner(tuning)
				}	
			}
		}
		set tuner(tuning) ""
	} else {
		.tuner.00.ll config -text "Tuning Pitches file"
		.tuner.00.e  config -bd 2 -state normal
		.tuner.00.files config -text "Find File" -command FindTuningFiles -bd 2
		if {![info exists tuner(pitchinfo_oldnames)]} {
			set tuner(pitchinfo_oldnames) $tuner(pitchinfo_names) 
		}
		set tuner(pitchinfo_names) 0
		.tuner.9.rp.nn config -text "" -state disabled
		switch -- $tuner(mode) {
			2 {
				if {[info exists tuner(hstuning)]} {
					set tuner(tuning) $tuner(hstuning)
				}
			}
			3 -
			4 {
				if {[info exists tuner(hftuning)]} {
					set tuner(tuning) $tuner(hftuning)
				}
			}
		}
		set tuner(previous_mode) $tuner(mode)
	}
}

#--- Constrain searches for pitch, within src files, to specified time ranges

proc SetTunerTimeLimits {setlims} {
	global tuner pa evv wstk
	if {[info exists tuner(timeparams)]} {
		set tuner(previous_timeparams) $tuner(timeparams)
	}

	catch {unset tuner(timeparams)}				;#	Remove all time limits to pitch-searches; also flagsging no time limits to be set in cmdline

	if {$setlims} {								;#	If user has indicated time-limits are needed

		if {[info exists tuner(previous_timeparams)]} {
			if {([llength $tuner(infnams)] * 2) == [llength $tuner(previous_timeparams)]} {
				set msg "Use Existing List Of Search Time-limits ?"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "yes"} {
					set tuner(timeparams) $tuner(previous_timeparams)
					set setlims 0
				} else {
					unset tuner(previous_timeparams)
				}
			} else {
				unset tuner(previous_timeparams)
			}
		}
		if {$setlims} {
			foreach fnam $tuner(infnams) {			;#	Set time-range limits where necessary

				set msg "Pitch-search Restricted Timerange For [file rootname [file tail $fnam]] ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					lappend tuner(timeparams) X X	;#	Flag NO time-search limits for this file
				} else {
					set timerange [GetTunerTimeLimits $fnam]
					if {[llength $timerange] < 2} {
						lappend tuner(timeparams) X X
					} else {
						if {[info exists tuner(timeparams)]} {
							set tuner(timeparams) [concat $tuner(timeparams) $timerange]
						} else {
							set tuner(timeparams) $timerange
						}
					}
				}
			}
			set valsentered 0						;#	Check if any timeranges have actually been entered
			if {[info exists tuner(timeparams)]} {
				foreach val $tuner(timeparams) {
					if {![string match $val "X"]} {
						set valsentered 1
						break
					}
				}
				if {!$valsentered} {
					unset tuner(timeparams)
				}
			}
		}
	}
}

#----- Use "Sound View" to enter time-limits for pitch-search in a sound

proc GetTunerTimeLimits {fnam} {
	global evv pa snack_list sn sn_feature sn_peakcnt sn_peakgroupindex sn_windowcnt sn_lofrq sn_hifrq sn_sttwintime sn_endwintime sn_amps

	set sn(edit) 0
	set sn(windows) 0

	catch {unset sn_feature}			;#	SAFETY .... FOR sn_etc variables
	catch {unset sn_peakcnt}
	catch {unset sn_peakgroupindex}
	catch {unset sn_windowcnt}
	catch {unset sn_lofrq}
	catch {unset sn_hifrq}
	catch {unset sn_sttwintime}
	catch {unset sn_endwintime}
	catch {unset sn_amps}

	;#	LAST 5 PARAMETERS OF SnackCreate ( 0  1  0  dur  1  ) ARE...
	;#
	;#	0   (= no specific "listing")
	;#	1 = Enable output of data
	;#	0   (= no specific "pcnt")
	;#	File duration
	;#	1 = quit after sending a single output-pair 
	;#

	set chans  $pa($fnam,$evv(CHANS))
	set insams $pa($fnam,$evv(INSAMS))
	set dur    $pa($fnam,$evv(DUR))
	set sr_x_chs [expr $pa($fnam,$evv(SRATE)) * $chans]

	SnackCreate $evv(TIME_OUT) $evv(SN_TIMEPAIRS) $fnam $insams $sr_x_chs $chans 0 1 0 $dur 1
	if {![info exists snack_list]} {
		return {}
	}
	set snack_list [lindex $snack_list 0]

	;#		IF TIME RANGE DOESN'T DIFFER SIGNIFICANTLY FROM WHOLE FILE, DON'T RETURN IT

	if {[Flteq [lindex $snack_list 0] 0.0] && [Flteq [lindex $snack_list 1] $pa($fnam,$evv(DUR))]} {		
		return {}
	}
	return $snack_list
}

proc FindTuningFiles {} {
	global tuner wl pa evv pr_tuningfiles
	foreach fnam [$wl get 0 end] {
		if {[IsAListofNumbers $pa($fnam,$evv(FTYP))] && ($pa($fnam,$evv(MINNUM)) >= 4) && ($pa($fnam,$evv(MAXNUM)) <= 127)} {
			lappend fnams $fnam
		}
	}
	if {![info exists fnams]} {
		Inf "No Tuning Files On Workspace"
		return {}
	}
	set one_only 0
	if {[llength $fnams] == 1}  {
		set one_only 1
	}
	set f .tuningfiles
	if [Dlg_Create $f "TUNING FILES" "set pr_tuningfiles 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0] 
		set f1 [frame $f.1] 
		button $f0.ok -text "Select File" -command "set pr_tuningfiles 1" -bg $evv(EMPH)  -highlightbackground [option get . background {}]
		button $f0.quit -text "Abandon" -command "set pr_tuningfiles 0"  -highlightbackground [option get . background {}]
		pack $f0.ok -side left -pady 6
		pack $f0.quit -side right
		pack $f0 -side top -fill x -expand true

		label $f.ll -text "\"Control-click\" to see file contents" -fg $evv(SPECIAL)
		pack $f.ll -side top -pady 6
		label $f1.tit -text "Possible Tuning Files" -fg $evv(SPECIAL)
		Scrolled_Listbox $f1.ll -width 60 -height 20 -selectmode single
		pack $f1.tit $f1.ll -side top -fill x -expand true -pady 2
		pack $f1 -side top -fill x -expand true
		bind $f.1.ll.list <Control-ButtonRelease-1> {SeeTuning %y}
		bind $f <Escape> {set pr_tuningfiles 0}
		bind $f <Return> {set pr_tuningfiles 1}
		wm resizable $f 0 0
	}
	$f.1.ll.list delete 0 end
	foreach fnam $fnams {
		$f.1.ll.list insert end $fnam
	}
	set pr_tuningfiles 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_tuningfiles $f.1.ll.list
	while {!$finished} {
		tkwait variable pr_tuningfiles
		if {$pr_tuningfiles} {
			if {$one_only} {
				set tuner(tuning) [lindex $fnams 0]
			} else {
				set i [$f.1.ll.list curselection]
				if {$i < 0} {
					Inf "No File Selected"
					continue
				}
				set tuner(tuning) [lindex $fnams $i]
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc SeeTuning {y} {
	set i [.tuningfiles.1.ll.list nearest $y]
	set fnam [.tuningfiles.1.ll.list get $i]
	SimpleDisplayTextfile $fnam
}

#--- Setup Al;ternative Tuning systems for Harmonic Fields

proc AlternativeTunings {} {
	global pr_just tuner just evv

	set f .just
	if [Dlg_Create $f "OTHER TUNINGS" "set pr_just 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0] 
		set f1 [frame $f.1] 
		set f2 [frame $f.2] 
		set f3 [frame $f.3] 
		set f4 [frame $f.4] 
		button $f0.ok -text "Set Tuning" -command "set pr_just 1" -bg $evv(EMPH)  -highlightbackground [option get . background {}]
		button $f0.quit -text "Abandon" -command "set pr_just 0"  -highlightbackground [option get . background {}]
		pack $f0.ok -side left -pady 6
		pack $f0.quit -side right
		pack $f0 -side top -fill x -expand true

		label $f.00 -text "Scale Type" -fg $evv(SPECIAL)
		pack $f.00 -side top -anchor w -pady 2

		radiobutton $f1.0 -text "Non-concert-pitch Chromatic" -variable just(type) -value 1
		radiobutton $f1.1 -text "Diatonic Major" -variable just(type) -value 2
		radiobutton $f1.2 -text "Harmonic Minor" -variable just(type) -value 3
		radiobutton $f1.3 -text "Pythagorean Diatonic" -variable just(type) -value 4
		radiobutton $f1.4 -text "Intense Diatonic" -variable just(type) -value 5
		radiobutton $f1.5 -text "Alternative Diatonic" -variable just(type) -value 6
		set just(type) 0
		pack $f1.0 $f1.1 $f1.2 $f1.3 $f1.4 $f1.5 -side top -anchor w
		pack $f.1 -side top -fill x -expand true -pady 2
		frame $f.10
		label $f.10.ll -text "Reference Pitch (Range 4 to 127)"
		entry $f.10.e -textvariable just(refpitch) -width 8
		set just(refpitch) ""
		pack  $f.10.ll $f.10.e -side left -padx 2
		pack $f.10 -side top -fill x -expand true -pady 2

		radiobutton $f2.1 -text "C"  -variable just(refp) -value 60 -width 3 -command "set just(refpitch) 60"
		radiobutton $f2.2 -text "C#" -variable just(refp) -value 61 -width 3 -command "set just(refpitch) 61"
		radiobutton $f2.3 -text "D"  -variable just(refp) -value 62 -width 3 -command "set just(refpitch) 62"
		radiobutton $f2.4 -text "Eb" -variable just(refp) -value 63 -width 3 -command "set just(refpitch) 63"
		radiobutton $f2.5 -text "E"  -variable just(refp) -value 64 -width 3 -command "set just(refpitch) 64"
		radiobutton $f2.6 -text "F"  -variable just(refp) -value 65 -width 3 -command "set just(refpitch) 65"
		radiobutton $f3.1 -text "F#" -variable just(refp) -value 66 -width 3 -command "set just(refpitch) 66"
		radiobutton $f3.2 -text "G"  -variable just(refp) -value 67 -width 3 -command "set just(refpitch) 67"
		radiobutton $f3.3 -text "Ab" -variable just(refp) -value 68 -width 3 -command "set just(refpitch) 68"
		radiobutton $f3.4 -text "A"  -variable just(refp) -value 69 -width 3 -command "set just(refpitch) 69"
		radiobutton $f3.5 -text "Bb" -variable just(refp) -value 70 -width 3 -command "set just(refpitch) 70"
		radiobutton $f3.6 -text "B"  -variable just(refp) -value 71 -width 3 -command "set just(refpitch) 71"
		set just(refp) 0
		pack $f2.1 $f2.2 $f2.3 $f2.4 $f2.5 $f2.6 -side left
		pack $f2 -side top -fill x -expand true
		pack $f3.1 $f3.2 $f3.3 $f3.4 $f3.5 $f3.6 -side left
		pack $f3 -side top -fill x -expand true

		label $f4.ll -text "Tuning File name"
		entry $f4.e -textvariable just(fnam) -width 24
		pack $f4.ll $f4.e -side top -pady 2
		pack $f4 -side top

		bind $f <Escape> {set pr_just 0}
		bind $f <Return> {set pr_just 1}
		wm resizable $f 0 0
	}
	set pr_just 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_just $f.10.e
	while {!$finished} {
		tkwait variable pr_just
		if {$pr_just} {
			if {$just(type) <= 0} {
				Inf "No Tuning Type Set"
				continue
			}
			if {[string length $just(refpitch)] <= 0} {
				Inf "No Reference Pitch Entered"
				continue
			}
			if {![IsNumeric $just(refpitch)] || ($just(refpitch) < 4) || ($just(refpitch) > 127)} {
				Inf "Reference Pitch Out Of Range (4-127)"
				continue
			}
			if {[string length $just(fnam)] <= 0} {
				Inf "No Tuning-file Name Entered"
				continue
			}
			if {![ValidCDPRootname $just(fnam)]} {
				continue
			}
			set outfnam [string tolower $just(fnam)]
			append outfnam $evv(TEXT_EXT)
			if {[file exists $outfnam]} {
				Inf "File $outfnam Already Exists : Please Choose A Different Name"
				continue
			}
			set pp $just(refpitch)
			while {$pp > 4} {
				set pp [expr $pp - 12.0]
			}
			set pp [expr $pp + 12.0]
			set pitches $pp			;#	e.g. C
			set ppf [MidiToHz $pp]
			switch -- $just(type) {
				1 {
					set pp [expr $pp + 1]
					lappend pitches $pp
					set pp [expr $pp + 1]
					lappend pitches $pp
					set pp [expr $pp + 1]
					lappend pitches $pp
					set pp [expr $pp + 1]
					lappend pitches $pp
					set pp [expr $pp + 1]
					lappend pitches $pp
					set pp [expr $pp + 1]
					lappend pitches $pp
					set pp [expr $pp + 1]
					lappend pitches $pp
					set pp [expr $pp + 1]
					lappend pitches $pp
					set pp [expr $pp + 1]
					lappend pitches $pp
					set pp [expr $pp + 1]
					lappend pitches $pp
				}
				2 {
					set pp [expr $pp + 2]	;#	e.g. D
					lappend pitches $pp
					set pp [expr $pp + 2]	;#	e.g. E
					lappend pitches $pp
					set pp [expr $pp + 1]	;#	e.g. F
					lappend pitches $pp
					set pp [expr $pp + 2]	;#	e.g. G
					lappend pitches $pp
					set pp [expr $pp + 2]	;#	e.g. A
					lappend pitches $pp
					set pp [expr $pp + 2]	;#	e.g. B
					lappend pitches $pp
				}
				3 {
					set pp [expr $pp + 2]	;#	e.g. D
					lappend pitches $pp
					set pp [expr $pp + 1]	;#	e.g. Eb
					lappend pitches $pp
					set pp [expr $pp + 2]	;#	e.g. F
					lappend pitches $pp
					set pp [expr $pp + 2]	;#	e.g. G
					lappend pitches $pp
					set pp [expr $pp + 1]	;#	e.g. Ab
					lappend pitches $pp
					set pp [expr $pp + 3]	;#	e.g. B
					lappend pitches $pp
				}
				4 {
					set ppfa [expr ($ppf * 9.0)/8.0]
					lappend pitches [HzToMidi $ppfa]
					set ppfa [expr ($ppf * 81.0)/64.0]
					lappend pitches [HzToMidi $ppfa]
					set ppfa [expr ($ppf * 4.0)/3.0]
					lappend pitches [HzToMidi $ppfa]
					set ppfa [expr ($ppf * 3.0)/2.0]
					lappend pitches [HzToMidi $ppfa]
					set ppfa [expr ($ppf * 27.0)/16.0]
					lappend pitches [HzToMidi $ppfa]
					set ppfa [expr ($ppf * 243.0)/128.0]
					lappend pitches [HzToMidi $ppfa]
				}
				5 {
					set ppfa [expr ($ppf * 9.0)/8.0]
					lappend pitches [HzToMidi $ppfa]
					set ppfa [expr ($ppf * 5.0)/4.0]
					lappend pitches [HzToMidi $ppfa]
					set ppfa [expr ($ppf * 4.0)/3.0]
					lappend pitches [HzToMidi $ppfa]
					set ppfa [expr ($ppf * 3.0)/2.0]
					lappend pitches [HzToMidi $ppfa]
					set ppfa [expr ($ppf * 5.0)/3.0]
					lappend pitches [HzToMidi $ppfa]
					set ppfa [expr ($ppf * 15.0)/8.0]
					lappend pitches [HzToMidi $ppfa]
				}
				6 {
					set ppfa [expr ($ppf * 9.0)/8.0]
					lappend pitches [HzToMidi $ppfa]
					set ppfa [expr ($ppf * 5.0)/4.0]
					lappend pitches [HzToMidi $ppfa]
					set ppfa [expr ($ppf * 4.0)/3.0]
					lappend pitches [HzToMidi $ppfa]
					set ppfa [expr ($ppf * 3.0)/2.0]
					lappend pitches [HzToMidi $ppfa]
					set ppfa [expr ($ppf * 27.0)/16.0]
					lappend pitches [HzToMidi $ppfa]
					set ppfa [expr ($ppf * 15.0)/8.0]
					lappend pitches [HzToMidi $ppfa]
				}
			}
			if [catch {open $outfnam "w"} zit] {
				Inf "Cannot Open Output File $just(fnam)"
				continue
			}
			foreach pitch $pitches {
				puts $zit $pitch
			}
			close $zit
			FileToWkspace $outfnam 0 0 0 0 1
			SetTuningPitchEntry
			set tuner(tuning) $outfnam
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#------ Capture tuning pitch output from SPECTUNE process

proc HandleProcessOutputWithPitchValueOutput {} {
	global CDPidrun prg_dun prg_abortd simple_program_messages pitch_info_message

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
		} elseif [string match INFO:* $line] {
			lappend pitch_info_message $line
			return
		} elseif [string match END:* $line] {
			set prg_dun 1
			return
		}
	}
	update idletasks
}

#--- Retrieve pitch value

proc GetTunedPitchData {} {
	global pitch_info_message
	if {![info exists pitch_info_message]} {
		return ""
	}
	set isdecpoint 1
	foreach line $pitch_info_message {
		if {![string first "Transposing from MIDI" $pitch_info_message] > 0} {
			continue
		}
		set line [string trim $line]	
		set line [split $line]
		set cnt 0
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}					;#				0		1		   2	3		4	  5			6	  7  8	  9		  10    
			if {$cnt == 6} {	;#	message is INFO: Transposing from MIDI foundpitch to TUNING-PITCH :  by ratio transposratio
				set tuningval $item

				set vallen [string length $tuningval]
				set decpointpos [string first "." $tuningval]	;#	Look for decpoint
				if {$decpointpos >= 0} {
					set isdecpoint 1
					set nuval ""
					if {$decpointpos > 0} {						;#	Get any digits before decpoint
						incr decpointpos -1
						append nuval [string range $tuningval 0 $decpointpos]
						incr decpointpos
					}
					incr decpointpos
					if {$decpointpos < $vallen} {				;#	If decpoint not at end of value
						append nuval "p"						;#	replace decpoint by "p" and append digits after decpoint
						append nuval [string range $tuningval $decpointpos end]
					} else {									;#	Otherwise, ignore decpoint
						set isdecpoint 0
					}
					set tuningval $nuval

					if {$isdecpoint} {
						set valend [string length $tuningval]
						incr valend -1							;#	"valend" is now position of final digit
						while {$valend > 0} {					;#	Eliminate trailing zeros
							if {[string match [string index $tuningval $valend] "0"]} {
								incr valend -1
							} else {
								break							;#	valend is now position of first non-zero digit (or decpoint) 
							}									;#	before end of number
						}
																;#	If decpoint is now at valend
						if {[string match [string index $tuningval $valend] "p"]} {	
							incr valend -1						;#	( i.e. followed entirely by zeros) ignore it
						}
						set tuningval [string range $tuningval 0 $valend]
					}
				}
				break
			}
			incr cnt
		}
		if {[info exists tuningval]} {
			break
		}
	}
	if {![info exists tuningval]} {
		return ""
	}
	return $tuningval
}

proc TunerHelp {} {
	set msg "TUNE SOUNDS\n"	
	append msg "\n"
	append msg "Tune each sound, in a set of input sounds, to the nearest pitch of a \"Tuning Set\".\n"
	append msg "\n"
	append msg "Input files must be all mono soundfiles or all stereo.\n"
	append msg "(In the stereo case it is assumed that both channels have the SAME tuning).\n"
	append msg "Tuned output files take the name of the input file, with a suffix (you specify).\n"
	append msg "(The actual tuned pitch value can also be appended to the output name).\n"
	append msg "\n"
	append msg "The process finds the MOST PROMINENT pitch in the source,\n"
	append msg "and tunes this to the nearest pitch in the tuning set or field.\n"
	append msg "(If there are other pitches, or pitchglides, in the source\n"
	append msg " these will be pitchshifted by the same amount as the most prominent pitch).\n"
	append msg "NB A file may have NO prominent pitch, so the process will NOT retune that sound.\n"
	append msg "NB The retuning is NOT GUARANTEED TO BE ACCURATE in all cases!!\n"
	append msg "\n"
	append msg "The tuning set is either ....\n"
	append msg "(1)  The tempered-scale at concert pitch.\n"
	append msg "(2)  A set of specified MIDI pitches (possibly fractional). (\"Harmonic Set\").\n"
	append msg "(3)  A set of specified MIDI pitches and their octave equivalents. (\"Harmonic Field\").\n"
	append msg "\n"
	append msg "Options 2 and 3 are defined by TEXTFILES which list the required MIDI values.\n"
	append msg "NB Do NOT put these on the \"Chosen Files\" list.\n"
	append msg "\n"
	append msg "These can be created on the workspace (\"ANY/ALL FILES\" --> \"CREATE A TEXTFILE\")\n"
	append msg "or elsewhere (e.g. \"CREATE\" on the \"Table Editor\").\n"
	append msg "\n"
	append msg "One such file (or a previously created file which is on the workspace)\n"
	append msg "can then be selected from the \"TUNE SOUNDS\" interface itself\n"
	append msg "by clicking on the \"Harmonic Set\" or \"Harmonic Field\" button\n" 
	append msg "(when an entry box for the name of the file, and a \"Find File\" button, will appear).\n"
	append msg "You can then ...\n"
	append msg "(1)  Write the (full) filename in the entry box, OR\n"
	append msg "(2)  Use the \"Find File\" button, to select a tuning file from a displayed list.\n"
	append msg "\n"
	append msg "Various alternative tunings can be generated, using the \"Other\" button.\n"
	append msg "Such tunings are saved in textfiles which can then be recalled later\n"
	append msg "using the \"Harmonic Field\" button.\n"
	append msg "\n"
	append msg "In assessing the pitches of the source, unless otherwise specified,\n"
	append msg "the entire sourcefile is searched.\n"
	append msg "However, you can choose to specify regions of each sound\n"
	append msg "which you feel have the most prominent pitch information,\n"
	append msg " by setting TIME LIMITS within each source for the pitch-search.\n"
	append msg "(The pitch search will then ignore other areas of the sound ).\n"
	append msg "\n"
	append msg "To do this, use the \"Set Time Limits\" option, and then, for each sound,\n"
	append msg "(1)  Define a search-range on the visual/audible sound-display which appears OR\n"
	append msg "(2)  Choose to allow the whole sound to be searched.\n"
	append msg "\n"
	append msg "By default, retuning is done on the SPECTRUM (preserving original duration).\n"
	append msg "You can opt to retune by changing the sampling rate (duration changes).\n"
	append msg "\n"
	append msg "Also ......\n"
	append msg "(1) In spectral-returning, source formant envelope is preserved. You can override this.\n"
	append msg "(2) Assessing which pitch is most prominent takes into account the relative loudness\n"
	append msg "          of any pitched windows found. You can ignore relative loudness.\n"
	append msg "(3) The initial pitch-data extracted is NOT smoothed. You can smooth it.\n"
	append msg "\n"
	append msg "In spectral-returning, you may wish to keep the intermediate retuned analysis files\n"
	append msg "for further spectral modification.  To do this, use the checkbutton on the interface.\n"
	Inf $msg
}

#--- Sort workspace files by pitch

proc PitchSort {} {
	global wl pa evv sort_pitches prg_dun prg_abortd simple_program_messages CDPidrun

	set ilist [$wl curselection]
	if {[llength $ilist] < 2} {
		Inf "Select Mono Or Stereo Soundfiles"
		return
	}
	foreach i $ilist {
		set fnam [$wl get $i]
		if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) > 2)} {
			Inf "Select Mono Or Stereo Soundfiles"
			return
		}
		lappend fnams $fnam
		lappend chans $pa($fnam,$evv(CHANS))
	}

	# DEFAULTS USED
	# tuner(match)  5
	# tuner(lo)		4
	# tuner(hi)		127
	# tuner(intune) 1
	# tuner(wins)	2
	# tuner(nois)	80

	catch {unset sort_pitches}
	Block "Finding Pitches of Files"
	set n 0
	foreach fnam $fnams chancnt $chans {
		set infnam $evv(DFLT_OUTNAME)
		append infnam $n $evv(SNDFILE_EXT)
		switch -- $chancnt {
			1 {
				if [catch {file copy $fnam infnam} zit] {
					Inf "Failed To Copy File [file rootname [file tail [[$fnam]]"
					DeleteAllTemporaryFiles
					UnBlock
					return
				}
			}
			2 {
				set cmd [file join $evv(CDPROGRAM_DIR) housekeep]
				lappend cmd chans 4 $fnam $infnam
				set prg_dun 0
				set prg_abortd 0
				catch {unset simple_program_messages}
				wm title .blocker "PLEASE WAIT:        CONVERTING TO MONO [file rootname [file tail $fnam]]"
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "Failed To Run Convert-to-mono [file rootname [file tail [[$fnam]]"
					catch {unset CDPidrun}
					DeleteAllTemporaryFiles
					UnBlock
					return
				} else {
					fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				if {!$prg_dun} {
					Inf "Failed In Converting To Mono [file rootname [file tail [[$fnam]]"
					catch {unset CDPidrun}
					DeleteAllTemporaryFiles
					UnBlock
					return
				}
				catch {close $CDPidrun}
				if {![file exists $infnam]} {
					Inf "Failed To Convert To Mono [file rootname [file tail [[$fnam]]"
					catch {unset CDPidrun}
					DeleteAllTemporaryFiles
					UnBlock
					return
				}
			}
		}
		lappend infnams $infnam
		incr n
	}
	
	foreach origfnam $fnams infnam $infnams {
		set outfnam [file rootname $infnam]
#RWD 2023 was ANALFILE_EXT
		append outfnam $evv(ANALFILE_OUT_EXT)
		set cmd [file join $evv(CDPROGRAM_DIR) pvoc]
		lappend cmd anal 1 $infnam $outfnam -c1024 -o3
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		wm title .blocker "PLEASE WAIT:    EXTRACTING SPECTRUM OF [file rootname [file tail $origfnam]]"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "Failed To Run Spectrum Extraction On [file rootname [file tail $origfnam]]"
			catch {unset CDPidrun}
			DeleteAllTemporaryFiles
			UnBlock
			return
		} else {
			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			Inf "Failed In Extracting Spectrum Of [file rootname [file tail $origfnam]]"
			catch {unset CDPidrun}
			DeleteAllTemporaryFiles
			UnBlock
			return
		}
		catch {close $CDPidrun}
		if {![file exists $outfnam]} {
			Inf "Failed To Extract Spectrum Of [file rootname [file tail $origfnam]]"
			catch {unset CDPidrun}
			DeleteAllTemporaryFiles
			UnBlock
			return
		}
		lappend outfnams $outfnam
	}

	foreach origfnam $fnams fnam $outfnams {
		set cmd [file join $evv(CDPROGRAM_DIR) spectune]
		lappend cmd tune 4 $fnam -l4 -h127 -m5 -i1 -w2 -n80
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		wm title .blocker "PLEASE WAIT:        FINDING PITCH OF [file rootname [file tail $origfnam]]"
		if [catch {open "|$cmd"} CDPidrun] {
			lappend badfiles $origfnam
			lappend sort_pitches "0"
			catch {unset CDPidrun}
			continue
		} else {
			fileevent $CDPidrun readable "HandleProcessOutputGrabingPitch"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			lappend badfiles $origfnam
			lappend sort_pitches "0"
			catch {close $CDPidrun}
			continue
		}
		catch {close $CDPidrun}
	}
	if {![info exists sort_pitches]} {
		DeleteAllTemporaryFiles
		Inf "No Pitches Detected"
		UnBlock
		return
	}
	set len [llength $fnams]
	if {[llength $sort_pitches] != $len} {
		DeleteAllTemporaryFiles
		Inf "Anomalous Number Of Pitches Detected"
		UnBlock
		return
	}
	if [info exists badfiles] {
		set msg "No Pitch Was Detected For The Following Files"	
		set cnt 0
		foreach fnam $badfiles {
			append msg "\n[file rootname [file tail $fnam]]"
			incr cnt
			if {$cnt >= 20} {
				append msg "\nAND MORE"
				break
			}
		}
		Inf $msg
	}
	wm title .blocker "PLEASE WAIT:        SORTING FILES TO PITCH ORDER"
	set len_less_one [expr $len -1]
	set n 0 
	while {$n < $len_less_one} {
		set fnam_n [lindex $fnams $n]
		set pich_n [lindex $sort_pitches $n]
		set m $n
		incr m
		while {$m < $len} {
			set fnam_m [lindex $fnams $m]
			set pich_m [lindex $sort_pitches $m]
			if {$pich_m < $pich_n} {
				set fnams [lreplace $fnams $n $n $fnam_m]
				set fnams [lreplace $fnams $m $m $fnam_n]
				set sort_pitches [lreplace $sort_pitches $n $n $pich_m]
				set sort_pitches [lreplace $sort_pitches $m $m $pich_n]
				set fnam_n $fnam_m
				set pich_n $pich_m
			}
			incr m
		}
		incr n
	}
	set ilist [ReverseList $ilist]
	foreach i $ilist {
		$wl delete $i
	}
	foreach fnam $fnams {
		$wl insert 0 $fnam
	}
	DeleteAllTemporaryFiles
	UnBlock
}
		
#------ Display info returned by running pitch-detect mode of spectune

proc HandleProcessOutputGrabingPitch {} {
	global CDPidrun prg_dun prg_abortd simple_program_messages sort_pitches

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
		} elseif {[string first "INFO: " $line] >= 0} {
			lappend sort_pitches [string range $line 6 end]
			return
		} elseif [string match END:* $line] {
			set prg_dun 1
			return
		}
	}
	update idletasks
}

#---- Shrink or expand multichannel file spread

proc MchShrink {} {
	global wl chlist pa evv pr_mchshrink mcs prg_dun prg_abortd CDPidrun wstk

	if {[info exists chlist] && ([llength $chlist] == 1)} {
		set fnam [lindex $chlist 0]
		if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) == 1)} {
			unset fnam
		}
	}
	if {![info exists fnam]} {
		set i [$wl curselection]
		if {![info exists i] || ([llength $i] != 1) || ($i == -1)} {
			Inf "Select A Soundfile With More Than 1 Channel"
			return
		}
		set fnam [$wl get $i]
	}
	set inchans $pa($fnam,$evv(CHANS))
	set srcfnam [file rootname $fnam]
	set n 1
	while {$n <= $inchans} {						;#	Set up temporary names of extracred channels
		set chanfnam $srcfnam
		append chanfnam "_c" $n $evv(SNDFILE_EXT)
		lappend chanfnams $chanfnam
		incr n
	}
	set got_channels 0
	foreach chanfnam $chanfnams {
		if {[file exists $chanfnam]} {
			set msg "File $chanfnam Already Exists: Use Existing Channel_extracted Files ??"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				Inf "As A File Named $chanfnam Already Exists: Cannot Proceed"
				return
			} else {
				set got_channels 1
				break
			}
		}
	}
	set f .mchshrink
	if [Dlg_Create $f "SPACE WARP MULTICHANNEL SOUND" "set pr_mchshrink 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0] 
		set f1 [frame $f.1] 
		set f2 [frame $f.2] 
		set f3 [frame $f.3] 
		set f4 [frame $f.4] 
		button $f0.ok -text "Warp" -command "set pr_mchshrink 1" -bg $evv(EMPH)  -highlightbackground [option get . background {}]
		button $f0.quit -text "Abandon" -command "set pr_mchshrink 0"  -highlightbackground [option get . background {}]
		pack $f0.ok -side left -pady 6
		pack $f0.quit -side right
		pack $f0 -side top -fill x -expand true

		label $f1.ll -text "Contraction/Expansion (Range 0 - 8)"
		entry $f1.e  -textvariable mcs(shr) -width 8
		pack $f1.e $f1.ll -side left -padx 2 
		pack $f.1 -side top -pady 2 -fill x -expand true 

		label $f2.ll -text "Rotation (Whole number of output channels)"
		entry $f2.e  -textvariable mcs(rot) -width 8
		pack $f2.e $f2.ll -side left -padx 2 
		pack $f.2 -side top -pady 2 -fill x -expand true 

		label $f3.ll -text "Channel-count of Output file (Range 2 to 16)"
		entry $f3.e  -textvariable mcs(ochans) -width 8
		pack $f3.e $f3.ll -side left -padx 2 
		pack $f.3 -side top -pady 2 -fill x -expand true 

		label $f4.ll -text "Output Filename"
		entry $f4.e  -textvariable mcs(ofnam) -width 8
		pack $f4.e $f4.ll -side left -padx 2 
		pack $f.4 -side top -pady 2

		bind $f.1.e <Down> {focus .mchshrink.2.e}
		bind $f.2.e <Down> {focus .mchshrink.3.e}
		bind $f.3.e <Down> {focus .mchshrink.4.e}
		bind $f.4.e <Down> {focus .mchshrink.1.e}

		bind $f.1.e <Up> {focus .mchshrink.4.e}
		bind $f.2.e <Up> {focus .mchshrink.1.e}
		bind $f.3.e <Up> {focus .mchshrink.2.e}
		bind $f.4.e <Up> {focus .mchshrink.3.e}

		bind $f <Escape> {set pr_mchshrink 0}
		bind $f <Return> {set pr_mchshrink 1}
		wm resizable $f 0 0
	}
	set pr_mchshrink 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_mchshrink $f.1.e
	while {!$finished} {
		tkwait variable pr_mchshrink
		if {$pr_mchshrink} {
			if {([string length $mcs(shr)] <= 0) || ![IsNumeric $mcs(shr)] || ($mcs(shr) < 0) || ($mcs(shr) > 8)} {
				Inf "Invalid Contraction/expansion Value (range 0 to 8)"
				continue
			}
			if {([string length $mcs(rot)] <= 0) || ![IsNumeric $mcs(rot)] || ![regexp {^[0-9]+$} $mcs(rot)]} {
				Inf "Invalid Rotation Value (whole number)"
				continue
			}
			if {([string length $mcs(ochans)] <= 0) || ![IsNumeric $mcs(ochans)] || ![regexp {^[0-9]+$} $mcs(ochans)]  || ($mcs(ochans) < 2) || ($mcs(ochans) > 16)} {
				Inf "Invalid Outfile Channel Count (range 2 to 16)"
				continue
			}
			set thisrot $mcs(rot)
			while {$thisrot < 0} {
				incr thisrot $mcs(ochans)
			}
			set thisrot [expr $thisrot % $mcs(ochans)]

			if {![ValidCDPRootname $mcs(ofnam)]} {
				continue
			}
			set outfnam [string tolower $mcs(ofnam)]
			append outfnam $evv(SNDFILE_EXT)
			if {[file exists $outfnam]} {
				Inf "File $outfnam Already Exists : Please Choose A Different Name"
				continue
			}
			set mixfile [string tolower $mcs(ofnam)]
			append mixfile [GetTextfileExtension mmx]
			if {[file exists $mixfile ]} {
				Inf "File $mixfile Already Exists : Please Choose A Different Name"
				continue
			}
			catch {unset mixlines}
			set line $mcs(ochans)		;#	Establish channel count of output file in multichannel mixfile
			lappend mixlines $line
			
			Block "WARPING MULTICHANNEL SPACE"

			if {!$got_channels} {
				set cmd [file join $evv(CDPROGRAM_DIR) housekeep]
				lappend cmd chans 2 $fnam
				set prg_dun 0
				set prg_abortd 0
				wm title .blocker "EXTRACTING CHANNELS OF [file rootname [file tail $fnam]]"
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "Failed To Run Channel Extraction On [file rootname [file tail $fnam]]"
					catch {unset CDPidrun}
					UnBlock
					set finished 1
					break
				} else {
					fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				if {!$prg_dun} {
					Inf "Failed In Extracting Channels Of [file rootname [file tail $fnam]]"
					catch {unset CDPidrun}
					UnBlock
					set finished 1
					break
				}
				catch {close $CDPidrun}
				set n 1
				set OK 1

				foreach chanfnam $chanfnams {
					if {![file exists $chanfnam]} {
						Inf "Failed To Extract Channel $n OF [file rootname [file tail $fnam]]"
						catch {unset CDPidrun}
						set OK 0
						break
					}
					incr n
				}
				if {!$OK} {
					UnBlock
					set finished 1
					break
				}
			}
			wm title .blocker "CONSTRUCTING MIXFILE"
			set ichan 1
			foreach ifnam $chanfnams {
				set line [list $ifnam 0.0 1]				;#	Each line starts at 0 with a mono source

				set chan [expr $ichan - 1]					;#	Change to 0 to (N-1) range
				set chan [expr double($chan) * $mcs(shr)]	;#	Shrink/expand

				set lchan [expr int(floor($chan))]			;#	Left channel
				set pos   [expr $chan - double($lchan)]		;#	Find positioning of output between L and R lspkrs
	
				if {[Flteq $pos 0.0]} {						;#	If output centred in a single lspkr
					incr lchan $thisrot						;#	Rotate output frame
					set lchan [expr $lchan % $mcs(ochans)]	;#	Resolve spatial-overflows in output channel-frame
					incr lchan								;#	Change back to 1-M range
					set rout 1								;#	routing from input channel
					append rout ":" $lchan					;#	route output to output channel
					lappend line $rout 1.0					;#	Add routing to line, at normal level
				} else {
					incr lchan $thisrot						;#	Rotate output frame
					set lchan [expr $lchan % $mcs(ochans)]	;#	Resolve spatial-overflows in output channel-frame
					set rchan [expr $lchan + 1]				;#	Setup RH channel
					set rchan [expr $rchan % $mcs(ochans)]	
					set levels [HoleInMiddle $pos]
					set lgain [lindex $levels 0]
					set rgain [lindex $levels 1]
					incr lchan								;#	Convert to Range 1-M
					incr rchan
					set rout 1								;#	routing from input channel
					append rout ":" $lchan					;#	route input to L output channel
					lappend line $rout $lgain				;#	at appropriate level
					set rout 1
					append rout ":" $rchan					;#	route input to R output channel
					lappend line $rout $rgain				;#	at appropriate level
				}
				lappend mixlines $line						;#	Assemble multichannel mixfile lines
				incr ichan
			}
			if [catch {open $mixfile "w"} zit] {
				Inf "Cannot Create Temporary Mixfile ([file tail $mixfile]) To Mix Down The Output"
				UnBlock
				set finished 1
				break
			} else {
				foreach line $mixlines {
					puts $zit $line
				}
				close $zit
			}
			if {!$got_channels} {
				foreach chanfnam $chanfnams {
					if {![string match $fnam [file tail $fnam]]} {
						UpdateBakupLog $chanfnam create 1
					}
					FileToWkspace $chanfnam 0 0 0 0 1
				}
			}
			FileToWkspace $mixfile 0 0 0 0 1
			set msg "Mixfile And Individual Channel Source-files Are On The Workspace"
			append msg "\n\nRun The Mixfile"
			UnBlock
			set finished 1
		} else {
			set finished 1
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc TuneOther {} {
	global tuner
	switch -- $tuner(other) {
		0 {
			if {[info exists tuner(oldkeepanal)]} {
				set tuner(keepanal) $tuner(oldkeepanal)
			}
			.tuner.9.ch config  -text "DON'T try to PRESERVE FORMANTS envelope" -state normal
			.tuner.9.ana config -text "RETAIN tuned ANALYSIS FILES, as well as soundfiles" -state normal
		}
		1 {
			if {[info exists tuner(keepanal)]} {
				set tuner(oldkeepanal) $tuner(keepanal)
			}
			.tuner.9.ch config  -text "" -state disabled
			.tuner.9.ana config -text "" -state disabled
			set tuner(keepanal) 0
		}
	}
}

#--- See comment inside function

proc PitchNamesAdjust {} {
	global wl wstk evv pa pr_pna pna_end chlist ch save_mixmanage scores_refresh

	set ilist [$wl curselection]
	if {![info exists ilist] || ([llength $ilist] <= 0) || (([llength $ilist] == 1) && ($ilist == -1))} {
		Inf "Select Soundfiles To Rename"
		return
	}
	foreach i $ilist {
		lappend fnams [$wl get $i]
	}
	foreach fnam $fnams {
		if {$pa($fnam,$evv(FTYP)) !=  $evv(SNDFILE)} {
			Inf "SELECT SOUNDFILES ONLY ([file rootname [file tail $fnam]] IS NOT A SOUNDFILE)"
			return
		}
	}
	set msg "This Operation Is To Be Used ~~ONLY~~\n"
	append msg "On Filenames Where The (whole-number) Pitch Is In The Name\n"
	append msg "(Possibly Preceded By The Pitchclass Name)\n"
	append msg "But The Files Have Been Subsequently Transposed\n"
	append msg "And The Transposition-value (whole +ve Or -ve Number) Is Also Inserted Into The Name\n"
	append msg "Directly After The Pitch Data.\n"
	append msg "\n"
	append msg "Both The Pitch And The Transposition Value Must Be Preceded By \"_\"\n"
	append msg "\n"
	append msg "Proceed ??"
	set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
	if {$choice == "no"} {
		return
	}
	set f .pna
	if [Dlg_Create $f "ADJUST NAMES OF FILES WITH TUNING-DERIVED NAMES" "set pr_pna 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0] 
		set f1 [frame $f.1] 
		button $f0.ok -text "Adjust Names" -command "set pr_pna 1"  -highlightbackground [option get . background {}]
		button $f0.quit -text "Abandon" -command "set pr_pna 0"  -highlightbackground [option get . background {}]
		pack $f0.ok -side left -pady 6
		pack $f0.quit -side right
		pack $f0 -side top -fill x -expand true
		label $f1.ll -text "How many characters at filename-end to ignore (excluding file extension)"
		entry $f1.e -textvariable pna_end -width 4
		pack $f1.e $f1.ll -side left -padx 2
		pack $f1 -side top -fill x -expand true
		bind $f <Escape> {set pr_pna 0}
		bind $f <Return> {set pr_pna 1}
		wm resizable $f 0 0
	}
	set pna_end 0
	set pr_pna 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_pna $f.1.e
	while {!$finished} {
		tkwait variable pr_pna
		if {$pr_pna} {
			if {([string length $pna_end] <= 0) || ![IsNumeric $pna_end] || ![regexp {^[0-9]+$} $pna_end]} {
				Inf "Invalid Number Of End-characters Entered"
				continue
			}
			foreach fnam $fnams {
				set origfnam $fnam
				set thisext [file extension $fnam]
				if {![string match [file tail $fnam] $fnam]} {
					set thisdir [file dirname $fnam]
				} else {
					set thisdir ""
				}
				set fnam [file rootname [file tail $fnam]]
				set len [string length $fnam]
				set tail ""
				set gotadj 0
				set gotit 0
				if {$pna_end} {
					incr len -$pna_end
					set tail [string range $fnam $len end]
					incr len -1
					set fnam [string range $fnam 0 $len]
					incr len
				}
				set endd [expr $len - 1]
				set n $endd
				while {$n >= 0} {
					if {[string match [string index $fnam $n] "_"]} {
						if {!$gotadj} {
							set adj [string range $fnam [expr $n + 1] $endd]
							set endd [expr $n - 1]
							set gotadj 1
						} else {
							set pp [string range $fnam [expr $n + 1] $endd]
							set fnam [string range $fnam 0 $n]
							set gotit 1
							break
						}
					}
					incr n -1
				}
				if {!$gotadj || !$gotit} {
					lappend nufnams $origfnam
					continue
				}
				set isname 0
				set len [string length $pp]
				set n 0
				while {$n < $len} {
					if {[regexp {^[0-9]$} [string index $pp $n]]} {
						break
					}
					incr n
				}
				if {$n == $len} {
					Inf "Pitch Value Not Found Where Expected In Name [file rootname [file tail $origfnam]]"	
					lappend nufnams $origfnam
					continue
				}
				if {$n > 0} {
					set isname 1
				}
				set pp [string range $pp $n end]

				set nupitch [expr $pp + $adj]
				if {$isname} {
					set nunn [expr $nupitch % 12]
					switch -- $nunn {
						0  {set pclass c}
						1  {set pclass dd}
						2  {set pclass d}
						3  {set pclass eb}
						4  {set pclass e}
						5  {set pclass f}
						6  {set pclass gb}
						7  {set pclass g}
						8  {set pclass ab}
						9  {set pclass a}
						10 {set pclass bb}
						11 {set pclass b}
					}
					append pclass $nupitch
					set nupitch $pclass
				}
				append fnam $nupitch
				if {$pna_end} {
					append fnam $tail
				}
				append fnam $thisext
				set nufnam $thisdir
				append nufnam $fnam
				if {[file exists $nufnam]} {
					Inf "Filename [file rootname [file tail $nufnam]] Already Exist"
					lappend nufnams $origfnam
				}
				lappend nufnams $nufnam
			}
			foreach i $ilist fnam $fnams nufnam $nufnams {
				if {[string match $fnam $nufnam]} {
					continue
				}
				if [catch {file rename $fnam $nufnam} zit] {
					continue
				}

				RenameProps $fnam $nufnam 1
				$wl delete $i
				$wl insert $i $nufnam
				set haspmark [HasPmark $fnam]
				if {$haspmark} {
					MovePmark $fnam $nufnam
				}
				set hasmmark [HasMmark $fnam]
				if {$hasmmark} {
					MoveMmark $fnam $nufnam
				}
				UpdateChosenFileMemory $fnam $nufnam
				set oldname_pos_on_chosen [LstIndx $fnam $ch]
				if {$oldname_pos_on_chosen >= 0} {
					RemoveFromChosenlist $fnam
					set chlist [linsert $chlist $oldname_pos_on_chosen $nufnam]
					$ch insert $oldname_pos_on_chosen $nufnam
				}
				DummyHistory $fnam "RENAMED_$nufnam"
				if {[MixMRename $fnam $nufnam 0]} {
					MixMStore
				}
				if [IsInBlists $fnam] {
					if [RenameInBlists $fnam $nufnam] {
						SaveBL $background_listing
					}
				}
				if [IsOnScore $fnam] {
					RenameOnScore $fnam $nufnam
					set scores_refresh 1
				}
				DataManage rename $fnam $nufnam
				lappend couettelist $fnam $nufnam
				UpdateBakupLog $fnam delete 0
				UpdateBakupLog $nufnam create 1
				CheckMainmix $fnam $nufnam
				CheckMainmixSnd $fnam $nufnam
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

######################################################################
# EXTRACT AVERAGE HARMONIC FIELD OF SOUND SOURCE AND APPLY IT TO SRC #
######################################################################

proc ExtractApplyHF {} {
	global chlist wl pr_eahf evv eahf
	if {[info exists chlist] && (([llength $chlist] == 1) || ([llength $chlist] == 2))} {
		if {[llength $chlist] == 1} {
			set eahf(isxtract) 1
		} elseif {[llength $chlist] == 2} {
			set eahf(isxtract) 0
		}
	} else {
		set ilist [$wl curselection]
		if {![info exists ilist] || ([llength $ilist] < 1) || ([llength $ilist] > 2) || ([lindex $ilist 0] == -1)} {
			Inf "Select files to use : one sound for \"extract\" : a sound and a filter file for \"apply\""
			return
		}
		if {[llength $ilist] == 1} {
			set eahf(isxtract) 1
		} elseif {[llength $ilist] == 2} {
			set eahf(isxtract) 0
		}
	}
	set f .eahf
	if [Dlg_Create $f "EXTRACT OR APPLY HARMONIC FIELD OF SOUND" "set pr_eahf 0" -borderwidth $evv(SBDR)] {
		frame $f.0 
		button $f.0.extract -text "Extract HF" -command "set pr_eahf 1" -width 10 -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $f.0.apply   -text "Apply HF" -command "set pr_eahf 2"   -width 10 -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $f.0.quit    -text "Quit" -command "set pr_eahf 0"       -width 10  -highlightbackground [option get . background {}]
		pack $f.0.extract $f.0.apply $f.0.quit -side left -padx 6
		pack $f.0 -side top -pady 2
		frame $f.1
		label $f.1.0 -text "ONE SOUND is needed as input if HF/PITCH is to be EXTRACTED" -fg $evv(SPECIAL)
		label $f.1.1 -text "A SOUND and A VARIBANK (MIDI) FILTER FILE are needed to APPLY HF to sound" -fg $evv(SPECIAL)
		pack $f.1.0 $f.1.1 -side top -pady 2
		pack $f.1 -side top -pady 2
		bind $f <Escape> {set pr_eahf 0}
		bind $f <Return> {EahfBind}
		wm resizable $f 0 0
	}
	if {$eahf(isxtract)} {
		.eahf.0.apply   config -text "" -command {} -bd 0 -bg [option get . background {}]
		.eahf.0.extract config -text "Extract HF" -command "set pr_eahf 1" -bd 2 -bg $evv(EMPH)
	} else {
		.eahf.0.apply   config -text "Apply HF" -command "set pr_eahf 2" -bd 2 -bg $evv(EMPH)
		.eahf.0.extract config -text "" -command {} -bd 0 -bg [option get . background {}]
	}
	set pr_eahf 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_eahf
	while {!$finished} {
		tkwait variable pr_eahf
		switch -- $pr_eahf {
			1 {
				if {[ExtractHF] > 0} {
					ApplyHF 1
				}
				set finished 1
			}
			2 {
				ApplyHF 0
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

proc EahfBind {} {
	global eahf pr_eahf
	if {$eahf(isxtract)} {
		set pr_eahf 1
	} else {
		set pr_eahf 2
	}
}


#----- EXTRACT THE AVERAGE HARMONIC FIELD OF A SOUND SOURCE

proc ExtractHF {} {
	global chlist wl pa evv pr_ehf ehf prg_dun prg_abortd CDPidrun wstk

	if {[info exists chlist] && ([llength $chlist] == 1)} {
		set fnam [lindex $chlist 0]
	} else {
		set ilist [$wl curselection]
		if {![info exists ilist] || ([llength $ilist] != 1) || ([lindex $ilist 0] == -1)} {
			Inf "Select a (mono) soundfile from which to extract the harmonic field"
			return
		}
		set fnam [$wl get $ilist]
	}
	if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
		Inf "Select a (mono) soundfile from which to extract the harmonic field"
		return
	}
	set dur $pa($fnam,$evv(DUR))
	set ehf(maxtstep) [expr ($dur/2.0) * $evv(SECS_TO_MS)]
	set ismonofied 0
	if {$pa($fnam,$evv(CHANS)) != 1} {
		set msg "Input soundfile is not mono: mix down to mono ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		}
		Block "CONVERTING TO MONO"
		set tempfnam $evv(DFLT_OUTNAME)
		append tempfnam 0 $evv(SNDFILE_EXT)
		set cmd [file join $evv(CDPROGRAM_DIR) housekeep]
		lappend cmd chans 4 $fnam $tempfnam
		set prg_dun 0
		set prg_abortd 0
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "Failed to run conversion to mono"
			catch {unset CDPidrun}
			UnBlock
			return
		} else {
			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			Inf "Failed to convert to mono"
			catch {unset CDPidrun}
			UnBlock
			return
		}
		catch {close $CDPidrun}
		if {![file exists $tempfnam]} {
			Inf "Mono version not created"
			catch {unset CDPidrun}
			UnBlock
			return
		}
		UnBlock
		catch {unset CDPidrun}
		set fnam $tempfnam
		set ismonofied 1
	}
	set ehf(fnam) $fnam
	set ehf(ifnam) [file rootname [file tail $fnam]]
	set ehf(Qdflt) 100
	set ehf(hcntdflt) 16
	set f .ehf
	if [Dlg_Create $f "EXTRACT HARMONIC FIELD OF SOUND" "set pr_ehf 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0] 
		set f1 [frame $f.1] 
		set f2 [frame $f.2] 
		set f3 [frame $f.3] 
		set f3t [frame $f.3t] 
		set f3a [frame $f.3a] 
		set f3b [frame $f.3b] 
		set f3c [frame $f.3c] 
		set f4 [frame $f.4] 
		set f5 [frame $f.5] 
		set f5a [frame $f.5a] 
		set f6 [frame $f.6] 
		set f6a [frame $f.6a] 
		set f7 [frame $f.7] 
		set f8 [frame $f.8] 
		button $f0.ok -text "Run" -command "set pr_ehf 1" -width 4 -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $f0.quitplay -text "Quit Play" -command "set pr_ehf 1" -width 9 -highlightbackground [option get . background {}]
		button $f0.help -text "Help" -command "ExtractHFHelp 1" -width 4 -bg $evv(HELP) -highlightbackground [option get . background {}]
		radiobutton $f0.ok1 -text "View Energy Profile" -variable ehf(ex) -value 1 -command "SwitchEhfState" -width 26
		radiobutton $f0.ok2 -text "Extract average HF" -variable ehf(ex) -value 2 -command "SwitchEhfState" -width 26
		radiobutton $f0.ok3 -text "Track pitch through time" -variable ehf(ex) -value 3 -command "SwitchEhfState" -width 26
		radiobutton $f0.ok4 -text "Track HF through time" -variable ehf(ex) -value 4 -command "SwitchEhfState" -width 26
		button $f0.quit -text "Quit" -command "set pr_ehf 0" -highlightbackground [option get . background {}]
		pack $f0.ok $f0.quitplay $f0.help -side left -pady 3
		pack $f0.ok1 $f0.ok2 $f0.ok3 $f0.ok4 -side left -padx 2
		pack $f0.quit -side right
		pack $f0 -side top -fill x -expand true
		label $f1.ll -text "Analysis channels (Range (256 - 4096) (Use Up/Down Arrows)                                 "
		button $f1.b -text "Default" -command "set ehf(chans) 1024"  -highlightbackground [option get . background {}]
		entry $f1.e -textvariable ehf(chans) -width 4 -state readonly
		set ehf(chans) 1024
		pack $f1.e $f1.b $f1.ll -side left -padx 2
		pack $f1 -side top -fill x -expand true
		label $f2.ll -text "Analysis Overlap (Range 1-4 : Use Left/Right Arrows)"
		button $f2.b -text "Default" -command "set ehf(overlap) 3"  -highlightbackground [option get . background {}]
		entry $f2.e -textvariable ehf(overlap) -width 4 -state readonly
		set ehf(overlap) 3
		pack $f2.e $f2.b $f2.ll -side left -padx 2
		pack $f2 -side top -fill x -expand true

		label $f3.ll -text "Peakcnt : Number of peaks to keep (Range 1 to 64)"
		button $f3.b -text "Default" -command "set ehf(pkcnt) 6"  -highlightbackground [option get . background {}]
		entry $f3.e -textvariable ehf(pkcnt) -width 4 -state normal
		set ehf(pkcnt) 6
		pack $f3.e $f3.b $f3.ll -side left -padx 2
		pack $f3 -side top -fill x -expand true

		label $f3t.ll -text "Timestep : (mS) Range 5 to < $ehf(maxtstep)"
		button $f3t.b -text "Default" -command "set ehf(tstep) 100"  -highlightbackground [option get . background {}]
		entry $f3t.e -textvariable ehf(tstep) -width 4 -state normal
		set ehf(tstep) 100
		pack $f3t.e $f3t.b $f3t.ll -side left -padx 2
		pack $f3t -side top -fill x -expand true

		label $f3a.ll -text "Min pitch : (MIDI : Range 0-127)"
		button $f3a.b -text "Default" -command "set ehf(bot) 0"  -highlightbackground [option get . background {}]
		entry $f3a.e -textvariable ehf(bot) -width 4
		set ehf(bot) 0
		pack $f3a.e $f3a.b $f3a.ll -side left -padx 2
		pack $f3a -side top -fill x -expand true

		label $f3b.ll -text "Max pitch : (MIDI : Range 0-127)"
		button $f3b.b -text "Default" -command "set ehf(top) 127"  -highlightbackground [option get . background {}]
		entry $f3b.e -textvariable ehf(top) -width 4
		set ehf(top) 127
		pack $f3b.e $f3b.b $f3b.ll -side left -padx 2
		pack $f3b -side top -fill x -expand true

		label $f3c.ll -text "Gate : Fraction of maxpeak-level below which signal ignored (Range 0 - 0.95)"
		button $f3c.b -text "Default" -command "set ehf(gate) 0.1"  -highlightbackground [option get . background {}]
		entry $f3c.e -textvariable ehf(gate) -width 4
		set ehf(gate) 0.1
		pack $f3c.e $f3c.b $f3c.ll -side left -padx 2
		pack $f3c -side top -fill x -expand true

		checkbutton $f4.ch -text "Equalise amplitudes, in filter, of selected pitches" -variable ehf(amp)
		pack $f4.ch -side left -padx 2
		pack $f4 -side top -fill x -expand true

		checkbutton $f5.ch -text "Eliminate pitches which are harmonics of lower pitches" -variable ehf(harm)
		pack $f5.ch -side left -padx 2
		pack $f5 -side top -fill x -expand true

		checkbutton $f5a.ch -text "Eliminate pitches at semitone interval to another" -variable ehf(dechrom)
		pack $f5a.ch -side left -padx 2
		pack $f5a -side top -fill x -expand true

		radiobutton $f6a.ch1 -text "No Transposing" -variable ehf(transp) -value 0 -width 18
		radiobutton $f6a.ch2 -text "Filter Down 8va" -variable ehf(transp) -value 1 -width 18
		radiobutton $f6a.ch3 -text "Down TWO 8vas" -variable ehf(transp) -value 2 -width 18
		pack $f6a.ch1 $f6a.ch2 $f6a.ch3 -side left -padx 2
		pack $f6a -side top -fill x -expand true

		label $f6.ch0 -text "Output"
		radiobutton $f6.ch1 -text "MIDI list" -variable ehf(midi) -value 1 -command "EhfQH 0"
		radiobutton $f6.ch2 -text "Varibank datafile" -variable ehf(midi) -value 0 -command "EhfQH 1"
		checkbutton $f6.ch3 -text "Test Listen" -variable ehf(testfilt) -command "EhfDoTestA"
		label $f6.ch4 -text "Filter Q "
		entry $f6.ch5 -textvariable ehf(Q) -width 5
		label $f6.ch6 -text "No of harmonics "
		entry $f6.ch7 -textvariable ehf(hcnt) -width 5
		pack $f6.ch0 $f6.ch1 $f6.ch2 $f6.ch3 $f6.ch4 $f6.ch5 $f6.ch6 $f6.ch7 -side left -padx 2
		pack $f6 -side top -fill x -expand true

		label $f7.ll -text "Output Filename"
		entry $f7.e  -textvariable ehf(ofnam) -width 24
		pack $f7.e $f7.ll -side left -padx 2 
		pack $f.7 -side top -pady 2
		set ehf(ofnam) ""

		label $f8.ll -text ""				;#	PADDING!
		pack $f8.ll -side left -padx 2 
		pack $f.8 -side top -pady 2

		set ehf(ex) 1
		set ehf(bot) 0
		set ehf(top) 127
		set ehf(gate) 0.1
		set ehf(tstep) 100
		set ehf(amp) 0
		set ehf(harm) 0
		set ehf(dechrom) 0
		set ehf(midi) 0
		set ehf(testfilt) 0
		set ehf(transp) 0
		set ehf(flagsave) 0
		set ehf(transpsave) 0
		SwitchEhfState

		bind $f <Up> {IncrEhfChans 0}
		bind $f <Down> {IncrEhfChans 1}
		bind $f <Left> {IncrEhfOverlap 1}
		bind $f <Right> {IncrEhfOverlap 0}

		bind $f <Escape> {set pr_ehf 0}
		wm resizable $f 0 0
	}
	.ehf.0.ok config -text "Run" -width 4 -bd 2 -bg $evv(EMPH)
	.ehf.0.quitplay config -text "" -command {} -bd 0
	set ehf(outsfnam) $evv(DFLT_OUTNAME)
	set ehf(continue) 0
	append ehf(outsfnam) $evv(SNDFILE_EXT)
	set ehf(ofnam) $ehf(ifnam)
	switch -- $ehf(ex) {
		1 {
			.ehf.0.ok config -command "set pr_ehf 1"
		}
		2 {
			.ehf.0.ok config -command "set pr_ehf 2"
			append ehf(ofnam) "_hf"
		 }
		3 {		
			.ehf.0.ok config -command "set pr_ehf 3"
			append ehf(ofnam) "_vp"
		}
		4 { 
			.ehf.0.ok config -command "set pr_ehf 4"
			append ehf(ofnam) "_vhf"
		}
	}
	catch {unset ehf(maxhcnt)}
	catch {unset ehf(maxmidi)}
	set pr_ehf 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_ehf $f.1.e
	while {!$finished} {
		DeleteAllTemporaryFiles
		tkwait variable pr_ehf
		switch -- $pr_ehf {
			0 {
				set finished 1
			}
			1 -
			2 -
			3 -
			4 {
				if {[string length $ehf(ofnam)] <= 0} {
					Inf "No output filename entered"
					continue
				}
				if {![ValidCDPRootname $ehf(ofnam)]} {
					continue
				}
				set outfnam [string tolower $ehf(ofnam)]
				append outfnam $evv(TEXT_EXT)
				if {[file exists $outfnam]} {
					Inf "File $outfnam already exists : please choose a different name"
					continue
				}
				if {$pr_ehf == 1} {
					set brkfnam [file rootname $outfnam]
					append brkfnam ".brk"
					if {[file exists $brkfnam]} {
						Inf "File $brkfnam already exists : please choose a different name"
						continue
					}
				}
				Block "EXTRACTING HARMONIC FIELD DATA"
				switch -- $pr_ehf {
					1 {
						set cmd [file join $evv(CDPROGRAM_DIR) specanal]
						lappend cmd specanal 7 $fnam $outfnam $ehf(chans) $ehf(overlap)
						set prg_dun 0
						set prg_abortd 0
						if [catch {open "|$cmd"} CDPidrun] {
							Inf "Failed to run pitch data extraction"
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
							Inf "Failed in extracting pitch data"
							catch {unset CDPidrun}
							UnBlock
							continue
						}
						catch {close $CDPidrun}
						if {![file exists $outfnam]} {
							Inf "No pitch data extracted"
							catch {unset CDPidrun}
							UnBlock
							continue
						}
						if {![catch {file rename $outfnam $brkfnam} zit]} {
							set outfnam $brkfnam
						}
						FileToWkspace $outfnam 0 0 0 0 1
						Inf "File $outfnam is on the workspace"
						UnBlock
						set ehf(continue) 0
						set finished 1
					}
					2 {
						if {([string length $ehf(pkcnt)] <= 0) || ![regexp {^[0-9]+$} $ehf(pkcnt)]  || ![IsNumeric $ehf(pkcnt)] || ($ehf(pkcnt) < 1) || ($ehf(pkcnt) > 64)} {
							Inf "Invalid peak count value (range 1 to 64)"
							UnBlock
							continue
						}
						if {!$ehf(midi) && $ehf(testfilt)} {
							if {([string length $ehf(Q)] <= 0) || ![regexp {^[0-9]+$} $ehf(Q)]  || ![IsNumeric $ehf(Q)] || ($ehf(Q) < 20) || ($ehf(Q) > 10000)} {
								Inf "Invalid test filter Q value (range 20 to 10000)"
								UnBlock
								continue
							}


							if {([string length $ehf(hcnt)] <= 0) || ![regexp {^[0-9]+$} $ehf(hcnt)]  || ![IsNumeric $ehf(hcnt)] || ($ehf(Q) < 1) || ($ehf(Q) > 200)} {
								Inf "Invalid test filter harmonics-count value (range 1 to 200 - may be modified once HF extracted)"
								UnBlock
								continue
							}
						}
						set cmd [file join $evv(CDPROGRAM_DIR) specanal]
						lappend cmd specanal 8 $fnam $outfnam $ehf(chans) $ehf(overlap) $ehf(pkcnt)
						if {$ehf(amp)} {
							lappend cmd "-a"
						}
						if {$ehf(harm)} {
							lappend cmd "-h"
						}
						if {$ehf(dechrom)} {
							lappend cmd "-c"
						}
						if {$ehf(transp) == 1} {
							lappend cmd -d
						} elseif {$ehf(transp) == 2} {
							lappend cmd -D
						}
						if {$ehf(midi)} {
							lappend cmd "-m"
							set msg2 "MIDI DATA"
						} else {
							set msg2 "VARIBANK FILTER DATA"
						}
						set prg_dun 0
						set prg_abortd 0
						wm title .blocker "CREATING $msg2"
						if [catch {open "|$cmd"} CDPidrun] {
							Inf "Failed to run creation of $msg2"
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
							Inf "Failed in creating $msg2"
							catch {unset CDPidrun}
							UnBlock
							continue
						}
						catch {close $CDPidrun}
						if {![file exists $outfnam]} {
							Inf "No $msg2 extracted"
							catch {unset CDPidrun}
							UnBlock
							continue
						}

						set savedata 1
						.ehf.0.ok  config -text "" -command {} -bd 0 -bg [option get . background {}]
						catch {unset ehf(maxmidi)}
						catch {unset ehf(maxhcnt)}
						if {$ehf(testfilt)} {

							;# TEST THE FILTER DATA

							wm title .blocker "TEST-FILTERING SRC WITH $ehf(ofnam)"
							set OK 1
							while {$OK} {
								set maxmidi [GetEhfMaxmidi $outfnam]
								if {$maxmidi <= 0} {
									set OK 0
									break
								}
								set ehf(maxmidi) $maxmidi
								set maxfrqinfile [MidiToHz $maxmidi]
								set srate $pa($ehf(fnam),$evv(SRATE))
								set maxfrq [expr $srate / 2.0]
								set maxhcnt [expr int(floor($maxfrq / $maxfrqinfile))]
								if {$maxhcnt > 200} {
									set maxhcnt 200
								}
								set ehf(maxhcnt) $maxhcnt
								if {$ehf(hcnt) > $maxhcnt} {
									Inf "Number of harmonics restricted to $maxhcnt by filter pitch-values"
									set ehf(hcnt) $maxhcnt
								}

								set cmd [file join $evv(CDPROGRAM_DIR) filter]
								lappend cmd varibank 2 $fnam $ehf(outsfnam) $outfnam $ehf(Q) 20 -t0 -h$ehf(hcnt) -r0 -d -n 
								
								set prg_dun 0
								set prg_abortd 0
								if [catch {open "|$cmd"} CDPidrun] {
									Inf "Failed to run filtering test"
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
									Inf "Filtering test failed"
									catch {unset CDPidrun}
									set OK 0
									break
								}
								catch {close $CDPidrun}
								if {![file exists $ehf(outsfnam)]} {
									Inf "No filter test output file created"
									catch {unset CDPidrun}
									set OK 0
									break
								}
								set ehf(continue) 0
								.ehf.0.ok1 config -state disabled
								.ehf.0.ok2 config -state disabled
								.ehf.0.ok3 config -state disabled
								.ehf.0.ok4 config -state disabled
								.ehf.0.ok       config -text "Play"      -command "TestPlayFilter 1" -bd 2
								.ehf.0.quitplay config -text "Quit Play" -command "TestPlayFilter 0" -bd 2
								set ehf(play) 1
								UnBlock
								set blockremoved 1
								Inf "Use play button to hear output (quit play once finished)"
								vwait ehf(play)
								.ehf.0.quitplay config -text "" -command {} -bd 0
								.ehf.0.ok config -text "" -command {} -bd 0 -bg [option get . background {}]
								.ehf.0.ok1 config -state normal
								.ehf.0.ok2 config -state normal
								.ehf.0.ok3 config -state normal
								.ehf.0.ok4 config -state normal
								set msg "Save filter data ??"
								set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
								if {$choice == "no"} {
									set savedata 0
								}
								set OK 1
								break
							}
						}
						set ehf(continue) 0
						set msg "Apply the extracted HF ??"
						set choice [tk_messageBox -type yesno -default no -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "yes"} {
							set ehf(continue) 1
						}
						if {![info exists blockremoved]} {
							UnBlock
						} else {
							unset blockremoved
						}
						if {$savedata} {
							FileToWkspace $outfnam 0 0 0 0 1
							if {$ehf(continue)} {
								lappend chlist $outfnam
							} else {
								Inf "File $outfnam is on the workspace"
							}
							set finished 1
						} else {
							if [catch {file delete $outfnam} zit] {
								Inf "Cannot remove unwanted file $outfnam"
							}
							.ehf.0.ok config -text "Run" -command "set pr_ehf 2" -bd 2 -bg $evv(EMPH)
						}
					}
					3 {
						if {([string length $ehf(tstep)] <= 0) || ![IsNumeric $ehf(tstep)] || ($ehf(tstep) < 5) || ($ehf(tstep) >= $ehf(maxtstep))} {
							Inf "Invalid timestep value (range 0 to < $ehf(maxtstep))"
							UnBlock
							continue
						}
						if {([string length $ehf(bot)] <= 0) || ![IsNumeric $ehf(bot)] || ![regexp {^[0-9]+$} $ehf(bot)]  || ($ehf(bot) < 0) || ($ehf(bot) > 127)} {
							Inf "Invalid minimum pitch (range 0 to 127)"
							UnBlock
							continue
						}
						if {([string length $ehf(top)] <= 0) || ![IsNumeric $ehf(top)] || ![regexp {^[0-9]+$} $ehf(top)]  || ($ehf(top) < 0) || ($ehf(top) > 127)} {
							Inf "Invalid maximum pitch (range 0 to 127)"
							UnBlock
							continue
						}
						if {$ehf(top) <= $ehf(bot)} {
							Inf "Minimum and maximum pitches are incompatible"
							UnBlock
							continue
						}
						if {([string length $ehf(gate)] <= 0) || ![IsNumeric $ehf(gate)] || ($ehf(gate) < 0) || ($ehf(gate) > 0.95)} {
							Inf "Invalid gate value (range 0 to 0.95)"
							UnBlock
							continue
						}
						set cmd [file join $evv(CDPROGRAM_DIR) specanal]
						lappend cmd specanal 9 $fnam $outfnam $ehf(chans) $ehf(overlap) $ehf(tstep)
						if {$ehf(bot) != 0} {
							lappend cmd -b$ehf(bot)
						}
						if {$ehf(top) != 127} {
							lappend cmd -t$ehf(top)
						}
						if {$ehf(gate) != 0} {
							lappend cmd -g$ehf(gate)
						}
						set prg_dun 0
						set prg_abortd 0
						if [catch {open "|$cmd"} CDPidrun] {
							Inf "Failed to run pitch tracking"
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
							Inf "Failed in pitch tracking"
							catch {unset CDPidrun}
							UnBlock
							continue
						}
						catch {close $CDPidrun}
						if {![file exists $outfnam]} {
							Inf "No pitch data extracted"
							catch {unset CDPidrun}
							UnBlock
							continue
						}
						FileToWkspace $outfnam 0 0 0 0 1
						Inf "File $outfnam is on the workspace"
						UnBlock
						set ehf(continue) 0
						set finished 1
					}
					4 {
						if {([string length $ehf(pkcnt)] <= 0) || ![regexp {^[0-9]+$} $ehf(pkcnt)]  || ![IsNumeric $ehf(pkcnt)] || ($ehf(pkcnt) < 1) || ($ehf(pkcnt) > 64)} {
							Inf "Invalid peak count value (range 1 to 64)"
							UnBlock
							continue
						}
						if {([string length $ehf(tstep)] <= 0) || ![IsNumeric $ehf(tstep)] || ($ehf(tstep) < 5) || ($ehf(tstep) >= $ehf(maxtstep))} {
							Inf "Invalid timestep value (range 0 to < $ehf(maxtstep))"
							UnBlock
							continue
						}
						if {([string length $ehf(bot)] <= 0) || ![IsNumeric $ehf(bot)] || ![regexp {^[0-9]+$} $ehf(bot)]  || ($ehf(bot) < 0) || ($ehf(bot) > 127)} {
							Inf "Invalid minimum pitch (range 0 to 127)"
							UnBlock
							continue
						}
						if {([string length $ehf(top)] <= 0) || ![IsNumeric $ehf(top)] || ![regexp {^[0-9]+$} $ehf(top)]  || ($ehf(top) < 0) || ($ehf(top) > 127)} {
							Inf "Invalid maximum pitch (range 0 to 127)"
							UnBlock
							continue
						}
						if {$ehf(top) <= $ehf(bot)} {
							Inf "Minimum and maximum pitches are incompatible"
							UnBlock
							continue
						}
						if {([string length $ehf(gate)] <= 0) || ![IsNumeric $ehf(gate)] || ($ehf(gate) < 0) || ($ehf(gate) > 0.95)} {
							Inf "Invalid gate value (range 0 to 0.95)"
							UnBlock
							continue
						}
						set cmd [file join $evv(CDPROGRAM_DIR) specanal]
						lappend cmd specanal 10 $fnam $outfnam $ehf(chans) $ehf(overlap) $ehf(pkcnt) $ehf(tstep)
						if {$ehf(bot) != 0} {
							lappend cmd -b$ehf(bot)
						}
						if {$ehf(top) != 127} {
							lappend cmd -t$ehf(top)
						}
						if {$ehf(gate) != 0} {
							lappend cmd -g$ehf(gate)
						}
						if {$ehf(transp) == 1} {
							lappend cmd -d
						} elseif {$ehf(transp) == 2} {
							lappend cmd -D
						}
						set prg_dun 0
						set prg_abortd 0
						if [catch {open "|$cmd"} CDPidrun] {
							Inf "Failed to run harmonic field tracking"
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
							Inf "Failed in tracking harmonic field"
							catch {unset CDPidrun}
							UnBlock
							continue
						}
						catch {close $CDPidrun}
						if {![file exists $outfnam]} {
							Inf "No harmonic field data extracted"
							catch {unset CDPidrun}
							UnBlock
							continue
						}
						if {[FileToWkspace $outfnam 0 0 0 0 1] > 0} {
							Inf "File $outfnam is on the workspace"
						}
						UnBlock
						set ehf(continue) 0
						set finished 1
					}
				}
			}
		}
	}
	if {$ismonofied} {
		DeleteAllTemporaryFiles
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $ehf(continue)
}

proc SwitchEhfState {} {
	global ehf pr_ehf
	switch -- $ehf(ex) {
		1 { ;# view energy profile
			if {!$ehf(flagsave)} {
 				set ehf(ampbak) $ehf(amp)
				set ehf(harmbak) $ehf(harm)
				set ehf(dechrombak) $ehf(dechrom)
				set ehf(midibak) $ehf(midi)
				set ehf(testfiltbak) $ehf(testfilt)
				set ehf(flagsave) 1
			}
			if {!$ehf(transpsave)} {
				set ehf(transpbak) $ehf(transp)
				set ehf(transpsave) 1
			}
			if {[string length $ehf(pkcnt)] > 0} { 
				set ehf(pkcntbak) $ehf(pkcnt)
			}
			set ehf(pkcnt) ""
			set ehf(amp) 0
			set ehf(harm) 0
			set ehf(dechrom) 0
			set ehf(midi) 0
			set ehf(testfilt) 0
			set ehf(transp) -1
			set ehf(dechrom) 0
			.ehf.0.ok config -command "set pr_ehf $ehf(ex)"
			.ehf.3.ll config -text ""
			.ehf.3.b config -text "" -bd 0 -command {}
			.ehf.3.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.ehf.3t.ll config -text ""
			.ehf.3t.b config -text "" -bd 0 -command {}
			.ehf.3t.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.ehf.4.ch config -text "" -state disabled
			.ehf.5.ch config -text "" -state disabled
			.ehf.5a.ch config -text "" -state disabled
			.ehf.6.ch0 config -text ""
			.ehf.6.ch1 config -text "" -state disabled
			.ehf.6.ch2 config -text "" -state disabled
			EhfQH 0
			.ehf.6a.ch1 config -text "" -state disabled
			.ehf.6a.ch2 config -text "" -state disabled
			.ehf.6a.ch3 config -text "" -state disabled
			if {[string length $ehf(tstep)] != 0} {
				set ehf(tstepbak) $ehf(tstep)
			}
			if {[string length $ehf(bot)] != 0} {
				set ehf(botbak)   $ehf(bot)
			}
			if {[string length $ehf(top)] != 0} {
				set ehf(topbak)   $ehf(top)
			}
			if {[string length $ehf(gate)] != 0} {
				set ehf(gatebak)  $ehf(gate)
			}
			set ehf(tstep) ""
			set ehf(bot) ""
			set ehf(top) ""
			set ehf(gate) ""
			.ehf.3a.ll config -text ""
			.ehf.3a.b config -text "" -bd 0 -command {}
			.ehf.3a.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.ehf.3b.ll config -text ""
			.ehf.3b.b config -text "" -bd 0 -command {}
			.ehf.3b.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.ehf.3c.ll config -text ""
			.ehf.3c.b config -text "" -bd 0 -command {}
			.ehf.3c.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			set ehf(ofnam) $ehf(ifnam)
		}
		2 {	;#	average HF
			.ehf.0.ok config -command "set pr_ehf $ehf(ex)"
			.ehf.3.ll config -text "Peakcnt : Number of peaks to keep (Range 1 to 64)"
			.ehf.3.b config -text "Default" -bd 2 -command "set ehf(pkcnt) 6"
			.ehf.3.e config -bd 2 -state normal -textvariable ehf(pkcnt)
			.ehf.3t.ll config -text ""
			.ehf.3t.b config -text "" -bd 0 -command {}
			.ehf.3t.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.ehf.4.ch config -text "Equalise amplitudes, in filter, of selected pitches"    -state normal
			.ehf.5.ch config -text "Eliminate pitches which are harmonics of lower pitches" -state normal
			.ehf.5a.ch config -text "Eliminate pitches at semitone interval to another" -state normal
			.ehf.6.ch0 config -text "Output"
			.ehf.6.ch1 config -text "MIDI list" -state normal
			.ehf.6.ch2 config -text "Varibank datafile" -state normal
			.ehf.6a.ch1 config -text "No Transposing" -state normal
			.ehf.6a.ch2 config -text "Filter Down 8va" -state normal
			.ehf.6a.ch3 config -text "Down TWO 8vas" -state normal
			if {[string length $ehf(tstep)] != 0} {
				set ehf(tstepbak) $ehf(tstep)
			}
			if {[string length $ehf(bot)] != 0} {
				set ehf(botbak)   $ehf(bot)
			}
			if {[string length $ehf(top)] != 0} {
				set ehf(topbak)   $ehf(top)
			}
			if {[string length $ehf(gate)] != 0} {
				set ehf(gatebak)  $ehf(gate)
			}
			set ehf(tstep) ""
			set ehf(bot) ""
			set ehf(top) ""
			set ehf(gate) ""
			.ehf.3a.ll config -text ""
			.ehf.3a.b config -text "" -bd 0 -command {}
			.ehf.3a.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.ehf.3b.ll config -text ""
			.ehf.3b.b config -text "" -bd 0 -command {}
			.ehf.3b.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.ehf.3c.ll config -text ""
			.ehf.3c.b config -text "" -bd 0 -command {}
			.ehf.3c.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			if {[info exists ehf(pkcntbak)]} {
				set ehf(pkcnt) $ehf(pkcntbak)
			}
			if {[info exists ehf(ampbak)]} {
				set ehf(amp) $ehf(ampbak)
			}
			if {[info exists ehf(harmbak)]} {
				set ehf(harm) $ehf(harmbak)
			}
			if {[info exists ehf(dechrombak)]} {
				set ehf(dechrom) $ehf(dechrombak)
			}
			if {[info exists ehf(midibak)]} {
				set ehf(midi) $ehf(midibak)
			}
			if {[info exists ehf(transpbak)]} {
				set ehf(transp) $ehf(transpbak)
			}
			if {[info exists ehf(testfiltbak)]} {
				set ehf(testfilt) $ehf(testfiltbak)
			} else {
				set ehf(testfilt) 0
			}
			EhfQH 1
			EhfDoTest $ehf(testfilt)
			set ehf(transpsave) 0
			set ehf(flagsave) 0
			set ehf(ofnam) $ehf(ifnam)
			append ehf(ofnam) "_hf"
		} 
		3 {	;#	track pitch
			.ehf.0.ok config -command "set pr_ehf $ehf(ex)"
			.ehf.3.ll config -text ""
			.ehf.3.b config -text "" -bd 0 -command {}
			.ehf.3.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			if {[string length $ehf(pkcnt)] != 0} {
				set ehf(pkcntbak) $ehf(pkcnt)
			}
			set ehf(pkcnt) ""
			.ehf.3t.ll config -text "Timestep : (mS) Range 5 to < $ehf(maxtstep)"
			.ehf.3t.b config -text "Default" -bd 2 -command "set ehf(tstep) 100"
			.ehf.3t.e config -bd 2 -state normal -textvariable ehf(tstep)
			if {!$ehf(flagsave)} {
 				set ehf(ampbak) $ehf(amp)
				set ehf(harmbak) $ehf(harm)
				set ehf(dechrombak) $ehf(dechrom)
				set ehf(midibak) $ehf(midi)
				set ehf(testfiltbak) $ehf(testfilt)
				set ehf(flagsave) 1
			}
			if {!$ehf(transpsave)} {
				set ehf(transpbak) $ehf(transp)
				set ehf(transpsave) 1
			}
			set ehf(amp) 0
			set ehf(harm) 0
			set ehf(dechrom) 0
			set ehf(midi) 0
			set ehf(transp) -1
			.ehf.4.ch config -text "" -state disabled
			.ehf.5.ch config -text "" -state disabled
			.ehf.5a.ch config -text "" -state disabled
			.ehf.6.ch0 config -text ""
			.ehf.6.ch1 config -text "" -state disabled
			.ehf.6.ch2 config -text "" -state disabled
			EhfQH 0
			.ehf.6a.ch1 config -text "" -state disabled
			.ehf.6a.ch2 config -text "" -state disabled
			.ehf.6a.ch3 config -text "" -state disabled

			.ehf.3a.ll config -text "Min pitch : (MIDI : Range 0-127)"
			.ehf.3a.b config -text "Default" -command "set ehf(bot) 0" -bd 2
			.ehf.3a.e config -bd 2 -state normal
			.ehf.3b.ll config -text "Max pitch : (MIDI : Range 0-127)"
			.ehf.3b.b config -text "Default" -command "set ehf(top) 127" -bd 2
			.ehf.3b.e config -bd 2 -state normal
			.ehf.3c.ll config -text "Gate : Fraction of maxpeak-level below which signal ignored (Range 0 - 0.95)"
			.ehf.3c.b config -text "Default" -command "set ehf(gate) 0.1" -bd 2
			.ehf.3c.e config -bd 2 -state normal
			set ehf(tstep) $ehf(tstepbak)
			set ehf(bot)   $ehf(botbak)
			set ehf(top)   $ehf(topbak)
			set ehf(gate)  $ehf(gatebak)
			set ehf(ofnam) $ehf(ifnam)
			append ehf(ofnam) "_vp"
		} 
		4 {	;#	track HF
			.ehf.0.ok config -command "set pr_ehf $ehf(ex)"
			.ehf.3.ll config -text "Peakcnt : Number of peaks to keep (Range 1 to 64)"
			.ehf.3.b config -text "Default" -bd 2 -command "set ehf(pkcnt) 6"
			.ehf.3.e config -bd 2 -state normal -textvariable ehf(pkcnt)
			.ehf.3t.ll config -text "Timestep : (mS) Range 5 to < $ehf(maxtstep)"
			.ehf.3t.b config -text "Default" -bd 2 -command "set ehf(tstep) 100"
			.ehf.3t.e config -bd 2 -state normal -textvariable ehf(tstep)
			if {!$ehf(flagsave)} {
 				set ehf(ampbak) $ehf(amp)
				set ehf(harmbak) $ehf(harm)
				set ehf(dechrombak) $ehf(dechrom)
				set ehf(midibak) $ehf(midi)
				set ehf(testfiltbak) $ehf(testfilt)
				set ehf(flagsave) 1
			}
			set ehf(amp) 0
			set ehf(harm) 0
			set ehf(dechrom) 0
			set ehf(midi) 0
			.ehf.4.ch config -text "" -state disabled
			.ehf.5.ch config -text "" -state disabled
			.ehf.5a.ch config -text "" -state disabled
			.ehf.6.ch0 config -text ""
			.ehf.6.ch1 config -text "" -state disabled
			.ehf.6.ch2 config -text "" -state disabled
			EhfQH 0
			.ehf.6a.ch1 config -text "No Transposing" -state normal
			.ehf.6a.ch2 config -text "Filter Down 8va" -state normal
			.ehf.6a.ch3 config -text "Down TWO 8vas" -state normal

			.ehf.3a.ll config -text "Min pitch : (MIDI : Range 0-127)"
			.ehf.3a.b config -text "Default" -command "set ehf(bot) 0" -bd 2
			.ehf.3a.e config -bd 2 -state normal
			.ehf.3b.ll config -text "Max pitch : (MIDI : Range 0-127)"
			.ehf.3b.b config -text "Default" -command "set ehf(top) 127" -bd 2
			.ehf.3b.e config -bd 2 -state normal
			.ehf.3c.ll config -text "Gate : Fraction of maxpeak-level below which signal ignored (Range 0 - 0.95)"
			.ehf.3c.b config -text "Default" -command "set ehf(gate) 0.1" -bd 2
			.ehf.3c.e config -bd 2 -state normal
			set ehf(pkcnt)  $ehf(pkcntbak)
			set ehf(tstep)  $ehf(tstepbak)
			set ehf(bot)    $ehf(botbak)
			set ehf(top)    $ehf(topbak)
			set ehf(gate)   $ehf(gatebak)
			if {[info exists ehf(transpbak)]} {			
				set ehf(transp) $ehf(transpbak)
			}
			set ehf(transpsave) 0
			set ehf(ofnam) $ehf(ifnam)
			append ehf(ofnam) "_vhf"
		}
	}
}

proc IncrEhfOverlap {down} {
	global ehf
	if {$down} {
		if {$ehf(overlap) > 1} {
			incr ehf(overlap) -1
		}
	} else {
		if {$ehf(overlap) < 4} {
			incr ehf(overlap)
		}
	}
}

proc IncrEhfChans {down} {
	global ehf
	if {$down} {
		if {$ehf(chans) > 256} {
			set ehf(chans) [expr $ehf(chans)/2]
		}
	} else {
		if {$ehf(chans) < 4096} {
			set ehf(chans) [expr $ehf(chans) * 2]
		}
	}
}

proc ExtractHFHelp {extra} {
	set msg "Extract/apply average or time-varying harmonic field (HF).\n"
	append msg "\n"
	if {$extra == 1} {
		append msg "NB ~~The parameters on display will change as you select one of the options in the top line~~\n"
		append msg "\n"
	}
	if {$extra != 2} {
		append msg "~~ VIEW ENERGY PROFILE or EXTRACT AVERAGE HF ~~\n"
		append msg "\n"
		append msg "Both processes add up the spectral energy in each semitone interval, OVER THE ENTIRE SOUND.\n"
		append msg "then plot a normalised graph of this energy.\n"
		append msg "\n"
		append msg "(1)  VIEW ENERGY PROFILE\n"
		append msg "\n"
		append msg "The output is a plot of energy against pitch. This can be displayed as a brkpnt file plot.\n"
		append msg "Here you can see the peaks in the data.\n"
		append msg "You can then assess a good \"peakcnt\" value for \"Extract Average HF\" (see below)\n"
		append msg "\n"
		append msg "(2)  EXTRACT AVERAGE HF\n"
		append msg "\n"
		append msg "Selects the N most prominent peaks from the energy profile. These can be ...\n"
		append msg "\n"
		append msg "(1)  output as a list of MIDI values OR\n"
		append msg "(2)  used to define the pitches in a varibank filter file.\n"
		append msg "\n"
		append msg "On building the varibank filter you can ...\n"
		append msg "\n"
		append msg "(1)  Eliminate (or not) peaks which are at harmonics of lower frequencies.\n"
		append msg "(2)  Eliminate (or not) peaks which are a semitone distant from other peaks.\n"
		append msg "(3)  Transpose the entire output down 1 or 2 octaves.\n"
		append msg "(4)  Standardise the amplitude of all peaks, OR Retain the relative amplitude of the peaks\n"
		append msg "      as found in the extracted data.\n"
	}
	if {$extra == 1} {
		append msg "(5)  Filter the source with the filter-data file generated, and listen to the result:\n"
		append msg "            (select \"Test Listen\" : you can then enter values for \"Q\" & \"No of harmonics\").\n"
	}
	if {$extra != 2} {
		append msg "\n"
		append msg "(3)  TRACK PITCH THROUGH TIME\n"
		append msg "\n"
		append msg "This process tracks the semitone-interval with the maximum energy AS IT CHANGES OVER TIME.\n"
		append msg "The output is a varibank filter focused on the time-changing peak pitch.\n"
		append msg "(The extracted pitches are NOT necessarily the fundamentals in the source sound).\n"
		append msg "\n"
		append msg "(4)  TRACK HF THROUGH TIME\n"
		append msg "\n"
		append msg "This process tracks the N semitone-interval with the maximum energies AS THEY CHANGE OVER TIME.\n"
		append msg "The output is a varibank filter focused on the time-changing HF.\n"
		append msg "\n"
		append msg "This process automatically eliminates ....\n"
		append msg "\n"
		append msg "(1)  peaks which are the 1st,2nd or 3rd harmonic of lower peaks.\n"
		append msg "(2)  peaks which are out of pitch range.\n"
		append msg "\n"
		append msg "You can also opt to transpose every filter pitch-value down by 1 or 2 octaves.\n"
		append msg "\n"
	}
	if {($extra == 0) || ($extra == 2)} {
		append msg "\n"
		append msg "~~ APPLY THE AVERAGE HF ~~\n"
		append msg "\n"
		append msg "After Using the \"Extract Average HF\" option in the \"Extract Pitch/HF\" window\n"
		append msg "use the extracted HF to filter the source sound\n"
		append msg "(you will need BOTH the source sound and the filter-datafile as inputs).\n"
		append msg "\n"
		append msg "TWO PROCESSES ARE AVAILABLE\n"
		append msg "\n"
		append msg "(1)  DISSOLVE source in HF, by crossfading to filtered versions with increasing Q values.\n"
		append msg "\n"
		append msg "(2)  Source EMERGES from HF, by crossfading from filtered versions with decreasing Q values.\n"
		append msg "\n"
	}
	Inf $msg
}

proc TestPlayFilter {on} {
	global ehf
	if {$on} {
		if {[file exists $ehf(outsfnam)]} {
			PlaySndfile $ehf(outsfnam) 0
			return
		}
		Inf "No output test file to play"
	}
	set ehf(play) 0
}

proc EhfQH {varibank} {
	global ehf
	switch -- $varibank {
		0 {	;#	MIDI list output only
			set ehf(testfiltbak) $ehf(testfilt)
			set ehf(testfilt) 0
			.ehf.6.ch3 config -text "" -state disabled
			EhfDoTest 0
		}
		1 {
			.ehf.6.ch3 config -text "Test Listen" -state normal
			if {[info exists ehf(testfiltbak)]} {
				set ehf(testfilt) $ehf(testfiltbak)
			} else {
				set ehf(testfilt) 0
			}
			EhfDoTest $ehf(testfilt)
		}
	}
}

proc EhfDoTest {do} {
	global ehf
	if {$do} {
		.ehf.6.ch4 config -text "Filter Q "
		.ehf.6.ch5 config -bd 2 -state normal
		.ehf.6.ch6 config -text "No of harmonics "
		.ehf.6.ch7 config -bd 2 -state normal
		if {[info exists ehf(Qbak)]} {
			set ehf(Q) $ehf(Qbak)
		} else {
			set ehf(Q) $ehf(Qdflt)
		}
		if {[info exists ehf(hcntbak)]} {
			set ehf(hcnt) $ehf(hcntbak)
		} else {
			set ehf(hcnt) $ehf(hcntdflt)
		}
	} else {
		if {[string length $ehf(Q)] > 0} {
			set ehf(Qbak) $ehf(Q)
		}
		if {[string length $ehf(hcnt)] > 0} {
			set ehf(hcntbak) $ehf(hcnt)
		}
		set ehf(Q) ""
		set ehf(hcnt) ""
		.ehf.6.ch4 config -text ""
		.ehf.6.ch5 config -bd 0 -state disabled -disabledbackground [option get . background {}]
		.ehf.6.ch6 config -text ""
		.ehf.6.ch7 config -bd 0 -state disabled -disabledbackground [option get . background {}]
	}
}

proc EhfDoTestA {} {
	global ehf
	if {$ehf(testfilt)} {
		EhfDoTest 1
	} else {
		EhfDoTest 0
	}
}

proc ApplyHF {fromextract} {
	global chlist wl evv pa pr_ahf ahf ehf set prg_dun prg_abortd CDPidrun wstk

	if {[info exists chlist] && ([llength $chlist] == 2)} {
		set ahf(fnamsrc) [lindex $chlist 0]
		set fnamflt [lindex $chlist 1]
	} else {
		set ilist [$wl curselection]
		if {![info exists ilist] || ([llength $ilist] != 2)} {
			Inf "Select a soundfile and filter varibank file (MIDI type) file of its extracted HF"
			return
		}
		set ahf(fnamsrc) [lindex $ilist 0]
		set fnamflt [lindex $ilist 1]
	}
	if {$pa($ahf(fnamsrc),$evv(FTYP)) != $evv(SNDFILE)} {
		if {$pa($fnamflt,$evv(FTYP)) != $evv(SNDFILE)} {
			Inf "Select a soundfile to filter with the HF data"
			return
		} else {
			set temp $ahf(fnamsrc)
			set ahf(fnamsrc) $fnamflt
			set fnamflt $temp
		}
	}
	if {![IsAMidiVaribankFile $fnamflt]} {
		Inf "File [file tail $fnamflt] is not a filter varibank file (MIDI type) file"
		return
	}
	set ahf(srate) $pa($ahf(fnamsrc),$evv(SRATE))
	set ahf(chans) $pa($ahf(fnamsrc),$evv(CHANS))
	set gotmaxhcnt 0
	set gotmaxmidi 0
	if {[info exists ahf(hcnt)] && ([string length $ahf(hcnt)] > 0) && [IsNumeric $ahf(hcnt)] && [regexp {^[0-9]+$} $ahf(hcnt)] && ($ahf(hcnt) >= 1) && ($ahf(hcnt) <= 200)} {
		set gothcnt 1
	} else {
		set ahf(hcnt) ""
		set gothcnt 0
	}

	;#	SET UP INTERNAL PARAMS, EITHER FROM EXTRACT PROCESS, OR DIRECTLY

	if {$fromextract} {
		if {[info exists ehf(maxhcnt)]} {
			set ahf(maxhcnt) $ehf(maxhcnt)
			set gotmaxhcnt 1
		}
		if {[info exists ehf(maxmidi)]} {
			set ahf(maxmidi) $ehf(maxmidi)
			set gotmaxmidi 1
		}
		if {[info exists ehf(hcnt)] && ([string length $ehf(hcnt)] > 0) && [regexp {^[0-9]+$} $ehf(hcnt)]  && [IsNumeric $ehf(hcnt)] && ($ehf(Q) >= 1) || ($ehf(Q) <=200)} {
			set ahf(hcnt) $ehf(hcnt)
			set gothcnt 1
		}
	} 
	if {!$gotmaxhcnt} {
		if {!$gotmaxmidi} {
			set ahf(maxmidi) [GetEhfMaxmidi $fnamflt]
			if {$ahf(maxmidi) <= 0} {
				return
			}
		}
		set maxfrqinfile [MidiToHz $ahf(maxmidi)]
		set maxfrq [expr $ahf(srate) / 2.0]
		set ahf(maxhcnt) [expr int(floor($maxfrq / $maxfrqinfile))]
		if {$ahf(maxhcnt) > 200} {
			set ahf(maxhcnt) 200
		}
	}
	if {$gothcnt} {
		if {$ahf(hcnt) > $ahf(maxhcnt)} {
			set ahf(hcnt) $ahf(maxhcnt)
		}
	} else {
		set ahf(hcnt) $ahf(maxhcnt)
	}
	set ahf(dur) $pa($ahf(fnamsrc),$evv(DUR))

	;#	SET UP TEMPORARY-FILE NAMES

	set ahf(reverse) $evv(DFLT_OUTNAME) 
	append ahf(reverse) $evv(SNDFILE_EXT)

	set ahf(reverseoutput) $evv(DFLT_OUTNAME) 
	append ahf(reverseoutput) 0 $evv(SNDFILE_EXT)

	set ahf(preoutput) $evv(DFLT_OUTNAME) 
	append ahf(preoutput) 00 $evv(SNDFILE_EXT)

	set ahf(silence) $evv(DFLT_OUTNAME) 
	append ahf(silence) 000 $evv(SNDFILE_EXT)

	set n 1
	while {$n <= 48} {								;#	16 possible Q values to filter at
		set ahf(ffnam,$n) $evv(DFLT_OUTNAME)		;#	If Emerge then dissolve, 16 possible filters of src + 16 of reversed src
		append ahf(ffnam,$n) $n $evv(SNDFILE_EXT)	;#	The dissolve filter files then have to be offset from 0, so +16 further files!!
		incr n
	}
	set ahf(balancefile) $evv(DFLT_OUTNAME)
	append ahf(balancefile) $evv(TEXT_EXT)

	set ahf(balancefile2) $evv(DFLT_OUTNAME)
	append ahf(balancefile2) 0 $evv(TEXT_EXT)

	set ahf(balancesrcs) $evv(DFLT_OUTNAME)
	append ahf(balancesrcs) 00 $evv(TEXT_EXT)

	set ahf(balancesrcs2) $evv(DFLT_OUTNAME)
	append ahf(balancesrcs2) 000 $evv(TEXT_EXT)

	set f .ahf
	if [Dlg_Create $f "APPLY EXTRACTED HARMONIC FIELD TO SOUND" "set pr_ahf 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.run -text "Run"  -command "set pr_ahf 1" -width 8 -bg $evv(EMPH) -highlightbackground [option get . background {}]
		radiobutton $f.0.dslv -text "Disolv" -variable ahf(emerge) -value 0 -width 8 -command "AhfEmergeTypeSet 0"
		radiobutton $f.0.emrg -text "Emerge" -variable ahf(emerge) -value 1 -width 8 -command "AhfEmergeTypeSet 1"
		radiobutton $f.0.emdv -text "Em+Dis" -variable ahf(emerge) -value 2 -width 8 -command "AhfEmergeTypeSet 2"
		set ahf(emerge) 0
		label $f.0.name -text "" -width 32 -anchor e
		button $f.0.play -text "Play"  -command "AhfPlay" -width 8 -highlightbackground [option get . background {}]
		radiobutton $f.0.keep -text "Keep"    -variable ahf(keep) -value 1 -command "AhfKeep 1" -width 8
		radiobutton $f.0.rjct -text "Delete"  -variable ahf(keep) -value 0 -command "AhfKeep 0" -width 8
		button $f.0.help -text "Help" -command "ExtractHFHelp 2" -width 4 -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.0.quit -text "Quit" -command "set pr_ahf 0" -highlightbackground [option get . background {}]
		pack $f.0.run $f.0.dslv $f.0.emrg $f.0.emdv $f.0.name $f.0.play $f.0.keep $f.0.rjct $f.0.help -side left -padx 2
		pack $f.0.quit -side right
		pack $f.0 -side top -fill x -expand true
		label $f.1 -text "Increasing Q values for HF filters" -fg $evv(SPECIAL)
		label $f.1a -text "(Up/Down arrows increase/decrease 1st Q value)" -fg $evv(SPECIAL)
		pack $f.1 $f.1a -side top -pady 2
		frame $f.a
		frame $f.a.a
			frame $f.a.a.2
			set n 1
			while {$n <= 8} {
				label $f.a.a.2.ll$n -text $n -width 2
				entry $f.a.a.2.$n -textvariable ahf(q$n) -width 5
				pack $f.a.a.2.ll$n $f.a.a.2.$n -side left
				incr n
			}
			pack $f.a.a.2 -side top -pady 2
			frame $f.a.a.3
			while {$n <= 16} {
				label $f.a.a.3.ll$n -text $n -width 2
				entry $f.a.a.3.$n -textvariable ahf(q$n) -width 5
				pack $f.a.a.3.ll$n $f.a.a.3.$n -side left
				incr n
			}
			pack $f.a.a.3 -side top -pady 2

			frame $f.a.a.4
			label $f.a.a.4.ll -text "Step between Q vals"
			radiobutton $f.a.a.4.add  -text "Additive"   -variable ahf(steptyp) -value 1 -command "AhfMultiply 1" -width 12
			radiobutton $f.a.a.4.prod -text "Multiplier" -variable ahf(steptyp) -value 2 -command "AhfMultiply 2" -width 12
			radiobutton $f.a.a.4.none -text "None"   -variable ahf(steptyp) -value 0 -command "AhfMultiply 0" -width 12
			entry $f.a.a.4.e -textvariable ahf(step) -width 6
			pack $f.a.a.4.ll $f.a.a.4.e $f.a.a.4.add $f.a.a.4.prod $f.a.a.4.none -side left -padx 2
			pack $f.a.a.4 -side top -pady 2

			radiobutton $f.a.a.5 -text "Remove Last Q value" -variable ahf(remove) -value 1 -command "AhfRemoveLastQval"
			pack $f.a.a.5 -side top -pady 2

		frame $f.a.b
		label $f.a.b.1 -text "Q Sets" -fg $evv(SPECIAL)
		pack $f.a.b.1 -side top -pady 4
		button $f.a.b.save -text "Save Qset" -command AhfSaveQset -width 10  -highlightbackground [option get . background {}]
		label $f.a.b.ll -text "Qset Name"
		entry $f.a.b.e -textvariable ahf(qsetname) -width 24
		pack $f.a.b.ll $f.a.b.e -side top -pady 2  
		button $f.a.b.load -text "Load Qset" -command AhfLoadQset -width 10  -highlightbackground [option get . background {}]
		pack $f.a.b.save $f.a.b.load -side top -pady 4
		pack $f.a.a $f.a.b -side left -padx 2
		pack $f.a -side top -pady 2

		set ahf(q1) 20

		label $f.6 -text "(Right/Left arrows increase/decrease harmonics cnt)" -fg $evv(SPECIAL)
		label $f.6a -text "(Click on \"Max\" box to set Value to max)" -fg $evv(SPECIAL)
		pack $f.6 $f.6a -side top -pady 2
		
		frame $f.7
		label $f.7.ll -text "Number of harmonics"
		entry $f.7.e -textvariable ahf(hcnt) -width 10
		pack $f.7.e $f.7.ll -side left -padx 2
		label $f.7.ll2 -text "Max"
		entry $f.7.e2 -textvariable ahf(maxhcnt) -width 10 -state readonly
		pack $f.7.e2 $f.7.ll2 -side right -padx 2
		pack $f.7 -side top -pady 2 -fill x -expand true

		frame $f.8
		label $f.8.ll -text "Timestep between maximi of successive files in crossfade-mix"
		entry $f.8.e -textvariable ahf(tstep) -width 10
		pack $f.8.e $f.8.ll -side left -padx 2
		label $f.8.ll2 -text "Max"
		entry $f.8.e2 -textvariable ahf(maxtstep) -width 10 -state readonly
		pack $f.8.e2 $f.8.ll2 -side right -padx 2
		pack $f.8 -side top -pady 2 -fill x -expand true

		checkbutton $f.9 -text "Omit source from mix" -variable ahf(nosrc)
		pack $f.9 -side top -pady 2 -anchor w
		set ahf(nosrc) 0

		frame $f.10
		label $f.10.ll -text "Next Outfile Name"
		entry $f.10.e -textvariable ahf(ofnam) -width 24 -state readonly
		pack $f.10.e $f.10.ll -side right -padx 2
		pack $f.10 -side top -pady 2

		wm resizable $f 0 0
		bind $f <Escape> {AhfEscapeBind}
		bind $f <Up>    {IncrAhfQ1 0}
		bind $f <Down>  {IncrAhfQ1 1}
		bind $f <Right> {IncrAhfHcnt 0}
		bind $f <Left>  {IncrAhfHcnt 1}
		bind $f.7.e2 <ButtonRelease> {DoAhfHcntBind}
		bind $f.8.e2 <ButtonRelease> {DoAhfTstepBind}
	}
	.ahf.0.run  config -text "Run" -command "set pr_ahf 1" -bd 2 -bg $evv(EMPH)
	.ahf.0.quit config -text "Quit" -command "set pr_ahf 0" -bd 2
	.ahf.0.dslv config -text "Disolv" -command "AhfEmergeTypeSet 0" -state normal
	.ahf.0.emrg config -text "Emerge" -command "AhfEmergeTypeSet 1" -state normal
	.ahf.0.emdv config -text "EmgDsv" -command "AhfEmergeTypeSet 2" -state normal
	.ahf.0.play config -text "" -command {} -bd 0 -bg [option get . background {}]
	.ahf.0.keep config -text "" -command {} -state disabled
	.ahf.0.rjct config -text "" -command {} -state disabled
	.ahf.0.name config -text ""
	set ahf(keep) -1

	;#	GET UNIQUE NAMES FOR OUTFILES

	set ahf(dofnambas) [file rootname [file tail $ahf(fnamsrc)]]
	append ahf(dofnambas) "_dissolve"
	set ahf(eofnambas) [file rootname [file tail $ahf(fnamsrc)]]
	append ahf(eofnambas) "_emerge"
	set ahf(edofnambas) [file rootname [file tail $ahf(fnamsrc)]]
	append ahf(edofnambas) "_emgdsv"

	set n 0
	set gotname 0
	while {!$gotname} {
		set thisfnam $ahf(dofnambas)
		append thisfnam $n $evv(SNDFILE_EXT)
		set gotit 0
		foreach fnam [$wl get 0 end] {
			if {[string first $thisfnam $fnam] == 0} {
				set gotit 1
				break
			}
		}
		if {!$gotit} {
			if {![file exists $thisfnam]} {
				set ahf(dofnam) [file rootname $thisfnam]
				set ahf(doutcnt) $n
				set gotname 1
			}
		}
		incr n
	}
	set n 0
	set gotname 0
	while {!$gotname} {
		set thisfnam $ahf(eofnambas)
		append thisfnam $n $evv(SNDFILE_EXT)
		set gotit 0
		foreach fnam [$wl get 0 end] {
			if {[string first $thisfnam $fnam] == 0} {
				set gotit 1
				break
			}
		}
		if {!$gotit} {
			if {![file exists $thisfnam]} {
				set ahf(eofnam) [file rootname $thisfnam]
				set ahf(eoutcnt) $n
				set gotname 1
			}
		}
		incr n
	}
	set n 0
	set gotname 0
	while {!$gotname} {
		set thisfnam $ahf(edofnambas)
		append thisfnam $n $evv(SNDFILE_EXT)
		set gotit 0
		foreach fnam [$wl get 0 end] {
			if {[string first $thisfnam $fnam] == 0} {
				set gotit 1
				break
			}
		}
		if {!$gotit} {
			if {![file exists $thisfnam]} {
				set ahf(edofnam) [file rootname $thisfnam]
				set ahf(edoutcnt) $n
				set gotname 1
			}
		}
		incr n
	}

	;#	ASSIGN OUTFILE NAME DEPENDING ON WHETHER "DISSOLVE" OR "EMERGE" IS SELECTED

	AhfEmergeTypeSet $ahf(emerge)

	;#	SET UP INITIAL PARAMS FOR q maxtstep AND qcnt FROM SCRATCH, OR FROM PREVIOUS RUN 

	set n 16
	while {$n > 0} {
		if {[string length $ahf(q$n)] > 0} {
			if {![IsNumeric $ahf(q$n)] || ($ahf(q$n) < 20) || ($ahf(q$n) > 10000)} {
				set k $n
				while {$k <= 16} {					;#	If this value invalid, delete all higher Q-values
					set ahf(q$k) ""
					incr k
				}
			} 
			if {![info exists ahf(qcnt)]} {			;#	If this is last valid Q-value, Note total number of Q values used
				set ahf(qcnt) $n
			}
		} elseif [info exists ahf(qcnt)] {			;#	If we've already noted topmost Q-value, but a lower value is blank
			set k $n
			while {$k <= 16} {
				set ahf(q$k) ""
				incr k
			}
			unset ahf(qcnt)
		}
		incr n -1
	}
	if {![info exists ahf(qcnt)]} {
		set ahf(q1) 20
		set ahf(qcnt) 1
	}
	set ahf(maxtstep) [SpecialDecr [expr $ahf(dur) / $ahf(qcnt)]]
	if {![info exists ahf(tstep)] || ![IsNumeric $ahf(tstep)] || ($ahf(tstep) < 0) || ($ahf(tstep) > $ahf(maxtstep))} {
		set ahf(tstep) $ahf(maxtstep)
	}

	set ahf(steptyp) 0
	set ahf(remove) 0
	set pr_ahf 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_ahf
	while {!$finished} {
		DeleteAllTemporaryFiles
		tkwait variable pr_ahf
		switch -- $pr_ahf {
			1 {
				.ahf.0.dslv config -text "" -command {} -state disabled
				.ahf.0.emrg config -text "" -command {} -state disabled
				.ahf.0.emdv config -text "" -command {} -state disabled
				.ahf.0.play config -text "" -command {} -bd 0 -bg [option get . background {}]
				.ahf.0.keep config -text ""  -state disabled -command {}
				.ahf.0.rjct config -text ""  -state disabled -command {}
				.ahf.0.name config -text ""

				;#	GET UNIQUE NAMES FOR OUTFILES

				set n 0
				set gotname 0
				while {!$gotname} {
					set thisfnam $ahf(dofnambas)
					append thisfnam $n $evv(SNDFILE_EXT)
					set gotit 0
					foreach fnam [$wl get 0 end] {
						if {[string first $thisfnam $fnam] == 0} {
							set gotit 1
							break
						}
					}
					if {!$gotit} {
						if {![file exists $thisfnam]} {
							set ahf(dofnam) [file rootname $thisfnam]
							set ahf(doutcnt) $n
							set gotname 1
						}
					}
					incr n
				}
				set n 0
				set gotname 0
				while {!$gotname} {
					set thisfnam $ahf(eofnambas)
					append thisfnam $n $evv(SNDFILE_EXT)
					set gotit 0
					foreach fnam [$wl get 0 end] {
						if {[string first $thisfnam $fnam] == 0} {
							set gotit 1
							break
						}
					}
					if {!$gotit} {
						if {![file exists $thisfnam]} {
							set ahf(eofnam) [file rootname $thisfnam]
							set ahf(eoutcnt) $n
							set gotname 1
						}
					}
					incr n
				}
				set n 0
				set gotname 0
				while {!$gotname} {
					set thisfnam $ahf(edofnambas)
					append thisfnam $n $evv(SNDFILE_EXT)
					set gotit 0
					foreach fnam [$wl get 0 end] {
						if {[string first $thisfnam $fnam] == 0} {
							set gotit 1
							break
						}
					}
					if {!$gotit} {
						if {![file exists $thisfnam]} {
							set ahf(edofnam) [file rootname $thisfnam]
							set ahf(edoutcnt) $n
							set gotname 1
						}
					}
					incr n
				}

				;#	ASSIGN OUTFILE NAME DEPENDING ON WHETHER "DISSOLVE" OR "EMERGE" IS SELECTED

				switch -- $ahf(emerge) {
					0 {
						set ahf(ofnam) $ahf(dofnam)
					}
					1 {
						set ahf(ofnam) $ahf(eofnam)
					}
					2 {
						set ahf(ofnam) $ahf(edofnam)
					}
				}

				;#	TEST PARAMETER VALIDITY

				set q_cnt [TestAhfQvalues]
				if {$q_cnt <= 0} {
					continue
				}
				set ahf(qcnt) $q_cnt
				
				if {([string length $ahf(hcnt)] <= 0) || ![IsNumeric $ahf(hcnt)] || ![regexp {^[0-9]+$} $ahf(hcnt)] || ($ahf(hcnt) < 1) || ($ahf(hcnt) > $ahf(maxhcnt))} {
					Inf "Harmonics-count is invalid or out of range for this filter file (range 1 to $ahf(maxhcnt))"
					continue
				} 
				set ahf(maxtstep) [SpecialDecr [expr $ahf(dur) / $ahf(qcnt)]]
				if {([string length $ahf(tstep)] <= 0) || ![IsNumeric $ahf(tstep)] || ($ahf(tstep) < 0) || ($ahf(tstep) > $ahf(maxtstep))} {
					Inf "Timestep invalid or out of range for src (duration $ahf(dur)) with $ahf(qcnt) filters (range 0 to $ahf(maxtstep))"
					set ahf(tstep) $ahf(maxtstep)
					continue
				} 
				if {$ahf(tstep) < 0.1} {	
					set msg "(almost) no cross-fading will occur with such a small timestep: proceed anyway ??"
					set choice [tk_messageBox -type yesno -default no -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
				}
				if {[string length $ahf(ofnam)] <= 0} {
					Inf "No output filename entered"
					continue
				}
				if {![ValidCDPRootname $ahf(ofnam)]} {
					continue
				}
				set ahf(output) [string tolower $ahf(ofnam)]
				append ahf(output) $evv(SNDFILE_EXT)
				if {[file exists $ahf(output)]} {
					Inf "File $ahf(output) already exists : please choose a different name"
					continue
				}

				Block "CREATING THE BALANCE FILE"

				catch {unset lines}
				if {$ahf(nosrc)} {
					set startat 1
				} else {
					set startat 0
				}
				set n $startat
				set time 0.0
				while {$n <= $ahf(qcnt)} {
					set line $time
					set k $startat
					while {$k <= $ahf(qcnt)} {
						if {$k == $n} {
							lappend line "1"
						} else {
							lappend line "0"
						}
						incr k
					}
					lappend lines $line
					if {$n < $ahf(qcnt)} {
						set halftime [expr $time + ($ahf(tstep)/2.0)]
						set line $halftime
						set k $startat
						while {$k <= $ahf(qcnt)} {
							if {($k == $n) || ($k == [expr $n + 1])} {
								lappend line "0.5"
							} else {
								lappend line "0"
							}
							incr k
						}
						lappend lines $line
					}
					set time [expr $time + $ahf(tstep)]
					incr n
				}
				if [catch {open $ahf(balancefile) "w"} zit] {
					Inf "Cannot create the crossfade balance file"
					UnBlock
					continue
				}
				foreach line $lines {
					puts $zit $line
				}
				close $zit

				;#	SAVING (EVENTUAL) NAMES OF FILES USED IN CROSSFADE-MIX

				catch {unset lines}
				if {$ahf(emerge)} {
					if {!$ahf(nosrc)} {
						set ofnam [file rootname [file tail $ahf(fnamsrc)]]
						append ofnam "_bkwds" $evv(SNDFILE_EXT)
						set line "$ofnam"
						lappend lines $line
					}
				} else {
					set line "$ahf(fnamsrc)"
					lappend lines $line
				}
				set n 1
				while {$n <= $ahf(qcnt)} {
					set ofnam [file rootname [file tail $ahf(fnamsrc)]]
					if {$ahf(emerge)} {
						append ofnam "_bkwd"
					}
					append ofnam "_vfilt_h" $ahf(hcnt) "_q" $ahf(q$n) $evv(SNDFILE_EXT)
					set ofnam [ReplaceDots $ofnam]
					set line "$ofnam"
					lappend lines $line
					incr n
				}
				if [catch {open $ahf(balancesrcs) "w"} zit] {
					Inf "Cannot save names of filtered src files"
				} else {
					foreach line $lines {
						puts $zit $line
					}
					close $zit
				}
				if {$ahf(emerge) == 2} {
					catch {unset lines}
					set ofnam [file rootname [file tail $ahf(fnamsrc)]]
					append ofnam "_premix_bkwds" $ahf(edoutcnt) $evv(SNDFILE_EXT)
					if {[file exists $ofnam]} {
						Inf "Intermediate file $ofnam already exists"
						UnBlock
						continue
					}
					set line "$ofnam"
					lappend lines $line
					set n 1
					while {$n <= $ahf(qcnt)} {
						set ofnam [file rootname [file tail $ahf(fnamsrc)]]
						append ofnam "_vfilt_h" $ahf(hcnt) "_q" $ahf(q$n) $evv(SNDFILE_EXT)
						set ofnam [ReplaceDots $ofnam]
						set line "$ofnam"
						lappend lines $line
						incr n
					}
					if [catch {open $ahf(balancesrcs2) "w"} zit] {
						Inf "Cannot save names of filtered src files"
					} else {
						foreach line $lines {
							puts $zit $line
						}
						close $zit
					}
				}

				;#	IF "EMERGE" RATHER THAN "DISSOLVE", REVERSE THE SRC SOUND

				catch {unset ahf(origfnamsrc)}

				if {$ahf(emerge)} {
					wm title .blocker "REVERSING SOURCE SOUND"
					set cmd [file join $evv(CDPROGRAM_DIR) modify]
					lappend cmd radical 1 $ahf(fnamsrc) $ahf(reverse)
					set prg_dun 0
					set prg_abortd 0
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "Failed to run reversing process"
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
						Inf "Failed in reversing src sound"
						catch {unset CDPidrun}
						UnBlock
						continue
					}
					catch {close $CDPidrun}
					if {![file exists $ahf(reverse)]} {
						Inf "No reversed sound produced"
						catch {unset CDPidrun}
						UnBlock
						continue
					}
					set ahf(origfnamsrc) $ahf(fnamsrc)
					set ahf(fnamsrc) $ahf(reverse)
				}

				;#	CREATE FILTERED FILES

				set n 1
				set OK 1
				while {$n <= $ahf(qcnt)} {
					wm title .blocker "FILTERING WITH Q = $ahf(q$n)"
					set cmd [file join $evv(CDPROGRAM_DIR) filter]
					lappend cmd varibank 2 $ahf(fnamsrc) $ahf(ffnam,$n) $fnamflt $ahf(q$n) 1 -t0 -h$ahf(hcnt) -r0 -d -n
					set prg_dun 0
					set prg_abortd 0
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "Failed to run filtering with Q $ahf(q$n)"
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
						Inf "Failed in filtering with Q $ahf(q$n)"
						catch {unset CDPidrun}
						set OK 0
						break
					}
					catch {close $CDPidrun}
					if {![file exists $ahf(ffnam,$n)]} {
						Inf "No filtered file with Q $ahf(q$n) produced"
						catch {unset CDPidrun}
						set OK 0
						break
					}
					incr n
				}
				if {!$OK} {
					if {$ahf(emerge)} {
						set ahf(fnamsrc) $ahf(origfnamsrc)
						unset ahf(origfnamsrc)
					}
					UnBlock
					continue
				}
				wm title .blocker "CROSS-FADING BETWEEN FILTERED FILES"

				set cmd [file join $evv(CDPROGRAM_DIR) submix]
				lappend cmd faders 
				if {!$ahf(nosrc)} {
					lappend cmd $ahf(fnamsrc)
				}
				set ahf(origoutput) $ahf(output)
				if {$ahf(emerge)} {							;#	If "Emerge"
					set ahf(fnamsrc) $ahf(origfnamsrc)		;#	RESTORE ORIGINAL SRC NAME
					unset ahf(origfnamsrc)
					set ahf(output) $ahf(reverseoutput)		;#	Substitute reversefile name for output name
				}

				set n 1
				while {$n <= $ahf(qcnt)} {
					lappend cmd $ahf(ffnam,$n)
					incr n
				}
				lappend cmd $ahf(output) $ahf(balancefile) 1
				set prg_dun 0
				set prg_abortd 0
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "Failed to run crossfade mix"
					catch {unset CDPidrun}
					set ahf(output) $ahf(origoutput)
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
					Inf "Failed in crossfading mix"
					catch {unset CDPidrun}
					set ahf(output) $ahf(origoutput)
					UnBlock
					continue
				}
				catch {close $CDPidrun}
				if {![file exists $ahf(output)]} {
					Inf "No crossfaded file produced"
					catch {unset CDPidrun}
					set ahf(output) $ahf(origoutput)
					UnBlock
					continue
				}
				set ahf(output) $ahf(origoutput)

				if {$ahf(emerge)} {
					wm title .blocker "RE-REVERSING OUTPUT SOUND"
					set cmd [file join $evv(CDPROGRAM_DIR) modify]
					switch -- $ahf(emerge) {
						1 {
							lappend cmd radical 1 $ahf(reverseoutput) $ahf(output)
							set thisout $ahf(output)
						}
						2 {
							lappend cmd radical 1 $ahf(reverseoutput) $ahf(preoutput)
							set thisout $ahf(preoutput)
						}
					}
					set prg_dun 0
					set prg_abortd 0
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "Failed to run re-reversing process"
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
						Inf "Failed in re-reversing output sound"
						catch {unset CDPidrun}
						UnBlock
						continue
					}
					catch {close $CDPidrun}
					if {![file exists $thisout]} {
						Inf "No re-reversed output produced"
						catch {unset CDPidrun}
						UnBlock
						continue
					}
				}
				if {$ahf(emerge) == 2} {
					set outlen [AhfSndDur $ahf(preoutput)]
					if {$outlen <= 0.0} {
						UnBlock
						continue
					}
					set betwixt [expr $outlen - $ahf(dur)]		;#	Timestep before "Dissolve" sounds are mixed into "Emerge" mix

					wm title .blocker "CREATING OFFSETTING SILENCE OF $betwixt SECS"
					set cmd [file join $evv(CDPROGRAM_DIR) synth]
					lappend cmd silence $ahf(silence) $ahf(srate) $ahf(chans) $betwixt
					set prg_dun 0
					set prg_abortd 0
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "Failed to run silent file synth"
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
						Inf "Failed in generating silent file"
						catch {unset CDPidrun}
						UnBlock
						continue
					}
					catch {close $CDPidrun}
					if {![file exists $ahf(silence)]} {
						Inf "No silent file output produced"
						catch {unset CDPidrun}
						UnBlock
						continue
					}
					set n 1
					set m 17
					while {$n <= $ahf(qcnt)} {
						wm title .blocker "FILTERING FOR DISSOLVE WITH Q = $ahf(q$n)"
						set cmd [file join $evv(CDPROGRAM_DIR) filter]
						lappend cmd varibank 2 $ahf(fnamsrc) $ahf(ffnam,$m) $fnamflt $ahf(q$n) 1 -t0 -h$ahf(hcnt) -r0 -d -n
						set prg_dun 0
						set prg_abortd 0
						if [catch {open "|$cmd"} CDPidrun] {
							Inf "Failed to run filtering for dissolve with Q $ahf(q$n)"
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
							Inf "Failed in filtering for dissolve with Q $ahf(q$n)"
							catch {unset CDPidrun}
							set OK 0
							break
						}
						catch {close $CDPidrun}
						if {![file exists $ahf(ffnam,$m)]} {
							Inf "No filtered file for dissolve with Q $ahf(q$n) produced"
							catch {unset CDPidrun}
							set OK 0
							break
						}
						incr n
						incr m
					}
					if {!$OK} {
						UnBlock
						continue
					}

					set n 1
					set m 17
					set k 33
					while {$n <= $ahf(qcnt)} {
						wm title .blocker "OFFSETTING DISSOLVE WITH Q = $ahf(q$n)"
						set cmd [file join $evv(CDPROGRAM_DIR) sfedit]
						lappend cmd join $ahf(silence) $ahf(ffnam,$m) $ahf(ffnam,$k) -w0
						set prg_dun 0
						set prg_abortd 0
						if [catch {open "|$cmd"} CDPidrun] {
							Inf "Failed to run offsetting of dissolve with Q $ahf(q$n)"
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
							Inf "Failed in offsetting of dissolve with Q $ahf(q$n)"
							catch {unset CDPidrun}
							set OK 0
							break
						}
						catch {close $CDPidrun}
						if {![file exists $ahf(ffnam,$k)]} {
							Inf "No offset file for dissolve with Q $ahf(q$n) produced"
							catch {unset CDPidrun}
							set OK 0
							break
						}
						incr n
						incr m
						incr k
					}
					if {!$OK} {
						UnBlock
						continue
					}

					wm title .blocker "CREATING THE DISSOLVE BALANCE FILE"

					catch {unset lines}
					set n 0
					set time 0.0
					set line $time
					set k 0
					while {$k <= $ahf(qcnt)} {
						if {$k == 0} {
							lappend line "1"
						} else {
							lappend line "0"
						}
						incr k
					}
					lappend lines $line
					set time $betwixt
					while {$n <= $ahf(qcnt)} {
						set line $time
						set k 0
						while {$k <= $ahf(qcnt)} {
							if {$k == $n} {
								lappend line "1"
							} else {
								lappend line "0"
							}
							incr k
						}
						lappend lines $line
						if {$n < $ahf(qcnt)} {
							set halftime [expr $time + ($ahf(tstep)/2.0)]
							set line $halftime
							set k 0
							while {$k <= $ahf(qcnt)} {
								if {($k == $n) || ($k == [expr $n + 1])} {
									lappend line "0.5"
								} else {
									lappend line "0"
								}
								incr k
							}
							lappend lines $line
						}
						set time [expr $time + $ahf(tstep)]
						incr n
					}
					if [catch {open $ahf(balancefile2) "w"} zit] {
						Inf "Cannot create the dissolve crossfade balance file"
						UnBlock
						continue
					}
					foreach line $lines {
						puts $zit $line
					}
					close $zit

					wm title .blocker "CROSS-FADING TO DISSOLVE"

					set cmd [file join $evv(CDPROGRAM_DIR) submix]
					lappend cmd faders $ahf(preoutput)

					set n 1
					set k 33
					while {$n <= $ahf(qcnt)} {
						lappend cmd $ahf(ffnam,$k)
						incr n
						incr k
					}
					lappend cmd $ahf(output) $ahf(balancefile2) 1
					set prg_dun 0
					set prg_abortd 0
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "Failed to run crossfade to dissolve mix"
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
						Inf "Failed in crossfading to dissolve mix"
						catch {unset CDPidrun}
						UnBlock
						continue
					}
					catch {close $CDPidrun}
					if {![file exists $ahf(output)]} {
						Inf "No crossfade-to-dissolve file produced"
						catch {unset CDPidrun}
						UnBlock
						continue
					}
				}
				set ahf(kept) 0			;#	Either Save or Delete output produced
				UnBlock
				.ahf.0.run  config -text ""  -command {} -bd 0 -bg [option get . background {}]
				.ahf.0.quit config -text "" -command {} -bd 0
				.ahf.0.play config -text "Play"  -command "AhfPlay" -bd 2 -bg $evv(EMPH)
				.ahf.0.keep config -text "Keep"    -state normal -command "AhfKeep 1"
				.ahf.0.rjct config -text "Delete"  -state normal -command "AhfKeep 0"
				.ahf.0.name config -text $ahf(output)
				vwait ahf(kept)
			}
			0 {
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

;#-- Derive successive Q-values from 1st.

proc AhfMultiply {typ} {
	global ahf
	switch -- $typ {
		0 {
			set ahf(step) ""
		}
		1 -
		2 {
			if {([string length $ahf(q1)] <= 0) || ![IsNumeric $ahf(q1)] || ($ahf(q1) < 20) || ($ahf(q1) > 10000)} {
				Inf "1st Q value is invalid or out of range  (20 - 10000) : cannot apply the designated step"
				set ahf(steptyp) 0
				return
			}
			if {([string length $ahf(step)] <= 0) || ![IsNumeric $ahf(step)]} {
				Inf "Step value is invalid"
				set ahf(steptyp) 0
				return
			}
			switch -- $typ {
				1 {
					if {($ahf(step) <= 0) || ($ahf(step) > [expr 10000 - $ahf(q1)])} {
						Inf "Step value is out of range (>0 to [expr 10000 - $ahf(q1)])"
						set ahf(steptyp) 0
						return
					}
					set ahf(qcnt) 1
					set n 2
					while {$n <= 16} {
						set nextq [expr $ahf(q$ahf(qcnt)) + $ahf(step)]
						if {$nextq <= 10000} {
							set ahf(q$n) $nextq
							incr ahf(qcnt)
						} else {
							break
						}
						incr n
					}
				}
				2 {
					if {($ahf(step) <= 1) || ([expr $ahf(step) * $ahf(q1)] > 10000)} {
						Inf "Step value is out of range (>1 to [expr 10000/$ahf(q1)])"
						set ahf(steptyp) 0
						return
					}
					set ahf(qcnt) 1
					set n 2
					while {$n <= 16} {
						set nextq [expr $ahf(q$ahf(qcnt)) * $ahf(step)]
						if {$nextq <= 10000} {
							set ahf(q$n) $nextq
							incr ahf(qcnt)
						} else {
							break
						}
						incr n
					}
				}
			}
			set n $ahf(qcnt)
			incr n
			while {$n <= 16} {
				set ahf(q$n) ""
				incr n
			}
			set ahf(maxtstep) [SpecialDecr [expr $ahf(dur) / $ahf(qcnt)]]
			if {([string length $ahf(tstep)] <= 0) || ($ahf(tstep) > $ahf(maxtstep))} {
				set ahf(tstep) $ahf(maxtstep)
			}
		}
	}
}

#---- Reduce number of Q values used by process

proc AhfRemoveLastQval {} {
	global ahf
	if {$ahf(remove)} {
		if {$ahf(qcnt) > 1} {
			set ahf(q$ahf(qcnt)) ""
			incr ahf(qcnt) -1
		}
	}
	set ahf(maxtstep) [SpecialDecr [expr $ahf(dur) / $ahf(qcnt)]]
	if {$ahf(tstep) > $ahf(maxtstep)} {
		set ahf(tstep) $ahf(maxtstep)
	}
	set ahf(remove) 0
}

#---- USe Up/Down arrows to incr and decr parameter vals

proc IncrAhfQ1 {down} {
	global ahf
	if {([string length $ahf(q1)] <= 0) || ![IsNumeric $ahf(q1)] || ($ahf(q1) < 20) || ($ahf(q1) > 10000)} {
		Inf "1st Q value is invalid or out of range  (20 to 10000)"
		return
	}
	if {$down} {
		if {$ahf(q1) >= 21} {
			set ahf(q1) [expr $ahf(q1) - 1]
		}
	} else {
		if {$ahf(q1) <= 9999} {
			set ahf(q1) [expr $ahf(q1) + 1]
		}
	}
}

proc IncrAhfHcnt {down} {
	global ahf
	if {([string length $ahf(hcnt)] <= 0) || ![IsNumeric $ahf(hcnt)] || ![regexp {^[0-9]+$} $ahf(hcnt)] || ($ahf(hcnt) < 1) || ($ahf(hcnt) > $ahf(maxhcnt))} {
		Inf "Harmonics-count is invalid or out of range for this filter file (range 1 to $ahf(maxhcnt))"
		set ahf(hcnt) $ahf(maxhcnt)
		return
	}
	if {$down} {
		if {$ahf(hcnt) > 1} {
			incr ahf(hcnt) -1
		}
	} else {
		if {$ahf(hcnt) < $ahf(maxhcnt)} {
			incr ahf(hcnt)
		}
	}
}

#--- Find max MIDI value in varibank filter file

proc GetEhfMaxmidi {fnam} {

	if [catch {open $fnam} zit] {
		Inf "Cannot open varibank filter file [file tail $fnam] to test for max harmonic count for filtering"
		return 0
	}
	set maxmidi 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		set itemcnt 0
		set line [split $line]
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				if {![IsEven $itemcnt]} {
					if {$item > $maxmidi} {
						set maxmidi $item
					}
				}
				incr itemcnt
			}
		}
		break
	}
	close $zit
	if {$maxmidi <= 0} {
		Inf "Cannot find max MIDI value in filter data"
	}
	return $maxmidi
}

#--- Clicking on maxvalue displayboxes(s) transfers maxvalue to entrybox

proc DoAhfHcntBind {} {
	global ahf
	set ahf(hcnt) $ahf(maxhcnt)
}

proc DoAhfTstepBind {} {
	global ahf
	set ahf(tstep) $ahf(maxtstep)
}

#--- Play output sound from ahf process

proc AhfPlay {} {
	global ahf
	if {![info exists ahf(output)]} {
		Inf "Cannot find output file"
	} elseif {![file exists $ahf(output)]} {
		Inf "Cannot find file $ahf(output)"
	} else {
		PlaySndfile $ahf(output) 0
	}
}

proc AhfKeep {keep} {
	global ahf wstk evv pr_ahf wl
	if {$keep} {
		if {[FileToWkspace $ahf(output) 0 0 0 0 1] > 0} {
			Inf "File $ahf(output) is on the workspace"
		}
		set msg "Do you want to save the filter files and the balance file ??"
		set choice [tk_messageBox -type yesno -default no -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			set n 1
			while {$n <= $ahf(qcnt)} {
				set ofnam [file rootname [file tail $ahf(fnamsrc)]]
				if {$ahf(emerge)} {				;#	With Emerge, backwards src is filtered, so filter files are of bkwds src
					append ofnam "_bkwd"
				}
				append ofnam "_vfilt_h" $ahf(hcnt) "_q" $ahf(q$n) $evv(SNDFILE_EXT)
				set ofnam [ReplaceDots $ofnam]
				if {![file exists $ofnam]} {
					if [catch {file rename $ahf(ffnam,$n) $ofnam} zit] {
						Inf "Failed to rename filter file with Q $ahf(q$n)"
					} else {
						FileToWkspace $ofnam 0 0 0 0 1
					}
				}
				incr n
			}
			if {$ahf(emerge)} {
				set ofnam [file rootname [file tail $ahf(fnamsrc)]]
				append ofnam "_bkwds" $ahf(edoutcnt) $evv(SNDFILE_EXT)
				if {![file exists $ofnam]} {
					if [catch {file rename $ahf(reverse) $ofnam} zit] {
						Inf "Failed to rename reversed file"
					} else {
						FileToWkspace $ofnam 0 0 0 0 1
					}
				}
			}
			if {$ahf(emerge) == 2} {			;#	With Emerge+Dissolve, there are offset filter-versions of the non-reversed sound		
				set n 1
				set k 33
				while {$n <= $ahf(qcnt)} {
					set ofnam [file rootname [file tail $ahf(fnamsrc)]]
					append ofnam "_vfilt_h" $ahf(hcnt) "_q" $ahf(q$n) $evv(SNDFILE_EXT)
					set ofnam [ReplaceDots $ofnam]
					if {![file exists $ofnam]} {
						if [catch {file rename $ahf(ffnam,$k) $ofnam} zit] {
							Inf "Failed to rename filter file with Q $ahf(q$n)"
						} else {
							FileToWkspace $ofnam 0 0 0 0 1
						}
					}
					incr n
					incr k
				}
				set ofnam [file rootname [file tail $ahf(fnamsrc)]]
				append ofnam "_premix_bkwds" $ahf(edoutcnt) $evv(SNDFILE_EXT)
				if {![file exists $ofnam]} {
					if [catch {file rename $ahf(preoutput) $ofnam} zit] {
						Inf "Failed to rename pre-output file (emerge mix)"
					} else {
						FileToWkspace $ofnam 0 0 0 0 1
					}
				}
			}
			set ofnam [file rootname $ahf(ofnam)]
			append ofnam "_balance" $evv(TEXT_EXT)
			if [catch {file rename $ahf(balancefile) $ofnam} zit] {
				Inf "Failed to rename balance file"
			} else {
				FileToWkspace $ofnam 0 0 0 0 1
			}
			if {[file exists $ahf(balancesrcs)]} {
				set ofnam [file rootname $ahf(ofnam)]
				append ofnam "_balancesrcs" $evv(TEXT_EXT)
				if [catch {file rename $ahf(balancesrcs) $ofnam} zit] {
					Inf "Failed to rename balance srcs file"
				} else {
					FileToWkspace $ofnam 0 0 0 0 1
				}
			}
			if {$ahf(emerge) == 2} {
				set ofnam [file rootname $ahf(ofnam)]
				append ofnam "_balance2" $evv(TEXT_EXT)
				if [catch {file rename $ahf(balancefile2) $ofnam} zit] {
					Inf "Failed to rename balance file"
				} else {
					FileToWkspace $ofnam 0 0 0 0 1
				}
				if {[file exists $ahf(balancesrcs2)]} {
					set ofnam [file rootname $ahf(ofnam)]
					append ofnam "_balancesrcs2" $evv(TEXT_EXT)
					if [catch {file rename $ahf(balancesrcs2) $ofnam} zit] {
						Inf "Failed to rename balance-2 srcs file"
					} else {
						FileToWkspace $ofnam 0 0 0 0 1
					}
				}
			}
		}

		;#	RESET OUTPUT NAME FOR ANY FURTHER PASS

		switch -- $ahf(emerge) {
			0 {
				incr ahf(doutcnt)
				set n $ahf(doutcnt)
			}
			1 {
				incr ahf(eoutcnt)
				set n $ahf(eoutcnt)
			} 
			2 {
				incr ahf(edoutcnt)
				set n $ahf(edoutcnt)
			} 
		}
		set gotname 0
		while {!$gotname} {
			switch -- $ahf(emerge) {
				0 {
					set thisfnam $ahf(dofnambas)
				}
				1 {
					set thisfnam $ahf(eofnambas)
				} 
				2 {
					set thisfnam $ahf(edofnambas)
				}
			}
			append thisfnam $n $evv(SNDFILE_EXT)
			set gotit 0
			foreach fnam [$wl get 0 end] {
				if {([string first $thisfnam $fnam] == 0)} {
					set gotit 1
					break
				}
			}
			if {!$gotit} {
				switch -- $ahf(emerge) {
					0 {
						if {![file exists $thisfnam]} {
							set ahf(dofnam) [file rootname $thisfnam]
							set ahf(ofnam) $ahf(dofnam)
							set ahf(doutcnt) $n
							set gotname 1
						}
					}
					1 {
						if {![file exists $thisfnam]} {
							set ahf(eofnam) [file rootname $thisfnam]
							set ahf(ofnam) $ahf(eofnam)
							set ahf(eoutcnt) $n
							set gotname 1
						}
					} 
					2 {
						if {![file exists $thisfnam]} {
							set ahf(edofnam) [file rootname $thisfnam]
							set ahf(ofnam) $ahf(edofnam)
							set ahf(edoutcnt) $n
							set gotname 1
						}
					} 
				}
				set gotname 1
			}
			incr n
		}
	} else {
		set msg "Sure you want to delete the output ??"
		set choice [tk_messageBox -type yesno -default no -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			if [catch {file delete $ahf(output)} zit] {
				Inf "Cannot delete the output files"
			}
		}
	}
	.ahf.0.run  config -text "Run" -command "set pr_ahf 1" -bd 2 -bg $evv(EMPH)
	.ahf.0.quit config -text "Quit" -command "set pr_ahf 0" -bd 2
	.ahf.0.dslv config -text "Disolv" -command "AhfEmergeTypeSet 0" -state normal
	.ahf.0.emrg config -text "Emerge" -command "AhfEmergeTypeSet 1" -state normal
	.ahf.0.emdv config -text "EmgDsv" -command "AhfEmergeTypeSet 2" -state normal
	.ahf.0.play config -text ""  -command {} -bd 0 -bg [option get . background {}]
	set ahf(keep) -1
	.ahf.0.keep config -text ""  -command {} -state disabled
	.ahf.0.rjct config -text ""  -command {} -state disabled 
	.ahf.0.name config -text ""
	set ahf(kept) 1
}

#--- Switch between "Dissolve" and "Emerge" names

proc AhfEmergeTypeSet {emerge} {
	global ahf
	switch -- $ahf(emerge) {
		0 {
			set ahf(ofnam) $ahf(dofnam)
			if {![info exists ahf(nosrcbak)]} {
				set ahf(nosrcbak) $ahf(nosrc)
			}
			set ahf(nosrc) 0
			.ahf.9 config -text "" -state disabled
		}
		1 {
			set ahf(ofnam) $ahf(eofnam)
			if {![info exists ahf(nosrcbak)]} {
				set ahf(nosrcbak) $ahf(nosrc)
			}
			set ahf(nosrc) 0
			.ahf.9 config -text "" -state disabled
		} 
		2 {
			set ahf(ofnam) $ahf(edofnam)
			.ahf.9 config -text "Omit source from mix" -state normal
			if {[info exists ahf(nosrcbak)]} {
				set ahf(nosrc) $ahf(nosrcbak)
				unset ahf(nosrcbak)
			}
		}
	} 
}

proc AhfEscapeBind {} {
	global pr_ahf
	if {[string length [.ahf.0.quit cget -text]] > 0} {
		set pr_ahf 0
	}
}

#--- Cope with rounding errors in calculating timestep

proc SpecialDecr {val} {
	global evv
	if {$val > $evv(FLTERR)} {
		set val [expr $val - $evv(FLTERR)]
	}
	return $val
}

#--- Find duration of Ahf output file

proc AhfSndDur {fnam} {
	global evv CDPid parse_error props_got propslist

	catch {unset propslist}
	set parse_error 0
	set props_got 0
	set cmd [file join $evv(CDPROGRAM_DIR) cdparse]
	lappend cmd $fnam 0
	if [catch {open "|$cmd"} CDPid] {
		Inf "Finding duration of file $fnam failed"
		catch {unset CDPid}
		return 0
	} else {
		set propslist ""
		fileevent $CDPid readable VariboxAccumulateFileProps
	}
	vwait props_got
	if {$parse_error} {
		set msg "Finding duration of file $fnam failed"
		return 0
	}
	if {![info exists propslist] || ([llength $propslist] == 0)} {
		set msg "Cannot get duration of $fnam : failed to get properties of file $fnam"
		return 0
	}
	if {[llength $propslist] != ($evv(CDP_PROPS_CNT) + $evv(CDP_MAXSAMP_CNT))} {
		set msg "Cannot get duration of $fnam : wrong number of props ([llength $propslist]) returned"
		return 0
	}
	return [lindex $propslist $evv(DUR)]
}

#---- Test Q values entered in Apply HF

proc TestAhfQvalues {} {
	global ahf
	if {([string length $ahf(q1)] <= 0) || ![IsNumeric $ahf(q1)] || ($ahf(q1) < 20) || ($ahf(q1) > 10000)} {
		Inf "First Q value invalid (range 20 to 10000)"
		return 0
	}
	set n 16
	catch {unset qcnt}
	while {$n > 0} {
		if {[string length $ahf(q$n)] > 0} {
			if {![IsNumeric $ahf(q$n)] || ($ahf(q$n) < 20) || ($ahf(q$n) > 10000)} {
				Inf "Q value $n invalid (range 20 to 10000)"
				return 0	
			} 
			if {![info exists qcnt]} {			;#	If this is last valid Q-value, Note total number of Q values used
				set qcnt $n
			}
		} elseif [info exists qcnt] {			;#	If we've already noted topmost Q-value, but a lower value is blank
			Inf "Q value $n missing"
			return 0
		}
		incr n -1
	}
	if {![info exists qcnt]} {
		Inf "No Q values set"
		return 0
	}
	return $qcnt
}

proc AhfSaveQset {} {
	global ahf wstk
	set q_cnt [TestAhfQvalues]
	if {$q_cnt < 0}  {
		return
	}
	if {[string length $ahf(qsetname)] <= 0} {
		Inf "No name entered for Q set"
		return
	}
	if {![ValidCDPRootname $ahf(qsetname)]} {
		return
	}
	set k [lsearch $ahf(qsetnames) $ahf(qsetname)]
	if {$k >= 0} {
		set msg "This Q-set name already exists: overwrite existing set of same name ??"
		set choice [tk_messageBox -type yesno -default no -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		} else {
			set ahf(qsetnames) [lreplace $ahf(qsetnames) $k $k]
			set ahf(qsets) [lreplace $ahf(qsets) $k $k]
		}
	}
	set qset $ahf(qsetname)
	set n 1
	while {$n <= $ahf(qcnt)} {
		lappend qset $ahf(q$n)
		incr n
	}
	lappend ahf(qsets) $qset
	lappend ahf(qsetnames) $ahf(qsetname)
	Inf "Q-set $ahf(qsetname) saved" 
}

#--- Load a previously saved set of Q values

proc AhfLoadQset {} {
	global ahf pr_ahfqsel evv wstk
	catch {unset ahf(qset)}
	if {![info exists ahf(qsets)]} {
		Inf "No pre-existing Q-sets to load"
		return
	}
	set len [llength $ahf(qsets)]
	if {$len == 0} {
		Inf "No pre-existing Q-sets to load"
		return
	} elseif {$len == 1} {
		if {$ahf(qsetname) == [lindex $ahf(qsetnames) 0]} {
			Inf "No other Qsets to load"
			return
		} else {
			set ahf(qset) [lindex $ahf(qsets) 0]
		}
	} else {
		set f .ahfqsel
		if [Dlg_Create $f "SELECT QSET" "set pr_ahfqsel 0" -borderwidth $evv(SBDR)] {
			frame $f.0
			button $f.0.sel  -text "Select" -command "set pr_ahfqsel 1" -width 6 -bg $evv(EMPH) -highlightbackground [option get . background {}]
			button $f.0.del  -text "Delete" -command "set pr_ahfqsel 2" -width 6 -highlightbackground [option get . background {}]
			button $f.0.quit -text "Quit"   -command "set pr_ahfqsel 0" -width 6 -highlightbackground [option get . background {}]
			pack $f.0.sel $f.0.del -side left -padx 8
			pack $f.0.quit -side right
			pack $f.0 -side top -fill x -expand true
			frame $f.1
			label $f.1.tit -text "Select a Qset from the list" -fg $evv(SPECIAL)
			Scrolled_Listbox $f.1.ll -width 80 -height 20 -selectmode single
			pack $f.1.tit $f.1.ll -side top -fill x -expand true -pady 2
			pack $f.1 -side top -fill x -expand true
			bind $f <Escape> {set pr_ahfqsel 0}
			bind $f <Return> {set pr_ahfqsel 1}
			wm resizable $f 0 0
		}
		$f.1.ll.list delete 0 end
		foreach qset $ahf(qsets) {
			$f.1.ll.list insert end $qset
		}
		set pr_ahfqsel 0
		set finished 0
		raise $f
		update idletasks
		StandardPosition $f
		My_Grab 0 $f pr_ahfqsel
		while {!$finished} {
			tkwait variable pr_ahfqsel
			switch -- $pr_ahfqsel {
				1 {
					set sel [$f.1.ll.list curselection]
					if {![info exists sel] || ([llength $sel] != 1)} {
						Inf "No Q-set selected"
						continue
					}
					set ahf(qset) [$f.1.ll.list get $sel]
					set finished 1
				}
				2 {
					set sel [$f.1.ll.list curselection]
					if {![info exists sel] || ([llength $sel] != 1)} {
						Inf "No Q-set selected"
						continue
					}
					set ahf(qset) [$f.1.ll.list get $sel]
					set msg "Are you sure you want to delete Q-set [lindex $ahf(qset) 0] ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
					$f.1.ll.list delete $sel
					set ahf(qsets) [lreplace $ahf(qsets) $sel $sel]
					set nam [lindex $ahf(qsetnames) $sel]
					set ahf(qsetnames) [lreplace $ahf(qsetnames) $sel $sel]
					if [string match $ahf(qsetname) $nam] {
						set ahf(qsetname) ""
					}
					catch {unset ahf(qset)}
				}
				0 {
					catch {unset ahf(qset)}
					set finished 1
				}		
			}
		}
		My_Release_to_Dialog $f
		Dlg_Dismiss $f
	}
	if {[info exists ahf(qset)]} {
		set ahf(qsetname) [lindex $ahf(qset) 0]
		set ahf(qcnt) [expr [llength $ahf(qset)] - 1]
		set n 1
		while {$n <= $ahf(qcnt)} {
			set ahf(q$n) [lindex $ahf(qset) $n]
			incr n
		}
		while {$n <= 16} {
			set ahf(q$n) ""
			incr n
		}
		set ahf(maxtstep) [SpecialDecr [expr $ahf(dur) / $ahf(qcnt)]]
		if {![info exists ahf(tstep)] || ![IsNumeric $ahf(tstep)] || ($ahf(tstep) < 0) || ($ahf(tstep) > $ahf(maxtstep))} {
			set ahf(tstep) $ahf(maxtstep)
		}
		set ahf(steptyp) 0
	}
}

#--- Load/Save existing qsets for ApplyHF

proc AhfLoadQsets {} {
	global ahf evv
	set fnam [file join $evv(URES_DIR) ahfq$evv(CDP_EXT)]
	set ahf(qsets) {}
	set ahf(qsetnames) {}
	if {[file exists $fnam]} {
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot open Qset data file to load existing Qsets"
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
			set itemcnt 0
			catch {unset nuline}
			set OK 1
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] > 0} {
					if {$itemcnt == 0} {
						if {![ValidCDPRootname $item]} {
							Inf "Invalid Q set name in data file : ignoring this Q-set"
							set OK 0
							break
						} else {
							set thisname $item
						}
					} elseif {([string length $item] <= 0) || ![IsNumeric $item] || ($item < 20) || ($item > 10000)} {
						Inf "Invalid Q value ($item) in Q-set $thisname in data file : ignoring this Q-set"
						set OK 0
						break
					}
					lappend nuline $item
					incr itemcnt
				}
			}
			if {$itemcnt < 2} {
				set OK 0
			}
			if {$OK} {
				lappend ahf(qsets) $nuline			
			}
		}
		close $zit
	}
	foreach qset $ahf(qsets) {
		lappend ahf(qsetnames) [lindex $qset 0]
	}
}

proc AhfSaveQsets {} {
	global ahf evv
	set fnam [file join $evv(URES_DIR) ahfq$evv(CDP_EXT)]
	if [catch {open $fnam "w"} zit] {
		Inf "Cannot open Q-set data file to write new qsets"
		return
	}
	foreach qset $ahf(qsets) {
		puts $zit $qset
	}
	close $zit
}

proc ReFormatMchan {} {
	global evv chlist pa pr_rfm rfm_format rfm_nam prg_dun prg_abortd simple_program_messages CDPidrun

	if {![info exists chlist] || ([llength $chlist] <= 0)} {
		Inf "Place mono soundfiles or single multichannel file on the chosen-files list"
		return
	}
	set n 0
	foreach fnam $chlist {
		incr n
		if {($n > 4) && ($chans == 2)} {
			Inf "Use no more than 4 stereo soundfiles"
			return
		}
		if {$n > 8} {
			Inf "Use no more than 8 mono soundfiles"
			return
		}
		if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
			Inf "Place mono soundfiles or single multichannel file on the chosen-files list"
			return
		}
		if {![info exists fnams]} {
			set chans $pa($fnam,$evv(CHANS))
		} elseif {$chans > 2} {							;#	must be more than one file, so first file must be mono or stereo
			Inf "Use either several mono or stereo soundfiles or one multichannel file"
			return
		} elseif {$pa($fnam,$evv(CHANS)) != $chans} {		;#	subsequent files must all be mono
			Inf "Use either several mono or stereo soundfiles or one multichannel file"
			return
		}
		lappend fnams $fnam
	}
	set filecnt [llength $fnams]
	if {$chans == 1} {
		if {($filecnt < 4) || ($filecnt > 8) || ($filecnt == 6)} {
			Inf "At present, no reformatting available for $filecnt mono files"
			return
		}
	} elseif {($chans == 3)  || ($chans == 6) || ($chans > 8)} {
		Inf "At present, no reformatting available for $chans channel files"
		return
	}
	if {$chans == 2} {
		if {($filecnt != 2) && ($filecnt != 4)} {
			Inf "At present, no reformatting available for $filecnt stereo files"
			return
		}
	}
	set f .rfm
	if [Dlg_Create $f "REFORMAT SOUND IN 8-CHANNELS" "set pr_rfm 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.r -text Format -command "set pr_rfm 1" -highlightbackground [option get . background {}]
		button $f.0.q -text Quit   -command "set pr_rfm 0" -highlightbackground [option get . background {}]
		pack $f.0.r -side left
		pack $f.0.q -side right
		pack $f.0 -side top -fill x -expand true 
		label $f.1 -text "SELECT THE INPUT FORMAT" -fg $evv(SPECIAL)
		pack $f.1 -side top -pady 2
		frame $f.2
		radiobutton $f.2.0 -text ""			   -variable rfm_format -value -1 -width 23
		radiobutton $f.2.1 -text "LRRL RING"   -variable rfm_format -value 41 -width 23
		radiobutton $f.2.2 -text "LRLR ZZAG"   -variable rfm_format -value 42 -width 23
		radiobutton $f.2.3 -text "LLRR LthenR" -variable rfm_format -value 43 -width 23
		radiobutton $f.2.4 -text ""			   -variable rfm_format -value -1 -width 23
		radiobutton $f.2.5 -text ""			   -variable rfm_format -value -1 -width 23
		pack $f.2.0 $f.2.1 $f.2.2 $f.2.3 $f.2.4 $f.2.5 -side left
		pack $f.2 -side top 
		frame $f.3
		label $f.3.ll -text "Output Filename"
		entry $f.3.e  -textvariable rfm_nam -width 24
		pack $f.3.ll $f.3.e -side left -padx 2
		pack $f.3 -side top -pady 2
		bind $f <Escape> {set pr_rfm 0}
		bind $f <Return> {set pr_rfm 1}
		wm resizable $f 0 0
	}	
	set rfm_format 0
	if {$chans == 2} {
		set kk $filecnt		;#	Choose on basis of number of mono files
	} elseif {$chans > 1} {
		set kk $chans		;#	Choose on basis of channel count in single file
	} else {
		set kk $filecnt		;#	Choose on basis of number of mono files
	}
	switch -- $kk {
		2 {
			$f.2.0 config -text ""			  -value -1	-state disabled
			$f.2.2 config -text "LR-LR ZZAG"  -value 21	-state normal
			$f.2.1 config -text "LR-RL RING"  -value 22	-state normal
			$f.2.3 config -text ""			  -value -1	-state disabled
			$f.2.4 config -text ""			  -value -1	-state disabled
			$f.2.5 config -text ""		      -value -1	-state disabled
		}
		4 {
			if {$chans == 2} {
				$f.2.0 config -text ""			  -value -1	-state disabled
				$f.2.1 config -text "LR_LR_LR_LR" -value 44	-state normal
				$f.2.2 config -text "LR_LR_LR_FB" -value 45	-state normal
				$f.2.3 config -text "FB_LR_LR_LR" -value 46	-state normal
				$f.2.4 config -text "LR_FB_LR_LR" -value 47	-state normal
				$f.2.5 config -text ""		      -value -1	-state disabled
			} else {
				$f.2.0 config -text ""			  -value -1	-state disabled
				$f.2.1 config -text "LRRL RING"   -value 41	-state normal
				$f.2.2 config -text "LRLR ZZAG"   -value 42	-state normal
				$f.2.3 config -text "LLRR LthenR" -value 43	-state normal
				$f.2.4 config -text ""			  -value -1	-state disabled
				$f.2.5 config -text ""		      -value -1	-state disabled
			}
		}
		5 {
			$f.2.0 config -text ""			  -value -1	-state disabled
			$f.2.1 config -text "C-LR-LR"	  -value 51	-state normal
			$f.2.2 config -text "LR-LR-C"	  -value 52	-state normal
			$f.2.3 config -text "LRrear_C_LR" -value 53	-state normal
			$f.2.4 config -text "L to R"	  -value 54	-state normal
			$f.2.5 config -text ""			  -value -1	-state disabled
		}
		7 {
			$f.2.0 config -text ""			 -value -1	-state disabled
			$f.2.1 config -text "C-LR-LR-LR" -value 71	-state normal
			$f.2.2 config -text "LR-LR-LR-C" -value 72	-state normal
			$f.2.3 config -text "L to R"     -value 73	-state normal
			$f.2.4 config -text ""		     -value -1	-state disabled
			$f.2.5 config -text ""		     -value -1	-state disabled
		}

		8 {
			if {$filecnt == 8} {	;#	8 mono to 8-chan ring
				$f.2.0 config -text "1 to 8 RING"		  -value 80	-state normal
			} else {				;#	1 8chan-file in non-ring format
				$f.2.0 config -text ""					  -value -1	-state disabled
			}
			$f.2.1 config -text "LR-LR-LR-LR OCTAGON"	  -value 81
			$f.2.2 config -text "LR-LR-LR-FB DIAMOND"	  -value 82
			$f.2.3 config -text "LR-FB-LR-LRrear DIAMOND" -value 83
			$f.2.4 config -text "LR-FB-LRrear-LR DIAMOND" -value 84	-state normal
			$f.2.5 config -text "FB-LR-LR-LR DIAMOND"     -value 85	-state normal
		}
	}
	set mixfnam $evv(DFLT_OUTNAME)
	append mixfnam 0 [GetTextfileExtension mmx]

					;#	SET DEFAULT OUTNAME

	set rfm_nam [FindCommonFilename $fnams]
	set pr_rfm 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_rfm
	while {!$finished} {
		tkwait variable pr_rfm
		switch -- $pr_rfm {
			1 {
				DeleteAllTemporaryFiles
				if {[string length $rfm_nam] <= 0} {
					Inf "No output filename entered"
					continue
				}
				set ofnam [string tolower $rfm_nam]
				if {![ValidCDPRootname $ofnam]} {
					continue
				}
				append ofnam $evv(SNDFILE_EXT)
				if {[file exists $ofnam]} {
					Inf "File $ofnam exists : please choose a different outputfile name"
					continue
				}
				if {$rfm_format < 41} {
					Inf "No input format set"
					continue
				}
				if {$filecnt == 1} {
					set fnam [lindex $fnams 0]
				}
				catch {unset lines}
				set line 8
				lappend lines $line
				switch -- $rfm_format {
					21 {	;#	STEREOS --> 4(in 8)
						set n 0
						foreach fnam $fnams {
							switch -- $n {
								0 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:8" 1 "2:2" 1] }
								1 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:6" 1 "2:4" 1] }
							}
							lappend lines $line
							incr n
						}
					}
					22 {	;#	STEREOS --> 4(in 8)
						set n 0
						foreach fnam $fnams {
							switch -- $n {
								0 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:8" 1 "2:2" 1] }
								1 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:4" 1 "2:6" 1] }
							}
							lappend lines $line
							incr n
						}
					}
					41 {
						if {$filecnt > 1} { 
							set n 0
							foreach fnam $fnams {
								switch -- $n {
									0 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:8" 1] }
									1 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:2" 1] }
									2 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:4" 1] }
									3 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:6" 1] }
								}
								lappend lines $line
								incr n
							}
						} else {
							set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:8" 1 "2:2" 1 "3:4" 1 "4:6" 1]
							lappend lines $line
						}
					}
					42 {
						if {$filecnt > 1} { 
							set n 0
							foreach fnam $fnams {
								switch -- $n {
									0 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:8" 1] }
									1 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:2" 1] }
									2 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:6" 1] }
									3 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:4" 1] }
								}
								lappend lines $line
								incr n
							}
						} else {
							set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:8" 1 "2:2" 1 "3:6" 1 "4:4" 1]
							lappend lines $line
						}
					}
					43 {
						if {$filecnt > 1} { 
							set n 0
							foreach fnam $fnams {
								switch -- $n {
									0 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:8" 1] }
									1 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:6" 1] }
									2 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:2" 1] }
									3 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:4" 1] }
								}
								lappend lines $line
								incr n
							}
						} else {
							set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:8" 1 "2:6" 1 "3:2" 1 "4:4" 1]
							lappend lines $line
						}
					}
					44 {	;#	STEREOS
						set n 0
						foreach fnam $fnams {
							switch -- $n {
								0 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:1" 1 "2:2" 1] }
								1 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:8" 1 "2:3" 1] }
								2 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:7" 1 "2:4" 1] }
								3 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:6" 1 "2:5" 1] }
							}
							lappend lines $line
							incr n
						}
					}
					45 {	;#	STEREOS
						set n 0
						foreach fnam $fnams {
							switch -- $n {
								0 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:8" 1 "2:2" 1] }
								1 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:7" 1 "2:3" 1] }
								2 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:6" 1 "2:4" 1] }
								3 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:1" 1 "2:5" 1] }
							}
							lappend lines $line
							incr n
						}
					}
					46 {	;#	STEREOS
						set n 0
						foreach fnam $fnams {
							switch -- $n {
								0 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:1" 1 "2:5" 1] }
								1 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:8" 1 "2:2" 1] }
								2 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:7" 1 "2:3" 1] }
								3 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:6" 1 "2:4" 1] }
							}
							lappend lines $line
							incr n
						}
					}
					47 {	;#	STEREOS
						set n 0
						foreach fnam $fnams {
							switch -- $n {
								0 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:8" 1 "2:2" 1] }
								1 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:1" 1 "2:5" 1] }
								2 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:7" 1 "2:3" 1] }
								3 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:6" 1 "2:4" 1] }
							}
							lappend lines $line
							incr n
						}
					}
					51 {
						if {$filecnt > 1} { 
							set n 0
							foreach fnam $fnams {
								switch -- $n {
									0 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:1" 1] }
									1 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:8" 1] }
									2 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:2" 1] }
									3 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:7" 1] }
									4 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:3" 1] }
								}
								lappend lines $line
								incr n
							}
						} else {
							set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:1" 1 "2:8" 1 "3:2" 1 "4:7" 1 "5:3" 1]
							lappend lines $line
						}
					}
					52 {
						if {$filecnt > 1} { 
							set n 0
							foreach fnam $fnams {
								switch -- $n {
									0 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:8" 1] }
									1 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:2" 1] }
									2 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:7" 1] }
									3 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:3" 1] }
									4 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:1" 1] }
								}
								lappend lines $line
								incr n
							}
						} else {
							set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:8" 1 "2:2" 1 "3:7" 1 "4:3" 1 "5:1" 1]
							lappend lines $line
						}
					}
					53 {
						if {$filecnt > 1} { 
							set n 0
							foreach fnam $fnams {
								switch -- $n {
									0 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:7" 1] }
									1 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:3" 1] }
									2 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:1" 1] }
									3 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:8" 1] }
									4 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:2" 1] }
								}
								lappend lines $line
								incr n
							}
						} else {
							set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:7" 1 "2:3" 1 "3:1" 1 "4:8" 1 "5:2" 1]
							lappend lines $line
						}
					}
					54 {
						if {$filecnt > 1} { 
							set n 0
							foreach fnam $fnams {
								switch -- $n {
									0 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:7" 1] }
									1 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:8" 1] }
									2 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:1" 1] }
									3 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:2" 1] }
									4 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:3" 1] }
								}
								lappend lines $line
								incr n
							}
						} else {
							set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:7" 1 "2:8" 1 "3:1" 1 "4:2" 1 "5:3" 1]
							lappend lines $line
						}
					}
					71 {
						if {$filecnt > 1} { 
							set n 0
							foreach fnam $fnams {
								switch -- $n {
									0 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:1" 1] }
									1 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:8" 1] }
									2 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:2" 1] }
									3 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:7" 1] }
									4 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:3" 1] }
									5 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:6" 1] }
									6 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:4" 1] }
								}
								lappend lines $line
								incr n
							}
						} else {
							set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:1" 1 "2:8" 1 "3:2" 1 "4:7" 1 "5:3" 1 "6:6" 1 "7:4" 1]
							lappend lines $line
						}
					}
					72 {
						if {$filecnt > 1} { 
							set n 0
							foreach fnam $fnams {
								switch -- $n {
									0 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:8" 1] }
									1 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:2" 1] }
									2 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:7" 1] }
									3 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:3" 1] }
									4 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:6" 1] }
									5 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:4" 1] }
									6 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:1" 1] }
								}
								lappend lines $line
								incr n
							}
						} else {
							set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:8" 1 "2:2" 1 "3:7" 1 "4:3" 1 "5:6" 1 "6:4" 1 "7:1" 1]
							lappend lines $line
						}
					}
					73 {
						if {$filecnt > 1} { 
							set n 0
							foreach fnam $fnams {
								switch -- $n {
									0 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:6" 1] }
									1 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:7" 1] }
									2 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:8" 1] }
									3 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:1" 1] }
									4 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:2" 1] }
									5 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:3" 1] }
									6 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:4" 1] }
								}
								lappend lines $line
								incr n
							}
						} else {
							set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:6" 1 "2:7" 1 "3:8" 1 "4:1" 1 "5:2" 1 "6:3" 1 "7:4" 1]
							lappend lines $line
						}
					}
					80 {
						set n 0
						foreach fnam $fnams {
							switch -- $n {
								0 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:1" 1] }
								1 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:2" 1] }
								2 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:3" 1] }
								3 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:4" 1] }
								4 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:5" 1] }
								5 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:6" 1] }
								6 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:7" 1] }
								7 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:8" 1] }
							}
							lappend lines $line
							incr n
						}
					}
					81 {
						if {$filecnt > 1} { 
							set n 0
							foreach fnam $fnams {
								switch -- $n {
									0 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:1" 1] }
									1 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:2" 1] }
									2 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:8" 1] }
									3 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:3" 1] }
									4 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:7" 1] }
									5 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:4" 1] }
									6 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:6" 1] }
									7 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:5" 1] }
								}
								lappend lines $line
								incr n
							}
						} else {
							set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:1" 1 "2:2" 1 "3:8" 1 "4:3" 1 "5:7" 1 "6:4" 1 "7:6" 1 "8:5" 1]
							lappend lines $line
						}
					}
					82 {
						if {$filecnt > 1} { 
							set n 0
							foreach fnam $fnams {
								switch -- $n {
									0 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:8" 1] }
									1 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:2" 1] }
									2 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:7" 1] }
									3 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:3" 1] }
									4 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:6" 1] }
									5 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:4" 1] }
									6 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:1" 1] }
									7 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:5" 1] }
								}
								lappend lines $line
								incr n
							}
						} else {
							set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:8" 1 "2:2" 1 "3:7" 1 "4:3" 1 "5:6" 1 "6:4" 1 "7:1" 1 "8:5" 1]
							lappend lines $line
						}
					}
					83 {
						if {$filecnt > 1} { 
							set n 0
							foreach fnam $fnams {
								switch -- $n {
									0 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:8" 1] }
									1 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:2" 1] }
									2 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:1" 1] }
									3 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:5" 1] }
									4 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:7" 1] }
									5 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:3" 1] }
									6 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:6" 1] }
									7 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:4" 1] }
								}
								lappend lines $line
								incr n
							}
						} else {
							set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:8" 1 "2:2" 1  "3:1" 1 "4:5" 1 "5:7" 1 "6:3" 1 "7:6" 1 "8:4" 1]
							lappend lines $line
						}
					}
					84 {
						if {$filecnt > 1} { 
							set n 0
							foreach fnam $fnams {
								switch -- $n {
									0 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:8" 1] }
									1 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:2" 1] }
									2 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:1" 1] }
									3 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:5" 1] }
									4 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:6" 1] }
									5 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:4" 1] }
									6 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:7" 1] }
									7 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:3" 1] }
								}
								lappend lines $line
								incr n
							}
						} else {
							set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:8" 1 "2:2" 1  "3:1" 1 "4:5" 1 "5:6" 1 "6:4" 1 "7:7" 1 "8:3" 1]
							lappend lines $line
						}
					}
					85 {
						if {$filecnt > 1} { 
							set n 0
							foreach fnam $fnams {
								switch -- $n {
									0 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:1" 1] }
									1 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:5" 1] }
									2 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:2" 1] }
									3 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:8" 1] }
									4 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:3" 1] }
									5 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:7" 1] }
									6 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:4" 1] }
									7 {  set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:6" 1] }
								}
								lappend lines $line
								incr n
							}
						} else {
							set line [list $fnam 0 $pa($fnam,$evv(CHANS)) "1:1" 1 "2:5" 1  "3:2" 1 "4:8" 1 "5:3" 1 "6:7" 1 "7:4" 1 "8:6" 1]
							lappend lines $line
						}
					}
				}
				if [catch {open $mixfnam "w"} zit] {
					Inf "Cannot open temporary mixfile to write mix data"
					continue
				}
				foreach line $lines {
					puts $zit $line
				}
				close $zit
				Block "REFORMATTING"
				set OK 1
				while {$OK} {
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					catch {unset CDPidrun}
					set cmd	[file join $evv(CDPROGRAM_DIR) newmix]
					lappend cmd multichan $mixfnam $ofnam
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "Cannot run sound reformatting process: $CDPidrun"
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
						set msg "Failed to run sound reformatting process"
						set msg [AddSimpleMessages $msg]
						Inf $msg
						set OK 0
						break
					}
					if {![file exists $ofnam]} {
						set msg "Failed to generate reformated soundfile"
						set msg [AddSimpleMessages $msg]
						Inf $msg
						set OK 0
						break
					}
					break
				}
				if {!$OK} {
					UnBlock
					continue
				}
				if {[FileToWkspace $ofnam 0 0 0 0 1] > 0} {
					Inf "File $ofnam is on the workspace"
				}
				UnBlock
				set finished 1
			}
			0 {	
				set finished 1
			}
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}


proc FindCommonFilename {fnams}  {
	set gotname 1
	set filecnt [llength $fnams]
	set fnam [lindex $fnams 0]
	set rfm_nam [file rootname [file tail $fnam]]

	if {$filecnt == 1} {
		set rfm_n $rfm_nam 
	} else {
		set maxindex [string length $rfm_nam]
		incr maxindex -1

		;#	Look for common name before channel indexing in name-tail e.g. myname_c1 myname_c2 ...

		set man_mfr [ReverseString $rfm_nam]
		set j [string first "_" $man_mfr]	;#	Find last separator in name
		set k [string first "-" $man_mfr]
		set m [string first " " $man_mfr]
		if {$j > 0} {						;#	if there's a "_"
			set kk $j
			if {$k > 0} {					;#	if there's also a "-"	
				if {$k < $kk} {
					set kk $k
				}
			}
			if {$m > 0} {					;#	if there's also a " "
				if {$m < $kk} {
					set kk $m
				}
			}
		} elseif {$k > 0} {					;#	if there's a "-"
			set kk $k
			if {$m > 0} {					;#	if there's also a " "
				if {$m < $kk} {
					set kk $m
				}
			}
		} elseif {$m > 0} {					;#	if there's a " "
			set kk $m
		} else {							;#	if none
			set gotname 0
		}
		if {$gotname} {						;#		 01k3456 --> 0123j56	6 - k(2) = 4(j) required string
			set jj [expr $maxindex - $kk]	;#		"gfedcba"	"abcdefg"					"abcd" from 0 to 3(j-1)
			incr jj -1
			set rfm_n [string range $rfm_nam 0 $jj]
			foreach fnam [lrange $fnams 1 end] {
				set rfm_n2 [string range [file rootname [file tail $fnam]] 0 $jj]
				if {![string match $rfm_n $rfm_n2]} {
					set gotname 0
					break
				}
			}
		}
		if {!$gotname} {
			set gotname 1

		;#	Look for common name before name-tail indicating which channel it is e.g. myname_front_l myname_front_r myname_rear_l ...

			set j [string first "_" $rfm_nam]	;#	Find last separator in name
			set k [string first "-" $rfm_nam]
			set m [string first " " $rfm_nam]
			if {$j > 0} {						;#	if there's a "_"
				set kk $j
				if {$k > 0} {					;#	if there's also a "-"	
					if {$k < $kk} {
						set kk $k
					}
				}
				if {$m > 0} {					;#	if there's also a " "
					if {$m < $kk} {
						set kk $m
					}
				}
			} elseif {$k > 0} {					;#	if there's a "-"
				set kk $k
				if {$m > 0} {					;#	if there's also a " "
					if {$m < $kk} {
						set kk $m
					}
				}
			} elseif {$m > 0} {					;#	if there's a " "
				set kk $m
			} else {							;#	if none
				set gotname 0
			}
			if {$gotname} {
				incr kk -1
				set rfm_n [string range $rfm_nam 0 $kk]
				foreach fnam [lrange $fnams 1 end] {
					set rfm_n2 [string range [file rootname [file tail $fnam]] 0 $kk]
					if {![string match $rfm_n $rfm_n2]} {
						set gotname 0
						break
					}
				}
			}
		}
	}
	if {$gotname} {
		append rfm_n "_refmt"
		return $rfm_n
	}
	return ""
}
