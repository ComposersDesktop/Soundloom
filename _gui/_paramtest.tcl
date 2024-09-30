#
# SOUND LOOM RELEASE mac version 17.0.4
#

######################################
# TESTING, RESETTING ETC. PARAMETERS #
######################################

#------ Test params input from patch for consistency with current infile props & exising datafiles

proc TestParamsWithReversion {} {
	global parname gdg_typeflag gdg_cnt prmgrd prm dfault evv
	global zz_timetype 	zz_secs_lo zz_samps_lo zz_stsamps_lo zz_srate_here patchparam
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
		set par_name [StripName	$parname($gcnt)]
 		set e $prmgrd.e$gcnt

		CheckRecalledParamVal $pcnt $gcnt $gtype $par_name $e

		if {$gtype == $evv(SWITCHED)} {
			incr pcnt
		}
		incr gcnt
		incr pcnt
	}
	if {$timetype_altered} {				;#	Reset ranges of affected params
		switch -regexp -- $timetype \
			^$evv(EDIT_SECS)$    {ResetFadeRanges $zz_secs_lo    $zz_secs_hi    $zz_srate_here $zz_chans_here secs 0} \
			^$evv(EDIT_SAMPS)$   {ResetFadeRanges $zz_samps_lo   $zz_samps_hi   $zz_srate_here $zz_chans_here samps 1} \
			^$evv(EDIT_STSAMPS)$ {ResetFadeRanges $zz_stsamps_lo $zz_stsamps_hi $zz_srate_here $zz_chans_here stsmps 2}

	}
	set i 0
	while {$i < $gdg_cnt} {							;#	Reset values of affected params
		if {[IsDeadParam $i]} {
			incr i
			continue
		}
		if {($gtype == $evv(NUMERIC)) && [string match *FADE* $parname($i)]} {
			set prm($i) $patchparam($i)				
			if {![IsNumeric $prm($i)]} {
				Inf "parameter $parname($i) ($prm($i)) must be numeric: Reverting to default value ($dfault($i))"
				set prm($i) $dfault($i)
			} elseif {$prm($i) < $actvlo($i) || $prm($i) > $actvhi($i)} {
				Inf "parameter $parname($i) ($prm($i)) out of range: Reverting to default value ($dfault($i))"
				set prm($i) $dfault($i)
			}
			InsertParamValueInEntryDisplay $prmgrd.e$i $i
			ResetScale $i linear
		}
		incr i
	}
}

#------ Check value of a parameter called from a patch or a hst

