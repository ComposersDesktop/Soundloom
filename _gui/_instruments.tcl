#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD 30 June 2013
# ... fixup button rectangles

#########################################################
# ESTABLISHING PROPERTIES OF GADGETS FOR INSTRUMENTS	#
#########################################################

#------ Get the descriptions of gadgets for an ins

proc GetInsGadgets {} {
	global pg_spec cmd_line ins zero_props prps norange_gdg dur_known evv
	global badparamspec params_got param_spec CDPid ins_ref
	
	set gcnt 0
	set propno 0

	while {$propno < $evv(CDP_FIRSTPASS_ITEMS)} {		
		lappend zero_props 0							
		incr propno
	}
	lappend zero_props 0								;#	1 extra prop used = decimation factor
	lappend zero_props 0								;#	1 extra prop used = origchans
	catch {unset pg_spec}

	#	MAKE A LIST OF SETS-OF-FILEPROPS (1 set for each 1st-infile, each outfile etc. as needed)

	set thisprocess 0
	set total_processes [llength $ins(cmdset)]
	foreach cmd_line $ins(cmdset) {
		set this_prog [lindex $cmd_line $evv(CMD_PROCESSNO)]
		set this_mode [lindex $cmd_line $evv(CMD_MODENO)]
		set pos $evv(CMD_INFILECNT)
		set infilecnt [lindex $cmd_line $pos]
		incr pos														;#	Machien processes MUST have infiles
		set firstfilename [file rootname [lindex $cmd_line $pos]]		;#	Find name of first infile

		#	FOR INFILES, PROPS CAN BE DEFINITELY KNOWN

		if [string match $evv(INFIL_MARK)* $firstfilename] {		
			set prps($firstfilename) [ConstructInfilePropsSet $firstfilename $thisprocess]
			if {[llength $prps($firstfilename)] <= 0} {
				return 0
			}
			set dur_known($firstfilename) 1
		} else {

		#	FOR RECYCLED FILES, PROPS CAN BE DEDUCED EXACTLY OR INCOMPLETELY (flagged)

			if {$thisprocess == 0} {
				Inf "Recycled file appears to be input to 1st process : Impossible"
				return 0
			}
			set origin_process $thisprocess
			incr origin_process -1

			#	SEARCH BACK THROUGH PREVIOUS PROCESSES FOR FILE ORIGIN

			while {$origin_process >= 0} {
#AUG 15!!
				set indx [string first "_" [string range $firstfilename 1 end]]
				incr indx

				set srchname [string range $firstfilename 0 $indx]
				set prev_cmd_line [lindex $ins(cmdset) $origin_process]
				set prev_prog [lindex $prev_cmd_line $evv(CMD_PROCESSNO)]
				set prev_mode [lindex $prev_cmd_line $evv(CMD_MODENO)]
				set prev_pos  $evv(CMD_INFILECNT)
				set prev_infilecnt [lindex $prev_cmd_line $prev_pos]
				incr prev_pos
				incr prev_pos $prev_infilecnt
				set outname [lindex $prev_cmd_line $prev_pos]
#AUG 15!!
				set indx [string first "_" [string range $outname 1 end]]

				incr indx 
				set outname [string range $outname 0 $indx]
				if [string match $outname $srchname] {
					break
				}
				incr origin_process -1
			}
			if {$origin_process < 0} {
				Inf "Failed to find origin of recycled file '$firstfilename'"
				return 0
			}
			set prps($firstfilename) $prps(##$origin_process)
			set dur_known($firstfilename) $dur_known(##$origin_process)

			CheckForGetpitchCase $firstfilename $origin_process $this_prog $this_mode $prev_prog $prev_mode
		}				
		if [ProcessOutputIsUsedLater $pos $infilecnt $thisprocess $total_processes] {
			if {![PredictTheOutputPropArray $thisprocess $firstfilename $pos $this_prog $this_mode $cmd_line]} {
				return 0
			}
		}
		incr thisprocess
	}

	#	USE cdparams TO CALCULATE THE GADGET-SPECIFICATIONS FOR EACH INSTRUMENT GADGETS

	catch {unset ins_ref}
 	foreach line $ins(gadgets) {
		catch {unset param_spec}
		set badparamspec 0
		set params_got 0
		set thisprocess [lindex $line 0]
		set these_gdgs [lrange $line 1 end]
		set thisprocess_gdgcnt [llength $these_gdgs]
		set cmd_line [lindex $ins(cmdset) $thisprocess]
		set this_prog [lindex $cmd_line $evv(CMD_PROCESSNO)]
		set this_mode [lindex $cmd_line $evv(CMD_MODENO)]
		set thisref [list $this_prog $this_mode]
		set pos $evv(CMD_INFILECNT)
		set infilecnt [lindex $cmd_line $pos]
		incr pos
		set thisfilename [file rootname [lindex $cmd_line $pos]]
																		;#	Drop the extra params
		set this_props_set [lrange $prps($thisfilename) 0 $evv(CDP_FIRSTPASS_ENDINDEX)]	

		#	RUN CDPARAMS FOR THE RELEVANT PROCESS

		if {[IsReleaseFiveProg $this_prog]} {
			set cdparams_cmd [file join $evv(CDPROGRAM_DIR) cdparams]
		} elseif {![ProgMissing [file join $evv(CDPROGRAM_DIR) cdparams_other] "\nThe program is needed to run this instrument on the Sound Loom."]} {
			set cdparams_cmd [file join $evv(CDPROGRAM_DIR) cdparams_other]
		} else {
			return 0
		}
		set cdparams_cmd [concat $cdparams_cmd $this_prog $this_mode $infilecnt $this_props_set]	

		if [catch {open "|$cdparams_cmd"} CDPid] {
			ErrShow "Failed to run cdparams"
			catch {unset CDPid}
			return 0										
		} else {										
	   		fileevent $CDPid readable AccumulateParameterSpecs
			fconfigure $CDPid -buffering line
		}												
		vwait params_got

		if {$badparamspec} {
			incr thisprocess
			ErrShow "Bad parameter specification for process $thisprocess"
			return 0									
		}

		if {![info exists param_spec] || ([llength $param_spec] <= $thisprocess_gdgcnt)} {
			incr thisprocess
			ErrShow "Insufficient data returned from 'cdparams' for process $thisprocess"
			return 0
		}

		set pgs_len [llength $param_spec]
		set bdf_param [lindex $param_spec 0]
		if {[llength $bdf_param] < 0} {
			incr thisprocess
			ErrShow "No brkdurflag returned from Cdparams for process $thisprocess"
			return 0
		}
										;#	ins(run) assumes brkdurflag is not set (simpler!!)

		set param_spec [lrange $param_spec 1 end]

		#	SUBSTITUTE THE EXTENDED NAMES IN THE GADGETS ACTUALLY USED BY INSTRUMENT

		foreach thisgadget $these_gdgs {
			set	g_no [lindex $thisgadget 0]
			set	gdg_newname [lindex $thisgadget 1]
			if {$g_no >= [llength $param_spec]} {
				Inf "Instrument is looking for a gadget that does not exist"
				return 0
			}
			set orig_gdg [lindex $param_spec $g_no]
			set new_gdg [lreplace $orig_gdg 1 1 $gdg_newname]
			if {!$dur_known($thisfilename) && [IsDurationDependentGadget $this_prog $this_mode $g_no]} {
				set norange_gdg($gcnt) 1
				set gtype [lindex $new_gdg 0]
				switch -- $gtype {
					SWITCHED {set thislo [lindex $new_gdg 5]}
					NUMERIC -
					LINEAR -
					LOG -
					PLOG -
					FILENAME -
					FILE_OR_VAL {
						set thislo [lindex $new_gdg 3]
					}
					default {
						ErrShow "Invalid gadget '$gtype' to set as unranged"
						return 0
					}
				}
				set uprval [EstablishUpperRangeLimit $gcnt $gdg_newname $thislo]
				switch -- $gtype {
					SWITCHED {set new_gdg [lreplace $new_gdg 6 6 $uprval]}
					NUMERIC -
					LINEAR -
					LOG -
					PLOG -
					FILENAME -
					FILE_OR_VAL {set new_gdg [lreplace $new_gdg 4 4 $uprval]}
				}
			} else {
				set norange_gdg($gcnt) 0
			}
			if {$this_mode > 0} {
				incr this_mode -1
			}
			if [InsertSampValConverters $new_gdg $this_prog $this_mode] {
				lappend new_gdg "sg"
			}
			lappend pg_spec $new_gdg
			lappend ins_ref $thisref
			incr gcnt
		}
	}
	return 1
}

#------ Set up upper range limit for parameter with unknown upper range limit

proc EstablishUpperRangeLimit {gcnt name thislo} {
	global pr_rangesize uprval actvhi evv

	set f .rangesize

	if [Dlg_Create $f "Parameter Value Range" "set pr_rangesize 0" -borderwidth $evv(BBDR) -bg $evv(EMPH)] {

		set fl1 [frame $f.titl  -borderwidth $evv(SBDR)]		;#	frame for buttons
		set fn  [frame $f.name  -borderwidth $evv(SBDR)]		;#	frame for list

		label  $fl1.title -text "Please estimate an upper limit for the value of"
		label  $fl1.para  -text "" -width 40
		label  $fl1.foot  -text "" -width 40
		entry  $fn.name -textvariable uprval -width 20
		button $fn.ok   -text "OK"   -command "set pr_rangesize 0" -bg $evv(EMPH) -highlightbackground [option get . background {}]
		pack $fn.name -side left
		pack $fn.ok   -side right
		pack $fl1.title $fl1.para $fl1.foot -side top
		pack $f.titl $f.name -side top
		bind $fn.name <Return> "set pr_rangesize 0"
		bind $fn.name <Escape> "set pr_rangesize 0"
		bind $fn.name <Key-space> "set pr_rangesize 0"
	}
	wm resizable $f 1 1
	wm protocol $f WM_DELETE_WINDOW

	ScreenCentre $f

	set name [string trim $name]
	set name [string toupper $name]
	set name [split $name "_"]
	.rangesize.titl.para config -text "$name"
	.rangesize.titl.foot config -text "above $thislo"
	set	pr_rangesize 0
	set finished 0
	raise $f
	My_Grab 0 $f pr_rangesize $f.name.name

	while {!$finished} {
		tkwait variable pr_rangesize
		set uprval [FixTxt $uprval "rangesize"]
		if {([string length $uprval] > 0) && [IsNumeric $uprval]} {
			if {$uprval <= $thislo} {
				Inf "Out of Range"
				ForceVal .rangesize.name.name ""
			} else {				
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $uprval
}

#------ Check if current process output is used as input later

proc ProcessOutputIsUsedLater {pos infilecnt thisprocess total_processes} {
	global cmd_line ins evv
	incr pos $infilecnt
	set outname [lindex $cmd_line $pos] 					;#	Get outputfilename
	set indx [string first "_" $outname]
	set outname [string range $outname 0 $indx]
	set nextprocess $thisprocess
	incr nextprocess										;#	Search subsequent processes
	while {$nextprocess < $total_processes} {
		set later_cmd_line [lindex $ins(cmdset) $nextprocess]
		set later_pos $evv(CMD_INFILECNT)
		set later_infilecnt [lindex $cmd_line $later_pos]
		incr later_pos
		set infilesend $later_pos
		incr infilesend $later_infilecnt
		while {$later_pos < $infilesend} {
			set laterfilename [file rootname [lindex $later_cmd_line $later_pos]]
			set indx [string first "_" $laterfilename]
			set srchname [string range $laterfilename 0 $indx]
			if [string match $srchname $outname] {
				return 1
			}
			incr later_pos
		}
		incr nextprocess
	}
	return 0
}

#------ Check if current process is using a pitchdata file which was GENERATED in previous process

proc CheckForGetpitchCase {firstfilename origin_process this_prog this_mode prev_prog prev_mode} {
	global zero_props prps evv
	
	set uses_pitchdata 0	

	if {$this_mode > 0} {
		incr this_mode -1
	}

	#	LOOK FOR PROGRAMS USING PITCHFILE INPUT

	switch -regexp -- $this_prog \
		^$evv(ONEFORM_COMBINE)$	- \
		^$evv(MAKE)$ 		- \
		^$evv(P_EXAG)$ 		- \
		^$evv(P_INVERT)$ 	- \
		^$evv(P_QUANTISE)$ 	- \
		^$evv(P_RANDOMISE)$ - \
		^$evv(P_SMOOTH)$ 	- \
		^$evv(P_TRANSPOSE)$ - \
		^$evv(P_VIBRATO)$ 	- \
		^$evv(P_CUT)$ 		- \
		^$evv(P_FIX)$ 		- \
		^$evv(P_INFO)$ 		- \
		^$evv(P_ZEROS)$ 	- \
		^$evv(P_SEE)$ 		- \
		^$evv(P_HEAR)$ 		- \
		^$evv(P_WRITE)$ {
			set uses_pitchdata 1
		} \
		^$evv(REPITCH)$ 	- \
		^$evv(REPITCHB)$ {
			if {$this_mode == $evv(PPT) || $this_mode == $evv(PTP)} {
				set uses_pitchdata 1
			}
		}

	#	CHECK IF SOURCE PROGRAM GENERATED THIS PITCH DATA FROM AN ANALFILE

	if {$uses_pitchdata && ($prev_prog == $evv(PITCH))} {
		set outprps $prps($firstfilename)
		incr prev_mode -1
		if {$prev_mode == $evv(PICH_TO_BIN)} {
			set insams [lindex $outprps $evv(WLENGTH)]
			set filesize $insams
			set outprps [lreplace $outprps $evv(INSAMS)   $evv(INSAMS)   $insams]
			set outprps [lreplace $outprps $evv(FSIZ) $evv(FSIZ) $filesize]
			set outprps [lreplace $outprps $evv(CHANS) $evv(CHANS) 1]
			set prps($firstfilename) $outprps
		} else {
			set duration [lindex $outprps $evv(DUR)]
			set outprps $zero_props
			set outprps [lreplace $outprps $evv(FTYP) $evv(FTYP) $evv(TR_OR_PB_OR_N_OR_W)]
			set outprps [lreplace $outprps $evv(LINECNT)  $evv(LINECNT)  $evv(DEFAULT_LINECNT)]
			set prps($firstfilename) $outprps
			set dur_known($firstfilename) 0		;#	We don't know the linecnt
		}
	}
}

#------ Construct a (short) properties set for an infle, to use to define gadget ranges

proc ConstructInfilePropsSet {coded_filename thisprocess} {
	global chlist pa evv insuff_warned

	incr thisprocess
	set coded_filename [file rootname $coded_filename]
	set fileno [string range $coded_filename 1 end]			;#	Find infileno, embedded in coded_name
	if {![info exists chlist] || ($fileno >= [llength $chlist])} {
		if {[info exists insuff_warned]} {
			ErrShow "Insufficient files for process $thisprocess"
			unset insuff_warned
		} else {
			ErrShow "Possibly insufficient files for process $thisprocess: Run instrument again"
			set insuff_warned 1
		}
		return ""
	}
	set realname [lindex $chlist $fileno]				;#	Get actual current-input file
	if {![info exists pa($realname,0)]} {
		Inf "Failed to find data on input file '$realname'"
		return ""
	}
	set propno 0
	while {$propno < $evv(CDP_FIRSTPASS_ITEMS)} {			;#	Get props of first input file needed by cdparams
		lappend outprps $pa($realname,$propno)
		incr propno
	}
	lappend outprps $pa($realname,$evv(DFAC))			;#	Plus the 'dfac' property
	lappend outprps $pa($realname,$evv(ORIGCHANS))	;#	Plus the 'origchans' property
	return $outprps
}

#------ Predict the properties of an outfile using two infile spectra

proc PredictOutputOfTwoSpecProcess {pos thisprocess firstfilename this_prog} {
	global prps dur_known cmd_line evv

	set outprps $prps($firstfilename)
	incr pos				
	set otherfilename [lindex $cmd_line $pos]	   			;#	Find name of 2nd infile

	if {![info exists dur_known($otherfilename)]} {	;#	If the dur_known flag of other file
		set dur_known($otherfilename) 1				;#	doesn't exist, it must be an INPUT file
	}														;#	we've not yet checked out, & hence duration is known

	if {!$dur_known($firstfilename) || !$dur_known($otherfilename)} {
		set dur_known(##$thisprocess) 0
		return [FixDefaultSpecDuration {$thisprocess}]
	}

	if {![info exists prps($otherfilename)]} {			;#	If output of previous process, its props-set exists,
															;#	else it's an infile and its pa must exist
		set prps($otherfilename) [ConstructInfilePropsSet $otherfilename $thisprocess]
		if {[llength prps($otherfilename)] <= 0} {
			return ""
		}
	}
	set thisfilesize  [lindex prps($firstfilename) $evv(FSIZ)]
	set otherfilesize [lindex prps($otherfilename) $evv(FSIZ)]
	if {($this_prog == $evv(SUM)) || ($this_prog == $evv(MAX)) \
	||  ($this_prog == $evv(ONEFORM_PUT)) || ($this_prog == $evv(ONEFORM_COMBINE))} {
		if {$thisfilesize < $otherfilesize} {
			set outprps [lreplace $outprps $evv(FSIZ) $evv(FSIZ) $otherfilesize]
			set outprps [lreplace $outprps $evv(INSAMS) $evv(INSAMS) \
				[lindex $prps($otherfilename) $evv(INSAMS) ]]
			set outprps [lreplace $outprps $evv(WLENGTH) $evv(WLENGTH) \
				[lindex $prps($otherfilename) $evv(WLENGTH)]]
			set outprps [lreplace $outprps $evv(DUR) $evv(DUR) \
				[lindex $prps($otherfilename) $evv(DUR)]]
		}						
	} elseif {$thisfilesize > $otherfilesize} {
		set outprps [lreplace $outprps $evv(FSIZ) $evv(FSIZ) $otherfilesize]
		set outprps [lreplace $outprps $evv(INSAMS) $evv(INSAMS) \
			[lindex $prps($otherfilename) $evv(INSAMS) ]]
		set outprps [lreplace $outprps $evv(WLENGTH) $evv(WLENGTH) \
			[lindex $prps($otherfilename) $evv(WLENGTH)]]
		set outprps [lreplace $outprps $evv(DUR) $evv(DUR) \
			[lindex $prps($otherfilename) $evv(DUR)]]
	}						
	return $outprps
}

#------ Predict the properties of an outfile using two infile spectra

proc PredictOutputOfTwoPTProcess {pos thisprocess firstfilename this_prog} {
	global prps cmd_line dur_known evv

	set outprps $prps($firstfilename)
	incr pos				
	set otherfilename [lindex $cmd_line $pos]	   			;#	Find name of 2nd infile

	if {![info exists dur_known($otherfilename)]} {	;#	If the dur_known flag of other file
		set dur_known($otherfilename) 1				;#	doesn't exist, it must be an INPUT file
	}														;#	we've not yet checked out, & hence duration is known

	if {!$dur_known($firstfilename) || !$dur_known($otherfilename)} {
		set dur_known(##$thisprocess) 0
		if {$this_prog == $evv(REPITCHB)} {
			set outprps $zero_props
			set outprps [lreplace $outprps $evv(FTYP) $evv(FTYP) $evv(TR_OR_PB_OR_N_OR_W)]
			set outprps [lreplace $prps(##$thisprocess) $evv(LINECNT)  $evv(LINECNT)  $evv(DEFAULT_LINECNT)]
			set outprps [lreplace $prps(##$thisprocess) $evv(DUR) $evv(DUR) $evv(DEFAULT_DUR)]
		} else {
			return [FixDefaultSpecDuration {$thisprocess}]
		}
	}

	if {![info exists prps($otherfilename)]} {			;#	If output of previous process, its props-set exists,
															;#	else it's an infile and its pa must exist
		set prps($otherfilename) [ConstructInfilePropsSet $otherfilename $thisprocess]
		if {[llength prps($otherfilename)] <= 0} {
			return ""
		}
	}
	set thisfiledur  [lindex prps($firstfilename) $evv(DUR)]
	set otherfiledur [lindex prps($otherfilename) $evv(DUR)]
	if {$thisfiledur > $otherfiledur} {
		if {$this_prog == $evv(REPITCHB)} {
			set outprps [lreplace $outprps $evv(FTYP) $evv(FTYP) $evv(TR_OR_PB_OR_N_OR_W)]
			set outprps [lreplace $prps(##$thisprocess) $evv(LINECNT)  $evv(LINECNT) $evv(DEFAULT_LINECNT)]
			set outprps [lreplace $outprps $evv(DUR) $evv(DUR) \
				[lindex $props_sets($otherfilename) $evv(DUR)]]
			set dur_known(##$thisprocess) 0	;#	Linecnt is not known
		} else {
			set outprps [lreplace $outprps $evv(FSIZ) $evv(FSIZ) $otherfilesize]
			set outprps [lreplace $outprps $evv(INSAMS) $evv(INSAMS) \
				[lindex $props_sets($otherfilename) $evv(INSAMS)]]
			set outprps [lreplace $outprps $evv(WLENGTH) $evv(WLENGTH) \
				[lindex $props_sets($otherfilename) $evv(WLENGTH)]]
			set outprps [lreplace $outprps $evv(DUR) $evv(DUR) \
				[lindex $props_sets($otherfilename) $evv(DUR)]]
		} 
	}						
	return $outprps
}

#------ Deduce the properties of outfiles from those of infiles, as far as is possible

proc PredictTheOutputPropArray {thisprocess firstfilename pos this_prog this_mode cmd_line} {
	global dur_known prps zero_props chlist evv

	#	DEFAULTS								

	if {$this_mode > 0} {
		incr this_mode -1
	}

	set prps(##$thisprocess) $prps($firstfilename)
	set dur_known(##$thisprocess) $dur_known($firstfilename)

	#	PROCESSES THAT (MAY) ALTER THE NUMBER OF CHANNELS IN THE OUTPUT

	switch -regexp -- $this_prog \
		^$evv(BRASSAGE)$ - \
		^$evv(SAUSAGE)$  {
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(CHANS) $evv(CHANS) 2]
		} \
		^$evv(WRAPPAGE)$  {
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(CHANS) $evv(CHANS) [lindex $cmd_line [expr 3 + [llength $chlist]]]
		} \
		^$evv(HOUSE_CHANS)$ {
			if {$this_mode == $evv(HOUSE_CHANNEL) || $this_mode == $evv(HOUSE_CHANNELS) || $this_mode == $evv(STOM)} {
				set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(CHANS) $evv(CHANS) 1]
			} elseif {$this_mode == $evv(MTOS)} {
				set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(CHANS) $evv(CHANS) 2]
			}
		} \
		^$evv(MTON)$ {
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(CHANS) $evv(CHANS) [lindex $cmd_line 4]]
		} \
		^$evv(MOD_SPACE)$ {
			if {$this_mode == $evv(MOD_PAN)} {
				set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(CHANS) $evv(CHANS) 2]
			}
		} \
		^$evv(PSOW_SPACE)$ {
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(CHANS) $evv(CHANS) 2]
		} \
		^$evv(SCALED_PAN)$ {
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(CHANS) $evv(CHANS) 2]
		} \
		^$evv(MCHANPAN)$ {
			switch -- $this_mode {
				8 -
				9 -
				2 {
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(CHANS) $evv(CHANS) [lindex $cmd_line 5]]
				}
				6 {
					;#
				}
				default {
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(CHANS) $evv(CHANS) [lindex $cmd_line 6]]
				}
			}
		} \
		^$evv(MCHSHRED)$ {
			switch -- $this_mode {
				0 {
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(CHANS) $evv(CHANS) [lindex $cmd_line 8]]
				}
				default {
					;#
				}
			}
		} \
		^$evv(MCHZIG)$ {
			switch -- $this_mode {
				0 {
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(CHANS) $evv(CHANS) [lindex $cmd_line 9]]
				}
				1 {
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(CHANS) $evv(CHANS) [lindex $cmd_line 6]]
				}
			}
		} \
		^$evv(MCHITER)$ {
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(CHANS) $evv(CHANS) [lindex $cmd_line 5]]
		} \
		^$evv(MCHANREV)$ {
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(CHANS) $evv(CHANS) [lindex $cmd_line 8]]
		}

	#	IF THE INPUT DURATION IS UNKNOWN, ONLY DO SOME PREDICTION

	if {!$dur_known(##$thisprocess)} {
		if {$this_prog < $evv(FOOT_OF_GROUCHO_PROCESSES)} {

	#	PROCESSES WHICH ALTER OUTFILE TYPE

			switch -regexp -- $this_prog \
				^$evv(FORMANTS)$ {
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(FORMANTFILE)]
				} \
				^$evv(P_HEAR)$ - \
				^$evv(MAKE)$ {
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(ANALFILE)]
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(CHANS) $evv(CHANS) \
						[lindex $prps(##$thisprocess) $evv(THIS_ORIGCHANS)]]
				} \
				^$evv(PITCH)$ {
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(PITCHFILE)]
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(CHANS) $evv(CHANS) 1]
				} \
				^$evv(REPITCH)$ {
					if {$this_mode == $evv(PPT)} {
						set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(TRANSPOSFILE)]
					}
	#	PROCESSES WHICH GENERATE TEXT OUTPUT
				} \
				^$evv(REPITCHB)$ {			
					set dur_known(##$thisprocess) 0
					set	prps(##$thisprocess) $zero_props
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(TR_OR_PB_OR_N_OR_W)]
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(LINECNT)  $evv(LINECNT)  $evv(DEFAULT_LINECNT)]
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(DUR) $evv(DUR) $evv(DEFAULT_DUR)]
					return 1
				}

		} else {

	#	PROCESSES WHICH ALTER OUTFILE TYPE

			switch -regexp -- $this_prog \
				^$evv(ONEFORM_GET)$ {
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(FORMANTFILE)]
				} \
				^$evv(ONEFORM_COMBINE)$	{
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(ANALFILE)]
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(CHANS) $evv(CHANS) \
						[lindex $prps(##$thisprocess) $evv(THIS_ORIGCHANS)]]
	#	PROCESSES WHICH GENERATE TEXT OUTPUT
				} \
				^$evv(SETHARES)$ {
					set dur_known(##$thisprocess) 0
					set	prps(##$thisprocess) $zero_props
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(TR_OR_PB_OR_N_OR_W)]
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(LINECNT)  $evv(LINECNT)  $evv(DEFAULT_LINECNT)]
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(DUR) $evv(DUR) $evv(DEFAULT_DUR)]
					return 1
				} \
				^$evv(MIXSYNC)$	   	 - \
				^$evv(MIXSYNCATT)$ 	 - \
				^$evv(PANORAMA)$  	 - \
				^$evv(TAN_ONE)$  	 - \
				^$evv(TAN_TWO)$  	 - \
				^$evv(TAN_SEQ)$  	 - \
				^$evv(TAN_LIST)$ 	 - \
				^$evv(TRANSIT)$ 	 - \
				^$evv(TRANSITF)$ 	 - \
				^$evv(TRANSITD)$ 	 - \
				^$evv(TRANSITFD)$ 	 - \
				^$evv(TRANSITS)$ 	 - \
				^$evv(TRANSITL)$ {
					set dur_known(##$thisprocess) 0
					set	prps(##$thisprocess) $zero_props
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(MIXFILE)]
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(LINECNT)  $evv(LINECNT)  $evv(DEFAULT_LINECNT)]
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(DUR) $evv(DUR) $evv(DEFAULT_DUR)]
					return 1
				} \
				^$evv(HOUSE_BUNDLE)$ {
					set dur_known(##$thisprocess) 0
					set	prps(##$thisprocess) $zero_props
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(LINELIST)]
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(LINECNT)  $evv(LINECNT)  $evv(DEFAULT_LINECNT)]
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(DUR) $evv(DUR) $evv(DEFAULT_DUR)]
					return 1
				} \
				^$evv(GRAIN_GET)$ {
					set dur_known(##$thisprocess) 0
					set	prps(##$thisprocess) $zero_props
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(NUMLIST)]
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(LINECNT)  $evv(LINECNT)  $evv(DEFAULT_LINECNT)]
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(DUR) $evv(DUR) $evv(DEFAULT_DUR)]
					return 1
				} \
				^$evv(PARTIALS_HARM)$ {
					set dur_known(##$thisprocess) 0
					set	prps(##$thisprocess) $zero_props
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(NUMLIST)]
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(LINECNT)  $evv(LINECNT)  $evv(DEFAULT_LINECNT)]
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(DUR) $evv(DUR) $evv(DEFAULT_DUR)]
				} \
				^$evv(ENV_EXTRACT)$ {
				 	if {$this_mode == $evv(ENV_BRKFILE_OUT)} {
						set dur_known(##$thisprocess) 0
						set	prps(##$thisprocess) $zero_props
						set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(NBK_OR_N_OR_WL)]
						set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(LINECNT)  $evv(LINECNT)  $evv(DEFAULT_LINECNT)]
						set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(DUR) $evv(DUR) $evv(DEFAULT_DUR)]
						return 1
					} else {
						set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(ENVFILE)]
						#	the srate etc of env files never needed in predicting property ranges
					}
				} \
				^$evv(RMRESP)$ {
					set dur_known(##$thisprocess) 0
					set	prps(##$thisprocess) $zero_props
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(NUMLIST)]
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(LINECNT)  $evv(LINECNT)  $evv(DEFAULT_LINECNT)]
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(DUR) $evv(DUR) $evv(DEFAULT_DUR)]
				} \
				^$evv(PEAKFIND)$ {
					set dur_known(##$thisprocess) 0
					set	prps(##$thisprocess) $zero_props
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(NUMLIST)]
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(LINECNT)  $evv(LINECNT)  $evv(DEFAULT_LINECNT)]
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(DUR) $evv(DUR) $evv(DEFAULT_DUR)]
				} \
				^$evv(SHRINK)$ {
					if {$this_mode >= $evv(SHRM_FINDMX)} {
						set dur_known(##$thisprocess) 0
						set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(MIXFILE)]
						set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(LINECNT)  $evv(LINECNT)  $evv(DEFAULT_LINECNT)]
						set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(DUR) $evv(DUR) $evv(DEFAULT_DUR)]
					}
				} \
				^$evv(STRANDS)$ {
					if {$this_mode == 0} {
						set dur_known(##$thisprocess) 0
						set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(BRKFILE)]
						set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(LINECNT)  $evv(LINECNT)  $evv(DEFAULT_LINECNT)]
						set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(DUR) $evv(DUR) $evv(DEFAULT_DUR)]
					}

	#	PROCESSES WHICH ALTER OUTFILE TYPE RADICALLY
 				} \
				^$evv(PVOC_ANAL)$ {
					if {![GeneratePvocAnalOutprops $thisprocess]} {
						return 0
					}
				} \
				^$evv(PVOC_SYNTH)$ {
					GeneratePvocSynthOutprops $thisprocess
				}
		}
		return 1				
	}

	#	OTHERWISE, THE INPUT DURATION IS KNOWN: TRY TO CALCULATE THE OUTPUT PARAMETERS

	# SPEC PROCESSES WHICH ALTER LENGTH

	switch -regexp -- $this_prog \
		^$evv(CUT)$ 	 - \
		^$evv(GRAB)$ 	 - \
		^$evv(MAGNIFY)$	 - \
		^$evv(TSTRETCH)$ - \
		^$evv(FREEZE2)$	 - \
		^$evv(DRUNK)$	 - \
		^$evv(SHUFFLE)$	 - \
		^$evv(WEAVE)$	 - \
		^$evv(WARP)$	 - \
		^$evv(GLIDE)$	 - \
		^$evv(BRIDGE)$	 - \
		^$evv(MORPH)$	 - \
		^$evv(P_APPROX)$ - \
		^$evv(P_CUT)$	 - \
		^$evv(ANALJOIN)$ - \
		^$evv(SPECROSS)$ - \
		^$evv(LUCIER_GET)$ - \
		^$evv(LUCIER_PUT)$ - \
		^$evv(LUCIER_DEL)$ {
			set dur_known(##$thisprocess) 0
			FixDefaultSpecDuration	$thisprocess

	# SPEC PROCESSES TAKING MIN OR MAX
		} \
		^$evv(SPECMORPH)$ {
			if {$this_mode < 4} {
				set dur_known(##$thisprocess) 0
				FixDefaultSpecDuration	$thisprocess
			}
		} \
		^$evv(SUM)$		- \
		^$evv(MAX)$		- \
		^$evv(MEAN)$	- \
		^$evv(CROSS)$	- \
		^$evv(FORM)$	- \
		^$evv(ONEFORM_PUT)$	- \
		^$evv(ONEFORM_COMBINE)$	- \
		^$evv(VOCODE)$	- \
		^$evv(SPECENV)$ - \
		^$evv(MAKE)$ - \
		^$evv(SPECTWIN)$ - \
		^$evv(SPECSPHINX)$ {
			set	prps(##$thisprocess) \
				[PredictOutputOfTwoSpecProcess $pos $thisprocess $firstfilename $this_prog]
			if {($this_prog == $evv(MAKE)) || ($this_prog == $evv(ONEFORM_COMBINE))} {
				set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(ANALFILE)]
				set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(CHANS) $evv(CHANS) [lindex $prps(##$thisprocess) $evv(THIS_ORIGCHANS)]]
			}
			if {[llength $prps(##$thisprocess)] <= 0} {
				return 0
			}
		} \
		^$evv(REPITCH)$	- \
		^$evv(REPITCHB)$ {
			set	prps(##$thisprocess) [PredictOutputOfTwoPTProcess $pos $thisprocess $firstfilename $this_prog]
			if {[llength $prps(##$thisprocess)] <= 0} {
				return 0
			}

	# GROUCHO PROCESSES WHICH ALTER LENGTH

		} \
		^$evv(NOISE_SUPRESS)$	- \
		^$evv(SEQUENCER)$		- \
		^$evv(SEQUENCER2)$		- \
		^$evv(CONVOLVE)$		- \
		^$evv(BAKTOBAK)$		- \
		^$evv(DISTORT_AVG)$		- \
		^$evv(DISTORT_MLT)$		- \
		^$evv(DISTORT_DIV)$		- \
		^$evv(DISTORT_HRM)$		- \
		^$evv(DISTORT_FRC)$		- \
		^$evv(DISTORT_REV)$		- \
		^$evv(DISTORT_SHUF)$	- \
		^$evv(DISTORT_RPT)$		- \
		^$evv(DISTREP)$			- \
		^$evv(DISTORT_RPT2)$	- \
		^$evv(DISTORT_RPTFL)$	- \
		^$evv(DISTORT_INTP)$	- \
		^$evv(DISTORT_DEL)$		- \
		^$evv(DISTORT_RPL)$		- \
		^$evv(DISTORT_TEL)$		- \
		^$evv(DISTORT_FLT)$		- \
		^$evv(DISTORT_INT)$		- \
		^$evv(DISTORT_PCH)$		- \
		^$evv(DISTORT_PULSED)$	- \
		^$evv(ZIGZAG)$			- \
		^$evv(LOOP)$			- \
		^$evv(SCRAMBLE)$		- \
		^$evv(ITERATE)$			- \
		^$evv(ITERLINE)$		- \
		^$evv(ITERLINEF)$		- \
		^$evv(ITERATE_EXTEND)$	- \
		^$evv(DRUNKWALK)$		- \
		^$evv(GRAIN_OMIT)$		- \
		^$evv(GRAIN_DUPLICATE)$	- \
		^$evv(PSOW_DUPL)$		- \
		^$evv(PSOW_DEL)$		- \
		^$evv(GRAIN_REORDER)$	- \
		^$evv(GRAIN_REPITCH)$	- \
		^$evv(GRAIN_RERHYTHM)$	- \
		^$evv(GRAIN_REMOTIF)$	- \
		^$evv(GRAIN_TIMEWARP)$	- \
		^$evv(GRAIN_REVERSE)$	- \
		^$evv(GRAIN_POSITION)$	- \
		^$evv(GRAIN_ALIGN)$		- \
		^$evv(ENV_CURTAILING)$	- \
		^$evv(EXPDECAY)$		- \
		^$evv(PEAKCHOP)$		- \
		^$evv(ENV_PLUCK)$		- \
		^$evv(MIX)$				- \
		^$evv(MIXMULTI)$		- \
		^$evv(MIXTWO)$			- \
		^$evv(MIXBALANCE)$		- \
		^$evv(MIXCROSS)$		- \
		^$evv(MIXINTERL)$		- \
		^$evv(EQ)$				- \
		^$evv(LPHP)$			- \
		^$evv(FSTATVAR)$		- \
		^$evv(FLTBANKN)$		- \
		^$evv(FLTBANKU)$		- \
		^$evv(FLTBANKV)$		- \
		^$evv(SYNFILT)$			- \
		^$evv(STRANDS)$			- \
		^$evv(FLTBANKV2)$		- \
		^$evv(FLTITER)$			- \
		^$evv(FLTSWEEP)$		- \
		^$evv(ALLPASS)$			- \
		^$evv(MOD_PITCH)$		- \
		^$evv(MOD_REVECHO)$		- \
		^$evv(MCHANREV)$		- \
		^$evv(EDIT_CUT)$		- \
		^$evv(EDIT_CUTMANY)$	- \
		^$evv(PSOW_CHOP)$		- \
		^$evv(SYLLABS)$			- \
		^$evv(EDIT_CUTEND)$		- \
		^$evv(EDIT_ZCUT)$		- \
		^$evv(MANY_ZCUTS)$		- \
		^$evv(EDIT_EXCISE)$		- \
		^$evv(EDIT_EXCISEMANY)$	- \
		^$evv(EDIT_INSERT)$		- \
		^$evv(EDIT_INSERT2)$	- \
		^$evv(EDIT_INSERTSIL)$	- \
		^$evv(EDIT_JOIN)$		- \
		^$evv(JOIN_SEQ)$		- \
		^$evv(JOIN_SEQDYN)$		- \
		^$evv(BRASSAGE)$		- \
		^$evv(SAUSAGE)$			- \
		^$evv(WRAPPAGE)$		- \
		^$evv(SIMPLE_TEX)$ 		- \
		^$evv(GROUPS)$ 			- \
		^$evv(DECORATED)$ 		- \
		^$evv(PREDECOR)$ 		- \
		^$evv(POSTDECOR)$ 		- \
		^$evv(ORNATE)$ 			- \
		^$evv(PREORNATE)$ 		- \
		^$evv(POSTORNATE)$ 		- \
		^$evv(MOTIFS)$ 			- \
		^$evv(MOTIFSIN)$		- \
		^$evv(TIMED)$ 			- \
		^$evv(TGROUPS)$ 		- \
		^$evv(TMOTIFS)$ 		- \
		^$evv(STACK)$ 			- \
		^$evv(DOUBLETS)$		- \
		^$evv(MIXMANY)$ 		- \
		^$evv(TMOTIFSIN)$ 		- \
		^$evv(RRRR_EXTEND)$		- \
		^$evv(SSSS_EXTEND)$		- \
		^$evv(PSOW_STRETCH)$	- \
		^$evv(PSOW_FREEZE)$		- \
		^$evv(PSOW_FEATURES)$	- \
		^$evv(PSOW_SPLIT)$		- \
		^$evv(PSOW_INTERP)$		- \
		^$evv(PSOW_INTERLEAVE)$	- \
		^$evv(PSOW_REPLACE)$	- \
		^$evv(PSOW_SYNTH)$		- \
		^$evv(PSOW_IMPOSE)$		- \
		^$evv(PSOW_EXTEND)$		- \
		^$evv(PSOW_EXTEND2)$	- \
		^$evv(PSOW_CUT)$		- \
		^$evv(PSOW_STRFILL)$	- \
		^$evv(PSOW_REINF)$		- \
		^$evv(PREFIXSIL)$		- \
		^$evv(STRANS_MULTI)$	- \
		^$evv(TAPDELAY)$		- \
		^$evv(CONSTRICT)$		- \
		^$evv(RMVERB)$			- \
		^$evv(ISOLATE)$ 		- \
		^$evv(REJOIN)$ 			- \
		^$evv(PACKET)$          - \
		^$evv(ECHO)$			- \
		^$evv(CANTOR)$			- \
		^$evv(TEX_MCHAN)$		- \
		^$evv(NEWTEX)$			- \
		^$evv(CERACU)$			- \
		^$evv(SHIFTER)$			- \
		^$evv(FRACTURE)$		- \
		^$evv(NEWDELAY)$		- \
		^$evv(MADRID)$			- \
		^$evv(DISTCUT)$			- \
		^$evv(ENVCUT)$			- \
		^$evv(TOSTEREO)$		- \
		^$evv(SILEND)$ {
			set dur_known(##$thisprocess) 0
			FixDefaultGrouchoDuration $thisprocess
		} \
		^$evv(SHRINK)$ {
			if {$this_mode < $evv(SHRM_FINDMX)} {
				set dur_known(##$thisprocess) 0
				FixDefaultGrouchoDuration $thisprocess
			}
		} \
		^$evv(GREV)$ {
			if {$this_mode == $evv(GREV_GET)} {
				set dur_known(##$thisprocess) 0
				set	prps(##$thisprocess) $zero_props
				set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(NUMLIST)]
				set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(LINECNT)  $evv(LINECNT)  $evv(DEFAULT_LINECNT)]
				set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(DUR) $evv(DUR) $evv(DEFAULT_DUR)]
				return 1
			} else {
				set dur_known(##$thisprocess) 0
				FixDefaultGrouchoDuration $thisprocess
			}
		} \
		^$evv(GREV_EXTEND)$ {
			set dur_known(##$thisprocess) 0
			FixDefaultGrouchoDuration $thisprocess
		} \
		^$evv(ENV_WARPING)$		- \
		^$evv(ENV_RESHAPING)$	- \
		^$evv(ENV_REPLOTTING)$	{
			if {$this_mode == $evv(ENV_TSTRETCHING)} {
				set dur_known(##$thisprocess) 0
				if {$this_prog == $evv(ENV_WARPING)} {
					FixDefaultGrouchoDuration $thisprocess
				} elseif {$this_prog == $evv(ENV_RESHAPING)} {
					FixDefaultEnvelDuration $thisprocess
				} else {
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(LINECNT)  $evv(LINECNT)  $evv(DEFAULT_LINECNT)]
					set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(DUR) $evv(DUR) $evv(DEFAULT_DUR)]
				}
			}
		} \
  		^$evv(ENV_IMPOSE)$  - \
  		^$evv(ENV_PROPOR)$  - \
		^$evv(ENV_REPLACE)$ {
			if {($this_mode == $evv(ENV_BRKFILE_IN)) || ($this_mode == $evv(ENV_DB_BRKFILE_IN))} {
				set dur_known(##$thisprocess) 0
				FixDefaultGrouchoDuration $thisprocess
			}
		} \
 		^$evv(MOD_RADICAL)$ {
			if {($this_mode == $evv(MOD_SCRUB)) || ($this_mode == $evv(MOD_CROSSMOD))} {
				set dur_known(##$thisprocess) 0
				FixDefaultGrouchoDuration $thisprocess
			}

	#	PROCESSES THAT GENERATE TEXT FROM NON-TEXT

		} \
		^$evv(MIXSYNC)$	   	 - \
		^$evv(MIXSYNCATT)$ {
			set dur_known(##$thisprocess) 0
			set	prps(##$thisprocess) $zero_props
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(MIXFILE)]
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(LINECNT)  $evv(LINECNT)  $evv(DEFAULT_LINECNT)]
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(DUR) $evv(DUR) $evv(DEFAULT_DUR)]
		} \
		^$evv(HOUSE_BUNDLE)$ {
			set dur_known(##$thisprocess) 0
			set	prps(##$thisprocess) $zero_props
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(LINELIST)]
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(LINECNT)  $evv(LINECNT)  $evv(DEFAULT_LINECNT)]
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(DUR) $evv(DUR) $evv(DEFAULT_DUR)]
		} \
		^$evv(GRAIN_GET)$ {
			set dur_known(##$thisprocess) 0
			set	prps(##$thisprocess) $zero_props
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(NUMLIST)]
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(LINECNT)  $evv(LINECNT)  $evv(DEFAULT_LINECNT)]
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(DUR) $evv(DUR) $evv(DEFAULT_DUR)]
		} \
		^$evv(PARTIALS_HARM)$ {
			set dur_known(##$thisprocess) 0
			set	prps(##$thisprocess) $zero_props
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(NUMLIST)]
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(LINECNT)  $evv(LINECNT)  $evv(DEFAULT_LINECNT)]
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(DUR) $evv(DUR) $evv(DEFAULT_DUR)]
		} \
		^$evv(PEAKFIND)$ {
			set dur_known(##$thisprocess) 0
			set	prps(##$thisprocess) $zero_props
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(NUMLIST)]
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(LINECNT)  $evv(LINECNT)  $evv(DEFAULT_LINECNT)]
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(DUR) $evv(DUR) $evv(DEFAULT_DUR)]
		} \
		^$evv(ENV_EXTRACT)$ {
		 	if {$this_mode == $evv(ENV_BRKFILE_OUT)} {
				set dur_known(##$thisprocess) 0
				set	prps(##$thisprocess) $zero_props
				set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(NBK_OR_N_OR_WL)]
				set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(LINECNT)  $evv(LINECNT)  $evv(DEFAULT_LINECNT)]
				set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(DUR) $evv(DUR) $evv(DEFAULT_DUR)]
			}
		} \
		^$evv(LUCIER_GETF)$ {
			set dur_known(##$thisprocess) 0
			set	prps(##$thisprocess) $zero_props
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(LINELIST)]
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(LINECNT)  $evv(LINECNT)  $evv(DEFAULT_LINECNT)]
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(DUR) $evv(DUR) $evv(DEFAULT_DUR)]

	#	PROCESSES THAT ALTER NUMBER OF LINES IN A TEXTFILE

		} \
		^$evv(ADDTOMIX)$ - \
		^$evv(MIXSHUFL)$ {
			set dur_known(##$thisprocess) 0
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(LINECNT)  $evv(LINECNT)  $evv(DEFAULT_LINECNT)]
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(DUR) $evv(DUR) $evv(DEFAULT_DUR)]
		} \
		^$evv(ENV_EXTRACT)$ {
		 	if {$this_mode == $evv(ENV_BRKFILE_OUT)} {
				set dur_known(##$thisprocess) 0
				set	prps(##$thisprocess) $zero_props
				set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(LINECNT)  $evv(LINECNT)  $evv(DEFAULT_LINECNT)]
				set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(NBK_OR_N_OR_WL)]
			}
		} \
		^$evv(ENV_REPLOTTING)$ {
		 	if {$this_mode == $evv(ENV_TSTRETCHING)} {
				set dur_known(##$thisprocess) 0
				set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(LINECNT)  $evv(LINECNT)  $evv(DEFAULT_LINECNT)]
				set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(DUR) $evv(DUR) $evv(DEFAULT_DUR)]
			}

	#	PROCESSES WHICH ALTER OUTFILE TYPE

		} \
		^$evv(FORMANTS)$ - \
		^$evv(ONEFORM_GET)$ {
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(FORMANTFILE)]
		} \
		^$evv(P_HEAR)$ {
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(ANALFILE)]
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(CHANS) $evv(CHANS) [lindex $prps(##$thisprocess) $evv(THIS_ORIGCHANS)]]
		} \
		^$evv(PITCH)$ {
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(PITCHFILE)]
			set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(CHANS) $evv(CHANS) 1]
		} \
		^$evv(REPITCH)$ {
			if {$this_mode == $evv(PPT)} {
				set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(TRANSPOSFILE)]
			}
		} \
		^$evv(SETHARES)$ - \
		^$evv(REPITCHB)$ {
			if {$this_mode == $evv(PPT)} {
				set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FTYP) $evv(TR_OR_UB_OR_N_OR_W)]
			}

	#	PROCESSES WHICH ALTER OUTFILE TYPE RADICALLY

		} \
		^$evv(PVOC_ANAL)$ {
			if {![GeneratePvocAnalOutprops $thisprocess]} {
				return 0
			}
		} \
		^$evv(PVOC_SYNTH)$ {
			GeneratePvocSynthOutprops $thisprocess
		}
	return 1
}
			
