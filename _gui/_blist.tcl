#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD 30 June 2013
# ... fixup button rectangles

#######################
# BACKGROUND LISTINGS #
#######################

#---- make Blist from contents of Wkspace

proc BListFromWkspace {listing selected dupl} {
	global dl b_l b_l_name same_b_l wl ch background_listing chcnt wstk play_pll sub_listing evv
	global hidden_dir sub_listing only_for_mix

	set i 0
	if {[string match "dirlist" $listing]} {
		if {![info exists dl]} {
			Inf "No Files Have Been Selected From The Directory Listing."
			return
		} else {
			set listing $dl
		}
	}

	if {[info exists play_pll] && [string match $listing $play_pll]} {
		set origlist [$play_pll curselection]
		if {![info exists origlist] || ([llength $origlist] <= 0)} {
			Inf "No Files Have Been Selected From The Playlist"
			return
		}
		foreach i $origlist {
			set fnam [$play_pll get $i]
			if {![string match $fnam [file tail $fnam]]} {
				lappend ilist $i
			}
			incr i
		}
		if {![info exists ilist]} {
			set msg "You Have Only Selected Home Directory Files From The Playlist\n\n"
			set msg2 [BigMessage]
			append msg $msg2
			Inf $msg
			return
		}
	} elseif {[info exists sub_listing] && [string match $listing $sub_listing]} {
		catch {unset ilist}
		set i 0
		foreach item [$sub_listing get 0 end] {
			if {[string match [file tail $item] $item]} {
				set msg [BigMessage]
				Inf $msg
				return
			}
			lappend ilist $i
			incr i
		}
	} else {
		switch -regexp -- $listing \
			^$wl$ {
				if {$selected} {
					set origlist [$wl curselection]
					if {![info exists origlist] || ([llength $origlist] <= 0)} {
						Inf "No Files Have Been Selected From The Workspace"
						return
					}
					foreach i $origlist {
						set fnam [$wl get $i]
						if {![string match $fnam [file tail $fnam]]} {
							lappend ilist $i
						}
						incr i
					}
					if {![info exists ilist]} {
						set msg "You Have Only Selected Home Directory Files From The Workspace\n\n"
						set msg2 [BigMessage]
						append msg $msg2
						Inf $msg
						return
					}
				} else {
					if {![AreYouSure]} {
						return
					}
					foreach fnam [$wl get 0 end] {
						if {![string match $fnam [file tail $fnam]]} {
							lappend ilist $i
						}
						incr i
					}
					if {![info exists ilist]} {
						set msg "There Are Only Home Directory Files On The Workspace\n\n"
						set msg2 [BigMessage]
						append msg $msg2
						Inf $msg
						return
					}
				}
			} \
			^$ch$ {
				if {[info exists only_for_mix]} {
					Inf "Duplicate Files On Chosen Files List: Cannot Proceed"
					return
				}
				if {$chcnt == 0} {
					Inf "There Are No Files On The Chosen Files List"
					return
				}
				foreach fnam [$ch get 0 end] {
					if {![string match $fnam [file tail $fnam]]} {
						lappend ilist $i
					}
					incr i
				}
				if {![info exists ilist]} {
					set msg "There Are Only Home Directory Files On The Chosen Files List\n\n"
					set msg2 [BigMessage]
					append msg $msg2
					Inf $msg
					return
				}
			} \
			^$dl$ {
				set origlist [$dl curselection]
				if {![info exists origlist] || ([llength $origlist] <= 0)} {
					Inf "No Files Have Been Selected From The Directory Listing"
					return
				}
				set zfnam [$dl get 0]
				if {[string length $hidden_dir] > 0} {
					set zfnam [file join $hidden_dir $zfnam]
				}
				if {[string match [file tail $zfnam] $zfnam]} {
					set msg [BigMessage]
					Inf $msg
					return
				}
				foreach i $origlist {
					set newfile	[$dl get $i]
					if {[string length $hidden_dir] > 0} {
						set newfile [file join $hidden_dir $newfile]
					}
					if {![file isdirectory $newfile]} {
						lappend ilist $i
					}
				}
				if {![info exists ilist]} {
					Inf "No Files Have Been Selected From The Directory Listing (only Subdirectories)"
					return
				}
			}

	}
	set OK 0
	if {[info exists same_b_l]} {
		set OK 1
		set b_l_name $same_b_l
		set choice [tk_messageBox -type yesno -default yes \
		-message "To Background Listing '$same_b_l'?" -icon question -parent [lindex $wstk end]]
		if {$choice == "no"} {
			set OK 0
		}
	}
	if {!$OK} {
		set b_l_name ""
		GetBLName 0
	}
	if {[string length $b_l_name] > 0} {
		set same_b_l $b_l_name
		Block "GRABBING SELECTED FILES TO $b_l_name"
		set blfile_preexisted 0
		if {[file exists $background_listing]} {
			set blfile_preexisted 1
		}
		GetMoreBL $b_l_name $ilist $listing $blfile_preexisted $background_listing $dupl
		UnBlock
	} else {
		catch {unset b_l_name}
	}
}	

#---- Remove any files on wkspace Unique to last Background listed on wkspace

proc RemoveBkgd {all} {
	global last_b_l last_bl_name last_bl_name2 wstk
	switch -- $all {
		0 {
			if {[info exists last_b_l]} {
				RemoveFromWkspace bkgd
				unset last_b_l
			} else {
				Inf "Either No Background List Has Been Loaded\n\nOr The Files Have Already Been Removed"
			}
		}
		1 {
			if {[info exists last_bl_name]} {
				set msg "Remove From Workspace Files\n\nIn Background Listing '$last_bl_name' ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "yes"} {
					RemoveFromWkspace bkgdall
				}
			} else {
				Inf "No Background Listing Has Been Loaded In This Session"
			}
		}
		2 {
			if {[info exists last_bl_name2]} {
				set msg "Remove From Workspace All Files\n\nIn Background Listing '$last_bl_name2' ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "yes"} {
					RemoveFromWkspace bkgdall2
				}
			} else {
				Inf "No Background Listing Has Been Accessed In This Session"
			}
		}
	}
}

#------- Enter, or choose, a name for a Background Listing and do something to it