proc CheckRecalledParamVal {pcnt gcnt gtype par_name e} {
	global prm patchparam dfault dfault1 dfault2 actvhi actvlo lo hi sublo subhi hst wl
	global dbl_rng rangetype dfltrangetype canhavefiles timetype_altered pprg
	global pa evv
	global timetype zz_secs_lo zz_samps_lo zz_stsamps_lo zz_srate_here
	global zz_chans_here zz_secs_hi	zz_samps_hi	zz_stsamps_hi
	global secslo sampslo stsampslo sratehere chanshere secshi sampshi stsampshi

	switch -regexp -- $gtype \
		^$evv(CHECKBUTTON)$ {
			switch -- $prm($pcnt) {
				0 -
				1 {}
				default {
					Inf "WARNING: Invalid $par_name switch value ($prm($pcnt)) in recalled process:\nDefaulting to $dfault($pcnt)."
					set prm($pcnt) $dfault($pcnt)
				}
			}
		} \
		^$evv(TIMETYPE)$ {
			switch -- $prm($pcnt) {
				0	-
				1	-
				2	{}
				default {
					Inf "WARNING: Invalid $par_name parameter value ($prm($pcnt)) in recalled process:\nDefaulting to $dfault($pcnt)."
					set prm($pcnt) $dfault($pcnt)
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
					Inf "WARNING: Invalid $par_name parameter value ($prm($pcnt)) in recalled process:\nDefaulting to $dfault($pcnt)."
					set prm($pcnt) $dfault($pcnt)
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
				Inf "WARNING: Invalid $par_name parameter value ($prm($pcnt)) in recalled process:\nDefaulting to $dfault($pcnt)."
				set prm($pcnt) $dfault($pcnt)
			}
		} \
		^$evv(OCT_GADGET)$ {
			set here [string first  "." $prm($pcnt)] 		;#	Deal with OCTVAL expressed as a double
			if {$here > 0} {
				incr here -1
				set prm($pcnt) [string range $prm($pcnt) 0 $here]
			}
			if {$prm($pcnt) < -4 || $prm($pcnt) > 4} {
				Inf "WARNING: Invalid $par_name parameter value ($prm($pcnt)) in recalled process:\nDefaulting to $dfault($pcnt)."
				set prm($pcnt) $dfault($pcnt)
			}
		} \
		^$evv(CHORD_GADGET)$ {
			set here [string first  "." $prm($pcnt)] 		;#	Deal with CHORDVAL expressed as a double
			if {$here > 0} {
				incr here -1
				set prm($pcnt) [string range $prm($pcnt) 0 $here]
			}
			if {$prm($pcnt) < 0 || $prm($pcnt) > 9} {
				Inf "WARNING: Invalid $par_name parameter value ($prm($pcnt)) in recalled process:\nDefaulting to $dfault($pcnt)."
				set prm($pcnt) $dfault($pcnt)
			}
		} \
		^$evv(DENSE_GADGET)$ {
			set here [string first  "." $prm($pcnt)] 		;#	Deal with CHORDVAL expressed as a double
			if {$here > 0} {
				incr here -1
				set prm($pcnt) [string range $prm($pcnt) 0 $here]
			}
			if {$prm($pcnt) < 0 || $prm($pcnt) > 3} {
				Inf "WARNING: Invalid $par_name parameter value ($prm($pcnt)) in recalled process:\nDefaulting to $dfault($pcnt)."
				set prm($pcnt) $dfault($pcnt)
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
					Inf "WARNING: Invalid $par_name parameter value ($prm($pcnt)) in recalled process:\nDefaulting to $dfault($pcnt)."
					set prm($pcnt) $dfault($pcnt)
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
					Inf "WARNING: Invalid $par_name parameter value ($prm($pcnt)) in recalled process:\nDefaulting to $dfault($pcnt)."
					set prm($pcnt) $dfault($pcnt)
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
					Inf "WARNING: Invalid $par_name parameter value ($prm($pcnt)) in recalled process:\nDefaulting to $dfault($pcnt)."
					set prm($pcnt) $dfault($pcnt)
				}
			}
		} \
		^$evv(GENERICNAME)$ {
#JUNE 30 UC-LC FIX
			set prm($pcnt) [string tolower $prm($pcnt)]
			if {![ValidCDPRootname $prm($pcnt)]} { 
				set prm($pcnt) ""
				InsertParamValueInEntryDisplay $e $pcnt
			}
		} \
		^$evv(VOWELS)$ {
			set prm($pcnt) [string tolower $prm($pcnt)]
			if {![ValidVowelName $prm($pcnt)]} {
				if {![file exists $prm($pcnt)] || [file isdirectory $prm($pcnt)]} { 
					set prm($pcnt) ""
					InsertParamValueInEntryDisplay $e $pcnt
				}
			}
		} \
		^$evv(STRING_A)$ {
			if {![ValidStringA $prm($pcnt) $gcnt]} {
				set prm($pcnt) ""
				InsertParamValueInEntryDisplay $e $pcnt
			}
		} \
		^$evv(STRING_B)$ {
			if {![ValidStringB $prm($pcnt) $gcnt]} {
				set prm($pcnt) ""
				InsertParamValueInEntryDisplay $e $pcnt
			}
		} \
		^$evv(STRING_C)$ {
			if {![ValidStringC $prm($pcnt) $gcnt]} {
				set prm($pcnt) ""
				InsertParamValueInEntryDisplay $e $pcnt
			}
		} \
		^$evv(STRING_D)$ {
			if {![ValidStringD $prm($pcnt) $gcnt]} {
				set prm($pcnt) ""
				InsertParamValueInEntryDisplay $e $pcnt
			}
		} \
		^$evv(STRING_E)$ {
			if {![ValidStringE $prm($pcnt) $gcnt]} {
				set prm($pcnt) ""
				InsertParamValueInEntryDisplay $e $pcnt
			}
		} \
		^$evv(LINEAR)$ 		-	\
		^$evv(LOG)$ 		-	\
		^$evv(PLOG)$ 		-	\
		^$evv(FILE_OR_VAL)$ -	\
		^$evv(LOGNUMERIC)$ -	\
		^$evv(NUMERIC)$ {
			if {($gtype == $evv(NUMERIC)) && [string match *FADE* $par_name]} {
				set patchparam($pcnt) $prm($pcnt)
			} elseif [IsNumeric $prm($pcnt)] {
				if {($prm($pcnt) > $actvhi($pcnt)) || ($prm($pcnt) < $actvlo($pcnt))} {
					if {$dbl_rng($pcnt)} {
						if [string match $gtype $evv(LINEAR)] {							
							SwitchRange $pcnt $gcnt	0 0
						} else {														
							SwitchLogRange $pcnt $gcnt 0 0
						}
						if {($prm($pcnt) > $actvhi($pcnt)) || ($prm($pcnt) < $actvlo($pcnt))} {
							Inf "Value for $par_name ($prm($pcnt)) is out of range:\nReverting to standard default $dfault($pcnt)"
							if {$rangetype($pcnt) != $dfltrangetype($pcnt)} {
								if [string match $gtype $evv(LINEAR)] {						
									SwitchRange $pcnt $gcnt 0 0
								} else {													
									SwitchLogRange $pcnt $gcnt 0 0
								}
							}
							set prm($pcnt) $dfault($pcnt)								
						}																
					} else {
						Inf "Value for $par_name ($prm($pcnt)) is out of range:\nReverting to standard default $dfault($pcnt)"
						set prm($pcnt) $dfault($pcnt)									
					}
				}																		
			} elseif {$canhavefiles($pcnt)} {
#JUNE 30 UC-LC FIX
				set prm($pcnt) [string tolower $prm($pcnt)]
				set thisfilename $prm($pcnt)
				if {![file exists $thisfilename] || [file isdirectory $thisfilename]} {
					Inf "File $prm($pcnt) for $par_name no longer exists:\nReverting to standard default $dfault($pcnt)"
					set prm($pcnt) $dfault($pcnt)											
				} elseif {![string match $gtype $evv(FILE_OR_VAL)]} {
					if {[set ii [LstIndx $prm($pcnt) $wl]] < 0} {
						Inf "The file $prm($pcnt) is not loaded on the Workspace\n\nDefaulting value [GetParName $pcnt] to $dfault($pcnt)"
						set prm($pcnt) $dfault($pcnt)
					} elseif {$pa($prm($pcnt),$evv(MAXBRK)) > $actvhi($pcnt) ||  $pa($prm($pcnt),$evv(MINBRK)) < $actvlo($pcnt)} {
						if {$dbl_rng($pcnt)} {
							if [string match $gtype $evv(LINEAR)] {							
								SwitchRange $pcnt $gcnt	0 0
							} else {														
								SwitchLogRange $pcnt $gcnt 0 0
							}
							if {$pa($prm($pcnt),$evv(MAXBRK)) > $actvhi($pcnt) \
							||  $pa($prm($pcnt),$evv(MINBRK)) < $actvlo($pcnt)} {
								Inf "Values in file $prm($pcnt) are out of range:\nReverting to standard default $dfault($pcnt)"
								if {$rangetype($pcnt) != $dfltrangetype($pcnt)} {
									if [string match $gtype $evv(LINEAR)] {						
										SwitchRange $pcnt $gcnt 0 0
									} else {													
										SwitchLogRange $pcnt $gcnt 0 0
									}
								}
								set prm($pcnt) $dfault($pcnt)								
							}																
						} else {
							Inf "Values in file $prm($pcnt) are out of range:\nReverting to standard default"
							set prm($pcnt) $dfault($pcnt)											
						}
					}
				}
			} else {
				Inf "Numeric values only for parameter $par_name:\nReverting to standard default"
				set prm($pcnt) $dfault($pcnt)
			}
			ForceVal $e $prm($pcnt)
			if [IsNumeric $prm($pcnt)] {
				if {[string match $gtype $evv(LOG)] || [string match $gtype $evv(PLOG)]  || [string match $gtype $evv(LOGNUMERIC)]} {
					SetScale $pcnt log
				} else {
					SetScale $pcnt linear
				}
			}
			if [string match $gtype $evv(PLOG)] {
				SetPitchValFromEntrybox $gcnt $pcnt										
			}
		} \
		^$evv(FILENAME)$ {
			set prm($pcnt) [string tolower $prm($pcnt)]
			set thisfilename $prm($pcnt)
			if {($pprg == $evv(P_INVERT)) && [string match $prm($pcnt) "0"]} {
				;# DO NOTHING
			} elseif {![file exists $thisfilename] || [file isdirectory $thisfilename]} {
				Inf "File $prm($pcnt) for $par_name no longer exists"
				set prm($pcnt) ""											
			}
			ForceVal $e $prm($pcnt)
		} \
		^$evv(OPTIONAL_FILE)$ {
			set prm($pcnt) [string tolower $prm($pcnt)]
			set thisfilename $prm($pcnt)
			if {[string match $prm($pcnt) "0"]} {
				;# DO NOTHING
			} elseif {![file exists $thisfilename] || [file isdirectory $thisfilename]} {
				Inf "File $prm($pcnt) for $par_name no longer exists"
				set prm($pcnt) "0"											
			}
			ForceVal $e $prm($pcnt)
		} \
		^$evv(SWITCHED)$ {
			set wasbadswitch 0
			switch -- $prm($pcnt) {
				0 -
				1 {}
				default {
					Inf "WARNING: Invalid $par_name switch value in recalled process: Defaulting."
					set prm($pcnt) $dfault($pcnt)
					set wasbadswitch 1
				}
			}
			set paramswitch $pcnt
			set origswitchval $prm($paramswitch)
			incr pcnt
			set origval $prm($pcnt)
			ToggleGadget $gcnt $paramswitch $pcnt $lo($pcnt) $hi($pcnt) $dfault1($pcnt) $sublo($pcnt) $subhi($pcnt) $dfault2($pcnt)	
			if {($origval > $actvhi($pcnt)) || ($origval < $actvlo($pcnt))} {
				set prm($paramswitch) [expr !$origswitchval]
				ToggleGadget $gcnt $paramswitch $pcnt $lo($pcnt) $hi($pcnt) $dfault1($pcnt) $sublo($pcnt) $subhi($pcnt) $dfault2($pcnt)	
				if {($origval > $actvhi($pcnt)) || ($origval < $actvlo($pcnt))} {
					if {!$wasbadswitch} {
						Inf "$par_name value ($origval) is out of range in this case:\nReverting to standard default"
					}
					set prm($paramswitch) 1											
					ToggleGadget $gcnt $paramswitch $pcnt $lo($pcnt) $hi($pcnt) $dfault1($pcnt) $sublo($pcnt) $subhi($pcnt) $dfault2($pcnt)	
				} else {
					if {!$wasbadswitch} {
						Inf "$par_name value ($origval) was out of range for switch option: Changed switch"
					}
					set prm($pcnt) $origval
					ForceVal $e $prm($pcnt)
 						SetScale $pcnt linear
				}
			} else {
				set prm($pcnt) $origval
				ForceVal $e $prm($pcnt)
				SetScale $pcnt linear
			}
		}
}

