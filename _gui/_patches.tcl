#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD June 30 2013
# ... fixup button rectangles

#############
# PATCHES	#
#############

#------ Delete an existing (parameters-) patch

proc DeletePatch {pl pd patch_ext} {
	global patchcnt cur_patch_display evv

	set patchno [$pl curselection]							;#	Get curselected lines (should be only 1)
	if {[string length $patchno] <= 0} {					;#	If none selected, return
		Inf "No patch selected"
		return
	}
	if [AreYouSure] {
		set patchname [$pl get $patchno]						;#	Get selected patchanme
		set fnam [file join $evv(PATCH_DIRECTORY) $patchname.$patch_ext]	;#	Reconstruct full name of file
		if [catch {file delete $fnam} in] {					;#	Attempt to delete it
			Inf "Cannot delete patch $patchname"
			return
		}
		if [string match $patchname $cur_patch_display] {
			set cur_patch_display ""
		}
		$pl delete $patchno
		incr patchcnt -1								;#	If successful, delete name from patchlist
		if {$patchcnt <= 0} {							;#	if patchlist now empty
		 	$pd.load   config -state disabled			;#	disable LOAD, & DELETE  buttons
			$pd.delete config -state disabled
		}
	}
}

#------ Load an existing (paramvals-) patch into the parameter dialog

proc LoadPatch {pl patch_ext} {
	global prm pmcnt ppg patchparam cur_patch cur_patch_display ins dfault wstk evv

	set indx [$pl curselection]
	if {[string length $indx] <= 0} {
		set i 0
		foreach p_nam [$pl get 0 end] {
			if {[string match $p_nam "temp"]} {
				break
			}
			incr i
		}
		if {$i < [$pl index end]} {
			$pl selection set $i
			set indx $i
		} else {
			Inf "No patch selected"
			return
		}
	}
	set patchname [$pl get $indx]
	set fnam [file join $evv(PATCH_DIRECTORY) $patchname.$patch_ext]	;#	Reconstruct full name of file
	if [catch {open $fnam r} fileId] {					;#	Attempt to open it
		Inf "Cannot open patchfile $patchname"
		return
	}
	catch {unset cur_patch}
	set i 0
	while {[gets $fileId line] >= 0} {						;#	Get 1 line at a time, from file
		set newparams [split $line]
		foreach item $newparams {
			set patchparam($i) $item						;#	And reassemble into a true list
			lappend cur_patch $item
			incr i
		}
	}			
	if {$i != $pmcnt} {
		set msg "Patch May Be Invalid For This Mode Of The Process\nOr It May Refer To A Previous Version Of The Process\n\nProceed Anyway ?"
		set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
		if [string match no $choice] {
			catch {unset cur_patch}
			close $fileId
			return
		}
	}
	set parcnt $i
	if {$pmcnt < $parcnt} {		;#	In case patch has too many params, scale back number of params to set
		set parcnt $pmcnt
	}
	set cur_patch_display $patchname
	close $fileId

	set i 0
	while {$i < $parcnt} {
		set prm($i) $patchparam($i)		
		incr i
	}
	while {$i < $pmcnt} {		;#	In case patch has less params than prog takes (some of which may be new, in a new version of prog)
		set prm($i) $dfault($i)	;#	set any remaining params to default vals
		incr i
	}
	TestParamsWithReversion
}

#------ Store a set of parameters, in a named file

proc StorePatch {w pbuttons patch_ext} {
	global prm new_patchname wstk pmcnt ins patchcnt sl_real papag evv

	if {!$sl_real} {
		Inf "If You Type A Name In The Entry Box Below,\nYou Can Save All The Parameter Values You Just Used\nAs A 'Patch'\n\nThe Patch Name Will Appear In The List Below\nAnd By Clicking On The Name You Can Recall All The Parameters, At Once."
		return
	}
	set entri $papag.patches.name.e

	if {$pmcnt <= 0} {
		Inf "No parameters to store"
		return
	}
	set pcnt 0
	while {$pcnt < $pmcnt} {
 		if {[string match {\*} $prm($pcnt)]} {
			Inf "You Cannot Store Patches With A \"*\" Parameter Value"
			return
		}
		incr pcnt
	}

#JUNE 30 UC-LC FIX
	set force_temp 0
	if {[string length $new_patchname] == 0} {
		set new_patchname "temp"
		ForceVal $entri $new_patchname
		set force_temp 1
	}
	set new_patchname [string tolower $new_patchname]
	set thisname [FixTxt $new_patchname "patch name"]
	if {[string length $thisname] <= 0} {
		return
	}
	if {![regexp {^[A-Za-z0-9_]+$} $thisname]} {	;#	patchnames must be alphanumeric, possibly with underscores
		Inf "Invalid patch name"
		return
	}										;#	associate patch with relevant file(name)
	set fullname [file join $evv(PATCH_DIRECTORY) $thisname.$patch_ext]
	set over_write 0
	foreach fi [$w get 0 end] {				;#	Check if name already exists
		if [string match $thisname $fi] {
			if {$force_temp} {
				set over_write 1
				break
			}
			set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] \
					-message "This patch name already exists: Overwrite existing patch?"]
			if [string match no $choice] {
				return
			} else {
				set over_write 1
				break
			}
		}
	}
	if [catch {open $fullname w} fileId] {	;#	Open patchfile, to create, or to overwrite
		Inf "$fileId"
		Inf "Cannot open patch file, to save patch"
		return
	}		
	set paramstr $prm(0)					;#	Assemble all prm values into a list & store in file
	set pcnt 1
	while {$pcnt < $pmcnt} {
 		lappend paramstr $prm($pcnt)
		incr pcnt
	}
	if [catch {puts $fileId "$paramstr"} err] {
		Inf $err
		Inf "Failed to save patch"
		catch {close $fileId}
		return
	}

	close $fileId
	if {!$over_write} {								;#	If it is a new patchfile
		$w insert end $thisname						;#	Add to listing
		SortListing $w 0							;#	Sort into alphnumeric order
	 	$pbuttons.load   config -state normal		;#	Enable the LOAD & DELETE PATCH buttons..
		$pbuttons.delete config -state normal		;# 	in case they're curently disabled
	}
	incr patchcnt
	set $new_patchname ""
	ForceVal $entri $new_patchname
	set new_patchname ""
}

#------ Store or get SOME of parameters

proc Subpatch {store} {
	global prm wstk pmcnt subpatchlist sl_real evv pr_subpatch subpatches subpatchname sub_p subp_shift old_subpatch_protocol evv

	if {!$sl_real} {
		Inf "You Can Save & Retrieve Some (Rather Than All) Of The Parameters Used On This Page."
		return
	}
	if {$pmcnt <= 0} {
		Inf "No parameters to store"
		return
	}
	set subpatchname ""
	set f .subpatch
	if [Dlg_Create $f "STORE SUBPATCH" "set pr_subpatch 0" -borderwidth $evv(SBDR)] {
		set b0 [frame $f.b0 -borderwidth $evv(SBDR)]
		set b1 [frame $f.b1 -borderwidth $evv(SBDR)]
		set b2a [frame $f.b2a -borderwidth $evv(SBDR)]
		set b2b [frame $f.b2b -borderwidth $evv(SBDR)]
		set b2c [frame $f.b2c -borderwidth $evv(SBDR)]
		set b2d [frame $f.b2d -borderwidth $evv(SBDR)]
		set b3 [frame $f.b3 -borderwidth $evv(SBDR)]
		set b3a [frame $f.b3a -borderwidth $evv(SBDR)]
		set b4 [frame $f.b4 -borderwidth $evv(SBDR)]
		button $b0.ss -text "Store Subpatch" -command {set pr_subpatch 1} -highlightbackground [option get . background {}]
		button $b0.ds -text "Delete Subpatch" -command {set pr_subpatch 2} -highlightbackground [option get . background {}]
		button $b0.qu -text Close -command {set pr_subpatch 0} -highlightbackground [option get . background {}]
		pack $b0.ss $b0.ds -side left -padx 4
		pack $b0.qu -side right
		label $b1.name -text "New Subpatch Name"
		entry $b1.e -textvariable subpatchname -width 40
		pack $b1.name $b1.e -side left -padx 2

		label $b2a.pp -text "WHICH PARAMS TO STORE"
		pack $b2a.pp -side top
		set k 1
		while {$k <= 10} {
			checkbutton $b2b.$k -variable sub_p($k) -text $k 
			pack $b2b.$k -side left
			incr k
		}
		while {$k <= 20} {
			checkbutton $b2c.$k -variable sub_p($k) -text $k 
			pack $b2c.$k -side left
			incr k
		}
		while {$k <= 30} {
			checkbutton $b2d.$k -variable sub_p($k) -text $k 
			pack $b2d.$k -side left
			incr k
		}
		label $b3a.ll -text "Shift subpatch position by  "
		entry $b3a.sh -textvariable subp_shift -width 4
		pack $b3a.ll $b3a.sh -side left
		label $b3.sp -text "EXISTING SUBPATCHES"
		pack $b3.sp -side top -pady 1
		set subpatches [Scrolled_Listbox $b4.ll -width 64 -height 26 -selectmode single]
		pack $b4.ll -side left -fill both -expand true
		pack $b0 $b1 $b2a $b2b $b2c $b2d $b3a $b3 $b4 -side top -pady 2 -fill x -expand true
		bind $f <Escape> {set pr_subpatch 0} 
	}
	$subpatches delete 0 end
	if {[info exists subpatchlist]} {
		foreach sp $subpatchlist {
			$subpatches insert end $sp
		}
	}
	if {$store} {
		$f.b1.name config -text "New Subpatch Name"
		$f.b1.e config -state normal -bd 2
		$f.b0.ss config -text "Store Subpatch"
		wm title $f "STORE NEW SUBPATCH"
		$f.b2a.pp config -text "WHICH PARAMS TO STORE"

		$f.b3a.ll config -text ""
		$f.b3a.sh config -state disabled -bd 0
		set subp_shift ""

		set k 1
		while {$k < 11} {
			set sub_p($k) 0
			if {$k <= $pmcnt} {
				if {[IsDeadParam [expr $k - 1]]} {
					$f.b2b.$k config -state disabled -text ""
				} else {
					$f.b2b.$k config -state normal -text $k
				}
			} else {
				$f.b2b.$k config -state disabled -text ""
			}
			incr k
		}
		while {$k < 21} {
			set sub_p($k) 0
			if {$k <= $pmcnt} {
				if {[IsDeadParam [expr $k - 1]]} {
					$f.b2c.$k config -state disabled -text ""
				} else {
					$f.b2c.$k config -state normal -text $k
				}
			} else {
				$f.b2c.$k config -state disabled -text ""
			}
			incr k
		}
		while {$k < 31} {
			set sub_p($k) 0
			if {$k <= $pmcnt} {
				if {[IsDeadParam [expr $k - 1]]} {
					$f.b2d.$k config -state disabled -text ""
				} else {
					$f.b2d.$k config -state normal -text $k
				}
			} else {
				$f.b2d.$k config -state disabled -text ""
			}
			incr k
		}
	} else {
		$f.b1.name config -text ""
		$f.b1.e config -state disabled -bd 0
		$f.b0.ss config -text "Get Subpatch"
		wm title $f "GET SUBPATCH"
		$f.b2a.pp config -text ""

		$f.b3a.ll config -text "Shift subpatch position by  "
		$f.b3a.sh config -state normal -bd 2
		set subp_shift 0

		set k 1
		while {$k < 11} {
			set sub_p($k) 0
			$f.b2b.$k config -state disabled -text ""
			incr k
		}
		while {$k < 21} {
			set sub_p($k) 0
			$f.b2c.$k config -state disabled -text ""
			incr k
		}
		while {$k < 31} {
			set sub_p($k) 0
			$f.b2d.$k config -state disabled -text ""
			incr k
		}
	}
	raise $f
	set pr_subpatch 0
	set finished 0
	if {$store} {
		My_Grab 0 $f pr_subpatch $f.b1.e
	} else {
		My_Grab 0 $f pr_subpatch $subpatches
	}
	while {!$finished} {
		tkwait variable pr_subpatch
		switch -- $pr_subpatch {
			2 {
				set i [$subpatches curselection]
				if {![info exists i] || ($i < 0)} {
					Inf "No Subpatch Selected"
					continue
				}
				DeleteSubPatch $i
				continue
			}
			1 {
				if {$store} {
					set k 1
					catch {unset psetlist}
					while {$k < 31} {
						
						if {$sub_p($k)} {
							lappend psetlist [expr $k - 1]
						}
						incr k
					}
					if {![info exists psetlist]} {
						Inf "No Parameters Selected"
						continue
					}
					if {[string length $subpatchname] <= 0} {
						Inf "No Subpatch Name Entered."
						continue
					}
					set subpatchname [string tolower $subpatchname]
					if {![regexp {^[A-Za-z0-9_]+$} $subpatchname]} {	;#	subpatchnames must be alphanumeric, possibly with underscores
						Inf "Invalid Subpatch Name"
						continue
					}										;#	associate subpatch with relevant file(name)
					if {![file exists $evv(SUBPATCH_DIRECTORY)] || ![file isdirectory $evv(SUBPATCH_DIRECTORY)]} {
						if {[catch {file mkdir $evv(SUBPATCH_DIRECTORY)} zit]} {
							Inf "Cannot Create Subpatches Directory\n$zit"
							break
						}
					}
					set fullname [file join $evv(SUBPATCH_DIRECTORY) $subpatchname$evv(TEXT_EXT)]
					set over_write -1
					if {[info exists subpatchlist]} {
						set i 0
						foreach item $subpatchlist {				;#	Check if name already exists
							set fi [lindex $item 0]
							if [string match $subpatchname $fi] {
								set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] \
										-message "This Subpatch Name Already Exists: Overwrite Existing Subpatch?"]
								if [string match no $choice] {
									continue
								} else {
									set over_write $i
									break
								}
							}
							incr i
						}
					}
					if [catch {open $fullname w} fileId] {	;#	Open subpatchfile, to create, or to overwrite
						Inf "Cannot Open Subpatch File, To Save Subpatch\n$fileId"
						continue
					}		
					catch {unset paramstr}
					foreach i $psetlist {
						if {$old_subpatch_protocol} {
							lappend paramstr $i $prm($i)
						} else {
							lappend paramstr [expr $i + 1] $prm($i)
						}
					}					
					if [catch {puts $fileId $paramstr} err] {
						Inf "Failed To Save Subpatch : $err"
						catch {close $fileId}
						continue
					}

					close $fileId
					set full_details [concat $subpatchname $paramstr]
					if {$over_write < 0} {					;#	If it is a new patchfile
						set inserted 0
						if {[info exists subpatchlist]} {
							set cnt 0
							foreach item $subpatchlist {
								set subp_name [lindex $item 0]
								if {[string compare $subp_name $subpatchname] >= 0} {
									set subpatchlist [linsert $subpatchlist $cnt $full_details]
									set inserted 1
									break
								}
								incr cnt
							}
						}
						if {!$inserted} {
							lappend subpatchlist $full_details
						}
					} else {								;# Not new name: replace existing item
						set subpatchlist [lreplace $subpatchlist $over_write $over_write $full_details]
					}
					$subpatches delete 0 end
					foreach sp $subpatchlist {
						$subpatches insert end $sp
					}
					set k [LstIndx $full_details $subpatches]			;#	Hilight new patch in list
					if {$k >= 0} {
						$subpatches selection clear 0 end
						$subpatches selection set $k
						$subpatches yview moveto [expr double($k) / double([$subpatches index end])]
					}
					continue
				} else {
					if {[string length $subp_shift] <= 0} {
						set subp_shift 0
					} elseif {![IsNumeric $subp_shift] || ![regexp {^[0-9\-]+$} $subp_shift]} {
						Inf "Invalid Shift Value Entered"
						continue
					}
					set pdescrips [FindGadgetTypes]
					if {[llength $pdescrips] <= 0} {
						Inf "This Process Takes No Parameters"
						break
					}
					set i [$subpatches curselection]
					if {![info exists i] || ($i < 0)} {
						Inf "No Subpatch Selected"
						continue
					}
					set thispatch [$subpatches get $i]
					set thispatch [lrange $thispatch 1 end]
					set OK 1
					catch {unset nu_thispatch}
					foreach {param_no param_val} $thispatch {
						if {!$old_subpatch_protocol} {
							incr param_no -1
						}
						incr param_no $subp_shift
						if {$param_no < 0} {
							Inf "Invalid Shift Value For This Subpatch"
							set OK 0
							break
						}
						lappend nu_thispatch $param_no $param_val	

					}
					if {!$OK} {
						continue
					}
					set thispatch $nu_thispatch
					set maxparindex [llength $thispatch]
					incr maxparindex -2
					set maxpar [lindex $thispatch $maxparindex]
					if {$maxpar >= $pmcnt} {
						Inf "This Subpatch Does Not Tally With The Process"
						continue
					}
					set OK 1
					foreach {pno pval} $thispatch {
						if {($pno < 0)} {
							Inf "Invalid Parameter Number In This Subpatch"
							set OK 0
							break
						}
						if {![ValidSubpatchValue $pno $pval $pdescrips]} {
							set OK 0
							break
						}
					}
					if {!$OK} {
						continue
					}
					foreach {pno pval} $thispatch {
						set prm($pno) $pval
						if {[IsNumeric $pval]} {
							set typ [lindex [lindex $pdescrips $pno] 1]
							switch -- $typ {
								PLOG -
								LOGNUMERIC {
									SetScale $pno log
								}
								POWTWO {
									SetScale $pno powtwo
								}
								NUMERIC -
								LINEAR -
								FILE_OR_VAL {
									SetScale $pno linear
								}
							}
						}
					}
					set finished 1
				}
			}
			0 {
				break
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#-------- check subpatch value against valid values for parameter in patch

proc ValidSubpatchValue {pno pval pdescrips} {
	global actvhi actvlo

	foreach pdescrip $pdescrips {
		if {[string match $pno [lindex $pdescrip 0]]} {

			switch -- [lindex $pdescrip 1] {
				LINEAR -
				LOG -
				PLOG -
				FILE_OR_VAL {
					if {[IsNumeric $pval] && (($pval > $actvhi($pno)) || ($pval < $actvlo($pno)))} {
						Inf "Value For Parameter [expr $pno + 1] Out Of Range"
						return 0
					}
					return 1
				}
				CHECKBUTTON {
					if {![regexp {^[0-1]+$} $pval] || !(($pval == 0) || ($pval == 1))} {
						Inf "Inappropriate Value For Checkbutton Parameter [expr $pno + 1]"
						return 0
					}
					return 1
				}
				SRATE_GADGET {
					if {!(($pval == 16000) || ($pval == 22050) || ($pval == 24000) \
					|| ($pval == 32000) || ($pval == 44100) || ($pval == 48000))} {
						Inf "Inappropriate Value For Sample Rate Parameter [expr $pno + 1]"
						return 0
					}
					return 1
				}
				OPTIONAL_FILE -
				FILENAME -
				GENERICNAME -
				STRING_A -
				STRING_B -
				STRING_C -
				STRING_D -
				STRING_E -
				VOWELS {
					if {[IsNumeric $pval]} {
						Inf "Inappropriate (numeric) Value For Parameter [expr $pno + 1]"
						return 0
					}
					return 1
				}
				POWTWO {
					if {![regexp {^[0-9]+$} $pval]} {
						Inf "Inappropriate (non-integer) Value For Parameter [expr $pno + 1]"
						return 0
					}
					set j $pval
					while {$j > 2} {
						set j [expr $j/2]
					}
					if {$j != 2} {
						Inf "Inappropriate Value (not a power of two) For Parameter [expr $pno + 1]"
						return 0
					}
					return 1
				}
				NUMERIC -
				LOGNUMERIC {
					if {![IsNumeric $pval]} {
						Inf "Inappropriate (non-numeric) Value For Parameter [expr $pno + 1]"
						return 0
					}
					if {($pval > $actvhi($pno)) || ($pval < $actvlo($pno))} {
						Inf "Value For Parameter [expr $pno + 1] Out Of Range"
						return 0
					}
					return 1
				}
				TIMETYPE {
					Inf "Subpatches Do Not Work With Parameters Like Parameter [expr $pno + 1]"
					return 0
				}
				MIDI_GADGET {
					if {![regexp {^[0-9]+$} $pval] || ($pval < 0) || ($pval > 11)} {
						Inf "Inappropriate Value For Midi Parameter [expr $pno + 1]"
						return 0
					}
					return 1
				}
				OCT_GADGET {
					if {![regexp {^[0-4\-]+$} $pval] || ![IsNumeric $pval] || ($pval < -4) || ($pval > 4)} {
						Inf "Inappropriate Value For Octave Parameter [expr $pno + 1]"
						return 0
					}
					return 1
				}
				CHORD_GADGET {
					if {![regexp {^[0-4]+$} $pval] || ($pval < 0) || ($pval > 4)} {
						Inf "Inappropriate Value For Chord-type Parameter [expr $pno + 1]"
						return 0
					}
					return 1
				}
				TWOFAC {
					if {![regexp {^[0-9]+$} $pval] \
					|| !(($pval == 1) || ($pval == 2) || ($pval == 4) || ($pval == 8) || ($pval == 16) || ($pval == 32))} {
						Inf "Inappropriate Value (not a power of 2) For Parameter [expr $pno + 1]"
						return 0
					}
					return 1
				}
				WAVETYPE {
					if {![regexp {^[1-4]+$} $pval] || ($pval < 1) || ($pval > 4)} {
						Inf "Inappropriate Value For Wave-type Parameter [expr $pno + 1]"
						return 0
					}
					return 1
				}
				DEAD {
					return 1
				}
			}		
		}
	}
	Inf "Unable To Find Range Details Of Parameter [expr $pno + 1]"
	return 0
}

#----- Find types of the parameter gadgets

proc FindGadgetTypes {} {
	global gdg_cnt pg_spec
	set gcnt 0
	set pcnt 0
	set pdescrips {}
	while {$gcnt < $gdg_cnt} {
		if {[IsDeadParam $gcnt]} {
			lappend pdescrips [list $pcnt DEAD]
			incr pcnt
			incr gcnt
			continue
		}
		set parameter_props [lindex $pg_spec $gcnt]  		;#	Find prm-props-group for 1 prm
		set prop_id [lindex $parameter_props 0]				;#	Get first property

		if {[string match $prop_id SWITCHED]} {
			lappend pdescrips [list $pcnt CHECKBUTTON]
			incr pcnt
			lappend pdescrips [list $pcnt NUMERIC]
		} else {
			lappend pdescrips [list $pcnt $prop_id]
		}
		incr pcnt
		incr gcnt
	}
	return $pdescrips
}

#------ Delete an existing (parameters-) subpatch

proc DeleteSubPatch {i} {
	global subpatches subpatchlist evv

	set thissubpatch [$subpatches get $i]
	if [AreYouSure] {
		set subpatchname [lindex $thissubpatch 0]
		set fnam [file join $evv(SUBPATCH_DIRECTORY) $subpatchname$evv(TEXT_EXT)]	;#	Reconstruct full name of file
		if [catch {file delete $fnam} in] {					;#	Attempt to delete it
			Inf "Cannot delete patch $subpatchname"
			return
		}
		$subpatches delete $i
		set subpatchlist [lreplace $subpatchlist $i $i]
	}
}

#------ Load existing Sub-patches to SoundLoom

proc LoadSubpatches {} {
	global subpatchlist evv
	if {![file exists $evv(SUBPATCH_DIRECTORY)] || ![file isdirectory $evv(SUBPATCH_DIRECTORY)]} {
		return
	}
	foreach fnam [lsort -dictionary [glob -nocomplain [file join $evv(SUBPATCH_DIRECTORY) *]]] {
		if [catch {open $fnam r} zit] {
			lappend badsubps [file rootname [file tail $fnam]]
			continue
		}
		set OK 1
		catch {unset nuline}
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			set line [split $line]
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] > 0} {
					lappend nuline $item
				}
			}
			set len [llength $nuline]
			if {($len == 0) || ![IsEven $len]} {
				lappend bumsubps [file rootname [file tail $fnam]]
				set OK 0
			}
			break
		}
		close $zit
		if {!$OK} {
			continue
		}
		set this_subp [file rootname [file tail $fnam]]
		set this_subp [concat $this_subp $nuline]
		lappend subpatchlist $this_subp
	}
	set msg ""
	if {[info exists badsubps]} {
		set cnt 0
		append msg "The Following Subpatches Failed To Load\n"
		foreach fnam $badsubps {
			if {$cnt > 20} {
				append msg "\nAnd More"
				break
			}
			append msg $fnam "  "
			incr cnt
		}
	}
	if {[info exists bumsubps]} {
		set cnt 0
		append msg "The Following Subpatches Were Corrupted\n"
		foreach fnam $bumsubps {
			if {$cnt > 20} {
				append msg "\nAnd More"
				break
			}
			append msg $fnam "  "
			incr cnt
		}
	}
	if {[string length $msg] > 0} {
		Inf $msg
	}
}

##################
#	SYNTH SETS	 #
##################

#
# UBER PROGRAMME TO FILTER WHITE NOISE WITH VARYING Q OR HARMONICS
# TO MAKE RELATED SET OF SOUND IMPULSES OF SAME LENGTH
#
# FILTER-PARTIALS CAN BE ENTERED
# Q OR HARMONICS-CNT CAN BE SPECIFIED AS A SERIES OF RELATED VALUES
#
# SOUND-OUTPUTS ARE SYSTEMATICALLY NAMED
#

#------ Requires 
#------ a soundfile source to filter
#------ a list of partialvals to create a filter file (first must be 1)
#------ a list of Q values for varipartial filter, or of harmonics-cnt values for varibank filter
#------	A Q value in the param "typ" for  varibank filter, or typ 0 for varipartial filter.

