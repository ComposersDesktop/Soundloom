#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD 30 June 2013
# ... fixup button rectangles

##########################################################
# "INFORMATION", "INFO" & "WHICH?" ON PROCESS MENUS PAGE #
##########################################################

###############
# INFORMATION #
###############

#------ Display Usage Message

proc Display_Usage {} {
	global CDPid usage_done usage_message maxusagelen usagecnt evv
	if [eof $CDPid] {
		set usage_done 1
		catch {close $CDPid}
		return
	} else {
		if {[gets $CDPid line] >= 0} {
			set line [string trim $line]
			set thislen [string length $line]
			if {$thislen > 0} {
				if {$thislen > $maxusagelen} {
					set maxusagelen $thislen
				}
				incr usagecnt
				if [string match INFO:* $line] {
					set line [string range $line 6 end] 
					lappend usage_message "$line"
				} elseif [string match WARNING:* $line] {
					lappend usage_message "$line"
				} elseif [string match ERROR:* $line] {
					lappend usage_message "$line"
					set usage_done 1
					catch {close $CDPid}
				}
			}
		}
	}
}			

proc Display_Gobo_Info {} {
	global CDPid usage_done usage_message evv
	if {[info exists CDPid] && [eof $CDPid]} {
		set usage_done 1
		catch {close $CDPid}
		return
	} else {
		if {[gets $CDPid line] >= 0} {
			set line [string trim $line]
			if [string match INFO:* $line] {
				set line [string range $line 6 end] 
				lappend usage_message "$line"
			} elseif [string match ERROR:* $line] {
				lappend usage_message "$line"
			}
			set usage_done 1
			catch {close $CDPid}
		}
	}
}			

#------ Display user HELP info on specific process

proc CDP_Specific_Usage {prog_no mode_no} {
	global CDPid mmod evv grainversion
	global maxusagelen usagecnt usage_message usage usage_done usage_read tkusage_missing gobo_info

	if {$gobo_info} {
		if {$prog_no == $evv(BATCH) || $prog_no == $evv(INSTRUMENT)} {
			return
		}
		set cmd [file join $evv(CDPROGRAM_DIR) gobosee]
		set cmd [concat $cmd $prog_no]
		set CDPid 0
		set usage_done 0
		catch {unset usage_message}
		if [catch {open "|$cmd"} CDPid] {
			ErrShow "Cannot get gobo information"
			catch {unset CDPid}
		} else {
			fileevent $CDPid readable Display_Gobo_Info		;#	Display info from gobo
			fconfigure $CDPid -buffering line
			if {!$usage_done} {
				vwait usage_done
			}
		}
		if {$usage_done} {
			ReadGoboInfo $usage_message
		}
		return
	}
	if {$prog_no >= $evv(PSEUDO_PROGS_BASE)} {
		set prog_no [PseudoProg $prog_no]
	}
	if {[IsReleaseFiveProg $prog_no]} {
		if {($prog_no == $evv(RRRR_EXTEND)) && ($grainversion >= 8)} {
			set cmd [file join $evv(CDPROGRAM_DIR) tkusage_other]
			set other_usage 1
		} else {
			set cmd [file join $evv(CDPROGRAM_DIR) tkusage]
			set other_usage 0
		}
	} else {
		set cmd [file join $evv(CDPROGRAM_DIR) tkusage_other]
		set other_usage 1
	}
	if {[info exists tkusage_missing] || [ProgMissing $cmd "Cannot get information about this (or any) process."]} {
		set tkusage_missing 1
		return
	}
	set f .usage
	eval {toplevel $f} -borderwidth $evv(SBDR)
	wm protocol $f WM_DELETE_WINDOW {set usage_read 1}
	wm resizable $f 1 1
	wm title $f "Program Information"					
 
	set z [frame $f.z -borderwidth $evv(SBDR)]
	set l [Scrolled_Listbox $f.l -borderwidth $evv(SBDR) -selectmode single]
	button $z.ok -text "OK" -command "set usage_read 1" -width 2 -highlightbackground [option get . background {}]
	label $f.man -text "More detailed information possibly in CDP manual    'CCDPNDEX.HTM'" -fg $evv(SPECIAL)
	pack $f.z -side top -fill x
	pack $z.ok -side top
	pack $f.man -side top
	pack $f.l -side top

	if {$prog_no == $evv(BATCH)} {
		BatchInfo
	} elseif {$prog_no == $evv(INSTRUMENT)} {
		InstrInfo
	} else {
		if {$other_usage} {
			if {$mode_no == 0} {
				set cmd [concat $cmd $prog_no $mode_no]
			} else {
				set cmd [concat $cmd $prog_no [expr $mode_no - 1]]
			}
		} else {
			set cmd [concat $cmd $prog_no]
		}
		set CDPid 0
		set maxusagelen 0
		set usagecnt 0
		set usage_done 0
		catch {unset usage_message}
		if [catch {open "|$cmd"} CDPid] {
			ErrShow "Cannot get help data"
			catch {unset CDPid}
		} else {
			fileevent $CDPid readable Display_Usage		;#	Display info from program
			fconfigure $CDPid -buffering line
			if {!$usage_done} {
				vwait usage_done
			}
		}
	}
	set usage_read 0
	if {$usagecnt > $evv(MAX_LISTBOX_HEIGHT)} {
		set thisheight $evv(MAX_LISTBOX_HEIGHT)
	} else {
		set thisheight $usagecnt
	}
	$l config -width $maxusagelen -height $thisheight

	raise $f
	My_Grab 0 $f usage_read	$z.ok
	foreach line $usage_message {
		$l insert end $line
	}
	catch {unset CDPid}					
	bind $f <Return> {set usage_read 1}
	bind $f <Escape> {set usage_read 1}
	tkwait variable usage_read
	My_Release_to_Dialog $f
	destroy $f
}