#------ Set a default value for the duration (& related params) of a snd-process gadget

proc FixDefaultGrouchoDuration {thisprocess} {
	global prps evv
	set	prps(##$thisprocess) \
		[lreplace $prps(##$thisprocess) $evv(DUR) $evv(DUR) $evv(DEFAULT_DUR)]
	set srate 	 [lindex $prps(##$thisprocess) $evv(SRATE)]
	set channels [lindex $prps(##$thisprocess) $evv(CHANS)]
	set insams 	 [expr round($evv(DEFAULT_DUR) * $srate * $channels)]
	set filesize $insams
	set	prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(INSAMS) $evv(INSAMS) $insams]
	set	prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FSIZ) $evv(FSIZ) $filesize]
}

#------ Set a default value for the duration (& related params) of a snd-process gadget

proc FixDefaultEnvelDuration {thisprocess} {
	global prps evv
	set	prps(##$thisprocess) \
		[lreplace $prps(##$thisprocess) $evv(DUR) $evv(DUR) $evv(DEFAULT_DUR)]
	set srate 	 [lindex $prps(##$thisprocess) $evv(SRATE)]
	set channels [lindex $prps(##$thisprocess) $evv(CHANS)]
	set insams 	 [expr round($evv(DEFAULT_DUR) * $srate * $channels)]
	set filesize $insams
	set	prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(INSAMS) $evv(INSAMS) $insams]
	set	prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FSIZ) $evv(FSIZ) $filesize]
}

#------ Set a default value for the duration (& related params) of a spectral-process gadget

proc FixDefaultSpecDuration {thisprocess} {
	global prps evv
	set frametime [lindex $prps(##$thisprocess) $evv(FRAMETIME)]
	set wlength   [expr round($evv(DEFAULT_DUR) / $frametime)]
	set duration  [expr $wlength * $frametime]
	set insams	  [expr $wlength * $evv(WANTED)]
	set filesize $insams
	set	prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(DUR) $evv(DUR) $duration]
	set	prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FSIZ) $evv(FSIZ) $filesize]
	set	prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(INSAMS)   $evv(INSAMS)   $insams]
	set	prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(WLENGTH)  $evv(WLENGTH)  $wlength]
}

#------ Gadget for a particular process depends on infile duration to set its range upper limit

proc IsDurationDependentGadget {this_prog this_mode g_no} {
	global evv

	if {$this_mode > 0} {
		incr this_mode -1
	}

	switch -regexp -- $this_prog \
		^$evv(ARPE)$ {
			if {$g_no == $evv(ARPE_SUST)} {
				return 1
			}
		} \
		^$evv(BLUR)$ {
			if {$g_no == $evv(BLUR_BLURF)} {
				return 1
			}
		} \
		^$evv(BLTR)$ {
			if {$g_no == $evv(BLUR_BLURF)} {
				return 1
			}
		} \
		^$evv(BRIDGE)$ {
			if {$g_no == $evv(BRG_OFFSET) || $g_no == $evv(BRG_STIME) || $g_no == $evv(BRG_ETIME)} {
				return 1
			}
		} \
		^$evv(CLEAN)$ {
			if {($this_mode == $evv(FROMTIME) || $this_mode == $evv(ANYWHERE)) && $g_no == $evv(CL_SKIPT)} {
				return 1
			}
		} \
		^$evv(CUT)$ {
			return 1
		} \
		^$evv(DRUNK)$ {
			if {$g_no == $evv(DRNK_RANGE) || $g_no == $evv(DRNK_STIME)} {
				return 1
			}
		} \
		^$evv(GRAB)$ {
			if {$g_no == $evv(GRAB_FRZTIME)} {
				return 1
			}
		} \
		^$evv(LEAF)$ {
			if {$g_no == $evv(LEAF_SIZE)} {
				return 1
			}
		} \
		^$evv(MAGNIFY)$ {
			if {$g_no == $evv(MAG_FRZTIME)} {
				return 1
			}
		} \
		^$evv(MORPH)$ {
			if {$g_no == $evv(MPH_STAG) || $g_no == $evv(MPH_ASTT)} {
				return 1
			}
		} \
		^$evv(SPECMORPH)$ {
			return 1
		} \
		^$evv(SPECMORPH2)$ {
			if {$this_mode != 0} {
				if {$g_no == 0 || $g_no == 1} {
					return 1
				}
			}
		} \
		^$evv(OCTVU)$ {
			if {$g_no == $evv(OCTVU_TSTEP)} {
				return 1
			}
		} \
		^$evv(P_APPROX)$ {
			if {$g_no == $evv(PA_TRANG) || $g_no == $evv(PA_SRANG)} {
				return 1
			}
		} \
		^$evv(P_CUT)$ {
			if {$g_no == $evv(PC_STT) || $g_no == $evv(PC_END)} {
				return 1
			}
		} \
		^$evv(P_FIX)$ {
			if {$g_no == $evv(PF_SCUT) || $g_no == $evv(PF_ECUT)} {
				return 1
			}
		} \
		^$evv(P_RANDOMISE)$ {
			if {$g_no == $evv(PR_TSTEP)} {
				return 1
			}
		} \
		^$evv(P_SMOOTH)$ {
			if {$g_no == $evv(PS_TFRAME)} {
				return 1
			}
		} \
		^$evv(PEAK)$ {
			if {$g_no == $evv(PEAK_TWINDOW)} {
				return 1
			}
		} \
		^$evv(WARP)$ {
			if {$g_no == $evv(WARP_TRNG) || $g_no == $evv(WARP_SRNG)} {
				return 1
			}
		} \
		^$evv(WAVER)$ {
			if {$g_no == $evv(WAVER_VIB)} {
				return 1
			}
		} \
		^$evv(ZIGZAG)$ {
			if {$g_no == $evv(ZIGZAG_START) ||  $g_no == $evv(ZIGZAG_END) \
			||  $g_no == $evv(ZIGZAG_DUR)   ||  $g_no == $evv(ZIGZAG_MIN) \
			||  $g_no == $evv(ZIGZAG_MAX)} {
				return 1
			}
		} \
		^$evv(SHRINK)$ {
			if {$this_mode < $evv(SHRM_FINDMX)} {
				if {$g_no == $evv(SHR_GAP) ||  $g_no == $evv(SHR_DUR)} {
					return 1
				}
			} else {
				if {$g_no == $evv(SHR_AFTER)} {
					return 1
				}
			}
		} \
		^$evv(LOOP)$ {
			if {$g_no == $evv(LOOP_START) ||  $g_no == $evv(LOOP_LEN)   \
			||  $g_no == $evv(LOOP_STEP)  ||  $g_no == $evv(LOOP_SRCHF)} {
				return 1
			}
		} \
		^$evv(SCRAMBLE)$ {
			if {$g_no == $evv(SCRAMBLE_MIN) ||  $g_no == $evv(SCRAMBLE_MAX) \
			||  $g_no == $evv(SCRAMBLE_LEN)} {
				return 1
			}
		} \
		^$evv(ITERATE_EXTEND)$ - \
		^$evv(ITERATE)$ {
			if {$this_mode == $evv(ITERATE_DUR) && $g_no == $evv(ITER_DUR)} {
				return 1
			}
		} \
		^$evv(ITERLINE)$ - \
		^$evv(ITERLINEF)$ {
			if {$g_no == $evv(ITER_DUR)} {
				return 1
			}
		} \
		^$evv(DOUBLETS)$ {
			return 1
		} \
		^$evv(GRAIN_ALIGN)$ {
			if {$g_no == $evv(GR_BLEN) || $g_no == $evv(GR_MINTIME) || $g_no == $evv(GR_WINSIZE)} {
				return 1
			}
		} \
		^$evv(ENV_REPLACE)$ {
			if {$g_no == $evv(ENV_WSIZE)} {
				return 1
			}
		} \
		^$evv(ENV_EXTRACT)$ {
			if {$g_no == $evv(ENV_WSIZE)} {
				return 1
			}
		} \
		^$evv(ENV_RESHAPING)$ {
			if {$this_mode == $evv(ENV_TRIGGERING)} {
				if {$g_no == $evv(ENV_TRIGDUR) || $g_no == $evv(ENV_WSIZE)}  {
					return 1
				}
			}
		} \
		^$evv(ENV_WARPING)$    - \
		^$evv(ENV_REPLOTTING)$ {
			if {$g_no == $evv(ENV_WSIZE)} {
				if {$this_mode == $evv(ENV_TRIGGERING) && $g_no == $evv(ENV_TRIGDUR)} {
					return 1
				}
			}
		} \
		^$evv(ENV_DOVETAILING)$ {
			if {$g_no == $evv(ENV_STARTTRIM) || $g_no == $evv(ENV_ENDTRIM)} {
				return 1
			}
		} \
		^$evv(ENV_CURTAILING)$ - \
		^$evv(EXPDECAY)$ {
			if {$g_no == $evv(ENV_STARTTIME) || $g_no == $evv(ENV_ENDTIME)} {
				return 1
			}
		} \
		^$evv(PEAKCHOP)$ {
			if {($g_no != 0) && ($g_no != 5) && ($g_no != 6)} {
				return 1
			}
		} \
		^$evv(ENV_SWELL)$ {
			if {$g_no == $evv(ENV_PEAKTIME)} {
				return 1
			}
		} \
		^$evv(ENV_ATTACK)$ {
			if {$g_no == $evv(ENV_ATK_TAIL)} {
				return 1
			}
			if {$this_mode == $evv(ENV_ATK_TIMED) || $this_mode == $evv(ENV_ATK_XTIME)} {
				if {$g_no == $evv(ENV_ATK_ATTIME)} {
					return 1
				}
			}
		} \
		^$evv(ENV_PLUCK)$ {
			if {$g_no == $evv(ENV_PLK_ENDSAMP)} {
				return 1
			}
		} \
		^$evv(MIXCROSS)$ {
			if {$g_no == $evv(MCR_STAGGER) || $g_no == $evv(MCR_BEGIN)} {
				return 1
			}
		} \
		^$evv(MIXTWO)$ - \
		^$evv(MIXBALANCE)$ {
			if {$g_no == $evv(MIX_STAGGER)} {
				return 1
			}
		} \
		^$evv(MIXGAIN)$ {
			if {$g_no == $evv(MSH_ENDLINE) || $g_no == $evv(MSH_STARTLINE)} {
				return 1
			}
		} \
		^$evv(MIXTWARP)$ {
			if {$this_mode != $evv(MTW_TIMESORT)} {
				if {$g_no == $evv(MSH_ENDLINE) || $g_no == $evv(MSH_STARTLINE)} {
					return 1
				}
			}
		} \
		^$evv(MIXSWARP)$ {
			if {$this_mode == $evv(MSW_TWISTONE) && $g_no == $evv(MSW_TWLINE)} {
				return 1
			}
			if {$this_mode != $evv(MSW_TWISTALL) && $this_mode != $evv(MSW_TWISTONE)}  {
				if {$g_no == $evv(MSH_ENDLINE) || $g_no == $evv(MSH_STARTLINE)} {
					return 1
				}
			}
		} \
		^$evv(MIXSHUFL)$ {
			if {$g_no == $evv(MSH_ENDLINE)	|| $g_no == $evv(MSH_STARTLINE)} {
				return 1
			}
		} \
		^$evv(MIX_PAN)$ {
			if {$g_no == $evv(PAN_PAN)} {
				return 1
			}
		} \
		^$evv(FLTITER)$ {
			if {$g_no == $evv(FLT_OUTDUR)} {
				return 1
			}
		} \
		^$evv(ALLPASS)$ {
			if {$g_no == $evv(FLT_DELAY)} {
				return 1
			}
		} \
		^$evv(MOD_PITCH)$ {
			if {$this_mode == $evv(MOD_ACCEL)} {
				if {$g_no == $evv(ACCEL_GOALTIME) || $g_no == $evv(ACCEL_STARTTIME)} {
					return 1
				}
			}
		} \
		^$evv(MOD_REVECHO)$ {
			if {$this_mode == $evv(MOD_VDELAY) && $g_no == $evv(DELAY_LFODELAY)} {
				return 1
			}
		} \
		^$evv(ECHO)$ {
			return 1
		} \
		^$evv(MOD_RADICAL)$ {
			if {$this_mode == $evv(MOD_SHRED) && $g_no == $evv(CHRED_CHLEN)} {
				return 1
			} elseif {$this_mode == $evv(MOD_SCRUB)} {
				if {$g_no == $evv(SCRUB_TOTALDUR) ||  $g_no == $evv(SCRUB_STARTRANGE) \
				||  $g_no == $evv(SCRUB_ESTART)} {
					return 1
				}
			}
		} \
		^$evv(SAUSAGE)$	- \
		^$evv(BRASSAGE)$ {
			if {$g_no == $evv(GRS_GRAINSIZE)  \
			||  $g_no == $evv(GRS_HGRAINSIZE) \
			||  $g_no == $evv(GRS_SRCHRANGE)} {
				return 1
			}
		} \
		^$evv(WRAPPAGE)$ {
			if {$g_no == $evv(WRAP_GRAINSIZE)  \
			||  $g_no == $evv(WRAP_HGRAINSIZE) \
			||  $g_no == $evv(WRAP_SRCHRANGE)} {
				return 1
			}
		} \
		^$evv(EDIT_ZCUT)$	  - \
		^$evv(EDIT_EXCISE)$	  - \
		^$evv(EDIT_INSERTSIL)$ - \
		^$evv(EDIT_INSERT2)$ - \
		^$evv(EDIT_CUT)$ {
			if {$g_no == $evv(CUT_CUT) || $g_no == $evv(CUT_END)} {
				return 1
			}
		} \
		^$evv(EDIT_CUTEND)$  - \
		^$evv(EDIT_INSERT)$ {
			if {$g_no == $evv(CUT_CUT)} {
				return 1
			}
		} \
		^$evv(DRUNKWALK)$ {
			if {$g_no == $evv(DRNK_TOTALDUR) \
			||  $g_no == $evv(DRNK_LOCUS) \
			||  $g_no == $evv(DRNK_AMBITUS) \
			||  $g_no == $evv(DRNK_GSTEP)	 \
			||  $g_no == $evv(DRNK_CLOKTIK) \
			||  $g_no == $evv(DRNK_SPLICELEN)} {
				return 1
			}
			if {$this_mode == $evv(HAS_SOBER_MOMENTS)} {
				if {$g_no == $evv(DRNK_MIN_PAUS) || $g_no == $evv(DRNK_MAX_PAUS)} {
					return 1
				}
			}
		} \
		^$evv(SHUDDER)$ {
			if {$g_no == $evv(SHUD_FRQ) \
			||  $g_no == $evv(SHUD_SCAT) \
			||  $g_no == $evv(SHUD_SPREAD) \
			||  $g_no == $evv(SHUD_MINDEPTH) \
			||  $g_no == $evv(SHUD_MAXDEPTH) \
			||  $g_no == $evv(SHUD_MINWIDTH) \
			||  $g_no == $evv(SHUD_MAXWIDTH)} {
				return 1
			}
		} \
		^$evv(PSOW_REINF)$ - \
		^$evv(PSOW_SPLIT)$ {
			if {$g_no == 0} {
				return 1
			}
		} \
		^$evv(PSOW_STRFILL)$ {
			if {$g_no == 0 || $g_no == 3} {
				return 1
			}
		} \
		^$evv(PSOW_DEL)$ - \
		^$evv(PSOW_IMPOSE)$ - \
		^$evv(PSOW_DUPL)$ {
			if {$g_no == 0 || $g_no == 1} {
				return 1
			}
		} \
		^$evv(PSOW_STRETCH)$ {
			if {$g_no == 0 || $g_no == 2} {
				return 1
			}
		} \
		^$evv(PSOW_FEATURES)$ {
			if {$g_no != 1 && $g_no != 7} {
				return 1
			}
		} \
		^$evv(PSOW_EXTEND)$ {
			if {$g_no != 2 && $g_no != 3} {
				return 1
			}
		} \
		^$evv(PSOW_EXTEND2)$ {
			if {$g_no != 2 } {
				return 1
			}
		} \
		^$evv(PARTIALS_HARM)$ {
			if {($this_mode > 1) && ($g_no == 2)} {
				return 1
			}
		} \
		^$evv(PSOW_SPACE)$	- \
		^$evv(PSOW_INTERP)$	- \
		^$evv(PSOW_SYNTH)$	- \
		^$evv(ONEFORM_GET)$ - \
		^$evv(PEAKFIND)$ - \
		^$evv(CONSTRICT)$ - \
		^$evv(PSOW_CHOP)$ {
			return 1
		} \
		^$evv(MCHANPAN)$ {
			switch -- $this_mode {
				2 -
				3 {
					if {($g_no == 1) || ($g_no == 2) || ($g_no == 3) || ($g_no == 4)} {
						return 1
					}
				
				}
				5 {
					if {($g_no == 2) || ($g_no == 3)} {
						return 1
					}
				}
				6 {
					if {$g_no == 0} {
						return 1
					}
				}
				8 -
				9 {
					return 0
				}
				default {
					if {$g_no == 0} {
						return 1
					}
				}
			}
		} \
		^$evv(FRAME)$ {
			switch -- $this_mode {
				0 {
					if {$g_no == 1} {
						return 1
					}
				}
				1 {
					if {$g_no == 1 || $g_no == 2} {
						return 1
					}
				}
			}
		} \
		^$evv(SUPERACCU)$ {
			switch -- $this_mode {
				0 -
				1 {
					if {($g_no == 0) || ($g_no == 1)} {
						return 1
					}
				}
				2 -
				3 {
					if {($g_no == 1) || ($g_no == 2)} {
						return 1
					}
				}
			}
		} \
		^$evv(SPECSPHINX)$ {
			switch -- $this_mode {
				0 -
				1 {
					if {($g_no == 0) || ($g_no == 1)} {
						return 1
					}
				}
				2 {
					if {$g_no == 0} {
						return 1
					}
				}
			}
		} \
		^$evv(SPECTWIN)$ {
			if {($g_no == 0) || ($g_no == 1)} {
				return 1
			}
		} \
		^$evv(TAN_ONE)$ - \
		^$evv(TAN_SEQ)$ - \
		^$evv(TAN_LIST)$ {
			if {($g_no == 5)} {
				return 1
			}
		} \
		^$evv(TAN_TWO)$ {
			if {($g_no == 6)} {
				return 1
			}
		} \
		^$evv(CANTOR)$ {
			if {($g_no == 4) || ($g_no == 5)} {
				return 1
			}
		} \
		^$evv(ENVCUT)$ {
			if {($g_no == 0) || ($g_no == 1) || ($g_no == 2)} {
				return 1
			}
		}

	return 0
}

#------ Predict properties of a PVOC analysis process

proc GeneratePvocAnalOutprops {thisprocess} {
	global cmd_line prps evv

	set pos $evv(CMD_INFILECNT)
	set infilecnt [lindex $cmd_line $pos]
	incr pos
	incr pos $infilecnt
	incr pos
	set chans [lindex $cmd_line $pos]
	if [string match $evv(VARP_MARK) $chans] {
		Inf "Sorry, this instrument does not have predictable properties."
		return 0
	}
	set chans [string range $chans 1 end]	;#	Delete the numeric marker on the value
	set chans [expr $chans + ($chans % 2)]
	incr pos
	set ovlp [lindex $cmd_line $pos]
	set ovlp [string range $ovlp 1 end]		;#	Delete the numeric marker on the value
	if [string match $evv(VARP_MARK) $ovlp] {
		Inf "Sorry, this instrument does not have predictable properties."
		return 0
	}
	incr ovlp -1
	switch -- $ovlp {
		0 {set dec [expr $chans * 4]}
		1 {set dec [expr $chans * 2]}
		2 {set dec $chans}
		3 {set dec [expr $chans / 2]}
	}
	set dec [expr int($dec / 8)]
	if {$dec < 1} {
		set dec 1
	}
	set srate [lindex $prps(##$thisprocess) $evv(SRATE)]
	set dur   [lindex $prps(##$thisprocess) $evv(DUR)]
	set arate [expr double($srate) / double($dec)]
	set frametime [expr 1.0 / $arate]
	set srate [expr int($arate)]
	set wlength [expr round($dur / $frametime)]
	incr chans 2
	set wanted $chans
	set insams [expr $wlength * $wanted]
	set filesize [expr $insams * $evv(FLTSIZE)]
	set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FRAMETIME) \
		$evv(ANALFILE) $filesize $insams $srate $chans $wanted $wlength 0 $arate $frametime]
	set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(THIS_DFAC) $evv(THIS_DFAC) $dec]
	return 1
}

#------ Predict properties of a PVOC synthesis process

proc GeneratePvocSynthOutprops {thisprocess} {
	global prps evv

	set dur   [lindex $prps(##$thisprocess) $evv(DUR)]
	set dec   [lindex $prps(##$thisprocess) $evv(THIS_DFAC)]
	set srate [lindex $prps(##$thisprocess) $evv(SRATE)]
	set srate [expr round($srate * $dec)]
	if {$srate > 45000} {
		set srate 48000
	} elseif {$srate > 40000} {
		set srate 44100
	} elseif {$srate > 30000} {
		set srate 32000
	} elseif {$srate > 23000} {
		set srate 24000
	} elseif {$srate > 20000} {
		set srate 22050
	} else {
		set srate 16000
	}
	set insams [expr round($dur * double($srate))]
	set filesize [expr $insams * $evv(SHORTSIZE)]
	set chans 1
	set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(FTYP) $evv(FRAMETIME) \
		$evv(SNDFILE) $filesize $insams $srate $chans 0 0 0 0.0 0.0]
	set prps(##$thisprocess) [lreplace $prps(##$thisprocess) $evv(THIS_DFAC) $evv(THIS_DFAC) 0.0]
}

#########################
# RUNNING INSTRUMENTS	#
#########################

#------ Try to run a ins which has been selected on the ins-listing

proc RunIns {} {
	global inslisting chlist ins hst tree brk lastrangetype pim evv last_ch

	set preset 0

	if {$hst(active) && $hst(ins)} {				;#	OVER-CAUTIOUS !!
		set preset 1
		set ins(name) [lindex $hst(this) 0]
	} elseif {$ins(recall)} {
		if {![info exists ins(last_name)]} {
			Inf "No Instrument Run Successfully Previously"
			set ins(recall) 0
			set ins(run) 0
 			set ins(was_last_process_used) $ins(was_penult_process)
 			set ins(early_abort) 1
			return
		}
		set preset 1
		set ins(name) $ins(last_name) 
	}
	set ins(recall) 0
	if {$preset} {
		set OK -1
		if {[info exists ins(names)] && ([llength $ins(names)] > 0)} {
			set i 0
			foreach mname $ins(names) {
				if [string match $mname $ins(name)] {
					set OK $i
					break
				}
				incr i
			}
		}
		if {$OK < 0} {
			Inf "Instrument '$ins(name)' no longer exists.\n"
			set hst(active) 0
			set hst(ins) 0					
			set ins(run) 0
 			set ins(was_last_process_used) $ins(was_penult_process)
 			set ins(early_abort) 1
			return
		} else {
			set i $OK
		}
	} else {
		if {[llength $ins(names)] == 1} {
			set i 0
		} else {
			set ilist [$inslisting curselection]
			if {[llength $ilist] <= 0} {
				Inf "No instrument selected."
				set ins(run) 0
	 			set ins(was_last_process_used) $ins(was_penult_process)
	 			set ins(early_abort) 1
				return
			}
			set i [lindex $ilist 0]
		}
		set ins(name) [lindex $ins(names) $i]
	}

	if {[info exists pim] && [info exists $pim]} {
		$pim.help.help config -fg $evv(SPECIAL) -text "Getting Parameter Details for $ins(name)"
	}

	set infilecnt [lindex $ins(infilecnts) $i]

	if [info exists chlist] {
		set kk [llength $chlist]
	} else {
		set kk 0
	}
	if {$kk != $infilecnt} {				;#	Check ins valid with this number of infiles
		Inf "Wrong number of infiles to run this instrument: needs $infilecnt files"
		set ins(run) 0
		set hst(active) 0
		set hst(ins) 0					
		if {[info exists pim] && [info exists $pim]} {
			$pim.help.help config -fg [option get . foreground {}] -text "$evv(HELP_DEFAULT)"
		}
		set ins(was_last_process_used) $ins(was_penult_process)
		set ins(early_abort) 1
		return
	}
	set ins(this) "[lindex $ins(uberlist) $i]"

	set ins(conditions) "[lindex $ins(this) $evv(MSUPER_CONDITIONS)]" 
	set cmd "MeetAllConditions"
	if [info exists chlist] {
		foreach infile $chlist {
			lappend cmd $infile
		}
	}
	if [string match [eval $cmd] "0"] {
		set ins(run) 0
		set hst(active) 0
		set hst(ins) 0
		if {[info exists pim] && [info exists $pim]} {
			$pim.help.help config -fg [option get . foreground {}] -text "$evv(HELP_DEFAULT)"
		}
		set ins(was_last_process_used) $ins(was_penult_process)
		set ins(early_abort) 1
		return
	}											;#	Unwrap all data for this ins

	set ins(cmdset) 	 "[lindex $ins(this) $evv(MSUPER_BATCH)]"
	set ins(gadgets)	 "[lindex $ins(this) $evv(MSUPER_GADGETS)]"
	set ins(tree) 		 "[lindex $ins(this) $evv(MSUPER_TREE)]"
	set tree(fnams)		 "[lindex $ins(this) $evv(MSUPER_FNAMES)]"
	set tree(procnames)		 "[lindex $ins(this) $evv(MSUPER_PNAMES)]"
	set ins(defaults)	 "[lindex $ins(this) $evv(MSUPER_DEFAULTS)]"
	set ins(subdefaults) "[lindex $ins(this) $evv(MSUPER_SUBDEFAULTS)]"
	set ins(timetypes)   "[lindex $ins(this) $evv(MSUPER_TIMETYPE)]"

# HISTORY: BEGIN CONSTRUCTION OF DO-INSTRUMENT HISTORY -->
	catch {unset hst(doins_cmd)}
	lappend hst(doins_cmd) $ins(name)
	if [info exists chlist] {
		set infilecnt [llength $chlist]
	} else {
		set infilecnt 0
	}
	lappend hst(doins_cmd) $infilecnt
	if [info exists chlist] {
		foreach infile $chlist {
			lappend hst(doins_cmd) $infile
		}											
	}
	set hst(initial_len) [llength $hst(doins_cmd)]
# <-- HISTORY: BEGIN CONSTRUCTION OF DO-INSTRUMENT HISTORY
	set brk(endtimeset) 0						;#	global variable	re endtime-of-brktables-used
	catch {unset lastrangetype}					;#	initialise memory for penultimate process-run (!!) 

	if {![RunThisIns]} {
		set ins(run) 0
		set ins(early_abort) 1
	}
	set last_ch $chlist
	set ins(run) 0

}

#------ Test input files against ins conditions
#
#	args is list of infiles given by user
#

proc MeetAllConditions {args} {
	global ins evv pa
	set i 0
	foreach fnam $args {
		set ftype $pa($fnam,$evv(FTYP))
		set chans $pa($fnam,$evv(CHANS))

		set condition_set "[lindex $ins(conditions) $i]"
		foreach condition_list $condition_set {
			if {![eval {MeetsCondition $ftype $chans $i} $condition_list]} {
				return 0
			}
		}
		incr i		
	}
	return 1
}

#------ Test Nth-infile input-properties against condition associated with Nth infile
						   
proc MeetsCondition {ftype chans fileno args} {
	global evv
	incr fileno
	foreach condition $args {
		if [string match "MONO" $condition] {
			if {$chans != 1} {	;#	If NOT mono, reject
				Inf "File number $fileno must be MONO for this instrument."
				return 0
			}
		} elseif [string match "STEREO" $condition] {
			if {$chans != 2} {	;#	If NOT stereo, reject
				Inf "File number $fileno must be STEREO for this instrument."
				return 0
			}
		} elseif {$condition == $evv(IS_A_MIXFILE)} {
			if {![IsAMixfile $ftype]} {
				Inf "File number $fileno is of the wrong type for this instrument."
				return 0
			}
		} elseif {$condition == $evv(IS_A_SNDLIST)} {
			if {![IsASndlist $ftype]} {
				Inf "File number $fileno is of the wrong type for this instrument."
				return 0
			}
		} elseif [string match \=* $condition] {
			set condition [string range $condition 1 end]
			if {$ftype != $condition} {			
				Inf "File number $fileno is of the wrong type for this instrument."
				return 0
			}
		} elseif [string match \|\|* $condition] {
			set condition [string range $condition 2 end]
			if {$ftype & $condition} {			
				return 1		;#	If it IS of this type, keep: else continue testing more conditions
			}
		} elseif [string match \!* $condition] {
			set condition [string range $condition 1 end]
			if {$ftype == $condition} {			
				Inf "File number $fileno is of the wrong type for this instrument."
				return 0
			}
		} elseif {!($ftype & $condition)} {
			Inf "File number $fileno is of the wrong type for this instrument."
			return 0
		}
	}
	return 1
}

#------ Run a specific ins

proc RunThisIns {} {
	global ins hst evv pg_spec pr3 do_repost
	global ppg_hlp_actv ppg_actv chlist prmgrd
	global dfault ins_subdflt from_runpage ins_timetype was_ins_run_recycle
	global prg_ran_before pmcnt gdg_creat_fail has_saved pim papag shortwindows small_screen

	set	prg_ran_before 0

	set ins(process_length) [llength $ins(tree)] 
	catch {unset pg_spec}
													;#	establish whether length of input prm-brkfiles
	set pmcnt 0

	Block "Checking out Parameters for your Instrument"

	set n 0
	foreach item $ins(defaults) {
		if {[InsParamIsVowel $n] && [ValidVowelName $item] } {
			incr n
			continue
		}
		incr n
	}

	if {![GetInsGadgets]} {						;#	New intelligent code to use existing file props
		UnBlock
		return 0									;#	and predict props of not-yet-created files
	}
	UnBlock

	if {!$ins(was_penult_process)} {			;#	If last process was not a ins
		catch {destroy .ppg}
		ClearProcessDependentItems					;#	Or it was a different ins
	} elseif {[info exists ins(last_name)] && ![string match $ins(name) $ins(last_name)]} {
		catch {destroy .ppg}					;#	destroy the associated ppg display
		ClearProcessDependentItems					;#	and the remembered parameter data
	}

	set ppg_hlp_actv 0
	set ppg_actv 1

	set pcnt1 0 
	foreach current_dflt $ins(defaults) {
		set dfault($pcnt1) $current_dflt
		incr pcnt1
	}
	set pcnt2 0 
	foreach current_subdflt $ins(subdefaults) {
		set ins_subdflt($pcnt2) $current_subdflt
		incr pcnt2
	}
	set pcnt3 0 

	catch {unset ins_timetype} 
	foreach thisprocess $ins(timetypes) {
		set len [llength $thisprocess]
		if {$len > 0} {
			set timetype [lindex $thisprocess 0]
			foreach tt [lrange $thisprocess 1 end] {
				if {$tt} {
					set	ins_timetype($pcnt3) $timetype
				} else {
					set	ins_timetype($pcnt3) -1
				}
				incr pcnt3
			}
		}
	}	
	if {$pcnt1 != $pcnt2} {
		ErrShow "Anomaly in data for Instrument : count of defaults not equal to count of subdefaults"
		return 0
	}
	if {$pcnt2 != $pcnt3} {
		ErrShow "Anomaly in data for Instrument : count of defaults not equal to count of timetypes"
		return 0
	}

	set from_runpage 1
	set gdg_creat_fail 0


	if [Dlg_Create .ppg "Parameters" "set pr3 0" -borderwidth $evv(BBDR)] {
		Dlg_Params .ppg $ins(name)
	}
	if {$small_screen} {
		set papag .ppg.c.canvas.f
	} else {
		set papag .ppg
	}	

	set entry_focus [EstablishRollingFocus]

	wm title .ppg "Parameters for Instrument $ins(name)"

	if {[info exists chlist]} {
		ForceVal $papag.parameters.buttons.fcnte [llength $chlist]
	} else {
		ForceVal $papag.parameters.buttons.fcnte "0"
	}
	if {$evv(NEWUSER_HELP)} {
		$papag.help.starthelp config -command "GetNewUserHelp parameters"
	}

	$papag.parameters.zzz.mabo config -text "Recycle Outfile" -command "RecycleOutfile" -state disabled
	$papag.parameters.output.playsrc config -text "Play Source" -command "PlayInput"

	set tshifter [IsTimeStretchingInstrument]
	if {$tshifter > 0} {
		$papag.parameters.output.editsrc config -text "TempoShift" -command "TempoShift 1 $tshifter" -bd 2 -state normal
	} else {
		$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
	}

	if {$gdg_creat_fail} {
		set from_runpage 0
		return 0
	}

	if {[info exists pim] && [info exists $pim]} {
		$pim.help.help config -fg [option get . foreground {}] -text "$evv(HELP_DEFAULT)"
	}
 	$papag.parameters.buttons.info config -command "ViewIns 1"
 	$papag.parameters.buttons.orig config -text "Orig Defaults" -state normal -borderwidth $evv(SBDR)

	SetButtonsStartState $papag.parameters		;#	Disable the output-action buttons

	if {$hst(active)} {
		EstablishHistoricalParams					;#	If running a previous ins with RECALL
	}												;#	Put it's params into the prm dialog boxes

	set ins(last_name) $ins(name) 			;#	Remember name for next pass

	set pr3 0
	set finished 0
	raise .ppg
	update idletasks
	StandardPosition .ppg
	if {[string length $entry_focus] > 0} {
		My_Grab 0 .ppg pr3 $entry_focus
	} else {
		My_Grab 0 .ppg pr3
	}
	while {!$finished} {
		tkwait variable pr3
		if {$pr3} {								;#	If a ins has been run succesfully
			if {![DeleteMarkedOutfiles]} {			;#	Pre-delete all intrinsically unwanted files
				RestoreInslessSystem			;#	delete temp outfiles, delete local-treedata
				set finished 1						;#	outfiles saved on pressing KEEP button	
			}										
			EnableOutputButtons $papag.parameters.output $papag.parameters.zzz.newp $papag.parameters.zzz.newf
		} else {
			if {![info exists was_ins_run_recycle] || !$was_ins_run_recycle} {
				RememberLastRunVals
			}
			RestoreInslessSystem				;#	delete temp outfiles, delete local-treedata
			AdjustAgainLabel
			set finished 1							
		}
	}
	My_Release_to_Dialog .ppg
	Dlg_Dismiss .ppg
	if [info exists do_repost] {
		unset do_repost
	}
	set from_runpage 0
	return 1
}

#------ Reconstruct the cmdlines needed for ins from templates + input data for params & infiles
#

proc AssembleTemporaryCmdlinesForIns {} {
	global temp_batch ins prm hst evv pa chlist pmcnt
	set i 0
	set pcnt 0 
	catch {unset temp_batch}
	set histpos 0
	foreach cmdline $ins(cmdset) {
		set zcmd [lindex $cmdline 0]
		set execprog [file join $evv(CDPROGRAM_DIR) [file tail $zcmd]]
		if {[ProgMissing $execprog "Cannot run this Instrument"]} {
			return 0
		}
		set pos $evv(CMD_INFILECNT)
		set filecnt [lindex $cmdline $pos]
		incr pos
		set j 0
		while {$j < $filecnt} {
			set thisfilename [lindex $cmdline $pos]			   			;#	Find name of next infile
			if [string match $evv(INFIL_MARK)* $thisfilename] {			;#	IF its marked as an infile
				set thisfilename [file rootname $thisfilename]
				set fileno [string range $thisfilename 1 end]			;#	Find infileno, embedded in name
				if {![info exists chlist] || ($fileno >= [llength $chlist])} {
					ErrShow "Insufficient files for one of the processes"
					return 0
				}
				set realname [lindex $chlist $fileno]					;#	Get actual current-input file
				set cmdline [lreplace $cmdline $pos $pos $realname] 	;#	Insert (replace) into cmdline
			}
			incr j
			incr pos
		}


		incr pos														 ;#	Step over outfilename
		set thisend [llength $cmdline]
		incr thisend -1
		if {[lindex $cmdline 1] == $evv(HOUSE_BUNDLE)} {
			incr thisend -1
		}
		set thispos $pos
		foreach parameter [lrange $cmdline $thispos $thisend] {
			if [string match $evv(VARP_MARK) $parameter] {		;#	"#" only
  				set val [MarkNumericVals $pcnt]
																		;#	Distinguish numbers from brkfiles
				if {($histpos == 0)} {
					if {[llength $hst(doins_cmd)] != $hst(initial_len)} {
						set hst(doins_cmd) [lrange $hst(doins_cmd) 0 [expr $hst(initial_len) - 1]]
					}
					incr histpos
				}
				lappend hst(doins_cmd) $val
				set cmdline [lreplace $cmdline $pos $pos $val]			;#	Insert (replace) into cmdline
				incr pcnt
				if {$pcnt > $pmcnt} {
					ErrShow "Not enough params to satisfy cmdlines of instrument"
					return 0
				}
			}
			incr pos
		}
		lappend temp_batch $cmdline										;#	Assemble all cmdlines of ins
	}
	if {$pcnt < $pmcnt} {
		ErrShow "Not enough locations on cmdlines of instrument to take all prm-vals"
		return 0
	}
	return 1
}

#------ Substitute the properties of the infiles OR INTERMEDIATE FILES

proc InterpretCmdlineForIns {cmdline} {
	global pa evv ins temp_batch prg

	set pos $evv(CMD_INFILECNT)

	set filecnt [lindex $cmdline $pos]
	incr pos
	if {$filecnt > 0} {
		set realname [lindex $cmdline $pos]
		if {![info exists pa($realname,0)]} {
			if [string match \#* $realname] {
				Inf "Failed to find data on intermediate file $realname"
			} else {
				set msg "Failed to find data on input file $realname"
				if {$ins(process_cnt) > 0} {
					set prg_no [expr $ins(process_cnt) - 1]
					set last_CDP_cmd "[lindex $temp_batch $prg_no]"	
					set ppprg [lindex $last_CDP_cmd 1]
					set mmmod [lindex $last_CDP_cmd 2]
					if {[ProcessHasVariableNumberOfOutfiles $ppprg $mmmod]} {
						append msg "\n\nPrevious process \"[lindex $prg(394) 1]\"\n"
						append msg "has a variable number of output files.\n"
						append msg "You may be attempting to access a file that it did not make\n"
						append msg "or failing to access a file that it did make.\n"
					}
				}
				Inf $msg
			}
			return ""
		}
		set endcmd [lrange $cmdline $pos end]
		set cmdline [lrange $cmdline 0 $evv(CMD_INFILECNT)]
		set propno 0													;#	If process takes input-files
		while {$propno < $evv(CDP_PROPS_CNT)} {							;#	Insert props of first input file
			lappend cmdline $pa($realname,$propno)
			incr propno
		}
		set cmdline [concat $cmdline $endcmd]
	}
	return $cmdline
}

#------ Delete all files that are not (potentially) saveable at end of ins

proc DeleteMarkedOutfiles {} {
	global tree prg_ocnt sndsout asndsout vwbl_sndsysout smpsout txtsout src evv
	set returnval 1
	foreach treeline $tree(fnams) {
		if [string match d* $treeline] {				;#	Find files marked for deletion
			set i [string first ":" $treeline]		
			incr i -1								
			set codename [string range $treeline 0 $i]	;#	Find their filetype (from codename extension)
			set name_ext [file extension $codename]		;#	And reset outcnts of various types
			switch -regexp -- $name_ext \
				^$evv(MONO_EXT)$  - \
				^$evv(SNDFILE_EXT)$	{incr sndsout -1 ; incr vwbl_sndsysout -1; incr smpsout -1} \
				^$evv(PSEUDO_EXT)$	{incr vwbl_sndsysout -1; incr smpsout -1} \
				^$evv(ANALFILE_EXT)$	{
					incr asndsout -1
					incr vwbl_sndsysout -1
					incr smpsout -1
				} \
				^$evv(PITCHFILE_EXT)$ - \
				^$evv(TRANSPOSFILE_EXT)$ - \
				^$evv(FORMANTFILE_EXT)$	- \
				^$evv(ENVFILE_EXT)$	{incr smpsout -1} \
				default {incr txtsout -1}

			incr prg_ocnt -1

			incr i 2								;#	Extract its true output name
			set fnam [string range $treeline $i end]
			if [file exists $fnam] {
				file stat $fnam filestatus
				if {$filestatus(ino) >= 0} {
					catch {close $filestatus(ino)}
				}										;#	And delete from system
				if [catch {file delete $fnam} zorg] {			
					set returnval 0
				} else {
					DeleteFileFromSrcLists $fnam
					PurgeArray $fnam
				}
			}
		}
	}
	if {$returnval == 0} {
		Inf "Failed to delete output files marked for deletion"
	}
	return $returnval
}

#############################################################
# DEVISING THE PROPERTY RESTRICTIONS ON INSTRUMENT INFILES	#
#############################################################

#------ Devise the property restrictions on infiles, from ins(conditions) params

proc DeviseInsConditions {} {
	global ins evv pr_ins

	if {[llength $ins(conditions)] == 0} {
		return 1
	}
	set i 0

	foreach this_props_set $ins(conditions) {	;#	Get the group of prm-sets assocd with the infile

		catch {unset tempprops}
		foreach props $this_props_set {				;#	Get each prm-set from the group
			set j 0
			foreach n $props {						;#	Get each prm in the set
				switch -- $j {
					0 { set pno $n }
					1 { set mno $n }	
					2 { set pos $n }
					default {
						incr j
						incr i
						ErrShow "Insufficient properties in propset $j for infile $i"
						return 0
					}
				}
				incr j
			}			
			if {$j < 3} {
				incr i
				ErrShow "Insufficient property-sets item ($j) for infile $i"
				return 0							;#	Generate the infile-conditions from the params
			}									 	;#	And append them in a list of conditions	for this infile
			set thisprops "[GetConditions $pno $mno $pos]"
			if {[string length $thisprops] <= 0} {
				return 0
			} else {
				set OK 1
				if [info exists tempprops] {
					foreach tprops $tempprops {
						if [string match $tprops $thisprops] {
							set OK 0
							break
						}
					}
				}
				if {$OK} {
					lappend tempprops $thisprops
				}
			}
		}											;#	Join these lists into a grand-list of conditions-for-all-infiles
		set ins(conditions) "[lreplace $ins(conditions) $i $i "$tempprops"]"
		incr i
	}
	return 1
}

#------ Type, or type-restrictions on infiles to ins-process

proc GetConditions {pno mno pos} {
	global evv
	set i 0

	switch -regexp -- $pno \
		^$evv(ENV_CREATE)$	 	-	\
		^$evv(MIXFORMAT)$	  	-	\
		^$evv(HOUSE_DISK)$	 	-	\
		^$evv(INFO_MUSUNITS)$	-	\
		^$evv(SYNTH_WAVE)$	 	-	\
		^$evv(SYNTH_NOISE)$	 	-	\
		^$evv(SYNTH_SIL)$		-	\
		^$evv(SYNTHESIZER)$	 	-	\
		^$evv(MULTI_SYN)$		-	\
		^$evv(UTILS_GETCOL)$	-	\
		^$evv(UTILS_PUTCOL)$	-	\
		^$evv(UTILS_JOINCOL)$	-	\
		^$evv(UTILS_COLMATHS)$	-	\
		^$evv(UTILS_COLMUSIC)$	-	\
		^$evv(UTILS_COLRAND)$	-	\
		^$evv(UTILS_COLLIST)$	-	\
		^$evv(UTILS_COLGEN)$	-	\
		^$evv(P_GEN)$	-	\
		^$evv(CLICK)$	-	\
		^$evv(ENVSYN)$	-	\
		^$evv(HOUSE_DEL)$		-	\
		^$evv(RMRESP)$			-	\
		^$evv(SYNFILT)$			-	\
		^$evv(STRANDS)$			-	\
		^$evv(FILTRAGE)$ {
			ErrShow "Should be no infiles or infileprops associated with process $pno mode $mno"
			return ""
		} \
		^$evv(MIXVAR)$	-	\
		^$evv(TRACK)$	-	\
		^$evv(WORDCNT)$ {
			ErrShow "Thisprocess ($pno) should not be operational"
			return ""
		} \
		^$evv(GAIN)$	  	-	\
		^$evv(LIMIT)$		-	\
		^$evv(BARE)$	  	-	\
		^$evv(CUT)$	  	 	-	\
		^$evv(SPEC_REMOVE)$ -	\
		^$evv(GRAB)$	  	-	\
		^$evv(MAGNIFY)$  	-	\
		^$evv(STRETCH)$  	-	\
		^$evv(TSTRETCH)$ 	-	\
		^$evv(ALT)$		  	-	\
		^$evv(OCT)$		  	-	\
		^$evv(SHIFTP)$  	-	\
		^$evv(TUNE)$	  	-	\
		^$evv(PICK)$	  	-	\
		^$evv(MULTRANS)$	-	\
		^$evv(CHORD)$	  	-	\
		^$evv(FILT)$	  	-	\
		^$evv(VFILT)$	  	-	\
		^$evv(GREQ)$	  	-	\
		^$evv(SPLIT)$	  	-	\
		^$evv(ARPE)$	  	-	\
		^$evv(PLUCK)$	  	-	\
		^$evv(S_TRACE)$  	-	\
		^$evv(BLTR)$	  	-	\
		^$evv(ACCU)$	  	-	\
		^$evv(EXAG)$	  	-	\
		^$evv(FOCUS)$	  	-	\
		^$evv(FOLD)$	  	-	\
		^$evv(FREEZE)$	 	-	\
		^$evv(STEP)$	  	-	\
		^$evv(AVRG)$	  	-	\
		^$evv(BLUR)$	  	-	\
		^$evv(SUPR)$	  	-	\
		^$evv(CHORUS)$  	-	\
		^$evv(DRUNK)$	  	-	\
		^$evv(SHUFFLE)$  	-	\
		^$evv(WEAVE)$	  	-	\
		^$evv(NOISE)$	  	-	\
		^$evv(SCAT)$	  	-	\
		^$evv(SPREAD)$  	-	\
		^$evv(SHIFT)$	  	-	\
		^$evv(GLIS)$	  	-	\
		^$evv(WAVER)$	  	-	\
		^$evv(WARP)$	  	-	\
		^$evv(INVERT)$  	-	\
		^$evv(PITCH)$	  	-	\
		^$evv(TRACK)$	  	-	\
		^$evv(FORMANTS)$ 	-	\
		^$evv(ONEFORM_GET)$ -	\
		^$evv(FORMSEE)$  	-	\
		^$evv(WINDOWCNT)$	-	\
		^$evv(CHANNEL)$  	-	\
		^$evv(FREQUENCY)$	-	\
		^$evv(LEVEL)$	  	-	\
		^$evv(OCTVU)$	  	-	\
		^$evv(PEAK)$	  	-	\
		^$evv(REPORT)$  	-	\
		^$evv(PRINT)$	  	-	\
		^$evv(PVOC_SYNTH)$	-	\
		^$evv(ANALENV)$ 	- 	\
		^$evv(PARTIALS_HARM)$ -	\
		^$evv(LUCIER_GETF)$ -	\
		^$evv(LUCIER_GET)$  -	\
		^$evv(SETHARES)$	-	\
		^$evv(FREEZE2)$	    -   \
		^$evv(SUPERACCU)$   -   \
		^$evv(SPECGRIDS)$	-   \
		^$evv(GLISTEN)$	 	-   \
		^$evv(SPECFOLD)$	-	\
		^$evv(TUNEVARY)$	 {
			switch -- $pos {
				0 { return "=$evv(IS_AN_ANALFILE)"}
				default {
					ErrShow "Incorrect infile position $pos for process $pno mode $mno"
					return ""
				}
			}
		} \
		^$evv(P_APPROX)$	-	\
		^$evv(P_EXAG)$	  	-	\
		^$evv(P_INVERT)$    -	\
		^$evv(P_QUANTISE)$  -	\
		^$evv(P_RANDOMISE)$ -	\
		^$evv(P_SMOOTH)$	-	\
		^$evv(P_TRANSPOSE)$ -	\
		^$evv(P_VIBRATO)$	-	\
		^$evv(P_CUT)$		-	\
		^$evv(P_FIX)$	  	-	\
		^$evv(P_INFO)$ 	  	-	\
		^$evv(P_ZEROS)$	  	-	\
		^$evv(P_HEAR)$	  	-	\
		^$evv(P_SYNTH)$	  	-	\
		^$evv(P_VOWELS)$	-	\
		^$evv(P_INSERT)$  	-	\
		^$evv(P_SINSERT)$  	-	\
		^$evv(P_PTOSIL)$  	-	\
		^$evv(P_NTOSIL)$  	-	\
		^$evv(P_INTERP)$  	-	\
		^$evv(P_BINTOBRK)$ 	-	\
		^$evv(PTOBRK)$ 	-	\
		^$evv(P_WRITE)$ {
			switch -- $pos {
				0	{return "=$evv(IS_A_PITCHFILE)"}
				default {
					ErrShow "Incorrect infile position $pos for process $pno mode $mno"
					return ""
				}
			}
		} \
		^$evv(ENV_RESHAPING)$	 -	\
		^$evv(ENV_ENVTOBRK)$	 -	\
		^$evv(ENV_ENVTODBBRK)$ {
			switch -- $pos {
				0	{return "=$evv(IS_AN_ENVFILE)"}
				default {
					ErrShow "Incorrect infile position $pos for process $pno mode $mno"
					return ""
				}
			}
		} \
		^$evv(ZIGZAG)$ 		  	-	\
		^$evv(LOOP)$ 		  	-	\
		^$evv(SCRAMBLE)$ 		-	\
		^$evv(ITERATE)$ 		-	\
		^$evv(ITERLINE)$ 		-	\
		^$evv(ITERLINEF)$ 		-	\
		^$evv(ITERATE_EXTEND)$ 	-	\
		^$evv(DRUNKWALK)$ 	  	-	\
		^$evv(GRAIN_COUNT)$     -	\
		^$evv(GRAIN_OMIT)$      -	\
		^$evv(GRAIN_DUPLICATE)$ -	\
		^$evv(GRAIN_REORDER)$	-	\
		^$evv(GRAIN_REPITCH)$	-	\
		^$evv(GRAIN_RERHYTHM)$  -	\
		^$evv(GRAIN_REMOTIF)$	-	\
		^$evv(GRAIN_TIMEWARP)$  -	\
		^$evv(GRAIN_GET)$		-	\
		^$evv(GRAIN_POSITION)$  -	\
		^$evv(GRAIN_REVERSE)$   -	\
		^$evv(ENV_EXTRACT)$	  	-	\
		^$evv(ENV_WARPING)$	  	-	\
		^$evv(ENV_DOVETAILING)$ -	\
		^$evv(ENV_CURTAILING)$  -	\
		^$evv(EXPDECAY)$		-	\
		^$evv(PEAKCHOP)$		-	\
		^$evv(ENV_SWELL)$		-	\
		^$evv(ENV_ATTACK)$	  	-	\
		^$evv(ENV_PLUCK)$		-	\
		^$evv(ENV_TREMOL)$	  	-	\
		^$evv(TREMOLO)$		  	-	\
		^$evv(EQ)$	   		  	-	\
		^$evv(LPHP)$	   	 	-	\
		^$evv(FSTATVAR)$	 	-	\
		^$evv(FLTBANKN)$	 	-	\
		^$evv(FLTBANKC)$	 	-	\
		^$evv(FLTBANKU)$	 	-	\
		^$evv(FLTBANKV)$	 	-	\
		^$evv(FLTBANKV2)$	 	-	\
		^$evv(FLTSWEEP)$	 	-	\
		^$evv(FLTITER)$ 	 	-	\
		^$evv(ALLPASS)$	 	  	-	\
		^$evv(MOD_PITCH)$		-	\
		^$evv(MOD_REVECHO)$	  	-	\
		^$evv(BRASSAGE)$		-	\
		^$evv(EDIT_CUT)$		-	\
		^$evv(EDIT_CUTMANY)$	-	\
		^$evv(SYLLABS)$			-	\
		^$evv(EDIT_CUTEND)$	  	-	\
		^$evv(EDIT_EXCISE)$	  	-	\
		^$evv(EDIT_EXCISEMANY)$ -	\
		^$evv(EDIT_INSERTSIL)$  -	\
		^$evv(HOUSE_COPY)$	  	-	\
		^$evv(HOUSE_CHANS)$	  	-	\
		^$evv(HOUSE_EXTRACT)$	-	\
		^$evv(TOPNTAIL_CLICKS)$	-	\
		^$evv(HOUSE_GATE)$		-	\
		^$evv(HOUSE_SPEC)$	  	-	\
		^$evv(HOUSE_RECOVER)$	-	\
		^$evv(INFO_TIMESUM)$	-	\
		^$evv(INFO_TIMEDIFF)$	-	\
		^$evv(INFO_SAMPTOTIME)$ -	\
		^$evv(INFO_TIMETOSAMP)$ -	\
		^$evv(INFO_MAXSAMP)$	-	\
		^$evv(INFO_MAXSAMP2)$	-	\
		^$evv(INFO_LOUDCHAN)$	-	\
		^$evv(INFO_FINDHOLE)$	-	\
		^$evv(INFO_DIFF)$		-	\
		^$evv(INFO_CDIFF)$	  	-	\
		^$evv(ACC_STREAM)$	  	-	\
		^$evv(STACK)$	  		-	\
		^$evv(INFO_PRNTSND)$	-	\
		^$evv(TIME_GRID)$		-	\
		^$evv(SEQUENCER)$		-	\
		^$evv(SHUDDER)$			-	\
		^$evv(DOUBLETS)$		-	\
		^$evv(BAKTOBAK)$		-	\
		^$evv(HOUSE_GATE2)$		-	\
		^$evv(GRAIN_ASSESS)$	-	\
		^$evv(ZCROSS_RATIO)$	-	\
		^$evv(PREFIXSIL)$		-	\
		^$evv(STRANS_MULTI)$	-	\
		^$evv(TAPDELAY)$		-	\
		^$evv(PEAKFIND)$		-	\
		^$evv(CONSTRICT)$		-	\
		^$evv(RMVERB)$			-	\
		^$evv(MCHANPAN)$  		-	\
		^$evv(FRAME)$			-	\
		^$evv(FLUTTER)$			-	\
		^$evv(ISOLATE)$			-	\
		^$evv(PACKET)$ 			-	\
		^$evv(SHRINK)$ 			-	\
		^$evv(CANTOR)$ 			-	\
		^$evv(NEWDELAY)$ 		-	\
		^$evv(ENVCUT)$ 			-	\
		^$evv(CERACU)$ {
			switch -- $pos {
				0	{return "=$evv(IS_A_SNDFILE)"}
				default {
					ErrShow "Incorrect infile position $pos for process $pno mode $mno"
					return ""
				}
			}
		} \
		^$evv(TAN_ONE)$ {
			switch -- $pos {
				0	{return "=$evv(IS_A_SNDFILE)"}
				default {
					ErrShow "Incorrect infile position $pos for process $pno mode $mno"
					return ""
				}
			}
		} \
		^$evv(TAN_TWO)$ {
			switch -- $pos {
				0	{return "MONO =$evv(IS_A_SNDFILE)"}
				1	{return "MONO =$evv(IS_A_SNDFILE)"}
				default {
					ErrShow "Incorrect infile position $pos for process $pno mode $mno"
					return ""
				}
			}
		} \
		^$evv(TRANSIT)$	  - \
		^$evv(TRANSITF)$  - \
		^$evv(TRANSITD)$  - \
		^$evv(TRANSITFD)$ - \
 		^$evv(TRANSITS)$  - \
		^$evv(TAN_SEQ)$ {
			return "MONO =$evv(IS_A_SNDFILE)"
		} \
 		^$evv(TRANSITL)$  - \
		^$evv(TAN_LIST)$ {
			switch -- $pos {
				0	{return "=$evv(IS_A_SNDLIST)"}
				default {
					ErrShow "Incorrect infile position $pos for process $pno mode $mno"
					return ""
				}
			}
		} \
		^$evv(PANORAMA)$ {
			return "MONO =$evv(IS_A_SNDFILE)"
		} \
		^$evv(MCHSHRED)$  {
			switch -- $mno {
				1 {
					switch -- $pos {
						0	{return "MONO =$evv(IS_A_SNDFILE)"}
						default {
							ErrShow "Incorrect infile position $pos for process $pno mode $mno"
							return ""
						}
					}
				}
				2 {
					switch -- $pos {
						0	{return "$evv(IS_A_SNDFILE)"}
						default {
							ErrShow "Incorrect infile position $pos for process $pno mode $mno"
							return ""
						}
					}

				}
			}
		} \
		^$evv(TOSTEREO)$ - \
		^$evv(MCHSTEREO)$ {
			switch -- $pos {
				0	{return "STEREO =$evv(IS_A_SNDFILE)"}
				default {
					ErrShow "Incorrect infile position $pos for process $pno mode $mno"
					return ""
				}
			}
		} \
		^$evv(EDIT_INSERT)$	  	-	\
		^$evv(EDIT_INSERT2)$ {
			switch -- $pos {
				0	{return "=$evv(IS_A_SNDFILE)"}
				1	{return "=$evv(IS_A_SNDFILE)"}
				default {
					ErrShow "Incorrect infile position $pos for process $pno mode $mno"
					return ""
				}
			}
		} \
		^$evv(NOISE_SUPRESS)$	 -	\
		^$evv(PVOC_ANAL)$		 -	\
		^$evv(PVOC_EXTRACT)$	 -	\
		^$evv(EDIT_ZCUT)$		 -	\
		^$evv(MANY_ZCUTS)$		 -	\
		^$evv(DISTORT_CYCLECNT)$ -	\
		^$evv(DISTORT)$ 		 -	\
		^$evv(DISTORT_ENV)$	   	 -	\
		^$evv(DISTORT_AVG)$	     -	\
		^$evv(DISTORT_OMT)$	     -	\
		^$evv(DISTORT_MLT)$	     -	\
		^$evv(DISTORT_DIV)$	     -	\
		^$evv(DISTORT_HRM)$	     -	\
		^$evv(DISTORT_FRC)$	     -	\
		^$evv(DISTORT_REV)$	     -	\
		^$evv(DISTORT_SHUF)$     -	\
		^$evv(DISTORT_RPT)$	     -	\
		^$evv(DISTREP)$			 -	\
		^$evv(DISTORT_RPT2)$	 -	\
		^$evv(DISTORT_RPTFL)$	 -	\
		^$evv(DISTORT_INTP)$	 -	\
		^$evv(DISTORT_DEL)$	     -	\
		^$evv(DISTORT_RPL)$	     -	\
		^$evv(DISTORT_TEL)$	     -	\
		^$evv(DISTORT_FLT)$	     -	\
		^$evv(DISTORT_PULSED)$	 -	\
		^$evv(DISTORT_PCH)$ 	 -	\
		^$evv(RRRR_EXTEND)$ 	 -	\
		^$evv(SSSS_EXTEND)$ 	 -	\
		^$evv(PSOW_STRETCH)$	-	\
		^$evv(PSOW_STRFILL)$	-	\
		^$evv(PSOW_FREEZE)$		-	\
		^$evv(PSOW_DUPL)$		-	\
		^$evv(PSOW_DEL)$		-	\
		^$evv(PSOW_FEATURES)$	-	\
		^$evv(PSOW_SYNTH)$		-	\
		^$evv(PSOW_SPLIT)$		-	\
		^$evv(PSOW_SPACE)$		-	\
		^$evv(PSOW_CHOP)$		-	\
		^$evv(PSOW_EXTEND)$		-	\
		^$evv(PSOW_EXTEND2)$	-	\
		^$evv(PSOW_LOCATE)$		-	\
		^$evv(PSOW_CUT)$		-	\
		^$evv(PSOW_REINF)$		-	\
		^$evv(GREV)$ 			-	\
		^$evv(MTON)$ 			-	\
		^$evv(MCHZIG)$ 			-	\
		^$evv(MCHITER)$ 		-	\
		^$evv(PARTITION)$		-	\
		^$evv(DISTCUT)$			-	\
		^$evv(GREV_EXTEND)$ {
			switch -- $pos {
				0	{return "MONO =$evv(IS_A_SNDFILE)"}
				default {
					ErrShow "Incorrect infile position $pos for process $pno mode $mno"
					return ""
				}
			}
		} \
		^$evv(PSOW_INTERP)$	 -	\
		^$evv(PSOW_INTERLEAVE)$	 -	\
		^$evv(PSOW_REPLACE)$ -	\
		^$evv(PSOW_IMPOSE)$ {
			switch -- $pos {
				0	{return "MONO =$evv(IS_A_SNDFILE)"}
				1	{return "MONO =$evv(IS_A_SNDFILE)"}
				default {
					ErrShow "Incorrect infile position $pos for process $pno mode $mno"
					return ""
				}
			}
		} \
		^$evv(FMNTSEE)$ {
			switch -- $pos {
				0	{return "=$evv(IS_A_FORMANTFILE)"}
				default {
					ErrShow "Incorrect infile position $pos for process $pno mode $mno"
					return ""
				}
			}
		} \
		^$evv(INFO_PROPS)$	-	\
		^$evv(INFO_SFLEN)$	-	\
		^$evv(INFO_TIMELIST)$ {
			switch -- $pos {
				0	{return "$evv(IS_A_SNDSYSTEM_FILE)"}
				default {
					ErrShow "Incorrect infile position $pos for process $pno mode $mno"
					return ""
				}
			}
		} \
		^$evv(HOUSE_DUMP)$	{
			return "$evv(IS_A_SNDSYSTEM_FILE)"
		} \
		^$evv(GRAIN_ALIGN)$ -	\
		^$evv(MIXTWO)$	  	-	\
		^$evv(MIXBALANCE)$	-	\
		^$evv(MIXCROSS)$	-	\
		^$evv(MIXINBETWEEN)$ -	\
		^$evv(CYCINBETWEEN)$ -	\
		^$evv(CONVOLVE)$ {
			switch -- $pos {
				0	{return "=$evv(IS_A_SNDFILE)"}
				1	{return "=$evv(IS_A_SNDFILE)"}
				default {
					ErrShow "Incorrect infile position $pos for process $pno mode $mno"
					return ""
				}
			}
		} \
		^$evv(DISTORT_INT)$ {
			switch -- $pos {
				0	{return "MONO =$evv(IS_A_SNDFILE)"}
				1	{return "MONO =$evv(IS_A_SNDFILE)"}
				default {
					ErrShow "Incorrect infile position $pos for process $pno mode $mno"
					return ""
				}
			}
		} \
		^$evv(GLIDE)$  	-	\
		^$evv(BRIDGE)$ 	-	\
		^$evv(MORPH)$  	-	\
		^$evv(VOCODE)$ 	-	\
		^$evv(SPECENV)$	-	\
		^$evv(SUM)$ 	-	\
		^$evv(DIFF)$	-	\
		^$evv(MEAN)$ 	-	\
		^$evv(CROSS)$ 	-	\
		^$evv(SPECSPHINX)$ - \
		^$evv(SPECTWIN)$ {
			switch -- $pos {
				0	{return "=$evv(IS_AN_ANALFILE)"}
				1	{return "=$evv(IS_AN_ANALFILE)"}
				default {
					ErrShow "Incorrect infile position $pos for process $pno mode $mno"
					return ""
				}
			}
		} \
		^$evv(SPECMORPH)$ {
			switch -- $pos {
				0	{return "=$evv(IS_AN_ANALFILE)"}
				1	{return "=$evv(IS_AN_ANALFILE)"}
				default {
					ErrShow "Incorrect infile position $pos for process $pno mode $mno"
					return ""
				}
			}
		} \
		^$evv(SPECMORPH2)$ {
			switch -- $pos {
				0	{return "=$evv(IS_AN_ANALFILE)"}
				default {
					ErrShow "Incorrect infile position $pos for process $pno mode $mno"
					return ""
				}
			}
		} \
		^$evv(ONEFORM_PUT)$	- \
		^$evv(FORM)$ {
			switch -- $pos {
				0	{return "=$evv(IS_AN_ANALFILE)"}
				1	{return "=$evv(IS_A_FORMANTFILE)"}
				default {
					ErrShow "Incorrect infile position $pos for process $pno mode $mno"
					return ""
				}
			}
		} \
		^$evv(ONEFORM_COMBINE)$	- \
		^$evv(MAKE)$ {
			switch -- $pos {
				0	{return "=$evv(IS_A_PITCHFILE)"}
				1	{return "=$evv(IS_A_FORMANTFILE)"}
				default {
					ErrShow "Incorrect infile position $pos for process $pno mode $mno"
					return ""
				}
			}
		} \
		^$evv(MAKE2)$ {
			switch -- $pos {
				0	{return "=$evv(IS_A_PITCHFILE)"}
				1	{return "=$evv(IS_A_FORMANTFILE)"}
				2	{return "=$evv(IS_AN_ENVFILE)"}
				default {
					ErrShow "Incorrect infile position $pos for process $pno mode $mno"
					return ""
				}
			}
		} \
		^$evv(LEAF)$		- \
		^$evv(MAX)$			- \
		^$evv(ANALJOIN)$	- \
		^$evv(SPECROSS)$	- \
		^$evv(LUCIER_PUT)$	- \
		^$evv(LUCIER_DEL)$  - \
		^$evv(SPECSLICE)$  {
			return "=$evv(IS_AN_ANALFILE)"
		} \
  		^$evv(SAUSAGE)$	 	-	\
  		^$evv(WRAPPAGE)$	-	\
 		^$evv(EDIT_JOIN)$	-	\
 		^$evv(JOIN_SEQ)$	-	\
 		^$evv(JOIN_SEQDYN)$	-	\
 		^$evv(MIXINTERL)$	-	\
		^$evv(SIMPLE_TEX)$ 	-	\
		^$evv(GROUPS)$ 	 	-	\
		^$evv(DECORATED)$  	-	\
		^$evv(PREDECOR)$ 	-	\
		^$evv(POSTDECOR)$  	-	\
		^$evv(ORNATE)$ 	 	-	\
		^$evv(PREORNATE)$  	-	\
		^$evv(POSTORNATE)$ 	-	\
		^$evv(MOTIFS)$ 	 	-	\
		^$evv(MOTIFSIN)$ 	-	\
		^$evv(TIMED)$		-	\
		^$evv(TGROUPS)$ 	-	\
		^$evv(TMOTIFS)$	 	-	\
		^$evv(TMOTIFSIN)$	-	\
		^$evv(TWIXT)$		-	\
		^$evv(HOUSE_BAKUP)$ -	\
		^$evv(MIXDUMMY)$ 	-	\
		^$evv(MULTIMIX)$ 	-	\
		^$evv(MIX_ON_GRID)$ -	\
		^$evv(MIX_AT_STEP)$ -	\
		^$evv(AUTOMIX)$ 	-	\
		^$evv(MIXMANY)$ 	-	\
		^$evv(SEQUENCER2)$ 	-	\
		^$evv(SEARCH)$		-	\
 		^$evv(MCHANREV)$ 	-	\
		^$evv(SPHINX)$  	-	\
		^$evv(REJOIN)$  	-	\
		^$evv(TEX_MCHAN)$	-	\
		^$evv(NEWTEX)$		-	\
		^$evv(SHIFTER)$		-	\
		^$evv(FRACTURE)$	-	\
		^$evv(MADRID)$ {
			return "=$evv(IS_A_SNDFILE)"
		} \
		^$evv(TRNSP)$ -	\
		^$evv(TRNSF)$ {
			switch -- $mno {
				1 -
				2 -
				3 {
					switch -- $pos {
						0	{return "=$evv(IS_AN_ANALFILE)"}
						default {
							ErrShow "Incorrect infile position $pos for process $pno mode $mno"
							return ""
						}
					}
				}
				4 {
					switch -- $pos {
						0 {return "=$evv(IS_AN_ANALFILE)"}
						1 {return "=$evv(IS_A_TRANSPOSFILE)"}
						default {
							ErrShow "Incorrect infile position $pos for process $pno mode $mno"
							return ""
						}
					}
				}
				default {
					ErrShow "Unknown mode in process $pno in GetConditions"
					return ""
				}
			}
		} \
		^$evv(ADDTOMIX)$ {
			switch -- $pno {
				0		{ return "$evv(IS_A_MIXFILE)"}
				default { return "$evv(IS_A_SNDFILE)"}
			}
		} \
  		^$evv(CLEAN)$ {
			switch -- $mno {
				1 -
				2 -
				3 {
					switch -- $pos {
						0 {return "=$evv(IS_AN_ANALFILE)"}
						1 {return "=$evv(IS_AN_ANALFILE)"}
						default {
							ErrShow "Incorrect infile position $pos for process $pno mode $mno"
							return ""
						}
					}
				}
				4 {
					switch -- $pos {
						0 {return "=$evv(IS_AN_ANALFILE)"}
						1 {return "=$evv(IS_AN_ANALFILE)"}
						2 {return "=$evv(IS_AN_ANALFILE)"}
						default {
							ErrShow "Incorrect infile position $pos for process $pno mode $mno"
							return ""
						}
					}
				}
				default {
					ErrShow "Unknown mode in process $pno in GetConditions"
					return ""
				}
			}
		} \
		^$evv(MOD_LOUDNESS)$ {
			switch -- $mno {
				1 -
				2 -
				3 -
				4 -
				6 {
					switch -- $pos {
						0	{return "=$evv(IS_A_SNDFILE)"}
						default {
							ErrShow "Incorrect infile position $pos for process $pno mode $mno"
							return ""
						}
					}
				}
				5 {
					switch -- $pos {
						0	{return "=$evv(IS_A_SNDFILE)"}
						1	{return "=$evv(IS_A_SNDFILE)"}
						default {
							ErrShow "Incorrect infile position $pos for process $pno mode $mno"
							return ""
						}
					}
				}
				7 -
				8 {
					return "=$evv(IS_A_SNDFILE)"
				}
				default {
					ErrShow "Unknown mode in process $pno in GetConditions"
					return ""
				}
			}
		} \
		^$evv(NEWGATE)$ {
			switch -- $pos {
				0	{return "=$evv(IS_A_SNDFILE)"}
				default {
					ErrShow "Incorrect infile position $pos for process $pno mode $mno"
					return ""
				}
			}
		} \
			^$evv(MOD_SPACE)$ {
			switch -- $mno {
				1 -
				2 -
				4 {
					switch -- $pos {
						0	{return "=$evv(IS_A_SNDFILE)"}
						default {
							ErrShow "Incorrect infile position $pos for process $pno mode $mno"
							return ""
						}
					}
				}
				3 {
					switch -- $pos {
						0	{return "$evv(IS_AN_UNRANGED_BRKFILE)"}
						default {
							ErrShow "Incorrect infile position $pos for process $pno mode $mno"
							return ""
						}
					}
				}
				default {
					ErrShow "Unknown mode in process $pno in GetConditions"
					return ""
				}
			}
		} \
		^$evv(SCALED_PAN)$ {
			switch -- $pos {
				0	{return "=$evv(IS_A_SNDFILE)"}
				default {
					ErrShow "Incorrect infile position $pos for process $pno"
					return ""
				}
			}
		} \
		^$evv(MOD_RADICAL)$ {
			switch -- $mno {
				1 -
				2 -
				3 -
				4 -
				5 {
					switch -- $pos {
						0	{return "=$evv(IS_A_SNDFILE)"}
						default {
							ErrShow "Incorrect infile position $pos for process $pno mode $mno"
							return ""
						}
					}
				}
				6 {
					switch -- $pos {
						0	{return "=$evv(IS_A_SNDFILE)"}
						1	{return "=$evv(IS_A_SNDFILE)"}
						default {
							ErrShow "Incorrect infile position $pos for process $pno mode $mno"
							return ""
						}
					}
				}
				default {
					ErrShow "Unknown mode in process $pno in GetConditions"
					return ""
				}
			}
		} \
		^$evv(ENV_IMPOSE)$  -	\
		^$evv(ENV_PROPOR)$  -	\
		^$evv(ENV_REPLACE)$ {
			switch -- $mno {
				1 {
					switch -- $pos {
						0	{return "=$evv(IS_A_SNDFILE)"}
						1	{return "=$evv(IS_A_SNDFILE)"}
						default {
							ErrShow "Incorrect infile position $pos for process $pno mode $mno"
							return ""
						}
					}
				}
				2 {
					switch -- $pos {
						0	{return "=$evv(IS_A_SNDFILE)"}
						1	{return "=$evv(IS_AN_ENVFILE)"}
						default {
							ErrShow "Incorrect infile position $pos for process $pno mode $mno"
							return ""
						}
					}
				}
				3 {
					switch -- $pos {
						0	{return "=$evv(IS_A_SNDFILE)"}
						1	{return "!$evv(MIX_MULTI) $evv(IS_A_NORMD_BRKFILE)"}
						default {
							ErrShow "Incorrect infile position $pos for process $pno mode $mno"
							return ""
						}
					}
				}
				4 {
					switch -- $pos {
						0	{return "=$evv(IS_A_SNDFILE)"}
						1	{return "$evv(IS_A_DB_BRKFILE)"}
						default {
							ErrShow "Incorrect infile position $pos for process $pno mode $mno"
							return ""
						}
					}
				}
				default {
					ErrShow "Unknown mode in process $pno in GetConditions"
					return ""
				}
			}
		} \
		^$evv(P_SEE)$ {
			switch -- $pos {
				0 {return "||$evv(IS_A_PITCHFILE) $evv(IS_A_TRANSPOSFILE)"}
				default {
					ErrShow "Incorrect infile position $pos for process $pno"
					return ""
				}
			}
		} \
		^$evv(REPITCH)$  - \
		^$evv(REPITCHB)$ {
			switch -- $mno {
				1 {
					switch -- $pos {
						0	{return "!$evv(MIX_MULTI) ||$evv(IS_A_PITCH_BRKFILE) =$evv(IS_A_PITCHFILE)"}
						1	{return "!$evv(MIX_MULTI) ||$evv(IS_A_PITCH_BRKFILE) =$evv(IS_A_PITCHFILE)"}
						default {
							ErrShow "Incorrect infile position $pos for process $pno mode $mno"
							return ""
						}
					}
				}
				2	{
					switch -- $pos {
						0	{return "!$evv(MIX_MULTI) ||$evv(IS_A_PITCH_BRKFILE) =$evv(IS_A_PITCHFILE)"}
						1	{return "!$evv(MIX_MULTI) ||$evv(IS_A_TRANSPOS_BRKFILE) =$evv(IS_A_TRANSPOSFILE)"}
						default {
							ErrShow "Incorrect infile position $pos for process $pno mode $mno"
							return ""
						}
					}
				}
				3	{
					switch -- $pos {
						0	{return "!$evv(MIX_MULTI) ||$evv(IS_A_TRANSPOS_BRKFILE) =$evv(IS_A_TRANSPOSFILE)"}
						1	{return "!$evv(MIX_MULTI) ||$evv(IS_A_TRANSPOS_BRKFILE) =$evv(IS_A_TRANSPOSFILE)"}
						default {
							ErrShow "Incorrect infile position $pos for process $pno mode $mno"
							return ""
						}
					}
				}
				default {
					ErrShow "Unknown mode in process $pno in GetConditions"
					return ""
				}
			}
		} \
		^$evv(MIX)$		  -	\
		^$evv(MIXMAX)$	  -	\
		^$evv(MIXGAIN)$	  -	\
		^$evv(MIXSHUFL)$  -	\
		^$evv(MIXTWARP)$  -	\
		^$evv(MIXSWARP)$  -	\
		^$evv(MIX_PAN)$  -	\
		^$evv(MIXTEST)$	{
			switch -- $pos {
				0 {return "$evv(IS_A_MIXFILE)"}
				default {
					ErrShow "Incorrect infile position $pos for process $pno mode $mno"
					return ""
				}
			}
		} \
		^$evv(MIXMULTI)$ {
			switch -- $pos {
				0 {return "=$evv(MIX_MULTI)"}
				default {
					ErrShow "Incorrect infile position $pos for process $pno mode $mno"
					return ""
				}
			}
		} \
		^$evv(MIXSYNC)$	 -	\
		^$evv(MIXSYNCATT)$ {
			switch -- $pos {
				0 {return "$evv(IS_MIX_OR_SNDLST_FIXSR)"}
				default {
					ErrShow "Incorrect infile position $pos for process $pno mode $mno"
					return ""
				}
			}
		} \
		^$evv(HOUSE_BUNDLE)$ {
			return "$evv(IS_ANYFILE)"
		} \
		^$evv(HOUSE_SORT)$ {
			ErrShow "This process should not be available in user instruments!"
			return ""
		} \
		^$evv(ENV_REPLOTTING)$ 	- \
		^$evv(ENV_BRKTOENV)$   	- \
		^$evv(ENV_BRKTODBBRK)$ {
			return "!$evv(MIX_MULTI) $evv(IS_A_NORMD_BRKFILE)"
		} \
		^$evv(ENV_DBBRKTOENV)$ 	- \
		^$evv(ENV_DBBRKTOBRK)$ {
			return "$evv(IS_A_DB_BRKFILE)"
		} \
 		^$evv(SPECLEAN)$ - \
 		^$evv(SPECTRACT)$ {
			switch -- $pos {
				0 {return "=$evv(IS_AN_ANALFILE)"}
				1 {return "=$evv(IS_AN_ANALFILE)"}
				default {
					ErrShow "Incorrect infile position $pos for process $pno mode $mno"
					return ""
				}
			}
		} \
		^$evv(PHASE)$ - \
		^$evv(CHANPHASE)$ -\
		^$evv(SILEND)$ {
			return "=$evv(IS_A_SNDFILE)"
		} \
		^$evv(BRKTOPI)$ {
			return "||$evv(IS_AN_UNRANGED_BRKFILE) $evv(IS_A_PITCH_BRKFILE)"
		} \
		default {
			ErrShow "Unknown processno in GetConditions"
			return ""
		}
	
}

#####################
# DRAWING THE TREE	#
#####################
				
#------ Ensure next infileno, is 1 more than previous

proc test30 {n max_fileno} {
	global tree evv pr_ins

	incr max_fileno
	if {$n != $max_fileno} {
		ErrShow "Error in infile indexing in tree"
		set pr_ins $evv(INS_ABORTED)
		return 0
	}
	return 1
}

#------ Ensure all files are counted in order from 0 (no skips)
#

proc test31 {max_fileno process_cnt} {
	global tree evv pr_ins
	if {$tree(files_icon_cnt) != $max_fileno} {
		ErrShow "Error in file indexing and counting"
		set pr_ins $evv(INS_ABORTED)
		return 0
	}
	if {$process_cnt <= 0} {
		ErrShow "Zero process count in tree decoding"
		set pr_ins $evv(INS_ABORTED)
		return 0
	}
	return 1
}

#------ Test for good tree-string format in input section

proc test32 {position_of_colon} {
	if {$position_of_colon < 0} {
		if {$position_of_colon < 0} {
			ErrShow "Bad Tree-string format: no ':'"
		}
		return 0
	}
	return 1
}

#------ Test for NUMERIC value for each input-file value

proc test33 {args} {
	foreach val $args {
		if {![regexp {^[0-9]+$} $val]} {
			ErrShow "Bad Tree-string format: Invalid input value '$val'"
			return 0
		}
	}
	return 1
}

#------ Check treeline output vals are (a) numeric (b) not previously used (c) in sequence

proc test35 {current_max_fileno args} {
	foreach val $args {
		if {![regexp {^[0-9]+$} $val]} {
			ErrShow "Bad Tree-string format: Invalid output value '$val'"
			return 0
		}
		if {$val <= $current_max_fileno} {					;#	Outfiles MUST be new
			ErrShow "Invalid outfile-number in tree: already used"
			return 0
		}
		incr current_max_fileno 
		if {$val != $current_max_fileno} {					;#	Outfiles MUST be in order
			ErrShow "Error in outfile indexing in tree"
			return 0
		}
	}
	return 1
}

#------ Test for good tree-filename format

proc test37 {position_of_colon} {
	if {$position_of_colon <= 0} {
		if {$position_of_colon < 0} {
			ErrShow "Bad Tree-Filename format: no ':'"
		} else {
			ErrShow "Bad Tree-Filename format: No base name for file"
		}
		return 0
	}
	return 1
}

#------ Test for existence of truname part of tree-filename

proc test38 {outputstring} {
	if {[string length $outputstring] <= 0} {
		ErrShow "Bad Tree-Filename format: No truname"
		return 0
	}
	return 1
}

#------ DISPLAYING INSTRUMENT AS TREE ON INSTRUMENT-DIALOG

proc DrawTree {can} {
	global ins tree only_looking evv

	catch {$can addtag treeparts all}
	catch {$can delete treeparts}
	
	set tree(process_cnt) [DecodeTreetextToTreePlan]			  ;#	p3 of orig notes
	if {$tree(process_cnt) <= 0} {
		return 0
	}
	if {![ReformLayoutandCodeGridPoints $can]} {
		return 0
	}
	if {![AssociateNamesWithGridpoints]} {
		return 0
	}
	if {![PutNamesOnTree $can]} {
		return 0
	}
	return 1
}

#------ Construct the tree-PLAN from the Data in Tree-File
#
#	1)	All NEW infiles (not recycled files) are placed on top line
#	2)	A process is placed on line BELOW bottom-most infile on display (files can be recycled)
#	3)	Outfiles are placed on line immediately below PROCESS
#

proc DecodeTreetextToTreePlan {} {
	global pr_ins evv ins tree only_looking
	global fpoint ppoint	;#	points on tree representing files & processes

	set process_cnt 0		;#	counts processes
	set max_fileno -1		
	set thisrow 0			;#	current row
	set tree(endcol) 0		;#	last column of current row
	set tree(all_endcols) 0	;#	List of last columns in each row
	set tree(endrow) 0		;#	Bottom-most row of display

	set tree(files_icon_cnt) 0
	if {$tree(process_cnt) <= 0} {
		ErrShow "No treedata exists yet: program error: DecodeTreetextToTreePlan{}"
		set pr_ins $evv(INS_ABORTED)
		return 0
	}
	catch {unset tree(inputs_to_each_process)}
	catch {unset tree(outputs_from_each_process)}

	foreach treefile_line $ins(tree) {
		set furthestrow 0
		catch {unset process_inputs}
		set i_cnt 0
		set n_list [InputsToProcess $treefile_line]
		if {[llength $n_list] > 0} {
			foreach n $n_list {		;#	POSITIONING INPUT FILES
				# TESTING CODE ONLY BELOW
				if {$n < 0} {
					set pr_ins $evv(INS_ABORTED)
					return 0
				}
				# TESTING CODE ONLY ABOVE

				if {$n > $max_fileno} {							;#	If file not already used, its NEW infile
					# TESTING CODE ONLY BELOW
					if {![test30 $n $max_fileno]} {
						return 0
					}
					# TESTING CODE ONLY ABOVE
					PutNewInfileOnTopLine $n					;#	Put it on top line
					incr tree(files_icon_cnt)
					set max_fileno $n							;#	Reset 'Count' of files
				}
				set thisrow $fpoint($n,row)						;#	Find row on which this infile occurs
				if {$thisrow > $furthestrow} {
					set furthestrow $thisrow					;#	Find bottom-most row on which any of infiles occurs
				}											
				lappend process_inputs $n						;#	List all inputs to this process
				incr i_cnt
			}
		} else {
			set process_inputs {}								;#	Create an empty list ?????PROGRAMMING??????
		}
		lappend tree(inputs_to_each_process) "$process_inputs"	;#	List of lists of the process inputs
		set thisrow $furthestrow
																;#	POSITIONING PROCESS-NAMES
		incr thisrow			   								;#	Move to line below bottom-most infile occurence
		set tree(endcol) [FindLastUnusedColumn $thisrow]
		# TESTING CODE ONLY BELOW
		if {$tree(endcol) < 0} {
			set pr_ins $evv(INS_ABORTED)
			return 0
		}
		# TESTING CODE ONLY ABOVE
		set ppoint($process_cnt,row) $thisrow					;#	Position the progname
		set ppoint($process_cnt,col) $tree(endcol)

		incr tree(endcol)										;#	Increment end-position in row
		set tree(all_endcols) "[lreplace $tree(all_endcols) $thisrow $thisrow $tree(endcol)]"
																;#	Increment ditto in STORE of end-positions

		incr thisrow											;#	Move to next row, to position outputs of process
		set tree(endcol) [FindLastUnusedColumn $thisrow]
		# TESTING CODE ONLY BELOW
		if {$tree(endcol) < 0} {
			set pr_ins $evv(INS_ABORTED)
			return 0
		}
		# TESTING CODE ONLY ABOVE
		catch {unset process_outputs}
		set o_cnt 0
		set n_list [OutputsFromProcess $treefile_line $max_fileno]
		if {[llength $n_list] > 0} {
			foreach n $n_list {			
				# TESTING CODE ONLY BELOW
				incr tree(files_icon_cnt)
				if {$n < 0} {
					set pr_ins $evv(INS_ABORTED)
					return 0
				}
				# TESTING CODE ONLY ABOVE
				set fpoint($n,row) $thisrow 					;#	Position output file, on this row
				set fpoint($n,col) $tree(endcol)				;#	In last column

				incr tree(endcol)								;#	Update endcolumn-no
				set tree(all_endcols) "[lreplace $tree(all_endcols) $thisrow $thisrow $tree(endcol)]"
				lappend process_outputs $n						;#	List of all outputs from this process
				incr o_cnt
			}
		} else {
			set process_outputs {}								;#	Create an empty list ?????PROGRAMMING??????
		}

		if {$o_cnt == 0 && $i_cnt == 0} {
			ErrShow "Process with no inputs or outputs specified: program error"
			set pr_ins $evv(INS_ABORTED)
			return 0
		}

		lappend tree(outputs_from_each_process) "$process_outputs"		
		set max_fileno $n										;#	List of lists of the process-outputs
		incr process_cnt										;#	'Count' files, Count tree-lines &, hence, processes
	}
	incr max_fileno
	# TESTING CODE ONLY BELOW
	if {![test31 $max_fileno $process_cnt]} {
		return 0
	}
	if {!$only_looking && ($tree(process_cnt) != $process_cnt)} {
		ErrShow "Error in counting processes: DecodeTreetextToTreePlan."
		return 0
	}
	# TESTING CODE ONLY ABOVE
	set tree(files_icon_cnt) $max_fileno

	return $process_cnt
}

#------ Relayout the tree, aesthetics!!

proc ReformLayoutandCodeGridPoints {can} {
	global fpoint ppoint tree
	set maxcol -1
	foreach val $tree(all_endcols) {
		if {$val > $maxcol} {
			set maxcol $val
		}
	}
	if {![AdjustTreeDisplayArea $maxcol $tree(endrow) $can]} {
		return 0
	}
	set i 0
	while {$i < $tree(process_cnt)} {
		set ppoint($i,col) [StaggerDisplay $ppoint($i,col) $maxcol [lindex $tree(all_endcols) $ppoint($i,row)]]
		incr i
	}
	set i 0
	while {$i < $tree(files_icon_cnt)} {
		set fpoint($i,col) [StaggerDisplay $fpoint($i,col) $maxcol [lindex $tree(all_endcols) $fpoint($i,row)]]
		incr i
	}

	return 1
}	
	# WE DON'T NEED TO CHANGE tree(all_endcols) AS IT'S NOT USED BEYOND HERE

#------ Associate File and Process Names with relevant Gridpoints
					
proc AssociateNamesWithGridpoints {} {
	global tree ins fpoint ppoint
	set i 0
	while {$i < $tree(files_icon_cnt)} {
		if {$ins(create)} {
			set truname [GetMCreateTruname [lindex $tree(fnams) $i]]
		} else {
			set truname [GetMRunTruname [lindex $tree(fnams) $i]]
		}
	 	# TESTING CODE ONLY BELOW
		if {[string length $truname] <= 0} {
			return 0
		}
	 	# TESTING CODE ONLY ABOVE
		set fpoint($i,name) $truname  
		incr i
	}
	set i 0
	while {$i < $tree(process_cnt)} {
		set ppoint($i,name) [lindex $tree(procnames) $i]  
		incr i
	}
	return 1
}

#------ Place names on tree
					
proc PutNamesOnTree {can} {
	global tree ins only_looking  
	
	ConvertToCanvasCoordinates
	DisplayLinklinesOnTree $can						;#	Do this first, so boxes overlay link-lines

	set i 0
	while {$i < $tree(process_cnt)} {
		DisplayProcessnameOnTree $i $can
		incr i
	}
	set i 0
	while {$i < $tree(files_icon_cnt)} {
		if {![DisplayFilenameOnTree $i $can]} {	;#	Filename is label, or an active button(for ins(create))
			return 0
		}
		incr i
	}
	if {$ins(create) && !$only_looking} {
		set i 0									;#	If creating ins
		while {$i < $tree(files_icon_cnt)} {	;#	Once display complete, activate buttons
			$can.ff$i.button config -state normal
			incr i
		}
	}
	return 1
}

#------ Return a list of file-inputs-to-the-process, on the given tree-item line

proc InputsToProcess {treefile_line} {
	set i [string first ":" $treefile_line]
	# TESTING CODE ONLY BELOW
	if {$i < 0} {
		ErrShow "Bad Tree-string format: no ':' in $treefile_line"
		return -1
	}
	# TESTING CODE ONLY ABOVE
	if {$i == 0} {
		return {}
	}		
	incr i -1
	set inputs [string range $treefile_line 0 $i]
	set invals [split $inputs ,]
	# TESTING CODE ONLY BELOW
	if {![eval {test33} $invals]} {
		return -1
	}
	# TESTING CODE ONLY ABOVE
	return $invals
}

#------ All NEW INPUT (rather than recycled) files are placed on TOP line
#
#	IMPORTANT: Position on top line used to calculate WHICH infile it is !!
#	Don't alter this layout procedure for New Infiles !!!
#
 
proc PutNewInfileOnTopLine {n} {
	global max_infileno tree fpoint
	set fpoint($n,row) 0								;#	Place on top row
	set tree(endcol) [lindex $tree(all_endcols) 0]		;#	Find endcolumn of top row
	set fpoint($n,col) $tree(endcol)					;#	Place there
	set fpoint($n,inno) $tree(endcol)					;#	Stores which newfile it is
	incr tree(endcol)									;#	Update endcolumn-no of top row
	set tree(all_endcols) "[lreplace $tree(all_endcols) 0 0 $tree(endcol)]"
}

#------ Find last (unused) column of current row

proc FindLastUnusedColumn {thisrow} {
	global tree
	if {$thisrow > $tree(endrow)} {								;#	IF THIS IS OFF THE DISPLAY SO-FAR
		incr tree(endrow)										;#	Enlarge row display by one
		# TESTING CODE ONLY BELOW
		if {$thisrow != $tree(endrow)} {
			ErrShow "Error in Row accounting"
			return -1
		}
		# TESTING CODE ONLY ABOVE
		set tree(endcol) 0										;#	Mark end of this row as 0
		lappend tree(all_endcols) 0								;#	Add to list of end-columns of rows
	} else {													;#	ELSE
		set tree(endcol) [lindex $tree(all_endcols) $thisrow]	;#	Find the end of this row
	}
	return $tree(endcol)
}

#------ Return a list of file-outputs-from-the-process, on the given tree-item line

proc OutputsFromProcess {treefile_line current_max_fileno} {
	global max_fileno

	set i [string first ":" $treefile_line]
	if {[string length [string range $treefile_line $i end]] <= 1} {	;#	No outputs
		return {}
	}
	incr i 1
	set outputstring [string range $treefile_line $i end]
	set outvals [split $outputstring ,]
	# TESTING CODE ONLY BELOW
	if {![eval {test35 $current_max_fileno} $outvals]} {
		return -1
	}
	# TESTING CODE ONLY ABOVE
	return $outvals
}

#------ Grow the canvas to fit the tree

proc AdjustTreeDisplayArea {maxcol maxrow can} {
	global tree only_looking icp evv
	incr maxrow					;#	Counting from 1 (not 0)

	set farcol $maxcol
	incr farcol					;#	Counting from 1 (not 0)
	incr farcol $maxcol			;#	farcol = (maxcol * 2) - 1	when display staggered
	incr farcol -1
	set resize_canvas 0
	set resize_w 0
	set resize_h 0
	set i 0
	set true_tree_width $evv(T_DISPLAY_XOFFSET)
#
#	while {$i < $farcol} {
#		incr true_tree_width $evv(T_CELLWIDTH)
#		incr i
#	}
#
	while {$i < $maxcol} {
		incr true_tree_width $evv(T_CELLWIDTH)
		incr true_tree_width $evv(T_HALF_CELLWIDTH)
		incr i
	}
	incr true_tree_width $evv(T_CELLWIDTH)

	set i 0
	set true_tree_height $evv(T_DISPLAY_YOFFSET)
	while {$i < $maxrow} {
		incr true_tree_height $evv(T_CELLHEIGHT)
		incr i
	}
	if {$true_tree_width > $tree(display_width)} {
		set tree(display_width) $true_tree_width
		set resize_canvas 1
		set resize_w 1
	}
	if {$true_tree_height > $tree(display_height)} {
		set tree(display_height) $true_tree_height
		set resize_canvas 1
		set resize_h 1
	}
	if {$resize_canvas} {
		update idletasks
#		tkwait visibility $can
		if [catch {$can config -scrollregion "0 0 $tree(display_width) $tree(display_height)"} in] {
			Inf "$in"
		}
		set xx [$can xview]
		set xx [expr 1.0 - [lindex $xx 1]]
		set vufracyx [expr double($evv(CANVAS_DISPLAYED_HEIGHT)) / double($tree(display_height))]
		if {$vufracyx > 1.0} {
			set vufracyx 1.0
		}
		if {$resize_w} {
			$can xview moveto $xx
			set vufracx [expr double($evv(CANVAS_DISPLAYED_WIDTH)) / double($tree(display_width))]
			set vufracx [expr 1.0 - $vufracx]
			if {$only_looking} {
				.machviewpage.tree.c.xscroll set $vufracx 1		;# config -command [list $can xview]
				.machviewpage.tree.c.yscroll set 0 $vufracyx    ;# config -command [list $can yview]
			} else {
				$icp.tree.tree.c.xscroll set $vufracx 1		;# config -command [list $can xview]
				$icp.tree.tree.c.yscroll set 0 $vufracyx    ;# config -command [list $can yview]
			}
		}		
		if {$resize_h} {
			set vufracy [expr 1.0 - $vufracyx]
			set yy [$can yview]
			set yy [expr 1.0 - [lindex $yy 1]]
			$can yview moveto $yy
			if {$only_looking} {
				.machviewpage.tree.c.xscroll set [lindex $xx 0] 1 ;# config -command [list $can yview]
				.machviewpage.tree.c.yscroll set $vufracy 1		  ;# config -command [list $can yview]
			} else {
				$icp.tree.tree.c.xscroll set [lindex $xx 0] 1 ;# config -command [list $can yview]
				$icp.tree.tree.c.yscroll set $vufracy 1		  ;# config -command [list $can yview]
			}
		}		
# ??? DESTROY AND RECREATE THE SCROLL-BARS ??

	}
	if {$resize_canvas \
	&& (($tree(display_width) > $evv(CANVAS_DISPLAYED_WIDTH)) \
	|| ($tree(display_height) > $evv(CANVAS_DISPLAYED_HEIGHT)))} {
		if {$only_looking} {
			.machviewpage.scroll.scr config -text "SCROLL TO VIEW  :  SCROLL TO VIEW  :  SCROLL TO VIEW"
		} else {
			$icp.tree.btns.scroll config -text "SCROLL TO VIEW  :  SCROLL TO VIEW  :  SCROLL TO VIEW"
		}
	} else {
		if {$only_looking} {
			.machviewpage.scroll.scr config -text ""
		} else {
			$icp.tree.btns.scroll config -text ""
		}
	}
;#	???? PROGRAMMING PROBLEM ???? what if the config fails (out of memory e.g.)

	return 1
}

#----- Stagger Display
#
#			ORIGVALS  	       *2					-1			+(maxval-origval)
#			|x| | | | 	| |x| | | | | | | 	|x| | | | | | | |	| | | |x| | | | |	
#			| |	| | | 	| | | | | | | | | 	| | | | | | | | | 	| | | | | | | | |
#			|x|x|x|x| 	| |x| |x| |x| |x| 	|x| |x| |x| |x| |	|x| |x| |x| |x| |	  
#			| |	| | |-->| | | | | | | | |-->| | | | | | | | |-->| | | | | | | | |
#			|x|x| | | 	| |x| |x| | | | | 	|x| |x| | | | | | 	| | |x| |x| | | |	
#			| |	| | | 	| | | | | | | | | 	| | | | | | | | | 	| | | | | | | | |
#			|x|x|x| | 	| |x| |x| |x| | | 	|x| |x| |x| | | | 	| |x| |x| |x| | |	
#

proc StaggerDisplay {thiscol maxcol thisrowmax} {
	incr thiscol							;#	Count from 1 (not 0)

	set stagger $maxcol
	incr stagger -$thisrowmax
	incr thiscol $thiscol					;#	*2
	incr thiscol -1							;#	-1
	incr thiscol $stagger					;#	+(maxcol-origcol)
	return $thiscol
}

#------ Extract truname of file, from filelisting, at Create-Ins stage

proc GetMCreateTruname {name} {
	set i [string first ":" $name]
	if {![test37 $i]} {
		return ""
	}
	incr i
	set truname [string range $name $i end]
	if {![test38 $truname]} {
		return ""
	}
	return $truname
}
	
#------ Extract truname of file, from filelisting, at Run-Ins stage

proc GetMRunTruname {name} {
	set deletable 0
	if [regexp {^in} $name] {		 	
		return $name
	} else {
		if [regexp {^del} $name] {		;#	deletable file
			set deletable 1
		}								
		set i [string first ":" $name]	;#	get truname
		if {![test37 $i]} {
			return ""
		}
		incr i
		set truname [string range $name $i end]
		if {![test38 $truname]} {
			return ""
		}
	}
	if {$deletable} {
		set newname "#"					;#	add additional marker to deletable file
		append newname $truname
		return $newname
	}
	return $truname
}
	
#------ Convert From Grid coords to Canvas coords

proc ConvertToCanvasCoordinates {} {
	global tree fpoint ppoint
	set i 0
	while {$i < $tree(files_icon_cnt)} {
		set fpoint($i,crow) [ConvertToGridYcoord $fpoint($i,row)]	;#	Calculate coords on canvas
		set fpoint($i,col) [ConvertToGridXcoord $fpoint($i,col) [lindex $tree(all_endcols) $fpoint($i,row)]]
		incr i
	}
	set i 0
	while {$i < $tree(process_cnt)} {
		set ppoint($i,crow) [ConvertToGridYcoord $ppoint($i,row)]	;#	Calculate coords on canvas
		set ppoint($i,col) [ConvertToGridXcoord $ppoint($i,col) [lindex $tree(all_endcols) $ppoint($i,row)]]
		incr i
	}
}

#------ Display linking lines on tree

proc DisplayLinklinesOnTree {c} {
	global tree fpoint ppoint evv
	set i 0
	set pno 0

	set i_length [llength $tree(inputs_to_each_process)]
	set o_length [llength $tree(outputs_from_each_process)]

	while {$pno < $tree(process_cnt)} {									 ;#	For each process
		if {$i_length > $pno} {											 ;#	For each INPUT to that process
			foreach fno [lindex $tree(inputs_to_each_process) $pno] {	 ;#	(inputs_to_each_process) is a list of lists
				catch {unset coords}								 	
				lappend coords $fpoint($fno,col) [expr $fpoint($fno,crow) + $evv(T_ARROW_OFFSET)]
																		 ;#	position of file-name
				set arrow_end [expr int($ppoint($pno,crow) - $evv(T_ARROW_OFFSET))]
				set in_c [Interp_c $fpoint($fno,crow) $arrow_end $fpoint($fno,col) $ppoint($pno,col)] 
																		 ;#	interpolated point
				set coords [concat $coords $in_c]
				lappend coords $ppoint($pno,col) $arrow_end				 ;#	point above position of process-name
																		 ;#	Interpolated point not on straight line
	#	(See example pp 403 for use of {} with eval, below)

				eval {$c create line} $coords \
					{-arrow last -fill black -smooth true -width $evv(TREELINE_WIDTH)}
			}															 ;#	Creates (splined) curve
		}
		if {$o_length > $pno} {											 ;#	For each OUTPUT to that process
			foreach fno [lindex $tree(outputs_from_each_process) $pno] { ;#	(outputs_from_each_process) is a list of lists
				catch {unset coords}								
				lappend coords $ppoint($pno,col) [expr $ppoint($pno,crow) + $evv(T_ARROW_OFFSET)]
																		 ;#	position of process-name
				set arrow_end [expr int($fpoint($fno,crow) - $evv(T_ARROW_OFFSET))]
				set in_c [Interp_c $ppoint($pno,crow) $arrow_end $ppoint($pno,col) $fpoint($fno,col)] 		 
																		 ;#	interpolated point
				set coords [concat $coords $in_c]
				lappend coords $fpoint($fno,col) $arrow_end				 ;#	point above position of file-name
				eval {$c create line} $coords \
					{-arrow last -fill black -smooth true -width $evv(TREELINE_WIDTH)}
			}															 ;#	Creates (splined) curve
		}
		incr pno
	}
}

#------ Produce midpoint of curved arc

proc Interp_c {row1 row2 col1 col2} {
	global evv
	set distance_across_grid $col2
	incr distance_across_grid -$col1
	set y [expr round(double($row1 + $row2) / 2)]		;#	halfway down
	set x [expr double($distance_across_grid / 2)]		;#	half distance across
	if {[Flteq $x 0.0]} {
		set x [expr round(($row2 - $row1) * $evv(T_VERTL_OFFSET))]
	} else {
		set x [expr round($x * $evv(T_CURVE_OFFSET))] 	;#	Crude!!
	}
	incr x $col1		
	lappend x $y
	return $x
}

#------ Display Processname On Tree

proc DisplayProcessnameOnTree {procno c} {
	global ppoint evv
	
	set proctext "\("
	set proctextno $procno
	incr proctextno
	append proctext $proctextno "\) " $ppoint($procno,name)
	catch {destroy $c.pp$procno}
	set f [frame $c.pp$procno -borderwidth 0]			;#	CREATE A LABEL, in a window, on the canvas
	$c create window $ppoint($procno,col) $ppoint($procno,crow) -anchor c -window $f
	button $f.label -text $proctext -justify center -width $evv(T_NAME_WIDTH) -font treefnt -command {} -highlightbackground [option get . background {}]
	pack $f.label -side top -fill both				
}

#------ Display Filename On Tree

proc DisplayFilenameOnTree {fileno c} {
	global ins fpoint evv pr_ins treefnt treedeletefnt pa tree only_looking

	set thisfnt treekeyfnt							  ;#	FONT
	if {$only_looking} {
		set fnam [lindex $tree(fnams) $fileno]
		set codename $fnam
		set truname $fnam
		set j [string first ":" $fnam]
		if {$j >= 0} {
			incr j 1
			set truname [string range $fnam $j end]
			incr j -2
			set codename [string range $codename 0 $j]
		}
		set file_ext [file extension $codename]			;#	COLOR
		switch -regexp -- $file_ext \
			^$evv(MONO_EXT)$ 			{set bkgd $evv(MONO_TC)} \
			^$evv(SNDFILE_EXT)$ 		{set bkgd $evv(SOUND_TC)} \
			^$evv(PSEUDO_EXT)$ 			{set bkgd $evv(PSEUDO_TC)} \
			^$evv(ANALFILE_EXT)$		{ set bkgd $evv(ANALYSIS_TC) } \
			^$evv(PITCHFILE_EXT)$ 		{ set bkgd $evv(PITCH_TC) } \
			^$evv(TRANSPOSFILE_EXT)$ 	{ set bkgd $evv(TRANSPOS_TC) } \
			^$evv(FORMANTFILE_EXT)$  	{ set bkgd $evv(FORMANT_TC) } \
			^$evv(ENVFILE_EXT)$ 	 	{ set bkgd $evv(ENVELOPE_TC) } \
			default {set bkgd $evv(TEXT_TC)}


		if [regexp {^del} $codename] {						;#	File marked for deletion
			set thisfnt treedeletefnt						;#	FONT Distinguishes kept from deleted files
		}													
		set fnam $truname
	} else {
		set fnam $fpoint($fileno,name)					;#	(NB only truname is stored in fpoint(m,name))
		set ftype $pa($fnam,$evv(FTYP))
		set chans $pa($fnam,$evv(CHANS))
		if {$ftype & $evv(IS_A_TEXTFILE)} { 
			set bkgd $evv(TEXT_TC)
		} else {
			switch -regexp -- $ftype \
				^$evv(SNDFILE)$ {
					if {$chans == 1} { 
						set bkgd $evv(MONO_TC)
					} else { 
						set bkgd $evv(SOUND_TC)
					}
				} \
				^$evv(PSEUDO_SND)$ 		{ set bkgd $evv(PSEUDO_TC) } \
				^$evv(ANALFILE)$		{ set bkgd $evv(ANALYSIS_TC) } \
				^$evv(PITCHFILE)$ 		{ set bkgd $evv(PITCH_TC) } \
				^$evv(TRANSPOSFILE)$ 	{ set bkgd $evv(TRANSPOS_TC) } \
				^$evv(FORMANTFILE)$  	{ set bkgd $evv(FORMANT_TC) } \
				^$evv(ENVFILE)$ 	 	{ set bkgd $evv(ENVELOPE_TC) } \
				default {
					ErrShow "Unknown file extension: DisplayFilenameOnTree{}"
					set pr_ins $evv(INS_ABORTED)
					return 0
				}

		}													
	}													;#	DISPLAYED-TEXT
	if [string match \#* $fnam] {
		set fnam [string range $fnam 1 end]		;#	Strip off the leading '#'
	}
	set fnam [file rootname $fnam]				;#	And the extension (colorcoding instead!!)				
	set lenxs [expr [string length $fnam] - $evv(T_NAME_WIDTH)]
	if {$lenxs > 0} {									;#	And curtail over-long filenames
		set zfnam "~"
		append zfnam [string range $fnam $lenxs end]
		set fnam $zfnam
	}

	catch {destroy $c.ff$fileno}
	set f [frame $c.ff$fileno -borderwidth 0]			;#	CREATE A BUTTON, in a window, on the canvas
	$c create window $fpoint($fileno,col) $fpoint($fileno,crow) -anchor c -window $f
	button $f.button -text $fnam -justify center \
		-width $evv(T_NAME_WIDTH) -bg $bkgd \
		-activebackground $evv(T_ACTIVEBKGD) -activeforeground $evv(T_ACTIVEFGND) \
		-command "ListSelectedMTreeFile $fileno" -state disabled -font $thisfnt -highlightbackground [option get . background {}]
														;#	Button puts assocd filename, on filename listing
	pack $f.button -side top -fill both					;#	Disable buttons until ALL are displayed!!

	return 1
}

#------ Get a file from existing tree, to infile listing, (AND note its type!!)

proc ListSelectedMTreeFile {fileno} {
	global ins_file_lst fpoint tree evv

	if {[LstIndx $fpoint($fileno,name) $ins_file_lst] < 0} {
		$ins_file_lst insert end $fpoint($fileno,name)
		if {$fpoint($fileno,row) == "0"} {	;#	IF input-file, note its fileno AND its infile-no
			lappend tree(filetype) "$evv(PREVIOUS_INFILE) $fileno $fpoint($fileno,inno)"
		} else {							;#	IF output-file, note its fileno
			lappend tree(filetype) "$evv(PREVIOUS_OUTFILE) $fileno"
		}
	} else {
		Inf "File '$fpoint($fileno,name)' is already listed."
	}
}

#------ Grid x-coord to Canvas x-coord

proc ConvertToGridXcoord {x row_entries} {
	global evv
	set newx $evv(T_DISPLAY_XOFFSET)
	set i 0
	if [IsEven $row_entries] {
		set swich 1
		incr newx -$evv(T_QUARTER_CELLWIDTH)
	} else {
		set swich 0
	}
	while {$i < $x} {
		if {$swich} {
			incr newx $evv(T_CELLWIDTH)
		} else {
			incr newx $evv(T_HALF_CELLWIDTH)
		}
		set swich [expr !($swich)]
		incr i
	}
	return $newx
}

#------ Grid y-coord to Canvas y-coord

proc ConvertToGridYcoord {y} {
	global evv
	set newy $evv(T_DISPLAY_YOFFSET)
	set i 0
	while {$i < $y} {
		incr newy $evv(T_CELLHEIGHT)
		incr i
	}
	return $newy
}

#########################
# CREATING INSTRUMENTS	#
#########################

#------ INSTRUMENTS (=BATCHFILES)
#
#	Set up flag for creating ins: Set up counter for processes used in ins
#	disable selection of existing Instruments, disable 'newfile' on Dlg_Process_and_Ins_Menus page
#
#	|-------------------------------|----------|
# 	| ----  ----  ----		  ----	| ---  --- |
#	||Cont||Conc||A   |		 |New |	||Cl ||Del||
#	||inue||lude||bort|		 |File|	||ear||ete||
#	| ----  ----  ----		  ----	| ---  --- |
#	|-------------------------------|----------|
#	|KEY (Color key to tree)		| listing  |
#	|-------------------------------|		   |
#	|		 -    -					| 		   |
#	|		 -    -					| 		   |
#	|		|1|	 |2|				|		   |
#	|		 -	  -					|		   |
#	|		 |	/					|		   |
#	|		 |/						|		   |
#	|	     ------					|		   |
#	|		|interp|				|		   |
#	|		 ------					|		   |
#									|		   |
#

proc CreateIns {} {
	global ins hst tree	ins_rethink ins_aborted baktrak pr_zog shortwindows
	global destroy_newfile_window mach ins_file_lst ins_creation from_mcreate
	global pr_ins tree inspage_emph ins_concluding evv pvoc_warn icp small_screen
	global last_outfile zaz_dummy dupl_mix dupl_vbx dupl_txt panprocess real_chlist thumbnailed

	if {[ArePhysModFiles 0]} {
		return
	}
	if {$dupl_mix || $dupl_vbx || $dupl_txt} {
		Inf "There Are Duplicated Files On The Chosen Files List: Cannot Proceed"
		return
	}
	if {[info exists panprocess] || [info exists real_chlist] || [info exists thumbnailed]} {
		return
	}

	set pvoc_warn 0
	catch {unset ins(name)}
	set pr_zog 0
	set tree(files_icon_cnt) 0
	set ins(thisprocess_finished) 0
	set ins(create) 1			   			;#	Flagup ins is being created
	set ins(process_cnt) 0		   			;#	Reset ins-process counter
												;#	Rootname evv(MACH_OUTFNAME)0_ for all outfiles of process 0
	catch {unset hst(ins_infiles)}		;#	Clear previous local hst data
	catch {unset hst(ins_params)}

	set ins_creation 1						;#	DISABLE GET-FILES BUTTON ON DIALOG_PROCESS_AND_INSTRUMENT_MENUS
												;#	if it exists
												;#	DISABLE SELECTION OF EXISTING INSTRUMENTS, if necessary
	if {($ins(cnt) > 0) && [winfo exists .menupage] && [info exists mach]} {			   		
		$mach.btns.run config -state disabled	;#	i.e. no nested Instruments allowed
	}
	set fnam [file join $evv(CDPRESOURCE_DIR) $evv(FIRSTINS)$evv(CDP_EXT)]
	if {![file exists $fnam]} {
		InsMsg
		if [catch {open $fnam "w"} zit] {
			Inf "Cannot create file '$fnam' to remember that you have seen this message."
		} else {
			close $zit
		}
	}
												
	if [catch {eval {toplevel .inspage} -borderwidth $evv(BBDR)} zorg] {
		ErrShow "Failed to establish Instrument Creation Window"
		set ins(create) 0
	}
	wm protocol .inspage WM_DELETE_WINDOW "set pr_ins $evv(INS_ABORTED)"
	wm title .inspage "Instrument Creation"

	if {[info exists shortwindows] || $small_screen} {
		set can [Scrolled_Canvas .inspage.c -width $evv(SMALL_WIDTH) -height $evv(SMALL_HEIGHT) \
							-scrollregion "0 0 $evv(INSCRE_WIDTH) $evv(SCROLL_HEIGHT)"]
		pack .inspage.c -side top -fill x -expand true
		set f [frame $can.f -bd 0]
		$can create window 0 0 -anchor nw -window $f
		set icp $f
	} else {
		set icp .inspage
	}	

	set help [frame $icp.help -borderwidth $evv(SBDR)]
	button $help.hlp -text Help -command "ActivateHelp $icp.help" -width 4  -highlightbackground [option get . background {}];# -bg $evv(HELP)
	label  $help.conn -text "" -width 13
	button $help.con -text "" -borderwidth 0 -state disabled -width 8 -highlightbackground [option get . background {}]
	label  $help.help -width 84 -text "$evv(HELP_DEFAULT)" -fg [option get . foreground {}]
	if {$evv(NEWUSER_HELP)} {
		button $help.starthelp -text "New User Help" -command "GetNewUserHelp ins"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
	}
	button $help.tips -text "Tips" -command "Tips ins" -width 4  -highlightbackground [option get . background {}];# -bg $evv(HELP)
	button $help.quit -text "End Session" -command "DoWkspaceQuit 0 0"  -highlightbackground [option get . background {}];# -bg $evv(QUIT_COLOR)
	bind $icp <Control-Command-Escape> "DoWkspaceQuit 0 0"
	bind $icp <Escape> "InsCreationEscape"
	bind $icp <Return> "InsCreationReturn"
#MOVED TO LEFT
	pack $help.quit -side left
	if {$evv(NEWUSER_HELP)} {
		pack $help.hlp $help.conn $help.con $help.help $help.starthelp $help.tips -side left
	} else {
		pack $help.hlp $help.conn $help.con $help.help $help.tips -side left
	}
#MOVED TO LEFT
#	pack $help.quit -side right

	set mmt [frame $icp.tree  -borderwidth $evv(SBDR)]  	;#	Frames for tree-display, and for filelist-display
	set mmf [frame $icp.files -borderwidth $evv(SBDR)]

	set mmtb [frame $mmt.btns -borderwidth $evv(SBDR)]	;#	Frames in tree-display for buttons and for tree
	set mmtk [frame $mmt.key  -borderwidth $evv(SBDR)]
	set mmtt [frame $mmt.tree -borderwidth $evv(SBDR)]
		
	set mmfb [frame $mmf.btns -borderwidth $evv(SBDR)]	;#	Frames in filelist-display for buttons and for filelist
	set mmfl [frame $mmf.filelist -borderwidth $evv(SBDR)]

	set mmfq [frame $mmf.nameslist -borderwidth $evv(SBDR)]

	set mmfb1 [frame $mmfb.1 -borderwidth $evv(SBDR)]
	set mmfb2 [frame $mmfb.2 -borderwidth $evv(SBDR)]
	set mmfb3 [frame $mmfb.3 -borderwidth $evv(SBDR)]
	set mmfb4 [frame $mmfb.4 -borderwidth $evv(SBDR)]
	pack $mmfb.3 $mmfb.2 $mmfb.1 $mmfb.4 -side top
												;#	Buttons in tree-display
	
	button $mmtb.continue -text "Make Instrument" -width 13 -command "ContinueIns" -bg $evv(EMPH) -highlightbackground [option get . background {}]
	set inspage_emph $mmtb.continue
	button $mmtb.conclude -text "Conclude" -command "set pr_zog 1 ; ConcludeIns" -highlightbackground [option get . background {}]
	label  $mmtb.scroll   -text "" -width 60 -fg $evv(SPECIAL)
	button $mmtb.abort    -text "Abort"    -command "set pr_zog 0 ; set pr_ins $evv(INS_ABORTED)" -highlightbackground [option get . background {}]
	pack $mmtb.continue $mmtb.conclude $mmtb.scroll -side left
	pack $mmtb.abort -side right

												;#	Buttons in filelist-display
	
	button $mmfb1.clear  -text  "Clear Choice"  -command "ClearInsInfileListing" 	-width 10 -highlightbackground [option get . background {}]
	button $mmfb1.newfile -text "Choose Files" -command "GetNewFile ; set pr_zog 1" -width 10 -bg $evv(EMPH) -highlightbackground [option get . background {}]
	lappend inspage_emph $mmfb1.newfile
	button $mmfb2.props -text "Properties" -command "Show_Props ins_file_lst 0" -width 10 -highlightbackground [option get . background {}]
	button $mmfb2.pl    -text "Play Srcs" -command "set from_mcreate 1; PlayOutput 0" -width 10 -highlightbackground [option get . background {}]

	label $mmfb3.lab -text "CHOSEN FILES"
	button $mmfb4.ro -text "Reverse Order" -command "FlipList ins" -width 13 -highlightbackground [option get . background {}]
	pack $mmfb2.pl $mmfb2.props -side left 
	pack $mmfb1.clear -side left
	pack $mmfb1.newfile -side right
	pack $mmfb3.lab -side top
	pack $mmfb4.ro -side top

#	DisplayTreeColorKey $mmtk					;#	Creates ColorKey to canvas
												;#	Creates Canvas and draws current ins-tree on it

	set can [Scrolled_Canvas $mmtt.c -width $evv(CANVAS_DISPLAYED_WIDTH) \
									-height $evv(CANVAS_DISPLAYED_HEIGHT) \
									-scrollregion "0 0 $evv(CANVAS_DISPLAYED_WIDTH) $evv(SCROLL_HEIGHT)"]

	pack $mmtt.c -fill both -expand true
												;#	Creates Scrolled Listbox for selected files
												
	set ins_file_lst [Scrolled_Listbox $mmfl.mlist -width 24 -height 15 -selectmode single]
	pack $mmfl.mlist -side top -fill both

	pack $icp.help -side top -fill both
	pack $mmt.btns $mmt.key $mmt.tree -side top -fill x
	pack $mmf.btns $mmf.filelist $mmf.nameslist -side top -fill x
	pack $icp.files $icp.tree -side left -fill both

	tkwait visibility $can
	set tree(display_width) [winfo width $icp.tree.tree.c]
	set tree(display_height) [winfo height $icp.tree.tree.c]

	bind $ins_file_lst <ButtonRelease-1> {RemovefromInsInfileListing}	

	InitialiseTreeDataAndInsInfileListing	;#	Set up start situation in tree (infiles only)
	 											;#	List the files previously selected on wkspace page
	bind $icp <Control-Key-p> {UniversalPlay icp 0}
	bind $icp <Control-Key-P> {UniversalPlay icp 0}
	bind $icp <Key-space> {UniversalPlay icp 0}

	catch {set remem_last_outfile $last_outfile}
	catch {unset last_outfile}
	set pr_ins $evv(INS_CONTINUES)
	raise .inspage
	update idletasks
	StandardPosition .inspage
	My_Grab 0 .inspage pr_ins
	while {$pr_ins == $evv(INS_CONTINUES)} {
		tkwait variable pr_ins
												 #	COMPLETED or ABORTED:Quit dialog
		switch -regexp -- $pr_ins \
			$evv(INS_COMPLETED) -	\
			$evv(INS_ABORTED) 	{}	\
			$evv(INS_CONTINUES) {							;#	Instrument sets out to run process
				set ins_rethink 0
				set ins_aborted 0
				while {1} {
					if {$pvoc_warn} {
						ErrShow "You cannot make an instrument\nwhich follows VARIABLE parameters in PVOC ANALYSIS\nwith another process"
						set pr_ins $evv(INS_ABORTED)
						break					
					}
					GotoGetAProcess								;#	Runs process as normal (collecting data en route)
					if {$ins_rethink} {
						set tree(process_cnt) 	 $baktrak(process_cnt)
						set ins(process_cnt) 	 $baktrak(mprocess_cnt)
						set tree(file_index) 	 $baktrak(file_index)
						set tree(infile_counter) $baktrak(infile_counter)
						break
					}
					if {$ins_aborted} {
						set pr_ins $evv(INS_ABORTED)
					}
					if {$pr_ins == $evv(INS_ABORTED)} { ;# 	IF PROCESS FAILED FATALLY
			 			break							;#	or was killed off :	Quit dialog
					}												
					$icp.tree.btns.continue config -text "Continue"
					if {$ins(process_cnt) == 1} {
						$icp.tree.btns.conclude config -bg $evv(EMPH)
						lappend inspage_emph $icp.tree.btns.conclude
					}
					raise .inspage
					wm title .inspage "Instrument Creation" 			
					if {![DrawTree $can] } {					;#	Redraw current state of ins-tree
						set pr_ins $evv(INS_ABORTED)
					}
	 				if {$pr_ins == $evv(INS_ABORTED)} { ;#	IF PROCESS FAILED FATALLY  	  :	Quit dialog
			 			break					
					}
					ReconfigInsHelp
					break
				}
			}
		
	}
	if {![info exists tree(fnams)]} {					;#	Concluded without chosing a process
		set pr_ins $evv(INS_ABORTED)
	}
	if {$pr_ins != $evv(INS_ABORTED)} {
		set pr_ins $evv(INS_COMPLETED)
		set tree(filecnt) [llength $tree(fnams)]
		if {$tree(outfile_counter) <= 0} {				   	;#	If there are output files
			DisableInsWindow $can $mmfb $mmtb
		} else {
			set ins_concluding 1
			RestructureInsWindow .inspage $mmtb $mmfb $mmfq $can	;#	Restructure window to save (or play or see) files
			tkwait variable pr_ins
		}
	}
	if {$pr_ins != $evv(INS_ABORTED)} {
		wm title .inspage "Instrument Being Completed"
		if {![DeviseInsConditions]} {		;#	Convert processno,modeno, and infileno to conditions on infiles
			set pr_ins $evv(INS_ABORTED)
		}
	}
	if {$pr_ins != $evv(INS_ABORTED)} {
		ReclassifyFilenames						;#	Mark files as saved or deleted ETC: 
												;#	also note where MONO (etc???) is necessitated by process(es)
												;#	And add count-of-infiles-to-ins to ins(infilecnts)
		set ins(name) [GetAcceptableInsName]
		if {$pr_ins != $evv(INS_ABORTED)} {
			SaveInsInfo
		}
	}
	set destroy_newfile_window 1				;#	set flag to destroy listing of possible-newfiles-for-ins
												;#	(files on workspace may change before next call to CreateIns)
	RestoreInslessSystem
	set ins(create) 0
	set ins_concluding 0
	if {[info exists zaz_dummy]} {
		foreach item $zaz_dummy {
			DummyHistory $item "OVERWRITTEN_AS_RESULT"
		}
		unset zaz_dummy
	}
	My_Release_to_Dialog .inspage				;#	Return focus to previous dialog
	if {![info exists last_outfile]} {
		catch {set last_outfile $remem_last_outfile}
	}
	Dlg_Dismiss .inspage							;#	destroy the window, returning to workspace page
}

#------ Disable any action in Orig Instrument Window, while ins is constructed

proc DisableInsWindow {can mmfb mmtb} {
 	DisableInsTreeButtons $can	;#	prevent canvas buttons being used
	$mmfb.1.clear	   config -state disabled
	$mmfb.1.newfile	   config -state disabled [option get . background {}]
	$mmfb.2.props	   config -state disabled
	$mmfb.2.pl		   config -state disabled
	$mmfb.4.ro		   config -state disabled

	$mmtb.continue  config -state disabled -bg [option get . background {}]
	$mmtb.abort	    config -state disabled
	$mmtb.conclude  config -state disabled -bg [option get . background {}]
}

#------ Convert filename coding, once filesaving is complete
#
#		AFTER SAVING 3 & 4 & 8			on COMPLETION
#		[0] in0:truname0.wav			[0] in0.wav				
#		[1] in1:truname1.ana			[1] in1.ana				
#		[2] out0:_out0_0				[2] del0:_out0_0		
#		[3]	#out1:_out0_1				[3]	out1:_out0_1		
#		[4]	#out2:_out1_0	  ---->>	[4]	out2:_out1_0		
#		[5]	out3:_out1_1				[5]	del3:_out1_1		
#		[6] in2:truname6.txt			[6] in2.txt				
#		[7] out4:_out2_0				[7] del4:_out2_0		
#		[8] #out5:_out2_1				[8] out5:_out2_1		
#
				  
proc ReclassifyFilenames {} {
	global tree hst pa evv
	set i 0
	while {$i < $tree(filecnt)} {
		set thisfname [lindex $tree(fnams) $i]
		if [regexp {^\#} $thisfname] {							;#	For an outfile marked as saved
			set thisfname [string range $thisfname 1 end]		;#	Remove marker
		} elseif [regexp {^o} $thisfname] {					
			set name_end [string range $thisfname 3 end]		;#	For an outfile that has NOT been saved
			set thisfname del									;#	change out* -> del* in list
			append thisfname $name_end
			set j [string first ":" $thisfname]					
			incr j
			set truname [string range $thisfname $j end]		;#	set the extension!!
			set ftype $pa($truname,$evv(FTYP))		;#	(needed for assigning filetype color on display)
			incr j -2
			set thisfname [string range $thisfname 0 $j]
			switch -regexp -- $ftype \
				^$evv(SNDFILE)$	     {set name_ext $evv(SNDFILE_EXT)}  \
				^$evv(PSEUDO_SND)$	 {set name_ext $evv(PSEUDO_EXT)}  \
				^$evv(ANALFILE)$ 	 {set name_ext $evv(ANALFILE_EXT)}	\
				^$evv(PITCHFILE)$ 	 {set name_ext $evv(PITCHFILE_EXT)} \
				^$evv(TRANSPOSFILE)$ {set name_ext $evv(TRANSPOSFILE_EXT)} \
				^$evv(FORMANTFILE)$  {set name_ext $evv(FORMANTFILE_EXT)} \
				^$evv(ENVFILE)$ 	 {set name_ext $evv(ENVFILE_EXT)} \
				default {set name_ext $evv(TEXT_EXT)}

			append thisfname $name_ext							;#	Append the extension -> new generic-type name
			append thisfname ":"
			append thisfname $truname
		} else {												;#	for an infile
			set j [string first ":" $thisfname]					
			incr j
			set truname [string range $thisfname $j end]		;#	set the extension!!

			lappend hst(ins_infiles) $truname 			;#	Save the truenames of infiles, for establishing hst!!

			set ftype $pa($truname,$evv(FTYP))		;#	(needed for assigning filetype color on display)
			incr j -2
			set thisfname [string range $thisfname 0 $j]		;#	Discard the truname
			switch -regexp -- $ftype \
				^$evv(SNDFILE)$	{
					set name_ext $evv(SNDFILE_EXT)		;#	Check if 'MONO' forced by processes used on file
					set name_ext [CheckForMonoRestriction $thisfname $name_ext]
				}  \
				^$evv(PSEUDO_SND)$ 	 {set name_ext $evv(PSEUDO_EXT)} \
				^$evv(ANALFILE)$ 	 {set name_ext $evv(ANALFILE_EXT)}	\
				^$evv(PITCHFILE)$ 	 {set name_ext $evv(PITCHFILE_EXT)} \
				^$evv(TRANSPOSFILE)$ {set name_ext $evv(TRANSPOSFILE_EXT)} \
				^$evv(FORMANTFILE)$  {set name_ext $evv(FORMANTFILE_EXT)} \
				^$evv(ENVFILE)$ 	 {set name_ext $evv(ENVFILE_EXT)} \
				default {set name_ext $evv(TEXT_EXT)}

			append thisfname $name_ext							;#	Append the extension -> new generic-type name
		}
		set tree(fnams) [lreplace $tree(fnams) $i $i $thisfname]
		incr i
	}
}

#------ Check the processes used on any sndfile to check if sndfile needs to be mono

proc CheckForMonoRestriction {thisfname name_ext} {
	global ins evv
	set infile_no [string range $thisfname 2 end]			;#	Assumes name is "inN", where N is the infile-no
	set this_props_group "[lindex $ins(conditions) $infile_no]"	
															;#	Get all props from all processes where infile used
	foreach prps $this_props_group { 					;#	Look at all props for a given process
		foreach prop $prps {							;#	Look at each prop
			if [string match "MONO" $prop] {				;#	if MONO restriction, change file extension
				return $evv(MONO_EXT)
			}
		}
	}
	return $name_ext
}

#------ Finish the current ins
#
#	Neutralise flag for creating ins: Save details of completed ins
#	If no pre-existing ins-list, create one: Put new ins on list:.
#	Enable selection of existing Instruments: Enable ins creation
#

proc ConcludeIns {} {
	global pr_ins pr_zog tree evv
	if {![AreYouSure]} {
		return
	}
	if {!$tree(process_cnt)} {
		set pr_ins $evv(INS_ABORTED)
	} else {
		set pr_ins $evv(INS_COMPLETED)
	}
	set pr_zog 2
}

#------ Restructure Instrument-Window while files are being saved
# 	| ----  ----  ----		  ----	| ---  --- |	# 	| ----  ----  ----  ----  ----  ----  | 		 |
#	||Cont||Conc||A   |		 |New |	||Cl ||Del||	#	||Play||Stop||See ||Keep||Keep||Quit| |		   	 |
#	||inue||lude||bort|		 |File|	||ear||ete||	#	||	  ||    ||    ||	|| All||	| |THIS FILE |
#	| ----  ----  ----		  ----	| ---  --- |	#	| ----  ----  ----  ----  ----  ----  | 		 |
#	|-------------------------------|----------|	#	|-------------------------------------|----------|
#	|KEY (Color key to tree)		| listing  |	#	|KEY (Color key to tree)			  | entrybox |
#	|-------------------------------|		   |	#	|-------------------------------------|----------|
#	|		 -    -					| 		   |	#	|		 -    -						  |			 | 		   
#	|		 -    -					| 		   |	#	|		 -    -						  |			 | 		   
#	|		|1|	 |2|				|		   |	#	|		|1|	 |2|					  |			 |		   
#	|		 -	  -					|		   |	#	|		 -	  -						  |			 |		   
#	|		 |	/					|		   |	#	|		 |	/						  |			 |		   
#	|		 |/						|		   |	#	|		 |/							  |			 |		   
#	|	     ------					|		   |	#	|	     ------						  |			 |		   
#	|		|interp|				|		   |	#	|		|interp|					  |			 |		   
#	|		 ------					|		   |	#	|		 ------						  |			 |		   
#


proc RestructureInsWindow {ins_window mmtb mmfb mmfq can} {

	global ins hst chlist tree azaz z_savename pr_ins nu_names sysname
	global inspage_emph ins_file_lst fpoint smpsout evv
   	global prg_ocnt sndsout asndsout vwbl_sndsysout txtsout pa inspage_hlp_actv icp 

	set ins(files_saved) 0
	set tree(filecnt) [llength $tree(fnams)]
	wm title $ins_window "Save instrument outfiles"

	catch {unset hst(outlist)}
 	DisableInsTreeButtons $can				;#	Prevent canvas buttons being used

 	catch {unset inspage_emph}

	destroy $mmfb.1.clear
	destroy $mmfb.1.newfile
	destroy $mmfb.2.props
	destroy $mmfb.2.pl
	destroy $mmfb.4.ro
	destroy $mmfb.3.lab

	label $mmfb.1.lab -text "Instrument Outputs" -justify center
	pack $mmfb.1.lab -side top
	label $mmfb.2.l -text "Name"
	set azaz [entry $mmfb.2.e -width 12 -textvariable z_savename]
	pack $mmfb.2.l $mmfb.2.e -side left

	label $mmfq.laba -text "Recent Names"
	Scrolled_Listbox $mmfq.lbox -height $evv(NSTORLEN) -selectmode single 
	label $mmfq.labb -text "Recent Source Names"
	Scrolled_Listbox $mmfq.lboxb -height $evv(NSTORLEN) -selectmode single -height 3
	label  $mmfq.bbb -text "standard names"
	set ku [frame $mmfq.bbbb]
	button $ku.bb1 -text "$sysname(1)" -command "PutName $azaz $sysname(1)" -highlightbackground [option get . background {}]
	button $ku.bb2 -text "$sysname(2)" -command "PutName $azaz $sysname(2)" -highlightbackground [option get . background {}]
	button $ku.bb3 -text "$sysname(3)" -command "PutName $azaz $sysname(3)" -highlightbackground [option get . background {}]
	button $ku.bb4 -text "$sysname(4)" -command "PutName $azaz $sysname(4)" -highlightbackground [option get . background {}]
	bind $mmfq.lbox.list <ButtonRelease-1> "NameListChoose $mmfq.lbox.list $azaz"
	bind $mmfq.lboxb.list <ButtonRelease-1> "NameListChoose $mmfq.lboxb.list $azaz"
	pack $mmfq.bbb $mmfq.bbbb -side top -pady 1
	pack $ku.bb1 $ku.bb2 $ku.bb3 $ku.bb4 -side left -padx 1
	pack $mmfq.labb $mmfq.lboxb $mmfq.laba $mmfq.lbox -side top -fill x
	if [info exists nu_names] { 
		$mmfq.lbox.list delete 0 end
		foreach nname $nu_names {	;#	Post recent names
			$mmfq.lbox.list insert end $nname
		}					
		$mmfq.lbox.list xview moveto 0.0
	}
 	$mmfq.lboxb.list delete 0 end
	$mmfq.lboxb.list xview moveto 0.0
	if {[info exists ins(chlist)] && ([llength $ins(chlist)] > 0)} {
		set thisl $ins(chlist)
	} elseif {[info exists chlist] && ([llength $chlist] > 0)} {
		set thisl $chlist
	}
	if [info exists thisl] { 
		set i 0
		foreach nname $thisl {	;#	Post source names
			$mmfq.lboxb.list insert end [file rootname $nname]
			incr i
			if {$i >= 2} {
				break
			}
		}					
	}
	$ins_file_lst delete 0 end
	set prg_ocnt 0
	set sndsout 0
	set asndsout 0
	set smpsout 0
	set vwbl_sndsysout 0
	set txtsout 0
	catch {unset tree(selectedfile_no)}
	set i 0
	while {$i < $tree(files_icon_cnt)} {
		set fnam $fpoint($i,name)
		if [string match $evv(MACH_OUTFNAME)* $fnam] {
			$ins_file_lst insert end $fnam
			lappend tree(selectedfile_no) $i
			incr prg_ocnt
			set ftype $pa($fnam,$evv(FTYP))
			if {$ftype == $evv(SNDFILE)} {
				incr sndsout
				incr smpsout 
				incr vwbl_sndsysout
			} elseif {$ftype == $evv(PSEUDO_SND)} {
				incr smpsout 
				incr vwbl_sndsysout
			} elseif {$ftype == $evv(ANALFILE)} { 
				incr asndsout
				incr smpsout 
				incr vwbl_sndsysout
			} elseif {$ftype & $evv(IS_A_TEXTFILE)} { 
				incr txtsout 
			} else {
				incr smpsout 
			}
		}
		incr i
	}
	if {$prg_ocnt <= 0} {
		set pr_ins $evv(INS_ABORTED)
		return
	}

	bind $ins_file_lst <ButtonRelease-1> {}	;#	Select, rather than delete, files listed

	set z_savename ""

	destroy $mmtb.abort							
	destroy $mmtb.continue							
	destroy $mmtb.scroll
	destroy $mmtb.conclude							;#	Create new set of buttons to play, etc Keep files

	button $mmtb.conclude -text "Conclude"	-command "ConcludeMFilesaving" -bg $evv(EMPH)  -highlightbackground [option get . background {}]
	label  $mmtb.pad	-text "" -width 8
	button $mmtb.play	 -text "Play" -command "PlayOutput 0"  -highlightbackground [option get . background {}]
	button $mmtb.view	 -text "View" -command "ViewOutput"  -highlightbackground [option get . background {}]
	button $mmtb.read	 -text "Read" -command "ReadFile"  -highlightbackground [option get . background {}]
	button $mmtb.keep	 -text "Save As" -command "KeepMFile $mmtb" -bg $evv(EMPH) -fg $evv(SPECIAL) -highlightbackground [option get . background {}]
	button $mmtb.keepall -text "Save All" -command "KeepAllMFiles" -highlightbackground [option get . background {}]
	button $mmtb.props   -text "Props" -command "Show_Props from_parampage 0" -highlightbackground [option get . background {}]
	button $mmtb.mxsmp   -text "MaxSamp" -command "GetMaxsamps 0 1" -highlightbackground [option get . background {}]
	pack $mmtb.play $mmtb.view $mmtb.read $mmtb.keep $mmtb.keepall $mmtb.props $mmtb.mxsmp $mmtb.pad $mmtb.conclude -side left

	bind $azaz <Return> "KeepMFile $icp.tree.btns"

	lappend inspage_emph $mmtb.conclude $mmtb.keep

	if {!$txtsout} {
		$mmtb.read config -state disabled
	} else {
		$mmtb.read config -bg $evv(EMPH)
		lappend inspage_emph $mmtb.read
	}
	if {!$sndsout && !$asndsout} {	
		$mmtb.play config -state disabled
	} else {
		$mmtb.play config -bg $evv(EMPH)
		lappend inspage_emph $mmtb.play
	}
	if {!$vwbl_sndsysout} {
		$mmtb.view config -state disabled
	} else {
		$mmtb.view config -bg $evv(EMPH)
		lappend inspage_emph $mmtb.view
	}
	if {$prg_ocnt > 1} {
		$mmtb.keepall config -bg $evv(EMPH)
		lappend inspage_emph $mmtb.keepall
	} else {
		$mmtb.keepall config -state disabled
	}
	if {[info exists inspage_hlp_actv] && $inspage_hlp_actv} {
		ActivateInspageHelp
	}
	focus $azaz
}

#------ Save file selected from ins tree
#	Marking in tree(fnams) list
#
#	fnames						on SAVING 3
#	[0] in0:truname0			[0] in0:truname0.wav
#	[1] in1:truname1			[1] in1:truname1.ana
#	[2] out0:_out0_0			[2] out0:_out0_0
#	[3]	out1:_out0_1	--->>	[3]	#out1:_out0_1
#	[4]	out2:_out1_0			[4]	out2:_out1_0
#	[5]	out3:_out1_1			[5]	out3:_out1_1
#	[6] in2:truname6			[6] in2:truname6.txt
#	[7] out4:_out2_0			[7] out4:_out2_0
#	[8] out5:_out2_1			[8] out5:_out2_1
#

proc KeepMFile {mmtb} {
	global wl ins ins_file_lst tree azaz z_savename prg_ocnt ppg_emph pa evv
	global pr_ins last_outfile has_saved rememd icp

	set all_list [$ins_file_lst get 0 end]
	if {[llength $all_list] == 1} {
		set fnam [lindex $all_list 0]
		set i 0
	} else {

	#	SHOULD BE SINGLE SELECTION MODE

		set i [$ins_file_lst curselection]
		if {[llength $i] <= 0} {
			Inf "No file(s) selected."
			return
		} 
	}

	if {[string length $z_savename] <= 0} {
		Inf "No new name given"
		return
	}												;#	Generates full output name
#JUNE 30 UC-LC FIX
	set z_savename [string tolower $z_savename]
	set fnam [$ins_file_lst get $i]
	set selected_file [lindex $tree(selectedfile_no) $i]
	set ftype $pa($fnam,$evv(FTYP))
	set newname [OutfileKeep $fnam $z_savename]	
	if {[string length $newname] > 0} {				;#	and rename props if successful
		$wl insert 0 $newname						;#	Add to start of workspace
		WkspCntSimple 1
		catch {unset rememd}
		incr ins(files_saved)
		AddNameToNameslist $z_savename $icp.files.nameslist.lbox.list
		set z_savename ""							;#	Empty the entry-box
		ForceVal $azaz $z_savename
													;#	Mark file as saved, in tree-fnames-list

		set newline [PrefixTreeline $selected_file $ftype]
		set tree(fnams) "[lreplace $tree(fnams) $selected_file $selected_file $newline]"
		set tree(selectedfile_no) [lreplace $tree(selectedfile_no) $i $i]
	} else {
		set z_savename ""							;#	Failed to save: Empty the entry-box
		ForceVal $azaz $z_savename		
		return
	}
	$ins_file_lst delete $i $i

	incr prg_ocnt -1
	set has_saved 1

	if {$prg_ocnt == 1} {
		$mmtb.keepall config -bg [option get . background {}] -state disabled
		set len [llength $ppg_emph]
		incr len -2
		set ppg_emph [lrange $ppg_emph 0 $len]
	}
	if {$prg_ocnt <= 0} {
		TurnOffInsOutputButtons
		set pr_ins $evv(INS_COMPLETED)
	}		
	lappend last_outfile $newname
}

#------ Save file selected from ins tree

proc KeepAllMFiles {} {
	global wl ins ins_file_lst tree azaz z_savename prg_ocnt pa rememd evv
	global pr_ins last_outfile has_saved
	global wksp_cnt total_wksp_cnt ww icp

	set fnams [$ins_file_lst get 0 end]

	if {[string length $z_savename] <= 0} {
		Inf "No new name given"
		return
	}													;#	Generates full output name
	set z_savename [string tolower $z_savename]
	if [ValidCDPRootname $z_savename] {					;#	Test for valid CDP name
		if [regexp {[0-9]+$} $z_savename] {				;#	Test that there's no numeral at end
			Inf "No numerals allowed at the end of a generic name"
			set z_savename ""							;#	Empty the entry-box
			ForceVal $azaz $z_savename
			return
		} else {
			set OK 1
			set basename $z_savename
			set baselen [string length $basename]
			foreach fnam [glob -nocomplain "$basename*"] {	
#ADDED JULY 2001->
		  		set fnam [file rootname $fnam]
#<-ADDED JULY 2001
				if {[string length $fnam] > $baselen} {
					set zstr [string range $fnam $baselen end]
					if [regexp {^[0-9]+$} $zstr] {
						set OK 0
						break
					}
				} else {
					set OK 0
					break
				}			;#	Test that generic name is not already in use
			}
		}
		if {!$OK} {
			Inf "Files already exist with the name '$fnam'"
			set z_savename ""						;#	Empty the entry-box
			ForceVal $azaz $z_savename
			return
		}
	} else {
		return
	}
	set i 0
	catch {set remem_last_outfile $last_outfile}
	catch {unset last_outfile}
	foreach fnam $fnams {
		set selected_file [lindex $tree(selectedfile_no) $i]
		set newname $z_savename
		append newname $i
		set ftype $pa($fnam,$evv(FTYP))
		set newname [OutfileKeep $fnam $newname]	
		if {[string length $newname] > 0} {				;#	and rename props if successful
			$wl insert 0 $newname						;#	Add to start of workspace
			catch {unset rememd}
			incr wksp_cnt
			incr total_wksp_cnt
			incr ins(files_saved)
														;#	Mark file as saved, in tree-fnames-list
			set newline [PrefixTreeline $selected_file $ftype]
			set tree(fnams) "[lreplace $tree(fnams) $selected_file $selected_file $newline]"
		} else {
			set z_savename ""							;#	Failed to save: Empty the entry-box
			ForceVal $azaz $z_savename		
			of {![info exists last_outfile]} {
				catch {set last_outfile $remem_last_outfile}
			}
			return
		}
		incr prg_ocnt -1
		set has_saved 1
		incr i
		lappend last_outfile $newname
	}
	ForceVal $ww.1.a.endd.l.cnts.new $wksp_cnt
	ForceVal $ww.1.a.endd.l.cnts.all $total_wksp_cnt

	ReMarkWkspaceCount
	AddNameToNameslist $z_savename $icp.files.nameslist.lbox.list
	$ins_file_lst delete 0 end
	TurnOffInsOutputButtons
	set pr_ins $evv(INS_COMPLETED)
}		

#------ Prefix line of tree, with '#', to indicate a saved file, and add approp filetype-extension to coded-name

proc PrefixTreeline {selected_file ftype} {
	global tree evv

	set treeline [lindex $tree(fnams) $selected_file] 	
	set j [string first ":" $treeline]
	set line_end [string range $treeline $j end]
	incr j -1
	set newline [string range $treeline 0 $j]
	switch -regexp -- $ftype \
		^$evv(SNDFILE)$	     {set name_ext $evv(SNDFILE_EXT)}  \
		^$evv(PSEUDO_SND)$ 	 {set name_ext $evv(PSEUDO_EXT)} \
		^$evv(ANALFILE)$ 	 {set name_ext $evv(ANALFILE_EXT)}	\
		^$evv(PITCHFILE)$ 	 {set name_ext $evv(PITCHFILE_EXT)} \
		^$evv(TRANSPOSFILE)$ {set name_ext $evv(TRANSPOSFILE_EXT)} \
		^$evv(FORMANTFILE)$  {set name_ext $evv(FORMANTFILE_EXT)} \
		^$evv(ENVFILE)$ 	 {set name_ext $evv(ENVFILE_EXT)} \
		default {set name_ext $evv(TEXT_EXT)}

	append newline $name_ext
	incr j 1
	append newline $line_end
	set treeline #
	append treeline $newline
	return $treeline
}

#------ Turn Off inspage buttons to do with keeping or viewing/hearing output

proc TurnOffInsOutputButtons {} {
global icp
	$icp.tree.btns.play	  config -bg [option get . background {}] -state disabled 
	$icp.tree.btns.view	  config -bg [option get . background {}] -state disabled
	$icp.tree.btns.read	  config -bg [option get . background {}] -state disabled
	$icp.tree.btns.keep	  config -bg [option get . background {}] -state disabled
	$icp.tree.btns.props  config -bg [option get . background {}] -state disabled
	$icp.tree.btns.mxsmp  config -bg [option get . background {}] -state disabled
	$icp.tree.btns.keepall config -bg [option get . background {}] -state disabled
}

#------ Tell the ins that you have saved all the files you want to: (it will delete the rest)

proc ConcludeMFilesaving {} {
	global ins wstk pr_ins evv
	if {$ins(files_saved) <= 0} {
		set choice [tk_messageBox -type yesno -parent [lindex $wstk end] \
		-message  "If you save no files, instrument will not be kept: OK??" -icon question]
		if {$choice == "yes"}  {
			set pr_ins $evv(INS_ABORTED)
		}
		return
	}
	set pr_ins $evv(INS_COMPLETED)
}

#------ Disable all tree buttons

proc DisableInsTreeButtons {ins_canvas} {
	global tree
	set i 0
	while {$i < $tree(filecnt)} {					
		$ins_canvas.ff$i.button config -state disabled
		incr i
	}	
}

#------ Do next ins-process, possibly recycling existing files

proc ContinueIns {} {
	global ins_file_lst sl_real
	if {!$sl_real} {
		Inf "You Can Record A Sequence Of Sound Processes Here,\nand Build It Into Your Own, Named, Instrument.\nIt Will Be Displayed As A Diagram As You Build It."
		Inf "The Instrument Can Have Its Own Predefined Parameters\nor Parameters Entered By The User.\nYou Can Change Your Mind About The Design At Any Time During The Build."
		Inf "The Finished Instrument Can Then Be Called By A Single Button Press."
		Inf "To See An Example Instrument, Go Back To The Workspace And Press The 'Process' Button.\nOn The New (Process) Page Which Is Displayed, On The Far Right, Select 'See'"
		return
	}
	if {[llength [$ins_file_lst get 0 end]] > 0} {
 		DoContinueIns
	} else {
		Inf "No files selected"
	}
}

proc DoContinueIns {} {
	global ins o_nam pr_ins tree baktrak ins_file_lst wstk pr_zog evv

	set pr_zog 0
	set baktrak(process_cnt)    $tree(process_cnt)
	set baktrak(mprocess_cnt)   $ins(process_cnt)
	set baktrak(file_index)     $tree(file_index)
	set baktrak(infile_counter) $tree(infile_counter)

	set ins(thisprocess_finished) 0
	set o_nam $evv(MACH_OUTFNAME)
	append o_nam $ins(process_cnt) "_"

	incr ins(process_cnt)
	if [info exists ins(chlist)] {
		set ins(last_ch) $ins(chlist)
		unset ins(chlist)
	}
	# the ins_file_lst is cleared when the ins is saved (StoreInsProcessData)
	# Files are selected (in correct order) to the filedisplay [thl], independently

	foreach fnam [$ins_file_lst get 0 end] {
		lappend ins(chlist) $fnam	;#	Get files from visible list to background list (ins(chlist))
	}
	if {![RememberInfilesToTree]} {		;#	Temporarily remember the infile information to tree structure
		set pr_ins $evv(INS_ABORTED)	
	} else {							
		set pr_ins $evv(INS_CONTINUES)		
	}									;#	i.e. continues with process from INSTRUMENT-TREE dialog
}

#------ Remember the infile tree information: Not SAVED until process is actually successfully completed

proc RememberInfilesToTree {} {
	global ins tree evv

	catch {unset tree(current_infiles)}					;#	Destroy any existing LOCAL list of filenames
	catch {unset tree(this_process_infilenos)}
	catch {unset tree(nonrecycled_file_inlist_pos)}
	catch {unset tree(nonrecycled_file_fileno)}
	set tree(this_process_inputs_cnt) 0
											
	if {![info exists ins(chlist)]} {
		return 1
	}

	# REMEMBER INFILES TO TREE

	foreach fnam $ins(chlist) {
		set thisfile_typing [lindex $tree(filetype) $tree(this_process_inputs_cnt)]
		switch -regexp -- [lindex $thisfile_typing $evv(TYP)] \
			^$evv(PREVIOUS_OUTFILE)$ {							;#	if it's a recycled ofil, named "evv(MACH_OUTFNAME)N_M"
				set this_fileno [lindex $thisfile_typing $evv(FNO)]	;#	Find absolute-file-number of output file
			} \
  			^$evv(PREVIOUS_INFILE)$ {
				lappend tree(nonrecycled_file_inlist_pos) $tree(this_process_inputs_cnt)	
																	;#	Store POSITION-in-infile-list-to-process of INfile
				lappend tree(nonrecycled_file_fileno) [lindex $thisfile_typing $evv(INO)]	
																	;#	Store Infile-number of file
																	;#	Used to associate process-conditions with infiles
				set this_fileno [lindex $thisfile_typing $evv(FNO)]	;#	Find absolute-file-number of input file

			} \
  			^$evv(NEW_INFILE)$ {
				lappend tree(nonrecycled_file_inlist_pos) $tree(this_process_inputs_cnt) 
															;# 	Store POSITION-in-infile-list-to-process of NEWfile
				lappend tree(nonrecycled_file_fileno) $tree(infile_counter)	
															;#	Store NEW Infile-number of file
				set thisfname in							;#	CREATE THE NEW-INFILE GENERIC-NAME 'inN:filename'
				append thisfname $tree(infile_counter) ":" $fnam
				lappend tree(current_infiles) $thisfname	;#	And add to LOCAL list of filenames (GLOBALLY numbered)
				incr tree(infile_counter)					;#	Increment NEW-infile counter

				set this_fileno $tree(file_index)			;#	New fileno = total-count of files (in and out) so far
				incr tree(file_index)						;#	Increment the count of total files used in the ins
			} \
			default {
				ErrShow "Unknown file-typing in RememberInfilesToTree{}"
				return 0
			}
				
					
		lappend tree(this_process_infilenos) $this_fileno	;#	Keep list of absolute-filenos used as inputs to process
															;#	Used to construct tree-diagram....
		incr tree(this_process_inputs_cnt)					;#	Count no of infiles (new or recycled) to this process
	}
	return 1
}

#------ Get newfile(s) from workspace, for use in making ins (indirect: avoids altering wksp during making ins)

proc GetNewFile {} {
	global pr_newfile newfile_for_ins destroy_newfile_window wl nfm_fll evv

	set f .newfile_for_ins
	if {$destroy_newfile_window} {					;#	On first call to GetNewFile for CURRENT ins,
 		destroy $f									;#	destroy any previous listing of possible-newfiles.
		set destroy_newfile_window 0				;#	(Not destroyed again till CURRENT ins concludes|aborts).
	}
	if [Dlg_Create $f "Select Files From Workspace" "set pr_newfile 1" -borderwidth $evv(BBDR)] {
		set fb [frame $f.butn -borderwidth $evv(SBDR)]		;#	frame for buttons
		set fl [frame $f.list -borderwidth $evv(SBDR)]		;#	frame for list
		button $fb.quit  -text "Close"       -command "set pr_newfile 1" -highlightbackground [option get . background {}]
		button $fb.props -text "Properties"   -command "ShowPropsMach $fb.props $fb.sf" -width 12 -highlightbackground [option get . background {}]
		button $fb.sf    -text "Select Files" -command "ToSelectMach $fb.sf $fb.props" -width 12 -bg $evv(EMPH) -highlightbackground [option get . background {}]
		
		pack $fb.quit  -side left -padx 1
		pack $fb.props $fb.sf -side right -padx 1
		set nfm_fll [Scrolled_Listbox $fl.lbox -width 64 -height 24 -selectmode single]
		pack $fl.lbox -side top						;#	Create a listbox and
		foreach fnam [$wl get 0 end] {			;#	copy in all files from current workspace
			$nfm_fll insert end $fnam
		}	
		pack $f.butn $f.list -side top -fill x
		wm resizable $f 1 1
		bind $f <Return> {set pr_newfile 1}
		bind $f <Escape> {set pr_newfile 1}
		bind $f <Key-space> {set pr_newfile 1}
	}

	raise $f

	bind $nfm_fll <ButtonRelease-1> {}				;#	Click on file-in-list copies it to ins_file_lst
	bind $nfm_fll <ButtonRelease-1> {ListCopySelectToMFList $nfm_fll}

	bind .newfile_for_ins <ButtonRelease-1> {HideWindow %W %x %y pr_newfile}

	set pr_newfile 0

	My_Grab 0 $f pr_newfile $f.list.lbox

	# MOVEIT TO RIGHT HALF OF CALLING WINDOW

	wm geometry $f [ToRightHalf .inspage $f]

	tkwait variable pr_newfile					;#	'Quit' was pressed: hide dialog, return to Instrument-Dialog

	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#------ Show properties of files listed for selection to ins-chosen list

proc ShowPropsMach {fb1 fb2} {
	global nfm_fll evv
	$nfm_fll selection clear 0 end
	bind $nfm_fll <ButtonRelease-1> {}
	bind $nfm_fll <ButtonRelease-1> {Show_Props newfile_for_ins 0}
 	$fb1 config -bg $evv(EMPH)
 	$fb2 config -bg [option get . background {}]
}

#------ Return to selection mode the list from which files are selected to go to ins-chosne list

proc ToSelectMach {fb1 fb2} {
	global nfm_fll evv
	$nfm_fll selection clear 0 end
	bind $nfm_fll <ButtonRelease-1> {}				;#	Click on file-in-list copies it to ins_file_lst
	bind $nfm_fll <ButtonRelease-1> {ListCopySelectToMFList $nfm_fll}
 	$fb1 config -bg $evv(EMPH)
 	$fb2 config -bg [option get . background {}]
}

#------ Transfer selected item from one list to InstrumentFileListing, AND store its type

proc ListCopySelectToMFList {src} {
	global tree ins_file_lst evv

	set ilist [$src curselection]
	if {[llength $ilist] <= 0} {
		tk_messageBox -type ok -icon info  -parent .newfile_for_ins -message "No files selected"
		return
	}

	if {[info exists tree(fnams)] && ([llength $tree(fnams)] > 0)} {
		set isinlist 1
	} else {
		set isinlist 0
	}
	foreach i $ilist {
		set fnam [$src get $i]
		if {$isinlist} {
			set ok 1
			foreach fnm $tree(fnams) {
				set truname [GetMCreateTruname $fnm]
				if [string match $fnam $truname] {
					tk_messageBox -type ok -icon info  -parent .newfile_for_ins \
					-message "File $fnam already in use in your instrument\nSELECT IT FROM THE INSTRUMENT TREE"
					set ok 0
					break
				}
			}
			if {!$ok} {
				continue
			}
		}
		if {[LstIndx $fnam $ins_file_lst] < 0} {
			$ins_file_lst insert end $fnam
			lappend tree(filetype) "$evv(NEW_INFILE)"
		} else {
			tk_messageBox -type ok -icon info  -parent .newfile_for_ins -message "File $fnam is already listed."
		}
	}
}

#------ Restore the state of the system prior to creating a ins

proc RestoreInslessSystem {} {
	global evv mach ins_file_lst tree ins o_nam ins_creation
	global ins_concluding src pmask only_for_mix

	#CLEAR THE INSTRUMENT HILITELIST (ORIGINAL chlist REMAINS)
	if {$ins(create)} {
		if [info exists ins_file_lst] {
			$ins_file_lst delete 0 end	;#	Redundant, as window destroyed ??
		}
		catch {unset tree(filetype)}
		catch {unset ins(chlist)}
		# RESTORE STATE OF DIALOG_PROCESS_AND_INSTRUMENT_MENUS
		set ins_creation 0					;#	Re-enable GET FILES button on Dlg_Process_and_Ins_Menus
		
		if {[winfo exists .menupage] && [info exists mach]} {
			$mach.btns.run config -state normal	;#	Enable selection existing Instruments on Dlg_Process_and_Ins_Menus
		}										;#	Delete all remaining, unrenamed, ins outputs

		set ins(create) 0
		if {$dupl_mix} {
# POSSIBLE REDUNDANT
			set pmask [OnlyForMix]
		} else {
			set pmask [GetProgsmask]
		}
		set woof 0
		set pmask [append woof $pmask]
		set ins(create) 1
	}
	set fnams [glob -nocomplain $evv(MACH_OUTFNAME)*]
	if {[llength $fnams] > 0} {
		foreach fnam $fnams {
			file stat $fnam filestatus
			if {$filestatus(ino) >= 0} {
				catch {close $filestatus(ino)}
			}

			if [catch {file delete $fnam} xx] {	
				Inf "Cannot delete file '$fnam': (still open?)"
			} else {								;#	NB This deletes ALL ins outfiles (from every process)
				DeleteFileFromSrcLists $fnam
				PurgeArray $fnam
			}
		}
	} 
	set fnams [glob -nocomplain $evv(DFLT_OUTNAME)*]
	if {[llength $fnams] > 0} {
		foreach fnam $fnams {
			file stat $fnam filestatus
			if {$filestatus(ino) >= 0} {
				catch {close $filestatus(ino)}
			}
			if [catch {file delete $fnam} xx] {	
				Inf "Cannot delete file '$fnam': (still open?)"
			} else {								;#	NB This deletes outfiles from possible odd processes
				DeleteFileFromSrcLists $fnam
				PurgeArray $fnam				;#	And any extra files with DFLT_OUTNAME generated in ins
			}
		}
	}									
												
	UnsetExistingTree							;#	Remove lists which have data APPENDED, 
												;#	so they don't confuse NEXT ins
	set o_nam $evv(DFLT_OUTNAME)	;#	Return to standard ofil-name
	set ins_concluding 0
}

#------ Destroy any existing ins-tree-dialog & related data, because this data will be APPENDED

proc UnsetExistingTree {} {
	global ins tree
	catch {unset ins(cmdset)}
	catch {unset ins(gadgets)}
	catch {unset ins(conditions)}
	catch {unset ins(tree)}
	catch {unset ins(defaults)}
	catch {unset ins(subdefaults)}
	catch {unset ins(timetypes)}
	catch {unset ins(this)}
	catch {unset ins(chlist)}
	catch {unset ins(current_gdg_store)}
	catch {unset ins(current_defaults)}
	catch {unset ins(current_subdefaults)}
	catch {unset ins(current_timetypes)}
	catch {unset tree(fnams)}
	catch {unset tree(procnames)}
	catch {unset tree(nonrecycled_file_inlist_pos)}
	catch {unset tree(nonrecycled_file_fileno)}
	catch {unset tree(current_infiles)}
	catch {unset tree(this_process_infilenos)}
	catch {unset tree(this_process_outfilenos)}
	catch {unset tree(filetype)}
	catch {unset tree(inputs_to_each_process)}
	catch {unset tree(outputs_from_each_process)}
	catch {unset tree(all_endcols)}
}

#------ Remove Filename from ins infile-listing (only) AND from associated typelist

proc RemovefromInsInfileListing {} {
	global ins_file_lst tree

	if {[llength [$ins_file_lst get 0 end]] <= 0} {
		return
	}

	set ilist [$ins_file_lst curselection]
	if {[llength $ilist] <= 0} {
		Inf "No item selected"
		return
	}
	foreach i [lsort -integer -decreasing $ilist] {
		$ins_file_lst delete $i
		set tree(filetype) "[lreplace $tree(filetype) $i $i]"
	}
}

#------ Clear display of user infiles to ins, AND delete associate type-list

proc ClearInsInfileListing {} {
	global ins_file_lst tree
 	$ins_file_lst delete 0 end
	catch {unset tree(filetype)}
}

#------ Display a Colour-Key above tree-display

proc DisplayTreeColorKey {treekey} {
	global ins evv treefnt treedeletefnt only_looking
														
	if {$only_looking} {
		label $treekey.key 	 -text "KEY" 	  		-width 5 -font treekeyfnt -anchor w
	} else {
		label $treekey.key 	 -text "KEY" 	  		-width 10 -font treekeyfnt -anchor w
	}
	label $treekey.snd   -text "sound" 	  		-bg $evv(SOUND_TC)    -width 10 -font treefnt 
	label $treekey.mono  -text "mono sound"		-bg $evv(MONO_TC) 	  -width 10 -font treefnt  
	label $treekey.anal  -text "spectrum" 		-bg $evv(ANALYSIS_TC) -width 10 -font treefnt 
	label $treekey.pitch -text "pitch" 	  		-bg $evv(PITCH_TC)    -width 10 -font treefnt 
	label $treekey.trans -text "transposition" 	-bg $evv(TRANSPOS_TC) -width 10 -font treefnt 
	label $treekey.fmnt  -text "formants"  		-bg $evv(FORMANT_TC)  -width 10 -font treefnt 
	label $treekey.env   -text "envelope" 		-bg $evv(ENVELOPE_TC) -width 10 -font treefnt 
	label $treekey.txt   -text "text" 	  		-bg $evv(TEXT_TC) 	  -width 10 -font treefnt 
	label $treekey.pseud -text "pseudo snd" 	-bg $evv(PSEUDO_TC)   -width 10 -font treefnt 
	if {$only_looking} {
		label $treekey.gap -text "" -bg $evv(NEUTRAL_TC) -width 1
		label $treekey.keep -text "Retained" -width 8 -font treekeyfnt
		label $treekey.del -text  "Deleted" -width 8 -font treedeletefnt
		grid $treekey.key $treekey.snd $treekey.mono $treekey.anal $treekey.pitch $treekey.trans $treekey.fmnt \
				$treekey.env $treekey.txt $treekey.pseud $treekey.gap $treekey.keep $treekey.del
	} else {
		grid $treekey.key $treekey.snd $treekey.mono $treekey.anal $treekey.pitch $treekey.trans $treekey.fmnt \
			 $treekey.env $treekey.txt $treekey.pseud
	}
}

#------ Set up counters, and initial input files, in tree

proc InitialiseTreeDataAndInsInfileListing {} {
	global chlist ins_file_lst tree evv

	UnsetExistingTree
	set tree(process_cnt) 0								;#	Counts lines in tree-file
	set tree(file_index) 0								;#	Count (and numbering) of files used & produced in tree
	set tree(infile_counter) 0							;#	Counts input files in tree
	set tree(outfile_counter) 0							;#	Counts output files in tree
														;#	Before 1st process...(updated process by process)
	catch {unset tree(filetype)}
	if [info exists chlist] {
		foreach fnam [lrange $chlist 0 end] {
			$ins_file_lst insert end $fnam ;#	Copy fnames from wkspace chlist to ins_file_lst
			lappend tree(filetype) "$evv(NEW_INFILE)"	 ;#	And note that they are NEW infiles
		}
	}
}

#------ If any property is to be a variable when the ins runs, store it temporarily
#	It's possible process may be run again, with different params, before user decides to keep
#	So this is a temporary save
#

proc RememberSpecOfVariableInsParams {} {
	global gdg_cnt gdg_typeflag ins_variable_store evv
	global ins dfault timetype_exists parname timetype sdfault stsdfault
	global saved_cmd pa prm

	set return_val 0
	set gcnt 0
	set pcnt 0
	catch {unset ins(current_gdg_store)}
	catch {unset ins(current_defaults)}
	catch {unset ins(current_subdefaults)}
	catch {unset ins(current_timetypes)}
	set infilecnt [lindex $saved_cmd $evv(CMD_INFILECNT)]		 ;#	Find start of params in cmdline 
	set params_offset [expr int ($evv(CMD_PROPS_OFFSET) + $evv(CDP_PROPS_CNT) + $infilecnt + 1)]
																	 ;#	Extra one is for ofil
	set files_warning 0
	
	while {$gcnt < $gdg_cnt} {
		if {[IsDeadParam $gcnt]} {
			incr pcnt
			incr gcnt
		}
		if {$ins_variable_store($gcnt)} {						 ;# If it's a prm marked as an INSTRUMENT-variable
			set return_val 1
			set gadgspec [ReconstructGadgetSpec $gcnt]
			lappend ins(current_gdg_store) $gadgspec 			 ;#	Temporarily save gadget-spec

			set param_position [expr int($params_offset + $pcnt)]	 ;#	Get position of this prm on saved cmdline
			set machin_dflt [lindex $saved_cmd $param_position]  ;#	save val entered, as defaultval for ins
			if [string match $evv(NUM_MARK)* $machin_dflt] {
				set machin_dflt [string range $machin_dflt 1 end]	 ;# If ness, remove numeric-val marker
			}
			if {$timetype_exists && [string match *FADE* $parname($gcnt)]} {
				switch -regexp -- $timetype \
					^$evv(EDIT_SECS)$    {set ins_sub_dflt $dfault($pcnt)} \
					^$evv(EDIT_SAMPS)$   {set ins_sub_dflt $sdfault($pcnt)} \
					^$evv(EDIT_STSAMPS)$ {set ins_sub_dflt $stsdfault($pcnt)}

			} else {					
				set ins_sub_dflt $dfault($pcnt)
			}
			if {$gdg_typeflag($gcnt) == $evv(SWITCHED)} {			;# Switched gadgets have 2 params, so....
				lappend	ins(current_timetypes) 0
				lappend ins(current_defaults) $machin_dflt 	 	 	
				lappend ins(current_subdefaults) $ins_sub_dflt 	
				incr param_position								 	 	
				set machin_dflt [lindex $saved_cmd $param_position]
				if [string match $evv(NUM_MARK)* $machin_dflt] {
					set machin_dflt [string range $machin_dflt 1 end]	 
				}													 ;# If ness, remove numeric-val marker
				incr pcnt
				set ins_sub_dflt $dfault($pcnt)
				incr pcnt -1
			}														 
			lappend ins(current_defaults) $machin_dflt 			 ;#	A list of these vals
			lappend ins(current_subdefaults) $ins_sub_dflt 	 ;#	A list of these vals
			if {$timetype_exists} {									 ;#	WARNING Code relies on fact there are NO switched
				if [string match *FADE* $parname($gcnt)] {			 ;#	gadgets in any timetype processes (laziness!)
					lappend	ins(current_timetypes) 1
				} else {
					lappend	ins(current_timetypes) 0
				}
			} else {
				lappend	ins(current_timetypes) 0
			}
		} elseif {[info exists pa($prm($pcnt),$evv(FTYP))]} {
			if {($gdg_typeflag($gcnt) == $evv(OPTIONAL_FILE)) || ($gdg_typeflag($gcnt) == $evv(FILENAME))} {
				set msg "                                           WARNING:\n\n"
				append msg "Parameter '$prm($pcnt)'  for  [GetParName $pcnt] : \n\n"
				append msg "If this file is later deleted, the Instrument will no longer work.\n\n"
				Inf $msg
			} elseif {!$files_warning} {
				set msg "                                           WARNING:\n\n"
				append msg "Parameter '$prm($pcnt)'  for  [GetParName $pcnt] : \n\n"
				append msg "It is unwise to use a file as a FIXED PARAMETER when creating an instrument\n"
				append msg "when a numeric parameter is possible.\n\n"
				append msg "If the parameter file is later deleted, the Instrument will no longer work.\n\n"
				append msg "Use a numeric parameter for now, and SET THE PARAMETER AS A VARIABLE.\n\n"
				append msg "You can then use the parameter FILE when you RUN the instrument."
				Inf $msg
				set files_warning 1
			}
		}
		if {$gdg_typeflag($gcnt) == $evv(SWITCHED)} {			 ;#	Has 2 params
			incr pcnt
		}		
		incr pcnt
		incr gcnt
	}
	if [info exists ins(current_timetypes)] {
		RationaliseTimetypeData
	}
	if [info exists ins(current_gdg_store)] {
		RepackageGadgets 
	}
	return return_val
}

#------ Put brackets around the gadget information

proc RepackageGadgets {} {
	global ins
	set process_index $ins(process_cnt)
	incr process_index -1
	set ins(current_gdg_store) [concat $process_index $ins(current_gdg_store)]
	set zart "\{"
	append zart $ins(current_gdg_store)
	append zart "\}"
	set ins(current_gdg_store) $zart
}

#------ Rationalise the data about the time-type of any appropriate params

proc RationaliseTimetypeData {} {
	global ins timetype

	foreach tt $ins(current_timetypes) {		
		if {$tt} {								;#	If any parameter flagged as timetype dependent
			break								;#	break from loop
		}
	}
	if {$tt} {									;#	If any parameter flagged as timetype dependent
		set x $timetype							;#	Insert the timetype value at head of list
	} else {									;#	Otherwise, destroy the data
		set x -1
	}
	set ins(current_timetypes) [concat $x $ins(current_timetypes)]
}

#------ Add the process name, and number, to the parameter name

proc ReconstructGadgetSpec {gcnt} {
	global saved_cmd tpn ins pg_spec evv

	set gadgspec [lindex $pg_spec $gcnt]
	set gadgname [lindex $gadgspec 1]
	set pno [lindex $saved_cmd $evv(CMD_PROCESSNO)]
	set mno [lindex $saved_cmd $evv(CMD_MODENO)]
	if {$mno > 0} {
		incr mno -1
	}
	set prgname [lindex $tpn($pno) $mno]
	if {[llength $prgname] > 1} {
		set newprgname [lindex $prgname 0]
		foreach word [lrange $prgname 1 end] {
			append newprgname "_" $word
		}
		set prgname $newprgname
	}
	append gadgname "_:_\(" $ins(process_cnt) "\)_" $prgname 
	
	set gadgspec [list $gcnt $gadgname]
	return $gadgspec
}

#------ Store all the data about the current process: for use of ins
#
#	If any prop is to be a variable when ins runs, append its gdg_spec to a list
#	Store process-name, for use in tree-diagram
#	Save cmdline, substituting markers for infiles, & stripping out pa vals
#	Clear file display on Instrument-Tree window
#
#	CMDLINE STARTS OUT AS....
#  (0)	progname processno modeno infilecnt props................. filename filename ... param0 param1 param2 param3....
#	AFTER REMOVING PROPS DATA...
#  (1)	progname processno modeno infilecnt filename filename ... param0 param1 param2 param3....
#	AFTER SUBSTITUTING FOR INSTRUMENT-VARIABLE PARAMS...
#  (2)	progname processno modeno infilecnt filename filename ... param0 # # param3....
#	AFTER SUBSTITUTING FOR TRUE-INFILE NAMES...
#  (3)	progname processno modeno infilecnt filename @0 ... param1 # # param3....
#

proc StoreInsProcessData {} {
	global ins saved_cmd ins_file_lst tree pprg mmod tpn
	global progno modeno


	if {!$ins(data_stored)} {				;#	If process-data not yet stored (user could press KEEP twice)

		#(0)
		set saved_cmd [ShortenCmdline]		;#	Discard infile props from saved cmdline
		#(1)
		if [info exists ins(current_gdg_store)] { ;#	Store gadget-spec for params declared 'variable'
			if [info exists ins(gadgets)] {
				set ins(gadgets) [concat $ins(gadgets) $ins(current_gdg_store)]
			} else {
				set ins(gadgets) $ins(current_gdg_store)
			}
			if [info exists ins(defaults)] {
				set ins(defaults) [concat $ins(defaults) $ins(current_defaults)]
			} else {
				set ins(defaults) $ins(current_defaults)
			}
			if [info exists ins(subdefaults)] {
				set ins(subdefaults) [concat $ins(subdefaults) $ins(current_subdefaults)]
			} else {
				set ins(subdefaults) $ins(current_subdefaults)
			}
			if [info exists ins(current_timetypes)] {
				lappend ins(timetypes) $ins(current_timetypes)
			}
			MarkVariableParamsInCmdline			;#	Replace vals of ins-variable params, in cmdline, by markers
												;#	Also, save their values, for hst
		#(2)
		}

 		if {![CompleteThisProcessTreeData]} { 	;#	Save output data for the tree diagram: and grow tree
			return 0
		}										;#	If there are any Input (not recycled) files to this process
		if [info exists tree(nonrecycled_file_inlist_pos)] {	
			if {![PrestorePropsData_and_DoInfilenameSubstitutions]} {			
				return 0						;#	Store params to calc required-props [decode later]
			}									;#	Substitute TRUEinfile-names by numbered markers
		#(3)
			
		}
		lappend ins(cmdset) "$saved_cmd"	;#	Save the revised cmdline
		set mmode $mmod
		if {$mmode > 0} {
			incr mmode -1
		}
		lappend tree(procnames) "[lindex $tpn($pprg) $mmode]"	
												;#	Save the process-name(for tree-display)
	}											
	set ins(data_stored) 1					;#	Prevents attempt to save InstrumentProcess-spec twice!!

	if [info exists ins_file_lst] {
		$ins_file_lst delete 0 end	;#	Clear the process-infile listing on INSTRUMENT-TREE dialog
	}
	catch {unset tree(filetype)}				;#	Clear the associated file-typing data
												;#	ready for next ins-process
	return 1
}

#------ Store those values which will allow us to calculate required infile props at a later stage
#
#	Instrumentprops listing associated with TRUE infiles (list) to ins (later)
#	
#	At each process, an infile might be reused, so the appropriate list of conditions is lappended
#	each time it is used
#

proc PrestorePropsData_and_DoInfilenameSubstitutions {} {
	global tree ins evv pprg mmod saved_cmd

	set j 0										
	foreach position "$tree(nonrecycled_file_inlist_pos)" fileno "$tree(nonrecycled_file_fileno)" {		
												;#	ins(conditions) list-order corresponds to Infile numbers
		set this_insprops "$pprg $mmod $position"
												;#	Store params for procuring props required of infile(fileno)
		#TESTING CODE BELOW
		if {($fileno > 1) && ($fileno > [llength $ins(conditions)])} {
			ErrShow "Miscounting instrument properties list"
			return 0
		}
		if {$position >= [lindex $saved_cmd $evv(CMD_INFILECNT)]} {
			ErrShow "Infile position in cmdline exceeds infilecnt"
			return 0
		}
		#TESTING CODE ABOVE											
												;# Add to end of ins(condits) list,if completely-new infile.
		if {![info exists ins(conditions)] || ($fileno == [llength $ins(conditions)])} { 
				set zart "\{"
				append zart $this_insprops
				append zart "\}"
				set this_insprops $zart
			lappend ins(conditions) "$this_insprops"
		} else {								;#	Append to an existing propslist,if infile input to previous process
			set oldprops [lindex $ins(conditions) $fileno]
			set do_lappend 1
			foreach propset $oldprops {
				if {([lindex $propset 0] == $pprg) \
				&&  ([lindex $propset 1] == $mmod) \
				&&  ([lindex $propset 2] == $position)} {
					set do_lappend 0
					break
				}
			}
			if {$do_lappend} {
				lappend oldprops $this_insprops
				set ins(conditions) "[lreplace $ins(conditions) $fileno $fileno "$oldprops"]"
			}			
		}										;#	Find prm position in (shortened) cmdline
		set param_pos [expr int($evv(CMD_PROPS_OFFSET) + $position)]
		set str $evv(INFIL_MARK)				;#	Replace true-infilename by marker '~N.ext'
		append str $fileno						;#	where N is infile-number, and ".ext" is extension of orig file
		append str [file extension [lindex $saved_cmd $param_pos]]
												;#	(Latter is for later legibility as textfile!!)
		set saved_cmd "[lreplace $saved_cmd $param_pos $param_pos $str]"
	}
	return 1
}

#------ Remove fileprops from cmdline

proc ShortenCmdline {} {
	global evv saved_cmd
	set cmdline [lrange $saved_cmd 0 $evv(CMD_INFILECNT)]
	set offset [expr int($evv(CMD_PROPS_OFFSET) + $evv(CDP_PROPS_CNT))]
	set cmdline_end [lrange $saved_cmd $offset end]  
	set cmdline [concat $cmdline $cmdline_end]
	return $cmdline
}

#------ Mark ins-variable-params in the saved cmdline

proc MarkVariableParamsInCmdline {} {
	global gdg_cnt gdg_typeflag saved_cmd ins_variable_store hst evv
	set gcnt 0
	set pcnt 0
	set infilecnt [lindex $saved_cmd $evv(CMD_INFILECNT)]		 ;#	Find start of params in cmdline 
	set params_offset [expr int($evv(CMD_PROPS_OFFSET) + $infilecnt + 1)]
																	 ;# NB props have been REMOVED from saved_cmd
	while {$gcnt < $gdg_cnt} {				
		if {[IsDeadParam $gcnt]} {
			incr pcnt
			incr gcnt
		}
		if {$ins_variable_store($gcnt)} {						 ;# If it's a prm marked as a INSTRUMENT-variable
			set param_position [expr int($params_offset + $pcnt)]	 ;#	Get position of this prm on saved cmdline
			lappend hst(ins_params) [lindex $saved_cmd $param_position]
																	 ;#	Save ins-variable params, for hst
			set saved_cmd "[lreplace $saved_cmd $param_position $param_position $evv(VARP_MARK)]"
																	 ;#	Replace val by marker in cmdline
			if {$gdg_typeflag($gcnt) == $evv(SWITCHED)} {		 ;# Switched gadgets have 2 params, so....
				incr param_position								 	 ;#	save 2nd-prm val, as default for ins
				set saved_cmd "[lreplace $saved_cmd $param_position $param_position $evv(VARP_MARK)]"
																	 ;#	Replace 2nd val by marker in cmdline
			}														 
		}
		if {$gdg_typeflag($gcnt) == $evv(SWITCHED)} {			;#	Has 2 params
			incr pcnt
		}		
		incr pcnt
		incr gcnt
	}
}

#------ Complete tree-data relating to current process, in this ins
#
#	Add the ofil data to the tree-file line, and to the filenames listing
#	NB Instrument processes with NO outfiles, are automatically aborted at 'KEEP'
#	Move the counting-base forward, for infile or ofil data counting
#	Increment the tree-line pointer
#

proc CompleteThisProcessTreeData {} {
	global o_nam tree ins_oputputs

	if {$tree(this_process_inputs_cnt) <= 0} {
		set tree(this_process_infilenos) {}
	}

	if [info exists tree(current_infiles)] {
		if [info exists tree(fnams)] {
			set tree(fnams) [concat $tree(fnams) $tree(current_infiles)]	   
		} else {
			set tree(fnams) $tree(current_infiles)
		}
	}											   					 
	catch {unset tree(this_process_outfilenos)}

	set j 0					  					
	set fnams [glob -nocomplain "$o_nam*"]
	if {[llength $fnams] > 0} {
		foreach fnam $fnams {
			lappend tree(this_process_outfilenos) $tree(file_index)	;#	Create local list of process outputs
			incr tree(file_index)
			set thisfname out
			append thisfname $tree(outfile_counter) ":" $fnam 	;#	Creates 'outN:filename' on each line
			lappend tree(fnams) $thisfname						;#	Add outfilename-data to list of fnams
			incr tree(outfile_counter)
			incr j
		}
	} else {
		set tree(this_process_outfilenos) {}
	}
	GrowTree
	return 1
}

#------ Reconstruct the tree-data from the inputfile and outputfile data

proc GrowTree {} {
	global ins tree

	set j 0
	foreach in $tree(this_process_infilenos) {	 ;#	????? PROGRAMMING ???? Works with empty list ??
		if {$j > 0} {
			append thistreeunit ","
		}
		append thistreeunit $in
		incr j
	}
	append thistreeunit ":"
	set j 0
	foreach out $tree(this_process_outfilenos) { ;#	????? PROGRAMMING ???? Works with empty list ??
		if {$j > 0} {
			append thistreeunit ","
		}
		append thistreeunit $out
		incr j
	}
	lappend ins(tree) $thistreeunit
	incr tree(process_cnt)						 ;#	Count the (processes) lines in treefile
}

#------ Get name for new ins, which is valid, and not already used

proc GetAcceptableInsName {} {
	global new_mach_name pr_ins pr_newmach ins m_name inames ins evv
	global prg
	set f .new_mach_name	
	if [Dlg_Create $f "Name the New Instrument" "set pr_newmach 0" -borderwidth $evv(BBDR)] {
		set fe [frame $f.e -borderwidth $evv(SBDR)]
		set ff [frame $f.f -borderwidth $evv(SBDR)]
		button $fe.ok -text "OK"             -command "set pr_newmach 1" -highlightbackground [option get . background {}]
		label  $fe.lab -text "Name" -width 6
		button $fe.b  -text "Abandon Instrument" -command "set pr_newmach 0" -highlightbackground [option get . background {}]
		entry $fe.e -width 32 -textvariable m_name
		pack $fe.ok $fe.lab $fe.e -side left -padx 2 
		pack $fe.b -side right
		label $f.lab -text "Existing names"
		pack $f.e $f.lab -side top 
		set inames [Scrolled_Listbox $ff.list -width 24 -height 10 -selectmode single]
		pack $ff.list -side top -fill both -expand true
		pack $f.f -side top -fill both -expand true						
		bind $inames <ButtonRelease-1> {SelectMname}
		bind $f <Return> {set pr_newmach 1}
		bind $f <Escape> {set pr_newmach 0}
		wm resizable $f 1 1
	}
	set finished 0
	set pr_newmach 0
	$inames delete 0 end
	if [info exists ins(names)] {
		foreach inam $ins(names) {
			$inames insert end $inam
		}
	}
	raise $f
	My_Grab 0 $f pr_newmach $f.e.e

	while {!$finished} {
		tkwait variable pr_newmach
		if {$pr_newmach == 0} {
			set pr_ins $evv(INS_ABORTED)
			set finished 1
		} else {
			set OK 1
			set m_name [FixTxt $m_name "instrument name"]
			if {[string length $m_name] <= 0} {
				ForceVal $f.e.e $m_name
				continue
			}
			set lmn [string tolower $m_name]
			set i 1
			while {$i <= $evv(MAX_PROCESS_NO)} {
				if {![info exists prg($i)]} {
					incr i
					continue
				}
				set process_name [string tolower [lindex $prg($i) $evv(UMBREL_INDX)]]
				if [string match $lmn $process_name] {
					Inf "Instrument has same name as a CDP process: Cannot use this name."
					set m_name ""
					ForceVal $f.e.e $m_name
					set OK 0
					break
				} elseif [string match  $i,* $lmn] {
					Inf "Instrument has same name as a CDP process number: Cannot use this as a name."
					set m_name ""
					ForceVal $f.e.e $m_name
					set OK 0
					break
				}
				incr i
			}
			if {!$OK} {
				continue
			}
			set OK 1
			if [info exists ins(names)] {
				foreach m $ins(names) {
					if [string match $lmn [string tolower $m]] {
						Inf "This instrument already exists."
						set OK 0
						break
					}
				}
				if {!$OK} {
					continue
				}
			}
			if [ValidCDPRootname $lmn] { 
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $lmn
}

#------ Save info re current ins to ins-superlist: list new ins on ins-listing

proc SaveInsInfo {} {

	global tree ins inslisting

	DoHistory
	set ins(this) $ins(name)
	if {![info exists ins(conditions)]} { 	;#	If no input files, setup empty list for props
		set ins(conditions) {}
	}
	if {![info exists ins(gadgets)]} {		;#	If no variable params for ins, setup empty list
		set ins(gadgets) {}
	}
	if {![info exists ins(defaults)]} {		;#	If no variable params for ins, setup empty list
		set ins(defaults) {}
	}
	if {![info exists ins(subdefaults)]} {	;#	If no variable params for ins, setup empty list
		set ins(subdefaults) {}
	}
	if {![info exists ins(timetypes)]} {	;#	If no variable params for ins, setup empty list
		set ins(timetypes) {}
	}
	lappend ins(this) "$ins(cmdset)" "$ins(gadgets)" "$ins(conditions)" "$ins(tree)" 
	lappend ins(this) "$tree(fnams)" "$tree(procnames)" "$ins(defaults)" "$ins(subdefaults)"
	lappend ins(this) "$ins(timetypes)"

	set orig_uber ins(uberlist)
	lappend ins(uberlist) $ins(this)

	if [NewInsInfoToFile] {
		lappend ins(names) $ins(name)
		$inslisting insert end $ins(name)
		set cnt 0
		foreach item $tree(fnams) {
			if [regexp {^in} $item] {			;#	Count all infiles to ins
				incr cnt
			}
		}
		lappend ins(infilecnts) $cnt
		incr ins(cnt)
	} else {
		Inf "Cannot save your new instrument to file: Abandoning it."
		set ins(uberlist) orig_uber
	}
}

###############
# INSTRUMENTS #
###############

#------ Permanently destroy Instruments selected from displayed list

proc DestroyIns {} {
	global ins_destroyed inslisting wstk ins pr_destroymach sl_real evv
	global batchId gadgetId defaultsId subdefaultsId timetypeId propsId treeId fnamesId pnamesId

	if {!$sl_real} {
		Inf "Instruments You Have Created Can Also Be Destroyed, From This Listing."
		return
	}
	set all_list [$inslisting get 0 end]
	set len [llength $all_list]
	if {$len == 1} {
		set indx 0
	} else {
		set indx [$inslisting curselection]
		if {[llength $indx] <= 0} {
			Inf "No item selected"
			return
		}
	}
	set thisname [$inslisting get $indx]
	set choice [tk_messageBox -type yesno -message  "Destroy instrument '$thisname' forever??" \
				-icon question -parent [lindex $wstk end]]
	if {$choice == "no"}  {
		return
	}
	catch {close $batchId}				;# precautionary !! Close all related files
	catch {close $gadgetId}
	catch {close $defaultsId}
	catch {close $subdefaultsId}
	catch {close $timetypeId}
	catch {close $propsId}
	catch {close $treeId}
	catch {close $fnamesId}
	catch {close $pnamesId}				;#	Destroy disk-stored info re this ins

	set fnam [file join $evv(INS_DIR) $thisname$evv(INS_BATCH)]
	if [file exists $fnam] {
		if [catch {file delete $fnam} zorg] {
			Inf "Cannot delete file '$thisname$evv(INS_BATCH)'"
		}
	}
	set fnam [file join $evv(INS_DIR) $thisname$evv(INS_GADGETS)]
	if [file exists $fnam] {
		if [catch {file delete $fnam} zorg] {
			Inf "Cannot delete file '$thisname$evv(INS_GADGETS)'"
		}
	}
	set fnam [file join $evv(INS_DIR) $thisname$evv(INS_FILEPROPS)]
	if [file exists $fnam] {
		if [catch {file delete $fnam} zorg] {
			Inf "Cannot delete file '$thisname$evv(INS_FILEPROPS)'"
		}
	}
	set fnam [file join $evv(INS_DIR) $thisname$evv(INS_TREE)]
	if [file exists $fnam] {
		if [catch {file delete $fnam} zorg] {
			Inf "Cannot delete file '$thisname$evv(INS_TREE)'"
		}
	}
	set fnam [file join $evv(INS_DIR) $thisname$evv(INS_FNAMES)]
	if [file exists $fnam] {
		if [catch {file delete $fnam} zorg] {
			Inf "Cannot delete file '$thisname$evv(INS_FNAMES)'"
		}
	}
	set fnam [file join $evv(INS_DIR) $thisname$evv(INS_PNAMES)]
	if [file exists $fnam] {
		if [catch {file delete $fnam} zorg] {
			Inf "Cannot delete file '$thisname$evv(INS_PNAMES)'"
		}
	}
	set fnam [file join $evv(INS_DIR) $thisname$evv(INS_DEFAULTS)]
	if [file exists $fnam] {
		if [catch {file delete $fnam} zorg] {
			Inf "Cannot delete file '$thisname$evv(INS_DEFAULTS)'"
		}
	}
	set fnam [file join $evv(INS_DIR) $thisname$evv(INS_SUBDEFAULTS)]
	if [file exists $fnam] {
		if [catch {file delete $fnam} zorg] {
			Inf "Cannot delete file '$thisname$evv(INS_SUBDEFAULTS)'"
		}
	}
	set fnam [file join $evv(INS_DIR) $thisname$evv(INS_TIMETYPE)]
	if [file exists $fnam] {
		if [catch {file delete $fnam} zorg] {
			Inf "Cannot delete file '$thisname$evv(INS_TIMETYPE)'"
		}
	}
	set i [lsearch -exact $ins(names) $thisname]		;#	Remove this ins from list of ins-names
	set ins(names) [lreplace $ins(names) $i $i]
	set i 0
	foreach m $ins(uberlist) {
		set mname [lindex $m 0]
		if [string match $mname $thisname] {
			set ins(uberlist) 	[lreplace $ins(uberlist) $i $i]
			set ins(infilecnts) [lreplace $ins(infilecnts) $i $i]
			break
		}
		incr i
	}
	set i 0
	foreach mname $ins(names) {
		if [string match $mname $thisname] {
			set ins(names) [lreplace $ins(names) $i $i]
			break
		}
		incr i
	}
	if [catch {open $evv(DFLT_TMPFNAME) w} fileId] {
		ErrShow "Cannot open temporary file to save revised list of instruments. "
		Inf "SUGGESTION: Delete instrument '$thisname' from file '$fnam', using a textfile editor, to avoid future problems."
	} else {
		foreach name $ins(names) {				;#	Save the ammended list of existing Instruments
			puts $fileId "$name"
		}
		close $fileId
		set fnam [file join $evv(INS_DIR) $evv(INS_LIST)]
		if [catch {file delete $fnam} zorg] {
			Inf "Cannot delete existing instrument-names listing, to write revised list."
			Inf "SUGGESTION: Delete instrument '$thisname' from file '$fnam', using a textfile editor, to avoid future problems."
		} elseif [catch {file rename $evv(DFLT_TMPFNAME) $fnam}] {
			Inf "Cannot save the revised list of instrument names."
			Inf "SUGGESTION: Delete instrument '$thisname' from file '$fnam', using a textfile editor, to avoid future problems."
		}
	}
	$inslisting delete 0 end
	foreach m $ins(names) {
		$inslisting insert end $m
	}
	incr ins(cnt) -1
}

#------ Save-to-file the accumulated information about new Instruments

proc NewInsInfoToFile {} {
	global tree ins evv
	global batchId gadgetId defaultsId subdefaultsId timetypeId propsId treeId fnamesId pnamesId

	if [catch {open [file join $evv(INS_DIR) $evv(INS_LIST)] a} insnamesId] {
		Inf "Cannot open file to store instrument names: Cannot store new instruments"
		return 0
	}
	set m "[lindex $ins(uberlist) end]"

	set j 0
	foreach item $m {	 
		switch -- $j {
			0 	{set name 			  "$item"}
			1	{set ins(cmdset) 	  "$item"}
			2	{set ins(gadgets)  	  "$item"}
			3	{set ins(conditions)  "$item"}
			4	{set ins(tree) 	 	  "$item"}
			5	{set tree(fnams) 	  "$item"}
			6	{set tree(procnames)  "$item"}
			7	{set ins(defaults) 	  "$item"}
			8	{set ins(subdefaults) "$item"}
			9	{set ins(timetypes)   "$item"}
			default {
				ErrShow "Too many data sets stored for instrument $name: cannot save it"
				catch {close $insnamesId}
				return 0
			}
		}
		incr j
	}
	if {$j < 10} {
		ErrShow "Insufficient data sets stored for instrument $name: cannot save it"
		catch {close $insnamesId}
		return 0
	}
	if [catch {open [file join $evv(INS_DIR) $name$evv(INS_BATCH)] w} batchId] {
		Inf "Cannot open File '$name$evv(INS_BATCH)' to store instrument '$name data'"
		catch {close $insnamesId}
		return 0
	}
	if [catch {open [file join $evv(INS_DIR) $name$evv(INS_GADGETS)] w} gadgetId] {
		Inf "Cannot open File '$name$evv(INS_GADGETS)' to store instrument '$name' parameter-entry data"
		close $batchId
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_BATCH)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_BATCH)]'"
		}
		catch {close $insnamesId}
		return 0
	}
	if [catch {open [file join $evv(INS_DIR) $name$evv(INS_FILEPROPS)] w} propsId] {
	Inf "Cannot open File '$name$evv(INS_FILEPROPS)' to store instrument '$name' file-properties data"
		close $batchId
		close $gadgetId
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_BATCH)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_BATCH)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_GADGETS)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_GADGETS)]'"
		}
		catch {close $insnamesId}
		return 0
	}
	if [catch {open [file join $evv(INS_DIR) $name$evv(INS_TREE)] w} treeId] {
		Inf "Cannot open File '$name$evv(INS_TREE)' to store instrument '$name' tree data"
		close $batchId
		close $gadgetId
		close $propsId
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_BATCH)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_BATCH)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_GADGETS)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_GADGETS)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_FILEPROPS)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_FILEPROPS)]'"
		}
		catch {close $insnamesId}
		return 0
	}
	if [catch {open [file join $evv(INS_DIR) $name$evv(INS_FNAMES)] w} fnamesId] {
		Inf "Cannot open File '$name$evv(INS_FNAMES)' to store instrument '$name' tree data"
		close $batchId
		close $gadgetId
		close $propsId
		close $treeId
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_BATCH)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_BATCH)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_GADGETS)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_GADGETS)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_FILEPROPS)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_FILEPROPS)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_TREE)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_TREE)]'"
		}
		catch {close $insnamesId}
		return 0
	}
	if [catch {open [file join $evv(INS_DIR) $name$evv(INS_PNAMES)] w} pnamesId] {
		Inf "Cannot open File '$name$evv(INS_PNAMES)' to store instrument '$name' tree data"
		close $batchId
		close $gadgetId
		close $propsId
		close $treeId
		close $fnamesId
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_BATCH)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_BATCH)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_GADGETS)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_GADGETS)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_FILEPROPS)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_FILEPROPS)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_TREE)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_TREE)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_FNAMES)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_FNAMES)]'"
		}
		catch {close $insnamesId}
		return 0
	}
	if [catch {open [file join $evv(INS_DIR) $name$evv(INS_DEFAULTS)] w} defaultsId] {
		Inf "Cannot open File '$name$evv(INS_DEFAULTS)' to store instrument '$name' tree data"
		close $batchId
		close $gadgetId
		close $propsId
		close $treeId
		close $fnamesId
		close $pnamesId
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_BATCH)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_BATCH)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_GADGETS)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_GADGETS)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_FILEPROPS)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_FILEPROPS)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_TREE)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_TREE)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_FNAMES)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_FNAMES)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_PNAMES)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_PNAMES)]'"
		}
		catch {close $insnamesId}
		return 0
	}
	if [catch {open [file join $evv(INS_DIR) $name$evv(INS_SUBDEFAULTS)] w} subdefaultsId] {
		Inf "Cannot open File '$name$evv(INS_SUBDEFAULTS)' to store instrument '$name' tree data"
		close $batchId
		close $gadgetId
		close $propsId
		close $treeId
		close $fnamesId
		close $pnamesId
		close $defaultsId
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_BATCH)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_BATCH)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_GADGETS)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_GADGETS)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_FILEPROPS)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_FILEPROPS)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_TREE)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_TREE)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_FNAMES)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_FNAMES)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_PNAMES)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_PNAMES)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_DEFAULTS)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_DEFAULTS)]'"
		}
		catch {close $insnamesId}
		return 0
	}
	if [catch {open [file join $evv(INS_DIR) $name$evv(INS_TIMETYPE)] w} timetypeId] {
		Inf "Cannot open File '$name$evv(INS_TIMETYPE)' to store instrument '$name' tree data"
		close $batchId
		close $gadgetId
		close $propsId
		close $treeId
		close $fnamesId
		close $pnamesId
		close $defaultsId
		close $subdefaultsId
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_BATCH)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_BATCH)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_GADGETS)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_GADGETS)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_FILEPROPS)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_FILEPROPS)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_TREE)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_TREE)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_FNAMES)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_FNAMES)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_PNAMES)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_PNAMES)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_DEFAULTS)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_DEFAULTS)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_SUBDEFAULTS)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_SUBDEFAULTS)]'"
		}
		catch {close $insnamesId}
		return 0
	}
	if {[llength $ins(defaults)] != [llength $ins(subdefaults)]} {
		ErrShow "Counts of gadgets-defaults and of gadget-subdefaults do not tally: can't save instrument $name"
		close $batchId
		close $gadgetId
		close $propsId
		close $treeId
		close $fnamesId
		close $pnamesId
		close $defaultsId
		close $subdefaultsId
		close $timetypeId
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_BATCH)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_BATCH)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_GADGETS)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_GADGETS)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_FILEPROPS)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_FILEPROPS)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_TREE)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_TREE)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_FNAMES)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_FNAMES)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_PNAMES)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_PNAMES)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_DEFAULTS)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_DEFAULTS)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_SUBDEFAULTS)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_SUBDEFAULTS)]'"
		}
		if [catch {file delete [file join $evv(INS_DIR) $name$evv(INS_TIMETYPE)]} zorg] {
			Inf "Cannot delete file '[file join $evv(INS_DIR) $name$evv(INS_TIMETYPE)]'"
		}
		catch {close $insnamesId}
		return 0
	}
	foreach data_item $ins(cmdset) {
		puts $batchId "$data_item"
	}
	foreach data_item $ins(tree) {
		puts $treeId "$data_item"
	}
	foreach data_item $tree(fnams) {
		puts $fnamesId "$data_item"
	}
	foreach data_item $tree(procnames) {
		puts $pnamesId "$data_item"
	}
	foreach data_item $ins(gadgets) {		;#	Could be NO gadgets if no variable params for ins: 
		puts $gadgetId "$data_item"			;#	In THAT case, saves empty file
	}
	foreach data_item $ins(defaults) {		;#	Could be NO defaults if no variable params for ins
		puts $defaultsId "$data_item"		;#	In THAT case, saves empty file
	}
	foreach data_item $ins(subdefaults) {	;#	Could be NO defaults if no variable params for ins
		puts $subdefaultsId "$data_item"	;#	In THAT case, saves empty file
	}
	foreach data_item $ins(timetypes) {		;#	Could be NO timetypes if no variable params for ins
		puts $timetypeId "$data_item"		;#	In THAT case, saves empty file
	}
	set j [llength $ins(conditions)]		;#	Could be NO props if no infiles: in THAT case, saves empty file
	if {$j > 0} {
		puts $propsId "$j"					  ;#	Store total number of infiles
		foreach file_props $ins(conditions) { ;#	For each infile
			set j [llength $file_props]
			puts $propsId "$j"				;#	Store number of conditions for this-infile
			foreach condition $file_props {
				puts $propsId "$condition"	;#	Store conditions for this-infile
			}
		}
	} else {
		puts $propsId 0						;#	Store total number of infiles = 0
	}
	puts $insnamesId "$name"	;#	ONLY when all data stored is ins-name APPENDED to existing list
	close $batchId
	close $gadgetId
	close $defaultsId
	close $subdefaultsId
	close $timetypeId
	close $propsId
	close $treeId
	close $fnamesId
	close $pnamesId
	close $insnamesId
	return 1
}