proc GetBLName {kill} {
	global pr_bln b_l bln_var b_l_name same_b_l last_bl_name2 background_listing wl pa pitchmark got_bls grabbed_bln evv
	global bl_srchstr score_files last_score_bl remain_list wstk scoremixlist dupl_mix dupl_vbx dupl_txt

	if {($kill == 11) && ($dupl_mix || $dupl_vbx || $dupl_txt)} {
		Inf "Duplicate Files On Chosen List: Cannot Proceed"
		return
	}

	if {($kill == 5) || ($kill == 6) || ($kill == 7)} {
		catch {destroy .pmark}
	}
	switch -- $kill {
		9 {
			if {![info exists got_bls]} {
				return
			}
		}
		15 {
			set filelist [ListFromScore 1234]
			if {[llength $filelist] <= 0} {
				Inf "There Are No Files On The Sketch Score"
				return
			}
		}
		16 {
			if {![info exists scoremixlist] || ([llength $scoremixlist] <= 0)} {
				Inf "No Files Have Been Selected"
				return
			}
			set filelist $scoremixlist
		}
	}
	catch {unset grabbed_bln}
	set f .bln
	if [Dlg_Create $f "GET BACKGROUND LISTING NAME" "set pr_bln 0" -width 65 -borderwidth $evv(SBDR)] {
		set a [frame $f.a -borderwidth $evv(SBDR)]
		set b [frame $f.b -borderwidth $evv(SBDR)]
		set c [frame $f.c -borderwidth $evv(SBDR)]
		set e [frame $f.e -borderwidth $evv(SBDR)]
		set g [frame $f.g -borderwidth $evv(SBDR)]
		set h [frame $f.h -borderwidth $evv(SBDR)]
		set d [frame $f.d -borderwidth $evv(SBDR)]

		menubutton $a.a -text "" -menu $a.a.menu -bd 0 -relief flat -state disabled -width 20
		set m3 [menu $a.a.menu -tearoff 0]
		$m3 add command -label "Create New B-List" -command {CreateEmptyBlist} -foreground black
		$m3 add separator
		$m3 add command -label "Destroy Current B-List" -command {DestroyBlist} -foreground black
		menubutton $a.b -text "" -menu $a.b.menu -bd 0 -relief flat -state disabled -width 20
		set m2 [menu $a.b.menu -tearoff 0]
		$m2 add command -label "From Workspace" -command {GetSoundFromWkspace 0 0} -foreground black
		$m2 add separator
		$m2 add command -label "From Elsewhere" -command {FileFind 0 1 1} -foreground black
		button $a.q -text "Close" -command "set pr_bln 0" -highlightbackground [option get . background {}]
		pack $a.a $a.b -side left -pady 2 -padx 4 -fill x -anchor center
		pack $a.q -side right
		button $b.d -text "" -command {} -width 20 -highlightbackground [option get . background {}]
		button $b.d2 -text "" -command {} -width 20 -highlightbackground [option get . background {}]
		button $b.d3 -text "" -command {} -width 20 -highlightbackground [option get . background {}]
		pack $b.d $b.d2 $b.d3 -side left -padx 4
		label $c.l -text "" -width 35 -foreground $evv(SPECIAL)
		pack $c.l -side left -fill x -expand true
		label $e.l -text "     B-list Name" -width 14
		entry $e.e -textvariable bln_var -width 24
		button $e.play -text " PLAY " -command {set pr_bln 2} -bd 2 -highlightbackground [option get . background {}]
		button $e.a -text "A" -command "PlaySndfile $evv(TESTFILE_A) 0" -bd 4  -width 2  -highlightbackground [option get . background {}];# -bg $evv(HELP)
		pack $e.play -side left -fill x -padx 3
		pack $e.l $e.e -side left
		pack $e.a -side right -fill x -padx 3

		menubutton $h.pm -text "" -menu $h.pm.menu -bd 0 -relief flat -state disabled -width 9
		set mm [menu $h.pm.menu -tearoff 0]
		$mm add command -label "FIND SELECTED FILE ELSEWHERE" -command {} -foreground black
		$mm add separator 
		$mm add command -label "Find File In Other Blists" -command {set pr_bln 5} -foreground black
		$mm add separator
		$mm add command -label "Find File In Logs" -command {set pr_bln 8} -foreground black
		$mm add separator 
		$mm add command -label "USE SELECTED FILES ELSEWHERE" -command {}  -foreground black
		$mm add separator 
		$mm add command -label "Files To Workspace" -command {set pr_bln 7} -foreground black
		$mm add separator 
		$mm add command -label "File Directory To Wkspace" -command {set pr_bln 9} -foreground black
		$mm add separator 
		$mm add command -label "List Files In A Textfile" -command {set pr_bln 10} -foreground black

		menubutton $h.s0 -text "" -menu $h.s0.menu -bd 0 -relief flat -state disabled -width 9
		set m [menu $h.s0.menu -tearoff 0]
		$m add command -label "FIND" -command {}  -foreground black
		$m add separator 
		$m add command -label "Find Matches In File List Shown" -command {SearchBlists 0} -foreground black
		$m add separator 
		$m add command -label "Find Matching Files In All B-Lists" -command {SearchBlists 1} -foreground black
		$m add separator 
		$m add command -label "Find Match Of Directory Name In B-Lists" -command {SearchBlists 2} -foreground black
		$m add separator 
		$m add command -label "GET SEARCH STRING" -command {}  -foreground black
		$m add separator 
		$m add command -label "Use File Directory As Search String" -command {SearchBlists 3} -foreground black
		$m add separator 
		$m add command -label "Use File Name As Search String" -command {SearchBlists 4} -foreground black

		menubutton $h.s1 -text "" -menu $h.s1.menu -bd 0 -relief flat -state disabled -width 9
		set m1 [menu $h.s1.menu -tearoff 0]
		$m1 add command -label "See File Pitchmark" -command {set pr_bln 6} -foreground black
		$m1 add separator 
		$m1 add command -label "Compare With All Existing Pmarks" -command "ManipulatePmarks .bln.d.d2.ll.list 1" -foreground black
		$m1 add separator 
		$m1 add command -label "Compare Two Pitch Marks" -command "PmarkCompare .bln.d.d2.ll.list" -foreground black

		label $h.ll -text "Search String"
		entry $h.ee -textvariable bl_srchstr -width 20 -disabledbackground [option get . background {}]
		button $h.he -text "" -command {} -bd 0 -state disabled -highlightbackground [option get . background {}]
		pack $h.s0 $h.ll $h.ee -side left -padx 3
		pack $h.he $h.s1 $h.pm -side right -padx 3
		set dd [frame $d.d -borderwidth $evv(SBDR)]
		set dd2 [frame $d.d2 -borderwidth $evv(SBDR)]
		label $dd.l -text "B-LIST NAMES"
		label $dd2.l -text "FILES IN B-LIST"
		Scrolled_Listbox $dd.ll -width 20 -height 20 -selectmode single
		Scrolled_Listbox $dd2.ll -width 45 -height 20 -selectmode single
		pack $dd.l $dd.ll -side top -pady 1
		pack $dd2.l $dd2.ll -side top -pady 1
		pack $dd $dd2 -side left -fill x -expand true
		pack $a $b $h $c $g $e $d -side top -fill x -expand true -pady 1
		wm resizable $f 1 1
		bind .bln <Control-Key-P> {UniversalPlay list .bln.d.d2.ll.list}
		bind .bln <Control-Key-p> {UniversalPlay list .bln.d.d2.ll.list}
		bind .bln <Control-Key-G> {GrabFromBkgd .bln.d.d2.ll.list}
		bind .bln <Control-Key-g> {GrabFromBkgd .bln.d.d2.ll.list}
		bind .bln <Key-space> {UniversalPlay list .bln.d.d2.ll.list}
		bind .bln <Double-1>  {UniversalPlay list .bln.d.d2.ll.list}
		bind $f <Escape> {set pr_bln 0}
	}
	set bln_var ""
	bind $f.d.d2.ll.list <ButtonRelease-1> {}
	$f.a.a config -text "" -bd 0 -relief flat -state disabled 
	$f.a.b config -text "" -bd 0 -relief flat -state disabled 
	$f.b.d2 config -text "" -command {} -bd 0 -state disabled -width 20
	$f.b.d3 config -text "" -command {} -state disabled -bd 0 -bg [option get . background {}] 
	$f.e.play config -text "" -command {} -bd 0 -state disabled
	$f.e.a config -text "" -command {} -bd 0 -state disabled -bg [option get . background {}] -width 2
	$f.h.pm config -text "" -bd 0 -relief flat -state disabled
	$f.h.s0 config -text "" -bd 0 -relief flat -state disabled
	$f.h.s1 config -text "" -bd 0 -relief flat -state disabled
	$f.h.ll config -text ""
	$f.h.ee config -bd 0 -state disabled
	$f.h.he config -text "" -command {} -bd 0 -state disabled -bg [option get . background {}]
	switch -- $kill {
		0 {
			wm title $f "BACKGROUND LISTING NAME"
			$f.b.d config -text "FILES TO LISTING" -command "set pr_bln 1" -bd 2
			$f.c.l config -text "TO ADD TO AN EXISTING LISTING\nChoose from listed NAMES with the mouse\n\nTO CREATE A NEW LISTING\nWrite a name in the box"
			$f.e.e config -state normal -bd 2
			$f.e.l config -text "     B-list Name" -width 14
			$f.d.d2.l config -text "FILES IN B-LIST"
			bind $f.d.d.ll.list <ButtonRelease-1> {set bln_var [GetBlnName %y 0]}
			$f.d.d2.ll.list config -selectmode single
			$f.d.d.ll.list config -selectmode single
		}
		1 {
			wm title $f "DESTROY BACKGROUND LISTING"
			$f.b.d config -text "DESTROY LISTING" -command "set pr_bln 1" -bd 2
			$f.c.l config -text "TO DESTROY A LISTING\n\nCHOOSE IT FROM THE LISTED NAMES WITH THE MOUSE\n\nAND PRESS 'DESTROY LISTING'"
			$f.e.e config -state disabled -bd 2
			$f.e.l config -text "     B-list Name" -width 14
			$f.d.d2.l config -text "FILES IN B-LIST"
			bind $f.d.d.ll.list <ButtonRelease-1> {.bln.e.e config -state normal; set bln_var [GetBlnName %y 0]; .bln.e.e config -state disabled}
			$f.d.d2.ll.list config -selectmode single
			$f.d.d.ll.list config -selectmode single
		} 
		2 -
		9 {
			wm title $f "PLAY/EDIT BACKGROUND LISTING"
			$f.b.d config -text "PLAY OR READ FILE" -command {set pr_bln 2} -bd 2
			$f.b.d2 config -text "REMOVE FROM B-LIST" -command {set pr_bln 1} -bd 2 -state normal -width 20
			$f.c.l config -text "CLICK ON A LISTING NAME TO SEE THE LISTING\n\nCLICK ON LISTED FILE TO SELECT IT\n\nCHOOSE PLAY OR REMOVE"
			$f.e.e config -state disabled -bd 2
			bind $f.d.d.ll.list <ButtonRelease-1> {.bln.e.e config -state normal; set bln_var [GetBlnName %y 1]; .bln.e.e config -state disabled}
			$f.d.d2.ll.list config -selectmode single
			$f.e.play config -text "SEE\nPMARK" -command "set pr_bln 4" -bd 2 -state normal
			$f.e.l config -text "     B-list Name" -width 14
			$f.d.d2.l config -text "FILES IN B-LIST"
			$f.e.a config -text "FILELIST\nTO TEXTFILE" -command "set pr_bln 3" -bd 2 -state normal -bg [option get . background {}] -width 11
			$f.d.d.ll.list config -selectmode single
		} 
		3 {
			wm title $f "GET BACKGROUND LISTING FILES"
			$f.b.d config -text "USE LISTING" -command "set pr_bln 1" -bd 2
			$f.c.l config -text "\n\nCHOOSE FROM LISTED NAMES WITH THE MOUSE\n\n"
			$f.e.e config -state disabled -bd 2
			$f.e.l config -text "     B-list Name" -width 14
			$f.d.d2.l config -text "FILES IN B-LIST"
			bind $f.d.d.ll.list <ButtonRelease-1> {.bln.e.e config -state normal; set bln_var [GetBlnName %y 0]; .bln.e.e config -state disabled}
			$f.d.d2.ll.list config -selectmode single
			$f.d.d.ll.list config -selectmode single
		}
		4 {
			wm title $f "RENAME BACKGROUND LISTING"
			$f.b.d config -text "RENAME LISTING" -command "set pr_bln 1" -bd 2
			$f.c.l config -text "\nSELECT AN EXISTING LISTING WITH THE MOUSE\n\nENTER A NEW NAME FOR SELECTED LISTING\n"
			$f.e.e config -state normal -bd 2
			$f.e.l config -text "     B-list Name" -width 14
			$f.d.d2.l config -text "FILES IN B-LIST"
			bind $f.d.d.ll.list <ButtonRelease-1> {GetBlnName %y 1}
			$f.d.d2.ll.list config -selectmode single
			$f.d.d.ll.list config -selectmode single
		}
		5 {
			wm title $f "PITCH MARK A SOUND"
			$f.b.d config -text "CREATE/EDIT PITCH MARK" -command "set pr_bln 1" -bd 2
			$f.b.d2 config -text "REMOVE PITCH MARK" -command "set pr_bln 3" -bd 2 -state normal -width 20
			$f.c.l config -text "\n\nSELECT A LISTING WITH THE MOUSE\n\n"
			$f.e.e config -state disabled -bd 2
			$f.e.l config -text "     B-list Name" -width 14
			$f.d.d2.l config -text "FILES IN B-LIST"
			bind $f.d.d.ll.list <ButtonRelease-1> {.bln.e.e config -state normal; set bln_var [GetBlnName %y 1]; .bln.e.e config -state disabled}
			$f.d.d2.ll.list config -selectmode single
			$f.e.play config  -text " PLAY " -command "set pr_bln 2" -bd 2 -state normal
			$f.e.a config -text "A" -command "PlaySndfile $evv(TESTFILE_A) 0" -bd 4 -state normal -width 2 ;# -bg $evv(HELP)
			$f.d.d.ll.list config -selectmode single
		}
		6 {
			wm title $f "SHOW PITCH MARKED SOUNDS"
			$f.b.d config -text "COMPARE 2 PITCH MARKS" -command "set pr_bln 1" -bd 2
			$f.b.d2 config -text "SHOW PITCH MARK" -command "set pr_bln 3" -bd 2 -width 20 -state normal
			$f.c.l config -text "\nSELECT A LISTING WITH THE MOUSE\n\nANY PITCH MARKED FILES WILL BE HIGHLIGHTED\n"
			$f.e.e config -state disabled -bd 2
			$f.e.l config -text "     B-list Name" -width 14
			$f.d.d2.l config -text "FILES IN B-LIST"
			bind $f.d.d.ll.list <ButtonRelease-1> {ShowBlistPmarks %y}
			$f.d.d2.ll.list config -selectmode multiple
			$f.e.a config -text "CLEAR\nHIGHLIGHTS" -command {.bln.d.d2.ll.list selection clear 0 end}  -bd 2 -state normal -bg [option get . background {}] -width 9
			$f.d.d.ll.list config -selectmode single
		}
		7 {
			wm title $f "COMPARE PITCH MARK WITH OTHERS"
			$f.b.d config -text "COMPARE PITCH MARK" -command "set pr_bln 1" -bd 2
			$f.c.l config -text "\nSELECT A LISTING WITH THE MOUSE\n\nSELECT A FILE FROM THE 2nd DISPLAY\n"
			$f.e.e config -state disabled -bd 2
			$f.e.l config -text "     B-list Name" -width 14
			$f.d.d2.l config -text "FILES IN B-LIST"
			bind $f.d.d.ll.list <ButtonRelease-1> {.bln.e.e config -state normal; set bln_var [GetBlnName %y 1]; .bln.e.e config -state disabled}
			$f.d.d2.ll.list config -selectmode single
			$f.d.d.ll.list config -selectmode single
		}
		8 {
			wm title $f "CHOOSE BACKGROUND LISTING"
			$f.b.d config -text "CHOOSE LISTING" -command "set pr_bln 1" -bd 2
			$f.c.l config -text "TO CHOOSE A LISTING\n\nCHOOSE IT FROM THE LISTED NAMES WITH THE MOUSE\n\nAND PRESS 'CHOOSE LISTING'"
			$f.e.e config -state disabled -bd 2
			$f.e.l config -text "     B-list Name" -width 14
			$f.d.d2.l config -text "FILES IN B-LIST"
			bind $f.d.d.ll.list <ButtonRelease-1> {.bln.e.e config -state normal; set bln_var [GetBlnName %y 0]; .bln.e.e config -state disabled}
			$f.d.d2.ll.list config -selectmode single
			$f.d.d.ll.list config -selectmode single
		} 
		10 {
			wm title $f "SPECIFIC FILES TO WORKSPACE"
			$f.b.d config -text "GRAB FILES\nTO WORKSPACE" -command "set pr_bln 1" -bd 2
			$f.b.d2 config -text "GRAB DIRECTORY OF FILE\nTO DIRECTORY LISTING" -command "set pr_bln 3" -bd 2 -state normal -width 23
			$f.c.l config -text "TO SEE FILES IN A LISTING\nCHOOSE LISTING NAMES WITH THE MOUSE\n\nTO GRAB FILES\nSELECT FROM 2ND LIST, AND PRESS 'GRAB'"
			$f.e.e config -state disabled -bd 2
			$f.e.l config -text "     B-list Name" -width 14
			$f.d.d2.l config -text "FILES IN B-LIST"
			bind $f.d.d.ll.list <ButtonRelease-1> {.bln.e.e config -state normal; set bln_var [GetBlnName %y 0]; .bln.e.e config -state disabled}
			$f.d.d2.ll.list config -selectmode extended
			$f.d.d.ll.list config -selectmode single
		} 
		14 {
			wm title $f "SPECIFIC FILES TO CHOSEN FILES LIST"
			$f.b.d config -text "GRAB FILES\nTO WORKSPACE" -command "set pr_bln 1" -bd 2
			$f.c.l config -text "TO SEE FILES IN A LISTING\nCHOOSE LISTING NAMES WITH THE MOUSE\n\nTO GRAB FILES\nSELECT FROM 2ND LIST, AND PRESS 'GRAB'"
			$f.e.e config -state disabled -bd 2
			$f.e.l config -text "     B-list Name" -width 14
			$f.d.d2.l config -text "FILES IN B-LIST"
			bind $f.d.d.ll.list <ButtonRelease-1> {.bln.e.e config -state normal; set bln_var [GetBlnName %y 0]; .bln.e.e config -state disabled}
			$f.d.d2.ll.list config -selectmode extended
			$f.d.d.ll.list config -selectmode single
		} 
		11 {
			wm title $f "MUSIC WORKPAD"
			$f.a.a config -text "Create/Destroy" -state normal -relief raised -bd 3
			$f.a.b config -text "Find Files" -state normal -relief raised -bd 3
			$f.b.d config -text "GET B-LIST FILES" -command "set pr_bln 1" -bd 2
			$f.b.d2 config -text "GET & REMOVE FILES" -command "set pr_bln 3" -bd 2 -state normal -width 20
			$f.b.d3 config -text "PUT FILES"  -command "set pr_bln 4"  -bd 2 -state normal -width 20
			$f.c.l config -text "\n"
			$f.e.e config -state disabled -bd 2
			$f.e.l config -text "     B-list Name" -width 14
			$f.d.d2.l config -text "FILES IN B-LIST"
			bind $f.d.d.ll.list <ButtonRelease-1> {.bln.e.e config -state normal; set bln_var [GetBlnName %y 0]; .bln.e.e config -state disabled}
			$f.d.d.ll.list config -selectmode single
			$f.d.d2.ll.list config -selectmode extended
			$f.e.play config  -text " PLAY:READ" -command "set pr_bln 2" -bd 2 -state normal
			$f.e.a config -text "A" -command "PlaySndfile $evv(TESTFILE_A) 0" -bd 4 -state normal -width 2 ;# -bg $evv(HELP)
			$f.h.pm config -text "FileOps" -bd 3 -relief raised -state normal
			$f.h.s1 config -text "Pichmrk" -bd 3 -relief raised -state normal
			$f.h.s0 config -text "Search" -bd 3 -relief raised -state normal
			$f.h.ll config -text "Search\nString"
			$f.h.ee config -bd 2 -state normal
			$f.h.he config -text "Help" -command {CDP_Specific_Usage $evv(TE_26) 0} -bd 2 -state normal ;# -bg $evv(HELP)
		} 
		12 -
		13 {
			wm title $f "SELECT FILE FOR SKETCH SCORE"
			$f.b.d config -text "USE FILE" -command "set pr_bln 1" -bd 2
			$f.b.d2 config -text "IN OTHER BLISTS?" -command "set pr_bln 3" -bd 2 -state normal -width 20
			$f.b.d3 config -text "Notebook"  -command "NnnSee" -bd 2 -state normal -width 12 -bg $evv(HELP)
			$f.c.l config -text "\nSELECT A LISTING WITH THE MOUSE\n\nSELECT A FILE FROM THE 2nd DISPLAY\n"
			$f.e.e config -state disabled -bd 2
			$f.e.l config -text "     B-list Name" -width 14
			$f.d.d2.l config -text "FILES IN B-LIST"
			bind $f.d.d.ll.list <ButtonRelease-1> {.bln.e.e config -state normal; set bln_var [GetBlnName %y 0]; .bln.e.e config -state disabled}
			$f.d.d2.ll.list config -selectmode multiple
			$f.d.d.ll.list config -selectmode single
			$f.e.play config  -text " PLAY " -command "set pr_bln 2" -bd 2 -state normal
			$f.e.a config -text "A" -command "PlaySndfile $evv(TESTFILE_A) 0" -bd 4 -state normal -width 2 ;# -bg $evv(HELP)
		}
		15 {
			wm title $f "REMOVE SKETCH SCORE FILES FROM B-LIST"
			$f.b.d config -text "B-LIST TO\nSUBTRACT FROM" -command "set pr_bln 1" -bd 2
			$f.b.d2 config -text "B-LIST\nTO SAVE AS" -command "set pr_bln 3" -bd 2 -state normal
			$f.c.l config -text "\n\nSELECT A LISTING WITH THE MOUSE\n\n"
			$f.e.e config -state normal -bd 2
			$f.e.l config -text "     B-list Name" -width 14
			$f.d.d2.l config -text "FILES IN B-LIST"
			bind $f.d.d.ll.list <ButtonRelease-1> {set bln_var [GetBlnName %y 0]}
			$f.d.d.ll.list config -selectmode single
			$f.d.d2.ll.list config -selectmode single
		}
		16 {
			wm title $f "ADD FILES TO B-LIST AT GIVEN POSITION"
			$f.b.d config -text "ADD FILES" -command "set pr_bln 1" -bd 2
			$f.c.l config -text "SELECT A B-LIST WITH THE MOUSE\nSELECT INSERTION POSITION IN FILES LIST\nTO INSERT AT END, MAKE NO SELECTION\nTO CLEAR SELECTION, RESELECT B-LIST"
			$f.e.e config -state disabled -bd 2
			$f.e.l config -text "     B-list Name" -width 14
			$f.d.d2.l config -text "FILES IN B-LIST"
			bind $f.d.d.ll.list <ButtonRelease-1> {.bln.e.e config -state normal; set bln_var [GetBlnName %y 0]; .bln.e.e config -state disabled}
			$f.d.d.ll.list config -selectmode single
			$f.d.d2.ll.list config -selectmode single
		}
		17 {	
			wm title $f "ARE BLISTS MUTUALLY EXCLUSIVE ?"
			$f.b.d config -text "PLAY FILE" -command {set pr_bln 2} -bd 2
			$f.b.d2 config -text "COMPARE" -command {set pr_bln 1} -bd 2 -state normal -width 20
			$f.c.l config -text "CHOOSE TWO OR MORE BLISTS\n\nTO DO THE COMPARISON\n"
			$f.e.e config -state disabled -bd 0
			$f.e.l config -text "" -width 14
			$f.d.d2.l config -text "FILES IN SEVERAL B-LISTS"
			bind $f.d.d.ll.list <ButtonRelease-1> {}
			$f.d.d.ll.list config -selectmode multiple
			$f.d.d2.ll.list config -selectmode single
			$f.e.play config -text "" -command {} -bd 0 -state disabled
			$f.e.a config -text "" -command {} -bd 0 -state disabled -bg [option get . background {}]
			$f.b.d3 config -text "SND IN WHICH BLISTS?"  -command "set pr_bln 4"  -bd 2 -state normal -width 20
		}
	}
	$f.d.d.ll.list delete 0 end
	$f.d.d2.ll.list delete 0 end
	if {$kill == 9} {
		foreach index $got_bls {
			lappend templist $index
		}
		set kill 2
	} else {
		foreach index [array names b_l] {
			lappend templist $index
		}
	}
	if {[info exists templist]} {
		foreach item [lsort -dictionary $templist] {
			$f.d.d.ll.list insert end $item
		}
	}
	if {$kill == 13} {
		.bln.e.e config -state normal
		set bln_var $last_score_bl
		.bln.e.e config -state disabled
		if [info exists b_l($bln_var)] {
			foreach fnam $b_l($bln_var) {
				$f.d.d2.ll.list insert end $fnam
			}
		}
		set kill 12
	} else {
		set bln_var ""
	}
	catch {unset blist_nameslist}
	raise $f
	update idletasks
	StandardPosition $f
	set pr_bln 0
	set listing_altered 0
	set finished 0
	My_Grab 0 $f pr_bln $f.e.e
	while {!$finished} {
		tkwait variable pr_bln
		switch -- $kill {
			0 -
			1 -
			3 -
			8 {
				$f.d.d2.ll.list delete 0 end
			}
		}
		switch -- $pr_bln {
			0 {													;#	QUIT
				set finished 1
			}
			2 {			;# PLAY
				set ilist [.bln.d.d2.ll.list curselection]
				set i [lindex $ilist 0]
				if {![info exists i] || ($i < 0)} {
					Inf "No File Selected"
					continue
				}
				set pa_preexisted 1
				set fnam [.bln.d.d2.ll.list get $i]
				set ftyp [FindFileType $fnam]
				if {$ftyp < 0} {
					continue
				}
				if {$ftyp == $evv(SNDFILE)} {
					PlaySndfile $fnam 0
				} elseif {$kill == 2 || $kill == 11} {
					if {$ftyp & $evv(IS_A_TEXTFILE)} {
						SimpleDisplayTextfile $fnam
					} else {
						Inf "'$fnam' Is Neither A Soundfile Nor A Textfile"
					}
				} else {
					Inf "'$fnam' Is Not A Soundfile"
				}
			}
			default {											;# ACT ON BLIST (pr_bln = 1 or 3,4,5,6)
				if {$kill != 17} {
					if {[string length $bln_var] <= 0} {
						if {$kill == 4} {
							Inf "No New Background Listing Name Entered"
						} else {
							Inf "No Background Listing Name Entered"
						}
						continue
					}
				}
				switch -- $kill {
					3 -
					0 {														;# RETURN BLIST NAME
						if [regexp {[^A-Za-z0-9_\-]} $bln_var] {
							Inf "Invalid Characters In Name (Use letters, numbers, dash or underscore only)"
							continue
						}
						set b_l_name [string tolower $bln_var]		
						if {[string length $bln_var] > 0} {
							set last_bl_name2 $b_l_name
						}
						set finished 1
					}
					1 {														;# DESTROY BLIST
						if [DestroyBlist] {
							set listing_altered 1
							if {[array size b_l] <= 0} {
								catch {unset b_l}
								set finished 1
							}
						}
					}
					2 {											
						if {[string length $bln_var] <= 0} {
							Inf "No Background Listing Name Entered"
							continue
						}
						switch -- $pr_bln {
							1 {												;# REMOVE FILE FROM BLIST
								set i [.bln.d.d2.ll.list curselection]
								if {![info exists i] || ($i < 0)} {
									Inf "No Item Selected For Removal From Listing"
									continue
								}
								if {[AreYouSure]} {
									.bln.d.d2.ll.list delete $i
									set b_l($bln_var) [lreplace $b_l($bln_var) $i $i]
									if {[llength $b_l($bln_var)] <= 0} {
										unset b_l($bln_var)
									}
									if {[array size b_l] <= 0} {
										catch {unset b_l}
										set b_l_name ""
										set finished 1
									}
									set listing_altered 1
								}
							}
							3 {												;# SAVE BLIST TO TEXTFILE
								foreach fnam [.bln.d.d2.ll.list get 0 end] {
									lappend ftotext $fnam
								}
								if {![info exists ftotext]} {
									Inf "No Files Listed"
								} else {
									BlistToTextfile $ftotext
									unset ftotext
								}
								continue
							}										
							4 {												;# DISPLAY PMARK OF BLIST FILE
								set i [.bln.d.d2.ll.list curselection]
								if {![info exists i] || ($i < 0)} {
									Inf "No File Selected"
									continue
								}
								Do_Pitchmark .bln.d.d2.ll.list $evv(DISPLAY_PMARK)
								continue
							}										
						}
					}
					4 {														;# RENAME BLIST
						set OK 1
						if [regexp {[^A-Za-z0-9_\-]} $bln_var] {
							Inf "Invalid Characters In Name (Use letters, numbers, dash or underscore only)"
							continue
						}
						foreach item [.bln.d.d.ll.list get 0 end] {
							if {[string match $item $bln_var]} {
								Inf "This Name Is Already In Use"
								set OK 0
								break
							}
						}
						if {!$OK} {
							continue
						}
						set i [.bln.d.d.ll.list curselection]
						if {![info exists i] || ($i < 0)} {
							Inf "No Item Selected For Renaming"
							continue
						}
						if {[AreYouSure]} {
							set old_name [.bln.d.d.ll.list get $i]
							set b_l($bln_var) $b_l($old_name)
							unset b_l($old_name)
							.bln.d.d.ll.list delete $i
							.bln.d.d.ll.list insert $i $bln_var
							set listing_altered 1
							set last_bl_name2 $bln_var
						}
					}
					5 -
					7 {														
						set i [.bln.d.d2.ll.list curselection]
						if {![info exists i] || ($i < 0)} {
							Inf "No Soundfile Selected"
							continue
						}
						set lastbhi $i
						set pa_preexisted 1
						set fnam [.bln.d.d2.ll.list get $i]
						set ftyp [FindFileType $fnam]
						if {!($ftyp == $evv(SNDFILE))} {
							Inf "'$fnam' Is Not A Soundfile"
							continue
						}
						if {$kill == 5} {
							if {$pr_bln==3} {
								DoPitchmark $fnam 1							;# DELETE PITCH MARK
							} else {
								DoPitchmark $fnam 0							;# CREATE OR EDIT PITCH MARK
							}
							if {[info exists lastbhi]} {
								.bln.d.d2.ll.list selection set $lastbhi
							}
						} elseif {$kill == 7} {
							if {![info exists pitchmark($fnam)]} {
								Inf "No Pitch Mark Exists For File '$fnam'"
							} else {
								ManipulatePmarks .bln.d.d2.ll.list 1		;# COMPARE ONE PMARK WITH ALL OTHERS
							}
						}
					}
					6 {
						if {$pr_bln == 3} {									;# SHOW PMARK
							Do_Pitchmark .bln.d.d2.ll.list $evv(DISPLAY_PMARK)
						} else {											;# COMPARE 2 PMARKS
							PmarkCompare .bln.d.d2.ll.list
						}
					}
					8 {														;# CHOOSE BLIST
						lappend blist_nameslist $bln_var
						set msg "More Names ??"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							set finished 1
						}
					}
					10 {													
						set ilist [.bln.d.d2.ll.list curselection]
						if {![info exists ilist] || ([llength $ilist] <= 0)} {
							Inf "No Soundfile Selected"
							continue
						}
						if {$pr_bln == 3} {
							BListDirToWorkspace $ilist						;# DIRECTORY OF SPECIFIC B-LIST FILE TO WORKSPACE
						} else {
							BListFilesToWorkspace $ilist $bln_var 0			;# SPECIFIC B-LIST FILE TO WORKSPACE
						}
					}
					11 {													;# CUT AND PASTE AMONG LISTS
						set ilist [.bln.d.d2.ll.list curselection]
						if {$pr_bln == 4} {
							set i "end"
						} elseif {![info exists ilist] || ([llength $ilist] <= 0)} {
							Inf "No Files Selected" 
							continue
						}
						switch -- $pr_bln {
							1 {												;# GET FILE FROM B-LIST
								catch {unset grabbed_bln} 
								set ilist [ReverseList $ilist]
								foreach i $ilist {
									lappend grabbed_bln [.bln.d.d2.ll.list get $i]
								}
							}
							3 {												;# GET & REMOVE FILE FROM B-LIST
								catch {unset grabbed_bln} 
								set ilist [ReverseList $ilist]
								foreach i $ilist {
									set this_grab [.bln.d.d2.ll.list get $i]
									.bln.d.d2.ll.list delete $i
									set k [lsearch -exact $b_l($bln_var) $this_grab]
									if {$k >= 0} {
										set b_l($bln_var) [lreplace $b_l($bln_var) $k $k]
										set listing_altered 1
									}
									lappend grabbed_bln $this_grab
								}
							}
							4 {												;# PUT FILE INTO B-LIST
								if {[info exists ilist] & ([llength $ilist] > 0)} {
									if {[llength $ilist] > 1} {
										Inf "Select A Single Insertion Position"
										continue
									}
									set i [lindex $ilist 0]
								} else {
									if [info exists b_l($bln_var)] {
										set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
											-message "Insert At End Of List '$bln_var' ??"]
										if {$choice == "no"} {
											Inf "Please Select An Insertion Position"
											continue
										}
									}
									set i "end"
								}
								catch {unset these_grabs}
								catch {unset bad_grabs}
								if [info exists b_l($bln_var)] {
									foreach this_grab $grabbed_bln {
										set k [lsearch -exact $b_l($bln_var) $this_grab]
										if {$k >= 0} {
											lappend bad_grabs $this_grab
										} else {
											lappend these_grabs $this_grab
										}
									}
								} else {
									set these_grabs $grabbed_bln
								}
								set msg ""
								if [info exists these_grabs] {
									foreach this_grab $these_grabs {
										.bln.d.d2.ll.list insert $i $this_grab
										if [info exists b_l($bln_var)] {
											set b_l($bln_var) [linsert $b_l($bln_var) $i $this_grab]
										} else {
											lappend b_l($bln_var) $this_grab
										}
										set listing_altered 1
									}
									if [info exists bad_grabs] {
										set msg "These Files Were Already In The Listing\n\n"
										set j 0
										foreach this_grab $bad_grabs {
											append msg "$this_grab   "
											incr j
											if {$j > 15} {
												append msg "\n\nAnd More"
												break
											}
										}
									}
								} else {
									append msg "All These Files Were Already In The B-List"
								}
								if {[string length $msg] > 0} {
									Inf "$msg"
								}
							}
							5 {												;# SEE OTHER B-LISTS CONTAINING FILE
								if {[llength $ilist] > 1} {
									Inf "Select A Single File"
									continue
								}
								set fnam [.bln.d.d2.ll.list get [lindex $ilist 0]]
								ShowOtherBlists $fnam
							}
							6 {												;# SEE PITCHMARK OF FILE
								if {[llength $ilist] > 1} {
									Inf "Select A Single File"
									continue
								}
								Do_Pitchmark .bln.d.d2.ll.list $evv(DISPLAY_PMARK)
							}
							7 {												;# GRAB FILES TO WORKSPACE
								BListFilesToWorkspace $ilist $bln_var 0
							}
							8 {												;# FIND FILE IN LOGS
								if {[llength $ilist] > 1} {
									Inf "Select A Single File"
									continue
								}
								set fnam [.bln.d.d2.ll.list get [lindex $ilist 0]]
								set fnam [string tolower [file tail $fnam]]
								SearchLogs $fnam 0
							}
							9 {												;# DIRECTORY OF CHOSEN B-LIST FILE TO WORKSPACE
								BListDirToWorkspace $ilist
							}
							10 {											;# B-LIST TO TEXTFILE
								foreach fnam [.bln.d.d2.ll.list get 0 end] {
									lappend ftotext $fnam
								}
								if {![info exists ftotext]} {
									Inf "No Files Listed"
								} else {
									BlistToTextfile $ftotext
									unset ftotext
								}
							}
						}
					}
					12 {
						set ilist [.bln.d.d2.ll.list curselection]
						if {![info exists ilist] || ([llength $ilist] <= 0)} {
							Inf "No Files Selected"
							continue
						}
						if {$pr_bln == 3} {
							if {[llength $ilist] > 1} {
								Inf "Select A Single File"
								continue
							}
							ShowOtherBlists [.bln.d.d2.ll.list get [lindex $ilist 0]]
							continue
						}
						catch {unset score_files}
						catch {unset bad_files}
						foreach i $ilist {
							set fnam [.bln.d.d2.ll.list get $i]

							set ftyp [FindFileType $fnam]
							if {$ftyp == $evv(SNDFILE)} {
								lappend score_files $fnam
							} else {
								lappend bad_files $fnam
							}
						}
						if [info exists bad_files] {
							if {![info exists score_files]} {
								Inf "None Of These Files Is A Soundfile"
							} else {
								set msg "Some Of These Files Are Not Soundfiles: Just Ignore These ??"
								set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
								if {$choice == "no"} {
									unset score_files
								}
							}
						}
						if [info exists score_files] {
							set last_score_bl $bln_var
							set finished 1
						}
					}
					14 {												;# SPECIFIC B-LIST FILE TO CHOSEN FILES	
						set ilist [.bln.d.d2.ll.list curselection]
						if {![info exists ilist] || ([llength $ilist] <= 0)} {
							Inf "No Soundfiles Selected"
							continue
						}
						BListFilesToWorkspace $ilist $bln_var 1			
					}
					15 {												;# SUBTRACT SKETCH SCORE FILES FROM B-LIST
						if {$pr_bln == 1} {
							if {![info exists b_l($bln_var)]} {
								Inf "B-List '$bln_var' Does Not Exist"
								continue
							}
							set lenbefore [llength $b_l($bln_var)]
							set remain_list [ScoreSubtract $filelist]
							set lenafter [llength $remain_list]
							if {$lenafter <= 0} {
								Inf "No Files Are Left"
							} elseif {$lenbefore == $lenafter} {
								Inf "No Files Have Been Removed"
								catch {unset remain_list}
							} else {
								.bln.d.d2.ll.list delete 0 end
								foreach fnam $remain_list {
									.bln.d.d2.ll.list insert end $fnam
								}
								set bl_subtract_done $bln_var
							}
							continue
						}
						if {![info exists remain_list]} {
							Inf "Files Have Not Been Subtracted Yet"
							continue
						} elseif {[llength $remain_list] <= 0} {
							Inf "No Files Are Left"
							continue
						} elseif [string match $bln_var $bl_subtract_done] {
							set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
								-message "Overwrite The Original B-List '$bln_var' ??"]
							if {$choice == "no"} {
								continue
							} else {
								catch {unset b_l($bln_var)}
								.bln.d.d2.ll.list delete 0 end
							}
						} elseif [info exists b_l($bln_var)] {
							set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
								-message "Add Files To Existing B-List '$bln_var' ??"]
							if {$choice == "no"} {
								continue
							}
						} else {
							.bln.d.d2.ll.list delete 0 end
						}
						foreach fnam $remain_list {
							lappend b_l($bln_var) $fnam
							.bln.d.d2.ll.list insert end $fnam
						}
						Inf "Remaining Files Listed In B-List '$bln_var'"
						set listing_altered 1
					}
					16 {
						catch {unset goodfiles}
						set OK 1
						foreach fnam $filelist {
							set k [lsearch -exact $b_l($bln_var) $fnam]
							if {$k < 0} {
								lappend goodfiles $fnam
							} else {
								set OK 0
							}
						}
						if {![info exists goodfiles]} {
							Inf "All These Files Were Already In The B-List"
							continue
						} elseif {!$OK} {
							Inf "Some Of These Files Were Already In The B-List"
						}
						set i [.bln.d.d2.ll.list curselection]
						if {$i >= 0} {
							set goodfiles [ReverseList $goodfiles]
							foreach fnam $goodfiles {
								set b_l($bln_var) [linsert $b_l($bln_var) $i $fnam]
								.bln.d.d2.ll.list insert $i $fnam
							}
						} else {
							foreach fnam $goodfiles {
								lappend b_l($bln_var) $fnam
								.bln.d.d2.ll.list insert end $fnam
							}
						}
						set listing_altered 1
					}
					17 {
						if {$pr_bln == 4} {
							set i [.bln.d.d2.ll.list curselection]
							if {![info exists i] || ($i < 0)} {
								Inf "No Sound Selected"
								continue
							}
							set fnam [.bln.d.d2.ll.list get $i]
							catch {unset bls_w_f}
							foreach namm [.bln.d.d.ll.list get 0 end] {
								set k [lsearch $b_l($namm) $fnam]
								if {$k >= 0} {
									lappend bls_w_f $namm
								}
							}
							if {[info exists bls_w_f]} {
								set msg "Sound '$fnam' Is In B-Lists\n"
								foreach namm $bls_w_f {
									append msg "$namm   "
								}
								Inf $msg
							}
							continue
						}
						set jlist [$f.d.d.ll.list curselection]
						if {[llength $jlist] < 2} {
							Inf "Select 2 Or More B-Lists, To Do The Comparison"
							continue
						}
						$f.d.d2.ll.list delete 0 end
						set file_comparator {}
						set bad_comp {}
						foreach j $jlist {
							foreach fnam $b_l([$f.d.d.ll.list get $j]) {
								set k [lsearch -exact $file_comparator $fnam]
								if {$k < 0} {
									lappend file_comparator $fnam
								} else {
									lappend bad_comp $fnam
								}
							}
						}
						if {[llength $bad_comp] > 0} {
							foreach fnam $bad_comp {
								$f.d.d2.ll.list insert end $fnam
							}
						} else {
							Inf "The B-Lists Are Mutually Exclusive"
						}
					}
				}
			}
		}
	}
	if {[info exists blist_nameslist]} {
		set bln_var $blist_nameslist
	}
	if {$listing_altered} {
		if {[info exists b_l]} {
			SaveBL $background_listing
		} else {
			catch {file delete $background_listing}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#----- List named Blist, on right of Blist display

proc GetBlnName {y keep} {
	global b_l last_bl_name2
	set i [.bln.d.d.ll.list nearest $y]
	set nnam [.bln.d.d.ll.list get $i]
	if {[info exists b_l]} {
		.bln.d.d2.ll.list delete 0 end
		foreach index [array names b_l] {
			if {[string match $index $nnam]} {
				foreach item $b_l($nnam) {
					.bln.d.d2.ll.list insert end $item
				}
				if {$keep} {
					set last_bl_name2 $nnam
				}
				break
			}
		}
	}
	return $nnam
}

#------ Load Background Listing to Workspace

proc LoadBLToWkspace {bl_name replace toch} {
	global b_l chpos chlist ch chcnt wl do_parse_report pa wstk evv
	global pprg mmod again last_chlist last_ch lalast_ch last_b_l last_bl_name last_bl_name2
	global wksp_cnt total_wksp_cnt rememd pim last_mix previous_b_l parse_the_max

	if {$replace} {
		catch {unset pa}
		if {[info exists evv(THUMDIR)]} {
			RestoreThumbnailProps
		}
		$wl delete 0 end
		catch {unset rememd}
		set wksp_cnt 0
		set total_wksp_cnt 0
	}
	set force_it 0
	set asked_forceit 0
	if {[info exists last_b_l]} {
		set previous_b_l $last_b_l
		unset last_b_l
	}
	set loadcnt 0
	if {$toch} {
		ClearAndSaveChoice
		set chlist {}
	}
	foreach fnam $b_l($bl_name) {
		if {!$replace && ([LstIndx $fnam $wl] >= 0)} {
			if {$toch} {
				lappend chlist $fnam
				$ch insert end $fnam
				incr chcnt
				lappend last_b_l $fnam
				incr loadcnt
				set chpos -1
			}
			continue
		}
		if [file exists $fnam] {		;#	Attempt to load files listed in existing wkspace file
			set fnam [string tolower $fnam]
			if [IgnoreSoundloomxxxFilenames $fnam] {
				continue
			}
			set test [FileToWkspace $fnam 0 0 0 0 0]
			if {$test == $evv(PARSE_FAILED)} {
				if {[file isfile $fnam] && ([LstIndx $fnam $wl] < 0)} {
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
						-message "Spurious file $fnam listed in workspace : Delete it ?"]
					if {$choice == "yes"} {
						if [catch {file delete $fnam} xx] {
							Inf "$xx\nCannot remove file $fnam : Ignoring it"
							lappend asked_re_delete $fnam
						} else {
							DummyHistory $fnam "DESTROYED"
						}
					} else {
						lappend asked_re_delete $fnam
					}
				}
			} elseif {$test < 0} {
				ErrShow "Parsing error with file $fnam : Ignoring it"
				continue
			} else {
				if {$pa($fnam,$evv(FTYP)) == $evv(SNDFILE)}  {
					if {![info exists pa($fnam,$evv(MAXREP))] && $parse_the_max} {	;#	Otherwise it's already known
						GetMaxsampOnInput $fnam
					}
				}
				lappend last_b_l $fnam
				if {$toch} {
					lappend chlist $fnam
					$ch insert end $fnam
					incr chcnt
					set chpos -1
				}
			}
		} elseif {!$force_it} {
			set choice [tk_messageBox -type yesno -default yes \
			-message "File $fnam no longer exists : Do you wish to continue with restoring this workspace ?" \
			-icon question -parent [lindex $wstk end]]
			if {$choice == "no"} {
				return
			} elseif {!$asked_forceit} {
				set choice [tk_messageBox -type yesno -default yes \
				-message "Restore this workspace, whatever may be missing?" \
				-icon question -parent [lindex $wstk end]]
				if {$choice == "yes"} {
					set force_it 1
				}
				set asked_forceit 1
			}
		}
		incr loadcnt
	}
	if {$replace} {
		foreach fnam [glob -nocomplain *] {
			set fnam [string tolower $fnam]
			if [file isdirectory $fnam] {
				continue
			} elseif [IgnoreSoundloomxxxFilenames $fnam] {
				continue
			} elseif {[info exists asked_re_delete] && ([lsearch -exact $asked_re_delete $fnam] >= 0)} {
				continue
			}
			if {[LstIndx $fnam $wl] < 0} {
				if {[string match $evv(MACH_OUTFNAME)* $fnam] \
				||  [string match $evv(DFLT_OUTNAME)* $fnam] \
				||  [string match $evv(DFLT_TMPFNAME)* $fnam]} {
					if [catch {file delete $fnam} xx] {
						Inf "$xx\nCannot remove temporary file $fnam : Ignoring it"
					}
					continue
				}
				set do_parse_report 1
				if {[DoParse $fnam $wl 2 0] <= 0} {
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
						-message "Spurious file $fnam in workspace directory : Delete it ?"]
					if {$choice == "yes"} {
						if [catch {file delete $fnam} xx] {
							Inf "$xx\nCannot remove file $fnam : Ignoring it"
						} else {
							DataManage delete $fnam
							lappend couettelist $fnam
							DummyHistory $fnam "DESTROYED"
						}
					}
				} else {
					$wl insert end $fnam				;#	Simply unbakdup : to top of listing
					WkspCntSimple 1
				}
			}
		}
		if {[info exists couettelist]} {
			CouettePatchesDelete $couettelist
		}
	}
	if {$loadcnt == 0} {
		if {[info exists previous_b_l]} {
			set last_b_l $previous_b_l
		}
		Inf "No New Files have been loaded onto workspace"
	} else {
		set last_bl_name $bl_name
		set last_bl_name2 $bl_name
	}
	set pprg 0				 					;#	Otherwise, reset GUI memory
	set mmod 0
	set again(0) -1
	set again(1) -1
	catch {$pim.last.2 config -text "NONE"}
	if {!$toch} {
		catch {unset chlist}
		catch {unset last_chlist}
		catch {unset last_ch}
		catch {unset lalast_ch}
		catch {unset last_mix}
		$ch delete 0 end
		set chcnt 0
	} elseif {[info exists chlist] && ([llength $chlist] <= 0)} {
		unset chlist
	}
	return
}