########
# INFO #
########

#------ Get information on menu or single program

proc RetrieveInfo {ff} {
	global infstat inslisting ins menupage cdpmenu procmenu_hlp_actv procmenu pim
	global info_hlpstate info_windowstate info_quitstate info_newfstate info_mabostate info_againstate execsflag
	global info_favusestate info_favaddstate info_favallstate info_macrunstate info_macseestate info_macdelstate
	global info_menu info_bg info_fg specific_info pr_descrip prcfrm chosen_men prg retrieve_info_state_saved evv

	# REMOVE ANY POSTED MENU SO HELP-STATE & ACTION-STATE POSTED MENUS ARE NOT CONFUSED

	DePost
	switch -- $infstat {
		0 {
			set infstat 1
#			MacProcessInfoMsg
			# IF THIS IS INITIAL ENTRY TO INFO STATE, REMEMBER STATE, AND DO DISABLING, 

			if {![info exists retrieve_info_state_saved]} {
				catch {unset info_menu}			;# REDUNDANT
				$ff.info config -state disabled

				# DISABLE HELP, REMEMBERING IT'S CURRENT STATE

				set info_hlpstate	 [$pim.help.hlp cget -state]
				set info_windowstate [$pim.help.con cget -state]
				set info_quitstate	 [$pim.help.quit cget -state]
				$pim.help.hlp  config -state disabled
				$pim.help.con  config -state disabled
				$pim.help.quit config -state disabled
				$pim.help.help config -text "$evv(HELP_DEFAULT)" -fg [option get . foreground {}]

				# DISABLE OTHER ACTION BUTTONS, AND SAVE STATE (retain "Which" and "see"(Instruments))

				set info_newfstate   [$pim.topbtns.newf cget -state]
				set info_mabostate   [$pim.topbtns.mabo cget -state]
				set info_againstate  [$pim.topbtns.again cget -state]
				set info_favusestate [$pim.alpha.fav.btns.use cget -state]
				set info_favaddstate [$pim.alpha.fav.btns.add cget -state]
				set info_favallstate [$pim.alpha.fav.btns.all cget -state]
				$pim.topbtns.newf config -state disabled
				$pim.topbtns.mabo config -state disabled
				$pim.topbtns.again config -state disabled
				$pim.alpha.fav.btns.use config -state disabled
				$pim.alpha.fav.btns.add config -state disabled
				$pim.alpha.fav.btns.all config -state disabled
				set info_macrunstate [$pim.alpha.mac.btns.run cget -state]
				$pim.alpha.mac.btns.run config -state disabled
				set info_macseestate [$pim.alpha.mac.btns.see cget -state]
				$pim.alpha.mac.btns.see config -state disabled
				set info_macdelstate [$pim.alpha.mac.btns.del cget -state]
				$pim.alpha.mac.btns.del config -state disabled

				# ENABLE SUPERBUTTONS, AND SAVE STATE

				set i 0
				while {$i < $evv(MAXMENUNO)} {
					if {[winfo exists $pim.alpha.ppp.men.mb$i]} {
						set info_menu($i) [$pim.alpha.ppp.men.mb$i cget -state]
						$pim.alpha.ppp.men.mb$i config -state disabled
						set info_bg($i) [$pim.alpha.ppp.men.mb$i cget -background]
						set info_fg($i) [$pim.alpha.ppp.men.mb$i cget -foreground]
						set info_cmd$i [$pim.alpha.ppp.men.mb$i cget -command] 
						$pim.alpha.ppp.men.mb$i config -bg $evv(HELP) -fg [option get . foreground {}]
					}
					incr i
				}
				set retrieve_info_state_saved 1
			}
			set i 0

			catch {unset ii}
			while {$i < $evv(MAXMENUNO)} {
				if [info exists info_menu($i)] {
					if {$specific_info} {
						$pim.alpha.ppp.men.mb$i config -state normal -command "SetupCurrentMenu $i"
						if {[info exists chosen_men] && [string match $chosen_men $prcfrm.mb$i.menu]} {
							set ii $i
						}
					} else {
						$pim.alpha.ppp.men.mb$i config -state normal -command "FindRelevantProcess $i"
					}
				}
				incr i
			}

			if [info exists ii] {
 				catch {$procmenu config -bg $evv(HELP)}

				if {[info exists chosen_men] && [info exists $chosen_men]} {

							;#	Seems unnecessary, but had a problem once!

					$chosen_men config -bg $evv(HELP)
	 				set yy 0
					foreach j [lrange $cdpmenu($ii) $evv(MENUPROGS_INDEX) end] { ;#	Access each menu program
						if {[IsCrypto $j]} {
							$chosen_men entryconfigure $yy -background $evv(HELP) -command "CryptoMessage $j"
						} else {
							set modecnt [lindex $prg($j) $evv(MODECNT_INDEX)]		;#	modecnt
							$chosen_men entryconfigure $yy -background $evv(HELP)
							if {$modecnt == 0} {									
								$chosen_men entryconfigure $yy -command "CDP_Specific_Usage $j 0"
							} else {												;#	else set up a cascade menu as well
								set kk 0
								while {$kk < $modecnt} {
									$chosen_men.sub$j entryconfigure $kk -command "CDP_Specific_Usage $j $kk" -background $evv(HELP)
									incr kk										;#	and set cascade-menu-buttons' actions
								}
							}
						}
						incr yy
					}
				}
			}

			$ff.info config -text "Action" -bg $evv(EMPH)
			$ff.newf config -bg [option get . background {}]
			$pim.help.help config -bg [option get . background {}]
			$ff.info config -state normal
		}
		1 {
			set infstat 0
			catch {unset retrieve_info_state_saved}
			$ff.info config -state disabled

			# RESTORE SUPERBUTTONS STATE

			set i 0
			while {$i < $evv(MAXMENUNO)} {
				if [info exists info_menu($i)] {
					$pim.alpha.ppp.men.mb$i config -state disabled
					$pim.alpha.ppp.men.mb$i config -bg $info_bg($i) -fg $info_fg($i)
				}
				incr i
			}
			set i 0
			catch {unset ii}
			while {$i < $evv(MAXMENUNO)} {
				if [info exists info_menu($i)] {
					$pim.alpha.ppp.men.mb$i config -state $info_menu($i) -command "SetupCurrentMenu $i"
				}
				if {[info exists chosen_men] && [string match $chosen_men $prcfrm.mb$i.menu] } {
					set ii $i
				}
				incr i
			}
			if [info exists ii] {

#	 	IF POSTED-MENU SELECTED DURING INFO STATE, WAS FOR A NON-EXECUTABLE PROCESS (NO PROGRAM ON SYSTEM),
#		DELETE IT ON RETURNING TO ACTIVE STATE

				if {![string index $execsflag $ii]} {
					if [info exists procmenu] {
						catch {destroy $chosen_men}
						catch {destroy $procmenu}
					}
				} else {
					set chosen_men $prcfrm.mb$ii.menu
#MAY 2001
					if {![catch {$chosen_men config -bg [option get . background {}]} xxij]} {
		 				catch {$procmenu config -bg $evv(ON_COLOR)}
						set yy 0
						foreach j [lrange $cdpmenu($ii) $evv(MENUPROGS_INDEX) end] { ;#	Access each menu program
							set modecnt [lindex $prg($j) $evv(MODECNT_INDEX)]		;#	modecnt
							$chosen_men entryconfigure $yy -background [option get . background {}]
							if {$modecnt == 0} {									
								$chosen_men entryconfigure $yy -command "ActivateProgram $ii $j 0"
							} else {												;#	else set up a cascade menu as well
								set kk 0
								while {$kk < $modecnt} {
									$chosen_men.sub$j entryconfigure $kk -command "ActivateProgram $ii $j $kk" \
										 -background [option get . background {}]
									incr kk										;#	and set cascade-menu-buttons' actions
								}
							}
							incr yy
						}
					}
				}
			}

			# REACTIVATE OTHER ACTION BUTTONS

			$pim.topbtns.newf config -state $info_newfstate
			$pim.topbtns.mabo config -state $info_mabostate
			$pim.topbtns.again config -state $info_againstate
			$pim.alpha.fav.btns.use config -state $info_favusestate
			$pim.alpha.fav.btns.add config -state $info_favaddstate
			$pim.alpha.fav.btns.all config -state $info_favallstate
			$pim.alpha.mac.btns.run config -state $info_macrunstate
			$pim.alpha.mac.btns.del config -state $info_macdelstate
			$pim.alpha.mac.btns.see config -state $info_macseestate

			# REACTIVATE STATE OF HELP

			$pim.help.hlp  config -state $info_hlpstate
			$pim.help.con  config -state $info_windowstate
			$pim.help.quit config -state $info_quitstate

			$ff.info config -text "Info" -bg $evv(HELP)
			$ff.newf config -bg $evv(EMPH)
			if {$procmenu_hlp_actv} {
				$pim.help.help config -bg [option get . activeBackground {}]
			}
			$ff.info config -state normal
			unset info_menu
		}
	}
}