###################################
# LOAD INSTRUMENTS DATA FROM DISK #
###################################

#------ Load existing Instruments from disk, ready for use	

proc LoadInsNames {} {
	global ins evv
																  
	set mfile [file join $evv(INS_DIR) $evv(INS_LIST)]
	if [file exists $mfile] {
		if [catch {open $mfile r} fileId] {
			ErrShow "Cannot load instruments"
			return 0
		}
	} else {
		return 0
	}
	catch {unset ins(names)}
	set ins(cnt) 0
	while {[gets $fileId mnam] >= 0} {
		if {[string length $mnam] <= 0} {
			Inf "Blank line in ins names file '$evv(INS_LIST)'"
			continue
		}
		if {[file exists [file join $evv(INS_DIR) $mnam$evv(INS_BATCH)]]
		&&  [file exists [file join $evv(INS_DIR) $mnam$evv(INS_GADGETS)]]
		&&  [file exists [file join $evv(INS_DIR) $mnam$evv(INS_FILEPROPS)]]
		&&  [file exists [file join $evv(INS_DIR) $mnam$evv(INS_TREE)]]
		&&  [file exists [file join $evv(INS_DIR) $mnam$evv(INS_FNAMES)]] 
		&&  [file exists [file join $evv(INS_DIR) $mnam$evv(INS_PNAMES)]] 
		&&  [file exists [file join $evv(INS_DIR) $mnam$evv(INS_DEFAULTS)]]
		&&  [file exists [file join $evv(INS_DIR) $mnam$evv(INS_SUBDEFAULTS)]]
		&&  [file exists [file join $evv(INS_DIR) $mnam$evv(INS_TIMETYPE)]]} {
			lappend ins(names) $mnam
			incr ins(cnt)
		} else {
			Inf "Insufficient data-files for instrument '$mnam'"
		}
	}
	close $fileId
	if [info exists ins(names)] {
		set ins(names) [lsort -dictionary $ins(names)]
		return 1
	}
	return 0
}

