#
# SOUND LOOM RELEASE mac version 17.0.4
#
# RWD June 30 2013
# ... fixup button rectangles

############
# NOTEBOOK #
############

#------ See or edit Notebook

proc NnnSee {args} {
	global unotes pr_maketext new_nnn sl_real search_string tstandard tlist ww wl ch chlist dl evv wksp_dirname
	global textfilename look_on_workspace nnn_cleared logname

	set search_set 0
	set look_on_workspace 0
	if {!$sl_real} {
		Inf "You Can Keep Notes On Your Work In The Notebook\nThe Notebook Can Be Accessed From Many Different Places On The Soundloom"
		return
	}		
	if {[llength $args] == 1} {
		if {[string match $args ~~~$wl] || [string match $args ~~~$ch] || [string match $args ~~~$dl] || [string match $args ~~~$ww.1.b.de]} {

			if {[string match $args ~~~$ww.1.b.de]} {
				if {![info exists wksp_dirname] || ([string length $wksp_dirname] <= 0)} {
					Inf "No Directory For Sources or Back-Ups Selected"
					return
				}
				set args $wksp_dirname
			} else {
				if {[string match $args ~~~$wl] || [string match $args ~~~$dl]} {
					set args [string range $args 3 end]
					set ilist [$args curselection]
					if {[llength $ilist] > 1} {
						Inf "Select A Single File To Search For"
						return
					}
					set i [lindex $ilist 0]
					if {$i < 0} {
						Inf "No Selection Made"
						return
					}
					set fnam [file tail [$args get $i]]
				} else {
					if {![info exists chlist] || ([llength $chlist] <= 0)} {
						Inf "No Selection Made"
						return
					}
					set fnam [file tail [lindex $chlist 0]]
				}
				set search_string $fnam
				set search_set 1
				set look_on_workspace 1
				set args {}
			}
		} elseif {[string match $args ~~~$wl~~~]} {
			set look_on_workspace 1
			set args {}
		}
	}
	set f .npad
	if [Dlg_Create $f "Notebook" "set pr_maketext 0" -borderwidth $evv(BBDR)] {
		EstablishTextWindow $f 0
		$f.k.t yview moveto 1.0
	}
	$f.b.k config -text "" -width 0 -bd 0 -command {} -bg [option get . background {}]
	$f.b.find config -text "Select File/Line" -bd 2 -state normal -width 18
	$f.b.undo config -text "" -bd 0 -command {}
#	InstallMeterKeystrokes $f
	set tstandard .npad.z.z.t
	set tlist .npad.k.t
	if {!$search_set} {
		set search_string ""
	}
	$f.b.ref config -command "RefSee $f.k.t"

	if {[info exists nnn_cleared]} {
		$f.k.t delete 1.0 end
		unset nnn_cleared
#LISTDATE EMERGENCY MAY 2007
		LognameDerive
#TO HERE
		set zarb " ----------- "
		set zorb $zarb
		append zorb $logname
		append zorb $zarb 
		lappend unotes $zorb
		lappend unotes ""
		foreach line $unotes {
			$f.k.t insert end "$line\n"
		}
	}
	if {$new_nnn} {
		if [info exists unotes] {		;# Load current state of notes
			foreach line $unotes {
				$f.k.t insert end "$line\n"
			}
		}
		set new_nnn 0
	}
	$f.b.l config -text ""
	set textfilename ""
	ForceVal $f.b.e $textfilename
	$f.b.e config -borderwidth 0 -state readonly -readonlybackground [option get . background {}]
	$f.b.m config -borderwidth 0 -state disabled -text ""
	if [catch {open [file join $evv(URES_DIR) $evv(DFLT_NTBK)] "w"} nId] {
		Inf "Cannot open temporary file to save current notebook state.\n"
		return
	}
	puts $nId "[$f.k.t get 1.0 end]"
	close $nId
	.npad.b.keep config -text "Save Update"
	.npad.b.cancel config -text "Close (No Update)"
	wm title $f "Notebook"			;#	Force title (in case window used for brkpoint edit)
	set pr_maketext 0
	raise $f
	update idletasks
	StandardPosition $f
	if {!$search_set} {
		$f.k.t yview moveto 1.0
		$f.z.0.src config -bg [option get . background {}]
		$f.z.0.ss config -bg [option get . background {}]
	} else {
		$f.z.0.src config -bg $evv(EMPH)
		$f.z.0.ss config -bg $evv(EMPH)
	}
	if {[llength $args] > 0} {
		foreach item $args {
			foreach fnam $item {
				$f.k.t insert end "$fnam\n"
			}
		}
	}
	My_Grab 0 $f pr_maketext $f.k.t
	tkwait variable pr_maketext
	if {!$pr_maketext} {
		if [catch {open [file join $evv(URES_DIR) $evv(DFLT_NTBK)] "r"} nId] {
			Inf "Cannot open temporary file to restore previous notebook state.\n"
			return
		} else {
			$f.k.t delete 1.0 end			;# if notes not to be changed - restore inital state of notes
			set qq 0
			while {[gets $nId line] >= 0} {
				if {$qq > 0} {
					$f.k.t insert end "\n"
				}
				$f.k.t insert end "$line"
				incr qq
			}
			close $nId
		}
	} else {
		NnnSave
	}
#	.npad.b.e config -text "" -state normal
	UninstallMeterKeystrokes $f
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#------ Load notebook if it exists

proc NnnLoad {} {
	global wstk unotes logname evv

	set gotfile 0
	set nnn [file join $evv(URES_DIR) $evv(NOTEBOOK)$evv(CDP_EXT)]
	if [file exists $nnn] {
		if [catch {open $nnn "r"} npfileId] {
			Inf "Cannot open existing notebook file."
			set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] \
				-message "Cannot open existing notebook file. Abandon it?"]
			if {$choice == "no"} {
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] \
					-message "Quit the workspace, to examine the notebook (otherwise it will be overwritten) ?"]
				if {$choice == "yes"} {
					return 0
				}
			}
		} else {
			set gotfile 1
		}
	}
	if {$gotfile} {
		while {[gets $npfileId line] >= 0} {
			lappend unotes $line
		}
		close $npfileId
	}
	if [info exists logname] {
		set zarb " --------- "
		set zorb $zarb
		append zorb $logname
		append zorb $zarb 
		lappend unotes $zorb
		lappend unotes ""
	}		
	return 1
}

