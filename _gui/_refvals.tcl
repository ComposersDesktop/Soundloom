#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD 30 June 2013
# ... fixup button rectangles

####################
# REFERENCE VALUES #
####################

#------ Create, See, Load, and Store Reference Values

proc RefStore {from} {
	global ref pr_ref pr_ref_ref pdi col_tabname rsto runval sl_real tabed muc wl play_pll wstk evv
	global chcnt chlist mu

	if {!$sl_real} {
		Inf "You Can Save A Value Or Name From Here To The Reference Store\nSo That It Can Be Used Again Later"
		return
	}
	set finished 0
	set pr_ref 0

	switch -- $from {
		"ted" {							;#	Store output table from Table Editor
			set h $tabed.message
			if {[string length $col_tabname] <= 0} {
				ForceVal $h.e "No output table name to store."
			 	$h.e config -bg $evv(EMPH)
				return
			}
		 	$h.ree config -state normal -borderwidth 2
			focus $h.ree
		 	$h.pref config -text "Explanatory Text" -state disabled -bg $evv(EMPH)
		 	$h.pref2 config -text "" -state disabled -bg [option get . background {}] -bd 0
		 	$h.ok config -text "OK" -command {set pr_ref 1} -state normal -borderwidth 2
		 	$h.no config -text "No" -command {set pr_ref 0} -state normal -borderwidth 2
			set rsto "ted"
			while {!$finished} {
				tkwait variable pr_ref
				if {$pr_ref} {
					if {![info exists ref(text2)] || ([string length $ref(text2)] <= 0)} {
						ForceVal $h.e "No reference text entered"
					 	$h.e config -bg $evv(EMPH)
						continue
					}
					lappend ref(name) $ref(text2)
					lappend ref(val) $col_tabname
					incr ref(cnt)
					StoreRefs
					set finished 1
				} else {
					set finished 1
				}
			}
		 	$h.pref  config -text "OutFil->Ref" -state normal \
		 		-bg [option get . background {}] -fg [option get . foreground {}]
		 	$h.pref2  config -text "Msg->Ref" -state normal \
		 		-bg [option get . background {}] -fg [option get . foreground {}] -bd 2
		 	$h.ree config -state disabled -borderwidth 0
		 	$h.ok config -text "" -state disabled -borderwidth 0
		 	$h.no config -text "" -state disabled -borderwidth 0
			set ref(text2) ""
			ForceVal $h.e ""
		 	$h.e config -bg [option get . background {}]
			set rsto ""
		}
		"tedmes" {							;#	Store output message from Table Editor
			set h $tabed.message
			set val [$h.e get]
			if {[string length $val] <= 0} {
				Inf "No Table Editor message to store."
				return
			}
		 	$h.ree config -state normal -borderwidth 2
			focus $h.ree
		 	$h.pref config -text "" -state disabled -bg [option get . background {}] -bd 0
		 	$h.pref2 config -text "Explanatory Text" -state disabled -bg $evv(EMPH)
		 	$h.ok config -text "OK" -command {set pr_ref 1} -state normal -borderwidth 2
		 	$h.no config -text "No" -command {set pr_ref 0} -state normal -borderwidth 2
			set rsto "tedmes"
			while {!$finished} {
				tkwait variable pr_ref
				if {$pr_ref} {
					if {![info exists ref(text2)] || ([string length $ref(text2)] <= 0)} {
						Inf "No reference text entered"
						continue
					}
					lappend ref(name) $ref(text2)
					lappend ref(val) $val
					incr ref(cnt)
					StoreRefs
					set finished 1
				} else {
					set finished 1
				}
			}
		 	$h.pref  config -text "Outfil->Ref" -state normal \
		 		-bg [option get . background {}] -fg [option get . foreground {}] -bd 2
		 	$h.pref2  config -text "Msg->Ref" -state normal \
		 		-bg [option get . background {}] -fg [option get . foreground {}]
		 	$h.ree config -state disabled -borderwidth 0
		 	$h.ok config -text "" -state disabled -borderwidth 0
		 	$h.no config -text "" -state disabled -borderwidth 0
			set ref(text2) ""
			ForceVal $h.e ""
		 	$h.e config -bg [option get . background {}]
			set rsto ""
		}
		"colcurs" {
			set i [$tabed.bot.icframe.l.list curselection]
			if {![info exists i] || ($i < 0)} {
				set i [$tabed.bot.ocframe.l.list curselection]
				if {![info exists i] || ($i < 0)} {
					ForceVal $tabed.message.e  "No value selected."
					$tabed.message.e config -bg $evv(EMPH)
					return
				} else {
					set val [$tabed.bot.ocframe.l.list get $i] 
				}
			} else {
				set val [$tabed.bot.icframe.l.list get $i] 
			}
			set f .ref_ref
			if [Dlg_Create $f "Enter Reference Value Comment text" "set pr_ref_ref 0" -width 48 -borderwidth $evv(SBDR)] {
				set b [frame $f.buttons -borderwidth $evv(SBDR)]
				set l [frame $f.l -borderwidth $evv(SBDR)]
				button $b.q -text Close -command {set pr_ref_ref 0} -width 4 -highlightbackground [option get . background {}]
				button $b.r -text OK -command {set pr_ref_ref 1} -width 4 -highlightbackground [option get . background {}]
				pack $b.q -side right
				pack $b.r -side left
				label $l.l -text "Text"
				entry $l.e -textvariable ref(text3) -width 32
				pack $l.l $l.e -side left -padx 1
				pack $f.buttons $f.l -side top -fill x -expand true
#				wm resizable $f 0 0
				bind $f <Return> {set pr_ref_ref 1}
				bind $f <Escape> {set pr_ref_ref 0}
			}
			raise $f
			set ref(text3) ""
			set pr_ref_ref 0
			set finished 0
			My_Grab 0 $f pr_ref_ref .ref_ref.l.e
			while {!$finished} {
				tkwait variable pr_ref_ref
				if {$pr_ref_ref} {
					if {[string length $ref(text3)] <= 0} {
						continue
					}
					lappend ref(name) $ref(text3)
					lappend ref(val) $val
					incr ref(cnt)
					StoreRefs
					set finished 1
				} else {
					set finished 1
				}
			}
			My_Release_to_Dialog $f
			Dlg_Dismiss $f
		}
		"clc" {				;#	Store input or output values from Music Calculator
			set h $muc.vtop2
		 	$h.refin config -state disabled
		 	$h.refout config -state disabled
			if {$ref(out)} {
				if {[string length $mu(recyc)] <= 0} {
					Inf "Output Is Not Numeric"
					raise .cpd
					return
				}
				set zz $mu(recyc)
			} else {
				if [IsNumeric $pdi] {
					set zz $pdi
				}
			}
			if {![info exists zz] || ([string length $zz] <= 0)} {
				Inf "Cannot store non-numeric values"
			 	$h.refin config -state normal
			 	$h.refout config -state normal
				raise .cpd
				return
			}
	 		$h.ree config -state normal -borderwidth 2
			focus $h.ree
	 		$h.ref config -text "Explanatory text" -borderwidth 2 -disabledforeground [option get . foreground {}] -state disabled  -bg $evv(EMPH)
	 		$h.ok config -text "OK" -command {set pr_ref 1} -state normal -borderwidth 2
	 		$h.no config -text "No" -command {set pr_ref 0} -state normal -borderwidth 2
			set rsto "clc"
			while {!$finished} {
				tkwait variable pr_ref
				if {$pr_ref} {
					if {![info exists ref(text)] || ([string length $ref(text)] <= 0)} {
						Inf "No reference text entered"
						continue
					}
					lappend ref(name) $ref(text)
					lappend ref(val) $zz
					incr ref(cnt)
					StoreRefs
					set finished 1
				} else {
					set finished 1
				}
			}
			if [winfo exists .cpd] {
	 			$h.ref config -text "Keep for ref" -state normal \
	 				-bg [option get . background {}] -fg [option get . foreground {}]
	 			$h.ree config -state disabled -borderwidth 0
	 			$h.ok config -text "" -state disabled -borderwidth 0
	 			$h.no config -text "" -state disabled -borderwidth 0
	 			$h.refin config -state normal
	 			$h.refout config -state normal
			}
			set ref(text) ""
			set rsto ""
		}
		"run" {				;#	Store input or output values from Run display
			set h .running.t
		 	$h.ref config -text "Explanatory text" -disabledforeground [option get . foreground {}] -state disabled  -borderwidth 2 -bg $evv(EMPH)
		 	$h.ree config -state normal -borderwidth 2
			focus $h.ree
		 	$h.okk config -text "OK" -command {set pr_ref 1} -state normal -bd 2 -bg $evv(EMPH)
		 	$h.no config -command {set pr_ref 0}
			set rsto "run"
			while {!$finished} {
				tkwait variable pr_ref
				if {$pr_ref} {
					if {![info exists ref(text)] || ([string length $ref(text)] <= 0)} {
						Inf "No reference text entered"
						continue
					}
					lappend ref(name) $ref(text)
					lappend ref(val) $runval
					incr ref(cnt)
					StoreRefs
					set finished 1
				} else {
					set finished 1
				}
			}
		 	$h.ref config -text "" -bg [option get . background {}] -fg [option get . foreground {}]
		 	$h.ree config -state disabled -borderwidth 0
		 	$h.okk config -text "" -state disabled -borderwidth 0
		 	$h.no config -text "" -state disabled -borderwidth 0
			set ref(text) ""
			set rsto ""
			set pr_ref_ref 0
		}
		"wl" {				;#	Store workspace filename
			set ilist [$wl curselection]
			if {[llength $ilist] <= 0} {
				Inf "No Item Selected"
				return
			}
			set fnam [file rootname [file tail [$wl get [lindex $ilist 0]]]]
			if {[llength $ilist] > 1} {
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
					-message "More Than One Item Selected.    Referencing The Name '$fnam' ?"]
				if {$choice == "no"} {
					return
				}
			} else {
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
					-message "Keeping '$fnam' As A Reference Value ?"]
				if {$choice == "no"} {
					return
				}
			}
			lappend ref(name) "FROM WORKSPACE"
			lappend ref(val) $fnam
			incr ref(cnt)
			StoreRefs
		}
		"ch" {				;#	Store Chosen Files list filename
			if {![info exists chcnt] || ![info exists chlist] || ($chcnt <= 0)} {
				Inf "No Filename On Chosen Files List"
				return
			} elseif {$chcnt > 1} {
				Inf "More Than One File Name On Chosen Files List"
				return
			}
			set fnam [file rootname [file tail [lindex $chlist 0]]]
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
				-message "Keeping '$fnam' As A Reference Value ?"]
			if {$choice == "no"} {
				return
			}
			lappend ref(name) "FROM CHOSEN FILES LIST"
			lappend ref(val) $fnam
			incr ref(cnt)
			StoreRefs
		}
		"pl" {				;#	Store playlist filename
			set i [$play_pll curselection]
			if {![info exists i] || ($i < 0)} {
				Inf "No item selected"
				return
			}
			set fnam [file rootname [file tail [$play_pll get $i]]]
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
				-message "Keeping '$fnam' As A Reference Value ?"]
			if {$choice == "no"} {
				return
			}
			lappend ref(name) "FROM PLAYLIST"
			lappend ref(val) $fnam
			incr ref(cnt)
			StoreRefs
		}
	}
}

