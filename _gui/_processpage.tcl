#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD June 28 2013 
# ... fixup button rectangles



#########################
# PROCESS MENUS PAGE	#
#########################

#------ (Re)display previous process used

proc ReconfigLastProcessDisplay {f} {
	global pprg mmod prg selected_menu cdpmenu ins evv

	if {$ins(was_last_process_used)} {
		if {![info exists ins(name)]} {
			return
		}
		set thistext "Instrument $ins(name)"
	} else {
		if {![info exists selected_menu] || ($pprg < 0)} {		;#	Possible if first process = aborted hst
			return
		}
		set thistext "[lindex $cdpmenu($selected_menu) $evv(MENUNAME_INDEX)]"
		append thistext ": "
		if {[IsMchanToolkit $pprg]} {
			set str [MchanToolKitNames $pprg]
		} else {
			set str [string toupper [lindex $prg($pprg) $evv(PROGNAME_INDEX)]]
		}
		if {$mmod > 0} {
			set mode_index $evv(MODECNT_INDEX)
			incr mode_index $mmod
			append str "...."
			append str [lindex $prg($pprg) $mode_index]
		}
		append thistext $str
	}
	set strlen [string length $thistext]
	incr strlen 4
	$f config -text $thistext -width $strlen -justify left -fg $evv(SPECIAL)
}

#------ Create a listing of existing Instruments, on the menus page

proc CreateInsListing {} {
	global mach inslisting ins evv

	label $mach.lab -text "INSTRUMENTS"
	set mab [frame $mach.btns -borderwidth $evv(SBDR)]		;#	button to run selected ins
	set inslisting [Scrolled_Listbox $mach.mlist -width 24 -height 26 -selectmode single]

	pack $mach.lab $mach.btns $mach.mlist -side top -fill x
	button $mab.run -text "Run" -width 3 -command "GotoRunIns" -highlightbackground [option get . background {}]

	button $mab.see -text "See" -width 3 -command "ViewIns 0" -highlightbackground [option get . background {}]
	button $mab.del -text "Destroy" -command "DestroyIns" -highlightbackground [option get . background {}]
	pack $mab.run $mab.see -side left
	pack $mab.del -side right
	if [info exists ins(names)] {
		foreach mnam $ins(names) {		   	;#	Load existing Instruments (already got from disk
			$inslisting insert end $mnam	;#	to the list 'Instruments') into the display
		}
	}
}

#------ Function for running Instruments, with exception when recycling is in operation (avoid crashes)

proc GotoRunIns {} {
	global ins pr2 in_recycle sl_real mchengineer done_ins_stereo done_ins_stchan

	if {!$sl_real} {
		Inf "Instruments You Create (by Combining Several Processes) Are Listed Here.\nA Single Click On An Instrument In This List Will Launch It."
		return
	}
	if {[info exists mchengineer]} {
		Inf "Instruments Not Available For Multichannel Engineering."
		return
	} elseif {$in_recycle} {
		Inf "For Safety, as files have been recycled,\nReturn to Workspace before Running an Instrument."
	} else {
		set done_ins_stereo 0
		set done_ins_stchan -1
		set ins(run) 1
		set pr2 1
	}
}

#------ Show ins tree
#
#	|-------------------------------
#	|KEY (Color key to tree)		|
#	|-------------------------------|
#	|		 -    -					|
#	|		|1|	 |2|				|
#	|		 -	  -					|
#	|		 |	/					|
#	|		 |/						|
#	|	     ------					|
#	|		|interp|				|
#	|		 ------					|
#									

proc ViewIns {from_parampage} {
	global evv machview_pr machviewpage lastmviewname
	global inslisting tree ins only_looking sl_real

	set tree_drawn 0
	if {$from_parampage} {
		set i 0
		set OK -1
		foreach mname $ins(names) {
			if [string match $mname $ins(name)] {
				set OK $i
				break
			}
			incr i
		}
		if {$OK >= 0} {
			set i $OK
		} else {
			Inf "No information on this instrument."
			return
		}
	} else {
		set i [$inslisting curselection]
		if {[llength $i] <= 0} {
			if {!$sl_real} {
				Inf "Instruments Are Created By Recording A Sequence Of Processes.\nYou Can Display A Diagram Of Your Created Instrument Here.\nThe Display Shows A Stereo Time-stretching Instrument."
				set i 0
			} else {
				Inf "No item selected"
				return
			}
		}
	}
	set mname [lindex $ins(names) $i]
	set ins(this) 	"[lindex $ins(uberlist) $i]"
	set ins(tree)   "[lindex $ins(this) $evv(MSUPER_TREE)]"
	set tree(fnams) "[lindex $ins(this) $evv(MSUPER_FNAMES)]"
	set tree(procnames) "[lindex $ins(this) $evv(MSUPER_PNAMES)]"

	set mm .machviewpage

	if {[info exists $mm] && [info exists lastmviewname] && ![string match $mname $lastmviewname] } {
		destroy $mm 								;#	If not trying to display SAME ins, destroy window
	}												;#	Otherwise window merely re-displayed from last time
	set lastmviewname $mname
	set only_looking 1
 	if [Dlg_Create $mm "Instrument [string toupper $mname]" "set machview_pr 1" -borderwidth $evv(BBDR)] {
		set mmtb [frame $mm.btn    -borderwidth $evv(SBDR)]	;#	Frames for button key & tree-display
		set mmts [frame $mm.scroll -borderwidth $evv(SBDR)]
		set mmtk [frame $mm.key    -borderwidth $evv(SBDR)]
		set mmtt [frame $mm.tree   -borderwidth $evv(SBDR)]
		pack $mm.btn $mm.scroll $mm.key $mm.tree -side top -fill x
		
		button $mmtb.quit -text "OK" -command "set machview_pr 1" -highlightbackground [option get . background {}]
		pack $mmtb.quit -side top
		label $mmts.scr -text "" -width 60 -fg $evv(SPECIAL)
		pack $mmts.scr -side top
	
		DisplayTreeColorKey $mmtk					;#	Creates ColorKey to canvas
													;#	Creates Canvas and draws current ins-tree on it

		set tree(process_cnt) [llength $ins(tree)]
		set can [Scrolled_Canvas $mmtt.c -width $evv(SMALL_WIDTH) \
									-height $evv(SMALLER_HEIGHT) \
							-scrollregion "0 0 $evv(CANVAS_DISPLAYED_WIDTH) $evv(CANVAS_DISPLAYED_HEIGHT)"]

		pack $mmtt.c -fill both -expand true
		bind .machviewpage <ButtonRelease-1> {HideWindow %W %x %y machview_pr}
		bind .machviewpage <Return>  {set machview_pr 1}
		bind .machviewpage <Escape>  {set machview_pr 1}
		bind .machviewpage <Key-space>  {set machview_pr 1}
	}
	wm title $mm "Instrument [string toupper $mname]"

	tkwait visibility .machviewpage.tree.c
	set tree(display_width) [winfo width .machviewpage.tree.c]
	set tree(display_height) [winfo height .machviewpage.tree.c]


	if {[DrawTree .machviewpage.tree.c.canvas]} {
		set machview_pr 0
		raise $mm
		update idletasks
		StandardPosition $mm
		My_Grab 0 $mm machview_pr		
		tkwait variable machview_pr
		My_Release_to_Dialog $mm
		Dlg_Dismiss $mm
	}
	set only_looking 0
}
	
#------ Activate appropriate processes on menus (those that can be run with processes given)

proc ActivateRelevantProcessesOnCurrentMenu {i} {
	global cdpmenu pmask menupage prcfrm submenu_cnt infstat in_recycle sl_real ins chlist pa evv

	set thisend "end"
	set spaceon [SpaceException]
	set crosson [CrossException]
	if {!$sl_real} {
		set thisend [expr $evv(MENUPROGS_INDEX) + 2]
	}
	set submenu_cnt 0
	foreach j [lrange $cdpmenu($i) $evv(MENUPROGS_INDEX) $thisend] {	;#	Access restricted set of programs
		set submenu_cnt [ColourSubmenuSubtitle $prcfrm.mb$i.menu $j $pmask $submenu_cnt]
		if {$j >= $evv(PSEUDO_PROGS_BASE)} {
			set j [PseudoProg $j]
		}
		if {($j == $evv(MOD_SPACE)) && [info exists spaceon]} {
			$prcfrm.mb$i.menu entryconfigure $submenu_cnt -background $evv(ON_COLOR) -foreground black -state normal
		} elseif {($j == $evv(MOD_RADICAL)) && [info exists crosson]} {
			$prcfrm.mb$i.menu entryconfigure $submenu_cnt -background $evv(ON_COLOR) -foreground black -state normal
		} elseif {($j == $evv(P_FIX)) && ![PitchEditorValid ""]} {
			$prcfrm.mb$i.menu entryconfigure $submenu_cnt -background $evv(OFF_COLOR) -state disabled -foreground LightGrey
		} elseif {(($j == $evv(MIXDUMMY)) || ($j == $evv(MIX_AT_STEP)) || ($j == $evv(MIX_ON_GRID))) && ![MixValidChans]} {
			$prcfrm.mb$i.menu entryconfigure $submenu_cnt -background $evv(OFF_COLOR) -state disabled -foreground LightGrey
		} elseif {[string index $pmask $j]} {	;#	(checking against 'pmask' flag) if active, set it ON 
			$prcfrm.mb$i.menu entryconfigure $submenu_cnt -background $evv(ON_COLOR) -foreground black -state normal
		} else {
			$prcfrm.mb$i.menu entryconfigure $submenu_cnt -background $evv(OFF_COLOR) -state disabled -foreground LightGrey
		}
		incr submenu_cnt
	}
	if {([lindex $cdpmenu($i) 0] == "MULTICHAN") && [info exists chlist]} {
		foreach fnam $chlist {
			if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
				$prcfrm.mb$i.menu entryconfigure $submenu_cnt -background $evv(OFF_COLOR) -state disabled -foreground LightGrey
				return
			}
			if {$pa($fnam,$evv(CHANS)) > 8} {
				$prcfrm.mb$i.menu entryconfigure $submenu_cnt -background $evv(OFF_COLOR) -state disabled -foreground LightGrey
				return
			}
		}
		$prcfrm.mb$i.menu entryconfigure $submenu_cnt -background $evv(ON_COLOR) -foreground black -state normal
	}
}

#------ Post the selected supermenu, as the current menu 