##########
# WHICH? #
##########

#------ Helps user to locate an appropriate process to run
#
#	Input is a word, or a set of words, from user.
#	Use a map from in-words to key-words.
#	Recursively construct list of relevant processes, from found keywords
#	Use list to display description, menu name, and process name, of each relevant process.
#

#------ This program finds relevant progs from text typed in by user or for a single menu

proc FindRelevantProcess {menuno} {
	global prog_list pr_descrip find_process user_query cdpmenu evv
	global query_display_listcnt relevant_query pmask 8chanflag

	set f .find_process									;#	Establish dialog with query entry box
	if [info exists $f]	{
		destroy $f
	}
	eval {toplevel $f} -borderwidth $evv(SBDR)	;#	as a scrolled frame !!!!
	wm protocol $f WM_DELETE_WINDOW {set pr_descrip 1}
	wm resizable $f 1 1
	set prog_list {}									;#	Set list of approp progs to empty

	if {$menuno < 0} {									;#	"WHICH?" option

		wm title $f "Which process?"					
		set z [frame $f.z -borderwidth $evv(SBDR)]
		set z2 [frame $f.z2 -borderwidth $evv(SBDR)]
		label $z.lab -text "Describe what you want to do" -width 28
		entry $z.e -textvariable user_query -width 48
		radiobutton $z.r1 -variable relevant_query -text relevant -value 1
		radiobutton $z.r2 -variable relevant_query -text all -value 0
		button $z.ok -text "Close" -command "set pr_descrip 0" -width 5 -highlightbackground [option get . background {}]
		pack $z.lab $z.e $z.r1 $z.r2 $z.ok -side left
		label $z2.lab -text "Less keywords show MORE processes." -width 34
		pack $z2.lab -side top
		pack $f.z $f.z2 -side top -fill x
		$z.r1 deselect
		$z.r2 deselect

		bind $z.e <Return> {.find_process.z.lab config -text "Relevant process, or all processes?"}
		bind $z.r1 <ButtonRelease-1> {set pr_descrip 1}
		bind $z.r2 <ButtonRelease-1> {set pr_descrip 1}

	} else {											;#	general INFO optin
		wm title $f "MENU [lindex $cdpmenu($menuno) $evv(MENUNAME_INDEX)]"					
		set z [frame $f.z -borderwidth $evv(SBDR)]
		button $z.ok -text "" -command {} -width 4  -highlightbackground [option get . background {}]
		pack $z.ok -side top
		pack $f.z -side top -fill x
	}
	frame $f.cc
	set c [canvas $f.cc.c -width 80 -height 10 -yscrollcommand [list $f.cc.yscroll set]]
	scrollbar $f.cc.yscroll -orient vertical -command [list $f.cc.c yview]
	pack $f.cc.yscroll -side right -fill y
	pack $f.cc.c -side left -fill both -expand true
	pack $f.cc -side top -fill both -expand true
	set ff [frame $c.zorg]
	$c create window 0 0 -anchor nw -window $ff
	frame $ff.sp1 -bg [option get . foreground {}] -width 1
	frame $ff.sp2 -bg [option get . foreground {}] -width 1
	bind $f <Escape> {set pr_descrip 0}

	if {$menuno < 0} {									;#	"WHICH?" option

		set pr_descrip 0							;#	Wait for user to press OK button
		set finished 0
		raise $f
		My_Grab 0 $f pr_descrip $z.e
		tkwait variable pr_descrip

		if {$pr_descrip == 0} {
			My_Release_to_Dialog $f
			destroy $f
			return
		}

		bind $z.r1 <ButtonRelease-1> {}
		bind $z.r2 <ButtonRelease-1> {}
		$z.r1 config -state disabled
		$z.r2 config -state disabled
		set significant_words_cnt 0						
		set uquery [CleanUpInputText [string trim $user_query]]
		set user_query ""
		set user_query [concat $user_query $uquery]
		if {[llength $user_query] <= 0} {
			Inf "No query entered."
			My_Release_to_Dialog $f
			destroy $f
			return
		}
		$z.lab config -text "Searching"					;#	Disable OK button
		foreach word $user_query {						;#	Search user's query for significant words
			set word [string tolower $word]
		  	if [ScanWordKey $word $significant_words_cnt] {
				incr significant_words_cnt
			}							   				;#	And assemble list of possible programs
			if {[llength $prog_list] <= 0} {
				break
			}
		}
		if {$significant_words_cnt == 0} {
			Inf "Sorry, no suggestions with this query."
			My_Release_to_Dialog $f
			destroy $f
			return
		}

		if {$relevant_query} {
			foreach prog_no $prog_list {
				if {$prog_no >= $evv(PSEUDO_PROGS_BASE)} {
					set pseud_prog [PseudoProg $prog_no] 
					if [string index $pmask $pseud_prog] {
						lappend newlist $prog_no
					}
				} elseif [string index $pmask $prog_no] {
					lappend newlist $prog_no
				}
			}
			if {![info exists newlist]} {
				Inf "Sorry, no relevant suggestions with this query."
				My_Release_to_Dialog $f
				destroy $f
				return
			} else {
				set prog_list $newlist
			}
		}

	} else {											;# general INFO option

		set prog_list [lrange $cdpmenu($menuno) $evv(MENUPROGS_INDEX) end]
		if {[llength $prog_list] <= 0} {
			set prog_list -1
		}
		if {$menuno == 17} {	
			set 8chanflag 1
		} else {
			catch {unset 8chanflag}
		}
	}
	set query_display_listcnt 0
	DisplayUserMessageAndMenuIndex $ff					;#	Display list of programs
	set rowcnt $query_display_listcnt
	incr rowcnt $query_display_listcnt
	set child $ff.la2
	tkwait visibility $child
	set bbox [grid bbox $ff 0 0]
	set incr [lindex $bbox 3]
	set width [winfo reqwidth $ff]
	set height [winfo reqheight $ff]
	grid  $ff.sp1 -row 0 -column 1 -rowspan $rowcnt -sticky ns
	grid  $ff.sp2 -row 0 -column 3 -rowspan $rowcnt -sticky ns
	$c config -scrollregion "0 0 $width $height"
	$c config -yscrollincrement $incr
	set height [expr $query_display_listcnt + 1]
	if {$height > 32} {
		set height 32
	}
	set height [expr $height * $incr]
	$c config -width $width -height $height
	if {$menuno < 0} {
		$z.lab config -text "Suggested processes are these"
		$z.e config -state disabled
		$z.ok config -text OK -command "set pr_descrip 1"
		bind $f	<ButtonRelease-1> {HideWindow %W %x %y pr_descrip}
		set pr_descrip 0						
	} else {
		$z.ok config -text OK -command "set pr_descrip 1"
		bind $f	<ButtonRelease-1> {HideWindow %W %x %y pr_descrip}
		set pr_descrip 0
		raise $f
		My_Grab 0 $f pr_descrip $z.ok
	}
	tkwait variable pr_descrip					;#	Wait for user to press OK, then exit
	raise $f
	My_Release_to_Dialog $f
	destroy $f
}