#------ Load-from-file the information about existing Instruments

proc LoadInsInfo {} {
	global evv ins tree
	global batchId gadgetId defaultsId subdefaultsId timetypeId propsId treeId fnamesId pnamesId

	foreach name $ins(names) {
		if [catch {open [file join $evv(INS_DIR) $name$evv(INS_BATCH)] r} batchId] {
			Inf "Cannot load instrument performance data for '$name'"
			return 0
		}
		if [catch {open [file join $evv(INS_DIR) $name$evv(INS_GADGETS)] r} gadgetId] {
			Inf "Cannot load instrument parameter-gadgets for '$name'"
			close $batchId
			return 0
		}
		if [catch {open [file join $evv(INS_DIR) $name$evv(INS_TREE)] r} treeId] {
			Inf "Cannot load instrument tree data for '$name'"
			close $batchId
			close $gadgetId
			return 0
		}
		if [catch {open [file join $evv(INS_DIR) $name$evv(INS_FNAMES)] r} fnamesId] {
			Inf "Cannot load instrument-tree fnams data for '$name'"
			close $batchId
			close $gadgetId
			close $treeId
			return 0
		}
		if [catch {open [file join $evv(INS_DIR) $name$evv(INS_PNAMES)] r} pnamesId] {
			Inf "Cannot load instrument tree process-names data for '$name'"
			close $batchId
			close $gadgetId
			close $treeId
			close $fnamesId
			return 0
		}
		if [catch {open [file join $evv(INS_DIR) $name$evv(INS_FILEPROPS)] r} propsId] {
			Inf "Cannot load instrument tree file-properties data for '$name'"
			close $batchId
			close $gadgetId
			close $treeId
			close $fnamesId
			close $pnamesId
			return 0
		}
		if [catch {open [file join $evv(INS_DIR) $name$evv(INS_DEFAULTS)] r} defaultsId] {
			Inf "Cannot load instrument tree file-properties data for '$name'"
			close $batchId
			close $gadgetId
			close $treeId
			close $fnamesId
			close $pnamesId
			close $propsId
			return 0
		}
		if [catch {open [file join $evv(INS_DIR) $name$evv(INS_SUBDEFAULTS)] r} subdefaultsId] {
			Inf "Cannot load instrument tree file-properties data for '$name'"
			close $batchId
			close $gadgetId
			close $treeId
			close $fnamesId
			close $pnamesId
			close $propsId
			close $defaultsId
			return 0
		}
		if [catch {open [file join $evv(INS_DIR) $name$evv(INS_TIMETYPE)] r} timetypeId] {
			Inf "Cannot load instrument tree file-properties data for '$name'"
			close $batchId
			close $gadgetId
			close $treeId
			close $fnamesId
			close $pnamesId
			close $propsId
			close $defaultsId
			close $subdefaultsId
			return 0
		}
		if {![LoadInsProps $name $propsId]} {
			close $batchId
			close $gadgetId
			close $treeId
			close $fnamesId
			close $pnamesId
			close $propsId
			close $defaultsId
			close $subdefaultsId
			close $timetypeId
			continue
		}
	 	while { [gets $batchId thisline] >= 0} {	;#	Read lines from textfile into list
			lappend ins(cmdset) "$thisline"
		}
 		set j 0
 		while { [gets $gadgetId thisline] >= 0} {
			lappend ins(gadgets) "$thisline"
			incr j
		}
		if {$j == 0} {
			set ins(gadgets) {}
		}
 		set j 0
 		while { [gets $defaultsId thisline] >= 0} {
			lappend ins(defaults) "$thisline"
			incr j
		}
		if {$j == 0} {
			set ins(defaults) {}
		}
 		set j 0
 		while { [gets $subdefaultsId thisline] >= 0} {
			lappend ins(subdefaults) "$thisline"
			incr j
		}
		if {$j == 0} {
			set ins(subdefaults) {}
		}
 		set j 0
 		while { [gets $timetypeId thisline] >= 0} {
			lappend ins(timetypes) "$thisline"
			incr j
		}
		if {$j == 0} {
			set ins(timetypes) {}
		}
	 	while { [gets $treeId thisline] >= 0} {
			lappend ins(tree) "$thisline"
		}
 		while { [gets $fnamesId thisline] >= 0} {
			lappend tree(fnams) "$thisline"
		}
	 	while { [gets $pnamesId thisline] >= 0} {
			lappend tree(procnames) "$thisline"
		}
		set ins(this) $name
		lappend ins(this) "$ins(cmdset)" "$ins(gadgets)" "$ins(conditions)"  "$ins(tree)"
		lappend ins(this) "$tree(fnams)" "$tree(procnames)" "$ins(defaults)" "$ins(subdefaults)"
		lappend ins(this) "$ins(timetypes)"
		lappend ins(uberlist) "$ins(this)"
		close $batchId
		close $gadgetId
		close $defaultsId
		close $subdefaultsId
		close $timetypeId
		close $treeId
		close $fnamesId
		close $pnamesId
		close $propsId
		unset ins(cmdset)
		unset ins(gadgets)
		unset ins(defaults)
		unset ins(subdefaults)
		unset ins(timetypes)
		unset ins(tree)
		unset tree(fnams)
		unset tree(procnames)
		unset ins(conditions)
	}
}

