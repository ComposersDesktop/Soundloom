#
# SOUND LOOM RELEASE mac version 17.0.4
#

#####################
# RUNNING PROCESSES	#
#####################

#------ Run the program
								
proc RunProgram {fpr} {
	global prg_ran_before params_altered saved_cmd wl
	global cdpoutput ins rundisplay evv pprg mmod pr3
	global prg_ocnt sndsout asndsout smpsout vwbl_sndsysout txtsout papag
	global insprogoutcnt inssndsout insasndsout ins_vwbl_sndsysout instxtsout
	global prg_dun CDP_cmd deleting_status prg_abortd after_error
	global bulk chlist inssmpsout ins_cmd_dummy prm fof_pos checked_bulknorm_level bulksplit
	global panprocess panprocessfnam panprocess_individ pa mchengineer qikoffset

	catch {unset qikoffset}

	if {($pprg == $evv(MCHANPAN)) && ($mmod == 8)} {
		if {![RunProcessPanning $pa([lindex $chlist 0],$evv(CHANS))]} {
			catch {unset panprocess}
			catch {unset panprocessfnam}
			catch {unset panprocess_individ}
			DeleteAllTemporaryFiles
			set pr3 0
			return
		}
		PanProcess 0
		EnableRunAndOtherActionButtons $fpr
		return
	} elseif {(($pprg == $evv(MIX)) || ($pprg == $evv(MIXMULTI))) && !$ins(run)} {
		catch {SetScale 0 numeric}
		catch {SetScale 1 numeric}
	}
	catch {destroy .cpd}

 	if {[TrapBadData]} {
		return
	}
	DisableRunAndOtherActionButtons $fpr
	if {!$ins(run)} {
		DisableExtraBatchButtons
	}
	if {$ins(run)} {
		if {![DeleteAllTemporaryFiles]} {								;#	delete all possibly-named temporary files
			ErrShow "Files may be open to VIEW or to READ or to PLAY: close them, to proceed"
			EnableRunAndOtherActionButtons $fpr
			return											
		}
	} elseif {!$ins(create) || !$ins(thisprocess_finished)} {	;#	Delete any files left from any previous
		if {![info exists bulksplit] && ![info exists panprocess] && ![info exists mchengineer]} {
			if {![DeleteTemporaryFiles]} {									;#	run at this progcall as this could cock up 
				ErrShow "Files may be open to VIEW or to READ or to PLAY: close them, to proceed"
				EnableRunAndOtherActionButtons $fpr
				return											
			}
		}
	}			
 	set params_altered [ParamsChanged]						;#	If parameters have been altered
	RememberCurrentParams									;#	Save current state of params
															;#	If program not yet run, or params altered
	if {$prg_ran_before == 0 || $params_altered == 1} {
		if {![ParamsOK]} {									;#	If bad params, message displayed elsewhere
			EnableRunAndOtherActionButtons $fpr
			return											;#	Go back to waiting for button press
		}
	}
	if {[info exists panprocess] && ($panprocess == 1) && [info exists panprocess_individ]} {
		set panprocbulk 1
		set src_fnam [lindex $chlist 0]
		set chchans $pa($src_fnam,$evv(CHANS))
		set origchlist $chlist
		set zfz $evv(DFLT_OUTNAME)
		append zfz "0000_c"
		unset chlist
		foreach zfznam [glob -nocomplain $zfz*] {
			lappend chlist $zfznam
		}
		foreach zfz $chlist {
			set propno 0
			while {$propno < ($evv(CDP_PROPS_CNT) + $evv(CDP_MAXSAMP_CNT))} {
				if {[info exists pa($src_fnam,$propno)]} {
					set pa($zfz,$propno) $pa($src_fnam,$propno)
				}
				incr propno
			}
			set pa($zfz,$evv(FSIZ)) [expr $pa($src_fnam,$evv(FSIZ)) / $chchans]
			set pa($zfz,$evv(INSAMS)) [expr $pa($src_fnam,$evv(INSAMS)) / $chchans]
			set pa($zfz,$evv(CHANS)) 1
		}
		set bulk(run) 1
	}
	if {$bulk(run)} {			   ;#	If it's a bulk run
		if {![PurgeBulkOutput]} {
			return
		}
		set bulk(prg_ocnt) 0
		set bulk(sndsout) 0
		set bulk(asndsout) 0
		set bulk(smpsout) 0
		set bulk(vwbl_sndsysout) 0
		set bulk(txtsout) 0
		set prg_dun 1
		set prg_abortd 0
		set after_error 0
		set rpd [Create_Running_Process_Display]
		ForceVal $rpd.p.cnt.e2 [llength $chlist] 
		raise .running
		update idletasks
		StandardPosition .running
		My_Grab 0 $rpd prg_dun
		catch {tkwait visibility $rundisplay(done)}
		catch {tkwait window .running}
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {$prg_dun} {
			set prg_ocnt $bulk(prg_ocnt)
			set sndsout $bulk(sndsout)
			set asndsout $bulk(asndsout)
			set smpsout $bulk(smpsout)
			set vwbl_sndsysout $bulk(vwbl_sndsysout)
			set txtsout $bulk(txtsout)
			set params_altered 0
			incr prg_ran_before
			if {[info exists panprocbulk]} {
				foreach zfnam $chlist] {
					PurgeArray $zfnam
				}
				set zfz $evv(MACH_OUTFNAME)
				foreach fzfnam [glob $zfz*] {
					lappend renamelist $fzfnam
				}
				set zfz $evv(DFLT_OUTNAME)
				set k 1 
				foreach zfznam $renamelist {
					set zfznu $evv(DFLT_OUTNAME)
					append zfznu "0_c" $k $evv(SNDFILE_EXT)
					if [catch {file rename $zfznam $zfznu} zit] {
						Inf "file Renaming Failed"
						catch {unset panprocess}
						catch {unset panprocessfnam}
						catch {unset panprocess_individ}
						break
					}
					set propno 0
					while {$propno < ($evv(CDP_PROPS_CNT) + $evv(CDP_MAXSAMP_CNT))} {
						if {[info exists pa($zfz,$propno)]} {
							set pa($zfznu,$zfznam) $pa($zfz,$propno)
						}
						incr propno
					}
					incr k
				}
				foreach zfznam $renamelist {
					PurgeArray $zfznam
				}
				set prg_ocnt 0
				set bulk(run) 0
				set bulk(sndsout) 0
				set bulk(asndsout) 0
				set bulk(smpsout) 0
				set bulk(vwbl_sndsysout) 0
				set bulk(txtsout) 0
				set chlist $origchlist
				unset panprocbulk
			}
		} else {
			if {![DeleteAllTemporaryFiles]} {
				ErrShow "Files may be open to VIEW or to READ or to PLAY: close them, to proceed"
				set chlist $origchlist
				catch {unset panprocbulk}
				catch {unset panprocess}
				catch {unset panprocessfnam}
				catch {unset panprocess_individ}
			}
			EnableRunAndOtherActionButtons $fpr
			if {$prg_abortd} {
				set pr3 0
			}
			return
		}
	} elseif {$ins(run)} {									;#	If it's a ins-running,
		set insprogoutcnt 0
		set inssndsout 0
		set insasndsout 0
		set inssmpsout 0
		set ins_vwbl_sndsysout 0
		set instxtsout 0
		set prg_dun 1
		set prg_abortd 0
		set after_error 0
		set rpd [Create_Running_Process_Display]
		ForceVal $rpd.p.cnt.e2 $ins(process_length) 
		raise .running
		update idletasks
		StandardPosition .running
		My_Grab 0 $rpd prg_dun
		tkwait visibility $rundisplay(done)
		tkwait window .running

		if {$prg_abortd} {
			set prg_dun 0
		}

		if {$prg_dun} {
			set prg_ocnt $insprogoutcnt
			set sndsout $inssndsout
			set asndsout $insasndsout
			set smpsout $inssmpsout
			set vwbl_sndsysout $ins_vwbl_sndsysout
			set txtsout $instxtsout
			set params_altered 0						;#	If INSTRUMENT multi-process, mark that these params are USED
			incr prg_ran_before				;#	If INSTRUMENT multi-process, mark 1st multi-process run 
		} else {
			if {![DeleteAllTemporaryFiles]} {
				ErrShow "Files may be open to VIEW or to READ or to PLAY: close them, to proceed"
			}
			EnableRunAndOtherActionButtons $fpr
			if {$prg_abortd} {
				set pr3 0
			}
			return
		}
	} else {
		set prg_ocnt 0
		if {$pprg == $evv(MIXFORMAT)} {				;#	MixFormat gives user info only
			CDP_Specific_Usage $pprg 0
		}  else {
			set prg_abortd 0
			set prg_dun 1
			set after_error 0
			set rpd [Create_Running_Process_Display]
			raise .running
			update idletasks
			StandardPosition .running
			My_Grab 0 $rpd prg_dun
			catch {tkwait visibility $rundisplay(done)}
			MACMessage 4
			catch {tkwait window .running}
			if {$prg_abortd} {
				set prg_dun 0
			}
			if {$prg_dun} {
				set params_altered 0					;#	mark that these params now USED
				CountParseAndListOutputs
				if {[info exists deleting_status] && $deleting_status} {
					RemoveDuplicatesOnWkspace
					set deleting_status 0
				}
				if {$prg_ocnt < 0} {							;#	Failure in unique-naming routines
					if {![DeleteTemporaryFiles]} {				;#	delete temp outfiles EVEN IF creating ins
						ErrShow "Files may be open to VIEW or to READ or to PLAY: close them, to proceed"
					}
					EnableRunAndOtherActionButtons $fpr
					catch {unset panprocess}
					catch {unset panprocessfnam}
					catch {unset panprocess_individ}
					set pr3 0
					return
				}
				incr prg_ran_before			;#	If SINGLE process, mark 1st run (stops user trying to save TWICE)

				if {$ins(create)} {
					 if {[IsStandalonePrognoWithNonCDPFormat $pprg]} {
						set saved_cmd $ins_cmd_dummy
					} else {
						set saved_cmd "$CDP_cmd"		;#	At ins-creation, save the cmdline, for constructing the ins
					}
				} else {
					set saved_cmd "$CDP_cmd"			;#	also used by History
				}
				if {($pprg == $evv(FOFEX_EX)) && ($mmod == 2)} {
					set fof_pos $prm(1)
				}
			} else {									;#	Where NOT  ins(run) save it for History
				catch {unset panprocess}
				catch {unset panprocessfnam}
				catch {unset panprocess_individ}
				if {![DeleteTemporaryFiles]} {			;#	delete temp outfiles EVEN IF creating ins
					ErrShow "Files may be open to VIEW or to READ or to PLAY: close them, to proceed"
				}
				EnableRunAndOtherActionButtons $fpr
				return
			}
		}
	}
	EnableRunAndOtherActionButtons $fpr

	if {$evv(NEWUSER_HELP)} {
		$papag.help.starthelp config -command "GetNewUserHelp output"
	}

	set pr3 1
}

#------ Remove duplicate files from workspace

proc RemoveDuplicatesOnWkspace {} {
	global wl rememd

	set i 0
	foreach fnam [$wl get 0 end] {
		if {![file exists $fnam]} {
			lappend ilist $i
		}
		incr i		
	}
	if [info exists ilist] {
		foreach i [lsort -integer -decreasing $ilist] {
			WkspCnt [$wl get $i] -1
			$wl delete $i
		}
		catch {unset rememd}
	}
}

#------ Final run procedure from running-window