#------ This program accumulates a viable list of progs, from assessment of each key word in turn

proc ResetProgslist {newlen args} {	   			;#	args is the existing list
	global prog_list

	set nulist {}
	foreach item $args {
		if {[lsearch $prog_list $item] >= 0} {
			lappend nulist $item
		}
	}
	set prog_list $nulist
}

proc Alphindex {c} {
	switch -- $c {
		a {return 0}
		b {return 1}
		c {return 2}
		d {return 3}
		e {return 4}
		f {return 5}
		g {return 6}
		h {return 7}
		i {return 8}
		j {return 9}
		k {return 10}
		l {return 11}
		m {return 12}
		n {return 13}
		o {return 14}
		p {return 15}
		q {return 16}
		r {return 17}
		s {return 18}
		t {return 19}
		u {return 20}
		v {return 21}
		w {return 22}
		x {return 23}
		y {return 24}
		z {return 25}
	}
}

proc Indexalph {c} {
	switch -- $c {
		0 {return a}
		1 {return b}
		2 {return c}
		3 {return d}
		4 {return e}
		5 {return f}
		6 {return g}
		7 {return h}
		8 {return i}
		9 {return j}
		10 {return k}
		11 {return l}
		12 {return m}
		13 {return n}
		14 {return o}
		15 {return p}
		16 {return q}
		17 {return r}
		18 {return s}
		19 {return t}
		20 {return u}
		21 {return v}
		22 {return w}
		23 {return x}
		24 {return y}
		25 {return z}
	}
}

