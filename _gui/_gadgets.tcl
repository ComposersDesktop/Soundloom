#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD 30 June 2013
# ... fixup button rectangles

###################################
# SET UP PARAMETER ENTRY GADGETS  #
###################################

#------ Create the parameter-entry displays (gadgets) appropriate to prm type

proc CreateGadgets {} {
	global gdg_cnt pmcnt gdg_typeflag evv pg_spec gno islog ins
	global ins prmgrd timetype_exists gadgets_created evv
	global range_changed refp entry_exists  is_dflt_sr_gadget samp_to_level_convert extrahelp

	set timetype_exists 0
	set is_dflt_sr_gadget -1
	catch {unset extrahelp}

	set gcnt 0
	catch {unset gdg_typeflag}
	set pmcnt 0
	catch {unset entry_exists}
	while {$gcnt < $gdg_cnt} {
		if {[IsDeadParam $gcnt]} {
			CreateDeadParam $gcnt
			incr gcnt
			incr pmcnt
			continue
		}
		set samp_to_level_convert 0
		set is_timetype 0
		set gno $gcnt
		incr gno
		set ins(possible_param) [ParamIsInsCompatible $gcnt]
		set islog($gcnt) 0

		set param_props "[lindex $pg_spec $gcnt]"  			;#	Find prm-props-group for 1 prm
		set prop_id [lindex $param_props 0]				 ;#	Get first property
		set refp($pmcnt) 1
		set entry_exists($gcnt) 1

		switch -- $prop_id {
			CHECKBUTTON {
				if {[llength $param_props] != 2} {
					ErrShow "Wrong number of params for Check-button-gadget"
					return 0
				}
				set refp($pmcnt) 0
				set entry_exists($gcnt) 0
				set cmd CheckButtonGadget
			}
			SWITCHED {
				if {[llength $param_props] != 11} {
					ErrShow "Wrong number of params for Switched-gadget"
					return 0
				}
				set refp($pmcnt) 0
				set cmd SwitchedGadget
			}
			LINEAR {
				if {([llength $param_props] == 9) && [string match [lindex $param_props end] "sg"]} {
					set samp_to_level_convert 1
					set param_props [lrange $param_props 0 7]
				}
				if {[llength $param_props] != 8} {
					ErrShow "Wrong number of params for Linear-gadget"
					return 0
				}
				set cmd LinearGadget
			}
			LOG {
				if {[llength $param_props] != 8} {
					ErrShow "Wrong number of params for Log-gadget"
					return 0
				}
				set islog($gcnt) 1
				set cmd LogGadget
			}
			POWTWO {
				if {[llength $param_props] != 8} {
					ErrShow "Wrong number of params for Powers-of-2-gadget"
					return 0
				}
				set cmd PowtwoGadget
			}
			PLOG {
				if {[llength $param_props] != 8} {
					ErrShow "Wrong number of params for Plog-gadget"
					return 0
				}
				set islog($gcnt) 1
				set cmd PlogGadget
			}
			FILE_OR_VAL {
				if {[llength $param_props] != 6} {
					ErrShow "Wrong number of params for File-or-Val-gadget"
					return 0
				}
				set cmd FileOrValGadget
			}
			OPTIONAL_FILE -
			FILENAME {
				if {[llength $param_props] != 7} {
					ErrShow "Wrong number of params for Filename-gadget"
					return 0
				}
				set cmd FilenameGadget
			}
			NUMERIC {
				if {([llength $param_props] == 7) && [string match [lindex $param_props end] "sg"]} {
					set samp_to_level_convert 1
					set param_props [lrange $param_props 0 5]
				}
				if {[llength $param_props] != 6} {
					ErrShow "Wrong number of params for Numeric-gadget"
					return 0
				}
				set cmd NumericGadget
			}
			LOGNUMERIC {
				if {([llength $param_props] == 7) && [string match [lindex $param_props end] "sg"]} {
					set samp_to_level_convert 1
					set param_props [lrange $param_props 0 5]
				}
				if {[llength $param_props] != 6} {
					ErrShow "Wrong number of params for Log-Numeric-gadget"
					return 0
				}
				set cmd LogNumericGadget
			}
			TIMETYPE {
				if {[llength $param_props] != 3} {
					ErrShow "Wrong number of params for Timetype-gadget"
					return 0
				}
				set refp($pmcnt) 0
				set ins(possible_param) 0
				set timetype_exists 1
				set entry_exists($gcnt) 0
				set cmd TimetypeGadget
			}
			SRATE_GADGET {
				if {[llength $param_props] != 3} {
					ErrShow "Wrong number of params for Srate-gadget"
					return 0
				}
				set refp($pmcnt) 0
				set entry_exists($gcnt) 0
				set cmd SrateGadget
			}
			MIDI_GADGET {
				if {[llength $param_props] != 3} {
					ErrShow "Wrong number of params for Midi-gadget"
					return 0
				}
				set refp($pmcnt) 0
				set entry_exists($gcnt) 0
				set cmd MidiGadget
			}
			OCT_GADGET {
				if {[llength $param_props] != 3} {
					ErrShow "Wrong number of params for Oct-gadget"
					return 0
				}
				set refp($pmcnt) 0
				set entry_exists($gcnt) 0
				set cmd OctGadget
			}
			CHORD_GADGET {
				if {[llength $param_props] != 3} {
					ErrShow "Wrong number of params for Chordsort-gadget"
					return 0
				}
				set refp($pmcnt) 0
				set entry_exists($gcnt) 0
				set cmd ChordGadget
			}
			TWOFAC {
				if {[llength $param_props] != 3} {
					ErrShow "Wrong number of params for Twofac-gadget"
					return 0
				}
				set refp($pmcnt) 0
				set entry_exists($gcnt) 0
				set cmd TwofacGadget
			}
			WAVETYPE {
				if {[llength $param_props] != 3} {
					ErrShow "Wrong number of params for Wavetype-gadget"
					return 0
				}
				set refp($pmcnt) 0
				set entry_exists($gcnt) 0
				set cmd WavetypeGadget
			}
			GENERICNAME -
			STRING_A -
			STRING_B -
			STRING_C -
			STRING_D -
			STRING_E {
				if {[llength $param_props] != 2} {
					ErrShow "Wrong number of params for String-gadget"
					return 0
				}
				set cmd StringGadget
			}
			VOWELS {
				if {[llength $param_props] != 2} {
					ErrShow "Wrong number of params for Vowels-gadget"
					return 0
				}
				set cmd FileOrVowelGadget
			}
			default {
				ErrShow "Unknown gadget identifier ($prop_id) in data from cdparams"
				return 0
			}
		}		
		set gdg_typeflag($gcnt) $evv($prop_id)
		set cmd [concat $cmd [lrange $param_props 1 end]]
		lappend cmd $gcnt $pmcnt

		if [catch {eval $cmd} in] {
			Inf "$in"
			return 0
		}
		set range_changed($pmcnt) 0

		incr pmcnt
		if {$gdg_typeflag($gcnt) == $evv(SWITCHED)} {		;#	switched gadget takes 2 params
			set range_changed($pmcnt) 0
			set refp($pmcnt) 1								;#	2nd switched param can be entered from Ref Vals
			incr pmcnt
		}
		incr gcnt
	}
	set lastrow $gcnt
	incr lastrow $gcnt
	incr lastrow
	frame $prmgrd.lastline -bg [option get . foreground {}] -height 1
	grid $prmgrd.lastline -row $lastrow -column 0 -columnspan 12 -sticky ew
	return 1
}

proc That {thispass} {
	global evv
	set crypt [string range $evv(PI) 2 end]
	set zz 3
	append zz $crypt
	set crypt $zz
	set cryptlen [string length $crypt]

	set len [string length $thispass]
	set i 0
	set j 0
	while {$i < $len} {
		set c [string index $thispass $i]
		set c [Alphindex $c]
		set k [string index $crypt $j]
		incr c -$k
		while {$c < 0} {
			incr c 26
		}
		set c [Indexalph $c]
		if {$i == 0} {
			set newpass $c
		} else {
			append newpass $c
		}
		incr i
		incr j
		if {$j >= $cryptlen} {
			set j 0
		}
	}
	return $newpass
}

#############
# GADGETS	#
#############

#------ LINEAR-SLIDER-BAR GADGET
#
#	  0		  1	   2	  3		   4	5	  6			7				8			   9  |	 11
#	--------------------------------------------------------------------------------------|--------
#  | ----  	----			     ----   /\ 	 ----	____________					      |	 ---   |
#  ||Get | |Make| No: PARAMNAME | lo |  \/  | hi | |val entry...| ======||========	      |	|var|  |
#  ||File| |File|			    |	 | range| 	 | |____________|	 (slider bar)	      |	 ---   |
#  | ----	----			     ---- switch ----									      |        |
#	--------------------------------------------------------------------------------------|--------
#	BRKFILE-ENTRY	  NAME		RANGE-INFORMATION  VALUE-ENTRY....................
#				    & NUMBER
#					OF PARAM
#

proc LinearGadget {name datatype low high dflt sublow subhigh gcnt pcnt} {
	global dfault actvhi actvlo prmgrd scl ins samp_to_level_convert
	global isint canhavefiles prm dbl_rng norange_gdg evv extrahelp

	set thisrow $gcnt
	incr thisrow $gcnt

	set isint($pcnt) 0
	set canhavefiles($pcnt) 0
	if {$datatype == "i" || $datatype == "I"} {
		set isint($pcnt) 1
	}
	if {$datatype == "I" || $datatype == "D"} {
		set canhavefiles($pcnt) 1
	}
	#	NO. AND NAME
	DisplayParamName $name $gcnt $pcnt $pcnt $thisrow
	incr thisrow
	#	FILE ENTRY
	Show_GetInfile_Display $datatype $gcnt $pcnt $thisrow
	DoGadgetBind $datatype
	if {[Midiable $pcnt]} {
		frame $prmgrd.kbd$gcnt
		switch -- [Midiable $pcnt] {
			1 {
				MakeKeyboardKey $prmgrd.kbd$gcnt $evv(MIDITOPARAM) $pcnt
			}
			2 {
				MakeKeyboardKey $prmgrd.kbd$gcnt $evv(MIDITOTRANSPOSPARAM) $pcnt
				set extrahelp(miditotransposparam) $prmgrd.kbd$gcnt
			}
		}
		if {$ins(create)} {
			grid  $prmgrd.kbd$gcnt -row $thisrow -column [expr $evv(INS_VARIABLE) + 1] -sticky w
		} else {
			grid  $prmgrd.kbd$gcnt -row $thisrow -column [expr $evv(MAKE_FILE) + 1] -sticky w
		}
	}

	#	RANGE DISPLAY

	if {$ins(run) && $norange_gdg($gcnt)} {
		EstablishUnknownRange $name $gcnt $pcnt $low $high $thisrow
		set dbl_rng($pcnt) 0
	} elseif {![Flteq $low $sublow] || ![Flteq $high $subhigh]} {
		EstablishRange $gcnt $pcnt $low $high $sublow $subhigh $thisrow $dflt
		set dbl_rng($pcnt) 1 
	} else {
		EstablishSimpleRange $gcnt $pcnt $low $high $thisrow
		set dbl_rng($pcnt) 0
	}
	if {$ins(run)} {
		set prm($pcnt) $dfault($pcnt)
	} else {
		set dfault($pcnt) $dflt
		set prm($pcnt) $dflt
	}

	#	ENTRY BOX
	entry $prmgrd.e$gcnt -textvariable prm($pcnt) -width 14
	grid  $prmgrd.e$gcnt -row $thisrow -column $evv(VAL_ENTRY)
	bind  $prmgrd.e$gcnt <Tab> "ThisParamOK $gcnt $pcnt $prmgrd.e$gcnt"
	bind  $prmgrd.e$gcnt <Shift-Up> "MoveVal $gcnt $pcnt 0"
	bind  $prmgrd.e$gcnt <Shift-Down> "MoveVal $gcnt $pcnt 1"
	bind  $prmgrd.e$gcnt <Command-ButtonRelease-1> "ShowFileParam $prmgrd.e$gcnt $pcnt $gcnt 0 0"
	bind  $prmgrd.e$gcnt <Control-Command-ButtonRelease-1> "ShowFileParam $prmgrd.e$gcnt $pcnt $gcnt 0 1"

	if {$samp_to_level_convert} {
		radiobutton $prmgrd.sg$gcnt -variable dummy -text "smp/lvl" -value 0 \
			-command "SamplesizeToLevelConvert $pcnt $prmgrd.sg$gcnt"
		grid $prmgrd.sg$gcnt -row $thisrow -column $evv(PARAM_SPACE)
	} else {
		set spacc [label $prmgrd.spcc$gcnt -text "" -width 1]
		grid $spacc -row $thisrow -column $evv(PARAM_SPACE)
	}
	#	SLIDER BAR
	set scl($pcnt) [MakeScale $gcnt $pcnt linear]
	grid $scl($pcnt) -row $thisrow -column $evv(SLIDER_BAR)

	set spacc2 [label $prmgrd.spcc2a$gcnt -text "" -width 1]
	grid $spacc2 -row $thisrow -column $evv(PARAM_SPACE2)

	if {$ins(run)} {
		JigInsLinearDefaultDisplay $pcnt $gcnt
		InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
		return
	}
	InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
	SetScale $pcnt linear
}

#------ Setting the LinearGadget-slider-bar and checking file exists for a ins run

proc JigInsLinearDefaultDisplay {pcnt gcnt} {
	global prm actvlo actvhi dfault ins_subdflt dfltrangetype dbl_rng evv gadget_msg

	set gindex $gcnt
	incr gindex

	if [IsNumeric $prm($pcnt)] {
		if {$prm($pcnt) < $actvlo($pcnt) || $prm($pcnt) > $actvhi($pcnt) } {
			if {$dbl_rng($gcnt)} {
				SwitchRange $pcnt $gcnt 0 0
				set dfltrangetype($pcnt) $evv(MAXRANGE_SET)
				if {$prm($pcnt) < $actvlo($pcnt) || $prm($pcnt) > $actvhi($pcnt) } {
					SwitchRange $pcnt $gcnt 0 0
					set dfltrangetype($pcnt) $evv(MINRANGE_SET)
#NEW FEB 2004
					lappend gadget_msg "Instrument default value for parameter $gindex is out of range here : reverting to standard default"
#
#					Inf "Instrument default value for parameter $gindex is out of range here : reverting to standard default"
#
					set dfault($pcnt) $ins_subdflt($pcnt)
					set prm($pcnt) $ins_subdflt($pcnt)
				}
			} else {
				Inf "Instrument default value for parameter $gindex is out of range here : finding best default"
				set dfault($pcnt) $ins_subdflt($pcnt)
				if {$dfault($pcnt) > $actvhi($pcnt)} {
					set dfault($pcnt) $actvhi($pcnt)
				}
				set prm($pcnt) $dfault($pcnt)
			}
		}
		SetScale $pcnt linear
	} else {
		set fnam $prm($pcnt)
		if {![file exists $fnam]} {
#NEW FEB 2004
			lappend gadget_msg "File $prm($pcnt) no longer exists : reverting to standard default value"
#
#			Inf "File '$prm($pcnt)' no longer exists : reverting to standard default value"
#
			set dfault($pcnt) $ins_subdflt($pcnt)
			set prm($pcnt) $ins_subdflt($pcnt)
			SetScale $pcnt linear
		} else {
			set remember $prm($pcnt)
			set prm($pcnt) $ins_subdflt($pcnt)			
			SetScale $pcnt linear
			set dfault($pcnt) $remember
			set prm($pcnt) $remember
		}
	}
}

#------ LOG-SLIDER-BAR GADGET
#
#	  0		  1	   2	  3		   4	5	  6			7				8			   9	|	11
#	----------------------------------------------------------------------------------------|-------
#  | ----  	----			     ----   /\ 	 ----	____________					     	|  ---  |
#  ||Get | |Make| No: PARAMNAME | lo |  \/  | hi | |val entry...| ======||========	     	| |var| |
#  ||File| |File|			    |	 | range| 	 | |____________|	 (slider bar)	    	|  ---  |
#  | ----	----			     ---- switch ----									     	|       |
#	----------------------------------------------------------------------------------------|-------
#	BRKFILE-ENTRY	  NAME		RANGE-INFORMATION  VALUE-ENTRY....................
#				    & NUMBER
#					OF PARAM
#


proc LogGadget {name datatype low high dflt sublow subhigh gcnt pcnt} {
	global dfault actvhi actvlo prmgrd scl norange_gdg
	global prm isint canhavefiles dbl_rng ins evv extrahelp

	set thisrow $gcnt
	incr thisrow $gcnt

	set isint($pcnt) 0
	set canhavefiles($pcnt) 0
	if {$datatype == "i" || $datatype == "I"} {
		set isint($pcnt) 1
	}
	if {$datatype == "I" || $datatype == "D"} {
		set canhavefiles($pcnt) 1
	}

	#	NO. AND NAME
	DisplayParamName $name $gcnt $pcnt $pcnt $thisrow
	incr thisrow
	#	FILE ENTRY
	Show_GetInfile_Display $datatype $gcnt $pcnt $thisrow
	DoGadgetBind $datatype
	if {[Midiable $pcnt]} {
		frame $prmgrd.kbd$gcnt
		switch -- [Midiable $pcnt] {
			1 {
				MakeKeyboardKey $prmgrd.kbd$gcnt $evv(MIDITOPARAM) $pcnt
			}
			2 {
				MakeKeyboardKey $prmgrd.kbd$gcnt $evv(MIDITOTRANSPOSPARAM) $pcnt
				set extrahelp(miditotransposparam) $prmgrd.kbd$gcnt
			}
		}
		if {$ins(create)} {
			grid  $prmgrd.kbd$gcnt -row $thisrow -column [expr $evv(INS_VARIABLE) + 1] -sticky w
		} else {
			grid  $prmgrd.kbd$gcnt -row $thisrow -column [expr $evv(MAKE_FILE) + 1] -sticky w
		}
	}
	#	RANGE DISPLAY

	if {$ins(run) && $norange_gdg($gcnt)} {
		EstablishUnknownRange $name $gcnt $pcnt $low $high $thisrow
		set dbl_rng($pcnt) 0
	} elseif {![Flteq $low $sublow] || ![Flteq $high $subhigh]} {
		EstablishLogRange $gcnt $pcnt $low $high $sublow $subhigh $thisrow $dflt
		set dbl_rng($pcnt) 1
	} else {
		EstablishSimpleLogRange $gcnt $pcnt $low $high $thisrow
		set dbl_rng($pcnt) 0
	}

	if {$ins(run)} {
		set prm($pcnt) $dfault($pcnt)
	} else {
		set dfault($pcnt) $dflt
		set prm($pcnt) $dflt
	}

	#	ENTRY BOX
	entry $prmgrd.e$gcnt -textvariable prm($pcnt) -width 14
	grid  $prmgrd.e$gcnt -row $thisrow -column $evv(VAL_ENTRY)
	bind  $prmgrd.e$gcnt <Tab> "ThisParamOK $gcnt $pcnt $prmgrd.e$gcnt"
	bind  $prmgrd.e$gcnt <Shift-Up> "MoveVal $gcnt $pcnt 0"
	bind  $prmgrd.e$gcnt <Shift-Down> "MoveVal $gcnt $pcnt 1"
	bind  $prmgrd.e$gcnt <Command-ButtonRelease-1> "ShowFileParam $prmgrd.e$gcnt $pcnt $gcnt 0 0"
	bind  $prmgrd.e$gcnt <Control-Command-ButtonRelease-1> "ShowFileParam $prmgrd.e$gcnt $pcnt $gcnt 0 1"

	set spacc [label $prmgrd.spcc$gcnt -text "" -width 1]
	grid $spacc -row $thisrow -column $evv(PARAM_SPACE)

	#	SLIDER BAR

	set scl($pcnt) [MakeScale $gcnt $pcnt log]
	grid $scl($pcnt) -row $thisrow -column $evv(SLIDER_BAR)

	set spacc2 [label $prmgrd.spcc2a$gcnt -text "" -width 1]
	grid $spacc2 -row $thisrow -column $evv(PARAM_SPACE2)

	if {$ins(run)} {
		JigInsLogDefaultDisplay	$pcnt $gcnt
		InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
		return
	}
	InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
	SetScale $pcnt log
}

#------ Setting the (P)LogGadget-slider-bar and checking file exists for a ins run

proc JigInsLogDefaultDisplay {pcnt gcnt} {
	global prm actvlo actvhi dfault ins_subdflt dfltrangetype dbl_rng evv gadget_msg

	set gindex $gcnt
	incr gindex

	if [IsNumeric $prm($pcnt)] {
		if {$prm($pcnt) < $actvlo($pcnt) || $prm($pcnt) > $actvhi($pcnt) } {

			if {$dbl_rng($pcnt)} {
				SwitchLogRange $pcnt $gcnt 0 0
				set dfltrangetype($pcnt) $evv(MAXRANGE_SET)
				if {$prm($pcnt) < $actvlo($pcnt) || $prm($pcnt) > $actvhi($pcnt) } {
					SwitchLogRange $pcnt $gcnt 0 0
					set dfltrangetype($pcnt) $evv(MINRANGE_SET)
#NEW FEB 2004
					lappend gadget_msg "Instrument default value for parameter $gindex is out of range here : reverting to standard default"
#
#					Inf "Instrument default value for parameter $gindex is out of range here : reverting to standard default"
#
					set dfault($pcnt) $ins_subdflt($pcnt)
					set prm($pcnt) $ins_subdflt($pcnt)
				}
			} else {
#NEW FEB 2004
				lappend gadget_msg "Instrument default value for parameter $gindex is out of range here : finding best default"
#
#				Inf "Instrument default value for parameter $gindex is out of range here : finding best default"
#
				set dfault($pcnt) $ins_subdflt($pcnt)
				if {$dfault($pcnt) > $actvhi($pcnt)} {
					set dfault($pcnt) $actvhi($pcnt)
				}
				set prm($pcnt) $dfault($pcnt)
			}
		}
		SetScale $pcnt log
	} else {
		set fnam $prm($pcnt)
		if {![file exists $fnam]} {
#NEW FEB 2004
			lappend gadget_msg "File $prm($pcnt) no longer exists : reverting to standard default value"
#
#			Inf "File $prm($pcnt) no longer exists : reverting to standard default value"
#
			set dfault($pcnt) $ins_subdflt($pcnt)
			set prm($pcnt) $ins_subdflt($pcnt)
			SetScale $pcnt log
		} else {
			set remember $prm($pcnt)
			set prm($pcnt) $ins_subdflt($pcnt)			
			SetScale $pcnt log
			set dfault($pcnt) $remember
			set prm($pcnt) $remember
		}
	}
}

