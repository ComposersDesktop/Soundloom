#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD 30 June 2013
# ... fixup button rectangles

#####################################
# CREATING BRKPNT DATA GRAPHICALLY	#
#####################################

#------ Create a brkfile for a parameter, for a selected process and infile
#
#	CAUTION: Only use to make brkfiles associated with a given process run
#				because it sets the global variable "brk(endtimeset)" 
#				for ALL OTHER brktables assocd with this process run.
#

proc Dlg_MakeBrkfile {pcnt gcnt} {
	global get_brkfile actvhi actvlo islog get_brkfile pr_brkfile pr_brkname brk
	global brkfrm brk_extname sfbbb evv
	global c_res is_file_edit brklmtval brkedit_emph dfault small_screen bfw
	global gg_cnt pp_cnt
	set gg_cnt $gcnt
	set pp_cnt $pcnt

	set is_file_edit 0
	set brk(could_be_maskedge) 0
	set brk(maskedge) -1
	set brk(ismarked) 0
	set brk(time_constrained) 1
	set brk(maxrangeindex) -1
	set brk(is_brkediting) 0
	set brk(short_table) 0

	if {![info exists brk(from_wkspace)]} {
		set brk(from_wkspace) 0
	}
	if {$brk(from_wkspace)} {
		if {![EstablishBrkLimitvals 0 0]} {
			return
		}
	}
	set f .get_brkfile
	if [Dlg_Create .get_brkfile "" "set pr_brkfile 0 ; set pr_brkname 0" -borderwidth $evv(BBDR)] {
		EstablishBrkfileWindow .get_brkfile $pcnt $gcnt
	}
	if {$small_screen} {
		set bfw .get_brkfile.c.canvas.f
	} else {
		set bfw .get_brkfile
	}	
	wm resizable .get_brkfile 1 1
	wm title .get_brkfile "Create a Breakpoint File"					;#	Force title
	$sfbbb.load config -text "" -command {} -bd 0 -state disabled
	catch {unset brkedit_emph}
	if {$brk(from_wkspace)} {
		$sfbbb.use config  -text "" -borderwidth 0 -bg [option get . background {}] -command {}
	} else {
		$sfbbb.use config  -text "Use" -width 4 -borderwidth $evv(SBDR) -bg $evv(EMPH) \
			-command "set pr_brkfile $evv(USEBRK) ; set pr_textfile 0"
		lappend brkedit_emph $sfbbb.use
	}
	set brk(fill_label) ""
	set brk(fill_cmd) {}

	DeactivateBrkdisplayOptions								;#	Deactivate all the display-modification options
	FullClearBrkDisplay $bfw.btns											 
	set brk(xdisplay_end) $evv(XWIDTH)						;#	A created brktable always x-fills entire display
	set brk(xdisplay_end_atedge) [expr int($brk(xdisplay_end) + $evv(BWIDTH))]				
	set brk(active_xdisplay_end) $evv(XWIDTH)				;#	All display applies to file
	set brk(mous_xdisplay_end) [expr $brk(xdisplay_end) + $evv(BWIDTH)]
	set brk(mous_active_xdisplay_end) [expr $brk(active_xdisplay_end) + $evv(BWIDTH)]
 	set brk(maskedge) -1											
 	set brk(greymask) -1											;#	There is no mask

	if {$brk(from_wkspace)} {
		set lo $brklmtval(lo)
		set hi $brklmtval(hi)
		set is_log $brklmtval(islog)
	} else {
		set lo $actvlo($pcnt)
		set hi $actvhi($pcnt)
		set is_log $islog($gcnt)
	}
	wm withdraw .get_brkfile
	if {![SetAndStoreBrkLimitvals $lo $hi $is_log 0 $pcnt]} {
		wm deiconify .get_brkfile
		Dlg_Dismiss .get_brkfile
		return 0											;#	Establish the range limits, & brktime-end (if poss)
	}
	wm deiconify .get_brkfile

	EstablishGrafToRealConversionConstants
	SetupAxes												;#
	ClearRealAndDisplayCoordinates							;#	Clear any existing coordinate vals

	SaveBrkframeInputs $lo $hi $is_log

	if {$brk(from_wkspace) || ![IsNumeric $dfault($pcnt)]} {
		CreateInitialPoints $brkfrm(lo)						;#	Create points at zero-time and endtime
	} else {
		set val [CalcDefaultYcoord $dfault($pcnt)]
		CreateInitialPointsNew $val $dfault($pcnt)
	}
	set brk(wascut) 0										;#	No points added or removed
	InitialiseBaktrak
	SaveOriginal_c											;#	Save these start vals in case want to restore
	set brk_extname [GetTextfileExtension brk]				;#	and it will be a textfile
	ActivateBrkdisplayOptions								;#	Activate (appropriate items on) options menu
	set pr_brkfile 0
	raise .get_brkfile
	update idletasks
	StandardPosition .get_brkfile
	My_Grab 0 .get_brkfile pr_brkfile						;#	Create brkfile, and give it a name
	BrkfileMagic $brk_extname $pcnt
	My_Release_to_Dialog .get_brkfile
	Dlg_Dismiss .get_brkfile
}													

#------ Establish the Range and log/linear type of a brkfile to be created.

proc EstablishBrkLimitvals {withfile fnam} {
	global brklmtval pr_limits pr_wrkbrk pa evv

	set f .limitvals

	if {$withfile} {
		set brklmtval(lo) $pa($fnam,$evv(MINBRK))
		set brklmtval(hi) $pa($fnam,$evv(MAXBRK))
	} else {
		set brklmtval(lo) 0.0
		set brklmtval(hi) 1.0
	}
	set brklmtval(islog) 0

	if [Dlg_Create $f "Brkfile Limits" "set pr_limits 0"] {
		set ff [frame $f.buttons -borderwidth $evv(SBDR) -bg $evv(EMPH)]
		button $ff.ok -text "OK" -command "set pr_limits 1" -highlightbackground [option get . background {}]
		button $ff.quit -text "Close" -command "set pr_limits 0; set pr_wrkbrk 0" -highlightbackground [option get . background {}]
		label $ff.l1 -text "Bottom of range"
		entry $ff.e1 -textvariable brklmtval(lo)
		label $ff.l2 -text "Top of range"
		entry $ff.e2 -textvariable brklmtval(hi)
		label $ff.l3 -text "Log display"
		checkbutton $ff.e3 -variable brklmtval(islog)
		grid $ff.ok $ff.quit
		grid $ff.l1 $ff.e1
		grid $ff.l2 $ff.e2
		grid $ff.l3 $ff.e3
		pack $ff -side top
		wm resizable $f 1 1
		bind $f <Return> {set pr_limits 1}
		bind $f <Escape> {set pr_limits 0}
	}
	ScreenCentre $f
	raise $f
	set pr_limits 0
	set finished 0
	raise $f
	My_Grab 0 $f pr_limits $f.buttons.e1
	while {!$finished} {
		tkwait variable pr_limits
		if {$pr_limits} {
			if {![IsNumeric $brklmtval(lo)]} {
				Inf "Bottom of range must be a number."
			} elseif {![IsNumeric $brklmtval(hi)]} {
				Inf "Top of range must be a number."
			} elseif {$brklmtval(lo) >= $brklmtval(hi)} {
				Inf "Bottom of range must be below top of range."
			} else {
				set finished 1
			}
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $pr_limits
}

#------ Create the points at zero-time and endtime, and draw connecting line.
#
#	 _								_
#	|_|----------------------------|_|
#

proc CreateInitialPointsNew {lo loreal} {
	global displ_c real_c brkfrm brk evv
	set x  0
	set y $lo

	catch {unset displ_c}
	lappend displ_c $x $y
	set x $evv(XWIDTH)
	lappend displ_c $x $y
	set brk(coordcnt) 4
	set brk(coordend) 2
	lappend real_c 0.0 $loreal		
	lappend real_c $brkfrm(endtime) $loreal
	Get_cResolution
	set brk(real_endtime) $brkfrm(endtime)
	DisplayBrktable
}				  				

#------ Create the points at zero-time and endtime, and draw connecting line.
#
#	 _								_
#	|_|----------------------------|_|
#

proc CreateInitialPoints {lo} {
	global zero displ_c real_c brkfrm brk evv
	set x  0
	if {$zero(exists)} {	 	;#	If there's a zeroline, set startpoints on zeroline
		set y $zero(y)
	} else {					;#	Else, set startpoints to foot of display
		set y $evv(YHEIGHT)
	}
	catch {unset displ_c}
	lappend displ_c $x $y
	set x $evv(XWIDTH)
	lappend displ_c $x $y
	set brk(coordcnt) 4
	set brk(coordend) 2
	if {$zero(exists)} {	 	;#	update the REAL values of the coordinates (represented by screen points)
		lappend real_c 0.0 0.0		
		lappend real_c $brkfrm(endtime) 0.0		
	} else {
		lappend real_c 0.0 $lo		
		lappend real_c $brkfrm(endtime) $lo
	}
	Get_cResolution
	set brk(real_endtime) $brkfrm(endtime)
	DisplayBrktable
}				  				

#------ Calc where default coords are on Y axis.

proc CalcDefaultYcoord {val} {
	global brkfrm brk evv
	set y [expr $val - $brkfrm(lo)]		;#	Set to input val
	if {$brkfrm(islog)} {					;#	if log display
		set y [expr log10($y + 1)]			;#	Add 1 to val before taking log (so lowest possible val is 0)
	}
	set y [expr int($y * $brk(yvaltograf))]	;#	Convert to range of display
	set y [expr $evv(YHEIGHT) - $y]			;#	Invert display
	return $y
}

#############################################################
# SAVING , USING, TESTING OR ABANDONING EDITED BRKPNT DATA	#
#############################################################

#------ Having created, edited or abandoned a brkfile, save brkfile data to file, or abandon it

proc BrkfileMagic {extname pcnt} {
	global pr_brkfile brk real_c prm get_brkfile newbrkfileId sfffl bfw evv
	global current_type getout good_res is_file_edit brkval_list wstk sl_real inside_ins_create ins

	set finished 0
	set getout 0

	if {$brk(is_brkediting)} {
		set fnam $brk(name) 
	}

	while {!$finished} {

		$bfw.l.quantise.ton config -state normal
		$bfw.l.quantise.tof config -state normal
		$bfw.l.quantise.von config -state normal
		$bfw.l.quantise.vof config -state normal

		if {$getout} {
			break
		}
		tkwait variable pr_brkfile					;#	stay in window, editing brkfile, or renaming file

		$bfw.l.quantise.ton config -state disabled
		$bfw.l.quantise.tof config -state disabled
		$bfw.l.quantise.von config -state disabled
		$bfw.l.quantise.vof config -state disabled

		if {$pr_brkfile == 0} {
			set finished 1								;#	CANCEL: exit dialog
		} else {
			set vals_unchanged 0
			if {$brk(is_brkediting)} {
				set vals_unchanged 1
				if {[llength $brk(orig_cs)] != [llength $real_c]} {
					set vals_unchanged 0
				} else {
					foreach orig $brk(orig_cs) real $real_c {
						if {![Flteq $orig $real]} {
							set vals_unchanged 0
							break
						}
					}
				}
			}
			set lasttime -1
			set badtime 0
			foreach {time val} $real_c {
				if [Flteq $lasttime $time] {
					set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] \
						-message "This table has more than 1 point at time $time\nRemove duplicate times?"]
					if {$choice == "yes"} {
						SqueezeOutBadTimes
					}
					set badtime 1
					break
				}					
				set lasttime $time
			}		
			if {$badtime} {
				continue
			}
			if {$vals_unchanged} {
				if {$pr_brkfile == $evv(USEBRK)} {	;#	If USE was pressed, and we've not subsequently edited data
					set prm($pcnt) $fnam	 		;#	Use last saved data
					set finished 1						;#	And quit dialog
				} else {								;#	If SAVE was pressed, ignore it
					Inf "No brkfile has been modified or created."
				}
			} else {
				if {$sl_real} {
					set fnam [NuGetValidBrkfileNameAndOpenFile $extname]
		 			if {[string length $fnam] > 0} {
						SaveReal_cToBrkfile	$newbrkfileId $pcnt 	;#	Write data to file
						close $newbrkfileId					 
						if {[FileToWkspace $fnam 0 0 0 0 1] <= 0} { 
							if [catch {file delete $fnam} result] {
								ErrShow "Cannot delete invalid file $fnam"
							} else {
								if {$ins(create)} {
									set inside_ins_create 1
								}
								DummyHistory $fnam "DESTROYED"
								catch {unset inside_ins_create}
							}
							DeleteFileFromSrcLists $fnam
							continue							;#	Put file on workspace, it it's valid file
						}
						Inf "Saved File $brk(name)"

						if {$pr_brkfile == $evv(USEBRK)} {	;#	If USE was pressed
							set prm($pcnt) $fnam	 		;#	Enter filename as current prm val
							set finished 1						;#	And quit dialog
						} else {
							if {$is_file_edit} {
								$sfffl delete 0 end				;#	Refresh the listing of files to be edited
								List_Appropriate_Files $pcnt $sfffl $current_type
							}
							set brk(orig_cs) "$real_c"	;#	Update orig_cs to those of newly created file
							if {!$good_res} {
								set finished 1
							}
						}
					} else {
						continue
					}
				} else {
					Inf "The Breakpoint File Can Be Saved.\nIt Will Be Placed On The Workspace.\nIf You Called This Routine From A Process Parameter Box, And Pressed The 'Use' Button,\nThe File Will Become The Parameter Value.\n"
					set finished 1
				}
			}
		}
	}
	$brkval_list delete 0 end
}

#------ Remove duplicate times

proc SqueezeOutBadTimes {} {
	global real_c displ_c brkfrm brk

	set look_for_maskedge 1
	set lasttime -1

	set endindex [llength $real_c]
	incr endindex -2
	set endtime [lindex $real_c $endindex]
	foreach {time val} $real_c {
		if {![Flteq $lasttime $time]} {
			lappend new_c $time $val
		}
		set lasttime $time
	}
	unset real_c
	set real_c $new_c
	set endindex [llength $real_c]
	incr endindex -2
	set real_c [lreplace $real_c $endindex $endindex $endtime]
	unset displ_c

	foreach {time val} $real_c {
		set x [RealToGrafx $time]
		set y [RealToGrafy $val $brkfrm(lo) $brkfrm(islog)]
		lappend displ_c $x $y
		if {$look_for_maskedge && ($x == $brk(active_xdisplay_end))} {
			set brk(maskedge) $x
			set look_for_maskedge 0
		}
	}
	DisplayBrktableQ
}

#------ Save Coordinates To Brkfile

proc SaveReal_cToBrkfile {fileId pcnt} {
	global real_c pr_maketext fine_tune brkfrm evv
	global good_res displ_c brkfrm pr_brkfile good_res has_just_fine_tuned brk

	set brk(tempreal_c) "$real_c"

	set look_for_maskedge 0
	if {$brk(could_be_maskedge)} {
		set look_for_maskedge 1
	}
	set good_res 1
	if {$fine_tune} {
		FineTuneBrkpnts $pcnt
		set has_just_fine_tuned 1
		if {$pr_maketext \
		&& ($pr_brkfile == $evv(SAVEBRK))} {	;#	Points have been tuned && resultant graf would be displayed
			Get_cResolution
			CheckBrkfileDisplayResolution [lindex $real_c $brk(coordend)] 0
			if {$good_res} {
				catch {unset displ_c}
				foreach {time val} $real_c {
					set x [RealToGrafx $time]
					set y [RealToGrafy $val $brkfrm(lo) $brkfrm(islog)]
					lappend displ_c $x $y
					if {$look_for_maskedge && ($x == $brk(active_xdisplay_end))} {
						set brk(maskedge) $x
						set look_for_maskedge 0
					}
				}
				DisplayBrktable
			}
		}
	}
	foreach {time val} $real_c {
		puts $fileId "$time $val"
	}
}

#------ Allow user to edit brkpont vals as text

proc FineTuneBrkpnts {pcnt} {
	global pr_maketext textfilename brk real_c displ_c search_string tstandard tlist readonlyfg readonlybg evv
	set f .maketext
	if [Dlg_Create $f "" "set pr_maketext 0" -borderwidth $evv(BBDR)] {
		EstablishTextWindow $f 0
	}
	$f.b.k config -text "" -width 0 -bd 0 -command {} -bg [option get . background {}]
	$f.z.0.src config -bg [option get . background {}]
	$f.z.0.ss  config -bg [option get . background {}]
	set tstandard .maketext.z.z.t
	set tlist .maketext.k.t
	set search_string ""
	$f.b.find config -text "" -bd 0 -state disabled
	$f.b.undo config -text "" -bd 0 -command {}
	$f.b.ref config -command "RefSee $f.k.t"
	$f.b.l config -text "filename" 
	$f.b.e config -state readonly -borderwidth 2 -foreground $readonlyfg -readonlybackground $readonlybg
	$f.b.m config -state disabled -borderwidth 0 -text ""

	wm resizable $f 1 1
	wm title $f "Fine Tune Breakpoint Data : $brk(name)" ;#	Establish a text-editing window, with approp title
	.maketext.b.keep config -text "Keep Changes"
	.maketext.b.cancel config -text "Leave Unchanged"
	bind .maketext <ButtonRelease-1> {RaiseWindow %W %x %y}
	set textfilename $brk(name)							;#	Display name of outfile created by user
	ForceVal $f.b.e $textfilename
	set t $f.k.t
	$t delete 1.0 end					  				;#	Clear any existing text in window
	set qq 0
	foreach {x y} $real_c {							;#	Put real brk coords into window
		$t insert end "$x\t"
		$t insert end "$y\n"
		incr qq
	}
	if {$qq > 0} {
		Scrollbars_Reset $f.k.t $f.k.sy 0 $qq [$f.k.t cget -width]
	}
	set pr_maketext 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_maketext

	while {!$finished} {
		tkwait variable pr_maketext					;#	stay in window, editing text, or renaming file
		if {$pr_maketext} {
			if [TestNewPoints $t $pcnt] {			 
				KeepTextEditedReal_c
				set finished 1
			}
		} else {
			set finished 1								;#	CANCEL: exit dialog
		}
	}
	$f.b.e config -state normal
	$f.b.m config -state normal -borderwidth 2 -text "Standard Names"
	My_Release_to_Dialog $f	 							;#	Return to calling dialog
	Dlg_Dismiss $f
}

#------ Write modified brkpnt data from text-display to real_c
#
#	WARNING: assumes nothing but text in textwindow (as this is tested for in calling context)
#

proc KeepTextEditedReal_c {} {
	global text_c real_c
	catch {unset real_c}
	foreach val $text_c {
		lappend real_c $val
	}
	return 1
}

#------ Test that hand-edited brkfile, is still a brkfile

proc TestNewPoints {t pcnt} {
	global text_c real_c brk
	set lasttime -1
	set words ""
	catch {unset text_c}
	set vals [$t get 1.0 end]
	set vals "[split $vals]"				;#	split line into single-space separated items
	foreach item $vals {
		set item [string trim $item]
		if {[string length $item] > 0} {
			set words [concat $words $item]
		}
	}
	set wordcnt [llength $words]
	if {$wordcnt <= 0} {
		return 0
	}
	if {![IsEven $wordcnt]} {
		Inf "Values incorrectly paired."
		return 0
	}
	set indx 1
	foreach {time val} $words {
		set lasttime [ValidBrkpointLine $pcnt $lasttime $time $val $indx]
		if {$lasttime < 0} {
			return 0
		}
		incr indx
	}
	if {$lasttime != [lindex $real_c $brk(coordend)]} { 
		Inf "Last time in brktable cannot be altered here."
		return 0
	}
	set brk(coordend) [expr [llength $words] - 2]
	set text_c $words
	return 1
}

#------ 
#		Test that hand-edited brkfile, is still a brkfile
#

proc TestBrkpnts {t pcnt} {
	global brk
	set lasttime -1
	set words ""
	set vals [$t get 1.0 end]
	set vals "[split $vals]"				;#	split line into single-space separated items
	foreach item $vals {
		set item [string trim $item]
		if {[string length $item] > 0} {
			set words [concat $words $item]
		}
	}
	set wordcnt [llength $words]
	if {$wordcnt <= 0} {
		Inf "No Values in table."
		return 0
	}
	if {![IsEven $wordcnt]} {
		Inf "Values incorrectly paired."
		return 0
	}
	set indx 1
	foreach {time val} $words {
		set lasttime [ValidBrkpointLine $pcnt $lasttime $time $val $indx]
		if {$lasttime < 0} {
			return 0
		}
		incr indx
	}
	return 1
}

#------ Test for valid brkpoint data

proc ValidBrkpointLine {pcnt lasttime time val indx} {
	global actvhi actvlo brk
	if {![IsNumeric $time]} {
		Inf "Non-numeric time '$time' encountered"
		return -1
	} elseif {![IsNumeric $val]} {
		Inf "Non-numeric value '$val' encountered"
		return -1
	}
	if {$time < 0.0} {
		Inf "Negative time value at line $indx"
		return -1
	}
	if {$lasttime < 0 && $time != 0.0} {
		Inf "First time in the table must be ZERO."
		return -1
	}
	if {$time <= $lasttime} {
		Inf "Time values don't advance at breakpoint-pair $indx"
		return -1
	} elseif {[info exists brk(from_wkspace)] && !$brk(from_wkspace)} {
		if {($val > $actvhi($pcnt)) || ($val < $actvlo($pcnt))} {
			Inf "Value out of range at breakpoint-pair $indx"
			return -1
		}
	}
	return $time
}

#------ Restore original state of the brkfile display
#
#	Restores last file loaded into brkfile dialog, or start-state for brkfile-creation
#

proc RestoreOrigBrkframeDisplaySetup {b} {
	global real_c origreal_c displ_c origdisplay_c brk origbrk brkfrm origbrkfrm
	global brkoptions c_res orig__c_res evv
	global bkc qval qtime
	

	set real_c 		 	  		 "$origreal_c"
	set displ_c 		 	 	  "$origdisplay_c"
	SetValQuantiseOff
	SetTimeQuantiseOff
	set brk(coordcnt)   		  $origbrk(coordcnt)
	set brk(coordend)   		  $origbrk(coordend)
	set brkfrm(lo) 			 	  $origbrkfrm(lo)
	set brkfrm(hi) 			 	  $origbrkfrm(hi)
	if {$brkfrm(islog) != $origbrkfrm(islog)} {
		set brkfrm(islog) $origbrkfrm(islog) 				 
		if {$brkfrm(islog)} {
			$brkoptions entryconfigure 4 -label "Linear Display"  -command "LogtoLin"
			catch {$bkc(can) itemconfigure logdisp -fill $evv(SPECIAL)}
		} else {												;#	Change label & action on button
			$brkoptions entryconfigure 4 -label "Log Display"  -command "LintoLog"
			catch {$bkc(can) itemconfigure logdisp -fill [option get . background {}]}
		}
	}
	set brkfrm(endtime)		 	  $origbrkfrm(endtime)
	set brk(wascut) 	  	  	 	  $origbrk(wascut)
	set brk(autosetframe_in_use) 	  $origbrk(autosetframe_in_use)
	set brk(range) 			 	 	  $origbrk(range)
	set brk(xgraftoval) 			  $origbrk(xgraftoval)
	set brk(xvaltograf) 			  $origbrk(xvaltograf)
	set brk(ygraftoval) 			  $origbrk(ygraftoval)
	set brk(yvaltograf) 			  $origbrk(yvaltograf)
	set brk(xdisplay_end) 		  	  $origbrk(xdisplay_end)
	set brk(xdisplay_end_atedge) 	  $origbrk(xdisplay_end_atedge)
	set brk(active_xdisplay_end) 	  $origbrk(active_xdisplay_end)

	set brk(real_endtime)		 	  $origbrk(real_endtime)
	set brk(time_autoset) 	  		  $origbrk(time_autoset)
	set c_res	 	 	  $orig__c_res

	set brk(greymask) 		 	 	  $origbrk(greymask)
	set brk(could_be_maskedge) 	 	  $origbrk(could_be_maskedge)
	set brk(maskedge) 			 	  $origbrk(maskedge)

	set brk(mous_xdisplay_end) 		  [expr $brk(xdisplay_end) + $evv(BWIDTH)]
	set brk(mous_active_xdisplay_end) [expr $brk(active_xdisplay_end) + $evv(BWIDTH)]

	ResetRangeMemory
	set name $brk(name)
	FullClearBrkDisplay $b
	set brk(name) $name
	SetupAxes
	BrkDisplayMasks
	DisplayBrktable
	if {$brk(time_autoset)} {
		TimeConstrainOptions $b
		set brk(time_constrained) 1
	}
	InitialiseBaktrak									;#	Remember total state
}

#------ Temporariliy save current state, for use in baktraking

proc DoTempBaktrak {} {
	global real_c displ_c brk brkfrm baktemp
	global c_res qval qtime

	set baktemp(real_c) 		   "$real_c"
	set baktemp(displ_c) 		   "$displ_c"
	set baktemp(qval) 		   		    $qval
	set baktemp(qtime) 		   		 	$qtime
	set baktemp(coordcnt)   		  	$brk(coordcnt)
	set baktemp(coordend)   		  	$brk(coordend)
	set baktemp(lo) 			  		$brkfrm(lo)
	set baktemp(hi) 			  		$brkfrm(hi)
	set baktemp(islog) 		  			$brkfrm(islog) 				 
	set baktemp(framendtime)		  	$brkfrm(endtime)
	set baktemp(wascut) 	  	  	    $brk(wascut)
	set baktemp(autosetframe_in_use)	$brk(autosetframe_in_use)
	set baktemp(range) 			 		$brk(range)
	set baktemp(xgraftoval) 		  	$brk(xgraftoval)
	set baktemp(xvaltograf) 		  	$brk(xvaltograf)
	set baktemp(ygraftoval) 		  	$brk(ygraftoval)
	set baktemp(yvaltograf) 		  	$brk(yvaltograf)
	set baktemp(xdisplay_end) 		  	$brk(xdisplay_end)
	set baktemp(xdisplay_end_atedge) 	$brk(xdisplay_end_atedge)
	set baktemp(active_xdisplay_end)  	$brk(active_xdisplay_end)

	set baktemp(real_endtime)	 	  	$brk(real_endtime)
	set baktemp(time_autoset)  			$brk(time_autoset)
	set baktemp(c_res)	 	$c_res
	set baktemp(greymask) 		 	  	$brk(greymask)
	set baktemp(could_be_maskedge) 		$brk(could_be_maskedge)
	set baktemp(maskedge)			  	$brk(maskedge)
	set baktemp(real_endtime)			$brk(real_endtime)
	set baktemp(time_constrained)		$brk(time_constrained)
}