#------ Display process-desription, menu-name and process-name at appropriate grid positions.

proc DisplayFoundItem {menuname processname listcnt ff descrip} {
	incr listcnt $listcnt								 		;#	Multiply listposition by 2
	label $ff.la$listcnt -text "[string trim $menuname]"
	label $ff.lb$listcnt -text "[string trim [string toupper $processname]]"
	label $ff.lc$listcnt -text "$descrip"
	grid  $ff.la$listcnt -row $listcnt -column 0 -sticky w		;#	Followed by a line-separator 
	grid  $ff.lb$listcnt -row $listcnt -column 2 -sticky w		;#	as each list entry is textline
	grid  $ff.lc$listcnt -row $listcnt -column 4 -sticky w
	incr listcnt
	frame $ff.f$listcnt -bg [option get . foreground {}] -width 20 -height 1	;#	separator line
	grid  $ff.f$listcnt -row $listcnt -column 0 -columnspan 5 -sticky ew
}

#------ Cleanup a user-input text that may contain multiple spaces (trim it before here!!)

proc CleanUpInputText {args} {
	set i 0
	set words ""
	foreach word $args {
		if {[string length $word] > 0} {
			set words [concat $words $word]
			incr i
		}
	}
	if {$i <= 0} {
		return ""
	}
	return $words
}