#------ Load properties of Instrument

proc LoadInsProps {name propsId} {
	global ins

	set in_linecnt 0
 	set conditions 0
 	while { [gets $propsId thisline] >= 0} {
		lappend theselines "$thisline"
		incr in_linecnt
	}
	if {$in_linecnt <= 0} {
		Inf "No data in properties file for instrument '$name'"
		return 0
	}
	set linecnt 0
	set infilecnt [lindex $theselines $linecnt]
	lappend ins(infilecnts) $infilecnt
	if {$infilecnt > 0} {
		incr linecnt
		while {$linecnt < $in_linecnt} {
			set condition_cnt [lindex $theselines $linecnt]
			incr linecnt
			if {$linecnt > $in_linecnt} {
				Inf "Condition-data missing in conditions file for '$name'"
				catch {unset ins(conditions)}
				return 0
			}
			set j 0
			unset conditions
			while {$j < $condition_cnt} {
				lappend conditions "[lindex $theselines $linecnt]"
				incr j
				incr linecnt
				if {$linecnt > $in_linecnt} {
					Inf "Condition missing in conditions file for '$name'"
					catch {unset ins(conditions)}
					return 0
				}
			}
			lappend ins(conditions) "$conditions"
		}
		if {[llength $ins(conditions)] != $infilecnt} {
			Inf "Anomaly in count of stored conditions for instrument '$name'"
			return 0
		}
	} else {
		lappend ins(conditions) {}		;#	No infiles = no properties
	}
	return 1
}