#------ Update baktrak info

proc UpdateBaktrak {} {
	global baktemp baktrak canbaktrak

	set baktrak(real_c) 			$baktemp(real_c)
	set baktrak(displ_c) 			$baktemp(displ_c)
	set baktrak(qval)					$baktemp(qval)
	set baktrak(qtime)					$baktemp(qtime)
	set baktrak(coordcnt) 				$baktemp(coordcnt)
	set baktrak(coordend) 				$baktemp(coordend)
	set baktrak(lo) 					$baktemp(lo)
	set baktrak(hi) 					$baktemp(hi)
	set baktrak(islog) 					$baktemp(islog)
	set baktrak(framendtime) 			$baktemp(framendtime)
	set baktrak(wascut) 				$baktemp(wascut)
	set baktrak(autosetframe_in_use) 	$baktemp(autosetframe_in_use)
	set baktrak(range) 					$baktemp(range)
	set baktrak(xgraftoval) 			$baktemp(xgraftoval)
	set baktrak(xvaltograf) 			$baktemp(xvaltograf)
	set baktrak(ygraftoval) 			$baktemp(ygraftoval)
	set baktrak(yvaltograf) 			$baktemp(yvaltograf)
	set baktrak(xdisplay_end) 			$baktemp(xdisplay_end)
	set baktrak(xdisplay_end_atedge) 	$baktemp(xdisplay_end_atedge)
	set baktrak(active_xdisplay_end) 	$baktemp(active_xdisplay_end)

	set baktrak(real_endtime) 			$baktemp(real_endtime)
	set baktrak(time_autoset) 			$baktemp(time_autoset)
	set baktrak(c_res) 		$baktemp(c_res)
	set baktrak(greymask) 				$baktemp(greymask)
	set baktrak(could_be_maskedge) 		$baktemp(could_be_maskedge)
	set baktrak(maskedge) 				$baktemp(maskedge)
	set baktrak(real_endtime) 			$baktemp(real_endtime)
	set baktrak(time_constrained) 		$baktemp(time_constrained)
	set canbaktrak 1
}

#------ Single step undo

proc BrkUndo {b} {
	global brk baktrak canbaktrak brkfrm brk bkc real_c displ_c c_res
	global brkoptions qval qtime evv

	if {$canbaktrak} {
		set real_c 				 "$baktrak(real_c)"
		set displ_c 			 "$baktrak(displ_c)"
		set qval					 $baktrak(qval)
		if [string match "0" $qval] {
			SetValQuantiseOff
		}
		set qtime					 $baktrak(qtime)
		if [string match "0" $qtime] {
			SetTimeQuantiseOff
		}
		set brk(coordcnt)		  	 $baktrak(coordcnt)
		set brk(coordend)		  	 $baktrak(coordend)
		set brkfrm(lo) 			 $baktrak(lo) 				 
		set brkfrm(hi) 			 $baktrak(hi) 				 
		if {$brkfrm(islog) != $baktrak(islog)} {
			set brkfrm(islog) 	 $baktrak(islog) 				 
			if {$brkfrm(islog)} {
				$brkoptions entryconfigure 4 -label "Linear Display"  -command "LogtoLin"
				catch {$bkc(can) itemconfigure logdisp -fill $evv(SPECIAL)}
			} else {												;#	Change label & action on button
				$brkoptions entryconfigure 4 -label "Log Display"  -command "LintoLog"
				catch {$bkc(can) itemconfigure logdisp -fill [option get . background {}]}
			}
		}
 		set brkfrm(endtime)		 $baktrak(framendtime)
		set	brk(wascut)			 	 $baktrak(wascut) 	  	  	 
		set brk(time_autoset) 	  	 $baktrak(time_autoset)
		set brk(autosetframe_in_use) $baktrak(autosetframe_in_use) 
		set brk(range) 			 	 $baktrak(range)
		set brk(xgraftoval) 		 $baktrak(xgraftoval)
		set brk(xvaltograf) 		 $baktrak(xvaltograf) 			  
		set brk(ygraftoval) 		 $baktrak(ygraftoval) 			  
		set brk(yvaltograf) 		 $baktrak(yvaltograf) 			  
		set brk(xdisplay_end) 	 	 $baktrak(xdisplay_end)
		set brk(xdisplay_end_atedge) $baktrak(xdisplay_end_atedge)
		set brk(active_xdisplay_end) $baktrak(active_xdisplay_end)

		set brk(greymask)	 		 $baktrak(greymask)
		set c_res	 	 $baktrak(c_res)
		set brk(mous_xdisplay_end) 		  [expr $brk(xdisplay_end) + $evv(BWIDTH)]
		set brk(mous_active_xdisplay_end) [expr $brk(active_xdisplay_end) + $evv(BWIDTH)]

		set brk(real_endtime) 		$baktrak(real_endtime)

		StepBackInRangeMemory

		if {$brk(time_constrained)} {
			if {!$baktrak(time_constrained)} {
				TimeUnconstrainOptions $b
			}
		} else {
			if {$baktrak(time_constrained)} {
				TimeConstrainOptions $b
			}
		}
		set name $brk(name)
		FullClearBrkDisplay $b
		set brk(name) $name
		SetupAxes
		BrkDisplayMasks
		DisplayBrktable
		InitialiseBaktrak
	}
}

#########################################
# GLOBAL GRAPHIC OPERATIONS ON BRKFILES	#
#########################################

#------ Disallow options which alter timeframe

proc TimeConstrainOptions {b} {
	global brkoptions brk

 	$brkoptions entryconfigure 5  -label "Remove Time Constraints" -command "NoTimeConstraints $b"
 	$brkoptions entryconfigure 6  -label $brk(fill_label) -state normal	;#	Fill
 	$brkoptions entryconfigure 7  -label "" -state disabled				;#	Lengthen
	$brkoptions entryconfigure 8  -label "" -state disabled				;#	Shorten
	$brkoptions entryconfigure 9  -label "" -state disabled				;#	Time Stretch By
	$brkoptions entryconfigure 10 -label "" -state disabled				;#	Time Stretch To
	$brkoptions entryconfigure 11 -label "" -state disabled				;#	Time Shrink	By
	$brkoptions entryconfigure 12 -label "" -state disabled				;#	Time Shrink	To
	$brkoptions entryconfigure 13 -label "" -state disabled				;#	Orig Timerange
	set brk(time_constrained) 1
}

#------ Allow options which alter timeframe

proc TimeUnconstrainOptions {b} {
	global brkoptions
 	$brkoptions entryconfigure 5  -label "Constrain Time" -command "RestoreTimeConstraints $b"
 	$brkoptions entryconfigure 6  -label "" -state disabled	;#	Fill
 	$brkoptions entryconfigure 7  -label "Lengthen Table" 		-state normal
	$brkoptions entryconfigure 8  -label "Shorten Table"		-state normal
	$brkoptions entryconfigure 9  -label "Time Stretch By"		-state normal
	$brkoptions entryconfigure 10 -label "Time Stretch To"		-state normal
	$brkoptions entryconfigure 11 -label "Time Shrink By"		-state normal
	$brkoptions entryconfigure 12 -label "Time Shrink To"		-state normal
	$brkoptions entryconfigure 13 -label "Original Timings"		-state normal
	set brk(time_constrained) 0
}

#------ Remove time-constraints on display (set by length of soundfile)

proc NoTimeConstraints {b} {
	global brkoptions brk bkc brkfrm real_c evv

	if {!$brk(time_autoset)} {
		return
	}
	DoTempBaktrak
	set brk(time_autoset) 0
	catch {$bkc(can) delete message} in
	TimeUnconstrainOptions $b
	TimewiseRedisplayBrk [lindex $real_c $brk(coordend)] $b
	UpdateBaktrak
}

#------ Remove time-constraints on display (set by length of soundfile)

proc RestoreTimeConstraints {b} {
	global real_c brkoptions origbrkfrm brk

	if {$brk(time_autoset)} {
		return
	}
	DoTempBaktrak
	set brk(time_autoset) 1
	TimeConstrainOptions $b
	TimewiseRedisplayBrk $origbrkfrm(endtime) $b
	UpdateBaktrak
}

#------ Lengthen a brkfile, by adding extra point beyond end

proc LengthenBrk {b} {
	global brkeditval displ_c real_c good_res c_res brkfrm brk evv
	global origbrkfrm baktemp

	ValDialog "Duration" "l" $brk(real_endtime) $evv(MAXDUR)
	if {[string length $brkeditval] <= 0} {
		return
	}
	if [Flteq $brkeditval $brk(real_endtime)] {
		return
	}
	DoTempBaktrak

	set endval [lindex $real_c end]			;#	Add extra point to real_c
	lappend real_c $brkeditval $endval			

	incr brk(coordcnt) 2
	incr brk(coordend) 2

	Get_cResolution
	CheckBrkfileDisplayResolution $brkeditval 0
	if {!$good_res} {
		set real_c 		  "$baktemp(real_c)"
		set c_res "$baktemp(c_res)"
		set brk(coordcnt)	  $baktemp(coordcnt)
		set brk(coordend)	  $baktemp(coordend)
		set good_res 1
		return
	}
	set brk(real_endtime) $brkeditval
	if {![ReconfigureDisplay -1]} {
		set real_c 		  "$baktemp(real_c)"
		set c_res "$baktemp(c_res)"
		set brk(coordcnt)	  $baktemp(coordcnt)
		set brk(coordend)	  $baktemp(coordend)
		return
	}
	TimewiseRedisplayBrk $brk(real_endtime) $b
	UpdateBaktrak
}

#------ Shorten a brkfile, by cutting it at a specified time

proc ShortenBrk {b} {
	global brkeditval real_c displ_c brk origbrkfrm evv 
	global brkfrm	baktemp good_res

	DoTempBaktrak

	ValDialog "Duration" "h" $evv(MINDUR) $brk(real_endtime)
	if {[string length $brkeditval] <= 0} {
		return
	}
	if [Flteq $brkeditval $brk(real_endtime)] {
		return
	}

	set new_brkendtime $brkeditval
	set timindx 0

	set x [RealToGrafx $new_brkendtime]
	if {$brk(maskedge) > 0 && ($x < $evv(XWIDTH))} {
		foreach {xa ya} $displ_c {
			if {$x == $xa} {
				CutTableAtDisplayedPoint $x $brk(maskedge) $b
				UpdateBaktrak
				return		
			}
		}
	}
	if {![SpliceReal_c $new_brkendtime]} {
		return
	}
	set display_endtime [ReconfigureDisplay $x]
	if {$display_endtime < 0.0} {
		return
	}
	Get_cResolution	
	CheckBrkfileDisplayResolution $brkeditval 0
	if {!$good_res} {
		set real_c 		  "$baktemp(real_c)"
		set c_res "$baktemp(c_res)"
		set brk(coordcnt)	  $baktemp(coordcnt)
		set brk(coordend)	  $baktemp(coordend)
		set good_res 1
		return
	}
	if {![ReconfigureDisplay -1]} {
		set real_c 		  "$baktemp(real_c)"
		set c_res "$baktemp(c_res)"
		set brk(coordcnt)	  $baktemp(coordcnt)
		set brk(coordend)	  $baktemp(coordend)
		return
	}
	TimewiseRedisplayBrk $display_endtime $b
	UpdateBaktrak
}

#------ Allow entry of within-range numbers, for action on brktables