#---- Read Effect of gobo

proc ReadGoboInfo {str} {

	if {[string length $str] <= 0} {
		return
	} elseif [string match ERROR* $str] {
		Inf "$str"
		return
	}
	if {[string match [string index $str 41] "1"]} {
		Inf "Process works with ANY file"
		return
	}
	if {[string match 0* $str]} {
		set process_changes_srate 1
	} else {
		set process_changes_srate 0
	}
	set manyfiles 0
	set str [string range $str 1 end]
	if {[string match 100001111111111111111111111111111111111* $str]} {
		Inf "Process works with NO files"
		return
	} elseif {[string match 01000* $str]} {
		set takes_files 1
	} elseif {[string match 01111* $str]} {
		set takes_files 1+
		set manyfiles 1
	} elseif {[string match 00100* $str]} {
		set takes_files 2
		set manyfiles 1
		set twfiles 1
	} elseif {[string match 00111* $str]} {
		set takes_files 2+
		set manyfiles 1
	} elseif {[string match 00010* $str]} {
		set takes_files 3
		set manyfiles 1
	} elseif {[string match 00011* $str]} {
		set takes_files 3
		set manyfiles 1
	}
	if {[string match [string index $str 1] 1]} {
		if {[string match [string range $str 5 38] "1111111111111111111111111111111111"]} {
			if {[string match 01111* $str]} {
				Inf "Process works with any number of any types of files"
			} else {
				Inf "Process works with one file of any type"
			}
			return
		}
	}
	set first_is_sndorsync 0
	set first_is_bintype 0
	set first_is_sndtype 0
	if {[string match [string range $str 5 19] "100000000000000"]} {
		set first_is_bintype 1 
		set firsttype analysis 
	} elseif {[string match [string range $str 5 19] "010000000000000"]} {
		set first_is_bintype 1 
		set firsttype binary_pitch
	} elseif {[string match [string range $str 5 19] "001000000000000"]} {
		set first_is_bintype 1 
		set firsttype binary_transposition
	} elseif {[string match [string range $str 5 19] "000100000000000"]} {
		set first_is_bintype 1 
		set firsttype formant
	} elseif {[string match [string range $str 5 19] "000010000000000"]} {
		set first_is_bintype 1
		set first_is_sndtype 1 
		set firsttype sound
	} elseif {[string match [string range $str 5 19] "000001000000000"]} {
		set first_is_bintype 1 
		set firsttype binary_envelope
	} elseif {[string match [string range $str 5 19] "000000010000000"]} {
		set firsttype pitch_or_transpostion_text
	} elseif {[string match [string range $str 5 19] "000000001000000"]} {
		set firsttype db_envelope_text
	} elseif {[string match [string range $str 5 19] "111111000000000"]} {
		set first_is_bintype 1
		set firsttype sndsys
	} elseif {[string match [string range $str 5 19] "000000000100000"]} {
		set firsttype envelope_text
	} elseif {[string match [string range $str 5 19] "000000000010000"]} {
		set firsttype brk
	} elseif {[string match [string range $str 5 19] "000000000001000"]} {
		set first_is_sndorsync 1 
		set firsttype sndlist
	} elseif {[string match [string range $str 5 19] "000000000000100"]} {
		set first_is_sndorsync 1 
		set firsttype synclist
	} elseif {[string match [string range $str 5 19] "000000000000010"]} {
		set firsttype mixfile
	} elseif {[string match [string range $str 5 19] "000000010110001"]} {
		set firsttype numbers_list
	}
	if {![info exists firsttype]} {
		Inf "Unknown"
		return
	}
	set must_be_same_srate 0
	if {$first_is_sndorsync} {
		set must_be_same_srate [string index $str 21]
	}
	if {$first_is_sndtype} 	{										;#	gobo_25-27
		set chans1 [string range $str 23 25]
		switch -- $chans1 {
			"100" { set chans1 "mono" }
			"010" { set chans1 "stereo" }
			"110" { set chans1 "mono_or_stereo" }
			"111" { set chans1 "any_number_of_channels" }
		}
	}
	set process_changes_srate 0


	if {!$manyfiles} {						
		set msg "Process works with a single "
		if {[info exists chans1]} {
			append msg "$chans1 "
		}
		append msg "$firsttype file"
		if {$must_be_same_srate} {
			append msg "\n(where soundfiles must have the same sample rate)"
		}
		Inf "$msg"
		return
	} else {
		set msg "Process works with $takes_files files.\nFirst file must be a \n"
		if {[info exists chans1]} {
			append msg "$chans1 "
		}
		set msg "$firsttype file\n"
	}
	set last_is_bintype 0
	set last_is_binenv 0

	if {[string match [string range $str 26 30] "00100"]} {
		set lasttype sound
		set last_is_bintype 1 
	} elseif {[string match [string range $str 26 30] "10000"]} {
		set lasttype analysis
		set last_is_bintype 1 
	} elseif {[string match [string range $str 26 30] "00010"]} {
		set lasttype binary_pitch_or_transposition
		set last_is_bintype 1 
	} elseif {[string match [string range $str 26 30] "01000"]} {
		set lasttype formant
		set last_is_bintype 1 
	} elseif {[string match [string range $str 26 30] "00000"]} {
		set lasttype binary_envelope
		set last_is_bintype 1
		set last_is_binenv 1
	} elseif {[string match [string range $str 26 30] "11110"]} {
		set lasttype soundsystem
		set last_is_bintype 1 
	} elseif {[string match [string range $str 26 30] "00001"]} {
		set lasttype envelope_or_dbenvelope_text
	} elseif {[string match [string range $str 26 30] "00101"]} {
		set lasttype envelope_or_dbenvelope_text_or_sound
		set last_is_bintype 1 
	}
	if {[string match [string index $str 37] "1"]} {
		append lasttype "_or_binaryenv_ordbenv"
	}
	append msg "last file must be a $lasttype file\n"
	if {$first_is_bintype} {
		set all_same_type 0
		set all_same_srate 0
		set all_same_chancnt 0
		if {!$first_is_sndtype} {
			set all_same_otherprops 1
		} else {				
			set all_same_otherprops 0
		}
		if {$last_is_bintype} { 
			if {[string match [string index $str 32] "0"]} { set all_same_type 1  }
			if {[string match [string index $str 33] "0"]} { set all_same_srate 1 }
			if {[string match [string index $str 34] "0"]} { set all_same_chancnt 1 }
			if {[string match [string index $str 35] "0"]} { set all_same_otherprops 1 }
		}
		if {$all_same_type} {
			append msg "All files must be of the same type.\n"
		}
		if {$all_same_srate} {
			append msg "All files must be of the same sample rate.\n"
		}
		if {$all_same_chancnt} {
			append msg "All files must be of the same channel count.\n"
		}
		if {$all_same_otherprops} {
			append msg "All files must have all other properties the same.\n"
		}
	}
	Inf "$msg"
}