proc DoRun {rpd} {
	global CDPidrun prg_dun CDP_cmd new_cmdline_testing badcmd
	global ins temp_batch o_nam prg_ocnt sndsout asndsout smpsout vwbl_sndsysout txtsout evv
	global insprogoutcnt inssndsout insasndsout ins_vwbl_sndsysout instxtsout program_messages
	global prg_abortd rundisplay after_error inssmpsout new_fastquitrun
	global bulk chlist prm dfault sl_real tpn hst pprg mmod
	global sfedit_cutmany_broken eoftrap are_warnings no_run_msgs bulksplit origsplitfnam ch

	if {!$sl_real} {
		set prm(2) $dfault(2)
	}

	catch {unset are_warnings}
	TurnOffOutputButtons
	
	if {$bulk(run)} {
		if {![AssembleBulkCmdlines]} {
			My_Release_to_Dialog .running
			destroy .running
			return
		}
		set bulk(process_length) [llength $chlist]
		set bulk(process_cnt) 0
		set rundisplay(processno) 0
		set bulk(prg_ocnt) 0
		set bulk(sndsout) 0
		set bulk(asndsout) 0
		set bulk(smpsout) 0
		set bulk(vwbl_sndsysout) 0
		set bulk(txtsout) 0
		set bulk(messages) 0
		catch {unset hst(bulk)}
		set hst(bulkend) -1
		while {$bulk(process_cnt) < $bulk(process_length)} {
			if {$bulk(process_cnt) && ![winfo exists .running]} {
				set prg_dun 0
				return
			}
			ResetProgressBar
			incr rundisplay(processno)
			ForceVal $rpd.p.cnt.e1 $rundisplay(processno) 
			set CDP_cmd "[lindex $temp_batch $bulk(process_cnt)]"	
			lappend hst(bulk) $CDP_cmd
			incr hst(bulkend)
			set CDPidrun 0
			set program_messages 0
			set prg_dun 0
			set prg_abortd 0
			set after_error 0
			if {[IsStandalonePrognoWithNonCDPFormat $pprg]} {
				set sloom_cmd $CDP_cmd
			} else {
				set sloom_cmd [linsert $CDP_cmd 1 "#"]
			}
# RWD 2023 debugging...
#            Inf "0: command = $sloom_cmd"
			if [catch {open "|$sloom_cmd"} CDPidrun] {
				set line "$CDPidrun"
				.running.i.info insert end "$line\n" {error}
				set line "Cannot run process [lindex $CDP_cmd 1] for file [lindex $chlist $bulk(process_cnt)]"
				.running.i.info insert end "$line\n" {error}
				set bulk(messages) 1
				incr bulk(process_cnt)
				if {[info exists bulksplit]} {
					unset bulksplit
					DeleteAllTemporaryFiles
					set chlist $origsplitfnam
					$ch delete 0 end
					$ch insert end $origsplitfnam
					break
				}
				continue
		   	} else {
				.running.t.sv config -text "" -state disabled -bg [option get . background {}] -bd 0
				.running.t.ok config -text "" -state disabled -bg [option get . background {}]
				if {[info exists eoftrap]} {
		   			fileevent $CDPidrun readable "Display_Running_Program_Info $rpd 1"
		   		} else {									;#	Display info from program
			   		fileevent $CDPidrun readable "Display_Running_Program_Info $rpd 0"
				}
			}
			vwait prg_dun
# 2023 from PC 17.0.4
            set x 0
			after 1 {set x 1}
			vwait x
			if {$prg_abortd} {
				set prg_dun 0
			}
			if {!$prg_dun} {
				set line "Program failed for file [lindex $chlist $bulk(process_cnt)]"
				.running.i.info insert end "$line\n" {error}
				set bulk(messages) 1
				incr bulk(process_cnt)
				if {$hst(bulkend) == 0} {
					unset hst(bulk)
				} else {
					set hst(bulk) [lreplace $hst(bulk) $hst(bulkend) $hst(bulkend)]
				}
				incr hst(bulkend) -1
				if {[info exists bulksplit]} {
					unset bulksplit
					DeleteAllTemporaryFiles
					set chlist $origsplitfnam
					$ch delete 0 end
					$ch insert end $origsplitfnam
					break
				}
				continue
			} else {
				if {[info exists program_messages] && $program_messages} {
					set bulk(messages) 1
				}
				CountParseAndListBulkOutputs $bulk(process_cnt)
				if {$prg_ocnt < 0} {							;#	Failure in unique-naming routines
					set line "No output generated for file [lindex $chlist $bulk(process_cnt)]"
					.running.i.info insert end "$line\n" {error}
					set bulk(messages) 1
					incr bulk(process_cnt)
					if {$hst(bulkend) == 0} {
						unset hst(bulk)
					} else {
						set hst(bulk) [lreplace $hst(bulk) $hst(bulkend) $hst(bulkend)]
					}
					incr hst(bulkend) -1
					if {[info exists bulksplit]} {
						unset bulksplit
						DeleteAllTemporaryFiles
						set chlist $origsplitfnam
						$ch delete 0 end
						$ch insert end $origsplitfnam
						break
					}
					continue
				}
				incr bulk(prg_ocnt) $prg_ocnt
				incr bulk(sndsout) $sndsout
				incr bulk(asndsout) $asndsout
				incr bulk(smpsout) $smpsout
				incr bulk(vwbl_sndsysout) $vwbl_sndsysout
				incr bulk(txtsout) $txtsout
				incr bulk(process_cnt)
			}
#KLUDGE BECAUSE PROCESSING IS TOO FAST (!) AND LOOM FALLS OVER

			if {[ProcessIsTooFast]} {
				set x 0
				after 50 {set x 1}
				vwait x
			}
		}
		if {$bulk(messages)} {
			.running.t.sv config -text "Save Msgs" -state normal -bg $evv(EMPH) -bd 2
			.running.t.ok config -text "OK" -command "My_Release_to_Dialog .running ; destroy .running" -state normal -bg $evv(EMPH)
		} else {
			My_Release_to_Dialog .running
			destroy .running
		}
	} elseif {$ins(run)} {

		if {![AssembleTemporaryCmdlinesForIns]} {
			My_Release_to_Dialog .running
			destroy .running
			return
		}
		set ins(process_cnt) 0
		set rundisplay(processnm) ""
		set rundisplay(processno) 0
		set insprogoutcnt 0
		set inssndsout 0
		set insasndsout 0
		set inssmpsout 0
		set ins_vwbl_sndsysout 0
		set instxtsout 0
		set ins_messages 0
		while {$ins(process_cnt) < $ins(process_length)} {
			if {$ins(process_cnt) && ![winfo exists .running]} {
				set prg_dun 0
				return
			}
			ResetProgressBar
			incr rundisplay(processno)
			ForceVal $rpd.p.cnt.e1 $rundisplay(processno) 
			set o_nam $evv(MACH_OUTFNAME)		;#	update ofil name at each process
			append o_nam $ins(process_cnt) "_"	;#	so they'll tally with Instrumentcreate-generated names
			set CDP_cmd "[lindex $temp_batch $ins(process_cnt)]"	

			set ppprg [lindex $CDP_cmd 1]
			set mmmod [lindex $CDP_cmd 2]
			if {$mmmod > 0} {
				incr mmmod -1
			}
			set rundisplay(processnm) [lindex $tpn($ppprg) $mmmod]
			ForceVal $rpd.p.cnt.e0 $rundisplay(processnm) 

			set CDP_cmd [InterpretCmdlineForIns $CDP_cmd]
			set sub_pprog [lindex $CDP_cmd 1]
			if {[IsStandalonePrognoWithNonCDPFormat $sub_pprog]} {
				set CDP_cmd [ConvertStoredInsDummyCmdToStandaloneCmdWithNonCDPFormat $CDP_cmd]
			}
			if {[string length $CDP_cmd] <= 0} {
				My_Release_to_Dialog .running
				destroy .running
				return
			}
			set CDPidrun 0
			set program_messages 0
			set prg_dun 0
			set prg_abortd 0
			set after_error 0
			if {[IsStandalonePrognoWithNonCDPFormat $sub_pprog]} {
				set sloom_cmd $CDP_cmd
			} else {
				set sloom_cmd [linsert $CDP_cmd 1 "#"]
			}
# RWD 2023 debugging...
#            Inf "1: command = $sloom_cmd"
            
			if [catch {open "|$sloom_cmd"} CDPidrun] {
				ErrShow "$CDPidrun"
				ErrShow "Cannot run process [lindex $CDP_cmd 1]"
				My_Release_to_Dialog .running
				destroy .running
				return
		   	} else {
				.running.t.sv config -text "" -state disabled -bg [option get . background {}] -bd 0
				.running.t.ok config -text "" -state disabled -bg [option get . background {}]
		   		fileevent $CDPidrun readable "Display_Running_Program_Info $rpd 0"
		   													;#	Display info from program
			}
			vwait prg_dun
			if {$prg_abortd} {
				set prg_dun 0
			}
			if {!$prg_dun} {
				if {[info exists program_messages] && $program_messages} {
					.running.t.sv config -text "Save Msgs" -state normal -bg $evv(EMPH) -bd 2
					.running.t.ok config -text "OK" -command "set prg_dun 0 ; My_Release_to_Dialog .running ; destroy .running" -state normal -bg $evv(EMPH)
					vwait prg_dun
				} else {
					My_Release_to_Dialog .running
					destroy .running
				}
				return
			} else {
				if {[info exists program_messages] && $program_messages} {
					set ins_messages 1
				}
				CountParseAndListOutputs
				if {$prg_ocnt < 0} {							;#	Failure in unique-naming routines
					My_Release_to_Dialog .running
					destroy .running
					return
				}
				incr insprogoutcnt $prg_ocnt
				incr inssndsout $sndsout
				incr insasndsout $asndsout
				incr inssmpsout $smpsout
				incr ins_vwbl_sndsysout $vwbl_sndsysout
				incr instxtsout $txtsout
				incr ins(process_cnt)
			}
		}
		if {$ins_messages} {
			.running.t.sv config -text "Save Msgs" -state normal -bg $evv(EMPH) -bd 2
			.running.t.ok config -text "OK" -command "My_Release_to_Dialog .running ; destroy .running" -state normal -bg $evv(EMPH)
		} else {
			My_Release_to_Dialog .running
			destroy .running
		}
	} else {
		set badcmd 0									;#	For a single process (even at InstrumentCREATION)
		set CDP_cmd [AssembleCmdline 0]
		if {$new_cmdline_testing} {
			Patch_to_Batch 0 -1 0
		}
		if {$badcmd} {
			My_Release_to_Dialog .running
			destroy .running
			return
		}
#KLUDGE-->
		if {$sfedit_cutmany_broken && [IsCutMany $CDP_cmd]} {
			RunCutManyBatch $CDP_cmd $rpd
		} else {
#<--KLUDGE
			set CDPidrun 0
			set program_messages 0
			set after_error 0
			if {[IsStandalonePrognoWithNonCDPFormat $pprg]} {
				set sloom_cmd $CDP_cmd
			} else {
				set sloom_cmd [linsert $CDP_cmd 1 "#"]
			}
# RWD 2023 debugging...
#            Inf "2: command = $sloom_cmd"
			if [catch {open "|$sloom_cmd"} CDPidrun] {
				ErrShow "$CDPidrun"
				ErrShow "Cannot run process [lindex $CDP_cmd 1]"
				My_Release_to_Dialog .running
				destroy .running
				return										;#	On failure, go back to waiting for button press
	   		} else {
				.running.t.sv config -text "" -state disabled -bg [option get . background {}] -bd 0
				.running.t.ok config -text "" -state disabled -bg [option get . background {}]
	   			fileevent $CDPidrun readable "Display_Running_Program_Info $rpd 0"
	   		}
		}												;#	Display info from program
		vwait prg_dun
		set no_msgs 0
		if {[info exists no_run_msgs]} {				;#	Look for instruction to "show no messages"
			set no_msgs 1
			if {$ins(run) || [MessageOnlyProcess $pprg]} {
				set no_msgs 0							;#	BUT Always show messages with instruments
			}											;#	Or with message-only processes
		}
		if {$no_msgs && ![info exists are_warnings]} {	;#	If "show no msgs", so long as no warnings, delete msgs
			catch {unset program_messages}
		}
		if {[info exists program_messages] && $program_messages} {
			if {$pprg == $evv(INFO_MAXSAMP)} {
				catch {.running.t.sv config -text "Time as\nHr:Min:Sec" -state normal -bg $evv(EMPH) -bd 2}
				catch {.running.t.ok config -text "OK" -command "RunOK" -state normal -bg $evv(EMPH)}

			} elseif {($pprg == $evv(MIX)) || ($pprg == $evv(MIXMULTI))} {
				RunOK
			} elseif {([info exists new_fastquitrun] && $new_fastquitrun) && ![IsSndinfoPrg $pprg]} {
				RunOK
			} else {
				catch {.running.t.sv config -text "Save\nMessages" -state normal -bg $evv(EMPH) -bd 2}
				catch {.running.t.ok config -text "OK" -command "RunOK" -state normal -bg $evv(EMPH)}
			}
		} else {										;#	If no msgs, quit run page
			if [winfo exists .running] {
				My_Release_to_Dialog .running
				destroy .running
			}
		}
	}
}

