#
# SOUND LOOM RELEASE mac version 17.0.4
#
# RWD Feb 2011 line 2918: always use do_stop with anal files!
# until such time as I have a GUI player done...
#RWD 28 June 2013
# ... fixup button rectangles

######################
# GETTING PARAMETERS #
######################

#------ Set program no. and mode no. global variables, and return pr2 (to continue)
 
proc ActivateProgram {i j k} {
	global pr2 pprg mmod has_saved_at_all pseudoprog evv

	if {[NoLongerAvailable $j $k] || [NotAccessible $j $k]} {
		return
	}
	if {$j >= $evv(PSEUDO_PROGS_BASE)} {
		set pseudoprog $j
		set j [PseudoProg $j] 
	} else {
		catch {unset pseudoprog}
	}
	set has_saved_at_all 0
	set pprg $j
	set mmod $k
	set pr2 1
}			

#------ Return from ppg to workspace
 
proc GetNewFilesFromPpg {} {
	global favors current_favorites pr2 pr3 ins_rethink pseudoprog last_pseudoprog pprg mmod prm wl ww evv real_chlist chlist
	global set_thumbnailed qikmixset bulksplit origsplitfnam articvw last_outfile woutlist

	catch {file delete $articvw}
	if {[info exists bulksplit]} {		;#	Force exit from multichan-bulkprocess-of-individ-chans
		unset bulksplit					;#	And return directly to workspace
		set chlist $origsplitfnam
		DeleteAllTemporaryFiles
	}
	catch {unset qikmixset}
	catch {$favors delete 0 end}
	catch {unset current_favorites}
	if {[info exists pseudoprog]} {
		set last_pseudoprog $pseudoprog
	} else {
		catch {unset last_pseudoprog}
	}
	catch {unset pseudoprog}
	if {($pprg == $evv(RETIME)) && ($mmod == 12)} {
		set fnam $prm(0)
		if {[LstIndx $fnam $wl] < 0} {
			if {[FileToWkspace $fnam 0 0 0 0 1] > 0} {
				$wl selection clear 0 end
				$wl selection set 0
			}
		}
		catch {unset woutlist}
	}
	if {[info exists real_chlist]} {
		set chlist $real_chlist
		unset real_chlist
		set set_thumbnailed 0
		$ww.1.a.mez.bkgd config -state normal
	}
	PurgeTempThumbnails
	set pr3 0
	set pr2 0
 	set ins_rethink 1
	if {[info exists woutlist] && [info exists last_outfile]} {
		$wl selection clear 0 end
		set i 0
		foreach fnam $last_outfile {
			$wl selection set $i
			incr i
		}
	}
}

#------ Return from ppg to workspace during Instrument
 
proc AbandonIns {} {
	global favors current_favorites pr2 pr3 ins_aborted qikmixset
	catch {$favors delete 0 end}
	catch {unset current_favorites}
	catch {unset qikmixset}
	set pr3 0
	set pr2 0
 	set ins_aborted 1
}

#------ Get parameters for process and, if OK, run program

proc GetParamsAndRunProgram {} {
	global ppg pg_spec param_spec bombout cdpmenu prg selected_menu pim papag small_screen evv
	global pr3 prg_ocnt pprg mmod brkdurflag from_runpage wstk prm invlist
	global prg_ran_before ins hst do_repost mixmaxnorm last_outfile
	global CDPid badparamspec ppg chlist chosen_men entry_exists sndgraphics
	global params_got ins_creation ins_concluding gdg_creat_fail maxgrain_gatelevel
	global ppg_hlp_actv ppg_actv var_could_exist pmcnt prmgrd sl_real new_cdparams_testing
	global has_played has_viewed has_read has_saved has_saved_at_all is_terminating is_crypto
	global bulk snack_enabled pseudoprog fof_pos stage_last disstage_last fof_separator
	global onpage_oneatatime panprocess panprocessfnam panprocess_individ mchengineer o_nam pa articvw articorigdata woutlist
	global ins_file_lst

	catch {unset woutlist}
	catch {unset stage_last}
	catch {unset disstage_last}
	set params_got 0
	set prg_ran_before 0
	set badparamspec 0
#OCT 2005
	set has_played 0

	set is_crypto [HandleCryptoModes]

	set this_mode $mmod
	incr this_mode -1

	catch {unset param_spec}

	if {[GrainTrap]} {
		return 0
	}
	set cdparams_cmd "[SetupCdparamsCmdline]"

	if {$new_cdparams_testing} {
		Inf "Command To cdparams Is\n\n$cdparams_cmd"
	}
	if [catch {open "|$cdparams_cmd"} CDPid] {
		ErrShow "FAILED TO RUN cdparams"
		catch {unset CDPid}
		return 0										
	} else {										
   		fileevent $CDPid readable AccumulateParameterSpecs
		fconfigure $CDPid -buffering line
	}												
	vwait params_got

	if {$badparamspec} {
		ErrShow "Bad parameter specification"
		return 0									
	}

	if {![info exists param_spec]} {
		ErrShow "No data returned from Cdparams"
		return 0
	}

#DISTINGUISHING THE fileevent GLOBAL FROM THE WIDER GLOBAL

	set pg_spec $param_spec

	set pgs_len [llength $pg_spec]
	if {$pgs_len <= 0} {
		ErrShow "No data returned from Cdparams"
		return 0
	}
	set bdf_param [lindex $pg_spec 0]
	if {[llength $bdf_param] < 0} {
		ErrShow "No brkdurflag returned from Cdparams"
		return 0
	}
	set brkdurflag [lindex $bdf_param 0]
	if {$pgs_len > 1} {
		set pg_spec [lrange $pg_spec 1 end]

		set i 0
		foreach jjj $pg_spec {
			if [InsertSampValConverters $jjj $pprg $this_mode] {
				lappend jjj "sg"
				set pg_spec [lreplace $pg_spec $i $i $jjj]
			}
			incr i
		}
	} else {
		unset pg_spec
	}
	;#	NB If this is a NEW process, 'GotoProgram' has destroyed any existing ppg

	set ppg_hlp_actv 0
	set ppg_actv 1

	set from_runpage 1

	if {[info exists var_could_exist]} {
		if {$ins_creation && !$var_could_exist} {	
			catch {destroy .ppg}					;#	If existing ppg is not set up for ins-creation
		 											;#	destroy it and start again
		} elseif {!$ins_creation  && $var_could_exist} {	
			catch {destroy .ppg}					;#	If existing ppg IS set up for ins-creation
		}											;#	destroy it and start again
	}
	set gdg_creat_fail 0
	if [Dlg_Create .ppg "Parameters" "set pr3 0" -borderwidth $evv(BBDR)] {
		Dlg_Params .ppg $pprg
	}
	bind .ppg <Control-Key-m> {DirectToQikEdit}
	bind .ppg <Control-Key-M> {DirectToQikEdit}

	bind .ppg <Control-8> {GetMaxsamps 1 0}
	bind .ppg <Control-9> {GetMaxsamps 0 1}

#FEBRUARY 2004: Problem with History if Table Editor used during Instrument Creation ....
	if {[info exists ins(create)] && $ins(create)} {
		$papag.parameters.zzz.tedit config -state disabled	
	} else {
		$papag.parameters.zzz.tedit config -state normal
	}
	DisableExtraBatchButtons
	if {$small_screen} {
		set papag .ppg.c.canvas.f
	} else {
		set papag .ppg
	}	
#NOVEMBER 2001
	switch -regexp -- $pprg \
		^$evv(MIX)$		- \
		^$evv(MIXGAIN)$ {
			if {[info exists mixmaxnorm] && ($mixmaxnorm < 1.0)} {
				switch -regexp -- $pprg \
					^$evv(MIX)$ {
						set prm($evv(MIX_ATTEN)) $mixmaxnorm
					} \
					^$evv(MIXGAIN)$ {
						set prm($evv(MIX_GAIN)) $mixmaxnorm
					}
			}
		} \
		^$evv(GRAIN_COUNT)$		- \
		^$evv(GRAIN_GET)$		- \
		^$evv(GRAIN_REVERSE)$ {
			if {[info exists maxgrain_gatelevel]} {
				set prm(1) $maxgrain_gatelevel
			}
		} \
		^$evv(GRAIN_REORDER)$	-\
		^$evv(GRAIN_DUPLICATE)$	- \
		^$evv(GRAIN_REPITCH)$	- \
		^$evv(GRAIN_RERHYTHM)$	- \
		^$evv(GRAIN_REMOTIF)$	- \
		^$evv(GRAIN_TIMEWARP)$ {
			if {[info exists maxgrain_gatelevel]} {
				set prm(2) $maxgrain_gatelevel
			}
		} \
		^$evv(GRAIN_OMIT)$		- \
		^$evv(GRAIN_POSITION)$ {
			if {[info exists maxgrain_gatelevel]} {
				set prm(3) $maxgrain_gatelevel
			}
		} \
		^$evv(GRAIN_ALIGN)$	{
			if {[info exists maxgrain_gatelevel]} {
				set prm(1) $maxgrain_gatelevel
				set prm(3) $maxgrain_gatelevel
			}
		} \
		^$evv(PSOW_CUT)$ - \
		^$evv(PSOW_FREEZE)$ {
			if {[info exists fof_pos]} {
				set prm(1) $fof_pos
			}
		} \
		^$evv(FOFEX_EX)$ {
			if {$this_mode == 1} {
				if {[info exists fof_pos]} {
					set prm(1) $fof_pos
				}
			}
		} \
		^$evv(SIMPLE_TEX)$	- \
		^$evv(TEX_MCHAN)$   - \
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
			set prm([expr $evv(TEXTURE_INSHI) + 1]) [llength $chlist]
		}

	set entry_focus [EstablishRollingFocus]

	if {[IsMchanToolkit $pprg]} {
		set thistext [MchanToolKitNames $pprg]
	} else {
		set thistext "[lindex $cdpmenu($selected_menu) $evv(MENUNAME_INDEX)] [lindex $prg($pprg) $evv(PROGNAME_INDEX)]"
	}
	if {$mmod > 0} {
		set mode_index $evv(MODECNT_INDEX)
		incr mode_index $mmod
		append thistext "...."
		append thistext [lindex $prg($pprg) $mode_index]
	}

	wm title .ppg "Parameters for $thistext"

	if {($ins(create) && [info exists ins(chlist)]) || (!$ins(create) && [info exists chlist])} {
		ForceVal $papag.parameters.buttons.fcnte [llength $chlist]
	} else {
		ForceVal $papag.parameters.buttons.fcnte "0"
	}
	if {$evv(NEWUSER_HELP)} {
		$papag.help.starthelp config -command "GetNewUserHelp parameters"
	}
 
 	if {$ins_creation} {
		$papag.parameters.output.keep config -text "Keep"
	 	$papag.parameters.zzz.newf config -text "Get New Files"
 		$papag.parameters.zzz.mabo config -text "Abandon Instr" -command AbandonIns -state normal
		$papag.parameters.output.playsrc config -text "Play Src" -command "PlayInput"
		$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
		$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
		ProcessSpecificDisplaysForInstrumentCreation
	} else {
		$papag.parameters.output.keep config -text "Save As"
 		if {[info exists onpage_oneatatime]} {
			$papag.parameters.zzz.newf config -text "Next File" -command {DoOneAtATimeFromParampage}
		} elseif {[info exists mchengineer]} {
	 		$papag.parameters.zzz.newf config -text "Engineer" -command {GetNewFilesFromPpg}
		} else {
			$papag.parameters.zzz.newf config -text "To Wkspace" -command {GetNewFilesFromPpg}
		}
		$papag.parameters.zzz.mabo config -text "Recycle Output" -command "RecycleOutfile" -state disabled
		$papag.parameters.output.playsrc config -text "Play Src" -command "PlayInput"
		if {$ins(run)} {
			$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
			$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
		} else {
			switch -regexp -- $pprg \
				^$evv(MIXMAX)$		- \
				^$evv(MIXGAIN)$		- \
				^$evv(MIXSHUFL)$	- \
				^$evv(MIXSYNC)$		- \
				^$evv(MIXSYNCATT)$	- \
				^$evv(MIXTWARP)$	- \
				^$evv(MIXSWARP)$ {
					$papag.parameters.output.editsrc config -text "Edit Mix" \
						-command "EditSrcTextfile mix" -bd 2 -state normal
					$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state normal
					MixingBackup
				} \
				^$evv(MIX)$	{
					$papag.parameters.output.editsrc config -text "Edit Mix" \
						-command "EditSrcTextfile mix" -bd 2 -state normal
					$papag.parameters.output.editqik config -text "QikEdit" \
						-command "EditSrcMixfile mix" -bd 2 -state normal
					MixingBackup
				} \
				^$evv(MIXMULTI)$ {
					$papag.parameters.output.editsrc config -text "Edit Mix" \
						-command "EditSrcTextfile mmix" -bd 2 -state normal
					$papag.parameters.output.editqik config -text "QikEdit" \
						-command "EditSrcMixfile mix" -bd 2 -state normal
					MixingBackup
				} \
				^$evv(MIXBALANCE)$ {
					$papag.parameters.output.editsrc config -text  "Invert" \
						-command "InvertData balance" -bd 2 -state normal
					$papag.parameters.output.editqik config -text "SndSwap" \
						-command "ReverseBalanceFiles" -bd 2 -state normal
				} \
				^$evv(ITERFOF)$ {
					$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOROFF)
					$papag.parameters.output.editqik config -text "Line Dur" -command "SnapToLineDur" -bd 2 -state normal
				} \
				^$evv(SPLINTER)$ {
					$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 1" -bd 2 -state normal -bg $evv(SNCOLOR)
					$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
				} \
				^$evv(FIND_PANPOS)$ - \
				^$evv(ONEFORM_GET)$ {
					$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 1" -bd 2 -state normal -bg $evv(SNCOLOR)
					$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
				} \
				^$evv(LOOP)$ {
					$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOR)
					$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
				} \
				^$evv(SPECEX)$ {
					$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOR)
					$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
				} \
				^$evv(SHRINK)$ {
					set invlist [FindSndfilesChosen]
					if {[llength $invlist] > 0} {
						if {$mmod == 4} {
							$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 1" -bd 2 -state normal -bg $evv(SNCOLOR)
						} else {
							$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOROFF)
						}
					}
					$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
				} \
				^$evv(FOFEX_CO)$ {
					set invlist [FindSndfilesChosen]
					if {[llength $invlist] > 0} {
						if {$snack_enabled} {
							if {(($mmod == 1) || ($mmod == 6) || ($mmod == 7)) && [info exists fof_separator]} {						
								$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOR)
							} else {
								$papag.parameters.output.editsrc config -text "SView Only" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOROFF)
							}
						} else {
							$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
							SnackRecolor $invlist 1
						}
					} else {
						$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
					}
				} \
				^$evv(EDIT_INSERT2)$ - \
				^$evv(EDIT_INSERTSIL)$ {
					set invlist [FindSndfilesChosen]
					if {[llength $invlist] > 0} {
						if {$snack_enabled} {
							$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOR)
						} else {
							$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
							SnackRecolor $invlist 1
						}
					} else {
						$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
					}
					$papag.parameters.output.editqik config -text "End->Dur" -command "EndtimeToDur" -bd 2 -state normal
				} \
				^$evv(EDIT_EXCISEMANY)$ - \
				^$evv(EDIT_CUTMANY)$ - \
				^$evv(INSERTSIL_MANY)$ {
					set invlist [FindSndfilesChosen]
					if {[llength $invlist] > 0} {
						$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
						SnackRecolor $invlist 0
					} else {
						$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
					}
					$papag.parameters.output.editqik config -text "Merge" -command "MergeMultiEditData" -bd 2 -state normal
				} \
				^$evv(LPHP)$ {
					$papag.parameters.output.editsrc config -text "Toggle" -command "InvertFilt" -bd 2 -state normal
					$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
				} \
				^$evv(TOSTEREO)$ {
					$papag.parameters.output.editsrc config -text "View Src" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOR)
					$papag.parameters.output.editqik config -text "Toggle" -command "ChooseToStereo" -bd 2 -state normal
				} \
				^$evv(MIX_AT_STEP)$ {
					set invlist [FindSndfilesChosen]
					$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
					SnackRecolor $invlist 0
					$papag.parameters.output.editqik config -text  "TapTime" -command "MixTimetap" -bd 2 -state normal
				} \
				^$evv(PREFIXSIL)$ {
					set invlist [FindSndfilesChosen]
					$papag.parameters.output.editsrc config -text "View Src" -command "SnackView 1" -bd 2 -state normal -bg $evv(SNCOLOR)
					$papag.parameters.output.editqik config -text  "" -command {} -bd 0
				} \
				^$evv(MOD_SPACE)$ {
					set invlist [FindSndfilesChosen]
					$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
					SnackRecolor $invlist 0
					if {$this_mode == $evv(MOD_PAN)} {
						$papag.parameters.output.editqik config -text  "Invert" \
							-command "InvertData pan" -bd 2 -state normal
					} else {
						$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
					}
				} \
				^$evv(MOD_RADICAL)$ {
					$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
					set invlist [FindSndfilesChosen]
					if {$this_mode == $evv(MOD_SCRUB)} {
						$papag.parameters.output.editsrc config -text "View Src" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOR)
					} else {
						$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
						SnackRecolor $invlist 0
					}
				} \
				^$evv(ENV_IMPOSE)$	- \
				^$evv(ENV_REPLACE)$ {
					if {$this_mode == $evv(ENV_BRKFILE_IN)} {
						$papag.parameters.output.editsrc config -text  "Edit Env" \
							-command "EditSrcTextfile env" -bd 2 -state normal
					$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
					}
				} \
				^$evv(TWIXT)$ {
					$papag.parameters.output.editsrc config -text  "NudgeTime" \
						-command "EditSrcTextfile twixt" -bd 2 -state normal
					$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
				} \
				^$evv(CLICK)$ {
					$papag.parameters.output.editsrc config -text  "Time+Beat" \
						-command "ClikCalculator" -bd 2 -state normal
					$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
				} \
				^$evv(FLTBANKV)$ {
					$papag.parameters.output.editsrc config -text  "MaxHarmnc" \
						-command "MaxHarmCalc 2" -bd 2 -state normal
					$papag.parameters.output.editqik config -text "Randomise" -command ScatterFilter -bd 2 -state normal
				} \
				^$evv(SYNFILT)$ {
					$papag.parameters.output.editsrc config -text  "Max Harmonic" \
						-command "MaxHarmCalc $this_mode" -bd 2 -state normal
					$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
				} \
				^$evv(FLTBANKV2)$ {
					set invlist [FindSndfilesChosen]
					if {[llength $invlist] > 0} {
						$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
						SnackRecolor $invlist 0
					} else {
						$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
					}
					$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
				} \
				^$evv(MIXCROSS)$ {
					set invlist [FindSndfilesChosen]
					if {[llength $invlist] > 0} {
						if {$snack_enabled} {
							$papag.parameters.output.editsrc config -text "Snd View" -command "ViewInput $invlist" -bd 2 -state normal -bg $evv(SNCOLOR)
						} else {
							$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal -bg [option get . background {}]
						}
					} else {
						$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
					}
					$papag.parameters.output.editqik config -text "Nudge" -command "MixCrossNudge mixcross" -bd 2 -state normal
				} \
				^$evv(ENV_TREMOL)$ {
					set invlist [FindSndfilesChosen]
					if {[llength $invlist] > 0} {
						$papag.parameters.output.editsrc config -text "Snd View" -command "ViewInput $invlist" -bd 2 -state normal -bg $evv(SNCOLOR)
						SnackRecolor $invlist 0
						$papag.parameters.output.editqik config -text "VaryFrq" -command "TremVary" -bd 2 -state normal
					} else {
						$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state normal
						$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state normal
					}
				} \
				^$evv(MOD_PITCH)$ {
					set invlist [FindSndfilesChosen]
					if {[llength $invlist] > 0} {
						if {$this_mode == 4} {
							$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOR)
							$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state normal
						} elseif {$this_mode == 5} {
							$papag.parameters.output.editsrc config -text "Snd View" -command "ViewInput $invlist" -bd 2 -state normal -bg $evv(SNCOLOR)
							SnackRecolor $invlist 0
							$papag.parameters.output.editqik config -text "VaryFrq" -command "TremVary" -bd 2 -state normal
						} elseif {[llength $invlist] > 0} {
							$papag.parameters.output.editsrc config -text "Snd View" -command "ViewInput $invlist" -bd 2 -state normal -bg $evv(SNCOLOR)
							SnackRecolor $invlist 0
							$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state normal
						}
					} else {
						$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state normal
						$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state normal
					}
				} \
				^$evv(STRANS_MULTI)$ {
					set invlist [FindSndfilesChosen]
					if {[llength $invlist] > 0} {
						if {$this_mode == 2} {
							$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOR)
							$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state normal
						} elseif {$this_mode == 3} {
							$papag.parameters.output.editsrc config -text "Snd View" -command "ViewInput $invlist" -bd 2 -state normal -bg $evv(SNCOLOR)
							SnackRecolor $invlist 0
							$papag.parameters.output.editqik config -text "VaryFrq" -command "TremVary" -bd 2 -state normal
						} elseif {[llength $invlist] > 0} {
							$papag.parameters.output.editsrc config -text "Snd View" -command "ViewInput $invlist" -bd 2 -state normal -bg $evv(SNCOLOR)
							SnackRecolor $invlist 0
							$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state normal
						}
					} else {
						$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state normal
						$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state normal
					}
				} \
				^$evv(ENV_CURTAILING)$ - \
				^$evv(EXPDECAY)$ {
					set invlist [FindSndfilesChosen]
					if {[llength $invlist] > 0} {
						if {$snack_enabled} {
							if {$mmod == 3 || $mmod == 6} {
								$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 1" -bd 2 -state normal -bg $evv(SNCOLOR)
							} else {
								$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOR)
							}
						} else {
							$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
							SnackRecolor $invlist 1
						}
					} else {
						$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
					}
					if {($this_mode == 0) || ($this_mode == 3)} {
						$papag.parameters.output.editqik config -text "Nudge" -command "MixCrossNudge curtail" -bd 2 -state normal
					} else {
						$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
					}
				} \
				^$evv(ENV_DOVETAILING)$ {
					set invlist [FindSndfilesChosen]
					if {[llength $invlist] > 0} {
						if {$snack_enabled && (![info exists bulk(run)] || ($bulk(run) == 0))} {
							$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOR)
						} else {
							$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
							SnackRecolor $invlist 1
						}
					} else {
						$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
					}
					if {($this_mode == 0) || ($this_mode == 3)} {
						$papag.parameters.output.editqik config -text "Nudge" -command "MixCrossNudge curtail" -bd 2 -state normal
					} else {
						$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
					}
				} \
				^$evv(SAUSAGE)$ {
					set invlist [FindSndfilesChosen]
					if {[llength $invlist] > 0} {
						$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
						SnackRecolor $invlist 0
					} else {
						$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
					}
					$papag.parameters.output.editqik config -text  "Str->Sq" \
						-command "StretchToSqueeze 1" -bd 2 -state normal
				} \
				^$evv(WRAPPAGE)$ {
					set invlist [FindSndfilesChosen]
					if {[llength $invlist] > 0} {
						$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
						SnackRecolor $invlist 0
					} else {
						$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
					}
					$papag.parameters.output.editqik config -text  "Str->Sq" \
						-command "StretchToSqueeze 3" -bd 2 -state normal
				} \
				^$evv(BRASSAGE)$ {
					set invlist [FindSndfilesChosen]
					if {[llength $invlist] > 0} {
						$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
						SnackRecolor $invlist 0
					} else {
						$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
					}
					if {$mmod == 2 || $mmod == 6} {
						$papag.parameters.output.editqik config -text  "Str->Sq" \
							-command "StretchToSqueeze 0" -bd 2 -state normal
					} elseif {$mmod == 7} {
						$papag.parameters.output.editqik config -text  "Str->Sq" \
							-command "StretchToSqueeze 1" -bd 2 -state normal
					}
				} \
				^$evv(DRUNKWALK)$ {
					if {$sndgraphics && ($mmod == 1)} {
						$papag.parameters.output.editsrc config -text "MakeLocus" -command "Booze" -bd 2 -state normal
					} else {
						$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
						set invlist [FindSndfilesChosen]
						if {[llength $invlist] > 0} {
							$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
							SnackRecolor $invlist 0
						} else {
							$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
						}
					}
				} \
				^$evv(P_APPROX)$ - \
				^$evv(P_EXAG)$ - \
				^$evv(P_QUANTISE)$ - \
				^$evv(P_RANDOMISE)$ - \
				^$evv(P_SMOOTH)$ - \
				^$evv(P_TRANSPOSE)$ - \
				^$evv(P_VIBRATO)$ - \
				^$evv(P_SYNTH)$ - \
				^$evv(P_VOWELS)$ - \
				^$evv(P_INVERT)$ {
					set invlist [FindSndfilesChosen]
					if {[llength $invlist] > 0} {
						$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal -width 8
						SnackRecolor $invlist 0
					} else {
						$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled -width 8
					}
					if {[info exists bulk(run)] && ($bulk(run) == 1)} {
						$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
					} else {
						$papag.parameters.output.editqik config -text "Details" -command "PitchDetails" -bd 2 -state normal -width 11
					}
				} \
				^$evv(SPLIT)$ {
					set version [GetVersionNumber $evv(SPLIT)]
					if [VersionExceeds 5.0.0 $version] {
						$papag.parameters.output.editqik config -text "Draw" -command "Dlg_MakeEqDatafile 0" -bd 2 -state normal -width 11
					} else {
						$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
					}
					set invlist [FindSndfilesChosen]
					if {[llength $invlist] > 0} {
						$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal -width 8
						SnackRecolor $invlist 0
					} else {
						$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled -width 8
					}
				} \
				^$evv(PSOW_EXTEND)$ {
					set invlist [FindSndfilesChosen]
					if {[llength $invlist] > 0} {
						$papag.parameters.output.playsrc config -text "Snd View" -command "SnackView 1" -bd 2 -state normal -bg $evv(SNCOLOR)
						$papag.parameters.output.editsrc config -text "VibLocal" -command "LocalVib" -bd 2 -state normal -width 8
						$papag.parameters.output.editqik config -text "Artic" -command "Articulate" -bd 2 -state normal -width 8
						catch {file delete $articvw}
						catch {unset articorigdata}
						catch {PurgeArray $articvw}
					} else {
						$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled -width 8
						$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
					}
				} \
				^$evv(MCHANPAN)$ {
					set invlist [FindSndfilesChosen]
					if {$mmod == 1} {
						$papag.parameters.output.editqik config -text "Rotation" -command "MchanpanRotate" -bd 2 -state normal -width 8	
					} else {
						$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled -width 8
					}
					$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
					SnackRecolor $invlist 0
				} \
				^$evv(BAKTOBAK)$ {
					set invlist [FindSndfilesChosen]
					if {[llength $invlist] > 0} {
						if {$snack_enabled} {
							$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 1" -bd 2 -state normal -bg $evv(SNCOLOR)
						} else {
							$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
							SnackRecolor $invlist 1
						}
					} else {
						$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled -width 8
					}
					$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled -width 8
				} \
				^$evv(SYNTH_WAVE)$ {
					$papag.parameters.output.editqik config -text "FileDur" -command "SynthDurInFile wave" -bd 2 -state normal -width 8
				} \
				^$evv(SYNTH_NOISE)$ {
					$papag.parameters.output.editqik config -text "FileDur" -command "SynthDurInFile noise" -bd 2 -state normal -width 8
				} \
				^$evv(SYNTH_SPEC)$ {
					$papag.parameters.output.editqik config -text "FileDur" -command "SynthDurInFile spec" -bd 2 -state normal -width 8
				} \
				^$evv(GRAIN_COUNT)$		- \
				^$evv(GRAIN_GET)$		- \
				^$evv(GRAIN_REVERSE)$	- \
				^$evv(GRAIN_REORDER)$	- \
				^$evv(GRAIN_DUPLICATE)$	- \
				^$evv(GRAIN_REPITCH)$	- \
				^$evv(GRAIN_RERHYTHM)$	- \
				^$evv(GRAIN_REMOTIF)$	- \
				^$evv(GRAIN_TIMEWARP)$	- \
				^$evv(GRAIN_OMIT)$		- \
				^$evv(GRAIN_POSITION)$	- \
				^$evv(GRAIN_ALIGN)$	{
					set invlist [FindSndfilesChosen]
					if {[llength $invlist] > 0} {
						$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
						SnackRecolor $invlist 0
					} else {
						$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
					}
					$papag.parameters.output.editqik config -text "BestGate" -command "SetGoodGate" -bd 2 -state normal -width 8
				} \
				^$evv(RETIME)$	{
					set invlist [FindSndfilesChosen]
					switch -- $mmod {
						2 {
							if {[llength $invlist] > 0} {
								$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
								SnackRecolor $invlist 0
							}
							$papag.parameters.output.editqik config -text "Infile MM" -command "GetInMM" -bd 2 -state normal
						}
						5 {
							$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOR)
							$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
						}
						8 -
						14 {
							$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 1" -bd 2 -state normal -bg $evv(SNCOLOR)
							$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
						}
						default {
							if {[llength $invlist] > 0} {
								$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
								SnackRecolor $invlist 0
							}
							$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
						}
					}
				} \
				^$evv(MOD_LOUDNESS)$ {
					if {$mmod == 1} {
						$papag.parameters.output.editqik config -text "Scale" -command {ScaleEnvelope} -bd 2 -state normal
						set invlist [FindSndfilesChosen]
						if {[llength $invlist] > 0} {
							if {$snack_enabled && [IsSingleEditType $pprg]} {
								$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOR)
							} elseif {$snack_enabled && [IsSingleMarkType $pprg]} {
								$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 1" -bd 2 -state normal -bg $evv(SNCOLOR)
							} else {
								$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
								SnackRecolor $invlist 0
							}
						} else {
							$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
						}
					} else {
						$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
						set invlist [FindSndfilesChosen]
						if {[llength $invlist] > 0} {
							if {$snack_enabled && [IsSingleEditType $pprg]} {
								$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOR)
							} elseif {$snack_enabled && [IsSingleMarkType $pprg]} {
								$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 1" -bd 2 -state normal -bg $evv(SNCOLOR)
							} else {
								$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
								SnackRecolor $invlist 0
							}
						} else {
							$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
						}
					}
				} \
				^$evv(HOVER2)$ {
					set invlist [FindSndfilesChosen]
					if {[llength $invlist] > 0} {
						if {$snack_enabled} {
							$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOR)
						} else {
							$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
							SnackRecolor $invlist 0
						}
					} else {
						$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
					}
				} \
				^$evv(INFO_MAXSAMP2)$ {
					$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
					set invlist [FindSndfilesChosen]
					if {[llength $invlist] > 0} {
						if {$snack_enabled} {
							$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOR)
						} else {
							$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
							SnackRecolor $invlist 0
						}
					} else {
						$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
					}
				} \
				default {
					$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
					set invlist [FindSndfilesChosen]
					if {[llength $invlist] > 0} {
						if {$snack_enabled && [IsSingleEditType $pprg]} {
							$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOR)
						} elseif {$snack_enabled && [IsSingleMarkType $pprg]} {
							$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 1" -bd 2 -state normal -bg $evv(SNCOLOR)
						} else {
							$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
							SnackRecolor $invlist 0
						}
					} else {
						$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
					}
				}

			set tshifter [IsTimeStretchingProcess $pprg $mmod]
			if {$tshifter > 0} {
				$papag.parameters.output.editsrc config -text "TempoShift" -command "TempoShift 0 $tshifter" -bd 2 -state normal -bg [option get . background {}]
			}
			if {$pprg == $evv(TSTRETCH) && ($mmod == 1)} {
				$papag.parameters.output.editqik config -text "0.01sec->" -command "ShuffleBrk" -bd 2 -state normal -bg [option get . background {}]
			}
		}
	}
	if {$gdg_creat_fail || $bombout} {
		set from_runpage 0
		return
	}
 	$papag.parameters.buttons.info config -command "CDP_Specific_Usage $pprg $mmod"
 	$papag.parameters.buttons.orig config -text "" -borderwidth 0 -state disabled

	SetButtonsStartState $papag.parameters			;#	Disable the output-action buttons

	if {$hst(active)} {
		EstablishHistoricalParams					;#	If running a previous process with RECALL
	}												;#	Put it's params into the prm dialog boxes
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
	MACMessage 3
	if {[info exists pseudoprog] && ($pseudoprog == $evv(ELASTIC))} {
		set msg "Enter Time Stretch First.\n\n"
		append msg "Then Use \"Snd View\" Page To Enter\nEither\n"
		append msg "2 Times : Time At Which Stretching Starts + Time Where Stretch Reaches Max\n"
		append msg "OR\n"
		append msg "Sets Of 4-Times, Each Being : Stretch Start, Stretch-Reaches-Max, Stretch-Max End, Stretch Ends."
		Inf $msg
	}
	while {!$finished} {
		tkwait variable pr3
		if {$pr3} {									;#	If a program has been run succesfully
			if {$ins(create)} {
				if {$prg_ocnt > 0} { 				;#	If outfiles from this process
					RememberSpecOfVariableInsParams	;#	These could be changed, if program rerun with new params
					set ins(data_stored) 0			;#	Mark that process-data is not yet saved

				} else {							;#	If no outfiles
													;#	Instrument forgets about process
					incr ins(process_cnt) -1
					$papag.parameters.output.keep config -text "Continue" -command GetNewFilesFromPpg
					EnableOutputButtons $papag.parameters.output $papag.parameters.zzz.newp \
						$papag.parameters.zzz.newf
				}
			}
			if {[info exists panprocess]} {
				switch -- $panprocess {
					1 {
						incr panprocess
						Inf "Return To Workspace And Select \"Pan A Process\" From \"Multichannel Pan\" On The Multichan Menu"
						set prg_ocnt 0
						set finished 1
					}
					2 {
						Inf "Impossible!"
						unset panprocess
						catch {unset panprocessfnam}
						catch {unset panprocess_individ}
						set prg_ocnt 0
					}
					3 {
						set prg_ocnt 1
						unset panprocess
						catch {unset panprocessfnam}
						catch {unset panprocess_individ}
					}
				}
			}
			if {$prg_ocnt > 0} {					;#	Includes activating KEEP button
				set has_played 0					;#	Normal mode: outfiles saved on pressing KEEP button
				set has_viewed 0
				set has_read 0
				set has_saved 0

				if {$ins(create)} {
					$papag.parameters.output.keep config -text "Keep" -command KeepOutput
				} elseif {[info exists mchengineer]} {
					$papag.parameters.output.keep config -text "Keep" -command KeepOutput
					$papag.parameters.output.run config -state disabled
				} else {
					$papag.parameters.output.keep config -text "Save As" -command KeepOutput
				}
				if {($pprg == $evv(MIX)) || ($pprg == $evv(MIXMULTI))} { 
					if {$ins(create)} {
						set inmix [lindex $ins(chlist) 0]
					} else {
						set inmix [lindex $chlist 0]
					}
					if {![Flteq $prm(1) $pa($inmix,$evv(DUR))] || ($prm(0) > 0.0)} {
						$prmgrd.mixwarn config -text "INCOMPLETE MIX" -fg red
						DovetailIncompleteMix $inmix
					} else {
						$prmgrd.mixwarn config -text ""
					}
				}
				EnableOutputButtons $papag.parameters.output $papag.parameters.zzz.newp $papag.parameters.zzz.newf
			}											;#	Instrumentcreate mode: Process-data saved on pressing KEEP
														;#	Either KEEP in createInstrument-mode has been pressed
			MACMessage 5
#MOVED NOVEMBER 2001
			if {$pprg != $evv(MIXMAX)} {
				catch {unset mixmaxnorm}
			}
		} else {
			AdjustAgainLabel
			RememberLastRunVals
			set finished 1							
		}

		if {$finished && [QuittingProcessWithNoSave]} {
			set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] \
					-message "Discard the output file(s)?"]
			if [string match no $choice] {
				set finished 0
			} else {
				set has_saved 1							;#	Prevents Recycle recursion from repeating "Discard" question
			}
		}
	}
	catch {unset pseudoprog}
	if {[info exists pim] && [info exists $pim]} {		;#	If start with hst, menupage may not exist
		$pim.help.help config -text "$evv(HELP_DEFAULT)"  -fg [option get . foreground {}]
	}													   
    set is_crypto 0
	if {!$ins(create) && ![info exists panprocess] && ![info exists mchengineer]} {
		DeleteAllTemporaryFiles
	}
	My_Release_to_Dialog .ppg							;#	Return focus to previous dialog
	Dlg_Dismiss .ppg									;#	Hide the dialog
	if [info exists do_repost] {
		set x 0
		after 500 {set x 1}
		vwait x
		RepostMenu
		unset do_repost
	}
	set from_runpage 0
}

#------ Adjust 'Again' button name when going from Param page to Process page directly.

proc AdjustAgainLabel {} {
	global ins procmenu_emph pim evv

	if {[info exists pim] && [info exists $pim]} {
		if {$ins(was_last_process_used)} {
			$pim.topbtns.again config -text "Use Instr Again" -state normal -bg $evv(EMPH)
		} else {
			$pim.topbtns.again config -text "Use Process Again" -state normal -bg $evv(EMPH)
		}
		if {![info exists procmenu_emph] || ([lsearch -exact $procmenu_emph $pim.topbtns.again] < 0)} {
			lappend procmenu_emph $pim.topbtns.again
		}
	}
}

#----- Up, Down Arrows work on param entry boxes

proc EstablishRollingFocus {} {
	global gdg_cnt entry_exists prmgrd

	set i 0
	set j 0
	set entry_focus ""
	if {$gdg_cnt <= 0} {
		return $entry_focus
	}
	while {$i < $gdg_cnt} {
		if {$entry_exists($i)} {
			lappend entries $i
			if {$j == 0} {
				set first_entry $i
			}
			set last_entry $i
			incr j
		}
		incr i
	}
	if {$j > 1} {
		foreach i $entries {
			set step [expr $i - $last_entry] 
			bind $prmgrd.e$i <Up> {}
			bind $prmgrd.e$i <Up> "RollFocusParams $i [expr -$step]"
			bind $prmgrd.e$last_entry <Down> {}
			bind $prmgrd.e$last_entry <Down> "RollFocusParams $last_entry $step"
			set last_entry $i
		}
	}
	if {$j > 0} {
		set entry_focus $prmgrd.e$first_entry
	}
	return $entry_focus
}

proc RollFocusParams {foc val} {
	global gdg_cnt prmgrd
	incr foc $val
	set foc [expr $foc % $gdg_cnt]
	focus $prmgrd.e$foc
}

#------ Repost a previously-selected menu, on returning to the Process Page

proc RepostMenu {} {
	global chosen_men
	if [info exists chosen_men] {
		PostMenu $chosen_men
	}
}

#------ Enable buttons appropriate to type of output

proc EnableOutputButtons {po newp newf} {
	global sndsout asndsout smpsout txtsout vwbl_sndsysout ppg_emph ins_creation papag ins pprg mmod evv
	global singleform bulk

	set singleform 0
	set thismode $mmod
	incr thismode -1

	$po.oput config -text "OUTPUT "
	$po.keep config -state normal -bg $evv(EMPH) -fg $evv(SPECIAL)	;#	Enable the file keep button
	$po.props config -state normal												;#	Enable the file props button
	$po.mxsmp config -state normal												;#	Enable the file props button
	$newp config -bg $evv(EMPH)
	$newf config -bg $evv(EMPH)

	catch {unset ppg_emph}
	lappend ppg_emph $newp $newf $po.keep

	if {$sndsout > 0 || $asndsout > 0} {
		$po.play config -state normal -bg $evv(EMPH)
		lappend ppg_emph $po.play
	}
	if {$smpsout > 0} {
		$po.mxsmp config -state normal
	}
	if {$txtsout > 0} {							;#	Enable the read button
		$po.read config -state normal -bg $evv(EMPH)
		lappend ppg_emph $po.read
	}
	if { $vwbl_sndsysout > 0} { 	 		;#	Enable the view button
		$po.view config -state normal -bg $evv(EMPH)
		lappend ppg_emph $po.view
	}
	if {($pprg == $evv(ONEFORM_GET)) && !$bulk(run)} { 	 ;#	Enable the view button
		if {[file exists [file join $evv(CDPROGRAM_DIR) vuform$evv(EXEC)]]} {
			set singleform 1
			$po.view config -state normal -bg $evv(EMPH)
			lappend ppg_emph $po.view
		}
	}
	if {!$ins(run) } {
		if {($pprg == $evv(EQ)) || ($pprg == $evv(LPHP)) || ($pprg == $evv(FSTATVAR)) \
		|| ($pprg == $evv(FLTBANKN)) || ($pprg == $evv(FLTBANKU)) || ($pprg == $evv(FLTBANKV))  || ($pprg == $evv(FLTBANKV2)) \
		|| ($pprg == $evv(FLTSWEEP)) || ($pprg == $evv(FLTITER)) || ($pprg == $evv(ALLPASS)) || ($pprg == $evv(SYNFILT))} {
			$papag.parameters.output.editqik config -bd 2 -text "Gain" -command "FilterAtten" -bg $evv(EMPH) -state normal
		} elseif {$pprg == $evv(PSOW_FEATURES)} {
			$papag.parameters.output.editqik config -bd 2 -text "Gain" -command "GainParamAtten psow" -bg $evv(EMPH) -state normal
		} elseif {($pprg == $evv(MOD_REVECHO)) && ($thismode == 2)} {
			$papag.parameters.output.editqik config -bd 2 -text "Gain" -command "GainParamAtten stadium" -bg $evv(EMPH) -state normal
		} elseif {$pprg == $evv(MCHANREV)} {
			$papag.parameters.output.editqik config -bd 2 -text "Gain" -command "GainParamAtten stadium" -bg $evv(EMPH) -state normal
		} elseif {($pprg == $evv(HOUSE_EXTRACT)) && ($thismode == 2)} {
			$papag.parameters.output.editqik config -bd 2 -text "CutBy" -command "TopnTailResult" -bg $evv(EMPH) -state normal
		}
	}
}

#------ Read data output from CDParams

proc AccumulateParameterSpecs {} {
	global badparamspec CDPid param_spec params_got

	if [eof $CDPid] {
		catch {close $CDPid}				 
		return
	} else {
		gets $CDPid line
		set str [string trim $line]
		if [string match ERROR:* $line] {
			set str [string range $line [string first "ERROR:" $line] end] 
			set badparamspec 1
			set params_got 1
			ErrShow $str
			catch {close $CDPid}				 
		} elseif [string match WARNING:* $line] {
			set str [string range $line [string first "WARNING:" $line] end] 
			Inf $str
		} elseif [string match ENDPARAMS* $line] {
			set params_got 1
			catch {close $CDPid}
		} else {
			lappend param_spec $line				;#	Groups-of-parameter-characteristics listed in order
		}											;#	(saved: In case ins requires them)			
	}
}

#------ Disable output buttons, when new process is selected, and no process has yet been run.

proc SetButtonsStartState {fpr} {
	global prg_ran_before ppg_emph ins pprg mmod evv
	set thismode $mmod
	incr thismode -1
	catch {unset ppg_emph}
	$fpr.output.play    config -state disabled -bg [option get . background {}]
	$fpr.output.view    config -state disabled -bg [option get . background {}]
	$fpr.output.read    config -state disabled -bg [option get . background {}]
	$fpr.output.keep    config -state disabled -bg [option get . background {}]	-fg [option get . foreground {}]
	$fpr.output.keep    config -state disabled -bg [option get . background {}]	-fg [option get . foreground {}]
	$fpr.output.oput    config -text ""
	$fpr.output.props   config -state disabled
	$fpr.output.mxsmp   config -state disabled
 	$fpr.output.run 	config -state normal -bg $evv(EMPH)
	lappend ppg_emph $fpr.output.run
 	$fpr.buttons.reset  config -state normal
 	$fpr.buttons.repen  config -state normal
 	$fpr.buttons.dflt   config -state normal
	if {$ins(run)} {
 		$fpr.buttons.orig   config -state normal
	}
 	$fpr.zzz.newp config -state normal
 	$fpr.zzz.newf config -state normal
	if {$prg_ran_before > 0} {
	 	$fpr.zzz.newp config -bg $evv(EMPH)
	 	$fpr.zzz.newf config -bg $evv(EMPH)
		lappend ppg_emph $fpr.zzz.newp $fpr.zzz.newf
	} else {
	 	$fpr.zzz.newp config -bg [option get . background {}]
	 	$fpr.zzz.newf config -bg [option get . background {}]
	}
	if {!$ins(run)} {
		if {($pprg == $evv(EQ)) || ($pprg == $evv(FSTATVAR)) \
		|| ($pprg == $evv(FLTBANKN)) || ($pprg == $evv(FLTBANKU)) || ($pprg == $evv(FLTBANKV2)) \
		|| ($pprg == $evv(FLTSWEEP)) || ($pprg == $evv(FLTITER)) || ($pprg == $evv(ALLPASS)) \
		|| ($pprg == $evv(LPHP)) || ($pprg == $evv(PSOW_FEATURES)) || (($pprg == $evv(MOD_REVECHO)) && ($thismode == 2)) \
		|| (($pprg == $evv(HOUSE_EXTRACT)) && ($thismode == 2)) || ($pprg == $evv(MCHANREV))} {
			$fpr.output.editqik config -bd 0 -text "" -command {} -bg [option get . background {}]
		}
		if {$pprg == $evv(FLTBANKV)} {
			$fpr.output.editqik config -text "Randomise" -command ScatterFilter -bd 2 -state normal
		}
	}
}

#------ Disable load- & delete-patch buttons

proc DisablePatchButtons {pd} {
 	$pd.load   config -state disabled
	$pd.delete config -state disabled
}

#------ Establish the parameter dialog for both process and (do)ins
#
#	RUN RESET DEFAULTS	   		   QUIT |	LOAD	DELETE
#										|
# 	PLAY VIEW READ KEEP 		   		|	STORE	Patchname
#	------------------------------------|---------------------
#										|
#			Paramslist					|	 Patchlist
#										

proc Dlg_Params {p patch_ext} {
	global patchcnt pg_spec gdg_cnt pr3 pr2 new_patchname prmgrd p_l ins evv gadget_msg
	global prg pprg mmod selected_menu cdpmenu ppg_actv ppg_hlp_actv infcnt small_screen papag
	global gdg_creat_fail gadgets_created chlist do_repost p_pg is_crypto cur_patch cur_patch_display sl_real
	global menuinverse readonlyfg readonlybg mix_last_preset onpage_oneatatime mchengineer param_last_preset

	catch {destroy .cpd}

	if {$small_screen} {
		set can [Scrolled_Canvas $p.c -width $evv(SMALL_WIDTH) -height $evv(SMALL_HEIGHT) \
							-scrollregion "0 0 $evv(PARAMS_WIDTH) $evv(SCROLL_HEIGHT)"]
		pack $p.c -side top -fill x -expand true
		set f [frame $can.f -bd 0]
		$can create window 0 0 -anchor nw -window $f
		set papag $f
	} else {
		set papag $p
	}	

	set gdg_cnt 0
	catch {unset cur_patch}	
	if [info exists pg_spec] {
		set gdg_cnt [llength $pg_spec]
	}
	#	HELP AND QUIT

	set help [frame $papag.help -borderwidth $evv(SBDR)]
	button $help.ksh -text K -command "Shortcuts parampage" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $help.hlp -text Help -command "ActivateHelp $papag.help" -width 4 ;# -bg $evv(HELP) -highlightbackground [option get . background {}]
	label  $help.conn -text "" -width 13
	button $help.con -text "" -borderwidth 0 -state disabled -width 8 -highlightbackground [option get . background {}]
	label  $help.help -width 84 -text "$evv(HELP_DEFAULT)" -fg [option get . foreground {}]
	if {$evv(NEWUSER_HELP)} {
		button $help.starthelp -text "New User Help" -command "GetNewUserHelp parameters"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
	} else {
		button $help.star -text "What Value?" -command "StarCommand" -highlightbackground [option get . background {}]
	}
	button $help.kluj -text "Release Slider" -command SliderFix -highlightbackground [option get . background {}]
	button $help.quit -text "End Session" -command "DoWkspaceQuit 0 0"  -highlightbackground [option get . background {}];# -bg $evv(QUIT_COLOR)
	bind $papag <Control-Command-Escape> "DoWkspaceQuit 0 0"
	if {$evv(NEWUSER_HELP)} {
#MOVED TO LEFT
		pack $help.quit -side left
		pack $help.ksh $help.hlp $help.conn $help.con $help.help $help.starthelp -side left
#MOVED TO LEFT
#		pack $help.quit -side right
	} else {
#MOVED TO LEFT
		pack $help.quit -side left
		pack $help.ksh $help.hlp $help.conn $help.con $help.help -side left
#MOVED TO LEFT
#		pack $help.quit $help.star -side right -padx 2
		pack $help.star -side right -padx 2
	}
	pack $help.kluj -side right -padx 2

	# 	FRAMES FOR PARAMETERS & PATCHES

	set fpr [frame $papag.parameters -borderwidth $evv(SBDR)] 	;#	frame parameter lists
	frame $papag.spac -bg [option get . foreground {}] -width 1 -height 20

	set fpt [frame $papag.patches -borderwidth $evv(SBDR)]		;#	frame for patch lists

	;# PARAMETER FRAME CONTAINS...

	set zzz [frame $fpr.zzz -borderwidth $evv(SBDR)]		    ;#	frame for get new process
	frame $fpr.space -bg [option get . foreground {}] -height 1 -width 20
	set prl [frame $fpr.titles -borderwidth $evv(SBDR)]		;#	frame for title
	set pb  [frame $fpr.buttons -borderwidth $evv(SBDR)]		;#	frame for action buttons
	set po  [frame $fpr.output -borderwidth $evv(SBDR)]		;#	frame for output buttons
	set prd [frame $fpr.prd -borderwidth $evv(SBDR)]			;#	frame for Reset/Default titles
	set par [frame $fpr.par -borderwidth $evv(SBDR)]			;#	frame for parameter entry grid
	pack $fpr.zzz $fpr.space $fpr.titles $fpr.buttons  $fpr.output $fpr.prd $fpr.par -side top -fill both

	if {$gdg_cnt > 0} {
		set c [canvas $par.c -width 80 -height 10 -yscrollcommand [list $par.yscroll set] \
			-highlightthickness 1 -highlightbackground black]
		scrollbar $par.yscroll -orient vertical -command [list $par.c yview]
		pack $par.yscroll -side right -fill y
		pack $par.c -side left -fill both -expand true
		set prmgrd [frame $c.zorg]
		$c create window 0 0 -anchor nw -window $prmgrd
	}

	#	GET NEW PROCESS

 	button $zzz.newp -text "New Process" -width 16 -command "GetNewProcess 1" -highlightbackground [option get . background {}]
	if {[info exists onpage_oneatatime]} {
		button $zzz.newf -text "Next File" -width 16 -command {DoOneAtATimeFromParampage} -highlightbackground [option get . background {}]
	} elseif {[info exists mchengineer]} {
 		button $zzz.newf -text "Engineer" -width 16 -command {GetNewFilesFromPpg} -highlightbackground [option get . background {}]
	} else {
 		button $zzz.newf -text "To Wkspace" -width 16 -command {GetNewFilesFromPpg} -highlightbackground [option get . background {}]
	}
 	button $zzz.mabo -text "" -width 12 -command {}	-state disabled -borderwidth $evv(SBDR) -highlightbackground [option get . background {}]
	button $zzz.calc -text "Calculate" -width 8 -command "MusicUnitConvertor 2 0"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
	button $zzz.ref  -text "Reference" -width 8 -command "RefSee 1"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
	menubutton $zzz.nns  -text "Notebook" -menu $zzz.nns.m -relief raised  -width 12 ;# -background $evv(HELP)
	set m [menu $zzz.nns.m -tearoff 0]
	$m add command -label "Read / Edit" -command NnnSee -foreground black
	$m add separator
	$m add command -label "Keep Params" -command "NnnGetParams 0 0" -foreground black
	$m add command -label "Keep Params & Infiles" -command "NnnGetParams 1 0" -foreground black
	$m add command -label "Keep Params, Infiles & Outfile" -command "NnnGetParams 1 1" -foreground black
	if {!$sl_real} {
		button $zzz.aaa  -text "A" -bd 4 -command	TellA -width 2  -highlightbackground [option get . background {}];# -bg $evv(HELP)
	} else {
		button $zzz.aaa  -text "A" -bd 4 -command "PlaySndfile $evv(TESTFILE_A) 0" -width 2  -highlightbackground [option get . background {}];# -bg $evv(HELP)
	}
	button $zzz.tedit -text "Table Ed" -width 8  -command "set p_pg 1; TableEditor"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
	pack $zzz.newp $zzz.newf $zzz.mabo -side left
	pack $zzz.calc $zzz.tedit $zzz.ref -side right -padx 1
	pack $zzz.nns -side right -padx 1 -ipady 2
	pack $zzz.aaa -side right -padx 1

	# 	TITLE FOR PARAMETERS

	label $prl.params -text "PARAMETER VALUES FOR "
	if {$ins(run)} {
		set thistext "Instrument $ins(name)"
	} else {
		if {$is_crypto} {
			set thistext "[lindex $cdpmenu($selected_menu) $evv(MENUNAME_INDEX)] actually calling [string toupper [lindex $prg($pprg) $evv(PROGNAME_INDEX)]]"
		} elseif {[IsMchanToolkit $pprg]} {
			set thistext [MchanToolKitNames $pprg]
		} else {
			set thistext "[lindex $menuinverse $pprg] [lindex $prg($pprg) $evv(PROGNAME_INDEX)]"
		}
		if {$mmod > 0} {
			set mode_index $evv(MODECNT_INDEX)
			incr mode_index $mmod
			append thistext "...."
			append thistext [lindex $prg($pprg) $mode_index]
		}
	}
	set current_filecnt 0
	if {$ins(create) && [info exists ins(chlist)]} {
		set current_filecnt [llength $ins(chlist)]
		set current_file [lindex $ins(chlist) 0]
	} elseif [info exists chlist] {
		set current_filecnt [llength $chlist]
		if {$current_filecnt > 0} {
			set current_file [lindex $chlist 0]
		}
	}
	if {$current_filecnt > 0} {
		append thistext " : FILE "
		set current_file [string tolower [file tail $current_file]]
		append thistext $current_file
		if {$current_filecnt > 1} {
			append thistext "...ETC"
		}
	}

	label $prl.prgname -text $thistext -fg $evv(SPECIAL)
	pack $prl.params $prl.prgname -side top -fill x

	# 	PARAMETER ACTION BUTTONS

 	button $pb.reset -text "Reset Vals"     	 -width 8 -command "ResetPreviousRunParams" -highlightbackground [option get . background {}]
 	button $pb.repen -text "Penult Run Vals" 	 -width 14 -command "ResetPenultimateRunParams" -highlightbackground [option get . background {}]
	if {$ins(run)} {
 		button $pb.dflt  -text "Instr Defaults" -width 13 -command "ResetValues dfault" -highlightbackground [option get . background {}]
	} else {
 		button $pb.dflt  -text "Set Defaults" 	 -width 13 -command "ResetValues dfault" -highlightbackground [option get . background {}]
	} 
 	button $pb.orig  -text "" -width 14 -command "ResetValues ins_subdflt" -state disabled  -highlightbackground [option get . background {}]
 	button $pb.info -text "Info" -command "CDP_Specific_Usage $pprg $mmod"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
 	label  $pb.fcnt -text "No. of infiles"
 	button $pb.geti -text "See Textfiles" -command SeeTextfiles -highlightbackground [option get . background {}] 
 	entry  $pb.fcnte -textvariable infcnt -width 3 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
	pack $pb.reset $pb.repen $pb.dflt $pb.orig -side left
	pack $pb.info $pb.fcnte	$pb.fcnt $pb.geti -side right -padx 1

	# 	RUN & OUTPUT BUTTONS

 	button $po.run -text "Run"  -command "RunProgram $fpr" -bg $evv(EMPH) -highlightbackground [option get . background {}]
	catch {unset ppg_emph}
	lappend ppg_emph $po.run

	button $po.editsrc -text "" -width 8 -command {} -bd 0 -state disabled -highlightbackground [option get . background {}]
	button $po.editqik -text "" -width 8 -command {} -bd 0 -state disabled -highlightbackground [option get . background {}]
	button $po.playsrc -text "Play Src" -command "PlayInput" -width 6 -highlightbackground [option get . background {}]
	menubutton $po.propsrc -text "Src Props" -menu $po.propsrc.m -relief raised -width 10
	set m [menu $po.propsrc.m -tearoff 0]
	$m add command -label "All Props" -command "Show_Props inputfile_props 0" -foreground black
	$m add separator
	$m add command -label "Duration" -command "Show_Props inputfile_props dur" -foreground black
	$m add separator
	$m add command -label "Channels" -command "Show_Props inputfile_props chans" -foreground black
	$m add separator
	$m add command -label "Windowlen" -command "Show_Props inputfile_props winlen" -foreground black
	$m add separator
	$m add command -label "Maxsamp" -command "Show_Props inputfile_props maxsamp" -foreground black

	button $po.propmax -text "SrcMax" -command "GetMaxsamps 1 0" -width 5 -highlightbackground [option get . background {}]
	button $po.play -text  "Play" -command "PlayOutput 0"  -state disabled  -highlightbackground [option get . background {}]
	button $po.view -text  "View" -command "ViewOutput"  -state disabled -highlightbackground [option get . background {}]
	button $po.read -text  "Read" -command "ReadFile" -state disabled
	label $po.oput -text "" -fg $evv(SPECIAL) -width 8
	button $po.keep -text  "Save As" -command "KeepOutput" -state disabled -width 5 -highlightbackground [option get . background {}]
	button $po.props -text "Props" -command "Show_Props from_parampage 0" -state disabled -highlightbackground [option get . background {}]
	button $po.mxsmp -text "MaxSmp" -command "GetMaxsamps 0 1" -state disabled -highlightbackground [option get . background {}]

	pack $po.run $po.propmax -side left
	pack $po.propsrc -side left -ipadx 1 -ipady 1
	pack $po.playsrc $po.editsrc $po.editqik -side left
	pack $po.view $po.read $po.play $po.props $po.mxsmp $po.keep $po.oput -side right

	pack $papag.help -side top -fill both
	pack $papag.parameters $papag.spac $papag.patches -side left -fill both

	# 	PARAMETER ENTRY GADGETS, ON GRID

	bind $papag <Control-0> {}	;# Remove any existing bindings to paramgrid 
	bind $papag <Control-e> {}
	bind $papag <Control-E> {}
	if {$gdg_cnt > 0} {
		label $prd.res -text "Reset"
		label $prd.hms -text "ToSecs"
		label $prd.pen -text "LastRun"
		if {$ins(run)} {
			label $prd.def -text "Default"
			label $prd.ori -text "Original  "
		} else {
			label $prd.def -text "Default   "
		}
		pack $prd.res $prd.hms -side left
		if {$ins(run)} {
			pack $prd.ori $prd.def $prd.pen -side right
		}  else {
			pack $prd.def $prd.pen -side right
		}

		set gadget_msg {}
		if {![CreateGadgets]} {
			ErrShow "Gadget creation failed"
			set gdg_creat_fail 1
			return
		}
		if {$pprg == $evv(MIX)} {
			if {$mix_last_preset} {
				ResetPenultimateRunParams
			}
		} elseif {$param_last_preset} {
			ResetPenultimateRunParams
		}

#NEW FEB 2004
		# 	PATCH FRAME CONTAINS

		frame $fpt.dum0 -height 1 -bg [option get . foreground {}]
		set pn  [frame $fpt.name  -borderwidth $evv(SBDR)]	;#	frame for name of saved-patch
		frame $fpt.dum1 -height 1 -bg [option get . foreground {}]
		set ptl [frame $fpt.titles -borderwidth $evv(SBDR)]	;#	frame for title
		set pd  [frame $fpt.get   -borderwidth $evv(SBDR)]	;#	frame for load/delete buttons
		set pd2 [frame $fpt.get2   -borderwidth $evv(SBDR)]	;#	frame for subpatch menubutton
		set pp  [frame $fpt.plist -borderwidth $evv(SBDR)]	;#	frame for patchlisting
		set px  [frame $fpt.current -borderwidth $evv(SBDR)] ;#	frame for current patchname
		frame $fpt.dum2 -height 1 -bg [option get . foreground {}]
		set ptl2 [frame $fpt.titles2 -borderwidth $evv(SBDR)]	;#	frame for title
		set py  [frame $fpt.batch -borderwidth $evv(SBDR)] ;#	frame for patch-to-batch
		set py1  [frame $fpt.batch.1 -borderwidth $evv(SBDR)] ;#	frame for patch-to-batch
		set py2  [frame $fpt.batch.2 -borderwidth $evv(SBDR)] ;#	frame for patch-to-batch
		pack $py1 $py2 -side left
		pack $fpt.dum0 -side top -fill x -expand true
		pack $fpt.name -side top -fill x
		pack $fpt.dum1 -side top -fill x -expand true
		pack $fpt.titles $fpt.get $fpt.get2 $fpt.plist $fpt.current -side top -fill x
		pack $fpt.dum2 -side top -fill x -expand true -pady 3
		pack $fpt.titles2 $fpt.batch -side top -fill x

#NOV 1999 MOVED PATCH STUFF TO FOOT OF FUNCTION

		set rowcnt $gdg_cnt
		incr rowcnt $gdg_cnt
		set goal $gdg_cnt
		incr goal -1	
		set child $prmgrd.no$goal		;#	PROBLEM IF DEFAULT SRATE IS FIRST GADGET.. never set!!

		tkwait visibility $child

		set bbox [grid bbox $prmgrd 0 0]
		set incr [lindex $bbox 3]

		set thisrow 0
		while {$thisrow < $rowcnt} {
			grid rowconfigure $prmgrd $thisrow -minsize $incr
			incr thisrow
		}
		incr incr $incr
		set scrinc [expr $incr + 1.4]	;#TRYING TO GET SCROLLBAR TO STEP NICELY: FUDGE
		set width [winfo reqwidth $prmgrd]
		set height [winfo reqheight $prmgrd]
		incr height 53		;#	KLUDGE ... Final param in RRRR_EXTEND is mot being displayed, but don't see why!!
		$c config -scrollregion "0 0 $width $height"
		$c config -yscrollincrement $scrinc
		set height 406
		$c config -width $width -height $height

		if {($pprg == $evv(MIX)) || ($pprg == $evv(MIXMULTI))} { 
			label $prmgrd.mixwarn -text "" -fg red
			grid $prmgrd.mixwarn
		}
		#	PATCH STORE BUTTON & NAMING SPACE

		if {$ins(run)} {
			label $pn.lab -text "Name of\nPatch" -width 12
		} else {
			label $pn.lab -text "Name of\nPatch or Batch" -width 12
		}
		entry $pn.e -textvariable new_patchname -width 10
		pack $pn.lab -side left
		pack $pn.e -side right -fill x
		$pn.e xview moveto 1.0

		#	TITLE FOR PATCHES

		label $ptl.patches -text "PATCHES" -fg $evv(SPECIAL)
		pack $ptl.patches -side top -fill x

		#	PATCH LISTING

		set p_l [Scrolled_Listbox $pp.patchlist -width 12 -height 20 -selectmode single]

		# DISPLAY OF CURRENT IN-USE PATCH

		label $px.l -text "Current Patch"
		entry $px.e -textvariable cur_patch_display -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
  		pack $px.l $px.e -side left

		# TO BATCH

		if {!$ins(run)} {
			label $ptl2.batch -text "SAVE PROCESS TO BATCHFILE" -fg $evv(SPECIAL)
			button $py1.b1 -text "Save" -width 4 -command "Patch_to_Batch $patch_ext 0 0" -highlightbackground [option get . background {}]
			button $py1.b2 -text "Append" -width 6 -command "Patch_to_Batch $patch_ext 1 0" -bd 2 -highlightbackground [option get . background {}]

			button $py2.b1 -text "" -width 8 -command "Patch_to_Batch $patch_ext 0 1" -bd 0 -state disabled -highlightbackground [option get . background {}]
			button $py2.b2 -text "" -width 8 -command "Patch_to_Batch $patch_ext 1 1" -bd 0 -state disabled -highlightbackground [option get . background {}]
		} else {
			label $ptl2.batch -text "" -fg $evv(SPECIAL)
			button $py1.b2 -text "" -width 14 -command {} -bd 0 -highlightbackground [option get . background {}]
			button $py1.b1 -text "" -width 14 -command {} -bd 0 -highlightbackground [option get . background {}]
			button $py2.b2 -text "" -width 15 -command {} -bd 0 -highlightbackground [option get . background {}]
			button $py2.b1 -text "" -width 15 -command {} -bd 0 -highlightbackground [option get . background {}]
		}
		pack $ptl2.batch -side top -fill x
		pack $py1.b1 $py1.b2 -side top -pady 4
		pack $py2.b1 $py2.b2 -side top -pady 4

		#	GET & DELETE PATCH BUTTONS

 		button $pd.store  -text "Save"  -command "StorePatch $p_l $pd $patch_ext" -highlightbackground [option get . background {}]
 		button $pd.load   -text "Load"   -command "LoadPatch $p_l $patch_ext" -highlightbackground [option get . background {}]
		menubutton $pd2.subp   -text "Subpatch" -menu $pd2.subp.m -relief raised -width 10
		set m [menu $pd2.subp.m -tearoff 0]
		$m add command -label "Save Subpatch" -command "Subpatch 1" -foreground black
		$m add separator
		$m add command -label "Load Subpatch" -command "Subpatch 0" -foreground black
		button $pd.delete -text "Delete" -command "DeletePatch $p_l $pd $patch_ext" -highlightbackground [option get . background {}]
		pack $pd.load $pd.store -side left
		pack $pd2.subp -side left
		pack $pd.delete -side right
		
		pack $pp.patchlist -side top -fill both

			## REDUNDANT INSTRUCTION ??		
		$p_l delete 0 end 							;# 	Clear the patches window
				;#	Patches are associated with relevant program by their extension number
		set patchcnt 0								;#	List and count any relevant patches								
		foreach patchname [lsort -dictionary [glob -nocomplain [file join $evv(PATCH_DIRECTORY) "*.$patch_ext"]]] {
			set patchname [file rootname [file tail $patchname]]
			$p_l insert end $patchname
			incr patchcnt								
		}
		if {$patchcnt == 0} {						;#	If no patches
			DisablePatchButtons $pd					;#	Disable load- & delete-patch buttons
		}		
	} elseif {!$ins(run)} {
		# 	PATCH FRAME CONTAINS

		set ptl [frame $fpt.titles -borderwidth $evv(SBDR)]	;#	frame for title
		set pn  [frame $fpt.name  -borderwidth $evv(SBDR)]	;#	frame for name of saved-patch
		set py  [frame $fpt.batch -borderwidth $evv(SBDR)] ;#	frame for patch-to-batch
		set py1  [frame $fpt.batch.1 -borderwidth $evv(SBDR)] ;#	frame for patch-to-batch
		set py2  [frame $fpt.batch.2 -borderwidth $evv(SBDR)] ;#	frame for patch-to-batch
		pack $py1 $py2 -side left
		pack $fpt.name $fpt.titles $fpt.batch -side top -fill x

		#	TITLE FOR PATCHES

		label $ptl.patches -text "BATCHES" -fg $evv(SPECIAL)
		pack $ptl.patches -side top -fill x

		# PATCH TO BATCH
		if {!$ins(run)} {
			button $py1.b1 -text "Save"   -width 11 -command "Patch_to_Batch $patch_ext 0 0" -highlightbackground [option get . background {}]
			button $py1.b2 -text "Append" -width 11 -command "Patch_to_Batch $patch_ext 1 0" -bd 2 -highlightbackground [option get . background {}]
			button $py2.b1 -text ""   -width 15 -command "Patch_to_Batch $patch_ext 0 1" -bd 0 -state disabled -highlightbackground [option get . background {}]
			button $py2.b2 -text "" -width 15 -command "Patch_to_Batch $patch_ext 1 1" -bd 0 -state disabled -highlightbackground [option get . background {}]
	  		pack $py1.b1 $py1.b2 -side top -pady 4
	  		pack $py2.b1 $py2.b2 -side top -pady 4
		}
		
		#	PATCH STORE BUTTON & NAMING SPACE

		label $pn.lab -text "Name\nof Batchfile" -width 4
		entry $pn.e -textvariable new_patchname -width 10
		pack $pn.lab -side left
		pack $pn.e -side right -fill x
		$pn.e xview moveto 1.0
	}
	if {!$evv(NEWUSER_HELP)} {
		SpaceBoxOrStarCommand
	}
	set cur_patch_display ""
	wm resizable $p 1 1
#NEW FEB 2004
	if {[info exists gadget_msg] && ([llength $gadget_msg] > 0)} {
		set msg ""
		foreach item $gadget_msg {
			append msg $item "\n"
		}
		Inf $msg
	}
	bind $papag <Control-Key-P> {UniversalPlay papag 0}
	bind $papag <Control-Key-p> {UniversalPlay papag 0}
	bind $papag <Key-space>		{UniversalPlay papag 0}
	bind $papag <Command-p> {ResetPenultimateRunParams}
	bind $papag <Command-P> {ResetPenultimateRunParams}
	bind $papag <Command-d> {ResetValues dfault}
	bind $papag <Command-D> {ResetValues dfault}
	bind $papag <Command-c> {PlayChannel 2}
	bind $papag <Command-C> {PlayChannel 2}
	if {[info exists ins(run)] && $ins(run)} {
		bind $papag <Control-q> {}
		bind $papag <Control-Q> {}
	} elseif {($patch_ext == $evv(MIX)) || ($patch_ext == $evv(MIXMULTI))} {
		bind $papag <Control-q> {EditSrcMixfile mix}
		bind $papag <Control-Q> {EditSrcMixfile mix}
	} else {
		bind $papag <Control-q> {}
		bind $papag <Control-Q> {}
	}
	bind $papag <Control-s> {SaveAction}
	bind $papag <Control-S> {SaveAction}

	bind $papag <Command-n> {AltN_Action}
	bind $papag <Command-N> {AltN_Action}
	bind $papag <Command-r> {AltR_Action}
	bind $papag <Command-R> {AltR_Action}

	bind $papag.parameters.buttons.fcnte <ButtonRelease> {SetFilecntParam}
#APR 2007
#	bind .ppg <Return> "KeyRun $papag.parameters.output.run"
	bind .ppg <Return> "ParamsReturnAction"
	bind .ppg <Escape> {Escape_Action}
}

#------ Read the output file(s)

proc ReadFile {} {
	global o_nam pr10 ins evv txtsout readoutlist read_prr wksp_cnt
	global pa wl from_runpage ins_concluding ins_file_lst from_shrink rhshfnam
	global has_read bulk ch from_chosen from_dirl dl hidden_dir

	set has_read 1
	if {($from_runpage || $ins_concluding)} {
		if {$txtsout == 0} {
			ErrShow "No Textfiles to read: Program Error in enabling buttons"
			return
		}
		if {($txtsout == 1) && [DoSingleFile read]} {
			return
		}
	} else {
		if {$from_chosen} {	  ;# Chosenfile list
			foreach fnam [$ch get 0 end] {
				if {$pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)} { 
					lappend flist $fnam
				}
			}
			if {![info exists flist]} {	 ;# If no textfiles, just ignore this call
				set from_chosen 0
				return
			} elseif {[llength $flist] == 1} {
				SimpleDisplayTextfile $flist
				set from_chosen 0
				return
			}
		} elseif {$from_dirl} {	  ;# Directory listing
			set i [$dl curselection]
			set fnam [$dl get $i]
			if {[string length $hidden_dir] > 0} {
				set fnam [file join $hidden_dir $fnam]
			}
			SimpleDisplayTextfile $fnam
			return
		} elseif {$from_shrink} {	  ;# Shrink facility
			DisplayTextfile $rhshfnam($from_shrink)
			return
		} else {	;# workspace
			set i [$wl curselection]
			if {[llength $i] <= 0} {
				if {$wksp_cnt > 0} {
					set fnam [$wl get 0]
				} else {
					Inf "No File Selected"
					return
				}
			} else {
				set fnam [$wl get [lindex $i 0]]
			}
			if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} { 
				Inf "$fnam Is Not A Textfile"
				return
			}
			DisplayTextfile $fnam
			return
		}
	}
	set f .readoutlist
	if [Dlg_Create $f "Textfiles" "set pr10 1" -borderwidth $evv(BBDR)] {
		set b [frame $f.button -borderwidth $evv(SBDR)]
		set r [frame $f.reader -borderwidth $evv(SBDR)]
		set read_prr [Scrolled_Listbox $r.readlist -width 128 -height 32 -selectmode single]
		button $b.read -text "Read" -command "ReadSelectedTextfile $read_prr" -highlightbackground [option get . background {}]
		button $b.sort -text "Sort" -command "ListSort $read_prr" -highlightbackground [option get . background {}]
		button $b.quit -text "Close" -command "set pr10 1" -highlightbackground [option get . background {}]
		pack $b.read $b.sort -side left -padx 1
		pack $b.quit -side right
		pack $r.readlist -side top -fill both
		pack $f.button $f.reader -side top -fill x
		wm resizable $f 1 1
		bind $f <Return> {set pr10 1}
		bind $f <Escape> {set pr10 1}
		bind $f <Key-space> {set pr10 1}
	}
	$read_prr delete 0 end
	bind .readoutlist <ButtonRelease-1> {HideWindow %W %x %y pr10}

	if {$from_runpage} {
		if {$ins(run) || $bulk(run)} {
			set namegroup $evv(MACH_OUTFNAME)	;#	Collects outputs from ALL ins-processes
		} else {
			set namegroup $o_nam				 ;#	Collects normal outs, or current Instrumentcreateprocess outs
		}
		append namegroup "*"
		foreach fnam [lsort -dictionary [glob -nocomplain $namegroup]] {	
			if {$pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)} { 
				$read_prr insert end $fnam
			}
		}					
	} elseif {$ins_concluding} {
		foreach fnam [$ins_file_lst get 0 end] {
			if {$pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)} { 
				$read_prr insert end $fnam
			}
		}
	} else {
		foreach fnam $flist {
			$read_prr insert end $fnam
		}
	}
	set pr10 0
	raise $f
	My_Grab 0 $f pr10 $f.reader.readlist

	if {$from_runpage} {
		wm geometry $f [ToRightThird .ppg $f]
	} elseif {$ins_concluding} {
		wm geometry $f [ToRightThird .inspage $f]
	} else {
		wm geometry $f [ToRightThird .workspace $f]
	}

	tkwait variable pr10
	set from_chosen 0
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#------ Read file selected

proc ReadSelectedTextfile {prr} {
	global from_runpage ins_concluding txtsout pa from_chosen evv

	if {$from_runpage || $ins_concluding} {
		set process_output 1
	} else {
		set process_output 0
	}

# NOVEMBER 2000

	set i 1
	if {$process_output} {
		if {$txtsout == 1} {
			set i 0
		}
	} else {
		set j 0
		foreach item [$prr get 0 end] {
			incr j
		}
		if {$j == 1} {
			set i 0
		}
	}
	if {$i} {
		set i [$prr curselection]
		if {[string length $i] <= 0} {
			Inf "No Item Selected"
			return
		}
	}
	set fnam [$prr get $i]

	if {$process_output} {
		if [ProcessGivesBrkfile] {
			if {![DisplayBrkfile $fnam 0]} {
				DisplayTextfile $fnam
			}
		} else {
			DisplayTextfile $fnam
		}
	} elseif {$from_chosen} {
		SimpleDisplayTextfile $fnam
	} else {
		DisplayTextfile $fnam
	}
}

#------ Output of process is a time/value brkpntfile

proc ProcessGivesBrkfile {} {
	global pprg mmod evv

	set mmode $mmod
	incr mmode -1

	switch -regexp -- $pprg \
		^$evv(MOD_SPACE)$ {
			if {$mmode == $evv(MOD_MIRRORPAN)} {
				return 1
			}
		} \
		^$evv(ENV_EXTRACT)$ - \
		^$evv(ENV_CREATE)$ {
			if {$mmode == $evv(ENV_BRKFILE_OUT)} {
				return 1
			}
		} \
		^$evv(REPITCHB)$ 	   - \
		^$evv(ENV_BRKTODBBRK)$ - \
		^$evv(ENV_DBBRKTOBRK)$ - \
		^$evv(ENV_ENVTOBRK)$   - \
		^$evv(ENV_ENVTODBBRK)$ - \
		^$evv(ENV_REPLOTTING)$ {
			return 1
		}

	return 0
}

#------ Display a named brkpoint file graphically

proc DisplayBrkfile {fnam possible} {
	global pr_showbrk bkc bsh bsh_list pa c_res evv
	global displ_c real_c brkfrm brk
	global zero

	set f .show_brkfile

	if [Dlg_Create $f "Breakpoint File" "set pr_showbrk 0" -borderwidth $evv(BBDR)] {
		set ff [frame $f.btns -borderwidth 0]
		label  $ff.lab	-text "This file can be edited from the workspace page"
		button $ff.ok 	-text "OK" -command "set pr_showbrk 0" -highlightbackground [option get . background {}]
		pack $ff.lab -side left
		pack $ff.ok -side right

		frame $f.priti1 -height 8 -width 20

		#	CANVAS AND VALUE LISTING

		set bsh(can) [canvas $f.c -height $bkc(height) -width $bkc(width) -borderwidth 0 \
			-highlightthickness 1 -highlightbackground $evv(SPECIAL)]
		frame $f.priti2 -height 20 -width 4
		set z [frame  $f.l -borderwidth $evv(SBDR)]
		set bsh_list [Scrolled_Listbox $z.ll -width 32 -height 32 -selectmode single]
		frame $bsh_list.f -bd 0
		pack $z.ll -side left -fill both -expand true
		pack $f.btns -side top -fill x 
		pack $f.priti1 -side top -fill both -expand true
		pack $f.c $f.priti2 $f.l -side left -fill both
		$bsh(can) create rect $bkc(rectx1) $bkc(recty1) $bkc(rectx2) $bkc(recty2) -tag outline
		bind $f <Return> {set pr_showbrk 0}
		bind $f <Escape> {set pr_showbrk 0}
		bind $f <Key-space> {set pr_showbrk 0}
	}
	wm resizable $f 1 1

	if {$possible} {
		wm title .show_brkfile "Possible Breakpoint File [file rootname [file tail $fnam]]"
	} else {
		wm title .show_brkfile "Breakpoint File [file rootname [file tail $fnam]]"
	}
	catch {$bsh(can) delete cline}  in
	catch {$bsh(can) delete points} in
	catch {$bsh(can) delete rangeinfo} in
	catch {$bsh(can) delete zinfo} in
	catch {$bsh(can) delete endinfo} in
	catch {$bsh(can) delete message} in
	catch {unset displ_c} in
	catch {unset real_c} in
	set brk(coordcnt) 0
	set brkfrm(lo) $pa($fnam,$evv(MINBRK))
	set brkfrm(hi) $pa($fnam,$evv(MAXBRK))
	set brkfrm(islog) 0
	set brk(range) [expr $brkfrm(hi) - $brkfrm(lo)]
	if [Flteq $brk(range) 0.0] {
		Inf "Insufficient Range Of Values To Display These Points Graphically"
		Dlg_Dismiss $f
		return 0
	}
	set brkfrm(endtime) $pa($fnam,$evv(DUR))
	if [Flteq $brkfrm(endtime) 0.0] {
		Inf "Insufficient Time Range To Display These Points Graphically"
		Dlg_Dismiss $f
		return 0
	}
	set brk(real_endtime) $brkfrm(endtime)

	Block "Getting Data"
	if {![GetReal_cFromFile $fnam]} {
		return 1
	}
	wm title .blocker  "PLEASE WAIT:      CALCULATING CONVERSION CONSTANTS"
	set brk(xdisplay_end) 		 $evv(XWIDTH)
	set brk(xdisplay_end_atedge) [expr int($brk(xdisplay_end) + $evv(BWIDTH))]				
	set brk(active_xdisplay_end) $evv(XWIDTH)
	EstablishGrafToRealConversionConstants
	SetupBrkfileDisplay_c							;#	Establish display-coords of points.
	set zero(exists) 0
	if {$brkfrm(lo) < 0.0 && $brkfrm(hi) > 0.0} {
		set zero(exists) 1
		CalcZerolineYcoord
		set y [expr int($zero(y) + $evv(BWIDTH))]
		$bsh(can) create line $evv(BWIDTH) $y $bkc(actual_xwidth_end) $y -tag zinfo
		$bsh(can) create text $bkc(zerotext_xposition) $y -text "0" -tag zinfo
	}
	$bsh(can) create text $evv(BWIDTH) $bkc(text_yposition) -text "0.0" -tag {zinfo}
	set righttext [StripTrailingZeros $brk(real_endtime)]
	$bsh(can) create text $brk(xdisplay_end_atedge) $bkc(text_yposition) -text $righttext -justify left -tag {endinfo}
	$bsh(can) create text $bkc(halfwidth) $bkc(text_yposition) -text $evv(TIME) -tag {endinfo}
	$bsh(can) create text $bkc(rangetext_xoffset) $bkc(rangetext) -text $evv(VALUE)

	if {$brkfrm(lo) > $bkc(rangetextmin)} {
		set lodisplay [string range $brkfrm(lo) 0 $evv(MAX_XCHAR)]
		if {[string range $lodisplay end end] == "."} {
			set newend [string length $lodisplay]
			incr newend -2				   		
			set lodisplay [string range $lodisplay 0 $newend]
		}
	} else {
		set lodisplay [MagDisplay $brkfrm(lo)]
	}
	$bsh(can) create text $bkc(rangetext_xoffset) $bkc(text_rangebot) -text $lodisplay -tag {rangeinfo}

	if {$brkfrm(hi) < $bkc(rangetextmax)} {
		set hidisplay [string range $brkfrm(hi) 0 $evv(MAX_XCHAR)]
		if {[string range $lodisplay end end] == "."} {
			set newend [string length $hidisplay]
			incr newend -2				   		
			set hidisplay [string range $hidisplay 0 $newend]
		}
	} else {
		set hidisplay [MagDisplay $brkfrm(hi)]
	}
	$bsh(can) create text $bkc(rangetext_xoffset) $bkc(text_rangetop) -text $hidisplay -tag {rangeinfo}

	catch {$bsh(can) delete points} in
	wm title .blocker  "PLEASE WAIT:      DRAWING GRAPH"
	foreach {x y} $displ_c {
		incr x $evv(BWIDTH)
		incr y $evv(BWIDTH)
		set xa [expr int($x + $evv(PWIDTH))]
		set ya [expr int($y + $evv(PWIDTH))]
		$bsh(can) create rect $x $y $xa $ya -fill black -tag points
	}
	catch {$bsh(can) delete cline} in
	foreach {x y} $displ_c {
		incr x $evv(BPWIDTH)
		incr y $evv(BPWIDTH)
		lappend line_c $x $y
	}
	eval {$bsh(can) create line} $line_c {-fill black} {-tag cline}
	$bsh_list delete 0 end
	set spacer "    "
	set resolen 14						  	;#	SYSTEM DEPENDENT, ???
	set resend $resolen
	incr resend -1
	wm title .blocker  "PLEASE WAIT:      LISTING POINTS"
	foreach {time val} $real_c {
		if [string match [string index $time 0] "."] {
			set nought "0"
			set time [append nought $time]
		}
		set timelen [string length $time]
		if {$timelen < $resolen} {			
			if {![string match *\.* $time]} {
				append time "."
				incr timelen 
			}
			set	x $resolen
			incr x -$timelen
			while {$x > 0} {
				append time "0"
				incr x -1
			}
		} elseif {$timelen > $resolen} {
			set time [string range $time 0 $resend]
		}
		append time $spacer $val
		$bsh_list insert end $time
	}
	UnBlock
	set pr_showbrk 0
	raise $f
	My_Grab 0 $f pr_showbrk											
	tkwait variable pr_showbrk
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return 1
}

#------ Display a named textfile

proc DisplayTextfile {fnam} {
	global pr11 pr10 text_sf prg_ocnt wl read_prr from_runpage do_parse_report evv
	global ins_concluding src rememd renam ch brk wstk pa propfiles_list user_text_extensions mixmanage from_shrink nesstype
	global chlist

	catch {destroy .cpd}
	set f .textdisplay
	if [Dlg_Create $f $fnam "set pr11 1" -borderwidth $evv(BBDR)] {
		set b  [frame $f.button -borderwidth $evv(SBDR)]
		set b2 [frame $f.button2 -borderwidth $evv(SBDR)]
		set s  [frame $f.see -borderwidth $evv(SBDR)]
		button $b.ok -text "Close (no edit)" -width 14 -command "set pr11 0" -highlightbackground [option get . background {}]
		button $b.ed -text "Edited Version" -width 14 -command "set pr11 1" -highlightbackground [option get . background {}]
		button $b.ss -text "Save As New File" -width 14 -command "set pr11 2" -highlightbackground [option get . background {}]
		button $b.calc -text "Calculator" -width 8 -command "MusicUnitConvertor 5 0"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
		button $b.ref  -text "Reference" -width 8 -command "RefSee $s.seefile"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
		button $b.a -bd 4 -text "A" -command "PlaySndfile $evv(TESTFILE_A) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
		label $b2.w   -text "(Data will not be saved to disk until you use SAVE AS)" -fg $evv(SPECIAL)
		pack $b.ok $b.ed $b.ss $b.ref $b.calc $b.a -side left -padx 3 -fill x
		pack $b2.w -side top
		set text_sf [text $s.seefile -width 128 -height 20 -yscrollcommand "$s.sy set"]
		scrollbar $s.sy -orient vert -command "$s.seefile yview"
		pack $s.seefile -side left -fill both -expand true
		pack $s.sy -side right -fill y -expand true
		pack $f.button $f.button2 $f.see -side top
		wm resizable $f 1 1
		bind $text_sf <Control-Key-p> {UniversalPlay text $text_sf}
		bind $text_sf <Control-Key-P> {UniversalPlay text $text_sf}
		bind $text_sf <Control-Key-g> {UniversalGrab $text_sf}
		bind $text_sf <Control-Key-G> {UniversalGrab $text_sf}
		bind $text_sf <Command-Up> {MoveValByOct $text_sf 1} 
		bind $text_sf <Command-Down> {MoveValByOct $text_sf 0} 
		bind $f <Escape> {set pr11 0}
	}
	wm title $f $fnam
	if {$from_runpage || $ins_concluding || $from_shrink} {
		.textdisplay.button2.w config -text "(Data will not be saved to disk until you use SAVE AS)"
		.textdisplay.button.ss config -text "" -command {} -bd 0 -state disabled
	} else {
		.textdisplay.button2.w config -text ""
		.textdisplay.button.ss config -text "Save As New File" -width 14 -command "set pr11 2" -bd 2 -state normal
	}

	set finished 0
	$text_sf delete 1.0 end								;#	Clear the filelist window

	set is_nessfile [IsAValidNessFile $fnam 1 0 0]
	if [catch {open $fnam r} fileId] {
		Inf $fileId							;#	If textfile cannot be opened
		return		
	}
	set qq 0
	set x_max 0
	while {[gets $fileId thisline] >= 0} {			;#	Read lines from textfile into text-listing, avoiding extra newline
		if {$qq > 0} {
			$text_sf insert end "\n"
		}
		$text_sf insert end "$thisline"
		set show_len [string length $thisline]
		if {$show_len > $x_max} {
			set x_max $show_len
		}
		incr qq
	}
	close $fileId
	if {$qq > 0} {
		Scrollbars_Reset $text_sf $f.see.sy 0 $qq $x_max
	}
	if {[info exists propfiles_list]} {
		set is_a_known_propfile [lsearch $propfiles_list $fnam]
	} else {
		set is_a_known_propfile -1
	}
	set pr11 0
	set save_mixmanage 0
	set nessupdate 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr11 $f.see.seefile
	while {!$finished} {
		tkwait variable pr11						;#	Wait for OK to be pressed
		catch {unset is_a_propfile}
		catch {unset brk_is_set}
		if {$pr11} {
			set tmpfnam $evv(DFLT_TMPFNAME)
			if [catch {open $tmpfnam w} fileId] {
				Inf "Cannot Open Temporary File To Do Updating.\n"
			} else {
				puts -nonewline $fileId "[$text_sf get 1.0 end]"
				close $fileId
				set do_parse_report 1
				if {[DoParse $tmpfnam $wl 2 0] <= 0} {
					ErrShow "Parsing failed for edited file."
					if [catch {file delete $tmpfnam}] {
						Inf "Failed To Remove The File '$tmpfnam' : Delete By Hand For Safe Working."
					}
				} else {
					set origftyp $pa($fnam,$evv(FTYP))
					set newftyp $pa($tmpfnam,$evv(FTYP))
					if {$is_nessfile == 0} {
						set is_nessfile [IsAValidNessFile $tmpfnam 0 $is_nessfile 0]
					} else {
						set ntyp [IsAValidNessFile $tmpfnam 0 $is_nessfile 0]
						if {$ntyp != $is_nessfile} {
							set msg "THIS FILE IS NO LONGER A VALID PHYSICAL MODELLING DATA FILE:  KEEP IT??"
							set choice [tk_messageBox -type yesno -icon question -default no -parent [lindex $wstk end] -message $msg]
							if {$choice == "no"} {
								continue
							} else {
								set is_nessfile 0
							}
						}
					}
					if {[IsAMixfileIncludingMultichan $origftyp] && ![IsAMixfileIncludingMultichan $newftyp] } {
						set msg "The New File Is No Longer A Valid Mixfile: Do You Still Want To Keep It ?"
						set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							continue
						}
					} elseif {[IsABrkfile $origftyp] && ![IsABrkfile $newftyp]} {
						set msg "The New File Is No Longer A Numeric Brkfile: Do You Still Want To Keep It ?"
						set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							continue
						}
					} elseif {$is_a_known_propfile >= 0} {
						if {![IsThisAPropsFile $tmpfnam]} {
							set msg "$fnam Is No Longer A Properties File: Do You Still Want To Keep It As It Is ??"
							set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
							if {$choice == "no"} {
								continue
							} else {
								set k [lsearch $propfiles_list $fnam]
								set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
								if {[llength $propfiles_list] <= 0} {
									unset propfiles_list
								}
								set is_a_known_propfile -1
							}
						}
					} elseif {[IsThisAPropsFile $tmpfnam]} {
						set msg "This File Could Now Be A Properties File: Is It A Properties File ??"
						set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
						if {$choice == "yes"} {
							set is_a_propfile 1
						}
					}
					if {$pr11 == 1} {
						set oldextname [file extension $fnam]
						if {$is_nessfile != 0} {
							set extname $evv(NESS_EXT)
						} else {
							set extname [AssignTextfileExtension $newftyp]
							if {[string match $oldextname ".bat"]} {
								set msg "Is '$fnam' Still A Valid Batchfile ??"
								set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
								if {$choice == "yes"} {
									set extname $oldextname
								} else {
									set msg "Keep The (Invalid Batch)File $fnam ??"
									set choice [tk_messageBox -type yesno -icon question -defualt no -parent [lindex $wstk end] -message $msg]
									if {$choice == "no"} {
										continue
									}
								}
							} else {
								if {[string match $extname [GetTextfileExtension brk]] && ![string match $extname $evv(TEXT_EXT)]} {
									if {[HasBrkpntStructure $text_sf 1]} {
										set extname [GetTextfileExtension brk]
									} else {
										set extname $evv(TEXT_EXT)
									}
									set brk_is_set 1
								}
								if {($is_a_known_propfile >= 0) || [info exists is_a_propfile]} {
									set extname [GetTextfileExtension props]
								} 
								if {![IsAMixfileIncludingMultichan $origftyp] && ![IsABrkfile $origftyp] && ($is_a_known_propfile < 0) && ![info exists is_a_propfile]} {
									if {[info exists user_text_extensions] && ![info exists brk_is_set]} {
										set OK 1
										foreach zob [lrange $user_text_extensions 1 end] {
											if {[string match $zob $oldextname]} {
												set msg "If Original File was a '$zob' file\n\nDoes New File Have Correct Syntax For A '$zob' File ??"
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
											continue
										}
									}
								}
							}
						}
				 		if [catch {file delete $fnam} zizit] {
							Inf "Cannot Remove Original File"
							if [catch {file delete $tmpfnam}] {
								Inf "The Original File And The New File '$tmpfnam' Now Both Exist."
							} else {
								PurgeArray $tmpfnam
							}
						} else {
							if {[info exists mixmanage($fnam)]} {
								unset mixmanage($fnam)
								set save_mixmanage 1
							}
							if {[info exists nesstype($fnam)]} {
								PurgeNessData $fnam
								set nessupdate 1
							}
							DeleteFileFromSrcLists $fnam
							set ozfnam $fnam
							set fnam [file rootname $fnam]
							append fnam $extname
							if [catch {file rename $tmpfnam $fnam} in] {
								ErrShow "$in"
								UpdateBakupLog $fnam delete 1
								Inf "Cannot Substitute The New File: Original File Lost"
								set fnam $ozfnam
								PurgeArray $fnam				;#	can't remove unbakdup files!!
								RemoveFromChosenlist $fnam		;#	Otherwise, remove it
								RemoveFromDirlist $fnam
								DeleteFileFromSrcLists $fnam
								set i [LstIndx $fnam $wl]
								if {$i >= 0} {
									$wl delete $i
									WkspCnt $fnam -1
									catch {unset rememd}
								}
								set i [LstIndx $fnam $read_prr]
								if {$i >= 0} {
									$read_prr delete $i
								}
								DummyHistory $fnam "LOST"
								PurgeArray $tmpfnam
								if {$is_a_known_propfile >= 0} {
									set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
								}
							} else {
								UpdateBakupLog $fnam modify 1
								PurgeArray $ozfnam				
								DoParse $fnam $wl 0 0
								if {[string match $ozfnam $fnam]} {
									DummyHistory $fnam "EDITED"
									if {[UpdatedIfAMix $fnam 0]} {	;#	IF NEWFILE IS A MIXFILE, UPDATE MIX MANAGER
										set save_mixmanage 1
									} elseif {[UpdatedIfANess $fnam]} {
										set nessupdate 1
									}
									if {[LstIndx $fnam $ch] >= 0} {
										set renam 1
									}
								} else {
									DummyHistory $ozfnam "DESTROYED"
									DummyHistory $fnam "CREATED"
									set i [LstIndx $ozfnam $wl]
									if {$i >= 0} {
										$wl delete $i
										$wl insert $i $fnam
									}
									if {[info exists mixmanage($ozfnam)]} {
										unset mixmanage($ozfnam)
										set save_mixmanage 1
									}
									if {[info exists nesstype($ozfnam)]} {
										PurgeNessData $ozfnam
										set nessupdate 1
									}
									if {[UpdatedIfAMix $fnam 0]} {	;#	IF NEWFILE IS A MIXFILE, UPDATE MIX MANAGER
										set save_mixmanage 1
									} elseif {[UpdatedIfANess $fnam]} {
										set nessupdate 1
									}
									set i [LstIndx $ozfnam $ch]
									if {$i >= 0} {
										set renam 1
										$ch delete $i
										$ch insert $i $fnam
										set chlist [lreplace $chlist $i $i $fnam]
									}
									if {[info exists is_a_propfile]} {
										AddToPropfilesList $fnam
									}
								}
								set finished 1
							}			
						}
					} else {
						set nufnam [GetNuFnam $fnam]
						if {[string length $nufnam] > 0} {
							if {$is_nessfile != 0} {
								set extname $evv(NESS_EXT)
							} else {
								set extname [AssignTextfileExtension $newftyp]
								if {[string match $extname [GetTextfileExtension brk]] && ![string match $extname $evv(TEXT_EXT)]} {
									if {[HasBrkpntStructure $text_sf 1]} {
										set extname [GetTextfileExtension brk]
									} else {
										set extname $evv(TEXT_EXT)
									}
									set brk_is_set 1
								}
								if {($is_a_known_propfile >= 0) || [info exists is_a_propfile]} {
									set extname [GetTextfileExtension props]
								} 
								set oldextname [file extension $fnam]
								set OK 1
								if {![IsAMixfileIncludingMultichan $origftyp] && ![IsABrkfile $origftyp] && ($is_a_known_propfile < 0) && ![info exists is_a_propfile]} {
									if {[info exists user_text_extensions] && ![info exists brk_is_set]} {
										set OK 1
										foreach zob [lrange $user_text_extensions 1 end] {
											if {[string match $zob $oldextname]} {
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
											continue
										}
									}
								}
							}
							set nufnam [file rootname $nufnam]
							append nufnam $extname
							if [catch {file rename -force $tmpfnam $nufnam} in] {
								ErrShow "Cannot rename the new file to '$nufnam'"	
							} else {
								PurgeArray $tmpfnam
								if {[FileToWkspace $nufnam 0 0 0 0 1] <= 0} {	 		
									if [catch {file delete $nufnam} result] {
										ErrShow "Cannot delete invalid file $nufnam"
										if {[UpdatedIfAMix $nufnam 0]} { 	;#	EVEN THOUGH NOT ON WORKSPACE, TRY TO UPDATE MIX MANAGER
											set save_mixmanage 1
										} elseif {[UpdatedIfANess $nufnam]} {
											set nessupdate 1
										}
									}
									DeleteFileFromSrcLists $nufnam
									continue						;#	Put file on workspace, only if valid file
								} elseif {($is_a_known_propfile >= 0) || [info exists is_a_propfile]} {
									AddToPropfilesList $nufnam	;# Assume new file is intended also to be a propsfile
								}
								DummyHistory $nufnam "CREATED"
								if {[UpdatedIfAMix $nufnam 0]} {			;#	IF A (NON-TEMPFILE) MIXFLE, UPDATE MIX MANAGER
									set save_mixmanage 1
								} elseif {[UpdatedIfANess $nufnam]} {
									set nessupdate 1
								}
								AddNameToNameslist $nufnam 0
							}
							if {!($from_runpage || $ins_concluding) && $brk(from_wkspace)} {
								if [info exists read_prr] {
									$read_prr insert 0 $nufnam
								}
							}
							set finished 1
						}
					}
				}
			}
		} else {
			set finished 1
			break
		}
	}
	if {$save_mixmanage} {
		MixMStore
	}
	if {$nessupdate} {
		NessMStore
	}
	catch {close $fileId}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f								;#	Hide the dialog
	if {($from_runpage || $ins_concluding) && ($prg_ocnt == 1)} {
		set pr10 1
	}
}

#------ New option on edit textfile, to save with new name

proc GetNuFnam {fnam} {
	global pr11_11 q_savename rememd ch wl nu_names wstk ins chlist sysname evv

	set f .nufnam
	if [Dlg_Create $f "New Filename" "set pr11_11 1" -borderwidth $evv(BBDR)] {
		set b [frame $f.button -borderwidth $evv(SBDR)]
		set n [frame $f.name -borderwidth $evv(SBDR)]
		set s [frame $f.saver -borderwidth $evv(SBDR)]
		set a [frame $f.a -borderwidth $evv(SBDR)]
		label $s.laba -text "Recent Names"
		Scrolled_Listbox $s.names -height $evv(NSTORLEN) -selectmode single
		label $s.labb -text "Recent Source Names"
		Scrolled_Listbox $s.namesb -height $evv(NSTORLEN) -selectmode single -height 3
		label $s.bbb -text "standard names"
		set ku [frame $s.bbbb]
		button $ku.bb1 -text "$sysname(1)" -command "PutName .nufnam.name.name $sysname(1)" -highlightbackground [option get . background {}]
		button $ku.bb2 -text "$sysname(2)" -command "PutName .nufnam.name.name $sysname(2)" -highlightbackground [option get . background {}]
		button $ku.bb3 -text "$sysname(3)" -command "PutName .nufnam.name.name $sysname(3)" -highlightbackground [option get . background {}]
		button $ku.bb4 -text "$sysname(4)" -command "PutName .nufnam.name.name $sysname(4)" -highlightbackground [option get . background {}]
		button $ku.bb5 -text "$sysname(5)" -command "PutName .nufnam.name.name $sysname(5)" -highlightbackground [option get . background {}]
		pack $s.bbb $s.bbbb -side top -pady 1
		pack $ku.bb1 $ku.bb2 $ku.bb3 $ku.bb4 $ku.bb5 -side left -padx 1
		pack $s.labb $s.namesb $s.laba $s.names -side top -fill x
		label $a.arrow -text "Up Arrow: incr name(end)     Dn Arrow: decr name(end)"
		label $a.arrw2 -text "Cntrl Up: incr name(start)   Cntrl Dn: decr name(start)"
		pack $a.arrow -side top
		pack $a.arrw2 -side top
		button $b.save -text "OK" -command "set pr11_11 1" -highlightbackground [option get . background {}]
		button $b.quit -text "Close" -command "set pr11_11 0" -highlightbackground [option get . background {}]
		pack $b.save -side left
		pack $b.quit -side right
		label $n.l -text "Name"
		entry $n.name -width 20 -textvariable q_savename
		pack $n.l $n.name -side left
		pack $f.button -side top -fill x -expand true
		pack $f.name -side top
		pack $f.a $f.saver -side top -fill x -expand true

		bind $f.saver.names.list <Down> "AdvanceNameIndex 0 q_savename 0"
		bind $f.saver.namesb.list <Down> "AdvanceNameIndex 0 q_savename 0"
		bind $f.name.name <Down> "AdvanceNameIndex 0 q_savename 0"
		bind $f.saver.names.list <Up> "AdvanceNameIndex 1 q_savename 0"
		bind $f.saver.namesb.list <Up> "AdvanceNameIndex 1 q_savename 0"
		bind $f.name.name <Up> "AdvanceNameIndex 1 q_savename 0"

		bind $f.saver.names.list <Control-Down> "AdvanceNameIndex 0 q_savename 1"
		bind $f.saver.namesb.list <Control-Down> "AdvanceNameIndex 0 q_savename 1"
		bind $f.name.name <Control-Down> "AdvanceNameIndex 0 q_savename 1"
		bind $f.saver.names.list <Control-Up> "AdvanceNameIndex 1 q_savename 1"
		bind $f.saver.namesb.list <Control-Up> "AdvanceNameIndex 1 q_savename 1"
		bind $f.name.name <Control-Up> "AdvanceNameIndex 1 q_savename 1"

		bind $f.saver.names.list <ButtonRelease-1> {NameListChoose .nufnam.saver.names.list .nufnam.name.name}
		bind $f.saver.namesb.list <ButtonRelease-1> {NameListChoose .nufnam.saver.namesb.list .nufnam.name.name}

		bind $f <Return> {set pr11_11 1}
		bind $f <Escape> {set pr11_11 0}
	}
	wm resizable $f 1 1
	if [info exists nu_names] { 
		$f.saver.names.list delete 0 end
		foreach nname $nu_names {	;#	Post recent names
			$f.saver.names.list insert end $nname
		}					
		$f.saver.names.list xview moveto 0.0
	}
	$f.saver.namesb.list delete 0 end
	$f.saver.namesb.list xview moveto 0.0
	if {[info exists ins(chlist)] && ([llength $ins(chlist)] > 0)} {
		set thisl $ins(chlist)
	} elseif {[info exists chlist] && ([llength $chlist] > 0)} {
		set thisl $chlist
	}
	if [info exists thisl] { 
		set i 0
		foreach nname $thisl {	;#	Post source names
			$f.saver.namesb.list insert end [file rootname [file tail $nname]]
			incr i
			if {$i >= 2} {
				break
			}
		}					
	}
	raise $f
	set q_savename [file tail [file rootname $fnam]]
	$f.name.name xview moveto 1.0
	set pr11_11 0
	set finished 0
	My_Grab 0 $f pr11_11 $f.name.name
	while {!$finished} {
		tkwait variable pr11_11
		if {$pr11_11 == 0} {
			set nufnam ""
			set finished 1
			break
		} else {
			if {[string length $q_savename] <= 0} {
				Inf "No Name Entered."
				continue
			}
			set q_savename [string tolower $q_savename]
			if [string match $q_savename $fnam] {
				Inf "Cannot Use The Original Name Here."
				continue
			}
			set savename [FixTxt $q_savename "filename"]
			if {[string length $savename] <= 0} {
				continue
			}
			if {![ValidCDPRootname $savename]} { 
				continue
			}
			set q_savename $savename
			set extname [file extension $fnam]
			set nufnam $savename
			set nufnam $nufnam$extname				
			if {[LstIndx $nufnam $ch] >= 0} {
				Inf "'$fnam' Is An Input File To This Process: You Cannot Overwrite It Here."
				continue
			}
			if [file exists $nufnam] {
				set choice [tk_messageBox -type yesno -message "File exists: Overwrite?" \
							-icon question -parent [lindex $wstk end]]
				if [string match "no" $choice] {
					continue
				} else {
					if {![DeleteFileFromSystem $nufnam 1 0]} {
						continue
					}
				}										
				DummyHistory $nufnam "OVERWRITTEN"
				set i [LstIndx $nufnam $wl]	;#	remove from workspace listing
				if {$i >= 0} {
					$wl delete $i
					WkspCntSimple -1
					catch {unset rememd}
				}
			}
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $nufnam
}

#------ Play the output sound(s) or the sounds on wkspace, chosen list or dirlist.

proc PlayOutput {sel} {
	global pr4 o_nam ins evv playlist sndsout asndsout play_pll from_dirl dl hidden_dir
	global pa wl from_runpage ins_file_lst ins_concluding playcnt lastplay dupl_mix
	global has_played from_chosen from_mcreate ch chlist src bulk do_ptoc_update ptoc_update_done sl_real lastplel
	global plist_del_warn playgrab
	set plist_del_warn 1
	set playcnt -1
	set from_wl 0
	set do_ptoc_update 1
	set ptoc_update_done 0
	if {!$sl_real} {
		if {$from_runpage} {
			Inf "If The File You Have Created Is A Soundfile (As In This Case)\nThis Button Becomes Active, And The Sound Can Be Played.\n\nIf You Created A Textfile, The 'Read' Button Becomes Active\nAnd You Can Read Your File."
			return
		} else {
			if {$sel} {
				Inf "This Button Allows You To Play Any Soundfiles Selected From The List Below."
			} else {
				Inf "This Button Allows You To Play Any Soundfiles In The List Below."
			}
			return
		}
	}
	if {($sel == 3) && $dupl_mix} {
		Inf "Duplicate files on chosen files list: cannot proceed"
		return
	}
	set has_played 1
	if {$from_dirl} {
		set ilist [$dl curselection]
		set i [lindex $ilist 0]
		set zort [$dl get $i]
		if {[string length $hidden_dir] > 0} {
			set zort [file join $hidden_dir $zort]
		}
		set ftyp [FindFileType $zort]
		switch -regexp -- $ftyp \
			^$evv(SNDFILE)$ {
				PlaySndfile $zort 0
			} \
			^$evv(ANALFILE)$ {
				PlaySndfile $zort 1
			} \
			default {
				Inf "The File '$zort' Is Not A Playable File"
			}
		return
	}
	if {($from_runpage || $ins_concluding)} {
		if {$sndsout == 0 && $asndsout == 0} {
			ErrShow "No Soundfiles to play: Program Error in enabling buttons"
			return
		} elseif {([expr $sndsout + $asndsout] == 1) && [DoSingleFile play]} {
			return
		} else {
			if {$from_runpage} {
				if {$ins(run) || $bulk(run)} {
					set namegroup $evv(MACH_OUTFNAME) 	;#	Collects outputs from ALL ins-processes
				} else {
					set namegroup $o_nam 		;#	Collects normal outs, or current Instrumentcreateprocess outs
				}
				set playcnt 0
				foreach fnam [lsort -dictionary [glob -nocomplain $namegroup*]] {
					if {($pa($fnam,$evv(FTYP)) == $evv(SNDFILE)) || ($pa($fnam,$evv(FTYP)) == $evv(ANALFILE))} {
						lappend flist $fnam
						incr  playcnt
					}
				}					
			} else {
				set playcnt 0
				foreach fnam [$ins_file_lst get 0 end] {
					if {($pa($fnam,$evv(FTYP)) == $evv(SNDFILE)) || ($pa($fnam,$evv(FTYP)) == $evv(ANALFILE))} {
						lappend flist $fnam
						incr  playcnt
					}
				}
			}
		}
	} elseif {$from_chosen || $from_mcreate} {
		if {$from_chosen} {
			if {![info exists chlist]} {
				set from_chosen 0
				set from_mcreate 0
				return
			}
			set searchlist $chlist
			if {$dupl_mix} {
				set searchlist [RemoveDupls $searchlist]
			}
		} elseif {$from_mcreate} {
			set searchlist [$ins_file_lst get 0 end]
		}
		set playcnt 0
		foreach fnam $searchlist {
			if {($pa($fnam,$evv(FTYP)) == $evv(SNDFILE)) || ($pa($fnam,$evv(FTYP)) == $evv(ANALFILE))} {
				lappend flist $fnam
				incr playcnt
			} elseif [info exists src($fnam)] {
				foreach fnm $src($fnam) {
					if [file exists $fnm] {
						lappend flist $fnm
						incr playcnt
					}
				}
			}
		}
	} else {
		set from_wl 1
		set playcnt 0
		switch -- $sel {
			0 -
			2 {
				foreach fnam [$wl get 0 end] {
					if {($pa($fnam,$evv(FTYP)) == $evv(SNDFILE)) || ($pa($fnam,$evv(FTYP)) == $evv(ANALFILE))} { 
						lappend flist $fnam
						incr playcnt
					}
				}
			}
			1 -
			3 {
				set ilist [$wl curselection]
				if {($sel==3) && (![info exists ilist] || ([llength $ilist] <= 0))} {
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
							set ilist [$wl curselection]
						}
					}
				}
				if {![info exists ilist] || ([llength $ilist] <= 0)} {
					Inf "No Files Selected"
					return
				} 
				foreach i $ilist {
					set fnam [$wl get $i]
					if {($pa($fnam,$evv(FTYP)) == $evv(SNDFILE)) || ($pa($fnam,$evv(FTYP)) == $evv(ANALFILE))} { 
						lappend flist $fnam
						incr playcnt
					} else {
						set badfile 1
					}
				}
				if {($playcnt == 0) && $badfile} {
					Inf "Selected Files Are Not Soundfiles"
					return
				} 
			} 
		}
	}
	if {$playcnt == 0} {
		set from_chosen 0
		set from_mcreate 0
		return
	} elseif {$playcnt == 1} {
		if {$sel > 1} {
			Inf "Only One Soundfile Here"
			return
		}
		set fnam [lindex $flist 0]
		if {![info exists pa($fnam,$evv(FTYP))]} {
			Inf "Cannot Find File Type"
			return
		}
		if {$pa($fnam,$evv(FTYP)) == $evv(ANALFILE)} {
			PlaySndfile $fnam 1
		} else {
			PlaySndfile $fnam 0
		}
		set from_chosen 0
		set from_mcreate 0
		catch {unset lastplay}
		return
	}
	if {$sel > 1} {
		PartitionPlay $flist
		return
	}
	set f .playlist
	if [Dlg_Create $f "Playlist" "set pr4 1" -borderwidth $evv(BBDR)] {
		set b 	   [frame $f.button  -borderwidth $evv(SBDR)]
		set c 	   [frame $f.button2 -borderwidth $evv(SBDR)]
		set d 	   [frame $f.button3 -borderwidth $evv(SBDR)]
		set z	   [frame $f.button4 -borderwidth $evv(SBDR)]
		set player [frame $f.play -borderwidth $evv(SBDR)]
		set play_pll [Scrolled_Listbox $player.playlist -width 72 -height 36 -selectmode single]
		button $b.play -text "Play"    -command "PlaySelectedSndfile $play_pll" -width 6 -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $b.sview -text "SView"  -command "SnackDisplay 0 playlist 0 0" -width 6 -bg $evv(SNCOLOR) -highlightbackground [option get . background {}]
		button $b.a -text "A" -bd 4 -command "PlaySndfile $evv(TESTFILE_A) 0" -width 2  -highlightbackground [option get . background {}];# -bg $evv(HELP)
		button $b.playnext -text "Play Next" -command {PlayNext 0 play_pll} -bg $evv(EMPH) -width 12 -highlightbackground [option get . background {}]
		button $b.playlast -text "Play Previous" -command {PlayNext 1 play_pll} -bg $evv(EMPH) -width 12 -highlightbackground [option get . background {}]
		button $b.playfirst -text "Play First" -command {PlayNext 2 play_pll} -bg $evv(EMPH) -width 12 -highlightbackground [option get . background {}]
		button $b.quit -text "Close" -command "set pr4 1" -highlightbackground [option get . background {}]
		button $c.dum -text ""    -command {}  -bd 0 -width 7 -highlightbackground [option get . background {}]
		button $c.dum3 -text ""    -command {}  -bd 0 -width 7 -highlightbackground [option get . background {}]
		button $z.srch -text ""    -command {}  -bd 0 -width 7 -highlightbackground [option get . background {}]
		menubutton $d.menu -text "Pitch Markers" -width 18 -menu $d.menu.m -relief raised
		set m [menu $d.menu.m -tearoff 0]
		$m add command -label "Create or Edit" -command {Do_Pitchmark $play_pll 0} -foreground black
		$m add command -label "Delete (!!)" -command {Do_Pitchmark $play_pll 1} -foreground black

		menubutton $c.sort -text "Sort"     -width 12 -menu $c.sort.m -relief raised
		set ms [menu $c.sort.m -tearoff 0]
		$ms add command -label "Sort"    -command {PlaySort $play_pll} -foreground black
		$ms add separator
		$ms add command -label "Move Selected File To Top"  -command {PlayMove 1 $play_pll} -foreground black
		$ms add separator
		$ms add command -label "Move Selected File To End"  -command {PlayMove 0 $play_pll} -foreground black
		$ms add separator
		$ms add command -label "Restore Previous Order" -command {PlayRestore $play_pll} -foreground black
		$ms add separator
		$ms add command -label "Force Chosen Files In This Order" -command {ChosSort $play_pll} -foreground $evv(SPECIAL)

		menubutton $c.scro -text "Selection" -width 12 -menu $c.scro.m -relief raised
		set mm [menu $c.scro.m -tearoff 0]
		$mm add command -label "" -command {} -foreground black 
		$mm add separator 
		$mm add command -label "" -command {} -foreground black
		$mm add separator ;# -background $evv(HELP)
		$mm add command -label "REARRANGE" -command {}  -foreground black
		$mm add separator ;# -background $evv(HELP)
		$mm add command -label "" -command {} -foreground black
		$mm add separator
		$mm add command -label "" -command {} -foreground black
		$mm add separator
		$mm add command -label "" -command {} -foreground black
		$mm add command -label "" -command {} -foreground black
		$mm add command -label "" -command {} -foreground black
		$mm add command -label "" -command {} -foreground black
		$mm add separator
		$mm add command -label "" -command {} -foreground black
		$mm add separator
		$mm add command -label "" -command {} -foreground black
		$mm add command -label "" -command {} -foreground black
		$mm add command -label "" -command {} -foreground black
		$mm add command -label "" -command {} -foreground black
		$mm add separator
		$mm add command -label "" -command {} -foreground black
		$mm add separator
		$mm add command -label "" -command {} -foreground black
		$mm add separator
		$mm add command -label "" -command {} -foreground black
		radiobutton $d.gr -variable playgrab -value 1 -text "" -width 5 -command {} -state disabled
		set playgrab 0
		button $d.ch -text "" -command {} -bd 0 -state disabled -width 18 -highlightbackground [option get . background {}]
		button $d.ref -text "Keep as Reference Val" -command {RefStore pl} -width 18  -highlightbackground [option get . background {}];# -bg $evv(HELP)
		button $d.dum2 -text "" -command {} -bd 0 -width 4 -highlightbackground [option get . background {}]
		button $d.dum4 -text "" -command {} -bd 0 -width 4 -highlightbackground [option get . background {}]
		pack $b.play $b.sview $b.a $b.playnext $b.playlast $b.playfirst -side left -padx 1
		pack $b.quit -side right -padx 1
		pack $c.dum $c.sort $c.scro -side left -padx 1 -fill x
		pack $c.dum3 -side right -padx 1 -fill x 
		pack $d.dum2 $d.ch $d.ref -side left -padx 1 -fill x
		pack $d.dum4 $d.menu -side right -padx 1 -fill x
		pack $player.playlist -side top -fill both -expand true
		pack $z.srch -side top
		pack $f.button -side top -fill x
		pack $f.button2 -side top -expand true
		pack $f.button4 -side top -expand true
		pack $f.button3 -side top -expand true
		pack $f.play -side top -fill x
		bind .playlist <Control-Key-p> {UniversalPlay list $play_pll}
		bind .playlist <Control-Key-P> {UniversalPlay list $play_pll}
		bind .playlist <Key-space>     {UniversalPlay list $play_pll}
		bind .playlist <Double-1>      {UniversalPlay list $play_pll}
		bind $f <Escape> {set pr4 1}
	}
	wm resizable $f 1 1
	set plist_del_warn 1
	if {$from_wl} {
		$f.button2.scro config -text "Selection" -state normal -borderwidth 2
		$f.button3.gr config -state normal -text Grab -command PlaylistToChlist3
		set playgrab 0
		$f.button3.ch config  -text "Grab as Chosen File" -command {set do_ptoc_update [PlaylistToChlist $do_ptoc_update]} -bd 2 -state normal
		$f.button2.sort config -text "Sort" -bd 2 -state normal
		$f.button2.scro.m entryconfig 0  -label "DO IT AGAIN" -command {} ;# -background $evv(HELP) 
#		$f.button2.scro.m entryconfig 1  -background $evv(HELP) 
		$f.button2.scro.m entryconfig 2  -label "" -command {}
		$f.button2.scro.m entryconfig 4 -label "REMOVE"
		$f.button2.scro.m entryconfig 6 -label "Remove File From Workspace" -command "PlayWkRemove; SetPlel remove"
		$f.button2.scro.m entryconfig 8 -label "TO CHOSEN LIST" ;# -background $evv(HELP)
		$f.button2.scro.m entryconfig 10 -label "Clear Chosen List" -command "PlayToClearChosen; SetPlel clchosen"
		$f.button2.scro.m entryconfig 11 -label "Choose Sound To Process" -command "PlayToChosen 0; SetPlel tochosen"
		$f.button2.scro.m entryconfig 12 -label "File To Chosen & Quit Play" -command "PlayToChosen 1; SetPlel tochoq"
		$f.button2.scro.m entryconfig 13 -label "File Replaces Chosen List & Quit Play" -command "PlayToChosen 2; SetPlel tochoq2"
		$f.button2.scro.m entryconfig 15 -label "PARTITION SOUNDS AMONG LISTINGS" ;# -background $evv(HELP)
		$f.button2.scro.m entryconfig 17 -label "Add Sound To A Background Listing" -command "BListFromWkspace $play_pll 0 0; SetPlel toblist"
		$f.button2.scro.m entryconfig 18 -label "Remove Sound From A Background Listing" -command "GetBLName 2; SetPlel remblist"
		$f.button2.scro.m entryconfig 19 -label "See/Play/Edit Background Listings" -command "GetBLName 2; SetPlel edblist"
		$f.button2.scro.m entryconfig 20 -label "Check B-Lists Are Distinct" -command "GetBLName 17; SetPlel distblist"
		$f.button2.scro.m entryconfig 22 -label "DESTROY FILE" ;# -background $evv(HELP)
		$f.button2.scro.m entryconfig 24 -label "Destroy File (!!)" -command "PlaylistDeletion"
		$f.button2.scro.m entryconfig 26 -label "Turn Off Destroy Warning (Care!!)" -command "ResetDelWarn"
	} else {
		if {$from_chosen} {
			$f.button3.gr config -state disabled -command {} -text ""
			set playgrab 0
			$f.button3.ch config  -text "Grab as Chosen File" \
			-command {set do_ptoc_update [PlaylistToChlist2 $do_ptoc_update]} -bd 2 -state normal
			$f.button2.sort config -text "Sort" -bd 2 -state normal
			$f.button2.sort.m entryconfig 12 -label "Put Chosen Files In This Order" -command {ChosSort $play_pll}
			$f.button2.scro config -text "" -state disabled -borderwidth 0
		} else {
			$f.button3.gr config -state disabled -command {} -text ""
			set playgrab 0
			$f.button3.ch config -text "" -command {} -bd 0 -state disabled
			$f.button2.sort config -text "" -bd 0 -state disabled 
			$f.button2.scro config -text "Selection" -state normal -borderwidth 2
			$f.button2.scro.m entryconfig 0  -label "" -command {}
			$f.button2.scro.m entryconfig 1  -background [option get . background {}]
			$f.button2.scro.m entryconfig 2  -label "" -command {}
			$f.button2.scro.m entryconfig 4 -label "REARRANGE"
			$f.button2.scro.m entryconfig 6 -label "Scroll Selected File To Top" -command "PlayScroll"
			$f.button2.scro.m entryconfig 8 -label "" -background [option get . background {}]
			$f.button2.scro.m entryconfig 10  -label "" -command {}
			$f.button2.scro.m entryconfig 11  -label "" -command {}
			$f.button2.scro.m entryconfig 12  -label "" -command {}
			$f.button2.scro.m entryconfig 13 -label "" -command {}
			$f.button2.scro.m entryconfig 15 -label "" -background [option get . background {}]
			$f.button2.scro.m entryconfig 17 -label "" -command {}
			$f.button2.scro.m entryconfig 18 -label "" -command {}
			$f.button2.scro.m entryconfig 19 -label "" -command {}
			$f.button2.scro.m entryconfig 20 -label "" -command {}
			$f.button2.scro.m entryconfig 22 -label "" -background [option get . background {}]
			$f.button2.scro.m entryconfig 24 -label "" -command {}
			$f.button2.scro.m entryconfig 26 -label "" -command {}
		}
	}
	if {$from_wl || $from_chosen} {
		$f.button3.menu config -text "Pitch Markers" -width 18 -relief raised  -state normal
		$f.button3.ref config -text "Keep as Reference Val" -command {RefStore pl} -width 18 -bd 2 ;# -bg $evv(HELP)
		$f.button4.srch config -text "Search" -command {SearchPlaylistForFile} -bd 2
	} else {
		$f.button3.menu config -text "" -relief flat -state disabled
		$f.button3.ref config  -text "" -command {} -bg [option get . background {}] -bd 0
		$f.button4.srch config -text "" -command {} -bd 0
	}
	if {$from_wl} {
		if {[info exists lastplel]} {
			if {![string match $lastplel "delete"]} {
				SetPlel $lastplel
			}
		}
	}
	$play_pll delete 0 end
	if {!$from_wl} {
		set setsel 0
	} elseif {![info exists lastplay]} {
		set setsel 0
	} else {
		set setsel 1
	}
	set i 0
	foreach fnam $flist {
		$play_pll insert end $fnam
		if {$setsel && [string match $lastplay $fnam]} {
			set ii $i
			set setsel 0
		}
		incr i
	}
	if {[info exists ii]} {
		$play_pll selection set $ii
		$play_pll yview moveto [expr double($ii)/double($i)]
	} else {
		$play_pll selection set 0
	}
	set from_chosen 0
	set from_mcreate 0
	set pr4 0
	raise $f
	My_Grab 0 $f pr4 $f.play.playlist

	if {$from_runpage} {
		wm geometry $f [ToRightHalf .ppg $f]
	} elseif {$ins_concluding} {
		wm geometry $f [ToRightHalf .inspage $f]
	} else {
		wm geometry $f [ToRightHalf .workspace $f]
	}
	tkwait variable pr4
	if {$from_wl} {
		set i [$play_pll curselection]
		if {$i >= 0} {
			set lastplay [$play_pll get $i]
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#------ Play sndfile selected from playlist

proc PlaySelectedSndfile {pll} {
	global sndsout asndsout from_runpage ins_concluding playcnt last_played pa evv
#	if {(($from_runpage || $ins_concluding) && ([expr $sndsout + $asndsout] == 1)) || $playcnt == 1} {
#		set i 0
#	}
	if {$playcnt == 1} {
		set i 0
	} else {
		set i [$pll curselection]
		if {[string length $i] <= 0} {
			Inf "No Item Selected"
			return
		}
	}
	set fnam [$pll get $i]
	set last_played $fnam
	if {![info exists pa($fnam,$evv(FTYP))]} {
		Inf "Cannot Get File Type"
		return
	}
	if {$pa($fnam,$evv(FTYP)) == $evv(ANALFILE)} {
		PlaySndfile $fnam 1
	} else {
		PlaySndfile $fnam 0
	}
}

#------ Play a sndfile

proc PlaySndfile {fnam anal} {
	global CDPidplay playcmd pvplaycmd pa pr_playstop wstk evv
	global do_play_stop playiconify play_killed play_pids
	global sndcardfault

	if {[info exists sndcardfault]} {
		Inf "Cannot play soundfiles at present"
		return 0
	}
	set zfnam [pwd]
	set fnam [file join $zfnam $fnam]
	if {![file exists $fnam]} {
		Inf "File $fnam No Longer Exists"
		return 0
	}
	set pr_playstop 0
	set do_stop 0
	if {$anal} {
		set cmd \"$pvplaycmd\"
		lappend cmd -i "$fnam"
#RWD will always need this for pvoc playback!
		set do_stop 1
	} else {
		if {[info exists pa($fnam,$evv(CHANS))] && ($pa($fnam,$evv(CHANS)) > 2)} {
			set cmd $pvplaycmd
			set rawplaycmd $cmd
			if {![file exists $rawplaycmd]} {
				Inf "Play Program [file rootname [file tail $rawplaycmd]] Not Available."
				return 0
			}
			if {[info exists evv(DEVICE)]} {
				lappend cmd -i -u -d$evv(DEVICE) "$fnam"
			} else {
				lappend cmd -i -u "$fnam"
			}
			set do_stop 1

		} elseif {[string match [file rootname [file tail [lindex $playcmd 0]]] "pvplay"]} {
			set cmd [lindex $playcmd 0]
			set rawplaycmd $cmd
			if {![file exists $rawplaycmd]} {
				Inf "Play Program [file rootname [file tail $rawplaycmd]] Not Available."
				return 0
			}
			lappend cmd -i -u "$fnam"
			if {[info exists evv(DEVICE)]} {					;#	ADD DEVICE FLAG, if known
				set cmd [linsert $cmd 2 "-d$evv(DEVICE)"]
			}
			set do_stop 1
		} else {
			if {![file exists $playcmd]} {
				Inf "File \"$playcmd\" to play files no longer exists"
				return 0
			}
			if {[string match [file rootname [file tail $playcmd]] "qtscript"]} {
				set rawplaycmd "/Applications/QuickTime Player.app/Contents/MacOS/QuickTime Player"
				if {![file exists $rawplaycmd]} {
					Inf "Play Program \"QuickTime Player\" Not Available."
					return 0
				}
			} elseif {[string match [file rootname [file tail $playcmd]] "qt7script"]} {
				set rawplaycmd "/Applications/QuickTime Player 7.app/Contents/MacOS/QuickTime Player 7"
				if {![file exists $rawplaycmd]} {
					Inf "Play Program \"QuickTime Pro\" Not Available."
					return 0
				}
			} elseif {[string match [file rootname [file tail $playcmd]] "vlcscript"]} {
				set rawplaycmd "/Applications/VLC.app/Contents/MacOS/VLC"
				if {![file exists $rawplaycmd]} {
					Inf "Play Program \"VLC\" Not Available."
					return 0
				}
			}
			set cmd \"$playcmd\"
			lappend cmd "$fnam"
		}
	}
	if {[info exists do_play_stop]} {
		set do_stop 1
	}

	if [catch {open "|$cmd"} CDPidplay] {
		ErrShow "$CDPidplay : Play program not responding with file $fnam"
		return 0
	}
	catch {unset play_killed}
	if {$do_stop} {
		if {[info exists playiconify]} {
			wm iconify [lindex $wstk end]
		}
		set play_pids [pid $CDPidplay]
		set callcentre [GetCentre [lindex $wstk end]]
		set f .stopplay
		if [Dlg_Create $f "" "ExitPlayer" -borderwidth $evv(BBDR)] {
			button $f.b -text "  STOP PLAY " -command "ExitPlayer" -width 12 -highlightbackground [option get . background {}]
			pack $f.b -side top
			bind $f <space> "ExitPlayer"
		}
		update idletasks
		raise $f    
		set geo [CentreOnCallingWindow $f $callcentre]
		My_Grab 0 $f pr_playstop
		wm geometry $f $geo
		wm resizable $f 1 1
		tkwait variable pr_playstop
		catch {exec kill $play_pids}
		if {![info exists play_killed]} {
			My_Release_to_Dialog $f
			Dlg_Dismiss $f
		}
	}
	catch {close $CDPidplay}
	return 1
}

proc ExitPlayer {} {
	global pr_playstop CDPidplay wstk playiconify play_killed play_pids
	catch {exec kill $play_pids}
	catch {close $CDPidplay}
	My_Release_to_Dialog .stopplay
	Dlg_Dismiss .stopplay
	set play_killed 1
	if {[info exists playiconify]} {
		wm deiconify [lindex $wstk end]
	}
	set pr_playstop 0
}

#------ Send sndsystem files to snack for viewing
 
proc ViewOutput {} {
	global o_nam pr100 ins evv vwbl_sndsysout viewlist
	global view_prr pa wl from_runpage ins_concluding
	global ins_file_lst has_viewed bulk sl_real invlist invlist_view singleform chlist

	if {!$sl_real} {
		if {($from_runpage || $ins_concluding)} {
			Inf "If The File You Have Created Is A Soundfile (As In This Case)\nThis Button Becomes Active,\nAnd You Can See A Graphic Display Of The Waveform Of The Sound."
		} else {
			Inf "If The File You Selected Is A Soundfile\nYou Can See A Graphic Display Of The Waveform Of The Sound."
		}
		return
	}
	set has_viewed 1
	if {$invlist_view} {
		if {![info exists invlist]} {
			return
		}
	} elseif {($from_runpage || $ins_concluding)} {
		if {$singleform} {
			ViewSingleForm
			return
		}
		if {$vwbl_sndsysout == 0} {
			ErrShow "No Sndsystem files to display: Program Error in enabling buttons"
			return
		}
		if {($vwbl_sndsysout == 1) && [DoSingleFile view]} {
			return
		}
	} else {
		set viewit 0
		set i [$wl curselection]
		if {[llength $i] > 0} {
			set i [lindex $i 0]
			set fnam [$wl get $i]
			if {($pa($fnam,$evv(FTYP)) == $evv(SNDFILE)) || ($pa($fnam,$evv(FTYP)) == $evv(PSEUDO_SND))} {
				$wl selection clear 0 end
				$wl selection set $i
				set viewit 1
			} elseif {[IsABrkfile $pa($fnam,$evv(FTYP))]} {
				$wl selection clear 0 end
				$wl selection set $i
				GrafDisplayBrkfile 1 1
				return
			} elseif {$pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)} {
				$wl selection clear 0 end
				$wl selection set $i
				SimpleDisplayTextfile $fnam
				return
			} else {
				set viewit -1
			}
		} elseif {[info exists chlist] && ([llength $chlist] > 0)} {
			if {[llength $chlist] == 1} {
				set fnam [lindex $chlist 0]
				set i [LstIndx $fnam $wl]
				if {($pa($fnam,$evv(FTYP)) == $evv(SNDFILE)) || ($pa($fnam,$evv(FTYP)) == $evv(PSEUDO_SND))} {
					$wl selection clear 0 end
					$wl selection set $i
					set viewit 1
				} elseif {[IsABrkfile $pa($fnam,$evv(FTYP))]} {
					$wl selection clear 0 end
					$wl selection set $i
					GrafDisplayBrkfile 1 1
					return
				} elseif {$pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)} {
					$wl selection clear 0 end
					$wl selection set $i
					SimpleDisplayTextfile $fnam
					return
				} else {
					set viewit -1
				}
			} else {
				set viewit 2
			}
		}
		switch -- $viewit {
			-1 { Inf "'$fnam' Is Not A Viewable File" }
			1  { ViewSelectedFile $wl 0 }
			0  { Inf "No File Selected" }
			2  { Inf "Select A Single File" }
		}
		return
	}
	set f .viewlist
	if [Dlg_Create $f "Viewable Files" "set pr100 1" -borderwidth $evv(BBDR)] {
		set b [frame $f.button -borderwidth $evv(SBDR)]
		set r [frame $f.reader -borderwidth $evv(SBDR)]
		set view_prr [Scrolled_Listbox $r.readlist -width 48 -height 10 -selectmode single]
		button $b.read -text "View" -command "ViewSelectedFile $view_prr 0" -highlightbackground [option get . background {}]
		button $b.zzz -text "View Last Played" -command "ViewSelectedFile $view_prr 1" -highlightbackground [option get . background {}]
		button $b.sort -text "Sort" -command "ListSort $view_prr" -highlightbackground [option get . background {}]
		button $b.quit -text "Close" -command "set pr100 1" -highlightbackground [option get . background {}]
		pack $b.read $b.zzz $b.sort -side left -padx 1
		pack $b.quit -side right
		pack $r.readlist -side top -fill x
		pack $f.button $f.reader -side top -fill x
		bind $f <Escape> {set pr100 0}
		bind $f <Return> "ViewSelectedFile $view_prr 0"
		bind $f <space> "UniversalPlay list $view_prr"
	}
	wm resizable $f 1 1

	bind .viewlist <ButtonRelease-1> {HideWindow %W %x %y pr100}

	$view_prr delete 0 end
	if {$invlist_view} {
		foreach fnam $invlist {
			$view_prr insert end $fnam
		}
	} elseif {$from_runpage} {
		if {$ins(run) || $bulk(run)} {
			set namegroup $evv(MACH_OUTFNAME) 	;#	Collects outputs from ALL ins-processes
		} else {
			set namegroup $o_nam					;#	Collects normal outs, or current Instrumentcreateprocess outs
		}
		
		set thisnamegroup $namegroup
		foreach fnam [lsort -dictionary [glob -nocomplain $thisnamegroup*]] {
			set filetype $pa($fnam,$evv(FTYP))
			if {$filetype == $evv(SNDFILE) \
			|| $filetype == $evv(PSEUDO_SND) || $filetype == $evv(ANALFILE)} { 
				$view_prr insert end $fnam
			}
		}					
	} elseif {$ins_concluding} {
		foreach fnam [$ins_file_lst get 0 end] {
			set filetype $pa($fnam,$evv(FTYP))
			if {$filetype == $evv(SNDFILE) \
			|| $filetype == $evv(PSEUDO_SND) || $filetype == $evv(ANALFILE)} { 
				$view_prr insert end $fnam
			}
		}
	} else {
		foreach fnam [$wl get 0 end] {
			set filetype $pa($fnam,$evv(FTYP))
			if {$filetype == $evv(SNDFILE) \
			|| $filetype == $evv(PSEUDO_SND) || $filetype == $evv(ANALFILE)} { 
				$view_prr insert end $fnam
			}
		}
	}
	set pr100 0
	raise $f
	My_Grab 0 $f pr100 $f.reader.readlist

	if {$from_runpage} {
		wm geometry $f [ToRightThird .ppg $f]
	} elseif {$ins_concluding} {
		wm geometry $f [ToRightThird .inspage $f]
	} else {
		wm geometry $f [ToRightThird .workspace $f]
	}

	tkwait variable pr100
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#------ View sndsystem file in SNACK
 
proc ViewSelectedFile {listing last} {
	global vwbl_sndsysout CDPidview viewcnt from_runpage ins_concluding last_played pa invlist_view view_prr pprg evv
	if {!$invlist_view && ($from_runpage || $ins_concluding) && ($vwbl_sndsysout == 1)} {
		set fnam [$listing get 0]
	} else {
		if {$last} {
			if {![info exists last_played]} {
				Inf "No Previous File Played"
				return
			}
			if {![file exists $last_played]} {
				Inf "File No Longer Exists"
				return
			}
			if {![info exists pa($last_played,$evv(FTYP))]} {
				if {![DoMinParse $last_played]} {
					return
				}
			}
			if {$pa($last_played,$evv(FTYP)) != $evv(SNDFILE)} {
				Inf "File No Longer Exists"
				return
			}
			set fnam $last_played
		} else {
			if {[$listing index end] == 1} {
				set i 0
			} else {
				set i [$listing curselection]
				if {[string length $i] <= 0} {
					Inf "No item selected"
					return
				}
			}
			set fnam [$listing get $i]
		}
	}
	if {[Snackable $fnam]} {
		if {[info exists view_prr] && ($listing == $view_prr)} {
			if {$pprg == $evv(MIXCROSS)} {
				SnackDisplay $evv(SN_TIMEPAIRS) mixcross 0 $fnam
			} elseif {($pprg == $evv(MIX_AT_STEP)) && $invlist_view && ([$view_prr curselection] == 0)} {
				SnackDisplay $evv(SN_SINGLETIME) $evv(MIX_AT_STEP) $evv(TIME_OUT) 0
			} else  {
				if {$pa($fnam,$evv(DUR)) * $pa($fnam,$evv(CHANS)) > 300} {
					Block "Creating waveform display"
				}
				SnackDisplay 0 $evv(SN_FILE_PRMPAGE_NO_OUTPUT) 0 $fnam
				if {[winfo exists .blocker]} {
					UnBlock
				}
			}
		} else  {
			if {$pa($fnam,$evv(DUR)) * $pa($fnam,$evv(CHANS)) > 300} {
				Block "Creating waveform display"
			}
			SnackDisplay 0 $evv(SN_FILE_PRMPAGE_NO_OUTPUT) 0 $fnam
			if {[winfo exists .blocker]} {
				UnBlock
			}
		}
	} else {
		if {$pa($fnam,$evv(CHANS)) > 2} {
			if {$pa($fnam,$evv(FTYP)) == $evv(SNDFILE)} {
				Inf "Cannot Display Multichannel Files, in this Display Mode (See System State Menu)"
				return
			} else {
				Inf "Cannot Display Analysis File"
				return
			}
		}
		set cmd [file join $evv(CDPROGRAM_DIR) viewsf]
		if [ProgMissing $cmd "Cannot view the file."] {
			return
		}
		set fnam [OmitSpaces $fnam]
		set cmd [concat $cmd $fnam]
		if [catch {open "|$cmd"} CDPidview($viewcnt)] {
			ErrShow "$CDPidview($viewcnt)"
			catch {unset CDPidview($viewcnt)}
			return
		}
		incr viewcnt
	}
}

#------ Keep the output file(s)

proc KeepOutput {} {
	global prg_ocnt pr8 o_nam ins hst pr3 z_savename keeplist wstk evv
	global keep_sl nu_names names_sl bulk chlist sysname sl_real papag
	global last_outfile zaz_dummy from_instr pprg mmod pa origmixbak bulksplit saved_cmd mchengineer woutlist

	if {($pprg == $evv(SHRINK)) && ($mmod > $evv(SHRM_FINDMX))} {
		set shrink_special 1
	}
	if {!$sl_real} {
		Inf "If You Decide To Keep The File You Have Created,\nYou Are Asked To Give It A Name.\nIt Is Then Saved To Disk And Posted On The Workspace."
		Inf "You Can Then\n1) Run The Process Again With Different Parameters, To Make A New Sound.\n2) Go Get A New Process To Apply To The Same Sound.\n3) Recycle The Output Sound To Use In A New Process.\n4) Go Get A Different Sound."
	}
	if {[info exists mchengineer]} {
		SaveEngineeredFile
		set pr3 0
		set pr2 0
		return
	}
	catch {unset hst(outlist)}
	catch {unset hst(bulkout)}
	set hst(bulkoutcnt) 0
	if {$hst(active)} {
		OriginalHistoryOutfilesDisplay
	}
	if {$prg_ocnt <= 0} {
		Inf "No Outputs To Save"
		return									;#	When making ins, outputs not renamed until very end,
	} elseif {$ins(create)} {				;#	But signal to 'KEEP' implies process-data must be kept!!
		if {![StoreInsProcessData]} {		;#	Can only be file-stored once (internally safeguarded)
			ErrShow "StoreInsProcessData failed"
			BombOut
		}
		set ins(thisprocess_finished) 1		;#	This signals successful completion of a ins-process.
		set pr3 0							;#	This causes calling dialog to return to Process-Menu
									# HISTORY -->
									# at ins(create), individual process hst NOT SAVED
									# Total ins process saved by different route
									# <-- HISTORY
		return
	} elseif {$prg_ocnt > 1} {
		if {$bulk(run)} {
			if {[info exists bulksplit]} {
				if {![JoinMchanFile]} {
					return
				}
				set bulksplit_done 1
				set prg_ocnt 1
			} else {
				foreach fnam [lsort -dictionary [glob -nocomplain $evv(MACH_OUTFNAME)*]] {
					set outexample $fnam
					break
				}
				set kepp_name 1
				foreach in_fnam $chlist {
					if {[string match $in_fnam [file tail $in_fnam]]} {
						set kepp_name 0
						break
					}
				}
				if {$kepp_name || (![string match $pa([lindex $chlist 0],$evv(FTYP)) $pa($outexample,$evv(FTYP))])} {
					set choice [tk_messageBox -type yesno -message "Keep original names?" \
							-icon question -parent [lindex $wstk end]]
					if [string match "yes" $choice] {
						if [DoSameNames] {
							TurnOffOutputButtons
							DoHistory
							PurgeTempThumbnails
							set woutlist 1
							return
						}
					}
				}
				set choice [tk_messageBox -type yesno -message "Generic output extension?" \
							-icon question -parent [lindex $wstk end]]
				if [string match "yes" $choice] {
					if [GenericExtensionCreate] {
						TurnOffOutputButtons
						DoHistory
						PurgeTempThumbnails
						set woutlist 1
						return							;#	If Generic naming succeeds, return
					}									;#	Otherwise drop through to individual naming
				}
			}
		} else {
			if {($pprg == $evv(PITCH)) && ($mmod == 1)} {
				Inf "File 1: Analysis File From Which To Resynth Pitch To Check It\nFile 2: Binary Pitch Data"
			}
			set do_genericnamecreate 0
			if {[info exists shrink_special]} {
				set do_genericnamecreate 1
			} else {
				set choice [tk_messageBox -type yesno -message "Generic output name?" -icon question -parent [lindex $wstk end]]
				if [string match "yes" $choice] {
					set do_genericnamecreate 1
				}
			}
			if {$do_genericnamecreate} {
				if [GenericNameCreate] {
					if [info exists hst(outlist)] {		;#	If files are retained, save details to hst
						if {$ins(run)} {
							set from_instr 1
						}
						DoHistory
						catch {unset from_instr}
					}
					set woutlist 1
					TurnOffOutputButtons
					PurgeTempThumbnails
					return							;#	If Generic naming succeeds, return
				}									;#	Otherwise drop through to individual naming
			}
		}
	}
	PurgeTempThumbnails
	set f .keeplist
	if [Dlg_Create $f "Save List" "set pr8 1" -borderwidth $evv(BBDR)] {
		set b [frame $f.button -borderwidth $evv(SBDR)]
		set n [frame $f.name -borderwidth $evv(SBDR)]
		set a [frame $f.a -borderwidth $evv(SBDR)]
		set s [frame $f.saver -borderwidth $evv(SBDR)]
		label $a.arrow -text "Up Arrow: incr name(end)     Dn Arrow: decr name(end)"
		label $a.arrw2 -text "Cntrl Up: incr name(start)   Cntrl Dn: decr name(start)"
		pack $a.arrow -side top
		pack $a.arrw2 -side top
		set keep_sl [Scrolled_Listbox $s.keepers -height 10 -selectmode single -width 40]
		pack $s.keepers -side top -fill x
		label $s.laba -text "Recent Names"
		set names_sl [Scrolled_Listbox $s.names -height $evv(NSTORLEN) -selectmode single -width 40]
		label $s.labb -text "Recent Source Names"
		Scrolled_Listbox $s.namesb -height $evv(NSTORLEN) -selectmode single -height 3 -width 40
		label $s.bbb -text "standard names"
		menubutton $s.bxxb -text "Standard Names" -width 17 -menu $s.bxxb.menu -bd 2  -relief raised ;# -bg $evv(HELP)
		menubutton $s.bxxb2 -text "Standard Suffixes" -menu $s.bxxb2.menu -bd 2 -bg $evv(HELP) -relief raised
		set zlob [menu $s.bxxb.menu  -tearoff 0]
		MakeStandardNamesMenu $zlob $f.name.name 0
		set zlob2 [menu $s.bxxb2.menu  -tearoff 0]
		MakeStandardSuffixesMenu $zlob2 $f.name.name 0
		set ku [frame $s.bbbb]
		button $ku.bb1 -text "$sysname(1)" -command "PutName .keeplist.name.name $sysname(1)" -highlightbackground [option get . background {}]
		button $ku.bb2 -text "$sysname(2)" -command "PutName .keeplist.name.name $sysname(2)" -highlightbackground [option get . background {}]
		button $ku.bb3 -text "$sysname(3)" -command "PutName .keeplist.name.name $sysname(3)" -highlightbackground [option get . background {}]
		button $ku.bb4 -text "$sysname(4)" -command "PutName .keeplist.name.name $sysname(4)" -highlightbackground [option get . background {}]
		button $ku.bb5 -text "$sysname(5)" -command "PutName .keeplist.name.name $sysname(5)" -highlightbackground [option get . background {}]
		pack $s.bbb $s.bbbb $s.bxxb $s.bxxb2 -side top -pady 1
		pack $ku.bb1 $ku.bb2 $ku.bb3 $ku.bb4 $ku.bb5 -side left -padx 1
		pack $s.labb $s.namesb $s.laba $s.names -side top -fill x

		button $b.save -text "Save" -command "KeepSelectedFile $keep_sl" -highlightbackground [option get . background {}]
		radiobutton $b.clear -variable dummy -text Clear -command {set z_savename ""}
		button $b.quit -text "Close" -command "set pr8 1" -highlightbackground [option get . background {}]
		pack $b.save -side left
		pack $b.quit $b.clear -side right
		label $n.l -text "Name"
		entry $n.name -width 20 -textvariable z_savename
		pack $n.l $n.name -side left
		pack $f.button -side top -fill x -expand true
		pack $f.name $f.a $f.saver -side top
		bind $f.name.name <Up> "AdvanceNameIndex 1 z_savename 0"
		bind $f.name.name <Down> "AdvanceNameIndex 0 z_savename 0"
		bind $f.name.name <Up> "AdvanceNameIndex 1 z_savename 0"
		bind $f.name.name <Down> "AdvanceNameIndex 0 z_savename 0"

		bind $f.name.name <Control-Up> "AdvanceNameIndex 1 z_savename 1"
		bind $f.name.name <Control-Down> "AdvanceNameIndex 0 z_savename 1"
		bind $f.name.name <Control-Up> "AdvanceNameIndex 1 z_savename 1"
		bind $f.name.name <Control-Down> "AdvanceNameIndex 0 z_savename 1"

		bind $f <Control-s>  "KeepSelectedFile $keep_sl"
		bind $f <Control-S>  "KeepSelectedFile $keep_sl"
		bind $f <Key-space> "PlayFromSave"
		bind $f <Control-p> "PlayFromSave"
		bind $f <Control-P> "PlayFromSave"
		bind $f <Return> "KeepSelectedFile $keep_sl"
		bind $f <Escape> {set pr8 1}
	}
	bind .keeplist.saver.names.list <ButtonRelease-1> {NameListChoose .keeplist.saver.names.list .keeplist.name.name}
	bind .keeplist.saver.namesb.list <ButtonRelease-1> {NameListChoose .keeplist.saver.namesb.list .keeplist.name.name}

	wm resizable $f 1 1
	$keep_sl delete 0 end
	if {$ins(run) || $bulk(run)} {
		set namegroup $evv(MACH_OUTFNAME)	;#	Collects outputs from ALL ins-processes
	} else {
		set namegroup $o_nam				;#	Collects normal outs, or current Instrumentcreateprocess outs
	}
	set thumnam $namegroup					;#	Ignores any temporary thumbnails made (with name cdptest000)
	append thumnam "00*"
	append namegroup "*"
	foreach fnam [lsort -dictionary [glob -nocomplain $namegroup]] {	;#	Find the files
		if {[info exists origmixbak] && [string match $origmixbak $fnam]} {
			continue
		}
		if {[string match $thumnam $fnam]} {
			continue
		}
		$keep_sl insert end $fnam
		lappend hst(bulkout) $fnam
	}					
	if [info exists nu_names] { 
		$names_sl delete 0 end
		foreach nname $nu_names {	;#	Post recent names
			$names_sl insert end $nname
		}					
		$names_sl xview moveto 0.0
	}
 	.keeplist.saver.namesb.list delete 0 end
	.keeplist.saver.namesb.list xview moveto 0.0
	if {[info exists ins(chlist)] && ([llength $ins(chlist)] > 0)} {
		set thisl $ins(chlist)
	} elseif {[info exists chlist] && ([llength $chlist] > 0)} {
		set thisl $chlist
	}
	if [info exists thisl] { 
		set i 0
		foreach nname $thisl {	;#	Post source names
			.keeplist.saver.namesb.list insert end [file rootname [file tail $nname]]
			incr i
			if {$i >= 2} {
				break
			}
		}					
	}
	if {$hst(active) && [info exists hst(outfiles)] && ([llength $hst(outfiles)] > 0)} {
		set qwe [lindex $hst(outfiles) 0]
		set qqq1 [string last ">" $qwe]
		set qqq2 [string last "." $qwe]
		incr qqq1
		incr qqq2 -1
		if {($qqq1 < 0) || ($qqq2 < 0) || ($qqq2 <= $qqq1)} {
			set z_savename ""
		} else {
			set qwe [string range $qwe $qqq1 $qqq2]
			set z_savename $qwe
		}
	}
	catch {set remem_last_outfile $last_outfile}
	catch {unset last_outfile}
	set pr8 0
	raise $f
	My_Grab 0 $f pr8 $f.name.name
	tkwait variable pr8
	if {!$sl_real} {
		Inf "If You Have Saved The File, With A New Name\nYour File Would Now Be Saved To Disk,\nAnd Listed On The Workspace."
		TurnOffOutputButtons
		$papag.parameters.zzz.mabo config -state normal
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	if {![info exists last_outfile]} {
		catch {set last_outfile $remem_last_outfile}
	}
	if {[info exists hst(outlist)] || ($hst(bulkoutcnt) > 0)} {		;#	If files are retained, save details to hst
		if {$ins(run)} {
			set from_instr 1
		}
		if {[info exists saved_cmd]} {		;#	panprocess does not preserve the cmd at present
			DoHistory
		}
		catch {unset from_instr}
	}
	if {[info exists zaz_dummy]} {
		foreach item $zaz_dummy {
			DummyHistory $item OVERWRITTEN_AS_RESULT
		}
		unset {zaz_dummy}
	}
	if {[info exists bulksplit_done]} {		;#	After bulksplit completed: force return to wkspace
		GetNewFilesFromPpg
	}
}

#------ Get Name from Namelist

proc NameListChoose {w e} {
	$e delete 0 end
	foreach i [$w curselection] {
		$e insert 0 [$w get $i]
	}
}

#------ Keep file selected from list

proc KeepSelectedFile {sl} {
	global wl z_savename prg_ocnt pr8 last_outfile has_saved has_saved_at_all names_sl rememd sl_real bulk hst
	global ins papag pprg mmod wkspace_newfile lastmixio chlist main_mix

	if {!$sl_real} {
		set pr8 1
		return
	}

	set z_savename [string tolower $z_savename]
	set savename [FixTxt $z_savename "filename"]
	if {[string length $savename] <= 0} {
		return
	}
	if {$prg_ocnt == 1} {
		set i 0
	} else {
		set i [$sl curselection]
		if {[string length $i] <= 0} {
			Inf "No Item Selected"
			return
		}
	}
	set fnam [$sl get $i]
	set newname [OutfileKeep $fnam $savename]	;#	Generates full output name
	if {[string length $newname] > 0} {
		$sl delete $i								;#	Delete from save list
		$wl insert 0 $newname						;#	Add to start of workspace
		set wkspace_newfile 1
		WkspCntSimple 1
		catch {unset rememd}
		incr prg_ocnt -1
		set has_saved 1
		set has_saved_at_all 1
		if $bulk(run) {
			set k [lsearch $hst(bulkout) $fnam]
			set a $fnam
			append a "->"
			append a $newname
			set hst(bulkout) [lreplace $hst(bulkout) $k $k $a]
			incr hst(bulkoutcnt)
		}
		if {!$ins(run)} {
			$papag.parameters.zzz.mabo config -state normal
		}
		AddNameToNameslist $savename $names_sl
		lappend last_outfile $newname
		if {$prg_ocnt <= 0} {
			if {[ProcessHasSingleOutfile $pprg $mmod] && !$bulk(run) && !$ins(run)} { 
				EnableExtraBatchButtons
				if [IsBasicMixProcess] {
					set mxxfil [lindex $chlist 0]
					if {[info exists main_mix]} {							;#	If a main mix has been established
						if {[string match $mxxfil $main_mix(fnam)]} {		;#	If we're currently working on it
							set lastmixio [list $mxxfil $newname]			;#	Remember the name of the sndfile output from the mix
						}
					} else {												;#	If NO main mix has been established
						set lastmixio [list $mxxfil $newname]				;#	Remember the name of the mixfile and the sndfile output from the mix
					}
				}
			}
			TurnOffOutputButtons
			set pr8 1
		}		
	}
}

#------ Turn Off ppg buttons to do with keeping or viewing/hearing output

proc TurnOffOutputButtons {} {
	global ppg_emph papag pprg mmod ins evv
	set thismode $mmod
	incr thismode -1
	catch {unset ppg_emph}
	lappend ppg_emph $papag.parameters.zzz.newp $papag.parameters.zzz.newf
	$papag.parameters.output.oput config -text ""
	$papag.parameters.output.keep config -bg [option get . background {}] \
		-fg [option get . foreground {}] -state disabled
	$papag.parameters.output.play config -bg [option get . background {}] -state disabled
	$papag.parameters.output.read config -bg [option get . background {}] -state disabled
	$papag.parameters.output.view config -bg [option get . background {}] -state disabled
	$papag.parameters.output.props config -state disabled
	$papag.parameters.output.mxsmp config -state disabled
	if {!$ins(run)} {
		if {($pprg == $evv(EQ)) || ($pprg == $evv(LPHP)) || ($pprg == $evv(FSTATVAR)) \
		|| ($pprg == $evv(FLTBANKN)) || ($pprg == $evv(FLTBANKU)) || ($pprg == $evv(FLTBANKV2)) \
		|| ($pprg == $evv(FLTSWEEP)) || ($pprg == $evv(FLTITER)) || ($pprg == $evv(ALLPASS)) } {
			$papag.parameters.output.editqik config -bd 0 -text "" -command {} -bg [option get . background {}]
		} elseif {$pprg == $evv(FLTBANKV)} {
			$papag.parameters.output.editqik config -text "Randomise" -command ScatterFilter -bd 2 -state normal
		} elseif {$pprg == $evv(PSOW_FEATURES)} {
			$papag.parameters.output.editqik config -bd 2 -text "Gain" -command "GainParamAtten psow" -bg $evv(EMPH) -state normal
		} elseif {($pprg == $evv(MOD_REVECHO)) && ($thismode == 2)} {
			$papag.parameters.output.editqik config -bd 2 -text "Gain" -command "GainParamAtten stadium" -bg $evv(EMPH) -state normal
		} elseif {$pprg == $evv(MCHANREV)} {
			$papag.parameters.output.editqik config -bd 2 -text "Gain" -command "GainParamAtten stadium" -bg $evv(EMPH) -state normal
		} elseif {($pprg == $evv(HOUSE_EXTRACT)) && ($thismode == 2)} {
			$papag.parameters.output.editqik config -bd 2 -text "CutBy" -command "TopnTailResult" -bg $evv(EMPH) -state normal
		}
	}
}

proc EnableExtraBatchButtons {} {
	global papag
	$papag.patches.batch.2.b1 config -state normal -text "+Outname" -bd 2
	$papag.patches.batch.2.b2 config -state normal -text "+Outname" -bd 2
	$papag.parameters.zzz.nns.m entryconfig 4 -label "Keep Params, Infiles & Outfile" -command "NnnGetParams 1 1"
}

proc DisableExtraBatchButtons {} {
	global papag
	$papag.patches.batch.2.b1 config -state disabled -text "" -bd 0
	$papag.patches.batch.2.b2 config -state disabled -text "" -bd 0
	$papag.parameters.zzz.nns.m entryconfig 4 -label "" -command {}
}

#------ Rename a created file, to save it (un-renamed files are automatically deleted)

proc OutfileKeep {origname newname} {
	global hst wl wstk pa ch rememd evv new_cdp_extensions ins pprg mmod chlist zaz_dummy mixmanage ambisonic_to_wav ambwxyz main_mix
	global woutlist

	set newname [FixTxt $newname "new name"]
	if {[string length $newname] <= 0} {
		Inf "No Valid New Name Given."
		return ""
	}
	if {![ValidCDPRootname $newname]} { 
		return ""
	}
	set extname [file extension $origname]
	set fnam "$newname"

	if {$new_cdp_extensions} {
		set extname [GetFileExtension $origname]
	}
	if {[AmbisonicOut $pprg] && !$ambisonic_to_wav} {
		set extname ".amb"
	} elseif {[info exists ambwxyz]} {
		set extname ".wxyz"
		unset ambwxyz
	}
	if {[string match $extname ".brk"]} {
		if {[expr $pa($origname,$evv(LINECNT)) * 2] != $pa($origname,$evv(NUMSIZE))} {
			set extname $evv(TEXT_EXT)
		}
	}
	set fnam $fnam$extname				
	if {[LstIndx $fnam $ch] >= 0} {
		Inf "'$fnam' Is An Input File To This Process: You Cannot Overwrite It Here.\n(You Can Return To Workspace To Force Renaming)"
		return ""
	}
	set save_mixmanage 0
	if [file exists $fnam] {
		set choice [tk_messageBox -type yesno -message "File exists: Overwrite?" \
					-icon question -parent [lindex $wstk end]]
		if [string match "no" $choice] {
			return ""
		} else {
			if {![DeleteFileFromSystem $fnam 1 0]} {
				return ""
			}
			if {[info exists mixmanage($fnam)]} {
				unset mixmanage($fnam)
				set save_mixmanage 1
			}
			if {[IsInAMixfile $fnam]} {
				lappend mixmanage_deletes $fnam
			}
		}										
		lappend zaz_dummy $fnam
		set i [LstIndx $fnam $wl]	;#	remove from workspace listing
		if {$i >= 0} {
			$wl delete $i
			WkspCntSimple -1
			catch {unset rememd}
		}
	} 
	if [catch {file rename $origname $fnam} ] {
		ErrShow "Cannot rename file\nIt may be open for PLAY, READ or VIEW\nClose it, to proceed."
		return ""
	}
	if {[IsBasicMixProcess] && [info exists main_mix(fnam)] && [info exists chlist] && [string match [lindex $chlist 0] $main_mix(fnam)]} {
		set main_mix(snd) $fnam
		MainMixButton 0
	}
	if {!$ins(create) && [PitchReproducing $pprg $mmod]} {
		set srcfnam [lindex $chlist 0]
		if [HasPmark $srcfnam] {
			CopyPmark $srcfnam $fnam
		}
		if [HasMmark $srcfnam] {
			CopyMmark $srcfnam $fnam
		}
	}
	set a $origname
	append a "->"
	append a $fnam
	lappend hst(outlist) "$a"
	RenameProps $origname $fnam 0
	if {[UpdatedIfAMix $fnam 0]} {
		set save_mixmanage 1					;#	IF FILE IS A MIXFILE, UPDATE MIX MANAGER
	}
	if {[MixMPurge 0]} {						;#	CHECK IF ANY MIXFILE HAS BEEN DELETED
		set save_mixmanage 1
	}
	if {[info exists mixmanage_deletes]} {		;#	CHECK IF ANY SOUNDFILE WITHIN A MIXFILE HAS BEEN DELETED
		foreach fnam $mixmanage_deletes {
			if {[IsInAMixfile $fnam] && ![file exists $fnam]} {
				if {[MixM_ManagedDeletion $mixmanage_deletes]} {
					set save_mixmanage 1
				}
			}
		}
	}
	if {$save_mixmanage} {						;# IF MIX MANAGEMENT DATA CHANGED, SAVE TO DISK
		MixMStore
	}
	GenerateSrcList $fnam
	set woutlist 1
	return $fnam
}

#------ Attempt to give a generic name to the several outputs

proc GenericNameCreate {} {
	global wl pr9  o_nam hst ins gname generic evv chlist rememd pprg mmod
	global pa nu_names names_g last_outfile prg_ocnt has_saved has_saved_at_all
	global wksp_cnt total_wksp_cnt ww names_sl papag pprg new_cdp_extensions
	global wkspace_newfile generic_underscore generic_from_one channelxchan generic_channels

	if {($pprg == $evv(SHRINK)) && ($mmod > $evv(SHRM_FINDMX))} {
		set shrink_special 1
	}
	if {![info exists generic_underscore]} {
		set generic_underscore 1
	}
	if {![info exists generic_from_one]} {
		set generic_from_one 1
	}
	set g .generic
	if [Dlg_Create $g "Generic Name" "set pr9 0" -borderwidth $evv(BBDR)] {
		set gn [frame $g.name -borderwidth $evv(SBDR)]
		set go [frame $g.other -borderwidth $evv(SBDR)]
		button $gn.b -text Close -width 6 -command "set pr9 0" -highlightbackground [option get . background {}]
		label $gn.l -text "" -width 4
		button $gn.ok -text OK -width 6 -command "set pr9 1" -highlightbackground [option get . background {}]
		checkbutton $gn.us -text "force \"_\"" -variable generic_underscore
		checkbutton $gn.f1 -text "from 1" -variable generic_from_one -width 6
		entry $gn.e -width 20 -textvariable gname
		checkbutton $gn.cc -text "Numbered Channels" -variable generic_channels -width 17 
		pack $gn.ok $gn.us $gn.f1 $gn.e $gn.cc -side left
		pack $gn.b $gn.l -side right
		label $go.laba -text "Recent Names"
		set names_g [Scrolled_Listbox $go.nunames -height $evv(NSTORLEN) -selectmode single]
		label $go.labb -text "Recent Source Names"
		set names_i [Scrolled_Listbox $go.nunamesb -height $evv(NSTORLEN) -selectmode single]
		bind .generic.other.nunames.list <ButtonRelease-1> {NameListChoose .generic.other.nunames.list .generic.name.e}
		bind .generic.other.nunamesb.list <ButtonRelease-1> {NameListChoose .generic.other.nunamesb.list .generic.name.e}
		pack $go.labb $go.nunamesb $go.laba $go.nunames -side top -fill x
		pack $g.name $g.other -side top
		bind .generic.name.e <Up>   "AdvanceNameIndex 1 gname 0"
		bind .generic.name.e <Down> "AdvanceNameIndex 0 gname 0"
		bind .generic.name.e <Control-Up>   "AdvanceNameIndex 1 gname 1"
		bind .generic.name.e <Control-Down> "AdvanceNameIndex 0 gname 1"
		bind .generic <Return> {set pr9 1}
		bind .generic <Escape> {set pr9 0}
		wm resizable $g 1 1
	}
	if {($pprg == $evv(HOUSE_CHANS)) && ($mmod == 2)} {
		.generic.name.cc config -text "Numbered Channels" -state normal -command DoNumberedChans
		set generic_channels 1
	} else {
		set generic_channels 0
		.generic.name.cc config -text "" -state disabled
	}
	if {$ins(run) || [info exists channelxchan]} {
		$g.name.f1 config -text "" -state disabled
	} else {
		$g.name.f1 config -text "from 1" -state normal
	}
	if [info exists nu_names] { 
		.generic.other.nunames.list delete 0 end
		foreach nname $nu_names {	;#	Post recent names
			.generic.other.nunames.list insert end $nname
		}					
		.generic.other.nunames.list xview moveto 0.0
	}
	.generic.other.nunamesb.list delete 0 end
	.generic.other.nunamesb.list xview moveto 0.0
	if {[info exists ins(chlist)] && ([llength $ins(chlist)] > 0)} {
		set thisl $ins(chlist)
	} elseif {[info exists chlist] && ([llength $chlist] > 0)} {
		set thisl $chlist
	}
	if [info exists thisl] { 
		set i 0
		foreach nname $thisl {	;#	Post source names
			.generic.other.nunamesb.list insert end [file rootname [file tail $nname]]
			incr i
			if {$i >= 2} {
				break
			}
		}					
	}
 	if {$ins(run)} {
		set namegroup $evv(MACH_OUTFNAME)	;#	Collects outputs from ALL ins-processes
	} else {
		set namegroup $o_nam				;#	Collects normal outs, or current Instrumentcreateprocess outs
	}
	append namegroup "*"

	if {![info exists ins(chlist)] && [info exists chlist] && ([llength $chlist] == 1)} {
		set gname [file rootname [file tail [lindex $chlist 0]]]
		if {($pprg == $evv(HOUSE_CHANS)) && ($mmod == 2)} {
			append gname "_c"
		}
	} else {
		set gname ""
	}
	set finished 0
	set pr9 0
	raise $g
	My_Grab 0 $g pr9 $g.name.e
	while {!$finished} {
		tkwait variable pr9

		if {$pr9} {				  						;#	Entered a generic name
			set gname [string tolower $gname]
			set gname [FixTxt $gname "generic name"]
			if {[string length $gname] <= 0} {
				ForceVal $g.name.e $gname
				continue
			}
			if [ValidCDPRootname $gname] {					;#	Test for valid CDP name
;# 2023
				set can_use_same_name 1
				foreach fnam [lsort -dictionary [glob -nocomplain $namegroup]] {	;#	Find the files
					set extname [file extension $fnam]				;#	Get its extension
					if {![info exists test_exts]} {
						lappend test_exts $extname
					} else {
						if {[lsearch $test_exts $extname] >= 0} {
;# 2023                     
							set can_use_same_name 0
							break
						} else {
							lappend test_exts $extname
						}
					}
				}
				set OK 0
;# 2023
				if {$can_use_same_name} {
					set OK 1
					foreach extname $test_exts {
						set test_nam $gname$extname
						if {[file exists $test_nam]} {
							set OK 0
						}
					}
				}
				catch {unset test_exts}
				if {!$OK} {
					set OK 1								;#	Test that generic name is not already in use
					if {($pprg == $evv(FOFEX_EX)) && ($mmod == 1)} {
						set fnam $gname
						set s_nam $gname$evv(SNDFILE_EXT)
						set b_nam $gname
						append b_nam [GetTextfileExtension brk]
						if {[file exists $s_nam]} {
							set orig_fnam $s_nam
							set OK 0
						} elseif {[file exists $b_nam]} {
							set orig_fnam $b_nam
							set OK 0
						}
					} else {
						if {$generic_underscore || [regexp {[0-9]+$} $gname]} {		;#	Test that there's no numeral at end
							append gname "_"
						}
						set basename $gname
						set baselen [string length $basename]
						foreach fnam [glob -nocomplain "$basename*"] {	
							if {![file isdirectory $fnam]} {
								set orig_fnam $fnam
								set fnam [file rootname $fnam]
								if {[string length $fnam] > $baselen} {
									set zstr [string range $fnam $baselen end]
									if [regexp {^[0-9]+\.*} $zstr] {
										set OK 0
										break
									}
								}			;#	Test that generic name is not already in use
								if {[info exists shrink_special]} {
									if {[string length $fnam] == $baselen} {
										if {[string match [file extension $orig_fnam] $evv(TEXT_EXT)] \
										||  [string match [file extension $orig_fnam] [GetTextfileExtension mix]]} {
											if {[file exists $orig_fnam]} {
												set OK 0
												break
											}
										}
									}
								}
							}
						}
					}
				}
				if {$OK} {
					AddNameToNameslist $gname $names_g
					set finished 1
				} else {
					Inf "Files Already Exist With The Name $fnam"
				}				
			}
		} else {											;#	On ABANDON being pressed, finish
			set finished 1
		}
	}
	My_Release_to_Dialog $g
	Dlg_Dismiss $g
	if {$pr9 == 0} {										;#	If ABANDONed, return 0								
		return 0		
	}
	set i 0
	catch {set remem_last_outfile $last_outfile}
	catch {unset last_outfile}
	set pitch_reproducing  ""
	set mel_reproducing  ""
	if {!$ins(create) && [PitchReproducing $pprg $mmod]} {
		set srcfnam [lindex $chlist 0]
		if [HasPmark $srcfnam] {
			set pitch_reproducing $srcfnam
		}
		if [HasMmark $srcfnam] {
			set mel_reproducing $srcfnam
		}
	}
	foreach fnam [lsort -dictionary [glob -nocomplain $namegroup]] {	;#	Find the files
		set extname [file extension $fnam]				;#	Get its extension
		if {$ins(run)} {
			set no $i										;#	For doInstrument-output, number incrementally
		} else {											;#	But for single process output...
			set thisrootname [file tail $fnam]								;# 	a/b/test4.wav - > test4.wav
			set thisrootname [file rootname $thisrootname]					;#	test4.wav -> test4
			set no [string range $thisrootname [string length $o_nam] end]	;#	WHY? 
			if {[info exists channelxchan]} {
				set no [lindex $channelxchan $no]
			} elseif {$generic_from_one} {
				incr no
			}
		}													
;# 2023 ---->
		if {$new_cdp_extensions} {
			set extname [GetFileExtension $fnam]
		}
		if {$can_use_same_name} {
			set newname $gname$extname
		} else {
;# <---- 2023
			if {[info exists shrink_special]} {
				if {[string match [file extension $fnam] $evv(TEXT_EXT)]} {
					set newname $gname$extname
				} elseif {[string match [file extension $fnam] [GetTextfileExtension mix]]} {
					set newname $gname$extname
					ReplaceInternalNames $fnam $gname
				} else {
					set newname $gname$no$extname
				}
			} else {
				set newname $gname$no$extname					;#	Replace name by genericname
			}
		}

		if [catch {file rename $fnam $newname}] {
			ErrShow "Cannot rename file\nIt may be open for PLAY, READ or VIEW\nClose it, to proceed."
			if {![info exists last_outfile]} {
				catch {set last_outfile $remem_last_outfile}
			}
			catch {unset channelxchan}
			return 0
		}

		set a $fnam
		append a "->"
		append a $newname
		lappend hst(outlist) "$a"

		RenameProps $fnam $newname 0						;#	Rename properties
		if {[UpdateIfAMix $newname 0]} {
			set save_mixmanage 1
		}
		if {[string length $pitch_reproducing] > 0} {
			CopyPmark $pitch_reproducing $newname
		}
		if {[string length $mel_reproducing] > 0} {
			CopyMmark $mel_reproducing $newname
		}
		lappend genfiles $newname
		lappend last_outfile $newname
		incr i
	}
	catch {unset channelxchan}
	if {[info exists genfiles]} {
		set genfiles [ReverseList $genfiles]
		foreach newname $genfiles {
			GenerateSrcList $newname
			$wl insert 0 $newname								;#	Add to start of workspace
			incr wksp_cnt
			incr total_wksp_cnt
		}
		set wkspace_newfile 1
		catch {unset rememd}
		if {[info exists save_mixmanage]} {
			MixMStore
		}
	}
	ForceVal $ww.1.a.endd.l.cnts.new $wksp_cnt
	ForceVal $ww.1.a.endd.l.cnts.all $total_wksp_cnt
	ReMarkWkspaceCount
	set prg_ocnt 0
	set has_saved 1
	set has_saved_at_all 1
	if {!$ins(run)} {
		$papag.parameters.zzz.mabo config -state normal
	}
	return 1
}
		
#------ Establish cmdline to send to 'cdparams' to get parameter specifications for window

proc SetupCdparamsCmdline {} {
	global pprg mmod chlist ins evv pa sl_real is_crypto

	if {$ins(create)} {
		if [info exists ins(chlist)] {
			set thischosenlist "$ins(chlist)"
		}
	} else {
		if [info exists chlist] {
			set thischosenlist "$chlist"
		}
	}
	if {!$sl_real} {
		set cmd [file join $evv(CDPROGRAM_DIR) cdparsyn]
	} elseif {[IsReleaseFiveProg $pprg]} {	
		set cmd [file join $evv(CDPROGRAM_DIR) cdparams]
	} else {
		set cmd [file join $evv(CDPROGRAM_DIR) cdparams_other]
	}
	set cmd [concat $cmd $pprg $mmod]			;# program number & mode number
	if [info exists thischosenlist] {
		set filecnt [llength $thischosenlist]
	} else {
		set filecnt 0
	}
	lappend cmd $filecnt
	if {$filecnt > 0} {
		set fnam [lindex $thischosenlist 0]	;# props (of file0) which help set variable ranges
		set i 0
		while {$i < $evv(CDP_FIRSTPASS_ITEMS)} {
			lappend cmd $pa($fnam,$i)
			incr i
		}
	} else {								;#	If no infile, send a dummy set of props
		set i 0
		while {$i < $evv(CDP_FIRSTPASS_ITEMS)} {
			lappend cmd 0
			incr i
		}
	}
	return $cmd
}

#------ This is the main procedure for getting parameters and Running program

proc GotoProgram {} {
	global pprg mmod again ppg pprg prg brk lastrangetype pmcnt ins pim in_recycle
	global chlist last_chlist bulk origmixbak evv mchengineer wstk mixfulldur mixmaxdur pa

											;#	may not exist yet, if running hst
	if {[info exists pim] && [info exists $pim]} {
		if [IsMchanToolkit] {
			set str "Getting Parameter Details for [GetMchanToolKitProgname $pprg]"
		} else {
			set str "Getting Parameter Details for [string toupper [lindex $prg($pprg) 1]]" 
		}
		$pim.help.help config -fg $evv(SPECIAL) -text $str 
	}
											;#	if a new process has been selected
	if {$ins(was_penult_process)} {
		catch {destroy .ppg}
		ClearProcessDependentItems
		set pmcnt 0						;#	pmcnt will be set or reset at Gadget_Creation

	} elseif { $pprg != $again(0)  ||  $mmod != $again(1)} {
		if {$again(0) > 0} {				;#	if there was a previous process
			catch {destroy .ppg}		;#	destroy the associated get-params-dialog
		}
		ClearProcessDependentItems			;#	pmcnt will be set or reset at Gadget_Creation
		set pmcnt 0						;#	Otherwise the previous pmcnt is retained

	} else {
		if {$ins(create)} {
			if {[info exists ins(chlist)] && ([llength $ins(chlist)] > 0)} {
				set this_chosenlist $ins(chlist)
			}
		} elseif {[info exists chlist] && ([llength $chlist] > 0)} {
			if {![info exists mchengineer]} {
				set this_chosenlist $chlist
			}
		}
		if [info exists last_chlist] {				;#	if theres a past list of files
			if {![info exists this_chosenlist]} {		;#	if there's now no list, destroy ppg
				catch {destroy .ppg}				
				ClearProcessDependentItems
				set pmcnt 0							;#	else if the lists are not same length, destroy ppg
			} elseif {[llength $last_chlist] != [llength $this_chosenlist]} {
				catch {destroy .ppg}				
				ClearProcessDependentItems
				set pmcnt 0
			} else {									;#	else if lists not identical, destroy ppg
				foreach mlast $last_chlist mthis $this_chosenlist {
					if {![string match $mlast $mthis]} {
						catch {destroy .ppg}
						ClearProcessDependentItems
						set pmcnt 0
						break
					}
				}
			}											;#	if there's no past list of files
		} elseif [info exists this_chosenlist] {	 	;#	but there is one now, destroy paramage
			catch {destroy .ppg}
			ClearProcessDependentItems
			set pmcnt 0
		}
	}
	if [info exists this_chosenlist] {
		set last_chlist $this_chosenlist
	}

	set again(0) $pprg					;#	Save choice of program/mode
	set again(1) $mmod					;#	to be utilised by 'again' function, next time round

	set brk(endtimeset) 0					;#	global variable	re endtime-of-brktables-used

	catch {unset lastrangetype}				;#	initialise memory for penultimate process-run (!!) 

	if {($pprg == $evv(P_FIX)) && [PitchEditorValid "Cannot graphically edit pitchfile"]} {
		DoPitchDisplay [lindex $chlist 0]
		return
	}
	if {$bulk(run) && (($pprg == $evv(MIXMULTI)) || ($pprg == $evv(MIX)))} {
		set msg "Run Full Mixes Independent Of Duration Of Outputs ??"
		set choice [tk_messageBox -type yesno -message $msg -icon question -parent [lindex $wstk end]]
		if {$choice == "yes"} {
			catch {unset mixmaxdur}
			set mixfulldur 1
		} else {
			catch {unset mixfulldur}
			set mixdur $pa([lindex $chlist 0],$evv(DUR))
			set len [llength $chlist]
			set n 1
			while {$n < $len} {
				if {$pa([lindex $chlist $n],$evv(DUR)) < $mixdur} {
					set mixdur $pa([lindex $chlist $n],$evv(DUR))
					set tell 1
				}
				incr n
			}
			if {[info exists tell]} {
				Inf "Maximum Mix End Parameter, For Bulk Processing, Is $mixdur"
				set mixmaxdur $mixdur
			}
		}
	}
	GetParamsAndRunProgram
	if {[IsMixProcess]} {
		if {[info exists origmixbak] && [file exists $origmixbak]} {
			if [catch {file delete $origmixbak} zat] {
				Inf "Cannot Delete Backup Copy Of Original Mix ($origmixbak)\nDelete This Now (Outside The Loom) Before Proceeding"
			}
		}
	}
}

#------ If the process is applicable to the current file(s), set it to run
 
proc RerunProgram {} {
	global pprg pmask ins pr2 set has_saved_at_all in_recycle pseudoprog last_pseudoprog stage_last disstage_last bulksplit

	if {[info exists bulksplit]} {
		Inf "Cannot Rerun a Process if Bulk Processing a Multichannel file."
		return	
	}
	if {[info exists stage_last]} {
		SetStage
		return
	} elseif {[info exists disstage_last]} {
		SetDisStage
		return
	}
	if {$ins(was_last_process_used)} {
		if {$in_recycle} {
			Inf "For Safety, As Files Have Been Recycled,\nReturn To Workspace Before Re-running The Instrument."
		} else {
			set ins(recall) 1
			set ins(run) 1
			set pr2 1
		}
	} elseif {$pprg == 0} {
		Inf "No Previous Process Has Been Run"
	} else {
		if {[info exists last_pseudoprog]} {
			set pseudoprog $last_pseudoprog
			set pprg [PseudoProg $pseudoprog] 
			unset last_pseudoprog
		}
		if {![string index $pmask $pprg]} {
			Inf "This Process Will Not Run With The Selected Input File(s)"
		} else { 
			set pr2 1 				;# automatically activates program $pprg $mmod
		}
	}
	set has_saved_at_all 0
}

#------ Attempt to give a generic extension to the several outputs

proc GenericExtensionCreate {} {
	global wl prompt999 hst ins gname generic evv papag pprg mmod genextstart rememd
	global names_g last_outfile prg_ocnt has_saved has_saved_at_all chlist
	global wksp_cnt total_wksp_cnt ww new_cdp_extensions hst wkspace_newfile

	set g .genericx
	if [Dlg_Create $g "Generic Extension" "set prompt999 0" -borderwidth $evv(BBDR)] {
		set gn [frame $g.name -borderwidth $evv(SBDR)]
		set gw [frame $g.where -borderwidth $evv(SBDR)]
		button $gn.b -text Close -width 6 -command "set prompt999 0" -highlightbackground [option get . background {}]
		label $gn.l -text "" -width 4
		button $gn.ok -text OK -width 6 -command "set prompt999 1" -highlightbackground [option get . background {}]
		entry $gn.e -width 20 -textvariable gname
		pack $gn.ok $gn.e -side left
		pack $gn.b $gn.l -side right
		radiobutton $gw.1 -variable genextstart -text "At Start" -value 1
		radiobutton $gw.2 -variable genextstart -text "At End    " -value 0
		pack $gw.1 $gw.2 -side left
		set genextstart 0
		pack $g.name $g.where -side top -pady 2
		bind .genericx <Return> {set prompt999 1}
		bind .genericx <Escape> {set prompt999 0}
		wm resizable $g 1 1
	}
	set gname ""
	set finished 0
	set prompt999 0
	raise $g
	My_Grab 0 $g prompt999 $g.name.e
	while {!$finished} {
		tkwait variable prompt999
		if {$prompt999} {				  						;#	Entered a generic extension
			set gname [string tolower $gname]
			set gname [FixTxt $gname "generic name"]
			if {[string length $gname] <= 0} {
				ForceVal $g.name.e $gname
				continue
			}
			if {![regexp {^[a-zA-Z0-9_\-]+$} $gname]} {
				Inf "Invalid Characters In Name-Extension Given"
				continue
			}
			set OK 1								;#	Test that generic name is not already in use

			foreach fnam [lsort -dictionary [glob -nocomplain $evv(MACH_OUTFNAME)*]] {	;#	Find outfile extension
				if {$new_cdp_extensions} {
					set f_ext [GetFileExtension $fnam]
				} else {
					set f_ext [file extension $fnam]
				}
				break
			}
			foreach fnam $chlist {	
				set fnm [file tail $fnam]
				set froot [file rootname $fnm]
				if {$genextstart} {
					set fnam $gname
					append fnam "_" $froot
				} else {
					set fnam $froot
					append fnam "_" $gname
				}
				set fnam $fnam$f_ext
				if {[file exists $fnam] && ![file isdirectory $fnam]} {
					set OK 0
					break
				}
			}
			if {!$OK} {
				Inf "Files Already Exist With The Name '$fnam'"
			} else {
				set finished 1
			}				
		} else {											;#	On ABANDON being pressed, finish
			set finished 1
		}
	}
	My_Release_to_Dialog $g
	Dlg_Dismiss $g
	if {$prompt999 == 0} {										;#	If ABANDONed, return 0								
		return 0		
	}
	set j [string length $evv(MACH_OUTFNAME)]

	set namegroup $evv(MACH_OUTFNAME)				;#	Collects outputs from ALL bulk-processes
	append namegroup "*"
	catch {set remem_last_outfile $last_outfile}
	catch {unset last_outfile}
	set pitch_reproducing 0
	if {!$ins(create) && [PitchReproducing $pprg $mmod]} {
		set pitch_reproducing 1
	}
	foreach fnam [lsort -dictionary [glob -nocomplain $namegroup]] {	;#	Find the files
		set extname [file extension $fnam]								;#	Get its extension
		set thisrootname [file rootname [file tail $fnam]]				;#	Get its root
		set k [string last "_" $thisrootname]
		incr k -1
		set no [string range $thisrootname $j $k]
		set srcname [lindex $chlist $no]
		set newname [file rootname [file tail $srcname]]

		if {$new_cdp_extensions} {
			set extname [GetFileExtension $fnam]
		}
		if {$genextstart} {
			set zznam $gname
			append zznam "_" $newname $extname
			set newname $zznam
		} else {
			append newname "_" $gname $extname
		}
		if [catch {file rename $fnam $newname}] {
			ErrShow "Cannot rename file\nIt may be open for PLAY, READ or VIEW\nClose it, to proceed."
			if {![info exists last_outfile]} {
				catch {set last_outfile $remem_last_outfile}
			}
			return 0
		}
		if {$pitch_reproducing} {
			if [HasPmark $srcname] {
				CopyPmark $srcname $newname
			}
			if [HasMmark $srcname] {
				CopyMmark $srcname $newname
			}
		}
		set a $fnam
		append a "->"
		append a $newname
		lappend hst(bulkout) $a
		incr hst(bulkoutcnt)

		RenameProps $fnam $newname 0						;#	Rename properties
		if {[UpdateIfAMix $newname 0]} {
			set save_mixmanage 1
		}
		GenerateSrcListBulk $newname $srcname
		lappend genfiles $newname
		lappend last_outfile $newname
	}
	if {[info exists genfiles]} {
		set genfiles [ReverseList $genfiles]
		foreach newname $genfiles {
			$wl insert 0 $newname								;#	Add to start of workspace
			incr wksp_cnt
			incr total_wksp_cnt
		}
		set wkspace_newfile 1
		catch {unset rememd}
		if {[info exists save_mixmanage]} {
			MixMStore
		}
	}
	ForceVal $ww.1.a.endd.l.cnts.new $wksp_cnt
	ForceVal $ww.1.a.endd.l.cnts.all $total_wksp_cnt
	ReMarkWkspaceCount
	set prg_ocnt 0
	set has_saved 1
	set has_saved_at_all 1
	if {!$ins(run)} {
		$papag.parameters.zzz.mabo config -state normal
	}
	return 1
}
		
#------ Remember parameter vals, for next call to this process-mode or Instrument

proc RememberLastRunVals {} {

	global lastrunvals penultrangetype pprg mmod ins pmcnt lastrangetype dbl_rng pstore
	global prg_ran_before main_mix

	if {([info exists prg_ran_before] && $prg_ran_before) || [MainMix]} {	;#	i.e. If the program has run since calling Params window, or we just ran Mix on QikEdit page
		set i 0
		if {$ins(run)} {
			catch {unset lastrunvals($ins(name))}
			catch {unset penultrangetype($ins(name))}
			while {$i < $pmcnt} {
				lappend lastrunvals($ins(name)) $pstore($i)
				if {$dbl_rng($i)} {
					lappend penultrangetype($ins(name)) $lastrangetype($i)
				} else {
					lappend penultrangetype($ins(name)) 0
				}
				incr i
			}
		} else {
			if {[info exists pstore]} {
				catch {unset lastrunvals($pprg,$mmod)}
				catch {unset penultrangetype($pprg,$mmod)}
				while {$i < $pmcnt} {
					lappend lastrunvals($pprg,$mmod) $pstore($i)
					if {$dbl_rng($i)} {
						lappend penultrangetype($pprg,$mmod) $lastrangetype($i)
					} else {
						lappend penultrangetype($pprg,$mmod) 0
					}
					incr i
				}
				if {[MainMix]} {
					catch {unset main_mix(lastrunvals)}
					catch {unset main_mix(penultrangetype)}
					set i 0
					while {$i < $pmcnt} {
						lappend main_mix(lastrunvals) $pstore($i)
						if {$dbl_rng($i)} {
							lappend main_mix(penultrangetype) $lastrangetype($i)
						} else {
							lappend main_mix(penultrangetype) 0
						}
						incr i
					}
				}
			}
		}
	}
}

#------ Display a named mixfile for editing, from Score page ONLY (no NESS files!!)

proc EditSrcTextfile {filetype} {
	global pr1234 wl do_parse_report pa prm evv
	global pr3 pr2 favors current_favorites chlist src pprg
	global wstk rememd actvhi last_outfile last_mix vm_i bigmix

	catch {destroy .cpd}
	set save_mixmanage 0
	set OK 1
	if {$filetype == "sketchmix"} {
		catch {destroy .mixdisplay}
		set fnam [.scvumix2.e.1.ll.list get $vm_i]
	} elseif {![info exists chlist]} {
		return
	}
	switch $filetype {
		mmix -
		mix {
			if {[llength $chlist] != 1} {
				return
			}
			set fnam [lindex $chlist 0]
		}
		env { 
			if {[llength $chlist] != 2} {
				return
			}
			set fnam [lindex $chlist 1]
		}
		twixt { 
			set fnam $prm(0)
			if {([string length $fnam] <= 0) || ![file exists $fnam]} {
				Inf "No Valid Datafile Name Has Been Entered.\n"
				return
			}
			EditTwixtTimes $fnam
			return
		}
	}
	if {[info exists bigmix] && (($filetype == "mix") || ($filetype == "mmix"))} {
		set thisfont userfnt
		set resiz_horiz 1
		set thiswidth 240
	} else {
		set thisfont midfnt
		set resiz_horiz 0
		set thiswidth 120
	}
	set f .mixdisplay
	if [Dlg_Create $f $fnam "set pr1234 0" -borderwidth $evv(BBDR)] {
		set b  [frame $f.button -borderwidth $evv(SBDR)]
		set s  [frame $f.see -borderwidth $evv(SBDR)]
		button $b.ok -text "Close (no edit)" -width 14 -command "set pr1234 0" -highlightbackground [option get . background {}]
		button $b.ed -text "Edited Version" -width 14 -command "set pr1234 1" -highlightbackground [option get . background {}]
		button $b.ca -text "Calculator" -width 8 -command "MusicUnitConvertor 0 0"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
		button $b.re -text "Ref Vals" -width 8 -command "RefSee $s.seefile"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
		button $b.no -text "Notebook" -width 8 -command NnnSee  -highlightbackground [option get . background {}];# -bg $evv(HELP)
		button $b.sn -text "" -width 8 -command {} -highlightbackground [option get . background {}]
		pack $b.ed -side left -padx 1
		pack $b.ok $b.ca $b.re $b.sn $b.no -side right
		text $s.seefile -width 120 -height 32 -yscrollcommand "$s.sy set" -font midfnt
		scrollbar $s.sy -orient vert -command "$s.seefile yview"
		pack $s.seefile -side left -fill both -expand true
		pack $s.sy -side right -fill y -expand true
		pack $f.button $f.see -side top -fill x -expand true
		wm resizable $f 1 1
		bind $f.see.seefile <Control-Key-p> {UniversalPlay text .mixdisplay.see.seefile}
		bind $f.see.seefile <Control-Key-P> {UniversalPlay text .mixdisplay.see.seefile}
		bind $f.see.seefile <Control-Key-g> {UniversalGrab .mixdisplay.see.seefile}
		bind $f.see.seefile <Control-Key-G> {UniversalGrab .mixdisplay.see.seefile}
		bind $f <Escape> {set pr1234 0}
	}
	switch $filetype {
		mmix -
		mix {
			$f.button.sn config -text "Get Sndfile" -command "SndToCursor $f.see.seefile" -bd 2 -state normal ;# -bg $evv(HELP)
		}
		sketchmix -
		env { 
			$f.button.sn config -text "" -command {} -bg [option get . background {}] -bd 0 -state disabled
		}
	}
	wm title $f $fnam
	set finished 0
	.mixdisplay.see.seefile delete 1.0 end								;#	Clear the filelist window

	if [catch {open $fnam r} fileId] {
		Inf $fileId							;#	If textfile cannot be opened
		Dlg_Dismiss $f							;#	Hide the dialog
		return		
	}
	set qq 0
	set x_max 0
	while {[gets $fileId thisline] >= 0} {			;#	Read lines from textfile into text-listing, avoiding extra newline
		if {$qq > 0} {
			.mixdisplay.see.seefile insert end "\n"
		}
		.mixdisplay.see.seefile insert end "$thisline"
		set z_len [string length $thisline]
		if {$z_len > $x_max} {
			set x_max $z_len
		}
		incr qq
	}
	close $fileId
	if {$qq > 0} {
		Scrollbars_Reset .mixdisplay.see.seefile .mixdisplay.see.sy 0 $qq $x_max
	}
	set pr1234 0
	raise $f
	update idletasks
	StandardPosition2 $f
	if {$filetype == "sketchmix"} {
		My_Grab 0 $f pr1234 $f.see.seefile
	} else {
		My_Grab 0 $f pr1234 $f.see.seefile
	}
	while {!$finished} {
		tkwait variable pr1234						;#	Wait for OK to be pressed
		if {$pr1234} {
			set tmpfnam $evv(DFLT_TMPFNAME)
			if [catch {open $tmpfnam w} fileId] {
				Inf "Cannot Open Temporary File To Do Updating.\n"
				continue
			}
			puts -nonewline $fileId "[.mixdisplay.see.seefile get 1.0 end]"
			close $fileId
			set do_parse_report 0
			if {[DoParse $tmpfnam $wl 0 0] <= 0} {
				ErrShow "Parsing failed for edited file."
				continue
			}
			if [catch {set ftype $pa($tmpfnam,$evv(FTYP))}] {
				Inf "Cannot Find Properties Of Edited File."
				continue
			}
			if {($filetype == "mix") || ($filetype == "mmix")} {
				set duratend0 0
				set duratend1 0
				set dur $pa($tmpfnam,$evv(DUR))
				set indur $pa($fnam,$evv(DUR))
				if {[Flteq $prm(0) $indur]} {
					set duratend0 1
				}
				if {[Flteq $prm(1) $indur]} {
					set duratend1 1
				}
			}
		set ok2 1
			switch $filetype {
				mmix {
					if {$ftype != $evv(MIX_MULTI)} {
						Inf "EDITED FILE IS NO LONGER A VALID MULTICHANNEL MIXFILE."
						PurgeArray $tmpfnam
						set ok2 0
					} else {
						RefreshInsndlist
					}
				}
				sketchmix -
				mix {
					if {![IsAMixfile $ftype]} {
						Inf "Edited File Is No Longer A Valid Mixfile."
						PurgeArray $tmpfnam
						set ok2 0
					} elseif {$filetype == "mix"} {
						RefreshInsndlist
					}
				}
				env {
					if {$ftype == $evv(MIX_MULTI)} {
						Inf "Edited File Is No Longer A Valid Envelope."
						PurgeArray $tmpfnam
						set ok2 0
					}
					if {!($ftype & $evv(IS_A_TRANSPOS_BRKFILE)) \
					&&  !($ftype & $evv(IS_A_NORMD_BRKFILE)) \
					&&  !($ftype & $evv(POSITIVE_BRKFILE))} {
						Inf "Edited File Is No Longer A Valid Envelope."
						PurgeArray $tmpfnam
						set ok2 0
					}
				}
			}
			if {!$ok2} {
				continue
			}
			if [catch {file delete $fnam} zzzat] {
				Inf "Cannot Remove The Original File To Replace It With New Values"
				PurgeArray $tmpfnam
				continue
			}
			DeleteFileFromSrcLists $fnam
			if {$filetype == "sketchmix"} {
				.scvumix2.e.2.ll.list delete 0 end
			}
			if [catch {file rename $tmpfnam $fnam} in] {
				ErrShow "$in"
				Inf "Cannot Substitute The New File: Original File Lost."
				PurgeArray $tmpfnam
				PurgeArray $fnam				;#	can't remove unbakdup files!!
				RemoveFromChosenlist $fnam
				RemoveFromDirlist $fnam
				if {[string match $last_mix $fnam]} {
					set last_mix ""
				}
				if {[info exists last_outfile] && [string match $fnam $last_outfile]} {
					catch {unset last_outfile}
				}
				set i [LstIndx $fnam $wl]
				if {$i >= 0} {
					$wl delete $i
					WkspCnt $fnam -1
					catch {unset rememd}
				}
				set OK 0
				DummyHistory $fnam "LOST"
				if {[MixMDelete $fnam 0]} {
					set save_mixmanage 1
				}
				if {$filetype == "sketchmix"} {
					.scvumix2.e.1.ll.list delete $vm_i
					set vm_i -1
				}
				set finished 1
			} else {									
				DummyHistory $fnam "EDITED"
				PurgeArray $fnam				
				RenameProps $tmpfnam $fnam 0
				if {[UpdatedIfAMix $fnam 0]} {
					set save_mixmanage 1
				}
				if {$filetype == "sketchmix"} {
					if [catch {open $fnam "r"} zit] {
						Inf "Cannot Open Newly Edited File To Refresh Display Here"
						set vm_i -1
					} else {
						while {[gets $zit line] >= 0} {
							.scvumix2.e.2.ll.list insert end $line
						}
						close $zit
					}
				}
				if {($filetype == "mix") || ($filetype == "mmix")} {
					ReEstablishMixRange $dur $duratend0 $duratend1
				}
				set finished 1
			}
		} else {
			set finished 1
		}
	}
	if {[string match "mix" $filetype] && ($pprg == $evv(MIX) || $pprg == $evv(MIXMAX) || $pprg == $evv(MIXGAIN))} {
		set dur $pa($fnam,$evv(DUR))
		if {$dur != $actvhi(0)} {
			AlterParamDisplay $dur
		}
	}
	if {[string match "mmix" $filetype] && ($pprg == $evv(MIXMULTI))} {
		set dur $pa($fnam,$evv(DUR))
		if {$dur != $actvhi(0)} {
			AlterParamDisplay $dur
		}
	}
	if {$save_mixmanage} {
		MixMStore
	}
	catch {PurgeArray $tmpfnam}
	if {$filetype == "sketchmix"} {
		My_Release_to_Dialog $f
		Dlg_Dismiss $f
	} else {
		My_Release_to_Dialog $f
		Dlg_Dismiss $f
		if {!$OK} {
			catch {$favors delete 0 end}				;#	If file lost, return to workspace.
			catch {unset current_favorites}
			set pr3 0
			set pr2 0
		}
	}
	catch {close $fileId}
}

#------ Put a Sndfile-name at cursor position

proc SndToCursor {dest} {
	global pr_sndgrab wl pa evv

	set f .sndgrab
	if [Dlg_Create $f "Soundfiles on Workspace" "set pr_sndgrab 0" -borderwidth $evv(SBDR)] {
		set b [frame $f.buttons -borderwidth $evv(SBDR)]
		button $b.get  -text "To Cursor" -command {set pr_sndgrab 1} -highlightbackground [option get . background {}]
		button $b.quit -text "Close" -command {set pr_sndgrab 0} -highlightbackground [option get . background {}]
		pack $b.get -side left
		pack $b.quit -side right
		Scrolled_Listbox $f.l -selectmode single -width 64 -height 20
		pack $f.buttons $f.l -side top -fill x -expand true
		bind $f <Return> {set pr_sndgrab 1}
		bind $f <Escape> {set pr_sndgrab 0}
		bind $f.l <space> "UniversalPlay list $f.l.list"
	}
	foreach fnam [$wl get 0 end] {
		if {$pa($fnam,$evv(FTYP)) == $evv(SNDFILE)} {
			$f.l.list insert end $fnam
		}
	}
	raise $f
	set pr_sndgrab 0	
	set finished 0
	My_Grab 0 $f pr_sndgrab $f.l
	while {!$finished} {
		tkwait variable pr_sndgrab
	 	if {$pr_sndgrab} {
			set i [$f.l.list curselection]
			if {![info exists i] || ![IsNumeric $i] || ($i < 0)} {
				Inf "No Item Selected"
			} else {
				$dest insert insert [$f.l.list get $i]
				set finished 1
			}
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#------ Recycle Outfile

proc RecycleOutfile {} {
	global hst no_processes ins processes_will_work blocker pmask last_outfile chlist ch qikmixset
	global favors current_favorites pr2 pr3 ins_rethink lastpmask was_ins_run_recycle
	global bulk in_recycle chcnt sl_real wl pseudoprog last_pseudoprog pa evv wstk monomix_recycle real_chlist ww
	global onpage_oneatatime mchengineer articvw

	catch {file delete $articvw}
	if {[info exists mchengineer]} {
		set pr3 0
		set pr2 0
		return
	}
	if {!$sl_real} {
		Inf "With This Button, You Can Use The Output File\nAs The Input To A New Process.\n\nYou Will Find Yourself Back On The Process Menus Page\nWhere You Can Choose A Process To Apply To Your New File."
		return
	}
 	catch {unset onpage_oneatatime}
	set monorecyc 0
	if {![info exists last_outfile]} {
		return
	} else {
		set cnt 0
		foreach ffnam $last_outfile {
			if {![file isfile $ffnam]} {
				return
			}
			incr cnt
		}
	}
	if {$monomix_recycle && ($cnt == 1)} {
		set out_fnam  [lindex $last_outfile 0]
		if {($pa($out_fnam,$evv(FTYP)) == $evv(SNDFILE)) && ($pa($out_fnam,$evv(CHANS)) > 2)} {
			set do_monorec 1
			if {$monomix_recycle == 2} {
				set msg "Recycle As Mono ??"
				set choice [tk_messageBox -type yesno -message $msg -icon question -parent [lindex $wstk end]]
				if [string match "no" $choice] {
					set do_monorec 0
				}
			}
			if {$do_monorec} {
				set monofnam [file tail $out_fnam]
				set monofnam [file join $evv(THUMDIR) $monofnam]
				if {[file exists $monofnam]} {
					set msg "Overwrite Existing Thumbnail ??"
					set choice [tk_messageBox -type yesno -message $msg -icon question -parent [lindex $wstk end]]
					if [string match "yes" $choice] {
						if [catch {file delete $monofnam} zit] {
							Inf "Cannot Delete Existing Thumbnail"
							set monorecyc 0
						} else {
							set monorecyc [MakeThumbnail $out_fnam]
						}
					}
				} else {
					set monorecyc [MakeThumbnail $out_fnam]
				}
			}
		}
	}
	# THIS IS REPEAT OF 'GetNewFilesFromPpg', (which if called as such, may proceed too quickly)

	incr in_recycle	

	catch {$favors delete 0 end}
	catch {unset current_favorites}

	catch {unset qikmixset}
	DeleteAllTemporaryFiles

	RememberLastRunVals
	if {$ins(run)} {
		set was_ins_run_recycle 1
	} else {
		set was_ins_run_recycle 0
	}
	set pr3 0
	set pr2 0
	if {[info exists pseudoprog]} {
		set last_pseudoprog $pseudoprog
	} else {
		catch {unset last_pseudoprog}
	}
	catch {unset pseudoprog}
 	set ins_rethink 1
	set ins(run) 0

	# THIS IS REPEAT OF 'GetLastOutfile', (which if called as such, does not reset file channelcnt correctly)

	ClearWkspaceSelectedFiles

	if {[info exists real_chlist]} {				;#	If already using a thumbnail
		unset real_chlist							;#	Delete the chlist shadow
	}
	$wl selection clear 0 end
	if {$monorecyc} {								;#	If recycling thumbnail of a multichan file
		set real_chlist $out_fnam					;#	Store the true chosen multichan file
		lappend chlist $monofnam					;#	substitute the thumbnail
		$ww.1.a.mez.bkgd config -state disabled
		incr chcnt
	} else {
		foreach ffnam $last_outfile {
			lappend chlist $ffnam		;#	add to end of list
			$ch insert end $ffnam		;#	add to end of display
			$wl selection set $chcnt
			incr chcnt
		}
	}
	PurgeTempThumbnails
	SetLastMixfile $chlist

	# REMAINDER IS REPEAT OF 'GotoGetAProcess', (which if called as such, does not reset pmask correctly)

	set processes_will_work 1
	ClearInfileDependentItems				;#	Ensure no memory of previous brktable environment
	set choicechanged [CheckForChoiceChange]

	if {$choicechanged} {					;# If change in files or processing-type selected
		if {$bulk(lastrun)} {
			set pmask [GetBulkProgsMask]	;#	Validate processes for normal processing
		} else {							;#	Otherwise, keep previous pmask, but drop start (spacer) bit
			set pmask [GetProgsmask]		;#	Validate processes for normal processing
		}
	} else {								;#	Otherwise, keep previous pmask, but drop start (spacer) bit
		set pmask [string range $pmask 1 end]
	}
	if {$bulk(lastrun)} {
		set bulk(run) 1
	}

	if [string match $pmask 0] {		;#	If no individual processes are active with given infiles
		if {$hst(active)} {
			if {!$hst(ins)} {		;#	If this is a (non-ins) hst, it won't work: return	
				Inf "This Processes Will Not Work With The Input File(s) Given"
				set hst(active) 0			
				incr in_recycle	-1
				return
			}								;#	If it IS a ins hst, it may work, so continue

		} elseif {$ins(cnt) <= 0}  {	;#	If there are NO Instruments, then nothing will work
			Inf "No Processes Work With The Input File(s) Given"
			incr in_recycle	-1
			return							;#	So we return, having failed to proceed
		} else {							;#	But if there ARE Instruments, these might still work
			set processes_will_work 0		;#	So flag the Dialog not to display processes
		}
	}
	set woof 0
	set pmask [append woof $pmask]			;#	Program count starts at 1, pmask starts at 0. SORRY!!
	if {$hst(active)} {
		RunHistory							;#	If running a hst, process-menus page not needed, BUT,
		incr in_recycle	-1
		return		   						;#	If hst proves invalid, fall through to Process Menus page.
	}										;#	Only if it succeeds does it return to Workspace page.
	
	set lastpmask 0
	Dlg_Process_and_Ins_Menus
	incr in_recycle -1
}

#------ Play the input sound(s) 	NEW deals with srcs of NON-soundfiles.

proc PlayInput {} {
	global pr44 ins chlist inplay_pll pa src pprg mmod insndslist evv

	catch {unset insndslist}
	set is_mix 0
	set i 0
	if {$ins(create)} {
		if {![info exists ins(chlist)]} {
			return
		}
		foreach fnam $ins(chlist) {
			if {($pa($fnam,$evv(FTYP)) == $evv(SNDFILE)) || ($pa($fnam,$evv(FTYP)) == $evv(ANALFILE))} {
				lappend insndslist $fnam
				incr i
			}
		}
	} else {
		if {!$ins(run)} {
			switch -regexp -- $pprg \
				^$evv(MIX)$			- \
				^$evv(MIXMAX)$		- \
				^$evv(MIXGAIN)$		- \
				^$evv(MIXSHUFL)$	- \
				^$evv(MIXSYNC)$		- \
				^$evv(MIXSYNCATT)$	- \
				^$evv(MIXTWARP)$	- \
				^$evv(MIXSWARP)$	-\
				^$evv(MIXMULTI)$ {
					set zwx [lindex $chlist 0]
					if [catch {open $zwx "r"} fId] {
						Inf "Cannot Open Mixfile To Get Data On Soundfiles It Uses."
					} else {
						set badfiles {}
						set c_cnt 0
						while {[gets $fId line] >= 0} {			;#	Look inside mixfile
							if {($pprg == $evv(MIXMULTI)) && ($c_cnt == 0)} {
								incr c_cnt
								continue
							}
							set line [split $line]
							foreach item $line {
								if [string length $item] {		;#	Ignoring spaces:comments,get 1st item on line.
									if {![string match \;* $item]} {
										set item [string tolower $item]
										set item [RegulariseDirectoryRepresentation $item]
										if {[info exists pa($item,$evv(FTYP))] && ($pa($item,$evv(FTYP)) == $evv(SNDFILE))} {
											lappend tl $item	;#	If it's a sndfile on wkspace, 
										} else {
											lappend badfiles $item
										}
										break					;#	Whether a comment or not, ignore rest of line
									} else {
										break
									}
								}
							}
							incr c_cnt
						}
						close $fId
						if [info exists tl] {					;#	If not a mixfile using files on workspace, discard data.
							set	insndslist $tl					;# 	Otherwise, construct playlist
							set i [llength $insndslist]
							set is_mix 1
							if {[llength $badfiles] == 1} {
								Inf "'[lindex $badfiles 0]' Is Not On The Workspace"
							} elseif {[llength $badfiles] > 1} {
								set msg [lindex $badfiles 0]
								set zzcnt 0
								foreach item [lrange $badfiles 1 end] {
									if {$zzcnt > 60} {
										append msg "  AND MORE"
										break
									}
									append msg "  $item"
									incr zzcnt
								}
								append msg "\nAre Not On The Workspace"
								Inf $msg
							}
						} else {
							Inf "None Of These Files Is On The Workspace"
						}
					}
				}
		}
		if {!$is_mix} {
			if {![info exists chlist]} {
				return
			}
			if {$pprg == $evv(FOFEX_CO)} {
				set fnam [lindex $chlist 0]				
				if [info exists src($fnam)] {
					foreach srcfile $src($fnam) {
						if [string match $evv(DELMARK)* $srcfile] {
							lappend deleted_files [string range $srcfile 1 end]
						} else {
							lappend insndslist $srcfile
							incr i
						}
					}
				}
			} else {
				foreach fnam $chlist {
					if {($pa($fnam,$evv(FTYP)) == $evv(SNDFILE)) || ($pa($fnam,$evv(FTYP)) == $evv(ANALFILE))} {
						lappend insndslist $fnam
						incr i
					} elseif [info exists src($fnam)] {
						foreach srcfile $src($fnam) {
							if [string match $evv(DELMARK)* $srcfile] {
								lappend deleted_files [string range $srcfile 1 end]
							} else {
								lappend insndslist $srcfile
								incr i
							}
						}
					}
				}
			}
		}
	}
	if [info exists deleted_files] {
		if {[string length $deleted_files] == 1} {
			Inf "The Original Sourcefile\n$deleted_files\nNo Longer Exists"
		} else {
			Inf "The Original Sourcefiles\n$deleted_files\nNo Longer Exist"
		}
	}
	switch -- $i {
		0 { return }
		1 {
			set fnam [lindex $insndslist 0]
			if {![info exists pa($fnam,$evv(FTYP))]} {
				Inf "Cannot Find File Type"
				return
			}
			if {$pa($fnam,$evv(FTYP)) == $evv(ANALFILE)} {
				PlaySndfile $fnam 1
			} else {
				PlaySndfile $fnam 0
			}
			return
		}
		default {
			set insndslist [CollapsePlaylist $insndslist]
			set f .inplaylist
			if [Dlg_Create $f "Input Playlist" "set pr44 1" -borderwidth $evv(BBDR)] {
				set b 	   [frame $f.button -borderwidth $evv(SBDR)]
				set player [frame $f.play -borderwidth $evv(SBDR)]
				set inplay_pll [Scrolled_Listbox $player.playlist -width 48 -height 32 -selectmode single]
				button $b.play -text "Play" -command "PlaySelectedInSndfile $inplay_pll" -highlightbackground [option get . background {}]
				button $b.sort -text "Sort" -command "ListSort $inplay_pll" -highlightbackground [option get . background {}]
				button $b.quit -text "Close" -command "set pr44 1" -highlightbackground [option get . background {}]
				pack $b.play $b.sort -side left -padx 1
				pack $b.quit -side right
				pack $player.playlist -side top -fill both
				pack $f.button $f.play -side top -fill x
				bind $inplay_pll <Double-1> {UniversalPlay list $inplay_pll}
				bind .inplaylist <Control-Key-p> {UniversalPlay list $inplay_pll}
				bind .inplaylist <Control-Key-P> {UniversalPlay list $inplay_pll}
				bind .inplaylist <Key-space> {UniversalPlay list $inplay_pll}
				bind $f <Escape> {set pr44 1}
			}
			wm resizable $f 1 1

			bind .inplaylist <ButtonRelease-1> {HideWindow %W %x %y pr44}

			$inplay_pll delete 0 end
			foreach fnam $insndslist {
				$inplay_pll insert end $fnam
			}
			set pr44 0
			raise $f
			My_Grab 0 $f pr44 $f.play.playlist
			tkwait variable pr44
			My_Release_to_Dialog $f
			Dlg_Dismiss $f
		}
	}
}

#------ Remove any duplicates from playlist

proc CollapsePlaylist {inlist} {

	set i 0
	set len [llength $inlist]
	while {$i < [expr $len - 1]} {							;#	Until end of (currently modified) list reached
		set startlist [lrange $inlist 0 $i]					;#	Retain first i+1 items of list
		set compfile [lindex $inlist $i]					;#	Note last-item of this sublist
		incr i
		set rest_of_list [lrange $inlist $i end]			;#	Define remainder of list as Rest-of-list
		catch {unset newrest_of_list}
		foreach fnm $rest_of_list {
			if {![string match $fnm $compfile]} {			;#	If item in rest-of-list != last-item of sublist
				lappend newrest_of_list $fnm				;#	keep it, as its not a duplicate
			}
		}
		if [info exists newrest_of_list] {					;#	concatenate sublist with new rest-of-list
			set inlist [concat $startlist $newrest_of_list]	;#	Duplicates have failed to be recorded in newrest_of_list
		} else {									  		
			set inlist $startlist															
		}
		set len [llength $inlist]							;#	recalcualte total length of list
	}
	return $inlist
}

#------ Play sndfile selected from playlist

proc PlaySelectedInSndfile {pll} {
	global pa evv

	set i [$pll curselection]
	if {[string length $i] <= 0} {
		Inf "No Item Selected"
		return
	}
	set fnam [$pll get $i]
	if {![info exists pa($fnam,$evv(FTYP))]} {
		Inf "Cannot Find Type Of File"
		return
	}
	if {$pa($fnam,$evv(FTYP)) == $evv(ANALFILE)} {
		PlaySndfile $fnam 1
	} else {
		PlaySndfile $fnam 0
	}
}

#------ Play, View or Read a single file, if there is only 1 file to play, view or read

proc DoSingleFile {action} {
	global from_runpage pa o_nam bulk pprg evv
	global ins_file_lst ins viewcnt CDPidview origmixbak

	if {$from_runpage} {
		if {$ins(run) || $bulk(run)} {
			set namegroup $evv(MACH_OUTFNAME)  ;#	Collects outputs from ALL ins-processes
		} else {
			set namegroup $o_nam				 ;#	Collects normal outs, or current Instrumentcreateprocess outs
		}
		foreach fnam [lsort -dictionary [glob -nocomplain $namegroup*]] {
			lappend file_list $fnam
		}
		if {[info exists origmixbak]} {
			if {![info exists file_list]} {
				Inf "No File To Play" 
				return 1
			}
			set kq [lsearch $file_list $origmixbak]
			if {$kq >= 0} {
				set file_list [lreplace $file_list $kq $kq]
			}
		}
	} else {												;#	From ins(creation)_concluding
		set file_list [$ins_file_lst get 0 end]
	}
	set found 0
	if {![info exists file_list]} {
		return 1
	}		
	foreach fnam $file_list {
		set filetype $pa($fnam,$evv(FTYP))
		switch $action {
			"play" { if {($filetype == $evv(SNDFILE)) || ($filetype == $evv(ANALFILE))} { set found 1 } }
			"view" { if {($filetype == $evv(SNDFILE)) || ($filetype == $evv(ANALFILE)) || ($filetype == $evv(PSEUDO_SND))}	{ set found 1 } }
			"read" { if {$filetype & $evv(IS_A_TEXTFILE)}	 							{ set found 1 } }
		}
		if {$found} {
			break
		}
	}
	if {!$found} {		;#	This is an error in system logic, but ignore
		return 0
	}
	switch $action {
		"play"	{
			if {$filetype == $evv(ANALFILE)} {
				PlaySndfile $fnam 1
			} else {
				PlaySndfile $fnam 0
			}
		}
		"view" {
			if {[Snackable $fnam]} {
				if {$pprg == $evv(MIX)} {
					if {$pa($fnam,$evv(DUR)) * $pa($fnam,$evv(CHANS)) > 300} {
						Block "Creating waveform display"
					}
					if {[winfo exists .blocker]} {
						UnBlock
					}
					SnackDisplay $evv(SN_TIMEDIFF) mixmix 0 $fnam
				} else {
					if {$pa($fnam,$evv(DUR)) * $pa($fnam,$evv(CHANS)) > 300} {
						Block "Creating waveform display"
					}
					SnackDisplay 0 $evv(SN_FILE_PRMPAGE_NO_OUTPUT) 0 $fnam
					if {[winfo exists .blocker]} {
						UnBlock
					}
				}
			} else {
				if {$pa($fnam,$evv(CHANS)) > 2} {
					if {$pa($fnam,$evv(FTYP)) == $evv(SNDFILE)} {
						Inf "Cannot Display Multichannel Files, in this Display Mode (See System State Menu)"
						return 1
					}
				}
				set cmd [file join $evv(CDPROGRAM_DIR) viewsf]
				if [ProgMissing $cmd "Cannot view the file."] {
					return 1
				}
				set fnam [OmitSpaces $fnam]
				set cmd [concat $cmd $fnam]
				if [catch {open "|$cmd"} CDPidview($viewcnt)] {
					ErrShow "$CDPidview"
					catch {unset CDPidview($viewcnt)}
					return 1
				}
				incr viewcnt
			}
		}
		"read" {
			if [ProcessGivesBrkfile] {
				if {![DisplayBrkfile $fnam 0]} {
					DisplayTextfile $fnam
				}
			} else {
				DisplayTextfile $fnam
			}
		}
	}
	return 1
}

#--- Change mixfile display when mix is edited

proc AlterParamDisplay {dur} {
	global hi actvhi actvlo prmgrd prange evv

 	set hi(0) $dur
 	set actvhi(0) $dur
	set prange(0) [expr $actvhi(0) - $actvlo(0)]
	SetPrtype 0
	set hitxt [FiveSigFig $actvhi(0)]
	if {[info exists $prmgrd.rhi0]} {
		$prmgrd.rhi0 config -text $hitxt
	}
	SetScale 0 lin
 	set hi(1) $dur
 	set actvhi(1) $dur
	set prange(1) [expr $actvhi(1) - $actvlo(1)]
	SetPrtype 1
	set hitxt [FiveSigFig $actvhi(1)]
	if {[info exists $prmgrd.rhi1]} {
		$prmgrd.rhi1 config -text $hitxt
	}
	SetScale 1 lin
}

#--- Put extra buttons in gadget to do samplesize <-> level conversion

proc InsertSampValConverters {jjj this_prog this_mode} {
	global evv

	set name [lindex $jjj 1]
	switch -regexp -- $this_prog \
		^$evv(ENV_WARPING)$		- \
		^$evv(ENV_REPLOTTING)$	- \
		^$evv(ENV_RESHAPING)$ {
			switch -regexp -- $this_mode \
				^$evv(ENV_EXPANDING)$ - \
				^$evv(ENV_LIMITING)$  - \
				^$evv(ENV_DUCKED)$ {
					if {[string match $name "GATE_LEVEL"] || [string match $name "THRESHOLD_LEVEL"]}  { return 1 }
				} \
				^$evv(ENV_GATING)$ {
					if [string match $name "GATE_LEVEL"] 											  { return 1 }
				} \
				^$evv(ENV_INVERTING)$ {
					if {[string match $name "GATE_LEVEL"] || [string match $name "MIRROR_LEVEL"]} 	  { return 1 }
				} \
				^$evv(ENV_TRIGGERING)$ {
					if {[string match $name "GATE_LEVEL"] || [string match $name "MIN_TRIGGER_LEVEL-RISE"]} { return 1 }
				} \
				^$evv(ENV_LIFTING)$ {
					if [string match $name "LIFT"] 			{ return 1 }
				}
		} \
		^$evv(ENV_ATTACK) {
			if {$this_mode == $evv(ENV_ATK_GATED)} {
					if [string match $name "GATE_LEVEL"]	{ return 1 }
				}
		} \
		^$evv(GRAIN_COUNT)$ 	- \
		^$evv(GRAIN_OMIT)$ 		- \
		^$evv(GRAIN_DUPLICATE)$ - \
		^$evv(GRAIN_REORDER)$	- \
		^$evv(GRAIN_REPITCH)$	- \
		^$evv(GRAIN_RERHYTHM)$	- \
		^$evv(GRAIN_REMOTIF)$ 	- \
		^$evv(GRAIN_TIMEWARP)$	- \
		^$evv(GRAIN_POSITION)$	- \
		^$evv(GRAIN_GET)$		- \
		^$evv(GRAIN_REVERSE)$ 	{
			if [string match $name "GATE_LEVEL"] 			{ return 1 }
		} \
		^$evv(GRAIN_ALIGN)$ {
			if {[string match $name "GATE_LEVEL"] || [string match $name "GATE_LEVEL_FOR_2nd_FILE"]} 	{ return 1 }
		} \
		^$evv(HOUSE_EXTRACT)$ {
			switch -regexp -- $this_mode \
				^$evv(HOUSE_TOPNTAIL)$ {
					if [string match $name "GATE_LEVEL"] 			{ return 1 }
				} \
		 		^$evv(HOUSE_CUTGATE)$ - \
		 		^$evv(HOUSE_ONSETS)$ {
					if {[string match $name "GATE_LEVEL"] || [string match $name "ENDGATE_LEVEL"] \
					|| [string match $name "THRESHOLD"]   || [string match $name "INITIAL_LEVEL"]}			{ return 1 }
				} \
				^$evv(HOUSE_RECTIFY)$ {
					if [string match $name "SHIFT"] 				{ return 1 }
				}
		} \
		^$evv(TOPNTAIL_CLICKS)$ {
			if [string match $name "GATE_LEVEL"] 			{ return 1 }
		} \
		^$evv(INFO_FINDHOLE)$ {
			if [string match $name "THRESHOLD_LEVEL"] 		{ return 1 }
		} \
		^$evv(INFO_DIFF)$  - \
		^$evv(INFO_CDIFF)$ {
			if [string match $name "MAX_ACCEPTABLE_WANDER"] { return 1 }
		} \
		^$evv(MOD_LOUDNESS)$ {
			if [string match $name "LEVEL"] 				{ return 1 }
		} \
		^$evv(DISTORT_OVERLOAD)$ {
			if [string match $name "GATE_LEVEL_WHERE_SIGNAL_IS_CLIPPED"] 				{ return 1 }
		}

	return 0
}

#--- Edit times in a twixt (source segmentation times) file, by nudging up or down

proc EditTwixtTimes {fnam} {
	global prtwixt twixtlist twixtall twixtms twixtlen twixtdur
	global twixtminstep twixtinsert twixtoutfnam twixtsamp twixtsrate
	global chlist pa prm mmod wstk prm evv

	catch {destroy .cpd}

	set twixtlen 0
	set f .twixttimes
	if [Dlg_Create $f "NUDGER" "set prtwixt 0" -borderwidth $evv(BBDR)] {
		set b  [frame $f.button -borderwidth $evv(SBDR)]
		set b2 [frame $f.butto2 -borderwidth $evv(SBDR)]
		set b3 [frame $f.butto3 -borderwidth $evv(SBDR)]
		set b4 [frame $f.butto4 -borderwidth $evv(SBDR)]
		set b5 [frame $f.butto5 -borderwidth $evv(SBDR)]
		set s  [frame $f.see -borderwidth $evv(SBDR)]
		button $b.ok -text "Close (no edit)" -width 14 -command "set prtwixt 0" -highlightbackground [option get . background {}]
		button $b.ed -text "Keep Edited Version" -width 17 -command "set prtwixt 1" -highlightbackground [option get . background {}]
		label $b.sn -text "Outfile" -width 8
		entry $b.e -textvariable twixtoutfnam -width 16
		button $b.ca -text "Calculator" -width 8 -command "MusicUnitConvertor 0 0"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
		button $b.re -text "Insert Ref Val" -width 12 -command "RefSee 2"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
		button $b.no -text "Notebook" -width 8 -command NnnSee  -highlightbackground [option get . background {}];# -bg $evv(HELP)
		pack $b.ed $b.sn $b.e -side left -padx 1
		pack $b.ok $b.ca $b.re $b.no -side right -padx 1

		label $b2.l1 -text "NUDGE" 
		button $b2.up -text "up" -command {NudgeTwixt 1 $twixtall $twixtms $twixtlist $twixtdur $twixtminstep} -highlightbackground [option get . background {}]
		button $b2.dn -text "dn" -command {NudgeTwixt -1 $twixtall $twixtms $twixtlist $twixtdur $twixtminstep} -highlightbackground [option get . background {}]
		radiobutton $b2.ch1 -variable twixtall -text "CHOSEN VAL" -value 0
		radiobutton $b2.ch2 -variable twixtall -text "ALL VALS" -value 1
		label $b2.l2 -text "BY"
		radiobutton $b2.ms0	   -variable twixtms -text ".1"  -value ".1"
		radiobutton $b2.ms1    -variable twixtms -text "1"   -value 1
		radiobutton $b2.ms10   -variable twixtms -text "10"  -value 10
		radiobutton $b2.ms100  -variable twixtms -text "100" -value 100
		radiobutton $b2.ms1000 -variable twixtms -text "1000" -value 1000
		label $b2.l3 -text "milliSECS"
		pack $b2.l1 $b2.up $b2.dn $b2.ch1 $b2.ch2 -side left -padx 1
		pack $b2.l3 $b2.ms1000 $b2.ms100 $b2.ms10 $b2.ms1 $b2.ms0 $b2.l2 -side right -padx 1

		label $f.tit0 -text "CHANGE ENTRIES" -fg $evv(SPECIAL)
		label $f.tit1 -text "DELETE ENTRIES AND INSERT NEW ENTRIES" -fg $evv(SPECIAL)
		label $f.tit2 -text "CHANGE TO, OR INSERT, SPECIFIC VALUES" -fg $evv(SPECIAL)
		label $f.tit3 -text "MOVE UP AND DOWN LIST OF ENTRIES" -fg $evv(SPECIAL)

		button $b3.del -text "Delete One Time Val" -width 16 -command "DelTwixt" -highlightbackground [option get . background {}]
		button $b3.res -text "Restore Deleted Val" -width 16 -command "RestoreDelTwixt" -highlightbackground [option get . background {}]
		button $b3.ins -text "Insert Time Values"  -width 16 -command "InsertTwixt" -highlightbackground [option get . background {}]
		entry  $b3.e -textvariable twixtinsert -width 16
		label  $b3.lab -text "  VALUES"
		pack $b3.del $b3.res $b3.ins -side left -padx 1
		pack $b3.lab $b3.e -side right -padx 1

		button $b4.repsamp -text "Replace by time at" -width 16 -command "RepSamp 0" -highlightbackground [option get . background {}]
		button $b4.addsamp -text "Add time of" -width 16 -command "RepSamp 1" -highlightbackground [option get . background {}]
		button $b4.subsamp -text "Subtract time of" -width 16 -command "RepSamp -1" -highlightbackground [option get . background {}]
		button $b4.inssamp -text "Insert time at" -width 16 -command "InsSamp" -highlightbackground [option get . background {}]
		entry  $b4.e -textvariable twixtsamp -width 16
		label  $b4.lab -text "SAMPLES"
		pack $b4.repsamp $b4.addsamp $b4.subsamp $b4.inssamp -side left -padx 1
		pack $b4.lab $b4.e -side right -padx 1

		button $b5.next -text "Go To Next Value" -command {HiliteNext $twixtlist $twixtlen 0} -width 16  -highlightbackground [option get . background {}]
		button $b5.last -text "To Previous Value" -command {HilitePrevious $twixtlist} -width 16  -highlightbackground [option get . background {}]
		pack $b5.next $b5.last -side left -padx 1

		set twixtlist [Scrolled_Listbox $s.tl -width 20 -height 24 -selectmode single]
		pack $s.tl -side left -fill both -expand true

		pack $f.button $f.tit0 $f.butto2 $f.tit1 $f.butto3 $f.tit2 $f.butto4 -side top -fill x -expand true
		pack $f.tit3 $f.butto5 -side top -expand true
		pack $f.see -side top -fill x -expand true
		wm resizable $f 1 1
		bind $twixtlist <Down> {HiliteNext $twixtlist $twixtlen 0}
		bind $twixtlist <Up> {HilitePrevious $twixtlist}
		bind $twixtlist <Control-Up> {$twixtlist selection clear 0 end ; $twixtlist selection set 0}
		bind $twixtlist <Control-Down> {$twixtlist selection clear 0 end ; $twixtlist selection set end}
		bind $twixtlist <Delete> {}
		bind $twixtlist <Delete> {DelTwixt}
		bind $f <Escape> {set prtwixt 0}
		bind $f <Return> {set prtwixt 1}
	}
	set twixtall 0
	set twixtms "1"
	set twixtinsert "1"
	set twixtsample ""
	if [catch {open $fnam "r"} zib] {
		Inf "Cannot Read Data From File '$fnam'"
		destroy $f
		return
	}
	$twixtlist delete 0 end
	while {[gets $zib line] >= 0} {
		set str [string trim $line]
#FEB 2022
		if {[string length $str] <= 0} {
			continue
		} elseif {[string match [string index $str 0] ";"]} {
			continue
		}
		if {![IsNumeric $str]} {
			Inf "Invalid Data ($str) In File '$fnam'"
			close $zib
			destroy $f
			return
		}
		$twixtlist insert end "$twixtlen   $str"
		incr twixtlen
	}
	close $zib
	set filnam [lindex $chlist 0]
	set twixtdur $pa($filnam,$evv(DUR))
	set twixtsrate $pa($filnam,$evv(SRATE))
	foreach filnam $chlist {
		if {$pa($filnam,$evv(DUR)) < $twixtdur} {
			set twixtdur $pa($filnam,$evv(DUR))
		}
	}
	set badtime 0
	set badsepa 0
	set yy 0

	if {![IsNumeric $prm(1)]} {
		Inf "Cannot Edit File Until Splicelength Is Set"
		destroy $f
		return
	}
	set twixtoutfnam [file rootname $fnam]
	set twixtminstep [expr $prm(1) * .001]
	foreach item [$twixtlist get 0 end] {
		set item [split $item]
		set item [lindex $item 3]
		if {$yy} {
			if {[expr $item - $lastitem] <= $twixtminstep} {
				set badsepa 1
				break
			}
		}
		if {$item > $twixtdur} {
			set badtime 1
			break
		}
		set lastitem $item
		incr yy
	}
	if {$badtime} {
		Inf "Times In Datafile Extend Beyond End Of Shortest Input Soundfile ($twixtdur)\n\nCannot Use This Datafile"
		destroy $f
		return
	}
	if {$badsepa} {
		Inf "Some Of Times In Datafile Are Closer Than Duration Needed For Splice ($twixtminstep)\n\nCannot Use This Datafile\n(Use 'Get File' To Radically Edit)"
		destroy $f
		return
	}
	set prtwixt 0
	set finished 0
	raise $f
	My_Grab 0 $f prtwixt $twixtlist
	while {!$finished} {
		tkwait variable prtwixt
		if {!$prtwixt} {
		   break
		}
		if {![ValidCDPRootname $twixtoutfnam]} {
			continue
		}
		if {$prtwixt} {
			set tmpfnam $evv(DFLT_TMPFNAME)
			if [catch {open $tmpfnam w} fileId] {
				Inf "Cannot Open Temporary File To Do Updating.\n"
				break		
			}
			foreach val [$twixtlist get 0 end] {
				set val [split $val]
				set val [lindex $val 3]
				puts $fileId $val
			}
			close $fileId
			if [string match [file rootname $fnam] $twixtoutfnam] {
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] \
					-message "Overwrite the input file?"]
				if [string match no $choice] {
					continue
				}
				if [catch {file delete $fnam} zub] {
					Inf "Cannot Remove Original Data.\n"
					break
				} else {
					DummyHistory $fnam "EDITED"
				}
			}
			set grogro $twixtoutfnam$evv(TEXT_EXT)
			if {[file exists $grogro]} {
				if [catch {file rename -force $tmpfnam $grogro} zub] {
					Inf "Cannot Rename Newdata File.\nData Is In File '$evv(DFLT_TMPFNAME)'\nRename The File Outside The Sound Loom Before Proceeding.\n"
					break
				}
			} else {
				if [catch {file rename $tmpfnam $grogro} zub] {
					Inf "Cannot Rename Newdata File.\nData Is In File '$evv(DFLT_TMPFNAME)'\nRename The File Outside The Sound Loom Before Proceeding.\n"
					break
				}
			}
			set prm(0) $grogro
			break
		}
	}
	catch {destroy .cpd}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Nudge times in a twixt (source segmentation times) file, up or down

proc NudgeTwixt {direction all ms list duration mindist} {

	set nudge [expr $ms * $direction * .001]
	if {$all} {
		set kk [$list curselection]
		set loval [$list get 0]
		set loval [split $loval]
		set loval [lindex $loval 3]
		set lopos [lindex $loval 0]

		set hival [$list get end]
		set hival [split $hival]
		set hival [lindex $hival 3]

		if {$nudge < 0} {
			if {$loval <= 0.0} {
				lappend newlist $loval
				lappend newpos  $lopos
				foreach val [$list get 1 end] {
					set val [split $val]
					set pos [lindex $val 0]
					set val [lindex $val 3]
					set val [expr $val + $nudge]
					lappend newlist $val
					lappend newpos  $pos
				}
				if {[llength $newlist] > 1} {
					if {[lindex $newlist 1] <= [expr [lindex $newlist 0] + $mindist]} {
						Inf "Values Would Be Too Close At Start Of List"
						return
					}
				}
			} else {
				set loval [expr $loval + $nudge]
				if {$loval < 0} {
					Inf "Value At Start Of List Would Be Less Than Zero"
					return
				}
				foreach val [$list get 0 end] {
					set val [split $val]
					set pos [lindex $val 0]
					set val [lindex $val 3]

					set val [expr $val + $nudge]
					lappend newlist $val
					lappend newpos  $pos
				}
			}
		} else {
			if {$hival >= $duration} {
				foreach val [$list get 0 end] {
					set val [split $val]
					set pos [lindex $val 0]
					set val [lindex $val 3]

					set val [expr $val + $nudge]
					lappend newlist $val
					lappend newpos  $pos
				}
				set jj [llength $newlist]
				incr jj -1
				set newlist [lreplace $newlist $jj $jj $duration]
				if {$jj > 0} {
					if {[lindex $newlist $jj] <= [expr [lindex $newlist [expr $jj - 1]] + $mindist]} {
						Inf "Values Would Be Too Close At End Of List"
						return
					}
				}
			} else {
				set hival [expr $hival + $nudge]
				if {$hival > $duration} {
					Inf "Value At End Of List Would Be Beyond End Of Shortest Input Soundfile ($duration)"
					return
				}
				foreach val [$list get 0 end] {
					set val [split $val]
					set pos [lindex $val 0]
					set val [lindex $val 3]

					set val [expr $val + $nudge]
					lappend newlist $val
					lappend newpos  $pos
				}
			}
		}
		$list delete 0 end
		foreach pos $newpos val $newlist {
			$list insert end "$pos   $val"
		}
		if {$kk >= 0} {
			$list selection set $kk
		}
	} else {
		set i [$list curselection]
		if {[string length $i] <= 0} {
			Inf "No Item Selected"
			return
		}
		set origval [$list get $i]
		set origval [split $origval]
		set origpos [lindex $origval 0]
		set origval [lindex $origval 3]

		set newval [expr $origval + $nudge]
		if {$newval < 0} {
			Inf "Cannot Generate Values Below Zero"
			return
		} elseif {$newval > $duration} {
			Inf "Cannot Generate Values Very Close To Or Beyond End Of Shortest Input Soundfile ($duration)"
			return
		} elseif {$i > 0} {
			set j [expr $i - 1]
			set val2 [$list get $j]
			set val2 [split $val2 ]
			set val2 [lindex $val2 3]

			if {$newval <= [expr $val2 + $mindist]} {
				Inf "Values Would Be Too Close Together"
				return
			}
		}
		set val2 [$list get end]
			set val2 [split $val2 ]
			set val2 [lindex $val2 3]

		if {![string match $val2 $origval]} {
			set j [expr $i + 1]
			set val2 [$list get $j]
			set val2 [split $val2 ]
			set val2 [lindex $val2 3]

			if {$newval >= [expr $val2 - $mindist]} {
				Inf "Values Would Be Too Close Together"
				return
			}
		}
		$list delete $i
		$list insert $i "$origpos   $newval"
		$list selection set $i
	}
}

#------ Insert a number of entires  after cursor position intwixtlist

proc InsertTwixt {} {
	global twixtlist twixtinsert twixtminstep twixtlen

	set n 0
	set i [$twixtlist curselection]
	if {[string length $i] <= 0} {
		Inf "No Item Selected"
		return
	}
	set val1 [$twixtlist get $i]
	set val1 [split $val1 ]
	set val1 [lindex $val1 3]

	if {$i == [expr $twixtlen - 1]} {
 		set diff $twixtminstep
		while {$n < $twixtinsert} {
			set val1 [expr $val1 + $diff]
			$twixtlist insert end "X   $val1"
			incr twixtlen
			incr n
		}
	} else {
		incr i
		set val2 [$twixtlist get $i]
		set val2 [split $val2 ]
		set val2 [lindex $val2 3]

		set diff [expr $val2 - $val1]
		set diff [expr $diff/($twixtinsert+1)]
		if {$diff <= $twixtminstep} {
			Inf "Values Would Be Too Close Together"
			return
		}
		while {$n < $twixtinsert} {
			set val1 [expr $val1 + $diff]
			$twixtlist insert $i "X   $val1"
			incr twixtlen
			incr i
			incr n
		}
	}
	set twixtinsert "1"
	catch {unset twixtdel}
}

#------ Delete an entry from the twixt list

proc DelTwixt {} {
	global twixtlist twixtlen twixtdel twixtdelpos

	set i [$twixtlist curselection]
	if {[string length $i] <= 0} {
		Inf "No Item Selected"
		return
	}
	if {$twixtlen <= 1} {
		Inf "Cannot Delete The Entire File"
		return
	}
	set twixtdelpos $i
	set twixtdel [$twixtlist get $i]

	set kk $i
	$twixtlist delete $i
	incr twixtlen -1

	if {$kk == $twixtlen} {
		incr kk -1
	}
	$twixtlist selection set $kk
}

#------ Restore value deleted from the twixt list

proc RestoreDelTwixt {} {
	global twixtlist twixtlen twixtdel twixtdelpos

	if {![info exists twixtdel]} {
		Inf "No Item Just Deleted"
		return
	}
	if {$twixtdelpos >= $twixtlen} {
		$twixtlist insert end $twixtdel
		$twixtlist selection clear  0 end
		$twixtlist selection set $twixtlen
	} else {
		$twixtlist insert $twixtdelpos $twixtdel
		$twixtlist selection clear 0 end
		$twixtlist selection set $twixtdelpos
	}
	incr twixtlen
	unset twixtdel
}

#------ Replace existing time value by time corresponding to sample position

proc RepSamp {isadd} {
	global twixtlist twixtsamp twixtsrate twixtlen twixtminstep twixtdur

	set i [$twixtlist curselection]
	if {[string length $i] <= 0} {
		Inf "No Position Indicated In Timelist"
		return
	}
	if {([string length $twixtsamp] < 0) || ![regexp {^[0-9]+$} $twixtsamp]} {
		Inf "Invalid Sample Number"
		return
	}
	set newval [expr (double($twixtsamp))/(double($twixtsrate))]

	set val [$twixtlist get $i]
	set val [split $val]
	set pos [lindex $val 0]
	set val [lindex $val 3]
	if {![string match "0" $isadd]} {
		set newval [expr $newval * $isadd]
		set newval [expr $val + $newval]
		if {$newval < 0.0} {
			Inf "Cannot Generate Time Values Below Zero"
			return
		}
	}
	if {$i > 0} {
		incr i -1
		set valpre [$twixtlist get $i]
		set valpre [split $valpre]
		set valpre [lindex $valpre 3]
		incr i
	}
	if {$i < [expr $twixtlen - 1]} {
		incr i
		set valpost [$twixtlist get $i]
		set valpost [split $valpost]
		set valpost [lindex $valpost 3]
		incr i -1
	}
	if [info exists valpre] {
		set gapp [expr $newval - $valpre]
		if {$gapp < 0.0} {
			Inf "Values Would Be Out Of Sequence"
			return
		} elseif {$gapp <= $twixtminstep} {
			Inf "Values Would Be Too Close Together"
			return
		}
	}
	if [info exists valpost] {
		set gapp [expr $valpost  - $newval]
		if {$gapp < 0.0} {
			Inf "Values Would Be Out Of Sequence"
			return
		} elseif {$gapp <= $twixtminstep} {
			Inf "Values Would Be Too Close Together"
			return
		} else {
			$twixtlist delete $i
			$twixtlist insert $i "$pos   $newval"
			return
		}
	} else {
		if {[expr $twixtdur - $newval] <= $twixtminstep} {
			Inf "Cannot Generate Values Very Close To Or Beyond End Of Shortest Input Soundfile ($twixtdur)"
			return
		} else {
			$twixtlist delete $i
			$twixtlist insert end "$pos   $newval"
			return
		}
	}
}

#------ Insert time corresponding to sample position

proc InsSamp {} {
	global twixtlist twixtsamp twixtsrate twixtlen twixtminstep twixtdur

	if {([string length $twixtsamp] < 0) || ![regexp {^[0-9]+$} $twixtsamp]} {
		Inf "Invalid Sample Number"
		return
	}
	set newval [expr (double($twixtsamp))/(double($twixtsrate))]

	set done 0
	set n 0
	foreach val [$twixtlist get 0 end] {
		set val [split $val]
		set val [lindex $val 3]

		if {$newval < $val} {
			if {$val - $newval <= $twixtminstep} {
				Inf "Values Would Be Too Close Together"
				return
			} elseif {$n > 0} {
				incr n -1
				set valpre [$twixtlist get $n]
				set valpre [split $valpre]
				set valpre [lindex $valpre 3]
				if {$newval - $valpre <= $twixtminstep} {
					Inf "Values Would Be Too Close Together"
					return
				}
				incr n 1
			}
			$twixtlist insert $n "X   $newval"
			incr twixtlen
			return
		}
		incr n
	}
	if {$newval - $val <= $twixtminstep} {
		Inf "Values Would Be Too Close Together"
		return
	} elseif {[expr $twixtdur - $newval] <= $twixtminstep} {
		Inf "Cannot Generate Values Very Close To Or Beyond End Of Shortest Input Soundfile ($twixtdur)"
		return
	}
	$twixtlist insert end "X   $newval"
	incr twixtlen
}

#---- Get New CDP File Extensions

proc GetFileExtension {fnam} {
	global pa evv
;# 2023/2
	set ftyp $pa($fnam,$evv(FTYP))
	switch -regexp -- $ftyp \
		^$evv(SNDFILE)$		 {return $evv(SNDFILE_EXT)}  \
		^$evv(PSEUDO_SND)$	 {return $evv(SNDFILE_EXT)}  \
		^$evv(ANALFILE)$ 	 {return $evv(ANALFILE_OUT_EXT)}	\
		^$evv(PITCHFILE)$ 	 {return $evv(PITCHFILE_EXT)} \
		^$evv(TRANSPOSFILE)$ {return $evv(TRANSPOSFILE_EXT)} \
		^$evv(FORMANTFILE)$  {return $evv(FORMANTFILE_EXT)} \
		^$evv(ENVFILE)$ 	 {return $evv(ENVFILE_EXT)} \
		default 			 {return [AssignTextfileExtension $ftyp]}
}

#-------

proc SimpleDisplayTextfile {fnam} {
	global pr11_x text_sfs prg_ocnt wl from_runpage do_parse_report evv
	global ins_concluding src rememd ch brk

	catch {destroy .cpd}

	set f .stextdisplay
	if [Dlg_Create $f $fnam "set pr11_x 1" -borderwidth $evv(BBDR)] {
		set f1 [frame $f.1 -borderwidth $evv(SBDR)]
		button $f1.ok -text "Close" -width 14 -command "set pr11_x 0"
		label $f1.info -text "For Single Selected SOUND  ****  Control-P = Play                    For Single Selected FILE  ****  Control-G = Grab to Wkspace          " -fg $evv(SPECIAL)
		pack $f1.ok -side left
		pack $f1.info -side right 
		pack $f1 -side top -pady 2 -fill x -expand true
		set s  [frame $f.see -borderwidth $evv(SBDR)]
		set text_sfs [text $s.seefile -width 128 -height 20 -yscrollcommand "$s.sy set"]
		scrollbar $s.sy -orient vert -command "$s.seefile yview"
		pack $s.seefile -side left -fill both -expand true
		pack $s.sy -side right -fill y -expand true
		pack $f.see -side top -pady 2
		wm resizable $f 1 1
		bind $text_sfs <Control-Key-p> {UniversalPlay text $text_sfs}
		bind $text_sfs <Control-Key-P> {UniversalPlay text $text_sfs}
		bind $text_sfs <Control-Key-g> {UniversalGrab $text_sfs}
		bind $text_sfs <Control-Key-G> {UniversalGrab $text_sfs}
		bind $f <Return> {set pr11_x 1}
		bind $f <Escape> {set pr11_x 1}
		bind $f <Key-space> {set pr11_x 1}
	}
	wm title $f $fnam
	set finished 0
	$text_sfs delete 1.0 end								;#	Clear the filelist window

	if [catch {open $fnam r} fileId] {
		Inf $fileId							;#	If textfile cannot be opened
		Dlg_Dismiss $f							;#	Hide the dialog
		return		
	}
	set qq 0
	set x_max 0
	while {[gets $fileId thisline] >= 0} {			;#	Read lines from textfile into text-listing, avoiding extra newline
		if {$qq > 0} {
			$text_sfs insert end "\n"
		}
		$text_sfs insert end "$thisline"
		set z_len [string length $thisline]
		if {$z_len > $x_max} {
			set x_max $z_len
		}
		incr qq
	}
	close $fileId
	if {$qq > 0} {
		Scrollbars_Reset $text_sfs .stextdisplay.see.sy 0 $qq $x_max
	}	
	set pr11_x 0
	set finished 0
	raise $f
	My_Grab 0 $f pr11_x $f.see.seefile
	tkwait variable pr11_x						;#	Wait for OK to be pressed
	My_Release_to_Dialog $f
	Dlg_Dismiss $f								;#	Hide the dialog
}

proc FilterAtten {} {
	global maxsamp_missing maxsamp_line ch papag CDPmaxId done_maxsamp ins o_nam evv

	$papag.parameters.output.editqik config -bg [option get . background {}] -state disabled
	catch {unset maxsamp_line}

	set file1 [$ch get 0]
	set file2 $o_nam
	append file2 "0" $evv(SNDFILE_EXT)

	set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
	if [info exists maxsamp_missing] {
		Inf "maxsamp2$evv(EXEC) Is Not On Your System.\nCannot Search File For Maximum Sample In File."
		return
	} else {
		if [ProgMissing $cmd "Cannot search file for maximum sample in file."] {
			set maxsamp_missing 1
			return
		}
	}
	set cmda $cmd
	lappend cmda $file1
	if [catch {open "|$cmda"} CDPmaxId] {
		ErrShow "$CDPmaxId"
		return
   	} else {
   		fileevent $CDPmaxId readable "Maxsamp_Info2"
	}
 	vwait done_maxsamp
	catch {close $CDPmaxId}
	set done_maxsamp 0
	set cmda $cmd
	lappend cmda $file2
	if [catch {open "|$cmda"} CDPmaxId] {
		ErrShow "$CDPmaxId"
		return
   	} else {
   		fileevent $CDPmaxId readable "Maxsamp_Info2"
	}
 	vwait done_maxsamp

	set n 0
	if {![info exists maxsamp_line]} {
		Inf "No Maximum Sample Information Retrieved"
		return
	}
	foreach item $maxsamp_line {
		set item [split $item]
		set items($n) [lindex $item end]
		incr n
	}
	if {$n >= 2} {
		if {$items(1) <= 0.0} {
			Inf "Output Has Zero Amplitude"
			return
		}
		set gain [expr double($items(0)) / double($items(1))]
		set gain [expr round($gain * 100.0) / 100.0]
		set gain [string range $gain 0 4]
		if {$gain > 1.0} {
			$papag.parameters.output.editqik config -text "* $gain" -bg $evv(EMPH) -state normal -command "DoFGain $gain"
		} else {
			$papag.parameters.output.editqik config -text "<= 1" -bg $evv(EMPH) -state normal -command "DoFGain 0"
		}
	} else {
		$papag.parameters.output.editqik config -text "Unknown" -bg $evv(EMPH) -state normal -command "DoFGain 0"
	}
}

#------ Store info returned by maxsamp

proc Maxsamp_Info2 {} {
	global CDPmaxId done_maxsamp maxsamp_line

	if {[info exists CDPmaxId] && [eof $CDPmaxId]} {
		catch {close $CDPmaxId}
		set done_maxsamp 1
		return
	} else {
		gets $CDPmaxId line
		set line [string trim $line]
		if {[string length $line] <= 0} {
			return
		}
		if {[string first "ABSOLUTE" $line] >=0} {
			lappend maxsamp_line $line
			set done_maxsamp 1
			return
		}
	}
	update idletasks
}			

#------ Move playlist item to foot of list (to enable sorting)

proc PlayMove {up listing} {
	global old_play play_new

	set i [$listing curselection]
	if {![info exists i] || ($i < 0)} {
		Inf "No File Selected"
		return
	}
	catch {unset old_play}
	foreach item [$listing get 0 end] {
		lappend old_play $item
	}
	set fnam [$listing get $i]
	$listing delete $i
	if {$up} {
		$listing insert 0 $fnam
	} else {
		$listing insert end $fnam
	}
	catch {unset play_new}
	foreach item [$listing get 0 end] {
		lappend play_new $item
	}
	return $play_new
}

proc PlaySort {listing} {
	global old_play play_new
	catch {unset old_play}
	foreach item [$listing get 0 end] {
		lappend old_play $item
	}
	ListSort $listing
	catch {unset play_new}
	foreach item [$listing get 0 end] {
		lappend play_new $item
	}
	return $play_new
}

proc PlayRestore {listing} {
	global old_play play_new
	if {![info exists old_play]} {
		Inf "No Listing To Restore"
		return
	}
	foreach item [$listing get 0 end] {
		lappend other_old_play $item
	}
	$listing delete 0 end
	foreach item $old_play {
		$listing insert end $item
	}
	set play_new $old_play
	set old_play $other_old_play
	return $play_new
}

#-----

proc PlaylistToChlist {do_ptoc_update} {
	global play_pll ch chlist chcnt wstk pr_ptoc ptoc_update_done pr4 evv

	set i [$play_pll curselection]
	if {![info exists i] || ($i < 0)} {
		Inf "No File Selected"
		return
	}
	set fnam [$play_pll get $i]
	set onlist 0
	if [info exists chlist] {
		foreach fnm $chlist {
			if [string match $fnm $fnam] {
				set onlist 1
				break
			}
		}
	}
	set f .ptoc
	if [Dlg_Create $f "TO CHOSEN FILES" "set pr_ptoc 0" -borderwidth $evv(BBDR)] {
		set b1 [frame $f.b1 -borderwidth $evv(SBDR)]
		set b2 [frame $f.b2 -borderwidth $evv(SBDR)]
		button $b1.qu -text Close -command "set pr_ptoc 0" -highlightbackground [option get . background {}]
		pack $b1.qu -side top -pady 2
		radiobutton $b2.add	-variable pr_ptoc -text "Add To List"  -value 1
		radiobutton $b2.rep -variable pr_ptoc -text "Replace List" -value 2
		pack $b2.add $b2.rep -side left -pady 2 -padx 4
		pack $b1 $b2  -side top -pady 1
		wm resizable $f 1 1
		bind $f <Escape> {set pr_ptoc 0}
	}
	set pr_ptoc 0
	set finished 0
	raise $f
	My_Grab 0 $f pr_ptoc
	while {!$finished} {
		tkwait variable pr_ptoc
		switch  -- $pr_ptoc {
			0 {									;#	QUIT
				set finished 1
			}
			1 {									;#	ADD TO LIST
				if {$onlist} {
					Inf "File Is Already On Chosen Files List"
				} else {
					if {$do_ptoc_update} {		;# ORIGINAL CHOSEN LIST NOT YET BACKED UP, therefore BACK IT UP
						DoChoiceBak
						set do_ptoc_update 0	;# PREVENT CHOSEN LIST BEING BACKED UP AGAIN
						set ptoc_update_done 1	;# REMEMBER THAT CHOSEN LIST IS NOW BACKED UP
					}
					lappend chlist $fnam
					$ch insert end $fnam
					incr chcnt
					set finished 1
				}
			}
			2 {									;# REPLACE LIST
				if {$ptoc_update_done} {		;# IF CHOSEN LIST ALREADY BACKED UP, SIMPLY CLEAR IT
					ClearWkspaceSelectedFiles
				} else {
					ClearAndSaveChoice			;# IF NOT, BACK IT UP, AND CLEAR IT
					set ptoc_update_done 1		;# REMEMBER THAT CHOSEN LIST IS NOW BACKED UP
				}
				set do_ptoc_update 0			;# PREVENT CHOSEN LIST BEING BACKED UP AGAIN
				lappend chlist $fnam
				$ch insert end $fnam
				incr chcnt
				set pr4 0
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $do_ptoc_update
}

#-----

proc PlaylistToChlist2 {do_ptoc_update} {
	global play_pll ch chlist chcnt wstk pr_ptoc ptoc_update_done pr4 evv

	set i [$play_pll curselection]
	if {![info exists i] || ($i < 0)} {
		Inf "No File Selected"
		return
	}
	set fnam [$play_pll get $i]
	set onlist 0
	if [info exists chlist] {
		foreach fnm $chlist {
			if [string match $fnm $fnam] {
				set onlist 1
				break
			}
		}
	}		;# REPLACE LIST
	if {$ptoc_update_done} {		;# IF CHOSEN LIST ALREADY BACKED UP, SIMPLY CLEAR IT
		ClearWkspaceSelectedFiles
	} else {
		ClearAndSaveChoice			;# IF NOT, BACK IT UP, AND CLEAR IT
		set ptoc_update_done 1		;# REMEMBER THAT CHOSEN LIST IS NOW BACKED UP
	}
	set do_ptoc_update 0			;# PREVENT CHOSEN LIST BEING BACKED UP AGAIN
	lappend chlist $fnam
	$ch insert end $fnam
	incr chcnt
	set pr4 0
	return $do_ptoc_update
}

#--- Does the CDP process preserve the pitch content of the original file IN ALL CIRCUMSTANCES ?
#--- (in peculiar cases STOM (stereo to mono) might not ...but we assume it does here!!)

proc PitchReproducing {thisprg thismode} {
	global evv

	incr thismode -1
	switch -regexp -- $thisprg \
		^$evv(HOUSE_COPY)$ {
			return 1
		} \
		^$evv(MTON)$ {
			return 1
		} \
		^$evv(HOUSE_CHANS)$ {
			if {($thismode == $evv(STOM)) || ($thismode == $evv(MTOS))} {
				return 1
			}
		}

	return 0
}

#------ Search playlist for a file

proc SearchPlaylist {play_srch} {
	global last_play_srch lastplaystart play_pll

	if {[string length $play_srch] <= 0}  {
		Inf "No Seach String Given"
		return 0
	}
	set len 0
	foreach item [$play_pll get 0 end] {
		incr len
	}
	if {$len == 0} {
		Inf "No Files To Search Through"
		return 0
	}
	if {[info exists last_play_srch] && [string match $last_play_srch $play_srch]} {
		set i $lastplaystart
		foreach item [$play_pll get $lastplaystart end] {
			if {[string first $play_srch $item] >= 0} {
				$play_pll selection clear 0 end
				$play_pll selection set $i
				incr i
				if {$i >= $len} {
					set i 0
				}
				set lastplaystart $i	
				set last_play_srch $play_srch
				return 1
			}
			incr i
		}
	} else {
		set lastplaystart "end"
	}
	set i 0
	foreach item [$play_pll get 0 $lastplaystart] {
		if {[string first $play_srch $item] >= 0} {
			$play_pll selection clear 0 end
			$play_pll selection set $i
			incr i
			if {$i >= $len} {
				set i 0
			}		
			set lastplaystart $i
			set last_play_srch $play_srch
			return 1
		}
		incr i
	}
	catch {unset last_play_srch}
	catch {unset lastplaystart}
	Inf "No Match Found"
	return 0
}

#------ Setup Searching playlist for a file

proc SearchPlaylistForFile {} {
	global wl pr_playfind playfilstr total_wksp_cnt evv

	set f .play_find
	if [Dlg_Create $f "FIND FILE" "set pr_playfind 0" -width 80 -borderwidth $evv(SBDR)] {
		set b1 [frame $f.b1 -borderwidth $evv(SBDR)]
		set b0 [frame $f.b0 -borderwidth $evv(SBDR)]
		button $b1.se -text Search -command {set pr_playfind 1} -highlightbackground [option get . background {}]
		button $b1.dum -text "" -command {} -bd 0 -width 20 -highlightbackground [option get . background {}]
		button $b1.qu -text Close -command {set pr_playfind 0} -highlightbackground [option get . background {}]
		pack $b1.se $b1.dum -side left -pady 1
		pack $b1.qu -side right -pady 1
		label $b0.l -text "STRING TO MATCH"
		pack $b0.l -side top -pady 1
		entry $b0.e -textvariable playfilstr -width 16
		pack $b0.e -side top -pady 1
		pack $b1 $b0 -side top -fill x -expand true
		wm resizable $f 1 1
		bind $f <Escape> {set pr_playfind 0}
		bind $f <Return> {set pr_playfind 1}
	}
	raise $f
	set pr_playfind 0
	set finished 0
	My_Grab 0 $f pr_playfind $f.b0.e
	while {!$finished} {
		tkwait variable pr_playfind
		if {$pr_playfind} {
			if {[SearchPlaylist $playfilstr]} {
				set finished 1
			}
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc PlayScroll  {} {
	global play_pll

	set i [$play_pll curselection]
	if {![info exists i] || ($i < 0)} {
		Inf "No File Selected"
		return
	}
	set fnam [$play_pll get $i]
	$play_pll delete $i
	$play_pll insert 0 $fnam
	$play_pll yview moveto 0
	$play_pll selection set 0
}

proc PlayToChosen {andexit} {
	global chlist ch chcnt pa play_pll pr4

	set i [$play_pll curselection]
	if {![info exists i] || ([llength $i] <= 0)} {
		Inf "No Sound Selected"
		return
	}
	if {[llength $i] > 1} {
		Inf "Select A Single Sound"
		return
	}
	set fnam [$play_pll get $i]
	if {$andexit > 1} {
		DoChoiceBak
		ClearWkspaceSelectedFiles
		lappend chlist $fnam
		$ch insert end $fnam
		incr chcnt
	} else {
		if {[info exists chlist] && ([lsearch $chlist $fnam] >= 0)} {
			Inf "The File '$fnam' Is Already On The Chosen Files List"
		} else {
			lappend chlist $fnam		;#	add to end of list
			$ch insert end $fnam		;#	add to end of display
			incr chcnt
			set isadded 1
		}
	}
	if {!$andexit} {
		if {[info exists isadded]} {
			Inf "The File '$fnam' Has Been Added To The Chosen Files List"
		}
	} else {
		set pr4 1
	}
}

proc PlaylistDeletion {} {
	global wl blist_change wstk files_deleted rememd play_pll playcnt plist_del_warn

	set i [$play_pll curselection]
	if {![info exists i] || ([llength $i] <= 0)} {
		Inf "No File Selected"
		return
	}
	if {[llength $i] > 1} {
		Inf "Select A Single Sound"
		return
	}
	set fnam [$play_pll get $i]

	if {$plist_del_warn} {
		set msg "Are You Sure You Want To DESTROY File '$fnam'?"
		set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
		if {$choice == "no"} {
			return
		}
	}
	if [DeleteFileFromSystem $fnam 0 1] {
		DummyHistory $fnam "DESTROYED"
	}
	if {[info exists blist_change] && ($blist_change)} {
		SaveBL $background_listing
	}
	set j [LstIndx $fnam $wl]
	if {$j >= 0} {	
		WkspCnt [$wl get $j] -1
		$wl delete $j
	}
	$play_pll delete $i
	incr playcnt -1
	set cnt $playcnt
	incr cnt -1
	if {$cnt > 0} {
		if {$i <= $cnt} {
			$play_pll selection set $i
		} else {	
			$play_pll selection set $cnt
		}
	}
	set files_deleted 1
	catch {unset rememd}
}

proc PlayNext {which whichlist} {
	global play_pll play_pll2 playcnt part_pll playcnt2 evv
	switch -- $whichlist {
		play_pll {
			set playlisting $play_pll
			set pplaycnt $playcnt
		}
		play_pll2 {
			set playlisting $play_pll2
			set pplaycnt $playcnt2
		}
		part_pll {
			set playlisting $part_pll
			set pplaycnt [$playlisting index end]
		}
	}
	if {$which < 2} {
		set i [$playlisting curselection]
		if {![info exists i] || ($i < 0)} {
			Inf "No Item Selected"
			return
		}
	}
	switch -- $which {
		0 {		;# NEXT
			incr i 
			if {$i >= $pplaycnt} {
				set i 0
				$playlisting yview moveto 0.0
			}
		}
		1 {		;# PREVIOUS
			incr i -1
			if {$i < 0} {
				set i $pplaycnt
				incr i -1
				$playlisting yview moveto 1.0
			}
		}
		2 {		;# FIRST
			set i 0 
			$playlisting yview moveto 0.0
		}
	}
	$playlisting selection clear 0 end
	$playlisting selection set $i
	set os [$playlisting yview]
	set toppos [lindex $os 0]
	set botpos [lindex $os 1]
	set thispos [expr double($i)/[$playlisting index end]]
	if {($thispos >= [expr [lindex $os 1] - $evv(FLTERR)]) || ($thispos < [expr [lindex $os 0] + $evv(FLTERR)])} {
		$playlisting yview moveto [expr double($i)/double([$playlisting index end])]
	} 
	PlaySelectedSndfile $playlisting
}

proc ChosSort {play_pll} {
	global ch chlist 
	set cnt 0
	foreach fnam [$play_pll get 0 end] {
		lappend thesefiles $fnam
		incr cnt
	}
	DoChoiceBak
	$ch delete 0 end
	catch {unset chlist}
	foreach fnam $thesefiles {
		$ch insert end $fnam
		lappend chlist $fnam
	}
	Inf "Files On Chosen List Have Been Reordered"
}

proc PlayWkRemove {} {
	global play_pll total_wksp_cnt wl ww rememd

	set i [$play_pll curselection]
	if {$i < 0} {
		Inf "No File Selected"
		return
	}
	set fnam [$play_pll get $i]
	if [AreYouSure] {
		set k [LstIndx $fnam $wl]
		if {$k >= 0} {
				set ff [file tail $fnam]				;#	get name without directory path
			if {![string match $ff $fnam]} {	 		;#	IF no directory path, it's not bakdup
				PurgeArray $fnam						;#	can't remove unbakdup files!!
				RemoveFromChosenlist $fnam				;#	Otherwise, remove it
				incr total_wksp_cnt -1
				$wl delete $k
				ForceVal $ww.1.a.endd.l.cnts.all $total_wksp_cnt
				catch {unset rememd}
				$play_pll delete $i
			} else {
				Inf "Cannot Remove Files Which Are Not Backed-Up"
				return
			}
		}
	}
}

proc MaxHarmCalc {vbanktype} {
	global mmod prm chlist pa evv hi actvhi

	if {$vbanktype == 2} {
		set msg2 "Varibank "
		set pno 4
		set fnam [lindex $chlist 0]
		if {![info exists pa($fnam,$evv(SRATE))]} {
			Inf "Cannot Get Data On The Input Sound"
			return
		}
		set srate $pa($fnam,$evv(SRATE))
	} else {
		set msg2 ""
		set pno 4
		set srate $prm(1)
	}
	set thismode $mmod
	incr thismode -1
	set maxfrq [expr $srate / 2.0]
	set minfrq 9.0
	set fnam $prm(0)
	if {[string length $fnam] <= 0} {
		Inf "No Filter Data File Entered As Parameter: Cannot Calculate Maximum Harmonic"
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File $fnam To Read Filter Data"
		return
	}
	set linecnt 1
	set maxfrqinfile 0.0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		} elseif {[string match ";" [string index $line 0]]} {
			continue
		}
		set line [split $line]
		catch {unset nuline}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend nuline $item
			}
		}
		if {![info exists nuline]} {
			continue
		}
		set ccnt 0
		foreach item $nuline {
			if {![IsNumeric $item]} {
				Inf "File $fnam Is Not A Valid $msg2 Filter File"
				close $zit
				return
			}
			if [expr $ccnt & 1] {
				if {$item < 0.0}  {
					Inf "Value $item On Line $linecnt Of File $fnam Is Out Of Range"
					close $zit
					return
				}
				if {($vbanktype == 2) && ($thismode == 0)} {
					set thisfrq $item
				} else {
					set thisfrq [MidiToHz $item]
				}
				if {($thisfrq < $minfrq) || ($thisfrq > $maxfrq)} {
					Inf "Value $item On Line $linecnt Of File $fnam Is Out Of Range"
					close $zit
					return
				}
				if {$thisfrq > $maxfrqinfile} {
					set maxfrqinfile $thisfrq
				}
			}
			incr ccnt
		}
		incr linecnt
	}
	close $zit
	if {$maxfrqinfile <= 0.0} {
		Inf "File $fnam Is Not A Valid $msg2 Filter File"
		return
	}
	set outval [expr int(floor($maxfrq / $maxfrqinfile))]
	if {$outval > $hi($pno)} {
		set outval $hi($pno)
	}
	Inf "Max Possible Harmonic Is $outval"
	if {$outval <= $actvhi($pno)} {
		set prm($pno) $outval
	}
	return
}

#--- Set up the Playlist menu REPEAT ACTION command at top of menu

proc SetPlel {str} {
	global play_pll lastplel

	switch -- $str {
		top			{.playlist.button2.scro.m entryconfig 2 -label "Scroll Selected File To Top" -command PlayScroll} 
		remove		{.playlist.button2.scro.m entryconfig 2 -label "Remove File From Workspace" -command PlayWkRemove} 
		tochosen	{.playlist.button2.scro.m entryconfig 2 -label "Choose Sound To Process" -command "PlayToChosen 0" } 
		tochoq		{.playlist.button2.scro.m entryconfig 2 -label "File To Chosen & Quit Play" -command "PlayToChosen 1" } 
		tochoq2		{.playlist.button2.scro.m entryconfig 2 -label "Replace Chosen & Quit Play" -command "PlayToChosen 2" } 
		clchosen	{.playlist.button2.scro.m entryconfig 2 -label "Clear Chosen List" -command PlayToClearChosen } 
		toblist		{.playlist.button2.scro.m entryconfig 2 -label "Add Sound To A Background Listing" -command "BListFromWkspace $play_pll 0 0"} 
		remblist	{.playlist.button2.scro.m entryconfig 2 -label "Remove Sound From A Background Listing" -command "GetBLName 2" } 
		edblist		{.playlist.button2.scro.m entryconfig 2 -label "See/Play/Edit Background Listings" -command "GetBLName 2" } 
		distblist	{.playlist.button2.scro.m entryconfig 2 -label "Check B-Lists Are Distinct" -command "GetBLName 17" } 
		delete		{.playlist.button2.scro.m entryconfig 2 -label "Destroy File (!!)"  -command PlaylistDeletion} 
	}
	set lastplel $str
}

proc SeeTextfiles {} {
	global wl pa przz read_pzz stindex evv

	foreach fnam [$wl get 0 end] {
		if {$pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)} {
			lappend textlist $fnam
		}
	}
	if {![info exists textlist]} {
		Inf "There Are No Textfiles On The Workspace"
		return
	}
	foreach fnam $textlist {
		set ftail [file tail $fnam]
		set z($ftail) $fnam
		lappend ftaillist $ftail
	}
	set ftaillist [lsort -dictionary $ftaillist]
	set st ""
	set cnt 0
	unset textlist
	catch {unset stindex}
	foreach ftail $ftaillist {
		set firstchar [string index $ftail 0]
		if {![string match $firstchar $st]} {
			set st $firstchar
			lappend stindex $st $cnt
		}
		lappend textlist $z($ftail)
		incr cnt
	}
	set f .textview
	if [Dlg_Create $f "Textfiles" "set przz 1" -borderwidth $evv(BBDR)] {
		set b [frame $f.button -borderwidth $evv(SBDR)]
		button $b.quit -text "Close" -command "set przz 0" -highlightbackground [option get . background {}]
		label $b.ins1 -text "SELECT FILE FROM LIST to view it and e.g. GRAB A VALUE\n--------------------------------------" -fg $evv(SPECIAL)
		label $b.ins2 -text "USE KEYBOARD LETTERS TO INDEX LIST" -fg $evv(SPECIAL) 
		label $b.ins3 -text "e.g. hit 'f' to go to files starting with  'f'" -fg $evv(SPECIAL)
		pack $b.quit $b.ins1 $b.ins2 $b.ins3 -side top -pady 1
		set r [frame $f.reader -borderwidth $evv(SBDR)]
		set read_pzz [Scrolled_Listbox $r.readlist -width 64 -height 32 -selectmode single]
		pack $r.readlist -side top -fill both
		pack $b $r -side top
		bind $read_pzz <ButtonRelease-1> {ShowText %y; 	set przz 1}
		bind $read_pzz <Key-a> {TextShowSel a}
		bind $read_pzz <Key-b> {TextShowSel b}
		bind $read_pzz <Key-c> {TextShowSel c}
		bind $read_pzz <Key-d> {TextShowSel d}
		bind $read_pzz <Key-e> {TextShowSel e}
		bind $read_pzz <Key-f> {TextShowSel f}
		bind $read_pzz <Key-g> {TextShowSel g}
		bind $read_pzz <Key-h> {TextShowSel h}
		bind $read_pzz <Key-i> {TextShowSel i}
		bind $read_pzz <Key-j> {TextShowSel j}
		bind $read_pzz <Key-k> {TextShowSel k}
		bind $read_pzz <Key-l> {TextShowSel l}
		bind $read_pzz <Key-m> {TextShowSel m}
		bind $read_pzz <Key-n> {TextShowSel n}
		bind $read_pzz <Key-o> {TextShowSel o}
		bind $read_pzz <Key-p> {TextShowSel p}
		bind $read_pzz <Key-q> {TextShowSel q}
		bind $read_pzz <Key-r> {TextShowSel r}
		bind $read_pzz <Key-s> {TextShowSel s}
		bind $read_pzz <Key-t> {TextShowSel t}
		bind $read_pzz <Key-u> {TextShowSel u}
		bind $read_pzz <Key-v> {TextShowSel v}
		bind $read_pzz <Key-w> {TextShowSel w}
		bind $read_pzz <Key-x> {TextShowSel x}
		bind $read_pzz <Key-y> {TextShowSel y}
		bind $read_pzz <Key-z> {TextShowSel z}
		bind $f <Escape> {set przz 0}
		bind $f <Return> {set przz 0}
		bind $f <Key-space> {set przz 0}
	}
	$read_pzz delete 0 end
	foreach fnam $textlist {
		$read_pzz insert end $fnam
	}
	set przz 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f przz $read_pzz
	tkwait variable przz
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc ShowText {y} {
	global read_pzz
	set i [$read_pzz nearest $y]
	if {$i < 0} {
		return
	}
	set fnam [$read_pzz get $i]
	SimpleDisplayTextfile $fnam
}

proc TextShowSel {char} {
	global stindex read_pzz
	set char [string tolower $char]
	set k [lsearch $stindex $char]
	if {$k < 0} {
		Inf "No Filenames Begin With $char"
		return
	}
	incr k
	set i [lindex $stindex $k]
	$read_pzz selection clear 0 end
	$read_pzz selection set $i
	set ii [$read_pzz index end]
	$read_pzz yview moveto [expr double($i)/double($ii)]
}
	
proc FindSndfilesChosen {} {
	global chlist pa evv src 

	set in_sndslist {}
	if [info exists chlist] {
		foreach fnam $chlist {
			set ftyp $pa($fnam,$evv(FTYP))
			if {$ftyp & $evv(IS_A_TEXTFILE)} {
				continue
			} elseif {$ftyp == $evv(SNDFILE)} {
				lappend in_sndslist $fnam
				set fnam [OmitSpaces $fnam]
			} elseif [info exists src($fnam)] {
				foreach srcfile $src($fnam) {
					if {![string match $evv(DELMARK)* $srcfile]} {
						lappend in_sndslist $srcfile
					}
				}
			}
		}
	}
	return $in_sndslist
}

#------ View the input sound(s)

proc ViewInput {args} {
	global pr55 inview_pll sndgraphics invlist invlist_view snack_enabled snack_stereo pa evv

	set invlist_view 1
	set i [llength $args] 
	if {$i == 1} {
		set fnam [lindex $args 0]
		if {[Snackable $fnam]} {
			SnackDisplay 0 $evv(SN_FROM_PRMPAGE_NO_OUTPUT) $evv(TIME_OUT) 0
		} elseif {$sndgraphics} {
			if {$pa($fnam,$evv(CHANS)) > 2} {
				Inf "Cannot Display Multichannel Files, in this Display Mode (See System State Menu)"
				return
			}
			PlayWindow2 $fnam 0
		}
		set invlist_view 0
		return
	}
	set invlist [CollapsePlaylist $args]
	ViewOutput
	set invlist_view 0
}

proc ResetDelWarn {} {
	global plist_del_warn
	switch -- $plist_del_warn {
		1 {
			.playlist.button2.scro.m entryconfig 26 -label "Warn About Destroying Files"
			set plist_del_warn 0
		}
		0 {
			.playlist.button2.scro.m entryconfig 26 -label "Turn Off Destroy Warning (Care!!)"
			set plist_del_warn 1
		}
	}
	return 
}

proc RefreshInsndlist {} {
	global chlist insndslist pa evv

	if {![info exists chlist] || ([llength $chlist] != 1)} {
		Inf "This Function Should Not Be Called -- Program Error"
		return
	}
	set zwx [lindex $chlist 0]
	if [catch {open $zwx "r"} fId] {
		Inf "Cannot Open Mixfile To Get Data On Soundfiles It Uses."
	} else {
		while {[gets $fId line] >= 0} {			;#	Look inside mixfile
			set line [split $line]
			foreach item $line {
				if [string length $item] {		;#	Ignoring spaces:comments,get 1st item on line.
					if {![string match \;* $item]} {
						set item [string tolower $item]
						set item [RegulariseDirectoryRepresentation $item]
						if {[info exists pa($item,$evv(FTYP))] && ($pa($item,$evv(FTYP)) == $evv(SNDFILE))} {
							lappend tl $item	;#	If it's a sndfile on wkspace, 
						}
						break					;#	Whether a comment or not, ignore rest of line
					}
				}
			}
		}
		close $fId
		if [info exists tl] {
			set tl [RemoveDupls $tl]
			set	insndslist $tl
			set i [llength $insndslist]
		}										
	}
}

proc InvertData {typ} {
	global prm pa evv
	set type [string toupper $typ]
	if {[IsNumeric $prm(0)]} {
		if {$typ == "balance"} {
			set prm(0) [expr 1.0 - $prm(0)]
		} else {
			set prm(0) [expr -$prm(0)]
		}
		SetScale 0 linear
	} else {
		set fnam $prm(0)
		if {![info exists pa($fnam,$evv(FTYP))]} {
			Inf "Information About File '$fnam' Does Not Exist"
			return
		}
		if {$typ == "balance"} {
			if {![IsANormdBrkfile $pa($fnam,$evv(FTYP))]} {
				Inf "'$fnam' Is Not A $type File"
				return
			}
		} else {
			if {![IsABrkfile $pa($fnam,$evv(FTYP))]} {
				Inf "'$fnam' Is Not A $type File"
				return
			}
		}
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot Open File '$fnam' To Invert $type Data"
			return
		}
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[llength $line] <= 0} {
				continue
			}
			if {[string match [string index $line 0] ";"]} {
				lappend nulines $nuline
				continue
			}
			set line [split $line]
			set cnt 0
			catch {unset nuline}
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] > 0} {
					lappend nuline $item
					incr cnt
				}
			}
			if {$cnt != 2} {
				Inf "Invalid Data In File '$fnam'"
				close $zit
				return
			}
			if {$typ == "balance"} {
				set nubal [expr 1.0 - [lindex $nuline 1]]
				if {[string first "e" $nubal] >= 0} {
					set nubal 0.0
				}
			} else {
				set nubal [lindex $nuline 1]
				set nubal [expr -$nubal]
			}
			set nuline [lreplace $nuline 1 1 $nubal]
			lappend nulines $nuline
		}
		close $zit
		if [catch {open $fnam "w"} zit] {
			Inf "Cannot Reopen File '$fnam' To Write Inverted $type Data"
			return
		}
		foreach line $nulines {
			puts $zit $line
		}
		close $zit
		UpdateBakupLog $fnam modify 1
	}
	Inf "Inverted"
}

proc PlaySndfileNew {full_display} {
	global CDPsurf playcmd wavesurfer_copyright_informed wl pa evv

	if {!$wavesurfer_copyright_informed} {
		DisplayWavesurferCopyright
	}
	set ilist [$wl curselection]
	set i [lindex $ilist 0]
	if {$i < 0} {
		Inf "No Sound Selected"
		return
	}
	if {[llength $ilist] > 1} {
		Inf "Select A Single Sound "
		return
	}
	set fnam [$wl get $i]
	set ftyp $pa($fnam,$evv(FTYP))
	if {$ftyp != $evv(SNDFILE)} {
		Inf "Select A Sound File"
		return
	}

	if {[info exists CDPsurf($fnam)]} {
		Inf "You Already Have A Window Open To Play A Sound With This Name\n\nPlease Close That Window Before Proceeding"
		return
	}

	set cmd [file join $evv(CDPROGRAM_DIR) wavesurfer]
	if {$full_display} {
		set cmd [concat $cmd -config Demonstration $fnam]
	} else {
		set cmd [concat $cmd -config Waveform $fnam]
	}

	if [catch {open "|$cmd"} CDPsurf($fnam)] {
		ErrShow "$CDPsurf($fnam) : Play program not responding with file $fnam"
		return 0
	} else {
  		fileevent $CDPsurf($fnam) readable "Surf_Info $fnam"
	}
	return 1
}

proc Surf_Info {Id} {
	global CDPsurf
	catch {close $CDPsurf($Id)}
	catch {unset CDPsurf($Id)}
	return
}			

#------ Display Wavesurfer Copyright Message

proc DisplayWavesurferCopyright {} {
	global wavesurfer_copyright_informed evv

	set fnam [file join $evv(URES_DIR) $evv(CDP_SURF)$evv(CDP_EXT)]
	if {[file exists $fnam]} {
		return
	} else {
		set msg "Copyright (C) 2000-2002 Jonas Beskow and Kåre Sjölander \n"
		append msg "\n"
		append msg "The following terms apply to all files associated\n"
		append msg "with the software unless explicitly disclaimed in individual files.\n"
		append msg "\n"
		append msg "The authors hereby grant permission to use, copy, modify, distribute,\n"
		append msg "and license this software and its documentation for any purpose, provided\n"
		append msg "that existing copyright notices are retained in all copies and that this\n"
		append msg "notice is included verbatim in any distributions. No written agreement,\n"
		append msg "license, or royalty fee is required for any of the authorized uses.\n"
		append msg "Modifications to this software may be copyrighted by their authors\n"
		append msg "and need not follow the licensing terms described here, provided that\n"
		append msg "the new terms are clearly indicated on the first page of each file where\n"
		append msg "they apply.\n"
		append msg "\n"
		append msg "IN NO EVENT SHALL THE AUTHORS OR DISTRIBUTORS BE LIABLE TO ANY PARTY\n"
		append msg "FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES\n"
		append msg "ARISING OUT OF THE USE OF THIS SOFTWARE, ITS DOCUMENTATION, OR ANY\n"
		append msg "DERIVATIVES THEREOF, EVEN IF THE AUTHORS HAVE BEEN ADVISED OF THE\n"
		append msg "POSSIBILITY OF SUCH DAMAGE.\n"
		append msg "\n"
		append msg "THE AUTHORS AND DISTRIBUTORS SPECIFICALLY DISCLAIM ANY WARRANTIES,\n"
		append msg "INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY,\n"
		append msg "FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.  THIS SOFTWARE\n"
		append msg "IS PROVIDED ON AN \"AS IS\" BASIS, AND THE AUTHORS AND DISTRIBUTORS HAVE\n"
		append msg "NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR\n"
		append msg "MODIFICATIONS.\n"
		Inf $msg
		if [catch {open $fnam "w"} zit] {
			Inf "Cannot Open File '$fnam' To Register That You Have Read The 'Wavesurfer' Copyright Notice"
			return
		}
		close $zit
	}
	set wavesurfer_copyright_informed 1
}

#------ Get Wavesurfer Copyright

proc GetWavesurferCopyright {} {
	global wavesurfer_copyright_informed evv

	set fnam [file join $evv(URES_DIR) $evv(CDP_SURF)$evv(CDP_EXT)]
	if {[file exists $fnam]} {
		set wavesurfer_copyright_informed 1
	} else {
		set wavesurfer_copyright_informed 0
	}
}

proc NoLongerAvailable {progno modeno} {
	global evv
	set returnval 0
	switch -regexp -- $progno \
		^$evv(HOUSE_EXTRACT)$ {
			if {$modeno == 5} {	;# "Fix by hand"
				set returnval 1
			}
		} \
		^$evv(HOUSE_SPEC)$ {
			if {$modeno > 1} {	;# "Change sampletype or channel count in header"
				set returnval 1
			}
		}

	return $returnval
}

proc NotAccessible {progno modeno} {
	global panprocess bulksplit evv
	set returnval 0
	if {$progno == $evv(MCHANPAN)} {
		if {$modeno == 8} {		;# "Pan a process"
			if {![info exists panprocess]} {
				Inf "This Process Only Works After Setting \"Pan Process Round Multichan File\" On The \"Music Testbed\""
				set returnval 1
			} elseif {$panprocess < 3} {
				Inf "Process The Multichannel File, Before Chosing This Option"
				set returnval 1
			}
		} else {
			if {[info exists panprocess] && ($panprocess == 3)} {
				Inf "Only \"Pan A Process\" Works At This Point"
				set returnval 1
			}
		}
	} elseif {[info exists panprocess] && ($panprocess > 1)} {
		set returnval 1
	} elseif {[info exists bulksplit]} {
		if {($progno == $evv(MOD_SPACE)) && ($modeno != 1)} {
			set returnval 1
		} elseif {($progno == $evv(MOD_REVECHO)) && ($modeno == 2)} {
			set returnval 1
		}
	}
	return $returnval
}

proc StretchToSqueeze {twoparams} {
	global prm pa evv wstk wl total_wksp_cnt scores_refresh background_listing rememd
	set n 0
	set doneboth 0
	if {$twoparams == 3} {
		set startn 4
		set n 4
		set step 1
		set lim 5 
	} else {
		set startn 0
		set n 0
		set step 2
		set lim 2
	}
	while {$n <= $lim} {
		set val $prm($n)
		if {[IsNumeric $val]} {
			if {$val < 0.0} {
				set msg "Invalid Timestretch "
				if {$n == $lim} {
					append msg "Limit "
				} 
				append msg "Value"
				Inf $msg
				return
			}
			if {$val != 0} {
				set prm($n) [expr 1.0/$prm($n)]
			}
		} else {
			set fnam $val
			if {![info exists pa($fnam,$evv(FTYP))]} {
				Inf "File '$fnam' Is Not A File On The Workspace"
				return
			}
			if {![IsABrkfile $pa($fnam,$evv(FTYP))]} {
				Inf "File '$fnam' Is Not A Breakpoint File"
				return
			}
			if {$pa($fnam,$evv(MINBRK)) < 0.0} {
				Inf "File '$fnam' Is Not A Valid Timewarp File (Contains Negative Values)"
				return
			}
			if {$pa($fnam,$evv(MINBRK)) == 0.0} {
				Inf "File '$fnam' Contains Zeros, Cannot Invert Stretch To Squeeze"
				return
			}
			if [catch {open $fnam "r"} zit] {
				Inf "Cannot Open File '$fnam'"
				return
			}
			catch {unset times}
			catch {unset vals}
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
						0 { lappend times $item }
						1 { lappend vals  $item }
					}
					incr cnt
				}
				if {$cnt != 2} {
					Inf "Invalid Data Line In File '$fnam'"
					close $zit
					return
				}
			}
			close $zit
			if {![info exists times]} {
				Inf "No Data Found In File '$fnam'"
				return
			}
			if {($n == $startn) && $twoparams && [string match $prm($startn) $prm($lim)]} {
				set doneboth 1
			}
			catch {unset nuvals}
			foreach val $vals {
				set nuval [expr 1.0 / $val]
				lappend nuvals $nuval
			}
			set origfnam $fnam
			set nu_name 0
			set msg "Overwrite Original File '$fnam' ?"
			set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				set fnam [GetStretchFname]
				if {[string length $fnam] <= 0} {
					return
				}
				set nu_name 1
			}
			if [catch {open $fnam "w"} zit] {
				Inf "Cannot Open File '$fnam' To Write New Values"
				return
			}
			foreach time $times val $nuvals {
				set line $time
				append line "  " $val
				puts $zit $line
			}
			close $zit
			if {$nu_name} {
				;#	IF NEW NAME, NOT IN A SUBDIR, so NO UpdateBakupLog
				set prm($n) $fnam
				catch {unset rememd}
			} else {
				UpdateBakupLog $origfnam modify 1
				set i [LstIndx $origfnam $wl]
				set ftyp $pa($origfnam,$evv(FTYP))
				PurgeArray $origfnam
				RemoveFromChosenlist $origfnam
				incr total_wksp_cnt -1
				$wl delete $i
				DeleteFileFromSrcLists $origfnam
				if [IsInBlists $origfnam] {
					set msg "The Overwritten File '$origfnam' Was Mentioned In Background Listings\n\nRemove Those Mentions ??"
					set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
					if {$choice == "yes"} {
						if [RemoveFromBLists $origfnam] {
							SaveBL $background_listing
						}
					}
				}
				if [IsOnScore $origfnam] {
					set msg "The Overwritten File '$origfnam' Is In Use In The Current Sketch Score\n\nRemove It ??"
					set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
					if {$choice == "yes"} {
						RemoveFromScore $origfnam
						set scores_refresh 1
					}
				} elseif {$ftyp == $evv(SNDFILE)} {
					set scores_refresh 1
				}
				DummyHistory $origfnam "OVERWRITTEN"
			}
			FileToWkspace $fnam 0 0 0 0 1
		}
		if {$doneboth} {
			set prm($lim) $prm($startn)
			break
		}
		if {!$twoparams} {
			break
		}
		incr n $step
	}
}

proc GetStretchFname {} {
	global pr_squeeze squeezename evv

	set f .stretch
	if [Dlg_Create $f "Stretchfile Name" "set pr_squeeze 0" -borderwidth $evv(BBDR)] {
		frame $f.0 -borderwidth $evv(SBDR)
		frame $f.1 -borderwidth $evv(SBDR)
		button $f.0.ok -text "Keep Name" -command "set pr_squeeze 1" -highlightbackground [option get . background {}]
		button $f.0.q -text  "Abandon" -command "set pr_squeeze 0" -highlightbackground [option get . background {}]
		pack $f.0.ok -side left
		pack $f.0.q  -side right
		label $f.1.ll -text "New Filename"
		entry $f.1.e -textvariable squeezename -width 24
		pack $f.1.ll $f.1.e -side left -padx 2
		pack $f.0 -side top -fill x -expand true
		pack $f.1 -side top
		wm resizable $f 1 1
		bind $f <Escape> {set pr_squeeze 0}
		bind $f <Return> {set pr_squeeze 1}
	}
	set squeezename ""
	set pr_squeeze 0
	set finished 0
	raise $f
	My_Grab 0 $f pr_squeeze $f.1.e
	while {!$finished} {
		tkwait variable pr_squeeze
		if {$pr_squeeze == 0} {
			set squeezename ""
			break
		}
		if {[string length $squeezename] <= 0} {
			Inf "No Filename Entered"
			continue
		}
		if {![ValidCDPRootname $squeezename]} {
			Inf "Invalid Filename Entered"
			continue
		}
		if {[file exists $squeezename]} {
			Inf "File $squeezename Already Exists: Please Choose Another Name"
			continue
		}
		append squeezename [GetTextfileExtension brk]
		break
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $squeezename
}

proc WindowCountOutOfRange {} {
	global chlist pa evv
	if {![info exists chlist] || ([llength $chlist] <= 0)} {
		return 1
	}
	set fnam [lindex $chlist 0]
	if {![info exists pa($fnam,$evv(WLENGTH))]} {
		return 1
	}
	if {$pa($fnam,$evv(WLENGTH)) > $evv(PDISPLAY_MAXWINDOWS)} {
		return 1
	}
	return 0
}

proc PitchEditorValid {str} {
	global ins bulk in_recycle evv
	if {$in_recycle || $ins(create) || $bulk(run) || [WindowCountOutOfRange]} {
		return 0
	}
	if {[ProgMissing [file join $evv(CDPROGRAM_DIR) pdisplay] $str]} {
		return 0
	}
	return 1
}

proc ReEstablishMixRange {dur duratend0 duratend1} {
	global lo hi sublo subhi actvlo actvhi prmgrd prange prm
	if {[Flteq $actvhi(1) $dur]} {
		return
	}
 	set lo(0) 0
	set hi(0) $dur
 	set lo(1) 0
 	set hi(1) $dur
 	set sublo(1) $lo(1)
 	set subhi(1) $hi(1)

 	set actvlo(1) $lo(1)
 	set actvhi(1) $hi(1)
	set prange(1) [expr $actvhi(1) - $actvlo(1)]
 	set actvlo(0) $lo(0)
 	set actvhi(0) $hi(0)
	set prange(0) [expr $actvhi(0) - $actvlo(0)]
	SetPrtype 1
	set lotxt [FiveSigFig $actvlo(1)]
	set hitxt [FiveSigFig $actvhi(1)]
	$prmgrd.rlo0 config -text $lotxt
	$prmgrd.rhi0 config -text $hitxt
	$prmgrd.rlo1 config -text $lotxt
	$prmgrd.rhi1 config -text $hitxt
	if {$prm(1) > $dur} {
		set prm(1) $dur
		SetScale 1 lin
	} elseif {$prm(1) < $dur} { 
		if {$duratend1} {
			set prm(1) $dur
		}
		SetScale 1 lin
	}
	if {$prm(0) > $dur} {
		set prm(0) $dur
		SetScale 0 lin
	} elseif {$prm(0) < $dur} { 
		if {$duratend0} {
			set prm(0) $dur
		}
		SetScale 0 lin
	}
}

proc MixTimetap {} {
	global tap_on tap_t papag prm evv

	set tap_t($tap_on) [clock clicks]
	incr tap_on
	if {$tap_on > 1} {
		$papag.parameters.output.editqik config -state disabled -bg [option get . background {}]
		set tap_on 0
		set secs [expr (double($tap_t(1) - $tap_t(0))) / $evv(CLOCK_TICK)]
		set prm(0) $secs
		$papag.parameters.output.editqik config -state normal
	} else {
		$papag.parameters.output.editqik config -bg $evv(EMPH)
	}
}

proc MixCrossNudge {prog} {
	global prm pr_cronud cronud_time cronud_stag wstk
	if {![info exists prm] || ![info exists prm(0)] || ![info exists prm(1)] || ![info exists prm(2)]} {
		Inf "No Times To Nudge"
		return
	}
	if {![IsNumeric $prm(0)] || ![IsNumeric $prm(1)] || ![IsNumeric $prm(2)]} {
		Inf "Not All Time Values Are Numeric"
		return
	}
	set callcentre [GetCentre [lindex $wstk end]]
	set f .cronud
	if [Dlg_Create $f "NUDGE CROSSFADE TIMES" "set pr_cronud 0" -bd 2 -width 320 -height 64] {
		frame $f.1
		frame $f.2
		button $f.1.q -text "Close"  -command "set pr_cronud 0" -highlightbackground [option get . background {}]
		button $f.1.n -text "Nudge" -command "set pr_cronud 1" -highlightbackground [option get . background {}]
		radiobutton $f.1.c -text "clear" -value dummy -command {set cronud_time ""}
		pack $f.1.n $f.1.c -side left
		pack $f.1.q -side right
		label $f.2.ll -text "Move times by  "
		entry $f.2.e -textvariable cronud_time -width 8
		checkbutton $f.2.r -variable cronud_stag -text "Move Stagger"
		pack $f.2.ll $f.2.e $f.2.r -side left -padx 2
		pack propagate $f false
		pack $f.1 -side top -pady 2 -fill x -expand true
		pack $f.2 -side top -pady 2 -fill x -expand true
		bind $f <Escape> {set pr_cronud 0}
		bind $f <Return> {set pr_cronud 1}
	}
	switch -- $prog {
		"mixcross" {
			wm title $f "NUDGE CROSSFADE TIMES"
			$f.2.r config -text "Move Stagger" -state normal
			set cronud_stag 0
		}
		"curtail" {
			wm title $f "NUDGE CURTAIL TIMES"
			set cronud_stag 0
			$f.2.r config -text "" -state disabled
		}
	}
	wm resizable $f 1 1
	set pr_cronud 0
	set finished 0
	raise $f
	update idletasks
	set geo [CentreOnCallingWindow $f $callcentre]
	My_Grab 1 $f pr_cronud $f.2.e
	wm geometry $f $geo
	while {!$finished} {
		tkwait variable pr_cronud
		if {$pr_cronud} {
			if {![IsNumeric $cronud_time]} {
				Inf "Invalid Nudge Time Entered"
				continue
			}
			if {$cronud_stag}  {
				set test [expr $prm(0) + $cronud_time]
				if {$test < 0} {
					Inf "Invalid Stagger Time ($test) Generated"
					continue
				} else {
					set prm(0) $test
				}
			}
			switch -- $prog {
				"mixcross" {
					set prm(1) [expr $prm(1) + $cronud_time]
					set prm(2) [expr $prm(2) + $cronud_time]
				}
				"curtail" {
					set prm(0) [expr $prm(0) + $cronud_time]
					set prm(1) [expr $prm(1) + $cronud_time]
				}
			}
		}
		set finished 1
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

proc GrainTrap {} {
	global pprg mmod evv pa ins bulk chlist
	switch -regexp -- $pprg \
		^$evv(GRAIN_COUNT)$		- \
		^$evv(GRAIN_OMIT)$		- \
		^$evv(GRAIN_DUPLICATE)$	- \
		^$evv(GRAIN_REORDER)$	- \
		^$evv(GRAIN_REPITCH)$	- \
		^$evv(GRAIN_RERHYTHM)$	- \
		^$evv(GRAIN_REMOTIF)$	- \
		^$evv(GRAIN_TIMEWARP)$	- \
		^$evv(GRAIN_GET)$		- \
		^$evv(GRAIN_POSITION)$	- \
		^$evv(GRAIN_ALIGN)$		- \
		^$evv(GRAIN_REVERSE)$ {
			if {$ins(run)} {
				if {![info exists ins(chlist)] || ([llength $ins(chlist)] <= 0)} {
					return 1
				}
				set thischlist $ins(chlist)
			} else {
				if {![info exists chlist] || ([llength $chlist] <= 0)} {
					return 1
				}
				set thischlist $chlist
			}
			foreach fnam $thischlist {		
				if {$pa($fnam,$evv(DUR)) <= 0.1} {
					Inf "File '$fnam' Is Too Short\nThis Grain Process Does Not Work With Sounds Of 0.1 Second Or Less"
					return 1
				}
			}
		}

	if {$bulk(run) && ($pprg == $evv(RRRR_EXTEND)) && ($mmod == 3)} {
		Inf "THIS PROCESS WILL NOT RUN IN BULK PROCESSING MODE"
		return 1
	}
	return 0
}

proc RemoveDupls {inlist} {
	set len [llength $inlist]
	if {$len > 1} {
		set len_less_one [expr $len - 1]
		set i 0
		while {$i < $len_less_one} {
			set j $i
			incr j
			while {$j < $len} {
				if {[string match [lindex $inlist $i] [lindex $inlist $j]]} {
					set inlist [lreplace $inlist $j $j]
					incr j -1
					incr len -1
					incr len_less_one -1
				}
				incr j
			}
			incr i		
		}
	}
	return $inlist
}

proc ReverseBalanceFiles {} {
	global ch chlist actvhi actvlo hi prmgrd prange pa evv
	if {![info exists chlist] || ([llength $chlist] !=2)} {
		return
	}
	set chlist [ReverseList $chlist]
	$ch delete 0 end
	foreach  fnam $chlist {
		$ch insert 0 $fnam
	}
	set actvhi(2) $pa([lindex $chlist 0],$evv(DUR))
	set hi(2) $pa([lindex $chlist 0],$evv(DUR))
	set prange(2) [expr $actvhi(2) - $actvlo(2)]
	SetPrtype 2
	$prmgrd.rhi2 config -text [FiveSigFig $actvhi(2)]
	SetScale 2 linear
	Inf "Sound Order Reversed"
}

proc PlayToClearChosen {} {
	global ch chlist chcnt
	DoChoiceBak
	$ch delete 0 end
	catch {unset chlist}
	set chcnt 0
}

proc PitchDetails {} {
	global chlist pr_pd GpId done_pd pa evv val_pd zonk readonlyfg readonlybg
	if {![info exists chlist] || ([llength $chlist] != 1) || ![info exists pa([lindex $chlist 0],$evv(FTYP))]} {
		Inf "Cannot Locate The Source Pitch File"
		return
	}
	set f .pitchdet
	if [Dlg_Create $f "Pitch Details " "set pr_pd 1" -borderwidth $evv(BBDR)] {
		button $f.quit -text OK -command "set pr_pd 0" -highlightbackground [option get . background {}]
		pack $f.quit -side top -pady 2
		set b0 [frame $f.button0 -borderwidth $evv(SBDR)]
		set b1 [frame $f.button1 -borderwidth $evv(SBDR)]
		set b2 [frame $f.button2 -borderwidth $evv(SBDR)]
		set b3 [frame $f.button3 -borderwidth $evv(SBDR)]
		label $b2.valab -text "MEAN: Frq "
		entry $b2.val -textvariable zonk(00) -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $b2.milab -text "Midi "
		entry $b2.midi -textvariable zonk(01) -width 8 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $b2.aplab -text "Approx Midi "
		entry $b2.app -textvariable zonk(02) -width 6 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $b2.nolab -text "Note"
		entry $b2.note -textvariable zonk(03) -width 6 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $b2.valab $b2.val $b2.milab $b2.midi $b2.aplab $b2.app $b2.nolab $b2.note -side left -padx 2

		label $b1.valab -text "MIN:   Frq "
		entry $b1.val -textvariable zonk(10) -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $b1.milab -text "Midi "
		entry $b1.midi -textvariable zonk(11) -width 8 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $b1.aplab -text "Approx Midi "
		entry $b1.app -textvariable zonk(12) -width 6 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $b1.nolab -text "Note"
		entry $b1.note -textvariable zonk(13) -width 6 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $b1.tilab -text "Time"
		entry $b1.time -textvariable zonk(14) -width 8 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $b1.valab $b1.val $b1.milab $b1.midi $b1.aplab $b1.app $b1.nolab $b1.note $b1.tilab $b1.time -side left -padx 2

		label $b0.valab -text "MAX:   Frq "
		entry $b0.val -textvariable zonk(20) -width 12 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $b0.milab -text "Midi "
		entry $b0.midi -textvariable zonk(21) -width 8 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $b0.aplab -text "Approx Midi "
		entry $b0.app -textvariable zonk(22) -width 6 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $b0.nolab -text "Note"
		entry $b0.note -textvariable zonk(23) -width 6 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $b0.tilab -text "Time"
		entry $b0.time -textvariable zonk(24) -width 8 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $b0.valab $b0.val $b0.milab $b0.midi $b0.aplab $b0.app $b0.nolab $b0.note $b0.tilab $b0.time -side left -padx 2

		label $b3.valab -text "TOTAL RANGE :"
		entry $b3.val -textvariable zonk(30) -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		label $b3.semilab -text "Semitones "
		pack $b3.valab $b3.val $b3.semilab -side left -padx 2 -anchor w

		pack $b0 $b1 $b2 $b3 -side top -pady 2 -anchor w
		wm resizable $f 1 1
		bind $f <Return> {set pr_pd 0}
		bind $f <Escape> {set pr_pd 0}
		bind $f <Key-space> {set pr_pd 0}
	}
	set fnam [lindex $chlist 0]
	catch {unset val_pd}
	Block "Extracting Pitch Details"
	set cmd [file join $evv(CDPROGRAM_DIR) pitchinfo]
	lappend cmd info $fnam
	if [catch {open "|$cmd"} GpId] {
		ErrShow "$GpId"
		UnBlock
		return
   	} else {
   		fileevent $GpId readable Show_Pitchdetails
	}
 	vwait done_pd
	catch {close $GpId}
	UnBlock
	if {!$done_pd || ![info exists val_pd]} {
		Dlg_Dismiss $f
		return
	}
	catch {unset outvals}
	set linecnt 0
	foreach val $val_pd {
		set itemcnt 0
		set vals [split $val]
		foreach v $vals {
			set v [string trim $v]
			if {[string length $v] <= 0} {
				continue
			}
			switch -- $linecnt {
				0 -
				1 {
					switch -- $itemcnt {
						3 {
							set k [string first "HZ" $v]
							incr k -1
							set v [string range $v 0 $k]
							append v "  Hz"
							ForceVal .pitchdet.button$linecnt.val $v
						}			
						6 {
							ForceVal .pitchdet.button$linecnt.midi $v
							set v [expr int(round($v))]
							ForceVal .pitchdet.button$linecnt.app $v
							set oct [expr int($v / 12.0) - 5]
							set basetone [expr int(round($v))]
							set basetone [expr $basetone % 12]
							switch -- $basetone {
								0  {set v C}
								1  {set v C#}
								2  {set v D}
								3  {set v Eb}
								4  {set v E}
								5  {set v F}
								6  {set v F#}
								7  {set v G}
								8  {set v Ab}
								9  {set v A}
								10 {set v Bb}
								11 {set v B}
							}
							append v $oct
							ForceVal .pitchdet.button$linecnt.note $v
						}
						8 {
							ForceVal .pitchdet.button$linecnt.time $v
						}
					}
				}
				2 {
					switch -- $itemcnt {
						2 {
							set k [string first "HZ" $v]
							incr k -1
							set v [string range $v 0 $k]
							append v "  Hz"
							ForceVal .pitchdet.button$linecnt.val $v
						}			
						5 {
							ForceVal .pitchdet.button$linecnt.midi $v
							set v [expr int(round($v))]
							ForceVal .pitchdet.button$linecnt.app $v
							set oct [expr int($v / 12.0) - 5]
							set basetone [expr int(round($v))]
							set basetone [expr $basetone % 12]
							switch -- $basetone {
								0  {set v C}
								1  {set v C#}
								2  {set v D}
								3  {set v Eb}
								4  {set v E}
								5  {set v F}
								6  {set v F#}
								7  {set v G}
								8  {set v Ab}
								9  {set v A}
								10 {set v Bb}
								11 {set v B}
							}
							append v $oct
							ForceVal .pitchdet.button$linecnt.note $v
						}
						8 {
							ForceVal .pitchdet.button$linecnt.time $v
						}
					}
				}
				3 {
					switch -- $itemcnt {
						2 {
							if {[llength $val] == 4} {
								ForceVal .pitchdet.button$linecnt.val $v
							} else {
								set vv [expr $v * 12]
							}
						}			
						5 {
							set v [expr $vv + $v]
							ForceVal .pitchdet.button$linecnt.val $v
						}			
					}
				}
			}
			incr itemcnt
		}
		incr linecnt
	}
	set pr_pd 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_pd
	tkwait variable pr_pd
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc Show_Pitchdetails {} {
	global GpId val_pd done_pd
	if {![info exists GpId] || [eof $GpId]} {
		catch {close $GpId}				 
		set done_pd 1				 
		return
	} else {
		gets $GpId line
		set line [string trim $line]
		if [string match ERROR:* $line] {
			set str [string range $line [string first "ERROR:" $line] end] 
			ErrShow $str
			catch {close $GpId}
			set done_pd 0				 
		} elseif [string match CDP* $line] {
			;# SKIP
		} elseif {[string length $line] > 0} {
			lappend val_pd $line
		}
	}
}

# ----- view a sinlge formant, in a snigle formant file

proc ViewSingleForm {} {
	global ins evv o_nam CDPvf vfdone
	
	if {$ins(run)} {
		set namegroup $evv(MACH_OUTFNAME) 	;#	Collects outputs from ALL ins-processes
	} else {
		set namegroup $o_nam					;#	Collects normal outs, or current Instrumentcreateprocess outs
	}
	append namegroup 0
	foreach fnam [lsort -dictionary [glob -nocomplain $namegroup*]] {
		lappend oneformlist $fnam
	}
	if {![info exists oneformlist] || ([llength $oneformlist] != 1)} {
		Inf "Problem Finding Single-Formant File"
		return
	}
	set cmd [file join $evv(CDPROGRAM_DIR) vuform]

	if [catch {open "|$cmd $oneformlist"} CDPvf] {
		ErrShow "Failed To Run 'vuform'"
		catch {unset CDPvf}
		return										
	} else {										
   		fileevent $CDPvf readable VufError
	}												
	vwait vfdone

	set len [string length $namegroup]
	incr len -2
	set fnam [string range $namegroup 0 $len]
	append fnam "1" $evv(TEXT_EXT)
	if {![file exists $fnam]} {
		ErrShow "No Data Returned From 'vuform'"
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open Intermediate File '$fnam' To Read Formant Data"
		return
	}
	set linecnt 0
	set isvals 0 
	set z 0
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
		}
		switch -- $linecnt {
			0 {
				set specenvcnt $line
			}
			default {
				set val $line
				if {$isvals} {
					lappend vals $val
				} else {
					lappend rang $val
					incr z
					if {$z >= $specenvcnt} {
						set isvals 1
					}
				}
			}
		}
		incr linecnt
	}
	close $zit
	if {![info exists rang]} {
		Inf "No Valid Data Found"
		return
	}
	set maxval 0.0
	foreach val $vals {
		if {$val > $maxval} {
			set maxval $val
		}
	}
	if {$maxval <= 0.0} {
		Inf "Formant Has Zero Level"
		return
	}
	DisplayFormantData [file tail $fnam] $rang $vals $maxval
}

proc VufError {} {
	global CDPvf vfdone

	if [eof $CDPvf] {
		set vfdone 1
		catch {close $CDPvf}				 
		return
	} else {
		gets $CDPvf line
		set str [string trim $line]
		if [string match ERROR:* $line] {
			set str [string range $line [string first "ERROR:" $line] end] 
			set vfdone 0
			ErrShow $str
			catch {close $CDPid}				 
		} else {
			set vfdone 1
			catch {close $CDPid}
		}
	}
}

proc GainParamAtten {typ} {
	global maxsamp_missing maxsamp_line ch papag CDPmaxId done_maxsamp ins o_nam prm evv

	$papag.parameters.output.editqik config -bg [option get . background {}] -state disabled
	catch {unset maxsamp_line}

	set file1 $o_nam
	append file1 "0" $evv(SNDFILE_EXT)

	set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
	if [info exists maxsamp_missing] {
		Inf "maxsamp2$evv(EXEC) Is Not On Your System.\nCannot Search File For Maximum Sample In File."
		return
	} else {
		if [ProgMissing $cmd "Cannot search file for maximum sample in file."] {
			set maxsamp_missing 1
			return
		}
	}
	set cmda $cmd
	lappend cmda $file1
	if [catch {open "|$cmda"} CDPmaxId] {
		ErrShow "$CDPmaxId"
		return
   	} else {
   		fileevent $CDPmaxId readable "Maxsamp_Info2"
	}
 	vwait done_maxsamp
	catch {close $CDPmaxId}
	set n 0
	if {![info exists maxsamp_line]} {
		Inf "No Maximum Sample Information Retrieved"
		return
	}
	set maxsamp_line [StripCurlies $maxsamp_line]
	set items [split $maxsamp_line]
	set gain [lindex $items end]
	switch -- $typ {
		"psow"    {set paramno 7}
		"stadium" {set paramno 0}
	}
	if {$gain > 1.0} {
		set gain [expr 1.0/$gain]
		set gain [string range $gain 0 4]
		set gain [DecPlaces [expr $prm($paramno) * $gain] 6]
		$papag.parameters.output.editqik config -text "* $gain" -bg $evv(EMPH) -state normal -command {}
		set prm($paramno) $gain
	} else {
		$papag.parameters.output.editqik config -text "1 or more" -bg $evv(EMPH) -state normal -command {}
	}
}

proc LocalVib {} {
	global prm chlist evv pr_locvib viblocname wstk pa actvlo actvhi viblocend vlocrandep vlocranfrq
	global readonlyfg readonlybg

	catch {unset viblocend}
	set fnam [lindex $chlist 0]
	if {![IsNumeric $prm(1)] || ($prm(1) < 0.0) || ($prm(1) > $actvhi(1))} {
		Inf "Invalid Freeze Time On Parameters Page."
		return
	}
	if {![IsNumeric $prm(2)] || ($prm(2) <= $actvlo(2)) || ($prm(2) > $actvhi(2))} {
		Inf "Invalid Output Duration On Parameters Page."
		return
	}
	if {![IsNumeric $prm(5)] || ($prm(5) < $actvlo(5)) || ($prm(5) > $actvhi(5))} {
		Inf "Invalid Vibrato Depth On Parameters Page"
		return
	}
	if {[Flteq $prm(5) 0.0]} {
		Inf "Zero Vibrato Depth On Parameters Page: Enter An Average Value"
		return
	}
	set stt $prm(1)
	set vibdur [expr $prm(2) - $pa([lindex $chlist 0],$evv(DUR))]
	set end [expr $prm(1) + $vibdur]
	if {[expr $end - $stt] <= 0.02} {
		Inf "Sustain Is Too Short To Make A Local Vibrato File."
		return
	}
	set vfrq $prm(4)
	set vdep $prm(5)
	set f .locvib
	if [Dlg_Create $f "Local Vibrato" "set pr_locvib 0" -borderwidth $evv(BBDR)] {
		frame $f.0
		frame $f.1
		frame $f.2
		button $f.0.ok -text "OK" -command "set pr_locvib 1" -highlightbackground [option get . background {}]
		button $f.0.hh -text "Help" -command "VibLocHelp" -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.0.sv -text "Snd View" -command "SnackDisplay $evv(SN_SINGLETIME) vibloc $evv(TIME_OUT) 0" -bg $evv(SNCOLOR) -highlightbackground [option get . background {}]
		button $f.0.qu -text "Close" -command "set pr_locvib 0" -highlightbackground [option get . background {}]
		pack $f.0.ok $f.0.hh $f.0.sv -side left -padx 2
		pack $f.0.qu -side right
		label $f.1.ld -text "Randomise (0-1) Depth "
		entry $f.1.ed -textvariable vlocrandep -width 6 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		set vlocrandep 0.0
		label $f.1.lf -text "Frequency "
		entry $f.1.ef -textvariable vlocranfrq -width 6 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		set vlocranfrq 0.0
		pack $f.1.ld $f.1.ed $f.1.lf $f.1.ef -side left  
		label $f.2.ll -text "Generic Output Filename   "
		entry $f.2.e -textvariable viblocname -width 16
		pack $f.2.ll $f.2.e -side left
		pack $f.0 $f.1 $f.2 -side top -fill x -expand true -pady 2
		wm resizable $f 1 1
		bind $f <Right> {LocVibRandInc dep 0}
		bind $f <Left>  {LocVibRandInc dep 1}
		bind $f <Up>	{LocVibRandInc frq 0}
		bind $f <Down>	{LocVibRandInc frq 1}
		bind $f <Escape> {set pr_locvib 0}
		bind $f <Return> {set pr_locvib 1}
	}
	set viblocname [file rootname [file tail $fnam]]
	set finished 0
	set pr_locvib 0 
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_locvib
	while {!$finished} {
		tkwait variable pr_locvib
		if {$pr_locvib} {
			if {$vlocranfrq > 0.0} {
				if {![IsNumeric $prm(4)] || ($prm(4) <= $actvlo(4)) || ($prm(4) > $actvhi(4))} {
					set msg "Invalid Frequency Value On Parameters Page."
					continue
				}
			}
			if {[string length $viblocname] <= 0} {
				Inf "No Name Entered."
				continue
			}
			set viblocname [string tolower [file rootname [file tail $viblocname]]]
			if {![ValidCDPRootname $viblocname]} { 
				continue
			}
			set sname $viblocname
			set snamedep $sname
			append snamedep "_dep"
			append snamedep [GetTextfileExtension brk]
			if {[file exists $snamedep]} {
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] \
						-message "File exists: overwrite it ?"]
				if {$choice == "no"} {
					continue
				}
			}
			if {$vlocranfrq > 0.0} {
				set snamefrq $sname
				append snamefrq "_frq"
				append snamefrq [GetTextfileExtension brk]
				if {[file exists $snamefrq]} {
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] \
							-message "File exists: overwrite it ?"]
					if {$choice == "no"} {
						continue
					}
				}
			}
			if {[info exists viblocend]} {
				set extend [expr $viblocend - $prm(1)]
				set end [expr $end + $extend]
			}
			set line "0 0"
			lappend lines $line
			set line "$stt 0"
			lappend lines $line
			set line "[expr $stt + 0.01] $vdep"	
			lappend lines $line
			set viblocdur [expr $end - $stt]
			if {$vlocrandep > 0.0} {
				set steps [expr int(round($viblocdur * 2.0))]
				incr steps -1
				set k 0
				set thistime $stt
				while {$k < $steps} {
					set thistime [expr $thistime + 0.5]
					set thisval [expr (rand() * 2.0) - 1.0]
					set thisval [expr $thisval * $vlocrandep]
					if {$thisval > 0.0} {
						set thisval [expr ($thisval * $vdep) + $vdep]
					} else {
						set thisval [expr -$thisval]
						set thisval [expr $thisval * ($vdep/2.0)]
						set thisval [expr $vdep - $thisval]
					}
					set line "$thistime $thisval"	
					lappend lines $line
					incr k
				}
			}
			set line "[expr $end - 0.01] $vdep"	
			lappend lines $line
			set line "$end 0"	
			lappend lines $line
			set line "[expr $pa($fnam,$evv(DUR)) + $vibdur + 1.0] 0"	
			lappend lines $line

			if [catch {open $snamedep "w"} zit] {
				Inf "Cannot open file '$snamedep'"
				continue
			}
			foreach line $lines {
				puts $zit $line
			}
			close $zit
			FileToWkspace $snamedep 0 0 0 0 1
			set prm(5) $snamedep
			if {$vlocranfrq > 0.0} {
				catch {unset lines}
				set line "0 $vfrq"
				lappend lines $line
				set line "$stt $vfrq"
				lappend lines $line
				set steps [expr int(round($viblocdur * 2.0))]
				incr steps -1
				set k 0
				set thistime $stt
				while {$k < $steps} {
					set thistime [expr $thistime + 0.5]
					set thisval [expr (rand() * 2.0) - 1.0]
					set thisval [expr $thisval * $vlocranfrq]
					if {$thisval > 0.0} {
						set thisval [expr ($thisval * $vfrq) + $vfrq]
					} else {
						set thisval [expr -$thisval]
						set thisval [expr $thisval * ($vfrq/2.0)]
						set thisval [expr $vfrq - $thisval]
					}
					set line "$thistime $thisval"	
					lappend lines $line
					incr k
				}
				set line "$end $vfrq"	
				lappend lines $line
				set line "[expr $pa($fnam,$evv(DUR)) + $vibdur + 1.0] $vfrq"	
				lappend lines $line
				if [catch {open $snamefrq "w"} zit] {
					Inf "Cannot open file '$snamefrq'"
					continue
				}
				foreach line $lines {
					puts $zit $line
				}
				close $zit
				FileToWkspace $snamefrq 0 0 0 0 1
				set prm(4) $snamefrq
			}
			set finished 1
		} else {
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc LocVibRandInc {typ down} {
	global vlocrandep vlocranfrq
	if {$typ == "dep"} {
		if {$down} {
			if {$vlocrandep > 0.0} {
				set vlocrandep [DecPlaces [expr $vlocrandep - 0.1] 2]
			}
		} else {
			if {$vlocrandep < 1.0} {
				set vlocrandep [DecPlaces [expr $vlocrandep + 0.1] 2]
			}
		}
	} else {
		if {$down} {
			if {$vlocranfrq > 0.0} {
				set vlocranfrq [DecPlaces [expr $vlocranfrq - 0.1] 2]
			}
		} else {
			if {$vlocranfrq < 1.0} {
				set vlocranfrq [DecPlaces [expr $vlocranfrq + 0.1] 2]
			}
		}
	}
}

proc VibLocHelp {} {
	set msg "LOCALISED VIBRATO\n"
	append msg "\n"
	append msg "Apply vibrato only to the FOF-extended area of the sound.\n"
	append msg "\n"
	append msg "(1) If vibrato DEPTH is to be randomised,\n"
	append msg "put value for the AVERAGE depth in the\n"
	append msg "depth param value box on parameters page.\n"
	append msg "\n"
	append msg "(2) If vibrato FREQUENCY is to be randomised\n"
	append msg "put value for the AVERAGE frequency in the\n"
	append msg "freq paramvalue box on the parameters page.\n"
	append msg "\n"
	append msg "Max rand variation frq or depth =(average * 2).\n"
	append msg "Min rand variation frq or depth =(average / 2).\n"
	append msg "\n"
	append msg "(3) To change randomisation of vib DEPTH\n"
	append msg "use \"Left\" and \"Right\" arrows on keyboad.\n"
	append msg "\n"
	append msg "(4) To change randomisation of vib FREQUENCY\n"
	append msg "use \"Up\" and \"Down\" arrows on .\n"
	append msg "\n"
	append msg "(5) If vib extends past end of FOF extension,\n"
	append msg "mark the place where vibrato would end\n"
	append msg "in the input file, using \"Snd View\".\n"
	append msg "\n"
	Inf $msg
}

proc InvertFilt {} {
	global prm mmod pr_lphp wstk evv
	set thismode $mmod
	incr thismode -1
	set f .lphp
	set pr_lphp 0
	set callcentre [GetCentre [lindex $wstk end]]
	if [Dlg_Create $f "LPHP" "set pr_lphp 0" -borderwidth $evv(BBDR)] {
		frame $f.b
		frame $f.r
		button $f.b.quit -text "Close" -command "set pr_lphp 0" -highlightbackground [option get . background {}]
		pack $f.b.quit -side top
		label $f.r.0a -text ""
		radiobutton $f.r.1 -text "Lopass <--> Hipass" -variable pr_lphp -value 1
		label $f.r.1a -text ""
		radiobutton $f.r.2 -text "100 Hz Nudge UP     " -variable pr_lphp -value 2
		radiobutton $f.r.3 -text "100 Hz Nudge DOWN     " -variable pr_lphp -value 3
		label $f.r.3a -text ""
		radiobutton $f.r.4 -text "1000 Hz Nudge UP     " -variable pr_lphp -value 4
		radiobutton $f.r.5 -text "1000 Hz Nudge DOWN     " -variable pr_lphp -value 5
		pack $f.r.0a $f.r.1 $f.r.1a $f.r.2 $f.r.3 $f.r.3a $f.r.4 $f.r.5 -side top -anchor w
		pack $f.b -side top
		pack $f.r -side top -fill x -expand true
		bind $f <Escape> {set pr_lphp 0}
	}
	if {$thismode == 0} {	;# FRQ
		$f.r.2 config -text "100 Hz Nudge UP"
		$f.r.3 config -text "100 Hz Nudge DOWN"
		$f.r.4 config -text "1000 Hz Nudge UP"
		$f.r.5 config -text "1000 Hz Nudge DOWN"
	} else {	;# MIDI
		$f.r.2 config -text "Nudge a minor 3rd UP"
		$f.r.3 config -text "Nudge a minor 3rd DOWN"
		$f.r.4 config -text "Nudge an Octave UP"
		$f.r.5 config -text "Nudge an Octave DOWN"
	}
	raise $f
	update idletasks
	set geo [CentreOnCallingWindow $f $callcentre]
	My_Grab 0 $f pr_lphp
	wm geometry $f $geo
	tkwait variable pr_lphp
	switch -- $pr_lphp {
		1 {		;#	LP<>HP
			set temp $prm(1)
			set prm(1) $prm(2)
			set prm(2) $temp
		}
		2 {		;#	Up 100Hz or a m3
			if {$thismode == 0} {
				set prm(1) [expr $prm(1) + 100.0]
				set prm(2) [expr $prm(2) + 100.0]
			} else {
				set prm(1) [expr $prm(1) + 3.0]
				set prm(2) [expr $prm(2) + 3.0]
			}
		}
		3 {		;#	Down 100Hz or a m3
			if {$thismode == 0} {
				set prm(1) [expr $prm(1) - 100.0]
				set prm(2) [expr $prm(2) - 100.0]
			} else {
				set prm(1) [expr $prm(1) - 3.0]
				set prm(2) [expr $prm(2) - 3.0]
			}
		}
		4 {		;#	Up 1000Hz or an 8va
			if {$thismode == 0} {
				set prm(1) [expr $prm(1) + 1000.0]
				set prm(2) [expr $prm(2) + 1000.0]
			} else {
				set prm(1) [expr $prm(1) + 12.0]
				set prm(2) [expr $prm(2) + 12.0]
			}
		}
		5 {		;#	Down 1000Hz or an 8va
			if {$thismode == 0} {
				set prm(1) [expr $prm(1) - 1000.0]
				set prm(2) [expr $prm(2) - 1000.0]
			} else {
				set prm(1) [expr $prm(1) - 12.0]
				set prm(2) [expr $prm(2) - 12.0]
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc EndtimeToDur {} {
	global prm
	if {![IsNumeric $prm(0)] || ![IsNumeric $prm(1)]} {
		return
	}
	if {$prm(1) < $prm(0)} {
		return
	}
	set prm(0) [StripLeadingZeros $prm(0)]
	set prm(1) [StripLeadingZeros $prm(1)]
	set prm(1) [expr $prm(1) - $prm(0)]
}

proc DoFGain {gain} {
	global prm pprg mmod papag evv
	set thismode $mmod
	incr thismode -1
	if {$gain > 0} {
		switch -regexp -- $pprg \
			^$evv(EQ)$ {
				if {$thismode == 2} {
					set k 4
				} else {
					set k 3
				}
			} \
			^$evv(LPHP)$ {
				set k 4
			} \
			^$evv(FLTITER)$ - \
			^$evv(FLTBANKU)$ {
				set k 2
			} \
			^$evv(ALLPASS)$ {
				set k 3
			} \
			^$evv(FSTATVAR)$ - \
			^$evv(FLTBANKN)$ - \
			^$evv(FLTSWEEP)$ - \
			^$evv(FLTBANKU)$ {
				set k 1
			} \
			^$evv(FLTBANKV)$ - \
			^$evv(FLTBANKV2)$ {
				set k 2
			} \
			^$evv(SYNFILT)$ {
				set k 4
			}

		if {[IsNumeric $prm($k)]} {
			set prm($k) [expr $prm($k) * $gain]
		}
	}
	if {$pprg == $evv(FLTBANKV)} {
		$papag.parameters.output.editqik config -text "Randomise" -command ScatterFilter -bd 2 -state normal
	}
}

proc TopnTailResult {} {
	global papag chlist ins bulk pa evv
	
	if {$bulk(run)} {
		$papag.parameters.output.editqik config -text "Unknown" -bg $evv(EMPH) -state normal -command {}
		return
	}
	if {$ins(create)} {
		if {[info exists ins(chlist)] && ([llength $ins(chlist)] >= 1)} {
			set ch_list $ins(chlist)
			set outfname $evv(MACH_OUTFNAME)
		} 
 	} else {
		if {[info exists chlist] && ([llength $chlist] >= 1)} {
			set ch_list $chlist
			set outfname $evv(DFLT_OUTNAME)
		}
	}
	if {![info exists ch_list]} {
		return
	}
	set fnam [lindex $ch_list 0]
	if {![info exists pa($fnam,$evv(FTYP))] || ($pa($fnam,$evv(FTYP)) != $evv(SNDFILE))} {
		return
	}
	append outfname "0" $evv(SNDFILE_EXT)
	set indur $pa($fnam,$evv(DUR))
	if {![file exists $outfname] || ![info exists pa($outfname,$evv(DUR))]} {
		Inf "File Already Saved: Can't Calculate This Now"
		return
	}
	set outdur $pa($outfname,$evv(DUR))
	set cut [DecPlaces [expr $indur - $outdur] 3]
	$papag.parameters.output.editqik config -text "$cut secs" -bg $evv(EMPH) -state normal -command {}
}

proc SynthDurInFile {typ} {
	global prm pa evv
	switch -- $typ {
		"wave"  { set k 3}
		"noise" { set k 3}
		"spec"  { set k 1}
	}
	set val $prm($k)
	if {[IsNumeric $val]} {
		return
	}
	if {![info exists pa($val,$evv(DUR))]} {
		return
	}
	switch -- $typ {
		"wave"  { set k 2}
		"noise" { set k 2}
		"spec"  { set k 0}
	}
	set prm($k) $pa($val,$evv(DUR))
}

proc SetFilecntParam {} {
	global pprg prm evv infcnt
	if {(($pprg >= $evv(SIMPLE_TEX)) && ($pprg <= $evv(TMOTIFSIN))) || ($pprg == $evv(TEX_MCHAN))} {
		set prm(6) $infcnt
	}
}

proc IsReleaseFiveProg {pprg} {
	global evv grainversion
	if {$pprg == $evv(RRRR_EXTEND)} {
		if {$grainversion >= 8} {
			return 0
		} else {
			return 1
		}
	}
	if {($pprg <= $evv(TOP_OF_CDP)) && (($pprg < $evv(BOT_OF_PRIV)) || ($pprg > $evv(TOP_OF_PRIV))) \
	 && ($pprg != $evv(MCHSTEREO)) && ($pprg != $evv(SPECTOVF2)) && ($pprg != $evv(MTON)) && ($pprg != $evv(FLUTTER)) \
	 && ($pprg != $evv(SETHARES)) && ($pprg != $evv(MCHSHRED)) && ($pprg != $evv(MCHZIG)) && ($pprg != $evv(MCHITER))} {
		return 1
	}
	return 0
}

proc KeyRun {fprun} {
	global papag ppg_emph pr_runmsg ins bulk
	if {[string match [$fprun cget -state] "disabled"]} {
		return
	} elseif {[regexp {OK} [$fprun cget -text]]} {	;# The OK button on run window is present: quit run-window
		if {$ins(run) || $bulk(run)} {
			My_Release_to_Dialog .running
			Dlg_Dismiss .running
			destroy .running

		} else {
			RunOK
		}
		return
	} elseif {![regexp {Run} [$fprun cget -text]]} {
		return
	}
	if {[regexp {\.running} $fprun]} {	;# This is 'Run' button on the run-window; run the prog
		DoRun .running
	} else {							;# This is 'Run' button on the params-window; goto run-window
		RunProgram $papag.parameters
	}
}

proc SetGoodGate {} {
	global maxgrain_gatelevel evv prm pprg
	if {![info exists maxgrain_gatelevel]} {
		return
	}
	switch -regexp -- $pprg \
		^$evv(GRAIN_COUNT)$		- \
		^$evv(GRAIN_GET)$		- \
		^$evv(GRAIN_REVERSE)$ {
			set prm(1) $maxgrain_gatelevel
		} \
		^$evv(GRAIN_REORDER)$	-\
		^$evv(GRAIN_DUPLICATE)$	- \
		^$evv(GRAIN_REPITCH)$	- \
		^$evv(GRAIN_RERHYTHM)$	- \
		^$evv(GRAIN_REMOTIF)$	- \
		^$evv(GRAIN_TIMEWARP)$ {
			set prm(2) $maxgrain_gatelevel
		} \
		^$evv(GRAIN_OMIT)$		- \
		^$evv(GRAIN_POSITION)$ {
			set prm(3) $maxgrain_gatelevel
		} \
		^$evv(GRAIN_ALIGN)$	{
			set prm(1) $maxgrain_gatelevel
			set prm(3) $maxgrain_gatelevel
		}
}

proc Snackable {fnam} {
	global snack_enabled snack_stereo pa evv
	if {![info exists pa($fnam,$evv(FTYP))]} {
		return 0
	}
	if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
		return 0
	}
	if {$snack_enabled && ($snack_stereo || ($pa($fnam,$evv(CHANS)) == 1))} {
		return 1
	}
	return 0
}

proc SnackView {singlemark} {
	global fof_separator pprg mmod evv
	if {$singlemark} {
		switch -regexp -- $pprg \
			^$evv(GRAB)$ - \
			^$evv(MAGNIFY)$ - \
			^$evv(ENV_CURTAILING)$ - \
			^$evv(MORPH)$ - \
			^$evv(PSOW_CUT)$ - \
			^$evv(PSOW_EXTEND)$ - \
			^$evv(STACK)$ - \
			^$evv(PREFIXSIL)$ - \
			^$evv(BAKTOBAK)$ - \
			^$evv(ONEFORM_GET)$ - \
			^$evv(FIND_PANPOS)$ - \
			^$evv(SPLINTER)$ - \
			^$evv(PSOW_FREEZE)$ {
				SnackDisplay $evv(SN_SINGLETIME) $pprg $evv(TIME_OUT) 0
			} \
			^$evv(SPECMORPH)$  {
				if {$mmod != 7} {
					SnackDisplay $evv(SN_SINGLETIME) $pprg $evv(TIME_OUT) 0
				}
			} \
			^$evv(SPECMORPH2)$ {
				if {$mmod != 1} {
					SnackDisplay $evv(SN_SINGLETIME) $pprg $evv(TIME_OUT) 0
				}
			} \
			^$evv(RETIME)$ {
				if {($mmod == 8) || ($mmod == 14)} {
					SnackDisplay $evv(SN_SINGLETIME) $pprg $evv(TIME_OUT) 0
				}
			} \
			^$evv(EDIT_INSERT)$ {
				switch -- $mmod {
					1 { SnackDisplay $evv(SN_SINGLETIME) $pprg $evv(TIME_OUT) 0}
					2 { SnackDisplay $evv(SN_SINGLETIME) $pprg $evv(SMPS_OUT) 0}
					3 { SnackDisplay $evv(SN_SINGLETIME) $pprg $evv(GRPS_OUT) 0}
				}
			} \
			^$evv(FILT)$ {
				if {$mmod <= 6} {
					SnackDisplay $evv(SN_SINGLEFRQ) $pprg $evv(TIME_OUT) 0 ;# SINGLE FRQ OUTPUT
				}
			} \
			^$evv(SHRINK)$ {
				SnackDisplay $evv(SN_SINGLETIME) $pprg $evv(TIME_OUT) 0
			} \
			^$evv(WAVER)$ - \
			^$evv(PICK)$ - \
			^$evv(STRETCH)$ - \
			^$evv(GLIS)$ - \
			^$evv(SHIFTP)$ {
				SnackDisplay $evv(SN_SINGLEFRQ) $pprg evv(TIME_OUT) 0	;#	SINGLE FRQ OUTPUT
			} \
			^$evv(S_TRACE)$ {
				if {($mmod > 1) && ($mmod < 4)} {
					SnackDisplay $evv(SN_SINGLEFRQ) $pprg evv(TIME_OUT) 0	;#	SINGLE FRQ OUTPUT
				}
			}

	} else {
		switch -regexp -- $pprg \
			^$evv(EDIT_ZCUT)$	- \
			^$evv(EDIT_CUT)$	- \
			^$evv(EDIT_EXCISE)$	- \
			^$evv(EDIT_INSERTSIL)$ {
				switch -- $mmod {
					1 { SnackDisplay $evv(SN_TIMEPAIRS) $pprg $evv(TIME_OUT) 0}
					2 { SnackDisplay $evv(SN_TIMEPAIRS) $pprg $evv(SMPS_OUT) 0}
					3 { SnackDisplay $evv(SN_TIMEPAIRS) $pprg $evv(GRPS_OUT) 0}
				}
			} \
			^$evv(RRRR_EXTEND)$ {
				if {($mmod == 1) || ($mmod == 3)} {
					SnackDisplay $evv(SN_TIMEPAIRS) $pprg $evv(TIME_OUT) 0
				}
			} \
			^$evv(RETIME)$ {
				if {$mmod == 5} {
					SnackDisplay $evv(SN_TIMEPAIRS) $pprg $evv(TIME_OUT) 0
				}
			} \
			^$evv(MOD_PITCH)$ {
				if {$mmod == 5} {
					SnackDisplay $evv(SN_TIMEPAIRS) $pprg $evv(TIME_OUT) 0
				}
			} \
			^$evv(MOD_RADICAL)$ {
				if {$mmod == 3} {
					SnackDisplay $evv(SN_TIMEPAIRS) $pprg $evv(TIME_OUT) 0
				}
			} \
			^$evv(STRANS_MULTI)$ {
				if {$mmod == 3} {
					SnackDisplay $evv(SN_TIMEPAIRS) $pprg $evv(TIME_OUT) 0
				}
			} \
			^$evv(ZIGZAG)$ - \
			^$evv(MCHZIG)$ {
				if {$mmod == 1} {
					SnackDisplay $evv(SN_TIMEPAIRS) $pprg $evv(TIME_OUT) 0
				}
			} \
			^$evv(INFO_MAXSAMP2)$	- \
			^$evv(ENV_DOVETAILING)$	- \
			^$evv(EDIT_INSERT2)$	- \
			^$evv(ITERATE_EXTEND)$	- \
			^$evv(ENV_CURTAILING)$  - \
			^$evv(EXPDECAY)$		- \
			^$evv(BRIDGE)$			- \
			^$evv(HOVER2)$			- \
			^$evv(TOSTEREO)$		- \
			^$evv(LOOP)$			- \
			^$evv(SPECEX)$			- \
			^$evv(GREV_EXTEND)$ {
				SnackDisplay $evv(SN_TIMEPAIRS) $pprg $evv(TIME_OUT) 0
			} \
			^$evv(S_TRACE)$ {
				if {$mmod == 4} {
					SnackDisplay $evv(SN_FRQBAND) $pprg evv(TIME_OUT) 0	;#	FRQ BAND
				}
			} \
			^$evv(FILT)$ {
				if {$mmod > 6} {
					SnackDisplay $evv(SN_FRQBAND) $pprg $evv(TIME_OUT) 0	;# FRQ BAND
				}
			} \
			^$evv(FOFEX_CO)$ {
				if {[info exists fof_separator]} {
					switch -- $mmod {
						1 {SnackDisplay $evv(SN_SINGLETIME) fofex1 $evv(SMPS_OUT) 0}
						6 {SnackDisplay $evv(SN_UNSORTED_TIMES) fofex6 $evv(SMPS_OUT) 0}
						7 {SnackDisplay $evv(SN_UNSORTED_TIMES) fofex7 $evv(SMPS_OUT) 0}
						default {SnackDisplay 0 $evv(SN_FROM_PRMPAGE_NO_OUTPUT) $evv(TIME_OUT) 0}
					}
				} else {
					SnackDisplay 0 $evv(SN_FROM_PRMPAGE_NO_OUTPUT) $evv(TIME_OUT) 0
				}
			} \
			^$evv(SHRINK)$ {
					SnackDisplay 0 $evv(SN_FROM_PRMPAGE_NO_OUTPUT) $evv(TIME_OUT) 0
			} \
			default {
				SnackDisplay $evv(SN_FRQBAND) $pprg $evv(TIME_OUT) 0	;#	FRQ BAND
			}
	}
}

proc SnackRecolor {invlist on} {
	global papag evv
	if {([llength $invlist] == 1) && [Snackable [lindex $invlist 0]]} {
		if {$on} {
			$papag.parameters.output.editsrc config	-text "Snd View" -bg $evv(SNCOLOR)
		} else {
			$papag.parameters.output.editsrc config	-text "SView Only" -bg $evv(SNCOLOROFF)
		}
	} else {
		$papag.parameters.output.editsrc config	-text "View Src" -bg [option get . background {}]
	}
}

proc IsSingleMarkType {prog} {
	global mmod evv

	switch -regexp -- $prog \
		^$evv(FILT)$ {
			if {$mmod <= 6} {
				return 1
			}
		} \
		^$evv(S_TRACE)$ {
			if {($mmod > 1) && ($mmod < 4)} {
				return 1
			}
		} \
		^$evv(PSOW_CUT)$ - \
		^$evv(PSOW_FREEZE)$ - \
		^$evv(PREFIXSIL)$ - \
		^$evv(BAKTOBAK)$ - \
		^$evv(MORPH)$ - \
		^$evv(GRAB)$ - \
		^$evv(MAGNIFY)$ - \
		^$evv(WAVER)$ - \
		^$evv(PICK)$ - \
		^$evv(STRETCH)$ - \
		^$evv(GLIS)$ - \
		^$evv(EDIT_INSERT)$ - \
		^$evv(STACK)$ - \
		^$evv(SHIFTP)$ {
			return 1
		 } \
		^$evv(SHIFT)$ {
			if {($mmod == 2) || ($mmod == 3)} {
				return 1
			}
		 } \
		^$evv(SPECMORPH)$ {
			if {$mmod != 7} {
				return 1
			}
		} \
		^$evv(SPECMORPH2)$ {
			if {$mmod != 1} {
				return 1
			}
		} \
		^$evv(SHRINK)$ {
			if {$mmod == 4} {
				return 1
			}
		 }

	return 0
}

proc IsSingleEditType {prog} {
	global mmod evv

	switch -regexp -- $prog \
		^$evv(FILT)$ {
			if {$mmod > 6} {
				return 1
			}
		} \
		^$evv(S_TRACE)$ {
			if {$mmod == 4} {
				return 1
			}
		} \
		^$evv(SHIFT)$ {
			if {($mmod == 4) || ($mmod == 5)} {
				return 1
			}
		} \
		^$evv(RRRR_EXTEND)$ {
			if {($mmod == 1) || ($mmod == 3)} {
				return 1
			}
		} \
		^$evv(ZIGZAG)$ - \
		^$evv(MCHZIG)$ {
			if {$mmod == 1} {
				return 1
			}
		} \
		^$evv(EDIT_ZCUT)$	- \
		^$evv(EDIT_CUT)$	- \
		^$evv(EDIT_EXCISE)$	- \
		^$evv(EDIT_INSERTSIL)$ - \
		^$evv(EDIT_INSERT2)$ - \
		^$evv(BRIDGE)$ - \
		^$evv(FOCUS)$ - \
		^$evv(CHORD)$ - \
		^$evv(TRNSF)$ - \
		^$evv(TRNSP)$ - \
		^$evv(ARPE)$ - \
		^$evv(FOLD)$ - \
		^$evv(PITCH)$ - \
		^$evv(MULTRANS)$ - \
		^$evv(MEAN)$ - \
		^$evv(ITERATE_EXTEND)$ - \
		^$evv(SPECROSS)$  - \
		^$evv(TOSTEREO)$	- \
		^$evv(SPECEX)$	- \
		^$evv(GREV_EXTEND)$ {
			return 1
		 }

	return 0
}

proc SpaceBoxOrStarCommand {} {
	global pprg evv papag
	switch -regexp -- $pprg \
		^$evv(SYNTHESIZER)$ - \
		^$evv(NEWTEX)$ {
			$papag.help.star config -text "Space Type?" -bg $evv(EMPH) -command SpaceboxHelp
		} \
		default {
			$papag.help.star config -text "What Value?" -bg [option get . background {}] -command StarCommand
		}
}

proc StarCommand {} {
	set msg "To Test A Range Of Values For A Parameter:\n\n"
	append msg "Enter a  '*'   in (ONLY ONE) parameter box\n"
	append msg "and run the program in the normal way."
	Inf $msg
}

proc SpaceboxHelp {} {
	set msg "SPECIAL SPATIAL DISTRIBUTIONS FOR 8-CHANNEL FILES ONLY.\n"
	append msg "\n"
	append msg "1:  Left-Right Random ........ Alternate Left and Right sides, random positions.\n"
	append msg "2:  Front-Back Random ....... Alternate Front and back areas of space, random positions.\n"
	append msg "3:  Rotate ...................... Requires a positive or negative rotation speed in cycles per second.\n"            
	append msg "4:  Superspace1 ............... Single channel positions only.\n"
	append msg "5:  Superspace2 ............... Single channels and channel-pairs only.\n"
	append msg "6:  Superspace3 ............... Single channels, channel-pairs and triangles only.\n"
	append msg "7:  Superspace4 ............... Single channels, channel-pairs, triangles, square, diamond and all-on.\n"
	append msg "8:  Left-Right Alternate ....... Alternate Left and Right sides, using all channels of each side.\n"
	append msg "9:  Back-Front Alternate ...... Alternate Back and Front areas, using all channels of each area.\n"
	append msg "10: Frameswitch ............... Alternate Between Square and Diamond 4-sets.\n"
	append msg "11: TriangleA Rotate 1 ........ Rotate a triple of alternate channels, clockwise (e.g. 135 -> 246 -> 357...)\n"
	append msg "12: TriangleA AntiRotate 1 ... Rotate a triple of alternate channels, anticlockwise (e.g. 357 ->246 -> 135...)\n"
	append msg "13: TriangleB Rotate 2 ........ Rotate a channel and the pair opposite, clockwise (e.g. 146 -> 257 -> 368 ...)\n"
	append msg "14: TriangleB AntiRotate 2 ... Rotate a channel and the pair opposite, anticlockwise (e.g. 368 -> 257 -> 146 ...)\n"
	Inf $msg
}

proc MergeMultiEditData {} {
	global prm pr_mergedit mergeditname wstk evv
	set filename $prm(0)
	if {([string length $filename] <= 0) || [string match $filename "filename"]} {
		Inf "No edit data (parameter 1) to merge"
		return
	}
	if [catch {open $prm(0) "r"} zit] {
		Inf "Cannot open datafile '$prm(0)'"
		return
	}
	set datcnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
#FEB 2022
        if {[string length $line] <= 0} {
			continue
		} elseif {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend nuvals $item
				incr datcnt
			}
		}
	}
	if {![info exists nuvals]} {
		Inf "No data in datafile '$prm(0)'"
		return
	}
	if {![IsEven $datcnt]} {
		Inf "Data not paired correctly in datafile '$prm(0)'"
		return
	}
	set n 0
	while {$n < [expr $datcnt - 2]}  {
		set nplusone [expr $n + 1]
		set lastval1 [lindex $nuvals $n]
		set lastval2 [lindex $nuvals $nplusone]
		set m $n
		incr m 2	
		while {$m < $datcnt} {
			set mplusone [expr $m + 1]
			set val1 [lindex $nuvals $m]
			set val2 [lindex $nuvals $mplusone]
			if {$val1 < $lastval1} {
				set nuvals [lreplace $nuvals $n $n $val1]
				set nuvals [lreplace $nuvals $nplusone $nplusone $val2]
				set nuvals [lreplace $nuvals $m $m $lastval1]
				set nuvals [lreplace $nuvals $mplusone $mplusone $lastval2]
				set lastval1 $val1
				set lastval2 $val2
			}
			incr m 2
		}
		incr n 2
	}
	if {[lindex $nuvals 0] >= [lindex $nuvals 1]} {
		Inf "Pair of values not in order ([lindex $nuvals 0] [lindex $nuvals 1]) in datafile '$prm(0)'"
		return
	}
	set outvals [lrange $nuvals 0 1]
	set lastval1 [lindex $outvals 0]
	set lastval2 [lindex $outvals 1]
	foreach {val1 val2} [lrange $nuvals 2 end] {
		if {$val1 >= $val2} {
			Inf "Pair of values not in order ($val1 $val2) in datafile '$prm(0)'"
			return
		}
		if {$lastval2 < $val1} {
			lappend outvals $val1 $val2
		} elseif {$lastval2 >= $val2} {
			;												 #	Item absorbed within previous item, already in outtable
		} elseif {$lastval2 >= $val1} {
			set outvals [lreplace $outvals end end $val2]	;#	Previous time-segment in outtable is extended
		}
		set cnt [expr [llength $outvals] - 2]
		set lastval1 [lindex $outvals $cnt]
		incr cnt
		set lastval2 [lindex $outvals $cnt]
	}
	set f .mergedit
	if [Dlg_Create $f "Merged Data Filename" "set pr_mergedit 0" -borderwidth $evv(BBDR)] {
		set b [frame $f.b -borderwidth $evv(SBDR)]
		set r [frame $f.r -borderwidth $evv(SBDR)]
		button $b.ok -text "OK" -command "set pr_mergedit 1" -highlightbackground [option get . background {}]
		button $b.quit -text "Quit" -command "set pr_mergedit 0" -highlightbackground [option get . background {}]
		pack $b.ok -side left
		pack $b.quit -side right
		pack $b -side top -fill x -expand true
		label $r.lab -text "New Filename  "
		entry $r.e -textvariable mergeditname -width 32
		pack $r.lab $r.e -side left -padx 2
		pack $r -side top -pady 2
		wm resizable $f 1 1
		bind $f <Escape> {set pr_mergedit 0}
		bind $f <Return> {set pr_mergedit 1}
	}
	set origname [file rootname $prm(0)]
	set mergeditname $origname
	set pr_mergedit 0	
	set finished 0
	My_Grab 0 $f pr_mergedit $f.r.e
	while {!$finished} {
		tkwait variable pr_mergedit
	 	if {$pr_mergedit} {
			if {![ValidCDPRootname $mergeditname]} {
				continue
			}
			set mergeditname [string tolower $mergeditname]
			if {[string match $mergeditname $origname]} {
				set msg "Overwrite the original file ??"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if [string match no $choice] {
					continue
				}
			} elseif {[file exists $mergeditname$evv(TEXT_EXT)]} {
				set msg "File already exists: Overwrite it ??"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if [string match no $choice] {
					continue
				}
			}
			set outfnam $mergeditname$evv(TEXT_EXT)
			if [catch {open $outfnam "w"} zit] {
				Inf "Cannot open file '$outfnam' to write new data"
				continue
			}
			foreach {val1 val2} $outvals {
				set line $val1
				append line " " $val2
				puts $zit $line
			}
			close $zit
			FileToWkspace $outfnam 0 0 0 0 1 
			set prm(0) $outfnam
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc PseudoProg {prog_no} {
	global prg evv
	switch -regexp -- $prog_no \
		^$evv(SLICE)$ { 
			set true_prog $evv(EDIT_CUTMANY) 
		} \
		^$evv(SNIP)$ { 
			set true_prog $evv(MANYSIL)
		} \
		^$evv(ENV_CONTOUR)$ { 
			set true_prog $evv(MOD_LOUDNESS)
		} \
		^$evv(ELASTIC)$ { 
			set true_prog $evv(TSTRETCH)
		} \
		^$evv(PAD)$ { 
			set true_prog $evv(SILEND)
		}

	return $true_prog
}

proc SliderFix {} {
	Inf "Release Slider"
}

proc QuittingProcessWithNoSave {} {
	global sl_real is_terminating ins_creation ins_concluding prg_ocnt has_saved has_saved_at_all has_played has_viewed has_read evv
	global mchengineer
	if {[info exists mchengineer]} {
		return 0
	}
	foreach fnam [glob -nocomplain [file join $evv(DFLT_OUTNAME) *]] {
		lappend outfnams $fnam
	}
	foreach fnam [glob -nocomplain [file join $evv(MACH_OUTFNAME) *]] {
		lappend outfnams $fnam
	}
	if {![info exists outfnams]} {
		return 0
	}
	if {$sl_real && !$is_terminating && (!$ins_creation || $ins_concluding) && $prg_ocnt > 0 \
	&& (![info exists has_saved] || !$has_saved) \
	&& (![info exists has_saved_at_all] || !$has_saved_at_all) \
	&& (![info exists has_played] || !$has_played) \
	&& (![info exists has_viewed] || !$has_viewed) \
	&& (![info exists has_read] || !$has_read)} {
		return 1
	}
	return 0
}

#--- Does process involve time-stretching ?

proc IsTimeStretchingProcess {ppprg mmmod} {
	global evv
	switch -regexp -- $ppprg \
		^$evv(TSTRETCH)$ {
			if {$mmmod == 1} {
				return $ppprg
			}		
		} \
		^$evv(BRASSAGE)$ {
			if {$mmmod == 2} {
				return $ppprg
			}		
		}

	return 0
}

#------- Rename output files with names of input files (only called if they have a different extension)

proc DoSameNames {} {
	global evv last_outfile chlist new_cdp_extensions hst last_outfile wl wksp_cnt total_wksp_cnt wkspace_newfile rememd
	global ww prg_ocnt has_saved has_saved_at_all papag ins pprg mmod

	set j [string length $evv(MACH_OUTFNAME)]

	set namegroup $evv(MACH_OUTFNAME)				;#	Collects outputs from ALL bulk-processes
	append namegroup "*"
	catch {set remem_last_outfile $last_outfile}
	catch {unset last_outfile}
	set pitch_reproducing 0
	if {!$ins(create) && [PitchReproducing $pprg $mmod]} {
		set pitch_reproducing 1
	}
	set j [string length $evv(MACH_OUTFNAME)]

	foreach fnam [lsort -dictionary [glob -nocomplain $namegroup]] {
		set thisrootname [file rootname [file tail $fnam]]
		set k [string last "_" $thisrootname]
		incr k -1
		set no [string range $thisrootname $j $k]
		set srcname [lindex $chlist $no]
		set newname [file rootname [file tail $srcname]]
		if {$new_cdp_extensions} {
			set extname [GetFileExtension $fnam]
		}
		append newname $extname
		if {[file exists $newname]} {
			Inf "FILE '$newname' Already Exists: You Cannot Overwrite It Here"
			if {![info exists last_outfile]} {
				catch {set last_outfile $remem_last_outfile}
			}
			return 0
		}
	}
	foreach fnam [lsort -dictionary [glob -nocomplain $namegroup]] {
		set thisrootname [file rootname [file tail $fnam]]
		set k [string last "_" $thisrootname]
		incr k -1
		set no [string range $thisrootname $j $k]
		set srcname [lindex $chlist $no]
		set newname [file rootname [file tail $srcname]]
		if {$new_cdp_extensions} {
			set extname [GetFileExtension $fnam]
		}
		append newname $extname
		if [catch {file rename -force $fnam $newname}] {
			ErrShow "Cannot rename file\nIt may be open for PLAY, READ or VIEW\nClose it, to proceed."
			if {![info exists last_outfile]} {
				catch {set last_outfile $remem_last_outfile}
			}
		}
		if {$pitch_reproducing} {
			if [HasPmark $srcname] {
				CopyPmark $srcname $newname
			}
			if [HasMmark $srcname] {
				CopyMmark $srcname $newname
			}
		}
		set a $fnam
		append a "->"
		append a $newname
		lappend hst(bulkout) $a
		incr hst(bulkoutcnt)

		RenameProps $fnam $newname 0						;#	Rename properties
		if {[UpdateIfAMix $newname 0]} {
			set save_mixmanage 1
		}
		GenerateSrcListBulk $newname $srcname
		lappend genfiles $newname
		lappend last_outfile $newname
	}
	if {[info exists genfiles]} {
		set genfiles [ReverseList $genfiles]
		foreach newname $genfiles {
			$wl insert 0 $newname								;#	Add to start of workspace
			incr wksp_cnt
			incr total_wksp_cnt
		}
		set wkspace_newfile 1
		catch {unset rememd}
		if {[info exists save_mixmanage]} {
			MixMStore
		}
	}
	ForceVal $ww.1.a.endd.l.cnts.new $wksp_cnt
	ForceVal $ww.1.a.endd.l.cnts.all $total_wksp_cnt
	ReMarkWkspaceCount
	set prg_ocnt 0
	set has_saved 1
	set has_saved_at_all 1
	if {!$ins(run)} {
		$papag.parameters.zzz.mabo config -state normal
	}
	return 1
}

proc MixingBackup {} {
	global origmixbak chlist evv
	set fnam [lindex $chlist 0]
	set origmixbak $evv(DFLT_OUTNAME)
	append origmixbak "000" $evv(TEXT_EXT)
	if [catch {file copy $fnam $origmixbak} zat] {
		Inf "Cannot Make Backup Copy Of Mix, For Possible Restoration."
	}
}

proc IsMixProcess {} {
	global pprg evv
	switch -regexp -- $pprg \
		^$evv(MIX)$			- \
		^$evv(MIXMAX)$		- \
		^$evv(MIXGAIN)$		- \
		^$evv(MIXSHUFL)$	- \
		^$evv(MIXSYNC)$		- \
		^$evv(MIXSYNCATT)$	- \
		^$evv(MIXTWARP)$	- \
		^$evv(MIXSWARP)$	- \
		^$evv(MIXMULTI)$ {
			return 1
		}

	return 0
}

#---- Is this a mixing process acting on a defined main_mix ??

proc MainMix {} {
	global main_mix chlist
	if {[IsMixProcess] && [info exists main_mix] && [string match [lindex $chlist 0] $main_mix(fnam)]} {
		return 1
	}
	return 0
}

proc GetNewProcess {repost} {
	global onpage_oneatatime pr3 do_repost qikmixset bulksplit articvw

	catch {file delete $articvw}
	if {[info exists bulksplit]} {		;#	Force exit from multichan-bulkprocess-of-individ-chans
		GetNewFilesFromPpg				;#	And return directly to workspace
		return
	}
 	catch {unset onpage_oneatatime}
	catch {unset qikmixset}
	PurgeTempThumbnails
	set pr3 0
	if {$repost} {
		set do_repost 1
	} else {
		catch {unset do_repost}
	}
}

#---- Get MM in data file to MM parameter on params page, for retime-mode2

proc GetInMM {} {
	global prm idealtag chlist wl evv
	set gotit 0
	set infnam $prm(0)
	if {([string length $infnam] <= 0) || ![file exists $infnam]} {
		if {[info exists idealtag]} {
			set fnam [file rootname [file tail [lindex $chlist 0]]]
			append fnam "_" $idealtag
			foreach wlfnam [$wl get 0 end] {
				if {[string match [file extension $wlfnam] $evv(TEXT_EXT)]} {
					if {[string match $fnam [file rootname [file tail $wlfnam]]]} {
						set prm(0) $wlfnam
						set gotit 1
						break
					}
				}
			}
		}
		if {!$gotit} {
			if {[string length $infnam] <= 0} {
				Inf "Cannot Get Input MM: No Input Data File Entered Yet"
				return
			} else {
				Inf "Cannot Get Input MM: '$infnam' Is Not On The Workspace"
				return
			}
		}
	}
	set fnam $prm(0)
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open Data File '$fnam'"
		return
	}
	set gotit 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
#FEB 2022
		if {[string length $line] <= 0} {
			continue
		} elseif {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		foreach item $line	{
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			set inmm $item
			set gotit 1
			break
		}
		if {$gotit} {
			break
		}
	}
	close $zit
	if {!$gotit} {
		Inf "No Data Found In File '$fnam'"
		return
	}
	if {![IsNumeric $inmm] || ($inmm <= 0.0)} {
		Inf "Invalid Data ($inmm) Found In File '$fnam'"
		return
	}
	set prm(1) $inmm
}

#---- Keyboard Shortcut to QikEdit

proc DirectToQikEdit {} {
	global ins chlist pa evv
	if {$ins(run)} {
		if {![info exist ins(chlist)]} {
			return
		}
		set fnam [lindex $ins(chlist) 0]
	} else {
		if {![info exist chlist]} {
			return
		}
		set fnam [lindex $chlist 0]
	}
	if {[IsAMixfileIncludingMultichan $pa($fnam,$evv(FTYP))]} {
		EditSrcMixfile mix0
	}
}

#---- CDP internal player missing

proc NoNativePlayer {} {
	Inf "The CDP Internal Play-Program \"pvplay\" Is Not On Your System.\nCannot Play This Type Of File."
}

#---- Generate file to make mono input to mchanpan rotate around space

proc MchanpanRotate {} {
	global pr_mchrot mchrotname mchrotstt mchrotstp mchrotcps prm pa chlist evv

	set f .mchrot
	set endtime $pa([lindex $chlist 0],$evv(DUR))
	set outchans $prm(1)
	if {![regexp {^[0-9]+$} $outchans] || ![IsNumeric $outchans] || ($outchans < 3) || ($outchans > 16)} {
		Inf "Invalid Outchannel Count In Parameters"
		return
	}
	if [Dlg_Create $f "ROTATE MONO SRC" "set pr_mchrot 0" -borderwidth $evv(BBDR)] {
		set b [frame $f.b -borderwidth $evv(SBDR)]
		set p [frame $f.p -borderwidth $evv(SBDR)]
		set r [frame $f.r -borderwidth $evv(SBDR)]
		button $b.ok -text "OK" -command "set pr_mchrot 1" -highlightbackground [option get . background {}]
		button $b.quit -text "Quit" -command "set pr_mchrot 0" -highlightbackground [option get . background {}]
		pack $b.ok -side left
		pack $b.quit -side right
		pack $b -side top -fill x -expand true
		label $p.stl -text "Start Time "
		entry $p.stt -textvariable mchrotstt -width 6
		label $p.spl -text "Start Position "
		entry $p.stp -textvariable mchrotstp -width 6
		label $p.cpl -text "Cycles per sec (-ve vals anticlock) "
		entry $p.cps -textvariable mchrotcps -width 6
		pack $p.stl $p.stt $p.spl $p.stp $p.cpl $p.cps -side left -padx 2
		pack $p -side top -fill x -expand true
		label $r.lab -text "Output Filename  "
		entry $r.e -textvariable mchrotname -width 32
		pack $r.lab $r.e -side left -padx 2
		pack $r -side top -pady 2
		wm resizable $f 1 1
		bind $f <Escape> {set pr_mchrot 0}
		bind $f <Return> {set pr_mchrot 1}
	}
	set mchrotclok 0
	set mchrotstt 0.0
	set mchrotstp 1
	set mchrotcps ""
	set mchrotname ""
	set pr_mchrot 0	
	set finished 0
	My_Grab 0 $f pr_mchrot $f.r.e
	while {!$finished} {
		tkwait variable pr_mchrot
	 	if {$pr_mchrot} {
			if {[string length $mchrotname] <= 0} {
				Inf "No Output Filename Entered"
				continue
			}
			set outname [string tolower $mchrotname]
			if {![ValidCDPRootname $outname]} {
				continue
			}
			append outname $evv(TEXT_EXT)
			if {![IsNumeric $mchrotstt] || ($mchrotstt < 0.0)} {
				Inf "Invalid Rotation Start Time"
				continue
			}
			if {$mchrotstt >= $endtime} {
				Inf "Rotation Starts Beyond End Of Input File"
				continue
			}
			if {![regexp {^[0-9]+$} $mchrotstp] || ![IsNumeric $mchrotstp] || ($mchrotstp < 1) || ($mchrotstp > $outchans)} {
				Inf "Invalid Rotation Start Position (range 1 to $outchans)"
				continue
			}
			if {![IsNumeric $mchrotcps] || [Flteq $mchrotcps 0.0]} {
				Inf "Invalid Rotation Speed"
				continue
			}
			set speed [expr abs($mchrotcps)]
			if {$mchrotcps < 0} {
				set rot -1
			} else {
				set rot 1
			}
			catch {unset outlines}
			if {$mchrotstt > 0.0} {				;#	CREATE STATIONARY POINT FOR ROTATIONS NOT STARTING AT 0
				set line 0.0
				lappend line $mchrotstp $rot
				lappend outlines $line
			}
			if {$rot > 0} {
				set firstpartrot [expr double($outchans - $mchrotstp)/double($outchans)]
				set endpos $outchans
				set sttpos 1
			} else {
				set firstpartrot [expr double($mchrotstp - 1)/double($outchans)]
				set endpos 1
				set sttpos $outchans
			}
			set firstpartrot [expr $firstpartrot/$speed]
			set chanskip [expr 1.0/double($speed * $outchans)] 
			set nlessonechanskip [expr $chanskip * ($outchans - 1)] 

			set thistime $mchrotstt				;#	CREATE INITIAL POINT OF ROTATION
			set line $thistime
			lappend line $mchrotstp $rot
			lappend outlines $line
			if {![Flteq $firstpartrot 0.0]} {	;#	ADVANCE TO ENDPOS OF FIRST ROTATION
				set thistime [expr $thistime + $firstpartrot]
				set line $thistime
				lappend line $endpos $rot
				lappend outlines $line
			}
			while {$thistime < $endtime} {
				set thistime [expr $thistime + $chanskip]	;#	(for N-chans) Skip from N to 1 (or 1 to N for anticlok)
				set line $thistime
				lappend line $sttpos $rot
				lappend outlines $line
				set thistime [expr $thistime + $nlessonechanskip]	;#	Move round all channels except final skip N->1 (or N->1)
				set line $thistime
				lappend line $endpos $rot
				lappend outlines $line
			}
			if [catch {open $outname "w"} zit] {
				Inf "Cannot Open File '$outfnam' To Write Data"
				continue
			}
			foreach line $outlines {
				puts $zit $line
			}
			close $zit
			FileToWkspace $outname 0 0 0 0 1
			set prm(0) $outname
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#------	Scale Values inside an envelope file

proc ScaleEnvelope {} {
	global prm pr_envscale envscale_scale envscale_fnam evnscalecap actvhi pa evv wstk wl last_outfile

	if {([string length $prm(0)] <= 0) || ![file exists $prm(0)]} {
		Inf "No Evelope Filename Entered: Cannot Scale Envelope"
		return
	}
	set fnam $prm(0)
	if {![info exists pa($fnam,$evv(FTYP))]} {
		Inf "File '$fnam' Is Not On The Workspace: Cannot Scale Envelope"
		return
	}
	set ftyp $pa($fnam,$evv(FTYP))
	if {![IsABrkfile $ftyp]} {
		Inf "File '$fnam' Is Not A Breakpoint File: Cannot Scale Envelope"
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File '$fnam' To Scale Envelope"
		return
	}
	set maxbrk -1
	set minbrk 100000
	set maxnum -100000
	set minnum 100000
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
#FEB 2022
		if {[string length $line] <= 0} {
			continue
		} elseif {[string match [string index $line 0] ";"]} {
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
					lappend times $item
				}
				1 {
					lappend vals $item
					if {$item > $maxbrk} {
						set maxbrk $item
					}
					if {$item < $minbrk} {
						set minbrk $item
					}
				}
			}
			if {$item > $maxnum} {
				set maxnum $item
			}
			if {$item < $minnum} {
				set minnum $item
			}
			incr cnt
		}
		if {$cnt != 2} {
			Inf "Invalid Data In File '$fnam'"
			close $zit
			return
		}
	}
	close $zit
	if {$minnum < 0.0} {
		Inf "'$fnam' Is Not A Valid Envelope Data File"
		return
	}
	if {$maxbrk > $actvhi(0)} {
		Inf "'$fnam' Contains Values Outside The Range Specified"
		return
	}

	set f .envscale
	if [Dlg_Create $f "SCALE ENVELOPE" "set pr_envscale 0" -borderwidth $evv(BBDR)] {
		set b [frame $f.b -borderwidth $evv(SBDR)]
		set p [frame $f.p -borderwidth $evv(SBDR)]
		set q [frame $f.q -borderwidth $evv(SBDR)]
		set n [frame $f.n -borderwidth $evv(SBDR)]
		button $b.ok -text "OK" -command "set pr_envscale 1" -highlightbackground [option get . background {}]
		button $b.quit -text "Quit" -command "set pr_envscale 0" -highlightbackground [option get . background {}]
		pack $b.ok -side left
		pack $b.quit -side right
		pack $b -side top -fill x -expand true
		label $p.sfl -text "Scale Factor "
		entry $p.sfe -textvariable envscale_scale -width 20
		pack $p.sfe $p.sfl -side left -padx 2
		pack $p -side top -fill x -expand true
		checkbutton $q.only -variable evnscalecap -text "Retain maxlevel"
		pack $q.only -side left -padx 2
		pack $q -side top -fill x -expand true
		label $n.sfl -text "New Filename "
		entry $n.sfe -textvariable envscale_fnam -width 20
		pack $n.sfe $n.sfl -side left -padx 2
		pack $n -side top -fill x -expand true
		set envscale_scale ""
		wm resizable $f 1 1
		bind .envscale.n.sfe  <Up> "AdvanceNameIndex 1 envscale_fnam 0"
		bind .envscale.n.sfe  <Down> "AdvanceNameIndex 0 envscale_fnam 0"
		bind .envscale.n.sfe  <Control-Up> "AdvanceNameIndex 1 envscale_fnam 1"
		bind .envscale.n.sfe  <Control-Down> "AdvanceNameIndex 0 envscale_fnam 1"
		bind $f <Escape> {set pr_envscale 0}
		bind $f <Return> {set pr_envscale 1}
	}
	set envscale_fnam [file rootname [file tail $fnam]]
	set pr_envscale 0	
	set finished 0
	My_Grab 0 $f pr_envscale $f.p.sfe
	while {!$finished} {
		tkwait variable pr_envscale
	 	if {$pr_envscale} {
			if {[string length $envscale_fnam] <= 0} {
				Inf "No Output Filename Entered"
				continue
			}
			set outfnam [string tolower $envscale_fnam]
			if {![ValidCDPRootname $outfnam]} {
				continue
			}
			append outfnam [GetTextfileExtension brk]
			set overwrite 0
			if {[string match $outfnam $fnam]} {
				set msg "Overwrite Input Data File ??"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if [string match no $choice] {
					continue
				}
				set overwrite 1
			} else {
				if {[file exists $outfnam]} {
					Inf "File '$outfnam' Already Exists: Please Choose A Different Name"
					continue
				}
			}
			if {([string length $envscale_scale] <= 0) || ![IsNumeric $envscale_scale] || ($envscale_scale <= 0.0)} {
				Inf "Invalid Scale Factor"
				continue
			}
			catch {unset nuvals}
			set OK 1
			if {$evnscalecap} {
				if {$envscale_scale > 1.0} {
					set msg "As Scalefactor Is > 1.0, The Maxima Will Be Effectively Lowered: OK ??"
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
					if [string match no $choice] {
						continue
					}
				}
				set max_val 0.0
				foreach val $vals {
					if {$val > $max_val} {
						set max_val $val
					}
				}
				foreach val $vals {
					if {[Flteq $val $max_val]} {
						set nuval $val
					} else {
						set nuval [expr $val * $envscale_scale]
					}
					if {$nuval > $actvhi(0)} {
						Inf "This Scale Factor Generates Envelope Values Outside The Range Specified"
						set OK 0
						break
					}
					lappend nuvals $nuval
				}
			} else {
				foreach val $vals {
					set nuval [expr $val * $envscale_scale]
					if {$nuval > $actvhi(0)} {
						Inf "This Scale Factor Generates Envelope Values Outside The Range Specified"
						set OK 0
						break
					}
					lappend nuvals $nuval
				}
			}
			if {!$OK} {
				continue
			}
			if {$overwrite} {
				if [DeleteFileFromSystem $fnam 0 1] {
					DummyHistory $fnam "DESTROYED"
				} else {
					Inf "Cannot Delete Existing Data File '$fnam'"
					continue
				}
				set j [LstIndx $fnam $wl]
				if {$j >= 0} {	
					WkspCnt [$wl get $j] -1
					$wl delete $j
				}
			}
			if [catch {open $outfnam "w"} zit] {
				Inf "Cannot Open File '$outfnam' To Write The Scaled Values"
				continue
			}
			foreach time $times val $nuvals {
				set line [list $time $val]
				puts $zit $line
			}
			close $zit
			if {[FileToWkspace $outfnam 0 0 0 0 1] > 0} {
				set last_outfile $outfnam
			}
			set prm(0) $outfnam
			Inf "Envelope Scaled"
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#------ When "Snd View" used for anal files, the anal file is 1 anal window shifted in time:
#------ but the display, based on the src soundfile is not shifted.
#------ so output values in any generated breakpoint file need to be shifted 1-anal-window in time.

proc ShuffleBrk {} {
	global prm evv pa wstk chlist ins
	if {([string length $prm(0)] <= 0) || ([IsNumeric $prm(0)])} {
		Inf "Time Stretch Parameter Is Not A Breakpoint File"
		return
	}
	set fnam $prm(0)
	if {![file exists $fnam] || ![info exists pa($fnam,$evv(FTYP))] || ![IsABrkfile $pa($fnam,$evv(FTYP))]} {
		Inf "Time Stretch Parameter Is Not An Existing Breakpoint File"
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File '$fnam' To Read Original Times"
		return
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
#FEB 2022
		if {[string length $line] <= 0} {
			continue
		} elseif {[string match [string index $line 0] ";"]} {
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
				if {$item > 0} {
					set item [expr $item + 0.01]
				}
				set nuline $item
			} else {
				lappend nuline $item
			}
			incr cnt
		}
		lappend nulines $nuline
	}
	close $zit
	if [catch {open $fnam "w"} zit] {
		Inf "Cannot Reopen File '$fnam' To Write New Times"
		return
	}
	foreach line $nulines {
		puts $zit $line
	}
	close $zit
}

proc IsBasicMixProcess {} {
	global pprg evv
	if {(($pprg == $evv(MIX)) || $pprg == $evv(MIXMULTI))} {
		return 1
	}
	return 0
}

#----- For PSOW EXTEND: If there is an envelope isolating event in sound, this can be modified here.

proc Articulate {} {
	global pa evv prm wstk chlist tv_active invlist stitchtime articstitchtime
	global pr_artic articv evlev fnamartic articv_store readonlyfg readonlybg
	global prearticlines artic_event articvw articorigdata artic_gg articglob stitchratio

	set stitchtime 0.0
	catch {unset stitchratio}
	set articvw "__"
	append articvw $evv(DFLT_OUTNAME) "000" $evv(SNDFILE_EXT)
	set outvw $evv(DFLT_OUTNAME)
	append outvw "0" $evv(SNDFILE_EXT)

	if {![info exists articorigdata]} {
		set articorigdata $prm(7)
	}
	if {[IsNumeric $articorigdata] || ![file exists $articorigdata] \
	|| ![info exists pa($articorigdata,$evv(FTYP))] || ![IsANormdBrkfile $pa($articorigdata,$evv(TYP))]} {
		set msg "No Unarticulated Envelope File Exists."
		if {$tv_active} {
			append msg "\n\nGenerate This From MIDI-Key When Defining Transposition Line."
		}
		unset articorigdata
		Inf $msg
		return
	}
	if [catch {open $articorigdata "r"} zit] {
		Inf "Cannot Open File '$articorigdata'"
		return
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
#FEB 2022
		if {[string length $line] <= 0} {
			continue
		} elseif {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		catch {unset nuline}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			lappend nuline $item
		}
		lappend lines $nuline
	}
	close $zit
	set cnt -1
	set inevent 0
	set prearticlines $lines
	foreach line $lines {
		set time [lindex $line 0]
		set val  [lindex $line 1]
		if {$val > 0} {
			if {$inevent} {
				set artic_event($cnt) [lreplace $artic_event($cnt) 1 1 $time]	;#	Record event end
				if {$val > $evlev($cnt)} {
					set evlev($cnt) $val
				}
			} else {
				incr cnt
				set artic_event($cnt) [list $time $time]						;#	Set up zero-duration event at "time"
				set evlev($cnt) $val
				set inevent 1
			}
		} else {
			if {$inevent} {
				lappend artic_event($cnt) $time 0.0								;#	Record gap start, zero-duration
				set inevent 0
			} elseif {[info exists artic_event]} {
				set gap [expr $time - [lindex $artic_event($cnt) 2]]
				set artic_event($cnt) [lreplace $artic_event($cnt) 3 3 $gap]	;#	Record gap end
			}
		}
	}
	if {[info exists artic_event]} {
		if {[lindex $artic_event(0) 0] == 0.0} {									;#	If first event starts at zero
			set articv(zro,0) 1														;#	Remember this
			set stttime [lindex [lindex $lines 2] 0]								
			set lev0 [lindex [lindex $lines 2] 1]									;#	Check to see if it includes the pre-FOF part of the file
			set endtime [lindex [lindex $lines 3] 0]
			set lev1 [lindex [lindex $lines 3] 1]
			if {($lev0 > 0) && ($lev1 > 0)} {										;#	And if so,
				set artic_event(0) [lreplace $artic_event(0) 0 1 $stttime $endtime]	;#	force it to start within the extended FOF
				set evlev(0) $lev0													;#	and take the level of the first FOF extended event
			}
		} else {
			set articv(zro,0) 0
		}
		if {[llength $artic_event($cnt)] < 4} {										;#	If the final event is incomplete
			unset artic_event($cnt)													;#	Remove it
		} else {
			incr cnt
		}
		if {$cnt < 0} {
			unset artic_event
		}
	}
	if {![info exists artic_event]} {
		Inf "No Separable Events Found"
		return
	}
	set articv(cnt,0) $cnt
	if {[file exists $articvw]} {
		set invlist $articvw
	} elseif {[file exists $outvw]} {
		if {![catch {file copy $outvw $articvw} zit]} {
			set n 0
			while {$n < 12} {
				set pa($articvw,$n) $pa($outvw,$n)
				incr n
			}
			set invlist $articvw
		}
	} 
	if {![file exists $articvw]} {
		Inf "No Output File Yet : Will Display Input File with \"Snd View\""
		set invlist [lindex $chlist 0]
	}
	set f .artic
	if [Dlg_Create $f "Event Articulation" "set pr_artic 0" -borderwidth $evv(BBDR)] {
		frame $f.0
		frame $f.00 -bg $evv(POINT) -height 1
		frame $f.1
		frame $f.11 -bg $evv(POINT) -height 1
		frame $f.2
		frame $f.22 -bg $evv(POINT) -height 1
		frame $f.3
		button $f.0.ok -text "Articulate" -command "set pr_artic 1" -highlightbackground [option get . background {}]
		button $f.0.hh -text "Help" -command "ArticHelp 1" -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.0.sv -text "Snd View" -command "SnackDisplay $evv(SN_TIMESLIST) sn_artic $evv(TIME_OUT) $invlist" -bg $evv(SNCOLOR) -highlightbackground [option get . background {}]
		button $f.0.rp -text "Previous Vals" -command "ResetPreviousArtic" -highlightbackground [option get . background {}]
		SnackRecolor $invlist 0
		button $f.0.qu -text "Abandon" -command "set pr_artic 0" -highlightbackground [option get . background {}]
		pack $f.0.ok $f.0.hh $f.0.sv $f.0.rp -side left -padx 2
		pack $f.0.qu -side right
		pack $f.0 -side top -fill x -expand true -pady 2
		pack $f.00 -side top -pady 2 -fill x -expand true
		label $f.1.ll -text "Output filename"
		entry $f.1.e -textvariable fnamartic -width 24
		button $f.1.st -text "Stitch to end" -command "StitchToEnd" -highlightbackground [option get . background {}]
		label $f.1.ms -text "max stitchtime "
		entry $f.1.se -textvariable articstitchtime -width 4
		label $f.1.all -text "All Events: Artic "
		button $f.1.set   -text "On"  -command "SetAllArtics 1" -width 3 -highlightbackground [option get . background {}]
		button $f.1.clear -text "Off" -command "SetAllArtics 0" -width 3 -highlightbackground [option get . background {}]
		pack $f.1.ll $f.1.e $f.1.st $f.1.ms $f.1.se -side left -padx 2
		pack $f.1.clear $f.1.set $f.1.all -side right
		pack $f.1 -side top -pady 2 -fill x -expand true
		pack $f.11 -side top -pady 2 -fill x -expand true
		label $f.2.ggg -text "GLOBALS   " -fg $evv(SPECIAL)
		label $f.2.grl -text "risetime "
		entry $f.2.gre -textvariable articv(ris,0) -width 5 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		radiobutton $f.2.grr -text "set rise   | " -variable artic_gg -value 1 -command {ArticSetGlobal ris}
		label $f.2.gdl -text "decay "
		entry $f.2.gde -textvariable articv(dec,0) -width 5 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		radiobutton $f.2.gdd -text "set decay" -variable artic_gg -value 2 -command {ArticSetGlobal dec}
		button $f.2.mem -text "Save" -command "ArticGlobsStorage 1" -width 6 -highlightbackground [option get . background {}]
		button $f.2.unm -text "Recall"   -command "ArticGlobsStorage 0" -width 6 -highlightbackground [option get . background {}]
		pack $f.2.ggg $f.2.grl $f.2.gre $f.2.grr $f.2.gdl $f.2.gde $f.2.gdd $f.2.mem $f.2.unm -side left -pady 2
		pack $f.2 -side top -pady 2
		pack $f.22 -side top -pady 2 -fill x -expand true
		bind $f.2.gre <Up>	 "IncrArctic ris 0 0 0"
		bind $f.2.gre <Down> "IncrArctic ris 0 1 0"
		bind $f.2.gde <Up>   "IncrArctic dec 0 0 0"
		bind $f.2.gde <Down> "IncrArctic dec 0 1 0"
		bind $f.2.gre <Shift-Up>   "IncrArctic ris 0 0 1"
		bind $f.2.gre <Shift-Down> "IncrArctic ris 0 1 1"
		bind $f.2.gde <Shift-Up>   "IncrArctic dec 0 0 1"
		bind $f.2.gde <Shift-Down> "IncrArctic dec 0 1 1"
		set n 1
		set ecnt 1
		while {$n <= 5} {
			frame $f.3.$n
			set k 0
			while {$k <= 20} {
				if {$k == 0} {
					set z [expr $n + 1000]
					frame $f.3.$n.$z
					frame $f.3.$n.$z.00a -bg $evv(POINT) -height 1
					button $f.3.$n.$z.0 -text "Event number"	   -width 20 -bd 0 -command {} -highlightbackground [option get . background {}]
					frame $f.3.$n.$z.0a -bg $evv(POINT) -height 1
					button $f.3.$n.$z.1 -text "Articulation On"   -width 20 -bd 0 -command {} -highlightbackground [option get . background {}]
					frame $f.3.$n.$z.1a -bg $evv(POINT) -height 1
					button $f.3.$n.$z.2 -text "Decay to minimum of"	   -width 20 -bd 0 -command {} -highlightbackground [option get . background {}]
					frame $f.3.$n.$z.2a -bg $evv(POINT) -height 1
					button $f.3.$n.$z.3 -text "Min at time-fraction" -width 20 -bd 0 -command {} -highlightbackground [option get . background {}]
					frame $f.3.$n.$z.3a -bg $evv(POINT) -height 1
					button $f.3.$n.$z.4 -text "Sustain"		   -width 20 -bd 0 -command {} -highlightbackground [option get . background {}]
					frame $f.3.$n.$z.4a -bg $evv(POINT) -height 1
					button $f.3.$n.$z.5 -text "Slur"		   -width 20 -bd 0 -command {} -highlightbackground [option get . background {}]
					frame $f.3.$n.$z.5a -bg $evv(POINT) -height 1
					button $f.3.$n.$z.6 -text "Change Gain"	   -width 20 -bd 0 -command {} -highlightbackground [option get . background {}]
					frame $f.3.$n.$z.6a -bg $evv(POINT) -height 1
					button $f.3.$n.$z.7 -text "Restore Orig gain" -width 20 -bd 0 -command {} -highlightbackground [option get . background {}]
					frame $f.3.$n.$z.7a -bg $evv(POINT) -height 1
					button $f.3.$n.$z.8 -text "Rise Time"	   -width 20 -bd 0 -command {} -highlightbackground [option get . background {}]
					frame $f.3.$n.$z.8a -bg $evv(POINT) -height 1
					button $f.3.$n.$z.9 -text "Decay Time"	   -width 20 -bd 0 -command {} -highlightbackground [option get . background {}]
					frame $f.3.$n.$z.9a -bg $evv(POINT) -height 1
					pack $f.3.$n.$z.00a -side top -fill x -expand true
					pack $f.3.$n.$z.0 -side top
					pack $f.3.$n.$z.0a -side top -fill x -expand true
					pack $f.3.$n.$z.1 -side top
					pack $f.3.$n.$z.1a -side top -fill x -expand true
					pack $f.3.$n.$z.2 -side top
					pack $f.3.$n.$z.2a -side top -fill x -expand true
					pack $f.3.$n.$z.3 -side top
					pack $f.3.$n.$z.3a -side top -fill x -expand true
					pack $f.3.$n.$z.4 -side top
					pack $f.3.$n.$z.4a -side top -fill x -expand true
					pack $f.3.$n.$z.5 -side top
					pack $f.3.$n.$z.5a -side top -fill x -expand true -pady 2
					pack $f.3.$n.$z.6 -side top
					pack $f.3.$n.$z.6a -side top -fill x -expand true
					pack $f.3.$n.$z.7 -side top
					pack $f.3.$n.$z.7a -side top -fill x -expand true
					pack $f.3.$n.$z.8 -side top
					pack $f.3.$n.$z.8a -side top -fill x -expand true
					pack $f.3.$n.$z.9 -side top
					pack $f.3.$n.$z.9a -side top -fill x -expand true
					pack $f.3.$n.$z -side left
					set zz [expr $z + 1000]
					frame $f.3.$n.$zz -bg $evv(POINT) -width 1
					pack $f.3.$n.$zz -side left -padx 2 -fill y -expand true
					incr k
				} else {
					frame $f.3.$n.$ecnt
					frame $f.3.$n.$ecnt.numa -bg $evv(POINT) -height 1
					label $f.3.$n.$ecnt.num -text "$ecnt"
					frame $f.3.$n.$ecnt.numb -bg $evv(POINT) -height 1
					checkbutton $f.3.$n.$ecnt.chk -variable articv(onn,$ecnt) -command "ArticOn $ecnt"
					entry $f.3.$n.$ecnt.lev -textvariable articv(lev,$ecnt) -width 5 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
					entry $f.3.$n.$ecnt.frc -textvariable articv(frc,$ecnt) -width 5 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
					checkbutton $f.3.$n.$ecnt.sus -variable articv(sus,$ecnt) -command "ArticSustain $ecnt sus"
					checkbutton $f.3.$n.$ecnt.leg -variable articv(leg,$ecnt) -command "ArticSustain $ecnt leg"
					entry $f.3.$n.$ecnt.gai -textvariable articv(gai,$ecnt) -width 5 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
					checkbutton $f.3.$n.$ecnt.res -variable articv(rga,$ecnt) -command "ArticGainRestore $ecnt"
					entry $f.3.$n.$ecnt.ris -textvariable articv(ris,$ecnt) -width 5 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
					entry $f.3.$n.$ecnt.dec -textvariable articv(dec,$ecnt) -width 5 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
					pack $f.3.$n.$ecnt.numa -side top -fill x -expand true -padx 2
					pack $f.3.$n.$ecnt.num -side top
					pack $f.3.$n.$ecnt.numb -side top -fill x -expand true -padx 2
					pack $f.3.$n.$ecnt.chk -side top
					pack $f.3.$n.$ecnt.lev -side top
					pack $f.3.$n.$ecnt.frc -side top
					pack $f.3.$n.$ecnt.sus -side top
					pack $f.3.$n.$ecnt.leg -side top
					pack $f.3.$n.$ecnt.gai -side top
					pack $f.3.$n.$ecnt.res -side top
					pack $f.3.$n.$ecnt.ris -side top
					pack $f.3.$n.$ecnt.dec -side top
					bind $f.3.$n.$ecnt.lev <Up>	  "IncrArctic lev $ecnt 0 0"
					bind $f.3.$n.$ecnt.lev <Down> "IncrArctic lev $ecnt 1 0"
					bind $f.3.$n.$ecnt.frc <Up>   "IncrArctic frc $ecnt 0 0"
					bind $f.3.$n.$ecnt.frc <Down> "IncrArctic frc $ecnt 1 0"
					bind $f.3.$n.$ecnt.gai <Up>   "IncrArctic gai $ecnt 0 0"
					bind $f.3.$n.$ecnt.gai <Down> "IncrArctic gai $ecnt 1 0"
					bind $f.3.$n.$ecnt.lev <Up>	  "IncrArctic lev $ecnt 0 0"
					bind $f.3.$n.$ecnt.lev <Down> "IncrArctic lev $ecnt 1 0"
					bind $f.3.$n.$ecnt.frc <Up>   "IncrArctic frc $ecnt 0 0"
					bind $f.3.$n.$ecnt.frc <Down> "IncrArctic frc $ecnt 1 0"
					bind $f.3.$n.$ecnt.gai <Up>   "IncrArctic gai $ecnt 0 0"
					bind $f.3.$n.$ecnt.gai <Down> "IncrArctic gai $ecnt 1 0"
					bind $f.3.$n.$ecnt.ris <Up>   "IncrArctic ris $ecnt 0 0"
					bind $f.3.$n.$ecnt.ris <Down> "IncrArctic ris $ecnt 1 0"
					bind $f.3.$n.$ecnt.dec <Up>   "IncrArctic dec $ecnt 0 0"
					bind $f.3.$n.$ecnt.dec <Down> "IncrArctic dec $ecnt 1 0"
					bind $f.3.$n.$ecnt.lev <Shift-Up>	"IncrArctic lev $ecnt 0 1"
					bind $f.3.$n.$ecnt.lev <Shift-Down> "IncrArctic lev $ecnt 1 1"
					bind $f.3.$n.$ecnt.frc <Shift-Up>   "IncrArctic frc $ecnt 0 1"
					bind $f.3.$n.$ecnt.frc <Shift-Down> "IncrArctic frc $ecnt 1 1"
					bind $f.3.$n.$ecnt.gai <Shift-Up>   "IncrArctic gai $ecnt 0 1"
					bind $f.3.$n.$ecnt.gai <Shift-Down> "IncrArctic gai $ecnt 1 1"
					bind $f.3.$n.$ecnt.lev <Shift-Up>	"IncrArctic lev $ecnt 0 1"
					bind $f.3.$n.$ecnt.lev <Shift-Down> "IncrArctic lev $ecnt 1 1"
					bind $f.3.$n.$ecnt.frc <Shift-Up>   "IncrArctic frc $ecnt 0 1"
					bind $f.3.$n.$ecnt.frc <Shift-Down> "IncrArctic frc $ecnt 1 1"
					bind $f.3.$n.$ecnt.gai <Shift-Up>   "IncrArctic gai $ecnt 0 1"
					bind $f.3.$n.$ecnt.gai <Shift-Down> "IncrArctic gai $ecnt 1 1"
					bind $f.3.$n.$ecnt.ris <Shift-Up>   "IncrArctic ris $ecnt 0 1"
					bind $f.3.$n.$ecnt.ris <Shift-Down> "IncrArctic ris $ecnt 1 1"
					bind $f.3.$n.$ecnt.dec <Shift-Up>   "IncrArctic dec $ecnt 0 1"
					bind $f.3.$n.$ecnt.dec <Shift-Down> "IncrArctic dec $ecnt 1 1"
					pack $f.3.$n.$ecnt -side left
					set zz [expr $ecnt + 3000]
					frame $f.3.$n.$zz -bg $evv(POINT) -width 1
					pack $f.3.$n.$zz -side left -padx 2 -fill y -expand true
					incr k
					incr ecnt
					if {$ecnt > $articv(cnt,0)} {
						break
					}
				}
			}
			pack $f.3.$n -side top -pady 2
			if {$ecnt > $articv(cnt,0)} {
				break
			}
			incr n
		}	
		pack $f.3 -side top
		wm resizable $f 1 1
		bind $f <Escape> {set pr_artic 0}
		bind $f <Return> {set pr_artic 1}
	}
	if {![info exists articstitchtime]} {
		set articstitchtime ""
	}
	set m 0
	set n 1
	set e 1
	while {$e <= $articv(cnt,0)} {
		set articv(onn,$e) 0
		set articv(sus,$e) 0
		set articv(leg,$e) 0
		set articv(rga,$e) 0
		set articv_store(lev,$e) 0
		set articv_store(frc,$e) 0
		set articv_store(gai,$e) [DecPlaces $evlev($m) 3]
		set articv_store(ris,$e) 0.01
		set articv_store(dec,$e) 0.01
		set articv(lev,$e) ""
		set articv(frc,$e) ""
		set articv(gai,$e) ""
		set articv(ris,$e) ""
		set articv(dec,$e) ""
		if {[expr $e % 20] == 0} {
			incr n
		}
		incr e
		incr m
	}
	set fnamartic [file rootname [file tail $articorigdata]]
	append fnamartic "_artic"
	set finished 0
	set pr_artic 0 
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_artic
	while {!$finished} {
		tkwait variable pr_artic
		if {$pr_artic} {
			if {[string length $fnamartic] <= 0} {
				Inf "Invalid Output Datafile Name"
				continue
			}
			if {![ValidCDPRootname $fnamartic]} {
				Inf "Invalid Filename Entered"
				continue
			}
			set outfnam $fnamartic
			append outfnam [GetTextfileExtension brk]
			if {[string match $outfnam $articorigdata]} {
				Inf "You Cannot Overwrite The Original Unarticulated Envelope\n(In Case You Need To Return To It)"
				continue
			}
			if {[file exists $outfnam]} {
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] \
						-message "File exists: overwrite it ?"]
				if {$choice == "no"} {
					continue
				}
			}
			set outlines [DoArtics]
			if {[llength $outlines] <= 0} {
				continue
			}
			if [catch {open $outfnam "w"} zit] {
				Inf "Cannot Open File '$outfnam' To Write Articulation Data"
				continue
			}
			foreach line $outlines {
				puts $zit $line
			}
			close $zit
			FileToWkspace $outfnam 0 0 0 0 1
			set prm(7) $outfnam
			RememberArtic
			set finished 1
		} else {
			RestorePreArtic
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

#---- Arrow-Key control of "Artic" window values

proc IncrArctic {typ cnt down large} {
	global articv articv_store
	if {$cnt > 0} { 
		if {!$articv(onn,$cnt)} {
			return
		}
		if {$articv(leg,$cnt) && (($typ == "lev") || ($typ == "frc") || ($typ == "dec"))} {
			return
		}
		if {$articv(sus,$cnt) && (($typ == "lev") || ($typ == "frc"))} {
			return
		}
	}
	if {$large} {
		set step 0.1
	} else {
		set step 0.001
	}
	switch -- $typ {
		"glr" -
		"gld" -
		"ris" -
		"dec" {
			set zmax 10.0
			if {$large} {
				set zmin 0.1
			} else {
				set zmin 0.01
			}
		}
		default {
			set zmax 1.0
			set zmin 0.0
		}
	}
	if {$down} {
		if {![IsNumeric $articv($typ,$cnt)]} {
			set articv($typ,$cnt) $zmax
		} elseif {$articv($typ,$cnt) > 0.0} {
			set articv($typ,$cnt) [expr $articv($typ,$cnt) - $step]
			if {$articv($typ,$cnt) < $zmin} {
				set articv($typ,$cnt) $zmin
			}
		}
	} else {
		if {![IsNumeric $articv($typ,$cnt)]} {
			set articv($typ,$cnt) $zmin
		} elseif {$articv($typ,$cnt) < $zmax} {
			set articv($typ,$cnt) [expr $articv($typ,$cnt) + $step]
			if {$articv($typ,$cnt) > $zmax} {
				set articv($typ,$cnt) $zmax
			}
		}
	}
	if {$typ == "gai"} {
		if {$articv($typ,$cnt) == $articv_store($typ,$cnt)} {
			set articv(rga,$cnt) 1
		} else {
			set articv(rga,$cnt) 0
		}
	}
}

#---- Help for the "Artic" button for FOF extension.

proc ArticHelp {more} {
	set msg "                 SETTING ARTICULATION\n"
	append msg "\n"
	append msg "Articulation applied to OUTPUT of a process\n"
	append msg "already run, if it already has \"Loudness Contour\"\n"
	append msg "(possibly from MIDI key) which divides the output\n"
	append msg "into a number of silence-separated events.\n"
	append msg "Each articulable event numbered on interface.\n"
	append msg "see in sound, using \"Snd View\" on interface.\n"
	if {$more} {
		append msg "\n"
		append msg "1) To set event for artic, tick \"Articulation on\" or\n"
		append msg "select/mark it in \"Snd View\", (zooming ifness).\n"
		append msg "2) Set event's decay minimum above zero, by resetting\n"
		append msg "\"Decay to Minimum of\", and start time of minimum,\n"
		append msg "as a fraction of time-gap between this event's end\n"
		append msg "and next event's start:  reset \"Min at time-fraction\".\n"
		append msg "3) Force event to sustain until next event begins -\n"
		append msg "tick \"Sustain\" box, or elide event into next\n"
		append msg "(no pause) - tick \"Slur\" box.\n"
		append msg "4) Change overall gain by resetting \"Change Gain\"\n"
		append msg "Reset to original by ticking \"Restore orig gain\".\n"
		append msg "5) Change rise time of event with \"Rise time\",\n"
		append msg "and decay with \"Decay time\". Or change rise/decay\n"
		append msg "of ALL events (with \"Articulation on\"), by setting\n"
		append msg "\"Global rise/decay time\"+ pressing \"Set\" button.\n"
		append msg "Current Global values of \"rise/decay\" can be stored\n"
		append msg "(\"Remember\") and recalled later (\"Recall\").\n"
		append msg "6) Adjust level of last event to better match\n"
		append msg "level at sound end, by using \"Stich to end\".\n"
		append msg "\"max stitchtime\" = duration of level ramp at end\n"
		append msg "of final event.(If not set, ramps over entire event).\n"
		append msg "7)TO CHANGE NUMERIC VALUES, point to relevant box.\n"
		append msg "(a)  For small changes, \"Up\" and \"Down\" arrows.\n"
		append msg "(b)  For large, \"Shift Up\" and \"Shift Down\".\n"
		append msg "\n"
		append msg "Once artic complete, new envelope file output.\n"
		append msg "Rerun process (from Params page), then hear/see\n"
		append msg "result from \"View\" button on Params page.\n"
		append msg "\n"
		append msg "RE-running before quitting Params page,\n"
		append msg "(a) will articulate ORIGINAL envelope file\n"
		append msg "     not any articd envelope previously made).\n"
		append msg "(b)  Recall previous articulation settings from\n"
		append msg "     \"Previous Vals\" button.\n"
	} else {
		append msg "or from \"View\" button to top right of\n"
		append msg "Params Display (active after process has run).\n"
	}
	append msg "\n"
	Inf $msg
}

#---- Restore original gain of an event within a FOF-extended sound

proc ArticGainRestore {cnt} {
	global articv articv_store 
	if {!$articv(onn,$cnt)} {
		return
	}
	set articv(gai,$cnt) $articv_store(gai,$cnt)
	set articv(rga,$cnt 0)
}

#---- Sustain event within a FOF-extended sound

proc ArticSustain {cnt typ} {
	global articv articv_bak evlev
	if {!$articv(onn,$cnt)} {
		set articv(sus,$cnt) 0
		set articv(leg,$cnt) 0
		set articv(frc,$cnt) ""
		set articv(lev,$cnt) ""
		return
	}
	if {$typ == "sus"} {
		set articv(leg,$cnt) 0
		if {$articv(sus,$cnt)} {
			set articv_bak(lev,$cnt) $articv(lev,$cnt)
			set articv_bak(frc,$cnt) $articv(frc,$cnt)
			set articv(frc,$cnt) ""
			set articv(lev,$cnt) ""
		} else {
			catch {set articv(lev,$cnt) $articv_bak(lev,$cnt)}
			catch {set articv(frc,$cnt) $articv_bak(frc,$cnt)}
		}
	} else {
		set articv(sus,$cnt) 0
		if {$articv(leg,$cnt)} {
			set articv_bak(lev,$cnt) $articv(lev,$cnt)
			set articv_bak(frc,$cnt) $articv(frc,$cnt)
			set articv_bak(dec,$cnt) $articv(dec,$cnt)
			set articv(frc,$cnt) ""
			set articv(lev,$cnt) ""
			set articv(dec,$cnt) ""
		} else {
			catch {set articv(lev,$cnt) $articv_bak(lev,$cnt)}
			catch {set articv(frc,$cnt) $articv_bak(frc,$cnt)}
			catch {set articv(dec,$cnt) $articv_bak(dec,$cnt)}
		}
	}
}

#---- Switch on/off articulation for an event within a FOF-extended sound

proc ArticOn {n} {
	global articv articv_store
	if {$articv(onn,$n)} {
		set articv(lev,$n) $articv_store(lev,$n)
		set articv(frc,$n) $articv_store(frc,$n)
		set articv(gai,$n) $articv_store(gai,$n)
		set articv(ris,$n) $articv_store(ris,$n)
		set articv(dec,$n) $articv_store(dec,$n)
		set articv(rga,$n) 1
	} else {
		set articv(lev,$n) ""
		set articv(frc,$n) ""
		set articv(gai,$n) ""
		set articv(ris,$n) ""
		set articv(dec,$n) ""
		set articv(rga,$n) 0
		set articv(sus,$n) 0
		set articv(leg,$n) 0
	}
}

proc SetAllArtics {on} {
	global articv articv_store
	set n 1
	if {$on} {
		while {$n <= $articv(cnt,0)} {
			if {!$articv(onn,$n)} {
				set articv(onn,$n) 1
				set articv(lev,$n) $articv_store(lev,$n)
				set articv(frc,$n) $articv_store(frc,$n)
				set articv(gai,$n) $articv_store(gai,$n)
				set articv(ris,$n) $articv_store(ris,$n)
				set articv(dec,$n) $articv_store(dec,$n)
				set articv(rga,$n) 1
			}
			incr n
		}
	} else {
		while {$n <= $articv(cnt,0)} {
			set articv(onn,$n) 0
			set articv(lev,$n) ""
			set articv(frc,$n) ""
			set articv(gai,$n) ""
			set articv(ris,$n) ""
			set articv(dec,$n) ""
			set articv(rga,$n) 0
			set articv(sus,$n) 0
			set articv(leg,$n) 0
			incr n
		}
	}
}

#---- Rewrite the output envelope, to reflect the articulations entered

proc DoArtics {} {
	global articv evlev prearticlines artic_event return stitchratio stitchin stitchout stitchtime
	set nulines $prearticlines
	set slurs {}
	set artic_done 0
	set n 0
	set m 1
	while {$n < $articv(cnt,0)} {
		if {$articv(onn,$m)} {

			;#	IF EVENT IS TO BE SLURRED
				 
			if {$articv(leg,$m)} {
				set linetime [lindex $artic_event($n) 0]
				set cnt 0
				foreach line $nulines {
					if {[lindex $line 0] == $linetime} {	;#	Find MIDI event start in original lines
						incr cnt 2
						set nulines [lreplace $nulines $cnt [expr $cnt + 1]]
						set articv(lev,$m) "" ;# SAFETY
						set articv(frc,$m) "" ;# SAFETY
						set artic_done 1
						lappend slurs $m
						break
					}
					incr cnt
				}
			}

			;#	IF EVENT IS TO BE SUSTAINED
				 
			if {$articv(sus,$m)} {
				set linetime [lindex $artic_event($n) 0]
				set cnt 0
				foreach line $nulines {
					if {[lindex $line 0] == $linetime} {	;#	Find MIDI event start in original lines
						incr cnt 3
						set nextev  [lindex $nulines $cnt]
						set nextime [lindex $nextev 0]
						set endtime [expr $nextime - 0.02]
						incr cnt -2
						set line [lindex $nulines $cnt]
						set time [lindex $line 0]
						if {$endtime <= $time} {
							Inf "Event Already Sustained"
							break
						} else {
							set line [lreplace $line 0 0 $endtime]
							set nulines [lreplace $nulines $cnt $cnt $line]
							incr cnt
							set endtime [expr $endtime + 0.01]
							set line [lindex $nulines $cnt]
							set line [lreplace $line 0 0 $endtime]
							set nulines [lreplace $nulines $cnt $cnt $line]
							set articv(lev,$m) "" ;# SAFETY
							set articv(frc,$m) "" ;# SAFETY
							set artic_done 1
						}
						break
					}
					incr cnt
				}
			}

			;#	IF DECAY MINIMUM IS CHANGED
				 
			if {[IsNumeric $articv(lev,$m)] && ($articv(lev,$m) != 0)} {
				set linetime [lindex $artic_event($n) 0]
				set cnt 0
				foreach line $nulines {
					if {[lindex $line 0] == $linetime} {	;#	Find MIDI event start in original lines
						incr cnt 2
						set line [lindex $nulines $cnt]		;#	Go to MIDI event end in orig lines
						if {[lindex $line 1] == 0} {
							set line [lreplace $line 1 1 $articv(lev,$m)]
							set nulines [lreplace $nulines $cnt $cnt $line]
						}
						incr cnt 1
						set line [lindex $nulines $cnt]		;#	Go to MIDI event end in orig lines
						if {[lindex $line 1] == 0} {
							set line [lreplace $line 1 1 $articv(lev,$m)]
							set nulines [lreplace $nulines $cnt $cnt $line]
						}
						set artic_done 1
						break
					}
					incr cnt
				}
			}

			;#	IF DECAY ENDPOINT IS CHANGED
				 
			if {[IsNumeric $articv(frc,$m)] && ($articv(frc,$m) != 0)} {
				set linetime [lindex $artic_event($n) 0]
				set gap [lindex $artic_event($n) 3]
				set endshift [expr $gap * $articv(frc,$m)]	;#	Calculate change in decay-end position
				set cnt 0
				foreach line $nulines {
					if {[lindex $line 0] == $linetime} {	;#	Find MIDI event start in original lines
						incr cnt							;#	Go to end-time of current event before decay
						set endline [lindex $nulines $cnt]		
						incr cnt 2							;#	Go to start-time of next event
						set line [lindex $nulines $cnt]		
						set nextevtime [lindex $line 0]
						incr cnt -1							;#	Go to decay-end of event
						set line [lindex $nulines $cnt]		;#	Get time and ..
						set time [lindex $line 0]			;#	move the decay-end by "timeshift"
						set newtime [expr $time + $endshift]
						if {$newtime >= $nextevtime} {		;#	Check it's not overlapped start of next event
							set newtime [expr $nextevtime - 0.01]
							if {$newtime <= $time} {
								Inf "Cannot Shift Decay End Of Event $m"
							} else {
								set endline [lreplace $endline 0 0 $newtime]
								incr cnt -1									
								set nulines [lreplace $nulines $cnt [expr $cnt + 1] $endline]
							}
							break
						}
						set line [lreplace $line 0 0 $newtime]
						set nulines [lreplace $nulines $cnt $cnt $line]
						set artic_done 1
						break
					}
					incr cnt
				}
			}

			;#	IF EVENT GAIN IS CHANGED
				 
			if {[IsNumeric $articv(gai,$m)] && ![Flteq $articv(gai,$m) [DecPlaces $evlev($n) 3]]} {
				set linetime [lindex $artic_event($n) 0]
				set cnt 0
				foreach line $nulines {
					if {[lindex $line 0] == $linetime} {	;#	Find MIDI-event start in original lines and change gain
						set line [lreplace $line 1 1 $articv(gai,$m)]
						set nulines [lreplace $nulines $cnt $cnt $line]
						incr cnt							;#	Go to MIDI-event end in orig lines and change gain
						set line [lindex $nulines $cnt]
						set line [lreplace $line 1 1 $articv(gai,$m)]
						set nulines [lreplace $nulines $cnt $cnt $line]
						set artic_done 1
						break
					}
					incr cnt
				}
			}

			;#	IF EVENT RISETIME IS CHANGED
				 
			set prerise $nulines							;#	Original lines need to be preserved in case event starttime is moved here
			if {[IsNumeric $articv(ris,$m)] && ![Flteq $articv(ris,$m) 0.01]} {
				set linetime [lindex $artic_event($n) 0]
				set cnt 0
				foreach line $nulines {
					if {[lindex $line 0] == $linetime} {	;#	Find MIDI-event start in original lines and change gain
						set sttline $line					;#	Go to sustain-start of MIDI event end in orig lines
						set sttsus [lindex $sttline 0]
						set advans [expr $articv(ris,$m) - 0.01]
						incr cnt
						set susline [lindex $nulines $cnt]		;#	Go to end of sustain of event
						set endsus [lindex $susline 0]
						incr cnt
						set decline [lindex $nulines $cnt]		;#	Go to end of decay of event
						set enddec [lindex $decline 0]
						incr cnt
						set nexline [lindex $nulines $cnt]		;#	Go to end of start of next event
						set nextev [lindex $nexline 0]
						set nuenddec [expr $enddec + $advans]
						incr cnt -1								;#	if not overlapping next event-start
						if {$nuenddec < $nextev} {				;#	shift event sus_end and decay-end forward
							set decline [lreplace $decline 0 0 $nuenddec]		
							set nulines [lreplace $nulines $cnt $cnt $decline]
							incr cnt -1
							set endsus  [expr $endsus + $advans]
							set susline [lreplace $susline 0 0 $endsus]		
							set nulines [lreplace $nulines $cnt $cnt $susline]
							incr cnt -1
						} else {								;#	else, can we leave sus_end etc. where they are ??
							if {[expr $sttsus + $advans] >= $endsus} {
								Inf "No Time For Lengthened Risetime In Event $m"
								break
							}
							incr cnt -2
						}										;#	move sus_end forward		
						set sttsus  [expr $sttsus + $advans]
						set sttline [lreplace $sttline 0 0 $sttsus]		
						set nulines [lreplace $nulines $cnt $cnt $sttline]
						set artic_done 1
						break
					}
					incr cnt
				}
			}

			;#	IF EVENT DECAYTIME IS CHANGED
				 
			if {[IsNumeric $articv(dec,$m)] && ![Flteq $articv(dec,$m) 0.01]} {
				set linetime [lindex $artic_event($n) 0]
				set cnt 0
				foreach origline $prerise line $nulines {		;#	Search linetimes prior to possible mod of risetime
					if {[lindex $origline 0] == $linetime} {	;#	Find MIDI-event start in original lines and change gain
						if {[lsearch $slurs $m] >= 0} {
							break							;#	No decay with slurred notes
						}
						set advans [expr $articv(dec,$m) - 0.01]
						set stt [lindex $line 0]
						incr cnt
						set susline [lindex $nulines $cnt]	;#	Go to end of sustain of event
						set endsus [lindex $susline 0]
						incr cnt
						set decline [lindex $nulines $cnt]		;#	Go to end of decay of event
						set enddec [lindex $decline 0]
						incr cnt
						set nexline [lindex $nulines $cnt]		;#	Go to end of decay of event
						set nextev [lindex $nexline 0]
						incr cnt -1
						set origenddec $enddec
						set enddec [expr $enddec + $advans]
						if {$enddec >= $nextev} {				;#	Either advance end of decay slope, if possible,
							set enddec $origenddec
							incr cnt -1							;#	Or retro start of decay slope, of possible
							set endsus [expr $enddec - $articv(dec,$m)]
							if {$endsus <= $stt} {				;#	Or use whatever space is available
								set availspace [expr $nextev - $stt]
								set suson [expr $availspace - $advans]
								if {$suson <= 0.0} {
									Inf "No Time For Lengthened Decaytime In Event $m"
									break
								} else {
									set endsus [expr $stt + $suson]
									set susline [lreplace $susline 0 0 $endsus]
									set nulines [lreplace $nulines $cnt $cnt $susline]
									incr cnt
									set nulines [lreplace $nulines $cnt $cnt]
									set artic_done 1
									break
								}
							} else {
								set susline [lreplace $susline 0 0 $endsus]
								set nulines [lreplace $nulines $cnt $cnt $susline]
								set artic_done 1
								break
							}
						} else {
							set decline [lreplace $decline 0 0 $enddec]
							set nulines [lreplace $nulines $cnt $cnt $decline]
							set artic_done 1
							break
						}
					}
					incr cnt
				}
			}
		}
		incr n
		incr m
	}
	set lastlevl 1
	set lasttime 0
	set stitchinset 0	
	set stitchoutset 0
	set stitchindone 0	
	if {[info exists stitchratio]} {			;#	If stitching set, amplitude-stitch last event to end of sound
		set len [llength $nulines]
		set n 0
		while {$n < $len} {
			set line [lindex $nulines $n]
			set thistime [lindex $line 0]
			set thislevl [lindex $line 1]
			set timestep [expr $thistime - $lasttime]
			set levlstep [expr $thislevl - $lastlevl]
			if {!$stitchindone && ($thistime > $stitchin)} {
				set tratio [expr ($stitchin - $lasttime)/$timestep]
				set levl [expr ($levlstep * $tratio) + $lastlevl]
				set levl [expr $levl * $stitchratio]
				set nuline1 [list $stitchin $levl]
				set stitchinset 1
			}
			if {$thistime > $stitchout} {
				set tratio [expr ($stitchout - $lasttime)/$timestep]
				set levl [expr ($levlstep * $tratio) + $lastlevl]
				set nuline2 [list $stitchout $levl]
				set stitchoutset 1
			}
			if {$stitchinset && $stitchoutset} {
				set nulines [linsert $nulines $n $nuline1 $nuline2]
				break
			} elseif {$stitchinset} {
				set nulines [linsert $nulines $n $nuline1]
				set stichindone 1
			} elseif {$stitchoutset} {
				set nulines [linsert $nulines $n $nuline2]
				set artic_done 1
				break
			}
			set lastlevl $thislevl
			set lasttime $thistime
			incr n
		}
	}
	if {$stitchtime > 0} {	;#	If stitching time setup, insert extra line, if poss
		set len [llength $nulines]
		set n 0
		while {$n < $len} {
			set line [lindex $nulines $n]
			set thistime [lindex $line 0]
			if {[string match $thistime $stitchin]} {
				set pretime [expr $thistime - $stitchtime]
				incr n -1
				set lastline [lindex $nulines $n]
				set lasttime [lindex $lastline 0]
				set lastval  [lindex $lastline 1]
				incr n
				if {$lasttime < $pretime} {
					set line [list $pretime $lastval]
					set nulines [linsert $nulines $n $line]
					set artic_done 1
				}
				break
			}
			incr n
		}
	}
	if {!$artic_done} {
		Inf "No Articulation Done"
		return {}
	}
	return $nulines
}

#------ Restore the original envelope MIDI data, before any articulation

proc RestorePreArtic {} {
	global prm articorigdata
	if {![info exists articorigdata]} {
		return
	}
	if {![file exists $articorigdata]} {
		Inf "Pre-Articulated File '$articorigdata' No Longer Exists"
		return
	}
	set prm(7) $articorigdata
}

#------ Clean up any temporary file from "Artic" if system crashed

proc CleanArticFileAfterCrash {} {
	global evv
	set fnam "__"
	append fnam $evv(DFLT_OUTNAME) "000" $evv(SNDFILE_EXT)
	while {[file exists $fnam]} {
		catch {file delete $fnam}
	}
	set fnam "__"
	append fnam $evv(DFLT_OUTNAME) "111" $evv(SNDFILE_EXT)
	while {[file exists $fnam]} {
		catch {file delete $fnam}
	}
	set fnam "__"
	append fnam $evv(DFLT_OUTNAME) "222" $evv(SNDFILE_EXT)
	while {[file exists $fnam]} {
		catch {file delete $fnam}
	}
}

#------ Setup global rise or decay times

proc ArticSetGlobal {typ} {
	global articv artic_gg
	set is_set 0
	set n 1
	if {![IsNumeric $articv($typ,0)] || ($articv($typ,0) < 0.01) || ($articv($typ,0) > 10.0)} {
		return
	}
	while {$n <= $articv(cnt,0)} {
		if {$articv(onn,$n)} {
			set articv($typ,$n) $articv($typ,0)
			set is_set 1
		}
		incr n
	}
	if {!$is_set} {
		Inf "No Events Have \"Articulation On\""
	}
	set artic_gg 0
}

#----- Remember and recall previous articulation state

proc RememberArtic {} {
	global articv_mem articv
	set articv_mem(cnt,0) $articv(cnt,0)
	set articv_mem(ris,0) $articv(ris,0) 
	set articv_mem(dec,0) $articv(dec,0)
	set n 1
	while {$n <= $articv(cnt,0)} {
		set articv_mem(onn,$n) $articv(onn,$n)
		set articv_mem(lev,$n) $articv(lev,$n)
		set articv_mem(frc,$n) $articv(frc,$n)
		set articv_mem(sus,$n) $articv(sus,$n)
		set articv_mem(leg,$n) $articv(leg,$n)
		set articv_mem(gai,$n) $articv(gai,$n)
		set articv_mem(rga,$n) $articv(rga,$n)
		set articv_mem(ris,$n) $articv(ris,$n)
		set articv_mem(dec,$n) $articv(dec,$n)
		incr n
	}
}

proc ResetPreviousArtic {} {
	global articv_mem articv wstk
	if {![info exists articv_mem] || ($articv_mem(cnt,0) == 0)} {
		Inf "No Previous Settings"
		return
	}
	if {$articv_mem(cnt,0) > $articv(cnt,0)} {
		set msg "Previous Articulation Was For More Events: Proceed For Existing Events ??"
		set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		}
	} elseif {$articv_mem(cnt,0) < $articv(cnt,0)} {
		set msg "Previous Articulation Was For Fewer Events: Set First $articv_mem(cnt,0) Events ??"
		set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		}
	}
	set articv(ris,0) $articv_mem(ris,0)  
	set articv(dec,0) $articv_mem(dec,0)  
	set n 1
	while {$n <= $articv(cnt,0)} {
		set articv(onn,$n) $articv_mem(onn,$n)
		set articv(lev,$n) $articv_mem(lev,$n)
		set articv(frc,$n) $articv_mem(frc,$n)
		set articv(sus,$n) $articv_mem(sus,$n)
		set articv(leg,$n) $articv_mem(leg,$n)
		set articv(gai,$n) $articv_mem(gai,$n)
		set articv(rga,$n) $articv_mem(rga,$n)
		set articv(ris,$n) $articv_mem(ris,$n)
		set articv(dec,$n) $articv_mem(dec,$n)
		incr n
	}
}

proc ArticGlobsStorage {store} {
	global articv evv
	set fnam [file join $evv(URES_DIR) articg$evv(CDP_EXT)]
	if {$store} {
		if {([string length $articv(ris,0)] <= 0)} {
			if {([string length $articv(dec,0)] <= 0)} {
				Inf "No Globals To Remember"
				return
			} else {
				set memlist [list "-" $articv(dec,0)]
			}
		} elseif {([string length $articv(dec,0)] <= 0)} {
			set memlist [list $articv(ris,0) "-"]
		} else {
			set memlist [list $articv(ris,0) $articv(dec,0)]
		}
		if {[file exists $fnam]} {
			if [catch {file delete $fnam} zit] {
				Inf "Cannot Delete Existing Globals Memory File '$fnam'"
				return
			}
		}
		if [catch {open $fnam "w"} zit] {
			Inf "Cannot Open File '$fnam' To Remember Global Values"
			return
		}
		puts $zit $memlist
		close $zit
	} else {
		if {![file exists $fnam]} {
			Inf "No Stored Globals To Recall"
			return
		}
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot Open File '$fnam' To Read Global Values"
			return
		}
		set cnt 0
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				switch -- $cnt {
					0 {
						if {[IsNumeric $item]} {
							set risval $item
						}
					}
					1 {
						if {[IsNumeric $item]} {
							set decval $item
						}
					}
				}
				incr cnt
				if {$cnt > 2} {
					break
				}
			}
		}
		if {$cnt != 2} {
			Inf "Bad Data In File '$fnam'"
			return
		}
		if {[info exists risval]} {
			set articv(ris,0) $risval
		}
		if {[info exists decval]} {
			set articv(dec,0) $decval
		}
	}
}

proc StitchToEnd {} {
	global prm chlist pa evv wstk articvw simple_program_messages prg_dun prg_abortd CDPidrun CDPmaxId maxsamp_line
	global stitchratio stitchin stitchout articstitchtime stitchtime

	catch {unset stitchratio}
	if {[string length $articstitchtime] > 0} {
		if {![IsNumeric $articstitchtime] || ($articstitchtime < 0.01)} {
			set msg "Invalid Max Stitch Time (Min Val 0.01) :  Ignore It And Do Stitch??"
			set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
			set articstitchtime ""
			if {$choice == "no"} {
				return
			} else {
				set stitchtime 0.0
			}
		} else {
			set stitchtime $articstitchtime
		}
	} else {
		set msg "No Max Stitchtime Set: Do Stitch Anyway ??"
		set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		}
		set stitchtime 0.0
	}
	set inseg "__"
	append inseg $evv(DFLT_OUTNAME) "111" $evv(SNDFILE_EXT)
	set outseg "__"
	append outseg $evv(DFLT_OUTNAME) "222" $evv(SNDFILE_EXT)

	set endstart [expr $prm(2) - $pa([lindex $chlist 0],$evv(DUR)) + $prm(1)]	;#	Total_output_dur - src_dur + frztime
	set insegend  [expr $endstart - 0.005]
	set insegstt  [expr $insegend - 0.02]
	set outsegstt [expr $endstart + 0.005]
	set outsegend [expr $outsegstt + 0.02]

	set stitchin  $insegend
	set stitchout $outsegstt

	Block "Assessing Level before end portion"
	set cmd [file join $evv(CDPROGRAM_DIR) sfedit]
	lappend cmd cut 1 $articvw $inseg $insegstt $insegend -w0
	set prg_dun 0
	set prg_abortd 0
	catch {unset simple_program_messages}
	if [catch {open "|$cmd"} CDPidrun] {
		ErrShow "Cannot Cut Segment Prior To End Of Sound: $CDPidrun"
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
		set msg "Cannot Cut Segment Prior To End Of Sound"
		set msg [AddSimpleMessages $msg]
		ErrShow $msg
		UnBlock
		return
	}
	set done_maxsamp 0
	catch {unset maxsamp_line}
	set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
	lappend cmd $inseg 1
	if [catch {open "|$cmd"} CDPmaxId] {
		ErrShow "$CDPmaxId"
		catch {file delete $inseg}
		UnBlock
		return
   	} else {
   		fileevent $CDPmaxId readable "Maxsamp_Info2"
	}
 	vwait done_maxsamp
	catch {close $CDPmaxId}
	if {![info exists maxsamp_line]} {
		Inf "No Maximum Sample Information Retrieved From Segment Prior To End Of Sound"
		catch {file delete $inseg}
		UnBlock
		return
	}
	set maxsamp_line [StripCurlies $maxsamp_line]
	set items [split $maxsamp_line]
	set pregain [lindex $items end]
	if {$pregain <= 0.0} {
		Inf "Maximum Sample From Segment Prior To Sound-End Is Zero, Cannot Stitch"
		catch {file delete $inseg}
		UnBlock
		return
	}

	wm title .blocker "PLEASE WAIT:        Finding Level at start of end-portion"

	set cmd [file join $evv(CDPROGRAM_DIR) sfedit]
	lappend cmd cut 1 $articvw $outseg $outsegstt $outsegend -w0
	set prg_dun 0
	set prg_abortd 0
	catch {unset simple_program_messages}
	if [catch {open "|$cmd"} CDPidrun] {
		ErrShow "Cannot Cut Segment At Start Of Sound-End: $CDPidrun"
		catch {unset CDPidrun}
		catch {file delete $inseg}
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
		set msg "Cannot Cut Segment At Start Of Sound-End"
		set msg [AddSimpleMessages $msg]
		ErrShow $msg
		catch {file delete $inseg}
		UnBlock
		return
	}
	set done_maxsamp 0
	catch {unset maxsamp_line}
	set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
	lappend cmd $outseg 1
	if [catch {open "|$cmd"} CDPmaxId] {
		ErrShow "$CDPmaxId"
		catch {file delete $inseg}
		catch {file delete $outseg}
		UnBlock
		return
   	} else {
   		fileevent $CDPmaxId readable "Maxsamp_Info2"
	}
 	vwait done_maxsamp
	catch {close $CDPmaxId}
	if {![info exists maxsamp_line]} {
		Inf "No Maximum Sample Information Retrieved From Segment At Start Of Sound-End"
		catch {file delete $inseg}
		catch {file delete $outseg}
		UnBlock
		return
	}
	set maxsamp_line [StripCurlies $maxsamp_line]
	set items [split $maxsamp_line]
	set postgain [lindex $items end]
	if {$postgain <= 0.0} {
		Inf "No Maximum Sample From Segment At Start Of Sound-End Is Zero, Cannot Stitch"
		catch {file delete $inseg}
		catch {file delete $outseg}
		UnBlock
		return
	}
	catch {file delete $inseg}
	catch {file delete $outseg}
	set stitchratio [expr $postgain/$pregain]
	Inf "Done Stitch"
	UnBlock
}

#---- Command-N emulates "Get New Process" key

proc AltN_Action {} {
	global papag
	if {[string match [$papag.parameters.zzz.newp cget -state] "normal"]} {
		GetNewProcess 1	
	}
}

#---- Escape emulates "To Wkspace: New Files" OR Abnadon one-at-atime OR Abandon crewating instrument

proc Escape_Action {} {
	global ins_creation onpage_oneatatime which_oneatatime oneatatime papag
  	if {$ins_creation} {
		if{[string match [$papag.parameters.zzz.mabo cget -state] "normal"]} {
			AbandonIns
		}
	} elseif {[string match [$papag.parameters.zzz.newf cget -state] "normal"] } {
		if {[info exists onpage_oneatatime]} {
			unset onpage_oneatatime
			catch {unset which_oneatatime}
			catch {unset oneatatime}
		}
		GetNewFilesFromPpg
	}
}

#---- Command-R Emulates Recycle Key

proc AltR_Action {} {
	global ins ins_creation papag
 	if {!$ins_creation} {
		if {[string match [$papag.parameters.zzz.mabo cget -text] "Recycle Output"] \
		&&	[string match [$papag.parameters.zzz.mabo cget -state] "normal"] } {
 			RecycleOutfile
		}
	}
}

#---- Command-A Emulates Abandon Instrument Key

proc AltA_Action {} {
	global ins_creation papag
  	if {$ins_creation && [string match [$papag.parameters.zzz.mabo cget -state] "normal"]} {
		AbandonIns
	}
}

#---- Control-S Saves Files, or Process

proc SaveAction {} {
	global papag
	if {[string match [$papag.parameters.output.keep cget -state] "normal"]} {
		KeepOutput
	}
}

#--- Avoid running a process a 2nd time, by too quick resort to "Return" key!!

proc ParamsReturnAction {} {
	global papag wstk pprg evv
	if {[string match [$papag.parameters.output.keep cget -state] normal]} {
		if {![ParamsChanged]} {
			if {!(($pprg == $evv(MIXMULTI)) || ($pprg == $evv(MIX))) && ![string match [$papag.parameters.zzz.newf cget -text] "Get Next File"]} {
				set msg "Just ran this process with these parameters: run again ??"
				set choice [tk_messageBox -type yesno -default no -icon question -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					return
				}
			}
		}
	}
	KeyRun $papag.parameters.output.run
}

#--- Play soundfile in to-save list

proc PlayFromSave {} {
	global evv
	set i [.keeplist.saver.keepers.list curselection]
	if {$i < 0} {
		return
	}
	set fnam [.keeplist.saver.keepers.list get $i]
	set ftyp [FindFileType $fnam]
	if {$ftyp == $evv(SNDFILE)} {
		PlaySndfile $fnam 0
	}
}

#--- Dovetail ends of incomplete mix

proc DovetailIncompleteMix {inmix} {
	global ins evv prg_dun prg_abortd simple_program_messages CDPidrun prm pa

	set dur [expr $prm(1) - $prm(0)]
	if {$dur <= 0.04} {
		Inf "Incomplete Mix	Too Short To Dovetail "
		return
	}
	if {$ins(create)} {
		set outfnam $evv(MACH_OUTFNAME)
		set outfnam [glob -nocomplain $evv(MACH_OUTFNAME)*]
		if {[llength $outfnam] != 1} {
			Inf "Can't Dovetail Incomplete Mix"
			return
		}
	} else {
		set outfnam $evv(DFLT_OUTNAME)
		append outfnam 0 $evv(SNDFILE_EXT)
	}
	if {![file exists $outfnam]} {
		Inf "Can't Dovetail Incomplete Mixfile Output"
		return
	}
	set nuoutfnam [file rootname $outfnam]
	set len [string length $nuoutfnam]
	set len [expr $len - 1]
	set indx [string index $nuoutfnam $len] 
	if {![IsNumeric $indx]} {
		set indx 1
		lappend nuoutfnam $indx
	} else {
		incr indx
		set nuoutfnam [string range $nuoutfnam 0 [expr $len - 1]]
		append nuoutfnam $indx
	}
	append nuoutfnam $evv(SNDFILE_EXT)
	set dovestt 0
	set doveend 0
	set dovecnt 0
	set mgstt 0
	if {$prm(0) > 0.0} {
		set dovestt 0.02
		incr dovecnt
		set mgstt 1
	}
	if {![Flteq $prm(1) $pa($inmix,$evv(DUR))]} {
		set doveend 0.02
		incr dovecnt
	} 
	switch -- $dovecnt {
		2 {
			set endmsg "Ends"
		} 
		1 {
			if {$mgstt} {
				set endmsg "Start"
			} else {
				set endmsg "End"
			}
		}
		0 {
			return		;#	SAFETY
		}
	}
	Block "Dovetailing $endmsg Of Incomplete Mix"
	set cmd [file join $evv(CDPROGRAM_DIR) envel]
	lappend cmd dovetail 2 $outfnam $nuoutfnam $dovestt $doveend -t0
	set prg_dun 0
	set prg_abortd 0
	catch {unset simple_program_messages}
	if [catch {open "|$cmd"} CDPidrun] {
		catch {unset CDPidrun}
		ErrShow "Cannot Dovetail $endmsg Of Incomplete Mix Output: $CDPidrun"
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
		set msg "Failed To Dovetail $endmsg Of Incomplete Mix Output"
		set msg [AddSimpleMessages $msg]
		ErrShow $msg
		catch {file delete $nuoutfnam}
		UnBlock
		return
	}
	if [catch {file delete $outfnam} zit] {
		Inf "Cannot Replace Un-Dovetailed Mix Output With Dovetailed Version"
		catch {file delete $nuoutfnam}
		return
	}
	if [catch {file rename $nuoutfnam $outfnam} zit] {
		Inf "Cannot Rename Dovetailed Mix Output: Mix Output May Not Succeed"
	}
	UnBlock
}

proc LoadDoveMix {} {
	global evv dovemix
	set dovemix 0
	set fnam [file join $evv(URES_DIR) dovemix$evv(CDP_EXT)]
	if {[file exists $fnam]} {
		set dovemix 1
	}
}

proc SetDoveMix {} {
	global evv dovemix
	set fnam [file join $evv(URES_DIR) dovemix$evv(CDP_EXT)]
	if {![info exists dovemix] || ($dovemix == 0)} {
		set dovemix 1
		Inf "Incomplete Mixes Will Be Dovetailed"
		if {![catch {open $fnam "w"} zit]} {
			close $zit
		}
	} else {
		set dovemix 0
		Inf "Incomplete Mixes Will ~~NOT~~ Be Dovetailed"
		catch {file delete $fnam}
	}
}

#--- Replace names INSIDE a mixfile, on generic rename of SHRINK output

proc ReplaceInternalNames {mixfnam newname} {
	global evv
	if [catch {open $mixfnam "r"} zit] {
		Inf "Cannot Open Output Mixfile To Rename Listed Sndfiles"
		return
	}
	set k [string length $evv(DFLT_OUTNAME)]
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
#FEB 2022
		if {[string length $line] <= 0} {
			continue
		} elseif {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		catch {unset nuline}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend nuline $item
			}
		}
		set fnam [lindex $nuline 0]
		set basfnam [file rootname  $fnam]
		set ext		[file extension $fnam]
		set num [string range $basfnam $k end]
		set fnam $newname
		append fnam $num $ext
		set nuline [lreplace $nuline 0 0 $fnam]
		lappend nulines $nuline
	}
	close $zit
	if [catch {file delete $mixfnam} zit] {
		Inf "Cannot Delete Output Mixfile With Temporary Names"
		return
	}
	if [catch {open $mixfnam "w"} zit] {
		Inf "Cannot Reopen Output Mixfile To Rename Listed Sndfiles"
		return
	}
	foreach line $nulines {
		puts $zit $line
	}
	close $zit
}

#------ ITERFOF ONLY: Set Duration param to duration of line entered as param 1

proc SnapToLineDur {} {
	global pprg mmod evv prm pa
	if {$pprg != $evv(ITERFOF)} {
		return
	}
	if {[string length $prm(0)] <= 0} {
		Inf "No Line Parameter-1 Entered Yet"
		return
	}
	if {[IsNumeric $prm(0)]} {
		Inf "Line Parameter-1 ($prm(0)) Is Not A File"
		return
	}
	if {![file exists $prm(0)]} {
		Inf "Line Parameter File ($prm(0)) Does Not Exist"
		return
	}
	if {![IsABrkfile $pa($prm(0),$evv(FTYP))]} {
		Inf "File $prm(0) Is Not Of Correct Type"
		return
	}
	if {(($mmod <= 2) && (($pa($prm(0),$evv(MINBRK)) < -24) || ($pa($prm(0),$evv(MAXBRK)) > 12))) \
	||  (($mmod > 2 ) && (($pa($prm(0),$evv(MINBRK)) < 24)  || ($pa($prm(0),$evv(MAXBRK)) > 96)))} {
		Inf "File $prm(0) Is Out Of Range"
		return
	}
	if [catch {open $prm(0) "r"} zit] {
		Inf "Cannot Open File $prm(1)"
		return
	}
	set cnt 0
	set istime 1
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
#FEB 2022
		if {[string length $line] <= 0} {
			continue
		} elseif {[string match [string index $line 0] ";"]} {
			continue
		}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {$istime} {
				if [info exists lasttime] {
					set penulttime $lasttime
				}
				set lasttime $item
			} else {
				incr cnt
			}
			set istime [expr !$istime]
		}
	}
	close $zit
	if {$cnt < 2} {
		Inf "Insufficient Notes In Line To Set Duration"
		return
	}
	if {![info exists penulttime]} {
		Inf "Failed To Find Penultimate Time In Line To Set Duration"
		return
	}
	set laststep [expr $lasttime - $penulttime]
	set lasttime [expr $lasttime + $laststep]
	set prm(1) $lasttime
}

proc ProcessSpecificDisplaysForInstrumentCreation {} {
	global evv ins_file_lst pprg mmod snack_enabled papag
	catch {set invlist [$ins_file_lst get 0 end]}
	if {![info exists invlist]} {
		set invlist {}
	}
	set this_mode $mmod
	incr this_mode -1

	switch -regexp -- $pprg \
		^$evv(MIXMAX)$		- \
		^$evv(MIXGAIN)$		- \
		^$evv(MIXSHUFL)$	- \
		^$evv(MIXSYNC)$		- \
		^$evv(MIXSYNCATT)$	- \
		^$evv(MIXTWARP)$	- \
		^$evv(MIXSWARP)$ {
			$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state normal
			$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state normal
		} \
		^$evv(MIX)$	{
			$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state normal
			$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state normal
		} \
		^$evv(MIXMULTI)$ {
			$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state normal
			$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state normal
		} \
		^$evv(MIXBALANCE)$ {
			$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state normal
			$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state normal
		} \
		^$evv(ITERFOF)$ {
			$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOROFF)
			$papag.parameters.output.editqik config -text "Line Dur" -command "SnapToLineDur" -bd 2 -state normal
		} \
		^$evv(SPLINTER)$ {
			$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 1" -bd 2 -state normal -bg $evv(SNCOLOR)
			$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
		} \
		^$evv(FIND_PANPOS)$ - \
		^$evv(ONEFORM_GET)$ {
			$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 1" -bd 2 -state normal -bg $evv(SNCOLOR)
			$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
		} \
		^$evv(LOOP)$ {
			$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOR)
			$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
		} \
		^$evv(SHRINK)$ {
			if {[llength $invlist] > 0} {
				if {$mmod == 4} {
					$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 1" -bd 2 -state normal -bg $evv(SNCOLOR)
				} else {
					$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOROFF)
				}
			}
			$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
		} \
		^$evv(FOFEX_CO)$ {
			if {[llength $invlist] > 0} {
				if {$snack_enabled} {
					if {(($mmod == 1) || ($mmod == 6) || ($mmod == 7)) && [info exists fof_separator]} {						
						$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOR)
					} else {
						$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOROFF)
					}
				} else {
					$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
					SnackRecolor $invlist 1
				}
			} else {
				$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
			}
		} \
		^$evv(EDIT_INSERT2)$ - \
		^$evv(EDIT_INSERTSIL)$ {
			if {[llength $invlist] > 0} {
				if {$snack_enabled} {
					$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOR)
				} else {
					$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
					SnackRecolor $invlist 1
				}
			} else {
				$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
			}
			$papag.parameters.output.editqik config -text "End->Dur" -command "EndtimeToDur" -bd 2 -state normal
		} \
		^$evv(EDIT_EXCISEMANY)$ - \
		^$evv(EDIT_CUTMANY)$ - \
		^$evv(INSERTSIL_MANY)$ {
			if {[llength $invlist] > 0} {
				$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
				SnackRecolor $invlist 0
			} else {
				$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
			}
			$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
		} \
		^$evv(LPHP)$ {
			$papag.parameters.output.editsrc config -text "Toggle" -command "InvertFilt" -bd 2 -state normal
			$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
		} \
		^$evv(MIX_AT_STEP)$ {
			$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal -bg $evv(SNCOLOR)
			SnackRecolor $invlist 0
			$papag.parameters.output.editqik config -text  "Tap Time" -command "MixTimetap" -bd 2 -state normal
		} \
		^$evv(PREFIXSIL)$ {
			$papag.parameters.output.editsrc config -text "View Src" -command "SnackView 1" -bd 2 -state normal -bg $evv(SNCOLOR)
			$papag.parameters.output.editqik config -text  "" -command {} -bd 0
		} \
		^$evv(MOD_SPACE)$ {
			$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
			SnackRecolor $invlist 0
			if {$this_mode == $evv(MOD_PAN)} {
				$papag.parameters.output.editqik config -text  "Invert" \
					-command "InvertData pan" -bd 2 -state normal
			} else {
				$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
			}
		} \
		^$evv(MOD_RADICAL)$ {
			$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
			if {$this_mode == $evv(MOD_SCRUB)} {
				$papag.parameters.output.editsrc config -text "View Src" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOR)
			} else {
				$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
				SnackRecolor $invlist 0
			}
		} \
		^$evv(ENV_IMPOSE)$	- \
		^$evv(ENV_REPLACE)$ {
			if {$this_mode == $evv(ENV_BRKFILE_IN)} {
				$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
				$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
			}
		} \
		^$evv(TWIXT)$ {
			$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
			$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
		} \
		^$evv(CLICK)$ {
			$papag.parameters.output.editsrc config -text  "Time+Beats" -command "ClikCalculator" -bd 2 -state normal
			$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
		} \
		^$evv(FLTBANKV)$ {
			$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
			$papag.parameters.output.editqik config -text "Randomise" -command ScatterFilter -bd 2 -state normal
		} \
		^$evv(SYNFILT)$ {
			$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
			$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
		} \
		^$evv(FLTBANKV2)$ {
			if {[llength $invlist] > 0} {
				$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
				SnackRecolor $invlist 0
			} else {
				$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
			}
			$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
		} \
		^$evv(MIXCROSS)$ {
			if {[llength $invlist] > 0} {
				if {$snack_enabled} {
					$papag.parameters.output.editsrc config -text "Snd View" -command "ViewInput $invlist" -bd 2 -state normal -bg $evv(SNCOLOR)
				} else {
					$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal -bg [option get . background {}]
				}
			} else {
				$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
			}
			$papag.parameters.output.editqik config -text "Nudge" -command "MixCrossNudge mixcross" -bd 2 -state normal
		} \
		^$evv(ENV_TREMOL)$ {
			if {[llength $invlist] > 0} {
				$papag.parameters.output.editsrc config -text "Snd View" -command "ViewInput $invlist" -bd 2 -state normal -bg $evv(SNCOLOR)
				SnackRecolor $invlist 0
				$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state normal
			} else {
				$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state normal
				$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state normal
			}
		} \
		^$evv(MOD_PITCH)$ {
			if {[llength $invlist] > 0} {
				if {$this_mode == 4} {
					$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOR)
					$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state normal
				} elseif {$this_mode == 5} {
					$papag.parameters.output.editsrc config -text "Snd View" -command "ViewInput $invlist" -bd 2 -state normal -bg $evv(SNCOLOR)
					SnackRecolor $invlist 0
					$papag.parameters.output.editqik config "" -command {} -bd 0 -state normal
				} elseif {[llength $invlist] > 0} {
					$papag.parameters.output.editsrc config -text "Snd View" -command "ViewInput $invlist" -bd 2 -state normal -bg $evv(SNCOLOR)
					SnackRecolor $invlist 0
					$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state normal
				}
			} else {
				$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state normal
				$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state normal
			}
		} \
		^$evv(STRANS_MULTI)$ {
			if {[llength $invlist] > 0} {
				if {$this_mode == 2} {
					$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOR)
					$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state normal
				} elseif {$this_mode == 3} {
					$papag.parameters.output.editsrc config -text "Snd View" -command "ViewInput $invlist" -bd 2 -state normal -bg $evv(SNCOLOR)
					SnackRecolor $invlist 0
					$papag.parameters.output.editqik config "" -command {} -bd 0 -state normal
				} elseif {[llength $invlist] > 0} {
					$papag.parameters.output.editsrc config -text "Snd View" -command "ViewInput $invlist" -bd 2 -state normal -bg $evv(SNCOLOR)
					SnackRecolor $invlist 0
					$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state normal
				}
			} else {
				$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state normal
				$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state normal
			}
		} \
		^$evv(ENV_CURTAILING)$ - \
		^$evv(EXPDECAY)$ {
			if {[llength $invlist] > 0} {
				if {$snack_enabled} {
					if {$mmod == 3 || $mmod == 6} {
						$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 1" -bd 2 -state normal -bg $evv(SNCOLOR)
					} else {
						$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOR)
					}
				} else {
					$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
					SnackRecolor $invlist 1
				}
			} else {
				$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
			}
			if {($this_mode == 0) || ($this_mode == 3)} {
				$papag.parameters.output.editqik config -text "Nudge" -command "MixCrossNudge curtail" -bd 2 -state normal
			} else {
				$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
			}
		} \
		^$evv(ENV_DOVETAILING)$ {
			if {[llength $invlist] > 0} {
				if {$snack_enabled} {
					$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOR)
				} else {
					$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
					SnackRecolor $invlist 1
				}
			} else {
				$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
			}
			if {($this_mode == 0) || ($this_mode == 3)} {
				$papag.parameters.output.editqik config -text "Nudge" -command "MixCrossNudge curtail" -bd 2 -state normal
			} else {
				$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
			}
		} \
		^$evv(SAUSAGE)$ {
			if {[llength $invlist] > 0} {
				$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
				SnackRecolor $invlist 0
			} else {
				$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
			}
			$papag.parameters.output.editqik config -text  "Str->Sq" -command "StretchToSqueeze 1" -bd 2 -state normal
		} \
		^$evv(WRAPPAGE)$ {
			if {[llength $invlist] > 0} {
				$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
				SnackRecolor $invlist 0
			} else {
				$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
			}
			$papag.parameters.output.editqik config -text  "Str->Sq" -command "StretchToSqueeze 3" -bd 2 -state normal
		} \
		^$evv(BRASSAGE)$ {
			if {[llength $invlist] > 0} {
				$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
				SnackRecolor $invlist 0
			} else {
				$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
			}
			if {$mmod == 2 || $mmod == 6} {
				$papag.parameters.output.editqik config -text  "Str->Sq" -command "StretchToSqueeze 0" -bd 2 -state normal
			} elseif {$mmod == 7} {
				$papag.parameters.output.editqik config -text  "Str->Sq" -command "StretchToSqueeze 1" -bd 2 -state normal
			}
		} \
		^$evv(DRUNKWALK)$ {
			if {$sndgraphics && ($mmod == 1)} {
				$papag.parameters.output.editsrc config -text "Make Locus" -command "Booze" -bd 2 -state normal
			} else {
				$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
				if {[llength $invlist] > 0} {
					$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
					SnackRecolor $invlist 0
				} else {
					$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
				}
			}
		} \
		^$evv(P_APPROX)$ - \
		^$evv(P_EXAG)$ - \
		^$evv(P_QUANTISE)$ - \
		^$evv(P_RANDOMISE)$ - \
		^$evv(P_SMOOTH)$ - \
		^$evv(P_TRANSPOSE)$ - \
		^$evv(P_VIBRATO)$ - \
		^$evv(P_SYNTH)$ - \
		^$evv(P_VOWELS)$ - \
		^$evv(P_INVERT)$ {
			if {[llength $invlist] > 0} {
				$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal -width 8
				SnackRecolor $invlist 0
			} else {
				$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled -width 8
			}
			$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
		} \
		^$evv(SPLIT)$ {
			set version [GetVersionNumber $evv(SPLIT)]
			$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
			if {[llength $invlist] > 0} {
				$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal -width 8
				SnackRecolor $invlist 0
			} else {
				$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled -width 8
			}
		} \
		^$evv(PSOW_EXTEND)$ {
			if {[llength $invlist] > 0} {
				$papag.parameters.output.playsrc config -text "Snd View" -command "SnackView 1" -bd 2 -state normal -bg $evv(SNCOLOR)
				$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
				$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
				catch {file delete $articvw}
				catch {unset articorigdata}
				catch {PurgeArray $articvw}
			} else {
				$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled -width 8
				$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
			}
		} \
		^$evv(MCHANPAN)$ {
			if {$mmod == 1} {
				$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
			} else {
				$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled -width 8
			}
			$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
			SnackRecolor $invlist 0
		} \
		^$evv(BAKTOBAK)$ {
			if {[llength $invlist] > 0} {
				if {$snack_enabled} {
					$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 1" -bd 2 -state normal -bg $evv(SNCOLOR)
				} else {
					$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
					SnackRecolor $invlist 1
				}
			} else {
				$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled -width 8
			}
			$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled -width 8
		} \
		^$evv(SYNTH_WAVE)$ {
			$papag.parameters.output.editqik config -text "FileDur" -command "SynthDurInFile wave" -bd 2 -state normal -width 8
		} \
		^$evv(SYNTH_NOISE)$ {
			$papag.parameters.output.editqik config -text "FileDur" -command "SynthDurInFile noise" -bd 2 -state normal -width 8
		} \
		^$evv(SYNTH_SPEC)$ {
			$papag.parameters.output.editqik config -text "FileDur" -command "SynthDurInFile spec" -bd 2 -state normal -width 8
		} \
		^$evv(GRAIN_COUNT)$		- \
		^$evv(GRAIN_GET)$		- \
		^$evv(GRAIN_REVERSE)$	- \
		^$evv(GRAIN_REORDER)$	- \
		^$evv(GRAIN_DUPLICATE)$	- \
		^$evv(GRAIN_REPITCH)$	- \
		^$evv(GRAIN_RERHYTHM)$	- \
		^$evv(GRAIN_REMOTIF)$	- \
		^$evv(GRAIN_TIMEWARP)$	- \
		^$evv(GRAIN_OMIT)$		- \
		^$evv(GRAIN_POSITION)$	- \
		^$evv(GRAIN_ALIGN)$	{
			if {[llength $invlist] > 0} {
				$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
				SnackRecolor $invlist 0
			} else {
				$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
			}
			$papag.parameters.output.editqik config -text "BestGate" -command "SetGoodGate" -bd 2 -state normal -width 8
		} \
		^$evv(RETIME)$	{
			switch -- $mmod {
				2 {
					if {[llength $invlist] > 0} {
						$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
						SnackRecolor $invlist 0
					}
					$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
				}
				5 {
					$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOR)
					$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
				}
				8 -
				14 {
					$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 1" -bd 2 -state normal -bg $evv(SNCOLOR)
					$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
				}
				default {
					if {[llength $invlist] > 0} {
						$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
						SnackRecolor $invlist 0
					}
					$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
				}
			}
		} \
		^$evv(MOD_LOUDNESS)$ {
			if {$mmod == 1} {
				$papag.parameters.output.editqik config -text "Scale" -command {ScaleEnvelope} -bd 2 -state normal
				if {[llength $invlist] > 0} {
					if {$snack_enabled && [IsSingleEditType $pprg]} {
						$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOR)
					} elseif {$snack_enabled && [IsSingleMarkType $pprg]} {
						$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 1" -bd 2 -state normal -bg $evv(SNCOLOR)
					} else {
						$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
						SnackRecolor $invlist 0
					}
				} else {
					$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
				}
			} else {
				$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
				if {[llength $invlist] > 0} {
					if {$snack_enabled && [IsSingleEditType $pprg]} {
						$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOR)
					} elseif {$snack_enabled && [IsSingleMarkType $pprg]} {
						$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 1" -bd 2 -state normal -bg $evv(SNCOLOR)
					} else {
						$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
						SnackRecolor $invlist 0
					}
				} else {
					$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
				}
			}
		} \
		^$evv(HOVER2)$ {
			if {[llength $invlist] > 0} {
				if {$snack_enabled} {
					$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOR)
				} else {
					$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
					SnackRecolor $invlist 0
				}
			} else {
				$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
			}
		} \
		default {
			$papag.parameters.output.editqik config -text "" -command {} -bd 0 -state disabled
			if {[llength $invlist] > 0} {
				if {$snack_enabled && [IsSingleEditType $pprg]} {
					$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 0" -bd 2 -state normal -bg $evv(SNCOLOR)
				} elseif {$snack_enabled && [IsSingleMarkType $pprg]} {
					$papag.parameters.output.editsrc config -text "Snd View" -command "SnackView 1" -bd 2 -state normal -bg $evv(SNCOLOR)
				} else {
					$papag.parameters.output.editsrc config -text "View Src" -command "ViewInput $invlist" -bd 2 -state normal
					SnackRecolor $invlist 0
				}
			} else {
				$papag.parameters.output.editsrc config -text "" -command {} -bd 0 -state disabled
			}
		}
}

proc ChooseToStereo {} {
	global prm pa chlist evv pr_tosttog tstog_emer tstog_flip tstog_fork
	set choose_fork 0
	set is_forked 0
	set toggle_stereo 0
	set set_stereo 0
	if {![IsNumeric $prm(0)] || ($prm(0) < 0) || ($prm(0) > $pa([lindex $chlist 0],$evv(DUR)))} {
		Inf "Invalid start time"
		return
	}
	if {![IsNumeric $prm(1)] || ($prm(1) < 0) || ($prm(1) > $pa([lindex $chlist 0],$evv(DUR)))} {
		Inf "Invalid end time"
		return
	}
	if {[Flteq $prm(0) $prm(1)]} {
		Inf "Start and end times are the same : cannot proceed"
		return
	}
	set time_reversed 0
	if {$prm(0) > $prm(1)} {
		set time_reversed 1
	}
	if {![IsNumeric $prm(2)] || ![regexp {^[0-9]+$} $prm(2)] || ($prm(2) < 2) || ($prm(2) > 16)} {
		Inf "Invalid channel count"
		return
	}
	if {![IsNumeric $prm(3)] || ![regexp {^[0-9]+$} $prm(3)] || ($prm(3) < 0) || ($prm(3) > $prm(2))} {
		Inf "Invalid left or fork channel"
		return
	}
	if {![IsNumeric $prm(4)] || ![regexp {^[0-9]+$} $prm(4)] || ($prm(4) < 0) || ($prm(4) > $prm(2))} {
		Inf "Invalid right channel"
		return
	}
	set is_multi 0
	if {$prm(2) > 2} {
		set is_multi 1
	}
	if {$is_multi} {
		if {($prm(3) == 0) && ($prm(4) == 0)} {	;#	No channels chosen, decide whether to fork or not
			set choose_fork 1
		} elseif {$prm(4) == 0} {				;#	Channel 3 was Fork channel: change to non-fork ??
			set is_forked 1
		}
	} else {
		if {(($prm(3) == 1) && ($prm(4) == 2)) || (($prm(3) == 2) && ($prm(4) == 1)) } {
			set toggle_stereo 1
		} else {
			set set_stereo 1
		}
	}

	set f .tosttog
	if [Dlg_Create $f "TOGGLE TO_STEREO" "set pr_tosttog 0" -borderwidth $evv(BBDR)] {
		frame $f.0
		button $f.0.ok -text "Reset" -command "set pr_tosttog 1"
		button $f.0.quit -text "Quit" -command "set pr_tosttog 0"
		pack $f.0.ok -side left
		pack $f.0.quit -side right
		pack $f.0 -side top -fill x -expand true
		
		frame $f.1
		checkbutton $f.1.emer -variable tstog_emer -text "Emerge TO Stereo" -width 20
		checkbutton $f.1.flip -variable tstog_flip -text "Flip Stereo"	    -width 20
		checkbutton $f.1.fork -variable tstog_fork -text "Do as Fork"       -width 20
		pack $f.1.emer $f.1.flip $f.1.fork -side left
		pack $f.1 -side top -fill x
		wm resizable $f 0 0
		bind $f <Escape> {set pr_tosttog 0}
		bind $f <Return> {set pr_tosttog 1}
	}
	set tstog_emer 0
	set tstog_flip 0
	set tstog_fork 0
	if {$toggle_stereo} {									;#	STEREO OUT ONLY
		$f.1.flip config -text "Flip Stereo" -state normal
	} elseif {$set_stereo} {
		$f.1.flip config -text "Set Stereo" -state normal
	} else {
		$f.1.flip config -text "" -state disabled
	}	

	if {!$is_multi} {
		$f.1.fork config -text "" -state disabled
	} elseif {$choose_fork} {								;#	MULTICHAN OUT ONLY
		$f.1.fork config -text "Do as Forked" -state normal
	} elseif {$is_forked} {
		$f.1.fork config -text "Not Forked" -state normal
	} else {
		$f.1.fork config -text "Do as Forked" -state normal
	}
	if {$time_reversed} {
		$f.1.emer config -text "Emerge TO Stereo"
	} else {
		$f.1.emer config -text "Merge FROM Stereo"
	}
	set pr_tosttog 0	
	set finished 0
	My_Grab 0 $f pr_tosttog
	while {!$finished} {
		tkwait variable pr_tosttog
	 	if {$pr_tosttog} {
			if {!$tstog_emer && !$tstog_flip && !$tstog_fork} {
				Inf "Nothing changed"
				continue
			}
					;#	TIME FLOW

			if {$tstog_emer} {				;#	Reverse from-stereo to to-stereo or vice versa
				set temp $prm(0)
				set prm(0) $prm(1)
				set prm(1) $temp
			}
					;#	STEREO OUTPUT CASES

			if {$tstog_flip} {		
				if {$toggle_stereo} {		
					set temp $prm(3)		;#	Toggle output channels
					set prm(3) $prm(4)
					set prm(4) $temp
				} elseif {$set_stereo} {	;#	Set stereo output to defaults
					set prm(3) 1
					set prm(4) 2
				}
			}
					;#	MULTICHAN CASES

			if {$choose_fork} {				;#	Original channels NOT SET
				set prm(3) 1
				if {$tstog_fork} {			;#	IF checkbutton set, Set as forked
					set prm(4) 0
				} else {					;#	ELSE Set as not forked
					set prm(4) 2
				}
			} elseif {$tstog_fork} {		;#	ELSE IF checkbutton set
				if {$is_forked} {			;#	If already forked, set channel 2 (prm4) to channel adjacent to ch1 (prm3)
					set prm(4) $prm(3)
					incr prm(4)
					if {$prm(4) > $prm(2)} {
						set prm(4) [expr $prm(4) - $prm(2)]
					}
				} else {					;#	If NOT already forked, set chan2 output to zero (forces forking)	
					set prm(4) 0
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

proc DoNumberedChans {} {
	global gname generic_underscore generic_from_one
	set chnam [.generic.other.nunamesb.list get 0]
	append chnam "_c"
	set gname $chnam
	ForceVal .generic.name.e $gname
	set generic_underscore 0
	set generic_from_one 1
}


proc PlaylistToChlist3 {} {
	global play_pll ch chlist chcnt playgrab

	set i [$play_pll curselection]
	if {![info exists i] || ($i < 0)} {
		Inf "No file selected"
		return
	}
	set fnam [$play_pll get $i]
	if [info exists chlist] {
		foreach fnm $chlist {
			if [string match $fnm $fnam] {
				Inf "Already listed"
				return
			}
		}
	}
	set nulist $fnam
	if {[info exists chlist]} {
		set nulist [concat $nulist $chlist]
	}
	DoChoiceBak	
	$ch delete 0 end
	foreach fnam $nulist {
		lappend chlist $fnam
		$ch insert end $fnam
		incr chcnt
	}
	Inf "Added to chosen file"
	set playgrab 0
}

proc FootofCallingWindow {win} {
	set xy [wm geometry $win]
	set xy [split $xy x+]
	set h [lindex $xy 1]
	set y [lindex $xy 3]
	set foot [expr $y + $h]
	return $foot
}

proc SetBelowCallingWindow {win foot} {
	set xy [wm geometry $win]
	set xy [split $xy x+]
	set w [lindex $xy 0]
	set h [lindex $xy 1]
	set x [lindex $xy 2]
	set y [expr $foot + $h]
	set geo $w
	append geo x $h + $x + $y
	return $geo
}