proc RefSee {typ} {
	global ref pr_refs mu sl_real refnewname evv

	if {!$sl_real} {
		Inf "Important Data Can Be Stored In The Reference Values List.\nThese Values Can Be Accessed From Many Places And Used\nWhile Working On The Soundloom."
		return
	}
	set f .ref
	if [Dlg_Create $f "Reference Values" "set pr_refs 0" -borderwidth $evv(SBDR)] {
		set b [frame $f.buttons -borderwidth $evv(SBDR)]
		set c [frame $f.change -borderwidth $evv(SBDR)]
		Scrolled_Listbox $f.l -height 28 -width 48 -selectmode single
		button $b.q -text Close -command {set pr_refs 0} -width 7 -highlightbackground [option get . background {}]
		button $b.c -text Create -command {CreateRef} -width 7 -highlightbackground [option get . background {}]
		button $b.r -text Remove -command {DelRef .ref.l.list} -width 7 -highlightbackground [option get . background {}]
		button $b.x -text "Change Text" -command {ChangeRefName .ref.l.list} -width 12 -highlightbackground [option get . background {}]
		button $b.p -text "To Param" -command {} -width 11 -highlightbackground [option get . background {}]
		pack $b.q -side right
		pack $b.c $b.r $b.x $b.p -side left -padx 1
		label $c.ll -text "New Text" -width 8
		entry $c.e -textvariable refnewname -width 48
		button $c.ok -text "Change" -width 7 -bd 0 -command {} -highlightbackground [option get . background {}]
		button $c.q -text "Abandon" -width 7 -bd 0 -command RefNameQuit -highlightbackground [option get . background {}]
		pack $c.ll $c.e $c.ok $c.q -side left
		pack $f.buttons $f.change $f.l -side top -fill x -expand true
		wm resizable $f 0 1
		bind $f <Return> {set pr_refs 0}
		bind $f <Escape> {set pr_refs 0}
	}
	set  refnewname ""
	$f.change.ll config -text "" -width 8
	$f.change.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
	$f.change.ok config -text "" -bd 0 -state disabled
	$f.change.q  config -text "" -bd 0 -state disabled
	.ref.l.list delete 0 end
	$f.buttons.p config -bd 2 -bg [option get . background {}]
	switch -- $typ {
		"6" {
			$f.buttons.p config -borderwidth 2 -text "To Value" -command "ValToParam .qkref 0" -state normal -bg $evv(EMPH)
		}
		"5" {
			$f.buttons.p config -borderwidth 2 -text "" -command {} -state disabled -bd 0
		}
		"4" {
			$f.buttons.p config -borderwidth 2 -text "To Log Search" -command {RefToLogSrch .ref.l.list 1; set pr_refs 0} -state normal
		}
		"3" {
			$f.buttons.p config -borderwidth 2 -text "To Log Search" -command {RefToLogSrch .ref.l.list 0; set pr_refs 0} -state normal
		}
		"2" {
			$f.buttons.p config -borderwidth 2 -text "To Timelist" -command {RefToTimelist .ref.l.list} -state normal
		}
		"1" {
			$f.buttons.p config -borderwidth 2 -text "To Param" -command {ValToParam .ref.l.list pr_refs} -state normal
		}
		"0" {
			$f.buttons.p config -borderwidth 0 -text "" -command {} -state disabled
		}
		default {
			$f.buttons.p config -borderwidth 2 -text "To Cursor" -command "RefToCursor .ref.l.list $typ" -state normal
		}
	}
	set n 0
   	while {$n < $ref(cnt)} {
		set zz [lindex $ref(val) $n]
		set m 0
		while {$m < $mu(SPACS)} {
			append zz " "
			incr m
		}
		append zz [lindex $ref(name) $n]
		.ref.l.list insert end $zz
		incr n
	}
	set pr_refs 0
	raise $f
	My_Grab 0 $f pr_refs .ref.l.list
	tkwait variable pr_refs
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc DelRef {ll} {
	global ref
	set i [$ll curselection]
	if {![info exists i] || ![IsNumeric $i]} {
		Inf "No item selected"
		return
	}
	$ll delete $i
	set ref(name) [lreplace $ref(name) $i $i]
	set ref(val) [lreplace $ref(val) $i $i]
	incr ref(cnt) -1
}

proc ChangeRefName {ll} {
	global ref
	
	set i [$ll curselection]
	if {![info exists i] || ![IsNumeric $i]} {
		Inf "No Item Selected"
		return
	}
	$ll selection set $i
	.ref.change.ll config -text "New Text" -width 8
	.ref.change.e  config -bd 2 -state normal
	.ref.change.ok config -text "Change" -bd 2 -state normal -command "RefNameChange $i $ll"
	.ref.change.q  config -text "Abandon" -bd 2 -state normal
	.ref.buttons.x config -state disabled
	.ref.buttons.c config -state disabled
	.ref.buttons.r config -state disabled
}

proc RefNameChange {i ll} {
	global ref refnewname mu
	if {[string length $refnewname] <= 0} {
		Inf "No New Name Entered"
		return
	}
	set ref(name) [lreplace $ref(name) $i $i $refnewname]
	$ll delete $i
	set zz [lindex $ref(val) $i]
	set m 0
	while {$m < $mu(SPACS)} {
		append zz " "
		incr m
	}
	append zz [lindex $ref(name) $i]
	$ll insert $i $zz
	RefNameQuit
	$ll selection set $i
}

proc RefNameQuit {} {
	global ref refnewname

	set refnewname ""
	.ref.change.ll config -text "" -width 8
	.ref.change.e  config -bd 0 -state disabled -disabledbackground [option get . background {}]
	.ref.change.ok config -text "" -bd 0 -state disabled -command {}
	.ref.change.q  config  -text "" -bd 0 -state disabled
	.ref.buttons.x config -state normal
	.ref.buttons.c config -state normal
	.ref.buttons.r config -state normal
}

proc DelAllRefs {} {
	global ref sl_real evv
	if {!$sl_real} {
		Inf "You Can Remove All Previously Stored Reference Values, If Starting A Completely New Project."
		return
	}
	if [AreYouSure] {
		set ref(name) {}
		set ref(val) {}
		set ref(cnt) 0
		set ref_file [file join $evv(URES_DIR) $evv(REF_FILE)$evv(CDP_EXT)]
		if [file exists $ref_file] {
			if [catch {open $ref_file "w"} zorg] {
				Inf "Cannot delete existing references in reference file '$ref_file'"
				return
			}
			close $zorg
		}
	}
}

proc RefGet {str} {
	global ref pr_rfg mu sl_real evv

	set is_simple 0
	if {[string match pdi $str] || [string match tempo $str]} {
		set is_simple 1
	}
	if {!$sl_real} {
		Inf "You Can Recall Values You Have Saved In The Reference Values List\nAnd Use Them Here In The Calculator"
		return
	}
	if {$ref(cnt) <= 0} {
		Inf "No Reference Values."
		return
	}
	set f .rfg
	if [Dlg_Create $f "Reference Values" "set pr_rfg 0" -borderwidth $evv(SBDR)] {
		set b [frame $f.buttons -borderwidth $evv(SBDR)]
		Scrolled_Listbox $f.l -height 28 -width 48 -selectmode single
		button $b.q -text Close -command {set pr_rfg 0} -width 5 -highlightbackground [option get . background {}]
		pack $b.q -side top
		pack $f.buttons $f.l -side top
		wm resizable $f 0 1
		bind $f <Return> {set pr_rfg 0}
		bind $f <Escape> {set pr_rfg 0}
		bind $f <Key-space> {set pr_rfg 0}
	}
	bind $f.l.list <ButtonRelease-1> {}
	bind $f.l.list <ButtonRelease-1> "GetRef %W %y $str"
	.rfg.l.list delete 0 end
	set n 0
   	while {$n < $ref(cnt)} {
		set zz [lindex $ref(val) $n]
		set m 0
		while {$m < $mu(SPACS)} {
			append zz " "
			incr m
		}
		append zz [lindex $ref(name) $n]
		.rfg.l.list insert end $zz
		incr n
	}
	set pr_rfg 0
	raise $f
	if {$is_simple} {
		Simple_Grab 0 $f pr_rfg .rfg.l.list
	} else {
		My_Grab 0 $f pr_rfg .rfg.l.list
	}
	tkwait variable pr_rfg
	if {$is_simple} {
		Simple_Release_to_Dialog $f
	} else {
		My_Release_to_Dialog $f
	}
	Dlg_Dismiss $f
}

proc GetRef {ll y str} {
	global ref pdi last_pdi tempo colpar pdf pr_rfg col_x mu batch_replace

	set i [$ll nearest $y]
	set zz [$ll get $i]
	set zz [split $zz]
	set zz [lindex $zz 0]
	if {[string length $zz] <= 0} {
		return
	}
	switch -- $str {
		"tempo" {set tempo $zz}
		"pdi"	{
			if {![IsNumeric $zz]} {	   ;#	Calculator doesn't yet work for non-numeric ref vals
				return
			}
			if {[info exists pdi] && ([string length $pdi] > 0)} {
				set last_pdi $pdi
			}
			set pdn $zz
			ClearPad 1
			set pdf $mu(NPAD)
			SetupAsNumeric $pdn
			set pdi $pdn
		}
		pview {
			SetPviewMark $zz
		}
		batch {
			set batch_replace $zz
		}
		default {				   		
			if {[string match col_x* $str] && ![IsNumeric $zz]} {
				return					;#	xN type parameters on TableEditor don't work for non-numeric vals
			}
			set $str $zz
		}
	}
	set pr_rfg 1
}


proc StoreRefs {} {
	global ref evv

	if {$ref(cnt) <= 0} {	
		return
	}
	if [catch {open $evv(DFLT_REFS) w} refId] {
		Inf "Cannot open temporary file to backup reference data"
		return
	} else {
		set n 0
		while {$n < $ref(cnt)} {
			puts $refId [lindex $ref(val) $n]
			puts $refId [lindex $ref(name) $n]
			incr n
		}
		close $refId
	}
	set ref_file [file join $evv(URES_DIR) $evv(REF_FILE)$evv(CDP_EXT)]
	if [file exists $ref_file] {
		if [catch {file delete $ref_file} zorg] {
			Inf "Cannot delete existing reference files, to write current references"
			return
		}
	}
	if [catch {file rename $evv(DFLT_REFS) $ref_file}] {
		ErrShow "Failed to save reference data"
	}
}

proc LoadRefs {} {
	global ref evv

	set ref_file [file join $evv(URES_DIR) $evv(REF_FILE)$evv(CDP_EXT)]
	if {![file exists $ref_file]} {
		return
	}
	if [catch {open $ref_file r} refId] {
		Inf "Cannot open reference data file to read reference values"
		return
	} else {
		set ref(cnt) 0
		set ref(name) {}
		set ref(val) {}
		while {[gets $refId zz] >= 0} {
			if {$ref(cnt) & 1} {
				lappend ref(name) $zz
			} else {
				lappend ref(val) $zz
			}
			incr ref(cnt)
		}
		close $refId
	}
	if {$ref(cnt) & 1} {
		Inf "Reference data incorrectly paired. Adding a dummy entry ('Unknown')"
		lappend ref(name) "Unknown"
		incr ref(cnt)
	}
	set ref(cnt) [expr round($ref(cnt) / 2)]
}

#------ Put a Reference val at cursor position

proc RefToCursor {src dest} {
	global ref pr_refs

	set i [$src curselection]
	if {![info exists i] || ![IsNumeric $i] || ($i < 0)} {
		Inf "No item selected"
		return
	}
	$dest insert insert [lindex [lindex $ref(val) $i] 0]
	set pr_refs 1
}

#------ Create Reference Value directly

proc CreateRef {} {
	global pr_cref refval reftxt ref mu evv
	set f .cref
	if [Dlg_Create $f "Reference Val" "set pr_cref 0"  -borderwidth $evv(SBDR)] {
		set fb [frame $f.buttons -borderwidth $evv(SBDR)]
		set fv [frame $f.val  -borderwidth $evv(SBDR)]
		button $fb.quit	-text "Close" -width 3 -command "set pr_cref 0" -highlightbackground [option get . background {}]
		button $fb.ok	-text "OK" -width 3 -command "set pr_cref 1" -highlightbackground [option get . background {}]
		pack $fb.ok -side left
		pack $fb.quit -side right
		label $fv.val -text "value"
		entry $fv.ev -width 20 -textvariable refval
		label $fv.nam -text "text"
		entry $fv.en -width 20 -textvariable reftxt
		grid $fv.val $fv.ev -row 0 -padx 1 -sticky w 
		grid $fv.nam $fv.en -row 1 -padx 1 -sticky w 
		pack $f.buttons $f.val -side top -fill x -expand true
#		wm resizable $f 0 0
		bind $fv.ev <Down> {focus .cref.val.en}
		bind $fv.en <Up> {focus .cref.val.ev}
		bind $f <Return> {set pr_cref 1}
		bind $f <Escape> {set pr_cref 0}
	}
	set reftxt ""
	set finished 0
	set pr_cref 0
	set notxt 0
	raise $f
	My_Grab 0 $f pr_cref $f.val.ev
	while {!$finished} {
		if {$notxt} {
			focus $f.val.en
		} else {
			focus $f.val.ev
		}
		tkwait variable pr_cref
	 	if {$pr_cref} {
			if {[string length $refval] <= 0} {
				Inf "No valid reference value entered."
				set notxt 0
			} elseif {([string length $reftxt] <= 0)} {
				Inf "No reference text entered."
				set notxt 1
			} else {	
				lappend ref(val) $refval
				lappend ref(name) $reftxt
				incr ref(cnt)
				set zz $refval
				set m 0
				while {$m < $mu(SPACS)} {
					append zz " "
					incr m
				}
				append zz $reftxt
				.ref.l.list insert end $zz
				StoreRefs
				set finished 1
			}
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#------ Put a Reference val into a param, OR the output file from Table Editor to param

proc ValToParam {calling_window calling_window_switch} {
	global ref wl pr_rtp prno pa wstk prm pmcnt refp pr_refs evv
	global pmcnt gdg_typeflag parname col_tabname pr_te
	global grafixbrk pr_playw mu tabed_outfile mixval refval

	set fromref 0
	set fromgrafix 0
	set fromcalc 0
	if {[string match $calling_window .ref.l.list]} {
		set fromref 1
	} elseif {[string match $calling_window .playwindow]} {
		set fromgrafix 1
	} elseif {[string match $calling_window .cpd]} {
		set fromcalc 1
	} elseif {[string match $calling_window .qkref]} {
		set i [.ref.l.list curselection]
		if {$i < 0} {
			Inf "No Item Selected"
		} else {
			set mixval [lindex [lindex $ref(val) $i] 0]
		}
		set pr_refs 0
		return
	}
	if {$fromref} {
		set i [$calling_window curselection]
		if {![info exists i] || ![IsNumeric $i] || ($i < 0)} {
			Inf "No item selected"
			return
		}
	}
	if {$pmcnt == 1} {
		if {!$refp(0)} {
			Inf "This parameter cannot be set from here."
		} elseif {$fromref} {
			set prm(0) [lindex [lindex $ref(val) $i] 0]
		} elseif {$fromgrafix}  { ;# PlayWindow display
			set prm(0) $grafixbrk
		} elseif {$fromcalc}  { ;# Calculator Output
			set prm(0) $mu(recyc)
			destroy $calling_window
			return
		} else {	;# From Table Editor button
			set prm(0) $tabed_outfile
		}
		set $calling_window_switch 0
		return
	}
	set f .rtp
	if [Dlg_Create $f "Parameter Number" "set pr_rtp 0" -borderwidth $evv(BBDR)] {
		set b  [frame $f.b -borderwidth $evv(SBDR)]
		button $b.ok -text "OK" -width 5 -command "set pr_rtp 1" -highlightbackground [option get . background {}]
		button $b.q  -text "Close" -width 5 -command "set pr_rtp 0" -highlightbackground [option get . background {}]
		pack $b.ok -side left
		pack $b.q -side right
		set e  [frame $f.e -borderwidth $evv(SBDR)]
		Scrolled_Listbox $f.l -width 80 -height 20
 		label $e.l -text "Number"
		entry $e.e -width 20 -textvariable prno
		pack $e.l $e.e -side left -padx 1
		pack $f.b $f.e $f.l -side top -fill x -expand true
#		wm resizable $f 0 0
		bind $f.l.list <ButtonRelease-1> "GetParamNum %W %y"
		set prno ""
		bind $f <Return> {set pr_rtp 1}
		bind $f <Escape> {set pr_rtp 0}
	}
	set pr_rtp 0
	set finished 0
	$f.l.list delete 0 end
	set p_cnt 0 
	set g_cnt 0 
	set j 1

#JUNE 2000 List of (numbered) parameter names

	while {$p_cnt < $pmcnt} {
		if {[IsDeadParam $p_cnt]} {
			incr g_cnt
			incr p_cnt
			continue
		}
		if {$gdg_typeflag($g_cnt) == $evv(SWITCHED)} {
			incr p_cnt
			incr j
		}
		catch {unset line}
		set name $parname($g_cnt) 
		set name [string trim $name]
		set name [split $name "_"]
		set line $j
		append line " : " $name
		$f.l.list insert end $line
		incr p_cnt
		incr g_cnt
		incr j
	}
	raise $f
	My_Grab 0 $f pr_rtp $f.e.e
	while {!$finished} {
		tkwait variable pr_rtp
		if {$pr_rtp} {
			if {![IsNumeric $prno]} {
				Inf "No (Valid) Parameter Number Entered."
				continue
			}
			set pprno $prno
			incr pprno -1
			if {($pprno < 0) || ($pprno >= $pmcnt)} {
				Inf "No such parameter exists."
				continue
			}
			if {!$refp($pprno)} {
				Inf "This parameter cannot be set from here."
				continue
			}
			if {$fromref} {
	#NEW second level of indexing: MAY 12: 2002
				set prm($pprno) [lindex [lindex $ref(val) $i] 0]
			} elseif {$fromgrafix}  { ;# PlayWindow display
				set prm($pprno) $grafixbrk
			} elseif {$fromcalc}  { ;# Calculator output
				set prm($pprno) $mu(recyc)
			} else {	;# From Table Editor button
				set prm($pprno) $tabed_outfile
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	if {$pr_rtp} {
		if {$fromcalc} {
			destroy $calling_window
		} else {
			set $calling_window_switch 0
		}
	} elseif {$fromcalc} {
		destroy $calling_window
	}
}

#------ Put a Reference val into a Nudge Timelist

proc RefToTimelist {ll} {
	global ref twixtlist twixtminstep twixtlen twixtdur

	set j [$ll curselection]
	if {![info exists j] || ![IsNumeric $j] || ($j < 0)} {
		Inf "No reference item selected"
		return
	}
	set newtime [lindex $ref(val) $j]
	set k 0
	set done 0
	foreach val [$twixtlist get 0 end] {
		set val [split $val]
		set val [lindex $val 3]
		if {$newtime < $val} {
			if {$k > 0} {
				if {[expr $newtime - $lastval] <= $twixtminstep} {
					Inf "Values would be too close together"
					return
				}
			} elseif {$k  < [expr $twixtlen - 1]} {
				set kk [expr $k + 1]
				set nextval [$twixtlist	get $kk]
				if {[expr $nextval - $newtime] <= $twixtminstep} {
					Inf "Values would be too close together"
					return
				}
			}
			$twixtlist insert $k "X   $newtime"
			set done 1
			break
		}
		set lastval $val
		incr k
	}
	if {!$done} {
		if {[expr $newtime - $lastval] <= $twixtminstep} {
			Inf "Values would be too close together"
			return
		} elseif {[expr $twixtdur - $newtime] <= $twixtminstep} {
			Inf "Cannot generate values very close to or beyond end of shortest input soundfile ($twixtdur)"
			return
		}
		$twixtlist insert end "X   $newtime"
		set done 1
	}
	if {$done} {
		set pr_refs 0
	}
}


proc GetParamNum {ll y} {
	global prno
	set i [$ll nearest $y]
	set zz [$ll get $i]
	set zz [split $zz]
	set zz [lindex $zz 0]
	if {[string length $zz] <= 0} {
		return
	}
	set prno $zz
	ForceVal .rtp.e.e $prno
}



proc RefToLogSrch {ll action} {
	global logsrch ref action_src

	set i [$ll curselection]
	if {![info exists i] || ![IsNumeric $i] || ($i < 0)} {
		Inf "No item selected"
		return
	}
	if {$action} {
		set action_src [lindex [lindex $ref(val) $i] 0]
	} else {
		set logsrch [lindex [lindex $ref(val) $i] 0]
	}
}

#################
# DEGRADE SOUND #
#################

proc Degrade {} {
	global wl chlist pa evv wstk pr_degrade degrade CDPidrun prg_dun prg_abortd	simple_program_messages rememd
	global maxsamp_line done_maxsamp CDPmaxId

	set i [$wl curselection]
	if {[info exists chlist] && ([llength $chlist] == 1)} {
		set fnam [lindex $chlist 0]
	} elseif {[info exists i] && ([llength $i] == 1) && ($i != -1)} {
		set fnam [$wl get $i]
	}
	if {[info exists fnam]} {
		if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) != 1)} {
			unset fnam
		}
	}
	if {![info exists fnam]} {
		Inf "Select a single mono soundfile"
		return
	}
	set f .degrade
	if [Dlg_Create $f "DEGRADE SOUND" "set pr_degrade 0"  -borderwidth $evv(SBDR)] {
		frame $f.0
		frame $f.1
		frame $f.2
		frame $f.3
		button $f.0.ok -text "Degrade" -width 7 -command "set pr_degrade 1" -highlightbackground [option get . background {}]
		button $f.0.h  -text "Help"    -width 4 -command "DegradeHelp" -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.0.p  -text "Play"    -width 4 -command "PlayDegrade" -highlightbackground [option get . background {}]
		button $f.0.v  -text "View"    -width 4 -command "DisplayDegradeOutput" -bd 2 -state normal -bg $evv(SNCOLOROFF) -highlightbackground [option get . background {}]
		button $f.0.d  -text "Del"     -width 4 -command "DeleteDegradeOutput" -highlightbackground [option get . background {}]
		label $f.0.nn -text "Filename"
		entry $f.0.n -textvariable degrade(fnam) -width 12
		set degrade(fnam) ""
		button $f.0.s -text "Save Data"  -width 10 -command "set pr_degrade 2" -highlightbackground [option get . background {}]
		button $f.0.r -text "Rename/Del" -width 10 -command "RenameDegradeData" -highlightbackground [option get . background {}]
		button $f.0.a -text "Last Data"  -width 10 -command "set pr_degrade 3" -highlightbackground [option get . background {}]
		label $f.0.dum -text "" -width 7
		pack $f.0.ok $f.0.h $f.0.p $f.0.v $f.0.d $f.0.nn $f.0.n $f.0.s $f.0.r $f.0.a $f.0.dum -side left -padx 2
		button $f.0.quit -text "Quit" -width 4 -command "set pr_degrade 0" -highlightbackground [option get . background {}]
		pack $f.0.quit -side right
		pack $f.0 -side top -pady 2
		label $f.1.dpl -text "Degrade Pattern" -width 16
		entry $f.1.dp  -textvariable degrade(pattern) -width 40
		pack $f.1.dpl $f.1.dp -side left -fill x -expand true
		pack $f.1 -side top -pady 2
		radiobutton $f.2.1 -text "Random Vals" -variable degrade(rand) -value 1 -width 14 -command "DegradeRand 1"
		radiobutton $f.2.2 -text "Clear Vals"  -variable degrade(rand) -value 0 -width 14 -command "DegradeRand 0"
		pack $f.2.1 $f.2.2 -side left -fill x -expand true
		pack $f.2 -side top -pady 2
		frame $f.3.1
		frame $f.3.1.tit
		label $f.3.1.tit.tit -text "PARAMS" -fg $evv(SPECIAL)
		button $f.3.1.tit.cl -text "Clear" -command ClearDegradeParams -highlightbackground [option get . background {}]
		pack $f.3.1.tit.tit $f.3.1.tit.cl -side left
		set degrade(t) [text $f.3.1.t -setgrid true -wrap word -width 14 -height 34 \
		-xscrollcommand "$f.3.1.sx set" -yscrollcommand "$f.3.1.sy set"]
		scrollbar $f.3.1.sy -orient vert  -command "$f.3.1.k.t yview"
		scrollbar $f.3.1.sx -orient horiz -command "$f.3.1.t xview"
		pack $f.3.1.tit $f.3.1.t -side top
		pack $f.3.1 -side left -pady 2
		frame $f.3.2
		label $f.3.2.tit -text "PATCHES (Click-on to select)" -fg $evv(SPECIAL)
		set degrade(patchlist) [Scrolled_Listbox $f.3.2.ll -height 32 -width 48 -selectmode single -height 32]
		pack $f.3.2.tit $f.3.2.ll -side top
		pack $f.3.2 -side right -pady 2
		pack $f.3 -side top -pady 2
		wm resizable $f 0 0
		bind $degrade(patchlist) <ButtonRelease-1> {LoadSelectedDegradePatch %y}
		bind $f <Key-space>	 {PlayDegrade}
		bind .degrade.0.n <Up>			 "AdvanceNameIndex 1 degrade(fnam) 0"
		bind .degrade.0.n <Down>		 "AdvanceNameIndex 0 degrade(fnam) 0"
		bind .degrade.0.n <Control-Up>   "AdvanceNameIndex 1 degrade(fnam) 1"
		bind .degrade.0.n <Control-Down> "AdvanceNameIndex 0 degrade(fnam) 1"
		bind .degrade.1.dp <Down> {focus .degrade.0.n}
		bind .degrade.1.dp <Up>	  {focus .degrade.0.n}
		bind $f <Return> {DoDegrade}
		bind $f <Escape> {set pr_degrade 0}
	}
	$degrade(patchlist) delete 0 end
	if {[info exists degrade(patches)]} {
		foreach nam $degrade(patches) {
			$degrade(patchlist) insert end $nam
		}
	}
	set degrade(rand) -1
	set finished 0
	set pr_degrade 0
	raise $f
	My_Grab 0 $f pr_degrade $f.1.dp
	while {!$finished} {
		tkwait variable pr_degrade	
		switch -- $pr_degrade {
			1 {

				;#	CHECK OUTFILE NAME

				if {[string length $degrade(fnam)] <= 0} {
					Inf "No name entered for the output sound"
					continue
				}
				set outfnam [string tolower $degrade(fnam)]
				if {![ValidCDPRootname $outfnam]} {
					continue
				}
				append outfnam $evv(SNDFILE_EXT)
				if {[file exists $outfnam]} {
					set msg "File $outfnam already exists : overwrite it ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						Inf "Please choose a different filename"
						continue
					} elseif {[DeleteFileFromSystem $outfnam 0 1] <= 0} {
						Inf "Cannot delete existing file $outfnam : please choose a different filename"
						continue
					} else {
						set i [LstIndx $outfnam $wl]
						if {$i >= 0} {
							WkspCnt [$wl get $i] -1
							$wl delete $i
							catch {unset rememd}
						}
					}
				}

				;#	CHECK DEGRADE PATTERN

				set degrade(pattern) [string trim $degrade(pattern)]
				if {[string length $degrade(pattern)] <= 0} {
					Inf "No pattern entered"
					continue
				}
				set len [llength [split $degrade(pattern)]]
				if {$len > 1} {
					Inf "Spaces in pattern not permitted"
					continue
				}
				set patlen [string length $degrade(pattern)]
				set k 0
				set valcnt 0
				set OK 1
				while {$k < $patlen} {
					set p [string index $degrade(pattern) $k]
					if {[string match $p "d"]} {
						incr valcnt 2
					} elseif {[string match $p "r"]} {
						incr valcnt
					} else {
						Inf "Invalid character $p in pattern"
						set OK 0
						break
					}
					incr k
				}
				if {!$OK} {
					continue
				}

				;#	CHECK ENTERED VALS AGAINST PATTERN

				set lines [$degrade(t) get 1.0 end]	
				set lines "[split $lines \n]"
				catch {unset vals}
				set OK 1
				foreach line $lines {
					set items [split $line]	
					foreach item $items {
						set item [string trim $item]
						if {[string length $item] > 0} {
							if {![IsNumeric $item]} {
								Inf "Invalid value $item entered"
								set OK 0
								break
							}
							lappend vals $item
						}
					}
					if {!$OK} {
						break
					}
				}
				if {!$OK} {
					continue
				}
				if {![info exists vals]} {
					Inf "No parameter values entered"
					continue
				}
				set len [llength $vals]
				if {$len < $valcnt} {
					set msg "Insufficient values entered"
					if {$degrade(rand)} {
						append msg "\n\n(Do not change pattern after random-setting parameters)"
					}
					Inf $msg
					continue
				} elseif {$len > $valcnt} {
					set msg "TOO MANY VALUES ENTERED"
					if {$degrade(rand)} {
						append msg "\n\n(Do not change pattern after random-setting parameters)"
					}
					Inf $msg
					continue
				}
				set k 0
				set kk 0
				while {$kk < $patlen} {
					set item [string index $degrade(pattern) $kk]
					if {$item == "r"} {
						set val [lindex $vals $k]
						incr k
						if {$val < 20 || $val > 100} {
							Inf "Frequency value $val out of range (20 - 100)"
							set OK 0
							break		
						}
					} else {
						set val1 [lindex $vals $k]
						incr k
						set val2 [lindex $vals $k]
						incr k
						if {![regexp {^[0-9]+$} $val1] || ($val1 < 2) || ($val1 > 3)} {
							Inf "Invalid waveset repetition value $val1 : 2 or 3 only"
							set OK 0
							break
						}
						if {![regexp {^[0-9]+$} $val2] || ($val2 < 1) || ($val2 > 3)} {
							Inf "Invalid waveset grouping value $val2	 : 1, 2 or 3 only"
							set OK 0
							break
						}
					}
					incr kk
				}
				if {!$OK} {
					continue
				}
				set degrade(vals) $vals

				;#	DO PROCESSING

				catch {file delete $degrade(output)}
				DeleteAllTemporaryFiles
				catch {unset degrade(successful)}
				set OK 1
				set paramscnt  0		;#	count of all parameters
				set processcnt 0		;#	count of all processes (used to number temporary output files)
				set distortcnt 1		;#	numbering of each distort process in pattern
				set ringmodcnt 1		;#	numbering of each ringmod process in pattern

				set ofnam $fnam			;#	"ofnam" becomes "ifnam" within loop

				Block "DEGRADING THE SOUND"

				while {$OK} {
					set kk 0
					while {$kk < $patlen} {
						set p [string index $degrade(pattern) $kk]
						set ifnam $ofnam
						set ofnam $evv(MACH_OUTFNAME)
						append ofnam $processcnt $evv(SNDFILE_EXT)
						incr processcnt
						if {$p == "d"} {

							set par1 [lindex $degrade(vals) $paramscnt]
							incr paramscnt
							set par2 [lindex $degrade(vals) $paramscnt]
							incr paramscnt
							set cmd [file join $evv(CDPROGRAM_DIR) distort]
							lappend cmd repeat2 $ifnam $ofnam $par1 -c$par2
							set prg_dun 0
							set prg_abortd 0
							catch {unset simple_program_messages}
							wm title .blocker "RUNNING WAVESET-DISTORT $distortcnt"
							if [catch {open "|$cmd"} CDPidrun] {
								Inf "$CDPidrun : failed to run waveset-distort $distortcnt"
								catch {unset CDPidrun}
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
								set msg "Cannot create output from waveset-distort $distortcnt"
								set msg [AddSimpleMessages $msg]
								ErrShow $msg
								set OK 0
								break
							}
							set ifnam $ofnam
							set ofnam $evv(MACH_OUTFNAME)
							append ofnam $processcnt $evv(SNDFILE_EXT)
							incr processcnt

							;#	HIPASS FILTER OUTPUT
							
							set cmd [file join $evv(CDPROGRAM_DIR) filter]
							lappend cmd lohi 1 $ifnam $ofnam -96 80 50 -t0 -s1
							set prg_dun 0
							set prg_abortd 0
							catch {unset simple_program_messages}
							wm title .blocker "RUNNING FILTERING OF WAVESET-DISTORT $distortcnt"
							if [catch {open "|$cmd"} CDPidrun] {
								Inf "$CDPidrun : Failed to do filtering of waveset-distort $distortcnt"
								catch {unset CDPidrun}
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
								set msg "Cannot create filtered output from waveset-distort $distortcnt"
								set msg [AddSimpleMessages $msg]
								ErrShow $msg
								set OK 0
								break
							}
							set lastproc "WAVESET-DISTORTION $distortcnt"
							incr distortcnt

						} else { ;# ringmod

							set par [lindex $degrade(vals) $paramscnt]
							incr paramscnt
							set cmd [file join $evv(CDPROGRAM_DIR) modify]
							lappend cmd radical 5 $ifnam $ofnam $par
							set prg_dun 0
							set prg_abortd 0
							catch {unset simple_program_messages}
							wm title .blocker "RUNNING RING_MODULATION $ringmodcnt"
							if [catch {open "|$cmd"} CDPidrun] {
								Inf "$CDPidrun : Failed to do ring_modulation $ringmodcnt"
								catch {unset CDPidrun}
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
								set msg "Cannot do ring_modulation $ringmodcnt"
								set msg [AddSimpleMessages $msg]
								ErrShow $msg
								set OK 0
								break
							}
							set lastproc "RING_MODULATION $ringmodcnt"
							incr ringmodcnt
						}
						set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
						catch {unset CDPmaxId}
						catch {unset maxsamp_line}
						set done_maxsamp 0
						lappend cmd $ofnam
						if [catch {open "|$cmd"} CDPmaxId] {
							;
	   					} else {
	   						fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
		 					vwait done_maxsamp
						}
						if {[info exists maxsamp_line]} {

							set maxoutsamp [lindex $maxsamp_line 0]
							if {$maxoutsamp <= 0.0} {
								Inf "Output level zero"
								set OK 0
								break
							}
							if {$maxoutsamp < 0.9} {

								;#	NORMALISE OUTPUT
				
								set ifnam $ofnam
								set ofnam $evv(MACH_OUTFNAME)
								append ofnam $processcnt $evv(SNDFILE_EXT)
								incr processcnt

								set cmd [file join $evv(CDPROGRAM_DIR) modify]
								lappend cmd loudness 3 $ifnam $ofnam -l0.9
								set prg_dun 0
								set prg_abortd 0
								catch {unset simple_program_messages}
								wm title .blocker "NORMALISING OUTPUT OF $lastproc"
								if [catch {open "|$cmd"} CDPidrun] {
									Inf "$CDPidrun : Failed to normalise output of $lastproc"
									catch {unset CDPidrun}
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
									set msg "Cannot normalise output of $lastproc"
									set msg [AddSimpleMessages $msg]
									ErrShow $msg
									set OK 0
									break
								}
							}
						}
						incr kk  
					}
					break
				}
				if {!$OK} {
					UnBlock
					continue
				}
				set degrade(output) $ofnam		;#	Used by "Play"

				if [catch {file copy $degrade(output) $outfnam} zit] {
					Inf "Cannot copy the temporary output file to $outfnam"
					UnBlock
					continue
				}
				if {[FileToWkspace $outfnam 0 0 0 0 1] > 0} {
					Inf "File $outfnam is on the workspace"
				} else {
					Inf "File $outfnam has been created, but is not on the workspace"
				}
				set degrade(lastvals) [list $degrade(pattern) $degrade(vals)]
				set degrade(successful) 1
				UnBlock
				continue
			}
			2 {
				if {![info exists degrade(successful)]} {
					Inf "No degrade file created yet"
					continue
				}
				if {[string length $degrade(fnam)] <= 0} {
					Inf "No name entered for the degrade data"
					continue
				}
				set nam [string tolower $degrade(fnam)]
				if {![ValidCDPRootname $nam]} {
					continue
				}
				set pachnam "dgr_"
				append pachnam $nam
				set overwriting 0
				set outnam [file join $evv(URES_DIR) $pachnam$evv(CDP_EXT)]
				if {[file exists $outnam]} {
					set msg "Overwrite existing patch $nam ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					} else {
						set overwriting 1
					}
				}
				catch {unset lines} 
				set line $degrade(pattern)
				lappend lines $line
				set line $degrade(vals)
				lappend lines $line
				if [catch {open $outnam "w"} zit] {
					Inf "Cannot open file $outnam to write the patch"
					continue
				}
				foreach line $lines {
					puts $zit $line
				}
				close $zit
				if {!$overwriting} {
					lappend degrade(patches) $nam
					set degrade(patches) [lsort -dictionary $degrade(patches)]
					$degrade(patchlist) delete 0 end
					foreach nnam $degrade(patches) {
						$degrade(patchlist) insert end $nnam
					}
				}
				Inf "Patch $nam saved"
				continue
			}
			3 {		;#	LOAD PREVIOUS VALUES
				if {![info exists degrade(lastvals)]} {
					Inf "No previous degrade parameters exist"
					continue
				} else {
					set degrade(pattern) [lindex $degrade(lastvals) 0]
					set degrade(vals)    [lindex $degrade(lastvals) 1]
					set qq 0
					$degrade(t) delete 1.0 end
					foreach val $degrade(vals) {
						if {$qq > 0} {
							$degrade(t) insert end "\n"
						}
						$degrade(t) insert end $val
						incr qq
					}
				}
				continue
			}
			0 {
				DeleteAllTemporaryFiles
				set finished 1
			}
		}
	}
	if {[info exists degrade(output)]} {
		catch {[PurgeArray $degrade(output)]}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc DegradeHelp {} {
	set msg "DEGRADE SOUND\n"
	append msg "\n"
	append msg "PATTERN\n"
	append msg "\n"
	append msg "A list of the letters \"r\" and \"d\" only.\n"
	append msg "\n"
	append msg "\"r\" is a ring-modulation process,\n"
	append msg "            for which ONE (frequency) parameter is required, in the range 20 to 100,\n"
	append msg "            every time \"r\" occurs in the pattern.\n"
	append msg "\n"
	append msg "\"d\" is a waveset-repeat-without-timestretch process,\n"
	append msg "            for which TWO (repeat-count & waveset-groupsize) parameters are needed\n"
	append msg "            every time \"d\" occurs in the pattern.\n"
	append msg "            Repeat-count can be 2 or 3.\n"
	append msg "            Waveset-Groupsize can be 1,2 or 3.\n"
	append msg "\n"
	append msg "PARAMETERS\n"
	append msg "\n"
	append msg "Values can be entered by typing in the \"PARAMETERS\" window.\n"
	append msg "            Enter the APPROPRIATE NUMBER of values (see above) IN THE CORRECT ORDER\n"
	append msg "            to correspond to the pattern you have set must be.\n"
	append msg "\n"
	append msg "If \"Random Vals\" is chosen, parameters are set with random values.\n"
	append msg "            However, such random value sets can be saved (\"Save Pattern\")\n"
	append msg "\n"
	append msg "Previously saved Values (and the associated pattern) can also be LOADED\n"
	append msg "            by Clicking on a previously saved, named PATCH\n"
	append msg "            listed in the PATCHES window.\n"
	append msg "\n"
	append msg "\"Clear Vals\" clears the parameters window (but not the pattern).\n"
	append msg "\n"
	append msg "RENAMING AND DELETING PATCHES\n"
	append msg "\n"
	append msg "To RENAME a patch, enter a new name in the name box, select a patch and hit \"RENAME/DEL\".\n"
	append msg "To DELETE a patch, CLEAR the name box, select a patch and hit \"RENAME/DEL\".\n"
	append msg "\n"
	Inf $msg
}

proc PlayDegrade {} {
	global degrade
	if {![info exists degrade(output)] || ![file exists $degrade(output)]} {
		Inf "No output file to play"
		return
	}
	PlaySndfile	$degrade(output) 0
}

proc LoadDegradePatches {} {
	global evv degrade
	catch {unset degrade(patches)}
	foreach fnam [glob -nocomplain [file join $evv(URES_DIR) dgr_*]] {
		if {[file isdirectory $fnam]} {
			continue
		}	
		set nam [file rootname [file tail $fnam]]
		set nam [string range $nam 4 end]
		lappend degrade(patches) $nam
	}
	if {[info exists degrade(patches)]} {
		set degrade(patches) [lsort -dictionary $degrade(patches)]
	}
}

proc ClearDegradeParams {} {
	global degrade
	$degrade(t) delete 1.0 end
}

proc DegradeRand {set} {
	global degrade
	if {$set} {
		set degrad(pattern) [string trim $degrade(pattern)]
		set len [string length $degrade(pattern)]
		if {$len == 0} {
			Inf "No degrade pattern entered"
			set degrade(rand) 0
			return
		}
		set k 0
		while {$k < $len} {
			set p [string index $degrade(pattern) $k]
			if {!([string match $p "d"] || [string match $p "r"])} {
				Inf "Invalid character ($p) in degrade pattern"
				set degrade(rand) 0
				return
			}
			incr k
		}
		catch {unset degrade(vals)}
		set k 0
		set len [string length $degrade(pattern)]
		while {$k < $len} {
			set item [string index $degrade(pattern) $k]
			switch -- $item {
				"d" {
					set val [expr int(floor(rand() * 2)) + 2]		;#	rand*2 -> 0 to 1.999 intfloor -> 0:1 -> 2:3
					lappend degrade(vals) $val
					set val [expr int(floor(rand() * 3)) + 1]		;#	rand*3 -> 0 to 2.999 intfloor -> 0:1:2 -> 1:2:3
					lappend degrade(vals) $val
				}
				"r" {
					set val [expr (rand() * 80.0) + 20.0]			;#	0 -> 79.99 -> 20 -> 99.99
					lappend degrade(vals) $val
				}
			}
			incr k
		}
		$degrade(t) delete 1.0 end
		set qq 0
		$degrade(t) delete 1.0 end
		foreach val $degrade(vals) {
			if {$qq > 0} {
				$degrade(t) insert end "\n"
			}
			$degrade(t) insert end $val
			incr qq
		}
	} else {
		$degrade(t) delete 1.0 end
	}
}	

;# "Return" key doesn't start Degrade if we're in vals window

proc DoDegrade {} {
	global degrade pr_degrade
	if {![string match [focus] $degrade(t)]} {
		set pr_degrade 1
	}
}

proc DisplayDegradeOutput {} {
	global degrade evv pa
	if {![info exists degrade(output)] || ![file exists $degrade(output)]} {
		return
	}
	if {![info exists pa($degrade(output),$evv(FTYP))]} {
		if {[DoParse $degrade(output) 0 0 0] <= 0} {
			return
		}
	}
	SnackDisplay 0 $evv(SN_FROM_DEGRADE_NO_OUTPUT) $evv(TIME_OUT) $degrade(output)
}

proc LoadSelectedDegradePatch {y} {
	global degrade evv
	set i [$degrade(patchlist) nearest $y]
	if {![info exists i] || ($i == -1)} {
		return
	}
	set pachnam "dgr_"
	append pachnam [$degrade(patchlist) get $i]
	set pfnam [file join $evv(URES_DIR) $pachnam$evv(CDP_EXT)]
	if {![file exists $pfnam]} {
		Inf "Patch file	$pfnam no longer exists"
		$degrade(patchlist) delete $i
		set degrade(patches) [leplace $degrade(patches) $i $i]
		return
	}
	if [catch {open $pfnam "r"} zit] {
		Inf "Cannot open patch file $pfnam"
		return
	}
	catch {unset lines}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] > 0} {
			lappend lines $line
		}
	}
	close $zit
	if {[llength $lines] != 2} {
		Inf "Bad data in patchfile $pfnam"
		return
	}
	set degrade(pattern) [lindex $lines 0]
	set degrade(vals) [lindex $lines 1]
	set qq 0
	$degrade(t) delete 1.0 end
	foreach val $degrade(vals) {
		if {$qq > 0} {
			$degrade(t) insert end "\n"
		}
		$degrade(t) insert end $val
		incr qq
	}
}

proc RenameDegradeData {} {
	global degrade wstk evv pa wl ch chlist rememd
	set snd_delete 0

	set i [$degrade(patchlist) curselection]
	if {![info exists i] || ($i == -1)} {
		Inf "No patch selected for renaming"
		return
	}
	set orignam [$degrade(patchlist) get $i]
	set origpachnam "dgr_"
	append origpachnam $orignam
	set origpfnam [file join $evv(URES_DIR) $origpachnam$evv(CDP_EXT)]
	if {![file exists $origpfnam]} {
		Inf "Patch file $origpfnam no longer exists"
		$degrade(patchlist) delete $i
		set degrade(patches) [lreplace $degrade(patches) $i $i]
		return
	}
	if {[string length $degrade(fnam)] <= 0} {
		set msg "No new name entered for patch : delete the existing patch ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		} else {
			if {![AreYouSure]} {
				return
			}
			if [catch {file delete $origpfnam} zit] {
				Inf "Cannot delete existing patch file $origpfnam"
				return
			}
			$degrade(patchlist) delete $i
			set degrade(patches) [lreplace $degrade(patches) $i $i]
		}
		set msg "Delete the related (same name) output file ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		}
		set snd_delete 1
	} else {
		set nunam [string tolower $degrade(fnam)]
		if {![ValidCDPRootname $nunam]} {
			return
		}
		if {[string match $nunam $orignam]} {
			Inf "Name has not changed"
			return
		}
		set nupachnam "dgr_"
		append nupachnam $nunam
		set nupfnam [file join $evv(URES_DIR) $nupachnam$evv(CDP_EXT)]

		set kknu [lsearch $degrade(patches) $nunam]
		if {$kknu >= 0} {
			set msg "New patch name already being used : overwrite existing patch ??"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				return
			} else {
				if [catch {file delete $nupfnam} zit] {
					Inf "Cannot overwrite existing patch file $nupfnam"
					return
				}
				set degrade(patches) [lreplace $degrade(patches) $kknu $kknu] 
			}
		}
		if [catch {file rename $origpfnam $nupfnam} zit] {
			Inf "Cannot rename patch $orignam"
			return
		}
		set degrade(patches) [lreplace $degrade(patches) $i $i $nunam]
		set degrade(patches) [lsort -dictionary $degrade(patches)]
		$degrade(patchlist) delete 0 end
		foreach p $degrade(patches) {
			$degrade(patchlist) insert end $p
		}
		set msg "Rename related (same name) output file ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		}
	}
	set i 0
	foreach fnam [$wl get 0 end] {
		if {[string match [file rootname [file tail $fnam]] $orignam]} {
			if {($pa($fnam,$evv(FTYP)) == $evv(SNDFILE)) && ($pa($fnam,$evv(CHANS)) == 1)} {
				if {[info exists matchfnam]} {
					Inf "More than one soundfile with the name $orignam$evv(SNDFILE_EXT) : Cannot proceed"
					return
				}
				set matchfnam $fnam
				set ii $i
			}
		}
		incr i
	}
	if {![info exists matchfnam]} {
		Inf "no mono soundfiles with name $orignam$evv(SNDFILE_EXT) found on the workspace"
		return
	}
	if {$snd_delete} {
		if {[DeleteFileFromSystem $matchfnam 0 1] <= 0} {
			Inf "Cannot delete sound file $matchfnam"
		} else {
			DummyHistory $matchfnam "DESTROYED"
			if {[IsInAMixfile $matchfnam]} {
				if {[MixM_ManagedDeletion $matchfnam]} {
					MixMStore
				}
			}
			if {$ii >= 0} {
				$wl delete $ii
				WkspCnt $matchfnam -1
				catch {unset rememd}
			}
			Inf "Sound file $matchfnam deleted"
		}
		return
	}
	set thisdir [file dirname $matchfnam]
	set dirlen [string length $thisdir]
	if {$dirlen < 2} {
		set thisdir ""
	}
	set nufnam [file join $thisdir $nunam$evv(SNDFILE_EXT)]

	if [catch {file rename $matchfnam $nufnam} zorg] {
		ErrShow "FAILED TO RENAME FILE $matchfnam"
		return
	}
	UpdateBakupLog $matchfnam delete 0
	UpdateBakupLog $nufnam create 1
	CheckMainmixSnd $matchfnam $nufnam
	$wl delete $ii
	$wl insert $ii $nufnam
	RenameProps $matchfnam $nufnam 1
	DummyHistory $matchfnam "RENAMED_$nufnam"
	DataManage rename $matchfnam $nufnam
	if {[MixMRename $matchfnam $nufnam 0]} {
		MixMStore
	}
	set haspmark [HasPmark $matchfnam]
	if {$haspmark} {
		MovePmark $matchfnam $nufnam
	}
	set hasmmark [HasMmark $matchfnam]
	if {$hasmmark} {
		MoveMmark $matchfnam $nufnam
	}
	if [IsInBlists $matchfnam] {
		if [RenameInBlists $matchfnam $nufnam] {
			SaveBL $background_listing
		}
	}
	if [IsOnScore $matchfnam] {
		RenameOnScore $matchfnam $nufnam
	}
	AddToDirlist $nufnam
	if [info exists chlist] {
		set j [lsearch -exact $chlist $matchfnam]
		if {$j >= 0} {
			set jjj [lsearch -exact $chlist $nufnam]
			if {$jjj >= 0} {
				set chlist [lreplace $chlist $j $j]
			} else {
				set chlist [lreplace $chlist $j $j $nufnam]
			}
			$ch delete 0 end
			foreach ff $chlist {
				$ch insert end $ff
			}
		}
	}
	Inf "Renamed related output file"
}