#------ Save a copy of the parameters in the prm-dialog-box

proc RememberCurrentParams {} {
	global pmcnt pstore prm lastrangetype dbl_rng rangetype bakpstore baklastrangetype
	global prg_ran_before ins pmcnt

	if {$pmcnt > 0} {
		set i 0 
		if {$prg_ran_before} {
			while {$i < $pmcnt} {
				if {[IsDeadParam $i]} {
					incr i
					continue
				}
				set bakpstore($i) $pstore($i)
				set pstore($i) $prm($i)
				if {$dbl_rng($i)} {
					set baklastrangetype($i) $lastrangetype($i)
					set lastrangetype($i) $rangetype($i)
				}
				incr i
			} 
		} else {
			while {$i < $pmcnt} {
				if {[IsDeadParam $i]} {
					incr i
					continue
				}
				set pstore($i) $prm($i)
				if {$dbl_rng($i)} {
					set lastrangetype($i) $rangetype($i)
				}
				incr i
			} 
		}
	}
}

#------ Reset (default or previous setting) values of params

proc ResetValues {varName args} {
	global gdg_cnt gdg_typeflag pstore evv prm actvhi actvlo parname timetype_altered
   	global sratehere chanshere secslo sampslo stsampslo secshi sampshi stsampshi timetype_filename
	global lo hi sublo subhi dfault1 dfault2 isint dbl_rng dfault timetype chlist ins pa
	global rangetype lastrangetype baklastrangetype dfltrangetype partype prmgrd
	global pstore bakpstore ins_subdflt powtwo_range powtwo_convertor is_dflt_sr_gadget pprg

	if [ParampageInActiveHelpState] {
		return
	}
	upvar $varName var

	set timetype_altered 0

	if {[llength $args] > 0} {			;#	Reset a single value
		set gcnt [lindex $args 0]
		set pcnt [lindex $args 1]
		set total $gcnt
		incr total
	} else {							;#	Reset all values
		set gcnt 0
		set pcnt 0
		set total $gdg_cnt
	}

	while {$gcnt < $total} {
		if {[IsDeadParam $gcnt]} {
			incr pcnt
			incr gcnt
			continue
		}
		if {$gcnt == $is_dflt_sr_gadget} {
			incr pcnt
			incr gcnt
			continue
		}
		switch -regexp -- $gdg_typeflag($gcnt) \
			^$evv(SWITCHED)$ { 
				set paramswitch $pcnt				;#	remember additional parameter index
				set prm($paramswitch) $var($pcnt)	;#	Reset its value
				incr pcnt							;#	go to next parameter
				ToggleGadget $gcnt $paramswitch $pcnt $lo($pcnt) $hi($pcnt) $dfault1($pcnt) $sublo($pcnt) $subhi($pcnt) $dfault2($pcnt)	
				if {$isint($pcnt)} {
					set prm($pcnt) [expr round($var($pcnt))]
				} else {
					set prm($pcnt) $var($pcnt)		;#	Then set value
				}
				InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
				ResetScale $pcnt linear
			} 	\
			^$evv(TIMETYPE)$ {
				set prm($pcnt) $var($pcnt)		
				set timetype 	$prm($pcnt)		;#	set the timetype flag
				set timetype_altered 1
				set secs_lo		$secslo($pcnt)		;#	and remember the relevant variables
				set samps_lo	$sampslo($pcnt)
				set stsamps_lo	$stsampslo($pcnt)
				set srate_here	$sratehere($pcnt)
				set chans_here	$chanshere($pcnt)
				set secs_hi		$secshi($pcnt)
				set samps_hi	$sampshi($pcnt)
				set stsamps_hi	$stsampshi($pcnt)
			}	\
			^$evv(LINEAR)$ - \
			^$evv(FILE_OR_VAL)$ - \
			^$evv(LOGNUMERIC)$ - \
			^$evv(NUMERIC)$ {
				if {!(([info exists ins(run)] && $ins(run)) || ([info exists ins(create)] && $ins(create)))} {
					if {($pprg == $evv(MIX)) || ($pprg == $evv(MIXMAX)) || ($pprg == $evv(MIXMULTI))} {
						if {$pcnt == 1} {
							set dddur $pa([lindex $chlist 0],$evv(DUR))
							if {![Flteq $var($pcnt) $dddur]} {
								set var($pcnt) $dddur
							}
						}
					}
				}
				if [IsNumeric $var($pcnt)] {
					if {$isint($pcnt)} {
						set var($pcnt) [StripLeadingZeros $var($pcnt)]
						set prm($pcnt) [expr round($var($pcnt))]
					} else {
						set prm($pcnt) $var($pcnt)		;#	Then set value
					}
					InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
					if {$gdg_typeflag($gcnt) == $evv(LOGNUMERIC)} {
						ResetScale $pcnt log
					} else {
						ResetScale $pcnt linear
					}
				} else {
					set prm($pcnt) $var($pcnt)			;#	Then set filename
				}
			}	\
			^$evv(LOG)$ {
				if [IsNumeric $var($pcnt)] {
					if {$isint($pcnt)} {
						set var($pcnt) [StripLeadingZeros $var($pcnt)]
						set prm($pcnt) [expr round($var($pcnt))]
					} else {
						set prm($pcnt) $var($pcnt)		;#	Then set value
					}
					InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
					ResetScale $pcnt log
				} else {
					set prm($pcnt) $var($pcnt)			;#	Then set filename
				}
			}	\
			^$evv(POWTWO)$ {
				if [IsNumeric $var($pcnt)] {
					set var($pcnt) [StripLeadingZeros $var($pcnt)]
					set prm($pcnt) [expr round($var($pcnt))]
					InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
					set powtwo_range($pcnt) [expr int(round(log($actvhi($pcnt)) * $evv(ONE_OVER_LN2)))]  
					set powtwo_convertor($pcnt) [expr 1.0 / $powtwo_range($pcnt)]  
					ResetScale $pcnt powtwo
				} else {
					set prm($pcnt) $var($pcnt)			;#	Then set filename
				}
			}	\
			^$evv(PLOG)$ {
				if [IsNumeric $var($pcnt)] {
					if {$isint($pcnt)} {
						set var($pcnt) [StripLeadingZeros $var($pcnt)]
						set prm($pcnt) [expr round($var($pcnt))]
					} else {
						set prm($pcnt) $var($pcnt)		;#	Then set value
					}
					set pitchdisplay($pcnt) [SetPitchDisplay [expr log ($prm($pcnt))] $gcnt $pcnt]
					ForceVal $prmgrd.pi$gcnt $pitchdisplay($pcnt)
					ResetScale $pcnt log
				} else {
					set prm($pcnt) $var($pcnt)			;#	Then set filename
				}
			}	\
			^$evv(VOWELS)$ -	\
			^$evv(GENERICNAME)$ -	\
			^$evv(STRING_A)$ -	\
			^$evv(STRING_B)$ -	\
			^$evv(STRING_C)$ -	\
			^$evv(STRING_D)$ -	\
			^$evv(STRING_E)$ {
				if {$isint($pcnt)} {
					set prm($pcnt) [expr round($var($pcnt))]
				} else {
					set prm($pcnt) $var($pcnt)		;#	Then set value
				}
				InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
			} \
			default {
				if {$isint($pcnt)} {
					set prm($pcnt) [expr round($var($pcnt))]
				} else {
					set prm($pcnt) $var($pcnt)		;#	Then set value
				}
			}

		if {$dbl_rng($pcnt)} {
			set do_range_switch 0

			switch -exact -- $varName {
				"pstore" {
					if {$rangetype($pcnt) != $lastrangetype($pcnt)} {
						set do_range_switch 1
					}
				}
				"bakpstore" {
					if {$rangetype($pcnt) != $baklastrangetype($pcnt)} {
						set do_range_switch 1
					}
				}
				default {
					if {$rangetype($pcnt) != $dfltrangetype($pcnt)} {
						set do_range_switch 1
					}
				}
			}
			if {$do_range_switch} {
				if [string match "log" $partype($pcnt)] {
					SwitchLogRange $pcnt $gcnt 0 0
					ResetScale $pcnt log
				} else {
					SwitchRange $pcnt $gcnt 0 0
					ResetScale $pcnt linear
				}
			}
		}
		incr pcnt							;#	Next parameter
		incr gcnt							;#	Next gadget

	}
	if {$timetype_altered} {				;#	Reset ranges of affected params
		switch -regexp -- $timetype \
			^$evv(EDIT_SECS)$    {ResetFadeRanges $secs_lo    $secs_hi    $srate_here $chans_here secs 0} \
			^$evv(EDIT_SAMPS)$   {ResetFadeRanges $samps_lo   $samps_hi   $srate_here $chans_here samps 1} \
			^$evv(EDIT_STSAMPS)$ {ResetFadeRanges $stsamps_lo $stsamps_hi $srate_here $chans_here stsmps 2}

		set i 0
		while {$i < $gdg_cnt} {							;#	Reset values of affected params
			if {[IsDeadParam $i]} {
				incr i
				continue
			}
			if {($gdg_typeflag($i) == $evv(NUMERIC)) && [string match *FADE* $parname($i)]} {
				set prm($i) $var($i)						;#	gadgets in any timetype processes (laziness!)
				InsertParamValueInEntryDisplay $prmgrd.e$i $i
				ResetScale $i linear
			}

			incr i
		}
	}
	if {($pprg == $evv(MIX)) || ($pprg == $evv(MIXMULTI))} {
		$prmgrd.mixwarn config -text ""
	}
}

