#
# SOUND LOOM RELEASE mac version 17.0.4
#

################
# CLEANING KIT #
################

proc CleaningKit {} {
	global wl chlist pa evv
	foreach fnam [glob -nocomplain $evv(CLEANKIT_NAME)*] {
		if [file isdirectory $fnam] {
			continue
		}
		Inf "FILES USING THE RESERVED FILENAME 'evv(CLEANKIT_NAME)' EXIST ON YOUR SYSTEM: CANNOT PROCEED"
		return
	}
	set i [$wl curselection]
	if {([llength $i] > 1) || ($i < 0)} {
		if {![info exists chlist] || ([llength $chlist] != 1)} {
			if {($i < 0) && ([$wl index end] >= 0)} {
				set fnam [$wl get 0]
				if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
					Inf "'$fnam' Is Not A Soundfile"
					return
				}
				set cleani 0
			} else {
				Inf "Select A Single Workspace Soundfile"
				return
			}
		} else {
			set fnam [lindex $chlist 0]
			set cleani [LstIndx $fnam $wl]
			if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
				Inf "'$fnam' Is Not A Soundfile"
				return
			}
		}
	} else {
		set cleani $i
		set fnam [$wl get $i]
		if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
			if {![info exists chlist] || ([llength $chlist] != 1)} {
				Inf "'$fnam' Is Not A Soundfile"
				return
			} else {
				set fnam [lindex $chlist 0]
				if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
					Inf "'$fnam' Is Not A Soundfile"
					return
				}
				set cleani [LstIndx $fnam $wl]
			}
		}
	}
	if {$pa($fnam,$evv(CHANS)) > 2} {
		Inf "Mono files mainly : Stereo files for Spectral Denoise only"
		return
	}
	DoCleanKit $fnam
	if {[info exists cleani]} {
		$wl selection set $cleani
	}
}

proc DoCleanKit {fnam} {
	global pr_ckit ckitfile ckitvar cklist ckit_filindex wstk evv shortwindows pa
	global blist_change background_listing wl rememd last_outfile ckitorig ckit

	set ckit_filindex 0
	set ckitfile ""

	set outfile $evv(DFLT_OUTNAME)
	append outfile 0
	append outfile $evv(SNDFILE_EXT)

	set ckit(srate) $pa($fnam,$evv(SRATE))
	set ckit(dur)   $pa($fnam,$evv(DUR))
	set ckit(insams) $pa($fnam,$evv(INSAMS))

	set f .ckit
	
	if [Dlg_Create $f "CLEANING KIT" "set pr_ckit 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0 -bd 0]
		set f0a [frame $f.0a -bd 0 -height 1 -bg [option get . foreground {}]]
		set f1 [frame $f.1 -bd 0]
		set f1a [frame $f.1a -bd 0 -height 1 -bg [option get . foreground {}]]
		set f2 [frame $f.2 -bd 0]
		set f3 [frame $f.3 -bd 0]
		set f6 [frame $f.6 -bd 0]
		button $f0.keep -text "Keep Output" -width 11 -command "set pr_ckit 2" -bg [option get . background {}]
		label $f0.name -text "Outputfile Name"
		entry $f0.e -textvariable ckitfile -width 20
		radiobutton $f0.r1 -variable ckitorig -text "source name" -value 1 -command "GetCkitOrigFilename $fnam; set ckitorig 0"
		radiobutton $f0.r2 -variable ckitsuff -text "suffix 'cln'" -value 1 -command "CkitSuffix; set ckitsuff 0"
		button $f0.a1 -text "a1" -width 3 -command "set ckitfile a1" 
		button $f0.a2 -text "a2" -width 3 -command "set ckitfile a2" 
		button $f0.h -text "Help" -width 3 -command "TellClean" -bg $evv(HELP)
		button $f0.quit -text "Abandon" -command "set pr_ckit 0"
		pack $f0.keep $f0.name $f0.e $f0.r1 $f0.r2 $f0.a1 $f0.a2 $f0.h -side left -padx 2
		pack $f0.quit -side right -padx 2
		pack $f0 -side top -fill x -expand true

		pack $f0a -side top -fill x -expand true -pady 2

		if {[info exists shortwindows]} {
			set cklist [Scrolled_Listbox $f6.l -width 110 -height 12 -selectmode single]
		} else {
			set cklist [Scrolled_Listbox $f6.l -width 110 -height 24 -selectmode single]
		}
		button $f1.clea -text "Clean Sound"   -width 13 -command "set pr_ckit 1" -bg $evv(EMPH)
		button $f1.play -text "Sound View"  -width 13 -command "PlayFromCleanedList $cklist" -bg $evv(SNCOLOROFF)
		button $f1.dele -text "Delete Sounds" -width 13 -command "DeleteFromCleanedList $cklist"
		button $f1.reset -text "Reset" -width 13 -command DeleteAllTemporaryFiles
		button $f1.restt -text "Start Again" -width 13 -command DeleteAllCkitFiles
		pack $f1.clea $f1.play $f1.dele $f1.reset $f1.restt -side left -padx 20
		pack $f1 -side top -pady 4

		pack $f1a -side top -fill x -expand true -pady 2

		radiobutton	$f2.rgn -variable ckitvar -text "CLEAN GENERAL NOISE" -value 1 -command {.ckit.6.l.list config -selectmode single}
		radiobutton	$f2.gat -variable ckitvar -text "GATE out Bad Signal" -value 2 -command {.ckit.6.l.list config -selectmode single}
		radiobutton	$f2.cut -variable ckitvar -text "CUT away Bad Signal" -value 3 -command {.ckit.6.l.list config -selectmode single}
		radiobutton	$f2.rei -variable ckitvar -text "REINSERT ORIGINAL SIGNAL" -value 8 -command {.ckit.6.l.list config -selectmode extended}
		pack $f2.rgn $f2.gat $f2.cut $f2.rei -side left
		pack $f2 -side top

		label     	$f3.lab -text "REMOVE  BLEMISHES"
		radiobutton	$f3.rpb -variable ckitvar -text "Pitch In Signal              "  -value 4 -command {.ckit.6.l.list config -selectmode single}
		radiobutton	$f3.rps -variable ckitvar -text "Sound under Sibilant " -value 5 -command {.ckit.6.l.list config -selectmode single}
		radiobutton	$f3.rnp -variable ckitvar -text "Noise Above Signal     "   -value 6 -command {.ckit.6.l.list config -selectmode single}
		radiobutton	$f3.lof -variable ckitvar -text "Low Freq problem         " -value 7 -command {.ckit.6.l.list config -selectmode single}
		radiobutton	$f3.fla -variable ckitvar -text "Subtract spectrum       " -value 1 -command {.ckit.6.l.list config -selectmode single}
		radiobutton	$f3.gra -variable ckitvar -text "Graft seg elsewhere  " -value 10 -command {.ckit.6.l.list config -selectmode single}
		radiobutton	$f3.ins -variable ckitvar -text "Insert silence               " -value 12 -command {.ckit.6.l.list config -selectmode single}
		radiobutton	$f3.att -variable ckitvar -text "Attenuate level             " -value 11 -command {.ckit.6.l.list config -selectmode single}
		radiobutton	$f3.dov -variable ckitvar -text "Dovetail the ends         " -value 9 -command {.ckit.6.l.list config -selectmode single}
		radiobutton	$f3.stc -variable ckitvar -text "Subtract spec Stereo  " -value 13 -command {.ckit.6.l.list config -selectmode single}
		label $f3.msg -text "The Output File From Each Cleaning Process Appears At The End Of The List Below" -fg $evv(SPECIAL)
		pack $f3.lab $f3.rpb $f3.rps $f3.rnp $f3.lof $f3.fla $f3.gra $f3.ins $f3.att $f3.dov $f3.msg $f3.stc -side top
		pack $f3 -side top

		pack $f6.l -side top -fill both -expand true
		pack $f6 -side top -pady 2
		bind $f.0.e <Up> "AdvanceNameIndex 1 ckitfile 0"
		bind $f.0.e <Down> "AdvanceNameIndex 0 ckitfile 0"
		bind $f.0.e <Shift-Up> "AdvanceNameIndex 1 ckitfile 1"
		bind $f.0.e <Shift-Down> "AdvanceNameIndex 0 ckitfile 1"
		wm resizable $f 1 1
		bind $f <Escape> {set pr_ckit 0}
		bind $f <Return> {set pr_ckit 1}
	}
	wm title $f "CLEANING KIT: [file tail $fnam]"
	if {$pa($fnam,$evv(CHANS)) == 2} {
		set ckitvar 13
	} else {
		set ckitvar 1
	}
	$cklist delete 0 end
	$cklist insert end $fnam
	set pr_ckit 0
	raise $f
	update idletasks
	StandardPosition2 .ckit
	set finished 0
	My_Grab 0 $f pr_ckit $f
	while {!$finished} {
		tkwait variable pr_ckit
		switch -- $pr_ckit {
			1 {
				set obvious 0
				if {$ckitvar == 0} {
					Inf "No Cleaning Process Selected"
					continue
				}
				if {$ckitvar == 13} {
					if {$pa($fnam,$evv(CHANS)) != 2} {
						Inf "Stereo files only for this cleaning process"
						set ckitvar 0
						continue
					}
				} else {
					if {$pa($fnam,$evv(CHANS)) > 1} {
						Inf "Mono files only for this cleaning process"
						set ckitvar 0
						continue
					}
				}
				if {[$cklist index end] == 1} {
					if {$ckitvar == 8} {
						Inf "You Can Only Use This Process With An Original And A Cleaned Sound"
						continue
					}
					set thisfnam $fnam
				} else {
					if {($ckitvar == 8) && ([$cklist index end] == 2)} {
						set ilist [list 0 1]
						set thisorigfnam [$cklist get 0]
						set thisfnam [$cklist get 1]
						set obvious 1
					} else {
						set ilist [$cklist curselection]
						set len [llength $ilist]
						switch -- $len {
							1 {
								if {$ilist == -1} {
									Inf "No Sound Selected"
									continue
								} elseif {$ckitvar == 8} {
									Inf "Select Two Sounds"
									continue
								} else {
									set thisfnam [$cklist get $ilist]
								}
							}
							2 {
								if {$ckitvar != 8} {
									Inf "Select A Single Sound"
									continue
								} else {		
									set thisorigfnam [$cklist get [lindex $ilist 0]]
									set thisfnam [$cklist get [lindex $ilist 1]]
								}
							}
							0 {
								Inf "No Sound Selected"
								continue
							}
							default {
								Inf "Too Many Sounds Selected"
								continue
							}
						}
					}
				}
				switch -- $ckitvar {
					1 { GeneralDenoise		$thisfnam	}
					2 { DoDisNoise			$thisfnam	}
					3 { DoCutJunk			$thisfnam	}
					4 { RemovePitchElements $thisfnam	}
					5 { DoNoiseDecouple		$thisfnam 1 }
					6 { DoNoiseDecouple		$thisfnam 0 }
					7 { DoNoiseDecouple		$thisfnam 2 }
					9 { EnvelEnds			$thisfnam }
					10 { Graft				$thisfnam }
					11 { CleanAtten			$thisfnam }
					12 { CleanInsil			$thisfnam }
					13 { GeneralDenoiseStereo $thisfnam }
					8 {
						if {!$obvious} {
							set msg "Is '$thisfnam' The Cleaned File ??"
							set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
							if {$choice == "no"} {
								set temp $thisfnam
								set thisfnam $thisorigfnam
								set thisorigfnam $temp
							}
						}
						DoUnNoise $thisfnam $thisorigfnam
					}
				}
				$cklist selection clear 0 end
				$cklist selection set [expr [$cklist index end] -1]
			}
			2 {
				if {[$cklist index end] <= 1} {
					Inf "No Cleaning Has Been Done"
					continue
				}
				set i [$cklist curselection]
				if {[llength $i] > 1} {
					Inf "Select A Single Sound"
					continue
				}
				if {([string length $i] <= 0 ) || ($i == -1)} {
					Inf "No File Selected"
					continue
				}
				if {$i == 0} {
					Inf "You Have Selected The (Uncleaned) Original Sound"
					continue
				}
				set outfile [$cklist get $i]

				set ckitfile [string trim $ckitfile]
				if {[string length $ckitfile] <= 0} {
					Inf "No Outputfile Name Entered"
					continue
				}
				if {![ValidCDPRootname [file rootname [file tail $ckitfile]]]} {
					continue
				}
				set nufnam [string tolower $ckitfile]
				append nufnam $evv(SNDFILE_EXT)
				if {[file exists $nufnam]} {
					if {[file isdirectory $nufnam]} {
						Inf "File '$nufnam' Already Exists (As A Directory)"
						continue
					} else {
						if {[string match $fnam $nufnam]} {
							set msg "Overwrite The Original File ??"
						} else {
							set msg "File '$nufnam' Already Exists: Overwrite It ??"
						}
						set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							continue
						}
						set blist_change 0
						if {![DeleteFileFromSystem $nufnam 0 1]} {
							Inf "Cannot Delete Existing File '$nufnam'"
							continue
						}
						DummyHistory $nufnam "DESTROYED"
						if {$blist_change} {
							SaveBL $background_listing
						}
						if {[IsInAMixfile $nufnam]} {
							set delmix 1
							if {[string match $fnam $nufnam]} {
								set msg "Overwritten File Is In A Mixfile : Keep The Mixfile ??"
								set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
								if {$choice == "yes"} {
									set delmix 0
								}
							}
							if {$delmix} {
								MixM_ManagedDeletion $nufnam
								MixMStore
							}
						}
						set i [LstIndx $nufnam $wl]	;#	remove from workspace listing, if there
						if {$i >= 0} {
							$wl delete $i
							WkspCnt $nufnam -1
							catch {unset rememd}
						}
					}
				}
				if [catch {file rename $outfile $nufnam} zit] {
					Inf "Cannot Rename Output File To '$nufnam'"
					continue
				}
				UpdateBakupLog $nufnam create 1
				if {[FileToWkspace $nufnam 0 0 0 0 1] > 0} {
					$wl selection clear 0 end
					$wl selection set 0
				}
				set last_outfile $nufnam
				break
			}
			0 {
				set k [LstIndx $fnam $wl]
				if {$k >= 0} {
					$wl selection clear 0 end
					$wl selection set $k
				}
				break
			}
		}
	}
	DeleteAllCkitFiles
	My_Release_to_Dialog $f
	destroy .ckit
}

proc CkitSuffix {} {
	global ckitfile
	if {![info exists ckitfile]} {
		return
	}
	set ckitfile [string trim $ckitfile]
	set len [string length $ckitfile]
	if {$len <= 0} {
		return
	}
	if {$len > 4} {
		incr len -4
	}
	if {[string match [string range $ckitfile $len end] "_cln"]} {
		return
	}
	append ckitfile "_cln"
}

proc DeleteAllCkitFiles {} {
	global cklist evv ww wl total_wksp_cnt wksp_cnt rememd ckit_filindex
	DeleteAllTemporaryFiles
	foreach fnam [glob -nocomplain $evv(CLEANKIT_NAME)*] {
		if [file isdirectory $fnam] {
			continue
		}
		if [catch {file delete $fnam} zit] {
			lappend badfiles $fnam
		}
		set i [LstIndx $fnam $wl] 
		if {$i >= 0} {
			PurgeArray $fnam
			$wl delete $i
			incr total_wksp_cnt -1
			incr wksp_cnt -1
			ForceVal $ww.1.a.endd.l.cnts.new $wksp_cnt
			ForceVal $ww.1.a.endd.l.cnts.all $total_wksp_cnt
			catch {unset rememd}
		}
	}				
	set cnt 0
	if {[info exists cklist]} {
		foreach fnam [$cklist get 0 end] {
			if {![file exists $fnam]} {
				lappend ilist $cnt
			}
			incr cnt
		}
		if [info exists ilist] {
			set ilist [ReverseList $ilist]
			foreach i $ilist {
				$cklist delete $i
			}
		}
	}
	if [info exists badfiles] {
		set lastindx [file rootname [lindex $badfiles end]]
		set lastindx [string range $lastindx [string length $evv(CLEANKIT_NAME)] end]
		set ckit_filindex $lastindx
		incr ckit_filindex
		set msg "Failed To Delete The Temporary Cleaning File"
		if {[llength $badfiles] > 1} {
			append msg "S"
		}
		append msg "\n"
		set cnt 0
		foreach fnam $badfiles {
			append msg $fnam "\n"
			incr cnt
			if {$cnt >= 20} {
				append msg "And More"
				break
			}
		}
		Inf $msg
	} else {
		set ckit_filindex 0
	}
}

proc PlayFromCleanedList {ll} {
	global evv
	if {[$ll index end] <= 1} {
		set fnam [$ll get 0]
	} else {
		set i [$ll curselection]
		if {([llength $i] != 1) || ([string length $i] <= 0) || ($i == -1)} {
			Inf "Select A Single Sound"
			return
		}
		set fnam [$ll get $i]
	}
	SnackDisplay 0 $evv(SN_FROM_CLEANKIT_NO_OUTPUT) 0 $fnam
}

proc DeleteFromCleanedList {ll} {
	global evv cklist ckit_filindex
	if {[$ll index end] <= 1} {
		Inf "You Cannot Delete The Source Sound Here"
		return
	} else {
		set ilist [$ll curselection]
		if {([llength $ilist] < 1) || ([string length $ilist] <= 0) || ($ilist == -1)} {
			Inf "Select Sounds To Delete"
			return
		} 
		if {([llength $ilist] == 1) && ($ilist == 0)} {
			Inf "You Cannot Delete The Source Sound Here"
			return
		}
	}
	set ilist [ReverseList $ilist]
	foreach i $ilist {
		set fnam [$ll get $i]
		if {![catch {file delete $fnam} zab]} {
			$ll delete $i
		}
	}
	set i [$ll index end]
	incr i -1
	if {$ll == $cklist} {
		set fnam [file rootname [$ll get $i]]
		set k [string first $evv(CLEANKIT_NAME) $fnam]
		if {$k < 0} {
			set ckit_filindex 0
		} else {
			set lastindx [string range $fnam [string length $evv(CLEANKIT_NAME)] end]
			incr lastindx
			set ckit_filindex $lastindx
		}
	}
}

proc GetCkitOrigFilename {fnam} {
	global ckitfile
	set ckitfile [file rootname $fnam]
	focus .ckit.0.e
	.ckit.0.e icursor end
}

#------ General Functions in many cleaning processes

proc PlayCleanedOutput {} {
	global pa evv ckit snack_enabled
	set fnam $evv(DFLT_OUTNAME)
	append fnam 0
	append fnam $evv(SNDFILE_EXT)
	if {![file exists $fnam]} {
		Inf "No Output File To Play"
		return
	}
	set pa($fnam,$evv(CHANS)) 1
	if {$snack_enabled} {
		set pa($fnam,$evv(SRATE)) $ckit(srate)
		set pa($fnam,$evv(DUR)) $ckit(dur)
		set pa($fnam,$evv(INSAMS)) $ckit(insams)
		SnackDisplay 0 $evv(SN_FROM_CLEANKIT_OUTPUT) 0 $fnam
		unset pa($fnam,$evv(SRATE))
		unset pa($fnam,$evv(DUR))
		unset pa($fnam,$evv(INSAMS))
	} else {
		PlaySndfile $fnam 0
	}
	unset pa($fnam,$evv(CHANS))
}