proc DeleteDegradeOutput {} {
	global degrade evv wstk wl rememd
	if {!$degrade(successful)} {
		Inf "No current outputfile"
		return
	}
	set outfnam [string tolower $degrade(fnam)]
	append outfnam $evv(SNDFILE_EXT)
	if {![string match [$wl get 0] $outfnam]} {
		Inf "Current named file is not the most recent output file"
		return
	}
	set msg "Delete soundfile $outfnam ??"
	set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
	if {$choice == "no"} {
		return
	}
	if {[DeleteFileFromSystem $outfnam 0 1] <= 0} {
		Inf "Cannot delete sound file $outfnam"
	}
	$wl delete 0
	WkspCnt $outfnam -1
	catch {unset rememd}
	Inf "Sound file $outfnam deleted"
}

####################
# RECURSIVE FILTER #
####################

proc Polyfilter {} {
	global wl chlist pa evv wstk pr_polyf polyf CDPidrun prg_dun prg_abortd	simple_program_messages rememd
	global maxsamp_line done_maxsamp CDPmaxId has_overflowed

	set i [$wl curselection]
	if {[info exists chlist] && ([llength $chlist] == 1)} {
		set fnam [lindex $chlist 0]
	} elseif {[info exists i] && ([llength $i] == 1) && ($i != -1)} {
		set fnam [$wl get $i]
	}
	if {[info exists fnam]} {
		if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
			unset fnam
		}
	}
	if {![info exists fnam]} {
		Inf "Select a single soundfile"
		return
	}
	set f .polyf
	if [Dlg_Create $f "RECURSIVELY FILTER SOUND" "set pr_polyf 0"  -borderwidth $evv(SBDR)] {
		frame $f.0
		frame $f.1
		frame $f.2
		frame $f.2a
		frame $f.3
		button $f.0.ok -text "Filter"  -width 7 -command "set pr_polyf 1" -highlightbackground [option get . background {}]
		button $f.0.h  -text "Help"    -width 4 -command "PolyfiltHelp" -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.0.p  -text "Play"    -width 4 -command "PlayPolyfilt" -highlightbackground [option get . background {}]
		button $f.0.v  -text "View"    -width 4 -command "DisplayPolyfiltOutput" -bd 2 -state normal -bg $evv(SNCOLOROFF) -highlightbackground [option get . background {}]
		button $f.0.d  -text "Del"     -width 4 -command "DeletePolyfiltOutput" -highlightbackground [option get . background {}]
		label $f.0.nn -text "Filename"
		entry $f.0.n -textvariable polyf(fnam) -width 12
		set polyf(fnam) ""
		button $f.0.s -text "Save Data"  -width 10 -command "set pr_polyf 2" -highlightbackground [option get . background {}]
		button $f.0.r -text "Rename/Del" -width 10 -command "RenamePolyfiltData" -highlightbackground [option get . background {}]
		button $f.0.a -text "Last Data"  -width 10 -command "set pr_polyf 3" -highlightbackground [option get . background {}]
		label $f.0.dum -text "" -width 7
		pack $f.0.ok $f.0.h $f.0.p $f.0.v $f.0.d $f.0.nn $f.0.n $f.0.s $f.0.r $f.0.a $f.0.dum -side left -padx 2
		button $f.0.quit -text "Quit" -width 4 -command "set pr_polyf 0" -highlightbackground [option get . background {}]
		pack $f.0.quit -side right
		pack $f.0 -side top -pady 2
		label $f.1.dpl -text "Pass Band" -width 16
		entry $f.1.dp  -textvariable polyf(pass) -width 40
		pack $f.1.dpl $f.1.dp -side left -fill x -expand true
		pack $f.1 -side top -pady 2
		label $f.2.dpl -text "Stop Band" -width 16
		entry $f.2.dp  -textvariable polyf(stop) -width 40
		pack $f.2.dpl $f.2.dp -side left -fill x -expand true
		pack $f.2 -side top -pady 2
		label $f.2a.dpl -text "Recursion cnt" -width 16
		entry $f.2a.dp  -textvariable polyf(cnt) -width 40
		pack $f.2a.dpl $f.2a.dp -side left -fill x -expand true
		pack $f.2a -side top -pady 2
		frame $f.3.2
		label $f.3.2.tit -text "PATCHES (Click-on to select)" -fg $evv(SPECIAL)
		set polyf(patchlist) [Scrolled_Listbox $f.3.2.ll -height 32 -width 48 -selectmode single -height 32]
		pack $f.3.2.tit $f.3.2.ll -side top
		pack $f.3.2 -side right -pady 2
		pack $f.3 -side top -pady 2
		wm resizable $f 0 0
		bind $polyf(patchlist) <ButtonRelease-1> {LoadSelectedPolyfiltPatch %y}
		wm resizable $f 0 0
		bind $f <Key-space>	 {PlayPolyfilt}
		bind .polyf.0.n <Up>		    "AdvanceNameIndex 1 polyf(fnam) 0"
		bind .polyf.0.n <Down>			"AdvanceNameIndex 0 polyf(fnam) 0"
		bind .polyf.0.n <Control-Up>	"AdvanceNameIndex 1 polyf(fnam) 1"
		bind .polyf.0.n <Control-Down>	"AdvanceNameIndex 0 polyf(fnam) 1"
		bind .polyf.1.dp <Down> {focus .polyf.2.dp}
		bind .polyf.2.dp <Down> {focus .polyf.2a.dp}
		bind .polyf.2a.dp <Down> {focus .polyf.1.dp}
		bind .polyf.1.dp <Up>	{focus .polyf.2a.dp}
		bind .polyf.2.dp <Up>	{focus .polyf.1.dp}
		bind .polyf.2a.dp <Up>	{focus .polyf.2.dp}
		bind $f <Return> {set pr_polyf 1}
		bind $f <Escape> {set pr_polyf 0}
	}
	$polyf(patchlist) delete 0 end
	if {[info exists polyf(patches)]} {
		foreach nam $polyf(patches) {
			$polyf(patchlist) insert end $nam
		}
	}
	set polyf(fnam) [file rootname [file tail $fnam]]
	append polyf(fnam) _rf
	set finished 0
	set pr_polyf 0
	raise $f
	My_Grab 0 $f pr_polyf $f.0.n
	while {!$finished} {
		tkwait variable pr_polyf	
		switch -- $pr_polyf {
			1 {

				;#	CHECK OUTFILE NAME

				if {[string length $polyf(fnam)] <= 0} {
					Inf "No name entered for the output sound"
					continue
				}
				set outfnam [string tolower $polyf(fnam)]
				if {![ValidCDPRootname $outfnam]} {
					continue
				}
				append outfnam $evv(SNDFILE_EXT)
				if {[file exists $outfnam]} {
					set msg "File $outfnam already exists : overwrite it ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						Inf "Please choose a different filename"
						continue
					} elseif {[DeleteFileFromSystem $outfnam 0 1] <= 0} {
						Inf "Cannot delete existing file $outfnam : please choose a different filename"
						continue
					} else {
						set i [LstIndx $outfnam $wl]
						if {$i >= 0} {
							WkspCnt [$wl get $i] -1
							$wl delete $i
							catch {unset rememd}
						}
					}
				}

				;#	CHECK FILTER PARAMS

				if {([string length $polyf(pass)] <= 0) || ![IsNumeric $polyf(pass)] || ($polyf(pass) < 10) || ($polyf(pass) >= 22050)} {
					Inf "Invalid filter passband frequency (range 10 to 22050 hz)"
					continue
				}
				if {([string length $polyf(stop)] <= 0) || ![IsNumeric $polyf(stop)] || ($polyf(stop) < 10) || ($polyf(stop) >= 22050)} {
					Inf "Invalid filter stopband frequency (range 10 to 22050 hz)"
					continue
				}
				if {([string length $polyf(cnt)] <= 0) || ![regexp {^[0-9]+$} $polyf(cnt)] || ($polyf(cnt) < 1) || ($polyf(cnt) > 6)} {
					Inf "Invalid filter iteration count (range 1 to 6)"
					continue
				}

				catch {file delete $polyf(output)}
				DeleteAllTemporaryFiles
				catch {unset polyf(successful)}
				set OK 1
				set processcnt 0		;#	count of all processes (used to number temporary output files)
				set itercnt 0
				set ofnam $fnam			;#	"ofnam" becomes "ifnam" within loop

				Block "RECURSIVELY FILTERING THE SOUND"

				while {$OK} {
					while {($itercnt < $polyf(cnt))} {
						set ifnam $ofnam
						set ofnam $evv(MACH_OUTFNAME)
						append ofnam $processcnt $evv(SNDFILE_EXT)
						incr processcnt
						set level 1
						set maxoutsamp 1.0
						set passcnt 1
						while {$maxoutsamp >= 0.95} {
							set cmd [file join $evv(CDPROGRAM_DIR) filter]
							lappend cmd lohi 1 $ifnam $ofnam -96.0 $polyf(pass) $polyf(stop) -t1.0 -s$level 
							set has_overflowed 0
							set prg_dun 0
							set prg_abortd 0
							catch {unset simple_program_messages}
							wm title .blocker "RUNNING FILTER $itercnt : PASS $passcnt"
							if [catch {open "|$cmd"} CDPidrun] {
								Inf "$CDPidrun : Failed to run filter $itercnt : pass $passcnt"
								catch {unset CDPidrun}
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
								set msg "Cannot create output from filter $itercnt : pass $passcnt"
								set msg [AddSimpleMessages $msg]
								ErrShow $msg
								set OK 0
								break
							}

							set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
							catch {unset CDPmaxId}
							catch {unset maxsamp_line}
							set done_maxsamp 0
							lappend cmd $ofnam
							if [catch {open "|$cmd"} CDPmaxId] {
								Inf "Cannot run maxsap2 program"
								set OK 0
								break
	   						} else {
	   							fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
		 						vwait done_maxsamp
							}
							if {![info exists maxsamp_line]} {
								Inf "Cannot find level of intermediate file $ofnam"
								set OK 0
								break
							}
							set maxoutsamp [lindex $maxsamp_line 0]
							if {$maxoutsamp > 0.95} {
								set level [expr $level * 0.9]
								if [catch {file delete $ofnam} zit] {
									Inf "Cannnot delete intermediate file $ofnam"
									set OK 0
									break
								}
							}
							incr passcnt
						}
						if {!$OK} {
							break
						}
						if {$maxoutsamp <= 0.0} {
							Inf "Output of filter iteration has level zero"
							set OK 0
							break
						}
						if {$maxoutsamp < 0.9} {
							set ifnam $ofnam
							set ofnam $evv(MACH_OUTFNAME)
							append ofnam $processcnt $evv(SNDFILE_EXT)
							incr processcnt

							set cmd [file join $evv(CDPROGRAM_DIR) modify]
							lappend cmd loudness 3 $ifnam $ofnam -l0.9
							set prg_dun 0
							set prg_abortd 0
							catch {unset simple_program_messages}
							wm title .blocker "NORMALISING OUTPUT OF FILTER ITERATION $itercnt"
							if [catch {open "|$cmd"} CDPidrun] {
								Inf "$CDPidrun : Failed to normalise output of filter iteration $itercnt"
								catch {unset CDPidrun}
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
								set msg "Cannot normalise output of filter iteration $itercnt"
								set msg [AddSimpleMessages $msg]
								ErrShow $msg
								set OK 0
								break
							}
						}
						if {!$OK} {
							break
						}
						incr itercnt
					}
					set ifnam $ofnam
					set ofnam $evv(MACH_OUTFNAME)
					append ofnam $processcnt $evv(SNDFILE_EXT)
					set cmd  [file join $evv(CDPROGRAM_DIR) housekeep]
					lappend cmd extract 3 $ifnam $ofnam -g0 -s15 -b
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					wm title .blocker "TAILING OUTPUT OF FILTER ITERATION $itercnt"
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "$CDPidrun : Failed to tail output of filter iteration $itercnt"
						catch {unset CDPidrun}
						set $ofnam $ifnam			;#	just use untailed version
						break
					} else {
						fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
					}
					vwait prg_dun
					if {$prg_abortd} {
						set prg_dun 0
					}
					if {!$prg_dun} {
						set msg "Cannot tail output of filter iteration $itercnt"
						set msg [AddSimpleMessages $msg]
						ErrShow $msg
						set $ofnam $ifnam			;#	just use untailed version
						break
					}
					break
				}
				if {!$OK} {
					UnBlock 
					continue
				}
				set polyf(output) $ofnam		;#	Used by "Play"

				if [catch {file copy $polyf(output) $outfnam} zit] {
					Inf "Cannot copy the temporary output file to $outfnam"
					UnBlock
					continue
				}
				if {[FileToWkspace $outfnam 0 0 0 0 1] > 0} {
					Inf "File $outfnam is on the workspace"
				} else {
					Inf "File $outfnam has been created, but is not on the workspace"
				}
				set polyf(lastvals) [list $polyf(pass) $polyf(stop) $polyf(cnt)]
				set polyf(successful) 1
				UnBlock
				continue
			}
			2 {
				if {![info exists polyf(successful)]} {
					Inf "No degrade file created yet"
					continue
				}
				if {[string length $polyf(fnam)] <= 0} {
					Inf "No name entered for the degrade data"
					continue
				}
				set nam [string tolower $polyf(fnam)]
				if {![ValidCDPRootname $nam]} {
					continue
				}
				set pachnam "poly_"
				append pachnam $nam
				set overwriting 0
				set outnam [file join $evv(URES_DIR) $pachnam$evv(CDP_EXT)]
				if {[file exists $outnam]} {
					set msg "Overwrite existing patch $nam ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					} else {
						set overwriting 1
					}
				}
				catch {unset line} 
				set line [list $polyf(pass) $polyf(stop) $polyf(cnt)]
				if [catch {open $outnam "w"} zit] {
					Inf "Cannot open file $outnam to write the patch"
					continue
				}
				puts $zit $line
				close $zit
				if {!$overwriting} {
					lappend polyf(patches) $nam
					set polyf(patches) [lsort -dictionary $polyf(patches)]
					$polyf(patchlist) delete 0 end
					foreach nnam $polyf(patches) {
						$polyf(patchlist) insert end $nnam
					}
				}
				Inf "Patch $nam saved"
				continue
			}
			3 {		;#	LOAD PREVIOUS VALUES
				if {![info exists polyf(lastvals)]} {
					Inf "No previous degrade parameters exist"
					continue
				} else {
					set polyf(pass) [lindex $polyf(lastvals) 0]
					set polyf(stop) [lindex $polyf(lastvals) 1]
					set polyf(cnt)  [lindex $polyf(lastvals) 2]
				}
				continue
			}
			0 {
				DeleteAllTemporaryFiles
				set finished 1
			}
		}
	}
	if {[info exists polyf(output)]} {
		catch {[PurgeArray $polyf(output)]}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc PolyfiltHelp {} {
	set msg "Recursively filter the sound\n"
	append msg "\n"
	append msg "Apply filter recursively : adjusting level as you proceed\n"
	append msg "\n"
	append msg "PASS : Filter pass band in Hz (Range 20 - 22050).\n"
	append msg "STOP : Filter stop band in Hz (Range 20 - 22050).\n"
	append msg "RECURSIONS : Number of recursive applications of the filter.\n"
	append msg "\n"
	append msg "If Stop band is Above pass band, this is a Low-pass filter.\n"
	append msg "If Stop band is Below pass band, this is a High-pass filter.\n"
	append msg "\n"
	Inf $msg
}

proc PlayPolyfilt {} {
	global polyf
	if {![info exists polyf(output)] || ![file exists $polyf(output)]} {
		Inf "No output file to play"
		return
	}
	PlaySndfile	$polyf(output) 0
}

proc LoadPolyfiltPatches {} {
	global evv polyf
	catch {unset polyf(patches)}
	foreach fnam [glob -nocomplain [file join $evv(URES_DIR) poly_*]] {
		if {[file isdirectory $fnam]} {
			continue
		}	
		set nam [file rootname [file tail $fnam]]
		set nam [string range $nam 5 end]
		lappend polyf(patches) $nam
	}
	if {[info exists polyf(patches)]} {
		set polyf(patches) [lsort -dictionary $polyf(patches)]
	}
}

proc DisplayPolyfiltOutput {} {
	global polyf evv pa
	if {![info exists polyf(output)] || ![file exists $polyf(output)]} {
		return
	}
	if {![info exists pa($polyf(output),$evv(FTYP))]} {
		if {[DoParse $polyf(output) 0 0 0] <= 0} {
			return
		}
	}
	SnackDisplay 0 $evv(SN_FROM_POLYF_NO_OUTPUT) $evv(TIME_OUT) $polyf(output)
}

proc LoadSelectedPolyfiltPatch {y} {
	global polyf evv
	set i [$polyf(patchlist) nearest $y]
	if {![info exists i] || ($i == -1)} {
		return
	}
	set pachnam "poly_"
	append pachnam [$polyf(patchlist) get $i]
	set pfnam [file join $evv(URES_DIR) $pachnam$evv(CDP_EXT)]
	if {![file exists $pfnam]} {
		Inf "Patch file	$pfnam no longer exists"
		$polyf(patchlist) delete $i
		set polyf(patches) [leplace $polyf(patches) $i $i]
		return
	}
	if [catch {open $pfnam "r"} zit] {
		Inf "Cannot open patch file $pfnam"
		return
	}
	set ccnt 0
	catch {unset items}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] > 0} {
			set line [split $line]
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] > 0} {
					lappend items $item
					incr ccnt
				}
			}
			break
		}
	}
	close $zit
	if {$ccnt != 3} {
		Inf "Bad data in patchfile $pfnam"
		return
	}
	set polyf(pass) [lindex $items 0]
	set polyf(stop) [lindex $items 1]
	set polyf(cnt)  [lindex $items 2]
}