proc GenerateSpectraByFiltering {} {
	global chlist evv pa wl wstk pr_sre sre_ftyp sre_settyp sre_ftyp sre_pitch sre_q sre_old_q sre_dbl sre_exp

	catch {unset sre_old_q}

	set startmsg "Requires A Soundfile, Followed By 2 Textiles.\n"
	append startmsg "The First Textfile Is A List Of Partials (first Value \"1\" Then Rising)\n"
	append startmsg "The Second Is A List Of Either \"Q\" Values (12-9999) Or \"Harmonics-count\" Values (1-200)"

	if {![info exists chlist] || ([llength $chlist] !=3)} {
		Inf $startmsg
		return
	}
	set fnam [lindex $chlist 0]
	if {$pa($fnam,$evv(FTYP)) == $evv(SNDFILE)} {
		set srcfile $fnam
		set srate $pa($fnam,$evv(SRATE))
		set dur $pa($fnam,$evv(DUR))
	} else {
		Inf $startmsg
		return
	}
	set n 0
	foreach fnam [lrange $chlist 1 end] {
		if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)) || ![IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
			Inf $startmsg
			return
		} elseif {($pa($fnam,$evv(MINNUM)) < 1.0) || ($pa($fnam,$evv(MAXNUM)) > 9999)} {
			Inf $startmsg
			return
		}
		switch -- $n {
			0 {
				if {$pa($fnam,$evv(MINNUM)) != 1.0} {
					Inf $startmsg
					return
				}
				set partialsfile $fnam
			}
			1 {
				if {$pa($fnam,$evv(MINNUM)) < 1.0} {
					Inf $startmsg
					return
				}
				if {$pa($fnam,$evv(MAXNUM)) <= 200} {
					set intyp am ;# AMBIGUOUS
				} else {
					set intyp vp
				}
				set valsfile $fnam
			}
		}
		incr n
	}

	set f .sre
	if [Dlg_Create $f "CREATE SPECTRALLY-RELATED FILES" "set pr_sre 0" -borderwidth $evv(BBDR)] {
		frame $f.0
		button $f.0.ab -text Abandon -width 10 -command "set pr_sre 0"
		button $f.0.ok -text Generate -width 10 -command "set pr_sre 1"
		pack $f.0.ab -side right
		pack $f.0.ok -side left
		pack $f.0 -side top -pady 2 -fill x -expand true
		frame $f.1
		label $f.1.ll -text "MIDI pitch" 
		entry $f.1.e -textvariable sre_pitch
		pack $f.1.e $f.1.ll -side left -padx 2
		pack $f.1 -side top -pady 2 -fill x -expand true
		frame $f.2
		label $f.2.ll -text "Filter Type"
		entry $f.2.e -textvariable sre_ftyp -width 16 -state readonly
		label $f.2.ll2 -text "Q value"
		entry $f.2.e2 -textvariable sre_q -width 16
		pack $f.2.e $f.2.ll $f.2.e2 $f.2.ll2 -side left -padx 2
		pack $f.2 -side top -pady 2 -fill x -expand true
		frame $f.3
		radiobutton $f.3.vb -variable sre_settyp -text "varibank (vary harmonics-cnt)" -value 1 -command SetSBEtyp
		radiobutton $f.3.vp -variable sre_settyp -text "varipartial (vary Q)"          -value 0 -command SetSBEtyp
		pack $f.3.vb $f.3.vp -side left 
		pack $f.3 -side top -pady 2 -fill x -expand true
		frame $f.4
		checkbutton $f.4.dbl -variable sre_dbl -text "double filter"
		pack $f.4.dbl -side left 
		pack $f.4 -side top -pady 2 -fill x -expand true
		frame $f.5
		checkbutton $f.5.exp -variable sre_exp -text "exp decay"
		pack $f.5.exp -side left 
		pack $f.5 -side top -pady 2 -fill x -expand true
		wm resizable $f 1 1
		bind $f <Return> {set pr_sre 1}
		bind $f <Escape> {set pr_sre 0}
	}
	set sre_dbl 1
	set sre_q ""
	switch -- $intyp {
		"vp" {
			$f.2.ll2 config -text ""
			$f.2.e2 config -bd 0 -state disabled -disabledbackground [option get . background {}]
			set sre_settyp 0
			$f.3.vb config -state disabled -disabledforeground [option get . foreground {}]
			$f.3.vp config -state disabled -disabledforeground [option get . foreground {}]
			set sre_ftyp "varipartials"	
		}
		"am" {
			$f.2.ll2 config -text "Q value"
			$f.2.e2 config -bd 2 -state normal
			set sre_settyp -1
			$f.3.vb config -state normal
			$f.3.vp config -state normal
			set sre_ftyp ""	
		}
	}
	set finished 0
	set pr_sre 0
	raise $f
	My_Grab 0 $f pr_sre $f.1.e
	while {!$finished} {
		tkwait variable pr_sre
		if {$pr_sre} {
			if {![IsNumeric $sre_pitch] || ($sre_pitch < 0.0) || ($sre_pitch > 127)} {
				Inf "No Valid Pitch Value Entered (Range 0 -127)"
				continue
			}
			set nyquist [expr floor(double($srate)/2.0)]

			set hz [MidiToHz $sre_pitch]
			if {$hz >= $nyquist} {
				Inf "Pitch Value Beyond Nyquist At This Sample Rate"
				continue
			}
			set len [string length $sre_pitch]
			set n 0
			set pnam ""
			while {$n < $len} {
				set item [string index $sre_pitch $n]
				if {[string match  $item "."]} {
					append pnam "p"
				} else {
					append pnam $item
				}
				incr n
			}

			;#	GENERATE FILTER FILE NAMES FROM PARTIALS FILE NAME, AND CHECK IF THEY EXIST

			set filtfileb [file rootname [file tail $partialsfile]]
			append filtfileb "_" $pnam "_vb" $evv(TEXT_EXT)
			set msg ""
			$wl selection clear 0 end
			if [file exists $filtfileb] {
				set k [LstIndx $filtfileb $wl]
				if {$k >= 0} {
					$wl selection set $k
					if {$k > 32} {
						set k [expr double($k) / double([$wl index end])]
						$wl yview moveto $k
					}
				}
				append msg "File $filtfileb Already Exists\n"
				set queri 1
			}
			set filtfilep [file rootname [file tail $partialsfile]]
			append filtfilep "_" $pnam "_vp" $evv(TEXT_EXT)
			if [file exists $filtfilep] {
				set k [LstIndx $filtfilep $wl]
				if {$k >= 0} {
					$wl selection clear 0 end
					$wl selection set $k
					if {$k > 32} {
						set k [expr double($k) / double([$wl index end])]
						$wl yview moveto $k
					}
				}
				append msg "File $filtfilep Already Exists\n"
				set queri 1
			}
			if {[info exists queri]} {
				append msg "Reuse File(s) ??"
				unset queri
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message "$msg"]
				if {$choice == "no"} {
					break
				}
			}
			switch -- $sre_settyp {
				0 {
					set typ 0		;#	flags "varipartials"
					set filtfile $filtfilep
				}
				1 {
					if {![IsNumeric $sre_q] || ($sre_q < 1.0) || ($sre_q > 9999)} {
						Inf "No Valid Q Value Entered (Range 1 - 9999)"
						continue
					}
					set typ $sre_q
					set filtfile $filtfileb
				}
				default {
					Inf "No Filter Type Chosen"
					continue
				}
			}			
			if {![SynthByVarifilt $srcfile $sre_pitch $partialsfile $valsfile $typ $srate $filtfile $sre_dbl $sre_exp $dur]} {
				DeleteAllTemporaryFiles
				continue
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Switch parameters available, depending on filter type

proc SetSBEtyp {} {
	global sre_settyp sre_ftyp sre_old_q
	switch -- $sre_settyp {
		1 {
			set sre_ftyp varibank
			.sre.2.ll2 config -text "Q value"
			.sre.2.e2 config -bd 2 -state normal
			if {[info exists sre_old_q]} {
				set sre_q $sre_old_q
			}
		}
		0 {
			if {[info exists sre_q] && ([string length $sre_q] > 0)} {
				set sre_old_q $sre_q
			}
			set sre_ftyp varipartials
			.sre.2.ll2 config -text ""
			.sre.2.e2 config -bd 0 -state disabled -disabledbackground [option get . background {}]
		}
	}
}

#---- Do the synth

proc SynthByVarifilt {srcfile pitch partialsfile valsfile typ srate filtfile dbl exp dur} {
	global evv pa CDPidrun prg_dun prg_abortd simple_program_messages last_outfile

	;#	VARIPARTIALS filter (typ 0)
	;#	Takes a list of qvalues in "valsfile" and has typ 0
	;#	VARIBANK filter (typ 1)
	;#	Takes a list of harmonics-counts in "valsfile", and a fixed Q value ("typ") in range 1 <> 9999

	set hz [MidiToHz $pitch]

	if {!$exp} {

		;#	GET ORIGINAL ENVELOPE

		set evnam $evv(DFLT_OUTNAME)
		append evnam 00 $evv(TEXT_EXT)
		set evnnam $evv(DFLT_OUTNAME)
		append evnnam 000 $evv(TEXT_EXT)
		set cmd [file join $evv(CDPROGRAM_DIR) envel]
		lappend cmd extract 2 $srcfile $evnam 5 -d0
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		Block "PLEASE WAIT:        EXTRACTING SOURCE ENVELOPE"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "$CDPidrun : Failed To Extract Source Envelope"
			UnBlock			
			return 0
   		} else {
 			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun || ![file exists $evnam]} {
			set msg "Failed To Do Extract Envelope Of Source"
			set msg [AddSimpleMessages $msg]
			Inf $msg
			UnBlock
			return 0
		}
		if [catch {open $evnam "r"} zit] {
			Inf "Cannot Open Temporary Envelope File $evnam To Normalise It"
			UnBlock			
			return 0
		}

		;#	NORMALISE IT

		set maxval 0
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			set line [split $line]
			set OK 1
			set cnt 0
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				if {$cnt == 1} {
					if {$item > $maxval} {
						set maxval $item
					}
				}
				lappend oldvals $item
				incr cnt
			}
		}
		close $zit
		UnBlock			
		if {$maxval <= 0.0} {
			Inf "Source File Is Silent : Cannot Proceed"
			DeleteAllTemporaryFiles
			return 0
		}
		set norm [expr 1.0/$maxval]
		set nuvals {}
		foreach {time val} $oldvals {
			set val [expr $val * $norm]
			set val [NotExponential $val]
			lappend nuvals $time $val
		}
		if [catch {open $evnnam "w"} zit] {
			Inf "Cannot Open Temporary File $evnam To Write Normalised Envelope"
			DeleteAllTemporaryFiles
			return 0
		}
		foreach {time val} $nuvals {
			set line [list $time $val]
			puts $zit $line
		}
		close $zit
	}

	;#	CHECK TYP

	if {![IsNumeric $typ] || ($typ < 0) || ($typ > 9999)} {
		Inf "Invalid $typ Value"
		return 0
	}
	if {$typ > 0} {
		set qvalue $typ
		set typ 1
	}

	;#	SET FILTER-DATA FILE NAME

	set len [string length $pitch]
	set n 0
	set pnam ""
	while {$n < $len} {
		set item [string index $pitch $n]
		if {[string match  $item "."]} {
			append pnam "p"
		} else {
			append pnam $item
		}
		incr n
	}

	set nyquist [expr floor(double($srate)/2.0)]

	;#	READ Q OR HARMONICS-CNT VALUES

	if [catch {open $valsfile "r"} zit] {
		Inf "Cannot Open Values File"
		return 0
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
		set OK 1
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {![IsNumeric $item]} {
				Inf "Non-Numeric Value ($item) In File $valsfile"
				set OK 0
				break
			}
			switch -- $typ {
				0 {
					if {($item < 1.0) || ($item > 9999.0)} {
						Inf "Invalid Q Value ($item) In File $valsfile : Range 1 - 9999"
						set OK 0
						break
					}
				}
				1 {
					if {![regexp {^[0-9]+$} $item] || ($item < 1.0) || ($item > 200.0)} {
						Inf "Invalid Harmonics Count ($item) In File $valsfile : Needs Integer In Range 1 - 200"
						set OK 0
						break
					}
					if {($hz * $item) >=  $nyquist} {
						Inf "Harmonics Count ($item) In File $valsfile Too High For Given Pitch"
						set OK 0
						break
					}
				}
			}
			lappend vals $item
		}
		if {!$OK} {
			break
		}
	}
	close $zit
	if {!$OK} {
		return 0
	}
	if {![info exists vals]} {
		Inf "No Data Found In File $valsfile"
		return 0
	}

	;#	READ FILTER PARTIALS VALS

	if [catch {open $partialsfile "r"} zit] {
		Inf "Cannot Open Filter Partials File"
		return 0
	}
	set cnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		set OK 1
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {![IsNumeric $item] || ($item < 1.0)} {
				Inf "Invalid Partial Value ($item) In File $partialsfile : ( >= 1.0)"
				set OK 0
				break
			}
			if {$cnt == 0} { 
				if {$item != 1.0} {
					Inf "Invalid First Partial Value ($item) In File $partialsfile : Must Be \"1\""
					set OK 0
					break
				}
			} else {
				set thishz [expr $hz * $item]
				if {$hz >= $nyquist} {
					Inf Partial Value $item Too High With Pitch Given"
					set OK 0
					break
				}
			}
			lappend partialvals $item
			incr cnt
		}
		if {!$OK} {
			break
		}
	}
	close $zit
	if {!$OK} {
		return 0
	}
	if {![info exists partialvals]} {
		Inf "No Data Found In File $partialsfile"
		return 0
	}

	set srcnam  [file rootname [file tail $srcfile]]
	set filtnam [file rootname [file tail $partialsfile]]

	;#	REMOVE DECPOINTS IN VALUES AND SYSTEMATICALLY NAME OUTPUT FILES WHILE SETTING UP FILTER-CMD LINES

	set cmdcnt 0
	foreach val $vals {				;#	varipartials  val = Q : varibank val = HARMONICS-CNT (while q is qvalue)
		if {$typ == 1} {	;#	VARIBANK
			set len [string length $qvalue]
			set n 0
			set qvnam ""
			while {$n < $len} {
				set item [string index $qvalue $n]
				if {[string match  $item "."]} {
					append qvnam "p"
				} else {
					append qvnam $item
				}
				incr n
			}
		}
		set len [string length $val]
		set n 0
		set valnam ""
		while {$n < $len} {
			set item [string index $val $n]
			if {[string match  $item "."]} {
				append valnam "p"
			} else {
				append valnam $item
			}
			incr n
		}
		set ofnam $srcnam
		switch -- $typ {
			0 {
				append ofnam "_" $pnam "_" $filtnam "_q" $valnam
			}
			1 {
				append ofnam "_" $pnam "_" $filtnam "_q" $qvnam "_h" $valnam 
			}
		}
		if {$dbl} { 
			append ofnam "_dbl" 
		}
		if {$exp} {
			append ofnam "_exp"
		}
		append ofnam $evv(SNDFILE_EXT)
		set tempofnam $evv(DFLT_OUTNAME)
		append tempofnam $cmdcnt $evv(SNDFILE_EXT)
		set tempefnam $evv(MACH_OUTFNAME)
		append tempefnam $cmdcnt $evv(SNDFILE_EXT)
		set cmd [file join $evv(CDPROGRAM_DIR) filter]
		switch -- $typ {
			0 {
				lappend cmd varibank2 2 $srcfile $tempofnam $filtfile $val 1 -t0 -n
			}
			1 {
				lappend cmd varibank 2 $srcfile $tempofnam $filtfile $qvalue 1 -t0 -h$val -r0 -n
			}
		}
		if {$dbl} {
			lappend cmd -d
		}
		lappend thisbatch $cmd
		lappend tempofnams $tempofnam
		lappend tempefnams $tempefnam
		lappend ofnams $ofnam
		incr cmdcnt
	}

	;#	CHECK IF ANY OF OUTPUT SNDFILES ALREADY EXIST

	foreach ofnam $ofnams {
		if [file exists $ofnam] {
			Inf "File $ofnam Exists : Cannot Proceed"
			return 0
		}
	}
	;#	CREATE FILTER-DATA AND FILE

	if {![file exists $filtfile]} {
		catch {unset filtlines}
		switch -- $typ {
			0 {					;#	VARIFILT
				set line [list 0 $pitch 1]
				lappend filtlines $line
				set line [lreplace $line 0 0 10000]
				lappend filtlines $line
				set line "\#"
				lappend filtlines $line
				set line [list 0]
				foreach partial $partialvals {
					lappend line $partial 1
				}
				lappend filtlines $line
				set line [lreplace $line 0 0 10000]
				lappend filtlines $line
			}
			1 {					;#	VARIBANK
				set line [list 0 $pitch 1]
				foreach partial [lrange $partialvals 1 end] {
					set thishz [expr $hz * $partial]
					set thispitch [HzToMidi $thishz]
					lappend line $thispitch 1
				}
				lappend filtlines $line
				set line [lreplace $line 0 0 10000]
				lappend filtlines $line
			}
		}
		if [catch {open $filtfile "w"} zit] {
			Inf "CANNOT OPEN FILE $filtfnam TO MAKE FILTER CONTROL FILE"
			return 0
		}
		foreach line $filtlines {
			puts $zit $line 	
		}
		close $zit
		FileToWkspace $filtfile 0 0 0 0 1
	}

	;#	DO THE FILTERING ETC

	Block "PLEASE WAIT:        FILTERING"
	set cmdcnt 0
	set OK 1
	foreach cmd $thisbatch {
		if {$typ == 0} {
			set fmsg "Q [lindex $cmd 6]"
		} else {
			set fmsg " [string range [lindex $cmd 9] 2 end] HARMONICS"
		}

		set tempofnam [lindex $tempofnams $cmdcnt]
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		wm title .blocker "PLEASE WAIT:        FILTERING WITH $fmsg"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "$CDPidrun : Failed To Filter With $fmsg"
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
			set msg "Failed To Do Filtering With $fmsg"
			set msg [AddSimpleMessages $msg]
			Inf $msg
			set OK 0
			break
		}
		if {![file exists $tempofnam]} {
			set msg "Failed To Produce Outfile With $fmsg"
			set msg [AddSimpleMessages $msg]
			Inf $msg
			set OK 0
			break
		}
		if {$cmdcnt == 0} {				;#	FIND DURATION OF FIRST FILTERED FILE, TO USE AS CURTAIL-PARAM FOR LATER FILES
			if {$exp} {
				if {[DoParse $tempofnam 0 0 0] <= 0} {
					set OK 0
					break
				}
				set envdur $pa($tempofnam,$evv(DUR))
				set envdur [expr $envdur - 0.01]
				PurgeArray $tempofnam
			} else {
				set envdur [expr $dur - 0.01]
			}
		}
		incr cmdcnt
	}
	if {!$OK} {
		UnBlock
		return 0
	}
	wm title .blocker "PLEASE WAIT:        ENVELOPING OUTPUTS"
	catch {unset realofnams}
	set cmdcnt 0
	foreach tempofnam $tempofnams tempefnam $tempefnams {
		set cmd [file join $evv(CDPROGRAM_DIR) envel]
		if {$exp} {
			lappend cmd curtail 4 $tempofnam $tempefnam 0 $envdur -t0
		} else {
			lappend cmd impose 3 $tempofnam $evnnam $tempefnam 
		}
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		wm title .blocker "PLEASE WAIT:        ENVELOPING FILE WITH $fmsg"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "$CDPidrun : Failed To Envelope File With $fmsg"
			set OK 0
			break
   		} else {
 			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun || ![file exists $tempefnam]} {
			set msg "Failed To Produce Enveloped Outfile With $fmsg"
			set msg [AddSimpleMessages $msg]
			Inf $msg
			set OK 0
			break
		}
		lappend realefnams $tempefnam
		incr cmdcnt
	}
	wm title .blocker "PLEASE WAIT:        RE-ENVELOPING OUTPUTS"
	catch {unset realofnams}
	set cmdcnt 0
	foreach tempofnam $realefnams {
		set ofnam [lindex $ofnams $cmdcnt]
		if {($cmdcnt == 0) && $exp} {
			if [catch {file rename $tempofnam $ofnam} zit] {
				Inf "Failed To Rename Temporary File $tempofnam To $ofnam"
				set OK 0
				break
			}
		} else {
			set cmd [file join $evv(CDPROGRAM_DIR) envel]
			if {$exp} {
				lappend cmd dovetail 2 $tempofnam $ofnam .01 0 -t0
			} else {
				lappend cmd curtail 4 $tempofnam $ofnam $envdur $dur -t0
			}
			set CDPidrun 0
			set prg_dun 0
			set prg_abortd 0
			catch {unset simple_program_messages}
			wm title .blocker "PLEASE WAIT:        RE-ENVELOPING FILE $ofnam"
			if [catch {open "|$cmd"} CDPidrun] {
				Inf "$CDPidrun : Failed To Re-enveloping File $ofnam"
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
				set msg "Failed To Do Re-enveloping For File $ofnam"
				set msg [AddSimpleMessages $msg]
				Inf $msg
				set OK 0
				break
			}
			if {![file exists $ofnam]} {
				set msg "Failed To Produce Re-enveloped Outfile $ofnam"
				set msg [AddSimpleMessages $msg]
				Inf $msg
				set OK 0
				break
			}
		}
		lappend realofnams $ofnam
		incr cmdcnt
	}
	if {!$OK} {
		UnBlock
		if [info exists realofnams] { 
			foreach ofnam $realofnams {
				if [file exists $ofnam] {
					catch {file delete $ofnam}
				}
			}
		}
		return 0
	}
	set ofnams [ReverseList $realofnams]
	foreach ofnam $ofnams {
		FileToWkspace $ofnam 0 0 0 0 1
		lappend zx $ofnam
	}
	if {[info exists zx]} {
		set last_outfile $zx
	}
	Inf "Output Files Are On The Workspace"
	UnBlock
	return 1
}

#---- Help for Synth sequences

proc SynthSetsHelp {} {
	set msg "~~~ GENERATE SETS OF RELATED SOUNDS ~~~\n"
	append msg "\n"
	append msg "Generate groups of related sounds by gradually modifying a source sound,\n"
	append msg "or applying progressively changing values to a set of sounds.\n"
	append msg "\n"
	Inf $msg
}

#---- Help for Synth sequences

proc SynthSetsHelp1 {} {
	set msg "~~~ GENERATE SOUND SETS ~~~\n"
	append msg "\n"
	append msg "Generate groups of related sounds by gradually modifying a source sound,\n"
	append msg "\n"
	append msg "~~~ GENERATE SPECTRA BY FILTERING ~~~\n"
	append msg "\n"
	append msg "Generate groups of related sounds by filtering a source. Needs 3 files.\n"
	append msg "(1) A soundfile to filter (usually a noisy source).\n"
	append msg "(2) A textfile with a list of partials (the first entry must be \"1\")\n"
	append msg "(3) A textfile with a list of increasing \"Q\" values (for varipartial filters)\n"
	append msg "        or \"harmonics cnt\" values (for varibank filters).\n"
	append msg "\n"
	append msg "LOW PITCHES can cope with lower Q values and without double filtering.\n"
	append msg "HIGH PITCHES need Q values at 12 or more.\n"
	append msg "\n"
	append msg "~~~ MODIFY SOUNDS BY FILTERING ~~~\n"
	append msg "\n"
	append msg "Generate related sounds by filtering source, then interpolating with original. Needs 2 files.\n"
	append msg "(1) A soundfile to filter.\n"
	append msg "(2) A textfile of increasing interpolation values.\n"
	append msg "\n"
	append msg "~~~ GENERATE SOUNDS BY INTERPOLATION ~~~\n"
	append msg "\n"
	append msg "Generate related sounds by interpolating between 2 existing sounds. Needs 3 files.\n"
	append msg "(1-2) Two soundfiles to interpolate between.\n"
	append msg "(3) A textfile of increasing interpolation values.\n"
	append msg "\n"
	append msg "~~~ MODIFY SOUND BY STACKING ~~~\n"
	append msg "\n"
	append msg "Generate related sounds by stacking source sound. Needs 3 files.\n"
	append msg "(1) A soundfile to stack.\n"
	append msg "(2) A textfile listing transpositions in semitones.\n"
	append msg "(3) A textfile listing increasing stack \"lean\" values (between 0.01 and 100).\n"
	append msg "\n"
	append msg "~~~ MODIFY SOUND BY REVERB ~~~\n"
	append msg "\n"
	append msg "Generate related sounds by reverbing source sound. Needs 2 files.\n"
	append msg "(1) A soundfile to reverb.\n"
	append msg "(2) A textfile listing of increasing echo-counts (between 2 and 1000).\n"
	append msg "\n"
	append msg "~~~ MODIFY SOUND BY DISTORTION ~~~\n"
	append msg "\n"
	append msg "Generate related sounds by interpolating to a distorted version. Needs 2 files.\n"
	append msg "(1) A soundfile to distort.\n"
	append msg "(2) A textfile listing of increasing interpolation values (Range >0 to < 1).\n"
	append msg "        OR (for interpolation distortion) a list of cyclecnts (Range 2 - 12)\n"
	append msg "\n"
	append msg "~~~ MODIFY SOUND BY TREMOLO/VIBRATO/ACCEL ~~~\n"
	append msg "\n"
	append msg "Generate related sounds. Needs 2 files.\n"
	append msg "(1) A soundfile to modify.\n"
	append msg "(2) For TREMOLO: A textfile listing of increasing depth & peak-narrowing.\n"
	append msg "                Values between 0 and < 1 refer to tremolo depth (D).\n"
	append msg "                Values between 1 and 100 refer to peak narrowing (PN).\n"
	append msg "                For first outputs, D Values are applied, using the first PN value.\n"
	append msg "                FOr subsequent outputs, PN values are applied at depth 1.\n"
	append msg "        For VIBRATO: A textfile listing increasing semitone-widths.\n"
	append msg "        For ACCEL:   A textfile listing increasing accelerations.\n"
	append msg "\n"
	append msg "~~~ MODIFY SOUND BY PITCH ~~~\n"
	append msg "\n"
	append msg "Generate new sounds by pitchshifting. Needs 2 files.\n"
	append msg "(1) A soundfile to distort.\n"
	append msg "(2) A textfile of increasing semitone transpositions (Range >-24 to +24).\n"
	append msg "\n"
	append msg "~~~ MODIFY SOUND BY TIMESTRETCH OR TIMESHRINK ~~~\n"
	append msg "\n"
	append msg "Create set of time-stretched or shrunk files. Needs 2 files.\n"
	append msg "(1) A soundfile.\n"
	append msg "(2) A textfile of increasing or decreasing stretch/shrink values (>0 and not 1.0).\n"
	append msg "\n"
	append msg "~~~ MODIFY SOUND BY END TRIM ~~~\n"
	append msg "\n"
	append msg "Create set of end-trimmed sounds. Needs a soundfile.\n"
	append msg "\n"
	Inf $msg
}

#---- Help for Synth sequences

proc SynthSetsHelp2 {} {
	set msg "~~~ PROGRESSIVELY MODIFY SOUND SETS ~~~\n"
	append msg "\n"
	append msg "\n"
	append msg "Apply progressively changing transformations to a set of sounds.\n"
	append msg "\n"
	append msg "\n"
	append msg "~~~ MODIFY SOUNDSET BY PITCH ~~~\n"
	append msg "\n"
	append msg "Pitchshift a Set of sounds by increasing amounts. Needs 2+ sndfiles.\n"
	append msg "Last sound shifted max. Others shifted by intermediate amount.\n"
	append msg "\n"
	append msg "\n"
	append msg "~~~ MODIFY SOUND SET BY END TRIM ~~~\n"
	append msg "\n"
	append msg "Trim off ends of a set of sounds by increasing amounts. Needs 2+ sndfiles.\n"
	append msg "Last sound trimmed max. Others trimmed by intermediate amount.\n"
	append msg "\n"
	Inf $msg
}
#---- Help for Synth sequences

proc SynthSetsHelp3 {} {
	set msg "~~~ IDENTICALLY MODIFY SOUND SETS ~~~\n"
	append msg "\n"
	append msg "\n"
	append msg "Apply the SAME transformation to each sound in a set of sounds.\n"
	append msg "\n"
	append msg "\n"
	append msg "~~~ CUT AND NORMALISE ~~~\n"
	append msg "\n"
	append msg "Trim off end of sound but retain max level of original.\n"
	append msg "\n"
	Inf $msg
}

#--- Filter src, then interp betwen src and filtered version