#------ PLOG-SLIDER-BAR GADGET
#
#	  0		 1	   2	  3		   4	5	  6			7				8			   9	 10	   |  11
#	-----------------------------------------------------------------------------------------------|-------
#  | ----  	----			     ----   /\ 	 ----	____________					 -----	 ----  |  ---  |
#  ||Get | |Make| No: PARAMNAME | lo |  \/  | hi | |val entry...| ======||========	|pitch|	|pch | | |var| |
#  ||File| |File|			    |	 | range| 	 | |____________|	 (slider bar)	|dsply|	|fix | |  ---  |
#  | ----	----			     ---- switch ----									 -----	 ----  |       |
#	-----------------------------------------------------------------------------------------------|-------
#	BRKFILE-ENTRY	  NAME		RANGE-INFORMATION  VALUE-ENTRY....................	PITCHVAL......
#				    & NUMBER														DISPLAY
#					OF PARAM
#

proc PlogGadget {name datatype low high dflt sublow subhigh gcnt pcnt} {
	global dfault prm evv prmgrd scl isint canhavefiles norange_gdg
	global pitchdisplay actvhi actvlo dbl_rng ins
	global prm readonlyfg readonlybg extrahelp

	set thisrow $gcnt
	incr thisrow $gcnt

	set isint($pcnt) 0
	set canhavefiles($pcnt) 0
	if {$datatype == "i" || $datatype == "I"} {
		set isint($pcnt) 1
	}
	if {$datatype == "I" || $datatype == "D"} {
		set canhavefiles($pcnt) 1
	}

	#	NO. AND NAME
	DisplayParamName $name $gcnt $pcnt $pcnt $thisrow
	incr thisrow
	#	FILE ENTRY
	Show_GetInfile_Display $datatype $gcnt $pcnt $thisrow
	DoGadgetBind $datatype
	if {[Midiable $pcnt]} {
		frame $prmgrd.kbd$gcnt
		switch -- [Midiable $pcnt] {
			1 {
				MakeKeyboardKey $prmgrd.kbd$gcnt $evv(MIDITOPARAM) $pcnt
			}
			2 {
				MakeKeyboardKey $prmgrd.kbd$gcnt $evv(MIDITOTRANSPOSPARAM) $pcnt
				set extrahelp(miditotransposparam) $prmgrd.kbd$gcnt
			}
		}
		if {$ins(create)} {
			grid  $prmgrd.kbd$gcnt -row $thisrow -column [expr $evv(INS_VARIABLE) + 1] -sticky w
		} else {
			grid  $prmgrd.kbd$gcnt -row $thisrow -column [expr $evv(MAKE_FILE) + 1] -sticky w
		}
	}
	#	RANGE DISPLAY
	if {$ins(run) && $norange_gdg($gcnt)} {
		EstablishUnknownRange $name $gcnt $pcnt $low $high $thisrow
		set dbl_rng($pcnt) 0
	} elseif {![Flteq $low $sublow] || ![Flteq $high $subhigh]} {
		EstablishLogRange $gcnt $pcnt $low $high $sublow $subhigh $thisrow $dflt
		set dbl_rng($pcnt) 1
	} else {
		EstablishSimpleLogRange $gcnt $pcnt $low $high $thisrow
		set dbl_rng($pcnt) 0
	}

	if {$ins(run)} {
		set prm($pcnt) $dfault($pcnt)
	} else {
		set dfault($pcnt) $dflt
		set prm($pcnt) $dflt
	}
	#	ENTRY BOX
	entry $prmgrd.e$gcnt -textvariable prm($pcnt) -width 14
	grid  $prmgrd.e$gcnt -row $thisrow -column $evv(VAL_ENTRY)
	bind  $prmgrd.e$gcnt <Tab> "ThisParamOK $gcnt $pcnt $prmgrd.e$gcnt"
	bind  $prmgrd.e$gcnt <Shift-Up> "MoveVal $gcnt $pcnt 0"
	bind  $prmgrd.e$gcnt <Shift-Down> "MoveVal $gcnt $pcnt 1"
	bind  $prmgrd.e$gcnt <Command-ButtonRelease-1> "ShowFileParam $prmgrd.e$gcnt $pcnt $gcnt 0 0"
	bind  $prmgrd.e$gcnt <Control-Command-ButtonRelease-1> "ShowFileParam $prmgrd.e$gcnt $pcnt $gcnt 0 1"

	set spacc [label $prmgrd.spcc$gcnt -text "" -width 1]
	grid $spacc -row $thisrow -column $evv(PARAM_SPACE)

	#	SLIDER BAR
	set scl($pcnt) [MakeScale $gcnt $pcnt plog]
	grid $scl($pcnt) -row $thisrow -column $evv(SLIDER_BAR)

	#	PITCH DISPLAY
	entry $prmgrd.pi$gcnt -textvariable pitchdisplay($pcnt) -width 5 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
	grid $prmgrd.pi$gcnt -row $thisrow -column $evv(PITCH_DSPLY)
	# 	PITCHFIX BUTTON
	button $prmgrd.pf$gcnt -text "Exact" -command "FixPitch $pcnt $gcnt" -highlightbackground [option get . background {}]
	grid $prmgrd.pf$gcnt -row $thisrow -column $evv(PITCH_FIX)

	set spacc2 [label $prmgrd.spcc2a$gcnt -text "" -width 1]
	grid $spacc2 -row $thisrow -column $evv(PARAM_SPACE2)

	# ADD BINDING FROM SLIDER TO PITCH DISPLAY

	bind $prmgrd.s$gcnt  <ButtonRelease-1> "SetPitchValFromSlider $gcnt $pcnt"
	# ADD BINDING FROM ENTRY-BOX TO PITCH DISPLAY
	bind $prmgrd.e$gcnt <Tab> "+ SetPitchValFromEntrybox $gcnt $pcnt"

	if {$ins(run)} {
		JigInsPLogDefaultDisplay $pcnt $gcnt
		InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
		return
	}
	InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
	set pitchdisplay($pcnt) [SetPitchDisplay [expr log ($prm($pcnt))] $gcnt $pcnt]
	ForceVal $prmgrd.pi$gcnt $pitchdisplay($pcnt)
	SetScale $pcnt log
}


#------ Setting the (P)LogGadget-slider-bar and checking file exists for a ins run

proc JigInsPLogDefaultDisplay {pcnt gcnt} {
	global prm actvlo actvhi dfault dfltrangetype ins_subdflt prmgrd dbl_rng evv gadget_msg
	global pitchdisplay

	set gindex $gcnt
	incr gindex

	if [IsNumeric $prm($pcnt)] {
		if {$prm($pcnt) < $actvlo($pcnt) || $prm($pcnt) > $actvhi($pcnt) } {
			if {$dbl_rng($pcnt)} {
				SwitchLogRange $pcnt $gcnt 0 0
				set dfltrangetype($pcnt) $evv(MAXRANGE_SET)
				if {$prm($pcnt) < $actvlo($pcnt) || $prm($pcnt) > $actvhi($pcnt) } {
					SwitchLogRange $pcnt $gcnt 0 0
					set dfltrangetype($pcnt) $evv(MINRANGE_SET)
#NEW FEB 2004
					lappend gadget_msg "Instrument default value for parameter $gindex is out of range here : reverting to standard default"
#
#					Inf "Instrument default value for parameter $gindex is out of range here : reverting to standard default"
#
					set dfault($pcnt) $ins_subdflt($pcnt)
					set prm($pcnt) $ins_subdflt($pcnt)
				}
			} else {
#NEW FEB 2004
				lappend gadget_msg "Instrument default value for parameter $gindex is out of range here : finding best default"
#
#				Inf "Instrument default value for parameter $gindex is out of range here : finding best default"
#
				set dfault($pcnt) $ins_subdflt($pcnt)
				if {$dfault($pcnt) > $actvhi($pcnt)} {
					set dfault($pcnt) $actvhi($pcnt)
				}
				set prm($pcnt) $dfault($pcnt)
			}
		}
		set pitchdisplay($pcnt) [SetPitchDisplay [expr log ($prm($pcnt))] $gcnt $pcnt]
		ForceVal $prmgrd.pi$gcnt $pitchdisplay($pcnt)
		SetScale $pcnt log
	} else {
		set fnam $prm($pcnt)
		if {![file exists $fnam]} {
#NEW FEB 2004
			lappend gadget_msg "File $prm($pcnt) no longer exists : reverting to standard default value"
#
#			Inf "File $prm($pcnt) no longer exists : reverting to standard default value"
#
			set dfault($pcnt) $ins_subdflt($pcnt)
			set prm($pcnt) $ins_subdflt($pcnt)
			set pitchdisplay($pcnt) [SetPitchDisplay [expr log ($prm($pcnt))] $gcnt $pcnt]
			ForceVal $prmgrd.pi$gcnt $pitchdisplay($pcnt)
			SetScale $pcnt log
		} else {
			set remember $prm($pcnt)
			set prm($pcnt) $ins_subdflt($pcnt)			
			SetScale $pcnt log
			set pitchdisplay($pcnt) [SetPitchDisplay [expr log ($prm($pcnt))] $gcnt $pcnt]
			ForceVal $prmgrd.pi$gcnt $pitchdisplay($pcnt)
			set dfault($pcnt) $remember
			set prm($pcnt) $remember
		}
	}
}

#------ FILE-OR-VAL GADGET	
#
#		Special parameters, with a single range: files entered as TEXTFILES
#	  0		 1	   2	  3		   4	5	  6			7				8			   9	 10	   |  11
#	-----------------------------------------------------------------------------------------------|-------
#  | ----  	----			     ----    	 ----	____________								   |  ---  |
#  ||Get | |Make| No: PARAMNAME | lo |      | hi | |val entry...| ======||========				   | |var| |
#  ||File| |File|			    |	 |  	| 	 | |____________|	 (slider bar)				   |  ---  |
#  | ----	----			     ---- 		 ----									 			   |       |
#	-----------------------------------------------------------------------------------------------|-------
#	ODDFILE-ENTRY	  NAME		RANGE-INFORMATION  VALUE-ENTRY....................	
#				    & NUMBER														
#					OF PARAM
#

proc FileOrValGadget {name datatype low high dflt gcnt pcnt} {
	global dfault isint canhavefiles prmgrd scl norange_gdg
	global prm dbl_rng ins evv

	set thisrow $gcnt
	incr thisrow $gcnt

	set dbl_rng($pcnt) 0

	set isint($pcnt) 0
	set canhavefiles($pcnt) 0
	if {$datatype == "i" || $datatype == "I"} {
		set isint($pcnt) 1
	}
	if {$datatype == "I" || $datatype == "D"} {
		set canhavefiles($pcnt) 1
	}

	#	NO. AND NAME
	DisplayParamName $name $gcnt $pcnt $pcnt $thisrow
	incr thisrow
	#	FILE ENTRY
	SetupTextInfileDisplay $gcnt $pcnt $thisrow
	DoGadgetBind 0
	#	RANGE DISPLAY
	if {$ins(run) && $norange_gdg($gcnt)} {
		EstablishUnknownRange $name $gcnt $pcnt $low $high $thisrow
	} else {
		EstablishSimpleRange $gcnt $pcnt $low $high $thisrow
	}

	if {$ins(run)} {
		set prm($pcnt) $dfault($pcnt)
	} else {
	 	set dfault($pcnt) $dflt
		set prm($pcnt) $dflt
	}

	#	ENTRY BOX
	entry $prmgrd.e$gcnt -textvariable prm($pcnt) -width 14
	grid  $prmgrd.e$gcnt -row $thisrow -column $evv(VAL_ENTRY)
	bind  $prmgrd.e$gcnt <Tab> "ThisParamOK $gcnt $pcnt $prmgrd.e$gcnt"
	bind  $prmgrd.e$gcnt <Shift-Up> "MoveVal $gcnt $pcnt 0"
	bind  $prmgrd.e$gcnt <Shift-Down> "MoveVal $gcnt $pcnt 1"
	bind  $prmgrd.e$gcnt <Command-ButtonRelease-1> "ShowFileParam $prmgrd.e$gcnt $pcnt $gcnt 0 0"
	bind  $prmgrd.e$gcnt <Control-Command-ButtonRelease-1> "ShowFileParam $prmgrd.e$gcnt $pcnt $gcnt 0 1"

	set spacc [label $prmgrd.spcc$gcnt -text "" -width 1]
	grid $spacc -row $thisrow -column $evv(PARAM_SPACE)

	#	SLIDER BAR
	set scl($pcnt) [MakeScale $gcnt $pcnt linear]
	grid $scl($pcnt) -row $thisrow -column $evv(SLIDER_BAR)

	set spacc2 [label $prmgrd.spcc2a$gcnt -text "" -width 1]
	grid $spacc2 -row $thisrow -column $evv(PARAM_SPACE2)

	if {$ins(run)} {
		JigInsFileOrValDefaultDisplay $pcnt $gcnt
		InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
		return
	}

	InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
	SetScale $pcnt linear
}

#------ Setting the FileOrValGadget-slider-bar and checking file exists for a ins run

proc JigInsFileOrValDefaultDisplay {pcnt gcnt} {
	global prm actvlo actvhi dfault ins_subdflt evv gadget_msg

	set gindex $gcnt
	incr gindex

	if [IsNumeric $prm($pcnt)] {
		if {$prm($pcnt) < $actvlo($pcnt) || $prm($pcnt) > $actvhi($pcnt) } {
#NEW FEB 2004
			lappend gadget_msg "Instrument default value for parameter $gindex is out of range here : finding best default"
#
#			Inf "Instrument default value for parameter $gindex is out of range here : finding best default"
#
			set dfault($pcnt) $ins_subdflt($pcnt)
			if {$dfault($pcnt) > $actvhi($pcnt)} {
				set dfault($pcnt) $actvhi($pcnt)
			}
			set prm($pcnt) $dfault($pcnt)
		}
		SetScale $pcnt linear
	} else {
		set fnam $prm($pcnt)
		if {![file exists $fnam]} {
#NEW FEB 2004
			lappend gadget_msg "File $prm($pcnt) no longer exists : reverting to standard default value"
#
#			Inf "File $prm($pcnt) no longer exists : reverting to standard default value"
#
			set dfault($pcnt) $ins_subdflt($pcnt)
			set prm($pcnt) $ins_subdflt($pcnt)
			SetScale $pcnt linear
		} else {
			set remember $prm($pcnt)
			set prm($pcnt) $ins_subdflt($pcnt)			
			SetScale $pcnt linear
			set dfault($pcnt) $remember
			set prm($pcnt) $remember
		}
	}
}

#------ FILE-OR-VOWEL GADGET	
#
#		vowel parameters, files entered as TEXTFILES as as VOWEL STRING
#	  0		 1	   2	  3		   4	5	  6			7				8			   9	 10	   |  11
#	-----------------------------------------------------------------------------------------------|-------
#  | ----  	----			     ____________								   					   |  ---  |
#  ||Get | |Make| No: PARAMNAME |val entry...| 								   					   | |var| |
#  ||File| |File|			    |____________|	 							  					   |  ---  |
#  | ----	----			    									 			   				   |       |
#	-----------------------------------------------------------------------------------------------|-------
#	ODDFILE-ENTRY	  NAME		RANGE-INFORMATION  VALUE-ENTRY....................	
#				    & NUMBER														
#					OF PARAM
#

proc FileOrVowelGadget {name gcnt pcnt} {
	global dfault isint canhavefiles prmgrd scl norange_gdg gadget_msg
	global prm dbl_rng ins evv

	set thisrow $gcnt
	incr thisrow $gcnt

	set dbl_rng($pcnt) 0

	set isint($pcnt) 0
	set canhavefiles($pcnt) 1

	#	NO. AND NAME
	DisplayParamName $name $gcnt $pcnt $pcnt $thisrow
	incr thisrow
	#	FILE ENTRY
	SetupTextInfileDisplay $gcnt $pcnt $thisrow
	DoGadgetBind 0

	if {$ins(run)} {
		set prm($pcnt) $dfault($pcnt)
	} else {
	 	set dfault($pcnt) "a"
		set prm($pcnt) "a"
	}

	#	ENTRY BOX
	entry $prmgrd.e$gcnt -textvariable prm($pcnt) -width 14
	grid  $prmgrd.e$gcnt -row $thisrow -column $evv(VAL_ENTRY)
	bind  $prmgrd.e$gcnt <Tab> "ThisParamOK $gcnt $pcnt $prmgrd.e$gcnt"
	bind  $prmgrd.e$gcnt <Command-ButtonRelease-1> "ShowFileParam $prmgrd.e$gcnt $pcnt $gcnt 0 0"
	bind  $prmgrd.e$gcnt <Control-Command-ButtonRelease-1> "ShowFileParam $prmgrd.e$gcnt $pcnt $gcnt 0 1"

	set spacc [label $prmgrd.spcc$gcnt -text "" -width 1]
	grid $spacc -row $thisrow -column $evv(PARAM_SPACE)

	if {$ins(run)} {
		if {![ValidVowelName $prm($pcnt)]} {
			set fnam $prm($pcnt)
			if {![file exists $fnam]} {
#NEW FEB 2004
				lappend gadget_msg "File $prm($pcnt) no longer exists : reverting to standard default value"
#
#				Inf "File $prm($pcnt) no longer exists : reverting to standard default value"
#
				set dfault($pcnt) "a"
				set prm($pcnt) "a"
			} else {
				set remember $prm($pcnt)
				set prm($pcnt) $ins_subdflt($pcnt)			
				set dfault($pcnt) $remember
				set prm($pcnt) $remember
			}
		}
	}
}

#------ FILENAME GADGET	
#
#	(Special params: files entered as TEXTFILES only) May display 0, 1 or 2 ranges, for users
#	  0		 1	   2	  3		   4	5	  6			7				8		9	   10		   |  11
#	-----------------------------------------------------------------------------------------------|-------
#  | ----  	----			     					____________								   |  ---  |
#  ||Get | |Make| No: PARAMNAME 				   |val entry...| 								   | |var| |
#  ||File| |File|			    				   |____________|	 							   |  ---  |
#  | ----	----			     													 			   |       |
#	-----------------------------------------------------------------------------------------------|-------
#																									
#	-----------------------------------------------------------------------------------------------|-------
#  | ----  	----			     ----    	 ----	____________								   |  ---  |
#  ||Get | |Make| No: PARAMNAME | lo |Range1| hi | |val entry...|  								   | |var| |
#  ||File| |File|			    |	 |  	| 	 | |____________|  								   |  ---  |
#  | ----	----			     ---- 		 ----												   |       |
#	-----------------------------------------------------------------------------------------------|-------
#
#	-----------------------------------------------------------------------------------------------|-------
#  | ----  	----			     ----    	 ----	____________	----			 ----		   |  ---  |
#  ||Get | |Make| No: PARAMNAME | lo |Range1| hi | |val entry...|  | lo |	Range2	| hi |		   | |var| |
#  ||File| |File|			    |	 |  	| 	 | |____________|  |    |	   		|    |		   |  ---  |
#  | ----	----			     ---- 		 ----					----			----		   |       |
#	-----------------------------------------------------------------------------------------------|-------
#	ODDFILE-ENTRY	  NAME						   VALUE-ENTRY
#				    & NUMBER														
#					OF PARAM
#