proc SetupCurrentMenu {i} {
	global infstat procmenu cdpmenu menupage prg prcfrm chosen_men selected_menu evv
	global current_menu_index sl_real chlist pa panprocess released ins bulk wstk

	set thisend "end"
	if {!$sl_real} {
		set thisend [expr $evv(MENUPROGS_INDEX) + 2]
	}
	set current_menu_index $i
	if [info exists procmenu] {
		destroy $chosen_men
		destroy $procmenu
	}
	set procmenu [menubutton $prcfrm.mb$i -text [lindex $cdpmenu($i) $evv(MENUNAME_INDEX)] -menu $prcfrm.mb$i.menu \
		-width $evv(MAX_PROGNAMEWIDTH) -borderwidth $evv(SBDR) -relief raised -bg $evv(ON_COLOR) -fg black]
#	if {$infstat} {
#		$prcfrm.mb$i config ;# -bg $evv(HELP)
#	}	
	pack $procmenu -side top
	update idletasks
	set chosen_men [menu $prcfrm.mb$i.menu -tearoff 0]
	foreach j [lrange $cdpmenu($i) $evv(MENUPROGS_INDEX) $thisend] {	;#	Access each submenu (program) associated with menu
		if {[IsCrypto $j]} {
			set subm_name [lindex $prg($j) $evv(PROGNAME_INDEX)]	;#	Get its title, and
			if {$infstat} {
				$chosen_men add command -label $subm_name -command "CryptoMessage $j" \
				-background $evv(HELP) -foreground black
			} else {
				$chosen_men add command -label $subm_name -command "ActivateProgram $i $j 0" \
					-background [option get . background {}] -foreground black
			}
			continue
		}
		switch -regexp -- $j \
			^$evv(RRRR_EXTEND)$ {
				set subtitle [GetSubmenuSubtitle $j]
				if {$infstat} {
					$chosen_men add separator -background $evv(HELP) 
					$chosen_men add command -label $subtitle -command {} -background $evv(EMPH) -foreground black
					$chosen_men add separator -background $evv(HELP) 
				} else {
					$chosen_men add separator -background [option get . background {}]
					$chosen_men add command -label $subtitle -command {} -background [option get . background {}] -foreground black
					$chosen_men add separator -background [option get . background {}]
				}
			} \
			^$evv(PITCH)$ - \
			^$evv(P_BINTOBRK)$ - \
			^$evv(P_QUANTISE)$ - \
			^$evv(REPITCH)$ - \
			^$evv(P_FIX)$ - \
			^$evv(P_SYNTH)$ - \
			^$evv(EDIT_EXCISE)$ - \
			^$evv(EDIT_INSERT)$ - \
			^$evv(EDIT_JOIN)$ - \
			^$evv(RANDCUTS)$ - \
			^$evv(NOISE_SUPRESS)$ - \
			^$evv(ENV_IMPOSE)$ - \
			^$evv(ENV_RESHAPING)$ - \
			^$evv(ENV_ENVTOBRK)$ - \
			^$evv(ENV_DOVETAILING)$ - \
			^$evv(TIME_GRID)$ - \
			^$evv(MIX)$ {
				set subtitle [GetSubmenuSubtitle $j]
				if {$infstat} {
					$chosen_men add separator -background $evv(HELP)
					$chosen_men add command -label $subtitle -command {} -background $evv(EMPH) -foreground black
					$chosen_men add separator -background $evv(HELP)
				} else {
					$chosen_men add separator -background $evv(EMPH)
					$chosen_men add command -label $subtitle -command {} -background [option get . background {}] -foreground black
					$chosen_men add separator -background $evv(EMPH)
				}
			} \
			^$evv(GRAIN_COUNT)$ - \
			^$evv(TRNSP)$ - \
			^$evv(EDIT_CUT)$ - \
			^$evv(ENV_CREATE)$ {
				set subtitle [GetSubmenuSubtitle $j]
				if {$infstat} {
					$chosen_men add command -label $subtitle -command {} -background $evv(EMPH) -foreground black
					$chosen_men add separator -background $evv(HELP)
				} else {
					$chosen_men add command -label $subtitle -command {} -background [option get . background {}] -foreground black
					$chosen_men add separator -background $evv(EMPH)
				}
			}

		set subm_name [lindex $prg($j) $evv(PROGNAME_INDEX)]	;#	Get its title, and
		set modecnt [lindex $prg($j) $evv(MODECNT_INDEX)]		;#	modecnt
		if {$modecnt == 0} {									;#	if no modes, set menu-button action
			if {$infstat} {
				$chosen_men add command -label $subm_name -command "CDP_Specific_Usage $j 0"  -foreground black \
				;# -background $evv(HELP)
			} elseif {($j == $evv(P_FIX)) && ![PitchEditorValid ""]} {
				$chosen_men add command -label $subm_name -command "ActivateProgram $i $j 0"  -foreground black \
					-background [option get . background {}] -state disabled
			} elseif {(($j == $evv(MIX_AT_STEP)) || ($j == $evv(MIX_ON_GRID))) && ![MixValidChans]} {
				$chosen_men add command -label $subm_name -command "ActivateProgram $i $j 0"  -foreground black \
					-background [option get . background {}] -state disabled
			} else {
				$chosen_men add command -label $subm_name -command "ActivateProgram $i $j 0"  -foreground black \
					-background [option get . background {}]
			}
		} else {												;#	else set up a cascade menu as well
			if {$infstat} {
				$chosen_men add cascade -label	$subm_name -menu $chosen_men.sub$j  -foreground black \
					;# -background $evv(HELP)
			} else {
				$chosen_men add cascade -label	$subm_name -menu $chosen_men.sub$j  -foreground black \
					-background [option get . background {}]
			}
			set men2 [menu $chosen_men.sub$j -tearoff 0]
			set modeno 1
			if {$infstat} {
				foreach modename [lrange $prg($j) $evv(MODENAMES_BASE) end] {
					$men2 add command -label $modename -command "CDP_Specific_Usage $j $modeno"  -foreground black \
						;# -background $evv(HELP)
					incr modeno										;#	and set cascade-menu-buttons' usage-action
				}
			} elseif {($j == $evv(MIXDUMMY)) && ![MixValidChans]} {
				foreach modename [lrange $prg($j) $evv(MODENAMES_BASE) end] {
					$men2 add command -label $modename -command "ActivateProgram $i $j $modeno"  -foreground black \
						-background [option get . background {}] -state disabled
					incr modeno										;#	and set cascade-menu-buttons' actions
				}
			} else {
				foreach modename [lrange $prg($j) $evv(MODENAMES_BASE) end] {
					$men2 add command -label $modename -command "ActivateProgram $i $j $modeno"  -foreground black \
						-background [option get . background {}]
					incr modeno										;#	and set cascade-menu-buttons' actions
				}
			}
		}
		if {$j == $evv(FRAME)} {									;#	Insert 8 channel interface at foot of MULTICHAN menu
			if {$infstat} {
				$chosen_men add cascade -label "MULTI-CHANNEL STAGING" -menu $chosen_men.eight -background $evv(HELP) -foreground black
				set mfzeight [menu $chosen_men.eight -tearoff 0]
				$mfzeight add command -label "Arrange On Multiphonic Stage" -command {HelpOctStage} -background $evv(HELP) -foreground black
				$mfzeight add command -label "Collapse to Stereo Panorama" -command {HelpDisOctStage N} -background $evv(HELP) -foreground black
				if [info exists released(mchantoolkit)] {
					$chosen_men add command -label "MULTI-CHANNEL TOOLKIT" -command {HelpMCTK} -background $evv(HELP) -foreground black
				}
			} elseif {![info exists panprocess]} {
				$chosen_men add cascade -label "MULTI-CHANNEL STAGING" -menu $chosen_men.eight -foreground black
				set mfzeight [menu $chosen_men.eight -tearoff 0]
				$mfzeight add command -label "Arrange On Multiphonic Stage" -command SetStage -foreground black
				$mfzeight add command -label "Collapse to Stereo Panorama" -command SetDisStage -foreground black
				if {[info exists chlist] && ([llength $chlist] == 1) && ($pa([lindex $chlist 0],$evv(FTYP)) == $evv(SNDFILE))} {
					$chosen_men entryconfigure 7 -state normal -background $evv(EMPH) -foreground black
				} else {
					$chosen_men entryconfigure 7 -background [option get . background {}] -state disabled -foreground black
				}
				if {[info exists released(mchantoolkit)] && [info exists released(mchanpan)]} {
					$chosen_men add separator -background $evv(HELP)
					$chosen_men add command  -label "MULTICHANNEL TOOLKIT" -command {} -background $evv(HELP) -foreground black
					$chosen_men add separator -background $evv(HELP)
					$chosen_men add command  -label "Copy Soundfile, Changing Format" -command {ActivateProgram 0 $evv(COPYSFX) 0} -foreground black
					$chosen_men add separator
					$chosen_men add command  -label "1st Order Ambisonic Pan" -command {ActivateProgram 0 $evv(ABFPAN) 0} -foreground black
					$chosen_men add command  -label "2nd Order Ambisonic Pan" -command {ActivateProgram 0 $evv(ABFPAN2) 0} -foreground black
					$chosen_men add command  -label "2nd Order Periphonic Pan" -command {ActivateProgram 0 $evv(ABFPAN2P) 0} -foreground black
					$chosen_men add command  -label "WAVEX to Ambisonic (unsets lspkr positions)" -command {ActivateProgram 0 $evv(CHXFORMATG) 0} -foreground black
					$chosen_men add command  -label "Decode Ambisonic Format" -command {ActivateProgram 0 $evv(FMDCODE) 0} -foreground black
					$chosen_men add separator
					$chosen_men add command  -label "Extract Chans from Multichan File" -command {ActivateProgram 0 $evv(CHANNELX) 0} -foreground black
					$chosen_men add command  -label "Interleave Channels (WAVEX formats)" -command {ActivateProgram 0 $evv(INTERLX) 0} -foreground black
					$chosen_men add command  -label "Reorder Output Channels" -command {ActivateProgram 0 $evv(CHORDER) 0} -foreground black
					$chosen_men add separator
					$chosen_men add command  -label "lpskr-position mask values for WAVEX" -command {ActivateProgram 0 $evv(CHXFORMATM) 0} -foreground black
					$chosen_men add command  -label "Change WAVEX Speaker Positions mask" -command {ActivateProgram 0 $evv(CHXFORMAT) 0} -foreground black
					$chosen_men add separator
					$chosen_men add command  -label "Check files compatible for Concatenate" -command {ActivateProgram 0 $evv(NJOINCH) 0} -foreground black
					$chosen_men add command  -label "Concenate Files (e.g. for CD Burn)" -command {ActivateProgram 0 $evv(NJOIN) 0} -foreground black
					$chosen_men add command  -label "Mix 2 multichan files of same format" -command {ActivateProgram 0 $evv(NMIX) 0} -foreground black
					$chosen_men add separator
					$chosen_men add command  -label "RMS Power And Level Stats" -command {ActivateProgram 0 $evv(RMSINFO) 0} -foreground black
					$chosen_men add command  -label "File Properties (including WAVEX)" -command {ActivateProgram 0 $evv(SFEXPROPS) 0} -foreground black
					set sndcnt [ChlistIsComptibleSnds]
					switch -- $sndcnt {
						1 {		;#	ONE SNDFILE
							$chosen_men entryconfigure 16 -state normal -background $evv(EMPH) -foreground black
							$chosen_men entryconfigure 17 -background $evv(EMPH)
							$chosen_men entryconfigure 18 -state normal -background $evv(EMPH) -foreground black
							$chosen_men entryconfigure 19 -state normal -background $evv(EMPH) -foreground black
							$chosen_men entryconfigure 20 -state normal -background $evv(EMPH) -foreground black
							$chosen_men entryconfigure 21 -state normal -background $evv(EMPH) -foreground black
							$chosen_men entryconfigure 22 -state normal -background $evv(EMPH) -foreground black
							$chosen_men entryconfigure 23 -background $evv(EMPH)
							$chosen_men entryconfigure 24 -state normal -background $evv(EMPH) -foreground black
							$chosen_men entryconfigure 25 -background [option get . background {}] -state disabled -foreground black
							$chosen_men entryconfigure 26 -state normal -background $evv(EMPH) -foreground black
							$chosen_men entryconfigure 27 -background $evv(EMPH)
							$chosen_men entryconfigure 28 -state normal -background $evv(EMPH) -foreground black
							$chosen_men entryconfigure 29 -state normal -background $evv(EMPH) -foreground black
							$chosen_men entryconfigure 30 -background [option get . background {}]
							$chosen_men entryconfigure 31 -background [option get . background {}] -state disabled -foreground black
							$chosen_men entryconfigure 32 -background [option get . background {}] -state disabled -foreground black
							$chosen_men entryconfigure 33 -background [option get . background {}] -state disabled -foreground black
							$chosen_men entryconfigure 34 -background [option get . background {}]
							$chosen_men entryconfigure 35 -state normal -background $evv(EMPH) -foreground black
							$chosen_men entryconfigure 36 -state normal -background $evv(EMPH) -foreground black
						}
						default {	;#	SEVERAL SNDFILES
							$chosen_men entryconfigure 16 -background [option get . background {}] -state disabled -foreground black
							$chosen_men entryconfigure 17 -background [option get . background {}]
							$chosen_men entryconfigure 18 -background [option get . background {}] -state disabled -foreground black
							$chosen_men entryconfigure 19 -background [option get . background {}] -state disabled -foreground black
							$chosen_men entryconfigure 20 -background [option get . background {}] -state disabled -foreground black
							$chosen_men entryconfigure 21 -background [option get . background {}] -state disabled -foreground black
							$chosen_men entryconfigure 22 -background [option get . background {}] -state disabled -foreground black
							$chosen_men entryconfigure 23 -background [option get . background {}]
							$chosen_men entryconfigure 24 -background [option get . background {}] -state disabled -foreground black
							$chosen_men entryconfigure 25 -background $evv(EMPH) -state normal -foreground black
							$chosen_men entryconfigure 26 -background [option get . background {}] -state disabled -foreground black
							$chosen_men entryconfigure 27 -background [option get . background {}]
							$chosen_men entryconfigure 28 -state normal -background $evv(EMPH) -foreground black
							$chosen_men entryconfigure 29 -background [option get . background {}] -state disabled -foreground black
							$chosen_men entryconfigure 30 -background $evv(EMPH)
							$chosen_men entryconfigure 31 -state normal -background $evv(EMPH) -foreground black
							$chosen_men entryconfigure 32 -state normal -background $evv(EMPH) -foreground black
							$chosen_men entryconfigure 33 -state normal -background $evv(EMPH) -foreground black
							$chosen_men entryconfigure 34 -background $evv(EMPH)
							$chosen_men entryconfigure 35 -background [option get . background {}] -state disabled -foreground black
							$chosen_men entryconfigure 36 -background [option get . background {}] -state disabled -foreground black
						}
					}
				}
			}
		}
	}
	if {$i == $evv(PVOC_MENU)} {
		if {(![info exists ins(create)] || !$ins(create)) && (![info exists ins(run)] || !$ins(run))} { 
			if {[info exists chlist] && ([llength $chlist] == 1)} {
				if {$pa([lindex $chlist 0],$evv(FTYP)) == $evv(ANALFILE)} {
					set qik_pvoc_synth 1
				}
			} elseif {$bulk(run) && [info exists chlist] && ([llength $chlist] >= 1)} {
				if {$pa([lindex $chlist 0],$evv(FTYP)) == $evv(ANALFILE)} {
					set qik_pvoc_synth 1
				}
			}
		}
	} elseif {$i == $evv(CHANS_MENU)} {
		if {(![info exists ins(create)] || !$ins(create)) && (![info exists ins(run)] || !$ins(run))} {
			if {[info exists chlist] && ([llength $chlist] > 1) && ([llength $chlist] <= 16)} {
				if {($pa([lindex $chlist 0],$evv(FTYP)) == $evv(SNDFILE)) && ($pa([lindex $chlist 0],$evv(CHANS)) == 1)} {
					if {!$bulk(run) && (![info exists released(repair)] || ![RepairCompatible [llength $chlist]])} {
						set qik_chan_merge 1
					}
				}
			}
		}
	}
	if {!$infstat} {
		ActivateRelevantProcessesOnCurrentMenu $i
	}
	if {![info exists qik_pvoc_synth] && ![info exists qik_chan_merge]} {
		tkwait visibility $prcfrm.mb$i
		PostMenu $chosen_men
	}
	set selected_menu $i
	if {[info exists qik_pvoc_synth]} {
		ActivateProgram 0 $evv(PVOC_SYNTH) 0
	} elseif {[info exists qik_chan_merge]} {
		ActivateProgram 0 $evv(MIXINTERL) 0
	}
}

#------ Post chosen menu

proc PostMenu {men} {
	global menupage evv
	set w_c [GetWidgetFoot_c $men]
	if {[string length $w_c] <= 0} {
		return
	}
	set x [lindex $w_c 0]
	set y [lindex $w_c 1]
	$men post $x $y
}

#------ Get position of the bottom (left) of a widget

proc GetWidgetFoot_c {men} {
	global evv
	set men [string range $men 1 end]
	set path [split $men "."]
	set win "."
	append win [lindex $path 0]
	set xy [wm geometry $win]
	set win_c [split $xy x+]				;#	geometry of -ves seems to be 269x342+-26+74
	set x [lindex $win_c 2]					;#	Position of window on screen
	set y [lindex $win_c 3]

	set fullwij $win

	set wijlen [llength $path]
	incr wijlen -2
	set path [lrange $path 1 $wijlen]

	foreach wij $path {
		append fullwij "." $wij
#OCTOBER 2001
		if [catch {set jj [winfo geometry $fullwij]} blip] {
			return ""
		}
		set wij_c [split $jj x+]			;#	Width, height and position of widget in containing widget (or window)

		set hj [lindex $wij_c 1]
		set xj [lindex $wij_c 2]
		set yj [lindex $wij_c 3]

		incr x $xj								;#	position of widget relative to screen
		incr y $yj
	}
	incr y $hj									;#	position of widget bottom edge...

	incr x $evv(W_BORDER)					;#	system-dependent adjustments
	incr y $evv(W_BORDER)
	incr y $evv(WTITLE_HITE)
	lappend w_c $x $y
	return $w_c
}


#------ Activate appropriate processes on menus (those that can be run with processes given)

proc ActivateRelevantProcessesOnSupermenu {} {
	global cdpmenu menustate pmask selected_menu prcfrm execsflag bulk pim evv

	set i 0
	set spaceon [SpaceException]
	set radicoff [RadicalException]
	set crosson [CrossException]
	while {$i < $evv(MAXMENUNO)}  {
		if {![info exists cdpmenu($i)]} {
			incr i
			continue
		} elseif {![string index $execsflag $i]} {
			if {[winfo exists $pim.alpha.ppp.men.mb$i]} {
				set mbtn $pim.alpha.ppp.men.mb$i
				$mbtn config -bg $evv(UNAVAILABLE) -state disabled
				set menustate($i) disabled
			}
			if {[info exists selected_menu] && ($selected_menu == $i)} {
				catch {destroy $prcfrm.mb$i}
			}
			incr i
			continue
		}
		set _actv 0							;#	Default menu-state to inactive
		foreach j [lrange $cdpmenu($i) $evv(MENUPROGS_INDEX) end] { ;#	Access each program-number associated with menu
			if {$j >= $evv(PSEUDO_PROGS_BASE)} {
				set j [PseudoProg $j]
			}
			if {($j == $evv(MOD_RADICAL)) && $radicoff} {
				continue
			}
			if [string index $pmask $j] {
				set _actv 1
				break
			}
			if {$spaceon && ($j == $evv(MOD_SPACE))} {
				set _actv 1
				break
			}
			if {$crosson && ($j == $evv(MOD_RADICAL))} {
				set _actv 1
			}
		}
		set mbtn $pim.alpha.ppp.men.mb$i
		if {$_actv} {	
			$mbtn config -bg $evv(ON_COLOR) -fg black -state normal -text [lindex $cdpmenu($i) $evv(MENUNAME_INDEX)]
			set menustate($i) normal
		} else {
			$mbtn config -bg $evv(OFF_COLOR) -fg LightGrey -state disabled
			set menustate($i) disabled
			if {[info exists selected_menu] && ($selected_menu == $i)} {
				catch {destroy $prcfrm.mb$i}
			}
		}
		incr i
	}
}

#------ No ins-process can have a variable number of outfiles

proc ProcessIsNotInsCompatible {} {
	global pprg mmod evv
	set returnval 0

	set mmode $mmod
	incr mmode -1

	switch -regexp -- $pprg \
		^$evv(TRNSP)$ - \
		^$evv(TRNSF)$ {
			if {$mmode == $evv(TRNS_BIN)} {
				set returnval 1
			}
		} \
		^$evv(HOUSE_EXTRACT)$ {
			if {$mmode == $evv(HOUSE_CUTGATE)} {
				set returnval 1
			}
		} \
		^$evv(HOUSE_RECOVER)$ {
			set returnval 1
		} \
		^$evv(TSTRETCH)$ {
			if {$mmode == $evv(TSTR_LENGTH)} {
				set returnval 1
			}
		} \
		^$evv(MOD_PITCH)$ {
			if {$mmode == $evv(MOD_TRANSPOS_INFO) || $mmode == $evv(MOD_TRANSPOS_SEMIT_INFO)} {
				set returnval 1
			}
		} \
		^$evv(HOUSE_EXTRACT)$ {
			if {$mmode == $evv(HOUSE_CUTGATE_PREVIEW)} {
				set returnval 1
			}
		} \
		^$evv(ENV_WARPING)$ - \
		^$evv(ENV_RESHAPING)$ - \
		^$evv(ENV_REPLOTTING)$ {
			if {$mmode == $evv(ENV_PEAKCNT)} {
				set returnval 1
			}
		} \
		^$evv(ENV_EXTRACT)$ {
			if {$mmode == $evv(ENV_EXTRACT_CRYPTO)} {
				set returnval 1
			}
		} \
		^$evv(TWIXT)$ {
			if {$mmode == $evv(TRUE_EDIT)} {
				set returnval 1
			}
		} \
		^$evv(PVOC_EXTRACT)$ 	 - \
		^$evv(REPITCHB)$ 		 - \
		^$evv(ENV_CREATE)$ 		 - \
		^$evv(ENV_ENVTOBRK)$ 	 - \
		^$evv(ENV_ENVTODBBRK)$ 	 - \
		^$evv(ENV_BRKTOENV)$ 	 - \
		^$evv(ENV_DBBRKTOENV)$ 	 - \
		^$evv(ENV_DBBRKTOBRK)$ 	 - \
		^$evv(ENV_BRKTODBBRK)$ 	 - \
		^$evv(HOUSE_SORT)$ 		 - \
		^$evv(HOUSE_DEL)$  		 - \
		^$evv(WINDOWCNT)$  		 - \
		^$evv(CHANNEL)$	   		 - \
		^$evv(FREQUENCY)$  		 - \
		^$evv(LEVEL)$	   		 - \
		^$evv(OCTVU)$	   		 - \
		^$evv(PEAK)$	   		 - \
		^$evv(REPORT)$	   		 - \
		^$evv(PRINT)$	   		 - \
		^$evv(P_INFO)$	   		 - \
		^$evv(P_ZEROS)$	   		 - \
		^$evv(P_SEE)$	   		 - \
		^$evv(P_WRITE)$	   		 - \
		^$evv(FMNTSEE)$	   		 - \
		^$evv(FORMSEE)$	   		 - \
		^$evv(DISTORT_CYCLECNT)$ - \
		^$evv(GRAIN_COUNT)$		 - \
		^$evv(MIXTEST)$			 - \
		^$evv(MIXFORMAT)$		 - \
		^$evv(MIXMAX)$			 - \
		^$evv(FLTBANKC)$		 - \
		^$evv(HOUSE_DISK)$		 - \
		^$evv(SYNTH_WAVE)$	 	 - \
		^$evv(P_GEN)$	 	 	 - \
		^$evv(SYNTH_NOISE)$	 	 - \
		^$evv(PVOC_EXTRACT)$	 - \
		^$evv(SYNTH_SIL)$	 	 - \
		^$evv(INFO_PROPS)$		 - \
		^$evv(INFO_SFLEN)$		 - \
		^$evv(INFO_TIMELIST)$	 - \
		^$evv(INFO_TIMESUM)$	 - \
		^$evv(INFO_TIMEDIFF)$	 - \
		^$evv(INFO_SAMPTOTIME)$	 - \
		^$evv(INFO_TIMETOSAMP)$	 - \
		^$evv(INFO_MAXSAMP)$	 - \
		^$evv(INFO_MAXSAMP2)$	 - \
		^$evv(INFO_LOUDCHAN)$	 - \
		^$evv(INFO_FINDHOLE)$	 - \
		^$evv(INFO_DIFF)$		 - \
		^$evv(INFO_CDIFF)$		 - \
		^$evv(INFO_PRNTSND)$	 - \
		^$evv(INFO_MUSUNITS)$	 - \
		^$evv(UTILS_GETCOL)$	 - \
		^$evv(UTILS_PUTCOL)$	 - \
		^$evv(UTILS_JOINCOL)$	 - \
		^$evv(UTILS_COLMATHS)$	 - \
		^$evv(UTILS_COLMUSIC)$	 - \
		^$evv(UTILS_COLRAND)$	 - \
		^$evv(UTILS_COLLIST)$	 - \
		^$evv(UTILS_COLGEN)$	 - \
		^$evv(FIND_PANPOS)$		 - \
		^$evv(MAKE_VFILT)$		 - \
		^$evv(BATCH_EXPAND)$	 - \
		^$evv(MIX_MODEL)$		 - \
		^$evv(RANDCUTS)$		 - \
		^$evv(TEX_MCHAN)$		 - \
		^$evv(SYNTHESIZER)$		 - \
		^$evv(SPEKLINE)$		 - \
		^$evv(SUBTRACT)$ {
			set returnval 1
		}

	if {$returnval} {
		Inf "Processes with no infiles or a variable number of outfiles, File deletion,\nand various information generating, testing, and data conversion processes\ncan't be used in instruments\n\nThis process is not available."
	}
	return $returnval
}