#------ Save notebook to file

proc NnnSave {} {
	global evv unotes
	if {![winfo exists .npad]} {
		return
	}
	set gotfile 0
	set nnn [file join $evv(URES_DIR) $evv(NOTEBOOK)$evv(CDP_EXT)]
	set temp_nbk [file join $evv(URES_DIR) $evv(DFLT_NTBK)]
	catch {file delete $temp_nbk}
	if [catch {open $temp_nbk "w"} npfileId] {
		Inf "Cannot open temporary file to write notebook. Some notes lost."
		return
	}
	puts $npfileId "[.npad.k.t get 1.0 end]"
	close $npfileId
	set bum 0
	if [file exists $nnn] {
	 	if {[catch {file delete $nnn} in] || [catch {file rename $temp_nbk $nnn} in]} {
			set bum 1
		}
	} elseif [catch {file rename $temp_nbk $nnn} in] {
		set bum 1
			
	}
	if {$bum} {
		Inf "Cannot save todays notes to the standard notebook file."
		Inf "To recover them, retrieve them from file '$temp_nbk'\nUsing Some Other Program, Before Proceeding."
	}
	if {![catch {open $nnn "r"} zit]} {
		catch {unset unotes}
		while {[gets $zit line] >= 0} {
			lappend unotes $line
		}
		close $zit
	}
	return
}

#--- Grab files and list them in the Notebook