proc CreateBalanceFile {src balancefile minsplice srate sampdur dur} {
	global rpe_timepairs unn_timepairs dcou_timepairs den_timepairs cj_timepairs 
	set cnt 0
	set infil 0
	switch -- $src {
		"rpe"  { set timepairs $rpe_timepairs } 
		"unn"  { set timepairs $unn_timepairs }  
		"dcou" { set timepairs $dcou_timepairs }  
		"den"  { set timepairs $den_timepairs }  
	}
	foreach item $timepairs {
		catch {unset nuline}
		if {$infil == 0} {
			if {$cnt == 0} {
				if {$item <= $minsplice} {
					lappend nuline 0
					lappend nuline 0
					lappend nulines $nuline
				} else {
					lappend nuline 0
					lappend nuline 1
					lappend nulines $nuline
					catch {unset nuline}				
					lappend nuline [expr $item - $minsplice]
					lappend nuline 1
					lappend nulines $nuline
					catch {unset nuline}				
					lappend nuline $item
					lappend nuline 0
					lappend nulines $nuline
				}
			} else {
				catch {unset nuline}				
				lappend nuline [expr $item - $minsplice]
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
			lappend nuline [expr $item + $minsplice]
			lappend nuline 1
			lappend nulines $nuline
		}
		set infil [expr !$infil]			
		incr cnt
	}
	set step [expr $sampdur - $item]
	set linecnt [llength $nulines]
	set lcnt 0
	if [catch {open $balancefile "w"} zit] {
		Inf "Cannot Open Temporary Balance-File '$balancefile'"
		return 0
	}
	foreach line $nulines {
		incr lcnt
		set sampdur [lindex $line 0]
		set time [expr double($sampdur) / double($srate)]
		set nuline $time
		append nuline "  " [lindex $line 1]
		puts $zit $nuline
	}
	if {$step > $minsplice} {
		set sampdur [expr $sampdur + $minsplice]
		set time [expr double($sampdur) / double($srate)]
		set nuline $time
		append  nuline "  " 1
		puts $zit $nuline
		set time [expr $time + 1.0]
		set nuline $time
		append  nuline "  " 1
		puts $zit $nuline
	} elseif {$step > 0} {
		set time [expr $time + 1.0]
		set nuline $time
		append  nuline "  " 0
		puts $zit $nuline
	}
	close $zit
	return 1
}

proc SetSmpcnt {where sampdur} {
	global rpe_t dcou_t den_t dis_t cj_t grft_t clatn_t clinsil_t clatn_all
	global rpe_all denois_all dis_all dcou_all cj_all clinsil_all
	switch -- $where {
		"rpe_t" {
			$rpe_t insert end "\t$sampdur"
		}
		"dcou_t" {
			$dcou_t insert end "\t$sampdur"
		}
		"den_t" {
			$den_t insert end "\t$sampdur"
		}
		"dis_t" {
			$dis_t insert end "\t$sampdur"
		}
		"cj_t" {
			$cj_t insert end "\t$sampdur"
		}
		"grft_t" {
			$grft_t insert end "\t$sampdur"
		}
		"clatn_t" {
			$clatn_t insert end "\t$sampdur"
		}
		"clinsil_t" {
			$clinsil_t delete 1.0 end
			$clinsil_t insert end "0\t$sampdur"
		}
		"rpe_all" {
			$rpe_t delete 1.0 end
			$rpe_t insert end "0\t$sampdur"
		}
		"denois_all" {
			$den_t delete 1.0 end
			$den_t insert end "0\t$sampdur"
		}
		"dis_all" {
			$dis_t delete 1.0 end
			$dis_t insert end "0\t$sampdur"
		}
		"dcou_all" {
			$dcou_t delete 1.0 end
			$dcou_t insert end "0\t$sampdur"
		}
		"cj_all" {
			$cj_t delete 1.0 end
			$cj_t insert end "0\t$sampdur"
		}
		"clinsil_all" {
			$clinsil_t delete 1.0 end
			$clinsil_t insert end "0\t$sampdur"
		}
		"clatn_all" {
			$clatn_t delete 1.0 end
			$clatn_t insert end "0\t$sampdur"
		}
	}
}

proc LastClean {listing} {
	global previous_clean  rpe_t den_t dis_t dcou_t cj_t clatn_t clinsil_t
	upvar $listing thislisting
	if {![info exists previous_clean]} {
		return
	}
	$thislisting delete 1.0 end
	$thislisting insert end $previous_clean
}

proc ClearClean {listing} {
	$listing delete 1.0 end
}

########## VARIOUS CLEANING ROUTINES ##########

#--- Rationalises the brkpnt times entered in the Cleaning window

proc CleanSortTimes {listing mingap nonebad} {

	set returnval {}
	if {!$nonebad} {
		set returnval xx
	}
	set words [$listing get 1.0 end]
	foreach item $words {
		set item [string trim $item]
		if {[string length $item] > 0} {
			lappend nuwords $item
		}
	}
	if {![info exists nuwords]} {
		if {$nonebad} {
			Inf "No Sample Times Given"
		}
		return {}
	}
	foreach item $nuwords {
		if {![regexp {^[0-9]+$} $item]} {
			Inf "Invalid Sampletime '$item'"
			return $returnval
		}
	}
	set len [llength $nuwords]
	if {![IsEven $len]} {
		Inf "Sampletimes Incorrectly Paired"
		return $returnval
	} elseif {$len == 2} {
		if {[lindex $nuwords 1] <= [lindex $nuwords 0]} {
			Inf "Sampletimes Do Not Increase"
			return $returnval
		}
		return $nuwords
	}
	set len 0
	foreach {time0 time1} $nuwords {
		set wordpair [list $time0 $time1]
		lappend wordpairs $wordpair
		incr len
	}
	set len_less_one [expr $len - 1]

	set changed 0
	set n 0
	while {$n < $len_less_one} {
		set npair [lindex $wordpairs $n]
		set m $n
		incr m
		while {$m < $len} {
			set mpair [lindex $wordpairs $m]
				;#	REMOVE DUPLICATES
			if {([lindex $npair 0] == [lindex $mpair 0]) && ([lindex $npair 1] == [lindex $mpair 1])} {
				set wordpairs [lreplace $wordpairs $m $m]
				set changed 1
				incr len -1
				incr len_less_one -1
				incr m -1
				;#	SORT INTO TIME ORDER OF BLOCK START-TIMES
			} elseif {[lindex $npair 0] > [lindex $mpair 0]} {
				set wordpairs [lreplace $wordpairs $m $m $npair]
				set wordpairs [lreplace $wordpairs $n $n $mpair]
				set npair $mpair
				set changed 1
			}
			incr m
		}
		incr n
	}
	set n 0 
	set m 1
	while {$m < $len} {
		set npair [lindex $wordpairs $n]
		set mpair [lindex $wordpairs $m]
				;#	MERGE OVERLAPPING TIME BLOCKS
		if {[lindex $mpair 0] < [lindex $npair 1]} {
			if {[lindex $mpair 1] > [lindex $npair 1]} {
				set nupair [list [lindex $npair 0] [lindex $mpair 1]]
				set wordpairs [lreplace $wordpairs $n $n $nupair]
			}
			set wordpairs [lreplace $wordpairs $m $m]
			set changed 1
			incr len -1
		} else {
			incr m
			incr n
		}
	}

	set n 0 
	set m 1
	while {$m < $len} {
		set npair [lindex $wordpairs $n]
		set mpair [lindex $wordpairs $m]
				;#	CHECK FOR GAPS TOO SHORT TO SPLICE
		if {[lindex $mpair 0] - [lindex $npair 1] <= $mingap} {
			Inf "Gap Between Samplepairs Too Small For Splices, At [lindex $npair 1]"
			return {}
		}
		incr m
		incr n
	}
	if {$changed} {
		set nuwords {}
		$listing delete 1.0 end
		foreach wordpair $wordpairs {
			set nuwords [concat $nuwords $wordpair]
			set line [lindex $wordpair 0]
			append line "  " [lindex $wordpair 1]
			$listing insert end "$line\n"
		}
	}
	return $nuwords
}

#------- Remove Pitch from part of sound

proc RemovePitchElements {fnam} {

	global pr_rpe rpepitch rpepitchlo rpemidi rpemidilo rpenote rpeoct rpehifrq rpe_t rpe_timepairs rpe_top rpe_bot
	global mu pa evv rpesmpcnt rp_res rpe_retain  rpe_timepairsbak snack_enabled
	global rpepitchbak rpepitchlobak rpehifrqbak ckit_filindex cklist previous_clean rpeall rp_clr shortwindows
	BakupRpe
	catch {unset rpemidi}
	catch {unset rpemidilo}

	set srate $pa($fnam,$evv(SRATE))
	set sampdur [expr $pa($fnam,$evv(INSAMS)) / $pa($fnam,$evv(CHANS))]
	set minsplice [expr int(round(20 * $evv(MS_TO_SECS) * $srate))]
	set mingap [expr $minsplice * 2]
	set dur $pa($fnam,$evv(DUR))

	set balancefile $evv(DFLT_OUTNAME)
	append balancefile 0
	append balancefile $evv(TEXT_EXT)
	
	set outfile $evv(DFLT_OUTNAME)
	append outfile 0
	append outfile $evv(SNDFILE_EXT)
	set f .rpe
	
	if [Dlg_Create $f "REMOVE PITCHED ELEMENTS" "set pr_rpe 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0 -bd 0]
		set f1 [frame $f.1 -bd 0]
		set f3 [frame $f.3 -bd 0]
		set f4 [frame $f.4 -bd 0]
		set f5 [frame $f.5 -bd 0]
		set f6 [frame $f.6 -bd 0]
		set f7 [frame $f.7 -bd 0]
		set f8 [frame $f.8 -bd 0]

		if {[info exists shortwindows]} {
			set this_height 8
		} else {
			set this_height 16
		}
		set rpe_t [text $f7.t -setgrid true -wrap word -width 76 -height $this_height \
		-xscrollcommand "$f7.sx set" -yscrollcommand "$f7.sy set"]
		scrollbar $f7.sy -orient vert  -command ".rpe.7.t yview"
		scrollbar $f7.sx -orient horiz -command ".rpe.7.t xview"
		pack $f7.t -side left -fill both -expand true
		pack $f7.sy -side right -fill y

		button $f0.keep -text "" -width 11 -command {} -bd 0
		pack $f0.keep -side left -padx 2
		button $f0.quit -text "Abandon" -command "set pr_rpe 0"
		if {$snack_enabled} {
			button $f0.see -text "Sound View" -command "SnackDisplay $evv(SN_TIMEPAIRS) $rpe_t $evv(GRPS_OUT) $fnam" -bg $evv(SNCOLOR)
			pack $f0.see -side left -padx 40
		}
		pack $f0.quit -side right -padx 2
		pack $f0 -side top -fill x -expand true
		button $f1.clean    -text "Clean Sound" -width 11 -command "set pr_rpe 1" -bg $evv(EMPH)
		button $f1.playsrc -text "Play Source" -width 11 -command "PlaySndfile $fnam 0"		
		if {$snack_enabled} {
			button $f1.playout -text "View Output" -width 11 -command "PlayCleanedOutput"
		} else {
			button $f1.playout -text "Play Output" -width 11 -command "PlayCleanedOutput"
		}
		bind $f <Key-space> "PlayCleanedOutput"
		button $f1.a -text "A" -bd 4 -command "PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfile.wav] 0" -width 2 -bg $evv(HELP)
		button $f1.reset -text "Reset" -command ReinitRpe
		button $f1.recov -text "Recover" -command DeleteAllTemporaryFiles
		pack $f1.clean $f1.playsrc $f1.playout $f1.a $f1.reset $f1.recov -side left -padx 2
		checkbutton $f1.retain -text "Retain only this pitch" -variable rpe_retain
		pack $f1.retain -side right
		pack $f1 -side top -fill x -expand true

		label $f3.llp -text "Pitch"
		entry $f3.pitch -textvariable rpepitch -width 6 -state readonly
		radiobutton $f3.a  -text "A"  -width 2 -variable rpenote -command "SetRpeNote A"  -value 0
		radiobutton $f3.bb -text "Bb" -width 2 -variable rpenote -command "SetRpeNote Bb" -value 1
		radiobutton $f3.b  -text "B"  -width 2 -variable rpenote -command "SetRpeNote B"  -value 2
		radiobutton $f3.c  -text "C"  -width 2 -variable rpenote -command "SetRpeNote C"  -value 3
		radiobutton $f3.c# -text "C#" -width 2 -variable rpenote -command "SetRpeNote C#" -value 4
		radiobutton $f3.d  -text "D"  -width 2 -variable rpenote -command "SetRpeNote D"  -value 5
		radiobutton $f3.eb -text "Eb" -width 2 -variable rpenote -command "SetRpeNote Eb" -value 6
		radiobutton $f3.e  -text "E"  -width 2 -variable rpenote -command "SetRpeNote E"  -value 7
		radiobutton $f3.f  -text "F"  -width 2 -variable rpenote -command "SetRpeNote F"  -value 8
		radiobutton $f3.f# -text "F#" -width 2 -variable rpenote -command "SetRpeNote F#" -value 9
		radiobutton $f3.g  -text "G"  -width 2 -variable rpenote -command "SetRpeNote G"  -value 10
		radiobutton $f3.ab -text "Ab" -width 2 -variable rpenote -command "SetRpeNote Ab" -value 11
		pack $f3.llp $f3.pitch -side left -padx 2
		pack $f3.a $f3.bb $f3.b $f3.c $f3.c# $f3.d $f3.eb $f3.e $f3.f $f3.f# $f3.g $f3.ab -side left
		pack $f3 -side top -fill x -expand true

		label $f4.llo -text "          Octave"
		radiobutton $f4.m5 -text "-5" -width 2 -variable rpeoct -command "SetRpeOct" -value -5
		radiobutton $f4.m4 -text "-4" -width 2 -variable rpeoct -command "SetRpeOct" -value -4
		radiobutton $f4.m3 -text "-3" -width 2 -variable rpeoct -command "SetRpeOct" -value -3
		radiobutton $f4.m2 -text "-2" -width 2 -variable rpeoct -command "SetRpeOct" -value -2
		radiobutton $f4.m1 -text "-1" -width 2 -variable rpeoct -command "SetRpeOct" -value -1
		radiobutton $f4.0  -text "0"  -width 2 -variable rpeoct -command "SetRpeOct" -value 0
		radiobutton $f4.1  -text "1"  -width 2 -variable rpeoct -command "SetRpeOct" -value 1
		radiobutton $f4.2  -text "2"  -width 2 -variable rpeoct -command "SetRpeOct" -value 2
		radiobutton $f4.3  -text "3"  -width 2 -variable rpeoct -command "SetRpeOct" -value 3
		radiobutton $f4.4  -text "4"  -width 2 -variable rpeoct -command "SetRpeOct" -value 4
		radiobutton $f4.5  -text "5"  -width 2 -variable rpeoct -command "SetRpeOct" -value 5
		pack $f4.llo -side left -padx 2
		pack $f4.m5 $f4.m4 $f4.m3 $f4.m2 $f4.m1 $f4.0 $f4.1 $f4.2 $f4.3 $f4.4 $f4.5  -side left
		pack $f4 -side top -fill x -expand true

		label $f5.ll -text "Lower Pitch Limit (optional)"
		entry $f5.lo -textvariable rpepitchlo -width 6 -state readonly
		button $f5.down -text "Down" -command "SetRpeLow 0"
		button $f5.up   -text "Up" -command "SetRpeLow 1"
		pack $f5.ll $f5.lo $f5.down $f5.up -side left -padx 2
		label $f5.ll2 -text "Max frq of harmonics to be deleted"
		entry $f5.max -textvariable rpehifrq -width 12
		pack $f5.max $f5.ll2 -side right -padx 2
		pack $f5 -side top -fill x -expand true
		frame $f.5a -bg [option get . foreground {}] -height 1
		pack $f.5a -side top -fill x -expand true -pady 1

		checkbutton $f6.all -text "Clean All" -variable rpeall -command "SetSmpcnt rpe_all $sampdur; set rpeall 0"
		pack $f6.all -side top
		label $f6.ll -text "Start And End Samples Of Regions To Be Cleaned"
		frame $f6.kkk
		radiobutton	$f6.kkk.sc -variable rpesmpcnt -text "End Of File Sample" -command "SetSmpcnt rpe_t $sampdur; set rpesmpcnt 0" -value 1
		radiobutton	$f6.kkk.res -variable rp_res -text "Restore Last Run Vals" -command "LastClean rpe_t; set rp_res 0" -value 1
		radiobutton	$f6.kkk.clr -variable rp_clr -text "Clear Values" -command "ClearClean $rpe_t; set rp_clr 0" -value 1
		pack $f6.ll -side top
		pack $f6.kkk.sc $f6.kkk.res $f6.kkk.clr -side left -padx 4
		pack $f6.kkk -side top
		pack $f6 -side top -fill x -pady 2

		pack $f7 -side top -fill both -expand true

		Scrolled_Listbox $f8.l -width 110 -height 6 -selectmode single
		pack $f8.l -side top -fill both -expand true
		pack $f8 -side top -pady 2
		wm resizable $f 1 1
		bind $f <Escape> {set pr_rpe 0}
		bind $f <Return> {set pr_rpe 1}
	}
	set rpeall 0
	set rpe_retain 0
	wm title $f "REMOVE PITCHED ELEMENTS FROM [file tail $fnam]"
	$f.8.l.list delete 0 end
	$f.7.t delete 1.0 end
	set rpenote -1
	set rpeoct 6
	set pr_rpe 0
	set rpe_lastmidi -1
	set rpe_lastmidilo -1
	set rpe_lasthifrq -1
	set rpe_timepairs {}
	set rpepitch ""
	ForceVal .rpe.3.pitch ""
	set rpepitchlo ""
	ForceVal .rpe.5.lo $rpepitchlo
	set rpehifrq ""
	ForceVal .rpe.5.max $rpehifrq
	raise $f
	update idletasks
	StandardPosition2 .rpe
	set finished 0
	My_Grab 0 $f pr_rpe $f
	while {!$finished} {
		tkwait variable pr_rpe
		switch -- $pr_rpe {
			1 {
				set rpe_recalc 0
				set rpehifrq [string trim $rpehifrq]
				if {[string length $rpehifrq] <= 0} {
					Inf "No High Frequency Limit Entered"
					continue
				}
				if {![IsNumeric $rpehifrq]} {
					Inf "Invalid High Frequency Limit Entered"
					continue
				}
				if {($rpehifrq < $mu(MINPITCH)) || ($rpehifrq > $mu(MAXMFRQ))} {
					Inf "High Frequency Limit Is Out Of Range ($mu(MINPITCH) To $mu(MAXMFRQ))"
					continue
				}
				if {![info exists rpemidi]} {
					Inf "No Pitch Specified"	
					continue
				}
				set themiditop [HzToMidi $rpehifrq]
				if {$themiditop <= $rpemidi} {
					Inf "High Frequency Limit Too Low For Pitch Being Used"
					continue
				}
				if {$rpehifrq != $rpe_lasthifrq} {
					set rpe_recalc 1
				}
				if {$rpemidi != $rpe_lastmidi} {
					set rpe_top [DecPlaces [expr $rpemidi + 1.5] 1]
					if {$rpe_top > $mu(MIDIMAX)} {
						set rpe_top $mu(MIDIMAX)
					}
					set rpe_recalc 1
					set rpe_pitchchanged 1
					set rpe_lastmidi $rpemidi
				} else {
					set rpe_pitchchanged 0
				}
				if {[info exists rpemidilo]} {									;#	IF THERE IS LOPITCH INFO
					if {$rpe_pitchchanged || ($rpemidilo != $rpe_lastmidilo)} {	;#	IF PITCH OR LOPITCH HAS CHANGED
						set rpe_bot [DecPlaces [expr $rpemidilo - 1.5] 1]		;# RECALC REP_BOT
						set rpe_recalc 1
					}
					set rpe_lastmidilo $rpemidilo
				} else {														;#	IF THERE IS NO LOPITCH INFO	
					if {$rpe_pitchchanged || ($rpe_lastmidilo != -1)} {			;#	IF PITCH HAS CHANGED or THERE WAS LOPITCH LAST TIME
						set rpe_bot [DecPlaces [expr $rpemidi - 1.5] 1]			;# RECALC REP_BOT
						set rpe_recalc 1
					}
					set rpe_lastmidilo -1
				}
				if {$rpe_bot < $mu(MIDIMIN)} {
					set rpe_bot $mu(MIDIMIN)
				}
					;#	CHECK TIME PAIRS

				set rpe_retime 1
				set rpe_timepairs [CleanSortTimes $rpe_t $mingap 1]
				if {[llength $rpe_timepairs] <= 0} {
					continue
				}
				set rpe_timepairsbak $rpe_timepairs
				if {![CreateBalanceFile rpe $balancefile $minsplice $srate $sampdur $dur]} {
					continue
				}
				$f.8.l.list delete 0 end
				if {![RunRpe $fnam $rpe_recalc $rpe_retime $dur $rpe_retain]} {
					set rpepitchbak $rpepitch
					set rpepitchlobak $rpepitchlo
					set rpehifrqbak $rpehifrq
					continue
				}
				.rpe.0.keep config -text "Keep Output" -command "set pr_rpe 2" -bg $evv(EMPH) -bd 2		
				.rpe.1.clean config -text "" -command {} -bd 0 -bg [option get . background {}]
				if {$snack_enabled} {
					.rpe.1.playout config -bg $evv(SNCOLOR)	
				} else {
					.rpe.1.playout config -bg $evv(EMPH)	
				}
			}
			2 {
				if {![file exists $outfile]} {
					Inf "Cannot Find The Output File"
					.rpe.0.keep config -text "" -command {} -bd 0 -bg [option get . background {}]
					.rpe.1.clean config -text "Clean Sound" -command "set pr_rpe 1" -bg $evv(EMPH) -bd 2		
					continue
				}
				set nufnam $evv(CLEANKIT_NAME)
				append nufnam $ckit_filindex
				append nufnam $evv(SNDFILE_EXT)
				if {[file exists $nufnam]} {
					Inf "'$nufnam' Already Exists"
					continue
				}
				if [catch {file rename $outfile $nufnam} zit] {
					Inf "Cannot Rename Output File To '$nufnam'"
					continue
				}
				if {[DoParse $nufnam 0 0 0] <= 0} {
					if {![file delete $nufnam]} {
						Inf "Failed To Delete Bad File '$nufnam'"
					}
					continue
				}
				$cklist insert end $nufnam
				incr ckit_filindex

				.rpe.1.clean config -text "Clean Sound" -command "set pr_rpe 1" -bg $evv(EMPH) -bd 2
				.rpe.0.keep config -text "" -command {} -bd 0 -bg [option get . background {}]
				.rpe.1.playout config -bg [option get . background {}]
				break
			}
			0 {
				break
			}
		}
	}
	set previous_clean [$rpe_t get 1.0 end]
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	destroy .rpe
}

proc SetRpeNote {note} {
	global rpenote rpepitch rpemidi rpemidilo rpepitchlo
	set domidi 0
	if {[string length $rpepitch] > 0} {
		set k [string first "-" $rpepitch]
		if {$k < 0} {
			set k 1
			set qq [string index $rpepitch $k]
			if {[string match $qq "#"] || [string match $qq "b"]} {
				incr k
			}
		}
		append note [string range $rpepitch $k end]
		if [regexp {[0-5]} $rpepitch] {
			set domidi 1
		}
	} else {
		catch {unset rpemidi}
	}
	set rpepitch $note
	ForceVal .rpe.3.pitch $rpepitch
	if {$domidi} {
		set rpemidi [ConvertPitchToMidi $rpepitch]
		if {[info exists rpemidilo] && ($rpemidi <= $rpemidilo)} {
			unset rpemidilo
			set rpepitchlo ""
			ForceVal .rpe.5.lo $rpepitchlo
		} elseif {[string length $rpepitchlo] > 0} {
			set val [ConvertPitchToMidi $rpepitchlo]
			if {$val <= $rpemidilo} {
				unset rpemidilo
				set rpepitchlo ""
				ForceVal .rpe.5.lo $rpepitchlo
			}
		}
	}
}

proc SetRpeOct {} {
	global rpepitch rpepitchlo rpemidi rpemidilo rpeoct
	if {[string length $rpepitch] <= 0} {
		Inf "CHOOSE THE NOTE FIRST"
		return
	}
	set k [string first "-" $rpepitch]
	if {$k < 0} {
		set k 1
		set qq [string index $rpepitch $k]
		if {[string match $qq "#"] || [string match $qq "b"]} {
			incr k
		}
	}
	incr k -1
	set rpepitch [string range $rpepitch 0 $k]
	append rpepitch $rpeoct
	ForceVal .rpe.3.pitch $rpepitch
	set rpemidi [ConvertPitchToMidi $rpepitch]
	if {[info exists rpemidilo] && ($rpemidi <= $rpemidilo)} {
		unset rpemidilo
		set rpepitchlo ""
		ForceVal .rpe.5.lo $rpepitchlo
	} elseif {[string length $rpepitchlo] > 0} {
		set val [ConvertPitchToMidi $rpepitchlo]
		if {$val <= $rpemidilo} {
			unset rpemidilo
			set rpepitchlo ""
			ForceVal .rpe.5.lo $rpepitchlo
		}
	}
}

proc SetRpeLow {up} {
	global rpemidi rpemidilo rpepitchlo
	if {![info exists rpemidi]} {
		Inf "Set The Pitch (Including The Octave) First"
		return
	}
	if {![info exists rpemidilo]} {
		set rpemidilo $rpemidi
	}
	if {$up} {
		incr rpemidilo
		if {$rpemidilo >= $rpemidi} {
			unset rpemidilo
			set rpepitchlo ""
		} else {
			set rpepitchlo [SetRpeLo $rpemidilo]
		}
	} else {
		incr rpemidilo -1
		if {$rpemidilo < 0} {
			set rpemidilo 0
		} 
		set rpepitchlo [SetRpeLo $rpemidilo]
	}
	ForceVal .rpe.5.lo $rpepitchlo
}

proc SetRpeLo {val} {
	set note [MidiToNote $val]
	set val [expr int(floor($val/12.0))]
	set val [expr $val - 5]
	append note $val
	return $note
}

proc RunRpe {fnam recalc retime dur retain} {
	global rpe_top rpe_bot rpehifrq evv
	global CDPidrun prg_dun prg_abortd

	set mode $retain
	incr mode

	set analfile $evv(DFLT_OUTNAME)
;# 2023 was ANALFILE_EXT
	append analfile 1 $evv(ANALFILE_OUT_EXT)

	set filtanal $evv(DFLT_OUTNAME)
;# 2023 was ANALFILE_EXT
	append filtanal 2 $evv(ANALFILE_OUT_EXT)

	set filtfile $evv(DFLT_OUTNAME)
	append filtfile 3 $evv(SNDFILE_EXT)

	set outfile $evv(DFLT_OUTNAME)
	append outfile 0 $evv(SNDFILE_EXT)

	set balancefile  $evv(DFLT_OUTNAME)
	append balancefile 0 $evv(TEXT_EXT)

	;#	ONLY MAKE ANALFILE, IF IT DOESN'T ALREADY EXIST

	if {![file exists $analfile]} {
		set cmd [file join $evv(CDPROGRAM_DIR) pvoc]
		lappend cmd anal 1 $fnam $analfile -c1024 -o3
		lappend cmds $cmd
	}

	;#	ONLY REDO THE FILTERING,IF IT'S NEW VALUES

	if {$recalc} {
		if [file exists $filtanal] {
			if [catch {file delete $filtanal} zub] {
				Inf	"Cannot Delete File $filtanal"
				return
			}
		}
		if [file exists $filtfile] {
			if [catch {file delete $filtfile} zub] {
				Inf	"Cannot Delete File $filtanal"
				return
			}
		}
		set cmd [file join $evv(CDPROGRAM_DIR) specnu]
		lappend cmd remove $mode $analfile $filtanal $rpe_top $rpe_bot $rpehifrq 1.0
		lappend cmds $cmd
		set cmd [file join $evv(CDPROGRAM_DIR) pvoc]
		lappend cmd synth $filtanal $filtfile
		lappend cmds $cmd
	}
	if {$recalc || $retime} {
		set cmd [file join $evv(CDPROGRAM_DIR) submix]
		lappend cmd balance $fnam $filtfile $outfile -k$balancefile -b0 -e$dur
		lappend cmds $cmd
	}
	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	set returnval 1
	.rpe.8.l.list delete 0 end
	if {![info exists cmds]} {
		return 0
	}
	Block "Cleaning Sound"
	foreach cmd $cmds {
		if [catch {open "|$cmd"} CDPidrun] {
			set line "$CDPidrun : Can't Run Process '[lrange $cmd 0 1]'."
			.rpe.8.l.list insert end $line
			set returnval 0
			break
	   	} else {
	   		fileevent $CDPidrun readable "Display_RpeBatch_Info .rpe.8.l.list"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			set line "Process '[lrange $cmd 0 1]' Failed"
			.rpe.8.l.list insert end $line
			set returnval 0
			break
		}
	}
	if {$returnval} {
		.rpe.8.l.list delete 0 end
		.rpe.8.l.list insert end "Cleaning Completed"
	} 
	UnBlock
	.rpe.8.l.list yview moveto 1.0
	return $returnval
}

proc Display_RpeBatch_Info {f} {
	global CDPidrun rundisplay prg_dun prg_abortd evv

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
		} elseif [string match END:* $line] {
			set prg_dun 1
			return
		} else {
			$f insert end $line
			return
		}
	}
	update idletasks
}

proc ReinitRpe {} {
	global rpepitch rpepitchlo rpe_timepairs rpehifrq rpemidi rpemidilo
	global rpepitchbak rpepitchlobak rpe_timepairsbak rpehifrqbak pr_rpe evv

	if [string match [.rpe.0.keep cget -text] "Keep Output"] {
		DeleteAllTemporaryFiles
		.rpe.0.keep config -text "" -command {} -bd 0 -bg [option get . background {}]
		.rpe.1.clean config -text "Clean Sound" -command "set pr_rpe 1" -bg $evv(EMPH) -bd 2
		.rpe.1.playout config -bg [option get . background {}]
		return
	}
	if {[info exists rpepitchbak]} {
		set rpepitch [string trim $rpepitchbak]
		ForceVal .rpe.3.pitch $rpepitch
		if {[string length $rpepitch] > 0} {
			set rpemidi [ConvertPitchToMidi $rpepitch]
		}
	} 
	if {[info exists rpepitchlobak]} {
		set rpepitchlo [string trim $rpepitchlobak]
		ForceVal .rpe.5.lo $rpepitchlo
		if {[string length $rpepitchlo] > 0} {
			set rpemidilo [ConvertPitchToMidi $rpepitchlo]
		}
	} 
	if {[info exists rpehifrqbak]} {
		set rpehifrq $rpehifrqbak
		ForceVal .rpe.5.max $rpehifrq
	} 
	if {[info exists rpe_timepairsbak]} {
		.rpe.7.t delete 1.0 end
		set rpe_timepairs $rpe_timepairsbak
		foreach {time0 time1} $rpe_timepairs {
			.rpe.7.t insert end "$time0\t$time1\n"
		}
	}
}

proc BakupRpe {} {
	global rpepitch rpepitchlo rpe_timepairs rpehifrq
	global rpepitchbak rpepitchlobak rpe_timepairsbak rpehifrqbak
	catch {unset rpepitchbak}
	catch {unset rpepitchlobak}
	catch {unset rpehifrqbak}
	catch {unset rpe_timepairsbak}
	if {[info exists rpepitch]} {
		if {[regexp {[0-5]} $rpepitch]} {
			set rpepitchbak $rpepitch
		}
	}
	if {[info exists rpepitchlo] && ([string length $rpepitchlo] > 0)} {
		set rpepitchlobak $rpepitchlo
	} 
	if {[info exists rpehifrq]} {
		set rpehifrqbak $rpehifrq
	} 
	if {[info exists rpe_timepairs]} {
		set rpe_timepairsbak $rpe_timepairs
	}
}

#----- Remove signal in all analysis window channels, below a specified level 