#------ Establish viability of processes with infiles, then run a process, ins or hst

proc GotoGetAProcess {} {
	global hst no_processes ins processes_will_work blocker pmask chlist evv last_chused panprocess_individ pprg
	global bulk has_saved_at_all last_ch renam sl_real last_choice chused dupl_mix wstk pa panprocess panprocessfnam
	global thumbnailed thumbfile real_chlist bulksplit mchengineer done_ins_stereo done_ins_stchan

	set done_ins_stereo 0
	set done_ins_stchan -1
	if {[ArePhysModFiles 0]} {
		return
	}

	if {[info exists panprocess]} {
		if {$bulk(run)} {
			return
		}
	}
	if {[info exists panprocess] && ($panprocess == 3) && [info exists panprocessfnam]} {
		if {![string match $panprocessfnam [lindex $chlist 0]]} {
			unset panprocess
			unset panprocessfnam
			catch {unset panprocess_individ}
		}
		if {$pprg == $evv(DISTORT_ENV)} {
			set panprocess_individ 1
		}
	}
	if {[info exists thumbnailed]} {
		if ($bulk(run)) {
			return
		}
		if {[IsCorrectThumbnail]} {
			set real_chlist $chlist
			set chlist $thumbfile
		}
		unset thumbnailed
	}
	set processes_will_work 1

	if {[TooManyFiles]} {
		return
	}
	if {$bulk(run)} {
		if {[info exists panprocess]} {
			return
		}
		if {[info exists only_for_mix]} {
			set msg "Duplicate Files On Chosen Files List: Cannot Proceed:\n\nRemove Duplicates ?"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "yes"} {
				ChoiceDelDupls
			}
			return
		} else {
			if {[info exists chlist] && ([llength $chlist] == 1) && ($pa([lindex $chlist 0],$evv(CHANS)) > 2)} {
				if !{[SplitMchanFile [lindex $chlist 0]]} {
					return
				}
			}
		}
	}
	ClearInfileDependentItems						;#	Ensure no memory of previous brktable environment

	set OK 1
	set choicechanged 0

	if {$ins(create)} {								;#	If ins-creation
		if [info exists ins(chlist)] {
			SetChlistChanMap $ins(chlist)		
			if {[info exists chused]} {
				set last_chused $chused
			}
			set chused $ins(chlist)
			SetLastMixfile $ins(chlist)
		} else {
			SetChlistChanMap {}
		}
		if {![info exists ins(last_ch)]} {	;#	If 1st-pass, compare chosen files with ditto for last PROCESS
			if {![info exists last_choice]} {		;#	If none, this is first choice of files
				set choicechanged 1
				set renam 0
			} else {								;#	Otherwise, set up to do comparison with previous PROCESS files
				set ins(last_ch) $last_choice
			}										;#	Otherwise, compare with last ins pass choice of files
		}
		if {!$choicechanged} {						;#	If comparison possible, compare current choice with previous
			if {$renam} {
				set choicechanged 1
			} elseif [info exists ins(chlist)] {
				if {[llength $ins(last_ch)] != [llength $ins(chlist)]} {
					set choicechanged 1
					set renam 0
				} else {
					foreach lc $ins(last_ch) c $ins(chlist) {
						if {![string match $lc $c]} {
							set choicechanged 1
							set renam 0
							break
						}
					}
				}
			}
		}
	} elseif {![info exists mchengineer]} {			;#	if NOT ins-creation, and not multichannel engineering
		if [info exists chlist] {
			SetChlistChanMap $chlist		
			if {[info exists chused]} {
				set last_chused $chused
			}
			set chused $chlist
			SetLastMixfile $chlist
		} else {
			SetChlistChanMap {}
		}
		if [info exists ins(last_ch)] {				;#	if previous file-choice was for a ins
			if {![info exists chlist]} {
				if {[llength $ins(last_ch)] > 0} {
					set choicechanged 1
					set renam 0
				}
			} else {
				if {[llength $ins(last_ch)] != [llength $chlist]} {
					set choicechanged 1
					set renam 0
				} else {
					foreach lc $ins(last_ch) c $chlist {
						if {![string match $lc $c]} {		;#	do comparison this process choice and last ins choice
							set choicechanged 1
							set renam 0
							break
						}
					}
				}
			}
			unset ins(last_ch)						;#	unset ins-lastchoice so next comparison is not with ins
		} else {
			set choicechanged [CheckForChoiceChange] ;#	Normal case : Remember chlist, mark if it's changed

			if {$renam} {							;# -renam- flag says files in list have same name BUT are not same files
				if {$choicechanged == 1} {			;# If names of files have changed, -renam- need no longer be set
					set renam 0						
				}
				set choicechanged 1					;# If names of files have NOT changed, but files in list
			}										;# are different files (-renam- set) 
		}											;# force gobo to run, by setting choicechanged
	}
	if {$bulk(run)} {
		if {!$sl_real} {
			Inf "You Can Apply The Same Sound Process To A Whole List Of Input Files\nProviding They Are All Of The Same Type"
			return
		}
		if {![info exists chlist] || ([llength $chlist] <= 0)} {
			Inf "No files to process"
			return
		}
		if {[info exists bulksplit]} {
			set pmask [OnlyForBulksplit]
		} elseif {$choicechanged || !$bulk(lastrun)} { ;# If change in files or processing-type selected
			set pmask [GetBulkProgsMask]		 ;#	Validate processes for bulk processing
		} else {								 ;#	Otherwise, keep previous pmask, but drop start (spacer) bit
			set pmask [string range $pmask 1 end]
		}
		if {([string length $pmask] <= 0) || [string match $pmask 0]} {		;#	If no processes work with this combo of files
			set processes_will_work 0			;#	flag the Dialog not to display processes
			Inf "No bulk process will work with the files chosen"
			return
		}
		set bulk(lastrun) 1
	} elseif {$dupl_mix} {
		set pmask [OnlyForMix]
		set bulk(lastrun) 0
	} elseif {[info exists panprocess]} {
		switch -- $panprocess {
			1 {
				set pmask [OnlyForPanProcess]
				set bulk(lastrun) 0
			}
			3 {
				set pmask [OnlyForPanProcessPassTwo]
				set bulk(lastrun) 0
			}
		}
	} else {
		if {[info exists mchengineer]} {
			set pmask [OnlyForEngineer]
		} elseif {$choicechanged || $bulk(lastrun) || ![info exists pmask]} { ;# If change in files or processing-type selected
			set pmask [GetProgsmask]			;#	Validate processes for normal processing
		} else {								;#	Otherwise, keep previous pmask, but drop start (spacer) bit
			set pmask [string range $pmask 1 end]
		}
		if [string match $pmask 0] {		;#	If no individual processes are active with given infiles
			if {$hst(active)} {
				if {!$hst(ins)} {		;#	If this is a (non-ins) hst, it won't work: return	
					Inf "This processes will not work with the input file(s) given"
					set hst(active) 0			
					return
				}								;#	If it IS a ins hst, it may work, so continue

			} elseif {$ins(cnt) <= 0}  {	;#	If there are NO Instruments, then nothing will work
				Inf "No processes work with the input file(s) given"
				return							;#	So we return, having failed to proceed
			} else {							;#	But if there ARE Instruments, these might still work
				set processes_will_work 0		;#	So flag the Dialog not to display processes
			}
		}
		set bulk(lastrun) 0
	}
	set woof 0
	set pmask [append woof $pmask]	;#	Program count starts at 1, pmask starts at 0. SORRY!!

	if {$hst(active)} {
		RunHistory							;#	If running a hst, process-menus page not needed, BUT,
		return		   						;#	If hst proves invalid, fall through to Process Menus page.
	}										;#	Only if it succeeds does it return to Workspace page.
	Dlg_Process_and_Ins_Menus
}

#------ Set up the dialog box for the menu of programs