proc FilesToNotebook {listing} {
	global wl dl chlist chcnt scoremixlist sl_real hidden_dir

	if {!$sl_real} {
		Inf "You Can Highlight Files In The Various Workspace Windows\nOr Select Them On The Sketch Score\nAnd List Their Names In The Notebook."
		return
	}

	switch -- $listing {
		"wl" {
			set ilist [$wl curselection]
			if {![info exists ilist] || ([llength $ilist] <= 0)} {
				Inf "No Files Have Been Selected"
				return
			}
			foreach i $ilist {
				lappend insert [$wl get $i]
			}
		}
		"ch" {
			if {[info exists chlist] && ($chcnt > 0)} {
				foreach fnam $chlist {
					lappend insert $fnam
				}
			}
		}
		"dl" {
			set ilist [$dl curselection]
			if {![info exists ilist] || ([llength $ilist] <= 0)} {
				Inf "No Files Have Been Selected"
				return
			}
			foreach i $ilist {
				set fnam [$dl get $i]
				if {[string length $hidden_dir] > 0} {
					set fnam [file join $hidden_dir $fnam]
				}
				lappend insert $fnam
			}
		}
		"sc" {
			if {![info exists scoremixlist]} {
				Inf "No Files Have Been Selected"
				return
			}
			set insert $scoremixlist
		}
	}
	if {[info exists insert]} {
		NnnSee $insert
	}
}

#--- Grab files and list them in the Notebook

proc FileContentToNotebook {where} {
	global wl ww dl pa chcnt chlist sl_real hidden_dir evv

	if {!$sl_real} {
		Inf "You Can Highlight A Text File On Any Of The Workspace Windows\nAnd Print Its Contents In The Notebook."
		return
	}
	switch -- $where {
		"wl" {
			set ilist [$wl curselection]
			if {![info exists ilist] || ([llength $ilist] <= 0)} {
				Inf "No Files Have Been Selected"
				return
			}
			if {[llength $ilist] > 1} {
				Inf "Choose Just One File"
				return
			}
			set fnam [$wl get [lindex $ilist 0]]
		}
		"ch" {
			if {![info exists chcnt] || ($chcnt < 1)} {
				Inf "No Files Have Been Selected"
				return
			} elseif {$chcnt > 1} {
				Inf "There Is More Than One File In The Chosen List"
				return
			}
			set fnam [lindex $chlist 0]
		}
		"dl" {
			if {[string length [$ww.1.b.msgx cget -text]] > 0} {
				Inf "You Must List A Directory on the Workspace\n\nBefore This Option Becomes Active"
				return
			}
			if {![info exists dl]} {
				Inf "No Files Have Been Selected"
				return
			}
			set ilist [$dl curselection]
			if {![info exists ilist] || ([llength $ilist] <= 0)} {
				Inf "No Files Have Been Selected"
				return
			}
			set fnam [$dl get [lindex $ilist 0]]
			if {[string length $hidden_dir] > 0} {
				set fnam [file join $hidden_dir $fnam]
			}
			if {![info exists pa($fnam,$evv(FTYP))]} {
				set test [DoMinParse $fnam]
				if {$test <= 0} {
					return
				}
			}
		}
	}
	if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
		Inf "File '$fnam' Is Not A Textfile"
		if {[info exists test]} {
			catch {unset pa($fnam,$evv(FTYP))}
		}
		return
	}
	if {[info exists test]} {
		catch {unset pa($fnam,$evv(FTYP))}
	}
	if [catch {open $fnam} zit] {
		Inf "Cannot Open File '$fnam'"
		return
	}
	while {[gets $zit line] >= 0} {
		lappend insert $line
	}
	catch {close $zit}
	if {[info exists insert]} {
		NnnSee $insert
	}
}

#--- Add B-list name to Notebook

proc BlistToNotebook {} {
	global bln_var sl_real

	if {!$sl_real} {
		Inf "The Name Of A Background Listing (see elsewhere)\nCan Be Grabbed To The Notebook."
		return
	}
	GetBLName 8
	if {[string length $bln_var] > 0} {
		NnnSee $bln_var
	}
}

#---- Find file highlighted on notebook.