#------ Restore prm vals previously used when running this program THIS TIME AROUND

proc ResetPreviousRunParams {args} {
	global pstore dfault lastrangetype

	if {[info exists pstore] && [info exists lastrangetype]} {
		eval {ResetValues pstore} $args
	} else {
		eval {ResetValues dfault} $args
	}
}

#------ Restore prm vals previously used when running this program PREVIOUS TIME AROUND

proc ResetPenultimateRunParams {args} {
	global bakpstore prg_ran_before sl_real

	if [ParampageInActiveHelpState] {
		return
	}
	if {!$sl_real} {
		if {[llength $args] <= 0} {
			Inf "With This Button, You Can Reset All Parameters\nTo The Values Used In A Previous Run,\nEven If This Run Was In A Previous Session."
			return
		} else {
			Inf "With This Button, You Can Reset This Particular Parameter\nTo The Value Used In A Previous Run,\nEven If This Run Was In A Previous Session."
			return
		}
	}
	if {$prg_ran_before <= 1} {
		eval {ResetPenultVals} $args
		return
	}
	eval {ResetValues bakpstore} $args
}

#------ Reset sliders and ranges, and textbox, where timetype changes

proc ResetFadeRanges {lo hi srate_here chans_here type tt} {
	global prm isint actvlo actvhi parname prmgrd gdg_cnt dfault evv
	global gdg_typeflag resetfaderanges_firsttime stsdfault sdfault timetype
	set i 0
	while {$i < $gdg_cnt} {
		if {[IsDeadParam $i]} {
			incr i
			continue
		}
		if {$resetfaderanges_firsttime} {
			set xx [expr double($dfault($i)) * $srate_here]
			if [catch {set stsdfault($i) [expr round($xx)]}] {
				#	INTEGER TOO LARGE
				set stsdfault($i) $evv(MAXINT)
			}
			set xx [expr $xx * $chans_here]
			if [catch {set sdfault($i) [expr round($xx)]}] {
				#	INTEGER TOO LARGE
				set sdfault($i) $evv(MAXINT)
			}
		}
		if {($gdg_typeflag($i) == $evv(NUMERIC)) && [string match *FADE* $parname($i)]} {
			ResetThisFadeRange $i $lo $hi $type
		}
		incr i
	}
	set timetype $tt
	set resetfaderanges_firsttime 0
}