#------- Add (further) items to a background Listing

proc GetMoreBL {bl_name ilist listing blfile_preexisted b_listing dupl} {
	global b_l pa evv wl rememd dl hidden_dir

	set is_hidden_dir 0
	if {[string match $listing $dl] && ([string length $hidden_dir] > 0)} {
		set is_hidden_dir 1
	}
	set pre_len 0
	if [info exists b_l($bl_name)] {				
		set pre_len [llength $b_l($bl_name)]
	}
	foreach i $ilist {
		set newfile	[$listing get $i]
		if {$is_hidden_dir} {
			set newfile [file join $hidden_dir $newfile]
		}
		if {![file isdirectory $newfile]} {
			lappend b_l($bl_name) $newfile
		}
	}
	if [info exists b_l($bl_name)] {
		set bl_end [llength $b_l($bl_name)]
		if {$bl_end >= 2} {
			set bl_preend $bl_end
			incr bl_preend -1
			set k 0
			while {$k < $bl_preend} {
				set newfile [lindex $b_l($bl_name) $k]
				set q $k
				incr q
				set OK 1
				while {$q < $bl_end} {
					set newfile2 [lindex $b_l($bl_name) $q]
					if {[string match $newfile $newfile2]} {
						set OK 0
						break
					}
					incr q
				}
				if {$OK} {
					lappend new_b_l $newfile
				} elseif {$dupl} {
					;# FIND A NEW NAME FOR DUPLICATE FILE
					set zf [file rootname $newfile]
					set zext [file extension $newfile]
					set zz 0
					set zfnam $zf
					append zfnam "_cop"
					append zfnam $zz
					append zfnam $zext
					while {[file exists $zfnam]} {
						incr zz
						set zfnam $zf
						append zfnam "_cop"
						append zfnam $zz
						append zfnam $zext
					}
					set haspmark [HasPmark $newfile]
					set hasmmark [HasMmark $newfile]
					if [catch {file copy $newfile $zfnam} in] {
						Inf "Cannot Copy '$newfile': Abandoning Adding Files To B-List"
						set b_l($bl_name) [lrange $b_l($bl_name) 0 $pre_len]
							;# SAFE TO RETURN AS ORIGINAL STATE OF BLISTS NOT ALTERED
						return
					} else {
						set propno 0
						while {$propno < ($evv(CDP_PROPS_CNT) + $evv(CDP_MAXSAMP_CNT))} {
							if {[info exists pa($newfile,$propno)]} {
								set pa($zfnam,$propno) $pa($newfile,$propno)
							}
							incr propno
						}
						DummyHistory $zfnam "CREATED"
						if {$haspmark} {
							CopyPmark $newfile $zfnam
						}
						if {$hasmmark} {
							CopyMmark $newfile $zfnam
						}
					}
					$wl insert 0 $zfnam
					WkspCnt $zfnam 1
					catch {unset rememd}
					set b_l($bl_name) [lreplace $b_l($bl_name) $q $q $zfnam]
				}
				incr k
			}
			if {!$dupl} {
				lappend new_b_l [lindex $b_l($bl_name) end]
				set b_l($bl_name) $new_b_l
			}
		}
		if {[llength $b_l($bl_name)] == $pre_len} {
			Inf "No Files Were Added To The Background List (Probably already on the Listing)"
			if {$blfile_preexisted} {
				SaveBL $b_listing
			} else {
				catch {file delete $b_listing}
			}
		} else {
			SaveBL $b_listing
		}
	}
}