proc RenamePolyfiltData {} {
	global polyf wstk evv pa wl ch chlist rememd
	set snd_delete 0

	set i [$polyf(patchlist) curselection]
	if {![info exists i] || ([llength $i] == 0) || ($i == -1)} {
		Inf "No patch selected for renaming"
		return
	}
	set orignam [$polyf(patchlist) get $i]
	set origpachnam "poly_"
	append origpachnam $orignam
	set origpfnam [file join $evv(URES_DIR) $origpachnam$evv(CDP_EXT)]
	if {![file exists $origpfnam]} {
		Inf "Patch file $origpfnam no longer exists"
		$polyf(patchlist) delete $i
		set polyf(patches) [lreplace $polyf(patches) $i $i]
		return
	}
	if {[string length $polyf(fnam)] <= 0} {
		set msg "No new name entered for patch : delete the existing patch ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		} else {
			if {![AreYouSure]} {
				return
			}
			if [catch {file delete $origpfnam} zit] {
				Inf "Cannot delete existing patch file $origpfnam"
				return
			}
			$polyf(patchlist) delete $i
			set polyf(patches) [lreplace $polyf(patches) $i $i]
		}
		set msg "Delete the related (same name) output file ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		}
		set snd_delete 1
	} else {
		set nunam [string tolower $polyf(fnam)]
		if {![ValidCDPRootname $nunam]} {
			return
		}
		if {[string match $nunam $orignam]} {
			Inf "Name has not changed"
			return
		}
		set nupachnam "poly_"
		append nupachnam $nunam
		set nupfnam [file join $evv(URES_DIR) $nupachnam$evv(CDP_EXT)]

		set kknu [lsearch $polyf(patches) $nunam]
		if {$kknu >= 0} {
			set msg "New patch name already being used : overwrite existing patch ??"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				return
			} else {
				if [catch {file delete $nupfnam} zit] {
					Inf "Cannot overwrite existing patch file $nupfnam"
					return
				}
				set polyf(patches) [lreplace $polyf(patches) $kknu $kknu] 
			}
		}
		if [catch {file rename $origpfnam $nupfnam} zit] {
			Inf "Cannot rename patch $orignam"
			return
		}
		set polyf(patches) [lreplace $polyf(patches) $i $i $nunam]
		set polyf(patches) [lsort -dictionary $polyf(patches)]
		$polyf(patchlist) delete 0 end
		foreach p $polyf(patches) {
			$polyf(patchlist) insert end $p
		}
		set msg "Rename related (same name) output file ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		}
	}
	set i 0
	foreach fnam [$wl get 0 end] {
		if {[string match [file rootname [file tail $fnam]] $orignam]} {
			if {($pa($fnam,$evv(FTYP)) == $evv(SNDFILE)) && ($pa($fnam,$evv(CHANS)) == 1)} {
				if {[info exists matchfnam]} {
					Inf "More than one soundfile with the name $orignam$evv(SNDFILE_EXT) : Cannot proceed"
					return
				}
				set matchfnam $fnam
				set ii $i
			}
		}
		incr i
	}
	if {![info exists matchfnam]} {
		Inf "No mono soundfiles with name $orignam$evv(SNDFILE_EXT) found on the workspace"
		return
	}
	if {$snd_delete} {
		if {[DeleteFileFromSystem $matchfnam 0 1] <= 0} {
			Inf "Cannot delete sound file $matchfnam"
		} else {
			DummyHistory $matchfnam "DESTROYED"
			if {[IsInAMixfile $matchfnam]} {
				if {[MixM_ManagedDeletion $matchfnam]} {
					MixMStore
				}
			}
			if {$ii >= 0} {
				$wl delete $ii
				WkspCnt $matchfnam -1
				catch {unset rememd}
			}
			Inf "Sound file $matchfnam deleted"
		}
		return
	}
	set thisdir [file dirname $matchfnam]
	set dirlen [string length $thisdir]
	if {$dirlen < 2} {
		set thisdir ""
	}
	set nufnam [file join $thisdir $nunam$evv(SNDFILE_EXT)]

	if [catch {file rename $matchfnam $nufnam} zorg] {
		ErrShow "FAILED TO RENAME FILE $matchfnam"
		return
	}
	UpdateBakupLog $matchfnam delete 0
	UpdateBakupLog $nufnam create 1
	CheckMainmixSnd $matchfnam $nufnam
	$wl delete $ii
	$wl insert $ii $nufnam
	RenameProps $matchfnam $nufnam 1
	DummyHistory $matchfnam "RENAMED_$nufnam"
	DataManage rename $matchfnam $nufnam
	if {[MixMRename $matchfnam $nufnam 0]} {
		MixMStore
	}
	set haspmark [HasPmark $matchfnam]
	if {$haspmark} {
		MovePmark $matchfnam $nufnam
	}
	set hasmmark [HasMmark $matchfnam]
	if {$hasmmark} {
		MoveMmark $matchfnam $nufnam
	}
	if [IsInBlists $matchfnam] {
		if [RenameInBlists $matchfnam $nufnam] {
			SaveBL $background_listing
		}
	}
	if [IsOnScore $matchfnam] {
		RenameOnScore $matchfnam $nufnam
	}
	AddToDirlist $nufnam
	if [info exists chlist] {
		set j [lsearch -exact $chlist $matchfnam]
		if {$j >= 0} {
			set jjj [lsearch -exact $chlist $nufnam]
			if {$jjj >= 0} {
				set chlist [lreplace $chlist $j $j]
			} else {
				set chlist [lreplace $chlist $j $j $nufnam]
			}
			$ch delete 0 end
			foreach ff $chlist {
				$ch insert end $ff
			}
		}
	}
	Inf "Renamed related output file"
}