#------ Allow functions to operate on data returned to Run window

proc RunOK {} {
	global pprg mmod mixmaxnorm maxgrain_gatelevel fof_pos runval pr_ref_ref pr_ref ref texoverload fof_separator prm evv

	set texoverload ""
	set mmode $mmod
	incr mmode -1
	set bas -1
	set itemcnt 0
	set getitem -1
	set valexists 0
	if {$pprg == $evv(MIXMAX)} {
		switch -regexp -- $mmode \
			^$evv(MIX_LEVEL_ONLY)$ - \
			^$evv(MIX_LEVEL_AND_CLIPS)$ {
				catch {unset mixmaxnorm}
				foreach word [.running.i.info get 1.0 end] {
					if {$itemcnt} {
						incr itemcnt
						if {$itemcnt == 4} {
							if {[IsNumeric $word]} {
								set	mixmaxnorm [TwoSigFig $word]
								set	runval $mixmaxnorm
							}
							break
						}
					} elseif [regexp {NORMALISATION} $word] {
						incr itemcnt
					}
				}
			}

	} elseif {($pprg == $evv(MIX)) || ($pprg == $evv(MIXMULTI))} {
		;

	} elseif {$pprg == $evv(GRAIN_ASSESS)} {
		catch {unset maxgrain_gatelevel}
		foreach word [.running.i.info get 1.0 end] {
			switch -- $itemcnt {
				0 {
					if {[string match "gate" $word]} {
						incr itemcnt
					}
				}
				1 {
					if {[string match "value" $word]} {
						incr itemcnt
					}
				} 2 {
					if {[IsNumeric $word]} {
						set	maxgrain_gatelevel $word
						break
					}
				}
			}
		}
	} elseif {$pprg == $evv(INFO_SFLEN)} {
		foreach word [.running.i.info get 1.0 end] {
			if {$itemcnt} {
				incr itemcnt
				if {$itemcnt == 2} {
					set	runval $word
					set valexists 1
					break
				}
			} elseif [regexp {DURATION} $word] {
				incr itemcnt
			}
		}
	} elseif {$pprg == $evv(PSOW_FREEZE)} {
		catch {unset fof_pos}
		foreach word [.running.i.info get 1.0 end] {
			switch -- $itemcnt {
				0 {
					if {[string match "grabbing" $word]} {
						incr itemcnt
					} else {
						continue
					}
				}
				5 {
					if {[IsNumeric $word]} {
						set	fof_pos $word
						break
					}
					incr itemcnt
				}
				default {
					incr itemcnt
				}
			}
		}
	} elseif {$pprg == $evv(FOFEX_EX)} {
		if {$mmod == 1} {
			foreach word [.running.i.info get 1.0 end] {
				if {[string match $word "separation"]} {
					set this_pos 0
				} elseif {[info exists this_pos]} {
					incr this_pos
					if {$this_pos == 5} {
						set fof_separator $word
						break
					}
				}
			}
		}
	} elseif {$pprg == $evv(PSOW_CUT)} {
		catch {unset fof_pos}
		foreach word [.running.i.info get 1.0 end] {
			switch -- $itemcnt {
				0 {
					if {[string match "TIME" $word]} {
						incr itemcnt
					} else {
						continue
					}
				}
				6 {
					if {[IsNumeric $word]} {
						set	fof_pos $word
						break
					}
					incr itemcnt
				}
				default {
					incr itemcnt
				}
			}
		}
	} else {
		switch -regexp -- $pprg \
			^$evv(TSTRETCH)$ { 
				if {$mmode == $evv(TSTR_LENGTH)} {
					set getitem 6
				}					
			} \
			^$evv(WINDOWCNT)$ 		 { set getitem 2  } \
			^$evv(CHANNEL)$ 		 { set getitem 5  } \
			^$evv(FREQUENCY)$ 		 { set getitem 0  } \
			^$evv(DISTORT_CYCLECNT)$ { set getitem 0  } \
			^$evv(GRAIN_COUNT)$ 	 {
 				foreach word [.running.i.info get 1.0 end] {
					if {[regexp {^[0-9]+$} $word]} {
						set runval $word
						set valexists 1
						break
					}
				}
			} \
			^$evv(INFO_TIMESUM)$ 	 { set getitem 2  } \
			^$evv(INFO_TIMEDIFF)$ 	 { set getitem 2  } \
			^$evv(INFO_SAMPTOTIME)$  { set getitem 1  } \
			^$evv(INFO_TIMETOSAMP)$  { set getitem 1  } \
			^$evv(INFO_MAXSAMP)$ 	 { set getitem 3  } \
			^$evv(INFO_MAXSAMP2)$ 	 { set getitem 3  } \
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
	   			foreach word [.running.i.info get 1.0 end] {
					if {$bas == $itemcnt} {
						set texoverload $word
						break
					}
					if {[string match $word "OVERLOAD:"]} {
						set bas $itemcnt
						incr bas 5
					}
					incr itemcnt
				}
			}

		if {$getitem >= 0} {
   			foreach word [.running.i.info get 1.0 end] {
				if {$itemcnt == $getitem} {
					set runval $word
					set valexists 1
					break
				}
				incr itemcnt
			}
		}
		if {[string length $texoverload] > 0} {
			TextureAtten
		}
	}
	if {$valexists} {
		set ref(text) ""
		set pr_ref_ref 0
 		.running.p.abort config -state disabled -text "" -state disabled -bd 0 -bg [option get . background {}]
		.running.t.sv config -text "" -state disabled -bg [option get . background {}] -bd 0
		.running.t.ok config -text "" -command {} -state disabled -bd 0 -bg [option get . background {}]
	 	.running.t.ref config -text "Keep $runval for reference ??" -state normal -bd 2 -bg $evv(EMPH)
 		.running.t.no config -text "No" -command {set pr_ref_ref 0} -state normal -bd 2 -bg $evv(EMPH)
		tkwait variable pr_ref_ref
	}
	My_Release_to_Dialog .running
	destroy .running
}

#------ Count, parse and list outputfiles from process
#
#	We assume all output files are called outfilenameN (where N is an integer), in ascending order
#	and that NO other files have this name
#

proc CountParseAndListOutputs {} {
	global prg_ocnt sndsout asndsout smpsout txtsout vwbl_sndsysout o_nam pa sl_real origmixbak evv
	global do_parse_report pprg channelxchan
	set prg_ocnt 0
	set sndsout 0
	set asndsout 0
	set smpsout 0
	set vwbl_sndsysout 0
	set txtsout 0
	set finished 0
	if {$pprg == $evv(CHANNELX)} {
		catch {unset channelxchan}
		set fnam $o_nam$prg_ocnt 
		set j 0
		foreach ffnam [glob -nocomplain "$fnam*"] {
			set ffnamnu [file rootname $ffnam]
			set ext [file extension $ffnam]
			set k [string first "_c" $ffnamnu]
			lappend channelxchan [string range $ffnamnu [expr $k + 2] end]
			incr k -2
			set ffnamnu [string range $ffnamnu 0 $k]
			append ffnamnu $j $ext
			if [catch {file rename $ffnam $ffnamnu} zit] {
				Inf "Cannot Change Output Name Of $ffnam To $ffnamnu"
				continue
			}
			incr j
		}
	}
	while {!$finished} {				 				;#	Create filenames 'outfilenameN' in ascending order
		set j 0
		set fnam $o_nam$prg_ocnt 
		if [file exists $fnam] {					;#	Look for file outfilenameN (without extension)
			incr j
		}
		foreach ffname [glob -nocomplain "$fnam.*"] {			;#	Look for file outfilenameN with extension
			if {[info exists origmixbak] && [string match $ffname $origmixbak]} {
				continue
			}
			incr j									
			if {$j > 1} {
				ErrShow "Naming conflict in output: [file rootname $fnam]"
				set prg_ocnt -1
				return
			} else {
				set fnam $ffname
			}
		}					
		if {$j == 0} {							;#	If NO file outfilenameN exists, we're at end of output-files: exit
			set finished 1
			break
		}										;#	Parse outfilenameN,if ness change extension,Put on wkspace-listing
		set do_parse_report 1
		set fnam [DoOutputParse $fnam]
		if {[string length $fnam] == 0} {
			ErrShow "DoOutputParse failed"
			set prg_ocnt -1
			return
		}
		incr prg_ocnt									;#	Count output files
		if {!$sl_real} {
			incr sndsout
			incr smpsout
			incr vwbl_sndsysout					
			return
		}
		if {$pa($fnam,$evv(FTYP)) == $evv(SNDFILE)} {
			incr sndsout								;#	Count output sndfiles
			incr smpsout
			incr vwbl_sndsysout					
		} elseif {$pa($fnam,$evv(FTYP)) == $evv(PSEUDO_SND)} {
			incr vwbl_sndsysout					;#	Count displayable sndsystem files
			incr smpsout
		} elseif {$pa($fnam,$evv(FTYP)) == $evv(ANALFILE)} {
			incr asndsout
			incr vwbl_sndsysout					;#	Count displayable sndsystem files
			incr smpsout
		} elseif {$pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)} {
			incr txtsout								;#	Count text files
		} else {
			incr smpsout
		}
	}
}

#------ Parse file(cdparse),add or change name_extension where ness, save its data in pa.
	
proc DoOutputParse {fnam} {
	global evv CDPid parse_error is_input_parse pa props_got
	global propslist pprg mmod sl_real

	if {!$sl_real} {
		Inf "The Soundloom Examines The Output File To Discover All Its Properties.\nIt Then Knows Which Processes Can Be Applied To The File."
		return $fnam
	}
	set parse_error 0
	set props_got 0
	set is_input_parse 0
	set CDPid 0
	set cmd [file join $evv(CDPROGRAM_DIR) cdparse]

	if [catch {open "|$cmd $fnam 0"} CDPid] {
		ErrShow "Failed to parse file $fnam"
		catch {unset CDPid}
		return ""
	} else {
  		set propslist ""
		fileevent $CDPid readable "AccumulateFileProps"
	}
	vwait props_got

	if {$parse_error} {
		return ""
	}
	if [info exists propslist] {
		if {[llength $propslist] != ($evv(CDP_PROPS_CNT) + $evv(CDP_MAXSAMP_CNT))} {
#			ErrShow "Wrong number of props ([llength $propslist]) returned to DoOutputParse from cdparse\nof file $fnam\nPROPSLIST\n$propslist"
			set ext [file extension $fnam]
			switch -regexp -- $ext \
				^$evv(SNDFILE_EXT)$ - \
				^$evv(ANALFILE_EXT)$ - \
				^$evv(PITCHFILE_EXT)$ - \
				^$evv(TRANSPOSFILE_EXT)$ - \
				^$evv(FORMANTFILE_EXT)$ - \
				^$evv(ENVFILE_EXT)$ {
					ErrShow "Cannot Read The Header Of The Output File '$fnam'\nThe CDP Process May Not Have Functioned Correctly"
				} \
				default {
					ErrShow "Cannot Find any valid data in the output file '$fnam'\nThe CDP Process May Not Have Functioned Correctly"
				}

			return ""
		}
	} else {
		ErrShow "Failed to get properties of $fnam"
		return ""
	}																	;#	Trap pseudo_sndfiles
	set mmode $mmod
	incr mmode -1

	if {($pprg == $evv(LEVEL)) || ($pprg == $evv(P_SEE)) \
	|| (($pprg == $evv(HOUSE_EXTRACT)) && ($mmode == $evv(HOUSE_CUTGATE_PREVIEW)))} {
		set propslist [lreplace $propslist $evv(FTYP) $evv(FTYP) $evv(PSEUDO_SND)]
	}

	set ftyp [lindex $propslist $evv(FTYP)]
	switch -regexp -- $ftyp \
		^$evv(SNDFILE)$ - \
		^$evv(PSEUDO_SND)$ - \
		^$evv(ANALFILE)$ - \
		^$evv(PITCHFILE)$ - \
		^$evv(TRANSPOSFILE)$ - \
		^$evv(FORMANTFILE)$ - \
		^$evv(ENVFILE)$ {} \
		default {		   		;#	Else textfile
			set nufnam $fnam
			if {$pprg == $evv(BATCH_EXPAND)} {
				append nufnam $evv(BATCH_EXT)
			} else {			
				set this_ext [AssignTextfileExtension $ftyp]
				append nufnam $this_ext
			}
			if [catch {file rename -force $fnam $nufnam}] {
				ErrShow "Cannot change the output file extension.\n"
			} else {
				set fnam $nufnam
			}
		}


	set propno 0
	foreach prop [lrange $propslist 0 end] {
		set pa($fnam,$propno) $prop
		incr propno
	}
	if {[info exists pa($fnam,$evv(MAXREP))]} {
		if {($pa($fnam,$evv(MAXREP)) < 0) || ($pa($fnam,$evv(FTYP)) != $evv(SNDFILE))} {
			unset pa($fnam,$evv(MAXREP))
		}
	}
	return $fnam
}