#----- Check if parameter of instr is a vowel

proc InsParamIsVowel {ins_pno} {
	global ins evv

	set varcnt 0
	set checkit 0
	foreach cmdline $ins(cmdset) {
		if {[lindex $cmdline $evv(CMD_PROCESSNO)] == $evv(P_VOWELS)} {
			set checkit 1
			break
		}
	}
	if {!$checkit} {
		return 0
	}
	set checkit 0
	foreach cmdline $ins(cmdset) {
		if {[lindex $cmdline $evv(CMD_PROCESSNO)] == $evv(P_VOWELS)} {
			set checkit 1						  ;# only test if this is process P_VOWELS
		} else {
			set checkit 0
		}
		set pos $evv(CMD_INFILECNT)
		set filecnt [lindex $cmdline $pos]
		incr pos
		incr pos $filecnt 
		incr pos	;#	Step over outfilename
		set thisend [llength $cmdline]
		incr thisend -1
		set parcnt 0
		foreach parameter [lrange $cmdline $pos $thisend] {
			if [string match $evv(VARP_MARK) $parameter] {		;#	"#" only, Instrument variable
				if {$varcnt == $ins_pno} {						;#	IF this is the ins variable we want
					if {$checkit && ($parcnt == 0)} {			;#    if we're at 1st variable in P_VOWELS
						return 1								;#    return TRUE
					} else {									;#    else
						return 0								;#    return FALSE
					}
				} else {										;#  OTHERWISE count the ins variables
					incr varcnt
				}
			}
			incr parcnt											;# count parameters in cmdline
		}
	}
	return 0
}