proc ModifySpectraByFilterAndInterp {} {
	global chlist evv pa pr_mre mre_ftyp mre_settyp mre_lo mre_hi
	global CDPmaxId maxsamp_line done_maxsamp

	set startmsg "REQUIRES A SOUNDFILE, FOLLOWED BY A TEXTILE OF INTERPOLATION VALUES.\n"

	if {![info exists chlist] || ([llength $chlist] !=2)} {
		Inf $startmsg
		return
	}
	set fnam [lindex $chlist 0]
	if {$pa($fnam,$evv(FTYP)) == $evv(SNDFILE)} {
		set srcfile $fnam
		set srate $pa($fnam,$evv(SRATE))
		set nyquist [expr floor(double($srate)/2.0)]
		catch {unset CDPmaxId}
		catch {unset maxsamp_line}
		set done_maxsamp 0
		set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
		lappend cmd $fnam
		lappend cmd 1		;#	1 flag added to FORCE read of maxsample
		if [catch {open "|$cmd"} CDPmaxId] {
			Inf "Finding Maximum Level Of $fnam: Process Failed"
			return
	   	} else {
	   		fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
		}
	 	vwait done_maxsamp
		if {[info exists maxsamp_line]} {
			set maxsamp [lindex $maxsamp_line 0]
		} else {
			Inf "Failed To Find Maximum Level Of File $fnam"
			return
		}
		if {$maxsamp <= 0.0} {
			Inf "File $fnam has zero level"
			return
		}
	} else {
		Inf $startmsg
		return
	}
	set fnam [lindex $chlist 1]
	if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)) || ![IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
		Inf $startmsg
		return
	} elseif {($pa($fnam,$evv(MINNUM)) <= 0.0) || ($pa($fnam,$evv(MAXNUM)) >= 1.0)} {
		Inf $startmsg
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File $fnam"
		return
	}
	set cnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		set OK 1
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {![IsNumeric $item] || ($item <= 0.0) || ($item >= 1.0)} {
				Inf "Invalid Interpolation Value ($item) In File $fnam : (Range > 0 to < 1)"
				set OK 0
				break
			}
			if {($cnt > 0) && ($item <= $lastval)} {
				Inf "Values Do Not Increase Between $lastval And $item In File $fnam"
				set OK 0
				break
			}
			set lastval $item
			lappend interpvals $item
			incr cnt
		}
	}
	close $zit
	if {!$OK} {
		return
	}
	set interpfil $fnam
	set f .mre
	if [Dlg_Create $f "CREATE FILES BY FILTER + INTERP" "set pr_mre 0" -borderwidth $evv(BBDR)] {
		frame $f.0
		button $f.0.ab -text Abandon -width 10 -command "set pr_mre 0"
		button $f.0.ok -text Generate -width 10 -command "set pr_mre 1"
		pack $f.0.ab -side right
		pack $f.0.ok -side left
		pack $f.0 -side top -pady 2 -fill x -expand true
		frame $f.1
		label $f.1.ll -text "lower frq" 
		entry $f.1.e -textvariable mre_lo
		pack $f.1.e $f.1.ll -side left -padx 2
		pack $f.1 -side top -pady 2 -fill x -expand true
		frame $f.2
		label $f.2.ll -text "upper frq" 
		entry $f.2.e -textvariable mre_hi
		pack $f.2.e $f.2.ll -side left -padx 2
		pack $f.2 -side top -pady 2 -fill x -expand true
		frame $f.3
		label $f.3.ll -text "Filter Type"
		entry $f.3.e -textvariable mre_ftyp -width 16 -state readonly
		pack $f.3.e $f.3.ll -side left -padx 2
		pack $f.3 -side top -pady 2 -fill x -expand true
		frame $f.4
		radiobutton $f.4.vb -variable mre_settyp -text "low pass"  -value 0 -command SetFLHType
		radiobutton $f.4.vp -variable mre_settyp -text "high pass" -value 1 -command SetFLHType
		pack $f.4.vb $f.4.vp -side left 
		pack $f.4 -side top -pady 2 -fill x -expand true
		wm resizable $f 1 1
		bind $f.1.e <Down> "focus $f.2.e"
		bind $f.2.e <Down> "focus $f.1.e"
		bind $f.1.e <Up> "focus $f.2.e"
		bind $f.2.e <Up> "focus $f.1.e"
		bind $f <Return> {set pr_mre 1}
		bind $f <Escape> {set pr_mre 0}
	}
	set mre_settyp -1
	SetFLHType
	set finished 0
	set pr_mre 0
	raise $f
	My_Grab 0 $f pr_mre $f.1.e
	while {!$finished} {
		tkwait variable pr_mre
		if {$pr_mre} {
			if {![IsNumeric $mre_lo] || ($mre_lo < 10.0) || ($mre_lo >= $nyquist)} {
				Inf "No Valid Lower Frq Value Entered (Range 10 - $nyquist)"
				continue
			}
			if {![IsNumeric $mre_hi] || ($mre_hi < 10.0) || ($mre_hi >= $nyquist)} {
				Inf "No Valid Higher Frq Value Entered (range 10 - $nyquist)"
				continue
			}
			if {$mre_hi <= $mre_lo} {
				Inf "Lower And Higher Frq Values Incompatible"
				continue
			}
			if {$mre_settyp < 0} {
				Inf "No Filter Type Set"
				continue
			}
			if {![SynthByFiltInterp $srcfile $mre_lo $mre_hi $mre_settyp $interpvals $interpfil $maxsamp]} {
				DeleteAllTemporaryFiles
				continue
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc SetFLHType {} {
	global mre_settyp mre_ftyp
	switch -- $mre_settyp {
		0 {
			set mre_ftyp "low pass"
		}
		1 {
			set mre_ftyp "high pass"
		}
		default {
			set mre_ftyp ""
		}
	}
}

#---- do the filter and interp

proc SynthByFiltInterp {srcfile lofval hifval typ vals interpfile level} {
	global evv pa CDPidrun prg_dun prg_abortd simple_program_messages 
	global CDPmaxId maxsamp_line done_maxsamp last_outfile

	set tempofnam0 $evv(DFLT_OUTNAME)
	append tempofnam0 0 $evv(SNDFILE_EXT)
	set tempofnam1 $evv(DFLT_OUTNAME)
	append tempofnam1 1 $evv(SNDFILE_EXT)
	set tempofnam2 $evv(MACH_OUTFNAME)
	append tempofnam2 $evv(SNDFILE_EXT)
	
	set srcnam  [file rootname [file tail $srcfile]]
	set itpnam  [file rootname [file tail $interpfile]]

	;#	REMOVE DECPOINTS IN VALUES AND SYSTEMATICALLY NAME INTERPOLATED OUTPUT FILES

	set len [string length $lofval]
	set n 0
	set lonam ""
	while {$n < $len} {
		set item [string index $lofval $n]
		if {[string match  $item "."]} {
			append lonam "p"
		} else {
			append lonam $item
		}
		incr n
	}
	set len [string length $hifval]
	set n 0
	set hinam ""
	while {$n < $len} {
		set item [string index $hifval $n]
		if {[string match  $item "."]} {
			append hinam "p"
		} else {
			append hinam $item
		}
		incr n
	}
	set itpcnt 1
	foreach val $vals {				;#	interpolation values
		set len [string length $val]
		set n 0
		set valnam ""
		while {$n < $len} {
			set item [string index $val $n]
			if {[string match  $item "."]} {
				append valnam "p"
			} else {
				append valnam $item
			}
			incr n
		}
		set ofnam $srcnam
		switch -- $typ {
			0 {
				append ofnam "_fi_" $lonam "_" $hinam "_" $itpnam "_" $itpcnt
			}
			1 {
				append ofnam "_fi_" $hinam "_" $lonam "_" $itpnam "_" $itpcnt
			}
		}
		append ofnam $evv(SNDFILE_EXT)
		lappend ofnams $ofnam
		incr itpcnt
	}

	;#	SET UP NAME OF FILTERED FILE

	set ofnam $srcnam
	set $valnam 1
	switch -- $typ {
		0 {
			append ofnam "_fi_" $lonam "_" $hinam
		}
		1 {
			append ofnam "_fi_" $hinam "_" $lonam
		}
	}
	append ofnam $evv(SNDFILE_EXT)
	lappend ofnams $ofnam
	foreach ofnam $ofnams {
		if {[file exists $ofnam]} {
			Inf "File $ofnam Already Exists : Cannot Proceed"
			return 0
		}
	}
	set lastofnam [lindex $ofnams end]
	set ofnams [lreplace $ofnams end end]

	;#	DO FILTERING

	set cmd [file join $evv(CDPROGRAM_DIR) filter]
	switch -- $typ {
		0 {
			lappend cmd lohi 1 $srcfile $tempofnam0 -96 $lofval $hifval -t0 -s.9
		}
		1 {
			lappend cmd lohi 1 $srcfile $tempofnam0 -96 $hifval $lofval -t0 -s.9
		}
	}
	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	catch {unset simple_program_messages}
	Block "PLEASE WAIT:        FILTERING THE SOURCE"
	if [catch {open "|$cmd"} CDPidrun] {
		Inf "$CDPidrun : Failed To Run Filtering"
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
		set msg "Failed To Filter The Source"
		set msg [AddSimpleMessages $msg]
		Inf $msg
		UnBlock
		return 0
	}
	if {![file exists $tempofnam0]} {
		set msg "Failed To Produce Filtered Sourcefile"
		set msg [AddSimpleMessages $msg]
		Inf $msg
		UnBlock
		return 0
	}

	;#	FIND LEVEL OF FILTERED SOURCE

	catch {unset CDPmaxId}
	catch {unset maxsamp_line}
	set done_maxsamp 0
	set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
	lappend cmd $tempofnam0
	lappend cmd 1		;#	1 flag added to FORCE read of maxsample
	if [catch {open "|$cmd"} CDPmaxId] {
		Inf "Finding Maximum Level Of $tempofnam0: Process Failed"
		UnBlock
		return
	} else {
	   	fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
	}
	vwait done_maxsamp
	if {[info exists maxsamp_line]} {
		set maxsamp [lindex $maxsamp_line 0]
	} else {
		Inf "Failed To Find Maximum Level Of File $tempofnam0"
		UnBlock
		return
	}
	if {$maxsamp  <= 0.0} {
		Inf "File $tempofnam0 has zero level"
		UnBlock
		return
	}
	;#	ADJUST LEVEL OF FILTERED SOURCE IF NESS

	if {[Flteq $maxsamp $level]} {
		if [catch {file $rename $tempofnam0 $tempofnam1} zit] {
			Inf "Failed To Rename Temporary File"
			UnBlock
			return
		}
	} else {
		set cmd [file join $evv(CDPROGRAM_DIR) modify]
		lappend cmd loudness 4 $tempofnam0 $tempofnam1 -l$level
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		wm title .blocker "PLEASE WAIT:        NORMALISING FILTERED SOURCE"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "$CDPidrun : Failed To Run Normalisation Of Filtered Source"
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
			set msg "Failed To Normalise The Filtered Source"
			set msg [AddSimpleMessages $msg]
			Inf $msg
			UnBlock
			return 0
		}
		if {![file exists $tempofnam1]} {
			set msg "Failed To Produce Normalised Filtered Source"
			set msg [AddSimpleMessages $msg]
			Inf $msg
			UnBlock
			return 0
		}
	}

	;#	DO THE INTERPOLATION

	set cmd [file join $evv(CDPROGRAM_DIR) submix]
	lappend cmd inbetween 2 $srcfile $tempofnam1 $tempofnam2 $interpfile
	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	catch {unset simple_program_messages}
	wm title .blocker "PLEASE WAIT:        INTERPOLATING FILES"
	if [catch {open "|$cmd"} CDPidrun] {
		Inf "$CDPidrun : Failed To Run Interpolation"
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
		set msg "Failed To Interpolate Src With Filtered Src"
		set msg [AddSimpleMessages $msg]
		Inf $msg
		UnBlock
		return 0
	}
	set n 1
	foreach val $vals {
		set tempofnam [file rootname $tempofnam2]
		if {$n < 10} {
			append tempofnam 00$n
		} elseif {$n < 100} {
			append tempofnam 0$n
		} else {
			append tempofnam $n
		}
		append tempofnam $evv(SNDFILE_EXT)
		if {![file exists $tempofnam]} {
			Inf "Not All Interpolation Files Exist"
			UnBlock
			return 0
		}
		lappend tempofnams $tempofnam
		incr n
	}

	;#	RENAME THE FILTERED FILE

	if [catch {file rename $tempofnam1 $lastofnam} zit] {
		Inf "Cannot Rename The Filtered File"
		UnBlock
		return 0
	}

	;#	NORMALISE AND RENAME THE OUTPUT FILES

	foreach tempofnam $tempofnams ofnam $ofnams {
		catch {unset CDPmaxId}
		catch {unset maxsamp_line}
		set done_maxsamp 0
		set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
		lappend cmd $tempofnam
		lappend cmd 1		;#	1 flag added to FORCE read of maxsample
		if [catch {open "|$cmd"} CDPmaxId] {
			Inf "Finding Maximum Level Of $tempofnam: Process Failed"
			continue
		} else {
	   		fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
		}
		vwait done_maxsamp
		if {[info exists maxsamp_line]} {
			set maxsamp [lindex $maxsamp_line 0]
		} else {
			Inf "Failed To Find Maximum Level Of File $tempofnam"
			continue
		}
		if {$maxsamp <= 0.0} {
			Inf "File $tempofnam has level zero"
			continue
		}
		if {[Flteq $maxsamp $level]} {
			if [catch {file $rename $tempofnam $ofnam} zit] {
				Inf "Failed To Rename Temporary File $tempofnam To $ofnam"
				continue
			}
		} else {
			set cmd [file join $evv(CDPROGRAM_DIR) modify]
			lappend cmd loudness 4 $tempofnam $ofnam -l$level
			set CDPidrun 0
			set prg_dun 0
			set prg_abortd 0
			catch {unset simple_program_messages}
			wm title .blocker "PLEASE WAIT:        NORMALISING OUTPUT $ofnam"
			if [catch {open "|$cmd"} CDPidrun] {
				Inf "$CDPidrun : Failed To Run Normalisation Output $ofnam"
				continue
   			} else {
 				fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
			}
			vwait prg_dun
			if {$prg_abortd} {
				set prg_dun 0
			}
			if {!$prg_dun} {
				set msg "Failed To Normalise Output $outfnam"
				set msg [AddSimpleMessages $msg]
				Inf $msg
				continue
			}
			if {![file exists $ofnam]} {
				set msg "Failed To Produce Normalised Output $ofnam"
				set msg [AddSimpleMessages $msg]
				Inf $msg
				continue
			}
		}
	}
	lappend ofnams $lastofnam
	set ofnams [ReverseList $ofnams]
	foreach ofnam $ofnams {
		if {[file exists $ofnam]} {
			FileToWkspace $ofnam 0 0 0 0 1
			lappend zx $ofnam
		}
	}
	if {[info exists zx]} {
		set last_outfile $zx
	}
	UnBlock
	Inf "Files Are On The Workspace"
	return 1
}

#--- interp betwen two srcs

proc GenerateSpectraByInterpolation {} {
	global chlist evv pa pr_gsi gsi_offset

	set startmsg "Requires Two Soundfiles, Followed By A Textile Of Interpolation Values.\n"

	if {![info exists chlist] || ([llength $chlist] !=3)} {
		Inf $startmsg
		return
	}
	set fnam [lindex $chlist 0]
	if {$pa($fnam,$evv(FTYP)) == $evv(SNDFILE)} {
		set srcfile1 $fnam
		set srate $pa($fnam,$evv(SRATE))
		set chans $pa($fnam,$evv(CHANS))
		set dur1 $pa($fnam,$evv(DUR))
	} else {
		Inf $startmsg
		return
	}
	set fnam [lindex $chlist 1]
	if {$pa($fnam,$evv(FTYP)) == $evv(SNDFILE)} {
		set srcfile2 $fnam
		if {$pa($fnam,$evv(SRATE)) != $srate} {
			Inf "Sounds Have Incompatible Srates"
			return
		}
		if {$pa($fnam,$evv(CHANS)) != $chans} {
			Inf "Sounds Have Incompatible Channel Count"
			return
		}
		set dur2 $pa($fnam,$evv(DUR))
	} else {
		Inf $startmsg
		return
	}
	set fnam [lindex $chlist 2]
	if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)) || ![IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
		Inf $startmsg
		return
	} elseif {($pa($fnam,$evv(MINNUM)) <= 0.0) || ($pa($fnam,$evv(MAXNUM)) >= 1.0)} {
		Inf $startmsg
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File $fnam"
		return
	}
	set cnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		set OK 1
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {![IsNumeric $item] || ($item <= 0.0) || ($item >= 1.0)} {
				Inf "Invalid Interpolation Value ($item) In File $fnam : (Range > 0 to < 1)"
				set OK 0
				break
			}
			if {($cnt > 0) && ($item <= $lastval)} {
				Inf "Values Do Not Increase Between $lastval And $item In File $fnam"
				set OK 0
				break
			}
			set lastval $item
			lappend interpvals $item
			incr cnt
		}
		if {!$OK} {
			break
		}
	}
	close $zit
	if {!$OK} {
		return
	}
	set interpfile $fnam

	set f .gsi
	if [Dlg_Create $f "CREATE NEW FILES BY INTERPOLATION" "set pr_gsi 0" -borderwidth $evv(BBDR)] {
		frame $f.0
		button $f.0.ab -text Abandon -width 10 -command "set pr_gsi 0"
		button $f.0.ok -text Generate -width 10 -command "set pr_gsi 1"
		pack $f.0.ab -side right
		pack $f.0.ok -side left
		pack $f.0 -side top -pady 2 -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Offset of 1st sound"
		entry $f.1.e -textvariable gsi_offset -width 8
		pack $f.1.e $f.1.ll -side left
		pack $f.1 -side top -pady 2 -fill x -expand true
		wm resizable $f 1 1
		bind $f <Return> {set pr_gsi 1}
		bind $f <Escape> {set pr_gsi 0}
	}
	set finished 0
	set pr_gsi 0
	raise $f
	My_Grab 0 $f pr_gsi
	while {!$finished} {
		tkwait variable pr_gsi
		if {$pr_gsi} {
			if {[string length $gsi_offset] <= 0} {
				set gsi_offset 0
			}
			if {$gsi_offset > 0} {
				if {![GenerateOffsetSrcfile $srcfile1 $gsi_offset]} {
					continue
				}
			} elseif {$gsi_offset < 0} {
				if {![GenerateOffsetSrcfile $srcfile2 [expr -$gsi_offset]]} {
					continue
				}
			}
			if {![SynthByInterp $srcfile1 $srcfile2 $gsi_offset $interpvals $interpfile]} {
				DeleteAllTemporaryFiles
				continue
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc GenerateOffsetSrcfile {srcfile offset} {
	global evv CDPidrun prg_dun prg_abortd simple_program_messages
	set tempofnam $evv(MACH_OUTFNAME)
	append tempofnam 0 $evv(SNDFILE_EXT)

	set cmd [file join $evv(CDPROGRAM_DIR) prefix]
	lappend cmd silence $srcfile $tempofnam $offset
	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	catch {unset simple_program_messages}
	Block "PLEASE WAIT:        OFFSETTING FILE $srcfile"
	if [catch {open "|$cmd"} CDPidrun] {
		Inf "$CDPidrun : Failed To Run Offsetting"
		UnBlock
		return 0
   	} else {
 		fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
	}
	vwait prg_dun
	if {$prg_abortd} {
		set prg_dun 0
	}
	if {!$prg_dun || ![file exists $tempofnam]} {
		set msg "Failed To Offset File $srcfile"
		set msg [AddSimpleMessages $msg]
		Inf $msg
		UnBlock
		return 0
	}
	UnBlock
	return 1
}


#---- do the interp

proc SynthByInterp {srcfile1 srcfile2 offset vals interpfile} {
	global evv pa CDPidrun prg_dun prg_abortd simple_program_messages last_outfile

	set tempofnam1 $evv(DFLT_OUTNAME)
	append tempofnam1 $evv(SNDFILE_EXT)

	set offsetfnam $evv(MACH_OUTFNAME)
	append offsetfnam 0 $evv(SNDFILE_EXT)

	set itpnam [file rootname [file tail $interpfile]]

	;#	REMOVE DECPOINTS IN VALUES AND SYSTEMATICALLY NAME OUTPUT FILES

	set srcnam1 [file rootname [file tail $srcfile1]]
	set srcnam2 [file rootname [file tail $srcfile2]]

	set neg 0
	if {$offset != 0.0} {
		if {$offset < 0.0} {
			set ofsnam "-"
			set offset [string range $offset 1 end]
			set neg 1
		} else {
			set ofsnam ""
		}
		set len [string length $offset]
		set n 0
		while {$n < $len} {
			set c [string index $offset $n]
			if {[string match $c "."]} {
				append ofsnam "p"
			} else {
				append ofsnam $c
			}
			incr n
		}
	}
	set basofnam $srcnam1
	append basofnam "_" $srcnam2 "_i_"
	if {$offset != 0.0} {
		append basofnam "ofset" $ofsnam "_"
	}
	append basofnam $itpnam "_"
	set itpcnt 1
	foreach val $vals {				;#	interpolation values
		set ofnam $basofnam
		append ofnam $itpcnt
		append ofnam $evv(SNDFILE_EXT)
		lappend ofnams $ofnam
		incr itpcnt
	}
	foreach ofnam $ofnams {
		if {[file exists $ofnam]} {
			Inf "File $ofnam Already Exists : Cannot Proceed"
			return 0
		}
	}

	if {$offset != 0.0} {
		if {$neg} {
			set srcfile2 $offsetfnam
		} else {
			set srcfile1 $offsetfnam
		}
	}
	set cmd [file join $evv(CDPROGRAM_DIR) submix]
	lappend cmd inbetween 2 $srcfile1 $srcfile2 $tempofnam1 $interpfile
	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	catch {unset simple_program_messages}
	Block "PLEASE WAIT:        INTERPOLATING FILES"
	if [catch {open "|$cmd"} CDPidrun] {
		Inf "$CDPidrun : Failed To Run Interpolation"
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
		set msg "Failed To Interpolate Files"
		set msg [AddSimpleMessages $msg]
		Inf $msg
		UnBlock
		return 0
	}
	set n 1
	foreach val $vals {
		set tempofnam [file rootname $tempofnam1]
		if {$n < 10} {
			append tempofnam 00$n
		} elseif {$n < 100} {
			append tempofnam 0$n
		} else {
			append tempofnam $n
		}
		append tempofnam $evv(SNDFILE_EXT)
		if {![file exists $tempofnam]} {
			Inf "Not All Interpolation Files Exist"
			UnBlock
			return 0
		}
		lappend tempofnams $tempofnam
		incr n
	}
	foreach tempofnam $tempofnams ofnam $ofnams {
		if [catch {file rename $tempofnam $ofnam} zit] {
			Inf "Failed To Rename The  Interpolated File $ofnam"
			continue
		}
	}
	set ofnams [ReverseList $ofnams]
	foreach ofnam $ofnams {
		if {[file exists $ofnam]} {
			FileToWkspace $ofnam 0 0 0 0 1
			lappend zx $ofnam
		}
	}
	if {[info exists zx]} {
		set last_outfile $zx
	}
	UnBlock
	Inf "Files Are On The Workspace"
	return 1
}

#---- STACK
#---- Use stackfile, and lean values to generate mod of sound

proc GenerateSpectraByStacking {} {

	global chlist evv pa sn prm sn_prm1 pr_cfs cfs_last cfs_lastval cfs_atk

	set sn_prm1 0

	set startmsg "REQUIRES A SOUNDFILES, A TEXTFILE OF STACK-TRANSPOSITIONS, AND A TEXTFILE OF \"LEAN\" VALUES.\n"

	if {![info exists chlist] || ([llength $chlist] !=3)} {
		Inf $startmsg
		return
	}
	set fnam [lindex $chlist 0]
	if {$pa($fnam,$evv(FTYP)) == $evv(SNDFILE)} {
		set dur $pa($fnam,$evv(DUR))
		set srcfile $fnam
	} else {
		Inf $startmsg
		return
	}
	set fnam [lindex $chlist 1]
	if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)) || ![IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
		Inf $startmsg
		return
	} elseif {($pa($fnam,$evv(MINNUM)) < -60.0) || ($pa($fnam,$evv(MAXNUM)) > 60.0)} {
		Inf $startmsg
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File $fnam"
		return
	}
	set cnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		set OK 1
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {![IsNumeric $item] || ($item < -60.0) || ($item > 60.0)} {
				Inf "Invalid Stack Value ($item) In File $fnam : (Range >= -60 to <= 60)"
				set OK 0
				break
			}
			if {($cnt > 0) && ([lsearch $stakvals $item] >= 0)} {
				Inf "Value $item Duplicated In File $fnam"
				set OK 0
				break
			}
			lappend stakvals $item
			incr cnt
		}
		if {!$OK} {
			break
		}
	}
	close $zit
	if {!$OK} {
		return
	}
	set stakcnt  [llength $stakvals]
	set stakfile $fnam

	set fnam [lindex $chlist 2]
	if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)) || ![IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
		Inf $startmsg
		return
	} elseif {($pa($fnam,$evv(MINNUM)) < 0.01) || ($pa($fnam,$evv(MAXNUM)) > 100.0)} {
		Inf $startmsg
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File $fnam"
		return
	}
	set cnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		set OK 1
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {![IsNumeric $item] || ($item < 0.01) || ($item > 100.0)} {
				Inf "Invalid Lean Value ($item) In File $fnam : (Range >= 0.01 to <= 100)"
				set OK 0
				break
			}
			if {($cnt > 0) && ($item <= $lastval)} {
				Inf "Lean Values Do Not Increase At  $lastval $item In File $fnam"
				set OK 0
				break
			}
			set lastval $item
			lappend leanvals $item
			incr cnt
		}
		if {!$OK} {
			break
		}
	}
	set leanfile $fnam
	close $zit
	if {!$OK} {
		return
	}
	catch unset {sn(snack_list)}
	set f .cfs
	if [Dlg_Create $f "CREATE NEW FILES BY STACKING" "set pr_cfs 0" -borderwidth $evv(BBDR)] {
		frame $f.0
		button $f.0.ab -text Abandon -width 10 -command "set pr_cfs 0"
		button $f.0.ok -text Generate -width 10 -command "set pr_cfs 1"
		button $f.0.sv -text "Sound View" -width 10 -command "GetAtkTime 0" -bg $evv(SNCOLOR)
		pack $f.0.ab -side right
		pack $f.0.ok $f.0.sv -side left -padx 4
		pack $f.0 -side top -pady 2 -fill x -expand true
		label $f.1 -text "Use \"Sound View\" to specify attack time in src" -fg $evv(SPECIAL)
		pack $f.1 -side top
		frame $f.2
		entry $f.2.e -textvariable cfs_atk -width 12 
		label $f.2.ll -text "Attack time"
		checkbutton $f.2.lat -text "Use last value" -variable cfs_last
		pack $f.2.e $f.2.ll $f.2.lat -side left -padx 2
		pack $f.2 -side top -pady 2 -fill x -expand true
		wm resizable $f 1 1
		bind $f <Return> {set pr_cfs 1}
		bind $f <Escape> {set pr_cfs 0}
	}
	if {[info exists cfs_lastval]} {
		$f.2.lat config -text "Use last value" -state normal
	} else {
		$f.2.lat config -text "" -state disabled
	}
	set cfs_last 0
	set finished 0
	set pr_cfs 0
	raise $f
	My_Grab 0 $f pr_cfs
	while {!$finished} {
		tkwait variable pr_cfs
		if {$pr_cfs} {
			if {[llength $cfs_atk] <= 0 || !([IsNumeric $cfs_atk]) || ($cfs_atk < 0.0) || ($cfs_atk >= $dur)} {
				Inf "Invalid Attack-time"
				continue
			}
			set cfs_lastval $cfs_atk
			if {![SynthByStack $srcfile $stakfile $stakcnt $cfs_atk $leanfile $leanvals]} {
				DeleteAllTemporaryFiles
				continue
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc GetAtkTime {gsd} {
	global evv prm pprg cfs_atk gsd_par1 shoct_atk strr_atk trrm_lim trrs_lim strs_atk trrn_dur trtr_lim trtr_stt
	if {[info exists pprg]} {
		set oldpprg $pprg
	}
	if {$gsd == 8} {
		set pprg $evv(SYNTHSEQ2)
		SnackDisplay $evv(SN_TIMEPAIRS) $pprg $evv(TIME_OUT) 0
	} else {
		set pprg $evv(SYNTHSEQ)
		SnackDisplay $evv(SN_SINGLETIME) $pprg $evv(TIME_OUT) 0
	}
	if {[info exists oldpprg]} {
		set pprg $oldpprg 
	} else {
		unset pprg
	}
	if {[info exists prm(0)] && ([llength $prm(0)] == 1)} {
		switch -- $gsd {
			0 {
				set cfs_atk $prm(0)
			}
			1 {
				set gsd_par1 $prm(0)
			}
			2 {
				set shoct_atk $prm(0)
			}
			3 {
				set strr_atk $prm(0)
			}
			4 {
				set trrm_lim $prm(0)
			}
			5 {
				set trrs_lim $prm(0)
			}
			6 {
				set strs_atk $prm(0)
			}
			7 {
				set trrn_dur $prm(0)
			}
			8 {
				set trtr_stt $prm(0)
				set trtr_lim $prm(1)
			}
		}
	}
}

proc SynthByStack {srcfile stakfile stakcnt atktime leanfile leanvals} {
	global evv CDPidrun prg_dun prg_abortd simple_program_messages last_outfile

	;#	SET UP OUTFILE NAMES

	set outfnambas [file rootname [file tail $srcfile]]
	set staknam [file rootname [file tail $stakfile]]
	set leannam [file rootname [file tail $leanfile]]
	set atknam ""
	set len [string length $atktime]
	set n 0
	while {$n < $len} {
		set c [string index $atktime $n]
		if {[string match $c "."]} {
			append atknam "p"
		} else {
			append atknam $c
		}
		incr n
	}
	foreach lean $leanvals {
		set lnam ""
		set len [string length $lean]
		set n 0
		while {$n < $len} {
			set c [string index $lean $n]
			if {[string match $c "."]} {
				append lnam "p"
			} else {
				append lnam $c
			}
			incr n
		}

		set ofnam $outfnambas
		append ofnam "_stk_" $atknam "_" $staknam "_" $leannam "_" $lnam
		append ofnam $evv(SNDFILE_EXT)
		if {[file exist $ofnam]} {
			Inf "File $ofnam Already Exists : Cannot Proceed"
			return
		}
		lappend ofnams $ofnam
	}
	Block "PLEASE WAIT:        STACKING FILES"
	set n 1
	foreach lean $leanvals ofnam $ofnams {
		set cmd [file join $evv(CDPROGRAM_DIR) modify]
		lappend cmd stack $srcfile $ofnam $stakfile $stakcnt $lean $atktime 1 1 -n 
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		wm title .blocker "PLEASE WAIT:        STACKING FILE $n"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "$CDPidrun : FAILED TO STACK FILE $ofnam"
			continue
		} else {
 			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			set msg "Failed To Produce Stacked File $ofnam"
			set msg [AddSimpleMessages $msg]
			Inf $msg
			continue
		}
		lappend outfnams $ofnam
		incr n
	}
	if {![info exists outfnams]} {
		UnBlock
		return 0
	}
	set outfnams [ReverseList $outfnams]
	foreach ofnam $outfnams {
		FileToWkspace $ofnam 0 0 0 0 1
		lappend zx $outfnams
	}
	set last_outfile $zx
	UnBlock
	return 1
}

#---- REVERB
#---- Use REVERBVALS, and stasize to generate mods of sound

proc GenerateSpectraByReverb {} {

	global chlist evv pa wstk pr_gsr gsr_lastval gsr_stad gsr_maxdur gsr_stereo

	set startmsg "Requires A Soundfile, And Textfile Of Reverb Echo-counts.\n"

	if {![info exists chlist] || ([llength $chlist] !=2)} {
		Inf $startmsg
		return
	}
	set fnam [lindex $chlist 0]
	if {$pa($fnam,$evv(FTYP)) == $evv(SNDFILE)} {
		set dur $pa($fnam,$evv(DUR))
		set srcfile $fnam
	} else {
		Inf $startmsg
		return
	}
	set fnam [lindex $chlist 1]
	if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)) || ![IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
		Inf $startmsg
		return
	} elseif {($pa($fnam,$evv(MINNUM)) < 2.0) || ($pa($fnam,$evv(MAXNUM)) > 1000.0)} {
		Inf $startmsg
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File $fnam"
		return
	}
	set cnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		set OK 1
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {![regexp {^[0-9]+$} $item] || ($item < 2.0) || ($item > 1000.0)} {
				Inf "Invalid Echo-Count ($item) In File $fnam : (Range >= 2 to <= 1000)"
				set OK 0
				break
			}
			if {($cnt > 0) && ($item <= $lastval)} {
				Inf "Echo Values Do Not Increase At $lastval $item IN FILE $fnam"
				set OK 0
				break
			}
			set lastval $item
			lappend echovals $item
			incr cnt
		}
		if {!$OK} {
			break
		}
	}
	set echofile $fnam
	close $zit
	if {!$OK} {
		return
	}

	set f .gsr
	if [Dlg_Create $f "CREATE NEW FILES BY REVERB" "set pr_gsr 0" -borderwidth $evv(BBDR)] {
		frame $f.0
		button $f.0.ab -text Abandon -width 10 -command "set pr_gsr 0"
		checkbutton $f.0.st -text "Stereo out" -variable gsr_stereo
		button $f.0.ok -text Generate -width 10 -command "set pr_gsr 1"
		pack $f.0.ab -side right
		pack $f.0.ok $f.0.st -side left -padx 4
		pack $f.0 -side top -pady 2 -fill x -expand true
		frame $f.1
		entry $f.1.e -textvariable gsr_stad -width 12 
		label $f.1.ll -text "Stadium-size multiplier"
		checkbutton $f.1.lat -text "Use last value" -variable gsr_last
		pack $f.1.e $f.1.ll $f.1.lat -side left -padx 2
		pack $f.1 -side top -pady 2 -fill x -expand true
		wm resizable $f 1 1
		bind $f <Return> {set pr_gsr 1}
		bind $f <Escape> {set pr_gsr 0}
		frame $f.2
		entry $f.2.e -textvariable gsr_maxdur -width 12 
		label $f.2.ll -text "Maximum dur (zero = no max)" -width 60
		pack $f.2.e $f.2.ll -side left -padx 2
		pack $f.2 -side top -pady 2 -fill x -expand true
		wm resizable $f 1 1
		bind $f.1.e <Up> "focus $f.2.e"
		bind $f.2.e <Up> "focus $f.1.e"
		bind $f.1.e <Down> "focus $f.2.e"
		bind $f.2.e <Down> "focus $f.1.e"
		bind $f <Return> {set pr_gsr 1}
		bind $f <Escape> {set pr_gsr 0}
	}
	if {[info exists gsr_lastval]} {
		$f.1.lat config -text "Use last value" -state normal
	} else {
		$f.1.lat config -text "" -state disabled
	}
	$f.2.ll config -text "Maximum dur : Range >= $dur OR zero (= no max)"
	set gsr_maxdur $dur
	set gsr_last 0
	set finished 0
	set pr_gsr 0
	raise $f
	My_Grab 0 $f pr_gsr $f.1.e
	while {!$finished} {
		tkwait variable pr_gsr
		if {$pr_gsr} {
			if {[llength $gsr_maxdur] <= 0} {
				set msg "No Maximum Duration - Is This Correct ??"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message "$msg"]
				if {$choice == "no"} {
					continue
				} else {
					set gsr_maxdur 0
				}
			} elseif {[llength $gsr_maxdur] <= 0 || !([IsNumeric $gsr_maxdur]) || (($gsr_maxdur < $dur) && ($gsr_maxdur != 0.0))} {
				Inf "Invalid Maximum-Duration"
				continue
			}
			if {[llength $gsr_stad] <= 0 || !([IsNumeric $gsr_stad]) || ($gsr_stad < 0.1) || ($gsr_stad >= 10)} {
				Inf "Invalid Stadium-Size Multiplier"
				continue
			}
			set gsr_lastval $gsr_stad
			if {![SynthByReverb $srcfile $gsr_stad $echofile $dur $gsr_maxdur $echovals]} {
				DeleteAllTemporaryFiles
				continue
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc SynthByReverb {srcfile stadsize echofile dur maxdur echovals} {
	global evv CDPidrun prg_dun prg_abortd simple_program_messages pa evv last_outfile gsr_stereo

	;#	SET UP OUTFILE NAMES

	set outfnambas [file rootname [file tail $srcfile]]
	set echonam [file rootname [file tail $echofile]]
	set ssnam ""
	set mmnam ""
	set len [string length $stadsize]
	set n 0
	while {$n < $len} {
		set c [string index $stadsize $n]
		if {[string match $c "."]} {
			append ssnam "p"
		} else {
			append ssnam $c
		}
		incr n
	}
	if {$maxdur > 0.0} {
		set n 0
		while {$n < $len} {
			set c [string index $maxdur $n]
			if {[string match $c "."]} {
				append mmnam "p"
			} else {
				append mmnam $c
			}
			incr n
		}
	}
	set n 0
	foreach echo $echovals {
		set tempofnam $evv(DFLT_OUTNAME)
		append tempofnam $n $evv(SNDFILE_EXT)
		lappend tempofnams $tempofnam
		set ofnam2 $evv(MACH_OUTFNAME)
		append ofnam2 $n $evv(SNDFILE_EXT)
		lappend ofnams2 $ofnam2
		incr n
	}

	foreach echo $echovals {
		set ofnam $outfnambas
		if {$gsr_stereo} {
			append ofnam "_rev_"
		} else {
			append ofnam "_revm_"
		}
		append ofnam $ssnam "_" $echonam "_" $echo
		if {$maxdur >0.0} {
			append ofnam "_" cutmax "_" $mmnam
		}
		append ofnam $evv(SNDFILE_EXT)
		if {[file exist $ofnam]} {
			Inf "File $ofnam Already Exists : Cannot Proceed"
			return 0
		}
		lappend ofnams $ofnam
	}
	set finaloutfnams $ofnams
	if {$maxdur > 0.0} {
		set ofnams $tempofnams
	}

	Block "PLEASE WAIT:        REVERBING FILES"
	set n 1
	foreach echo $echovals ofnam2 $ofnams2 ofnam $ofnams {
		set cmd [file join $evv(CDPROGRAM_DIR) modify]
		lappend cmd revecho 3 $srcfile $ofnam2 -g1 -r1 -s$stadsize -e$echo -n
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		wm title .blocker "PLEASE WAIT:        REVERBING FILE $n"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "$CDPidrun : Failed To Reverb File $n"
			UnBlock
			return 0
		} else {
 			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun || ![file exists $ofnam2]} {
			set msg "Failed To Produce Reverbed File $n"
			set msg [AddSimpleMessages $msg]
			Inf $msg
			UnBlock
			return 0
		}
		if {$gsr_stereo} {
			lappend outfnams $ofnam2
		} else {
			;#	CONVERT TO MONO

			set cmd [file join $evv(CDPROGRAM_DIR) housekeep]
			lappend cmd chans 4 $ofnam2 $ofnam
			set CDPidrun 0
			set prg_dun 0
			set prg_abortd 0
			catch {unset simple_program_messages}
			wm title .blocker "PLEASE WAIT:        MONO-CONVERTING FILE $n"
			if [catch {open "|$cmd"} CDPidrun] {
				Inf "$CDPidrun : Failed To Mono-convert File $n"
				if {$maxdur > 0.0} {
					UnBlock
					return 0
				}
				continue
			} else {
 				fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
			}
			vwait prg_dun
			if {$prg_abortd} {
				set prg_dun 0
			}
			if {!$prg_dun || ![file exists $ofnam]} {
				set msg "Failed To Produce Mono-Converted File $n"
				set msg [AddSimpleMessages $msg]
				Inf $msg
				if {$maxdur > 0.0} {
					UnBlock
					return 0
				}
				continue
			}
			lappend outfnams $ofnam
		}
		incr n
	}
	if {![info exists outfnams]} {
		UnBlock
		return 0
	}

	if {$maxdur > 0.0} {

		set goaldur $dur
		set durdiff [expr $maxdur - $dur]
		set durstep [expr $durdiff/[llength $echovals]]  
		foreach tempofnam $outfnams ofnam $finaloutfnams {
			set goaldur [expr $goaldur + $durstep]
			if {[DoParse $tempofnam 0 0 0] <= 0} {
				Inf "Failed To Find Original Duration Of File $ofnam"
				continue
			}
			set dur $pa($tempofnam,$evv(DUR))
			PurgeArray $tempofnam
			if {$goaldur < $dur} {
				set cmd [file join $evv(CDPROGRAM_DIR) envel]
				lappend cmd curtail 4 $tempofnam $ofnam 0 $goaldur -t0
				set CDPidrun 0
				set prg_dun 0
				set prg_abortd 0
				catch {unset simple_program_messages}
				wm title .blocker "PLEASE WAIT:        ENVELOPING FILE $ofnam"
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "$CDPidrun : Failed To End-envelope File $ofnam"
					continue
   				} else {
 					fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				if {!$prg_dun} {
					set msg "Failed To Do End-envelope For File $ofnam"
					set msg [AddSimpleMessages $msg]
					continue
				}
				if {![file exists $ofnam]} {
					set msg "Failed To Produce End-enveloped $ofnam"
					set msg [AddSimpleMessages $msg]
					Inf $msg
					continue
				}
			} else {
				if [catch {file rename $tempofnam $ofnam} zit] {
					Inf "Failed To Rename Temporary File To $ofnam"
					continue
				}
			}
		}
		set outfnams $finaloutfnams
	
	} elseif {$gsr_stereo} {
		set ofnams $outfnams
		unset outfnams
		foreach ofnam $ofnams outfnam $finaloutfnams {
			if [catch {file rename $ofnam $outfnam} zit] {
				Inf "Failed To Rename File $outfnam"
				continue
			}
			lappend outfnams $outfnam
		}
		if {![info exists outfnams]} {
			UnBlock
			return 0
		}
	}
	set outfnams [ReverseList $outfnams]
	foreach ofnam $outfnams {
		if {[file exists $ofnam]} {
			FileToWkspace $ofnam 0 0 0 0 1
			lappend zx $ofnam
		}
	}
	if {[info exists zx]} {
		set last_outfile $zx
	}
	UnBlock
	return 1
}

#---- DISTORT
#---- Use distort cycletyp and interp

proc GenerateSpectraByDistort {} {
	global chlist evv pa pr_gsd gsd_typ gsd_par1 gsd_par2 gsd_mode gsd_mod2 sn_prm1
	global CDPmaxId maxsamp_line done_maxsamp gsd_lastexag gsd_lastrep gsd_lastom gsd_lastoo
	global gsd_last_atk gsd_last

	set sn_prm1 0

	set startmsg "Requires A Mono Soundfile, And Textfile Of Interpolation Values.\n"

	if {![info exists chlist] || ([llength $chlist] !=2)} {
		Inf $startmsg
		return
	}
	set fnam [lindex $chlist 0]
	if {($pa($fnam,$evv(FTYP)) == $evv(SNDFILE)) && ($pa($fnam,$evv(CHANS)) == 1)} {
		set dur $pa($fnam,$evv(DUR))
		set srcfile $fnam
	} else {
		Inf $startmsg
		return
	}
	set couldbeinterp 0
	set fnam [lindex $chlist 1]
	if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)) || ![IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
		Inf $startmsg
		return
	} elseif {($pa($fnam,$evv(MINNUM)) <= 0.0) || ($pa($fnam,$evv(MAXNUM)) >= 1.0)} {
		if {($pa($fnam,$evv(MINNUM)) >= 2.0) && ($pa($fnam,$evv(MAXNUM)) <= 12.0)} {
			set couldbeinterp 1
		} else {
			Inf $startmsg
			return
		}
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File $fnam"
		return
	}
	set cnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		set OK 1
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {$couldbeinterp} {
				if {![IsNumeric $item] || ![regexp {^[0-9]+$} $item] || ($item < 2.0) || ($item > 12.0)} {
					Inf "Invalid Interpolation Value ($item) In File $fnam : (Integer : Range 2 to 12)"
					set OK 0
					break
				}
			} elseif {![IsNumeric $item] || ($item <= 0.0) || ($item >= 1.0)} {
				Inf "Invalid Interp Value ($item) In File $fnam : (Range > 0 to < 1)"
				set OK 0
				break
			}
			if {($cnt > 0) && ($item <= $lastval)} {
				Inf "Interp Values Do Not Increase At $lastval $item In File $fnam"
				set OK 0
				break
			}
			set lastval $item
			lappend interpvals $item
			incr cnt
		}
		if {!$OK} {
			break
		}
	}
	set interpfile $fnam
	close $zit
	if {!$OK} {
		return
	}
	set f .gsd
	if [Dlg_Create $f "CREATE NEW FILES BY DISTORT & INTERP" "set pr_gsd 0" -borderwidth $evv(BBDR)] {
		frame $f.0
		button $f.0.ab -text Abandon -width 10 -command "set pr_gsd 0"
		button $f.0.ok -text Generate -width 10 -command "set pr_gsd 1"
		button $f.0.sv -text "Sound View" -width 10 -command "GetAtkTime 1" -bg $evv(SNCOLOR)
		pack $f.0.ab -side right
		pack $f.0.ok $f.0.sv -side left -padx 4
		pack $f.0 -side top -pady 2 -fill x -expand true
		frame $f.1
		radiobutton $f.1.0 -variable gsd_typ -width 7 -text sine	 -value 0 -command GSDother
		radiobutton $f.1.1 -variable gsd_typ -width 7 -text square	 -value 1 -command GSDother
		radiobutton $f.1.2 -variable gsd_typ -width 7 -text triangle -value 2 -command GSDother
		radiobutton $f.1.3 -variable gsd_typ -width 7 -text CLICK	 -value 3 -command GSDother
		radiobutton $f.1.4 -variable gsd_typ -width 7 -text INVERSE  -value 4 -command GSDother
		pack $f.1.0 $f.1.1 $f.1.2 $f.1.3 $f.1.4 -side left 
		pack $f.1 -side top 
		frame $f.2
		radiobutton $f.2.5 -variable gsd_typ -width 7 -text EXAGG	 -value 5 -command GSDother
		radiobutton $f.2.6 -variable gsd_typ -width 7 -text repeat	 -value 6 -command GSDother		;# (AND INTERP)
		radiobutton $f.2.7 -variable gsd_typ -width 7 -text omit	 -value 7 -command GSDother		;#	NORMALISE
		radiobutton $f.2.8 -variable gsd_typ -width 7 -text INTERP	 -value 8 -command GSDother		;# NEEDS CUT-START AND DOVE END
		pack $f.2.5 $f.2.6 $f.2.7 $f.2.8 -side left 
		pack $f.2 -side top 
		frame $f.3
		entry $f.3.e -textvariable gsd_par1 -width 8 -bd 0 -disabledbackground [option get . background {}] -state disabled
		label $f.3.ll -text "" -width 12
		checkbutton $f.3.lat -text "Use Last Val" -variable gsd_last -command GetLastGsdAtk
		pack $f.3.e $f.3.ll $f.3.lat -side left 
		pack $f.3 -side top 
		frame $f.4
		entry $f.4.e -textvariable gsd_par2 -width 8 -bd 0 -disabledbackground [option get . background {}] -state disabled
		label $f.4.ll -text "" -width 12
		pack $f.4.e $f.4.ll -side left 
		pack $f.4 -side top 
		wm resizable $f 1 1
		bind $f <Return> {set pr_gsd 1}
		bind $f <Escape> {set pr_gsd 0}
	}
	set gsd_mod2 0
	set gsd_par1 0
	set gsd_par2 0
	set gsd_typ -1
	GSDother
	set finished 0
	set pr_gsd 0
	raise $f
	My_Grab 0 $f pr_gsd
	while {!$finished} {
		tkwait variable pr_gsd
		if {$pr_gsd} {
			set msg "Interpolation values not compatible with this option : Range should be "
			set OK 1
			switch -- $couldbeinterp {
				0 {
					if {$gsd_typ == 8} {
						set OK 0
						append msg " 2 to 12"
					}
				}
				1 {
					if {$gsd_typ != 8} {
						set OK 0
						append msg " >0 to <1"
					}
				}
			}
			if {!$OK} {
				Inf $msg
				continue
			}
			switch -- $gsd_typ {
				-1 {
					Inf "No Distortion Type Chosen"
					continue
				}
				0 {	;#	SINE
					set gsd_mode reform
					set gsd_mod2 7
				}
				1 {	;#	SQUARE
					set gsd_mode reform
					set gsd_mod2 2
				}
				2 {	;#	TRIANGLE
					set gsd_mode reform
					set gsd_mod2 4
				}
				3 {	;#	CLICK
					set gsd_mode reform
					set gsd_mod2 6
				}
				4 {	;#	INVERT HALF-CYCLES
					set gsd_mode reform
					set gsd_mod2 5
				}
				5 {	;#	EXAGG
					set gsd_mode reform
					set gsd_mod2 8
					if {![info exists gsd_par1] || ![IsNumeric $gsd_par1] || ($gsd_par1 < 0.000002) || ($gsd_par1 > 40)} {
						Inf "Invalid Exaggeration Value (range 0.000002 to 40)"
						continue
					}
					set gsd_lastexag $gsd_par1
				}
				6 {	;#	REPEAT
					set gsd_mode repeat2
					if {![info exists gsd_par1] || ![IsNumeric $gsd_par1] || ![regexp {^[0-9]+$} $gsd_par1] || ($gsd_par1 < 2) || ($gsd_par1 > 20)} {
						Inf "Invalid Repetition Value (range 2 to 20)"
						continue
					}
					set gsd_lastrep $gsd_par1
				}
				7 {	;#	OMIT
					set gsd_mode omit
					if {![info exists gsd_par1] || ![IsNumeric $gsd_par1] || ![regexp {^[0-9]+$} $gsd_par1] || ($gsd_par1 < 1) || ($gsd_par1 > 63)} {
						Inf "Invalid Omission Value (range 1 to 63)"
						continue
					}
					if {![info exists gsd_par2] || ![IsNumeric $gsd_par2] || ![regexp {^[0-9]+$} $gsd_par2] || ($gsd_par1 < 2) || ($gsd_par2 > 64)} {
						Inf "Invalid \"Out Of\" Value (range 2 to 64)"
						continue
					}
					if {$gsd_par2 <= $gsd_par1} {
						Inf "Incompatible Omision And \"Out Of\" Values"
						continue
					}
					set gsd_lastom $gsd_par1 
					set gsd_lastoo $gsd_par2 
				}
				8 {	;#	INTERP
					set gsd_mode interpolate
					if {![info exists gsd_par1] || ![IsNumeric $gsd_par1] || ($gsd_par1 < 0) || ($gsd_par1 >= $dur)} {
						Inf "Invalid Attack Position (range 0 to < $dur)"
						continue
					}
				}
			}
			set gsd_last_atk $gsd_par1
			if {![SynthByDistort $srcfile $gsd_mode $gsd_mod2 $dur $gsd_par1 $gsd_par2 $interpfile $interpvals]} {
				DeleteAllTemporaryFiles
				continue
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}


proc GetLastGsdAtk {} {
	global gsd_last gsd_par1 gsd_last_atk
	if {$gsd_last} {
		if {[info exists gsd_last_atk]} { 
			set gsd_par1 $gsd_last_atk
		} else {
			set gsd_last 0
			Inf "No Previous Value"
		}
	}
}

proc GSDother {} {
	global gsd_typ gsd_par1 gsd_par2 gsd_lastexag gsd_lastrep gsd_lastom gsd_lastoo cfs_atk evv gsd_last

	set gsd_last 0

	set gsd_par1 ""
	set gsd_par2 ""
	switch -- $gsd_typ {
		5 {
			.gsd.3.e  config -bd 2 -state normal
			.gsd.3.ll config -text "Exaggeration"
			.gsd.3.lat config -text "" -state disabled
			.gsd.4.e  config -bd 0 -disabledbackground [option get . background {}] -state disabled
			.gsd.4.ll config -text ""
			.gsd.0.sv config -text "" -bd 0 -background [option get . background {}] -command {}
			catch {set gsd_par1 $gsd_lastexag}
		}
		6 {
			.gsd.3.e  config -bd 2 -state normal
			.gsd.3.ll config -text "Repetitions"
			.gsd.3.lat config -text "" -state disabled
			.gsd.4.e  config -bd 0 -disabledbackground [option get . background {}] -state disabled
			.gsd.4.ll config -text ""
			.gsd.0.sv config -text "" -bd 0 -background [option get . background {}] -command {}
			catch {set gsd_par1 $gsd_lastrep}
		}
		7 {
			.gsd.3.e  config -bd 2 -state normal
			.gsd.3.ll config -text "Omit"
			.gsd.3.lat config -text "" -state disabled
			.gsd.4.e  config -bd 2 -state normal
			.gsd.4.ll config -text "Out of"
			.gsd.0.sv config -text "" -bd 0 -background [option get . background {}] -command {}
			catch {set gsd_par1 $gsd_lastom}
			catch {set gsd_par2 $gsd_lastoo}
		}
		8 {
			.gsd.3.e  config -bd 2 -state normal
			.gsd.3.ll config -text "Atk Time"
			.gsd.3.lat config -text "Use Last Val" -state normal
			.gsd.4.e  config -bd 0 -disabledbackground [option get . background {}] -state disabled
			.gsd.4.ll config -text ""
			.gsd.0.sv config -text "Sound View" -bd 2 -background $evv(SNCOLOR) -command "GetAtkTime 1"
		}
		default {
			set gsd_par1 ""
			set gsd_par2 ""
			.gsd.0.sv config -text "" -bd 0 -background [option get . background {}] -command {}
			.gsd.3.e  config -bd 0 -disabledbackground [option get . background {}] -state disabled
			.gsd.3.ll config -text ""
			.gsd.3.lat config -text "" -state disabled
			.gsd.4.e  config -bd 0 -disabledbackground [option get . background {}] -state disabled
			.gsd.4.ll config -text ""
		}
	}
}

proc SynthByDistort {srcfile typ mode dur par1 par2 interpfile vals} {
	global evv CDPidrun prg_dun prg_abortd simple_program_messages pa evv last_outfile

	set n 0
	set len [llength $vals] 
	while {$n < $len} {
		set tempofnam $evv(DFLT_OUTNAME)
		lappend tempofnam $n $evv(SNDFILE_EXT)
		lappend tempofnams $tempofnam
		incr n
	}
	set tempofnam1 $evv(DFLT_OUTNAME)
	append tempofnam1 $n $evv(SNDFILE_EXT)
	incr n
	set tempofnam2 $evv(DFLT_OUTNAME)
	append tempofnam2 $n $evv(SNDFILE_EXT)
	incr n
	set tempofnam3 $evv(DFLT_OUTNAME)
	append tempofnam3 $n $evv(SNDFILE_EXT)

	set m 0
	while {$m < $len} {
		incr n
		set shortofnam $evv(DFLT_OUTNAME)
		append shortofnam $n $evv(SNDFILE_EXT)
		lappend shortofnams $shortofnam
		incr m
	}
	set m 0
	while {$m < $len} {
		incr n
		set shortofnam $evv(DFLT_OUTNAME)
		append shortofnam $n $evv(SNDFILE_EXT)
		lappend shorterofnams $shortofnam
		incr m
	}

	set tempinterpnam $evv(MACH_OUTFNAME)

	;#	SET UP OUTFILE NAMES

	if {$par1 > 0} {
		set p1nam ""
		set len [string length $par1]
		set n 0
		while {$n < $len} {
			set c [string index $par1 $n]
			if {[string match $c "."]} {
				append p1nam "p"
			} else {
				append p1nam $c
			}
			incr n
		}
	}
	if {$par2 > 0} {
		set p2nam ""
		set len [string length $par2]
		set n 0
		while {$n < $len} {
			set c [string index $par2 $n]
			if {[string match $c "."]} {
				append p2nam "p"
			} else {
				append p2nam $c
			}
			incr n
		}
	}

	set outfnambas [file rootname [file tail $srcfile]]
	set iterpnam   [file rootname [file tail $interpfile]]
	if {[string match $typ "reform"]} {
		switch -- $mode {
			2 { append outfnambas "_" idistortsqu }
			4 { append outfnambas "_" idistorttri }
			5 { append outfnambas "_" idistortinv }
			6 { append outfnambas "_" idistortclk }
			7 { append outfnambas "_" idistortsin }
			8 { append outfnambas "_" idistortexg }
		}
				
	} else {
		append outfnambas "_" idistort$typ
	}
	switch -- $typ {
		"reform" {
			if {$mode == 8} {
				append outfnambas "_" $p1nam
			}
		}
		"repeat2" -
		interpolate {
			append outfnambas "_" $p1nam
		}
		"omit" {
			append outfnambas "_" $p1nam "_" $p2nam
		}
	}
	append outfnambas "_" $iterpnam

	foreach val $vals {
		set valnam ""
		set len [string length $val]
		set n 0
		while {$n < $len} {
			set c [string index $val $n]
			if {[string match $c "."]} {
				append valnam "p"
			} else {
				append valnam $c
			}
			incr n
		}
		set ofnam $outfnambas
		append ofnam "_" $valnam
		append ofnam $evv(SNDFILE_EXT)
		if {[file exist $ofnam]} {
			Inf "File $ofnam Already Exists : Cannot Proceed"
			return 0
		}
		lappend ofnams $ofnam
	}
	set lastofnam $outfnambas 
	append lastofnam "_" 1 $evv(SNDFILE_EXT)
	if {[file exist $lastofnam]} {
		Inf "File $lastofnam Already Exists : Cannot Proceed"
		return 0
	}

	Block "PLEASE WAIT:        DISTORTING FILES"

	if {[string match $typ "interpolate"]} {
		set n 1
		foreach val $vals tempofnam $tempofnams {
			set cmd [file join $evv(CDPROGRAM_DIR) distort]
			lappend cmd interpolate 
			lappend cmd $srcfile $tempofnam $val -s0
			set CDPidrun 0
			set prg_dun 0
			set prg_abortd 0
			catch {unset simple_program_messages}
			wm title .blocker "PLEASE WAIT:        DISTORTING FILE $n"
			if [catch {open "|$cmd"} CDPidrun] {
				Inf "$CDPidrun : Failed To Distort File $n"
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
				set msg "Failed To Produce Distorted File $n"
				set msg [AddSimpleMessages $msg]
				Inf $msg
				UnBlock
				return 0
			}
			incr n
		}

	;#	CURTAIL OUTFILE ATTACK
		set n 1
		foreach val $vals tempofnam $tempofnams shortofnam $shortofnams {
			set thisdur [expr ($val - 1) * $par1]
			set cmd [file join $evv(CDPROGRAM_DIR) sfedit]
			lappend cmd excise 1 $tempofnam $shortofnam 0 $thisdur -w5
			set CDPidrun 0
			set prg_dun 0
			set prg_abortd 0
			catch {unset simple_program_messages}
			wm title .blocker "PLEASE WAIT:        SHORTENING DISTORTED FILE $n"
			if [catch {open "|$cmd"} CDPidrun] {
				Inf "$CDPidrun : Failed To Shorten Distorted File"
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
				set msg "Failed To Do Shortening For Distorted File $n"
				set msg [AddSimpleMessages $msg]
				UnBlock
				return 0
			}
			if {![file exists $shortofnam]} {
				set msg "Failed To Produce Shortened Distorted File $n"
				set msg [AddSimpleMessages $msg]
				Inf $msg
				UnBlock
				return 0
			}
			incr n
		}
		set n 1
		foreach tempofnam $shortofnams shortofnam $shorterofnams {
			set cmd [file join $evv(CDPROGRAM_DIR) envel]
			lappend cmd curtail 4 $tempofnam $shortofnam $par1 $dur -t0
			set CDPidrun 0
			set prg_dun 0
			set prg_abortd 0
			catch {unset simple_program_messages}
			wm title .blocker "PLEASE WAIT:        CURTAILING DISTORTED FILE $n"
			if [catch {open "|$cmd"} CDPidrun] {
				Inf "$CDPidrun : Failed To Curtail Distorted File"
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
				set msg "Failed To Do Curtailing For Distorted File $n"
				set msg [AddSimpleMessages $msg]
				UnBlock
				return 0
			}
			if {![file exists $shortofnam]} {
				set msg "Failed To Produce Curtailed Distorted File $n"
				set msg [AddSimpleMessages $msg]
				Inf $msg
				UnBlock
				return 0
			}
			incr n
		}
		set n 1
		foreach val $vals shortofnam $shorterofnams ofnam $ofnams {
			set cmd [file join $evv(CDPROGRAM_DIR) filter]
			lappend cmd lohi 1 $shortofnam $ofnam -96 40 20 -t0 -s.9
			set CDPidrun 0
			set prg_dun 0
			set prg_abortd 0
			catch {unset simple_program_messages}
			wm title .blocker "PLEASE WAIT:        FILTERING DISTORTED FILE $n"
			if [catch {open "|$cmd"} CDPidrun] {
				Inf "$CDPidrun : Failed To Run Filtering Of Distorted File $n"
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
				set msg "Failed To Filter Distorted File $n"
				set msg [AddSimpleMessages $msg]
				UnBlock
				return 0
			}
		}
		set trueofnams $ofnams
	} else {
		set cmd [file join $evv(CDPROGRAM_DIR) distort]
		lappend cmd $typ
		if {$mode > 0} {
			lappend cmd $mode
		}
		lappend cmd $srcfile $tempofnam1
		if {$par1 > 0} {
			lappend cmd $par1
		}
		if {$par2 > 0} {
			lappend cmd $par2
		}
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		wm title .blocker "PLEASE WAIT:        DISTORTING FILE"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "$CDPidrun : Failed To Distort File"
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
			set msg "Failed To Produce Distorted File"
			set msg [AddSimpleMessages $msg]
			Inf $msg
			UnBlock
			return 0
		}

		;#	LOPASS FILTER OUTFILE

		set cmd [file join $evv(CDPROGRAM_DIR) filter]
		lappend cmd lohi 1 $tempofnam1 $tempofnam3 -96 40 20 -t0 -s.9
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		wm title .blocker "PLEASE WAIT:        FILTERING DISTORTED FILE"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "$CDPidrun : Failed To Run Filtering Of Distorted File"
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
			set msg "Failed To Filter Distorted File"
			set msg [AddSimpleMessages $msg]
			UnBlock
			return 0
		}
		if {![file exists $tempofnam3]} {
			set msg "Failed To Produce Filtered Distorted File"
			set msg [AddSimpleMessages $msg]
			Inf $msg
			UnBlock
			return 0
		}

		;#	DO INTERPOLATION

		set cmd [file join $evv(CDPROGRAM_DIR) submix]
		lappend cmd inbetween 2 $srcfile $tempofnam3 $tempinterpnam $interpfile
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		wm title .blocker "PLEASE WAIT:        INTERPOLATING FILES"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "$CDPidrun : Failed To Interpolate Files"
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
			set msg "Failed To Produce Interpolated Files"
			set msg [AddSimpleMessages $msg]
			Inf $msg
			UnBlock
			return 0
		}
		set n 1
		set len [llength $vals]
		while {$n <= $len} {
			if {$n < 10} {
				set nn 00$n
			} elseif {$n < 100} {
				set nn 0$n
			} else {
				set nn $n
			}
			set thisofnam $tempinterpnam
			append thisofnam $nn $evv(SNDFILE_EXT)
			if {![file exists $thisofnam]} {
				Inf "One Or More Of Interpolated Files Does Not Exist : $thisofnam"
				UnBlock
				return 0
			}
			lappend outfnams $thisofnam
			incr n	
		}
		foreach outfnam $outfnams ofnam $ofnams {
			if [catch {file rename $outfnam $ofnam} zit] {
				Inf "Failed To Rename File $ofnam"
				continue
			} else {
				lappend trueofnams $ofnam
			}
		}
		if [catch {file rename $tempofnam3 $lastofnam} zit] {
			Inf "Failed To Rename File $lastofnam"
		} else {
			lappend trueofnams $lastofnam
		}
		if {![info exists trueofnams]} {
			UnBlock
			return 0
		}
	}
	set trueofnams [ReverseList $trueofnams]
	foreach fnam $trueofnams {
		FileToWkspace $fnam 0 0 0 0 1
	}
	UnBlock
	return 1
}