#------ Display info returned by running-program in the the program-running display

proc Display_Running_Program_Info {rpd eoftest_trap} {
	global running CDPidrun rundisplay prg_dun prg_abortd ins program_messages after_error evv
	global bulk super_abort are_warnings

# ATTEMPT TO STOP "[eof $CDPidrun]" FAILING (FAST MACHINES ??)
	if {$eoftest_trap} {
		if [catch {set test [eof $CDPidrun]} zit] {
			return
		} elseif {$test} {
			set prg_dun 1
			catch {close $CDPidrun}
			return
		}
	} else {
		if [eof $CDPidrun] {
			set prg_dun 1
			catch {close $CDPidrun}
			return
		}
	}
	gets $CDPidrun line
	set line [string trim $line]
	if {[string length $line] <= 0} {
		return
	}
	if [string match INFO:* $line] {
		set line [string range $line 6 end] 
		.running.i.info insert end "$line\n"
		set program_messages 1
	} elseif [string match WARNING:* $line] {
		set line [string range $line 9 end] 
		.running.i.info insert end "$line\n" {warning}
		set are_warnings 1
		set program_messages 1
	} elseif [string match TIME:* $line] {
		set line [string range $line 6 end] 
		if {![IsNumeric $line]} {
			.running.i.info insert end "Time Display Message Error (non_numeric)\n" {warning}
			set program_messages 1
		} elseif {$line < 0 || $line > $evv(PBAR_LENGTH)} {
			.running.i.info insert end "Time Display Message Range Error ($line > $evv(PBAR_LENGTH) || $line < 0)\n" {warning}
			set program_messages 1
		}
		$rundisplay(done) config -width $line
	} elseif [string match ERROR:* $line] {
		set line [string range $line 7 end] 
		.running.i.info insert end "$line\n" {error}
		set are_warnings 1
		set after_error 1
		set prg_dun 0
		set prg_abortd 1
		set program_messages 1
		return
	} elseif [string match END:* $line] {
		$rundisplay(done) config -width $evv(PBAR_LENGTH)
		set prg_dun 1
		return
	} else {
		.running.i.info insert end "$line\n"
		set program_messages 1
	}
	update idletasks
}			

#------ Terminating a CDP process or ins

proc SeriousTermination {rpd} {
	global CDPidrun ins evv 

	if [info exists CDPidrun] {
		catch {close $CDPidrun}
		unset CDPidrun
	}
}

#------ Create a list of the parameters for the cdpmain program

proc AssembleCmdline {from_musunits} {
	global prm pmcnt prg pprg mmod chlist pa o_nam is_crypto
	global badcmd hst ins deleting_status copy_name full_copy_name evv
	global float_out ins_cmd_dummy submixversion texture_mindur_override

	if {!$from_musunits} {
		if {$ins(create)} {
			if [info exists ins(chlist)] {
				set thischosenlist "$ins(chlist)"
			}
		} else {
			if [info exists chlist] {
				set thischosenlist "$chlist"
			}
		}
		if {$pprg == $evv(MIXBALANCE)} {
			if {$submixversion < 7} {
				set dur $pa([lindex $thischosenlist 0],$evv(DUR))
				set maxdur $dur
				foreach fnam [lrange $thischosenlist 1 end] {
					if {$pa($fnam,$evv(DUR)) > $maxdur} {
						set maxdur $pa($fnam,$evv(DUR))
						set maxfile $fnam
					}
				}
				if {$maxdur > $dur} {
					Inf "For This Process, Put The Longest File ($maxfile) First In The List Of Files."
					set badcmd 1
					return ""
				}
			}
		}
	}
	set i 0
	if [IsMchanToolkit $pprg] {
		set cmd [file join $evv(CDPROGRAM_DIR) [GetMchanToolKitProgname $pprg]]
	} else {
		if {[IsTextureProgram $pprg] && $texture_mindur_override} {
			set cmd [file join $evv(CDPROGRAM_DIR) texture_new]
		} else {
			set cmd [file join $evv(CDPROGRAM_DIR) [lindex $prg($pprg) $evv(UMBREL_INDX)]]
		}
	}
	if {[string length $cmd] == 0} {
		set badcmd 1
		return ""
	}
	if [ProgMissing $cmd "Cannot perform this process"] {
		set badcmd 1
		return ""
	}
	if {![IsStandalonePrognoWithNonCDPFormat $pprg]} {
		catch {unset ins_cmd_dummy}
		lappend cmd $pprg $mmod		 				;#	Program number & Mode number
		if [info exists thischosenlist] {
			set infilecnt [llength $thischosenlist]			;#	Number of input files 
		} else {
			set infilecnt 0
		}
		set zumph 0
		set bailout [CheckCrypto]
		if {$bailout} {
			set infilecnt 1
		}
		lappend cmd $infilecnt
		if {$infilecnt > 0} {								;#	If there are any infiles
			set fnam [lindex $thischosenlist 0]
			set propno 0
			while {$propno < $evv(CDP_PROPS_CNT)} {			;#	Send Properties of first input file
				lappend cmd $pa($fnam,$propno)
				incr propno
			}
		}
	} else {
		if $ins(create) {
			set ins_cmd_dummy [CreateDummyStandaloneCmd 1]
		} else {
			catch {unset ins_cmd_dummy}
		}
		if {![IsMchanToolkit $pprg] && ([lindex $prg($pprg) $evv(MODECNT_INDEX)] > 0)} {
			lappend cmd $mmod
		}
		set infilecnt 0
		if [info exists thischosenlist] {
			set infilecnt [llength $thischosenlist]			;#	Number of input files 
		}
		set bailout 0
	}
	if {$infilecnt > 0} {								;#	If there are any infiles
		foreach fnam [lrange $thischosenlist 0  end] { 	;# 	And Names of all the input files
			lappend cmd "$fnam"
			if {$ins(create)} {		 				;#	at ins-creation, hst collects all infiles
				lappend hst(infiles) "$fnam"
			}
			if {$bailout} {
				break
			}
		}
	}

	if {$pprg == $evv(HOUSE_DEL)} {
		set deleting_status 1
		set copy_name $prm(0)
	} else {
		set deleting_status 0
	}
	if {($pprg == $evv(RETIME)) && ($mmod == 12)} {
		set out_name [string tolower $prm(0)]
		if {![string match [file extension $out_name] $evv(TEXT_EXT)]} {
			if {[string length [file extension $out_name]] > 0} {
				Inf "Invalid File Extension ([file extension $out_name]): Must Be '$evv(TEXT_EXT)' Or None"
				return 0
			}
			set out_name [file rootname $out_name]
			append out_name $evv(TEXT_EXT)
			set prm(0) $out_name
		}
	} elseif {($pprg == $evv(MIXMAX)) && ($mmod == 1)} {
		;#	NO OUTFILE
	} else {
		set out_name $o_nam
		append out_name "0"

## NOV 2002: FORCES sfsysEx to write correct type of outfile!!

		set file_ext [GetProcessOutfileExtension $pprg $mmod]
		append out_name $file_ext
		if {($file_ext == $evv(SNDFILE_EXT)) && $float_out && ![IsStandalonePrognoWithNonCDPFormat $pprg]} {
			if {[NonTextfileOutputIsASoundfile $pprg $mmod]} {
				set fzz $evv(FLOAT_OUT)
				append fzz $out_name
				set out_name $fzz
			}
		}
	}
	if {!(($pprg == $evv(MIXMAX)) && ($mmod == 1))} {
		lappend cmd $out_name							;#	Name of outfile(s), always a standard default-name
	}
	set i 0
	while {$i < $pmcnt} {							;#	all parameters for the program
		if {![IsStandalonePrognoWithNonCDPFormat $pprg]} {
			set val [MarkNumericVals $i]				;#	Distinguish numbers from brkfiles
		} else {
			set val $prm($i)
		}
		lappend cmd $val
		incr i
		if {[IsDeadParam $i]} {
			set prm($i) 0
			set val $evv(NUM_MARK)
			append val $prm($i)
			lappend cmd $val
			incr i
		}
	}
	if {[IsStandalonePrognoWithNonCDPFormat $pprg]} {
		set cmd [StandAloneCommand $cmd]
		if {[llength $cmd] <= 0} {
			set badcmd 1
			return ""
		}
	}
	if {($pprg == $evv(MOD_RADICAL)) && ($mmod == [expr $evv(MOD_SCRUB) + 1])} {
		if {![NewVersion $pprg]} {
			set cmd [RemoveNewFlags $cmd]
		}
	}
	return $cmd
}

#------ Allows processes to run as modes to 'wrong' program : NO crypto modes allowed in Instruments

#---- Remove new cmdline flags, if user running old version of program

proc RemoveNewFlags {cmd} {
	global prg_version_number evv
	set n 0 
	set entry [lindex $cmd end]
	if {[string match $entry "$evv(NUM_MARK)1"]} {
		Inf "Single Scrub Option Not Available In version $prg_version_number Of 'modify'"
	}
	set cmd [lreplace $cmd end end]
	return $cmd
}

#------ Check for new version of program

proc NewVersion {thisprg} {
	global prg_dun prg_abortd CDPidrun prg_version_number evv prg
	catch {unset prg_version_number}
	set vercmd [file join $evv(CDPROGRAM_DIR) [lindex $prg($thisprg) $evv(UMBREL_INDX)]]
	lappend vercmd "--version"
	set prg_dun 0
	set prg_abortd 0
	if [catch {open "|$vercmd"} CDPidrun] {
		set msg "Cannot Get Program Version Number: $CDPidrun\n"
		append msg "\n\nIgnoring Single-Scrub Flag"
		Inf $msg
		catch {unset CDPidrun}
		return 0
	} else {
		fileevent $CDPidrun readable "Extract_Version_Number"
	}
	vwait prg_dun
	if {$prg_abortd} {
		set prg_dun 0
	}
	if {!$prg_dun} {
		Inf "Failed To Get Program Version Number: Ignoring Single-Scrub Flag"
		return 0
	}
	if {![info exists prg_version_number]} {
		Inf "Failed To Get Program Version Number: Ignoring Single-Scrub Flag"
		return 0
	}
	set prg_version_number [string index $prg_version_number 0]
	if {$prg_version_number <= 6} {
		return 0
	}
	return 1
}

#------ Display info returned by running-program in the the program-running display

proc Extract_Version_Number {} {
	global running CDPidrun prg_dun prg_abortd prg_version_number

	if [eof $CDPidrun] {
		set prg_dun 1
		catch {close $CDPidrun}
		return
	}
	gets $CDPidrun line
	set line [string trim $line]
	if {[string length $line] <= 0} {
		return
	}
	if {[regexp {^[0-9]$} [string index $line 0]]} {
		set prg_version_number $line
		set prg_dun 1
		catch {close $CDPidrun}
		return
	} elseif [string match ERROR:* $line] {
		set prg_dun 0
		set prg_abortd 1
		return
	} elseif [string match END:* $line] {
		set prg_dun 1
		return
	}
	update idletasks
}			