#------ Reset Range (and value) of parambox, to reflect new time-unit (samples/secs etc)

proc ResetThisFadeRange {i lo hi type} {
	global actvhi actvlo prange dfault sdfault stsdfault isint islog prmgrd evv

	set actvlo($i) $lo
	set actvhi($i) $hi
	set prange($i) [expr $actvhi($i) - $actvlo($i)]
	if {!$islog($i)} {
		SetPrtype $i
	}
	switch $type {
		secs 	{set prm($i) $dfault($i)	 ; set isint($i) 0}
		samps 	{set prm($i) $sdfault($i)   ; set isint($i) 1}
		stsmps 	{set prm($i) $stsdfault($i) ; set isint($i) 1}
	}
	if {$isint($i)} {
		set lotxt [expr round($actvlo($i))]
		set hitxt [expr round($actvhi($i))]
	} else {
		set lotxt [FiveSigFig $actvlo($i)]
		set hitxt [FiveSigFig $actvhi($i)]
	}
	set lowidth [string length $lotxt]
	if {$lowidth < $evv(RANGEWIDTH)} {
		set lowidth $evv(RANGEWIDTH)
	}
	set hiwidth [string length $hitxt]
	if {$hiwidth < $evv(RANGEWIDTH)} {
		set hiwidth $evv(RANGEWIDTH)
	}
	$prmgrd.rlo$i config -text $lotxt -width $lowidth
	$prmgrd.rhi$i config -text $hitxt -width $hiwidth
	InsertParamValueInEntryDisplay $prmgrd.e$i $i
	ResetScale $i linear
}

#------ Test for validity of type-A string		(abcde-acccccccad OR abcde:acccccccad)

proc ValidStringA {str gcnt} {
	global parname

	set par_name [StripName	$parname($gcnt)]

	if {[regexp  -nocase {^[a-z]+\-[a-z]+$} $str]} {
		set i [string first "-"	$str]
	} elseif {[regexp  -nocase {^[a-z]+:[a-z]+$} $str]} {
		set i [string first ":"	$str]
	} else {
		Inf "$str in $par_name is not a valid string for this process"
		return 0
	}
	incr i -1
	set domain [string range $str 0 $i]
	incr i 2
	set image [string range $str $i end]
	set dlen [string length $domain]
	set dlen_less_one $dlen
	incr dlen_less_one -1
	set d 0
	while {$d < $dlen_less_one} {	 ;#	Check no repeated letters in domain
		set i $d
		incr i
		while {$i < $dlen} {
			if {[string index $domain $i] == [string index $domain $d]} {
				Inf "$domain in $par_name contains repeated letters"
				return 0
			}
			incr i
		}
		incr d
	}
	set i 0
	set ilen [string length $image]
	while {$i < $ilen} {			  	;#	Check all image letters occur in domain
		set d 0
		set OK 0
		while {$d < $dlen} {
			if {[string index $image $i] == [string index $domain $d]} {
				set OK 1
				break
			}
			incr d
		}				
		if {!$OK} {
			Inf "$image is not consistent with $domain in $par_name"
			return 0
		}
		incr i
	}				
	return 1
}