#---- SEQUENCES BY TREMOLO

proc GenerateSpectraByTremolo {} {

	global chlist evv pa pr_trr trr_frq trr_typ couldbetrem couldbevib couldbeacc accdown

	set startmsg "Requires Soundfile, And Textfile Of (Optional) Tremolo Depths (0 To <1), And Peak-Narrowings (2-100).\n"
	set accdown 0

	if {![info exists chlist] || ([llength $chlist] !=2)} {
		Inf $startmsg
		return
	}
	set fnam [lindex $chlist 0]
	if {$pa($fnam,$evv(FTYP)) == $evv(SNDFILE)} {
		set dur $pa($fnam,$evv(DUR))
		set srcfile $fnam
	} else {
		Inf $startmsg
		return
	}
	set fnam [lindex $chlist 1]
	if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)) || ![IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
		Inf $startmsg
		return
	} elseif {($pa($fnam,$evv(MINNUM)) < 0.0) || ($pa($fnam,$evv(MAXNUM)) > 100.0)} {
		Inf $startmsg
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File $fnam"
		return
	}
	set cnt 0
	set couldbetrem 1
	set couldbevib 1
	set couldbeacc 1
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		set OK 1
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {![IsNumeric $item] || ($item < 0.0) || ($item > 100.0)} {
				Inf "Invalid Value ($item) In File $fnam : (Range 0 to 100)"
				set OK 0
				break
			}
			if {($item < 0.5) || ($item > 4.0)} {
				set couldbeacc 0
			}
			if {$item > 12.0} {
				set couldbevib 0
			}
			if {($item >= 1.0) && ![regexp {^[0-9]+$} $item]} {
				set couldbetrem 0				
			}
			if {!$couldbevib && !$couldbetrem} {
				Inf "Invalid Vibrato-depth Val ($item) (Range 0 to 12) or Tremolo Peak-narrowing Val (if >= 1, must be integer)"
				set OK 0
				break
			}
			if {$cnt > 0 && ($item <= $lastval)} {
				Inf "Values Do Not Increase At $lastval $item In File $fnam"
				set OK 0
				break
			}
			set lastval $item
			lappend tremvals $item
			incr cnt
		}
		if {!$OK} {
			break
		}
	}
	set tremfile $fnam
	close $zit
	if {!$OK} {
		return
	}
	if {$couldbeacc} {
		if {$pa($fnam,$evv(MAXNUM)) <= 1} {
			set accdown 1
		}
	}
	set f .trr
	if [Dlg_Create $f "CREATE NEW FILES BY TREMOLO OR VIBRATO" "set pr_trr 0" -borderwidth $evv(BBDR)] {
		frame $f.0
		button $f.0.ab -text Abandon -width 10 -command "set pr_trr 0"
		button $f.0.ok -text Generate -width 10 -command "set pr_trr 1"
		pack $f.0.ab -side right
		pack $f.0.ok -side left -padx 4
		pack $f.0 -side top -pady 2 -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Frequency (Range 10-30)"
		entry $f.1.e -textvariable trr_frq -width 10
		pack $f.1.e $f.1.ll -side left -padx 2
		pack $f.1 -side top -pady 2 -fill x -expand true
		frame $f.2
		radiobutton $f.2.tr -variable trr_typ -text tremolo -value 1 -command CheckTRRTyp
		radiobutton $f.2.vb -variable trr_typ -text vibrato -value 2 -command CheckTRRTyp
		radiobutton $f.2.ac -variable trr_typ -text accel   -value 3 -command CheckTRRTyp
		pack $f.2.tr $f.2.vb $f.2.ac -side left
		pack $f.2 -side top -pady 2
		wm resizable $f 1 1
		bind $f <Return> {set pr_trr 1}
		bind $f <Escape> {set pr_trr 0}
	}
	set trr_typ 0
	set finished 0
	set pr_trr 0
	raise $f
	My_Grab 0 $f pr_trr $f.1.e
	while {!$finished} {
		tkwait variable pr_trr
		if {$pr_trr} {
			if {$trr_typ <= 0} {
				Inf "No Process Type Chosen"
				continue
			}
			if {$trr_typ != 3} {
				if {([string  length $trr_frq] <= 0) || ($trr_frq < 10) || ($trr_frq > 30)} {
					Inf "Invalid Frequency Value"
					continue
				}
			}
			if {![SynthByTremolo $srcfile $trr_typ $trr_frq $dur $tremvals $tremfile]} {
				DeleteAllTemporaryFiles
				continue
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc CheckTRRTyp {}  {
	global couldbetrem couldbevib couldbeacc trr_typ trr_last_frq trr_frq
	switch -- $trr_typ {
		1 {
			if {!$couldbetrem} {
				Inf "Input Data Is Not Tremolo Data"
				set trr_typ 0
			}
			.trr.1.ll config -text "Frequency"
			.trr.1.e  config -bd 2 -state normal
			if {[info exists trr_last_frq]} {
				set trr_frq $trr_last_frq 
			}
		}
		2 {
			if {!$couldbevib} {
				Inf "Input Data Is Not Vibrato Data"
				set trr_typ 0
			}
			.trr.1.ll config -text "Frequency"
			.trr.1.e  config -bd 2 -state normal
			if {[info exists trr_last_frq]} {
				set trr_frq $trr_last_frq 
			}
		}
		3 {
			if {!$couldbeacc} {
				Inf "Input Data Is Not Acceleration Data"
				set trr_typ 0
			}
			set trr_last_frq $trr_frq
			set trr_frq ""
			.trr.1.ll config -text ""
			.trr.1.e  config -bd 0 -disabledbackground [option get . background {}] -state disabled
		}
	}
}

proc SynthByTremolo {srcfile typ frq dur tremvals tremfile} {
	global evv CDPidrun prg_dun prg_abortd simple_program_messages pa evv last_outfile accdown

	if {$accdown} {
		set tremvals [ReverseList $tremvals]
	}

	;#	SET UP OUTFILE NAMES

	set outfnambas [file rootname [file tail $srcfile]]
	set tremnam [file rootname [file tail $tremfile]]

	set frnam ""
	set len [string length $frq]
	set n 0
	while {$n < $len} {
		set c [string index $frq $n]
		if {[string match $c "."]} {
			append frnam "p"
		} else {
			append frnam $c
		}
		incr n
	}
	foreach val $tremvals {
		set vnam ""
		set len [string length $val]
		set n 0
		while {$n < $len} {
			set c [string index $val $n]
			if {[string match $c "."]} {
				append vnam "p"
			} else {
				append vnam $c
			}
			incr n
		}
		set ofnam $outfnambas
		switch -- $typ {
			1 {
				append ofnam "_trem_"
			} 
			2 {
				append ofnam "_vib_"
			}
			3 {
				append ofnam "_accel_"
			}
		}
		append ofnam $frnam $tremnam "_" $vnam
		append ofnam $evv(SNDFILE_EXT)
		if {[file exist $ofnam]} {
			Inf "File $ofnam Already Exists : Cannot Proceed"
			return 0
		}
		lappend ofnams $ofnam
	}

	Block "PLEASE WAIT:        PROCESSING FILES"
	set n 1
	foreach val $tremvals ofnam $ofnams {
		switch -- $typ {
			1 {
				set cmd [file join $evv(CDPROGRAM_DIR) tremolo]
				if {$val < 1} {
					lappend cmd tremolo 1 $srcfile $ofnam $frq $val 1 1 
				} else {
					lappend cmd tremolo 1 $srcfile $ofnam $frq 1 1 $val
				}
			}
			2 {
				set cmd [file join $evv(CDPROGRAM_DIR) modify]
				lappend cmd speed 6 $srcfile $ofnam $frq $val
			}
			3 {
				set cmd [file join $evv(CDPROGRAM_DIR) modify]
				lappend cmd speed 5 $srcfile $ofnam $val $dur
			}
		}
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		wm title .blocker "PLEASE WAIT:        PROCESSING FILE $ofnam"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "$CDPidrun : Failed To Process File $ofnam"
			continue
		} else {
 			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			set msg "Failed To Produce Processed File $ofnam"
			set msg [AddSimpleMessages $msg]
			Inf $msg
			continue
		}
		lappend outfnams $ofnam
		incr n
	}
	if {![info exists outfnams]} {
		UnBlock
		return 0
	}
	set outfnams [ReverseList $outfnams]
	foreach ofnam $outfnams {
		FileToWkspace $ofnam 0 0 0 0 1
	}
	set last_outfile $outfnams
	UnBlock
	return 1
}

#---- PITCH

proc GenerateSpectraByPshift {} {

	global chlist evv pa pr_ppsh ppsh_lo ppsh_hi

	set startmsg "Requires Soundfile, And Textfile Of Semitone Transpositions (range -24 To 36).\n"
	set accdown 0

	if {![info exists chlist] || ([llength $chlist] !=2)} {
		Inf $startmsg
		return
	}
	set fnam [lindex $chlist 0]
	if {$pa($fnam,$evv(FTYP)) == $evv(SNDFILE)} {
		set dur $pa($fnam,$evv(DUR))
		set srcfile $fnam
	} else {
		Inf $startmsg
		return
	}
	set fnam [lindex $chlist 1]
	if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)) || ![IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
		Inf $startmsg
		return
	} elseif {($pa($fnam,$evv(MINNUM)) < -24.0) || ($pa($fnam,$evv(MAXNUM)) > 36.0)} {
		Inf $startmsg
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File $fnam"
		return
	}
	set cnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		set OK 1
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {![IsNumeric $item] || ($item < -24.0) || ($item > 36.0)} {
				Inf "Invalid Value ($item) In File $fnam : (Range -24 to 36)"
				set OK 0
				break
			}
			if {$cnt > 0 && ($item <= $lastval)} {
				Inf "Values Do Not Increase At $lastval $item In File $fnam"
				set OK 0
				break
			}
			set lastval $item
			lappend ppshvals $item
			incr cnt
		}
		if {!$OK} {
			break
		}
	}
	set ppshfile $fnam
	close $zit
	if {!$OK} {
		return
	}
	set f .ppsh
	if [Dlg_Create $f "CREATE NEW FILES BY PITCH SHIFTING" "set pr_ppsh 0" -borderwidth $evv(BBDR)] {
		frame $f.0
		button $f.0.ab -text Abandon -width 10 -command "set pr_ppsh 0"
		button $f.0.ok -text Generate -width 10 -command "set pr_ppsh 1"
		pack $f.0.ab -side right
		pack $f.0.ok -side left -padx 4
		pack $f.0 -side top -pady 2 -fill x -expand true
		frame $f.1
		checkbutton $f.1.lo -text "Curtail dur of low pitches" -variable ppsh_lo
		checkbutton $f.1.hi -text "Extend dur of high pitches" -variable ppsh_hi
		pack $f.1.lo $f.1.hi -side left
		pack $f.1 -side top -pady 2
		wm resizable $f 1 1
		bind $f <Return> {set pr_ppsh 1}
		bind $f <Escape> {set pr_ppsh 0}
	}
	set ppsh_lo 0
	set ppsh_hi 0
	set finished 0
	set pr_ppsh 0
	raise $f
	My_Grab 0 $f pr_ppsh
	while {!$finished} {
		tkwait variable pr_ppsh
		if {$pr_ppsh} {
			if {![SynthByPshift $srcfile $ppshfile $dur $ppsh_lo $ppsh_hi $ppshvals]} {
				DeleteAllTemporaryFiles
				continue
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc SynthByPshift {srcfile ppshfile dur locurtail hiextend vals} {
	global evv CDPidrun prg_dun prg_abortd simple_program_messages pa evv last_outfile

	if {$locurtail} {

		#	GET ENVELOPE OF ORIGINAL SOUND

		set evnam $evv(DFLT_OUTNAME)
		append evnam 00 $evv(TEXT_EXT)
		set evnnam $evv(DFLT_OUTNAME)
		append evnnam 000 $evv(TEXT_EXT)
		set evdnam $evv(DFLT_OUTNAME)
		append evdnam 000 $evv(SNDFILE_EXT)
		set cmd [file join $evv(CDPROGRAM_DIR) envel]
		lappend cmd extract 2 $srcfile $evnam 5 -d0
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		Block "PLEASE WAIT:        EXTRACTING SOURCE ENVELOPE"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "$CDPidrun : Failed To Extract Source Envelope"
			UnBlock			
			return 0
   		} else {
 			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun || ![file exists $evnam]} {
			set msg "Failed To Do Extract Envelope Of Source"
			set msg [AddSimpleMessages $msg]
			Inf $msg
			UnBlock
			return 0
		}
		if [catch {open $evnam "r"} zit] {
			Inf "Cannot Open Temporary Source-envelope File $evnam"
			UnBlock			
			return 0
		}
		;#	NORMALISE IT

		set maxval 0
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			set line [split $line]
			set OK 1
			set cnt 0
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				if {$cnt == 1} {
					if {$item > $maxval} {
						set maxval $item
					}
				}
				lappend oldvals $item
				incr cnt
			}
		}
		close $zit
		UnBlock			
		set evals $oldvals

		if {$maxval <= 0.0} {
			Inf "Source File Is Silent : Cannot Proceed"
			DeleteAllTemporaryFiles
			return 0
		}
		set norm [expr 1.0/$maxval]
		set nuvals {}
		foreach {time val} $oldvals {
			set val [expr $val * $norm]
			lappend nuvals $time $val
		}
		set envals $nuvals
		set origmaxval $maxval
	}

	;#	SET UP OUTFILE NAMES

	set outfnambas [file rootname [file tail $srcfile]]
	set ppshnam [file rootname [file tail $ppshfile]]
	append outfnambas "_ps_" $ppshnam "_"

	set m 1
	foreach val $vals {
		set vnam ""
		set len [string length $val]
		set n 0
		while {$n < $len} {
			set c [string index $val $n]
			if {$n == 0} {
				if {[string match $c "-"]} {
					append vnam "dn"
					incr n
					continue
				} else {
					append vnam "up"
				}
			}
			if {[string match $c "."]} {
				append vnam "p"
			} else {
				append vnam $c
			}
			incr n
		}
		if {$locurtail && ($val < 0)} {
			append vnam "_" locut
		}
		if {$hiextend && ($val >= 1)} {
			append vnam "_" hiext
		}
		set ofnam $outfnambas
		append ofnam $vnam $evv(SNDFILE_EXT)
		if {[file exist $ofnam]} {
			Inf "File $ofnam Already Exists : Cannot Proceed"
			return 0
		}
		lappend ofnams $ofnam
		set tempofnam $evv(DFLT_OUTNAME)
		append tempofnam $m $evv(SNDFILE_EXT)
		lappend tempofnams $tempofnam 
		set tempofnam $evv(MACH_OUTFNAME)
		append tempofnam $m $evv(SNDFILE_EXT)
		lappend otherfnams $tempofnam 
		incr m
	}
	foreach val $vals {
		set tempofnam $evv(MACH_OUTFNAME)
		append tempofnam $m $evv(SNDFILE_EXT)
		lappend furtherfnams $tempofnam 
		incr m
	}

	Block "PLEASE WAIT:        PROCESSING FILES"
	set n 1
	foreach val $vals ofnam $tempofnams {
		set cmd [file join $evv(CDPROGRAM_DIR) modify]
		lappend cmd speed 2 $srcfile $ofnam $val
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		wm title .blocker "PLEASE WAIT:        PROCESSING FILE $ofnam"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "$CDPidrun : Failed To Process File $ofnam"
			UnBlock 
			return 0
		} else {
 			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun || ![file exists $ofnam]} {
			set msg "Failed To Produce Processed File $ofnam"
			set msg [AddSimpleMessages $msg]
			Inf $msg
			UnBlock 
			return 0
		}
		incr n
	}
	if {$locurtail || $hiextend} {
		if {$locurtail} {
			set n 1
			foreach val $vals tempofnam $tempofnams otherfnam $otherfnams {
				if {$val < 0} {
					catch {unset thisevals}										;#	Deduce envelope of t-stretched sound (thisevals)
					set tratio [expr -$val/double($evv(SEMITONES_PER_OCTAVE))]
					set tratio [expr pow(2.0,$tratio)]
					foreach {time eval} $evals {
						set time [expr $time * $tratio]
						lappend thisevals $time $eval
					}
					set beforetim [lindex $thisevals 0]
					set beforeval [lindex $thisevals 1]
					catch {unset thatevals}
					foreach {time eval} $envals {								;#	At each time in normalised envelope of src
						foreach {thistime thisval} $thisevals {					;#	Find corresponding value (thisval) in thisevals
							if {$thistime > $time} {
								set aftertim $thistime
								set afterval $thisval
								break
							} else {
								set beforetim $thistime
								set beforeval $thisval
							}
						}
						set timdiff [expr $aftertim - $beforetim]
						set valdiff [expr $afterval - $beforeval]
						set tratio  [expr ($time - $beforetim)/$timdiff]
						set vstep	[expr $valdiff * $tratio]
						set thisval	[expr $beforeval + $vstep]  
						lappend thatevals $time $thisval						;#	Deduce loudness envelope of output sound
					}
					set maxval 0.0
					foreach {time eval} $thatevals {								;#	Deduce max loudness in output
						if {$eval > $maxval} {
							set maxval $eval
						}
					}
					set norm [expr $origmaxval/$maxval]							;#	Adjust normalisation envelope
					catch {unset thisevals}		
					foreach {time eval} $envals {								;#	so predicted max output of sound is same as max in src
						set eval [expr $eval * $norm]
						set eval [NotExponential $eval]
						lappend thisevals $time $eval
					}
					if {$n > 1} {
						if [catch {file delete $evnnam} zit] {
							Inf "Cannot Delete Temporary File $evnam To Write New Adjusted Envelope"
							DeleteAllTemporaryFiles
							return 0
						}
					}		
					if [catch {open $evnnam "w"} zit] {
						Inf "Cannot Open Temporary File $evnam To Write Adjusted Envelope"
						DeleteAllTemporaryFiles
						return 0
					}
					foreach {time eval} $thisevals {
						set line [list $time $eval]
						puts $zit $line
					}
					close $zit
					if {[file exists $evdnam] && [catch {file delete $evdnam} zit]} {
						Inf "Failed To Delete Intermediate Temporary File $evdnam"
						DeleteAllTemporaryFiles
						UnBlock 
						return 0
					}
					set cmd [file join $evv(CDPROGRAM_DIR) envel]
					lappend cmd impose 3 $tempofnam $evnnam $evdnam 
					set CDPidrun 0
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					wm title .blocker "PLEASE WAIT:        ENVELOPING FILE $n"
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "$CDPidrun : Failed To Envelope File $n"
						UnBlock 
						return 0
					} else {
 						fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
					}
					vwait prg_dun
					if {$prg_abortd} {
						set prg_dun 0
					}
					if {!$prg_dun || ![file exists $evdnam]} {
						set msg "Failed To Produce Enveloped File $n"
						set msg [AddSimpleMessages $msg]
						Inf $msg
						UnBlock 
						return 0
					}
					set cmd [file join $evv(CDPROGRAM_DIR) sfedit]
					lappend cmd cut 1 $evdnam $otherfnam 0 $dur -w5
					set CDPidrun 0
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					wm title .blocker "PLEASE WAIT:        CURTAILING FILE $n"
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "$CDPidrun : Failed To Curtail File $ofnam"
						UnBlock 
						return 0
					} else {
 						fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
					}
					vwait prg_dun
					if {$prg_abortd} {
						set prg_dun 0
					}
					if {!$prg_dun || ![file exists $otherfnam]} {
						set msg "Failed To Produce Curtailed File $n"
						set msg [AddSimpleMessages $msg]
						Inf $msg
						UnBlock 
						return 0
					}
				} else {
					if [catch {file rename $tempofnam $otherfnam} zit] {
						Inf "Failed To Rename File $n"
						UnBlock 
						return 0
					}
				}
				lappend outfnams $otherfnam
				incr n
			}
		} else {
			set outfnams $tempofnams
		}
		if {$hiextend} {

			;#	REVERBS EXTENDING SOUND TO ORIG DURATION
			set echos [list 0 12 22 33 41 50 59 67 73 80 87 93 99 104 109 113 127 131 133 137 141 144 147 147 147 147 147 147 147 147 147 147 147 147 147 147 147 ]

			set n 1
			foreach val $vals tempofnam $outfnams furofnam $furtherfnams ofnam $ofnams  {
				if {$val >= 1} { 
					set val [expr int(floor($val))]
					set echo [lindex $echos $val]
					set cmd [file join $evv(CDPROGRAM_DIR) modify]
					lappend cmd revecho 3 $tempofnam $furofnam -g1 -r1 -s.1 -e$echo -n
					set CDPidrun 0
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					wm title .blocker "PLEASE WAIT:        EXTENDING FILE $n"
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "$CDPidrun : Failed To Extend File $ofnam"
						UnBlock 
						return 0
					} else {
 						fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
					}
					vwait prg_dun
					if {$prg_abortd} {
						set prg_dun 0
					}
					if {!$prg_dun || ![file exists $furofnam]} {
						set msg "Failed To Produce Extended File $n"
						set msg [AddSimpleMessages $msg]
						Inf $msg
						UnBlock 
						return 0
					}
					set cmd [file join $evv(CDPROGRAM_DIR) housekeep]
					lappend cmd chans 4 $furofnam $ofnam
					set CDPidrun 0
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					wm title .blocker "PLEASE WAIT:        CONVERTING FILE $ofnam TO MONO"
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "$CDPidrun : Failed To Convert File $ofnam To Mono"
						UnBlock 
						return 0
					} else {
 						fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
					}
					vwait prg_dun
					if {$prg_abortd} {
						set prg_dun 0
					}
					if {!$prg_dun || ![file exists $ofnam]} {
						set msg "Failed To Produce Mono File $ofnam"
						set msg [AddSimpleMessages $msg]
						Inf $msg
						UnBlock 
						return 0
					}
				} else {
					if [catch {file rename $tempofnam $ofnam} zit] {
						Inf "Failed To Rename File $ofnam"
						UnBlock 
						return 0
					}
				}
				incr n
			}
			set outfnams $ofnams
		} else {
			foreach tempofnam $outfnams ofnam $ofnams {
				if [catch {file rename $tempofnam $ofnam} zit] {
					Inf "Failed To Rename File $ofnam"
					UnBlock 
					return 0
				}
			}
			set outfnams $ofnams
		}
	} else {
		foreach tempofnam $tempofnams ofnam $ofnams {
			if [catch {file rename $tempofnam $ofnam} zit] {
				Inf "Failed To Rename File $ofnam"
				UnBlock 
				return 0
			}
		}
		set outfnams $ofnams
	}

	set outfnams [ReverseList $outfnams]
	foreach ofnam $outfnams {
		FileToWkspace $ofnam 0 0 0 0 1
	}
	set last_outfile $outfnams
	UnBlock
	return 1
}