proc Dlg_Process_and_Ins_Menus {} {
	global evv menupage pr2
	global pmask lastpmask bombout processes_will_work ins_rethink
	global mach ins	pprg procmenu_hlp_actv	ins_creation inslisting mach
	global cdpmenu prcfrm favorites favors menu_topbtns specific_info procmenu_emph pr_ins
	global current_menu_index bulk small_screen pim sschange execsflag stage_last disstage_last proc_info_state
	global panprocess panprocessfnam panprocess_individ mchengineer
	global chosen_men procmenu
			
	catch {destroy .cpd}

	set spacnt 0
	set thistype 0
	set rowcnt 0
	set procmenu_hlp_actv 0
	set procmenu_actv 1

	if [Dlg_Create .menupage "Sound Process : (if page is empty, click here)" "set pr2 0 ; set pr_ins $evv(INS_ABORTED)" -borderwidth $evv(BBDR)] {

		if {$small_screen} {
			set can [Scrolled_Canvas .menupage.c -width $evv(SMALL_WIDTH) -height $evv(SMALL_HEIGHT) \
								-scrollregion "0 0 $evv(PROCESS_WIDTH) $evv(SCROLL_HEIGHT)"]
			pack .menupage.c -side top -fill x -expand true
			set f [frame $can.f -bd 0]
			$can create window 0 0 -anchor nw -window $f
			set pim $f
		} else {
			set pim .menupage
		}	

		set help [frame $pim.help -borderwidth $evv(SBDR)]		;#	help frame
		set last [frame $pim.last -borderwidth $evv(SBDR)]		;#	last process frame
		set tb [frame $pim.topbtns -borderwidth $evv(SBDR)]	;#	master buttons to quit or repeat
		set menu_topbtns $tb
		set inname [frame $pim.inpname]

		label $last.1 -text ""	-width 15
		label $last.2 -text "" -fg $evv(SPECIAL)

		label $inname.lab1 -text "   Last Process Used:   "
		label $inname.lab2 -text "NONE" -fg $evv(SPECIAL)

		button $inname.previous -text "Recent Processes" -command RerunRecentProgram -width 20 -highlightbackground [option get . background {}]
		pack $inname.previous $inname.lab1 $inname.lab2 -side left
		frame $pim.spac  -width 1 -bg [option get . foreground {}]
		set alp [frame $pim.alpha -borderwidth $evv(SBDR)]
		pack $pim.help $pim.last $pim.topbtns $pim.inpname $pim.spac $pim.alpha -side top -fill both

		#	HELP AND QUIT

		button $help.hlp -text Help -command "ActivateHelp $pim.help" -width 4  -highlightbackground [option get . background {}];# -bg $evv(HELP)
		button $help.kk -text "K" -bg $evv(HELP) -command "Shortcuts processpage" -width 2 -highlightbackground [option get . background {}]
		label  $help.conn -text "" -width 13
		button $help.con -text "" -borderwidth 0 -state disabled -width 8 -highlightbackground [option get . background {}]
		label  $help.help -width 84 -text "$evv(HELP_DEFAULT)" -fg [option get . foreground {}]
		if {$evv(NEWUSER_HELP)} {
			button $help.starthelp -text "New User Help" -command "GetNewUserHelp process" ;# -bg $evv(HELP)
		}
		button $help.quit -text "End Session" -command "DoWkspaceQuit 0 0"  -highlightbackground [option get . background {}];# -bg $evv(QUIT_COLOR)
		bind .menupage <Control-Command-Escape> "DoWkspaceQuit 0 0"
# MOVED TO LEFT
		pack $help.quit -side left
		if {$evv(NEWUSER_HELP)} {
			pack   $help.hlp $help.kk $help.conn $help.con $help.help $help.starthelp -side left
		} else {
			pack   $help.hlp $help.kk $help.conn $help.con $help.help -side left
		}
# MOVED TO LEFT
#		pack $help.quit -side right

		#	LAST PROCESS DISPLAY

		label $last.4 -text "IF PROCESS NOT DISPLAYED\nCheck Files On Chosen List"
		button $last.3 -text "See Chosen Files" -command SeeChosen -highlightbackground [option get . background {}]
		pack $last.4 $last.3 -side left -padx 2
		pack $last.1 $last.2 -side left

		#	SOUND PROCESS MENUS: OPERATIONAL BUTTONS

		button $tb.newf -text "To Wkspace : New Files" -width 20 -command "ReturnToWorkspace" -highlightbackground [option get . background {}]

		button $tb.again -text "Use Process Again" -width 20 -command "RerunProgram" -highlightbackground [option get . background {}]
		button $tb.info -text "Info" -width 6 -command {RetrieveInfo $pim.topbtns}  -highlightbackground [option get . background {}];# -bg $evv(HELP)
		radiobutton $tb.infom -variable specific_info -text "menu" -value 0 -command {SwitchInfo 0}
		radiobutton $tb.infop -variable specific_info -text "process" -value 1 -command {SwitchInfo 1}

		button $tb.find -text "Which?"	           -command "FindRelevantProcess -1"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
		button $tb.mabo -text "" -width 22 -command "AbandonIns" -state disabled -borderwidth 0 -highlightbackground [option get . background {}]
		button $tb.tips -text "Tips" -command "Tips ppg"   -highlightbackground [option get . background {}];# -bg $evv(HELP)
		button $tb.nbk -text "Notebook" -width 8 -command NnnSee  -highlightbackground [option get . background {}];# -bg $evv(HELP)
		button $tb.clc -text "Calculator" -width 8 -command "MusicUnitConvertor 0 0"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
		button $tb.ref -text "Reference" -width 8 -command "RefSee 0"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
		pack $tb.again $tb.newf $tb.info $tb.infom $tb.infop $tb.find $tb.mabo -side left
		pack $tb.clc $tb.ref $tb.nbk $tb.tips -side right

		set prcfrm [frame $alp.qqq -borderwidth $evv(SBDR)]	;#	frame for process-menu
					frame $alp.spac -width 1 -bg [option get . foreground {}]			;#	space
		set plop   [frame $alp.ppp -borderwidth $evv(SBDR)]		;#	frame for master-menu
					frame $alp.spc2 -width 1 -bg [option get . foreground {}]			;#	space
		set fav   [frame $alp.fav -borderwidth $evv(SBDR)]		;#	frame for favorite processes
		set mach  [frame $alp.mac -borderwidth $evv(SBDR)]		;#	frame for Instruments listing

		pack $alp.qqq $alp.spac $alp.ppp $alp.spc2 $alp.fav $alp.mac -side left -fill both

		set p [frame $plop.men -borderwidth $evv(SBDR)]		;#	frame for master-menu

		pack $plop.men -side top -fill both



		label $prcfrm.title -text "CURRENT MENU" -width [expr $evv(MAX_PROGNAMEWIDTH) + 2]
		pack $prcfrm.title -side top
	
		set i 2
		set allcols 1
		while {$i <= $evv(MENU_COLCNT)} {
			set allcols [expr $allcols * $i]
			incr i
		}
		set halfway [expr $allcols / 2]
		set colcell [expr $allcols / $evv(MENU_COLCNT)]
		if {$processes_will_work} {

		# LAYING OUT THE MENU-BUTTONS ON A GRID

			set i 0
			set gotfirst 0
			set colcnt 0
			set rowdone 0
			label $p.title -text "AVAILABLE PROCESS MENUS"		;#	Ubertitle line only
			grid $p.title -row $rowcnt -column 0 -columnspan $allcols -sticky ew

			incr rowcnt
			
			while {$i <= $evv(MAXMENUNO)}  {
				if {![info exists cdpmenu($i)]} {	;#	Ignore any non-existent menus
					incr i
					continue
				}
				if {![string index $execsflag $i]} {	;#	skip any non-operational menus
					if {!$gotfirst} {
						set thistype [lindex $cdpmenu($i) $evv(MENUTYPE_INDEX)]
						label $p.lab$spacnt -text $thistype		;#	Title line only
						grid $p.lab$spacnt -row $rowcnt -column 0 -columnspan $allcols -sticky ew
						incr spacnt								
						incr rowcnt
						set gotfirst 1
					}
					incr i
					continue
				}
				if {!$gotfirst} {
					set thistype [lindex $cdpmenu($i) $evv(MENUTYPE_INDEX)]
					label $p.lab$spacnt -text $thistype		;#	Title line only
					grid $p.lab$spacnt -row $rowcnt -column 0 -columnspan $allcols -sticky ew
					incr spacnt								
					incr rowcnt
					set gotfirst 1
				} else {
					set newtype [lindex $cdpmenu($i) $evv(MENUTYPE_INDEX)]
					if {![string match $thistype $newtype]} {
						set thistype $newtype
						set rowdone 2
					}
				}
				if {!$rowdone} {
					if {$colcnt >= $evv(MENU_COLCNT)} {		;#	Once a columnfull of buttons is ready
						set rowdone 1
					}		
				}
				if {$rowdone > 0} {							;#	Once a row is ready
					set cnt [llength $button_list]
					set colcentr [expr ($cnt * $colcell) / 2]
					set colstart [expr $halfway - $colcentr]
					foreach n $button_list {				;#	Construct command to generate grid row
						set cmd grid						
						set thisbutton "\$b"
						append thisbutton $n
						set cmd [concat $cmd $thisbutton]
						set cmd [concat $cmd -row $rowcnt -column $colstart -columnspan $colcell -padx 1 -pady 1]
						if [ catch {eval $cmd} zonk] {		;#	Set the listed buttons out on the grid
							ErrShow $zonk
							BombOut
							return
						}
						incr colstart $colcell
					}
					incr rowcnt
					catch {unset button_list}				;#	and destroy that list (row) of button-numbers
					if {$rowdone > 1} {
						frame $p.spacer$spacnt -bg [option get . foreground {}] -height 1
						grid $p.spacer$spacnt -row $rowcnt -column 0 -columnspan $allcols -pady 6 -sticky ew
						incr spacnt							;#	If current menu group completed, add spacing line
						incr rowcnt
						label $p.lab$spacnt -text $thistype
						grid $p.lab$spacnt -row $rowcnt -column 0 -columnspan $allcols -sticky ew
						incr rowcnt
					}
					set colcnt 0							;#	Start counting columns again for the next row
					set rowdone 0
				}

			# STORE BUTTON NUMBERS AND CONSTRUCT MENU and SUBMENU ITEMS, READY FOR GRIDDING
			# AT SETUP, ALL MENUBUTTONS ARE INACTIVE
	
				lappend button_list $i					;#	Add current button no. to buttons made so far in this row
				incr colcnt								;#	Count columns in this row
	
				set b$i [button $p.mb$i -text [lindex $cdpmenu($i) $evv(MENUNAME_INDEX)] \
									-bg $evv(OFF_COLOR) -fg LightGrey -width $evv(MENU_MAXNAME) \
									-borderwidth $evv(SBDR) -command "SetupCurrentMenu $i" -state disabled  -highlightbackground [option get . background {}]]
				incr i
			}
			if {$colcnt > 0} {								;#	If any buttons remains, undisplayed on grid
				set cnt [llength $button_list]
				set colcentr [expr ($cnt * $colcell) / 2]
				set colstart [expr $halfway - $colcentr]
				foreach n $button_list {					;#	Construct command to generate grid row
					set cmd grid						
					set thisbutton "\$b"
					append thisbutton $n
					set cmd [concat $cmd $thisbutton]
					set cmd [concat $cmd -row $rowcnt -column $colstart -columnspan $colcell -padx 1 -pady 1]
					if [ catch {eval $cmd} zonk] {			;#	Set the listed buttons out on the grid
						ErrShow $zonk
						BombOut
						return
					}
					incr colstart $colcell
				}
				catch {unset button_list}
				set colcnt 0						
			}
		} else {
			if {$ins(cnt) > 0} {
				set item ": TRY INSTRUMENTS"
			} else {
				set item ""
			}
			message $p.none -text "NO PROCESSES WILL WORK WITH GIVEN INPUT FILES $item" -foreground $evv(ERR_COLR)
			grid $p.none -row 0 -column 0 -columnspan $evv(MENU_COLCNT) -sticky news
		}

		label $fav.title -text "FAVOURITES"
		frame $fav.btns -borderwidth $evv(SBDR)
		set favors [Scrolled_Listbox $fav.ll -width 38 -height 26 -selectmode single]

		pack $fav.title $fav.btns $fav.ll -side top
		button $fav.btns.use -text "Use" -command RunFavorite -width 6 -highlightbackground [option get . background {}]
		button $fav.btns.add -text "Add Last Process" -borderwidth $evv(SBDR) -command AddFavorite -width 16 -highlightbackground [option get . background {}]
		button $fav.btns.all -text "See All" -borderwidth $evv(SBDR) -command "SeeAllFavorites $fav.btns" -width 7 -highlightbackground [option get . background {}]
		pack $fav.btns.use $fav.btns.add -side left
		pack $fav.btns.all -side right

		#	INSTRUMENT LISTING

		CreateInsListing
		wm resizable .menupage 1 1

		bind .menupage <Control-Key-P> {UniversalPlay menupage 0}
		bind .menupage <Control-Key-p> {UniversalPlay menupage 0}
		bind .menupage <Key-space>	   {UniversalPlay menupage 0}
#		bind .menupage <Control-Key-m> {GoDirectToMix}
#		bind .menupage <Control-Key-M> {GoDirectToMix}

		bind .menupage <Command-Key-1> {GodoProcess 1 0}
		bind .menupage <Command-b> {GodoProcess b 0}
		bind .menupage <Command-B> {GodoProcess b 0}
		bind .menupage <Command-c> {GodoProcess c 0}
		bind .menupage <Command-C> {GodoProcess c 0}
		bind .menupage <Control-Command-c> {GodoProcess c 1}
		bind .menupage <Control-Command-C> {GodoProcess c 1}
		bind .menupage <Command-d> {GodoProcess d 0}
		bind .menupage <Command-D> {GodoProcess d 0}
		bind .menupage <Control-Command-d> {GodoProcess d 1}
		bind .menupage <Control-Command-D> {GodoProcess d 1}
		bind .menupage <Command-e> {GodoProcess e 0}
		bind .menupage <Command-E> {GodoProcess e 0}
		bind .menupage <Command-Key-#> {GodoProcess e 1}
		bind .menupage <Control-e> {GodoProcess e 2}
		bind .menupage <Control-E> {GodoProcess e 2}
		bind .menupage <Command-f> {GodoProcess f 0}
		bind .menupage <Command-F> {GodoProcess f 0}
		bind .menupage <Control-Command-f> {GodoProcess f 1}
		bind .menupage <Control-Command-F> {GodoProcess f 1}
		bind .menupage <Command-g> {GodoProcess g 0}
		bind .menupage <Command-G> {GodoProcess g 0}
		bind .menupage <Control-Command-g> {GodoProcess g 1}
		bind .menupage <Control-Command-G> {GodoProcess g 1}
		bind .menupage <Command-h> {GodoProcess h 0}
		bind .menupage <Command-H> {GodoProcess h 0}
		bind .menupage <Control-Command-h> {GodoProcess h 1}
		bind .menupage <Control-Command-H> {GodoProcess h 1}
		bind .menupage <Command-i> {GodoProcess i 0}
		bind .menupage <Command-I> {GodoProcess i 0}
		bind .menupage <Command-j> {GodoProcess j 0}
		bind .menupage <Command-J> {GodoProcess j 0}
		bind .menupage <Command-k> {GodoProcess k 0}
		bind .menupage <Command-K> {GodoProcess k 0}
		bind .menupage <Command-l> {GodoProcess l 0}
		bind .menupage <Command-L> {GodoProcess l 0}
		bind .menupage <Command-m> {GodoProcess m 0}
		bind .menupage <Command-M> {GodoProcess m 0}
		bind .menupage <Command-n> {GodoProcess n 0}
		bind .menupage <Command-N> {GodoProcess n 0}
		bind .menupage <Control-m> {GodoProcess m 2}
		bind .menupage <Control-M> {GodoProcess m 2}
		bind .menupage <Command-p> {GodoProcess p 0}
		bind .menupage <Command-P> {GodoProcess p 0}
		bind .menupage <Control-Command-p> {GodoProcess p 1}
		bind .menupage <Control-Command-P> {GodoProcess p 1}
		bind .menupage <Command-r> {GodoProcess r 0}
		bind .menupage <Command-R> {GodoProcess r 0}
		bind .menupage <Control-Command-r> {GodoProcess r 1}
		bind .menupage <Control-Command-R> {GodoProcess r 1}
		bind .menupage <Command-s> {GodoProcess s 0}
		bind .menupage <Command-S> {GodoProcess s 0}
		bind .menupage <Control-Command-s> {GodoProcess s 1}
		bind .menupage <Control-Command-S> {GodoProcess s 1}
		bind .menupage <Command-t> {GodoProcess t 0}
		bind .menupage <Command-T> {GodoProcess t 0}
		bind .menupage <Control-Command-t> {GodoProcess t 1}
		bind .menupage <Control-Command-T> {GodoProcess t 1}
		bind .menupage <Command-v> {GodoProcess v 0}
		bind .menupage <Command-V> {GodoProcess v 0}
		bind .menupage <Control-Command-v> {GodoProcess v 1}
		bind .menupage <Control-Command-V> {GodoProcess v 1}
		bind .menupage <Command-w> {GodoProcess w 0}
		bind .menupage <Command-W> {GodoProcess w 0}
		bind .menupage <Command-x> {GodoProcess x 0}
		bind .menupage <Command-X> {GodoProcess x 0}
		bind .menupage <Control-Command-x> {GodoProcess x 1}
		bind .menupage <Control-Command-X> {GodoProcess x 1}
		bind .menupage <Command-z> {GodoProcess z 0}
		bind .menupage <Command-Z> {GodoProcess z 0}
		bind .menupage <Control-Command-z> {GodoProcess z 1}
		bind .menupage <Control-Command-Z> {GodoProcess z 1}

		bind .menupage <Escape> "set pr2 0 ; set pr_ins $evv(INS_ABORTED)"
		bind $pim <Control-Key-f> {Show_Props processpage 0}
		bind $pim <Control-Key-F> {Show_Props processpage 0}
		bind $pim <Control-Key-c> {Show_Props processpage chans}
		bind $pim <Control-Key-C> {Show_Props processpage chans}
	}
	if {$small_screen} {
		set pim .menupage.c.canvas.f
	} else {
		set pim .menupage
	}	
	if {$ins_creation} {
		$pim.topbtns.mabo config -text "Abandon Instrument" \
			-command AbandonIns -state normal -borderwidth $evv(SBDR)
		$mach.btns.run config -state disabled
		$pim.topbtns.newf config -text "Get New Files"
	} else {
		$pim.topbtns.mabo config -text "" -state disabled -borderwidth 0
		if {$bulk(run)} {
			$mach.btns.run config -state disabled
		} else {
			$mach.btns.run config -state normal -text "Run"
		}
		if {[info exists mchengineer]} {
			$pim.topbtns.newf config -text "To Engineering"
		} else {
			$pim.topbtns.newf config -text "To Wkspace : New Files"
		}
	}

 	set in_name [GetInfileName]
	if {[string length $in_name] > 0} {

		$pim.last.1 config -text "      PROCESSING FILE:      " -fg [option get . foreground {}]
		$pim.last.2 config -text $in_name
	} else {
		$pim.last.1 config -text "NO INPUT FILE" -fg $evv(SPECIAL)
		$pim.last.2 config -text ""
	}
	bind $pim <Return> {PossiblyRerunProgram}
	bind $pim <Left> {}
	bind $pim <Right> {}
	bind $pim <Left> {GetProcInfo}
	bind $pim <Right> {GetProcInfo}
	set proc_info_state 0
	raise .menupage
	update idletasks
	StandardPosition .menupage
	wm resizable .menupage 1 1
	catch {unset procmenu_emph}
	if {$ins(was_last_process_used)} {
		$pim.topbtns.again config -text "Use Instrument Again" -state normal -bg $evv(EMPH)
		lappend procmenu_emph $pim.topbtns.again
	} elseif {([info exists pprg] && ($pprg > 0) \
	&& ($pprg <= [string length $pmask]) && [string index $pmask $pprg]) || [info exists stage_last]|| [info exists disstage_last]} {
		$pim.topbtns.again config -text "Use Process Again" -state normal -bg $evv(EMPH)
		lappend procmenu_emph $pim.topbtns.again
	} else {
		$pim.topbtns.again config -state disabled -bg [option get . background {}]
	}

	if {[info exists favorites] && ([llength $favorites] > 0)} {
		DisplayFavorites
	}

	if {$sschange || ![string match $pmask $lastpmask] || [ChanShift]} {
		if {$pmask != 0} {
		 	ActivateRelevantProcessesOnSupermenu
			if {$current_menu_index >= 0 && [info exists $prcfrm.mb$current_menu_index.menu]} {
				ActivateRelevantProcessesOnCurrentMenu $current_menu_index
			}
		}
		set sschange 0
	}
	if {($pprg != 0) && ![IsMchanToolkit $pprg]} {
		ReconfigLastProcessDisplay $pim.inpname.lab2
	}
	set specific_info 0
	set pr2 2
	set finished 0
	set firsttime 1
	# AWAIT USER INPUT : RUN PROCESS OR QUIT WINDOW

	My_Grab 0 .menupage pr2
	MACMessage 2
	while {!$finished} {
		tkwait variable pr2					;#	wait for pr2 to be set by button-press
		switch -- $pr2 {
			1 {
#DECIDED TO RUN CDP PROCESS
				if {$ins(create)} {
					if [ProcessIsNotInsCompatible] {
						continue			   			
					} elseif {$ins(run)} {
						Inf "You cannot run an existing instrument whilst creating a new instrument."
						set ins(run) 0
						continue
					}
				}
				set ins(early_abort) 0
				set ins(was_penult_process) $ins(was_last_process_used)
				if {$ins(run)} {
					set ins(was_last_process_used) 1
					RunIns		  				;#	Run a ins (stored in Instrumentdata-"arrays")
				} else {							;#	Run a single process
					set ins(was_last_process_used) 0

					if {![DisambiguateProcess]} {
						continue
					}

					RememberLastProcess
					GotoProgram	 					;#	Uses vals of $pprg $mmod, either set here, or pre-existing
				}
				if {$bombout} {						;#	even if program fails, dialog does not fail
# PROCESS HAS BOMBED OUT						;#	UNLESS it bombs out
					set finished 1					
				} elseif {[info exists mchengineer]} {
					set finished 1
				} elseif {$pr2 == 0 || ($ins(create) && $ins(thisprocess_finished))} {
# QUIT HAS BEEN ACTIVATED ON PARAMS PAGE OR ONE PROCESS HAS SUCCEEDED FOR A INSTRUMENT 
					set lastpmask $pmask 	;#	Remember the last state of programs-active-mask
												;#	returns to workspace and quits						
					set finished 1 				;#	OR Forces return to ins-dialog after every SINGLE completed process
				}								;#	Details of process have been saved elsewhere
							
				if {$firsttime  && !$ins(early_abort)} {
					if {$ins(was_last_process_used)} {
						$pim.topbtns.again config -text "Use Instrument Again" -state normal -bg $evv(EMPH)
					} else {
						$pim.topbtns.again config -text "Use Process Again" -state normal -bg $evv(EMPH)
					}
					lappend procmenu_emph $pim.topbtns.again
					set firsttime 0
				}

# ELSE PROCESS HAS SUCCEEDED OR FAILED, BUT NOT BOMBED OUT: JUST CONTINUE

				if {!$ins(early_abort)} {
					ReconfigLastProcessDisplay $pim.inpname.lab2
				}
			}
			0 {
# DECIDED NOT TO RUN ANY PROCESS
				set lastpmask $pmask		;#	Remember the last state of programs-active-mask
				set finished 1						;#	Get ready to return
			}
			default {
# NON-CDP PROCESS HAS RUN AND WILL RETURN DIRECTLY TO WORKSPACE
				if {[info exists stage_last] || [info exists disstage_last]} {
					if [info exists procmenu] {
						destroy $chosen_men
						destroy $procmenu
					}
					$pim.topbtns.again config -text "Use Process Again" -state normal -bg $evv(EMPH)
					set finished 1
				}
			}
		}
	}
	if {[info exists panprocess]} {
		if {$panprocess == 2} {
			incr panprocess
		} elseif {$panprocess == 3} {
			unset panprocess
			unset panprocessfnam
			catch {unset panprocess_individ}
		}
	}
	set bulk(run) 0
	My_Release_to_Dialog .menupage				;#	Return to calling dialog
	Dlg_Dismiss .menupage						;#	Quit dialog (saved to background)
}

#------ Deal with processes whose modes accept diferent numbers or types of files
#
#		If number or type of files changes, we cannot run the same MODE of the program
#