#------ Test for validity of type-B string		(abaabdef:b OR abaabdef-b)

proc ValidStringB {str gcnt} {
	global parname

	set par_name [StripName	$parname($gcnt)]

	if {[regexp -nocase {^[a-z]+:[a-z]+$} $str]} {
		set i [string first ":"	$str]
	} elseif {[regexp -nocase {^[a-z]+\-[a-z]+$} $str]} {
		set i [string first \-	$str]
	} else {
		Inf "$str in $par_name is not a valid string for this process"
		return 0
	}
	incr i -1
	set domain [string range $str 0 $i]
	incr i 2
	set image [string range $str $i end]
	set dlen [string length $domain]
	set d 0
	set minletter z
	while {$d < $dlen} {	 ;#	Check for alphabetically-minimum letter in domain
		set c [string index $str $d]
		if {[string compare $c $minletter] < 0} {
			set minletter $c
		}
		incr d
	}
	set ilen [string length $image]
	if {$ilen > 1} {
		Inf "Too many letters in image for	 $par_name"
		return 0
	}										;#	Check image letter is 'greater' than min domain letter
	if {[string compare [string index $image 0] $minletter] <= 0} {
		Inf "Pattern $str in $par_name doesn't advance through the file"
		return 0
	}
	return 1
}

#------ Test for validity of type-C string		(notestring e.g. F#d-2)