proc FilenameGadget {name datatype low high sublow subhigh gcnt pcnt} {
	global prm isint canhavefiles dfault prmgrd dbl_rng norange_gdg ins gdg_typeflag evv

	set thisrow $gcnt
	incr thisrow $gcnt

	set dbl_rng($pcnt) 0
	set isint($pcnt) 0
	set canhavefiles($pcnt) 0

	#	NO. AND NAME
	DisplayParamName $name $gcnt $pcnt $pcnt $thisrow
	incr thisrow
	#	TEXT-FILE ENTRY
	SetupTextInfileDisplay $gcnt $pcnt $thisrow
	DoGadgetBind 0

	if {$ins(run)} {
		set prm($pcnt) $dfault($pcnt)
	} elseif {$gdg_typeflag($gcnt) == $evv(OPTIONAL_FILE)} {
		set dfault($pcnt) 0
		set prm($pcnt) 0
	} else {
		set dfault($pcnt) "filename"
		set prm($pcnt) "filename"
	}

	#	ENTRY BOX
	entry $prmgrd.e$gcnt -textvariable prm($pcnt) -width 14
	grid  $prmgrd.e$gcnt -row $thisrow -column $evv(VAL_ENTRY)
	bind  $prmgrd.e$gcnt <Tab> "ThisParamOK $gcnt $pcnt $prmgrd.e$gcnt"
	bind  $prmgrd.e$gcnt <Command-ButtonRelease-1> "ShowFileParam $prmgrd.e$gcnt $pcnt $gcnt 0 0"
	bind  $prmgrd.e$gcnt <Control-Command-ButtonRelease-1> "ShowFileParam $prmgrd.e$gcnt $pcnt $gcnt 0 1"


	if {$ins(run) && $norange_gdg($gcnt) && ($datatype ==1 || $datatype == 2)} {
		EstablishUnknownRange $name $gcnt $pcnt $low $high $thisrow
	} else {
		switch -- $datatype {
			0 {}
			1 {
				EstablishSimpleRange $gcnt $pcnt $low $high $thisrow
				set spacc [label $prmgrd.spcc$gcnt -text "" -width 1]
				grid $spacc -row $thisrow -column $evv(PARAM_SPACE)
			}
			2 {		
				EstablishSimpleRange $gcnt $pcnt $low $high $thisrow
				EstablishOtherRange $gcnt $pcnt $sublow $subhigh $evv(PARAM_SPACE) $thisrow
			}
			default {
				ErrShow "Erroneous datatype for FilenameGadget range display"
			}
		}
	}
	if {$ins(run)} {
		JigInsFilenameDefaultDisplay $pcnt $gcnt
	}
	InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
}

#------ Checking the FilenameGadget default-file exists for a ins run

proc JigInsFilenameDefaultDisplay {pcnt gcnt} {
	global prm dfault ins_subdflt gadget_msg

	set fnam $prm($pcnt)
	set $dfault($pcnt) $prm($pcnt)
	if {![file exists $fnam]} {
#NEW FEB 2004
		lappend gadget_msg "File $prm($pcnt) no longer exists"
#
#		Inf "File $prm($pcnt) no longer exists"
#
		set dfault($pcnt) $ins_subdflt($pcnt)
		set prm($pcnt) $ins_subdflt($pcnt)
	}
}

#------ NUMERIC GADGET
#
#	  0		 1	   2	  3		   4	5	  6			7				8			   9	|	11
#	----------------------------------------------------------------------------------------|-------
#  | 						     ----    	 ----	____________					 		|  ---  |
#  |			  No: PARAMNAME | lo |      | hi | |val entry...| ======||========			| |var| |
#  |						    |	 | 		| 	 | |____________|	 (slider bar)			|  ---  |
#  | 						     ---- 		 ----									 		|       |
#	----------------------------------------------------------------------------------------|-------
#					  NAME		RANGE-INFORMATION  VALUE-ENTRY....................	
#				    & NUMBER														
#					OF PARAM
#

proc NumericGadget {name datatype low high dflt gcnt pcnt} {
	global dfault isint prm prmgrd scl canhavefiles dbl_rng ins evv
	global chlist ins_timetype norange_gdg actvhi samp_to_level_convert

	set thisrow $gcnt
	incr thisrow $gcnt
 	set dbl_rng($pcnt) 0

	set isint($pcnt) 0
	set canhavefiles($pcnt) 0
	if {$datatype == "i" || $datatype == "I"} {
		set isint($pcnt) 1
	}

	if {$ins(run)} {
		set fix_timetype 0
		if {($ins_timetype($gcnt) > 0)} {
			set fix_timetype 1
		} elseif {$norange_gdg($gcnt) && [IsAnEditProcessUsingSamples $gcnt]} {
			set fix_timetype 1
		}
		if {$fix_timetype} {
			set fnam [lindex $chlist 0]
			set invals [eval {SetTimeType $ins_timetype($gcnt) $fnam} $low $high $dflt]
			set low 	[lindex $invals 0]
			set high 	[lindex $invals 1]
			set dflt 	[lindex $invals 2]
			set isint($pcnt) 1
		}
	}
	#	NO. AND NAME
	DisplayParamName $name $gcnt $pcnt $pcnt $thisrow
	incr thisrow
	#	RANGE DISPLAY

	if {$ins(run) && $norange_gdg($gcnt)} {
		EstablishUnknownRange $name $gcnt $pcnt $low $high $thisrow
		set dbl_rng($pcnt) 0
	} else {
		EstablishSimpleRange $gcnt $pcnt $low $high $thisrow
	}
	if {$ins(run)} {
		if {$dfault($pcnt) > $actvhi($pcnt)} {
			set dfault($pcnt) $actvhi($pcnt)
		}
		set prm($pcnt) $dfault($pcnt)
	} else {
		set dfault($pcnt) $dflt
		set prm($pcnt) $dflt
	}
	#	ENTRY BOX
	entry $prmgrd.e$gcnt -textvariable prm($pcnt) -width 14
	grid  $prmgrd.e$gcnt -row $thisrow -column $evv(VAL_ENTRY)
	bind  $prmgrd.e$gcnt <Tab> "ThisParamOK $gcnt $pcnt $prmgrd.e$gcnt"
	bind  $prmgrd.e$gcnt <Shift-Up> "MoveVal $gcnt $pcnt 0"
	bind  $prmgrd.e$gcnt <Shift-Down> "MoveVal $gcnt $pcnt 1"

	if {$samp_to_level_convert} {
		radiobutton $prmgrd.sg$gcnt -variable dummy -text "smp/lvl" -value 0 \
			-command "SamplesizeToLevelConvert $pcnt $prmgrd.sg$gcnt"
		grid $prmgrd.sg$gcnt -row $thisrow -column $evv(PARAM_SPACE)
	} else {
		set spacc [label $prmgrd.spcc$gcnt -text "" -width 1]
		grid $spacc -row $thisrow -column $evv(PARAM_SPACE)
	}
	#	SLIDER BAR
	set scl($pcnt) [MakeScale $gcnt $pcnt linear]
	grid $scl($pcnt) -row $thisrow -column $evv(SLIDER_BAR)

	set spacc2 [label $prmgrd.spcc2a$gcnt -text "" -width 1]
	grid $spacc2 -row $thisrow -column $evv(PARAM_SPACE2)

	InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
	SetScale $pcnt linear
}

#------ LOGNUMERIC GADGET
#
#	  0		 1	   2	  3		   4	5	  6			7				8			   9	|	11
#	----------------------------------------------------------------------------------------|-------
#  | 						     ----    	 ----	____________					 		|  ---  |
#  |			  No: PARAMNAME | lo |      | hi | |val entry...| ======||========			| |var| |
#  |						    |	 | 		| 	 | |____________|	 (slider bar)			|  ---  |
#  | 						     ---- 		 ----									 		|       |
#	----------------------------------------------------------------------------------------|-------
#					  NAME		RANGE-INFORMATION  VALUE-ENTRY....................	
#				    & NUMBER														
#					OF PARAM
#

proc LogNumericGadget {name datatype low high dflt gcnt pcnt} {
	global dfault isint prm prmgrd scl canhavefiles dbl_rng ins evv
	global ins_timetype norange_gdg actvhi samp_to_level_convert

	set thisrow $gcnt
	incr thisrow $gcnt
 	set dbl_rng($pcnt) 0

	set isint($pcnt) 0
	set canhavefiles($pcnt) 0
	if {$datatype == "i" || $datatype == "I"} {
		set isint($pcnt) 1
	}

	#	NO. AND NAME
	DisplayParamName $name $gcnt $pcnt $pcnt $thisrow
	incr thisrow
	#	RANGE DISPLAY

	if {$ins(run) && $norange_gdg($gcnt)} {
		EstablishUnknownRange $name $gcnt $pcnt $low $high $thisrow
		set dbl_rng($pcnt) 0
	} else {
		EstablishSimpleLogRange $gcnt $pcnt $low $high $thisrow
	}
	if {$ins(run)} {
		if {$dfault($pcnt) > $actvhi($pcnt)} {
			set dfault($pcnt) $actvhi($pcnt)
		}
		set prm($pcnt) $dfault($pcnt)
	} else {
		set dfault($pcnt) $dflt
		set prm($pcnt) $dflt
	}
	#	ENTRY BOX
	entry $prmgrd.e$gcnt -textvariable prm($pcnt) -width 14
	grid  $prmgrd.e$gcnt -row $thisrow -column $evv(VAL_ENTRY)
	bind  $prmgrd.e$gcnt <Tab> "ThisParamOK $gcnt $pcnt $prmgrd.e$gcnt"
	bind  $prmgrd.e$gcnt <Shift-Up> "MoveVal $gcnt $pcnt 0"
	bind  $prmgrd.e$gcnt <Shift-Down> "MoveVal $gcnt $pcnt 1"

	set spacc [label $prmgrd.spcc$gcnt -text "" -width 1]
	grid $spacc -row $thisrow -column $evv(PARAM_SPACE)

	#	SLIDER BAR
	set scl($pcnt) [MakeScale $gcnt $pcnt log]
	grid $scl($pcnt) -row $thisrow -column $evv(SLIDER_BAR)

	set spacc2 [label $prmgrd.spcc2a$gcnt -text "" -width 1]
	grid $spacc2 -row $thisrow -column $evv(PARAM_SPACE2)

	if {$ins(run)} {
		SetScale $pcnt log
		InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
		return
	}
	InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
	SetScale $pcnt log
}

#------ Note timetype of gadget using samples instead of seconds, where a default duration range has been set up

proc IsAnEditProcessUsingSamples {gcnt} {
	global ins ins_ref ins_timetype evv

	set thisref [lindex $ins_ref $gcnt]
	set this_prog [lindex $thisref 0]
	set this_mode [lindex $thisref 1]

	incr this_mode -1
	switch -regexp -- $this_prog \
		^$evv(EDIT_CUT)$		- \
		^$evv(EDIT_CUTEND)$		- \
		^$evv(EDIT_ZCUT)$		- \
		^$evv(EDIT_EXCISE)$		- \
		^$evv(EDIT_EXCISEMANY)$	- \
		^$evv(EDIT_INSERT)$		- \
		^$evv(EDIT_INSERTSIL)$ {
			switch -regexp -- $this_mode \
				^$evv(EDIT_SAMPS)$ {
					set ins_timetype($gcnt) $evv(EDIT_SAMPS)
					return 1
				} \
				^$evv(EDIT_STSAMPS)$ {
					set ins_timetype($gcnt) $evv(EDIT_STSAMPS)
					return 1
				}
		}
	return 0
}		

#------ Alter timetype of gadget, for a ins run

proc SetTimeType {tt fnam args} {
	global pa evv

	set s_rate [expr double($pa($fnam,$evv(SRATE)))]
	set c_hans [expr round($pa($fnam,$evv(CHANS)))]
	switch -- $tt {
		1 {set multiplier [expr $s_rate * $c_hans]}
		2 {set multiplier $s_rate}
	}
	foreach item $args {
		set item [expr $item * $multiplier]
		if [catch {set item [expr round($item)]} in] {
			#INTEGER TOO LARGE
			set item $evv(MAXINT)
		}
		if {($tt == 1) && ($c_hans > 1)} {
			set item [expr [expr round($item  / $c_hans)] * $c_hans]
		}
		lappend outargs $item
	}
	return $outargs
}

#------ Revert to standard timetpye, if gadget range is unknowable

proc UnsetTimeType {tt fnam val} {
	global pa evv

	set s_rate [expr double($pa($fnam,$evv(SRATE)))]
	set c_hans [expr round($pa($fnam,$evv(CHANS)))]
	switch -- $tt {
		1 {set divider [expr $s_rate * $c_hans]}
		2 {set divider $s_rate}
	}
	set val [expr $val / $divider]

	FINDOUT WHICH PARAMETER TIMETYPE IS
	SUBSTITUTE IN CMDLINE

	return $val
}

#------ TIMETYPE GADGET 
#
# Modifies units understood in time-value-input, and modifies active range (for slider)
#	  0		 1	   2	  3		   4	5	  6			7				8			   9	|	11
#	----------------------------------------------------------------------------------------|-------
#  |			   No: PARAMNAME						/\secs		/\samps	   /\stereosamps|  ---  |
#  |													\/	  		\/		   \/			| |var| |
#  |																						|  ---  | 
#	----------------------------------------------------------------------------------------|-------
# 														CHOICE-OF-ENTRY-UNITS..............
#
#

proc TimetypeGadget {name dflt gcnt pcnt} {
	global chlist prm pa actvhi actvlo dfault evv
	global ins prmgrd secshi sampshi stsampshi resetfaderanges_firsttime
	global sratehere chanshere isint dbl_rng ins timetype
	global secslo sampslo stsampslo secshi sampshi stsampshi

	set resetfaderanges_firsttime 1
 	set dbl_rng($pcnt) 0

	set isint($pcnt) 1
	set thisrow $gcnt
	incr thisrow $gcnt
	if {$ins(create)} {
		set thischosenlist "$ins(chlist)"
	} else {
		set thischosenlist "$chlist"
	}
	#	NO. AND NAME
	DisplayParamName $name $gcnt $pcnt $pcnt $thisrow
	incr thisrow
	set fnam [lindex $thischosenlist 0]
	#	ESTABLISH RANGE VARIABLES

	set secslo($pcnt)    0
	set sampslo($pcnt)   0
	set stsampslo($pcnt) 0

 	set timetype [expr round($dflt)]

	set dfault($pcnt) $timetype
	set prm($pcnt) $timetype

	set sratehere($pcnt) $pa($fnam,$evv(SRATE))
	set chanshere($pcnt) $pa($fnam,$evv(CHANS))
	set secshi($pcnt)  $pa($fnam,$evv(DUR))
	set sampshi($pcnt) $pa($fnam,$evv(INSAMS))
	set stsampshi($pcnt) [expr $sampshi($pcnt) / $chanshere($pcnt)]
	set rr [frame $prmgrd.tt$gcnt]
	radiobutton $rr.0 -variable prm($pcnt) -text "seconds"     -value 0 \
		-command "ResetFadeRanges $secslo($pcnt) $secshi($pcnt) $sratehere($pcnt) $chanshere($pcnt) secs 0"
	radiobutton $rr.1 -variable prm($pcnt) -text "samples"     -value 1 \
		-command "ResetFadeRanges $sampslo($pcnt) $sampshi($pcnt) $sratehere($pcnt) $chanshere($pcnt) samps 1"
	radiobutton $rr.2 -variable prm($pcnt) -text "samplegroups" -value 2 \
		-command "ResetFadeRanges $stsampslo($pcnt) $stsampshi($pcnt) $sratehere($pcnt) $chanshere($pcnt) stsmps 2"
	grid $prmgrd.tt$gcnt -row $thisrow -column $evv(LORANGE) -columnspan 8
	pack $rr.0 $rr.1 $rr.2 -side left
}

#------ SRATE GADGET 
#
#						Offers a choice of valid srates
#	  0	    1	   2	  3		4	   5	  6			7		8	   9					|	11
#	----------------------------------------------------------------------------------------|-------
#  |			No: PARAMNAME	/\16000/\22050/\24000/\32000/\44100/\48000					|  ---  |
#  |						 	\/	   \/	  \/	 \/		\/	   \/						| |var| |
#  |																						|  ---  |
#	----------------------------------------------------------------------------------------|-------
# 								CHOICE-OF-VALID-SAMPLE-RATES..............
#

proc SrateGadget {name dflt gcnt pcnt} {
	global prm dfault prmgrd isint dbl_rng ins is_dflt_sr_gadget sl_real evv

 	set dbl_rng($pcnt) 0
	set thisrow $gcnt
	incr thisrow $gcnt
	#	NO. AND NAME
	DisplayParamName $name $gcnt $pcnt $pcnt $thisrow
	incr thisrow
	set isint($pcnt) 1
	set rr [frame $prmgrd.srate$gcnt]

	if {$evv(DFLT_SR) > 0} {
		set	prm($pcnt) $evv(DFLT_SR)
		if {!$sl_real} {
			label $rr.0 -text "USING DEFAULT SAMPLING RATE ..... $evv(DFLT_SR) .... FOR THIS DEMONSTRATION"
		} else {
			label $rr.0 -text "USING DEFAULT SAMPLING RATE ..... $evv(DFLT_SR)"
		}
		pack $rr.0 -side left
		$prmgrd.no$gcnt.res config -state disabled
		$prmgrd.no$gcnt.hms config -state disabled
		$prmgrd.no$gcnt.pen config -state disabled
		$prmgrd.no$gcnt.def config -state disabled
		if {$ins(run)} {
			$prmgrd.no$gcnt.ori config -state disabled
		}
		set is_dflt_sr_gadget $gcnt
	} else {
		if {$ins(run)} {
			set prm($pcnt) [expr int($dfault($pcnt))]
		} else {
			set prm($pcnt) [expr int($dflt)]
		 	set dfault($pcnt) $dflt
		}
		radiobutton $rr.0 -variable prm($pcnt) -text "16000" -value 16000
		radiobutton $rr.1 -variable prm($pcnt) -text "22050" -value 22050
		radiobutton $rr.2 -variable prm($pcnt) -text "24000" -value 24000
		radiobutton $rr.3 -variable prm($pcnt) -text "32000" -value 32000
		radiobutton $rr.4 -variable prm($pcnt) -text "44100" -value 44100
		radiobutton $rr.5 -variable prm($pcnt) -text "48000" -value 48000
		radiobutton $rr.6 -variable prm($pcnt) -text "88200" -value 88200
		radiobutton $rr.7 -variable prm($pcnt) -text "96000" -value 96000
		pack $rr.0 $rr.1 $rr.2 $rr.3 $rr.4 $rr.5 $rr.6 $rr.7 -side left
	}
	grid $prmgrd.srate$gcnt -row $thisrow -column $evv(LORANGE) -columnspan 10 -sticky w
}

#------ MIDI GADGET 
#
#						Offers a choice of notes
#	  0	    1	   2	  3		4	   5	  6			7		8	   9					|	11
#	----------------------------------------------------------------------------------------|-------
#  |			No: PARAMNAME	/\C/\C#/\D/\Eb/\E/\F/\F#/\G/\Ab/\A/\Bb/\B					|  ---  |
#  |						 	\/ \/  \/ \/  \/ \/ \/  \/ \/  \/ \/  \/					| |var| |
#  |																						|  ---  |
#	----------------------------------------------------------------------------------------|-------
# 								CHOICE-OF-TEMPERED-PITCHES..............
#

proc MidiGadget {name dflt gcnt pcnt} {
	global prm dfault prmgrd isint dbl_rng ins is_dflt_sr_gadget sl_real evv

 	set dbl_rng($pcnt) 0
	set thisrow $gcnt
	incr thisrow $gcnt
	#	NO. AND NAME
	DisplayParamName $name $gcnt $pcnt $pcnt $thisrow
	incr thisrow
	set isint($pcnt) 1
	set rr [frame $prmgrd.srate$gcnt]

	if {$ins(run)} {
		set prm($pcnt) [expr int($dfault($pcnt))]
	} else {
		set prm($pcnt) [expr int($dflt)]
	 	set dfault($pcnt) $dflt
	}
	radiobutton $rr.0 -variable prm($pcnt) -text "C" -value 0
	radiobutton $rr.1 -variable prm($pcnt) -text "C#" -value 1
	radiobutton $rr.2 -variable prm($pcnt) -text "D" -value 2
	radiobutton $rr.3 -variable prm($pcnt) -text "Eb" -value 3
	radiobutton $rr.4 -variable prm($pcnt) -text "E" -value 4
	radiobutton $rr.5 -variable prm($pcnt) -text "F" -value 5
	radiobutton $rr.6 -variable prm($pcnt) -text "F#" -value 6
	radiobutton $rr.7 -variable prm($pcnt) -text "G" -value 7
	radiobutton $rr.8 -variable prm($pcnt) -text "Ab" -value 8
	radiobutton $rr.9 -variable prm($pcnt) -text "A" -value 9
	radiobutton $rr.10 -variable prm($pcnt) -text "Bb" -value 10
	radiobutton $rr.11 -variable prm($pcnt) -text "B" -value 11
	pack $rr.0 $rr.1 $rr.2 $rr.3 $rr.4 $rr.5 $rr.6 $rr.7 $rr.8 $rr.9 $rr.10 $rr.11 -side left
	grid $prmgrd.srate$gcnt -row $thisrow -column $evv(LORANGE) -columnspan 10 -sticky w
}

#------ OCT GADGET 
#
#						Offers a choice of octave range
#	  0	    1	   2	  3		4	   5	  6			7		8	   9					|	11
#	----------------------------------------------------------------------------------------|-------
#  |			No: PARAMNAME	/\-4/\-3/\-2/\-1/\0/\1/\2/\3/\4								|  ---  |
#  |						 	\/  \/  \/  \/  \/ \/ \/ \/ \/ 								| |var| |
#  |																						|  ---  |
#	----------------------------------------------------------------------------------------|-------
# 								CHOICE-OF-OCTAVE-RANGE..............
#

