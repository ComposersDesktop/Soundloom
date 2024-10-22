#
# SOUND LOOM RELEASE mac version 17.0.4E
#

#################
#	FINISHING	#
#################

#------ Call the tidy up routine on aborting the session

proc TidyUpAfterAbort {} {
	global pr1 in_tidyup blocker
	if [info exists in_tidyup] {
		return				;#	Prevent recursive call to TidyUp
	}
	My_Super_Release_to_Dialog
	set pr1 0
	TidyUp
	exit		;#	Final exit from main Application window
}

#------ Backup various items, on finishing or aborting the session

proc TidyUp {} {
	global pr1 ins hst memory wstk logs_count wl ww evv
	global in_tidyup favorites current_scorename scores_refresh articvw data_released released
	global do_redesign do_starthlp uv tw_testing sl_real propdir no_analplay local_dir
	global proptabnotesbak proptabnotesfil proptabtimesbak proptabtimesfil tostick lastmixio ahf
	global nessinit

	Block "Saving your Session"
	set in_tidyup 1
	if {$sl_real} {
		catch {SaveDirListingFromWkspace}
	}
	if {[info exists articvw] && [file exists $articvw]} {
		catch {file delete $articvw}
	}
	set ofil [file join $evv(URES_DIR) badpvplay$evv(CDP_EXT)]
	if {[info exists no_analplay] && $no_analplay} {
		catch {open $ofil "w"} zit
		catch {close $zit}
	} else {
		catch {file delete $ofil}
	}
	#RWD 10-2024 must use the .tv file extension
	set tvs  [file join $evv(CDPRESOURCE_DIR) tvscript.tv]
	if {[file exists $tvs]} {
		catch {file delete $tvs}
	}
	#	(COMPLETE) SAVING THE LOG OF CURRENT SESSION
	if {[info exists hst] && [info exists hst(fileId)]} {
		catch {FinalHistoryStorage}
	}
    ClearBadLogs

	#	CULL EXISITING SESSION LOGS ?
	if {[info exists hst] && [info exists hst(todaysname)]} {
		set logs_count 1
		foreach fnam [lsort -dictionary [glob -nocomplain [file join $evv(LOGDIR) *]]] {
			set fnam [file tail $fnam]
			if {![string match $fnam $hst(todaysname)]
			&&	![string match $fnam $evv(LOGCOUNT_FILE)$evv(CDP_EXT)]
			&&	![string match $fnam $evv(LOGSCNT_FILE)$evv(CDP_EXT)]} {	
				incr logs_count						;#	Count all logfiles except today's
			}
		}

		if {$logs_count >= $evv(THIS_LOGS_MAX)} {

			if [catch {open [file join $evv(LOGDIR) $evv(LOGSCNT_FILE)$evv(CDP_EXT)] w} fileId] {
				ErrShow "Problem: Cannot open log counting file $evv(LOGSCNT_FILE)$evv(CDP_EXT)"
			}  else {
				set choice [tk_messageBox -type yesno -message "You Have $logs_count Log Files.\nDo You Wish To Delete Some Session Logs??" \
					-icon question -parent [lindex $wstk end]]
				if {$choice == "yes"}  {
					DoLogCull 1
				} else {
					incr evv(THIS_LOGS_MAX) $evv(LOGS_MAX)
				}
				puts $fileId $evv(THIS_LOGS_MAX)
				catch {close $fileId}
			}
		}
	}

	#	BACKING-UP THE WORKSPACE (FOR RESTORATION AT NEXT SESSION)

	if {$sl_real && [info exists ww]} {
		if [info exists wl] {
			if {!$tw_testing} {
				SaveWorkspace
				DeleteAllTemporaryFiles
			}
		}
	}
	SaveAlgebra
	if {!$sl_real} {
		DeleteAllTemporaryFiles
	}

	if {$sl_real} {
		catch {SaveSrcListsToFile}		;#	Save listings of sound-srcs for non-sound files (if they exist)
		catch {SaveLastRunValsToFile}	;#	Save parameters last used in each program
		catch {StoreRefs}				;#	Store users reference values
		catch {StoreRecentDirs}			;#	Store list of recently used directories
		if {!$tw_testing} {				
			catch {NnnSave}				;#	Save notebook
		}

		if {[info exists do_redesign] && [info exists uv(redesign)]} {
			if {$do_redesign && !$uv(redesign)} {
				set uv(redesign) 1
				catch {SaveUserEnvironment}
			} elseif {!$do_redesign && $uv(redesign)} {
				set uv(redesign) 0
				catch {SaveUserEnvironment}
			}
		}
		if [info exists do_starthlp] { 
			set fnam [file join $evv(URES_DIR) $evv(BHELP)$evv(CDP_EXT)]
			if [catch {open $fnam "w"} helpId] {
				Inf "Cannot open file $evv(BHELP)$evv(CDP_EXT) to save state of startup help"
			} else {
				catch {puts $helpId $do_starthlp}
				catch {close $helpId}
			}
		}
		catch {SaveTestFlags}
		SaveLastBL
		if [info exists current_scorename] {
			BakupScore $current_scorename
		}
		BakupScore ""
		BakupScoreMixlist
		if {[info exists scores_refresh] && $scores_refresh} {
			RefreshUnloadedScores 1
		}
	}
	if [info exists propdir] {
		set tmpfnam $evv(DFLT_TMPFNAME)
		if [catch {open $tmpfnam w} fileId] {
			Inf "Cannot open temporary file to remember special-properties file-directory."
		} else {
			puts $fileId $propdir
			close $fileId		
			set ofil [file join $evv(URES_DIR) $evv(PROPDIR)$evv(CDP_EXT)] 
			if {[file exists $ofil]} {
				if [catch {file rename -force $evv(DFLT_TMPFNAME) $ofil} zit] {
					Inf "Cannot retain memory of special-properties file-directory (in file '$ofil')"
				}
			} else {
				if [catch {file rename $evv(DFLT_TMPFNAME) $ofil} zit] {
					Inf "Cannot retain memory of special-properties file-directory (in file '$ofil')"
				}
			}
		}
	}
	SavePropfilesList
	SavePositionInProptable
	SaveIntroState
	SaveQikButton
	SaveLastMix
	if {$sl_real} {
		SaveTextfileExtensions	
	}
	SaveColour

	set ntbk_displayed [file join $evv(CDPRESOURCE_DIR) $evv(NB_DISPLAYED)$evv(CDP_EXT)]
	set ntbk_retained [file join $evv(CDPRESOURCE_DIR) $evv(NTBKRETAIN)$evv(CDP_EXT)]
	if {[file exists $ntbk_displayed] && [file exists $ntbk_retained] } {
		Inf "Today's Notebook May Still Be On The Desktop\n\nIf So, You Should Close It Now."
	}
	if {[info exists proptabnotesbak] && [info exists proptabnotesfil] } {
		SavePropTabNotesData
	}
	if {[info exists proptabtimesbak] && [info exists proptabtimesfil] } {
		SavePropTabTimesData
	}
	SaveExtraxtSpecificPitchedMaterialParams
	SaveLastSoundlist
	SetLastMixIO
	SaveMainMix
	SaveMMLastVals
	SaveQikClikVals
	SaveFOFSeparator
	SaveRestailVals
	SaveMrestailVals
	PurgeTempThumbnails
	if {$data_released} {
		SaveScience
		SaveSpekData
		SaveSpekouts
		SaveTsSrcFiles
	}
	if {[info exists nessinit]} {
		NessMStore
	}
	if {[info exists released(newmix)]} {
		SaveTILPfiles
	}
	if {[info exists evv(NEWUSER_HELP)] && $evv(NEWUSER_HELP)} {
		SaveIntroState
		GetNewUserHelp finish
		if {$sl_real && [info exists ww]} {
			destroy .workspace
		}
		if {[info exists tostick]} {
			CopyToStick
		}
		ClearBakupLog	
		WarnBakupLog 0
		exit
	}
	if {[info exists ahf(qsets)]} {
		AhfSaveQsets
	}
	if {$sl_real && [info exists ww]} {
		destroy .workspace
	}
	if {[info exists tostick]} {
		CopyToStick
	}
	ClearBakupLog	
	WarnBakupLog 0
	unset in_tidyup
	UnBlock
}