proc GeneralDenoise {fnam} {
	global pr_denoi denoistt denoiend denoipersist denoigain denoisplice pa evv shortwindows
	global denoipersist_last denoigain_last denoisplice_last denoistt_last denoiend_last denoisub_last
	global den_timepairs den_newbal snack_enabled denoi_swi
	global den_timepairsbak den_t denoisub denoisubbak denoismpcnt denoi_res denoiall denoi_fornoise
	global denoipersistbak denoigainbak denoisplicebak denoisttbak denoiendbak ckit_filindex cklist previous_clean
	set f .denoi
	
	catch {unset den_timepairsbak}
	catch {unset denoisplice_last}
	catch {unset denoistt_last}
	catch {unset denoiend_last}

	if {$pa($fnam,$evv(CHANS)) > 1} {
		Inf "Mono Files Only"
		return
	} 
	set srate [expr double ($pa($fnam,$evv(SRATE)))]
	set sampdur $pa($fnam,$evv(INSAMS))
	set dur		$pa($fnam,$evv(DUR))
	set frametime [expr 1026.0 / (8.0 * $srate)]

	set minsplice [expr int(round(20 * $evv(MS_TO_SECS) * $srate))]
	set mingap [expr $minsplice * 2]

	set balancefile $evv(DFLT_OUTNAME)
	append balancefile 0
	append balancefile $evv(TEXT_EXT)

	set outfile $evv(DFLT_OUTNAME)
	append outfile 0
	append outfile $evv(SNDFILE_EXT)

	if [Dlg_Create $f "GENERAL DENOISE" "set pr_denoi 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0 -bd 0]
		set f1 [frame $f.1 -bd 0]
		set fx [frame $f.x -bd 0]
		set f2 [frame $f.2 -bd 0]
		set f3 [frame $f.3 -bd 0]
		set fy [frame $f.y -bd 0]
		set fz [frame $f.z -bd 0]
		set f4 [frame $f.4 -bd 0]

		if {[info exists shortwindows]} {
			set this_height 8
		} else {
			set this_height 16
		}
		set den_t [text $fz.t -setgrid true -wrap word -width 76 -height $this_height \
		-xscrollcommand "$fz.sx set" -yscrollcommand "$fz.sy set"]
		scrollbar $fz.sy -orient vert  -command ".denoi.7.t yview"
		scrollbar $fz.sx -orient horiz -command ".denoi.7.t xview"
		pack $fz.t -side left -fill both -expand true
		pack $fz.sy -side right -fill y

		button $f0.keep -text "" -width 11 -command {} -bd 0
		pack $f0.keep -side left -padx 2
		if {$snack_enabled} {
			button $f0.see -text "Sound View" -command "SnackDisplay $evv(SN_TIMEPAIRS) noiseg $evv(GRPS_OUT) $fnam" -bg $evv(SNCOLOR)
			pack $f0.see -side left -padx 2
		}
		button $f0.quit -text "Abandon" -command "set pr_denoi 0"
		if {$snack_enabled} {
			frame $f0.1
			checkbutton $f0.1.where -text "Vals For Noise Segment" -variable denoi_fornoise -command "DenoiRoute $fnam"
			pack $f0.1.where -side left
		}
		pack $f0.quit -side right -padx 2
		if {$snack_enabled} {
			pack $f0.1 -side right -padx 40
		}
		pack $f0 -side top -fill x -expand true
		button $f1.clean -text "Clean Sound" -width 11 -command "set pr_denoi 1" -bg $evv(EMPH)
		button $f1.playsrc -text "Play Source" -width 11 -command "PlaySndfile $fnam 0"		
		if {$snack_enabled} {
			button $f1.playout -text "View Output" -width 11 -command "PlayCleanedOutput"
		} else {
			button $f1.playout -text "Play Output" -width 11 -command "PlayCleanedOutput"
		}
		bind $f <Key-space> "PlayCleanedOutput"
		button $f1.reset -text "Reset" -command "ReinitDenoi 0"
		button $f1.recov -text "Recover" -command DeleteAllTemporaryFiles
		pack $f1.clean $f1.playsrc $f1.playout $f1.reset $f1.recov -side left -padx 2
		pack $f1 -side top -fill x -expand true

		checkbutton $fx.sub -variable denoisub -text "Subtract as well as gate"
		pack $fx.sub -side right -padx 2
		pack $fx -side top -fill x -expand true

		label $f2.ls -text " Noise Only segment: Start Time (samples)"
		entry $f2.es -textvariable denoistt -width 12
		label $f2.le -text "End Time (samples)"
		entry $f2.ee -textvariable denoiend -width 12
		label $f2.lc -text "Splice Duration (1 - 50 ms)"
		entry $f2.ec -textvariable denoisplice -width 12
		pack $f2.ls $f2.es $f2.le $f2.ee $f2.lc $f2.ec -side left -padx 2
		pack $f2 -side top -pady 1

		label $f3.lp -text "Persistance of deletable noise feature ( 1 - 1000 ms)"
		entry $f3.ep -textvariable denoipersist -width 12
		label $f3.lg -text "Noise Pregain (1 - 40)"
		entry $f3.eg -textvariable denoigain -width 12
		pack $f3.lp $f3.ep $f3.lg $f3.eg -side left -padx 2
		pack $f3 -side top -pady 1

		frame $f.3a -bg [option get . foreground {}] -height 1
		pack $f.3a -side top -fill x -expand true -pady 1
		label $fy.ll -text "To Clean Only Certain Region(s) Of File, Enter Start And End Samples Of Region(s)"
		frame $fy.kkk
		checkbutton $fy.kkk.all -text "Clean All" -variable denoiall -command "SetSmpcnt denois_all $sampdur; set denoiall 0"
		pack $fy.kkk.all -side top
		radiobutton	$fy.kkk.sc -variable denoismpcnt -text "End Of File Sample" -command "SetSmpcnt den_t $sampdur; set denoismpcnt 0" -value 1
		radiobutton	$fy.kkk.res -variable denoi_res -text "Restore Last Run Vals" -command "LastClean den_t; set denoi_res 0" -value 1
		radiobutton	$fy.kkk.swi -variable denoi_swi -text "Vals Below To Noise Seg" -command "SwapNoiParams $fnam; set denoi_swi 0" -value 1

		pack $fy.ll -side top
		pack $fy.kkk.sc $fy.kkk.res $fy.kkk.swi -side left -padx 4
		pack $fy.kkk -side top
		pack $fy -side top -fill x -pady 2

		pack $fz -side top -fill both -expand true

		Scrolled_Listbox $f4.l -width 110 -height 6 -selectmode single
		pack $f4.l -side top -fill both -expand true
		pack $f4 -side top -pady 2
		wm resizable $f 1 1

		bind .denoi.2.es <Right> {focus .denoi.2.ee}
		bind .denoi.2.ee <Right> {focus .denoi.2.ec}
		bind .denoi.2.ec <Right> {focus .denoi.3.ep}
		bind .denoi.3.ep <Right> {focus .denoi.3.eg}
		bind .denoi.3.eg <Right> {focus .denoi.2.es}
		bind .denoi.2.es <Left> {focus .denoi.3.eg}
		bind .denoi.2.ee <Left> {focus .denoi.2.es}
		bind .denoi.2.ec <Left> {focus .denoi.2.ee}
		bind .denoi.3.ep <Left> {focus .denoi.2.ec}
		bind .denoi.3.eg <Left> {focus .denoi.3.ep}
		bind .denoi.2.es <Down> {focus .denoi.3.ep}
		bind .denoi.2.ee <Down> {focus .denoi.3.ep}
		bind .denoi.2.ec <Down> {focus .denoi.3.eg}
		bind .denoi.3.ep <Up> {focus .denoi.2.es}
		bind .denoi.3.eg <Up> {focus .denoi.2.ec}
		bind .denoi.3.ep <Down> {focus $den_t}
		bind .denoi.3.eg <Down> {focus $den_t}
		bind $f <Escape> {set pr_denoi 0}
		bind $f <Return> {set pr_denoi 1}
	}
	if {$snack_enabled} {
		set denoi_fornoise 1
		.denoi.0.see config -command "SnackDisplay $evv(SN_TIMEPAIRS) noiseg $evv(GRPS_OUT) $fnam"
	}
	set denoiall 0
	set denoisub 1
	wm title $f "GENERAL DENOISE THE FILE [file tail $fnam]"
	set denoigain 1.2
	set denoipersist [DecPlaces [expr 8.0 * $frametime * $evv(SECS_TO_MS)] 5]
	set denoisplice 3.0
	set denoigain_last $denoigain
	set denoipersist_last $denoipersist
	$f.4.l.list delete 0 end
	set pr_denoi 0
	raise $f
	update idletasks
	StandardPosition2 .denoi
	set finished 0
	My_Grab 0 $f pr_denoi $f
	while {!$finished} {
		tkwait variable pr_denoi
		switch -- $pr_denoi {
			1 {
				set denoisplice [string trim $denoisplice]
				if {[string length $denoisplice] <= 0} {
					Inf "No Noise Splice Duration Entered"
					continue
				}
				if {![IsNumeric $denoisplice] || ($denoisplice < 1.0) || ($denoisplice >= 50.0)} {
					Inf "Invalid Noise Splice Duration Entered"
					continue
				}
				set denoistt [string trim $denoistt]
				if {[string length $denoistt] <= 0} {
					Inf "No Noise Start Time Entered"
					continue
				}
				if {![regexp {[0-9]+} $denoistt] || ($denoistt < 0) || ($denoistt >= $sampdur)} {
					Inf "Invalid Noise Start Time Entered"
					continue
				}
				set denoiend [string trim $denoiend]
				if {[string length $denoiend] <= 0} {
					Inf "No Noise End Time Entered"
					continue
				}
				if {![regexp {[0-9]+} $denoiend] || ($denoiend <= 0) || ($denoiend > $sampdur)} {
					Inf "Invalid Noise End Time Entered"
					continue
				}
				set cutlen [expr double($denoiend - $denoistt)/$srate]
				if {$cutlen <= 0.0} {
					Inf "Incompatible Noise Start And End Times Entered"
					continue
				} elseif {$cutlen <= [expr 2.0 * $denoisplice * $evv(MS_TO_SECS)]} {
					Inf "Noise Segment Too Short For Splices"
					continue
				}
				set denoigain [string trim $denoigain]
				if {[string length $denoigain] <= 0} {
					Inf "No Pregain Value Entered"
					continue
				}
				if {![IsPositiveNumber $denoigain]} {
					Inf "Invalid Pregain Value Entered"
					continue
				}
				if {$denoigain < 1.0} {
					set denoigain 1.0
				} elseif {$denoigain > 40.0} {
					set denoigain 40.0
				}
				set denoipersist [string trim $denoipersist]
				if {[string length $denoipersist] <= 0} {
					Inf "No Persist Value Entered"
					continue
				}
				if {![IsPositiveNumber $denoipersist]} {
					Inf "Invalid Persist Value Entered"
					continue
				}
				if {$denoipersist < 1.0} {
					set denoipersist 1.0
				} elseif {$denoipersist > 1000.0} {
					set denoipersist 1000.0
				}
				$f.4.l.list delete 0 end

					;#	CHECK TIME PAIRS

				set den_newbal 0

				catch {unset nutimepairs}


				set nutimepairs [CleanSortTimes $den_t $mingap 0]
				set len [llength $nutimepairs]
				if {$len <= 0} {									;#	IF WE'RE NOISE REDUCING THE WHOLE FILE (i.e. WE DON'T NEED A BALANCEFILE)
					if [file exists $balancefile] {					;#	IF WE WERE NOT DOING THIS BEFORE (i.e. A BALANCEFILE EXISTS)
						if [catch {file delete $balancefile} zub] {	;#	DELETE THE EXISTING BALANCE FILE, AND PROCEED
							Inf "Cannot Delete File '$balancefile'"
							continue
						}
						set den_newbal 1
					}
				} elseif {$len == 1} {
					continue
				} else {											;#	IF THERE ARE BRKPNT TIMES, WE'RE DENOISING BITS OF THE FILE
					set den_newbal 0								;#	CHECK TO SEE IF THE BREAKPOINT DATA HAS CHANGED
					if {[info exists den_timepairs]} {
						if {[llength $den_timepairs] == $len} {
							set den_retime 0
							foreach time0 $den_timepairs time1 $nutimepairs {
								if {$time0 != $time1} {
									set den_retime 1
									break
								}
							}
							if {$den_retime} {							;#	IF BREAKPOINT DATA HAS CHANGED, SET THE NEW VALUES
								set den_timepairs $nutimepairs
							}
						}
					} else {
						set den_timepairs $nutimepairs
					}												;#	CREATE (OR RE-CREATE) THE BALANCEFILE		
					if {![CreateBalanceFile den $balancefile $minsplice $srate $sampdur $dur]} {
						continue
					}
					set den_newbal 1
				}
				if {![RunDenoi $fnam $denoistt $denoiend $denoisplice $denoipersist $denoigain $dur $denoisub 0]} {
					set denoigain_last	  $denoigain
					set denoipersist_last $denoipersist
					set denoisplice_last  $denoisplice
					set denoistt_last	  $denoistt
					set denoiend_last	  $denoiend
					set denoisub_last	  $denoisub
					if {[info exists den_timepairs]} {
						set den_timepairsbak $den_timepairs
					}
					continue
				}
				set denoigain_last	  $denoigain
				set denoipersist_last $denoipersist
				set denoisplice_last  $denoisplice
				set denoistt_last	  $denoistt
				set denoiend_last	  $denoiend
				set denoisub_last	  $denoisub
				if {[info exists den_timepairs]} {
					set den_timepairsbak $den_timepairs
				}
				.denoi.0.keep config -text "Keep Output" -command "set pr_denoi 2" -bg $evv(EMPH) -bd 2
				.denoi.1.clean config -text "" -command {} -bg [option get . background {}] -bd 0
				if {$snack_enabled} {
					.denoi.1.playout config -bg $evv(SNCOLOR)	
				} else {
					.denoi.1.playout config -bg $evv(EMPH)	
				}
			}
			2 {
				if {![file exists $outfile]} {
					Inf "Cannot Find The Output File"
					.denoi.0.keep config -text "" -command {} -bg [option get . background {}] -bd 0
					.denoi.1.clean config -text "Clean Sound" -command "set pr_denoi 1" -bg $evv(EMPH) -bd 2
					continue
				}
				set nufnam $evv(CLEANKIT_NAME)
				append nufnam $ckit_filindex
				append nufnam $evv(SNDFILE_EXT)
				if {[file exists $nufnam]} {
					Inf "'$nufnam' ALREADY EXISTS"
					continue
				}
				if [catch {file rename $outfile $nufnam} zit] {
					Inf "Cannot Rename Output File To '$nufnam'"
					continue
				}
				if {[DoParse $nufnam 0 0 0] <= 0} {
					if {![file delete $nufnam]} {
						Inf "Failed To Delete Bad File '$nufnam'"
					}
					continue
				}
				$cklist insert end $nufnam
				incr ckit_filindex
				.denoi.0.keep config -text "" -command {} -bg [option get . background {}] -bd 0
				.denoi.1.clean config -text "Clean Sound" -command "set pr_denoi 1" -bg $evv(EMPH) -bd 2
				.denoi.1.playout config -bg [option get . background {}]
				break
			}
			0 {
				break
			}
		}
	}
	DeleteAllTemporaryFiles
	if {[info exists denoipersist]} {
		set denoipersistbak $denoipersist
	}
	if {[info exists denoigain]} { 
		set denoigainbak $denoigain
	}
	if {[info exists denoisplice]} {
		set denoisplicebak $denoisplice
	}
	if {[info exists denoistt]} {
		set denoisttbak $denoistt
	} 
	if {[info exists denoiend]} {
		set denoiendbak $denoiend
	}
	if {[info exists denoisub]} {
		set denoisubbak $denoisub
	}
	set previous_clean [$den_t get 1.0 end]
	My_Release_to_Dialog $f
	destroy .denoi
}

proc ReinitDenoi {stereo} {
	global den_timepairs den_timepairsbak evv
	global denoipersist denoisplice denoistt denoiend pr_denoi
	global denoipersist_last denoisplice_last denoistt_last denoiend_last denoisub_last
	global denoipersistbak denoigainbak denoisttbak denoiendbak denoisub denoisubbak
	if {$stereo} {
		set ff .stdenoi
	} else {
		set ff .denoi
	}
	if [string match [$ff.0.keep cget -text] "Keep Output"] {
		if {$stereo} {
			set ifile $evv(DFLT_OUTNAME)						;#	don't delete temporary separated channels
			append ifile 111 $evv(SNDFILE_EXT)
			set	ofnam [file rootname [file tail $ifile]]
			set ofnam1 $ofnam 
			append ofnam1 _c1 $evv(SNDFILE_EXT)
			set ofnam2 $ofnam 
			append ofnam2 _c2 $evv(SNDFILE_EXT)
			DeleteAllTemporaryFilesExcept $ifile $ofnam1 $ofnam2
		} else {
			DeleteAllTemporaryFiles
		}
		$ff.0.keep config -text "" -command {} -bg [option get . background {}] -bd 0
		$ff.1.clean config -text "Clean Sound" -command "set pr_denoi 1" -bg $evv(EMPH) -bd 2
		$ff.1.playout config -bg [option get . background {}]
		return
		$ff.4.1.list delete 0 end
	}
	if {[info exists den_timepairsbak]} {
		$ff.z.t delete 1.0 end
		set den_timepairs $den_timepairsbak
		foreach {time0 time1} $den_timepairs {
			$ff.z.t insert end "$time0\t$time1\n"
		}
	}
	if {[info exists denoistt_last]} {
			set denoistt $denoistt_last
		if {[info exists denoigain_last]} { 
			set denoigain $denoigain_last
		}
		if {[info exists denoisplice_last]} {
			set denoisplice $denoisplice_last
		}
		if {[info exists denoipersist_last]} {
			set denoipersist $denoipersist_last
		} 
		if {[info exists denoiend_last]} {
			set denoiend $denoiend_last
		}
		if {[info exists denoisub_last]} {
			set denoisub $denoisub_last
		}
	} elseif {[info exists denoipersistbak]} {
		set denoipersist $denoipersistbak
		if {[info exists denoigainbak]} { 
			set denoigain $denoigainbak
		}
		if {[info exists denoisplicebak]} {
			set denoisplice $denoisplicebak
		}
		if {[info exists denoisttbak]} {
			set denoistt $denoisttbak
		} 
		if {[info exists denoiendbak]} {
			set denoiend $denoiendbak
		}
		if {[info exists denoisubbak]} {
			set denoisub $denoisubbak
		}
	}
}

proc RunDenoi {fnam start end splice persist gain dur sub stereo} {
	global CDPidrun prg_dun prg_abortd denoistt_last denoiend_last denoisplice_last denoigain_last denoipersist_last evv
	global den_newbal denoisub_last dother
;# 2023
	global denoi_chan2
	
	if {$stereo} {
		set ff .stdenoi
	} else {
		set ff .denoi
	}
	set noisfile $evv(DFLT_OUTNAME)
	append noisfile 1
	append noisfile $evv(SNDFILE_EXT)

	set analfile $evv(DFLT_OUTNAME)
	append analfile 2
;# 2023 was ANALFILE_EXT
	append analfile $evv(ANALFILE_OUT_EXT)
	
	set noisanal $evv(DFLT_OUTNAME)
	append noisanal 3
;# 2023 was ANALFILE_EXT
	append noisanal $evv(ANALFILE_OUT_EXT)

	set outanal $evv(DFLT_OUTNAME)
	append outanal 4
;# 2023 was ANALFILE_EXT
	append outanal $evv(ANALFILE_OUT_EXT)

	set balancefile $evv(DFLT_OUTNAME)
	append balancefile 0
	append balancefile $evv(TEXT_EXT)

	set synfile $evv(DFLT_OUTNAME)
	append synfile 5
	append synfile $evv(SNDFILE_EXT)

	set outfile $evv(DFLT_OUTNAME)
	append outfile 0
	append outfile $evv(SNDFILE_EXT)

	set do_it 0 

	;#	ONLY ANALYSE SRC FILE, IF ANAL FILE DOESN'T ALREADY EXIST
;# 2023 ---->
	if {$stereo && $denoi_chan2} {
		catch {file delete $analfile}
		catch {file delete $noisfile}
		catch {file delete $noisanal}
		catch {file delete $outanal}
		catch {file delete $synfile}
	}
;# <---- 2023
	if {![file exists $analfile]} {
		set cmd [file join $evv(CDPROGRAM_DIR) pvoc]
		lappend cmd anal 1 $fnam $analfile -c1024 -o3
		lappend cmds $cmd
		set do_it 1
	}

	;#	IF SRC_ANAL ALREADY EXISTS, ONLY CUT NOISE FILE, IF IT DOESN'T ALREADY EXIST OR PARAMETERS HAVE CHANGED

	if {!$do_it} {
		if {[info exists denoistt_last]} {
			if {($denoistt_last != $start) || ($denoiend_last != $end) || ($denoisplice_last != $splice)} {
				set do_it 1	;#	IF ANY EDIT-NOISE PARAMS HAVE CHANGED
			} elseif {![file exists $noisfile]} {
				set do_it 1	;#	OR IF EDIT FAILED
			}
		}
	}
	if {$do_it} {
		set cmd [file join $evv(CDPROGRAM_DIR) sfedit]
		lappend cmd cut 3 $fnam $noisfile $start $end -w$splice
		lappend cmds $cmd
	}

	;#	ONLY ANALYSE NOISE FILE, IF NEW NOISFILE HAS BEEN MADE, OR IF NOISEANAL FILE DOESN'T ALREADY EXIST

	if {$do_it || ![file exists $noisanal]} {
		set cmd [file join $evv(CDPROGRAM_DIR) pvoc]
		lappend cmd anal 1 $noisfile $noisanal -c1024 -o3
		lappend cmds $cmd
		set do_it 1
	}

	;#	ONLY REDO THE NOISE-REDUCTION IF NEW NOISANAL FILE MADE OR PARAMS CHANGED

	if {!$do_it} {
		if {($denoipersist_last != $persist) || ($denoigain_last != $gain) || ($denoisub_last != $sub)} {
			set do_it 1	;#	IF ANY NOISE-REDUCE PARAMS HAVE CHANGED
		} elseif {![file exists $outanal]} {
			set do_it 1	;#	OR IF NOISE-REDUCTION FAILED TO HAPPEN
		}
	}
	if {$do_it} {
		set cmd [file join $evv(CDPROGRAM_DIR) specnu]
		if {$sub} {
			lappend cmd subtract
		} else {
			lappend cmd clean
		}
		lappend cmd $analfile $noisanal $outanal $persist $gain
		lappend cmds $cmd
	}		
	
	;#	DO CROSS-MIX WITH ORIGINAL IF BALANCEFILE EXISTS, IF PREVIOUS PARAMS ALTERED OR IF BALANCEFILE IS NEW

	if {[file exists $balancefile]} {
		if {$do_it || $den_newbal || ![file exists $synfile]} {
			set cmd [file join $evv(CDPROGRAM_DIR) pvoc]
			lappend cmd synth $outanal $synfile
			lappend cmds $cmd
			set cmd [file join $evv(CDPROGRAM_DIR) submix]
			lappend cmd balance $fnam $synfile $outfile -k$balancefile -b0 -e$dur
			lappend cmds $cmd
		}
	} else {

	;#	OR GO DIRECTLY TO OUTPUT IF NO BALANCEFILE EXISTS, IF PREVIOUS PARAMS ALTERED OR BALANCEFILE DID EXIST LAST TIME

		if {$do_it || $den_newbal || ![file exists $outfile]} {
			set cmd [file join $evv(CDPROGRAM_DIR) pvoc]
			lappend cmd synth $outanal $outfile
			lappend cmds $cmd
		}
	}
	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	set returnval 1
	$ff.4.l.list delete 0 end
	if {![info exists cmds]} {
		return 0
	}
	if {$stereo} {
		if {[info exists dother]} {
			set mmsg "Cleaning 2nd Channel of Sound"
		} else {
			set mmsg "Cleaning 1st Channel of Sound"
		}
	} else {
		set mmsg "Cleaning Sound"
	}
	Block $mmsg
	foreach cmd $cmds {
		if [catch {open "|$cmd"} CDPidrun] {
			set line "$CDPidrun : Can't Run Process '[lrange $cmd 0 1]'."
			$ff.4.l.list insert end $line
			set returnval 0
			break
	   	} else {
	   		fileevent $CDPidrun readable "Display_RpeBatch_Info $ff.4.l.list"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			set line "Process '[lrange $cmd 0 1]' Failed"
			$ff.4.l.list insert end $line
			set returnval 0
			break
		}
	}
	if {$returnval} {
		$ff.4.l.list delete 0 end
		$ff.4.l.list insert end "Cleaning Completed"
		if {$stereo} {
			if {![info exists dother]} {
				set dother 1
			} else {
				catch {unset dother}
			}
		}
	} else {
		if {$stereo && [info exists dother]} {
			unset dother
		}
	} 
	UnBlock
	$ff.4.l.list yview moveto 1.0
	return $returnval
}

proc DenoiRoute {fnam stereo} {
	global denoi_fornoise den_t evv noisegstfnam
	switch -- $denoi_fornoise {
		1 {
			if {$stereo} {
				.stdenoi.0.see config -command "SnackDisplay $evv(SN_TIMEPAIRS) noisegst $evv(GRPS_OUT) $noisegstfnam"
			} else {
				.denoi.0.see config -command "SnackDisplay $evv(SN_TIMEPAIRS) noiseg $evv(GRPS_OUT) $fnam"
			}
		}
		0 {
			if {$stereo} {
				.stdenoi.0.see config -command "SnackDisplay $evv(SN_TIMEPAIRS) $den_t $evv(GRPS_OUT) $noisegstfnam"
			} else {
				.denoi.0.see config -command "SnackDisplay $evv(SN_TIMEPAIRS) $den_t $evv(GRPS_OUT) $fnam"
			}
		}
	}
}