#----- Load the background-listings from file

proc LoadBL {b_listing} {
	global b_l wstk

	if {![file exists $b_listing]} {
		return
	}
	if [catch {open $b_listing r} zfileId] {
		Inf "Cannot open file $b_listing to read existing Background Listings"
		return
	}
	set newbl 0
	set skipit 0
	set blist_altered 0
	while {[gets $zfileId line] >= 0} {
		set line [string trim $line]
		if {[string length $line] >= 0} {
			if {$newbl} {
				set blname $line
				set newbl 0
			} elseif {$line  == "###"} {
				set newbl 1
				set skipit 0
			} elseif {![info exists blname]} {
				Inf "WARNING: Anomaly in data from file $b_listing for Background Listings"
				break
			} elseif {$skipit} {
				continue
			} elseif {[file exists $line]} {
				lappend b_l($blname) $line
			} else {
				set msg "File '$line' in B-List '$blname' No Longer Exists\n\nAbandon The B-List ??"
				set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
				if {$choice == "yes"} {
					catch {unset b_l($blname)}
					set blist_altered 1
					set skipit 1
				}
			}
		}
	}
	catch {close $zfileId}
	if {$blist_altered} {
		SaveBL $b_listing
	}
}

#------- Save Background Listings to file

proc SaveBL {b_listing} {
	global b_l evv

	if [catch {open $evv(DFLT_TMPFNAME) w} zfileId] {
		Inf "Cannot open file $evv(DFLT_TMPFNAME) to temporarily store new Background Listing"
		return
	}
	foreach blname [array names b_l] {
		puts $zfileId "###"
		puts $zfileId $blname
		foreach item $b_l($blname) {
			puts $zfileId $item
		}
	}
	catch {close $zfileId}
	if {[file exists $b_listing]} {
		if [catch {file rename -force $evv(DFLT_TMPFNAME) $b_listing} zit] {
			Inf "Cannot rename temporary file $evv(DFLT_TMPFNAME) as background listing file $b_listing\n\nYou should rename this file OUTSIDE the Sound Loom (don't Quit), NOW, overwriting any existing B-List file,\nor you will lose your Background File information"
		}
	} else {
		if [catch {file rename $evv(DFLT_TMPFNAME) $b_listing} zit] {
			Inf "Cannot rename temporary file $evv(DFLT_TMPFNAME) as background listing file $b_listing\n\nYou should rename this file OUTSIDE the Sound Loom (don't Quit), NOW, overwriting any existing B-List file,\nor you will lose your Background File information"
		}
	}
}