#------ Release focus on dialog, restore focus to previous dialog

proc My_Super_Release_to_Dialog {} {
global wstk window_stack_index message_maxindex message_stack

	set window_stack_index [llength $wstk]
	incr window_stack_index -1
	set thiswindow [lindex $wstk $window_stack_index]
	while {![string match $thiswindow ".cdphello"]
		&& ![string match $thiswindow ".workspace"]} {
		if [string match $thiswindow ".blocker"] {
			incr message_maxindex -1
			if {$message_maxindex < 0} {
				catch {unset message_stack}
			} else {
				set message_stack [lrange $message_stack 0 $message_maxindex]
			}
		}
		incr window_stack_index -1
		if {$window_stack_index < 0} {
			break
		}
		set wstk [lrange $wstk 0 $window_stack_index]
		set nextwindow [lindex $wstk end]

		if {![catch {grab release $thiswindow}]} {
			destroy $thiswindow
		}
		set thiswindow $nextwindow
		catch {focus $thiswindow}
		catch {grab $thiswindow}
	}
}

#################################################################
#	SAVING THE PARAMETERS USED IN PREVIOUS RUN OF EACH PROGRAM	#
#################################################################

#------ Save values of params last used in each of programs, to file

proc SaveLastRunValsToFile {} {
	global lastrunvals penultrangetype prg ins evv

	set fnam [file join $evv(URES_DIR) $evv(LASTRUNVALS)$evv(CDP_EXT)]

	if {![catch {open $fnam r} fId]} {
		while { [gets $fId line] >= 0} {
			lappend oldlines $line
		}
		catch {close $fId}
	}
	if [catch {open $evv(DFLT_TMPFNAME) w} fileId] {
		Inf "Cannot open file to save Last Run Values"
		return		
	}
	if {[info exists lastrunvals]} {
		foreach index [array names lastrunvals] {
			if {![info exists penultrangetype($index)] } {
				continue			;#	Forget data if it's incomplete
			}
			set validname 1
			if [regexp {^[0-9]+,[0-9]+$} $index] {
				set i [string first , $index]
				incr i -1
				set progno [string range $index 0 $i]
				if {![info exists prg($progno)]} {
					continue		;#	Forget names with invalid program numbers
				}
				incr i 2
				set modeno [string range $index $i end]
				set modecnt [lindex $prg($progno) $evv(MODECNT_INDEX)]
				if {$modeno > $modecnt} {
					continue		;#	Forget names with invalid mode numbers
				}
			} else {
				set validname 0
				foreach mname $ins(names) {
					if [string match $mname $index] {
						set validname 1
						break
					}
				}
			}
			if {!$validname} {
				continue			;#	Forget data for invalid (or deleted) ins names
			}
			catch {unset line}
			catch {unset line2}
			lappend line $index
			foreach val $lastrunvals($index) {
				lappend line $val
			}
			foreach val $penultrangetype($index) {
				lappend line2 $val
			}
			puts $fileId $line
			puts $fileId $line2
			lappend indexlist $index
		}
	}
	if [info exists oldlines] {
		set even 1
		foreach line $oldlines {
		 	if {$even} {
				set oldindex [lindex $line 0]
				set got 0
				if [info exists indexlist] {
					foreach index $indexlist {
						if [string match $index $oldindex] {
							set got 1
							break
						}
					}
				}
				if {!$got} {
					puts $fileId $line
				}
			} elseif {!$got} {
				puts $fileId $line
			}
			set even [expr !$even]
		}
	}
	close $fileId
	catch {close $fId}
	if [file exists $fnam] {
		if [catch {file delete $fnam}] {
			Inf "Cannot remove the previous file of last run params : Hence cannot save current values."
			catch {file delete $evv(DFLT_TMPFNAME)}
			return
		}
	} 
	if [catch {file rename $evv(DFLT_TMPFNAME) $fnam} in] {
		ErrShow "Cannot rename the file of last run params : data lost"
	}
}