proc SwapNoiParams {fnam stereo} {
	global den_t denoistt denoiend denoi_fornoise evv noisegstfnam
	set zdata [$den_t get 1.0 end]
	set vals {}
	foreach item $zdata {
		set item [string trim $item]
		if {[string length $item] > 0} {
			lappend vals $item
		}
	}
	if {[llength $vals] == 2} {
		set denoistt [lindex $vals 0]
		set denoiend [lindex $vals 1]
		$den_t delete 1.0 end
		set denoi_fornoise 0
		if {$stereo} {
			.stdenoi.0.see config -command "SnackDisplay $evv(SN_TIMEPAIRS) $den_t $evv(GRPS_OUT) $noisegstfnam"
		} else {
			.denoi.0.see config -command "SnackDisplay $evv(SN_TIMEPAIRS) $den_t $evv(GRPS_OUT) $fnam"
		}
	}
}

#------- Reinsert part of original signal into sound being cleaned

proc DoUnNoise {fnam forig} {
	global pr_unn unn_timepairs unn_timepairsbak unn_t unn_res unn_clr shortwindows
	global pa evv ckit_filindex cklist snack_enabled

	set evv(UNSPLICE) 20
	set srate $pa($fnam,$evv(SRATE))
	set sampdur [expr $pa($fnam,$evv(INSAMS)) / $pa($fnam,$evv(CHANS))]
	set minsplice [expr int(round($evv(UNSPLICE) * $evv(MS_TO_SECS) * $srate))]
	set mingap [expr $minsplice * 2]
	set dur  $pa($fnam,$evv(DUR))
	set dur2 $pa($forig,$evv(DUR))
	if {$dur2  < $dur} {
		set dur $dur2
	}
	set balancefile $evv(DFLT_OUTNAME)
	append balancefile 0
	append balancefile $evv(TEXT_EXT)
	
	set outfile $evv(DFLT_OUTNAME)
	append outfile 0
	append outfile $evv(SNDFILE_EXT)
	set f .unn
	
	if [Dlg_Create $f "REINSERT ORIGINAL SIGNAL" "set pr_unn 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0 -bd 0]
		set f1 [frame $f.1 -bd 0]
		set f2 [frame $f.2 -bd 0]
		set f3 [frame $f.3 -bd 0]
		set f4 [frame $f.4 -bd 0]
		if {[info exists shortwindows]} {
			set this_height 8
		} else {
			set this_height 16
		}
		set unn_t [text $f3.t -setgrid true -wrap word -width 76 -height $this_height \
		-xscrollcommand "$f3.sx set" -yscrollcommand "$f3.sy set"]
		scrollbar $f3.sy -orient vert  -command ".unn.3.t yview"
		scrollbar $f3.sx -orient horiz -command ".unn.3.t xview"
		pack $f3.t -side left -fill both -expand true
		pack $f3.sy -side right -fill y

		button $f0.keep -text "" -command {} -bd 0
		pack $f0.keep -side left -padx 2
		if {$snack_enabled} {
			button $f0.see -text "Sound View Original" -command "SnackDisplay $evv(SN_TIMEPAIRS) unnoiseg $evv(GRPS_OUT) $forig" -bg $evv(SNCOLOR)
			pack $f0.see -side left -padx 2
		}
		button $f0.quit -text "Abandon" -command "set pr_unn 0"
		pack $f0.quit -side right -padx 2
		pack $f0 -side top -fill x -expand true
		button $f1.clean    -text "Reinsert Snd" -width 11 -command "set pr_unn 1" -bg $evv(EMPH)
		button $f1.playsrc -text "Play Source" -width 11 -command "PlaySndfile $fnam 0"		
		if {$snack_enabled} {
			button $f1.playout -text "View Output" -width 11 -command "PlayCleanedOutput"
		} else {
			button $f1.playout -text "Play Output" -width 11 -command "PlayCleanedOutput"
		}
		bind $f <Key-space> "PlayCleanedOutput"
		button $f1.reset -text "Reset" -command ReinitUnn
		button $f1.recov -text "Recover" -command DeleteAllTemporaryFiles
		pack $f1.clean $f1.playsrc $f1.playout $f1.reset $f1.recov -side left -padx 2
		pack $f1 -side top -fill x -expand true
		frame $f.1a -bg [option get . foreground {}] -height 1
		pack $f.1a -side top -fill x -expand true -pady 1

		label $f2.ll -text "Start And End Samples Of Regions To Be Reinserted"
		pack $f2.ll -side top
		pack $f2 -side top -fill x -pady 2

		radiobutton	$f2.kkk -variable unn_res -text "Restore Last Run Vals" -command "LastClean unn_t; set unn_res 0" -value 1
		radiobutton	$f2.clr -variable unn_clr -text "Clear Values" -command "ClearClean $unn_t; set unn_clr 0" -value 1
		pack $f2.kkk $f2.clr -side top

		pack $f3 -side top -fill both -expand true

		Scrolled_Listbox $f4.l -width 110 -height 6 -selectmode single
		pack $f4.l -side top -fill both -expand true
		pack $f4 -side top -pady 2
		wm resizable $f 1 1
		bind $f <Escape> {set pr_unn 0}
		bind $f <Return> {set pr_unn 1}
	}
	wm title $f "REINSERT ORIGINAL SIGNAL [file tail $forig] INTO [file tail $fnam]"
	$f.4.l.list delete 0 end
	$f.3.t delete 1.0 end
	set pr_unn 0
	set unn_timepairs {}
	raise $f
	update idletasks
	StandardPosition2 .unn
	set finished 0
	My_Grab 0 $f pr_unn $f
	while {!$finished} {
		tkwait variable pr_unn
		switch -- $pr_unn {
			1 {
				set unn_timepairs [CleanSortTimes $unn_t $mingap 1]
				if {[llength $unn_timepairs] <= 0} {
					continue
				}
				set unn_timepairsbak $unn_timepairs
				if {![CreateBalanceFile unn $balancefile $minsplice $srate $sampdur $dur]} {
					continue
				}
				$f.4.l.list delete 0 end
				if {![RunUnn $fnam $forig $dur]} {
					continue
				}
				.unn.0.keep config -text "Keep Output" -command "set pr_unn 2" -bg $evv(EMPH) -bd 2
				.unn.1.clean config -text "" -command {} -bg [option get . background {}] -bd 0
				if {$snack_enabled} {
					.unn.1.playout config -bg $evv(SNCOLOR)	
				} else {
					.unn.1.playout config -bg $evv(EMPH)	
				}
			}
			2 {
				if {![file exists $outfile]} {
					Inf "Cannot Find The Output File"
					.unn.0.keep config -text "" -command {} -bg [option get . background {}] -bd 0
					.unn.1.clean config -text "Clean Sound" -command "set pr_unn 1" -bg $evv(EMPH) -bd 2
					continue
				}
				set nufnam $evv(CLEANKIT_NAME)
				append nufnam $ckit_filindex
				append nufnam $evv(SNDFILE_EXT)
				if {[file exists $nufnam]} {
					Inf "'$nufnam' ALREADY EXISTS"
					continue
				}
				if [catch {file rename $outfile $nufnam} zit] {
					Inf "Cannot Rename Output File To '$nufnam'"
					continue
				}
				if {[DoParse $nufnam 0 0 0] <= 0} {
					if {![file delete $nufnam]} {
						Inf "Failed To Delete Bad File '$nufnam'"
					}
					continue
				}
				$cklist insert end $nufnam
				incr ckit_filindex
				.unn.0.keep config -text "" -command {} -bg [option get . background {}] -bd 0
				.unn.1.clean config -text "Clean Sound" -command "set pr_unn 1" -bg $evv(EMPH) -bd 2
				.unn.1.playout config -bg [option get . background {}]
				break
			}
			0 {
				break
			}
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	destroy .unn
}

proc ReinitUnn {} {
	global unn_timepairs unn_timepairsbak pr_unn evv

	if [string match [.unn.0.keep cget -text] "Keep Output"] {
		DeleteAllTemporaryFiles
		.unn.0.keep config -text "" -command {} -bg [option get . background {}] -bd 0
		.unn.1.clean config -text "Reinsert Snd" -command "set pr_unn 1" -bg $evv(EMPH) -bd 2
		.unn.1.playout config -bg [option get . background {}]
		return
	}
	if {[info exists unn_timepairsbak]} {
		.unn.3.t delete 1.0 end
		set unn_timepairs $unn_timepairsbak
		foreach {time0 time1} $unn_timepairs {
			.unn.3.t insert end "$time0\t$time1\n"
		}
	}
}

proc RunUnn {fnam forig dur} {
	global evv
	global CDPidrun prg_dun prg_abortd

	set outfile $evv(DFLT_OUTNAME)
	append outfile 0 $evv(SNDFILE_EXT)

	set balancefile  $evv(DFLT_OUTNAME)
	append balancefile 0 $evv(TEXT_EXT)

	set cmd [file join $evv(CDPROGRAM_DIR) submix]
	lappend cmd balance $fnam $forig $outfile -k$balancefile -b0 -e$dur

	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	set returnval 1
	.unn.4.l.list delete 0 end
	Block "Cleaning Sound"
	set finished 0
	while {!$finished} {
		if [catch {open "|$cmd"} CDPidrun] {
			set line "$CDPidrun : Can't Run Process."
			.unn.4.l.list insert end $line
			set returnval 0
			set finished 1
			break
		} else {
	   		fileevent $CDPidrun readable "Display_RpeBatch_Info .unn.4.l.list"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			set line "Process Failed"
			.unn.4.l.list insert end $line
			set returnval 0
			set finished 1
			break
		}
		if {$returnval} {
			.unn.4.l.list delete 0 end
			.unn.4.l.list insert end "Cleaning Completed"
		} 
		set finished 1
	}
	UnBlock
	.unn.4.l.list yview moveto 1.0
	return $returnval
}

#-------- Gate out specified areas of signal

proc DoDisNoise {fnam} {
	global pr_disn dis_timepairs dis_timepairsbak dis_t dissplice disnsmpcnt previous_clean disn_res disn_clr shortwindows
	global pa evv ckit_filindex cklist disnall snack_enabled

	set evv(DISSPLICE) 15
	set srate $pa($fnam,$evv(SRATE))
	set sampdur [expr $pa($fnam,$evv(INSAMS)) / $pa($fnam,$evv(CHANS))]
	set minsplice [expr int(round($evv(DISSPLICE) * $evv(MS_TO_SECS) * $srate))]
	set mingap [expr $minsplice * 2]
	set dur  $pa($fnam,$evv(INSAMS))
	set balancefile $evv(DFLT_OUTNAME)
	append balancefile 0
	append balancefile $evv(TEXT_EXT)
	
	set outfile $evv(DFLT_OUTNAME)
	append outfile 0
	append outfile $evv(SNDFILE_EXT)
	set f .dis
	
	if [Dlg_Create $f "GATE BAD SIGNAL" "set pr_disn 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0 -bd 0]
		set f1 [frame $f.1 -bd 0]
		set f1a [frame $f.1a -bd 0]
		set f2 [frame $f.2 -bd 0]
		set f3 [frame $f.3 -bd 0]
		set f4 [frame $f.4 -bd 0]

		if {[info exists shortwindows]} {
			set this_height 8
		} else {
			set this_height 16
		}
		set dis_t [text $f3.t -setgrid true -wrap word -width 76 -height $this_height \
		-xscrollcommand "$f3.sx set" -yscrollcommand "$f3.sy set"]
		scrollbar $f3.sy -orient vert  -command ".dis.3.t yview"
		scrollbar $f3.sx -orient horiz -command ".dis.3.t xview"
		pack $f3.t -side left -fill both -expand true
		pack $f3.sy -side right -fill y

		button $f0.keep -text "" -command {} -bd 0
		pack $f0.keep -side left -padx 2
		button $f0.quit -text "Abandon" -command "set pr_disn 0"
		if {$snack_enabled} {
			button $f0.see -text "Sound View"  -command "SnackDisplay $evv(SN_TIMEPAIRS) $dis_t $evv(GRPS_OUT) $fnam" -bg $evv(SNCOLOR)
			pack $f0.see -side left -padx 40
		}
		pack $f0.quit -side right -padx 2
		pack $f0 -side top -fill x -expand true
		button $f1.clean    -text "Clean Sound" -width 11 -command "set pr_disn 1" -bg $evv(EMPH)
		button $f1.playsrc -text "Play Source" -width 11 -command "PlaySndfile $fnam 0"		
		if {$snack_enabled} {
			button $f1.playout -text "View Output" -width 11 -command "PlayCleanedOutput"
		} else {
			button $f1.playout -text "Play Output" -width 11 -command "PlayCleanedOutput"
		}
		bind $f <Key-space> "PlayCleanedOutput"
		button $f1.reset -text "Reset" -command ReinitDis
		button $f1.recov -text "Recover" -command DeleteAllTemporaryFiles
		pack $f1.clean $f1.playsrc $f1.playout $f1.reset $f1.recov -side left -padx 2
		pack $f1 -side top -fill x -expand true

		label $f1a.ll -text "Splicelen (mS)"
		entry $f1a.e -textvariable dissplice -width 6
		button $f1a.b1 -text 15 -width 4 -command {set dissplice 15}
		button $f1a.b2 -text 3  -width 4 -command {set dissplice 3}
		pack $f1a.ll $f1a.e $f1a.b1 $f1a.b2 -side left -padx 2
		pack $f1a -side top -fill x -pady 2 
		frame $f.1b -bg [option get . foreground {}] -height 1
		pack $f.1b -side top -fill x -expand true -pady 1

		checkbutton $f2.all -text "Clean All" -variable disnall -command "SetSmpcnt dis_all $sampdur; set disnall 0"
		pack $f2.all -side top
		label $f2.ll -text "Start And End Samples Of Regions To Be Gated"
		frame $f2.kkk
		radiobutton	$f2.kkk.sc -variable disnsmpcnt -text "End Of File Sample" -command "SetSmpcnt dis_t $sampdur; set disnsmpcnt 0" -value 1
		radiobutton	$f2.kkk.res -variable disn_res -text "Restore Last Run Vals" -command "LastClean dis_t; set disn_res 0" -value 1
		radiobutton	$f2.kkk.clr -variable disn_clr -text "Clear Values" -command "ClearClean $dis_t; set disn_clr 0" -value 1

		pack $f2.ll -side top
		pack $f2.kkk.sc $f2.kkk.res $f2.kkk.clr -side left -pady 4
		pack $f2.kkk -side top
		pack $f2 -side top -fill x -pady 2

		pack $f3 -side top -fill both -expand true

		Scrolled_Listbox $f4.l -width 110 -height 6 -selectmode single
		pack $f4.l -side top -fill both -expand true
		pack $f4 -side top -pady 2
		wm resizable $f 1 1
		bind $f <Escape> {set pr_disn 0}
		bind $f <Return> {set pr_disn 1}
	}
	set disnall 0
	wm title $f "GATE BAD SIGNAL FROM FILE [file tail $fnam]"
	set dissplice $evv(DISSPLICE)
	$f.4.l.list delete 0 end
	$f.3.t delete 1.0 end
	set pr_disn 0
	set dis_timepairs {}
	raise $f
	update idletasks
	StandardPosition2 .dis
	set finished 0
	My_Grab 0 $f pr_disn $f
	while {!$finished} {
		tkwait variable pr_disn
		$f.4.l.list delete 0 end
		switch -- $pr_disn {
			1 {
				set dissplice [string trim $dissplice]
				if {[string length $dissplice] > 0} {
					if {![IsPositiveNumber $dissplice]} {
						Inf "Invalid Splice Length"
						continue
					}
				} else {
					set dissplice $evv(DISSPLICE)
				}
				set minsplice [expr int(round($dissplice * $evv(MS_TO_SECS) * $srate))]
				set mingap [expr $minsplice * 2]

				set dis_timepairs [CleanSortTimes $dis_t $mingap 1]
				if {[llength $dis_timepairs] <= 0} {
					continue
				}
				if {![CreateGateFile $balancefile $dur .dis.4.l.list]} {
					continue
				}
				$f.4.l.list delete 0 end
				set dis_timepairsbak $dis_timepairs
				if {![RunDis $fnam $dissplice .dis.4.l.list]} {
					continue
				}
				.dis.0.keep config -text "Keep Output" -command "set pr_disn 2" -bg $evv(EMPH) -bd 2
				.dis.1.clean config -text "" -command {} -bg [option get . background {}] -bd 0
				if {$snack_enabled} {
					.dis.1.playout config -bg $evv(SNCOLOR)	
				} else {
					.dis.1.playout config -bg $evv(EMPH)	
				}
			}
			2 {
				if {![file exists $outfile]} {
					Inf "Cannot Find The Output File"
					.dis.0.keep config -text "" -command {} -bg [option get . background {}] -bd 0
					.dis.1.clean config -text "Clean Sound" -command "set pr_disn 1" -bg $evv(EMPH) -bd 2
					continue
				}
				set nufnam $evv(CLEANKIT_NAME)
				append nufnam $ckit_filindex
				append nufnam $evv(SNDFILE_EXT)
				if {[file exists $nufnam]} {
					Inf "'$nufnam' Already Exists"
					continue
				}
				if [catch {file rename $outfile $nufnam} zit] {
					Inf "Cannot Rename Output File To '$nufnam'"
					continue
				}
				if {[DoParse $nufnam 0 0 0] <= 0} {
					if {![file delete $nufnam]} {
						Inf "Failed To Delete Bad File '$nufnam'"
					}
					continue
				}
				$cklist insert end $nufnam
				incr ckit_filindex
				.dis.0.keep config -text "" -command {} -bg [option get . background {}] -bd 0
				.dis.1.clean config -text "Clean Sound" -command "set pr_disn 1" -bg $evv(EMPH) -bd 2
				.dis.1.playout config -bg [option get . background {}]
				break
			}
			0 {
				break
			}
		}
	}
	set previous_clean [$dis_t get 1.0 end]
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	destroy .dis
}

proc ReinitDis {} {
	global dis_timepairs dis_timepairsbak pr_disn evv

	if [string match [.dis.0.keep cget -text] "Keep Output"] {
		DeleteAllTemporaryFiles
		.dis.0.keep config -text "" -command {} -bg [option get . background {}] -bd 0
		.dis.1.clean config -text "Clean Source" -command "set pr_disn 1" -bg $evv(EMPH) -bd 2
		.dis.1.playout config -bg [option get . background {}]
		return
	}
	if {[info exists dis_timepairsbak]} {
		.dis.3.t delete 1.0 end
		set dis_timepairs $dis_timepairsbak
		foreach {time0 time1} $dis_timepairs {
			.dis.3.t insert end "$time0\t$time1\n"
		}
	}
}

proc RunDis {fnam splice f} {
	global evv
	global CDPidrun prg_dun prg_abortd

	set outfile $evv(DFLT_OUTNAME)
	append outfile 0 $evv(SNDFILE_EXT)

	set balancefile $evv(DFLT_OUTNAME)
	append balancefile 0 $evv(TEXT_EXT)

	set cmd [file join $evv(CDPROGRAM_DIR) sfedit]
	lappend cmd masks 3 $fnam $outfile $balancefile -w$splice

	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	set returnval 1
	$f delete 0 end
	Block "Cleaning Sound"
	set finished 0
	while {!$finished} {
		if [catch {open "|$cmd"} CDPidrun] {
			set line "$CDPidrun : Can't Run Process."
			$f insert end $line
			set returnval 0
			set finished 1
			break
		} else {
	   		fileevent $CDPidrun readable "Display_RpeBatch_Info $f"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			set line "Process Failed"
			$f insert end $line
			set returnval 0
			set finished 1
			break
		}
		if {$returnval} {
			$f delete 0 end
			$f insert end "Cleaning Completed"
		} 
		set finished 1
	}
	UnBlock
	$f yview moveto 1.0
	return $returnval
}

proc CreateGateFile {balancefile dur f} {
	global dis_timepairs
	set cnt 0
	foreach {time0 time1} $dis_timepairs {
		if {$time0 >= $dur} {
			break
		}
		incr cnt
	}
	if {$cnt == 0} {
		$f insert end "No Relevant Gating Areas In File"
		return 0
	}
	if [catch {open $balancefile "w"} zit] {
		Inf "Cannot Open Temporary Balance-File '$balancefile'"
		return 0
	}
	set cnt 0
	foreach {time0 time1} $dis_timepairs {
		if {$time0 >= $dur} {
			break
		}
		set line [list $time0 $time1]	
		puts $zit $line
		incr cnt
	}
	close $zit
	return 1
}

#--------- Filter out low or high frequencies in parts of signal

proc DoNoiseDecouple {fnam cutpitch} {
	global pr_ndcou dcou_timepairs dcou_timepairsbak dcou_t dcousplice dcoupass dcoustop dcoulosmpcnt previous_clean
	global pa wstk evv dcoulo ckit_filindex cklist dcoulo_res dcoubo dcouall dcougain dcoulo_clr
	global dcoustoplast dcoupasslast dcousplicelast dcou_filttop snack_enabled shortwindows

	set evv(DISSPLICE) 15
	set evv(DISLOSPLICE) 55
	set srate $pa($fnam,$evv(SRATE))
	set dcou_filttop [expr $srate / 2.0]
	set sampdur [expr $pa($fnam,$evv(INSAMS)) / $pa($fnam,$evv(CHANS))]
	set minsplice [expr int(round($evv(DISSPLICE) * $evv(MS_TO_SECS) * $srate))]
	set mingap [expr $minsplice * 2]
	set dur  $pa($fnam,$evv(INSAMS))

	set evv(FLT_MAXFRQ)	[expr $srate/2.0]

	set balancefile $evv(DFLT_OUTNAME)
	append balancefile 0
	append balancefile $evv(TEXT_EXT)
	
	set outfile $evv(DFLT_OUTNAME)
	append outfile 0
	append outfile $evv(SNDFILE_EXT)
	set f .dcou
	
	if [Dlg_Create $f "DECOUPLE NOISE" "set pr_ndcou 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0 -bd 0]
		set f1 [frame $f.1 -bd 0]
		set f1a [frame $f.1a -bd 0]
		set fx [frame $f.x -bd 0]
		set fz [frame $f.z -bd 0]
		set f2 [frame $f.2 -bd 0]
		set f3 [frame $f.3 -bd 0]
		set f4 [frame $f.4 -bd 0]

		if {[info exists shortwindows]} {
			set this_height 8
		} else {
			set this_height 16
		}
		set dcou_t [text $f3.t -setgrid true -wrap word -width 76 -height $this_height \
		-xscrollcommand "$f3.sx set" -yscrollcommand "$f3.sy set"]
		scrollbar $f3.sy -orient vert  -command ".dcou.3.t yview"
		scrollbar $f3.sx -orient horiz -command ".dcou.3.t xview"
		pack $f3.t -side left -fill both -expand true
		pack $f3.sy -side right -fill y

		button $f0.keep -text "" -command {} -bd 0
		pack $f0.keep -side left -padx 2
		button $f0.quit -text "Abandon" -command "set pr_ndcou 0"
		if {$snack_enabled} {
			button $f0.see -text "Sound View"  -command "SnackDisplay $evv(SN_TIMEPAIRS) $dcou_t $evv(GRPS_OUT) $fnam" -bg $evv(SNCOLOR)
			pack $f0.see -side left -padx 40
		}
		pack $f0.quit -side right -padx 2
		pack $f0 -side top -fill x -expand true
		button $f1.clean    -text "Clean Sound" -width 11 -command "set pr_ndcou 1" -bg $evv(EMPH)
		button $f1.playsrc -text "Play Source" -width 11 -command "PlaySndfile $fnam 0"		
		if {$snack_enabled} {
			button $f1.playout -text "View Output" -width 11 -command "PlayCleanedOutput"
		} else {
			button $f1.playout -text "Play Output" -width 11 -command "PlayCleanedOutput"
		}
		bind $f <Key-space> "PlayCleanedOutput"
		button $f1.reset -text "Reset" -command ReinitDcou
		button $f1.recov -text "Recover" -command DeleteAllTemporaryFiles
		pack $f1.clean $f1.playsrc $f1.playout $f1.reset $f1.recov -side left -padx 2
		pack $f1 -side top -fill x -expand true

		label $f1a.l1 -text "Pass Above Frq"
		entry $f1a.e1 -textvariable dcoupass -width 6
		label $f1a.l2 -text "Cut Below Frq"
		entry $f1a.e2 -textvariable dcoustop -width 6
		label $f1a.l3 -text "Splicelen (mS)"
		entry $f1a.e3 -textvariable dcousplice -width 6
		label $f1a.lr -text "LoCut "
		radiobutton	$f1a.r1 -variable dcoulo -command "SetDcoulo" -value 1
		radiobutton	$f1a.r2 -variable dcoulo -command "SetDcoulo" -value 2
		radiobutton	$f1a.r3 -variable dcoulo -command "SetDcoulo" -value 3
		radiobutton	$f1a.r4 -variable dcoulo -command "SetDcoulo" -value 4
		radiobutton	$f1a.r5 -variable dcoulo -command "SetDcoulo" -value 5
		label $f1a.ll -text "Gain (optional)"
		entry $f1a.e -textvariable dcougain -width 6

		pack $f1a.l1 $f1a.e1 $f1a.l2 $f1a.e2 $f1a.l3 $f1a.e3 $f1a.r1 $f1a.r2 $f1a.r3 $f1a.r4 $f1a.r5 $f1a.ll $f1a.e -side left -padx 2
		pack $f1a -side top -fill x -pady 2 

		radiobutton	$fx.r1  -variable dcoubo -command "SetDcouBoth $cutpitch" -value 1
		radiobutton	$fx.r3  -variable dcoubo -command "SetDcouBoth $cutpitch" -value 3
		radiobutton	$fx.r5  -variable dcoubo -command "SetDcouBoth $cutpitch" -value 5
		radiobutton	$fx.r7  -variable dcoubo -command "SetDcouBoth $cutpitch" -value 7
		radiobutton	$fx.r9  -variable dcoubo -command "SetDcouBoth $cutpitch" -value 9
		radiobutton	$fx.r11 -variable dcoubo -command "SetDcouBoth $cutpitch" -value 11

		pack $fx.r1 $fx.r3 $fx.r5 $fx.r7 $fx.r9 $fx.r11 -side left
		pack $fx -side top

		radiobutton	$fz.r2  -variable dcoubo -command "SetDcouBoth $cutpitch" -value 2
		radiobutton	$fz.r4  -variable dcoubo -command "SetDcouBoth $cutpitch" -value 4
		radiobutton	$fz.r6  -variable dcoubo -command "SetDcouBoth $cutpitch" -value 6
		radiobutton	$fz.r8  -variable dcoubo -command "SetDcouBoth $cutpitch" -value 8
		radiobutton	$fz.r10 -variable dcoubo -command "SetDcouBoth $cutpitch" -value 10
		radiobutton	$fz.r12 -variable dcoubo -command "SetDcouBoth $cutpitch" -value 12
		radiobutton	$fz.r13 -variable dcoubo -command "SetDcouBoth $cutpitch" -value 13

		pack $fz.r13 $fz.r2 $fz.r4 $fz.r6 $fz.r8 $fz.r10 $fz.r12 -side left
		pack $fz -side top

		frame $f.1b -bg [option get . foreground {}] -height 1
		pack $f.1b -side top -fill x -expand true -pady 1

		checkbutton $f2.all -text "Clean All" -variable dcouall -command "SetSmpcnt dcou_all $sampdur; set dcouall 0"
		pack $f2.all -side top
		label $f2.ll -text "Start And End Samples Of Regions To Be Cleaned"
		frame $f2.kkk
		radiobutton	$f2.kkk.sc -variable dcoulosmpcnt -text "End Of File Sample" -command "SetSmpcnt dcou_t $sampdur; set dcoulosmpcnt 0" -value 1
		radiobutton	$f2.kkk.res -variable dcoulo_res -text "Restore Last Run Vals" -command "LastClean dcou_t; set dcoulo_res 0" -value 1
		radiobutton	$f2.kkk.clr -variable dcoulo_clr -text "Clear Values" -command "ClearClean $dcou_t; set dcoulo_clr 0" -value 1

		pack $f2.ll -side top
		pack $f2.kkk.sc $f2.kkk.res $f2.kkk.clr -side left -padx 4
		pack $f2.kkk -side top
		pack $f2 -side top -fill x -pady 2

		pack $f3 -side top -fill both -expand true

		Scrolled_Listbox $f4.l -width 110 -height 6 -selectmode single
		pack $f4.l -side top -fill both -expand true
		pack $f4 -side top -pady 2
		wm resizable $f 1 1

		bind .dcou.1a.e1 <Right> {focus .dcou.1a.e2}
		bind .dcou.1a.e2 <Right> {focus .dcou.1a.e3}
		bind .dcou.1a.e3 <Right> {focus .dcou.1a.e1}
		bind .dcou.1a.e1 <Left>  {focus .dcou.1a.e3}
		bind .dcou.1a.e2 <Left>  {focus .dcou.1a.e1}
		bind .dcou.1a.e3 <Left>  {focus .dcou.1a.e2}
		bind $f <Escape> {set pr_ndcou 0}
		bind $f <Return> {set pr_ndcou 1}
	}
	set dcougain 1.0
	set dcouall 0
	set dcoulo 0
	set dcoubo 0
	switch -- $cutpitch {
		2 {	;#	CUT BASS
			set dcougain 1
			wm title $f "REMOVE LOW FREQUENCY BLEMISH IN [file tail $fnam]"
			$f.1a.l1 config -text ""
			$f.1a.l2 config -text ""
			set dcoupass ""
			$f.1a.e1 config -bd 0 -state disabled
			set dcoustop ""
			$f.1a.e2 config -bd 0 -state disabled
			$f.1a.lr config -text "LoCut "
			$f.1a.r1 config -state normal -text 80Hz
			$f.1a.r2 config -state normal -text 100Hz
			$f.1a.r3 config -state normal -text 150Hz
			$f.1a.r4 config -state normal -text 200Hz
			$f.1a.r5 config -state normal -text 250Hz
			$f.x.r1 config -state disabled -text ""
			$f.z.r2 config -state disabled -text ""
			$f.x.r3 config -state disabled -text ""
			$f.z.r4 config -state disabled -text ""
			$f.x.r5 config -state disabled -text ""
			$f.z.r6 config -state disabled -text ""
			$f.x.r7 config -state disabled -text ""
			$f.z.r8 config -state disabled -text ""
			$f.x.r9 config -state disabled -text ""
			$f.z.r10 config -state disabled -text ""
			$f.x.r11 config -state disabled -text ""
			$f.z.r12 config -state disabled -text ""
			$f.z.r13 config -state disabled -text ""
			set dcousplice $evv(DISLOSPLICE)
		} 
		1 {	;#	HIPASS
			wm title $f "REMOVE SOUND BLEMISH FROM SIBILANT IN [file tail $fnam]"
			$f.1a.l1 config -text "Pass Above Frq"
			$f.1a.l2 config -text "Cut Below Frq"
			$f.1a.e1 config -state normal -bd 2
			set dcoupass ""
			$f.1a.e2 config -state normal -bd 2
			set dcoustop ""
			$f.1a.lr config -text ""
			$f.1a.r1 config -state disabled -text ""
			$f.1a.r2 config -state disabled -text ""
			$f.1a.r3 config -state disabled -text ""
			$f.1a.r4 config -state disabled -text ""
			$f.1a.r5 config -state disabled -text ""
			$f.x.r1 config -state normal -text "1000/1500"
			$f.z.r2 config -state normal -text "1500/2000"
			$f.x.r3 config -state normal -text "2000/2500"
			$f.z.r4 config -state normal -text "2500/3000"
			$f.x.r5 config -state normal -text "3000/3500"
			$f.z.r6 config -state normal -text "3500/4000"
			$f.x.r7 config -state normal -text "4000/4500"
			$f.z.r8 config -state normal -text "4500/5000"
			$f.x.r9 config -state normal -text "5000/5500"
			$f.z.r10 config -state normal -text "5500/6000"
			$f.x.r11 config -state normal -text "Previous"
			$f.z.r12 config -state normal -text "+ 500"
			$f.z.r13 config -state normal -text "-100"
			set dcousplice $evv(DISSPLICE)
		} 
		0 {	;#	LOPASS
			wm title $f "REMOVE NOISE BLEMISH FROM PITCH IN [file tail $fnam]"
			$f.1a.l1 config -text "Pass Below Frq"
			$f.1a.l2 config -text "Cut Above Frq"
			$f.1a.e1 config -state normal -bd 2
			set dcoupass ""
			$f.1a.e2 config -state normal -bd 2
			set dcoustop ""
			$f.1a.lr config -text ""
			$f.1a.r1 config -state disabled -text ""
			$f.1a.r2 config -state disabled -text ""
			$f.1a.r3 config -state disabled -text ""
			$f.1a.r4 config -state disabled -text ""
			$f.1a.r5 config -state disabled -text ""
			set dcousplice $evv(DISSPLICE)
			$f.x.r1 config -state normal -text "1000/1500"
			$f.z.r2 config -state normal -text "1500/2000"
			$f.x.r3 config -state normal -text "2000/2500"
			$f.z.r4 config -state normal -text "2500/3000"
			$f.x.r5 config -state normal -text "3000/3500"
			$f.z.r6 config -state normal -text "3500/4000"
			$f.x.r7 config -state normal -text "4000/4500"
			$f.z.r8 config -state normal -text "4500/5000"
			$f.x.r9 config -state normal -text "5000/5500"
			$f.z.r10 config -state normal -text "5500/6000"
			$f.x.r11 config -state normal -text "Previous"
			$f.z.r12 config -state normal -text "+ 500  "
			$f.z.r13 config -state normal -text "-100"
		}
	}
	$f.4.l.list delete 0 end
	$f.3.t delete 1.0 end
	set pr_ndcou 0
	set dcou_timepairs {}
	raise $f
	update idletasks
	StandardPosition2 .dcou
	set finished 0
	My_Grab 0 $f pr_ndcou $f
	while {!$finished} {
		tkwait variable pr_ndcou
		$f.4.l.list delete 0 end
		switch -- $pr_ndcou {
			1 {
				set dcougain [string trim $dcougain]
				if {[string length $dcougain] > 0} {
					if {![IsNumeric $dcougain]} {
						Inf "Invalid Gain Value Entered"
						continue
					} elseif {($dcougain <= 0.005 ) || ($dcougain >= 200.0)} {
						Inf "Invalid Gain Value Entered"
						continue
					}
				}
				set dcoupass [string trim $dcoupass]
				if {[string length $dcoupass] <= 0} {
					Inf "First Filter Frequency Is Missing"
					continue
				}
				if {![IsPositiveNumber $dcoupass]} {
					Inf "Invalid First Filter Frequency"
					continue
				}
				if {($dcoupass < $evv(FLT_MINFRQ)) || ($dcoupass > $evv(FLT_MAXFRQ))} {
					Inf "First Filter Frequency Out Of Range ($evv(FLT_MINFRQ) to $evv(FLT_MAXFRQ))"
					continue
				}
				set dcoustop [string trim $dcoustop]
				if {[string length $dcoustop] <= 0} {
					Inf "Second Of Filter Frequency Is Missing"
					continue
				}
				if {![IsPositiveNumber $dcoustop]} {
					Inf "Invalid Second Filter Frequency"
					continue
				}
				if {($dcoustop < $evv(FLT_MINFRQ)) || ($dcoustop > $evv(FLT_MAXFRQ))} {
					Inf "Second Filter Frequency Out Of Range ($evv(FLT_MINFRQ) to $evv(FLT_MAXFRQ))"
					continue
				}
				if {[Flteq $dcoustop $dcoupass]} {
					set msg "Filter Frequencies Cannot Be Equal"
					continue
				}
				set doreverse 0
				switch -- $cutpitch {
					0 {
						if {$dcoustop < $dcoupass} {
							set doreverse 1
						}
					}
					1 {
						if {$dcoupass < $dcoustop} {
							set doreverse 1
						}
					}
				}
				if {$doreverse} {
					set msg "Filter Frequencies Are Inverted : Reverse Them ?"
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
					set temp $dcoupass
					set dcoupass $dcoustop
					set dcoustop $temp
				}
				if {[string length $dcousplice] > 0} {
					if {![IsPositiveNumber $dcousplice]} {
						Inf "Invalid Splice Length"
						continue
					}
				} else {
					set dcousplice $evv(DISSPLICE)
				}
				set minsplice [expr int(round($dcousplice * $evv(MS_TO_SECS) * $srate))]
				set mingap [expr $minsplice * 2]

				set dcou_timepairs [CleanSortTimes $dcou_t $mingap 1]
				if {[llength $dcou_timepairs] <= 0} {
					continue
				}
				set dcou_timepairsbak $dcou_timepairs
				if {![CreateBalanceFile dcou $balancefile $minsplice $srate $sampdur $dur]} {
					continue
				}
				$f.4.l.list delete 0 end
				if {![RunDcou $fnam $minsplice $dcoupass $dcoustop .dcou.4.l.list]} {
					continue
				}
				.dcou.0.keep config -text "Keep Output" -command "set pr_ndcou 2" -bg $evv(EMPH) -bd 2
				.dcou.1.clean config -text "" -command {} -bg [option get . background {}] -bd 0
				if {$snack_enabled} {
					.dcou.1.playout config -bg $evv(SNCOLOR)	
				} else {
					.dcou.1.playout config -bg $evv(EMPH)	
				}
			}
			2 {
				if {![file exists $outfile]} {
					Inf "Cannot Find The Output File"
					.dcou.0.keep config -text "" -command {} -bg [option get . background {}] -bd 0
					.dcou.1.clean config -text "Clean Sound" -command "set pr_ndcou 1" -bg $evv(EMPH) -bd 2
					continue
				}
				set nufnam $evv(CLEANKIT_NAME)
				append nufnam $ckit_filindex
				append nufnam $evv(SNDFILE_EXT)
				if {[file exists $nufnam]} {
					Inf "'$nufnam' Already Exists"
					continue
				}
				if [catch {file rename $outfile $nufnam} zit] {
					Inf "Cannot Rename Output File To '$nufnam'"
					continue
				}
				if {[DoParse $nufnam 0 0 0] <= 0} {
					if {![file delete $nufnam]} {
						Inf "Failed To Delete Bad File '$nufnam'"
					}
					continue
				}
				$cklist insert end $nufnam
				incr ckit_filindex
				.dcou.0.keep config -text "" -command {} -bg [option get . background {}] -bd 0
				.dcou.1.clean config -text "Clean Sound" -command "set pr_ndcou 1" -bg $evv(EMPH) -bd 2
				.dcou.1.playout config -bg [option get . background {}]
				break
			}
			0 {
				break
			}
		}
	}
	set previous_clean [$dcou_t get 1.0 end]
	set dcoustoplast $dcoustop
	set dcoupasslast $dcoupass
	set dcousplicelast $dcousplice
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	destroy .dcou
}

proc ReinitDcou {} {
	global dcou_timepairs dcou_timepairsbak pr_ndcou evv

	if [string match [.dcou.0.keep cget -text] "Keep Output"] {
		DeleteAllTemporaryFiles
		.dcou.0.keep config -text "" -command {} -bg [option get . background {}] -bd 0
		.dcou.1.clean config -text "Clean Source" -command "set pr_ndcou 1" -bg $evv(EMPH) -bd 2
		.dcou.1.playout config -bg [option get . background {}]
		return
	}
	if {[info exists dcou_timepairsbak]} {
		.dcou.3.t delete 1.0 end
		set dcou_timepairs $dcou_timepairsbak
		foreach {time0 time1} $dcou_timepairs {
			.dcou.3.t insert end "$time0\t$time1\n"
		}
	}
}

proc RunDcou {fnam splice pass stop f} {
	global dcougain pa evv
	global CDPidrun prg_dun prg_abortd

	set outfile $evv(DFLT_OUTNAME)
	append outfile 0 $evv(SNDFILE_EXT)

	set filtfile $evv(DFLT_OUTNAME)
	append filtfile 1 $evv(SNDFILE_EXT)

	set balancefile $evv(DFLT_OUTNAME)
	append balancefile 0 $evv(TEXT_EXT)

	set dur $pa($fnam,$evv(DUR))

	set cmd [file join $evv(CDPROGRAM_DIR) filter]
	lappend cmd lohi 1 $fnam $filtfile -96.0 $pass $stop -t0
	if {[string length $dcougain] > 0} {
		lappend cmd -s$dcougain
	} else {
		lappend cmd -s1
	}
	lappend cmds $cmd

	set cmd [file join $evv(CDPROGRAM_DIR) submix]
	lappend cmd balance $fnam $filtfile $outfile -k$balancefile -b0 -e$dur
	lappend cmds $cmd

	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	set returnval 1
	$f delete 0 end
	if {![info exists cmds]} {
		return 0
	}
	Block "Cleaning Sound"
	foreach cmd $cmds {
		if [catch {open "|$cmd"} CDPidrun] {
			set line "$CDPidrun : Can't Run Process '[lrange $cmd 0 1]'."
			.dcou.4.l.list insert end $line
			set returnval 0
			break
	   	} else {
	   		fileevent $CDPidrun readable "Display_RpeBatch_Info .dcou.4.l.list"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			set line "Process '[lrange $cmd 0 1]' Failed"
			.dcou.4.l.list insert end $line
			set returnval 0
			break
		}
	}
	if {$returnval} {
		.dcou.4.l.list delete 0 end
		.dcou.4.l.list insert end "Cleaning Completed"
	} 
	UnBlock
	.dcou.4.l.list yview moveto 1.0
	return $returnval
}

proc SetDcoulo {} {
	global dcoulo dcoustop dcoupass
	switch -- $dcoulo {
		0 {
			Inf "No Filter Value Set"	
			set dcoustop ""
			set dcoupass ""
		}
		1	{
			set dcoustop 50.0
			set dcoupass 80.0
		}
		2	{
			set dcoustop 65.0
			set dcoupass 100.0
		}
		3	{
			set dcoustop 100.0
			set dcoupass 150.0
		}
		4	{
			set dcoustop 150.0
			set dcoupass 200.0
		}
		5	{
			set dcoustop 200.0
			set dcoupass 250.0
		}
	}
}

proc SetDcouBoth {cutpitch} {
	global dcoubo dcoupass dcoustop dcoustoplast dcoupasslast dcousplicelast dcou_filttop

	switch -- $dcoubo {
		1 {
			if {$cutpitch == 0} {
				set dcoupass 1000
				set dcoustop 1500
			} else {
				set dcoustop 1000
				set dcoupass 1500
			}
		}
		2 {
			if {$cutpitch == 0} {
				set dcoupass 1500
				set dcoustop 2000
			} else {
				set dcoustop 1500
				set dcoupass 2000
			}
		}
		3 {
			if {$cutpitch == 0} {
				set dcoupass 2000
				set dcoustop 2500
			} else {
				set dcoustop 2000
				set dcoupass 2500
			}
		}
		4 {
			if {$cutpitch == 0} {
				set dcoupass 2500
				set dcoustop 3000
			} else {
				set dcoustop 2500
				set dcoupass 3000
			}
		}
		5 {
			if {$cutpitch == 0} {
				set dcoupass 3000
				set dcoustop 3500
			} else {
				set dcoustop 3000
				set dcoupass 3500
			}
		}
		6 {
			if {$cutpitch == 0} {
				set dcoupass 3500
				set dcoustop 4000
			} else {
				set dcoustop 3500
				set dcoupass 4000
			}
		}
		7 {
			if {$cutpitch == 0} {
				set dcoupass 4000
				set dcoustop 4500
			} else {
				set dcoustop 4000
				set dcoupass 4500
			}
		}
		8 {
			if {$cutpitch == 0} {
				set dcoupass 4500
				set dcoustop 5000
			} else {
				set dcoustop 4500
				set dcoupass 5000
			}
		}
		9 {
			if {$cutpitch == 0} {
				set dcoupass 5000
				set dcoustop 5500
			} else {
				set dcoustop 5000
				set dcoupass 5500
			}
		}
		10 {
			if {$cutpitch == 0} {
				set dcoupass 5500
				set dcoustop 6000
			} else {
				set dcoustop 5500
				set dcoupass 6000
			}
		}
		11 {
			if {[info exists dcoupasslast] && [info exists dcoustoplast] && [info exists dcousplicelast]} {
				if {$cutpitch == 0} {
					if {$dcoupasslast > $dcoustoplast} {
						set dcoupass $dcoustoplast
						set dcoustop $dcoupasslast
					} else {
						set dcoupass $dcoupasslast
						set dcoustop $dcoustoplast
					}
				} else {
					if {$dcoupasslast < $dcoustoplast} {
						set dcoupass $dcoustoplast
						set dcoustop $dcoupasslast
					} else {
						set dcoupass $dcoupasslast
						set dcoustop $dcoustoplast
					}
				}
				set dcousplice dcousplicelast
			} else {
				return
			}
		}
		12 {
			if {[regexp {^[0-9]+$} $dcoustop] && [regexp {^[0-9]+$} $dcoupass]} {
				set nudcoustop [expr $dcoustop + 500]
				set nudcoupass [expr $dcoupass + 500]
			} elseif {[IsNumeric $dcoustop] && [IsNumeric $dcoupass]} {
				set nudcoustop [expr int(round($dcoustop))]
				set nudcoupass [expr int(round($dcoupass))]
				incr nudcoustop 500
				incr nudcoupass 500
			} else {
				return
			}
			if {($nudcoustop < $dcou_filttop) && ($nudcoupass < $dcou_filttop)} {
				set dcoustop $nudcoustop 
				set dcoupass $nudcoupass  
			}
		}
		13 {
			if {[regexp {^[0-9]+$} $dcoustop] && [regexp {^[0-9]+$} $dcoupass]} {
				set nudcoustop [expr $dcoustop - 100]
				set nudcoupass [expr $dcoupass - 100]
			} elseif {[IsNumeric $dcoustop] && [IsNumeric $dcoupass]} {
				set nudcoustop [expr int(round($dcoustop))]
				set nudcoupass [expr int(round($dcoupass))]
				incr nudcoustop -100
				incr nudcoupass -100
			} else {
				return
			}
			if {($nudcoustop >= 100) && ($nudcoupass >= 100)} {
				set dcoustop $nudcoustop 
				set dcoupass $nudcoupass  
			}
		}
	}
}

#----- remove unwanted sounds from signal (output is hence shorter than opiginal)

proc DoCutJunk {fnam} {
	global pr_cj cj_timepairs cj_timepairsbak cj_t cjsplice cjsmpcnt previous_clean cj_res cj_clr
	global pa evv ckit_filindex cklist cjall snack_enabled shortwindows

	set evv(DISSPLICE) 15
	set srate $pa($fnam,$evv(SRATE))
	set sampdur [expr $pa($fnam,$evv(INSAMS)) / $pa($fnam,$evv(CHANS))]
	set minsplice [expr int(round($evv(DISSPLICE) * $evv(MS_TO_SECS) * $srate))]
	set mingap [expr $minsplice * 2]

	set outfile $evv(DFLT_OUTNAME)
	append outfile 0
	append outfile $evv(SNDFILE_EXT)

	set excisefile $evv(DFLT_OUTNAME)
	append excisefile 0
	append excisefile $evv(TEXT_EXT)

	set f .cj
	
	if [Dlg_Create $f "EXCISE UNWANTED SOUNDS" "set pr_cj 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0 -bd 0]
		set f1 [frame $f.1 -bd 0]
		set f1a [frame $f.1a -bd 0]
		set f2 [frame $f.2 -bd 0]
		set f3 [frame $f.3 -bd 0]
		set f4 [frame $f.4 -bd 0]

		if {[info exists shortwindows]} {
			set this_height 8
		} else {
			set this_height 16
		}
		set cj_t [text $f3.t -setgrid true -wrap word -width 76 -height $this_height \
		-xscrollcommand "$f3.sx set" -yscrollcommand "$f3.sy set"]
		scrollbar $f3.sy -orient vert  -command ".cj.3.t yview"
		scrollbar $f3.sx -orient horiz -command ".cj.3.t xview"
		pack $f3.t -side left -fill both -expand true
		pack $f3.sy -side right -fill y

		button $f0.keep -text "" -command {} -bd 0
		pack $f0.keep -side left -padx 2
		button $f0.quit -text "Abandon" -command "set pr_cj 0"
		if {$snack_enabled} {
			button $f0.see -text "Sound View"  -command "SnackDisplay $evv(SN_TIMEPAIRS) $cj_t $evv(GRPS_OUT) $fnam" -bg $evv(SNCOLOR)
			pack $f0.see -side left -padx 40
		}
		pack $f0.quit -side right -padx 2
		pack $f0 -side top -fill x -expand true
		button $f1.clean    -text "Cut Sound" -width 11 -command "set pr_cj 1" -bg $evv(EMPH)	
		button $f1.playsrc -text "Play Source" -width 11 -command "PlaySndfile $fnam 0"		
		if {$snack_enabled} {
			button $f1.playout -text "View Output" -width 11 -command "PlayCleanedOutput"
		} else {
			button $f1.playout -text "Play Output" -width 11 -command "PlayCleanedOutput"
		}
		bind $f <Key-space> "PlayCleanedOutput"
		button $f1.reset -text "Reset" -command ReinitCj
		button $f1.recov -text "Recover" -command DeleteAllTemporaryFiles
		pack $f1.clean $f1.playsrc $f1.playout $f1.reset $f1.recov -side left -padx 2
		pack $f1 -side top -fill x -expand true

		label $f1a.l1 -text "Splicelen (mS)"
		entry $f1a.e1 -textvariable cjsplice -width 6
		button $f1a.b1 -text 15 -width 4 -command {set cjsplice 15}
		button $f1a.b2 -text 3  -width 4 -command {set cjsplice 3}
		pack $f1a.l1 $f1a.e1 $f1a.b1 $f1a.b2 -side left -padx 2
		pack $f1a -side top -fill x -pady 2 
		frame $f.1b -bg [option get . foreground {}] -height 1
		pack $f.1b -side top -fill x -expand true -pady 1

		checkbutton $f2.all -text "Clean All" -variable cjall -command "SetSmpcnt cj_all $sampdur; set cjall 0"
		pack $f2.all -side top
		label $f2.ll -text "Start And End Samples Of Regions To Be Removed"
		frame $f2.kkk
		radiobutton	$f2.kkk.sc -variable cjsmpcnt -text "End Of File Sample" -command "SetSmpcnt cj_t $sampdur; set cjsmpcnt 0" -value 1
		radiobutton	$f2.kkk.res -variable cj_res -text "Restore Last Run Vals" -command "LastClean cj_t; set cj_res 0" -value 1
		radiobutton	$f2.kkk.clr -variable cj_clr -text "Clear Values" -command "ClearClean $cj_t; set cj_clr 0" -value 1

		pack $f2.ll -side top
		pack $f2.kkk.sc $f2.kkk.res $f2.kkk.clr -side left -padx 4
		pack $f2.kkk -side top
		pack $f2 -side top -fill x -pady 2

		pack $f3 -side top -fill both -expand true

		Scrolled_Listbox $f4.l -width 110 -height 6 -selectmode single
		pack $f4.l -side top -fill both -expand true
		pack $f4 -side top -pady 2
		wm resizable $f 1 1
		bind $f <Escape> {set pr_cj 0}
		bind $f <Return> {set pr_cj 1}
	}
	set cjall 0
	wm title $f "EXCISE UNWANTED SOUNDS FROM FILE [file tail $fnam]"
	set cjsplice $evv(DISSPLICE)
	$f.4.l.list delete 0 end
	$f.3.t delete 1.0 end
	set pr_cj 0
	set cj_timepairs {}
	raise $f
	update idletasks
	StandardPosition2 .cj
	set finished 0
	My_Grab 0 $f pr_cj $f
	while {!$finished} {
		tkwait variable pr_cj
		$f.4.l.list delete 0 end
		switch -- $pr_cj {
			1 {
				set cjsplice [string trim $cjsplice]
				if {[string length $cjsplice] > 0} {
					if {![IsPositiveNumber $cjsplice]} {
						Inf "Invalid Splice Length"
						continue
					}
				} else {
					set cjsplice $evv(DISSPLICE)
				}
				set minsplice [expr int(round($cjsplice * $evv(MS_TO_SECS) * $srate))]
				set mingap [expr $minsplice * 2]

				set cj_timepairs [CleanSortTimes $cj_t $mingap 1]
				if {[llength $cj_timepairs] <= 0} {
					continue
				}
				set cj_timepairsbak $cj_timepairs
				if {![CreateExciseFile $excisefile $sampdur]} {
					continue
				}
				$f.4.l.list delete 0 end
				if {![RunCj $fnam $cjsplice .cj.4.l.list]} {
					continue
				}
				set cj_timepairsbak $cj_timepairs
				.cj.0.keep config -text "Keep Output" -command "set pr_cj 2" -bg $evv(EMPH) -bd 2
				.cj.1.clean config -text "" -command {} -bg [option get . background {}] -bd 0
				if {$snack_enabled} {
					.cj.1.playout config -bg $evv(SNCOLOR)	
				} else {
					.cj.1.playout config -bg $evv(EMPH)	
				}
			}
			2 {
				if {![file exists $outfile]} {
					Inf "Cannot Find The Output File"
					.cj.0.keep config -text "" -command {} -bg [option get . background {}] -bd 0
					.cj.1.clean config -text "Clean Sound" -command "set pr_cj 1" -bg $evv(EMPH) -bd 2
					continue
				}
				set nufnam $evv(CLEANKIT_NAME)
				append nufnam $ckit_filindex
				append nufnam $evv(SNDFILE_EXT)
				if {[file exists $nufnam]} {
					Inf "'$nufnam' Already Exists"
					continue
				}
				if [catch {file rename $outfile $nufnam} zit] {
					Inf "Cannot Rename Output File To '$nufnam'"
					continue
				}
				if {[DoParse $nufnam 0 0 0] <= 0} {
					if {![file delete $nufnam]} {
						Inf "Failed To Delete Bad File '$nufnam'"
					}
					continue
				}
				$cklist insert end $nufnam
				incr ckit_filindex
				.cj.0.keep config -text "" -command {} -bg [option get . background {}] -bd 0
				.cj.1.clean config -text "Clean Sound" -command "set pr_cj 1" -bg $evv(EMPH) -bd 2
				.cj.1.playout config -bg [option get . background {}]
				break
			}
			0 {
				break
			}
		}
	}
	set previous_clean [$cj_t get 1.0 end]
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	destroy .cj
}

proc ReinitCj {} {
	global cj_timepairs cj_timepairsbak pr_cj evv

	if [string match [.cj.0.keep cget -text] "Keep Output"] {
		DeleteAllTemporaryFiles
		.cj.0.keep config -text "" -command {} -bg [option get . background {}] -bd 0
		.cj.1.clean config -text "Clean Source" -command "set pr_cj 1" -bg $evv(EMPH) -bd 2
		.cj.1.playout config -bg [option get . background {}]
		return
	}
	if {[info exists cj_timepairsbak]} {
		.cj.3.t delete 1.0 end
		set cj_timepairs $cj_timepairsbak
		foreach {time0 time1} $cj_timepairs {
			.cj.3.t insert end "$time0\t$time1\n"
		}
	}
}

proc RunCj {fnam splice f} {
	global evv
	global CDPidrun prg_dun prg_abortd

	set outfile $evv(DFLT_OUTNAME)
	append outfile 0 $evv(SNDFILE_EXT)

	set excisefile $evv(DFLT_OUTNAME)
	append excisefile 0 $evv(TEXT_EXT)

	set cmd [file join $evv(CDPROGRAM_DIR) sfedit]
	lappend cmd excises 3 $fnam $outfile $excisefile -w$splice

	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	set returnval 1
	$f delete 0 end
	Block "Editing Sound"
	if [catch {open "|$cmd"} CDPidrun] {
		set line "$CDPidrun : Can't Run Editing Process"
		.cj.4.l.list insert end $line
		UnBlock
		return 0
		break
	} else {
	   	fileevent $CDPidrun readable "Display_RpeBatch_Info .cj.4.l.list"
	}
	vwait prg_dun
	if {$prg_abortd} {
		set prg_dun 0
	}
	if {!$prg_dun} {
		set line "Editing Process Failed"
		.cj.4.l.list insert end $line
		UnBlock
		return 0
	}
	.cj.4.l.list delete 0 end
	.cj.4.l.list insert end "Cleaning Completed"
	UnBlock
	.cj.4.l.list yview moveto 1.0
	return 1
}

proc CreateExciseFile {excisefile sampdur} {
	global cj_timepairs 
	if [catch {open $excisefile "w"} zit] {
		Inf "Cannot Open Temporary Excise-File '$excisefile'"
		return 0
	}
	set cnt 0
	foreach {time1 time2} $cj_timepairs {
		if {$time1 >= $sampdur} {
			break
		} elseif {$time2 >= $sampdur} {
			set time2 $sampdur
		}
		set nuline [list $time1 $time2]
		puts $zit $nuline
		incr cnt
	}
	close $zit
	if {$cnt == 0} {
		Inf "No Valid Excise Lines"
		catch {file delete $zit} zub
		return 0
	}
	return 1
}

#------ Dovetail one or both ends of sound

proc EnvelEnds {fnam} {
	global pr_e_e  ee_start ee_end previous_clean ee_curve1 ee_curve2
	global pa evv ckit_filindex cklist snack_enabled

	set srate $pa($fnam,$evv(SRATE))
	set sampdur [expr $pa($fnam,$evv(INSAMS)) / $pa($fnam,$evv(CHANS))]
	set realdur [expr $sampdur / double($srate)]

	set outfile $evv(DFLT_OUTNAME)
	append outfile 0
	append outfile $evv(SNDFILE_EXT)

	set f .ee
	
	if [Dlg_Create $f "DOVETAIL SOUND END(S)" "set pr_e_e 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0 -bd 0]
		set f1 [frame $f.1 -bd 0]
		set f2 [frame $f.2 -bd 0]
		set f3 [frame $f.3 -bd 0]
		set f4 [frame $f.4 -bd 0]
		button $f0.keep -text "" -command {} -bd 0
		pack $f0.keep -side left -padx 2
		button $f0.quit -text "Abandon" -command "set pr_e_e 0"
		pack $f0.quit -side right -padx 2
		pack $f0 -side top -fill x -expand true
		button $f1.clean    -text "Dovetail Snd" -width 12 -command "set pr_e_e 1" -bg $evv(EMPH)	
		button $f1.playsrc -text "Play Source" -width 11 -command "PlaySndfile $fnam 0"		
		if {$snack_enabled} {
			button $f1.playout -text "View Output" -width 11 -command "PlayCleanedOutput"
		} else {
			button $f1.playout -text "Play Output" -width 11 -command "PlayCleanedOutput"
		}
		bind $f <Key-space> "PlayCleanedOutput"
		button $f1.reset -text "Reset" -command ReinitEe
		button $f1.recov -text "Recover" -command DeleteAllTemporaryFiles
		pack $f1.clean $f1.playsrc $f1.playout $f1.reset $f1.recov -side left -padx 2
		pack $f1 -side top -fill x -expand true

		label $f2.l1 -text "Start Dovetail length in secs"
		entry $f2.e1 -textvariable ee_start -width 6

		label $f3.l2 -text "End Dovetail    length in secs"
		entry $f3.e2 -textvariable ee_end -width 6

		set ee_curve1 -1
		set ee_curve2 -1
		radiobutton	$f2.ll -variable ee_curve1 -text "Linear" -value 1 -command "DisDoublExp ee_curve2"
		radiobutton	$f2.ee -variable ee_curve1 -text "Exponential" -value 2 -command "DisDoublExp ee_curve2"
		radiobutton	$f2.dd -variable ee_curve1 -text "Doubly Exponential" -value 3 -command "set ee_curve2 3"
		radiobutton	$f2.nn -variable ee_curve1 -text "None" -value 0 -command "set ee_curve1 -1; set ee_start \"\""
		radiobutton	$f3.ll -variable ee_curve2 -text "Linear" -value 1 -command "DisDoublExp ee_curve1"
		radiobutton	$f3.ee -variable ee_curve2 -text "Exponential" -value 2 -command "DisDoublExp ee_curve1"
		radiobutton	$f3.dd -variable ee_curve2 -text "Doubly Exponential" -value 3 -command "set ee_curve1 3"
		radiobutton	$f3.nn -variable ee_curve2 -text "None" -value 0 -command "set ee_curve2 -1; set ee_end \"\""
		pack $f2.l1 $f2.e1 $f2.ll $f2.ee $f2.dd $f2.nn -side left -padx 2
		pack $f3.l2 $f3.e2 $f3.ll $f3.ee $f3.dd $f3.nn -side left -padx 2
		pack $f2 $f3 -side top
		Scrolled_Listbox $f4.l -width 110 -height 6 -selectmode single
		pack $f4.l -side top -fill both -expand true
		pack $f4 -side top -pady 2
		wm resizable $f 1 1
		bind $f <Return> {set pr_e_e 1}
		bind $f <Escape> {set pr_e_e 0}
	}
	wm title $f "DOVETAIL FILE [file tail $fnam]"
	set pr_e_e 0
	raise $f
	update idletasks
	StandardPosition2 .ee
	set finished 0
	My_Grab 0 $f pr_e_e $f
	while {!$finished} {
		.ee.4.l.list delete 0 end
		tkwait variable pr_e_e
		switch -- $pr_e_e {
			1 {
				set ee_qend ""
				set ee_qstart ""
				set ee_start [string trim $ee_start]
				set ee_end [string trim $ee_end]
				if {([string length $ee_start] <= 0) && ([string length $ee_end] <= 0)} {
					Inf "No Dovetail Duration(s) Specified"
					continue
				}
				if {[string length $ee_start] > 0} {
					if {![IsPositiveNumber $ee_start]} {
						Inf "Invalid Start Dovetail"
						continue
					} elseif {$ee_curve1 == 0} {
						Inf "No Start Dovetail Style (Linear/Exp) Specified"
						continue
					}
					set ee_qstart $ee_start
				} elseif {($ee_curve1 > 0) && ($ee_curve1 !=3)} {
					Inf "No Start Dovetail Duration Specified"
					continue
				}
				if {[string length $ee_end] > 0} {
					if {![IsPositiveNumber $ee_end]} {
						Inf "Invalid End Dovetail"
						continue
					} elseif {$ee_curve2 == 0} {
						Inf "No End Dovetail Style (Linear/Exp) Specified"
						continue
					}
					set ee_qend $ee_end
				} elseif {($ee_curve2 > 0) && ($ee_curve2 !=3)} {
					Inf "No End Dovetail Duration Specified"
					continue
				}
				if {($ee_curve1 > 0) && ($ee_curve2 > 0)} {
					if {$ee_curve1 == 3} {
						if {([string length $ee_start] > 0) && ([string length $ee_end] > 0)} {
							if {[expr $ee_qstart + $ee_qend] >= $realdur} {
								Inf "Dovetails Are Too Long For The File (Duration $realdur Secs)"
								continue
							}
						} elseif {[string length $ee_start] > 0} {
							if {$ee_qstart >= $realdur} {
								Inf "Dovetail Is Too Long For The File (Duration $realdur Secs)"
								continue
							}
						} elseif {$ee_qend >= $realdur} {
							Inf "Dovetail Is Too Long For The File (Duration $realdur Secs)"
							continue
						}
					} elseif {[expr $ee_qstart + $ee_qend] >= $realdur} {
						Inf "Dovetails Are Too Long For The File (Duration $realdur Secs)"
						continue
					}
				} elseif {$ee_curve1 > 0} {
					if {$ee_qstart >= $realdur} {
						Inf "Dovetail ($ee_start) Is Too Long For The File (Duration $realdur Secs)"
						continue
					}
				} elseif {$ee_curve2 > 0} {
					if {$ee_qend >= $realdur} {
						Inf "Dovetail ($ee_end) Is Too Long For The File (Duration $realdur Secs)"
						continue
					}
				}
				if {![RunEe $fnam $ee_qstart $ee_qend $ee_curve1 $ee_curve2]} {
					continue
				}
				.ee.0.keep config -text "Keep Output" -command "set pr_e_e 2" -bg $evv(EMPH) -bd 2
				.ee.1.clean config -text "" -command {} -bg [option get . background {}] -bd 0
				if {$snack_enabled} {
					.ee.1.playout config -bg $evv(SNCOLOR)	
				} else {
					.ee.1.playout config -bg $evv(EMPH)	
				}
			}
			2 {
				if {![file exists $outfile]} {
					Inf "Cannot Find The Output File"
					.cj.0.keep config -text "" -command {} -bg [option get . background {}] -bd 0
					.cj.1.clean config -text "Dovetail Snd" -command "set pr_e_e 1" -bg $evv(EMPH) -bd 2
					continue
				}
				set nufnam $evv(CLEANKIT_NAME)
				append nufnam $ckit_filindex
				append nufnam $evv(SNDFILE_EXT)
				if {[file exists $nufnam]} {
					Inf "'$nufnam' ALREADY EXISTS"
					continue
				}
				if [catch {file rename $outfile $nufnam} zit] {
					Inf "Cannot Rename Output File To '$nufnam'"
					continue
				}
				if {[DoParse $nufnam 0 0 0] <= 0} {
					if {![file delete $nufnam]} {
						Inf "Failed To Delete Bad File '$nufnam'"
					}
					continue
				}
				$cklist insert end $nufnam
				incr ckit_filindex
				.ee.0.keep config -text "" -command {} -bg [option get . background {}] -bd 0
				.ee.1.clean config -text "Dovetail Snd" -command "set pr_e_e 1" -bg $evv(EMPH) -bd 2
				.ee.1.playout config -bg [option get . background {}]
				break
			}
			0 {
				break
			}
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	destroy .ee
}

proc ReinitEe {} {
	global pr_e_e evv

	if [string match [.ee.0.keep cget -text] "Keep Output"] {
		DeleteAllTemporaryFiles
		.ee.0.keep config -text "" -command {} -bg [option get . background {}] -bd 0
		.ee.1.clean config -text "Dovetail Snd" -command "set pr_e_e 1" -bg $evv(EMPH) -bd 2
		.ee.1.playout config -bg [option get . background {}]
		return
	}
	.ee.4.l.list delete 0 end
}

proc RunEe {fnam start end curve1 curve2} {
	global evv
	global CDPidrun prg_dun prg_abortd

	if {[string length $start] <= 0} {
		set start 0.0
		if {$curve1 != 3} {
			set curve1 1
		}
	} elseif {$curve1 == 0} {
		set curve1 1
	}
	if {[string length $end] <= 0} {
		set end 0.0
		if {$curve2 != 3} {
			set curve2 1
		}
	} elseif {$curve2== 0} {
		set curve1 1
	}

	incr curve1 -1	
	incr curve2 -1

	set outfile $evv(DFLT_OUTNAME)
	append outfile 0 $evv(SNDFILE_EXT)

	set cmd [file join $evv(CDPROGRAM_DIR) envel]
	lappend cmd dovetail
	if {$curve1 == 2} {
		lappend cmd 2
	} else {
		lappend cmd 1
	}
	lappend cmd $fnam $outfile $start $end
	if {$curve1 != 2} {
		lappend cmd $curve1 $curve2
	}
	lappend cmd -t0

	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	set returnval 1
	.ee.4.l.list  delete 0 end
	Block "Editing Sound"
	if [catch {open "|$cmd"} CDPidrun] {
		set line "$CDPidrun : Can't Run Dovetailing Process"
		.ee.4.l.list insert end $line
		UnBlock
		return 0
		break
	} else {
	   	fileevent $CDPidrun readable "Display_RpeBatch_Info .ee.4.l.list"
	}
	vwait prg_dun
	if {$prg_abortd} {
		set prg_dun 0
	}
	if {!$prg_dun} {
		set line "Dovetailing Process Failed"
		.ee.4.l.list insert end $line
		UnBlock
		return 0
	}
	.ee.4.l.list delete 0 end
	.ee.4.l.list insert end "Dovetailing Completed"
	UnBlock
	.ee.4.l.list yview moveto 1.0
	return 1
}

proc DisDoublExp {curve} { 
	global ee_curve1 ee_curve2
	upvar $curve thiscurve
	if {$thiscurve == 3} {
		set thiscurve 0
	}
}

#----- Graft part of sound into another place in sound.

proc Graft {fnam} {
	global pr_grft grftstt grftgain grftsplice pa evv shortwindows
	global grftgain_last grftsplice_last grftstt_last
	global grft_timepairs grft_newbal grftlevel grftover
	global grft_timepairsbak grft_t grftsmpcnt grft_res grft_clr
	global grftgainbak grftsplicebak grftsttbak ckit_filindex cklist previous_clean grft_forpos snack_enabled
	set f .grft
	
	catch {unset grftsplice_last}
	catch {unset grftstt_last}

	if {$pa($fnam,$evv(CHANS)) > 1} {
		Inf "Mono Files Only"
		return
	} 
	set srate [expr double ($pa($fnam,$evv(SRATE)))]
	set sampdur $pa($fnam,$evv(INSAMS))
	set dur		$pa($fnam,$evv(DUR))
	set frametime [expr 1026.0 / (8.0 * $srate)]

	set minsplice [expr int(round(1 * $evv(MS_TO_SECS) * $srate))]

	set balancefile $evv(DFLT_OUTNAME)
	append balancefile 0
	append balancefile $evv(TEXT_EXT)

	set outfile $evv(DFLT_OUTNAME)
	append outfile 0
	append outfile $evv(SNDFILE_EXT)

	if [Dlg_Create $f "GRAFT PART OF SRC ELSEWHERE" "set pr_grft 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0 -bd 0]
		set f1 [frame $f.1 -bd 0]
		set f2 [frame $f.2 -bd 0]
		set f3 [frame $f.3 -bd 0]
		set fy [frame $f.y -bd 0]
		set fz [frame $f.z -bd 0]
		set f4 [frame $f.4 -bd 0]

		if {[info exists shortwindows]} {
			set this_height 8
		} else {
			set this_height 16
		}
		set grft_t [text $fz.t -setgrid true -wrap word -width 76 -height $this_height \
		-xscrollcommand "$fz.sx set" -yscrollcommand "$fz.sy set"]
		scrollbar $fz.sy -orient vert  -command ".grft.7.t yview"
		scrollbar $fz.sx -orient horiz -command ".grft.7.t xview"
		pack $fz.t -side left -fill both -expand true
		pack $fz.sy -side right -fill y

		button $f0.keep -text "" -width 11 -command {} -bd 0
		pack $f0.keep -side left -padx 2
		if {$snack_enabled} {
			button $f0.see -text "Sound View"  -command "SnackDisplay $evv(SN_TIMEPAIRS) $grft_t $evv(GRPS_OUT) $fnam" -bg $evv(SNCOLOR)
			pack $f0.see -side left -padx 2
		}
		button $f0.quit -text "Abandon" -command "set pr_grft 0"
		pack $f0.quit -side right -padx 2
		if {$snack_enabled} {
			frame $f0.1
			checkbutton $f0.1.where -text "Vals For Insert point" -variable grft_forpos -command "GraftRoute $fnam"
			pack $f0.1.where -side left
			pack $f0.1 -side right -padx 40
		}
		pack $f0 -side top -fill x -expand true
		button $f1.clean -text "Graft Sound" -width 11 -command "set pr_grft 1" -bg $evv(EMPH)
		button $f1.playsrc -text "Play Source" -width 11 -command "PlaySndfile $fnam 0"		
		if {$snack_enabled} {
			button $f1.playout -text "View Output" -width 11 -command "PlayCleanedOutput"
		} else {
			button $f1.playout -text "Play Output" -width 11 -command "PlayCleanedOutput"
		}
		bind $f <Key-space> "PlayCleanedOutput"
		button $f1.reset -text "Reset" -command ReinitGraft
		button $f1.recov -text "Recover" -command DeleteAllTemporaryFiles
		pack $f1.clean $f1.playsrc $f1.playout $f1.reset $f1.recov -side left -padx 2
		pack $f1 -side top -fill x -expand true

		label $f2.ls -text "Start Position to insert graft: (samples)"
		entry $f2.es -textvariable grftstt -width 12
		label $f2.lc -text "Splice Duration (1 - 50 ms)"
		entry $f2.ec -textvariable grftsplice -width 12
		pack $f2.ls $f2.es $f2.lc $f2.ec -side left -padx 2
		pack $f2 -side top -pady 1

		label $f3.lg -text "Insert Level (0 - 1)"
		entry $f3.eg -textvariable grftgain -width 12
		checkbutton $f3.ov -text "Overwrite Existing Signal" -variable grftover
		pack $f3.lg $f3.eg $f3.ov -side left -padx 2
		pack $f3 -side top -pady 1

		frame $f.3a -bg [option get . foreground {}] -height 1
		pack $f.3a -side top -fill x -expand true -pady 1
		label $fy.ll -text "Segment To Use As Graft"
		frame $fy.kkk
		radiobutton	$fy.kkk.sc -variable grftsmpcnt -text "End Of File Sample" -command "SetSmpcnt grft_t $sampdur; set grftsmpcnt 0" -value 1
		radiobutton	$fy.kkk.res -variable grft_res -text "Restore Last Run Vals" -command "LastClean grft_t; set grft_res 0" -value 1
		radiobutton	$fy.kkk.clr -variable grft_clr -text "Clear Values" -command "ClearClean $grft_t; set grft_clr 0" -value 1

		pack $fy.ll -side top
		pack $fy.kkk.sc $fy.kkk.res $fy.kkk.clr -side left -padx 4
		pack $fy.kkk -side top
		pack $fy -side top -fill x -pady 2

		pack $fz -side top -fill both -expand true

		Scrolled_Listbox $f4.l -width 110 -height 6 -selectmode single
		pack $f4.l -side top -fill both -expand true
		pack $f4 -side top -pady 2
		wm resizable $f 1 1

		bind .grft.2.es <Right> {focus .grft.2.ec}
		bind .grft.2.ec <Right> {focus .grft.3.eg}
		bind .grft.3.eg <Right> {focus .grft.2.es}
		bind .grft.2.es <Left> {focus .grft.3.eg}
		bind .grft.2.ec <Left> {focus .grft.2.es}
		bind .grft.3.eg <Left> {focus .grft.3.ec}
		bind .grft.2.es <Down> {focus .grft.2.ec}
		bind .grft.2.ec <Down> {focus .grft.3.eg}
		bind .grft.3.eg <Down> {focus .grft.2.es}
		bind .grft.2.es <Up> {focus .grft.3.eg}
		bind .grft.2.ec <Up> {focus .grft.2.es}
		bind .grft.3.eg <Up> {focus .grft.3.ec}
		bind $f <Escape> {set pr_grft 0}
		bind $f <Return> {set pr_grft 1}
	}
	if {$snack_enabled} {
		set grft_forpos 0
		.grft.0.see config -command "SnackDisplay $evv(SN_TIMEPAIRS) $grft_t $evv(GRPS_OUT) $fnam"
	}
	set grftover 1
	wm title $f "USE GRAFT IN FILE [file tail $fnam]"
	set grftgain 1.0
	set grftsplice 5.0
	set grftgain_last $grftgain
	$f.4.l.list delete 0 end
	set pr_grft 0
	raise $f
	update idletasks
	StandardPosition2 .grft
	set finished 0
	My_Grab 0 $f pr_grft $f
	while {!$finished} {
		tkwait variable pr_grft
		switch -- $pr_grft {
			1 {
				set grftsplice [string trim $grftsplice]
				if {[string length $grftsplice] <= 0} {
					Inf "No Graft Splice Duration Entered"
					continue
				}
				if {![IsNumeric $grftsplice] || ($grftsplice < 1.0) || ($grftsplice >= 50.0)} {
					Inf "Invalid Graft Splice Duration Entered"
					continue
				}
				set smpsplice [expr int(round($grftsplice * $evv(MS_TO_SECS) * $srate))]
				set mingap [expr $smpsplice * 2.0]
				set grftstt [string trim $grftstt]
				if {[string length $grftstt] <= 0} {
					Inf "No Graft Insert Time Entered"
					continue
				}
				if {![regexp {[0-9]+} $grftstt] || ($grftstt < 0) || ($grftstt >= $sampdur)} {
					Inf "Invalid Graft Insert Time Entered"
					continue
				}
				set grftgain [string trim $grftgain]
				if {[string length $grftgain] <= 0} {
					Inf "No Graft Gain Value Entered"
					continue
				}
				if {![IsPositiveNumber $grftgain]} {
					Inf "Invalid Graft Gain Value Entered"
					continue
				}
				if {($grftgain < 0.0) || ($grftgain > 1.0)} {
					Inf "Invalid Graft Gain Value Entered"
					continue
				}
				$f.4.l.list delete 0 end

					;#	CHECK TIME PAIRS

				catch {unset nutimepairs}
				set OK 1
				set len 0
				foreach word [$grft_t get 1.0 end] {
					set word [string trim $word]
					if {[string length $word] > 0} {
						lappend nutimepairs $word
						incr len
					}
				}
				if {$len == 0} {
					Inf "No Graft Times Entered"
					continue
				}
				if {$len != 2} {
					Inf "Two Times (Only) Needed To Specify Graft Segment"
					continue
				}
				set grft_retime 1
				if {[info exists grft_timepairs] && ([llength $grft_timepairs] == $len)} {
					set grft_retime 0
					foreach time0 $grft_timepairs time1 $nutimepairs {
						if {$time0 != $time1} {
							set grft_retime 1
							break
						}
					}
				}
				if {$grft_retime} {
					set cnt 0
					foreach item $nutimepairs {
						if {![regexp {^[0-9]+$} $item]} {
							Inf "Invalid Sampletime '$item'"
							set OK 0 
							break
						}
						if {$cnt > 0} {
							set step [expr $item - $lastitem]
							if {$step <= $mingap} {
								Inf "Gap Between Samplepair Too Small For Splice"
								set OK 0 
								break
							}
						}
						set lastitem $item
						incr cnt
					}
					if {!$OK} {
						continue
					}
					set grft_timepairs $nutimepairs
					set grft_timepairsbak $grft_timepairs
				}
				set time0 [lindex $grft_timepairs 0]
				set time1 [lindex $grft_timepairs 1]
				if {($time0 <= $smpsplice) && ($time1 >= [expr $sampdur - $smpsplice])} {
					Inf "Graft Is Too Large"
					continue
				}
				if {![RunGraft $fnam $grftstt $grftsplice $grftgain $time0 $time1 $grftover]} {
					set grftstt_last	  $grftstt
					set grftsplice_last  $grftsplice
					set grftgain_last	  $grftgain
					continue
				}
				set grftstt_last	  $grftstt
				set grftsplice_last  $grftsplice
				set grftgain_last	  $grftgain
				if {[info exists grft_timepairs]} {
					set grft_timepairsbak $grft_timepairs
				}
				.grft.0.keep config -text "Keep Output" -command "set pr_grft 2" -bg $evv(EMPH) -bd 2
				.grft.1.clean config -text "" -command {} -bg [option get . background {}] -bd 0
				if {$snack_enabled} {
					.grft.1.playout config -bg $evv(SNCOLOR)	
				} else {
					.grft.1.playout config -bg $evv(EMPH)	
				}
			}
			2 {
				if {![file exists $outfile]} {
					Inf "Cannot Find The Output File"
					.grft.0.keep config -text "" -command {} -bg [option get . background {}] -bd 0
					.grft.1.clean config -text "Clean Sound" -command "set pr_grft 1" -bg $evv(EMPH) -bd 2
					continue
				}
				set nufnam $evv(CLEANKIT_NAME)
				append nufnam $ckit_filindex
				append nufnam $evv(SNDFILE_EXT)
				if {[file exists $nufnam]} {
					Inf "'$nufnam' Already Exists"
					continue
				}
				if [catch {file rename $outfile $nufnam} zit] {
					Inf "Cannot Rename Output File To '$nufnam'"
					continue
				}
				if {[DoParse $nufnam 0 0 0] <= 0} {
					if {![file delete $nufnam]} {
						Inf "Failed To Delete Bad File '$nufnam'"
					}
					continue
				}
				$cklist insert end $nufnam
				incr ckit_filindex
				.grft.0.keep config -text "" -command {} -bg [option get . background {}] -bd 0
				.grft.1.clean config -text "Clean Sound" -command "set pr_grft 1" -bg $evv(EMPH) -bd 2
				.grft.1.playout config -bg [option get . background {}]
				break
			}
			0 {
				break
			}
		}
	}
	DeleteAllTemporaryFiles
	if {[info exists grftgain]} { 
		set grftgainbak $grftgain
	}
	if {[info exists grftsplice]} {
		set grftsplicebak $grftsplice
	}
	if {[info exists grftstt]} {
		set grftsttbak $grftstt
	} 
	set previous_clean [$grft_t get 1.0 end]
	My_Release_to_Dialog $f
	destroy .grft
}

proc ReinitGraft {} {
	global grft_timepairs grft_timepairsbak evv
	global grftsplice grftstt pr_grft
	global grftsplice_last grftstt_last
	global grftgainbak grftsttbak

	if [string match [.grft.0.keep cget -text] "Keep Output"] {
		DeleteAllTemporaryFiles
		.grft.0.keep config -text "" -command {} -bg [option get . background {}] -bd 0
		.grft.1.clean config -text "Graft Sound" -command "set pr_grft 1" -bg $evv(EMPH) -bd 2
		.grft.1.playout config -bg [option get . background {}]
		return
		.grft.4.1.list delete 0 end
	}
	if {[info exists grft_timepairsbak]} {
		.grft.z.t delete 1.0 end
		set grft_timepairs $grft_timepairsbak
		foreach {time0 time1} $grft_timepairs {
			.grft.z.t insert end "$time0\t$time1\n"
		}
	}
	if {[info exists grftstt_last]} {
		set grftstt $grftstt_last
		if {[info exists grftgain_last]} { 
			set grftgain $grftgain_last
		}
		if {[info exists grftsplice_last]} {
			set grftsplice $grftsplice_last
		}
	} elseif {[info exists grftgainbak]} { 
		set grftgain $grftgainbak
		if {[info exists grftsplicebak]} {
			set grftsplice $grftsplicebak
		}
		if {[info exists grftsttbak]} {
			set grftstt $grftsttbak
		} 
	}
}

proc RunGraft {fnam start splice gain time0 time1 over} {
	global CDPidrun prg_dun prg_abortd grftstt_last grftsplice_last grftgain_last grft_time0_last grft_time1_last evv

	set grftfile $evv(DFLT_OUTNAME)
	append grftfile 1
	append grftfile $evv(SNDFILE_EXT)

	set outfile $evv(DFLT_OUTNAME)
	append outfile 0
	append outfile $evv(SNDFILE_EXT)

	set do_it 1 

	;#	ONLY CUT GRAFT FILE, IF IT DOESN'T ALREADY EXIST OR PARAMETERS HAVE CHANGED

	if {[info exists grft_time0_last] && [info exists grftsplice_last]} {
		if {($grft_time0_last == $time0) || ($grft_time1_last == $time1) || ($grftsplice_last == $splice)} {
			if {[file exists $grftfile]} {
				set do_it 0
			}
		}
	}

	if {$do_it} {
		set cmd [file join $evv(CDPROGRAM_DIR) sfedit]
		lappend cmd cut 3 $fnam $grftfile $time0 $time1 -w$splice
		lappend cmds $cmd
	}
	set cmd [file join $evv(CDPROGRAM_DIR) sfedit]
	lappend cmd insert 3 $fnam $grftfile $outfile $start -w$splice -l$gain
	if {$over} {
		lappend cmd "-o"
	}
	lappend cmds $cmd

	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	set returnval 1
	.grft.4.l.list delete 0 end
	if {![info exists cmds]} {
		return 0
	}
	Block "Grafting Sound"
	foreach cmd $cmds {
		if [catch {open "|$cmd"} CDPidrun] {
			set line "$CDPidrun : Can't Run Process '[lrange $cmd 0 1]'."
			.grft.4.l.list insert end $line
			set returnval 0
			break
	   	} else {
	   		fileevent $CDPidrun readable "Display_RpeBatch_Info .grft.4.l.list"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			set line "Process '[lrange $cmd 0 1]' Failed"
			.grft.4.l.list insert end $line
			set returnval 0
			break
		}
	}
	if {$returnval} {
		.grft.4.l.list delete 0 end
		.grft.4.l.list insert end "Grafting Completed"
	} 
	UnBlock
	.grft.4.l.list yview moveto 1.0
	set grft_time0_last $time0
	set grft_time1_last $time1
	set grftsplice_last $splice
	return $returnval
}

proc GraftRoute {fnam} {
	global grft_forpos grft_t evv
	switch -- $grft_forpos {
		1 {
			.grft.0.see config -command "SnackDisplay $evv(SN_SINGLETIME) grftins $evv(GRPS_OUT) $fnam"
		}
		0 {
			.grft.0.see config -command "SnackDisplay $evv(SN_TIMEPAIRS) $grft_t $evv(GRPS_OUT) $fnam"
		}
	}
}

#---- Reduce level in part of sound.

proc CleanAtten {fnam} {
	global pr_clatn clatn_timepairs clatn_timepairsbak clatn_t clatnsplice clatnsmpcnt previous_clean clatn_res clatn_clr
	global pa evv ckit_filindex cklist clatnall clatn_atn snack_enabled shortwindows

	set evv(DISSPLICE) 15
	set srate $pa($fnam,$evv(SRATE))
	set sampdur [expr $pa($fnam,$evv(INSAMS)) / $pa($fnam,$evv(CHANS))]
	set minsplice [expr int(round($evv(DISSPLICE) * $evv(MS_TO_SECS) * $srate))]
	set mingap [expr $minsplice * 2]
	set dur  $pa($fnam,$evv(DUR))
	set envelfile $evv(DFLT_OUTNAME)
	append envelfile 0
	append envelfile $evv(TEXT_EXT)
	
	set outfile $evv(DFLT_OUTNAME)
	append outfile 0
	append outfile $evv(SNDFILE_EXT)
	set f .clatn
	
	if [Dlg_Create $f "ATTENUATE PART OF SOUND" "set pr_clatn 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0 -bd 0]
		set f1 [frame $f.1 -bd 0]
		set f1a [frame $f.1a -bd 0]
		set f2 [frame $f.2 -bd 0]
		set f3 [frame $f.3 -bd 0]
		set f4 [frame $f.4 -bd 0]

		if {[info exists shortwindows]} {
			set this_height 8
		} else {
			set this_height 16
		}
		set clatn_t [text $f3.t -setgrid true -wrap word -width 76 -height $this_height \
		-xscrollcommand "$f3.sx set" -yscrollcommand "$f3.sy set"]
		scrollbar $f3.sy -orient vert  -command ".clatn.3.t yview"
		scrollbar $f3.sx -orient horiz -command ".clatn.3.t xview"
		pack $f3.t -side left -fill both -expand true
		pack $f3.sy -side right -fill y

		button $f0.keep -text "" -command {} -bd 0
		pack $f0.keep -side left -padx 2
		button $f0.quit -text "Abandon" -command "set pr_clatn 0"
		if {$snack_enabled} {
			button $f0.see -text "Sound View" -command "SnackDisplay $evv(SN_TIMEPAIRS) $clatn_t $evv(GRPS_OUT) $fnam" -bg $evv(SNCOLOR)
			pack $f0.see -side left -padx 40
		}
		pack $f0.quit -side right -padx 2
		pack $f0 -side top -fill x -expand true
		button $f1.clean    -text "Clean Sound" -width 11 -command "set pr_clatn 1" -bg $evv(EMPH)
		button $f1.playsrc -text "Play Source" -width 11 -command "PlaySndfile $fnam 0"		
		if {$snack_enabled} {
			button $f1.playout -text "View Output" -width 11 -command "PlayCleanedOutput"
		} else {
			button $f1.playout -text "Play Output" -width 11 -command "PlayCleanedOutput"
		}
		bind $f <Key-space> "PlayCleanedOutput"
		button $f1.reset -text "Reset" -command ReinitClatn
		button $f1.recov -text "Recover" -command DeleteAllTemporaryFiles
		pack $f1.clean $f1.playsrc $f1.playout $f1.reset $f1.recov -side left -padx 2
		pack $f1 -side top -fill x -expand true

		label $f1a.ll -text "Slopelen (mS)"
		entry $f1a.e -textvariable clatnsplice -width 6
		pack $f1a.ll $f1a.e -side left -padx 2
		label $f1a.ll2 -text "Attenuation"
		entry $f1a.e2 -textvariable clatn_atn -width 6
		pack $f1a.e2 $f1a.ll2 -side right -padx 2
		pack $f1a -side top -fill x -pady 2 
		frame $f.1b -bg [option get . foreground {}] -height 1
		pack $f.1b -side top -fill x -expand true -pady 1

		checkbutton $f2.all -text "Clean All" -variable clatnall -command "SetSmpcnt clatn_all $sampdur; set clatnall 0"
		pack $f2.all -side top
		label $f2.ll -text "Start And End Samples Of Regions To Be Gated"
		frame $f2.kkk
		radiobutton	$f2.kkk.sc -variable clatnsmpcnt -text "End Of File Sample" -command "SetSmpcnt clatn_t $sampdur; set clatnsmpcnt 0" -value 1
		radiobutton	$f2.kkk.res -variable clatn_res -text "Restore Last Run Vals" -command "LastClean clatn_t; set clatn_res 0" -value 1
		radiobutton	$f2.kkk.clr -variable clatn_clr -text "Clear Values" -command "ClearClean $clatn_t; set clatn_clr 0" -value 1

		pack $f2.ll -side top
		pack $f2.kkk.sc $f2.kkk.res $f2.kkk.clr -side left -pady 4
		pack $f2.kkk -side top
		pack $f2 -side top -fill x -pady 2

		pack $f3 -side top -fill both -expand true

		Scrolled_Listbox $f4.l -width 110 -height 6 -selectmode single
		pack $f4.l -side top -fill both -expand true
		pack $f4 -side top -pady 2
		wm resizable $f 1 1
		bind $f <Escape> {set pr_clatn 0}
		bind $f <Return> {set pr_clatn 1}
	}
	set clatnall 0
	wm title $f "ATTENUATE PART OF FILE [file tail $fnam]"
	set clatnsplice $evv(DISSPLICE)
	$f.4.l.list delete 0 end
	$f.3.t delete 1.0 end
	set pr_clatn 0
	set clatn_timepairs {}
	raise $f
	update idletasks
	StandardPosition2 .clatn
	set finished 0
	My_Grab 0 $f pr_clatn $f
	while {!$finished} {
		tkwait variable pr_clatn
		$f.4.l.list delete 0 end
		switch -- $pr_clatn {
			1 {
				set clatn_atn [string trim $clatn_atn]
				if {![IsPositiveNumber $clatn_atn] || ($clatn_atn >= 1.0) || ($clatn_atn <= 0.0)} {
					Inf "Invalid Attenuation Value"
					continue
				}
				set clatnsplice [string trim $clatnsplice]
				if {[string length $clatnsplice] > 0} {
					if {![IsPositiveNumber $clatnsplice]} {
						Inf "Invalid Splice Length"
						continue
					}
				} else {
					set clatnsplice $evv(DISSPLICE)
				}
				set splicesecs [expr $clatnsplice * $evv(MS_TO_SECS)]
				set minsplice [expr int(round($splicesecs * $srate))]
				set mingap [expr $minsplice * 2]

				set clatn_timepairs [CleanSortTimes $clatn_t $mingap 1]
				if {[llength $clatn_timepairs] <= 0} {
					continue
				}
				if {![CreateClatnFile $envelfile $splicesecs $dur $srate .clatn.4.l.list]} {
					continue
				}
				$f.4.l.list delete 0 end
				set clatn_timepairsbak $clatn_timepairs
				if {![RunClatn $fnam $outfile $envelfile .clatn.4.l.list]} {
					continue
				}
				.clatn.0.keep config -text "Keep Output" -command "set pr_clatn 2" -bg $evv(EMPH) -bd 2
				.clatn.1.clean config -text "" -command {} -bg [option get . background {}] -bd 0
				if {$snack_enabled} {
					.clatn.1.playout config -bg $evv(SNCOLOR)	
				} else {
					.clatn.1.playout config -bg $evv(EMPH)	
				}
			}
			2 {
				if {![file exists $outfile]} {
					Inf "Cannot Find The Output File"
					.clatn.0.keep config -text "" -command {} -bg [option get . background {}] -bd 0
					.clatn.1.clean config -text "Clean Sound" -command "set pr_clatn 1" -bg $evv(EMPH) -bd 2
					continue
				}
				set nufnam $evv(CLEANKIT_NAME)
				append nufnam $ckit_filindex
				append nufnam $evv(SNDFILE_EXT)
				if {[file exists $nufnam]} {
					Inf "'$nufnam' Already Exists"
					continue
				}
				if [catch {file rename $outfile $nufnam} zit] {
					Inf "Cannot Rename Output File To '$nufnam'"
					continue
				}
				if {[DoParse $nufnam 0 0 0] <= 0} {
					if {![file delete $nufnam]} {
						Inf "Failed To Delete Bad File '$nufnam'"
					}
					continue
				}
				$cklist insert end $nufnam
				incr ckit_filindex
				.clatn.0.keep config -text "" -command {} -bg [option get . background {}] -bd 0
				.clatn.1.clean config -text "Clean Sound" -command "set pr_clatn 1" -bg $evv(EMPH) -bd 2
				.clatn.1.playout config -bg [option get . background {}]
				break
			}
			0 {
				break
			}
		}
	}
	set previous_clean [$clatn_t get 1.0 end]
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	destroy .clatn
}

proc ReinitClatn {} {
	global clatn_timepairs clatn_timepairsbak pr_clatn evv

	if [string match [.clatn.0.keep cget -text] "Keep Output"] {
		DeleteAllTemporaryFiles
		.clatn.0.keep config -text "" -command {} -bg [option get . background {}] -bd 0
		.clatn.1.clean config -text "Clean Source" -command "set pr_clatn 1" -bg $evv(EMPH) -bd 2
		.clatn.1.playout config -bg [option get . background {}]
		return
	}
	if {[info exists clatn_timepairsbak]} {
		.clatn.3.t delete 1.0 end
		set clatn_timepairs $clatn_timepairsbak
		foreach {time0 time1} $clatn_timepairs {
			.clatn.3.t insert end "$time0\t$time1\n"
		}
	}
}

proc RunClatn {fnam outfile envelfile f} {
	global evv
	global CDPidrun prg_dun prg_abortd

	set cmd [file join $evv(CDPROGRAM_DIR) modify]
	lappend cmd loudness 1 $fnam $outfile $envelfile

	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	set returnval 1
	$f delete 0 end
	Block "Cleaning Sound"
	set finished 0
	while {!$finished} {
		if [catch {open "|$cmd"} CDPidrun] {
			set line "$CDPidrun : Can't Run Process."
			$f insert end $line
			set returnval 0
			set finished 1
			break
		} else {
	   		fileevent $CDPidrun readable "Display_RpeBatch_Info $f"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			set line "Process Failed"
			$f insert end $line
			set returnval 0
			set finished 1
			break
		}
		if {$returnval} {
			$f delete 0 end
			$f insert end "Cleaning Completed"
		} 
		set finished 1
	}
	UnBlock
	$f yview moveto 1.0
	return $returnval
}

proc CreateClatnFile {envelfile splicelen dur srate f} {
	global clatn_timepairs clatn_atn
	set cnt 0
	foreach {time0 time1} $clatn_timepairs {
		set time0 [expr double($time0) / double($srate)]
		set time1 [expr double($time1) / double($srate)]
		lappend nutimes $time0 $time1
		if {$time0 >= $dur} {
			break
		}
		incr cnt 2
	}
	if {$cnt == 0} {
		$f insert end "No Relevant Attenuation Areas In File"
		return 0
	}
	incr cnt -1
	set nutimes [lrange $nutimes 0 $cnt]
	if [catch {open $envelfile "w"} zit] {
		Inf "Cannot Open Temporary Envelope-File '$envelfile'"
		return 0
	}
	set cnt 0
	foreach {time0 time1} $nutimes {
		if {$cnt == 0} {
			if {$time0 > 0.0} {
				set line [list 0.0 1.0]
				puts $zit $line
			}
		}
		if {$time0 >= $dur} {
			set line [list $dur 1.0]
			puts $zit $line
			break
		}
		set line [list $time0 1.0]	
		puts $zit $line
		set nexttime [expr $time0 + $splicelen]
		if {$nexttime >= $dur} {
			set line [list $dur 1.0]	
			puts $zit $line
			break
		}
		set line [list $nexttime $clatn_atn]	
		puts $zit $line
		set nexttime [expr $time1 - $splicelen]
		if {$nexttime >= $dur} {
			set line [list $dur clatn_atn]	
			puts $zit $line
			break
		}
		set line [list $nexttime $clatn_atn]	
		puts $zit $line
		if {$time1 >= $dur} {
			set line [list $dur $clatn_atn]
			puts $zit $line
			break
		}
		set line [list $time1 1.0]	
		puts $zit $line
		incr cnt
	}
	if {$time1 < $dur} {
		set line [list $dur 1.0]	
		puts $zit $line
	}
	close $zit
	return 1
}

#------ Insert silence in sound

proc CleanInsil {fnam} {
	global pr_clinsil clinsil_timepair clinsil_timepairbak clinsil_t clinsilsplice clinsilsmpcnt previous_clean clinsil_res clinsil_clr
	global pa evv ckit_filindex cklist clinsil_all snack_enabled shortwindows

	set evv(DISSPLICE) 15
	set srate $pa($fnam,$evv(SRATE))
	set sampdur [expr $pa($fnam,$evv(INSAMS)) / $pa($fnam,$evv(CHANS))]
	set minsplice [expr int(round($evv(DISSPLICE) * $evv(MS_TO_SECS) * $srate))]
	set mingap [expr $minsplice * 2]
	set dur  $pa($fnam,$evv(DUR))
	
	set outfile $evv(DFLT_OUTNAME)
	append outfile 0
	append outfile $evv(SNDFILE_EXT)
	set f .clinsil
	
	if [Dlg_Create $f "INSERT SILENCE IN SOUND" "set pr_clinsil 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0 -bd 0]
		set f1 [frame $f.1 -bd 0]
		set f1a [frame $f.1a -bd 0]
		set f2 [frame $f.2 -bd 0]
		set f3 [frame $f.3 -bd 0]
		set f4 [frame $f.4 -bd 0]

		if {[info exists shortwindows]} {
			set this_height 8
		} else {
			set this_height 16
		}
		set clinsil_t [text $f3.t -setgrid true -wrap word -width 76 -height $this_height \
		-xscrollcommand "$f3.sx set" -yscrollcommand "$f3.sy set"]
		scrollbar $f3.sy -orient vert  -command ".clinsil.3.t yview"
		scrollbar $f3.sx -orient horiz -command ".clinsil.3.t xview"
		pack $f3.t -side left -fill both -expand true
		pack $f3.sy -side right -fill y

		button $f0.keep -text "" -command {} -bd 0
		pack $f0.keep -side left -padx 2
		button $f0.quit -text "Abandon" -command "set pr_clinsil 0"
		if {$snack_enabled} {
			button $f0.see -text "Sound View" -command "SnackDisplay $evv(SN_TIMEPAIRS) $clinsil_t $evv(GRPS_OUT) $fnam" -bg $evv(SNCOLOR)
			pack $f0.see -side left -padx 40
		}
		pack $f0.quit -side right -padx 2
		pack $f0 -side top -fill x -expand true
		button $f1.clean    -text "Clean Sound" -width 11 -command "set pr_clinsil 1" -bg $evv(EMPH)
		button $f1.playsrc -text "Play Source" -width 11 -command "PlaySndfile $fnam 0"		
		if {$snack_enabled} {
			button $f1.playout -text "View Output" -width 11 -command "PlayCleanedOutput"
		} else {
			button $f1.playout -text "Play Output" -width 11 -command "PlayCleanedOutput"
		}
		bind $f <Key-space> "PlayCleanedOutput"
		button $f1.reset -text "Reset" -command ReinitClinsil
		button $f1.recov -text "Recover" -command DeleteAllTemporaryFiles
		pack $f1.clean $f1.playsrc $f1.playout $f1.reset $f1.recov -side left -padx 2
		pack $f1 -side top -fill x -expand true

		label $f1a.ll -text "Splice (mS)"
		entry $f1a.e -textvariable clinsilsplice -width 6
		pack $f1a.ll $f1a.e -side left -padx 2
		pack $f1a -side top -fill x -pady 2 
		frame $f.1b -bg [option get . foreground {}] -height 1
		pack $f.1b -side top -fill x -expand true -pady 1

		checkbutton $f2.all -text "Clean All" -variable clinsil_all -command "SetSmpcnt clinsil_all $sampdur; set clinsil_all 0"
		pack $f2.all -side top
		label $f2.ll -text "Start And End Samples Of Inserted Silence"
		frame $f2.kkk
		radiobutton	$f2.kkk.sc -variable clinsilsmpcnt -text "End Of File Sample" -command "SetSmpcnt clinsil_t $sampdur; set clinsilsmpcnt 0" -value 1
		radiobutton	$f2.kkk.res -variable clinsil_res -text "Restore Last Run Vals" -command "LastClean clinsil_t; set clinsil_res 0" -value 1
		radiobutton	$f2.kkk.clr -variable clinsil_clr -text "Clear Values" -command "ClearClean $clinsil_t; set clinsil_clr 0" -value 1

		pack $f2.ll -side top
		pack $f2.kkk.sc $f2.kkk.res $f2.kkk.clr -side left -pady 4
		pack $f2.kkk -side top
		pack $f2 -side top -fill x -pady 2

		pack $f3 -side top -fill both -expand true

		Scrolled_Listbox $f4.l -width 110 -height 6 -selectmode single
		pack $f4.l -side top -fill both -expand true
		pack $f4 -side top -pady 2
		wm resizable $f 1 1
		bind $f <Escape> {set pr_clinsil 0}
		bind $f <Return> {set pr_clinsil 1}
	}
	set clinsil_all 0
	wm title $f "INSERT SILENCE IN FILE [file tail $fnam]"
	set clinsilsplice $evv(DISSPLICE)
	$f.4.l.list delete 0 end
	$f.3.t delete 1.0 end
	set pr_clinsil 0
	set clinsil_timepair {}
	raise $f
	update idletasks
	StandardPosition2 .clinsil
	set finished 0
	My_Grab 0 $f pr_clinsil $f
	while {!$finished} {
		tkwait variable pr_clinsil
		$f.4.l.list delete 0 end
		switch -- $pr_clinsil {
			1 {
				set clinsilsplice [string trim $clinsilsplice]
				if {[string length $clinsilsplice] > 0} {
					if {![IsPositiveNumber $clinsilsplice]} {
						Inf "Invalid Splice Length"
						continue
					}
				} else {
					set clinsilsplice $evv(DISSPLICE)
				}
				set splicesecs [expr $clinsilsplice * $evv(MS_TO_SECS)]
				set minsplice [expr int(round($splicesecs * $srate))]
				set mingap [expr $minsplice * 2]
				catch {unset nutimepairs}
				set OK 1
				set len 0

				foreach word [$clinsil_t get 1.0 end] {
					set word [string trim $word]
					if {[string length $word] > 0} {
						lappend nutimepairs $word
						incr len
					}
				}
				if {![info exists nutimepairs]} {
					Inf "No Sample Times Given"
					continue
				}
				if {$len != 2} {
					Inf "Not A Pair Of Sample Times"
					continue
				}
				foreach item $nutimepairs {
					if {![regexp {^[0-9]+$} $item]} {
						Inf "Invalid Sampletime '$item'"
						continue
					}
				}
				set stt [lindex $nutimepairs 0]
				set end [lindex $nutimepairs 1]
				set step [expr $end - $stt]
				if {$step <= 0} {
					Inf "Times Not In Order"
					continue
				} elseif {$step <= $mingap} {
					Inf "Length Of Silence Too Short For Splices"
					continue

				}
				set clinsil_timepair $nutimepairs

				$f.4.l.list delete 0 end
				set clinsil_timepairbak $clinsil_timepair
				if {![RunClinsil $fnam $outfile .clinsil.4.l.list $stt $step]} {
					continue
				}
				.clinsil.0.keep config -text "Keep Output" -command "set pr_clinsil 2" -bg $evv(EMPH) -bd 2
				.clinsil.1.clean config -text "" -command {} -bg [option get . background {}] -bd 0
				if {$snack_enabled} {
					.clinsil.1.playout config -bg $evv(SNCOLOR)	
				} else {
					.clinsil.1.playout config -bg $evv(EMPH)	
				}
			}
			2 {
				if {![file exists $outfile]} {
					Inf "Cannot Find The Output File"
					.clinsil.0.keep config -text "" -command {} -bg [option get . background {}] -bd 0
					.clinsil.1.clean config -text "Clean Sound" -command "set pr_clinsil 1" -bg $evv(EMPH) -bd 2
					continue
				}
				set nufnam $evv(CLEANKIT_NAME)
				append nufnam $ckit_filindex
				append nufnam $evv(SNDFILE_EXT)
				if {[file exists $nufnam]} {
					Inf "'$nufnam' Already Exists"
					continue
				}
				if [catch {file rename $outfile $nufnam} zit] {
					Inf "Cannot Rename Output File To '$nufnam'"
					continue
				}
				if {[DoParse $nufnam 0 0 0] <= 0} {
					if {![file delete $nufnam]} {
						Inf "Failed To Delete Bad File '$nufnam'"
					}
					continue
				}
				$cklist insert end $nufnam
				incr ckit_filindex
				.clinsil.0.keep config -text "" -command {} -bg [option get . background {}] -bd 0
				.clinsil.1.clean config -text "Clean Sound" -command "set pr_clinsil 1" -bg $evv(EMPH) -bd 2
				.clinsil.1.playout config -bg [option get . background {}]
				break
			}
			0 {
				break
			}
		}
	}
	set previous_clean [$clinsil_t get 1.0 end]
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	destroy .clinsil
}

proc ReinitClinsil {} {
	global clinsil_timepair clinsil_timepairbak pr_clinsil evv

	if [string match [.clinsil.0.keep cget -text] "Keep Output"] {
		DeleteAllTemporaryFiles
		.clinsil.0.keep config -text "" -command {} -bg [option get . background {}] -bd 0
		.clinsil.1.clean config -text "Clean Source" -command "set pr_clinsil 1" -bg $evv(EMPH) -bd 2
		.clinsil.1.playout config -bg [option get . background {}]
		return
	}
	if {[info exists clinsil_timepairbak]} {
		.clinsil.3.t delete 1.0 end
		set clinsil_timepair $clinsil_timepairbak
		foreach {time0 time1} $clinsil_timepair {
			.clinsil.3.t insert end "$time0\t$time1\n"
		}
	}
}

proc RunClinsil {fnam outfile f stt end} {
	global clinsilsplice evv
	global CDPidrun prg_dun prg_abortd

	set cmd [file join $evv(CDPROGRAM_DIR) sfedit]
	lappend cmd insil 3 $fnam $outfile $stt $end -w$clinsilsplice

	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	set returnval 1
	$f delete 0 end
	Block "Cleaning Sound"
	set finished 0
	while {!$finished} {
		if [catch {open "|$cmd"} CDPidrun] {
			set line "$CDPidrun : Can't Run Process."
			$f insert end $line
			set returnval 0
			set finished 1
			break
		} else {
	   		fileevent $CDPidrun readable "Display_RpeBatch_Info $f"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			set line "Process Failed"
			$f insert end $line
			set returnval 0
			set finished 1
			break
		}
		if {$returnval} {
			$f delete 0 end
			$f insert end "Cleaning Completed"
		} 
		set finished 1
	}
	UnBlock
	$f yview moveto 1.0
	return $returnval
}

#----- Remove signal below a specified level in all analysis window channels of each stereo-channel of a stereofile, 

proc GeneralDenoiseStereo {fnam} {
	global pr_stdenoi denoistt denoiend denoipersist denoigain denoisplice pa evv shortwindows
	global denoipersist_last denoigain_last denoisplice_last denoistt_last denoiend_last denoisub_last
	global den_timepairs den_newbal snack_enabled denoi_swi
	global den_timepairsbak den_t denoisub denoisubbak denoismpcnt denoi_res denoiall denoi_fornoise
	global denoipersistbak denoigainbak denoisplicebak denoisttbak denoiendbak ckit_filindex cklist previous_clean
	global CDPidrun prg_dun prg_abortd CDPidrun noisegstfnam
	set f .stdenoi
	
	catch {unset den_timepairsbak}
	catch {unset denoisplice_last}
	catch {unset denoistt_last}
	catch {unset denoiend_last}

	if {$pa($fnam,$evv(CHANS)) != 2} {
		Inf "Stereo files only"
		return
	} 
	set srate [expr double ($pa($fnam,$evv(SRATE)))]
	set sampdur [expr $pa($fnam,$evv(INSAMS))/2]		;#	sampdur for processes is mono sampcnt
	set dur		$pa($fnam,$evv(DUR))
	set frametime [expr 1026.0 / (8.0 * $srate)]

	set minsplice [expr int(round(20 * $evv(MS_TO_SECS) * $srate))]
	set mingap [expr $minsplice * 2]

	set balancefile $evv(DFLT_OUTNAME)
	append balancefile 0
	append balancefile $evv(TEXT_EXT)

	set outfile $evv(DFLT_OUTNAME)
	append outfile 0
	append outfile $evv(SNDFILE_EXT)

	set outfile1 $evv(DFLT_OUTNAME)
	append outfile1 01
	append outfile1 $evv(SNDFILE_EXT)

	set outfile2 $evv(DFLT_OUTNAME)
	append outfile2 02
	append outfile2 $evv(SNDFILE_EXT)

	set ifile $evv(DFLT_OUTNAME)						;#	set up a temporary file to take input file
	append ifile 111 $evv(SNDFILE_EXT)
														;#	input file copied to a temporary file
	if [catch {file copy $fnam $ifile} zit] {
		Inf "Failed to copy input file to temporary stereo file : \n$zit"
		return
	}

	;#	SEPARATE CHANNELS OF STEREO INPUT

	set cmd [file join $evv(CDPROGRAM_DIR) housekeep]
	lappend cmd chans 2 $ifile
	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	Block "Separating Channels"
	if [catch {open "|$cmd"} CDPidrun] {
		Inf "$CDPidrun : Can't run process to separate channels of input."
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
		Inf "Separating channels of input file failed"
		DeleteAllTemporaryFiles
		UnBlock
		return
	}
	set	ofnam [file rootname [file tail $ifile]]
	set ofnam1 $ofnam 
	append ofnam1 _c1 $evv(SNDFILE_EXT)
	set ofnam2 $ofnam 
	append ofnam2 _c2 $evv(SNDFILE_EXT)
	if {![file exists $ofnam1] || ![file exists $ofnam2]} {
		Inf "Failed to extract all channels of input file"
		DeleteAllTemporaryFiles
		UnBlock
		return
	}
	UnBlock

	set noisegstfnam $fnam
	if [Dlg_Create $f "Stereo Denoise" "set pr_stdenoi 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0 -bd 0]
		set f1 [frame $f.1 -bd 0]
		set fx [frame $f.x -bd 0]
		set f2 [frame $f.2 -bd 0]
		set f3 [frame $f.3 -bd 0]
		set fy [frame $f.y -bd 0]
		set fz [frame $f.z -bd 0]
		set f4 [frame $f.4 -bd 0]

		if {[info exists shortwindows]} {
			set this_height 8
		} else {
			set this_height 16
		}
		set den_t [text $fz.t -setgrid true -wrap word -width 76 -height $this_height \
		-xscrollcommand "$fz.sx set" -yscrollcommand "$fz.sy set"]
		scrollbar $fz.sy -orient vert  -command ".stdenoi.7.t yview"
		scrollbar $fz.sx -orient horiz -command ".stdenoi.7.t xview"
		pack $fz.t -side left -fill both -expand true
		pack $fz.sy -side right -fill y

		button $f0.keep -text "" -width 11 -command {} -bd 0
		pack $f0.keep -side left -padx 2
		if {$snack_enabled} {
			button $f0.see -text "View Input" -command "SnackDisplay $evv(SN_TIMEPAIRS) noisegst $evv(GRPS_OUT) $noisegstfnam" -bg $evv(SNCOLOR)	;#	listing is now "noisegst"
			pack $f0.see -side left -padx 2
		}
		button $f0.quit -text "Abandon" -command "set pr_stdenoi 0"
		if {$snack_enabled} {
			frame $f0.1
			checkbutton $f0.1.where -text "Vals For Noise Segment" -variable denoi_fornoise -command "DenoiRoute $ofnam1 1"
			pack $f0.1.where -side left
		}
		pack $f0.quit -side right -padx 2
		if {$snack_enabled} {
			pack $f0.1 -side right -padx 40
		}
		pack $f0 -side top -fill x -expand true
		button $f1.clean -text "Clean Sound" -width 11 -command "set pr_stdenoi 1" -bg $evv(EMPH)
		button $f1.playsrc -text "Play Source" -width 11 -command "PlaySndfile $fnam 0"		
		if {$snack_enabled} {
			button $f1.playout -text "View Output" -width 11 -command "PlayCleanedStereoOutput"		;#	 Now play stereo output
		} else {
			button $f1.playout -text "Play Output" -width 11 -command "PlayCleanedStereoOutput"
		}
		bind $f <Key-space> "PlayCleanedStereoOutput"
		button $f1.reset -text "Reset" -command "ReinitDenoi 1"										;#	modified to allow stereo option
		button $f1.recov -text "Recover" -command "DeleteAllTemporaryFilesExcept $ofnam1 $ofnam2"	;#	don't delete separated channels of source						
		pack $f1.clean $f1.playsrc $f1.playout $f1.reset $f1.recov -side left -padx 2
		pack $f1 -side top -fill x -expand true

		checkbutton $fx.sub -variable denoisub -text "Subtract as well as gate"
		pack $fx.sub -side right -padx 2
		pack $fx -side top -fill x -expand true

		label $f2.ls -text " Noise Only segment: Start Time (samples)"
		entry $f2.es -textvariable denoistt -width 12
		label $f2.le -text "End Time (samples)"
		entry $f2.ee -textvariable denoiend -width 12
		label $f2.lc -text "Splice Duration (1 - 50 ms)"
		entry $f2.ec -textvariable denoisplice -width 12
		pack $f2.ls $f2.es $f2.le $f2.ee $f2.lc $f2.ec -side left -padx 2
		pack $f2 -side top -pady 1

		label $f3.lp -text "Persistance of deletable noise feature ( 1 - 1000 ms)"
		entry $f3.ep -textvariable denoipersist -width 12
		label $f3.lg -text "Noise Pregain (1 - 40)"
		entry $f3.eg -textvariable denoigain -width 12
		pack $f3.lp $f3.ep $f3.lg $f3.eg -side left -padx 2
		pack $f3 -side top -pady 1

		frame $f.3a -bg [option get . foreground {}] -height 1
		pack $f.3a -side top -fill x -expand true -pady 1
		label $fy.ll1 -text "To clean only certain region(s) of file"
		label $fy.ll2 -text "enter start and end samples of region(s)"
		frame $fy.kkk
		checkbutton $fy.kkk.all -text "Clean All" -variable denoiall -command "SetSmpcnt denois_all $sampdur; set denoiall 0"			;#	sampdur adjusted to be mono-sampcnt
		pack $fy.kkk.all -side top
		radiobutton	$fy.kkk.sc -variable denoismpcnt -text "End of file sample" -command "SetSmpcnt den_t $sampdur; set denoismpcnt 0" -value 1
		radiobutton	$fy.kkk.res -variable denoi_res -text "Restore last run vals" -command "LastClean den_t; set denoi_res 0" -value 1
		radiobutton	$fy.kkk.swi -variable denoi_swi -text "Vals below to noise seg" -command "SwapNoiParams $fnam 1; set denoi_swi 0" -value 1

		pack $fy.ll1 -side top
		pack $fy.ll2 -side top
		pack $fy.kkk.sc $fy.kkk.res $fy.kkk.swi -side left -padx 4
		pack $fy.kkk -side top
		pack $fy -side top -fill x -pady 2

		pack $fz -side top -fill both -expand true
		Scrolled_Listbox $f4.l -width 110 -height 6 -selectmode single
		pack $f4.l -side top -fill both -expand true
		pack $f4 -side top -pady 2
		wm resizable $f 0 0

		bind .stdenoi.2.es <Right> {focus .stdenoi.2.ee}
		bind .stdenoi.2.ee <Right> {focus .stdenoi.2.ec}
		bind .stdenoi.2.ec <Right> {focus .stdenoi.3.ep}
		bind .stdenoi.3.ep <Right> {focus .stdenoi.3.eg}
		bind .stdenoi.3.eg <Right> {focus .stdenoi.2.es}
		bind .stdenoi.2.es <Left> {focus .stdenoi.3.eg}
		bind .stdenoi.2.ee <Left> {focus .stdenoi.2.es}
		bind .stdenoi.2.ec <Left> {focus .stdenoi.2.ee}
		bind .stdenoi.3.ep <Left> {focus .stdenoi.2.ec}
		bind .stdenoi.3.eg <Left> {focus .stdenoi.3.ep}
		bind .stdenoi.2.es <Down> {focus .stdenoi.3.ep}
		bind .stdenoi.2.ee <Down> {focus .stdenoi.3.ep}
		bind .stdenoi.2.ec <Down> {focus .stdenoi.3.eg}
		bind .stdenoi.3.ep <Up> {focus .stdenoi.2.es}
		bind .stdenoi.3.eg <Up> {focus .stdenoi.2.ec}
		bind .stdenoi.3.ep <Down> {focus $den_t}
		bind .stdenoi.3.eg <Down> {focus $den_t}
		bind $f <Escape> {set pr_stdenoi 0}
		bind $f <Return> {set pr_stdenoi 1}
	}
	if {$snack_enabled} {
		set denoi_fornoise 1
		.stdenoi.0.see config -command "SnackDisplay $evv(SN_TIMEPAIRS) noisegst $evv(GRPS_OUT) $noisegstfnam"		;#	listing modified to "noisegst"
	}
	set denoiall 0
	set denoisub 1
	wm title $f "General denoise the file [file tail $fnam]"
	set denoigain 1.2
	set denoipersist [DecPlaces [expr 8.0 * $frametime * $evv(SECS_TO_MS)] 5]
	set denoisplice 3.0
	set denoigain_last $denoigain
	set denoipersist_last $denoipersist
	$f.4.l.list delete 0 end
	set pr_stdenoi 0
	raise $f
	update idletasks
	StandardPosition2 .stdenoi
	set finished 0
	My_Grab 0 $f pr_stdenoi $f
	while {!$finished} {
		tkwait variable pr_stdenoi
		switch -- $pr_stdenoi {
			1 {
				set denoisplice [string trim $denoisplice]
				if {[string length $denoisplice] <= 0} {
					Inf "No noise splice duration entered"
					continue
				}
				if {![IsNumeric $denoisplice] || ($denoisplice < 1.0) || ($denoisplice >= 50.0)} {
					Inf "Invalid noise splice duration entered"
					continue
				}
				set denoistt [string trim $denoistt]
				if {[string length $denoistt] <= 0} {
					Inf "No noise start time entered"
					continue
				}
				if {![regexp {[0-9]+} $denoistt] || ($denoistt < 0) || ($denoistt >= $sampdur)} {
					Inf "Invalid noise start time entered"
					continue
				}
				set denoiend [string trim $denoiend]
				if {[string length $denoiend] <= 0} {
					Inf "No noise end time entered"
					continue
				}
				if {![regexp {[0-9]+} $denoiend] || ($denoiend <= 0) || ($denoiend > $sampdur)} {
					Inf "Invalid noise end time entered"
					continue
				}
				set cutlen [expr double($denoiend - $denoistt)/$srate]
				if {$cutlen <= 0.0} {
					Inf "Incompatible noise start and end times entered"
					continue
				} elseif {$cutlen <= [expr 2.0 * $denoisplice * $evv(MS_TO_SECS)]} {
					Inf "Noise segment too short for splices"
					continue
				}
				set denoigain [string trim $denoigain]
				if {[string length $denoigain] <= 0} {
					Inf "No pregain value entered"
					continue
				}
				if {![IsPositiveNumber $denoigain]} {
					Inf "Invalid pregain value entered"
					continue
				}
				if {$denoigain < 1.0} {
					set denoigain 1.0
				} elseif {$denoigain > 40.0} {
					set denoigain 40.0
				}
				set denoipersist [string trim $denoipersist]
				if {[string length $denoipersist] <= 0} {
					Inf "No persist value entered"
					continue
				}
				if {![IsPositiveNumber $denoipersist]} {
					Inf "Invalid persist value entered"
					continue
				}
				if {$denoipersist < 1.0} {
					set denoipersist 1.0
				} elseif {$denoipersist > 1000.0} {
					set denoipersist 1000.0
				}
				$f.4.l.list delete 0 end

					;#	CHECK TIME PAIRS

				set den_newbal 0

				catch {unset nutimepairs}


				set nutimepairs [CleanSortTimes $den_t $mingap 0]
				set len [llength $nutimepairs]
				if {$len <= 0} {									;#	IF WE'RE NOISE REDUCING THE WHOLE FILE (i.e. WE DON'T NEED A BALANCEFILE)
					if [file exists $balancefile] {					;#	IF WE WERE NOT DOING THIS BEFORE (i.e. A BALANCEFILE EXISTS)
						if [catch {file delete $balancefile} zub] {	;#	DELETE THE EXISTING BALANCE FILE, AND PROCEED
							Inf "Cannot delete file '$balancefile'"
							continue
						}
						set den_newbal 1
					}
				} elseif {$len == 1} {
					continue
				} else {											;#	IF THERE ARE BRKPNT TIMES, WE'RE DENOISING BITS OF THE FILE
					set den_newbal 0								;#	CHECK TO SEE IF THE BREAKPOINT DATA HAS CHANGED
					if {[info exists den_timepairs]} {
						if {[llength $den_timepairs] == $len} {
							set den_retime 0
							foreach time0 $den_timepairs time1 $nutimepairs {
								if {$time0 != $time1} {
									set den_retime 1
									break
								}
							}
							if {$den_retime} {							;#	IF BREAKPOINT DATA HAS CHANGED, SET THE NEW VALUES
								set den_timepairs $nutimepairs
							}
						}
					} else {
						set den_timepairs $nutimepairs
					}												;#	CREATE (OR RE-CREATE) THE BALANCEFILE		
					if {![CreateBalanceFile den $balancefile $minsplice $srate $sampdur $dur]} {
						continue
					}
					set den_newbal 1
				}
;# 2023
				set denoi_chan2 0
				if {![RunDenoi $ofnam1 $denoistt $denoiend $denoisplice $denoipersist $denoigain $dur $denoisub 1]} {
					set denoigain_last	  $denoigain
					set denoipersist_last $denoipersist
					set denoisplice_last  $denoisplice
					set denoistt_last	  $denoistt
					set denoiend_last	  $denoiend
					set denoisub_last	  $denoisub
					if {[info exists den_timepairs]} {
						set den_timepairsbak $den_timepairs
					}
					continue
				}
				set denoigain_last	  $denoigain
				set denoipersist_last $denoipersist
				set denoisplice_last  $denoisplice
				set denoistt_last	  $denoistt
				set denoiend_last	  $denoiend
				set denoisub_last	  $denoisub
				if {[info exists den_timepairs]} {
					set den_timepairsbak $den_timepairs
				}
				if [catch {file rename $outfile $outfile1} zit] {
					Inf "Cannot rename channel 1 outfile"
					DeleteAllTemporaryFilesExcept $ofnam1 $ofnam2
					continue
				}
;# 2023
				set denoi_chan2	1
				if {![RunDenoi $ofnam2 $denoistt $denoiend $denoisplice $denoipersist $denoigain $dur $denoisub 1]} {
					catch {file delete $outfile}
					continue
				}
			    if [catch {file rename $outfile $outfile2} zit] {
					Inf "Cannot rename channel 2 outfile"
					DeleteAllTemporaryFilesExcept $ofnam1 $ofnam2
					continue
				}

				;#	MERGE CHANNELS TO STEREO

				set cmd [file join $evv(CDPROGRAM_DIR) submix]
				lappend cmd interleave $outfile1 $outfile2 $outfile
				set CDPidrun 0
				set prg_dun 0
				set prg_abortd 0
				Block "Merging Output Channels"
				if [catch {open "|$cmd"} CDPidrun] {
					set line "$CDPidrun : Can't merge cleaned channels to stereo channels."
					DeleteAllTemporaryFilesExcept $ofnam1 $ofnam2
					UnBlock
					continue
				} else {
	   				fileevent $CDPidrun readable "Display_RpeBatch_Info .stdenoi.4.l.list"
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				if {!$prg_dun} {
					set line "Merging channels failed"
					DeleteAllTemporaryFilesExcept $ofnam1 $ofnam2
					UnBlock
					continue
				}
				if {![file exists $outfile]} {
					Inf "Failed to merge channels of output file"
					DeleteAllTemporaryFilesExcept $ofnam1 $ofnam2
					UnBlock
					continue
				}
				set denoigain_last	  $denoigain
				set denoipersist_last $denoipersist
				set denoisplice_last  $denoisplice
				set denoistt_last	  $denoistt
				set denoiend_last	  $denoiend
				set denoisub_last	  $denoisub
				if {[info exists den_timepairs]} {
					set den_timepairsbak $den_timepairs
				}
				.stdenoi.0.keep config -text "Keep Output" -command "set pr_stdenoi 2" -bg $evv(EMPH) -bd 2
				.stdenoi.1.clean config -text "" -command {} -bg [option get . background {}] -bd 0
				if {$snack_enabled} {
					.stdenoi.1.playout config -bg $evv(SNCOLOR)	
				} else {
					.stdenoi.1.playout config -bg $evv(EMPH)	
				}
				UnBlock
			}
			2 {
				if {![file exists $outfile]} {
					Inf "Cannot find the output file"
					.stdenoi.0.keep config -text "" -command {} -bg [option get . background {}] -bd 0
					.stdenoi.1.clean config -text "Clean Sound" -command "set pr_stdenoi 1" -bg $evv(EMPH) -bd 2
					continue
				}
				set nufnam $evv(CLEANKIT_NAME)
				append nufnam $ckit_filindex
				append nufnam $evv(SNDFILE_EXT)
				if {[file exists $nufnam]} {
					Inf "'$nufnam' ALREADY EXISTS"
					continue
				}
				if [catch {file rename $outfile $nufnam} zit] {
					Inf "Cannot rename output file to '$nufnam'"
					continue
				}
				if {[DoParse $nufnam 0 0 0] <= 0} {
					if {![file delete $nufnam]} {
						Inf "Failed to delete bad file '$nufnam'"
					}
					continue
				}
				$cklist insert end $nufnam
				incr ckit_filindex
				.stdenoi.0.keep config -text "" -command {} -bg [option get . background {}] -bd 0
				.stdenoi.1.clean config -text "Clean Sound" -command "set pr_stdenoi 1" -bg $evv(EMPH) -bd 2
				.stdenoi.1.playout config -bg [option get . background {}]
				break
			}
			0 {
				break
			}
		}
	}
	DeleteAllTemporaryFiles
	if {[info exists denoipersist]} {
		set denoipersistbak $denoipersist
	}
	if {[info exists denoigain]} { 
		set denoigainbak $denoigain
	}
	if {[info exists denoisplice]} {
		set denoisplicebak $denoisplice
	}
	if {[info exists denoistt]} {
		set denoisttbak $denoistt
	} 
	if {[info exists denoiend]} {
		set denoiendbak $denoiend
	}
	if {[info exists denoisub]} {
		set denoisubbak $denoisub
	}
	set previous_clean [$den_t get 1.0 end]
	My_Release_to_Dialog $f
	destroy .stdenoi
}

proc PlayCleanedStereoOutput {} {
	global pa evv ckit snack_enabled
	set fnam $evv(DFLT_OUTNAME)
	append fnam 0
	append fnam $evv(SNDFILE_EXT)
	if {![file exists $fnam]} {
		Inf "No output file to play"
		return
	}
	set pa($fnam,$evv(CHANS)) 2		;#	Changed for stereo
	if {$snack_enabled} {
		set pa($fnam,$evv(SRATE)) $ckit(srate)
		set pa($fnam,$evv(DUR)) $ckit(dur)
		set pa($fnam,$evv(INSAMS)) $ckit(insams)
		SnackDisplay 0 $evv(SN_FROM_CLEANKIT_OUTPUT) 0 $fnam
		unset pa($fnam,$evv(SRATE))
		unset pa($fnam,$evv(DUR))
		unset pa($fnam,$evv(INSAMS))
	} else {
		PlaySndfile $fnam 0
	}
	unset pa($fnam,$evv(CHANS))
}