#------ Allows processes to run as modes to 'wrong' program : NO crypto modes allowed in Instruments

proc HandleCryptoModes {} {
	global pprg mmod evv
	
	set is_cryp 0
	set mmode $mmod
	incr mmode -1		   ;#	Change gui representation to internal representation

	switch -regexp -- $pprg \
		^$evv(ENV_EXTRACT)$ {
			if {$mmode == $evv(ENV_EXTRACT_CRYPTO)} {
				set pprg $evv(HOUSE_EXTRACT)
				set mmod $evv(HOUSE_CUTGATE_PREVIEW)
				incr mmod  ;#	Change internal representation to gui representation
				set is_cryp 1
			}
		} \
		^$evv(TWIXT)$ {
			if {$mmode == $evv(TWIXT_ONSETS_CRYPTO)} {
				set pprg $evv(HOUSE_EXTRACT)
				set mmod $evv(HOUSE_ONSETS)
				incr mmod  ;#	Change internal representation to gui representation
				set is_cryp 1
			} elseif {$mmode == $evv(TWIXT_PREVIEW_CRYPTO)} {
				set pprg $evv(HOUSE_EXTRACT)
				set mmod $evv(HOUSE_CUTGATE_PREVIEW)
				incr mmod  ;#	Change internal representation to gui representation
				set is_cryp 1
			}
		} \
		^$evv(MOD_LOUDNESS)$ {
			if {$mmode == $evv(MOD_LOUDNESS_FRQ_CRYPTO)} {
				set pprg $evv(ENV_TREMOL)
				set mmod $evv(ENV_TREM_LIN)
				incr mmod  ;#	Change internal representation to gui representation
				set is_cryp 1
			} elseif {$mmode == $evv(MOD_LOUDNESS_PCH_CRYPTO)} {
				set pprg $evv(ENV_TREMOL)
				set mmod $evv(ENV_TREM_LOG)
				incr mmod  ;#	Change internal representation to gui representation
				set is_cryp 1
			}
		} \
		^$evv(ENV_CONTOUR)$ {
			set pprg $evv(MOD_LOUDNESS)
			set mmod $evv(LOUDNESS_GAIN)
			incr mmod  ;#	Change internal representation to gui representation
			set is_cryp 1
		}

	return $is_cryp
}

#------ Mark values which are numeric with an extra prefixed '@', for cpdmain decoding

proc MarkNumericVals {pcnt} {
	global param_is_numeric prm evv

	if {$param_is_numeric($pcnt)} {					;#	Numeric values preceded by '@'
		set val $evv(NUM_MARK)
		append val $prm($pcnt)
	} else {
		set val $prm($pcnt)
	}
	return $val
}

#------ On quitting Parampage, or on rerunning program from current page, delete temporary files
#	to avoid any future miscounting!!
#
#RWD 2023 below, added -force as per 17.0.6
proc DeleteTemporaryFiles {} {
	global o_nam	ins src evv

	set fnams [glob -nocomplain "$o_nam*"]
	if {[llength $fnams] > 0} {
		foreach fnam $fnams {
			file stat $fnam filestatus
			if {$filestatus(ino) >= 0} {
				catch {close $filestatus(ino)}
			}
			if [catch {file delete -force $fnam} result] {
				ErrShow "Cannot delete temporary file $fnam"
				return 0
			}
			DeleteFileFromSrcLists $fnam
			PurgeArray $fnam							;#	And remove associated data
		}
	}														;#	Delete any other tempfiles 
	if {$ins(create)} {									;#	from exceptional processes in ins
		set fnams [glob -nocomplain $evv(DFLT_OUTNAME)*]
		if {[llength $fnams] > 0} {
			foreach fnam $fnams {
				file stat $fnam filestatus
				if {$filestatus(ino) >= 0} {
					catch {close $filestatus(ino)}
				}

				if [catch {file delete -force $fnam} result] {
					ErrShow "Cannot delete temporary file $fnam"
					return 0
				}
				DeleteFileFromSrcLists $fnam
				PurgeArray $fnam
			}
		}
	}					
	PurgeTempThumbnails					
	return 1
}

#------ On quitting Parampage, or on rerunning program from current page, delete temporary files
#	to avoid any future miscounting!!
#

proc DeleteAllTemporaryFiles {} {
	global ins src evv

	set returnval 1
	set i 0
	while {$i < 2} {
		switch -- $i {
			"0" {set outfname $evv(DFLT_OUTNAME) }
			"1" {set outfname $evv(MACH_OUTFNAME) }
		}
		set fnams [glob -nocomplain "$outfname*"]
		if {[llength $fnams] > 0} {
			foreach fnam $fnams {
				file stat $fnam filestatus
				if {$filestatus(ino) >= 0} {
					catch {close $filestatus(ino)}
				}
				if [catch {file delete -force $fnam} result] {
					ErrShow "Cannot delete temporary file $fnam"
					set returnval 0
				}
				DeleteFileFromSrcLists $fnam
				PurgeArray $fnam
			}
		}
		incr i
	}
	return $returnval
}

#------ Have the parameters in dialog-box been changed from last time

proc ParamsChanged {} {
	global pmcnt prm pstore
	global range_changed

	set i 0
	if {![info exists pstore] || ([array size pstore] != $pmcnt)} {
		return 1
	}
	while {$i < $pmcnt} {
  		if {![string match $prm($i) $pstore($i)] || $range_changed($i)} {
			return 1
		}
		incr i
	}
	return 0
}

#------ Check that params entered are valid

proc ParamsOK {} {
	global prm pmcnt gdg_cnt gdg_typeflag param_is_numeric prmgrd parname pprg evv ismS
	set gcnt 0			 								;#	entry-gadget counter
	set pcnt 0											;#	prm counter
	while {$gcnt < $gdg_cnt} {
		if {[IsDeadParam $gcnt]} {
			incr gcnt
			incr pcnt
			continue
		}
		set par_name [StripName $parname($gcnt)]
		if {$gdg_typeflag($gcnt) == $evv(SWITCHED)} { ;#	First SWITCHED-gadget prm='checkbtn': need not be tested 
			set param_is_numeric($pcnt) 1
			incr pcnt									 ;#	Go to other SWITCHED-gadget prm, and remove space
			if {$pcnt >= $pmcnt} {
				ErrShow "Error in parameter arithmetic in ParamsOK"
				return 0
			}
		}
		set param_is_numeric($pcnt) 0
												#	radio-buttons & checkbuttons: no range tests required
		switch -regexp -- $gdg_typeflag($gcnt) \
			^$evv(TIMETYPE)$ 	- \
			^$evv(SRATE_GADGET)$ - \
			^$evv(MIDI_GADGET)$ - \
			^$evv(OCT_GADGET)$ - \
			^$evv(CHORD_GADGET)$ - \
			^$evv(DENSE_GADGET)$ - \
			^$evv(TWOFAC)$ 		- \
			^$evv(WAVETYPE)$    - \
			^$evv(CHECKBUTTON)$ {set param_is_numeric($pcnt) 1} \
			^$evv(LINEAR)$ 		- \
			^$evv(LOG)$ 		- \
			^$evv(PLOG)$ 		- \
			^$evv(FILE_OR_VAL)$ - \
			^$evv(SWITCHED)$ {
#JUNE 30 UC-LC FIX
				set prm($pcnt) [string tolower $prm($pcnt)]
#JULY2020 BIZARRRE BUG IN TCL/TK, WHICH RECOGNISES "*" AS "~"
				if {[string match [string index $prm($pcnt) 0] "~"] && ![string match [string index $prm($pcnt) 0] "*"]} {
					set val [ConvertToFreq $prm($pcnt)]
					if {[string length $val] > 0} {
						set prm($pcnt) $val
					} else {
						set msg "INVALID NOTE-NAME\n\n"
						append msg "SYNTAX IS:  ~  Letter  {\# or b}  Octave  {u or d}\n"
						append msg "Items in curly brackets {} are optional.\n"
						append msg "Octave Range is -5 to 5.\n\n"
						append msg "e.g. C2, F#-2u"
						Inf $msg
					}
				}				
				set prm($pcnt) [RegulariseEnteredParamText $prm($pcnt) "parameter $par_name" $gdg_typeflag($gcnt) $pcnt $gcnt]
				ForceVal $prmgrd.e$gcnt $prm($pcnt)
				if {[string length $prm($pcnt)] <= 0} {
					return 0
				}
				set checkms 0
				if {$gdg_typeflag($gcnt) == $evv(LINEAR)} {
					set checkms 1
				}
				if [IsNumericOrE $prm($pcnt) $checkms] {
					if {[info exists ismS]} {
						set prm($pcnt) [ConvertFromMsecs $prm($pcnt)]
						unset ismS
					}
					if {![IsInRange $pcnt $gcnt]} {
						return 0
					}
					set param_is_numeric($pcnt) 1
				} else {
					if {$gdg_typeflag($gcnt) == $evv(SWITCHED) || $gdg_typeflag($gcnt) == $evv(POWTWO)} {
						Inf "Parameter $par_name must be numeric"
						set prm($pcnt) ""
						ForceVal $prmgrd.e$gcnt $prm($pcnt)
						return 0
					}
					if {![file exists $prm($pcnt)]} {
						Inf "File $prm($pcnt) is not in the working directory"
						return 0
					} 
					if {$gdg_typeflag($gcnt) != $evv(FILE_OR_VAL)} {
						if {![FilevalIsInRange $pcnt $gcnt]} {
							return 0
						}
					}
				}					  	
			} \
			^$evv(POWTWO)$  {
				set prm($pcnt) [RegulariseEnteredParamText $prm($pcnt) "parameter $par_name" $gdg_typeflag($gcnt) $pcnt $gcnt]
				ForceVal $prmgrd.e$gcnt $prm($pcnt)
				if {[string length $prm($pcnt)] <= 0} {
					return 0
				}
				if [IsNumeric $prm($pcnt)] {
					if {![IsInRange $pcnt $gcnt]} {
						return 0
					}
					set prm($pcnt) [expr round($prm($pcnt))]
					set prm($pcnt) [expr $prm($pcnt) + ($prm($pcnt) % 2)]		;#	Force PVOC to be even
					set param_is_numeric($pcnt) 1
					ForceVal $prmgrd.e$gcnt $prm($pcnt)
				} else {
					Inf "Numeric values only for parameter $par_name"
					set prm($pcnt) ""
					ForceVal $prmgrd.e$gcnt $prm($pcnt)
					return 0
				}
			} \
			^$evv(LOGNUMERIC)$ - \
			^$evv(NUMERIC)$ {
				set prm($pcnt) [RegulariseEnteredParamText $prm($pcnt) "parameter $par_name" $gdg_typeflag($gcnt) $pcnt $gcnt]
				ForceVal $prmgrd.e$gcnt $prm($pcnt)
				if {[string length $prm($pcnt)] <= 0} {
					return 0
				}
				set checkms 0
				if {$gdg_typeflag($gcnt) == $evv(NUMERIC)} {
					set checkms 1
				}
				if [IsNumericOrE $prm($pcnt) $checkms] {
					if {[info exists ismS]} {
						set prm($pcnt) [ConvertFromMsecs $prm($pcnt)]
						unset ismS
					}
					if {![IsInRange $pcnt $gcnt]} {
						return 0
					}
					set param_is_numeric($pcnt) 1
				} else {
					Inf "Numeric values only for parameter $par_name"
					set prm($pcnt) ""
					ForceVal $prmgrd.e$gcnt $prm($pcnt)
					return 0
				}
			} \
			^$evv(GENERICNAME)$ {
#JUNE 30 UC-LC FIX
				set prm($pcnt) [string tolower $prm($pcnt)]
				set prm($pcnt) [RegulariseEnteredParamText $prm($pcnt) "parameter $par_name" $gdg_typeflag($gcnt) $pcnt $gcnt]
				ForceVal $prmgrd.e$gcnt $prm($pcnt)
				if {[string length $prm($pcnt)] <= 0} {
					return 0
				}
				if {![ValidCDPRootname $prm($pcnt)]} { 
					set prm($pcnt) ""
					ForceVal $prmgrd.e$gcnt $prm($pcnt)
					return 0
				} else {
					set prm($pcnt) [file rootname $prm($pcnt)]
				}
			} \
			^$evv(FILENAME)$ {
				set prm($pcnt) [string tolower $prm($pcnt)]
				set prm($pcnt) [RegulariseEnteredParamText $prm($pcnt) "parameter $par_name" $gdg_typeflag($gcnt) $pcnt $gcnt]
				ForceVal $prmgrd.e$gcnt $prm($pcnt)
				if {[string length $prm($pcnt)] <= 0} {
					return 0
				}
				if {($pprg == $evv(P_INVERT)) && [string match $prm($pcnt) "0"]} {
					;# DO NOTHING, IT'S OK!!
				} elseif {![file exists $prm($pcnt)] || [file isdirectory $prm($pcnt)]} { 
					set prm($pcnt) ""
					ForceVal $prmgrd.e$gcnt $prm($pcnt)
					return 0
				}
			} \
			^$evv(VOWELS)$ {
				set prm($pcnt) [string tolower $prm($pcnt)]
				set prm($pcnt) [RegulariseEnteredParamText $prm($pcnt) "parameter $par_name" $gdg_typeflag($gcnt) $pcnt $gcnt]
				ForceVal $prmgrd.e$gcnt $prm($pcnt)
				if {[string length $prm($pcnt)] <= 0} {
					return 0
				} 
				if {![ValidVowelName $prm($pcnt)]} {
					if {![file exists $prm($pcnt)] || [file isdirectory $prm($pcnt)]} { 
						set prm($pcnt) ""
						ForceVal $prmgrd.e$gcnt $prm($pcnt)
						return 0
					}
				}
			} \
			^$evv(STRING_A)$ {
				set prm($pcnt) [RegulariseEnteredParamText $prm($pcnt) "parameter $par_name" $gdg_typeflag($gcnt) $pcnt $gcnt]
				ForceVal $prmgrd.e$gcnt $prm($pcnt)
				if {[string length $prm($pcnt)] <= 0} {
					return 0
				}
				if {![ValidStringA $prm($pcnt) $gcnt]} {
					return 0
				}
			} \
			^$evv(STRING_B)$ {
				set prm($pcnt) [RegulariseEnteredParamText $prm($pcnt) "parameter $par_name" $gdg_typeflag($gcnt) $pcnt $gcnt]
				ForceVal $prmgrd.e$gcnt $prm($pcnt)
				if {[string length $prm($pcnt)] <= 0} {
					return 0
				}
				if {![ValidStringB $prm($pcnt) $gcnt] } {
					return 0
				}
			} \
			^$evv(STRING_C)$ {
				set prm($pcnt) [RegulariseEnteredParamText $prm($pcnt) "parameter $par_name" $gdg_typeflag($gcnt) $pcnt $gcnt]
				ForceVal $prmgrd.e$gcnt $prm($pcnt)
				if {[string length $prm($pcnt)] <= 0} {
					return 0
				}
				if {![ValidStringC $prm($pcnt) $gcnt]} {
					return 0
				}
			} \
			^$evv(STRING_D)$ {
				set prm($pcnt) [RegulariseEnteredParamText $prm($pcnt) "parameter $par_name" $gdg_typeflag($gcnt) $pcnt $gcnt]
				ForceVal $prmgrd.e$gcnt $prm($pcnt)
				if {[string length $prm($pcnt)] <= 0} {
					return 0
				}
				if {![ValidStringD $prm($pcnt) $gcnt]} {
					return 0
				}
			} \
			^$evv(STRING_E)$ {
				set prm($pcnt) [RegulariseEnteredParamText $prm($pcnt) "parameter $par_name" $gdg_typeflag($gcnt) $pcnt $gcnt]
				ForceVal $prmgrd.e$gcnt $prm($pcnt)
				if {[string length $prm($pcnt)] <= 0} {
					return 0
				}
				if {![ValidStringE $prm($pcnt) $gcnt]} {
					return 0
				}
			}
					
		incr pcnt						;#	Next parameter
		incr gcnt						;#	Next gadget
	}
	CheckCurrentPatchDisplay
	return 1
}