proc DeletePolyfiltOutput {} {
	global polyf evv wstk wl rememd
	if {!$polyf(successful)} {
		Inf "No current outputfile"
		return
	}
	set outfnam [string tolower $polyf(fnam)]
	append outfnam $evv(SNDFILE_EXT)
	if {![string match [$wl get 0] $outfnam]} {
		Inf "Current named file is not the most recent output file"
		return
	}
	set msg "Delete soundfile $outfnam ??"
	set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
	if {$choice == "no"} {
		return
	}
	if {[DeleteFileFromSystem $outfnam 0 1] <= 0} {
		Inf "Cannot delete sound file $outfnam"
	}
	$wl delete 0
	WkspCnt $outfnam -1
	catch {unset rememd}
	Inf "Sound file $outfnam deleted"
}

proc PlayVbankChord {} {
	global wl chlist pa evv prg_dun prg_abortd simple_program_messages CDPidrun
	set midivals {}
	set i [$wl curselection]
	if {([llength $i] == 1) && ($i != -1)} {
		set fnam [$wl get $i]
		if {$pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)} {
			set midivals [IsAFixedHPVaribankFile $fnam]
		}
	}
	if {[llength $midivals] <= 0} {
		if {[info exists chlist] && ([llength $chlist] == 1)} {
			set fnam [lindex $chlist 0]
			if {$pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)} {
				set midivals [IsAFixedHPVaribankFile $fnam]
			}
		}
	}		
	if {[llength $midivals] <= 0} {
		Inf "Select one fixed-harmony midi-varibank data file"
		return
	}
	set mfnam $evv(DFLT_OUTNAME)
	set ofnam $evv(DFLT_OUTNAME)
	append mfnam $evv(TEXT_EXT)
	append	ofnam $evv(SNDFILE_EXT)
	if [catch {open $mfnam "w"} zit] {
		Inf "Cannot open temporary midi-list file to do synthesis"
		return
	}
	foreach val $midivals {
		puts $zit $val
	}
	close $zit

	set cmd [file join $evv(CDPROGRAM_DIR) synth]
	lappend cmd chord 1 $ofnam $mfnam 44100 1 4 -a.3 -t4096
	set prg_dun 0
	set prg_abortd 0
	catch {unset simple_program_messages}
	if [catch {open "|$cmd"} CDPidrun] {
		Inf "Cannot run synthesis process : $cdpidrun"
		catch {unset CDPidrun}
		return
	} else {
		fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
	}
	vwait prg_dun
	if {$prg_abortd} {
		set prg_dun 0
	}
	if {!$prg_dun} {
		set msg "Cannot create synthesized harmonic field"
		set msg [AddSimpleMessages $msg]
		Inf $msg
		return
	}
	if {![file exists $ofnam]} {
		Inf "Failed to create synthesized harmonic field"
		return
	}
	PlaySndfile $ofnam 0
	DeleteAllTemporaryFiles
}