#---- Does the file occur in any background listings ?

proc ShowBlistsOfFile {ll} {
	global b_l sl_real evv

	if {!$sl_real} {
		Inf "Show The Names Of Any B-Lists\nWhich Contain The Selected File"
		return
	}
	if {![info exists b_l]} {
		return
	}
	set ilist [$ll curselection] 
	if {![info exists ilist] || ([llength $ilist] <= 0)} {
		Inf "No File Selected"
		return
	}
	if {[llength $ilist] > 1} {
		Inf "Select just one file"
		return
	}
	set fnam [$ll get [lindex $ilist 0]]
	foreach bn [array names b_l] {
		set j [lsearch $b_l($bn) $fnam]
		if {$j >= 0} {
			lappend blists $bn
		}
	}
	if {[info exists blists]} {
		ShowBlists $fnam $blists
	} else {
		Inf "File '$fnam' Is Not On Any Background Listings"
	}
}

#---- Display background listings in which file occurs

proc ShowBlists {fnam blists} {
	global pr_shbl evv

	set f .shbl
	if [Dlg_Create $f "BACKGROUND LISTINGS" "set pr_shbl 0" -width 60 -borderwidth $evv(SBDR)] {
		button $f.b -text "OK" -command {set pr_shbl 0} -highlightbackground [option get . background {}]
		Scrolled_Listbox $f.ll -width 60 -height 20 -selectmode single
		pack $f.b -side top -pady 3
		pack $f.ll -side top -fill both -expand true
		wm resizable $f 1 1
		bind $f <Return> {set pr_shbl 0}
		bind $f <Escape>  {set pr_shbl 0}
		bind $f <Key-space>  {set pr_shbl 0}
	}
	$f.ll.list delete 0 end
	wm title $f "B-LISTS WITH $fnam"
	foreach bl $blists {
		$f.ll.list insert end $bl
	}
	raise $f
	update idletasks
	StandardPosition $f
	set pr_shbl 0
	My_Grab 0 $f pr_shbl $f.ll.list
	tkwait variable pr_shbl
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- Does the file occur in any background listings ?

proc IsInBlists {fnam} {
	global b_l in_b_l

	if {![info exists b_l]} {
		return 0
	}
	if {[string match $fnam [file tail $fnam]]} {
		return 0
	}
	catch {unset in_b_l}
	foreach bn [array names b_l] {
		set j [lsearch $b_l($bn) $fnam]
		if {$j >= 0} {
			lappend in_b_l $bn
		}
	}
	if {[info exists in_b_l]} {
		return 1
	}
	return 0
}

#---- Rename a file in BLists

proc RenameInBlists {fnam nufnam} {
	global in_b_l b_l background_listing
	set changed 0
	foreach bn $in_b_l {
		set j [lsearch $b_l($bn) $fnam]
		if {$j >= 0} {
			set b_l($bn) [lreplace $b_l($bn) $j $j $nufnam]
			set changed 1
		}
	}
	return $changed
}

#---- When a file is destroyed, remove it from Blists

proc RemoveFromBLists {fnam} {
	global b_l in_b_l background_listing

	set changed 0
	foreach bn $in_b_l {
		set j [lsearch $b_l($bn) $fnam]
		if {$j >= 0} {
			set b_l($bn) [lreplace $b_l($bn) $j $j]
			if {[llength $b_l($bn)] <= 0} {
				unset b_l($bn)
			}
			set changed 1
		}
	}
	return $changed
}

#--- Get Files in Background Listing to Workspace

proc LoadToWorkspaceBL {add toch} {
	global b_l b_l_name
	if {![info exists b_l]} {
		Inf "There Are No Background Listings"
		return
	}
	Block "LOADING BACKGROUND LISTING TO WORKSPACE"
	set b_l_name ""
	GetBLName 3
	if {[string length $b_l_name] > 0} {
		if {$add} {
			LoadBLToWkspace $b_l_name 0 $toch
		} else {
			LoadBLToWkspace $b_l_name 1 $toch
		}
	} else {
		catch {unset b_l_name}
	}
	UnBlock
}

#---- Delete EVERY Blist

proc DeleteAllBL {} {
	global b_l b_l_name same_b_l last_b_l last_bl_name last_bl_name2 background_listing wstk

	set msg "Are You Sure You Want To Delete\n\n                 ******** ALL ********\n\nYour Background Listings ??"
	set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
	if {$choice == "no"} {
		return
	}
	catch {file delete $background_listing}
	catch {unset b_l}
	catch {unset b_l_name}
	catch {unset same_b_l}
	catch {unset last_b_l}	
	catch {unset last_bl_name}
	catch {unset last_bl_name2}
}

#--- message re Home Dir files and Blists

proc BigMessage {} {
	set msg "FILES IN THE HOME DIRECTORY\n"
	append msg "CANNOT BE USED IN BACKGROUND LISTINGS.\n"
	append msg "---------------------------------------\n"
	append msg "Current Home Directory files\n"
	append msg "will appear on the Workspace whether\n"
	append msg "or not a Background List is loaded.\n\n"
	append msg "Home directory files NOT currently\n"
	append msg "shown on the Workspace, NO LONGER EXIST.\n\n"
	append msg "So there is no reason to store a\n"
	append msg "Home Directory file in a Background Listing.\n\n"
	return $msg
}

#------- Save Last Background Listings info to file

proc SaveLastBL {} {
	global last_b_l last_bl_name last_bl_name2 evv

	if [catch {open $evv(DFLT_TMPFNAME) w} zfileId] {
		Inf "Cannot open file $evv(DFLT_TMPFNAME) to temporarily store Last Background Listing info"
		return
	}
	if {[info exists last_bl_name]} {
		puts $zfileId $last_bl_name
	} else {
		puts $zfileId "###"
	}
	if {[info exists last_bl_name2]} {
		puts $zfileId $last_bl_name2
	} else {
		puts $zfileId "###"
	}
	if {[info exists last_b_l]} {
		foreach item $last_b_l {
			puts $zfileId $item
		}
	} else {
		puts $zfileId "###"
	}
	catch {close $zfileId}

	set fnam [file join $evv(URES_DIR) $evv(BLIST_BACK)$evv(CDP_EXT)]
	if {[file exists $fnam]} {
		if [catch {file rename -force $evv(DFLT_TMPFNAME) $fnam} zit] {
			Inf "Cannot rename temporary file $evv(DFLT_TMPFNAME) as Last-background-listing-used Info file $fnam\n\nYou should rename this file OUTSIDE the Sound Loom (don't Quit), NOW, overwriting any existing Last-background-listing-used file,\nor you will lose your Last-background-listing-used information"
		}
	} else {
		if [catch {file rename $evv(DFLT_TMPFNAME) $fnam} zit] {
			Inf "Cannot rename temporary file $evv(DFLT_TMPFNAME) as Last-background-listing-used Info file $fnam\n\nYou should rename this file OUTSIDE the Sound Loom (don't Quit), NOW, overwriting any existing Last-background-listing-used file,\nor you will lose your Last-background-listing-used information"
		}
	}
}

#------- Load Last Background Listings info from file

proc LoadLastBL {} {
	global last_b_l last_bl_name last_bl_name2 evv

	set fnam [file join $evv(URES_DIR) $evv(BLIST_BACK)$evv(CDP_EXT)]
	if {![file exists $fnam]} {
		return
	}
	if [catch {open $fnam r} zfileId] {
		Inf "Cannot open file $fnam to load Last Background Listing info"
		return
	}
	set i 0
	while {[gets $zfileId line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		switch -- $i {
			0 {
				if {![string match "#" [string index $line 0]]} {
					set last_bl_name $line
				}
			}
			1 {
				if {![string match "#" [string index $line 0]]} {
					set last_bl_name2 $line
				}
			}
			2 {
				if {![string match "#" [string index $line 0]]} {
					while {[gets $zfileId line] >= 0} {
						set line [string trim $line]
						if {[string length $line] <= 0} {
							continue
						}
						lappend last_b_l $line
					}
				}
				break
			}
		}
		incr i
	}
	catch {close $zfileId}
}

#--- Find a file in Background Listings

proc FileFind_inBLists {getstr} {
	global wl pr_filfnd2 filstr2 evv sl_real

	if {!$sl_real} {
		Inf "Search All B-Lists\nFor Mentions Of The Selected File,\nAnd Name The Relevant B-Lists."
		return
	}
	if {$getstr} {
		set f .file_find2
		if [Dlg_Create $f "STRING TO MATCH" "set pr_filfnd2 0" -width 80 -borderwidth $evv(SBDR)] {
			set b0 [frame $f.b0 -borderwidth $evv(SBDR)]
			set b1 [frame $f.b1 -borderwidth $evv(SBDR)]
			button $b0.ff -text "FIND\nFILE" -command {set pr_filfnd2 1} -bg $evv(EMPH) -highlightbackground [option get . background {}]
			button $b0.qu -text "Close" -command {set pr_filfnd2 0} -highlightbackground [option get . background {}]
			pack $b0.ff -side left
			pack $b0.qu -side right
			label $b1.l -text "STRING TO MATCH"
			entry $b1.e -textvariable filstr2 -width 24
			pack $b1.l $b1.e -side left -pady 2
			pack $b0 $b1 -side top -fill x -expand true
			wm resizable $f 1 1
			bind $f <Return> {set pr_filfnd2 1}
			bind $f <Escape> {set pr_filfnd2 0}
		}
		raise $f
		set pr_filfnd2 0
		set finished 0
		My_Grab 0 $f pr_filfnd2 $f.b1.e
		while {!$finished} {
			tkwait variable pr_filfnd2
			if {$pr_filfnd2} {
				if {[string length $filstr2] <= 0} {
					Inf "No Search String Entered"
					continue
				}
				if {[regexp {[^A-Za-z0-9\-\_]+} $filstr2]} {
					Inf "Invalid Characters In Search String '$filstr2'\n\nYou cannot use directory paths or file extensions here."
					continue
				}
				FileFindinBLists $filstr2 0
			} else {
				set finished 1
			}
		}
		My_Release_to_Dialog $f
		Dlg_Dismiss $f
	} else {
		set ilist [$wl curselection]
		if {![info exists ilist] || ([llength $ilist] <= 0)} {
			Inf "No Item Selected"
			return
		}
		if {([llength $ilist] > 1)} {
			Inf "Select Just One File"
			return
		}
		set fnam [$wl get [lindex $ilist 0]]
		FileFindinBLists $fnam 1
	}
}

#------- Find File in Background Listings

proc FileFindinBLists {str wholename} {
	global b_l got_bls

	if {![info exists b_l]} {
		Inf "There Are No Background Lists"
		return
	}
	catch {unset got_bls}
	if {$wholename} {
		foreach bl [array names b_l] {
			foreach fnam $b_l($bl) {
				if {[string match $fnam $str]} {
					lappend got_bls $bl
					break
				}
			}
		}
	} else {
		foreach bl [array names b_l] {
			foreach fnam $b_l($bl) {
				set fnam [file rootname [file tail $fnam]]
				if [regexp $str $fnam] {
					lappend got_bls $bl
					break
				}
			}
		}
	}
	if {![info exists got_bls]} {
		Inf "No Match Found"
		return
	}
	GetBLName 9
}

#----- Get selected B-list files to workspace

proc BListFilesToWorkspace {ilist this_blist toch} {
	global wl pa rememd last_b_l last_bl_name last_bl_name2 ch chlist chpos chcnt evv

	set msg ""
	foreach i $ilist {
		set fnam [.bln.d.d2.ll.list get $i]
		lappend tochlist $fnam
		if {[LstIndx $fnam $wl] >= 0} {
			lappend gotlist $fnam
		} else {
			lappend grablist $fnam
		}
	}
	if {![info exists grablist] && !$toch} {
		Inf "All These Files Are Already On The Workspace"
		return
	} 
	if [info exists grablist] {
		set grablist [ReverseList $grablist]
		foreach fnam $grablist {
			if {![file exists $fnam]} {
				lappend badfiles(0) $fnam
				continue
			} elseif {![info exists pa($fnam,$evv(FTYP))]} {
				if {[DoParse $fnam $wl 0 0] <= 0} {
					lappend badfiles(1) $fnam
					continue
				}
			}
			if {$evv(DFLT_SR) > 0} {
				set filetype $pa($fnam,$evv(FTYP))
				if {($filetype & $evv(IS_A_SNDSYSTEM_FILE)) && ($filetype != $evv(ENVFILE))} {
					if {$filetype == $evv(SNDFILE)} {
						if {$pa($fnam,$evv(SRATE)) != $evv(DFLT_SR)} {
  							PurgeArray $fnam
							lappend badfiles(2) $fnam
							continue
						}
					} elseif {$pa($fnam,$evv(ORIGRATE)) != $evv(DFLT_SR)} {
						PurgeArray $fnam
						lappend badfiles(2) $fnam
						continue
					}
				} elseif {$filetype == $evv(PSEUDO_SND)} {
					if {$pa($fnam,$evv(SRATE)) != $evv(DFLT_SR)} {
						PurgeArray $fnam
						lappend badfiles(2) $fnam
						continue
					}
				}			
			}
			$wl insert 0 $fnam
			WkspCnt $fnam 1
			catch {unset rememd}
			lappend done $fnam
		}
	}
	if {$toch} {
		catch {unset done}
		set n 0
		while {$n < 3} {
			if [info exists badfiles($n)] {
				foreach fnam $badfiles($n) {
					set k [lsearch -exact $tochlist $fnam]
					if {$k >= 0} {
						set tochlist [lreplace $tochlist $k $k]
					}
				}
			}
			incr n
		}
		if {[llength $tochlist] > 0} {
			if [info exists chlist] {
				set OK 0
				foreach fnam $tochlist {
					set k [lsearch $chlist $fnam]
					if {$k < 0} {
						set OK 1
						break
					}
				}
				if {!$OK && ([llength $chlist] == [llength $tochlist])} {
					Inf "These Files Already Make Up The Chosen Files List"
					return
				}
			}
			ClearAndSaveChoice
			set chpos -1
			foreach fnam $tochlist {
				lappend chlist $fnam
				$ch insert end $fnam
				incr chcnt
				lappend done $fnam
			}
		}
	}
	if [info exists done] {
		if {$toch} {
			Inf "Files Have Been Placed On The Chosen Files List"
		} else {
			Inf "Files Have Been Placed On The Workspace"
		}
		set last_b_l $done
		set last_bl_name $this_blist
		set last_bl_name2 $this_blist
	} else {
		if {$toch} {
			append msg "No Files Have Been Placed On The Chosen Files List\n\n"
		} else {
			append msg "No Files Have Been Placed On The Workspace\n\n"
		}
	}
	if [info exists badfiles(0)] {
		append msg "The Following Files No Longer Exist\n\n"
		foreach fnam $badfiles(0) {
			append msg "$fnam  "
		}
		append msg "\n\n"
	}
	if [info exists badfiles(1)] {
		append msg "The Following Files Are Not CDP Compatible\n\n"
		foreach fnam $badfiles(1) {
			append msg "$fnam  "
		}
		append msg "\n\n"
	}
	if [info exists badfiles(2)] {
		append msg "The Following Files Are At The Wrong Sampling Rate\n\n"
		foreach fnam $badfiles(2) {
			append msg "$fnam  "
		}
		append msg "\n\n"
	}
	if {!$toch && [info exists gotlist]} {
		append msg "The Following Files Are Already On The Workspace\n\n"
		foreach fnam $gotlist {
			append msg "$fnam  "
		}
	}
	if {[string length $msg] > 0} {
		Inf $msg
	}
}

#----- Get directory of selected B-list files to workspace

proc BListDirToWorkspace {ilist} {
	global wl wksp_dirname pr_5 evv

	set msg ""
	foreach i $ilist {
		set fnam [.bln.d.d2.ll.list get $i]
		if {![info exists thisdir]} {
			set thisdir [file dirname $fnam]
		} elseif {![string match $thisdir [file dirname $fnam]]} {
			Inf "Files From More Than One Directory Have Been Selected"
			return
		}
	}
	if {[string length $thisdir] <= 1} {
		set wksp_dirname ""
	} else {
		set wksp_dirname $thisdir
	}
	if {[info exists pr_5]} {
		LoadDir
		Inf "Directory '$thisdir' Has Been Listed On The Workspace"
	} else {
		Inf "You Must Go The Workspace And List A Directory\n            Before This Option Will Become Active"
	}
}

#---- Save a background listing to a textfile

proc BlistToTextfile {flist} {
	global pr_bltotex bltotex wstk wl total_wksp_cnt evv

	set f .bl_totex
	if [Dlg_Create $f "B-LIST TO TEXTFILE" "set pr_bltotex 0" -width 60 -borderwidth $evv(SBDR)] {
		frame $f.1 -borderwidth 2
		frame $f.2 -borderwidth 2
		button $f.1.ok -text "OK" -command {set pr_bltotex 1} -highlightbackground [option get . background {}]
		button $f.1.di -text "Choose\nDirectory" -command {DoListingOfDirectories .bl_totex.2.e} -highlightbackground [option get . background {}]
		button $f.1.qu -text "Close" -command {set pr_bltotex 0} -highlightbackground [option get . background {}]
		pack $f.1.ok $f.1.di -side left -padx 4
		pack $f.1.qu -side right -padx 1
		label $f.2.l -text "Textfile Name   "
		entry $f.2.e -textvariable bltotex -width 64
		pack $f.2.l $f.2.e -side left -padx 1
		pack $f.1 $f.2 -side top -pady 2 -fill x -expand true
		wm resizable $f 1 1
		bind $f <Return> {set pr_bltotex 1}
		bind $f <Escape> {set pr_bltotex 0}
	}
	raise $f
	set pr_bltotex 0
	set finished 0
	My_Grab 0 $f pr_bltotex $f.2.e
	while {!$finished} {
		tkwait variable pr_bltotex
		if {$pr_bltotex} {
			set bltotex [string tolower [StripHomeDir $bltotex]]
			if {[string length $bltotex] <= 0} {
				Inf "No Filename Entered"
				continue
			}
			if {![ValidCdpFilename [file rootname $bltotex] 1]} {
				continue
			}
			set bltotex [file rootname $bltotex]
			append bltotex [GetTextfileExtension sndlist]
			if [file isdirectory $bltotex] {
				Inf "This Is A Directory Name"
				continue
			}
			if [file exists $bltotex] {
				set choice [tk_messageBox -type yesno -default yes \
				-message "File '$bltotex' Exists : Overwrite It?" -icon question -parent [lindex $wstk end]]
				if {$choice == "no"} {
					continue
				} else {
					if {![DeleteFileFromSystem $bltotex 1 1]} {
						continue
					}
					set i [LstIndx $bltotex $wl]
					if {$i >= 0} {
						RemoveAllRefsToFile $bltotex $i
					}
				}
			}
			if [catch {open $bltotex "w"} zit] {
				Inf "Cannot Open File '$bltotex'"
				continue
			}
			foreach fnam $flist {
				puts $zit $fnam
			}
			close $zit
			FileToWkspace $bltotex 0 0 0 0 1
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#------ Search Blistings

proc SearchBlists {typ} {
	global bl_srchstr b_l bln_var

	if {$typ != 3 && $typ != 4} {
		if {![info exists bl_srchstr] || ([string length $bl_srchstr] <= 0)} {
			Inf "No Search String Given"
			return
		}
	}
	set bl_srchstr [string tolower $bl_srchstr]
	switch -- $typ {
		0 {							;# FIND FILES IN FILE LISTING
			set i 0
			foreach fnam [.bln.d.d2.ll.list get 0 end] {
				set fnam [file rootname [file tail $fnam]]
				if [regexp $bl_srchstr $fnam] {
					lappend ilist $i
				}
				incr i
			}
			if {$i == 0} {
				Inf "No Files Listed"
				return
			}
			if {![info exists ilist]} {
				Inf "No Matches Found"
				return
			}
			set len $i
			.bln.d.d2.ll.list selection clear 0 end
			foreach i $ilist {
				.bln.d.d2.ll.list selection set $i
			}
			.bln.d.d2.ll.list yview moveto [expr double($i)/double($len)]
		}
		1 {							;# FIND FILES IN BLIST LISTING
			set i 0
			foreach nnam [.bln.d.d.ll.list get 0 end] {
				foreach fnam $b_l($nnam) {
					set fnam [file rootname [file tail $fnam]]
					if [regexp $bl_srchstr $fnam] {
						lappend ilist $i
						if [string match $bln_var $nnam] {
							set jj $i
						}
						break
					}
				}
				incr i
			}
			if {$i == 0} {
				Inf "No B-Lists Listed"		;# Safety only
				return
			}
			if {![info exists ilist]} {
				Inf "No Matches Found"
				return
			}
			set len $i
			.bln.d.d.ll.list selection clear 0 end
			foreach i $ilist {
				.bln.d.d.ll.list selection set $i
				if {![info exists ii]} {
					if {[info exists jj] && ($i != $jj)} {
						set ii $i
					} else {
						set ii $i
					}
				}
			}
			if [info exists ii] {
				.bln.d.d.ll.list yview moveto [expr double($ii)/double($len)]
			}
		}
		2 {							;# FIND DIRECTORY IN BLIST LISTINGS
			set i 0
			foreach nnam [.bln.d.d.ll.list get 0 end] {
				foreach fnam $b_l($nnam) {
					set fnam [file dirname $fnam]
					if [regexp $bl_srchstr $fnam] {
						lappend ilist $i
						if [string match $bln_var $nnam] {
							set jj $i
						}
						break
					}
				}
				incr i
			}
			if {$i == 0} {
				Inf "No B-Lists Listed"		;# Safety only
				return
			}
			if {![info exists ilist]} {
				Inf "No Matches Found"
				return
			}
			set len $i
			.bln.d.d.ll.list selection clear 0 end
			foreach i $ilist {
				.bln.d.d.ll.list selection set $i
				if {![info exists ii]} {
					if {[info exists jj]  && ($i != $jj)} {
						set ii $i
					} else {
						set ii $i
					}
				}
			}
			if [info exists ii] {
				.bln.d.d.ll.list yview moveto [expr double($ii)/double($len)]
			}
		}
		3 {
			set ilist [.bln.d.d2.ll.list curselection]
			if {![info exists ilist] || ([llength $ilist] <= 0)} {
				Inf "No File Selected"
				return
			}
			foreach i $ilist {
				set fnam [.bln.d.d2.ll.list get $i]
				if {![info exists thisdir]} {
					set thisdir [file dirname $fnam]
				} elseif {![string match $thisdir [file dirname $fnam]]} {
					Inf "Files From More Than One Directory Have Been Selected"
					return
				}
			}
			set bl_srchstr $thisdir
		}
		4 {
			set ilist [.bln.d.d2.ll.list curselection]
			if {![info exists ilist] || ([llength $ilist] <= 0)} {
				Inf "No File Selected"
				return
			}
			if {[llength $ilist] > 1} {
				Inf "Select A Single File"
				return
			}
			set fnam [.bln.d.d2.ll.list get [lindex $ilist 0]]
			set thisdir [file rootname [file tail $fnam]]
			set bl_srchstr $thisdir
		}
	}
}

proc ShowOtherBlists {fnam} {
	global b_l bln_var

	catch {unset jlist}
	set j 0
	foreach blz [.bln.d.d.ll.list get 0 end] {
		if {[lsearch -exact $b_l($blz) $fnam] >= 0} {
			if [string match $bln_var $blz] {
				set jj $j
			}
			lappend jlist $j
		}
		incr j
	}
	set len $j
	catch {unset ii}
	if {[info exists jlist] && ([llength $jlist] > 1)} {
		.bln.d.d.ll.list selection clear 0 end
		foreach j $jlist {
			.bln.d.d.ll.list selection set $j
			if {![info exists ii] && ($j != $jj)} {
				set ii $j
			}
		}
		if [info exists ii] {
			.bln.d.d.ll.list yview moveto [expr double($ii)/double($len)]
		}
	} else {
		Inf "'$fnam' Is Not In Any Other B-List"
	}
}

#--- Subtract list of files from a B-list

proc ScoreSubtract {filelist} {
	global bln_var b_l

	foreach fnam $b_l($bln_var) {
		lappend blfnams $fnam
	}
	foreach fnam $filelist {
		set k [lsearch -exact $blfnams $fnam]
		if {$k >= 0} {
			set blfnams [lreplace $blfnams $k $k]
		}
	}
	return $blfnams
}

proc CreateEmptyBlist {} {
	global pr_getnublname bln_var nublname b_l evv

	set f .getnublname

	if [Dlg_Create $f "NEW B-LIST NAME" "set pr_getnublname 0" -width 60 -borderwidth $evv(SBDR)] {
		frame $f.1 -borderwidth 2
		frame $f.2 -borderwidth 2
		button $f.1.ok -text "OK" -command {set pr_getnublname 1} -highlightbackground [option get . background {}]
		button $f.1.qu -text "Close" -command {set pr_getnublname 0} -highlightbackground [option get . background {}]
		pack $f.1.ok -side left -padx 1
		pack $f.1.qu -side right -padx 1
		label $f.2.l -text "Name for New B-List  "
		entry $f.2.e -textvariable nublname -width 64
		pack $f.2.l $f.2.e -side left -padx 1
		pack $f.1 $f.2 -side top -pady 2 -fill x -expand true
		wm resizable $f 1 1
		bind $f <Return> {set pr_getnublname 1}
		bind $f <Escape> {set pr_getnublname 0}
	}
	raise $f
	set pr_getnublname 0
	set finished 0
	My_Grab 0 $f pr_getnublname $f.2.e
	while {!$finished} {
		tkwait variable pr_getnublname
		if {!$pr_getnublname} {
			break
		}
		if {[string length $nublname] <= 0} {
			Inf "No Name Entered"
			continue
		}
		if [regexp {[^A-Za-z0-9_\-]} $nublname] {
			Inf "Invalid Characters In Name (Use letters, numbers, dash or underscore only)"
			continue
		}
		set nublname [string tolower $nublname]		
		if [info exists b_l] {
			set OK 1
			foreach nnam [array names b_l] {
				if [string match $nnam $nublname] {
					Inf "A B-List Called '$nublname' Already Exists"
					set OK 0
					break
				}
			}
			if {!$OK} {
				continue
			}
		}
		.bln.e.e config -state normal
		set bln_var $nublname
		.bln.e.e config -state disabled
		.bln.d.d2.ll.list delete 0 end
		break
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- Destroy a B-list

proc DestroyBlist {} {
	global b_l bln_var same_b_l last_bl_name last_bl_name2

	if {[string length $bln_var] <= 0} {
		Inf "No Background Listing Name Given"
		return 0
	}
	if {[AreYouSure]} {
		if [catch {unset b_l($bln_var)} zit] {
			Inf "Background Listing '$bln_var' No Longer Exists"
			return 0
		}
		.bln.d.d2.ll.list delete 0 end
		set j [LstIndx $bln_var .bln.d.d.ll.list]
		.bln.d.d.ll.list delete $j
		if {[info exists same_b_l] && [string match $bln_var $same_b_l]} {
			catch {unset same_b_l}
		}
		if {[info exists last_bl_name] && [string match $last_bl_name $bln_var]} {
			unset last_bl_name
		}
		if {[info exists last_bl_name2] && [string match $last_bl_name2 $bln_var]} {
			unset last_bl_name2
		}
		set bln_var ""
		return 1
	}
	return 0
}

#---- Grab Bkgd List file to wkspace

proc GrabFromBkgd {ll} {
	global wl
	set ilist [$ll curselection]
	if {![info exists ilist] || ([llength $ilist] <= 0) || ([lindex $ilist 0] == -1)} {
		return
	}
	foreach i $ilist {
		set fnam [$ll get $i]
		if {[LstIndx $fnam $wl] >= 0} {
			lappend already $fnam
		} else {
			FileToWkspace $fnam 0 0 0 0 0
			set done 1
		}
	}
	if [info exists already] {
		if {[llength $ilist] == [llength $already]} {
			if {[llength $ilist] == 1} {
				Inf "File Already On The Workspace"
			} else {
				Inf "These Files Are Already On The Workspace"
			}
		} else {
			Inf "[llength $already] Of These Files Already On The Workspace"
		}
	}
	if [info exists done] {
		Inf "File(s) Placed On Workspace"
	}
}

##################
# SOUND LISTINGS #
##################

proc SoundlistsCompare {} {
	global pr_slistcomp slist_comp slist_list slist_cnt wl ch chlist chcnt slist_fnam pa evv
	catch {unset slist_list}
	set ilist [$wl curselection]
	if {[llength $ilist] < 2} {
		if {[info exists chlist]} {
			if {[llength $chlist] < 2} {
				Inf "Select 2 Or More Textfiles Which List Sounds"
				return
			}
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
	set n 0
	foreach i $ilist {
		set fnam($n) [$wl get $i]
		if {![IsASndlist $pa($fnam($n),$evv(FTYP))]} {
			Inf "Select 2 Or More Textfiles Which List Sounds"
			return
		}
		incr n
	}
	set slist_cnt $n
	set n 0
	while {$n < $slist_cnt} {
		if [catch {open $fnam($n) "r"} zit] {
			Inf "CANNOT OPEN FILE $fnam(n)"
			return
		}
		while {[gets $zit line] >= 0} {
			set sfnam [string trim $line]
			if {[string length $sfnam] <= 0} {
				continue
			}
			if {![file exists $sfnam]} {
				Inf "File '$sfnam' Listed In File '$fnam($n)' Does Not Exist"
				close $zit
				return
			}
			lappend slist($n) $sfnam
		}
		close $zit
		incr n
	}
	set slist_list(all) {}
	set n 0
	while {$n < $slist_cnt} {
		foreach sfnam $slist($n) {
			if {[lsearch $slist_list(all) $sfnam] < 0} {
				lappend slist_list(all) $sfnam
			}
		}
		incr n
	}
	set slist_list(one) $slist_list(all)
	set slist_cnt_less_one [expr $slist_cnt - 1]
	set finished 0
	while {$n < $slist_cnt_less_one} {
		foreach fnam_n $slist($n) {
			set k [lsearch $slist_list(one) $fnam_n]
			if {$k < 0} {
				continue
			}
			set m $n
			incr m
			while {$m < $slist_cnt} {
				foreach fnam_m $slist($m) {
					if {[lsearch $slist_list(one) $fnam_m] < 0} {
						continue
					}
					if {[string match $fnam_n $fnam_m]} {
						set slist_list(one) [lreplace $slist_list(one) $k $k]
						if {[llength $slist_list(one)] <= 0} {
							set finished 1
							break
						}
					}
				}
				if {$finished} {
					break
				}
				incr m
			}
			if {$finished} {
				break
			}
		}
		if {$finished} {
			break
		}
		incr n
	}
	set slist_list(common) $slist_list(all)
	set comlen [llength $slist_list(common)]
	set cc 0
	while {$cc < $comlen} {
		set sfnam [lindex $slist_list(common) $cc]
		set n 0 
		while {$n < $slist_cnt} {
			if {[lsearch $slist($n) $sfnam] < 0} {
				set slist_list(common) [lreplace $slist_list(common) $cc $cc]
				incr cc -1
				incr comlen -1
				break
			}
			incr n
		}
		incr cc
	}

	set f .slistcomp
	if [Dlg_Create  $f "COMPARE SOUND LISTINGS" "set pr_slistcomp 0" -borderwidth $evv(SBDR)] {
		set f1 [frame $f.1 -bd $evv(SBDR)]
		set f2 [frame $f.2 -bd $evv(SBDR)]
		set f3 [frame $f.3 -bd $evv(SBDR)]
		button $f1.qu -text "Quit" -command {set pr_slistcomp 0} -highlightbackground [option get . background {}]
		button $f1.ok -text "Listed Files to Chosen" -command {set pr_slistcomp 1} -width 24 -highlightbackground [option get . background {}]
		button $f1.nu -text "Listed Files to New List" -command {set pr_slistcomp 2} -width 24 -highlightbackground [option get . background {}]
		label $f1.ll -text "Outname "
		entry $f1.ee -textvariable slist_fnam -width 24
		pack $f1.ok $f1.nu $f1.ll $f1.ee -side left
		pack $f1.qu -side right
		pack $f1 -side top -fill x -expand true
		radiobutton $f2.1 -variable slist_comp -value 1 -text "Sounds common to all lists" -command "SlistSort"
		radiobutton $f2.2 -variable slist_comp -value 2 -text "Sounds in one list Only"	-command "SlistSort"
		radiobutton $f2.3 -variable slist_comp -value 3 -text "Sounds from all lists"	-command "SlistSort"
		pack $f2.1 $f2.2 $f2.3 -side left
		pack $f2 -side top
		Scrolled_Listbox $f3.ll -width 80 -height 20 -selectmode single
		pack $f3.ll -side top
		pack $f3 -side top -fill x -expand true
		wm resizable .slistcomp 1 1
		bind $f <Escape> {set pr_slistcomp 0}
	}
	set slist_fnam ""
	.slistcomp.3.ll.list delete 0 end
	set slist_comp 0
	raise $f
	set pr_slistcomp 0
	set finished 0
	My_Grab 0 $f pr_slistcomp
	while {!$finished} {
		tkwait variable pr_slistcomp
		catch {unset outlist}
		foreach sfnam [.slistcomp.3.ll.list get 0 end] {
			lappend outlist $sfnam
		}
		switch -- $pr_slistcomp {
			1 {
				if {![info exists outlist]} {
					Inf "No Sounds Listed"
					continue
				}
				catch {unset out_outlist}
				set badfiles 0
				Block "Putting Sounds on Chosen List"
				foreach sfnam $outlist {
					if {[LstIndx $sfnam $wl] < 0} {
						if {[FileToWkspace $sfnam 0 0 0 0 1] > 0} {
							lappend out_outlist $sfnam
						} else {
							incr badfiles
						}
					} else {
						lappend out_outlist $sfnam
					}
				}
				if {![info exists out_outlist]} {
					Inf "Could Not Grab Any Of These Files To The Workspace"	
					UnBlock
					continue
				} elseif {$badfiles} {
					Inf "Failed To Grab $badfiles Of These Files To The Workspace"	
				}
				DoChoiceBak
				ClearWkspaceSelectedFiles
				set chlist $out_outlist
				foreach sfnam $chlist {
					$ch insert end $sfnam
					incr chcnt
				}
				UnBlock
			}
			2 {
				if {![info exists outlist]} {
					Inf "No Sounds Listed"
					continue
				}
				if {[string length $slist_fnam] <= 0} {
					Inf "No Output Filename Entered"
					continue
				}
				if {![ValidCDPRootname $slist_fnam]} {
					continue
				}
				set outname $slist_fnam
				append outname [GetTextfileExtension sndlist]
				if {[file exists $outname]} {
					Inf "File '$outname' Already Exists: Please Choose A Different Name"
					continue
				}
				if [catch {open $outname "w"} zit] {
					Inf "Cannot Open File '$outname' To Write Data"
					continue
				}
				foreach sfnam $outlist {
					puts $zit $sfnam
				}
				close $zit
				if {[FileToWkspace $outname 0 0 0 0 1] > 0} {
					Inf "File '$outname' Is On The Workspace"
				}					
			}
			0 {
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc SlistSort {} {
	global slist_comp slist_list
	switch -- $slist_comp {
		0 {
			return
		}
		1 {
			.slistcomp.3.ll.list delete 0 end
			foreach sfnam $slist_list(common) {
				.slistcomp.3.ll.list insert end $sfnam
			}
		}
		2 {
			.slistcomp.3.ll.list delete 0 end
			foreach sfnam $slist_list(one) {
				.slistcomp.3.ll.list insert end $sfnam
			}
		}
		3 {
			.slistcomp.3.ll.list delete 0 end
			foreach sfnam $slist_list(all) {
				.slistcomp.3.ll.list insert end $sfnam
			}
		}
	}
	return
}

proc SoundlistSort {} {
	global chlist pa wstk wl evv
	set ilist [$wl curselection]
	if {![info exists ilist] || ([llength $ilist] !=1) || ($ilist == -1)} {
		if {![info exists chlist] || ([llength $chlist] != 1)} {
			Inf "Select	A Single Textfile Which Lists Sounds"
			return
		}
		set k [LstIndx [lindex $chlist 0] $wl]
		if {$k < 0} {
			Inf "Select	A Single Textfile Which Lists Sounds"
			return
		}
		$wl selection clear 0 end
		$wl selection set $k
	}
	set i [$wl curselection]
	set fnam [$wl get $i]
	if {![IsASndlist $pa($fnam,$evv(FTYP))]} {
		Inf "Select A Textfile Which Lists Sounds"
		return
	}
	set tempfnam $evv(DFLT_OUTNAME)$evv(TEXT_EXT)
	if [catch {file copy $fnam $tempfnam} zit] {
		set msg "Cannot Make A Backup Copy Of Your Original File"
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File 'fnam' To Read Data"
		DeleteAllTemporaryFiles
		return
	}
	while {[gets $zit line] >= 0} {
		set sfnam [string trim $line]
		if {[string length $sfnam] <= 0} {
			continue
		}
		if {![file exists $sfnam]} {
			Inf "File '$sfnam' Listed In File '$fnam' Does Not Exist"
			close $zit
			DeleteAllTemporaryFiles
			return
		}
		lappend sfnams $sfnam
	}
	close $zit
	set sfnams [lsort -dictionary $sfnams]
	if [catch {file delete $fnam} zit] {
		Inf "Cannot Delete Original File"
		DeleteAllTemporaryFiles
		return
	}
	if [catch {open $fnam "w"} zit] {
		Inf "Cannot Open File '$fnam' To Write Sorted Data"
		if [catch {file rename $tempfnam $fnam} zit] {
			Inf "Cannot Rename Temporary File '$tempfnam' (With Original Data) To '$fnam'\n\nBefore Closing This Dialogue, Change Its Name ~Outside~ The Loom!!"
			UpdateBakupLog $fnam delete 1
		}
		DeleteAllTemporaryFiles
		return
	}

	foreach sfnam $sfnams {
		puts $zit $sfnam
	}
	close $zit
	UpdateBakupLog $fnam modify 1 
	DeleteAllTemporaryFiles
}

#----- Mix cyclically from soundlists

proc SoundlistsMix {} {
	global chlist pa wstk wl evv pr_orcmix lastorcmixmin mix_perm orcmixlistrandorder orcmixrandorder
	global orcmixchans orcmixstep orcmixchorder orcmixrandchorder orcmixlevscat orcmixmin orcmixfnam orcmixselection

	set ilist [$wl curselection]
	if {![info exists ilist] || ([llength $ilist] < 2)} {
		catch {unset ilist}
		if {![info exists chlist] || ([llength $chlist] < 2)} {
			Inf "Select	Two Or More Textfiles Which List Sounds"
			return
		}
		foreach fnam $chlist {
			set i [LstIndx $fnam $wl]
			lappend ilist $i
		}
		$wl selection clear 0 end
		foreach i $ilist {
			$wl selection set $i
		}
	}
	set ilist [$wl curselection]
	foreach i $ilist {
		set fnam [$wl get $i]
		if {![IsASndlist $pa($fnam,$evv(FTYP))]} {
			Inf "File '$fnam' Is Not A List Of Sounds"
			return
		}
		lappend orcs $fnam
	}
	catch {unset orcfnams}
	set cnt 0
	set consulted 0 
	set allfilescnt 0
	Block "Checking Files"
	foreach fnam $orcs {
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot Open File '$fnam' To Get Listed Sounds"
			UnBlock
			return
		}
		while {[gets $zit line] >= 0} {
			set sfnam [string trim $line]
			if {[string length $sfnam] <= 0} {
				continue
			}
			if {![file exists $sfnam]} {
				lappend badfiles $sfnam
				if {!$consulted} {
					set consulted 1
					set msg "File '$sfnam' Listed In File '$fnam' Does Not Exist: Continue Without Such Files ??"
					set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
					if {$choice == "no"} {
						close $zit
						UnBlock
						return
					}
				}
				continue
			}
			if {![info exists pa($sfnam,$evv(CHANS))]} {
				Inf "File '$sfnam' Is Not On The Workspace: Cannot Proceed"
				close $zit
				UnBlock
				return
			}	
			if {$pa($sfnam,$evv(CHANS)) != 1} {
				Inf "File '$sfnam' Is Not Mono: Cannot Proceed"
				close $zit
				UnBlock
				return
			}	
			lappend orcfnams($cnt) $sfnam
		}
		close $zit
		if {[info exists orcfnams($cnt)]} {
			lappend orclens [llength $orcfnams($cnt)]
			if {[info exists allfiles]} {
				foreach fnam $orcfnams($cnt) {
					if {[lsearch $allfiles $fnam] < 0} {
						lappend allfiles $fnam
						incr allfilescnt
					}
				}
			} else {
				set allfiles $orcfnams($cnt)
				set len [llength $orcfnams($cnt)]
				set len_less_one [expr $len - 1]
				set n 0
				while {$n < $len_less_one} {
					set fnam_n [lindex $orcfnams($cnt) $n]
					set m $n
					incr m
					while {$m < $len} {
						set fnam_m [lindex $orcfnams($cnt) $m]
						if {[string match $fnam_n $fnam_m]} {
							set allfiles [lreplace $allfiles $m $m]
							incr len -1
							incr len_less_one -1
						} else {
							incr m
						}
					}
					incr n
				}
				set allfilescnt [llength $allfiles]
			}
			incr cnt
		} else {
			set msg "No Valid Soundfiles Found In File '$fnam' : Continue Without It ??"
			set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
			if {$choice == "no"} {
				return
			}
		}
	}
	if {[info exists badfiles]} {
		set ccnt 0 
		set msg "The Following Files Do Not Exist"
		foreach fnam $badfiles {
			append msg "\n$fnam"
			incr ccnt
			if {$ccnt >= 20} {
				append msg "\nAND MORE"
				break
			}
		}
		Inf $msg
	}
	UnBlock
	set orccnt $cnt
	if {$orccnt == 0} {
		Inf "No Valid Soundfiles Found"
		return
	}
	set orcmaxlimit 0
	if {$allfiles > $evv(MAXFILES)} {
		set msg "Too Many Files, In Total, For A Mixfile: Limit To Maximum ($evv(MAXFILES)) ??"
		set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
		if {$choice == "yes"} {
			set orcmaxlimit 1
		}
	}
	set maxlen 0
	foreach len $orclens {
		if {$len > $maxlen} {
			set maxlen $len
		}
	}
	set minorclen $maxlen
	foreach len $orclens {
		if {$len < $minorclen} {
			set minorclen $len
		}
	}
	if {$minorclen != $maxlen} {
		set msg "Not All Soundlists Are Of The Same Length: Files At End Of Longer Lists Will Be Ignored: OK ??"
		set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
		if {$choice == "no"} {
			return
		}
	}
	catch {unset lastorcmixmin}
	set f .orcmix
	if [Dlg_Create  $f "MIX FROM SOUND LISTINGS" "set pr_orcmix 0" -borderwidth $evv(SBDR)] {
		set f0  [frame $f.0  -bd $evv(SBDR)]
		set f1  [frame $f.1  -bd $evv(SBDR)]
		set f2  [frame $f.2  -bd $evv(SBDR)]
		set f3a [frame $f.3a -bd $evv(SBDR)]
		set f3  [frame $f.3  -bd $evv(SBDR)]
		set f4  [frame $f.4  -bd $evv(SBDR)]
		set f5  [frame $f.5  -bd $evv(SBDR)]
		set f6  [frame $f.6  -bd $evv(SBDR)]
		button $f0.qu -text "Quit" -command {set pr_orcmix 0} -highlightbackground [option get . background {}]
		button $f0.ok -text "Do Mix" -command {set pr_orcmix 1} -width 8 -highlightbackground [option get . background {}]
		pack $f0.ok -side left
		pack $f0.qu -side right
		pack $f0 -side top -fill x -expand true
		label $f1.ll -text "Output Channels (4-16) "
		entry $f1.e -textvariable orcmixchans -width 4
		pack $f1.e $f1.ll -side left
		pack $f1 -side top -fill x -expand true
		label $f2.ll -text "Timestep between entries "
		entry $f2.e -textvariable orcmixstep -width 4
		pack $f2.e $f2.ll -side left
		pack $f2 -side top -fill x -expand true
		label $f3a.ll -text "List from which file selected "
		radiobutton $f3a.0 -variable orcmixlistrandorder -value 0 -text "In Order"
		radiobutton $f3a.1 -variable orcmixlistrandorder -value 1 -text "Random"
		pack $f3a.0 $f3a.1 $f3a.ll -side left
		pack $f3a -side top -fill x -expand true
		label $f3.ll -text "File Selected from List "
		radiobutton $f3.0 -variable orcmixrandorder -value 0 -text "In Order"
		radiobutton $f3.1 -variable orcmixrandorder -value 1 -text "Random"
		pack $f3.0 $f3.1 $f3.ll -side left
		pack $f3 -side top -fill x -expand true
		label $f4.ll -text "Output Channel Assignment "
		radiobutton $f4.0 -variable orcmixrandchorder -value 0 -text "In Order"
		radiobutton $f4.1 -variable orcmixrandchorder -value 1 -text "Random"
		pack $f4.0 $f4.1 $f4.ll -side left
		pack $f4 -side top -fill x -expand true
		label $f5.ll -text "Level Distribution "
		radiobutton $f5.1 -variable orcmixlevscat -value 0 -text "Flat" -command OrcMixLevel
		radiobutton $f5.0 -variable orcmixlevscat -value 1 -text "Scattered" -command OrcMixLevel
		label $f5.ell -text "Min level " -width 9
		entry $f5.e -textvariable orcmixmin -width 4 -disabledbackground [option get . background {}]
		pack $f5.1 $f5.0 $f5.ll $f5.e $f5.ell -side left
		pack $f5 -side top -fill x -expand true
		label $f6.ll -text "Output Mix name "
		entry $f6.e -textvariable orcmixfnam -width 20
		pack $f6.e $f6.ll -side left
		pack $f6 -side top -fill x -expand true
		set orcmixchans 8
		set orcmixstep 1
		set orcmixlistrandorder 0
		set orcmixrandorder 0
		set orcmixrandchorder 0
		set	orcmixlevscat 0
		set orcmixmin ""
		wm resizable .orcmix 1 1
		bind $f <Return> {set pr_orcmix 1}
		bind $f <Escape> {set pr_orcmix 0}
	}
	if {![info exists orcmixlevscat]} {
		set orcmixlevscat 0
	}
	OrcMixLevel
	raise $f
	update idletasks
	StandardPosition $f
	set pr_orcmix 0
	set finished 0
	My_Grab 0 $f pr_orcmix $f.6.e
	while {!$finished} {
		tkwait variable pr_orcmix
		if {$pr_orcmix} {
			if {[string length $orcmixchans] <= 0} {
				Inf "No Output Channel Count Entered"
				continue
			}
			if {![IsNumeric $orcmixchans] || ![regexp {^[0-9]+$} $orcmixchans] || ($orcmixchans < 4) || ($orcmixchans > 16)} {
				Inf "Invalid Channel Count Entered"
				continue
			}
			if {[string length $orcmixfnam] <= 0} {
				Inf "No Output Filename Entered"
				continue
			}
			if {![ValidCDPRootname $orcmixfnam]} {
				continue
			}
			set outname [string tolower $orcmixfnam]
			append outname [GetTextfileExtension mmx]
			if {[file exists $outname]} {
				Inf "File '$outname' Already Exists: Please Choose A Different Name"
				continue
			}
			if {[string length $orcmixstep] <= 0} {
				Inf "No Timestep Entered Entered"
				continue
			}
			if {![IsNumeric $orcmixstep] || ($orcmixstep < 0)} {
				Inf "Invalid Timestep Entered"
				continue
			}
			if {$orcmixlevscat} {
				if {![IsNumeric $orcmixmin] || ($orcmixmin < 0) || ($orcmixmin > 1)} {
					Inf "Invalid Minimum Level Entered (Range 0-1)"
					continue
				}
				set orcmixrang [expr 1.0 - $orcmixmin]
			}
			if {$orcmixrandorder} {				;#	If necessary, randomise order of file selection WITHIN lists
				set cnt 0
				while {$cnt < $orccnt} {
					catch {unset nulist}
					set len [llength $orcfnams($cnt)]
					RandomiseOrder $len
					set n 0
					while {$n < $len} {
						lappend nulist [lindex $orcfnams($cnt) $mix_perm($n)]
						incr n
					}
					set orcfnams($cnt) $nulist
					incr cnt
				}
			}
			if {$orcmixlistrandorder} {			;#	If necessary, randomise order of which-list-to-use-next
				RandomiseOrder $orccnt
				set n 0 
				while {$n < $orccnt} {
					set thisorc($n) $orcfnams($mix_perm($n))
					incr n
				}
			} else {			
				while {$n < $orccnt} {
					set thisorc($n) $orcfnams($n)
					incr n
				}
			}
			if {$orcmixrandchorder == 1} {		;#	If necessary, randomise output channel order
				RandomiseOrder $orcmixchans
				set n 0 
				while {$n < $orcmixchans} {
					set thischan($n) [expr $mix_perm($n) + 1]
					incr n
				}
			} else {
				set n 0
				while {$n < $orcmixchans} {
					set thischan($n) [expr $n + 1]
					incr n
				}
			}
			catch {unset mixlines}
			set line $orcmixchans
			lappend mixlines $line
			set done 0
			set alloutfiles {}
			set outfilesused 0
			set chanassigncnt 0
			set time 0.0
			set k 0
			while {$k < $minorclen} {								;#	For every location in a list
				set j 0
				while {$j < $orccnt} {								;#	For every list
					set orc $thisorc($j)							;#	Get the list 
					set fnam [lindex $orc $k]						;#	Get the file at the list location
					set line $fnam
					lappend line $time $pa($fnam,$evv(CHANS))
					set rout "1:"
					append rout $thischan($chanassigncnt)
					lappend line $rout
					if {$orcmixlevscat} {
						set lev	[expr (rand() * $orcmixrang) + $orcmixmin]					
					} else {
						set lev 1.0
					}
					lappend line $lev
					lappend mixlines $line
					incr chanassigncnt
					if {$chanassigncnt >= $orcmixchans} {
						if {$orcmixrandchorder} {
							RandomiseOrder $orcmixchans
							set n 0 
							while {$n < $orcmixchans} {
								set thischan($n) [expr $mix_perm($n) + 1]
								incr n
							}
						}
						set chanassigncnt 0
					}
					if {$orcmaxlimit} {
						if {[lsearch $alloutfiles $fnam] < 0} {
							lappend alloutfiles $fnam
							incr outfilesused
							if {$outfilesused >= $evv(MAXFILES)} {
								set done 1
							}
						}

					}
					if {$done} {
						break
					}
					set time [expr $time + $orcmixstep]
					incr j
				}
				if {$done} {
					break
				}
				if {$orcmixlistrandorder} {			;#	If necessary, randomise order of which-list-to-use-next
					RandomiseOrder $orccnt
					set n 0 
					while {$n < $orccnt} {
						set thisorc($n) $orcfnams($mix_perm($n))
						incr n
					}
				}
				incr k
			}
			if [catch {open $outname "w"} zit] {
				Inf "Cannot Open File '$outname' To Write Data"
				continue
			}			
			foreach line $mixlines {
				puts $zit $line
			}
			close $zit
			FileToWkspace $outname 0 0 0 0 1			
			Inf "File '$outname' Is On The Workspace"
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- Toggle availability of level-range bottom value

proc OrcMixLevel {} {
	global lastorcmixmin orcmixmin orcmixlevscat
	if {$orcmixlevscat} {
		.orcmix.5.ell config -text "Min Level "
		.orcmix.5.e   config -bd 2 -state normal
		if {[info exists lastorcmixmin]} {
			set orcmixmin $lastorcmixmin
		}
	} else {
		set lastorcmixmin $orcmixmin
		.orcmix.5.ell config -text ""
		.orcmix.5.e   config -bd 0 -state disabled
	}
}

#--- Extract sounds from a Property File to a Soundlist

proc PropToOrc {} {
	global chlist pa wstk wl props_info evv
	set ilist [$wl curselection]
	if {![info exists ilist] || ([llength $ilist] !=1) || ($ilist == -1)} {
		if {![info exists chlist] || ([llength $chlist] != 1)} {
			Inf "Select	A Single Properties File"
			return
		}
		set k [LstIndx [lindex $chlist 0] $wl]
		if {$k < 0} {
			Inf "Select	A Single Properties File"
			return
		}
		$wl selection clear 0 end
		$wl selection set $k
	}
	set i [$wl curselection]
	set fnam [$wl get $i]
	Block "Extracting Sounds"
	if {![ThisIsAPropsFile $fnam 1 0]} {
		UnBlock
		return
	}
	set outfnam [file rootname [file tail $fnam]]
	append outfnam [GetTextfileExtension sndlist]
	if {[file exists $outfnam]} {
		Inf "File '$outfnam' Already Exists : Cannot Overwrite It Here"
		UnBlock
		return
	}
	set propfile [lindex $props_info 1]
	foreach line $propfile {
		lappend fnams [lindex $line 0]
	}
	if [catch {open $outfnam "w"} zit] {
		Inf "Cannot Open File '$outfnam' To Write Sound List"
		UnBlock
		return
	}
	foreach fnam $fnams {
		puts $zit $fnam
	}
	close $zit
	UnBlock
	FileToWkspace $outfnam 0 0 0 0 1
	Inf "File '$outfnam' Is On The Workspace"
	return
}