#-------

proc SelectMname {} {
	global inames m_name

	set i [$inames curselection]
	if {![info exists i] || ($i < 0)} {
		return
	}
	set m_name [$inames get $i]
}

proc InstrInfo {} {
	global maxusagelen usage_message usagecnt evv

	catch {unset usage_message}
	set maxusagelen 0
	set usagecnt 0
	set line ""
	UpdateInfoMessage $line
	set line "                                                  CREATING AND USING INSTRUMENTS"
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "An instrument is a combination of existing processes."
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "1) Almost any process can be included as part of an Instrument definiton."
	UpdateInfoMessage $line
	set line "        (The Sound Loom will prevent you using any processes that are not acceptable in Instrument definitions)."
	UpdateInfoMessage $line
	set line "2) An existing process can be used any number of times in the definition of an instrument."
	UpdateInfoMessage $line
	set line "3) In defining an Instrument, you cannot use other Instruments, Bulk Processing or Batchfile Processing."
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "TO CREATE AN INSTRUMENT ( ***** see also 'INSTRUMENT PARAMETERS' below ******)"
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "1)  Select the file(s) you want to start working on (the file(s) for the FIRST process in your instrument) to the 'Chosen Files' list."
	UpdateInfoMessage $line
	set line "2)  Press the 'Create Instrument' button."
	UpdateInfoMessage $line
	set line "3)  You will find yourself on the Instrument Creation page, with chosen file(s) listed on the left. (You can change the file selection from here)."
	UpdateInfoMessage $line
	set line "4)  Once you are sure you have the correct file(s) selected, press 'Continue', which takes you to the Process page."
	UpdateInfoMessage $line
	set line "5)  Now proceed as normally, selecting a Process, specifying the Parameters, and running the process."
	UpdateInfoMessage $line
	set line "        If you are not satisfied with the output, you can change parameters and run again, or choose a new process."
	UpdateInfoMessage $line
	set line "6)  Once you are satisfied with the process output, Press 'Save Process'."
	UpdateInfoMessage $line
	set line "7)  You will return to the Instrument Creation page where the selected input file(s), the Process and the output(s)"
	UpdateInfoMessage $line
	set line "        will be displayed graphically, with filenames colour-coded as per the key at the top of the page."
	UpdateInfoMessage $line
	set line "8)  As your input to the next process, you can now select EITHER"
	UpdateInfoMessage $line
	set line "        one or more of the output (or input) files in the graphic display (click on the filename in the graphic display)"
	UpdateInfoMessage $line
	set line "        OR completely new input files (using the panel on the left)."
	UpdateInfoMessage $line
	set line "9)  Pressing continue will take you to the Process page once more allowing you to chosse the next process for your Instrument..... and so on."
	UpdateInfoMessage $line
	set line "10) You can abandon instrument creation at any stage by pressing 'Abort' on the Instrument Creation page."
	UpdateInfoMessage $line
	set line "11) Once you have completed your instrument, press 'Conclude' on the Instrument Creation page."
	UpdateInfoMessage $line
	set line "12) On the display which appears, you must now save one or more of the files that your Instrument has created."
	UpdateInfoMessage $line
	set line "        If you do not save any of the outputs, the Instrument will be abandoned. (An instrument with no output is not very useful!). "
	UpdateInfoMessage $line
	set line "13) Once you have saved the files you need, press 'Conclude'."
	UpdateInfoMessage $line
	set line "14) You will now be asked to name the Instrument."
	UpdateInfoMessage $line
	set line "15) Once the Instrument has been created it will appear in the list of 'Instruments' on the Process Page."
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "TO USE AN INSTRUMENT"
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "1) On the process page, instead of selecting a Process from the Process menu, select an Instrument from the 'Instruments' panel on the right."
	UpdateInfoMessage $line
	set line "2) The instrument will look like, and run like, a normal (single) process."
	UpdateInfoMessage $line
	set line "        The display on the 'Run' page will name and count the individual processes being run by your Instrument."
	UpdateInfoMessage $line
	set line "3) You can see what the Instrument does by pressing the 'See' button above the list of Instruments on the Process Page."
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "INSTRUMENT PARAMETERS"
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "1) When you are creating your Instrument, on the Process page you will see an extra small checkbox on the right of each Parameter display."
	UpdateInfoMessage $line
	set line "2) If you want this parameter to also be a parameter of the Instrument you are creating, check this box."
	UpdateInfoMessage $line
	set line "        Later, when you run the Instrument, this parameter will appear on the Parameters page of the Instrument."
	UpdateInfoMessage $line
	set line "3) If you do not check the box, the Instrument will assume that the value of the parameter you have chosen will always be the same."
	UpdateInfoMessage $line
	set line "        When you run the Instrument, the original value will always be used and the Parameter wil not even appear on the Instrument's Parameter page."
	UpdateInfoMessage $line
	set line "        For example, in an Instrument that performs PVOC anaylsis, Time-stretching and PVOC resynthesis,"
	UpdateInfoMessage $line
	set line "        you will probably want to be able to alter the Time-stretching parmater of the created Instrument (tick this parameter),"
	UpdateInfoMessage $line
	set line "        but may want to always use the same number of PVOC-analysis channels (don't tick this parameter)."
	UpdateInfoMessage $line
	set line "3) If you use the name of a file (rather than numeric data) as a Parameter value for your Instrument,"
	UpdateInfoMessage $line
	set line "        and if that parameter is not ticked, the Instrument will automatically look for a file with the original name."
	UpdateInfoMessage $line
	set line "        If the file has been deleted the Instrument will fail."
	UpdateInfoMessage $line
	set line "        i.e. always tick the box for a parameter which uses a file."
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "OTHER ISSUES"
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "1) INSTRUMENTS CANNOT BE EDITED once they have been made,"
	UpdateInfoMessage $line
	set line "        (though they can be deleted, from the Instruments panel on the Process Page)."
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "2) DO NOT MAKE INSTRUMENTS THAT ARE TOO COMPLICATED."
	UpdateInfoMessage $line
	set line "        You may discover later on that you want to add or remove features, or have access to parameters you did not tick."
	UpdateInfoMessage $line
	set line "        As Instruments cannot be edited, you would have to make a new Instrument from scratch."
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "        IT IS OFTEN A GOOD IDEA TO DEVISE AN INSTRUMENT IN TWO PARTS."
	UpdateInfoMessage $line
	set line "        e.g. imagine an Instrument which splits a multichannel file into seperate channels, does PVOC-anaylsis on each channel,"
	UpdateInfoMessage $line
	set line "        spectral processing (on each channel), resynthesis, and channel recombination."
	UpdateInfoMessage $line
	set line "        Each time you run this instrument it will do the channel splitting and analysis of your source afresh (which takes time)."
	UpdateInfoMessage $line
	set line "        It is more efficient to have Instrument-1 for the channel-splitting and analysis,"
	UpdateInfoMessage $line
	set line "        and Instrument-2 for the spectral processing, resynthesis and channel-recombination."
	UpdateInfoMessage $line
	set line "        Then you can run Instrument-1 once, to make the initial analysis data,"
	UpdateInfoMessage $line
	set line "        then run Instrument-2 any number of times, using that data, without having to recreate the data from scratch."
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "3)  IT IS BEST NOT TO USE BREAKPOINT FILES AS PARAMETERS DURING THE CREATION OF AN INSTRUMENT."
	UpdateInfoMessage $line
	set line "        (they can still be used as parameters for the Instrument when you later USE it,"
	UpdateInfoMessage $line
	set line "         so long as the process parameter is set as a parameter of the Instrument ...... see above)."
	UpdateInfoMessage $line
	set line "        If you use a breakpoint while CREATING an Instrument, and you later DELETE (or change directory) of that breakpoint file. "
	UpdateInfoMessage $line
	set line "        a) If it was used for a parameter which is settable from the Instrument, you will receive a warning message,"
	UpdateInfoMessage $line
	set line "              but you can then enter a valid value or filename for the Instrument parameter."
	UpdateInfoMessage $line
	set line "        b) If it was used as a fixed (now hidden) parameter of the Instrument, that Instrument will no longer fuction."
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
}