proc FindNotebookFile {} {
	global evv dl hidden_dir wksp_dirname wstk filstr wl active_dir ww

	if {![catch {selection get -displayof .npad.k.t} sel]} {
		set sel [string trim $sel]
		if {[string length $sel] <= 0} {
			Inf "No Selection Made"
			return 0
		}
		set llist [split $sel]
		if {[llength $llist] > 1} {
			Inf "Selection Contains More Than One Word"
			return 0
		}
		set rt [file rootname [file tail $sel]]
		if {![ValidCDPRootname $rt]} {
			return 0
		}
		set ext [file extension $sel]
		if {[string length $ext] == 0} {
			set msg "Selected Item Has No File Extension: Assume It's A Soundfile ?"
			set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				return 0
			}
			append sel $evv(SNDFILE_EXT)
		}
		if {[file exists $sel]} {
			set k [LstIndx $sel $wl]
			if {$k >= 0} {
				$wl selection clear 0 end
				$wl selection set $k
				set drf [expr double($k)/double([$wl index end])]
				$wl yview moveto $drf
				return 1
			}
			set dir [file dirname $sel]
			if {[string length $dir] <= 1} {
				set dir ""
			}
			if {![info exists active_dir]} {
				Inf "Cannot Search Directories Until Some Directory Is Listed On Workspace Page."
				return 0
			}
			set doit 1
			set fnam [$dl get 0]
			if {[string length $fnam] > 0} {
				if {[string length $hidden_dir] > 0} {
					set fnam [file join $hidden_dir $fnam]
				}
				set resdir [file dirname $fnam]
				if {[string length $resdir] <= 1} {
					set resdir ""
				}
				if {[string match $dir $resdir]} {
					set doit 0
				}
			}
			if {$doit} {
				if {[string length $dir] <= 1} {
					set wksp_dirname ""
				} else {
					set wksp_dirname $dir
					UpdateRecentDirs $wksp_dirname
				}
				ForceVal $ww.1.b.de $wksp_dirname
				set active_dir $wksp_dirname
				$dl delete 0 end
				Block "Listing Directory"
				foreach fnam [lsort -dictionary [glob -nocomplain [file join $wksp_dirname *]]] {
					if [IsListableFile $fnam] {
						set fnam [string tolower $fnam]
						$dl insert end $fnam		;#	and place them in the listing window
					}
					$dl xview moveto 1.0
				}
				UnBlock
				set hidden_dir ""
			}
			if {[string length $hidden_dir] > 0} {
				set k [LstIndx [file tail $sel] $dl]
			} else {
				set k [LstIndx $sel $dl]
			}
			if {$k >= 0} {
				$dl selection clear 0 end
				$dl selection set $k
				set drf [expr double($k)/double([$dl index end])]
				$dl yview moveto $drf
				return 1
			} else {
				Inf "Found Directory, But Not Found File"
				return 0
			}
		} else {
			set dir [file dirname $sel]
			if {[string length $dir] > 1} {
				set msg "File Either Does Not Exist, Or Is Not In This Directory.\n\nLook In Other Directories ??"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					return 0
				}
			}
			set filstr [file rootname [file tail $sel]]
			FileFind 0 0 1
			return 0
		}
	} else {
		Inf "No Selection Made"
		return 0
	}
}