proc OctGadget {name dflt gcnt pcnt} {
	global prm dfault prmgrd isint dbl_rng ins is_dflt_sr_gadget sl_real evv

 	set dbl_rng($pcnt) 0
	set thisrow $gcnt
	incr thisrow $gcnt
	#	NO. AND NAME
	DisplayParamName $name $gcnt $pcnt $pcnt $thisrow
	incr thisrow
	set isint($pcnt) 1
	set rr [frame $prmgrd.srate$gcnt]

	if {$ins(run)} {
		set prm($pcnt) [expr int($dfault($pcnt))]
	} else {
		set prm($pcnt) [expr int($dflt)]
	 	set dfault($pcnt) $dflt
	}
	radiobutton $rr.0 -variable prm($pcnt) -text "-4" -value -4
	radiobutton $rr.1 -variable prm($pcnt) -text "-3" -value -3
	radiobutton $rr.2 -variable prm($pcnt) -text "-2" -value -2
	radiobutton $rr.3 -variable prm($pcnt) -text "-1" -value -1
	radiobutton $rr.4 -variable prm($pcnt) -text "0" -value 0
	radiobutton $rr.5 -variable prm($pcnt) -text "1" -value 1
	radiobutton $rr.6 -variable prm($pcnt) -text "2" -value 2
	radiobutton $rr.7 -variable prm($pcnt) -text "3" -value 3
	radiobutton $rr.8 -variable prm($pcnt) -text "4" -value 4
	pack $rr.0 $rr.1 $rr.2 $rr.3 $rr.4 $rr.5 $rr.6 $rr.7 $rr.8 -side left
	grid $prmgrd.srate$gcnt -row $thisrow -column $evv(LORANGE) -columnspan 10 -sticky w
}

#------ CHORD GADGET 
#
#						Offers a choice of chord sorting
#	  0	    1	   2	  3		4	   5	  6			7		8	   9					|	11
#	----------------------------------------------------------------------------------------|-------
#  |			No: PARAMNAME	/\  /\  /\  /\  /\  /\  /\  /\  /\ 							|  ---  |
#  |						 	\/  \/  \/  \/  \/  \/  \/  \/  \/ 							| |var| |
#  |																						|  ---  |
#	----------------------------------------------------------------------------------------|-------
#

proc ChordGadget {name dflt gcnt pcnt} {
	global prm dfault prmgrd isint dbl_rng ins is_dflt_sr_gadget sl_real evv

 	set dbl_rng($pcnt) 0
	set thisrow $gcnt
	incr thisrow $gcnt
	#	NO. AND NAME
	DisplayParamName $name $gcnt $pcnt $pcnt $thisrow
	incr thisrow
	set isint($pcnt) 1
	set rr [frame $prmgrd.srate$gcnt]

	if {$ins(run)} {
		set prm($pcnt) [expr int($dfault($pcnt))]
	} else {
		set prm($pcnt) [expr int($dflt)]
	 	set dfault($pcnt) $dflt
	}
	radiobutton $rr.0 -variable prm($pcnt) -text "ROOT" -width 4 -value 0
	radiobutton $rr.1 -variable prm($pcnt) -text "TOPNOTE" -width 6 -value 1
	radiobutton $rr.2 -variable prm($pcnt) -text "PITCHCLASS SET" -width 13 -value 2
	radiobutton $rr.3 -variable prm($pcnt) -text "CHORD TYPE"  -width 9 -value 3
	radiobutton $rr.4 -variable prm($pcnt) -text "CHORD TYPE (1 of each)" -width 18 -value 4
	pack $rr.0 $rr.1 $rr.2 $rr.3 $rr.4 -side left
	grid $prmgrd.srate$gcnt -row $thisrow -column $evv(LORANGE) -columnspan 10 -sticky w
}

#------ TWOFAC GADGET 
#
#						Offers a choice of powers of 2
#	  0	    1	   2	  3		4	   5	  6		 7		8		9						|	11
#	----------------------------------------------------------------------------------------|-------
#  |			No: PARAMNAME	/\1    /\2    /\4    /\8    /\16   /\32						|  ---  |
#  |							\/     \/	  \/	 \/	    \/	   \/	   					| |var| |
#  |																						|  ---  |
#	----------------------------------------------------------------------------------------|-------
# 								CHOICE-OF-POWERS_OF_2................
#
#

proc TwofacGadget {name dflt gcnt pcnt} {
	global prm dfault prmgrd isint dbl_rng ins evv

	set isint($pcnt) 1
 	set dbl_rng($pcnt) 0
	set thisrow $gcnt
	incr thisrow $gcnt
	#	NO. AND NAME
	DisplayParamName $name $gcnt $pcnt $pcnt $thisrow
	incr thisrow
	if {$ins(run)} {
		set prm($pcnt) [expr int($dfault($pcnt))]
	} else {
		set prm($pcnt) [expr int($dflt)]
	 	set dfault($pcnt) $dflt
	}
	set rr [frame $prmgrd.twofac$gcnt]
	radiobutton $rr.0 -variable prm($pcnt) -text "1" -value 1
	radiobutton $rr.1 -variable prm($pcnt) -text "2" -value 2
	radiobutton $rr.2 -variable prm($pcnt) -text "4" -value 4
	radiobutton $rr.3 -variable prm($pcnt) -text "8" -value 8
	radiobutton $rr.4 -variable prm($pcnt) -text "16" -value 16
	radiobutton $rr.5 -variable prm($pcnt) -text "32" -value 32
	grid $prmgrd.twofac$gcnt -row $thisrow -column $evv(LORANGE) -columnspan 10
	pack $rr.0 $rr.1 $rr.2 $rr.3 $rr.4 $rr.5 -side left
}

#------ WAVETYPE GADGET 
#
#						 Offers a choice of wavetypes
#	  0	    1	   2	  3		4	   5	  6			7				8			   9	|	11
#	----------------------------------------------------------------------------------------|-------
#  |			No: PARAMNAME	/\sin  /\saw  /\upramp/\dnramp								|  ---  |
#  |							\/	   \/	  \/	  \/		   							| |var| |
#  |																						|  ---  |
#	----------------------------------------------------------------------------------------|-------
# 	CHOICE-OF-WAVEFORMS............
#
#

proc WavetypeGadget {name dflt gcnt pcnt} {
	global prm dfault prmgrd isint dbl_rng ins evv

	set isint($pcnt) 1
 	set dbl_rng($pcnt) 0
	set thisrow $gcnt
	incr thisrow $gcnt
	#	NO. AND NAME
	DisplayParamName $name $gcnt $pcnt $pcnt $thisrow
	incr thisrow

	if {$ins(run)} {
		set prm($pcnt) [expr int($dfault($pcnt))]
	} else {
		set prm($pcnt) [expr int($dflt)]
	 	set dfault($pcnt) $dflt
	}
	set rr [frame $prmgrd.wave$gcnt]
	radiobutton $rr.0 -variable prm($pcnt) -text "sin" -value 2
	radiobutton $rr.1 -variable prm($pcnt) -text "saw" -value 3
	radiobutton $rr.2 -variable prm($pcnt) -text "upramp" -value 4
	radiobutton $rr.3 -variable prm($pcnt) -text "dnramp" -value 1
	grid $prmgrd.wave$gcnt -row $thisrow -column $evv(LORANGE) -columnspan 10
	pack $rr.0 $rr.1 $rr.2 $rr.3 -side left
}

#------ STRING GADGET
#
#		for entering special string-codes, or filenames, or generic-filenames
#	  0		 1	   2	  3		   4	5	  6			7				8			   9	|	11
#	----------------------------------------------------------------------------------------|-------
#  | 						    					____________					 		|  ---  |
#  |			  No: PARAMNAME 				   |val entry...| 							| |var| |
#  |						    				   |____________|	 						|  ---  |
#  | 						     													 		|       |
#	----------------------------------------------------------------------------------------|-------
#					  NAME							TEXT-ENTRY
#				    & NUMBER						(OF FILENAME)
#					OF PARAM
#

proc StringGadget {name gcnt pcnt} {
	global prm evv dfault prmgrd dbl_rng ins isint

	set isint($pcnt) 0
 	set dbl_rng($pcnt) 0
	set thisrow $gcnt
	incr thisrow $gcnt
	# 	NO. AND NAME
	DisplayParamName $name $gcnt $pcnt $pcnt $thisrow
	incr thisrow
	# 	ENTRY BOX
	entry $prmgrd.e$gcnt -textvariable prm($pcnt) -width 14
	grid  $prmgrd.e$gcnt -row $thisrow -column $evv(VAL_ENTRY)
	bind  $prmgrd.e$gcnt <Tab> "ThisParamOK $gcnt $pcnt $prmgrd.e$gcnt"
	bind  $prmgrd.e$gcnt <Command-ButtonRelease-1> "ShowFileParam $prmgrd.e$gcnt $pcnt $gcnt 0 0"
	bind  $prmgrd.e$gcnt <Control-Command-ButtonRelease-1> "ShowFileParam $prmgrd.e$gcnt $pcnt $gcnt 0 1"

	# NORMAL CASE: START WITH EMPTY VALUE-BOX

	if {$ins(run)} {
		set prm($pcnt) $dfault($pcnt)
	} else {
		set dfault($pcnt) ""
		set prm($pcnt) ""
	}
	set spacc [label $prmgrd.spcc$gcnt -text "" -width 1]
	grid $spacc -row $thisrow -column $evv(PARAM_SPACE)

	InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
}

#------ CHECK-BUTTON GADGET
#
#	  0	    1	   2	  3		4	   5	  6			7				8			   9	|	11
#	----------------------------------------------------------------------------------------|-------
#  |			 No: PARAMNAME	/\															|  ---  |
#  |							\/															| |var| |
#  |																						|  ---  |
#	----------------------------------------------------------------------------------------|-------
# 	
#
#

proc CheckButtonGadget {name gcnt pcnt} {
	global prm dfault prmgrd isint dbl_rng ins evv

	set isint($pcnt) 1
 	set dbl_rng($pcnt) 0
	set thisrow $gcnt
	incr thisrow $gcnt
	#	NO. AND NAME
	DisplayParamName $name $gcnt $pcnt $pcnt $thisrow
	incr thisrow
	checkbutton $prmgrd.chb$gcnt -variable prm($pcnt) -text ""
	grid $prmgrd.chb$gcnt -row $thisrow -column $evv(RANGE_SWITCH)
 
	if {$ins(run)} {
		set prm($pcnt) $dfault($pcnt)
	} else {
		if [string match SLOPE* $name] {
			set prm($pcnt) 1				;#	Envelopes are defaulted to exponential
		 	set dfault($pcnt) 1
		} else {
			set prm($pcnt) 0				;#	All other flags are defaulted to OFF
		 	set dfault($pcnt) 0
		}
	}
	set spacc [label $prmgrd.spcc$gcnt -text "" -width 1]
	grid $spacc -row $thisrow -column $evv(PARAM_SPACE)
}

#------ SWITCHED GADGET
#
#	  0		 1	   2	  3		   4	5	  6			7				8			   9		10  |  11
#	------------------------------------------------------------------------------------------------|-------
#  | 							 ----    	 ----	____________								  	|  ---  |
#  |/\ SWITCHNAME/\ SWITCHNAME	| lo |      | hi | |val entry...| ======||========					| |var| |
#  |\/		     \/		        |	 | 		| 	 | |____________|	 (slider bar)					|  ---  |
#  | 							 ---- 		 ----												  	|       |
#	------------------------------------------------------------------------------------------------|-------
#	SWITCHED-PARAM	  			RANGE-INFORMATION  VALUE-ENTRY....................	
#	   SWITCHES													   
#
#	1st parameter returned is the SWITCHING-PARAMETER (variable 'paramswitch')
#	pcnt becomes the standard PARAMETER
#
#	N.B. At present SWITCHED gadget has no infile possibilities. IF these did happen in future
#	functions to get/make files need to be modified, to accept both pcnt & gdg_type,
#	because the file made is for ($pcnt+1) in these cases : AND TESTING ROUTINES (various)!!
#

proc SwitchedGadget {name name2 name3 datatype low high dflt low2 high2 dflt2 gcnt pcnt} {
	global prm prange evv actvhi actvlo dfault prmgrd scl isint evv
	global canhavefiles dfault1 dfault2	dbl_rng ins ins_switch_dflt
	global lo hi sublo subhi

	set thisrow $gcnt
	incr thisrow $gcnt
 	set dbl_rng($pcnt) 0

	set paramswitch $pcnt
	if {$ins(run)} {
		set prm($paramswitch) $dfault($paramswitch)	
	}
	set isint($paramswitch) 1
	incr pcnt										;#	Move on the 'real' parameter

	if {$ins(run)} {
		set ins_switch_dflt($pcnt) $dfault($pcnt)
	}
 	set dbl_rng($pcnt) 0

	set lo($pcnt) $low
	set hi($pcnt) $high
	set sublo($pcnt) $low2
	set subhi($pcnt) $high2

	set dfault1($pcnt) $dflt
	set dfault2($pcnt) $dflt2

	set isint($pcnt) 0
	set canhavefiles($pcnt) 0
	if {$datatype == "i" || $datatype == "I"} {
		set isint($pcnt) 1
	}
	if {$datatype == "I" || $datatype == "D"} {
		set canhavefiles($pcnt) 1
	}
	DisplayParamName $name $gcnt $paramswitch $pcnt $thisrow
	incr thisrow

	#	SWITCH DEVICE
	set newname2 "[split $name2 "_"]"
	set newname3 "[split $name3 "_"]"
	
	radiobutton $prmgrd.rba$gcnt -variable prm($paramswitch) -text $newname2 -value 1 \
		-command "ToggleGadget $gcnt $paramswitch $pcnt $low $high $dflt $low2 $high2 $dflt2"
	radiobutton $prmgrd.rbb$gcnt -variable prm($paramswitch) -text $newname3 -value 0 \
		-command "ToggleGadget $gcnt $paramswitch $pcnt $low $high $dflt $low2 $high2 $dflt2"
	grid $prmgrd.rba$gcnt -row $thisrow -column $evv(SWITCHED_SWITCHA)
	grid $prmgrd.rbb$gcnt -row $thisrow -column $evv(SWITCHED_SWITCHB)
	#	INITIAL SET UP OF RANGE

	set actvlo($pcnt) $low
 	set actvhi($pcnt) $high
	set prange($pcnt) [expr $actvhi($pcnt) - $actvlo($pcnt)]
	SetPrtype $pcnt

	if {$isint($pcnt)} {
		set lotxt [expr round($actvlo($pcnt))]
		set hitxt [expr round($actvhi($pcnt))]
	} else {
		set lotxt [FiveSigFig $actvlo($pcnt)]
		set hitxt [FiveSigFig $actvhi($pcnt)]
	}
	set lowidth [string length $lotxt]
	if {$lowidth < $evv(RANGEWIDTH)} {
		set lowidth $evv(RANGEWIDTH)
	}
	set hiwidth [string length $hitxt]
	if {$hiwidth < $evv(RANGEWIDTH)} {
		set hiwidth $evv(RANGEWIDTH)
	}
	label $prmgrd.rlo$gcnt -justify center -text $lotxt -width $lowidth
	label $prmgrd.rb$gcnt -justify center -text "Range"
	label $prmgrd.rhi$gcnt -justify center -text $hitxt -width $hiwidth

	# RANGE LIMITS
 	grid $prmgrd.rlo$gcnt -row $thisrow -column $evv(LORANGE) -sticky e
	grid $prmgrd.rb$gcnt  -row $thisrow -column $evv(RANGE_SWITCH)
	grid $prmgrd.rhi$gcnt -row $thisrow -column $evv(HIRANGE) -sticky w

	#	ENTRY BOX
	entry $prmgrd.e$gcnt -textvariable prm($pcnt) -width 14
	grid  $prmgrd.e$gcnt -row $thisrow -column $evv(VAL_ENTRY)
	bind  $prmgrd.e$gcnt <Tab> "ThisParamOK $gcnt $pcnt $prmgrd.e$gcnt"

	set spacc [label $prmgrd.spcc$gcnt -text "" -width 1]
	grid $spacc -row $thisrow -column $evv(PARAM_SPACE)

	#	SLIDER BAR
	set scl($pcnt) [MakeScale $gcnt $pcnt linear]
	grid $scl($pcnt) -row $thisrow -column $evv(SLIDER_BAR)

	set spacc2 [label $prmgrd.spcc2a$gcnt -text "" -width 1]
	grid $spacc2 -row $thisrow -column $evv(PARAM_SPACE2)

	if {$ins(run)} {
		if {$prm($paramswitch) != 1} {
			ToggleGadget $gcnt $prm($paramswitch) $pcnt $low $high $dflt $low2 $high2 $dflt2
		}
	} else { 
		set prm($paramswitch) 1
		set dfault($paramswitch) 1
	}

	if {$ins(run)} {
		set prm($pcnt) $dfault($pcnt)
	} else {
		set prm($pcnt) $dflt2
	 	set dfault($pcnt) $dflt2
	}
	InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
	SetScale $pcnt linear
}

#------ Toggle between 2 different ranges

proc ToggleGadget {gcnt paramswitch pcnt low high dflt low2 high2 dflt2} {
	global prm prmgrd prange actvhi actvlo dfault isint ins ins_switch_dflt evv


	switch -- $prm($paramswitch) {
		0 {
		 	set actvlo($pcnt) $low2	  				;#	Reset scaling values for slider
 			set actvhi($pcnt) $high2
			if {$ins(run)} {
				if {$dfault($paramswitch) == $prm($paramswitch)} {
					set dfault($pcnt) $ins_switch_dflt($pcnt)		
					set prm($pcnt)  $ins_switch_dflt($pcnt)
				} else {
				 	set dfault($pcnt) $dflt2
					set prm($pcnt)  $dflt2
				}
			} else {
			 	set dfault($pcnt) $dflt2					;#	Reset default value to other default
				set prm($pcnt)  $dflt2					;#	Reset displayed value to that default, if ness
			}
			InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
		}
		1 {				
		 	set actvlo($pcnt) $low
 			set actvhi($pcnt) $high
			if {$ins(run)} {
				if {$dfault($paramswitch) == $prm($paramswitch)} {
					set dfault($pcnt) $ins_switch_dflt($pcnt)		
					set prm($pcnt)  $ins_switch_dflt($pcnt)
				} else {
				 	set dfault($pcnt) $dflt
					set prm($pcnt)  $dflt
				}
			}  else {
			 	set dfault($pcnt) $dflt
				set prm($pcnt)  $dflt					;#	Reset displayed value to that default, if ness
			}
			InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
		}
	}
	set prange($pcnt) [expr $actvhi($pcnt) - $actvlo($pcnt)] 
	SetPrtype $pcnt
	if {$isint($pcnt)} {
		set lotxt [expr round($actvlo($pcnt))]
		set hitxt [expr round($actvhi($pcnt))]
	} else {
		set lotxt [FiveSigFig $actvlo($pcnt)]
		set hitxt [FiveSigFig $actvhi($pcnt)]
	}
	set lowidth [string length $lotxt]
	if {$lowidth < $evv(RANGEWIDTH)} {
		set lowidth $evv(RANGEWIDTH)
	}
	set hiwidth [string length $hitxt]
	if {$hiwidth < $evv(RANGEWIDTH)} {
		set hiwidth $evv(RANGEWIDTH)
	}
	$prmgrd.rlo$gcnt config -text $lotxt -width $lowidth				;#	Reset range displays
	$prmgrd.rhi$gcnt config -text $hitxt -width $hiwidth
	SetScale $pcnt linear
}

#############################################
# FUNCTIONS USED IN CONSTRUCTING GADGETS	#
#############################################

#------ Put parameter name and number on grid

proc DisplayParamName {name gcnt pcnt p_no thisrow} {
	global evv gno prmgrd parname ins ins_variable_store dodo_a var_could_exist

	set f [frame $prmgrd.no$gcnt]
	set parname($gcnt) $name
	set dodo_a 0
	grid  $prmgrd.no$gcnt -row $thisrow -column 0 -columnspan 12 -sticky ew
	#PARAM NUMBER:
	label $f.no -text $gno -width 3
	#PARAMNAME:
	set name [string trim $name]
	set name [split $name "_"]
	incr p_no
	set nname "\["
	append nname $p_no "\]:"
	set name [concat $nname $name]
	label $f.name -text "$name"
	label $f.name2 -text "$name"
	radiobutton $f.res -command "ResetPreviousRunParams $gcnt $pcnt" \
		-selectcolor $evv(PBAR_DONECOLOR) \
		-activebackground [option get . background {}] -variable dodo_a -val 0
	radiobutton $f.hms -command "ConvertToSecs $pcnt $gcnt" \
		-selectcolor $evv(PBAR_DONECOLOR) \
		-activebackground [option get . background {}] -variable dodo_a -val 0
	if {![NumericTypeGadget $gcnt]} {
		$f.hms config -state disabled
	}
	radiobutton $f.pen -command "ResetPenultimateRunParams $gcnt $pcnt" \
		-selectcolor $evv(PBAR_DONECOLOR) \
		-activebackground [option get . background {}] -variable dodo_a -val 0
	radiobutton $f.def -command "ResetValues dfault $gcnt $pcnt" \
		-selectcolor $evv(PBAR_DONECOLOR) \
		-activebackground [option get . background {}] -variable dodo_a -val 0
	
	if {$ins(run)} {
		radiobutton $f.ori -command "ResetValues ins_subdflt $gcnt $pcnt" \
			-selectcolor $evv(PBAR_DONECOLOR) \
			-activebackground [option get . background {}] -variable dodo_a -val 0
	}
	#SPACER LINE
	frame $f.spc -bg [option get . foreground {}] -height 1
	pack $f.res $f.hms $f.name -side left
	pack $f.spc -side left -anchor e -fill x -expand true
	if {$ins(run)} {
		pack $f.ori $f.def $f.pen $f.name2 -side right
	} else {
		pack $f.def $f.pen $f.name2 -side right
	}
	# INSTRUMENT VARIABLE
	incr thisrow
	if {$ins(create)} {
		set var_could_exist 1
		if {$ins(possible_param)} {
			checkbutton $prmgrd.var$gcnt -variable ins_variable_store($gcnt) -text "variable" -width 10 -command "PvocWarn $gcnt"
			grid $prmgrd.var$gcnt -row $thisrow -column $evv(INS_VARIABLE)
		}
	} else {
		set var_could_exist 0
	}
	set ins_variable_store($gcnt) 0
}