proc MacProcessInfoMsg {} {
	global specific_info
	if {$specific_info} {
		set msg "Click On A Menu Button For Information, Then Select Process From Drop-down Menu"
		append msg "\n(For General Information About All Menu Processes, Select 'menu' Option)"
		append msg "\n"
		append msg "\n"
		append msg "WARNING for MAC users\n"
		append msg "\n"
		append msg "Using 'Info' button to toggle MANY TIMES AT ONCE\n"
		append msg "between 'Info' and 'Action'\n"
		append msg "and between 'Menu' & 'Process'\n"
		append msg "can cause TK/Tcl to get lost on the MAC,\n"
		append msg "and The Sound Loom hangs.\n"
		append msg "\n"
		append msg "In this situation, restart the Sound Loom again.\n"
		append msg "\n"
	} else {
		set msg "Click On A Menu Button For Information"
		append msg "\n\n(For Specific Information About A Proces, Select 'process' Option)"
	}
	append msg "\n\n                               To Return To Active Mode\nPress The 'Action' Button Which Will Appear When You Quit This Message" 
	Inf $msg
}

proc IsCrypto {n} {
	global cryptoprogs
	if {[info exists cryptoprogs]} {
		set k [lsearch $cryptoprogs $n]
		if {($k >= 0) && [IsEven $k]} {
			return 1
		}
	}
	return 0
}

proc CryptoMessage {n} {
	global cryptoprogs prg evv
	set k [lsearch $cryptoprogs $n]
	incr k
	set m [lindex $cryptoprogs $k]
	Inf "'[lindex $prg($n) $evv(PROGNAME_INDEX)]' CALLS THE PROGRAM '[lindex $prg($m) $evv(PROGNAME_INDEX)]'"
}