#---- PITCHES OF SET

proc GenerateSpectraByPshiftSet {} {

	global chlist evv pa pr_ppse ppse_ex ppse_tt ppse_goal

	set startmsg "Requires List Of Soundfiles.\n"
	set accdown 0

	if {![info exists chlist] || ([llength $chlist] < 2)} {
		Inf $startmsg
		return
	}
	foreach fnam $chlist {
		if {$pa($fnam,$evv(FTYP)) == $evv(SNDFILE)} {
			lappend durs $pa($fnam,$evv(DUR))
		} else {
			Inf $startmsg
			return
		}
		lappend fnams $fnam
	}
	set f .ppse
	if [Dlg_Create $f "CREATE NEW SND SET BY PITCH SHIFTING" "set pr_ppse 0" -borderwidth $evv(BBDR)] {
		frame $f.0
		button $f.0.ab -text Abandon -width 10 -command "set pr_ppse 0"
		button $f.0.ok -text Generate -width 10 -command "set pr_ppse 1"
		pack $f.0.ab -side right
		pack $f.0.ok -side left -padx 4
		pack $f.0 -side top -pady 2 -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Goal transposition"
		entry $f.1.e -textvariable ppse_goal -width 8
		pack $f.1.e $f.1.ll -side left
		pack $f.1 -side top -pady 2
		frame $f.2
		checkbutton $f.2.ex -text "Curtail or extend pitch durations" -variable ppse_ex
		pack $f.2.ex -side left
		pack $f.2 -side top -pady 2
		frame $f.3
		checkbutton $f.3.tt -text "Tempered pitches only" -variable ppse_tt
		pack $f.3.tt -side left
		pack $f.3 -side top -pady 2
		wm resizable $f 1 1
		bind $f <Return> {set pr_ppse 1}
		bind $f <Escape> {set pr_ppse 0}
	}
	set ppse_lo 0
	set ppse_hi 0
	set finished 0
	set pr_ppse 0
	raise $f
	My_Grab 0 $f pr_ppse
	while {!$finished} {
		tkwait variable pr_ppse
		if {$pr_ppse} {
			if {![SynthByPshiftSet $ppse_goal $ppse_ex $ppse_tt $fnams $durs]} {
				DeleteAllTemporaryFiles
				continue
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc SynthByPshiftSet {goal ppse_ex tempered srcfiles durs} {
	global evv CDPidrun prg_dun prg_abortd simple_program_messages pa evv last_outfile

	set evnam $evv(DFLT_OUTNAME)
	append evnam 00 $evv(TEXT_EXT)
	set evnnam $evv(DFLT_OUTNAME)
	append evnnam 000 $evv(TEXT_EXT)
	set evdnam $evv(DFLT_OUTNAME)
	append evdnam 000 $evv(SNDFILE_EXT)

	;#	SET UP OUTFILE NAMES

	set len [llength $srcfiles]
	set transstep [expr double($goal)/double($len)]
	set thistrans 0

	set locurtail 0
	set hiextend 0
	if {$ppse_ex} {
		if {$goal < 0.0} {
			set locurtail 1
		} else {
			set hiextend 1
		}
	}
	set m 1
	foreach fnam $srcfiles {
		if {$m == $len} {
			set thistrans $goal
		} else { 
			set thistrans [expr $thistrans + $transstep]
		}
		if {$thistrans  < 0} {
			set trans [string range $thistrans 1 end]
			set neg 1
		} else {
			set trans $thistrans
			set neg 0
		}
		if {$tempered} {
			set trnam [expr int(round($trans))]
		} else {
			set allzeros 1
			set gotpoint -1
			set trnam ""
			set len [string length $trans]
			set n 0
			while {$n < $len} {
				set c [string index $trans $n]
				if {[string match $c "."]} {
					append trnam "p"
					set gotpoint $n
				} else {
					append trnam $c
					if {($gotpoint >= 0) && ![string match $c 0]} {
						set allzeros 0
					}
				}
				incr n
			}
			if {($trans != 0.0) && $allzeros} {
				set trnam [string range $trnam 0 [expr $gotpoint - 1]]
			}
		}
		if {$neg} {
			append trnam "dn"
		} else {
			append trnam "up"
		}
		set ofnam [file rootname [file tail $fnam]]
		append ofnam "_pps_" $trnam
		if {$locurtail && ($thistrans < 0)} {
			append ofnam "_" locut
		}
		if {$hiextend && ($thistrans >= 1)} {
			append ofnam "_" hiext
		}
		append ofnam $evv(SNDFILE_EXT)
		if {[file exist $ofnam]} {
			Inf "File $ofnam Already Exists : Cannot Proceed"
			return 0
		}
		lappend ofnams $ofnam
		set tempofnam $evv(DFLT_OUTNAME)
		append tempofnam $m $evv(SNDFILE_EXT)
		lappend tempofnams $tempofnam 
		set tempofnam $evv(MACH_OUTFNAME)
		append tempofnam $m $evv(SNDFILE_EXT)
		lappend otherfnams $tempofnam 
		lappend vals $thistrans
		incr m
	}
	foreach val $vals {
		set tempofnam $evv(MACH_OUTFNAME)
		append tempofnam $m $evv(SNDFILE_EXT)
		lappend furtherfnams $tempofnam 
		incr m
	}

	Block "PLEASE WAIT:        PROCESSING FILES"
	set n 1
	foreach val $vals srcfile $srcfiles ofnam $tempofnams {
		set cmd [file join $evv(CDPROGRAM_DIR) modify]
		lappend cmd speed 2 $srcfile $ofnam $val
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		wm title .blocker "PLEASE WAIT:        PROCESSING FILE $ofnam"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "$CDPidrun : Failed To Process File $ofnam"
			UnBlock 
			return 0
		} else {
 			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun || ![file exists $ofnam]} {
			set msg "Failed To Produce Processed File $ofnam"
			set msg [AddSimpleMessages $msg]
			Inf $msg
			UnBlock 
			return 0
		}
		incr n
	}
	if {$locurtail || $hiextend} {
		if {$locurtail} {
			set n 1
			foreach val $vals srcfile $srcfiles tempofnam $tempofnams otherfnam $otherfnams dur $durs {
				if {$val < 0} { 

				#	FIND ENVELOPE OF SOURCE (evals TO FILE evnam) AND NORMALISE (envals)

					if {[file exists $evnam] && [catch {file delete $evnam} zit]} {
						Inf "Cannot Delete Temporary Source-envelope File $evnam"
						DeleteAllTemporaryFilesExcept $evnam
						UnBlock			
						return 0
					}
					set cmd [file join $evv(CDPROGRAM_DIR) envel]
					lappend cmd extract 2 $srcfile $evnam 5 -d0
					set CDPidrun 0
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					wm title .blocker "PLEASE WAIT:        EXTRACTING SOURCE ENVELOPE"
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "$CDPidrun : Failed To Extract Source Envelope"
						DeleteAllTemporaryFiles
						UnBlock			
						return 0
   					} else {
 						fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
					}
					vwait prg_dun
					if {$prg_abortd} {
						set prg_dun 0
					}
					if {!$prg_dun || ![file exists $evnam]} {
						set msg "Failed To Do Extract Envelope Of Source"
						set msg [AddSimpleMessages $msg]
						Inf $msg
						DeleteAllTemporaryFiles
						UnBlock
						return 0
					}

				;#	NORMALISE SRC-ENVELOPE AND NOTE MAXVAL

					if [catch {open $evnam "r"} zit] {
						Inf "Cannot Open Temporary Source-envelope File $evnam"
						DeleteAllTemporaryFiles
						UnBlock			
						return 0
					}
					set maxval 0
					set oldvals {}
					while {[gets $zit line] >= 0} {
						set line [string trim $line]
						if {[string length $line] <= 0} {
							continue
						}
						set line [split $line]
						set OK 1
						set cnt 0
						foreach item $line {
							set item [string trim $item]
							if {[string length $item] <= 0} {
								continue
							}
							if {$cnt == 1} {
								if {$item > $maxval} {
									set maxval $item
								}
							}
							lappend oldvals $item
							incr cnt
						}
					}
					close $zit
					set evals $oldvals

					if {$maxval <= 0.0} {
						Inf "Source File [file rootname[file tail $srcfile]] Is Silent : Cannot Proceed"
						DeleteAllTemporaryFiles
						UnBlock			
						return 0
					}
					set norm [expr 1.0/$maxval]
					set nuvals {}
					foreach {time val} $oldvals {
						set val [expr $val * $norm]
						lappend nuvals $time $val
					}
					set envals $nuvals
					set origmaxval $maxval

			;#	CALCULATE NEW ENVELOPE AND STORE IN FILE evnnam : NB "val" here is number of semitones DOWN

					catch {unset thisevals}
					catch {unset thatevals}
					set tratio [expr $val/double($evv(SEMITONES_PER_OCTAVE))]
					set tratio [expr pow(2.0,$tratio)]
					foreach {time eval} $evals {
						set time [expr $time * $tratio]
						lappend thisevals $time $eval
					}
					set beforetim [lindex $thisevals 0]
					set beforeval [lindex $thisevals 1]
					foreach {time eval} $envals {								;#	At each time in normalised envelope of src
						foreach {thistime thisval} $thisevals {					;#	Find corresponding value (thisval) in thisevals
							if {$thistime > $time} {
								set aftertim $thistime
								set afterval $thisval
								break
							} else {
								set beforetim $thistime
								set beforeval $thisval
							}
						}
						set timdiff [expr $aftertim - $beforetim]
						set valdiff [expr $afterval - $beforeval]
						set tratio  [expr ($time - $beforetim)/$timdiff]
						set vstep	[expr $valdiff * $tratio]
						set thisval	[expr $beforeval + $vstep]  
						lappend thatevals $time $thisval						;#	Deduce loudness envelope of output sound
					}
					set maxval 0.0
					foreach {time eval} $thatevals {								;#	Deduce max loudness in output
						if {$eval > $maxval} {
							set maxval $eval
						}
					}
					if {$maxval == 0.0} {
						Inf "$val Semitones Adjusted File Is At Zero Level During Preserved Segment : Cannot Proceed"
						DeleteAllTemporaryFiles
						UnBlock			
						return 0
					}
					set norm [expr $origmaxval/$maxval]							;#	Adjust normalisation envelope
					catch {unset thisevals}		
					foreach {time eval} $envals {								;#	so predicted max output of sound is same as max in src
						set eval [expr $eval * $norm]
						set eval [NotExponential $eval]
						lappend thisevals $time $eval
					}
					if {$n > 1} {
						if [catch {file delete $evnnam} zit] {
							Inf "Cannot Delete Temporary File $evnam To Write New Adjusted Envelope"
							DeleteAllTemporaryFiles
							return 0
						}
					}		
					if [catch {open $evnnam "w"} zit] {
						Inf "Cannot Open Temporary File $evnam To Write Adjusted Envelope"
						DeleteAllTemporaryFiles
						return 0
					}
					foreach {time eval} $thisevals {
						set line [list $time $eval]
						puts $zit $line
					}
					close $zit

			;#	ENVELOPE THE OUTPUT WITH THE NEW ENVELOPE

					if {[file exists $evdnam] && [catch {file delete $evdnam} zit]} {
						Inf "Cannot Delete Temporary Enveloped Sound $evdnam"
						DeleteAllTemporaryFiles
						UnBlock
						return 0
					}
					set cmd [file join $evv(CDPROGRAM_DIR) envel]
					lappend cmd impose 3 $tempofnam $evnnam $evdnam 
					set CDPidrun 0
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					wm title .blocker "PLEASE WAIT:        CURTAILING FILE $n"
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "$CDPidrun : Failed To Curtail File $n"
						UnBlock 
						return 0
					} else {
 						fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
					}
					vwait prg_dun
					if {$prg_abortd} {
						set prg_dun 0
					}
					if {!$prg_dun || ![file exists $evdnam]} {
						set msg "Failed To Produce Curtailed File $n"
						set msg [AddSimpleMessages $msg]
						Inf $msg
						UnBlock 
						return 0
					}

			;#	CURTAIL THE OUTPUT

					set cmd [file join $evv(CDPROGRAM_DIR) sfedit]
					lappend cmd cut 1 $evdnam $otherfnam 0 $dur -w5
					set CDPidrun 0
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					wm title .blocker "PLEASE WAIT:        CURTAILING FILE $n"
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "$CDPidrun : Failed To Curtail File $n"
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
						set msg "Failed To Produce Curtailed File $n"
						set msg [AddSimpleMessages $msg]
						Inf $msg
						UnBlock 
						return 0
					}
				} else {
					if [catch {file rename $tempofnam $otherfnam} zit] {
						Inf "Failed To Rename File $n"
						UnBlock 
						return 0
					}
				}
				lappend outfnams $otherfnam
				incr n
			}
		} else {
			set outfnams $tempofnams
		}
		if {$hiextend} {

			;#	REVERBS EXTENDING SOUND TO ORIG DURATION
			set echos [list 0 12 22 33 41 50 59 67 73 80 87 93 99 104 109 113 127 131 133 137 141 144 \
				147 147 147 147 147 147 147 147 147 147 147 147 147 147 147 147 147 147 147 147 147 147 \
				147 147 147 147 147 147 147 147 147 147 147 147 147 147 147 147 147 147 147 147 147 147 147 ]

			set n 1
			foreach val $vals tempofnam $outfnams furofnam $furtherfnams ofnam $ofnams  {
				if {$val >= 1} { 
					set val [expr int(floor($val))]
					set echo [lindex $echos $val]
					set cmd [file join $evv(CDPROGRAM_DIR) modify]
					lappend cmd revecho 3 $tempofnam $furofnam -g1 -r1 -s.1 -e$echo -n
					set CDPidrun 0
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					wm title .blocker "PLEASE WAIT:        EXTENDING FILE $n"
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "$CDPidrun : Failed To Extend File $ofnam"
						UnBlock 
						return 0
					} else {
 						fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
					}
					vwait prg_dun
					if {$prg_abortd} {
						set prg_dun 0
					}
					if {!$prg_dun || ![file exists $furofnam]} {
						set msg "Failed To Produce Extended File $n"
						set msg [AddSimpleMessages $msg]
						Inf $msg
						UnBlock 
						return 0
					}
					set cmd [file join $evv(CDPROGRAM_DIR) housekeep]
					lappend cmd chans 4 $furofnam $ofnam
					set CDPidrun 0
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					wm title .blocker "PLEASE WAIT:        CONVERTING FILE $ofnam TO MONO"
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "$CDPidrun : Failed To Convert File $ofnam To Mono"
						UnBlock 
						return 0
					} else {
 						fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
					}
					vwait prg_dun
					if {$prg_abortd} {
						set prg_dun 0
					}
					if {!$prg_dun || ![file exists $ofnam]} {
						set msg "Failed To Produce Mono File $ofnam"
						set msg [AddSimpleMessages $msg]
						Inf $msg
						UnBlock 
						return 0
					}
				} else {
					if [catch {file rename $tempofnam $ofnam} zit] {
						Inf "Failed To Rename File $ofnam"
						UnBlock 
						return 0
					}
				}
				incr n
			}
			set outfnams $ofnams
		} else {
			foreach tempofnam $outfnams ofnam $ofnams {
				if [catch {file rename $tempofnam $ofnam} zit] {
					Inf "Failed To Rename File $ofnam"
					UnBlock 
					return 0
				}
			}
			set outfnams $ofnams
		}
	} else {
		foreach tempofnam $tempofnams ofnam $ofnams {
			if [catch {file rename $tempofnam $ofnam} zit] {
				Inf "Failed To Rename File $ofnam"
				UnBlock 
				return 0
			}
		}
		set outfnams $ofnams
	}

	set outfnams [ReverseList $outfnams]
	foreach ofnam $outfnams {
		FileToWkspace $ofnam 0 0 0 0 1
	}
	set last_outfile $outfnams
	UnBlock
	return 1
}

#---- OctShift

