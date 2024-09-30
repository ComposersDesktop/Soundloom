#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD 30 June 2013
# ... fixup button rectangles

######################
# CREATING TEXTFILES #
######################

#------ Allow user to create a textfile, and save it
#
#	 ---------------------------------------
#	|Create a Datafile \\\\\\\\\\\\\\\\\\\\\|
#	|---------------------------------------|
#	|  ----  	       ____________  ------ |
#	| |KEEP| filename [____________]|CANCEL||
#	|  ----   					 	 ------ |
#	|  ------------------------------------ |	
#	| |	(textbox)					     | ||
#	| |								     |^||
#	| |								     |_||
#	| |								     | ||
#	| |								     | ||
#	| |								     |_||
#	| |----------------------------------|	|
#	| |						>>		     |	|	
#	|  ----------------------------------   |	
#	 ---------------------------------------

proc Dlg_MakeTextfile {pcnt gcnt} {
	global maketext pr_maketext	textfilename wstk is_file_edit prm from_runpage tstandard tlist evv
	global prmgrd isbrktype wl chlist src rememd renam sl_real search_string freeharm fhd_name fromspace sd
	global readonlyfg readonlybg from_emph emphfnam nessins segment from_gettrof

	set is_file_edit 0
	set save_mixmanage 0
	set nessupdate 0
	set f .maketext

	if [Dlg_Create $f "Create A Datafile" "set pr_maketext 0" -borderwidth $evv(BBDR)] {
		EstablishTextWindow $f 0
	}
#	$f.b.k config -text "K" -width 2 -bd 2 -command "Shortcuts textfile" -bg $evv(HELP) NOT AVAILABLE ON THE MAC
	$f.b.k config -text "" -width 0 -bd 0 -command {}
	$f.z.0.src config -bg [option get . background {}]
	$f.z.0.ss  config -bg [option get . background {}]
	$f.b.undo config -text "" -bd 0 -command {}
#	InstallMeterKeystrokes $f
	set tstandard .maketext.z.z.t
	$tstandard config -state normal
	$tstandard delete 1.0 end
	$tstandard config -state disabled
	set tlist .maketext.k.t
	set search_string ""
	set textfilename ""
	$f.b.ref config -command "RefSee $f.k.t"
	if {[info exists from_gettrof]} {
		.maketext.b.keep config -text "Save Data"
	} else {
		.maketext.b.keep config -text "Save File"
	}
	.maketext.b.cancel config -text "Close"

	if {$pcnt == -1} {
		MakeKeyboardKey $f.b.midi -1 .maketext.k.t
	}
	$f.b.find config -text "" -bd 0 -state disabled
	if {[info exists from_gettrof]} {
		$f.b.l config -text "" 
		$f.b.e config -borderwidth 0 -state disabled -disabledbackground [option get . background {}]
		$f.b.m config -state disabled -borderwidth 0 -text ""
		wm title $f "Create Data"
	} else {
		$f.b.l config -text "filename" 
		$f.b.e config -borderwidth 2 -state normal ;#	Make entrybox active, (ditto)
		$f.b.m config -state normal -borderwidth 2 -text "Standard Names"	;#	Make standardnames active
		wm title $f "Create a Datafile"			;#	Force title (in case window used for brkpoint edit)
	}
	set t $f.k.t
	$t delete 1.0 end

	if [info exists from_emph] {
		set textfilename [file rootname $emphfnam]
		$f.b.e config -state readonly -fg $readonlyfg -bg $readonlybg
	}
	if [info exists textfilename] {
		ForceVal $f.b.e $textfilename
	}
	set pr_maketext 0			
	set finished 0
	raise $f
	My_Grab 0 $f pr_maketext $f.k.t
	while {!$finished} {

		tkwait variable pr_maketext

		if {$pr_maketext} {
#JUNE 30 UC-LC FIX
			if {!$sl_real} {
				Inf "You Can Name And Save The File You Have Created.\nThe Soundloom Will Check Its Syntax And Note Its Type.\nThe File Will Then Be Placed On The Workspace."
				continue
			}
			if {[info exists from_gettrof]} {
				set segment(textdata) [$t get 1.0 end]
				unset from_gettrof
				break
			}
			set textfilename [string tolower $textfilename]
			set textfilename [FixTxt $textfilename "filename"]
			if {[string length $textfilename] <= 0} {
				ForceVal $f.b.e $textfilename
				continue
			}
			if [ValidCDPRootname $textfilename] {		;#	If not a valid name, stays waiting in dialog
				set do_renam 0
				set origtextfilename $textfilename
				if {[HasBrkpntStructure .maketext.k.t 1]} {
					set extt [GetTextfileExtension brk]
				} elseif {[HasNessfileStructure .maketext.k.t 0]} {
					set extname $evv(NESS_EXT)
				} else {
					set extt $evv(TEXT_EXT)
				}
				append textfilename $extt
				if [file exists $textfilename] {
					set it_exists 1
					set choice [tk_messageBox -type yesno -message "File already exists: Overwrite it?" \
							-icon question -parent [lindex $wstk end]]
					if [string match $choice "no"] {
						set textfilename $origtextfilename						
						catch {unset it_exists}
						continue						;#	If file exists, and don't want to overwrite it, 
					}									;#	stays waiting in dialog.
# POSSIBLE CHOSEN FILE OVERWRITE
					if [info exists chlist] {
						set j [lsearch -exact $chlist $textfilename]
						if {$j >= 0} {
							set do_renam 1
						}
					}
				}
				if {$from_runpage && ([info exists isbrktype] && $isbrktype)} {
					if {![TestBrkpnts .maketext.k.t $pcnt]} {
						set textfilename [file rootname $textfilename]
						ForceVal $f.b.e $textfilename
	
						set do_renam 0
						catch {unset it_exists}
						continue
					}
				} elseif {[info exists fromspace] && $fromspace} {
					if {![TestSpacePoints .maketext.k.t]} {
						set textfilename [file rootname $textfilename]
						set sd(edge) $textfilename 
	
						set do_renam 0
						catch {unset it_exists}
						continue
					}
				}
				if [catch {open $textfilename w} fileId] {
					Inf "Cannot open file '$textfilename'";#	If file not opened, stays waiting in dialog
					set do_renam 0
					catch {unset it_exists}
				} else {
					puts -nonewline $fileId "[$t get 1.0 end]"
					close $fileId						;#	Write data to file
					if {[info exists it_exists]} {
						DummyHistory $textfilename "OVERWRITTEN"
						if {$do_renam} {
							set renam 1
						}
						unset it_exists
					} else {
						DummyHistory $textfilename "CREATED"
					}
 					set ii [LstIndx $textfilename $wl]
					if {$ii >= 0} {
						$wl delete $ii
						WkspCntSimple -1
						catch {unset rememd}
					}
					if {[FileToWkspace $textfilename 0 0 0 0 1] <= 0} {
						if [catch {file delete $textfilename} result] {
							ErrShow "Cannot delete invalid file $textfilename"
						} else {
							DummyHistory $textfilename "DESTROYED"
							DeleteFileFromSrcLists $textfilename
						}
						set textfilename [file rootname $textfilename]
						ForceVal $f.b.e $textfilename
						if {[UpdatedIfAMix $textfilename 0]} {
							set save_mixmanage 1
						} elseif {[UpdatedIfANess $textfilename]} {
							set nessupdate 1
						}
						continue
					}
					if {[UpdatedIfAMix $textfilename 0]} {
						set save_mixmanage 1
					} elseif {[UpdatedIfANess $textfilename]} {
						set nessupdate 1
					}
					if {$from_runpage} {
						set prm($pcnt) $textfilename	 	;#	Enter filename as current prm val
						ForceVal $prmgrd.e$gcnt $prm($pcnt)
					} elseif {[info exists fromspace] && $fromspace} {
						set sd(edge) $textfilename
					} elseif {[info exists freeharm]} {
						set fhd_name $textfilename
					}
					set textfilename ""
					ForceVal $f.b.e $textfilename
					set finished 1						;#	And quit dialog
				}
			}
		} else {
			set finished 1								;#	CANCEL: exit dialog
		}
	}
	if {![info exists from_gettrof]} {
		if {[MixMPurge 0]} {
			set save_mixmanage 1
		}
		if {$save_mixmanage} {
			MixMStore
		}
		if {$nessupdate} {
			if {[info exists nessins(0)]} {
				unset nessins(0)
			}
			NessMStore
		}
		catch {close $fileId}
	}
#	UninstallMeterKeystrokes $f
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

#------ create a textfile from the Params Page

proc Dlg_MakeTextfile_Param {pcnt gcnt} {
	global pr_maketextp textfilenamep wstk is_file_editp prm pprg mmod evv
	global prmgrd isbrktype wl chlist src rememd renam sl_real ins standardk pa inside_ins_create snack_enabled
	global sv_dummy sv_dummyname pseudoprog gdg_cnt done_ins_stereo done_ins_stchan

	catch {destroy .cpd}

	set mmode $mmod
	incr mmode -1
	set is_file_editp 0
	set f .maketextp

	if [Dlg_Create $f "Create A Datafile" "set pr_maketextp 0" -borderwidth $evv(BBDR)] {
		set b [frame $f.b]
		set k [frame $f.k]		
		button $b.keep   -text "Save File" -command "set pr_maketextp 1" -highlightbackground [option get . background {}]
		button $b.k -text "" -width 2 -bd 0 -command {} -bg [option get . background {}] -highlightbackground [option get . background {}]
		button $b.stan   -text "" -width 15 -command {} -bd 0 -highlightbackground [option get . background {}]
		frame $b.midi
		button $b.dur    -text "" -width 10 -command {} -bd 0 -highlightbackground [option get . background {}]
		if {$snack_enabled} {
			button $b.sew    -text "" -width 10 -command {} -bd 0 -bg [option get . background {}] -highlightbackground [option get . background {}]
		}
		label  $b.l -text "filename" 
		entry  $b.e -textvariable textfilenamep
		menubutton $b.m -text "Standard Names" -width 17 -menu $b.m.menu -relief raised
		set snames [menu $b.m.menu -tearoff 0]
		MakeStandardNamesMenu $snames .maketextp.b.e 0
		button $b.calc -text "Calculator" -width 8 -command "MusicUnitConvertor 0 0"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
		button $b.ref   -text "Reference" -width 8 -command "RefSee $f.k.t"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
		button $b.cancel -text "Close" -command "set pr_maketextp 0" -highlightbackground [option get . background {}]
		if {$snack_enabled} {
			pack $b.keep $b.k $b.stan $b.midi $b.sew $b.dur $b.l $b.e $b.m -side left -padx 1 -pady 1
		} else {
			pack $b.keep $b.k $b.stan $b.midi $b.dur $b.l $b.e $b.m -side left -padx 1 -pady 1
		}
		pack $b.cancel $b.calc $b.ref -side right -padx 1 -pady 1
		set t [text $k.t -setgrid true -wrap word -width 84 -height 32 \
		-xscrollcommand "$k.sx set" -yscrollcommand "$k.sy set"]
		scrollbar $k.sy -orient vert  -command "$f.k.t yview"
		scrollbar $k.sx -orient horiz -command "$f.k.t xview"
		pack $k.t -side left -fill both -expand true
		pack $k.sy -side right -fill y
		pack $f.b $f.k -side top -fill x
		bind $f.b.e <Up> "AdvanceNameIndex 1 textfilenamep 0"
		bind $f.b.e <Down> "AdvanceNameIndex 0 textfilenamep 0"
		bind $f.b.e <Control-Up> "AdvanceNameIndex 1 textfilenamep 1"
		bind $f.b.e <Control-Down> "AdvanceNameIndex 0 textfilenamep 1"
		bind $f <Escape> "set pr_maketextp 0"
		bind $f <Control-s> "set pr_maketextp 1"
		bind $f <Control-S> "set pr_maketextp 1"
		bind $f <Control-M> "FixedPitchConvert .maketextp.k.t"
	}
	if {![info exists textfilenamep] || ![string match [file rootname $textfilenamep] "temp"]} {
		set textfilenamep ""
	}
	ForceVal $f.b.e $textfilenamep
	$f.b.l config -text "filename" 
	set t $f.k.t
	$t delete 1.0 end
	if {$pprg == $evv(MIXBALANCE)} {
		bind $f.k.t <Control-t> {SampsToTime .maketextp.k.t 0}
		bind $f.k.t <Control-T> {SampsToTime .maketextp.k.t 0}
		bind $f.k.t <Control-a> {PairsToSwaps .maketextp.k.t}
		bind $f.k.t <Control-A> {PairsToSwaps .maketextp.k.t}
	} elseif {$pprg == $evv(AUTOMIX)} {
		bind $f.k.t <Control-t> {SampsToTime .maketextp.k.t 1}
		bind $f.k.t <Control-T> {SampsToTime .maketextp.k.t 1}
	} else {
		bind $f.k.t <Control-t> {SampsToBrkTime .maketextp.k.t}
		bind $f.k.t <Control-T> {SampsToBrkTime .maketextp.k.t}
		bind $f.k.t <Control-a> {}
		bind $f.k.t <Control-A> {}
	}
	if {$pcnt == 0} {
		switch -regexp -- $pprg \
			^$evv(SIMPLE_TEX)$ 	- \
			^$evv(TEX_MCHAN)$ 	- \
			^$evv(GROUPS)$ 		- \
			^$evv(DECORATED)$ 	- \
			^$evv(PREDECOR)$ 	- \
			^$evv(POSTDECOR)$ 	- \
			^$evv(ORNATE)$ 		- \
			^$evv(PREORNATE)$ 	- \
			^$evv(POSTORNATE)$ 	- \
			^$evv(MOTIFS)$ 		- \
			^$evv(MOTIFSIN)$ 	- \
			^$evv(TIMED)$ 		- \
			^$evv(TGROUPS)$ 	- \
			^$evv(TMOTIFS)$ 	- \
			^$evv(TMOTIFSIN)$ {
				$f.b.stan config -text "Standard Features" -command "StandardTextureFeatures" -bd 2 -state normal
				MakeKeyboardKey .maketextp.b.midi $evv(MIDITEXTURE) .maketextp.k.t
			} \
			^$evv(GREQ)$ 	 - \
			^$evv(P_INVERT)$ - \
			^$evv(P_INSERT)$ - \
			^$evv(P_SINSERT)$ - \
			^$evv(P_SYNTH)$  - \
			^$evv(P_VOWELS)$ - \
			^$evv(VFILT)$ - \
			^$evv(P_GEN)$ - \
			^$evv(MIX_ON_GRID)$ - \
			^$evv(AUTOMIX)$ - \
			^$evv(MIXBALANCE)$ - \
			^$evv(SPLIT)$ 	 - \
			^$evv(FLTBANKU)$ - \
			^$evv(FLTITER)$ - \
			^$evv(FLTBANKV)$ - \
			^$evv(SYNFILT)$ - \
			^$evv(FLTBANKV2)$ - \
			^$evv(DEL_PERM)$ - \
			^$evv(DISTORT_HRM)$ - \
			^$evv(DISTORT_PULSED)$ - \
			^$evv(EDIT_CUTMANY)$ - \
			^$evv(MANY_ZCUTS)$ - \
			^$evv(STACK)$ - \
			^$evv(SYLLABS)$ - \
			^$evv(JOIN_SEQ)$ - \
			^$evv(JOIN_SEQDYN)$ - \
			^$evv(DEL_PERM2)$ - \
			^$evv(FREEZE)$ - \
			^$evv(FREEZE2)$ - \
			^$evv(GRAIN_REMOTIF)$ - \
			^$evv(ENV_CREATE)$ - \
			^$evv(BATCH_EXPAND)$ - \
			^$evv(TWIXT)$ - \
			^$evv(SPHINX)$ - \
			^$evv(MULTI_SYN)$ - \
			^$evv(GRAIN_GET)$ - \
			^$evv(TAPDELAY)$ - \
			^$evv(MCHANPAN)$ - \
			^$evv(FRAME)$ - \
			^$evv(FLUTTER)$ - \
			^$evv(MCHSTEREO)$ - \
			^$evv(RMVERB)$ - \
			^$evv(PULSER3)$ - \
			^$evv(NEWTEX)$ - \
			^$evv(MADRID)$ - \
			^$evv(SHIFTER)$ - \
			^$evv(FRACTURE)$ - \
			^$evv(SPEKLINE)$ - \
			^$evv(ROTOR)$ - \
			^$evv(TESSELATE)$ - \
			^$evv(CRYSTAL)$ - \
			^$evv(CASCADE)$ - \
			^$evv(FRACTAL)$ - \
			^$evv(FRACSPEC)$ - \
			^$evv(REPEATER)$ - \
			^$evv(VERGES)$ - \
			^$evv(MOTOR)$ - \
			^$evv(STUTTER)$ - \
			^$evv(DISTMARK)$ - \
			^$evv(SUPPRESS)$ - \
			^$evv(SCRUNCH)$ {
					$f.b.stan config -text "Standard Features" -command "StandardSpecialFeatures" -bd 2 -state normal
			} \
			^$evv(SPECFNU)$ {
				if {($mmode == 6) || ($mmode == 14) || ($mmode == 16) || ($mmode == 17) || ($mmode == 22)} {
					$f.b.stan config -text "Standard Features" -command "StandardSpecialFeatures" -bd 2 -state normal
				}
			} \
			^$evv(CERACU)$ {
				$f.b.stan config -text "Standard Features" -command "StandardSpecialFeatures" -bd 2 -state normal
			} \
			^$evv(SYNTHESIZER)$ {
				if {$mmode != $evv(SYNTH_SPIKES)} {
					$f.b.stan config -text "Standard Features" -command "StandardSpecialFeatures" -bd 2 -state normal
				}
			} \
			^$evv(SEQUENCER)$ - \
			^$evv(SEQUENCER2)$ {
				$f.b.stan config -text "Standard Features" -command "StandardSpecialFeatures" -bd 2 -state normal
				MakeKeyboardKey .maketextp.b.midi $evv(MIDISEQUENCER) .maketextp.k.t
			} \
			^$evv(GREV)$ {
				if {$mmode == $evv(GREV_GET)} {
					$f.b.stan config -text "Standard Features" -command "StandardSpecialFeatures" -bd 2 -state normal
				}
			} \
			^$evv(CLICK)$ {
				$f.b.stan config -text "Standard Features" -command "StandardSpecialFeatures" -bd 2 -state normal
				$f.b.k config -text "K" -width 2 -bd 2 -command "Shortcuts textfile" -bg $evv(HELP)
#				InstallMeterKeystrokes $f
			} \
			^$evv(ZIGZAG)$ {
				$f.b.k config -text "K" -width 2 -bd 2 -command "Shortcuts textfile" -bg $evv(HELP)
				bind $f <Control-1> {}
				bind $f <Control-1> "BracketList $f"
			} \
			^$evv(DISTORT_ENV)$ {
				if {$mmode == $evv(DISTORTE_USERDEF)} {
					$f.b.stan config -text "Standard Features" -command "StandardSpecialFeatures" -bd 2 -state normal
				}
			} \
			^$evv(ENVSYN)$ {
				if {$mmode == $evv(ENVSYN_USERDEF)} {
					$f.b.stan config -text "Standard Features" -command "StandardSpecialFeatures" -bd 2 -state normal
				}
			} \
			^$evv(TUNE)$ {
				MakeKeyboardKey .maketextp.b.midi $evv(MIDIPITCHES) .maketextp.k.t
			} \
			^$evv(PULSER2)$ - \
			^$evv(PULSER)$ {
				if {$mmode == 2} {
					$f.b.stan config -text "Standard Features" -command "StandardSpecialFeatures" -bd 2 -state normal
				}
			} \
			default {
				$f.b.stan config -text "" -command {} -bd 0 -state disabled
			}

	} elseif {($pprg == $evv(RETIME)) && ($mmode == 1) && ($pcnt == 2)} {
		$f.b.stan config -text "From Ideal Times" -command GetIntermediateIdealRealtimes -bd 2 -state normal
	} else {
		$f.b.stan config -text "" -command {} -bd 0 -state disabled
	}
	if {[MidiBrkable $pcnt]} {
		MakeKeyboardKey $f.b.midi -1 .maketextp.k.t
	} elseif {[MidiFiltData $pcnt]} {
		MakeKeyboardKey .maketextp.b.midi $evv(MIDIFILT) .maketextp.k.t
	}
	$f.b.dur config -text "" -command {} -bd 0 -state disabled
	if {[info exists chlist] && ([llength $chlist] > 0)} {
		set fnam [lindex $chlist 0]
		set ftypp $pa($fnam,$evv(FTYP))
		if {$ftypp & $evv(IS_A_SNDSYSTEM_FILE)} {
			set dur [SecOrSampDur $fnam]
			$f.b.dur config -text "Duration" -command ".maketextp.k.t insert end $dur" -bd 2 -state normal
		}
		if {$snack_enabled} {
			if {($ftypp == $evv(SNDFILE))} {
				if {$pprg == $evv(ISOLATE)} {
					switch -- $mmode {
						0 -
						1 {
							catch {.maketextp.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_TIMEPAIRS) .maketextp.k.t $evv(TIME_OUT) $pcnt" -bd 2 -state normal -bg $evv(SNCOLOR)}
						}
						2 {
							catch {.maketextp.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_BRKPNTPAIRS) .maketextp.k.t $evv(TIME_OUT) $pcnt" -bd 2 -state normal -bg $evv(SNCOLOR)}
						}
						default {
							catch {.maketextp.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_TIMESLIST) .maketextp.k.t $evv(TIME_OUT) $pcnt" -bd 2 -state normal -bg $evv(SNCOLOR)}
						}
					}
				} elseif {$isbrktype} {
					if {($pprg == $evv(HOVER))} {
						if {$pcnt == 1} {
							$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_TIMESLIST) .maketextp.k.t $evv(TIME_OUT) $pcnt" -bd 2 -state normal -bg $evv(SNCOLOR)
						}
					} elseif {[EstablishAnyNecessarySoundViewDummyFile $fnam $pcnt]} {
						$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_BRKPNTPAIRS) .maketextp.k.t $evv(TIME_OUT) $pcnt" -bd 2 -state normal -bg $evv(SNCOLOR)
					} elseif {($pprg == $evv(DRUNKWALK)) && ($pcnt == 1)} {
						$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_UNSORTED_TIMES) .maketextp.k.t $evv(TIME_OUT) $pcnt" -bd 2 -state normal -bg $evv(SNCOLOR)
					}
				} elseif [IsMultiEditType $pprg] {
					if {[info exists pseudoprog] && (($pseudoprog == $evv(SLICE)) || ($pseudoprog == $evv(SNIP)))} {
						switch -- $mmod {
							0 -
							1 {
								$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_TIMESLIST) .maketextp.k.t $evv(TIME_OUT) 0" -bd 2 -state normal -bg $evv(SNCOLOR)
							}
							2 {
								$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_TIMESLIST) .maketextp.k.t $evv(SMPS_OUT) 0" -bd 2 -state normal -bg $evv(SNCOLOR)
							}
							3 {
								$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_TIMESLIST) .maketextp.k.t $evv(GRPS_OUT) 0" -bd 2 -state normal -bg $evv(SNCOLOR)
							}
						}
					} elseif {$pprg == $evv(FOFEX_EX)} {
						if {$mmod == 1} {
							$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_TIMEPAIRS) .maketextp.k.t $evv(GRPS_OUT) 0" -bd 2 -state normal -bg $evv(SNCOLOR)
						}						
					} elseif {$pprg == $evv(TWEET)} {
						$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_TIMEPAIRS) .maketextp.k.t $evv(GRPS_OUT) 0" -bd 2 -state normal -bg $evv(SNCOLOR)
					} elseif {$pprg == $evv(SUPPRESS)} {
						$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_TIMEPAIRS) .maketextp.k.t $evv(TIME_OUT) 0" -bd 2 -state normal -bg $evv(SNCOLOR)
					} else {
						switch -- $mmod {
							0 -
							1 {
								$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_TIMEPAIRS) .maketextp.k.t $evv(TIME_OUT) 0" -bd 2 -state normal -bg $evv(SNCOLOR)
							}
							2 {
								$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_TIMEPAIRS) .maketextp.k.t $evv(SMPS_OUT) 0" -bd 2 -state normal -bg $evv(SNCOLOR)
							}
							3 {
								$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_TIMEPAIRS) .maketextp.k.t $evv(GRPS_OUT) 0" -bd 2 -state normal -bg $evv(SNCOLOR)
							}
						}
					}
				} elseif [IsTimesListType $pprg $mmod] {
					switch -- $mmod {
						0 -
						1 {
							$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_TIMESLIST) .maketextp.k.t $evv(TIME_OUT) 0" -bd 2 -state normal -bg $evv(SNCOLOR)
						}
						2 {
							$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_TIMESLIST) .maketextp.k.t $evv(SMPS_OUT) 0" -bd 2 -state normal -bg $evv(SNCOLOR)
						}
						3 {
							$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_TIMESLIST) .maketextp.k.t $evv(GRPS_OUT) 0" -bd 2 -state normal -bg $evv(SNCOLOR)
						}
					}
				} elseif [IsOtherTimesListType $pprg $mmod] {
					$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_TIMESLIST) .maketextp.k.t $evv(TIME_OUT) 0" -bd 2 -state normal -bg $evv(SNCOLOR)
				} elseif [IsTimesListTypeWithMultipleInfiles $pprg $mmod] {
					$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_MULTIFILES) .maketextp.k.t $evv(TIME_OUT) 0" -bd 2 -state normal -bg $evv(SNCOLOR)
				} elseif [IsTimedDataFile $pprg $pcnt] {
					$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_BRKPNT_TIMEONLY) .maketextp.k.t $evv(TIME_OUT) 0" -bd 2 -state normal -bg $evv(SNCOLOR)
				} elseif [IsZigZag $pprg $mmod $pcnt] {
					$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_UNSORTED_TIMES) .maketextp.k.t $evv(TIME_OUT) 0" -bd 2 -state normal -bg $evv(SNCOLOR)
				} else {
					$f.b.sew config -text "" -command {} -bd 0 -bg [option get . background {}]
				}
			} elseif [IsMultiEditPitchfileType $pprg] {
				switch -- $mmod {
					1 {
						$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_TIMEPAIRS) .maketextp.k.t $evv(TIME_OUT) 0" -bd 2 -state normal -bg $evv(SNCOLOR)
					}
					2 {
						$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_TIMEPAIRS) .maketextp.k.t $evv(SMPS_OUT) 0" -bd 2 -state normal -bg $evv(SNCOLOR)
					}
				}
			} elseif [IsBrkpntDataWithSpecialProperties $pprg $pcnt] {
				$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_BRKPNT_TIMEONLY) .maketextp.k.t $evv(TIME_OUT) 0" -bd 2 -state normal -bg $evv(SNCOLOR)
			} elseif [IsTimesListTypeWithExtraCharacters $pprg $pcnt] {
				$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_WITHALPHA) .maketextp.k.t $evv(TIME_OUT) 0" -bd 2 -state normal -bg $evv(SNCOLOR)
			} elseif {[IsMultiEditType $pprg]} {
				$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_TIMESLIST) .maketextp.k.t $evv(TIME_OUT) 0" -bd 2 -state normal -bg $evv(SNCOLOR)
				;# NB TSTRETCH is ONLY analfile based prog which "IsMultiEditType"
			} elseif {$isbrktype && [SrcFileExists]} {	
				$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_BRKPNTPAIRS) .maketextp.k.t $evv(TIME_OUT) $pcnt" -bd 2 -state normal -bg $evv(SNCOLOR)
			} elseif {$pprg == $evv(SPECFNU)} {
				switch -- $mmode {
					0 -
					1 -
					2 -
					3 -
					9 {		;#	F_NARROW, F_SQUEEZE, F_INVERT, F_ROTATE, F_ARPEG
						if {$gcnt == 0} {
							$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_BRKPNTPAIRS) .maketextp.k.t $evv(TIME_OUT) $pcnt" -bd 2 -state normal -bg $evv(SNCOLOR)
						}
					}
					6 {		;#	F_MAKEFILT
						if {$gcnt == 0} {
							$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_TIMESLIST) .maketextp.k.t $evv(TIME_OUT) 0" -bd 2 -state normal -bg $evv(SNCOLOR)
						}
					}
					7 -
					8 {		;#	F_MOVE, F_MOVE2
						if {$gcnt < 4} {
							$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_BRKPNTPAIRS) .maketextp.k.t $evv(TIME_OUT) $pcnt" -bd 2 -state normal -bg $evv(SNCOLOR)
						}
					}
					10 -
					11 -
					12 -
					13 -
					18 {	;# F_OCTSHIFT, F_TRANS, F_FRQSHIFT, F_RESPACE, F_PCHRAND
						if {($gcnt == 0) || ($gcnt == 4)} {
							$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_BRKPNTPAIRS) .maketextp.k.t $evv(TIME_OUT) $pcnt" -bd 2 -state normal -bg $evv(SNCOLOR)
						}
					} 
					14 {	;# F_PINVERT
						if {($gcnt == 1) || ($gcnt == 5)} {
							$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_BRKPNTPAIRS) .maketextp.k.t $evv(TIME_OUT) $pcnt" -bd 2 -state normal -bg $evv(SNCOLOR)
						}
					}
					15 {	;# F_PEXAGG
						if {($gcnt == 0) || ($gcnt == 1) || ($gcnt == 5)} {
							$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_BRKPNTPAIRS) .maketextp.k.t $evv(TIME_OUT) $pcnt" -bd 2 -state normal -bg $evv(SNCOLOR)
						}
					}
					16 {	;# F_PQUANT
						if {$gcnt == 5} {
							$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_BRKPNTPAIRS) .maketextp.k.t $evv(TIME_OUT) $pcnt" -bd 2 -state normal -bg $evv(SNCOLOR)
						}
					}
					17 {	;# F_PCHRAND
						if {($gcnt == 1) || ($gcnt == 2) || ($gcnt == 6)} {
							$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_BRKPNTPAIRS) .maketextp.k.t $evv(TIME_OUT) $pcnt" -bd 2 -state normal -bg $evv(SNCOLOR)
						}
					}
					22 {	;# F_SINUS
						if {($gcnt == 1) || ($gcnt >= 3)} {
							$f.b.sew config -text "Snd View" -command "SnackDisplay $evv(SN_BRKPNTPAIRS) .maketextp.k.t $evv(TIME_OUT) $pcnt" -bd 2 -state normal -bg $evv(SNCOLOR)
						}
					}
				}
			} else {
				$f.b.sew config -text "" -command {} -bd 0 -bg [option get . background {}]
			}
		}
	}
	set pr_maketextp 0			
	set finished 0
	raise $f
	My_Grab 0 $f pr_maketextp $f.k.t
	while {!$finished} {
		tkwait variable pr_maketextp
		if {$pr_maketextp} {
			if {!$sl_real} {
				Inf "You Can Name And Save The File You Have Created.\nThe Soundloom Will Check Its Syntax.\nIf It Is Valid For The Current Process, It Will Become The Parameter Value\nOn The Parameters Page."
				continue
			}
#JUNE 30 UC-LC FIX
			set textfilenamep [string tolower $textfilenamep]
			set textfilenamep [FixTxt $textfilenamep "filename"]
			if {[string length $textfilenamep] <= 0} {
				ForceVal $f.b.e $textfilenamep
				continue
			}
			if [ValidCDPRootname $textfilenamep] {		;#	If not a valid name, stays waiting in dialog
				set do_renam 0
				set origtextfilename $textfilenamep
				if {[HasBrkpntStructure .maketextp.k.t 1]} {
					set eextt [GetTextfileExtension brk]
				} else {
					set eextt $evv(TEXT_EXT)
				}
				append textfilenamep $eextt
				if [file exists $textfilenamep] {
					set it_exists 1
					if {![string match [file rootname $textfilenamep] "temp"]} {
						set choice [tk_messageBox -type yesno -message "File already exists: Overwrite it?" \
								-icon question -parent [lindex $wstk end]]
						if [string match $choice "no"] {
							set textfilenamep $origtextfilename						
							catch {unset it_exists}
							continue						;#	If file exists, and don't want to overwrite it, 
						}									;#	stays waiting in dialog.
					}
					if [info exists chlist] {
						set j [lsearch -exact $chlist $textfilenamep]
						if {$j >= 0} {
							set do_renam 1
						}
					}
				}
				if {[info exists isbrktype] && $isbrktype} {
					if {![TestBrkpnts .maketextp.k.t $pcnt]} {
						set textfilenamep [file rootname $textfilenamep]
						ForceVal $f.b.e $textfilenamep
						set do_renam 0
						catch {unset it_exists}
						continue
					}
				}
				if [catch {open $textfilenamep w} fileId] {
					Inf "Cannot open file '$textfilenamep'"	;#	If file not opened, stays waiting in dialog
					set do_renam 0
					catch {unset it_exists}
				} else {
					puts -nonewline $fileId "[$t get 1.0 end]"
					close $fileId						;#	Write data to file
					if {[info exists it_exists]} {
						if {$ins(create)} {
							set inside_ins_create 1
						}
						DummyHistory $textfilenamep "OVERWRITTEN"
						if {$do_renam} {
							set renam 1
						}
						catch {unset inside_ins_create}
						unset it_exists
					} else {
						if {$ins(create)} {
							set inside_ins_create 1
						}
						DummyHistory $textfilenamep "CREATED"
						catch {unset inside_ins_create}
					}
 					set ii [LstIndx $textfilenamep $wl]
					if {$ii >= 0} {
						$wl delete $ii
						WkspCntSimple -1
						catch {unset rememd}
					}
					if {[FileToWkspace $textfilenamep 0 0 0 0 1] <= 0} {
						if [catch {file delete $textfilenamep} result] {
							ErrShow "Cannot delete invalid file $textfilenamep"
						} else {
							if {$ins(create)} {
								set inside_ins_create 1
							}
							DummyHistory $textfilenamep "DESTROYED"
							catch {unset inside_ins_create}
							DeleteFileFromSrcLists $textfilenamep
						}
						set textfilenamep [file rootname $textfilenamep]
						ForceVal $f.b.e $textfilenamep
						continue
					}
					set prm($pcnt) $textfilenamep	 	;#	Enter filename as current prm val
					ForceVal $prmgrd.e$gcnt $prm($pcnt)
					set do_stereo 0
					if {[info exists ins(run)] && $ins(run) && ($gdg_cnt > [expr $pcnt + 1]) && ([string first "stereo" $ins(name)] >= 0)} {
						if {$done_ins_stchan == $pcnt} {
							set done_ins_stereo 0
						}
						if {!$done_ins_stereo} {
							if {[info exists chlist] && ([llength $chlist] == 1) && ($pa([lindex $chlist 0],$evv(CHANS)) == 2)} {
								set msg "Set next parameter to same value ??"
								set choice [tk_messageBox -type yesno -message $msg -parent [lindex $wstk end] -icon question]
								if {$choice == "yes"} {
									set do_stereo 1
								}
							}
						}
					}
					if {$do_stereo} {
						set done_ins_stchan $pcnt
						incr pcnt
						incr gcnt
						set prm($pcnt) $textfilenamep	 	;#	Enter filename as current prm val
						ForceVal $prmgrd.e$gcnt $prm($pcnt)
						set done_ins_stereo 1
					}
					set textfilenamep [file rootname $textfilenamep]
					ForceVal $f.b.e $textfilenamep
					set finished 1						;#	And quit dialog
				}
			}
		} else {
			set finished 1								;#	CANCEL: exit dialog
		}
	}
	set standardk 0
#	UninstallMeterKeystrokes $f
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
	if {[info exists sv_dummy]} {
		catch {file delete $sv_dummyname}
		unset sv_dummy
	}
}

#####################
# TEXTFILE EDITING	#
#####################

#------ Allow user to edit a textfile or brkfile, and save it

proc EditTextfile {fnam type pcnt gcnt} {
	global good_res has_just_fine_tuned wstk is_file_edit brk
	
	set brk(short_table) 0
	set brk(could_be_short_table) 0
	set is_file_edit 1	

	set has_just_fine_tuned 0
	set good_res 1
	switch -- $type {
		"seg" - 
		"special" {
			Dlg_EditTextfile $fnam $gcnt $pcnt $type
		}
		"allbrk" -
		"allbrk_wk" -
		"mchrot" -
		"brk" {
			set do_brk [Dlg_ChooseFiletypeToEdit]
			if $do_brk {
				set good_brkfile [Dlg_EditBrkfile $fnam $pcnt $gcnt]
				if {$good_brkfile >= 0} {
					if {!$brk(from_wkspace) && !$has_just_fine_tuned && !$good_res && $brk(could_be_short_table)} {
						set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] \
							-message "Would you like to edit '$fnam' without reference to the chosen process file duration?"]
						if {$choice == "yes"} {
							set brk(short_table) 1
							set good_brkfile [Dlg_EditBrkfile $fnam $gcnt $pcnt]
						}
						set brk(could_be_short_table) 0
					}
				}
				if {($good_brkfile < 0) || (!$has_just_fine_tuned && !$good_res)} {
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] \
						-message "Would you like to edit '$fnam' as a text file?"]
					if {$choice == "yes"} {
						Dlg_EditTextfile $fnam $gcnt $pcnt brk
					}
				}
			} else {
				Dlg_EditTextfile $fnam $gcnt $pcnt brk
			}
		}
		default {
			ErrShow "Unknown type in EditTextfile"
		}
	}
	set is_file_edit 0
}	

#------ Allow user to edit a textfile, and save it

proc Dlg_EditTextfile {fnam gcnt pcnt typ} {
	global maketext pr_maketext	textfilename ch wl wstk parname brk sfffl src search_string textorig evv
	global rememd text_filecnt tstandard tlist ins from_batchedit set edit_badbrk inside_ins_create
	global user_text_extensions mixmanage snack_enabled tv_active pprg sv_dummy sv_dummyname k_textfilename nesstype
		   
	catch {unset edit_badbrk}
	set f .maketext
	if [Dlg_Create $f "" "set pr_maketext 0" -borderwidth $evv(BBDR)] {
		EstablishTextWindow $f 1
	}
#	$f.b.k config -text "K" -width 2 -bd 2 -command "Shortcuts textfile" -bg $evv(HELP)	NOT AVAILABLE ON THE MAC
	$f.b.k config -text "" -width 0 -bd 0 -command {}
	$f.b.find config -text "" -bd 0 -state disabled -bg [option get . background {}]
	$f.b.undo config -text "Undo" -bd 2 -state normal -command "set pr_maketext 2"
	if {$gcnt >= 0} {
		bind $f.k.t <Command-Up> {MoveValByOct .maketext.k.t 1}
		bind $f.k.t <Command-Down> {MoveValByOct .maketext.k.t 0} 
		if {$snack_enabled} {
			SetUpSndViewEdit $typ $pcnt
		} else {
			.maketext.b.find config -text "" -command {} -bd 0 -bg [option get . background {}]
		}
		if {$tv_active && ($pprg == $evv(FLTBANKV))} {
			MakeKeyboardKey .maketext.b.kbd  -2 .maketext.k.t
		} else {
			catch {.maketext.b.kbd config -text "" -command {} -bd 0 -bg [option get . background {}]}
		}
	}
	$f.z.0.src config -bg [option get . background {}]
	$f.z.0.ss  config -bg [option get . background {}]
#	InstallMeterKeystrokes $f
	set tstandard .maketext.z.z.t
	$tstandard config -state normal
	$tstandard delete 1.0 end
	$tstandard config -state disabled
	set tlist .maketext.k.t
	set search_string ""
	$f.b.ref config -command "RefSee $f.k.t"
	if {$brk(from_wkspace)} {
		wm title $f "Edit a Datafile"					;#	Force title (in case window used for brkpoint edit)
	} else {
		if {$gcnt >= 0} {
			set par_name [StripName	$parname($gcnt)]
			wm title $f "Edit a Datafile for $par_name"		;#	Force title (in case window used for brkpoint edit)
		} else {
			wm title $f "Edit a Datafile"					;#	Force title
		}
	}	
	$f.b.l config -text "filename" 
	$f.b.e config -state normal -borderwidth 2	;#	Make entrybox active, (ditto)
	$f.b.m config -state normal -borderwidth 2 -text "Standard Names"	;#	Make standardnames, active

	.maketext.b.keep config -text "Keep Changes"
	.maketext.b.cancel config -text "Leave Unchanged"
	set t $f.k.t
	$t delete 1.0 end					  				;#	Clear any existing text in window
	set orig_fullname $fnam
	set orig_shortname [file tail $fnam]
	set extname [file extension $fnam]
	if {$extname == $evv(NESS_EXT)} {
		if {[info exists nesstype($fnam)]} {
			set intyp $nesstype($fnam)
		} else {
			set intyp 0
		}
		set is_nessfile 1
	} else {
		set is_nessfile 0
	}
	set textfilename [file rootname $orig_shortname]
	set infdir [file dirname $fnam]
	if {[string length $infdir] <= 1} {
		set infdir ""
	}
	ForceVal $f.b.e $textfilename
	set orig_rootname $textfilename
	if [catch {open $fnam r} fileId] {
		Inf "Cannot open file '$fnam' to edit it."	;#	Open the textfile
		Dlg_Dismiss $f
		if {[info exists sv_dummy]} {
			catch {file delete $sv_dummyname}
			unset sv_dummy
		}
		return
	}
	catch {unset textorig}
	set qq 0
	set save_mixmanage 0
	set nessupdate 0
	while {[gets $fileId line] >= 0} {					;#	Put contents of file into window, avoiding extra newline
		lappend textorig $line
		if {$qq > 0} {
			$t insert end "\n"
		}
		$t insert end "$line"
		incr qq
	}
	close $fileId
	set pr_maketext 0
	set finished 0
	raise $f
	My_Grab 0 $f pr_maketext
	if {[string match $typ "ideas"]} {
		set x 0
		after 100 {set x 0}
		vwait x
		.maketext.k.t yview moveto 1.0
	}
	while {!$finished} {
		tkwait variable pr_maketext					;#	stay in window, editing text, or renaming file
		switch -- $pr_maketext {
			1 {
				catch {unset brkchecked}
				set badbrk 0
				if {$typ == "brk"} {
					set k [IsValidSyntaxBrkfile $t $pcnt $gcnt]
					if {$k <= 0} {
						if {$k == 0} {
							set msg "File Is Out Of Range For The Range Settings Of The Current Application: Keep It Anyway ?"
						} else {
							set msg "File Is No Longer A Valid Brkpoint File: Keep It Anyway ?"
						}
						set choice [tk_messageBox -type yesno -message $msg -parent [lindex $wstk end] -icon question]
						if {$choice == "no"} {
							continue
						} else {
							set badbrk 1
							if {$k < 0} {
								set extname $evv(TEXT_EXT)
							}
						}
					}
					set brkchecked 1
				}
				set OK 1
				if {$is_nessfile} {
					if {[HasNessfileStructure $t 0]} {
						set extname $evv(NESS_EXT)
					} else {
						set msg "DATA IS NO LONGER IN VALID PHYSICAL MODELLING FORMAT: KEEP IT ??"
						set choice [tk_messageBox -type yesno -message -default no $msg -parent [lindex $wstk end] -icon question]
						if {$choice == "yes"} {
							set is_nessfile 0
							set extname $evv(TEXT_EXT)
						} else {
							continue
						}
					} 
				} else {
					if {[HasNessfileStructure $t 0]} {
						set extname $evv(NESS_EXT)
						set is_nessfile 1
					} else {
						set extname $evv(TEXT_EXT)
					}
				}
				if {![info exists brkchecked] && !$is_nessfile && [info exists user_text_extensions]} {
					foreach zob $user_text_extensions {
						if {[string match $zob $extname]} {
							set msg "Does New File Have Correct Syntax For A '$zob' File ??"
							set choice [tk_messageBox -type yesno -message $msg -parent [lindex $wstk end] -icon question]
							if {$choice == "no"} {
								set msg "Change Filename To Standard '$evv(TEXT_EXT)' Extension??"
								set choice [tk_messageBox -type yesno -message $msg -parent [lindex $wstk end] -icon question]
								if {$choice == "no"} {
									set OK 0
									break
								} else {
									set extname $evv(TEXT_EXT)
								}
							}
						}
					}				
					if {!$OK} {
						break
					}
				}
				set i 0
				set textfilename [string tolower $textfilename]
				set checkname [file join  $infdir $textfilename$extname]
				if [ValidCDPRootname $textfilename] {		;#	If not a valid filename, stays waiting in dialog
					set do_overwrite_orig 0
					if {[string match $orig_fullname $checkname]} {					;# IF output name is the name of the file being edited ?
						if {[string match $orig_rootname "temp"] || [string match $typ "ideas"]} {
							set fnam $orig_fullname									;# DO overwrite of any file called 'temp' and any props-ideas file
							set do_overwrite_orig 1									;# ELSE ask user..
						} else {			
							set choice [tk_messageBox -type yesno -message "Overwrite original file?" -parent [lindex $wstk end] -icon question]
							if {$choice == "no"} {
									continue										;# DONT overwrite
							} else {
								set fnam $orig_fullname								;# DO overwrite
								set do_overwrite_orig 1
							}
						}
					} else {
						set fnam $textfilename$extname
					}
					set not_exist 1
					if [file exists $fnam] {									;# Does file with name of output-file already exist ?	
						catch {unset not_exist}
						if {!$is_nessfile} {
							set j [LstIndx $fnam $ch]
							if {$j >= 0} {
								Inf "File is a selected file for this process: cannot be overwritten now"
								continue													
							}
						}				;#	IF already-existing-file NOT file-being-edited (checked above): and it is not called 'temp', Ask user ...
						if {![string match $orig_fullname $checkname] && ![string match $textfilename "temp"]} {
							set choice [tk_messageBox -type yesno -message "A file called '$fnam' already exists : Overwrite it?" \
										 -parent [lindex $wstk end] -icon question]
							if {$choice == "no"} {
								continue
							}
						}
 						if {![DeleteFileFromSystem $fnam 1 0]} {
							continue
						}
						if {[info exists mixmanage($fnam)]} {
							unset mixmanage($fnam)
							set save_mixmanage 1
						}
						if {[info exists nesstype($fnam)]} {
							PurgeNessData $fnam
							set nessupdate 1
						}
						if {$do_overwrite_orig} {
							if {$ins(create)} {
								set inside_ins_create 1
							}
							DummyHistory $fnam "EDITED"
							catch {unset inside_ins_create}
						} else {
							if {$ins(create)} {
								set inside_ins_create 1
							}
							DummyHistory $fnam "OVERWRITTEN"
							catch {unset inside_ins_create}
						}
						$wl delete [LstIndx $fnam $wl]
						WkspCntSimple -1
						if {[info exists sfffl]} {
							set t_t [LstIndx $fnam $sfffl]
							if {$t_t >= 0} {
								$sfffl delete $t_t 
								incr text_filecnt -1
								$sfffl selection clear 0 end
							}
						}
						catch {unset rememd}
					}
					if [catch {open $fnam w} fileId] {
						Inf "$fileId"
					   Inf "Cannot open file '$textfilename'"
					} else {
						puts -nonewline $fileId "[$t get 1.0 end]"
						close $fileId						;#	Write data to file
						if {[info exists not_exist]} {
							if {$ins(create)} {
								set inside_ins_create 1
							}
							DummyHistory $fnam "CREATED"
							catch {unset inside_ins_create}
							unset not_exist
						}
						if {[FileToWkspace $fnam 0 0 0 0 1] <= 0} {	 		
							if [catch {file delete $fnam} result] {
								ErrShow "Cannot delete invalid file $fnam"
								if {[UpdatedIfAMix $fnam 0]} {	;#	UPDATE MIXMANAGER IF NECESSARY, EVEN IF FileToWkspace FAILS
									set save_mixmanage 1
								} elseif {[UpdatedIfANess $fnam]} {
									set nessupdate 1
								}
							}
							if {$ins(create)} {
								set inside_ins_create 1
							}
							DummyHistory $fnam "DESTROYED"
							catch {unset inside_ins_create}
							DeleteFileFromSrcLists $fnam
							continue						;#	Put file on workspace, only if valid file
						}
						if {[UpdatedIfAMix $fnam 0]} {			;#	UPDATE MIXMANAGER IF NECESSARY
							set save_mixmanage 1
						} elseif {[UpdatedIfANess $fnam]} {
							set nessupdate 1
						}
						if {[info exists sfffl]} {
							$sfffl insert 0 $fnam
							incr text_filecnt
							$sfffl selection clear 0 end
							$sfffl selection set 0
						}
						set from_batchedit $fnam
						set textfilename ""					
						ForceVal $f.b.e $textfilename
						set finished 1						;#	and exit dialog
					}
					if {$badbrk} {
						set edit_badbrk $fnam
					} else {
						catch {unset edit_badbrk}
					}
				}
			}
			2 {
				$t delete 1.0 end
				set qq 0
				foreach line $textorig {			;#	Restore original contents
					if {$qq > 0} {
						$t insert end "\n"
					}
					$t insert end "$line"
					incr qq
				}
			}
			0 {
				set finished 1								;#	CANCEL: exit dialog
			}
		}
	}
	if {[MixMPurge 0]} {		 ;#	CHECK FOR MIXFILE DELETIONS
		set save_mixmanage 1
	}
	if {$save_mixmanage} {
		MixMStore
	}
	if {$nessupdate} {
		NessMStore
	}
#	UninstallMeterKeystrokes $f
	My_Release_to_Dialog $f	 							;#	Return to calling dialog
	Dlg_Dismiss $f
	destroy $f
	set k_textfilename $fnam
	if {[info exists sv_dummy]} {
		catch {[file delete $sv_dummyname]}
		unset sv_dummy
	}
}

#------ Setup a window to enter and or edit text

proc EstablishTextWindow {f withsound} {
	global pr_maketext pr_textfile textfilename is_file_edit search_string evv

	catch {destroy .cpd}

	set b [frame $f.b]
	frame $f.dum0 -height 1 -bg [option get . foreground {}]
	set z [frame $f.z]		
	frame $f.dum1 -height 1 -bg [option get . foreground {}] 
	set k [frame $f.k]		
	set d [frame $f.d]		
	button $b.keep   -text "Keep Changes"   -command "set pr_maketext 1" -highlightbackground [option get . background {}]
	button $b.k -text "" -width 2 -bd 0 -command {} -bg [option get . background {}] -highlightbackground [option get . background {}]
	label  $b.l -text "filename" 
	entry  $b.e -textvariable textfilename
	menubutton $b.m -text "Standard Names" -width 17 -menu $b.m.menu -relief raised
	button $b.a -text "A" -command "PlaySndfile $evv(TESTFILE_A) 0" -width 2 -bg $evv(HELP) -bd 4 -highlightbackground [option get . background {}]
	set snames [menu $b.m.menu -tearoff 0]
	MakeStandardNamesMenu $snames $f.b.e 1
	if {$withsound} {
		button $b.find -text "" -bd 0 -width 14 -command {} -bg [option get . background {}] -highlightbackground [option get . background {}]
		button $b.kbd -text "" -bd 0 -width 11 -command {} -bg [option get . background {}] -highlightbackground [option get . background {}]
	} else {
		menubutton $b.find -text "" -bd 0 -width 14 -menu $b.find.menu -relief raised -state disabled
		menubutton $b.kbd -text "" -bd 0 -width 11 -relief raised -state disabled
		set fdo [menu $b.find.menu -tearoff 0]
		$fdo add command -label "Find File Or Dir" -command "FindFileFromNotebook" -foreground black
		$fdo add separator
		$fdo add command -label "Play Soundfile" -command "PlayFileFromNotebook" -foreground black
		$fdo add separator
		$fdo add command -label "Lines To Textfile" -command "BatchfileFromNotebook" -foreground black
	}
	frame $b.midi
	button $b.calc -text "Calculator" -width 8 -command "MusicUnitConvertor 4 0"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
	button $b.ref   -text "Reference" -width 8 -command "RefSee 0"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
	button $b.cancel -text "Leave Unchanged" -command "set pr_maketext 0" -highlightbackground [option get . background {}]
	button $b.undo -text "" -width 4 -command {} -highlightbackground [option get . background {}]
	pack $b.keep $b.k $b.l $b.e $b.m $b.a -side left -padx 1 -pady 1
	pack $b.cancel $b.undo $b.calc $b.ref $b.kbd $b.find $b.midi -side right -padx 1 -pady 1
	set t [text $k.t -setgrid true -wrap word -width 76 -height 32 \
	-xscrollcommand "$k.sx set" -yscrollcommand "$k.sy set"]
	scrollbar $k.sy -orient vert  -command "$f.k.t yview"
	scrollbar $k.sx -orient horiz -command "$f.k.t xview"
	pack $k.t -side left -fill both -expand true
	pack $k.sy -side right -fill y
	set z0 [frame $z.0]
	menubutton $z0.m -text "Special Formats" -width 18 -menu $z0.m.menu -relief raised
	frame $z0.dum  -height 1 -bg [option get . foreground {}] 
	button $z0.src -text "Search for" -command "SearchForString $f" -highlightbackground [option get . background {}]
	entry $z0.ss -textvariable search_string -width 16
	pack $z0.m -side top -pady 2
	pack $z0.dum -side top -fill x -expand true -pady 6 -padx 2
	pack $z0.src $z0.ss -side top -pady 2 -padx 2
	set rod [menu $z0.m.menu -tearoff 0]

	$rod add cascade -label "Distort" -menu $rod.sub7 -foreground black
	set rod7 [menu $rod.sub7 -tearoff 0]
	$rod7 add command -label "harmonic" -command "StandardMenu distort_hrm" -foreground black

	$rod add cascade -label "Edit" -menu $rod.sub4 -foreground black
	set rod4 [menu $rod.sub4 -tearoff 0]
	$rod4 add command -label "cutout & keep many" -command "StandardMenu edit_cutmany" -foreground black
	$rod4 add command -label "ditto at zero-crossings" -command "StandardMenu edit_cutmany" -foreground black
	$rod4 add command -label "switch between files" -command "StandardMenu twixt" -foreground black
	$rod4 add command -label "make a sphinx" -command "StandardMenu sphinx" -foreground black

	$rod add cascade -label "Extend" -menu $rod.sub9 -foreground black
	set rod9 [menu $rod.sub9 -tearoff 0]
	$rod9 add command -label "sequencer" -command "StandardMenu sequencer" -foreground black
	$rod9 add command -label "multifile sequencer" -command "StandardMenu sequencer2" -foreground black

	$rod add cascade -label "Filter" -menu $rod.sub6 -foreground black
	set rod6 [menu $rod.sub6 -tearoff 0]
	$rod6 add command -label "iterated" -command "StandardMenu fltiter" -foreground black
	$rod6 add command -label "userbank" -command "StandardMenu fltbanku" -foreground black
	$rod6 add command -label "varibank" -command "StandardMenu fltbankv" -foreground black
	$rod6 add command -label "varipartials" -command "StandardMenu fltbankv2" -foreground black

	$rod add cascade -label "Grain" -menu $rod.sub6a -foreground black
	set rod6a [menu $rod.sub6a -tearoff 0]
	$rod6a add command -label "remotif" -command "StandardMenu grn_remotif" -foreground black

	$rod add cascade -label "Harmonic Field" -menu $rod.sub8 -foreground black
	set rod8 [menu $rod.sub8 -tearoff 0]
	$rod8 add command -label "Chords from Delay & Shift" -command "StandardMenu del_perm" -foreground black
	$rod8 add command -label "Patterns from Delay & Shift" -command "StandardMenu del_perm2" -foreground black
	$rod8 add command -label "Synthesize Chords" -command "StandardMenu chords" -foreground black

	$rod add cascade -label "Hilite" -menu $rod.sub1 -foreground black
	set rod1 [menu $rod.sub1 -tearoff 0]
	$rod1 add command -label "graphic eq (one band)" -command "StandardMenu greqone" -foreground black
	$rod1 add command -label "graphic eq (many bands)" -command "StandardMenu greq" -foreground black
	$rod1 add command -label "bands" -command "StandardMenu split" -foreground black
	$rod1 add command -label "vowels" -command "StandardMenu vfilt" -foreground black

	$rod add cascade -label "Radical" -menu $rod.sub5 -foreground black
	set rod5 [menu $rod.sub5 -tearoff 0]
	$rod5 add command -label "stack" -command "StandardMenu stack" -foreground black

	$rod add cascade -label "Repitch" -menu $rod.sub2 -foreground black
	set rod2 [menu $rod.sub2 -tearoff 0]
	$rod2 add command -label "invert" -command "StandardMenu p_invert" -foreground black
	$rod2 add command -label "spectrum over pitch" -command "StandardMenu p_synth" -foreground black
	$rod2 add command -label "vowels over pitch" -command "StandardMenu p_vowels" -foreground black
	$rod2 add command -label "synthesize pitch" -command "StandardMenu p_gen" -foreground black
	$rod2 add command -label "insert unpitched windows" -command "StandardMenu p_insert" -foreground black

	$rod add cascade -label "Mix" -menu $rod.sub3 -foreground black
	set rod3 [menu $rod.sub3 -tearoff 0]
	$rod3 add command -label "mix on grid" -command "StandardMenu mix_on_grid" -foreground black
	$rod3 add command -label "balance" -command "StandardMenu automix" -foreground black

	$rod add command -label "Multidelay & Room Reverb" -command "StandaloneStandardMenu multidelay" -foreground black

	$rod add command -label "Clicktrack" -command "StandardMenu click" -foreground black
	$rod add command -label "Time + Beats" -command "ClikCalculator" -foreground $evv(SPECIAL)

	set zz [frame $z.z]
	text $zz.t -setgrid true -wrap word -width 64 -height 8 \
	-xscrollcommand "$zz.sx set" -yscrollcommand "$zz.sy set"
	scrollbar $zz.sy -orient vert  -command "$f.z.z.t yview"
	scrollbar $zz.sx -orient horiz -command "$f.z.z.t xview"

	pack $zz.t -side left -fill both -expand true
	pack $zz.sy -side right -fill y
	pack $z.0 $z.z -side left -fill y -expand true

	pack $f.b -side top -fill x
	pack $f.dum0 -side top -fill x -pady 2
	pack $f.z -side top -fill x
	pack $f.dum1 -side top -fill x -pady 2
	pack $f.k $f.d -side top -fill x
	bind $f.k.t	<ButtonRelease-1> "catch {$f.k.t tag delete hilite}"
	bind $f.k.t	<Control-u> "ChangeCase 0"
	bind $f.k.t	<Control-U> "ChangeCase 1"
	bind $f.k.t <Control-P>	"UniversalPlay text $f.k.t"
	bind $f.k.t <Control-p>	"UniversalPlay text $f.k.t" 
	bind $f.k.t <Control-G>	"UniversalGrab $f.k.t"
	bind $f.k.t <Control-g>	"UniversalGrab $f.k.t" 
	bind $f.b.e <Up> "AdvanceNameIndex 1 textfilename 0"
	bind $f.b.e <Down> "AdvanceNameIndex 0 textfilename 0"
	bind $f.b.e <Control-Up> "AdvanceNameIndex 1 textfilename 1"
	bind $f.b.e <Control-Down> "AdvanceNameIndex 0 textfilename 1"
	bind $f <Escape> "set pr_maketext 0"
	bind $f <Control-s> "set pr_maketext 1"
	bind $f <Control-S> "set pr_maketext 1"
}

#------ List all special data files, and allow user to chose one for entry to parameter-page
#
#	Only appropriate files displayed.	<--->		All textfiles are displayed.
#	Selected file is used as parameter.				Any file may be edited, so it becomes
#													appropriate to the need in hand,
#													and will thus appear on the 
#													appropriate-files listing.
#

proc Dlg_GetTextfile {pcnt gcnt type} {
	global get_textfile pr_textfile pr_maketext sfffl sfffb text_filecnt parname brk sl_real wl pa evv
	
	set f .get_textfile

	switch -- $type {
		"seg" {
			set thistitle "Lists of values"
		}
		"special" {
			set par_name [StripName	$parname($gcnt)]
			set thistitle "Special Data Files : $par_name"
		}
		"brk" {
			if {!$sl_real} {
				Inf "You Can Enter A Parameter Which Itself Varies Through Time.\nThis Is Defined In A Textifle, Called A Breakpoint File"
				Inf "The Soundloom Will Present You With A List Of Any Breakpoint Files\nListed On The Workspace, Which Are Appropriate To This Process,\nAnd Allow You To Choose One Of These As The Parameter."
			}
			set par_name [StripName	$parname($gcnt)]
			set thistitle "Breakpoint Files : $par_name "
		}
		"mchrot" {
			set thistitle "Breakpoint Files"
		}
		"allbrk_wk" {
			set ilist [$wl curselection]
			if {[llength $ilist] <= 0} {
				Inf "No files selected"
				return
			}
			set OK 0
			foreach i $ilist {
				set fnam [$wl get $i]
				if {[IsABrkfile $pa($fnam,$evv(FTYP))]} {
					set OK 1
					break
				}
			}
			if {!$OK} {
				Inf "No breakpoint files selected"
				return
			}
			set thistitle "Breakpoint Files"
		}
		"allbrk" {
			set thistitle "Breakpoint Files"
		}
	}
	if {![info exists brk(from_wkspace)]} {
		set brk(from_wkspace) 0
	}

	if [Dlg_Create $f "" "set pr_textfile 0" -borderwidth $evv(BBDR)] {
		set sfffb [frame $f.buttons]
		frame $f.msg
		set sfffl [Scrolled_Listbox $f.filelist -width 48 -height 20 -selectmode single]		
		pack $f.buttons $f.msg $f.filelist -side top -fill x
		button $sfffb.load -text "" -width 4  -command {} -highlightbackground [option get . background {}]
		button $sfffb.all  -text "" -width 10 -command {} -highlightbackground [option get . background {}]
		button $sfffb.edit -text "" -width 4  -command {} -highlightbackground [option get . background {}]
		button $sfffb.quit -text "Close" -width 7 -command "set pr_textfile 0" -highlightbackground [option get . background {}]
		label  $sfffb.lab  -text "" -width 32
		button $sfffb.del  -text "" -width 6  -command {} -highlightbackground [option get . background {}]
		pack $sfffb.load $sfffb.all $sfffb.edit $sfffb.del $sfffb.lab -side left
		pack $sfffb.quit -side right
		label $f.msg.1 -text "IF EDITING A PARAMETER FOR A PROCESS\nAND FILE IS NOT LISTED AFTER YOU HAVE EDITED IT.." -fg $evv(SPECIAL)
		label $f.msg.2 -text "1) Values Out of Range ?? Toggle range button on params page.."
		label $f.msg.3 -text "2) Bad Syntax, or Totally out of Range for the Application??"
		label $f.msg.4 -text "      Press 'All Textfile' and re-edit the file."
		pack $f.msg.1 $f.msg.2 $f.msg.3 $f.msg.4 -side top
		bind $f <Double-1> "ShowGetFileChoice %y"
		bind $f <Return> {set pr_textfile 0}
		bind $f <Escape> {set pr_textfile 0}
	}
	raise $f
	wm title $f "$thistitle"			;#	Force title, in case it's new
	$sfffl delete 0 end
	List_Appropriate_Files $pcnt $sfffl $type
	if {$brk(from_wkspace)} {
		$sfffb.all config  -text "Display" -command "GrafDisplayBrkfile 0" -borderwidth 2 -state normal
	} else {
		$sfffb.all config -text "All Textfiles" -command "SeeAll $sfffl $sfffb $type $pcnt $gcnt" -borderwidth $evv(SBDR) -state normal
	}
	if {($text_filecnt > 0) || !$sl_real} {
		if {$brk(from_wkspace)} {
			$sfffb.load config  -text "" -command {} -borderwidth 0 -state disabled
		} else {
			if {$type == "seg"} {	
				$sfffb.load config -text "Use" -command "UseSegFile $sfffl" -state normal -borderwidth $evv(SBDR)
				bind $f <Return> "UseSegFile $sfffl"
			} elseif {$type == "mchrot"} {	
				$sfffb.load config -text "Use" -command "UseRotFile $sfffl" -state normal -borderwidth $evv(SBDR)
				bind $f <Return> "UseRotFile $sfffl"
			} else {
				$sfffb.load config -text "Use" -command "UseFile $pcnt $sfffl" -state normal -borderwidth $evv(SBDR)
				bind $f <Return> "UseFile $pcnt $sfffl"
			}
		}
		$sfffb.edit config -text "Edit"   -command "GetFileToEdit $type $sfffl $pcnt $gcnt"
		$sfffb.del  config -text "Delete" -command "DeleteFile $sfffl"
		switch $type {
			"seg" - 
			"special" {$sfffb.lab config -text "Possible files??" -fg [option get . foreground {}]}
			"brk"	  {$sfffb.lab config -text "Appropriate files" -fg [option get . foreground {}]}
			"mchrot"  {$sfffb.lab config -text "Appropriate files" -fg [option get . foreground {}]}
		}
	} else {
		$sfffb.lab config -text "No appropriate files found" -fg $evv(SPECIAL)
	}
	set pr_textfile 0
	raise $f
 	My_Grab 0 $f pr_textfile
	tkwait variable pr_textfile
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#------ Change display to show ALL  textfiles (or brkfiles)

proc SeeAll {sfl b type pcnt gcnt} {
	global pr_textfile text_filecnt edit_type sl_real evv

	$b.load config -text "Other" -command "OtherPossibleFiles $type $gcnt $pcnt"
	$sfl delete 0 end										;#	Clear file display
	switch -- $type {
		"seg"	  -
		"special" -
		"mchrot"  -
		"brk"	 {
			$b.all  config -text "See Possible"				;#	Change function of SEE ALL to SEE POSSIBLE
			set thistype all
		}
	}														
	List_Appropriate_Files $pcnt $sfl $thistype 		
	$b.all config -command "SeeUseful $sfl $b $type $pcnt $gcnt"
	if {($text_filecnt > 0) || !$sl_real } {							
		$b.edit config -text "Edit"   -command "GetFileToEdit $type $sfl $pcnt $gcnt"
		$b.del  config -text "Delete" -command "DeleteFile $sfl"
		switch -- $type {
			"seg"	  -
			"special" {$b.lab config  -text "All textfiles on workspace" -fg [option get . foreground {}]}
			"mchrot"  -
			"brk"	  {$b.lab config  -text "All breakpoint files on workspace" -fg [option get . foreground {}]}
		}
	} else {														
		switch -- $type {
			"seg"	  -
			"special" {$b.lab config  -text "No textfiles found on workspace" -fg $evv(SPECIAL)}
			"mchrot"  -
			"brk"	  {$b.lab config  -text "No breakpoint files found on workspace" -fg $evv(SPECIAL)}
		}
	}
}

#------ Change display to show only APPROPRIATE textfiles

proc SeeUseful {sfl b type pcnt gcnt} {
	global text_filecnt sl_real evv
	$sfl delete 0 end									
	List_Appropriate_Files $pcnt $sfl $type
	$b.all config -text "All Textfiles" -command "SeeAll $sfl $b $type $pcnt $gcnt"
	if {($text_filecnt > 0) || !$sl_real} {							
		if {$type == "seg"} {
			$b.load config -text "Use"    -command "UseSegFile $sfl" -state normal
		} else {
			$b.load config -text "Use"    -command "UseFile $pcnt $sfl" -state normal
		}
		$b.edit config -text "Edit"   -command "GetFileToEdit $type $sfl $pcnt $gcnt"
		$b.del  config -text "Delete" -command "DeleteFile $sfl"
		switch -- $type {
			"seg" -
			"special" {$b.lab config -text "Possible files??"  -fg [option get . foreground {}]} 
			"mchrot" -
			"brk"	  {$b.lab config -text "Appropriate files" -fg [option get . foreground {}]}
		}
	} else {														
		$b.lab config -text "No appropriate files found" -fg $evv(SPECIAL)
	}
}

#------ Submit file, selected from listing, to editor

proc GetFileToEdit {type sfl pcnt gcnt} {
	global text_filecnt sl_real edit_badbrk

	if {!$sl_real} {
		Inf "The File You Select From The List Below\nCan Be Edited, Before You Use It."
		return
	}
	if {$text_filecnt == 1} {
		set i 0
	} else {
		set i [$sfl curselection]	
		if {[llength $i] <= 0} {
			Inf "No file selected"
			return
		}
	}
	set fnam [$sfl get $i]
	EditTextfile $fnam $type $pcnt $gcnt	;#	Allows selected file to be edited
	if {[info exists edit_badbrk]} {
		set k [LstIndx $edit_badbrk $sfl]
		if {$k >= 0} {
			$sfl delete $k
		}
		unset edit_badbrk
	}
}

#------ Use a textfile selected from files listing as a parameter

proc UseFile {pcnt sfl} {
	global pr_textfile prm brk prm text_filecnt sl_real
	global ins chlist pa evv gdg_cnt wstk done_ins_stereo done_ins_stchan
	set do_stereo 0
	if {!$sl_real} {
		Inf "The File You Select From The List Below\nWill Become The Parameter Value."
		return
	}
	if {$text_filecnt == 1} {
		set i 0
	} else {
		set i [$sfl curselection]
		if {[llength $i] <= 0} {
			Inf "No file selected"
			return
		}
	}

	if {[info exists ins(run)] && $ins(run) && ($gdg_cnt > [expr $pcnt + 1]) && ([string first "stereo" $ins(name)] >= 0)} {
		if {$done_ins_stchan == $pcnt} {
			set done_ins_stereo 0
		}
		if {!$done_ins_stereo} {
			if {[info exists chlist] && ([llength $chlist] == 1) && ($pa([lindex $chlist 0],$evv(CHANS)) == 2)} {
				set msg "Set next parameter to same value ??"
				set choice [tk_messageBox -type yesno -message $msg -parent [lindex $wstk end] -icon question]
				if {$choice == "yes"} {
					set do_stereo 1
				}
			}
		}
	}
	set prm($pcnt) [$sfl get $i]	;#	Goes directly to be a prm value
	if {$do_stereo} {
		set done_ins_stchan $pcnt
		incr pcnt
		set prm($pcnt) [$sfl get $i]
		set done_ins_stereo 1
	}
	set	pr_textfile 0
}

#------ Delete a textfile selected from files listing

proc DeleteFile {sfl} {
	global wl ch text_filecnt rememd sl_real

	if {!$sl_real} {
		Inf "The File You Select From The List Below\nWill Be Deleted From Disk."
		return
	}
	set i [$sfl curselection]
	if {[llength $i] <= 0} {
		Inf "No file selected"
		return
	}
	set fnam [$sfl get $i]
	set j [LstIndx $fnam $ch]
	if {$j >= 0} {
		Inf "File is a selected file for this process: cannot be deleted now"
		return
	}
	if [AreYouSure] {
		file stat $fnam filestatus
		if {$filestatus(ino) >= 0} {
			catch {close $filestatus(ino)}
		}
		if [DeleteFileFromSystem $fnam 1 1] {
			DummyHistory $fnam "DESTROYED"
			$sfl delete $i
			incr text_filecnt -1
			WkspCnt $fnam -1
			catch {$wl delete [LstIndx $fnam $wl]}
			catch {unset rememd}
		}
	}
}

#------ List appropriate special-data files to a files-listing, for user to select as prm-source

proc List_Appropriate_Files {pcnt ll type} {
	global ins wl text_filecnt pa sl_real evv
	global pprg mmod actvlo actvhi prm
	global current_type chlist edit_badbrk

	set mmode $mmod
	incr mmode -1
	set current_type $type
	set text_filecnt 0
	switch -- $type {
		"all" {
			set i 0
			set j -1
			if {![info exists edit_badbrk]} {
				set j -2
			}
			foreach fnam [$wl get 0 end] {			;#	list textfiles only
				if {$pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)} {
					$ll insert end $fnam
					incr text_filecnt 
					if {($j == -1) && [string match $edit_badbrk $fnam]} {
						set j $i
					}
					incr i
				}
			}
			if {$j >= 0} {
				$ll selection set $j
				set i [expr double($j) / double([$ll index end])]
				$ll yview moveto $i
			}
		}
		"seg" {
			foreach fnam [$wl get 0 end] {			;#	list lists of single words only
				if {($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)) \
				&&   ($pa($fnam,$evv(LINECNT)) == $pa($fnam,$evv(ALL_WORDS)))} {
					$ll insert end $fnam
					incr text_filecnt 
				}
			}
		}
		"special" {
			if {$ins(run)} {
				foreach fnam [$wl get 0 end] {		;#	list textfiles only
					if {$pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)} {
						$ll insert end $fnam
						incr text_filecnt 
					}
				}
			} else {									
				foreach fnam [$wl get 0 end] {		;#	list appropriate textfiles only
					set OK 0
					switch -regexp -- $pprg \
						^$evv(MIXINBETWEEN)$ -	\
						^$evv(FREEZE)$ 	 	-	\
						^$evv(FREEZE2)$	 	-	\
						^$evv(SIMPLE_TEX)$ 	-	\
						^$evv(TEX_MCHAN)$ 	-	\
						^$evv(TIMED)$		-	\
						^$evv(GROUPS)$	 	-	\
						^$evv(ORNATE)$	 	-	\
						^$evv(PREORNATE)$  	-	\
						^$evv(POSTORNATE)$ 	-	\
						^$evv(MOTIFS)$	 	-	\
						^$evv(MOTIFSIN)$	-	\
						^$evv(DECORATED)$	-	\
						^$evv(PREDECOR)$	-	\
						^$evv(POSTDECOR)$	-	\
						^$evv(TGROUPS)$	 	-	\
						^$evv(TMOTIFS)$	 	-	\
						^$evv(TMOTIFSIN)$	-	\
						^$evv(SPLIT)$		-	\
						^$evv(ENV_CREATE)$ 	-	\
						^$evv(FLTBANKU)$	-	\
						^$evv(FLTITER)$	 	-	\
						^$evv(FLTBANKV)$ 	-	\
						^$evv(SYNFILT)$ 	-	\
						^$evv(FLTBANKV2)$ 	-	\
						^$evv(HF_PERM1)$ 	-	\
						^$evv(HF_PERM1)$ 	-	\
						^$evv(DEL_PERM)$ 	-	\
						^$evv(CLICK)$ 		-	\
						^$evv(DEL_PERM2)$ 	-	\
						^$evv(SYNTHESIZER)$ -	\
						^$evv(NEWTEX)$ {
							if {[IsNotMixText $pa($fnam,$evv(FTYP))]} {
								set OK 1									
								#	is a textfile, but not a mixfile		
							}				
						}			  		\
						^$evv(TRNSF)$ - 	\
						^$evv(TRNSP)$ {
							switch -regexp -- $mmode \
								^$evv(TRNS_RATIO)$ {
									if {($pa($fnam,$evv(FTYP)) != $evv(MIX_MULTI)) && ($pa($fnam,$evv(FTYP)) & $evv(IS_A_TRANSPOS_BRKFILE))} {
										set OK 1		;#	is a transposition-ratio brkfile
									}
								}	  		\
								^$evv(TRNS_OCT)$ - \
								^$evv(TRNS_SEMIT)$ {			
									if {[IsABrkfile $pa($fnam,$evv(FTYP))]} {			
										set OK 1		;#	is an unspecified range brkfile
									}
								}	
							
						}		\
						^$evv(SEQUENCER)$ {
							if {[IsAListofNumbers $pa($fnam,$evv(FTYP))] \
							&& ([expr $pa($fnam,$evv(NUMSIZE)) % 3] == 0)} {
								set OK 1		;#	is a number list with 3 columns
							}						
						}		\
						^$evv(PULSER2)$ - \
						^$evv(PULSER)$ {
							if {[IsAListofNumbers $pa($fnam,$evv(FTYP))] && ($pa($fnam,$evv(NUMSIZE)) >= 2) && ($pa($fnam,$evv(MINNUM)) >= 0)} {
								set OK 1		;#	is a number list with at least 2 entries and all >= 0
							}						
						}		\
						^$evv(CERACU)$ {
							if {[IsAListofNumbers $pa($fnam,$evv(FTYP))] && ($pa($fnam,$evv(NUMSIZE)) >= 2) && ($pa($fnam,$evv(MINNUM)) >= 1)} {
								set OK 1		;#	is a number list with at least 2 entries and all >= 1
							}						
						}		\
						^$evv(SHIFTER)$ {
							if {[IsAListofNumbers $pa($fnam,$evv(FTYP))] && ($pa($fnam,$evv(NUMSIZE)) >= 2) && ($pa($fnam,$evv(MINNUM)) >= 2)} {
								set OK 1		;#	is a number list with at least 2 entries and all >= 2
							}						
						}		\
						^$evv(FRACTURE)$ {
							if {[IsAListofNumbers $pa($fnam,$evv(FTYP))] && ([expr $pa($fnam,$evv(NUMSIZE)) % 15] == 0) && ($pa($fnam,$evv(MINNUM)) >= 0)} {
								set OK 1		;#	is a number list with entries grouped in 15s and all >= 0
							}						
						} \
						^$evv(SEQUENCER2)$ {
							if {[info exists chlist] && ([llength $chlist] > 0) && [IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
								set len [expr $pa($fnam,$evv(NUMSIZE)) - [llength $chlist]]
								if {($len > 0) && ([expr $len % 5] == 0)} {
									set OK 1		;#	is a number list with 5 columns, plus a first line containing midival for each infile
								}
							}						
						}		\
						^$evv(MULTI_SYN)$  - \
						^$evv(GRAIN_GET)$ {
							if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
								set OK 1		;#	is a number list
							}						
						}		\
						^$evv(GREV)$ {
							if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
								set OK 1		;#	is a number list
							}
						} \
						^$evv(MOD_LOUDNESS)$ {
							switch -regexp -- $mmode \
								^$evv(LOUD_PROPOR)$  - \
								^$evv(LOUD_DB_PROPOR)$ {
									if {[IsABrkfile $pa($fnam,$evv(FTYP))]} {
										set OK 1		;#	is a brkfile
									}
								}
						} \
						^$evv(ITERLINE)$ {
							if {[IsABrkfile $pa($fnam,$evv(FTYP))] && ($pa($fnam,$evv(MINBRK)) >= -24.0) && ($pa($fnam,$evv(MAXBRK)) <= 24.0)} {
								set OK 1		;#	is a brkfile with value range -24 to +24
							}
						} \
						^$evv(ITERLINEF)$ {
							if {[IsABrkfile $pa($fnam,$evv(FTYP))] && ($pa($fnam,$evv(MINBRK)) >= -12.0) && ($pa($fnam,$evv(MAXBRK)) <= 12.0)} {
								set OK 1		;#	is a brkfile with value range -12 to +12
							}
						} \
						^$evv(DISTORT_ENV)$  	-	\
						^$evv(ENVSYN)$  		-	\
						^$evv(ENV_WARPING)$  	-	\
						^$evv(ENV_REPLOTTING)$ 	-	\
						^$evv(DISTORT_PULSED)$  -	\
						^$evv(ENV_RESHAPING)$ {
							if {[IsANormdBrkfile $pa($fnam,$evv(FTYP))]} {
								set OK 1				;#	is a normalised brkfile (used for envelopes)
							}
						} \
						^$evv(ACC_STREAM)$		-	\
						^$evv(CHORD)$		  	-	\
						^$evv(P_QUANTISE)$	 	-	\
						^$evv(P_SYNTH)$	 		-	\
						^$evv(TUNE)$  		 	-	\
						^$evv(WEAVE)$		 	-	\
						^$evv(MULTRANS)$	 	-	\
						^$evv(ZIGZAG)$		 	-	\
						^$evv(MCHZIG)$		 	-	\
						^$evv(GRAIN_REPITCH)$	-	\
						^$evv(GRAIN_RERHYTHM)$ 	-	\
						^$evv(GRAIN_POSITION)$ {
							if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
								set OK 1				;#	is a list of numbers
							}
						}	\
						^$evv(GREQ)$ {
							switch -regexp -- $mmode \
								^$evv(GR_ONEBAND)$ {
									if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
										set OK 1		;#	is a list of numbers
									}
								}				  		\
								^$evv(GR_MULTIBAND)$ {
									if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
										if [IsEven [expr round($pa($fnam,$evv(NUMSIZE)))]] {
											set OK 1	;#	is a list of paired numbers
										}
									}
								}				  

						}					  	 	\
						^$evv(P_INVERT)$		-	\
						^$evv(P_INSERT)$		-	\
						^$evv(P_SINSERT)$		-	\
						^$evv(DISTORT_HRM)$		-	\
						^$evv(GRAIN_REMOTIF)$ 	-	\
						^$evv(INSERTSIL_MANY)$ 	-	\
						^$evv(HOUSE_EXTRACT)$ 	-	\
						^$evv(EDIT_CUTMANY)$ 	-	\
						^$evv(SUPPRESS)$ 	-	\
						^$evv(MANY_ZCUTS)$ 	-	\
						^$evv(JOIN_SEQDYN)$ -	\
						^$evv(EDIT_EXCISEMANY)$ {
							if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
								if [IsEven [expr round($pa($fnam,$evv(NUMSIZE)))]] {
									set OK 1			;#	is a list of paired numbers
								}
							}
						}	\
						^$evv(STACK)$ -	\
						^$evv(SYLLABS)$ -	\
						^$evv(JOIN_SEQ)$ -	\
						^$evv(TWIXT)$ {
							if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
								set OK 1		;#	is a list of numbers
							}
						}	\
						^$evv(SPHINX)$ {
							if {[IsAListofNumbers $pa($fnam,$evv(FTYP))] \
							&&  ($pa($fnam,$evv(FTYP)) & $evv(IS_A_LINELIST))} {
								set OK 1		;#	is a list of numbers arranged in lines
							}
						}	\
						^$evv(MIX_ON_GRID)$ - \
						^$evv(AUTOMIX)$ 	- \
						^$evv(P_GEN)$ 		- \
						^$evv(VFILT)$ 		- \
						^$evv(BATCH_EXPAND)$ - \
						^$evv(PSOW_SYNTH)$ - \
						^$evv(PSOW_IMPOSE)$ - \
						^$evv(P_VOWELS)$ {
							if {$pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)} {
								set OK 1		;#	is a textfile
							}
						}	\
						^$evv(TAPDELAY)$ {
							if {[IsAListofNumbers $pa($fnam,$evv(FTYP))] \
							&& (([expr $pa($fnam,$evv(NUMSIZE)) % 2] == 0)
							||  ([expr $pa($fnam,$evv(NUMSIZE)) % 3] == 0))} {
								set OK 1		;#	is a number list with 2 or 3 columns
							}						
						}		\
						^$evv(PSOW_STRETCH)$ - \
						^$evv(PSOW_DUPL)$ - \
						^$evv(PSOW_STRFILL)$ - \
						^$evv(PSOW_FREEZE)$ - \
						^$evv(PSOW_CHOP)$ - \
						^$evv(PSOW_FEATURES)$ - \
						^$evv(PSOW_SPLIT)$ - \
						^$evv(PSOW_SPACE)$ - \
						^$evv(PSOW_INTERP)$ - \
						^$evv(PSOW_REPLACE)$ - \
						^$evv(PSOW_EXTEND)$ - \
						^$evv(PSOW_EXTEND2)$ - \
						^$evv(PSOW_LOCATE)$ - \
						^$evv(PSOW_CUT)$ - \
						^$evv(PSOW_INTERLEAVE)$ - \
						^$evv(PSOW_DEL)$ {
							if {[IsABrkfile $pa($fnam,$evv(FTYP))]} {			
								set OK 1		;#	is an unspecified range brkfile
							}
						}		\
						^$evv(SPEKLINE)$ {
							if {[IsABrkfile $pa($fnam,$evv(FTYP))] && ($pa($fnam,$evv(MINNUM)) >= 0.0)} {			
								set OK 1		;#	is an unspecified range brkfile with values >= 0.0
							}
						}		\
						^$evv(PSOW_REINF)$ {
							if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
								set OK 1		;#	is a number list
							}
						}		\
						^$evv(RETIME)$ {
							switch -- $mmode {
								0 {
									if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
										set OK 1		;#	is a number list
									}
								}
								1 {
									if {[IsAListofNumbers $pa($fnam,$evv(FTYP))] && [IsEven $pa($fnam,$evv(NUMSIZE))] && ($pa($fnam,$evv(MINNUM)) >= 0.0)} {
										set OK 1		;#	is a number list with even number of entries, ALL  >= 0
									}
								}
								5 -
								6 {
									if {[IsAListofNumbers $pa($fnam,$evv(FTYP))] && ($pa($fnam,$evv(MINNUM)) >= 0.0)} {
										set OK 1		;#	is a number list, ALL  >= 0
									}
								}
								8 {
									if {[IsAListofNumbers $pa($fnam,$evv(FTYP))] && ($pa($fnam,$evv(MINNUM)) == 0.0) && ($pa($fnam,$evv(MAXNUM)) == 1.0)} {
										set OK 1		;#	is a number list, ALL >= 0 <=1
									}
								}
							}
						} \
						^$evv(TAPDELAY)$ - \
						^$evv(RMVERB)$ {
							if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
								set k [expr $pa($fnam,$evv(NUMSIZE)) / $pa($fnam,$evv(LINECNT))]
								if {($k == 2) || ($k == 3)} {
									if {[expr $k * $pa($fnam,$evv(LINECNT))] == $pa($fnam,$evv(NUMSIZE))} {
										set OK 1		;#	is a number list with 2 or 3 columns
									}						
								}
							}
						} \
						^$evv(FOFEX_EX)$ - \
						^$evv(FOFEX_CO)$ - \
						^$evv(TWEET)$    - \
						^$evv(MANYSIL)$ {
							if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
								set k [expr $pa($fnam,$evv(NUMSIZE)) / $pa($fnam,$evv(LINECNT))]
								if {[expr $k * $pa($fnam,$evv(LINECNT))] == $pa($fnam,$evv(NUMSIZE))} {
									set OK 1		;#	is a number list with 2
								}
							}
						} \
						^$evv(MCHANPAN)$ {
							switch -- $mmode {
								0 {
									if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
										set k [expr $pa($fnam,$evv(NUMSIZE)) / $pa($fnam,$evv(LINECNT))]
										if {([expr $k * $pa($fnam,$evv(LINECNT))] == $pa($fnam,$evv(NUMSIZE))) && ($k == 3)} {
											set OK 1		;#	is a number list with 3 columns
										}
									}
								}
								1 {
									if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
										if {($pa($fnam,$evv(MINNUM)) > 0) &&  ($pa($fnam,$evv(MAXNUM)) <= 16)} {
											set OK 1		;#	is a number list in range 1 to 16
										}
									}
								}
								6 {
									if {[IsAListofNumbers $pa($fnam,$evv(FTYP))] && ($pa($fnam,$evv(MINNUM)) >= 0.0)} {
										set OK 1		;#	is a number list, all vals >= 0
									}
								}
							}
						} \
						^$evv(FRAME)$ {
							if {$ins(create)} {
								set sfnam [lindex $ins(chlist) 0]
							} else {
								set sfnam [lindex $chlist 0]
							}
							switch -- $mmode {
								2 {
									if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
										if {$pa($fnam,$evv(NUMSIZE)) == $pa($sfnam,$evv(CHANS))} {
											set OK 1		;#	is a list of ALL chans numbers
										}
									}
								}
								6 {
									if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
										if {$pa($fnam,$evv(NUMSIZE)) <= $pa($sfnam,$evv(CHANS))} {
											set OK 1		;#	is a list of some of chan numbers
										}
									}
								}
								default {
									if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
										set k [expr $pa($fnam,$evv(NUMSIZE)) / $pa($fnam,$evv(LINECNT))]
										if {([expr $k * $pa($fnam,$evv(LINECNT))] == $pa($fnam,$evv(NUMSIZE))) && ($k == [expr $pa($sfnam,$evv(CHANS)) + 1])} {
											set OK 1		;#	is a number list with chans+1 cols
										}
									}
								}
							}
						} \
						^$evv(FLUTTER)$ {
							if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
								set OK 1		;#	is a list of chans numbers
							}
						} \
						^$evv(CHANNELX)$ {
							if {$ins(create)} {
								set sfnam [lindex $ins(chlist) 0]
							} else {
								set sfnam [lindex $chlist 0]
							}
							if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
								if {($pa($fnam,$evv(MINNUM)) >= 1) && ($pa($fnam,$evv(MAXNUM)) <= $pa($sfnam,$evv(CHANS)))} {
									set OK 1		;#	is a list of chans numbers in range 1 t to chancnt of infile
								}
							}
						} \
						^$evv(MCHSTEREO)$ {
							if {$ins(create)} {
								set thischlist $ins(chlist)
							} else {
								set thischlist $chlist
							}
							if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
								if {($pa($fnam,$evv(NUMSIZE)) == [llength $thischlist]) && ($pa($fnam,$evv(MINNUM)) >= 1) && ($pa($fnam,$evv(MAXNUM)) <= $prm(1))} {
									set OK 1		;#	is a list of chans numbers, as long as number of infiles
								}
							}
						} \
						^$evv(WRAPPAGE)$ {
							if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
								set k [expr $pa($fnam,$evv(NUMSIZE)) / $pa($fnam,$evv(LINECNT))]
									if {([expr $k * $pa($fnam,$evv(LINECNT))] == $pa($fnam,$evv(NUMSIZE))) && ($k == 3)} {
										set OK 1		;#	is a number list with 3 columns
								}
							}
						} \
						^$evv(SPECSLICE)$ {
							if {[IsABrkfile $pa($fnam,$evv(FTYP))]} {			
								set OK 1		;#	is an unspecified range brkfile
							}
						} \
						^$evv(SUPERACCU)$ {
							if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
								if {($pa($fnam,$evv(MINNUM)) >= 0) && ($pa($fnam,$evv(MAXNUM)) <= 127)} {
									set OK 1		;#	is a list of midi values
								}
							}
						} \
						^$evv(TUNEVARY)$ {
							if {($pa($fnam,$evv(FTYP)) & $evv(IS_A_LINELIST)) && [IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
								set OK 1		;#	is a list of numbers, with equal number of entries on each line
							}
						} \
						^$evv(ISOLATE)$ {
							switch -- $mmode {
								"0" -
								"1" {
									if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]  && ($pa($fnam,$evv(MINNUM)) >= 0) \
									&& [IsEven [expr round($pa($fnam,$evv(NUMSIZE)))]]} {
										set OK 1		;#	is a list of positive-or-0 numbers, with an even number of entries
									}
								}
								"3" -
								"4" {
									if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]  && ($pa($fnam,$evv(MINNUM)) >= 0)} {
										set OK 1		;#	is a list of positive-or-0 numbers

									}
								}
							}
						} \
						^$evv(PANORAMA)$ {
							if {$mmode == 1}  {
								if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]  && ($pa($fnam,$evv(MINNUM)) >= 0) && ($pa($fnam,$evv(MAXNUM)) <= 360) \
								&& ($pa($fnam,$evv(NUMSIZE)) > 2) && ($pa($fnam,$evv(NUMSIZE)) <= 16)} {
									set OK 1		;#	is a list of angular positions for 3-16 loudspeakers
								}
							}
						} \
						^$evv(MADRID)$ {
							if {$mmode == 1}  {
								if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]  && ($pa($fnam,$evv(MINNUM)) >= 1)} {
									set OK 1		;#	is a list of numbers >= 1
								}
							}
						} \
						^$evv(SHRINK)$ - \
						^$evv(PACKET)$ {
							if {$ins(create)} {
								set sfnam [lindex $ins(chlist) 0]
							} else {
								set sfnam [lindex $chlist 0]
							}
							if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]  && ($pa($fnam,$evv(MINNUM)) >= 0.0) && ($pa($fnam,$evv(MAXNUM)) <= $pa($sfnam,$evv(DUR)))} {
								set OK 1
							}
						} \
						^$evv(SPECMORPH2)$ {
							if {$mmode > 0}  {
								if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]  && ($pa($fnam,$evv(MINNUM)) >= 0) && ($pa($fnam,$evv(MAXNUM)) < 22500)} {
									set OK 1
								}
							}
						} \
						^$evv(PULSER3)$ {
							if {$mmode == 0}  {
								if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]  && ($pa($fnam,$evv(MINNUM)) >= -1) && ($pa($fnam,$evv(MAXNUM)) <= 64.0)} {
									set OK 1
								}
							} else {
								if {[IsNotMixText $pa($fnam,$evv(FTYP))]} {
									set OK 1									
								}
							}
						} \
						^$evv(STRANDS)$ {
							if {$mmode == 2}  {
								if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]  && ($pa($fnam,$evv(MINNUM)) >= 2) && ($pa($fnam,$evv(MAXNUM)) <= 100)} {
									set OK 1
								}
							}
						} \
						^$evv(SPECTUNE)$ {
							if {($mmode > 0) && ($mmode !=3)}  {
								if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]  && ($pa($fnam,$evv(MINNUM)) >= 4) && ($pa($fnam,$evv(MAXNUM)) <= 127)} {
									set OK 1
								}
							}
						} \
						^$evv(ROTOR)$ {
							if {[IsABrkfile $pa($fnam,$evv(FTYP))]  && ($pa($fnam,$evv(MINBRK)) >= 0) && ($pa($fnam,$evv(MAXBRK)) <= 1.0)} {
								set OK 1
							}
						} \
						^$evv(TESSELATE)$ {
							if {[info exists chlist] && [IsAListofNumbers $pa($fnam,$evv(FTYP))] && ($pa($fnam,$evv(LINECNT)) == 2)} {
								set k [expr $pa($fnam,$evv(NUMSIZE)) / $pa($fnam,$evv(LINECNT))]
									if {([expr $k * $pa($fnam,$evv(LINECNT))] == $pa($fnam,$evv(NUMSIZE))) && ($k == [llength $chlist])} {
										set OK 1		;#	is a number list with chlist-len columns
								}
							}
						} \
						^$evv(CRYSTAL)$ {
							if {[info exists chlist] && [IsAListofNumbers $pa($fnam,$evv(FTYP))] && ($pa($fnam,$evv(LINECNT)) > 1) && ($pa($fnam,$evv(NUMSIZE)) >= 9)} {
								set k [llength $chlist] 
								if {($k == 1) || ($k == [expr $pa($fnam,$evv(LINECNT)) - 1])} {
									set OK 1		;#	is a number list with >1 line and 9 or more entries overall (x y z coords of at least 1 vertex + initial middle and end pairs for envelope, at least)
													;#	and, if length chlist > 1, number of input files corresponds to linecnt - 1 (li.e. less the envelope info)
								}
							}
						} \
						^$evv(CASCADE)$ {
							if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]  && ($pa($fnam,$evv(MINNUM)) > 0) && ($pa($fnam,$evv(MAXNUM)) <= $pa([lindex $chlist 0],$evv(DUR)))} {
								set OK 1
							}
						} \
						^$evv(FRACTAL)$ {
							if {$mmode == 0} {
								if {[IsABrkfile $pa($fnam,$evv(FTYP))] && ($pa($fnam,$evv(MINBRK)) >= 0) && ($pa($fnam,$evv(MAXBRK)) <= 127)} {
									set OK 1
								}
							} else {
								if {[IsABrkfile $pa($fnam,$evv(FTYP))] && ($pa($fnam,$evv(MINBRK)) >= -12) && ($pa($fnam,$evv(MAXBRK)) <= 12)} {
									set OK 1
								}
							}
						} \
						^$evv(FRACSPEC)$ {
							if {[IsABrkfile $pa($fnam,$evv(FTYP))] && ($pa($fnam,$evv(MINBRK)) >= -12) && ($pa($fnam,$evv(MAXBRK)) <= 12)} {
								set OK 1
							}
						} \
						^$evv(REPEATER)$ {
							if {[IsAListofNumbers $pa($fnam,$evv(FTYP))] && ($pa($fnam,$evv(NUMSIZE)) > 0) && ($pa($fnam,$evv(NUMSIZE))/$pa($fnam,$evv(LINECNT)) == 4)} {
								set OK 1
							}
						} \
						^$evv(VERGES)$ {
							if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]  && ($pa($fnam,$evv(MINNUM)) >= 0) && ($pa($fnam,$evv(MAXNUM)) <= $pa([lindex $chlist 0],$evv(DUR)))} {
								set OK 1
							}
						} \
						^$evv(DISTMARK)$ {
							if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]  && ($pa($fnam,$evv(MINNUM)) >= 0) && ($pa($fnam,$evv(MAXNUM)) < $pa([lindex $chlist 0],$evv(DUR)))} {
								set OK 1
							}
						} \
						^$evv(STUTTER)$ - \
						^$evv(MOTOR)$ {
							if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]  && ($pa($fnam,$evv(MINNUM)) > 0.016) && ($pa($fnam,$evv(MAXNUM)) < [expr $pa([lindex $chlist 0],$evv(DUR)) - 0.016])} {
								set OK 1
							}
						} \
						^$evv(SCRUNCH)$ {
							if {(($mmode > 3) && ($mmode < 8)) || ($mmode > 9)} { 
								if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]  && ($pa($fnam,$evv(MINNUM)) >= 0.0) && ($pa($fnam,$evv(MAXNUM)) <= $pa([lindex $chlist 0],$evv(DUR)))} {
									set OK 1
								}
							}
						} \
						^$evv(SPECFNU)$ {
							switch -- $mmode {
								14 {			;#	interval mapping
									if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
										if [IsEven [expr round($pa($fnam,$evv(NUMSIZE)))]] {
											set OK 1			;#	is a list of paired numbers
										}
									}
								}
								6  -
								16 -
								17 {			;#	HF data with mapping mnemonic (and, for 6, list of times)
									if {($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)) && ![IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
										set OK 1		;#	is a textfile, but not (just) a list of numbers
									}

								}
							}
						} \
						default {
							ErrShow "Unknown option ($pprg) reached in List_Appropriate_Files."
							return 0
						}

					if {$OK} {
						$ll insert end $fnam
						incr text_filecnt 
					}
				}
			}
		}
		"brk" {
			foreach fnam [$wl get 0 end] {		;#	list brkfiles with correct range only
				if {[IsABrkfile $pa($fnam,$evv(FTYP))] \
				&&  ($pa($fnam,$evv(MINBRK)) >= $actvlo($pcnt)) \
				&&	($pa($fnam,$evv(MAXBRK)) <= $actvhi($pcnt))} {
					$ll insert end $fnam
					incr text_filecnt 
				}
			}
		}	
		"mchrot" {
			foreach fnam [$wl get 0 end] {		;#	list brkfiles with correct range only
				if {[IsABrkfile $pa($fnam,$evv(FTYP))] \
				&&  ($pa($fnam,$evv(MINBRK)) >= 0) \
				&&	($pa($fnam,$evv(MAXBRK)) <= 64)} {
					$ll insert end $fnam
					incr text_filecnt 
				}
			}
		}	
		"allbrk" {
			if {!$sl_real} {
				Inf "All Breakpoint Files On The Workspace Will Be Listed\nWhether Or Not They Are Appropriate.\n\nHowever, You Can Edit An Existing File\nTo Create New, Appropriate Values."
			}
			foreach fnam [$wl get 0 end] {		;#	list all brkfiles
				if {[IsABrkfile $pa($fnam,$evv(FTYP))]} {
					$ll insert end $fnam
					incr text_filecnt 
				}
			}
		}
		"allbrk_wk" {
			if {!$sl_real} {
				Inf "All Breakpoint Files On The Workspace Will Be Listed\nWhether Or Not They Are Appropriate.\n\nHowever, You Can Edit An Existing File\nTo Create New, Appropriate Values."
			}
			set ilist [$wl curselection]
			foreach i $ilist {
				set fnam [$wl get $i]
				if {[IsABrkfile $pa($fnam,$evv(FTYP))]} {
					$ll insert end $fnam
					incr text_filecnt 
				}
			}
		}	
	}
	if {($type != "allbrk_wk") && ($type != "seg") && ($type != "mchrot")} {
		if {([string length $prm($pcnt)] > 0) && ![IsNumeric $prm($pcnt)]} {
			set i 0
			foreach fnam [$ll get 0 end] {
				if {[string match $fnam $prm($pcnt)]} { 
					$ll delete $i
					$ll insert 0 $fnam
					break
				}
				incr i
			}
		}
	}
}

#------ Allow user to edit as text or as graph.

proc Dlg_ChooseFiletypeToEdit {} {
	global pr_whichtype2 isbrktype text_edit_style evv
	set f .whichtype2
	set isbrktype 1
#NEW AUGUST 2001
	if {$text_edit_style != 0} {
		switch -- $text_edit_style {
			1 {return 0}
			2 {return 1}
		}
		set isbrktype 0
	}
	if [Dlg_Create $f "Text or Graphic" "set pr_whichtype2 1" -borderwidth $evv(BBDR)] {
		frame $f.0
		frame $f.00
		frame $f.1
		button $f.0.brk  -text "Work on Graph"   -width 16 -command "set pr_whichtype2 1" -highlightbackground [option get . background {}]
		button $f.0.txt  -text "Work with Text"  -width 16 -command "set pr_whichtype2 0" -highlightbackground [option get . background {}]
		pack $f.0.brk -side left 
		pack $f.0.txt -side right 
		label  $f.00.spc  -text "~~ In Future ~~"
		pack $f.00.spc -side top
		button $f.1.brk  -text "Always use Graph" -width 16 -command "SetTextEditStyle 2; set pr_whichtype2 1" -highlightbackground [option get . background {}]
		button $f.1.txt  -text "Always use Text" -width 16 -command "SetTextEditStyle 1; set pr_whichtype2 0" -highlightbackground [option get . background {}]
		label  $f.1.spc  -text "You can reset this choice on the 'SYSTEM' menu"
		pack $f.1.brk $f.1.txt $f.1.spc -side left
		pack $f.0 -side top -fill x -expand true
		pack $f.00 -side top
		pack $f.1 -side top -pady 8
	}
	wm resizable $f 1 1
	set pr_whichtype2 0
	ScreenCentreSmall $f
	raise $f
	My_Grab 0 $f pr_whichtype2 $f
	tkwait variable pr_whichtype2
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $pr_whichtype2
	set isbrktype 0
}

proc SetTextEditStyle {n} {
	global new_text_edit_style text_edit_style orig_text_edit_style
	if {![info exists orig_text_edit_style]} {
		set orig_text_edit_style $text_edit_style
	}
	set text_edit_style $n
	set new_text_edit_style $n
}

proc SearchForString {f} {
	global search_string last_search_string tlist cnt laststart lastcnt evv

	if {[info exists last_search_string] && [string match $last_search_string $search_string]} {
		set searchstart [expr $laststart + 1]
	} else {
		set searchstart 1.0
	}
	catch {$tlist tag delete hilite}
	if {[string length $search_string] <= 0} {
		Inf "No search string entered"
	}
	set start [$tlist search -count cnt -nocase -regexp -- $search_string $searchstart]
	if {[info exists cnt] && ([string length $start] > 0)} {
		$tlist tag configure hilite -background blue -foreground white
		$tlist see $start
		$tlist tag add hilite $start "$start +$cnt chars"
		set laststart $start
		set lastcnt $cnt
		set last_search_string $search_string 
	} else {
		Inf "Not Found"
	}
	$f.z.0.src config -bg [option get . background {}]
	$f.z.0.ss  config -bg [option get . background {}]
}

#----- Create menu of standard CDP filenames

proc MakeStandardNamesMenu {menu entry readme} {
	global evv
	$menu add command -label "Temporary File" -command "ForceVal $entry temp; focus $entry" -foreground black
	$menu add cascade -label "Recent Names" -command "CreateRecentTextfileNames $entry" -foreground $evv(SPECIAL)
	if {$readme} {
		$menu add command -label "Readme"   -command "ForceVal $entry readme" -foreground black
	}
	$menu add command -label "Balance"   -command "ForceVal $entry balance; focus $entry" -foreground black
	$menu add command -label "density"   -command "ForceVal $entry density; focus $entry" -foreground black
	$menu add command -label "env"       -command "ForceVal $entry env; focus $entry" -foreground black
	$menu add command -label "excises"   -command "ForceVal $entry excises; focus $entry" -foreground black
	$menu add command -label "filt"      -command "ForceVal $entry filt; focus $entry" -foreground black
	$menu add command -label "freq"      -command "ForceVal $entry freq; focus $entry" -foreground black
	$menu add command -label "grid"      -command "ForceVal $entry grid; focus $entry" -foreground black
	$menu add command -label "hi"        -command "ForceVal $entry hi; focus $entry" -foreground black
	$menu add command -label "lo"        -command "ForceVal $entry lo; focus $entry" -foreground black
	$menu add command -label "mix1"      -command "ForceVal $entry mix1; focus $entry" -foreground black
	$menu add command -label "mix2"      -command "ForceVal $entry mix2; focus $entry" -foreground black
	$menu add command -label "notedata"  -command "ForceVal $entry notedata; focus $entry" -foreground black
	$menu add command -label "pan"       -command "ForceVal $entry pan; focus $entry" -foreground black
	$menu add command -label "q"         -command "ForceVal $entry q; focus $entry" -foreground black
	$menu add command -label "sequence"  -command "ForceVal $entry sequence; focus $entry" -foreground black
	$menu add command -label "spread"    -command "ForceVal $entry spread; focus $entry" -foreground black
	$menu add command -label "stack"     -command "ForceVal $entry stack; focus $entry" -foreground black
	$menu add command -label "stretch"   -command "ForceVal $entry stretch; focus $entry" -foreground black
	$menu add command -label "temp"      -command "ForceVal $entry temp; focus $entry" -foreground black
	$menu add command -label "times"     -command "ForceVal $entry times; focus $entry" -foreground black
	$menu add command -label "trans"     -command "ForceVal $entry trans; focus $entry" -foreground black
	$menu add command -label "tremfrq"   -command "ForceVal $entry tremfrq; focus $entry" -foreground black
	$menu add command -label "tremdepth" -command "ForceVal $entry tremdepth; focus $entry" -foreground black
	$menu add command -label "vector"    -command "ForceVal $entry vector; focus $entry" -foreground black
	$menu add command -label "vibfrq"    -command "ForceVal $entry vibfrq; focus $entry" -foreground black
	$menu add command -label "vibdepth"  -command "ForceVal $entry vibdepth; focus $entry" -foreground black
	$menu add command -label "warp"      -command "ForceVal $entry warp; focus $entry" -foreground black
	$menu add command -label "zig"       -command "ForceVal $entry zig; focus $entry" -foreground black
}

#----- Create menu of standard CDP suffixes

proc MakeStandardSuffixesMenu {menu entry readme} {
	global evv
	if {$readme} {
		$menu add command -label "Readme"   -command "ForceVal $entry readme"
	}
	$menu add command -label "Add Suffix"  -command {} -background $evv(HELP) -foreground black
	$menu add separator
	$menu add command -label "'midi'"  -command "ForceSuffix $entry midi; focus $entry" -foreground black
	$menu add command -label "'mtf'"   -command "ForceSuffix $entry mtf; focus $entry" -foreground black
	$menu add command -label "'pitch'" -command "ForceSuffix $entry pitch; focus $entry" -foreground black
	$menu add command -label "'frq'"   -command "ForceSuffix $entry frq; focus $entry" -foreground black
	$menu add command -label "'cln'"   -command "ForceSuffix $entry cln; focus $entry" -foreground black
	$menu add command -label "'rept'"  -command "ForceSuffix $entry rept; focus $entry" -foreground black
	$menu add command -label "'sofar'" -command "ForceSuffix $entry sofar; focus $entry" -foreground black
	$menu add separator
	$menu add command -label "Replace Suffix"  -command {} -background $evv(HELP) -foreground black
	$menu add separator
	$menu add command -label "'midi'"  -command "ReplaceSuffix $entry midi; focus $entry" -foreground black
	$menu add command -label "'mtf'"   -command "ReplaceSuffix $entry mtf; focus $entry" -foreground black
	$menu add command -label "'pitch'" -command "ReplaceSuffix $entry pitch; focus $entry" -foreground black
	$menu add command -label "'frq'"   -command "ReplaceSuffix $entry frq; focus $entry" -foreground black
}

proc ForceSuffix {e suffix} {
	set str [$e get]
	if {[string length $str] <= 0} {
		Inf "No Name To Add Suffix To"
		return
	}
	append str "_" $suffix
	ForceVal $e $str
}

proc ReplaceSuffix {e suffix} {
	set str [$e get]
	if {[string length $str] <= 0} {
		Inf "No Name To Add Suffix To"
		return
	}
	set k [string last "_" $str]
	if {$k < 0} {
		Inf "No Suffix To Replace"
		return
	}
	set str [string range $str 0 $k]
	append str $suffix
	ForceVal $e $str
}

proc InstallMeterKeystrokes {f} {
	global bindF1 bindControl_F1 bindControl_Shift_F1 bindCommand_F1 bindCommand_Shift_F1 bindShift_F2 bindShift_F3 bindShift_F4
	global bindShift_F5 bindShift_F6 bindShift_F7 bindShift_F8 bindShift_F9 bindShift_F10 bindShift_F11 bindShift_F12
	global bindF2 bindF3 bindF4 bindF5 bindF6 bindF7 bindF8 bindF9 bindF10 bindF11 bindF12 bindControl_F2 bindControl_F3
	global bindControl_F4 bindControl_F5 bindControl_F6 bindControl_F7 bindControl_F8 bindControl_F9 bindControl_F10
	global bindControl_F11 bindControl_F12 bindCommand_F2 bindCommand_F3 bindCommand_F4 bindCommand_F5 bindCommand_F6 bindCommand_F7 bindCommand_F8
	global bindCommand_F9 bindCommand_F10 bindCommand_F11 bindCommand_F12 bindControl_Command_F2 bindControl_Command_F3 bindControl_Command_F4
	global bindControl_Command_F5 bindControl_Command_F6 bindControl_Command_F7 bindControl_Command_F8 bindControl_Command_F9 bindControl_Command_F10
	global bindControl_Command_F11 bindControl_Command_F12 bindControl_Key_r

	set bindF1 [bind $f.k.t <F1>]
	set bindControl_F1 [bind $f.k.t <Control-F1>]
	set bindControl_Shift_F1 [bind $f.k.t <Control-Shift-F1>]
	set bindCommand_F1 [bind $f.k.t <Command-F1>]
	set bindCommand_Shift_F1 [bind $f.k.t <Command-Shift-F1>]

	set bindShift_F2 [bind $f.k.t <Shift-F2>]
	set bindShift_F3 [bind $f.k.t <Shift-F3>]
	set bindShift_F4 [bind $f.k.t <Shift-F4>]
	set bindShift_F5 [bind $f.k.t <Shift-F5>]
	set bindShift_F6 [bind $f.k.t <Shift-F6>]
	set bindShift_F7 [bind $f.k.t <Shift-F7>]
	set bindShift_F8 [bind $f.k.t <Shift-F8>]
	set bindShift_F9 [bind $f.k.t <Shift-F9>]
	set bindShift_F10 [bind $f.k.t <Shift-F10>]
	set bindShift_F11 [bind $f.k.t <Shift-F11>]
	set bindShift_F12 [bind $f.k.t <Shift-F12>]
	set bindF2 [bind $f.k.t <F2>]
	set bindF3 [bind $f.k.t <F3>]
	set bindF4 [bind $f.k.t <F4>]
	set bindF5 [bind $f.k.t <F5>]
	set bindF6 [bind $f.k.t <F6>]
	set bindF7 [bind $f.k.t <F7>]
	set bindF8 [bind $f.k.t <F8>]
	set bindF9 [bind $f.k.t <F9>]
	set bindF10 [bind $f.k.t <F10>]
	set bindF11 [bind $f.k.t <F11>]
	set bindF12 [bind $f.k.t <F12>]
	set bindControl_F2 [bind $f.k.t <Control-F2>]
	set bindControl_F3 [bind $f.k.t <Control-F3>]
	set bindControl_F4 [bind $f.k.t <Control-F4>]
	set bindControl_F5 [bind $f.k.t <Control-F5>]
	set bindControl_F6 [bind $f.k.t <Control-F6>]
	set bindControl_F7 [bind $f.k.t <Control-F7>]
	set bindControl_F8 [bind $f.k.t <Control-F8>]
	set bindControl_F9 [bind $f.k.t <Control-F9>]
	set bindControl_F10 [bind $f.k.t <Control-F10>]
	set bindControl_F11 [bind $f.k.t <Control-F11>]
	set bindControl_F12 [bind $f.k.t <Control-F12>]
	set bindCommand_F2 [bind $f.k.t <Command-F2>]
	set bindCommand_F3 [bind $f.k.t <Command-F3>]
	set bindCommand_F4 [bind $f.k.t <Command-F4>]
	set bindCommand_F5 [bind $f.k.t <Command-F5>]
	set bindCommand_F6 [bind $f.k.t <Command-F6>]
	set bindCommand_F7 [bind $f.k.t <Command-F7>]
	set bindCommand_F8 [bind $f.k.t <Command-F8>]
	set bindCommand_F9 [bind $f.k.t <Command-F9>]
	set bindCommand_F10 [bind $f.k.t <Command-F10>]
	set bindCommand_F11 [bind $f.k.t <Command-F11>]
	set bindCommand_F12 [bind $f.k.t <Command-F12>]
	set bindControl_Command_F2 [bind $f.k.t <Control-Command-F2>]
	set bindControl_Command_F3 [bind $f.k.t <Control-Command-F3>]
	set bindControl_Command_F4 [bind $f.k.t <Control-Command-F4>]
	set bindControl_Command_F5 [bind $f.k.t <Control-Command-F5>]
	set bindControl_Command_F6 [bind $f.k.t <Control-Command-F6>]
	set bindControl_Command_F7 [bind $f.k.t <Control-Command-F7>]
	set bindControl_Command_F8 [bind $f.k.t <Control-Command-F8>]
	set bindControl_Command_F9 [bind $f.k.t <Control-Command-F9>]
	set bindControl_Command_F10 [bind $f.k.t <Control-Command-F10>]
	set bindControl_Command_F11 [bind $f.k.t <Control-Command-F11>]
	set bindControl_Command_F12 [bind $f.k.t <Control-Command-F12>]
	set bindControl_Key_r [bind $f.k.t <Control-Key-r>]

	bind $f.k.t <F1> {}
	bind $f.k.t <Control-F1> {}
	bind $f.k.t <Control-Shift-F1> {}
	bind $f.k.t <Command-F1> {}
	bind $f.k.t <Command-Shift-F1> {}
	bind $f.k.t <Shift-F2> {}
	bind $f.k.t <Shift-F3> {}
	bind $f.k.t <Shift-F4> {}
	bind $f.k.t <Shift-F5> {}
	bind $f.k.t <Shift-F6> {}
	bind $f.k.t <Shift-F7> {}
	bind $f.k.t <Shift-F8> {}
	bind $f.k.t <Shift-F9> {}
	bind $f.k.t <Shift-F10> {}
	bind $f.k.t <Shift-F11> {}
	bind $f.k.t <Shift-F12> {}
	bind $f.k.t <F2> {}
	bind $f.k.t <F3> {}
	bind $f.k.t <F4> {}
	bind $f.k.t <F5> {}
	bind $f.k.t <F6> {}
	bind $f.k.t <F7> {}
	bind $f.k.t <F8> {}
	bind $f.k.t <F9> {}
	bind $f.k.t <F10> {}
	bind $f.k.t <F11> {}
	bind $f.k.t <F12> {}
	bind $f.k.t <Control-F2> {}
	bind $f.k.t <Control-F3> {}
	bind $f.k.t <Control-F4> {}
	bind $f.k.t <Control-F5> {}
	bind $f.k.t <Control-F6> {}
	bind $f.k.t <Control-F7> {}
	bind $f.k.t <Control-F8> {}
	bind $f.k.t <Control-F9> {}
	bind $f.k.t <Control-F10> {}
	bind $f.k.t <Control-F11> {}
	bind $f.k.t <Control-F12> {}
	bind $f.k.t <Command-F2> {}
	bind $f.k.t <Command-F3> {}
	bind $f.k.t <Command-F4> {}
	bind $f.k.t <Command-F5> {}
	bind $f.k.t <Command-F6> {}
	bind $f.k.t <Command-F7> {}
	bind $f.k.t <Command-F8> {}
	bind $f.k.t <Command-F9> {}
	bind $f.k.t <Command-F10> {}
	bind $f.k.t <Command-F11> {}
	bind $f.k.t <Command-F12> {}
	bind $f.k.t <Control-Command-F2> {}
	bind $f.k.t <Control-Command-F3> {}
	bind $f.k.t <Control-Command-F4> {}
	bind $f.k.t <Control-Command-F5> {}
	bind $f.k.t <Control-Command-F6> {}
	bind $f.k.t <Control-Command-F7> {}
	bind $f.k.t <Control-Command-F8> {}
	bind $f.k.t <Control-Command-F9> {}
	bind $f.k.t <Control-Command-F10> {}
	bind $f.k.t <Control-Command-F11> {}
	bind $f.k.t <Control-Command-F12> {}
	bind $f.k.t <Control-Key-r> {}

	bind $f.k.t <F1> "NextLineNo $f.k.t"
	bind $f.k.t <Control-F1> "$f.k.t insert end 1="
	bind $f.k.t <Control-Shift-F1> "$f.k.t insert end 2="
	bind $f.k.t <Command-F1> "$f.k.t insert end .5="
	bind $f.k.t <Command-Shift-F1> "$f.k.t insert end 1.5="
	bind $f.k.t <Shift-F2> "$f.k.t insert end 2:2"
	bind $f.k.t <Shift-F3> "$f.k.t insert end 3:2"
	bind $f.k.t <Shift-F4> "$f.k.t insert end 4:2"
	bind $f.k.t <Shift-F5> "$f.k.t insert end 5:2"
	bind $f.k.t <Shift-F6> "$f.k.t insert end 6:2"
	bind $f.k.t <Shift-F7> "$f.k.t insert end 7:2"
	bind $f.k.t <Shift-F8> "$f.k.t insert end 8:2"
	bind $f.k.t <Shift-F9> "$f.k.t insert end 9:2"
	bind $f.k.t <Shift-F10> "$f.k.t insert end 10:2"
	bind $f.k.t <Shift-F11> "$f.k.t insert end 11:2"
	bind $f.k.t <Shift-F12> "$f.k.t insert end 12:2"
	bind $f.k.t <F2> "$f.k.t insert end 2:4"
	bind $f.k.t <F3> "$f.k.t insert end 3:4"
	bind $f.k.t <F4> "$f.k.t insert end 4:4"
	bind $f.k.t <F5> "$f.k.t insert end 5:4"
	bind $f.k.t <F6> "$f.k.t insert end 6:4"
	bind $f.k.t <F7> "$f.k.t insert end 7:4"
	bind $f.k.t <F8> "$f.k.t insert end 8:4"
	bind $f.k.t <F9> "$f.k.t insert end 9:4"
	bind $f.k.t <F10> "$f.k.t insert end 10:4"
	bind $f.k.t <F11> "$f.k.t insert end 11:4"
	bind $f.k.t <F12> "$f.k.t insert end 12:4"
	bind $f.k.t <Control-F2> "$f.k.t insert end 2:8"
	bind $f.k.t <Control-F3> "$f.k.t insert end 3:8"
	bind $f.k.t <Control-F4> "$f.k.t insert end 4:8"
	bind $f.k.t <Control-F5> "$f.k.t insert end 5:8"
	bind $f.k.t <Control-F6> "$f.k.t insert end 6:8"
	bind $f.k.t <Control-F7> "$f.k.t insert end 7:8"
	bind $f.k.t <Control-F8> "$f.k.t insert end 8:8"
	bind $f.k.t <Control-F9> "$f.k.t insert end 9:8"
	bind $f.k.t <Control-F10> "$f.k.t insert end 10:8"
	bind $f.k.t <Control-F11> "$f.k.t insert end 11:8"
	bind $f.k.t <Control-F12> "$f.k.t insert end 12:8"
	bind $f.k.t <Command-F2> "$f.k.t insert end 2:16"
	bind $f.k.t <Command-F3> "$f.k.t insert end 3:16"
	bind $f.k.t <Command-F4> "$f.k.t insert end 4:16"
	bind $f.k.t <Command-F5> "$f.k.t insert end 5:16"
	bind $f.k.t <Command-F6> "$f.k.t insert end 6:16"
	bind $f.k.t <Command-F7> "$f.k.t insert end 7:16"
	bind $f.k.t <Command-F8> "$f.k.t insert end 8:16"
	bind $f.k.t <Command-F9> "$f.k.t insert end 9:16"
	bind $f.k.t <Command-F10> "$f.k.t insert end 10:16"
	bind $f.k.t <Command-F11> "$f.k.t insert end 11:16"
	bind $f.k.t <Command-F12> "$f.k.t insert end 12:16"
	bind $f.k.t <Control-Command-F2> "$f.k.t insert end 2:32"
	bind $f.k.t <Control-Command-F3> "$f.k.t insert end 3:32"
	bind $f.k.t <Control-Command-F4> "$f.k.t insert end 4:32"
	bind $f.k.t <Control-Command-F5> "$f.k.t insert end 5:32"
	bind $f.k.t <Control-Command-F6> "$f.k.t insert end 6:32"
	bind $f.k.t <Control-Command-F7> "$f.k.t insert end 7:32"
	bind $f.k.t <Control-Command-F8> "$f.k.t insert end 8:32"
	bind $f.k.t <Control-Command-F9> "$f.k.t insert end 9:32"
	bind $f.k.t <Control-Command-F10> "$f.k.t insert end 10:32"
	bind $f.k.t <Control-Command-F11> "$f.k.t insert end 11:32"
	bind $f.k.t <Control-Command-F12> "$f.k.t insert end 12:32"
	bind $f.k.t <Control-Key-r> "RenumberClikLines $f.k.t"
}

#--- Unbind Function Keys

proc UninstallMeterKeystrokes {f} {
	global bindF1 bindControl_F1 bindControl_Shift_F1 bindCommand_F1 bindCommand_Shift_F1 bindShift_F2 bindShift_F3 bindShift_F4
	global bindShift_F5 bindShift_F6 bindShift_F7 bindShift_F8 bindShift_F9 bindShift_F10 bindShift_F11 bindShift_F12
	global bindF2 bindF3 bindF4 bindF5 bindF6 bindF7 bindF8 bindF9 bindF10 bindF11 bindF12 bindControl_F2 bindControl_F3
	global bindControl_F4 bindControl_F5 bindControl_F6 bindControl_F7 bindControl_F8 bindControl_F9 bindControl_F10
	global bindControl_F11 bindControl_F12 bindCommand_F2 bindCommand_F3 bindCommand_F4 bindCommand_F5 bindCommand_F6 bindCommand_F7 bindCommand_F8
	global bindCommand_F9 bindCommand_F10 bindCommand_F11 bindCommand_F12 bindControl_Command_F2 bindControl_Command_F3 bindControl_Command_F4
	global bindControl_Command_F5 bindControl_Command_F6 bindControl_Command_F7 bindControl_Command_F8 bindControl_Command_F9 bindControl_Command_F10
	global bindControl_Command_F11 bindControl_Command_F12 bindControl_Key_r

	if {[info exists bindF1]} {
		bind $f.k.t <F1> {}
		bind $f.k.t <Control-F1> {}
		bind $f.k.t <Control-Shift-F1> {}
		bind $f.k.t <Command-F1> {}
		bind $f.k.t <Command-Shift-F1> {}
		bind $f.k.t <Shift-F2> {}
		bind $f.k.t <Shift-F3> {}
		bind $f.k.t <Shift-F4> {}
		bind $f.k.t <Shift-F5> {}
		bind $f.k.t <Shift-F6> {}
		bind $f.k.t <Shift-F7> {}
		bind $f.k.t <Shift-F8> {}
		bind $f.k.t <Shift-F9> {}
		bind $f.k.t <Shift-F10> {}
		bind $f.k.t <Shift-F11> {}
		bind $f.k.t <Shift-F12> {}
		bind $f.k.t <F2> {}
		bind $f.k.t <F3> {}
		bind $f.k.t <F4> {}
		bind $f.k.t <F5> {}
		bind $f.k.t <F6> {}
		bind $f.k.t <F7> {}
		bind $f.k.t <F8> {}
		bind $f.k.t <F9> {}
		bind $f.k.t <F10> {}
		bind $f.k.t <F11> {}
		bind $f.k.t <F12> {}
		bind $f.k.t <Control-F2> {}
		bind $f.k.t <Control-F3> {}
		bind $f.k.t <Control-F4> {}
		bind $f.k.t <Control-F5> {}
		bind $f.k.t <Control-F6> {}
		bind $f.k.t <Control-F7> {}
		bind $f.k.t <Control-F8> {}
		bind $f.k.t <Control-F9> {}
		bind $f.k.t <Control-F10> {}
		bind $f.k.t <Control-F11> {}
		bind $f.k.t <Control-F12> {}
		bind $f.k.t <Command-F2> {}
		bind $f.k.t <Command-F3> {}
		bind $f.k.t <Command-F4> {}
		bind $f.k.t <Command-F5> {}
		bind $f.k.t <Command-F6> {}
		bind $f.k.t <Command-F7> {}
		bind $f.k.t <Command-F8> {}
		bind $f.k.t <Command-F9> {}
		bind $f.k.t <Command-F10> {}
		bind $f.k.t <Command-F11> {}
		bind $f.k.t <Command-F12> {}
		bind $f.k.t <Control-Command-F2> {}
		bind $f.k.t <Control-Command-F3> {}
		bind $f.k.t <Control-Command-F4> {}
		bind $f.k.t <Control-Command-F5> {}
		bind $f.k.t <Control-Command-F6> {}
		bind $f.k.t <Control-Command-F7> {}
		bind $f.k.t <Control-Command-F8> {}
		bind $f.k.t <Control-Command-F9> {}
		bind $f.k.t <Control-Command-F10> {}
		bind $f.k.t <Control-Command-F11> {}
		bind $f.k.t <Control-Command-F12> {}
		bind $f.k.t <Control-Key-r> {}

		bind $f.k.t <F1> $bindF1
		bind $f.k.t <Control-F1> $bindControl_F1
		bind $f.k.t <Control-Shift-F1> $bindControl_Shift_F1
		bind $f.k.t <Command-F1> $bindCommand_F1
		bind $f.k.t <Command-Shift-F1> $bindCommand_Shift_F1
		bind $f.k.t <Shift-F2> $bindShift_F2
		bind $f.k.t <Shift-F3> $bindShift_F3
		bind $f.k.t <Shift-F4> $bindShift_F4
		bind $f.k.t <Shift-F5> $bindShift_F5
		bind $f.k.t <Shift-F6> $bindShift_F6
		bind $f.k.t <Shift-F7> $bindShift_F7
		bind $f.k.t <Shift-F8> $bindShift_F8
		bind $f.k.t <Shift-F9> $bindShift_F9
		bind $f.k.t <Shift-F10> $bindShift_F10
		bind $f.k.t <Shift-F11> $bindShift_F11
		bind $f.k.t <Shift-F12> $bindShift_F12
		bind $f.k.t <F2> $bindF2
		bind $f.k.t <F3> $bindF3
		bind $f.k.t <F4> $bindF4
		bind $f.k.t <F5> $bindF5
		bind $f.k.t <F6> $bindF6
		bind $f.k.t <F7> $bindF7
		bind $f.k.t <F8> $bindF8
		bind $f.k.t <F9> $bindF9
		bind $f.k.t <F10> $bindF10
		bind $f.k.t <F11> $bindF11
		bind $f.k.t <F12> $bindF12
		bind $f.k.t <Control-F2> $bindControl_F2
		bind $f.k.t <Control-F3> $bindControl_F3
		bind $f.k.t <Control-F4> $bindControl_F4
		bind $f.k.t <Control-F5> $bindControl_F5
		bind $f.k.t <Control-F6> $bindControl_F6
		bind $f.k.t <Control-F7> $bindControl_F7
		bind $f.k.t <Control-F8> $bindControl_F8
		bind $f.k.t <Control-F9> $bindControl_F9
		bind $f.k.t <Control-F10> $bindControl_F10
		bind $f.k.t <Control-F11> $bindControl_F11
		bind $f.k.t <Control-F12> $bindControl_F12
		bind $f.k.t <Command-F2> $bindCommand_F2
		bind $f.k.t <Command-F3> $bindCommand_F3
		bind $f.k.t <Command-F4> $bindCommand_F4
		bind $f.k.t <Command-F5> $bindCommand_F5
		bind $f.k.t <Command-F6> $bindCommand_F6
		bind $f.k.t <Command-F7> $bindCommand_F7
		bind $f.k.t <Command-F8> $bindCommand_F8
		bind $f.k.t <Command-F9> $bindCommand_F9
		bind $f.k.t <Command-F10> $bindCommand_F10
		bind $f.k.t <Command-F11> $bindCommand_F11
		bind $f.k.t <Command-F12> $bindCommand_F12
		bind $f.k.t <Control-Command-F2> $bindControl_Command_F2
		bind $f.k.t <Control-Command-F3> $bindControl_Command_F3
		bind $f.k.t <Control-Command-F4> $bindControl_Command_F4
		bind $f.k.t <Control-Command-F5> $bindControl_Command_F5
		bind $f.k.t <Control-Command-F6> $bindControl_Command_F6
		bind $f.k.t <Control-Command-F7> $bindControl_Command_F7
		bind $f.k.t <Control-Command-F8> $bindControl_Command_F8
		bind $f.k.t <Control-Command-F9> $bindControl_Command_F9
		bind $f.k.t <Control-Command-F10> $bindControl_Command_F10
		bind $f.k.t <Control-Command-F11> $bindControl_Command_F11
		bind $f.k.t <Control-Command-F12> $bindControl_Command_F12
		bind $f.k.t <Control-Key-r> $bindControl_Key_r
	}
}

#---- Insert Next Line Number
#
# NB Structure for extracting lines from a TEXT WDIGET, esp way to Find END LINE INDEX!!
#

proc NextLineNo {t} {

	for {set n [expr int(round([$t index end]))]} {$n > 0} {incr n -1} {
		set line [$t get $n.0 $n.end]
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		set line [split $line]
		set lineno [lindex $line 0]
		if {([string first ";" $lineno] >= 0) || ([string first "(" $lineno] >= 0)} {
			unset lineno
			continue
		}
		if {![regexp {^[0-9]+$} $lineno]} {
			Inf "Bad Line Number '$lineno': check line numbers are not stringing together at very end of file"
			break
		}
		incr lineno
		if {($lineno >= 100000) && !($checkbadlineno)} {
			Inf "Very large line number: check line numbers are not stringing together at very end of file"
		}
		$t insert end $lineno
		break
	}
	if {![info exists lineno]} {
		Inf "No numbered lines : cannot generate next line number"
		return
	}
}

#---- Renumber Lines in CLick Data File

proc RenumberClikLines {t} {
	set newlineno 1
	set lastbumline -1
	for {set n 1} {$n <= [expr int(round([$t index end]))]} {incr n} {
		set line [$t get $n.0 $n.end]
		set line [string trim $line]
		if {[string length $line] <= 0} {
			lappend lines $line
			continue
		}
		set line [split $line]
		set lineno [lindex $line 0]
		if {([string first ";" $lineno] >= 0) || ([string first "(" $lineno] >= 0)} {
			lappend lines $line
			unset lineno
			continue
		}
		if {![regexp {^[0-9]+$} $lineno]} {
			Inf "Bad Line Number '$lineno': check line numbers are not stringing together at very end of file"
			break
		}
		set lineno $newlineno
		incr newlineno
		set line [lreplace $line 0 0 $lineno]
		lappend lines $line
	}
	if {![info exists lineno]} {
		Inf "No numbered lines to Renumber!"
		return
	}
	$t delete 1.0 end	
	set m 0
	foreach line $lines {
		set n 0
		catch {unset outline}
		foreach item $line {
			if {[string length $item] <= 0} {
				continue
			}
			if {$n} {
				append outline "\t"
			}
			append outline $item
			incr n
		}
		if {$m} {
			$t insert end "\n"
		}
		incr m
		if {[info exists outline]} {
			$t insert end "$outline"
		} else {
			set lastbumline $m
		}
	}
	if {$m == $lastbumline} {
		set k [expr int(round([$t index end]))]
		$t delete $k.0 "$k.end +1 char"
		incr k -1
		$t see $k.0
	}
}

#----- Make Duplicate copies of textfile

proc DuplicateTextfile {} {
	global wl ch pr_du tx_dupl tx_duplcnt pa evv sl_real rememd propfiles_list

	if {!$sl_real} {
		Inf "If You Select A Textfile\nYou Can Make (Multiplie) Copies Of It"
		return
	}
	set ilist [$wl curselection]
	if {[llength $ilist] != 1} {
		Inf "This Option Only Works With A Single Selected File"
		return
	}
	set fnam [$wl get [lindex $ilist 0]]
	if {![info exists pa($fnam,$evv(FTYP))] } {
		Inf "File Data Missing"
		return
	}
	if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
		Inf "Selected File Is Not A Textfile"
		return
	}
	set save_mixmanage 0
	set nessupdate 0
	if {[info exists propfiles_list]} {
		set is_a_known_propfile [lsearch -exact $propfiles_list $fnam]
	} else {
		set is_a_known_propfile -1
	}
	set f .textdupl
	if [Dlg_Create $f "DUPLICATE TEXTFILE" "set pr_du 0" -width 40 -borderwidth $evv(SBDR)] {
		set a [frame $f.a -borderwidth $evv(SBDR)]
		set b [frame $f.b -borderwidth $evv(SBDR)]
		set c [frame $f.c -borderwidth $evv(SBDR)]
		button $a.qu -text Close -command "set pr_du 0" -highlightbackground [option get . background {}]
		button $a.do -text "Copy" -command "set pr_du 1" -highlightbackground [option get . background {}]
		pack $a.do -side left -pady 2
		pack $a.qu -side right -pady 2
		label $b.ll -text "Generic Name of output files"
		entry $b.ee -textvariable tx_dupl -width 24
		pack $b.ll $b.ee -side left
		label $c.ll -text "Number of copies to make"
		entry $c.ee -textvariable tx_duplcnt -width 24
		pack $c.ll $c.ee -side left
		pack $a $b $c -side top -fill x -expand true
		wm resizable $f 1 1
		bind $f.b.ee <Down> {focus .textdupl.c.ee}
		bind $f.b.ee <Up> {focus .textdupl.c.ee}
		bind $f.c.ee <Down> {focus .textdupl.b.ee}
		bind $f.c.ee <Up> {focus .textdupl.b.ee}
		bind $f <Return> {set pr_du 1}
		bind $f <Escape> {set pr_du 0}
	}
	set in_ext [file extension $fnam]
	set tx_dupl ""
	set tx_duplcnt 1
	raise $f
	set pr_du 0
	set finished 0
	My_Grab 0 $f pr_du $f.b.ee
	while {!$finished} {
		tkwait variable pr_du
		if {$pr_du} {
			if {![ValidCdpFilename $tx_dupl 1]} {
				continue
			} elseif {![regexp {^[0-9]+$} $tx_duplcnt] || ($tx_duplcnt < 1)} {
				Inf "Invalid Value Given For Number Of Copies Required (integer >= 1)"
				continue
			}
			set cnt 0
			set tx_dupl [string tolower $tx_dupl]
			if {$tx_duplcnt == 1} {
				set thisfnam $tx_dupl$in_ext
				if {[file exists $thisfnam]} {
					Inf "A File Named '	$thisfnam' Already Exists: Cannot Proceed"
					continue
				}
			} else {
				while {$cnt < $tx_duplcnt} {
					set thisfnam $tx_dupl$cnt$in_ext
					if {[file exists $thisfnam]} {
						Inf "A File Named '	$thisfnam' Already Exists: Cannot Proceed"
						break
					}
					incr cnt
				}
				if {$cnt != $tx_duplcnt} {
					continue
				}
			}
			set cnt 0
			if {$tx_duplcnt == 1} {
				set thisfnam $tx_dupl$in_ext
				if [catch {file copy $fnam $thisfnam} zit] {
					lappend fails $thisfnam
				} else {
					lappend succeeds $thisfnam
				}
			} else {
				while {$cnt < $tx_duplcnt} {
					set thisfnam $tx_dupl$cnt$in_ext
					if [catch {file copy $fnam $thisfnam} zit] {
						lappend fails $thisfnam
					} else {
						lappend succeeds $thisfnam
					}
					incr cnt
				}
			}
			if [info exists fails] {
				set cnt 0
				set msg "Failed To Generate The Following Copies\n"
				foreach fnam $fails {
					if {$cnt > 20} {
						append msg "And More\n"
						break
					}
					append msg $fnam "\n"
					incr cnt
				}
				Inf $msg
			}
			if [info exists succeeds] {
				set succeeds [ReverseList $succeeds]
				foreach thisfnam $succeeds {
					UpdateBakupLog $thisfnam create 1
					$wl insert 0 $thisfnam
					WkspCnt $thisfnam 1
					set propno 0
					while {$propno < ($evv(CDP_PROPS_CNT) + $evv(CDP_MAXSAMP_CNT))} {
						if {[info exists pa($fnam,$propno)]} {
							set pa($thisfnam,$propno) $pa($fnam,$propno)
						}
						incr propno
					}
					if {$is_a_known_propfile >= 0} {
						AddToPropfilesList $thisfnam
					} elseif {[CopiedIfAMix $fnam $thisfnam 0]} {
						set save_mixmanage 1
					} elseif {[CopiedIfANess $fnam $thisfnam 0]} {
						set nessupdate 1
					}
				}
				catch {unset rememd}
				Inf "The Copied Files Are On The Workspace"
				break
			} else {
				Inf "Failed To Make Any Copies"
				continue
			}
		} else {
			break
		}
	}
	if {$save_mixmanage} {
		MixMStore
	}
	if {$nessupdate} {
		NessMstore
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc DuplicateSeveralTextfiles {} {
	global wl ch pr_du2 tx_dupl2 tx_duplcnt2 pa evv sl_real rememd propfiles_list

	if {!$sl_real} {
		Inf "If You Select Several Textfiles\nYou Can Make Copies Of Them"
		return
	}
	set ilist [$wl curselection]
	if {[llength $ilist] < 0} {
		Inf "No Files Selected"
		return
	}
	foreach i $ilist {
		set fnam [$wl get $i]
		if {![info exists pa($fnam,$evv(FTYP))] } {
			Inf "File Data Missing"
			return
		}
		if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
			Inf "Selected File Is Not A Textfile"
			return
		}
		lappend fnams $fnam
	}
	set save_mixmanage 0
	set nessupdate 0
	set f .textdupl2
	if [Dlg_Create $f "DUPLICATE TEXTFILES" "set pr_du2 0" -width 40 -borderwidth $evv(SBDR)] {
		set a [frame $f.a -borderwidth $evv(SBDR)]
		set b [frame $f.b -borderwidth $evv(SBDR)]
		button $a.qu -text Close -command "set pr_du2 0" -highlightbackground [option get . background {}]
		button $a.do -text "Copy" -command "set pr_du2 1" -highlightbackground [option get . background {}]
		pack $a.do -side left -pady 2
		pack $a.qu -side right -pady 2
		label $b.ll -text "Generic Extension"
		entry $b.ee -textvariable tx_dupl2 -width 24
		pack $b.ll $b.ee -side left
		pack $a $b -side top -fill x -expand true
		wm resizable $f 1 1
		bind $f <Return> {set pr_du2 1}
		bind $f <Escape> {set pr_du2 0}
	}
	set tx_dupl2 ""
	set tx_duplcnt2 0
	raise $f
	set pr_du2 0
	set finished 0
	My_Grab 0 $f pr_du2 $f.b.ee
	while {!$finished} {
		tkwait variable pr_du2
		if {$pr_du2} {
			if {[string length $tx_dupl2] <= 0} {
				Inf "No Generic Extension Entered"
				continue
			}
			catch {unset nunames}
			set OK 1
			foreach fnam $fnams {
				set nuname [file rootname $fnam]
				set ext [file extension $fnam]
				append nuname "_" $tx_dupl2
				if {![ValidCdpFilename $nuname 1]} {
					set OK 0
					break
				}
				append nuname $ext
				if {[file exists $nuname]} {
					Inf "A File Named '	$nuname' Already Exists: Cannot Proceed"
					set OK 0
					break
				}
				lappend nunames $nuname
			}
			if {!$OK} {
				continue
			}
			set cnt 0
			set xcnt 0
			catch {unset badfiles}
			set nunames [ReverseList $nunames]
			foreach fnam $fnams nuname $nunames {
				if [catch {file copy $fnam $nuname} zit] {
					lappend badfiles $fnam
					incr cnt
					continue
				}
				UpdateBakupLog $nuname create 1
				DummyHistory $nuname "CREATED"
				set propno 0
				while {$propno < ($evv(CDP_PROPS_CNT) + $evv(CDP_MAXSAMP_CNT))} {
					if {[info exists pa($fnam,$propno)]} {
						set pa($nuname,$propno) $pa($fnam,$propno)
					}
					incr propno
				}
				if {[CopiedIfAMix $fnam $nuname 0]} {
					set save_mixmanage 1
				} elseif {[CopiedIfANess $fnam $nuname 0]} {
					set nessupdate 1
				}
				if {[info exists propfiles_list]} { 
					set k [lsearch $propfiles_list $fnam]
					if {$k >= 0} {
						AddToPropfilesList $nuname
					}
				}
				$wl insert 0 $nuname
				WkspCnt $nuname 1
				catch {unset rememd}
				incr xcnt
				incr cnt
			}
			if {$xcnt == 0} {
				Inf "Failed To Rename Any Of These Files"
				continue
			}
			if {$cnt != $xcnt} {
				set msg "Failed To Rename The Followng Files\n"
				set cnt 0
				foreach fnam $badfiles {
					if {$cnt > 20} {
						append msg "\nAnd More"
						break
					}
					append msg $fnam  "   "
					incr cnt
				}
				Inf $msg
			}
			catch {unset rememd}
			Inf "The Copied Files Are On The Workspace"
			set finished 1
		} else {
			break
		}
	}
	if {$save_mixmanage} {
		MixMStore
	}
	if {$nessupdate} {
		NessMStore
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc PostTextfile {kill} {
	global pr_post ptext_sfs wl posted_files pa evv

	set f .ptextdisplay
	if {$kill}  {
		catch {destroy $f}
		catch {unset posted_files}
		return
	}
	set ilist [$wl curselection]
	if {![info exists ilist] || ([llength $ilist] <= 0)} {
		Inf "No Files Selected"
		return
	} 
	foreach i $ilist {
		set fnam [$wl get $i]
		if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
			Inf "Select Textfiles Only"
			return
		} 
		lappend fnams $fnam
	}
	if [winfo exists $f] {
		set pr_post 0		;#	THIS BREAKS THE tkwait LOOP FROM THE LAST CALL TO THIS FUNC
		catch {unset posted_files}
	}
	set posted_files $fnams
	if [Dlg_Create $f "" "destroy $f" -borderwidth $evv(BBDR)] {
		frame $f.0 -borderwidth $evv(SBDR)
		button $f.0.ok -text "To Workspace" -width 14 -command "set pr_post 1 ; focus .workspace" -highlightbackground [option get . background {}]
			;#	WHEN FUNCTION IS CALLED, ABOVE 1st COMMAND RETURNS FOCUS TO WORKSPACE
			;#	WHEN FUNCTION IS NOT CALLED, BUT WINDOW HAS FOCUS, ABOVE 2nd COMMAND RETURNS FOCUS TO WORKSPACE
		set s  [frame $f.see -borderwidth $evv(SBDR)]
		set ptext_sfs [text $s.seefile -width 128 -height 20 -yscrollcommand "$s.sy set"]
		scrollbar $s.sy -orient vert -command "$s.seefile yview"
		pack $s.seefile -side left -fill both -expand true
		pack $s.sy -side right -fill y -expand true
		pack $f.0.ok -side left
		pack $f.0 $f.see -side top -pady 2
	}
	set msg "PERMANENT DISPLAY OF [lindex $fnams 0]"
	if {[llength $fnams] > 1} {
		append msg "  AND OTHER FILES"
	}
	wm title $f $msg
	if {![PostFiles $fnams]} {
		destroy $f
		return		
	}
	set pr_post 0
	raise $f
	My_Grab 0 $f pr_post
	tkwait variable pr_post
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc ChangeCase {up} {
	if {![catch {selection get -displayof .npad.k.t} sel]} {
		set sel [string trim $sel]
		set len [string length $sel]
		if {$len <= 0} {
			return
		}
	}
	set n 0
	set nustr ""
	while {$n < $len} {
		set char [string index $sel $n]
		if {$up} {
			if {[regexp {[a-z]} $char]} {
				append nustr [string toupper $char]
			} else {
				append nustr $char
			}
		} else {
			if {[regexp {[A-Z]} $char]} {
				append nustr [string tolower $char]
			} else {
				append nustr $char
			}
		}
		incr n
	}
	set k [.npad.k.t tag ranges sel]
	.npad.k.t delete [lindex $k 0] [lindex $k 1]
	.npad.k.t insert [lindex $k 0] $nustr
}

proc PostRefresh {} {
	global posted_files
	if {![info exists posted_files]} {
		Inf "No Files Posted"
		return
	}
	foreach fnam $posted_files {
		if {![file exists $fnam]} {
			lappend badfiles $fnam
		} else {
			lappend goodfiles $fnam
		}
	}
	if {![info exists goodfiles]} {
		Inf "The Posted Files No Longer Exist"
		return
	}
	if {[info exists badfiles]} {
		set msg "The Following Posted Files No Longer Exist\n\n"
		set cnt 0
		foreach fnam $badfiles {
			incr cnt
			if {$cnt > 20} {
				append msg "\n\nAnd More"
				break
			}
			append msg $fnam "  "
		}
		Inf $msg
	}
	PostFiles $goodfiles
}

proc PostFiles {fnams} {
	global ptext_sfs
	$ptext_sfs config -state normal
	$ptext_sfs delete 1.0 end								;#	Clear the filelist window
	set separate 0
	set fcnt 0
	foreach fnam $fnams {
		if {$separate} {
			$ptext_sfs insert end "\n-------------------------------------------\n"
		}
		if [catch {open $fnam r} fileId] {
			Inf "Cannot Open File '$fnam': $fileId"		;#	If textfile cannot be opened
			set separate 0
			continue
		}
		set qq 0
		while {[gets $fileId thisline] >= 0} {			;#	Read lines from textfile into text-listing, avoiding extra newline
			if {$qq > 0} {
				$ptext_sfs insert end "\n"
			}
			$ptext_sfs insert end "$thisline"
			incr qq
		}
		close $fileId
		set separate 1
		incr fcnt
	}
	$ptext_sfs config -state disabled
	return $fcnt
}

proc PostGet {} {
	global posted_files ch chlist chcnt evv wl
	if {![info exists posted_files]} {
		Inf "No Files Posted"
		return
	}
	foreach fnam $posted_files {
		if {![file exists $fnam]} {
			lappend badfiles $fnam
		} else {
			if {[LstIndx $fnam $wl] < 0} {
				lappend notgot $fnam
			}
			lappend goodfiles $fnam
		}
	}
	if {[info exists notgot]} {
		set len [llength $notgot]
		set cnt 0
		while {$cnt < $len} {
			set fnam [lindex $notgot $cnt]
			set k [lsearch $goodfiles $fnam]
			set ftyp [FindFileType $fnam]
			if {($ftyp == -1) || !($ftyp & $evv(IS_A_TEXTFILE))} {
				if {$k >= 0} {
					set goodfiles [lreplace $goodfiles $k $k]
				}
				incr cnt
				continue
			}
			if {[FileToWkspace $fnam 0 0 0 0 0] <= 0} {
				if {$k >= 0} {
					set goodfiles [lreplace $goodfiles $k $k]
				}
				incr cnt
				continue
			}					
			set notgot [lreplace $notgot $cnt $cnt]
			incr len -1
		}
		if {[llength $notgot] > 0} {
			set msg "The Following Posted Files No Longer Exist As Textfiles, Or Cannot Be Loaded To The Workspace\n\n"
			set cnt 0
			foreach fnam $notgot {
				incr cnt
				if {$cnt > 20} {
					append msg "\n\nAnd More"
					break
				}
				append msg $fnam "  "
			}
			Inf $msg
			if {[llength $goodfiles] <= 0} {
				return
			} 
		}
	}
	if {![info exists goodfiles]} {
		Inf "the Posted Files No Longer Exist"
		return
	}
	if {[info exists badfiles]} {
		set msg "The Following Posted Files No Longer Exist\n\n"
		set cnt 0
		foreach fnam $badfiles {
			incr cnt
			if {$cnt > 20} {
				append msg "\n\nAnd More"
				break
			}
			append msg $fnam "  "
		}
		Inf $msg
	}
	DoChoiceBak
	ClearWkspaceSelectedFiles
	foreach fnam $goodfiles {
		lappend chlist $fnam		;#	add to end of list
		$ch insert end $fnam		;#	add to end of display
		incr chcnt
	}
}

proc SndToMix {typ} {
	global wl wstk pa evv pr_sndtomix sndtomixname sndtomix_mix sndtomix_exists wstk sndtomix_ov sndtomix_over
	global chlist chcnt ch sndtomix_t sndtomix_b sndtomix_m sndtomix_after
	if {$typ == 9} {
		set ilist [$wl curselection]
		if {[lindex $ilist 0] < 0} {
			if {![info exists chlist] || ([llength $chlist] <= 0)} {
				Inf "No Files Selected"
				return
			} else {
				foreach fnam $chlist {
					set i [LstIndx $fnam $wl]
					lappend ilist $i
				}
			}
		}		
		set typ 8
	} elseif {($typ == 5) || ($typ == 6)} {
		if {![info exists chlist] || ([llength $chlist] <= 0)} {
			Inf "No Files Selected"
			return
		} else {
			set i 0
			while {$i < $chcnt} {
				lappend ilist $i
				incr i
			}
		}
	} else {
		set ilist [$wl curselection]
		if {[lindex $ilist 0] < 0} {
			Inf "No Files Selected"
			return
		}
	}
	set mixcnt 0
	catch {unset sndtomix_mix}
	foreach i $ilist {
		if {($typ == 5) || ($typ == 6)} {
			set fnam [$ch get $i]
		} else {
			set fnam [$wl get $i]
		}
		if {![info exists pa($fnam,$evv(FTYP))]} {
			Inf "Cannot Find Data On File $fnam"
			return
		}
		if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
			if {[IsAMixfileIncludingMultichan $pa($fnam,$evv(FTYP))]} {
				incr mixcnt
				if {$pa($fnam,$evv(FTYP)) == $evv(MIX_MULTI)} {
					set multichan 1
					set outchans $pa($fnam,$evv(OUT_CHANS))
				} else {
					set multichan 0
				}
				if {$mixcnt > 1} {
					Inf "Select Just One Mixfile With The Soundfiles"
					return
				}
				set sndtomix_mix $fnam
				continue
			} else {
				Inf "File $fnam Is Neither A Soundfile Nor A Mixfile"
				return
			}
		}
		lappend fnams $fnam
		lappend fnams $pa($fnam,$evv(CHANS))
	}
	if {![info exists fnams]} {
		if {[info exists sndtomix_mix]} {
			Inf "No Soundfiles Selected With The Mixfile"
		} else {
			Inf "No Valid Files Selected"
		}
		return
	}
	if {![info exists sndtomix_mix]} {
		Inf "No Mixfile Selected With The Soundfiles"
		return
	}
	if {($typ == 4) || ($typ == 5)} {
		if {[llength $fnams] != 4} {
			Inf "Select 2 Soundfiles With The Mixfile"
			return
		}
		if {$multichan} {
			if {[lindex $fnams 1] != [lindex $fnams 3]} {
				Inf "Sounds Do Not Have The Same Number Of Channels"
				return
			}
		}
	}
	if {$multichan} {
		foreach {fnam chans} $fnams {
			if {$chans > $outchans} {
				Inf "Cannot Add Or Substitute Files With More Than $outchans Channels Into This Multichannel Mix.\n"
				return
			}
		}
	} else {
		foreach {fnam chans} $fnams {
			if {$chans > 2} {
				Inf "Cannot Add Or Substitute Files With More Than 2 Channels Into Standard Mixfiles.\n\nCreate A Multichannel Mixfile Instead."
				return
			}
		}
	}
	set save_mixmanage 0
	set f .sndtomix
	if [Dlg_Create $f "Add Sound To Mixfile" "set pr_sndtomix 0" -borderwidth $evv(BBDR)] {
		set b [frame $f.b]
		set k [frame $f.k]		
		set k0 [frame $f.k0]		
		set kk [frame $f.kk]		
		set kkk [frame $f.kkk]		
		set j [frame $f.j]		
		set q [frame $f.q]		
		button $b.kp -text "Add Snds" -command "set pr_sndtomix 1" -highlightbackground [option get . background {}]
		label $b.ov -text "Overlay Existing Mix by"
		entry $b.e -textvariable sndtomix_ov -width 8
		label $b.ms -text "secs"
		button $b.v -text "Verify" -command "set pr_sndtomix 2" -highlightbackground [option get . background {}]
		button $b.ab -text "Abandon" -command "set pr_sndtomix 0" -highlightbackground [option get . background {}]
		pack $b.kp $b.ov $b.e $b.ms -side left -padx 2
		pack $b.ab $b.v -side right
		label $k.ll -text "out mixfile name"
		entry $k.e -textvariable sndtomixname -width 24
		label $k.ch -text "" -width 10
		checkbutton $k.re -variable sndtomix_over -text "overwrite"
		pack $k.ll $k.e $k.ch $k.re -side left
		label $k0.ll1 -text "UpArrow: increment name        DownArrow: decr name"
		label $k0.ll2 -text "Standard Names"
		pack $k0.ll1 $k0.ll2 -side top -pady 2
		button $kk.1 -text mix1 -command "set sndtomixname mix1" -highlightbackground [option get . background {}]
		button $kk.2 -text mix2 -command "set sndtomixname mix2" -highlightbackground [option get . background {}]
		button $kk.c -text mix_current -command "set sndtomixname mix_current" -highlightbackground [option get . background {}]
		pack $kk.1  $kk.2 $kk.c -side left -padx 2
		label $kkk.1 -text "At Time"
		entry $kkk.e -textvariable sndtomix_t -width 6
		checkbutton $kkk.1a -variable sndtomix_after -text "After\nLast Entry" -command {}
		label $kkk.2 -text "...or At Beat"
		entry $kkk.e2 -textvariable sndtomix_b -width 6
		label $kkk.3 -text "Tempo (MM)"
		entry $kkk.e3 -textvariable sndtomix_m -width 6
		pack $kkk.1 $kkk.e $kkk.1a $kkk.2 $kkk.e2 $kkk.3 $kkk.e3 -side left -padx 2 
		label $j.m -text "\n\n"
		label $j.m2 -text "MIXFILE CONTENTS"
		label $j.m3 -text "SOUNDS TO ADD"
		radiobutton $q.r -variable dumx -text "At end of mix" -value 0 -command {}
		pack $q.r -side left
		Scrolled_Listbox $j.ll2 -width 48 -height 10 -selectmode single
		Scrolled_Listbox $j.ll3 -width 48 -height 10 -selectmode single
		pack $j.m $j.m2 $j.ll2 $j.m3 $j.ll3 -side top -fill both
		pack $b -side top -fill x -expand true
		pack $k -side top -padx 2 -pady 4
		pack $k0 -side top -padx 2
		pack $kk $kkk -side top -padx 2 -pady 4
		pack $q -side top -fill x -expand true
		pack $j -side top -fill x -expand true

		bind $f.k.e <Down> "AdvanceNameIndex 0 sndtomixname 0"
		bind $f.j.ll2.list <Down> "AdvanceNameIndex 0 sndtomixname 0"
		bind $f.j.ll3.list <Down> "AdvanceNameIndex 0 sndtomixname 0"
		bind $f.kkk.e3 <Down> "AdvanceNameIndex 0 sndtomixname 0"
		bind $f.kkk.e2 <Down> "AdvanceNameIndex 0 sndtomixname 0"
		bind $f.kkk.e <Down> "AdvanceNameIndex 0 sndtomixname 0"
		bind $f.b.e <Down> "AdvanceNameIndex 0 sndtomixname 0"

		bind $f.k.e <Up> "AdvanceNameIndex 1 sndtomixname 0"
		bind $f.j.ll2.list <Up> "AdvanceNameIndex 1 sndtomixname 0"
		bind $f.j.ll3.list <Up> "AdvanceNameIndex 1 sndtomixname 0"
		bind $f.kkk.e3 <Up> "AdvanceNameIndex 1 sndtomixname 0"
		bind $f.kkk.e2 <Up> "AdvanceNameIndex 1 sndtomixname 0"
		bind $f.kkk.e <Up> "AdvanceNameIndex 1 sndtomixname 0"
		bind $f.b.e <Up> "AdvanceNameIndex 1 sndtomixname 0"

		bind $f.k.e <Control-Down> "AdvanceNameIndex 0 sndtomixname 1"
		bind $f.j.ll2.list <Control-Down> "AdvanceNameIndex 0 sndtomixname 1"
		bind $f.j.ll3.list <Control-Down> "AdvanceNameIndex 0 sndtomixname 1"
		bind $f.kkk.e3 <Control-Down> "AdvanceNameIndex 0 sndtomixname 1"
		bind $f.kkk.e2 <Control-Down> "AdvanceNameIndex 0 sndtomixname 1"
		bind $f.kkk.e <Control-Down> "AdvanceNameIndex 0 sndtomixname 1"
		bind $f.b.e <Control-Down> "AdvanceNameIndex 0 sndtomixname 1"

		bind $f.k.e <Control-Up> "AdvanceNameIndex 1 sndtomixname 1"
		bind $f.j.ll2.list <Control-Up> "AdvanceNameIndex 1 sndtomixname 1"
		bind $f.j.ll3.list <Control-Up> "AdvanceNameIndex 1 sndtomixname 1"
		bind $f.kkk.e3 <Control-Up> "AdvanceNameIndex 1 sndtomixname 1"
		bind $f.kkk.e2 <Control-Up> "AdvanceNameIndex 1 sndtomixname 1"
		bind $f.kkk.e <Control-Up> "AdvanceNameIndex 1 sndtomixname 1"
		bind $f.b.e <Control-Up> "AdvanceNameIndex 1 sndtomixname 1"

		bind $f <Escape> {set pr_sndtomix 0}
	}
	$f.j.m config -text "\nMIXFILE SELECTED\n$sndtomix_mix"
	set sndtomix_over 0
	set sndtomix_after 0
	set sndtomix_t ""
	set sndtomixname [file tail $sndtomix_mix]
	$f.k.e xview moveto 1.0
	$f.b.v config -text "" -state disabled -bd 0 -bg [option get . background {}]
	if {($typ == 0) || ($typ == 6) || ($typ == 7) || ($typ == 4) || ($typ == 5)  || ($typ == 8) || ($typ == 10)} {
		set sndtomix_ov ""
		$f.b.ov config -text ""
		$f.b.e config -bd 0 -state disabled
		$f.b.ms config -text ""
	} else {
		$f.b.ov config -text "Overlay Existing Mix by"
		$f.b.e config -bd 2 -state normal
		$f.b.ms config -text "secs"
		set sndtomix_ov ""
	}
	$f.q.r config -state disabled -text ""
	switch -- $typ {
		0 {
			wm title $f "Insert Sounds at Start of Mix"
			$f.j.m3 config -text "SOUNDS TO ADD"
			$f.b.kp config -text "Add Snds"
			$f.kkk.1 config -text ""
			$f.kkk.e config -bd 0 -state disabled
			$f.kkk.1a config -text "\n" -state disabled
			$f.kkk.2 config -text ""
			$f.kkk.e2 config -bd 0 -state disabled
			$f.kkk.3 config -text ""
			$f.kkk.e3 config -bd 0 -state disabled
			set sndtomix_t ""
			set sndtomix_b ""
			set sndtomix_m ""
		}
		7 -
		6 {
			wm title $f "Insert Sounds at Specified Time in Mix"
			$f.j.m3 config -text "SOUNDS TO ADD"
			$f.b.kp config -text "Add Snds"
			$f.kkk.1 config -text "Insert At Time"
			$f.kkk.e config -bd 2 -state normal
			$f.kkk.1a config -text "After\nLast Entry" -state normal -command {}
			$f.kkk.2 config -text "...or At Beat"
			$f.kkk.e2 config -bd 2 -state normal
			$f.kkk.3 config -text "Tempo (MM)"
			$f.kkk.e3 config -bd 2 -state normal
			$f.q.r config -state normal -text "At end of mix" -command "set sndtomix_t $pa($sndtomix_mix,$evv(DUR))"
		}
		1 {
			wm title $f "Overlay Sounds at Mix zero"
			$f.j.m3 config -text "SOUNDS TO ADD"
			$f.b.kp config -text "Add Snds"
			$f.kkk.1 config -text ""
			$f.kkk.e config -bd 0 -state disabled
			$f.kkk.1a config -text "\n" -state disabled
			$f.kkk.2 config -text ""
			$f.kkk.e2 config -bd 0 -state disabled
			$f.kkk.3 config -text ""
			$f.kkk.e3 config -bd 0 -state disabled
			set sndtomix_t ""
			set sndtomix_b ""
			set sndtomix_m ""
		}
		2 {
			wm title $f "Add Sound (sequence) to Mix end"
			$f.j.m3 config -text "SOUNDS TO ADD"
			$f.b.kp config -text "Add Snds"
			$f.kkk.1 config -text ""
			$f.kkk.e config -bd 0 -state disabled
			$f.kkk.1a config -text "\n" -state disabled
			$f.kkk.2 config -text ""
			$f.kkk.e2 config -bd 0 -state disabled
			$f.kkk.3 config -text ""
			$f.kkk.e3 config -bd 0 -state disabled
			set sndtomix_t ""
			set sndtomix_b ""
			set sndtomix_m ""
		}
		3 {
			wm title $f "Add (overlaid) Sounds to Mix end"
			$f.j.m3 config -text "SOUNDS TO ADD"
			$f.b.kp config -text "Add Snds"
			$f.kkk.1 config -text ""
			$f.kkk.e config -bd 0 -state disabled
			$f.kkk.1a config -text "\n" -state disabled
			$f.kkk.2 config -text ""
			$f.kkk.e2 config -bd 0 -state disabled
			$f.kkk.3 config -text ""
			$f.kkk.e3 config -bd 0 -state disabled
			set sndtomix_t ""
			set sndtomix_b ""
			set sndtomix_m ""
		}
		4 {
			wm title $f "Replace Sounds in Mix"
			$f.j.m3 config -text "SOUNDS TO SWAP"
			$f.b.kp config -text "Replace Snds"
			$f.kkk.1 config -text ""
			$f.kkk.e config -bd 0 -state disabled
			$f.kkk.1a config -text "\n" -state disabled
			$f.kkk.2 config -text ""
			$f.kkk.e2 config -bd 0 -state disabled
			$f.kkk.3 config -text ""
			$f.kkk.e3 config -bd 0 -state disabled
			set sndtomix_t ""
			set sndtomix_b ""
			set sndtomix_m ""
		}
		5 {
			wm title $f "Replace Sounds in Mix"
			$f.j.m3 config -text "SOUNDS TO SWAP"
			$f.b.kp config -text "Replace Snds"
			$f.kkk.1 config -text ""
			$f.kkk.e config -bd 0 -state disabled
			$f.kkk.1a config -text "All\n" -state normal -command SwapOccurence
			$f.kkk.2 config -text ""
			$f.kkk.e2 config -bd 0 -state disabled
			$f.kkk.3 config -text ""
			$f.kkk.e3 config -bd 0 -state disabled
			set sndtomix_t ""
			set sndtomix_b ""
			set sndtomix_m ""
			set sndtomix_after 1
		}
		8 -
		10 {
			wm title $f "Replace All Sounds in Mix"
			$f.j.m3 config -text "SOUNDS TO SUBSTITUTE"
			$f.b.kp config -text "Replace Snds"
			$f.kkk.1 config -text ""
			$f.kkk.e config -bd 0 -state disabled
			$f.kkk.1a config -text "\n" -state disabled
			$f.kkk.2 config -text ""
			$f.kkk.e2 config -bd 0 -state disabled
			$f.kkk.3 config -text ""
			$f.kkk.e3 config -bd 0 -state disabled
			set sndtomix_t ""
			set sndtomix_b ""
			set sndtomix_m ""
			set sndtomix_after 1
		}
	}
	set gotchancnt 0
	switch -- $typ {
		6 -
		7 {
			bind $f.j.ll2.list <ButtonRelease-1> {GetSndToMixTime}
		}
		default {
			bind $f.j.ll2.list <ButtonRelease-1> {}
		}
	}
	.sndtomix.k.ch config -text ""
	$f.b.kp config -state normal
	set sndtomix_exists 0
	$f.j.ll2.list delete 0 end
	$f.j.ll3.list delete 0 end
	if {[catch {open $sndtomix_mix "r"} zit]} {
		Inf "Cannot Read Data In Input Mixfile"
		Dlg_Dismiss $f
		return
	}
	if {$typ == 8} {
		set fnamlen [llength $fnams]
		set fnamcnt 0
		while {[gets $zit line] >= 0} {
			$f.j.ll2.list insert end $line
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			if {$multichan && !$gotchancnt} {
				set gotchancnt $line
				continue
			}
			if {[string match [string index $line 0] ";"]} {
				lappend outlines $line
			} else {
				catch {unset nuline}
				set cnt 0
				set line [split $line]
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] > 0} {
						if {$cnt == 0} {
							if {$fnamcnt >= $fnamlen} {
								Inf "Number Of Files Used In Mixfile Is Greater Than Number Of Files To Insert ([expr $fnamlen/2])"
								Dlg_Dismiss $f
								return
							}
							lappend nuline [lindex $fnams $fnamcnt]
							incr fnamcnt
							set nuchans [lindex $fnams $fnamcnt]
							incr fnamcnt
						} else {
							if {($cnt == 2) && ![string match $item $nuchans]} {
								Inf "[lindex $nuline 0] Does Not Have Same No Of Chans ($nuchans) As [lindex $line 0] ($item)"
								Dlg_Dismiss $f
								return
							}
							lappend nuline $item
						}
						incr cnt
					}
				}
				lappend outlines $nuline
			}
		}
		close $zit
		if {$fnamcnt != $fnamlen} {
			Inf "Number Of Files To Insert ([expr $fnamcnt/2]) Does Not Tally With Number Of Files In Original Mix ([expr $fnamlen/2])"
			Dlg_Dismiss $f
			return
		}

	} elseif {$typ == 10} {
		set fnamlen [llength $fnams]
		set fnamcnt 0
		while {[gets $zit line] >= 0} {
			$f.j.ll2.list insert end $line
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			if {[string match [string index $line 0] ";"]} {
				lappend outlines $line
			} else {
				if {$multichan && !$gotchancnt} {
					set gotchancnt $line
					continue
				}
				catch {unset nuline}
				set cnt 0
				set line [split $line]
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] > 0} {
						if {$cnt == 0} {
							lappend mixfnams $item
							lappend nuline $item
						} else {
							if {$cnt == 2} {
								lappend mixchans $item
							}
							lappend nuline $item
						}
						incr cnt
					}
				}
				lappend outlines $nuline
			}
		}
		close $zit
		set inmixfnams [GetIndependentItems $mixfnams]
		set fnamcnt [llength $inmixfnams]					
		if {[expr $fnamcnt * 2] != $fnamlen} {
			Inf "Number Of Files To Substitute ($fnamcnt) Does Not Tally With Number Of Files Used In Original Mix ([expr $fnamlen/2])"
			Dlg_Dismiss $f
			return
		}
		foreach mfnam $inmixfnams {ifnam ichans} $fnams {
			set k [lsearch $mixfnams $mfnam]
			set inmixchans [lindex $mixchans $k]
			if {$ichans != $inmixchans} {
				Inf "'$mfnam' Does Not Have Same No Of Chans ($ichans) As '$ifnam'"
				Dlg_Dismiss $f
				return
			}
		}
		set inlines $outlines
		unset outlines
		set gotchancnt 0
		foreach line $inlines {
			if {[string match [string index $line 0] ";"]} {
				lappend outlines $line
				continue
			}
			set ffnam [lindex $line 0]
			set k [lsearch $inmixfnams $ffnam]
			set ffnam [lindex $fnams [expr $k * 2]]
			set line [lreplace $line 0 0 $ffnam]
			lappend outlines $line
		}
	} else {
		while {[gets $zit line] >= 0} {
			if {$multichan && !$gotchancnt} {
				set gotchancnt $line
			} else {
				$f.j.ll2.list insert end $line
			}
		}
		close $zit
	}
	set n 0
	set len [llength $fnams]
	while {$n < $len} {
		$f.j.ll3.list insert end [lindex $fnams $n]
		incr n 2
	}
	set pr_sndtomix 0
	set finished 0
	raise $f
	My_Grab 0 $f pr_sndtomix $f.k.e
	while {!$finished} {
		tkwait variable pr_sndtomix
		if {$pr_sndtomix} {
			set ext [file extension $sndtomixname]
			set testnam [file rootname $sndtomixname]
			if {![ValidCDPRootname $testnam]} {
				continue
			}
			if {$multichan} {
				set this_ext [GetTextfileExtension mmx]
			} else {
				set this_ext [GetTextfileExtension mix]
			}
			append testnam $this_ext
			set snd_to_mix_name $testnam
			if {[file exists $snd_to_mix_name]} {
				set sndtomix_exists 1
				.sndtomix.k.ch config -text "exists"
			} else {
				set sndtomix_exists 0
				.sndtomix.k.ch config -text "new file"
			}
			set sndtomix_dur $pa($sndtomix_mix,$evv(DUR))
			if {($typ == 1) || ($typ == 2) || ($typ == 3)} {
				if {[string length $sndtomix_ov] <= 0} {
					set overlay 0
				} elseif {![IsNumeric $sndtomix_ov] || ($sndtomix_ov < 0)} {
					Inf "Invalid Overlay Value"
					continue
				} else {
					set overlay $sndtomix_ov
				}
				switch -- $typ {
					1 {
						set dur_in 0
						foreach {ffnam chans} $fnams {
							set dur_in [expr $dur_in + $pa($ffnam,$evv(DUR))]
						}
						if {$sndtomix_ov > $dur_in} {
							Inf "Invalid Overlay Value ($sndtomix_ov): Longer Than Total Duration Of Input Files"
							continue
						}
					}
					2 -
					3 {
						if {$sndtomix_ov > $sndtomix_dur} {
							Inf "Invalid Overlay Value ($sndtomix_ov): Longer Than Mixfile"
							continue
						}
					}
				}
			} elseif {($typ == 6) || ($typ == 7)} {
				if {![IsNumeric $sndtomix_t] || ($sndtomix_t < 0.0)} {
					if {![IsNumeric $sndtomix_b] || ($sndtomix_b < 0.0)} {
						Inf "Invalid Time Or Beat At Which To Insert Sound Into Mix"
						continue
					} elseif {![IsNumeric $sndtomix_m] || ($sndtomix_m < 0.0)} {
						Inf "Invalid Tempo (Metronome Mark Value)"
						continue
					} else {
						set sndtomix_t [DecPlaces [expr (60.0/double($sndtomix_m)) * ($sndtomix_b - 1.0)] 4]
					}
				} elseif {[IsNumeric $sndtomix_b] && ($sndtomix_b > 0.0) \
					&& [IsNumeric $sndtomix_m] && ($sndtomix_m > 0.0)} {
					set ztime [DecPlaces [expr (60.0/double($sndtomix_m)) * ($sndtomix_b - 1.0)] 4]
					if {![Flteq $ztime $sndtomix_t]} {
						Inf "Ambiguous: Beat Value Or Time Value ??"
						continue
					}
				}
			}
			catch {unset msg}
			if {$sndtomix_exists} {
				if {[string match $sndtomix_mix $snd_to_mix_name]} {
					if {!$sndtomix_over} {
						set msg "Overwrite Original File '$sndtomix_mix' ??"
					}
				} else {
					set sndtomix_over 0
					set msg "File '$snd_to_mix_name' Exists: Overwrite It ??"
				}
				if {[info exists msg]} {
					set choice [tk_messageBox -type yesno -message $msg -parent [lindex $wstk end] -icon question]
					if {$choice == "no"} {
						continue
					}
				}
			}
			catch {unset origlist}
			foreach line [$f.j.ll2.list get 0 end] {
				lappend origlist $line
			}
			if {($typ != 8) && ($typ != 10)} {
				catch {unset outlines}
			}
			switch -- $typ {
				0 -
				1 {
					set offset 0.0
					if {$multichan} {
						foreach {fnam chans} $fnams {
							set line $fnam
							append line "  $offset  $chans"
							set zz 1
							while {$zz <= $chans} {
								set route [ChanToRoute $zz]
								append line  "  $route  1"
								incr zz
							}
							if {$typ == 1} {
								set offset [expr $offset + $pa($fnam,$evv(DUR))]
							}
							lappend outlines $line
						}
					} else {
						foreach {fnam chans} $fnams {
							switch -- $chans {
								1 {
									set line $fnam
									append line "  $offset  1  1.0  C"
								}
								2 {
									set line $fnam
									append line "  $offset  2  1.0  L  1.0  R"
								}
							}
							if {$typ == 1} {
								set offset [expr $offset + $pa($fnam,$evv(DUR))]
							}
							lappend outlines $line
						}
					}
					if {$typ == 1} {
						set offset [expr $offset - $overlay]
					}
					foreach line [$f.j.ll2.list get 0 end] {
						set line [string trim $line]
						if {([llength $line] <=0) || [string match ";*" $line]} {
							lappend outlines $line
							continue
						}
						set line [split $line]
						set cnt 0
						catch {unset nuline}
						foreach item $line {
							set item [string trim $item]
							if {[string length $item] > 0} {
								switch -- $cnt {
									1 {
										set item [expr $item + $offset]
									}
								}												
								lappend nuline $item
								incr cnt
							}
						}
						if {[info exists nuline]} {
							set nuline [join $nuline]
							lappend outlines $nuline
						}
					}
				}
				7 -
				6 {
					set end 0
					foreach line [$f.j.ll2.list get 0 end] {
						if {$sndtomix_after} {
							set end [GetFarthest $end $line]
						}
						lappend outlines $line
					}
					if {$multichan} {
						foreach {fnam chans} $fnams {
							set line $fnam
							append line "  [expr $sndtomix_t + $end]  $chans"
							set zz 1
							while {$zz <= $chans} {
								set route [ChanToRoute $zz]
								append line  "  $route  1"
								incr zz
							}
							lappend outlines $line
						}
					} else {
						foreach {fnam chans} $fnams {
							switch -- $chans {
								1 {
									set line $fnam
									append line "  [expr $sndtomix_t + $end]  1  1.0  C"
								}
								2 {
									set line $fnam
									append line "  [expr $sndtomix_t + $end]  2  1.0  L  1.0  R"
								}
							}
							lappend outlines $line
						}
					}
				}
				2 -
				3 {
					foreach line [$f.j.ll2.list get 0 end] {
						lappend outlines $line
					}
					set offset $sndtomix_dur
					set offset [expr $offset - $overlay]
					if {$multichan} {
						foreach {fnam chans} $fnams {
							set line $fnam
							append line "  $offset  $chans"
							set zz 1
							while {$zz <= $chans} {
								set route [ChanToRoute $zz]
								append line "  $route  1"
								incr zz
							}
							if {$typ == 2} {
								set offset [expr $offset + $pa($fnam,$evv(DUR))]
							}
							lappend outlines $line
						}
					} else {
						foreach {fnam chans} $fnams {
							switch -- $chans {
								1 {
									set line $fnam
									append line "  $offset  1  1.0  C"
								}
								2 {
									set line $fnam
									append line "  $offset  2  1.0  L  1.0  R"
								}
							}
							if {$typ == 2} {
								set offset [expr $offset + $pa($fnam,$evv(DUR))]
							}
							lappend outlines $line
						}
					}
				}
				4 -
				5 {
					set replacing1 0
					set replacing2 0
					set occurence 0
					set ocnt 0
					set done_replace 0
					if {$typ == 5} {
						if {!$sndtomix_after} {
							if {![regexp {^[0-9]+$} $sndtomix_t]} {
								Inf "Invalid Occurence Number"
								continue
							}
							set occurence $sndtomix_t
						}
					}	
					if {$multichan} {
						foreach line [$f.j.ll2.list get 0 end] {
							set origline $line
							catch {unset nuline}
							set doing_replace 0
							set line [string trim $line]
							set line [split $line]
							set ccnt 0
							set OK 1
							foreach item $line {
								if {[string length $item] <= 0} {
									continue
								}
								if {$ccnt == 0} {
									set item [string trim $item]
									if {[string match ";*" $item]} {	;#	Skip Comments
										set nuline $origline
										set OK 0
										break
									}
									if {[string match $item [lindex $fnams 0]]} {
										if {$replacing2} {
											Inf "Both Files Are Already Used In The Mixfile"
											set OK -1
											break
										}
										set skip 0
										if {$occurence > 0} {
											incr ocnt
											if {$ocnt != $occurence} {
												set skip 1
											}
										}
										if {$skip} {
											lappend nuline $item
										} else {
											if {!$replacing1} {
												set repfile [lindex $fnams 2]
												set replacing1 1
											}
											lappend nuline $repfile
											set done_replace 1
											set doing_replace 1
										}
									} elseif {[string match $item [lindex $fnams 2]]} {
										if {$replacing1} {
											Inf "Both Files Are Already Used In The Mixfile"
											set OK -1
											break
										}
										set skip 0
										if {$occurence > 0} {
											incr ocnt
											if {$ocnt != $occurence} {
												set skip 1
											}
										}
										if {$skip} {
											lappend nuline $item
										} else {
											if {!$replacing2} {
												set repfile [lindex $fnams 0]
												set replacing2 1
											}
											lappend nuline $repfile
											set done_replace 1
											set doing_replace 1
										}
									} else {
										lappend nuline $item
										set doing_replace 0
									}
								} else {
									lappend nuline $item
								}
								incr ccnt
							}	
							if {$OK < 0} {
								break
							}
							if {[info exists nuline]} {
								lappend outlines $nuline
							}
							if {$OK == 0} {
								continue
							}
						}
					} else {
						foreach line [$f.j.ll2.list get 0 end] {
							set origline $line
							catch {unset nuline}
							set skiptail 0
							set addtail 0
							set doing_replace 0
							set line [string trim $line]
							set line [split $line]
							set ccnt 0
							set OK 1
							foreach item $line {
								if {[string length $item] <= 0} {
									continue
								}
								switch -- $ccnt {
									0 {
										set item [string trim $item]
										if {[string match ";*" $item]} {	;#	Skip Comments
											set nuline $origline
											set OK 0
											break
										}
										if {[string match $item [lindex $fnams 0]]} {
											if {$replacing2} {
												Inf "Both Files Are Already Used In The Mixfile"
												set OK -1
												break
											}
											set skip 0
											if {$occurence > 0} {
												incr ocnt
												if {$ocnt != $occurence} {
													set skip 1
												}
											}
											if {$skip} {
												lappend nuline $item
											} else {
												if {!$replacing1} {
													set repfile [lindex $fnams 2]
													set repchan [lindex $fnams 3] 
													set replacing1 1
												}
												lappend nuline $repfile
												set done_replace 1
												set doing_replace 1
											}
										} elseif {[string match $item [lindex $fnams 2]]} {
											if {$replacing1} {
												Inf "Both Files Are Already Used In The Mixfile"
												set OK -1
												break
											}
											set skip 0
											if {$occurence > 0} {
												incr ocnt
												if {$ocnt != $occurence} {
													set skip 1
												}
											}
											if {$skip} {
												lappend nuline $item
											} else {
												if {!$replacing2} {
													set repfile [lindex $fnams 0]
													set repchan [lindex $fnams 1] 
													set replacing2 1
												}
												lappend nuline $repfile
												set done_replace 1
												set doing_replace 1
											}
										} else {
											lappend nuline $item
											set doing_replace 0
										}
									}
									1 {
										lappend nuline $item
									}
									2 {
										if {$doing_replace} {
											if {$repchan != $item} {
												set item $repchan
												if {$repchan == 2} {
													set skiptail 1
												} else {
													set addtail 1
												}
											}
										}
										lappend nuline $item
									}
									3 {
										lappend nuline $item
										if {$skiptail} {
											break
										}
										if {$addtail} {
											lappend nuline "C"
											break
										}
									}
									4 -
									5 -
									6 {
										lappend nuline $item
									}
								}
								incr ccnt
							}	
							if {$OK < 0} {
								break
							}
							if {[info exists nuline]} {
								lappend outlines $nuline
							}
							if {$OK == 0} {
								continue
							}
						}
					}
					if {$OK < 0} {
						break
					}
				}
			}
			if {![info exists outlines]} {
				Inf "No Changes Made"
				continue
			}
			if {($typ == 4) || ($typ == 5)} {
				if {!$done_replace} {
					Inf "No Changes Made: Occurence $occurence Not Found"
					continue
				}
				$f.j.ll3.list delete 0 end
				foreach line $outlines {
					$f.j.ll3.list insert end $line
				}
			} else {
				$f.j.ll2.list delete 0 end
				foreach line $outlines {
					$f.j.ll2.list insert end $line
				}
				if {$typ > 1} {
					$f.j.ll2.list yview moveto 1.0
				}
			}
			$f.b.v config -text "Verify" -state normal -bd 2 -bg $evv(EMPH)
			$f.b.kp config -state disabled
			tkwait variable pr_sndtomix
			if {$pr_sndtomix != 2} {
				if {($typ == 4) || ($typ == 5)} {
					break
				}
				$f.j.ll2.list delete 0 end
				foreach fnam $origlist {
					$f.j.ll2.list insert end $fnam
				}
				$f.b.v config -text "" -state disabled -bd 0 -bg [option get . background {}]
				$f.b.kp config -state normal
				continue
			}
			if {$sndtomix_exists} {
				set exxt [GetTextfileExtension mix]
				set tempfnam $evv(DFLT_OUTNAME)
				append tempfnam 0 $exxt
				if [catch {open $tempfnam "w"} zit] {
					Inf "Cannot Open Temporary File '$tempfnam' To Write New Mix Data"
					continue
				}
			} else {
				if [catch {open $snd_to_mix_name "w"} zit] {
					Inf "Cannot Open File '$snd_to_mix_name' To Write New Mix Data"
					continue
				}
			}
			if {$gotchancnt > 0} {
				puts $zit $gotchancnt
			}
			foreach line $outlines {
				puts $zit $line
			}
			close $zit
			if {$sndtomix_exists} {
				if [catch {file rename -force $tempfnam $snd_to_mix_name} zit] {
					Inf "Cannot Rename Temporary File '$tempfnam' To '$snd_to_mix_name'\nDo This Now, Outside The Soundloom, To Preserve Your Data"
				}
			}
			if {$sndtomix_exists && ([LstIndx $snd_to_mix_name $wl] >=0)} {
				if {[DoParse $snd_to_mix_name 0 0 0] > 0} {
					if {[MixMUpdate $snd_to_mix_name 0]} {
						set save_mixmanage 1				;#	UPDATES MIXMANAGER, IF cdparse SUCCEEDS
					}
				}
			} else {
				FileToWkspace $snd_to_mix_name 0 0 0 0 1
				if {[UpdatedIfAMix $snd_to_mix_name 0]} {	;#	UPDATES MIXMANAGER, EVEN IF FileToWkspace FAILS
					set save_mixmanage 1
				}
			}
			if {($typ == 5) || ($typ == 6)} {
				DoChoiceBak
				set chlist $snd_to_mix_name
				set chcnt 1
				$ch delete 0 end
				$ch insert end $snd_to_mix_name
			}
			break
		} else {
			break
		}
	}
	if {![DoDurParse $snd_to_mix_name]} {
		Inf "Unable to reset file duration"
	}
	if {$save_mixmanage} {
		MixMStore
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc IsValidSyntaxBrkfile {t pcnt gcnt} {
	global actvlo actvhi
	set badrange 0
	set lasttime -1
	set words {}
	set vals [$t get 1.0 end]
	set lines "[split $vals \n]"

	foreach line $lines {
		set vals "[split $line]"				;#	split line into single-space separated items
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		set thesewords {}
		foreach item $vals {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend thesewords $item
			}
		}
		set wordcnt [llength $thesewords]
		if {$wordcnt <= 0} {
			continue
		}
		if {$wordcnt != 2 } {
			Inf "Incorrect Count Of Entries (Should Be 2) On One Or More Lines"
			return -1
		}
		set words [concat $words $thesewords]
	}
	foreach {time val} $words {
		if {![IsNumeric $time]} {
			Inf "Non-Numeric Time Value Found"
			return -1
		}
		if {$time < 0.0} {
			Inf "Subzero Time Found"
			return -1
		}
		if {$time <= $lasttime} {
			Inf "Times Out Of Sequence"
			return -1
		}
		set lasttime $time
		if {![IsNumeric $val]} {
			Inf "Non-Numeric Value Found"
			return -1
		}		
		if {$gcnt >= 0} {
			if {($val < $actvlo($pcnt)) || ($val > $actvhi($pcnt))} {
				set badrange 1
			}
		}
	}
	if {$badrange} {
		Inf "Values Out Of Range, For Range Set On Parameters Page ($actvlo($pcnt) to  $actvhi($pcnt))"
		return 0
	}
	return 1
}

#----- Design brkpoint files for spatialisation

proc SpaceDesign {} {
	global spacdes_got CDPspac spac_error spacdes_clear pa evv
	global pr_spacedesign sd sd_list wstk p_pg new_cmdline_testing
	global wl rememd blist_change files_deleted sd_infnam chlist shortwindows

	if {![info exists chlist] || [llength $chlist] < 1} {
		Inf "No Soundfile on Chosen List"
		return
	}
	set sd_infnam [lindex $chlist 0]
	if {$pa($sd_infnam,$evv(FTYP)) != $evv(SNDFILE)} {
		Inf "$sd_infnam is not a Soundfile"
		return
	}
	set f .spacedesign
	if [Dlg_Create $f "Space Design" "set pr_spacedesign 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		frame $f.0a -bg [option get . foreground {}] -height 1
		frame $f.1
		frame $f.1a -bg [option get . foreground {}] -height 1
		frame $f.11
		frame $f.11a -bg [option get . foreground {}] -height 1
		frame $f.2
		frame $f.2a -bg [option get . foreground {}] -height 1
		frame $f.3
		frame $f.4
		frame $f.5
		frame $f.55
		frame $f.5a -bg [option get . foreground {}] -height 1
		frame $f.6
		frame $f.7
		button $f.0.run -text Run -command "set pr_spacedesign 1" -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $f.0.help -text Help -command "SpaceDesignHelp" -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.0.quit -text Close -command "set pr_spacedesign 0" -highlightbackground [option get . background {}]
		pack $f.0.run -side left -padx 2
		pack $f.0.help -side left -padx 2
		pack $f.0.quit -side right -padx 2
		button $f.1.play -text "Play Outfile" -command "PlayRotate" -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.1.save -text "Save Parameter Set" -command "SaveSD" -highlightbackground [option get . background {}]
		label $f.1.lab -text "Data Filename"
		entry $f.1.fnam -textvariable sd(save) -width 16
		button $f.1.load -text "Load Parameter Set" -command "LoadSD" -highlightbackground [option get . background {}]
		label $f.1.dummy -text "                   "
		pack $f.1.play -side left -padx 2
		pack $f.1.dummy $f.1.load $f.1.lab $f.1.fnam $f.1.lab $f.1.save -side right -padx 2

		frame $f.11.1
		button $f.11.1.find -text "Find Textfile" -command SDFind -highlightbackground [option get . background {}]
		button $f.11.1.creat -text "Create Textfile" -command "Dlg_MakeTextfile 0 0" -highlightbackground [option get . background {}]
		button $f.11.1.tabed -text "Table Editor" -command "set p_pg 0; TableEditor"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
		pack $f.11.1.find $f.11.1.creat $f.11.1.tabed -side left -padx 12
		pack $f.11.1 -side top
		label $f.2.modes -text "MODES :"
		radiobutton $f.2.stom -variable sd(mode) -text "Stereo into Mono" -value stom -command "SetUpSDVars 1"
		radiobutton $f.2.mtos -variable sd(mode) -text "Mono into Stereo" -value mtos -command "SetUpSDVars 2"
		radiobutton $f.2.rota -variable sd(mode) -text "Rotation" -value rotate -command "SetUpSDVars 3"
		radiobutton $f.2.clear -variable spacdes_clear -text "Clear All Vals" -value 1 -command "ClearSDVars"
		pack $f.2.modes $f.2.stom $f.2.mtos $f.2.rota -side left -padx 2
		pack $f.2.clear -side right -padx 2
		label $f.3.params -text PARAMS: 
		label $f.3.lab1 -text "start time"
		entry $f.3.stime -textvariable sd(starttime) -width 6 -disabledbackground [option get . background {}]
		label $f.3.lab2 -text "end time"
		entry $f.3.etime -textvariable sd(endtime) -width 6 -disabledbackground [option get . background {}]
		label $f.3.lab3 -text "end position"
		entry $f.3.epos -textvariable sd(endpos) -width 6 -disabledbackground [option get . background {}]
		label $f.3.lab4 -text "prescale level"
		entry $f.3.pre  -textvariable sd(prescale) -width 6 -disabledbackground [option get . background {}]
		label $f.3.lab0   -text "end position"
		entry $f.3.far    -textvariable sd(farpos) -width 6 -disabledbackground [option get . background {}]
		label $f.3.lab00 -text "distance filter\ncutoff frq (if any)"
		entry $f.3.flt    -textvariable sd(filt) -width 6 -disabledbackground [option get . background {}]
		pack $f.3.params -side left
		pack $f.3.flt $f.3.lab00 $f.3.far $f.3.lab0 $f.3.pre $f.3.lab4 $f.3.epos $f.3.lab3 $f.3.etime $f.3.lab2 $f.3.stime \
		$f.3.lab1 -side right -padx 2
		button $f.4.lab1   -text "times\nat edges of space" -command CreateSpaceText -state normal -bd 2 -highlightbackground [option get . background {}]
		entry $f.4.edge   -textvariable sd(edge) -width 16 -disabledbackground [option get . background {}]
		label $f.4.lab2   -text "rotation width\n(0-1)"
		entry $f.4.width  -textvariable sd(width) -width 16 -disabledbackground [option get . background {}]
		label $f.4.lab3   -text "proportion of time\nat edge of space(>0 to <1)"
		entry $f.4.linger -textvariable sd(linger) -width 6 -disabledbackground [option get . background {}]
		pack $f.4.linger $f.4.lab3 $f.4.width $f.4.lab2 $f.4.edge $f.4.lab1 -side right -padx 2
		label $f.5.lab1  -text "ratio of front level\nto rear level"
		entry $f.5.deep  -textvariable sd(depth) -width 6 -disabledbackground [option get . background {}]
		label $f.5.lab2  -text "maxlevel leads\ncentre position by(0-1)"
		entry $f.5.lead  -textvariable sd(lead)  -width 6 -disabledbackground [option get . background {}]
		label $f.5.lab3  -text "overall attenuation\n(>0 to 10)"
		entry $f.5.atten -textvariable sd(atten) -width 6 -disabledbackground [option get . background {}]
		label $f.5.lab4  -text "clockwise"
		radiobutton $f.5.clock -variable sd(clock) -value 1
		label $f.5.lab5  -text "anticlock"
		radiobutton $f.5.anti -variable sd(clock) -value 0
		pack $f.5.anti $f.5.lab5 $f.5.clock $f.5.lab4 -side right
		pack $f.5.atten $f.5.lab3 $f.5.lead $f.5.lab2 $f.5.deep $f.5.lab1 -side right -padx 2 
		label $f.55.lab1a -text "ratio time at rear\nto time at front(1-20) (optional)"
		entry $f.55.warp  -textvariable sd(warp) -width 6 -disabledbackground [option get . background {}]
		pack $f.55.warp $f.55.lab1a -side right -padx 2
		label $f.6.lab -text "Spatialisation Textfiles Name"
		entry $f.6.fnam -textvariable sd(datafnam) -width 16 -disabledbackground [option get . background {}]
		label $f.6.lab2 -text "New Soundfile Name"
		entry $f.6.fnam2 -textvariable sd(sndfnam) -width 16 -disabledbackground [option get . background {}]
		pack $f.6.lab $f.6.fnam $f.6.lab2 $f.6.fnam2 -side left -padx 2
		if {[info exists shortwindows]} {
			set sd_list [Scrolled_Listbox $f.7.list -width 120 -height 16]
		} else {
			set sd_list [Scrolled_Listbox $f.7.list -width 120 -height 32]
		}
		pack $f.7.list -side top
		pack $f.0 $f.0a $f.1 $f.1a $f.11 $f.11a $f.2 $f.2a $f.3 -side top -fill x -expand true -pady 2
		pack $f.4 $f.5 $f.55 -side top -pady 2 -fill x -expand true
		pack $f.5a -side top -fill x -expand true
		pack $f.6 -side top -pady 2
		pack $f.7 -side top -fill x -expand true -pady 2
		set sd(clock) -1
		set sd(mode) 0
		set spacdes_clear 0
		set sd(prescale) ""
		wm resizable $f 1 1
		bind $f <Return> {set pr_spacedesign 1}
		bind $f <Escape> {set pr_spacedesign 0}
	}
	catch {unset sd(fnam2_full)}
	switch -- $sd(mode) {
		0		 {SetUpSDVars 0} 
		"stom"   {SetUpSDVars 1} 
		"mtos"   {SetUpSDVars 2} 
		"rotate" {SetUpSDVars 3} 
	}
	set finished 0
	set do_overwrite 0
	set pr_spacedesign 0
	raise $f
	update idletasks
	StandardPosition2 .spacedesign
	My_Grab 0 $f pr_spacedesign
	while {!$finished} {
		DeleteAllTemporaryFiles
		tkwait variable pr_spacedesign
		if {$pr_spacedesign} {
			$sd_list delete 0 end
			switch -- $sd(mode) {
				"stom" -
				"mtos" {
					if {$pa($sd_infnam,$evv(CHANS)) != 2} {
						Inf "$sd_infnam is not a Stereo soundfile"
						continue
					}
					set thisfnam1 [file rootname [file tail $sd_infnam]]
					append thisfnam1 "_c1$evv(SNDFILE_EXT)"
					set thisfnam2 [file rootname [file tail $sd_infnam]]
					append thisfnam2 "_c2$evv(SNDFILE_EXT)"
					if {[file exists $thisfnam1]} {
						Inf "File '$thisfnam1' already exists: cannot proceed"
						continue
					}
					if {[file exists $thisfnam2]} {
						Inf "File '$thisfnam2' already exists: cannot proceed"
						continue
					}
				}
				"rotate" {
					if {$pa($sd_infnam,$evv(CHANS)) != 1} {
						Inf "$sd_infnam is not a Mono soundfile"
						continue
					}
				}
			}
			switch -- $sd(mode) {
				"stom" -
				"mtos" -
				"rotate" {
					if {[string length $sd(sndfnam)] <= 0} {
						Inf "No out-soundfile name entered"
						continue
					}
					if {![ValidCDPRootname $sd(sndfnam)]} {
						continue
					}
					set sd(fnam2_full) $sd(sndfnam)$evv(SNDFILE_EXT)
					if {[string match $sd(fnam2_full) $sd_infnam]} {
						Inf "Input and output files are the same: Not permitted"
						continue
					}
					if [file exists $sd(fnam2_full)] {
						set msg "File '$sd(fnam2_full)' already exist.\n\nOVERWRITE IT ??"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							continue
						}
						if [DeleteFileFromSystem $sd(fnam2_full) 0 1] {
							set i [LstIndx $sd(fnam2_full) $wl]
							if {$i >= 0} {
								RemoveAllRefsToFile $sd(fnam2_full) $i
								$wl delete $i
								WkspCnt [$wl get $i] -1
								catch {unset rememd}
								DummyHistory $sd(fnam2_full) "DESTROYED"
							}
						} else {
							continue
						}
					}
					if {[string length $sd(datafnam)] <= 0} {
						Inf "No spatialisation textfile name entered"
						continue
					}
					if {![ValidCDPRootname $sd(datafnam)]} {
						continue
					}
					set zfnam1 $sd(datafnam)
					append zfnam1 "1.txt"
					set zfnam2 $sd(datafnam)
					append zfnam2 "2.txt"
					set zfnam3 $sd(datafnam)
					append zfnam3 "3.txt"
					set zfnams_exist 0
					set do_overwrite 0

					if {[IsNumeric $sd(filt)]} { 
						if {($sd(filt) < 100) || ($sd(filt) > 10000)} {
							Inf "Invalid filter frequency (range 100 to 10000)"
							continue
						}
					}
					if {[file exists $zfnam1] && [file exists $zfnam2]} {
						set msg "'$zfnam1' & '$zfnam2' already exist.\n\nUSE THE EXISTING FILES ??"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "yes"} {
							set zfnams_exist 1
						} else {
							set msg "OVERWRITE THEM ??"
							set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
							if {$choice == "no"} {
								continue
							} else {
								set do_overwrite 1
							}
						}
					} elseif {[file exists $zfnam1] || [file exists $zfnam2]} {
						set msg "Either one or both of files '$zfnam1' & '$zfnam2' already exist.\n\nOVERWRITE THEM ??"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							continue
						} else {
							set do_overwrite 1
						}
					}
					switch -- $sd(mode) {
						"stom" - 
						"mtos" {
							if {[string length $sd(prescale)] != 0} {
								if {![IsNumeric $sd(prescale)] || ($sd(prescale) < 0.00003) || ($sd(prescale) > 2.0)} {
									Inf "Invalid prescale value (range 0.00003 to 2)"
									continue
								}
							} else {
								set sd(prescale) 1.0
							}
						}
					}
					if {!$zfnams_exist} {
						if {![IsNumeric $sd(starttime)] || ($sd(starttime) < 0.0)} {
							Inf "Invalid start time"
							continue
						}
						if {![IsNumeric $sd(endtime)] || ($sd(endtime) <= $sd(starttime))} {
							Inf "Invalid end time"
							continue
						}
						if {![IsNumeric $sd(endpos)] || ($sd(endpos) < -1.0) || ($sd(endpos) > 1.0)} {
							switch -- $sd(mode) {
								"stom" {
									Inf "Invalid convergence end position (range -1 to 1)"
								}
								"mtos" {
									Inf "Invalid divergence start position (range -1 to 1)"
								}
								"rotate" {
									Inf "Invalid start position (range -1 to 1)"
								}
							}
							continue
						}
						switch -- $sd(mode) {
							"rotate" {
								if {![IsNumeric $sd(farpos)] || ($sd(farpos) < -1.0) || ($sd(farpos) > 1.0)} {
									Inf "Invalid end position (range -1 to 1)"
									continue
								}
								if {[IsNumeric $sd(filt)]} {
									if {($sd(filt) < 100) || ($sd(filt) > 10000)} {
										Inf "Invalid filter frequency (range 100 to 10000)"
										continue
									}
								} elseif {[string length $sd(filt)] > 0} {
									Inf "Invalid filter frequency value"
									continue
								}
								;#  CHECK EDGE TIMES FILE
								if {[string length $sd(edge)] <= 0} {
									Inf "No edge times filename entered"
									continue
								}
								if {[string length [file extension $sd(edge)]] <= 0} {
									append sd(edge) $evv(TEXT_EXT)
								}
								if {![file exists $sd(edge)]} {
									Inf "File $sd(edge) does not exist"
									continue
								}
								if {![info exists pa($sd(edge),$evv(FTYP))]} {
									Inf "File $sd(edge) is not on the workspace"
									continue
								}
								if {!($pa($sd(edge),$evv(FTYP)) & $evv(NUMLIST))} {
									Inf "File $sd(edge) is not a list of times stored on separate lines"
									continue
								}
								if {$pa($sd(edge),$evv(MINNUM)) < $sd(starttime)} {
									Inf "First time in File $sd(edge) is before start time $sd(starttime)"
									continue
								}
								if [catch {open $sd(edge) "r"} zit] {
									Inf "Cannot open file $sd(edge) to check values"
									continue
								}
								set OK 1
								set zz 0
								set lastval -1
								while {[gets $zit val] >= 0} {
									set val [string trim $val]
									if {[string length $val] <= 0} {
										continue
									}
									if {![IsNumeric $val]} {
										Inf "File $sd(edge) is not a list of times stored on separate lines"
										set OK 0
										break
									}
									if {$val <= $lastval} {															
										Inf "File $sd(edge) is not a list of increasing times"
										set OK 0
										break

									}
									set lastval $val
									incr zz
								}
								close $zit
								if {!$OK} {
									continue
								}
								if [IsNumeric $sd(width)] {
									if {($sd(width) < 0.0) || ($sd(width) > 1.0)} {
										Inf "Width out of range (0-1)"
										continue
									}
								} else {
									if {![file exists $sd(width)]} {
										Inf "Width file $sd(width) does not exist"
										continue
									}
									if {![info exists pa($sd(width),$evv(FTYP))]} {
										Inf "File $sd(width) is not on the workspace"
										continue
									}
									if {![IsABrkfile $pa($sd(width),$evv(FTYP))]} {
										Inf "File $sd(width) is not a normalised brkpkoint file"
										continue
									}
								}									
								if {![IsNumeric $sd(linger)] || ($sd(linger) <= 0.0) || ($sd(linger) >= 1.0)} {
									Inf "Invalid proportion of time at edge of space (range >0 to <1)"
									continue
								}
								if {![IsNumeric $sd(depth)] || ($sd(depth) < 1.0)} {
									Inf "Invalid ratio of front to rear level (range >= 1)"
									continue
								}
								if {![IsNumeric $sd(lead)] || ($sd(lead) < 0.0) || ($sd(lead) > 1.0)} {
									Inf "Invalid maxlevel lead over centre position  (range 0 - 1)"
									continue
								}
								if {![IsNumeric $sd(atten)] || ($sd(atten) <= 0.0) || ($sd(atten) > 10.0)} {
									Inf "Invalid overall attenuation (range >0 - 10)"
									continue
								}
								if {[string length $sd(warp)] > 0} {
									if {![IsNumeric $sd(warp)] || ($sd(warp) < 1.0) || ($sd(warp) > 20.0)} {
										Inf "Invalid front time to rear time ratio (range >1 - 20)"
										continue
									}
								}
							}
						}
					}
					if {$do_overwrite} {
						set crum 0
						if {[file exists $zfnam1]} {
							if [DeleteFileFromSystem $zfnam1 0 1] {
								set i [LstIndx $zfnam1 $wl]
								if {$i >= 0} {
									RemoveAllRefsToFile $zfnam1 $i
									DummyHistory $zfnam1 "DESTROYED"
								}
							} else {
								set crum 1
							}
						}
						if {[file exists $zfnam2]} {
							if [DeleteFileFromSystem $zfnam2 0 1] {
								set i [LstIndx $zfnam2 $wl]
								if {$i >= 0} {
									RemoveAllRefsToFile $zfnam2 $i
									DummyHistory $zfnam2 "DESTROYED"
								}
							} else {
								set crum 1
							}
						}
						if {$crum} {
							Inf "Cannot delete the existing files '$zfnam'"
							continue
						}
					}
					set spac_error 0
					if {!$zfnams_exist} {
						set spacdes_got 0
						set cmd [file join $evv(CDPROGRAM_DIR) spacedesign]
						switch -- $sd(mode) {
							"stom" -
							"mtos" {
								set cmd [list $cmd $sd(mode) $sd(datafnam) $sd(starttime) $sd(endtime) $sd(endpos)]
							}
							"rotate" {
								if {($sd(filt) > 0.0) && [file exists $zfnam3]} {
									if [DeleteFileFromSystem $zfnam3 0 1] {
										set i [LstIndx $zfnam3 $wl]
										if {$i >= 0} {
											RemoveAllRefsToFile $zfnam3 $i
											$wl delete $i
											WkspCnt [$wl get $i] -1
											catch {unset rememd}
											DummyHistory $zfnam3 "DESTROYED"
										}
									}	
								}
								set cmd [list $cmd $sd(mode) $sd(datafnam) $sd(starttime) $sd(endtime) $sd(endpos)]
								lappend cmd $sd(farpos) $sd(edge) $sd(width) $sd(clock) $sd(linger) $sd(depth) $sd(lead) $sd(atten)
								if {$sd(filt) > 0.0} {
									lappend cmd 1
								} else {
									lappend cmd 0
								}
								if {[string length $sd(warp)] == 0} {
									lappend cmd 1
								} else {
									lappend cmd $sd(warp)
								}
							}
						}
						if {$new_cmdline_testing} {
							Inf "$cmd"
						}
						if [catch {open "|$cmd"} CDPspac] {
							Inf "Cannot Run The Spacedesign Utility"
							catch {unset CDPspac}
							set finished 1
						} else {
							fileevent $CDPspac readable WriteSpaceDesignData
						}
						vwait spacdes_got
						catch {close $CDPspac}
						if {$spac_error} {
							continue
						}
						set thisfnam1 $sd(datafnam)
						append thisfnam1 "1.txt"
						set thisfnam2 $sd(datafnam)
						append thisfnam2 "2.txt"
						if {![file exists $thisfnam1]} {
							Inf "File '$thisfnam1' has not been created: cannot proceed"
							set finished 1
							break
						}
						if {![file exists $thisfnam2]} {
							Inf "File '$thisfnam2' has not been created: cannot proceed"
							catch {file delete $thisfnam1}
							set finished 1
							break
						}
						FileToWkspace $thisfnam1 0 0 0 1 1
						FileToWkspace $thisfnam2 0 0 0 1 1
						DummyHistory $thisfnam1 "CREATED"
						DummyHistory $thisfnam2 "CREATED"
						if {[string length $sd(filt)] > 0} {
							FileToWkspace $zfnam3 0 0 0 1 1
							DummyHistory $zfnam3 "CREATED"
							Inf "The files '$thisfnam1', '$thisfnam2' & '$zfnam3' are now on the Workspace"
						} else {
							Inf "The files '$thisfnam1' & '$thisfnam2' are now on the Workspace"
						}
					}
					Block "Doing the Space Design"
					switch -- $sd(mode) {
						"stom" -
						"mtos" {
							set cmd [file join $evv(CDPROGRAM_DIR) housekeep]
							set cmd [list $cmd chans 2 $sd_infnam]
							set spacdes_got 0
							if [catch {open "|$cmd"} CDPspac] {
								Inf "Cannot Split Channels Of Original Sound"
								catch {unset CDPspac}
								UnBlock
								continue
							} else {
								fileevent $CDPspac readable WriteSpaceDesignData2
							}
							vwait spacdes_got
							catch {close $CDPspac}
							if {$spac_error} {
								UnBlock
								continue
							}
							set thisfnam1 [file rootname [file tail $sd_infnam]]
							append thisfnam1 "_c1$evv(SNDFILE_EXT)"
							set thisfnam2 [file rootname [file tail $sd_infnam]]
							append thisfnam2 "_c2$evv(SNDFILE_EXT)"
							if {![file exists $thisfnam1]} {
								Inf "File '$thisfnam1' has not been created: cannot proceed"
								UnBlock
								continue
							}
							if {![file exists $thisfnam2]} {
								Inf "File '$thisfnam2' has not been created: cannot proceed"
								catch {file delete $thisfnam1}
								UnBlock
								continue
							}
							if [catch {file rename $thisfnam1 cdptest0$evv(SNDFILE_EXT)} zit] {
								Inf "File rename failed 1"
								UnBlock
								continue
							}
							if [catch {file rename $thisfnam2 cdptest1$evv(SNDFILE_EXT)} zit] {
								Inf "File rename failed 2"
								UnBlock
								continue
							}
							set cmd [file join $evv(CDPROGRAM_DIR) modify]
							set cmd [list $cmd space 1 cdptest0$evv(SNDFILE_EXT) cdptest2$evv(SNDFILE_EXT) $zfnam1]
							if {[IsNumeric $sd(prescale)] && ![Flteq $sd(prescale) 1.0]} {
								lappend cmd "-p$sd(prescale)"
							}
							set spacdes_got 0
							if [catch {open "|$cmd"} CDPspac] {
								Inf "Cannot Respatialise Channel 1"
								catch {unset CDPspac}
								UnBlock
								continue
							} else {
								fileevent $CDPspac readable WriteSpaceDesignData2
							}
							vwait spacdes_got
							catch {close $CDPspac}
							if {$spac_error} {
								UnBlock
								continue
							}
							if {![file exists cdptest2$evv(SNDFILE_EXT)]} {
								Inf "Spatialisation of channel one has failed: cannot proceed"
								UnBlock
								continue
							}
							set cmd [file join $evv(CDPROGRAM_DIR) modify]
							set cmd [list $cmd space 1 cdptest1$evv(SNDFILE_EXT) cdptest3$evv(SNDFILE_EXT) $zfnam2]
							if {[IsNumeric $sd(prescale)] && ![Flteq $sd(prescale) 1.0]} {
								lappend cmd "-p$sd(prescale)"
							}
							set spacdes_got 0
							if [catch {open "|$cmd"} CDPspac] {
								Inf "Cannot Respatialise Channel 2"
								catch {unset CDPspac}
								UnBlock
								continue
							} else {
								fileevent $CDPspac readable WriteSpaceDesignData2
							}
							vwait spacdes_got
							catch {close $CDPspac}
							if {$spac_error} {
								UnBlock
								continue
							}
							if {![file exists cdptest3$evv(SNDFILE_EXT)]} {
								Inf "Spatialisation of channel two has failed: cannot proceed"
								UnBlock
								continue
							}
							set cmd [file join $evv(CDPROGRAM_DIR) submix]
							set cmd [list $cmd balance cdptest2$evv(SNDFILE_EXT) cdptest3$evv(SNDFILE_EXT) cdptest4$evv(SNDFILE_EXT)]
							set spacdes_got 0
							if [catch {open "|$cmd"} CDPspac] {
								Inf "Cannot Merge The Respastialised Channels"
								catch {unset CDPspac}
								UnBlock
								continue
							} else {
								fileevent $CDPspac readable WriteSpaceDesignData2
							}
							vwait spacdes_got
							catch {close $CDPspac}
							if {$spac_error} {
								UnBlock
								continue
							}
							if {![file exists cdptest4$evv(SNDFILE_EXT)]} {
								Inf "Merging of the spatialised channels has failed"
								UnBlock
								continue
							}
							if [catch {file rename cdptest4$evv(SNDFILE_EXT) $sd(fnam2_full)} zit] {
								Inf "Failed to rename temporary output file 'cdptest4$evv(SNDFILE_EXT)'\n\nRename NOW, outside the CDP!"
							}
						}
						"rotate" {

							if {[string length $sd(filt)] > 0} {
								set stopfrq [expr $sd(filt) + (double($sd(filt))/4.0)]
								set cmd [file join $evv(CDPROGRAM_DIR) filter]
								set cmd [list $cmd lohi 1 $sd_infnam cdptest0$evv(SNDFILE_EXT) -96 $sd(filt) $stopfrq]
								set spacdes_got 0
								if [catch {open "|$cmd"} CDPspac] {
									Inf "Cannot Create Filtered Soundfile"
									catch {unset CDPspac}
									UnBlock
									continue
								} else {
									fileevent $CDPspac readable WriteSpaceDesignData2
								}
								vwait spacdes_got
								catch {close $CDPspac}
								if {$spac_error} {
									UnBlock
									continue
								}
								if {![file exists cdptest0$evv(SNDFILE_EXT)]} {
									Inf "Filtering of the soundfile has failed"
									UnBlock
									continue
								}
								set cmd [file join $evv(CDPROGRAM_DIR) submix]
								set cmd [list $cmd balance $sd_infnam cdptest0$evv(SNDFILE_EXT) cdptest1$evv(SNDFILE_EXT) -k$zfnam3]
								set spacdes_got 0
								if [catch {open "|$cmd"} CDPspac] {
									Inf "Cannot Create Mix Of Filtered And Original Soundfile"
									catch {unset CDPspac}
									DeleteAllTemporaryFiles
									UnBlock
									continue
								} else {
									fileevent $CDPspac readable WriteSpaceDesignData2
								}
								vwait spacdes_got
								catch {close $CDPspac}
								if {$spac_error} {
									DeleteAllTemporaryFiles
									UnBlock
									continue
								}
								if {![file exists cdptest1$evv(SNDFILE_EXT)]} {
									Inf "Filtering of the soundfile has failed"
									DeleteAllTemporaryFiles
									UnBlock
									continue
								}
								set file_to_process cdptest1$evv(SNDFILE_EXT)
							} else {
								set file_to_process $sd_infnam
							}
							set cmd [file join $evv(CDPROGRAM_DIR) modify]
							set cmd [list $cmd loudness 1 $file_to_process cdptest2$evv(SNDFILE_EXT) $zfnam2]
							set spacdes_got 0
							if [catch {open "|$cmd"} CDPspac] {
								Inf "Cannot Create Enveloped Soundfile"
								catch {unset CDPspac}
								DeleteAllTemporaryFiles
								UnBlock
								continue
							} else {
								fileevent $CDPspac readable WriteSpaceDesignData2
							}
							vwait spacdes_got
							catch {close $CDPspac}
							if {$spac_error} {
								DeleteAllTemporaryFiles
								UnBlock
								continue
							}
							if {![file exists cdptest2$evv(SNDFILE_EXT)]} {
								DeleteAllTemporaryFiles
								UnBlock
								continue
							}
							set cmd [file join $evv(CDPROGRAM_DIR) modify]
							set cmd [list $cmd space 1 cdptest2$evv(SNDFILE_EXT) cdptest3$evv(SNDFILE_EXT) $zfnam1]
							set spacdes_got 0
							if [catch {open "|$cmd"} CDPspac] {
								Inf "Cannot Respatialise Soundfile"
								catch {unset CDPspac}
								DeleteAllTemporaryFiles
								UnBlock
								continue
							} else {
								fileevent $CDPspac readable WriteSpaceDesignData2
							}
							vwait spacdes_got
							catch {close $CDPspac}
							if {$spac_error} {
								DeleteAllTemporaryFiles
								UnBlock
								continue
							}
							if {![file exists cdptest3$evv(SNDFILE_EXT)]} {
								Inf "Spatialisation has failed"
								DeleteAllTemporaryFiles
								UnBlock
								continue
							}
							if [catch {file rename cdptest3$evv(SNDFILE_EXT) $sd(fnam2_full)} zit] {
								Inf "Failed to rename temporary output file 'cdptest3$evv(SNDFILE_EXT)'\n\nRename NOW, outside the CDP!"
							}
						}
					}
					DeleteAllTemporaryFiles
					FileToWkspace $sd(fnam2_full) 0 0 0 0 1
					UnBlock
					Inf "The file '$sd(fnam2_full)' is now on the Worksapce"
				}
				0 {
					Inf "No mode set"
					continue
				}
			}
		} else {
			set finished 1
		}
	}
	DeleteAllTemporaryFiles
	$sd_list delete 0 end
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return
}

#------ Write Space Design Data to file

proc WriteSpaceDesignData {} {
	global CDPspac spacdes_got spac_error evv
	if [eof $CDPspac] {
		set spacdes_got 1
		catch {close $CDPspac}
		return
	} else {
		catch {set test [gets $CDPspac line]}
		if {[info exists test] && ($test >= 0)} {
			Inf "SpaceDesign: $line"
			set spac_error 1
			set spacdes_got 1
			catch {close $CDPspac}
		}
	}
}			

proc SetUpSDVars {mode} {
	global sd sd_infnam pa evv
	set f .spacedesign
	switch -- $mode {
		0 {
			$f.11.1.tabed config -text "" -state disabled -bg [option get . background {}] -bd 0
			$f.11.1.creat config -text "" -bd 0 -state disabled
			$f.11.1.find config -text "" -bd 0 -state disabled
			$f.3.lab1  config -text ""
			$f.3.stime config -bd 0 -state disabled
			$f.3.lab2  config -text ""
			$f.3.etime config -bd 0 -state disabled
			$f.3.lab3  config -text ""
			$f.3.epos  config -bd 0 -state disabled
			$f.3.lab4  config -text ""
			$f.3.pre   config -bd 0 -state disabled
			$f.3.lab0  config -text "\n"
			$f.3.far   config -bd 0 -state disabled
			$f.3.lab00  config -text "\n"
			$f.3.flt    config -bd 0 -state disabled
			$f.4.lab1   config -text "\n" -state disabled -bd 0
			$f.4.edge   config -bd 0 -state disabled
			$f.4.lab2   config -text "\n"
			$f.4.width  config -bd 0 -state disabled
			$f.4.lab3   config -text "\n"
			$f.4.linger config -bd 0 -state disabled
			$f.5.lab1   config -text "\n"
			$f.5.deep   config -bd 0 -state disabled
			$f.5.lab2   config -text "\n"
			$f.5.lead   config -bd 0 -state disabled
			$f.5.lab3   config -text "\n"
			$f.5.atten  config -bd 0 -state disabled
			$f.5.lab4   config -text ""
			$f.5.clock	config -state disabled
			$f.5.lab5   config -text ""
			$f.5.anti	config -state disabled
			$f.55.lab1a  config -text "\n"
			$f.55.warp   config -bd 0 -state disabled
			set sd(clock) -1	
			set sd(edge) ""
			set sd(width) ""
			set sd(linger) ""
			set sd(depth) ""
			set sd(lead) ""
			set sd(atten) ""
			set sd(filt) ""
			set sd(warp) ""

			bind $f.3.stime	 <Left> {}
			bind $f.3.etime	 <Left> {}
			bind $f.3.epos	 <Left> {}
			bind $f.3.pre	 <Left> {}
			bind $f.3.far	 <Left> {}
			bind $f.3.flt    <Left> {}
			bind $f.4.edge   <Left> {}
			bind $f.4.width  <Left> {}
			bind $f.4.linger <Left> {}
			bind $f.5.deep	 <Left> {}
			bind $f.5.lead	 <Left> {}
			bind $f.5.atten	 <Left> {}
			bind $f.55.warp	 <Left> {}
			bind $f.6.fnam	 <Left> {}
			bind $f.6.fnam2	 <Left> {}

			bind $f.3.stime	 <Right> {}
			bind $f.3.etime	 <Right> {}
			bind $f.3.epos	 <Right> {}
			bind $f.3.pre	 <Right> {}
			bind $f.3.far	 <Right> {}
			bind $f.3.flt    <Right> {}
			bind $f.4.edge   <Right> {}
			bind $f.4.width  <Right> {}
			bind $f.4.linger <Right> {}
			bind $f.5.deep	 <Right> {}
			bind $f.5.lead	 <Right> {}
			bind $f.5.atten	 <Right> {}
			bind $f.55.warp	 <Right> {}
			bind $f.6.fnam	 <Right> {}
			bind $f.6.fnam2	 <Right> {}

			bind $f.3.stime	 <Down> {}
			bind $f.3.etime	 <Down> {}
			bind $f.3.epos	 <Down> {}
			bind $f.3.pre	 <Down> {}
			bind $f.3.far	 <Down> {}
			bind $f.3.flt    <Down> {}
			bind $f.4.edge   <Down> {}
			bind $f.4.width  <Down> {}
			bind $f.4.linger <Down> {}
			bind $f.5.deep	 <Down> {}
			bind $f.5.lead	 <Down> {}
			bind $f.5.atten	 <Down> {}
			bind $f.55.warp	 <Down> {}
			bind $f.6.fnam	 <Down> {}
			bind $f.6.fnam2	 <Down> {}

			bind $f.3.stime	 <Up> {}
			bind $f.3.etime	 <Up> {}
			bind $f.3.epos	 <Up> {}
			bind $f.3.pre	 <Up> {}
			bind $f.3.far	 <Up> {}
			bind $f.3.flt    <Up> {}
			bind $f.4.edge   <Up> {}
			bind $f.4.width  <Up> {}
			bind $f.4.linger <Up> {}
			bind $f.5.deep	 <Up> {}
			bind $f.5.lead	 <Up> {}
			bind $f.5.atten	 <Up> {}
			bind $f.55.warp	 <Up> {}
			bind $f.6.fnam	 <Up> {}
			bind $f.6.fnam2	 <Up> {}
		}
		1 {
			$f.11.1.tabed config -text "" -state disabled -bg [option get . background {}] -bd 0
			$f.11.1.creat config -text "" -bd 0 -state disabled
			$f.11.1.find config -text "" -bd 0 -state disabled
			$f.3.lab1  config -text "start time"
			$f.3.stime config -bd 2 -state normal
			$f.3.lab2  config -text "end time"
			$f.3.etime config -bd 2 -state normal
			$f.3.lab3  config -text "end position"
			$f.3.epos config -bd 2 -state normal
			$f.3.lab4  config -text "prescale level"
			$f.3.pre   config -bd 2 -state normal
			$f.3.lab0   config -text "\n"
			$f.3.far    config -bd 0 -state disabled
			$f.3.lab00  config -text "\n"
			$f.3.flt    config -bd 0 -state disabled
			$f.4.lab1   config -text "\n" -state disabled -bd 0
			$f.4.edge   config -bd 0 -state disabled
			$f.4.lab2   config -text "\n"
			$f.4.width  config -bd 0 -state disabled
			$f.4.lab3   config -text "\n"
			$f.4.linger config -bd 0 -state disabled
			$f.5.lab1   config -text "\n"
			$f.5.deep   config -bd 0 -state disabled
			$f.5.lab2   config -text "\n"
			$f.5.lead   config -bd 0 -state disabled
			$f.5.lab3   config -text "\n"
			$f.5.atten  config -bd 0 -state disabled
			$f.5.lab4   config -text ""
			$f.5.clock	config -state disabled
			$f.5.lab5   config -text ""
			$f.5.anti	config -state disabled
			$f.55.lab1a  config -text "\n"
			$f.55.warp   config -bd 0 -state disabled
			set sd(clock) -1	
			set sd(starttime) "" 
			set sd(endtime) ""
			set sd(endpos) ""
			set sd(prescale) ""
			set sd(farpos) ""
			set sd(edge) ""
			set sd(width) ""
			set sd(linger) ""
			set sd(depth) ""
			set sd(lead) ""
			set sd(atten) ""
			set sd(filt) ""
			set sd(warp) ""

			bind $f.3.stime	 <Left> "focus $f.3.pre"
			bind $f.3.etime	 <Left> "focus $f.3.stime"
			bind $f.3.epos	 <Left> "focus $f.3.etime"
			bind $f.3.pre	 <Left> "focus $f.3.epos"
			bind $f.3.far	 <Left> {}
			bind $f.3.flt    <Left> {}
			bind $f.4.edge   <Left> {}
			bind $f.4.width  <Left> {}
			bind $f.4.linger <Left> {}
			bind $f.5.deep	 <Left> {}
			bind $f.5.lead	 <Left> {}
			bind $f.5.atten	 <Left> {}
			bind $f.55.warp	 <Left> {}
			bind $f.6.fnam	 <Left> "focus $f.6.fnam2"
			bind $f.6.fnam2	 <Left> "focus $f.6.fnam"

			bind $f.3.stime	 <Right> "focus $f.3.etime"
			bind $f.3.etime	 <Right> "focus $f.3.epos"
			bind $f.3.epos	 <Right> "focus $f.3.pre"
			bind $f.3.pre	 <Right> "focus $f.3.stime"
			bind $f.3.far	 <Right> {}
			bind $f.3.flt    <Right> {}
			bind $f.4.edge   <Right> {}
			bind $f.4.width  <Right> {}
			bind $f.4.linger <Right> {}
			bind $f.5.deep	 <Right> {}
			bind $f.5.lead	 <Right> {}
			bind $f.5.atten	 <Right> {}
			bind $f.55.warp	 <Right> {}
			bind $f.6.fnam	 <Right> "focus $f.6.fnam2"
			bind $f.6.fnam2	 <Right> "focus $f.6.fnam"

			bind $f.3.stime	 <Down> "focus $f.6.fnam"
			bind $f.3.etime	 <Down> "focus $f.6.fnam"
			bind $f.3.epos	 <Down> "focus $f.6.fnam2"
			bind $f.3.pre	 <Down> "focus $f.6.fnam2"
			bind $f.3.far	 <Down> {}
			bind $f.3.flt    <Down> {}
			bind $f.4.edge   <Down> {}
			bind $f.4.width  <Down> {}
			bind $f.4.linger <Down> {}
			bind $f.5.deep	 <Down> {}
			bind $f.5.lead	 <Down> {}
			bind $f.5.atten	 <Down> {}
			bind $f.55.warp	 <Down> {}
			bind $f.6.fnam	 <Down> "focus $f.3.stime"
			bind $f.6.fnam2	 <Down> "focus $f.3.pre"

			bind $f.3.stime	 <Up> "focus $f.6.fnam"
			bind $f.3.etime	 <Up> "focus $f.6.fnam"
			bind $f.3.epos	 <Up> "focus $f.6.fnam2"
			bind $f.3.pre	 <Up> "focus $f.6.fnam2"
			bind $f.3.far	 <Up> {}
			bind $f.3.flt    <Up> {}
			bind $f.4.edge   <Up> {}
			bind $f.4.width  <Up> {}
			bind $f.4.linger <Up> {}
			bind $f.5.deep	 <Up> {}
			bind $f.5.lead	 <Up> {}
			bind $f.5.atten	 <Up> {}
			bind $f.55.warp	 <Up> {}
			bind $f.6.fnam	 <Up> "focus $f.3.stime"
			bind $f.6.fnam2	 <Up> "focus $f.3.pre"
		}
		2 {
			$f.11.1.tabed config -text "" -state disabled -bg [option get . background {}] -bd 0
			$f.11.1.creat config -text "" -bd 0 -state disabled
			$f.11.1.find config -text "" -bd 0 -state disabled
			$f.3.lab1  config -text "start time"
			$f.3.stime config -bd 2 -state normal
			$f.3.lab2  config -text "end time"
			$f.3.etime config -bd 2 -state normal
			$f.3.lab3  config -text "start position"
			$f.3.epos config -bd 2 -state normal
			$f.3.lab4  config -text "prescale level"
			$f.3.pre   config -bd 2 -state normal
			$f.3.lab0   config -text "\n"
			$f.3.far    config -bd 0 -state disabled
			$f.3.lab00  config -text "\n"
			$f.3.flt    config -bd 0 -state disabled
			$f.4.lab1   config -text "\n" -state disabled -bd 0
			$f.4.edge   config -bd 0 -state disabled
			$f.4.lab2   config -text "\n"
			$f.4.width  config -bd 0 -state disabled
			$f.4.lab3   config -text "\n"
			$f.4.linger config -bd 0 -state disabled
			$f.5.lab1   config -text "\n"
			$f.5.deep   config -bd 0 -state disabled
			$f.5.lab2   config -text "\n"
			$f.5.lead   config -bd 0 -state disabled
			$f.5.lab3   config -text "\n"
			$f.5.atten  config -bd 0 -state disabled
			$f.5.lab4   config -text ""
			$f.5.clock	config -state disabled
			$f.5.lab5   config -text ""
			$f.5.anti	config -state disabled
			$f.55.lab1a  config -text "\n"
			$f.55.warp   config -bd 0 -state disabled
			set sd(clock) -1	
			set sd(starttime) "" 
			set sd(endtime) ""
			set sd(endpos) ""
			set sd(prescale) ""
			set sd(farpos) ""
			set sd(edge) ""
			set sd(width) ""
			set sd(linger) ""
			set sd(depth) ""
			set sd(lead) ""
			set sd(atten) ""
			set sd(filt) ""
			set sd(warp) ""

			bind $f.3.stime	 <Left> "focus $f.3.pre"
			bind $f.3.etime	 <Left> "focus $f.3.stime"
			bind $f.3.epos	 <Left> "focus $f.3.etime"
			bind $f.3.pre	 <Left> "focus $f.3.epos"
			bind $f.3.far	 <Left> {}
			bind $f.3.flt    <Left> {}
			bind $f.4.edge   <Left> {}
			bind $f.4.width  <Left> {}
			bind $f.4.linger <Left> {}
			bind $f.5.deep	 <Left> {}
			bind $f.5.lead	 <Left> {}
			bind $f.5.atten	 <Left> {}
			bind $f.55.warp	 <Left> {}
			bind $f.6.fnam	 <Left> "focus $f.6.fnam2"
			bind $f.6.fnam2	 <Left> "focus $f.6.fnam"

			bind $f.3.stime	 <Right> "focus $f.3.etime"
			bind $f.3.etime	 <Right> "focus $f.3.epos"
			bind $f.3.epos	 <Right> "focus $f.3.pre"
			bind $f.3.pre	 <Right> "focus $f.3.stime"
			bind $f.3.far	 <Right> {}
			bind $f.3.flt    <Right> {}
			bind $f.4.edge   <Right> {}
			bind $f.4.width  <Right> {}
			bind $f.4.linger <Right> {}
			bind $f.5.deep	 <Right> {}
			bind $f.5.lead	 <Right> {}
			bind $f.5.atten	 <Right> {}
			bind $f.55.warp	 <Right> {}
			bind $f.6.fnam	 <Right> "focus $f.6.fnam2"
			bind $f.6.fnam2	 <Right> "focus $f.6.fnam"

			bind $f.3.stime	 <Down> "focus $f.6.fnam"
			bind $f.3.etime	 <Down> "focus $f.6.fnam"
			bind $f.3.epos	 <Down> "focus $f.6.fnam2"
			bind $f.3.pre	 <Down> "focus $f.6.fnam2"
			bind $f.3.far	 <Down> {}
			bind $f.3.flt    <Down> {}
			bind $f.4.edge   <Down> {}
			bind $f.4.width  <Down> {}
			bind $f.4.linger <Down> {}
			bind $f.5.deep	 <Down> {}
			bind $f.5.lead	 <Down> {}
			bind $f.5.atten	 <Down> {}
			bind $f.55.warp	 <Down> {}
			bind $f.6.fnam	 <Down> "focus $f.3.stime"
			bind $f.6.fnam2	 <Down> "focus $f.3.pre"

			bind $f.3.stime	 <Up> "focus $f.6.fnam"
			bind $f.3.etime	 <Up> "focus $f.6.fnam"
			bind $f.3.epos	 <Up> "focus $f.6.fnam2"
			bind $f.3.pre	 <Up> "focus $f.6.fnam2"
			bind $f.3.far	 <Up> {}
			bind $f.3.flt    <Up> {}
			bind $f.4.edge   <Up> {}
			bind $f.4.width  <Up> {}
			bind $f.4.linger <Up> {}
			bind $f.5.deep	 <Up> {}
			bind $f.5.lead	 <Up> {}
			bind $f.5.atten	 <Up> {}
			bind $f.55.warp	 <Up> {}
			bind $f.6.fnam	 <Up> "focus $f.3.stime"
			bind $f.6.fnam2	 <Up> "focus $f.3.pre"
		}
		3 {
			$f.11.1.tabed config -text "Table Editor" -state normal -bd 2 ;# -bg $evv(HELP)
			$f.11.1.creat config -text "Create Textfile" -bd 2 -state normal
			$f.11.1.find config -text "Find Textfile" -bd 2 -state normal
			$f.3.lab1  config -text "start time"
			$f.3.stime config -bd 2 -state normal
			$f.3.lab2  config -text "end time"
			$f.3.etime config -bd 2 -state normal
			$f.3.lab3  config -text "start position"
			$f.3.epos config -bd 2 -state normal
			$f.3.lab4  config -text ""
			$f.3.pre   config -bd 0 -state disabled
			$f.3.lab0   config -text "end position"
			$f.3.far    config -bd 2 -state normal
			$f.3.lab00  config -text "distance filter\ncutoff frq (if any)"
			$f.3.flt    config -bd 2 -state normal
			$f.4.lab1   config -text "times\nat edges of space" -command CreateSpaceText -state normal -bd 2
			$f.4.edge   config -bd 2 -state normal
			$f.4.lab2   config -text "rotation width\n(0-1)"
			$f.4.width  config -bd 2 -state normal
			$f.4.lab3   config -text "proportion of time\nat edge of space(>0 to <1)"
			$f.4.linger config -bd 2 -state normal
			$f.5.lab1   config -text "ratio of front level\nto rear level"
			$f.5.deep   config -bd 2 -state normal
			$f.5.lab2   config -text "maxlevel leads\ncentre position by(0-1)"
			$f.5.lead   config -bd 2 -state normal
			$f.5.lab3   config -text "overall attenuation\n(>0 to 10)"
			$f.5.atten  config -bd 2 -state normal
			$f.5.lab4   config -text "clockwise"
			$f.5.clock	config -state normal
			$f.5.lab5   config -text "anticlock"
			$f.5.anti	config -state normal
			$f.55.lab1a  config -text "ratio time at rear\nto time at front(1-20) (optional)"
			$f.55.warp	config -bd 2 -state normal   
			set sd(clock) 1	
			set sd(starttime) $evv(SD_START) 
			set sd(endtime) $pa($sd_infnam,$evv(DUR))
			set sd(endpos) ""
			set sd(prescale) ""
			set sd(farpos) ""
			set sd(edge) ""
			set sd(width) $evv(SD_WIDTH)
			set sd(linger) $evv(SD_LINGER)
			set sd(depth) $evv(SD_DEPTH)
			set sd(lead) $evv(SD_LEAD)
			set sd(atten) 1.0
			set sd(filt) $evv(SD_FILT)
			set sd(warp) ""

			bind $f.3.pre	 <Left>  {}
			bind $f.3.pre	 <Right> {}
			bind $f.3.pre	 <Up>	 {}
			bind $f.3.pre	 <Down>	 {}

			bind $f.3.stime	 <Left> "focus $f.6.fnam2"
			bind $f.3.etime	 <Left> "focus $f.3.stime"
			bind $f.3.epos	 <Left> "focus $f.3.etime"
			bind $f.3.far	 <Left> "focus $f.3.epos"
			bind $f.3.flt    <Left> "focus $f.3.far"
			bind $f.4.edge   <Left> "focus $f.3.flt"
			bind $f.4.width  <Left> "focus $f.4.edge"
			bind $f.4.linger <Left> "focus $f.4.width"
			bind $f.5.deep	 <Left> "focus $f.4.linger"
			bind $f.5.lead	 <Left> "focus $f.5.deep"
			bind $f.5.atten	 <Left> "focus $f.5.lead"
			bind $f.55.warp	 <Left> "focus $f.5.atten"
			bind $f.6.fnam	 <Left> "focus $f.55.warp"
			bind $f.6.fnam2	 <Left> "focus $f.6.fnam"

			bind $f.3.stime	 <Right> "focus $f.3.etime"
			bind $f.3.etime	 <Right> "focus $f.3.epos"
			bind $f.3.epos	 <Right> "focus $f.3.far"
			bind $f.3.far	 <Right> "focus $f.3.flt"
			bind $f.3.flt    <Right> "focus $f.4.edge"
			bind $f.4.edge   <Right> "focus $f.4.width"
			bind $f.4.width  <Right> "focus $f.4.linger"
			bind $f.4.linger <Right> "focus $f.5.deep"
			bind $f.5.deep	 <Right> "focus $f.5.lead"
			bind $f.5.lead	 <Right> "focus $f.5.atten"
			bind $f.5.atten	 <Right> "focus $f.55.warp"
			bind $f.55.warp	 <Right> "focus $f.6.fnam"
			bind $f.6.fnam	 <Right> "focus $f.6.fnam2"
			bind $f.6.fnam2	 <Right> "focus $f.3.etime"

			bind $f.3.stime	 <Down> "focus $f.4.edge"
			bind $f.3.etime	 <Down> "focus $f.4.edge"
			bind $f.3.epos	 <Down> "focus $f.5.lead"
			bind $f.3.far	 <Down> "focus $f.5.atten"
			bind $f.3.flt    <Down> "focus $f.4.linger"
			bind $f.4.edge   <Down> "focus $f.5.deep"
			bind $f.4.width  <Down> "focus $f.5.lead"
			bind $f.4.linger <Down> "focus $f.55.warp"
			bind $f.5.deep	 <Down> "focus $f.6.fnam"
			bind $f.5.lead	 <Down> "focus $f.6.fnam"
			bind $f.5.atten	 <Down> "focus $f.6.fnam2"
			bind $f.55.warp	 <Down> "focus $f.6.fnam2"
			bind $f.6.fnam	 <Down> "focus $f.3.stime"
			bind $f.6.fnam2	 <Down> "focus $f.3.far"

			bind $f.3.stime	 <Up> "focus $f.6.fnam"
			bind $f.3.etime	 <Up> "focus $f.6.fnam"
			bind $f.3.epos	 <Up> "focus $f.6.fnam"
			bind $f.3.far	 <Up> "focus $f.6.fnam2"
			bind $f.3.flt    <Up> "focus $f.6.fnam2"
			bind $f.4.edge   <Up> "focus $f.3.stime"
			bind $f.4.width  <Up> "focus $f.3.epos"
			bind $f.4.linger <Up> "focus $f.3.flt"
			bind $f.5.deep	 <Up> "focus $f.4.edge"
			bind $f.5.lead	 <Up> "focus $f.3.epos"
			bind $f.5.atten	 <Up> "focus $f.3.far"
			bind $f.55.warp	 <Up> "focus $f.4.linger"
			bind $f.6.fnam	 <Up> "focus $f.5.deep"
			bind $f.6.fnam2	 <Up> "focus $f.55.warp"
		}
	}
}

proc ClearSDVars {} {
	global sd spacdes_clear
	set f .spacedesign
	foreach name [array names sd] {
		set sd($name) "" 
	}
	set spacdes_clear 0
}

#------ Write Space Design Data to file

proc WriteSpaceDesignData2 {} {
	global CDPspac spacdes_got spac_error sd_list evv
	if [eof $CDPspac] {
		set spacdes_got 1
		catch {close $CDPspac}
		return
	} else {
		catch {set test [gets $CDPspac line]}
		if {[info exists test] && ($test >= 0)} {
			$sd_list insert end "$line"
			if {[string match "ERROR:*" $line]} {			
				set spac_error 1
				set spacdes_got 1
				catch {close $CDPspac}
			}
		}
	}
}			

proc FilesExtend {} {
	global chlist evv pa pr_fextend fextend_dur fextend_ext fextend_splic fe_list
	global spac_error CDPspac spacdes_got
	if {![info exists chlist] || ([llength $chlist] <= 0)} {
		Inf "No Files Chosen"
		return
	}
	foreach fnam $chlist {
		if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
			Inf "File '$fnam' Is Not A Soundfile"
			return
		}
	}
	set f .fextend
	if [Dlg_Create $f "Extend Files" "set pr_fextend 0" -borderwidth $evv(SBDR)] {
		frame $f.1
		frame $f.2
		frame $f.3
		button $f.1.run  -text "Extend" -command "set pr_fextend 1" -highlightbackground [option get . background {}]
		button $f.1.quit -text "Close" -command "set pr_fextend 0" -highlightbackground [option get . background {}]
		pack $f.1.run -side left
		pack $f.1.quit -side right
		label $f.2.labd -text "Minimum Output Duration"
		entry $f.2.e -textvariable fextend_dur -width 12
		label $f.2.labs -text "Splice Length (ms)"
		entry $f.2.e2 -textvariable fextend_splic -width 12
		label $f.2.labf -text "Name Extension"
		entry $f.2.e3 -textvariable fextend_ext -width 12
		pack $f.2.labd $f.2.e $f.2.labs $f.2.e2 $f.2.labf $f.2.e3 -side left -padx 2
		set fe_list [Scrolled_Listbox $f.3.list -width 120 -height 10]
		pack $f.3.list -side top  -fill both -expand true
		pack $f.1 $f.2 $f.3 -side top -fill x -expand true
		bind $f <Return> {set pr_fextend 1}
		bind $f <Escape> {set pr_fextend 0}
	}
	$fe_list delete 0 end
	set pr_fextend 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition2 .fextend
	My_Grab 0 $f pr_fextend $f.2.e
	while {!$finished} {
		tkwait variable pr_fextend
		if {$pr_fextend} {
			if {![IsNumeric $fextend_dur] || ($fextend_dur <= 0.0)} {
				Inf "Invalid Duration Value"
				continue
			}
			foreach fnam $chlist {
				if {$pa($fnam,$evv(DUR)) < $fextend_dur} {
					lappend nulist $fnam
				}
			}
			if {![info exists nulist]} {
				Inf "All Files Are Longer Than The Specified Duration"
				continue
			}
			if {![IsNumeric $fextend_splic] || ($fextend_splic <= 0.0)} {
				Inf "Invalid Splicelength Value"
				continue
			}
			if {![regexp {^[A-Za-z0-9]+$} $fextend_ext]} {
				Inf "Invalid Filename Extension : Must Be Alphanumeric"
				continue
			}
			Block "Extending Files"
			set cnt 0
			set OK 1
			foreach fnam $nulist {
				set k [expr int(ceil(double($fextend_dur) / double($pa($fnam,$evv(DUR)))))]
				incr k -1
				if {$k < 1} {
					set OK 0
					break
				}
				if {![CheckExistingFextFiles $fnam $k]} {
					continue
				}
				set cmd [file join $evv(CDPROGRAM_DIR) housekeep]
				lappend cmd copy 2 $fnam $k
				set spac_error 0
				catch {close $CDPspac}
				if [catch {open "|$cmd"} CDPspac] {
					Inf "Cannot Make (all) Copies Of File '$fnam' : $CDPspac"
					catch {unset CDPspac}
					ClearExtFiles $fnam $k
					set OK 0
					break
				} else {
					fileevent $CDPspac readable WriteFilesExtend
				}
				vwait spacdes_got
				catch {close $CDPspac}
				if {$spac_error} {
					ClearExtFiles $fnam $k
					set OK 0
					break
				}
				set cmd [file join $evv(CDPROGRAM_DIR) sfedit]
				lappend cmd join $fnam
				set m 1
				set fnambas [file rootname [file tail $fnam]]
				while {$m <= $k} {
					set fnamin $fnambas
					if {$m < 10} {
						append fnamin "_00" $m
					} elseif {$m < 100} {
						append fnamin "_0" $m
					} else {
						append fnamin "_" $m
					}
					append fnamin $evv(SNDFILE_EXT)
					lappend cmd $fnamin
					incr m
				}
				append fnambas "_" [string tolower $fextend_ext]
				lappend cmd $fnambas
				lappend cmd "-w$fextend_splic"
				set spac_error 0
				catch {close $CDPspac}
				if [catch {open "|$cmd"} CDPspac] {
					Inf "Cannot Join Copies Of File '$fnam' : $CDPspac"
					catch {unset CDPspac}
					ClearExtFiles $fnam $k
					set OK 0
					break
				} else {
					fileevent $CDPspac readable WriteFilesExtend
				}
				vwait spacdes_got
				catch {close $CDPspac}
				if {$spac_error} {
					ClearExtFiles $fnam $k
					set OK 0
					break
				}
				ClearExtFiles $fnam $k
				FileToWkspace $fnambas$evv(SNDFILE_EXT) 0 0 0 0 1
				incr cnt
			}
			if {!$OK} {
				UnBlock
				continue
			}
			if {$cnt > 0} {
				Inf "The Extended files are on the workspace"
			}
			UnBlock
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return
}

proc ClearExtFiles {fnam k} {
	global evv
	set m 1
	while {$m <= $k} {
		set fnamin [file rootname [file tail $fnam]]
		if {$m < 10} {
			append fnamin "_00" $m
		} elseif {$m < 100} {
			append fnamin "_0" $m
		} else {
			append fnamin "_" $m
		}
		append fnamin $evv(SNDFILE_EXT)
		if {[file exists $fnamin]} {
			if [catch {file delete $fnamin} zit] {
				Inf "Cannot delete intermediate file '$fnamin'"
			}
		}
		incr m
	}
}

proc CheckExistingFextFiles {fnam k} {
	global evv
	set m 1
	set OK 1
	while {$m <= $k} {
		set fnamout [file rootname [file tail $fnam]]
		if {$m < 10} {
			append fnamout "_00" $m
		} elseif {$m < 100} {
			append fnamout "_0" $m
		} else {
			append fnamout "_" $m
		}
		append fnamout $evv(SNDFILE_EXT)
		if {[file exists $fnamout]} {
			Inf "Cannot Make Copies Of File '$fnam' : File '$fnamout' already exists"
			return 0
		}
		incr m
	}
	return 1
}

#------ Write Files Extend Data to file

proc WriteFilesExtend {} {
	global CDPspac spacdes_got spac_error fe_list evv
	if [eof $CDPspac] {
		set spacdes_got 1
		catch {close $CDPspac}
		return
	} else {
		catch {set test [gets $CDPspac line]}
		if {[info exists test] && ($test >= 0)} {
			$fe_list insert end "$line"
			if {[string match "ERROR:*" $line]} {			
				set spac_error 1
				set spacdes_got 1
				catch {close $CDPspac}
			}
		}
	}
}			

proc PlayRotate {} {
	global sd
	if {[info exists sd(fnam2_full)] && [file exists $sd(fnam2_full)]} {
		PlaySndfile $sd(fnam2_full) 0
	} else {
		Inf "No Outfile to Play"
	}
}

proc FilesCurtail {} {
	global chlist evv pa pr_fcurtail fcurtail_ext fcurtail_splic fe_list
	global spacdes_got spac_error CDPspac ch chcnt
	if {![info exists chlist] || ([llength $chlist] <= 1)} {
		Inf "Only One File Chosen"
		return
	}
	foreach fnam $chlist {
		if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
			Inf "File '$fnam' Is Not A Soundfile"
			return
		}
	}
	set outdur $pa([lindex $chlist 0],$evv(DUR))
	foreach fnam [lrange $chlist 1 end] {
		if {$pa($fnam,$evv(DUR)) <= $outdur} {
			lappend badfiles $fnam
		}
	}
	if {[info exists badfiles]} {
		set msg "The Following Files Are Already Equal To Or Shorter Than [lindex $chlist 0]\n\n"
		set n 0
		foreach fnam $badfiles {
			incr n
			if {$n > 20} {
				append msg "\nAnd More"
				break
			}
			append msg $fnam "   "
		}
		Inf $msg
		return 0
	}
	set f .fcurtail
	if [Dlg_Create $f "Curtail Files to length of First" "set pr_fcurtail 0" -borderwidth $evv(SBDR)] {
		frame $f.1
		frame $f.2
		frame $f.3
		button $f.1.run  -text "Cut" -command "set pr_fcurtail 1" -highlightbackground [option get . background {}]
		button $f.1.quit -text "Close" -command "set pr_fcurtail 0" -highlightbackground [option get . background {}]
		pack $f.1.run -side left
		pack $f.1.quit -side right
		label $f.2.labs -text "Splice Length (ms)"
		entry $f.2.e2 -textvariable fcurtail_splic -width 12
		label $f.2.labf -text "Name Extension"
		entry $f.2.e3 -textvariable fcurtail_ext -width 12
		pack $f.2.labs $f.2.e2 $f.2.labf $f.2.e3 -side left -padx 2
		set fe_list [Scrolled_Listbox $f.3.list -width 120 -height 10]
		pack $f.3.list -side top  -fill both -expand true
		pack $f.1 $f.2 $f.3 -side top -fill x -expand true
		bind $f <Return> {set pr_fcurtail 1}
		bind $f <Escape> {set pr_fcurtail 0}
	}
	$fe_list delete 0 end
	set pr_fcurtail 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition2 .fcurtail
	My_Grab 0 $f pr_fcurtail $f.2.e3
	while {!$finished} {
		tkwait variable pr_fcurtail
		if {$pr_fcurtail} {
			if {![IsNumeric $fcurtail_splic] || ($fcurtail_splic <= 0.0)} {
				Inf "Invalid Splicelength Value"
				continue
			}
			if {[expr 2.0 * ($fcurtail_splic / 1000.0)] >= $outdur} {
				Inf "Splicelength Too Long For Duration Required"
				continue
			}
			if {![regexp {^[A-Za-z0-9]+$} $fcurtail_ext]} {
				Inf "Invalid Filename Extension : Must Be Alphanumeric"
				continue
			}
			set OK 1
			catch {unset nulist}
			foreach fnam [lrange $chlist 1 end] {
				set testfnam [file rootname [file tail $fnam]]
				append testfnam "_" $fcurtail_ext $evv(SNDFILE_EXT)
				if {[file exists $testfnam]} {
					Inf "File $testfnam Already Exists"
					set OK 0
					break
				}
				lappend nulist $testfnam
			}
			if {!$OK} {
				continue
			}
			Block "Cutting Files"
			set cnt 0
			catch {unset donefiles}
			catch {unset donenames}
			foreach fnam [lrange $chlist 1 end] fnamout $nulist {
				incr cnt
				set cmd [file join $evv(CDPROGRAM_DIR) sfedit]
				lappend cmd cut 1 $fnam $fnamout 0.0 $outdur -w$fcurtail_splic
				set spac_error 0
				catch {close $CDPspac}
				if [catch {open "|$cmd"} CDPspac] {
					Inf "Cannot Make Cut Copy Of File '$fnam' : $CDPspac"
					catch {unset CDPspac}
					continue
				} else {
					fileevent $CDPspac readable WriteFilesExtend
				}
				vwait spacdes_got
				catch {close $CDPspac}
				if {$spac_error} {
					continue
				}
				FileToWkspace $fnamout 0 0 0 0 1
				lappend donefiles $cnt
				lappend donenames $fnamout
			}
			if [info exists donefiles] {
				DoChoiceBak
				foreach fnam $donenames {
					lappend chlist $fnam
				}
				set donefiles [ReverseList $donefiles]
				foreach item $donefiles {
					set chlist [lreplace $chlist $item $item]
				}
				$ch delete 0 end
				set chcnt 0
				foreach fnam $chlist {
					$ch insert end $fnam
					incr chcnt
				}
			}
			UnBlock
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return
}

proc SaveSD {} {
	global sd evv wstk 
	set data $sd(mode)
	if {[string length $sd(save)] <= 0} {
		Inf "No Filename Entered"
		return
	}
	if {![ValidCDPRootname $sd(save)]} {
		return
	}
	set fnam $sd(save)
	append fnam $evv(TEXT_EXT)
	if {[file exists $fnam]} {
		set msg "File '$fnam' already exists: Overwrite it?"
		set choice [tk_messageBox -type yesno -message $msg -icon question -parent [lindex $wstk end]]
		if [string match $choice "no"] {
			return
		}
	}
	switch --  $sd(mode) {
		0 {
			Inf "NO DATA TO SAVE"
			return
		}
		"mtos" -
		"stom" {
			if {([string length $sd(starttime)] <= 0) || \
			([string length $sd(endtime)] <= 0) || \
			([string length $sd(endpos)] <= 0) || \
			([string length $sd(prescale)] <= 0) || \
			([string length $sd(datafnam)] <= 0) || \
			([string length $sd(sndfnam)] <= 0)} {
				Inf "Incomplete Data"
				return
			}
			lappend data $sd(starttime) $sd(endtime) $sd(endpos) $sd(prescale) $sd(datafnam) $sd(sndfnam)
		}
		"rotate" {
			if {([string length $sd(starttime)] <= 0) || \
			([string length $sd(endtime)] <= 0) || \
			([string length $sd(endpos)] <= 0) || \
			([string length $sd(farpos)] <= 0) || \
			([string length $sd(edge)] <= 0) || \
			([string length $sd(width)] <= 0) || \
			([string length $sd(linger)] <= 0) || \
			([string length $sd(depth)] <= 0) || \
			([string length $sd(lead)] <= 0) || \
			([string length $sd(atten)] <= 0) || \
			([string length $sd(datafnam)] <= 0) || \
			([string length $sd(sndfnam)] <= 0) || \
			($sd(clock) < 0)} {
				Inf "Incomplete Data"
				return
			}
			lappend data $sd(starttime) $sd(endtime) $sd(endpos) $sd(farpos) $sd(edge) $sd(width)
			lappend data $sd(linger) $sd(depth) $sd(lead) $sd(atten) $sd(clock)
			if {[string length $sd(warp)] == 0} {
				lappend data 1.0
			} else {
				lappend data $sd(warp)
			}
			if {[string length $sd(filt)] > 0} {
				lappend data $sd(filt)
			}
			lappend data $sd(datafnam) $sd(sndfnam)
		}
	}
	if [catch {open $fnam "w"} zit] {
		Inf "Cannot open file $fnam to save data"
		return
	}
	foreach item $data {
		puts $zit $item
	}
	close $zit
	FileToWkspace $fnam 0 0 0 0 1
	Inf "Stored Data in file $fnam"
	return
}

proc LoadSD {} {
	global sd evv wstk pa wl pr_sdload lsd_list
	foreach fnam [$wl get 0 end] {
		if {[info exists pa($fnam,$evv(FTYP))] && ($pa($fnam,$evv(FTYP)) == $evv(WORDLIST))} {
			set wdcnt $pa($fnam,$evv(ALL_WORDS))
			if {($wdcnt == 7) || ($wdcnt == 15) || ($wdcnt == 16)} {
				lappend posfiles $fnam
			}
		}
	}
	if {![info exists posfiles]} {
		Inf "There Are No Space Design Datafiles On The Workspace"
		return
	}
	if {[llength $posfiles] == 1} {
		set fnam [lindex $posfiles 0]
		GetSDdata $fnam
		return
	}
	set f .sdload
	if [Dlg_Create $f "Load Space Design Data" "set pr_sdload 0" -borderwidth $evv(SBDR)] {
		frame $f.1
		frame $f.2
		button $f.1.run  -text "Load" -command "set pr_sdload 1" -highlightbackground [option get . background {}]
		button $f.1.quit -text "Close" -command "set pr_sdload 0" -highlightbackground [option get . background {}]
		pack $f.1.run -side left
		pack $f.1.quit -side right
		set lsd_list [Scrolled_Listbox $f.2.list -width 120 -height 10 -selectmode single]
		pack $f.2.list -side top  -fill both -expand true
		pack $f.1 $f.2 -side top -fill x -expand true
		bind $f <Return> {set pr_sdload 1}
		bind $f <Escape> {set pr_sdload 0}
	}
	$lsd_list delete 0 end
	foreach fnam $posfiles {
		$lsd_list insert end $fnam
	}
	set pr_sdload 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition2 .sdload
	My_Grab 0 $f pr_sdload $lsd_list
	while {!$finished} {
		tkwait variable pr_sdload
		catch {unset data}
		if {$pr_sdload} {
			set i [$lsd_list curselection]
			if {$i < 0} {
				Inf "No File Selected"
				continue
			}
			set fnam [$lsd_list get $i]
			if {![GetSDdata $fnam]} {
				continue
			}
		}
		set finished 1
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return
}

proc GetSDdata {fnam} {
	global sd pa evv
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File $fnam To Read Data"
		return 0
	}
	set n 1
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		switch -- $n {
			1 {
				switch -- $line {
					"stom" -
					"mtos" -
					"rotate" {
					}
					default {
						Inf "Invalid Mode Data In File"
						close $zit
						return 0
					}
				}
			}
			2 -
			3 -
			4 - 
			5 - 
			8 -
			9 -
			10 -
			11 -
			13 {
				if {![IsNumeric $line]} {
					Inf "Invalid (Non-Numeric) Data In File At Line $n"
					close $zit
					return 0
				}
			}
			12 {
				if {!([string match $line "0"] || [string match $line "1"])} {
					Inf "Invalid Clockwise/Anticlockwise Data (1/0) In File at line $n"
					close $zit
					return 0
				}
			}
			14 {
				set wdcnt $pa($fnam,$evv(ALL_WORDS))
				if {$wdcnt > 15} {
					if {![IsNumeric $line]} {
						Inf "Invalid Filter Frq Data In File At Line $n"
						close $zit
						return 0
					}
				}
			}
			6 -
			7 -
			15 - 
			16 {	;# NO CHECK, it's a filename or (7) filename-or-number
			}
		}
		lappend data $line
		incr n
	}
	close $zit
	if {![info exists data]} {
		Inf "Failed To Read Any Data From File $fnam"
		return 0
	}
	incr n -1
	if {!(($n == 7) || ($n == 15) || ($n == 16))} {
		Inf "Invalid Data Count From File $fnam"
		return 0
	}
	incr n -2
	set m 0
	while {$m < $n} {
		switch -- $m {
			0  { 
				set sd(mode) [lindex $data $m]
				switch --  $sd(mode) {
					"stom"	 {SetUpSDVars 1}
					"mtos"	 {SetUpSDVars 2}
					"rotate" {SetUpSDVars 3}
				}
			}
			1  { set sd(starttime) [lindex $data $m] }
			2  { set sd(endtime)   [lindex $data $m] }
			3  { set sd(endpos)	   [lindex $data $m] }
			4  {
				if {$n == 5} { 
					set sd(prescale)  [lindex $data $m]
				} else {
					set sd(farpos)	  [lindex $data $m]
				 }
			}
			5  { set sd(edge)	   [lindex $data $m] }
			6  { set sd(width)	   [lindex $data $m] }
			7  { set sd(linger)	   [lindex $data $m] }
			8  { set sd(depth)	   [lindex $data $m] }
			9  { set sd(lead)	   [lindex $data $m] }
			10 { set sd(atten)	   [lindex $data $m] }
			11 { set sd(clock)	   [lindex $data $m] }
			12 { set sd(warp)	   [lindex $data $m] }
			13 { set sd(filt)	   [lindex $data $m] }
		}  
		incr m
	}
	set sd(datafnam)  [lindex $data $m]
	incr m
	set sd(sndfnam)   [lindex $data $m]
	return 1
}

proc SDFind {} {
	global wl pa evv pr_sdfind lsf_list sd
	foreach fnam [$wl get 0 end] {
		if {[info exists pa($fnam,$evv(FTYP))]} {
			if {$pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)} {
				lappend posfiles $fnam
			}
		}
	}
	if {![info exists posfiles]} {
		Inf "No Textfiles On Workspace"	
		return
	}
	set f .sdfind
	if [Dlg_Create $f "Find Textfiles" "set pr_sdfind 0" -borderwidth $evv(SBDR)] {
		frame $f.1
		frame $f.2
		button $f.1.run1 -text "Load as Edge Times File" -command "set pr_sdfind 1" -highlightbackground [option get . background {}]
		button $f.1.run2 -text "Load as Width File" -command "set pr_sdfind 2" -highlightbackground [option get . background {}]
		button $f.1.view -text "See File" -command "set pr_sdfind 3" -highlightbackground [option get . background {}]
		button $f.1.quit -text "Close" -command "set pr_sdfind 0" -highlightbackground [option get . background {}]
		pack $f.1.run1 $f.1.run2 -side left
		pack $f.1.quit $f.1.view -side right -padx 4
		set lsf_list [Scrolled_Listbox $f.2.list -width 120 -height 10 -selectmode single]
		pack $f.2.list -side top  -fill both -expand true
		pack $f.1 $f.2 -side top -fill x -expand true
		bind $f <Escape>  {set pr_sdfind 0}
	}
	$lsf_list delete 0 end
	foreach fnam $posfiles {
		$lsf_list insert end $fnam
	}
	set pr_sdfind 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition2 .sdfind
	My_Grab 0 $f pr_sdfind $lsf_list
	while {!$finished} {
		tkwait variable pr_sdfind
		if {$pr_sdfind} {
			set i [$lsf_list curselection]
			if {$i < 0} {
				Inf "No File Selected"	
				continue
			}
			set fnam [$lsf_list get $i]
			switch -- $pr_sdfind {
				1 {
					set sd(edge) $fnam
				}
				2 {
					set sd(width) $fnam
				}
				3 {
					SimpleDisplayTextfile $fnam
					continue
				}
			}
		}
		set finished 1
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return
}

proc FilesMono {} {
	global chlist evv pa pr_fmono fmono_ext fe_list
	global spacdes_got spac_error CDPspac ch chcnt wstk

	if {![info exists chlist] || ([llength $chlist] <= 0)} {
		Inf "No Files Chosen"
		return
	}
	set warned 0
	foreach fnam $chlist {
		if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
			if {!$warned} {
				set msg "File '$fnam' Is Not A Soundfile: Continue ?"
				set choice [tk_messageBox -type yesno -message $msg -icon question -parent [lindex $wstk end]]
				if [string match $choice "no"] {
					return
				}
				set warned 1
			}
		} elseif {$pa($fnam,$evv(CHANS)) == 1} {
			lappend fnams $fnam
		}
	}
	if {![info exists fnams]} {
		Inf "There Are No Mono Files In The Chosen Files List"
		return
	}
	set f .fmono
	if [Dlg_Create $f "Convert Mono Files To Stereo" "set pr_fmono 0" -borderwidth $evv(SBDR)] {
		frame $f.1
		frame $f.2
		frame $f.3
		button $f.1.run  -text "Convert" -command "set pr_fmono 1" -highlightbackground [option get . background {}]
		button $f.1.quit -text "Close" -command "set pr_fmono 0" -highlightbackground [option get . background {}]
		pack $f.1.run -side left
		pack $f.1.quit -side right
		label $f.2.lab -text "Name Extension"
		entry $f.2.e -textvariable fmono_ext -width 12
		pack $f.2.lab $f.2.e -side left -padx 2
		set fe_list [Scrolled_Listbox $f.3.list -width 120 -height 10]
		pack $f.3.list -side top  -fill both -expand true
		pack $f.1 $f.2 $f.3 -side top -fill x -expand true
		set fmono_ext "st"
		bind $f <Return> {set pr_fmono 1}
		bind $f <Escape> {set pr_fmono 0}
	}
	set pr_fmono 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition2 .fmono
	My_Grab 0 $f pr_fmono $f.2.e
	while {!$finished} {
		tkwait variable pr_fmono
		if {$pr_fmono} {
			if {[string length $fmono_ext] <= 0} {
				Inf "No File Extension Entered"
				continue
			}
			catch {unset nufnams}
			set OK 1
			foreach fnam $fnams {
				set fext [file extension $fnam]
				set nufnam [file rootname [file tail $fnam]]
				append nufnam "_" $fmono_ext $fext
				if {[file exists $nufnam]} {
					Inf "File $nufnam Already Exists"
					set OK 0
					break
				}
				lappend nufnams $nufnam
			}
			if {!$OK} {
				continue
			}
			Block "Converting files to Stereo"
			set cnt 0
			catch {unset donefiles}
			foreach fnam $fnams nufnam $nufnams {
				set cmd [file join $evv(CDPROGRAM_DIR) housekeep]
				lappend cmd chans 5 $fnam $nufnam
				set spac_error 0
				catch {close $CDPspac}
				if [catch {open "|$cmd"} CDPspac] {
					Inf "Cannot Convert File '$fnam' To Stereo : $CDPspac"
					catch {unset CDPspac}
					continue
				} else {
					fileevent $CDPspac readable WriteFilesExtend
				}
				vwait spacdes_got
				catch {close $CDPspac}
				if {$spac_error} {
					continue
				}
				if {[FileToWkspace $nufnam 0 0 0 0 1] > 0} {
					lappend donefiles $fnam $nufnam
				}
			}
			if [info exists donefiles] {
				DoChoiceBak
				foreach {fnam nufnam} $donefiles {
					set k [LstIndx $fnam $ch]
					set chlist [lreplace $chlist $k $k $nufnam]
				}
				$ch delete 0 end
				set chcnt 0
				foreach fnam $chlist {
					$ch insert end $fnam
					incr chcnt
				}
			}
			UnBlock
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return
}

proc GetFarthest {end line} {
	set line [string trim $line]
	if {[string length $line] > 0} {
		if {![string match ";" [string index $line 0]]} {
			set line [split $line]
			set cnt 0
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				if {$cnt == 1} {
					if {[IsNumeric $item] && ($item > 0.0)} {
						if {$item > $end} {
							return $item
						}
					}
					break
				}
				incr cnt
			}
		}
	}
	return $end
}
		
proc MixMerge {} {
	global ch chlist chcnt pa evv mix_merge_typ pr_mixmerge mixmerge_timestep mix_merge_typ mixmerge_filename
	if {![info exists chlist] || ([llength $chlist] != 2)} {
		Inf "Choose Two Mixfiles"
		return
	}
	set ochan_cnt 0
	set srate_tested 0
	set maxtime -1
	set filecnt 0
	foreach fnam $chlist {
		if {![info exists pa($fnam,$evv(FTYP))] || ![IsAMixfileIncludingMultichan $pa($fnam,$evv(FTYP))]} {
			Inf "Choose Two Mixfiles"
			return
		}
		set is_a_multichan 1
		if {[IsAMixfile $pa($fnam,$evv(FTYP))]} {
			set is_a_multichan 0
		}
		if {[info exists multichan]} {
			if {$multichan !=  $is_a_multichan} {
				Inf "You Cannot Merge Standard Mixfiles With Multichannel Mixfiles"
				return
			}
		} elseif {$is_a_multichan} {
			set multichan 1
		} else {
			set multichan 0
		}
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot Open File '$fnam'"
			return
		}
		set linecnt 0
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			if {[string match ";" [string index $line 0]]} {
				lappend nulines($filecnt) $line
				continue
			}
			set line [split $line]
			set itemcnt 0
			catch {unset nuline}
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				if {$is_a_multichan && ($linecnt == 0)} {
					if {[llength $line] != 1} {
						Inf "Invalid Output Channel Count ($line) In Multichannel Mixfile $fnam"
						return
					} elseif {![IsNumeric $item] || ![regexp {^[0-9]+$} $item] || ($item > 16) || ($item < 2)} {
						Inf "Invalid Output Channel Count ($item) In Multichannel Mixfile $fnam"
						return
					}
					if {$item > $ochan_cnt} {
						set ochan_cnt $item
					}
					break
				}
				switch -- $itemcnt {
					0 {
						if {![file exists $item]} {
							Inf "File '$item' No Longer Exists"
							close $zit
							return
						}
						if {![info exists pa($item,$evv(FTYP))]} {
							Inf "FILE '$item' Is Not On The Workspace"
							close $zit
							return
						}
						if {![info exists srate($filecnt)]} {
							set srate($filecnt) $pa($item,$evv(SRATE))
						}
						if {($filecnt==1) && !$srate_tested} {
							if {$srate(0) != $srate(1)} {
								Inf "Incompatible Sample Rates In The Mixfiles"
								close $zit
								return
							} else {
								set srate_tested 1
							}
						}
					}
					1 {
						if {$filecnt == 0} {
							if {[IsNumeric $item] && ($item >= 0)} {
								set maxtime $item
							}
						}
					}
				}
				lappend nuline $item
				incr itemcnt
			}
			if {$is_a_multichan && ($linecnt == 0)} {
				incr linecnt
				continue
			}
			lappend nulines($filecnt) $nuline
			incr linecnt
		}
		close $zit
		incr filecnt
	}
	set f .mixmerge
	if [Dlg_Create $f "Merge Mixfiles" "set pr_mixmerge 0" -borderwidth $evv(SBDR)] {
		set b [frame $f.b]
		set j [frame $f.j]		
		set k [frame $f.k]		
		set kk [frame $f.kk]		
		set kkk [frame $f.kkk]		
		button $b.kp -text "Merge Mixes" -command "set pr_mixmerge 1" -highlightbackground [option get . background {}]
		button $b.ss -text "Sort" -command "set pr_mixmerge 3" -highlightbackground [option get . background {}]
		button $b.vv -text "Verify" -command "set pr_mixmerge 2" -highlightbackground [option get . background {}]
		label $b.tt -text "See Top panel" -fg $evv(SPECIAL)
		button $b.qu -text "Abandon" -command "set pr_mixmerge 0" -highlightbackground [option get . background {}]
		pack $b.kp $b.ss $b.vv $b.tt -side left -padx 4
		pack $b.qu -side right
		label $f.nu1 -text "\"Sort\" sorts files to time order" -fg $evv(SPECIAL)
		label $f.nu2 -text "AND puts commented lines at foot of file." -fg $evv(SPECIAL)
		label $j.ll -text "New mixfilename"
		entry $j.e -textvariable mixmerge_filename -width 16
		pack $j.ll $j.e -side left -padx 2
		radiobutton $k.0 -variable mix_merge_typ -value 0 -text "Merge mixfiles\nas they are" -command "MixMergeButtonsSet 0"
		radiobutton $k.1 -variable mix_merge_typ -value 1 -text "Timestep between\nmixfile starts" -command "MixMergeButtonsSet 1"
		radiobutton $k.2 -variable mix_merge_typ -value 2 -text "Timestep after\nlast line in mix1" -command "MixMergeButtonsSet 2"
		pack $k.0 $k.1 $k.2 -side left
		label $kk.ll -text "Timestep"
		entry $kk.e -textvariable mixmerge_timestep -width 8
		pack $kk.ll $kk.e -side left -padx 2
		Scrolled_Listbox $kkk.ll1 -width 48 -height 10 -selectmode single
		Scrolled_Listbox $kkk.ll2 -width 48 -height 10 -selectmode single
		pack $kkk.ll1 $kkk.ll2 -side top -fill both -expand true 
		pack $f.b -side top -fill x -expand true -pady 2
		pack $f.j $f.nu1 $f.nu2 $f.k $f.kk $f.kkk -side top -pady 2
		bind $f <Escape> {set pr_mixmerge 0}
	}
	.mixmerge.b.ss config -text "" -bd 0 -state disabled -bg [option get . background {}]
	.mixmerge.b.vv config -text "" -bd 0 -state disabled -bg [option get . background {}]
	.mixmerge.b.tt config -text ""
	.mixmerge.nu1 config -text ""
	.mixmerge.nu2 config -text ""
	set mix_merge_typ -1
	set pr_mixmerge 0
	set mixmerge_filename ""
	set finished 0
	$f.kkk.ll1.list delete 0 end	
	foreach line $nulines(0) {
		$f.kkk.ll1.list insert end $line
	}
	$f.kkk.ll2.list delete 0 end	
	foreach line $nulines(1) {
		$f.kkk.ll2.list insert end $line
	}
	raise $f
	update idletasks
	StandardPosition2 .mixmerge
	My_Grab 0 $f pr_mixmerge $f.kkk.ll1
	while {!$finished} {
		tkwait variable pr_mixmerge
		switch -- $pr_mixmerge {
			1 {
				.mixmerge.b.ss config -text "" -bd 0 -state disabled -bg [option get . background {}]
				.mixmerge.b.vv config -text "" -bd 0 -state disabled -bg [option get . background {}]
				.mixmerge.b.tt config -text ""
				.mixmerge.nu1 config -text ""
				.mixmerge.nu2 config -text ""
				if {[string length $mixmerge_filename] <= 0} {
					Inf "No Output Filename Entered"
					continue
				}
				set mixmerge_filename [string tolower $mixmerge_filename]
				if {![ValidCDPRootname $mixmerge_filename]} {
					continue
				}
				switch -- $mix_merge_typ {
					"-1" {
						Inf "No Mix Merge Type Selected"
						continue
					}
					0 {
						set offset 0.0
					}
					1 {
						if {![IsNumeric $mixmerge_timestep] || ($mixmerge_timestep < 0.0)} {
							Inf "Invalid Timestep Value"
							continue
						}
						set offset $mixmerge_timestep
					}
					2 {
						if {![IsNumeric $mixmerge_timestep]} {
							Inf "Invalid Timestep Value"
							continue
						}
						set offset [expr $maxtime + $mixmerge_timestep]
						if {$offset < 0.0} {
							Inf "Invalid Timestep Value"
							continue
						}
					}
				}
				$f.kkk.ll1.list delete 0 end
				foreach line $nulines(0) {
					$f.kkk.ll1.list insert end $line
				}
				foreach line $nulines(1) {
					if {[string match ";" [string index [lindex $line 0] 0]]} {
						$f.kkk.ll1.list insert end $line
					} else {
						set time [lindex $line 1]
						set time [expr $time + $offset]
						set line [lreplace $line 1 1 $time]
						$f.kkk.ll1.list insert end $line
					}
				}
				.mixmerge.kkk.ll1.list yview moveto 1.0
				.mixmerge.b.ss config -text "Sort" -bd 2 -state normal -bg $evv(EMPH)
				.mixmerge.b.vv config -text "Verify" -bd 2 -state normal -bg $evv(EMPH)
				.mixmerge.b.tt config -text "See Top panel"
				.mixmerge.nu1 config -text "\"Sort\" sorts files to time order"
				.mixmerge.nu2 config -text "AND puts commented lines at foot of file."
			}
			2 {

				if {[string length $mixmerge_filename] <= 0} {
					Inf "No Output Filename Entered"
					continue
				}
				if {![ValidCDPRootname $mixmerge_filename]} {
					continue
				}
				set outfnam $mixmerge_filename
				if {$multichan} {
					set this_ext [GetTextfileExtension mmx]
				} else {
					set this_ext [GetTextfileExtension mix]
				}
				append outfnam $this_ext
				if {[file exists $mixmerge_filename]} {
					Inf "File '$mixmerge_filename' Already Exists: Please Chose Another Filename"
					continue
				}
				if [catch {open $outfnam "w"} zit] {
					Inf "Cannot Open File '$outfnam'"
					continue
				}
				if {$is_a_multichan} {
					puts $zit $ochan_cnt
				}
				foreach line [.mixmerge.kkk.ll1.list get 0 end] {
					puts $zit $line
				}
				close $zit
				FileToWkspace $outfnam 0 0 0 0 1
				MixMMerge $outfnam		;#	ADD MERGED FILE TO MIX MANAGER
				DoChoiceBak
				$ch delete 0 end
				set chcnt 0
				set chlist $outfnam 
				foreach fnam $chlist {
					$ch insert end $fnam
					incr chcnt
				}
				set finished 1
			}
			3 {
				catch {unset comments}
				catch {unset trulines}
				foreach line [$f.kkk.ll1.list get 0 end] {
					if {[string match ";" [string index [lindex $line 0] 0]]} {
						lappend comments $line
					} else {
						lappend trulines $line
					}
				}
				if {[info exists trulines]} {
					set len [llength $trulines]
					set len_less_one [expr $len - 1]
					set n 0
					while {$n < $len_less_one} {
						set nline [lindex $trulines $n]
						set ntime [lindex $nline 1]
						set m [expr $n + 1]
						while {$m < $len} {
							set mline [lindex $trulines $m]
							set mtime [lindex $mline 1]
							if {$mtime < $ntime} {
								set trulines [lreplace $trulines $m $m $nline]
								set trulines [lreplace $trulines $n $n $mline]
								set ntime $mtime
							}
							incr m
						}
						incr n
					}
				}
				if {[info exists comments]} {
					set trulines [concat $trulines $comments]
				}
				$f.kkk.ll1.list delete 0 end
				foreach line $trulines {
					$f.kkk.ll1.list insert end $line
				}
			}
			0 {
				set finished 1
			}
		}						
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return
}

proc MixMergeButtonsSet {val} {
	global mixmerge_timestep
	switch -- $val {
		0 {
			.mixmerge.kk.ll config -text ""		
			set mixmerge_timestep ""
			.mixmerge.kk.e config -bd 0 -state disabled
		}
		1 -
		2 {
			.mixmerge.kk.ll config -text "Timestep"		
			.mixmerge.kk.e config -bd 2 -state normal
		}
	}
}

proc SwapOccurence {} {
	global sndtomix_after sndtomix_t
	switch -- $sndtomix_after {
		0 {
			.sndtomix.kkk.1 config -text "Occurence"
			.sndtomix.kkk.e config -bd 2 -state normal
		}
		1 {
			.sndtomix.kkk.1 config -text ""
			.sndtomix.kkk.e config -bd 2 -state disabled
			set sndtomix_t ""
		}
	}
}

proc IsNotMixText {ftyp} {
	global evv
	if {($ftyp & $evv(IS_NOT_MIX_TEXT)) && ($ftyp != $evv(MIX_MULTI))} {
		return 1
	}
	return 0
}

proc ChanToRoute {chan} {
	switch -- $chan {
		1	{return 1:1}
		2	{return 2:2}
		3	{return 3:3}
		4	{return 4:4}
		5	{return 5:5}
		6	{return 6:6}
		7	{return 7:7}
		8	{return 8:8}
		9	{return 9:9}
		10	{return 10:10}
		11	{return 11:11}
		12	{return 12:12}
		13	{return 13:13}
		14	{return 14:14}
		15	{return 15:15}
		16  {return 16:16}
	}
	return ""
}

proc SampsToTime {t multi} {
	global chlist pa evv
	if {![info exists chlist] || ([llength $chlist] < 2)} {
		return
	}
	set len [llength $chlist]
	if {$multi} {
		set str [.maketextp.b.stan cget -text]
		if {[string match $str "Delete Features"]} {
			UnsetStandardSpecialFeatures 0
		}
		incr len
	}
	set fnam [lindex $chlist 0]
	set srate $pa($fnam,$evv(SRATE))
	set cnt 0
	foreach item [$t get 1.0 end] {
		lappend nuline $item
		incr cnt
		if {$cnt == $len} {
			set time [lindex $nuline 0]
			if {[regexp {^[0-9]+$} $time]} {
				set time [expr $time / double($srate)]
				set nuline [lreplace $nuline 0 0 $time]
			}
			lappend nulines $nuline
			catch {unset nuline}
			set cnt 0
		}
	}
	if [info exists nulines] {
		set linecnt [llength $nulines]
		$t delete 1.0 end
		set lcnt 0
		foreach line $nulines {
			incr lcnt
			set nuline ""
			set cnt 1
			foreach item $line {
				if {$cnt < $len} {
					append nuline $item "  "
				} elseif {$lcnt == $linecnt} {
					append nuline $item
				} else {
					append nuline $item "\n"
				}
				incr cnt
			}
			$t insert end $nuline
		}
	}
}

proc PairsToSwaps {t} {
	global chlist pa evv
	if {![info exists chlist] || ([llength $chlist] != 2)} {
		return
	}
	set fnam [lindex $chlist 0]
	set srate $pa($fnam,$evv(SRATE))
	set sampdur [expr $pa($fnam,$evv(INSAMS)) / $pa($fnam,$evv(CHANS))]

	set fnam2 [lindex $chlist 1]
	set sampdur2 [expr $pa($fnam2,$evv(INSAMS)) / $pa($fnam2,$evv(CHANS))]
	if {$sampdur2 > $sampdur} {
		set sampdur $sampdur2
	}
	set cnt 0
	set str [.maketextp.b.stan cget -text]
	if {[string match $str "Delete Features"]} {
		UnsetStandardSpecialFeatures 0
	}
	foreach item [$t get 1.0 end] {
		if {![regexp {^[0-9]+$} $item] || ($item < 0)} {
			Inf "Not all entries are sampletimes"
			return
		}
		if {$cnt > 0} {
			set step [expr $item - $lastitem]
			if {[IsEven $cnt]} {
				if {$step <= 2000} {
					Inf "Gap between samplepairs too small, at $lastitem"
					return
				}
			} else {
				if {$step <= 0} {
					Inf "Samplepairs not in time order at $item"
					return
				}
			}
		}
		set lastitem $item
		incr cnt
	}
	if {![IsEven $cnt]} {
		Inf "Sampletime entries are not (all) in pairs"
		return
	}
	set cnt 0
	set infil 0
	foreach item [$t get 1.0 end] {
		if {$infil == 0} {
			if {$cnt == 0} {
				if {$item <= 1000} {				
					catch {unset nuline}				
					lappend nuline 0
					lappend nuline 0
					lappend nulines $nuline
				} else {
					catch {unset nuline}				
					lappend nuline 0
					lappend nuline 1
					lappend nulines $nuline
					catch {unset nuline}				
					lappend nuline [expr $item - 1000]
					lappend nuline 1
					lappend nulines $nuline
					catch {unset nuline}				
					lappend nuline $item
					lappend nuline 0
					lappend nulines $nuline
				}
			} else {
				catch {unset nuline}				
				lappend nuline [expr $item - 1000]
				lappend nuline 1
				lappend nulines $nuline
				catch {unset nuline}				
				lappend nuline $item
				lappend nuline 0
				lappend nulines $nuline
			}
		} else {
			catch {unset nuline}				
			lappend nuline $item
			lappend nuline 0
			lappend nulines $nuline
			if {$item >= $sampdur} {
				break
			}
			catch {unset nuline}				
			lappend nuline [expr $item + 1000]
			lappend nuline 1
			lappend nulines $nuline
		}
		set infil [expr !$infil]			
		incr cnt
	}
	set step [expr $sampdur - $item]

	set linecnt [llength $nulines]
	set lcnt 0
	$t delete 1.0 end
	foreach line $nulines {
		incr lcnt
		set samptime [lindex $line 0]
		set time [expr double($samptime) / double($srate)]
		set nuline $time
		append nuline "  " [lindex $line 1]
		if {($lcnt != $linecnt) || ($step >= 0)} {		;#		IF TRUE LAST LINE , NO NEWLINE
			append nuline "\n"
		}
		$t insert end $nuline
	}
	if {$step > 1000} {
		set samptime [expr $samptime + 1000]
		set time [expr double($samptime) / double($srate)]
		set nuline $time
		append  nuline "  " 1 "\n"
		$t insert end $nuline
		set time [expr $pa($fnam,$evv(DUR)) + 1.0]
		set nuline $time
		append  nuline "  " 1
		$t insert end $nuline
	} elseif {$step > 0} {
		set time [expr $pa($fnam,$evv(DUR)) + 1.0]
		set nuline $time
		append  nuline "  " 0
		$t insert end $nuline
	}
}

#------ Move frq by oct in brkpnt file

proc MoveValByOct {src up} {
	global ref pr_refs

	set str [$src get "insert linestart" "insert lineend"]
	set str [split [string trim $str]]
	set cnt 0
	foreach item $str {
		if {[string length $item] <= 0} {
			continue
		}
		lappend nulist $item
		incr cnt
	}
	if {$cnt != 2} {
		return
	}
	set str [lindex $nulist 1]
	if {![IsNumeric $str]} {
		return
	}
	if {$up} {
		set str [expr $str * 2.0]
	} else {
		set str [expr $str / 2.0]
	}
	set nulist [lreplace $nulist 1 1 $str]
	$src delete "insert linestart" "insert lineend"
	$src insert insert $nulist
}

proc SpaceDesignHelp {} {
	append msg "STEREO INTO MONO and MONO INTO STEREO\n"
	append msg "\n"
	append msg "describe trajectory collapsing sound from stereo image to\n"
	append msg "mono stream located in stereo space (or vice versa).\n"
	append msg "Start Time, End Time, End (Start) Position,\n"
	append msg " define end (start) of the transition.\n"
	append msg "\n"
	append msg "ROTATE\n"
	append msg "\n"
	append msg "describes trajectory rotating in space.\n"
	append msg "No doppler shift used, so image is of a small space\n"
	append msg "(possibly magnified) close to listener.\n"
	append msg "1) Start & End Time & Position define start & end of rotation.\n"
	append msg "   (sound assumed stationary outside these time limits).\n"
	append msg "2) Clockwise/Anticlockwise: define direction of rotation.\n"
	append msg "3) Times At Edges Of Space: textfile listing times where image\n"
	append msg "   reaches leftmost and rightmost positions on each rotation.\n"
	append msg "4) Rotation Width: 1 = full stereo, 0 = no spread (no rotation)\n"
	append msg "5) Proportion Of Time At Edges Of Space: (time spent lingering\n"
	append msg "   at leftmost and rightmost positions).\n"
	append msg "6) Ratio Of Front Level To Rear Level: max loudness ratio\n"
	append msg "   between 'frontmost' and 'rearmost' position.\n"
	append msg "7) Distance Filter: filters off high freqs when rotating sound\n"
	append msg "   'distant' from front.\n"
	append msg "8) Maxlevel Leads Centre Position: Signal may reach max (min)\n
	append msg "   level before reaching centre position of rotation.\n"
	append msg "   0 = no difference, 1 = max consistent with rotation-image.\n"
	append msg "9) Ratio Time At Rear To Time At Front: defines apparent size\n"
	append msg "   of rotation space. Larger ratio makes space deeper.\n"
	append msg "10) Overall Attenuation: May be necessary to attenuate signal,\n"
	append msg "   if source level very high.\n"
	append msg "\n"
	append msg "All modes generate spatial-data textfiles and soundfile output\n"
	append msg "on workspace. If spatial data files already exist, you're asked\m"
	append msg "to confirm if you want to overwrite them with new data.\n"
	Inf $msg
}

proc SampsToBrkTime {t} {
	global chlist pa evv
	if {![info exists chlist] || ([llength $chlist] < 1)} {
		return
	}
	set fnam [lindex $chlist 0]
	set srate $pa($fnam,$evv(SRATE))
	set str [.maketextp.b.stan cget -text]
	if {[string match $str "Delete Features"]} {
		UnsetStandardSpecialFeatures 0
	}
	set cnt 0
	foreach item [$t get 1.0 end] {
		if {[IsEven $cnt]} {
			if {![regexp {^[0-9]+$} $item]} {
				return
			}
			lappend nuline [expr $item / double($srate)]
		} else {
			lappend nuline $item
			lappend nulines $nuline
			unset nuline
		}
		incr cnt
	}
	if [info exists nulines] {
		set linecnt [llength $nulines]
		$t delete 1.0 end
		set lcnt 0
		foreach line $nulines {
			incr lcnt
			set nuline ""
			set cnt 0
			foreach item $line {
				if {[IsEven $cnt]} {
					append nuline $item "  "
				} elseif {$lcnt == $linecnt} {
					append nuline $item
				} else {
					append nuline $item "\n"
				}
				incr cnt
			}
			$t insert end $nuline
		}
	}
}

proc AdvanceNameIndex {up name atstart} {
	global sndtomixname q_savename gname z_savename qikcopy_name renamefile col_tabname textfilename textfilenamep
	global envscale_fnam degrade polyf

	upvar $name thisname
	if {[string length $thisname] <= 0} {
		return
	}
	set ext [file extension $thisname]
	set fnam [file rootname $thisname]
	if {![ValidCDPRootname $fnam]} {
		return
	}
	if {$atstart} {
		set len [string length $fnam]
		set k 0
		while {$k < $len} {
			if {[info exists startnum]} {
				if {[regexp {[0-9]+} [string index $fnam $k]]} {
					set endnum $k
				} else {
					break
				}
			} else {
				if {[regexp {[0-9]+} [string index $fnam $k]]} {
					set startnum $k
					set endnum $k
				}
			}
			incr k
		}
	} else {
		set len [string length $fnam]
		set k $len 
		incr k -1
		while {$k >= 0} {
			if {[info exists startnum]} {
				if {[regexp {[0-9]+} [string index $fnam $k]]} {
					set startnum $k
				} else {
					break
				}
			} else {
				if {[regexp {[0-9]+} [string index $fnam $k]]} {
					set startnum $k
					set endnum $k
				}
			}
			incr k -1
		}
	}
	if {![info exists startnum]} {
		return
	}
	set indx [string range $fnam $startnum $endnum]
 #ELIMINATE LEADING ZEROS
	set k [string length $indx]
	if {$k > 1} {
		set leadingzeros 0
		incr k -1
		set j 0
		while {$j < $k} {
			if {[string match [string index $indx $j] "0"]} {
				incr leadingzeros
			} else {
				break
			}
			incr j
		}
		if {$leadingzeros > 0} {
			incr startnum $leadingzeros
			set indx [string range $fnam $startnum $endnum]
		}
	}	 

	set k $startnum
	incr k -1
	if {$k >= 0} {
		set basfnam [string range $fnam 0 $k]
	}
	set k $endnum
	incr k
	if {$k < $len} {
		set endfnam [string range $fnam $k end]
	}
	if {$up} {
		incr indx
	} else {
		if {$indx == 0} {
			return
		}
		incr indx -1
	}
	set fnam ""
	if {[info exists basfnam]} {
		append fnam $basfnam
	}
	append fnam $indx
	if {[info exists endfnam]} {
		append fnam $endfnam
	}
	append fnam $ext
	set $name $fnam
	if {$atstart} {
		set moveloc 0.0
	} else {
		set moveloc 1.0
	}
	switch -- $name {
		"sndtomixname" {
			.sndtomix.k.e xview moveto $moveloc
		}
		"q_savename" {
			.nufnam.name.name xview moveto $moveloc
		}
		"z_savename" {
			.keeplist.name.name xview moveto $moveloc
		}
		"qikcopy_name" {
			.qikcopy.2.e xview moveto $moveloc
		}
		"gname" {
			.generic.name.e xview moveto $moveloc
		}
		"degrade(fnam)" {
			.degrade.0.n xview moveto $moveloc
		}
		"polyf(fnam)" {
			.polyf.0.n xview moveto $moveloc
		}
	}
}

proc GetSndToMixTime {} {
	global sndtomix_t
	set i [.sndtomix.j.ll2.list curselection]
	if {$i < 0} {
		return
	}
	set line [.sndtomix.j.ll2.list get $i]
	set line [string trim $line]
	if {([string length $line] <= 0) || ([string match [string index $line 0] ";"])} {
		return
	}
	set line [split $line]
	foreach item $line {
		set item [string trim $item]
		if {[string length $item] > 0} {
			lappend nuline $item
		}
	}
	if {![info exists nuline] || ([llength $nuline] < 2)} {
		return
	}
	set val [lindex $nuline 1]
	if {![IsNumeric $val]} {
		return
	}
	set sndtomix_t $val
}

proc CreateRecentTextfileNames {entry} {
	global pr_recnam wl evv

	foreach fnam [$wl get 0 end] {
		if {[string match $fnam [file tail $fnam]] && [IsATextfileExtension [file extension $fnam]]} {
			lappend txtnames [file rootname $fnam]
		}
	}
	if {![info exists txtnames]} {
		Inf "No Textfiles In Workspace Directory"
	}
	set f .recnam
	if [Dlg_Create $f "Recent Textfile Names" "set pr_recnam 1" -borderwidth $evv(BBDR)] {
		label $f.lab -text "Click on name to select"
		button $f.quit -text "Close" -command "set pr_recnam 0" -highlightbackground [option get . background {}]
		Scrolled_Listbox $f.names -height $evv(NSTORLEN) -selectmode single -width 40
		pack $f.lab $f.quit $f.names -side top -pady 2
		bind .recnam.names.list <ButtonRelease-1> "NameListChoose .recnam.names.list $entry; set pr_recnam 1"
		bind $f <Return> {set pr_recnam 0}
		bind $f <Escape> {set pr_recnam 0}
		bind $f <Key-space> {set pr_recnam 0}
	}
	.recnam.names.list delete 0 end
	foreach nname $txtnames {	;#	Post recent names
		.recnam.names.list insert end $nname
	}					
	set pr_recnam 0
	raise $f
	My_Grab 0 $f pr_recnam .recnam.names.list
	tkwait variable pr_recnam
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc CreateSpaceText {} {
	global fromspace sd
	if {![info exists sd(starttime)] || ([string length [string trim $sd(starttime)]] <= 0)} {
		Inf "Enter The Rotation Starttime Before You Create This File"
		return 0
	} elseif {![IsNumeric $sd(starttime)] || ($sd(starttime) < 0.0)} {
		Inf "Invalid Rotation Starttime Entered"
		return 0
	}
	if {![info exists sd(endtime)] || ([string length [string trim $sd(endtime)]] <= 0)} {
		Inf "Enter The Rotation Endtime Before You Create This File"
		return 0
	} elseif {![IsNumeric $sd(endtime)] || ($sd(endtime) < 0.0)} {
		Inf "Invalid Rotation Endtime Entered"
		return 0
	}
	set fromspace 1
	Dlg_MakeTextfile 0 0 
	set fromspace 0
}

proc TestSpacePoints {t} {
	global sd
	set vals [$t get 1.0 end]
	set vals "[split $vals]"				;#	split line into single-space separated items
	foreach item $vals {
		set item [string trim $item]
		if {[string length $item] > 0} {
			lappend words $item
		}
	}
	set wordcnt [llength $words]
	if {$wordcnt <= 0} {
		Inf "No Values In Table."
		return 0
	}
	set cnt 0
	foreach val $words {
		if {$cnt == 0} {
			if {$val < $sd(starttime)} {
				Inf "First Time '$val' Falls Before The Rotation Starttime '$sd(starttime)'"
				return 0
			}
			set lasttime $val
		} elseif {$val <= $lasttime} {
			Inf "Times Do Not Advance At '$val $lasttime'"
			return 0
		}
		if {$val > $sd(endtime)} {
			Inf "Time '$val' Falls After The Rotation Endtime '$sd(endtime)'"
			return 0
		}
		incr cnt
	}
	return 1
}

proc HasBrkpntStructure {t istextlisting} {
	set lasttime -1
	set words {}
	if {$istextlisting}  {
		set vals [$t get 1.0 end]
		set lines "[split $vals \n]"
	} else {
		foreach line [$t get 0 end] {
			lappend lines $line
		}
	}
	foreach line $lines {
		set vals "[split $line]"				;#	split line into single-space separated items
		set thesewords {}
		foreach item $vals {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend thesewords $item
			}
		}
		set wordcnt [llength $thesewords]
		if {$wordcnt <= 0} {
			continue
		}
		if {$wordcnt != 2 } {
			return 0
		}
		set words [concat $words $thesewords]
	}
	foreach {time val} $words {
		if {![IsNumeric $time]} {
			return 0
		} elseif {![IsNumeric $val]} {
			return 0
		}
		if {$time < 0.0} {
			return 0
		}
		if {($lasttime < 0) && ($time != 0.0)} {
			return 0
		}
		if {$time <= $lasttime} {
			return 0
		}
		set lasttime $time
	}
	return 1
}

proc SecOrSampDur {fnam} {
	global pprg mmod evv pa

	switch -regexp -- $pprg \
		^$evv(EDIT_CUTMANY)$	- \
		^$evv(EDIT_EXCISEMANY)$ - \
		^$evv(INSERTSIL_MANY)$	- \
		^$evv(SYLLABS)$ {
			switch -- $mmod {
				1 { set dur $pa($fnam,$evv(DUR)) }
				2 { set dur $pa($fnam,$evv(INSAMS)) }
				3 { set dur [expr $pa($fnam,$evv(INSAMS)) / $pa($fnam,$evv(CHANS))]}
			}
		} \
		^$evv(MANY_ZCUTS)$ {
			switch -- $mmod {
				1 { set dur $pa($fnam,$evv(DUR)) }
				2 { set dur $pa($fnam,$evv(INSAMS)) }
			}
		} \
		default {
			set dur $pa($fnam,$evv(DUR))
		}
	if {![info exists dur]} {
		set dur "unknown"
	}
	return $dur
}

proc IsMultiEditType {prog} {
	global evv mmod pseudoprog

	switch -regexp -- $prog \
		^$evv(MANY_ZCUTS)$		- \
		^$evv(EDIT_CUTMANY)$	- \
		^$evv(SUPPRESS)$	- \
		^$evv(EDIT_EXCISEMANY)$	- \
		^$evv(INSERTSIL_MANY)$ - \
		^$evv(MANYSIL)$ - \
		^$evv(REPEATER)$ - \
		^$evv(TWEET)$ - \
		^$evv(FOFEX_EX)$ {
			return 1
		 } \
		^$evv(TSTRETCH)$ {
			if {[info exists pseudoprog] && ($pseudoprog == $evv(ELASTIC))} {
				return 1
			}
		 } \
		^$evv(ISOLATE)$ {
			switch -- $mmod {
				1 -
				2 {
					return 1
				}
			}
		 }

	return 0
}

proc IsMultiEditPitchfileType {prog} {
	global evv

	switch -regexp -- $prog \
		^$evv(P_INSERT)$ - \
		^$evv(P_SINSERT)$ {
			return 1
		 }

	return 0
}

proc IsTimesListType {prog mmod} {
	global evv

	switch -regexp -- $prog \
		^$evv(SYLLABS)$ {
			return 1
		 } \
		^$evv(VERGES)$ {
			return 1
		 } \
		^$evv(DISTMARK)$ {
			return 1
		 } \
		^$evv(STUTTER)$ {
			return 1
		 }

	return 0
}

proc IsOtherTimesListType {prog mmod} {
	global evv

	switch -regexp -- $prog \
		^$evv(PACKET)$ {
			return 1
		 } \
		^$evv(RETIME)$ {
			if {$mmod == 1} {
				return 1
			}
		 } \
		^$evv(SHRINK)$ {
			if {$mmod == 6} {
				return 1
			}
		 } \
		^$evv(SCRUNCH)$ {
			if {(($mmod > 3) && ($mmod < 8)) || ($mmod > 9)} { 
				return 1
			}
		 } \
		^$evv(MOTOR)$ {
			if {[expr $mmod % 3] == 1} {
				return 1
			}
		 } \
		^$evv(CASCADE)$ {
			if {$mmod >= 5} {
				return 1
			}
		 }

	return 0
}

proc IsTimesListTypeWithMultipleInfiles {prog mmod} {
	global evv

	switch -regexp -- $prog \
		^$evv(TWIXT)$ {
			if {($mmod >= 1) && ($mmod <= 4)} {
				return 1
			}
		}

	return 0
}

proc IsBrkpntDataWithSpecialProperties {prog pcnt} {
	global evv

	switch -regexp -- $prog \
		^$evv(FREEZE2)$ - \
		^$evv(VFILT)$ {
			if {$pcnt == 0} {
				return 1
			}
		}

	return 0
}

proc IsTimesListTypeWithExtraCharacters {prog pcnt} {
	global evv

	switch -regexp -- $prog \
		^$evv(FREEZE)$ {
			if {$pcnt == 0} {
				return 1
			}
		}

	return 0
}

proc IsTimedDataFile {prog pcnt} {
	global evv

	switch -regexp -- $prog \
		^$evv(SYNTHESIZER)$ - \
		^$evv(FLTBANKV)$ - \
		^$evv(SYNFILT)$ {
			if {$pcnt == 0} {
				return 1
			}
		}

	return 0
}

proc IsZigZag {prog mmod pcnt} {
	global evv

	switch -regexp -- $prog \
		^$evv(ZIGZAG)$ - \
		^$evv(MCHZIG)$ {
			if {$mmod == 2 && $pcnt == 0} {
				return 1
			}
		}

	return 0
}

proc SetUpSndViewEdit {typ pcnt} {
	global pseudoprog chlist pa pprg mmod evv
	global prm

	if {![info exists chlist] || ([llength $chlist] <= 0)} {
		return
	}
	set fnam [lindex $chlist 0]
	if {$pa($fnam,$evv(FTYP)) == $evv(SNDFILE)} {
		if {$typ == "brk"} {
			if {[EstablishAnyNecessarySoundViewDummyFile $fnam $pcnt]} {
				catch {.maketext.b.find config -text "Snd View" -command "SnackDisplay $evv(SN_BRKPNTPAIRS) .maketext.k.t $evv(TIME_OUT) $pcnt" -bd 2 -state normal -bg $evv(SNCOLOR)}
			}
		} elseif [IsTimesListType $pprg $mmod] {
			switch -- $mmod {
				0 -
				1 {
					catch {.maketext.b.find config -text "Snd View" -command "SnackDisplay $evv(SN_TIMESLIST) .maketext.k.t $evv(TIME_OUT) $pcnt" -bd 2 -state normal -bg $evv(SNCOLOR)}
				}
				2 {
					catch {.maketext.b.find config -text "Snd View" -command "SnackDisplay $evv(SN_TIMESLIST) .maketext.k.t $evv(SMPS_OUT) $pcnt" -bd 2 -state normal -bg $evv(SNCOLOR)}
				}
				3 {
					catch {.maketext.b.find config -text "Snd View" -command "SnackDisplay $evv(SN_TIMESLIST) .maketext.k.t $evv(GRPS_OUT) $pcnt" -bd 2 -state normal -bg $evv(SNCOLOR)}
				}
			}
		} elseif [IsOtherTimesListType $pprg $mmod] {
			catch {.maketext.b.find config -text "Snd View" -command "SnackDisplay $evv(SN_TIMESLIST) .maketext.k.t $evv(TIME_OUT) $pcnt" -bd 2 -state normal -bg $evv(SNCOLOR)}
		} elseif [IsMultiEditType $pprg] {
			if {[info exists pseudoprog] && (($pseudoprog == $evv(SLICE)) || ($pseudoprog == $evv(SNIP)))} {
				.maketext.b.find config -text "" -bd 0 -state disabled -bg [option get . background {}]
				catch {.maketext.b.find config -command {}}
				return
			} elseif {$pprg == $evv(FOFEX_EX)} {
				if {$mmod == 1} {
					catch {.maketext.b.find config -text "Snd View" -command "SnackDisplay $evv(SN_TIMEPAIRS) .maketext.k.t $evv(GRPS_OUT) $pcnt" -bd 2 -state normal -bg $evv(SNCOLOR)}
				}
			} elseif {$pprg == $evv(TWEET)} {
				catch {.maketext.b.find config -text "Snd View" -command "SnackDisplay $evv(SN_TIMEPAIRS) .maketext.k.t $evv(GRPS_OUT) $pcnt" -bd 2 -state normal -bg $evv(SNCOLOR)}
			} elseif {$pprg == $evv(SUPPRESS)} {
				catch {.maketext.b.find config -text "Snd View" -command "SnackDisplay $evv(SN_TIMEPAIRS) .maketext.k.t $evv(TIME_OUT) $pcnt" -bd 2 -state normal -bg $evv(SNCOLOR)}
			} else {
				switch -- $mmod {
					1 {
						catch {.maketext.b.find config -text "Snd View" -command "SnackDisplay $evv(SN_TIMEPAIRS) .maketext.k.t $evv(TIME_OUT) $pcnt" -bd 2 -state normal -bg $evv(SNCOLOR)}
					}
					2 {
						catch {.maketext.b.find config -text "Snd View" -command "SnackDisplay $evv(SN_TIMEPAIRS) .maketext.k.t $evv(SMPS_OUT) $pcnt" -bd 2 -state normal -bg $evv(SNCOLOR)}
					}
					3 {
						catch {.maketext.b.find config -text "Snd View" -command "SnackDisplay $evv(SN_TIMEPAIRS) .maketext.k.t $evv(GRPS_OUT) $pcnt" -bd 2 -state normal -bg $evv(SNCOLOR)}
					}
				}
			}
		} elseif [IsTimesListTypeWithMultipleInfiles $pprg $mmod] {
			catch {.maketext.b.find config -text "Snd View" -command "SnackDisplay $evv(SN_MULTIFILES) .maketext.k.t $evv(TIME_OUT) $pcnt" -bd 2 -state normal -bg $evv(SNCOLOR)}
		} elseif [IsTimedDataFile $pprg $pcnt] {
			catch {.maketext.b.find config -text "Snd View" -command "SnackDisplay $evv(SN_MOVETIME_ONLY2) .maketext.k.t $evv(TIME_OUT) 0" -bd 2 -state normal -bg $evv(SNCOLOR)}
		}
	} else {
		if [IsBrkpntDataWithSpecialProperties $pprg $pcnt] {
			catch {.maketext.b.find config -text "Snd View" -command "SnackDisplay $evv(SN_MOVETIME_ONLY) .maketext.k.t $evv(TIME_OUT) $pcnt" -bd 2 -state normal -bg $evv(SNCOLOR)}
		}
	}
}

#----------- Find the sound source of anal or pitch file

proc SrcFileExists {} {
	global chlist src pa evv
	if {![info exists chlist] || ([llength $chlist] <= 0)} {
		return 0
	}
	set fnam [lindex $chlist 0]
	if [info exists src($fnam)] {
		foreach srcfile $src($fnam) {
			if [string match $evv(DELMARK)* $srcfile] {
				continue
			} elseif {![info exists pa($srcfile,$evv(FTYP))]} {
				continue
			} elseif {$pa($srcfile,$evv(FTYP)) != $evv(SNDFILE)} {
				continue
			} else {
				return 1
			}
		}
	}
	return 0
}


proc CreateDummyFile {dur} {
	global sv_dummy sv_dummyname CDPzrun prg_dunz evv pa chlist
	set sv_dummyname cdptest000.wav
	if {[file exists $sv_dummyname]} {
		catch {file delete $sv_dummyname}
	}
	catch {unset sv_dummy}
	set srate $pa([lindex $chlist 0],$evv(SRATE))
	set cmd [file join $evv(CDPROGRAM_DIR) synth]
	lappend cmd wave 1 $sv_dummyname $srate 1 $dur 440 -a0.2 -t256
	set prg_dunz 0
	if [catch {open "|$cmd"} CDPzrun] {
		return 0
	} else {
		fileevent $CDPzrun readable "BogSynth"
	}
	vwait prg_dunz
	if {[file exists $sv_dummyname]} {
		if {[DoParse $sv_dummyname 0 0 0] <= 0} {
			catch {file delete $sv_dummyname}
			PurgePropfilesList $sv_dummyname
			return 0
		}
		set sv_dummy 1
		return 1
	}
	return 0
}


proc BogSynth {} {
	global CDPzrun prg_dunz evv

	if [eof $CDPzrun] {
		set prg_dunz 1
		catch {close $CDPzrun}
		return
	} else {
		gets $CDPzrun line
		set line [string trim $line]
		if {[string length $line] <= 0} {
			return
		} elseif [string match END:* $line] {
			set prg_dunz 1
			catch {close $CDPzrun}
			return
		}
	}
	update idletasks
}

#--- In some cases we need to draw breakpont data over an output duration, rather than over the input file ....

proc EstablishAnyNecessarySoundViewDummyFile {fnam pcnt} {
	global pprg evv prm mmod pa

	switch -regexp -- $pprg \
		^$evv(SIMPLE_TEX)$	- \
		^$evv(TEX_MCHAN)$	- \
		^$evv(GROUPS)$		- \
		^$evv(DECORATED)$	- \
		^$evv(PREDECOR)$	- \
		^$evv(POSTDECOR)$	- \
		^$evv(ORNATE)$		- \
		^$evv(PREORNATE)$	- \
		^$evv(POSTORNATE)$	- \
		^$evv(MOTIFS)$		- \
		^$evv(MOTIFSIN)$	- \
		^$evv(TIMED)$		- \
		^$evv(TGROUPS)$		- \
		^$evv(TMOTIFS)$		- \
		^$evv(TMOTIFSIN)$ {
			if {![IsNumeric $prm(1)] || ($prm(1) <= 0)} {
				Inf "No Sound Duration Specified"
				return 0
			} elseif {![CreateDummyFile $prm(1)]} {
				return 0
			}
		} \
		^$evv(NEWTEX)$ {
			switch -- $mmod {
				1 {
					if {![IsNumeric $prm(1)] || ($prm(1) <= 0)} {
						Inf "No Sound Duration Specified"
						return 0
					} elseif {![CreateDummyFile $prm(1)]} {
						return 0
					}
				}
				default {
					if {![IsNumeric $prm(0)] || ($prm(0) <= 0)} {
						Inf "No Sound Duration Specified"
						return 0
					} elseif {![CreateDummyFile $prm(0)]} {
						return 0
					}
				}
			}
		} \
		^$evv(DRUNKWALK)$ {
			if {$pcnt == $evv(DRNK_LOCUS)} {
				return 0		;#	locus specification needs to see the input file
			}
			if {![IsNumeric $prm(0)] || ($prm(0) <= 0)} {
				Inf "No Sound Duration Specified"
				return 0
			} elseif {![CreateDummyFile $prm(0)]} {
				return 0
			}
		} \
		^$evv(ITERATE)$ - \
		^$evv(ITERLINE)$	- \
		^$evv(ITERLINEF)$	- \
		^$evv(ITERATE_EXTEND)$ {
			return 0	;#	duration of output depends on delay, which can be a brkpnt file, so duration of dummy file 
						;#	(on which to draw brkpnt vals) cannot be determined
		} \
		default {
			;#	ALL OTHER PROCESSES DISPLAY THE SOUNDFILE BEING PROCESSED
		}

	return 1
}

#---- Get the different items from list where some items are duplicated

proc GetIndependentItems {inlist} {
	set outlist {}
	foreach item $inlist {
		if {[lsearch $outlist $item] < 0} {
			lappend outlist $item
		}
	}
	return $outlist
}

#---- Get realtimes from an Ideals datafile, and generate times intermediate between these

proc GetIntermediateIdealRealtimes {} {
	global prm
	set fnam $prm(0)
	if {([string length $fnam] <= 0) || ![file exists $fnam]} {
		Inf "No (Valid) Retime Datfile Entered On Parameters Page"
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open Retime Datfile"
		return
	}
	set  cnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {$cnt >= 1} {
			catch {unset nuline}
			set line [split $line]
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] > 0} {
					lappend nuline $item
				}
			}
			lappend outvals [lindex $nuline 0]
		}
		incr cnt
	}
	close $zit
	if {![info exists outvals]} {
		Inf "No Data Found In Retime Data File"
		return
	}
	set bothvals 0
	if {[IsNumeric $prm(2)]} {
		set bothvals 1
	}
	if {$bothvals} {
		lappend nuoutvals [list 0.0 $prm(2)]
	} else {
		set nuoutvals 0.0
	}
	set firstoutval [lindex $outvals 0]
	foreach val [lrange $outvals 1 end] {
		set inter [expr ($val - $firstoutval) / 3.0]
	if {$bothvals} {
			lappend nuoutvals [list [expr $firstoutval + $inter] $prm(2)]
			lappend nuoutvals [list [expr $firstoutval + (2.0 * $inter)] $prm(2)]
		} else {
			lappend nuoutvals [expr $firstoutval + $inter]
			lappend nuoutvals [expr $firstoutval + (2.0 * $inter)]
		}
		set firstoutval $val
	}
	if {$bothvals} {
		lappend nuoutvals [list [expr $val + 10.0] $prm(2)]
	} else {
		lappend nuoutvals [expr $val + 10.0]
	}

	.maketextp.k.t delete 1.0 end
	set line "(Each pair of times brackets a peak in the idealtimes list : Delete this line before saving data)"
	.maketextp.k.t insert end "$line\n"
	foreach val $nuoutvals {
		.maketextp.k.t insert end "$val   \n"
	}
	.maketextp.b.stan config -text "Delete Explainer" -command "IdealFlip"
}

proc IdealFlip {} {
	.maketextp.k.t delete 1.0 2.0
	.maketextp.b.stan config -text "From Ideal Times" -command GetIntermediateIdealRealtimes
}

proc GrafDisplayBrkfile {wksp possible} {
	global sfffl wl
	if {$wksp} {
		set ilist [$wl curselection]
		if {![info exists ilist] || ([llength $ilist] <= 0) || ([lindex $ilist 0] == -1)} {
			Inf "No File Selected"
			return
		}
		if {[llength $ilist] == 1} {
			set fnam [$wl get [lindex $ilist 0]]
		} else {
			Read_Brkfile
			return
		}
	} else {
		set ilist [$sfffl curselection]
		if {![info exists ilist] || ([llength $ilist] <= 0) || ([lindex $ilist 0] == -1)} {
			Inf "No File Selected"
			return
		}
		set fnam [$sfffl get [lindex $ilist 0]]
	}
	if {![DisplayBrkfile $fnam $possible]} {
		DisplayTextfile $fnam
	}
}

#------ Grab other appropriate files to workspace to add to files-listing

proc OtherPossibleFiles {type gcnt pcnt} {
	global wstk pa evv pr_alternativefiles altsellist altdirlist alternativedir readonlybg readonlyfg alternlist wl sfffb brk sfffl

	set f .alternativefiles
	if [Dlg_Create $f "GET OTHER FILES" "set pr_alternativefiles 0" -borderwidth 2 -width 84] {
		frame $f.0
		button $f.0.qu -text "Abandon" -command "set pr_alternativefiles 0" -highlightbackground [option get . background {}]
		button $f.0.ss -text "Select Hilited" -command "set pr_alternativefiles 2" -highlightbackground [option get . background {}]
		button $f.0.dd -text "Deselect Hilited" -command "set pr_alternativefiles 3" -highlightbackground [option get . background {}]
		button $f.0.pp -text "Try these files" -command "set pr_alternativefiles 1" -highlightbackground [option get . background {}]
		pack $f.0.pp $f.0.dd -side left -padx 40
		pack $f.0.qu $f.0.ss -side right -padx 40
		pack  $f.0 -side top -fill x -expand true
		frame $f.1
		frame $f.1.1 
		label $f.1.1.tit -text "Files in Directory " -fg $evv(SPECIAL)
		frame $f.1.1.dir
		entry $f.1.1.dir.e -textvariable alternativedir -width 40 -state readonly -fg $readonlyfg -readonlybackground $readonlybg
		button $f.1.1.dir.b -text "Find Dir" -command {ListChosenAlternativeDir} -highlightbackground [option get . background {}]
		pack $f.1.1.dir.b $f.1.1.dir.e -side left
		set altdirlist [Scrolled_Listbox $f.1.1.ll -width 48 -height 20 -selectmode extended]
		pack $f.1.1.tit $f.1.1.dir $f.1.1.ll -side top -pady 2
		frame $f.1.2
		label $f.1.2.tit -text "Selected Files" -fg $evv(SPECIAL)
		frame $f.1.2.dum
		label $f.1.2.dum.dum -text "" -width 40
		pack $f.1.2.dum.dum -side left
		set altsellist [Scrolled_Listbox $f.1.2.ll -width 48 -height 20 -selectmode extended]
		pack $f.1.2.tit $f.1.2.dum $f.1.2.ll -side top -pady 2
		pack $f.1.1 $f.1.2 -side right
		pack $f.1 -side top
		wm resizable $f 1 1
		bind $f <Return> {set pr_alternativefiles 1}
		bind $f <Escape> {set pr_alternativefiles 0}
	}
	catch {unset alternlist}
	set alternativedir ""
	$altdirlist delete 0 end
	$altsellist delete 0 end
	set pr_alternativefiles 0
	update idletasks
	raise $f
	update idletasks
	My_Grab 0 $f pr_alternativefiles $f.1.1.dir.e
	update idletasks
	set finished 0
	while {!$finished} {
		tkwait variable pr_alternativefiles
		switch -- $pr_alternativefiles {
			0 {
				catch {unset alternlist} 
				set finished 1
			}
			1 {
				catch {unset alternlist} 
				if {[$altsellist index end] == 0} {
					foreach fnam [$altdirlist get 0 end] {
						lappend alternlist $fnam
					}
				} else {
					foreach fnam [$altsellist get 0 end] {
						lappend alternlist $fnam
					}
				}
				set finished 1
			}
			2 {
				set ilist [$altdirlist curselection]
				if {![info exists ilist] || ([llength $ilist] <= 0) || (([llength $ilist] == 1) && ([lindex $ilist 0] == -1))} {
					Inf "No File Selected In Directory List"
					unset ilist
					continue
				}
				foreach i $ilist {
					set fnam [$altdirlist get $i]
					if {[LstIndx $fnam $altsellist] < 0} {
						$altsellist insert end $fnam
					}
				}
				unset ilist
			}
			3 {
				set ilist [$altsellist curselection]
				if {![info exists ilist] || ([llength $ilist] <= 0) || (([llength $ilist] == 1) && ([lindex $ilist 0] == -1))} {
					Inf "No File Chosen For Deletion In Selected Files List"
					unset ilist
					continue
				}
				set msg "Are You Sure You Want To De-Select The File(s) ??"
				set choice [tk_messageBox -type yesno -message $msg -icon question -parent [lindex $wstk end]]
				if [string match $choice "no"] {
					unset ilist
					continue
				}
				set ilist [ReverseList $ilist]
				foreach i $ilist {
					$altsellist delete $i
				}
				unset ilist
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	if {![info exists alternlist] || ([llength $alternlist] <= 0)} {
		return
	}
	Block "PARSING FILES"
	foreach fnam $alternlist {
		if {[DoParse $fnam 0 0 0] <= 0} {
			lappend badfiles $fnam
		} else {
			lappend goodfiles $fnam
		}
	}
	if {![info exists goodfiles]} {
		Inf "None Of These Files Are Workable Soundloom Files"
		UnBlock
		return
	} elseif {[info exists badfiles]} {
		set msg "The Following Files Are Not Workable Soundloom Files\n"
		set cnt 0
		foreach fnam $badfiles {
			append msg $fnam "\n"
			incr cnt
			if {$cnt >= 20} {
				append msg "AND MORE\n"
				break
			}
		}
		Inf $msg
	}
	wm title .blocker "PLEASE WAIT:     TESTING FILES"
	set files_found 0
	catch {unset badrange}
	catch {unset badfiles}
	foreach fnam $goodfiles {
		set test [TestPossibleFile $fnam $type $pcnt]
		switch -- $test {
			1 {
				set files_found 1
				$wl insert 0 $fnam
			}
			-1 {
				lappend badrange $fnam
			}
			0 {
				lappend badfiles $fnam
			}
		}
	}
	UnBlock
	if {[info exists badrange]} {
		set msg "The Following Files Have The Wrong Range\n"
		set cnt 0
		foreach fnam $badrange {
			append msg $fnam "\n"
			incr cnt
			if {$cnt >= 20} {
				append msg "AND MORE\n"
				break
			}
		}
		append msg "Load To Workspace Anyway ??"
		set choice [tk_messageBox -type yesno -message $msg -icon question -parent [lindex $wstk end]]
		if [string match $choice "yes"] {
			foreach fnam $badrange {
				$wl insert 0 $fnam
			}
		} else {
			foreach fnam $badrange {
				catch {PurgeArray $fnam}
			}
		}
	}
	if {[info exists badfiles]} {
		set msg "The Following Files Are Inappropriate In This Case\n"
		set cnt 0
		foreach fnam $badfiles {
			append msg $fnam "\n"
			incr cnt
			if {$cnt >= 20} {
				append msg "AND MORE\n"
				break
			}
		}
		append msg "Load To Workspace Anyway ??"
		set choice [tk_messageBox -type yesno -message $msg -icon question -parent [lindex $wstk end]]
		if [string match $choice "yes"] {
			foreach fnam $badfiles {
				$wl insert 0 $fnam
			}
		} else {
			foreach fnam $badfiles {
				catch {PurgeArray $fnam}
			}
		}
	}
	$sfffl delete 0 end
	List_Appropriate_Files $pcnt $sfffl $type
	set text_filecnt [$sfffl index end]
	if {$brk(from_wkspace)} {
		$sfffb.all config  -text "Display" -command "GrafDisplayBrkfile 0" -borderwidth 2 -state normal
	} else {
		$sfffb.all config -text "All Textfiles" -command "SeeAll $sfffl $sfffb $type $pcnt $gcnt" -borderwidth $evv(SBDR) -state normal
	}
	if {($text_filecnt > 0) || !$sl_real} {
		if {$brk(from_wkspace)} {
			$sfffb.load config  -text "" -command {} -borderwidth 0 -state disabled
		} else {
			if {$type == "seg"} {	
				$sfffb.load config -text "Use" -command "UseSegFile $sfffl" -state normal -borderwidth $evv(SBDR)
				bind $f <Return> "UseSegFile $sfffl"
			} elseif {$type == "mchrot"} {	
				$sfffb.load config -text "Use" -command "UseRotFile $sfffl" -state normal -borderwidth $evv(SBDR)
				bind $f <Return> "UseRotFile $sfffl"
			} else {
				$sfffb.load config -text "Use" -command "UseFile $pcnt $sfffl" -state normal -borderwidth $evv(SBDR)
				bind $f <Return> "UseFile $pcnt $sfffl"
			}
		}
		$sfffb.edit config -text "Edit"   -command "GetFileToEdit $type $sfffl $pcnt $gcnt"
		$sfffb.del  config -text "Delete" -command "DeleteFile $sfffl"
		switch $type {
			"seg" - 
			"special" {$sfffb.lab config -text "Possible files??" -fg [option get . foreground {}]}
			"brk"	  {$sfffb.lab config -text "Appropriate files" -fg [option get . foreground {}]}
			"mchrot"  {$sfffb.lab config -text "Appropriate files" -fg [option get . foreground {}]}
		}
	} else {
		$sfffb.lab config -text "No appropriate files found" -fg $evv(SPECIAL)
	}
	return
}
	
#---- Test alternative files for specific usage

proc TestPossibleFile {fnam type pcnt} {
	global pa evv global pprg mmod actvlo actvhi prm chlist ins actvlo actvhi 
	set mmode $mmod
	incr mmode -1
	
	switch -- $type {
		"all" {
			if {$pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)} {
				return 1
			}
		}
		"seg" {
			if {($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)) \
			&&  ($pa($fnam,$evv(LINECNT)) == $pa($fnam,$evv(ALL_WORDS)))} {
				return 1
			}
		}
		"special" {
			if {$ins(run)} {
				if {$pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)} {
					return 1
				}
			} else {
				set OK 0
				switch -regexp -- $pprg \
					^$evv(MIXINBETWEEN)$ -	\
					^$evv(FREEZE)$ 	 	-	\
					^$evv(FREEZE2)$	 	-	\
					^$evv(SIMPLE_TEX)$ 	-	\
					^$evv(TEX_MCHAN)$ 	-	\
					^$evv(TIMED)$		-	\
					^$evv(GROUPS)$	 	-	\
					^$evv(ORNATE)$	 	-	\
					^$evv(PREORNATE)$  	-	\
					^$evv(POSTORNATE)$ 	-	\
					^$evv(MOTIFS)$	 	-	\
					^$evv(MOTIFSIN)$	-	\
					^$evv(DECORATED)$	-	\
					^$evv(PREDECOR)$	-	\
					^$evv(POSTDECOR)$	-	\
					^$evv(TGROUPS)$	 	-	\
					^$evv(TMOTIFS)$	 	-	\
					^$evv(TMOTIFSIN)$	-	\
					^$evv(SPLIT)$		-	\
					^$evv(ENV_CREATE)$ 	-	\
					^$evv(FLTBANKU)$	-	\
					^$evv(FLTITER)$	 	-	\
					^$evv(FLTBANKV)$ 	-	\
					^$evv(SYNFILT)$ 	-	\
					^$evv(FLTBANKV2)$ 	-	\
					^$evv(HF_PERM1)$ 	-	\
					^$evv(HF_PERM1)$ 	-	\
					^$evv(DEL_PERM)$ 	-	\
					^$evv(CLICK)$ 		-	\
					^$evv(DEL_PERM2)$	-	\
					^$evv(SYNTHESIZER)$	-	\
					^$evv(NEWTEX)$ {
						if {[IsNotMixText $pa($fnam,$evv(FTYP))]} {
							set OK 1									
						}				
					} \
					^$evv(TRNSF)$ - \
					^$evv(TRNSP)$ {
						switch -regexp -- $mmode \
							^$evv(TRNS_RATIO)$ {
								if {($pa($fnam,$evv(FTYP)) != $evv(MIX_MULTI)) && ($pa($fnam,$evv(FTYP)) & $evv(IS_A_TRANSPOS_BRKFILE))} {
									set OK 1		;#	is a transposition-ratio brkfile
								}
							} \
							^$evv(TRNS_OCT)$ - \
							^$evv(TRNS_SEMIT)$ {
								if {[IsABrkfile $pa($fnam,$evv(FTYP))]} {			
									set OK 1		;#	is an unspecified range brkfile
								}
							}	
						
					} \
					^$evv(CERACU)$ {
						if {[IsAListofNumbers $pa($fnam,$evv(FTYP))] && ($pa($fnam,$evv(NUMSIZE)) >= 2) && ($pa($fnam,$evv(MINNUM)) >= 1)} {
							set OK 1		;#	is a number list with at least 2 entries and all >= 1
						}						
					} \
					^$evv(SHIFTER)$ {
						if {[IsAListofNumbers $pa($fnam,$evv(FTYP))] && ($pa($fnam,$evv(NUMSIZE)) >= 2) && ($pa($fnam,$evv(MINNUM)) >= 2)} {
							set OK 1		;#	is a number list with at least 2 entries and all >= 2
						}						
					} \
					^$evv(FRACTURE)$ {
						if {[IsAListofNumbers $pa($fnam,$evv(FTYP))] && ([expr $pa($fnam,$evv(NUMSIZE)) % 15] == 0) && ($pa($fnam,$evv(MINNUM)) >= 0)} {
							set OK 1		;#	is a number list with entries grouped in 15s and all >= 0
						}						
					} \
					^$evv(MADRID)$ {
						if {[IsAListofNumbers $pa($fnam,$evv(FTYP))] ($pa($fnam,$evv(MINNUM)) >= 1)} {
							set OK 1		;#	is a number list with all entries >= 1
						}						
					} \
					^$evv(SEQUENCER)$ {
						if {[IsAListofNumbers $pa($fnam,$evv(FTYP))] \
						&& ([expr $pa($fnam,$evv(NUMSIZE)) % 3] == 0)} {
							set OK 1		;#	is a number list with 3 columns
						}						
					} \
					^$evv(SEQUENCER2)$ {
						if {[info exists chlist] && ([llength $chlist] > 0) && [IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
							set len [expr $pa($fnam,$evv(NUMSIZE)) - [llength $chlist]]
							if {($len > 0) && ([expr $len % 5] == 0)} {
								set OK 1		;#	is a number list with 5 columns, plus a first line containing midival for each infile
							}
						}						
					} \
					^$evv(MULTI_SYN)$  - \
					^$evv(GRAIN_GET)$ {
						if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
							set OK 1		;#	is a number list
						}						
					} \
					^$evv(GREV)$ {
						if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
							set OK 1		;#	is a number list
						}
					} \
					^$evv(MOD_LOUDNESS)$ {
						switch -regexp -- $mmode \
							^$evv(LOUD_PROPOR)$  - \
							^$evv(LOUD_DB_PROPOR)$ {
								if {[IsABrkfile $pa($fnam,$evv(FTYP))]} {
									set OK 1		;#	is a brkfile
								}
							}
					} \
					^$evv(DISTORT_ENV)$  	-	\
					^$evv(ENVSYN)$  		-	\
					^$evv(ENV_WARPING)$  	-	\
					^$evv(ENV_REPLOTTING)$ 	-	\
					^$evv(DISTORT_PULSED)$  -	\
					^$evv(ENV_RESHAPING)$ {
						if {[IsANormdBrkfile $pa($fnam,$evv(FTYP))]} {
							set OK 1				;#	is a normalised brkfile (used for envelopes)
						}
					} \
					^$evv(ACC_STREAM)$		-	\
					^$evv(CHORD)$		  	-	\
					^$evv(P_QUANTISE)$	 	-	\
					^$evv(P_SYNTH)$	 		-	\
					^$evv(TUNE)$  		 	-	\
					^$evv(WEAVE)$		 	-	\
					^$evv(MULTRANS)$	 	-	\
					^$evv(ZIGZAG)$		 	-	\
					^$evv(MCHZIG)$		 	-	\
					^$evv(GRAIN_REPITCH)$	-	\
					^$evv(GRAIN_RERHYTHM)$ 	-	\
					^$evv(GRAIN_POSITION)$ {
						if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
							set OK 1				;#	is a list of numbers
						}
					} \
					^$evv(GREQ)$ {
						switch -regexp -- $mmode \
							^$evv(GR_ONEBAND)$ {
								if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
									set OK 1		;#	is a list of numbers
								}
							} \
							^$evv(GR_MULTIBAND)$ {
								if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
									if [IsEven [expr round($pa($fnam,$evv(NUMSIZE)))]] {
										set OK 1	;#	is a list of paired numbers
									}
								}
							}				  

					} \
					^$evv(P_INVERT)$		-	\
					^$evv(P_INSERT)$		-	\
					^$evv(P_SINSERT)$		-	\
					^$evv(DISTORT_HRM)$		-	\
					^$evv(GRAIN_REMOTIF)$ 	-	\
					^$evv(INSERTSIL_MANY)$ 	-	\
					^$evv(HOUSE_EXTRACT)$ 	-	\
					^$evv(EDIT_CUTMANY)$ 	-	\
					^$evv(SUPPRESS)$ 	-	\
					^$evv(MANY_ZCUTS)$ 	-	\
					^$evv(JOIN_SEQDYN)$ -	\
					^$evv(EDIT_EXCISEMANY)$ {
						if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
							if [IsEven [expr round($pa($fnam,$evv(NUMSIZE)))]] {
								set OK 1			;#	is a list of paired numbers
							}
						}
					} \
					^$evv(STACK)$ -	\
					^$evv(SYLLABS)$ -	\
					^$evv(JOIN_SEQ)$ -	\
					^$evv(TWIXT)$ {
						if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
							set OK 1		;#	is a list of numbers
						}
					} \
					^$evv(SPHINX)$ {
						if {[IsAListofNumbers $pa($fnam,$evv(FTYP))] \
						&&  ($pa($fnam,$evv(FTYP)) & $evv(IS_A_LINELIST))} {
							set OK 1		;#	is a list of numbers arranged in lines
						}
					} \
					^$evv(MIX_ON_GRID)$ - \
					^$evv(AUTOMIX)$ 	- \
					^$evv(P_GEN)$ 		- \
					^$evv(VFILT)$ 		- \
					^$evv(BATCH_EXPAND)$ - \
					^$evv(PSOW_SYNTH)$ - \
					^$evv(PSOW_IMPOSE)$ - \
					^$evv(P_VOWELS)$ {
						if {$pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)} {
							set OK 1		;#	is a textfile
						}
					} \
					^$evv(TAPDELAY)$ {
						if {[IsAListofNumbers $pa($fnam,$evv(FTYP))] \
						&& (([expr $pa($fnam,$evv(NUMSIZE)) % 2] == 0)
						||  ([expr $pa($fnam,$evv(NUMSIZE)) % 3] == 0))} {
							set OK 1		;#	is a number list with 2 or 3 columns
						}						
					} \
					^$evv(PSOW_STRETCH)$ - \
					^$evv(PSOW_DUPL)$ - \
					^$evv(PSOW_STRFILL)$ - \
					^$evv(PSOW_FREEZE)$ - \
					^$evv(PSOW_CHOP)$ - \
					^$evv(PSOW_FEATURES)$ - \
					^$evv(PSOW_SPLIT)$ - \
					^$evv(PSOW_SPACE)$ - \
					^$evv(PSOW_INTERP)$ - \
					^$evv(PSOW_REPLACE)$ - \
					^$evv(PSOW_EXTEND)$ - \
					^$evv(PSOW_EXTEND2)$ - \
					^$evv(PSOW_LOCATE)$ - \
					^$evv(PSOW_CUT)$ - \
					^$evv(PSOW_INTERLEAVE)$ - \
					^$evv(PSOW_DEL)$ {
						if {[IsABrkfile $pa($fnam,$evv(FTYP))]} {			
							set OK 1		;#	is an unspecified range brkfile
						}
					} \
					^$evv(PSOW_REINF)$ {
						if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
							set OK 1		;#	is a number list
						}
					} \
					^$evv(RETIME)$ {
						switch -- $mmode {
							0 {
								if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
									set OK 1		;#	is a number list
								}
							}
							1 {
								if {[IsAListofNumbers $pa($fnam,$evv(FTYP))] && [IsEven $pa($fnam,$evv(NUMSIZE))] && ($pa($fnam,$evv(MINNUM)) >= 0.0)} {
									set OK 1		;#	is a number list with an even number of entries, ALL  >= 0
								}
							}
							5 -
							6 {
								if {[IsAListofNumbers $pa($fnam,$evv(FTYP))] && ($pa($fnam,$evv(MINNUM)) >= 0.0)} {
									set OK 1		;#	is a number list, ALL  >= 0
								}
							}
							8 {
								if {[IsAListofNumbers $pa($fnam,$evv(FTYP))] && ($pa($fnam,$evv(MINNUM)) == 0.0) && ($pa($fnam,$evv(MAXNUM)) == 1.0)} {
									set OK 1		;#	is a number list, ALL >= 0 <=1
								}
							}
						}
					} \
					^$evv(TAPDELAY)$ - \
					^$evv(RMVERB)$ {
						if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
							set k [expr $pa($fnam,$evv(NUMSIZE)) / $pa($fnam,$evv(LINECNT))]
							if {($k == 2) || ($k == 3)} {
								if {[expr $k * $pa($fnam,$evv(LINECNT))] == $pa($fnam,$evv(NUMSIZE))} {
									set OK 1		;#	is a number list with 2 or 3 columns
								}						
							}
						}
					} \
					^$evv(FOFEX_EX)$ - \
					^$evv(FOFEX_CO)$ - \
					^$evv(TWEET)$    - \
					^$evv(MANYSIL)$ {
						if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
							set k [expr $pa($fnam,$evv(NUMSIZE)) / $pa($fnam,$evv(LINECNT))]
							if {[expr $k * $pa($fnam,$evv(LINECNT))] == $pa($fnam,$evv(NUMSIZE))} {
								set OK 1		;#	is a number list with 2 columns
							}
						}
					} \
					^$evv(MCHANPAN)$ {
						switch -- $mmode {
							0 {
								if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
									set k [expr $pa($fnam,$evv(NUMSIZE)) / $pa($fnam,$evv(LINECNT))]
									if {([expr $k * $pa($fnam,$evv(LINECNT))] == $pa($fnam,$evv(NUMSIZE))) && ($k == 3)} {
										set OK 1		;#	is a number list with 3 columns
									}
								}
							}
							1 {
								if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
									if {($pa($fnam,$evv(MINNUM)) > 0) &&  ($pa($fnam,$evv(MAXNUM)) <= 16)} {
										set OK 1		;#	is a number list in range 1 to 16
									}
								}
							}
							6 {
								if {[IsAListofNumbers $pa($fnam,$evv(FTYP))] && ($pa($fnam,$evv(MINNUM)) >= 0.0)} {
									set OK 1		;#	is a number list, all vals >= 0
								}
							}
						}
					} \
					^$evv(FRAME)$ {
						if {$ins(create)} {
							set sfnam [lindex $ins(chlist) 0]
						} else {
							set sfnam [lindex $chlist 0]
						}
						switch -- $mmode {
							2 {
								if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
									if {$pa($fnam,$evv(NUMSIZE)) == $pa($sfnam,$evv(CHANS))} {
										set OK 1		;#	is a list of ALL chans numbers
									}
								}
							}
							6 {
								if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
									if {$pa($fnam,$evv(NUMSIZE)) <= $pa($sfnam,$evv(CHANS))} {
										set OK 1		;#	is a list of some of chan numbers
									}
								}
							}
							default {
								if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
									set k [expr $pa($fnam,$evv(NUMSIZE)) / $pa($fnam,$evv(LINECNT))]
									if {([expr $k * $pa($fnam,$evv(LINECNT))] == $pa($fnam,$evv(NUMSIZE))) && ($k == [expr $pa($sfnam,$evv(CHANS)) + 1])} {
										set OK 1		;#	is a number list with chans+1 cols
									}
								}
							}
						}
					} \
					^$evv(FLUTTER)$ {
						if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
							set OK 1		;#	is a list of chans numbers
						}
					} \
					^$evv(CHANNELX)$ {
						if {$ins(create)} {
							set sfnam [lindex $ins(chlist) 0]
						} else {
							set sfnam [lindex $chlist 0]
						}
						if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
							if {($pa($fnam,$evv(MINNUM)) >= 1) && ($pa($fnam,$evv(MAXNUM)) <= $pa($sfnam,$evv(CHANS)))} {
								set OK 1		;#	is a list of chans numbers in range 1 t to chancnt of infile
							}
						}
					} \
					^$evv(MCHSTEREO)$ {
						if {$ins(create)} {
							set thischlist $ins(chlist)
						} else {
							set thischlist $chlist
						}
						if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
							if {($pa($fnam,$evv(NUMSIZE)) == [llength $thischlist]) && ($pa($fnam,$evv(MINNUM)) >= 1) && ($pa($fnam,$evv(MAXNUM)) <= $prm(1))} {
								set OK 1		;#	is a list of chans numbers, as long as number of infiles
							}
						}
					} \
					^$evv(WRAPPAGE)$ {
						if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
							set k [expr $pa($fnam,$evv(NUMSIZE)) / $pa($fnam,$evv(LINECNT))]
								if {([expr $k * $pa($fnam,$evv(LINECNT))] == $pa($fnam,$evv(NUMSIZE))) && ($k == 3)} {
									set OK 1		;#	is a number list with 3 columns
							}
						}
					} \
					^$evv(SPECSLICE)$ {
						if {[IsABrkfile $pa($fnam,$evv(FTYP))]} {			
							set OK 1		;#	is an unspecified range brkfile
						}
					} \
					^$evv(PACKET)$ {
						if {$ins(create)} {
							set sfnam [lindex $ins(chlist) 0]
						} else {
							set sfnam [lindex $chlist 0]
						}
						if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]  && ($pa($fnam,$evv(MINNUM)) >= 0.0) && ($pa($fnam,$evv(MAXNUM)) <= $pa($sfnam,$evv(DUR)))} {
							set OK 1
						}
					} \
					^$evv(PULSER3)$ {
						if {$mmode == 0} {
							if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]  && ($pa($fnam,$evv(MINNUM)) >= -1.0) && ($pa($fnam,$evv(MAXNUM)) <= 64.0)} {
								set OK 1
							}
						} else {
							if {[IsNotMixText $pa($fnam,$evv(FTYP))]} {
								set OK 1									
							}				
						}
					} \
					default {
						ErrShow "Unknown option ($pprg) reached in List_Appropriate_Files."
						return 0
					}

				if {$OK} {
					return 1
				}
			}
		}
		"brk" {
			if {[IsABrkfile $pa($fnam,$evv(FTYP))]} {
				if {($pa($fnam,$evv(MINBRK)) >= $actvlo($pcnt)) &&	($pa($fnam,$evv(MAXBRK)) <= $actvhi($pcnt))} {
					return 1
				} else {
					return -1
				}
			}
		}	
		"mchrot" {
			if {[IsABrkfile $pa($fnam,$evv(FTYP))]} {
				if {($pa($fnam,$evv(MINBRK)) >= 0) && ($pa($fnam,$evv(MAXBRK)) <= 64)} {
					return 1
				} else {
					return -1
				}
			}
		}	
		"allbrk" {
			if {[IsABrkfile $pa($fnam,$evv(FTYP))]} {
				return 1
			}
		}
	}
	return 0
}

proc ListChosenAlternativeDir {} {
	global alternativedir altdirlist
	DoListingOfDirectories alternative
	if {([string length $alternativedir] > 0) && [file exists $alternativedir] && [file isdirectory $alternativedir]} {
		$altdirlist delete 0 end
		foreach fnam [glob -nocomplain [file join $alternativedir *]] {
			$altdirlist insert end $fnam
		}
	}
}

proc ShowGetFileChoice {y} {
	global sfffl
	set i [$sfffl nearest $y]
	if {$i >= 0} {
		set fnam [$sfffl get $i]
		SimpleDisplayTextfile $fnam
	}
}

proc FixedPitchConvert {t} {
	global pprg mmod evv
	if {($pprg != $evv(FLTBANKV)) || ($mmod != 2)} {
		return
	}
	set vals [$t get 1.0 end]
	set lines "[split $vals \n]"
	foreach line $lines {
		set vals [split $line]
		foreach val $vals {
			set val [string trim $val]
			if {[string length $val] <= 0} {
				continue
			}
			lappend nuvals $val
		}
	}
	if {![info exists nuvals]} {
		return
	}
	foreach val $nuvals {
		if {($val < 0) || ($val > 127)} {
			Inf "Invalid Midi Value $val Encountered : Cannot Do Conversion"
			return
		}
	}
	set len [llength $nuvals]
	if {$len > 1} {
		set len_less_one [expr $len - 1]
		set n 0
		while {$n < $len_less_one} {
			set val_n [lindex $nuvals $n]
			set m $n
			incr m
			while {$m < $len} {
				if {[lindex $nuvals $m] == $val_n} {
					Inf "Duplicated Midi Value ($val_n)"
					return
				}
				incr m
			}
			incr n
		}
	}
	set line0 0
	set line1 10000
	foreach val $nuvals {
		lappend line0 $val 1
		lappend line1 $val 1
	}
	set lines [list $line0 $line1]
	$t delete 1.0 end
	foreach line $lines {
		$t insert end "$line\n"
	}
}

proc BracketList {f} {
	global chlist evv pa
	set data "0"
	foreach item [$f.k.t get 1.0 end] {
		lappend data "$item"
	}
	lappend data $pa([lindex $chlist 0],$evv(DUR))
	$f.k.t delete 1.0 end
	foreach line $data {
		$f.k.t insert end "$line\n"
	}
}

proc MixBakupTest {} {
	global wl ch chlist pa evv wstk
	if {[info exists chlist] && ([llength $chlist] == 1)} {
		set fnam [lindex $chlist 0]
		set ftyp $pa($fnam,$evv(FTYP))
		if {![IsAMixfileIncludingMultichan $ftyp]} {
			unset fnam
		}
	}
	if {![info exists fnam]} {
		set i [$wl curselection]
		if {[info exists i] && ([llength $i] == 1) && ($i != -1)} {
			set fnam [$wl get $i]
			set ftyp $pa($fnam,$evv(FTYP))
			if {![IsAMixfileIncludingMultichan $ftyp]} {
				unset fnam
			}
		}
	}
	if {![info exists fnam]} {
		Inf "Chose a mixfile"
		return
	}
	set is_a_multichan 0
	if {$ftyp ==  $evv(MIX_MULTI)} {
		set is_a_multichan 1
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot open file [file rootname [file tail $fnam]]"
		return
	}
	set linecnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		set is_comment 0
		if {[string match ";" [string index $line 0]]} {
			set is_comment 1
			set line [string range $line 1 end]
		}
		set line [split $line]
		set itemcnt 0
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {$is_a_multichan && ($linecnt == 0)} {
				break
			}
			switch -- $itemcnt {
				0 {
					if {![file exists $item]} {
						if {$is_comment} {
							lappend nonexist_c $item
						} else {
							lappend nonexist $item
						}
					} elseif {[string match $item [file tail $item]]} {
						if {$is_comment} {
							lappend nonbakup_c $item
						} else {
							lappend nonbakup $item
						}
					}
				}
				1 {
					break
				}
			}
			incr itemcnt
		}
		incr linecnt
	}
	close $zit
	set msg "In Mixfile $fnam\n\n"
	if {[info exists nonexist]} {
		append msg "The following files no longer exist"
		foreach fnam $nonexist {
			append msg "\n$fnam"
		}
	}
	if {[info exists nonbakup]} {
		append msg "\nthe following files are not backed-up"
		foreach fnam $nonbakup {
			append msg "\n$fnam"
		}
	}
	if {[info exists nonexist_c] || [info exists nonbakup_c]} {
		set mmsg "Do wish to know about the status of muted files ??"
		set choice [tk_messageBox -type yesno -message $mmsg -icon question -parent [lindex $wstk end]]
		if [string match $choice "yes"] {
			if {[info exists nonexist_c]} {
				append msg "\nThe following muted files no longer exist"
				foreach fnam $nonexist_c {
					append msg "\n$fnam"
				}
			} 
			if {[info exists nonbakup_c]} {
				append msg "\nThe following muted files are not backed-up"
				foreach fnam $nonbakup_c {
					append msg "\n$fnam"
				}
			}
		}
	}
	if {[string length $msg] <= 0} {
		append msg "All files are backed up"
	}
	Inf $msg
}