#--------------

proc StoreRecentDirs {} {
	global recent_dirs evv

	if {![info exists recent_dirs]} {
		return
	}

	set tmpfnam $evv(DFLT_TMPFNAME)
	if [catch {open $tmpfnam w} fileId] {
		Inf "Cannot open temporary file to do updating of recent directories."
		return
	}
		
	foreach rd $recent_dirs {
		puts $fileId $rd
	}
	close $fileId
	set rd_file [file join $evv(URES_DIR) $evv(RECDIRS)$evv(CDP_EXT)]
	if [file exists $rd_file] {
		if [catch {file delete $rd_file}] {
			ErrShow "Cannot delete original Recent-Directories file. Cannot update listing of sound-sources of Recent Directories."
			return
		}
	}
	if [catch {file rename $tmpfnam $rd_file}] {
		ErrShow "Cannot Rename temporary Recent Directories file. Lost the listing of Recent Directories."
	}
}

#------ Save details of last soundlist being used, and position in it.

proc SaveLastSoundlist {} {
	global lastgrabfil lastgrab evv
	set fnam [file join $evv(URES_DIR) lastgrab$evv(CDP_EXT)]
	if {[info exists lastgrabfil] && [file exists $lastgrabfil] && [info exists lastgrab]} {
		if [catch {open $fnam "w"} zit] {
			return
		}
		set line [list $lastgrabfil $lastgrab]
		puts $zit $line
		close $zit
	} else {
		catch {file delete $fnam}
	}
}