proc DisambiguateProcess {} {
	global pprg mmod ins chlist pa bulk evv in_recycle

	set mmode $mmod
	incr mmode -1

	if {($pprg == $evv(BRASSAGE)) || ($pprg == $evv(SAUSAGE))} {
		if [info exists chlist] {
			set fnam [lindex $chlist 0]
			if {$pa($fnam,$evv(CHANS)) > 2} {
				Inf "Works with mono or stereo files only"
				return 0
			}
		} else {
			return 0
		}
	}
	if {$bulk(run)} {
		switch -regexp -- $pprg \
			^$evv(MOD_RADICAL)$ {
				if {$mmode == $evv(MOD_CROSSMOD)} {
					Inf "Bulk processing does not work with this mode"
					return 0
				}
			} \
			^$evv(MOD_LOUDNESS)$ {
				if {$mmode == $evv(LOUDNESS_BALANCE) \
				||  $mmode == $evv(LOUDNESS_LOUDEST) \
				||  $mmode == $evv(LOUDNESS_EQUALISE)} {
					Inf "Bulk processing does not work with this mode"
					return 0
				}
			} \
			^$evv(HOUSE_COPY)$ {
				if {$mmode == $evv(DUPL)} {
					Inf "Bulk processing does not work with this mode"
					return 0
				}
			} \
			^$evv(HOUSE_CHANS)$ {
				set multichans 0
				set havestereo 0
				set havemono 0
				if [info exists chlist] {
					foreach fnam $chlist {
						if {$pa($fnam,$evv(CHANS)) > 2} {
							set multichans 1
						} elseif {$pa($fnam,$evv(CHANS)) == 2} {
							set havestereo 1
						} else {
							set havemono 1
						}
					}
				}
				switch -regexp -- $mmode \
					^$evv(HOUSE_CHANNEL)$ {
						if {$havemono} {
							Inf "Processing only works with stereo or multichannel files"
							return 0
						}
					} \
					^$evv(HOUSE_CHANNELS)$ {
						Inf "Bulk processing does not work with this mode"
						return 0
					} \
					^$evv(STOM)$ {
						if {$havemono} {
							Inf "Processing only works with stereo or multichannel files"
							return 0
						}
					} \
					^$evv(MTOS)$ {
						if {$multichans || $havestereo} {
							Inf "Processing only works with mono files"
							return 0
						}
					} \
					^$evv(HOUSE_ZCHANNEL)$ {
						if {$multichans || $havestereo} {
							Inf "Processing does not work with stereo or multichannel files"
							return 0
						}
					}
			} \
			^$evv(MIXINTERL)$ {
				if {$in_recycle} {
					Inf "Process cannot be used when recycling from Bulk-Processing:\n\nReturn to Workspace and Try Again"
					return 0
				}
			} \
			^$evv(HOUSE_EXTRACT)$ {
				if {$mmode == $evv(HOUSE_CUTGATE)} {
					Inf "Bulk processing does not work with this mode"
					return 0
				}
			} \
			^$evv(MOTOR)$ {
				if {[expr $mmode % 3] == 2} {
					Inf "Bulk processing does not work with this mode"
					return 0
				}
			}

		return 1
	}

	if {$ins(create)} {
		if {[info exists ins(chlist)] && ([llength $ins(chlist)] > 0)} {
			set this_chosenlist $ins(chlist)
		}
	} elseif {[info exists chlist] && ([llength $chlist] > 0)} {
		set this_chosenlist $chlist
	}

	switch -regexp -- $pprg \
		^$evv(BARE)$ - \
		^$evv(OCT)$ - \
		^$evv(ALT)$ {
			if [info exists this_chosenlist] {
				set this_file [lindex $this_chosenlist 1]
			}
			if {$pa($this_file,$evv(FTYP)) == $evv(PITCHFILE)} {
				return 1
			} else {
				Inf "2nd file must be a binary pitch file (not a binary transposition file)"
				return 0
			}
		}  \
		^$evv(TRNSP)$ - \
		^$evv(TRNSF)$ {
			if [info exists this_chosenlist] {
				set infilecnt [llength $this_chosenlist]
			} else {
				Inf "Wrong number of infiles for this process"
				return 0
			}
			switch -- $infilecnt {
				1 {
					if {$mmode == $evv(TRNS_RATIO) || $mmode == $evv(TRNS_OCT)	||  $mmode == $evv(TRNS_SEMIT)}	{
						return 1
					} else {
						Inf "Wrong number of infiles for this process"
						return 0
					}
				}
				2 {
					if {$mmode == $evv(TRNS_BIN)} {
						set this_file [lindex $this_chosenlist 1]
						if {$pa($this_file,$evv(FTYP)) == $evv(TRANSPOSFILE)} {
							return 1
						} else {
							Inf "2nd file must be a binary transposition file (not a binary pitchfile)"
							return 0
						}
					} else {
						Inf "Wrong number of infiles for this process"
						return 0
					}
				}
			}
		} \
		^$evv(MOD_RADICAL)$ - \
		^$evv(MOD_LOUDNESS)$ {
			if [info exists this_chosenlist] {
				set infilecnt [llength $this_chosenlist]
			} else {
				Inf "Wrong number of infiles for this process"
				return 0
			}
			if {$pprg == $evv(MOD_RADICAL)} {
				if {$pa([lindex $this_chosenlist 0],$evv(FTYP)) != $evv(SNDFILE)} {
					Inf "Soundfiles only for this process."
					return 0
				}
				switch -- $infilecnt {
					1 {
						if {$mmode == $evv(MOD_REVERSE) || $mmode == $evv(MOD_SHRED)	\
						||  $mmode == $evv(MOD_SCRUB)	|| $mmode == $evv(MOD_LOBIT)	\
						||  $mmode == $evv(MOD_RINGMOD) || $mmode == $evv(MOD_LOBIT2)}	{
							return 1
						}
					}
					2 {
						if {$mmode == $evv(MOD_CROSSMOD)} {
							set c1 $pa([lindex $this_chosenlist 0],$evv(CHANS))
							set c2 $pa([lindex $this_chosenlist 1],$evv(CHANS))
							if {(($c1 > 2) || ($c2 > 2))} {
								if {($c1 != $c2) && ($c1 != 1) && ($c2 != 1)} {
									Inf "Files with more than 2 channels, will only modulate with files of same number of channels, or with mono files"
									return 0
								}
							}
							return 1
						}
					}
				}
			} else {
				switch -- $infilecnt {
					1 {
						if {$mmode != $evv(LOUDNESS_BALANCE) \
						&&  $mmode != $evv(LOUDNESS_LOUDEST) && $mmode != $evv(LOUDNESS_EQUALISE)} {
							return 1
						}
					}
					2 {
						if {$mmode == $evv(LOUDNESS_BALANCE) ||  $mmode == $evv(LOUDNESS_LOUDEST)} {
							return 1
						}
						if {$mmode == $evv(LOUDNESS_EQUALISE)} {
							set c1 $pa([lindex $this_chosenlist 0],$evv(CHANS))
							set c2 $pa([lindex $this_chosenlist 1],$evv(CHANS))
							if {$c1 == $c2} {
								return 1
							} else {
								Inf "Files must have same channel-count for this process"
								return 0
							}
						}
					}
					default {
						if {$mmode == $evv(LOUDNESS_LOUDEST)} {
							return 1
						}
						if {$mmode == $evv(LOUDNESS_EQUALISE)} {
							set c1 $pa([lindex $this_chosenlist 0],$evv(CHANS))
							foreach f_n_am [lrange $this_chosenlist 1 end] {
								if {$pa($f_n_am,$evv(CHANS)) != $c1} {
									Inf "Files must have same channel-count for this process"
									return 0
								}
							}
							return 1
						}
					}
				}
			}
			Inf "Wrong number of infiles for this process"
			return 0
		} \
		^$evv(CLEAN)$ {
			if {$ins(create)} {
				if {![info exists ins(chlist)] || ([llength $ins(chlist)] < 2)} {
					Inf "Wrong number of infiles for this process"
					return 0
				}	
				set this_chosenlist $ins(chlist)
			} else {
				if {![info exists chlist] || ([llength $chlist] < 2)} {
					Inf "Wrong number of infiles for this process"
					return 0
				}	
				set this_chosenlist $chlist
			}
			set infilecnt [llength $this_chosenlist]
			switch -- $infilecnt {
				2 {
					if {$mmode == $evv(FROMTIME) || $mmode == $evv(ANYWHERE) || $mmode == $evv(FILTERING)} {
						return 1
					}
				}
				3 {
					if {$mmode == $evv(COMPARING)} {
						return 1
					}

				}
			}
			Inf "Wrong number of infiles for this process"
			return 0
		} \
		^$evv(ENV_IMPOSE)$  - \
		^$evv(ENV_REPLACE)$ {
			if {$ins(create)} {
				if {![info exists ins(chlist)] || ([llength $ins(chlist)] != 2)} {
					Inf "Wrong number of infiles for this process"
					return 0
				}
				set this_chosenlist $ins(chlist)
			} else {
				if {![info exists chlist] || ([llength $chlist] != 2)} {
					Inf "Wrong number of infiles for this process"
					return 0
				}
				set this_chosenlist $chlist
			}
			set fnam [lindex $this_chosenlist 1]
			set filetype $pa($fnam,$evv(FTYP))
			
			switch -regexp -- $mmode \
				^$evv(ENV_SNDFILE_IN)$ {
					if {$filetype != $evv(SNDFILE)} {
						Inf "Wrong type of file for this process (requires a SOUNDFILE)"
						return 0
					}
				} \
				^$evv(ENV_ENVFILE_IN)$ {
					if {$filetype != $evv(ENVFILE)} {
						Inf "Wrong type of file for this process (requires a Binary Envelope File)"
						return 0
					}
				} \
				^$evv(ENV_BRKFILE_IN)$ {
					if {$pprg == $evv(ENV_IMPOSE)} {
						if {$filetype == $evv(MIX_MULTI)} {
							Inf "Wrong type of file for this process (requires an Envelope Textfile)"
							return 0
						}
						if {!($filetype & $evv(IS_A_TRANSPOS_BRKFILE)) \
						&&  !($filetype & $evv(IS_A_NORMD_BRKFILE)) \
						&&  !($filetype & $evv(POSITIVE_BRKFILE))} {
							Inf "Wrong type of file for this process (requires an Envelope Textfile)"	;# The +ve only range established at gobo
							return 0
						}
					} elseif {![IsANormdBrkfile $filetype]} {
						Inf "Wrong type of file for this process\n\n(requires a Breakpoint Textfile with values between 0 -1)"
						return 0
					}
				} \
				^$evv(ENV_DB_BRKFILE_IN)$ {
					if {!($filetype & $evv(IS_A_DB_BRKFILE))} {
						Inf "Wrong type of file for this process (requires an Breakpoint Textfile with dB values)"
						return 0
					}
				} \
				default {
					return 0
				}

		} \
		^$evv(TWIXT)$ {
			set OK 1
			if {$ins(create)} {
				if {![info exists ins(chlist)] || ([llength $ins(chlist)] < 2)} {
					set OK 0
				}
			} elseif {![info exists chlist] || ([llength $chlist] < 2)} {
				set OK 0
			}
			if {!$OK} {
				Inf "This process needs more than one file"
				return 0
			}
		} \
		^$evv(MOD_SPACE)$ {
			if {$ins(create)} {
				if {![info exists ins(chlist)] || ([llength $ins(chlist)] != 1)} {
					Inf "Wrong number of files for this process"
					return 0
				}
				set this_chosenlist $ins(chlist)
			} else {
				if {![info exists chlist] || ([llength $chlist] != 1)} {
					Inf "Wrong number of files for this process"
					return 0
				}
				set this_chosenlist $chlist
			}
			set fnam [lindex $this_chosenlist 0]
			set filetype $pa($fnam,$evv(FTYP))
			set chans    $pa($fnam,$evv(CHANS))
			switch -regexp -- $mmode \
				^$evv(MOD_PAN)$ - \
				^$evv(MOD_MIRROR)$ - \
				^$evv(MOD_NARROW)$ {
					if {$filetype != $evv(SNDFILE)} {
						Inf "Wrong type of file for this process"
						return 0
					}
					if {$mmode == $evv(MOD_PAN)} {
						if {$chans != 1} {
							Inf "Mono files only for this process"
							return 0
						} 
					} elseif {$chans != 2} {
						Inf "Stereo files only for this process"
						return 0
					} 
				} \
				^$evv(MOD_MIRRORPAN)$ {
					if {![IsABrkfile $filetype]} {
						Inf "Wrong type of file for this process"
						return 0
					}
				}
		
		} \
		^$evv(HOUSE_COPY)$ {
			if {$ins(create)} {
				if {![info exists ins(chlist)] || ([llength $ins(chlist)] != 1)} {
					Inf "Wrong number of files for this process"
					return 0
				}
				set this_chosenlist $ins(chlist)
			} else {
				if {![info exists chlist] || ([llength $chlist] != 1)} {
					Inf "Wrong number of files for this process"
					return 0
				}
				set this_chosenlist $chlist
			}
			set fnam [lindex $this_chosenlist 0]
			set filetype $pa($fnam,$evv(FTYP))
			if {($mmode == $evv(DUPL)) && !($filetype == $evv(SNDFILE))} {
				Inf "This process only works with soundfiles"
				if {$filetype & $evv(IS_A_TEXTFILE)} {
					Inf "Multiple copies of Textfiles can be made on the workspace\nfrom the 'Selected Files of Type' menu"
				}
				return 0
			}
		} \
		^$evv(HOUSE_CHANS)$ {
			if {$mmode == $evv(HOUSE_CHANNEL)} {
				set fnam [lindex $this_chosenlist 0]
				set chancnt $pa($fnam,$evv(CHANS))
				if {$chancnt < 2} {
					return 0
				}
			}
		} \
		^$evv(MIXTWO)$ {
			set fnam1 [lindex $this_chosenlist 0]
			set fnam2 [lindex $this_chosenlist 1]
			set chancnt1 $pa($fnam1,$evv(CHANS))
			set chancnt2 $pa($fnam2,$evv(CHANS))
			if {$chancnt1 != $chancnt2} {
				Inf "Files Have Different Channel Counts: This Process May Fail: 'Create Mixfile' Then 'Mix' Is Safer"
			}
		} \
		^$evv(MCHANPAN)$ {
			if {$mmode == 6} {
				if {$pa([lindex $this_chosenlist 0],$evv(CHANS)) == 1} {
					Inf "Stereo Or Multichannel Files Only For This Process"
					return 0
				}
			} elseif {($mmode != 3) && ($mmode != 7)} {
				if {$pa([lindex $this_chosenlist 0],$evv(CHANS)) > 1} {
					Inf "Mono Files Only For This Process"
					return 0
				}
			}
		} \
		^$evv(MCHSHRED)$ {
			if {$mmode == 0} {
				if {$pa([lindex $this_chosenlist 0],$evv(CHANS)) != 1} {
					Inf "Mono Files Only For This Process"
					return 0
				}
			} elseif {$pa([lindex $this_chosenlist 0],$evv(CHANS)) == 1} {
				Inf "Multichannel Files Only For This Process"
				return 0
			}
		} \
		^$evv(SPECAV)$ {
			if {$mmode != 1} {
				if {[info exists this_chosenlist] && ([llength $this_chosenlist] > 1)} {
					Inf "Single input file only for this process"
					return 0
				}
			}
		} \
		^$evv(NEWTEX)$ {
			if {$mmode == 0} {
				if {[info exists this_chosenlist] && ([llength $this_chosenlist] > 1)} {
					Inf "Single input files for this process"
					return 0
				}
			} elseif {$mmode == 1} {
				if {[info exists this_chosenlist] && ([llength $this_chosenlist] < 2)} {
					Inf "At least two input files needed for this process"
					return 0
				}
			}
		} \
		^$evv(SHIFTER)$ {
			if {$mmode == 0} {
				if {[info exists this_chosenlist] && ([llength $this_chosenlist] > 1)} {
					Inf "Single input files for this process"
					return 0
				}
			} elseif {$mmode == 1} {
				if {[info exists this_chosenlist] && ([llength $this_chosenlist] < 2)} {
					Inf "At least two input files needed for this process"
					return 0
				}
			}
		} \
		^$evv(CASCADE)$ {
			if {!(($mmode == 0) || ($mmode == 5)) && ($pa([lindex $this_chosenlist 0],$evv(CHANS)) != 1)} {
				if {[info exists this_chosenlist] && ([llength $this_chosenlist] < 2)} {
					Inf "Mono input files only, for this mode of the process"
					return 0
				}
			}
		} \
		^$evv(MADRID)$ {
			if {$mmode == 1} {
				if {[info exists this_chosenlist] && ([llength $this_chosenlist] < 2)} {
					Inf "At least two input files needed for this process"
					return 0
				}
			}
		} \
		^$evv(FRACTAL)$ {
			if {$mmode == 0} {
				if {$pa([lindex $this_chosenlist 0],$evv(CHANS)) != 1} {
					Inf "Mono files only for this process"
					return 0
				}
			}
		} \
		^$evv(MOTOR)$ {
			if {[expr $mmode % 3] < 2} {
				if {[llength $this_chosenlist] != 1} {
					Inf "Single file only for this mode of this process"
					return 0
				}
			} else {
				if {[llength $this_chosenlist] < 2} {
					Inf "Multiple files needed in this mode of this process"
					return 0
				}
			}
		}

	return 1
}

#------ Get Name of input file(s) if there is one.

proc GetInfileName {} {
	global ins chlist

	set current_filecnt 0
	if {$ins(create) && [info exists ins(chlist)]} {
		set current_filecnt [llength $ins(chlist)]
		set current_file [lindex $ins(chlist) 0]
	} elseif [info exists chlist] {
		set current_filecnt [llength $chlist]
		if {$current_filecnt > 0} {
			set current_file [lindex $chlist 0]
		}
	}
	set thistext ""
	if {$current_filecnt > 0} {
		set current_file [string tolower [file tail $current_file]]
		append thistext $current_file
		if {$current_filecnt > 1} {
			append thistext "...ETC"
		}
	}
	return $thistext
}