proc InsMsg {} {
	InsMsg1
	InsMsg2
}

proc InsMsg1 {} {
	set msg "~~ IMPORTANT TIPS ABOUT MAKING INSTRUMENT ~~\n"
	append msg "To get info about Instruments in future\n"
	append msg "use Help on the Workspace page.\n"
	append msg "\n"
	append msg "(1) INSTRUMENT COMPLEXITY.\n"
	append msg "\n"
	append msg "Instruments CAN'T BE EDITED once made.\n"
	append msg "So it's wise to break down complex processes\n"
	append msg "to smaller units, and build a series of instrs.\n"
	append msg "e.g.\n"
	append msg "you might want to perform this sequence.....\n"
	append msg "\n"
	append msg "Split a stereo sound to two mono channels,\n"
	append msg "analyse those 2 to find their spectra,\n"
	append msg "perform some spectral processes on each,\n"
	append msg "then resynthesize both of them,\n"
	append msg "and merge them into a stereo output file.\n"
	append msg "\n"
	append msg "It's best to have 2 instruments,\n"
	append msg "one to create the analysis files,\n"
	append msg "and the other to do everything else.\n"
	append msg "\n"
	append msg "You're likely to want to alter parameter values\n"
	append msg "for the spectral process to get the best result,\n"
	append msg "but you don't need to keep analysing the source\n"
	append msg "every time you do this.\n"
	append msg "Having 2 instruments makes explorations faster.\n"
	append msg "\n"
	append msg "(For complex processes you can also build\n"
	append msg "a batch file: see Help info on batchfiling).\n"
	append msg "\n"
	Inf $msg
}

proc InsMsg2 {} {
	set msg    "(2) DON'T USE BREAKPOINT FILES AS PARAMS\n"
	append msg "      WHILE CREATING AN INSTRUMENT\n"
	append msg "\n"
	append msg "When CREATING an instrument it's best to use\n"
	append msg "numeric values. (You can use breakpoint values\n"
	append msg "when you RUN the Instrument).\n"
	append msg "\n"
	append msg "There are two types of instrument parameters...\n"
	append msg "\n"
	append msg "a)    Fixed parameters, which are always the same,\n"
	append msg "      are NOT entered when the Instrument is used,\n"
	append msg "      and won't even appear on the screen.\n"
	append msg "\n"
	append msg "b)    Variable parameters, which you can SET\n"
	append msg "      when you RUN the Instrument.\n"
	append msg "\n"
	append msg "To set a process parameter as a Variable parameter\n"
	append msg "for the Instrument, you just tick the small box\n"
	append msg "appearing on the right of the parameter display\n"
	append msg "(ONLY when an Instrument is being created).\n"
	append msg "\n"
	append msg "If you use a breakfile while CREATING an Instrument,\n"
	append msg "and subsequently delete, rename or move that file,\n"
	append msg "with Fixed params, the Instrument won't function,\n"
	append msg "while with Variable params, the Instrument will\n"
	append msg "search for the original breakfile and you'll get\n"
	append msg "a warning message every time you use the instrument\n"
	append msg "(you can still proceed, entering the value you want).\n"
	append msg "\n"
	Inf $msg
}

#--- Send tempo shift ratio to process or instrument parameter

proc TempoShift {isins shifter} {
	global pr_temposh temposh0 temposh1 temposhprm prm readonlyfg readonlybg evv
	set temposh0 0
	set temposh1 0
	set temposhprm 0
	set f .temposh
	if [Dlg_Create $f "Tempo Shift Ratio" "set pr_temposh 0" -borderwidth $evv(BBDR)] {
		set b [frame $f.b -borderwidth $evv(SBDR)]
		set r [frame $f.r -borderwidth $evv(SBDR)]
		button $b.ok -text "Get Ratio" -command "set pr_temposh 1" -highlightbackground [option get . background {}]
		entry $b.e -textvariable temposhprm -width 4 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $b.ll -text "Param to Set (use Up-Dn arrows)"
		button $b.quit -text "Quit" -command "set pr_temposh 0" -highlightbackground [option get . background {}]
		pack $b.ok $b.e $b.ll -side left -padx 2
		pack $b.quit -side right
		pack $b -side top -fill x -expand true
		set r1 [frame $f.r.1 -borderwidth $evv(SBDR)]
		set r2 [frame $f.r.2 -borderwidth $evv(SBDR)]
		radiobutton $r1.60  -text 60  -variable temposh0 -value 60
		pack $r1.60  -side top
		radiobutton $r2.60  -text 60  -variable temposh1 -value 60
		pack $r2.60  -side top
		radiobutton $r1.63  -text 63  -variable temposh0 -value 63
		pack $r1.63  -side top
		radiobutton $r2.63  -text 63  -variable temposh1 -value 63
		pack $r2.63  -side top
		radiobutton $r1.66  -text 66  -variable temposh0 -value 66
		pack $r1.66  -side top
		radiobutton $r2.66  -text 66  -variable temposh1 -value 66
		pack $r2.66  -side top
		radiobutton $r1.69  -text 69  -variable temposh0 -value 69
		pack $r1.69  -side top
		radiobutton $r2.69  -text 69  -variable temposh1 -value 69
		pack $r2.69  -side top
		radiobutton $r1.72  -text 72  -variable temposh0 -value 72
		pack $r1.72  -side top
		radiobutton $r2.72  -text 72  -variable temposh1 -value 72
		pack $r2.72  -side top
		radiobutton $r1.76  -text 76  -variable temposh0 -value 76
		pack $r1.76  -side top
		radiobutton $r2.76  -text 76  -variable temposh1 -value 76
		pack $r2.76  -side top
		radiobutton $r1.80  -text 80  -variable temposh0 -value 80
		pack $r1.80  -side top
		radiobutton $r2.80  -text 80  -variable temposh1 -value 80
		pack $r2.80  -side top
		radiobutton $r1.84  -text 84  -variable temposh0 -value 84
		pack $r1.84  -side top
		radiobutton $r2.84  -text 84  -variable temposh1 -value 84
		pack $r2.84  -side top
		radiobutton $r1.88  -text 88  -variable temposh0 -value 88
		pack $r1.88  -side top
		radiobutton $r2.88  -text 88  -variable temposh1 -value 88
		pack $r2.88  -side top
		radiobutton $r1.92  -text 92  -variable temposh0 -value 92
		pack $r1.92  -side top
		radiobutton $r2.92  -text 92  -variable temposh1 -value 92
		pack $r2.92  -side top
		radiobutton $r1.96  -text 96  -variable temposh0 -value 96
		pack $r1.96  -side top
		radiobutton $r2.96  -text 96  -variable temposh1 -value 96
		pack $r2.96  -side top
		radiobutton $r1.100 -text 100 -variable temposh0 -value 100
		pack $r1.100 -side top
		radiobutton $r2.100 -text 100 -variable temposh1 -value 100
		pack $r2.100 -side top
		radiobutton $r1.104 -text 104 -variable temposh0 -value 104
		pack $r1.104 -side top
		radiobutton $r2.104 -text 104 -variable temposh1 -value 104
		pack $r2.104 -side top
		radiobutton $r1.108 -text 108 -variable temposh0 -value 108
		pack $r1.108 -side top
		radiobutton $r2.108 -text 108 -variable temposh1 -value 108
		pack $r2.108 -side top
		radiobutton $r1.112 -text 112 -variable temposh0 -value 112
		pack $r1.112 -side top
		radiobutton $r2.112 -text 112 -variable temposh1 -value 112
		pack $r2.112 -side top
		radiobutton $r1.116 -text 116 -variable temposh0 -value 116
		pack $r1.116 -side top
		radiobutton $r2.116 -text 116 -variable temposh1 -value 116
		pack $r2.116 -side top
		radiobutton $r1.120 -text 120 -variable temposh0 -value 120
		pack $r1.120 -side top
		radiobutton $r2.120 -text 120 -variable temposh1 -value 120
		pack $r2.120 -side top
		radiobutton $r1.126 -text 126 -variable temposh0 -value 126
		pack $r1.126 -side top
		radiobutton $r2.126 -text 126 -variable temposh1 -value 126
		pack $r2.126 -side top
		radiobutton $r1.132 -text 132 -variable temposh0 -value 132
		pack $r1.132 -side top
		radiobutton $r2.132 -text 132 -variable temposh1 -value 132
		pack $r2.132 -side top
		radiobutton $r1.138 -text 138 -variable temposh0 -value 138
		pack $r1.138 -side top
		radiobutton $r2.138 -text 138 -variable temposh1 -value 138
		pack $r2.138 -side top
		radiobutton $r1.144 -text 144 -variable temposh0 -value 144
		pack $r1.144 -side top
		radiobutton $r2.144 -text 144 -variable temposh1 -value 144
		pack $r2.144 -side top
		radiobutton $r1.152 -text 152 -variable temposh0 -value 152
		pack $r1.152 -side top
		radiobutton $r2.152 -text 152 -variable temposh1 -value 152
		pack $r2.152 -side top
		radiobutton $r1.160 -text 160 -variable temposh0 -value 160
		pack $r1.160 -side top
		radiobutton $r2.160 -text 160 -variable temposh1 -value 160
		pack $r2.160 -side top
		radiobutton $r1.168 -text 168 -variable temposh0 -value 168
		pack $r1.168 -side top
		radiobutton $r2.168 -text 168 -variable temposh1 -value 168
		pack $r2.168 -side top
		radiobutton $r1.176 -text 176 -variable temposh0 -value 176
		pack $r1.176 -side top
		radiobutton $r2.176 -text 176 -variable temposh1 -value 176
		pack $r2.176 -side top
		radiobutton $r1.184 -text 184 -variable temposh0 -value 184
		pack $r1.184 -side top
		radiobutton $r2.184 -text 184 -variable temposh1 -value 184
		pack $r2.184 -side top
		radiobutton $r1.192 -text 192 -variable temposh0 -value 192
		pack $r1.192 -side top
		radiobutton $r2.192 -text 192 -variable temposh1 -value 192
		pack $r2.192 -side top
		radiobutton $r1.200 -text 200 -variable temposh0 -value 200
		pack $r1.200 -side top
		radiobutton $r2.200 -text 200 -variable temposh1 -value 200
		pack $r2.200 -side top
		radiobutton $r1.208 -text 208 -variable temposh0 -value 208
		pack $r1.208 -side top
		radiobutton $r2.208 -text 208 -variable temposh1 -value 208
		pack $r2.208 -side top
		pack $r1 $r2 -side left -fill x -expand true
		pack $r -side top -pady 2
		wm resizable $f 1 1
		bind $f <Escape> {set pr_temposh 0}
		bind $f <Return> {set pr_temposh 1}
	}
	bind $f.b.e <Up>   "IncrParIndex 1 $isins"
	bind $f.b.e <Down> "IncrParIndex -1 $isins"
	set pr_temposh 0	
	set finished 0
	My_Grab 0 $f pr_temposh $f.b.e
	while {!$finished} {
		tkwait variable pr_temposh
	 	if {$pr_temposh} {
			if {$temposh0 <= 0} {
				Inf "No Initial Tempo Set"
				continue
			}
			if {$temposh1 <= 0} {
				Inf "No Final Tempo Set"
				continue
			}
			if {$temposhprm < 1} {
				Inf "No Parameter Number Set"
				continue
			}
			set k [expr $temposhprm - 1]
			if {$shifter == $evv(BRASSAGE)} {
				set prm($k) [expr double($temposh1)/double($temposh0)]
			} else {
				set prm($k) [expr double($temposh0)/double($temposh1)]
			}
			set finished 1
		} else {
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc IncrParIndex {n isins} {
	global ins gdg_cnt temposhprm
	if {$isins} {
		set len [llength $ins(gadgets)]
	} else {
		set len $gdg_cnt
	}
	incr temposhprm $n
	if {$temposhprm < 1} {
		set temposhprm 1
	}
	if {$temposhprm > $len} {
		set temposhprm $len
	}
}

#--- Does instrument involve time-stretching ?

proc IsTimeStretchingInstrument {} {
	global ins evv	
	set possible 0
	foreach cmdline $ins(cmdset) {
		set ppprg [lindex $cmdline 1]
		set mmmod [lindex $cmdline 2]
		set returnval [IsTimeStretchingProcess $ppprg $mmmod]
		if {$returnval > 0} {
			return $returnval
		}
	}
	return 0
}

#--------- Escape and Return Key functions for Instrument

proc InsCreationEscape {} {
	global pr_ins evv wstk
	set msg "Abandon The Instrument ??"
	set choice [tk_messageBox -type yesno -parent [lindex $wstk end] -message  $msg -icon question]
	if {$choice == "no"}  {
		Inf "To Complete Making The Instrument: Use The \"Conclude\" Button"
		return
	}
	set pr_ins $evv(INS_ABORTED)
}

proc InsCreationReturn {} {
	global icp
	if {[winfo exists $icp.tree.btns.continue]} {
		if {[string match [$icp.tree.btns.continue  cget -state] "normal"]} {
			ContinueIns
		}
	}
}

#----- Does CDP process have a variable number of outfiles.

proc ProcessHasVariableNumberOfOutfiles {pprg mmod} {
	global evv
	set mode $mmod
	incr mode -1	

	switch -regexp -- $pprg \
		^evv(RANDCUTS)$ - \
		^evv(RANDCHUNKS)$ - \
		^evv(MIXINBETWEEN)$ {- \
			return 1
		} \
		^evv(HOUSE_COPY)$ {
			if {$mode == $evv(DUPL)} {
				return 1
			}
		} \
		^evv(HOUSE_CHANS)$ {
			if {$mode == $evv(HOUSE_CHANNELS)} {
				return 0
			}
		} \
		^evv(HOUSE_EXTRACT)$ {
			if {$mode == $evv(HOUSE_CUTGATE)} {
				return 0
			}
		} \
   	   	^evv(RRRR_EXTEND)$ {
			if {$mode == 2} {
				return 1
			}
		} \
	   	^evv(PARTITION)$ {
			return 1
		} \
	   	^evv(SPECGRIDS)$ {
			return 1
		}

	return 1
}

