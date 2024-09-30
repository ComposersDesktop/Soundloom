#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD June 28 2013
# ... fixup button rectangles
#######################################################
# RUN A BATCHFILE FROM A SPECIAL WINDOW IN SOUND LOOM #
#######################################################

proc GoToBatchProcessing {gotfile} {
	global wl batch_file batchname bdir pr_batch sl_real wstk pa evv panprocess chlist real_chlist thumbnailed set_thumbnailed ww
	global ch chcnt

	;# batch_file IS A LIST OF LINES OF THE BATCHFILE

	if {[info exists panprocess]} {
		return
	}
	if {[info exists real_chlist]} {
		Inf "Abandoning Thumbnail Processing"
		set chlist $real_chlist
		unset real_chlist
		catch {unset thumbnailed}
		catch {unset set_thumbnailed}
		$ww.1.a.mez.bkgd config -state normal
	}
	if {$sl_real} {
		Block "CHECKING FOR TEMPORARY FILES"
		foreach fnam [glob -nocomplain -- *] {
			set fnam [string tolower $fnam]
			set ftail [file tail $fnam]
			if {[string match $evv(DFLT_OUTNAME)* $ftail] \
			 || [string match $evv(MACH_OUTFNAME)* $ftail] \
			 || [string match $evv(DFLT_TMPFNAME)* $ftail]} {
				if [catch {file delete $fnam} xx] {
					Inf "Cannot Remove Temporary File '$fnam' : Ignoring It"
				} else {
					DeleteFileFromSrcLists $fnam
				}
			}
		}
		UnBlock
	} else {
		Inf "A Whole List Of CDP Processes Can Be Run As A Batchfile"
		return
	}
	if {$gotfile} {
		set i [$wl curselection]
		if {($i < 0) || ([llength $i] > 1)} {
			Inf "Select Just One Batchfile On The Workspace"
			return
		}
		set batchname [$wl get $i]
		if {!($pa($batchname,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
			Inf "File '$batchname' Is Not A Batchfile"
			return
		}
		if {![string match ".bat" [file extension $batchname]]} {
			set msg "File $batchname Does Not Have A Batchfile Extension: Change Extension ??"
			set choice [tk_messageBox -type yesno -message $msg -icon question -parent [lindex $wstk end]]
			if [string match $choice "no"] {
				return
			}
			set nufnam [file rootname $batchname]
			append nufnam $evv(BATCH_EXT)
			if {[file exists $nufnam]} {
				Inf "File $nufnam Already Exists : Cannot Rename The Batchfile"
				return
			}
			if [catch {file rename $batchname $nufnam} zit] {
				Inf "Cannot Rename File $batchname"
				return
			}
			set oldname_pos_on_chosen [LstIndx $batchname $ch]
			if {$oldname_pos_on_chosen >= 0} {
				RemoveFromChosenlist $batchname
				set chlist [linsert $chlist $oldname_pos_on_chosen $nufnam]
				incr chcnt
				$ch insert $oldname_pos_on_chosen $nufnam
			}
			UpdateChosenFileMemory $batchname $nufnam
			UpdateBakupLog $batchname delete 0
			UpdateBakupLog $nufnam create 1
			$wl delete $i								
			$wl insert $i $nufnam						;#	rename workspace item
			RenameProps	$batchname $nufnam 1				;#	rename props
			DummyHistory $batchname "RENAMED_$nufnam"
			AddNameToNameslist [file tail $nufnam] 0
			RenameOnDirlist $batchname $nufnam
		}
	}
	set f .batching
	if [Dlg_Create $f "BATCH FILE PROCESSING" "set pr_batch 1" -borderwidth $evv(SBDR)] {
		set fz [frame $f.z -borderwidth $evv(BBDR)]
		button $fz.i -text "Information" -width 10 -command "CDP_Specific_Usage $evv(BATCH) 0"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
		button $fz.sy -text "Syntax" -width 10 -command "BatchSyntaxDisplay"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
		pack $fz.i -side left
		pack $fz.sy -side right
		set f1 [frame $f.1 -borderwidth $evv(BBDR)]
		set f2 [frame $f.2 -borderwidth $evv(BBDR)]
		set f3 [frame $f.3 -borderwidth $evv(BBDR)]
		label $f1.fname -text "New filename  "
		entry $f1.e -textvariable batchname -width 32
		button $f1.save -text "Save Edited File" -command SaveBatchfile -highlightbackground [option get . background {}]
		pack $f1.fname $f1.e $f1.save -side left
		button $f2.run -text RUN -command RunBatch -highlightbackground [option get . background {}]
		button $f2.quit -text "Close" -command "set pr_batch 1" -highlightbackground [option get . background {}]
		pack $f2.run -side left
		pack $f2.quit -side right
		set t [text $f3.t -setgrid true -wrap word -width 84 -height 32 \
		-xscrollcommand "$f3.sx set" -yscrollcommand "$f3.sy set"]
		scrollbar $f3.sy -orient vert  -command "$f3.t yview"
		scrollbar $f3.sx -orient horiz -command "$f3.t xview"
		pack $f3.t -side left -fill both -expand true
		pack $f3.sy -side right -fill y
		pack $f.z -side top -fill x -expand true
		pack $f.1 -side top -pady 1
		pack $f.2 $f.3 -side top -fill x -expand true -pady 1 -padx 1
		wm resizable $f 1 1
		bind .batching.3.t <Control-Key-P> {UniversalPlay text .batching.3.t}
		bind .batching.3.t <Control-Key-p> {UniversalPlay text .batching.3.t}
		bind $f <Escape> {set pr_batch 1}
	}
	catch {unset batch_file}
	.batching.3.t delete 1.0 end
	if {$gotfile} {
		if {![LoadBatchfile]} {
			catch {destroy .batching}
			return
		}
	} 
#	set batchname ""
	set pr_batch 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_batch $f.3.t
	tkwait variable pr_batch
	My_Release_to_Dialog .batching
	catch {destroy .batching}
}

#-----------

proc LoadBatchfile {} {
	global batchname batch_file	sl_real evv
	set t .batching.3.t

	set ba_name $batchname
	if {![file exists $ba_name]} {
		Inf "File '$ba_name' Does Not Exist"
		return 0
	}
	if [catch {open $ba_name "r"} zib] {
		Inf "Cannot open file '$ba_name'"
		return 0
	}
	set i 0
	while {[gets $zib line] >= 0} {
		catch {unset newline}
		set line [string trim $line]
		set line [split $line]
		foreach item $line {
			if {[string length $item] > 0} {
				lappend newline $item
			}
		}
		if {![info exists newline]} {
			continue
		}
		set j 0
		foreach item $newline {
			if {$j == 0} {
				set nuline $item
				set j 1
			} else {
				append nuline " " $item
			}
		}
		set nuline [RegulariseDirectoryRepresentation_No_tolower $nuline]
		set nuline [StripLocalCurlies $nuline]
		lappend batch_file $nuline
		incr i
	}
	if {$i == 0} {
		Inf "No data in file '$ba_name'"
		catch {close $zib}
		return 0
	}
	$t delete 1.0 end
	foreach line $batch_file {
		$t insert end "$line\n"
	}	
	catch {close $zib}
	return 1
}

#-----------------

proc SaveBatchfile {} {
	global batchname wstk sl_real excluded_batchfiles evv

	if {!$sl_real} {
		Inf "You Can Save The New Version Of A Batchfile You Have Edited\nor A Newly Created Batchfile."
		return
	}

	set t .batching.3.t

	if {[string length $batchname] <=0 }	 {
		Inf "No filename given"
		return
	}
	set dir [file dirname $batchname]
	set name  [file tail $batchname]
	set rname [file rootname $name]
	set extname [file extension $name]
	if {![string match $name $rname] && ![string match $evv(BATCH_EXT) $extname]} {
		Inf "You Cannot Use Extensions In The Filename, Here"
		return
	} elseif {[lsearch $excluded_batchfiles $rname] >= 0} {
		Inf "This Is A Reserved Batchfile Name: Please Choose Another Name."
		return
	}
	if {![ValidCdpFilename $rname 1]} {
		return
	}
	set w_bname $batchname
	if {[string length $extname] <= 0} {
		append w_bname $evv(BATCH_EXT)
	}
	if [file exists $w_bname] {
		set choice [tk_messageBox -type yesno -message "File $w_bname already exists : Overwrite It?" \
			-icon question -parent [lindex $wstk end]]
		if [string match $choice "no"] {
			return
		} else {
			set it_exists 1
		}
	}
	if [catch {open $w_bname "w"} zib] {
		Inf "Cannot open file '$w_bname'"
		return
	}
	set i 0

	set imax [$t index end]
	set i 1
	set cnt 0
	while {$i < $imax} {
		catch {unset newline}
		set line [$t get $i.0 $i.end]
		set line [string trim $line]
		set line [split $line]
		set j 0
		foreach item $line {
			if {[string length $item] > 0} {
				if {$j == 0} {
					set	newline $item
					set j 1
				} else {
					append newline " " $item
				}
			}
		}
		if [info exists newline] {
			set newline [RegulariseDirectoryRepresentation $newline]
			puts $zib $newline
			incr cnt
		}
	 	incr i
	}
	close $zib
	if {$cnt == 0} {
		Inf "No data to save"
		if [catch {file delete $w_bname} zat] {
			Inf "Cannot delete empty file '$w_bname'"
		}
	} else {
		if {[info exists it_exists]} {
			DummyHistory $w_bname "BATCH_EDITED_OR_OVERWRITTEN"
		} else {
			DummyHistory $w_bname "BATCH_CREATED"
			FileToWkspace $w_bname 0 0 0 0 1
		}
	}
}

#-----------------

proc RunBatch {} {
	global rundisplay batch_file prg_dun sl_real

	set prg_dun 0
	catch {destroy .cpd}

	if {[ConvertDisplayToBatchfile] <= 0} {
		Inf "No batchfile data given"
		return
	}

	if [ExistingFilesAreDeleted] {
		return
	}

	if {![Create_Batch_Process_Display]} {
		return
	}
	raise .brunning
	My_Grab 0 .brunning prg_dun
	update idletasks
	StandardPosition .brunning
	tkwait visibility $rundisplay(done)
	tkwait window .brunning
}

#-----------------

proc Create_Batch_Process_Display {} {
	global rundisplay evv batch_file true_batch_file readonlyfg readonlybg

	if {![ConvertBatchoutfileRepresentation $batch_file]} {
		return 0
	}
	set f .brunning
	eval {toplevel $f} -borderwidth $evv(SBDR)
	wm protocol $f WM_DELETE_WINDOW "catch {My_Release_to_Dialog .brunning} ; catch {destroy .brunning}"
	wm resizable $f 1 1
	wm title $f "Running Batch File"

	set ft [frame $f.t -borderwidth $evv(BBDR)]						;#	Frame for start button 
	set fi [frame $f.i -borderwidth $evv(BBDR)]						;#	Frame for info box 
	set fd [frame $f.d -height $evv(PBAR_SEPARATOR_HEIGHT)]		 	;#	Dividing line
	set fp [frame $f.p -borderwidth $evv(BBDR)]						;#	frame for batch_cnt
																			
	pack $f.t $f.i $f.d $f.p -side top -fill x

	button $ft.ok  -text "Run" -command "RunBatchGo $f" -bg $evv(EMPH) -highlightbackground [option get . background {}]

	pack $ft.ok -side left
																				;#	INFOBOX DETAILS
	set t [text $fi.info -setgrid true -wrap word -width 120 -height 24 \
											-yscrollcommand "$fi.sy set"]
	$t tag configure warning -foreground $evv(WARN_COLR)   			;#	Text-colors for various messagetypes
	$t tag configure error   -foreground $evv(ERR_COLR) -background $evv(EMPH)
	$t tag configure info    -foreground $evv(INF_COLR)
	scrollbar $fi.sy -orient vertical -command "$fi.info yview"
	pack $fi.sy -side right -fill y
	pack $fi.info -side left -fill both -expand true	
	set fpc [frame $fp.cnt -borderwidth $evv(BBDR)]				;#	Frame for cnt of completed processes

	pack $fp.cnt -side top
	set rundisplay(done) [entry $fpc.e0 -textvariable rundisplay(processno) -width 20 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg]
	label $fpc.lab1 -text "Batchfile Line Number"				;#	Display batch-cnt
	label $fpc.lab2 -text "  of [expr int(round([.batching.3.t index end])) - 2]"
	pack $fpc.lab1 $fpc.e0 $fpc.lab2 -side left
	ForceVal .brunning.p.cnt.e0 ""
	bind $f <Return> {R_RunBatchGo}
	return 1
}

proc R_RunBatchGo {} {
	
	if {[string match [.brunning.t.ok cget -state] disabled]} {
		return
	} elseif {[string match [.brunning.t.ok cget -text] "Run"]} {
		RunBatchGo .brunning
	} elseif {[string match [.brunning.t.ok cget -text] "OK"]} {
		My_Release_to_Dialog .brunning
		destroy .brunning
	}
}

#------ Final run procedure from running batchfile

proc RunBatchGo {rpd} {
	global batch_file wl true_batch_file ww wksp_cnt total_wksp_cnt last_outfile batch_outfiles files_destroyed pprg
	global CDPidrun CDP_cmd prg_dun program_messages prg_abortd after_error rundisplay evv batchidle rememd

	if {![winfo exists .brunning]} {
		Inf "Run Window not ready"
		catch {My_Release_to_Dialog .brunning}
		catch {destroy .brunning}
		set prg_dun 0
		return
	}
	set batch_outfiles {}
	catch {unset files_destroyed}
	set rundisplay(processno) 0
	set cnt 0
	foreach line $true_batch_file origline $batch_file {
		set CDP_cmd $line
		incr rundisplay(processno)
		ForceVal $rpd.p.cnt.e0 $rundisplay(processno) 
		set CDPidrun 0
		set program_messages 0
		set prg_dun 0
		set prg_abortd 0
		set after_error 0
		.brunning.i.info insert end "$origline\n" {info}
		set program_messages 1
		set firstword [lindex $CDP_cmd 0]
		if {[string index $firstword 0] == "#" || [string index $firstword 0] == "@" || [string index $firstword 0] == ";" \
		|| 	[string match "rem" $firstword] || [string match "echo" $firstword]} {
			incr cnt
			continue
		} elseif {[string match "copysfx" $firstword]} {
			set CDP_cmd [lreplace $CDP_cmd 0 0 housekeep copy 1]
		} elseif {[string match "rmsf" $firstword]} {
			if {[llength $CDP_cmd] > 1} {
				set f_nam [lindex $CDP_cmd 1]
				if {[string length [file extension $f_nam]] <= 0} {
					append f_nam $evv(SNDFILE_EXT)
				}
				set CDP_cmd "rm"
				lappend CDP_cmd $f_nam
			} else {
				.brunning.i.info insert end "No filename Given\n" {error}
				incr cnt
				continue
			}
		}
		set firstword [lindex $CDP_cmd 0]
		if {[string match "rm" $firstword]} {
			if {[llength $CDP_cmd] > 1} {
				set f_nam [lindex $CDP_cmd 1]
				if {![file exists $f_nam]} {
					.brunning.i.info insert end "File $f_nam does not exist" {warning}
				} else {
					if [catch {file delete $f_nam} zit] {
						.brunning.i.info insert end "$zit\nCannot delete file $f_nam" {warning}
					} else {
						lappend files_destroyed $f_nam
						DummyHistory $f_nam "DESTROYED"
					}
				}
				incr cnt
				continue
			} else {
				.brunning.i.info insert end "No filename Given\n" {error}
				incr cnt
				continue
			}
		} else {
			set firstword [file join $evv(CDPROGRAM_DIR) $firstword]
			set CDP_cmd [lreplace $CDP_cmd 0 0 $firstword]
		}
		if {[IsStandaloneProgWithNonCDPFormat [lindex $CDP_cmd 0]]} {
			set sloom_cmd $CDP_cmd
		} else {
			set sloom_cmd [linsert $CDP_cmd 1 "##"]
		}
		if [catch {open "|$sloom_cmd"} CDPidrun] {
			set line "$CDPidrun : CAN'T RUN PROCESS, Or (if output redirected) output in file.\n$line"
			.brunning.i.info insert end "$origline\n" {error}
			incr cnt
			continue
	   	} else {
			.brunning.t.ok config -state disabled -bg [option get . background {}]
	   		fileevent $CDPidrun readable "Display_Batch_Running_Info $rpd"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			set line "PROCESS FAILED"
			.brunning.i.info insert end "$origline\n" {error}
			incr cnt
			continue
		}
		UpdateWorkspaceAfterBatch $after_error $cnt
		.brunning.i.info yview moveto 1
		incr cnt
	}
	if [info exists batch_outfiles] {
		if [info exists files_destroyed] {
			foreach fnam $files_destroyed {
				set k [lsearch $batch_outfiles $fnam]
				if {$k >= 0} {
					set batch_outfiles [lreplace $batch_outfiles $k $k]
				}
			}
		}
		set last_outfile $batch_outfiles
		set batch_outfiles [ReverseList $batch_outfiles]
		foreach fnam $batch_outfiles {
			$wl insert 0 $fnam
			WkspCnt $fnam 1
			catch {unset rememd}
		}
	}
	if [info exists files_destroyed] {
		UpdateWorkspaceOnDeletedFiles
	}
	if {$program_messages} {
		.brunning.t.ok config -text "OK" -command "My_Release_to_Dialog .brunning ; destroy .brunning" -state normal -bg $evv(EMPH)
	}
}

#---------

proc UpdateWorkspaceAfterBatch {abort cnt} {
	global batch_newname done_bren wl wstk batch_outfiles evv

	foreach fnam [glob -nocomplain -- *] {
		set fnam [string tolower $fnam]
		set ftail [file tail $fnam]
		if [file isdirectory $fnam] {
			continue
		} elseif [IgnoreSoundloomxxxFilenames $fnam] {
			continue
		} elseif {[string match $evv(DFLT_OUTNAME)* $ftail] \
		|| [string match $evv(MACH_OUTFNAME)* $ftail] \
		|| [string match $evv(DFLT_TMPFNAME)* $ftail]} {
			set done_bren 0
			if {![LaterDeleted $cnt $fnam]} {
				BatchRename $fnam
				set fnam $batch_newname
			} else {
				continue
			}
		}
		if {([lsearch $batch_outfiles $fnam] < 0) && ([LstIndx $fnam $wl] < 0)} {
			if {$abort} {
				if [catch {file delete $fnam} zab] {
					set line "Cannot delete the file $fnam"
					.brunning.i.info insert end "$line\n" {error}
				}
			} else {
				set do_parse_report 1
				if {[DoParse $fnam $wl 0 0] <= 0} {
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
						-message "Spurious file $fnam created : Delete it ?"]
					if {$choice == "yes"} {
						if [catch {file delete $fnam} xx] {
							Inf "$xx\nCannot remove file '$fnam' : Ignoring it"
						} else {
							DummyHistory $fnam "DESTROYED"
						}
					}
				} 
				lappend batch_outfiles $fnam
			}
		}
	}
}

#-----------

proc UpdateWorkspaceOnDeletedFiles {} {
	global wl ww files_destroyed wksp_cnt total_wksp_cnt rememd

	foreach fnam $files_destroyed {
		set i [LstIndx $fnam $wl]
		if {$i >= 0} {
			lappend ilist $i
		}
	}
	if {[info exists ilist]} {
		set ilist [ReverseList $ilist]
		foreach i $ilist {
			set fnam [$wl get $i]
			$wl delete $i
			PurgeArray $fnam
			incr wksp_cnt -1
			incr total_wksp_cnt -1
		}
		catch {unset rememd}
		ForceVal $ww.1.a.endd.l.cnts.new $wksp_cnt
		ForceVal $ww.1.a.endd.l.cnts.all $total_wksp_cnt
#JAN22
		$ww.1.a.endd.l.cnts.new config -foreground black
		$ww.1.a.endd.l.cnts.all config -foreground black

		ReMarkWkspaceCount
	}
}

#-----------

proc BatchRename {fnam} {
	global batch_newname pr_bren done_bren evv

	set f .batchren

	if [Dlg_Create $f "RENAME BATCH OUTPUT FILE" "set pr_bren 1" -borderwidth $evv(SBDR)] {
		label $f.l1 -text ""
		label $f.l2 -text "PLEASE RENAME THE FILE: (WITH THE FILE EXTENSION)"
		button $f.b -text "OK" -command "set pr_bren 1" -highlightbackground [option get . background {}]
		frame $f.t -borderwidth $evv(BBDR)
		label $f.t.l -text "New Filename"
		entry $f.t.e -textvariable batch_newname  -width 64
		pack $f.t.l $f.t.e -side left
		pack $f.l1 $f.l2 $f.b $f.t -side top
	}
	wm resizable $f 1 1
	set ftail [file tail $fnam]

	$f.l1 config -text "$ftail is a reserved Sound Loom filename"
	set pr_bren 0
	set finished 0
	set batch_newname ""
	raise $f
	My_Grab 0 $f pr_bren $f.t.e
	while {!$finished} {
		tkwait variable pr_bren
		if {[string length $batch_newname] <= 0} {
			Inf "No name entered"
			continue
		}
		set ftail [file tail $batch_newname]
		if {[string match $evv(DFLT_OUTNAME)* $ftail] \
		|| [string match $evv(MACH_OUTFNAME)* $ftail] \
		|| [string match $evv(DFLT_TMPFNAME)* $ftail] \
		|| [IgnoreSoundloomxxxFilenames $ftail]} {
			Inf "This is still a reserved Sound Loom filename\n\nPlease Enter A New Name"
			continue
		}
		if [catch {file rename $fnam $batch_newname} zib] {
			Inf "Cannot rename the file to '$batch_newname'\n\n$zib"
			continue
		}
		set finished 1
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	set done_bren 1
}

#-----------

proc ConvertDisplayToBatchfile {} {
	global batch_file 
	set t .batching.3.t

	catch {unset batch_file}
	set imax [$t index end]
	set i 1
	set cnt 0
	while {$i < $imax} {
		catch {unset newline}
		set line [$t get $i.0 $i.end]
		set line [string trim $line]
		set line [split $line]
		set j 0
		foreach item $line {
			if {[string length $item] > 0} {
				if {$j == 0} {
					set newline $item
					set j 1
				} else {
					append newline " " $item
				}
			}
			incr j
		}
		if [info exists newline] {
			set newline [RegulariseDirectoryRepresentation_No_tolower $newline]
			lappend batch_file $newline
			incr cnt
		}
	 	incr i
	}
	return $cnt
}

#----------------

proc GetBatchfile {fl} {
	global pr_batchlist

	set i [$fl curselection]
	if {![info exists i] || ($i < 0)} {
		return
	}
	ForceVal .batching.1.e [$fl get $i]
	set pr_batchlist 1
}

#------ Display info returned by running-batchfile in the the program-running display

proc Display_Batch_Running_Info {rpd} {
	global CDPidrun rundisplay prg_dun prg_abortd program_messages after_error evv
	global bulk super_abort

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
		if [string match INFO:* $line] {
			set line [string range $line 6 end] 
			.brunning.i.info insert end "$line\n"
			set program_messages 1
		} elseif [string match WARNING:* $line] {
			set line [string range $line 9 end] 
			.brunning.i.info insert end "$line\n" {warning}
			set program_messages 1
		} elseif [string match ERROR:* $line] {
			set line [string range $line 7 end] 
			.brunning.i.info insert end "$line\n" {error}
			set after_error 1
			set prg_abortd 1
			set program_messages 1
			set prg_dun 0
			return
		} elseif [string match END:* $line] {
			set prg_dun 1
			return
		} else {
			.brunning.i.info insert end "$line\n"
			set program_messages 1
			return
		}
	}
	update idletasks
}

proc UpdateInfoMessage {line} {
	global maxusagelen usagecnt usage_message
	set thislen [string length $line]
	if {$thislen > $maxusagelen} {
		set maxusagelen $thislen
	}
	lappend usage_message $line
	incr usagecnt
}

proc BatchInfo {} {
	global maxusagelen usage_message usagecnt evv

	catch {unset usage_message}
	set maxusagelen 0
	set usagecnt 0
	set line ""
	UpdateInfoMessage $line
	set line "                                                               RUNNING BATCHFILES"
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "This facility enables command-line-style batchfile to be run, using the CDP command-line syntax."
	UpdateInfoMessage $line
	set line "Because it depends on you getting the command-line syntax right"
	UpdateInfoMessage $line
	set line "IT IS NOT QUITE AS ROBUST as the rest of the Sound Loom (!)"
	UpdateInfoMessage $line
	set line "(If you type in (or edit) your own batchfile lines, there is no error checking), so you are advised to..."
	UpdateInfoMessage $line
	set line "(a) Generate batchfile lines AUTOMATICALLY from the Parameters page,"
	UpdateInfoMessage $line
	set line "(b) Use BULK PROCESS, where the same process is to be run with the SAME PARAMETERS but on different sources."
	UpdateInfoMessage $line
	set line "(c) Build an INSTRUMENT, where several processes are to be run in sequence, and you are sure what you want."
	UpdateInfoMessage $line
	set line "       However, Instruments cannot be edited, so creating a batchfile leaves flexibilty for changing your mind later."
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "(a) Where the SAME process is to be run repeatedly but with some param(s) having A DIFFERENT VALUE at each pass,"
	UpdateInfoMessage $line
	set line "       you can use the VECTORED BATCHFILE operation, described below."
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "If you enter batchfile data by hand, or edit it, BE ABSOLUTELY SURE the command-line syntax is correct!!!"
	UpdateInfoMessage $line
	set line "    (On the batchfile page there is a SYNTAX button, which displays the syntax of any CDP command line process you specify)."
	UpdateInfoMessage $line
	set line "    NB The Sound Loom will not check your syntax here !!!!!"
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "                                              SAFEST ROUTE TO CREATING A BATCHFILE"
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "If you run a process on the CDP Process page, you can 'Save' the commandline of the process (with correct syntax!)"
	UpdateInfoMessage $line
	set line "using the panel on the right hand side."
	UpdateInfoMessage $line
	set line "To use the output of one process as input to the next, save the Process WITH the outfile name(s) with the '+Outname' button."
	UpdateInfoMessage $line
	set line "(You can only do this AFTER you have saved the output file, by giving it a name)."
	UpdateInfoMessage $line
	set line "If you now run others processes, you can 'Append' these to the same (named) batchfile."
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "                                                            EDITING A BATCHFILE"
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "You can use the global editing facilities (on the menu 'Batch' above the Workspace)"
	UpdateInfoMessage $line
	set line "to change the input or outputfilenames, or edit/replace datafiles, or (globally) change parameter values"
	UpdateInfoMessage $line
	set line "with less risk of creating bad syntax in your new file."
	UpdateInfoMessage $line
	set line "You can also edit your batchfile as a normal textfile (menu 'Files of Type' on the Workspace),"
	UpdateInfoMessage $line
	set line "or on the Run-Batchfile page, where you can use the 'Syntax' button to check your syntax."
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "'rem' 'echo' 'rm' 'rmsf' and comment lines (beginning with '#' or '@') can be handled,"
	UpdateInfoMessage $line
	set line "as can INDIRECTION (sending process output to a specified data file via '>' or '>>')."
	UpdateInfoMessage $line
	set line "However if Indirection is used..."
	UpdateInfoMessage $line
	set line "(a) It will generate an error message (which, IN THIS CASE, may be acknowledged and ignored)"
	UpdateInfoMessage $line
	set line "(b) The datafile generated by the indirection will not be listed on the workspace."
	UpdateInfoMessage $line
	set line "      (If sent to the Home directory, 'Update Data On All Workspace Files' will list it at foot of the workspace)."
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "** Other non-CDP processes may cause problems. **"
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "                                                WHAT HAPPENS DURING BATCHFILING"
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "(1) The process runs each successive line of the batchfile in turn."
	UpdateInfoMessage $line
	set line "(2) A successful process concludes by loading any output files onto the workspace, for further work."
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "                                                HOW CAN ERRORS OCCUR ?"
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "(1)  During a batchfile process, you will be prevented from deleting or verwriting pre-existing files on your system,"
	UpdateInfoMessage $line
	set line "            and will receive warning messages if your batchfile attempts to do this."
	UpdateInfoMessage $line
	set line "(2)  Should the syntax of any line be incorrect, that line will produce no output."
	UpdateInfoMessage $line
	set line "     Where that output was supposed to be the input to following lines, you will get further error messages."
	UpdateInfoMessage $line
	set line "(3)  Bad parameter values, or file-finding errors will also generate error-messages."
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "      ERROR messages will accumulate on the Batchfile screen."
	UpdateInfoMessage $line
	set line "      These may, in turn, generate TK/TCL error messages. For more information about how to proceed, see below."
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "                                                   SOME BATCHFILE PROBLEMS"
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "(1) In some circumstances, TK/TCL ERROR MESSAGES may occur."
	UpdateInfoMessage $line
	set line "      You must acknowledge these, by clicking 'OK' in (all) the dialog(s), to proceed."
	UpdateInfoMessage $line
	set line "(2) If you have too many syntax or data errors in the batchfile, you may stall the Sound Loom."
	UpdateInfoMessage $line
	set line "(3) Very long batchfiles may occasionally stall the Sound Loom."
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "                                                   IF THE SOUND LOOM STALLS"
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "If the Sound Loom hangs, kill the CDP process that is currently running, and kill the Sound Loom."
	UpdateInfoMessage $line
	set line "On restarting the Sound Loom, you may find some files from the aborted batchfile appear on the workspace."
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "                                                   TO CREATE A VECTORED BATCHFILE"
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "(1) Choose ONE of the files you want to work with, and set up the process you want to apply, going to the parameters page."
	UpdateInfoMessage $line
	set line "      On the parameters page, in the writehand panel labelled 'BATCHES', select 'Save'."
	UpdateInfoMessage $line
	set line "(2) Move to the the TABLE EDITOR 'Create' menu, (or the WORKSPACE 'Files Of Type' menu) and"
	UpdateInfoMessage $line
	set line "      generate a list of values for the parameter (the PARAMETER VECTOR). Let's suppose we use 6 values in the Vector."
	UpdateInfoMessage $line
	set line "(3) Now (on the Workspace) select ALL the files that the Batchfile will process and put them in the Chosen Files list."
	UpdateInfoMessage $line
	set line "      There are two different options........"
	UpdateInfoMessage $line
	set line "      (a) List 1 file FOR EACH of the different values listed in the Vector."
	UpdateInfoMessage $line
	set line "            so you will have 6 infiles with 6 different values for A PARTICULAR parameter"
	UpdateInfoMessage $line
	set line "            the 1st batch-action will processs file 1 with vector value 1."
	UpdateInfoMessage $line
	set line "            the 2nd batch-action will processs file 2 with vector value 2, and so on."
	UpdateInfoMessage $line
	set line "      (b) List JUST ONE file: in this case the 6 parameter values of the vector will be applied to the SAME file."
	UpdateInfoMessage $line
	set line "            to produce 6 separate outputs from the same input file."
	UpdateInfoMessage $line
	set line "(4) Go to the TABLE EDITOR and switch it to 'ManyFiles' mode."
	UpdateInfoMessage $line
	set line "(5) Select the Batchfile and the Vector file you just created (in that order)."
	UpdateInfoMessage $line
	set line "(6) From the 'Join' menu, choose 'Create A Vectored Batchfile'"
	UpdateInfoMessage $line
	set line "(7) Using the information displayed for you in the Parameter box which appears...."
	UpdateInfoMessage $line
	set line "      note the column-numbers in which the inputfile, the outputfile, and the parameter(s) you have vectored, occur."
	UpdateInfoMessage $line
	set line "      and enter these column numbers as the parameters."
	UpdateInfoMessage $line
	set line "(8) Save the resulting table AS A BATCHFILE, using the 'Batch' button on the right."
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
	set line "(MOST OF THIS INFORMATION ON VECTORED BATCHFILES CAN ALSO BE ACCESSED FROM THE TABLE EDITOR, 'Join' MENU)"
	UpdateInfoMessage $line
	set line ""
	UpdateInfoMessage $line
}

#----------- Command line info

proc BatchSyntax {ll instr} {
	global released gate_version modify_version evv

	switch -- $instr {

		"BLUR" {

			$ll delete 0 end
			set line "BLUR AVRG     infile outfile N"
			$ll insert end $line
			set line "BLUR BLUR     infile outfile blurring"
			$ll insert end $line
			set line "BLUR CHORUS 1   infile outfile aspread        "
			$ll insert end $line
			set line "BLUR CHORUS 2-4 infile outfile         fspread"
			$ll insert end $line
			set line "BLUR CHORUS 5-7 infile outfile aspread fspread"
			$ll insert end $line
			set line "(1) Randomise partial amplitudes."
			$ll insert end $line
			set line "(2) Randomise partial frequencies."
			$ll insert end $line
			set line "(3) Randomise partial frequencies upwards only."
			$ll insert end $line
			set line "(4) Randomise partial frequencies downwards only."
			$ll insert end $line
			set line "(5) Randomise partial amplitudes AND frequencies."
			$ll insert end $line
			set line "(6) Randomise partial amplitudes, and frequencies upwards only."
			$ll insert end $line
			set line "(7) Randomise partial amplitudes, and frequencies downwards only."
			$ll insert end $line
			set line "BLUR DRUNK    infile outfile range starttime duration \[-z\]"
			$ll insert end $line
			set line "BLUR NOISE    infile outfile noise"
			$ll insert end $line
			set line "BLUR SHUFFLE  infile outfile domain-image grpsize"
			$ll insert end $line
			set line "BLUR SCATTER  infile outfile keep \[-bblocksize\] \[-r\] \[-n\] "
			$ll insert end $line
			set line "BLUR SPREAD   infile outfile -fN|-pN \[-i\] \[-sspread\]"
			$ll insert end $line
			set line "BLUR SUPPRESS infile outfile N"
			$ll insert end $line
			set line "BLUR WEAVE    infile outfile weavfile"
			$ll insert end $line
			set line "GLISTEN GLISTEN    infile outfile grpdiv windur \[-ppshift\] \[-ddurrand\] \[-vdivrand\]"
			$ll insert end $line
			set line "SPECNU RAND    infile outfile \[-ttimescale\] \[-ggroupcnt\]"
			$ll insert end $line
			set line "SPECNU SQUEEZE    infile outfile centrefrq sqeeze"
			$ll insert end $line
			set line "SPECNU EXTEND    infile outfile time dur stretch \[-wwindowgroup\] \[-s\] \[-e\] "
			$ll insert end $line
			if {[info exists released(suppress)]} {
				set line "SUPPRESS PARTIALS inanalfil outanalfil timeslots lofrq hifrq chancnt"
				$ll insert end $line
			}
			if {[info exists released(caltrain)]} {
				set line "CALTRAIN CALTRAIN inanalfil outanalfil blurtime abovefrq \[-lbasscut\]"
				$ll insert end $line
			}
		}
		"BRASSAGE" {

			$ll delete 0 end
			set line "MODIFY BRASSAGE 1      infile outfile pitchshift"
			$ll insert end $line
			set line "MODIFY BRASSAGE 2      infile outfile velocity"
			$ll insert end $line
			set line "MODIFY BRASSAGE 3      infile outfile density pitch amp \[-rrange\]"
			$ll insert end $line
			set line "MODIFY BRASSAGE 4      infile outfile grainsize \[-rrange\]"
			$ll insert end $line
			set line "MODIFY BRASSAGE 5      infile outfile density \[-d\]"
			$ll insert end $line
			set line "MODIFY BRASSAGE 6      infile outfile velocity density grainsize pitchshft amp space bsplice esplice"
			$ll insert end $line
	        set line "          \[-rrange\] \[-jjitter\] \[-loutlength\] \[-cchannel\] \[-d\] \[-x\] \[-n\]"
			$ll insert end $line
			set line "MODIFY BRASSAGE 7      infile outfile velocity density hvelocity hdensity grainsize pitchshift"
			$ll insert end $line
			set line "          amp space bsplice esplice hgrainsize hpitchshift hamp hspace hbsplice hesplice"
			$ll insert end $line
	        set line "          \[-rrange\] \[-jjitter\] \[-loutlength\] \[-cchannel\] \[-d\] \[-x\] \[-n\]"
			$ll insert end $line
			set line "(1) pitchshift"
			$ll insert end $line
			set line "(2) timestretch"
			$ll insert end $line
			set line "(3) reverb"
			$ll insert end $line
			set line "(4) scramble"
			$ll insert end $line
			set line "(5) granulate"
			$ll insert end $line
			set line "(6) brassage"
			$ll insert end $line
			set line "(7) full monty"
			$ll insert end $line
			set line "MODIFY SAUSAGE         infile \[infile2 ...\] outfile velocity density"
			$ll insert end $line
			set line "          hvelocity hdensity grainsize  pitchshift  amp  space  bsplice  esplice"
			$ll insert end $line
			set line "          hgrainsize hpitchshift hamp hspace hbsplice hesplice"
			$ll insert end $line
	        set line "          \[-rrange\] \[-jjitter\] \[-loutlength\] \[-cchannel\] \[-d\] \[-x\] \[-n\]"
			$ll insert end $line
		}
		"CHANNELS" {

			$ll delete 0 end
			set line "HOUSEKEEP CHANS 1      infile channo"
			$ll insert end $line
			set line "HOUSEKEEP CHANS 2      infile "
			$ll insert end $line
			set line "HOUSEKEEP CHANS 3      infile outfile channo"
			$ll insert end $line
			set line "HOUSEKEEP CHANS 4      infile outfile \[-p\]"
			$ll insert end $line
			set line "HOUSEKEEP CHANS 5      infile outfile"
			$ll insert end $line
			set line "(1) extract a channel : channo is channel to extract : outfile named inname_c1 etc."
			$ll insert end $line
			set line "(2) extract all channels : outfiles are named inname_c1 etc."
			$ll insert end $line
			set line "(3) zero one channel : mono file goes to 1 side of stereo : stereo file has one channel zeroed out."
			$ll insert end $line
			set line "(4) stereo to mono : -p inverts phase of 2nd channel before mixing." 
			$ll insert end $line
			set line "(5) mono to stereo : creates 2-channel equivalent of mono infile." 
			$ll insert end $line
			set line "SUBMIX INTERLEAVE     sndfile1 sndfile2 \[sndfile3 sndfile4\] outfile"
			$ll insert end $line
			if {[info exists released(gate)]} {
				if {$gate_version < 6} {
					set line "GATE GATE     infile outfile gatelevel(dB)"
				} else {
					set line "GATE GATE  1-2 infile outfile gatelevel(dB)"
				}
				$ll insert end $line
			}
			if {[info exists released(phase)]} {
				set line "PHASE PHASE  1   infile  outfile"
				$ll insert end $line
				set line "PHASE PHASE  2   stereoinfile outfile  -ttransfer"
				$ll insert end $line
			}
			if {[info exists released(chanphase)]} {
				set line "CHANPHASE CHANPHASE  1   infile outfile  channel"
				$ll insert end $line
			}
			if {[info exists released(mton)]} {
				set line "MTON MTON     infile outfile outchans"
				$ll insert end $line
			}
			if {[info exists released(repair)]} {
				set line "REPAIR REPAIR infiles generic-outfile-name channels"
				$ll insert end $line
			}
		}

		"COMBINE" {

			$ll delete 0 end
			set line "COMBINE DIFF        infile infile2 outfile \[-ccrossover\] \[-a\]"
			$ll insert end $line
			set line "COMBINE INTERLEAVE  infile infile2 \[infile3 ....\] outfile leafsize"
			$ll insert end $line
			set line "COMBINE MAKE        pitchfile formantfile outfile"
			$ll insert end $line
			set line "COMBINE MAKE2       pitchfile formantfile envfile outfile"
			$ll insert end $line
			set line "COMBINE MAX         infile infile2 \[infile3 ....\] outfile"
			$ll insert end $line
			set line "COMBINE MEAN 1-8    infile infile2 outfile \[-llofrq\] \[-hhifrq\] \[-cchans\] \[-z\]"
			$ll insert end $line
			set line "(1) mean channel amp of 2 files :  mean of two pitches"
			$ll insert end $line
			set line "(2) mean channel amp of 2 files :  mean of two frqs"
			$ll insert end $line
			set line "(3) channel amp from file1      :  mean of two pitches"
			$ll insert end $line
			set line "(4) channel amp from file1      :  mean of two frqs"
			$ll insert end $line
			set line "(5) channel amp from file2      :  mean of two pitches"
			$ll insert end $line
			set line "(6) channel amp from file2      :  mean of two frqs"
			$ll insert end $line
			set line "(7) max channel amp of 2 files  :  mean of two pitches"
			$ll insert end $line
			set line "(8) max channel amp of 2 files  :  mean of two frqs"
			$ll insert end $line
			set line "COMBINE SUM         infile infile2 outfile \[-ccrossover\]"
			$ll insert end $line
			set line "COMBINE CROSS       infile infile2 outfile \[-iinterp\]"
			$ll insert end $line
			set line "SPECSPHINX SPECSPHINX 1 infile infile2 outfile \[-aampbalance\] \[-ffrqbalance\]"
			$ll insert end $line
			set line "SPECSPHINX SPECSPHINX 2 infile infile2 outfile \[-bbias\] \[-ggain\]"
			$ll insert end $line
			set line "SPECSPHINX SPECSPHINX 3 infile infile2 outfile \[-ddepth\] \[-ggain\] \[-ccutoff\] \[-e\]"
			$ll insert end $line
			set line "SPECTWIN SPECTWIN 1-4 infile infile2 outfile \[-ffrqint\] \[-eenvint\] \[-ddupl\] \[-sstep\] \[-rrolloff\]"
			$ll insert end $line
		}
		"DISTORT" {

			$ll delete 0 end
			set line "DISTORT AVERAGE      infile outfile cyclecnt \[-mmaxwavelen\] \[-sskipcycles\]"
			$ll insert end $line
			set line "DISTORT CYCLECNT     infile"
			$ll insert end $line
			set line "DISTORT DELETE 1-3   infile outfile cyclecnt \[-sskipcycles\]"
			$ll insert end $line
	 		set line "(1) 1 in cyclecnt wavecycles retained"
			$ll insert end $line
			set line "(2) Strongest 1 in cyclecnt wavecycles retained"
			$ll insert end $line
			set line "(3) Weakest 1 in cyclecnt wavecycles deleted"
			$ll insert end $line
			set line "DISTORT DIVIDE       infile outfile N \[-i\]"
			$ll insert end $line
			set line "DISTORT ENVEL 1-2    infile outfile         cyclecnt \[-ttroughing\] \[-eexponent\]"
			$ll insert end $line
			set line "DISTORT ENVEL 3      infile outfile         cyclecnt troughing     \[-eexponent\]"
			$ll insert end $line
			set line "DISTORT ENVEL 4      infile outfile envfile cyclecnt "
			$ll insert end $line
			set line "(1) rising envelope."
			$ll insert end $line
			set line "(2) falling envelope."
			$ll insert end $line
			set line "(3) troughed envelope."
			$ll insert end $line
			set line "(4) user defined envelope."
			$ll insert end $line
			set line "DISTORT FILTER 1-2   infile outfile freq        \[-sskipcycles\]"
			$ll insert end $line
			set line "DISTORT FILTER 3     infile outfile freq1 freq2 \[-sskipcycles\]"
			$ll insert end $line
			set line "(1) omit cycles below FREQ"
			$ll insert end $line
			set line "(2) omit cycles above FREQ"
			$ll insert end $line
			set line "(3) omit cycles below FREQ1 and above FREQ2"
			$ll insert end $line
			set line "DISTORT FRACTAL      infile outfile scaling loudness \[-ppre_attenuation\]"
			$ll insert end $line
			set line "DISTORT HARMONIC     infile outfile harmonics-file \[-ppre_attenuation\]"
			$ll insert end $line
			set line "DISTORT INTERPOLATE  infile outfile multiplier \[-sskipcycles\]"
			$ll insert end $line
			set line "DISTORT INTERACT 1-2 infile1 infile2 outfile"
			$ll insert end $line
			set line "(1) interleave wavecycles from the two infiles."
			$ll insert end $line
			set line "(2) impose wavecycle-lengths of 1st file on wavecycles of 2nd"
			$ll insert end $line
			set line "DISTORT MULTIPLY     infile outfile N \[-s\]"
			$ll insert end $line
			set line "DISTORT OMIT         infile outfile A B"
			$ll insert end $line
			set line "DISTORT OVERLOAD 1   infile outfile gate depth"
			$ll insert end $line
			set line "DISTORT OVERLOAD 2   infile outfile gate depth freq"
			$ll insert end $line
			set line "DISTORT PITCH        infile outfile octvary \[-ccyclelen\] \[-sskipcycles\]"
			$ll insert end $line
			set line "DISTORT REFORM 1-7   infile outfile "
			$ll insert end $line
			set line "DISTORT REFORM 8     infile outfile  exaggeration"
			$ll insert end $line
			set line "(1) Convert to fixed level square_wave"
			$ll insert end $line
			set line "(2) Convert to square wave"
			$ll insert end $line
			set line "(3) Convert to fixed level triangular wave"
			$ll insert end $line
			set line "(4) Convert to triangular wave"
			$ll insert end $line
			set line "(5) Convert to inverted half_cycles"
			$ll insert end $line
			set line "(6) Convert to click stream"
			$ll insert end $line
			set line "(7) Convert to sinusoid"
			$ll insert end $line
			set line "(8) Exaggerate waveform contour"
			$ll insert end $line
			set line "DISTORT REPEAT       infile outfile multiplier \[-ccyleccnt\] \[-sskipcycles\]"
			$ll insert end $line
			set line "DISTORT REVERSE      infile outfile cyclecnt"
			$ll insert end $line
			set line "DISTORT SHUFFLE      infile outfile domain-image \[-ccylecnt\] \[-sskipcycles\]"
			$ll insert end $line
			set line "DISTORT REPLACE      infile outfile cyclecnt \[-sskipcycles\]"
			$ll insert end $line
			set line "DISTORT TELESCOPE    infile outfile cyclecnt \[-sskipcycles\] \[-a\]"
			$ll insert end $line
			set line "DISTORT REPEAT2       infile outfile multiplier \[-ccyleccnt\] \[-sskipcycles\]"
			$ll insert end $line
			if {[info exists released(hover)]} {
				set line "HOVER HOVER       infile outfile frq location frqrand locrand splice dur"
				$ll insert end $line
			}
			if {[info exists released(hover2)]} {
				set line "HOVER2 HOVER2     infile outfile frq location frqrand locrand dur \[-s\] \[-n\]"
				$ll insert end $line
			}
			if {[info exists released(distshift)]} {
				set line "DISTSHIFT DISTSHIFT 1 infile outfile groupcnt shift"
				$ll insert end $line
				set line "DISTSHIFT DISTSHIFT 2 infile outfile groupcnt"
				$ll insert end $line
			}
			if {[info exists released(clip)]} {
				set line "CLIP CLIP 1 infile outfile cliplevel"
				$ll insert end $line
				set line "CLIP CLIP 2 infile outfile waveset-fraction"
				$ll insert end $line
			}
			if {[info exists released(quirk)]} {
				set line "QUIRK QUIRK 1-2 infile outfile powerfactor"
				$ll insert end $line
			}
			if {[info exists released(scramble)]} {
				set line "SCRAMBLE SCRAMBLE 1-2  infile outfile dur seed \[-ccnt\] \[-ttrans\] \[-aatten\]"
				$ll insert end $line
				set line "SCRAMBLE SCRAMBLE 3-4  infile outfile \[-ccnt\] \[-ttrans\] \[-aatten\]"
				$ll insert end $line
				set line "SCRAMBLE SCRAMBLE 5-8  infile outfile cutsfile \[-ccnt\] \[-ttrans\] \[-aatten\]"
				$ll insert end $line
				set line "SCRAMBLE SCRAMBLE 9-10 infile outfile \[-ccnt\] \[-ttrans\] \[-aatten\]"
				$ll insert end $line
				set line "SCRAMBLE SCRAMBLE 11-14 infile outfile cutsfile \[-ccnt\] \[-ttrans\] \[-aatten\]"
				$ll insert end $line
			}
			if {[info exists released(sorter)]} {
				set line "SORTER SORTER 1-4 inf outf esiz \[-ssmooth\] \[-oopch\] \[-ppch\] \[-mmeta\] \[-f\]"
				$ll insert end $line
				set line "SORTER SORTER 5   inf outf esiz seed \[-ssmooth\] \[-oopch\] \[-ppch\] \[-mmeta\] \[-f\]"
				$ll insert end $line
			}
			if {[info exists released(distmark)]} {
				set line "DISTMARK DISTMARK infile outfile timeslist unitlen(mS) \[-ststretch\] \[-rrand\] \[-f\] \[-t\]"
				$ll insert end $line
			}
			if {[info exists released(distrep)]} {
				set line "DISTREP DISTREP infile outfile repeats cyclecnt \[-kskipcycles\] \[-ssplicelen\]"
				$ll insert end $line
			}
		}
		"VOICEBOX" {
			if {[info exists released(specfnu)]} {
				set line "SPECFNU SPECFNU 1 inanalfil outanalfil narrow   \[-ggain\] \[-ooff\] \[-t\] \[-f\] \[-s\] \[-x|-k\] \[-r\]"
				$ll insert end $line
				set line "                            (Narrows formants)"
				$ll insert end $line
				set line "SPECFNU SPECFNU 2 inanal outanal squeeze centre \[-ggain\] \[-t\] \[-f\] \[-s\] \[-x|-k\] \[-r\]"
				$ll insert end $line
				set line "                            (Squeezes spectrum around formant)"
				$ll insert end $line
				set line "SPECFNU SPECFNU 3 inanal outanal vibrate        \[-ggain\] \[-s\] \[-x|-k\] \[-r\]"
				$ll insert end $line
				set line "                            (Inverts formants)"
				$ll insert end $line
				set line "SPECFNU SPECFNU 4 inanal outanal rspeed    \[-ggain\] \[-s\] \[-x|-k\] \[-r\]"
				$ll insert end $line
				set line "                            (Rotates Formants)"
				$ll insert end $line
				set line "SPECFNU SPECFNU 5 inanal outanal                \[-ggain\] \[-f\]"
				$ll insert end $line
				set line "                            (Spectral Negative)"
				$ll insert end $line
				set line "SPECFNU SPECFNU 6 inanalfile outanalfile formantlist \[-ggain\] \[-s\] \[-x\]"
				$ll insert end $line
				set line "                            (Supresses formants)"
				$ll insert end $line
				set line "SPECFNU SPECFNU 7 inanalfile outfiltfile datafile filtcnt \[-bbelow\] \[-k|-i\] \[-f\] \[-s\]"
				$ll insert end $line
				set line "                            (Generates varibank filter from formants)"
				$ll insert end $line
				set line "SPECFNU SPECFNU 8 inanal outanal mov1 mov2 mov2 mov4 \[-ggain\] \[-t\] \[-s\] \[-x|-k\] \[-r\]"
				$ll insert end $line
				set line "                            (Moves formants by)"
				$ll insert end $line
				set line "SPECFNU SPECFNU 9 inanal outanal frq1 frq2 frq2 frq4 \[-ggain\] \[-t\] \[-s\] \[-n\] \[-x|-k\] \[-r\]"
				$ll insert end $line
				set line "                            (Moves formants to)"
				$ll insert end $line
				set line "SPECFNU SPECFNU 10 inanal outanal arprate    \[-ggain\] \[-s\] \[-x\] \[-r\] \[-d|-c\]"
				$ll insert end $line
				set line "                            (Arpeggiates spectrum, under formants)"
				$ll insert end $line
				set line "SPECFNU SPECFNU 11 inanal outanal OCTSHIFT   \[-ggain\] \[-parprate\] \[-llocut\] \[-hhicut\]"
				$ll insert end $line
				set line "                             \[-s\] \[-x\] \[-r\] \[-d|-c\] \[-f\]"
				$ll insert end $line
				set line "                            (Octave shifts spectrum, under formants)"
				$ll insert end $line
				set line "SPECFNU SPECFNU 12 inanal outanal TRANSPOS   \[-ggain\] \[-parprate\] \[-llocut\] \[-hhicut\]"
				$ll insert end $line
				set line "                             \[-s\] \[-x\] \[-r\] \[-d|-c\] \[-f\]"
				$ll insert end $line
				set line "                            (Transposes spectrum, under formants)"
				$ll insert end $line
				set line "SPECFNU SPECFNU 13 inanal outanal FRQSHIFT   \[-ggain\] \[-parprate\] \[-llocut\] \[-hhicut\]"
				$ll insert end $line
				set line "                             \[-s\] \[-x\] \[-r\] \[-d|-c\] \[-f\]"
				$ll insert end $line
				set line "                            (Frequency shifts spectrum, under formants)"
				$ll insert end $line
				set line "SPECFNU SPECFNU 14 inanal outanal RESPACE    \[-ggain\] \[-parprate\] \[-llocut\] \[-hhicut\]"
				$ll insert end $line
				set line "                             \[-s\] \[-x\] \[-r\] \[-d|-c\] \[-f\]"
				$ll insert end $line
				set line "                            (Respaces formants)"
				$ll insert end $line
				set line "SPECFNU SPECFNU 15 inanal outanal map about  \[-ggain\] \[-parprate\] \[-llocut\] \[-hhicut\] \[-blopch\] \[-thipch\]"
				$ll insert end $line
				set line "                             \[-s\] \[-x\] \[-r\] \[-d|-c\]"
				$ll insert end $line
				set line "                            (Inverts pitchline, under formants)"
				$ll insert end $line
				set line "SPECFNU SPECFNU 16 inanal outanal about rang \[-ggain\] \[-parprate\] \[-llocut\] \[-hhicut\] \[-blopch\] \[-thipch\]"
				$ll insert end $line
				set line "                             \[-T\] \[-F\] \[-M\] \[-A\] \[-B\] \[-s\] \[-x\] \[-r\] \[-d|-c\]"
				$ll insert end $line
				set line "                            (Exaggerates or smooths pitchline, under formants)"
				$ll insert end $line
				set line "SPECFNU SPECFNU 17 inanal outanal datafile   \[-ggain\] \[-parprate\] \[-llocut\] \[-hhicut\]"
				$ll insert end $line
				set line "                             \[-blopch\] \[-thipch\] \[-s\] \[-x\] \[-r\] \[-d|-c\] \[-o\] \[-n\]"
				$ll insert end $line
				set line "                            (Quantises pitch, under formants)"
				$ll insert end $line
				set line "SPECFNU SPECFNU 18 inanal outanal datafile range slew \[-ggain\] \[-parprate\] \[-llocut\] \[-hhicut\]"
				$ll insert end $line
				set line "                             \[-blopch\] \[-thipch\] \[-s\] \[-x\] \[-r\] \[-d|-c\] \[-o\] \[-n\] \[-k\]\]"
				$ll insert end $line
				set line "                            (Randomises pitch, under formants)"
				$ll insert end $line
				set line "SPECFNU SPECFNU 19 inanal outanal RAND \[-ggain\] \[-parprate\] \[-llocut\] \[-hhicut\] \[-s\] \[-x\] \[-r\] \[-d|-c\]"
				$ll insert end $line
				set line "                            (Randomises spectrum, under formants)"
				$ll insert end $line
				set line "SPECFNU SPECFNU 20 inanalfile outpseudosndfile  \[-s\]"
				$ll insert end $line
				set line "                            (Generates \"soundfile\" display of spectral envelopes)"
				$ll insert end $line
				set line "SPECFNU SPECFNU 21 inanalfile outtextfile \[-s\]"
				$ll insert end $line
				set line "                            (Lists frqs of peaks and troughs in spectrum)"
				$ll insert end $line
				set line "SPECFNU SPECFNU 22 inanal outtextfile \[-ssyldur\] \[-ppktrof\] \[-P|-B\]"
				$ll insert end $line
				set line "                            (Lists approx times of troughs between syllables)"
				$ll insert end $line
				set line "SPECFNU SPECFNU 23 inanalfile outanalfile hffile SINING \[-again\] \[-bamp1\] \[-camp2\] \[-damp3\] \[-eamp4\]"
				$ll insert end $line
				set line "                             \[-nqdep1\] \[-oqdep2\] \[-pdep3\] \[-qqdep4\] \[-s\] \[-f\] \[-r\] \[-S\]"
				$ll insert end $line
				set line "                            (Converts format frqs to sine tones)"
				$ll insert end $line
			}
		}
		"ENVEL" {

			$ll delete 0 end
			set line "ENVEL ATTACK 1    infile outfile gate gain onset decay \[-tenvtype\]"
			$ll insert end $line
			set line "ENVEL ATTACK 2-3  infile outfile time gain onset decay \[-tenvtype\]"
			$ll insert end $line
			set line "ENVEL ATTACK 4    infile outfile      gain onset decay \[-tenvtype\]"
			$ll insert end $line
			set line "(1) Set attack point where snd level first exceeds gate-level."
			$ll insert end $line
			set line "(2) attack point at max level around your approx-time (+- a few MS)"
			$ll insert end $line
			set line "(3) attack point at your exact-time."
			$ll insert end $line
			set line "(4) attack point at maxlevel in sndfile."
			$ll insert end $line
			set line "ENVEL CREATE 1 envfile createfile  wsize"
			$ll insert end $line
			set line "ENVEL CREATE 2 brkfile createfile"
			$ll insert end $line
			set line "(1) creates a BINARY envelope file:"
			$ll insert end $line
			set line "(2) creates a (TEXT) BRKPNT file:   File starts at time you specify."
			$ll insert end $line
			set line "ENVEL DOVETAIL 1  infile outfile infadedur outfadedur intype outtype \[-ttimes\]"
			$ll insert end $line
			set line "ENVEL DOVETAIL 2  infile outfile infadedur outfadedur                \[-ttimes\]"
			$ll insert end $line
			set line "In mode 2, envelope slopes are doubly exponential."
			$ll insert end $line
			set line "ENVEL CURTAIL 1   sndfile outfile fadestart fadeend  envtype  \[-ttimes\]"
			$ll insert end $line
			set line "ENVEL CURTAIL 2   sndfile outfile fadestart fade-dur envtype  \[-ttimes\]"
			$ll insert end $line
			set line "ENVEL CURTAIL 3   sndfile outfile fadestart          envtype  \[-ttimes\]"
			$ll insert end $line
			set line "ENVEL CURTAIL 4   sndfile outfile fadestart fadeend           \[-ttimes\]"
			$ll insert end $line
			set line "ENVEL CURTAIL 5   sndfile outfile fadestart fade-dur          \[-ttimes\]"
			$ll insert end $line
			set line "ENVEL CURTAIL 6   sndfile outfile fadestart                   \[-ttimes\]"
			$ll insert end $line
			set line "Modes 4-6 are doubly exponential."
			$ll insert end $line
			set line "(times = 1) takes param values in SECONDS: (default)"
			$ll insert end $line
			set line "(times = 2) takes param values in SAMPLES:"
			$ll insert end $line
			set line "(times = 3) takes param values in GROUPED_SAMPLES:"
			$ll insert end $line
			set line "ENVEL EXTRACT 1   infile outenvfile  wsize"
			$ll insert end $line
			set line "ENVEL EXTRACT 2   infile outbrkfile  wsize  \[-ddatareduce\]"
			$ll insert end $line
			set line "(1) extracts a binary envelope file:"
			$ll insert end $line
			set line "(2) extracts a (text) brkpnt file."
			$ll insert end $line
			set line "ENVEL IMPOSE 1    input_sndfile imposed-sndfile    outsndfile    wsize"
			$ll insert end $line
			set line "ENVEL IMPOSE 2    input_sndfile imposed-envfile    outsndfile"
			$ll insert end $line
			set line "ENVEL IMPOSE 3    input_sndfile imposed-brkfile    outsndfile"
			$ll insert end $line
			set line "ENVEL IMPOSE 4    input_sndfile imposed-brkfile-dB outsndfile"
			$ll insert end $line
			set line "(1) imposes an envelope extracted from another sndfile."
			$ll insert end $line
			set line "(2) imposes an envelope from a binary envelope file."
			$ll insert end $line
			set line "(3) imposes an envelope from a (text) brkpnt file: val range (0 - 1)."
			$ll insert end $line
			set line "(4) imposes an envelope from a (text) brkpnt file with dB vals (-96 to 0)."
			$ll insert end $line
			set line "ENVEL SCALED input_sndfile imposed-brkfile  outsndfile"
			$ll insert end $line
			set line "ENVEL REPLACE 1   input_sndfile replacing-sndfile    outsndfile wsize"
			$ll insert end $line
			set line "ENVEL REPLACE 2   input_sndfile replacing-envfile    outsndfile"
			$ll insert end $line
			set line "ENVEL REPLACE 3   input_sndfile replacing-brkfile    outsndfile"
			$ll insert end $line
			set line "ENVEL REPLACE 4   input_sndfile replacing-brkfile-dB outsndfile"
			$ll insert end $line
			set line "(1) replaces envelope with new one extracted from another sndfile."
			$ll insert end $line
			set line "(2) replaces envelope with new one from a binary envelope file."
			$ll insert end $line
			set line "(3) replaces envelope with new one from (text) brkpnt file: valrange 0-1."
			$ll insert end $line
			set line "(4) replaces envelope with new one from (text) brkpnt file in dB (-96 to 0)."
			$ll insert end $line
			set line "ENVEL SWELL       infile outfile peaktime peaktype"
			$ll insert end $line
	    	set line "ENVEL PLUCK       infile outfile startsamp wavelen \[-aatkcycles\] \[-ddecayrate\]"
			$ll insert end $line
			set line "ENVEL TREMOLO 1-2 infile outfile frq depth gain"
			$ll insert end $line
			set line "(1) Interpolate linearly between frqs in any frq brktable (default)."
			$ll insert end $line
			set line "(2) Interpolate logarithmically (like pitch). (Care with zero frqs)."
			$ll insert end $line
			set line "TREMOLO TREMOLO 1-2 infile outfile frq depth gain squeeze"
			$ll insert end $line
			set line "(1) Interpolate linearly between frqs in any frq brktable (default)."
			$ll insert end $line
			set line "(2) Interpolate logarithmically (like pitch). (Care with zero frqs)."
			$ll insert end $line
			set line "ENVEL REPLOT 1-12   brkfile outbrkfile          wsize various_params \[-dreduce\]"
			$ll insert end $line
			set line "ENVEL REPLOT 13     brkfile outbrkfile rampfile wsize various_params \[-dreduce\]"
			$ll insert end $line
			set line "ENVEL REPLOT 14-15  brkfile outbrkfile          wsize various_params \[-dreduce\]"
			$ll insert end $line
			set line "ENVEL RESHAPE 1-12  envfile outenvfile          various_params"
			$ll insert end $line
			set line "ENVEL RESHAPE 13    envfile outenvfile rampfile various_params"
			$ll insert end $line
			set line "ENVEL RESHAPE 14-15 envfile outenvfile          various_params"
			$ll insert end $line
			set line "ENVEL WARP 1-12     sndfile outsndfile          wsize various_params"
			$ll insert end $line
			set line "ENVEL WARP 13       sndfile outsndfile rampfile wsize various_params"
			$ll insert end $line
			set line "ENVEL WARP 14-15    sndfile outsndfile          wsize various_params"
			$ll insert end $line
			set line "(1) normalise"  
			$ll insert end $line
			set line "(2) reverse"
			$ll insert end $line
			set line "(3) exaggerate"
			$ll insert end $line
			set line "(4) attenuate"
			$ll insert end $line
			set line "(5) lift"  
			$ll insert end $line
			set line "(6) timestretch"
			$ll insert end $line
			set line "(7) flatten"
			$ll insert end $line
			set line "(8) gate"
			$ll insert end $line
			set line "(9)  invert"  
			$ll insert end $line
			set line "(10) limit"
			$ll insert end $line
			set line "(11) corrugate"
			$ll insert end $line
			set line "(12) expand "
			$ll insert end $line
			set line "(13) trigger"  
			$ll insert end $line
			set line "(14) ceiling"
			$ll insert end $line
			set line "(15) ducked"
			$ll insert end $line
			set line "ENVEL BRKTOENV    inbrkfile outenvfile  wsize"
			$ll insert end $line
			set line "ENVEL ENVTOBRK    inenvfile outbrkfile  \[-ddatareduce\]"
			$ll insert end $line
			set line "ENVEL DBTOENV     db_brkfile outenvfile  wsize"
			$ll insert end $line
			set line "ENVEL ENVTODB     inenvfile outbrkfile  \[-ddatareduce\]"
			$ll insert end $line
			set line "ENVEL DBTOGAIN    db_brkfile outbrkfile"
			$ll insert end $line
			set line "ENVEL GAINTODB    brkfile out_db_brkfile"
			$ll insert end $line
			set line "PEAKFIND PEAKFIND insndfile out_timelist windowsize \[-tthreshold\]"
			$ll insert end $line
			set line "REFOCUS REFOCUS 1-5 outname dur bandcnt focratio tstep trand \[-ooffset\] \[-eend\] \[-sseed\]"
			$ll insert end $line
			if {[info exists released(flatten)]} {
				set line "FLATTEN FLATTEN inf outf segmentsize shoulder \[-ttail\]"
				$ll insert end $line
			}
		}
		"EXTEND" {

			$ll delete 0 end
			set line "EXTEND DRUNK 1     infil outfil outdur locus ambitus step clock \[-ssplicelen\] \[-cclokrand\] \[-ooverlap\] \[-rseed\]"
			$ll insert end $line
			set line "EXTEND DRUNK 2     infil outfil outdur locus ambitus step clock mindrnk maxdrnk \[-ssplicelen\] \[-cclokrand\] \[-ooverlap\] \[-rseed\] \[-llosober\] \[-hhisober\]"
			$ll insert end $line
			set line "EXTEND ITERATE 1   infil outfil outduration \[-ddelay\] \[-rrand\] \[-ppshift\] \[-aampcut\] \[-ffade\] \[-ggain\] \[-sseed\]"
			$ll insert end $line
			set line "EXTEND ITERATE 2   infil outfil repetitions \[-ddelay\] \[-rrand\] \[-ppshift\] \[-aampcut\] \[-ffade\] \[-ggain\] \[-sseed\]"
			$ll insert end $line
			set line "EXTEND LOOP 1      infil outfil     start len    step  \[-wsplen\] \[-sscat\] \[-b\]"
			$ll insert end $line
			set line "EXTEND LOOP 2      infil outfil dur start len \[-lstep\] \[-wsplen\] \[-sscat\] \[-b\]"
			$ll insert end $line
			set line "EXTEND LOOP 3      infil outfil cnt start len \[-lstep\] \[-wsplen\] \[-sscat\] \[-b\]"
			$ll insert end $line
			set line "(1) Loop advances in soundfile until soundfile is exhausted."
			$ll insert end $line
			set line "(2) Specify outfile duration (shortened if looping reaches end of infile)."
			$ll insert end $line
			set line "(3) Specify number of loop repeats (reduced if looping reaches end of infile)."
			$ll insert end $line
			set line "EXTEND SCRAMBLE 1  infil outfil minseglen maxseglen outdur \[-wsplen\] \[-sseed\] \[-b\] \[-e\]"
			$ll insert end $line
			set line "EXTEND SCRAMBLE 2  infil outfil seglen    scatter   outdur \[-wsplen\] \[-sseed\] \[-b\] \[-e\]"
			$ll insert end $line
		    set line "(1) cut random chunks from file, and splice end to end."
			$ll insert end $line
		    set line "(2) cut file into random chunks and rearrange. repeat differently..etc"
			$ll insert end $line
			set line "EXTEND ZIGZAG 1    infil outfil start end dur minzig \[-ssplicelen\] \[-mmaxzig\] \[-rseed\]"
			$ll insert end $line
			set line "EXTEND ZIGZAG 2    infil outfil timefile \[-ssplicelen\]"
			$ll insert end $line
			set line "(1) random zigzags: starts at file start, ends at file end."
			$ll insert end $line
			set line "(2) zigzagging follows times supplied by user."
			$ll insert end $line
			if {[info exists released(iterline)]} {
				set line "ITERLINE ITERLINE  1-2  infile outfile transpositiondata delay rand pshift ampcut gain seed \[-n\]"
				$ll insert end $line
			}			
			if {[info exists released(iterlinef)]} {
				set line "ITERLINEF ITERLINEF  1-2  infile outfile transpositiondata delay rand pshift ampcut gain seed \[-n\]"
				$ll insert end $line
			}			
			if {[info exists released(iterfof)]} {
				set line "ITERFOF ITERFOF 1-4  infile outfile linedata outduration \[-pprand\] \[-aampcut\] \[-ttrimto\] \[-Ttrimby\] \[-Etrimslope\]"
				$ll insert end $line
				set line "                   \[-rrand\] \[-vvibmin\] \[-Vvibmax\] \[-depmin\] \[-Ddepmax\] \[-ggainmin\] \[-Ggainmax\] \[-Fupfade\] \[-ffade\] \[-Sseparation\]"
				$ll insert end $line
				set line "                   \[-Pportamento\] \[-iinterval\] \[-sseed\]"
				$ll insert end $line
			}
			if {[info exists released(silend)]} {
				set line "SILEND SILEND  1   infile outfile  pad-duration"
				$ll insert end $line
				set line "SILEND SILEND  2   infile outfile  outfile-duration"
				$ll insert end $line
			}
			if {[info exists released(bounce)]} {
				set line "BOUNCE BOUNCE infile outfile count startgap shorten endlevel ewarp \[-smin\] \[-c\] \[-e\]"
				$ll insert end $line
			}
	}
		"FILTER" {

			$ll delete 0 end
			set line "FILTER BANK 1-3       infile outfile Q gain lof hif \[-taildur\] \[-sscat\] \[-d\]"
			$ll insert end $line
			set line "FILTER BANK 4-6       infile outfile Q gain lof hif param \[-taildur\] \[-sscat\] \[-d\]"
			$ll insert end $line
			set line "FILTER BANKFRQS 1-3   anysndfile outtextfile lof hif"
			$ll insert end $line
			set line "FILTER BANKFRQS 4-6   anysndfile outtextfile lof hif param"
			$ll insert end $line
			set line "(1) harmonic series over lofrq."
			$ll insert end $line
			set line "(2) alternate harmonics over lofrq."
			$ll insert end $line
			set line "(3) subharmonic series below hifrq."
			$ll insert end $line
			set line "(4) harmonic series with linear offset: param = offset in hz."
			$ll insert end $line
			set line "(5) equal intervals between lo & hifrq: param = no. of filters."
			$ll insert end $line
			set line "(6) equal intervals between lo & hifrq: param = interval semitone-size."
			$ll insert end $line
			set line "FILTER USERBANK 1-2   infile outfile datafile Q gain \[-taildur\] \[-d\]"
			$ll insert end $line
			set line "FILTER VARIBANK 1-2   infile outfile data Q gain \[-ttaildur\] \[-hhcnt\] \[-rrolloff\] \[-d\]"
			$ll insert end $line
	    	set line "FILTER ITERATED 1-2   infile outfile datafile Q gain delay dur \[-sprescale\] \[-rrand\] \[-ppshift\] \[-aashift\] \[-d\] \[-i\] \[-e\] \[-n\]"
			$ll insert end $line
			set line "(1) Enter filter-pitches as frq, in Hz."
			$ll insert end $line
			set line "(2) Enter filter-pitches as MIDI values."
			$ll insert end $line
			set line "FILTER FIXED 1-2      infile outfile        boost/cut freq \[-taildur\] \[-sprescale\]"
			$ll insert end $line
			set line "FILTER FIXED 3        infile outfile bwidth boost/cut freq \[-taildur\] \[-sprescale\]"
			$ll insert end $line
			set line "(1) boost or cut below given frq"
			$ll insert end $line
			set line "(2) boost or cut above given frq"
			$ll insert end $line
			set line "(3) boost or cut a band centered on given frq"
			$ll insert end $line
	    	set line "FILTER LOHI 1-2       infile outfile attenuation pass-band stop-band \[-taildur\] \[-sprescale\]"
			$ll insert end $line
		    set line "(1) Pass-band and stop-band as freq in Hz."
			$ll insert end $line
		    set line "(2) Pass-band and stop-band as (possibly fractional) midi notes."
			$ll insert end $line
			set line "FILTER VARIABLE 1-4   infile outfile acuity gain frq \[-taildur\] "
			$ll insert end $line
			set line "FILTER SWEEPING 1-4   infile outfile acuity gain lofrq hifrq sweepfrq \[-taildur\] \[-pphase\]"
			$ll insert end $line
			set line "(1) high-pass"
			$ll insert end $line
			set line "(2) low-pass"
			$ll insert end $line
			set line "(3) band-pass"
			$ll insert end $line
			set line "(4) notch (band-reject)."
			$ll insert end $line
			set line "FILTER PHASING 1-2    infile outfile gain delay \[-taildur\] \[-sprescale\] \[-l\]"
			$ll insert end $line
			set line "(1) allpass filter (phase-shifted)"
			$ll insert end $line
			set line "(2) phasing effect"
			$ll insert end $line
			set line "FILTER VARIBANK2 1-2  infile outfile data Q gain \[-ttail\] \[-d\]"
			$ll insert end $line
			set line "(1) Frequency data"
			$ll insert end $line
			set line "(2) Midi data"
			$ll insert end $line
			if {[info exists released(lucier)]} {
				set line "LUCIER GETFILT  inanalfile  outfiltdata  min-roomsize  rolloff-interval"
				$ll insert end $line
				set line "LUCIER GET  inanalfile  outanalfile  min-roomsize  rolloff-interval  \[-l\]"
				$ll insert end $line
				set line "LUCIER IMPOSE  src-analfile  room-analfile  outanalfile  reson-count  \[-roct_tailoff\]"
				$ll insert end $line
				set line "LUCIER SUPPRESS  src-analfile  room-analfile  suppression"
				$ll insert end $line
			}
			if {[info exists released(filtrage)]} {
				set line "FILTRAGE FILTRAGE  1  outfiltdata  dur  cnt  MIDImin  MIDImax  distrib  rand  ampmin  amprand  ampdistrib  \[-sseed\]"
				$ll insert end $line
				set line "FILTRAGE FILTRAGE 2  outfiltdata  dur  cnt  MIDImin  MIDImax  distrib  rand  ampmin  amprand  ampdistrib  timestep  timerand  \[-sseed\]"
				$ll insert end $line
			}			
		}
		"FOCUS" {

			$ll delete 0 end
			set line "FOCUS ACCU   infile outfile \[-ddecay\] \[-gglis\]"
			$ll insert end $line
			set line "SUPERACCU SUPERACCU 1-2 infile outfile \[-ddecay\] \[-gglis\] \[r\]"
			$ll insert end $line
			set line "SUPERACCU SUPERACCU 3-4 infile outfile tuning \[-ddecay\] \[-gglis\] \[r\]"
			$ll insert end $line
			set line "FOCUS EXAG   infile outfile exaggeration"
			$ll insert end $line
			set line "FOCUS FOCUS  infile outfile -fN|-pN \[-i\] pk bw \[-bbt\] \[-ttp\] \[-sval\]"
			$ll insert end $line
			set line "FOCUS FOLD   infile outfile lofrq hifrq \[-x\]"
			$ll insert end $line
			set line "FOCUS FREEZE 1-3 infile outfile datafile"
			$ll insert end $line
			set line "(1) freeze channel amplitudes"
			$ll insert end $line
			set line "(2) freeze channel frequencies"
			$ll insert end $line
			set line "(3) freeze channel amplitudes & frequencies"
			$ll insert end $line
			set line "FOCUS HOLD   infile outfile datafile"
			$ll insert end $line
			set line "FOCUS STEP   infile outfile timestep"
			$ll insert end $line
			if {[info exists released(selfsim)]} {
				set line "SELFSIM SELFSIM  inanalfile outanalfile self-similarity-index"
				$ll insert end $line
			}
		}
		"FOFS" {

			$ll delete 0 end
			set line "PSOW STRETCH    infile outfile pitch-brkpnt-data timestretch segcnt"
			$ll insert end $line
			set line "PSOW DUPL       infile outfile pitch-brkpnt-data repeat-cnt segcnt"
			$ll insert end $line
			set line "PSOW DEL        infile outfile pitch-brkpnt-data propkeep segcnt"
			$ll insert end $line
			set line "PSOW STRTRANS   infile outfile pitch-brkpnt-data timestretch segcnt trans"
			$ll insert end $line
			set line "PSOW GRAB       infile outfile pitch-brkpnt-data time dur segcnt spectrans density rand"
			$ll insert end $line
			set line "PSOW CHOP       infile outfile pitch-brkpnt-data time-grain-pairs"
			$ll insert end $line
			set line "PSOW INTERP     infile1 infile2 outfile startdur interpdur enddur vibfrq  vibdepth  tremfrq  tremdepth"
			$ll insert end $line
			set line "infiles must be single FOFs"
			$ll insert end $line
			set line "PSOW FEATURES  1-2 infile1 outfile pitch-brkpnt-data segcnt trans  vibfrq  vibdepth  spectrans  hoarseness  attenuation"
			$ll insert end $line
			set line "(1) Transposition accompanied by timewarp "
			$ll insert end $line
			set line "(2) Transposed pitch accompanied by additional lower pitch"
			$ll insert end $line
			set line "PSOW SYNTH 1-5  infile1 outfile \[oscdatafile\] pitch-brkpnt-data depth"
			$ll insert end $line
			set line "(1) oscdatafile = frequency and amplitude pairs"
			$ll insert end $line
			set line "(2) oscdatafile = midipitch and amplitude pairs"
			$ll insert end $line
			set line "(3) oscdatafile = frq and amp data in the 'filter varibank' format"
			$ll insert end $line
			set line "(4) oscdatafile = midipitch & amp data in 'filter varibank' format"
			$ll insert end $line
			set line "(5) NO oscdatafile: synthetic source is noise"
			$ll insert end $line
			set line "PSOW SYNTH      infile1 infile2 outfile pitch-brkpnt-data depth wsize gate"
			$ll insert end $line
			set line "PSOW SPLIT      infile1 outfile pitch-brkpnt-data subharmno uptrans balance"
			$ll insert end $line
			set line "PSOW SPACE      infile1 outfile pitch-brkpnt-data subno separation balance hisuppress"
			$ll insert end $line
			set line "PSOW INTERLEAVE infile1 infile2 outfile pbrk1 pbrk2 grplen bias bal weight"
			$ll insert end $line
			set line "PSOW REPLACE    infile1 infile2 outfile pbrk1 pbrk2 grpcnt"
			$ll insert end $line
			set line "PSOW SUSTAIN    infile outfile pitch-brkpnt-data time dur segcnt vibfrq vibdepth gain \[-s\]"
			$ll insert end $line
			set line "PSOW SUSTAIN2   infile outfile start end  dur vibfrq vibdepth nudge"
			$ll insert end $line
			set line "PSOW LOCATE     infile pitch-brkpnt-data time"
			$ll insert end $line
			set line "PSOW CUTATGRAIN 1-2 infile outfile pitch-brkpnt-data time"
			$ll insert end $line
			set line "(1) Retain sound before grain"
			$ll insert end $line
			set line "(2) Retain sound after grain"
			$ll insert end $line
			set line "PSOW REINFORCE 1 infile outfile harmonics-reinforcement-data pitch-brkpnt-data \[-s\]"
			$ll insert end $line
			set line "PSOW REINFORCE 2 infile outfile inharmonic-reinforcement-data pitch-brkpnt-data \[-wweight\]"
			$ll insert end $line
			if {[info exists released(tweet)]} {
				set line "TWEET TWEET 1 infile outfile exclude pitchdata minlevel pkcnt chirp \[-w\]"
				$ll insert end $line
				set line "TWEET TWEET 2 infile outfile exclude pitchdata minlevel frq chirp \[-w\]"
				$ll insert end $line
				set line "TWEET TWEET 3 infile outfile exclude pitchdata minlevel \[-w\]"
				$ll insert end $line
			}
		}
		"FORMANTS" {

			$ll delete 0 end
			set line "FORMANTS GET      infile outfile -fN|-pN"
			$ll insert end $line
			set line "FORMANTS PUT 1    infile fmntfile outfile \[-i\] \[-llof\] \[-hhif\] \[-ggain\]"
			$ll insert end $line
			set line "FORMANTS PUT 2    infile fmntfile outfile      \[-llof\] \[-hhif\] \[-ggain\]"
			$ll insert end $line
			set line "(1) New formant envelope replaces sound's own formant envelope."
			$ll insert end $line
			set line "(2) New formant envelope imposed on top of sound's own formant envelope."
			$ll insert end $line
			set line "FORMANTS VOCODE   infile infile2 outfile -fN|-pN \[-llof\] \[-hhif\] \[-ggain\]"
			$ll insert end $line
			set line "FORMANTS SEE      infile outsndfile \[-v\]"
			$ll insert end $line
			set line "FORMANTS GETSEE   infile outsndfile -fN|-pN \[-s\]"
			$ll insert end $line
			if {[info exists released(specenv)]} {
				set line "SPECENV SPECENV inanalfil1 inanalfil2 outanalfil winsize \[-bbalance\] \[-p\] \[-i\] \[-k\]"
				$ll insert end $line
			}
		}
		"GRAIN" {

			$ll delete 0 end
			set line "GRAIN ALIGN        infile1 infile2 outfile offset gate2 \[-lgate\] \[-hminhole\] \[-twinsize\] \[-x\]"
			$ll insert end $line
			set line "GRAIN COUNT        infile \[-lgate\] \[-hminhole\] \[-twinsize\] \[-x\]"
			$ll insert end $line
			set line "GRAIN ASSESS       infile"
			$ll insert end $line
			set line "GRAIN DUPLICATE    infile outfile N \[-lgate\] \[-hminhole\] \[-twinsize\] \[-x\]"
			$ll insert end $line
			set line "GRAIN FIND         infile out-textfile \[-lgate\] \[-hminhole\] \[-twinsize\] \[-x\]"
			$ll insert end $line
			set line "GRAIN OMIT         infile outfile keep  out-of \[-lgate\] \[-hminhole\] \[-twinsize\] \[-x\]"
			$ll insert end $line
			set line "GRAIN REORDER      infile outfile code \[-lgate\] \[-hminhole\] \[-twinsize\] \[-x\]"
			$ll insert end $line
			set line "GRAIN REPOSITION   infile outfile timefile offset \[-lgate\] \[-hminhole\] \[-twinsize\] \[-x\]"
			$ll insert end $line
			set line "GRAIN REMOTIF  1-2 infile outfile transpmultfile \[-lgate\] \[-hminhole\] \[-twinsize\] \[-x\]"
			$ll insert end $line
			set line "GRAIN REPITCH  1-2 infile outfile transpfile \[-lgate\] \[-hminhole\] \[-twinsize\] \[-x\]"
			$ll insert end $line
			set line "GRAIN RERHYTHM 1-2 infile outfile multfile \[-lgate\] \[-hminhole\] \[-twinsize\] \[-x\]"
			$ll insert end $line
			set line "(1)   Transform each grain in turn, without repeating any grains:"
			$ll insert end $line
			set line "      on reaching end of transposition list, cycle back to its start."
			$ll insert end $line
			set line "(2)   Play grain at each transposed pitch, before proceeding to next grain."
			$ll insert end $line
			set line "GRAIN REVERSE      infile outfile \[-lgate\] \[-hminhole\] \[-twinsize\] \[-x\]" 
			$ll insert end $line
			set line "GRAIN TIMEWARP     infile outfile timestretch-ratio \[-lgate\] \[-hminhole\] \[-twinsize\] \[-x\]" 
			$ll insert end $line
			set line "GRAIN R_EXTEND  1  infile outfile start end tstretch prange repets get ascat pscat"
			$ll insert end $line
			set line "GRAIN R_EXTEND  2  infile outfile gate size tstretch prange repets get ascat pscat skip at tempo by \[-s\] \[-e\]"
			$ll insert end $line
			set line "GRAIN R_EXTEND  3  infile outfile start end prange"
			$ll insert end $line
			set line "GRAIN NOISE_EXTEND infile outfile duration minfrq mindur \[-x\]"
			$ll insert end $line
			set line "GRAIN GREV 1   infile outfile wsize trof grpcnt"
			$ll insert end $line
			set line "GRAIN GREV 2   infile outfile wsize trof grpcnt repeats"
			$ll insert end $line
			set line "GRAIN GREV 3-4 infile outfile wsize trof grpcnt keep out-of"
			$ll insert end $line
			set line "GRAIN GREV 5   infile outfile wsize trof grpcnt timestretch"
			$ll insert end $line
			set line "GRAIN GREV 6   infile outtextfile wsize trof grpcnt"
			$ll insert end $line
			set line "GRAIN GREV 7   infile outfile times_textfile wsize trof grpcnt"
			$ll insert end $line
			set line "GRAINEX EXTEND  infile outfile wsize trof added-dur start-of-grains end-of-grains"
			$ll insert end $line
		}
		"HFPERM" {
			$ll delete 0 end
			set line "HFPERM HFCHORDS 1-4     notesfile outfile srate (note-dur gap-dur (pause_dur)) min-setsize "
			$ll insert end $line
			set line "                          bottom-note bottom_oct top-note top_oct sort-by  \[-m -s -a -o\]"
			$ll insert end $line
			set line "HFPERM HFCHORDS2 1-4    notesfile outfile srate (note-dur gap-dur (pause_dur)) min-setsize sort-by  \[-m -s -a -o\]"
			$ll insert end $line
			set line "(1) sound out...outputs 1 soundfile of the chords."
			$ll insert end $line
			set line "(2) sounds out..outputs several soundfiles, chords grouped by the sort prodecure(s) you specify."
			$ll insert end $line
			set line "(3) text out ...outputs textfile listing chords described by their note names."
			$ll insert end $line
			set line "(4) midi out ...outputs list of chords described by the midi values of the notes in them."
			$ll insert end $line
			set line "HFPERM DELPERM          notesfile outfile permfile srate initial-notelen how-many -of-perm"
			$ll insert end $line
			set line "HFPERM DELPERM2         infile outfile permfile cycles-of-perm"
			$ll insert end $line

		}
		"HILITE" {

			$ll delete 0 end
			set line "HILITE ARPEG 1-4     infile outfile wave rate \[-pU\] \[-lX\] \[-hY\] \[-bZ\] \[-aA\] \[-Nk\] \[-sS\] \[-T\]  \[-K\]"
			$ll insert end $line
			set line "HILITE ARPEG 5-8     infile outfile wave rate \[-pU\] \[-lX\] \[-hY\] \[-bZ\] \[-aA\]"
			$ll insert end $line
			set line "(1) on..............play components inside arpeggiated band only."
			$ll insert end $line
			set line "(2) boost...........amplify snds in band. others play unamplified."
			$ll insert end $line
			set line "(3) below_boost.....initially play components in & below band only."
			$ll insert end $line
			set line "                     then amplify snds in band. others play unamplified."
			$ll insert end $line
			set line "                     (not with downramp)."
			$ll insert end $line
			set line "(4) above_boost.....initially play components in & above band only."
			$ll insert end $line
			set line "                     then amplify snds in band. others play unamplified."
			$ll insert end $line
			set line "                     (not with upramp: with sin/saw startphase>0.5)"
			$ll insert end $line
			set line "(5) below...........play components in & below arpeggiated band only."
			$ll insert end $line
			set line "(6) above...........play components in & above arpeggiated band only."
			$ll insert end $line
			set line "(7) once_below......initially play components in and below band only."
			$ll insert end $line
			set line "                     then play whole sound as normal.(not with downramp)."
			$ll insert end $line
			set line "(8) once_above......initially play components in and above arpeggiated band only."
			$ll insert end $line
			set line "                     then play whole sound as normal."
			$ll insert end $line
			set line "                     (not with upramp: with sin/saw startphase>0.5)"
			$ll insert end $line
			set line "HILITE BAND infile outfile datafile"
			$ll insert end $line
			set line "HILITE BLTR infile outfile blurring tracing "
			$ll insert end $line
			set line "HILITE FILTER 1-4    infile outfile frq1 Q "
			$ll insert end $line
			set line "HILITE FILTER 5-6    infile outfile frq1 Q gain"
			$ll insert end $line
			set line "HILITE FILTER 7-10   infile outfile frq1 frq2 Q"
			$ll insert end $line
			set line "HILITE FILTER 11-12  infile outfile frq1 frq2 Q gain"
			$ll insert end $line
			set line "(1)  high pass filter "
			$ll insert end $line
			set line "(2)  high pass filter (normalised output) "
			$ll insert end $line
			set line "(3)  low pass filter "
			$ll insert end $line
			set line "(4)  low pass filter (normalised output) "
			$ll insert end $line
			set line "(5)  high pass filter with gain "
			$ll insert end $line
			set line "(6)  low pass filter with gain "
			$ll insert end $line
			set line "(7)  band pass filter "
			$ll insert end $line
			set line "(8)  band pass filter (normalised output) "
			$ll insert end $line
			set line "(9)  notch filter "
			$ll insert end $line
			set line "(10) notch filter (normalised output) "
			$ll insert end $line
			set line "(11) band pass filter with gain "
			$ll insert end $line
			set line "(12) notch filter with gain "
			$ll insert end $line
			set line "HILITE GREQ 1-2      infile outfile filtfile \[-r\]"
			$ll insert end $line
			set line "(1) single bandwidth for all filter bands."
			$ll insert end $line
			set line "    Filtfile has 1 bandwidth (octaves) followed by centre frqs of all filter bands (Hz)."
			$ll insert end $line
			set line "(2) separate bandwidths for each filter band."
			$ll insert end $line
			set line "    Filtfile has 2 vals for each filter band : bandwidth (octs) & centre frq of band (Hz)."
			$ll insert end $line
			set line "HILITE PLUCK         infile outfile gain"
			$ll insert end $line
			set line "HILITE TRACE 1       infile outfile N"
			$ll insert end $line
			set line "HILITE TRACE 2       infile outfile N lofrq       \[-r\]"
			$ll insert end $line
			set line "HILITE TRACE 3       infile outfile N       hifrq \[-r\]"
			$ll insert end $line
			set line "HILITE TRACE 4       infile outfile N lofrq hifrq \[-r\]"
			$ll insert end $line
			set line "(1) Select loudest spectral components."
			$ll insert end $line
			set line "(2) Select loudest from above lofrq: Reject all spectral data below lofrq."
			$ll insert end $line
			set line "(3) Select loudest from below hifrq: Reject all spectral data above hifrq."
			$ll insert end $line
			set line "(4) Select loudest from between lofrq and hifrq: Reject data outside."
			$ll insert end $line
		}
		"HOUSEKEEP" {

			$ll delete 0 end
			set line "HOUSEKEEP BUNDLE 1-5   infile \[infile2....\] outtextfile"
			$ll insert end $line
			set line "(1) bundle all entered files"
			$ll insert end $line
			set line "(2) bundle all non-text files entered"
			$ll insert end $line
			set line "(3) bundle all non-text files of same type as first non-text file e.g. all sndfiles"
			$ll insert end $line
			set line "(4) as (3), but only files with same properties"
			$ll insert end $line
			set line "(5) as (4), but if file1 is sndfile, files with same channel count only"
			$ll insert end $line
			set line "HOUSEKEEP COPY 1       infile outfile"
			$ll insert end $line
			set line "HOUSEKEEP COPY 2       infile count \[-i\]"
			$ll insert end $line
			set line "HOUSEKEEP DISK         anyinfile"
			$ll insert end $line
			set line "HOUSEKEEP EXTRACT 1    infile \[-ggate\] \[-sS\] \[-eE\] \[-tT\] \[-hH\] \[-bB\] \[-iI\] \[-lL\] \[-wW\] \[-n\]"
			$ll insert end $line
	    	set line "HOUSEKEEP EXTRACT 2    infile outfile"
			$ll insert end $line
	    	set line "HOUSEKEEP EXTRACT 3    infile outfile \[-ggate\] \[-ssplice\] \[-b\] \[-e\]"
			$ll insert end $line
	    	set line "HOUSEKEEP EXTRACT 4    infile outfile shift"
			$ll insert end $line
	    	set line "HOUSEKEEP EXTRACT 5    infile valsfile"
			$ll insert end $line
	    	set line "HOUSEKEEP EXTRACT 6    infile outtextfile gate endgate threshold baktrak initlevel minsize gatewin"
			$ll insert end $line
			set line "(1) cut out & keep significant events from input sndfile."
			$ll insert end $line
			set line "(2) extraction preview: create pseudo-sndfile showing envelope of sndfile, sector by sector."
			$ll insert end $line
			set line "(3) top and tail: remove low level signal from start & end of sound."
			$ll insert end $line
			set line "(4) rectify: shift entire signal to eliminate dc drift."
			$ll insert end $line
			set line "(5) modify 'by hand' : valsfile of sampno & sampleval pairs, to substitute in file."
			$ll insert end $line
			set line "(6) find onset times:"
			$ll insert end $line
			set line "HOUSEKEEP REMOVE       filename \[-a\]"
			$ll insert end $line
	    	set line "HOUSEKEEP RESPEC 1     infile outfile new_samplerate"
			$ll insert end $line
			set line "HOUSEKEEP RESPEC 2     infile outfile"
			$ll insert end $line
			set line "HOUSEKEEP RESPEC 3     infile outfile \[-ssrate\] \[-cchannels\] \[-tsamptype\]"
			$ll insert end $line
			set line "(1) resample  at some different sampling rate."
			$ll insert end $line
			set line "(2) convert from integer to float samples, or vice versa"
			$ll insert end $line
			set line "(3) change properties of sound: (use with caution!!)"
			$ll insert end $line
			set line "HOUSEKEEP SORT 1       listfile"
			$ll insert end $line
			set line "HOUSEKEEP SORT 2-3     listfile small large step \[-l\]"
			$ll insert end $line
			set line "HOUSEKEEP SORT 4       listfile \[-l\]"
			$ll insert end $line
			set line "HOUSEKEEP SORT 5       listfile"
			$ll insert end $line
			set line "(1) sort by filetype to separate textfiles"
			$ll insert end $line
			set line "(2) sort by srate to separate textfiles"
			$ll insert end $line
			set line "(3) sort by duration: small = maxsize smallest files :large = minsize largest files. (secs)"
			$ll insert end $line
			set line "      step = size-steps between file groups : -l no outfile written."
			$ll insert end $line
			set line "(4) sort by log duration : the same, except step is duration ratio between file types."
			$ll insert end $line
			set line "(5) sort into duration order : -l causes file durations not to be written to outfile."
			$ll insert end $line
			set line "(6) find rogues : sort out any non- or invalid soundfiles."
			$ll insert end $line
			set line "HOUSEKEEP DEGLITCH  infile  outfile  glitch  gap  threshold  splice  window  \[-s\]"
			$ll insert end $line
		}
		"LOUDNESS" {

			$ll delete 0 end
			set line "MODIFY LOUDNESS 1      infile outfile gain"
			$ll insert end $line
			set line "MODIFY LOUDNESS 2      infile outfile gain"
			$ll insert end $line
			set line "MODIFY LOUDNESS 3      infile outfile \[-llevel\]"
			$ll insert end $line
			set line "MODIFY LOUDNESS 4      infile outfile \[-llevel\]"
			$ll insert end $line
			set line "MODIFY LOUDNESS 5      infile infile2 outfile"
			$ll insert end $line
			set line "MODIFY LOUDNESS 6      infile outfile"
			$ll insert end $line
			set line "MODIFY LOUDNESS 7      infile infile2 etc."
			$ll insert end $line
			set line "MODIFY LOUDNESS 8      infile infile2 etc. outfile"
			$ll insert end $line
			set line "(1) gain:         adjust level by factor gain."
			$ll insert end $line
			set line "(2) dbgain:       adjust level by gain db."
			$ll insert end $line
			set line "(3) normalise:    force level (if ness) to max possible, or to level given."
			$ll insert end $line
			set line "(4) force level:  force level to maximum possible, or to level given."
			$ll insert end $line
			set line "(5) balance:      force max level of file1 to max level of file 2."
			$ll insert end $line
			set line "(6) invert phase: invert phase of the sound."
			$ll insert end $line
			set line "(7) find loudest: find loudest file."
			$ll insert end $line
			set line "(8) equalise:     force all files to level of loudest file."
			$ll insert end $line
		}
		"MORPH" {

			$ll delete 0 end
			set line "MORPH BRIDGE 1-6       infile1 infile2 outfile \[-aoffset\] \[-bsf2\] \[-csa2\] \[-def2\] \[-eea2\] \[-fstart\] \[-gend\]"
			$ll insert end $line
			set line "(1) output level is direct result of interpolation."
			$ll insert end $line
			set line "(2) output level follows moment to moment minimum of the 2 infile amplitudes."
			$ll insert end $line
			set line "(3) output level follows moment to moment amplitude of infile1."
			$ll insert end $line
			set line "(4) output level follows moment to moment amplitude of infile2."
			$ll insert end $line
			set line "(5) output level moves, through interp, from that of file1 to that of file2."
			$ll insert end $line
			set line "(6) output level moves, through interp, from that of file2 to that of file1."
			$ll insert end $line
			set line "MORPH GLIDE            infile infile2 outfile duration"
			$ll insert end $line
			set line "MORPH MORPH 1-2        infile infile2 outfile as ae fs fe expa expf \[-sstagger\]"
			$ll insert end $line
			set line "(1) interpolate linearly (exp=1) or over curve of increasing (exp >1) or decreasing (<1) slope."
			$ll insert end $line
			set line "(2) interpolate over a cosinusoidal spline."
			$ll insert end $line
			set line "NEWMORPH NEWMORPH 1-4  infile infile2 outfile stagger startmorph endmorph exponent peakcnt \[-e\] \[-n\] \[-f\]"
			$ll insert end $line
			set line "(1) interpolate average peaks of spectra : linearly ( exp = 1 ) or over curve of increasing ( exp > 1 ) or decreasing ( <1 ) slope."
			$ll insert end $line
			set line "(2) interpolate average peaks of spectra : cosinusoidally ( exp = 1 ) or warped cosinusoid (exp != 1 )."
			$ll insert end $line
			set line "(3) interpolate momentwise peaks of spectra : linearly ( exp = 1 ) or over curve of increasing ( exp > 1 ) or decreasing ( <1 ) slope."
			$ll insert end $line
			set line "(4) interpolate momentwise peaks of spectra : cosinusoidally ( exp = 1 ) or warped cosinusoid (exp != 1 )."
			$ll insert end $line
			set line "NEWMORPH NEWMORPH 5-6  infile infile2 outfile stagger startmorph endmorph exponent peakcnt \[-rrand\]"
			$ll insert end $line
			set line "(5) interpolate peaks of spectra of file1 towards averaged peaks of file2."
			$ll insert end $line
			set line "(6) interpolate peaks of spectra of file1, cosinusoidally, towards averaged peaks of file2."
			$ll insert end $line
			set line "NEWMORPH NEWMORPH 7  infile infile2 outfile peakcnt outcnt \[-e\] \[-n\] \[-f\]"
			$ll insert end $line
			set line "(7) interpolate peaks of spectra of file1 towards those of file2, in steps, producing several output files."
			$ll insert end $line
			set line "NEWMORPH NEWMORPH2 1  infile outtextfile peakcnt"
			$ll insert end $line
			set line "NEWMORPH NEWMORPH2 2-3  infile outfile peaksfile startmorph endmorph exponent peakcnt \[-rrand\]"
			$ll insert end $line
			set line "(1) interpolate file1 peaks to average peaks of file2: linearly ( exp = 1 ) or over curve of increasing ( exp > 1 ) or decreasing ( <1 ) slope."
			$ll insert end $line
			set line "(2) ditto, cosinusoidally."
			$ll insert end $line
		}
		"MULTI" {

			$ll delete 0 end
			set line "NEWMIX MULTICHANNEL  multichanmixfile  outsndfile \[-sSTART\] \[-eEND\] \[-gATTENUATION\]"
			$ll insert end $line
			set line "MULTIMIX CREATE 1-6 insndfile1 \[insndfile2 .....\] outmixfile \[params\]"
			$ll insert end $line
			set line "       In Mode 3, param is TIMESTEP between each succesive entry."
			$ll insert end $line
			set line "       In Mode 4, (stereo or mono) param is BALANCE between narrow and wide stereo-pair."
			$ll insert end $line
			set line "       In Mode 5, (stereo or mono) params are STAGE WIDE REARWIDE REAR relative-levels."
			$ll insert end $line
			set line "       Mode 6, mono files only (no params)."
			$ll insert end $line
			set line "MULTIMIX CREATE 7 insndfile1 \[insndfile2 .....\] outmixfile outchans startchan \[-sskipchans\]"
			$ll insert end $line
			set line "MULTIMIX CREATE 8 insndfile1 \[insndfile2 .....\] outmixfile outchans"
			$ll insert end $line
			set line "SRATE MULTI 1-2  infile outfile PARAM \[-o\]"
			$ll insert end $line
			set line "       In Mode 1, PARAM is a speed multiplier."
			$ll insert end $line
			set line "       In Mode 2, PARAM is a transposition in semitones."
			$ll insert end $line
			set line "       -o reads brkpnt times as times in OUTPUT sound: default, read as times in input sound."
			$ll insert end $line
			set line "MCHANPAN mchanpan 1 infile outfile pandata outchans -fFOCUS"
			$ll insert end $line
			set line "MCHANPAN mchanpan 2 infile outfile switchdata outchans -fFOCUS -mMINSIL"
			$ll insert end $line
			set line "MCHANPAN mchanpan 3 infile outfile outchans centre spread depth rolloff minsil \[-s\]"
			$ll insert end $line
			set line "MCHANPAN mchanpan 4 infile outfile outchans centre spread depth rolloff"
			$ll insert end $line
			set line "MCHANPAN mchanpan 5 infile outfile outchans minsil"
			$ll insert end $line
			set line "MCHANPAN mchanpan 6 infile outfile outchans eventdur gap splice"
			$ll insert end $line
			set line "MCHANPAN mchanpan 7 infile outfile pandata rolloff"
			$ll insert end $line
			set line "MCHANPAN mchanpan 9 infile outfile outchans startchan speed focus \[-a\]"
			$ll insert end $line
			set line "MCHANPAN mchanpan 10 infile outfile outchans -fFOCUS -mMINSIL -gGROUPING \[-a\] \[-r\]"
			$ll insert end $line
			set line "FRAME shift 1 infile outfile snake rotation -sSMEAR"
			$ll insert end $line
			set line "FRAME shift 2 infile outfile snake rotation1 rotation2 -sSMEAR"
			$ll insert end $line
			set line "FRAME shift 3 infile outfile orientation"
			$ll insert end $line
			set line "FRAME shift 4 infile outfile mirrorplane"
			$ll insert end $line
			set line "FRAME shift 5 infile outfile -bBILATERAL"
			$ll insert end $line
			set line "FRAME shift 6 infile outfile swapA swapB"
			$ll insert end $line
			set line "FRAME shift 7 infile outfile chans_to_modify gain"
			$ll insert end $line
			set line "FRAME shift 8 infile outfile -bBILATERAL"
			$ll insert end $line
			set line "MCHANREV mchanrev infile outfile gain roll_off size count outchans centre spread"
			$ll insert end $line
			set line "MCHSTEREO mchstereo infile1 \[infile2 ....\]  outfile  outchandata  pregain  -s"
			$ll insert end $line
			set line "WRAPPAGE wrappage infile \[infile2 ...\] outfile  centre  outchans  spread  depth"
			$ll insert end $line
			set line "       velocity hvelocity  density  hdensity  grainsize  hgrainsize  pitchshift  hpitchshift"
			$ll insert end $line
			set line "       amp  hampbsplice  hbsplice  esplice  hesplice  rrange  jitter  outlength  \[-bbufmult -e -o\]"
			$ll insert end $line
			set line "FLUTTER flutter infile outfile chansetdata frq depth \[-r\]"
			$ll insert end $line
			set line "MCHSHRED shred 1 infile outfile repeats chunklen scatter outchans"
			$ll insert end $line
			set line "MCHSHRED shred 2 infile outfile repeats chunklen scatter"
			$ll insert end $line
			set line "MCHZIG zag 1 infile outfile start end dur minzig outchans \[-ssplicelen\] \[-mmaxzig\] \[-rseed\] \[-a\]"
			$ll insert end $line
			set line "MCHZIG zag 2 infile ileoutf timefile outchans \[-ssplicelen\] \[-a\]"
			$ll insert end $line
			set line "MCHITER ITER 1 infil outfil outchans outduration \[-ddelay\] \[-rrand\] \[-ppshift\] \[-aampcut\] \[-ffade\] \[-ggain\] \[-sseed\]"
			$ll insert end $line
			set line "MCHITER ITER 2 infil outfil outchans repetitions \[-ddelay\] \[-rrand\] \[-ppshift\] \[-aampcut\] \[-ffade\] \[-ggain\] \[-sseed\]"
			$ll insert end $line
			if {[info exists released(tostereo)]} {
				set line "TOSTEREO TOSTEREO infile outfile start end \[-oochans\] \[-lloutchan\] \[-rroutchan\] \[-mmixlev\]"
				$ll insert end $line
			}
		set line ""
			$ll insert end $line
			set line "MULTICHANNEL TOOLKIT"
			$ll insert end $line
			set line ""
			$ll insert end $line
			set line "ABFPAN \[-b\] \[-x\] \[-oN\]  infile outfile startpos endpos"
			$ll insert end $line
			set line "ABFPAN2 \[-gGAIN\] \[-w\] \[-p\[DEG\]\]  infile outfile startpos endpos"
			$ll insert end $line
			set line "NJOIN \[-sSECS | -SSECS\]  \[-cCUEFILE\] \[-x\] filelist.txt outfile"
			$ll insert end $line
			set line "CHANNELX \[-oBASENAME\] infile chan_no \[chan_no .....\]"
			$ll insert end $line
			set line "CHORDER infile outfile orderstring"
			$ll insert end $line
			set line "FMDCODE \[-x\]  \[-w\] infile outfile layout"
			$ll insert end $line
			set line "CHXFORMAT \[-m\] | \[\[-t\] \[-gguid\] \[-sMASK\]\] infile"
			$ll insert end $line
			set line "INTERLX \[-tN\] outfile infile \[infile2 ....\]"
			$ll insert end $line
			set line "COPYSFX \[-d\] \[-h\] \[-sSTYPE\] \[-tFORMAT\]  infile outfile"
			$ll insert end $line
			set line "NJOIN \[-sSECS | -SSECS\] \[-cCUEFILE\] \[-x\] filelist.txt \[outfile\]"
			$ll insert end $line
			set line "NMIX \[-d\] \[-f\] \[-oOFFSET\] infile1 infile2 outfile"
			$ll insert end $line
			set line "RMSINFO \[-n\] infile1 \[startpos \[endpos\]\]"
			$ll insert end $line
			set line "SFPROPS infile1"
			$ll insert end $line
		}
		"PITCH" {

			$ll delete 0 end
			set line "PITCH ALTHARMS 1-2  infile pitchfile outfile \[-x\]"
			$ll insert end $line
			set line "(1) delete odd harmonics."
			$ll insert end $line
			set line "(2)   delete even harmonics."
			$ll insert end $line
			set line "pitchfile must be derived from infile"
			$ll insert end $line
			set line "PITCH CHORDF        infile outfile -fN|-pN \[-i\] transpose_file \[-bbot\] \[-ttop\] \[-x\]"
			$ll insert end $line
			set line "PITCH CHORD         infile outfile transpose_file \[-bbot\] \[-ttop\] \[-x\]"
			$ll insert end $line
			set line "PITCH OCTMOVE 1-2   infile pitchfile outfile \[-i\] transposition"
			$ll insert end $line
			set line "PITCH OCTMOVE 3     infile pitchfile outfile \[-i\] transposition bassboost"
			$ll insert end $line
			set line "(1) transpose up."
			$ll insert end $line
			set line "(2) transpose down."
			$ll insert end $line
			set line "(3) transpose down, with bass-reinforcement."
			$ll insert end $line
			set line "pitchfile must be derived from infile."
			$ll insert end $line
			set line "PITCH PICK 1-3      infile outfile fundamental         \[-cclarity\]"
			$ll insert end $line
			set line "PITCH PICK 4-5      infile outfile fundamental frqstep \[-cclarity\]"
			$ll insert end $line
			set line "(1) Harmonic Series."
			$ll insert end $line
			set line "(2) Octaves."
			$ll insert end $line
			set line "(3) Odd partials of harmonic series only."
			$ll insert end $line
			set line "(4) Partials are successive linear steps (each of frqstep) from 'fundamental'."
			$ll insert end $line
			set line "(5) Add linear displacement (frqstep) to harmonic partials over fundamental."
			$ll insert end $line
			set line "PITCH TRANSP 1-3    infile outfile frq_split                     \[-ddepth\]"
			$ll insert end $line
			set line "PITCH TRANSP 4-5    infile outfile frq_split transpos            \[-ddepth\]"
			$ll insert end $line
			set line "PITCH TRANSP 6      infile outfile frq_split transpos1 transpos2 \[-ddepth\]"
			$ll insert end $line
			set line "(1) Octave transpose up, above freq_split."
			$ll insert end $line
			set line "(2) Octave transpose down, below freq_split."
			$ll insert end $line
			set line "(3) Octave transpose up and down."
			$ll insert end $line
			set line "(4) Pitch  transpose up, above freq_split."
			$ll insert end $line
			set line "(5) Pitch  transpose down, below freq_split."
			$ll insert end $line
			set line "(6) Pitch  transpose up and down."
			$ll insert end $line
			set line "PITCH TUNE 1-2      infile outfile pitch_template \[-ffocus\] \[-cclarity\] \[-ttrace\] \[-bbcut\] "
			$ll insert end $line
			set line "(1) enter pitch_template data as frq (in Hz)."
			$ll insert end $line
			set line "(2) enter pitch_template data as (possibly fractional) midi values."
			$ll insert end $line
			set line "VARITUNE VARITUNE   infile outfile pitch_template \[-ffocus\] \[-cclarity\] \[-ttrace\] \[-bbcut\] "
			$ll insert end $line
			set line "enter pitch_template data as lines of time + (possibly fractional) MIDI values (0-127)."
			$ll insert end $line
			set line "Times must start at zero and increase."
			$ll insert end $line
			set line "Same number of MIDI values (which may be duplicated) on each line."
			$ll insert end $line
		}
		"PITCHINFO" {

			$ll delete 0 end
			set line "PITCHINFO CONVERT    pitchfile outtextfile \[-dI\]"
			$ll insert end $line
			set line "PITCHINFO HEAR       pitchfile outfile \[-ggain\]"
			$ll insert end $line
	    	set line "PITCHINFO INFO       pitchfile"
			$ll insert end $line
			set line "PITCHINFO SEE 1      pitchfile    outsndfile scalefact"
			$ll insert end $line
			set line "PITCHINFO SEE 2      transposfile outsndfile"
			$ll insert end $line
			set line "(1) scalefact (> 0.0) multiplies pitch vals, for ease of viewing."
			$ll insert end $line
			set line "(2) Transposition data scaled to half max range, and displayed in log format"
			$ll insert end $line
	    	set line "PITCHINFO ZEROS      pitchfile"
			$ll insert end $line
		}
		"PITCHSPEED" {

			$ll delete 0 end
			set line "MODIFY SPEED 1      infile outfile     speed             \[-o\]"
			$ll insert end $line
	    	set line "MODIFY SPEED 2      infile outfile     semitone-transpos \[-o\]"
			$ll insert end $line
	    	set line "MODIFY SPEED 3      infile outtextfile speed             \[-o\]"
			$ll insert end $line
	    	set line "MODIFY SPEED 4      infile outtextfile semitone-transpos \[-o\]"
			$ll insert end $line
	    	set line "MODIFY SPEED 5      infile outfile     accel  goaltime   \[-sstarttime\]"
			$ll insert end $line
	    	set line "MODIFY SPEED 6      infile outfile     vibrate vibdepth"
			$ll insert end $line
			set line "(1) Vary speed/pitch of a sound."
			$ll insert end $line
			set line "(2) Vary speed/pitch by constant (fractional) no. of semitones."
			$ll insert end $line
			set line "(3) Get information on varying speed in a time-changing manner."
			$ll insert end $line
			set line "(4) Get info on time-variable speedchange in semitones."
			$ll insert end $line
			set line "    -o  brkpnt times read as outfile times (default: as infile times)."
			$ll insert end $line
			set line "(5) Accelerate or decelerate a sound."
			$ll insert end $line
			set line "    accel:     multiplication of speed reached by goaltime."
			$ll insert end $line
			set line "    goaltime:  time in output file at which accelerated speed reached."
			$ll insert end $line
			set line "    starttime: time in input/output file at which accel begins."
			$ll insert end $line
			set line "6)  Add vibrato to a sound."
			$ll insert end $line
			set line "    vibrate:   is rate of vibrato shaking in cycles-per-second."
			$ll insert end $line
			set line "    vibdepth:  is vibrato depth in (possibly fractional) semitones."
			$ll insert end $line
		}
		"PVOC" {

			$ll delete 0 end
			set line "PVOC ANAL 1-3      infile outfile \[-cpoints\] \[-ooverlap\]"
			$ll insert end $line
			set line "(1) standard analysis"
			$ll insert end $line
			set line "(2) output spectral envelope vals only"
			$ll insert end $line
			set line "(3) output spectral magnitude vals only"
			$ll insert end $line
			set line "PVOC EXTRACT      infile outfile \[-cpoints\] \[-ooverlap\] \[-ddochans\] \[-llochan\] \[-hhichan\]"
			$ll insert end $line
			set line "PVOC SYNTH        infile outfile"
			$ll insert end $line
		}
		"RADICAL" {

			$ll delete 0 end
			set line "MODIFY RADICAL 1      infile outfile"
			$ll insert end $line
	  		set line "MODIFY RADICAL 2      infile outfile repeats chunklen \[-sscatter\]"
			$ll insert end $line
	    	set line "MODIFY RADICAL 3      infile outfile dur \[-ldown\] \[-hup\] \[-sstart\] \[-eend\]"
			$ll insert end $line
			set line "MODIFY RADICAL 4      infile outfile  bit_resolution  srate_division"
			$ll insert end $line
			set line "MODIFY RADICAL 5      infile outfile  modulating-frq"
			$ll insert end $line
			set line "MODIFY RADICAL 6      infile1 infile2 outfile"
			$ll insert end $line
			if {$modify_version > 8} {
				set line "MODIFY RADICAL 7                infile outfile  bit_resolution  "
				$ll insert end $line
			}
			set line "(1) reverse : sound plays backwards."
			$ll insert end $line
			set line "(2) shred : sound is shredded, within its existing duration."
			$ll insert end $line
			set line "(3) scrub back & forth : as if handwinding over a tape-head."
			$ll insert end $line
			set line "(4) lose resolution : sound converted to lower srate, or bit-resolution."
			$ll insert end $line
			set line "(5) ring modulate : against input modulating frequency, creating sidebands."
			$ll insert end $line
			set line "(6) cross modulate : two infiles are multiplied, creating complex sidebands."
			$ll insert end $line
			if {$modify_version > 8} {
				set line "(7) bit quantisation : sound quantised to specified bit-resolution."
				$ll insert end $line
			}
			if {$modify_version > 7} {
				set line "MODIFY STACK          infile outfile tranpos-data no-of-items-in-stack lean attack-time gain proportion-to-make \[-s\] \[-n\]"
			} else {
				set line "MODIFY STACK          infile outfile tranpos-data no-of-items-in-stack lean attack-time gain proportion-to-make \[-s\]"
			}
			$ll insert end $line
			set line "CANTOR SET  1-2 infile outfile holesize holedig depth-trig splicelen maxdur \[-e\]"
			$ll insert end $line
			set line "CANTOR SET  3     infile outfile holelev holedig layercnt layerdec maxdur"
			$ll insert end $line
			set line "SHRINK SHRINK 1-3 infile outfile shrink gap contract outdur splen \[-ssmall\] \[-mmin\] \[-rrand\] \[-n\] \[-i\]"
			$ll insert end $line
			set line "SHRINK SHRINK 4 infile outfile time shrink gap contract outdur splen \[-ssmall\] \[-mmin\] \[-rrand\] \[-n\] \[-i\]"
			$ll insert end $line
			set line "SHRINK SHRINK 5 infile outname shrnk wsiz cntrct after splen \[-ssmall\] \[-mmin\] \[-rrand\] \[-llen\] \[-ggate\] \[-qskew\] \[-n\] \[-i\] \[-e\] \[-o\]"
			$ll insert end $line
			set line "SHRINK SHRINK 6 infile outname pktimes shrnk wsiz cntrct after splen \[-ssmall\] \[-mmin\] \[-rrand\] \[-llen\] \[-ggate\] \[-n\] \[-i\] \[-e\] \[-o\]"
			$ll insert end $line
			set line "FRACTURE FRACTURE 1-2 infile outfile envseries ochans streams pulse depth stack"
			$ll insert end $line
			set line "                          \[-rreadrnd\] \[-wwriternd\] \[-ddisp\] \[-llevrnd\] \[-eenvrnd\] \[-sstkrand\] \[-ppchrnd\] \[-l\]"
			$ll insert end $line
			if {[info exists released(pulser)]} {
				set line "PULSER PULSER 1 infile outfile dur pitch minrise maxrise minsustain maxsustain mindecay maxdecay speed scatter"
				$ll insert end $line
				set line "                          \[-eexpr\] \[-Eexpd\] \[-ppscat\] \[-aascat\] \[-ooctav\] \[-bbend\] \[-sseed\]"
				$ll insert end $line
				set line "PULSER PULSER 2 infile outfile dur minrise maxrise mindecay maxdecay speed scatter"
				$ll insert end $line
				set line "                          \[-eexpr\] \[-Eexpd\] \[-ppscat\] \[-aascat\] \[-ooctav\] \[-bbend\] \[-sseed\]"
				$ll insert end $line
				set line "PULSER PULSER 3 infile outfile spacedatafile dur minrise maxrise mindecay maxdecay speed scatter"
				$ll insert end $line
				set line "                          \[-eexpr\] \[-Eexpd\] \[-ppscat\] \[-aascat\] \[-ooctav\] \[-bbend\] \[-sseed\] \[-wwidth\]"
				$ll insert end $line
				set line "PULSER MULTI 1 infile1 infile2 \[infile3...\] outfile dur pitch minrise maxrise minsustain maxsustain mindecay maxdecay speed scatter"
				$ll insert end $line
				set line "                          \[-eexpr\] \[-Eexpd\] \[-ppscat\] \[-aascat\] \[-ooctav\] \[-bbend\] \[-sseed\] \[-r\]"
				$ll insert end $line
				set line "PULSER MULTI 2 infile1 infile2 \[infile3...\] outfile dur minrise maxrise mindecay maxdecay speed scatter"
				$ll insert end $line
				set line "                          \[-eexpr\] \[-Eexpd\] \[-ppscat\] \[-aascat\] \[-ooctav\] \[-bbend\] \[-sseed\] \[-r\]"
				$ll insert end $line
				set line "PULSER MULTI 3 infile1 infile2 \[infile3...\] outfile spacedatafile dur minrise maxrise mindecay maxdecay speed scatter"
				$ll insert end $line
				set line "                          \[-eexpr\] \[-Eexpd\] \[-ppscat\] \[-aascat\] \[-ooctav\] \[-bbend\] \[-sseed\]  \[-wwidth\] \[-r\]"
				$ll insert end $line
			}
			if {[info exists released(rotor)]} {
				set line "ROTOR ROTOR 1 infile outfile env cnt minp maxp step prot trot phas dur gstp \[-ddove\] \[-s\]"
				$ll insert end $line
				set line "ROTOR ROTOR 2-3 infile outfile env cnt minp maxp step prot trot phas dur \[-ddove\] \[-s\]"
				$ll insert end $line
			}
			if {[info exists released(crumble)]} {
				set line "CRUMBLE SOUND 1 infile outfile start dur1 dur2 orient segsize segrand inscat outscat outstr pscat seed \[-ssplice\] \[-ttail\] \[maxdur\]"
				$ll insert end $line
				set line "CRUMBLE SOUND 2 infile outfile start dur1 dur2 dur3 orient segsize segrand inscat outscat outstr pscat seed \[-ssplice\] \[-ttail\] \[maxdur\]"
				$ll insert end $line
			}
			if {[info exists released(tesselate)]} {
				set line "TESSELATE TESSELATE infile1 \[infile2 ...\] outfile datafile outchans cycledur outdur type"
				$ll insert end $line
			}
			if {[info exists released(phasor)]} {
				set line "PHASOR PHASOR infile outfile streams phasfrq shift ochans \[-ooffset\] \[-s\] \[-e\]"
				$ll insert end $line
			}
			if {[info exists released(crystal)]} {
				set line "CRYSTAL  ROTATE 1-10 infile1 \[infile2 ...\] outfile datafile rota rotb twidth tstep dur plo phi \[-ppass -sstop\] \[-afatt\] \[-Pfpresc\] \[-Ffslope\] \[-Ssslope\]"
				$ll insert end $line
			}
			if {[info exists released(waveform)]} {
				set line "WAVEFORM MAKE 1 infile outfile time cnt"
				$ll insert end $line
				set line "WAVEFORM MAKE 2 infile outfile time dur(mS)"
				$ll insert end $line
				set line "WAVEFORM MAKE 3 infile outfile time dur(mS) balance"
				$ll insert end $line
			}
			if {[info exists released(dvdwind)]} {
				set line "DVDWIND DVDWIND infile outfile  timecontract  cliplen(mS)"
				$ll insert end $line
			}
			if {[info exists released(cascade)]} {
				set line "CASCADE CASCADE 1-5  infile outfile seglen echocnt maxseg \[-emaxecho\] \[-rrand\] \[-sseed\] \[-Nshredno -Cshredcnt -a\] \[l\] \[-n\]"
				$ll insert end $line
				set line "CASCADE CASCADE 6-10 infile outfile cutdata echocnt \[-emaxecho\] \[-rrand\] \[-sseed\] \[-Nshredno -Cshredcnt -a\] \[l\] \[-n\]"
				$ll insert end $line
			}
			if {[info exists released(fractal)]} {
				set line "FRACTAL WAVE 1 infile outfile shape dur \[-mmaxfrac\] \[-tstr\] \[-iwarp\] \[-s\]"
				$ll insert end $line
				set line "FRACTAL WAVE 2 infile outfile shape     \[-mmaxfrac\] \[-tstr\] \[-iwarp\] \[-s\] \[-o\]"
				$ll insert end $line
				set line "FRACTAL SPECTRUM infile outfile shape   \[-mmaxfrac\] \[-tstr\] \[-iwarp\] \[-s\] \[-n\]"
				$ll insert end $line
			}
			if {[info exists released(splinter)]} {
				set line "SPLINTER SPLINTER 1-2 infile outfile target wcnt shrcnt ocnt p1 p2 \[-sscv\] \[-ppcv\] \[-eecnt\] \[-ffrq\] \[-rrand\] \[-vshrand\] \[-i\] \[-v\]"
				$ll insert end $line
				set line "SPLINTER SPLINTER 3-4 infile outfile target wcnt shrcnt ocnt p1 p2 \[-sscv\] \[-ppcv\] \[-eecnt\] \[-ddur\] \[-rrand\] \[-vshrand\] \[-i\] \[-v\]"
				$ll insert end $line
			}
			if {[info exists released(repeater)]} {
				set line "REPEATER REPEATER 1-2 infile outfile datafile \[-rrand\] \[-prand\]"
				$ll insert end $line
			    set line "Mode 1  :  datafile has \"starttime\"  \"endtime\"  \"repeat-count\"  \"delay-time\""
				$ll insert end $line
			    set line "Mode 2  :  datafile has \"starttime\"  \"endtime\"  \"repeat-count\"  \"offset-time\""
				$ll insert end $line
			}
			if {[info exists released(verges)]} {
				set line "VERGES VERGES infile outfile times \[-ttransp\] \[-eexp\] \[-ddur\] \[-n\]  \[-b | -s\]"
				$ll insert end $line
			}
			if {[info exists released(motor)]} {
				set line "MOTOR MOTOR 1,4,7 inf outf params"
				$ll insert end $line 	
				set line "MOTOR MOTOR 2,5,8 inf outf data params"
				$ll insert end $line 	
				set line "MOTOR MOTOR 3,6,9 inf1 \[inf2 ..\] outf params"
				$ll insert end $line 	
				set line "where \"params\" are......"
				$ll insert end $line 	
				set line "freq pulse fratio pratio sym dur \[-ffrand\] \[-pprand\] \[-jjitter\] \[-ttremor\] \[-yshift\] \[-eedge\] \[-bbite\] \[-sseed\] \[-vvary | -a\]"
				$ll insert end $line 	
				set line "and \[-c\] except for modes 1,4 and 7."
				$ll insert end $line 	
				set line "Modes 1-3 read segments from src, advancing then regressing."
				$ll insert end $line 	
				set line "Modes 4-6 read segments from src, advancing only."
				$ll insert end $line 	
				set line "Modes 7-9 read segments from src, advancing OR regressing only."
				$ll insert end $line 	
			}
			if {[info exists released(stutter)]} {
				set line "STUTTER STUTTER infile outfile times dur segjoins silprop silmin silmax seed \[-ttrans\] \[-aatten\] \[-bbias\] \[-mmindur\] \[-p\]"
				$ll insert end $line
			}
		}
		"REPITCH" {

			$ll delete 0 end
			set line "REPITCH GETPITCH 1      infile outfile pfil \[-tR\] \[-gM\] \[-sS\] \[-nH\] \[-lL\] \[-hT\] \[-a\] \[-z\]"
			$ll insert end $line
			set line "REPITCH GETPITCH 2      infile outfile bfil \[-tR\] \[-gM\] \[-sS\] \[-nH\] \[-lL\] \[-hT\] \[-di\] \[-a\]" 
			$ll insert end $line
			set line "(1) binary pitchfile input"
			$ll insert end $line
			set line "(2) text pitchfile input"
			$ll insert end $line
	    	set line "REPITCH EXAG 1-2        pitchfile outfile meanpch range"
			$ll insert end $line
	    	set line "REPITCH EXAG 3-4        pitchfile outfile meanpch       contour"
			$ll insert end $line
	    	set line "REPITCH EXAG 5-6        pitchfile outfile meanpch range contour"
			$ll insert end $line
	    	set line "(1,3,5) Give a pitchfile as ouput."
			$ll insert end $line
	    	set line "(2,4,6) Give a transposition file as output."
			$ll insert end $line
	    	set line "REPITCH APPROX 1-2     pitchfile outfile \[-pprange\] \[-ttrange\] \[-ssrange\]"
			$ll insert end $line
	    	set line "REPITCH INVERT 1-2     pitchfile outfile map \[-mmeanpch\] \[-bbot\] \[-ttop\]"
			$ll insert end $line
	    	set line "REPITCH QUANTISE 1-2   pitchfile outfile q-set \[-o\]"
			$ll insert end $line
			set line "REPITCH RANDOMISE 1-2  pitchfile outfile maxinterval timestep \[-sslew\]"
			$ll insert end $line
	    	set line "REPITCH SMOOTH 1-2     pitchfile outfile timeframe \[-pmeanpch\] \[-h\]"
			$ll insert end $line
			set line "REPITCH VIBRATO 1-2    pitchfile outfile vibfreq vibrange"
			$ll insert end $line
	    	set line "(1) Gives a pitchfile as ouput."
			$ll insert end $line
	    	set line "(2) Gives a transposition file as output."
			$ll insert end $line
	    	set line "REPITCH PCHSHIFT       pitchfile outpitchfile transposition"
			$ll insert end $line
			set line "REPITCH CUT 1          pitchfile outpitchfile starttime"
			$ll insert end $line
			set line "REPITCH CUT 2          pitchfile outpitchfile endtime"
			$ll insert end $line
			set line "REPITCH CUT 3          pitchfile outpitchfile starttime endtime"
			$ll insert end $line
			set line "REPITCH FIX            pitchfile outpitchfile \[-rt1\] \[-xt2\] \[-lbf\] \[-htf\] \[-sN\] \[-bf1\] \[-ef2\] \[-w\] \[-i\]"
			$ll insert end $line
			set line "REPITCH COMBINE 1      pitchfile pitchfile2 outtransposfile" 
			$ll insert end $line
			set line "REPITCH COMBINE 2      pitchfile transposfile outpitchfile" 
			$ll insert end $line
			set line "REPITCH COMBINE 3      transposfile transposfile2 outtransposfile" 
			$ll insert end $line
			set line "REPITCH COMBINEB 1     pitchfile pitchfile2 outtbrkfile \[-dI\]" 
			$ll insert end $line
			set line "REPITCH COMBINEB 2     pitchfile transposfile outpbrkfile \[-dI\]" 
			$ll insert end $line
			set line "REPITCH COMBINEB 3     transposfile transposfile2 outtbrkfile \[-dI\]" 
			$ll insert end $line
			set line "REPITCH TRANSPOSEF 1-3 infile outfile -fN|-pN \[-i\] transpos \[-lminf\] \[-hmaxf\] \[-x\]"
			$ll insert end $line
			set line "REPITCH TRANSPOSEF 4   infile transpos outfile -fN|-pN \[-i\] \[-lminf\] \[-hmaxf\] \[-x\]"
			$ll insert end $line
			set line "REPITCH TRANSPOSE 1-3  infile outfile transpos \[-lminfrq\] \[-hmaxfrq\] \[-x\]"
			$ll insert end $line
			set line "REPITCH TRANSPOSE 4   infile transpos outfile \[-lminfrq\] \[-hmaxfrq\] \[-x\]"
			$ll insert end $line
			set line "(1) transposition as a frq ratio."
			$ll insert end $line
			set line "(2) transposition in (fractions of) octaves."
			$ll insert end $line
			set line "(3) transposition in (fractions of) semitones."
			$ll insert end $line
			set line "(4) transposition as a binary data file."
			$ll insert end $line
			set line "REPITCH ANALENV         infile outfile"
			$ll insert end $line
			set line "REPITCH INSERTSIL 1-2   infile outfile silence-data"
			$ll insert end $line
			set line "REPITCH INSERTZEROS 1-2 infile outfile zeros-data"
			$ll insert end $line
			set line "(1) data as times."
			$ll insert end $line
			set line "(2) data as (grouped) samples (e.g. stereo-pair = 1 sample)."
			$ll insert end $line
			set line "REPITCH NOISETOSIL    infile outfile"
			$ll insert end $line
			set line "REPITCH PITCHTOSIL    infile outfile"
			$ll insert end $line
			set line "REPITCH SYNTH         infile outfile harmonics-data"
			$ll insert end $line
			set line "REPITCH VOWELS        infile outfile vowel-data halfwidth curve peakrange fundamental-weighting formant-scatter"
			$ll insert end $line
			set line "REPITCH PCHTOTEXT     infile outfile (converts binary pitch-data to text data)"
			$ll insert end $line
			set line "BRKTOPI BRKTOPI       infile outfile (converts text pitch-data to binary data)"
			$ll insert end $line
			set line "PEAK EXTRACT          inanalfile outfile 1 winsiz peak floor lo hi \[-htune\] \[-a\] \[-m\] \[-q\] \[-z\]"
			$ll insert end $line
			set line "PEAK EXTRACT          inanalfile outfile 2-4 winsiz peak floor lo hi \[-htune\] \[-a\] \[-m\] \[-q\] \[-z\] \[-f\]"
			$ll insert end $line
			if {[info exists released(spectune)]} {
				set line "SPECTUNE TUNE 1 inanalfile outfile \[-mmatch\] \[-llop\] \[-hhip\] \[-stime\] \[-etime\] \[-iintune\] \[-wwins\] \[-nnois\] \[-r\]\[-b\]\[-f\]"
				$ll insert end $line
				set line "SPECTUNE TUNE 2-3 inanalfile outfile tuning \[-mmatch\] \[-llop\] \[-hhip\] \[-stime\] \[-etime\] \[-iintune\] \[-wwins\] \[-nnois\] \[-r\]\[-b\]\[-f\]"
				$ll insert end $line
				set line "SPECTUNE TUNE 4 inanalfile \[-mmatch\] \[-llop\] \[-hhip\] \[-stime\] \[-etime\] \[-iintune\] \[-wwins\] \[-nnois\] \[-r\]\[-b\]"
				$ll insert end $line
			}
		}
		"REVECHO" {

			$ll delete 0 end
			set line "MODIFY REVECHO 1  infl outfl delay mix feedback tail \[-pprescale\] \[-i\]"
			$ll insert end $line
			set line "MODIFY REVECHO 2  infl outfl delay mix feedback lfomod lfofreq lfophase lfodelay tail \[-pprescale\] \[-sseed\]"
			$ll insert end $line
			if {$modify_version > 7} {
				set line "MODIFY REVECHO 3 infl outfl \[-ggain\] \[-rroll_off\] \[-ssize\] \[-ecount\] \[-n\]"
			} else {
				set line "MODIFY REVECHO 3 infl outfl \[-ggain\] \[-rroll_off\] \[-ssize\] \[-ecount\]"
			}
			$ll insert end $line
			set line "(1) standard delay : with feedback, & mix (0=dry) of original & delayed signal."
			$ll insert end $line
			set line "(2) varying delay : with low frequency oscillator varying delay time."
			$ll insert end $line
			set line "(3) stadium echo : create stadium p.a. type echos."
			$ll insert end $line
			set line "ECHO ECHO  infile outfile delay attenuation totaldur \[-rrand\] \[-ccut_off\]"
			$ll insert end $line
			set line "NEWDELAY NEWDELAY 1 infile outfile midipitch mix feedback"
			$ll insert end $line
			set line "NEWDELAY NEWDELAY 2 infile outfile midipitch headend pmult \[-rrand\] \[-ddip\] \[-mmid\]"
			$ll insert end $line
		}
		"RHYTHM" {

			set line "EXTEND SEQUENCE infil outfile sequence-file attenuation"
			$ll insert end $line
			set line "EXTEND SEQUENCE2 infil1 \[infil2....\] outfile sequence-file attenuation"
			$ll insert end $line
	    	set line "RETIME RETIME 1 infile outfile refpoints tempo"
			$ll insert end $line
	    	set line "RETIME RETIME 2 infile outfile resyncdata tempo peakwidth splicelen"
			$ll insert end $line
	    	set line "RETIME RETIME 3 infile outfile minsil inpkwidth outpkwidth splicelen"
			$ll insert end $line
	    	set line "RETIME RETIME 4 infile outfile tempo minsil pregain"
			$ll insert end $line
	    	set line "RETIME RETIME 5 infile outfile factor minsil \[-sstart -eend -async\]"
			$ll insert end $line
	    	set line "RETIME RETIME 6 infile outfile retempodata tempo offset minsil pregain"
			$ll insert end $line
	    	set line "RETIME RETIME 7 infile outfile retempodata offset minsil pregain"
			$ll insert end $line
	    	set line "RETIME RETIME 8 infile outfile tempo eventtime beats repeats minsil"
			$ll insert end $line
	    	set line "RETIME RETIME 9 infile outfile maskdata minsil"
			$ll insert end $line
	    	set line "RETIME RETIME 10 infile outfile equalise minsil \[-mmeter -ppregain\]"
			$ll insert end $line
	    	set line "RETIME RETIME 11 infile"
			$ll insert end $line
	    	set line "RETIME RETIME 12 infile outfile.txt"
			$ll insert end $line
	    	set line "RETIME RETIME 13 infile outfile newpeaktime"
			$ll insert end $line
	    	set line "RETIME RETIME 14 infile outfile newpeaktime origpeaktime"
			$ll insert end $line
	    	set line "CERACU CERACU infile outfile cyclecnts mindur outchans timelimit \[-o\] \[-l\]"
			$ll insert end $line
	    	set line "MADRID MADRID 1 infile \[infile2 ....\] dur ochans strmcnt delfact step rand \[-e\] \[-l\] \[-r|-R\]"
			$ll insert end $line
	    	set line "MADRID MADRID 2 infile1 infile2 \[infile23 ....\] sequencedata dur ochans strmcnt delfact step rand \[-e\] \[-l\]"
			$ll insert end $line
	    	set line "SHIFTER SHIFTER 1 infile cycles cycdur dur ochans linger transit \[-z|-r\] \[-l\]"
			$ll insert end $line
	    	set line "SHIFTER SHIFTER 2 infile1 infile2 \[infile3 ....\] cycles cycdur dur ochans linger transit \[-z|-r\] \[-l\]"
			$ll insert end $line
		}
		"SFEDIT" {

			$ll delete 0 end
			set line "SFEDIT CUT 1-3       infile outfile start end \[-wsplice\]"
			$ll insert end $line
			set line "SFEDIT CUTEND 1-3    infile outfile length \[-wsplice\]"
			$ll insert end $line
	    	set line "SFEDIT ZCUT 1-2      infile outfile start end"
			$ll insert end $line
	    	set line "SFEDIT ZCUTS 1-2      infile outfile cuttimes"
			$ll insert end $line
	    	set line "ISOLATE ISOLATE  1-2  inf outfnam cuttimes \[-ssplice\] \[-x\] \[-r\]"
			$ll insert end $line
	    	set line "ISOLATE ISOLATE  3    inf outfnam dBon dBoff \[-ssplice\] \[-mmin\] \[-llen\] \[-x\] \[-r\]"
			$ll insert end $line
	    	set line "ISOLATE ISOLATE  4    inf outfnam slicetimes \[-ssplice\] \[-x\] \[-r\]"
			$ll insert end $line
	    	set line "ISOLATE ISOLATE  5    inf outfnam slicetimes \[-ssplice\] \[-ddovetail\] \[-x\] \[-r\]"
			$ll insert end $line
	    	set line "REJOIN REJOIN 1-2    infile1 infile2 \[infile3...\] outfile \[-ggain\] \[-r\]"
			$ll insert end $line
	    	set line "PACKET PACKET 1-2    infile1 outfile(s) time(s) duration squeeze centring \[-n|-f\]"
			$ll insert end $line
			set line "SFEDIT EXCISE 1-3    infile outfile start end \[-wsplice\]"
			$ll insert end $line
	    	set line "SFEDIT EXCISES 1-3   infile outfile excisefile \[-wsplice\]"
			$ll insert end $line
			set line "SFEDIT INSERT 1-3    infile insert outfile time \[-wsplice\] \[-llevel\] \[-o\]"
			$ll insert end $line
			set line "SFEDIT INSIL 1-3     infile outfile time duration \[-wsplice\] \[-o\]"
			$ll insert end $line
			if {[info exists released(silend)]} {
				set line "SILEND SILEND  1   infile outfile  pad-duration"
				$ll insert end $line
				set line "SILEND SILEND  2   infile outfile  outfile-duration"
				$ll insert end $line
			}
	    	set line "SFEDIT MASKS 1-3     infile outfile excisefile \[-wsplice\]"
			$ll insert end $line
			set line "(1) Time in seconds."
			$ll insert end $line
			set line "(2) Time as sample count (rounded to multiples of channel-cnt)."
			$ll insert end $line
			set line "(3) Time as grouped-sample count (e.g. 3 = 3 stereo-pairs)."
			$ll insert end $line
			set line "SFEDIT JOIN          infile1 \[infile2 infile3....\] outfile \[-wsplice\] \[-b\] \[-e\] "
			$ll insert end $line
			set line "SFEDIT RANDCHUNKS    infile outfilename chunkcnt minchunk \[-mmaxchunk] \[-l\] \[-s\]"
			$ll insert end $line
			set line "SFEDIT RANDCUTS      infile average-chunklen scattering"
			$ll insert end $line
	    	set line "SFEDIT TWIXT 1-4     infile(s) outfile switch-times splicelen (segcnt) \[-wweight\] \[-r\]"
			$ll insert end $line
			set line "Imagine all files are running in parallel on a multitrack."
			$ll insert end $line
			set line "(1) In Sequence   Switch from one to another at switch-times."
			$ll insert end $line
			set line "(2) Permuted      Switch similarly, but with time-segment order randomly permuted."
			$ll insert end $line
			set line "(3) Random Choice Switch similarly, but chose any time-segment, at random, as next segment."
			$ll insert end $line
			set line "(4) Edit only     Cuts 1st file (only) into chunks defined by switch-times, outputting as separate files."
			$ll insert end $line
	    	set line "SFEDIT SPHINX 1-4    infile(s) outfile switch-times splicelen (segcnt) \[-wweight -r\]"
			$ll insert end $line
			set line "Imagine all files are running in parallel on a multitrack."
			$ll insert end $line
			set line "(1) In Sequence    Switch from one to another at switch-times."
			$ll insert end $line
			set line "                  where Nth switch-time in one file, corresponds to Nth in another file."
			$ll insert end $line
			set line "                  but these are not necessarily the same absolute time."
			$ll insert end $line
			set line "(2) Permuted       Switch similarly, but with time-segment order randomly permuted."
			$ll insert end $line
			set line "(3) Random Choice  Switch similarly, but chose any time-segment, at random, as next segment."
			$ll insert end $line
	    	set line "SFEDIT CUTMANY 1-3    infile outfile cuttimes \[-wsplice\]"
			$ll insert end $line
	    	set line "CONSTRICT CONSTRICT infile outfile decimation"
			$ll insert end $line
	    	set line "PARTITION PARTITION 1 infile groupoutname outcnt wavesetcnt"
			$ll insert end $line
	    	set line "PARTITION PARTITION 2 infile groupoutname outcnt duration \[-rrand\] \[-ssplice\] "
			$ll insert end $line
			if {[info exists released(distcut)]} {
				set line "DISTCUT DISTCUT 1 infile generic_outfilename cyclecnt exp \[-climit\]"
				$ll insert end $line
				set line "DISTCUT DISTCUT 2 infile generic_outfilename cyclecnt cyclestep exp \[-climit\]"
				$ll insert end $line
			}
			if {[info exists released(envcut)]} {
				set line "ENVCUT ENVCUT 1 infile generic_outfilename cyclecnt attack exp \[-climit\]"
				$ll insert end $line
				set line "ENVCUT ENVCUT 2 infile generic_outfilename cyclecnt cyclestep attack exp \[-climit\]"
				$ll insert end $line
			}
		}
		"SNDINFO" {
						 
			$ll delete 0 end
	    	set line "SNDINFO PROPS      infile"
			$ll insert end $line
	    	set line "SNDINFO LEN        infile"
			$ll insert end $line
	    	set line "SNDINFO LENS       infile \[infile2..\]"
			$ll insert end $line
	    	set line "SNDINFO SUMLEN     infile infile2 \[infile3..\] \[-ssplicelen\]"
			$ll insert end $line
	    	set line "SNDINFO TIMEDIFF   infile1 infile2"
			$ll insert end $line
	    	set line "SNDINFO SMPTIME    infile samplecnt \[-g\]"
			$ll insert end $line
	    	set line "SNDINFO TIMESMP    infile time \[-g\]"
			$ll insert end $line
	    	set line "SNDINFO MAXSAMP    infile \[-f\]"
			$ll insert end $line
	    	set line "SNDINFO MAXSAMP2   infile starttime endtime"
			$ll insert end $line
	    	set line "SNDINFO LOUDCHAN   infile"
			$ll insert end $line
	    	set line "SNDINFO FINDHOLE   infile \[-tthreshold\]"
			$ll insert end $line
	    	set line "SNDINFO DIFF       infile1 infile2 \[-tthreshold\] \[-ncnt\] \[-l\] \[-c\]"
			$ll insert end $line
		    set line "SNDINFO CHANDIFF   infile \[-tthreshold\] \[-ncnt\]"
			$ll insert end $line
		    set line "SNDINFO PRNTSND    infile outtextfile starttime endtime"
			$ll insert end $line
	    	set line "SNDINFO MAXI       infile \[infile2..\] outfile"
			$ll insert end $line
	    	set line "SNDINFO ZCROSS     infile \[-sstarttime -eendtime\]"
			$ll insert end $line
	    	set line "SUBTRACT SUBTRACT  infile1 infile2 \[-cchannel\]"
			$ll insert end $line
		}
		"SPACE" {

			$ll delete 0 end
			set line "MODIFY SPACE 1      infile outfile pan \[-pprescale\]"
			$ll insert end $line
			set line "MODIFY SPACE 2      infile outfile"
			$ll insert end $line
			set line "MODIFY SPACE 3      infile outfile"		
			$ll insert end $line
			set line "MODIFY SPACE 4      infile outfile narrowing"
			$ll insert end $line
			set line "(1) pan"
			$ll insert end $line
			set line "(2) mirror:      invert stereo positions in a stereo file."
			$ll insert end $line
			set line "(3) mirrorpan:   invert stereo positions in a pan data file."
			$ll insert end $line
			set line "(4) narrow"
			$ll insert end $line
			set line "MODIFY SPACEFORM  outpanfile cyclelen width dur quantisation phase"
			$ll insert end $line
			set line "MODIFY FINDPAN infile time"
			$ll insert end $line
			set line "MODIFY SCALEDPAN infile outfile pan \[-pprescale\]"
			$ll insert end $line
			set line "PANORAMA PANORAMA  infile1 infile2 \[infile3 ....\] outmix lspkr_cnt lspkr_width width offset config \[-rrand\] \[-p\] \[-q\]"
			$ll insert end $line
			set line "PANORAMA PANORAMA  infile1 infile2 \[infile3 ....\] lspkr_positions width offset config \[-rrand\] \[-p\] \[-q\]"
			$ll insert end $line
			set line "TANGENT ONEFILE 1 infile outfile dur steps maxangle dec \[-ffoc\] \[-jjitter\] \[-sslow\] \[-r\] \[-l\]"
			$ll insert end $line
			set line "TANGENT ONEFILE 2 infile outfile dur steps skew dec \[-ffoc\] \[-jjitter\] \[-r\] \[-l\]"
			$ll insert end $line
			set line "TANGENT TWOFILES 1 infile1 infile2 outfile dur steps maxangle dec bal \[-ffoc\] \[-jjitter\] \[-sslow\] \[-r\] \[-l\]"
			$ll insert end $line
			set line "TANGENT TWOFILES 2 infile1 infile2 outfile dur steps skew dec bal \[-ffoc\] \[-jjitter\] \[-r\] \[-l\]"
			$ll insert end $line
			set line "TANGENT SEQUENCE 1 infile1 infile2 \[infile3..\] outfile dur maxangle dec \[-ffoc\] \[-jjitter\] \[-sslow\] \[-r\] \[-l\]"
			$ll insert end $line
			set line "TANGENT SEQUENCE 2 infile1 infile2 \[infile3..\] outfile dur skew dec \[-ffoc\] \[-jjitter\] \[-r\] \[-l\]"
			$ll insert end $line
			set line "TANGENT LIST 1 sndlist outfile dur maxangle dec \[-ffoc\] \[-jjitter\] \[-sslow\] \[-r\] \[-l\]"
			$ll insert end $line
			set line "TANGENT LIST 2 sndlist outfile dur skew dec \[-ffoc\] \[-jjitter\] \[-r\] \[-l\]"
			$ll insert end $line
			set line "TRANSIT SIMPLE 1-5 infile outfile focus dur steps max dec \[-tthres -dlim -etlim -mmaxdur\] \[-l\]"
			$ll insert end $line
			set line "TRANSIT FILTERED 1-5 infile1 infile2 outfile focus dur steps max dec \[-tthres -dlim -etlim -mmaxdur\] \[-l\]"
			$ll insert end $line
			set line "TRANSIT DOPPLER 1-5 infile1 infile2 \[infile3 ....\] outfile focus dur steps max dec \[-tthres -dlim -etlim -mmaxdur\] \[-l\]"
			$ll insert end $line
			set line "TRANSIT DOPLFILT 1-5 inf1 inf2 inf3 inf4 \[inf5 ....\] outfile focus dur steps max dec \[-tthres -dlim -etlim -mmaxdur\] \[-l\]"
			$ll insert end $line
			set line "TRANSIT SEQUENCE 1-5 inf1 inf2 inf3 \[inf4 ....\] outfile focus dur max dec \[-l\]"
			$ll insert end $line
			set line "TRANSIT LIST 1-5 sndlist outfile focus dur max dec \[-l\]"
			$ll insert end $line
			set line "\"TRANSIT\" modes are"
			$ll insert end $line
			set line "           1 : Glancing         2 : Edgewise        3 : Crossing        4 : Close          5 : Central"
			$ll insert end $line
			if {[info exists released(spin)]} {
	    		set line "SPIN STEREO 1 infile outfile rate dopplershift \[-bboost\] \[-aatten\]"
				$ll insert end $line
	    		set line "SPIN STEREO 2 infile outfile rate ochans centre dopplershift bufexpand \[-bboost\] \[-aatten\] \[-kminamp\] \[-cmaxamp\]"
				$ll insert end $line
	    		set line "SPIN STEREO 3 infile outfile rate ochans centre dopplershift bufexpand \[-bboost\] \[-aatten\] \[-kminamp\]"
				$ll insert end $line
	    		set line "SPIN QUAD 1 inf1 inf2 outfile rate ochans centre dopplershift bufexpand \[-bboost\] \[-aatten\] \[-kminamp\] \[-cmaxamp\]"
				$ll insert end $line
	    		set line "SPIN QUAD 2 inf1 inf2 outfile rate ochans centre dopplershift bufexpand \[-bboost\] \[-aatten\] \[-kminamp\]"
				$ll insert end $line
			}
			if {[info exists released(brownian)]} {
	    		set line "BROWNIAN MOTION 1 inf outf chans dur att dec plo phi pstart sstart step sstep tick seed \[-aarange\] \[-mminamp\] \[-saslope\] \[-ddslope\] \[-l\]\n"
				$ll insert end $line
	    		set line "BROWNIAN MOTION 2 inf outf chans dur plo phi pstart sstart step sstep tick seed \[-aarange\] \[-mminamp\] \[-l\]"
				$ll insert end $line
			}
		}
		"SPEC" {

			$ll delete 0 end
			set line "SPEC BARE       infile pitchfile outfile \[-x\]"
			$ll insert end $line
			set line "SPEC CLEAN 1-2  infile nfile       outfile skiptime \[-gnoisgain\]"
			$ll insert end $line
			set line "SPEC CLEAN 3    infile nfile       outfile freq     \[-gnoisgain\]"
			$ll insert end $line
			set line "SPEC CLEAN 4    infile nfile gfile outfile          \[-gnoisgain\]"
			$ll insert end $line
			set line "(1) delete channel from time (after skiptime) its level falls below maxlevel (*noisgain) in NFILE."
			$ll insert end $line
			set line "(2) delete channel anywhere (after skiptime) its level does falls below maxlevel (*noisgain) in NFILE."
			$ll insert end $line
			set line "(3) as (2) but only for channels of frequency > 'freq'"
			$ll insert end $line
			set line "(4) delete channel everywhere, whose GFILE level always below maxlevel (*noisgain) in NFILE."
			$ll insert end $line
			set line "SPEC CUT        infile outfile starttime endtime"
			$ll insert end $line
			set line "SPEC GAIN       infile outfile gain"
			$ll insert end $line
			set line "SPEC GRAB       infile outfile time"
			$ll insert end $line
			set line "SPEC LIMIT      infile outfile threshold"
			$ll insert end $line
			set line "SPEC MAGNIFY    infile outfile time dur"
			$ll insert end $line
			set line "ANALJOIN JOIN   inanalfile1 inanalfile2 \[inanalfile3 ....\] outanalfile"
			$ll insert end $line
		}
		"SPECINFO" {

			$ll delete 0 end
			set line "SPECINFO CHANNEL    infile frq"
			$ll insert end $line
			set line "SPECINFO FREQUENCY  infile analysis_channel_number"
			$ll insert end $line
			set line "SPECINFO LEVEL      infile outsndfile"
			$ll insert end $line
			set line "SPECINFO OCTVU      infile outtextfile time_step \[-ffundamental\]"
			$ll insert end $line
			set line "SPECINFO PEAK       infile outtextfile \[-ccutoff_frq\] \[-ttimewindow\] \[-ffrqwindow\] \[-h\]"
			$ll insert end $line
			set line "SPECINFO PRINT      infile outtextfile time \[-wwindowcnt\]"
			$ll insert end $line
			set line "SPECINFO REPORT 1-4 infile outfile -fN|-pN \[-i\] pks \[-bbt\] \[-ttp\] \[-sval\]"
			$ll insert end $line
			set line "(1) Report on spectral peaks."
			$ll insert end $line
			set line "(2) Report spectral peaks in loudness order."
			$ll insert end $line
			set line "(3) Report spectral peaks as frq only (no time data)."
			$ll insert end $line
			set line "(4) Report spectral peaks in loudness order, as frq only (no time data)."
			$ll insert end $line
			set line "SPECINFO WINDOWCNT  infile"
			$ll insert end $line
		}
		"STRANGE" {

			$ll delete 0 end
			set line "STRANGE GLIS 1     infile outfile -fN|-pN \[-i\] glisrate        \[-ttopfrq\] "
			$ll insert end $line
			set line "STRANGE GLIS 2     infile outfile -fN|-pN \[-i\] glisrate hzstep \[-ttopfrq\] "
			$ll insert end $line
			set line "STRANGE GLIS 3     infile outfile -fN|-pN \[-i\] glisrate        \[-ttopfrq\] "
			$ll insert end $line
			set line "(1) shepard tones."
			$ll insert end $line
			set line "(2) inharmonic glide."
			$ll insert end $line
			set line "(3) self-glissando."
			$ll insert end $line
			set line "STRANGE INVERT 1-2 infile outfile"
			$ll insert end $line
			set line "(1) Normal inversion."
			$ll insert end $line
			set line "(2) Output sound retains amplitude envelope of source sound."
			$ll insert end $line
			set line "STRANGE SHIFT 1    infile outfile frqshift               \[-l\]"
			$ll insert end $line
			set line "STRANGE SHIFT 2-3  infile outfile frqshift frq_divide    \[-l\]"
			$ll insert end $line
			set line "STRANGE SHIFT 4-5  infile outfile frqshift frqlo   frqhi \[-l\]"
			$ll insert end $line
			set line "(1) Shift the whole spectrum."
			$ll insert end $line
			set line "(2) Shift the spectrum above frq_divide."
			$ll insert end $line
			set line "(3) Shift the spectrum below frq_divide."
			$ll insert end $line
			set line "(4) Shift the spectrum only in the range frqlo and frqhi."
			$ll insert end $line
			set line "(5) Shift the spectrum outside the range  frqlo to frqhi."
			$ll insert end $line
			set line "STRANGE WAVER 1    infile outfile vibfrq stretch botfrq"
			$ll insert end $line
			set line "STRANGE WAVER 2    infile outfile vibfrq stretch botfrq expon"
			$ll insert end $line
			set line "(1) Standard spectral stretching for inharmonic state."
			$ll insert end $line
			set line "(2) Specify spectral stretching for inharmonic state."
			$ll insert end $line
			set line "SPECGRIDS SPECGRIDS inanalfile generic-outname outfilecnt gridblockcnt"
			$ll insert end $line
			if {[info exists released(speculate)]} {
				set line "SPECULATE SPECULATE inanalfile generic-outname minfrq maxfrq \[-r\]"
				$ll insert end $line
			}
			if {[info exists released(specfold)]} {
	    		set line "SPECFOLD SPECFOLD 1 inanalfile outanalfile foldstart len cnt \[-a\]"
				$ll insert end $line
	    		set line "SPECFOLD SPECFOLD 2 inanalfile outanalfile foldstart len \[-a\]"
				$ll insert end $line
	    		set line "SPECFOLD SPECFOLD 3 inanalfile outanalfile foldstart len seed \[-a\]"
				$ll insert end $line
			}
		}
		"STRETCH" {

			$ll delete 0 end
			set line "STRETCH SPECTRUM 1-2 infile outfile frq_divide maxstretch exponent \[-ddepth\]"
			$ll insert end $line
			set line "(1) Stretch above the frq_divide."
			$ll insert end $line
			set line "(2) Stretch below the frq_divide."
			$ll insert end $line
			set line "STRETCH TIME 1 infile outfile timestretch"
			$ll insert end $line
			set line "STRETCH TIME 2 infile timestretch"
			$ll insert end $line
			set line "(2) program calculates length of output, only."
			$ll insert end $line
		}
		"SUBMIX" {

			$ll delete 0 end
			set line "SUBMIX ATTENUATE      inmixfile outmixfile gainval \[-sstartline\] \[-eendline\]"
			$ll insert end $line
	    	set line "SUBMIX DUMMY 1-2      infile1 infile2 \[infile3..\] mixfile"
			$ll insert end $line
			set line "(1) all files start at time zero."
			$ll insert end $line
			set line "(2) each file starts where previous file ends."
			$ll insert end $line
	    	set line "SUBMIX GETLEVEL 1     mixfile             \[-sSTART\] \[-eEND\]"
			$ll insert end $line
	    	set line "SUBMIX GETLEVEL 2-3   mixfile outtextfile \[-sSTART\] \[-eEND\]"
			$ll insert end $line
	    	set line "(1) finds maximum level of mix."
			$ll insert end $line
	    	set line "(2) finds locations of clipping in mix."
			$ll insert end $line
	    	set line "(3) finds locations of clipping, and maxlevel, in mix."
			$ll insert end $line
			set line "SUBMIX INBETWEEN 1    infile1  infile2  outname  count"
			$ll insert end $line
			set line "SUBMIX INBETWEEN 2    infile1  infile2  outname  ratios"
			$ll insert end $line
			set line "SUBMIX MERGE          sndfile1 sndfile2 outfile \[-sstagger\] \[-jskip\] \[-kskew\]  \[-bstart\] \[-eend\]"
			$ll insert end $line
			set line "SUBMIX BALANCE        sndfile1 sndfile2 outfile \[-sbalance\] \[-bstart\] \[-eend\]"
			$ll insert end $line
	    	set line "SUBMIX MIX            mixfile outsndfile \[-sSTART\] \[-eEND\] \[-gATTENUATION\] \[-a\]"
			$ll insert end $line
			set line "SUBMIX SHUFFLE 1-6    inmixfile outmixfile         \[-sstartl\] \[-eendl\]"
			$ll insert end $line
			set line "SUBMIX SHUFFLE 7      inmixfile outmixfile newname \[-sstartl\] \[-eendl\] \[-x\]"
			$ll insert end $line
			set line "(1)  duplicate each line."
			$ll insert end $line
			set line "(2)  reverse order of filenames."
			$ll insert end $line
			set line "(3)  scatter order of filenames."
			$ll insert end $line
			set line "(4)  replace sounds in selected lines with sound in startline."
			$ll insert end $line
			set line "(5)  omit lines           (closing up timegaps appropriately : mix must be in correct time order)"
			$ll insert end $line
			set line "(6)  omit alternate lines (closing up timegaps appropriately : mix must be in correct time order)"
			$ll insert end $line
			set line "(7)  duplicate and rename: duplicate each line with new sound"
			$ll insert end $line
			set line "SUBMIX SPACEWARP 1-2  inmixfile outmixfile q     \[-sstartl\] \[-eendl\]"
			$ll insert end $line
			set line "SUBMIX SPACEWARP 3-6  inmixfile outmixfile q1 q2 \[-sstartl\] \[-eendl\]"
			$ll insert end $line
			set line "SUBMIX SPACEWARP 7    inmixfile outmixfile"
			$ll insert end $line
			set line "SUBMIX SPACEWARP 8    inmixfile outmixfile q"
			$ll insert end $line
			set line "(1) sounds to same position : q is position. (stereo files become mono)"
			$ll insert end $line
			set line "(2) narrow spatial spread : q is a +ve number < 1.0"
			$ll insert end $line
			set line "(3) sequence positions leftwards : over range q1-q2 (stereo files become mono)"
			$ll insert end $line
			set line "(4) sequence positions rightwards : over range q1-q2 (stereo files become mono)"
			$ll insert end $line
			set line "(5) random-scatter positions : within range q1-q2 (stereo files become mono)"
			$ll insert end $line
			set line "(6) random, but alternate to l/r of centre of spatial range (q1-q2) specified.(stereo files become mono)"
			$ll insert end $line
			set line "(7) invert stereo in alternate lines of mixfile: (use to avoid clipping)."
			$ll insert end $line
			set line "(8) invert stereo in specified line of mixfile : q is line number."
			$ll insert end $line
			set line "SUBMIX SYNC 1-2       intextfile outmixfile"
			$ll insert end $line
			set line "(1) sync sndfile midtimes."		
			$ll insert end $line
			set line "(2) sync sndfile endtimes."
			$ll insert end $line
			set line "SUBMIX SYNCATTACK     intextfile outmixfile  \[-wdiv\] \[-p\]"
			$ll insert end $line
	    	set line "SUBMIX TEST           mixfile"
			$ll insert end $line
			set line "SUBMIX TIMEWARP 1     inmixfile outmixfile"
			$ll insert end $line
			set line "SUBMIX TIMEWARP 2-5   inmixfile outmixfile   \[-sstartline\] \[-eendline\]"
			$ll insert end $line
			set line "SUBMIX TIMEWARP 6-16  inmixfile outmixfile q \[-sstartline\] \[-eendline\]"
			$ll insert end $line
			set line "(1)  sort into time order."
			$ll insert end $line
			set line "(2)  reverse timing pattern:  e.g. rit. of sound entries becomes an accel."
			$ll insert end $line
			set line "(3)  reverse timing pattern & order of filenames."
			$ll insert end $line
			set line "(4)  freeze timegaps          between sounds, at first timegap value."
			$ll insert end $line
			set line "(5)  freeze timegaps & names  ditto, and all files take firstfile name."
			$ll insert end $line
			set line "(6)  scatter entry times      about orig vals. q is scattering: range(0-1)."
			$ll insert end $line
			set line "(7)  shuffle up entry times   shuffle times in file forward by time q secs."
			$ll insert end $line
			set line "(8)  add to timegaps          add fixed val q secs, to timegaps between sounds."
			$ll insert end $line
			set line "(9)  create fixed timegaps 1  between all sounds,timegap = q secs"
			$ll insert end $line
			set line "(10) create fixed timegaps 2  startval+q,startval+2q  etc"
			$ll insert end $line
			set line "(11) create fixed timegaps 3  startval*q startval*2q etc"
			$ll insert end $line
			set line "(12) create fixed timegaps 4  startval*q     startval*q*q    etc"
			$ll insert end $line
			set line "(13) enlarge timegaps 1       multiply them by q."
			$ll insert end $line
			set line "(14) enlarge timegaps 2       by +q, +2q,+3q  etc"
			$ll insert end $line
			set line "(15) enlarge timegaps 3       by *q *2q *3q"
			$ll insert end $line
			set line "(16) enlarge timegaps 4       by *q, *q*q, *q*q*q  etc. (care!!)"
			$ll insert end $line
			set line "SUBMIX CROSSFADE 1    sndfile1 sndfile2 outfile \[-sSTAGGER\] \[-bBEGIN\] \[-eEND\]"
			$ll insert end $line
			set line "SUBMIX CROSSFADE 2    sndfile1 sndfile2 outfile \[-sSTAGGER\] \[-bBEGIN\] \[-eEND\] \[-pPOWFAC\]"
			$ll insert end $line
			set line "(1) Linear crossfade."
			$ll insert end $line
			set line "(2) Cosinusiodal crossfade"
			$ll insert end $line
		}
		"SYNTH" {

			$ll delete 0 end
			set line "SYNTH NOISE outfile sr chans dur \[-aamp\]"
			$ll insert end $line
			set line "SYNTH SILENCE outfile sr chans dur"
			$ll insert end $line
			set line "SYNTH SPECTRA outfilename dur frq spread max-foc min-foc timevar srate \[-p\]"
			$ll insert end $line
			set line "SYNTH CHORD 1-2 outfile datafile sr chans dur \[-aamp\] \[-ttabsize\]"
			$ll insert end $line
			set line "(1) MIDI data"
			$ll insert end $line
			set line "(2) frequency data"
			$ll insert end $line
			set line "SYNTH WAVE 1-4 outfile sr chans dur freq \[-aamp\] \[-ttabsize\]"
			$ll insert end $line
			set line "(1) sine wave"
			$ll insert end $line
			set line "(2) square wave"
			$ll insert end $line
			set line "(3) sawtooth wave"
			$ll insert end $line
			set line "(4) ramp wave"
			$ll insert end $line
			set line "NEWSYNTH SYNTHESIS 1 outfile partials-data sr dur freq"
			$ll insert end $line
			set line "NEWSYNTH SYNTHESIS 2 outfile partials-data sr dur freq \[-nnarrowing\] \[-ccentring\] \[-f\]"
			$ll insert end $line
			set line "NEWSYNTH SYNTHESIS 3 outfile partials-data sr dur freq chans maxrange rate \[-urise\] \[-dfall\] \[-ssplice\] \[-m\]"
			$ll insert end $line
			set line "NEWSYNTH SYNTHESIS 4 outfile sr dur freq atk ea dec ed atoh gtow \[-fflv\] \[-rrnd|-e\]"
			$ll insert end $line
			set line "SPECTRUM LINES outfile 1 spectral-lines-data analchans sr dur harmonics rolloff datafoot datatop specfoot spectop gain warp ampwarp"
			$ll insert end $line
			set line "SPECTRUM LINES outfile 2 spectral-lines-data dur datafoot datatop specfoot spectop warp ampwarp"
			$ll insert end $line
			set line "PULSER SYNTH 1-3 outfile partials-data dur pitch minrise maxrise minsustain maxsustain mindecay maxdecay speed scatter"
			$ll insert end $line
			set line "                          \[-eexpr\] \[-Eexpd\] \[-ppscat\] \[-aascat\] \[-ooctav\] \[-bbend\] \[-sseed\] \[-r\] \[-Ssrate\]"
			$ll insert end $line
			set line "CHIRIKOV CHIRIKOV 1-2 outsndfile dur frq damping srate dovesplice"
			$ll insert end $line
			set line "CHIRIKOV CHIRIKOV 3-4 outbrkfile dur frq damping minpitch maxpitch timestep timerand"
			$ll insert end $line
			set line "MULTIOSC MULTIOSC 1 outsndfile dur frq frq2 amp2 srate dovesplice"
			$ll insert end $line
			set line "MULTIOSC MULTIOSC 2 outsndfile dur frq frq2 amp2 frq3 amp3 srate dovesplice"
			$ll insert end $line
			set line "MULTIOSC MULTIOSC 3 outsndfile dur frq frq2 amp2 frq3 amp3 frq4 amp4 srate dovesplice"
			$ll insert end $line
			set line "SYNFILT SYNFILT 1-2 outsndfile datafile srate chans Q hcnt rolloff seed \[-d\] \[-o\]"
			$ll insert end $line
			set line "STRANDS STRANDS 1-2 outfilename dur bands threads tstep bot top twist rand scat vamp vmin vmax turb \[-ggap\] \[-mminband\] \[-f3d\]"
			$ll insert end $line
			set line "STRANDS STRANDS 3 outfilename threadscntfile dur bands tstep bot top twist rand scat vamp vmin vmax turb \[-ggap\] \[-mminband\] \[-f3d\]"
			$ll insert end $line
			if {[info exists released(synspline)]} {
				set line "SYNSPLINE SYNSPLINE outfile srate dur frq splinecnt interpval seed \[-smaxspline\] \[-imaxinterp\] \[-dpdrift -vdriftrate\] \[-n\]"
				$ll insert end $line
			}
			if {[info exists released(impulse)]} {
				set line "IMPULSE IMPULSE  outfile dur pitch chirp slope peakscnt level \[-ggap\] \[-ssrate\] \[-cchans\]"
				$ll insert end $line
			}
		}
		"TEXTURE" {

			$ll delete 0 end
			set line "TEXTURE SIMPLE 1-5 infile \[infile2...\] outfile notedata outdur packing scatter"
			$ll insert end $line
			set line "             tgrid sndfirst sndlast  mingain maxgain  mindur maxdur  minpich maxpich"
			$ll insert end $line
			set line "             \[-aatten\] \[-pposition\] \[-sspread\] \[-rseed\] \[-w\] \[-c\] \[-p\]"
			$ll insert end $line
			set line "TEXTURE TIMED 1-5 infile \[infile2...\]  outfile  notedata     outdur skiptime"
			$ll insert end $line
			set line "             sndfirst sndlast mingain maxgain mindur maxdur minpitch maxpitch"
			$ll insert end $line
			set line "             \[-aatten\] \[-pposition\] \[-sspread\] \[-rseed\] \[-w\]"
			$ll insert end $line
			set line "TEXTURE GROUPED 1-5 infile \[infile2..\] outfile notedata outdur packing scatter tgrid"
			$ll insert end $line
			set line "             sndfirst sndlast mingain maxgain mindur maxdur minpitch maxpitch phgrid gpspace"
			$ll insert end $line
			set line "             gpsprange amprise contour gpsizelo gpsizehi gppaklo gppakhi gpranglo gpranghi"
			$ll insert end $line
			set line "             \[-aatten\] \[-pposition\] \[-sspread\] \[-rseed\] \[-w\] \[-d\] \[-i\]"
			$ll insert end $line
			set line "TEXTURE TGROUPED 1-5 infile \[infile2..\] outfile notedata outdur skip sndfirst sndlast"
			$ll insert end $line
			set line "             mingain maxgain mindur maxdur minpitch maxpitch phgrid gpspace gpsprange amprise contour"
			$ll insert end $line
			set line "             gpsizelo gpsizehi gppacklo gppackhi gpranglo gpranghi"
			$ll insert end $line
			set line "             \[-aatten\] \[-pposition\] \[-sspread\] \[-rseed\] \[-w\] \[-d\] \[-i\]"
			$ll insert end $line
			set line "TEXTURE DECORATED|PREDECOR|POSTDECOR 1-5 infile \[infile2..\] outfile notedata outdur skiptime"
			$ll insert end $line
			set line "             sndfirst sndlast mingain maxgain mindur maxdur phgrid gpspace gpsprange amprise contour"
			$ll insert end $line
			set line "             gpsizlo gpsizhi gppaklo gppakhi gpranglo gpranghi centring"
			$ll insert end $line
			set line "             \[-aatten\] \[-ppos\] \[-ssprd\] \[-rseed\] \[-w\] \[-d\] \[-i\] \[-h\] \[-e\] \[-k\]"
			$ll insert end $line
			set line "TEXTURE ORNATE|PREORNATE|POSTORNATE 1-5 infile \[infile2...\] outfile notedata outdur skiptime sndfirst sndlast"
			$ll insert end $line
			set line "             mingain maxgain mindur maxdur phgrid gpspace gpsprange amprise contour multlo multhi"
			$ll insert end $line
			set line "             \[-aatten\] \[-pposition\] \[-sspread\] \[-rseed\] \[-w\] \[-d\] \[-i\] \[-h\] \[-e\]"
			$ll insert end $line
			set line "TEXTURE MOTIFSIN 1-4 infile \[infile2..\] outfile notedata outdur packing scatter tgrid sndfirst sndlast mingain"
			$ll insert end $line
			set line "             maxgain mindur maxdur minpitch maxpitch phgrid gpspace gpsprange amprise  contour multlo multhi"
			$ll insert end $line
			set line "             \[-aatten\] \[-pposition\] \[-sspread\] \[-rseed\] \[-w\] \[-d\] \[-i\]"
			$ll insert end $line
			set line "TEXTURE TMOTIFSIN 1-4 infile \[infile2...\] outfile notedata sndfirst sndlast"
			$ll insert end $line
			set line "             mingain maxgain mindur maxdur minpich maxpich phgrid gpspace gpsprange"
			$ll insert end $line
			set line "             amprise contour multlo multhi \[-aatten\] \[-ppos\] \[-sspread\] \[-rseed\] \[-w\] \[-d\]"
			$ll insert end $line
			set line "TEXTURE MOTIFS 1-5 infile \[infile2...\] outfile notedata outdur packing"
			$ll insert end $line
			set line "             scatter tgrid sndfirst sndlast mingain maxgain mindur maxdur minpich maxpich"
			$ll insert end $line
			set line "             phgrid gpspace gpsprange amprise contour multlo multhi"
			$ll insert end $line
			set line "             \[-aatten\] \[-pposition\] \[-sspread\] \[-rseed\] \[-w\] \[-d\]"
			$ll insert end $line
			set line "TEXTURE TMOTIFS 1-5 infile \[infile2...\] outfile notedata outdur skip"
			$ll insert end $line
			set line "             sndfirst sndlast mingain maxgain mindur maxdur minpitch maxpitch phgrid"
			$ll insert end $line
			set line "             gpspace gpsprange amprise contour multlo multhi"
			$ll insert end $line
			set line "             \[-aatten\] \[-pposition\] \[-sspread\] \[-rseed\] \[-w\] \[-d\]"
			$ll insert end $line
			set line "(1)  on a given harmonic-field"
			$ll insert end $line
			set line "(2)  on changing harmonic-fields"
			$ll insert end $line
			set line "(3)  on a given harmonic-set"
			$ll insert end $line
			set line "(4)  on changing harmonic-sets"
			$ll insert end $line
		    set line "(5)  none"
			$ll insert end $line
			set line "TEXMCHAN TEXMCHAN 1-5 infile \[infile2...\] outfile notedata  outdur packing scatter"
			$ll insert end $line
			set line "             tgrid sndfirst sndlast  mingain maxgain  mindur maxdur minpich maxpich outchans"
			$ll insert end $line
			set line "             \[-aatten\] \[-pposition\] \[-sspread\] \[-rseed\] \[-w\] \[-c\] \[-p\] \[-f\]"
			$ll insert end $line
			set line "NEWTEX NEWTEX 1 infile outfile notedata dur chans maxrange step spacetype"
			$ll insert end $line
			set line "             \[-ssplice\] \[-nnumber\] \[-rrotspeed\] \[-efrom\] \[-Etime\] \[-cto\] \[-Ctime\] \[-x\] \[-j\]"
			$ll insert end $line
			set line "NEWTEX NEWTEX 2 infile infile2 \[infile3...\] outfile dur chans maxrange step spacetype delay"
			$ll insert end $line
			set line "             \[-ssplice\] \[-nnumber\] \[-rrotspeed\] \[-efrom\] \[-Etime\] \[-cto\] \[-Ctime\] \[-x\] \[-j\]"
			$ll insert end $line
			set line "NEWTEX NEWTEX 3 infile \[infile2...\] outfile dur chans maxrange step spacetype locus ambitus drunkstep"
			$ll insert end $line
			set line "             \[-ssplice\] \[-nnumber\] \[-rrotspeed\] \[-efrom\] \[-Etime\] \[-cto\] \[-Ctime\] \[-x\] \[-j\]"
			$ll insert end $line
		}
		"OTHER" {
			StandaloneNonCDPFormatSyntax $ll
		}
	}
}

#------- Commandline Info display

proc BatchSyntaxDisplay {} {
	global pr_bi released evv

	set f .batchsyntax
	if [Dlg_Create $f "BATCH FILE SYNTAX" "set pr_bi 1" -borderwidth $evv(SBDR)] {
		set fz [frame $f.z -borderwidth $evv(BBDR)]
		button $fz.b0 -text "Close" -command "set pr_bi 0" -highlightbackground [option get . background {}]
		label $fz.man -text "more  detailed  information  in   CDP  manual    'CCDPNDEX.HTM'" -fg $evv(SPECIAL)
		label $fz.qik -text "QUICK REFERENCE GUIDE" -bg $evv(EMPH) -fg $evv(SPECIAL)
		pack $fz.b0 $fz.qik $fz.man -side top -pady 1
		set f0 [frame $f.0 -borderwidth $evv(BBDR)]
		label $f0.ll -text "SELECT ITEM WITH MOUSE, TO TRANSFER IT TO THE BATCHFILE PAGE" 
		Scrolled_Listbox $f0.l -width 110 -height 33 -selectmode single
		pack $f0.ll -side top -fill x -expand true
		pack $f0.l -side top -fill x -expand true
		set f1 [frame $f.1 -borderwidth $evv(BBDR)]
		set f2 [frame $f.2 -borderwidth $evv(BBDR)]
		button $f1.b1 -text "BLUR" -command "BatchSyntax .batchsyntax.0.l.list BLUR" -width 14 -highlightbackground [option get . background {}]
		button $f1.b2 -text "BRASSAGE" -command "BatchSyntax .batchsyntax.0.l.list BRASSAGE" -width 14 -highlightbackground [option get . background {}]
		button $f1.b3 -text "CHANNELS" -command "BatchSyntax .batchsyntax.0.l.list CHANNELS" -width 14 -highlightbackground [option get . background {}]
		button $f1.b4 -text "COMBINE" -command "BatchSyntax .batchsyntax.0.l.list COMBINE" -width 14 -highlightbackground [option get . background {}]
		button $f1.b5 -text "DISTORT" -command "BatchSyntax .batchsyntax.0.l.list DISTORT" -width 14 -highlightbackground [option get . background {}]
		button $f1.b6 -text "EDIT" -command "BatchSyntax .batchsyntax.0.l.list SFEDIT" -width 14 -highlightbackground [option get . background {}]
		button $f1.b7 -text "ENVELOPE" -command "BatchSyntax .batchsyntax.0.l.list ENVEL" -width 14 -highlightbackground [option get . background {}]
		button $f1.b8 -text "EXTEND" -command "BatchSyntax .batchsyntax.0.l.list EXTEND" -width 14 -highlightbackground [option get . background {}]
		button $f1.b9 -text "FILTER" -command "BatchSyntax .batchsyntax.0.l.list FILTER" -width 14 -highlightbackground [option get . background {}]
		button $f1.b10 -text "FOCUS" -command "BatchSyntax .batchsyntax.0.l.list FOCUS" -width 14 -highlightbackground [option get . background {}]
		if {[info exists released(psow)]} {
			button $f1.b11 -text "FOFS" -command "BatchSyntax .batchsyntax.0.l.list FOFS" -width 14 -highlightbackground [option get . background {}]
		}
		button $f1.b12 -text "FORMANTS" -command "BatchSyntax .batchsyntax.0.l.list FORMANTS" -width 14 -highlightbackground [option get . background {}]
		button $f1.b13 -text "GRAIN" -command "BatchSyntax .batchsyntax.0.l.list GRAIN" -width 14 -highlightbackground [option get . background {}]
		button $f1.b14 -text "HARMONIC FLD" -command "BatchSyntax .batchsyntax.0.l.list HFPERM" -width 14 -highlightbackground [option get . background {}]
		button $f1.b15 -text "HIGHLIGHT" -command "BatchSyntax .batchsyntax.0.l.list HILITE" -width 14 -highlightbackground [option get . background {}]
		button $f1.b16 -text "HOUSEKEEP" -command "BatchSyntax .batchsyntax.0.l.list HOUSEKEEP" -width 14 -highlightbackground [option get . background {}]
		button $f1.b17 -text "LOUDNESS" -command "BatchSyntax .batchsyntax.0.l.list LOUDNESS" -width 14 -highlightbackground [option get . background {}]
		button $f1.b18 -text "MIX" -command "BatchSyntax .batchsyntax.0.l.list SUBMIX" -width 14 -highlightbackground [option get . background {}]
		button $f1.b18a -text "VOICEBOX" -command "BatchSyntax .batchsyntax.0.l.list VOICEBOX" -width 14
		button $f2.b19 -text "MORPH" -command "BatchSyntax .batchsyntax.0.l.list MORPH" -width 14 -highlightbackground [option get . background {}]
		if {[info exists released(newmix)]} {
			button $f2.b20 -text "MULTICHAN" -command "BatchSyntax .batchsyntax.0.l.list MULTI" -width 14 -highlightbackground [option get . background {}]
		}
		button $f2.b21 -text "PITCH:HARMONY" -command "BatchSyntax .batchsyntax.0.l.list PITCH" -width 14 -highlightbackground [option get . background {}]
		button $f2.b22 -text "PITCH:SPEED" -command "BatchSyntax .batchsyntax.0.l.list PITCHSPEED" -width 14 -highlightbackground [option get . background {}]
		button $f2.b23 -text "PITCH INFO" -command "BatchSyntax .batchsyntax.0.l.list PITCHINFO" -width 14 -highlightbackground [option get . background {}]
		button $f2.b24 -text "PVOC" -command "BatchSyntax .batchsyntax.0.l.list PVOC" -width 14 -highlightbackground [option get . background {}]
		button $f2.b25 -text "RADICAL" -command "BatchSyntax .batchsyntax.0.l.list RADICAL" -width 14 -highlightbackground [option get . background {}]
		button $f2.b26 -text "REPITCH" -command "BatchSyntax .batchsyntax.0.l.list REPITCH" -width 14 -highlightbackground [option get . background {}]
		button $f2.b27 -text "REVERB:ECHO" -command "BatchSyntax .batchsyntax.0.l.list REVECHO" -width 14 -highlightbackground [option get . background {}]
		button $f2.b27a -text "RHYTHM" -command "BatchSyntax .batchsyntax.0.l.list RHYTHM" -width 14 -highlightbackground [option get . background {}]
		button $f2.b28 -text "SIMPLE" -command "BatchSyntax .batchsyntax.0.l.list SPEC" -width 14 -highlightbackground [option get . background {}]
		button $f2.b29 -text "SOUND INFO" -command "BatchSyntax .batchsyntax.0.l.list SNDINFO" -width 14 -highlightbackground [option get . background {}]
		button $f2.b30 -text "SPACE" -command "BatchSyntax .batchsyntax.0.l.list SPACE" -width 14 -highlightbackground [option get . background {}]
		button $f2.b31 -text "SPECTRAL INFO" -command "BatchSyntax .batchsyntax.0.l.list SPECINFO" -width 14 -highlightbackground [option get . background {}]
		button $f2.b32 -text "STRANGE" -command "BatchSyntax .batchsyntax.0.l.list STRANGE" -width 14 -highlightbackground [option get . background {}]
		button $f2.b33 -text "STRETCH" -command "BatchSyntax .batchsyntax.0.l.list STRETCH" -width 14 -highlightbackground [option get . background {}]
		button $f2.b34 -text "SYNTHESIS" -command "BatchSyntax .batchsyntax.0.l.list SYNTH" -width 14 -highlightbackground [option get . background {}]
		button $f2.b35 -text "TEXTURE" -command "BatchSyntax .batchsyntax.0.l.list TEXTURE" -width 14 -highlightbackground [option get . background {}]
		button $f2.b36 -text "OTHER" -command "BatchSyntax .batchsyntax.0.l.list OTHER" -width 14 -highlightbackground [option get . background {}]

		pack $f1.b1  $f1.b2  $f1.b3  $f1.b4  $f1.b5  $f1.b6  $f1.b7  $f1.b8  $f1.b9 $f1.b10 -side top
		if {[info exists released(psow)]} {
			pack $f1.b11 -side top
		}
		pack $f1.b12 $f1.b13 $f1.b14 $f1.b15 $f1.b16 $f1.b17 $f1.b18 -side top
		if {[info exists released(specfnu)]} {
			pack $f1.b18a -side top
		}
		pack $f2.b19 -side top
		if {[info exists released(newmix)]} {
			pack $f2.b20 -side top
		}
		pack $f2.b21 $f2.b22 $f2.b23 $f2.b24 $f2.b25 $f2.b26 $f2.b27 $f2.b27a -side top
		pack $f2.b28 $f2.b29 $f2.b30 $f2.b31 $f2.b32 $f2.b33 $f2.b34 $f2.b35 $f2.b36 -side top
		pack $f.z -side top -fill x -expand true
		pack $f.0 $f.1 $f2 -side left
		bind $f.0.l.list <ButtonRelease> "GrabSynLine %y"
		bind $f <Return> {set pr_bi 1}
		bind $f <Escape> {set pr_bi 1}
		bind $f <Key-space>  {set pr_bi 1}
		wm resizable $f 1 1
	}
	set pr_bi 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_bi
	tkwait variable pr_bi
	My_Release_to_Dialog .batchsyntax
	catch {destroy .batchsyntax}
}

proc ExistingFilesAreDeleted {} {
	global batch_file evv

	foreach line $batch_file {

		if {[string last " " $line] < 0} {
			continue
		}
		set zz 1
		set OK 1
		catch {unset word}
		set rest $line
		while {$OK} {
			set k [string first " " $rest]
			if {$k < 0} {
				set word($zz) $rest
				break
			}
			incr k -1
			set word($zz) [string range $rest 0 $k]
			incr k 2
			set rest [string range $rest $k end] 
			incr zz
		}
		if {[string match "rm" $word(1)] || [string match "rmsf" $word(1)]} {
			if {![info exists word(2)] || [info exists word(3)]} {
				Inf "Bad syntax in line '$line'"
				return 1
			}
			if [file exists $word(2)] {
				Inf "The Line:\n'$line'\nWould Delete The Pre-existing File '$word(2)'\nCannot Proceed"
				return 1
			}
		}
		if {[string match "housekeep" $word(1)] && [string match "remove" $word(2)]} {
			if {![info exists word(3)]} {
				Inf "Bad syntax in line '$line'"
				return 1
			}
			set fnam $word(3)
			set len [string length $fnam]
			append fnam "_"
			incr len
 			foreach ffnam [glob -nocomplain $fnam*] {
				set zfnam [file rootname [file tail $ffnam]]
				set zfnam [string range $zfnam $len end]
				if {([string length $zfnam] == 3) && [regexp {^[0-9]+$} $zfnam]} {
					Inf "The Line:\n'$line'\nCould Possibly Delete The Pre-existing File '$ffnam'\nCannot Proceed"
					return 1
				}
			}						
		}
	}

	return 0
}

#------ Convert a Patch into a batchfile

proc Patch_to_Batch {patch_ext do_append using_outname} {
	global evv prg pprg mmod ins chlist papag wstk wl excluded_batchfiles CDP_cmd rememd
	global prm new_patchname pmcnt ppg patchparam cur_patch_display sl_real nu_names
	global float_out standopos filter_version

	if {!$sl_real} {
		Inf "The Commandline For The Process You Have Just Set Up\nCan Be Saved As A Batchfile\n\nBatchfiles Can Be Run From The Workspace Page."
		Inf "Saving The Commandline In This Way Can Be Useful\nIf You Want To Set Up\nA 'Vectored Batchfile',\nIn Which The Same Process Is Applied To The Same File\n(Or To A List Of Different Files)\nWith Different Values Of A Parameter For Each Process Run.\n\nSuch Vectored Batchfiles Can Be Created\nFrom A Single Batchfile\nAnd A Parameter Vector (a List Of Values)\nUsing Special Routines On The Table Editor."
		return
	}
	if {$using_outname} {
		if {![ProcessHasSingleOutfile $pprg $mmod]} {
			Inf "This Process Does Not Have A Single Outfile"
			return
		}
	}	
	set pcnt 0
	while {$pcnt < $pmcnt} {
 		if {[string match {\*} $prm($pcnt)]} {
			Inf "You Cannot Store Processes With A \"*\" Parameter Value"
			return
		}
		incr pcnt
	}
	set has_outfilename [ProcessHasAnOutfile $pprg $mmod]
	set existingcnt -1
	set  file_exists 0

	if {[IsStandalonePrognoWithNonCDPFormat $pprg]} {
		if {[IsMchanToolkit $pprg]} {
			if {$do_append >= 0} {
				Inf "Operation Not Available With Multichannel Toolkit Processes"
				return
			} else {
				Inf "Command Line is\n\n$CDP_cmd"
				return
			}
		}
		if {![info exists CDP_cmd]} {
			Inf "Cannot Find The Commandline"
			return
		}
		set cmd [file tail [lindex $CDP_cmd 0]]
		foreach item [lrange $CDP_cmd 1 end] {
			lappend cmd $item
		}
		if {$standopos > 0} {
			set out_name "#"		;#	temporary, until real name is known, below
			set cmd [lreplace $cmd $standopos $standopos $out_name]
		}
	} else {
		if {$ins(create)} {
			if [info exists ins(chlist)] {
				set thischosenlist "$ins(chlist)"
			}
		} else {
			if [info exists chlist] {
				set thischosenlist "$chlist"
			}
		}
		set cmdcnt 0
		set cmd [string tolower [lindex $prg($pprg) $evv(UMBREL_INDX)]]
		incr cmdcnt
		set progname [GetBatchProgname $pprg]
		lappend cmd $progname								;#	Program number
		incr cmdcnt
		if {$mmod > 0} {
			lappend cmd $mmod		 						;#	Mode number
			incr cmdcnt
		}
		if [info exists thischosenlist] {
			set infilecnt [llength $thischosenlist]			;#	Number of input files 
		} else {
			set infilecnt 0
		}
		if {$infilecnt > 0} {								;#	If there are any infiles
			foreach fnam [lrange $thischosenlist 0  end] { 	;# 	And Names of all the input files
				lappend cmd $fnam
				incr cmdcnt
			}
		}
		if {$do_append < 0} {
			if {$pprg == $evv(HOUSE_CHANS) && (($mmod == 1) || ($mmod == 2))} {
				;#
			} elseif {$has_outfilename} {
				if {$float_out} {
					set out_name "-foutfile"
				} else {
					set out_name "outfile"
				}
				lappend cmd $out_name								
				if {$pprg == $evv(PITCH)} {
					lappend cmd $out_name								
				}
			}
		} elseif {$has_outfilename} {
			set out_name "#"		;#	temporary, until real name is known, below
			if {![IsMultipleCopy]} {
				lappend cmd $out_name								
			}
			if {$pprg == $evv(PITCH)} {
				lappend cmd $out_name								
			}
		}
		if {$pmcnt > 0} {
			lappend cmd $prm(0)					;#	Attach all prm values onto end of cmdline
			set i 1
			while {$i < $pmcnt} {
 				lappend cmd $prm($i)
				incr i
			}
		}
		if {$pprg == $evv(FLTBANKV)} {		;#	Extra SLOOM Param from dropout on overflow, lose it for batchfiling
			set len [llength $cmd]
			if {$filter_version < 7} {
				incr len -3
				set cmd [lrange $cmd 0 $len]
			}
		}
		set cmd [SetupBatchcmdFlagLetters $cmd]
		set cmd [SetupFormantFlagLettersEtc $cmd]
	}
	if {[llength $cmd] <= 0} {
		return
	}
	if {$do_append < 0} {
		set clen [llength $cmd]
		set n 0
		while {$n < $clen} {
			set item [lindex $cmd $n]
			if {[string match $item "#"]} {
				if {$float_out} {
					set cmd [lreplace $cmd $n $n "-foutfile"]
				} else {
					set cmd [lreplace $cmd $n $n "outfile"]
				}
			}
			incr n
		}
		Inf "Command Line is\n\n$cmd"
		return
	}
	;#	GET AND TEST BATCHFILE NAME
	set new_patchname [string tolower $new_patchname]
	set thisname [FixTxt $new_patchname "batchfile name"]
	if {[string length $thisname] <= 0} {
		return
	}
	if {![regexp {^[A-Za-z0-9_\-]+$} $thisname]} {	;#	patchnames must be alphanumeric, possibly with underscores
		Inf "Invalid batchfile name (do not use a file extension)"
		return
	} else {
		set rthisname [string tolower [file rootname [file tail $thisname]]]
		if {[lsearch $excluded_batchfiles $rthisname] >= 0} {
			Inf "'$thisname' Is A Reserved Batchfile Name : Please Choose A Different Name"
			return
		}
	}
	
											;#	associate patch with relevant file(name)

	if {$do_append} {
		set OK 0
		foreach fi [glob -nocomplain *$evv(BATCH_EXT)] {	;#	Check if name already exists for a batchfile
			if [string match $thisname$evv(BATCH_EXT) [file tail $fi]] {
				set OK 1
				break
			}
		}
		if {!$OK} {
			Inf "No batchfile with the name '$thisname$evv(BATCH_EXT)' exists.\nIf the batchfile is not in the base directory,\nCOPY it to the base directory now, and try again."
			return
		}
	} else {
		foreach fi [glob -nocomplain "*$evv(BATCH_EXT)"] {	;#	Check if name already exists for a batchfile

			if [string match $thisname$evv(BATCH_EXT) $fi] {
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] \
						-message "A batchfile with this name already exists: Overwrite existing batchfile?"]
				if [string match no $choice] {
					return
				} else {
					set file_exists 1
					break
				}
			}
		}
	}
	if {[string match $evv(DFLT_OUTNAME)* $thisname] \
	|| [string match $evv(MACH_OUTFNAME)* $thisname] \
	|| [string match $evv(DFLT_TMPFNAME)* $thisname]} {
		Inf "The name you are using for the batchfile is a reserved CDP name.\n\nPlease choose a different name."
		return
	}
	if {$has_outfilename} {
		if {!$using_outname} {
			if {![IsMultipleCopy]} {
				set copcnt 0
				set cnt 0
				if {$do_append} {
					if [catch {open $thisname$evv(BATCH_EXT) "r"} fileId] {	;#	Open batchfile, to read, and to append data
						Inf "$fileId"
						Inf "Cannot open batch file, to read existing data"
						return
					}
					if {$float_out && ![IsStandalonePrognoWithNonCDPFormat $pprg]}	{
						set fthisname $evv(FLOAT_OUT)
						append fthisname $thisname
					} else {
						set fthisname $thisname
					}
					set tlen [string length $fthisname]
					while {[gets $fileId line] >= 0} {
						set line [split $line]
						if {[IsMultipleCopyLine $line]} {
							incr copcnt
							incr cnt
							continue
						}
						foreach item $line {
							if {[string match $fthisname* $item] && ([string length $item] > $tlen)} {
								set substr [string range $item $tlen end]
								set k [string first "." $substr]
								if {$k >= 0} {
									incr k -1
									set substr [string range $substr 0 $k]
								}
								if {[IsNumeric $substr] && ($substr > $existingcnt)} {
									set existingcnt $substr
									break
								}
							}
						}
						incr cnt
					}
					if {$existingcnt < 0 && ($cnt != $copcnt)} {
						Inf "Cannot locate outfilenames starting with $fthisname in existing batchfile: (try using Outnames ?)"
						catch {close $fileId}
						return
					}
					incr existingcnt
					if [catch {close $fileId} zib] {
						Inf "Cannot close the existing batchfile, in order to append new data"
						return
					}
				} else {
					set existingcnt 0
				}
				foreach fi [glob -nocomplain "*.*"] {	;#	Check if name already exists for the output file
					if [string match $thisname$existingcnt [file rootname $fi]] {
						set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] \
								-message "Your Batchfilename is also used as the name of the output file of your batch process,\nbut a file with this name already exists.\n\nOverwrite it??"]
						if [string match no $choice] {
							return
						} else {
							break
						}
					}
				}
				if {[IsStandalonePrognoWithNonCDPFormat $pprg]} {
					set cmd [lreplace $cmd $standopos $standopos $thisname$existingcnt]
				} elseif {$float_out} {
					set cmd [lreplace $cmd $cmdcnt $cmdcnt $evv(FLOAT_OUT)$thisname$existingcnt]
					if {$pprg == $evv(PITCH)} {
						incr existingcnt
						incr cmdcnt
						set cmd [lreplace $cmd $cmdcnt $cmdcnt $evv(FLOAT_OUT)$thisname$existingcnt]
					}
				} else {
					set cmd [lreplace $cmd $cmdcnt $cmdcnt $thisname$existingcnt]
					if {$pprg == $evv(PITCH)} {
						incr existingcnt
						incr cmdcnt
						set cmd [lreplace $cmd $cmdcnt $cmdcnt $thisname$existingcnt]
					}
				}
			}
		} else {
			if {[IsStandalonePrognoWithNonCDPFormat $pprg]} {
				set cmd [lreplace $cmd $standopos $standopos [lindex $nu_names 0]]
			} elseif {$float_out} {
				set zz $evv(FLOAT_OUT)
				append zz [lindex $nu_names 0]
				set cmd [lreplace $cmd $cmdcnt $cmdcnt $zz]
			} else {
				set cmd [lreplace $cmd $cmdcnt $cmdcnt [lindex $nu_names 0]]
			}
		}
	}
	set nufnam $thisname$evv(BATCH_EXT)
	if {$do_append} {
		if [catch {open $nufnam a} fileId] {	;#	Open batchfile, to create, or to overwrite
			Inf "$fileId"
			Inf "Cannot open batch file, to append new data"
			return
		} else {
			set file_exists 1
		}
	} else {
		if [catch {open $nufnam w} fileId] {	;#	Open batchfile, to create, or to overwrite
			Inf "$fileId"
			Inf "Cannot open batch file, to save batch data"
			return
		}		
	}
	if [catch {puts $fileId "$cmd"} err] {
		Inf $err
		Inf "Failed to save batch data"
		catch {close $fileId}
		return
	}

	catch {close $fileId}
	if {$file_exists} {
		set pos [LstIndx $nufnam $wl]
		if {$pos < 0} {
			if [BatchfileToWkspace $nufnam] {
				Inf "Batchfile\n\n'$nufnam'\n\nis now on the workspace"
			} else {
				Inf "Patchfile\n\n'$nufnam'\n\nexists in the base directory\nbutmay not be listed on the workspace"
			}
		} else {
			if {[DoParse $nufnam $wl 0 0] <= 0} {
				$wl delete $pos
				PurgeArray $nufnam
				RemoveFromChosenlist $nufnam
			} else {
				Inf "Batchfile\n\n'$nufnam'\n\nhas been rewritten"
				DummyHistory $nufnam "BATCHFILE_EXTENDED"
			}
		}
	} else {
		if [BatchfileToWkspace $nufnam] {
			Inf "Batchfile\n\n'$nufnam'\n\nis now on the workspace"
			DummyHistory $nufnam "BATCHFILE_CREATED"
		} else {
			Inf "Patchfile\n\n'$nufnam'\n\nexists in the base directory\nbut may not be listed on the workspace"
			DummyHistory $nufnam "BATCHFILE_CREATED"
			catch {unset rememd}
		}
	}
#	set new_patchname ""
#	ForceVal $papag.patches.name.e $new_patchname
}

#------ Parse file and add it to workspace

proc BatchfileToWkspace {fnam} {
	global pa wl ch wksp_in_chose_mode wstk evv
	global do_parse_report chcnt rememd wkspace_newfile

# 	0  = Continue without loading file 
#	-1 = Conclude file loading, major error
#	else Continues after loading file

	if {![file isfile $fnam]} {
		Inf "$fnam is not a file"
		return 0
	} elseif [IgnoreSoundloomxxxFilenames $fnam] {		;#	Possibly redundant
		return 0
	}
	set do_parse_report 1
	switch -- [DoParse $fnam $wl 0 0] {
		0		{return $evv(PARSE_FAILED)}						
		-1		{return -1}						
		default	{
			if {$evv(DFLT_SR) > 0} {
				set filetype $pa($fnam,$evv(FTYP))
				if {($filetype & $evv(IS_A_SNDSYSTEM_FILE)) && ($filetype != $evv(ENVFILE))} {
					if {$filetype & $evv(IS_A_SNDFILE)} {
						if {$pa($fnam,$evv(SRATE)) != $evv(DFLT_SR)} {
  							PurgeArray $fnam
							Inf "File $fnam is not at the specified sample rate of $evv(DFLT_SR)"
							return 0
						}
					} elseif {$pa($fnam,$evv(ORIGRATE)) != $evv(DFLT_SR)} {
						PurgeArray $fnam
						Inf "File $fnam is not at the specified sample rate of $evv(DFLT_SR)"
						return 0
					}
				} elseif {$filetype == $evv(PSEUDO_SND)} {
					if {$pa($fnam,$evv(SRATE)) != $evv(DFLT_SR)} {
						PurgeArray $fnam
						Inf "File $fnam is not at the specified sample rate of $evv(DFLT_SR)"
						return 0
					}
				}			
			}
			$wl insert 0 $fnam
			WkspCnt $fnam 1
			catch {unset rememd}
			set wkspace_newfile 1
		}
	}
	return 1
}

#------ Get cmdline name of program

proc GetBatchProgname {progno} {

	switch -- $progno {
		1 { return "gain"}			;# SPEC
		2 { return "limit"}
		3 { return "bare"}
		4 { return "clean"}
		5 { return "cut"}
		6 { return "grab"}
		7 { return "magnify"}
		8 { return "spectrum"}		;# STRETCH
		9 { return "time"}
		10 { return "altharms"}		;# PITCH
		11 { return "octmove"}
		12 { return "transp"}
		13 { return "tune"}
		14 { return "pick"}
		15 { return "chord"}
		16 { return "chordf"}
		17 { return "filter"}		;# HILITE
		18 { return "greq"}
		19 { return "band"}
		20 { return "arpeg"}
		21 { return "pluck"}
		22 { return "trace"}
		23 { return "bltr"}
		24 { return "accu"}			;# FOCUS
		25 { return "exag"}
		26 { return "focus"}
		27 { return "fold"}
		28 { return "freeze"}
		29 { return "step"}
		30 { return "avrg"}			;# BLUR
		31 { return "blur"}
		32 { return "suppress"}
		33 { return "chorus"}
		34 { return "drunk"}
		35 { return "shuffle"}
		36 { return "weave"}
		37 { return "noise"}
		38 { return "scatter"}
		39 { return "spread"}
		40 { return "shift"}		;# STRANGE
		41 { return "glis"}
		42 { return "waver"}
		44 { return "invert"}
		45 { return "glide"}		;# MORPH
		46 { return "bridge"}
		47 { return "morph"}
		48 { return "getpitch"}		;# REPITCH
    	50 { return "approx"}
    	51 { return "exag"}
    	52 { return "invert"}
    	53 { return "quantise"}
		54 { return "randomise"}
    	55 { return "smooth"}
    	56 { return "pchshift"}
		57 { return "vibrato"}
		58 { return "cut"}
		59 { return "fix"}
		60 { return "combine"}
		61 { return "combineb"}
		62 { return "transpose"}
		63 { return "transposef"}
		64 { return "get"}			;# FORMANTS
		65 { return "put"}
		66 { return "vocode"}
		67 { return "see"}
		68 { return "getsee"}
		69 { return "make"}			;# COMBINE
		70 { return "sum"}
		71 { return "diff"}
		72 { return "interleave"}
		73 { return "max"}
		74 { return "mean"}
		75 { return "cross"}
		76 { return "windowcnt"}	;# SPECINFO
		77 { return "channel"}
		78 { return "frequency"}
		79 { return "level"}
		80 { return "octvu"}
		81 { return "peak"}
		82 { return "report"}
		83 { return "print"}
    	84 { return "info"}			;# PITCHINFO
    	85 { return "zeros"}
		86 { return "see"}
		87 { return "hear"}
		88 { return "convert"}
		90  { return "mton"}		;# CHANNELS
		91  { return "flutter"}		;# MCHAN
		92  { return "extract"}		;# REPITCH
		93  { return "shred"}		;# MCHAN
		94  { return "zag"}			;# MCHAN
		95  { return "mchstereo"}	;# MCHAN
    	96  { return "zcuts"}		;# OTHER
    	97  { return "chord"}
		98  { return "balance"}
    	99  { return "maxsamp2"}
		100 { return "cyclecnt"}	;# DISTORT
		101 { return "reform"}
		102 { return "envel"}
		103 { return "average"}
		104 { return "omit"}
		105 { return "multiply"}
		106 { return "divide"}
		107 { return "harmonic"}
		108 { return "fractal"}
		109 { return "reverse"}
		110 { return "shuffle"}
		111 { return "repeat"}
		112 { return "interpolate"}
		113 { return "delete"}
		114 { return "replace"}
		115 { return "telescope"}
		116 { return "filter"}
		117 { return "interact"}
		118 { return "pitch"}
		119 { return "zigzag"}		;# EXTEND
		120 { return "loop"}
		121 { return "scramble"}
		122 { return "iterate"}
		123 { return "drunk"}
		124 { return "simple"}		;# TEXTURE
		125 { return "grouped"}
		126 { return "decorated"}
		127 { return "predecor"}
		128 { return "postdecor"}
		129 { return "ornate"}
		130 { return "preornate"}
		131 { return "postornate"}
		132 { return "motifs"}
		133 { return "motifsin"}
		134 { return "timed"}
		135 { return "tgrouped"}
		136 { return "tmotifs"}
		137 { return "tmotifsin"}
		138 { return "count"}		# GRAIN
		139 { return "omit"}
		140 { return "duplicate"}
		141 { return "reorder"}
		142 { return "repitch"}
		143 { return "rerhythm"}
		144 { return "remotif"}
		145 { return "timewarp"}
		146 { return "find"}
		147 { return "reposition"}
		148 { return "align"}
		149 { return "reverse"}
		150 { return "create"}		;# ENVEL
		151 { return "extract"}
		152 { return "impose"}
		153 { return "replace"}
		154 { return "warp"}
		155 { return "reshape"}
		156 { return "replot"}
		157 { return "dovetail"}
		158 { return "curtail"}
		159 { return "swell"}
		160 { return "attack"}
    	161 { return "pluck"}
		162 { return "tremolo"}
		163 { return "envtobrk"}
		164 { return "envtodb"}
		165 { return "brktoenv"}
		166 { return "dbtoenv"}
		167 { return "dbtogain"}
		168 { return "gaintodb"}
		169 { return "merge"}		;# SUBMIX
		170 { return "crossfade"}
		171 { return "interleave"}
		172 { return "inbetween"}
    	173 { return "mix"}
    	174 { return "getlevel"}
		175 { return "attenuate"}
		176 { return "shuffle"}
		177 { return "timewarp"}
		178 { return "spacewarp"}
		179 { return "sync"} 
		180 { return "syncattack"}
    	181 { return "test"}
    	183 { return "dummy"}
		185 { return "fixed"}		;# FILTER
    	186 { return "lohi"}
		187 { return "variable"}
		188 { return "bank"}
		189 { return "bankfrqs"}
		190 { return "userbank"}
		191 { return "varibank"}
		192 { return "sweeping"}
    	193 { return "iterated"}
		194 { return "phasing"}
		195 { return "loudness"}	;# MODIFY
		196	{ return "space"}
		197 { return "speed"}
		198 { return "revecho"}
		199 { return "brassage"}
		200 { return "sausage"}
		201 { return "radical"}
		202 { return "anal"}		;# PVOC
		203 { return "synth"}
		204 { return "extract"}
		206 { return "cut"}			;# SFEDIT
		207 { return "cutend"}
    	208 { return "zcut"}
		209 { return "excise"}
    	210 { return "excises"}
		211 { return "insert"}
		212 { return "insil"}
		213 { return "join"}
		214 { return "copy"}		;# HOUSEKEEP
		215 { return "chans"}
		216 { return "extract"}
    	217 { return "respec"}
		218 { return "bundle"}
		219 { return "sort"}
		220 {return  "bakup"}
		221 { return "recover"}
		222 { return "disk"}
    	223 { return "props"}		;# SNDINFO
    	224 { return "len"}
    	225 { return "lens"}
    	226 { return "sumlen"}
    	227 { return "timediff"}
    	228 { return "smptime"}
    	229 { return "timesmp"}
    	230 { return "maxsamp"}
    	231 { return "loudchan"}
    	232 { return "findhole"}
    	233 { return "diff"}
	    234 { return "chandiff"}
	    235 { return "prntsnd"}
	    236 { return "units"}
		237 { return "wave"}		;# SYNTH
		238 { return "noise"}
		239 { return "silence"}
		248 { return "hold"}		;# MORE
		249 { return "remove"}
    	251 { return "masks"}
		252 { return "randcuts"}
		253 { return "randchunks"}
		254 { return "spaceform"}
		255 { return "repetitions"}
		256 { return "multichan"}
		257 { return "join"}
		258 { return "withzeros"}
		259 { return "stretch"}
		260 { return "dupl"}
		261 { return "delete"}
		262 { return "strtrans"}
		263 { return "get"}
		264 { return "put"}
		265 { return "combine"}
		266 { return "grab"}
		267 { return "chop"}
		268 { return "interp"}
		269 { return "gate"}
		270 { return "features"}
		271 { return "synth"}
		272 { return "impose"}
		273 { return "split"}
		274 { return "space"}
		275 { return "interleave"}
		276 { return "replace"}
		277 { return "sustain"}
		278 { return "locate"}
		279 { return "cutatgrain"}
		280 { return "remove"}
		281 { return "sustain2"}
		282 { return "silence"}
		283 { return "multi"}
		284 { return "reinforce"}
		285 { return "harmonic"}
		286 { return "partials"}
		287 { return "iter"}
		289 { return "hfchords"}
		290 { return "hfchords2"}
		291 { return "delperm"}
		292 { return "delperm2"}
		293 { return "spectra"}
		294 { return "overload"}
		295 { return "twixt"}
    	296 { return "sphinx"}
		297 { return "maxi"}
		298 { return "synth"}
		299 { return "insertzeros"}
		300 { return "pitchtosil"}
		301 { return "noisetosil"}
		302 { return "insertsil"}
		303 { return "analenv"}
		304 { return "make2"}
		305 { return "vowels"}
		306 { return "dump"}
		307 { return "gate"}
		308 { return "ongrid"}
		309 { return "generate"}
		310 { return "interp"}
		311 { return "faders"}
		312 { return "cutmany"}
		313 { return "stack"}
		314 { return "vowels"}
		315 { return "scaled"}
		316 { return "scaledpan"}
		317 { return "mergemany"}
		318 { return "pulsed"}
		319 { return "noisecut"}
		320 { return "timegrid"}
		321 { return "sequence"}
		322 { return "convolve"}
		323 { return "baktobak"}
		324 { return "addtomix"}
		325 { return "replace"}
		326 { return "pan"}
		327 { return "shudder"}
		328 { return "atstep"}
		329 { return "findpan"}
		330 { return "clicks"}
		331 { return "doublets"}
		332 { return "syllables"}
		333 { return "joinseq"}
		334 { return "vfilters"}
		335 { return "batchexpand"}
		336 { return "model"}
		337 { return "inbetween2"}
		338 { return "joindyn"}
		339 { return "freeze"}
		340 { return "replim"}
		341 { return "endclicks"}
		342 { return "pchtotext"}
		343 { return "envsyn"}
		344 { return "sequence2"}
		345 { return "r_extend"}
		346 { return "deglitch"}
		347 { return "assess"}
		348 { return "varibank2"}
		349 { return "repeat2"}
		350 { return "zcross"}
		351 { return "noise_extend"}
		352 { return "grev"}
		356 { return "getfilt"}
		357 { return "get"}
		358 { return "impose"}
		359 { return "suppress"}
		360 { return "clean"}
		361 { return "subtract"}
		362 { return "phase"}
		364 { return "brktopi"}
		365 { return "slice"}
		366 { return "extract"}
		367 { return "construct"}
		368 { return "extend"}
		369 { return "peakfind"}
		370 { return "constrict"}
		371 { return "expdecay"}
		372 { return "peakchop"}
		373 { return "mchanpan"}
		374 { return "texmchan"}
		375 { return "manysil"}
		376 { return "retime"}
		378 { return "hover"}
		379 { return "create"}
		380 { return "shift"}
		381 { return "sigstart"}
		382 { return "mchanrev"}
		383 { return "wrappage"}
		391 { return "specsphinx"}
		392 { return "superaccu"}
		393 { return "partition"}
		394 { return "specgrids"}
		395 { return "glisten"}
		396 { return "tunevary"}
		397 { return "isolate"}
		398 { return "rejoin"}
		399 { return "panorama"}
		400 { return "tremolo"}
		401 { return "echo"}
		402 { return "packet"}
		403 { return "synthesis"}
		404 { return "onefile"}
		405 { return "twofiles"}
		406 { return "sequence"}
		407 { return "list"}
		408 { return "spectwin"}
		409 { return "simple"}
		410 { return "filtered"}
		411 { return "doppler"}
		412 { return "doplfilt"}
		413 { return "sequence"}
		414 { return "list"}
		415 { return "set"}
		416 { return "shrink"}
		417 { return "newtex"}
		418 { return "ceracu"}
		419 { return "madrid"}
		420 { return "shifter"}
		421 { return "fracture"}
		422 { return "subtract"}
		423 { return "lines"}
		424 { return "newmorph"}
		425 { return "newmorph2"}
		426 { return "newdelay"}
		427 { return "filtrage"}
		428 { return "iterline"}
		429 { return "iterlinef"}
		431 { return "rand"}
		432 { return "squeeze"}
		433 { return "hover2"}
		434 { return "selfsim"}
		435 { return "iterfof"}
		436 { return "pulser"}
		437 { return "multi"}
		438 { return "synth"}
		439 { return "chirikov"}
		440 { return "multiosc"}
		441 { return "synfilt"}
		442 { return "strands"}
		443 { return "refocus"}
		447 { return "chanphase"}
		448 { return "silend"}
		449 { return "speculate"}
		450 { return "tune"}
		451 { return "repair"}
		452 { return "distshift"}		
		453 { return "quirk"}
		454 { return "rotor"}
		455 { return "distcut"}
		456 { return "envcut"}
		458 { return "specfold"}
		459 { return "motion"}
		460 { return "stereo"}
		461 { return "quad"}
		462 { return "sound"}
		463 { return "tesselate"}
		465 { return "phasor"}
		466 { return "rotate"}
		467 { return "make"}
		468 { return "dvdwind"}
		469 { return "cascade"}
		470 { return "synspline"}
		471 { return "wave"}
		472 { return "spectrum"}
		473 { return "splinter"}
		474 { return "repeater"}
		475 { return "verges"}
		476 { return "motor"}
		477 { return "stutter"}
		478 { return "scramble"}
		479 { return "impulse"}
		480 { return "tweet"}
		481 { return "bounce"}
		482 { return "sorter"}
		483 { return "specfnu"}
		484 { return "flatten"}
		488 { return "distmark"}
		496 { return "distrep"}
		497 { return "tostereo"}
		498 { return "partials"}
		499 { return "caltrain"}
		500 { return "specenv"}
		503 { return "clip"}
		504 { return "extend"}
	}
	return ""
}

#---- Insert flag letters in batch command

proc SetupBatchcmdFlagLetters {cmd} {
	global pprg mmod filter_version modify_version

	set mode $mmod
	incr mode -1

	set outstr "#"

	switch -- $pprg {
		3  {	set outstr "-x"}
		4  {	set outstr "g"}
		5  {	set outstr "mbt"}
		8  {	set outstr "d"}
		10 {	set outstr "-x"}
		12 {	set outstr "d"}
		13 {	set outstr "fctb"}
		14 {	set outstr "c"}
		15 {	set outstr "bt-x"}
		16 {	set outstr "bt-x"}
		18 {	set outstr "-r"}
		20 {
			switch -- $mode {
				0 -
				1 -
				2 -
				3 { set outstr "plhbaNs-TK" }
				4 -
				5 { set outstr "plha" }
				default { set outstr "plhba" }
			}
		}
		22 {
			switch -- $mode {
				0 {	set outstr ""}
				default {	set outstr "-r"}
			}
		}
		24 {	set outstr "dg"}
		26 {	set outstr "bts"}
		27 {	set outstr "-x"}
		34 {	set outstr "-z"}
		38 {	set outstr "b-rn"}
		39 {	set outstr "s"}
		40 {	set outstr "-l"}
		41 {	set outstr "t"}
		43 {	set outstr "pts"}
		46 {	set outstr "abcdefg"}
		47 {	set outstr "s"}
		48 {
			switch -- $mode {																	   
				0 { set outstr "tgsnlh-az"}
				1 { set outstr "tgsnlhd-a"}
			}
		}
		50 {	set outstr "pts"}
		53 {	set outstr "-o"}
		54 {	set outstr "s"}
		55 {	set outstr "p-h"}
		59 {	set outstr "rxlhsbe-wi"}
		61 {	set outstr "d"}
		62 {	set outstr "lh-x"}
		63 {	set outstr "lh-x"}
		65 {	set outstr "lhg"}
		264 {	set outstr "lhg"}
		66 {	set outstr "lhg"}
		67 {	set outstr "-v"}
		68 {	set outstr "-s"}
		70 {	set outstr "c"}
		71 {	set outstr "c-a"}
		74 {	set outstr "lhc-z"}
		75 {	set outstr "i"}
		77 {	set outstr ""}
		81 {	set outstr "ctf-h"}
		82 {	set outstr "bts"}
		83 {	set outstr "w"}
		88 {	set outstr "d"}
		80 {	set outstr "f"}
		87 {	set outstr "g"}
		91 {	set outstr "r"}
		92 {
			switch -- $mode {																	   
				0 { set outstr "h-amqz"}
				default { set outstr "h-amqzf"}
			}
		}
		94 {
			switch -- $mode {
				0 {	set outstr "smr-a"}
				1 {	set outstr "s-a"}
			}
		}
		95 {	set outstr "-s"}
		97 {	set outstr "at"}
		98 {	set outstr "kbe"}
		102 {
			switch -- $mode {
				0 -
				1 {	set outstr "te"}
				2 {	set outstr "e"}
				3 {	set outstr ""}
			}
		}
		103 {	set outstr "ms"}
		105 {	set outstr "-s"}
		106 {	set outstr "-i"}
		107 {	set outstr "p"}
		108 {	set outstr "p"}
		110 {	set outstr "cs"}
		111 {	set outstr "cs"}
		112 {	set outstr "s"}
		113 {	set outstr "s"}
		114 {	set outstr "s"}
		115 {	set outstr "s-a"}
		116 {	set outstr "s"}
		118 {	set outstr "cs"}
		119 {	
			switch -- $mode {
				0 {	set outstr "smr"}
				1 {	set outstr "s"}
			}
		}
		120 {
			switch  -- $mode {
				0 {	set outstr "ws-b"}
				1 {	set outstr "lws-b"}
				2 {	set outstr "lws-b"}
			}
		}
		121 {	set outstr "ws-be"}
		122 {	set outstr "drpafgs"}
		123 {
			switch -- $mode {
				0 {	set outstr "scor"}
				1 {	set outstr "scorlh"}
			}
		}
		126 - 
		127 -
		128 {	set outstr "apsr-wdihek"}
		129 -
		130 -
		131 {	set outstr "apsr-wdihe"}
		132 -
		136 {	set outstr "apsr-wdi"}
		133 -
		137 {	set outstr "apsr-wdi"}
		125 -
		135 {	set outstr "apsr-wdi"}
		124 {	set outstr "apsr-wcp"}
		134 {	set outstr "apsr-w"}
		138 -
		139 -
		140 -
		141 -
		142 -
		143 -
		144 -
		145 -
		146 -
		147 -
		148 -
		149 {	set outstr "lht-x"}
		151 {
			switch -- $mode {
				0 {	set outstr ""}
				1 {	set outstr "d"}
			}
		}
		156 {	set outstr "d"}
		157 {	set outstr "t"}
		158 {	set outstr "t"}
		163 {	set outstr "d"}
		164 {	set outstr "d"}
		160 {	set outstr "t"}
		161 {	set outstr "ad"}
		169 {	set outstr "sjkbe"}
		170 {
			switch -- $mode {
				0 {	set outstr "sbe"}
				1 {	set outstr "sbep"}
			}
		}
		173 {	set outstr "seg-a"}
		174 {	set outstr "se"}
		175 {	set outstr "se"}
		176 {
			switch -- $mode {
				6 {	set outstr "se-x"}
				default { set outstr "se"}
			}
		}
		177 {
			switch -- $mode {
				0 {	set outstr ""}
				default { set outstr "se"}
			}
		}
		178 {
			switch -- $mode {
				6 {	set outstr ""}
				7 {	set outstr ""}
				default {	set outstr "se"}
			}
		}
		180 {	set outstr "w-p"}
		185 {	set outstr "ts"}
		186 {	set outstr "ts"}
		187 {	set outstr "t"}
		188 {	set outstr "ts-d"}
		190 {	set outstr "t-d"}
		191 {			
			if {$filter_version > 6} {
				 set outstr "thr-don"
			} else {
				 set outstr "thr-d"
			}
		}
		193 {	set outstr "srpa-dien"}
		192 {	set outstr "tp"}
		194 {	set outstr "ts-l"}

		195 {
			switch -- $mode {
				0 {	set outstr ""}
				1 {	set outstr ""}
				2 {	set outstr "l"}
				3 {	set outstr "l"}
				4 {	set outstr ""}
				5 {	set outstr ""}
				6 {	set outstr ""}
				7 {	set outstr ""}
			}
		}
		196 {
			switch -- $mode {
				0 {	set outstr "p"}
				1 {	set outstr ""}
				2 {	set outstr ""}
				3 {	set outstr ""}
			}
		}
		197 {
	 		switch -- $mode {
				4 {	set outstr "s"}
				5 {	set outstr ""}
				default {	set outstr "-o"}
			}
		}
		198 {
			switch -- $mode {														   
				0 {	set outstr "p-i"}
				1 {	set outstr "ps"}
				2 {
					if {$modify_version > 7} {
						set outstr "grse-n"
					} else {
						set outstr "grse"
					}
				}
			}
		}
		199 {
	 		switch -- $mode {
	 			0 {	set outstr ""}
	 			1 {	set outstr ""}
	 			2 {	set outstr "r"}
	 			3 {	set outstr "r"}
	 			4 {	set outstr "-d"}
	 			5 {	set outstr "rjlc-dxn"}
	 			6 {	set outstr "rjlc-dxn"}
	 		}
		}
		200 {	set outstr "rjlc-dxn"}
		201 {
			switch -- $mode {
				0 {	set outstr ""}
				1 {	set outstr "s-n"}
				2 {	set outstr "hlse"}
				3 {	set outstr ""}
				4 {	set outstr ""}
				5 {	set outstr ""}
				6 {	set outstr ""}
			}
		}
		202 {	set outstr "co"}
		204 {	set outstr "codlh"}
		206 {	set outstr "w"}
		207 {	set outstr "w"}
		209 {	set outstr "w"}
		210 {	set outstr "w"}
		211 {	set outstr "wl-o"}
		212 {	set outstr "w-os"}
		213 {	set outstr "w-be"}
		214 {
			switch -- $mode {
				0 {	set outstr ""}
				1 {	set outstr ""}
			}
		}
		215 {
			switch -- $mode {
				0 {	set outstr ""}
				1 {	set outstr ""}
				2 {	set outstr ""}
				3 {	set outstr "-p"}
				4 {	set outstr ""}
			}
		}
		216 {
			switch -- $mode {
				0 {	set outstr "gsethbilw"}
				1 {	set outstr ""}
				5 {	set outstr ""}
				2 {	set outstr "gs-be"}
				3 {	set outstr ""}
				4 {	set outstr ""}
			}
		}
		217 {
			switch -- $mode {
				0 {	set outstr ""}
				1 {	set outstr ""}
				2 {	set outstr "sct"}
			}
		}
		219 {
			switch -- $mode {
				0 {	set outstr ""}
				1 {	set outstr ""}
				2 {	set outstr "-l"}
				3 {	set outstr "-l"}
				4 {	set outstr "-l"}
				5 {	set outstr ""}
			}
		}
		221 {	set outstr "hics-p"}
		226 {	set outstr "s"}
		228 {	set outstr "-g"}
		229 {	set outstr "-g"}
		230 {	set outstr "-f"}
		232 {	set outstr "t"}
		233 {	set outstr "tn-lc"}
		234 {	set outstr "tn"}
		237 {	set outstr "at-f"}
		238 {	set outstr "a-f"}
		239 {	set outstr "-f"}
		249 {	set outstr "-a"}
		251 {	set outstr "w"}
		253 {	set outstr "m-ls"}
		256 {	set outstr "seg"}
		270 {	set outstr "-a"}
		277 {	set outstr "-s"}
		283 {
			switch -- $mode {
				0 -
				1 {	set outstr "-o"}
				2 {	set outstr "s"}
				3 { set outstr ""}
			}
		}
		284 {
			switch -- $mode {
				0 {	set outstr "d-s"}
				1 {	set outstr "w"}
			}
		}
		286 {	set outstr "-ap"}
		287 {	set outstr "drpafgs"}
		289 {	set outstr "-msao"}
		290 {	set outstr "-msao"}
		293 {	set outstr "-p"}
 		295 {
			switch -- $mode {
				3 {	set outstr ""}
				0 {	set outstr "w-r"}
				1 {	set outstr "w-r"}
				2 {	set outstr "w-r"}
			}
		}
 		296 {
			switch -- $mode {
				0 {	set outstr "w-r"}
				1 {	set outstr "w-r"}
				2 {	set outstr "w-r"}
			}
		}
		307 {	set outstr "z"}
		316 {	set outstr "p"}
		318 {	set outstr "-se"}
		319 {	set outstr "-n"}
		313 {
			if {$modify_version > 7} {
				set outstr "-sn"
			} else {
				set outstr "-s"
			}
		}
		325 {	set outstr "wl"}
		327 {	set outstr "-b"}
		330 {	set outstr "sez-t"}
		331 {   set outstr "-s" }
		332 {	set outstr "-p"}
		333 {   set outstr "wm-be"}
		337 {   set outstr "" }
		338 {	set outstr "-be"}
		339 {	set outstr "s"}
		340 {	set outstr "sf"}
		341 {	set outstr "-be"}
		346 {	set outstr "-s"}
		348 {
			if {$filter_version > 6} {
				set outstr "t-dn"
			} else {
				set outstr "t-d"
			}
		}
		349 {	set outstr "c-s"}
		350 {	set outstr "se"}
		351 {	set outstr "-x"}
		345 {
	 		switch -- $mode {
	 			0 {	set outstr "-x"}
	 			1 {	set outstr "-se"}
	 			2 {	set outstr ""}
	 		}
		}
		357 {	set outstr "-l"}
		362 {
	 		switch -- $mode {
	 			1 {	set outstr "t"}
				default { set outstr ""}
			}
		}
		366 {	set outstr "-w"}
		367 {	set outstr "-n"}
		369 {	set outstr "t"}
		372 {
	 		switch -- $mode {
	 			0 {	set outstr "gqsnrm"}
	 			1 {	set outstr "gq"}
			}
		}
		373 {
	 		switch -- $mode {
	 			0 {	set outstr "f"}
	 			1 {	set outstr "fm"}
	 			2 {	set outstr "-s"}
	 			8 {	set outstr "-a"}
	 			9 {	set outstr "fmg-ar"}
				default {set outstr ""}
			}
		}
		374 {	set outstr "apsr-wcpf"}
		376 {
	 		switch -- $mode {
				4 { set outstr "sea"}
				9 { set outstr "mp"}
				default {set outstr ""}
			}
		}
		380 {
	 		switch -- $mode {
	 			0 -
				1 {	set outstr "s"}
	 			4 {	set outstr "b"}
	 			7 {	set outstr "b"}
				default {set outstr ""}
			}
		}
		383 {	set outstr "b-eo"}
		391 {
	 		switch -- $mode {
				0 {	set outstr "af"}
				1 {	set outstr "bg"}
				2 {	set outstr "dgc-e"}
			}
		}
		392 {	set outstr "dg-r"}
		393 {
	 		switch -- $mode {
	 			0 { set outstr ""}
				1 {	set outstr "rs"}
			}
		}
		395 {	set outstr "pdv"}
		396 {	set outstr "fctb"}
		397 {
	 		switch -- $mode {
	 			0 -
				1 { set outstr "s-xr"}
				2 { set outstr "sml-xr"}
				3 { set outstr "s-xr"}
				4 { set outstr "sd-xr"}
			}
		}
		398 {	set outstr "g-r"}
		399 {	set outstr "r-pq"}
		401 {	set outstr "rc"}
		402 {	set outstr "-nf"}
		403 {
			switch -- $mode {
	 			0 {	set outstr ""}
				1 {	set outstr "nc-f"}
				2 {	set outstr "uds-m"}
				3 { set outstr "fr-e"}
			}
		}
		404 -
		405 - 
		406 -
		407 {
	 		switch -- $mode {
				0 { set outstr "fjs-rl" }
				1 { set outstr "fj-rl"  }
			}
		}
		408 {	set outstr "efdsr"}
		409	-
		410	-
		411	-
		412 {	set outstr "tdem-l" }
		413 -
		414	{	set outstr "-l" }
		415	{
	 		switch -- $mode {
				0 -
				1 {	set outstr "-e" }
			}
		}
		416 {
	 		switch -- $mode {
				0 -
				1 -
				2 -
				3 {	set outstr "msr-ni"}
				4 { set outstr "msrglq-nieo"}
				5 { set outstr "msrgl-nieo"}
			}
		}
		417 {	set outstr "sneEcCr-xj"}
		418 {	set outstr "-ol"}
		419 {
	 		switch -- $mode {
				0 {	set outstr "s-elrR"}
				1 { set outstr "s-el"}
			}
		}
		420 { set outstr "-zrl"}
		421 {
	 		switch -- $mode {
				0  { set outstr "rpdvesthmi-yl"}
				1  { set outstr "rpdvesthmiazclfjkwg-y"}
			}
		}
		422 { set outstr "c" }
		424 {
 	 		switch -- $mode {
				4 -
				5		{ set outstr "r" }
				default { set outstr "-enf" }
			}
		}
		425 {
 	 		switch -- $mode {
				0		{ set outstr "" }
				default { set outstr "r" }
			}
		}
		426 {
 	 		switch -- $mode {
				0		{ set outstr "" }
				default { set outstr "rdm" }
			}
		}
		427 { set outstr "s"}
		428 -
		429 { set outstr "-n"}
		431 { set outstr "tg"}
		433 { set outstr "-sn"}
		435 { set outstr "s"}
		436 {
 	 		switch -- $mode {
				2		{ set outstr "eEpaobsw" }
				default { set outstr "eEpaobs" }
			}
		}
		437 {
 	 		switch -- $mode {
				2		{ set outstr "eEpaobsw-r" }
				default { set outstr "eEpaobs-r" }
			}
		}
		438 { set outstr "eEpaobsS"}
		441 { set outstr "-so"}
		442 { 
 	 		switch -- $mode {
				1		{ set outstr "gmf-s"}
				default { set outstr "gmf"}
			}
		}
		443 { set outstr "oens"}
		449 { set outstr "-r"}
		450 {
 	 		switch -- $mode {
				3		{ set outstr "mlhseiwn-rb"}
				default { set outstr "mlhseiwn-rbf"}
			}
		}
		454 { set outstr "d-s"}
		455 -
		456 { set outstr "c"}
		458 { set outstr "-a"}
		459 {
 	 		switch -- $mode {
				0 { set outstr "amsd-l"}
				1 { set outstr "am-l"}
			}
		}
		460 {
 	 		switch -- $mode {
				0 { set outstr "ba"}
				1 { set outstr "bakc"}
				2 { set outstr "bak"}
			}
		}
		461 {
 	 		switch -- $mode {
				0 { set outstr "bakc"}
				1 { set outstr "bak"}
			}
		}
		462 { set outstr "std"}
		465 { set outstr "o-se"}
		466 { set outstr "psaPFS"}
		469 { set outstr "ersNC-aln"}
		470 { set outstr "sidv-n"}
		471 {
	 		switch -- $mode {
				0 { set outstr "mti-s"}
				1 { set outstr "mti-so"}
			}
		}
		472 { set outstr "mti-sn"}
		473 {
	 		switch -- $mode {
				0 -
				1 {	set outstr "espfrv-iI"}
				2 -
				3 {	set outstr "espdrv-iI"}
			}
		}
		474 { set outstr "rp"}
		475 { set outstr "ted-nbs"}
		476 {
			set modetype [expr $mode % 3]
	 		switch -- $modetype {
				0 {	set outstr "fpjtyebsv-a"}
				1 -
				2 {	set outstr "fpjtyebsv-ac"}
			}
		}
		477 { set outstr "tabm-p"}
		478 { set outstr "cta"}
		479 { set outstr "gsc"}
		480 { set outstr "-w"}
		481 { set outstr "s-ce"}
		482 { set outstr "sopm-f"}
		483 {
	 		switch -- $mode {
				0  { set outstr "go-tfsxkr"}
				1  { set outstr "g-tfsxkr"}
				2  { set outstr "g-sxkr"}
				3  { set outstr "g-sxkr"}
				4  { set outstr "g-f"}
				5  { set outstr "g-sx"}
				6  { set outstr "b-kifs"}
				7  { set outstr "g-tsxkr"}
				8  { set outstr "g-tsnxkr"}
				9  { set outstr "g-sxrdc"}
				10 { set outstr "glhp-sxrdcf"}
				11 { set outstr "glhp-sxrdcf"}
				12 { set outstr "glhp-sxrdcf"}
				13 { set outstr "glhp-sxrdcf"}
				14 { set outstr "glhpbt-sxrdc"}
				15 { set outstr "glhpbt-sxrdcTFMAB"}
				16 { set outstr "glhpbt-sxrdcon"}
				17 { set outstr "glhpbt-sxrdconk"}
				18 { set outstr "glhp-sxrdc"}
				19 { set outstr "-s"}
				20 { set outstr "-s"}
				21 { set outstr "sp-PB"}
				22 { set outstr "abcdeqpon-sfrS"}
			}
		}
		488 { set outstr "sr-ft"}
		496 { set outstr "ks"}
		497 { set outstr "olrm"}
		499 { set outstr "l"}
		500 { set outstr "b-kip"}
		504 { set outstr "w-se"}
		1  -
		2  -
		6  -
		7  -
		9  -
		11 -
		17 -
		19 -
		21 -
		23 -
		25 -
		28 -
		29 -
		30 -
		31 -
		32 -
		33 -
		35 -
		36 -
		37 -
		42 -
		44 -
		45 -
		51 -
		52 -
		56 -
		57 -
		58 -
		60 -
		64 -
		69 -
		72 -
		73 -
		76 -
		78 -
		79 -
		84 -
		85 -
		86 -
		90 -
		93 -
		96 -
		99 -
		100 -
		101 -
		104 -
		109 -
		117 -
		150 -
		152 -
		153 -
		154 -
		155 -
		159 -
		165 -
		166 -
		167 -
		168 -
		162 -
		171 -
		172 -
		179 -
		181 -
		182 -
		183 -
		187 -
		189 -
		203 -
		208 -
 		218 -
		220 -
		222 -
		223 -
		224 -
		225 -
		227 -
		231 -
		235 -
		236 -
		248 -
		252 -
		254 -
		255 -
		257 -
		258 -
		259 -
		260 -
		261 -
		262 -
		263 -
		265 -
		266 -
		267 -
		268 -
		269 -
		271 -
		272 -
		273 -
		274 -
		275 -
		276 -
		278 -
		279 -
		280 -
		281 -
		282 -
		285 -
		291 -
		292 -
		294 -
		297 -
		298 -
		299 -
		300 -
		301 -
		302 -
		303 -
		304 -
		305 -
		306 -
		307 -
		308 -
		309 -
		310 -
		311 -
		312 -
		314 -
		315 -
		317 -
		320 -
		321 -
		322 -
		323 -
		324 -
		326 -
		328 -
		329 -
		330 -
		334 -
		335 -
		336 -
		342 -
		343 -
		344 -
		347 -
		352 - 
		356 -
		358 -
		359 -
		360 -
		361 -
		364 -
		365 -
		368 -
		370 -
		371 -
		375 -
		378 -
		379 -
		381 -
		382 -
		394 -
		400 -
		423 -
		426 -
		432 -
		434 -
		439 -
		440 -
		447 -
		448 -
		451 -
		452 -
		453 -
		463 -
		467 -
		468 -
		484 -
		498 -
		503 { set outstr ""}
	}
	if [string match "#" $outstr] {
		Inf "Failed to find flagnames for batch command"
		return ""
	}
	set len [string length $outstr]
	if {$len <= 0} {
		return $cmd
	}
	incr len -1

	set cmdlen [llength $cmd]
	incr cmdlen -1
	set k [string first "-" $outstr] 
	if {$k >= 0} {						;# SET STANDALONE FLAGS
		while {$len >= 0} {
			set flagname [string index $outstr $len]	;#	GET FLAG LETTER
			incr len -1
			if [string match "-" $flagname] {			;# IF END OF STANDALONE FLAGS, BREAK FROM HERE
				break
			} else {
				if {$cmdlen < 3} {
					Inf "Cmdline length anomaly in batch command creation"
					return ""
				}
				set val [lindex $cmd $cmdlen]	
				if {$val != 0} {
					set cmd [lreplace $cmd $cmdlen $cmdlen -$flagname]	;# SUBSTITUTE FLAG
				} else {
					set cmd [lreplace $cmd $cmdlen $cmdlen]				;# OR ELIMINATE PARAMETER
				}
				incr cmdlen -1
			}
		}
	}
	while {$len >= 0} {
		set flagname [string index $outstr $len]			;# GET FLAG LETTER
		set val [lindex $cmd $cmdlen]						;# GET PARAMETER VALUE
		set flagname $flagname
		append flagname $val								;# ATTACH PARAMETER TO FLAG LETTER
		set cmd [lreplace $cmd $cmdlen $cmdlen -$flagname]	;# REPLACE PARAM BY FLAGGED PARAM
		incr len -1
		incr cmdlen -1
	}
	return $cmd
}

proc IsMultipleCopyLine {line} {
	global prg evv
	if {[string match [lindex $line 0] [lindex $prg($evv(HOUSE_COPY)) 0]] \
	&&  [string match [lindex $line 1] [GetBatchProgname $evv(HOUSE_COPY)]] \
	&&  [string match [lindex $line 2] "2"] } {
		return 1
	}
	return 0
}

proc IsMultipleCopy {} {
	global pprg mmod evv

	if {($pprg == $evv(HOUSE_COPY)) && ($mmod == 2)} {
		return 1
	}
	return 0
}

#----- Does CDP process have a single outfile.

proc ProcessHasSingleOutfile {pprg mmod} {
	global evv	

	switch -regexp -- $pprg \
		^evv(DISTORT_CYCLECNT)$ - \
		^evv(GRAIN_COUNT)$ - \
		^evv(HOUSE_SORT)$ - \
		^evv(HOUSE_DISK)$ - \
		^evv(P_INFO)$ - \
		^evv(P_ZEROS)$ - \
		^evv(PITCH)$ - \
		^evv(RANDCUTS)$ - \
		^evv(RANDCHUNKS)$ - \
		^evv(INFO_PROPS)$ - \
		^evv(INFO_SFLEN)$ - \
		^evv(INFO_TIMELIST)$ - \
		^evv(INFO_TIMESUM)$ - \
		^evv(INFO_TIMEDIFF)$ - \
		^evv(INFO_SAMPTOTIME)$ - \
		^evv(INFO_TIMETOSAMP)$ - \
		^evv(INFO_MAXSAMP)$ - \
		^evv(INFO_LOUDCHAN)$ - \
		^evv(INFO_FINDHOLE)$ - \
		^evv(INFO_DIFF)$ - \
		^evv(INFO_CDIFF)$ - \
		^evv(INFO_MUSUNITS)$ - \
		^evv(WINDOWCNT)$ - \
		^evv(CHANNEL)$ - \
		^evv(FREQUENCY)$ - \
		^evv(MIXINBETWEEN)$ - \
	   	^evv(MIXTEST)$ - \
	 	^evv(SEARCH)$ - \
	   	^evv(PARTITION)$ - \
	   	^evv(SPECGRIDS)$ - \
	   	^evv(ISOLATE)$  - \
	   	^evv(PACKET)$ {
			return 0
		} \
		^evv(HOUSE_COPY)$ {
			if {$mmod == 2} {
				return 0
			}
		} \
		^evv(HOUSE_CHANS)$ {
			if {$mmod == 2} {
				return 0
			}
		} \
		^evv(HOUSE_EXTRACT)$ {
			if {$mmod == 2} {
				return 0
			}
		} \
		^evv(MOD_LOUDNESS)$ {
			if {($mmod == 7) || ($mmod == 8)} {
				return 0
			}
		} \
		^evv(TSTRETCH)$ {
			if {$mmod== 2} {
				return 0
			}
		} \
    	^evv(MIXMAX)$ {
			if {$mmod == 1} {
				return 0
			}
		} \
	   	^evv(RRRR_EXTEND)$ {
			if {$mmod == 3} {
				return 0
			}
		}

	return 1
}

#----- Is a CDP-reserved-tempname file later deleted by the batchfile??

proc LaterDeleted {cnt fnam} {
	global batch_file
	set thiscmd [string tolower [lindex [lindex $batch_file $cnt] 0]]
	if {[string match $thiscmd "rm"] || [string match $thiscmd "rmsf"]} {
		return 1
	}
	set len [llength $batch_file]
	set endindex [expr $len - 1]
	if {$cnt == $endindex} {
		return 0
	}
	incr cnt
	foreach line [lrange $batch_file $cnt end] {
		set thiscmd [string tolower [lindex $line 0]]
		set thisfnam [string tolower [lindex $line 1]]
		if {[string match $thiscmd "rm"] || [string match $thiscmd "rmsf"]} {
			if {[string match [file rootname $thisfnam] [file rootname $fnam]]} {
				return 1
			}
		}
	}
	return 0
}

proc ProcessHasAnOutfile {pprg mmod} {
	global standopos evv
	if {[IsStandalonePrognoWithNonCDPFormat $pprg]} {
		if {$standopos < 0} {
			return 0
		} else {
			return 1
		}
	}
	switch -regexp -- $pprg \
		^$evv(GRAIN_COUNT)$		-\
		^$evv(GRAIN_ASSESS)$	-\
		^$evv(P_INFO)$			-\
		^$evv(P_ZEROS)$			-\
		^$evv(INFO_SFLEN)$		-\
		^$evv(INFO_TIMESUM)$	-\
		^$evv(INFO_TIMEDIFF)$	-\
		^$evv(INFO_SAMPTOTIME)$	-\
		^$evv(INFO_TIMETOSAMP)$	-\
		^$evv(INFO_MAXSAMP)$	-\
		^$evv(INFO_LOUDCHAN)$	-\
		^$evv(INFO_FINDHOLE)$	-\
		^$evv(INFO_DIFF)$		-\
		^$evv(INFO_CDIFF)$		-\
		^$evv(INFO_MUSUNITS)$	-\
		^$evv(INFO_MAXSAMP2)$	-\
		^$evv(WINDOWCNT)$		-\
		^$evv(CHANNEL)$			-\
		^$evv(FREQUENCY)$		-\
		^$evv(MIXTEST)$			-\
		^$evv(SEARCH)$ {
			return 0
		} \
		^$evv(MOD_LOUDNESS)$ {
			if {$mmod == 7} {
				return 0
			}
		} \
		^$evv(MIXMAX)$ {
			if {$mmod == 1} {
				return 0
			}
		} \
		^$evv(TSTRETCH)$ {
			if {$mmod == 2} {
				return 0
			}
		} \
		^$evv(HOUSE_CHANS)$ {
			if {$mmod == 2} {
				return 0
			}
		} \
		^$evv(SPECTUNE)$ {
			if {$mmod == 4} {
				return 0
			}
		}

	return 1
}

#--- Substitute Chosen Soundfiles for input soundfiles of a selected batchfile

proc BatchSubstitute {} {
	global chlist pa evv wl pr_subst pr_subst_name excluded_batchfiles wstk bag_blines total_wksp_cnt

	if {![info exists chlist] || ([llength $chlist] <= 0)} {
		Inf "There Are No Files On Chosen Files List"
		return
	}
	set fcnt 0
	foreach fnam $chlist {
		if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
			Inf "File '$fnam' is Not A Soundfile"
			return
		}
		incr fcnt
	}
	set bfnam [GetDataFromBatchfile]
	if {[string length $bfnam] <= 0} {
		return
	}
	set blen 0	
	set badinfo ""
	foreach line $bag_blines {
		catch {unset nuline}
		foreach item $line {
			set done 0
			set got_wav 0
			foreach extt $evv(SNDFILE_EXTS) {
				if {[string match *$extt $item]} {
					set got_wav 1
				}
			}
			if {$got_wav} {
				if {$blen > 0} {
					set bcnt 0
					foreach bs $batchsnds {
						if {[string match $item $bs]} {
							lappend nuline [lindex $chlist $bcnt]
							set done 1
							break
						}
						incr bcnt
					}
					if {($bcnt == $blen) && ($blen < $fcnt)} {
						set nufnam [lindex $chlist $blen]
						lappend nuline $nufnam
						set done 1
						lappend batchsnds $item
						if {[file exists $item] && ([LstIndx $item $wl] >= 0)} {
							if {$pa($item,$evv(CHANS)) != $pa($nufnam,$evv(CHANS))} {
								append badinfo "FILES $item & $nufnam DO NOT HAVE SAME NUMBER OF CHANNELS\n"
							}
						} else {
							append badinfo "CANNOT COMPARE CHANNEL COUNT OF $item & $nufnam\n"
						}
						incr blen
					}
				} else {
					set nufnam [lindex $chlist 0]
					lappend nuline $nufnam
					set done 1
					lappend batchsnds $item
					set blen 1
					if {[file exists $item] && ([LstIndx $item $wl] >= 0)} {
						if {$pa($item,$evv(CHANS)) != $pa($nufnam,$evv(CHANS))} {
							append badinfo "FILES $item & $nufnam DO NOT HAVE SAME NUMBER OF CHANNELS\n"
						}
					} else {
						append badinfo "CANNOT COMPARE CHANNEL COUNT OF $item & $nufnam\n"
					}
				}
			}
			if {!$done} {
				lappend nuline $item
			}
		}
		lappend outlines $nuline
	}
	if {$blen != $fcnt} {
		Inf "Insufficient Files In Batchfile To Do Substitution"
		return
	}
	if {[string length $badinfo] > 0} {
		set choice [tk_messageBox -type yesno -message "$badinfo \n\nIs this OK?" -icon question -parent [lindex $wstk end]]
		if [string match $choice "no"] {
			return
		}
	}
	set f .bedit
	if [Dlg_Create $f "BATCH FILE SUBSTITUTION" "set pr_subst 0" -borderwidth $evv(SBDR)] {
		set f1 [frame $f.1 -borderwidth $evv(BBDR)]
		set f2 [frame $f.2 -borderwidth $evv(BBDR)]
		set f3 [frame $f.3 -borderwidth $evv(BBDR)]
		set f4 [frame $f.4 -borderwidth $evv(BBDR)]
		set f4a [frame $f.4.a -borderwidth $evv(BBDR)]
		set f4b [frame $f.4.b -borderwidth $evv(BBDR)]
		button $f1.ok -text "OK" -command "set pr_subst 1" -highlightbackground [option get . background {}]
		button $f1.q -text "Abandon" -command "set pr_subst 0" -highlightbackground [option get . background {}]
		pack $f1.ok -side left 
		pack $f1.q -side right

		label $f2.ll -text "New batchfile name   "
		entry $f2.e  -textvariable "pr_subst_name" -width 20
		pack $f2.ll $f2.e -side left -padx 3

		label $f3.ll -text "ORIGINAL BATCHFILE ...... & EDITED BATCHFILE"
		pack $f3.ll -side top
		set t1 [text $f4a.t -setgrid true -wrap word -width 64 -height 32 \
		-xscrollcommand "$f4a.sx set" -yscrollcommand "$f4a.sy set"]
		scrollbar $f4a.sy -orient vert  -command "$f4a.t yview"
		scrollbar $f4a.sx -orient horiz -command "$f4a.t xview"
		pack $f4a.t -side left -fill both -expand true
		pack $f4a.sy -side right -fill y

		set t2 [text $f4b.t -setgrid true -wrap word -width 64 -height 32 \
		-xscrollcommand "$f4b.sx set" -yscrollcommand "$f4b.sy set"]
		scrollbar $f4b.sy -orient vert  -command "$f4b.t yview"
		scrollbar $f4b.sx -orient horiz -command "$f4b.t xview"
		pack $f4b.t -side left -fill both -expand true
		pack $f4b.sy -side right -fill y

		pack $f4a $f4b -side left

		pack $f.1 -side top -fill x -expand true
		pack $f.2 $f.3 $f.4 -side top 
		bind $f <Escape> {set pr_subst 0}
	}
	wm resizable $f 1 1
	$t1 delete 1.0 end
	foreach line $bag_blines {
		$t1 insert end "$line\n"
	}	
	$t2 delete 1.0 end
	foreach line $outlines {
		$t2 insert end "$line\n"
	}	
	set pr_subst_name ""
	raise $f
	update idletasks
	StandardPosition $f
	set pr_subst 0
	set finished 0
	My_Grab 0 $f pr_subst $f.2.e
	while {!$finished} {
		tkwait variable pr_subst
		if {$pr_subst} {
			if {[string length $pr_subst_name] <= 0 }	 {
				Inf "No Filename Given"
				continue
			}
			set pr_subst_name [string tolower $pr_subst_name]
			set dir [file dirname $pr_subst_name]
			set name  [file tail $pr_subst_name]
			set rname [file rootname $pr_subst_name]
			set extname [file extension $pr_subst_name]
			if {![string match $name $rname] && ![string match $evv(BATCH_EXT) $extname]} {
				Inf "You Cannot Use Extensions In The Filename, Here"
				continue
			} elseif {[lsearch $excluded_batchfiles $rname] >= 0} {
				Inf "This Is A Reserved Batchfile Name: Please Choose Another Name."
				continue
			}
			if {![ValidCdpFilename $rname 1]} {
				continue
			}
			set w_bname $pr_subst_name
			if {[string length $extname] <= 0} {
				append w_bname $evv(BATCH_EXT)
			}
			if [file exists $w_bname] {
				set choice [tk_messageBox -type yesno -message "File '$w_bname' already exists : Overwrite It?" \
					-icon question -parent [lindex $wstk end]]
				if [string match $choice "no"] {
					continue
				} else {
					set it_exists 1
				}
			}
			if [catch {open $w_bname "w"} zib] {
				Inf "Cannot Open File '$w_bname'"
				catch {unset it_exists}
				continue
			}
			puts $zib [$t2 get 1.0 end]
			close $zib
			if {[info exists it_exists]} {
				DummyHistory $w_bname "BATCH_EDITED_OR_OVERWRITTEN"
			} else {
				DummyHistory $w_bname "BATCH_CREATED"
			}
			set i [LstIndx $w_bname $wl]
			if {$i >= 0} {
				PurgeArray $w_bname
				RemoveFromChosenlist $w_bname
				incr total_wksp_cnt -1
				$wl delete $i
			}
			FileToWkspace $w_bname 0 0 0 0 1
			set finished 1
		} else {
			break
		}
	}
	My_Release_to_Dialog $f
	destroy $f
}

proc BatchSubstituteTell {} {

	set msg "CONVENTIONS FOR AUTOMATIC BATCHFILE EDITING\n"
	append msg "\n"
	append msg "(1)  TO DIFFERENTIATE INFILES FROM OUTFILES\n"
	append msg "        used inside the batchfile ...\n"
	append msg "\n"
	append msg "        Write INFILES WITH (an appropriate)\n"
	append msg "        file extension.\n"
	append msg "        Write OUTFILES with NO extension.\n"
	append msg "\n"
	append msg "(2)  SUBSTITUTION OF INPUTFILES uses\n"
	append msg "\n"
	append msg "        the (N) SOUNDfiles on Chosen Files list\n"
	append msg "        to replace the (first N) input SOUNDfiles\n"
	append msg "        in the Batchfile\n"
	append msg "\n"
	append msg "(3)  SUBSTITUTION OF OUTPUTFILES can be done\n"
	append msg "        in the 'Extract/Edit' Option.\n"
	append msg "\n"
	append msg "        Outfiles can be replaced in the batchfile\n"
	append msg "        and the new batchfile saved.\n"
	append msg "\n"
	append msg "(4)  CHANGE OF DATAFILES used in batchfile..\n"
	append msg "\n"
	append msg "        these can be selected, edited,\n"
	append msg "        and/or replaced, and new batchfile saved.\n"
	append msg "        Use the 'Extract/Edit' option.\n"
	Inf $msg
}

#--- Extract from batchfile a list of inputfiles, outfiles and control-data-files

proc BatchGetFiles {deltyp} {
	global pa evv wl pr_baget bag_blines pr_baget_name wstk no_bag bag_newname total_wksp_cnt
	global baget_typ
	set bfnam [GetDataFromBatchfile]
	if {[string length $bfnam] <= 0} {
		return
	}
	SortFilesInsideBatchfile $deltyp
	set no_bag 1
	set f .batget
	if [Dlg_Create $f "EXTRACT/EDIT DATA FROM BATCH FILE" "set pr_baget 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0 -borderwidth $evv(BBDR)]
		set f00 [frame $f.00 -height 1 -bg [option get . foreground {}]]
		set f1 [frame $f.1 -borderwidth $evv(BBDR)]
		set fa [frame $f1.a -borderwidth $evv(BBDR)]
		set faa [frame $f1.aa -width 1 -bg [option get . foreground {}]]
		set fb [frame $f1.b -borderwidth $evv(BBDR)]
		button $f0.q -text "Close" -command "set pr_baget 0" -highlightbackground [option get . background {}]
		pack $f0.q -side right

		set f1a [frame $fa.a]
		set f1b [frame $fa.b]
		set f1c [frame $fa.c]
		set f1k [frame $fa.k]
		set f1d [frame $fa.d]
		set f1e [frame $fa.e]
		label $f1a.ll -text "EXTRACTED FILES"
		pack $f1a.ll -side top
		button $f1b.ok -text "Keep This List" -command "set pr_baget 1" -highlightbackground [option get . background {}]
		pack $f1b.ok -side top -pady 2
		label $f1k.ll -text "Listing name"
		entry $f1k.e  -textvariable "pr_baget_name" -width 20
		pack $f1k.ll $f1k.e -side left -padx 1 -pady 2
		label $f1d.ll -text ""
		pack $f1d.ll -side top -pady 2

		set t2 [Scrolled_Listbox $f1e.t -width 64 -height 24 -selectmode single]
		pack $f1e.t -side top -fill both -expand true

		set f2a [frame $fb.a]
		set f2b [frame $fb.b]
		set f2c [frame $fb.c]
		set f2d [frame $fb.d]
		set f2e [frame $fb.e]

		set t1 [text $f2e.t -setgrid true -wrap word -width 84 -height 32 \
		-xscrollcommand "$f2e.sx set" -yscrollcommand "$f2e.sy set"]
		scrollbar $f2e.sy -orient vert  -command "$f2e.t yview"
		scrollbar $f2e.sx -orient horiz -command "$f2e.t xview"
		pack $f2e.t -side left -fill both -expand true
		pack $f2e.sy -side right -fill y

		label $f2a.ll -text "BATCHFILE DISPLAYED"
		pack $f2a.ll -side top
		button $f2b.but -text "Save New Batchfile" -command "SaveNewBatchFile $t1 1" -highlightbackground [option get . background {}]
		pack $f2b.but -side top
		label $f2c.ll -text "NEW BATCHFILE NAME"
		pack $f2c.ll -side top
		entry $f2d.e -textvariable bag_newname -width 24
		pack $f2d.e -side top

		radiobutton $f1c.i -variable baget_typ -text Inputfiles   -command "BagList .batget.1.a.e.t.list i" -value 0
		radiobutton $f1c.o -variable baget_typ -text Outputfiles  -command "BagList .batget.1.a.e.t.list o" -value 1
		radiobutton $f1c.t -variable baget_typ -text Textfiles    -command "BagList .batget.1.a.e.t.list t" -value 2
		
		pack $f1c.i $f1c.o $f1c.t -side left

		pack $f1a $f1c $f1b $f1k $f1d $f1e  -side top
		pack $f2a $f2b $f2c $f2d $f2e  -side top

		pack $fa -side left
		pack $faa -side left -fill y -expand true
		pack $fb -side left
		pack $f.0 -side top -fill x -expand true
		pack $f.00 -side top -fill x -expand true
		pack $f.1 -side top
		bind $f <Escape> {set pr_baget 0}
	}
	wm resizable $f 1 1
	set baget_typ -1
	$f.1.b.a.ll config -text "BATCHFILE DISPLAYED : $bfnam"
	$f.1.b.b.but config -text "" -bd 0 -state disabled
	$f.1.b.c.ll config -text ""
	$f.1.b.d.e config -state disabled -bd 0
	$t1 delete 1.0 end
	foreach line $bag_blines {
		$t1 insert end "$line\n"
	}	
	$t2 delete 0 end
	set pr_baget_name ""
	raise $f
	update idletasks
	StandardPosition $f
	set pr_baget 0
	set finished 0
	My_Grab 0 $f pr_baget $f.1.b.e
	while {!$finished} {
		tkwait variable pr_baget
		if {$pr_baget} {
			if {[string length $pr_baget_name] <= 0 }	 {
				Inf "No Filename Given"
				continue
			}
			set pr_baget_name [string tolower $pr_baget_name]
			set dir [file dirname $pr_baget_name]
			set name  [file tail $pr_baget_name]
			set rname [file rootname $pr_baget_name]
			set extname [file extension $pr_baget_name]
			if {![string match $name $rname] && ![string match $evv(TEXT_EXT) $extname]} {
				Inf "You Cannot Use Extensions In The Filename, Here"
				continue
			}
			if {![ValidCdpFilename $rname 1]} {
				continue
			}
			set w_bname $pr_baget_name
			if {[string length $extname] <= 0} {
				append w_bname $evv(TEXT_EXT)
			}
			if [file exists $w_bname] {
				set choice [tk_messageBox -type yesno -message "File '$w_bname' already exists : Overwrite It?" \
					-icon question -parent [lindex $wstk end]]
				if [string match $choice "no"] {
					continue
				} else {
					set it_exists 1
				}
			}
			if [catch {open $w_bname "w"} zib] {
				Inf "Cannot Open File '$w_bname'"
				catch {unset it_exists}
				continue
			}
			foreach item [$t2 get 0 end] {
				puts $zib $item
			}
			close $zib
			if {[info exists it_exists]} {
				DummyHistory $w_bname "EDITED_OR_OVERWRITTEN"
			} else {
				DummyHistory $w_bname "CREATED"
			}
			set i [LstIndx $w_bname $wl]
			if {$i >= 0} {
				PurgeArray $w_bname
				RemoveFromChosenlist $w_bname
				incr total_wksp_cnt -1
				$wl delete $i
			}
			FileToWkspace $w_bname 0 0 0 0 1
			Inf "File '$w_bname' Is Now On The Workspace"
			set i [LstIndx $w_bname $wl]
			if {$i >= 0} {
				$wl selection clear 0 end
				$wl selection set $i
			}
		} else {
			break
		}
	}
	My_Release_to_Dialog $f
	destroy $f
}

#--- List inputfiles, outfiles or control-data-files in a batchfile

proc BagList {t typ} {
	global ibfiles obfiles tbfiles no_bag
	$t delete 0 end
	switch -- $typ {
		i {
			if {[llength $ibfiles] <= 0} {
				$t insert end "FAILED TO FIND ANY INPUT FILES\n"
				set no_bag 1
				return
			}
			foreach fnam $ibfiles {
				$t insert end $fnam
			}	
			.batget.1.a.d.ll config -text ""
			bind $t <ButtonRelease>  {}
			set no_bag 0
		}
		o {
			if {[llength $obfiles] <= 0} {
				$t insert end "FAILED TO FIND ANY OUTPUT FILES\n"
				set no_bag 1
				return
			}
			foreach fnam $obfiles {
				$t insert end $fnam
			}
			.batget.1.a.d.ll config -text "CONTROL SELECT TO REPLACE"
			bind $t <ButtonRelease>  {}
			bind $t <Control-ButtonRelease-1>  "BatchOutputReplace $t %y"
			set no_bag 0
		}
		t {
			if {[llength $tbfiles] <= 0} {
				$t insert end "FAILED TO FIND ANY TEXT DATA FILES\n"
				set no_bag 1
				return
			}
			foreach fnam $tbfiles {
				$t insert end $fnam
			}
			.batget.1.a.d.ll config -text "SELECT FILE TO EDIT: CONTROL SELECT TO REPLACE"
			bind $t <ButtonRelease>  "BatchElementEdit $t"
			bind $t <Control-ButtonRelease-1>  "BatchElementReplace $t %y"
			set no_bag 0
		}
	}
}

#---- Is the file a soundsystem file or a textfile (i.e. a possible CDP-process input-file)

proc InfileExt {str} {
	global evv
	set ext [file extension $str]

	foreach item $evv(SNDFILE_EXTS) {
		if {[string match $ext $item]} {
			return 1
		}
	}
	if {[string match $ext $evv(ANALFILE_EXT)]} {
		return 1
	}
	if {[string match $ext $evv(PITCHFILE_EXT)]} {
		return 1
	}
	if {[string match $ext $evv(TRANSPOSFILE_EXT)]} {
		return 1
	}
	if {[string match $ext $evv(FORMANTFILE_EXT)]} {
		return 1
	}
	if {[string match $ext $evv(ENVFILE_EXT)]} {
		return 1
	}
	if {[IsATextfileExtension $ext]} {
		return 1
	}
	return 0
}

#---- Edit a slected datafile within a batchfile

proc BatchElementEdit {t} {
	global from_batchedit pa evv
	set i [$t curselection]
	set fnam [$t get $i]
	if {![info exists pa($fnam,$evv(FTYP))]} {
		Inf "File Is Not On Workspace: Cannot Edit"
		return
	}
	set from_batchedit ""
	Dlg_EditTextfile $fnam -1 0 batch
	if {([string length $from_batchedit] > 0) && ![string match $from_batchedit $fnam]} {
		BatchDatafileReplace data $t $fnam $from_batchedit $i
		BatchDatafileSave
		set from_batchedit ""
	}
}

#---- Save a modified batchfile

proc SaveNewBatchFile {t reset} {
	global bag_newname wstk evv total_wksp_cnt wl excluded_batchfiles
	if {[string length $bag_newname] <= 0 }	 {
		Inf "No Filename Given"
		return
	}
	set bag_newname [string tolower $bag_newname]
	set dir [file dirname $bag_newname]
	set name  [file tail $bag_newname]
	set rname [file rootname $bag_newname]
	set extname [file extension $bag_newname]
	if {![string match $name $rname] && ![string match $evv(BATCH_EXT) $extname]} {
		Inf "You Cannot Use Extensions In The Filename, Here"
		return
	} elseif {[lsearch $excluded_batchfiles $rname] >= 0} {
		Inf "This Is A Reserved Batchfile Name: Please Choose Another Name."
		return
	}
	if {![ValidCdpFilename $rname 1]} {
		return
	}
	set w_bname $bag_newname
	if {[string length $extname] <= 0} {
		append w_bname $evv(BATCH_EXT)
	}
	if [file exists $w_bname] {
		set choice [tk_messageBox -type yesno -message "File '$w_bname' already exists : Overwrite It?" \
			-icon question -parent [lindex $wstk end]]
		if [string match $choice "no"] {
			return
		} else {
			set it_exists 1
		}
	}
	if [catch {open $w_bname "w"} zib] {
		Inf "Cannot Open File '$w_bname'"
		catch {unset it_exists}
		return
	}
	puts $zib [$t get 1.0 end]
	close $zib
	if {[info exists it_exists]} {
		DummyHistory $w_bname "EDITED_OR_OVERWRITTEN"
	} else {
		DummyHistory $w_bname "CREATED"
	}
	set i [LstIndx $w_bname $wl]
	if {$i >= 0} {
		PurgeArray $w_bname
		RemoveFromChosenlist $w_bname
		incr total_wksp_cnt -1
		$wl delete $i
	}
	FileToWkspace $w_bname 0 0 0 0 1
	set bag_newname ""
	if {$reset} {
		.batget.1.b.b.but config -state disabled -text "" -bd 0
		.batget.1.b.c.ll config -text ""
		.batget.1.b.d.e config -state disabled -bd 0
		.batget.1.b.a.ll config -text "BATCHFILE DISPLAYED: $w_bname"
	}
	Inf "File '$w_bname' Is Now On The Workspace"
}

#-------- Select a file to replace an existing datafile used in a batchfile

proc BatchElementReplace {t y} {
	global pa evv wstk batrep pr_batrep wl do_bd_save
	set i [$t nearest $y]
	set zfnam [$t get $i]
	set do_bd_save 0
	set f .bat_rep
	if [Dlg_Create $f "REPLACE BATCHFILE DATA FILE" "set pr_batrep 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0 -borderwidth $evv(BBDR)]
		set f1 [frame $f.1 -borderwidth $evv(BBDR)]
		set f2 [frame $f.2 -borderwidth $evv(BBDR)]
		button $f0.ok -text "Replace" -command "set pr_batrep 1" -highlightbackground [option get . background {}]
		label $f0.fnam -text ""
		button $f0.q -text "Close" -command "set pr_batrep 0" -highlightbackground [option get . background {}]
		pack $f0.ok $f0.fnam -side left -padx 2
		pack $f0.q -side right
		label $f1.ll -text "Replacement File"
		entry $f1.e -textvariable batrep -width 48
		pack $f1.ll $f1.e -side left -padx 2
		Scrolled_Listbox $f2.s -width 64 -height 24 -selectmode single
		pack $f2.s -side top -fill both -expand true
		pack $f0 -side top -fill x -expand true
		pack $f1 $f2 -side top
		bind $f.2.s.list <ButtonRelease> "SelectReplacementDatafileForBatch .bat_rep.2.s.list %y"
		bind $f <Escape> {set pr_batrep 0}
		bind $f <Return> {set pr_batrep 1}
	}
	set batrep ""
	$f.0.fnam config -text $zfnam
	raise $f
	update idletasks
	StandardPosition $f
	set pr_batrep 0
	set finished 0
	$f.2.s.list delete 0 end
	foreach fnam [$wl get 0 end] {
		if {$pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)} {
			$f.2.s.list insert end $fnam
		}
	}
	My_Grab 0 $f pr_batrep $f.1.e
	while {!$finished} {
		tkwait variable pr_batrep
		if {$pr_batrep} {
			if {[string length $batrep] <= 0} {
				Inf "No Filename Entered"
				continue
			}
			if {![file exists $batrep]} {
				Inf "File '$batrep' Does Not Exist (Include the file extension)"
				continue
			}
			set j [LstIndx $batrep $wl]
			if {$j < 0} {
				if {[DoMinParse $batrep] <= 0} {
					Inf "File '$batrep' Is Not A Known Type"
					continue
				}
			}
			if {!($pa($batrep,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
				Inf "File '$batrep' Is Not A Textfile"
				continue
			}
			if {$j <= 0} {
				FileToWkspace $batrep 0 0 0 0 0
			}
			set msg "This Editor Does Not Check Whether Your File Is Appropriate: Ok To Proceed?"
			set choice [tk_messageBox -type yesno -message $msg -icon question -parent [lindex $wstk end]]
			if [string match $choice "yes"] {
				BatchDatafileReplace data $t $zfnam $batrep $i
				set do_bd_save 1
			}
			break
		} else {
			break
		}
	}
	My_Release_to_Dialog $f
	destroy $f
	if {$do_bd_save} {
		BatchDatafileSave
	}
}

#-------- Replace a datafile within a batchfile

proc BatchDatafileReplace {typ t fnam nufnam k} {
	global obfiles tbfiles bag_blines wstk from_batchedit
	
	$t delete 0 end
	switch -- $typ {
		"data" {
			set tbfiles [lreplace $tbfiles $k $k $nufnam]
			foreach z $tbfiles {
				$t insert end $z
			}
		}
		"out" {
			set obfiles [lreplace $obfiles $k $k $nufnam]
			$t delete 0 end
			foreach z $obfiles {
				$t insert end $z
			}
		}
	}
	set len [llength $bag_blines]
	set n 0
	while {$n < $len} {
		set line [lindex $bag_blines $n] 
		set ilen [llength $line]
		set i 0
		catch {unset nuline}
		set altered 0
		while {$i < $ilen} {
			set item [lindex $line $i]
			if {[string match $fnam $item]} {
				lappend nuline $nufnam
				set altered 1
			} else {
				lappend nuline $item
			}
			incr i
		}
		if {$altered} {
			set bag_blines [lreplace $bag_blines $n $n $nuline]
		}
		incr n
	}
	.batget.1.b.e.t delete 1.0 end
	foreach line $bag_blines {
		.batget.1.b.e.t insert end "$line\n"
	}
}

#--- Save a modified batchfile

proc BatchDatafileSave {} {
	global wstk
	
	set choice [tk_messageBox -type yesno -message "Save New Batchfile ?" -icon question -parent [lindex $wstk end]]
	if {$choice == "yes"} {
		.batget.1.b.b.but config -state normal -text "Save New Batchfile" -bd 2
		.batget.1.b.c.ll config -text "NEW BATCHFILE NAME"
		.batget.1.b.d.e config -state normal -bd 2
	} else {
		.batget.1.b.a.ll config -text "BATCHFILE DISPLAYED: \[temporary\]"
	}
}

#--- select a replacement datafile, from a list, to replace existing datafile in batchfile

proc SelectReplacementDatafileForBatch {t y} {
	global batrep
	set i [$t nearest $y]
	set batrep [$t get $i]
}

#-------- Select an outfile to replace in a batchfile

proc BatchOutputReplace {t y} {
	global pa evv wstk batorep pr_batorep wl do_bd_save
	set i [$t nearest $y]
	set zfnam [$t get $i]
	set do_bd_save 0
	set f .bat_orep
	if [Dlg_Create $f "REPLACE BATCHFILE OUTPUT FILE" "set pr_batorep 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0 -borderwidth $evv(BBDR)]
		set f1 [frame $f.1 -borderwidth $evv(BBDR)]
		button $f0.ok -text "Replace" -command "set pr_batorep 1" -highlightbackground [option get . background {}]
		label $f0.fnam -text ""
		button $f0.q -text "Close" -command "set pr_batorep 0" -highlightbackground [option get . background {}]
		pack $f0.ok $f0.fnam -side left -padx 2
		pack $f0.q -side right
		label $f1.ll -text "New Outfile Name"
		entry $f1.e -textvariable batorep -width 48
		pack $f1.ll $f1.e -side left -padx 2
		pack $f0 -side top -fill x -expand true
		pack $f1 -side top -pady 2
		bind $f <Return> {set pr_batorep 1}
		bind $f <Escape> {set pr_batorep 0}
	}
	set batorep ""
	$f.0.fnam config -text $zfnam
	raise $f
	set pr_batorep 0
	set finished 0
	My_Grab 0 $f pr_batorep $f.1.e
	while {!$finished} {
		tkwait variable pr_batorep
		if {$pr_batorep} {
			if {[string length $batorep] <= 0} {
				Inf "No Filename Entered"
				continue
			}
			set w_bname [string tolower $batorep]
			if {![ValidCDPRootname $w_bname]} {
				continue
			}
			set zob $w_bname$evv(SNDFILE_EXT)
			if {[file exists $zob]} {
				Inf "File $zob already exists : You cannot overwrite it from a batchfile."
				continue
			}
			BatchDatafileReplace out $t $zfnam $w_bname $i
			set do_bd_save 1
			break
		} else {
			break
		}
	}
	My_Release_to_Dialog $f
	destroy $f
	if {$do_bd_save} {
		BatchDatafileSave
	}
}

#---- Editing parameters globally in Batchfile

proc BatchGlobalParams {} {
	global wl pa evv bag_blines pr_batglob bag_newname batch_toreplace batch_replace excluded_batchfiles wstk total_wksp_cnt
	global globatcols globatrows

	set bfnam [GetDataFromBatchfile]
	if {[string length $bfnam] <= 0} {
		return
	}
	set f .batglob
	if [Dlg_Create $f "EXTRACT/EDIT DATA FROM BATCH FILE" "set pr_batglob 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0 -borderwidth $evv(BBDR)]
		set f00 [frame $f.00 -height 1 -bg [option get . foreground {}]]
		set f1 [frame $f.1 -borderwidth $evv(BBDR)]
		set f2 [frame $f.2 -borderwidth $evv(BBDR)]
		set f3 [frame $f.3 -borderwidth $evv(BBDR)]
		set f4 [frame $f.4 -borderwidth $evv(BBDR)]
		set f5 [frame $f.5 -borderwidth $evv(BBDR)]
		set f5a [frame $f.5a -borderwidth $evv(BBDR)]
		set f6 [frame $f.6 -borderwidth $evv(BBDR)]
		button $f0.q -text "Close" -command "set pr_batglob 0" -highlightbackground [option get . background {}]
		pack $f0.q -side right

		set t1 [text $f6.t -setgrid true -wrap word -width 84 -height 32 \
		-xscrollcommand "$f6.sx set" -yscrollcommand "$f6.sy set"]
		scrollbar $f6.sy -orient vert  -command "$f6.t yview"
		scrollbar $f6.sx -orient horiz -command "$f6.t xview"
		pack $f6.t -side left -fill both -expand true
		pack $f6.sy -side right -fill y

		label $f1.ll -text "BATCHFILE DISPLAYED"
		button $f2.but -text "Save New Batchfile" -command "SaveNewBatchFile $t1 0" -highlightbackground [option get . background {}]
		pack $f2.but -side top
		label $f3.ll -text "NEW BATCHFILE NAME"
		entry $f3.e -textvariable bag_newname -width 24
		pack $f3.ll $f3.e -side left -padx 2

		button $f4.l1 -text "Get Item Below or to Right of Cursor" -command "GetMarkedItemInBatch $t1" -highlightbackground [option get . background {}]
		entry $f4.e1 -textvariable batch_toreplace -state normal -width 16
		label $f4.l2 -text "Replace by"
		entry $f4.e2 -textvariable batch_replace -width 16
		button $f4.ref -text Ref -command "RefGet batch" -bg $evv(HELP) -highlightbackground [option get . background {}]
		pack $f4.l1 $f4.e1 $f4.l2 $f4.e2 $f4.ref -side left -padx 2
		button $f5.a -text "Do Search" -command "FindValInBatch $t1" -highlightbackground [option get . background {}]
		button $f5.b -text "Do Replace" -command "ReplaceValInBatch $t1" -highlightbackground [option get . background {}]
		button $f5.c -text "Replace All Txt" -command "ReplaceAllValsInBatch $t1" -highlightbackground [option get . background {}]
		button $f5.d -text "Repl Vals in Col" -command "ReplaceAllParamInBatch $t1" -highlightbackground [option get . background {}]
		pack $f5.a $f5.b $f5.c $f5.d -side left -padx 3
		label $f.5a.ll0 -text "Rows      "
		label $f.5a.ll1 -text "Columns      "
		pack $f.5a.ll0 $f.5a.ll1 -side left -padx 6
		pack $f0 -side top -fill x -expand true
		pack $f00 -side top -pady 2 -fill x -expand true
		pack $f1 $f2 $f3 $f4 $f5 $f5a -side top -pady 2
		pack $f6 -side top -fill x -expand true
		bind $f <Escape> {set pr_batglob 0}
	}
	wm resizable $f 1 1
	$f.1.ll config -text "BATCHFILE DISPLAYED : $bfnam"
	$t1 delete 1.0 end
	set cnt 0
	foreach line $bag_blines {
		if {$cnt == 0} {
			set ccnt [llength $line]
		} else {
			if {$ccnt != [llength $line]} {
				set ccnt 0
			}
		}
		$t1 insert end "$line\n"
		incr cnt
	}
	$f.5a.ll0 config -text "$cnt Rows"
	if {$ccnt == 0} {
		$f.5a.ll1 config -text "Columns vary"
	} else {
		$f.5a.ll1 config -text "$ccnt Columns"
	}
	set bag_newname ""
	set batch_toreplace ""
	set batch_replace ""
	ForceVal .batglob.4.e1 $batch_toreplace
	raise $f
	update idletasks
	StandardPosition $f
	set pr_batglob 0
	set finished 0
	My_Grab 0 $f pr_batglob $f.6.t
	while {!$finished} {
		tkwait variable pr_batglob
		if {$pr_batglob} {
			if {[string length $bag_newname] <= 0 }	 {
				Inf "No Batch Filename Given"
				continue
			}
			set bag_newname [string tolower $bag_newname]
			set dir [file dirname $bag_newname]
			set name  [file tail $bag_newname]
			set rname [file rootname $bag_newname]
			set extname [file extension $bag_newname]
			if {![string match $name $rname] && ![string match $evv(BATCH_EXT) $extname]} {
				Inf "You Cannot Use Extensions In The Filename, Here"
				return
			} elseif {[lsearch $excluded_batchfiles $rname] >= 0} {
				Inf "This Is A Reserved Batchfile Name: Please Choose Another Name."
				return
			}
			if {![ValidCdpFilename $rname 1]} {
				return
			}
			set w_bname $bag_newname
			if {[string length $extname] <= 0} {
				append w_bname $evv(BATCH_EXT)
			}
			if [file exists $w_bname] {
				set choice [tk_messageBox -type yesno -message "File '$w_bname' already exists : Overwrite It?" \
					-icon question -parent [lindex $wstk end]]
				if [string match $choice "no"] {
					return
				} else {
					set it_exists 1
				}
			}
			if [catch {open $w_bname "w"} zib] {
				Inf "Cannot Open File '$w_bname'"
				catch {unset it_exists}
				return
			}
			puts $zib [.batget.1.b.e.t get 1.0 end]
			close $zib
			if {[info exists it_exists]} {
				DummyHistory $w_bname "EDITED_OR_OVERWRITTEN"
			} else {
				DummyHistory $w_bname "CREATED"
			}
			set i [LstIndx $w_bname $wl]
			if {$i >= 0} {
				PurgeArray $w_bname
				RemoveFromChosenlist $w_bname
				incr total_wksp_cnt -1
				$wl delete $i
			}
			FileToWkspace $w_bname 0 0 0 0 1
			break
		} else {
			break
		}
	}
	My_Release_to_Dialog $f
	destroy $f
}


proc FindValInBatch {t} {
	global last_bsearch_string lastbstart lastbcnt batch_toreplace last_bend
	if {[string length $batch_toreplace] <= 0} {
		Inf "No Search String Given"
		return 1
	}
	set search_string $batch_toreplace
	set len [string length $search_string]
	if {[info exists last_bsearch_string] && [string match $last_bsearch_string $search_string]} {
		set searchstart $last_bend
	} else {
		set searchstart 1.0
	}
	catch {$t tag delete hilite}
	set start [$t search -count cnt -regexp -- $search_string $searchstart]
	if {[info exists cnt] && ($cnt == $len) && ([string length $start] > 0)} {
		$t tag configure hilite -background blue -foreground white
		$t see $start
		$t tag add hilite $start "$start +$cnt chars"
		set lastbcnt $cnt
		set lastbstart $start
		set k [string first "." $lastbstart]
		set lineno [string range $lastbstart 0 $k]
		set charno [string range $lastbstart [expr $k + 1] end]
		incr charno $lastbcnt
		set last_bend $lineno$charno
		set last_bsearch_string $search_string 
		return 1
	}
	Inf "No More Matching Strings Found"
	return 0
}

proc GetMarkedItemInBatch {t} {
	global batch_toreplace last_bsearch_string lastbstart lastbcnt last_bend
	set search_string [$t get "insert wordstart" "insert wordend"]
	if {![info exists search_string] || ([string length $search_string] <= 0)} {
		Inf "No Replacement String Marked"
		return
	} else {
		set lastbcnt [string length $batch_toreplace]
		set lastbstart [$t index "insert wordstart"]
		set last_bend [$t index "insert wordend"]
		set k [string first "." $lastbstart]
		set lineno [string range $lastbstart 0 $k]
		set charno [string range $lastbstart [expr $k + 1] end]
		set xtra 0
		while {$charno > 0} {
			incr charno -1
			incr xtra
			set thischar [$t get $lineno$charno]
			if {[regexp {[\ \t\n]} $thischar]} {
				incr charno
				incr xtra -1
				break
			}
		}
		set lastbstart $lineno$charno
		set k [string first "." $last_bend]
		set lineno [string range $last_bend 0 $k]
		set charno [string range $last_bend [expr $k + 1] end]
		set OK 1
		set thischar [$t get $lineno$charno]
		if {![regexp {[\ \t\n]} $thischar]} {
			while {$OK} {
				incr charno
				incr xtra
				set thischar [$t get $lineno$charno]
				if {[regexp {[\ \t\n]} $thischar]} {
					set OK 0
				}
			}
		}
		set last_bend $lineno$charno
		incr lastbcnt $xtra
		catch {$t tag delete hilite}
		set batch_toreplace [$t get $lastbstart $last_bend]
		ForceVal .batglob.4.e1 $batch_toreplace
		set last_bsearch_string $batch_toreplace
		$t tag add hilite $lastbstart $last_bend
		$t tag configure hilite -background blue -foreground white
	}
}

proc ReplaceValInBatch {t} {
	global lastbstart lastbcnt batch_replace
	if {[string length $batch_replace] <= 0} {
		Inf "No Replacement Value Given"
		return
	}
	if {[info exists lastbstart]} {
		if {![catch {$t tag delete hilite} zit]} {
			$t delete $lastbstart "$lastbstart +$lastbcnt chars"
			$t insert $lastbstart $batch_replace
		}
		FindValInBatch $t
	}
}

proc ReplaceAllValsInBatch {t} {
	global lastbstart lastbcnt batch_replace last_bend batch_toreplace batdiff
	if {[string length $batch_replace] <= 0} {
		Inf "No Replacement Value Given"
		return
	}
	set returnval [FindValInBatch $t]
	set cnt 0
	while {$returnval} {
		if {$cnt == 0} {
			set zzstart [expr int(floor($lastbstart))]
		} elseif {[string match $zzstart [expr int(floor($lastbstart))]]} {
			break
		}
		if {[info exists lastbstart]} {
			if {![catch {$t tag delete hilite} zit]} {
				$t delete $lastbstart "$lastbstart +$lastbcnt chars"
				$t insert $lastbstart $batch_replace
				set k [string first "." $lastbstart]
				incr k
				set j [string range $lastbstart $k end]
				incr j [string length $batch_replace]
				incr k -2
				set lastbstart [string range $lastbstart 0 $k]
				append lastbstart "." $j
				set jj [expr $j - [string length $batch_toreplace]]
				if {[info exists last_bend]} {
					if {$jj > 0} {
						set k [string first "." $last_bend]
						incr k
						set j [string range $last_bend $k end]
						incr j $jj
						incr k -2
						set last_bend [string range $last_bend 0 $k]
						append last_bend "." $j
					}
				}
			}
			set returnval [FindValInBatch $t]
		} else {
			break
		}
		incr cnt
	}
}

proc ReplaceAllParamInBatch {t1} {
	global batch_toreplace batch_replace bag_blines
	if {[string length $batch_replace] <= 0} {
		Inf "No Replacement Value Given"
		return
	}
	if {[string length $batch_toreplace] <= 0} {
		Inf "No Replacement Column Number Given"
		return
	}
	if {![regexp {^[0-9]+$} $batch_toreplace] || ($batch_toreplace < 1)} {
		Inf "'$batch_toreplace' Is Not A Valid Column Number"
		return
	}
	set linecnt 0
	foreach line $bag_blines {
		set thiscols 0
		foreach item $line {
			lappend nuvals $item
			incr thiscols
		}
		if {$linecnt == 0} {
			set colcnt $thiscols
		} elseif {$colcnt != $thiscols} {
			Inf "Inconsistent Number Of Columns: Cannot Do Substitution"
			return
		}
		incr linecnt
	}
	if {$batch_toreplace > $colcnt} {
		Inf "There Are Only '$colcnt' Columns In The Data"
		return
	}
	$t1 delete 1.0 end
	unset bag_blines
	set colc $batch_toreplace
	incr colc -1
	set cnt 0
	set j 0
	foreach val $nuvals {
		if {$j == $colc} {
			set val $batch_replace
		}
		lappend nuline $val
		incr cnt
		set j [expr $cnt % $colcnt]
		if {$j == 0} {
			$t1 insert end "$nuline\n"
			lappend bag_blines $nuline
			unset nuline
		}
	}	
}

#--- Hilite particular types of file found in batchfile, if on workspace

proc BatchHilite {typ} {
	global wl ibfiles obfiles tbfiles bag_blines last_bfnam evv wstk

	if {$typ == "b"} {
		if {![info exists last_bfnam]} {
			Inf "No Previously Chosen Batchfile"
			return
		}
		if {![file exists $last_bfnam]} {
			Inf "Batchfile '$last_bfnam' No Longer Exists"
			return
		}
		set i [LstIndx $last_bfnam $wl]
		if {$i < 0} {
			set msg "File '$last_bfnam' Is No Longer On The Workspace: Do You Want To Load It ?"
			set choice [tk_messageBox -type yesno -message $msg -icon question -parent [lindex $wstk end]]
			if [string match $choice "no"] {
				return
			}
			if {[FileToWkspace $last_bfnam 0 0 0 0 0] <= 0} {
				return
			}
			set i 0
		}
		$wl selection clear 0 end
		$wl selection set $i
		return
	}
	set bfnam [GetDataFromBatchfile]
	if {[string length $bfnam] <= 0} {
		return
	}
	set last_bfnam $bfnam
	SortFilesInsideBatchfile 1
	set ilist {}
	switch -- $typ {
		i { set listing $ibfiles }
		o { set listing $obfiles }
		t { set listing $tbfiles }
	}
	if {[llength $listing] <= 0} {
		Inf "No Files Were Found"
		return
	}
	if {$typ == "o"} {
		foreach item $obfiles {
			set position_data [GetBatchLineData $item]
			if {[llength $position_data] <= 0} {
				Inf "Cannot Retrieve Information About Outfile Type For $item"
				return
			}
			set cmd [concat BatchOutfileType $position_data]
			set ext [eval $cmd]
			lappend nu_obfiles $item$ext
		}
		set listing $nu_obfiles
	}
	foreach fnam $listing {
		set i [LstIndx $fnam $wl]
		if {$i >= 0} {
			lappend ilist $i
		} else {
			lappend bumlist $fnam
		}
	}
	if {[llength $ilist] <= 0} {
		set msg "None Of These Files Is On The Workspace\n"
		set cnt 0
		foreach item $bumlist {
			append msg "\n$item"
			incr cnt
			if {$cnt > 20} {
				append msg "\nAnd More"
				break
			}
		}
		Inf $msg
		return
	} elseif {[info exists bumlist]} {
		set msg "These Files Are Not On The Workspace\n"
		set cnt 0
		foreach item $bumlist {
			append msg "\n$item"
			incr cnt
			if {$cnt > 20} {
				append msg "\nAnd More"
				break
			}
		}
		Inf $msg
	}
	$wl selection clear 0 end
	foreach i $ilist {
		$wl selection set $i
	}
}

#----- Sort files used by batchfile into infiles, outfiles and datafiles

proc SortFilesInsideBatchfile {deltyp} {
	global ibfiles obfiles tbfiles bag_blines evv 
	set ibfiles {}
	set obfiles {}
	set tbfiles {}
	foreach line $bag_blines {
		set got_infiles 0
		set got_outfiles 0
		set itemcnt -1
		set del 0
		set progno 0
		foreach item $line {
			incr itemcnt
			switch -- $itemcnt {
				0 {
					if {[string match #* $item] || [string match @* $item]} {
						break
					}
					if {[string match $item "rm"] || [string match $item "rmsf"]} {
						if {!$deltyp} {
							break
						}
						set del 1
					}
					set progno [GetStandaloneProgramNoIfNonCDPFormat $item]
				}
				1 {
					if {[IsStandalonePrognoWithNonCDPFormat $progno]} {
						if {[InfileExt $item]} {
							set thisext [file extension $item]
							set got_infiles 1
							if {[lsearch $ibfiles $item] < 0} {		;# IF NOT ALREADY IN INFILES LIST
								set oblen [llength $obfiles]
								set obcnt 0
								foreach obf $obfiles {				;# CHECK AGAINST OUTFILES LIST
									set obf $obf$thisext
									if {[string match $obf $item]} {
										break
									}
									incr obcnt	
								}
								if {$obcnt == $oblen} {				;# IF NOT RECYCLED FROM OUTFILES LIST
									lappend ibfiles $item
								}
							}
							set got_infiles 1
						}
					} elseif {$del} {
						set thisext [file extension $item]
						if {[IsATextfileExtension $thisext]} {
							if {[llength $tbfiles] > 0} {
								set k [lsearch $tbfiles $item]
								if {$k >= 0} {
									set tbfiles [lreplace $tbfiles $k $k]
								}
							}
						} elseif {[InfileExt $item]} {
							set item [file rootname $item]
							if {[llength $obfiles] > 0} {
								set k [lsearch $obfiles $item]
								if {$k >= 0} {
									set obfiles [lreplace $obfiles $k $k]
								}
							}
						}
					}
				}
				default {
					if {!$got_outfiles} {
						if {!$got_infiles} {
							if {[InfileExt $item]} {
								set thisext [file extension $item]
								set got_infiles 1
								if {[lsearch $ibfiles $item] < 0} {		;# IF NOT ALREADY IN INFILES LIST
									set oblen [llength $obfiles]
									set obcnt 0
									foreach obf $obfiles {				;# CHECK AGAINST OUTFILES LIST
										set obf $obf$thisext
										if {[string match $obf $item]} {
											break
										}
										incr obcnt	
									}
									if {$obcnt == $oblen} {				;# IF NOT RECYCLED FROM OUTFILES LIST
										lappend ibfiles $item
									}
								}
							}
						} else {
							set thisext [file extension $item]
							if {[string length $thisext] <= 0} {
								if {$itemcnt == 4} {
									set p_rog [string tolower [lindex $line 0]]
									set m_od  [string tolower [lindex $line 1]]
									if {[string match $p_rog "blur"] || [string match $p_rog "distort"]} {
										if {[string match $m_od "shuffle"]} {
											continue
										}
									} elseif {[string match $p_rog "grain"] && [string match $m_od "reorder"]} { 
										continue
									}
								}
								lappend obfiles $item
								set got_outfiles 1
							}
						}
					} else {
						if {[string match -* $item]} {
							if {[string length $item] == 2} {
								continue
							} else {
								set item [string range $item 2 end]
							}
						}
						if {![IsNumeric $item]} {
							set thisext [file extension $item]
							if {[IsATextfileExtension $thisext]} {
								if {[lsearch $tbfiles $item] < 0} {
									lappend tbfiles $item
								}
							}
						}
					}
				}
			}
		}
	}
}

#--------

proc GetDataFromBatchfile {} {
	global wl pa evv bag_blines 

	set i [$wl curselection]
	if {($i < 0) || ([llength $i] > 1)} {
		Inf "Select Just One Batchfile On The Workspace"
		return ""
	}
	set bfnam [$wl get $i]
	if {!($pa($bfnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
		Inf "File '$bfnam' Is Not A Batchfile"
		return ""
	}
	if {![string match ".bat" [file extension $bfnam]]} {
		Inf "File '$bfnam' Is Not A Batchfile"
		return ""
	}
	if [catch {open $bfnam "r"} zit] {
		Inf "Cannot Open File '$bfnam'"
		return ""
	}
	catch {unset bag_blines}
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
		if {[info exists nuline]} {
			lappend bag_blines $nuline
		}
	}
	close $zit
	if {![info exists bag_blines]} {
		Inf "No Data Found In File '$bfnam'"
		return ""
	}
	return $bfnam
}


#----- deduce outfile type, and hence file extension, for batch output files

proc BatchOutfileType {umbrella prog mode pos} {
	global evv

	switch -- $umbrella {
		"analjoin" -
		"blur"	  -
		"combine" -
		"focus"   -
		"hilite"  -
		"morph"   -
		"newmorph" -
		"pitch"   -
		"spec"	  -
		"strange" {
			return $evv(ANALFILE_EXT)
		}
		"brassage" -
		"distort"  -
		"extend"   -
		"editsf"   -
		"flutter"  -
		"mchanrev" -
		"mchstereo" -
		"newmix"   -
		"retime"   -
		"sfedit"   -
		"synth"    -
		"texmchan" - 
		"texture"  -
		"mton"	   -
		"clip"	   -
		"pulser"   -
		"wrappage" {
			return $evv(SNDFILE_EXT)
		}
		"envel" {
			switch -- $prog {
				"create"   -
				"extract"  {
					switch -- $mode {
						1 { return $evv(ENVFILE_EXT) }
						2 { return [GetTextfileExtension brk]}
					}
				}
				"reshape"  -
				"cyclic"   -
				"brktoenv" -
				"dbtoenv"  { return $evv(ENVFILE_EXT) }
				"replot"   -
				"envtobrk" -
				"envtodb"  -
				"dbtogain" -
				"gaintodb" { return [GetTextfileExtension brk]}
				default    { return $evv(SNDFILE_EXT) }
			}
		}
		"filter" {
			switch -- $prog {
				"bankfrqs" { return $evv(TEXT_EXT)  }
				default    {return $evv(SNDFILE_EXT) }
			}
		}
		"formants" {
			switch -- $prog {
				"get"     { return $evv(FORMANTFILE_EXT)  }
				"put"     -
				"vocode"  { return $evv(ANALFILE_EXT)  }
				"see"     -
				"getsee"  { return $evv(SNDFILE_EXT) }
			}
		}
		"grain" {
			switch -- $prog {
				"find"    { return $evv(TEXT_EXT)  }
				default	  { return $evv(SNDFILE_EXT)  }	
			}
		}
		"hfperm" {
			switch -- $prog {
				"hfchords" -
				"hfchords2" {
					switch -- $mode {
						1 -
						2 { return $evv(SNDFILE_EXT) } 
						3-
						4 { return $evv(TEXT_EXT) }
					}
				}
				"delperm"   -
				"delperm2"  { return $evv(SNDFILE_EXT)  }
			}
		}
		"housekeep" {
			switch -- $prog {
				"extract" {
					switch -- $mode {
						2		-
						6		{ return $evv(TEXT_EXT) }
						default { return $evv(SNDFILE_EXT)  }
					}
				}
				"chans"    -
				"copy"     -
	    		"respec"   -
				"deglitch" { return $evv(SNDFILE_EXT)  }
				"bundle"   -
				"sort"     { return $evv(TEXT_EXT) }
			}
		}
		"lucier" {
			switch -- $prog {
				"getfilt"	{ return $evv(TEXT_EXT)  }
				default		{ return $evv(ANALFILE_EXT)  }
			}
		}
		"modify" {
			switch -- $prog {
				"revecho"   -
				"loudness"  -
				"radical"  { return $evv(SNDFILE_EXT)  }
				"speed" {
					switch -- $mode {
						3 -
						4	    { return $evv(TEXT_EXT) }
						default { return $evv(SNDFILE_EXT)  }
					}
				}
				"space" {
					switch -- $mode {
						3		{ return [GetTextfileExtension brk] }
						default { return $evv(SNDFILE_EXT)  }
					}
				}
				"spaceform" { return [GetTextfileExtension brk] }
				"scaledpan" { return $evv(SNDFILE_EXT)  }
				"shudder"   { return $evv(SNDFILE_EXT)  }
			}
		}
		"multimix" { return [GetTextfileExtension mmx] }
		"peak"     { return $evv(TEXT_EXT) }
		"pitchinfo" {
			switch -- $prog {
				"hear"    { return $evv(ANALFILE_EXT) }
				"see"	  { return $evv(SNDFILE_EXT)  }
				default   { return $evv(TEXT_EXT) }
			}
		}
		"pvoc" {
			switch -- $prog {
				"anal"	{ return $evv(ANALFILE_EXT) }
				default { return $evv(SNDFILE_EXT) }
			}
		}
		"repitch" {
			switch -- $prog {
				"getpitch" {
					switch -- $mode {
						1 {
							switch -- $pos {
								4 { return $evv(ANALFILE_EXT) }
								5 { return $evv(PITCHFILE_EXT) }
							}
						}
						2 {
							switch -- $pos {
								4 { return $evv(ANALFILE_EXT) }
								5 { return [GetTextfileExtension brk] }
							}
						}
					}
				}
				"combine" {
					switch -- $mode {
						1     -
						3   { return $evv(TRANSPOSFILE_EXT) }
						2   { return $evv(PITCHFILE_EXT) }
					}
				}
				"combineb"   { return [GetTextfileExtension brk] }
				"transposef" -
				"transpose"  -
				"vowels"	 { return $evv(ANALFILE_EXT) }
				"analenv"    { return $evv(ENVFILE_EXT) }
				"pchtotext"  { return [GetTextfileExtension brk] }
				"synth"      { return $evv(SNDFILE_EXT) }
				default	     { return $evv(PITCHFILE_EXT) }
			}
		}
		"rmresp"	{return $evv(TEXT_EXT)}
		"rmverb"	{return $evv(SNDFILE_EXT)}
		"sndinfo" {
			{ return $evv(TEXT_EXT) }
		}
		"specinfo" {
			switch -- $prog {
				"level"   { return $evv(SNDFILE_EXT) }
				default	  { return $evv(TEXT_EXT) }
			}
		}
		"stretch" {
			switch -- $prog {
				"spectrum" { return $evv(ANALFILE_EXT) }
				"time" {
					switch -- $mode {
						1 { return $evv(ANALFILE_EXT) }
						2 { return $evv(TEXT_EXT) }
					}
				}
			}
		}
		"submix" {
			switch -- $prog {
				"inbetween"   -
				"inbetween2"  -
				"interleave"  -
				"merge"       -
				"mergemany"   -
				"balance"     -
				"faders"     -
	    		"mix"         -
				"crossfade"	  { return $evv(SNDFILE_EXT) }
				default		  { return [GetTextfileExtension mix] }
			}
		}
		"tapdelay"	{return $evv(SNDFILE_EXT)}
	}
}

#--- Locate outfile in batchfile and assess its type

proc GetBatchLineData {str} {
	global bag_blines evv
	foreach line $bag_blines {
		set got_infiles 0
		set got_outfiles 0
		set itemcnt -1
		if {[lsearch $line $str] >= 0} {
			foreach item $line {
				incr itemcnt
				switch -- $itemcnt {
					0 {
						if {[string match #* $item] || [string match @* $item] || [string match $item "rm"] || [string match $item "rmsf"]} {
							break
						}
						set umbrella $item
						set progno [GetStandaloneProgramNoIfNonCDPFormat $umbrella]
					}
					1 {
						if {[IsStandaloneProgWithNonCDPFormat $progno]} {
							set prog 0
							set pos 0
							if {[ProcessHasModes $progno]} {
								set mode $item
								continue
							} else {
								set mode 0
							}
							if {[InfileExt $item]} {
								set got_infiles 1
							}
						} else {
							set prog $item
						}
					}
					default {
						if {$itemcnt == 2} {
							if {![IsStandalonePrognoWithNonCDPFormat $progno]} {
								set mode $item
							}
						}
						if {!$got_outfiles} {
							if {!$got_infiles} {
								if {[InfileExt $item]} {
									set got_infiles 1
								}
							} else {
								set thisext [file extension $item]
								if {[string length $thisext] <= 0} {
									if {$itemcnt == 4} {
										set p_rog [string tolower [lindex $line 0]]
										set m_od  [string tolower [lindex $line 1]]
										if {[string match $p_rog "blur"] || [string match $p_rog "distort"]} {
											if {[string match $m_od "shuffle"]} {
												continue
											}
										} elseif {[string match $p_rog "grain"] && [string match $m_od "reorder"]} { 
											continue
										}
									}
									if {[string match $str $item]} {
										set pos $itemcnt
										set outlist [list $umbrella $prog $mode $pos]
										return $outlist
									}
									set got_outfiles 1
								}
							}
						} elseif {[string match $str $item]} {
							set pos $itemcnt
							set outlist [list $umbrella $prog $mode $pos]
							return $outlist
						}
					}
				}
			}
		}
	}
	return {}
}

#--- Grab files found in batchfile, onto workspace

proc BatchGrab {} {
	global wl obfiles tbfiles bag_blines evv wstk

	set bfnam [GetDataFromBatchfile]
	if {[string length $bfnam] <= 0} {
		return
	}
	SortFilesInsideBatchfile 1
	foreach item $obfiles {
		set position_data [GetBatchLineData $item]
		if {[llength $position_data] <= 0} {
			Inf "Cannot Retrieve Information About Outfile Type For '$item'"
			return
		}
		set cmd [concat BatchOutfileType $position_data]
		set ext [eval $cmd]
		lappend nu_obfiles $item$ext
	}
	set listing [concat $tbfiles $nu_obfiles]
	if {[llength $listing] <= 0} {
		Inf No Files Were Found In Batchfile"
		return
	}
	foreach fnam $listing {
		set i [LstIndx $fnam $wl]
		if {$i < 0} {
			lappend getlist $fnam
		}
	}
	if {![info exists getlist]} {
		Inf "All Of These Files Are On The Workspace"
		return
	}
	foreach item $getlist {
		if {![file exists $item]} {
			lappend bumlist $item
		}
	}
	if {[info exists bumlist]} {
		set msg "These Files No Longer Exist\n"
		set cnt 0
		foreach item $bumlist {
			append msg "\n$item"
			incr cnt
			if {$cnt > 20} {
				append msg "\nAnd More"
				break
			}
		}
		append msg "\n\nDo You Wish To Continue Getting Existing Files To Workspace ??"
		set choice [tk_messageBox -type yesno -message $msg -icon question -parent [lindex $wstk end]]
		if [string match $choice "no"] {
			return
		}
		foreach item $bumlist {
			set k [lsearch $getlist $item]
			if {$k >= 0} {
				set getlist [lreplace $getlist $k $k]
			}
		}
	}
	foreach item $getlist {
		FileToWkspace $item 0 0 0 0 0
	}
}

proc GrabSynLine {y} {
	set i [.batchsyntax.0.l.list nearest $y]
	if {$i < 0} {
		return
	}
	set item [string tolower [.batchsyntax.0.l.list get $i]]
	if {![string match "(" [string index $item 0]]} {
		.batching.3.t insert end "\n$item"
		set item [split $item]
		Inf "Transferred [string toupper [lindex $item 0]] line to batchfile page"
	}
}

#----- Ensure outfiles have file-extension, then check if files exist and will therefore be overwritten

proc ConvertBatchoutfileRepresentation {lines} {
	global true_batch_file wstk evv wl
	catch {unset true_batch_file}
	foreach CDP_cmd $lines {
		set firstword [lindex $CDP_cmd 0]
		if {[string index $firstword 0] == "#" || [string index $firstword 0] == "@" || [string index $firstword 0] == ";" \
		|| 	[string match "rem" $firstword] || [string match "echo" $firstword]} {
			lappend true_batch_file $CDP_cmd
			continue
		} elseif {[string match "copysfx" $firstword]} {
			if {[llength $CDP_cmd] != 3} {
				Inf "Bad Commandline\n$CDP_cmd"
				return 0
			}
			set f_nam [lindex $CDP_cmd 1]
			if {![file exists $f_nam]} {
				Inf "Bad Commandline: file $f_nam does not exist\n$CDP_cmd"
				return 0
			}
			set ext [file extension $f_nam]
			set f_nam [lindex $CDP_cmd 2]
			if {[string length [file extension $f_nam]] <= 0} {
				append f_nam $ext
				set CDP_cmd [lreplace $CDP_cmd 2 2 $f_nam]
			}
			lappend true_batch_file $CDP_cmd
		}
		if {[IsStandaloneProgWithNonCDPFormat [lindex $CDP_cmd 0]]} { 
			set outinfo [GetNonCDPFormatBatchlineOutfileIndex $CDP_cmd]
		} else {
			set outinfo [GetBatchlineOutfileIndex $CDP_cmd]
		}
		if {[llength $outinfo] <= 0} {
			return 0
		}
		set ofidx [lindex $outinfo 0]	;#	Position of outfile in cmdline
		set ofext [lindex $outinfo 1]	;#	File extension of outfile
		if {$ofidx < 0} {
			return 0
		}
		if {$ofidx > 0} {
			if {[llength $CDP_cmd] <= $ofidx} {
				Inf "Bad Commandline: too short\n$CDP_cmd"
				return 0
			}
			if {$ofext != "DEL"} {
				set f_nam [lindex $CDP_cmd $ofidx]
				if {[string length [file extension $f_nam]] <= 0} {
					append f_nam $ofext
					set CDP_cmd [lreplace $CDP_cmd $ofidx $ofidx $f_nam]
				}
				if {[file exists $f_nam]} {
					lappend overwrites $f_nam
				}
			}
		}
		lappend true_batch_file $CDP_cmd
	}
	if {[info exists overwrites]} {
		set msg "The following files will be overwritten by this batch process...\n\n"
		set cnt 0
		foreach f_nam $overwrites {
			incr cnt
			if {$cnt > 20} {
				append msg "AND MORE\n"
				break
			}
			append msg "$f_nam\n"
		}
		append msg "\nDo you want to proceed ??"
		set choice [tk_messageBox -type yesno -message $msg -icon question -parent [lindex $wstk end]]
		if [string match $choice "no"] {
			return 0
		}
		foreach f_nam $overwrites {
			if {![DeleteFileFromSystem $f_nam 1 1]} {
				lappend badfiles $f_nam
			} else {
				set i [LstIndx $f_nam $wl]
				if {$i >= 0} {
					WkspCnt [$wl get $i] -1
					$wl delete $i
				}
				if {[IsInAMixfile $f_nam]} {
					MixM_ManagedDeletion $f_nam
					MixMStore
				}
			}
		}
		if {[info exists badfiles]} {
			set msg "Could Not Delete These Files ....\n\n"
			foreach f_nam $badfiles {
				incr cnt
				if {$cnt > 20} {
					append msg "And More\n"
					break
				}
				append msg "$f_nam\n"
			}
			append msg "\nCannot Proceed\n"
			Inf $msg
			return 0
		}
	}
	return 1
}

proc GetBatchlineOutfileIndex {cmdline} {
	global evv
	switch -- [lindex $cmdline 0] {
		"analjoin" {
			set outpos [SkipAllInfiles $evv(ANALFILE_EXT) 2 $cmdline]
			set outext $evv(ANALFILE_EXT)
		}
		"blur" {
			switch -- [lindex $cmdline 1] {
				"chorus" { set outpos 4 }
				default  { set outpos 3 }
			}
			set outext $evv(ANALFILE_EXT)
		}
		"combine" {
			switch -- [lindex $cmdline 1] {
				"diff" - 
				"make" -
				"sum"  -  
				"cross" {set outpos 4}
				"mean" -
				"make2" {set outpos 5}
				"interleave" -
				"max" {
					set outpos [SkipAllInfiles $evv(ANALFILE_EXT) 2 $cmdline]
				}
			}
			set outext $evv(ANALFILE_EXT)
		}
		"distort" {
			switch -- [lindex $cmdline 1] {
				"cyclecnt" {set outpos 0}
				"interact" {set outpos 5}
				"delete"	- 
				"envel"		-
				"filter"	-
				"distort"	-
				"reform"   {set outpos 4}
				default	   {set outpos 3}
			}
			set outext $evv(SNDFILE_EXT)
		}
		"pulser" {
			switch -- [lindex $cmdline 1] {
				"pulser"	- 
				"multi"	{
					switch -- [lindex $cmdline 2] {
						3 {
							set outpos 5
						}
						default {
							set outpos 4
						}
					}
				}
				default {
					set outpos 4
				}
			}
			set outext $evv(SNDFILE_EXT)
		}
		"clip" {
			set outpos 4
			set outext $evv(SNDFILE_EXT)
		}
		"envel" {
			switch -- [lindex $cmdline 1] {
				"curtail" -
				"dovetail" -
				"tremolo" -
				"warp"	  -
				"scaled"  -
				"attack" {
					set outpos 4
					set outext $evv(SNDFILE_EXT)
				}
				"create" {
					set outpos 4
					set outext [GetTextfileExtension brk]
				}
				"swell"    -
	    		"pluck" {
					set outpos 3
					set outext $evv(SNDFILE_EXT)
				}
				"impose" -
				"replace" {
					set outpos 5
					set outext $evv(SNDFILE_EXT)
				}
				"replot" -
				"extract" {
					set outpos 4
					set outext [GetTextfileExtension brk]
				}
				"envtobrk" -
				"envtodb"  -
				"dbtogain" -
				"gaintodb" {
					set outpos 3
					set outext [GetTextfileExtension brk]
				}
				"reshape" -
				"extract" {
					set outpos 4
					set outext $evv(ENVFILE_EXT)
				}
				"brktoenv" -
				"dbtoenv"  -
				"brktoenv"  -
				"dbtoenv" {
					set outpos 3
					set outext $evv(ENVFILE_EXT)
				}
			}
		}
		"extend" {
			switch -- [lindex $cmdline 1] {
				"sequence2" {
					set outpos [SkipAllInfiles $evv(SNDFILE_EXT) 3 $cmdline]
				}
				default {
					set outpos 4
				}
			}
			set outext $evv(SNDFILE_EXT)
		}
		"filter" {
			set outpos 4
			switch -- [lindex $cmdline 1] {
				"bankfrqs" {
					set outext $evv(TEXT_EXT)
				}
				default {
					set outext $evv(SNDFILE_EXT)
				}
			}
		}
		"flutter" {
			set outpos 3
			set outext $evv(SNDFILE_EXT)
		}
		"focus" {
			switch -- [lindex $cmdline 1] {
				"freeze" {
					set outpos 4
				}
				default {
					set outpos 3
				}
			}
			set outext $evv(ANALFILE_EXT)
		}
		"formants" {
			switch -- [lindex $cmdline 1] {
				"get" {
					set outpos 3
					set outext $evv(FORMANTFILE_EXT)
				}
				"put" {
					set outpos 5
					set outext $evv(ANALFILE_EXT)
				}
				"vocode" {
					set outpos 4
					set outext $evv(ANALFILE_EXT)
				}
				"see" -
				"getsee" {
					set outpos 3
					set outext $evv(SNDFILE_EXT)
				}
			}
		}
		"frame" {
			set outpos 4
			set outext $evv(SNDFILE_EXT)
		}
		"grain" {
			switch -- [lindex $cmdline 1] {
				"grev" {
					set outpos 4
					switch -- [lindex $cmdline 2] {
						6 { 
							set outext $evv(TEXT_EXT)
						}
						default {
							set outext $evv(SNDFILE_EXT)
						}
					}
				}
				"count" -
				"assess" {
					set outpos 0
					set outext $evv(SNDFILE_EXT)	;# dummy
				}
				"align"    -
				"remotif"  -
				"repitch"  -
				"rerhythm" {
					set outpos 4
					set outext $evv(SNDFILE_EXT)
				}
				"find" {
					set outpos 3
					set outext $evv(TEXT_EXT)
				}
				"r_extend" {
					set outpos 4
					set outext $evv(SNDFILE_EXT)
				}
				default {
					set outpos 3
					set outext $evv(SNDFILE_EXT)
				}
			}
		}
		"hfperm" {
			switch -- [lindex $cmdline 1] {
				"hfchords" -
				"hfchords2" {
					set outpos 4
					switch -- [lindex $cmdline 2] {
						1 -
						2 {
							set outext $evv(SNDFILE_EXT)
						}
						3 -
						4 {
							set outext $evv(TEXT_EXT)
						}
					}
				}
				"delperm" -
				"delperm2" {
					set outpos 3
					set outext $evv(SNDFILE_EXT)
				}
			}
		}
		"hilite" {
			switch -- [lindex $cmdline 1] {
				"band" -
				"bltr" -
				"pluck" {
					set outpos 3
				}
				default {
					set outpos 4
				}
			}
			set outext $evv(ANALFILE_EXT)
		}
		"housekeep" {
			switch -- [lindex $cmdline 1] {
				"bundle" {
					set outpos [expr [llength $cmdline] - 1]
					set outext $evv(TEXT_EXT)
				}
				"chans" {
					switch -- [lindex $cmdline 2] {
						1 - 
						2 {
							set outpos 0
							set outext $evv(SNDFILE_EXT)	;# dummy
						}
						default {
							set outpos 4
							set outext $evv(SNDFILE_EXT)
						}
					}
				}
				"copy" {
					switch -- [lindex $cmdline 2] {
						1 {
							set outpos 4
							set outext $evv(SNDFILE_EXT)
						}
						2 {
							set outpos 0
							set outext $evv(SNDFILE_EXT)	;# dummy
						}
					}
				}
				"disk" {
					set outpos 0
					set outext $evv(SNDFILE_EXT)			;# dummy
				}
				"extract" {
					switch -- [lindex $cmdline 2] {
						1 {
							set outpos 0
							set outext $evv(SNDFILE_EXT)	;# dummy
						}
						5 {
							set outpos -1					;#	Mode no longer operationa
							set outext $evv(SNDFILE_EXT)	;# dummy
						}
						6 {
							set outpos 4
							set outext $evv(TEXT_EXT)
						}
						default {
							set outpos 4
							set outext $evv(SNDFILE_EXT)
						}
					}
				}
				"remove" -
				"sort"  {
					set outpos 0
					set outext $evv(TEXT_EXT)		;# dummy
				}
	    		"respec" {
					set outpos 4
					set outext $evv(SNDFILE_EXT)
				}
				"deglitch" {
					set outpos 3
					set outext $evv(SNDFILE_EXT)
				}
			}
		}
		"lucier" {
			switch -- [lindex $cmdline 1] {
				"getfilt" -
				"get" {
					set outpos 3
					set outext $evv(ANALFILE_EXT)
				}
				"impose" -
				"suppress" {
					set outpos 4
					set outext $evv(ANALFILE_EXT)
				}
			}
		}
		"mchiter" -
		"mchzig" -
		"mchshred" -
		"mchanpan" {
			set outpos 4
			set outext $evv(SNDFILE_EXT)
		}
		"mchanrev" -
		"mchstereo" -
		"mton" {
			set outpos 3
			set outext $evv(SNDFILE_EXT)
		}
		"modify" {
			switch -- [lindex $cmdline 1] {
				"brassage" {
					set outpos 4
					set outext $evv(SNDFILE_EXT)
				}
				"sausage" {
					set outpos [SkipAllInfiles $evv(SNDFILE_EXT) 2 $cmdline]
					set outext $evv(SNDFILE_EXT)
				}
				"loudness" {
					switch -- [lindex $cmdline 2] {
						5 { set outpos 5 }
						7 { set outpos 0 }
						8 { set outpos [expr [llength $cmdline] - 1] }
						default {set outpos 4}
					}
					set outext $evv(SNDFILE_EXT)
				}
				"radical" {
					switch -- [lindex $cmdline 2] {
						6 { set outpos 5 }
						default { set outpos 4 }
					}
					set outext $evv(SNDFILE_EXT)
				}
				"revecho" -
				"space"   {
					set outpos 4
					set outext $evv(SNDFILE_EXT)
				}
				"scaledpan" {
					set outpos 3
					set outext $evv(SNDFILE_EXT)
				}
				"spaceform" {
					set outpos 2
					set outext [GetTextfileExtension brk]
				}
				"findpan" {
					set outpos 0
					set outext $evv(TEXT_EXT)
				}
				"speed" {
					set outpos 4
					switch -- [lindex $cmdline 2] {
	    				3 -
	    				4 {
							set outext $evv(TEXT_EXT)
						}
						default {
							set outext $evv(SNDFILE_EXT)
						}
					}
				}
				"shudder" {
					set outpos 3
					set outext $evv(SNDFILE_EXT)
				}
			}
		}
		"morph" {
			switch -- [lindex $cmdline 1] {
				"glide" {
					set outpos 4
				}
				default {
					set outpos 5
				}
			}		
			set outext $evv(ANALFILE_EXT)
		}
		"newmorph" {
			switch -- [lindex $cmdline 1] {
				"newmorph" {
					set outpos 5
				}
				"newmorph2" {
					set outpos 4
				}
			}
			set outext $evv(ANALFILE_EXT)
		}
		"multimix" {
			set outpos [SkipAllInfiles $evv(SNDFILE_EXT) 3 $cmdline]
			set outext [GetTextfileExtension mmx]
		}
		"newmix" {
			set outpos 3
			set outext $evv(SNDFILE_EXT)
		}
		"oneform" {
			switch -- [lindex $cmdline 1] {
				"get" {
					set outpos 3
					set outext $evv(FORMANTFILE_EXT)
				}
				"put" {
					set outpos 5
					set outext $evv(ANALFILE_EXT)
				}
				"combine" {
					set outpos 4
					set outext $evv(ANALFILE_EXT)
				}
			}
		}
		"peak" {
			set outpos 4
			set outext $evv(TEXT_EXT)
		}
		"pitch" {
			switch -- [lindex $cmdline 1] {
				"altharms" -
				"octmove" {
					set outpos 5
				}
				"chordf" -
				"chord" {
					set outpos 3
				}
				"pick"   -
				"transp" -
				"tune" {
					set outpos 4
				}
			}
			set outext $evv(ANALFILE_EXT)
		}
		"pitchinfo" {
			switch -- [lindex $cmdline 1] {
				"convert" {
					set outpos 3
					set outext [GetTextfileExtension brk]
				}
				"hear" {
					set outpos 3
					set outext $evv(SNDFILE_EXT)
				}
				"see" {
					set outpos 4
					set outext $evv(SNDFILE_EXT)
				}
	    		"info"   -
	    		"zeros" {
					set outpos 0
					set outext $evv(TEXT_EXT)	;#dummy
				}
			}
		}
		"psow" {
			switch -- [lindex $cmdline 1] {
				"synth" -
				"interleave" -
				"replace" -
				"features" -
				"cutatgrain" -
				"interp" {
					set outpos 4
					set outext $evv(SNDFILE_EXT)
				}
				"locate" {
					set outpos 0
					set outext $evv(TEXT_EXT)	;#	dummy
				}
				default {
					set outpos 3
					set outext $evv(SNDFILE_EXT)
				}
			}
		}
		"pvoc" {
			switch -- [lindex $cmdline 1] {
				"anal" {
					set outpos 4
					set outext $evv(ANALFILE_EXT)
				}
				default {
					set outpos 3
					set outext $evv(SNDFILE_EXT)
				}
			}
		}
		"repitch" {
			switch -- [lindex $cmdline 1] {
				"getpitch" {
					set outpos 0
					set outext $evv(ANALFILE_EXT)	;#	dummy
				}
				fix"		 -
	    		"pchshift"   -
				"noisetosil" -
				"pitchtosil" {
					set outpos 3
					set outext $evv(PITCHFILE_EXT)
				}
				"combine" {
					set outpos 5
					switch -- [lindex $cmdline 2] {
						2 {
							set outext $evv(PITCHFILE_EXT)
						}
						default {
							set outext $evv(TRANSPOSFILE_EXT)
						}
					}
				}
				"combineb" {
					set outpos 5
					set outext [GetTextfileExtension brk]
				}
				"transpose"  -
				"transposef" {
					switch -- [lindex $cmdline 2] {
						4 { 
							set outpos 5
						}
						default { 
							set outpos 4
						}
					}
					set outext $evv(ANALFILE_EXT)
				}
				"synth"  -
				"vowels" {
					set outpos 3
					set outext $evv(ANALFILE_EXT)
				}
				"analenv" -
				"pchtotext" {
					set outpos 3
					set outext $evv(ENVFILE_EXT)
				}
	    		default {
					set outpos 4
					set outext $evv(PITCHFILE_EXT)
				}
			}
		}
		"retime" {
			switch -- [lindex $cmdline 2] {
				"12" {
					set outpos 4
					set outext $evv(TEXT_EXT)
				}
				default {
					set outpos 4
					set outext $evv(SNDFILE_EXT)
				}
			}
		}
		"editsf" -
		"sfedit" {
			switch -- [lindex $cmdline 1] {
				"insert" {
					set outpos 5
					set outext $evv(SNDFILE_EXT)
				}
				"join" {
					set outpos [SkipAllInfiles $evv(SNDFILE_EXT) 2 $cmdline]
					set outext $evv(SNDFILE_EXT)
				}
				"randchunks" -
				"randcuts"   {
					set outpos 0
					set outext $evv(SNDFILE_EXT)	;#	dummy
				}
	    		"twixt"   -
	    		"sphinx" {
					set outpos [SkipAllInfiles $evv(SNDFILE_EXT) 3 $cmdline]
					set outext $evv(SNDFILE_EXT)
				}
				default {
					set outpos 4
					set outext $evv(SNDFILE_EXT)
				}
			}
		}
		"sndinfo" {
			switch -- [lindex $cmdline 1] {
				"prntsnd" {
					set outpos 3
					set outext $evv(TEXT_EXT)
				}
				default {
					set outpos 0
					set outext $evv(TEXT_EXT)	;#	dummy
				}
			}
		}
		"spec" {
			switch -- [lindex $cmdline 1] {
				"clean" {
					switch -- [lindex $cmdline 2] {
						4 {
							set outpos 7
						}
						default { 
							set outpos 6
						}
					}
				}
				"bare" {
					set outpos 4
				}
				default {
					set outpos 3
				}
			}
			set outext $evv(ANALFILE_EXT)
		}
		"specinfo" {
			switch -- [lindex $cmdline 1] {
				"level" {
					set outpos 3
					set outext $evv(SNDFILE_EXT)
				}
				"channel"   -
				"frequency" -
				"windowcnt" {
					set outpos 0
					set outext $evv(TEXT_EXT)	;#	dummy
				}
				"octvu" -
				"peak"  -
				"print" {
					set outpos 3
					set outext $evv(TEXT_EXT)
				}
				"report" {
					set outpos 4
					set outext $evv(TEXT_EXT)
				}
			}
		}
		"specnu" {
			switch -- [lindex $cmdline 1] {
				"remove" -
				"clean"  -
				"subtract" -
				"slice" {
					set outpos 4
					set outext $evv(ANALFILE_EXT)
				}
				"rand" - 
				"extend" - 
				"squeeze" {
					set outpos 3
					set outext $evv(ANALFILE_EXT)
				}
			}
		}
		"strange" {
			set outpos 4
			set outext $evv(ANALFILE_EXT)
		}
		"stretch" {
			switch -- [lindex $cmdline 1] {
				"spectrum" {
					set outpos 4
				}
				"time" {
					switch -- [lindex $cmdline 2] {
						1 {
							set outpos 4
						}
						2 {
							set outpos 0
						}
					}
				}
			}
			set outext $evv(ANALFILE_EXT)
		}
		"submix" {
			switch -- [lindex $cmdline 1] {
	    		"dummy" {
					set outpos [expr [llength $cmdline] - 1]
					set outext [GetTextfileExtension mix]
				}
	    		"test" {
					set outpos 0
					set outext $evv(SNDFILE_EXT)	;#	dummy
				}
	    		"getlevel" {
					switch -- [lindex $cmdline 2] {
	    				1 {
							set outpos 0
						}
						2 {
							set outpos 4
						}
					}
					set outext $evv(TEXT_EXT)
				}
				"crossfade" -
				"inbetween" {
					set outpos 5
					set outext $evv(SNDFILE_EXT)
				}
				"interleave" {
					set outpos [expr [llength $cmdline] - 1]
					set outext $evv(SNDFILE_EXT)
				}
				"merge"   -
				"balance" {
					set outpos 4
					set outext $evv(SNDFILE_EXT)
				}
	    		"mix" {
					set outpos 3
					set outext $evv(SNDFILE_EXT)
				}
				"syncattack" -
				"attenuate" {
					set outpos 3
					set outext [GetTextfileExtension mix]
				}
				"shuffle"   -
				"spacewarp" -
				"timewarp"  -
				"sync" {
					set outpos 4
					set outext [GetTextfileExtension mix]
				}
			}
		}
		"synth" {
			switch -- [lindex $cmdline 1] {
				"wave" -
				"clicks" -
				"chord" {
					set outpos 3
				}
				default {
					set outpos 2
				}
			}
			set outext $evv(SNDFILE_EXT)
		}
		"texmchan" -
		"texture" {
			set outpos [SkipAllInfiles $evv(SNDFILE_EXT) 3 $cmdline]
			set outext $evv(SNDFILE_EXT)
		}
		"wrappage" {
			set outpos [SkipAllInfiles $evv(SNDFILE_EXT) 2 $cmdline]
			set outext $evv(SNDFILE_EXT)
		}
		"rm" {
			set outpos 1
			set outext "DEL"
		}
		"superaccu" {
			set outpos 4
			set outext "$evv(ANALFILE_EXT)"
		}
		"specsphinx" {
			set outpos 5
			set outext "$evv(ANALFILE_EXT)"
		}
		"partition" -
		"isolate"   -
		"rejoin"	-
		"tremolo"	-
		"packet"	-
		"cantor"	-
		"shrink"  {
			set outpos 4
			set outext "$evv(SNDFILE_EXT)"
		}
		"newsynth" {
			set outpos 3
			set outext "$evv(SNDFILE_EXT)"
		}
		"specgrids" -
		"glisten"   -
		"tunevary" {
			set outpos 3
			set outext "$evv(ANALFILE_EXT)"
		}
		"panorama" {
			set outpos [SkipAllInfiles $evv(SNDFILE_EXT) 3 $cmdline]
			set outext [GetTextfileExtension mix]
		}
		"echo" {
			set outpos 3
			set outext "$evv(SNDFILE_EXT)"
		}
		"tangent"  {
			switch -- [lindex $cmdline 1] {
				"onefile" -
				"list" {
					set outpos 4
					set outext "$evv(SNDFILE_EXT)"
				}
				"twofiles"{
					set outpos 5
					set outext "$evv(SNDFILE_EXT)"
				}
				"sequence" {
					set outpos [SkipAllInfiles $evv(SNDFILE_EXT) 3 $cmdline]
					set outext "$evv(SNDFILE_EXT)"
				}
			}
		}
		"transit"  {
			switch -- [lindex $cmdline 1] {
				"simple" -
				"list" {
					set outpos 4
					set outext "$evv(SNDFILE_EXT)"
				}
				"filtered" {
					set outpos 5
					set outext "$evv(SNDFILE_EXT)"
				}
				"doppler"  -
				"doplfilt" -
				"sequence" {
					set outpos [SkipAllInfiles $evv(SNDFILE_EXT) 3 $cmdline]
					set outext "$evv(SNDFILE_EXT)"
				}
			}
		}
		"spectwin" {
			set outpos 5
			set outext "$evv(ANALFILE_EXT)"
		}
		"scramble" -
		"fracture" -
		"newdelay" {
			set outpos 4
			set outext "$evv(SNDFILE_EXT)"
		}
		"impulse" -
		"synspline" -
		"spectrum" {
			set outpos 2
			set outext "$evv(ANALFILE_EXT)"
		}
		"dvdwind" -
		"verges"  -
		"stutter" -
		"flatten" -
		"bounce"  -
		"tostereo"  -
		"distmark" {
			set outpos 3
			set outext "$evv(SNDFILE_EXT)"
		}
		"suppress" -
		"caltrain" -
		"speculate" {
			set outpos 3
			set outext "$evv(ANALFILE_EXT)"
		}
		"fractal" {
			switch -- [lindex $cmdline 1] {
				"wave" {
					set outpos 4
					set outext "$evv(SNDFILE_EXT)"
				}
				"spectrum" {
					set outpos 3
					set outext "$evv(ANALFILE_EXT)"
				}
			}
		}
		"motor" -
		"tweet" -
		"sorter" -
		"distrep" -
		"repeater" {
			set outpos 4
			set outext "$evv(SNDFILE_EXT)"
		}
		"specenv" {
			set outpos 4
			set outext "$evv(ANALFILE_EXT)"
		}
		"specfnu" {
			set outpos 4
			switch -- [lindex $cmdline 2] {
				7 -
				21 - 
				22 {
					set outext "$evv(TEXT_EXT)"
				}
				23 {
					set outext "$evv(SNDFILE_EXT)"
				}
				default {
					set outpos 4
					set outext "$evv(ANALFILE_EXT)"
				}
			}
		}
		"spectune" {
			switch -- [lindex $cmdline 2] {
				4 {
					set outpos 0
					set outext $evv(TEXT_EXT)	;#	dummy
				}
				default {
					set outpos 4
					set outext "$evv(ANALFILE_EXT)"
				}
			}
		}
		"repair" {
			set outpos [SkipAllInfiles $evv(SNDFILE_EXT) 3 $cmdline]
			set outext "$evv(SNDFILE_EXT)"
		}
		"splinter"  -
		"distshift" -
		"quirk"		-
		"rotor"		-
		"distcut"   -
		"envcut"    -
		"brownian"  -
		"cascade"   -
		"waveform"  -
		"crumble" {
			set outpos 4
			set outext "$evv(SNDFILE_EXT)"
		}
		"phasor" {
			set outpos 3
			set outext "$evv(SNDFILE_EXT)"
		}
		"specfold" {
			set outpos 4
			set outext "$evv(ANALFILE_EXT)"
		}
		"spin" {
			switch -- [lindex $cmdline 1] {
				"stereo"{
					set outpos 4
					set outext "$evv(SNDFILE_EXT)"
				}
				"quad" {
					set outpos 5
					set outext "$evv(SNDFILE_EXT)"
				}
			}
		}
		"tesselate" {
			set outpos [SkipAllInfiles $evv(SNDFILE_EXT) 2 $cmdline]
			set outext "$evv(SNDFILE_EXT)"
		}
		"crystal" {
			set outpos [SkipAllInfiles $evv(SNDFILE_EXT) 2 $cmdline]
			set outext "$evv(SNDFILE_EXT)"
		}
		"cascade" {
			set outpos 4
			set outext "$evv(SNDFILE_EXT)"
		}
	}
	if {![info exists outpos] || ![info exists outext]} {
		Inf "Bad Syntax In Line\n$cmdline"
		return {}
	}
	return [list $outpos $outext]
}

proc SkipAllInfiles {typ n cmdline} {
	global evv
	set outpos $n
	foreach fnam [lrange $cmdline $n end] {
		if {![string match [file extension $fnam] $typ]} {
			if {[string match "-*" $fnam] || [IsNumeric $fnam] || [IsATextfileExtension [file extension $fnam]]} {
				incr outpos -1
			}
			break
		}
		incr outpos
	}
	return $outpos
}

proc BatchTips {x} {
	switch -- $x {
		0 {
			set msg "CREATING A BATCHFILE WITH THE CORRECT SYNTAX\n\n"
			append msg "1) Run the sequence of programs you want to use.\n"
			append msg "2) After the 1st process has finished & BEFORE leaving the parameters page,\n"
			append msg "3) Put a batchfile name in the box at top right.\n"
			append msg "4) Press the 'Save as Batch' button, with Outname, at the Bottom right.\n"
			append msg "    (This saves your process as a cmdline in the named batchfile).\n"
			append msg "5) After each subsequent process has finished, in a similar way,\n"
			append msg "6) Press the 'Append to Batch' button, with Outname, at the Bottom right,\n"
			append msg "     Ensuring the the batchfile name (top right) has not changed.\n"
			append msg "In this way your processes will be preserved in a named batchfile.\n" 
		}
		1 {
			set msg "RUNNING THE SAME PROCESS WITH DIFFERENT PARAMETERS.\n\n"
			append msg "1) Run one process, and create a batchfile from it, before quitting the params page.\n"
			append msg "2) Create a textfile with a list of the different param values you want to use.\n"
			append msg "3) With the original file in the Chosen Files list, go to the Table Editor.\n"
			append msg "4) Select 'multiple files' mode.\n"
			append msg "5) On Right hand panel, select the batchfile, then the parameter-list file.\n"
			append msg "6) Go to 'Vectored Batchfile', on the JOIN menu, and follow the instructions.\n"
		}
		2 {
			set msg "RUNNING THE SAME PROCESS WITH DIFFERENT PARAMETERS ON DIFFERENT FILES.\n\n"
			append msg "1) Run one process, and create a batchfile from it, before quitting the params page.\n"
			append msg "2) Create a textfile with a list of the different param values you want to use,\n"
			append msg "       (There must be one parametere for each file that is to be processed).\n"
			append msg "3) List all the files you want to process in the Chosen files list.\n"
			append msg "4) Go to the Table Editor.\n"
			append msg "5) Select 'multiple files' mode.\n"
			append msg "6) On Right hand panel, select the batchfile, then the parameter-list file.\n"
			append msg "7) Go to 'Vectored Batchfile', on the JOIN menu, and follow the instructions.\n"
		}
		3 {
			set msg "RUNNING THE SAME SET OF PROCESSES ON DIFFERENTLY NAMED FILES\n\n"
			append msg "1) Run one set of processes, creating a batchfile as you go, on the params page.\n"
			append msg "2) Edit the batchfile to ensure that all intermediate files are DELETED.\n"
			append msg "3) Create a textfile, listing the files you want to process paired with an outfile name.\n"
			append msg "     Put the ORIGINAL file processed (and the outfilename) at the top of the list.\n"
			append msg "3) Go to the Table Editor. Put it in 'Multiple Files' mode.\n"
			append msg "4) Select the batchfile and the listing file.\n"
			append msg "5) On JOIN menu, Select EXTEND BATCH PROCESS TO NEW FILE.\n"
			append msg "6) This will duplicate all lines of the original batchfile N times, with input and output files\n"
			append msg "       changed to those in your list.\n\n"
			append msg "RUNNING THE SAME SET OF PROCESSES ON CONSECUTIVELY NUMBERED FILES (e.g. myfile0, myfile1, ...).\n\n"
			append msg "1) Run one set of processes, creating a batchfile as you go, on the params page.\n"
			append msg "2) Edit the batchfile to ensure that all files used in the process are numbered\n"
			append msg "     e.g. process on myfile0 might produce myanalysis0 then mypitch0 etc. etc.\n"
			append msg "     OR ensure intermediate files are DELETED at end of batchfile (e.g. 'del myanalysis')\n"
			append msg "3) Go to the Table Editor.\n"
			append msg "4) Select the batchfile.\n"
			append msg "5) On tables menu, Select DUPLICATE: DUPLICATE ALL ROWS NUMERICALLY INDEXING THE COPIED CONTENTS.\n"
			append msg "6) This will duplicate all lines of the original batchfile N times, with filenames\n"
			append msg "       numerically indexed e.g. myfile0, myfile1,... myoutfile0,myoutfile1, ...etc\n\n"
			append msg "Note that commandline CDP progs always produce output with '.wav' or '.aiff' extensions\n"
			append msg "when no outfile extension is specified, even if the output is an analysis (etc) file.\n"
			append msg "Bear this in mind when constructing batchfile names.\n"
			append msg "\n"
		}
	}
	Inf $msg
}

proc StripLocalCurlies {str} {
	set nustr ""
	set len [string length $str]
	set n 0
	while {$n < $len} {
		set char [string index $str $n]
		if {[string match "{" $char] || [string match "}" $char]} {
			incr n
			continue
		}
		append nustr $char
		incr n
	}
	return $nustr
}

proc SetupFormantFlagLettersEtc {cmd} {
	global pprg evv
	switch -regexp -- $pprg \
		^$evv(SPREAD)$	 - \
		^$evv(CHORD)$	 - \
		^$evv(FOCUS)$	 - \
		^$evv(FORMANTS)$ - \
		^$evv(FORMSEE)$ {
			set typ [lindex $cmd 4]
			set val [lindex $cmd 5]
			set qik [lindex $cmd 6]
			if {$typ == 1} {
				set nuval "-p"
			} else {
				set nuval "-f"
			}
			append nuval $val
			set cmd [lreplace $cmd 4 5 $nuval]
			if {$qik} {
				set cmd [lreplace $cmd 5 5 "-i"]
			} else {
				set cmd [lreplace $cmd 5 5]
			}
		} \
		^$evv(GLIS)$  - \
		^$evv(TRNSF)$ - \
		^$evv(VOCODE)$ {
			set typ [lindex $cmd 5]
			set val [lindex $cmd 6]
			set qik [lindex $cmd 7]
			if {$typ == 1} {
				set nuval "-p"
			} else {
				set nuval "-f"
			}
			append nuval $val
			set cmd [lreplace $cmd 5 6 $nuval]
			if {$qik} {
				set cmd [lreplace $cmd 6 6 "-i"]
			} else {
				set cmd [lreplace $cmd 6 6]
			}
		} \
		^$evv(FLTBANKC)$ {	;#	DELETE randomise PARAM WHIXH IS NON-FUNCTIONAL (Apr 2007) AND WILL BE DELETED IN NEXT CDP RELEASE
			set cmd [lrange $cmd 0 6]
		} \

	return $cmd
}

#------ Convert backslash to forward slash in directory paths with NO conversion to lower case

proc RegulariseDirectoryRepresentation_No_tolower {str} {
	if {[regexp {[\\]} $str]} {
		set strlist [split $str \\]		   			;#	Convert to TK directory representation
		if {[llength $strlist] > 1} {
			set newstr ""
			foreach item $strlist {
				append newstr $item "/"
			}
			set len [string length $newstr]
			incr len -2
			set str [string range $newstr 0 $len]
		}
	}
	return $str
}