#------ Display file get and make buttons, if necessary. Determine if prm is int or float.

proc Show_GetInfile_Display {datatype gcnt pcnt thisrow} {
	global prmgrd good_res evv
	switch -- $datatype {
		i -
		d {}
		I -
		D {
			set good_res 1
			button $prmgrd.fb$gcnt -text "Get File"  -width 8 -command "Dlg_GetTextfile $pcnt $gcnt brk" -highlightbackground [option get . background {}]
			button $prmgrd.mb$gcnt -text "Make File" -width 8 -command "Dlg_ChooseFiletype $pcnt $gcnt" -highlightbackground [option get . background {}]

			grid  $prmgrd.fb$gcnt -row $thisrow -column $evv(GET_FILE) -sticky w
			grid  $prmgrd.mb$gcnt -row $thisrow -column $evv(MAKE_FILE) -sticky w
		}
		default {
			ErrShow "Invalid datatype value: $datatype: Program error"
		}
	}
}

#------ Display file get and make buttons.

proc SetupTextInfileDisplay {gcnt pcnt thisrow} {
	global  prmgrd isbrktype evv
	button $prmgrd.fb$gcnt -text "Get  File" -width 8 -command "Dlg_GetTextfile $pcnt $gcnt special" -highlightbackground [option get . background {}]
	button $prmgrd.mb$gcnt -text "Make File" -width 8 -command "set isbrktype 0 ; Dlg_MakeTextfile_Param $pcnt $gcnt" -highlightbackground [option get . background {}]
	grid  $prmgrd.fb$gcnt -row $thisrow -column $evv(GET_FILE) -sticky w
	grid  $prmgrd.mb$gcnt -row $thisrow -column $evv(MAKE_FILE) -sticky w
}

#------ Set up the range determining parameters

proc EstablishRange {gcnt pcnt low high sublow subhigh thisrow dflt} {
	global lo hi sublo subhi actvlo actvhi isint rangetype prmgrd prange partype dfltrangetype evv

 	set lo($pcnt) $low
 	set hi($pcnt) $high
 	set sublo($pcnt) $sublow
 	set subhi($pcnt) $subhigh

 	set actvlo($pcnt) $sublow
 	set actvhi($pcnt) $subhigh
 	set rangetype($pcnt) $evv(MINRANGE_SET)
	set dfltrangetype($pcnt) $evv(MINRANGE_SET)
	set partype($pcnt) lin

	set prange($pcnt) [expr $actvhi($pcnt) - $actvlo($pcnt)]
	SetPrtype $pcnt
	if {$isint($pcnt)} {
		set lotxt [expr round($actvlo($pcnt))]
		set hitxt [expr round($actvhi($pcnt))]
	} else {
		set lotxt [FiveSigFig $actvlo($pcnt)]
		set hitxt [FiveSigFig $actvhi($pcnt)]
	}
	set lowidth [string length $lotxt]
	if {$lowidth < $evv(RANGEWIDTH)} {
		set lowidth $evv(RANGEWIDTH)
	}
	set hiwidth [string length $hitxt]
	if {$hiwidth < $evv(RANGEWIDTH)} {
		set hiwidth $evv(RANGEWIDTH)
	}
	label $prmgrd.rlo$gcnt -justify center -text $lotxt -width $lowidth
	button  $prmgrd.rb$gcnt -text "Range" -command "SwitchRange $pcnt $gcnt 1 1" -highlightbackground [option get . background {}]
	label $prmgrd.rhi$gcnt -justify center -text $hitxt -width $hiwidth
	# RANGE LIMITS & RANGE-CHANGE BUTTON
	grid $prmgrd.rlo$gcnt -row $thisrow -column $evv(LORANGE) -sticky e
	grid $prmgrd.rb$gcnt  -row $thisrow -column $evv(RANGE_SWITCH)
	grid $prmgrd.rhi$gcnt -row $thisrow -column $evv(HIRANGE) -sticky w

}

#------ Set up the range determining parameters for single-range case

proc EstablishSimpleRange {gcnt pcnt low high thisrow} {
	global lo hi sublo subhi actvlo actvhi isint prmgrd prange evv
	global ins ins_timetype

 	set lo($pcnt) $low
 	set hi($pcnt) $high
	
 	set actvlo($pcnt) $low
 	set actvhi($pcnt) $high

	set prange($pcnt) [expr $actvhi($pcnt) - $actvlo($pcnt)]
	SetPrtype $pcnt

	if {$isint($pcnt)} {
		set lotxt [expr round($actvlo($pcnt))]
		set hitxt [expr round($actvhi($pcnt))]
	} else {
		set lotxt [FiveSigFig $actvlo($pcnt)]
		set hitxt [FiveSigFig $actvhi($pcnt)]
	}
	set lowidth [string length $lotxt]
	if {$lowidth < $evv(RANGEWIDTH)} {
		set lowidth $evv(RANGEWIDTH)
	}
	set hiwidth [string length $hitxt]
	if {$hiwidth < $evv(RANGEWIDTH)} {
		set hiwidth $evv(RANGEWIDTH)
	}
	label $prmgrd.rlo$gcnt -justify center -text $lotxt -width $lowidth

	if {$ins(run)} {
		if {($ins_timetype($gcnt) > 0) || [IsAnEditProcessUsingSamples $gcnt]} {
			if {$ins_timetype($gcnt) == $evv(EDIT_STSAMPS)} {
				label $prmgrd.rr$gcnt -text "Range(SampGrps)"
			} elseif {$ins_timetype($gcnt) == $evv(EDIT_SAMPS)} {
				label $prmgrd.rr$gcnt -text "Range(Samples)"
			} else {
				label $prmgrd.rr$gcnt -text "Range"
			}
		} else {
			label $prmgrd.rr$gcnt -text "Range"
		}
	} else {
		label $prmgrd.rr$gcnt -text "Range"
	}
	label $prmgrd.rhi$gcnt -justify center -text $hitxt -width $hiwidth
	# RANGE LIMITS, BUT NO RANGE-CHANGE BUTTON
	grid $prmgrd.rlo$gcnt -row $thisrow -column $evv(LORANGE) -sticky e
	grid $prmgrd.rr$gcnt -row $thisrow -column $evv(RANGE_SWITCH)
	grid $prmgrd.rhi$gcnt -row $thisrow -column $evv(HIRANGE) -sticky w
}

#------ Set up the range determining parameters for parameter with unknown upper range limit

proc EstablishUnknownRange {name gcnt pcnt low high thisrow} {
	global lo hi sublo subhi actvlo actvhi isint prmgrd prange evv
	global ins ins_timetype

 	set lo($pcnt) $low
 	set hi($pcnt) $high
 	set actvlo($pcnt) $low
 	set actvhi($pcnt) $high

	set prange($pcnt) [expr $actvhi($pcnt) - $actvlo($pcnt)]
	SetPrtype $pcnt

	if {$isint($pcnt)} {
		set lotxt [expr round($actvlo($pcnt))]
		set hitxt [expr round($actvhi($pcnt))]
	} else {
		set lotxt [FiveSigFig $actvlo($pcnt)]
		set hitxt [FiveSigFig $actvhi($pcnt)]
	}
	set lowidth [string length $lotxt]
	if {$lowidth < $evv(RANGEWIDTH)} {
		set lowidth $evv(RANGEWIDTH)
	}
	set hiwidth [string length $hitxt]
	if {$hiwidth < $evv(RANGEWIDTH)} {
		set hiwidth $evv(RANGEWIDTH)
	}
	label $prmgrd.rlo$gcnt -justify center -text $lotxt -width $lowidth
	if {$ins_timetype($gcnt) == $evv(EDIT_STSAMPS)} {
		label $prmgrd.rr$gcnt -text "Range(SampGrps)"
	} elseif {$ins_timetype($gcnt) == $evv(EDIT_SAMPS)} {
		label $prmgrd.rr$gcnt -text "Range(Samples)"
	} else {
		label $prmgrd.rr$gcnt -text "Range"
	}
	label $prmgrd.rhi$gcnt -justify center -text $hitxt -width $hiwidth
	# RANGE LIMITS, BUT NO RANGE-CHANGE BUTTON
	grid $prmgrd.rlo$gcnt -row $thisrow -column $evv(LORANGE) -sticky e
	grid $prmgrd.rr$gcnt -row $thisrow -column $evv(RANGE_SWITCH)
	grid $prmgrd.rhi$gcnt -row $thisrow -column $evv(HIRANGE) -sticky w
}

#------ 2nd (display only) range

proc EstablishOtherRange {gcnt pcnt low high col thisrow} {
	global lo hi sublo subhi actvlo actvhi isint prmgrd prange evv

	set zoog $pcnt
	set kom 0
	incr pcnt 10000
	incr gcnt 10000
	set isint($pcnt) $isint($zoog) 

	#	These two lines may be redundant:
 	set lo($pcnt) $low
 	set hi($pcnt) $high
	#	These two lines may be even more redundant:
 	set sublo($pcnt) $low
 	set subhi($pcnt) $high
	
 	set actvlo($pcnt) $low
 	set actvhi($pcnt) $high

	set prange($pcnt) [expr $actvhi($pcnt) - $actvlo($pcnt)]
	SetPrtype $pcnt

	if {$isint($pcnt)} {
		set lotxt [expr round($actvlo($pcnt))]
		set hitxt [expr round($actvhi($pcnt))]
	} else {
		set lotxt [FiveSigFig $actvlo($pcnt)]
		set hitxt [FiveSigFig $actvhi($pcnt)]
		if {$actvlo($pcnt) <= $evv(FLTERR)} {
			set lotxt "\>0.0"
			set kom 1
		}			
	}
	set lowidth [string length $lotxt]
	if {$lowidth < $evv(RANGEWIDTH)} {
		set lowidth $evv(RANGEWIDTH)
	}
	set hiwidth [string length $hitxt]
	if {$hiwidth < $evv(RANGEWIDTH)} {
		set hiwidth $evv(RANGEWIDTH)
	}
	set zurb ""
	if {!$kom} {
		set q [expr $lowidth - [string length $lotxt]]
		if {$q > 0} {
			set i 0
			while {$i < $q} {
				append zurb "."
				incr i
			}
		}
	}
	if {[string length $zurb] > 0} {
		set lotxt [list $lotxt $zurb "Range2" $hitxt]
	} else {
		set lotxt [list $lotxt "Range2" $hitxt]
	}
	label $prmgrd.rlo$gcnt -justify center -text $lotxt
	grid $prmgrd.rlo$gcnt -row $thisrow -column $col -columnspan 3 -sticky w
}

#------ Set up the range determining parameters, for log-slider

proc EstablishLogRange {gcnt pcnt low high sublow subhigh thisrow dflt} {
	global lo hi sublo subhi actvlo actvhi isint rangetype evv
	global loglo loghi logsublo logsubhi dfltrangetype partype
	global activeloglo activeloghi prmgrd prange prtype
 	set lo($pcnt) $low
 	set hi($pcnt) $high
 	set sublo($pcnt) $sublow
 	set subhi($pcnt) $subhigh
	set loglo($pcnt) [expr log($lo($pcnt))]
	set loghi($pcnt) [expr log($hi($pcnt))]
 	set logsublo($pcnt) [expr log($sublo($pcnt))]
 	set logsubhi($pcnt) [expr log($subhi($pcnt))]

 	set actvlo($pcnt) $sublow
 	set actvhi($pcnt) $subhigh
 	set activeloglo($pcnt) $logsublo($pcnt)
 	set activeloghi($pcnt) $logsubhi($pcnt)
 	set rangetype($pcnt) $evv(MINRANGE_SET)
	set dfltrangetype($pcnt) $evv(MINRANGE_SET)
	set partype($pcnt) log

	set prange($pcnt) [expr $activeloghi($pcnt) - $activeloglo($pcnt)]
	set prtype($pcnt) 0

	if {$isint($pcnt)} {
		set lotxt [expr round($actvlo($pcnt))]
		set hitxt [expr round($actvhi($pcnt))]
	} else {
		set lotxt [FiveSigFig $actvlo($pcnt)]
		set hitxt [FiveSigFig $actvhi($pcnt)]
	}
	set lowidth [string length $lotxt]
	if {$lowidth < $evv(RANGEWIDTH)} {
		set lowidth $evv(RANGEWIDTH)
	}
	set hiwidth [string length $hitxt]
	if {$hiwidth < $evv(RANGEWIDTH)} {
		set hiwidth $evv(RANGEWIDTH)
	}
	label $prmgrd.rlo$gcnt -justify center -text $lotxt -width $lowidth
	button  $prmgrd.rb$gcnt -text "Range" -command "SwitchLogRange $pcnt $gcnt 1 1" -highlightbackground [option get . background {}]
	label $prmgrd.rhi$gcnt -justify center -text $hitxt -width $hiwidth
	# RANGE LIMITS & RANGE-CHANGE BUTTON
	grid $prmgrd.rlo$gcnt -row $thisrow -column $evv(LORANGE) -sticky e
	grid $prmgrd.rb$gcnt  -row $thisrow -column $evv(RANGE_SWITCH)
	grid $prmgrd.rhi$gcnt -row $thisrow -column $evv(HIRANGE) -sticky w
}

#------ Set up the range determining parameters, for log-slider

proc EstablishSimpleLogRange {gcnt pcnt low high thisrow} {
	global lo hi actvlo actvhi isint evv
	global loglo loghi logsublo logsubhi prtype
	global activeloglo activeloghi prmgrd prange
 	set lo($pcnt) $low
 	set hi($pcnt) $high
	set loglo($pcnt) [expr log($lo($pcnt))]
	set loghi($pcnt) [expr log($hi($pcnt))]
 	set actvlo($pcnt) $low
 	set actvhi($pcnt) $high
 	set activeloglo($pcnt) $loglo($pcnt)
 	set activeloghi($pcnt) $loghi($pcnt)
	set prange($pcnt) [expr $activeloghi($pcnt) - $activeloglo($pcnt)]
	set prtype($pcnt) 0

	if {$isint($pcnt)} {
		set lotxt [expr round($actvlo($pcnt))]
		set hitxt [expr round($actvhi($pcnt))]
	} else {
		set lotxt [FiveSigFig $actvlo($pcnt)]
		set hitxt [FiveSigFig $actvhi($pcnt)]
	}
	set lowidth [string length $lotxt]
	if {$lowidth < $evv(RANGEWIDTH)} {
		set lowidth $evv(RANGEWIDTH)
	}
	set hiwidth [string length $hitxt]
	if {$hiwidth < $evv(RANGEWIDTH)} {
		set hiwidth $evv(RANGEWIDTH)
	}
	label $prmgrd.rlo$gcnt -justify center -text $lotxt -width $lowidth
	label $prmgrd.rb$gcnt -text "Range" 
	label $prmgrd.rhi$gcnt -justify center -text $hitxt -width $hiwidth
	# RANGE LIMITS & RANGE-CHANGE BUTTON
	grid $prmgrd.rlo$gcnt -row $thisrow -column $evv(LORANGE) -sticky e
	grid $prmgrd.rb$gcnt  -row $thisrow -column $evv(RANGE_SWITCH)
	grid $prmgrd.rhi$gcnt -row $thisrow -column $evv(HIRANGE) -sticky w
}

#------ FUNCTIONS USED BY THE GADETS
#
#	Switch between limited & full range: change display too : if 'reset', reset val to default val
#

proc SwitchRange {pcnt gcnt resetdefault fromgui} {
	global rangetype evv actvhi actvlo lo hi sublo subhi isint prmgrd prange prm dfault evv
	global ins ins_subdflt range_changed

	switch -regexp -- $rangetype($pcnt) \
		^$evv(MINRANGE_SET)$ {
			set actvhi($pcnt) $hi($pcnt)			
			set actvlo($pcnt) $lo($pcnt)
 			set prange($pcnt) [expr $actvhi($pcnt) - $actvlo($pcnt)]
			SetPrtype $pcnt
			if {$isint($pcnt)} {
				set lotxt [expr round($actvlo($pcnt))]
				set hitxt [expr round($actvhi($pcnt))]
			} else {
				set lotxt [FiveSigFig $actvlo($pcnt)]
				set hitxt [FiveSigFig $actvhi($pcnt)]
			}
			set lowidth [string length $lotxt]
			if {$lowidth < $evv(RANGEWIDTH)} {
				set lowidth $evv(RANGEWIDTH)
			}
			set hiwidth [string length $hitxt]
			if {$hiwidth < $evv(RANGEWIDTH)} {
				set hiwidth $evv(RANGEWIDTH)
			}
			$prmgrd.rlo$gcnt config -text $lotxt -width $lowidth
			$prmgrd.rhi$gcnt config -text $hitxt -width $hiwidth
			set rangetype($pcnt) $evv(MAXRANGE_SET)

#JUNE 2000 add IsNumeric condition
			if {$resetdefault && [IsNumeric $prm($pcnt)]} {
				if {$prm($pcnt) < $actvlo($pcnt) || $prm($pcnt) > $actvhi($pcnt)} {
					set prm($pcnt) $dfault($pcnt)
					if {$ins(run) && ($prm($pcnt) < $actvlo($pcnt) || $prm($pcnt) > $actvhi($pcnt))} {
						set prm($pcnt) $ins_subdflt($pcnt)
					}
					InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
				}
			}
			ResetScale $pcnt linear
		}	\
		^$evv(MAXRANGE_SET)$ {
			set actvhi($pcnt) $subhi($pcnt)			
			set actvlo($pcnt) $sublo($pcnt)
 			set prange($pcnt) [expr $actvhi($pcnt) - $actvlo($pcnt)]
			SetPrtype $pcnt
			if {$isint($pcnt)} {
				set lotxt [expr round($actvlo($pcnt))]
				set hitxt [expr round($actvhi($pcnt))]
			} else {
				set lotxt [FiveSigFig $actvlo($pcnt)]
				set hitxt [FiveSigFig $actvhi($pcnt)]
			}
			set lowidth [string length $lotxt]
			if {$lowidth < $evv(RANGEWIDTH)} {
				set lowidth $evv(RANGEWIDTH)
			}
			set hiwidth [string length $hitxt]
			if {$hiwidth < $evv(RANGEWIDTH)} {
				set hiwidth $evv(RANGEWIDTH)
			}

			$prmgrd.rlo$gcnt config -text $lotxt -width $lowidth
			$prmgrd.rhi$gcnt config -text $hitxt -width $hiwidth
			set rangetype($pcnt) $evv(MINRANGE_SET)

#JUNE 2000 add IsNumeric condition
			if {$resetdefault && [IsNumeric $prm($pcnt)]} {
				if {$prm($pcnt) < $actvlo($pcnt) || $prm($pcnt) > $actvhi($pcnt)} {
					set prm($pcnt) $dfault($pcnt)
					if {$ins(run) && ($prm($pcnt) < $actvlo($pcnt) || $prm($pcnt) > $actvhi($pcnt))} {
						set prm($pcnt) $ins_subdflt($pcnt)
					}
					InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
				}
			}
			ResetScale $pcnt linear
		}
	
	if {$fromgui} {
		set range_changed($gcnt) 1
	}
}

#------ Switch between limited & full range: change display too: log case

proc SwitchLogRange {pcnt gcnt resetdefault fromgui} {
	global rangetype evv actvhi actvlo lo hi sublo subhi isint evv
	global loglo loghi logsublo logsubhi prm dfault prmgrd prange
	global activeloglo activeloghi prmgrd ins ins_subdflt range_changed

	switch -regexp -- $rangetype($pcnt) \
		^$evv(MINRANGE_SET)$ {
			set actvhi($pcnt) $hi($pcnt)			
			set actvlo($pcnt) $lo($pcnt)
			set activeloghi($pcnt) $loghi($pcnt)
			set activeloglo($pcnt) $loglo($pcnt)
 			set prange($pcnt) [expr $activeloghi($pcnt) - $activeloglo($pcnt)]
			if {$isint($pcnt)} {
				set lotxt [expr round($actvlo($pcnt))]
				set hitxt [expr round($actvhi($pcnt))]
			} else {
				set lotxt [FiveSigFig $actvlo($pcnt)]
				set hitxt [FiveSigFig $actvhi($pcnt)]
			}
			set lowidth [string length $lotxt]
			if {$lowidth < $evv(RANGEWIDTH)} {
				set lowidth $evv(RANGEWIDTH)
			}
			set hiwidth [string length $hitxt]
			if {$hiwidth < $evv(RANGEWIDTH)} {
				set hiwidth $evv(RANGEWIDTH)
			}
			$prmgrd.rlo$gcnt config -text $lotxt -width $lowidth
			$prmgrd.rhi$gcnt config -text $hitxt -width $hiwidth
			set rangetype($pcnt) $evv(MAXRANGE_SET)

#JUNE 2000 add IsNumeric condition
			if {$resetdefault && [IsNumeric $prm($pcnt)]} {
				if {$prm($pcnt) < $actvlo($pcnt) || $prm($pcnt) > $actvhi($pcnt)} {
					set prm($pcnt) $dfault($pcnt)
					if {$ins(run) && ($prm($pcnt) < $actvlo($pcnt) || $prm($pcnt) > $actvhi($pcnt))} {
						set prm($pcnt) $ins_subdflt($pcnt)
					}
					InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
				}
			}
			ResetScale $pcnt log

		}		\
		^$evv(MAXRANGE_SET)$ {
			set actvhi($pcnt) $subhi($pcnt)			
			set actvlo($pcnt) $sublo($pcnt)
			set activeloghi($pcnt) $logsubhi($pcnt)			
			set activeloglo($pcnt) $logsublo($pcnt)
 			set prange($pcnt) [expr $activeloghi($pcnt) - $activeloglo($pcnt)]
			if {$isint($pcnt)} {
				set lotxt [expr round($actvlo($pcnt))]
				set hitxt [expr round($actvhi($pcnt))]
			} else {
				set lotxt [FiveSigFig $actvlo($pcnt)]
				set hitxt [FiveSigFig $actvhi($pcnt)]
			}
			set lowidth [string length $lotxt]
			if {$lowidth < $evv(RANGEWIDTH)} {
				set lowidth $evv(RANGEWIDTH)
			}
			set hiwidth [string length $hitxt]
			if {$hiwidth < $evv(RANGEWIDTH)} {
				set hiwidth $evv(RANGEWIDTH)
			}
			$prmgrd.rlo$gcnt config -text $lotxt -width $lowidth
			$prmgrd.rhi$gcnt config -text $hitxt -width $hiwidth
			set rangetype($pcnt) $evv(MINRANGE_SET)

#JUNE 2000 add IsNumeric condition
			if {$resetdefault && [IsNumeric $prm($pcnt)]} {
				if {$prm($pcnt) < $actvlo($pcnt) || $prm($pcnt) > $actvhi($pcnt)} {
					set prm($pcnt) $dfault($pcnt)
					if {$ins(run) && ($prm($pcnt) < $actvlo($pcnt) || $prm($pcnt) > $actvhi($pcnt))} {
						set prm($pcnt) $ins_subdflt($pcnt)
					}
					InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
				}
			}
			ResetScale $pcnt log
		}

	if {$fromgui} {
		set range_changed($gcnt) 1
	}
}