proc GenerateSpectraByOct {} {

	global chlist evv pa pr_shoct shoct_atk sn_prm1 shoct_typ

	set startmsg "Requires A Mono Soundfile And A Texfile Of Interpolation Values.\n"

	set sn_prm1 0

	set fnam [lindex $chlist 0]
	if {($pa($fnam,$evv(FTYP)) == $evv(SNDFILE)) && ($pa($fnam,$evv(CHANS)) == 1)} {
		set dur $pa($fnam,$evv(DUR))
		set srcfile $fnam
	} else {
		Inf $startmsg
		return
	}
	set fnam [lindex $chlist 1]
	if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)) || ![IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
		Inf $startmsg
		return
	} elseif {($pa($fnam,$evv(MINNUM)) <= 0.0) || ($pa($fnam,$evv(MAXNUM)) >= 1.0)} {
		Inf $startmsg
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File $fnam"
		return
	}
	set cnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		set OK 1
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {![IsNumeric $item] || ($item < -24.0) || ($item > 24.0)} {
				Inf "Invalid Value ($item) In File $fnam : (Range -24 to 24)"
				set OK 0
				break
			}
			if {$cnt > 0 && ($item <= $lastval)} {
				Inf "Values Do Not Increase At $lastval $item In File $fnam"
				set OK 0
				break
			}
			set lastval $item
			lappend interpvals $item
			incr cnt
		}
		if {!$OK} {
			break
		}
	}
	set interpfnam $fnam
	close $zit
	if {!$OK} {
		return
	}
	set f .shoct
	if [Dlg_Create $f "CREATE NEW SNDS BY INTERPOLATING TO OCTAVE" "set pr_shoct 0" -borderwidth $evv(BBDR)] {
		frame $f.0
		button $f.0.ab -text Abandon -width 10 -command "set pr_shoct 0"
		button $f.0.sv -text "Sound View" -width 10 -command "GetAtkTime 2" -bg $evv(SNCOLOR)
		button $f.0.ok -text Generate -width 10 -command "set pr_shoct 1"
		pack $f.0.ab -side right
		pack $f.0.ok $f.0.sv -side left -padx 4
		pack $f.0 -side top -pady 2 -fill x -expand true
		frame $f.1
		radiobutton $f.1.up -variable shoct_typ -text Up -value 0
		radiobutton $f.1.dn -variable shoct_typ -text Down -value 1
		set shoct_typ 0
		pack $f.1.up $f.1.dn -side left
		pack $f.1 -side top -pady 2
		frame $f.2
		label $f.2.ll -text "Attack Time"
		entry $f.2.e -textvariable shoct_atk -width 8
		pack $f.2.e $f.2.ll -side left
		pack $f.2 -side top -pady 2
		wm resizable $f 1 1
		bind $f <Return> {set pr_shoct 1}
		bind $f <Escape> {set pr_shoct 0}
	}
	set finished 0
	set pr_shoct 0
	raise $f
	My_Grab 0 $f pr_shoct
	while {!$finished} {
		tkwait variable pr_shoct
		if {$pr_shoct} {
			if {([string length $shoct_atk] <= 0) || ![IsNumeric $shoct_atk] || ($shoct_atk < 0.0) || ($shoct_atk >= $dur)} {
				Inf "Invalid Attack-time Value (range 0 to < src duration $dur)"
				continue
			}
			if {![SynthByOct $srcfile $shoct_typ $dur $shoct_atk $interpfnam $interpvals]
			} {
				DeleteAllTemporaryFiles
				continue
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc SynthByOct {srcfile down dur atk interpfnam interpvals} {
	global evv pa CDPidrun prg_dun prg_abortd simple_program_messages

	set tempofnam0 $evv(DFLT_OUTNAME)
	append tempofnam0 0 $evv(SNDFILE_EXT)
	set tempofnam1 $evv(DFLT_OUTNAME)
	append tempofnam1 1 $evv(SNDFILE_EXT)
	set tempofnam2 $evv(DFLT_OUTNAME)
	append tempofnam2 2 $evv(SNDFILE_EXT)
	set tempofnam3 $evv(DFLT_OUTNAME)
	append tempofnam3 3 $evv(SNDFILE_EXT)
	set tempinterpnam $evv(MACH_OUTFNAME)

	set ofbasnam [file rootname [file tail $srcfile]]
	set itpnam [file rootname [file tail $interpfnam]]
	append ofbasnam "_o"
	if {$down} {
		append ofbasnam dn_
	} else {
		append ofbasnam up_
	}
	append ofbasnam $itpnam "_"

	foreach val $interpvals {
		set vnam ""
		set len [string length $val]
		set n 0
		while {$n < $len} {
			set c [string index $val $n]
			if {[string match $c "."]} {
				append vnam "p"
			} else {
				append vnam $c
			}
			incr n
		}
		set ofnam $ofbasnam
		append ofnam $vnam $evv(SNDFILE_EXT)
		if {[file exists $ofnam]} {
			Inf "File $ofnam Already Exists: Cannot Proceed"
			return 0
		} else {
			lappend ofnams $ofnam
		}
	}
	set lastofnam $ofbasnam 
	append lastofnam "12" $evv(SNDFILE_EXT)
	if {[file exists $lastofnam]} {
		Inf "File $lastofnam Already Exists: Cannot Proceed"
		return 0
	}

	Block "PLEASE WAIT:        PROCESSING FILES"

	if {$down} {
		set val -12
	} else {
		set val 12
	}
	set cmd [file join $evv(CDPROGRAM_DIR) modify]
	lappend cmd speed 2 $srcfile $tempofnam0 $val
	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	catch {unset simple_program_messages}
	wm title .blocker "PLEASE WAIT:        TRANSPOSING FILE"
	if [catch {open "|$cmd"} CDPidrun] {
		Inf "$CDPidrun : Failed To Transpose File"
		UnBlock 
		return 0
	} else {
 		fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
	}
	vwait prg_dun
	if {$prg_abortd} {
		set prg_dun 0
	}
	if {!$prg_dun || ![file exists $tempofnam0]} {
		set msg "Failed To Produce Transposed File"
		set msg [AddSimpleMessages $msg]
		Inf $msg
		UnBlock 
		return 0
	}

	if {$down} {

		;#	ATTACK MODIFYING LENGTHENED SOUND

		set cutt [expr $atk/2.0]	
		set win [expr $cutt/2.0]
		set win [expr ($win * 1000) - 0.1]
		if {$win > 5} {
			set win 5
		}
		set cmd [file join $evv(CDPROGRAM_DIR) sfedit]
		lappend cmd excise 1 $tempofnam0 $tempofnam1 0 $cutt -w$win
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		wm title .blocker "PLEASE WAIT:        SHORTENING ATTACK OF SOUND"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "$CDPidrun : Failed To Shorten Attack"
			UnBlock 
			return 0
		} else {
 			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun || ![file exists $tempofnam1]} {
			set msg "Failed To Produce Shortened Attack"
			set msg [AddSimpleMessages $msg]
			Inf $msg
			UnBlock 
			return 0
		}
		;#	SHORTENING TRANSPOSED SOUND

		if {[DoParse $tempofnam1 0 0 0] <= 0} {
			Inf "Cannot Determine Duration Of Atk-Curtailed Source"
			UnBlock 
			return 0
		}
		set thisdur $pa($tempofnam1,$evv(DUR))
		PurgeArray $tempofnam1
		if {$thisdur > $dur} {
			set cmd [file join $evv(CDPROGRAM_DIR) envel]
			lappend cmd curtail 4 $tempofnam1 $tempofnam2 0 $dur -t0
			set CDPidrun 0
			set prg_dun 0
			set prg_abortd 0
			catch {unset simple_program_messages}
			wm title .blocker "PLEASE WAIT:        SHORTENING OCTAVE-SHIFTED FILE"
			if [catch {open "|$cmd"} CDPidrun] {
				Inf "$CDPidrun : Failed To Shorten File"
				UnBlock 
				return 0
			} else {
 				fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
			}
			vwait prg_dun
			if {$prg_abortd} {
				set prg_dun 0
			}
			if {!$prg_dun || ![file exists $tempofnam1]} {
				set msg "Failed To Produce Shortened File"
				set msg [AddSimpleMessages $msg]
				Inf $msg
				UnBlock 
				return 0
			}
		} else {
			if [catch {file rename $tempofnam1 $tempofnam2} zit] {
				Inf "Failure To Rename Intermediate Temporary File"
				UnBlock
				return 0
			}
		}
	} else {

		;#	REVERB EXTEND SOUND TO ORIG DURATION

		set echo 99
		set cmd [file join $evv(CDPROGRAM_DIR) modify]
		lappend cmd revecho 3 $tempofnam0 $tempofnam1 -g1 -r1 -s.1 -e$echo -n
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		wm title .blocker "PLEASE WAIT:        EXTENDING TRANSPOSED FILE"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "$CDPidrun : Failed To Extend Transposed File"
			UnBlock 
			return 0
		} else {
 			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun || ![file exists $tempofnam1]} {
			set msg "Failed To Produce Extended Transposed File"
			set msg [AddSimpleMessages $msg]
			Inf $msg
			UnBlock 
			return 0
		}
		set cmd [file join $evv(CDPROGRAM_DIR) housekeep]
		lappend cmd chans 4 $tempofnam1 $tempofnam2
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		wm title .blocker "PLEASE WAIT:        CONVERTING TRANSPOSED FILE TO MONO"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "$CDPidrun : Failed To Convert Transposed File To Mono"
			UnBlock 
			return 0
		} else {
 			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun || ![file exists $tempofnam2]} {
			set msg "Failed To Produce Mono Version Of Transposed File"
			set msg [AddSimpleMessages $msg]
			Inf $msg
			UnBlock 
			return 0
		}
	}
	set cmd [file join $evv(CDPROGRAM_DIR) submix]
	lappend cmd inbetween 2 $srcfile $tempofnam2 $tempinterpnam $interpfnam
	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	catch {unset simple_program_messages}
	wm title .blocker "PLEASE WAIT:        INTERPOLATING FILES"
	if [catch {open "|$cmd"} CDPidrun] {
		Inf "$CDPidrun : Failed To Interpolate Files"
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
		set msg "Failed To Produce Interpolated Files"
		set msg [AddSimpleMessages $msg]
		Inf $msg
		UnBlock
		return 0
	}
	set n 1
	set len [llength $interpvals]
	while {$n <= $len} {
		if {$n < 10} {
			set nn 00$n
		} elseif {$n < 100} {
			set nn 0$n
		} else {
			set nn $n
		}
		set thisofnam $tempinterpnam
		append thisofnam $nn $evv(SNDFILE_EXT)
		if {![file exists $thisofnam]} {
			Inf "One Or More Of Interpolated Files ($thisofnam) Does Not Exist"
			UnBlock
			return 0
		}
		lappend outfnams $thisofnam
		incr n	
	}
	foreach outfnam $outfnams ofnam $ofnams {
		if [catch {file rename $outfnam $ofnam} zit] {
			Inf "Failed To Rename File $ofnam"
			continue
		} else {
			lappend trueofnams $ofnam
		}
	}
	if [catch {file rename $tempofnam2 $lastofnam} zit] {
		Inf "Failed To Rename File $lastofnam"
	} else {
		lappend trueofnams $lastofnam
	}
	if {![info exists trueofnams]} {
		UnBlock
		return 0
	}
	set trueofnams [ReverseList $trueofnams]
	foreach fnam $trueofnams {
		FileToWkspace $fnam 0 0 0 0 1
	}
	UnBlock
	return 1
}

#--- MIX ORCHESTRAS

proc GenerateSpectraByMixOrc {mergechans} {
	global chlist evv pa CDPidrun prg_dun prg_abortd simple_program_messages
	
	if {$mergechans} {
		set startmsg "Requires 2 Textfiles Listing The Same Number Of Mono Sounds."
	} else {
		set startmsg "Requires 2 Textfiles Listing The Same Number Of Sounds."
	}
	set fnam [lindex $chlist 0]
	if {[IsASndlist $pa($fnam,$evv(FTYP))]} {
		set src1 $fnam
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot Open File $fnam"
			return
		}
		Block "CHECKING SOUND LISTINGS"
		set OK 1
		set icnt 0
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			if {[string match [string index $line 0] ";"]} {
				continue
			}
			set line [split $line]
			set OK 1
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				if {![file exists $item]} {
					Inf "File $item No Longer Exists"
					set OK 0
					break
				}
				if {![info exists pa($item,$evv(FTYP))]} {
					if {[DoParse $item 0 0 0] <= 0} {
						Inf "Cannot Parse File $item"
						set OK 0
						break
					}
				}
				lappend fnams1 $item
				lappend srates $pa($item,$evv(SRATE))
				lappend chancnts $pa($item,$evv(CHANS))
				if {$mergechans && ($pa($item,$evv(CHANS)) != 1)} {
					Inf "Not All Listed Files Are Mono"
					set OK 0
					break
				} 
				incr icnt
			}
			if {!$OK} {
				break
			}
		}
		close $zit
		if {!$OK} {
			UnBlock
			return
		}
	} else {
		Inf $startmsg
		return
	}

	set fnam [lindex $chlist 1]
	if {[IsASndlist $pa($fnam,$evv(FTYP))]} {
		set src2 $fnam
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot Open File $fnam"
			UnBlock
			return
		}
		set cnt 0
		set OK 1
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			if {[string match [string index $line 0] ";"]} {
				continue
			}
			set line [split $line]
			set OK 1
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				if {![file exists $item]} {
					Inf "File $fnam No Longer Exists"
					set OK 0
					break
				}
				if {![info exists pa($item,$evv(FTYP))]} {
					if {[DoParse $item 0 0 0] <= 0} {
						Inf "Cannot Parse File $item"
						set OK 0
						break
					}
				}
				if {$pa($item,$evv(SRATE)) != [lindex $srates $cnt]} {
					Inf "Incompatible Sample Rates In Files [lindex $fnams1 $cnt] And $item"
					set OK 0
					break
				}
				if {$pa($item,$evv(CHANS)) != [lindex $chancnts $cnt]} {
					Inf "Incompatible Channel Counts In Files [lindex $fnams1 $cnt] And $item"
					set OK 0
					break
				}
				lappend fnams2 $item
				incr cnt
			}
			if {!$OK} {
				break
			}
		}
		close $zit
		if {!$OK} {
			UnBlock
			return
		}
	} else {
		Inf $startmsg
		UnBlock
		return
	}
	if {$cnt != $icnt} {
		Inf "Soundlists Do Not Have The Same Number Of Entries"
		UnBlock
		return
	}
	if {$mergechans} {
		set basfnam "mergorcs_"
	} else {
		set basfnam "mixorcs_"
	}
	append basfnam [file rootname [file tail $src1]]
	append basfnam "_" [file rootname [file tail $src2]] "_"
	set n 1
	while {$n <= $cnt} {
		set ofnam $basfnam
		append ofnam $n $evv(SNDFILE_EXT)
		lappend ofnams $ofnam
		incr n
	}
	set n 1
	foreach fnam1 $fnams1 fnam2 $fnams2 ofnam $ofnams {
		set cmd [file join $evv(CDPROGRAM_DIR) submix]
		if {$mergechans} {
			lappend cmd interleave
		} else {
			lappend cmd merge
		}
		lappend cmd $fnam1 $fnam2 $ofnam

		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		wm title .blocker "PLEASE WAIT:        MERGING FILE $ofnam"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "$CDPidrun : Failed To Merge File $ofnam"
			continue
   		} else {
 			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun || ![file exists $ofnam]} {
			set msg "Failed To Do Produce Outfile $ofnam"
			set msg [AddSimpleMessages $msg]
			Inf $msg
			continue
		}
		lappend outfnams $ofnam	
	}
	if {![info exists outfnams]} {
		Inf "No Outputs Produced"
		UnBlock
		return
	}
	set outfnams [ReverseList $outfnams]
	foreach ofnam $outfnams {
		FileToWkspace $ofnam 0 0 0 0 1
	}
	Inf "Files Are On The Workspace"
	UnBlock
	return 1
}

#---- Tstretch

proc GenerateSpectraByTstretch {} {

	global chlist evv pa pr_strr strr_atk sn_prm1

	set startmsg "Requires A Mono Soundfile And A Texfile Listing Tstretches (>1 AND <=64).\n"

	set sn_prm1 0

	if {![info exists chlist] || ([llength $chlist] != 2)} {
		Inf $startmsg
		return
	}
	set fnam [lindex $chlist 0]
	if {($pa($fnam,$evv(FTYP)) == $evv(SNDFILE)) && ($pa($fnam,$evv(CHANS)) == 1)} {
		set dur $pa($fnam,$evv(DUR))
		set srcfile $fnam
	} else {
		Inf $startmsg
		return
	}
	set fnam [lindex $chlist 1]
	if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)) || ![IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
		Inf $startmsg
		return
	} elseif {($pa($fnam,$evv(MINNUM)) <= 1.0) || ($pa($fnam,$evv(MAXNUM)) > 64.0)} {
		Inf $startmsg
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File $fnam"
		return
	}
	set cnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		set OK 1
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {![IsNumeric $item] || ($item <= 1.0) || ($item > 64.0)} {
				Inf "Invalid Value ($item) In File $fnam : (Range >1 to 64)"
				set OK 0
				break
			}
			if {$cnt > 0 && ($item <= $lastval)} {
				Inf "Values Do Not Increase At $lastval $item In File $fnam"
				set OK 0
				break
			}
			set lastval $item
			lappend strvals $item
			incr cnt
		}
		if {!$OK} {
			break
		}
	}
	set strfnam $fnam
	close $zit
	if {!$OK} {
		return
	}
	set f .strr
	if [Dlg_Create $f "CREATE NEW SNDS BY TIME-STRETCHING" "set pr_strr 0" -borderwidth $evv(BBDR)] {
		frame $f.0
		button $f.0.ab -text Abandon -width 10 -command "set pr_strr 0"
		button $f.0.sv -text "Sound View" -width 10 -command "GetAtkTime 3" -bg $evv(SNCOLOR)
		button $f.0.ok -text Generate -width 10 -command "set pr_strr 1"
		pack $f.0.ab -side right
		pack $f.0.ok $f.0.sv -side left -padx 4
		pack $f.0 -side top -pady 2 -fill x -expand true
		frame $f.2
		label $f.2.ll -text "End of Unstretched Attack"
		entry $f.2.e -textvariable strr_atk -width 8
		pack $f.2.e $f.2.ll -side left
		pack $f.2 -side top -pady 2
		wm resizable $f 1 1
		bind $f <Return> {set pr_strr 1}
		bind $f <Escape> {set pr_strr 0}
	}
	set finished 0
	set pr_strr 0
	raise $f
	My_Grab 0 $f pr_strr
	while {!$finished} {
		tkwait variable pr_strr
		if {$pr_strr} {
			if {([string length $strr_atk] <= 0) || ![IsNumeric $strr_atk] || ($strr_atk < 0.0) || ($strr_atk >= $dur)} {
				Inf "Invalid End-of-attack Value (range 0 to < src duration $dur)"
				continue
			}
			if {$dur - $strr_atk < 0.02} {
				Inf "End-of-attack $strr_atk Too Near End Of File ($dur)"
				continue
			}
			if {![SynthByStr $srcfile $dur $strr_atk $strfnam $strvals 0 0]} {
				DeleteAllTemporaryFiles
				continue
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc SynthByStr {srcfile dur atk strfnam strvals eq ts} {
	global evv pa CDPidrun prg_dun prg_abortd simple_program_messages
	global CDPmaxId maxsamp_line done_maxsamp

	set keepatk 1
	if {$atk <= 0} {
		set keepatk 0
	}
	set tempofnam $evv(DFLT_OUTNAME)
;# 2023	
	append tempofnam 0 $evv(ANALFILE_OUT_EXT)
	set analfile $tempofnam
	set n 1
	foreach val $strvals {
		set tempofnam $evv(DFLT_OUTNAME)
;# 2023
		append tempofnam $n $evv(ANALFILE_OUT_EXT)
		lappend tempofnams $tempofnam 
		set tempofnam $evv(DFLT_OUTNAME)
		append tempofnam $n $evv(TEXT_EXT)
		lappend strfiles $tempofnam
		set tempofnam $evv(MACH_OUTFNAME)
		append tempofnam $n $evv(SNDFILE_EXT)
		lappend otherfnams $tempofnam 
		set tempofnam $evv(MACH_OUTFNAME)
		append tempofnam 0 $n $evv(SNDFILE_EXT)
		lappend furtherfnams $tempofnam 
		incr n
	}

	if {$eq} {		;#	GET LEVEL OF SOURCE
		catch {unset CDPmaxId}
		catch {unset maxsamp_line}
		set done_maxsamp 0
		set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
		lappend cmd $srcfile
		lappend cmd 1		;#	1 flag added to FORCE read of maxsample
		if [catch {open "|$cmd"} CDPmaxId] {
			Inf "Finding Maximum Level Of [file rootname [file tail $srcfile]]: Process Failed"
			return 0
		} else {
	   		fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
		}
		vwait done_maxsamp
		if {[info exists maxsamp_line]} {
			set maxsamp [lindex $maxsamp_line 0]
		} else {
			Inf "Failed To Find Maximum Level Of Source File $srcfile"
			return 0
		}
		if {$maxsamp <= 0.0} {
			Inf "Source File Is Silent: Cannot Proceed"
			return 0
		}
		set srclevel $maxsamp
	}
	if {$ts} {
		set minval [lindex $strvals 0]
		foreach val $strvals {
			if {$val < $minval} {
				set minval $val
			}
		}
		set minval [expr $minval * $dur]
		if {$minval <= 0.005} {
			Inf "Smallest Time-altered File Is Too Short For Start Trim"
			return
		}
	}

	set ofbasnam [file rootname [file tail $srcfile]]
	set strnam [file rootname [file tail $strfnam]]
	append ofbasnam "_str_"
	if {$eq} {
		append ofbasnam "e"
	}
	if {$ts} {
		append ofbasnam "t"
	}
	if {$eq || $ts} {
		append ofbasnam "_"
	}
	append ofbasnam $strnam "_"

	;#	MAKE STRETCH BRKPNT FILES, PRESERVING ATK OF SOUND

	if {$keepatk} {
		foreach val $strvals strfile $strfiles {
			catch {unset lines}
			set line [list 0 1]
			lappend lines $line
			set line [list $atk 1]
			lappend lines $line
			set line [list [expr $atk + 0.02] $val]
			lappend lines $line
			set line [list $dur $val]
			lappend lines $line
			if [catch {open $strfile "w"} zit] {
				Inf "Cannot Open Temporary Brkpnt File $strfile"
				return 0
			}
			foreach line $lines {
				puts $zit $line
			}
			close $zit
		}
	}

	;#	MAKE OUTFILE NAMES

	foreach val $strvals {
		set vnam ""
		set len [string length $val]
		set n 0
		while {$n < $len} {
			set c [string index $val $n]
			if {[string match $c "."]} {
				append vnam "p"
			} else {
				append vnam $c
			}
			incr n
		}
		set ofnam $ofbasnam
		append ofnam $vnam $evv(SNDFILE_EXT)
		if {[file exists $ofnam]} {
			Inf "File $ofnam Already Exists: Cannot Proceed"
			return 0
		} else {
			lappend ofnams $ofnam
		}
	}

	Block "PLEASE WAIT:        PROCESSING FILES"

	set cmd [file join $evv(CDPROGRAM_DIR) pvoc]
	lappend cmd anal 1 $srcfile $analfile -c1024 -o3
	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	catch {unset simple_program_messages}
	wm title .blocker "PLEASE WAIT:        ANALYSING FILE"
	if [catch {open "|$cmd"} CDPidrun] {
		Inf "$CDPidrun : Failed To Analyse File"
		UnBlock 
		return 0
	} else {
 		fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
	}
	vwait prg_dun
	if {$prg_abortd} {
		set prg_dun 0
	}
	if {!$prg_dun || ![file exists $analfile]} {
		set msg "Failed To Produce Analysed File"
		set msg [AddSimpleMessages $msg]
		Inf $msg
		UnBlock 
		return 0
	}
	foreach strfile $strfiles val $strvals tempofnam $tempofnams {
		set cmd [file join $evv(CDPROGRAM_DIR) stretch]
		if {$keepatk} {
			lappend cmd time 1 $analfile $tempofnam $strfile
		} else {
			lappend cmd time 1 $analfile $tempofnam $val
		}
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		wm title .blocker "PLEASE WAIT:        STRETCHING SOUND BY $val"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "$CDPidrun : Failed To Stretch Sound By $val"
			UnBlock 
			return 0
		} else {
 			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun || ![file exists $tempofnam]} {
			set msg "Failed To Produce Sound Stretched By $val"
			set msg [AddSimpleMessages $msg]
			Inf $msg
			UnBlock 
			return 0
		}
	}
	if {$eq || $ts} {
		if {$eq && $ts} {
			set outputfnams $otherfnams
		} else {
			set outputfnams $furtherfnams
		}
	} else {
		set outputfnams $ofnams	;#	DIRECTLY TO OUTPUT SND NAMES
	}
	foreach tempofnam $tempofnams outputfnam $outputfnams otherfnam $otherfnams furtherfnam $furtherfnams ofnam $ofnams {
		set cmd [file join $evv(CDPROGRAM_DIR) pvoc]
		lappend cmd synth $tempofnam $outputfnam
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		wm title .blocker "PLEASE WAIT:        RESYNTHING FILE $ofnam"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "$CDPidrun : Failed To Resynth File $ofnam"
			UnBlock 
			return 0
		} else {
 			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun || ![file exists $outputfnam]} {
			set msg "Failed To Produce Resynthed File $ofnam"
			set msg [AddSimpleMessages $msg]
			Inf $msg
			UnBlock 
			return 0
		}
		if {$eq || $ts} {
			if {$ts} {
				set cmd [file join $evv(CDPROGRAM_DIR) envel]
				if {$eq} {
					lappend cmd dovetail 2 $outputfnam $furtherfnam .005 0 -t0
				} else {
					lappend cmd dovetail 2 $outputfnam $ofnam .005 0 -t0
				}
				set CDPidrun 0
				set prg_dun 0
				set prg_abortd 0
				catch {unset simple_program_messages}
				wm title .blocker "PLEASE WAIT:        TRIMMING FILE $ofnam"
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "$CDPidrun : Failed To Trim File $ofnam"
					DeleteAllTemporaryFiles
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
					set msg "Failed To Produce Trimmed File $ofnam"
					set msg [AddSimpleMessages $msg]
					Inf $msg
					DeleteAllTemporaryFiles
					UnBlock 
					return 0
				}
				if {($eq && ![file exists $furtherfnam]) || (!$eq && ![file exists $ofnam])} {
					set msg "Failed To Produce Trimmed File $ofnam"
					set msg [AddSimpleMessages $msg]
					Inf $msg
					DeleteAllTemporaryFiles
					UnBlock 
					return 0
				}
			}
			if {$eq} {
				catch {unset CDPmaxId}
				catch {unset maxsamp_line}
				set done_maxsamp 0
				set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
				if {$ts} {
					lappend cmd $furtherfnam
				} else {
					lappend cmd $outputfnam
				}
				lappend cmd 1		;#	1 flag added to FORCE read of maxsample
				if [catch {open "|$cmd"} CDPmaxId] {
					Inf "Finding Maximum Level Of $ofnam : Process Failed"
					DeleteAllTemporaryFiles
					UnBlock 
					return 0
				} else {
	   				fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
				}
				vwait done_maxsamp
				if {[info exists maxsamp_line]} {
					set maxsamp [lindex $maxsamp_line 0]
				} else {
					Inf "Failed To Find Maximum Level Of File $ofnam"
					DeleteAllTemporaryFiles
					UnBlock 
					return 0
				}
				if {$maxsamp <= 0.0} {
					Inf "Output File $ofnam Is Silent: Cannot Proceed"
					DeleteAllTemporaryFiles
					UnBlock 
					return 0
				}
				set norm [expr $srclevel/$maxsamp]

				set cmd [file join $evv(CDPROGRAM_DIR) modify]
				if {$ts} {
					lappend cmd loudness 1 $furtherfnam $ofnam $norm
				} else {
					lappend cmd loudness 1 $outputfnam $ofnam $norm
				}
				set CDPidrun 0
				set prg_dun 0
				set prg_abortd 0
				catch {unset simple_program_messages}
				wm title .blocker "PLEASE WAIT:        NORMALISING FILE $ofnam"
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "$CDPidrun : Failed To Normalise File $ofnam"
					DeleteAllTemporaryFiles
					UnBlock 
					return 0
				} else {
 					fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				if {!$prg_dun || ![file exists $ofnam]} {
					set msg "Failed To Produce Normalised File $ofnam"
					set msg [AddSimpleMessages $msg]
					Inf $msg
					DeleteAllTemporaryFiles
					UnBlock 
					return 0
				}
			}
			lappend outfnams $ofnam
		} else {
			lappend outfnams $outputfnam
		}
	}
	if {![info exists outfnams]} {
		UnBlock 
		return 0
	}
	set outfnams [ReverseList $outfnams]
	foreach fnam $outfnams {
		FileToWkspace $fnam 0 0 0 0 1
	}
	UnBlock
	return 1
}

#---- Time shrink a sound to produce a set of sounds