#------ Disable other action buttons while program is runnung

proc DisableRunAndOtherActionButtons {fpr} {
	global ppg_emph saved_ppg_emph evv
  	$fpr.output.run config -state disabled -bg [option get . background {}]
	set saved_ppg_emph $ppg_emph
	catch {unset ppg_emph}
 	$fpr.buttons.reset config -state disabled
 	$fpr.buttons.dflt  config -state disabled
 	$fpr.buttons.orig  config -state disabled
 	$fpr.zzz.newp	   config -state disabled
 	$fpr.zzz.newf	   config -state disabled
}

#------ Enable other action buttons once program is completed or aborted

proc EnableRunAndOtherActionButtons {fpr} {
	global ppg_emph saved_ppg_emph ins evv

	set ppg_emph $saved_ppg_emph
	foreach item $ppg_emph {
		$item config -bg $evv(EMPH)
	}
 	$fpr.output.run    config -state normal -bg $evv(EMPH)
 	$fpr.buttons.reset config -state normal
 	$fpr.buttons.dflt  config -state normal
	if {$ins(run)} {
	 	$fpr.buttons.orig  config -state normal
	}
 	$fpr.zzz.newp     config -state normal
 	$fpr.zzz.newf     config -state normal
}

#------ If parameters used are different from (loaded) current patch, clear current-patch display

proc CheckCurrentPatchDisplay {} {
	global pmcnt prm cur_patch cur_patch_display
		
	if [info exists cur_patch] {
		set zap 0
		set i 0
		while {$i < $pmcnt} {
			set patch_item [lindex $cur_patch $i]
			if {[IsNumeric $prm($i)] && [IsNumeric $patch_item]} {
				if {$prm($i) != $patch_item} {
					set zap 1
				}
			} elseif {![string match $prm($i) $patch_item]} {
				set zap 1
			}
			if {$zap} {
				set cur_patch_display ""
				catch {unset cur_patch}
				return
			}
			incr i
		}
	}
}

#------ If parameters used are different from (loaded) current patch, clear current-patch display

proc CheckCrypto {} {
	global pprg mmod is_crypto evv
	set mmode [expr $mmod - 1]
	if {$is_crypto} {
		if {($pprg == $evv(HOUSE_EXTRACT)) \
		&& (($mmode == $evv(HOUSE_ONSETS)) ||  ($mmode == $evv(HOUSE_CUTGATE_PREVIEW)))} {
			return 1
		}
	}
	return 0
}

#---- 

proc TwoSigFig {val} {
	set val [expr int(floor($val * 100.0))]
	set val [expr $val / 100.0]
	return $val
}

#------- Attenate Texture

proc TextureAtten {} {
	global prm pprg texoverload papag evv texture_version

	switch -regexp -- $pprg \
		^$evv(SIMPLE_TEX)$ {
			if {$texture_version > 7} {
				set paramno 14
				set total_params 20
			} else {
				set paramno 13
				set total_params 19
			}
		 } \
		^$evv(TEX_MCHAN)$ {
			set paramno 14
			set total_params 20
		 } \
		^$evv(GROUPS)$		{
			set paramno 24
			set total_params 30
		 } \
		^$evv(DECORATED)$	- \
		^$evv(PREDECOR)$	- \
		^$evv(POSTDECOR)$	{
			set paramno 21
			set total_params 31
		 } \
		^$evv(ORNATE)$		- \
		^$evv(PREORNATE)$	- \
		^$evv(POSTORNATE)$	{
			set paramno 16
			set total_params 25
		 } \
		^$evv(MOTIFS)$ {
			set paramno 20
			set total_params 26
		 } \
		^$evv(MOTIFSIN)$	{
			set paramno 20
			set total_params 27
		 } \
		^$evv(TIMED)$		{
			set paramno 11
			set total_params 15
		 } \
		^$evv(TGROUPS)$		{
			set paramno 22
			set total_params 29
		 } \
		^$evv(TMOTIFS)$		{
			set paramno 18
			set total_params 24
		 } \
		^$evv(TMOTIFSIN)$ 	{
			set paramno 16
			set total_params 22
		 }

	if {![IsNumeric $prm($paramno)]} {
		return
	}
	set texoverload [expr (floor($texoverload * 100.0))/100.0]
	set prm($paramno) [expr $prm($paramno) * $texoverload]
	ResetScale $paramno linear
	set k [expr double($paramno + 1)/double($total_params)]
	$papag.parameters.par.c yview moveto $k 
}

#--- Get correct outfile extension to send to program
#--- This ensures that if outfile is sndsys, it gets correct format (wav, aiff)
#--- But if it isn't, it also gets correct format (i.e. it doesNOt get e.g. ".wav.txt" instead of ".txt"