#----- POWTWO-SLIDER-BAR GADGET
#
#	  0		  1	   2	  3		   4	5	  6			7				8			   9	|	11
#	----------------------------------------------------------------------------------------|-------
#  | ----  	----			     ----   /\ 	 ----	____________					     	|  ---  |
#  ||Get | |Make| No: PARAMNAME | lo |  \/  | hi | |val entry...| ======||========	     	| |var| |
#  ||File| |File|			    |	 | range| 	 | |____________|	 (slider bar)	    	|  ---  |
#  | ----	----			     ---- switch ----									     	|       |
#	----------------------------------------------------------------------------------------|-------
#	BRKFILE-ENTRY	  NAME		RANGE-INFORMATION  VALUE-ENTRY....................
#				    & NUMBER
#					OF PARAM
#


proc PowtwoGadget {name datatype low high dflt sublow subhigh gcnt pcnt} {
	global dfault actvhi actvlo prmgrd scl norange_gdg
	global prm isint canhavefiles dbl_rng ins evv

	set thisrow $gcnt
	incr thisrow $gcnt

	set isint($pcnt) 1
	set canhavefiles($pcnt) 0
	set dbl_rng($pcnt) 0

	#	NO. AND NAME
	DisplayParamName $name $gcnt $pcnt $pcnt $thisrow
	incr thisrow

	#	RANGE DISPLAY

	EstablishPowtwoRange $gcnt $pcnt $low $high $thisrow

	if {$ins(run)} {
		set prm($pcnt) $dfault($pcnt)
	} else {
		set dfault($pcnt) $dflt
		set prm($pcnt) $dflt
	}

	#	ENTRY BOX
	entry $prmgrd.e$gcnt -textvariable prm($pcnt) -width 14
	grid  $prmgrd.e$gcnt -row $thisrow -column $evv(VAL_ENTRY)
	bind  $prmgrd.e$gcnt <Tab> "ThisParamOK $gcnt $pcnt $prmgrd.e$gcnt"

	set spacc [label $prmgrd.spcc$gcnt -text "" -width 1]
	grid $spacc -row $thisrow -column $evv(PARAM_SPACE)

	#	SLIDER BAR

	set scl($pcnt) [MakeScale $gcnt $pcnt powtwo]
	grid $scl($pcnt) -row $thisrow -column $evv(SLIDER_BAR)

	set spacc2 [label $prmgrd.spcc2a$gcnt -text "" -width 1]
	grid $spacc2 -row $thisrow -column $evv(PARAM_SPACE2)

	if {$ins(run)} {
		JigPowtwoDefaultDisplay	$pcnt $gcnt
		InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
		return
	}
	InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
	SetScale $pcnt powtwo
}

#------ Establish range for a Powtw0-Gadget

proc EstablishPowtwoRange {gcnt pcnt low high thisrow} {
	global lo hi sublo subhi actvlo actvhi isint prmgrd evv
	global ins ins_timetype powtwo_convertor powtwo_range

 	set lo($pcnt) $low
 	set hi($pcnt) $high
	
 	set actvlo($pcnt) $low
 	set actvhi($pcnt) $high

	set powtwo_range($pcnt) [expr int(round(log($hi($pcnt)) * $evv(ONE_OVER_LN2)))]  
	incr powtwo_range($pcnt) -1
	set powtwo_convertor($pcnt) [expr 1.0 / $powtwo_range($pcnt)]  

	set lotxt [expr round($actvlo($pcnt))]
	set hitxt [expr round($actvhi($pcnt))]
	set lowidth [string length $lotxt]
	if {$lowidth < $evv(RANGEWIDTH)} {
		set lowidth $evv(RANGEWIDTH)
	}
	set hiwidth [string length $hitxt]
	if {$hiwidth < $evv(RANGEWIDTH)} {
		set hiwidth $evv(RANGEWIDTH)
	}
	label $prmgrd.rlo$gcnt -justify center -text $lotxt -width $lowidth
	label $prmgrd.rr$gcnt -text "Range"
	label $prmgrd.rhi$gcnt -justify center -text $hitxt -width $hiwidth
	# RANGE LIMITS, BUT NO RANGE-CHANGE BUTTON
	grid $prmgrd.rlo$gcnt -row $thisrow -column $evv(LORANGE) -sticky e
	grid $prmgrd.rr$gcnt -row $thisrow -column $evv(RANGE_SWITCH)
	grid $prmgrd.rhi$gcnt -row $thisrow -column $evv(HIRANGE) -sticky w
}


#------ Setting the Powtw0-Gadget-slider-bar and checking file exists for a ins run

proc JigPowtwoDefaultDisplay {pcnt gcnt} {
	global prm actvlo actvhi dfault ins_subdflt dfltrangetype evv gadget_msg

	set gindex $gcnt
	incr gindex

	if {$prm($pcnt) < $actvlo($pcnt) || $prm($pcnt) > $actvhi($pcnt) } {
#NEW FEB 2004
		lappend gadget_msg "Instrument default value for parameter $gindex is out of range here : finding best default"
#
#		Inf "Instrument default value for parameter $gindex is out of range here : finding best default"
#
		set dfault($pcnt) $ins_subdflt($pcnt)
		if {$dfault($pcnt) > $actvhi($pcnt)} {
			set dfault($pcnt) $actvhi($pcnt)
		}
		set prm($pcnt) $dfault($pcnt)
	}
	SetScale $pcnt powtwo
}

#------ Allow user to edit as text or as graph.

proc Dlg_ChooseFiletype {pcnt gcnt} {
	global pr_whichtype brktype isbrktype text_edit_style evv
	set f .whichtype
	set isbrktype 1
#NEW AUGUST 2001
	if {$text_edit_style != 0} {
		switch -- $text_edit_style {
			1 { Dlg_MakeTextfile_Param $pcnt $gcnt}
			2 { Dlg_MakeBrkfile $pcnt $gcnt}
		}
		return
	}
	if [Dlg_Create $f "Text or Graphic" "set pr_whichtype 1" -borderwidth $evv(BBDR)] {
		frame $f.0
		frame $f.00
		frame $f.1
		button $f.0.brk  -text "Work on Graph"   -width 14 -command "Dlg_MakeBrkfile $pcnt $gcnt ; set pr_whichtype 1" -highlightbackground [option get . background {}]
		button $f.0.txt  -text "Work with Text"  -width 14 -command "Dlg_MakeTextfile_Param $pcnt $gcnt ; set pr_whichtype 1" -highlightbackground [option get . background {}]
		button $f.0.quit -text "Close" -command "set pr_whichtype 1" -highlightbackground [option get . background {}]
		pack $f.0.brk $f.0.txt -side left
		pack $f.0.quit -side right
		label  $f.00.spc  -text "~~ In Future ~~"
		pack $f.00.spc -side top
		button $f.1.brk  -text "Always use Graph" -width 14 -command "SetTextEditStyle 2; Dlg_MakeBrkfile $pcnt $gcnt ; set pr_whichtype 1" -highlightbackground [option get . background {}]
		button $f.1.txt  -text "Always use  Text" -width 14 -command "SetTextEditStyle 1; Dlg_MakeTextfile_Param $pcnt $gcnt ; set pr_whichtype 1" -highlightbackground [option get . background {}]
		label  $f.1.spc  -text "You can reset this choice on the 'System' menu"
		pack $f.1.brk $f.1.txt $f.1.spc -side left
		pack $f.0 -side top -fill x -expand true
		pack $f.00 -side top
		pack $f.1 -side top -pady 8
		bind $f <Return> {set pr_whichtype 1}
		bind $f <space>  {set pr_whichtype 1}
	}
	$f.0.brk config -command "Dlg_MakeBrkfile $pcnt $gcnt ; set pr_whichtype 1"
	$f.0.txt config -command "Dlg_MakeTextfile_Param $pcnt $gcnt ; set pr_whichtype 1"
	wm resizable $f 1 1
	set pr_whichtype 0
	raise $f
	My_Grab 0 $f pr_whichtype $f
	tkwait variable pr_whichtype
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	set isbrktype 0
}

#---------------------

proc PvocWarn {gcnt} {
	global pvoc_warn pprg ins_variable_store evv
	if {($pprg == $evv(PVOC_ANAL))} {
		if {$ins_variable_store($gcnt)} {
			Inf "You cannot make a valid instrument with\n\nvariable Number Of Channels or\nvariable Analwindow Overlap\n\nUnless This Is Last Process In Instrument.\n\nIn other cases the instrument does not have predictable properties."
			set pvoc_warn 1 
		} else {
			set pvoc_warn 0
		}
	}
}

#--- Make slider values more reasonable

proc SetPrtype {pcnt} {
	global prange prtype

	set prtype($pcnt) 0
	if {$prange($pcnt) > 256} {
		set prtype($pcnt) 1
	} elseif {$prange($pcnt) > 128} {
		set prtype($pcnt) 2
	} elseif {$prange($pcnt) > 64} {
		set prtype($pcnt) 4
	} elseif {$prange($pcnt) > 32} {
		set prtype($pcnt) 8
	} elseif {$prange($pcnt) > 16} {
		set prtype($pcnt) 16
	} elseif {$prange($pcnt) > 4} {
		set prtype($pcnt) 32
	} elseif {$prange($pcnt) > 2} {
		set prtype($pcnt) 64
	}
}

#--- Convert between sample-size & Level value, and vv. on appropriate param-gadgets

proc SamplesizeToLevelConvert {pcnt where} {
	global prm sampsize_convertor
	if {[info exists prm($pcnt)] && [IsNumericOrE $prm($pcnt)]} {
		 if {$prm($pcnt) < 1.0 && $prm($pcnt) >= -1.0} {
			set prm($pcnt) [expr $prm($pcnt) * $sampsize_convertor]
			$where config -text "lvl  "
		} else {
			set prm($pcnt) [expr $prm($pcnt) / double($sampsize_convertor)]
			$where config -text "smp"
		}
	}
}

proc ConvertToSecs {pcnt gcnt} {
	global prm evv mu cspreset
	if [ParampageInActiveHelpState] {
		return
	}
	if {[IsFrqParam $gcnt]} {
		if {[IsPitchNotation $prm($pcnt) 0]} {
			set prm($pcnt) [NoteToFrq $prm($pcnt)]
		} elseif {[IsMidiVal $prm($pcnt)]} {
			set prm($pcnt) [MidiToHz $prm($pcnt)]
		}
	} elseif {[IsMidiNoteParam $gcnt]} {
		if {[IsPitchNotation $prm($pcnt) 1]} {
			set prm($pcnt) [ConvertPitchToMidi $prm($pcnt)]
		} elseif {[IsNumeric $prm($pcnt)]} {
			set prm($pcnt) [HzToMidi $prm($pcnt)]
		}
	} elseif {[IsMidiGainParam $gcnt]} {
		if [IsGainValue $prm($pcnt)] {
			set prm($pcnt) [expr $prm($pcnt) * $mu(MIDIMAX)]
		}
	} elseif {[IsDbParam $gcnt]} {
		if {[IsGainValue $prm($pcnt)]} {
			set val [expr log10($prm($pcnt)) * 20.0]
			if {$val < -96.0} {
				set val -96.0
			}
			set prm($pcnt) $val
		}
	} elseif {[regexp {^[0-9]+$} $prm($pcnt)]} {
		set prm($pcnt) [ConvertSampcntNotation $prm($pcnt)]
	} elseif [IsHmsNotation $prm($pcnt)] {
		set prm($pcnt) [ConvertHmsNotation $prm($pcnt)]
	}
}

proc IsMidiVal {str} {
	global mu
	if {[IsNumeric $str]} {
		if {($str >= 0)  && ($str <= $mu(MIDIMAX))} {
			return 1
		}
	}
	return 0
}

proc IsHmsNotation {str} {

	if [ParampageInActiveHelpState] {
		return 0
	}
	set hrs 0
	set k [string first ":" $str]
	if {$k < 0} {
		return 0
	}
	incr k -1
	set mins [string range $str 0 $k]
	if {![regexp {^[0-9]+$} $mins]} {
		Inf "Parameter is not using Hrs:Mins:Secs notation correctly"
		return 0
	}
	incr k 2
	set str [string range $str $k end]
	set k [string first ":" $str]
	if {$k == 0} {
		Inf "Parameter is not using Hrs:Mins:Secs notation correctly"
		return 0
	} elseif {$k > 0} {
		set hrs $mins
		incr k -1
		set mins [string range $str 0 $k]
		if {![regexp {^[0-9]+$} $mins]} {
			Inf "Parameter is not using Hrs:Mins:Secs notation correctly"
			return 0
		}
		incr k 2
		set str [string range $str $k end]
	}
	if {![IsNumeric $str]} {
		Inf "Parameter is not using Hrs:Mins:Secs notation correctly"
		return 0
	}
	return 1
}

proc IsPitchNotation {str ismidi} {

	if [ParampageInActiveHelpState] {
		return 0
	}
	set len [string length $str]
	if {$len <= 1} {
		return 0
	}
	set cnt 0
	set note [string tolower [string index $str $cnt]]
	switch -- $note {
		"a" {	set midi 57 }
		"b" {	set midi 59 }
		"c" {	set midi 60 }
		"d" {	set midi 62 }
		"e" {	set midi 64 }
		"f" {	set midi 65 }
		"g" {	set midi 67 }
		default { return 0 }
	}
	incr cnt
	set item [string index $str $cnt]
	switch --  $item {
		"#" {	incr midi ; incr cnt}
		"b" { incr midi -1 ; incr cnt}
	}
	if {$cnt == $len} {
		return 0
	}
	set oct [string range $str $cnt end]
	set isneg 0
	if {[string match [string index $oct 0] "-"]} {
		set isneg 1
		set oct [string range $oct 1 end]
	}
	if {[string length $oct] > 1} {
		return 0
	}
	if {![regexp {^[0-9]+$} $oct]} {
		return 0
	}
	if {$oct > 9} {
		return 0
	}
	if {$ismidi} {
		if {$isneg} {
			set oct -$oct
		}
		set oct [expr $oct * 12]
		set midi [expr $midi + $oct]
		if {($midi < 0	) || ($midi > 127)} {
			return 0
		}
	}
	return 1
}

proc ConvertHmsNotation {str} {
	set hrs 0
	set k [string first ":" $str]
	incr k -1
	set mins [string range $str 0 $k]
	incr k 2
	set str [string range $str $k end]
	set k [string first ":" $str]
	if {$k > 0} {
		set hrs $mins
		incr k -1
		set mins [string range $str 0 $k]
		incr k 2
		set str [string range $str $k end]
	}
	set secs $str
	set hrs  [expr $hrs * 3600.0]
	set mins [expr $mins * 60.0]
	set secs [expr $secs + $mins + $hrs]
	return $secs
}

proc ParampageInActiveHelpState {} {
	if [winfo exists .ppg.help] {
		set www .ppg.help
	} elseif [winfo exists .ppg.c.canvas.f.help] {
		set www .ppg.c.canvas.f.help
	}
	if {[string match [$www.con cget -text] "Set Active"]} {
		return 1
	}
	return 0
}

proc ConvertSampcntNotation {str} {
	global chlist pa evv
	if {![info exists chlist] || ([llength $chlist] <= 0)} {
		return
	}
	set fnam [lindex $chlist 0]
	if {![info exists pa($fnam,$evv(SRATE))]} {
		return
	}
	set srate $pa($fnam,$evv(SRATE))
	set secs [DecPlaces [expr double($str)/double($srate)] 6]
	return $secs
}

proc NumericTypeGadget {gcnt} {
	global pg_spec
	set parameter_props [lindex $pg_spec $gcnt]
	set prop_id [lindex $parameter_props 0]
	switch -- $prop_id {
		SWITCHED	-
		LINEAR		-
		LOG			-
		PLOG		-
		FILE_OR_VAL -
		NUMERIC		-
		LOGNUMERIC	{
			return 1
		}
	}
	return 0
}

proc ConvertPitchToMidi {str} {
	set cnt 0
	set note [string tolower [string index $str $cnt]]
	switch -- $note {
		"a" {	set midi 69 }
		"b" {	set midi 71 }
		"c" {	set midi 60 }
		"d" {	set midi 62 }
		"e" {	set midi 64 }
		"f" {	set midi 65 }
		"g" {	set midi 67 }
	}
	incr cnt
	set item [string index $str $cnt]
	switch --  $item {
		"#" {	incr midi ; incr cnt}
		"b" { incr midi -1 ; incr cnt}
	}
	set oct [string range $str $cnt end]
	set oct [expr $oct * 12]
	set midi [expr $midi + $oct]
	return $midi
}

proc IsGainValue {str} {
	if {![IsNumeric $str]} {
		return 0
	}
	if {($str < 0.0) || ($str > 1.0)} {
		return 0
	}
	return 1
}

proc IsFrqParam {gcnt} {
	global pprg mmod evv
	set thismode $mmod
	incr thismode -1
	switch -regexp -- $pprg \
		^$evv(ARPE)$ {
			if {$gcnt == 3 || $gcnt == 4} {
				return 1
			}
		} \
		^$evv(CHANNEL)$ {
			if {$gcnt == 0} {
				return 1
			}
		} \
		^$evv(MULTRANS)$ {
			if {$gcnt == 1 || $gcnt == 2} {
				return 1
			}
		} \
		^$evv(CLEAN)$ {
			if {$thismode == $evv(FILTERING)} {
				if {$gcnt == 0} {
					return 1
				}
			}
		} \
		^$evv(FILT)$ {
			if {$gcnt == 0} {
				return 1
			}
			if {($thismode >= 6) &&  ($gcnt == 1)} {
				return 1
			}
		} \
		^$evv(FOCUS)$ {
			if {($gcnt == 4) || ($gcnt == 5)} {
				return 1
			}
		} \
		^$evv(FOLD)$ {
			if {$gcnt == 0 || $gcnt == 1} {
				return 1
			}
		} \
		^$evv(FORM)$ {
			if {$gcnt == 1 || $gcnt == 2} {
				return 1
			}
		} \
		^$evv(GLIS)$ {
			if {$gcnt == 3} {
				return 1
			}
		} \
		^$evv(MEAN)$ {
			if {$gcnt == 0 || $gcnt == 1} {
				return 1
			}
		} \
		^$evv(OCTVU)$ {
			if {$gcnt == 1} {
				return 1
			}
		} \
		^$evv(P_FIX)$ {
			if {$gcnt == 2 || $gcnt == 3 || $gcnt == 5 || $gcnt == 6} {
				return 1
			}
		} \
		^$evv(P_VIBRATO)$ {
			if {$gcnt == 0} {
				return 1
			}
		} \
		^$evv(PEAK)$ {
			if {$gcnt == 2} {
				return 1
			}
		} \
		^$evv(PICK)$ {
			if {$gcnt == 0} {
				return 1
			}
		} \
		^$evv(PITCH)$ {
			if {$gcnt == 4 || $gcnt == 5} {
				return 1
			}
		} \
		^$evv(REPORT)$ {
			if {$gcnt == 3 || $gcnt == 4} {
				return 1
			}
		} \
		^$evv(SHIFT) {
			if {$thismode == 1 || $thismode == 2} {
				if {$gcnt == 1} {
					return 1
				}
			} elseif {$thismode == 3 || $thismode == 4} {
				if {$gcnt == 1 || $gcnt == 2} {
					return 1
				}
			}
		} \
		^$evv(SHIFTP)$ {
			if {$gcnt == 0} {
				return 1
			}
		} \
		^$evv(STRETCH)$ {
			if {$gcnt == 0 || $gcnt == 1} {
				return 1
			}
		} \
		^$evv(S_TRACE)$ {
			if {$gcnt == 1 || $gcnt == 2} {
				return 1
			}
		} \
		^$evv(TRACK)$ {
			if {$gcnt == 0 || $gcnt == 4} {
				return 1
			}
		} \
		^$evv(TRNSF)$ {
			if {$gcnt == 3 || $gcnt == 4} {
				return 1
			}
		} \
		^$evv(TRNSP)$ {
			if {$gcnt == 1 || $gcnt == 2} {
				return 1
			}
		} \
		^$evv(TUNE)$ {
			if {$gcnt == 4} {
				return 1
			}
		} \
		^$evv(VOCODE)$ {
			if {$gcnt == 2 || $gcnt == 3} {
				return 1
			}
		} \
		^$evv(WAVER)$ {
			if {$gcnt == 0 || $gcnt == 2} {
				return 1
			}
		} \
		^$evv(DISTORT_RPTFL)$ {
			if {$gcnt == 3} {
				return 1
			}
		} \
		^$evv(DISTORT_FLT)$ {
			if {$gcnt == 0} {
				return 1
			}
			if {$thismode == 2 && $gcnt == 1} {
				return 1
			}
		} \
		^$evv(DISTORT_OVERLOAD)$ {
			if {$thismode == 1 && $gcnt == 2} {
				return 1
			}
		} \
		^$evv(DISTORT_PULSED)$ {
			if {$gcnt == 3} {
				return 1
			}
		} \
		^$evv(ENV_TREMOL)$ {
			if {$gcnt == 0} {
				return 1
			}
		} \
		^$evv(FLUTTER)$ {
			if {$gcnt == 0} {
				return 1
			}
		} \
		^$evv(SHUDDER)$ {
			if {$gcnt == 1} {
				return 1
			}
		} \
		^$evv(EQ)$ {
			if {$thismode == 2} {
				if {$gcnt == 2} {
					return 1
				}
			} elseif {$gcnt == 1} {
				return 1
			}
		} \
		^$evv(FSTATVAR)$ {
			if {$gcnt == 2} {
				return 1
			}
		} \
		^$evv(FLTBANKN)$ - \
		^$evv(FLTBANKC)$ {
			if {$gcnt == 2 || $gcnt == 3} {
				return 1
			}
		} \
		^$evv(FLTSWEEP)$ {
			if {$gcnt == 2 || $gcnt == 3} {
				return 1
			}
		} \
		^$evv(MOD_RADICAL)$ {
			if {$thismode == $evv(MOD_RINGMOD)} {
				if {$gcnt == 0} {
					return 1
				}
			}
		} \
		^$evv(SYNTH_WAVE)$ {
			if {$gcnt == 3} {
				return 1
			}
		} \
 		^$evv(SYNTH_SPEC)$ {
			if {$gcnt == 1} {
				return 1
			}
		} \
 		^$evv(NOISE_SUPRESS)$ {
			if {$gcnt == 1} {
				return 1
			}
		} \
		^$evv(CYCINBETWEEN)$ {
			if {$gcnt == 1} {
				return 1
			}
		} \
		^$evv(LPHP)$ {
			if {$gcnt == 1 || $gcnt == 2} {
				return 1
			}
		} \
		^$evv(ONEFORM_PUT)$ {
			if {$gcnt == 1 || $gcnt == 2} {
				return 1
			}
		} \
		^$evv(SPEC_REMOVE)$ {
			if {$gcnt == 2} {
				return 1
			}
		} \
		^$evv(SSSS_EXTEND)$ {
			if {$gcnt == 1} {
				return 1
			}
		}
	return 0
}