proc GenerateSpectraByTshrink {} {

	global chlist evv pa pr_shrr shrr_eq shrr_ts

	set startmsg "Requires A Mono Soundfile And A Texfile Listing Tstretches (<1 And > 0).\n"

	if {![info exists chlist] || ([llength $chlist] != 2)} {
		Inf $startmsg
		return
	}
	set fnam [lindex $chlist 0]
	if {($pa($fnam,$evv(FTYP)) == $evv(SNDFILE)) && ($pa($fnam,$evv(CHANS)) == 1)} {
		set dur $pa($fnam,$evv(DUR))
		set srcfile $fnam
	} else {
		Inf $startmsg
		return
	}
	set fnam [lindex $chlist 1]
	if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)) || ![IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
		Inf $startmsg
		return
	} elseif {($pa($fnam,$evv(MINNUM)) <= 0.0) || ($pa($fnam,$evv(MAXNUM)) >= 1.0)} {
		Inf $startmsg
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File $fnam"
		return
	}
	set cnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		set OK 1
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {![IsNumeric $item] || ($item < 0.0) || ($item >= 1.0)} {
				Inf "Invalid Value ($item) In File $fnam : (Range >0 to <1)"
				set OK 0
				break
			}
			if {$cnt > 0 && ($item >= $lastval)} {
				Inf "Values Do Not Decrease At $lastval $item In File $fnam"
				set OK 0
				break
			}
			set lastval $item
			lappend strvals $item
			incr cnt
		}
		if {!$OK} {
			break
		}
	}
	set strfnam $fnam
	close $zit
	if {!$OK} {
		return
	}
	set f .shrr
	if [Dlg_Create $f "CREATE NEW SNDS BY TIME-SHRINKING" "set pr_shrr 0" -borderwidth $evv(BBDR)] {
		frame $f.0
		button $f.0.ab -text Abandon -width 10 -command "set pr_shrr 0"
		button $f.0.ok -text Generate -width 10 -command "set pr_shrr 1"
		pack $f.0.ab -side right
		pack $f.0.ok -side left -padx 4
		pack $f.0 -side top -pady 2 -fill x -expand true
		frame $f.1
		checkbutton $f.1.eq -text "Equalise Levels" -variable shrr_eq
		checkbutton $f.1.ts -text "Trim start" -variable shrr_ts
		pack $f.1.eq $f.1.ts -side left
		pack $f.1 -side top -pady 2 -fill x -expand true
		wm resizable $f 1 1
		bind $f <Return> {set pr_shrr 1}
		bind $f <Escape> {set pr_shrr 0}
	}
	set shrr_ts 1
	set shrr_eq 1
	set finished 0
	set pr_shrr 0
	raise $f
	My_Grab 0 $f pr_shrr
	while {!$finished} {
		tkwait variable pr_shrr
		if {$pr_shrr} {
			if {![SynthByStr $srcfile $dur 0 $strfnam $strvals $shrr_eq $shrr_ts]} {
				DeleteAllTemporaryFiles
				continue
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- Modify snds by trimming end

proc GenerateSpectraByETrim {} {

	global chlist evv pa pr_trrm trrm_lim trrm_steps sn_prm1 trrm_exp trrm_nnn trrm_crv

	set startmsg "Requires A Mono Soundfile.\n"

	set sn_prm1 0

	if {![info exists chlist] || ([llength $chlist] != 1)} {
		Inf $startmsg
		return
	}

	set fnam [lindex $chlist 0]
	if {($pa($fnam,$evv(FTYP)) == $evv(SNDFILE)) && ($pa($fnam,$evv(CHANS)) == 1)} {
		set dur $pa($fnam,$evv(DUR))
		set srcfile $fnam
	} else {
		Inf $startmsg
		return
	}
	set f .trrm
	if [Dlg_Create $f "CREATE NEW SNDS BY END-TRIMMING SOURCE" "set pr_trrm 0" -borderwidth $evv(BBDR)] {
		frame $f.0
		button $f.0.ab -text Abandon -width 10 -command "set pr_trrm 0"
		button $f.0.sv -text "Sound View" -width 10 -command "GetAtkTime 4" -bg $evv(SNCOLOR)
		button $f.0.ok -text Generate -width 10 -command "set pr_trrm 1"
		pack $f.0.ab -side right
		pack $f.0.ok $f.0.sv -side left -padx 4
		pack $f.0 -side top -pady 2 -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Limit of end-trim"
		entry $f.1.e -textvariable trrm_lim -width 8
		pack $f.1.e $f.1.ll -side left
		pack $f.1 -side top -pady 2 -fill x -expand true
		frame $f.2
		label $f.2.ll -text "Number of trim-steps"
		entry $f.2.e -textvariable trrm_steps -width 8
		pack $f.2.e $f.2.ll -side left
		pack $f.2 -side top -pady 2 -fill x -expand true
		frame $f.3
		label $f.3.ll -text "Curve (1 = equal shortenings : > 1 = shrink be smaller and smaller steps)"
		entry $f.3.e -textvariable trrm_crv -width 8
		pack $f.3.e $f.3.ll -side left
		pack $f.3 -side top -pady 2 -fill x -expand true
		set trrm_crv 1
		frame $f.4
		checkbutton $f.4.ex -text "Exponential fades" -variable trrm_exp
		checkbutton $f.4.nn -text "Equalise levels" -variable trrm_nnn
		pack $f.4.ex $f.4.nn -side left
		pack $f.4 -side top -pady 2
		wm resizable $f 1 1
		bind $f <Return> {set pr_trrm 1}
		bind $f <Escape> {set pr_trrm 0}
	}
	set trrm_lim 0
	set finished 0
	set pr_trrm 0
	raise $f
	My_Grab 0 $f pr_trrm
	while {!$finished} {
		tkwait variable pr_trrm
		if {$pr_trrm} {
			if {([string length $trrm_lim] <= 0) || ![IsNumeric $trrm_lim] || ($trrm_lim < 0.0) || ($trrm_lim >= $dur)} {
				Inf "Invalid Limit-of-trim Value (range 0 to < src duration $dur)"
				continue
			}
			if {$dur - $trrm_lim < 0.02} {
				Inf "Limit-of-trim $trrm_lim Too Near End Of File ($dur)"
				continue
			}
			if {([string length $trrm_crv] <= 0) || ![IsNumeric $trrm_crv] || ($trrm_crv < 1.0)} {
				Inf "Invalid Trim Curve (Range >= 1)"
				continue
			}
			if {([string length $trrm_steps] <= 0) || ![regexp {^[0-9]+$} $trrm_steps] || ($trrm_steps < 1)} {
				Inf "Invalid Number Of Trim Steps (Range >= 1)"
				continue
			}
			if {![SynthByETrim $srcfile $dur $trrm_lim $trrm_steps $trrm_exp $trrm_nnn $trrm_crv]} {
				DeleteAllTemporaryFiles
				continue
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc SynthByETrim {srcfile dur lim steps exp normd curv} {
	global evv pa CDPidrun prg_dun prg_abortd simple_program_messages
	global CDPmaxId maxsamp_line done_maxsamp

	if {$normd} {
		catch {unset CDPmaxId}
		catch {unset maxsamp_line}
		set done_maxsamp 0
		set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
		lappend cmd $srcfile
		lappend cmd 1		;#	1 flag added to FORCE read of maxsample
		if [catch {open "|$cmd"} CDPmaxId] {
			Inf "Finding Maximum Level Of [file rootname [file tail $srcfile]]: Process Failed"
			return 0
		} else {
	   		fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
		}
		vwait done_maxsamp
		if {[info exists maxsamp_line]} {
			set maxsamp [lindex $maxsamp_line 0]
		} else {
			Inf "Failed To Find Maximum Level Of Source File $srcfile"
			return 0
		}
		if {$maxsamp <= 0.0} {
			Inf "Source File Is Silent: Cannot Proceed"
			return 0
		}
		set srclevel $maxsamp
	}
	if {$curv == 1.0} {
		if {$lim <= 0.0} {				;#	e.g. 4 steps after 0         0----|----|----|----|----END
			incr steps
			set trimstep [expr $dur/double($steps)]
			incr steps -1
			set trimval $trimstep
		} else {						;#	e.g. 4 steps including trim  0-T-----|-----|-----|----END
			set trimdur [expr $dur - $lim]
			set trimstep [expr $trimdur/double($steps)]
			set trimval $lim
		}
		set trimvals $trimval
		incr steps -1					;#	We've already set the first trimval
		set n 0
		while {$n < $steps} {
			set trimval [expr $trimval + $trimstep]
			lappend trimvals $trimval
			incr n
		}
		set trimvals [ReverseList $trimvals]	;#	Put shortest trim to end
	} else {
		if {$lim <= 0.0} {
			incr steps
			set trimstt [expr $dur/double($steps)]
			set trimenddur [expr $dur - $trimstt]
			incr steps -1
		} else {
			set trimstt $lim
			set trimenddur [expr $dur - $lim]
		}
		set n 1
		while {$n <= $steps} {
			set frac [expr 1.0 - (double($n)/double($steps))]
			set frac [expr pow($frac,$curv)]
			set trimendval [expr $trimenddur * $frac]
			set trimendval [expr $trimstt + $trimendval]
			lappend trimvals $trimendval
			incr n
		}
	}

	;#	CREATE OUTFILE NAMES

	set ofbasnam [file rootname [file tail $srcfile]]
	append ofbasnam "_etrim"
	if {$exp} {
		append ofbasnam "e"
	}
	if {$normd} {
		append ofbasnam "n"
	}
	append ofbasnam "_"

	foreach val $trimvals {
		set vnam ""
		set len [string length $val]
		set n 0
		while {$n < $len} {
			set c [string index $val $n]
			if {[string match $c "."]} {
				append vnam "p"
			} else {
				append vnam $c
			}
			incr n
		}
		set ofnam $ofbasnam
		append ofnam $vnam $evv(SNDFILE_EXT)
		if {[file exists $ofnam]} {
			Inf "File $ofnam Already Exists: Cannot Proceed"
			return 0
		} else {
			lappend ofnams $ofnam
		}
	}
	if {$normd} {
		set n 0
		foreach outdur $trimvals {
			set tempofnam $evv(DFLT_OUTNAME)
			append tempofnam $n $evv(SNDFILE_EXT)
			lappend tempofnams $tempofnam
			incr n
		}
		set outfnams $tempofnams
	} else {
		set outfnams $ofnams
	}

	Block "PLEASE WAIT:        TRIMMING FILES"

	foreach outdur $trimvals outfnam $outfnams ofnam $ofnams {
		if {$exp} {
			set cmd [file join $evv(CDPROGRAM_DIR) envel]
			lappend cmd curtail 4 $srcfile $outfnam 0 $outdur -t0
		} else {
			set cmd [file join $evv(CDPROGRAM_DIR) sfedit]
			lappend cmd cut 1 $srcfile $outfnam 0 $outdur -w5
		}
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		wm title .blocker "PLEASE WAIT:        TRIMMING FILE TO $outdur"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "$CDPidrun : Failed To Trim File TO $outdur"
			UnBlock 
			return 0
		} else {
 			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun || ![file exists $outfnam]} {
			set msg "Failed To Produce Trimmed File $outdur"
			set msg [AddSimpleMessages $msg]
			Inf $msg
			UnBlock 
			return 0
		}
		if {$normd} {
			catch {unset CDPmaxId}
			catch {unset maxsamp_line}
			set done_maxsamp 0
			set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
			lappend cmd $outfnam
			lappend cmd 1		;#	1 flag added to FORCE read of maxsample
			if [catch {open "|$cmd"} CDPmaxId] {
				Inf "Finding Maximum Level Of $outfnam: Process Failed"
				DeleteAllTemporaryFiles
				UnBlock
				return 0
			} else {
	   			fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
			}
			vwait done_maxsamp
			if {[info exists maxsamp_line]} {
				set maxsamp [lindex $maxsamp_line 0]
			} else {
				Inf "Failed To Find Maximum Level Of Intermediate File $outfnam"
				DeleteAllTemporaryFiles
				UnBlock
				return 0
			}
			if {$maxsamp <= 0.0} {
				Inf "Intermediate Output $outfnam Is Silent: Cannot Normalise"
				DeleteAllTemporaryFiles
				UnBlock
				return 0
			}
			set norm [expr $srclevel/$maxsamp]
			set CDPidrun 0
			set prg_dun 0
			set prg_abortd 0
			catch {unset simple_program_messages}
			wm title .blocker "PLEASE WAIT:        NORMALISING FILE $ofnam"
			set cmd [file join $evv(CDPROGRAM_DIR) modify]
			lappend cmd loudness 1 $outfnam $ofnam $norm
	 
			if [catch {open "|$cmd"} CDPidrun] {
				Inf "$CDPidrun : Failed To Normalise File $ofnam"
				UnBlock 
				return 0
			} else {
 				fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
			}
			vwait prg_dun
			if {$prg_abortd} {
				set prg_dun 0
			}
			if {!$prg_dun || ![file exists $ofnam]} {
				set msg "Failed To Produce Normalised File $ofnam"
				set msg [AddSimpleMessages $msg]
				Inf $msg
				UnBlock 
				return 0
			}
		}
	}
	set ofnams [ReverseList $ofnams]
	foreach fnam $ofnams {
		FileToWkspace $fnam 0 0 0 0 1
	}
	UnBlock
	return 1
}

#---- Modify set of snds by trimming end

proc GenerateSpectraByETrimSet {} {

	global chlist evv pa pr_trrs trrs_lim trrs_steps sn_prm1 trrs_exp trrs_nnn

	set startmsg "Requires Several Mono Soundfiles.\n"

	set sn_prm1 0

	if {![info exists chlist] || ([llength $chlist] < 2)} {
		Inf $startmsg
		return
	}
	set n 0
	foreach fnam $chlist {
		if {($pa($fnam,$evv(FTYP)) == $evv(SNDFILE)) && ($pa($fnam,$evv(CHANS)) == 1)} {
			lappend durs $pa($fnam,$evv(DUR))
			lappend srcfiles $fnam
		} else {
			Inf $startmsg
			return
		}
		if {$n == 0} {
			set srate $pa($fnam,$evv(SRATE))
		} else {
			if {$pa($fnam,$evv(SRATE)) != $srate} {
				Inf "Not All Input Files Have Same Sample Rate"
				return 0
			}
		}
		incr n
	}
	set mindur [lindex $durs 0]
	foreach dur $durs {
		if {$dur < $mindur} {
			set mindur $dur
		}
	}
	set f .trrs
	if [Dlg_Create $f "CREATE NEW SNDS BY END-TRIMMING SOURCES" "set pr_trrs 0" -borderwidth $evv(BBDR)] {
		frame $f.0
		button $f.0.ab -text Abandon -width 10 -command "set pr_trrs 0"
		button $f.0.sv -text "Sound View" -width 10 -command "GetAtkTime 5" -bg $evv(SNCOLOR)
		button $f.0.ok -text Generate -width 10 -command "set pr_trrs 1"
		pack $f.0.ab -side right
		pack $f.0.ok $f.0.sv -side left -padx 4
		pack $f.0 -side top -pady 2 -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Limit of end-trim"
		entry $f.1.e -textvariable trrs_lim -width 8
		pack $f.1.e $f.1.ll -side left
		pack $f.1 -side top -pady 2
		frame $f.3
		checkbutton $f.3.ex -text "Exponential fades" -variable trrs_exp
		checkbutton $f.3.nn -text "Equalise levels" -variable trrs_nnn
		pack $f.3.ex $f.3.nn -side left
		pack $f.3 -side top -pady 2
		wm resizable $f 1 1
		bind $f <Return> {set pr_trrs 1}
		bind $f <Escape> {set pr_trrs 0}
	}
	set finished 0
	set pr_trrs 0
	raise $f
	My_Grab 0 $f pr_trrs
	while {!$finished} {
		tkwait variable pr_trrs
		if {$pr_trrs} {
			if {([string length $trrs_lim] <= 0) || ![IsNumeric $trrs_lim] || ($trrs_lim <= 0.005) || ($trrs_lim >= $mindur)} {
				Inf "Invalid Limit-of-trim Value (range > 0.005 to < min src duration $mindur)"
				continue
			}
			if {$mindur - $trrs_lim < 0.02} {
				Inf "Limit-of-trim $trrs_lim Too Near End Of (shortest) File ($mindur)"
				continue
			}
			if {![SynthByETrimSet $srcfiles $durs $mindur $trrs_lim $trrs_exp $trrs_nnn]} {
				DeleteAllTemporaryFiles
				continue
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc SynthByETrimSet {srcfiles durs mindur lim exp normd} {
	global evv pa CDPidrun prg_dun prg_abortd simple_program_messages
	global CDPmaxId maxsamp_line done_maxsamp

	set steps [llength $srcfiles]
	if {$normd} {
		foreach srcfile $srcfiles {
			catch {unset CDPmaxId}
			catch {unset maxsamp_line}
			set done_maxsamp 0
			set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
			lappend cmd $srcfile
			lappend cmd 1		;#	1 flag added to FORCE read of maxsample
			if [catch {open "|$cmd"} CDPmaxId] {
				Inf "Finding Maximum Level Of [file rootname [file tail $srcfile]]: Process Failed"
				return 0
			} else {
	   			fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
			}
			vwait done_maxsamp
			if {[info exists maxsamp_line]} {
				set maxsamp [lindex $maxsamp_line 0]
			} else {
				Inf "Failed To Find Maximum Level Of Source File $srcfile"
				return 0
			}
			if {$maxsamp <= 0.0} {
				Inf "Source File $srcdile Is Silent: Cannot Proceed"
				return 0
			}
			lappend srclevels $maxsamp
		}
	}
	if {$lim <= 0.0} {				;#	e.g. 4 steps after 0         0----|----|----|----|----END
		incr steps
		set trimstep [expr $mindur/double($steps)]
		incr steps -1
		set trimval $trimstep
	} else {						;#	e.g. 4 steps including trim  0-T-----|-----|-----|----END
		set trimdur [expr $mindur - $lim]
		set trimstep [expr $trimdur/double($steps)]
		set trimval $lim
	}
	set trimvals $trimval
	incr steps -1					;#	We've already set the first trimval
	set n 0
	while {$n < $steps} {
		set trimval [expr $trimval + $trimstep]
		lappend trimvals $trimval
		incr n
	}
	set trimvals [ReverseList $trimvals]	;#	Put shortest trim to end

	;#	CREATE OUTFILE NAMES

	foreach val $trimvals srcfile $srcfiles {
		set ofbasnam [file rootname [file tail $srcfile]]
		append ofbasnam "_trime"
		if {$exp} {
			append ofbasnam "e"
		}
		if {$normd} {
			append ofbasnam "n"
		}
		append ofbasnam "_"
		set vnam ""
		set len [string length $val]
		set n 0
		while {$n < $len} {
			set c [string index $val $n]
			if {[string match $c "."]} {
				append vnam "p"
			} else {
				append vnam $c
			}
			incr n
		}
		set ofnam $ofbasnam
		append ofnam $vnam $evv(SNDFILE_EXT)
		if {[file exists $ofnam]} {
			Inf "File $ofnam Already Exists: Cannot Proceed"
			return 0
		} else {
			lappend ofnams $ofnam
		}
	}
	if {$normd} {
		set n 0
		foreach outdur $trimvals {
			set tempofnam $evv(DFLT_OUTNAME)
			append tempofnam $n $evv(SNDFILE_EXT)
			lappend tempofnams $tempofnam
			incr n
		}
		set outfnams $tempofnams
	} else {
		set outfnams $ofnams
	}

	Block "PLEASE WAIT:        TRIMMING FILES"

	set n 0
	foreach srcfile $srcfiles outdur $trimvals outfnam $outfnams ofnam $ofnams {
		if {$exp} {
			set cmd [file join $evv(CDPROGRAM_DIR) envel]
			lappend cmd curtail 4 $srcfile $outfnam 0 $outdur -t0
		} else {
			set cmd [file join $evv(CDPROGRAM_DIR) sfedit]
			lappend cmd cut 1 $srcfile $outfnam 0 $outdur -w5
		}
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		wm title .blocker "PLEASE WAIT:        TRIMMING FILE $srcfile"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "$CDPidrun : Failed To Trim File $srcfile"
			UnBlock 
			return 0
		} else {
 			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun || ![file exists $outfnam]} {
			set msg "Failed To Produce Trimmed File $srcfile"
			set msg [AddSimpleMessages $msg]
			Inf $msg
			UnBlock 
			return 0
		}
		if {$normd} {
			catch {unset CDPmaxId}
			catch {unset maxsamp_line}
			set done_maxsamp 0
			set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
			lappend cmd $outfnam
			lappend cmd 1		;#	1 flag added to FORCE read of maxsample
			if [catch {open "|$cmd"} CDPmaxId] {
				Inf "Finding Maximum Level Of $outfnam: Process Failed"
				DeleteAllTemporaryFiles
				UnBlock
				return 0
			} else {
	   			fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
			}
			vwait done_maxsamp
			if {[info exists maxsamp_line]} {
				set maxsamp [lindex $maxsamp_line 0]
			} else {
				Inf "Failed To Find Maximum Level Of Intermediate File $outfnam"
				DeleteAllTemporaryFiles
				UnBlock
				return 0
			}
			if {$maxsamp <= 0.0} {
				Inf "Intermediate Output $outfnam Is Silent: Cannot Normalise"
				DeleteAllTemporaryFiles
				UnBlock
				return 0
			}
			set norm [expr [lindex $srclevels $n]/$maxsamp]
			set CDPidrun 0
			set prg_dun 0
			set prg_abortd 0
			catch {unset simple_program_messages}
			wm title .blocker "PLEASE WAIT:        NORMALISING FILE $ofnam"
			set cmd [file join $evv(CDPROGRAM_DIR) modify]
			lappend cmd loudness 1 $outfnam $ofnam $norm
	 
			if [catch {open "|$cmd"} CDPidrun] {
				Inf "$CDPidrun : Failed To Normalise File $ofnam"
				UnBlock 
				return 0
			} else {
 				fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
			}
			vwait prg_dun
			if {$prg_abortd} {
				set prg_dun 0
			}
			if {!$prg_dun || ![file exists $ofnam]} {
				set msg "Failed To Produce Normalised File $ofnam"
				set msg [AddSimpleMessages $msg]
				Inf $msg
				UnBlock 
				return 0
			}
		}
		incr n
	}
	set ofnams [ReverseList $ofnams]
	foreach fnam $ofnams {
		FileToWkspace $fnam 0 0 0 0 1
	}
	UnBlock
	return 1
}

#---- Tstretch and shrink SETS of sounds

proc GenerateSpectraByTstretchSet {} {

	global chlist evv wstk pa pr_strs strs_atk sn_prm1

	set startmsg "Requires 2 Or More Mono Soundfile And A Texfile Listing Tstretches (>1 And <=64).\n"

	set sn_prm1 0

	if {![info exists chlist] || ([llength $chlist] <= 2)} {
		Inf $startmsg
		return
	}
	set len [llength $chlist]
	set insndcnt [expr $len - 1]
	incr len -2
	set n 0
	foreach fnam [lrange $chlist 0 $len] {
		if {($pa($fnam,$evv(FTYP)) == $evv(SNDFILE)) && ($pa($fnam,$evv(CHANS)) == 1)} {
			lappend durs $pa($fnam,$evv(DUR))
			set srcfile $fnam
		} else {
			Inf $startmsg
			return
		}
		if {$n == 0} {
			set srate $pa($fnam,$evv(SRATE))
		} else {
			if {$pa($fnam,$evv(SRATE)) != $srate} {
				Inf "Not All Input Files Have Same Sample Rate"
				return 0
			}
		}
		lappend srcfiles $fnam
		incr n
	}
	set fnam [lindex $chlist end]
	if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)) || ![IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
		Inf $startmsg
		return
	} elseif {($pa($fnam,$evv(MINNUM)) <= 1.0) || ($pa($fnam,$evv(MAXNUM)) > 64.0)} {
		Inf $startmsg
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File $fnam"
		return
	}
	set cnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		set OK 1
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {![IsNumeric $item] || ($item <= 1.0) || ($item > 64.0)} {
				Inf "Invalid Value ($item) In File $fnam : (Range >1 to 64)"
				set OK 0
				break
			}
			if {$cnt > 0 && ($item <= $lastval)} {
				Inf "Values Do Not Increase At $lastval $item In File $fnam"
				set OK 0
				break
			}
			set lastval $item
			lappend strvals $item
			incr cnt
		}
		if {!$OK} {
			break
		}
	}
	close $zit
	if {!$OK} {
		return
	}
	set llen [llength $strvals]
	if {$insndcnt > $llen} {
		Inf "More Input Sounds Than Stretch Values: Cannot Proceed"
		return
	} elseif {$insndcnt < $llen} {
		set msg "Not All Stretch Values Will Be Used: Proceed ??"
		set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message "$msg"]
		if {$choice == "no"} {
			return
		} else {
			set llen $insndcnt
			incr llen -1
			set strvals [lrange $strvals 0 $llen]
		}
	}
	set mindur [lindex $durs 0]
	foreach dur $durs {
		if {$dur < $mindur} {
			set mindur $dur
		}
	}
	set f .strs
	if [Dlg_Create $f "CREATE NEW SNDSET BY TIME-STRETCHING" "set pr_strs 0" -borderwidth $evv(BBDR)] {
		frame $f.0
		button $f.0.ab -text Abandon -width 10 -command "set pr_strs 0"
		button $f.0.sv -text "Sound View" -width 10 -command "GetAtkTime 6" -bg $evv(SNCOLOR)
		button $f.0.ok -text Generate -width 10 -command "set pr_strs 1"
		pack $f.0.ab -side right
		pack $f.0.ok $f.0.sv -side left -padx 4
		pack $f.0 -side top -pady 2 -fill x -expand true
		frame $f.2
		label $f.2.ll -text "End of Unstretched Attack"
		entry $f.2.e -textvariable strs_atk -width 8
		pack $f.2.e $f.2.ll -side left
		pack $f.2 -side top -pady 2
		wm resizable $f 1 1
		bind $f <Return> {set pr_strs 1}
		bind $f <Escape> {set pr_strs 0}
	}
	set finished 0
	set pr_strs 0
	raise $f
	My_Grab 0 $f pr_strs
	while {!$finished} {
		tkwait variable pr_strs
		if {$pr_strs} {
			if {([string length $strs_atk] <= 0) || ![IsNumeric $strs_atk] || ($strs_atk < 0.0) || ($strs_atk >= $mindur)} {
				Inf "Invalid End-of-attack Value (Range 0 to < duration of shortest src $mindur)"
				continue
			}
			if {$mindur - $strs_atk < 0.02} {
				Inf "End-of-attack $strs_atk Too Near End Of Shortest File ($mindur)"
				continue
			}
			if {![SynthByStrSet $srcfiles $durs $mindur $strs_atk $strvals 0 0]} {
				DeleteAllTemporaryFiles
				continue
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc SynthByStrSet {srcfiles durs mindur atk strvals eq ts} {
	global evv pa CDPidrun prg_dun prg_abortd simple_program_messages
	global CDPmaxId maxsamp_line done_maxsamp

	set keepatk 1
	if {$atk <= 0} {
		set keepatk 0
	}
	set tempofnam $evv(DFLT_OUTNAME)
;# 2023
	append tempofnam 0 $evv(ANALFILE_OUT_EXT)
	set analfile $tempofnam
	set n 1
	foreach val $strvals {
		set tempofnam $evv(DFLT_OUTNAME)
;# 2023
		append tempofnam $n $evv(ANALFILE_OUT_EXT)
		lappend tempofnams $tempofnam 
		set tempofnam $evv(DFLT_OUTNAME)
		append tempofnam $n $evv(TEXT_EXT)
		lappend strfiles $tempofnam
		set tempofnam $evv(MACH_OUTFNAME)
		append tempofnam $n $evv(SNDFILE_EXT)
		lappend otherfnams $tempofnam 
		set tempofnam $evv(MACH_OUTFNAME)
		append tempofnam 0 $n $evv(SNDFILE_EXT)
		lappend furtherfnams $tempofnam 
		incr n
	}

	if {$eq} {		;#	GET LEVEL OF SOURCE
		foreach srcfile $srcfiles {	
			catch {unset CDPmaxId}
			catch {unset maxsamp_line}
			set done_maxsamp 0
			set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
			lappend cmd $srcfile
			lappend cmd 1		;#	1 flag added to FORCE read of maxsample
			if [catch {open "|$cmd"} CDPmaxId] {
				Inf "Finding Maximum Level Of [file rootname [file tail $srcfile]]: Process Failed"
				return 0
			} else {
	   			fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
			}
			vwait done_maxsamp
			if {[info exists maxsamp_line]} {
				set maxsamp [lindex $maxsamp_line 0]
			} else {
				Inf "Failed To Find Maximum Level Of Source File $srcfile"
				return 0
			}
			if {$maxsamp <= 0.0} {
				Inf "Source File $srcfile Is Silent: Cannot Proceed"
				return 0
			}
			lappend srclevels $maxsamp
		}
	}
	if {$ts} {
		set minval [lindex $strvals 0]
		foreach val $strvals {
			if {$val < $minval} {
				set minval $val
			}
		}
		set minval [expr $minval * $mindur]
		if {$minval <= 0.005} {
			Inf "Smallest Time-altered File Is Too Short For Start Trim"
			return
		}
	}

	;#	MAKE STRETCH BRKPNT FILES, PRESERVING ATK OF SOUND

	if {$keepatk} {
		foreach val $strvals strfile $strfiles dur $durs {
			catch {unset lines}
			set line [list 0 1]
			lappend lines $line
			set line [list $atk 1]
			lappend lines $line
			set line [list [expr $atk + 0.02] $val]
			lappend lines $line
			set line [list $dur $val]
			lappend lines $line
			if [catch {open $strfile "w"} zit] {
				Inf "Cannot Open Temporary Brkpnt File $strfile"
				return 0
			}
			foreach line $lines {
				puts $zit $line
			}
			close $zit
		}
	}

	;#	MAKE OUTFILE NAMES

	foreach val $strvals srcfile $srcfiles {

		set ofbasnam [file rootname [file tail $srcfile]]
		append ofbasnam "_str_"
		if {$eq} {
			append ofbasnam "e"
		}
		if {$ts} {
			append ofbasnam "t"
		}
		if {$eq || $ts} {
			append ofbasnam "_"
		}
		set vnam ""
		set len [string length $val]
		set n 0
		while {$n < $len} {
			set c [string index $val $n]
			if {[string match $c "."]} {
				append vnam "p"
			} else {
				append vnam $c
			}
			incr n
		}
		set ofnam $ofbasnam
		append ofnam $vnam $evv(SNDFILE_EXT)
		if {[file exists $ofnam]} {
			Inf "File $ofnam Already Exists: Cannot Proceed"
			return 0
		} else {
			lappend ofnams $ofnam
		}
	}

	Block "PLEASE WAIT:        PROCESSING FILES"

	foreach srcfile $srcfiles strfile $strfiles val $strvals tempofnam $tempofnams {

		if {[file exists $analfile] && [catch {file delete $analfile} zit]} {
			Inf "Cannot Delete Intermediate Analysis File"
			DeleteAllTemporaryFilesExcept $analfile
			UnBlock
			return 0
		}
		set cmd [file join $evv(CDPROGRAM_DIR) pvoc]
		lappend cmd anal 1 $srcfile $analfile -c1024 -o3
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		wm title .blocker "PLEASE WAIT:        ANALYSING FILE $srcfile"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "$CDPidrun : Failed To Analyse File $srcfile"
			UnBlock 
			return 0
		} else {
 			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun || ![file exists $analfile]} {
			set msg "Failed To Produce Analysed File $srcfile"
			set msg [AddSimpleMessages $msg]
			Inf $msg
			UnBlock 
			return 0
		}

		set cmd [file join $evv(CDPROGRAM_DIR) stretch]
		if {$keepatk} {
			lappend cmd time 1 $analfile $tempofnam $strfile
		} else {
			lappend cmd time 1 $analfile $tempofnam $val
		}
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		wm title .blocker "PLEASE WAIT:        STRETCHING SOUND BY $val"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "$CDPidrun : Failed To Stretch Sound By $val"
			UnBlock 
			return 0
		} else {
 			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun || ![file exists $tempofnam]} {
			set msg "Failed To Produce Sound Stretched By $val"
			set msg [AddSimpleMessages $msg]
			Inf $msg
			UnBlock 
			return 0
		}
	}
	if {$eq || $ts} {
		if {$eq && $ts} {
			set outputfnams $otherfnams
		} else {
			set outputfnams $furtherfnams
		}
	} else {
		set outputfnams $ofnams	;#	DIRECTLY TO OUTPUT SND NAMES
	}
	set n 0
	foreach tempofnam $tempofnams outputfnam $outputfnams otherfnam $otherfnams furtherfnam $furtherfnams ofnam $ofnams {
		set cmd [file join $evv(CDPROGRAM_DIR) pvoc]
		lappend cmd synth $tempofnam $outputfnam
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		wm title .blocker "PLEASE WAIT:        RESYNTHING FILE $ofnam"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "$CDPidrun : Failed To Resynth File $ofnam"
			UnBlock 
			return 0
		} else {
 			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun || ![file exists $outputfnam]} {
			set msg "Failed To Produce Resynthed File $ofnam"
			set msg [AddSimpleMessages $msg]
			Inf $msg
			UnBlock 
			return 0
		}
		if {$eq || $ts} {
			if {$ts} {
				set cmd [file join $evv(CDPROGRAM_DIR) envel]
				if {$eq} {
					lappend cmd dovetail 2 $outputfnam $furtherfnam .005 0 -t0
				} else {
					lappend cmd dovetail 2 $outputfnam $ofnam .005 0 -t0
				}
				set CDPidrun 0
				set prg_dun 0
				set prg_abortd 0
				catch {unset simple_program_messages}
				wm title .blocker "PLEASE WAIT:        TRIMMING FILE $ofnam"
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "$CDPidrun : Failed To Trim File $ofnam"
					DeleteAllTemporaryFiles
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
					set msg "Failed To Produce Trimmed File $ofnam"
					set msg [AddSimpleMessages $msg]
					Inf $msg
					DeleteAllTemporaryFiles
					UnBlock 
					return 0
				}
				if {($eq && ![file exists $furtherfnam]) || (!$eq && ![file exists $ofnam])} {
					set msg "Failed To Produce Trimmed File $ofnam"
					set msg [AddSimpleMessages $msg]
					Inf $msg
					DeleteAllTemporaryFiles
					UnBlock 
					return 0
				}
			}
			if {$eq} {
				catch {unset CDPmaxId}
				catch {unset maxsamp_line}
				set done_maxsamp 0
				set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
				if {$ts} {
					lappend cmd $furtherfnam
				} else {
					lappend cmd $outputfnam
				}
				lappend cmd 1		;#	1 flag added to FORCE read of maxsample
				if [catch {open "|$cmd"} CDPmaxId] {
					Inf "Finding Maximum Level Of $ofnam : Process Failed"
					DeleteAllTemporaryFiles
					UnBlock 
					return 0
				} else {
	   				fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
				}
				vwait done_maxsamp
				if {[info exists maxsamp_line]} {
					set maxsamp [lindex $maxsamp_line 0]
				} else {
					Inf "Failed To Find Maximum Level Of File $ofnam"
					DeleteAllTemporaryFiles
					UnBlock 
					return 0
				}
				if {$maxsamp <= 0.0} {
					Inf "Output File $ofnam Is Silent: Cannot Proceed"
					DeleteAllTemporaryFiles
					UnBlock 
					return 0
				}
				set norm [expr [lindex $srclevels $n]/$maxsamp]

				set cmd [file join $evv(CDPROGRAM_DIR) modify]
				if {$ts} {
					lappend cmd loudness 1 $furtherfnam $ofnam $norm
				} else {
					lappend cmd loudness 1 $outputfnam $ofnam $norm
				}
				set CDPidrun 0
				set prg_dun 0
				set prg_abortd 0
				catch {unset simple_program_messages}
				wm title .blocker "PLEASE WAIT:        NORMALISING FILE $ofnam"
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "$CDPidrun : Failed To Normalise File $ofnam"
					DeleteAllTemporaryFiles
					UnBlock 
					return 0
				} else {
 					fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				if {!$prg_dun || ![file exists $ofnam]} {
					set msg "Failed To Produce Normalised File $ofnam"
					set msg [AddSimpleMessages $msg]
					Inf $msg
					DeleteAllTemporaryFiles
					UnBlock 
					return 0
				}
			}
			lappend outfnams $ofnam
		} else {
			lappend outfnams $outputfnam
		}
		incr n
	}
	if {![info exists outfnams]} {
		UnBlock 
		return 0
	}
	set outfnams [ReverseList $outfnams]
	foreach fnam $outfnams {
		FileToWkspace $fnam 0 0 0 0 1
	}
	UnBlock
	return 1
}

#---- Time shrink a sound to produce a set of sounds

proc GenerateSpectraByTshrinkSet {} {

	global chlist evv pa wstk pr_shrs shrs_eq shrs_ts

	set startmsg "Requires 2 Or Mono Soundfile And A Texfile Listing Tstretches (<1 And > 0).\n"

	if {![info exists chlist] || ([llength $chlist] <= 2)} {
		Inf $startmsg
		return
	}

	set len [llength $chlist]
	set insndcnt [expr $len - 1]
	incr len -2
	set n 0
	foreach fnam [lrange $chlist 0 $len] {
		if {($pa($fnam,$evv(FTYP)) == $evv(SNDFILE)) && ($pa($fnam,$evv(CHANS)) == 1)} {
			lappend durs $pa($fnam,$evv(DUR))
			set srcfile $fnam
		} else {
			Inf $startmsg
			return
		}
		if {$n == 0} {
			set srate $pa($fnam,$evv(SRATE))
		} else {
			if {$pa($fnam,$evv(SRATE)) != $srate} {
				Inf "Not All Input Files Have Same Sample Rate"
				return 0
			}
		}
		lappend srcfiles $fnam
		incr n
	}
	set fnam [lindex $chlist end]
	if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)) || ![IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
		Inf $startmsg
		return
	} elseif {($pa($fnam,$evv(MINNUM)) <= 0.0) || ($pa($fnam,$evv(MAXNUM)) >= 1.0)} {
		Inf $startmsg
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File $fnam"
		return
	}
	set cnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		set OK 1
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {![IsNumeric $item] || ($item < 0.0) || ($item >= 1.0)} {
				Inf "Invalid Value ($item) In File $fnam : (Range >0 to <1)"
				set OK 0
				break
			}
			if {$cnt > 0 && ($item >= $lastval)} {
				Inf "Values Do Not Decrease At $lastval $item In File $fnam"
				set OK 0
				break
			}
			set lastval $item
			lappend strvals $item
			incr cnt
		}
		if {!$OK} {
			break
		}
	}
	close $zit
	if {!$OK} {
		return
	}
	set llen [llength $strvals]
	if {$insndcnt > $llen} {
		Inf "More Input Sounds Than Stretch Values: Cannot Proceed"
		return
	} elseif {$insndcnt < $llen} {
		set msg "Not All Stretch Values Will Be Used: Proceed ??"
		set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message "$msg"]
		if {$choice == "no"} {
			return
		} else {
			set llen $insndcnt
			incr llen -1
			set strvals [lrange $strvals 0 $llen]
		}
	}
	set mindur [lindex $durs 0]
	foreach dur $durs {
		if {$dur < $mindur} {
			set mindur $dur
		}
	}
	set f .shrs
	if [Dlg_Create $f "CREATE NEW SNDSET BY TIME-SHRINKING" "set pr_shrs 0" -borderwidth $evv(BBDR)] {
		frame $f.0
		button $f.0.ab -text Abandon -width 10 -command "set pr_shrs 0"
		button $f.0.ok -text Generate -width 10 -command "set pr_shrs 1"
		pack $f.0.ab -side right
		pack $f.0.ok -side left -padx 4
		pack $f.0 -side top -pady 2 -fill x -expand true
		frame $f.1
		checkbutton $f.1.eq -text "Equalise Levels" -variable shrs_eq
		checkbutton $f.1.ts -text "Trim start" -variable shrs_ts
		pack $f.1.eq $f.1.ts -side left
		pack $f.1 -side top -pady 2 -fill x -expand true
		wm resizable $f 1 1
		bind $f <Return> {set pr_shrs 1}
		bind $f <Escape> {set pr_shrs 0}
	}
	set shrs_ts 1
	set shrs_eq 1
	set finished 0
	set pr_shrs 0
	raise $f
	My_Grab 0 $f pr_shrs
	while {!$finished} {
		tkwait variable pr_shrs
		if {$pr_shrs} {
			if {![SynthByStrSet $srcfiles $durs $mindur 0 $strvals $shrs_eq $shrs_ts]} {
				DeleteAllTemporaryFiles
				continue
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- SEQUENCES BY TREMOLO ON SET OF SOUNDS

proc GenerateSpectraByTremoloSet {} {

	global chlist evv pa wstk pr_trs trs_frq trs_typ couldbetrem couldbevib couldbeacc accdown

	set startmsg "Requires 2 Or More Soundfile, And Textfile Of (optional) Tremolo Depths (0 To <1), And Peak-narrowings (2-100).\n"
	set accdown 0

	if {![info exists chlist] || ([llength $chlist] <= 2)} {
		Inf $startmsg
		return
	}

	set len [llength $chlist]
	set insndcnt [expr $len - 1]
	incr len -2
	set n 0
	foreach fnam [lrange $chlist 0 $len] {
		if {($pa($fnam,$evv(FTYP)) == $evv(SNDFILE)) && ($pa($fnam,$evv(CHANS)) == 1)} {
			lappend durs $pa($fnam,$evv(DUR))
			set srcfile $fnam
		} else {
			Inf $startmsg
			return
		}
		if {$n == 0} {
			set srate $pa($fnam,$evv(SRATE))
		} else {
			if {$pa($fnam,$evv(SRATE)) != $srate} {
				Inf "Not All Input Files Have Same Sample Rate"
				return 0
			}
		}
		lappend srcfiles $fnam
		incr n
	}
	set fnam [lindex $chlist end]
	if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)) || ![IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
		Inf $startmsg
		return
	} elseif {($pa($fnam,$evv(MINNUM)) < 0.0) || ($pa($fnam,$evv(MAXNUM)) > 100.0)} {
		Inf $startmsg
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File $fnam"
		return
	}
	set cnt 0
	set couldbetrem 1
	set couldbevib 1
	set couldbeacc 1
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		set line [split $line]
		set OK 1
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {![IsNumeric $item] || ($item < 0.0) || ($item > 100.0)} {
				Inf "Invalid Value ($item) In File $fnam : (Range 0 to 100)"
				set OK 0
				break
			}
			if {($item < 0.5) || ($item > 4.0)} {
				set couldbeacc 0
			}
			if {$item > 12.0} {
				set couldbevib 0
			}
			if {($item >= 1.0) && ![regexp {^[0-9]+$} $item]} {
				set couldbetrem 0				
			}
			if {!$couldbevib && !$couldbetrem} {
				Inf "Invalid Vibrato-depth Val ($item) (Range 0 to 12) or Tremolo Peak-narrowing Val (if >= 1, must be integer)"
				set OK 0
				break
			}
			if {$cnt > 0 && ($item <= $lastval)} {
				Inf "Values Do Not Increase At $lastval $item In File $fnam"
				set OK 0
				break
			}
			set lastval $item
			lappend tremvals $item
			incr cnt
		}
		if {!$OK} {
			break
		}
	}
	set tremfile $fnam
	close $zit
	if {!$OK} {
		return
	}

	set llen [llength $tremvals]
	if {$insndcnt > $llen} {
		Inf "More Input Sounds Than Control Values: Cannot Proceed"
		return
	} elseif {$insndcnt < $llen} {
		set msg "Not All Control Values Will Be Used: Proceed ??"
		set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message "$msg"]
		if {$choice == "no"} {
			return
		} else {
			set llen $insndcnt
			incr llen -1
			set tremvals [lrange $tremvals 0 $llen]
		}
	}
	set mindur [lindex $durs 0]
	foreach dur $durs {
		if {$dur < $mindur} {
			set mindur $dur
		}
	}
	if {$couldbeacc} {
		if {$pa($fnam,$evv(MAXNUM)) <= 1} {
			set accdown 1
		}
	}
	set f .trs
	if [Dlg_Create $f "CREATE NEW FILESET BY TREMOLO OR VIBRATO" "set pr_trs 0" -borderwidth $evv(BBDR)] {
		frame $f.0
		button $f.0.ab -text Abandon -width 10 -command "set pr_trs 0"
		button $f.0.ok -text Generate -width 10 -command "set pr_trs 1"
		pack $f.0.ab -side right
		pack $f.0.ok -side left -padx 4
		pack $f.0 -side top -pady 2 -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Frequency (Range 10-30)"
		entry $f.1.e -textvariable trs_frq -width 10
		pack $f.1.e $f.1.ll -side left -padx 2
		pack $f.1 -side top -pady 2 -fill x -expand true
		frame $f.2
		radiobutton $f.2.tr -variable trs_typ -text tremolo -value 1 -command CheckTRSTyp
		radiobutton $f.2.vb -variable trs_typ -text vibrato -value 2 -command CheckTRSTyp
		radiobutton $f.2.ac -variable trs_typ -text accel   -value 3 -command CheckTRSTyp
		pack $f.2.tr $f.2.vb $f.2.ac -side left
		pack $f.2 -side top -pady 2
		wm resizable $f 1 1
		bind $f <Return> {set pr_trs 1}
		bind $f <Escape> {set pr_trs 0}
	}
	set trs_typ 0
	set finished 0
	set pr_trs 0
	raise $f
	My_Grab 0 $f pr_trs $f.1.e
	while {!$finished} {
		tkwait variable pr_trs
		if {$pr_trs} {
			if {$trs_typ <= 0} {
				Inf "No Process Type Chosen"
				continue
			}
			if {$trs_typ != 3} {
				if {([string  length $trs_frq] <= 0) || ($trs_frq < 10) || ($trs_frq > 30)} {
					Inf "Invalid Frequency Value"
					continue
				}
			}
			if {![SynthByTremoloSet $srcfiles $trs_typ $trs_frq $durs $tremvals $tremfile]} {
				DeleteAllTemporaryFiles
				continue
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc CheckTRSTyp {}  {
	global couldbetrem couldbevib couldbeacc trs_typ trs_last_frq trs_frq
	switch -- $trs_typ {
		1 {
			if {!$couldbetrem} {
				Inf "Input Data Is Not Tremolo Data"
				set trs_typ 0
			}
			.trs.1.ll config -text "Frequency"
			.trs.1.e  config -bd 2 -state normal
			if {[info exists trs_last_frq]} {
				set trs_frq $trs_last_frq 
			}
		}
		2 {
			if {!$couldbevib} {
				Inf "Input Data Is Not Vibrato Data"
				set trs_typ 0
			}
			.trs.1.ll config -text "Frequency"
			.trs.1.e  config -bd 2 -state normal
			if {[info exists trs_last_frq]} {
				set trs_frq $trs_last_frq 
			}
		}
		3 {
			if {!$couldbeacc} {
				Inf "Input Data Is Not Acceleration Data"
				set trs_typ 0
			}
			set trs_last_frq $trs_frq
			set trs_frq ""
			.trs.1.ll config -text ""
			.trs.1.e  config -bd 0 -disabledbackground [option get . background {}] -state disabled
		}
	}
}

proc SynthByTremoloSet {srcfiles typ frq durs tremvals tremfile} {
	global evv CDPidrun prg_dun prg_abortd simple_program_messages pa evv last_outfile accdown

	if {$accdown} {
		set tremvals [ReverseList $tremvals]
	}
	set tremnam [file rootname [file tail $tremfile]]

	;#	SET UP OUTFILE NAMES

	set frnam ""
	set len [string length $frq]
	set n 0
	while {$n < $len} {
		set c [string index $frq $n]
		if {[string match $c "."]} {
			append frnam "p"
		} else {
			append frnam $c
		}
		incr n
	}
	foreach val $tremvals srcfile $srcfiles {

		set outfnambas [file rootname [file tail $srcfile]]

		set vnam ""
		set len [string length $val]
		set n 0
		while {$n < $len} {
			set c [string index $val $n]
			if {[string match $c "."]} {
				append vnam "p"
			} else {
				append vnam $c
			}
			incr n
		}
		set ofnam $outfnambas
		switch -- $typ {
			1 {
				append ofnam "_trem_"
			} 
			2 {
				append ofnam "_vib_"
			}
			3 {
				append ofnam "_accel_"
			}
		}
		append ofnam $frnam $tremnam "_" $vnam
		append ofnam $evv(SNDFILE_EXT)
		if {[file exist $ofnam]} {
			Inf "File $ofnam Already Exists : Cannot Proceed"
			return 0
		}
		lappend ofnams $ofnam
	}

	Block "PLEASE WAIT:        PROCESSING FILES"
	set n 1
	foreach val $tremvals dur $durs srcfile $srcfiles ofnam $ofnams {
		switch -- $typ {
			1 {
				set cmd [file join $evv(CDPROGRAM_DIR) tremolo]
				if {$val < 1} {
					lappend cmd tremolo 1 $srcfile $ofnam $frq $val 1 1 
				} else {
					lappend cmd tremolo 1 $srcfile $ofnam $frq 1 1 $val
				}
			}
			2 {
				set cmd [file join $evv(CDPROGRAM_DIR) modify]
				lappend cmd speed 6 $srcfile $ofnam $frq $val
			}
			3 {
				set cmd [file join $evv(CDPROGRAM_DIR) modify]
				lappend cmd speed 5 $srcfile $ofnam $val $dur
			}
		}
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		wm title .blocker "PLEASE WAIT:        PROCESSING FILE $ofnam"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "$CDPidrun : Failed To Process File $ofnam"
			continue
		} else {
 			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			set msg "Failed To Produce Processed File $ofnam"
			set msg [AddSimpleMessages $msg]
			Inf $msg
			continue
		}
		lappend outfnams $ofnam
		incr n
	}
	if {![info exists outfnams]} {
		UnBlock
		return 0
	}
	set outfnams [ReverseList $outfnams]
	foreach ofnam $outfnams {
		FileToWkspace $ofnam 0 0 0 0 1
	}
	set last_outfile $outfnams
	UnBlock
	return 1
}

#---- Trim (to same duration) and normalise all members of a set of sounds

proc GenerateSpectraByETrimNorm {} {

	global chlist evv pa pr_trrn trrn_dur trrn_steps sn_prm1 trrn_exp

	set startmsg "Requires Several Mono Soundfiles.\n"

	set sn_prm1 0

	if {![info exists chlist] || ([llength $chlist] < 2)} {
		Inf $startmsg
		return
	}
	set n 0
	foreach fnam $chlist {
		if {($pa($fnam,$evv(FTYP)) == $evv(SNDFILE)) && ($pa($fnam,$evv(CHANS)) == 1)} {
			lappend durs $pa($fnam,$evv(DUR))
			lappend srcfiles $fnam
		} else {
			Inf $startmsg
			return
		}
		if {$n == 0} {
			set srate $pa($fnam,$evv(SRATE))
		} else {
			if {$pa($fnam,$evv(SRATE)) != $srate} {
				Inf "Not All Input Files Have Same Sample Rate"
				return 0
			}
		}
		incr n
	}
	set mindur [lindex $durs 0]
	foreach dur $durs {
		if {$dur < $mindur} {
			set mindur $dur
		}
	}
	set f .trrn
	if [Dlg_Create $f "CREATE NEW SNDS BY END-TRIM AND NORMALISE" "set pr_trrn 0" -borderwidth $evv(BBDR)] {
		frame $f.0
		button $f.0.ab -text Abandon -width 10 -command "set pr_trrn 0"
		button $f.0.sv -text "Sound View" -width 10 -command "GetAtkTime 7" -bg $evv(SNCOLOR)
		button $f.0.ok -text Generate -width 10 -command "set pr_trrn 1"
		pack $f.0.ab -side right
		pack $f.0.ok $f.0.sv -side left -padx 4
		pack $f.0 -side top -pady 2 -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Duration"
		entry $f.1.e -textvariable trrn_dur -width 8
		pack $f.1.e $f.1.ll -side left
		pack $f.1 -side top -pady 2
		frame $f.3
		checkbutton $f.3.ex -text "Exponential fades" -variable trrn_exp
		pack $f.3.ex -side left
		pack $f.3 -side top -pady 2
		wm resizable $f 1 1
		bind $f <Return> {set pr_trrn 1}
		bind $f <Escape> {set pr_trrn 0}
	}
	set finished 0
	set pr_trrn 0
	raise $f
	My_Grab 0 $f pr_trrn
	while {!$finished} {
		tkwait variable pr_trrn
		if {$pr_trrn} {
			if {([string length $trrn_dur] <= 0) || ![IsNumeric $trrn_dur] || ($trrn_dur <= 0.005) || ($trrn_dur >= $mindur)} {
				Inf "Invalid Limit-of-trim Value (range > 0.005 to < min src duration $mindur)"
				continue
			}
			if {$mindur - $trrn_dur < 0.02} {
				Inf "Limit-of-trim $trrn_dur Too Near End Of (shortest) File ($mindur)"
				continue
			}
			if {![SynthByETrimNormSet $srcfiles $durs $mindur $trrn_dur $trrn_exp]} {
				DeleteAllTemporaryFiles
				continue
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc SynthByETrimNormSet {srcfiles durs mindur outdur exp} {
	global evv pa CDPidrun prg_dun prg_abortd simple_program_messages last_outfile
	global CDPmaxId maxsamp_line done_maxsamp

	set steps [llength $srcfiles]
	foreach srcfile $srcfiles {
		catch {unset CDPmaxId}
		catch {unset maxsamp_line}
		set done_maxsamp 0
		set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
		lappend cmd $srcfile
		lappend cmd 1		;#	1 flag added to FORCE read of maxsample
		if [catch {open "|$cmd"} CDPmaxId] {
			Inf "Finding Maximum Level Of [file rootname [file tail $srcfile]]: Process Failed"
			return 0
		} else {
	   		fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
		}
		vwait done_maxsamp
		if {[info exists maxsamp_line]} {
			set maxsamp [lindex $maxsamp_line 0]
		} else {
			Inf "Failed To Find Maximum Level Of Source File $srcfile"
			return 0
		}
		if {$maxsamp <= 0.0} {
			Inf "Source File $srcdile Is Silent: Cannot Proceed"
			return 0
		}
		lappend srclevels $maxsamp
	}

	;#	CREATE OUTFILE NAMES

	foreach srcfile $srcfiles {
		set ofbasnam [file rootname [file tail $srcfile]]
		append ofbasnam "_cut"
		if {$exp} {
			append ofbasnam "e"
		}
		append ofbasnam "_"
		set vnam ""
		set len [string length $outdur]
		set n 0
		while {$n < $len} {
			set c [string index $outdur $n]
			if {[string match $c "."]} {
				append vnam "p"
			} else {
				append vnam $c
			}
			incr n
		}
		set ofnam $ofbasnam
		append ofnam $vnam $evv(SNDFILE_EXT)
		if {[file exists $ofnam]} {
			Inf "File $ofnam Already Exists: Cannot Proceed"
			return 0
		} else {
			lappend ofnams $ofnam
		}
	}
	set n 0
	foreach srcfile $srcfiles {
		set tempofnam $evv(DFLT_OUTNAME)
		append tempofnam $n $evv(SNDFILE_EXT)
		lappend tempofnams $tempofnam
		incr n
	}
	set outfnams $tempofnams

	Block "PLEASE WAIT:        CUTTING FILES"

	set n 0
	foreach srcfile $srcfiles outfnam $outfnams ofnam $ofnams {
		if {$exp} {
			set cmd [file join $evv(CDPROGRAM_DIR) envel]
			lappend cmd curtail 4 $srcfile $outfnam 0 $outdur -t0
		} else {
			set cmd [file join $evv(CDPROGRAM_DIR) sfedit]
			lappend cmd cut 1 $srcfile $outfnam 0 $outdur -w5
		}
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		wm title .blocker "PLEASE WAIT:        CUTTING FILE $srcfile"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "$CDPidrun : Failed To Cut File $srcfile"
			UnBlock 
			return 0
		} else {
 			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun || ![file exists $outfnam]} {
			set msg "Failed To Produce Cut File $srcfile"
			set msg [AddSimpleMessages $msg]
			Inf $msg
			UnBlock 
			return 0
		}
		catch {unset CDPmaxId}
		catch {unset maxsamp_line}
		set done_maxsamp 0
		set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
		lappend cmd $outfnam
		lappend cmd 1		;#	1 flag added to FORCE read of maxsample
		if [catch {open "|$cmd"} CDPmaxId] {
			Inf "Finding Maximum Level Of $outfnam: Process Failed"
			DeleteAllTemporaryFiles
			UnBlock
			return 0
		} else {
	   		fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
		}
		vwait done_maxsamp
		if {[info exists maxsamp_line]} {
			set maxsamp [lindex $maxsamp_line 0]
		} else {
			Inf "Failed To Find Maximum Level Of Intermediate File $outfnam"
			DeleteAllTemporaryFiles
			UnBlock
			return 0
		}
		if {$maxsamp <= 0.0} {
			Inf "Intermediate Output $outfnam Is Silent: Cannot Normalise"
			DeleteAllTemporaryFiles
			UnBlock
			return 0
		}
		set norm [expr [lindex $srclevels $n]/$maxsamp]
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		wm title .blocker "PLEASE WAIT:        NORMALISING FILE $ofnam"
		set cmd [file join $evv(CDPROGRAM_DIR) modify]
		lappend cmd loudness 1 $outfnam $ofnam $norm
 
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "$CDPidrun : Failed To Normalise File $ofnam"
			UnBlock 
			return 0
		} else {
 			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun || ![file exists $ofnam]} {
			set msg "Failed To Produce Normalised File $ofnam"
			set msg [AddSimpleMessages $msg]
			Inf $msg
			UnBlock 
			return 0
		}
		incr n
	}
	set ofnams [ReverseList $ofnams]
	foreach fnam $ofnams {
		FileToWkspace $fnam 0 0 0 0 1
	}
	set last_outfile $ofnams
	UnBlock
	return 1
}

#-----

#---- Modify snds by trimming round portion in centre

proc GenerateSpectraByTrim {} {

	global chlist evv pa pr_trtr trtr_lim trtr_steps sn_prm1 sn_prm2 trtr_stt trtr_nnn trtr_crv trtr_exp

	set startmsg "Requires A Mono Soundfile.\n"

	set sn_prm1 0
	set sn_prm2 1

	if {![info exists chlist] || ([llength $chlist] != 1)} {
		Inf $startmsg
		return
	}

	set fnam [lindex $chlist 0]
	if {($pa($fnam,$evv(FTYP)) == $evv(SNDFILE)) && ($pa($fnam,$evv(CHANS)) == 1)} {
		set dur $pa($fnam,$evv(DUR))
		set srcfile $fnam
	} else {
		Inf $startmsg
		return
	}
	set f .trtr
	if [Dlg_Create $f "CREATE NEW SNDS BY TRIMMING SOURCE" "set pr_trtr 0" -borderwidth $evv(BBDR)] {
		frame $f.0
		button $f.0.ab -text Abandon -width 10 -command "set pr_trtr 0"
		button $f.0.sv -text "Sound View" -width 10 -command "GetAtkTime 8" -bg $evv(SNCOLOR)
		button $f.0.ok -text Generate -width 10 -command "set pr_trtr 1"
		pack $f.0.ab -side right
		pack $f.0.ok $f.0.sv -side left -padx 4
		pack $f.0 -side top -pady 2 -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Start of end-trim"
		entry $f.1.e -textvariable trtr_stt -width 8
		pack $f.1.e $f.1.ll -side left
		pack $f.1 -side top -pady 2 -fill x -expand true
		frame $f.2
		label $f.2.ll -text "Limit of end-trim"
		entry $f.2.e -textvariable trtr_lim -width 8
		pack $f.2.e $f.2.ll -side left
		pack $f.2 -side top -pady 2 -fill x -expand true
		frame $f.3
		label $f.3.ll -text "Curve (1 = equal shortenings : > 1 = shrink be smaller and smaller steps)"
		entry $f.3.e -textvariable trtr_crv -width 8
		set trtr_crv 1
		pack $f.3.e $f.3.ll -side left
		pack $f.3 -side top -pady 2 -fill x -expand true
		frame $f.4
		label $f.4.ll -text "Number of trim-steps"
		entry $f.4.e -textvariable trtr_steps -width 8
		pack $f.4.e $f.4.ll -side left
		pack $f.4 -side top -pady 2 -fill x -expand true
		frame $f.5
		checkbutton $f.5.nn -text "Equalise levels" -variable trtr_nnn
		checkbutton $f.5.ex -text "Exponential Fade" -variable trtr_exp
		pack $f.5.nn $f.5.ex -side left
		pack $f.5 -side top -pady 2 -fill x -expand true
		wm resizable $f 1 1
		bind $f.1.e <Down> "focus $f.2.e"
		bind $f.2.e <Down> "focus $f.3.e"
		bind $f.3.e <Down> "focus $f.4.e"
		bind $f.4.e <Down> "focus $f.1.e"
		bind $f.1.e <Up> "focus $f.4.e"
		bind $f.2.e <Up> "focus $f.1.e"
		bind $f.3.e <Up> "focus $f.2.e"
		bind $f.4.e <Up> "focus $f.3.e"
		bind $f <Return> {set pr_trtr 1}
		bind $f <Escape> {set pr_trtr 0}
	}
	set finished 0
	set pr_trtr 0
	raise $f
	My_Grab 0 $f pr_trtr $f.1.e
	while {!$finished} {
		tkwait variable pr_trtr
		if {$pr_trtr} {
			if {([string length $trtr_stt] <= 0) || ![IsNumeric $trtr_stt] || ($trtr_stt < 0.0) || ($trtr_stt >= $dur)} {
				Inf "Invalid Start-of-trim Value (range 0 to src duration $dur)"
				continue
			}
			if {$dur - $trtr_stt < 0.02} {
				Inf "Start-of-trim $trtr_stt Too Near End Of File ($dur)"
				continue
			}
			if {([string length $trtr_lim] <= 0.02) || ![IsNumeric $trtr_lim] || ($trtr_lim < 0.0) || ($trtr_lim >= $dur)} {
				Inf "Invalid Limit-of-trim Value (range 0.02 to src duration $dur)"
				continue
			}
			if {$trtr_lim - $trtr_stt <= 0.005} {
				Inf "Final Trimmed Segment Is Too Short (range > 0.005)"
				continue
			} 
			if {([string length $trtr_crv] <= 0) || ![IsNumeric $trtr_crv] || ($trtr_crv < 1.0)} {
				Inf "Invalid Trim Curve Value (range >= 1.0 )"
				continue
			}
			if {([string length $trtr_steps] <= 0) || ![regexp {^[0-9]+$} $trtr_steps] || ($trtr_steps < 1)} {
				Inf "Invalid Number Of Trim Steps (range >= 1)"
				continue
			}
			if {![SynthByTrim $srcfile $dur $trtr_stt $trtr_lim $trtr_steps $trtr_nnn $trtr_crv $trtr_exp]} {
				DeleteAllTemporaryFiles
				continue
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc SynthByTrim {srcfile dur stt lim steps normd curv exp} {
	global evv pa CDPidrun prg_dun prg_abortd simple_program_messages last_outfile
	global CDPmaxId maxsamp_line done_maxsamp

	if {$normd} {
		catch {unset CDPmaxId}
		catch {unset maxsamp_line}
		set done_maxsamp 0
		set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
		lappend cmd $srcfile
		lappend cmd 1		;#	1 flag added to FORCE read of maxsample
		if [catch {open "|$cmd"} CDPmaxId] {
			Inf "Finding Maximum Level Of [file rootname [file tail $srcfile]]: Process Failed"
			return 0
		} else {
	   		fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
		}
		vwait done_maxsamp
		if {[info exists maxsamp_line]} {
			set maxsamp [lindex $maxsamp_line 0]
		} else {
			Inf "Failed To Find Maximum Level Of Source File $srcfile"
			return 0
		}
		if {$maxsamp <= 0.0} {
			Inf "Source File Is Silent: Cannot Proceed"
			return 0
		}
		set srclevel $maxsamp
	}
	set trimsttdur $stt
	set trimenddur [expr $dur - $lim]
	if {$curv == 1.0} {
		set trimsttstp [expr $trimsttdur/double($steps)]
		set trimendstp [expr $trimenddur/double($steps)]
		set trimsttval $trimsttstp
		set trimendval [expr $dur - $trimendstp]

		set trimsttvals $trimsttval
		set trimendvals $trimendval
		incr steps -1					;#	We've already set the first trimval
		set n 0
		while {$n < $steps} {
			set trimsttval [expr $trimsttval + $trimsttstp]
			if {$trimsttval > $stt} {
				set trimsttval $stt
			}
			lappend trimsttvals $trimsttval


			set trimendval [expr $trimendval - $trimendstp]
			if {$trimendval < $lim} {
				set trimendval $lim
			}
			lappend trimendvals $trimendval
			incr n
		}
	} else {
		set n 1
		while {$n <= $steps} {
			set frac [expr 1.0 - (double($n)/double($steps))]
			set frac [expr pow($frac,$curv)]
			set trimsttval [expr $trimsttdur * $frac]
			set trimsttval [expr $stt - $trimsttval]
			lappend trimsttvals $trimsttval
			set trimendval [expr $trimenddur * $frac]
			set trimendval [expr $lim + $trimendval]
			lappend trimendvals $trimendval
			incr n
		}
	}

	;#	CREATE OUTFILE NAMES

	set ofbasnam [file rootname [file tail $srcfile]]
	append ofbasnam "_trim"
	if {$normd} {
		append ofbasnam "n"
	}
	if {$exp} {
		append ofbasnam "e"
	}
	if {$curv > 0.0} {
		set cvnam ""
		set len [string length $curv]
		set n 0
		while {$n < $len} {
			set c [string index $curv $n]
			if {[string match $c "."]} {
				append cvnam "p"
			} else {
				append cvnam $c
			}
			incr n
		}
		append ofbasnam $cvnam
	}
	append ofbasnam "_"

	foreach sval $trimsttvals eval $trimendvals {
		set svnam ""
		set len [string length $sval]
		set n 0
		while {$n < $len} {
			set c [string index $sval $n]
			if {[string match $c "."]} {
				append svnam "p"
			} else {
				append svnam $c
			}
			incr n
		}
		set evnam ""
		set len [string length $eval]
		set n 0
		while {$n < $len} {
			set c [string index $eval $n]
			if {[string match $c "."]} {
				append evnam "p"
			} else {
				append evnam $c
			}
			incr n
		}
		set ofnam $ofbasnam
		append ofnam $svnam "_" $evnam $evv(SNDFILE_EXT)
		if {[file exists $ofnam]} {
			Inf "file $ofnam Already Exists: Cannot Proceed"
			return 0
		} else {
			lappend ofnams $ofnam
		}
	}

	set n 0
	foreach sval $trimsttvals {
		set tempofnam $evv(MACH_OUTFNAME)
		append tempofnam $n $evv(SNDFILE_EXT)
		lappend otherfnams $tempofnam
		set tempofnam $evv(DFLT_OUTNAME)
		append tempofnam $n $evv(SNDFILE_EXT)
		lappend tempofnams $tempofnam
		incr n
	}

	if {$normd || $exp} {
		set outfnams $tempofnams
	} else {
		set outfnams $ofnams
	}

	Block "PLEASE WAIT:        TRIMMING FILES"

	set n 1
	foreach sttval $trimsttvals endval $trimendvals outfnam $outfnams ofnam $ofnams otherfnam $otherfnams {
		set thisdur [expr $endval - $sttval]
		set msdur [expr $thisdur * 1000.0]
		if {$msdur > 30} {
			set splic 15
		} else {
			set splic [expr $msdur/2.0]
			set splic [expr $splic - 0.5]
		}
		set cmd [file join $evv(CDPROGRAM_DIR) sfedit]
		lappend cmd cut 1 $srcfile $outfnam $sttval $endval -w$splic
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		wm title .blocker "PLEASE WAIT:        FILE TRIM $n"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "$CDPidrun : Failed With File Trim $n"
			UnBlock 
			return 0
		} else {
 			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun || ![file exists $outfnam]} {
			set msg "Failed To Produce Trimmed File $n"
			set msg [AddSimpleMessages $msg]
			Inf $msg
			UnBlock 
			return 0
		}
		if {$normd} {
			catch {unset CDPmaxId}
			catch {unset maxsamp_line}
			set done_maxsamp 0
			set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
			lappend cmd $outfnam
			lappend cmd 1		;#	1 flag added to FORCE read of maxsample
			if [catch {open "|$cmd"} CDPmaxId] {
				Inf "Finding Maximum Level Of $outfnam: Process Failed"
				DeleteAllTemporaryFiles
				UnBlock
				return 0
			} else {
	   			fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
			}
			vwait done_maxsamp
			if {[info exists maxsamp_line]} {
				set maxsamp [lindex $maxsamp_line 0]
			} else {
				Inf "Failed To Find Maximum Level Of Intermediate File $outfnam"
				DeleteAllTemporaryFiles
				UnBlock
				return 0
			}
			if {$maxsamp <= 0.0} {
				Inf "Intermediate Output $outfnam Is Silent: Cannot Normalise"
				DeleteAllTemporaryFiles
				UnBlock
				return 0
			}
			set norm [expr $srclevel/$maxsamp]
			set CDPidrun 0
			set prg_dun 0
			set prg_abortd 0
			catch {unset simple_program_messages}
			wm title .blocker "PLEASE WAIT:        NORMALISING FILE $ofnam"
			set cmd [file join $evv(CDPROGRAM_DIR) modify]
			if {$exp} {
				lappend cmd loudness 1 $outfnam $otherfnam $norm
				set zfnam $otherfnam
			} else {
				lappend cmd loudness 1 $outfnam $ofnam $norm
				set zfnam $ofnam
			}
 			if [catch {open "|$cmd"} CDPidrun] {
				Inf "$CDPidrun : Failed To Normalise File $ofnam"
				UnBlock 
				return 0
			} else {
 				fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
			}
			vwait prg_dun
			if {$prg_abortd} {
				set prg_dun 0
			}
			if {!$prg_dun || ![file exists $zfnam]} {
				set msg "Failed To Produce Normalised File $ofnam"
				set msg [AddSimpleMessages $msg]
				Inf $msg
				UnBlock 
				return 0
			}
		}
		if {$exp} {
			set dov [expr $endval - $lim]
			set dov [NotExponential $dov]
			if {$dov <= $evv(FLTERR)} {
				set OK 1
				if {$normd} {
					if [catch {file rename $otherfnam $ofnam} zit] {
						set OK 0
					}
				} else {
					if [catch {file rename $tempofnam $ofnam} zit] {
						set OK 0
					}
				}
				if {!$OK} {
					Inf "Failed To Rename Non-dovetailed Element"
					UnBlock 
					return 0
				}
			} else {
				set CDPidrun 0
				set prg_dun 0
				set prg_abortd 0
				catch {unset simple_program_messages}
				wm title .blocker "PLEASE WAIT:        DOVETAILING FILE $ofnam"
				set cmd [file join $evv(CDPROGRAM_DIR) envel]
				if {$normd} {
					lappend cmd dovetail 2 $otherfnam $ofnam 0 $dov -t0
				} else {
					lappend cmd dovetail 2 $tempofnam $ofnam 0 $dov -t0
				}
 				if [catch {open "|$cmd"} CDPidrun] {
					Inf "$CDPidrun : Failed To Dovetail File $ofnam"
					UnBlock 
					return 0
				} else {
 					fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				if {!$prg_dun || ![file exists $ofnam]} {
					set msg "Failed To Produce Dovetailed File $ofnam"
					set msg [AddSimpleMessages $msg]
					Inf $msg
					UnBlock 
					return 0
				}
			}
		}
		incr n
	}
	set ofnams [ReverseList $ofnams]
	foreach fnam $ofnams {
		FileToWkspace $fnam 0 0 0 0 1
	}
	set last_outfile $ofnams
	UnBlock
	return 1
}