proc GetProcessOutfileExtension {pprg mmod} {
	global evv

	incr mmod -1
	set ext $evv(SNDFILE_EXT)	;# default = sndfile-type (.wav or .aiff) set as default by user

# HEREH JAN 25 2023
#	entries inserted at head of switch here to ensures any program with an ANAL ouput
#	gets $evv(ANALFILE_EXT), so it will get either ".ana" or ".pvx"

	switch -regexp -- $pprg \
		^$evv(AVRG)$		- \
		^$evv(BLUR)$		- \
		^$evv(SUPR)$		- \
		^$evv(CHORUS)$		- \
		^$evv(DRUNK)$		- \
		^$evv(SHUFFLE)$		- \
		^$evv(WEAVE)$		- \
		^$evv(NOISE)$		- \
		^$evv(SCAT)$		- \
		^$evv(SPREAD)$		- \
		^$evv(MAKE)$		- \
		^$evv(MAKE2)$		- \
		^$evv(SUM)$			- \
		^$evv(DIFF)$		- \
		^$evv(LEAF)$		- \
		^$evv(MAX)$			- \
		^$evv(MEAN)$		- \
		^$evv(CROSS)$		- \
		^$evv(ACCU)$		- \
		^$evv(EXAG)$		- \
		^$evv(FOCUS)$		- \
		^$evv(FOLD)$		- \
		^$evv(FREEZE)$		- \
		^$evv(FREEZE2)$		- \
		^$evv(STEP)$		- \
		^$evv(FORM)$		- \
		^$evv(VOCODE)$		- \
		^$evv(FILT)$		- \
		^$evv(VFILT)$		- \
		^$evv(GREQ)$		- \
		^$evv(SPLIT)$		- \
		^$evv(ARPE)$		- \
		^$evv(PLUCK)$		- \
		^$evv(S_TRACE)$		- \
		^$evv(BLTR)$		- \
		^$evv(LUCIER_GET)$	- \
		^$evv(LUCIER_PUT)$	- \
		^$evv(LUCIER_DEL)$	- \
		^$evv(GLIDE)$		- \
		^$evv(BRIDGE)$		- \
		^$evv(MORPH)$		- \
		^$evv(ALT)$			- \
		^$evv(OCT)$			- \
		^$evv(SHIFTP)$		- \
		^$evv(TUNE)$		- \
		^$evv(PICK)$		- \
		^$evv(MULTRANS)$	- \
		^$evv(CHORD)$		- \
		^$evv(P_HEAR)$		- \
		^$evv(PVOC_ANAL)$	- \
		^$evv(PITCH)$		- \
		^$evv(TRACK)$		- \
		^$evv(P_SYNTH)$		- \
		^$evv(P_VOWELS)$	- \
		^$evv(TRNSP)$		- \
		^$evv(TRNSF)$		- \
		^$evv(GLISTEN)$		- \
		^$evv(FRACSPEC)$	- \
		^$evv(SPECMORPH)$	- \
		^$evv(SPECTWIN)$	- \
		^$evv(SELFSIM)$		- \
		^$evv(SPECSPHINX)$	- \
		^$evv(SPECGRIDS)$	- \
		^$evv(SPECFOLD)$	- \
		^$evv(SUPERACCU)$	- \
		^$evv(TUNEVARY)$	- \
		^$evv(GAIN)$		- \
		^$evv(LIMIT)$		- \
		^$evv(BARE)$		- \
		^$evv(CLEAN)$		- \
		^$evv(CUT)$			- \
		^$evv(GRAB)$		- \
		^$evv(MAGNIFY)$		- \
		^$evv(ANALJOIN)$	- \
		^$evv(CALTRAIN)$	- \
		^$evv(ONEFORM_PUT)$	- \
		^$evv(ONEFORM_COMBINE)$	- \
		^$evv(SPECULATE)$	- \
		^$evv(SPEC_REMOVE)$	- \
		^$evv(SPECTRACT)$	- \
		^$evv(SPECLEAN)$	- \
		^$evv(SPECSLICE)$	- \
		^$evv(SPECRAND)$	- \
		^$evv(SPECSQZ)$		- \
		^$evv(SPECEX)$		- \
		^$evv(SPECROSS)$	- \
		^$evv(SPECENV)$		- \
		^$evv(SUPPRESS)$	- \
		^$evv(SHIFT)$		- \
		^$evv(GLIS)$		- \
		^$evv(WAVER)$		- \
		^$evv(WARP)$		- \
		^$evv(INVERT)$		- \
		^$evv(STRETCH)$	{
			set ext $evv(ANALFILE_OUT_EXT)
		} \
		^$evv(SPECMORPH2)$	{
			if {$mmod == 1} {
				set ext $evv(ANALFILE_OUT_EXT)
			}
		} \
		^$evv(SPECANAL)$	{
			if {$mmod == 0} {
				set ext $evv(ANALFILE_OUT_EXT)
			}
		} \
		^$evv(PVOC_ANAL)$	{
			if {$mmod == 0} {
				set ext $evv(ANALFILE_OUT_EXT)
			}
		} \
		^$evv(SPECTUNE)$	{
			if {($mmod != 3) && ($mmod != 5)} {
				set ext $evv(ANALFILE__OUT_EXT)
			}
		} \
		^$evv(SPECFNU)$	{
			if {($mmod != 6) && ($mmod != 19) && ($mmod != 20) && ($mmod != 21)} {
				set ext $evv(ANALFILE_OUT_EXT)
			}
		} \
		^$evv(TSTRETCH)$	{
			if {$mmod == 0} {
				set ext $evv(ANALFILE_OUT_EXT)
			}
		} \
		^$evv(HOUSE_COPY)$	{
			if {$mmod == 0} {
				set ext ""
			}
		} \
		^$evv(INFO_PROPS)$		- \
		^$evv(INFO_SFLEN)$		- \
		^$evv(INFO_TIMESUM)$	- \
		^$evv(INFO_TIMEDIFF)$	- \
		^$evv(INFO_SAMPTOTIME)$ - \
		^$evv(INFO_TIMETOSAMP)$ - \
		^$evv(INFO_MAXSAMP)$	- \
		^$evv(INFO_MAXSAMP2)$	- \
		^$evv(INFO_LOUDCHAN)$	- \
		^$evv(INFO_FINDHOLE)$	- \
		^$evv(INFO_DIFF)$		- \
		^$evv(INFO_CDIFF)$		- \
		^$evv(INFO_MUSUNITS)$	- \
		^$evv(WINDOWCNT)$		- \
		^$evv(CHANNEL)$			- \
		^$evv(FREQUENCY)$		- \
		^$evv(HOUSE_SORT)$		- \
		^$evv(REPITCHB)$		- \
		^$evv(ENV_REPLOTTING)$	- \
		^$evv(ENV_DBBRKTOBRK)$	- \
		^$evv(ENV_BRKTODBBRK)$	- \
		^$evv(ENV_ENVTOBRK)$	- \
		^$evv(ENV_ENVTODBBRK)$	- \
		^$evv(FLTBANKC)$		- \
		^$evv(MAKE_VFILT)$		- \
		^$evv(GRAIN_GET)$		- \
		^$evv(HOUSE_COPY)$		- \
		^$evv(HOUSE_BUNDLE)$	- \
		^$evv(SIN_TAB)$			- \
		^$evv(P_WRITE)$			- \
		^$evv(INFO_TIMELIST)$	- \
		^$evv(INFO_PRNTSND)$	- \
		^$evv(INFO_LOUDLIST)$	- \
		^$evv(OCTVU)$			- \
		^$evv(PEAK)$			- \
		^$evv(REPORT)$			- \
		^$evv(PRINT)$			- \
		^$evv(HOUSE_RECOVER)$	- \
		^$evv(MIXDUMMY)$		- \
		^$evv(MULTIMIX)$		- \
		^$evv(ADDTOMIX)$		- \
		^$evv(MIX_ON_GRID)$		- \
		^$evv(MIXSYNC)$			- \
		^$evv(MIXSYNCATT)$		- \
		^$evv(MIXTWARP)$		- \
		^$evv(MIXSWARP)$		- \
		^$evv(MIX_PAN)$			- \
		^$evv(MIX_AT_STEP)$		- \
		^$evv(MIXGAIN)$			- \
		^$evv(MIXMAX)$			- \
		^$evv(BATCH_EXPAND)$	- \
		^$evv(MIX_MODEL)$		- \
		^$evv(P_BINTOBRK)$		- \
		^$evv(PTOBRK)$			- \
		^$evv(PARTIALS_HARM)$	- \
		^$evv(MIXSHUFL)$		- \
		^$evv(LUCIER_GETF)$		- \
		^$evv(PEAKFIND)$		- \
		^$evv(SETHARES)$		- \
		^$evv(RMRESP)$ {
			set ext ""
		} \
		^$evv(HF_PERM1)$ - \
		^$evv(HF_PERM2)$ {
			if {($mmod == $evv(HFP_TEXTOUT)) || ($mmod == $evv(HFP_MIDIOUT))} {
				set ext ""
			}
		} \
		^$evv(ENV_CREATE)$ {
			if {$mmod == $evv(ENV_BRKFILE_OUT)} {
				set ext ""
			}
		} \
		^$evv(ENV_EXTRACT)$ {
			if {$mmod == $evv(ENV_BRKFILE_OUT)} {
				set ext ""
			}
		} \
		^$evv(HOUSE_EXTRACT)$ {
			if {$mmod == $evv(HOUSE_ONSETS)} {
				set ext ""
			}
		} \
		^$evv(MOD_SPACE)$ {
			if {$mmod == $evv(MOD_MIRRORPAN)} {
				set ext ""
			}
		} \
		^$evv(MOD_LOUDNESS)$ {
			if {$mmod == $evv(LOUDNESS_LOUDEST)} {
				set ext ""
			}
		} \
		^$evv(TSTRETCH)$ {
			if {$mmod == $evv(TSTR_LENGTH)} {
				set ext ""
			}
		} \
		^$evv(GREV)$ {
			if {$mmod == $evv(GREV_GET)} {
				set ext ""
			}
		} \
		^$evv(RETIME)$ {
			if {$mmod == 11} {
				set ext $evv(TEXT_EXT)
			}
		} \
		^$evv(SPEKLINE)$ {
			if {$mmod == 1} {
				set ext $evv(TEXT_EXT)
			}
		}

	return $ext
}

proc TrapBadStackCount {} {
	global prm evv
	if {[file exists $prm(0)]} {
		set stackcnt 0
		if {![catch {open $prm(0) "r"} zit]} {
			while {[gets $zit line] >= 0} {
				set line [string trim $line]
				set line [split $line]
				foreach item $line {
					if {([string length $item] > 0) && [IsNumeric $item]} {
						incr stackcnt
					}
				}
			}
			close $zit
			if {$stackcnt != $prm(1)} {
				set prm(1) $stackcnt
			}
		}
	}
}

#KLUDGE FIX FOR "sfedit cutmany"

proc IsCutMany {cmd} {
	global prg evv
	if {([string first [lindex $prg($evv(EDIT_CUTMANY)) 0] [lindex $cmd 0]] > 0) && [string match [lindex $cmd 1] $evv(EDIT_CUTMANY)]} {
		return 1
	}
	return 0
}

proc RunCutManyBatch {cmd rpd} {
	global CDPidrun prg_dun prg_abortd program_messages pa evv

	set newcmd [lindex $cmd 0]
	lappend newcmd "cut"
	set mode [lindex $cmd 2]
	lappend newcmd $mode

	set len [llength $cmd]

	set ifil_indx $len
	incr ifil_indx -4
	set ifil [lindex $cmd $ifil_indx]
	lappend newcmd $ifil

	set ofil_indx $len
	incr ofil_indx -3
	set ofil [lindex $cmd $ofil_indx]

	set excise_indx $len
	incr excise_indx -2
	set excises [lindex $cmd $excise_indx]

	set edit_indx $len
	incr edit_indx -1
	set orig_edit [string range [lindex $cmd $edit_indx] 1 end]
	set edit "-w"
	append edit $orig_edit

	set ext [file extension $ofil]
	set ofil [file rootname $ofil]
	set olen [string length $ofil]
	incr olen -2
	set ofil [string range $ofil 0 $olen]

	switch -- $mode {
		1 { set durlim $pa($ifil,$evv(DUR))}
		2 { set durlim $pa($ifil,$evv(INSAMS))}
		3 { set durlim [expr $pa($ifil,$evv(INSAMS))/$pa($ifil,$evv(CHANS))] }
	}
	set mindur [expr double($orig_edit) * $evv(MS_TO_SECS) * 2.0]

	if [catch {open $excises "r"} zit] {
		Inf "Cannot Open File '$excises' To Read Data"
		return
	}
	set cnt 0
	set outcnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		set line [split $line]
		foreach item $line {
			string trim $item
			if {[string length $item] <= 0} {
				continue
			}
			if {$cnt} {
				set endcut $item
			} else {
				set startcut $item
			}
			incr cnt
			if {$cnt==2} {
				set OK 0
				if {$startcut < $durlim} {
					set OK 1
					if {$endcut > $durlim} {
						set endcut $durlim
					}
					set cutlen [expr $endcut - $startcut]
					switch -- $mode {
						1 {}
						2 { set cutlen [expr double($cutlen) / double($pa($ifil,$evv(CHANS)) * $pa($ifil,$evv(SRATE)))] }
						3 { set cutlen [expr double($cutlen) / double($pa($ifil,$evv(SRATE)))] }
					}
					if {$cutlen <= $mindur} {		
						Inf "Edit $startcut To $endcut Too Short For Splices"
						close $zit
						return 0
					}
				}
				if {$OK} {
					catch {unset outcmd}
					set outcmd $newcmd
					set thisofil $ofil
					append thisofil $outcnt $ext
					lappend outcmd $thisofil $startcut $endcut $edit
					lappend batchfile $outcmd
					incr outcnt
				}
				set cnt 0
			}
		}
	}
	close $zit
	if {![info exists batchfile]} {
		Inf "No Data Found In Cuts File"
		return 0
	}
	set msg [lindex $batchfile 0]
	foreach line [lrange $batchfile 1 end] {
		append msg "\n" $line
	}
	set cnt 1
	set program_messages 0
	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	set returnval 1
	.running.t.ok config -state disabled -bg [option get . background {}]
	foreach cmd $batchfile {
		set line "Doing cut $cnt\n"
		.running.i.info insert end $line
		set program_messages 1
		if [catch {open "|$cmd"} CDPidrun] {
			set line "$CDPidrun : Can't Run Editing Process $cnt\n"
			.running.i.info insert end $line {error}
			set program_messages 1
			break
	   	} else {
	   		fileevent $CDPidrun readable "Display_Running_Program_Info $rpd 0"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			set line "Edit $cnt Failed\n"
			.running.i.info insert end $line {error}
			set program_messages 1
			break
		}
		incr cnt
	}
	.running.i.info yview moveto 1.0
	catch {.running.t.ok config -text "OK" -command "RunOK" -state normal -bg $evv(EMPH)}
}

proc IsDeadParam {pno} {
	global pprg mmod pcnt evv
	if {$pno == 12}  {
		if {($pprg == $evv(BRASSAGE)) && ($mmod == 6)} {
			return 1
		}
	} elseif {$pno == 20} {
		if {(($pprg == $evv(BRASSAGE)) && ($mmod == 7)) \
		||  (($pprg == $evv(SAUSAGE)) && ($mmod == 0))} {
			return 1
		}
	}
	return 0
}