proc IsMidiNoteParam {gcnt} {
	global pprg evv
	switch -regexp -- $pprg \
		^$evv(P_EXAG)$ {
			if {$gcnt == 0} {
				return 1
			}
		} \
		^$evv(P_INVERT)$ {
			if {$gcnt == 1 || $gcnt == 2 || $gcnt == 3} {
				return 1
			}
		} \
		^$evv(P_SMOOTH)$ {
			if {$gcnt == 1} {
				return 1
			}
		} \
		^$evv(SPEC_REMOVE)$ {
			if {$gcnt == 0 || $gcnt == 1} {
				return 1
			}
		} \
		^$evv(SIMPLE_TEX)$	- \
		^$evv(TEX_MCHAN)$	- \
		^$evv(TIMED)$		- \
		^$evv(GROUPS)$		- \
		^$evv(TGROUPS)$		- \
		^$evv(DECORATED)$	- \
		^$evv(PREDECOR)$	- \
		^$evv(POSTDECOR)$	- \
		^$evv(ORNATE)$		- \
		^$evv(PREORNATE)$	- \
		^$evv(POSTORNATE)$  - \
		^$evv(MOTIFS)$		- \
		^$evv(TMOTIFS)$		- \
		^$evv(MOTIFSIN)$	- \
		^$evv(TMOTIFSIN)$ {
			if {$gcnt == 11 || $gcnt == 12} {
				return 1
			}
		}
	return 0
}

proc IsMidiGainParam {gcnt} {
	global pprg evv
	switch -regexp -- $pprg \
		^$evv(SIMPLE_TEX)$	- \
		^$evv(TEX_MCHAN)$	- \
		^$evv(TIMED)$		- \
		^$evv(GROUPS)$		- \
		^$evv(TGROUPS)$		- \
		^$evv(DECORATED)$	- \
		^$evv(PREDECOR)$	- \
		^$evv(POSTDECOR)$	- \
		^$evv(ORNATE)$		- \
		^$evv(PREORNATE)$	- \
		^$evv(POSTORNATE)$  - \
		^$evv(MOTIFS)$		- \
		^$evv(TMOTIFS)$		- \
		^$evv(MOTIFSIN)$	- \
		^$evv(TMOTIFSIN)$ {
			if {$gcnt == 7 || $gcnt == 8} {
				return 1
			}
		}
	return 0
}

proc IsDbParam {gcnt} {
	global pprg evv
	switch -regexp -- $pprg \
		^$evv(LPHP)$ {
			if {$gcnt == 0} {
				return 1
			}
		} \
		^$evv(PITCH)$ {
			if {$gcnt == 2} {
				return 1
			}
		} \
		^$evv(TRACK)$ {
			if {$gcnt == 3} {
				return 1
			}
		} \
		^$evv(FLTBANKV)$ {
			if {$gcnt == 6} {
				return 1
			}
		} \
		^$evv(SYNFILT)$ {
			if {$gcnt == 8} {
				return 1
			}
		}
	return 0
}

proc CreateDeadParam {i} {
	global prm range_changed refp pstore dbl_rng entry_exists
	set prm($i) 0
	set range_changed($i) 0
	set refp($i) 0
	set pstore($i) 0
	set dbl_rng($i) 0
	set entry_exists($i) 0
}

proc MoveVal {gcnt pcnt down} {
	global prm ins actvhi actvlo norange_gdg
	if {$ins(run) && $norange_gdg($gcnt)} {
		return
	}
	if {![IsNumeric $prm($pcnt)]} {
		return
	}
	if {$down} {
		if {$prm($pcnt) <= $actvlo($pcnt)} {
			return
		} elseif {$prm($pcnt) > $actvhi($pcnt)} {
			set prm($pcnt) $actvhi($pcnt)
			return
		}
	} else {
		if {$prm($pcnt) >= $actvhi($pcnt)} {
			return
		} elseif {$prm($pcnt) < $actvlo($pcnt)} {
			set prm($pcnt) $actvlo($pcnt)
			return
		}
	}
	set range [expr $actvhi($pcnt) - $actvlo($pcnt)]
	;#	Step by the power of ten of the existing value
	set absval [expr abs($prm($pcnt))]
	if {$absval > 1000.0} {
		set q 1000
	} elseif {$absval >= 100.0} {
		set q 100
	} elseif {$absval >= 10.0} {
		set q 10
	} elseif {$absval >= 1.0} {
		set q 1
	} elseif {$absval >= 0.1} {
		set q 0.1
	} elseif {$absval >= 0.01} {
		set q 0.001
	;#	But if value is near to zero, step in relation to available range
	} elseif {$range >= 10000} {
		set q 1000
	} elseif {$range >= 1000} {
		set q 100
	} elseif {$range >= 100} {
		set q 10
	} elseif {$range >= 10} {
		set q 1
	} elseif {$range >= 1} {
		set q 0.1
	} elseif {$range >= 0.1} {
		set q 0.01
	} elseif {$range >= 0.01} {
		set q 0.001
	} else {
		return
	}
	if {$down} {
		set k [expr $actvlo($pcnt) - 1.0]
		while {$k < $actvlo($pcnt)} {
			set k [expr $prm($pcnt) - $q]
			switch -- $q {
				1000 {set q 100}
				100	 {set q 10}
				10	 {set q 1}
				1	 {set q 0.1}
				0.1	 {set q 0.01}
				0.01 {set q 0.001}
				0.001 {
					if {$k < $actvlo($pcnt)} {
						return
					}
					break
				}
			}
		}
	} else {
		set k [expr $actvhi($pcnt) + 1.0]
		while {$k > $actvhi($pcnt)} {
			set k [expr $prm($pcnt) + $q]
			switch -- $q {
				1000 {set q 100}
				100	 {set q 10}
				10	 {set q 1}
				1	 {set q 0.1}
				0.1	 {set q 0.01}
				0.01 {set q 0.001}
				0.001 {
					if {$k > $actvhi($pcnt)} {
						return
					}
					break
				}
			}
		}
	}
	if {$k > 0 && $k <= 0.001} {
		set k 0.001
	} elseif {$k < 0 && $k >= -0.001} {
		set k -0.001
	}
	set prm($pcnt) $k
}

proc DoGadgetBind {datatype} {
	global papag
	switch -- $datatype {								;#	Only create binding for "special" data, and for params that can be brkpnts
		 0 -
		 D -
		 I {
			set zzz [string trim [bind $papag <Control-0>]]	;#	Only create bindings if not already created for this parampage.
			if {[string length $zzz] > 0} {				;#	NB any existing bindings from previous parampage
				return									;#	are removed before gadgets of this page are created (see _parampage.tcl)
			}
			bind $papag <Control-0> {KeyViewParamtext 0} 
			bind $papag <Control-e> {KeyViewParamtext 1} 
			bind $papag <Control-E> {KeyViewParamtext 1} 
		 }
	}
}

proc KeyViewParamtext {edit} {
	global gdg_cnt prmgrd pg_spec k_textfilename prm brk evv
	set special 0
	set pcnt 0
	set gcnt 0
	if {[catch {selection get -displayof $prmgrd} sel]} {
		Inf "No Item Selected"
		return
	}
	if {[IsNumeric $sel]} {
		Inf "Item Selected Is Not A File"
		return
	}
	if {![file exists $sel]} {
		Inf "Item Selected Is Not A File"
		return
	}
	set ftyp [FindFileType $sel]
	if {($ftyp == -1) || !($ftyp & $evv(IS_A_TEXTFILE))} {
		Inf "Item Selected Is Not A Text File"
		return
	}
	while {$gcnt < $gdg_cnt} {							;#	Which parameter does the selection match ??
		set param_props "[lindex $pg_spec $gcnt]"
		set prop_id [lindex $param_props 0]
		if {[string match [string trim $prm($pcnt)] [string trim $sel]]} {
			break
		}
		if {$prop_id == "SWITCHED"} {
			incr pcnt
		}
		incr pcnt
		incr gcnt
	}
	if {$gcnt == $gdg_cnt} {
		Inf "No (Complete) Parameter Selected"
		return
	}
	set param_props "[lindex $pg_spec $gcnt]"
	set prop_id [lindex $param_props 0]
	switch -- $prop_id {
		"FILENAME" -
		"OPTIONAL_FILE" -
		"FILE_OR_VAL" -
		"VOWELS" {
			set special 1
		}
	}
	if {$edit} {
		set brk(from_wkspace) 0
		if {$special} {
			EditTextfile $sel special $pcnt $gcnt
		} else {
			EditTextfile $sel brk $pcnt $gcnt
		}
		set prm($pcnt) $k_textfilename
	} else {
		SimpleDisplayTextfile $sel
	}
}

################################################################################
# Reconfigure Gadgets, For new ranges etc, when processing files ONE AT A TIME #
################################################################################

#------- Recongif params page to be active with a new file

proc OneAtATimeReconfigParamPage {fnam} {
	global gdg_cnt param_spec pg_spec CDPid params_got badparamspec gdg_cnt papag which_oneatatime onpage_oneatatime
	global  norange_gdg

	set badparamspec 0

	set rootfnam [file rootname [file tail $fnam]]

	;#	RESET RANGE LIMITS

	if {$gdg_cnt > 0} {
	
		catch {unset param_spec}

		if {[GrainTrap]} {
			catch {unset onpage_oneatatime}
			UnsetNextFileState
			GetNewFilesFromPpg
			return
		}
		set cdparams_cmd "[SetupCdparamsCmdline]"

		if [catch {open "|$cdparams_cmd"} CDPid] {
			catch {unset CDPid}
			UnsetNextFileState
			GetNewFilesFromPpg
			return
		} else {										
   			fileevent $CDPid readable AccumulateParameterSpecs
			fconfigure $CDPid -buffering line
		}												
		vwait params_got

		if {$badparamspec} {
			UnsetNextFileState
			GetNewFilesFromPpg
			return
		}

		if {![info exists param_spec]} {
			UnsetNextFileState
			GetNewFilesFromPpg
			return
		}

		set pg_spec $param_spec

		set pgs_len [llength $pg_spec]
		if {$pgs_len > 1} {
			set pg_spec [lrange $pg_spec 1 end]
		} else {
			UnsetNextFileState
			GetNewFilesFromPpg
			return
		}
		set ggcnt 0 
		set ppmcnt 0
		while {$ggcnt < $gdg_cnt} {
			if {[IsDeadParam $ggcnt]} {
				incr ggcnt
				incr ppmcnt
				continue
			}
			set param_props "[lindex $pg_spec $ggcnt]"  			;#	Find prm-props-group for 1 prm
			set prop_id [lindex $param_props 0]						;#	Get first property
			switch -- $prop_id {
				CHECKBUTTON {
					incr ggcnt
					continue
				}
				SWITCHED {
					set cmd ResetSwitchedGadget
				}
				LINEAR {
					set cmd ResetLinearGadget
				}
				LOG {
					set cmd ResetLogGadget
				}
				PLOG {
					set cmd ResetPlogGadget
				}
				FILE_OR_VAL {
					set cmd ResetFileOrValGadget
				}
				OPTIONAL_FILE -
				FILENAME {
					set cmd ResetFilenameGadget
				}
				NUMERIC {
					set cmd ResetNumericGadget
				}
				LOGNUMERIC {
					set cmd ResetLogNumericGadget
				}
				TIMETYPE {
					set cmd ResetTimetypeGadget
				}
				SRATE_GADGET {
					set cmd ResetSrateGadget
				}
				POWTWO -
				MIDI_GADGET  -
				OCT_GADGET   -
				CHORD_GADGET -
				TWOFAC		 -
				WAVETYPE {
					set cmd ResetBasicGadget
				}
				GENERICNAME -
				STRING_A -
				STRING_B -
				STRING_C -
				STRING_D -
				STRING_E {
					set cmd ResetStringGadget
				}
				VOWELS {
					set cmd ResetFileOrVowelGadget
				}
				default {
					UnsetNextFileState
					GetNewFilesFromPpg
					return
				}
			}		
			set cmd [concat $cmd [lrange $param_props 1 end]]
			lappend cmd $ggcnt $ppmcnt

			if {![info exists norange_gdg($ggcnt)]} {
				set norange_gdg($ggcnt) 0
			}
			if [catch {eval $cmd} in] {
				UnsetNextFileState
				GetNewFilesFromPpg
				return
			}
			incr ppmcnt
			if {[string match $prop_id SWITCHED]} {		;#	switched gadget takes 2 params
				incr ppmcnt
			}
			incr ggcnt
		}
	}

	;#	RESET NAME OF INFILE IN TITLE BAR

	set thistext [$papag.parameters.titles.prgname cget -text]
	set k [string first ": FILE " $thistext]
	if {$k < 0} {
		UnsetNextFileState
		GetNewFilesFromPpg
		return
	}
	incr k 6
	set start_text [string range $thistext 0 $k]
	incr k
	set end_text [string range $thistext $k end]
	set len [string length $end_text]
	set k 0
	while {$k < $len} {
		if {[string match [string index $end_text $k] "."]} {
			break
		}
		incr k
	}
	if {$k == $len} {
		UnsetNextFileState
		GetNewFilesFromPpg
		return
	}
	set end_text [string range $end_text $k end]
	set thistext $start_text
	append thistext $rootfnam
	append thistext $end_text
	$papag.parameters.titles.prgname config -text $thistext

	;#	RESET NAME OF INFILE IN RENAME BOX (IF USED)

	catch {.keeplist.saver.namesb.list delete 0 end}
	catch {.keeplist.saver.namesb.list insert end $rootfnam}
}

#------ Set System to State where 'Next File' button is not operational

proc UnsetNextFileState {} {
	global which_oneatatime oneatatime chlist ch chcnt papag
	incr which_oneatatime -1
	set fnam [lindex $oneatatime $which_oneatatime]		;#	Go back to previously selected soundfile
	DoChoiceBak											;#	And put it on the Chosen Files List
	ClearWkspaceSelectedFiles
	lappend chlist $fnam
	$ch insert end $fnam								;#	Reset button on params page, to normal state
	incr chcnt
	$papag.parameters.zzz.newf config -text "To Wkspace" -command {GetNewFilesFromPpg}
}

#------ RESET NUMERIC GADGET

proc ResetNumericGadget {name datatype low high dflt gcnt pcnt} {
	global dfault isint prm prmgrd scl canhavefiles dbl_rng ins evv
	global chlist ins_timetype norange_gdg actvhi samp_to_level_convert

	set thisrow $gcnt
	incr thisrow $gcnt
	if {$ins(run)} {
		set fix_timetype 0
		if {($ins_timetype($gcnt) > 0)} {
			set fix_timetype 1
		} elseif {$norange_gdg($gcnt) && [IsAnEditProcessUsingSamples $gcnt]} {
			set fix_timetype 1
		}
		if {$fix_timetype} {
			set fnam [lindex $chlist 0]
			set invals [eval {SetTimeType $ins_timetype($gcnt) $fnam} $low $high $dflt]
			set low 	[lindex $invals 0]
			set high 	[lindex $invals 1]
			set dflt 	[lindex $invals 2]
			set isint($pcnt) 1
		}
	}
	incr thisrow
	if {$ins(run) && $norange_gdg($gcnt)} {
		ReEstablishUnknownRange $name $gcnt $pcnt $low $high $thisrow
	} else {
		ReEstablishSimpleRange $gcnt $pcnt $low $high $thisrow
	}
	if {$ins(run)} {
		if {$dfault($pcnt) > $actvhi($pcnt)} {
			set dfault($pcnt) $actvhi($pcnt)
		}
		set prm($pcnt) $dfault($pcnt)
	} else {
		set dfault($pcnt) $dflt
		set prm($pcnt) $dflt
	}
	InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
	SetScale $pcnt linear
}

#------ RESET LOGNUMERIC GADGET

proc ResetLogNumericGadget {name datatype low high dflt gcnt pcnt} {
	global dfault isint prm prmgrd scl canhavefiles dbl_rng ins evv
	global ins_timetype norange_gdg actvhi samp_to_level_convert

	set thisrow $gcnt
	incr thisrow $gcnt
	incr thisrow

	if {$ins(run) && $norange_gdg($gcnt)} {
		ReEstablishUnknownRange $name $gcnt $pcnt $low $high $thisrow
		set dbl_rng($pcnt) 0
	} else {
		ReEstablishSimpleLogRange $gcnt $pcnt $low $high $thisrow
	}
	if {$ins(run)} {
		if {$dfault($pcnt) > $actvhi($pcnt)} {
			set dfault($pcnt) $actvhi($pcnt)
		}
		set prm($pcnt) $dfault($pcnt)
	} else {
		set dfault($pcnt) $dflt
		set prm($pcnt) $dflt
	}
	if {$ins(run)} {
		SetScale $pcnt log
		InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
		return
	}
	InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
	SetScale $pcnt log
}

#------ RESET TIMETYPE GADGET 

proc ResetTimetypeGadget {name dflt gcnt pcnt} {
	global chlist prm pa actvhi actvlo dfault evv
	global ins prmgrd secshi sampshi stsampshi
	global sratehere chanshere isint dbl_rng ins timetype
	global secslo sampslo stsampslo secshi sampshi stsampshi

	if {$ins(create)} {
		set thischosenlist "$ins(chlist)"
	} else {
		set thischosenlist "$chlist"
	}
	set fnam [lindex $thischosenlist 0]

 	set secshi($pcnt)  $pa($fnam,$evv(DUR))
	set sampshi($pcnt) $pa($fnam,$evv(INSAMS))
	set stsampshi($pcnt) [expr $sampshi($pcnt) / $chanshere($pcnt)]
	set rr $prmgrd.tt$gcnt
	$rr.0 config -command "ResetFadeRanges $secslo($pcnt) $secshi($pcnt) $sratehere($pcnt) $chanshere($pcnt) secs 0"
	$rr.1 config -command "ResetFadeRanges $sampslo($pcnt) $sampshi($pcnt) $sratehere($pcnt) $chanshere($pcnt) samps 1"
	$rr.2 config -command "ResetFadeRanges $stsampslo($pcnt) $stsampshi($pcnt) $sratehere($pcnt) $chanshere($pcnt) stsmps 2"
}

#------ RESET SRATE GADGET 

proc ResetSrateGadget {name dflt gcnt pcnt} {
	global prm dfault prmgrd isint dbl_rng ins is_dflt_sr_gadget sl_real evv

	if {$evv(DFLT_SR) <= 0} {
		if {$ins(run)} {
			set prm($pcnt) [expr int($dfault($pcnt))]
		} else {
			set prm($pcnt) [expr int($dflt)]
		 	set dfault($pcnt) $dflt
		}
	}
}