proc FindFileFromNotebook {} {
	global pr_maketext wl look_on_workspace evv wstk wksp_dirname active_dir dl ww
	if {$look_on_workspace} {
		if {[catch {selection get -displayof .npad.k.t} sel]} {
			Inf "No Selection Made"
			return
		}
		set sel [string trim $sel]
		if {[string length $sel] <= 0} {
			Inf "No Selection Made"
			return
		}
		set llist [split $sel]
		if {[llength $llist] > 1} {
			Inf "Selection Contains More Than One Word"
			return
		}
		if {[file isdirectory $sel]} {
			set msg "$sel Is A Directory\nDo You Want To Load It To The Workspace ?"
			set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
			if {$choice == "yes"} {
				set wksp_dirname $sel
				UpdateRecentDirs $wksp_dirname
				ForceVal $ww.1.b.de $wksp_dirname
				set active_dir $wksp_dirname
				$dl delete 0 end
				Block "Listing Directory"
				foreach fnam [lsort -dictionary [glob -nocomplain [file join $wksp_dirname *]]] {
					if [IsListableFile $fnam] {
						set fnam [string tolower $fnam]
						$dl insert end $fnam		;#	and place them in the listing window
					}
					$dl xview moveto 1.0
				}
				UnBlock
				set pr_maketext 1
			}
			return
		}
		set rt [file rootname [file tail $sel]]
		if {![ValidCDPRootname $rt]} {
			return
		}
		set ext [file extension $sel]
		if {[string length $ext] == 0} {
			set msg "Selected Item Has No File Extension: Assume It's A Soundfile ?"
			set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				return
			}
			append sel $evv(SNDFILE_EXT)
		}
		set foundit 0
		set i 0
		foreach fnam [$wl get 0 end] {
			if {[string match $sel $fnam]} {
				set foundit 1
				break
			}
			incr i
		}
		if {$foundit} {
			$wl selection clear 0 end
			$wl selection set $i
			$wl yview moveto [expr double($i) / double([$wl index end])]
			set pr_maketext 1
			return
		}
	}
	if [FindNotebookFile] {
		set pr_maketext 1
	}
}

#---- Get params from parampage to notebook

proc NnnGetParams {with_infiles with_outfiles} {
	global prm gdg_cnt pg_spec ins chlist wl
	set gcnt 0
	set pcnt 0
	set line ""
	if {$with_outfiles} {
		set line "MAKING  "
		append line [$wl get 0] "\n"
		lappend insert $line
	}
	if {$with_infiles} {
		if {$ins(create) && [info exists ins(chlist)]} {
			 set zz $ins(chlist)
		} elseif [info exists chlist] {
			 set zz $chlist
		}
		if {[info exists zz]} {
			set line "WITH INFILES\n"
			foreach item $zz {
				append line $item \n
			}
		}
		lappend insert $line
	}
	while {$gcnt < $gdg_cnt} {
		if [IsDeadParam $gcnt] {
			incr gcnt
			incr pcnt
			continue
		}
		set param_props [lindex $pg_spec $gcnt]
		set name [lindex $param_props 1]
		set line $name
		set typ [lindex $param_props 0]
		if {$typ == "SWITCHED"} {
			if {$prm($pcnt)} {
				append line " pitchwise"
			} else {
				append line " frqwise"
			}
			incr pcnt
			append line " " $prm($pcnt)
		} elseif {$typ == "CHECKBUTTON"} {
			if {$prm($pcnt)} {
				append line " yes"
			} else {
				append line " no"
			}
		} elseif {$typ == "TIMETYPE"} {
			switch --  $prm($pcnt) {
				0 { append line " seconds" }
				1 { append line " sample count" }
				2 { append line " grouped sample count" }
			}
		} else {
			append line " " $prm($pcnt)
		}
		lappend insert $line
		incr gcnt
		incr pcnt
	}
	if {[info exists insert]} {
		set line [split [wm title .ppg]]
		set line [lrange $line 2 end]
		set line [join $line]
		set insert [linsert $insert 0 $line ""]
		NnnSee $insert
	} else {
		Inf "No Parameters To Put In Notebook"
	}
}

#-- Play file chosen in notebook