#----- Check for files with level above normalisation level, for Bulk processing.

proc TooLoudFilesToBulkNorm {val} {
	global chlist ch chcnt CDPmaxId done_maxsamp maxsamp_line checked_bulknorm_level wstk pa evv
	Block "Checking max samples"
	set maxlevel 0
	foreach fnam $chlist {
		set done_maxsamp 0
		catch {unset maxsamp_line}
		catch {unset CDPmaxId}
		set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
		lappend cmd $fnam 1
		if [catch {open "|$cmd"} CDPmaxId] {
			ErrShow "$CDPmaxId"
			My_Release_to_Dialog $f
			Dlg_Dismiss $f
			return
	   	} else {
			wm title .blocker   "PLEASE WAIT :      CALCULATING MAX LEVEL OF '$fnam'"
	   		fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
		}
	 	vwait done_maxsamp
		if {[info exists maxsamp_line]} {
			set thismax [lindex $maxsamp_line 0]
			if {$thismax >= $val} {
				lappend badfiles $fnam
				if {$thismax >= $maxlevel} {
					set maxlevel $thismax
				}
			}
		}
	}
	UnBlock
	set checked_bulknorm_level 1
	if [info exists badfiles] {
		if {[llength $badfiles] == [llength $chlist]} {
			Inf "All These Files Are Equal To Or Above The Normalisation Level"
			return 1
		}
		set msg "The Following Files Are Above The Normalisation Value Of '$val'\n"
		append msg "(Maximum Level File Is At '$maxlevel')\n\n"
		append msg "Need To Remove These From Chosen-Files List Before Proceeding\n\n"
		set cnt 0
		foreach fnam $badfiles {
			append msg "$fnam\n"
			incr cnt
			if {$cnt >= 20} {
				append msg "AND MORE"
				break
			}
		}
		append msg "\nRemove These From Chosen List Now ??"

		set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
		if {$choice == "yes"} {
			set nulist $chlist
			DoChoiceBak
			foreach fnam $badfiles {
				set k [lsearch $nulist $fnam]
				if {$k >= 0} {
					set nulist [lreplace $nulist $k $k]
				}
			}
			set chlist $nulist
			$ch delete 0 end
			set chcnt 0
			
			foreach fnam $chlist {
				$ch insert end $fnam
				incr chcnt
			}
		}
		return 1
	}
	return 0
}

#------ Display info returned by maxsamp

proc Get_Maxsamp_Info {} {
	global CDPmaxId done_maxsamp maxsamp_display maxsamp_line

	if [eof $CDPmaxId] {
		catch {close $CDPmaxId}
		set done_maxsamp 1
		return
	} else {
		gets $CDPmaxId line
		set line [string trim $line]
		if {[string length $line] <= 0} {
			return
		}
		if [string match KEEP:* $line] {
			set maxsamp_line $line
		} elseif [string match INFO:* $line] {
			;
		} elseif [string match WARNING:* $line] {
			;
		} elseif [string match ERROR:* $line] {
			catch {close $CDPmaxId}
			set done_maxsamp 1
			return
		} else {
			catch {close $CDPmaxId}
			set done_maxsamp 1
			return
		}
	}
	update idletasks
}			

#---- Check any possible run problems

proc TrapBadData {} {
	global bulk checked_bulknorm_level prm pprg mmod chlist evv
	set thismode [expr $mmod - 1]

	switch -regexp --  $pprg \
		^$evv(STACK)$ {
			TrapBadStackCount
		} \
		^$evv(MIXDUMMY)$	- \
		^$evv(MULTIMIX)$	- \
		^$evv(MIX_AT_STEP)$ - \
		^$evv(MIX_ON_GRID)$ {
			if [GappedName $chlist] {
				return 1
			}
		} \
		^$evv(MOD_LOUDNESS)$ {
			if {$bulk(run) && ($thismode == $evv(LOUDNESS_NORM))} {
				if {![info exists checked_bulknorm_level]} {
					if {[TooLoudFilesToBulkNorm $prm(0)]} {
						return 1
					}
				}
				catch {unset checked_bulknorm_level}
			}
		}

	return 0
}


#----- Creates shaping envelopes to allow process to be panned around multichans

proc RunProcessPanning {ochans} {
	global evv ps chlist pmcnt prm CDPidrun prg_dun prg_abortd simple_program_messages prg_ocnt
	global panprocess panprocessfnam panprocess_individ

	if {[info exists panprocess_individ]} {
		if [catch {file rename "cdptest0000.wav" "cdptest0.wav"} zit] {
			Inf "Failed (4) To Rename Temporary File"
			DeleteAllTemporaryFiles
			catch {unset panprocess}
			catch {unset panprocessfnam}
			catch {unset panprocess_individ}
			return 0
		}
	}
	set prg_ocnt 0
	set cmd [file join $evv(CDPROGRAM_DIR) mchanpan]
	lappend cmd mchanpan 8 "cdptest0.wav" 
	set i 0
	while {$i < $pmcnt} {
		lappend cmd $prm($i)
		incr i
	}
	Block "Generating Shaping Envelopes for Channels"

	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	if [catch {open "|$cmd"} CDPidrun] {
		Inf "Generating Shaping Envelopes Failed (1)"
		DeleteAllTemporaryFiles
		catch {unset panprocess}
		catch {unset panprocessfnam}
		catch {unset panprocess_individ}
		UnBlock
		return 0
   	} else {
   		fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
	}
	vwait prg_dun
	if {$prg_abortd} {
		set prg_dun 0
	}
	if {!$prg_dun} {
		Inf "Generating Shaping Envelopes Failed (2)"
		DeleteAllTemporaryFiles
		catch {unset panprocess}
		catch {unset panprocessfnam}
		catch {unset panprocess_individ}
		UnBlock
		return 0
	}
	set i 1
	while {$i <= $ochans} {
		set outfnam $evv(DFLT_OUTNAME)
		append outfnam $i $evv(TEXT_EXT)
		if {![file exists $outfnam]} {
			Inf "Failed To Generate Shaping Envelope For Channel $i"
			DeleteAllTemporaryFiles
			catch {unset panprocess}
			catch {unset panprocessfnam}
			catch {unset panprocess_individ}
			UnBlock
			return 0
		}
		incr i
	}
	set prg_ocnt 1
	UnBlock
	return 1
}

proc MessageOnlyProcess {progno} {
	global evv mmod
	switch -regexp -- $progno \
		^$evv(DISTORT_CYCLECNT)$ - \
		^$evv(GRAIN_COUNT)$		- \
		^$evv(GRAIN_ASSESS)$	- \
		^$evv(MIXFORMAT)$		- \
		^$evv(FLTBANKC)$		- \
		^$evv(FIND_PANPOS)$		- \
		^$evv(PSOW_LOCATE)$		- \
		^$evv(INFO_PROPS)$		- \
		^$evv(INFO_SFLEN)$		- \
		^$evv(INFO_TIMESUM)$	- \
		^$evv(INFO_TIMEDIFF)$	- \
		^$evv(INFO_SAMPTOTIME)$ - \
		^$evv(INFO_TIMETOSAMP)$ - \
		^$evv(INFO_MAXSAMP)$	- \
		^$evv(INFO_LOUDCHAN)$	- \
		^$evv(INFO_FINDHOLE)$	- \
		^$evv(INFO_DIFF)$		- \
		^$evv(INFO_CDIFF)$		- \
		^$evv(INFO_MAXSAMP2)$	- \
		^$evv(INFO_LOUDLIST)$	- \
		^$evv(ZCROSS_RATIO)$	- \
		^$evv(SEARCH)$			- \
		^$evv(WINDOWCNT)$		- \
		^$evv(CHANNEL)$			- \
		^$evv(FREQUENCY)$		- \
		^$evv(OCTVU)$			- \
		^$evv(P_INFO)$			- \
		^$evv(P_ZEROS)$			-\
		^$evv(MIXTEST)$ {
			return 1
		} \
		^$evv(ENV_WARPING)$		- \
		^$evv(ENV_RESHAPING)$	- \
		^$evv(ENV_REPLOTTING)$ {
			if {$mmod == 15} {
				return 1
			}
		} \
		^$evv(RETIME)$ {
			if {$mmod == 11} {
				return 1
			}
		} \
		^$evv(TSTRETCH)$ {
			if {$mmod == 2} {
				return 1
			}
		} \
		^$evv(HOUSE_EXTRACT)$ {
			if {$mmod == 6} {
				return 1
			}
		}

	return 0
}

#--- Output which is NOT a textfile really is a soundfile (and not an analysis file, an envelope file etc etc)

proc NonTextfileOutputIsASoundfile {progno modeno} {
	global evv

	if {$progno <= $evv(P_WRITE)} {
		return 0
	}
	if {($progno == $evv(ENV_EXTRACT)) && ($modeno == 1)} {
		return 0
	}
	switch -regexp -- $progno \
		^$evv(ENV_RESHAPING)	- \
		^$evv(ENV_BRKTOENV)		- \
		^$evv(ENV_DBBRKTOENV)	- \
		^$evv(ANALENV)			- \
		^$evv(PVOC_ANAL)$		- \
		^$evv(LUCIER_GETF)$		- \
		^$evv(LUCIER_GET)$		- \
		^$evv(LUCIER_PUT)$		- \
		^$evv(LUCIER_DEL)$		- \
		^$evv(FREEZE2)$			- \
		^$evv(ANALJOIN)$		- \
		^$evv(ONEFORM_GET)$		- \
		^$evv(ONEFORM_PUT)$		- \
		^$evv(ONEFORM_COMBINE)$	- \
		^$evv(SPEC_REMOVE)$		- \
		^$evv(PARTIALS_HARM)$	- \
		^$evv(SPECROSS)$		- \
		^$evv(P_SYNTH)$			- \
		^$evv(P_INSERT)$		- \
		^$evv(P_PTOSIL)$		- \
		^$evv(P_NTOSIL)$		- \
		^$evv(P_SINSERT)$		- \
		^$evv(ANALENV)$			- \
		^$evv(MAKE2)$			- \
		^$evv(P_VOWELS)$		- \
		^$evv(P_GEN)$			- \
		^$evv(P_INTERP)$		- \
		^$evv(VFILT)$			- \
		^$evv(SPECLEAN)$		- \
		^$evv(SPECTRACT)$		- \
		^$evv(BRKTOPI)$			- \
		^$evv(SPECSLICE)$ {
			return 0
		}

	return 1
}

proc ProcessIsTooFast {} {
	global pprg mmod evv
	switch -regexp -- $pprg \
		^$evv(RETIME)$ {
			if {($mmod == 11) || ($mmod == 12)} {
				return 1
			}
		} \
		^$evv(TSTRETCH)$ {
			if {$mmod == 2} {
				return 1
			}
		}	

	return 0
}

#------ Recognise Texture program (to possibly replace by no mindur, no splice

proc IsTextureProgram {progno} {
	global evv
	switch -regexp -- $progno \
		^$evv(SIMPLE_TEX)$	-\
		^$evv(GROUPS)$		-\
		^$evv(DECORATED)$	-\
		^$evv(PREDECOR)$	-\
		^$evv(POSTDECOR)$	-\
		^$evv(ORNATE)$		-\
		^$evv(PREORNATE)$	-\
		^$evv(POSTORNATE)$	-\
		^$evv(MOTIFS)$		-\
		^$evv(MOTIFSIN)$	-\
		^$evv(TIMED)$		-\
		^$evv(TGROUPS)$		-\
		^$evv(TMOTIFS)$		-\
		^$evv(TMOTIFSIN)$ {
			return 1
		}
	return 0
}

proc ConvertFromMsecs {val} { 
	global evv
	set vallower [string tolower $val]
	set k [string first "ms" $vallower]
	incr k -1
	set val [string range $val 0 $k]
	set val [expr $val * $evv(MS_TO_SECS)]
	return $val
}

proc IsSndinfoPrg {pprg} {
	switch -- $pprg {
		99  -
		223 -
		224 -
		225 -
		226 -
		227 -
		228 -
		229 -
		230 -
		231 -
		232 -
		233 -
		234 -
		235 -
		297 -
		350 -
		381 {
			return 1
		}
	}
	return 0
}