proc ValidStringC {str gcnt} {
	global parname

	set par_name [StripName	$parname($gcnt)]

	if {![regexp -nocase {^[a-g][b\#]?[du]?\-?[0-9]+$} $str]} {
		Inf "Invalid note string: $str :in $par_name"
		return 0
	}

	if {[string first "-" $str] == -1} {	;#	If it's not a -ve 8va, all +ve octaves work!!
		return 1
	}
	set i [string length $str]
	incr i -1
	while {$i >= 0} {
		if {![string match {[0-9]} [string index $str $i]]} {	;#	Get the numeric tail (octave)
			break
		}
		incr i -1
	}
	incr i
	set oct [string range $str $i end]
	if {$oct > 5} {							;#	less than -5 doesn't work too
		Inf "Notestring $str in $par_name is out of range"
		return 0
	}
	return 1
}

#------ Test for validity of type-D string		(interval-str e.g. m#4u)

proc ValidStringD {str gcnt} {
	global parname

	set par_name [StripName	$parname($gcnt)]

	if {![regexp -nocase {^\-?m?\#?[0-9]+[ud]?$} $str]} {
		Inf "Invalid interval string: $str :in $par_name"
		return 0
	}
	set number_end [string length $str]
	incr number_end -1
	set i $number_end
	while {$i >= 0} {
		if {![string match {[0-9]} [string index $str $i]]} {	;#	Get the numeric tail (basic interval)
			if {$i == $number_end} {
				incr number_end -1								;#	Ignore trailing 'u' or 'd'
			} else {
				break
			}
		}
		incr i -1
	}
	incr i
	set interval [string range $str $i $number_end] 			;#	interval must be in range 2-15
	if {$interval < 2 || $interval > 15} {
		Inf "Interval String $str is out of range in $par_name "
		return 0
	}														   	;# 2-digit interval vals cannot start with 0
	if {[string length $interval] > 1 && [string index $interval 0] != 1} {
		Inf "Invalid interval string: $str :in $par_name"
		return 0
	}
	if {[string first "m" $str] != -1} {						;#	If it's a minor-key interval
																#	These intervals can't be minor
		switch -- $interval {									
			4  -												
			5  -
			8  -
			11 -
			12 -
			15 {
				Inf "Invalid Interval String $str in $par_name"
				return 0
			}
		}
	}
	if {[string first "#" $str] != -1} {						;#	If it's a sharpened interval
																#	Only these intervals can be sharp
		switch -- $interval {									
			4  -												
			11 {}
			default {
				Inf "Invalid Interval String $str in $par_name"
				return 0
			}
		}
	}
	return 1
}

#------ Test for validity of type-E string		(new or existing textfilename)

proc ValidStringE {filename gcnt} {
	global parname evv

	set root [file rootname [file tail $filename]]
	if {![ValidCDPRootname $root]} {
		return 0
	}
	set thisdir [file dirname $filename]
	if {![file exists $thisdir] || ![file isdirectory $thisdir]} {
		Inf "Directory specified in pathname does not exist"
		return 0
	}
	append filename $evv(TEXT_EXT)
	set prm($gcnt) $filename
	return 1
}

#------ Insert a value set elsewhere, into entrybox display

proc InsertParamValueInEntryDisplay {e pcnt} {
	global prm isint
	set val $prm($pcnt)
	if {$isint($pcnt)} {
		set val [expr round($val)]
	}
	$e delete 0 end
	$e insert 0 $val
}

#------ Test for a valid brkpntfile 
#
#	NB $prm($i) is name of a FILE in the workspace and therefore with a pa!!!
#

proc FilevalIsInRange {pcnt gcnt} {
	global prm actvhi actvlo pa wl evv

	if {[set i [LstIndx $prm($pcnt) $wl]] < 0} {
		Inf "File $prm($pcnt) is not on the workspace"
		return 0
	} else {
		set prm($pcnt) [$wl get $i]		 	;#	Ensure file has correct CASE :April 15: 2000
	}
	if {$pa($prm($pcnt),$evv(MAXBRK)) > $actvhi($pcnt) 
	||  $pa($prm($pcnt),$evv(MINBRK)) < $actvlo($pcnt)} {
		Inf "Values in file $prm($pcnt) are out of range"
		return 0
	}					  	
	return 1
}

#------ Numeric values range test
				 
proc IsInRange {pcnt gcnt} {
	global prm actvhi actvlo parname wstk evv

	if {$prm($pcnt) > $actvhi($pcnt)} {
		set par_name [StripName	$parname($gcnt)]
		if {[string match $par_name "MIXING ENDTIME"]} {
			set prm($pcnt) $actvhi($pcnt)
			SetScale $pcnt 0
		} else {			
			set msg "$par_name Is Above The Permissible Range\n\n"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
				-message "$msg Reset To Maximum ?"]
			if {$choice == "yes"} {
				set prm($pcnt) $actvhi($pcnt)
				SetScale $pcnt 0
			}
		}
		return 0
	}
	if {$prm($pcnt) < $actvlo($pcnt)} {
		set par_name [StripName	$parname($gcnt)]
		set msg "$par_name Is Below The Permissible Range\n\n"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
			-message "$msg Reset To Minimum ?"]
		if {$choice == "yes"} {
			if {$actvlo($pcnt) == 0.0} {
				set prm($pcnt) $actvlo($pcnt)
			} else {
				set prm($pcnt) [expr $actvlo($pcnt) + $evv(ROUNDERR)]
			}
		}
		return 0
	}
	return 1
}

#------ Display value to 5 sigfig (only for text display .... not an actual numeric value used in calcs)

proc FiveSigFig {val} {
	set isneg 0
	if {$val < 0} {
		set valimit 6
		set valend 5
	} else {
		set valimit 5
		set valend 4
	}
	if {[string first "e-" $val] >= 0} {
		return 0.00000
	}
	set vallen [string length $val] 
	if {$vallen <= $valimit} {									;#	963 -> 963 | .963 ->.963 | 9.63 -> 9.63
		return $val
	} elseif {$val > 99999 || $val < -99999} {
		set decpnt [string first "." $val]						;#	699998.87 -> 699998		GOOD ENOUGH!
		if {$decpnt > 0} {
			incr decpnt -1
			return [string range $val 0 $decpnt]
		} 
		return $val						  						;#	699998 -> 699998
	}
	if {$val >= 1.0 || $val <= -1.0 || $val == 0.0} {			
		if {$vallen > $valimit} {								;#	-2.678677  -> -2.678	GOOD ENOUGH!
			return [string range $val 0 $valend]				;#	2.678677   -> 2.678		GOOD ENOUGH!		
		} else {												;#	-2		   -> -2	
			return $val											;#	0.0000000  -> 0.000
		}														;#	0		   -> 0
	}
	set decpos [string first "." $val]					
	incr decpos
	while {[string match [string index $val $decpos] "0"]} {
		incr decpos
	}
	if {$decpos > $valend} {
		return [string range $val 0 $decpos]
	}
	return [string range $val 0 $valend]
}

#------ Reset (previous run) values of params when its not an immediate rerun

proc ResetPenultVals {args} {
	global gdg_cnt gdg_typeflag pstore evv prm actvhi actvlo parname timetype_altered
   	global sratehere chanshere secslo sampslo stsampslo secshi sampshi stsampshi timetype_filename
	global lo hi sublo subhi dfault1 dfault2 isint dbl_rng dfault timetype ins
	global rangetype penultrangetype dfltrangetype partype prmgrd
	global lastrunvals pprg mmod powtwo_range powtwo_convertor is_dflt_sr_gadget main_mix
	set timetype_altered 0

	if {$ins(run)} {
		if [info exists lastrunvals($ins(name))] {
			set var $lastrunvals($ins(name))
			set penultrange $penultrangetype($ins(name))
		} else {
			return
		}
	} else {
		if {[MainMix]} {
			if [info exists main_mix(lastrunvals)] {
				set var $main_mix(lastrunvals)
				set penultrange $main_mix(penultrangetype)
			} else {
				return
			}
		} else {
			if [info exists lastrunvals($pprg,$mmod)] {
				set var $lastrunvals($pprg,$mmod)
				set penultrange $penultrangetype($pprg,$mmod)
			} else {
				return
			}
		}
	}

	if {[llength $args] > 0} {			;#	Reset a single value
		set gcnt [lindex $args 0]
		set pcnt [lindex $args 1]
		set total $gcnt
		incr total
	} else {							;#	Reset all values
		set gcnt 0
		set pcnt 0
		set total $gdg_cnt
	}

	while {$gcnt < $total} {
		if {[IsDeadParam $gcnt]} {
			incr pcnt
			incr gcnt
			continue
		}
		if {$gcnt == $is_dflt_sr_gadget} {
			incr pcnt
			incr gcnt
			continue
		}
		set val [lindex $var $pcnt]
		switch -regexp -- $gdg_typeflag($gcnt) \
			^$evv(SWITCHED)$ { 
				set paramswitch $pcnt			;#	remember additional parameter index
				set prm($paramswitch) $val		;#	Reset its value
				incr pcnt							;#	go to next parameter
				ToggleGadget $gcnt $paramswitch $pcnt $lo($pcnt) $hi($pcnt) $dfault1($pcnt) $sublo($pcnt) $subhi($pcnt) $dfault2($pcnt)	
				set val [lindex $var $pcnt]
				if {$isint($pcnt)} {
					set prm($pcnt) [expr round($val)]
				} else {
					set prm($pcnt) $val		;#	Then set value
				}
				InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
				ResetScale $pcnt linear
			} 	\
			^$evv(TIMETYPE)$ {
				set prm($pcnt) $val		
				set timetype 	$prm($pcnt)		;#	set the timetype flag
				set timetype_altered 1
				set secs_lo		$secslo($pcnt)		;#	and remember the relevant variables
				set samps_lo	$sampslo($pcnt)
				set stsamps_lo	$stsampslo($pcnt)
				set srate_here	$sratehere($pcnt)
				set chans_here	$chanshere($pcnt)
				set secs_hi		$secshi($pcnt)
				set samps_hi	$sampshi($pcnt)
				set stsamps_hi	$stsampshi($pcnt)
			}	\
			^$evv(LINEAR)$ - \
			^$evv(FILE_OR_VAL)$ - \
			^$evv(LOGNUMERIC)$ - \
			^$evv(NUMERIC)$ {
				if [IsNumeric $val] {
					if {$isint($pcnt)} {
						set val [StripLeadingZeros $val]
						set prm($pcnt) [expr round($val)]
					} else {
						set prm($pcnt) $val		;#	Then set value
					}
					InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
					if {$gdg_typeflag($gcnt) == $evv(LOGNUMERIC)} {
						ResetScale $pcnt log
					} else {
						ResetScale $pcnt linear
					}
				} else {
					set prm($pcnt) $val			;#	Then set filename
				}
			}	\
			^$evv(LOG)$ {
				if [IsNumeric $val] {
					if {$isint($pcnt)} {
						set val [StripLeadingZeros $val]
						set prm($pcnt) [expr round($val)]
					} else {
						set prm($pcnt) $val		;#	Then set value
					}
					InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
					ResetScale $pcnt log
				} else {
					set prm($pcnt) $val			;#	Then set fnam
				}
			}	\
			^$evv(POWTWO)$ {
				if [IsNumeric $val] {
					set val [StripLeadingZeros $val]
					set prm($pcnt) [expr round($val)]
					InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
					set powtwo_range($pcnt) [expr int(round(log($actvhi($pcnt)) * $evv(ONE_OVER_LN2)))]  
					set powtwo_convertor($pcnt) [expr 1.0 / $powtwo_range($pcnt)]  
					ResetScale $pcnt powtwo
				} else {
					set prm($pcnt) $val			;#	Then set filename
				}
			}	\
			^$evv(PLOG)$ {
				if [IsNumeric $val] {
					if {$isint($pcnt)} {
						set val [StripLeadingZeros $val]
						set prm($pcnt) [expr round($val)]
					} else {
						set prm($pcnt) $val		;#	Then set value
					}
					set pitchdisplay($pcnt) [SetPitchDisplay [expr log ($prm($pcnt))] $gcnt $pcnt]
					ForceVal $prmgrd.pi$gcnt $pitchdisplay($pcnt)
					ResetScale $pcnt log
				} else {
					set prm($pcnt) $val			;#	Then set filename
				}
			}	\
			^$evv(VOWELS)$ -	\
			^$evv(GENERICNAME)$ -	\
			^$evv(STRING_A)$ -	\
			^$evv(STRING_B)$ -	\
			^$evv(STRING_C)$ -	\
			^$evv(STRING_D)$ -	\
			^$evv(STRING_E)$ {
				if {$isint($pcnt)} {
					set prm($pcnt) [expr round($val)]
				} else {
					set prm($pcnt) $val		;#	Then set value
				}
				InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
			} \
			default {
				if {[IsNumeric $val] && $isint($pcnt)} {
					set prm($pcnt) [expr round($val)]
				} else {
					set prm($pcnt) $val		;#	Then set value
				}
			}

		if {$dbl_rng($pcnt)} {
			if {$rangetype($pcnt) != [lindex $penultrange $pcnt]} {
				if [string match "log" $partype($pcnt)] {
					SwitchLogRange $pcnt $gcnt 0 0
					ResetScale $pcnt log
				} else {
					SwitchRange $pcnt $gcnt 0 0
					ResetScale $pcnt linear
				}
			}
		}
		incr pcnt							;#	Next parameter
		incr gcnt							;#	Next gadget

	}
	if {$timetype_altered} {				;#	Reset ranges of affected params
		switch -regexp -- $timetype \
			^$evv(EDIT_SECS)$    {ResetFadeRanges $secs_lo    $secs_hi    $srate_here $chans_here secs 0} \
			^$evv(EDIT_SAMPS)$   {ResetFadeRanges $samps_lo   $samps_hi   $srate_here $chans_here samps 1} \
			^$evv(EDIT_STSAMPS)$ {ResetFadeRanges $stsamps_lo $stsamps_hi $srate_here $chans_here stsmps 2}

		set i 0
		while {$i < $gdg_cnt} {							;#	Reset values of affected params
			if {[IsDeadParam $i]} {
				incr i
				continue
			}
			if {($gdg_typeflag($i) == $evv(NUMERIC)) && [string match *FADE* $parname($i)]} {
				set prm($i) [lindex $var $i]				;#	gadgets in any timetype processes (laziness!)
				InsertParamValueInEntryDisplay $prmgrd.e$i $i
				ResetScale $i linear
			}

			incr i
		}
	}
}

#-------

proc ValidVowelName {str} {

	switch -- $str {
		"ee" { return 1 }
		"i"	 { return 1 }
		"e"	 { return 1 }
		"ai" { return 1 }
		"aii" { return 1 }
		"a"	 { return 1 }
		"ar" { return 1 }
		"o"	 { return 1 }
		"or" { return 1 }
		"oa" { return 1 }
		"u"	 { return 1 }
		"uu" { return 1 }
		"ui" { return 1 }
		"oo" { return 1 }
		"x"	 { return 1 }
		"xx" { return 1 }
		"n"  { return 1 }
		"m"  { return 1 }
		"r"  { return 1 }
		"th" { return 1 }
	}
	return 0
}

proc GetParName {paramno} {
	global evv gdg_cnt prmgrd gdg_typeflag
	set gcnt 0
	set pcnt 0
	while {$gcnt < $gdg_cnt} {
		if {[IsDeadParam $gcnt]} {
			incr gcnt
			incr pcnt
			continue
		}
		if {$pcnt == $paramno} {
			set textout [$prmgrd.no$gcnt.name cget -text]
			return $textout
		}
		if {$gdg_typeflag($gcnt) == $evv(SWITCHED)} {
			incr pcnt
		}
		incr pcnt
		incr gcnt
	}
	return ""
}