proc IsAFixedHPVaribankFile {fnam} {
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot open file $fnam"
		return {}
	}
	set OK 1
	set line_ccnt 0
	while {[gets $zit line] >= 0} {
		if {[string match [string index $line 0] ";"]} {
			continue
		}
		set c_cnt 0
		set line [split $line]
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {![IsNumeric $item]} {
				set OK 0
				break
			}
			if {[IsEven $c_cnt]} {
				if {$item < 0.0} {
					set OK 0
					break
				}
				if {$c_cnt == 0} {
					if {$line_ccnt == 0} {
						if {$item != 0.0} {
							set OK 0
							break
						}
					} elseif {$item <= $lasttime} {
						set OK 0
						break
					}
					set lasttime $item
				}
			} else {
				if {($item > 127) || ($item < 0)} {
					set OK 0
					break
				}
				lappend midivals $item
			}
			incr c_cnt
		}
		if {!$OK} {
			break
		}
		if {[IsEven $c_cnt]} {
			set OK 0
			break
		}
		incr line_ccnt
	}
	close $zit
	if {!$OK} {
		return {}
	}
	if {$line_ccnt < 2} {
		return {}
	}
	set midivals [lsort -increasing $midivals]
	set midivals [RemoveDuplicates $midivals]
	return $midivals
}