proc SeeChosen {} {
	global ins chlist pr_seec seec_list seechosen_cnt evv

	set f .seech
	if [Dlg_Create $f "Files Selected" "set pr_seec 0" -borderwidth $evv(BBDR)] {
		set f0 [frame $f.0 -borderwidth $evv(BBDR)]
		button $f0.ok -text "OK" -command "set pr_seec 0" -highlightbackground [option get . background {}]
		entry $f0.cnt -textvariable seechosen_cnt -width 4 -state readonly
		label $f0.ll -text "  No of files"
		pack $f0.cnt $f0.ll -side left
		pack $f0.ok -side right
		set seec_list [Scrolled_Listbox $f.slist -width 48 -height 20 -selectmode single]
		pack $f.0 -side top -pady 2 -fill x -expand true
		pack $f.slist -side top
		bind $f <Return> {set pr_seec 0}
		bind $f <Escape> {set pr_seec 0}
		bind $f <Key-space> {set pr_seec 0}
		bind $f.slist <space>  {UniversalPlay list $seec_list}
	}
	$seec_list delete 0 end
	if {$ins(create)} {
		if {[info exists ins(chlist)] && ([llength $ins(chlist)] > 0)} {
			set thislist $ins(chlist)
		}
	} else {
		if {[info exists chlist] && ([llength $chlist] > 0)} {
			set thislist $chlist
		}
	}
	if {![info exists thislist]} {
		$seec_list insert end "NO FILES"
		set cnt 0
	} else {
		set cnt 0
		foreach fnam $thislist {
			$seec_list insert end $fnam
			incr cnt
		}
	}
	set seechosen_cnt $cnt
	set pr_seec 0
	My_Grab 0 $f pr_seec
	tkwait variable pr_seec
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#-------------

proc SetLastMixfile {cl} {
	global pa evv last_mix
	if {[llength $cl] == 1} {
		set fnam [lindex $cl 0]
		if {[IsAMixfileIncludingMultichan $pa($fnam,$evv(FTYP))]} {
			set last_mix $fnam
		}
	}
}

#------ If the process is applicable to the current file(s), set it to run
 
proc RerunRecentProgram {} {
	global pprg mmod pmask pr2 has_saved_at_all last_prog last_mmod pr_lastproc pp_list wstk last_last_len last_last_select evv

	if {![info exists last_prog] || ([llength $last_prog] <= 0)} {
		Inf "No previous process remembered"
		return
	}
	set callcentre [GetCentre [lindex $wstk end]]
	set f .lastproc
	if [Dlg_Create $f "RECENT PROCESSES" "set pr_lastproc 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0 -borderwidth $evv(BBDR)]
		set f1 [frame $f.1 -borderwidth $evv(BBDR)]
		set f2 [frame $f.2 -borderwidth $evv(BBDR)]
		set f3 [frame $f.3 -borderwidth $evv(BBDR)]

		button $f0.cyc -text "CYCLE" -width 12 -command {set pr_lastproc 2}  -highlightbackground [option get . background {}] -bg $evv(EMPH)
		button $f0.quit -text "Close" -width 12 -command {set pr_lastproc 0} -highlightbackground [option get . background {}]
		pack $f0.cyc -side left
		pack $f0.quit -side right
		label $f1.lab -text "Click on a Process to select it"
		pack $f1.lab -side top
		set pp_list [Scrolled_Listbox $f2.l -width 120 -height 12 -selectmode single]
		pack $f2.l -side top -fill both -expand true
		button $f3.cle -text "Forget" -width 12 -command {set pr_lastproc 3} -highlightbackground [option get . background {}]
		pack $f3.cle -side left -padx 12
		pack $f0 $f1 $f2 $f3 -side top -pady 2 -fill x
		bind $pp_list <ButtonRelease-1> {set pr_lastproc 1}
		bind $f <Escape> {set pr_lastproc 0}
	}
	$pp_list delete 0 end
	set len 0
	foreach pp $last_prog mm $last_mmod {
		set line [CreateLastProcName $pp $mm]
		$pp_list insert end $line
	}
	set pr_lastproc 0
	set finished 0
	update idletasks
	set geo [CentreOnCallingWindow $f $callcentre]
	My_Grab 0 $f pr_lastproc
	wm geometry $f $geo
	while {!$finished} {
		tkwait variable pr_lastproc
		switch -- $pr_lastproc {
			1 {
				set i [$pp_list curselection]
				if {![info exists i] || ($i < 0)} {
					Inf "No previous process selected"
					continue
				} else {
					set cur_pprg $pprg
					set cur_mmod $mmod
					set pprg [lindex $last_prog $i]
					set mmod [lindex $last_mmod $i]
				}
				if {![string index $pmask $pprg]} {
					Inf "This process will not run with the selected input file(s)"
					set pprg $cur_pprg
					set mmod $cur_mmod
					continue
				} else {
					set last_last_len [llength $last_prog] 
					set last_last_select $i
					set pr2 1 				;# automatically activates program $pprg $mmod
				}
				set has_saved_at_all 0
				break
			}
			2 {
				set len [llength $last_prog]
				if {$len >= $evv(LASTPROCLIST_MAX)} {
					Inf "Cycling only works with less than $evv(LASTPROCLIST_MAX) processes"
					continue
				}
				switch -- $len {
					0 {
						continue
					}
					1 {
						set i 0
					}
					default {
						if {![info exists last_last_len]} {
							set i 0
						} elseif {$len != $last_last_len} {
							set msg "Start New Cycle ?"
							set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
							if {$choice == "no"} {
								continue
							}
							set i 0
						} else {
							set i [expr $last_last_select + 1]
							if {$i >= $len} {
								set i 0
							}
						}
					}
				}	
				set cur_pprg $pprg
				set cur_mmod $mmod
				set pprg [lindex $last_prog $i]
				set mmod [lindex $last_mmod $i]
				if {![string index $pmask $pprg]} {
					Inf "This process will not run with the selected input file(s)"
					set pprg $cur_pprg
					set mmod $cur_mmod
					continue
				} else {
					set last_last_len $len
					set last_last_select $i
					set pr2 1 				;# automatically activates program $pprg $mmod
				}
				set has_saved_at_all 0
				break
			}
			3 {
				set msg "Forget ~All~ Processes ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "yes"} {
					catch {unset last_prog}
					catch {unset last_mmod}
					catch {unset last_last_len}
					catch {unset last_last_select}
					break
				}
				set msg "Forget Selected Processes ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				bind $pp_list <ButtonRelease-1> {set pr_lastproc 4}
				.lastproc.3.cle config -text "Select" -width 12 -command {set pr_lastproc 5}
			}
			4 {
				set i [$pp_list curselection]
				set last_prog [lreplace $last_prog $i $i]
				set last_mmod [lreplace $last_mmod $i $i]
				$pp_list delete $i
				set last_last_select 0
				set last_last_len [llength $last_prog] 
				if {$last_last_len <= 0} {
					catch {unset last_prog}
					catch {unset last_mmod}
					catch {unset last_last_len}
					catch {unset last_last_select}
					break
				}
			}
			5 {
				.lastproc.3.cle config -text "Forget" -width 12 -command {set pr_lastproc 3}
				bind $pp_list <ButtonRelease-1> {set pr_lastproc 1}
			}
			0 {
				break
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc CreateLastProcName {pp mm} {
	global prg menuinverse
	set line [string toupper [lindex $menuinverse $pp]]
	append line " " [lindex $prg($pp) 1]
	if {$mm > 0} {
		append line " " [lindex $prg($pp) [expr 2 + $mm]]
	}
	return $line
}

proc RememberLastProcess {} {
	global pprg mmod last_prog last_mmod evv
	if {[info exists last_prog]} {
		set cnt 0
		foreach pp $last_prog mm $last_mmod {
			if {($pprg == $pp) && ($mmod == $mm)} {
				set last_prog [lreplace $last_prog $cnt $cnt]
				set last_mmod [lreplace $last_mmod $cnt $cnt]
				lappend last_prog $pprg
				lappend last_mmod $mmod
				return
			}
			incr cnt
		}
		if {[llength $last_prog] >= $evv(LASTPROCLIST_MAX)} {
			set last_prog [lrange $last_prog 1 end]
			set last_mmod [lrange $last_mmod 1 end]
		}
	}
	lappend last_prog $pprg
	lappend last_mmod $mmod
}


proc DePost {} {
	global procmenu chosen_men
	if [info exists procmenu] {
		catch {destroy $chosen_men}
		destroy $procmenu
	}
}

proc SwitchInfo {i} {
	global infstat pim
	if {$infstat} {
		set infstat 0
		RetrieveInfo $pim.topbtns
	}

}

proc CheckForChoiceChange {} {
	global chlist last_choice

	set returnval 0
	if {![info exists chlist] || ([llength $chlist] <= 0)} {
		set chlen 0
	} else {
		set chlen [llength $chlist]
	}
	if {![info exists last_choice] || ([llength $last_choice] <= 0)} {
		set lalen 0
	} else {
		set lalen [llength $last_choice]
	}
	if {$chlen != $lalen} {
		if {![info exists chlist]} {
			set last_choice {}
		} else {
			set last_choice $chlist
		}
		set returnval 1
	} elseif {$chlen != 0} {
		foreach fnam $chlist fnam2 $last_choice {
			if {![string match $fnam $fnam2]} {
				set last_choice $chlist
				set returnval 1
				break
			}
		}
	}
	return $returnval
}

#--- Play from anywhere, using control-p key

proc UniversalPlay {w which} {
	global ins chlist wstk pa pr_nu_playlist nu_inplay_pll evv
	global papag wl dl ch text_sf text_sfs ins_file_lst proplisting timeline tabed
	switch -- $w {
		icp {
			set fnams [glob -nocomplain "$evv(MACH_OUTFNAME)*"]
			if {[llength $fnams] <= 0} {
				foreach item [$ins_file_lst get 0 end] {
					set ftyp [FindFileType $item]
					if {($ftyp == $evv(SNDFILE)) || ($ftyp == $evv(ANALFILE))} {
						set fnam $item
						break
					}
				}
				if {[info exists fnam]} {
					Inf "Playing First Input Sound Chosen"
					PlaySndfile $fnam 0
				}
				return
			}
			set procno -1
			set zzz $evv(MACH_OUTFNAME)
			set zlen [string length $zzz]
			foreach fnam $fnams {
				set ftyp [FindFileType $fnam]
				if {($ftyp != $evv(SNDFILE)) && ($ftyp != $evv(ANALFILE))} {
					continue
				}
				set fnamb [string range [file rootname $fnam] $zlen end]
				set k [string last "_" $fnamb]
				incr k -1
				set thisprocno [string range $fnamb 0 $k]
				incr k 2
				set thisno [string range $fnamb $k end]
				if {$thisprocno < $procno} {
					continue
				} elseif {$thisprocno > $procno} {
					set procno $thisprocno
					set no $thisno
					set pfnam $fnam
				} else {
					if {$thisno > $no} {
						continue
					} else {
						set no $thisno
						set pfnam $fnam
					}
				}
			}
			if {[info exists pfnam]} {
				Inf "Playing First Soundfile Generated By Last Process"
				PlaySndfile $pfnam 0
				return
			}
		}
		props {
			set ilist [$proplisting curselection]
			set len [llength $ilist]
			if {($len <= 0) || ([lindex $ilist 0] < 0)} {
				Inf "No Sound Selected"
				return
			}
			set i [lindex $ilist 0]
			set fnam [lindex [$proplisting get $i] 0]
			if {[file exists $fnam]} {
				set ftyp [FindFileType $fnam]
				if {($ftyp == $evv(SNDFILE)) || ($ftyp == $evv(ANALFILE))} {
					PlaySndfile $fnam 0
				}
			}
			return
		}
		pmark {
			set fnam $which
			if {[string length $fnam] <= 0} {
				return
			}
			PlaySndfile $fnam 0
			return
		}
		tabed {
			set thislist $tabed.bot.itframe.l.list
			set ilist [$thislist curselection]
			if {![info exists ilist] || ([llength $ilist] < 1) || ([lindex $ilist 0] == -1)} {
				set thislist $tabed.bot.otframe.l.list
				set ilist [$thislist curselection]
				if {![info exists ilist] || ([llength $ilist] < 1) || ([lindex $ilist 0] == -1)} {
					set thislist $tabed.bot.icframe.l.list
					set ilist [$thislist curselection]
					if {![info exists ilist] || ([llength $ilist] < 1) || ([lindex $ilist 0] == -1)} {
						set thislist $tabed.bot.ocframe.l.list
						set ilist [$thislist curselection]
						if {![info exists ilist] || ([llength $ilist] < 1) || ([lindex $ilist 0] == -1)} {
							Inf "No Sound Selected"
							return
						}
					}
				}
			}
			set i [lindex $ilist 0]
			set fnam [$thislist get $i]
			set fnam [split [string trim $fnam]]
			set OK 0
			foreach item $fnam {
				if {[string length $item] <= 0} {
					continue
				}
				if {[file exists $item]} {
					set ftyp [FindFileType $item]
					if {($ftyp == $evv(SNDFILE)) || ($ftyp == $evv(ANALFILE))} {
						set fnam $item
						set OK 1
						break
					}
				}
			}
			if {$OK} {
				PlaySndfile $fnam 0
			}
			return
		}
		"papag" {
			if {[$papag.parameters.output.play cget -state] == "disabled"} {
				PlayInput
			} else {
				PlayOutput 0
			}
			return
		}
		"menupage" {
			PlayInput
			return
		}
		ww {
			set ilist [$wl curselection]
			if {![info exists ilist] || ([llength $ilist] < 1) || ([lindex $ilist 0] == -1)} {
				if {[info exists dl]} {
					set ilist [$dl curselection]
					if {[info exists ilist] && ([llength $ilist] >= 1) && ([lindex $ilist 0] != -1)} {
						foreach i $ilist {
							lappend thislist [$dl get $i]
						}
					}
				}
				if {![info exists thislist]} {
					if [info exists chlist] {
						set ilist [$ch curselection]
						if {[info exists ilist] && ([llength $ilist] > 0) && ([lindex $ilist 0] != -1)} {
							foreach i $ilist {
								lappend thislist [$ch get $i]
							}
						}
					}
				}
			} else {
				foreach i $ilist {
					lappend thislist [$wl get $i]
				}
			}
			if {![info exists thislist]} {
				Inf "No Item Selected"
				return
			}
		}
		list {
			set ilist [$which curselection]
			if {![info exists ilist] || ([llength $ilist] < 1) || ([lindex $ilist 0] == -1)} {
				if {[$which index end] == 1} {
					set ilist 0
				} else {
					Inf "No Sound Selected"
					return
				}
			}
			set fnam [$which get [lindex $ilist 0]]
			set ftyp [FindFileType $fnam]
			if {($ftyp != $evv(SNDFILE)) && ($ftyp != $evv(ANALFILE))} {
				Inf "'$fnam' Is Not A Soundfile"
			} else {
				PlaySndfile $fnam 0
			}
			return
		}
		xlist {
			set ilist [$which curselection]
			if {![info exists ilist] || ([llength $ilist] < 1) || ([lindex $ilist 0] == -1)} {
				if {[$which index end] == 1} {
					set ilist 0
				} else {
					Inf "No sound selected"
					return
				}
			}
			set fnamx [$which get [lindex $ilist 0]]
			set fnamx [string trim $fnamx]
			set fnamx [split $fnamx]
			set fnam [lindex $fnamx 0]
			set fnam [string trim $fnam]
			if {[string match [string index $fnam 0] ";"]} {
				set fnam [string range $fnam 1 end]
			}
			if {![file exists $fnam]} {
				Inf "File $fnam no longer exists"
				return
			}
			set ftyp [FindFileType $fnam]
			if {($ftyp != $evv(SNDFILE)) && ($ftyp != $evv(ANALFILE))} {
				Inf "$fnam is not a soundfile"
			} else {
				PlaySndfile $fnam 0
			}
			return
		}
		text {
			set twindow $which
			if {[catch {selection get -displayof $twindow} sel]} {
				return
			}
			set sel [string trim $sel]
			if {[string length $sel] <= 0} {
				Inf "No Item Marked With Cursor"
				return
			}
			set llist [split $sel]
			if {[llength $llist] > 1} {
				Inf "Selection Contains More Than One Word"
				return
			}
			if {[string match ";" [string index $sel 0]] && ([string length $sel] > 1)} {
				set sel [string range $sel 1 end]
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
				set selindir $sel
				while {![file exists $selindir]} {
					set msg "Soundfile '$selindir' Does Not Exist:  Do You Want To Specify (Another) Directory ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						return
					} else {
						set ddir [UniversalPlayDir]
						if {[string length $ddir] <= 0} {
							return
						}
						set selindir [file join $ddir $sel]
					}
				}
				set sel $selindir
			}
			set ftyp [FindFileType $sel]
			if {($ftyp != $evv(SNDFILE)) && ($ftyp != $evv(ANALFILE))} {
				Inf "'$sel' Is Not A Soundfile"
				return
			}
			set sel [ReverseBackslashes $sel]
			PlaySndfile $sel 0
			return
		}
	}
	foreach item $thislist {
		set ftyp [FindFileType $item]
		if {($ftyp == $evv(SNDFILE)) || ($ftyp == $evv(ANALFILE))} {
			lappend fnams $item
		}
	}
	if {![info exists fnams]} {
		Inf "No Soundfile Selected"
		return
	} elseif {[llength $fnams] == 1} {
		PlaySndfile [lindex $fnams 0] 0
		return
	}
	set f .nu_playlist
	if [Dlg_Create $f "Playlist" "set pr_nu_playlist 1" -borderwidth $evv(BBDR)] {
		set b 	   [frame $f.button -borderwidth $evv(SBDR)]
		set player [frame $f.play -borderwidth $evv(SBDR)]
		set nu_inplay_pll [Scrolled_Listbox $player.playlist -width 48 -height 32 -selectmode single]
		button $b.play -text "Play" -command "PlaySelectedInSndfile $nu_inplay_pll" -highlightbackground [option get . background {}]
		button $b.quit -text "Close" -command "set pr_nu_playlist 1" -highlightbackground [option get . background {}]
		pack $b.play -side left -padx 1
		pack $b.quit -side right
		pack $player.playlist -side top -fill both
		pack $f.button $f.play -side top -fill x
		bind $nu_inplay_pll <Double-1> {UniversalPlay list $nu_inplay_pll}
		bind .nu_playlist <Control-Key-p> {UniversalPlay list $nu_inplay_pll}
		bind .nu_playlist <Control-Key-P> {UniversalPlay list $nu_inplay_pll}
		bind .nu_playlist <Key-space> {UniversalPlay list $nu_inplay_pll}
		bind $f <Escape> {set pr_nu_playlist 1}
	}
	wm resizable $f 1 1
	$nu_inplay_pll delete 0 end
	foreach fnam $fnams {
		$nu_inplay_pll insert end $fnam
	}
	set pr_nu_playlist 0
	raise $f
	My_Grab 0 $f pr_nu_playlist $f.play.playlist
	tkwait variable pr_nu_playlist
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc TooManyFiles {} {
	global bulk wl ins chlist wstk evv

	set evv(TOOMANY) 900	;#	Seems to be c. 960-980, is different with bulk-run,
							;#	and varies with number of other files on the workspace.....

	if {$ins(create)} {
		if [info exists ins(chlist)] {
			set thischosenlist "$ins(chlist)"
		}
	} else {
		if [info exists chlist] {
			set thischosenlist "$chlist"
		}
	}
	if {![info exists thischosenlist]} {
		return 0
	}
	if {[llength $thischosenlist] > $evv(TOOMANY)} {
		set msg "WARNING: TK/Tcl May Fail to Handle More Than $evv(TOOMANY) Files (Reason Unknown)\n\nDo You Wish To Proceed ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return 1
		}
	}
	return 0
}

#---- Subtitles in Submenus

proc GetSubmenuSubtitle {j} {
	global evv
	switch -regexp -- $j \
		^$evv(ENV_CREATE)$ {
			set subtitle "CREATE : EXTRACT"
		} \
		^$evv(EDIT_CUT)$ {
			set subtitle "CUT AND KEEP"
		} \
		^$evv(TRNSP)$ {
			set subtitle "TRANSPOSE ANALYSIS DATA"
		} \
		^$evv(GRAIN_COUNT)$ {
			set subtitle "SOUNDS WITH AUDIBLE GRAINS"
		} \
		^$evv(PITCH)$ {
			set subtitle "EXTRACT : CREATE PITCHDATA"
		} \
		^$evv(P_BINTOBRK)$ {
			set subtitle "CONVERT PITCHDATA FORMAT"
		} \
		^$evv(P_QUANTISE)$ {
			set subtitle "MODIFY PITCHDATA"
		} \
		^$evv(REPITCH)$ {
			set subtitle "COMBINE PITCHDATA"
		} \
		^$evv(P_FIX)$ {
			set subtitle "MASSAGE PITCHDATA"
		} \
		^$evv(P_SYNTH)$ {
			set subtitle "SYNTHESIS FROM PITCHDATA"
		} \
		^$evv(EDIT_EXCISE)$ {
			set subtitle "CUT AND DISCARD"
		} \
		^$evv(EDIT_INSERT)$ {
			set subtitle "INSERT INTO SOUND"
		} \
		^$evv(EDIT_JOIN)$ {
			set subtitle "JOIN SOUNDS"
		} \
		^$evv(RANDCUTS)$ {
			set subtitle "RANDOM OR GRID CUTS"
		} \
		^$evv(NOISE_SUPRESS)$ {
			set subtitle "SPEECH RELATED"
		} \
		^$evv(ENV_IMPOSE)$ {
			set subtitle "IMPOSE ENVELOPE DATA"
		} \
		^$evv(ENV_RESHAPING)$  {
			set subtitle "MODIFY ENVELOPE DATA"
		} \
		^$evv(ENV_ENVTOBRK)$ {
			set subtitle "CHANGE ENVELOPE DATA FORMAT"
		} \
		^$evv(ENV_DOVETAILING)$ {
			set subtitle "IMPOSE : MODIFY CONTOUR"
		} \
		^$evv(TIME_GRID)$ {
			set subtitle "OTHER"
		} \
		^$evv(MIX)$ {
			set subtitle "MIXFILES"
		} \
		^$evv(RRRR_EXTEND)$ {
			set subtitle "SPEECH RELATED"
		}

	return $subtitle
}

proc ColourSubmenuSubtitle {menu j pmask submenu_cnt} {
	global evv
	switch -regexp -- $j \
		^$evv(GRAIN_COUNT)$ - \
		^$evv(TRNSP)$ - \
		^$evv(EDIT_CUT)$ - \
		^$evv(ENV_CREATE)$ {
			$menu entryconfigure $submenu_cnt -background $evv(OFF_COLOR) -foreground $evv(SPECIAL)
			incr submenu_cnt
			$menu entryconfigure $submenu_cnt -background $evv(OFF_COLOR)
			incr submenu_cnt
		} \
		^$evv(PITCH)$ - \
		^$evv(P_BINTOBRK)$ - \
		^$evv(P_QUANTISE)$ - \
		^$evv(REPITCH)$ - \
		^$evv(P_FIX)$ - \
		^$evv(P_SYNTH)$ - \
		^$evv(EDIT_EXCISE)$ - \
		^$evv(EDIT_INSERT)$ - \
		^$evv(EDIT_JOIN)$ - \
		^$evv(RANDCUTS)$ - \
		^$evv(NOISE_SUPRESS)$ - \
		^$evv(RRRR_EXTEND)$ - \
		^$evv(ENV_IMPOSE)$ - \
		^$evv(ENV_RESHAPING)$ - \
		^$evv(ENV_ENVTOBRK)$ - \
		^$evv(ENV_DOVETAILING)$ - \
		^$evv(TIME_GRID)$ - \
		^$evv(MIX)$ {
			$menu entryconfigure $submenu_cnt -background $evv(OFF_COLOR) 
			incr submenu_cnt
			$menu entryconfigure $submenu_cnt -background $evv(OFF_COLOR) -foreground $evv(SPECIAL)
			incr submenu_cnt
			$menu entryconfigure $submenu_cnt -background $evv(OFF_COLOR) 
			incr submenu_cnt
		}

	return $submenu_cnt
}

;# MAY BE WRONG ON MAC : TEST !!

proc ReverseBackslashes {fnam} {
	set len [string length $fnam]
	set i 0
	while {$i < $len} {
		set j [string index $fnam $i]
		if [regexp {^[\\]$} $j] {
			append outstr "/"
		} else {
			append outstr $j
		}
		incr i
	}
	return $outstr
}

proc UniversalPlayDir {} {
	global pr_upd univpdir wstk evv
	set callcentre [GetCentre [lindex $wstk end]]
	set f .upd
	if [Dlg_Create $f "SPECIFY DIRECTORY" "set pr_upd 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0 -borderwidth $evv(BBDR)]
		set f1 [frame $f.1 -borderwidth $evv(BBDR)]

		button $f0.set -text "Set Directory" -width 12 -command {set pr_upd 1} -highlightbackground [option get . background {}]
		button $f0.recent -text "Recent Dirs" -width 12 -command {set pr_upd 2} -highlightbackground [option get . background {}]
		button $f0.quit -text "Abandon" -width 12 -command {set pr_upd 0} -highlightbackground [option get . background {}]
		pack $f0.set $f0.recent -side left -padx 2
		pack $f0.quit -side right
		pack $f0 -side top -pady 2 -fill x -expand true
		label $f1.lab -text "Directory path "
		entry $f1.e -textvariable univpdir -width 36
		pack $f1.lab $f1.e -side left -padx 2
		pack $f1 -side top -pady 2
		bind $f <Escape> {set pr_upd 0}
		bind $f <Return> {set pr_upd 1}
	}
	set univpdir ""
	set pr_upd 0
	set finished 0
	update idletasks
	set geo [CentreOnCallingWindow $f $callcentre]
	My_Grab 0 $f pr_upd
	wm geometry $f $geo
	while {!$finished} {
		tkwait variable pr_upd
		switch -- $pr_upd {
			2 { 
				ListRecentDirs .upd.1.e
			}
			1 {
				if {[string length $univpdir] <= 0} {
					Inf "Invalid Directory Path Entered"
					continue
				}
				if {![file isdirectory $univpdir]} {
					Inf "Directory '$univpdir' Does Not Exist"
					continue
				}
				set finished 1
			}
			0  {
				set univpdir ""
				break
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $univpdir
}

#---- Shortcut to mix program from process page

proc GoDirectToMix {} {
	global ins chlist pa has_saved_at_all pprg mmod pr2 selected_menu pmcnt pstore prm evv actvhi actvlo
	if {$ins(run)} {
		if {![info exist ins(chlist)]} {
			return
		}
		set fnam [lindex $ins(chlist) 0]
	} else {
		if {![info exist chlist]} {
			return
		}
		set fnam [lindex $chlist 0]
	}
	if {[IsAMixfile $pa($fnam,$evv(FTYP))]} {
		set selected_menu 6
		set has_saved_at_all 0
		set pprg $evv(MIX)
		set mmod 0
		set pr2 1
	} elseif {[IsAMixfileIncludingMultichan $pa($fnam,$evv(FTYP))]} {
		set selected_menu 17
		set has_saved_at_all 0
		set pprg $evv(MIXMULTI)
		set mmod 0
		set pr2 1
	}
	set i 0
	while {$i < $pmcnt} {
		set pstore($i) $prm($i)
		incr i
	}
	set actvlo(0) 0.0
	set actvlo(0) $pa($fnam,$evv(DUR))
	set actvhi(1) 0.0
	set actvhi(1) $pa($fnam,$evv(DUR))
}

#--- Grab from any textwindow, using control-g key

proc UniversalGrab {twindow} {
	global evv wl wstk ch chcnt chlist

	if {[catch {selection get -displayof $twindow} sel]} {
		return
	}
	set sel [string trim $sel]
	if {[string length $sel] <= 0} {
		Inf "No Item Marked With Cursor"
		return
	}
	set llist [split $sel "\n"]
	set kkwl 0
	set kkch 0
	foreach item $llist {
		set item [split $item]
		set item [string trim $item ]
		set sel [lindex $item  0]
		if {[string match ";" [string index $sel 0]] && ([string length $sel] > 1)} {
			set sel [string range $sel 1 end]
		}
		if {[file isdirectory $sel]} {
			set badmsg "$sel is a directory"
			lappend badmsgs $badmsg
			continue
		}
		set rt [file rootname [file tail $sel]]
		if {![ValidCDPRootname $rt]} {
			continue
		}
		if {[string length [file extension $sel]] == 0} {
			append sel $evv(SNDFILE_EXT)
		}
		if {![file exists $sel]} {
			set badmsg "Soundfile '$sel' does not exist : (only-part-of-line ??)"
			lappend badmsgs $badmsg
			continue
		}
		set ftyp [FindFileType $sel]
		if {$ftyp != $evv(SNDFILE)} {
			Inf "$sel is not a soundfile"
			set badmsg "$sel IS NOT A SOUNDFILE"
			lappend badmsgs $badmsg
			continue
		}
		set sel [ReverseBackslashes $sel]
		set k [LstIndx $sel $wl]
		if {$k >= 0} {
			set msg "'$sel'\nis already on the workspace : put on \"chosen files\" list ??"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "yes"} {
				if {$kkch == 0} {
					DoChoiceBak
					ClearWkspaceSelectedFiles
				}
				$ch insert end $sel
				lappend chlist $sel
				incr chcnt
				incr kkch
			} else {
				if {$kkwl == 0} {
					$wl selection clear 0 end
				}
				incr kkwl
				$wl selection set $k
				AdjustWkspaceView $k
			}
			continue
		} else {
			FileToWkspace $sel 0 0 0 0 1
			lappend wklist $sel
			if {$kkwl == 0} {
				$wl selection clear 0 end
			}
			incr kkwl
			$wl selection set 0
		}
	}
	if {[info exists wklist]} {
		if {[llength $wklist] == 1} {
			set msg "[lindex $wklist 0]\nis now on the workspace"
		} else {
			set msg "The following files are now on the workspace\n"
			foreach fnam $wklist {
				append msg "$fnam\n"
			}
		}
		if {[info exists badmsgs]} {
			foreach badmsg $badmsgs {
				append msg "\n$badmsg"
			}
		}
		Inf $msg
	}
	return
}

proc GetProcInfo {} {	
	global pim proc_info_state specific_info infstat
	switch -- $proc_info_state {
		0 {
			if {$infstat == 1} {
				if {$specific_info == 0} {
					set specific_info 1
					SwitchInfo 1
					set proc_info_state 2
				} else {
					set specific_info 0
					RetrieveInfo $pim.topbtns
					set proc_info_state 0
				}
			} else {
				if {$specific_info == 1} {
					set specific_info 0
				}
				RetrieveInfo $pim.topbtns
				set proc_info_state 1
			}
		}
		1 {
			if {$specific_info == 1} {
				set specific_info 0
				RetrieveInfo $pim.topbtns
				set proc_info_state 0
			}
			set specific_info 1
			SwitchInfo 1
			set proc_info_state 2
		}
		2 {
			set specific_info 0
			RetrieveInfo $pim.topbtns
			set proc_info_state 0
		}
	}
}

#---- Allow space menu to be active if input file is appropriate textfile

proc SpaceException {} {
	global chlist pa evv
	if {[info exists chlist] && ([llength $chlist] == 1)} {
		set fnam [lindex $chlist 0]
		if {[IsABrkfile $pa($fnam,$evv(FTYP))] && ($pa($fnam,$evv(MINBRK)) >= -1.0) && ($pa($fnam,$evv(MAXBRK)) <= 1.0)} { 
			return 1
		}
	}
	return 0
}

#---- Prevent radical menu working with more than 2 input files

proc RadicalException {} {
	global chlist
	if {[info exists chlist] && ([llength $chlist] > 2)} {
		return 1
	}
	return 0
}

#---- Permit Cross-modulate to works with combo of stereo+mono infiles

proc CrossException {} {
	global chlist pa evv
	if {[info exists chlist] && ([llength $chlist] == 2)} {
		set c1 $pa([lindex $chlist 0],$evv(CHANS))
		set c2 $pa([lindex $chlist 1],$evv(CHANS))
		if {$c1 == $c2} {
			return 1
		}
		if {($c1 == 1) && ($c2 == 2)} {
			return 1
		}
		if {($c1 == 2) && ($c2 == 1)} {
			return 1
		}
	}
	return 0
}

#---- Retain a record of chan-cnt of files in chosen list

proc SetChlistChanMap {ll} {
	global chanmap lastchanmap pa evv
	if {[info exists chanmap]} {
		set lastchanmap $chanmap]
	}
	set chanmap {}
	foreach fnam $ll {
		lappend chanmap $pa($fnam,$evv(CHANS))
	}
	set chanmap [lsort $chanmap]
}

#---- Detect a change in channel-cnt of files in input list (even if pmask is same)

proc ChanShift {} {
	global chanmap lastchanmap
	if {[info exists chanmap] && [info exists lastchanmap] && ([llength $chanmap] == [llength $lastchanmap])} {
		foreach c1 $chanmap c2 $lastchanmap {
			if {$c1 != $c2} {
				return 1
			}
		}
	}
	return 0
}

proc HelpMCTK {} {
	set msg "MULTICHANNEL TOOLKIT\n"
	append msg "\n"
	append msg "Suite of programs for handling\n"
	append msg "different FORMATS of multichannel files.\n"
	append msg "\n"
	append msg "BY: Richard Dobson.\n"
	Inf $msg
}

#---- Does Chosen List contain (only) mutually-compatible soundfiles. Return count thereof.

proc ChlistIsComptibleSnds {} {
	global chlist pa evv
	if {![info exists chlist]} {
		return 0
	}
	set cnt 0
	foreach fnam $chlist {
		if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
			return 0
		}
		if {$cnt == 0} {
			set chans $pa($fnam,$evv(CHANS))
			set srate $pa($fnam,$evv(SRATE))
		} elseif {($chans != $pa($fnam,$evv(CHANS))) || ($srate != $pa($fnam,$evv(SRATE)))} {
			return 0
		}
		incr cnt
	}
	return $cnt
}

#----- Split and Rejoin multichan files --> independent channels

proc SplitMchanFile {fnam} {
	global origsplitfnam pa chlist evv prg_dun prg_abortd CDPidrun simple_program_messages bulksplit
	set origsplitfnam $fnam
	DeleteAllTemporaryFiles
	set chans $pa($fnam,$evv(CHANS))
	set splitfnam $evv(DFLT_OUTNAME)
	append splitfnam $evv(SNDFILE_EXT)
	set n chans
	if [catch {file copy $fnam $splitfnam} zit] {
		Inf "Failed To Make Temporary Copy Of Multichannel File"
		return 0
	}
	set cmd [file join $evv(CDPROGRAM_DIR) housekeep] 
	lappend cmd chans 2 $splitfnam

	set prg_dun 0
	set prg_abortd 0
	catch {unset simple_program_messages}
	Block "Extracting All Channels"
	if [catch {open "|$cmd"} CDPidrun] {
		ErrShow "Failed To Extract Channels"
		catch {unset CDPidrun}
		catch {file delete $splitfnam}
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
		set msg "Failed To Extract Channels"
		set msg [AddSimpleMessages $msg]
		ErrShow $msg
		catch {file delete $splitfnam}
		UnBlock
		return 0
	}
	UnBlock
	set n 1
	while {$n <= $chans} {
		set outfnam [file rootname $splitfnam]
		append outfnam _c $n $evv(SNDFILE_EXT)
		if {![file exists $outfnam]} {
			set badfiles 1
		} else {
			lappend goodfiles $outfnam
		}
		incr n
	}
	if {[info exists badfiles]} {
		Inf "Failed To Extract All Channels"
		DeleteAllTemporaryFiles
		return 0
	}
	foreach fnam $goodfiles {
		set propno 0
		while {$propno < $evv(CDP_PROPS_CNT)} {			;#Transfer props of multichan inflie 
			set pa($fnam,$propno) $pa($origsplitfnam,$propno)
			incr propno
		}
		set pa($fnam,$evv(FSIZ)) [expr $pa($fnam,$evv(FSIZ)) / $chans]
		set pa($fnam,$evv(INSAMS)) [expr $pa($fnam,$evv(INSAMS)) / $chans]
		set pa($fnam,$evv(CHANS)) 1
	}
	set chlist $goodfiles
	set bulksplit $chans

	return 1
}

proc JoinMchanFile {} {
	global pprg pa evv prg_dun prg_abortd CDPidrun simple_program_messages bulksplit origsplitfnam chlist

	catch {unset bulksplit}
	set chans $pa($origsplitfnam,$evv(CHANS))

	Block "Rejoining Channels of Multichan file"
	if {[IsAStereoOutProg]} {
		set stereo_outputs 1
		set cmd [file join $evv(CDPROGRAM_DIR) mchstereo] 
		lappend cmd mchstereo 
	} else {
		set stereo_outputs 0
		set cmd [file join $evv(CDPROGRAM_DIR) submix] 
		lappend cmd interleave 
	}
	set n 0
	set outdur 0.0
	set outsams 0
	while {$n < $chans} {
		set outfnam $evv(MACH_OUTFNAME)
		append outfnam $n "_0" $evv(SNDFILE_EXT)
		lappend cmd $outfnam
		incr n
		if {$pa($outfnam,$evv(DUR)) > $outdur} {		;#	Find max dur of outfiles to be joined
			set outdur $pa($outfnam,$evv(DUR))
			set outsams $pa($outfnam,$evv(INSAMS))
		}
	}
	set outfnam $evv(MACH_OUTFNAME)
	append outfnam $n "_0" $evv(SNDFILE_EXT)
	lappend cmd $outfnam			;#	output file

	if {$stereo_outputs} {
		set ochansdata $evv(MACH_OUTFNAME)
		append ochansdata 0_0 $evv(TEXT_EXT)
		if [catch {open $ochansdata "w"} zit] {
			DeleteAllTemporaryFiles
			set chlist $origsplitfnam
			UnBlock
			return 0
		}
		set str 1
		set n 2
		while {$n <= $chans} {
			append str " " $n
			incr n
		}
		puts $zit $str
		close $zit
		lappend cmd $ochansdata $chans .5
		set outsams [expr $outsams / 2]
	}
	set prg_dun 0
	set prg_abortd 0
	catch {unset simple_program_messages}
	if [catch {open "|$cmd"} CDPidrun] {
		ErrShow "Failed To Rejoin Channels"
		catch {unset CDPidrun}
		DeleteAllTemporaryFiles
		set chlist $origsplitfnam
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
		set msg "Failed To Rejoin Channels"
		set msg [AddSimpleMessages $msg]
		ErrShow $msg
		DeleteAllTemporaryFiles
		set chlist $origsplitfnam
		UnBlock
		return 0
	}
	if {![file exists $outfnam]} {
		ErrShow "Failed To Rejoin Channels"
		DeleteAllTemporaryFiles
		set chlist $origsplitfnam
		UnBlock
		return 0
	}
	set n 0 
	while {$n < $chans} {
		set xoutfnam $evv(MACH_OUTFNAME)
		append xoutfnam $n "_0" $evv(SNDFILE_EXT)
		catch {file delete $xoutfnam}
		incr n
	}
	if {$stereo_outputs} {
		catch {file delete $ochansdata}
	}
	set xoutfnam $evv(MACH_OUTFNAME)
	append xoutfnam 0 "_0" $evv(SNDFILE_EXT)
	if [catch {file rename $outfnam $xoutfnam} zit] {
		ErrShow "Rejoin Channels: Final Rename Failed"
		DeleteAllTemporaryFiles
		set chlist $origsplitfnam
		UnBlock
		return 0
	}
	set propno 0
	while {$propno < $evv(CDP_PROPS_CNT)} {			;#	Transfer props of multichan infile 
		set pa($xoutfnam,$propno) $pa($origsplitfnam,$propno)
		incr propno
	}
	set pa($xoutfnam,$evv(DUR)) $outdur						;#	But get true output dur!!
	set pa($xoutfnam,$evv(INSAMS)) [expr $outsams * $chans]
	set chlist $origsplitfnam
	UnBlock
	return 1
}

proc ReturnToWorkspace {} {
	global pr2 ins_rethink real_chlist chlist set_thumbnailed ww bulksplit origsplitfnam evv
	if {[info exists real_chlist]} {
		set chlist $real_chlist
		unset real_chlist
		set set_thumbnailed 0
		$ww.1.a.mez.bkgd config -state normal
	}
	if {[info exists bulksplit]} {
		unset bulksplit
		DeleteAllTemporaryFiles
		set chlist $origsplitfnam
	}
	set pr2 0
	set ins_rethink 1
}

proc PossiblyRerunProgram {} {
	global pim chlist pa evv pprg mmod pr2 selected_menu
	if {[string match [$pim.topbtns.again cget -state] "normal"]} {
		RerunProgram
	} else {
		if {[info exists chlist] && ([llength $chlist] == 1)} {
			set ftyp $pa([lindex $chlist 0],$evv(FTYP))
			if {$ftyp == $evv(MIX_MULTI)} {
				set pprg $evv(MIXMULTI)
				set mmod 0
				set selected_menu 17
				set pr2 1
			} elseif {[IsAMixfile $ftyp]} {
				set pprg $evv(MIX)
				set mmod 0
				set selected_menu 6
				set pr2 1
			}
		}
	}
}

#--- program has stereo output files

proc IsAStereoOutProg {} {
	global pprg mmod pa pathumb evv
	switch -regexp -- $pprg \
		^$evv(SIMPLE_TEX)$	- \
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
			return 1
		} \
		^$evv(MOD_REVECHO)$	{
			if {$mmod == 3} {
				return 1
			}
		} \
		^$evv(BRASSAGE)$	- \
		^$evv(SAUSAGE)$	{
			set fnam $evv(MACH_OUTFNAME)
			append fnam 0_0$evv(SNDFILE_EXT)
			if {[file exists $fnam]} {
				if {[DoThumbnailParse $fnam]} {
					set returnval 0
					if {$pa($fnam,$evv(CHANS)) > 1} {
						set returnval 1
					}
					PurgeArray $fnam
					PurgeThumbProps $fnam
					return $returnval
				}
			}
		} \
		^$evv(MOD_SPACE)$ {
			if {$mmod == 1} {
				return 1
			}
		}

	return 0
}

#----- Check ALL files on chosen list have no more than 2 channels, if "MIX" is to be activated

proc MixValidChans {}  {
	global chlist pa evv
	if {[info exists chlist]} {
		foreach fnam $chlist {
			if {$pa($fnam,$evv(CHANS)) > 2} {
				return 0
			}
		}
		return 1
	}
	return 0
}

#--- Shortcut to go direct to specific processes

proc GodoProcess {what cntrl} {
	global ins chlist pa evv pmcnt pstore prm selected_menu has_saved_at_all pprg mmod pr2 bulk

	if {$ins(run)} {
		if {![info exist ins(chlist)] || ([llength $ins(chlist)] <= 0)} {
			return
		}
		set ch_list $ins(chlist)
	} else {
		if {![info exists chlist] || ([llength $chlist] <= 0)} {
			return
		}
		set ch_list $chlist
	}
	set len_ch [llength $ch_list]
	if {$bulk(run)} {
		set len_ch 1
	}
	set is_anal 1
	set is_mix  0
	set is_mmix 0
	set is_f 0
	set is_p 0
	set chans_diverse 0
	foreach fnam $ch_list {
		if {$pa($fnam,$evv(FTYP)) != $evv(ANALFILE)} {
			set is_anal 0
			break
		}
		if {![info exists origrate]} {						;#	If analysis files
			set origrate $pa($fnam,$evv(ORIGRATE))
		} elseif {$origrate != $pa($fnam,$evv(ORIGRATE))} {
			return											;#	Check for consistency of properties
		}
		if {![info exists a_chans]} {
			set a_chans $pa($fnam,$evv(CHANS))
		} elseif {$a_chans != $pa($fnam,$evv(CHANS))} {
			return
		}
		if {![info exists a_srate]} {
			set a_srate $pa($fnam,$evv(SRATE))
		} elseif {$a_srate != $pa($fnam,$evv(SRATE))} {
			return
		}
	}
	if {!$is_anal} {										;#	If not analysis files
		set is_snd 1
		foreach fnam $ch_list {
			if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
				set is_snd 0
				break										;#	Must all be soundfiles
			}
			if {![info exists srate]} {
				set srate $pa($fnam,$evv(SRATE))			;#	Must have same srate
			} elseif {$srate != $pa($fnam,$evv(SRATE))} {
				return
			}
			if {![info exists chans]} {
				set chans $pa($fnam,$evv(CHANS))			;#	Compare channel cnt of soundfiles
			} elseif {$chans != $pa($fnam,$evv(CHANS))} {
				if {$bulk(run)} {
					return
				}
				set chans_diverse 1							;#	Note that sndfiles of different channel cnt used
				if {$pa($fnam,$evv(CHANS)) > $chans} {
					set chans $pa($fnam,$evv(CHANS))		;#	Store max channel cnt
				}
			}
		}
		if {!$is_snd} {										;#	If not analysis or sound files
			if {$bulk(run)} {
				return
			}
			if {[IsAMixfile $pa($fnam,$evv(FTYP))]} {
				set is_mix 1
				if {$len_ch > 1} {
					return
				}
			} elseif {[IsAMixfileIncludingMultichan $pa($fnam,$evv(FTYP))]} {
				set is_mmix 1
				if {$len_ch > 1} {
					return
				}
			} else {
				if {$len_ch != 2} {
					return
				}
				foreach fnam $ch_list {
					if {$pa($fnam,$evv(FTYP)) == $evv(PITCHFILE)} {
						if {$is_p} {
							return
						}
						set is_p 1
					}
					if {$pa($fnam,$evv(FTYP)) == $evv(FORMANTFILE)} {
						if {$is_f} {
							return
						}
						set is_f 1
					}
				}
				if {!($is_p && $is_f)} {
					return
				} elseif {$what != "c"} {
					return
				}
			}
		}
	}
	switch -- $what {
		"1" {
			if {!$is_snd || ($len_ch != 1) || ($chans == 1)} {
				return
			}
			set selected_menu 12
			set pprg $evv(HOUSE_CHANS)
			set mmod 4
		}
		"b" {
			if {$is_anal} {
				if {$len_ch > 1} {
					return
				}
				set selected_menu 24
				set pprg $evv(BLUR)
				set mmod 0
			} else {
				if {$chans_diverse || ($chans > 2)} {
					return
				}
				if {$len_ch > 1} {
					set selected_menu 13
					set pprg $evv(SAUSAGE)
					set mmod 0
				} else {
					set selected_menu 13
					set pprg $evv(BRASSAGE)
					set mmod 7
				}
			}
		}
		"c" {
			if {$cntrl} {
				if {!$is_snd || ($len_ch != 2)} {
					return
				}
				set selected_menu 31
				set pprg $evv(INFO_DIFF)
				set mmod 0
			} elseif {$is_p} {
				set selected_menu 29
				set pprg $evv(MAKE)
				set mmod 0
			} elseif {$is_anal} {
				if {$len_ch != 2} {
					return
				}
				set selected_menu 29
				set pprg $evv(SUM)
				set mmod 7
			} else {
				if {$chans_diverse} {
					return
				}
				set selected_menu 12
				if {$chans == 1} {
					if {$len_ch == 1} {
						set pprg $evv(HOUSE_CHANS)
						set mmod 5
					} else {
						set pprg $evv(MIXINTERL)
						set mmod 0
					}
				} else {
					if {$len_ch > 1} {
						return
					}
					set pprg $evv(HOUSE_CHANS)
					set mmod 2
				}
			}
		}
		"d" {
			if {$is_anal || ($len_ch > 1) || ($chans > 1)} {
				return
			}
			if {$cntrl} {
				set selected_menu 2
				set pprg $evv(DRUNKWALK)
				set mmod 1
			} else {
				set selected_menu 5
				set pprg $evv(ENV_DOVETAILING)
				set mmod 2
			}
		}
		"e" {
			if {$cntrl == 2} {
				if {$len_ch > 1} {
					return
				}
				if {$is_anal} {
					set selected_menu 5
					set pprg $evv(ANALENV)
					set mmod 0
				} else {
					set selected_menu 5
					set pprg $evv(ENV_EXTRACT)
					set mmod 2
				}
			} elseif {$cntrl == 1} {
				if {$is_anal || ($len_ch > 1)} {
					return
				}
				set selected_menu 1
				set pprg $evv(EDIT_CUTMANY)
				set mmod 1
			} else {
				if {$is_anal || ($len_ch > 1)} {
					return
				}
				set selected_menu 1
				set pprg $evv(EDIT_CUT)
				set mmod 1
			}
		}
		"f" {
			if {$len_ch > 1} {
				return
			}
			if {$cntrl} {
				if {$is_anal} {
					set selected_menu 22
					set pprg $evv(GREQ)
					set mmod 1
				} else {
					set selected_menu 7
					set pprg $evv(EQ)
					set mmod 3
				}
			} else {
				if {$is_anal} {
					set selected_menu 25
					set pprg $evv(FORMANTS)
					set mmod 0
				} else {
					set selected_menu 7
					set pprg $evv(LPHP)
					set mmod 1
				}
			}
		}
		"g" {
			if {$is_anal || ($len_ch > 1)} {
				return
			}
			if {$cntrl} {
				set selected_menu 4
				set pprg $evv(GRAIN_ASSESS)
				set mmod 0
			} else {
				set selected_menu 4
				set pprg $evv(GRAIN_COUNT)
				set mmod 0
			}
		}
		"h" {
			if {!$is_anal || ($len_ch > 1)} {
				return
			}
			if {$cntrl} {
				set selected_menu 23
				set pprg $evv(FREEZE2)
				set mmod 0
			} else {
				set selected_menu 22
				set pprg $evv(S_TRACE)
				set mmod 4
			}
		}
		"i" {
			if {$is_anal || ($chans > 2) || ($len_ch > 2)} {
				return
			}
			if {$len_ch == 2} {
				if {$chans_diverse} {
					return
				}
				set selected_menu 0
				set pprg $evv(EDIT_INSERT)
				set mmod 1
			} else {
				set selected_menu 2
				set pprg $evv(ITERATE)
				set mmod 1
			}
		}
		"j" {
			if {$is_anal || $chans_diverse} {
				return
			}
			set selected_menu 0
			set pprg $evv(EDIT_JOIN)
			set mmod 0
		}
		"k" {
			if {$is_anal || ($len_ch > 1)} {
				return
			}
			set selected_menu 5
			set pprg $evv(ENV_CURTAILING)
			set mmod 4
		}
		"l" {
			if {$is_anal || ($len_ch > 1)} {
				return
			}
			set selected_menu 8
			set pprg $evv(MOD_LOUDNESS)
			set mmod 1
		}
		"m" {
			if {$cntrl == 2} {				;#	Control-M
				if {$is_anal} {
					return
				}
				if {$is_mmix} {
					set selected_menu 6
					set pprg $evv(MIXMULTI)		;#	Mix, if a multichannel mixfile
					set mmod 0
				} elseif {$is_mix} {
					set selected_menu 6
					set pprg $evv(MIX)			;#	Mix, if a mixfile
					set mmod 0
				} else {
					set selected_menu 17		;#	Create a multichannel mixfile
					set pprg $evv(MULTIMIX)
					set mmod 8
				}
			} elseif {$is_anal} {			;#	Alt-M
				if {$len_ch != 2} {
					return
				}
				set selected_menu 30
				set pprg $evv(MORPH)			;#	Morph, if 2 anal files
				set mmod 2
			} elseif {$is_mmix} {
				set selected_menu 6
				set pprg $evv(MIXMULTI)			;#	Mix, if a multichannel mixfile
				set mmod 0
			} elseif {$is_mix} {
				set selected_menu 6
				set pprg $evv(MIX)				;#	Mix, if a mixfile
				set mmod 0
			} else {
				if {$chans > 2} {			;#	chans stores MAX chan count for sndfiles
					set selected_menu 17		;#	Create a multichannel mixfile
					set pprg $evv(MULTIMIX)
					set mmod 8
				} else {
					set selected_menu 6
					set pprg $evv(MIXDUMMY)		;#	Create a mixfile
					set mmod 0
				}
			}
		}
		"n" {
			if {($len_ch > 1) || $is_anal} {
				return
			}
			set selected_menu 8
			set pprg $evv(MOD_LOUDNESS)			;#	Nornmalise Loudness
			set mmod 3
		}
		"p" {
			if {$len_ch > 1} {
				return
			}
			if {$cntrl} {
				if {$is_anal} {
					return
				} else {
					if {$chans > 1} {
						return
					}
					set selected_menu 9
					set pprg $evv(MOD_SPACE)
					set mmod 1
				}
			} else {
				if {$is_anal} {
					set selected_menu 19
					set pprg $evv(PVOC_SYNTH)
					set mmod 0
				} else {
					if {$chans > 1} {
						return
					}
					set selected_menu 19
					set pprg $evv(PVOC_ANAL)
					set mmod 1
				}
			}
		}
		"r" {
			if {$cntrl} {
				if {$is_anal || ($len_ch > 1) || ($chans > 1)} {
					return
				}
				set selected_menu 1
				set pprg $evv(DISTORT_RPT)
				set mmod 0
			} else {
				if {$len_ch > 1} {
					return
				}
				if {$is_anal} {
					set selected_menu 28
					set pprg $evv(PITCH)
					set mmod 2
				} else {
					if {$chans > 2} {
						return
					}
					set selected_menu 10
					set pprg $evv(MOD_REVECHO)
					set mmod 3
				}
			}
		}
		"s" {
			if {$len_ch > 1} {
				return
			}
			if {$cntrl} {
				if {$is_anal} {
					set selected_menu 28
					set pprg $evv(TRNSF)
					set mmod 3
				} else {
					set selected_menu 14
					set pprg $evv(STACK)
					set mmod 0
				}
			} else {
				if {$is_anal} {
					set selected_menu 28
					set pprg $evv(TRNSP)
					set mmod 3
				} else {
					if {$chans <= 2} {
						set selected_menu 10
						set pprg $evv(MOD_PITCH)
						set mmod 2
					} else {
						set selected_menu 17
						set pprg $evv(STRANS_MULTI)
						set mmod 2
					}
				}
			}
		}
		"t" {
			if {$cntrl} {
				if {$is_anal || $chans_diverse || ($chans > 2)} {
					return
				}
				set selected_menu 3
				set pprg $evv(SIMPLE_TEX)
				set mmod 5
			} else {
				if {$len_ch > 1} {
					return
				}
				if {$is_anal} {
					set selected_menu 21
					set pprg $evv(TSTRETCH)
					set mmod 1
				} else {
					set selected_menu 13
					set pprg $evv(BRASSAGE)
					set mmod 2
				}
			}
		}
		"v" {
			if {$is_anal || ($len_ch > 1)} {
				return
			}
			if {$cntrl} {
				set selected_menu 7
				set pprg $evv(FLTBANKV)
				set mmod 2
			} else {
				if {$chans > 2} {
					set selected_menu 17
					set pprg $evv(STRANS_MULTI)
					set mmod 4
				} else {
					set selected_menu 10
					set pprg $evv(MOD_PITCH)
					set mmod 6
				}
			}
		}
		"w" {
			if {$is_anal || ($len_ch > 1)} {
				return
			}
			set selected_menu 8
			set pprg $evv(MOD_LOUDNESS)
			set mmod 9
		}
		"x" {
			if {$is_anal || ($len_ch > 1)} {
				return
			}
			if {$cntrl} {
				set selected_menu 0
				set pprg $evv(EDIT_EXCISEMANY)
				set mmod 1
			} else {
				set selected_menu 0
				set pprg $evv(EDIT_EXCISE)
				set mmod 1
			}
		}
		"z" {
			if {$is_anal || ($len_ch > 1)} {
				return
			}
			if {$cntrl} {
				set selected_menu 0
				set pprg $evv(EDIT_ZCUT)
				set mmod 1
			} else {
				set selected_menu 2
				set pprg $evv(ZIGZAG)
				set mmod 2
			}
		}
	}
	set has_saved_at_all 0
	set pr2 1
	set i 0
	while {$i < $pmcnt} {
		set pstore($i) $prm($i)
		incr i
	}
}

proc RepairCompatible {len} {

	set n [expr $len/2]
	if {$n * 2 == $len} {
		return 1
	}
	set n [expr $len/5]
	if {$n * 5 == $len} {
		return 1
	}	
	set n [expr $len/7]
	if {$n * 7 == $len} {
		return 1
	}
	return 0
}


proc ArePhysModFiles {instr} {
	global chlist ins_file_lst
	if {$instr} {
		if {[info exists ins_file_lst]} {
			foreach fnam [$ins_file_lst get 0 end] {
				if {[string match [file extension $fnam] ".m"]} {
					Inf "Physical modelling files cannot be used on the chosen files list: use music testbed"
					$ins_file_lst delete 0 end
					return 1
				}
			}
		}
	} else {
		if {[info exists chlist] && ([llength $chlist] > 0)} {
			foreach fnam $chlist {
				if {[string match [file extension $fnam] ".m"]} {
					Inf "Physical modelling files cannot be used on the chosen files list: use music testbed"
					return 1
				}
			}
		}
	}
	return 0
}