proc PlayFileFromNotebook {} {
	global wl look_on_workspace evv wstk wksp_dirname active_dir dl ww
	if {[catch {selection get -displayof .npad.k.t} sel]} {
		Inf "No Selection Made"
		return
	}
	set sel [string trim $sel]
	if {[string length $sel] <= 0} {
		Inf "No Selection Made"
		return
	}
	set llist [split $sel]
	if {[llength $llist] > 1} {
		Inf "Selection Contains More Than One Word"
		return
	}
	if {[file isdirectory $sel]} {
		Inf "'$sel' Is A Directory"
		return
	}
	set rt [file rootname [file tail $sel]]
	if {![ValidCDPRootname $rt]} {
		return
	}
	if {[string length [file extension $sel]] == 0} {
		append sel $evv(SNDFILE_EXT)
	}
	if {![file exists $sel]} {
		Inf "Soundfile '$sel' Does Not Exist"
		return
	}
	set ftyp [FindFileType $sel]
	if {$ftyp != $evv(SNDFILE)} {
		Inf "'$sel' Is Not A Soundfile"
		return
	}
	PlaySndfile $sel 0
}

proc ClearNotebook {} {
	global pr_clear_nnn nnndir nnnfil nnndir nnn_cleared unotes wstk evv
	set nnn [file join $evv(URES_DIR) $evv(NOTEBOOK)$evv(CDP_EXT)]
	set temp_nbk [file join $evv(URES_DIR) $evv(DFLT_NTBK)]
	if [winfo exists .npad] {
		catch {file delete $temp_nbk}
		if [catch {open $temp_nbk "w"} npfileId] {
			Inf "Cannot open temporary file to write notebook. Some notes lost."
			return
		}
		puts $npfileId "[.npad.k.t get 1.0 end]"
		close $npfileId
		set bum 0
		if [file exists $nnn] {
	 		if {[catch {file delete $nnn} in] || [catch {file rename $temp_nbk $nnn} in]} {
				set bum 1
			}
		} elseif [catch {file rename $temp_nbk $nnn} in] {
			set bum 1
		}
		if {$bum} {
			Inf "Cannot save todays notes to the standard notebook file."
			Inf "To Recover Them, Retrieve Them From File '$temp_nbk'\nUsing Some Other Program, Before Proceeding."
			return
		}
	}
	set callcentre [GetCentre [lindex $wstk end]]
	set f .nnn_clear
	if [Dlg_Create $f "Clear Notebook" "set pr_clear_nnn 0" -borderwidth $evv(BBDR)] {
		frame $f.1
		frame $f.2
		frame $f.3
		button $f.1.bakup -text "Clear & Backup Notebook" -command {set pr_clear_nnn 1} -width 23 -highlightbackground [option get . background {}]
		button $f.1.clear -text "Clear Notebook" -command {set pr_clear_nnn 2} -width 23 -highlightbackground [option get . background {}]
		button $f.1.quit -text "Close" -command {set pr_clear_nnn 0} -highlightbackground [option get . background {}]
		pack $f.1.bakup $f.1.clear -side left -padx 2
		pack $f.1.quit -side right 
		label $f.2.dir -text "Backup Directory"	
		entry $f.2.e -textvariable nnndir -width 60
		pack $f.2.dir $f.2.e -side left -padx 4
		label $f.3.fnm -text "Backup Filename"	
		entry $f.3.e -textvariable nnnfil -width 48
		pack $f.3.fnm $f.3.e -side left -padx 4
		pack $f.1 -side top -fill x -expand true
		pack $f.2 $f.3 -side top -pady 4
		wm resizable $f 1 1
		bind $f <Escape> {set pr_clear_nnn 0}
	}
	set do_delete 0
	set finished 0
	set pr_clear_nnn 0
	raise .nnn_clear
	update idletasks
	set geo [CentreOnCallingWindow $f $callcentre]
	My_Grab 0 .nnn_clear pr_clear_nnn $f.2.e
	while {!$finished} {
		tkwait variable pr_clear_nnn
		switch -- $pr_clear_nnn {
			0 {
				set finished 1
			}
			1 {
				set thisdir [CheckDirectoryName [string tolower $nnndir] "directory for notebook" 1 1]
				if {[string length $thisdir] <= 0}  {
					continue
				}
				if {![file exists $thisdir] || ![file isdirectory $thisdir]} {
					set msg "Directory '$thisdir' Does Not Exist:  Create New Directory?"
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
				}
				set nnnfilx [string tolower $nnnfil]
				if {![ValidCDPRootname $nnnfilx]} {
					continue
				}
				set outfil [file join $thisdir $nnnfilx$evv(TEXT_EXT)]
				if {[file exists $outfil]} {
					if {[file isdirectory $outfil]} {
						"'$outfil' Is An Existing Directory"
						continue
					}
					set msg "File '$outfil' Already Exists:  Overwrite It?"
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
					if [catch {file delete $outfil} zit] {
						Inf "Cannot Delete Existing File '$outfil'"
						continue
					}
				}
				if [catch {file copy $nnn $outfil} zit] {
					Inf "Failed To Copy Existing Notebook Data To '$outfil'\n"
					continue
				}
				set do_delete 1
			}
			2 {
				set msg "Are You Sure You Do Not Want To Back Up The Notebook Before Clearing It?"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				set do_delete 1
			}
		}
		if {$do_delete} {
			if [catch {file delete $nnn} zit] {
				Inf "Failed To Delete Notebook File '$nnn'\n\nDelete This, Outside The CDP, Before Proceeding"
			}
			if {[file exists $temp_nbk]} {
				if [catch {file delete $temp_nbk} zit] {
					Inf "Failed To Delete Notebook Backup File '$temp_nbk'\n\nDelete This, Outside The CDP, Before Proceeding"
				}
			}
			catch {unset unotes}
			set nnn_cleared 1
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	destroy $f
}

proc BatchfileFromNotebook {} {
	global pr_nbkbat nbkbatfil wstk not_bat evv

	if {[catch {selection get -displayof .npad.k.t} sel]} {
		Inf "No Line Selection Made"
		return
	}
	set sel [string trim $sel]
	if {[string length $sel] <= 0} {
		Inf "No Line Selection Made"
		return
	}
	set callcentre [GetCentre [lindex $wstk end]]
	set f .nbkbat
	if [Dlg_Create $f "To Textfile" "set pr_nbkbat 0" -borderwidth $evv(BBDR)] {
		frame $f.0
		button $f.0.save -text "Save" -command "set pr_nbkbat 1" -highlightbackground [option get . background {}]
		button $f.0.quit -text "Abandon" -command "set pr_nbkbat 0" -highlightbackground [option get . background {}]
		pack $f.0.save -side left
		pack $f.0.quit -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Output File Name  "
		entry $f.1.e -textvariable nbkbatfil -width 20
		pack $f.1.ll $f.1.e -side left
		pack $f.1 -side top
		checkbutton $f.2 -text "Batchfile" -variable not_bat
		pack $f.2 -side top -pady 2
		wm resizable $f 1 1
		bind $f <Escape> {set pr_nbkbat 0}
		bind $f <Return> {set pr_nbkbat 1}
	}
	set not_bat 0
	set pr_nbkbat 0
	raise $f
	update idletasks
	set geo [CentreOnCallingWindow $f $callcentre]
	My_Grab 0 $f pr_nbkbat $f.1.e
	set finished 0
	while {!$finished} {
		tkwait variable pr_nbkbat
		if {$pr_nbkbat} {
			if {[string length $nbkbatfil] <= 0} {
				Inf "No Filename Entered"
				continue
			}
			if {![ValidCDPRootname $nbkbatfil]} {
				continue
			}
			set nbkbatfilnam [string tolower $nbkbatfil]
			if {$not_bat} {
				append nbkbatfilnam ".bat"
			} else {
				append nbkbatfilnam $evv(TEXT_EXT)
			}
			if {[file exists $nbkbatfilnam]} {
				set msg "File $nbkbatfilnam Already Exists.  Overwrite It ?"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
			}
			if [catch {open $nbkbatfilnam "w"} zit] {
				Inf "Cannot Open File $nbkbatfilnam"
				continue
			}
			puts $zit $sel
			close $zit
			if {[FileToWkspace $nbkbatfilnam 0 0 0 0 1] > 0} {
				Inf "File $nbkbatfilnam Is Now On The Workspace"
			}
		}
		set finished 1
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}