#--   RESET BASIC GADGET

proc ResetBasicGadget {name dflt gcnt pcnt} {
	global prm dfault prmgrd isint dbl_rng ins is_dflt_sr_gadget sl_real evv

	if {$ins(run)} {
		set prm($pcnt) [expr int($dfault($pcnt))]
	} else {
		set prm($pcnt) [expr int($dflt)]
	 	set dfault($pcnt) $dflt
	}
}

#------ RESET STRING GADGET

proc ResetStringGadget {name gcnt pcnt} {
	global prm evv dfault prmgrd dbl_rng ins isint

	if {$ins(run)} {
		set prm($pcnt) $dfault($pcnt)
	} else {
		set dfault($pcnt) ""
		set prm($pcnt) ""
	}
}

#------ RESET SWITCHED GADGET

proc ResetSwitchedGadget {name name2 name3 datatype low high dflt low2 high2 dflt2 gcnt pcnt} {
	global prm prange evv actvhi actvlo dfault prmgrd scl isint evv
	global canhavefiles dfault1 dfault2	dbl_rng ins ins_switch_dflt
	global lo hi sublo subhi

	set paramswitch $pcnt
	if {$ins(run)} {
		set prm($paramswitch) $dfault($paramswitch)	
	}
	incr pcnt										;#	Move on the 'real' parameter

	if {$ins(run)} {
		set ins_switch_dflt($pcnt) $dfault($pcnt)
	}

	set lo($pcnt) $low
	set hi($pcnt) $high
	set sublo($pcnt) $low2
	set subhi($pcnt) $high2

	set dfault1($pcnt) $dflt
	set dfault2($pcnt) $dflt2

	$prmgrd.rba$gcnt config -command "ToggleGadget $gcnt $paramswitch $pcnt $low $high $dflt $low2 $high2 $dflt2"
	$prmgrd.rbb$gcnt config -command "ToggleGadget $gcnt $paramswitch $pcnt $low $high $dflt $low2 $high2 $dflt2"

	set actvlo($pcnt) $low
 	set actvhi($pcnt) $high
	set prange($pcnt) [expr $actvhi($pcnt) - $actvlo($pcnt)]
	SetPrtype $pcnt

	if {$isint($pcnt)} {
		set lotxt [expr round($actvlo($pcnt))]
		set hitxt [expr round($actvhi($pcnt))]
	} else {
		set lotxt [FiveSigFig $actvlo($pcnt)]
		set hitxt [FiveSigFig $actvhi($pcnt)]
	}
	set lowidth [string length $lotxt]
	if {$lowidth < $evv(RANGEWIDTH)} {
		set lowidth $evv(RANGEWIDTH)
	}
	set hiwidth [string length $hitxt]
	if {$hiwidth < $evv(RANGEWIDTH)} {
		set hiwidth $evv(RANGEWIDTH)
	}
	$prmgrd.rlo$gcnt config -text $lotxt -width $lowidth
	$prmgrd.rhi$gcnt config -text $hitxt -width $hiwidth

	if {$ins(run)} {
		set prm($pcnt) $dfault($pcnt)
	} else {
		set prm($pcnt) $dflt2
	 	set dfault($pcnt) $dflt2
	}
	InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
	SetScale $pcnt linear
}

#------ RESET FILE-OR-VOWEL GADGET	

proc ResetFileOrVowelGadget {name gcnt pcnt} {
	global dfault isint canhavefiles prmgrd scl norange_gdg gadget_msg
	global prm dbl_rng ins evv

	if {$ins(run)} {
		set prm($pcnt) $dfault($pcnt)
	} else {
	 	set dfault($pcnt) "a"
		set prm($pcnt) "a"
	}
	if {$ins(run)} {
		if {![ValidVowelName $prm($pcnt)]} {
			set fnam $prm($pcnt)
			if {![file exists $fnam]} {
				lappend gadget_msg "File $prm($pcnt) no longer exists : reverting to standard default value"
				set dfault($pcnt) "a"
				set prm($pcnt) "a"
			} else {
				set remember $prm($pcnt)
				set prm($pcnt) $ins_subdflt($pcnt)			
				set dfault($pcnt) $remember
				set prm($pcnt) $remember
			}
		}
	}
}

#------ RESET FILENAME GADGET	

proc ResetFilenameGadget {name datatype low high sublow subhigh gcnt pcnt} {
	global prm isint canhavefiles dfault prmgrd dbl_rng norange_gdg ins gdg_typeflag evv

	set thisrow $gcnt
	incr thisrow $gcnt
	incr thisrow

	if {$ins(run)} {
		set prm($pcnt) $dfault($pcnt)
	} elseif {$gdg_typeflag($gcnt) == $evv(OPTIONAL_FILE)} {
		set dfault($pcnt) 0
		set prm($pcnt) 0
	} else {
		set dfault($pcnt) "filename"
		set prm($pcnt) "filename"
	}

	if {$ins(run) && $norange_gdg($gcnt) && ($datatype ==1 || $datatype == 2)} {
		RESET ReEstablishUnknownRange $name $gcnt $pcnt $low $high $thisrow
	} else {
		switch -- $datatype {
			0 {}
			1 {
				ReEstablishSimpleRange $gcnt $pcnt $low $high $thisrow
			}
			2 {		
				ReEstablishSimpleRange $gcnt $pcnt $low $high $thisrow
				ReEstablishOtherRange $gcnt $pcnt $sublow $subhigh $evv(PARAM_SPACE) $thisrow
			}
			default {
				ErrShow "Erroneous datatype for FilenameGadget range display"
			}
		}
	}
	if {$ins(run)} {
		JigInsFilenameDefaultDisplay $pcnt $gcnt
	}
	InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
}

#------ RESET FILE-OR-VAL GADGET	

proc ResetFileOrValGadget {name datatype low high dflt gcnt pcnt} {
	global dfault isint canhavefiles prmgrd scl norange_gdg
	global prm dbl_rng ins evv

	set thisrow $gcnt
	incr thisrow $gcnt
	incr thisrow
	if {$ins(run) && $norange_gdg($gcnt)} {
		ReEstablishUnknownRange $name $gcnt $pcnt $low $high $thisrow
	} else {
		ReEstablishSimpleRange $gcnt $pcnt $low $high $thisrow
	}

	if {$ins(run)} {
		set prm($pcnt) $dfault($pcnt)
	} else {
	 	set dfault($pcnt) $dflt
		set prm($pcnt) $dflt
	}

	if {$ins(run)} {
		JigInsFileOrValDefaultDisplay $pcnt $gcnt
		InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
		return
	}
	InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
	SetScale $pcnt linear
}

#------ RESET LOG-SLIDER-BAR GADGET

proc ResetLogGadget {name datatype low high dflt sublow subhigh gcnt pcnt} {
	global dfault actvhi actvlo prmgrd scl norange_gdg
	global prm isint canhavefiles dbl_rng ins evv

	set thisrow $gcnt
	incr thisrow $gcnt
	incr thisrow
	if {$ins(run) && $norange_gdg($gcnt)} {
		ReEstablishUnknownRange $name $gcnt $pcnt $low $high $thisrow
	} elseif {![Flteq $low $sublow] || ![Flteq $high $subhigh]} {
		ReEstablishLogRange $gcnt $pcnt $low $high $sublow $subhigh $thisrow $dflt
	} else {
		ReEstablishSimpleLogRange $gcnt $pcnt $low $high $thisrow
	}
	if {$ins(run)} {
		set prm($pcnt) $dfault($pcnt)
	} else {
		set dfault($pcnt) $dflt
		set prm($pcnt) $dflt
	}
	if {$ins(run)} {
		JigInsLogDefaultDisplay	$pcnt $gcnt
		InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
		return
	}
	InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
	SetScale $pcnt log
}

#------ RESET PLOG-SLIDER-BAR GADGET

proc ResetPlogGadget {name datatype low high dflt sublow subhigh gcnt pcnt} {
	global dfault prm evv prmgrd scl isint canhavefiles norange_gdg
	global pitchdisplay actvhi actvlo dbl_rng ins
	global prm readonlyfg readonlybg

	set thisrow $gcnt
	incr thisrow $gcnt
	incr thisrow
	if {$ins(run) && $norange_gdg($gcnt)} {
		ReEstablishUnknownRange $name $gcnt $pcnt $low $high $thisrow
	} elseif {![Flteq $low $sublow] || ![Flteq $high $subhigh]} {
		ReEstablishLogRange $gcnt $pcnt $low $high $sublow $subhigh $thisrow $dflt
	} else {
		ReEstablishSimpleLogRange $gcnt $pcnt $low $high $thisrow
	}
	if {$ins(run)} {
		set prm($pcnt) $dfault($pcnt)
	} else {
		set dfault($pcnt) $dflt
		set prm($pcnt) $dflt
	}
	if {$ins(run)} {
		JigInsPLogDefaultDisplay $pcnt $gcnt
		InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
		return
	}
	InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
	set pitchdisplay($pcnt) [SetPitchDisplay [expr log ($prm($pcnt))] $gcnt $pcnt]
	ForceVal $prmgrd.pi$gcnt $pitchdisplay($pcnt)
	SetScale $pcnt log
}


#------ RESET LINEAR-SLIDER-BAR GADGET

proc ResetLinearGadget {name datatype low high dflt sublow subhigh gcnt pcnt} {
	global dfault actvhi actvlo prmgrd scl ins samp_to_level_convert
	global isint canhavefiles prm dbl_rng norange_gdg evv

	set thisrow $gcnt
	incr thisrow $gcnt
	incr thisrow

	if {$ins(run) && $norange_gdg($gcnt)} {
		ReEstablishUnknownRange $name $gcnt $pcnt $low $high $thisrow
	} elseif {![Flteq $low $sublow] || ![Flteq $high $subhigh]} {
		ReEstablishRange $gcnt $pcnt $low $high $sublow $subhigh $thisrow $dflt
	} else {
		ReEstablishSimpleRange $gcnt $pcnt $low $high $thisrow
	}
	if {$ins(run)} {
		set prm($pcnt) $dfault($pcnt)
	} else {
		set dfault($pcnt) $dflt
		set prm($pcnt) $dflt
	}
	if {$ins(run)} {
		JigInsLinearDefaultDisplay $pcnt $gcnt
		InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
		return
	}
	InsertParamValueInEntryDisplay $prmgrd.e$gcnt $pcnt
	SetScale $pcnt linear
}

#------ Set up the range determining parameters for single-range case

proc ReEstablishSimpleRange {gcnt pcnt low high thisrow} {
	global lo hi sublo subhi actvlo actvhi isint prmgrd prange evv
	global ins ins_timetype

 	set lo($pcnt) $low
 	set hi($pcnt) $high
	
 	set actvlo($pcnt) $low
 	set actvhi($pcnt) $high

	set prange($pcnt) [expr $actvhi($pcnt) - $actvlo($pcnt)]
	SetPrtype $pcnt

	if {$isint($pcnt)} {
		set lotxt [expr round($actvlo($pcnt))]
		set hitxt [expr round($actvhi($pcnt))]
	} else {
		set lotxt [FiveSigFig $actvlo($pcnt)]
		set hitxt [FiveSigFig $actvhi($pcnt)]
	}
	set lowidth [string length $lotxt]
	if {$lowidth < $evv(RANGEWIDTH)} {
		set lowidth $evv(RANGEWIDTH)
	}
	set hiwidth [string length $hitxt]
	if {$hiwidth < $evv(RANGEWIDTH)} {
		set hiwidth $evv(RANGEWIDTH)
	}
	$prmgrd.rlo$gcnt config -text $lotxt -width $lowidth
	$prmgrd.rhi$gcnt config -text $hitxt -width $hiwidth
}

#------ Set up the range determining parameters for parameter with unknown upper range limit

proc ReEstablishUnknownRange {name gcnt pcnt low high thisrow} {
	global lo hi sublo subhi actvlo actvhi isint prmgrd prange evv
	global ins ins_timetype

 	set lo($pcnt) $low
 	set hi($pcnt) $high
 	set actvlo($pcnt) $low
 	set actvhi($pcnt) $high

	set prange($pcnt) [expr $actvhi($pcnt) - $actvlo($pcnt)]
	SetPrtype $pcnt

	if {$isint($pcnt)} {
		set lotxt [expr round($actvlo($pcnt))]
		set hitxt [expr round($actvhi($pcnt))]
	} else {
		set lotxt [FiveSigFig $actvlo($pcnt)]
		set hitxt [FiveSigFig $actvhi($pcnt)]
	}
	set lowidth [string length $lotxt]
	if {$lowidth < $evv(RANGEWIDTH)} {
		set lowidth $evv(RANGEWIDTH)
	}
	set hiwidth [string length $hitxt]
	if {$hiwidth < $evv(RANGEWIDTH)} {
		set hiwidth $evv(RANGEWIDTH)
	}
	$prmgrd.rlo$gcnt config -text $lotxt -width $lowidth
	$prmgrd.rhi$gcnt donfig -text $hitxt -width $hiwidth
}

#------ 2nd (display only) range

proc ReEstablishOtherRange {gcnt pcnt low high col thisrow} {
	global lo hi sublo subhi actvlo actvhi isint prmgrd prange evv

	set zoog $pcnt
	set kom 0
	incr pcnt 10000
	incr gcnt 10000
	set isint($pcnt) $isint($zoog) 

	#	These two lines may be redundant:
 	set lo($pcnt) $low
 	set hi($pcnt) $high
	#	These two lines may be even more redundant:
 	set sublo($pcnt) $low
 	set subhi($pcnt) $high
	
 	set actvlo($pcnt) $low
 	set actvhi($pcnt) $high

	set prange($pcnt) [expr $actvhi($pcnt) - $actvlo($pcnt)]
	SetPrtype $pcnt

	if {$isint($pcnt)} {
		set lotxt [expr round($actvlo($pcnt))]
		set hitxt [expr round($actvhi($pcnt))]
	} else {
		set lotxt [FiveSigFig $actvlo($pcnt)]
		set hitxt [FiveSigFig $actvhi($pcnt)]
		if {$actvlo($pcnt) <= $evv(FLTERR)} {
			set lotxt "\>0.0"
			set kom 1
		}			
	}
	set lowidth [string length $lotxt]
	if {$lowidth < $evv(RANGEWIDTH)} {
		set lowidth $evv(RANGEWIDTH)
	}
	set hiwidth [string length $hitxt]
	if {$hiwidth < $evv(RANGEWIDTH)} {
		set hiwidth $evv(RANGEWIDTH)
	}
	set zurb ""
	if {!$kom} {
		set q [expr $lowidth - [string length $lotxt]]
		if {$q > 0} {
			set i 0
			while {$i < $q} {
				append zurb "."
				incr i
			}
		}
	}
	if {[string length $zurb] > 0} {
		set lotxt [list $lotxt $zurb "Range2" $hitxt]
	} else {
		set lotxt [list $lotxt "Range2" $hitxt]
	}
	$prmgrd.rlo$gcnt config -text $lotxt
}

#------ Set up the range determining parameters, for log-slider

proc ReEstablishLogRange {gcnt pcnt low high sublow subhigh thisrow dflt} {
	global lo hi sublo subhi actvlo actvhi isint rangetype evv
	global loglo loghi logsublo logsubhi dfltrangetype partype
	global activeloglo activeloghi prmgrd prange prtype
 	set lo($pcnt) $low
 	set hi($pcnt) $high
 	set sublo($pcnt) $sublow
 	set subhi($pcnt) $subhigh
	set loglo($pcnt) [expr log($lo($pcnt))]
	set loghi($pcnt) [expr log($hi($pcnt))]
 	set logsublo($pcnt) [expr log($sublo($pcnt))]
 	set logsubhi($pcnt) [expr log($subhi($pcnt))]

 	set actvlo($pcnt) $sublow
 	set actvhi($pcnt) $subhigh
 	set activeloglo($pcnt) $logsublo($pcnt)
 	set activeloghi($pcnt) $logsubhi($pcnt)
 	set rangetype($pcnt) $evv(MINRANGE_SET)
	set dfltrangetype($pcnt) $evv(MINRANGE_SET)
	set partype($pcnt) log

	set prange($pcnt) [expr $activeloghi($pcnt) - $activeloglo($pcnt)]
	set prtype($pcnt) 0

	if {$isint($pcnt)} {
		set lotxt [expr round($actvlo($pcnt))]
		set hitxt [expr round($actvhi($pcnt))]
	} else {
		set lotxt [FiveSigFig $actvlo($pcnt)]
		set hitxt [FiveSigFig $actvhi($pcnt)]
	}
	set lowidth [string length $lotxt]
	if {$lowidth < $evv(RANGEWIDTH)} {
		set lowidth $evv(RANGEWIDTH)
	}
	set hiwidth [string length $hitxt]
	if {$hiwidth < $evv(RANGEWIDTH)} {
		set hiwidth $evv(RANGEWIDTH)
	}
	$prmgrd.rlo$gcnt config -text $lotxt -width $lowidth
	prmgrd.rhi$gcnt config -text $hitxt -width $hiwidth
}

#------ Set up the range determining parameters, for log-slider

proc ReEstablishSimpleLogRange {gcnt pcnt low high thisrow} {
	global lo hi actvlo actvhi isint evv
	global loglo loghi logsublo logsubhi prtype
	global activeloglo activeloghi prmgrd prange
 	set lo($pcnt) $low
 	set hi($pcnt) $high
	set loglo($pcnt) [expr log($lo($pcnt))]
	set loghi($pcnt) [expr log($hi($pcnt))]
 	set actvlo($pcnt) $low
 	set actvhi($pcnt) $high
 	set activeloglo($pcnt) $loglo($pcnt)
 	set activeloghi($pcnt) $loghi($pcnt)
	set prange($pcnt) [expr $activeloghi($pcnt) - $activeloglo($pcnt)]
	set prtype($pcnt) 0

	if {$isint($pcnt)} {
		set lotxt [expr round($actvlo($pcnt))]
		set hitxt [expr round($actvhi($pcnt))]
	} else {
		set lotxt [FiveSigFig $actvlo($pcnt)]
		set hitxt [FiveSigFig $actvhi($pcnt)]
	}
	set lowidth [string length $lotxt]
	if {$lowidth < $evv(RANGEWIDTH)} {
		set lowidth $evv(RANGEWIDTH)
	}
	set hiwidth [string length $hitxt]
	if {$hiwidth < $evv(RANGEWIDTH)} {
		set hiwidth $evv(RANGEWIDTH)
	}
	$prmgrd.rlo$gcnt config -text $lotxt -width $lowidth
	$prmgrd.rhi$gcnt config -text $hitxt -width $hiwidth
}

#------ Set up the range determining parameters

proc ReEstablishRange {gcnt pcnt low high sublow subhigh thisrow dflt} {
	global lo hi sublo subhi actvlo actvhi isint rangetype prmgrd prange partype dfltrangetype evv

 	set lo($pcnt) $low
 	set hi($pcnt) $high
 	set sublo($pcnt) $sublow
 	set subhi($pcnt) $subhigh

 	set actvlo($pcnt) $sublow
 	set actvhi($pcnt) $subhigh

	set prange($pcnt) [expr $actvhi($pcnt) - $actvlo($pcnt)]
	SetPrtype $pcnt
	if {$isint($pcnt)} {
		set lotxt [expr round($actvlo($pcnt))]
		set hitxt [expr round($actvhi($pcnt))]
	} else {
		set lotxt [FiveSigFig $actvlo($pcnt)]
		set hitxt [FiveSigFig $actvhi($pcnt)]
	}
	set lowidth [string length $lotxt]
	if {$lowidth < $evv(RANGEWIDTH)} {
		set lowidth $evv(RANGEWIDTH)
	}
	set hiwidth [string length $hitxt]
	if {$hiwidth < $evv(RANGEWIDTH)} {
		set hiwidth $evv(RANGEWIDTH)
	}
	$prmgrd.rlo$gcnt config -text $lotxt -width $lowidth
	$prmgrd.rhi$gcnt config -text $hitxt -width $hiwidth
}

#--- Display contents of (or edit) any file-parameter, in response to righthand mouse-click

proc ShowFileParam {entrybox pcnt gcnt special edit} {
	global evv brk k_textfilename 

	set valname [$entrybox cget -textvariable]
	upvar $valname val
	if {[string length $val] <= 0} {
		return
	}
	if {[IsNumeric $val]} {
		return
	}
	set fnam [string tolower $val]
	if {![ValidCdpFilename [file rootname $fnam] 0]} {
		return
	}
	if {![ValidCdpExtension [file extension $fnam]]} {
		return
	}
	if {![file exists $fnam]} {
		Inf "If $fnam is a file, it no longer exists"
		return
	}
	if {$edit} {
		set brk(from_wkspace) 0
		if {$special} {
			EditTextfile $fnam special $pcnt $gcnt
		} else {
			EditTextfile $fnam brk $pcnt $gcnt
		}
		set prm($pcnt) $k_textfilename
	} else {
		SimpleDisplayTextfile $fnam
	}
}

proc ValidCdpExtension {ext} {
	global new_user_text_extensions user_text_extensions
	if {[string match $ext ".txt"]} {
		return 1
	}
	if {[info exists new_user_text_extensions]} {
		foreach item $new_user_text_extensions {
			if {[string match $ext $item]} {
				return 1
			}
		}
	} elseif {[info exists user_text_extensions]} {
		foreach item $user_text_extensions {
			if {[string match $ext $item]} {
				return 1
			}
		}
	}
	return 0
}