proc ValDialog {valname type lolimit hilimit} {
	global brkeditval pr_brkval evv

	set f .valdialog
	if [Dlg_Create $f "New $valname" "set pr_brkval 0" -borderwidth $evv(BBDR)] {
		set f1 [frame $f.1]
		set f2 [frame $f.2]
		button $f1.quit -text "Close" -command "set pr_brkval 0" -highlightbackground [option get . background {}]
		label  $f1.l -text "" -width $evv(MAX_BRKVAL_WIDTH) -anchor e
		label  $f1.r -text "" -width $evv(MAX_BRKVAL_RWIDTH) -anchor e
		entry  $f1.e -textvariable brkeditval -width 16
		button $f2.ok   -text "OK"   -command "set pr_brkval 1" -highlightbackground [option get . background {}]
		pack $f1.quit $f1.l $f1.e $f1.r -side left
		pack $f2.ok -side left
		pack $f.1 $f.2 -side top
		bind $f1.e <Return> {set pr_brkval 1}
		bind $f1.e <Escape> {set pr_brkval 0}
	}
	wm resizable $f 1 1
	set brkeditval ""
	ForceVal $f1.e $brkeditval
	$f1.l config -text "[string trim $valname]"
	$f1.r config -text "Range  $lolimit   to   $hilimit" -anchor w
	set finished 0
	set pr_brkval 0
	raise $f
	My_Grab 0 $f pr_brkval $f1.e
	ScreenCentre $f
	while {!$finished} {
		tkwait variable pr_brkval
		if {$pr_brkval} {
			set brkeditval [FixTxt $brkeditval "value"]
			if {[string length $brkeditval] <= 0} {
				ForceVal $f1.e $brkeditval
				continue
			}
			switch -- $type {
				"a" {			  		;#	Value must be within or at boundaries of range
					if [IsNumeric $brkeditval] {
						if {$brkeditval < $lolimit} {
							Inf "Value entered is too low. Minimum is $lolimit"
						} elseif {$brkeditval > $hilimit} {
							Inf "Value entered is too large. Maximum is $hilimit"
						} else {
							set finished 1
						}
					} else {
						Inf "No valid number entered."
					}
				}
				"l" {					;#	Value must be above lower boundary of range
					if [IsNumeric $brkeditval] {
						if {$brkeditval <= $lolimit} {
							Inf "Value entered is too low. Must be more than $lolimit"
						} elseif {$brkeditval > $hilimit} {
							Inf "Value entered is too large. Maximum is $hilimit"
						} else {
							set finished 1
						}
					} else {
						Inf "No valid number entered."
					}
				}
				"h" {					;#	Value must be below higher boundary of range
					if [IsNumeric $brkeditval] {
						if {$brkeditval < $lolimit} {
							Inf "Value entered is too small. Minimum is $lolimit"
						} elseif {$brkeditval >= $hilimit} {
							Inf "Value entered is too high. Must be less than $hilimit"
						} else {
							set finished 1
						}
					} else {
						Inf "No valid number entered."
					}
				}
				default {
					ErrShow "Unknown type: ValDialog"
					set brkeditval ""
					ForceVal $f1.e $brkeditval
					set finished 1
				}
			}
		} else {						;#	QUIT pressed
			set brkeditval ""
			ForceVal $f1.e $brkeditval
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#------ Force the brkpoints which is active on the infile, to fill the display space
#
#	(1)		 BRKPOINTS LONGER 						 
#
#	    THAN SPECFIED DISPLAY FRAME				     CHANGE BRKPOINTS
#  $active_xdisplay_end != $evv(XWIDTH)
#		 -----------------------				 -----------------------			
#		|		  ::::::::::::::|				|		 				|			
#		|	x	  ::::::::::::::|				|       x 				|			
#		|  / \	  :::x----x:::::|				|    /	   \			|			
#		| /	  \	  ::/::::::\::::|	------->>	|  /	 	  \ 		|			
#		|x	   \  :/::::::::\:::|				|x	      		 \		|			
#		|		\ /::::::::::\::|				|                	\   |			
#		|		 x::::::::::::\:|				|		  			   x|			
#		|		  :::::::::::::\|				|		  				|			
#		|		  ::::::::::::::x				|		  				|			
#		 -----------------------				 -----------------------			
# 				 brkfrm		real_endtime							brkfrm(endtime) DOES NOT CHANGE
#				 (endtime)												real_endtime	   
#						<-----												  brkpoint-set must be edited
#
#	(2)		 BRKPOINTS SHORTER 
#	    THAN SPECFIED DISPLAY FRAME				  CHANGE DISPLAY FRAME
#    $xdisplay_end != $evv(XWIDTH)
#		 -----------------------				 -----------------------			
#		|		  x:::::::::::::|				|		               x|			
#		|		 /::::::::::::::|				|		 			  /	|			
#		|	x	/ ::::::::::::::|				|        x 			/	|			
#		|  / \ /  ::::::::::::::|				|	  /	     \	  /		|			
#		| /	  x	  ::::::::::::::|				|  /            x		|			
#		|x	      ::::::::::::::|				|x	      				|			
#		|		  ::::::::::::::|				|		  				|			
#		|		  ::::::::::::::|				|		  				|			
#		 -----------------------				 -----------------------			
#				real_endtime    brkfrm								brkfrm(endtime) CHANGES
#							    (endtime)								real_endtime	
#						<------												  brkpoint-set remains same
#

proc FillTimeBrk {b} {
	global brkfrm xdisplay_end brk displ_c
	global brkoptions evv

	DoTempBaktrak

	# CASE (1)

	if {$brk(active_xdisplay_end) != $evv(XWIDTH)} {	;#	Brkpoint display ends after active-display area ends
		if {$brk(maskedge) > 0} {
			if [CutTableAtDisplayedPoint $brk(active_xdisplay_end) $brk(maskedge) $b] {
				set brk(active_xdisplay_end) $evv(XWIDTH)		;#	Force active-area to fill canvas
				set brk(maskedge) -1
				set brk(could_be_maskedge) 0
				UpdateBaktrak
			}
			$brkoptions entryconfigure 6 -label "" -state disabled
			Inf "Masked area can be restored now with 'Undo'"
			return
		}
		if {![SpliceReal_c $brkfrm(endtime)]} {	;#	Hence shorten the brkpoint set, to fit within active space
			return										
		}												;#	NB: brkfrm(endtime) DOES NOT CHANGE (merely remove mask)
		TimewiseRedisplayBrk $brk(real_endtime) $b		;#	End of current brktable = end of display
		UpdateBaktrak
		$brkoptions entryconfigure 6 -label "" -state disabled
		Inf "Masked area can be restored now with 'Undo'"
	
	# CASE (2)

	} elseif {$brk(xdisplay_end) != $evv(XWIDTH)} {		;#	Brkpoints display ends before canvas end
		set brk(autosetframe_in_use) 0					;#	Temporary change to display-area
		TimewiseRedisplayBrk $brk(real_endtime) $b
		UpdateBaktrak
		set brk(fill_label) "Restore Mask"
		set brk(fill_cmd) "RestoreMask $b"
		$brkoptions entryconfigure 6 -label "$brk(fill_label)" -command "$brk(fill_cmd)" -state normal
	}
}

#------ Restore time-display masks

proc RestoreMask {b} {
	global brkoptions origbrkfrm brk

	DoTempBaktrak
	set brk(autosetframe_in_use) 1
	TimewiseRedisplayBrk $origbrkfrm(endtime) $b
	set brk(fill_label) "Remove Masked Area"
	set brk(fill_cmd) "FillTimeBrk $b"
	$brkoptions entryconfigure 6 -label "$brk(fill_label)" -command "$brk(fill_cmd)" -state normal
	UpdateBaktrak
}	

#------ Time-stretch the brkpoint file - time-distance between points is scaled up

proc TstretchBrk {type b} {
	global brkeditval displ_c real_c brk evv 
	global origbrkfrm brkfrm good_res c_res baktemp

	DoTempBaktrak
	
	switch -exact -- $type {
		"by" {
			ValDialog "Stretch_Factor" "l" 1.0 $evv(MAXSTRETCH)
			if {[string length $brkeditval] <= 0} {
				return
			}
			if [Flteq $brkeditval 1.0] {
				return
			}
			set stretchfac $brkeditval
		}
		"to" {
			ValDialog "Duration" "l" $brk(real_endtime) $evv(MAXDUR)
			if {[string length $brkeditval] <= 0} {
				return
			}
			if [Flteq $brkeditval $brk(real_endtime)] {
				return
			}
			set stretchfac [expr double($brkeditval) / $brk(real_endtime)]
		}
		default {
			ErrShow "Unknown switch option in TstretchBrk"
			return
		}
	}
	foreach {time val} $real_c {
		set time [expr $time * $stretchfac]
		lappend new_c $time $val
	}
	set new_brkendtime $time

	unset real_c
	set real_c "$new_c"

	Get_cResolution	
	CheckBrkfileDisplayResolution $new_brkendtime 0
	if {!$good_res} {
		set real_c 		  "$baktemp(real_c)"
		set c_res "$baktemp(c_res)"
		set brk(coordcnt)	  $baktemp(coordcnt)
		set brk(coordend)	  $baktemp(coordend)
		set good_res 1
		return
	}
	if {![ReconfigureDisplay -1]} {
		set real_c 		  "$baktemp(real_c)"
		set c_res "$baktemp(c_res)"
		set brk(coordcnt)	  $baktemp(coordcnt)
		set brk(coordend)	  $baktemp(coordend)
	}
	set brk(real_endtime) $new_brkendtime
	TimewiseReformBrk $brk(real_endtime) $b
	UpdateBaktrak
}

#------ Time-shrink the brkpoint file - time-distance between points is scaled down

proc TshrinkBrk {type b} {
	global brkeditval displ_c real_c c_res good_res brk evv
	global origbrkfrm brkfrm good_res c_res baktemp 

	DoTempBaktrak

	switch -- $type {
		"by" {
			ValDialog "Shrink_Factor" "h" $evv(MINSTRETCH) 1.0
			if {[string length $brkeditval] <= 0} {
				return
			}
			set stretchfac $brkeditval
		}
		"to" {
			ValDialog "Duration" "h" $evv(MINDUR) $brk(real_endtime)
			if {[string length $brkeditval] <= 0} {
				return
			}
			set stretchfac [expr double($brkeditval) / $brk(real_endtime)]
		}
		default {
			ErrShow "Unknown switch option in TshrinkBrk"
			return
		}
	}
	foreach {time val} $real_c {
		set time [expr $time * $stretchfac]
		lappend new_c $time $val
	}
	set new_brkendval $time

	unset real_c
	set real_c 			   "$new_c"
	set old_c_res "$c_res"
	
	Get_cResolution
	CheckBrkfileDisplayResolution $new_brkendval 0
	if {!$good_res} {
		set real_c 		  "$baktemp(real_c)"
		set c_res "$baktemp(c_res)"
		set good_res 1
		return
	}	
	set brk(real_endtime) $new_brkendval			;#	End of current brktable (not ness of display)

	if {![ReconfigureDisplay -1]} {
		set real_c 		  "$baktemp(real_c)"
		set c_res "$baktemp(c_res)"
		set brk(coordcnt)	  $baktemp(coordcnt)
		set brk(coordend)	  $baktemp(coordend)
	}
	TimewiseReformBrk $brk(real_endtime) $b
	UpdateBaktrak
}

#------ Redisplay the time-axis text, the grafvals (if any), and recalc conversion constants time <-> x
#
#	For timestretch, display need not be changed
#

proc TimewiseReformBrk {brk_endtime b} {
	global brkfrm brk bkc 
	set brkfrm(endtime) $brk_endtime
	catch {$bkc(can) delete endinfo} in			
	DisplayBrkEndtime 							;#	Alter display on time-axis
	ForceVal $b.name $brk(name)
	EstablishGrafToRealConversionConstants_x	;#	Recalculate time-axis display-conversion-constants
	SeeValsBrk
}

#------ Restore original duration of brkfile (and hence orig points, if no points inserted or deleted amidships)
#
#	Restore original times		 				| | | | | |
#	
#	Restore current vals 	Either  too many	|o|o|o|o|o|o(oo) VALS LOST  (which must have been added at end)
#									exact no.	|o|o|o|o|o|o	 VALS MATCH
#									too few		|o|o|o| | |		 MORE VALS TO ADD
#
#	In this last case, repeat the last value	|a|b|c| | |	--->> |a|b|c|c|c|c
#

proc RestoreBrkdur {b} {
	global displ_c real_c origreal_c origbrkfrm brk
	global baktrak canbaktrak brkfrm evv

	if {![ReconfigureDisplay -1]} {
		return
	}
	DoTempBaktrak
	set display_endtime $origbrkfrm(endtime)
	set newlen 0
	set origlen [llength $origreal_c] 
	set reallen [llength $real_c] 

	if {$origlen > $reallen} {
		set realend $reallen
		incr realend -1
		set start_c "[lrange $origreal_c 0 $realend]"
		set end_c   "[lrange $origreal_c $reallen end]"
		foreach {origtime origval} $start_c {time val} $real_c  {
			lappend new_c $origtime $val
		}
		foreach {origtime origval} $end_c {
			lappend new_c $origtime $val		;#	If not enough values, current endval sticks at end
		}
	} elseif {$origlen < $reallen} {				;#	If not enough times, end values are axed
		incr origlen -1
		set start_c "[lrange $real_c 0 $origlen]"
		foreach {origtime origval} $origreal_c {time val} $start_c  {
			lappend new_c $origtime $val
		}
	} else {
		foreach {origtime origval} $origreal_c {time val} $real_c {
			lappend new_c $origtime $val
		}
	}
	unset real_c
	set real_c "$new_c"
	set indx [llength $real_c]
	incr indx -2
	set brk(real_endtime) [lindex $real_c $indx]
	set brk(coordcnt) [llength $new_c]
	set brk(coordend) [expr int($brk(coordcnt) - 2)]
	TimewiseRedisplayBrk $display_endtime $b
	Get_cResolution
	UpdateBaktrak
}

#------ Change display from Logarithmic to Linear

proc LogtoLin {} {
	global brkfrm displ_c
	DoTempBaktrak
	set new_rangeinfo 0
	set oldislog 1
	set newislog 0
	set brkfrm(islog) $newislog
	RangewiseRedisplayBrk $oldislog $newislog $new_rangeinfo
	UpdateBaktrak
}

#------ Change display from Linear to Logarithmic

proc LintoLog {} {
	global brkfrm displ_c
	DoTempBaktrak
	set new_rangeinfo 0
	set oldislog 0
	set newislog 1
	set brkfrm(islog) $newislog
	RangewiseRedisplayBrk $oldislog $newislog $new_rangeinfo
	UpdateBaktrak
}

#------ Redisplay brkfile, when value-dimension of display has been altered

proc RangewiseRedisplayBrk {oldislog newislog new_rangeinfo} {
	global evv brkfrm brkoptions zero brk bkc evv
													;#	retains time-texts, existing real_c
	RangewiseClearBrkDisplay $new_rangeinfo			;#	and, if not flagged, existing rangetext

	EstablishGrafToRealConversionConstants_y
	if {$brkfrm(lo) < 0.0 && $brkfrm(hi) > 0.0} {
		RedrawZeroLineAndText
	} else {
		set zero(exists) 0
	}
 	if {$new_rangeinfo} {
		DisplayRangeLimits
	}
	if {$brk(greymask) >= 0} {							;#	redisplay any pre-existing grey-mask
		BrkDisplayMasks
	}
	ReplotBrkdisplayY_c							;#	Recalculate display coordinates
	DrawGrafPoints									;#	Redraw points
	DrawGrafLine 1									;#	Redraw grafline
	if {$newislog != $oldislog} {
		if {$brkfrm(islog)} {
			$brkoptions entryconfigure 4 -label "Linear Display"  -command "LogtoLin"
			catch {$bkc(can) itemconfigure logdisp -fill $evv(SPECIAL)}
		} else {									;#	Change label & action on button
			$brkoptions entryconfigure 4 -label "Log Display"  -command "LintoLog"
			catch {$bkc(can) itemconfigure logdisp -fill [option get . background {}]}
		}
	}
}

#------ Draw Zero Line, and a "0", for brktable display.
									 
proc RedrawZeroLine {}  {
	global zero brkfrm brk bkc evv
	if {![string match $brkfrm(islog) $zero(last_islog)] 	\
	 || ![string match $brkfrm(lo) $zero(last_lo)]	 	\
	 || ![string match $brk(yvaltograf) $zero(last_yvaltograf)]} {		   ;# Only recalculate if necessary
		CalcZerolineYcoord
	}
	set zero(exists) 1
	set y [expr int($zero(y) + $evv(BWIDTH))]
	$bkc(can) create line $evv(BWIDTH) $y $bkc(actual_xwidth_end) $y -tag zinfo  	;# line on drawing canvas
}

#------ Clear the brkdisplay when value-range (only) altered
#
#	Retains 'greyout' flag as there's no time-dimension change.
#	And keeps name, as we're not changing real_c data here.
#

proc RangewiseClearBrkDisplay {new_rangeinfo} {
	global brk bkc
	catch {$bkc(can) delete cline}  in			   					 ;#	Delete line
	catch {$bkc(can) delete points} in								 ;#	points
	catch {$bkc(can) delete zinfo} in								 ;#	zeroline and its text
	if {$new_rangeinfo} {
		catch {$bkc(can) delete rangeinfo} in						 ;#	Delete rangeinfo, only if changed
	}
	catch {$bkc(can) delete greyout} in								 ;#	Delete any stipple mask
}

#------ Scale display values from real coords

proc ReplotBrkdisplayY_c {} {
	global real_c displ_c brkfrm

	set indx 1
	foreach {time val} $real_c {x y} $displ_c {
		lappend new_c $x [RealToGrafy $val $brkfrm(lo) $brkfrm(islog)]
	}
	unset displ_c
	set displ_c "$new_c"
}

#------ Replot display times from real coords (for quantising)

proc ReplotBrkdisplayX_c {} {
	global real_c displ_c

	set indx 1
	foreach {time val} $real_c {x y} $displ_c {
		lappend new_c [RealToGrafx $time] $y
	}
	unset displ_c
	set displ_c "$new_c"
}

#------ Update hst of range changes

proc UpdateRangeMemory {} {
	global brkfrm lastbrk brk
	lappend lastbrk(range) 	$brk(range)
	lappend lastbrk(hi) 	$brkfrm(hi)
	lappend lastbrk(lo) 	$brkfrm(lo)
	lappend lastbrk(islog) 	$brkfrm(islog)
	incr brk(maxrangeindex)
	set brk(thisrangeindex) $brk(maxrangeindex)
}

#------ Force brkpnt graph to fill the available height of the display

proc FillRangeBrk {} {
	global displ_c real_c brkfrm brk evv actvlo actvhi gg_cnt pp_cnt
	set firsttime 1
	DoTempBaktrak
	foreach {time val} $real_c {
		if {$firsttime} {
			set lo $val
			set hi $val
			set firsttime 0
		} else { 
			if {$val < $lo} {
				set lo $val
			} elseif {$val > $hi} {
				set hi $val
			}
		}
	}
	if {[expr abs($hi - $lo)] <  $evv(FLTERR)} {
		if {$gg_cnt < 0} {
			Inf "Values Have A Zero Range: Cannot Fill Display"
			return
		} else {
			if {$lo > $actvlo($pp_cnt)} {
				set lo $actvlo($pp_cnt)
			} else {
				set hi $actvhi($pp_cnt)
			}
		}
	}
	if {![string match $brkfrm(lo) $lo] || ![string match $brkfrm(hi) $hi]} {
		set brkfrm(hi) $hi
		set brkfrm(lo) $lo
		set brk(range) [expr $hi - $lo]
		UpdateRangeMemory
	 	set new_rangeinfo 1
		RangewiseRedisplayBrk 0 0 $new_rangeinfo
	}
	UpdateBaktrak
}

#------ Restore last brkpoint-display range

proc RestoreLastRangeBrk {} {
	global lastbrk brkfrm baktrak baktemp brk
	incr brk(thisrangeindex) -1
	if {$brk(thisrangeindex) < 0} {
		set brk(thisrangeindex) 0
		return
	}
	DoTempBaktrak
	set new_rangeinfo 0
	set brk(range) 	 [lindex $lastbrk(range) $brk(thisrangeindex)]
	set brkfrm(lo) [lindex $lastbrk(lo) $brk(thisrangeindex)]
	set brkfrm(hi) [lindex $lastbrk(hi) $brk(thisrangeindex)]
	set brkfrm(islog) [lindex $lastbrk(islog) $brk(thisrangeindex)]
	if {![string match $baktemp(lo) $brkfrm(lo)] || ![string match $baktemp(hi) $brkfrm(hi)]} {
	 	set new_rangeinfo 1
	}
	RangewiseRedisplayBrk $baktemp(islog) $brkfrm(islog) $new_rangeinfo
	incr brk(thisrangeindex) -1
	UpdateBaktrak
}

#------ Extend displayed range of brkpnt graph to user specified limits

proc ExtendRangeBrk {} {
	global displ_c brkfrm origbrkfrm brkeditval
	global brk origbrk wstk evv

	if [Flteq $brk(range) $origbrk(range)] {
		Inf "No additional range available."
		return
	}
	DoTempBaktrak
	set rangeischanged 0
	if {$brkfrm(hi) < $origbrkfrm(hi)} {
		set topset 1
		set choice [tk_messageBox -type yesno -message "Extend top of range?" \
					-icon question -parent [lindex $wstk end]]
		if [string match $choice "no"] {
			set topset 0
		}
		if {$topset} {
			ValDialog "Top_of_Range" "l" $brkfrm(hi) $origbrkfrm(hi)
			if {[string length $brkeditval] > 0} {
				set brkfrm(hi) $brkeditval
				set rangeischanged 1
			}				
		}

	}
	if {$brkfrm(lo) > $origbrkfrm(lo)} {
		set botset 1
		set choice [tk_messageBox -type yesno -message "Extend bottom of range?" \
					-icon question -parent [lindex $wstk end]]
		if [string match $choice "no"] {
			set botset 0
		}
		if {$botset} {
			ValDialog "Bottom_of_Range" "h" $origbrkfrm(lo) $brkfrm(lo)
			if {[string length $brkeditval] > 0} {
				set brkfrm(lo) $brkeditval
				set rangeischanged 1
			}				
		}
	}
	if {$rangeischanged} {
		set brk(range) [expr $brkfrm(hi) - $brkfrm(lo)]
		UpdateRangeMemory
		set new_rangeinfo 1
		RangewiseRedisplayBrk 0 0 $new_rangeinfo
	}
	UpdateBaktrak
}

#------ Restore original brkpoint-display range

proc RestoreRangeBrk {} {
	global brk origbrk brkfrm origbrkfrm baktemp

	DoTempBaktrak
	
	set new_rangeinfo 0
	set brk(range) 		$origbrk(range)
	set brkfrm(lo) 	$origbrkfrm(lo)
	set brkfrm(hi) 	$origbrkfrm(hi)
	set brkfrm(islog) $origbrkfrm(islog)

	ResetRangeMemory

	if {![string match $baktemp(lo) $brkfrm(lo)] || ![string match $baktemp(hi) $brkfrm(hi)]} {
	 	set new_rangeinfo 1
	}
	RangewiseRedisplayBrk $baktemp(islog) $brkfrm(islog) $new_rangeinfo
	UpdateBaktrak
}

#########################################
# MOUSE OPERATIONS ON BRKFILE GRAPHICS	#
#########################################

#------ 
# 	Create point at place on edge of inner canvas when mouse clicks on outer-canvas
#		OR a straightforward point on the canvas
#
#
#	 ---------------------------------------
#	| A	:		G			: 	  D			|
#	|...a-------g-----------d----------- ...|
#	|	|	 x				::::::::::::|	|
#	|	|	/ \				::::::::::::|	|
#	|	|  /   \			f:::::::::::| F	|
#	|	| /		\			x:::::::::::|	|
#	| 	|x		 \		   /::::::::::::| 	|
#	| C	c		  \		  /	::::::::::::|	|
#	|	|		   \	 /	::::::::::::|	|
#	|	|			\	/	::::::::::::|	|
#	|	|			 \ /	::::::::::::|	|
#	|	|		      x		::::::::::::|	|
#	|...b-----------h-------e-----------....|
#	| B	:			H		:	  E			|
#	 ---------------------------------------
#

proc CreatePoint {w x y} {
	global brk evv

	set timedgepoint 0

	DoTempBaktrak

	incr x -$evv(BWIDTH)
	incr y -$evv(BWIDTH)

	if {$x <= 0} {						 
		set	timedgepoint -1
		set x 0									 ;# C -> c:	Left edge
		if {$y < 0} {
			set y 0							 	 ;#	A -> a: Top left corner
		} elseif {$y > $evv(YHEIGHT)} {
			set y $evv(YHEIGHT)					 ;#	B -> b: Bottom left corner
		}									 
	} elseif {$x >= $brk(xdisplay_end)} {
		set	timedgepoint 1
		set x $brk(xdisplay_end)				 ;#	F -> f:	Right edge
		if {$y < 0} {
			set y 0								 ;#	D -> d: Top right corner
		} elseif {$y > $evv(YHEIGHT)} {
			set y $evv(YHEIGHT) 				 ;#	E -> e: Bottom right corner
		}
	} elseif {$y < 0} {
		set y 0								 	 ;#	G -> g: Top edge
	} elseif {$y > $evv(YHEIGHT)} {
		set y $evv(YHEIGHT)			 			 ;#	H -> h: Bottom edge
	}
	switch -- $timedgepoint {	
		-1 {
			if {![InjectStartPointIntoLists $y]} {
				return
			} else {
				set redrawpoints 1
			}
		}
		1 {
			if {![InjectEndPointIntoLists $y]} {
				return
			} else {
				set redrawpoints 1
			}
		}
		default {
			if {![InjectPointIntoLists $x $y]} {
				return
			} else {
				set redrawpoints 0
			}
		}
	}
	Get_cResolution
	if {$brk(could_be_maskedge) && ($x == $brk(active_xdisplay_end))} {
		set brk(maskedge) $x
	}
	if {$redrawpoints} {
		DisplayBrktable
	} else {
		DrawPoint $x $y
		DrawGrafLine 1
	}
	UpdateBaktrak
}

#------ Delete point closest to place where mouse clicks on inner-canvas

proc DeletePoint {w x y} {
	global evv brk bkc

	set obj [GetClosestPoint $x $y]
	set coords [$bkc(can) coords $obj]		 	 	;#	Only x-coord required, as can't have time-simultaneous points

	set x [expr round([lindex $coords 0])]			;#	Coords returns floats: convert to int

	#	CONVERT TO CENTRE OF POINT

	incr x $evv(PWIDTH)

	#	CONVERT TO MY COORDS

	incr x -$evv(BWIDTH)

	set indx [FindThisPointInList $x]

	if {$indx > 0 && $indx < $brk(coordend)} {	 ;#	Can't delete brktable endpoints
		DoTempBaktrak
		if {$brk(maskedge) == $x} {
			set brk(maskedge) -1
		}
		catch {$bkc(can) delete $obj} in	 	 ;#	Delete it
		if [RemovePointFromLists $indx] {		 ;#	and remove from listings
			DrawGrafLine 1
		}
		Get_cResolution
		UpdateBaktrak
	}
}

#------ Mark point closest to place where mouse shift-clicks on inner-canvas

proc MarkPoint {w x y} {
	global brkpnt brk bkc displ_c real_c brkval_list evv
	set brk(ismarked) 0														
#MARCH 7 2005
	set brkpnt(obj) [GetClosestPoint $x $y]
	set coords [$bkc(can) coords $brkpnt(obj)]		 	 	
	set brkpnt(x) [expr round([lindex $coords 0])]			;#	Coords returns floats: convert to int
	set brkpnt(y) [expr round([lindex $coords 1])]			;#	as can't have time-simultaneous points

#	CONVERT TO CENTRE OF POINT

	incr brkpnt(x) $evv(PWIDTH)
	incr brkpnt(y) $evv(PWIDTH)

	if {$brkpnt(x) == $evv(BWIDTH)} {
		$brkval_list selection clear 0 end
		$brkval_list selection set 0 0
		return												;#	Can't drag end points
	} elseif {$brkpnt(x) == $brk(xdisplay_end_atedge)} {
		$brkval_list selection clear 0 end
		$brkval_list selection set end end
		return												;#	Can't drag end points
	}

	DoTempBaktrak

	set brkpnt(mx) $x							 			;# 	Save coords of mouse
	set brkpnt(my) $y

	set brkpnt(lastx) $brkpnt(x)							;#	Remember coords of point
	set brkpnt(lasty) $brkpnt(y)						

	#	CONVERT TO MY COORDS, AND SAVE AS orig COORDS

	set brkpnt(origx) $brkpnt(x)
	incr brkpnt(origx) -$evv(BWIDTH)
	set brkpnt(origy) $brkpnt(y)
	incr brkpnt(origy) -$evv(BWIDTH)

	set brkpnt(timindex) [FindMotionLimitsInTimeDimension $brkpnt(origx)]
	if {$brkpnt(timindex) < 0} {
		return
	}
	set listindex [expr $brkpnt(timindex) / 2]
	$brkval_list selection clear 0 end
	$brkval_list selection set $listindex $listindex
	set brkpnt(valindex) $brkpnt(timindex)
	incr brkpnt(valindex)
	set brk(ismarked) 1											;#	Flag that a point is marked
}

#------ Drag marked point, with shift and mouse pressed down

proc DragPoint {w x y} {
	global brkpnt brk bkc brkrightstop brkleftstop displ_c evv

	if {!$brk(ismarked)} {
		return
	}
	set mx $x									 		;#	Map from mouse-coords to canvas-coords
	set my $y						 	
	set dx [expr $mx - $brkpnt(mx)]				 		;#	Find distance from last marked position of mouse
	set dy [expr $my - $brkpnt(my)]
	incr brkpnt(x) $dx									;#	Get coords of dragged point

	if {$brkpnt(x) > $brkrightstop} {					;#	Check for drag too far right, and, if ness
		set brkpnt(x) $brkrightstop						;#	adjust coords of point
		set dx [expr $brkpnt(x) - $brkpnt(lastx)]		;#	and adjust drag-distance
	} elseif {$brkpnt(x) < $brkleftstop} {				;#	Check for drag too far left, and, if ness
		set brkpnt(x) $brkleftstop						;#	adjust coords of point
		set dx [expr $brkpnt(x) - $brkpnt(lastx)]		;#	and adjust drag-distance
	}
	set brkpnt(lastx) $brkpnt(x)						;#	Remember new x coord
  
	incr brkpnt(y) $dy									
	if {$brkpnt(y) > $bkc(mouse_yheight)} {				;#	Check for drag too far down, and, if ness
		set brkpnt(y) $bkc(mouse_yheight)				;#	adjust coords of point
		set dy [expr $brkpnt(y) - $brkpnt(lasty)]		;#	and adjust drag-distance
	} elseif {$brkpnt(y) < $evv(BWIDTH)} {
		set brkpnt(y) $evv(BWIDTH)						;#	adjust coords of point
		set dy [expr $brkpnt(y) - $brkpnt(lasty)]		;#	and adjust drag-distance
	}

	set brkpnt(lasty) $brkpnt(y)						;#	Remember new y coord

	$w move $brkpnt(obj) $dx $dy				 		;#	Move object to new position
	set brkpnt(mx) $mx							 		;#  Store new mouse coords
	set brkpnt(my) $my
	set x [expr round($brkpnt(x) - $evv(BWIDTH))]
	set y [expr round ($brkpnt(y) - $evv(BWIDTH))]
	set valindex $brkpnt(timindex)
	incr valindex
	set displ_c [lreplace $displ_c $brkpnt(timindex) $valindex $x $y]
	DrawGrafLine 1
}

#------ Register position of dragged point, in the coordinates lists

proc RelocatePoint {w} {
	global brkpnt displ_c real_c brkfrm brk evv
	global baktrak canbaktrak

	if {!$brk(ismarked)} {
		return
	}

	set moved 0
	set movedx 0
	set movedy 0

	#	CONVERT TO MY COORDS

	incr brkpnt(x) -$evv(BWIDTH)
	incr brkpnt(y) -$evv(BWIDTH)

	if {$brkpnt(origx) != $brkpnt(x)} {
		if {$brk(could_be_maskedge)} {
			if {$brkpnt(origx) == $brk(maskedge)} {	
				set brk(maskedge) -1
			} elseif {$brkpnt(x) == $brk(active_xdisplay_end)} {
				set brk(maskedge) $brkpnt(x)
			}
		}
		set moved 1
		set movedx 1
	}
	if {$brkpnt(origy) != $brkpnt(y)} {
		set moved 1
		set movedy 1
	}
	if {$moved} {
		UpdateBaktrak
		if {$movedx} {
			set newx [GrafToRealx $brkpnt(x)]
			set real_c [lreplace $real_c $brkpnt(timindex) $brkpnt(timindex) $newx]
		}
		if {$movedy} {
			set newy [GrafToRealy $brkpnt(y) $brkfrm(islog) $brkfrm(lo)]
			set real_c [lreplace $real_c $brkpnt(valindex) $brkpnt(valindex) $newy]
		}
	}
	Get_cResolution
	SeeValsBrk

	set brk(ismarked) 0
}

#------ Delete a point from the coords list & the real_c list

proc RemovePointFromLists {timindex} {
	global displ_c real_c brk 
	set valindex $timindex
	incr valindex
	set displ_c [lreplace $displ_c $timindex $valindex]			
	set real_c [lreplace $real_c $timindex $valindex]
	incr brk(coordcnt) -2
	incr brk(coordend) -2
	set brk(wascut) 1
	return 1
}

#------ Find given point in coords list

proc FindThisPointInList {xa} {
	global displ_c
	set timindex 0
	foreach {x y} $displ_c {
		if [string match $x $xa] {
			return $timindex
		}
		incr timindex 2
	}
	return -1
}

#------ Put a newly created point into the coords list & the real_c list

proc InjectPointIntoLists {x y} {
	global displ_c real_c brkfrm brk
	 
	set timindex 0
	set valindex 1

	foreach {xa ya} $displ_c {
		if [string match $x $xa] {
			return 0					;#	Cannot overwrite existing time
		} elseif {$xa < $x} {
			incr timindex 2
			incr valindex 2
			continue
		}
		set displ_c [linsert $displ_c $timindex $x $y]
		set real_c [linsert $real_c $timindex \
			[GrafToRealx $x] [GrafToRealy $y $brkfrm(islog) $brkfrm(lo)]]
		incr brk(coordcnt) 2
		incr brk(coordend) 2
		set brk(wascut) 1
		return 1
		break
	}
	return 0
}

#------ Put a newly created point into the coords list & the real_c list

proc InjectStartPointIntoLists {y} {
	global displ_c real_c brkfrm brk

	set valindex 1
	if [string match [lindex $displ_c $valindex] $y] {
		return 0
	}
	set displ_c [lreplace $displ_c $valindex $valindex $y]
	set real_c [lreplace $real_c $valindex $valindex \
		[GrafToRealy $y $brkfrm(islog) $brkfrm(lo)]]
	return 1
}

#------ Put a newly created point into the coords list & the real_c list

proc InjectEndPointIntoLists {y} {
	global displ_c real_c brkfrm brk

	set valindex $brk(coordend)
	incr valindex
	if [string match [lindex $displ_c $valindex] $y] {
		return 0
	}
	set displ_c [lreplace $displ_c $valindex $valindex $y]
	set real_c [lreplace $real_c $valindex $valindex \
		[GrafToRealy $y $brkfrm(islog) $brkfrm(lo)]]
	return 1
}

#------ Convert grafpoint time to real timevalue

proc GrafToRealx {x} {
	global qtime brk
	set x [expr $x * $brk(xgraftoval)]
	if {![string match "0" $qtime]} {
		set x [Quantise $x $qtime 0.0 $brk(real_endtime)]
	}
	return $x
}

#------ Convert grafpoint value to real value

proc GrafToRealy {y is_log lo} {
	global evv qval brkfrm brk 
	set y [expr	($evv(YHEIGHT) - $y)]	;#	Invert y-display
	set y [expr $y * $brk(ygraftoval)]	;#	Convert into real range
	if {$is_log} {
		set y [expr pow(10,$y)]			;#	Undo log, then compensate for '1' offset
		set y [expr ($y - 1.0)]
	}
	set y [expr $y + $lo]				;#	Add base of real range
	if {![string match "0" $qval]} {
		set y [Quantise $y $qval $brkfrm(lo) $brkfrm(hi)]
	}
	return $y
}

#------ Find adjacent points to a given point in coords list

proc FindMotionLimitsInTimeDimension {xa} {
	global displ_c brk brkrightstop brkleftstop evv
	set preindex -2
	set timindex 0
	set postindex 2
	foreach {x y} $displ_c {
		if [string match $x $xa] {
			if {$timindex == 0} {
				ErrShow "Got start-point: Impossible"
				return -1
			} elseif {$timindex == $brk(coordend)} {
				ErrShow "Got end-point: Impossible"
				return -1
			} else {
				set brkleftstop  [lindex $displ_c $preindex]
				incr brkleftstop
				set brkrightstop [lindex $displ_c $postindex]
				incr brkrightstop -1
				incr brkrightstop $evv(BWIDTH)
				incr brkleftstop  $evv(BWIDTH)
				return $timindex
			}
		}
		incr preindex 2
		incr timindex 2
		incr postindex 2
	}
#
#	ErrShow "Got NO-point: Impossible"
#
	return -1
}

#------ Delete table beyond point closest to place where mouse clicks on inner-canvas

proc DeleteFromPoint {w x y b obj} {
	global evv brk bkc

	DoTempBaktrak

#MARCH 7 2005
	if {$obj < 0} {
		set obj [GetClosestPoint $x $y]
	}
	set coords [$bkc(can) coords $obj]					;#	Only x-coord needed: can't have time-simultaneous points
	set x [expr round([lindex $coords 0])] 	 			;#	Only x-coord required, as can't have time-simultaneous points

	#	CONVERT TO CENTRE OF POINT

	incr x $evv(PWIDTH)

	#	CONVERT TO MY COORDS

	incr x -$evv(BWIDTH)

	set indx [FindThisPointInList $x]
	if {$indx < 0} {
		ErrShow "Failed to find indicated point in coordinates list: DeleteFromPoint"
		return
	}
	if {$indx == 0 || $indx >= $brk(coordend)} {	 ;#	Can't delete entire display, or none of display
		return
	}
	CutTableAtDisplayedPoint $x $indx $b
	UpdateBaktrak
}

#------ Cut a breaktable display (and assocd coords) at user specified point

proc CutTable {w x y b} {
	global evv brk bkc brkfrm 

	#	GENERATE MY COORDS

	set xx [expr $x - $evv(BWIDTH)]
	set yy [expr $y - $evv(BWIDTH)]

	if {$xx <= 0 || $xx >= $brk(xdisplay_end)} {	;# 	Can't cut table at zero 
		return										;#	or at or after end of displayed points
	}
	set displaylist [$bkc(can) find withtag points]	;#	List all objects which are points

	foreach obj $displaylist {						;#	For each point
		set coords [$bkc(can) coords $obj]			;#	Only x-coord needed: can't have time-simultaneous points
		set objx [expr round ([lindex $coords 0])]	;#	Only x-coord needed: can't have time-simultaneous points
#2005 MARCH 7th
		set objx-2 [expr $objx - $evv(PWIDTH)]		;#	Find the enclosing x-coords of the point.
		set objx2 [expr $objx + $evv(PWIDTH)]		;#	Find the enclosing x-coords of the point.
		if {$x >= $objx-2 && $x <= $objx2} {		;#	If mouse has clicked at time-position of existing point
			DeleteFromPoint $w $x $y $b $obj		;#	NB USES ACTUAL outer-canvas COORDS
			return
		}
	}
	DoTempBaktrak
	set new_brkendtime [GrafToRealx $xx]		 	;#	End of current brktable (not ness of displayframe)
	if {![SpliceReal_c $new_brkendtime]} {
		return
	}

	set display_endtime [ReconfigureDisplay $xx]
	if {$display_endtime < 0} {
		return
	}

	TimewiseRedisplayBrk $display_endtime $b
	UpdateBaktrak
}


#------ Cut a breaktable display (and assocd coords) at existing displayed point

proc CutTableAtDisplayedPoint {x indx b} {
	global displ_c real_c c_res good_res brkfrm brk evv
	global brkfrm baktemp 

	set brk_endtime [lindex $real_c $indx]
	if {$x < $brk(active_xdisplay_end)} {		;#	If table cut in active area, both table and frame are shortened
		set display_endtime $brk_endtime		;#	case (A)
	} else {								 	;#	case (B)
		set display_endtime $brkfrm(endtime)	;#	Else, the frame remains where it is
	}
	incr indx

	set real_c "[lrange $real_c 0 $indx]"

	Get_cResolution
	CheckBrkfileDisplayResolution $brk_endtime 0
	if {!$good_res} {
		set real_c 		  	"$baktemp(real_c)"
		set c_res 	"$baktemp(c_res)"
		set brk(coordcnt)   	$baktemp(coordcnt)
		set brk(coordend)   	$baktemp(coordend)
		set good_res 1
		return 0
	}
	set brk(real_endtime) $brk_endtime

	set display_endtime [ReconfigureDisplay $x]
	if {$display_endtime < 0} {
		return
	}

	set displ_c "[lrange $displ_c 0 $indx]"
	set brk(coordcnt) [llength $real_c]
	set brk(coordend) [expr int($brk(coordcnt) - 2)]
	TimewiseRedisplayBrk $display_endtime $b
	return 1
}

#------ Redisplay brkfile, when time-dimension of display has been altered, altering brkfrm-time-end

proc TimewiseRedisplayBrk {display_endtime b} {
	global brkfrm baktrak canbaktrak brk

	TimewiseClearBrkDisplay $b					;#	retains range-texts, and existing REALcoords
	set brkfrm(endtime) $display_endtime		;#	Change endtime function of brktable
	SetBrkDisplayTimeParams						;#	setup params relating to masks, if any
	DisplayBrkEndtime							;#	Alter display on time-axis
	EstablishGrafToRealConversionConstants_x	;#	Recalculate time-axis display-conversion-constants
	ReplotBrkfileDisplayX_c					;#	Recalculate x coordinates of display
	BrkDisplayMasks								;#	Display any masks
	DrawGrafPoints								;#	Redraw points
	DrawGrafLine 1								;#	Redraw grafline
}

#------ Clear the brkdisplay when time-coordinates (only) altered

proc TimewiseClearBrkDisplay {b} {
	global displ_c brkfrm brk bkc
	catch {$bkc(can) delete cline}  in
	catch {$bkc(can) delete points} in
	catch {$bkc(can) delete endinfo} in
	catch {$bkc(can) delete greyout} in								 ;#	Clear any masks
	catch {$bkc(can) delete message} in								 ;#	Clear any masks
	ForceVal $b.name $brk(name)
}

#------ Time-rescale display coords from real coords

proc ReplotBrkfileDisplayX_c {} {
	global real_c displ_c brkfrm brk
	set indx 1

	catch {unset displ_c}
	foreach {time val} $real_c {
		lappend displ_c [RealToGrafx $time] [RealToGrafy $val $brkfrm(lo) $brkfrm(islog)]
	}
	set brk(coordcnt) [llength $real_c]
	set brk(coordend) [expr int($brk(coordcnt) - 2)]
	if {$brk(could_be_maskedge)} {
		set brk(maskedge) [SetMaskedge]
	}
}

#------ Reset display-state, especially in relatin to masking
#
#	(1)	  WHERE BRKPOINTS LONGER 						 
#	    THAN SPECFIED DISPLAY FRAME				     
#  $active_xdisplay_end != $evv(XWIDTH)
#				  |				
#				  |				
#			   	  |													  xdisplay_end
#		 -----------------------				 -----------------------			
#		|	x	  ::::::::::::::|				|	x	  ::::::::::::::|			
#		|  / \	  :::x----x:::::|				|  / \	  :::x----x:::::|			
#		| /	  \	  ::/::::::\::::|	------->>	| /	  \	  ::/::::::\::::|			
#		|x	   \  :/::::::::\:::|				|x	   \  :/::::::::\:::|			
#		|		\ /::::::::::\::|				|		\ /::::::::::\::|			
#		|		 x::::::::::::\:|				|		 x::::::::::::\:|			
#		|		  :::::::::::::\|				|		  :::::::::::::\|			
#		|		  ::::::::::::::x				|		  ::::::::::::::x			
#		 -----------------------				 -----------------------			
# 				 brkfrm		real_endtime			brkfrm		real_endtime
#				 (endtime)								(endtime)
#
#
#		(A)	   | Cut here, 								(B)		| Cut here
#			   | before active_xdisplay_end						| after active_xdisplay_end
#			   |												|
#		 ------|-								 ---------------|
#		|	   |:|	active_xdisplay_end ->MAX	|		  ::::::|	xdisplay_end STAYS
#		|	x  |:|								|	x	  ::::::|
#		|  / \ |:|	xdisplay_end ->	RATIO		|  / \	  :::x--x	active_xdisplay_end RATIO
#		| /	  \|:|								| /	  \	  ::/:::|
#		|x	   x:|								|x	   \  :/::::|
#		|	   |:|								|		\ /:::::|
#		|	   |:|								|		 x::::::|
#		|	   |:|								|		  ::::::|
#		 -----------------------				 -----------------------				 
# 			  brkfrm		real_endtime				brkfrm	real_endtime
#			  (endtime)		<-----						(endtime)	<-----
#				STAYS									 STAYS
#
#
#	(2)	  WHERE BRKPOINTS LONGER 						 
#	    THAN SPECFIED DISPLAY FRAME				     
#  $xdisplay_end != $evv(XWIDTH)
#				  |				
#				  |				
#			   	  |												
#		 -----------------------				 -----------------------			
#		|	x	  ::::::::::::::|				|	x	  ::::::::::::::|			
#		|  / \	  ::::::::::::::|				|  / \	  ::::::::::::::|			
#		| /	  \	  ::::::::::::::|				| /	  \	  ::::::::::::::|			
#		|x	   \  ::::::::::::::|				|x	   \  ::::::::::::::|			
#		|		\ ::::::::::::::|				|		\ ::::::::::::::|			
#		|		 x::::::::::::::|				|		 x::::::::::::::|					
#		|		  ::::::::::::::|				|		  ::::::::::::::|			
#		 -----------------------				 -----------------------			
# 				 real			brkfrm				real			brkfrm
#				 				(endtime)								(endtime)
#					
#
#		(C)	   | Cut here, 								(D)		| Cut here
#			   | before xdisplay_end							| after xdisplay_end
#			   |												|
#		 ------|----------------				 ---------------| FORBIDDEN
#		|	   |:xdisplay_end -> RATIO			|		  ::::::| (autoset frame MUST be in use)
#		|	x  |::::::::::::::::|				|	x	  ::::::|
#		|  / \ |::::::::::::::::|				|  / \	  ::::::|	(But FILL can be used)
#		| /	  \|::::::::::::::::|				| /	  \	  ::::::|	
#		|x	   x::::::::::::::::|				|x	   \  ::::::|
#		|	   |::::::::::::::::|				|		\ ::::::|
#		|	   |::::::::::::::::|				|		 x::::::|
#		|	   |::::::::::::::::|				|		  ::::::|
#		 -----------------------				 -----------------------				 
# 			  real_endtime	brkfrm					
#			  <-----		(endtime)				  
#							STAYS					
#
#
#	(3)	  WHERE BRKPOINTS SAME LENGTH
#	    	AS SPECFIED DISPLAY FRAME				     
#
#		 -----------------------	
#		|	x	                |		If AUTOSEET, cant cut	(E)	
#		|  / \	     x----x     |	
#		| /	  \	    /      \    |	
#		|x	   \   /        \   |	
#		|		\ /          \  |
#		|		 x            \ |
#		|		               \|
#		|		                x
#		 -----------------------
# 				 			real_endtime
#				 			brkfrm(endtime)
#
#
#		(F)	   | Cut here (not AUTOSET)
#			   | 
#			   |
#		 ------|
#		|	   | active_xdisplay_end STAYS as MAX
#		|	x  |
#		|  / \ | xdisplay_end STAYS as MAX
#		| /	  \|
#		|x	   x
#		|	   |
#		|	   |
#		 -----------------------
# 			  			<--real_endtime
#						<--brkfrm(endtime)		
#

proc ReconfigureDisplay {x} {
	global brk brkfrm evv

	#	DISPLAY WITH NO MASK

	if {$brk(xdisplay_end) == $evv(XWIDTH) && $brk(active_xdisplay_end) == $evv(XWIDTH)} {
 		if {$brk(time_autoset)} {
			return -1										;#	IF AUTOSET, CAN'T BE CUT							
		} else {										
			set display_endtime $brk(real_endtime)		;#	ELSE: DISPLAY ENDTIME BECOMES END OF BRKTABLE
		}			
	} else {

	#	DISPLAY WITH MASK : DISPLAY ENDTIME DOES NOT MOVE

		set display_endtime $brkfrm(endtime)			

	#	IF BRKTABLE DOES NOT EXTEND ACROSS FRAME, AND WE CUT BEYOND END OF BRKTABLE

		if {$brk(active_xdisplay_end) != $evv(XWIDTH) && $x > $brk(active_xdisplay_end)} {
			if {$brk(time_autoset)} {
				set brk(autosetframe_in_use) 0			;#	FRAME HAS BEEN CUT, SO AUTOSET NO LONGER IN USE
			}											
		}
	}
	return $display_endtime
}

################################
# EDITING BRKFILES GRAPHICALLY #
################################

#------ Edit a brkfile

proc Dlg_EditBrkfile {fnam pcnt gcnt} {
	global get_brkfile pr_brkfile pr_textfile pr_brkname parname brk brk_extname evv
	global sfbbb brkedit_emph brkfrm actvhi actvlo brklmtval pa qtime qval bfw small_screen

	if {$brk(from_wkspace)} {
		if {![EstablishBrkLimitvals 1 $fnam]} {
			return 0
		}
	} else {
		set par_name [StripName	$parname($gcnt)]
	}	
	if {[info exists brkfrm(hi)] && [info exists brkfrm(lo)]} {
	 	if {$brk(from_wkspace)} {
			if {$brklmtval(lo) < $brkfrm(lo) || $brklmtval(hi) > $brkfrm(hi)} {
				set brkfrm(lo) $brklmtval(lo)
				set brkfrm(hi) $brklmtval(hi)
				set brk(range) [expr $brkfrm(hi) - $brkfrm(lo)]
			}
		} elseif {$actvlo($pcnt) < $brkfrm(lo) || $actvhi($pcnt) > $brkfrm(hi)} {
			set brkfrm(lo) $actvlo($pcnt)
			set brkfrm(hi) $actvhi($pcnt)
			set brk(range) [expr $brkfrm(hi) - $brkfrm(lo)]
		}
	}
	if [Dlg_Create .get_brkfile "" "set pr_brkfile 0 ; set pr_brkname 0" -borderwidth $evv(BBDR)] {
		EstablishBrkfileWindow .get_brkfile $pcnt $gcnt
	}
	if {$small_screen} {
		set bfw .get_brkfile.c.canvas.f
	} else {
		set bfw .get_brkfile
	}	
	SetTimeQuantiseOff
	SetValQuantiseOff
	wm resizable .get_brkfile 1 1
	set brk(fill_label) "Remove Masked Area"
	set brk(fill_cmd) "FillTimeBrk $sfbbb"
	set brk(is_brkediting) 1
	set brk(ismarked) 0
	set brk(could_be_maskedge) 0
	set brk(maskedge) -1
	set brk(greymask) -1
	if {$brk(from_wkspace)} {
		wm title .get_brkfile "Edit a Breakpoint File"				;#	Force title
	} else {
		wm title .get_brkfile "Edit a Breakpoint File: $par_name"	;#	Force title
	}
	$sfbbb.load config -text "Another File" -command "set pr_brkfile 0" -state normal -bd $evv(SBDR)

	catch {unset brkedit_emph}

	if {$brk(from_wkspace)} {
		$sfbbb.use config  -text "" -borderwidth 0 -bg [option get . background {}] -command {}
	} else {
		$sfbbb.use config  -text "Use" -borderwidth $evv(SBDR) -width 4 -bg $evv(EMPH) \
			-command "set pr_brkfile $evv(USEBRK) ; set pr_textfile 0"
		lappend brkedit_emph $sfbbb.use
	}
	set good_brkfile [SetupBrkfileForEditing $bfw $fnam $pcnt $gcnt]
	if {$good_brkfile <= 0} {
		Dlg_Dismiss .get_brkfile
		return $good_brkfile
	}
	raise .get_brkfile
	update idletasks
	StandardPosition .get_brkfile
	My_Grab 0 .get_brkfile pr_brkfile											
	BrkfileMagic $brk_extname $pcnt			;#	Edit and give it a name
	My_Release_to_Dialog .get_brkfile	 	;#	Return to calling dialog
	Dlg_Dismiss .get_brkfile
	return 1
}

#------ Deal with a brkfile entered for editing: display it, edit it, save it etc.

proc SetupBrkfileForEditing {f fnam pcnt gcnt} {
	global actvhi actvlo islog brk brk_extname parname evv
	global pr_brkfile brklmtval pa zero

	if {$brk(from_wkspace)} {
		wm title .get_brkfile "EDIT BREAKPOINT FILE"					;#	Force title
	} else {
		set par_name [StripName	$parname($gcnt)]
		wm title .get_brkfile "EDIT BREAKPOINT FILE : for $par_name"	;#	Force title
	}
	set brk(time_constrained) 1
	set brk(maxrangeindex) -1
	set fnam [string trim $fnam]
	if {[string length $fnam] <= 0} {
		Inf "No filename entered."
		return 0
	}
	DeactivateBrkdisplayOptions							;#	Deactivate all the display-modification options
	FullClearBrkDisplay $f.btns							;#	Clear any existing display
	set brk(name) $fnam
	ForceVal $f.btns.name $brk(name)
	set brk(wascut) 0									;#	No points added or removed

	if {$brk(from_wkspace)} {

	#	DURATION AND RANGE SPECIFIED BY USER

		set lo $brklmtval(lo)
		set hi $brklmtval(hi)
		set is_log $brklmtval(islog)
	} else {

	#	DURATION AND RANGE SPECIFIED BY INFILE AND PROCESS

		set lo $actvlo($pcnt)
		set hi $actvhi($pcnt)
		set is_log $islog($gcnt)
	}

	if {![SetAndStoreBrkLimitvals $lo $hi $is_log $pa($fnam,$evv(DUR)) $pcnt]} {
		return 0
	}

	#	ESTABLISH THE REAL COORDS OF THE BRKTABLE DATA (OR DISCOVER THEY'RE INAPPROPRIATE)
	#	DEALS WITH BRKFILE BEING OUT-OF-(VALUE)RANGE, BY USER-SANCTIONED TRUNCATION

	ClearRealAndDisplayCoordinates						;#	Clear any existing coordinate vals.
	set good_brkfile [SetupBrkfileReal_c $fnam $pcnt]
	if {$good_brkfile <= 0} {						
		return $good_brkfile										
	}
	SetBrkDisplayTimeParams								;#	Is brkfile same length as that required by infile?
	SaveBrkframeInputs $lo $hi $is_log
	EstablishGrafToRealConversionConstants
	SetupBrkfileDisplay_c							;#	Establish display-coords of points.

	set brk(wascut) 0
	set zero(last_lo) $evv(GARBAGE)						;#	These values remember state of zeroline,
	set zero(last_islog) $evv(GARBAGE2)					;#  to ensure its not constantly recalculated
	set zero(last_yvaltograf) $evv(GARBAGE2)			;#  Garbage vals ensure it IS calculated first time round
	BrkDisplayMasks										;#	Create appropriate masks on display.
	SaveOriginal_c									;#	Save these start vals in case want to restore.
	InitialiseBaktrak									;#	Save inital state of system, for baktraking
	SetupAxes											;#	Draw limit vals on axes, and zeroline if ness
	DisplayBrktable										;#	Draw graf on screen
	set brk_extname [file extension $brk(name)]			;#	And post stripped-down name in filename-box

	ActivateBrkdisplayOptions 							;#	Activate (appropriate items) on OPTIONS menu

	set pr_brkfile 0
	return 1
}

#------ Setup a window to create or edit a brkfile
#
#	 ---------------------------------------------------------------------------------------------
#	| ----  ----  ----  ---	 ____________    ----  -----------------   ----  --------  ---------  |
#	||QUIT||LOAD||SAVE||USE|[____________]  |HELP||   OPTIONS	    | |UNDO||SEE VALS||HIDE VALS| |
#	| ----  ----  ----  ---	  (filename)     ---- |---------------  |  ----  --------  ---------  |
#	|											  |Lengthen		    |						  	  |
#	|											  |Shorten 		    |						  	  |
#	|	   A -------------------------------------|Time Stretch By  |-------------------	      |
#	|		|									  |Time Stretch To  |				  | |	      |
#	|		|									  |Time Shrink By   |				  | |	      |
#	|		|									  |Time Shrink To   |				  | |	      |
#	|		|									  |Remove Masked Area|				  | |		  |
#	|		|									  |New Timerange    |				  | |	 	  |
#	|		|									  |Orig Timerange   |				  | |	 	  |
#	|		|									  |Fill Valrange    |				  | |	 	  |
#	|		|									  |Extend Valrange  |				  | |	      | 
#	|		|									  |Log display      |				  | |	      | 
#	|		|									  |Previous Valrange|				  | |	      |
#	|		|									  |Next Valrange    |				  | |	      |
#	| 		|									  |Original Valrange|				  | |	 	  |
#	|"value"|									  |Start Again	    |				  | |	      |
#	|		|									   -----------------				  | |	      |
#	|		|																		  | |	      | 
#	|	    |---------------------------------------------------------------------------|0    	  | 
#	|		|																		  | |	      |
#	| 		|																		  | |	      |
#	|		|																		  | |	      |
#	|		|																		  | |	      |
#	|		|-------------------------------------------------------------------------  |	      |
#	|	   B --------------------------------------------------------------------------- 	   	  |
#	|		 C					   			"time"								  		D	      |
#	|																						      |
#	 ---------------------------------------------------------------------------------------------
#
#
#	 -------------------------------------------------------------------------------
#	|							^													|
#	|							|										   			|
#	|					  bwidth|										   			|
#	|							|										   			|
#	|		<-------------------|-------- xwidth ------------------------> 			|
#	|	     -------------------V------------------------------------------- 		|
#	|	^	|															  |	|		|
#	|	|	|															  |	|		|
#	| bwidth|															  |	|bwidth	|
#	|<----->|															  |	|<----->|
#	|	|	|															  |	|		|
#	|	|	|															  |	|		|
#	|	|	|															  |	|		|
#	| ywidth|															  |	|		|
#	|	|	|															  |	|		|
#	|	|	|															  |	|		|
#	|	|	|															  |	|		|
#	|	V	|															  | |		|
#	|	   ^|-------------------------------------------------------------	|		|
#	|pwidth| ---------------------------------------------------------------- 		|
#	|		  					^		   								  <-> 		|
#	|							|										 pwidth		|
#	|					  bwidth|									  (width of a	|
#	|							|									  graph point)	|
#	 ---------------------------V---------------------------------------------------

proc EstablishBrkfileWindow {f pcnt gcnt} {
	global pr_brkfile pr_brkname brkopt brkoptions qtime qval readonlyfg readonlybg
	global brk evv bkc
 	global sfbbb fine_tune
 	global brkedit_hlp_actv brkedit_actv brkedit_naming
	global brkval_list bfw small_screen
	global gg_cnt pp_cnt
	set gg_cnt $gcnt
	set pp_cnt $pcnt

	catch {destroy .cpd}

	set brkedit_hlp_actv 0
	set brkedit_actv 1
	set brkedit_naming 0

	if {$small_screen} {
		set can [Scrolled_Canvas $f.c -width $evv(SMALL_WIDTH) -height $evv(SMALL_HEIGHT) \
							-scrollregion "0 0 $evv(BRKF_WIDTH) $evv(SCROLL_HEIGHT)"]
		pack $f.c -side top -fill x -expand true
		set k [frame $can.f -bd 0]
		$can create window 0 0 -anchor nw -window $k
		set bfw $k
	} else {
		set bfw $f
	}	

	#	HELP AND QUIT

	set help [frame $bfw.help -borderwidth $evv(SBDR)]
	pack $help -side top -fill x -expand true
	button $help.hlp -text "Help" -command "ActivateHelp $bfw.help" -width 4  -highlightbackground [option get . background {}] ;# -bg $evv(HELP) 
	label  $help.conn -text "" -width 13
	button $help.con -text "" -borderwidth 0 -state disabled -width 8 -highlightbackground [option get . background {}]
	label $help.help -width 84 -text "$evv(HELP_DEFAULT)" -fg [option get . foreground {}]
	if {$evv(NEWUSER_HELP)} {
		button $help.starthelp -text "New User Help" -command "GetNewUserHelp brkfile"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
	}
	button $help.quit -text "End Session" -command "DoWkspaceQuit 0 0"  -highlightbackground [option get . background {}];# -bg $evv(QUIT_COLOR)
	bind $bfw <Control-Command-Escape> "DoWkspaceQuit 0 0"
#MOVED TO LEFT
	pack $help.quit -side left
	if {$evv(NEWUSER_HELP)} {
		pack $help.hlp $help.conn $help.con $help.help $help.starthelp -side left
	} else {
		pack $help.hlp $help.conn $help.con $help.help -side left
	}
#MOVED TO LEFT
#	pack $help.quit -side right

	#	BUTTONS

	set sfbbb [frame $bfw.btns -borderwidth 0]
	button $sfbbb.abdn 	  -text "Close" -width 4 -command "set pr_brkfile 0 ;  set pr_textfile 0"  -highlightbackground [option get . background {}]
	button $sfbbb.calc    -text "Calc" -width 4  -command "MusicUnitConvertor 0 0"  -highlightbackground [option get . background {}];# -bg $evv(HELP) 
	button $sfbbb.ref     -text "Refr" -width 4  -command "RefSee 0"  -highlightbackground [option get . background {}] ;# -bg $evv(HELP)
	button $sfbbb.load    -text ""  -width 12    -command {} -highlightbackground [option get . background {}]
	button $sfbbb.save 	  -text "Save" -width 4  -command "set pr_brkfile $evv(SAVEBRK)" -highlightbackground [option get . background {}]
	label $sfbbb.dumm	-text "             "
	button $sfbbb.use 	  -text "Use"  -width 4  -borderwidth $evv(SBDR) -bg $evv(EMPH) \
		-command "set pr_brkfile $evv(USEBRK) ; set pr_textfile 0"  -highlightbackground [option get . background {}]
	label  $sfbbb.lab	  -text "New Name" -width 9
	entry  $sfbbb.name	  -textvariable brk(name)
	checkbutton $sfbbb.ftune -text "FineTune" -variable fine_tune
	menubutton $sfbbb.mouse -text "Mouse" -width 7 -menu $sfbbb.mouse.help -relief raised
	menu $sfbbb.mouse.help -tearoff 0
	set brkopt [menubutton $sfbbb.options -text "Options" -width 9 -menu $sfbbb.options.brko -relief raised]
	button $sfbbb.undo    -text "Undo"        -width 4 -command "BrkUndo $sfbbb" -highlightbackground [option get . background {}]
	button $sfbbb.resto   -text "Start Again" -width 9 -command "RestoreOrigBrkframeDisplaySetup $sfbbb" -highlightbackground [option get . background {}]

	pack $sfbbb.load $sfbbb.dumm $sfbbb.save $sfbbb.lab $sfbbb.name $sfbbb.use $sfbbb.ftune  -side left -padx 1
	pack $sfbbb.mouse $sfbbb.options -side left -padx 1 -ipady 2
	pack $sfbbb.undo $sfbbb.resto $sfbbb.calc $sfbbb.ref -side left -padx 1
	pack $sfbbb.abdn -side left -padx 3

	set brkoptions [menu $sfbbb.options.brko -tearoff 0]
	$brkoptions add command -label "Fill Value Range"    	-command "FillRangeBrk" -foreground black
	$brkoptions add command -label "Extend Value Range"  	-command "ExtendRangeBrk" -foreground black
	$brkoptions add command -label "Previous Value Range" 	-command "RestoreLastRangeBrk" -foreground black
	$brkoptions add command -label "Original Value Range" 	-command "RestoreRangeBrk" -foreground black
	$brkoptions add command -label ""  -command {}	;#	TRUE LABEL AND COMMAND SET ELSEWHERE
	$brkoptions add command -label "Remove Time Constraints" -command "NoTimeConstraints $sfbbb" -foreground black
	$brkoptions add command -label "" -command {}
	$brkoptions add command -label "Lengthen Table"    	 -command "LengthenBrk $sfbbb"	 -foreground black
	$brkoptions add command -label "Shorten Table"	   	 -command "ShortenBrk $sfbbb"	 -foreground black
	$brkoptions add command -label "Time Stretch By"   	 -command "TstretchBrk by $sfbbb" -foreground black
	$brkoptions add command -label "Time Stretch To"   	 -command "TstretchBrk to $sfbbb" -foreground black
	$brkoptions add command -label "Time Shrink By"    	 -command "TshrinkBrk by $sfbbb" -foreground black
	$brkoptions add command -label "Time Shrink To"    	 -command "TshrinkBrk to $sfbbb" -foreground black
	$brkoptions add command -label "Original Timeset"	 -command "RestoreBrkdur $sfbbb" -foreground black

	$sfbbb.mouse.help add command -label "MOUSE AND KEYBOARD OPERATIONS" -command {} -foreground black
	$sfbbb.mouse.help add command -label "Mouse Click................Add point" -command {} -foreground black
	$sfbbb.mouse.help add command -label "Control Mouse Click........Delete point" -command {} -foreground black
	$sfbbb.mouse.help add command -label "Shift Mouse Drag...........Drag point" -command {} -foreground black
	$sfbbb.mouse.help add command -label "Control Shift Mouse Click..Delete table from nearest point" -command {} -foreground black
	$sfbbb.mouse.help add command -label "Control Command Mouse Click....Delete table from marked time" -command {} -foreground black
		
	# SPACING FRAME

	frame $bfw.priti1 -height 8 -width 20

	#	CANVAS AND VALUE LISTING

	set bkc(can) [canvas $bfw.c -height $bkc(height) -width $bkc(width) -borderwidth 0 \
		-highlightthickness 1 -highlightbackground $evv(SPECIAL)]
	frame $bfw.priti2 -height 20 -width 4
	set z [frame  $bfw.l -borderwidth $evv(SBDR)]

	set zq [frame $z.quantise -borderwidth $evv(SBDR)]

	label $zq.lab -text "Quantise" -width 9
	button $zq.ton -text "On"	-width 2 -command "SetTimeQuantise" -highlightbackground [option get . background {}]
	button $zq.tof -text "Off"	-width 2 -command "SetTimeQuantiseOff" -highlightbackground [option get . background {}]
	entry $zq.te -textvariable qtimex -width 4 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
	button $zq.von -text "On"	-width 2 -command "SetValQuantise" -highlightbackground [option get . background {}]
	button $zq.vof -text "Off"	-width 2 -command "SetValQuantiseOff" -highlightbackground [option get . background {}]
	entry $zq.ve -textvariable qvalx -width 4 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
	pack $zq.te $zq.ton $zq.tof $zq.lab $zq.von $zq.vof $zq.ve -side left

	set brkval_list [Scrolled_Listbox $z.ll -width 32 -height 30 -selectmode single]
	set zyz [frame $z.z -borderwidth $evv(SBDR)]
	label $zyz.brktime  -text "TIME"
	label $zyz.brkval   -text "VALUE"
	pack  $zyz.brktime -side left
	pack  $zyz.brkval  -side right
	frame $brkval_list.f -bd 0

	pack $z.z $z.quantise $z.ll -side top -fill both -expand true
	pack $bfw.btns -side top -fill x 
	pack $bfw.priti1 -side top -fill both -expand true
	pack $bfw.c $bfw.priti2 $bfw.l -side left -fill both

	$bkc(can) create rect $bkc(rectx1) $bkc(recty1) $bkc(rectx2) $bkc(recty2) -tag outline -outline $evv(BRKTABLE_BORDER)
	$bkc(can) create text 12 12 -text "LOG DISPLAY" -fill [option get . background {}] -anchor w -tag logdisp

	bind $bkc(can) <ButtonRelease-1> 				{CreatePoint %W %x %y}
	bind $bkc(can) <Control-ButtonRelease-1>		{DeletePoint %W %x %y}
	bind $bkc(can) <Shift-ButtonPress-1> 			{MarkPoint %W %x %y}
	bind $bkc(can) <Shift-B1-Motion> 				{DragPoint %W %x %y}
	bind $bkc(can) <Shift-ButtonRelease-1>			{RelocatePoint %W}
	bind $bkc(can) <Control-Shift-ButtonRelease-1> 	{DeleteFromPoint %W %x %y $sfbbb -1}
	bind $bkc(can) <Control-Command-ButtonRelease-1>	{CutTable %W %x %y $sfbbb}
}	

#------ Refresh list of coords

proc SeeValsBrk {} {
	global real_c brkval_list evv
	$brkval_list delete 0 end
	set spacer "    "
	set resolen 14						  	;#	SYSTEM DEPENDENT, ???
	set resend $resolen
	incr resend -1
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
		$brkval_list insert end $time
	}
}

#------ Deactive the OPTIONS on the brkfile page

proc DeactivateBrkdisplayOptions {} {
	global brkopt
	$brkopt config -state disabled
}

#------ Clear brkpoint display completely (must always be followed by points insertion!)

proc FullClearBrkDisplay {b} {
	global brk bkc
	catch {$bkc(can) delete cline}  in
	catch {$bkc(can) delete points} in
	catch {$bkc(can) delete rangeinfo} in
	catch {$bkc(can) delete zinfo} in
	catch {$bkc(can) delete endinfo} in
	catch {$bkc(can) delete greyout} in
	catch {$bkc(can) delete message} in
	set brk(greymask) -1
	set brk(name) ""
	ForceVal $b.name $brk(name)
}

#------ Establish end TIME, and range limits, for brktable display.

proc SetAndStoreBrkLimitvals {lo hi is_log inbrkdur pcnt} {
	global ins chlist brkdurflag pa brkfrm evv
	global brkfrm origbrkfrm origbrk is_file_edit brk

	set brk(autosetframe_in_use) 0

	#	EDIT BRKFILE AFTER RESOLUTION OVER WHOLE SNDFILE-TO-WHICH-IT-IS-APPLIED BECOMES BAD

	if {$brk(short_table)} {
		set brkfrm(endtime) $inbrkdur					 ;#	Set up a display of length of brktable, 
		set brk(time_autoset) 1					 	 	 ;#	and FIX it (can't be time-changed)
		set brk(autosetframe_in_use) 1						 
		set brk(endtimeset) 0							 ;#	In case another brktable called
		return 1

	#	EDIT OR CREATE BRKFILE FROM WORKSPACE PAGE

	} elseif {$brk(from_wkspace)} {
		if {$is_file_edit} {
			set brkfrm(endtime) $inbrkdur
		} else {
			if {![GetBrkDur]} {
				return 0
			}
			set brk(real_endtime) $brkfrm(endtime)
		}
		set brk(time_autoset) 0
		if {![SetupDisplayRangeConstants $lo $hi $is_log]} {
			return 0
		}
		set brk(endtimeset) 0
		return 1

	#	EDIT OR CREATE BRKFILE WHERE THE BRKFILE ENDTIME IS ALREADY SET (AS ANOTHER PARAM ALSO USED IT)

	} elseif {$brk(endtimeset) > 0} {					 ;#	IF endtime known for this process, or ins
		set lastpcnt [expr int(round($brk(endtimeset) - 1))]
		if {$brk(time_autoset)} {						 ;# if set automatically from insoundfile duration....
			set brkfrm(endtime) $origbrkfrm(endtime) ;#	restore it
			set brk(autosetframe_in_use) 1						 
		} elseif {$is_file_edit} {						 ;# else if editing existing file, 
			set brkfrm(endtime) $inbrkdur	 			 ;# set endtime from in (brk)file endtime,
		} else {
			if {![GetBrkDur]} {					 	 ;# else get user to specify a duration
				return 0									;# for both brktable and brkfile (same) 		
			}
		}
		if {!$is_file_edit} {							 ;#	If not editing an exisitng file
			set brk(real_endtime) $brkfrm(endtime)	 ;#	real duration of infile = duration of frame
		}
		if {($pcnt == $lastpcnt) && ($brkfrm(lo) == $lo) && ($brkfrm(hi) == $hi)} {
		;# If still working on same parameter, and range has not changed
			ResetRangeMemory							 ;#	Reset the hst of ranges, for this file
		} else {
			if {![SetupDisplayRangeConstants $lo $hi $is_log]} {
				return 0
			}
		}
		return 1												 

	#	EDIT OR CREATE BRKFILE APPROPRIATE TO SNDFILE TO WHICH IT WILL BE APPLIED

	} else {
		set oklist 0
		set infilelist ""
		if {$ins(create)} {							 	 ;# ELSE
			if [info exists ins(chlist)] {
				set infilelist "$ins(chlist)"		 ;#	Get appropriate infile list
			}
		} elseif [info exists chlist] {
			set infilelist "$chlist"				 
		}													 
		if {[llength $infilelist] > 0} {
			set oklist 1
			set sndfile_dur $pa([lindex $infilelist 0],$evv(DUR))
		}
															 ;# If this is NOT a (do)ins, and there are infiles
															 ;#	& brkfrm-dur flagged to be set to duration of sndinfile
		if {!$ins(run) && $oklist && $brkdurflag} {							 	 
			set brkfrm(endtime) $sndfile_dur				 ;#	flag time-(thus)-automatically-set
			set brk(time_autoset) 1					 	 	 
			set brk(autosetframe_in_use) 1						 
		} else {											 ;#	ELSE
			if {$is_file_edit} {							 ;# it's a (do)ins, a process with no infiles, or a process
				set brkfrm(endtime) $inbrkdur				 ;# in which brkfiledur cannot be set from insndfile dur
															 ;# In which case, set frame dur to length of brkpnt file(brkdur)
															 
			} else {
				if {![GetBrkDur]} {						 ;# EXCEPT IF CREATING (not editing) A FILE in which case
					return 0									 ;# user specifies duration
				}
			}
			set brk(time_autoset) 0							 ;#	flag time-NOT-automatically-set
		}
		if {!$is_file_edit} {								 ;#	If we're not editing an existing file, frametime is also
			set brk(real_endtime) $brkfrm(endtime)		 ;# duration of brkfile to be created
		}

		if {![SetupDisplayRangeConstants $lo $hi $is_log]} {
			return 0
		}
		incr pcnt
		set brk(endtimeset) $pcnt							 ;#	Flag that we've now set an endtime for this process
		return 1
	}
}

#------ Remember brk frame constants

proc SetupDisplayRangeConstants {lo hi is_log} {
	global brkfrm	brk bkc evv
	set brkfrm(lo) $lo
	set brkfrm(hi) $hi
	set brkfrm(islog) $is_log
	set brk(range) [expr $brkfrm(hi) - $brkfrm(lo)]
	if [Flteq $brk(range) 0.0] {
		Inf "Insufficient range of values to set up graphic display"
		return 0
	}
	if {$is_log} {
		catch {$bkc(can) itemconfigure logdisp -fill $evv(SPECIAL)}
	} else {
		catch {$bkc(can) itemconfigure logdisp -fill [option get . background {}]}
	}
	return 1
}

#------ Reset hst of range changes

proc ResetRangeMemory {} {
	global origbrkfrm lastbrk	brk bkc brkoptions origbrk evv 

	set lastbrk(range) $origbrk(range)
	set lastbrk(hi) $origbrkfrm(hi)
	set lastbrk(lo) $origbrkfrm(lo)
	set lastbrk(islog) $origbrkfrm(islog)
	set brk(maxrangeindex) 0
	set brk(thisrangeindex) 0
	if {$lastbrk(islog)} {
		$brkoptions entryconfigure 4 -label "Linear Display"  -command "LogtoLin"
		catch {$bkc(can) itemconfigure logdisp -fill $evv(SPECIAL)}
	} else {												;#	Change label & action on button
		$brkoptions entryconfigure 4 -label "Log Display"  -command "LintoLog"
		catch {$bkc(can) itemconfigure logdisp -fill [option get . background {}]}
	}
}

#------ Reset hst of range changes

proc StepBackInRangeMemory {} {
	global lastbrk brk

	if {![info exists brk(maxrangeindex)]} {
		return 0
	}

	if {$brk(maxrangeindex) <= 0} {
		return
	}
	if {$brk(thisrangeindex) == $brk(maxrangeindex)} {
		incr brk(thisrangeindex) -1	
	}
	incr brk(maxrangeindex) -1	

	set lastbrk(range) 	[lrange $lastbrk(range) 0 $brk(maxrangeindex)]
	set lastbrk(hi) 	[lrange $lastbrk(hi) 	0 $brk(maxrangeindex)]
	set lastbrk(lo) 	[lrange $lastbrk(lo) 	0 $brk(maxrangeindex)]
	set lastbrk(islog) 	[lrange $lastbrk(islog) 0 $brk(maxrangeindex)]
}

#------ Get end TIME for brktable display, from user.

proc GetBrkDur {} {
	global brkdurin pr_brkdurin pr_brkfile pr_textfile inval brkfrm brk chlist pa evv
	set f .brkdurin
	if [Dlg_Create $f "Breaktable Duration" "set pr_brkdurin 0" -borderwidth 10 -bg $evv(EMPH)] {
		button $f.ok -text "OK" -command "set pr_brkdurin 1" -highlightbackground [option get . background {}]
		entry  $f.e -textvariable inval -width 16
		label $f.l -text "" -width 28
		button $f.cancel -text "Cancel" -command "set pr_brkdurin 0 ; set pr_brkfile 0 ; set pr_textfile 0" -highlightbackground [option get . background {}]
		pack $f.ok $f.e $f.l -side left
		pack $f.cancel -side right
		wm resizable $f 1 1
		bind $f <Return> {set pr_brkdurin 1}
		bind $f <Escape> {set pr_brkdurin 0}
	}
	bind .brkdurin <ButtonRelease-1> {RaiseWindow %W %x %y}
	if {[info exists chlist]} {
		set dfltdur 0
		foreach item $chlist {
			if {[info exists pa($item,$evv(FTYP))]} {
				set ddur $pa($item,$evv(DUR))
				if {$ddur > $dfltdur} {
					set dfltdur $ddur
				}
			}
		}
		set inval $dfltdur
	} else {
		set inval ""
	}
	.brkdurin.l config -text "(minimum : $evv(MINBRKDUR) secs)" -anchor w
	ForceVal $f.e $inval
	set pr_brkdurin 0
	set finished 0
	ScreenCentre $f
	raise $f
	My_Grab 0 $f pr_brkdurin $f.e
	while {!$finished} {
		tkwait variable pr_brkdurin	   						;#	Wait for button press
		if {$pr_brkdurin} {									;#	OK pressed
			set inval [FixTxt $inval "value"]
			if {[string length $inval] <= 0} {
				ForceVal $f.e $inval
				continue
			}
			if {[IsPositiveNumber $inval] && ($inval >= $evv(MINBRKDUR))} {	;#	Check entered  val is +ve number
				set brkfrm(endtime) $inval
				set finished 1								  	;#	If so, return to calling dialog
			} else {
				Inf "Duration must be a positive number, and at least $evv(MINBRKDUR) sec." ;#	If not, stay in this dialog
			}
		} else {		  										;#	CANCEL pressed, return to calling dialog 
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $pr_brkdurin
}

#------ Save current limit points of brktable to brkfrm

proc SaveBrkframeInputs {lo hi is_log} {
	global origbrkfrm brkfrm brkoptions brk bkc origbrk evv

	#	REMEMBER INITIAL VALUES OF DISPLAY CONSTANTS

	set origbrk(range) 				 $brk(range)
	set origbrkfrm(lo)	 		 $brkfrm(lo)
	set origbrkfrm(hi) 			 $brkfrm(hi)
	set origbrkfrm(endtime) 		 $brkfrm(endtime)
	set origbrkfrm(islog) 		 $brkfrm(islog)
	set origbrk(xdisplay_end) 		 $brk(xdisplay_end)
	set origbrk(xdisplay_end_atedge) $brk(xdisplay_end_atedge)
	set origbrk(active_xdisplay_end) $brk(active_xdisplay_end)

	#	SETUP INITIAL STATE OF LOG/LIN DISPLAY CHECKBUTTON

	if {$is_log} {
		$brkoptions entryconfigure 4 -label "Linear Display" -command "LogtoLin"
		catch {$bkc(can) itemconfigure logdisp -fill $evv(SPECIAL)}
	} else {												;#	Change label & action on button
		$brkoptions entryconfigure 4 -label "Log Display" -command "LintoLog"
		catch {$bkc(can) itemconfigure logdisp -fill [option get . background {}]}
	}
}

#------ Clear existing coordinate and real-coordinate values

proc ClearRealAndDisplayCoordinates {} {
	global displ_c real_c brk
	catch {unset displ_c} in
	catch {unset real_c} in
	set brk(coordcnt) 0
}

#------ Get brkfile values into brkfile display, etc

proc SetupBrkfileReal_c {fnam pcnt} {
	global pa brkfrm brk wstk actvhi actvlo good_res evv
	
	if {![GetReal_cFromFile $fnam]} {
		return 0
	}

	#	DURATION AND VAL-RANGE OF BRKFILE

	set brk(real_endtime) $pa($fnam,$evv(DUR))
	if {$brk(real_endtime) <= $evv(FLTERR)} {
		return 0
	}

	CheckBrkfileDisplayResolution $brk(real_endtime) 1

	if {!$good_res} {
		return -1
	}
	set inlo $pa($fnam,$evv(MINBRK))
	set inhi $pa($fnam,$evv(MAXBRK))

	#	RATIONALISE RANGE

	if {$inlo < $brkfrm(lo)} {
 		if {$brk(real_endtime) > $brkfrm(endtime)} {
			if {![CheckRangeWithinActiveDisplay $fnam $brkfrm(lo) "lo"]} {
				return 0
			}
		} else {
 			set choice [tk_messageBox \
				-message "Input brktable extends below valid range: Modify Values?" \
				-type yesno -icon question -parent [lindex $wstk end]]
			if [string match $choice "no"] {
				return 0
			} else {
				SquashReal_c
			}
		}
	}
	if {$inhi > $brkfrm(hi)} {
 		if {$brk(real_endtime) > $brkfrm(endtime)} {
			if {![CheckRangeWithinActiveDisplay $fnam $brkfrm(hi) "hi"]} {
				return 0
			}
		} else {
 			set choice [tk_messageBox \
					-message "Input brktable extends above valid range: Modify Values?" \
					-type yesno -icon question -parent [lindex $wstk end]]
			if [string match $choice "no"] {
				return 0
			} else {
				HiSquashReal_c		;#	lo limit already tested
			}
		}
	}
	return 1
}

#------ Check Brkfile Can be adequately displayed on screen

proc CheckBrkfileDisplayResolution {brk_endtime firsttime} {
	global evv ins chlist pa good_res c_res brk

	set good_res 1
	set displayspan $evv(XWIDTH)
	if {$ins(create) && [info exists ins(chlist)]} {
		set thischosenlist "$ins(chlist)"
	} elseif [info exists chlist] {
		set thischosenlist "$chlist"
	}
	if {$brk(short_table) || !$brk(time_constrained)} {
		set displayspan $evv(XWIDTH)
	} elseif {[info exists thischosenlist] && ([llength $thischosenlist] > 0)} {
		set snd_dur $pa([lindex $thischosenlist 0],$evv(DUR))
		if {$snd_dur > $brk_endtime} {
			set displayspan [expr $brk_endtime / $snd_dur]
			set displayspan [expr round($displayspan * $evv(XWIDTH))]
		}
	} else {
		set displayspan $evv(XWIDTH)
	}
	foreach timespan $c_res {
		if {[expr round((double($timespan) / $brk_endtime) * $displayspan)] < 2} {
			Inf "Insufficient screen resolution to display these points"
			if {$firsttime && !$brk(short_table) && ($displayspan < $evv(XWIDTH))} {
				set brk(could_be_short_table) 1
			} else {				
				set brk(could_be_short_table) 0
			}
			set good_res 0
			return -1
		}
	}
}

#------ Get Brkfile Data from file

proc GetReal_cFromFile {fnam} {
	global real_c brk evv

	if [catch {open $fnam r} fileId] {
		Inf "Cannot open file $fnam to display it."	;#	Open the brkfile
		return 0
	}
	set valcnt 0
	while {[gets $fileId line] >= 0} {
		set vals "[string trim $line]"
		set vals "[split $vals]"
		foreach val $vals {
			if {[string length $val] > 0} {
				if {![IsNumeric $val]} {
					Inf "Non-numeric value ($val) in breaktable file"
					catch {close $fileId}
					return 0
				}
				lappend real_c $val
				incr valcnt
			}
		}
	}
	if {$valcnt < 4 || ![IsEven $valcnt]} {
		Inf "Failed to get a valid number of values from Brktable."
		catch {close $fileId}
		return 0
	}
	catch {close $fileId}

	incr valcnt -2

	if {[lindex $real_c 0] <= $evv(FLTERR)} {
		set real_c [lreplace $real_c 0 0 0.0]		;#	Force a true zero at start
	} else {
		lappend new_c 0.0 [lindex $real_c 1]		;#	Force a value at zero
		set real_c [concat $new_c $real_c]
		incr valcnt 2
	}
	Get_cResolution
	set brk(real_endtime) [lindex $real_c $valcnt]
	set brk(orig_cs) $real_c
	return 1
}

#------ Find timegaps between brktable entries

proc Get_cResolution {} {
	global c_res real_c brk

	set firstpair 1
	catch {unset c_res}
	foreach {time val} $real_c {
		if {$firstpair} {
			set firstpair 0
		} else {
		 	lappend c_res [expr $time - $lasttime]
		}
		set lasttime $time
	}
}

#------ Check brktable vals are within hirange limit of displayrange, in area where display is active

proc CheckRangeWithinActiveDisplay {fnam rangelimit whichrange} {
	global real_c brkfrm brk wstk evv

	set lasttime -1								;#	Flag that no previous time-coord is remembered

	set islolimit 0
	set ishilimit 0
	if [string match $whichrange "lo"] {
		set islolimit 1
	} else {
		set ishilimit 1
	}
	foreach {time val} $real_c {
		if {$time <= $brkfrm(endtime)} {		;# 	Point within activetime-displayrange 
												;#	is out of range
			if {($islolimit && ($val < $rangelimit)) || ($ishilimit && ($val > $rangelimit))} {
		 		set choice [tk_messageBox \
		 		-message "Input brktable out of valid range: Truncate Values?" \
					-type yesno -icon question -parent [lindex $wstk end]]
				if [string match $choice "no"] {
					return 0
				} else {
					if {$islolimit} {
						SquashReal_c
					} else {
						HiSquashReal_c		;#	lorange has already been checked
					}
					return 1
				}
			}
		} else { 								;# 	1st point beyond activetime-displayrange
												;#	is out of range
			if {($islolimit && ($val < $rangelimit)) || ($ishilimit && ($val > $rangelimit))} {
		 		set choice [tk_messageBox \
		 		-message "Input brktable out of valid range, beyond active part of display: Edit File?" \
					-type yesno -icon question -parent [lindex $wstk end]]
				if [string match $choice "no"] {
					return 0
				} else {
					if {$lasttime < 0} {
						ErrShow "Logical Error: CheckRangeWithinActiveDisplay"
						return 0
					} 
					if {![DoFancyTableSplice $time $val $lasttime $lastval $rangelimit $whichrange]} {
						return 0
					}
					return 1
				}								;# 	1st point beyond activetime-displayrange
			} else {							;#	is in range, but some point beyond is out of range
		 		set choice [tk_messageBox \
		 		-message "Input brktable out of valid range, beyond active part of display: Edit File?" \
					-type yesno -icon question -parent [lindex $wstk end]]
				if [string match $choice "no"] {
					return 0
				}
				if {![SpliceReal_c $brkfrm(endtime)]} {
					return 0
				}
				return 1						;#	CASE C (see DoFancyTableSplice notes)
			}									
		}
		set lastval $val
		set lasttime $time
	} 
	return 1
}

#------ Squash brktable values, to lie within valid parameter range ??

proc SquashReal_c {} {
	global real_c brkfrm brk  
	foreach {time val} $real_c {
		if {$val > $brkfrm(hi)} {				;#	Truncate out-of-range values
			set val $brkfrm(hi)
		} elseif {$val < $brkfrm(lo)} {
			set val $brkfrm(lo)
		}
		lappend new_c $time $val
	}
	unset real_c
	set real_c "$new_c"
}

#------ Squash too-high brktable values, to lie within valid parameter range.

proc HiSquashReal_c {} {
	global real_c brkfrm brk 
	foreach {time val} $real_c {
		if {$val > $brkfrm(hi)} {				;#	Truncate out-of-range values
			set val $brkfrm(hi)
		}
		lappend new_c $time $val
	}
	unset real_c
	set real_c "$new_c"
}

#------ Splice table that goes out of range BEYOND active_display_area.
#
#														x
#													   / \
#				CASE A							CASE B/	  \						CASE C
#						   x					   * /	   \
#				  *		 /	\					   */		\								x
#		 ---------*----/-----\--		 ----------X==x------\--		 ------------------/-\--
#		|		  *::/::::::::\:|		|		  /*  :ADDING:\:|		|		  ::::::::/:::\:|
#		|		  */:::::::::::\|		|		 / *  ::POINT::\|		|		  :::::::/:::::\|
#		|	x	 /*:::::::::::::x		|	x	/  *  ::AT::::::x		|	x	x ::::::/:::::::x
#		|  / \ /  *:::::::::::::|		|  / \ /   *  ::EDGE::::|		|  / \ / \:::::/::::::::|
#		| /	  x	  *:::::::::::::|		| /	  x	   *  :::OF:::::|		| /	  x	  :\::/:::::::::|
#		|x	     CUT::::::::::::|		|x	       *  :BRKFRAME:|		|x	      :::x::::::::::|
#		|		 HERE:::::::::::|		|		  CUT ::::::::::|		|		  ::::::::::::::|
#		|		  ::::::::::::::|		|		 HERE ::::::::::|		|		  ::::::::::::::|
#		 -----------------------		 -----------------------		 -----------------------
#		 Table goes out of range 		 Table goes out of range		 Table goes out of range
#		 at 1st point beyond mask		 at 1st point beyond mask		at 2nd or > point beyond mask
#	   	     BUT is IN range 			   BUT is OUT OF range 
#			  at mask edge	 				  at mask edge
#																				Done (as A)
# 			brkfrm(endtime)				brkfrm(endtime)			by calling SpliceReal_c		
#			   not altered					     altered					rather than this proc
#

proc DoFancyTableSplice {time val lasttime lastval rangelimit whichrange} {
	global brkfrm brk origbrkfrm real_c

	set valdiff  [expr $val - $lastval]
	set timediff [expr $time - $lasttime]
	set timeratio [expr ($brkfrm(endtime) - $lasttime) / double($timediff)]
	set edgeval [expr ($valdiff * $timeratio) + $lastval]
	if {([string match $whichrange "lo"] && ($edgeval >= $rangelimit))
	|| ([string match $whichrange "hi"] && ($edgeval <= $rangelimit))} {
		if {![SpliceReal_c $brkfrm(endtime)]} {					;#	CASE A
			return 0
		}
	} else {
		set valratio [expr ($rangelimit - $lastval) / double($valdiff)]
		set edgetime [expr ($timediff * $valratio) + $lasttime]
		if {$brk(time_autoset)} {
			if [Flteq $edgetime $brkfrm(endtime)] {
				set edgetime $brkfrm(endtime)
			}
		}
		if {![SpliceReal_c $edgetime]} {								;#	CASE B
			return 0
		}
		set valpos $brk(coordend)
		set lasttime [lindex $real_c $valpos] 
		incr valpos
		set lastval [lindex $real_c $valpos] 
		lappend real_c $brkfrm(endtime) $lastval
		set brk(real_endtime) $brkfrm(endtime) 
		incr brk(coordcnt) 2
		incr brk(coordend) 2
	}
	return 1
}

#------ Splice a table of coords at the specified time, creating new table ending at that time

proc SpliceReal_c {endtime} {
	global displ_c real_c c_res good_res brk
	set cnt 0
	set gotit 0
	set lasttime -1
	foreach {x y} $real_c {
		if {$x > $endtime} {
			set thistime $x
			set thisval $y
			set gotit 1
			break
		}
		set lasttime $x
		set lastval $y
		incr cnt 2
	}
	if {!$gotit} {
		ErrShow "Error in logic before SpliceReal_c"
		return 0
	} elseif {$lasttime < 0} {
		ErrShow "Error in logic of SpliceReal_c"
		return 0
	}

	set tempreal_c 			"$real_c"
	set old_c_res 	"$c_res"

	incr cnt -1
	set real_c "[lrange $real_c 0 $cnt]"
	if {![Flteq $lasttime $endtime]} {
		set timediff [expr $thistime - $lasttime]
		set valdiff  [expr $thisval - $lastval]
		set timeratio [expr ($endtime - $lasttime) / double($timediff)]
		set valdiff	[expr $valdiff * $timeratio]
		set lastval [expr $lastval + $valdiff]
		lappend real_c $endtime $lastval
	}
	Get_cResolution
	CheckBrkfileDisplayResolution $endtime 0
	if {!$good_res} {
		set real_c 			"$tempreal_c"
		set  c_res  "$old_c_res"
		set good_res 1
		return 0
	}
	set brk(coordcnt) [llength $real_c]
	set brk(coordend) [expr int($brk(coordcnt) - 2)]
	set brk(real_endtime) $endtime
	return 1
}

#------ Test if brktable is longer or shorter than brkfrm-required length

proc SetBrkDisplayTimeParams {} {
	global brkfrm brkoptions evv brk

	if {![Flteq $brkfrm(endtime) $brk(real_endtime)]} { 	;#	BUT brktable length != brkfrm length
		if {$brkfrm(endtime) < $brk(real_endtime)} {	 	;#	IF brkfrm is shorter than selected brktable
			set brk(xdisplay_end) $evv(XWIDTH)				;#	Brkfile uses full width of display
													 		;#	But only part of brktable acts on file
			set brk(xdisplay_end_atedge) [expr int($brk(xdisplay_end) + $evv(BWIDTH))]				
			set brk(active_xdisplay_end) [expr double($brkfrm(endtime)) / $brk(real_endtime)]
			set brk(active_xdisplay_end) [expr round($brk(active_xdisplay_end) * $evv(XWIDTH))]
			set brk(mous_xdisplay_end) 		  [expr $brk(xdisplay_end) + $evv(BWIDTH)]
			set brk(mous_active_xdisplay_end) [expr $brk(active_xdisplay_end) + $evv(BWIDTH)]
		} else { 									 		;#	ELSE brkfrm is longer than selected brktable
													 		;#	Brkfile uses only part of display
			set brk(xdisplay_end) [expr double($brk(real_endtime)) / $brkfrm(endtime)]
			set brk(xdisplay_end) [expr round($brk(xdisplay_end) * $evv(XWIDTH))]
			set brk(xdisplay_end_atedge) [expr int($brk(xdisplay_end) + $evv(BWIDTH))]				
			set brk(active_xdisplay_end) $evv(XWIDTH)		;#	But all of display applies to file
			set brk(mous_xdisplay_end) 		  [expr $brk(xdisplay_end) + $evv(BWIDTH)]
			set brk(mous_active_xdisplay_end) [expr $brk(active_xdisplay_end) + $evv(BWIDTH)]
		}
		return
	}												 		;#	If brkfrm length not autoset
	set brk(xdisplay_end) $evv(XWIDTH)						;#	Brkfile uses full width of display
	set brk(xdisplay_end_atedge) [expr int($brk(xdisplay_end) + $evv(BWIDTH))]				
	set brk(active_xdisplay_end) $evv(XWIDTH)				;#	All of display applies to file (in principle)
	set brk(mous_xdisplay_end) 		  [expr $brk(xdisplay_end) + $evv(BWIDTH)]
	set brk(mous_active_xdisplay_end) [expr $brk(active_xdisplay_end) + $evv(BWIDTH)]
}

#------ Establish Constants used to Convert Graf points to Real value-pairs

proc EstablishGrafToRealConversionConstants {} {
	EstablishGrafToRealConversionConstants_x
	EstablishGrafToRealConversionConstants_y
}

#------ Establish Constants used to Convert Graf time values to Real time values

proc EstablishGrafToRealConversionConstants_x {} {
	global brkfrm brk

	#	CONVERT FROM GRAF ACTIVE X-RANGE TO REAL TIME RANGE
	set brk(xgraftoval) [expr double($brk(real_endtime)) / $brk(xdisplay_end)]
	#	CONVERT FROM REAL TIME RANGE TO GRAF ACTIVE X-RANGE
	set brk(xvaltograf) [expr double($brk(xdisplay_end)) / $brk(real_endtime)] 
}	

#------ Establish Constants used to Convert Graf values to Real values

proc EstablishGrafToRealConversionConstants_y {} {
	global brk brkfrm evv
	if {$brkfrm(islog)} {
		set a [expr log10(1 + $brk(range))]			;#	Find log of real value range
	} else {										;#	(Ensure range is always from 0 (log 1) upwards)
		set a $brk(range)							;#	Find real value range
	}
	set brk(ygraftoval) [expr $a / double($evv(YHEIGHT))]	;#	Scale from graf y-range to real value range
	set brk(yvaltograf) [expr double($evv(YHEIGHT)) / $a]	;#	Scale from real value range to graf y-range
}	

#------ Generate display coords from real coords

proc SetupBrkfileDisplay_c {} {
	global real_c displ_c brk brkfrm
	set brk(coordcnt) 0
	catch {unset displ_c} in
	foreach {time val} $real_c {
		lappend displ_c [RealToGrafx $time]			;#	Convert brkfile time to y-display time
		lappend displ_c [RealToGrafy $val $brkfrm(lo) $brkfrm(islog)]
		incr brk(coordcnt) 2								;#	Convert brkfile value to y-display value
	}
	set brk(coordend) $brk(coordcnt)
	incr brk(coordend) -2 
}

#------ Save original coords, in case we wish to restore them

proc SaveOriginal_c {} {
	global origreal_c real_c origdisplay_c displ_c origbrk brk origbrkfrm brkfrm
	global origbrk orig__c_res c_res
	global lastbrk

	set origreal_c 		 	  	  "$real_c"
	set origdisplay_c 		 	  "$displ_c"
	set origbrk(coordcnt)   		  $brk(coordcnt)
	set origbrk(coordend)   		  $brk(coordend)
	set origbrkfrm(lo) 			  $brkfrm(lo)
	set origbrkfrm(hi) 			  $brkfrm(hi)
	set origbrkfrm(islog) 		  $brkfrm(islog) 				 
	set origbrkfrm(endtime)		  $brkfrm(endtime)
	set origbrk(wascut) 	  	  	  $brk(wascut)
	set origbrk(autosetframe_in_use)  $brk(autosetframe_in_use)
	set origbrk(range) 			 	  $brk(range)
	set origbrk(xgraftoval) 		  $brk(xgraftoval)
	set origbrk(xvaltograf) 		  $brk(xvaltograf)
	set origbrk(ygraftoval) 		  $brk(ygraftoval)
	set origbrk(yvaltograf) 		  $brk(yvaltograf)
	set origbrk(xdisplay_end) 		  $brk(xdisplay_end)
	set origbrk(xdisplay_end_atedge) $brk(xdisplay_end_atedge)
	set origbrk(active_xdisplay_end)  $brk(active_xdisplay_end)

	set origbrk(real_endtime)	 	  $brk(real_endtime)
	set origbrk(time_autoset)  		  $brk(time_autoset)
	set orig__c_res	 	  $c_res
	set origbrk(greymask) 		 	  $brk(greymask)
	set origbrk(could_be_maskedge) 	  $brk(could_be_maskedge)
	set origbrk(maskedge)			  $brk(maskedge)
	set origbrk(real_endtime) 		  $brk(real_endtime)

	ResetRangeMemory
}

#------ Set up baktrak vals to start vals, and disable baktraking (enabled once changes made)

proc InitialiseBaktrak {} {
	global baktrak canbaktrak brk brkfrm real_c displ_c qval qtime

	set baktrak(real_c) 		 	  "$real_c"
	set baktrak(displ_c) 		 	  "$displ_c"
	set baktrak(qval)					  $qval
	set baktrak(qtime)					  $qtime
	set baktrak(coordcnt)   			  $brk(coordcnt)
	set baktrak(coordend)   			  $brk(coordend)
	set baktrak(lo) 				 	  $brkfrm(lo)
	set baktrak(hi) 				 	  $brkfrm(hi)
	set baktrak(islog) 				 	  $brkfrm(islog)
	set baktrak(real_endtime)		 	  $brk(real_endtime)
	set baktrak(framendtime)		 	  $brkfrm(endtime)
	set baktrak(wascut) 	  	  	 	  $brk(wascut)
	set baktrak(time_autoset) 	  		  $brk(time_autoset)
	set baktrak(autosetframe_in_use) 	  $brk(autosetframe_in_use)
	set baktrak(range) 			 	 	  $brk(range)
	set baktrak(xgraftoval) 			  $brk(xgraftoval)
	set baktrak(xvaltograf) 			  $brk(xvaltograf)
	set baktrak(ygraftoval) 			  $brk(ygraftoval)
	set baktrak(yvaltograf) 			  $brk(yvaltograf)
	set baktrak(xdisplay_end) 		  	  $brk(xdisplay_end)
	set baktrak(brk_xdisplay_end_atedge)  $brk(xdisplay_end_atedge)
	set baktrak(active_xdisplay_end) 	  $brk(active_xdisplay_end)

	set baktrak(greymask) 		 	 	  $brk(greymask)
	set baktrak(could_be_maskedge) 	 	  $brk(could_be_maskedge)
	set baktrak(maskedge) 			 	  $brk(maskedge)
	set baktrak(time_constrained)	  	  $brk(time_constrained)

	set canbaktrak 0
}

#------ Deal with brktable being longer or shorter than brkfrm-required length, using semi-transparent masks
#
#				   (1)									   (2)
#	 		 BRKFILE LONGER 						 BRKFILE SHORTER 
#	 	  THAN INFILE REQUIRES					   THAN INFILE REQUIRES
#  $active_xdisplay_end != $evv(XWIDTH)		$xdisplay_end != $evv(XWIDTH)
#		 -----------------------				 -----------------------			
#		|		  ::::::::::::::|				|		  x:::::::::::::|			
#		|		  ::::::::::::::|				|		 /::::::::::::::|			
#		|	x	  ::::::::::::::|				|	x	/ ::::::::::::::|			
#		|  / \	  :::x----x:::::|				|  / \ /  ::::::::::::::|			
#		| /	  \	  ::/::::::\::::|				| /	  x	  ::::::::::::::|			
#		|x	   \  :/::::::::\:::|				|x	      ::::::::::::::|			
#		|		\ /::::::::::\::|				|		  ::::::::::::::|			
#		|		 x::::::::::::\:|				|		  ::::::::::::::|			
#		|		  :::::::::::::\|				|		  ::::::::::::::|			
#		|		  ::::::::::::::x				|		  ::::::::::::::|			
#		 -----------------------				 -----------------------			
#
#	CAUTION: if greyout established or changed AFTER line is drawn, need to redraw line/points in case (1)!!
#

proc BrkDisplayMasks {} {
	global displ_c evv brkoptions sfbbb brk bkc 

	set brk(could_be_maskedge) 0
	set brk(maskedge) -1

	if {$brk(xdisplay_end) != $evv(XWIDTH)} {
		$bkc(can) create text $bkc(halfwidth) $bkc(ytext_top) \
			-text "File not completely covered by brktable." -tag message -fill $evv(POINT)
		if {$brk(time_autoset)} {
			$bkc(can) create rect $brk(mous_xdisplay_end) $evv(BWIDTH) \
				$bkc(effective_mouse_xwidth) $bkc(effective_mouse_yheight) \
				-stipple gray50 -fill $evv(EMPH) -outline [option get . background {}] -width 0 -tag greyout
			set brk(greymask) $brk(mous_xdisplay_end)
		}
	} elseif {$brk(active_xdisplay_end) != $evv(XWIDTH)} {
		set brk(could_be_maskedge) 1
		$bkc(can) create text $bkc(halfwidth) $bkc(ytext_top) \
			-text "Brktable extends beyond end of file." -tag message -fill $evv(POINT)
		if {$brk(time_autoset)} {
			$bkc(can) create rect $brk(mous_active_xdisplay_end) $evv(BWIDTH) \
				$bkc(effective_mouse_xwidth) $bkc(effective_mouse_yheight) \
				-stipple gray12 -fill $evv(POINT) -outline [option get . background {}] -width 0 -tag greyout
			set brk(greymask) $brk(mous_active_xdisplay_end)
		}
		set brk(maskedge) [SetMaskedge]
	} else {
		catch {$bkc(can) delete message} in
		catch {$bkc(can) delete greyout} in
		set brk(maskedge) -1
		set brk(greymask) -1
	}
	if {$brk(greymask) > 0} {
		$brkoptions entryconfigure 6 -label "Remove Masked Area" -command "FillTimeBrk $sfbbb" -state normal
 	} else {
		$brkoptions entryconfigure 6 -label "" -state disabled
	}
}

#------ Check if there is a point exactly on the maskedge

proc SetMaskedge {} {
	global displ_c brk
	set timindex 0
	foreach {time val} $displ_c {	
		if [string match $brk(active_xdisplay_end) $time] {
			return $timindex 					;#	Flag if mask edge exactly at a display point
			break		
		}
		incr timindex 2
	}
	return -1
}

#------ Setup Axes for display for a brktable being Created

proc SetupAxes {} {
	global zero brkfrm
	set zero(exists) 0
	if {$brkfrm(lo) < 0.0 && $brkfrm(hi) > 0.0} {
		DrawZeroLineAndText
	}
	DrawLimitVals							;#	Draw range and time ends on (larger) canvas
}

#------ Draw Zero Line, and a "0", for brktable display.

proc DrawZeroLineAndText {}  {
	global zero brk evv	bkc
	DrawZeroLine
	set y [expr int($zero(y) + $evv(BWIDTH))]
	$bkc(can) create text $bkc(zerotext_xposition) $y -text "0" -tag zinfo -fill $evv(POINT) ;# Text on bordering canvas
}

#------ Draw Zero Line, and a "0", for brktable display.

proc RedrawZeroLineAndText {}  {
	global zero brk evv bkc
	RedrawZeroLine
	set y [expr int($zero(y) + $evv(BWIDTH))]
	$bkc(can) create text $bkc(zerotext_xposition) $y -text "0" -tag zinfo -fill $evv(POINT) ;# Text on bordering canvas
}

#------ Draw Zero Line, and a "0", for brktable display.

proc DrawZeroLine {}  {
	global zero brkfrm brk bkc evv
	set zero(exists) 1
	CalcZerolineYcoord
	set y [expr int($zero(y) + $evv(BWIDTH))]
	$bkc(can) create line $evv(BWIDTH) $y $bkc(actual_xwidth_end) $y -tag zinfo -fill $evv(POINT) ;# line on drawing canvas
}

#------ Calculate the Y-coordinate of the zero line

proc CalcZerolineYcoord {} {
	global zero brkfrm brk evv
	if {$brkfrm(islog)} {
		if {$brkfrm(lo) >= 0.0} {			;#	lo <= 0 (when func called) && >= 0 (hence) == 0
			set y 0							;#	0 is at bottom of range 
		} else {
			set y $brkfrm(lo)
			set y [expr -($y)]				;#	0 is at -lo from bottom of range
			set y [expr log10(1 + $y)]		;#	Convert to log value > 0 (log(1) = 0)
		} 
	} else {
		set y $brkfrm(lo)
		set y [expr -($y)]					;#	0 is at -lo from bottom of range
	}
											;#	Keep as global, so recalculated only in special circumstances
	set y [expr int($y * $brk(yvaltograf))]	
	set zero(y) $evv(YHEIGHT)				;#	Convert to inverted y-coords of screen
	incr zero(y) -$y
	set zero(last_islog) $brkfrm(islog)
	set zero(last_yvaltograf) $brk(yvaltograf)
	set zero(last_lo) $brkfrm(lo)
}

#------ Draw range ends and time ends on (larger) canvas outside (smaller) drawing canvas

proc DrawLimitVals {} {
	global evv brk bkc

	# DISPLAY TIME LIMITS AT FOOT OF BRKTABLE DISPLAY

#MARCH 7 2005
	DisplayBrkEndtime

	# DISPLAY VALUE RANGE LIMITS TO LEFT OF BRKTABLE DISPLAY

	$bkc(can) create text $bkc(rangetext_xoffset) $bkc(rangetext) -text $evv(VALUE) -fill $evv(POINT)
	DisplayRangeLimits
}

#------ Display endtime, which may involve putting word "time" at right or at centre of-foot-of-display.
#
#			  A						  B						   C					   	 D
#	 -------------------	  -------------------	   -------------------	    -------------------
#	|					|	 |				  |::|	  |			  |:::::::|	   |	|:::::::::::::::|
#	|					|	 |				  |::|	  |			  |:::::::|	   |	|:::::::::::::::|
#	|					|	 |				  |::|	  |			  |:::::::|	   | 	|:::::::::::::::|
#	|-------------------|	 |----------------|--|	  |-----------|-------|	   | ---|---------------|
#  0|       time        |Rt	0|	  time	    Lt|	 |Rt 0|	   time   |Lt	  |Rt 0|	|Lt    time	    |Rt
#	|					|	 |				  |	 |				  |		  |	   |	|				|
#

proc DisplayBrkEndtime {} {
	global bkc evv
	set timepos $bkc(halfwidth)			 										;#	This is on outer canvas
	$bkc(can) create text $timepos $bkc(text_yposition) -text $evv(TIME) -tag {endinfo} -fill $evv(POINT)
	TimeMarkers
}

#------ 
#  Display values of top and bottom of range, in outer canvas.
#

proc DisplayRangeLimits {} {
	global evv brkfrm brk bkc

	if {$brkfrm(lo) > $bkc(rangetextmin)} {			;#	If low value is within text-displayable limits
		set lodisplay [string range $brkfrm(lo) 0 $evv(MAX_XCHAR)] 	;#	Get max displayable sigfig
		if {[string range $lodisplay end end] == "."} {		;#	Drop any decimal point at VERY END of value
			set newend [string length $lodisplay]
			incr newend -2				   		
			set lodisplay [string range $lodisplay 0 $newend]
		}
	} else {											;#	If too large to display as (truncated) value
		set lodisplay [MagDisplay $brkfrm(lo)]		;#	use magnitude type display
	}
	$bkc(can) create text $bkc(rangetext_xoffset) $bkc(text_rangebot) -text $lodisplay -tag {rangeinfo} -fill $evv(POINT)

	if {$brkfrm(hi) < $bkc(rangetextmax)} {			;#	Simil for top of range value
		set hidisplay [string range $brkfrm(hi) 0 $evv(MAX_XCHAR)]
		if {[string range $lodisplay end end] == "."} {
			set newend [string length $hidisplay]
			incr newend -2				   		
			set hidisplay [string range $hidisplay 0 $newend]
		}
	} else {
		set hidisplay [MagDisplay $brkfrm(hi)]
	}
	$bkc(can) create text $bkc(rangetext_xoffset) $bkc(text_rangetop) -text $hidisplay  -tag {rangeinfo} -fill $evv(POINT)
}

#------ Create a pow-of-10 type display of a value which is too large to put on canvas as is.

proc MagDisplay {val} {
	set rounded_val [expr round($val)]
	set magnitude [GetMagnitude $rounded_val]	
	set divisor [expr pow(10,$magnitude)]
	set newval [expr round($rounded_val / $divisor)]
	set newval [GetAbsoluteIntegerPartOf $newval]
	append newval "*10^"
	append newval $magnitude
	if {$val < 0} {
		set val "-"
		append val $newval
	} else {
		set val $newval
	}
	return $val
}

#------ Get the magnitude of the (abs value of) number

proc GetMagnitude {str} {
	set str [GetAbsoluteIntegerPartOf $str]		;#	Get the (abs) integer part of string
	set thispow [string length $str]			;#	Count digits in string
	incr thispow -1								;#	Power of ten beyond single-digit representation
	return $thispow						
}

#------ Display existing file (or rather, the coords we have stored)

proc DisplayBrktable {} {
	DrawGrafPoints
	DrawGrafLine 1
}	

#------ Display existing file (or rather, the coords we have stored)

proc DisplayBrktableQ {} {
	DrawGrafPoints
	DrawGrafLineQ
}	

#------ Draw points on graf, from stored coords

proc DrawGrafPoints {} {
	global bkc displ_c
	catch {$bkc(can) delete points} in		;#	destroy any existing points
	foreach {x y} $displ_c {
		DrawPoint $x $y
	}
}

#------ Draw line on graf

proc DrawGrafLine {update_vals} {
	global bkc displ_c real_c brkfrm evv	  
	catch {$bkc(can) delete cline}
	catch {unset real_c}
	foreach {x y} $displ_c {
		lappend real_c [GrafToRealx $x] [GrafToRealy $y $brkfrm(islog) $brkfrm(lo)]
		incr x $evv(BPWIDTH)
		incr y $evv(BWIDTH)
		lappend line_c $x $y
	}
	eval {$bkc(can) create line} $line_c {-fill $evv(GRAF)} {-tag cline}
	SeeValsBrk
}

#------ Draw line on graf, avoiding quantising last time!!

proc DrawGrafLineQ {} {
	global bkc displ_c real_c brkfrm brk evv	  
	catch {$bkc(can) delete cline}
	catch {unset real_c}
	set endindex [llength $displ_c]
	set endindex [expr int($endindex / 2)]
	incr endindex -1
	set i 0
	foreach {x y} $displ_c {
		if {$i == $endindex} {
			lappend real_c $brk(real_endtime) [GrafToRealy $y $brkfrm(islog) $brkfrm(lo)]
		} else {
			lappend real_c [GrafToRealx $x] [GrafToRealy $y $brkfrm(islog) $brkfrm(lo)]
		}
		incr x $evv(BPWIDTH)
		incr y $evv(BWIDTH)
		lappend line_c $x $y
		incr i
	}
	eval {$bkc(can) create line} $line_c {-fill $evv(GRAF)} {-tag cline}
	SeeValsBrk
}

#------ Create a point (small rectangle) in graph

proc DrawPoint {x y} {
	global evv bkc
	incr x $evv(BWIDTH)
	incr y $evv(BWIDTH)
	set xa [expr int($x - $evv(PWIDTH))]
	set ya [expr int($y - $evv(PWIDTH))]
# 2005 MARCH 7th
	set xb [expr int($x + $evv(PWIDTH))]
	set yb [expr int($y + $evv(PWIDTH))]
	$bkc(can) create rect $xa $ya $xb $yb -fill $evv(POINT) -tag points
}

#------ Active the relevant OPTIONS on the brkfile page

proc ActivateBrkdisplayOptions {} {
	global brkoptions brkopt brk brkfrm origbrkfrm sfbbb evv

	if {$brk(time_autoset)} {
	 	$brkoptions entryconfigure 5  -label "Remove Time Constraints" -state normal
	 	$brkoptions entryconfigure 7  -label "" -state disabled	;#	Lengthen
		$brkoptions entryconfigure 8  -label "" -state disabled	;#	Shorten
		$brkoptions entryconfigure 9  -label "" -state disabled	;#	Time Stretch By
		$brkoptions entryconfigure 10 -label "" -state disabled	;#	Time Stretch To
		$brkoptions entryconfigure 11 -label "" -state disabled	;#	Time Shrink	By
		$brkoptions entryconfigure 12 -label "" -state disabled	;#	Time Shrink	To
		$brkoptions entryconfigure 13 -label "" -state disabled	;#	Orig Timerange
		set brk(time_constrained) 1	
	} else {
	 	$brkoptions entryconfigure 5  -label "" -state disabled ;#	No Time Constraints
	 	$brkoptions entryconfigure 7  -label "Lengthen Table" 		-state normal
		$brkoptions entryconfigure 8  -label "Shorten Table"		-state normal
		$brkoptions entryconfigure 9  -label "Time Stretch By"		-state normal
		$brkoptions entryconfigure 10 -label "Time Stretch To"		-state normal
		$brkoptions entryconfigure 11 -label "Time Shrink By"		-state normal
		$brkoptions entryconfigure 12 -label "Time Shrink To"		-state normal
		$brkoptions entryconfigure 13 -label "Original Timings"		-state normal
		set brk(time_constrained) 0	
	}

	if {($brk(xdisplay_end) == $evv(XWIDTH)) && ($brk(active_xdisplay_end) == $evv(XWIDTH))} {
		$brkoptions entryconfigure 6 -label "" -state disabled
	} else {
		$brkoptions entryconfigure 6 -label "Remove Masked Area" -command "FillTimeBrk $sfbbb" -state normal
	}
	$brkopt config -state normal						;#	Allow access to menu
}

#------ Convert real timevalue to grafpoint time 

proc RealToGrafx {x} {
	global evv brk
	set x [expr round($x * $brk(xvaltograf))]
	return $x
}

#------ Convert real value to grafpoint value

proc RealToGrafy {y lo is_log} {
	global evv brk
	if {$is_log} {
		if {$y <= $lo} {
			set y 0											;#	Set at bottom of range
		} else {
			set y [expr log10(1 + $y - $lo)]
		}					 								;#	Ensure value is always >=0 (log 1) upwards
	} else {
		set y [expr $y - $lo]								;#	Establish position within range
	}
	set y [expr $y * $brk(yvaltograf)]						;#	Convert into graf range
	set y [expr	round($evv(YHEIGHT) - $y)]					;#	Invert y-display
	return $y
}

#------ Turn off time quantise

proc SetTimeQuantiseOff {} {
	global qtime bfw
	set qtime 0
	ForceVal $bfw.l.quantise.te Off
}

#------ Turn off val quantise

proc SetValQuantiseOff {} {
	global qval	bfw
	set qval 0
	ForceVal $bfw.l.quantise.ve Off
}

#------ Quantise brktable values

proc SetValQuantise {} {
	global qval real_c brkfrm bfw

	DoTempBaktrak
	set orig_qval $qval
	set qval [GetQuantiseValue val]
	if {$qval >= $brkfrm(hi)} {
		Inf "Impossible quantisation value"
		set qval $orig_qval
		return
	}
	if {$orig_qval != $qval} {
		ForceVal $bfw.l.quantise.ve $qval
		if [info exists real_c] {
			if {$qval < $orig_qval} {		;#	Minimise reversion to pre-quantise values thus....
				ReplotBrkdisplayY_c		;#	Recalculate display coordinates
				DisplayBrktable				;#	Redraw points & line
			}
			foreach {time val} $real_c {
				set val [Quantise $val $qval $brkfrm(lo) $brkfrm(hi)]
				lappend new_c $time $val
			}
			unset real_c
			set real_c $new_c
			SeeValsBrk
		}
		UpdateBaktrak
	}
}

#------ Quantise brktable values

proc SetTimeQuantise {} {
	global qtime real_c brkfrm brk bfw

	set shrink 0
	set look_for_maskedge 1
	set orig_qtime $qtime
	DoTempBaktrak
	set qtime [GetQuantiseValue time]
	if {$qtime >= $brk(real_endtime)} {
		Inf "Impossible quantisation value"
		set qtime $orig_qtime
		return
	}
	if {$orig_qtime != $qtime} {
		ForceVal $bfw.l.quantise.te $qtime
		if [info exists real_c] {
			set endindex [llength $real_c]
			incr endindex -2
			set endtime [lindex $real_c $endindex]
			if {$qtime > $orig_qtime} {
				set lasttime -1
				foreach {time val} $real_c {
					set time [Quantise $time $qtime 0.0 $brk(real_endtime)]
					if {![Flteq $time $lasttime]} {
						lappend new_c $time $val
					} else {
						set shrink 1
					}
					set lasttime $time
				}
			} else {
				foreach {time val} $real_c {
					set time [Quantise $time $qtime 0.0 $brk(real_endtime)]
					lappend new_c $time $val
				}
			}
			unset real_c
			set real_c $new_c
			set endindex [llength $real_c]
			incr endindex -2
			set real_c [lreplace $real_c $endindex $endindex $endtime]
			if {$shrink} {
				SqueezeOutBadTimes
			}
			SeeValsBrk
		}
		UpdateBaktrak
	}
}

#------ Choose a quantisation value

proc GetQuantiseValue {type} {
	global pr_quantise qtime qval quantval wstk evv
	set f .quantlist
	switch $type {
		time {set quantval $qtime}
		val  {set quantval $qval}
		default {
			ErrShow "Unknown parameter $type to quantise"
			return 0
		}
	}
	set callcentre [GetCentre [lindex $wstk end]]
	if [Dlg_Create $f "Quantise Step" "set pr_quantise 1" -borderwidth $evv(BBDR)] {
		label $f.a -text "Select a quantisation value with mouseclick"
		button $f.q -text "Close" -command "set pr_quantise 0" -highlightbackground [option get . background {}]
		Scrolled_Listbox $f.ll -width 5 -height 16 -selectmode single
		pack $f.a $f.q $f.ll -side top -pady 3
		foreach val [list .001 .002 .005 .01 .02 .05 .1 .2 .5 1 2 5 10 20 50 100] {
			$f.ll.list insert end $val
		}
		bind $f.ll.list <ButtonRelease-1> {SelectQval %W ; set pr_quantise 1} 
		bind $f <Escape> {set pr_quantise 0}
		bind $f <Key-space> {set pr_quantise 0}
	}
	wm resizable $f 1 1
	set pr_quantise 0
	raise $f
	update idletasks
	set geo [CentreOnCallingWindow $f $callcentre]
	My_Grab 0 $f pr_quantise $f.ll.list
	wm geometry $f $geo
	tkwait variable pr_quantise
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $quantval
}


#------ Mouse select quantise value

proc SelectQval {w} {
	global quantval
	set hindx [$w curselection]
	if {[string length $hindx] <= 0} {
		return
	}
	$w selection clear $hindx
	set quantval [$w get $hindx]
}

#------ Quantise a value for use in brktable

proc Quantise {val q lo hi} {

	set z [expr round($val / $q)]
	set val [expr $z * $q]
	if {$val <= $lo} {
		set val $lo
	} 
	if {$val >= $hi} {
		set val $hi
	} 
	return $val
}

#################

#------ Get a Valid name for the Brkfile (or abandon it)

proc NuGetValidBrkfileNameAndOpenFile {extname} {
	global brk sfbbb sfbbb wstk newbrkfileId ch wl evv
	global rememd inside_ins_create ins

	set brk(name) [file rootname $brk(name)]
	set brk(name) [string tolower $brk(name)]
	set brk(name) [FixTxt $brk(name) "breakfile name"]
	if {[string length $brk(name)] <= 0} {
		return ""
	}
	ForceVal $sfbbb.name $brk(name)
	if [ValidCDPRootname $brk(name)] {				;#	If not a valid filename, stays waiting in loop
		set fnam $brk(name)						;#	OTHERWISE, Add file-extension
		append fnam $extname
		set notdone 0
		if [file exists $fnam] {		 		;#	test if this file already exists
			set ii [LstIndx $fnam $ch]
			if {$ii >= 0} {
				Inf "$fnam is a selected file for this process: cannot be overwritten now"
				return ""
			} else {
				set choice [tk_messageBox -type yesno -icon question \
					-message "$fnam exists  : Overwrite it ?" -parent [lindex $wstk end]]
				if {$choice == "no"} {				;#	If don't want to overwrite existing file, stay in loop
					return ""
				}
			}
			if {![DeleteFileFromSystem $fnam 1 0]} {
				return ""
			} else {							;#	If file deleted: delete its name from wkspace-listing
				if {$ins(create)} {
					set inside_ins_create 1
				}
				DummyHistory $fnam "EDITED_OR_OVERWRITTEN"
				catch {unset inside_ins_create}
				set ii [LstIndx $fnam $wl]
				if {$ii >= 0} {
					$wl delete $ii
					WkspCntSimple -1
					catch {unset rememd}
				}
			}
		} else {
			set not_exist 1
		}
		if [catch {open $fnam w} newbrkfileId] {
			Inf "Cannot open file $fnam"  ;#	If file not opened for save, stays waiting in dialog
			return ""
		} else {
			if {[info exists not_exist]} {
				if {$ins(create)} {
					set inside_ins_create 1
				}
				DummyHistory $fnam "CREATED"
				catch {unset inside_ins_create}
				unset not_exist
			}
			append brk(name) $extname
			return $brk(name)
		}
	} else {										;#	No valid name: stay in (reactivated) loop
		return ""
	}
}

proc GetCentre {w} {
	set xy [wm geometry $w]
	set srcwdw $w
	set xy [split $xy x+]
	set w [lindex $xy 0]
	set h [lindex $xy 1]
	set x [lindex $xy 2]
	set y [lindex $xy 3]
	set cx [expr $x + ($w/2)]
	set cy [expr $y + ($h/2)]
	if {$srcwdw == ".npad"} {
		if {$cx < 600} {
			set cx 600
		}
		if {$cy < 350} {
			set cy 350
		}
	}
	return [list $cx $cy]
}

proc CentreOnCallingWindow {win centre} {
	set xy [wm geometry $win]
	set xy [split $xy x+]
	set w [lindex $xy 0]
	set h [lindex $xy 1]
	set hw [expr $w/2]
	set hh [expr $h/2]
	set x [expr [lindex $centre 0] - $hw]
	set y [expr [lindex $centre 1] - $hh]
	set geo $w
	append geo x $h + $x + $y
	return $geo
}

proc GetClosestPoint {x y} {
	global evv bkc
	incr x -$evv(PWIDTH)
	incr y -$evv(PWIDTH)
	set mindist $evv(XWIDTH)
	incr mindist $evv(XWIDTH)
	set displaylist [$bkc(can) find withtag points]	;#	List all objects which are points
	foreach obj $displaylist {						;#	For each point
		set coords [$bkc(can) coords $obj]			;#	Only x-coord needed: can't have time-simultaneous points
		set objx [expr round([lindex $coords 0])]	;#	Only x-coord needed: can't have time-simultaneous points
		set thisdist [expr abs($x - $objx)]
		if {$thisdist < $mindist} {
			set mindist $thisdist
			set closest_obj $obj
			set objy [expr round([lindex $coords 1])]
			set thatydist [expr abs($y - $objy)]
		} elseif {$thisdist == $mindist} {
			if {[info exists thisydist]} {
				set objy [expr round([lindex $coords 1])]
				set thisydist [expr abs($y - $objy)]
				if {$thisydist < $thatydist} {
					set thatydist $thisydist
					set closest_obj $obj
				}
			}
		} else {
			catch {unset thisydist}
		}
	}
	return $closest_obj
}

proc TimeMarkers {} {
	global display_endtime brk brkfrm bkc evv

	if {($brk(xdisplay_end) == $evv(XWIDTH)) && ($brk(active_xdisplay_end) == $evv(XWIDTH))} {
		set display_time_end $brk(real_endtime)
	} elseif {$brk(xdisplay_end) < $brk(active_xdisplay_end)} { 	
		set display_time_end $brkfrm(endtime)
	} else {
		set display_time_end $brk(real_endtime)
	}
	catch {$bkc(can) delete tmark}
	set ratio [expr $evv(XWIDTH) / double($display_time_end)]
	if {$display_time_end > 10000} {
		return
	} elseif {$display_time_end > 1000} {
		set powdivisor 2
	} elseif {$display_time_end > 100} {
		set powdivisor 1
	} elseif {$display_time_end > 10} {
		set powdivisor 0
	} elseif {$display_time_end > 1} {
		set powdivisor -1
	} elseif {$display_time_end > .1} {
		set powdivisor -2
	} elseif {$display_time_end > .01} {
		set powdivisor -3
	} elseif {$display_time_end > .001} {
		set powdivisor -4
	} else {
		return
	}
	set step [expr pow(10.0,$powdivisor)]
	set stepcnt [expr double($display_time_end) / $step]
	if {$stepcnt < 20} {
		set stepexpander 1
	} elseif {$stepcnt < 40} {
		set stepexpander 2
	} elseif {$stepcnt < 80} {
		set stepexpander 4
	} else {
		set stepexpander 5
	}
	set step [expr $stepexpander * $step]
	set n 0
	while {$n <= $display_time_end} {
		set m [expr int(round ($n * $ratio))]
		incr m $evv(BWIDTH)
		set nn [StripTrailingZeros $n]
		$bkc(can) create line $m $bkc(timemarktop) $m $evv(BWIDTH) -fill $evv(POINT) -tag tmark
		$bkc(can) create text $m $bkc(timemarkbot) -text $nn -font brkxfnt -tag tmark -fill $evv(POINT)
		set n [expr $n + $step]
	}
}

#######################################
# CREATING EQ BRKPNT DATA GRAPHICALLY #
#######################################

#------ Create an eq brkfile for a parameter, for a selected process and infile

proc Dlg_MakeEqDatafile {pcnt} {
	global pr_eqfile eqq chlist pa eq_chwidth eq_nyquist eqfilename wstk
	global eqbbb evv prm ins small_screen eqfw pr_eqfile eqkc bkc
	global blist_change background_listing wl rememd eq_data_exists

	catch {destroy .cpd}
	set eq_data_exists 0
	set fnam [lindex $chlist 0]
	set srate $pa($fnam,$evv(ORIGRATE))
	set eq_nyquist [expr $srate / 2.0]

	set eqq(ismarked) 0

	set f .get_eqfile
	if [Dlg_Create .get_eqfile "" "set pr_eqfile 0" -borderwidth $evv(BBDR)] {
		if {$small_screen} {
			set can [Scrolled_Canvas $f.c -width $evv(SMALL_WIDTH) -height $evv(SMALL_HEIGHT) \
								-scrollregion "0 0 $evv(BRKF_WIDTH) $evv(SCROLL_HEIGHT)"]
			pack $f.c -side top -fill x -expand true
			set k [frame $can.f -bd 0]
			$can create window 0 0 -anchor nw -window $k
			set eqfw $k
		} else {
			set eqfw $f
		}	

		#	BUTTONS

		set eqbbb [frame $eqfw.btns -borderwidth 0]
		button $eqbbb.help 	  -text "Help" -width 6 -command "HelpEq"  -highlightbackground [option get . background {}] -bg $evv(HELP)
		button $eqbbb.save 	  -text "Save Data" -command "set pr_eqfile 1" -highlightbackground [option get . background {}]
		button $eqbbb.use 	  -text "Save & Use Data" -command "set pr_eqfile 2" -highlightbackground [option get . background {}]
		label  $eqbbb.lab	  -text "File Name" -width 16
		entry  $eqbbb.name	  -textvariable eqfilename
		button $eqbbb.load 	  -text "Load Data File for Editing" -command "EqFileLoad" -highlightbackground [option get . background {}]
		button $eqbbb.abdn 	  -text "Close" -width 7 -command "set pr_eqfile 0" -highlightbackground [option get . background {}]

		pack $eqbbb.help $eqbbb.save $eqbbb.use $eqbbb.lab $eqbbb.name $eqbbb.load -side left -padx 1
		pack $eqbbb.abdn -side right -padx 1

		# SPACING FRAME

		frame $eqfw.priti1 -height 8 -width 20

		#	CANVAS AND VALUE LISTING

		set eqq(XWIDTH) [expr int(round($evv(XWIDTH) * 5.0 / 4.0))]
		set eqq(width) [expr $eqq(XWIDTH) + (2 * $evv(BWIDTH))]
		set eqq(rectx2) [expr $eqq(XWIDTH) + $evv(BWIDTH)]

		set eqkc(can) [canvas $eqfw.c -height $bkc(height) -width $eqq(width) -borderwidth 0 \
			-highlightthickness 1 -highlightbackground $evv(SPECIAL)]

		pack $eqfw.btns -side top -fill x 
		pack $eqfw.c -side top -fill both

		$eqkc(can) create rect $bkc(rectx1) $bkc(recty1) $eqq(rectx2) $bkc(recty2) -tag outline -outline $evv(BRKTABLE_BORDER) 

		bind $eqkc(can) <ButtonRelease-1> 				{CreatePointEq %W %x %y}
		bind $eqkc(can) <Control-ButtonRelease-1>		{DeletePointEq %W %x %y}
		bind $eqkc(can) <Shift-ButtonPress-1> 			{MarkPointEq %W %x %y}
		bind $eqkc(can) <Shift-B1-Motion> 				{DragPointEq %W %x %y}
		bind $eqkc(can) <Shift-ButtonRelease-1>			{RelocatePointEq %W}
		bind $f <Escape> {set pr_eqfile 0}
	}
	wm resizable .get_eqfile 1 1
	wm title .get_eqfile "Create or Edit Data for Hilite Bands"		;#	Force title

	set eqfilename ""
	FullClearBrkDisplayEq $eqfw.btns											 
	set eqq(xdisplay_end) $eqq(XWIDTH)						;#	A created brktable always x-fills entire display
	set eqq(xdisplay_end_atedge) [expr int($eqq(xdisplay_end) + $evv(BWIDTH))]				

	set lo 0.0
	set hi 1.0

	EstablishGrafToRealConversionConstantsEq
	DisplayRangeInfoEq										;#
	ClearDisplayCoordinatesEq							;#	Clear any existing coordinate vals

	CreateInitialPointsEq
	set pr_eqfile 0
	raise .get_eqfile
	update idletasks
	StandardPosition .get_eqfile
	My_Grab 0 .get_eqfile pr_eqfile						;#	Create brkfile, and give it a name
	set finished 0
	while {!$finished} {
		tkwait variable pr_eqfile
		if {$pr_eqfile} {
			if {![ValidCDPRootname $eqfilename]} {
				continue
			}
			set eq_data [ConvertDataToEqFileFormat]
			if {[llength $eq_data] <= 0} {
				Inf "No Significant Data To Store"
				continue
			}
			set fnam $eqfilename
			append fnam [GetTextfileExtension brk]
			if {[file exists $fnam]} {
				set msg "FILE $fnam ALREADY EXISTS: OVERWRITE IT ?"
				set choice [tk_messageBox -message $msg -type yesno -icon question -parent [lindex $wstk end]]
				if [string match $choice "no"] {
					continue
				}
				set blist_change 0
				if [DeleteFileFromSystem $fnam 1 1] {
					DummyHistory $fnam "DESTROYED"
				}
				if {$blist_change} {
					SaveBL $background_listing
				}
				set i [LstIndx $fnam $wl]
				if {$i >= 0} {
					WkspCnt [$wl get $i] -1
					$wl delete $i
					catch {unset rememd}
				}
			}
			if [catch {open $fnam "w"} zit] {
				Inf "Cannot Open File $fnam"
				continue
			}
			WriteDataInEqFileFormat $eq_data $zit
			close $zit
			if {[FileToWkspace $fnam 0 0 0 0 1] <= 0} { 
				if [catch {file delete -force $fnam} result] {
					ErrShow "Cannot delete invalid file $fnam"
				} else {
					if {$ins(create)} {
						set inside_ins_create 1
					}
					DummyHistory $fnam "DESTROYED"
					catch {unset inside_ins_create}
				}
				DeleteFileFromSrcLists $fnam
				continue							;#	Put file on workspace, it it's valid file
			}
			Inf "Saved File $eqfilename"
			if {$pr_eqfile > 1} {
				set prm($pcnt) $fnam	 		;#	Enter filename as current prm val
				set finished 1
			}
		} else {
			break
		}
	}
	My_Release_to_Dialog .get_eqfile
	Dlg_Dismiss .get_eqfile
}													

#------ Create the points at max-level
#
#	 _								_
#	|_|----------------------------|_|
#

proc CreateInitialPointsEq {} {
	global displeq_c eqq evv
	set x  0
	set y 0
	catch {unset displeq_c}
	lappend displeq_c $x $y
	set x $eqq(XWIDTH)
	lappend displeq_c $x $y
	set eqq(coordcnt) 4
	set eqq(coordend) 2
	DisplayBrktableEq
}				  				

#############################################
# MOUSE OPERATIONS ON EQBRKFILE GRAPHICS	#
#############################################

#------ 
# 	Create point at place on edge of inner canvas when mouse clicks on outer-canvas
#		OR a straightforward point on the canvas
#

proc CreatePointEq {w x y} {
	global eqq evv

	set timedgepoint 0

	incr x -$evv(BWIDTH)
	incr y -$evv(BWIDTH)

	if {$x <= 0} {						 
		set	timedgepoint -1
		set x 0									 ;# C -> c:	Left edge
		if {$y < 0} {
			set y 0							 	 ;#	A -> a: Top left corner
		} elseif {$y > $evv(YHEIGHT)} {
			set y $evv(YHEIGHT)					 ;#	B -> b: Bottom left corner
		}									 
	} elseif {$x >= $eqq(xdisplay_end)} {
		set	timedgepoint 1
		set x $eqq(xdisplay_end)				 ;#	F -> f:	Right edge
		if {$y < 0} {
			set y 0								 ;#	D -> d: Top right corner
		} elseif {$y > $evv(YHEIGHT)} {
			set y $evv(YHEIGHT) 				 ;#	E -> e: Bottom right corner
		}
	} elseif {$y < 0} {
		set y 0								 	 ;#	G -> g: Top edge
	} elseif {$y > $evv(YHEIGHT)} {
		set y $evv(YHEIGHT)			 			 ;#	H -> h: Bottom edge
	}
	switch -- $timedgepoint {	
		-1 {
			if {![InjectStartPointIntoListsEq $y]} {
				return
			} else {
				set redrawpoints 1
			}
		}
		1 {
			if {![InjectEndPointIntoListsEq $y]} {
				return
			} else {
				set redrawpoints 1
			}
		}
		default {
			if {![InjectPointIntoListsEq $x $y]} {
				return
			} else {
				set redrawpoints 0
			}
		}
	}
	if {$redrawpoints} {
		DisplayBrktableEq
	} else {
		DrawPointEq $x $y
		DrawGrafLineEq 1
	}
}

#------ Delete point closest to place where mouse clicks on inner-canvas

proc DeletePointEq {w x y} {
	global evv eqq eqkc

	set obj [GetClosestPointEq $x $y]
	set coords [$eqkc(can) coords $obj]		 	 	;#	Only x-coord required, as can't have time-simultaneous points

	set x [expr round([lindex $coords 0])]			;#	Coords returns floats: convert to int

	#	CONVERT TO CENTRE OF POINT

	incr x $evv(PWIDTH)

	#	CONVERT TO MY COORDS

	incr x -$evv(BWIDTH)

	set indx [FindThisPointInListEq $x]
	if {$indx > 0 && $indx < $eqq(coordend)} {	 ;#	Can't delete brktable endpoints
		catch {$eqkc(can) delete $obj} in	 	 ;#	Delete it
		if [RemovePointFromListsEq $indx] {		 ;#	and remove from listings
			DrawGrafLineEq 1
		}
	}
}

#------ Mark point closest to place where mouse shift-clicks on inner-canvas

proc MarkPointEq {w x y} {
	global eqpnt eqq eqkc displeq_c evv
	set eqq(ismarked) 0														
#MARCH 7 2005
	set eqpnt(obj) [GetClosestPointEq $x $y]
	set coords [$eqkc(can) coords $eqpnt(obj)]		 	 	
	set eqpnt(x) [expr round([lindex $coords 0])]			;#	Coords returns floats: convert to int
	set eqpnt(y) [expr round([lindex $coords 1])]			;#	as can't have time-simultaneous points

#	CONVERT TO CENTRE OF POINT

	incr eqpnt(x) $evv(PWIDTH)
	incr eqpnt(y) $evv(PWIDTH)

	if {$eqpnt(x) == $evv(BWIDTH)} {
		return												;#	Can't drag end points
	} elseif {$eqpnt(x) == $eqq(xdisplay_end_atedge)} {
		return												;#	Can't drag end points
	}

	set eqpnt(mx) $x							 			;# 	Save coords of mouse
	set eqpnt(my) $y

	set eqpnt(lastx) $eqpnt(x)							;#	Remember coords of point
	set eqpnt(lasty) $eqpnt(y)						

	#	CONVERT TO MY COORDS, AND SAVE AS orig COORDS

	set eqpnt(origx) $eqpnt(x)
	incr eqpnt(origx) -$evv(BWIDTH)
	set eqpnt(origy) $eqpnt(y)
	incr eqpnt(origy) -$evv(BWIDTH)

	set eqpnt(timindex) [FindMotionLimitsInFrqDimension $eqpnt(origx)]
	if {$eqpnt(timindex) < 0} {
		return
	}
	set eqpnt(valindex) $eqpnt(timindex)
	incr eqpnt(valindex)
	set eqq(ismarked) 1											;#	Flag that a point is marked
}

#------ Drag marked point, with shift and mouse pressed down

proc DragPointEq {w x y} {
	global eqpnt eqq eqkc bkc eqqkrightstop eqqleftstop displeq_c evv

	if {!$eqq(ismarked)} {
		return
	}
	set mx $x									 		;#	Map from mouse-coords to canvas-coords
	set my $y						 	
	set dx [expr $mx - $eqpnt(mx)]				 		;#	Find distance from last marked position of mouse
	set dy [expr $my - $eqpnt(my)]
	incr eqpnt(x) $dx									;#	Get coords of dragged point

	if {$eqpnt(x) > $eqqkrightstop} {					;#	Check for drag too far right, and, if ness
		set eqpnt(x) $eqqkrightstop						;#	adjust coords of point
		set dx [expr $eqpnt(x) - $eqpnt(lastx)]		;#	and adjust drag-distance
	} elseif {$eqpnt(x) < $eqqleftstop} {				;#	Check for drag too far left, and, if ness
		set eqpnt(x) $eqqleftstop						;#	adjust coords of point
		set dx [expr $eqpnt(x) - $eqpnt(lastx)]		;#	and adjust drag-distance
	}
	set eqpnt(lastx) $eqpnt(x)						;#	Remember new x coord
  
	incr eqpnt(y) $dy									
	if {$eqpnt(y) > $bkc(mouse_yheight)} {				;#	Check for drag too far down, and, if ness
		set eqpnt(y) $bkc(mouse_yheight)				;#	adjust coords of point
		set dy [expr $eqpnt(y) - $eqpnt(lasty)]		;#	and adjust drag-distance
	} elseif {$eqpnt(y) < $evv(BWIDTH)} {
		set eqpnt(y) $evv(BWIDTH)						;#	adjust coords of point
		set dy [expr $eqpnt(y) - $eqpnt(lasty)]		;#	and adjust drag-distance
	}

	set eqpnt(lasty) $eqpnt(y)						;#	Remember new y coord

	$w move $eqpnt(obj) $dx $dy				 		;#	Move object to new position
	set eqpnt(mx) $mx							 		;#  Store new mouse coords
	set eqpnt(my) $my
	set x [expr round($eqpnt(x) - $evv(BWIDTH))]
	set y [expr round ($eqpnt(y) - $evv(BWIDTH))]
	set valindex $eqpnt(timindex)
	incr valindex
	set displeq_c [lreplace $displeq_c $eqpnt(timindex) $valindex $x $y]
	DrawGrafLineEq 1
}

#------ Register position of dragged point, in the coordinates lists

proc RelocatePointEq {w} {
	global eqpnt displeq_c eqq evv

	if {!$eqq(ismarked)} {
		return
	}

	set moved 0
	set movedx 0
	set movedy 0

	#	CONVERT TO MY COORDS

	incr eqpnt(x) -$evv(BWIDTH)
	incr eqpnt(y) -$evv(BWIDTH)

	if {$eqpnt(origx) != $eqpnt(x)} {
		set moved 1
		set movedx 1
	}
	if {$eqpnt(origy) != $eqpnt(y)} {
		set moved 1
		set movedy 1
	}
	set eqq(ismarked) 0
}

#------ Delete a point from the coords list

proc RemovePointFromListsEq {timindex} {
	global displeq_c eqq 
	set valindex $timindex
	incr valindex
	set displeq_c [lreplace $displeq_c $timindex $valindex]			
	incr eqq(coordcnt) -2
	incr eqq(coordend) -2
	return 1
}

#------ Find given point in coords list

proc FindThisPointInListEq {xa} {
	global displeq_c
	set timindex 0
	foreach {x y} $displeq_c {
		if [string match $x $xa] {
			return $timindex
		}
		incr timindex 2
	}
	return -1
}

#------ Put a newly created point into the coords list

proc InjectPointIntoListsEq {x y} {
	global displeq_c eqq
	 
	set timindex 0
	set valindex 1

	foreach {xa ya} $displeq_c {
		if [string match $x $xa] {
			return 0					;#	Cannot overwrite existing time
		} elseif {$xa < $x} {
			incr timindex 2
			incr valindex 2
			continue
		}
		set displeq_c [linsert $displeq_c $timindex $x $y]
		incr eqq(coordcnt) 2
		incr eqq(coordend) 2
		return 1
		break
	}
	return 0
}

#------ Put a newly created start point into the coords list

proc InjectStartPointIntoListsEq {y} {
	global displeq_c eqq

	set valindex 1
	if [string match [lindex $displeq_c $valindex] $y] {
		return 0
	}
	set displeq_c [lreplace $displeq_c $valindex $valindex $y]
	return 1
}

#------ Put a newly created end point into the coords list

proc InjectEndPointIntoListsEq {y} {
	global displeq_c eqq

	set valindex $eqq(coordend)
	incr valindex
	if [string match [lindex $displeq_c $valindex] $y] {
		return 0
	}
	set displeq_c [lreplace $displeq_c $valindex $valindex $y]
	return 1
}

#------ Find adjacent points to a given point in coords list

proc FindMotionLimitsInFrqDimension {xa} {
	global displeq_c eqq eqqkrightstop eqqleftstop evv
	set preindex -2
	set timindex 0
	set postindex 2
	foreach {x y} $displeq_c {
		if [string match $x $xa] {
			if {$timindex == 0} {
				ErrShow "Got start-point: Impossible"
				return -1
			} elseif {$timindex == $eqq(coordend)} {
				ErrShow "Got end-point: Impossible"
				return -1
			} else {
				set eqqleftstop  [lindex $displeq_c $preindex]
				incr eqqleftstop
				set eqqkrightstop [lindex $displeq_c $postindex]
				incr eqqkrightstop -1
				incr eqqkrightstop $evv(BWIDTH)
				incr eqqleftstop  $evv(BWIDTH)
				return $timindex
			}
		}
		incr preindex 2
		incr timindex 2
		incr postindex 2
	}
	return -1
}

#------ Clear brkpoint display completely (must always be followed by points insertion!)

proc FullClearBrkDisplayEq {b} {
	global eqq eqkc
	catch {$eqkc(can) delete cline}  in
	catch {$eqkc(can) delete points} in
	catch {$eqkc(can) delete rangeinfo} in
	set eqfilename ""
	ForceVal $b.name $eqfilename
}

#------ Clear existing coordinate and real-coordinate values

proc ClearDisplayCoordinatesEq {} {
	global displeq_c eqq
	catch {unset displeq_c} in
	set eqq(coordcnt) 0
}

#------ Establish Constants used to Convert Graf points to Real value-pairs

proc EstablishGrafToRealConversionConstantsEq {} {
	EstablishGrafToRealConversionConstantsEq_x
	EstablishGrafToRealConversionConstantsEq_y
}

#------ Establish Constants used to Convert Graf time values to Real time values

proc EstablishGrafToRealConversionConstantsEq_x {} {
	global eqq eq_nyquist evv

	#	CONVERT FROM GRAF ACTIVE X-RANGE TO REAL EQ RANGE
	set eqq(xgraftoval) [expr double($eq_nyquist) / $eqq(XWIDTH)]
	#	CONVERT FROM REAL TIME RANGE TO GRAF ACTIVE X-RANGE
	set eqq(xvaltograf) [expr double($eqq(XWIDTH)) / $eq_nyquist] 
}	

#------ Establish Constants used to Convert Graf values to Real values

proc EstablishGrafToRealConversionConstantsEq_y {} {
	global eqq evv
	set eqq(ygraftoval) [expr 1.0 / double($evv(YHEIGHT))]
	set eqq(yvaltograf) double($evv(YHEIGHT))
}	

#------ 
#  Display values of top and bottom of range, in outer canvas.
#

proc DisplayRangeInfoEq {} {
	global evv eqq eqkc bkc eq_nyquist
	catch {$eqkc(can) delete rangeinfo}
	set rmid [expr ($bkc(text_rangebot) + $bkc(text_rangetop)) / 2]
	$eqkc(can) create text $bkc(rangetext_xoffset) $bkc(text_rangebot) -text 0.0 \
			-font brkxfnt -tag {rangeinfo} -fill $evv(POINT)
	$eqkc(can) create text $bkc(rangetext_xoffset) $bkc(text_rangetop) -text 1.0 \
			-font brkxfnt -tag {rangeinfo} -fill $evv(POINT)
	$eqkc(can) create text $bkc(rangetext_xoffset) $rmid -text AMP \
			-font brkxfnt -tag {rangeinfo} -fill $evv(POINT)
	catch {$eqkc(can) delete tmark}
	set ratio [expr double($eqq(XWIDTH)) / $eq_nyquist]
	set n 1
	set nn [expr double($n) * 1000.0]
	while {$nn <= $eq_nyquist} {
		set m [expr int(round ($nn * $ratio))]
		incr m $evv(BWIDTH)
		$eqkc(can) create line $m $bkc(timemarktop) $m $evv(BWIDTH) -fill $evv(POINT) -tag tmark
		set thistext $n
		append thistext K
		$eqkc(can) create text $m $bkc(timemarkbot) -text $thistext -font brkxfnt -tag tmark -fill $evv(POINT)
		incr n
		set nn [expr double($n) * 1000.0]
	}
	set lo [expr $bkc(timemarkbot) + ($evv(BWIDTH)/2)]
	set m [expr int(round (($eq_nyquist * $ratio)/2.0))]
	incr m $evv(BWIDTH)
	$eqkc(can) create text $m $lo -text FRQ -font brkxfnt -tag tmark -fill $evv(POINT)
}

#------ Display existing file (or rather, the coords we have stored)

proc DisplayBrktableEq {} {
	DrawGrafPointsEq
	DrawGrafLineEq 1
}	

#------ Draw points on graf, from stored coords

proc DrawGrafPointsEq {} {
	global eqkc displeq_c
	catch {$eqkc(can) delete points} in		;#	destroy any existing points
	foreach {x y} $displeq_c {
		DrawPointEq $x $y
	}
}

#------ Draw line on graf

proc DrawGrafLineEq {update_vals} {
	global eqkc displeq_c evv	  
	catch {$eqkc(can) delete cline}
	foreach {x y} $displeq_c {
		incr x $evv(BPWIDTH)
		incr y $evv(BWIDTH)
		lappend line_c $x $y
	}
	eval {$eqkc(can) create line} $line_c {-fill $evv(GRAF)} {-tag cline}
}

#------ Create a point (small rectangle) in graph

proc DrawPointEq {x y} {
	global evv eqkc
	incr x $evv(BWIDTH)
	incr y $evv(BWIDTH)
	set xa [expr int($x - $evv(PWIDTH))]
	set ya [expr int($y - $evv(PWIDTH))]
	set xb [expr int($x + $evv(PWIDTH))]
	set yb [expr int($y + $evv(PWIDTH))]
	$eqkc(can) create rect $xa $ya $xb $yb -fill $evv(POINT) -tag points
}

#------ Convert real timevalue to grafpoint time 

proc RealToGrafxEq {x} {
	global evv eqq
	set x [expr round($x * $eqq(xvaltograf))]
	return $x
}

#------ Convert real value to grafpoint value

proc RealToGrafyEq {y} {
	global evv eqq
	set y [expr $y * $eqq(yvaltograf)]						;#	Convert into graf range
	set y [expr	round($evv(YHEIGHT) - $y)]					;#	Invert y-display
	return $y
}

proc GetClosestPointEq {x y} {
	global evv eqkc eqq
	incr x -$evv(PWIDTH)
	incr y -$evv(PWIDTH)
	set mindist $eqq(XWIDTH)
	incr mindist $eqq(XWIDTH)
	set displaylist [$eqkc(can) find withtag points]	;#	List all objects which are points
	foreach obj $displaylist {						;#	For each point
		set coords [$eqkc(can) coords $obj]			;#	Only x-coord needed: can't have frq-simultaneous points
		set objx [expr round([lindex $coords 0])]	;#	Only x-coord needed: can't have frq-simultaneous points
		set thisdist [expr abs($x - $objx)]
		if {$thisdist < $mindist} {
			set mindist $thisdist
			set closest_obj $obj
			set objy [expr round([lindex $coords 1])]
			set thatydist [expr abs($y - $objy)]
		} elseif {$thisdist == $mindist} {
			if {[info exists thisydist]} {
				set objy [expr round([lindex $coords 1])]
				set thisydist [expr abs($y - $objy)]
				if {$thisydist < $thatydist} {
					set thatydist $thisydist
					set closest_obj $obj
				}
			}
		} else {
			catch {unset thisydist}
		}
	}
	return $closest_obj
}

######################
# LOAD EQ DATA FILES #
######################

proc EqFileLoad {} {
	global pr_eqload displayeq_ok wl pa eqfilename eq_data_exists evv

	set cnt 0
	foreach fnam [$wl get 0 end] {
		if {$pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)} {
			lappend zfiles $fnam
			incr cnt
		}
	}
	if {$cnt == 0} {
		Inf "There Are No Textfiles On The Workspace"
		return
	}
	set displayeq_ok 0
	set f .eqload
	if [Dlg_Create $f "TEXT FILES" "set pr_eqload 0" -borderwidth $evv(BBDR)] {
		frame $f.1 -borderwidth 0
		button $f.1.l -text "Get File" -command "set pr_eqload 1" -highlightbackground [option get . background {}]
		button $f.1.q -text "Close" -command "set pr_eqload 0" -highlightbackground [option get . background {}]
		pack $f.1.l -side left -pady 2
		pack $f.1.q -side right -pady 2
		frame $f.2 -borderwidth 0
		Scrolled_Listbox $f.2.ll -width 80 -height 20 -selectmode single
		pack $f.2.ll -side top -fill both -expand true
		pack $f.1 $f.2 -side top -fill x -expand true -pady 2
		bind $f <Return> {set pr_eqload 1}
		bind $f <Escape> {set pr_eqload 0}
	}
	$f.2.ll.list delete 0 end
	set zfiles [lsort $zfiles]
	foreach fnam $zfiles {
		$f.2.ll.list insert end $fnam
	}
	set pr_eqload 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_eqload
	while {!$finished} {
		tkwait variable pr_eqload
		if {$pr_eqload} {
			set i [$f.2.ll.list curselection]
			if {$i < 0} {
				Inf "No File Selected"
				continue
			}
			set fnam [$f.2.ll.list get $i]
			if {![GetEqFileDisplayData $fnam]} {
				continue
			}
			set displayeq_ok 1
			set finished 1
		} else {
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	if {$displayeq_ok} {
		catch {$eqkc(can) delete cline} in
		DisplayBrktableEq
		set eqfilename [file rootname $fnam]
		set eq_data_exists 1
	}
}

#------ Display an eq-datafile

proc GetEqFileDisplayData {fnam} {
	global eqq displeq_c eqkc eq_nyquist

	set lasttopfrq 0.0
	set lasttopamp 0.0
	if {![file exists $fnam]} {
		Inf "File $fnam Does Not Exist"
		return 0
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File $fnam"
		return 0
	}
	set linecnt 1
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
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
		set len [llength $nuline] 
		if {($len < 4) || ($len > 5)} {
			Inf "Invalid File Type To Represent EQ Bands"
			catch {close $zit}
			return 0
		}
		set bitflag [lindex $nuline 2]
		set bum 0
		switch -- $bitflag {
			"1000" {
				set flat 1
				if {$len != 4} { 
					set bum 1
				}
			}
			"1100" {
				set flat 0
				if {$len != 5} { 
					set bum 1
				}
			}
			default {
				set bum 1
			}
		}
		if {$bum} {
			Inf "Invalid File Type To Represent EQ Bands"
			catch {close $zit}
			return 0
		}
		set botfrq [lindex $nuline 0]
		set topfrq [lindex $nuline 1]
		if {$topfrq > $eq_nyquist} {
			Inf "Frqs Too High For This Analysis File: Line $linecnt"
			catch {close $zit}
			return 0
		}
		if {$topfrq <= $botfrq} {
			Inf "Frqs In Wrong Order: Line $linecnt"
			catch {close $zit}
			return 0
		}
		set thisamp [lindex $nuline 3]
		if {($thisamp < 0.0) || ($thisamp > 1.0)} {
			Inf "Invalid Amplitude Value At Line $linecnt"
			catch {close $zit}
			return 0
		}
		if {$botfrq < $lasttopfrq} {
			if {$botfrq < 0.0} {
				Inf "Negative Frq At Line $linecnt"
			} else {
				Inf "Frq Bands Overlap At Line $linecnt"
			}
			catch {close $zit}
			return 0
		}
		if {![Flteq $botfrq $lasttopfrq]} {		;# BANDS BETWEEN SPECIFIED-BANDS
			set gap [expr $botfrq - $lasttopfrq]
			if {$gap <= 3.0} {
				set gap [expr $gap / 3.0]
			} else {
				set gap 1.0
			}
			if {$lasttopfrq <= 0.0} {
				lappend nulist $lasttopfrq 1.0	;#	INSERTS VALUE AT FRQ ZERO
			} else {
				lappend	nulist [expr $lasttopfrq + $gap] 1.0
			}
			lappend nulist [expr $botfrq - $gap] 1.0
		}
		if {$flat} {
			lappend nulist $botfrq $thisamp $topfrq $thisamp
		} else {
			set thatamp [lindex $nuline 4]
			if {($thatamp < 0.0) || ($thatamp > 1.0)} {
				Inf "Invalid 2nd Amplitude Value At Line $linecnt"
				catch {close $zit}
				return 0
			}
			lappend nulist $botfrq $thisamp $topfrq $thatamp
		}
		set lasttopfrq $topfrq
		if {$flat} {
			set lasttopamp $thisamp
		} else {
			set lasttopamp $thatamp
		}
		incr linecnt
	}
	catch {close $zit}
	set cnt 0
	set totcnt 0
	foreach {frq amp} $nulist {				;# REMOVE REDUNDANT POINTS
		if {$cnt == 0} {
			set lalastamp $amp
		} elseif {$cnt == 1} {
			set lastamp $amp
		} else {
			if {($lalastamp == $lastamp) && ($lastamp == $amp)} {
				set len [llength $outlist]
				incr len -3
				set outlist [lrange $outlist 0 $len]
				incr totcnt -1
			}
			set lalastamp $lastamp
			set lastamp $amp
		}
		lappend outlist $frq $amp
		set lastfrq $frq
		incr cnt
		incr totcnt
	}
	if {$totcnt == 0} {
		Inf "No Siginficant Data In File"
		return 0
	}
	if {![Flteq $lastfrq $eq_nyquist]} {	;#	ADD NYQUIST POINT
		if {$lastamp != 1.0} {
			set gap [expr $eq_nyquist - $lastfrq]
			if {$gap <= 2.0} {
				set gap [expr $gap / 3.0]
			} else {
				set gap 1.0
			}

			lappend outlist [expr $lastfrq + $gap] 1.0
		}
		lappend outlist $eq_nyquist 1.0
	}
	catch {unset displeq_c} in
	set eqq(coordcnt) 0
	foreach {frq amp} $outlist {
		lappend displeq_c [RealToGrafxEq $frq] [RealToGrafyEq $amp]
		incr eqq(coordcnt) 2
		incr eqq(coordend) 2
	}
	return 1
}

#######################
# WRITE EQ DATA FILES #
#######################

proc ConvertDataToEqFileFormat {} {
	global displeq_c eqq evv
	foreach {x y} $displeq_c {
		set x [expr $x * $eqq(xgraftoval)]
		set y [expr	round($evv(YHEIGHT) - $y)]
		set y [expr $y * $eqq(ygraftoval)]
		lappend frqamp $x $y
	}
	set cnt 0
	foreach {frq amp} $frqamp {
		if {$cnt == 0} {
			set lalastamp $amp
		} elseif {$cnt == 1} {
			set lastamp $amp
		} else {
			if {($lalastamp == $lastamp) && ($amp == $lastamp)} {
				set len [llength $nuvals]
				incr len -3		;#	DELETE LAST VAL, REDUNDANT
				set nuvals [lrange $nuvals 0 $len]
			}
			set lalastamp $lastamp
			set lastamp $amp
		}
		lappend nuvals $frq $amp
		incr cnt
	}
	set OK 0
	foreach {frq amp} $nuvals {
		if {![Flteq $amp 1.0]} {
			set OK 1
			break
		}
	}
	if {!$OK} {
		return {}
	}
	return $nuvals
}

proc WriteDataInEqFileFormat {eq_data zit} {
	global displeq_c eqq evv
	set cnt 0
	foreach {frq amp} $eq_data {
		if {$cnt != 0} {
			if {$amp != $lastamp} {
				set bitflag 1100
				set line "$lastfrq $frq $bitflag $lastamp $amp"
				puts $zit $line
			} elseif {![Flteq $amp 1.0]} {
				set bitflag 1000
				set line "$lastfrq $frq $bitflag $amp"
				puts $zit $line
			}
		}
		set lastfrq $frq
		set lastamp $amp
		incr cnt
	}		
}

proc HelpEq {} {
	set msg "                               *********************************\n"
	append msg "                                 DRAWING OR MODIFYING EQ DATA\n"
	append msg "                              *********************************\n\n"
	append msg "LOAD EXISTING FILE:                      USE \"Load a Data File\" BUTTON & SELECT FILE FROM LIST\n\n"
	append msg "CREATE A BREAKPOINT:                   MOUSE CLICK ON DISPLAY\n"
	append msg "CREATE A BREAKPOINT AT EDGE:    MOUSE CLICK OUTSIDE MAIN DISPLAY AREA\n"
	append msg "DELETE A BREAKPOINT:                    CONTROL MOUSE CLICK\n"
	append msg "MOVE A BREAKPOINT:                       SHIFT CLICK AND DRAG THE POINT WITH MOUSE\n\n"
	append msg "SAVE & USE THE DATA:                   USE \"Save & Use Data\" BUTTON\n"
	Inf $msg
}

#######################################
# CREATING FORMANT BRKPNT DATA GRAPHICALLY #
#######################################

#------ Display a single formant, using data in temporary textfile

proc DisplayFormantData {ffnam range vals maxval} {
	global pr_oneform chlist pa eq_chwidth fo_nyquist wstk
	global evv small_screen fofw pr_oneform fokc bkc fo fodfrom fodto

	catch {destroy .cpd}
	set fnam [lindex $chlist 0]
	set srate $pa($fnam,$evv(ORIGRATE))
	set fo_nyquist [expr $srate / 2.0]
	set f .get_fofile
	if [Dlg_Create $f "FORMANT ENVELOPE" "set pr_oneform 0" -borderwidth $evv(BBDR)] {
		if {$small_screen} {
			set can [Scrolled_Canvas $f.c -width $evv(SMALL_WIDTH) -height $evv(SMALL_HEIGHT) \
								-scrollregion "0 0 $evv(BRKF_WIDTH) $evv(SCROLL_HEIGHT)"]
			pack $f.c -side top -fill x -expand true
			set k [frame $can.f -bd 0]
			$can create window 0 0 -anchor nw -window $k
			set fofw $k
		} else {
			set fofw $f
		}	

		#	BUTTONS
		frame $fofw.1
		button $fofw.1.redi -text "Redisplay" -command "set pr_oneform 1" -highlightbackground [option get . background {}]
		label $fofw.1.f -text "  from  "
		entry $fofw.1.from -textvariable fodfrom -width 8 
		label $fofw.1.t -text "  to "
		entry $fofw.1.to -textvariable fodto -width 8 
		label $fofw.1.hz -text "Hz"
		button $fofw.1.quit 	  -text "Close" -command "set pr_oneform 0" -highlightbackground [option get . background {}]
		pack $fofw.1.redi $fofw.1.f $fofw.1.from $fofw.1.t $fofw.1.to $fofw.1.hz -side left -padx 2
		pack $fofw.1.quit -side right
		pack $fofw.1 -side top -pady 2 -fill x -expand true

		# SPACING FRAME

		frame $fofw.priti1 -height 8 -width 20

		#	CANVAS AND VALUE LISTING

		set fo(XWIDTH) [expr int(round($evv(XWIDTH) * 5.0 / 4.0))]
		set fo(width) [expr $fo(XWIDTH) + (2 * $evv(BWIDTH))]
		set fo(rectx2) [expr $fo(XWIDTH) + $evv(BWIDTH)]

		set fokc(can) [canvas $fofw.c -height $bkc(height) -width $fo(width) -borderwidth 0 \
			-highlightthickness 1 -highlightbackground $evv(SPECIAL)]

		pack $fofw.c -side top -fill both

		$fokc(can) create rect $bkc(rectx1) $bkc(recty1) $fo(rectx2) $bkc(recty2) -tag outline -outline $evv(BRKTABLE_BORDER) 
		bind $f <Return> {set pr_oneform 1}
		bind $f <Escape> {set pr_oneform 0}
	}
	wm resizable $f 1 1
	wm title $f "FORMANTS IN FILE $ffnam"		;#	Force title

	set fodfrom ""
	set fodto ""
	DisplayFormant $range $vals $maxval 0 $fo_nyquist
	set pr_oneform 0
	set finished 0 
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_oneform
	set finished 0
	while {!$finished} {
		tkwait variable pr_oneform
		if {$pr_oneform} {
			if {![IsNumeric $fodfrom] || ![IsNumeric $fodto]} {
				Inf	"Invalid Values Given For Display Limits"
				continue
			} elseif {[Flteq $fodfrom $fodto]} {
				Inf	"Redisplay Range Is Too Small"
				continue
			} elseif {$fodfrom < 0.0} {
				Inf "Lower Range Limit Is Not Valid."
				continue
			} elseif {$fodto > $fo_nyquist} {
				set msg "Upper Range Limit Too High. Readjust To Nyquist ?"
				set choice [tk_messageBox -message $msg -type yesno -icon question -parent [lindex $wstk end]]
				if [string match $choice "no"] {
					continue
				} else {
					set fodto $fo_nyquist
				}
			}
			if {$fodfrom > $fodto} {
				set temp $fodto
				set fodto $fodfrom
				set fodfrom $temp
			} 
			DisplayFormant $range $vals $maxval $fodfrom $fodto

		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}													


#------ 
#  Display values of top and bottom of range, in outer canvas.
#

proc DisplayRangeInfoFo {range val maxval lo hi} {
	global evv fo fokc bkc fo_nyquist

	catch {$fokc(can) delete rangeinfo}
	set maxvalz [DecPlaces $maxval 6]
	set rmid [expr ($bkc(text_rangebot) + $bkc(text_rangetop)) / 2]
	$fokc(can) create text $bkc(rangetext_xoffset) $bkc(text_rangebot) -text 0.0 \
			-font brkxfnt -tag {rangeinfo} -fill $evv(POINT)
	$fokc(can) create text $bkc(rangetext_xoffset) $bkc(text_rangetop) -text $maxvalz \
			-font brkxfnt -tag {rangeinfo} -fill $evv(POINT)
	$fokc(can) create text $bkc(rangetext_xoffset) $rmid -text AMP \
			-font brkxfnt -tag {rangeinfo} -fill $evv(POINT)
	catch {$fokc(can) delete tmark}
	set thisrange [expr $hi - $lo]
	set ratio [expr double($fo(XWIDTH)) / $thisrange]
	set n 1
	set incra [expr int(round($thisrange / 20.0))]
	set nn $lo
	foreach val $range {
		if {$val > $hi} {
			break
		} elseif {$val >= $lo} { 
			if {$val > $nn} {
				set pos [expr int(round($val * $ratio))]
				incr pos $evv(BWIDTH)
				set val [expr int(round($val))]
				if {$val > 9999} {
					set val [string range $val 0 1]
					append val "K"
				} elseif {$val > 999} {
					set nuval [string index $val 0]
					append nuval "." [string index $val 1] "K"
					set val $nuval
				}
				$fokc(can) create line $pos $bkc(timemarktop) $pos $evv(BWIDTH) -fill $evv(POINT) -tag tmark
				$fokc(can) create text $pos $bkc(timemarkbot) -text $val -font brkxfnt -tag tmark -fill $evv(POINT)
				incr nn $incra
			}
		}
	}
	set lopos [expr $bkc(timemarkbot) + ($evv(BWIDTH)/2)]
	set m [expr int(round (($fo_nyquist * $ratio)/2.0))]
	incr m $evv(BWIDTH)
	$fokc(can) create text $m $lopos -text FRQ -font brkxfnt -tag tmark -fill $evv(POINT)
}

proc DisplayFormant {range vals maxval lo hi} {
	global fokc fo evv 

	catch {$fokc(can) delete cline}  in
	catch {$fokc(can) delete points} in
	DisplayRangeInfoFo $range $vals $maxval $lo $hi
	set thisrange [expr $hi - $lo]
	set ratio [expr double($fo(XWIDTH)) / $thisrange]
	set lastxtrupos 0
	foreach val $vals rang $range {
		if {$rang > $hi} {
			break
		} else {
			set here [expr $rang - $lo]
			set xtrupos [expr $here * $ratio]
			set xpos [expr int(round(($xtrupos + $lastxtrupos)/2))]
			if {$xpos >= 0} {
				incr xpos $evv(BWIDTH)
				set ypos [expr $val / $maxval]
				set ypos [expr int(round($ypos * $evv(YHEIGHT)))]
				set ypos [expr $evv(YHEIGHT) - $ypos]
				incr ypos $evv(BWIDTH)
				set xa [expr int($xpos - $evv(PWIDTH))]
				set ya [expr int($ypos - $evv(PWIDTH))]
				set xb [expr int($xpos + $evv(PWIDTH))]
				set yb [expr int($ypos + $evv(PWIDTH))]
				$fokc(can) create rect $xa $ya $xb $yb -fill $evv(POINT) -tag points
				lappend lc $xpos $ypos
			}
			set lastxtrupos $xtrupos
		}
	}
	if {[llength $lc] < 4} {
		Inf "Too Small Range To Display Formant Data"
		catch {$fokc(can) delete cline}  in
		catch {$fokc(can) delete points} in
		return
	}
	$fokc(can) create line $lc -fill $evv(POINT) -tag points
}
