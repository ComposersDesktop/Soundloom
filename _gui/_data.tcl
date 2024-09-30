#
# SOUND LOOM RELEASE mac version 17.0.4
#
# NOW GENERATES A TEXTFILE OF A SINGLE WINDOW IN CORRECT FORMAT (fEB 13)
#

#
# INFO: The transforms to the data are stored as instructions in "spektransform" (SEE CODE)
#	spektransform is the CURRENT transform
#	there are also NAMED transforms, which can be loaded as the CURRENT transform
#	there is also the DEFAULT transform (specktr(default)
#
#	STORING THE CURVE-SETS
#
#	"init_brrk_fnams" are the data files
#	whose names have been saved between sessions, and which can be loaded if requested   
#
#	"previous_brrk_fnams" are the list of data files
#	REMAINING AFTER the last call to DATA DISPLAY in the current session
#
#	""brrk_fnams" are the UPDATABLE list of data files
#	used during a call to the Display routine
#
#	CONVERSION DATA TO SPEK
#
#	spek_c is first generated when data file converted into spectral range.
#	No other spectral transforms will work until this happens!!
#

################################


proc UberData {} {
	global pr_uberdata datadatatype testmaxspek evv
	set f .uberdata
	if [Dlg_Create $f "DATA TO SOUND" "set pr_uberdata 0" -borderwidth 2] {
		frame $f.0
		button $f.0.hh  -text "Help" -command "DataConversionOverview" -highlightbackground [option get . background {}]
		button $f.0.qu  -text "Quit" -command "set pr_uberdata 0" -highlightbackground [option get . background {}]
		pack $f.0.hh -side left
		pack $f.0.qu -side right
		pack  $f.0 -side top -fill x -expand true
		frame $f.1
		radiobutton $f.1.ts -text "Time Series Text-Data (t)" -variable datadatatype -value 1 -command TimeSeriesToSnd
		radiobutton $f.1.sp -text "Spectral Text-Data (s)" -variable datadatatype -value 2 -command SpectralDataToSound
		pack $f.1.ts  $f.1.sp -side left
		pack $f.1 -side top -pady 2
		wm resizable $f 1 1
		bind $f <Escape> {set pr_uberdata 0}
		bind $f <Key-t> {set datadatatype 1; TimeSeriesToSnd}
		bind $f <Key-T> {set datadatatype 1; TimeSeriesToSnd}
		bind $f <Key-s> {set datadatatype 2; SpectralDataToSound}
		bind $f <Key-S> {set datadatatype 2; SpectralDataToSound}
	}
	catch {unset testmaxspek}
	catch {unset testedmaxspek}
	set datadatatype 0
	set pr_uberdata 0
	update idletasks
	raise $f
	update idletasks
	My_Grab 0 $f pr_uberdata
	update idletasks
	set finished 0
	tkwait variable pr_uberdata
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc SpectralDataToSound {} {
	global pr_datosnd datosndlist datosndlist_spek datosndlist_data spekdisplaytype_changed spk evv
	global pr_uberdata

##TESTING ONLY
set evv(TESTING) 1
	catch {unset spk(vary)}
	catch {unset datosndlist_spek}
	catch {unset datosndlist_data}
	set spekdisplaytype_changed 0		;#	FLAGS IF CURRENT DISPLAY IS DIFFERENT TYPE TO PREVIOUS CALL
	catch {unset last_spektransform}
	catch {unset spk(presndset)}

	set evv(SPEKT_APPLY)   2
	set evv(SPEKT_QUIT)    1
	set evv(SPEKT_PRESND) -1
	set evv(SPEKT_POSTSND) 0

	set tcl_precision 17
	set f .datosnd
	if [Dlg_Create $f "spectral data to sound" "set pr_datosnd 0" -borderwidth 2 -width 160] {
		frame $f.0
		button $f.0.qq -text "Quit" -command "set pr_datosnd 0" -highlightbackground [option get . background {}]
		button $f.0.help -text "Help" -command DatToSndHelp -highlightbackground [option get . background {}]
		pack $f.0.qq -side right
		button $f.0.es -text "End Session" -command "DoWkspaceQuit 1 0" -highlightbackground [option get . background {}]
		pack $f.0.es $f.0.help -side left -padx 8
		pack $f.0 -side top -fill x -expand true

		frame $f.1
		frame $f.1.1
		frame $f.1.2
		frame $f.1.3
		label $f.1.1.a -text "Display" -fg $evv(SPECIAL)
		button $f.1.1.1 -text "Draw (different) graph(s) (#)"		-width 40 -command {DisplayBrkfileNew $evv(DISPLAY_ABSNEWK)}  -highlightbackground [option get . background {}]
		button $f.1.1.2 -text "Show current data display (Cntrl #)"	-width 40 -command {DisplayBrkfileNew $evv(DISPLAY_DATA_SPEK)}  -highlightbackground [option get . background {}]
		button $f.1.1.0 -text "Add (more) selected graph(s) (+)"	-width 40 -command {DisplayBrkfileNew $evv(DISPLAY_NEWK)}  -highlightbackground [option get . background {}]
		button $f.1.1.3 -text "Show named data display (Return)"	-width 40 -command {DisplayBrkfileNew $evv(LOAD_NAMED_DATA_SPEK)}  -highlightbackground [option get . background {}]
		pack $f.1.1.a $f.1.1.1 $f.1.1.2 $f.1.1.0 $f.1.1.3 -side top -pady 2

		label $f.1.2.a -text "Delete display" -fg $evv(SPECIAL)
		button $f.1.2.4 -text "Delete current data display"		-width 40 -command {DisplayBrkfileNew $evv(DELETE_DATA_SPEK)}  -highlightbackground [option get . background {}]
		button $f.1.2.5 -text "Delete named data display"		-width 40 -command {DisplayBrkfileNew $evv(DELETE_NAMED_DATA_SPEK)}  -highlightbackground [option get . background {}]
		label $f.1.2.b -text "Range of data" -fg $evv(SPECIAL)
		button $f.1.2.c -text "Get max range of selected files"		-width 40 -command {RangeOfSelectedSpek 1 0}  -highlightbackground [option get . background {}]
		button $f.1.2.d -text "List max amps of selected files"		-width 40 -command {RangeOfSelectedSpek 0 1}  -highlightbackground [option get . background {}]
		pack $f.1.2.a $f.1.2.4 $f.1.2.5 $f.1.2.b $f.1.2.c $f.1.2.d -side top -pady 2
		
		label $f.1.3.0 -text "List" -width 6 -fg $evv(SPECIAL)

		menubutton $f.1.3.mm -text "Modify file listing" -menu $f.1.3.mm.menu -relief raised -width 22 -relief raised
		set menx [menu $f.1.3.mm.menu -tearoff 0]
		$menx add command -label "Move files to top" -command {DatoSndTop}
		$menx add separator
		$menx add command -label "Reverse selection" -command {DatoSndReverse}
		$menx add separator
		$menx add command -label "Select all files"    -command {DatoSndAll}
		$menx add separator
		$menx add command -label "Chosen list files only"   -command {DatoSndSpek 2}
		$menx add separator
		$menx add command -label "Restore full list"  -command {DatoSndSpek 1}
		$menx add separator
		$menx add command -label "Restore original list"  -command {DatoSndSpek 3}

		button $f.1.3.dum1 -text "Chosen list files (C)" -command {DataChosenOnlySelect} -width 22  -highlightbackground [option get . background {}]
		label $f.1.3.dum2 -text "Transformations" -fg $evv(SPECIAL)
		button $f.1.3.trns -text "Manage transform seqs" -width 22 -command ManageTransformSeqs  -highlightbackground [option get . background {}]

		pack $f.1.3.0 $f.1.3.mm -side top -pady 2
		pack $f.1.3.dum1 -side top -pady 4
		pack $f.1.3.dum2 $f.1.3.trns -side top -pady 2

		pack $f.1.1 -side left -pady 8 -padx 16 
		pack $f.1.3 -side left -pady 8 -padx 16 -fill y -expand true
		pack $f.1.2 -side left -pady 8 -padx 16 
		pack $f.1 -side top

		frame $f.2
		label $f.2.tit -text "Data Files on the Workspace" -fg $evv(SPECIAL)
		set datosndlist [Scrolled_Listbox $f.2.ll -width 140 -height 32 -selectmode extended]
		pack $f.2.tit $f.2.ll -side top -pady 2
		pack $f.2 -side top -fill both -expand true
		bind $f <Key-#> {DisplayBrkfileNew $evv(DISPLAY_ABSNEWK)}
		bind $f <Key-+> {DisplayBrkfileNew $evv(DISPLAY_NEWK)}
		bind $f <Control-Key-#> {DisplayBrkfileNew $evv(DISPLAY_DATA_SPEK)}
		bind $f <Key-c> {DataChosenOnlySelect}
		bind $f <Key-C> {DataChosenOnlySelect}
		bind $f <Escape> {set pr_datosnd 0; set pr_uberdata 0}
		bind $f <Return> {DisplayBrkfileNew $evv(LOAD_NAMED_DATA_SPEK)}
		bind $f <Double-1> {ShowData %y}
		wm resizable $f 0 0
	}
	DatoSndSpek 0
	set pr_datosnd 0
	update idletasks
	raise $f
	StandardPosition2 $f
	My_Grab 0 $f pr_datosnd
	tkwait variable pr_datosnd
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	set tcl_precision 6
}

proc DataChosenOnlySelect {} {
	global datosndlist testmaxspek
	catch {unset testmaxspek}
	if {[DatoSndSpek 2]} {
		$datosndlist selection set 0 end
	}
}

proc DatoSndTop {} {
	global datosndlist datosndlist_data datosndlist_spek
	set ilist [$datosndlist curselection]
	if {![info exists ilist] || ([llength $ilist] <= 0) || (([llength $ilist] == 1) && ($ilist == -1))} {
		Inf "Select files from listing"	
		return
	}
	foreach i $ilist {
		lappend nulist [$datosndlist get $i]
	}
	foreach fnam [$datosndlist get 0 end] {
		if {[lsearch $nulist $fnam] < 0} {
			lappend nulist $fnam
		}
	}
	$datosndlist delete 0 end
	catch {unset datosndlist_data}
	foreach fnam $nulist {
		lappend datosndlist_data $fnam
		$datosndlist insert end $fnam
	}
}

proc DatoSndReverse {} {
	global datosndlist datosndlist_data datosndlist_spek
	set ilist [$datosndlist curselection]
	if {![info exists ilist] || ([llength $ilist] <= 0) || (([llength $ilist] == 1) && ($ilist == -1))} {
		Inf "select files from listing"	
		return
	}
	set len [llength $ilist]
	set jlist [ReverseList $ilist]
	set k 0
	set selindex 0
	set i [lindex $ilist $selindex]
	set j [lindex $jlist $selindex]
	foreach fnam [$datosndlist get 0 end] {
		if {($selindex < $len) && ($k == $i)} {
			lappend klist $j
			incr selindex
			if {$selindex < $len} {
				set i [lindex $ilist $selindex]
				set j [lindex $jlist $selindex]
			}
		} else {
			lappend klist $k
		}
		incr k
	}
	foreach k $klist {
		lappend nulist [$datosndlist get $k]
	}
	$datosndlist delete 0 end
	catch {unset datosndlist_data}
	foreach fnam $nulist {
		lappend datosndlist_data $fnam
		$datosndlist insert end $fnam
	}
}

proc DatoSndAll {} {
	global datosndlist
	$datosndlist selection set 0 end
}

proc DatoSndSpek {refresh} {
	global datosndlist datosndlist_spek datosndlist_data orig_datosndlist_data pa chlist wstk wl ch evv 
	
	if {$refresh == 1} {
		if {![info exists orig_datosndlist_data]} {
			return 0
		}
		set datosndlist_data $orig_datosndlist_data
		unset orig_datosndlist_data
		$datosndlist delete 0 end
	} elseif {($refresh == 3) || ![info exists datosndlist_data]} {
		$datosndlist delete 0 end
		set datosndlist_data {}
		foreach fnam [$wl get 0 end] {
			set ext [file extension $fnam]
			if {!([string match $ext $evv(SPEC_EXT)] || [string match $ext $evv(SPEK_EXT)] || [string match $ext $evv(SPKK_EXT)])} {
				if {[IsABrkfile $pa($fnam,$evv(FTYP))]} {
					lappend datosndlist_data $fnam
				}
			}
		}
		if {[llength $datosndlist_data] <= 0} {
			Inf "No appropriate data files on the workspace"
		}
	}
	if {$refresh == 2} {
		if {![info exists chlist]} {
			Inf "No files on chosen files list"
			return 0
		}
		catch {unset orig_datosndlist_data}
		if {[info exists datosndlist_data]} {
			set orig_datosndlist_data $datosndlist_data
			set datosndlist_data {}
		}
		foreach fnam [$ch get 0 end] {
			set ext [file extension $fnam]
			if {!([string match $ext $evv(SPEC_EXT)] || [string match $ext $evv(SPEK_EXT)] || [string match $ext $evv(SPKK_EXT)])} {
				if {[IsABrkfile $pa($fnam,$evv(FTYP))]} {
					lappend datosndlist_data $fnam
				} else {
					lappend  badfiles $fnam
				}
			}
		}
		if {[llength $datosndlist_data] <= 0} {
			Inf "No valid files found on chosen files list"
			if {[info exists orig_datosndlist_data]} {
				set datosndlist_data $orig_datosndlist_data
			}
			return 0
		} elseif {[info exists badfiles]} {
			set msg "Not all files on chosen files list are valid data files\n(e.g. [file tail [lindex $badfiles 0]])\n\nProceed with the valid ones only ?"
			set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				if {[info exists orig_datosndlist_data]} {
					set datosndlist_data $orig_datosndlist_data
					unset orig_datosndlist_data
					return 0
				}
			} else {
				$datosndlist delete 0 end
			}
		} else {
			$datosndlist delete 0 end
		}
	}
	foreach fnam $datosndlist_data {
		$datosndlist insert end $fnam
	}
	return 1
}

#---- Find Range limits of selected files

proc RangeOfSelectedSpek {msg getmaximi} {
	global datosndlist set_brrk_range wstk wl

	set ilist [$datosndlist curselection]
	if {![info exists ilist] || ([llength $ilist] <= 0) || (([llength $ilist] == 1) && ($ilist == -1))} {
		Inf "No data files selected"
		return
	}
	Block "Finding Data Ranges"
	foreach i $ilist {
		lappend fnams [$datosndlist get $i]
	}
	set init 0
	foreach fnam $fnams {
		set localmax 0
		if [catch {open $fnam r} fileId] {
			lappend badfiles $fnam
			continue
		}
		set valcnt 0
		catch {unset nuvals}
		set OK 1
		while {[gets $fileId line] >= 0} {
			set vals "[string trim $line]"
			set vals "[split $vals]"
			foreach val $vals {
				if {[string length $val] > 0} {
					if {![IsNumeric $val]} {
						set OK 0
						break
					}
					lappend nuvals $val
					incr valcnt
				}
			}
		}
		catch {close $fileId}
		if {$valcnt < 4 || ![IsEven $valcnt]} {
			set OK 0
		}
		if {!$OK} {
			lappend badfiles $fnam
			continue
		}
		set goodfile 1
		set vals $nuvals
		if {!$init} {
			set frqmin [lindex $vals 0] 
			set frqmax [lindex $vals 0] 
			set ampmin [lindex $vals 1] 
			set ampmax [lindex $vals 1] 
			set init 1
		}
		foreach {frq amp} $vals {
			if {$frq < $frqmin} {
				set frqmin $frq
			}
			if {$frq > $frqmax} {
				set frqmax $frq
			}
			if {$amp < $ampmin} {
				set ampmin $amp
			}
			if {$amp > $ampmax} {
				set ampmax $amp
				set ampmaxfil $fnam
			}
			if {$amp > $localmax} {
				set localmax $amp
			}
		}
		if {$getmaximi} {
			lappend maximi $localmax
		}
	}
	UnBlock
	if {![info exists goodfile]} {
		Inf "Unable to obtain range information from selected files"
		return
	} elseif {[info exists badfiles]} {
		set msg "The following files could not be opened, or contained invalid data\n\n"
		set cnt 0
		foreach fnam $badfiles {
			append msg "$fnam\n"
			incr cnt
			if {$cnt >= 20} {
				append msg "AND MORE"
				break
			}
		}
		Inf $msg
	} else {
		if {$getmaximi} {
			set ofnam "temp.txt"
			catch {file delete $ofnam}
			if [catch {open $ofnam "w"} zit] {
				Inf "Failed to open file $ofnam to write maximi data"
			} else {
				set msg "Normalise amplitude levels in output data ??"
				set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
				if {$choice == "yes"} {
					set maxx 0.0
					foreach val $maximi {
						if {$val > $maxx} {
							set maxx $val
						}
					}
					if {$maxx <= 0.0} {
						Inf "Cannot normalise values : (maximum amplitude is zero)"
						set maxx 1.0
					}
				} else {
					set maxx 1.0
				}
				set kk 1
				foreach val $maximi {
					set val [expr $val/$maxx]
					puts $zit $val
					incr kk
				}
				close $zit
				FileToWkspace $ofnam 0 0 0 0 1
				set i [LstIndx $ofnam $wl]
				if {$i != 0} {
					set j 0
					foreach fnam [$wl get 0 end] {
						if {$i != $j} {
							lappend nulist $fnam
						} else {
							set nulist [concat $fnam $nulist]
						}
						incr j
					}
					$wl delete 0 end
					foreach fnam $nulist {
						$wl insert end $fnam
					}
				}
				Inf "List of amplitude maximi in file $ofnam : rename this file to preserve it."
			}
			return
		}
		if {$ampmin < 0.0} {
			Inf "Y-range falls below zero: not valid for this utility"
			return
		}
		if {$frqmin < 0.0} {
			Inf "X-range falls below zero: not valid for this utility"
			return
		}
		if {$msg} {
			Inf "Range established : max amplitude in file [file rootname [file tail $ampmaxfil]]"
		}
	}
	if {$ampmin > 0.0} {
		set msg "Force minimum of amplitude range to zero ?"
		set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			set ampmin 0.0
		}
	}
	set set_brrk_range [list $ampmin $ampmax $frqmin $frqmax]
}

#---- Display data in textfile, on Double-Click

proc ShowData {y} {
	global datosndlist
	set i [$datosndlist nearest $y]
	set fnam [$datosndlist get $i]
	SimpleDisplayTextfile $fnam
}

proc DatToSndHelp {} {

	set msg	"Converting Data to Sound\n"
	append msg	"\n"
	append msg	"Converts (several files of) textfile data,\n"
	append msg	"representing the spectrum of some phenomenon,\n"
	append msg	"to a sound spectrum.\n"
	append msg	"\n"
	append msg	"Draw (more) Selected Graph(s)\n"
	append msg	"\n"
	append msg	"Display one or more data files selected from the list,\n"
	append msg	"or ADD the selected files to the current display.\n"
	append msg	"\n"
	append msg	"Data can be converted to spectra.\n"
	append msg	"\n"
	append msg	"Show Current Data Display\n"
	append msg	"\n"
	append msg	"Redisplay a set of data curves\n"
	append msg	"either previously displayed in this session\n"
	append msg	"or created or displayed in a previous session.\n"
	append msg	"\n"
	append msg	"Show Named Data Display\n"
	append msg	"\n"
	append msg	"Select a listing of data files\n"
	append msg	"created and named previously.\n"
	append msg	"Becomes default material for data display.\n"
	append msg	"\n"
	append msg	"Shortcuts\n"
	append msg	"\n"
	append msg	"Use \"#\" Key for shortcuts, as indicated.\n"
	append msg	"\n"
	append msg	"It can also be used ....\n"
	append msg	"\n"
	append msg	"(1)   to set top of (vertical) RANGE to 1.0\n"
	append msg	"                when range box is displayed.\n"
	append msg	"(2)   to launch the DEFAULT TRANSFORM SEQUENCE.\n"
	append msg	"\n"
	append msg	"Double Clicking on any file will display it.\n"
	append msg	"\n"
	Inf $msg
}

proc DataConversionOverview {} {
	set msg	"Converting Textfile Data to Sound\n"
	append msg	"\n"
	append msg	"Textfile Spectral Data\n"
	append msg	"(Requires NO data on the Chosen Files List)\n"
	append msg	"\n"
	append msg	"Converts (several files of) textfile data\n"
	append msg	"representing the spectrum of some phenomenon\n"
	append msg	"to a sound spectrum.\n"
	append msg	"\n"
	append msg	"Textfile Timeseries Data\n"
	append msg	"(Text datafile(s) must be on the Chosen Files List)\n"
	append msg	"\n"
	append msg	"Converts (several files of) textfile data\n"
	append msg	"representing some phenomena evolving in time\n"
	append msg	"Either to a sound\n"
	append msg	"Or to a control file controlling an input sound\n"
	append msg	"(input sound is entered from the control page).\n"
	Inf $msg
}

#######################
#					  #
#	GRAPHIC DISPLAY	  #
#					  #
#######################

#------ Display a named data file graphically

proc DisplayBrkfileNew {type} {
	global pr_showbrrk bkc evv wstk brrk_curvcnt brrkcolor datosndlist spk
	global bsh bsh_list disppl_c reall_c brrkfrm brrk brrk_fnams
	global brrk_frqmin brrk_frqmax brrk_ampmin brrk_ampmax spc_list brrk_showout
	global init_brrk_fnams init_brrk_range
	global brrk_xdisplay_end_atedge spekdisplaytype_changed
	global orig_brrk_range orig_spek_range previous_brrk_fnams spekshow
	global speks_to_save spekfrm spek spek_frqmin spek_frqmax spek_ampmin spek_ampmax
	global spekouts wl rememd last_spekouts spek_sndtype
	global spekified_output done_spekify set_brrk_range spekgrafrq spek_sndnam
	global readonlyfg readonlybg orig_brrkfrm testmaxspek

	switch -regexp -- $type \
		^$evv(DISPLAY_NEWK)$ \
		^$evv(LOAD_NAMED_DATA_SPEK)$ \
		^$evv(DISPLAY_DATA_SPEK)$ {
			catch {unset testmaxspek}
		}

	catch {unset spk(created)}		;#	FLAG SET IF SPECTRUM CREATED FROM DATA DURING CALL
	catch {unset spk(finalised)}	;#	FLAG THAT PRE-SOUND TRANSFORM SEQUENCE HAS NOT BEEN FINALISED
	catch {unset spk(snd_created)}	;#	FLAG THAT SOUND HAS BEEN GENERATED
	catch {unset spk(pkwid)}		;#	FLAG THAT PEAK-WIDTHS HAVE BEEN EXTRACTED
	catch {unset spk(presndset)}

	if {[info exists spk(zoom)]} {
		if {[info exists brrk_curvcnt] && [info exists orig_disppl_c]} {
			catch {unset disppl_c}
			set kk 0
			while {$kk < $brrk_curvcnt} {
				set disppl_c($kk) $orig_disppl_c($kk)
				incr kk
			}
		}
		unset spk(zoom)
	}

	set spekshow 1					;#	TOGGLE BETWEEN DISPLAYING SINGLE CURVE OF SET, AND SHOWING EVERYTHING EXCEPT DITTO
	set spk(interpd) 0				;#	FLAG SET IF CUBIC SPLINE OR LINEAR INTERPOLATION APPLIED (MUST OCCUR AFTER OTHER TRANSFORMS)
	set spk(mod) 0
	set spek_sndtype 0
	set spekgrafrq ""

	;#	STORE THE LIST OF CURVES IN PLACE AT THE START OF THE CALL, IN CASE CALL ABANDONED

	if {[info exists brrk_fnams]} {
		set previous_brrk_fnams $brrk_fnams
	}
	switch -regexp -- $type \
		^$evv(DELETE_DATA_SPEK)$ {
			set wasspek 0
			if {[info exists spk(display)]} {
				set wasspek 1
				unset spk(display)
			}
			AbandonDataDisplay 1
			if {$wasspek} {
				set spk(display) 1
			}
			DeleteNamedSpekDataListingFile 1
			Inf "Deleted current data info"
			return
		} \
		^$evv(DELETE_NAMED_DATA_SPEK)$ {
			DeleteNamedSpekDataListingFile 0
			return
		} \
		^$evv(LOAD_NAMED_DATA_SPEK)$ {
			if {![LoadNamedSpekDataListingFile]} {
				return
			}
			set type $evv(DISPLAY_DATA_SPEK)
		} \
		^$evv(DISPLAY_ABSNEWK)$ {
			set wasspek 0
			if {[info exists spk(display)]} {
				set wasspek 1
				unset spk(display)
			}
			AbandonDataDisplay 1
			if {$wasspek} {
				set spk(display) 1
			}
			DeleteNamedSpekDataListingFile 1
			RangeOfSelectedSpek 0 0
			set type $evv(DISPLAY_NEWK)
		}

	if {$type != $evv(DISPLAY_NEWK)} {
		;#	IF LOADING AN EXISTING SET OF CURVES, CHECK THEY EXIST

		if {(![info exists brrk_curvcnt] || $brrk_curvcnt == 0) && ![info exists init_brrk_fnams]} {
			Inf "No existing display"
			return
		}
		if {$type == $evv(DISPLAY_DATA_SPEK)} {

			;#	IF LOADING DATA CURVES

			if {![info exists brrk_fnams] && ![info exists init_brrk_fnams]} {
				Inf "No existing display"
				return
			}

			;#	IF DATA CURVES HAVE NOT BEEN USED PREVIOUSLY IN THIS SESSION, SET TO LOAD DATA CURVES SAVED FROM LAST SESSION

			if {![info exists brrk_fnams]} {
				set brrk_fnams $init_brrk_fnams
				set newdisplay 1
			}

			;#	IF LAST DISPLAY WAS NOT (ULTIMATELY) A DATA DISPLAY

			if {[info exists spk(display)]} {

				;#	IF SPECTRAL DATA WAS GENERATED FROM DATA DATA IN LAST SESSION, OPTION TO SAVE THAT SPECTRAL DATA

				if {$spk(ified)} {
					set msg "Do you want to save the spectral curve(s) created previously ??"
					set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						OutputSpectralDataFiles 1
						set spk(ified) 0
					}
					catch {unset speks_to_save}
					set spk(mod) 0
				}
				if {[info exists speks_to_save] || ($spk(mod) > 0)} {
					catch {unset speks_to_save}
					set spk(mod) 0
				}

				;#	DELETE THE SPECTRAL CURVES COORDS

				if {[info exists brrk_curvcnt] && [info exists bsh]} {
					set k 0	
					while {$k < $brrk_curvcnt} {
						catch {$bsh(can) delete cline($k)} in
						if {[info exists disppl_c($k)]} {
							unset disppl_c($k)
						}
						incr k
					}
					set brrk_curvcnt 0
				}

				;#	DESTROY THE DISPLAY

				destroy .show_brkfile2
			}

			;#	IF NEW DISPLAY IS OF DATA NOT YET LOADED IN THIS SESSION, SET CURVE COUNT TO ZERO

			if {[info exists newdisplay]} {
				set brrk_curvcnt 0
				unset newdisplay
			}
		}
	}

	;#	SET UP BASIC DISPLAY PROPERTIES

	set brrk_xdisplay_end_atedge [expr int($evv(XWIDTH) + $evv(BWIDTH))]				

	set evv(DATACOLORS) 16
	set evv(MAXGRAPHS)  256
	set evv(SPEKAMPTOP) 1
	set evv(SPEKAMPBOT) 0
	set evv(SPEKFRQBOT) 0

	set k 0
	while {$k < $evv(MAXGRAPHS)} {
		set thiscolour [expr $k % $evv(DATACOLORS)]
		switch -- $thiscolour {
			0  { set brrkcolor($k) black }
			1  { set brrkcolor($k) firebrick3 }
			2  { set brrkcolor($k) firebrick1 }			
			3  { set brrkcolor($k) DeepPink1 }			
			4  { set brrkcolor($k) magenta1 }			
			5  { set brrkcolor($k) MediumOrchid }			
			6  { set brrkcolor($k) DarkBlue }			
			7  { set brrkcolor($k) DeepSkyBlue3 }			
			8  { set brrkcolor($k) DeepSkyBlue1 }			
			9  { set brrkcolor($k) aquamarine3 }			
			10 { set brrkcolor($k) SeaGreen2 }			
			11 { set brrkcolor($k) chartreuse }			
			12 { set brrkcolor($k) yellow3 }			
			13 { set brrkcolor($k) gold3 }			
			14 { set brrkcolor($k) burlywood3 }			
			15 { set brrkcolor($k) tan4 }			
		}
		incr k
	}
	set evv(SPEKBTNCNT) 32

	set multiple_newfiles 0

	Block "Loading Data"

	if {$type != $evv(DISPLAY_NEWK)} {

		;#	IF SHOWING AN EXISTING DISPLAY
		
		set do_load 0
		if {![info exists brrk_curvcnt] || ($brrk_curvcnt == 0)} {

		;#	IF THERE HAS BEEN NO DISPLAY IN THIS SESSION, LOAD RELEVANT SAVED DISPLAY FROM PREVIOUS SESSION
		
			catch {unset spk(display)}
			set do_load 1

		} else {

		;#	IF THERE HAS BEEN A DISPLAY IN THIS SESSION, BUT LAST DISPLAY WAS NOT OF THE SAME TYPE,LOAD RELEVANT SAVED DISPLAY
		
			if {($type == $evv(DISPLAY_DATA_SPEK)) && [info exists spk(display)]} {
				catch {unset spk(display)}
				set do_load 1
				set brrk_curvcnt 0
			}
		}
		if {$do_load} {
		;#	IF DISPLAY NEEDS LOADING, LOAD EITHER EXISTING DATA FROM A PREVIOUS DISPLAY IN THIS SESSION
		;#	OR SAVED DATA FROM A PREVIOUS SESSION

			if {[info exists spk(display)]} {
				catch {unset spk(display)}
			} else {
				if {[info exists brrk_fnams]} {
					set pre_fnams $brrk_fnams 
					set rerange 1

				} elseif {[info exists init_brrk_fnams]} {
					set pre_fnams $init_brrk_fnams 
					set rerange 1
				}
				;#	IF ORIGINAL RANGE WAS CHANGED, RESET ORIGINAL
				
				if {[info exists rerange]} {
					if {[info exists orig_brrkfrm]} {
						RestoreOrigRanges
					}
				}
			}
			catch {unset orig_brrkfrm}
			set this_indx 0
			foreach fnam $pre_fnams {
				if {![GetRealBrrk_cFromFile $fnam $this_indx]} {
					continue
				}
				set gotit 1
				incr this_indx
			}
			if {$gotit} {
				set brrk_curvcnt $this_indx
			} else {
				Inf "No displayable data extracted"
				UnBlock
				return
			}

			;#	GENERATE CONSTANTS WHICH CONVERT INPUT DATA TO DISPLAY COORDS

			MakeSpekConversionConstants 
		}
		set brrk_lastindx [expr $brrk_curvcnt - 1]
		set last_indx $brrk_lastindx
	} else {

		;#	IF DISPLAYING NEW FILES (RATHER THAN LOADING AN EXISTING DISPLAY) , CHECK FILE TYPES

		catch {unset orig_brrkfrm}
		catch {unset ilist}
		set ilist [$datosndlist curselection]
		if {![info exists ilist] || ([llength $ilist] < 1) || (([llength $ilist] == 1) && ($ilist == -1))} {
			Inf "Select files from listing"	
			UnBlock
			return
		}
		set len [llength $ilist]
		foreach i $ilist {
			set fnam [$datosndlist get $i]
			lappend fnams $fnam
		}
		if {$len > 1} {
			set multiple_newfiles 1
		}

		set OK 1
		if {![info exists brrk_curvcnt] || ![info exists brrkfrm(lo)]} {
			set OK 0
		}

		;#	IF NO CURVES ALREADY DISPLAYED, CHECK TYPE OF DISPLAY (SPECTRAL OR DATA)

		if {!$OK} {
			set brrk_curvcnt 0
			set ext [CheckForSpecExtensions $fnams]
			if {!$ext} {
				UnBlock
				return
			}
			catch {unset spk(display)}
			set totalgraphs $len
			if {$totalgraphs > $evv(MAXGRAPHS)} {
				set msg "Too many overlaid displays (max $evv(MAXGRAPHS))"
				UnBlock
				return
			}
		} else {

		;#	ELSE, CHECK DATA-TYPE AGAINST TYPE OF ALREADY DISPLAYED CURVES: SET FLAG IF DISPLAY-TYPE CHANGED

			set ext [CheckForSpecExtensions $fnams]
			switch -- $ext {
				0 { 
					UnBlock
					return 
				}
				1 {
					if {[info exists spk(display)] && $spk(ified)} {
						set msg "Do you want to save the spectral output you created previously ??"
						set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
						if {$choice == "yes"} {
							OutputSpectralDataFiles 1
						}
					}
					catch {unset speks_to_save}
					set spk(mod) 0
					AbandonDataDisplay 0
					if {[info exists brrk_fnams]} {
						set brrk_curvcnt [llength $brrk_fnams]
					} else {
						set brrk_curvcnt 0
					}
					set spekdisplaytype_changed 1
				}
			}
			set totalgraphs [expr $len + $brrk_curvcnt]

		;#	CHECK NO CURVE-DISPLAY IS DUPLICATED

			catch {unset dupls}
			if {[info exists brrk_fnams]} {
				foreach fnam $fnams {
					if {[lsearch $brrk_fnams $fnam] >= 0} {
						lappend dupls $fnam
					}
				}
			}
			if {[info exists dupls]} {
				set msg "Some of these graphs are already displayed\n"
				set cnt 0
				foreach fnam $dupls {
					append msg "$fnam\n"
					incr cnt
					if {$cnt >= 20} {
						append msg "and more"
						break
					}
				}
				Inf $msg
				UnBlock
				return
			}

		;#	IF TOO MANY CURVES IN TOTAL, MAKE SOME SPACE, OR START AGAIN

			if {$totalgraphs > $evv(MAXGRAPHS)} {
				set msg "too many overlaid displays (max $evv(MAXGRAPHS))"
				if {$len == 1} {
					append msg "\n\nDelete last curve drawn ??"
				} else {
					append msg "\n\nDelete [expr $totalgraphs - $evv(MAXGRAPHS)] last curves drawn ??"
				}
				set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
				if {$choice == "yes"} {
					set current_brrk_curvcnt $brrk_curvcnt
					set brrk_curvcnt [expr $evv(MAXGRAPHS) - $len]
					set k $brrk_curvcnt
					while {$k < $current_brrk_curvcnt} {
						ClearBrrkpnt $k 1
						incr k
					}
					if {$brrk_curvcnt == 0} {
						unset brrk_fnams
					} else {
						set brrk_fnams [lrange $brrk_fnams 0 [expr $brrk_curvcnt - 1]]
					}
				} else {
					set msg "Start afresh ??"
					set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						ClearBrrkDisplay $brrk_curvcnt 1
						set brrk_curvcnt 0
						unset brrk_fnams
					} else {
						UnBlock
						return
					}
				}
			}
		}									

		;#	READ PARAMETERS OF NEW CURVE(S) FROM FILE(S)

		set brrk_lastindx $brrk_curvcnt
		if {$multiple_newfiles} {
			set start_indx $brrk_curvcnt
			foreach i $ilist {
				set fnam [$datosndlist get $i]
				if {![GetRealBrrk_cFromFile $fnam $brrk_lastindx]} {
					UnBlock
					return
				}
				incr brrk_lastindx
			}
			set brrk_curvcnt $brrk_lastindx
			incr brrk_lastindx -1
		} else {
			if {![GetRealBrrk_cFromFile $fnam $brrk_lastindx]} {
				UnBlock
				return
			}
			incr brrk_curvcnt
		}
		;#	UPDATE THE LIST OF CURVES
		
		if {[info exists brrk_fnams]} {
			set brrk_fnams [concat $brrk_fnams $fnams]
		} else {
			set brrk_fnams $fnams
		}
	}
	UnBlock
	set spk(ified) 0						;#	FLAG SET IF DATA CONVERTED TO PLAYABLE FORMAT
	set spk(inverted) 0
	set spk(iso) 0
	set spekified_output 0
	DeleteAllTemporaryFiles

	catch {unset speks_to_save}		;#	FLAGS THAT SPECTRA HAVE BEEN CREATED FROM DATA, BUT NOT YET SAVED
	set brrk_showout 0
	set f .show_brkfile2
	if [Dlg_Create $f "Data Display" "SpecLeave" -borderwidth $evv(BBDR)] {
		set ff [frame $f.btns -borderwidth 0]
		set fo [frame $f.outs -borderwidth 0]

		button $ff.nu  -text "Quit" -command {set pr_showbrrk 1} -bg $evv(EMPH)  -highlightbackground [option get . background {}]
		button $ff.es  -text "Abandon" -command {SpecLeave}  -highlightbackground [option get . background {}]
		button $ff.k -text "K" -highlightbackground [option get . background {}] -command "Shortcuts spek" -width 2
		button $ff.hlp -text "Help" -highlightbackground [option get . background {}] -command {ActivateHelp .show_brkfile2.btns} -width 4
		label  $ff.conn -text "" -width 13
		button $ff.con -text "" -borderwidth 0 -state disabled -width 8  -highlightbackground [option get . background {}]
		label $ff.help -width 48 -text "$evv(HELP_DEFAULT)"

		pack $ff.es -side left -padx 8
		pack $ff.k $ff.hlp $ff.conn $ff.con $ff.help -side left -padx 2

		button $fo.out  -text "Output Spectral Data" -command {set pr_showbrrk 3}  -highlightbackground [option get . background {}]
		label $fo.ll -text "Outfile Name "
		entry $fo.ee -textvariable spekoutname -width 32
		
		pack $fo.out $fo.ll $fo.ee -side left -padx 2
		button $fo.all -text "Show All" -command {SelectSpekDisplay all} -background $evv(EMPH) -width 8  -highlightbackground [option get . background {}]
		radiobutton $fo.show -text show -variable spekshow -value 1 -command SpekShowSwitch
		radiobutton $fo.hide -text hide -variable spekshow -value 0 -command SpekShowSwitch
		button $fo.top -text "Max" -command ShowMaxSpec  -highlightbackground [option get . background {}]
		button $fo.toptest -text "Test Max" -command TestMaxSpec -width 8  -highlightbackground [option get . background {}]
		pack $fo.all -side left -padx 8
		pack $fo.show $fo.hide $fo.top $fo.toptest -side left
		menubutton $ff.mod1 -text "Create/Modify Spectrum" -menu $ff.mod1.menu -relief raised -width 20
		set men1 [menu $ff.mod1.menu -tearoff 0]

		$men1 add command -label "Establish sound spectrum metrics" -command {} -background $evv(HELP)
		$men1 add separator
		$men1 add command -label "Sample rate of sound output" -command {SetSpekSamprate}
		$men1 add separator
		$men1 add command -label "Spectral channel count" -command {SetSpekChancnt}
		$men1 add separator
		$men1 add command -label "Convert to sound spectrum metrics (Stage 1)" -command {} -background $evv(HELP)
		$men1 add separator
		$men1 add command -label "Convert to sound spectrum metrics" -command {ConvertFromDataToSpectralRange 0}
		$men1 add separator
		$men1 add command -label "Modify spectral range (Stage 2)" -command {} -background $evv(HELP)
		$men1 add separator
		$men1 add command -label "Reset max amplitude of data"  -command {VerticalUpperLimitOfData 0}
		$men1 add command -label "Exaggerate/flatten amplitude" -command {ExaggerateFlattenVerticalDisplay 0}
		$men1 add separator
		$men1 add command -label "Set frq limits of data"	 -command {SetHorizontalRangeOfData 0}
		$men1 add command -label "Expand/contract frq range" -command {ExpandContractHorizontalRange 0}
		$men1 add command -label "Shift frq range"			 -command {ShiftHorizontalDataRange 0}
		$men1 add command -label "Warp freq range"			 -command {WarpHorizontalDisplay 0}
		$men1 add separator
		$men1 add command -label "Reset to original spectra" -command {ResetOriginalDataRange}
		$men1 add separator
		$men1 add command -label "Smooth curve (Stage 3)" -command {} -background $evv(HELP)
		$men1 add separator
		$men1 add command -label "Cubic spline" -command {CubicSplineSmoothing 0}
		$men1 add separator
		$men1 add command -label "Linear interpolation" -command {LinearSmoothing 0}
		$men1 add separator
		$men1 add command -label "Other modifications (Stage 4)" -command {} -background $evv(HELP)
		$men1 add separator
		$men1 add command -label "Invert (troughs to peaks)" -command {SpekInvertNotches 0}
		$men1 add separator
		$men1 add command -label "Isolate peaks" -command {SpekIsolatePeaks 0}
		$men1 add separator
		$men1 add command -label "Store peak widths" -command {GenerateSpekPeakWidths 0}
		$men1 add separator
		$men1 add command -label "Backtrack" -command {} -background $evv(HELP)
		$men1 add separator
		$men1 add command -label "Undo last change" -command {UndoLastSpekChange}
		$men1 add separator
		$men1 add command -label "Remember" -command {} -background $evv(HELP)
		$men1 add separator
		$men1 add command -label "Retain pre-sound transform sequence" -command {KeepPreSound}

		menubutton $ff.mod2 -text "Generate Sound" -menu $ff.mod2.menu -relief raised -width 17
		set men2 [menu $ff.mod2.menu -tearoff 0]

		$men2 add command -label "Establish sound duration" -command {} -background $evv(HELP)
		$men2 add separator
		$men2 add command -label "Duration of output sounds" -command {SetSpekDuration}
		$men2 add separator
		$men2 add command -label "Conversion to sound" -command {} -background $evv(HELP)
		$men2 add separator
		$men2 add command -label "Convert to playable data (Stage 1)" -command {GenerateSpektra 0}
		$men2 add separator
		$men2 add command -label "Convert to sound (Stage 2)" -command {CreateFixedSpectrumSound 0}
		$men2 add separator
		$men2 add command -label "Play sound (Space)" -command {} -background $evv(HELP)
		$men2 add separator -background $evv(EMPH)
		$men2 add command -label "Play sound output" -command {PlaySpekOutput 1} -background $evv(EMPH)
		$men2 add separator
		$men2 add command -label "Play previous outputs" -command {PlaySpekOutput 0}
		$men2 add separator
		$men2 add command -label "Modify sound (Space)" -command {} -background $evv(HELP)
		$men2 add separator -background $evv(EMPH)
		$men2 add command -label "Get output level" -command {GetSpekOutputLevel}
		$men2 add separator
		$men2 add command -label "Modify level value of transform process" -command {ModifyTransformLevel}
		$men2 add separator
		$men2 add command -label "Trim trailing silence" -command {SpekTrim}

		button $ff.view -text "View" -command {set pr_showbrrk 2} -bg $evv(SNCOLOR)  -highlightbackground [option get . background {}]

		menubutton $ff.trn -text "Save/Use Transforms" -menu $ff.trn.menu -relief raised -width 17
		set men3 [menu $ff.trn.menu -tearoff 0]
		$men3 add command -label "Save transform sequence" -command {} -background $evv(HELP)
		$men3 add separator
		$men3 add command -label "Save+name current transform sequence" -command {SaveAndNameCurrentTransform $evv(SPEKT_POSTSND)}
		$men3 add separator
		$men3 add command -label "Set current transform sequence as default" -command {SetCurrentTransformAsDefault 1}
		$men3 add separator
		$men3 add command -label "Apply" -command {} -background $evv(HELP)
		$men3 add separator -background $evv(EMPH)
		$men3 add command -label "Apply default transform sequence" -command {ApplyDefaultTransform} -background $evv(EMPH)
		$men3 add separator -background $evv(EMPH)
		$men3 add command -label "Get or delete" -command {} -background $evv(HELP)
		$men3 add separator
		$men3 add command -label "Get named transform sequence as default" -command {GetANamedTransform 0}
		$men3 add separator
		$men3 add command -label "Modify level value of transform process" -command {ModifyTransformLevel}
		$men3 add separator
		$men3 add command -label "Delete a named transform sequence" -command {GetANamedTransform 1}

		pack $ff.nu $ff.trn $ff.view $ff.mod2 $ff.mod1 -side right -padx 2

		set ff2 [frame $f.btns2 -borderwidth 0]
		set ff3 [frame $f.btns3 -borderwidth 0]
		set ff4 [frame $f.btns4 -borderwidth 0]
		set ff5 [frame $f.btns5 -borderwidth 0]
		set ff6 [frame $f.btns6 -borderwidth 0]
		set ff7 [frame $f.btns7 -borderwidth 0]
		set ff8 [frame $f.btns8 -borderwidth 0]
		set ff9 [frame $f.btns9 -borderwidth 0]
		set kk 0
		set jj 1
		while {$kk < $evv(MAXGRAPHS)} {
			set col [expr ($kk/$evv(SPEKBTNCNT)) + 2] 
			set thiscolour [expr $kk % $evv(DATACOLORS)]
			button $ff$col.$jj -text $jj -command "BrrkList $kk 1 0" -bg $brrkcolor($thiscolour) -fg white -width 2
			pack $ff$col.$jj -side left
			incr kk
			incr jj
		}
		button $ff2.movie -text "Movie" -command {SpekMovie} -width 8  -highlightbackground [option get . background {}]
		button $ff3.msp -text "Speed" -command {SetSpekMovieSpeed} -width 8  -highlightbackground [option get . background {}]
		pack $ff2.movie -side left -padx 8
		pack $ff3.msp -side left -padx 8
		button $ff4.zoom -text "Zoom" -command {SetSpekZoom 1} -width 8  -highlightbackground [option get . background {}]
		pack $ff4.zoom -side left -padx 8
		entry $ff9.frq -textvariable spekgrafrq -width 8 -state readonly -fg $readonlyfg -readonlybackground $readonlybg
		pack $ff9.frq -side left -padx 8
		label $ff9.frqa -text "Frq" -width 3 
		pack $ff9.frqa -side left

		frame $ff4.title
		label $ff4.title.title -text "Data Display" -fg $evv(SPECIAL) -font bigfont -width 40
		pack $ff4.title.title -side top -anchor center

		frame $ff9.data
		label $ff9.data.ll -text "Data from curve     " -bg white
		pack $ff9.data.ll -side left -padx 2

		label $ff9.spec -text "Files sourced"

		pack $ff4.title -side right

		pack $ff9.spec $ff9.data -side right -padx 16


		#	CANVAS AND VALUE LISTING

		set bsh(can) [canvas $f.c -height $bkc(height) -width $bkc(width) -borderwidth 0 \
			-highlightthickness 1 -highlightbackground $evv(SPECIAL) -background white]
		set z [frame  $f.l -borderwidth $evv(SBDR)]
		frame $f.s
		set bsh_list [Scrolled_Listbox $z.ll -width 32 -height 32 -selectmode single]
		frame $bsh_list.f -bd 0
		pack $z.ll -side left -fill both -expand true
		set spc_list [Scrolled_Listbox $f.s.ll -width 32 -height 32 -selectmode single]
		pack $f.s.ll -side left -fill both -expand true
		pack $f.btns -side top -fill x 
		pack $f.outs -side top -fill x -pady 10
		pack $f.btns2 $f.btns3 $f.btns4 $f.btns5 $f.btns6 $f.btns7 $f.btns8 $f.btns9 -side top -fill x 
		pack $f.c $f.l $f.s -side left -fill both
		$bsh(can) create rect $bkc(rectx1) $bkc(recty1) $bkc(rectx2) $bkc(recty2) -tag outline
		bind $f <Key-space> {PlaySpekOutput 1}
		bind $f <Control-Escape> {SpecLeave}
		bind $f <Escape> {QuitAndDisplayMaxGraph 0}
		bind $f <Return> {ApplyDefaultTransform}
		bind $f <Key-#>  {GetANamedTransform 0}
		bind $f <Control-Key-1> {DoSpekMaxima}
		bind $spc_list <ButtonRelease-1> {DoBrrkList %y}
		bind $bsh(can) <ButtonPress-1> {SpekShowFrq %x}
		wm resizable $f 0 0
	}
	.show_brkfile2.outs.toptest config -text "" -bd 0 -command {}
	set msg "Data Display of [file rootname [file tail [lindex $brrk_fnams 0]]]"
	if {[llength $brrk_fnams] > 1} {
		append msg " ETC."
	}
	wm title .show_brkfile2 $msg
	set spekoutname ""
	ToggleBrrkTitle
	set isspek 0
	Block "Displaying Data"
	if {$type == $evv(DISPLAY_NEWK)} {
		if {$multiple_newfiles} {
			set this_indx $start_indx
			set z 0
			while {$this_indx < $brrk_curvcnt} {
				wm title .blocker  "PLEASE WAIT:      Displaying file [expr $this_indx + 1]"
				set i [lindex $ilist $z]
				set thisfnam [$datosndlist get $i]
				if {$this_indx > 0} {

				;#	CHECK NEW RANGE AGAINST EXISTING RANGE

					set OK 1				
					if {($brrk_ampmin($this_indx) < $brrkfrm(lo)) || $brrk_ampmax($this_indx) > $brrkfrm(hi) \
					|| $brrk_frqmin($this_indx) < $brrkfrm(startfreq) || $brrk_frqmax($this_indx) > $brrkfrm(endfreq)} {
						set OK 0
					}
					if {!$OK} {
						set msg "DATA IN FILE [file rootname [file tail $thisfnam]] IS OUT OF RANGE\n"
						if {$brrk_ampmin($this_indx) < $brrkfrm(lo)} {
							append msg "\nMin of amp range = $brrkfrm(lo) Min amp in file = $brrk_ampmin($this_indx)"
						}
						if {$brrk_ampmax($this_indx) > $brrkfrm(hi)} {
							append msg "\nMax of amp range = $brrkfrm(hi) Max amp in file = $brrk_ampmax($this_indx)"
						}
						if {$brrk_frqmin($this_indx) < $brrkfrm(startfreq)} {
							append msg "\nMin of freq range = $brrkfrm(startfreq) Min of freq in file = $brrk_frqmin($this_indx)"
						}
						if {$brrk_frqmax($this_indx) > $brrkfrm(endfreq)} {
							append msg "\nMax of freq range = $brrkfrm(endfreq) Max of freq in file = $brrk_frqmax($this_indx)"
						}
						Inf $msg
						ClearBrrkDisplay $this_indx 1
						catch {unset brrk_curvcnt}
						if {[info exists previous_brrk_fnams]} {
							set brrk_fnams $previous_brrk_fnams
						} else {
							unset brrk_fnams 
						}
						UnBlock
						Dlg_Dismiss $f
						return
					}

				} else {
					set gotrange 0
					if {[info exists set_brrk_range]} {
						set rangelims $set_brrk_range
						set orig_brrk_range $rangelims
						unset set_brrk_range
						set gotrange 1
					} elseif {[info exists orig_brrk_range]} {
						set msg "Retain original ranges ??"
						set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
						if {$choice == "yes"} {
							set rangelims $orig_brrk_range
							set gotrange 1
						}
					}
					if {!$gotrange} {
						set rangelims [SpecifyBrrkRange $brrk_ampmin($this_indx) $brrk_ampmax($this_indx) $brrk_frqmin($this_indx) $brrk_frqmax($this_indx)]
						set orig_brrk_range $rangelims
						if {[llength $rangelims] <= 0} {
							catch {unset brrk_curvcnt}
							catch {unset brrk}
							catch {unset brrkfrm}
							UnBlock
							destroy $f
							return
						}
					}
					set brrkfrm(lo) [lindex $rangelims 0]
					set brrkfrm(hi) [lindex $rangelims 1]
					set brrkfrm(startfreq) [lindex $rangelims 2]
					set brrkfrm(endfreq) [lindex $rangelims 3]
					set brrk(range) [expr $brrkfrm(hi) - $brrkfrm(lo)]
					set brrk(real_startfreq) $brrkfrm(startfreq)
					set brrk(real_endfreq) $brrkfrm(endfreq)
					EstablishGrafToRealConversionConstantsBrrk
					EstablishCoordsOnGrafDisplay
				}
				if {$spekdisplaytype_changed} {
					EstablishGrafToRealConversionConstantsBrrk
					EstablishCoordsOnGrafDisplay
					set spekdisplaytype_changed 0
				}
				GetGraphCoordsAndDrawCurve $this_indx $isspek
				incr this_indx
				incr z
			}
			set brrk_curvcnt $this_indx
			set last_indx [expr $this_indx - 1]
		} else {
			set this_indx [expr $brrk_curvcnt - 1]
			if {$brrk_curvcnt > 1} {
			;#	CHECK NEW RANGE AGAINST OLD RANGE
				set OK 1
				if {($brrk_ampmin($this_indx) < $brrkfrm(lo)) || $brrk_ampmax($this_indx) > $brrkfrm(hi) \
				|| $brrk_frqmin($this_indx) < $brrkfrm(startfreq) || $brrk_frqmax($this_indx) > $brrkfrm(endfreq)} {
					set OK 0
				}
				if {!$OK} {
					set msg "new data is out of range: start a new display ??"
					set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						ClearBrrkDisplay $brrk_curvcnt 1
						catch {unset brrk_curvcnt}
						if {[info exists spk(display)]} {
							catch {unset spek}
							catch {unset spekfrm}
						} else {
							catch {unset brrk_fnams}
							catch {unset brrk}
							catch {unset brrkfrm}
						}
						if {[info exists orig_brrk_range]} {
							unset orig_brrk_range
						}
						destroy $f
					} else {
						if {$brrk_curvcnt > 0} {
							incr brrk_curvcnt -1
						}
						if {[info exists previous_brrk_fnams]} {
							set brrk_fnams $previous_brrk_fnams
						} else {
							unset brrk_fnams 
						}
						Dlg_Dismiss $f
					} 
					UnBlock
					return
				}
				if {$spekdisplaytype_changed} {
					EstablishGrafToRealConversionConstantsBrrk
					EstablishCoordsOnGrafDisplay
					set spekdisplaytype_changed 0
				}
			} else {
				set gotrange 0
				if {[info exists set_brrk_range]} {
					set rangelims $set_brrk_range
					set orig_brrk_range $rangelims
					unset set_brrk_range
					set gotrange 1
				} elseif {[info exists orig_brrk_range]} {
					set msg "Retain original ranges ??"
					set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						set rangelims $orig_brrk_range
						set gotrange 1
					}
				}
				if {!$gotrange} {
					set rangelims [SpecifyBrrkRange $brrk_ampmin($this_indx) $brrk_ampmax($this_indx) $brrk_frqmin($this_indx) $brrk_frqmax($this_indx)]
					if {[llength $rangelims] <= 0} {
						if {[info exists previous_brrk_fnams]} {
							set brrk_fnams $previous_brrk_fnams
						} else {
							unset brrk_fnams 
						}
						destroy $f
						UnBlock
						return
					}
					set orig_brrk_range $rangelims
				}
				set brrkfrm(lo) [lindex $rangelims 0]
				set brrkfrm(hi) [lindex $rangelims 1]
				set brrkfrm(startfreq) [lindex $rangelims 2]
				set brrkfrm(endfreq) [lindex $rangelims 3]
				set brrk(range) [expr $brrkfrm(hi) - $brrkfrm(lo)]
				set brrk(real_startfreq) $brrkfrm(startfreq)
				set brrk(real_endfreq) $brrkfrm(endfreq)
				EstablishGrafToRealConversionConstantsBrrk
				EstablishCoordsOnGrafDisplay
			}
			GetGraphCoordsAndDrawCurve $this_indx $isspek
		}

		if {$spekdisplaytype_changed} {					;#	If display is changed data->spec or vv, redraw the previously existing curves
			set lim [expr $brrk_curvcnt - 1]
			set k 0
			while {$k < $lim} {
				GetGraphCoordsAndDrawCurve $k $isspek
				incr k
			}
		}
	} else {
		MakeSpekConversionConstants
		EstablishCoordsOnGrafDisplay
		GetExistingRangesFromData $brrk_curvcnt
		set k 0
		while {$k < $brrk_curvcnt} {
			wm title .blocker  "PLEASE WAIT:      Displaying file [expr $k + 1]"
			GetGraphCoordsAndDrawCurve $k $isspek
			incr k
		}
	}
	$bsh_list delete 0 end
	set spacer "    "
	set last_indx [expr $brrk_curvcnt - 1]
	BrrkList $last_indx 0 0
	$spc_list delete 0 end
	foreach f_nam $brrk_fnams {
		$spc_list insert end $f_nam
	}
	if {[info exists this_indx]} {
		.show_brkfile2.btns9.data.ll config -text "Data from curve [file rootname [file tail $f_nam]]" -fg $brrkcolor($this_indx)
	} else {
		.show_brkfile2.btns9.data.ll config -text "Data from curve [file rootname [file tail $f_nam]]" -fg $brrkcolor($last_indx)
	}
	UnBlock
	set pr_showbrrk 0
	raise $f
	set finished 0
	My_Grab 0 $f pr_showbrrk											
	while {!$finished} {
		tkwait variable pr_showbrrk
		catch {unset resetdata}
		switch -- $pr_showbrrk {
			0 {
				set msg "You can remember the files from which these curves derive."
				append msg "\n\nAre you sure you want to forget them ?"
				set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					SaveNamedSpekDataListingFile
				} else {
					AbandonDataDisplay 1
				}
				if {[info exists spk(snd_created)] && ($spk(snd_created) > 0) && [info exists spekouts] && ([llength $spekouts] > 0)} {
					set msg "Delete the sound generated ?"
					set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						set fnam [lindex $spekouts end]
						set save_mixmanage 0
						if [DeleteFileFromSystem $fnam 1 1] {
							DummyHistory $fnam "DESTROYED"
							if {[MixMDelete $fnam 0]} {
								set save_mixmanage 1
							}
							if {[IsInAMixfile $fnam]} {
								lappend delete_mixmanage $fnam
							}
							set i [LstIndx $fnam $wl]
							if {$i >= 0} {
								WkspCnt [$wl get $i] -1
								$wl delete $i
							}
							catch {unset rememd}
							if {[info exists delete_mixmanage]} {
								if {[MixM_ManagedDeletion $delete_mixmanage]} {
									set save_mixmanage 1
								}
							}
							if {$save_mixmanage} {
								MixMStore
							}
							if {[info exists last_spekouts]} {
								set kj [lsearch $last_spekouts $fnam]
								while {$kj >= 0} {
									set last_spekouts [lreplace $last_spekouts $kj $kj]
									set kj [lsearch $last_spekouts $fnam]
								}
								if {[llength $last_spekouts] <= 0} {
									unset last_spekouts
								}
							}
						}
					}
				}
			}
			1 {
				if {$spk(ified) && !$spekified_output} {
					set msg "Save the spectral data ??"
					set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						if {![OutputSpectralDataFiles 0]} {
							continue
						}
					}
				}
				if {[info exists speks_to_save] || ($spk(mod) > 0)} {
					if {[info exists spk(created)]} {
						RestoreDisplayOfDataSource				;#	If spectrum created from data source
					}											;#	Force display-coords back to original state
					catch {unset speks_to_save}
					set spk(mod) 0
				}
				CheckTransformStatus 1
			}
			2 {
				if {![info exists spek_sndnam]} {
					Inf "No output file to display"
					continue
				}
				set outnam [file rootname $spek_sndnam]
				if {($brrk_curvcnt > 1) && !$spk(vary)} {
					append outnam 0
				}
				append outnam $evv(SNDFILE_EXT)
				if {![file exists $outnam]} {
					Inf "No output file '$outnam' to display"
					continue
				} elseif {($brrk_curvcnt > 1) && !$spk(vary)} {
					set msg "Can display first of outputs only: ok ?"
					set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
				}
				SnackDisplay 0 $evv(SN_FILE_PRMPAGE_NO_OUTPUT) 0 $outnam
				continue
			}
			3 {
				if {$spk(ified) || [info exists done_spekify]} {
					OutputSpectralDataFiles 0
					set spekified_output 1
					catch {unset done_spekify}
				} else {
					Inf "no spectral data generated"
				}
				continue
			}
		}
		break
	}
	if {$spekified_output} {
		set spk(ified) 0
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return
}

proc SpecLeave {} {
	global testmaxspek pr_showbrrk
	catch {unset testmaxspek} 
	set pr_showbrrk 0
}


#------- Display largest value graph

proc ShowMaxSpec {} {
	global spk
	if {![info exists spk(top)]} {
		Inf "No maximal graph to display"
		return 0
	}
	BrrkList $spk(top) 1 0
	.show_brkfile2.outs.toptest config -text "Test Max" -bd 2 -command {TestMaxSpec}
	return 1
}

proc TestMaxSpec {} {
	global testmaxspek wstk brrk_curvcnt
	Inf "From data selection page, choose \"draw (different) graph(s)\".\n\nor use \"#\" key"
	set testmaxspek [expr 1.0/double($brrk_curvcnt)]
	QuitAndDisplayMaxGraph 1
}

proc DoSpekMaxima {}  {
	if {[ShowMaxSpec]} {
		TestMaxSpec
	}
}

#------- Highlght max graph on quitting display

proc QuitAndDisplayMaxGraph {grp} {
	global spk brrk_fnams datosndlist pr_showbrrk testmaxspek
	set kmin -1
	if {[info exists spk(top)]} {
		set fnam [lindex $brrk_fnams $spk(top)]
		set kmin [LstIndx $fnam $datosndlist]
	}
	if {!$grp} {
		catch {unset testmaxspek}
	}
	set pr_showbrrk 1
	if {$kmin >= 0} {
		$datosndlist selection clear 0 end
		if {$grp} {
			set topoflisting [expr [$datosndlist index end] - 1]
			set topofset [expr [llength $brrk_fnams] - 1]
			set setlo [expr $spk(top) - 2]
			if {$setlo < 0} {
				set setlo 0
			}
			set sethi $setlo
			incr sethi 4
			if {$sethi > $topofset} {
				set sethi $topofset
			}
			set setindex $setlo
			set kmin [$datosndlist index end]
			incr kmin 2
			while {$setindex <= $sethi} {
				set fnam [lindex $brrk_fnams $setindex]
				set k [LstIndx $fnam $datosndlist]
				if {$k < $kmin} {
					set kmin $k
				}
				$datosndlist selection set $k
				incr setindex
			}
			set len [expr $sethi - $setlo]
			incr len 1
			if [info exists testmaxspek] {							;#	testmaxspek is 1/totalsetlen
				set testmaxspek [expr $testmaxspek * double($len)]	;#	testmaxspek is peaksetlen/totalsetlen
			}
		} else {
			$datosndlist selection set $kmin
		}
		if {$kmin > 32} {
			set kmin [expr double($kmin) / double([$datosndlist index end])]
			$datosndlist yview moveto $kmin
		}
	}
}

#----- Deleting graphs from display

proc ClearBrrkpnt {k wipe} {
	global bsh disppl_c reall_c brrk spk
	catch {$bsh(can) delete cline($k)}  in
	catch {$bsh(can) delete points($k)} in
	catch {unset disppl_c($k)} in
	if {$wipe} {
		if {[info exists spk(display)]} {
			catch {unset spek_c($k)} in
		} else {
			catch {unset reall_c($k)} in
		}
	}
	set brrk($k,coordcnt) 0
}

proc ClearBrrkDisplay {this_indx wipe} {
	global bsh bsh brrk_curvcnt brrk_fnams init_brrk_fnams

	if {[string match $this_indx "none"]} {	;#	If Func Called but no brrk_curvcnt set

		if {![info exists bsh(can)]} {		;#	If no curves have been drawn (very start of session), quit
			return
		} else						 {		;#	Else a display previously existed, but has been Abandoned.
			set this_indx 0					;#	find how many drawn curves need to be deleted
			if {![catch {set zzz [$bsh(can) find withtag cline($this_indx)]} zit]} {
				while {[llength $zzz] > 0} {
					incr this_indx		
					set zzz [$bsh(can) find withtag cline($this_indx)]
				}
			}
			set brrk_curvcnt $this_indx		;#	Avoids "none" version being called a 2nd time
		}
	}
	set k 0
	while {$k < $this_indx} {
		ClearBrrkpnt $k $wipe
		incr k
	}
	catch {$bsh(can) delete rangeinfo} in
	catch {$bsh(can) delete zinfo)} in
	catch {$bsh(can) delete endinfo} in
}

#---- Specify the vertical range of the display

proc SpecifyBrrkRange {amplo amphi frqlo frqhi} {
	global pr_brrkrange brrk_amptop brrk_ampbot brrk_frqtop brrk_frqbot pprg mmod maxsamp_line brrk_outlist evv

	set f .brrkrange

	if [Dlg_Create $f "Specify Range" "set pr_brrkrange 0" -borderwidth 2 -width 80] {
		frame $f.0
		button $f.0.s -text "OK" -command "set pr_brrkrange 1" -width 8  -highlightbackground [option get . background {}]
		label $f.0.ll -text "\"#\" sets Top of Range to 1, and quits" -fg $evv(SPECIAL)  -highlightbackground [option get . background {}]
		button $f.0.q -text "Abandon" -command "set pr_brrkrange 0" -width 8  -highlightbackground [option get . background {}]
		pack $f.0.s $f.0.ll -side left -padx 4
		pack $f.0.q -side right

		frame $f.1
		label $f.1.s -text "Top of Amplitude Range (max [expr int(round($amphi))])" -width 25
		entry $f.1.e -textvariable brrk_amptop -width 16
		pack $f.1.s -side left -padx 2
		pack $f.1.e -side right

		frame $f.2
		label $f.2.s -text "Bottom of Amplitude Range (min [expr int(round($amplo))])" -width 44
		entry $f.2.e -textvariable brrk_ampbot -width 16
		pack $f.2.s -side left
		pack $f.2.e -side right

		frame $f.3
		label $f.3.s -text "Top of Frequency Range (max [expr int(round($amphi))])" -width 25
		entry $f.3.e -textvariable brrk_frqtop -width 16
		pack $f.3.s -side left -padx 2
		pack $f.3.e -side right

		frame $f.4
		label $f.4.s -text "Bottom of Frequency Range (min [expr int(round($amplo))])" -width 44
		entry $f.4.e -textvariable brrk_frqbot -width 16
		pack $f.4.s -side left
		pack $f.4.e -side right

		pack $f.0 -side top -fill x -expand true
		pack $f.1 -side top -fill x -expand true
		pack $f.2 -side top -fill x -expand true
		pack $f.3 -side top -fill x -expand true
		pack $f.4 -side top -fill x -expand true
		bind $f.1.e <Down> "focus $f.2.e"
		bind $f.2.e <Down> "focus $f.3.e"
		bind $f.3.e <Down> "focus $f.4.e"
		bind $f.4.e <Down> "focus $f.1.e"
		bind $f.1.e <Up> "focus $f.4.e"
		bind $f.2.e <Up> "focus $f.1.e"
		bind $f.3.e <Up> "focus $f.2.e"
		bind $f.4.e <Up> "focus $f.3.e"
		bind $f <Return> "set pr_brrkrange 1" 
		bind $f <Escape> "set pr_brrkrange 0" 
		bind $f <Key-#> {set brrk_amptop 1; set pr_brrkrange 1} 
		wm resizable $f 0 0
	}
	set brrk_amptop $amphi
	set brrk_ampbot $amplo
	set brrk_frqtop $frqhi
	set brrk_frqbot $frqlo
	set pr_brrkrange 0
	update idletasks
	raise $f
	update idletasks
	My_Grab 0 $f pr_brrkrange $f.1.e
	update idletasks
	set finished 0
	while {!$finished} {
		tkwait variable pr_brrkrange
		switch -- $pr_brrkrange {
			1 {
				if {![IsNumeric $brrk_amptop] || ![IsNumeric $brrk_ampbot] || ![IsNumeric $brrk_frqtop] || ![IsNumeric $brrk_frqbot]} {
					Inf "Invalid value(s) entered"
					continue
				}
				if {$brrk_amptop <= $brrk_ampbot} {
					Inf "Amplitude range too small, or negative"
					continue
				}
				if {$brrk_frqtop <= $brrk_frqbot} {
					Inf "Frequency range too small, or negative"
					continue
				}
				if {($brrk_amptop < $amphi) || ($brrk_ampbot > $amplo)} {
					Inf "Amplitude range set does not span range of data to display"
					continue
				}
				if {($brrk_frqtop < $frqhi) || ($brrk_frqbot > $frqlo)} {
					Inf "Frequency range set does not span range of data to display"
					continue
				}
				set brrk_outlist [list $brrk_ampbot $brrk_amptop $brrk_frqbot $brrk_frqtop]
				set finished 1
			} 
			0 {
				set brrk_outlist {}
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $brrk_outlist
}

#------ Get Brkfile Data from file

proc GetRealBrrk_cFromFile {fnam this_indx} {
	global reall_c spek_c brrk brrk_frqmin brrk_frqmax brrk_ampmin brrk_ampmax evv spk
	global spek_frqmin spek_frqmax spek_ampmin spek_ampmax

	if [catch {open $fnam r} fileId] {
		Inf "Cannot open file $fnam to display it."	;#	open the brkfile
		return 0
	}
	set valcnt 0
	if {[info exists spk(display)]} { 
		catch {unset spek_c($this_indx)}
	} else {
		catch {unset reall_c($this_indx)}
	}
	wm title .blocker "PLEASE WAIT:      Getting data from file $this_indx"
	while {[gets $fileId line] >= 0} {
		set vals "[string trim $line]"
		set vals "[split $vals]"
		foreach val $vals {
			if {[string length $val] > 0} {
				if {![IsNumeric $val]} {
					Inf "Non-numeric value ($val) in data file $fnam"
					catch {close $fileId}
					return 0
				}
				lappend nuvals $val
				incr valcnt
			}
		}
	}
	catch {close $fileId}
	if {$valcnt < 4 || ![IsEven $valcnt]} {
		Inf "Failed to get a valid number of values from data file $fnam."
		return 0
	}
	set vals $nuvals
	if {[info exists spk(display)]} {
		set spek_c($this_indx) $vals
	} else {
		set reall_c($this_indx) $vals
	}
	set frqmin [lindex $vals 0] 
	set frqmax [lindex $vals 0] 
	set ampmin [lindex $vals 1] 
	set ampmax [lindex $vals 1] 
	foreach {frq amp} $vals {
		if {$frq < $frqmin} {
			set frqmin $frq
		}
		if {$frq > $frqmax} {
			set frqmax $frq
		}
		if {$amp < $ampmin} {
			set ampmin $amp
		}
		if {$amp > $ampmax} {
			set ampmax $amp
		}
	}
	if {[info exists spk(display)]} {
		set spek_frqmin($this_indx)	$frqmin
		set spek_frqmax($this_indx) $frqmax
		set spek_ampmin($this_indx) $ampmin
		set spek_ampmax($this_indx) $ampmax
	} else {
		set brrk_frqmin($this_indx)	$frqmin
		set brrk_frqmax($this_indx) $frqmax
		set brrk_ampmin($this_indx) $ampmin
		set brrk_ampmax($this_indx) $ampmax
	}
	return 1
}

#------ Generate display coords from real coords of data

proc SetupBrrkfileDisplay_c {this_indx} {
	global reall_c spek_c disppl_c brrk brrkfrm spekfrm spk
	set doit 0
	if {[info exists spk(display)]} {
		if {[info exists spek_c($this_indx)]} {
			set doit 1
			set vals $spek_c($this_indx)
			set lo $spekfrm(lo)
		}
	} else {
		if {[info exists reall_c($this_indx)]} {
			set doit 1
			set vals $reall_c($this_indx)
			set lo $brrkfrm(lo)
		}
	}
	if {$doit} {
		catch {unset disppl_c($this_indx)} in
		foreach {freq val} $vals {
			lappend disppl_c($this_indx) [RealToGrrafx $freq]		;#	Convert brkfile freq to y-display freq
			lappend disppl_c($this_indx) [RealToGrrafy $val $lo]	;#	Convert brkfile amp to y-display amp
		}
		return 1
	}
	return 0
}

#------ Generate display coords from real coords of spectrum

proc SetupSpekDisplay_c {this_indx} {
	global spek_c disppl_c brrk brrkfrm spekfrm spk
	if {[info exists spk(display)]} {
		set lo $spekfrm(lo)
	} else {
		set lo $brrkfrm(lo)
	}
	catch {unset disppl_c($this_indx)}
	foreach {freq val} $spek_c($this_indx) {
		lappend disppl_c($this_indx) [RealToGrrafx $freq]		;#	Convert brkfile freq to y-display freq
		lappend disppl_c($this_indx) [RealToGrrafy $val $lo]	;#	Convert brkfile amp to y-display amp
	}
}

#------ Generate display coords from special (sound-convertible) coords of spectrum

proc SetupSpekkkDisplay_c {this_indx} {
	global spek_c disppl_c brrk brrkfrm spekfrm spk evv
	if {[info exists spk(display)]} {
		set lo $spekfrm(lo)
	} else {
		set lo $brrkfrm(lo)
	}
	catch {unset disppl_c($this_indx)}
	set k 0
	set spekchans [expr $evv(ANALPOINTS)/2]
	set chwidth [expr double($evv(SPEKNYQUIST)) / double($spekchans + 1)]
	set chanmidfrq 0.0
	set len [llength $spek_c($this_indx)]
	set len [expr $len - 2]
	set coordcnt 0
	foreach {freq val} $spek_c($this_indx) {
		if {$freq < 0.0} {
			set freq [expr -$freq]
		} elseif {$freq <= 0.0} {
			if {$coordcnt == $len} {
				set freq $evv(SPEKNYQUIST)
			} else {
				set freq $chanmidfrq
			}
		}
		lappend disppl_c($this_indx) [RealToGrrafx $freq]		;#	Convert brkfile freq to y-display freq
		lappend disppl_c($this_indx) [RealToGrrafy $val $lo]	;#	Convert brkfile amp to y-display amp
		set chanmidfrq [expr $chanmidfrq + $chwidth]
		incr coordcnt 2					
	}
}

#------ Convert real value to grafpoint value

proc RealToGrrafx {x} {
	global evv brrk brrkfrm spk spekfrm
	if {[info exists spk(display)]} {
		set startfreq $spekfrm(startfreq)
	} else {
		set startfreq $brrkfrm(startfreq)
	}
	set x [expr $x - $startfreq]
	set x [expr $x * $brrk(xvaltograf)]
	return $x
}

proc RealToGrrafy {y lo} {
	global evv brrk
	set y [expr $y - $lo]									;#	Establish position within range
	set y [expr $y * $brrk(yvaltograf)]						;#	Convert into graf range
	set y [expr	$evv(YHEIGHT) - $y]							;#	Invert y-display
	return $y
}

#---- Text-list a specific curve

proc BrrkList {this_indx zit forcedata} {
	global reall_c spek_c bsh_list brrk_showout brrkcolor overlay_list spk spc_list
	if {$forcedata} {
		if {![info exists reall_c($this_indx)]} {
			Inf "This curve does not exist"
			return
		}
	} elseif {[info exists spk(display)]} {
		if {![info exists spek_c($this_indx)]} {
			Inf "This curve does not exist"
			return
		}
	} elseif {![info exists reall_c($this_indx)]} {
		Inf "This curve does not exist"
		return
	}
	set overlay_list $this_indx
	$bsh_list delete 0 end
	if {$brrk_showout} {
		if {![info exists spek_c($this_indx)]} {
			Inf "No output data generated"
			return
		}
		foreach {frq amp} $spek_c($this_indx) {
			set vals [list $frq $amp]
			$bsh_list insert end $vals
		}
	} else {
		if {[info exists spk(display)] && !$forcedata} {	;#	INPUT COULD BE DATA OR SPECTRUM
			foreach {frq amp} $spek_c($this_indx) {
				set vals [list $frq $amp]
				$bsh_list insert end $vals
			}
		} else {
			foreach {frq amp} $reall_c($this_indx) {
				set vals [list $frq $amp]
				$bsh_list insert end $vals
			}
		}
	}
	if {$zit} {
		SelectSpekDisplay $this_indx
	}
	set thiscurv [file rootname [file tail [$spc_list get $this_indx]]]
	.show_brkfile2.btns9.data.ll config -text "Data from curve $thiscurv" -fg $brrkcolor($this_indx)
}

#----- Do text-listing of specified graph selected by mouse

proc DoBrrkList {y} {
	global spc_list spk
	set i [$spc_list nearest $y]
	if {[info exists spk(display)] && [info exists spk(created)]} {
		BrrkList $i 0 1
	} else {
		BrrkList $i 0 0
	}
}

#---- Quit data display

proc AbandonDataDisplay {kill} {
	global brrk_curvcnt brrk brrkfrm spek spekfrm bsh_list brrk_fnams spk
	global orig_spek_range orig_brrk_range reall_c spek_c speks_to_save
	global init_brrk_fnams init_brrk_range spc_list orig_brrkfrm
	if {![info exists brrk_curvcnt]} {
													;#	No display has yet been drawn. 
		ClearBrrkDisplay none $kill					;#	True (typed) delete has been called
													;#	From topmost page.	
	} else {					
													;#	A display has been drawn.
		if {$kill} {								;#	Only delete real coords
			ClearBrrkDisplay $brrk_curvcnt $kill	;#  if its a real delete (Kill).
		}											;#	Otherwise merely switching between display types
		catch {unset brrk_curvcnt}					
		catch {$bsh_list delete 0 end}
		catch {$spc_list delete 0 end}
	}
	if {[info exists spk(display)]} {
		if {$kill} {
			catch {unset spek_c}
			catch {unset spekfrm}
			catch {unset spek}
			catch {unset orig_spek_range}
			unset spk(display)
			catch {unset speks_to_save}
			set spk(mod) 0
		} else {
			set orig_spek_range [list $spekfrm(lo) $spekfrm(hi) $spekfrm(startfreq) $spekfrm(endfreq)]
			SaveSpekData
			unset spk(display)
			catch {unset speks_to_save}
			set spk(mod) 0
		}
	} else {
		if {$kill} {
			catch {unset brrk_fnams}
			catch {unset reall_c}
			catch {unset brrkfrm}
			catch {unset brrk}
			catch {unset init_brrk_fnams}
			catch {unset init_brrk_range}
#			catch {unset orig_brrk_range}
		} else {
			if {[info exists orig_brrkfrm]} {
				RestoreOrigRanges
			}
			set orig_brrk_range [list $brrkfrm(lo) $brrkfrm(hi) $brrkfrm(startfreq) $brrkfrm(endfreq)]
			set init_brrk_range $orig_brrk_range 
			set init_brrk_fnams $brrk_fnams 
			SaveSpekData
		}
	}
}

#----- Draw the coord values on the graf axes

proc EstablishCoordsOnGrafDisplay {} {
	 global bsh evv bkc brrk brrk_xdisplay_end_atedge brrkfrm spekfrm spk spek

	if {[info exists spk(display)]} {
		set startfreq $spek(real_startfreq)
		set endfreq   $spek(real_endfreq)
		set hi $spekfrm(hi)
		set lo $spekfrm(lo)
	} else {
		set startfreq $brrk(real_startfreq)
		set endfreq   $brrk(real_endfreq)
		set hi $brrkfrm(hi)
		set lo $brrkfrm(lo)
	}
	catch {$bsh(can) delete zinfo} in
	catch {$bsh(can) delete endinfo} in
	catch {$bsh(can) delete rangeinfo} in
	$bsh(can) create text $evv(BWIDTH) $bkc(text_yposition) -text $startfreq -tag {zinfo}
	set righttext [StripTrailingZeros $endfreq]
	$bsh(can) create text $brrk_xdisplay_end_atedge $bkc(text_yposition) -text $righttext -justify left -tag {endinfo}
	$bsh(can) create text $bkc(halfwidth) $bkc(text_yposition) -text "Freq" -tag {endinfo}
	$bsh(can) create text $bkc(rangetext_xoffset) $bkc(rangetext) -text "Amp" -font brkxfnt

	if {$lo > $bkc(rangetextmin)} {
		set lodisplay [string range $lo 0 $evv(MAX_XCHAR)]
		if {[string range $lodisplay end end] == "."} {
			set newend [string length $lodisplay]
			incr newend -2				   		
			set lodisplay [string range $lodisplay 0 $newend]
		}
	} else {
		set lodisplay [MagDisplay $lo]
	}
	$bsh(can) create text $bkc(rangetext_xoffset) $bkc(text_rangebot) -text $lodisplay \
			-font brkxfnt -tag {rangeinfo}

	if {$hi < $bkc(rangetextmax)} {
		set hidisplay [string range $hi 0 $evv(MAX_XCHAR)]
		if {[string range $lodisplay end end] == "."} {
			set newend [string length $hidisplay]
			incr newend -2				   		
			set hidisplay [string range $hidisplay 0 $newend]
		}
	} else {
		set hidisplay [MagDisplay $hi]
	}
	$bsh(can) create text $bkc(rangetext_xoffset) $bkc(text_rangetop) -text $hidisplay \
			-font brkxfnt -tag {rangeinfo}
}

#----- Switch between showing all graphs, 1 of graphs, or all but one of graphs

proc SelectSpekDisplay {no} {
	global brrk_curvcnt bsh disppl_c evv brrkcolor spekbset spekshow spekshown
	.show_brkfile2.outs.toptest config -text "" -bd 0 -command {}
	set j 0
	while {$j < $brrk_curvcnt} {
		catch {$bsh(can) delete cline($j)}  in
		incr j
	}
	if {$no == "all"} {
		catch {unset spekshown}
		set k 0
		set kk 1
		Block "Drawing Curves"
		while {$k < $brrk_curvcnt} {
			catch {unset line_c} 
			foreach {x y} $disppl_c($k) {
				set x [expr $x + $evv(BPWIDTH)]
				set y [expr $y + $evv(BPWIDTH)]
				lappend line_c $x $y
			}
			eval {$bsh(can) create line} $line_c {-fill $brrkcolor($k)} {-tag cline($k)}
			set jj [expr ($k/$evv(SPEKBTNCNT)) + 2]
			.show_brkfile2.btns$jj.$kk config -fg white -bg $brrkcolor($k)
			incr k
			incr kk
		}
		UnBlock
	} elseif {$spekshow} {
		set spekshown $no
		set k 0
		set kk 1
		while {$k < $brrk_curvcnt} {
			if {$k == $spekshown} {
				catch {unset line_c} 
				foreach {x y} $disppl_c($k) {
					set x [expr $x + $evv(BPWIDTH)]
					set y [expr $y + $evv(BPWIDTH)]
					lappend line_c $x $y
				}
				eval {$bsh(can) create line} $line_c {-fill $brrkcolor($k)} {-tag cline($k)}
				set jj [expr ($k/$evv(SPEKBTNCNT)) + 2]
				.show_brkfile2.btns$jj.$kk config -fg black -bg white
			} else {
				set jj [expr ($k/$evv(SPEKBTNCNT)) + 2]
				.show_brkfile2.btns$jj.$kk config -fg white -bg $brrkcolor($k)
			}
			incr k
			incr kk
		}
	} else {
		set spekshown $no
		set k 0
		set kk 1
		Block "Drawing Curves"
		while {$k < $brrk_curvcnt} {
			if {$k == $spekshown} {
				set jj [expr ($kk/$evv(SPEKBTNCNT)) + 2]
				.show_brkfile2.btns$jj.$kk config -fg black -bg white
			} else {
				catch {unset line_c} 
				foreach {x y} $disppl_c($k) {
					set x [expr $x + $evv(BPWIDTH)]
					set y [expr $y + $evv(BPWIDTH)]
					lappend line_c $x $y
				}
				eval {$bsh(can) create line} $line_c {-fill $brrkcolor($k)} {-tag cline($k)}
				set jj [expr ($k/$evv(SPEKBTNCNT)) + 2]
				.show_brkfile2.btns$jj.$kk config -fg white -bg $brrkcolor($k)
			}
			incr k
			incr kk
		}
		UnBlock
	}
}

#----- Show each graph in turn, with apprpirate time_step

proc SpekMovie {} {
	global brrk_curvcnt bsh disppl_c evv brrkcolor spekframedur movie_running
	set k 0
	if {$brrk_curvcnt < 3} {
		Inf "At least 3 curves need for a movie display"
		return
	}
	if {[info exists movie_running]} {
		return
	}
	set movie_running 1
	while {$k < $brrk_curvcnt} {
		catch {$bsh(can) delete cline($k)}
		incr k
	}
	if {![info exists spekframedur]} {
		set spekframedur 600
	}
	set k 0
	set kk -2
	while {$k < $brrk_curvcnt} {
		if {$kk >= 0} {
			catch {$bsh(can) delete cline($kk)}
		}
		if {$k >= 0} {
			catch {$bsh(can) delete noo}
		}
		catch {unset line_c} 
		foreach {x y} $disppl_c($k) {
			set x [expr $x + $evv(BPWIDTH)]
			set y [expr $y + $evv(BPWIDTH)]
			lappend line_c $x $y
		}
		eval {$bsh(can) create text} 100 100 -text [expr $k+1] {-font {times 18 bold}} {-fill $brrkcolor($k)} {-tag noo}
		eval {$bsh(can) create line} $line_c {-fill $brrkcolor($k)} {-tag cline($k)}
		incr k
		incr kk
		set x 0
		after $spekframedur {set x 1}
		vwait x
	}
	while {$kk < $brrk_curvcnt} {
		catch {$bsh(can) delete cline($kk)}
		set x 0
		after $spekframedur {set x 1}
		vwait x
		incr kk
	}
	set x 0
	after [expr $spekframedur * 2] {set x 1}
	vwait x
	incr kk
	set k 0
	catch {$bsh(can) delete noo}
	Block "Redrawing Curves"
	while {$k < $brrk_curvcnt} {
		wm title .blocker "PLEASE WAIT:      Redrawing curve $k"
		catch {unset line_c} 
		foreach {x y} $disppl_c($k) {
			set x [expr $x + $evv(BPWIDTH)]
			set y [expr $y + $evv(BPWIDTH)]
			lappend line_c $x $y
		}
		eval {$bsh(can) create line} $line_c {-fill $brrkcolor($k)} {-tag cline($k)}
		incr k
	}
	UnBlock
	unset movie_running
}

proc SetSpekMovieSpeed {} {
	global spekframedur spkframedur pr_spekmovsp readonlyfg readonlybg evv
	set f .spekmovsp
	if [Dlg_Create $f "Set movie speed" "set pr_spekmovsp 0" -borderwidth 2 -width 80] {
		frame $f.0
		button $f.0.0 -text "Set New Speed" -command "set pr_spekmovsp 1"  -highlightbackground [option get . background {}]
		button $f.0.1 -text "Abandon" -command "set pr_spekmovsp 0"  -highlightbackground [option get . background {}]
		pack $f.0.0 -side left
		pack $f.0.1 -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Movie frame duration"
		entry $f.1.e -textvariable spkframedur -width 4 -state readonly -readonlybackground $readonlybg -fg $readonlyfg 
		button $f.1.b -text default -command {set spkframedur 0.05}  -highlightbackground [option get . background {}]
		pack $f.1.ll $f.1.e $f.1.b -side left -padx 2
		pack $f.1 -side top -pady 2
		label $f.2 -text "Change value using Up and Down Arrow Keys" -fg $evv(SPECIAL)
		label $f.3 -text "Control Up and Down scrolls Faster" -fg $evv(SPECIAL)
		pack $f.2 $f.3 -side top -pady 2
		set spkframedur 0.05
		bind $f <Up>   {SpekMovieSpeed 0 0}
		bind $f <Down> {SpekMovieSpeed 1 0}
		bind $f <Control-Up>   {SpekMovieSpeed 0 1}
		bind $f <Control-Down> {SpekMovieSpeed 1 1}
		bind $f <Return> {set pr_spekmovsp 1}
		bind $f <Escape> {set pr_spekmovsp 0}
		wm resizable $f 0 0
	}
	set pr_spekmovsp 0
	ScreenCentre $f
	update idletasks
	raise $f
	update idletasks
	My_Grab 0 $f pr_spekmovsp $f.1.e
	update idletasks
	set finished 0
	tkwait variable pr_spekmovsp
	if {$pr_spekmovsp} {
		set spekframedur [expr round($spkframedur * 1000)]
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc SpekMovieSpeed {down fast} {
	global spkframedur wasfast
	if {$down} {
		if {$fast} {
			if {[info exists wasfast]} {
				set spkframedur [expr $spkframedur - .1]
				if {$spkframedur  < 0.02} {
					set spkframedur 0.02
				}
			} else {
				set old $spkframedur
				set spkframedur [DecPlaces $spkframedur 1]
				if {$spkframedur > $old} {
					set spkframedur [expr $spkframedur - .1]
				}
				if {$spkframedur  < 0.02} {
					set spkframedur 0.02
				}
				set wasfast 1
			}
		} else {
			if {$spkframedur > 0.02} {
				catch {unset wasfast}
				set spkframedur [expr $spkframedur - .01]
			}
		}
	} else {
		if {$fast} {
			if {[info exists wasfast]} {
				if {$spkframedur < 0.1} {
					set spkframedur 0.1
				} else {
					set spkframedur [expr $spkframedur + .1]
					if {$spkframedur  > 2.0} {
						set spkframedur 2.0
					}
				}
			} else {
				set old $spkframedur
				set spkframedur [DecPlaces $spkframedur 1]
				if {$spkframedur < $old} {
					set spkframedur [expr $spkframedur + .1]
				}
				if {$spkframedur  > 2.0} {
					set spkframedur 2.0
				}
				set wasfast 1
			}
		} else {
			if {$spkframedur < 2.0} {
				catch {unset wasfast}
				set spkframedur [expr $spkframedur + .01]
			}
		}
	}
}

#---- Switch between Show x and Hide x

proc SpekShowSwitch {} {
	global spekshow spekshown
	if {[info exists spekshown]} {
		SelectSpekDisplay $spekshown
	}
}

#---- Change title, depending on whether display is Spectrum or Data

proc ToggleBrrkTitle {} {
	global spk
	if {[info exists spk(display)]} {
		.show_brkfile2.btns4.title.title config -text "Spectrum display"
	} else {
		.show_brkfile2.btns4.title.title config -text "Data display"
	}
}

#---- Get the relevant data ranges for the graphs, and calculate conversion constants to transform data/sepctrum to display

proc MakeSpekConversionConstants {} {
	global spekfrm spek init_brrk_range brrkfrm brrk
	if {![info exists init_brrk_range]} {
		if {[info exists brrkfrm(lo)]} {
			set init_brrk_range [list $brrkfrm(lo) $brrkfrm(hi) $brrkfrm(startfreq) $brrkfrm(endfreq)]
		} else {
			Inf "No non-spectral data range"
			return
		}
	}
	set brrkfrm(lo)			[lindex $init_brrk_range 0]
	set brrkfrm(hi)			[lindex $init_brrk_range 1]
	set brrkfrm(startfreq)	[lindex $init_brrk_range 2]
	set brrkfrm(endfreq)	[lindex $init_brrk_range 3]
	set brrk(range) [expr $brrkfrm(hi) - $brrkfrm(lo)]
	set brrk(real_startfreq) $brrkfrm(startfreq)
	set brrk(real_endfreq) $brrkfrm(endfreq)
	EstablishGrafToRealConversionConstantsBrrk
}

#---- Convert to display range, and draw curve

proc GetGraphCoordsAndDrawCurve {k isspec} {
	global bsh disppl_c brrkcolor evv spk
	if {$k == 0} {
		set spk(top) 0
		set spk(max) 10000
	}
	if {$isspec} {
		SetupSpekDisplay_c $k				;#	Establish display-coords of spectrum points.
	} else {
		if {![SetupBrrkfileDisplay_c $k]} {	;#	Establish display-coords of data points.
			return
		}
	}
	catch {unset line_c} 
	catch {$bsh(can) delete cline($k)} in
	foreach {x y} $disppl_c($k) {
		set x [expr $x + $evv(BPWIDTH)]
		set y [expr $y + $evv(BPWIDTH)]
		lappend line_c $x $y
		if {$y < $spk(max)} {
			set spk(max) $y
			set spk(top) $k
		}
	}
	eval {$bsh(can) create line} $line_c {-fill $brrkcolor($k)} {-tag cline($k)}
}

proc GetExistingRangesFromData {this_indx} {
	global reall_c spek_c brrk brrk_frqmin brrk_frqmax brrk_ampmin brrk_ampmax evv spk
	global spek_frqmin spek_frqmax spek_ampmin spek_ampmax 

	set k 0
	while {$k < $this_indx} {
		if {[info exists spk(display)]} {
			if {![info exists spek_c($k)]} {
				if {$k == 0} {
					Inf "Problem: missing spek coords"
				} else {
					return
				}
			}
			set vals $spek_c($k)
		} else {
			if {![info exists reall_c($k)]} {
				if {$k == 0} {
					Inf "Problem: missing data coords"
				} else {
					return
				}
			}
			set vals $reall_c($k)
		}
		set frqmin [lindex $vals 0] 
		set frqmax [lindex $vals 0] 
		set ampmin [lindex $vals 1] 
		set ampmax [lindex $vals 1] 
		foreach {frq amp} $vals {
			if {$frq < $frqmin} {
				set frqmin $frq
			}
			if {$frq > $frqmax} {
				set frqmax $frq
			}
			if {$amp < $ampmin} {
				set ampmin $amp
			}
			if {$amp > $ampmax} {
				set ampmax $amp
			}
		}
		if {[info exists spk(display)]} {
			set spek_frqmin($k)	$frqmin
			set spek_frqmax($k) $frqmax
			set spek_ampmin($k) $ampmin
			set spek_ampmax($k) $ampmax
		} else {
			set brrk_frqmin($k)	$frqmin
			set brrk_frqmax($k) $frqmax
			set brrk_ampmin($k) $ampmin
			set brrk_ampmax($k) $ampmax
		}
		incr k

	}
	return 1
}

#--- Check filetpes for display: data and spectal filesare incompatible for display

proc CheckForSpecExtensions {fnams} {
	global evv
	set fnam [lindex $fnams 0]
	set ext [file extension $fnam]
	if {[string match $ext ".brk"]} {
		set ext "text"
	} else {
		switch -regexp -- $ext \
			^$evv(TEXT_EXT)$ {
				set ext "text"
			} \
			^$evv(SPEC_EXT)$ {
				set ext "spec"
			} \
			^$evv(SPEK_EXT)$ {
				set ext "spec"
			} \
			default {
				Inf "First selected file has unknown file extension"
				return 0
			}
	}
	if {[llength $fnams] > 1} {
		foreach fnam [lrange $fnams 1 end] {
			switch -- $ext {
				"text" {
					if {![string match $evv(TEXT_EXT) [file extension $fnam]] \
					&&  ![string match ".brk" [file extension $fnam]]} {
						Inf "Selected files are not all of same type"
						return 0
					}
				}
				"spec" {
					if {![string match $evv(SPEC_EXT) [file extension $fnam]] \
					&&  ![string match $evv(SPEK_EXT) [file extension $fnam]]} {
						Inf "Selected files are not all of same type"
						return 0
					}
				}
			}
		}
	}
	if {$ext == "text"} {
		return 1
	}
	return 2
}

#---- Output Spectral Data of curves to named files

proc OutputSpectralDataFiles {name} {
	global pr_sposdf spek_c brrk_curvcnt spekoutname sposdfnam datosndlist_spek evv

	set kk 1
	while {1} {
		set datfnam $evv(DFLT_OUTNAME)
		append datfnam $kk $evv(TEXT_EXT)
		if {[file exists $datfnam]} {
			lappend datfnams $datfnam
		} else {
			break
		}
		incr kk
	}
	if {![info exists datfnams]} {
		Inf "No spectral data to save"
		return 0
	}
	if {$name} {
		set f .sposdf
		if [Dlg_Create $f "Spectral files name(s)" "set pr_sposdf 0" -borderwidth 2 -width 80] {
			button $f.0 -text "Set Name" -command "set pr_sposdf 1"  -highlightbackground [option get . background {}]
			label $f.1 -text "Generic Filename "
			entry $f.2 -textvariable sposdfnam -width 24
			button $f.3 -text "Abandon" -command "set pr_sposdf 0"  -highlightbackground [option get . background {}]
			pack $f.0 $f.1 $f.2 $f.3 -side left -padx 2
			wm resizable $f 0 0
			bind $f <Return> {set pr_sposdf 1}
			bind $f <Escape> {set pr_sposdf 0}
		}
		set pr_sposdf 0
		ScreenCentre $f
		update idletasks
		raise $f
		update idletasks
		My_Grab 0 $f pr_sposdf $f.2
		update idletasks
		set finished 0
		while {!$finished} {
			tkwait variable pr_sposdf
			if {$pr_sposdf} {
				if {[string length $sposdfnam] <= 0} {
					Inf "No output filename given"
					continue
				} elseif {![ValidCDPRootname $sposdfnam]} { 
					continue
				}
			} else {
				set sposdfnam ""
				set finished 1
			}
		}
		My_Release_to_Dialog $f
		Dlg_Dismiss $f
		if {[string length $sposdfnam] <= 0} {
			return 0
		}
		set spekoutname $sposdfnam		
	} else {
		if {[string length $spekoutname] <= 0} {
			Inf "No output filename given"
			return 0
		} elseif {![ValidCDPRootname $spekoutname]} { 
			return 0
		}
	}
	set k 1
	while {$k < $kk} {
		set outnam [string tolower $spekoutname]
		append outnam $k $evv(SPEK_EXT)
		if {[file exists $outnam]} {
			Inf "File '$outnam' already exists: please choose a different generic name"
			return 0
		}
		lappend outnams $outnam
		incr k
	}
	set cnt 0
	set badcnt 0
	foreach datfnam $datfnams outnam $outnams {
		incr cnt
		if [catch {file rename $datfnam $outnam} zit] {
			Inf "Cannot rename temporary file $datfnam to $outfnam
			incr badcnt
		} else {
			lappend out_files $outnam
		}
	}
	if {![info exists out_files]} {
		Inf "No files were backed up"
		return
	}
	foreach fnam $out_files {
		FileToWkspace $fnam 0 0 0 0 1
	}
	if {[llength $out_files] == 1} {
		set msg "File with name '[string tolower $spekoutname]' is on the workspace"
	} else {
		set msg "Files with generic name '[string tolower $spekoutname]' are on the workspace"
	}
	if {$badcnt > 0} {
		append msg "\n\n($badcnt files were not saved)"
	}
	Inf $msg
	return 1
}

#--- Show frq at point where mouse clicks on display

proc SpekShowFrq {x} {
	global spekgrafrq spk spek brrk evv bkc
	if {![info exists spk(display)]} {
		Inf "Not a spectral display"
		return
	}
	if [info exists spk(zoom)] {
		set x [expr $x - $evv(BWIDTH)]
		if {$x <= 0} {
			set spekgrafrq  $spk(zleft)
			return
		} elseif {$x >= $evv(XWIDTH)} {
			set spekgrafrq  $spk(zright)
			return
		}
		set x [expr $x/double($evv(XWIDTH))]
		set x [expr $x * ($spk(zright) - $spk(zleft))]
		set spekgrafrq  [expr $x + $spk(zleft)]
	} else {
		set x [expr $x - $evv(BWIDTH)]
		if {$x <= 0} {
			set spekgrafrq  $spek(real_startfreq)
			return
		} elseif {$x >= $evv(XWIDTH)} {
			set spekgrafrq  $spek(real_endfreq)
			return
		}
		set spekgrafrq  [expr $x / $brrk(xvaltograf)] 
	}
}

proc SetSpekZoom {on} {
	global brrk_curvcnt disppl_c orig_disppl_c pr_spkzm spk spek spekfrm brrk readonlybg readonlyfg evv
	global spkzm_ll spkzm_rr brrkcolor bsh
;#	IMPORTANT:	SWITCH ZOOM OFF BEFORE DOING ANY TRANSFORMATION
	if {$on && [info exists spk(zoom)]} {
		set on 0
	}
	if {$on} {
		if {[info exists spk(display)]} {
			set spk(zstartfreq) $spek(real_startfreq)
			set spk(zendfreq)   $spek(real_endfreq)
			set hi $spekfrm(hi)
			set lo $spekfrm(lo)
		} else {
			set spk(zstartfreq) $brrk(real_startfreq)
			set spk(zendfreq)   $brrk(real_endfreq)
		}
		catch {unset spk(zleft)}
		catch {unset spk(zright)}
		set f .spkzm
		if [Dlg_Create $f "ZOOM Coords" "set pr_spkzm 0" -borderwidth 2 -width 80] {
			frame $f.0
			button $f.0.0 -text "Set Coords" -command "set pr_spkzm 1"  -highlightbackground [option get . background {}]
			button $f.0.1 -text "Abandon Zoom" -command "set pr_spkzm 0"  -highlightbackground [option get . background {}]
			pack $f.0.0 -side left
			pack $f.0.1 -side right
			pack $f.0 -side top -fill x -expand true
			frame $f.1
			entry $f.1.0 -textvariable spkzm_ll -width 8 -state readonly -readonlybackground $readonlybg -fg $readonlyfg 
			label $f.1.1 -text "Leftmost value"
			label $f.1.2 -text "Up/Dn & L/R Arrows change coords by .1" -fg $evv(SPECIAL)
			pack $f.1.0 $f.1.1 -side left -padx 2
			pack $f.1.2 -side right
			pack $f.1 -side top -fill x -expand true -pady 2
			frame $f.2
			entry $f.2.0 -textvariable spkzm_rr -width 8 -state readonly -readonlybackground $readonlybg -fg $readonlyfg 
			label $f.2.1 -text "Rightmost value"
			label $f.2.2 -text "Shift Up/Dn etc by 1 : Cntrl by 10" -fg $evv(SPECIAL)
			pack $f.2.0 $f.2.1 -side left -padx 2
			pack $f.2.2 -side right
			pack $f.2 -side top -fill x -expand true -pady 2
			label $f.3 -text " : Cntrl-Shift by 100 : Alt by 1000" -fg $evv(SPECIAL)
			pack $f.3 -side top -pady 2 -anchor e
			wm resizable $f 0 0
			bind $f <Up>    {ChangeSpekZoomCoord r 0 0}
			bind $f <Down>  {ChangeSpekZoomCoord r 1 0}
			bind $f <Right> {ChangeSpekZoomCoord l 0 0}
			bind $f <Left>  {ChangeSpekZoomCoord l 1 0}
			bind $f <Shift-Up>    {ChangeSpekZoomCoord r 0 1}
			bind $f <Shift-Down>  {ChangeSpekZoomCoord r 1 1}
			bind $f <Shift-Right> {ChangeSpekZoomCoord l 0 1}
			bind $f <Shift-Left>  {ChangeSpekZoomCoord l 1 1}
			bind $f <Control-Up>    {ChangeSpekZoomCoord r 0 2}
			bind $f <Control-Down>  {ChangeSpekZoomCoord r 1 2}
			bind $f <Control-Right> {ChangeSpekZoomCoord l 0 2}
			bind $f <Control-Left>  {ChangeSpekZoomCoord l 1 2}
			bind $f <Control-Shift-Up>    {ChangeSpekZoomCoord r 0 3}
			bind $f <Control-Shift-Down>  {ChangeSpekZoomCoord r 1 3}
			bind $f <Control-Shift-Right> {ChangeSpekZoomCoord l 0 3}
			bind $f <Control-Shift-Left>  {ChangeSpekZoomCoord l 1 3}
			bind $f <Command-Up>    {ChangeSpekZoomCoord r 0 4}
			bind $f <Command-Down>  {ChangeSpekZoomCoord r 1 4}
			bind $f <Command-Right> {ChangeSpekZoomCoord l 0 4}
			bind $f <Command-Left>  {ChangeSpekZoomCoord l 1 4}
			bind $f <Return> {set pr_spkzm 1}
			bind $f <Escape> {set pr_spkzm 0}
		}
		if {[info exists spkzm_ll] && (($spkzm_ll > $spk(zstartfreq)) || ($spkzm_rr < $spk(zendfreq)))} {
			set spkzm_ll $spk(zstartfreq)
		}
		if {[info exists spkzm_rr] && (($spkzm_rr > $spk(zstartfreq)) || ($spkzm_rr < $spk(zendfreq)))} {
			set spkzm_rr $spk(zendfreq)
		}
		set pr_spkzm 0
		ScreenCentre $f
		update idletasks
		raise $f
		update idletasks
		My_Grab 0 $f pr_spkzm $f.1.0
		update idletasks
		set finished 0
		while {!$finished} {
			tkwait variable pr_spkzm
			if {$pr_spkzm} {
				if {$spkzm_rr <= $spkzm_ll} {
					Inf "Incompatible zoom coords"	
					continue
				} 
				set spk(zleft)	$spkzm_ll
				set spk(zright) $spkzm_rr
				set orig_range [expr $spk(zendfreq) - $spk(zstartfreq)]
				set new_range [expr $spk(zright) - $spk(zleft)]
				set spk(zoom) [expr double($orig_range)/double($new_range)]
				break
			} else {
				break
			}
		}
		My_Release_to_Dialog $f
		Dlg_Dismiss $f
		if {![info exists spk(zoom)]} {
			return
		}
		Block "Zooming"
		set kk 0
		EstablishZoomedCoordsOnGrafDisplay $spk(zleft) $spk(zright)
		set spk(d_zleft)  [expr $spk(zleft)  * $brrk(xvaltograf)]	
		set spk(d_zright) [expr $spk(zright) * $brrk(xvaltograf)]
		while {$kk < $brrk_curvcnt} {
			wm title .blocker  "PLEASE WAIT:      Zooming curve [expr $kk + 1]"
			set orig_disppl_c($kk) $disppl_c($kk)
			set len [llength $disppl_c($kk)]
			set xx 0
			set yy 1
			set nucoords {}
			while {$xx < $len} {
				set x [lindex $disppl_c($kk) $xx]
				set y [lindex $disppl_c($kk) $yy]
				if {$x > $spk(d_zright)} {
					break
				} elseif {$x >= $spk(d_zleft)}  {
					set x [expr $x - $spk(d_zleft)]
					set x [expr double($x) * $spk(zoom)]
					lappend nucoords $x $y
				}
				incr xx 2
				incr yy 2
			}
			set disppl_c($kk) $nucoords
			incr kk
		}
		set kk 0
		while {$kk < $brrk_curvcnt} {
			catch {$bsh(can) delete cline($kk)}
			catch {unset line_c}
			foreach {x y} $disppl_c($kk) {
				set x [expr $x + $evv(BPWIDTH)]
				set y [expr $y + $evv(BPWIDTH)]
				lappend line_c $x $y
			}
			eval {$bsh(can) create line} $line_c {-fill $brrkcolor($kk)} {-tag cline($kk)}
			incr kk
		}
		UnBlock
	} else {
		set kk 0
		Block "Zooming"
		while {$kk < $brrk_curvcnt} {
			if {![info exists orig_disppl_c($kk)]} {
				Inf "Problem restoring unzoomed version of curve [expr $kk + 1]"
				UnBlock
				return
			}
			incr kk
		}
		set kk 0
		EstablishZoomedCoordsOnGrafDisplay $spk(zstartfreq) $spk(zendfreq)
		while {$kk < $brrk_curvcnt} {
			wm title .blocker  "PLEASE WAIT:      Zooming curve [expr $kk + 1]"
			set disppl_c($kk) $orig_disppl_c($kk)
			catch {$bsh(can) delete cline($kk)}
			catch {unset line_c}
			foreach {x y} $disppl_c($kk) {
				set x [expr $x + $evv(BPWIDTH)]
				set y [expr $y + $evv(BPWIDTH)]
				lappend line_c $x $y
			}
			eval {$bsh(can) create line} $line_c {-fill $brrkcolor($kk)} {-tag cline($kk)}
			incr kk
		}
		unset spk(zoom)
		UnBlock
	}
}

proc ChangeSpekZoomCoord {whichend down cntrl} {
	global spkzm_ll spkzm_rr spk
	switch -- $cntrl {
		0 { set incr 0.1}
		1 { set incr 1}
		2 { set incr 10}
		3 { set incr 100}
		4 { set incr 1000}
	}
	if {$down} {
		set incr [expr -$incr]
	}
	switch -- $whichend {
		"r" {
			set spkzm_rr [expr $spkzm_rr + $incr]
			if {$spkzm_rr > $spk(zendfreq)} {
				set spkzm_rr $spk(zendfreq)
			} elseif {$spkzm_rr < $spk(zstartfreq)} {
				set spkzm_rr $spk(zstartfreq)
			}
		}
		"l" {
			set spkzm_ll [expr $spkzm_ll + $incr]
			if {$spkzm_ll > $spk(zendfreq)} {
				set spkzm_ll $spk(zendfreq)
			} elseif {$spkzm_ll < $spk(zstartfreq)} {
				set spkzm_ll $spk(zstartfreq)
			}
		}
	}
}

#---- Redraw frq coords on zoomewd display

proc EstablishZoomedCoordsOnGrafDisplay {startfreq endfreq} {
	global bsh evv bkc brrk_xdisplay_end_atedge
	catch {$bsh(can) delete zinfo} in
	catch {$bsh(can) delete endinfo} in
	$bsh(can) create text $evv(BWIDTH) $bkc(text_yposition) -text $startfreq -tag {zinfo}
	set righttext [StripTrailingZeros $endfreq]
	$bsh(can) create text $brrk_xdisplay_end_atedge $bkc(text_yposition) -text $righttext -justify left -tag {endinfo}
	$bsh(can) create text $bkc(halfwidth) $bkc(text_yposition) -text "Freq" -tag {endinfo}
}

#################################
#								#
#	DATA/SPECTRAL TRANSFORMS	#
#								#
#################################

#----- Convert Data to Spectral Range (Must be done first)

proc ConvertFromDataToSpectralRange {apply} {
	global brrk_curvcnt brrk spek spekfrm spek_c reall_c wstk evv
	global bsh bkc spektransform specktr spk brrkfrm speks_to_save brrk_xdisplay_end_atedge
	global init_brrk_range orig_brrk_range spek_exp_to_zero spek_prescale
	global bsh_list brrkcolor brrk_fnams disppl_c orig_brrk_range orig_brrkfrm


	if {[info exists spk(zoom)]} {
		SetSpekZoom 0
	}
	if {[info exists spk(display)]} {
		Inf "Displayed data is already a spectrum"
		return 0
	}
	if {[info exists spk(created)]} {
		Inf "Spectrum already generated"
		return 0
	}
	catch {unset spk(finalised)}
	if {!$apply} {
		catch {unset spk(presndset)}
		if {[info exists brrk_curvcnt] && ($brrk_curvcnt > 1)} {
			Inf "Only applicable to a single curve"
			return 0
		}
		if {![info exists evv(SPEKNYQUIST)]} {
			Inf "Set the sample rate before proceeding"
			return 0
		}
		if {![info exists evv(ANALPOINTS)]} {
			Inf "Set the analysis channel count"
			return 0
		}
		set spek_prescale 0
		set spek_exp_to_zero 0
		if {[info exists brrkfrm(endfreq)] && ![Flteq $brrkfrm(endfreq) 1.0]} {
			set msg "Input data ends at $brrkfrm(endfreq)\n"
			append msg "Do you want the converted data to be scaled\nby some integer factor ?"
			set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
			if {$choice == "yes"} {
				GetSpekPrescaleFactor	;#	Also forces data to expand down to zero, setting "spek_exp_to_zero"
				if {$spek_prescale != 0} {
					set spek_exp_to_zero 1
				}
			}
		}

		if {!$spek_exp_to_zero} {
			if {[info exists brrkfrm(startfreq)] && ($brrkfrm(startfreq) > 0) } {
				set msg "Input data does not start at zero on the y (frq) axis\n"
				append msg "Do you want the converted data to be similarly offset from zero ?"
				set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
				if {$choice == "yes"} {
					set spek_exp_to_zero 1
				}
			}
		}
	}
	set spekfrm(lo) $evv(SPEKAMPBOT)
	set spekfrm(hi) $evv(SPEKAMPTOP)
	set spekfrm(startfreq) $evv(SPEKFRQBOT)
	set spekfrm(endfreq)   $evv(SPEKNYQUIST)
	set spek(range) [expr $spekfrm(hi) - $spekfrm(lo)]
	set spek(real_startfreq) $spekfrm(startfreq)
	set spek(real_endfreq) $spekfrm(endfreq)

	SaveOrigRanges

	set brrkfrm(lo) 0.0	;#	If bottom of amp-range is not 0, causes -ve val during conversion to spek
	set brrk(range) [expr $brrkfrm(hi) - $brrkfrm(lo)]

	set spk(display) 1
	if {$spek_exp_to_zero} {		;#	If input data needs to be expanded down to zero
		set k 0						;#	Check first frq val of every graph and, if not zero, insert a 0 val-pair
		while {$k < $brrk_curvcnt} {
			if {![Flteq [lindex $reall_c($k) 0] 0]} {
				set nuvals [list 0.0 0.0]
				set reall_c($k) [concat $nuvals $reall_c($k)]
				set redraw($k) 1
			}
			incr k
		}
		set brrkfrm(startfreq) 0
		set brrk(real_startfreq) 0
	}
	if {$spek_prescale != 0} {						;#	If NO prescale, orig range just mapped onto 0 - 22050 (e.g.)
		set scalefact $spek_prescale
		if {$scalefact < 0} {
			set scalefact [expr 1.0/double(-$scalefact)]
		}
		set k 0											;#	otherwise, the original data is expanded to (some part of)
		while {$k < $brrk_curvcnt} {					;#	the new range AT THIS STAGE, and the subsequent mapping is 1:1		
			if {$apply} {
				wm title .blocker "PLEASE WAIT:        Checking range of file $k"			
			}
			foreach {frq amp} $reall_c($k) {
				set nufrq [expr $frq  * $scalefact]			;#	if the expansion causes the data to exceed spectral range
				if {$nufrq > $spek(real_endfreq)} {
					set msg "Curve [expr $k + 1] exceeds spectral range when  prescaled by $spek_prescale"
					append msg "\n\nCurtail the display to top of spectral range ?"
					set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						return 0
					}
					set len [llength $nucoords($k)]
					if {$len > 0} {							;#	Check previous entry in list of nucoords.
						incr len -2							;#	If its below top of spectrum
						if {[lindex $nucoords($k) $len] < $spek(real_endfreq)} {
							set nufrq $spek(real_endfreq)
							lappend nucoords($k) $nufrq 0.0	;#	set an end point at top of spectrum				
						} else {							;#	else, there's already an end point at top of spectrum
							set nufrq $spek(real_endfreq)	;#	(setting value prevents duplication of top-of-spectrum at loop exit)
						}
					} else {								;#	Else, very first data entry is beyond top of spectrum						
						set nufrq $spek(real_endfreq)		;#	(should be impossible, as value at frq 0 should have been inserted)
						lappend nucoords($k) $nufrq 0.0		;#	so set an end point at top of spectrum				
					}
					break									;#	and in all cases, stop converting coords
				}
				lappend nucoords($k) $nufrq $amp
			}
			if {![Flteq $nufrq $spek(real_endfreq)]} {			;#	If last prescaled frq not at top of spectral range
				lappend nucoords($k) $spek(real_endfreq) 0.0	;#	inserting value at max ensures that 
			}													;#	data will be mapped 1:1 (below) i.e. unchanged
			set redraw($k) 1
			incr k
		}
		set brrkfrm(endfreq) $spek(real_endfreq)
		set brrk(real_endfreq) $spek(real_endfreq)			;#	these ensure that data will be unchanged (below)
		set k 0
		while {$k < $brrk_curvcnt} {
			set reall_c($k) $nucoords($k)
			incr k
		}
	}
	EstablishGrafToRealConversionConstantsBrrk

	;#	REDRAW VALUE LIMITS ON DISPLAY

	catch {$bsh(can) delete zinfo} in
	$bsh(can) create text $evv(BWIDTH) $bkc(text_yposition) -text $spek(real_startfreq) -tag {zinfo}
	set righttext [StripTrailingZeros $spek(real_endfreq)]
	catch {$bsh(can) delete endinfo} in
	$bsh(can) create text $brrk_xdisplay_end_atedge $bkc(text_yposition) -text $righttext -justify left -tag {endinfo}

	if {$spekfrm(lo) > $bkc(rangetextmin)} {
		set lodisplay [string range $spekfrm(lo) 0 $evv(MAX_XCHAR)]
		if {[string range $lodisplay end end] == "."} {
			set newend [string length $lodisplay]
			incr newend -2				   		
			set lodisplay [string range $lodisplay 0 $newend]
		}
	} else {
		set lodisplay [MagDisplay $spekfrm(lo)]
	}
	catch {$bsh(can) delete rangeinfo} in
	$bsh(can) create text $bkc(rangetext_xoffset) $bkc(text_rangebot) -text $lodisplay -font brkxfnt -tag {rangeinfo}

	if {$spekfrm(hi) < $bkc(rangetextmax)} {
		set hidisplay [string range $spekfrm(hi) 0 $evv(MAX_XCHAR)]
		if {[string range $lodisplay end end] == "."} {
			set newend [string length $hidisplay]
			incr newend -2				   		
			set hidisplay [string range $hidisplay 0 $newend]
		}
	} else {
		set hidisplay [MagDisplay $spekfrm(hi)]
	}
	$bsh(can) create text $bkc(rangetext_xoffset) $bkc(text_rangetop) -text $hidisplay -font brkxfnt -tag {rangeinfo}

	ConvertToSpecDataRange $apply

	if {!$apply} {
		set lastk 0
		set k 0
		while {$k < $brrk_curvcnt} {
			if {[info exists redraw($k)]} {
				catch {unset disppl_c($k)}
				catch {$bsh(can) delete cline($k)} in
				GetGraphCoordsAndDrawCurve $k 0
				set lastk $k
			}
			incr k
		}
		if {$lastk == [expr $brrk_curvcnt - 1]} {
			$bsh_list delete 0 end
			foreach {frq amp} $spek_c($lastk) {
				set vals [list $frq $amp]
				$bsh_list insert end $vals
			}
			.show_brkfile2.btns9.data.ll config -text "Spectrum from curve $brrk_curvcnt" -fg $brrkcolor($lastk)
		}
		set spk(created) 1
		ToggleBrrkTitle
		set speks_to_save 1
		set init_brrk_range [list $orig_brrkfrm(lo) $orig_brrkfrm(hi) $orig_brrkfrm(startfreq) $orig_brrkfrm(endfreq)]		;#  Store range of DATA (as opposed to SPECTRUM)
		set orig_brrk_range [list $orig_brrkfrm(lo) $orig_brrkfrm(hi) $orig_brrkfrm(startfreq) $orig_brrkfrm(endfreq)]
		set init_spek_range [list $spekfrm(lo) $spekfrm(hi) $spekfrm(startfreq) $spekfrm(endfreq)]		;#	Store range of SPECTRUM
		set thistransform [concat RANGE $init_spek_range $spek_prescale $spek_exp_to_zero]
		set spektransform [list $thistransform]
		Inf "Converted to spectral metrics"
	} else {
		set orig_brrk_range [list $orig_brrkfrm(lo) $orig_brrkfrm(hi) $orig_brrkfrm(startfreq) $orig_brrkfrm(endfreq)]
	}
	set msg "Spectral display from [file rootname [file tail [lindex $brrk_fnams 0]]]"
	if {[llength $brrk_fnams] > 1} {
		append msg " etc."
	}
	wm title .show_brkfile2 $msg
	return 1
}

proc SaveOrigRanges {} {
	global orig_brrkfrm brrkfrm brrk
	set orig_brrkfrm(startfreq) $brrkfrm(startfreq)
	set orig_brrkfrm(endfreq) $brrkfrm(endfreq)
	set orig_brrkfrm(lo) $brrkfrm(lo)
	set orig_brrkfrm(hi) $brrkfrm(hi)
	set orig_brrkfrm(range) $brrk(range)
}

proc RestoreOrigRanges {} {
	global orig_brrkfrm brrkfrm brrk
	set brrkfrm(startfreq) $orig_brrkfrm(startfreq)
	set brrkfrm(endfreq) $orig_brrkfrm(endfreq)
	set brrkfrm(lo) $orig_brrkfrm(lo)
	set brrkfrm(hi) $orig_brrkfrm(hi)
	set brrk(range) $orig_brrkfrm(range)
}

#---- Establish prescaling factor

proc GetSpekPrescaleFactor {} {
	global spek_prescale pr_spekpresc upskale dnskale readonlyfg readonlybg spek_exp_to_zero evv
	set f .spekpresc
	if [Dlg_Create $f "Data prescale factor" "set pr_spekpresc 0" -borderwidth 2 -width 80] {
		frame $f.0
		button $f.0.0 -text "Set Factor" -command "set pr_spekpresc 1"  -highlightbackground [option get . background {}]
		button $f.0.1 -text "No Prescaling" -command "set pr_spekpresc 0"  -highlightbackground [option get . background {}]
		pack $f.0.0 -side left
		pack $f.0.1 -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		entry $f.1.0 -textvariable upskale -width 4 -state readonly -readonlybackground $readonlybg -fg $readonlyfg
		label $f.1.1 -text "UP scaling Factor"
		label $f.1.ll -text "Up/Down Arrows" -fg $evv(SPECIAL)
		pack $f.1.0 $f.1.1 -side left
		pack $f.1.ll -side right
		pack $f.1 -side top -pady 2 -fill x -expand true
		frame $f.2
		entry $f.2.0 -textvariable dnskale -width 4 -state readonly -readonlybackground $readonlybg -fg $readonlyfg
		label $f.2.1 -text "DOWN scaling Factor"
		label $f.2.ll -text "Left/Right Arrows" -fg $evv(SPECIAL)
		pack $f.2.0 $f.2.1 -side left
		pack $f.2.ll -side right
		pack $f.2 -side top -pady 2 -fill x -expand true
		label $f.3 -text "Up + Down Arrows change UPscale" -fg $evv(SPECIAL)
		label $f.4 -text "Left and Right Arrows change DOWNscale" -fg $evv(SPECIAL)
		bind $f <Up>    {IncrSkale 0 0}
		bind $f <Down>  {IncrSkale 0 1}
		bind $f <Left>  {IncrSkale 1 0}
		bind $f <Right> {IncrSkale 1 1}
		bind $f <Return> {set pr_spekpresc 1}
		bind $f <Escape> {set pr_spekpresc 0}
		wm resizable $f 0 0
	}
	set upskale ""
	set dnskale ""
	set spek_prescale ""
	set pr_spekpresc 0
	ScreenCentre $f
	update idletasks
	raise $f
	update idletasks
	My_Grab 0 $f pr_spekpresc
	update idletasks
	set finished 0
	while {!$finished} {
		tkwait variable pr_spekpresc
		if {$pr_spekpresc} {
			if {[string length $upskale] > 0} {
				set spek_prescale $upskale
			} elseif {[string length $dnskale] > 0} {
				set spek_prescale [expr -$dnskale]
				set spek_exp_to_zero 1
			} else {
				Inf "No prescale value set"
				continue
			}
		} else {
			set spek_prescale 0
		}
		break
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Change prescale factor 

proc IncrSkale {downscale down} {
	global upskale dnskale
	switch -- $downscale {
		0	{
			switch -- $down {
				0 {
					if {[string length $upskale] <= 0} {	;#	upscale up
						set upskale 2
						set dnskale ""
					} elseif {$upskale < 50000} {
						incr upskale
					}
				}
				1 {
					if {[string length $upskale] <= 0} {	;#	upskale down
						set upskale 2
						set dnskale ""
					} elseif {$upskale > 2} {
						incr upskale -1
					}
				}
			}
		}
		1	{
			switch -- $down {
				0 {
					if {[string length $dnskale] <= 0} {	;#	downscale up
						set dnskale 2
						set upskale ""
					} elseif {$dnskale < 50000} {
						incr dnskale
					}
				}
				1 {
					if {[string length $dnskale] <= 0} {	;#	downscale down
						set dnskale 2
						set upskale ""
					} elseif {$dnskale > 2} {
						incr dnskale -1
					}
				}
			}
		}
	}
}

#--- Convert input data to new total range for output data

proc ConvertToSpecDataRange {apply} {	
	global reall_c spek_c brrk_curvcnt brrk brrkfrm brrkcolor spekfrm evv
	set brrkfrm(frqrange) [expr $brrkfrm(endfreq) - $brrkfrm(startfreq)]
	set brrkfrm(amprange) [expr $brrkfrm(hi) - $brrkfrm(lo)]
	set spekfrm(frqrange) [expr $spekfrm(endfreq) - $spekfrm(startfreq)]
	set spekfrm(amprange) [expr $spekfrm(hi) - $spekfrm(lo)]
	set frqratio [expr $spekfrm(frqrange)/$brrkfrm(frqrange)]
	set ampratio [expr $spekfrm(amprange)/$brrkfrm(amprange)]
	catch {unset spek_c}
	set k 0
	while {$k < $brrk_curvcnt} {
		if {$apply} {
			wm title .blocker "PLEASE WAIT:        Mapping range of file $k"
		}
		foreach {frq amp} $reall_c($k) {
			set frq [expr $frq - $brrkfrm(startfreq)]
			set frq [expr $frq * $frqratio]
			set frq [expr $frq + $spekfrm(startfreq)]
			set amp [expr $amp - $brrkfrm(lo)]
			set amp [expr $amp * $ampratio]
			set amp [expr $amp + $spekfrm(lo)]
			lappend spek_c($k) $frq $amp
		}
		incr k
	}
	set last_indx [expr $k - 1]
	.show_brkfile2.btns9.data.ll config -text "Spectrum from curve $k" -fg $brrkcolor($last_indx)
}

#--- Convert Upper Limit of amplitude in spectral display

proc VerticalUpperLimitOfData {apply} {
	global brrk_curvcnt pr_spkul spkul spekfrm spektransform bsh brrkcolor bsh_list brrk_curvcnt
	global bsh spek_c orig_range_spek_c orig_range_spek orig_range_spekfrm spek wstk evv last_spek_c spk

	if {![info exists spek_c]} {
		Inf "Generate spectrum first (change to spectral range)"
		return 0
	}
	if {!$apply && $spk(ified)} {
		Inf "Already converted to playable data"
		return 0
	}
	set last_indx [expr $brrk_curvcnt - 1]
	if {$apply} {
		set ampratio [expr $spkul / $spekfrm(hi)] 
		set k 0
		while {$k < $brrk_curvcnt} {
			catch {unset output}
			foreach {frq amp} $spek_c($k) {
				set amp [expr $amp - $spekfrm(lo)]
				set amp [expr $amp * $ampratio]
				set amp [expr $amp + $spekfrm(lo)]
				lappend output $frq $amp
			}
			set spek_c($k) $output
			incr k
		}
		set k 0
	} else {
		if {$spk(interpd)} {
			Inf "Adjust range before doing smoothing"
			return 0			
		}
		if {$brrk_curvcnt > 1} {
			Inf "Only applicable to a single curve"
			return 0
		}
		set f .spkul
		if [Dlg_Create $f "Data upper limit" "set pr_spkul 0" -borderwidth 2 -width 80] {
			button $f.0 -text "Set Limit" -command "set pr_spkul 1"  -highlightbackground [option get . background {}]
			label $f.1 -text "Upper Limit "
			entry $f.2 -textvariable spkul -width 8
			button $f.3 -text "Abandon" -command "set pr_spkul 0"  -highlightbackground [option get . background {}]
			pack $f.0 $f.1 $f.2 $f.3 -side left -padx 2
			wm resizable $f 0 0
			bind $f <Return> {set pr_spkul 1}
			bind $f <Escape> {set pr_spkul 0}
		}
		set pr_spkul 0
		ScreenCentre $f
		update idletasks
		raise $f
		update idletasks
		My_Grab 0 $f pr_spkul $f.2
		update idletasks
		set finished 0
		while {!$finished} {
			tkwait variable pr_spkul
			if {$pr_spkul} {
				if {![IsNumeric $spkul] || ($spkul <= 0.0)} {
					Inf "Invalid upper limit value"
					continue
				}
				if {$spkul > $spekfrm(hi)} {
					Inf "Upper data limit is beyond range of disdplay"
					continue
				}
				if {![Flteq $spkul $spekfrm(hi)]} {
					catch {unset output}
					if {![info exists orig_range_spek_c]} {
						set orig_range_spek_c $spek_c($last_indx)
						foreach nam [array names spek] {
							set orig_range_spek($nam) $spek($nam)
						}
						foreach nam [array names spekfrm] {
							set orig_range_spekfrm($nam) $spekfrm($nam)
						}
					}
					set ampratio [expr $spkul / $spekfrm(hi)] 
					foreach {frq amp} $spek_c($last_indx) {
						set amp [expr $amp - $spekfrm(lo)]
						set amp [expr $amp * $ampratio]
						set amp [expr $amp + $spekfrm(lo)]
						lappend output $frq $amp
					}
					set last_spek_c $spek_c($last_indx)
					set spek_c($last_indx) $output
					set thistransform [list UPPER $spkul]
					lappend spektransform $thistransform
				}
				set k $last_indx
				set finished 1
			} else {
				set k $brrk_curvcnt
				set finished 1
			}
		}
		My_Release_to_Dialog $f
		Dlg_Dismiss $f
		incr spk(mod)
	}
	while {$k < $brrk_curvcnt} {
		catch {$bsh(can) delete points($k)} in
		catch {$bsh(can) delete cline($k)} in
		GetGraphCoordsAndDrawCurve $k 1
		incr k
	}
	$bsh_list delete 0 end
	foreach {frq amp} $spek_c($last_indx) {
		set vals [list $frq $amp]
		$bsh_list insert end $vals
	}
	.show_brkfile2.btns9.data.ll config -text "Spectrum from curve $brrk_curvcnt" -fg $brrkcolor([expr $brrk_curvcnt - 1])
	return 1
}

proc SetHorizontalRangeOfData {apply} {
	global brrk_curvcnt pr_spkhr spkup spkdn spekfrm
	global spektransform bsh disppl_c brrkcolor bsh_list bsh spek_c orig_range_spek_c wstk evv
	global orig_range_spek orig_range_spekfrm spek last_spek_c spk

	if {![info exists spek_c]} {
		Inf "Generate spectrum first (change to spectral range)"
		return 0
	}
	if {!$apply && $spk(ified)} {
		Inf "Already converted to playable data"
		return 0
	}
	if {[info exists spk(zoom)]} {
		SetSpekZoom 0
	}
	set last_indx [expr $brrk_curvcnt - 1]
	if {$apply} {
		set irange [expr $spekfrm(endfreq) - $spekfrm(startfreq)]
		set orange [expr $spkup - $spkdn]
		set k 0
		while {$k < $brrk_curvcnt} {
			catch {unset output}
			foreach {frq amp} $spek_c($k) {
				set val [expr ($frq - $spekfrm(startfreq))/$irange]
				set val [expr $val * $orange]
				set val [expr $val + $spkdn]
				lappend output $val $amp
			}
			if {[lindex $output 0] > 0.0} {
				set zzz [list 0.0 0.0]
				set output [concat $zzz $output]
			}
			set len [llength $output]
			incr len -2
			if {[lindex $output $len] < $evv(SPEKNYQUIST)} {
				set zzz [list $evv(SPEKNYQUIST) 0.0]
				set output [concat $output $zzz]
			}
			set spek_c($k) $output
			incr k
		}
	} else {
		if {$spk(interpd)} {
			Inf "Adjust range before doing smoothing"
			return 0			
		}
		if {$brrk_curvcnt > 1} {
			Inf "Apply to a single curve only"
			return 0			
		}
		set f .speklims
		if [Dlg_Create $f "Data frequency limits" "set pr_spkhr 0" -borderwidth 2 -width 80] {
			button $f.0 -text "Set Limits" -command "set pr_spkhr 1"  -highlightbackground [option get . background {}]
			label $f.1 -text "Lower Frq Limit "
			entry $f.2 -textvariable spkdn -width 8
			label $f.3 -text "Upper Frq Limit "
			entry $f.4 -textvariable spkup -width 8
			button $f.5 -text "Abandon" -command "set pr_spkhr 0"  -highlightbackground [option get . background {}]
			pack $f.0 $f.1 $f.2 $f.3 $f.4 $f.5 -side left -padx 2
			wm resizable $f 0 0
			bind $f <Return> {set pr_spkhr 1}
			bind $f <Escape> {set pr_spkhr 0}
		}
		set spkdn 0
		set spkup $evv(SPEKNYQUIST)
		set pr_spkhr 0
		ScreenCentre $f
		update idletasks
		raise $f
		update idletasks
		My_Grab 0 $f pr_spkhr $f.2
		update idletasks
		set finished 0
		while {!$finished} {
			tkwait variable pr_spkhr
			if {$pr_spkhr} {
				if {![IsNumeric $spkdn] || ($spkdn < 0.0)} {
					Inf  "Invalid lower frq limit (min 0.0)"
					continue
				}
				if {![IsNumeric $spkup] || ($spkup > $evv(SPEKNYQUIST))} {
					Inf  "Invalid upper frq limit (max $evv(SPEKNYQUIST))"
					continue
				}
				if {$spkup <= $spkdn} {
					Inf  "Frq limits incompatible"
					continue
				}
				catch {unset output}
				if {![info exists orig_range_spek_c]} {
					set orig_range_spek_c $spek_c($last_indx)
					foreach nam [array names spek] {
						set orig_range_spek($nam) $spek($nam)
					}
					foreach nam [array names spekfrm] {
						set orig_range_spekfrm($nam) $spekfrm($nam)
					}
				}
				set irange [expr double($spekfrm(endfreq) - $spekfrm(startfreq))]
				set orange [expr double($spkup - $spkdn)]
				foreach {frq amp} $spek_c($last_indx) {
					set val [expr ($frq - $spekfrm(startfreq))/$irange]
					set val [expr $val * $orange]
					set val [expr $val + $spkdn]
					lappend output $val $amp
				}
				if {[lindex $output 0] > 0.0} {
					set zzz [list 0.0 0.0]
					set output [concat $zzz $output]
				}
				set len [llength $output]
				incr len -2
				if {[lindex $output $len] < $evv(SPEKNYQUIST)} {
					set zzz [list $evv(SPEKNYQUIST) 0.0]
					set output [concat $output $zzz]
				}
				set last_spek_c $spek_c($last_indx)
				set spek_c($last_indx) $output
				set thistransform [list LIMITS $spkdn $spkup]
				lappend spektransform $thistransform
				set k $last_indx
				set finished 1
			} else {
				set k $brrk_curvcnt
				set finished 1
			}
		}
		My_Release_to_Dialog $f
		Dlg_Dismiss $f
		incr spk(mod)
	}
	while {$k < $brrk_curvcnt} {
		catch {$bsh(can) delete points($k)} in
		catch {$bsh(can) delete cline($k)} in
		GetGraphCoordsAndDrawCurve $k 1
		incr k
	}
	$bsh_list delete 0 end
	foreach {frq amp} $spek_c($last_indx) {
		set vals [list $frq $amp]
		$bsh_list insert end $vals
	}
	.show_brkfile2.btns9.data.ll config -text "Spectrum from curve $brrk_curvcnt" -fg $brrkcolor([expr $brrk_curvcnt - 1])
	return 1
}

proc ExpandContractHorizontalRange {apply} {
	global brrk_curvcnt pr_spkstr spekfrm spk_stretch
	global spektransform bsh brrkcolor bsh_list bsh spek_c orig_range_spek_c wstk evv
	global orig_range_spek set orig_range_spekfrm spek last_spek_c spk

	if {![info exists spek_c]} {
		Inf "Generate spectrum first (change to spectral range)"
		return 0
	}
	if {!$apply && $spk(ified)} {
		Inf "Already converted to playable data"
		return 0
	}
	set last_indx [expr $brrk_curvcnt - 1]
	if {$apply} {
		set irange [expr $spekfrm(endfreq) - $spekfrm(startfreq)]
		set orange [expr $irange * $spk_stretch]
		set k 0
		while {$k < $brrk_curvcnt} {
			catch {unset output}
			foreach {frq amp} $spek_c($k) {
				set val [expr ($frq - $spekfrm(startfreq))/$irange]
				set val [expr $val * $orange]
				set val [expr $val + $spekfrm(startfreq)]
				if {$val <= $evv(SPEKNYQUIST)} {
					lappend output $val $amp
				}
			}
			if {[lindex $output 0] > 0.0} {
				set zzz [list 0.0 0.0]
				set output [concat $zzz $output]
			}
			set len [llength $output]
			incr len -2
			if {[lindex $output $len] < $evv(SPEKNYQUIST)} {
				set zzz [list $evv(SPEKNYQUIST) 0.0]
				set output [concat $output $zzz]
			}
			set spek_c($k) $output
			incr k
		}
	} else {
		if {$spk(interpd)} {
			Inf "Adjust range before doing smoothing"
			return 0			
		}
		if {$brrk_curvcnt > 1} {
			Inf "Apply to a single curve only"
			return 0			
		}
		set spekchans [expr ($evv(ANALPOINTS)/2) + 1]
		set outchwidth [expr double($evv(SPEKNYQUIST)) / double($spekchans)]
		set f .spekstr
		if [Dlg_Create $f "Frequency range stretch" "set pr_spkstr 0" -borderwidth 2 -width 80] {
			button $f.0 -text "Stretch/Shrink Range" -command "set pr_spkstr 1"  -highlightbackground [option get . background {}]
			label $f.1 -text "Stretch Factor "
			entry $f.2 -textvariable spkstr -width 8
			button $f.5 -text "Abandon" -command "set pr_spkstr 0"  -highlightbackground [option get . background {}]
			pack $f.0 $f.1 $f.2 -side left -padx 2
			pack $f.5 -side right
			wm resizable $f 0 0
			bind $f <Return> {set pr_spkstr 1}
			bind $f <Escape> {set pr_spkstr 0}
		}
		set spkstr 1.0
		set pr_spkstr 0
		ScreenCentre $f
		update idletasks
		raise $f
		update idletasks
		My_Grab 0 $f pr_spkstr $f.2
		update idletasks
		set finished 0
		while {!$finished} {
			tkwait variable pr_spkstr
			if {$pr_spkstr} {
				if {![IsNumeric $spkstr] || ($spkstr < $evv(FLTERR))} {
					Inf  "Invalidfrq range stretch factor (min 0.0)"
					continue
				}
				set top [expr $spkstr * $spekfrm(endfrq)]
				set bot [expr $spkstr * $spekfrm(startfrq)]
				if {$top > $evv(SPEKNYQUIST)} {
					Inf  "Stretch is too large"
					continue
				}
				if {[expr $top - $bot] < [expr $outchwidth * 2]} {
					Inf  "Stretch is too small"
					continue
				}
				catch {unset output}
				if {![info exists orig_range_spek_c]} {
					set orig_range_spek_c $spek_c($last_indx)
					foreach nam [array names spek] {
						set orig_range_spek($nam) $spek($nam)
					}
					foreach nam [array names spekfrm] {
						set orig_range_spekfrm($nam) $spekfrm($nam)
					}
				}
				set irange [expr double($spekfrm(endfreq) - $spekfrm(startfreq))]
				set orange [expr $irange * $spkstr)]
				foreach {frq amp} $spek_c($last_indx) {
					set val [expr ($frq - $spekfrm(startfreq))/$irange]
					set val [expr $val * $orange]
					set val [expr $val + $spekfrm(startfreq)]
					lappend output $val $amp
				}
				if {[lindex $output 0] > 0.0} {
					set zzz [list 0.0 0.0]
					set output [concat $zzz $output]
				}
				set len [llength $output]
				incr len -2
				if {[lindex $output $len] < $evv(SPEKNYQUIST)} {
					set zzz [list $evv(SPEKNYQUIST) 0.0]
					set output [concat $output $zzz]
				}
				set last_spek_c $spek_c($last_indx)
				set spek_c($last_indx) $output
				set thistransform [list STRETCH $spkstr]
				lappend spektransform $thistransform
				set k $last_indx
				set finished 1
			} else {
				set k $brrk_curvcnt
				set finished 1
			}
		}
		My_Release_to_Dialog $f
		Dlg_Dismiss $f
		incr spk(mod)
	}
	while {$k < $brrk_curvcnt} {
		catch {$bsh(can) delete points($k)} in
		catch {$bsh(can) delete cline($k)} in
		GetGraphCoordsAndDrawCurve $k 1
		incr k
	}
	$bsh_list delete 0 end
	foreach {frq amp} $spek_c($last_indx) {
		set vals [list $frq $amp]
		$bsh_list insert end $vals
	}
	.show_brkfile2.btns9.data.ll config -text "Spectrum from curve $brrk_curvcnt" -fg $brrkcolor([expr $brrk_curvcnt - 1])
	return 1
}

proc ShiftHorizontalDataRange {apply} {
	global brrk_curvcnt pr_spkshft spkshft spekfrm
	global spektransform bsh brrkcolor bsh_list bsh spek_c orig_range_spek_c swtk evv
	global orig_range_spek orig_range_spekfrm spek last_spek_c spk

	if {![info exists spek_c]} {
		Inf "Generate spectrum first (change to spectral range)"
		return 0
	}
	if {!$apply && $spk(ified)} {
		Inf "Already converted to playable data"
		return 0
	}
	set last_indx [expr $brrk_curvcnt - 1]
	if {$apply} {
		set k 0
		while {$k < $brrk_curvcnt} {
			catch {unset output}
			foreach {frq amp} $spek_c($k) {
				set val [expr $frq + $spkshft]
				if {($val < 0.0) || ($val > $evv(SPEKNYQUIST))} {
					if {$amp > 0.0} {
						Inf  "Spectral shift out of range for curve [expr $k + 1]"
						return 0
					} else {
						continue
					}
				}
				lappend output $val $amp
			}
			if {![info exists output]} {
				Inf "Spectrum shifted out of range for curve [expr $k + 1]"
				return 0
			}
			if {[lindex $output 0] > 0.0} {
				set zzz [list 0.0 0.0]
				set output [concat $zzz $output]
			}
			set len [llength $output]
			incr len -2
			if {[lindex $output $len] < $evv(SPEKNYQUIST)} {
				set zzz [list $evv(SPEKNYQUIST) 0.0]
				set output [concat $output $zzz]
			}
			set spek_c($k) $output
			incr k
		}

	} else {
		if {$spk(interpd)} {
			Inf "Adjust range before doing smoothing"
			return 0			
		}
		if {$brrk_curvcnt > 1} {
			Inf "Apply to a single curve only"
			return 0			
		}
		set f .spekshift
		if [Dlg_Create $f "Shift spectral range" "set pr_spkshft 0" -borderwidth 2 -width 80] {
			button $f.0 -text "Shift Spectrum" -command "set pr_spkshft 1"  -highlightbackground [option get . background {}]
			label $f.1 -text "Shift (Hz) "
			entry $f.2 -textvariable spkshft -width 8
			button $f.5 -text "Abandon" -command "set pr_spkshft 0"  -highlightbackground [option get . background {}]
			pack $f.0 $f.1 $f.2 $f.5 -side left -padx 2
			wm resizable $f 0 0
			bind $f <Return> {set pr_spkshft 1}
			bind $f <Escape> {set pr_spkshft 0}
		}
		set spkshft 0
		set pr_spkshft 0
		ScreenCentre $f
		update idletasks
		raise $f
		update idletasks
		My_Grab 0 $f pr_spkshft $f.2
		update idletasks
		set finished 0
		while {!$finished} {
			tkwait variable pr_spkshft
			if {$pr_spkshft} {
				if {![IsNumeric $spkshft] || [Flteq $spkshft 0.0]} {
					Inf  "Invalid spectral shift"
					continue
				}
				set OK 1
				foreach {amp frq} $spek_c($last_indx) {
					set val [expr $frq + $spkshft]
					if {($val < 0.0) || ($val > $evv(SPEKNYQUIST))} {
						if {$amp > 0.0} {
							Inf  "Spectral shift out of range"
							set OK 0
							break
						}
					}
				}
				if {!$OK} {
					continue
				}
				catch {unset output}
				if {![info exists orig_range_spek_c]} {
					set orig_range_spek_c $spek_c($last_indx)
					foreach nam [array names spek] {
						set orig_range_spek($nam) $spek($nam)
					}
					foreach nam [array names spekfrm] {
						set orig_range_spekfrm($nam) $spekfrm($nam)
					}
				}
				foreach {frq amp} $spek_c($last_indx) {
					set val [expr $frq + $spkshft]
					if {($val < 0.0)} {
						continue
					} elseif {$val > $evv(SPEKNYQUIST)} {
						break
					}
					lappend output $val $amp
				}
				if {![info exists output]} {
					Inf "Spectrum shifted out of range"
					continue
				}
				if {[lindex $output 0] > 0.0} {
					set zzz [list 0.0 0.0]
					set output [concat $zzz $output]
				}
				set len [llength $output]
				incr len -2
				if {[lindex $output $len] < $evv(SPEKNYQUIST)} {
					set zzz [list $evv(SPEKNYQUIST) 0.0]
					set output [concat $output $zzz]
				}
				set last_spek_c $spek_c($last_indx)
				set spek_c($last_indx) $output
				set thistransform [list SHIFT $spkshft]
				lappend spektransform $thistransform
				set k $last_indx
				set finished 1
			} else {
				set k $brrk_curvcnt
				set finished 1
			}
		}
		My_Release_to_Dialog $f
		Dlg_Dismiss $f
		incr spk(mod)
	}
	while {$k < $brrk_curvcnt} {
		catch {$bsh(can) delete points($k)} in
		catch {$bsh(can) delete cline($k)} in
		GetGraphCoordsAndDrawCurve $k 1
		incr k
	}
	$bsh_list delete 0 end
	foreach {frq amp} $spek_c($last_indx) {
		set vals [list $frq $amp]
		$bsh_list insert end $vals
	}
	.show_brkfile2.btns9.data.ll config -text "Spectrum from curve $brrk_curvcnt" -fg $brrkcolor([expr $brrk_curvcnt - 1])
	return 1
}

#---- Need to do last, before conversion to sound

proc CubicSplineSmoothing {apply} {
	global brrk_curvcnt	evv CDPidrun prg_dun prg_abortd spek_c wstk
	global disppl_c bsh brrkcolor spektransform spk

	if {!$apply && $spk(ified)} {
		Inf "Already converted to playable data"
		return 0
	}
	if {$spk(interpd)} {
		if {!$apply} {
			Inf "Done smoothing already"
		}
		return 0
	}
	if {[info exists spk(zoom)]} {
		SetSpekZoom 0
	}
	DeleteAllTemporaryFiles
	set fnam0 $evv(DFLT_OUTNAME)
	append fnam0 0 $evv(TEXT_EXT)
	set fnam1 $evv(DFLT_OUTNAME)
	append fnam1 1 $evv(TEXT_EXT)
	if {!$apply} {
		if {[info exists brrk_curvcnt] && ($brrk_curvcnt > 1)} {
			Inf "Only applicable to a single curve"
			return 0
		}
		set k [expr $brrk_curvcnt - 1]
		set j $brrk_curvcnt 
	} else {
		set k 0
	}
	if {![info exists evv(SPEKNYQUIST)]} {
		Inf "Set the sample rate before proceeding"
		return 0
	}
	set speksr [expr $evv(SPEKNYQUIST) * 2]
	if {![info exists evv(ANALPOINTS)]} {
		Inf "Set the analysis channel count"
		return 0
	}
	if {![info exists spek_c]} {
		Inf "Create data in the spectral range first"
		return 0
	}
	while {$k < $brrk_curvcnt} {
		if {$apply} {
			wm title .blocker  "PLEASE WAIT:      Splining curve [expr $k + 1]"
		}
		catch {file delete $fnam1}
		if [catch {open $fnam0 "w"} zit] {
			Inf "Cannot open temporary file for splining curve [expr $k + 1]"
			incr k
			continue
		}
		set lastfrq -1.0
		set OK 1
		foreach {frq amp} $spek_c($k) {
			if {($frq < 0.0) || ($frq > $evv(SPEKNYQUIST)) || ($frq < $lastfrq) } {
				Inf "Invalid frequency value, or order, for curve [expr $k + 1]"
				set OK 0
				break
			}
			set lastfrq $frq
			if {($amp < 0.0) || ($amp > 1.0)} {
				Inf "Invalid amplitude value for curve [expr $k + 1]"
				set OK 0
				break
			}
			set line [list $frq $amp]
			puts $zit $line
		}
		close $zit
		if {!$OK} {
			incr k
			continue
		}
		set cmd [file join $evv(CDPROGRAM_DIR) cubicspline]
		lappend cmd $fnam0 $fnam1 $evv(ANALPOINTS) $speksr -s
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "Cubic spline failed to run for curve [$k + 1]"
			DeleteAllTemporaryFiles
			incr k
			continue
   		} else {
   			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			Inf "Cubic spline failed for curve [$k + 1]"
			DeleteAllTemporaryFiles
			incr k
			continue
		}
		if [catch {open $fnam1 "r"} zit] {
			Inf "Failed to open file $fnam1 of splined data to read it"
			incr k
			continue
		}
		if {!$apply} {
			incr k		;#	 FOR TEST TRANSFORM, CREATE NEW CURVE
		} else {
			catch {unset spek_c($k)}
		}
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			} else {
				set line [split $line]
				catch {unset nuline}
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] <= 0} {
						continue
					}
					lappend spek_c($k) $item		;#	FOR APPLIED TRANSFOPRM, OVERWRITE ORIG
				}
			}
		}
		close $zit
		if {!$apply} {
			set gotit 1
			break
		}
		incr k
	}
	if {!$apply && [info exists gotit]} {
		incr brrk_curvcnt
		SetupSpekDisplay_c $k						;#	Establish display-coords of points.
		catch {unset line_c}
		foreach {x y} $disppl_c($k) {
			set x [expr $x + $evv(BPWIDTH)]
			set y [expr $y + $evv(BPWIDTH)]
			lappend line_c $x $y
		}
		eval {$bsh(can) create line} $line_c {-fill $brrkcolor($k)} {-tag cline($k)}
		set msg "Is the smoothed curve ok ??"
		set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			set spek_c(0) $spek_c(1)
			unset spek_c(1)
			set disppl_c(0) $disppl_c(1)
			unset disppl_c(1)
			SetupSpekDisplay_c 0
			catch {$bsh(can) delete cline(0)} in
			catch {$bsh(can) delete cline(1)} in
			incr brrk_curvcnt -1
			catch {unset line_c}
			foreach {x y} $disppl_c(0) {
				set x [expr $x + $evv(BPWIDTH)]
				set y [expr $y + $evv(BPWIDTH)]
				lappend line_c $x $y
			}
			eval {$bsh(can) create line} $line_c {-fill $brrkcolor(0)} {-tag cline(0)}
			set spk(interpd) 1
			set thistransform [list SPLINE]
			lappend spektransform $thistransform
		} else {
			unset spek_c(1)
			unset disppl_c(1)
			catch {$bsh(can) delete cline(1)} in
			incr brrk_curvcnt -1
		}
		incr spk(mod)
	}
	if {$apply} {
		set spk(interpd) 1
	}
	return 1
}

#---- Need to do last, before conversion to sound

proc LinearSmoothing {apply} {
	global brrk_curvcnt	evv CDPidrun prg_dun prg_abortd spek_c wstk
	global disppl_c bsh brrkcolor spektransform spk

	if {!$apply && $spk(ified)} {
		Inf "Already converted to playable data"
		return 0
	}
	if {$spk(interpd)} {
		Inf "Done smoothing already"
		return 0
	}
	if {[info exists spk(zoom)]} {
		SetSpekZoom 0
	}
	DeleteAllTemporaryFiles
	set fnam0 $evv(DFLT_OUTNAME)
	append fnam0 0 $evv(TEXT_EXT)
	set fnam1 $evv(DFLT_OUTNAME)
	append fnam1 1 $evv(TEXT_EXT)
	if {!$apply} {
		if {[info exists brrk_curvcnt] && ($brrk_curvcnt > 1)} {
			Inf "Only applicable to a single curve"
			return 0
		}
		set k [expr $brrk_curvcnt - 1]
		set j $brrk_curvcnt 
	} else {
		set k 0
	}
	if {![info exists evv(SPEKNYQUIST)]} {
		Inf "Set the sample rate before proceeding"
		return 0
	}
	set speksr [expr $evv(SPEKNYQUIST) * 2]
	if {![info exists evv(ANALPOINTS)]} {
		Inf "Set the analysis channel count"
		return 0
	}
	if {![info exists spek_c]} {
		Inf "Create data in the spectral range first"
		return 0
	}
	while {$k < $brrk_curvcnt} {
		if {$apply} {
			wm title .blocker  "PLEASE WAIT:      Interpolating file [expr $k + 1]"
		}
		catch {file delete $fnam1}
		if [catch {open $fnam0 "w"} zit] {
			Inf "Cannot open temporary file for interpolating curve [expr $k + 1]"
			incr k
			continue
		}
		set lastfrq -1.0
		set OK 1
		foreach {frq amp} $spek_c($k) {
			if {($frq < 0.0) || ($frq > $evv(SPEKNYQUIST)) || ($frq < $lastfrq) } {
				Inf "Invalid frequency value, or order, for curve [expr $k + 1]"
				set OK 0
				break
			}
			set lastfrq $frq
			if {($amp < 0.0) || ($amp > 1.0)} {
				Inf "Invalid amplitude value for curve [expr $k + 1]"
				set OK 0
				break
			}
			set line [list $frq $amp]
			puts $zit $line
		}
		close $zit
		if {!$OK} {
			incr k
			continue
		}
		set cmd [file join $evv(CDPROGRAM_DIR) smooth]
		lappend cmd $fnam0 $fnam1 $evv(ANALPOINTS) $speksr -s
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "Linear interpolation failed to run for curve [$k + 1]"
			DeleteAllTemporaryFiles
			incr k
			continue
   		} else {
   			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			Inf "Linear interpolation failed for curve [$k + 1]"
			DeleteAllTemporaryFiles
			incr k
			continue
		}
		if [catch {open $fnam1 "r"} zit] {
			Inf "Failed to open file $fnam1 of interpolated data to read it"
			incr k
			continue
		}
		if {!$apply} {
			incr k		;#	 FOR TEST TRANSFORM, CREATE NEW CURVE
		} else {
			catch {unset spek_c($k)}
		}
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			} else {
				set line [split $line]
				catch {unset nuline}
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] <= 0} {
						continue
					}
					lappend spek_c($k) $item		;#	FOR APPLIED TRANSFOPRM, OVERWRITE ORIG
				}
			}
		}
		close $zit
		if {!$apply} {
			set gotit 1
			break
		}
		incr k
	}
	if {!$apply && [info exists gotit]} {
		incr brrk_curvcnt
		SetupSpekDisplay_c $k						;#	Establish display-coords of points.
		catch {unset line_c}
		foreach {x y} $disppl_c($k) {
			set x [expr $x + $evv(BPWIDTH)]
			set y [expr $y + $evv(BPWIDTH)]
			lappend line_c $x $y
		}
		eval {$bsh(can) create line} $line_c {-fill $brrkcolor($k)} {-tag cline($k)}
		set msg "Is the smoothed curve ok ??"
		set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			set spek_c(0) $spek_c(1)
			unset spek_c(1)
			set disppl_c(0) $disppl_c(1)
			unset disppl_c(1)
			SetupSpekDisplay_c 0
			catch {$bsh(can) delete cline(0)} in
			catch {$bsh(can) delete cline(1)} in
			incr brrk_curvcnt -1
			catch {unset line_c}
			foreach {x y} $disppl_c(0) {
				set x [expr $x + $evv(BPWIDTH)]
				set y [expr $y + $evv(BPWIDTH)]
				lappend line_c $x $y
			}
			eval {$bsh(can) create line} $line_c {-fill $brrkcolor(0)} {-tag cline(0)}
			set spk(interpd) 1
			set thistransform [list LINEAR]
			lappend spektransform $thistransform
		} else {
			unset spek_c(1)
			unset disppl_c(1)
			catch {$bsh(can) delete cline(1)} in
			incr brrk_curvcnt -1
		}
		incr spk(mod)
	}
	if {$apply} {
		set spk(interpd) 1
	}
	return 1
}

proc ResetOriginalDataRange {} {
	global brrk_curvcnt spekfrm
	global spektransform bsh brrkcolor bsh_list bsh spek_c orig_range_spek_c swtk evv
	global orig_range_spek orig_range_spekfrm spek spk

	if {![info exists spek_c]} {
		Inf "Generate spectrum first (change to spectral range)"
		return
	}
	if {$spk(ified)} {
		Inf "Already converted to playable data"
		return 0
	}
	if {![info exists orig_range_spek_c]} {
		Inf "No data on original spectral range"
		return
	}
	catch {unset spk(finalised)}
	foreach nam [array names spek] {
		set spek($nam) $orig_range_spek($nam)
	}
	foreach nam [array names spekfrm] {
		set spekfrm($nam)  $orig_range_spekfrm($nam)
	}
	set k [expr $brrk_curvcnt - 1]
	set spek_c($k) $orig_range_spek_c
	set spk(interpd) 0
	
	catch {$bsh(can) delete points($k)} in
	catch {$bsh(can) delete cline($k)} in
	GetGraphCoordsAndDrawCurve $k 1
	$bsh_list delete 0 end
	foreach {frq amp} $spek_c($k) {
		set vals [list $frq $amp]
		$bsh_list insert end $vals
	}
	.show_brkfile2.btns9.data.ll config -text "Spectrum from curve $brrk_curvcnt" -fg $brrkcolor([expr $brrk_curvcnt - 1])
	unset orig_range_spek_c
	unset orig_range_spek
	unset orig_range_spekfrm
	if {[info exists spektransform} {
		set spektransform [lrange $spektransform 0 0]
	}
	set spk(mod) 0
}

proc UndoLastSpekChange {} {
	global brrk_curvcnt spekfrm
	global spektransform bsh brrkcolor bsh_list bsh spek_c orig_range_spek_c swtk evv
	global orig_range_spek orig_range_spekfrm spek last_spek_c spk

	if {$spk(ified)} {
		Inf "Already converted to playable data"
		return 0
	}
	if {![info exists spek_c]} {
		Inf "Generate spectrum first (change to spectral range)"
		return
	}
	if {![info exists last_spek_c]} {
		Inf "No previous change to undo"
		return
	}
	catch {unset spk(finalised)}
	set lasttransform [lindex $spektransform end]
	set action [lindex $lasttransform 0]
	if {($action == "SPLINE") || ($action == "LINEAR")} {
		set spk(interpd) 0
	}
	set k [expr $brrk_curvcnt - 1]
	set spek_c($k) $last_spek_c
	
	catch {$bsh(can) delete points($k)} in
	catch {$bsh(can) delete cline($k)} in
	GetGraphCoordsAndDrawCurve $k 1
	$bsh_list delete 0 end
	foreach {frq amp} $spek_c($k) {
		set vals [list $frq $amp]
		$bsh_list insert end $vals
	}
	.show_brkfile2.btns9.data.ll config -text "Spectrum from curve $brrk_curvcnt" -fg $brrkcolor([expr $brrk_curvcnt - 1])
	set spektransform [lreplace $spektransform end end]
	if {$spk(mod) > 0} {
		incr spk(mod) -1
	}

}

proc KeepPreSound {} {
	global brrk_curvcnt wstk spk evv
	set doit 0
	if {[info exists brrk_curvcnt] && ($brrk_curvcnt > 1)} {
		Inf "Only applies to a single curve"
		return
	}
	if {[info exists spk(finalised)]} {
		set msg "Transform sequence already saved: save again ??"
	} else {
		set msg "Store the transform sequence as far as this point ??"
	}
	set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
	if {$choice == "yes"} {
		SaveAndNameCurrentTransform $evv(SPEKT_PRESND)
		set spk(finalised) 1
	}
}

#----- Exaggerate or flatten curve

proc ExaggerateFlattenVerticalDisplay {apply} {
	global brrk_curvcnt pr_spekflat spekflat spekfrm spektransform bsh brrkcolor bsh_list brrk_curvcnt
	global bsh spek_c orig_range_spek_c orig_range_spek orig_range_spekfrm spek wstk evv last_spek_c spk

	if {![info exists spek_c]} {
		Inf "Generate spectrum first (change to spectral range)"
		return 0
	}
	if {!$apply && $spk(ified)} {
		Inf "Already converted to playable data"
		return 0
	}
	set last_indx [expr $brrk_curvcnt - 1]
	if {$apply} {
		set k 0
		while {$k < $brrk_curvcnt} {
			set maxamp 0.0
			foreach {frq amp} $spek_c($k) {
				if {$amp > $maxamp} {
					set maxamp $amp
				}
			}
			if {$maxamp == 0} {
				Inf "One of these spectra is everywhere zero: cannot proceed to exaggerate/flatten"
				return 0
			}
			incr k
		}
		set k 0
		while {$k < $brrk_curvcnt} {
			set maxamp 0.0
			foreach {frq amp} $spek_c($k) {
				if {$amp > $maxamp} {
					set maxamp $amp
				}
			}
			catch {unset output}
			foreach {frq amp} $spek_c($k) {
				set amp [expr $amp/$maxamp]
				set amp [expr pow($amp,$spekflat)]
				set amp [expr $amp * $maxamp]
				lappend output $frq $amp
			}
			set spek_c($k) $output
			incr k
		}
		set k 0
	} else {
		if {$spk(interpd)} {
			Inf "Exaggerate/flatten before doing smoothing"
			return 0			
		}
		if {$brrk_curvcnt > 1} {
			Inf "Only applicable to a single curve"
			return 0
		}
		set f .spekflat
		if [Dlg_Create $f "Exaggerate/Flatten curve" "set pr_spekflat 0" -borderwidth 2 -width 80] {
			frame $f.0
			button $f.0.0 -text "Set Ratio" -command "set pr_spekflat 1"  -highlightbackground [option get . background {}]
			label $f.0.1 -text "Squash Ratio "
			entry $f.0.2 -textvariable spekflat -width 8
			button $f.0.3 -text "Abandon" -command "set pr_spekflat 0"  -highlightbackground [option get . background {}]
			pack $f.0.0 $f.0.1 $f.0.2 $f.0.3 -side left -padx 2
			pack $f.0 -side top -fill x -expand true
			label $f.1 -text "Ratio > 1 Increases gap between peaks and troughs" -fg $evv(SPECIAL)
			label $f.2 -text "Ratio < 1 Reduces gap between peaks and troughs"  -fg $evv(SPECIAL)
			pack $f.1 $f.2 -side top -pady 2
			wm resizable $f 0 0
			bind $f <Return> {set pr_spekflat 1}
			bind $f <Escape> {set pr_spekflat 0}
		}
		set pr_spekflat 0
		ScreenCentre $f
		update idletasks
		raise $f
		update idletasks
		My_Grab 0 $f pr_spekflat $f.2
		update idletasks
		set finished 0
		while {!$finished} {
			tkwait variable pr_spekflat
			if {$pr_spekflat} {
				if {![IsNumeric $spekflat] || ($spekflat <= 0.0)} {
					Inf "Invalid squash value"
					continue
				}
				if {$spekflat > 1000.0} {
					Inf "Unlikely squash value"
					continue
				}
				if {[flteq $spekflat 1.0]} {
					Inf "Squash value of 1.0 has no effect"
					continue
				}
				catch {unset output}
				if {![info exists orig_range_spek_c]} {
					set orig_range_spek_c $spek_c($last_indx)
					foreach nam [array names spek] {
						set orig_range_spek($nam) $spek($nam)
					}
					foreach nam [array names spekfrm] {
						set orig_range_spekfrm($nam) $spekfrm($nam)
					}
				}
				set maxamp 0.0
				foreach {frq amp} $spek_c($last_indx) {
					if {$amp > $maxamp} {
						set maxamp $amp
					}
				}
				if {$maxamp <= 0.0} {
					Inf "Spectrum is everywhere zero, cannot proceed"
					continue
				}
				foreach {frq amp} $spek_c($last_indx) {
					set amp [expr $amp/$maxamp]
					set amp [expr pow($amp,$spekflat)]
					set amp [expr $amp * $maxamp]
					lappend output $frq $amp
				}
				set last_spek_c $spek_c($last_indx)
				set spek_c($last_indx) $output
				set thistransform [list FLAT $spekflat]
				lappend spektransform $thistransform
				set k $last_indx
				set finished 1
			} else {
				set k $brrk_curvcnt
				set finished 1
			}
		}
		My_Release_to_Dialog $f
		Dlg_Dismiss $f
		incr spk(mod)
	}
	while {$k < $brrk_curvcnt} {
		catch {$bsh(can) delete points($k)} in
		catch {$bsh(can) delete cline($k)} in
		GetGraphCoordsAndDrawCurve $k 1
		incr k
	}
	$bsh_list delete 0 end
	foreach {frq amp} $spek_c($last_indx) {
		set vals [list $frq $amp]
		$bsh_list insert end $vals
	}
	.show_brkfile2.btns9.data.ll config -text "Spectrum from curve $brrk_curvcnt" -fg $brrkcolor([expr $brrk_curvcnt - 1])
	return 1
}

proc WarpHorizontalDisplay {apply} {
	global brrk_curvcnt pr_spekwarp spekwarp spekfrm spektransform bsh brrkcolor bsh_list brrk_curvcnt
	global bsh spek_c orig_range_spek_c orig_range_spek orig_range_spekfrm spek wstk evv last_spek_c spk

	if {![info exists spek_c]} {
		Inf "Generate spectrum first (change to spectral range)"
		return 0
	}
	if {!$apply && $spk(ified)} {
		Inf "Already converted to playable data"
		return 0
	}
	set last_indx [expr $brrk_curvcnt - 1]
	if {$apply} {
		set k 0
		while {$k < $brrk_curvcnt} {
			catch {unset output}
			foreach {frq amp} $spek_c($k) {
				set frq [expr $frq/$spekfrm(endfreq)]
				set frq [expr pow($frq,$spekwarp)]
				set frq [expr $frq * $spekfrm(endfreq)]
				lappend output $frq $amp
			}
			set spek_c($k) $output
			incr k
		}
		set k 0
	} else {
		if {$spk(interpd)} {
			Inf "Warp frequency range before doing smoothing"
			return 0			
		}
		if {$brrk_curvcnt > 1} {
			Inf "Only applicable to a single curve"
			return 0
		}
		set f .spekwarp
		if [Dlg_Create $f "Warp frequency range of spectrum" "set pr_spekwarp 0" -borderwidth 2 -width 80] {
			frame $f.0
			button $f.0.0 -text "Set Warp" -command "set pr_spekwarp 1"  -highlightbackground [option get . background {}]
			label $f.0.1 -text "Warp Ratio "
			entry $f.0.2 -textvariable spekwarp -width 8
			button $f.0.3 -text "Abandon" -command "set pr_spekwarp 0"  -highlightbackground [option get . background {}]
			pack $f.0.0 $f.0.1 $f.0.2 $f.0.3 -side left -padx 2
			pack $f.0 -side top -fill x -expand true
			label $f.1 -text "Ratio > 1 Spectrum squeezed towards the LOW frequencies"  -fg $evv(SPECIAL)
			label $f.2 -text "Ratio < 1 Spectrum squeezed towards the HIGH frequencies" -fg $evv(SPECIAL)
			pack $f.1 $f.2 -side top -pady 2
			wm resizable $f 0 0
			bind $f <Return> {set pr_spekwarp 1}
			bind $f <Escape> {set pr_spekwarp 0}
		}
		set pr_spekwarp 0
		ScreenCentre $f
		update idletasks
		raise $f
		update idletasks
		My_Grab 0 $f pr_spekwarp $f.2
		update idletasks
		set finished 0
		while {!$finished} {
			tkwait variable pr_spekwarp
			if {$pr_spekwarp} {
				if {![IsNumeric $spekwarp] || ($spekwarp <= 0.0)} {
					Inf "Invalid warp value"
					continue
				}
				if {$spekwarp > 1000.0} {
					Inf "Unlikely warp value"
					continue
				}
				if {[flteq $spekwarp 1.0]} {
					Inf "Warp value of 1.0 has no effect"
					continue
				}
				catch {unset output}
				if {![info exists orig_range_spek_c]} {
					set orig_range_spek_c $spek_c($last_indx)
					foreach nam [array names spek] {
						set orig_range_spek($nam) $spek($nam)
					}
					foreach nam [array names spekfrm] {
						set orig_range_spekfrm($nam) $spekfrm($nam)
					}
				}
				foreach {frq amp} $spek_c($last_indx) {
					set frq [expr $frq/$spekfrm(endfreq)]
					set frq [expr pow($frq,$spekwarp)]
					set frq [expr $frq * $spekfrm(endfreq)]
					lappend output $frq $amp
				}
				set last_spek_c $spek_c($last_indx)
				set spek_c($last_indx) $output
				set thistransform [list WARP $spekwarp]
				lappend spektransform $thistransform
				set k $last_indx
				set finished 1
			} else {
				set k $brrk_curvcnt
				set finished 1
			}
		}
		My_Release_to_Dialog $f
		Dlg_Dismiss $f
		incr spk(mod)
	}
	while {$k < $brrk_curvcnt} {
		catch {$bsh(can) delete points($k)} in
		catch {$bsh(can) delete cline($k)} in
		GetGraphCoordsAndDrawCurve $k 1
		incr k
	}
	$bsh_list delete 0 end
	foreach {frq amp} $spek_c($last_indx) {
		set vals [list $frq $amp]
		$bsh_list insert end $vals
	}
	.show_brkfile2.btns9.data.ll config -text "Spectrum from curve $brrk_curvcnt" -fg $brrkcolor([expr $brrk_curvcnt - 1])
	return 1
}

#--- Play spectra generated

proc PlaySpekOutput {last} {
	global spekouts pr_spekouts evv
	if {![info exists spekouts]} {
		Inf "No spectra generated"
		return
	}
	if {$last || ([llength $spekouts] == 1)} {
		set fnam [lindex $spekouts end]
		PlaySndfile $fnam 0
		return
	}
	set f .spekouts
	if [Dlg_Create $f "Play spectra generated" "set pr_spekouts 0" -borderwidth 2 -width 80] {
		frame $f.0
		button $f.0.0 -text "Play Selected" -command "set pr_spekouts 1"  -highlightbackground [option get . background {}]
		button $f.0.1 -text "Abandon" -command "set pr_spekouts 0"  -highlightbackground [option get . background {}]
		pack $f.0.0 -side left
		pack $f.0.1 -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.tit -text "Spectra generated" -fg $evv(SPECIAL)
		Scrolled_Listbox $f.1.ll -width 32 -height 32 -selectmode single
		pack $f.1.tit $f.1.ll -side top -pady 2
		pack $f.1 -side top -pady 2
		wm resizable $f 0 0
		bind $f <Return> {set pr_spekouts 1}
		bind $f <Escape> {set pr_spekouts 0}
	}
	$f.1.ll.list delete 0 end
	foreach fnam $spekouts {
		$f.1.ll.list insert end $fnam
	}
	set pr_spekouts 0
	update idletasks
	raise $f
	update idletasks
	My_Grab 0 $f pr_spekouts $f.2
	update idletasks
	set finished 0
	while {!$finished} {
		tkwait variable pr_spekouts
		if {$pr_spekouts} {
			set i [$f.1.ll.list curselection]
			set fnam [$f.1.ll.list get $i]
			PlaySndfile $fnam 0
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Find sound output level from spek synth

proc GetSpekOutputLevel {} {
	global spekouts pr_spekouts evv maxsamp_line done_maxsamp CDPmaxId spek_sndgain

	if {![info exists spekouts]} {
		Inf "No spectra generated"
		return
	}
	if {[llength $spekouts] > 1} {
		Inf "Getting level of last output generated"
	}
	set fnam [lindex $spekouts end]
	set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
	catch {unset maxsamp_line}
	set done_maxsamp 0
	lappend cmd $fnam
	if [catch {open "|$cmd"} CDPmaxId] {
		Inf "Failed to find maximum level of output"
		return
	}
	fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
	vwait done_maxsamp
	if {![info exists maxsamp_line]} {
		Inf "Cannot retrieve maximum level"
		return
	}
	set maxoutsamp [lindex $maxsamp_line 0]
	set msg "Output level = $maxoutsamp"
	if {$maxoutsamp > $evv(FLTERR)} {
		set rat [expr 0.94 / $maxoutsamp]
		if {$maxoutsamp > 1.0} {
			append msg "\n\nReduce level (by [DecPlaces $rat 3]) to [DecPlaces [expr $spek_sndgain * $rat] 3]"
		} elseif {$maxoutsamp < 0.94} {
			append msg "\n\nCould increase transform level (by [DecPlaces $rat 3]) to [DecPlaces [expr $spek_sndgain * $rat] 3]"
		}
	}
	Inf $msg
}

proc RestoreDisplayOfDataSource {} {
	global brrk_curvcnt spk orig_brrkfrm
	set k 0
	set was_spekdisplay 0
	unset spk(display)
	RestoreOrigRanges
	EstablishGrafToRealConversionConstantsBrrk
	while {$k < $brrk_curvcnt} {
		GetGraphCoordsAndDrawCurve $k 0
		incr k
	}
	set spk(display) 1
}

proc SpekInvertNotches {apply} {
	global brrk_curvcnt	evv CDPidrun prg_dun prg_abortd spek_c wstk
	global disppl_c bsh brrkcolor spektransform spk pr_speknotch spekminnotch
	global readonlyfg readonlybg spek_minnotch

	if {!$apply} { 
		if {$spk(ified)} {
			Inf "Already converted to playable data"
			return 0
		}
		if {$spk(inverted)} {
			Inf "Done inversion already"
			return 0
		}
	}
	if {[info exists spk(zoom)]} {
		SetSpekZoom 0
	}
	DeleteAllTemporaryFiles
	set fnam0 $evv(DFLT_OUTNAME)
	append fnam0 0 $evv(TEXT_EXT)
	set fnam1 $evv(DFLT_OUTNAME)
	append fnam1 1 $evv(TEXT_EXT)
	if {!$apply} {
		if {[info exists brrk_curvcnt] && ($brrk_curvcnt > 1)} {
			Inf "Only applicable to a single curve"
			return 0
		}
		set k [expr $brrk_curvcnt - 1]
		set j $brrk_curvcnt 
	} else {
		set k 0
	}
	if {![info exists evv(SPEKNYQUIST)]} {
		Inf "Set the sample rate before proceeding"
		return 0
	}
	set speksr [expr $evv(SPEKNYQUIST) * 2]
	if {![info exists spek_c]} {
		Inf "Create data in the spectral range first"
		return 0
	}
	if {!$apply} {
		set f .speknotch
		if [Dlg_Create $f "Specify minimum notch" "set pr_speknotch 0" -borderwidth 2] {
			frame $f.0
			button $f.0.set -text "Confirm minimum" -command "set pr_speknotch 1"  -highlightbackground [option get . background {}]
			button $f.0.qu  -text "NO minimum" -command "set pr_speknotch 0"  -highlightbackground [option get . background {}]
			pack $f.0.set -side left		
			pack $f.0.qu -side right
			pack  $f.0 -side top -fill x -expand true
			frame $f.1
			entry $f.1.0 -textvariable spekminnotch -width 16 -fg $readonlyfg -readonlybackground $readonlybg
			label $f.1.1 -text "Minimum notch depth to qualify as valid notch"
			pack $f.1.0 $f.1.1 -side left
			pack  $f.1 -side top -pady 2
			label $f.2 -text "Up/Down (& Control Up/Down) Arrows change notch" -fg $evv(SPECIAL)
			pack  $f.2 -side top -pady 2		 
			wm resizable $f 0 0
			bind $f <Up> {SpekNotchChange 0 0}
			bind $f <Down> {SpekNotchChange 1 0}
			bind $f <Control-Up> {SpekNotchChange 0 1}
			bind $f <Control-Down> {SpekNotchChange 1 1}
			bind $f <Return> {set pr_speknotch 1}
			bind $f <Escape> {set pr_speknotch 0}
			set spekminnotch 0.0
		}
		set pr_speknotch 0
		ScreenCentre $f
		update idletasks
		raise $f
		update idletasks
		My_Grab 0 $f pr_speknotch
		update idletasks
		set finished 0
		while {!$finished} {
			tkwait variable pr_speknotch
			if {$pr_speknotch} {
				set spek_minnotch $spekminnotch
			} else {
				set spek_minnotch 0.0
			}
			break
		}
		My_Release_to_Dialog $f
		Dlg_Dismiss $f
	}
	while {$k < $brrk_curvcnt} {
		if {$apply} {
			wm title .blocker  "PLEASE WAIT:      Inverting curve [expr $k + 1]"
		}
		catch {file delete $fnam1}
		if [catch {open $fnam0 "w"} zit] {
			Inf "Cannot open temporary file for inverting curve [expr $k + 1]"
			incr k
			continue
		}
		set lastfrq -1.0
		set OK 1
		foreach {frq amp} $spek_c($k) {
			if {($frq < 0.0) || ($frq > $evv(SPEKNYQUIST)) || ($frq < $lastfrq) } {
				Inf "Invalid frequency value, or order, for curve [expr $k + 1]"
				set OK 0
				break
			}
			set lastfrq $frq
			if {($amp < 0.0) || ($amp > 1.0)} {
				Inf "Invalid amplitude value for curve [expr $k + 1]"
				set OK 0
				break
			}
			set line [list $frq $amp]
			puts $zit $line
		}
		close $zit
		if {!$OK} {
			incr k
			continue
		}
		set cmd [file join $evv(CDPROGRAM_DIR) notchinvert]
		lappend cmd $fnam0 $fnam1 $speksr $spek_minnotch
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "Notch inversion failed to run for curve [$k + 1]"
			DeleteAllTemporaryFiles
			incr k
			continue
   		} else {
   			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			Inf "Notch inversion failed for curve [$k + 1]"
			DeleteAllTemporaryFiles
			incr k
			continue
		}
		if [catch {open $fnam1 "r"} zit] {
			Inf "Failed to open file $fnam1 of notch inverted data to read it"
			incr k
			continue
		}
		if {!$apply} {
			incr k		;#	 FOR TEST TRANSFORM, CREATE NEW CURVE
		} else {
			catch {unset spek_c($k)}
		}
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			} else {
				set line [split $line]
				catch {unset nuline}
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] <= 0} {
						continue
					}
					lappend spek_c($k) $item		;#	FOR APPLIED TRANSFORM, OVERWRITE ORIG
				}
			}
		}
		close $zit
		if {!$apply} {
			set gotit 1
			break
		}
		incr k
	}
	if {!$apply && [info exists gotit]} {
		incr brrk_curvcnt
		SetupSpekDisplay_c $k						;#	Establish display-coords of points.
		catch {unset line_c}
		foreach {x y} $disppl_c($k) {
			set x [expr $x + $evv(BPWIDTH)]
			set y [expr $y + $evv(BPWIDTH)]
			lappend line_c $x $y
		}
		eval {$bsh(can) create line} $line_c {-fill $brrkcolor($k)} {-tag cline($k)}
		set msg "Are the notch inversions ok ??"
		set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			set spek_c(0) $spek_c(1)
			unset spek_c(1)
			set disppl_c(0) $disppl_c(1)
			unset disppl_c(1)
			SetupSpekDisplay_c 0
			catch {$bsh(can) delete cline(0)} in
			catch {$bsh(can) delete cline(1)} in
			incr brrk_curvcnt -1
			catch {unset line_c}
			foreach {x y} $disppl_c(0) {
				set x [expr $x + $evv(BPWIDTH)]
				set y [expr $y + $evv(BPWIDTH)]
				lappend line_c $x $y
			}
			eval {$bsh(can) create line} $line_c {-fill $brrkcolor(0)} {-tag cline(0)}
			set spk(interpd) 1
			set thistransform [list INVERT $spek_minnotch]
			lappend spektransform $thistransform
		} else {
			unset spek_c(1)
			unset disppl_c(1)
			catch {$bsh(can) delete cline(1)} in
			incr brrk_curvcnt -1
		}
		incr spk(mod)
	}
	if {$apply} {
		set spk(inverted) 1
	}
	return 1
}

proc SpekNotchChange {down fast} {
	global spekminnotch
	if {$down} {
		if {$spekminnotch > 0.0} {
			if {$fast} {
				set spekminnotch [expr $spekminnotch - 0.01]
				if {$spekminnotch < 0.0} {
					set spekminnotch 0.000
				}
			} else {
				set spekminnotch [expr $spekminnotch - 0.001]
			}
		}
	} else {
		if {$spekminnotch < 1.0} {
			if {$fast} {
				set spekminnotch [expr $spekminnotch + 0.01]
				if {$spekminnotch > 1.0} {
					set spekminnotch 1.000
				}
			} else {
				set spekminnotch [expr $spekminnotch + 0.001]
			}
		}
	}
}

#------ Generate Histogram from peaks or inverted peaks data

proc SpekIsolatePeaks {apply} {
	global brrk_curvcnt	evv CDPidrun prg_dun prg_abortd spek_c wstk
	global disppl_c bsh brrkcolor spektransform spk pr_spekiso
	global readonlyfg readonlybg spekminnotch spek_minnotch

	if {!$apply} { 
		if {$spk(ified)} {
			Inf "Already converted to playable data"
			return 0
		}
		if {$spk(iso)} {
			Inf "Done peak isolation already"
			return 0
		}
	}
	if {[info exists spk(zoom)]} {
		SetSpekZoom 0
	}
	DeleteAllTemporaryFiles
	set fnam0 $evv(DFLT_OUTNAME)
	append fnam0 0 $evv(TEXT_EXT)
	set fnam1 $evv(DFLT_OUTNAME)
	append fnam1 1 $evv(TEXT_EXT)
	if {!$apply} {
		if {[info exists brrk_curvcnt] && ($brrk_curvcnt > 1)} {
			Inf "Only applicable to a single curve"
			return 0
		}
		set k [expr $brrk_curvcnt - 1]
		set j $brrk_curvcnt 
	} else {
		set k 0
	}
	if {![info exists evv(SPEKNYQUIST)]} {
		Inf "Set the sample rate before proceeding"
		return 0
	}
	set speksr [expr $evv(SPEKNYQUIST) * 2]
	if {![info exists spek_c]} {
		Inf "Create data in the spectral range first"
		return 0
	}
	if {!$apply} {
		set f .spekiso
		if [Dlg_Create $f "Isolate spectral peaks" "set pr_spekiso 0" -borderwidth 2] {
			frame $f.0
			button $f.0.set -text "Confirm width" -command "set pr_spekiso 1"  -highlightbackground [option get . background {}]
			button $f.0.qu  -text "Abandon" -command "set pr_spekiso 0"  -highlightbackground [option get . background {}]
			pack $f.0.set -side left		
			pack $f.0.qu -side right
			pack  $f.0 -side top -fill x -expand true
			frame $f.1
			entry $f.1.0 -textvariable spekminnotch -width 16 -fg $readonlyfg -readonlybackground $readonlybg
			label $f.1.1 -text "Minimum notch depth to qualify as peak-separating notch"
			pack $f.1.0 $f.1.1 -side left
			pack  $f.1 -side top -pady 2
			label $f.2 -text "Up/Down (& Control Up/Down) Arrows change width" -fg $evv(SPECIAL)
			pack  $f.2 -side top -pady 2		 
			wm resizable $f 0 0
			bind $f <Up> {SpekNotchChange 0 0}
			bind $f <Down> {SpekNotchChange 1 0}
			bind $f <Control-Up> {SpekNotchChange 0 1}
			bind $f <Control-Down> {SpekNotchChange 1 1}
			bind $f <Return> {set pr_spekiso 1}
			bind $f <Escape> {set pr_spekiso 0}
			set spekminnotch 0.1
		}
		set pr_spekiso 0
		ScreenCentre $f
		update idletasks
		raise $f
		update idletasks
		My_Grab 0 $f pr_spekiso
		update idletasks
		set finished 0
		while {!$finished} {
			tkwait variable pr_spekiso
			if {$pr_spekiso} {
				set spek_minnotch $spekminnotch
			} else {
				set spek_minnotch 0.0
			}
			break
		}
		My_Release_to_Dialog $f
		Dlg_Dismiss $f
	}
	while {$k < $brrk_curvcnt} {
		if {$apply} {
			wm title .blocker  "PLEASE WAIT:      Isolating peaks curve [expr $k + 1]"
		}
		catch {file delete $fnam1}
		if [catch {open $fnam0 "w"} zit] {
			Inf "Cannot open temporary file for isolating peaks of curve [expr $k + 1]"
			incr k
			continue
		}
		set lastfrq -1.0
		set OK 1
		foreach {frq amp} $spek_c($k) {
			if {($frq < 0.0) || ($frq > $evv(SPEKNYQUIST)) || ($frq < $lastfrq) } {
				Inf "Invalid frequency value, or order, for curve [expr $k + 1]"
				set OK 0
				break
			}
			set lastfrq $frq
			if {($amp < 0.0) || ($amp > 1.0)} {
				Inf "Invalid amplitude value for curve [expr $k + 1]"
				set OK 0
				break
			}
			set line [list $frq $amp]
			puts $zit $line
		}
		close $zit
		if {!$OK} {
			incr k
			continue
		}
		set cmd [file join $evv(CDPROGRAM_DIR) peakiso]
		lappend cmd $fnam0 $fnam1 $speksr $spek_minnotch
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "Peak isolation failed to run for curve [$k + 1]"
			DeleteAllTemporaryFiles
			incr k
			continue
   		} else {
   			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			Inf "Peak isolation failed for curve [$k + 1]"
			DeleteAllTemporaryFiles
			incr k
			continue
		}
		if [catch {open $fnam1 "r"} zit] {
			Inf "Failed to open file $fnam1 of peak isolation data to read it"
			incr k
			continue
		}
		if {!$apply} {
			incr k		;#	 FOR TEST TRANSFORM, CREATE NEW CURVE
		} else {
			catch {unset spek_c($k)}
		}
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			} else {
				set line [split $line]
				catch {unset nuline}
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] <= 0} {
						continue
					}
					lappend spek_c($k) $item		;#	FOR APPLIED TRANSFORM, OVERWRITE ORIG
				}
			}
		}
		close $zit
		if {!$apply} {
			set gotit 1
			break
		}
		incr k
	}
	if {!$apply && [info exists gotit]} {
		incr brrk_curvcnt
		SetupSpekDisplay_c $k						;#	Establish display-coords of points.
		catch {unset line_c}
		foreach {x y} $disppl_c($k) {
			set x [expr $x + $evv(BPWIDTH)]
			set y [expr $y + $evv(BPWIDTH)]
			lappend line_c $x $y
		}
		eval {$bsh(can) create line} $line_c {-fill $brrkcolor($k)} {-tag cline($k)}
		set msg "Is the peak isolation ok ??"
		set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			set spek_c(0) $spek_c(1)
			unset spek_c(1)
			set disppl_c(0) $disppl_c(1)
			unset disppl_c(1)
			SetupSpekDisplay_c 0
			catch {$bsh(can) delete cline(0)} in
			catch {$bsh(can) delete cline(1)} in
			incr brrk_curvcnt -1
			catch {unset line_c}
			foreach {x y} $disppl_c(0) {
				set x [expr $x + $evv(BPWIDTH)]
				set y [expr $y + $evv(BPWIDTH)]
				lappend line_c $x $y
			}
			eval {$bsh(can) create line} $line_c {-fill $brrkcolor(0)} {-tag cline(0)}
			set spk(interpd) 1
			set thistransform [list ISOLATE $spek_minnotch]
			lappend spektransform $thistransform
		} else {
			unset spek_c(1)
			unset disppl_c(1)
			catch {$bsh(can) delete cline(1)} in
			incr brrk_curvcnt -1
		}
		incr spk(mod)
	}
	if {$apply} {
		set spk(iso) 1
	}
	return 1
}

#---- extract frq width of peaks found, and store in temp files

proc GenerateSpekPeakWidths {apply} {
	global spek_c spektransform brrk_curvcnt spk evv wstk

	if {!$apply && [info exists spk(pkwid)]} {
		Inf "Already extracted widths"
		return 0
	}
	if {!$spk(interpd)} {
		Inf "Smooth spectrum first"
		return 0
	}
	set last_indx [expr $brrk_curvcnt - 1]
	if {$apply} {
		set k 0
		while {$k < $brrk_curvcnt} {
			wm title .blocker  "PLEASE WAIT:      Extracting peak widths for curve [expr $k + 1]"
			if {![GenSpekPeakWidth $spek_c($k) $k $apply]} {
				return 0
			}
			incr k
		}
	} else {
		if {![GenSpekPeakWidth $spek_c($last_indx) $last_indx $apply]} {
			return 0
		}
		set thistransform [list SPEKWID]
		lappend spektransform $thistransform
		set spk(pkwid) 1
#		if {[info exists evv(TESTING)]} {
#			List_Spectrum
#		}
		Inf "Extracted peak widths"
	}
	return 1
}

proc GenSpekPeakWidth {specc k apply} {
	global evv
	set iszero 1
	foreach {frq amp} $specc {
		if {$iszero} {
			if {$amp > 0.0} {
				set sttfrq $frq
				set endfrq $frq
				set maxamp $amp
				set maxfrq $frq
				set iszero 0
			}
		} else {
			if {$amp > 0.0} {
				set endfrq $frq
				if {$amp > $maxamp} {
					set maxamp $amp
					set maxfrq $frq
				}
			} else {
				set width [expr $endfrq - $sttfrq]
				lappend widths $width
				lappend maxamps $maxamp
				lappend maxfrqs $maxfrq
				set iszero 1
			}
		}
	}
	if {!$iszero} {
		set width [expr $endfrq - $sttfrq]
		lappend widths $width
		lappend maxamps $maxamp
		lappend maxfrqs $maxfrq
	}
	if {[info exists widths]} {
		set maxaspect 0.0
		foreach width $widths amp $maxamps {
			set aspect [expr double($width)/double($evv(SPEKNYQUIST))]
			if {[flteq $aspect 0.0]} {
				set aspect -1
			} else {
				set aspect [expr $amp / $aspect]
			}
			if {$aspect > $maxaspect} {
				set maxaspect $aspect
			}
			lappend aspects $aspect
		}
		set len [llength $aspects]
		set j 0
		while {$j < $len} {
			set aspect [lindex $aspects $j]
			if {$aspect < 0.0} {
				set aspects [lreplace $aspects $j $j $maxaspect]
			}
			incr j
		}
	}
	set fnam $evv(MACH_OUTFNAME)
	append fnam $k $evv(TEXT_EXT)
	catch {file delete $fnam}
	if [catch {open $fnam "w"} zit] {
		Inf "Cannot open file $fnam to write peak widths for curve [expr $k + 1]"
		if {$apply} {
			set j 0
			while {$j < $k} {
				set fnam $evv(MACH_OUTFNAME)
				append fnam $j $evv(TEXT_EXT)
				catch {file delete $fnam}
				incr j
			}
		}
		return 0
	}
	set j 0
	if {[info exists widths]} {
		foreach frq $maxfrqs aspect $aspects {
			set line [list $frq $aspect]
			puts $zit $line
			incr j
		}
	}
	close $zit
	return 1
}

#####################################################
#													#
# APPLYING TRANSFORM SEQUENCE TO ONE OR MANY CURVES #
#													#
#####################################################

proc ApplyDefaultTransform {} {
	global specktr spkul spkdn spkup spkstr spkshft spekflat spekwarp brrk brrk_curvcnt spk wstk evv
	global disppl_c brrkcolor bsh bsh_list spek_c spek_sndharm spek_sndbrite spek_sndgain
	global pr_spekapply speksingle spekapplysnd speksnd_got spekdfltmod spektransform done_spekify
	global spek_sndfrac spek_sndatt spek_sndspred spek_prescale spek_exp_to_zero spek_minnotch
	global spek_sndtype testmaxspek

	if {[info exists spk(zoom)]} {
		SetSpekZoom 0
	}
	catch {unset spk(vary)}
	set spekapplysnd 0
	set firsttrans [lindex $specktr(default) 0]		;#	If starting with spectral data,
	set firstaction [lindex $firsttrans 0]			;#	range has already been converted
	if {[string match $firstaction "RANGE"] && [info exists spk(display)]} {	
		set ampbot  [lindex $firsttrans 1]		
		set amptop  [lindex $firsttrans 2]			;#	 So check range of input spectrum
		set frqbot  [lindex $firsttrans 3]
		set nyquist [lindex $firsttrans 4]
		if {($ampbot != $evv(SPEKAMPBOT)) || ($amptop  != $evv(SPEKAMPTOP)) \
		|| ($frqbot  != $evv(SPEKFRQBOT)) || ($nyquist != $evv(SPEKNYQUIST))} {
			Inf "Spectral data has inappropriate spectra-data ranges\nfor this transform sequence"
			return
		}											;#	Then skip first line (range-changing) of transformation
		set thisspecktr [lrange $specktr(default) 1 end]
	} else {
		set thisspecktr $specktr(default)
	}
	set orig_specktr_default $specktr(default)
	set do_spekification 0
	foreach line $thisspecktr {						;#	Check for sound output, and time-varying output
		set action [lindex $line 0]
		if {[string match $action "VARYSPEK"]} {
			if {$brrk_curvcnt > 1} {
				set spk(vary) 1
			}
		}

		if {[string match $action "SPEKIFY"]} {
			set do_spekification 1
		}
		if {[string match $action "SPEKSND"]} {
			set is_speksnd 1
			set spek_sndharm  [lindex $line 1]
			set spek_sndbrite [lindex $line 2]
			set spek_sndspred [lindex $line 3]
			set spek_sndfrac  [lindex $line 4]
			set spek_sndatt   [lindex $line 5]
			set spek_sndtype  [lindex $line 6]
			set spek_sndgain  [lindex $line 7]
		}
	}
	if {($brrk_curvcnt > 1) && $do_spekification} {
		set multicurvesnd 1
	}
	set spk_skipdraw 0
	if {$brrk_curvcnt > 8} {
		set msg "Skip redrawing curves ?"
		set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			set spk_skipdraw 1
		}
	}
	set spekdfltmod 0
	if {[info exists testmaxspek]} {
		set spekapplysnd 1
		set speksingle 1
	} elseif {[info exists multicurvesnd] || [info exists is_speksnd]} {
		set f .spekapply
		if [Dlg_Create $f "Apply transform sequence" "set pr_spekapply 0" -borderwidth 2 -width 80] {
			frame $f.0
			button $f.0.0 -text "Apply" -command "set pr_spekapply 1"  -highlightbackground [option get . background {}]
			button $f.0.1 -text "Abandon" -command "set pr_spekapply 0"  -highlightbackground [option get . background {}]
			pack $f.0.0 -side left
			pack $f.0.1 -side right
			pack $f.0 -side top -fill x -expand true
			frame $f.1
			radiobutton $f.1.aa -variable spekapplysnd -value 0 -text "No sound" -command "set speksingle -1"
			radiobutton $f.1.bb -variable spekapplysnd -value 1 -text "Generate sound output"
			radiobutton $f.1.cc -variable spekapplysnd -value 2 -text "Modify sound generation"
			pack $f.1.aa $f.1.bb $f.1.cc -side top -pady 2
			pack $f.1 -side top -pady 2 -fill x -expand true
			frame $f.1a -bg $evv(POINT) -height 1
			pack $f.1a -side top -fill x -expand true
			frame $f.2
			radiobutton $f.2.aa -variable speksingle -value 1 -text "Generate single sound using all curves (#)"
			radiobutton $f.2.bb -variable speksingle -value 0 -text "Generate several sounds, one from each curve"
			pack $f.2.aa $f.2.bb -side top -pady 2
			pack $f.2 -side top -pady 2 -fill x -expand true
			wm resizable $f 0 0
			bind $f <Return> {set pr_spekapply 1}
			bind $f <Escape> {set pr_spekapply 0}
		}
		if {[info exists is_speksnd]} {
			$f.1.aa config -text "No sound" -state normal
			$f.1.bb config -text "Generate sound output" -state normal
			$f.1.cc config -text "Modify sound generation" -state normal
			set spekapplysnd 1
		} else {
			$f.1.aa config -text "" -state disabled
			$f.1.bb config -text "" -state disabled
			$f.1.cc config -text "" -state disabled
		}
		set speksingle -1
		if {[info exists multicurvesnd]} {
			$f.2.aa config -text "Generate single sound using all curves (#)" -state normal
			$f.2.bb config -text "Generate several sounds, one from each curve" -state normal
			bind $f <Key-#> {set speksingle 1; set pr_spekapply 1}
		} else {
			$f.2.aa config -text "" -state disabled
			$f.2.bb config -text "" -state disabled
			bind $f <Key-#> {set speksingle 0; set pr_spekapply 1}
		}
		set pr_spekapply 0
		update idletasks
		raise $f
		update idletasks
		My_Grab 0 $f pr_spekapply $f.2
		update idletasks
		set finished 0
		while {!$finished} {
			tkwait variable pr_spekapply
			if {$pr_spekapply} {
				if {[info exists multicurvesnd]} {
					if {$spekapplysnd} {
						switch -- $speksingle {
							0 {												;#	Choose to generate several sounds
								if {[info exists spk(vary)]} {				;#	If default code setup to generate SINGLE VARYsound
									unset spk(vary)							;#	modify it
									set len [llength $specktr(default)]
									set n 0
									while {$n < $len} {
										set line [lindex $specktr(default) $n]
										set action [lindex $line 0]
										if {[string match $action "VARYSPEK"]} {
											set specktr(default) [lreplace $specktr(default) $n $n]
											set spekdfltmod 1
											break
										}
										incr n
									}
								}
							}
							1 {												;#	Choose to generate single sounds
								set spk(vary) 1								;#	Ensure code setup to generate single timeVARIABLE spectrum
								set len [llength $specktr(default)]
								set n 0
								while {$n < $len} {
									set line [lindex $specktr(default) $n]
									set action [lindex $line 0]
									if {[string match $action "VARYSPEK"]} {
										break
									}
									incr n
								}
								if {$n == $len} {
									lappend specktr(default) "VARYSPEK"
									set spekdfltmod 1
								}
							}
							default {
								Inf "Decide on single sound or multiple sound outputs"
								continue
							}
						}
					}
				}
				if {[info exists is_speksnd] && ($spekapplysnd > 1)} {
					set orig_spek_sndharm  $spek_sndharm
					set orig_spek_sndbrite $spek_sndbrite
					set orig_spek_sndspred $spek_sndspred
					set orig_spek_sndfrac  $spek_sndfrac
					set orig_spek_sndatt   $spek_sndatt
					set orig_spek_sndtype  $spek_sndtype
					set orig_spek_sndgain  $spek_sndgain
					GetSpekSndParams									;#	Modify the output sound params
					if {!$speksnd_got} {
						set spek_sndharm  $orig_spek_sndharm			;#	if mod abandoned, reestablish orig params
						set spek_sndbrite $orig_spek_sndbrite
						set spek_sndspred $orig_spek_sndspred
						set spek_sndfrac  $orig_spek_sndfrac
						set spek_sndatt   $orig_spek_sndatt
						set spek_sndtype  $orig_spek_sndtype
						set spek_sndgain  $orig_spek_sndgain
						;# spekapplysnd is also reset in GetSpekSndParams
					} else {											;#	Else, modify the default transform
						set k 0
						foreach line $specktr(default) {						
							set action [lindex $line 0]
							if {[string match $action "SPEKSND"]} {
								set nuline "SPEKSND"
								lappend nuline $spek_sndharm $spek_sndbrite $spek_sndspred $spek_sndfrac $spek_sndatt $spek_sndtype $spek_sndgain 
								set specktr(default) [lreplace $specktr(default) $k $k $nuline]
								set spekdfltmod 1
								break
							}
							incr k
						}
					}
				}
				My_Release_to_Dialog $f						;#	Continue to transform with the settings chosen
				Dlg_Dismiss $f
				set finished 1
			} else {
				My_Release_to_Dialog $f						;#	Abandon applying the default transform
				Dlg_Dismiss $f
				return
			}
		}
	}
	if {$spekapplysnd} {								;#	If sound is being generated	
		foreach line $thisspecktr {						;#	Set up the output soundfile name
			set action [lindex $line 0]
			if {[string match $action "SPEKSND"]} {
				if {![CheckSpekTempFiles]} {
					return
				}
				if {![GetSpekSndName]} {
					return
				}
			}
		}
	}
	set spektransform $specktr(default)
	catch {unset spk(presndset)}
	catch {unset done_spekify}
	Block "Transforming data"
	foreach line $thisspecktr {
		set action [lindex $line 0]
		switch -- $action {
			"RANGE" {
				wm title .blocker  "PLEASE WAIT:      Setting spectral range"
				set evv(SPEKAMPBOT)  [lindex $line 1]
				set evv(SPEKAMPTOP)  [lindex $line 2]
				set evv(SPEKFRQBOT)  [lindex $line 3]
				set evv(SPEKNYQUIST) [lindex $line 4]
				set spek_prescale	 [lindex $line 5]
				set spek_exp_to_zero [lindex $line 6]


				if {![ConvertFromDataToSpectralRange 1]} {
					UnBlock
					return
				}
			}
			"SPLINE" {
				wm title .blocker  "PLEASE WAIT:      SPLINING"
				if {![CubicSplineSmoothing 1]} {
					UnBlock
					return
				}
			}
			"LINEAR" {
				wm title .blocker  "PLEASE WAIT:      INTERPOLATING"
				if {![LinearSmoothing 1]} {
					UnBlock
					return
				}
			}
			"UPPER" {
				wm title .blocker  "PLEASE WAIT:      RESCALING Y AXIS"
				set spkul [lindex $line 1]
				if {![VerticalUpperLimitOfData 1]} {
					UnBlock
					return
				}
			}
			"LIMITS" {
				wm title .blocker  "PLEASE WAIT:      RESCALING X AXIS"
				set spkdn [lindex $line 1]
				set spkup [lindex $line 2]
				if {![SetHorizontalRangeOfData 1]} {
					UnBlock
					return
				}
			}
			"STRETCH" {
				wm title .blocker  "PLEASE WAIT:      STRETCHING X AXIS"
				set spkstr [lindex $line 1]
				if {![ExpandContractHorizontalRange 1]} {
					UnBlock
					return
				}
			}
			"SHIFT" {
				wm title .blocker  "PLEASE WAIT:      SHIFTING X AXIS"
				set spkshft [lindex $line 1]
				if {![ShiftHorizontalDataRange 1]} {
					UnBlock
					return
				}
			}
			"FLAT" {
				wm title .blocker  "PLEASE WAIT:      WARPING Y AXIS"
				set spekflat [lindex $line 1]
				if {![ExaggerateFlattenVerticalDisplay 1]} {
					UnBlock
					return
				}
			}
			"WARP" {
				wm title .blocker  "PLEASE WAIT:      WARPING X AXIS"
				set spekwarp [lindex $line 1]
				if {![WarpHorizontalDisplay 1]} {
					UnBlock
					return
				}
			}
			"INVERT" {
				wm title .blocker  "PLEASE WAIT:      INVERTING NOTCHES"
				set spek_minnotch [lindex $line 1]
				if {![SpekInvertNotches 1]} {
					UnBlock
					return
				}
			}
			"ISOLATE" {
				wm title .blocker  "PLEASE WAIT:      ISOLATING PEAKS"
				set spek_minnotch [lindex $line 1]
				if {![SpekIsolatePeaks 1]} {
					UnBlock
					return
				}
			}
			"SPEKWID" {
				wm title .blocker  "PLEASE WAIT:      EXTRACTING PEAK WIDTHS"
				if {![GenerateSpekPeakWidths 1]} {
					UnBlock
					return
				}
				set done_spekify 1
			}
			"SPEKIFY" {
				if {$spekapplysnd} {
					wm title .blocker  "PLEASE WAIT:      CONVERTING TO PLAYABLE DATA"
					if {![GenerateSpektra 1]} {
						UnBlock
						return
					}
					set done_spekify 1
				}
			}
		}
	}
	set spk(display) 1
	ClearBrrkDisplay $brrk_curvcnt 1
	EstablishCoordsOnGrafDisplay
	set k 0
	if {$spk_skipdraw == 0} {
		while {$k < $brrk_curvcnt} {
			wm title .blocker  "PLEASE WAIT:      Drawing transformed curve [expr $k + 1]"
			catch {unset line_c}
			SetupSpekDisplay_c $k
			foreach {x y} $disppl_c($k) {
				set x [expr $x + $evv(BPWIDTH)]
				set y [expr $y + $evv(BPWIDTH)]
				lappend line_c $x $y
			}
			eval {$bsh(can) create line} $line_c {-fill $brrkcolor($k)} {-tag cline($k)}
			incr k
		}
		set last_indx [expr $k - 1]
		$bsh_list delete 0 end
		foreach {frq amp} $spek_c($last_indx) {
			set vals [list $frq $amp]
			$bsh_list insert end $vals
		}
		.show_brkfile2.btns9.data.ll config -text "Spectrum from curve $brrk_curvcnt" -fg $brrkcolor($last_indx)
	}
	if {$spekapplysnd} {
		wm title .blocker  "PLEASE WAIT:      Converting to sound"
		if {![CreateFixedSpectrumSound 1]} {
			UnBlock
			return
		}
	}
	UnBlock
	if {$spekdfltmod} {
		set msg "You have modified the default transform sequence\n\nSave this as a named transform sequence ?"
		set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			SaveAndNameCurrentTransform $evv(SPEKT_APPLY)
			set msg "Restore the original transform sequence as the default ?"
			set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
			if {$choice == "yes"} {
				set specktr(default) $orig_specktr_default
				Inf "Restored"
			}
		}
		set spekdfltmod 0
	}
	if {$spekapplysnd} {
		set spk(presndset) $spektransform
		SpekTransseqToPresound	;#	Allows different sound type to be applied to existing data
	}
	return
}

#------ Get a specific transform to apply (or delete a specific named transform)

proc GetANamedTransform {del} {
	global spektransform specktr pr_spektlist spektlist evv spfix keep_orig_spfix wstk
	if {![info exists specktr]} {
		Inf "No transform sequences have been created"
		return
	}
	foreach nam [array names specktr] {
		if {![string match $nam "default"]} {
			lappend nams $nam
		}
	}
	set nams [lsort -ascii $nams]
	if {![info exists nams]} {
		Inf "Only the default transform sequence exists"
		return
	}
	set f .spektlist
	if [Dlg_Create $f "Load named transform sequence" "set pr_spektlist 0" -borderwidth 2 -width 80] {
		frame $f.0
		button $f.0.ok -text "Load Selected" -command "set pr_spektlist 1" -width 16  -highlightbackground [option get . background {}]
		button $f.0.vu -text "View (Dbl Clk)"  -command "set pr_spektlist 2" -width 16  -highlightbackground [option get . background {}]
		button $f.0.md -text "Keep Modified Transform"  -command "set pr_spektlist 3" -width 24  -highlightbackground [option get . background {}]
		button $f.0.qq -text "Quit" -command "set pr_spektlist 0" -width 7  -highlightbackground [option get . background {}]
		pack $f.0.ok $f.0.vu $f.0.md -side left -padx 2
		pack $f.0.qq -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		frame $f.1.1
		label $f.1.1.tt -text "Select transformation from list" -fg $evv(SPECIAL)
		set spektlist [Scrolled_Listbox $f.1.1.ll -width 64 -height 32 -selectmode single]
		pack $f.1.1.tt $f.1.1.ll -side top
		pack $f.1.1 -side top
		frame $f.1.2
		label $f.1.2.range -text "Range" -fg $evv(SPECIAL)
		frame $f.1.2.scl
		label $f.1.2.scl.ll -text "data scaling"
		entry $f.1.2.scl.e  -textvariable spfix(scaling) -width 4
		checkbutton $f.1.2.ch -text "Expand range to zero" -variable spfix(exp)
		set spfix(exp) 0
		pack $f.1.2.scl.e $f.1.2.scl.ll -side left -fill x
		label $f.1.2.peaks -text "Peaks" -fg $evv(SPECIAL)
		frame $f.1.2.rrr
		radiobutton $f.1.2.rrr.r0 -text "no change" -variable spfix(pkstate) -value 0
		radiobutton $f.1.2.rrr.r1 -text "got peaks" -variable spfix(pkstate) -value 1
		radiobutton $f.1.2.rrr.r2 -text "inverted"  -variable spfix(pkstate) -value -1
		set spfix(pkstate) 0
		pack $f.1.2.rrr.r0 $f.1.2.rrr.r1 $f.1.2.rrr.r2 -side left -fill x
		frame $f.1.2.not
		label $f.1.2.not.nl -text "peak notch"
		entry $f.1.2.not.ne -textvariable spfix(notch) -width 4
		pack $f.1.2.not.ne $f.1.2.not.nl -side left -fill x
		label $f.1.2.sndp -text "Sound params" -fg $evv(SPECIAL)
		frame $f.1.2.hrm
		label $f.1.2.hrm.hl -text "no of harmonics"
		entry $f.1.2.hrm.he -textvariable spfix(harms) -width 4
		pack $f.1.2.hrm.he $f.1.2.hrm.hl -side left -fill x
		frame $f.1.2.bri
		label $f.1.2.bri.bl -text "brightness"
		entry $f.1.2.bri.be -textvariable spfix(brite) -width 4
		pack $f.1.2.bri.be $f.1.2.bri.bl -side left -fill x
		frame $f.1.2.spr
		label $f.1.2.spr.sl -text "peak frq-spread"
		entry $f.1.2.spr.se -textvariable spfix(pksprd) -width 4
		pack $f.1.2.spr.se $f.1.2.spr.sl -side left -fill x
		frame $f.1.2.low
		label $f.1.2.low.ll -text "background lowered"
		entry $f.1.2.low.le -textvariable spfix(frcbak) -width 4
		pack $f.1.2.low.le $f.1.2.low.ll -side left -fill x
		frame $f.1.2.att
		label $f.1.2.att.al -text "background max attenuation"
		entry $f.1.2.att.ae -textvariable spfix(attbak) -width 4
		pack $f.1.2.att.ae $f.1.2.att.al -side left -fill x
		frame $f.1.2.ogn
		label $f.1.2.bl -text "------- Peak Brightness Control -------"
		radiobutton $f.1.2.br1 -text "fixed"						  -variable spfix(type) -value 0
		radiobutton $f.1.2.br2 -text "narrow=bright"				  -variable spfix(type) -value 1
		radiobutton $f.1.2.br3 -text "frq varies"					  -variable spfix(type) -value 2
		radiobutton $f.1.2.br4 -text "frq+harms vary"				  -variable spfix(type) -value 3
		radiobutton $f.1.2.br5 -text "narrow=bright + frq varies"     -variable spfix(type) -value 4
		radiobutton $f.1.2.br6 -text "narrow=bright + frq+harms vary" -variable spfix(type) -value 5
		set spfix(type) -1
		label $f.1.2.ogn.gl -text "overall gain"
		entry $f.1.2.ogn.ge -textvariable spfix(gain) -width 4
		pack $f.1.2.ogn.ge $f.1.2.ogn.gl -side left -fill x
		pack $f.1.2.range -side top
		pack $f.1.2.scl $f.1.2.ch -side top -anchor w
		pack $f.1.2.peaks -side top
		pack $f.1.2.rrr $f.1.2.not -side top -anchor w
		pack $f.1.2.sndp -side top
		pack $f.1.2.hrm $f.1.2.bri $f.1.2.spr $f.1.2.low $f.1.2.att -side top -anchor w
		pack $f.1.2.bl -side top
		pack $f.1.2.br1 $f.1.2.br2 $f.1.2.br3 $f.1.2.br4 $f.1.2.br5 $f.1.2.br6 $f.1.2.ogn -side top -anchor w
		button $f.1.2.dum -text ""  -bd 0 -command {}
		button $f.1.2.dum2 -text "" -bd 0 -command {}
		frame $f.1.2.nam
		label $f.1.2.nam.ll -text "New transform name"
		entry $f.1.2.nam.e  -textvariable spfix(nam) -width 20
		pack $f.1.2.nam.ll $f.1.2.nam.e -side left -fill x
		pack $f.1.2.dum $f.1.2.dum2 $f.1.2.nam -side top 
		set spfix(nam) ""
		bind $f.1.1.ll.list <ButtonRelease-1> {SpecTransDisplay %y}
		pack $f.1.1 $f.1.2 -side left
		pack $f.1 -side top
		wm resizable $f 0 0
		bind $f <Return> {set pr_spektlist 1}
		bind $f <Escape> {set pr_spektlist 0}
		bind $f <Double-1> {SeeSpekTranSeq load}
	}
	if {$del} {
		$f.0.md		  config -text ""  -command {} -bd 0
		$f.1.2.range  config -text ""
		$f.1.2.peaks  config -text ""
		$f.1.2.sndp   config -text ""
		$f.1.2.scl.ll config -text ""
		$f.1.2.scl.e  config -bd 0 -state disabled -bg [option get . background {}]
		$f.1.2.ch     config -text "" -state disabled
		$f.1.2.rrr.r0 config -text "" -state disabled
		$f.1.2.rrr.r1 config -text "" -state disabled
		$f.1.2.rrr.r2 config -text "" -state disabled
		$f.1.2.not.nl config -text ""
		$f.1.2.not.ne config -bd 0 -state disabled -bg [option get . background {}]
		$f.1.2.hrm.hl config -text ""
		$f.1.2.hrm.he config -bd 0 -state disabled -bg [option get . background {}]
		$f.1.2.bri.bl config -text ""
		$f.1.2.bri.be config -bd 0 -state disabled -bg [option get . background {}]
		$f.1.2.spr.sl config -text ""
		$f.1.2.spr.se config -bd 0 -state disabled -bg [option get . background {}]
		$f.1.2.low.ll config -text ""
		$f.1.2.low.le config -bd 0 -state disabled -bg [option get . background {}]
		$f.1.2.att.al config -text ""
		$f.1.2.att.ae config -bd 0 -state disabled -bg [option get . background {}]
		$f.1.2.ogn.gl config -text ""
		$f.1.2.ogn.ge config -bd 0 -state disabled -bg [option get . background {}]
		$f.1.2.bl     config -text ""
		$f.1.2.br1    config -text "" -state disabled
		$f.1.2.br2    config -text "" -state disabled
		$f.1.2.br3    config -text "" -state disabled
		$f.1.2.br4    config -text "" -state disabled
		$f.1.2.br5    config -text "" -state disabled
		$f.1.2.br6    config -text "" -state disabled
		$f.1.2.nam.ll config -text ""
		$f.1.2.nam.e  config -bd 0 -state disabled -bg [option get . background {}]
		bind $f.1.1.ll.list <ButtonRelease-1> {}
	} else {
		$f.0.md		  config -text "Keep Modified Transform"  -command "set pr_spektlist 3" -bd 2
		$f.1.2.range  config -text "Range"
		$f.1.2.peaks  config -text "Peaks"
		$f.1.2.sndp   config -text "Sound params"
		$f.1.2.scl.ll config -text "data scaling"
		$f.1.2.scl.e  config -bd 2 -state normal
		$f.1.2.ch     config -text "Expand range to zero" -state normal
		$f.1.2.rrr.r0 config -text "no change" -state normal
		$f.1.2.rrr.r1 config -text "got peaks" -state normal
		$f.1.2.rrr.r2 config -text "inverted"  -state normal
		$f.1.2.not.nl config -text "peak notch"
		$f.1.2.not.ne config -bd 2 -state normal
		$f.1.2.hrm.hl config -text "no of harmonics"
		$f.1.2.hrm.he config -bd 2 -state normal
		$f.1.2.bri.bl config -text "brightness"
		$f.1.2.bri.be config -bd 2 -state normal
		$f.1.2.spr.sl config -text "peak frq-spread"
		$f.1.2.spr.se config -bd 2 -state normal
		$f.1.2.low.ll config -text "background lowered"
		$f.1.2.low.le config -bd 2 -state normal
		$f.1.2.att.al config -text "background max attenuation"
		$f.1.2.att.ae config -bd 2 -state normal
		$f.1.2.ogn.gl config -text "overall gain"
		$f.1.2.ogn.ge config -bd 2 -state normal
		$f.1.2.bl     config -text "------- Peak Brightness Control -------"
		$f.1.2.br1    config -text "fixed"							-state normal
		$f.1.2.br2    config -text "narrow=bright"					-state normal
		$f.1.2.br3    config -text "frq varies"					    -state normal
		$f.1.2.br4    config -text "frq+harms vary"				    -state normal
		$f.1.2.br5    config -text "narrow=bright + frq varies"	    -state normal
		$f.1.2.br6    config -text "narrow=bright + frq+harms vary" -state normal
		$f.1.2.nam.ll config -text "New transform name"
		$f.1.2.nam.e  config -bd 2 -state normal
		bind $f.1.1.ll.list <ButtonRelease-1> {SpecTransDisplay %y}
	}
	set spfix(scaling) ""
	set spfix(exp)     0
	set spfix(pkstate) 0
	set spfix(notch)  ""
	set spfix(harms)  ""
	set spfix(brite)  ""
	set spfix(pksprd) ""
	set spfix(frcbak) ""
	set spfix(attbak) ""
	set spfix(type) -1
	set spfix(gain)   ""
	set spfix(nam) ""
	catch {unset spfix(selected)}
	$spektlist delete 0 end
	if {$del} {
		wm title $f "Delete named transform sequence"
		$f.0.ok config -text "Delete Selected" -command "set pr_spektlist 4"
	} else {
		wm title $f "Load named transform sequence"
		$f.0.ok config -text "Load Selected" -command "set pr_spektlist 1"
		set nams [concat "default" $nams]
	}
	foreach nam $nams {
		$spektlist insert end $nam
	}
	set pr_spektlist 0
	update idletasks
	raise $f
	My_Grab 0 $f pr_spektlist $f.1.1.tt
	set finished 0
	while {!$finished} {
		tkwait variable pr_spektlist
		if {!$pr_spektlist} {
			break
		}
		switch -- $pr_spektlist {
			1 {
				catch {unset keep_orig_spfix}
				set i [$spektlist curselection]
				if {$i < 0} {
					Inf "No item selected"
					continue
				}
				set nam [$spektlist get $i]
				set spektransform $specktr($nam)
				set specktr(default) $specktr($nam)
				set finished 1
			}
			2 {
				catch {unset keep_orig_spfix}
				set i [$spektlist curselection]
				if {$i < 0} {
					Inf "No item selected"
					continue
				}
				SeeSpekTranSeq load
			}
			3 {
				set i [$spektlist curselection]
				if {$i < 0} {
					Inf "Reselect source item"
					set keep_orig_spfix 1
					continue
				}
				if {[CreateNewSpecTransForm]} {
					catch {unset keep_orig_spfix}
				}
			}
			4 {
				set i [$spektlist curselection]
				if {$i < 0} {
					Inf "No item selected"
					continue
				}
				set nam [$spektlist get $i]
				set msg "Are you sure you want to ~~destroy~~ transform sequence $nam ??"
				set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					return
				}
				set scidir [file join $evv(URES_DIR) science]
				set fnam [file join $scidir "sci_"]
				append fnam $nam $evv(CDP_EXT)
				if [catch {file delete $fnam} zit] {
					Inf "Cannot remove this transform sequence"
					return
				}
				unset specktr($nam)
				$spektlist delete $i
				Inf "Transform sequence $nam destroyed"
			}
			0 {
				set finished 1
			}
		}
	}		
	My_Release_to_Dialog $f
	destroy $f
}

proc SpecTransDisplay {y} {
	global spektlist specktr spfix keep_orig_spfix
	if {[info exists keep_orig_spfix]} {
		return
	}
	set i [$spektlist nearest $y]
	if {$i < 0} {
		return
	}
	set tt [$spektlist get $i]

	if {![info exists specktr($tt)]} {
		Inf "Transform $tt does not exist"
		return
	}
	if {$tt == "default"} {
		set k 0
		foreach item [$spektlist get 0 end] {
			if {$item != "default"} {
				if {[SameTransformSequence $specktr($item) $specktr(default)]} {
					set tt $item
					$spektlist selection clear 0 end
					$spektlist selection set $k
					if {$k >= 32} {
						set k [expr double($k) / double([$spektlist index end])]
						$spektlist yview moveto $k
					}
					break
				}
			}
			incr k
		}
	}
	set spfix(scaling) ""
	set spfix(exp)     0
	set spfix(pkstate) 0
	set spfix(notch)  ""
	set spfix(harms)  ""
	set spfix(brite)  ""
	set spfix(pksprd) ""
	set spfix(frcbak) ""
	set spfix(attbak) ""
	set spfix(type) -1
	set spfix(gain)   ""
		
	foreach line $specktr($tt) {
		set action [lindex $line 0]
		switch -- $action {
			"RANGE" {
				set spfix(scaling) [lindex $line 5]
				set spfix(exp)	   [lindex $line 6]
			}
			"INVERT" {
				set spfix(pkstate) -1
				set spfix(notch)   [lindex $line 1]
			}
			"ISOLATE" {
				set spfix(pkstate) 1
				set spfix(notch)   [lindex $line 1]
			}
			"SPEKSND" {
				set spfix(harms)  [lindex $line 1]
				set spfix(brite)  [lindex $line 2]
				set spfix(pksprd) [lindex $line 3]
				set spfix(frcbak) [lindex $line 4]
				set spfix(attbak) [lindex $line 5]
				set spfix(type)   [lindex $line 6]
				set spfix(gain)   [lindex $line 7]
			}
		}
	}
	set spfix(nam) $tt
	set spfix(selected) $tt
}

proc CreateNewSpecTransForm {} {
	global spfix specktr spektlist wstk

	if {([string length $spfix(scaling)] <= 0) || ![IsNumeric $spfix(scaling)] ||($spfix(scaling) < -50000) || ($spfix(scaling) > 50000)} {
		Inf "No new (valid) data scaling information"
		return 0
	}
	if {([string length $spfix(notch)] <= 0) || ![IsNumeric $spfix(notch)] ||($spfix(notch) < -50000) || ($spfix(notch) > 50000)} {
		Inf "No new (valid) data scaling information"
		return 0
	}
	if {([string length $spfix(harms)] <= 0) || ![IsNumeric $spfix(harms)] ||($spfix(harms) < 1) || ($spfix(harms) > 64)} {
		Inf "No new (valid) no of harmonics (1-64)"
		return 0
	}
	if {([string length $spfix(brite)] <= 0) || ![IsNumeric $spfix(brite)] ||($spfix(brite) <= 0) || ($spfix(brite) > 1)} {
		Inf "No new (valid) brightness (range >0-1)"
		return 0
	}
	if {([string length $spfix(pksprd)] <= 0) || ![IsNumeric $spfix(pksprd)] ||($spfix(pksprd) < 0) || ($spfix(pksprd) > 0.1)} {
		Inf "No new (valid)	peak frq-spread (range 0 - 0.1)"
		return 0
	}
	if {([string length $spfix(frcbak)] <= 0) || ![IsNumeric $spfix(frcbak)] ||($spfix(frcbak) < 0) || ($spfix(frcbak) > 1)} {
		Inf "No new (valid) background lowering (range 0-1)"
		return 0
	}
	if {([string length $spfix(attbak)] <= 0) || ![IsNumeric $spfix(attbak)] ||($spfix(attbak) < 0) || ($spfix(attbak) > 1)} {
		Inf "No new (valid) background attenuation (range 0-1)"
		return 0
	}
	if {$spfix(type) < 0} {
		Inf "No new peak brightness control"
		return 0
	}
	if {([string length $spfix(gain)] <= 0) || ![IsNumeric $spfix(gain)] ||($spfix(gain) <= 0) || ($spfix(gain) > 1.0)} {
		Inf "No new (valid) overall gain information (range >0-1)"
		return 0
	}
	if {([string length $spfix(nam)] <= 0) || ![ValidCDPRootname $spfix(nam)]} {
		Inf "No (valid) name given for new transform"
		return 0
	}
	set spfix(nam) [string tolower $spfix(nam)]
	set got 0
	foreach nam [array names specktr] {
		if {[string match $nam $spfix(nam)]} {
			set msg "New transform name already in use: overwrite existing transform ??"
			set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				return 0
			} else {
				set specktr(#new) $specktr($spfix(selected))
				set got 1
				unset specktr($spfix(nam))
				set k [LstIndx $spfix(nam) $spektlist]
				if {$k >= 0} {
					$spektlist delete $k
				}
				break
			}
		}
	}
	if {!$got} {
		set specktr(#new) $specktr($spfix(selected))
	}
	
	set len [llength $specktr(#new)]			;#	deal first with INVERT & ISOLATE
	set n 0
	set done 0
	while {$n < $len} { 	
		set line [lindex $specktr(#new) $n]
		set action [lindex $line 0]
		switch -- $action {
			"INVERT" {
				if {$spfix(pkstate) == 1} {
					set line [list "ISOLATE" $spfix(notch)]
					set specktr(#new) [lreplace $specktr(#new) $n $n $line]
				} elseif {$spfix(pkstate) == 0} {
					set specktr(#new) [lreplace $specktr(#new) $n $n]
				}
				set done 1
			}
			"ISOLATE" {
				if {$spfix(pkstate) == -1} {
					set line [list "INVERT" $spfix(notch)]
					set specktr(#new) [lreplace $specktr(#new) $n $n $line]
				} elseif {$spfix(pkstate) == 0} {
					set specktr(#new) [lreplace $specktr(#new) $n $n]
				}
				set done 1
			}
		}
		incr n
	}
	if {($spfix(pkstate) != 0) && !$done} {
		set n 0
		while {$n < $len} {
			set line [lindex $specktr(#new) $n]
			set action [lindex $line 0]
			switch -- $action {
				"LINEAR" -
				"SPLINE" {
					if {$spfix(pkstate) == 1} {
						set line [list "ISOLATE" $spfix(notch)]
					} else {
						set line [list "INVERT" $spfix(notch)]
					}
					incr n
					set specktr(#new) [linsert $specktr(#new) $n $n $line]
					incr len
					break
				}
			}
			incr n
		}
	}
	set n 0
	while {$n < $len} { 	
		set line [lindex $specktr(#new) $n]
		set action [lindex $line 0]
		switch -- $action {
			"RANGE" {
				set line [lreplace $line 5 5 $spfix(scaling)]
				set line [lreplace $line 6 6 $spfix(exp)]
				set specktr(#new) [lreplace $specktr(#new) $n $n $line]
			}
			"SPEKSND" {
				set line [lreplace $line 1 1 $spfix(harms) ]
				set line [lreplace $line 2 2 $spfix(brite) ]
				set line [lreplace $line 3 3 $spfix(pksprd)]
				set line [lreplace $line 4 4 $spfix(frcbak)]
				set line [lreplace $line 5 5 $spfix(attbak)]
				set line [lreplace $line 6 6 $spfix(type)  ]
				set line [lreplace $line 7 7 $spfix(gain)  ]
				set specktr(#new) [lreplace $specktr(#new) $n $n $line]
			}
		}
		incr n
	}
	foreach nam [array names specktr] {
		if {($nam != "#new") && ($nam != "default")} {
			if {[SameTransformSequence $specktr(#new) $specktr($nam)]} {
				Inf "This transform already exists ($nam)"
				unset specktr(#new)
				return 0
			}
		}
	}
	set msg [lindex $specktr(#new) 0]
	foreach line [lrange $specktr(#new) 1 end] {
		append msg "\n$line"
	}
	append msg "\n\nNew transform ok ??"
	set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
	if {$choice == "no"} {
		unset specktr(#new)
		return 0
	}
	set specktr($spfix(nam)) $specktr(#new)
	unset specktr(#new)
	$spektlist insert end $spfix(nam)
	$spektlist selection clear 0 end
	set k [LstIndx $spfix(nam) $spektlist]
	$spektlist selection set $k
	if {$k >= 32} {
		set k [expr double($k) / double([$spektlist index end])]
		$spektlist yview moveto $k
	}
	return 1
}

#--- Modify output level of a loaded transform

proc ModifyTransformLevel {} {
	global specktr pr_sptrlev sptrlevnu spk evv
	if {![info exists specktr(default)]} {
		Inf "No default transform established"
		return
	}
	foreach line $specktr(default) {				;#	Find existing sound output level
		set action [lindex $line 0]
		if {[string match $action "SPEKSND"]} {
			set sptrlevnu [lindex $line 7]
			break
		}
	}
	set f .sptrlev
	if [Dlg_Create $f "Modify transform level" "set pr_sptrlev 0" -borderwidth 2] {
		frame $f.0
		button $f.0.set -text "Change Level" -command "set pr_sptrlev 1"  -highlightbackground [option get . background {}]
		button $f.0.qu  -text "Abandon" -command "set pr_sptrlev 0"  -highlightbackground [option get . background {}]
		pack $f.0.set -side left		
		pack $f.0.qu -side right
		pack  $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Level (Range >0 - 1) "
		entry $f.1.e  -textvariable  "sptrlevnu" -width 4
		pack $f.1.ll $f.1.e -side right
		pack  $f.1 -side top
		wm resizable $f 0 0
		bind $f <Return> {set pr_sptrlev 1}
		bind $f <Escape> {set pr_sptrlev 0}
	}
	set pr_sptrlev 0
	ScreenCentre $f
	update idletasks
	raise $f
	update idletasks
	My_Grab 0 $f pr_sptrlev $f.1.e
	update idletasks
	set finished 0
	while {!$finished} {
		tkwait variable pr_sptrlev
		if {$pr_sptrlev} {
			if {[string length $sptrlevnu] <= 0} {
				Inf "No level value entered"
				continue
			}
			if {![IsNumeric $sptrlevnu] || ($sptrlevnu <= 0.0) || ($sptrlevnu > 1.0)} {
				Inf "Invalid level value entered"
				continue
			}
			foreach nam [array names specktr] {
				if {![string match $nam "default"]} {
					if {[SameTransformSequence $specktr($nam) $specktr(default)]} {
						set thisone $nam
						break
					}
				}
			}
			set len [llength $specktr(default)]
			set n 0
			while {$n < $len} {
				set line [lindex $specktr(default) $n]
				set action [lindex $line 0]
				if {[string match $action "SPEKSND"]} {
					set line [lreplace $line 7 7 $sptrlevnu]
					set specktr(default)  [lreplace $specktr(default) $n $n $line]

					set scidir [file join $evv(URES_DIR) science]
					set fnam [file join $scidir "sci_"]
					append fnam default $evv(CDP_EXT)
					if [catch {file delete $fnam} zit] {
						Inf "Cannot alter the stored default transform"
					}
					if [catch {open $fnam "w"} zit] {
						Inf "Cannot store the changed default transform"
					} else {
						foreach line $specktr(default) {
							puts $zit $line
						}
					}
					close $zit
					if {[info exists thisone]} {
						set specktr($thisone) [lreplace $specktr($thisone) $n $n $line]
						set fnam [file join $scidir "sci_"]
						append fnam $thisone $evv(CDP_EXT)
						if [catch {file delete $fnam} zit] {
							Inf "Cannot alter the stored transform"
						}
						if [catch {open $fnam "w"} zit] {
							Inf "Cannot store the changed transform"
						} else {
							foreach line $specktr($thisone) {
								puts $zit $line
							}
						}
						close $zit
					}
					break
				}
				incr n
			}
			set spk(interpd) 0 ;# Allows application to run again
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- The transform currently being created is set as the currently active default transform.

proc SetCurrentTransformAsDefault {frommenu} {
	global specktr spektransform spk wstk
	if {$frommenu && ![info exists spk(snd_created)]} {
		Inf "Generate the sound first"
	}
	if {[info exists specktr(default)]} {
		set msg "Replace existing default transform sequence ?"
		set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		}
	}
	set specktr(default) $spektransform
}

#--- Test latest transform to see if it is unique

proc UniqueSpektransform {} {
	global spektransform specktr speksame spekdfltmod
	set skipdefault 0
	if {[info exists spekdfltmod] && $spekdfltmod} {
		set skipdefault 1
	}
	if {[info exists specktr]} {
		foreach nam [array names specktr] {
			if {[string match $nam "default"] && $skipdefault} {
				continue
			}
			set is_match 0
			if {[llength $specktr($nam)] == [llength $spektransform]} {
				foreach t $specktr($nam) nt $spektransform {
					if {[llength $t] == [llength $nt]} {
						set is_match 1
						foreach i_t $t i_nt $nt {
							if {![string match $i_t $i_nt]} {
								set is_match 0
								break
							}
						}
						if {!$is_match} {
							break
						}
					}
				}
			}
			if {$is_match} {
				set speksame $nam
				return 0
			}
		}
	}
	return 1
}

proc SameTransformSequence {spektr1 spektr2} {
	if {[llength $spektr1] != [llength $spektr2]} {
		return 0
	}
	foreach i_t $spektr1 i_nt $spektr2 {
		if {![string match $i_t $i_nt]} {
			return 0
		}
	}
	return 1
}

#---- On quitting data-display, check if transform in use has been saved

proc CheckTransformStatus {end} {
	global spektransform last_spektransform spekdfltmod wstk spk evv
	if {![info exists spk(display)]} {
		return
	}
	if {[info exists spk(tsaved)]} {
		unset spk(tsaved)
		return
	}
	if {[info exists spk(presndset)]} {
		set spektransform $spk(presndset)
	}
	if {[info exists spk(snd_created)] && [info exists spektransform] && [UniqueSpektransform]} {
		set msg "You have used a transform sequence that has not been saved: Save it ?"
		set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			if {$end} {
				SaveAndNameCurrentTransform $evv(SPEKT_QUIT)
			} else {
				SaveAndNameCurrentTransform $evv(SPEKT_APPLY)
			}
			set msg "Do you want this transform sequence to be the default ?"
			set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
			if {$choice == "yes"} {
				SetCurrentTransformAsDefault 0
			}
			set spekdfltmod 0
		}
		if {$end} {
			catch {unset last_spektransform}
			catch {unset spk(presndset)}
			catch {unset spektransform}
		} elseif {[info exists spektransform]} {
			set last_spektransform $spektransform
		}
	}
}

########################################################
#													   #
# CONVERSION BETWEEN DATA (SPECTRA) AND DISPLAY COORDS #
#													   #
########################################################

#------ Establish Constants used to Convert Graf points to Real value-pairs

proc EstablishGrafToRealConversionConstantsBrrk {} {
	EstablishGrafToRealConversionConstantsBrrk_x
	EstablishGrafToRealConversionConstantsBrrk_y
}

#------ Establish Constants used to Convert Graf time values to Real time values

proc EstablishGrafToRealConversionConstantsBrrk_x {} {
	global brrk spek spk evv

	#	CONVERT FROM GRAF ACTIVE X-RANGE TO REAL TIME RANGE AND VICE VERSA
	if {[info exists spk(display)]} {
		set brrk(xvaltograf) [expr double($evv(XWIDTH)) / double($spek(real_endfreq) - $spek(real_startfreq))] 
	} else  {
		set brrk(xvaltograf) [expr double($evv(XWIDTH)) / double($brrk(real_endfreq) - $brrk(real_startfreq))] 
	}
}	

#------ Establish Constants used to Convert Graf values to Real values

proc EstablishGrafToRealConversionConstantsBrrk_y {} {
	global brrk spek evv spk
	if {[info exists spk(display)]} {
		set brrk(yvaltograf) [expr double($evv(YHEIGHT)) / $spek(range)]	;#	Scale from real value range to graf y-range
	} else {
		set brrk(yvaltograf) [expr double($evv(YHEIGHT)) / $brrk(range)]	;#	Scale from real value range to graf y-range
	}
}	

###################################################
#												  #
# SETTING BASIC CONSTANTS FOR CONVERSION TO SOUND #
#												  #
###################################################

proc SetSpekSamprate {} {
	global pr_speksr wstk evv speksr
	set f .speksr
	if {![info exists evv(SPEKNYQUIST)]} {
		set speksr 0
	} else {
		set speksr [expr $evv(SPEKNYQUIST) * 2]
	}
	if [Dlg_Create $f "Specify sample rate" "set pr_speksr 0" -borderwidth 2] {
		frame $f.0
		button $f.0.set -text "Confirm Srate" -command "set pr_speksr 1"  -highlightbackground [option get . background {}]
		button $f.0.qu  -text "Quit" -command "set pr_speksr 0"  -highlightbackground [option get . background {}]
		pack $f.0.set -side left		
		pack $f.0.qu -side right
		pack  $f.0 -side top -fill x -expand true
		frame $f.1
		radiobutton $f.1.0 -variable speksr -text "44100" -value 44100
		radiobutton $f.1.1 -variable speksr -text "48000" -value 48000
		radiobutton $f.1.2 -variable speksr -text "96000" -value 96000
		pack $f.1.0 $f.1.1 $f.1.2 -side left
		pack  $f.1 -side top
		wm resizable $f 0 0
		bind $f <Return> {set pr_speksr 1}
		bind $f <Escape> {set pr_speksr 0}
	}
	set pr_speksr 0
	ScreenCentre $f
	update idletasks
	raise $f
	update idletasks
	My_Grab 0 $f pr_speksr
	update idletasks
	set finished 0
	while {!$finished} {
		tkwait variable pr_speksr
		if {$speksr == 0} {
			set msg "No sample rate set: no spectral transforms or sound output possible: ok ?"
			set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				continue
			}
			set finished 1
		} else {
			set evv(SPEKNYQUIST) [expr $speksr/2]
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc SetSpekChancnt {} {
	global pr_spekch wstk spekch evv
	set f .spekch
	if {![info exists evv(ANALPOINTS)]} {
		set spekch 0
	} else {
		set spekch [expr $evv(ANALPOINTS)/2]
	}
	if [Dlg_Create $f "Specify spectral channel count" "set pr_spekch 0" -borderwidth 2] {
		frame $f.0
		button $f.0.set -text "Confirm Channels" -command "set pr_spekch 1"  -highlightbackground [option get . background {}]
		button $f.0.qu  -text "Quit" -command "set pr_spekch 0"  -highlightbackground [option get . background {}]
		pack $f.0.set -side left		
		pack $f.0.qu -side right
		pack  $f.0 -side top -fill x -expand true
		frame $f.1
		radiobutton $f.1.0 -variable spekch -text "256"  -value 256
		radiobutton $f.1.1 -variable spekch -text "512"  -value 512
		radiobutton $f.1.2 -variable spekch -text "1024" -value 1024
		radiobutton $f.1.3 -variable spekch -text "2048" -value 2048
		radiobutton $f.1.4 -variable spekch -text "4096" -value 4096
		radiobutton $f.1.5 -variable spekch -text "8192"  -value 8192
		pack $f.1.0 $f.1.1 $f.1.2 $f.1.3 $f.1.4 $f.1.5 -side left
		pack  $f.1 -side top
		wm resizable $f 0 0
		bind $f <Return> {set pr_spekch 1}
		bind $f <Escape> {set pr_spekch 0}
	}
	set pr_spekch 0
	ScreenCentre $f
	update idletasks
	raise $f
	update idletasks
	My_Grab 0 $f pr_spekch
	update idletasks
	set finished 0
	while {!$finished} {
		tkwait variable pr_spekch
		if {$spekch == 0} {
			set msg "No channel count set: no sound output possible: ok ?"
			set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				continue
			}
			set finished 1
		} else {
			set evv(ANALPOINTS) [expr $spekch * 2]
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc SetSpekDuration {} {
	global pr_spekdur wstk spekdur varispekdur evv
	set f .spekdur
	if {![info exists evv(SPEKDUR)]} {
		set spekdur ""
	} else {
		set spekdur $evv(SPEKDUR)
	}
	if {![info exists evv(VARISPEKDUR)]} {
		set varispekdur ""
	} else {
		set varispekdur $evv(VARISPEKDUR)
	}
	if [Dlg_Create $f "Specify output sound duration" "set pr_spekdur 0" -borderwidth 2] {
		frame $f.0
		button $f.0.set -text "Confirm New Duration" -command "set pr_spekdur 1"  -highlightbackground [option get . background {}]
		button $f.0.qu  -text "Quit" -command "set pr_spekdur 0"  -highlightbackground [option get . background {}]
		pack $f.0.set -side left		
		pack $f.0.qu -side right
		pack  $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.0 -text "duration of fixed spectra"
		entry $f.1.e -textvariable spekdur -width 8
		pack $f.1.e $f.1.0 -side left
		frame $f.2
		label $f.2.0 -text "duration of time-changing spectrum"
		entry $f.2.e -textvariable varispekdur -width 8
		pack $f.2.e $f.2.0 -side left
		pack $f.1 $f.2 -side top -pady 2 -anchor w
		wm resizable $f 0 0
		bind $f <Return> {set pr_spekdur 1}
		bind $f <Escape> {set pr_spekdur 0}
	}
	set pr_spekdur 0
	ScreenCentre $f
	update idletasks
	raise $f
	update idletasks
	My_Grab 0 $f pr_spekdur
	update idletasks
	set finished 0
	while {!$finished} {
		tkwait variable pr_spekdur
		if {![IsNumeric $spekdur] || ($spekdur <= 0.0)} {
			Inf "Invalid fixed-spectrum duration"
			continue
		}
		if {![IsNumeric $varispekdur] || ($varispekdur <= 0.0)} {
			Inf "Invalid varying-sepctrum duration"
			continue
		}
		set evv(SPEKDUR) $spekdur
		set evv(VARISPEKDUR) $varispekdur
		set finished 1
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

######################################################################################################
#																									 #
# SAVING, LOADING AND DELETING NAMED FILES CONTAINING LISTINGS OF DATA OR SPECTRAL FILES FOR DISPLAY #
#																									 #
######################################################################################################

#---- Construct a list of files containing lists of spectra (or data) files, and select one to load

proc LoadNamedSpekDataListingFile {} {
	global pr_spekload spekloadnam readonlybg readonlyfg speklistlist spekloadreturnval evv

	set nameroot "datdata"
	foreach fnam [lsort -dictionary [glob -nocomplain [file join $evv(SPEKDIR) *]]] {
		set fnam [file rootname [file tail $fnam]]
		if {[string length $fnam] > 7} {
			if {[string first $nameroot $fnam] == 0} {
				lappend nametags [string range $fnam 8 end]
			}
		}
	}
	if {![info exists nametags]} {
		Inf "No named data file listings have been saved"
		return 0
	}
	set spekloadnam ""
	set spekloadreturnval 0
	set f .spekload
	if [Dlg_Create $f "Load named list of data files" "set pr_spekload 0" -borderwidth 2 -width 80] {
		frame $f.0
		button $f.0.0 -text "Load Named File" -command "set pr_spekload 1"  -highlightbackground [option get . background {}]
		button $f.0.1 -text "Abandon" -command "set pr_spekload 0"  -highlightbackground [option get . background {}]
		pack $f.0.0 -side left
		pack $f.0.1 -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.1 -text "Listing Name "
		entry $f.1.2 -textvariable spekloadnam -width 24 -fg $readonlyfg -readonlybackground $readonlybg -state readonly
		pack $f.1.1 $f.1.2 -side left
		pack $f.1 -side top -pady 2
		frame $f.2
		label $f.2.tit -text "Select named data listing with mouse" -fg $evv(SPECIAL)
		set speklistlist [Scrolled_Listbox $f.2.ll -width 64 -height 32 -selectmode single]
		pack $f.2.tit $f.2.ll -side top -pady 2
		pack $f.2 -side top -fill both
		bind $speklistlist <ButtonRelease-1> {SpekListGet %y}
		wm resizable $f 0 0
		bind $f <Return> {set pr_spekload 1}
		bind $f <Escape> {set pr_spekload 0}
	}
	wm title $f "Load named list of data files"
	$f.2.tit config -text "Select named data listing with mouse"
	$speklistlist delete 0 end
	foreach nametag $nametags {
		$speklistlist insert end $nametag
	}
	set pr_spekload 0
	update idletasks
	raise $f
	update idletasks
	My_Grab 0 $f pr_spekload
	update idletasks
	set finished 0
	while {!$finished} {
		tkwait variable pr_spekload
		if {$pr_spekload} {
			if {[string length $spekloadnam] <= 0} {
				Inf "No listing name given"
				continue
			}
			set ofnam $nameroot
			append ofnam "_" $spekloadnam $evv(CDP_EXT)
			set ofnam [file join $evv(SPEKDIR) $ofnam]
			if {![file exists $ofnam]} {
				Inf "File [file tail $ofnam] no longer exists"
				continue
			}
			if {[LoadNamedSpekData $ofnam 1]} {
				set spekloadreturnval 1
				set finished 1
			} else {
				continue
			}
		} else {
			set spekloadreturnval 0
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $spekloadreturnval
}

proc SpekListGet {y} {
	global speklistlist spekloadnam
	set i [$speklistlist nearest $y]
	set nametag [$speklistlist get $i]
	set spekloadnam $nametag
}

#---- Save a list of spectra (or data) files, with a specific name

proc SaveNamedSpekDataListingFile {} {
	global pr_speknamsav speksavnam speksavlist wstk evv
	global spk orig_spek_range spekfrm orig_brrk_range brrkfrm brrk_fnams
	
	set nameroot "datdata"
	set nametags {}
	foreach fnam [lsort -dictionary [glob -nocomplain [file join $evv(SPEKDIR) *]]] {
		set fnam [file rootname [file tail $fnam]]
		if {[string length $fnam] > 7} {
			if {[string first $nameroot $fnam] == 0} {
				lappend nametags [string range $fnam 8 end]
			}
		}
	}
	set f .speknamsav
	if [Dlg_Create $f "Save named list of data files" "set pr_speknamsav 0" -borderwidth 2 -width 80] {
		frame $f.0
		button $f.0.0 -text "Save " -command "set pr_speknamsav 1"  -highlightbackground [option get . background {}]
		button $f.0.1 -text "Abandon" -command "set pr_speknamsav 0"  -highlightbackground [option get . background {}]
		pack $f.0.0 -side left
		pack $f.0.1 -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.1 -text "Listing Name "
		entry $f.1.2 -textvariable speksavnam -width 24
		pack $f.1.1 $f.1.2 -side left
		pack $f.1 -side top -pady 2
		frame $f.2
		label $f.2.tit -text "Existing data listing names" -fg $evv(SPECIAL)
		set speksavlist [Scrolled_Listbox $f.2.ll -width 64 -height 32 -selectmode single]
		pack $f.2.tit $f.2.ll -side top -pady 2
		pack $f.2 -side top -fill both
		bind $speksavlist <ButtonRelease-1> {SpekListSav %y}
		wm resizable $f 0 0
		bind $f <Return> {set pr_speknamsav 1}
		bind $f <Escape> {set pr_speknamsav 0}
	}
	wm title $f "Save named list of data files"
	$f.2.tit config -text "Existing data listing names"
	$speksavlist delete 0 end
	foreach nametag $nametags {
		$speksavlist insert end $nametag
	}
	set pr_speknamsav 0
	update idletasks
	raise $f
	update idletasks
	My_Grab 0 $f pr_speknamsav
	update idletasks
	set finished 0
	while {!$finished} {
		tkwait variable pr_speknamsav
		if {$pr_speknamsav} {
			if {[string length $speksavnam] <= 0} {
				Inf "No listing name given"
				continue
			}
			if {![ValidCDPRootname $speksavnam]} { 
				continue
			}
			set outnam [string tolower $speksavnam]
			if {[lsearch $nametags $outnam] >= 0} {
				set msg "Listing $outnam exists: overwrite it ??"
				set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
			}
			set ofnam $nameroot
			append ofnam "_" $outnam $evv(CDP_EXT)
			set ofnam [file join $evv(SPEKDIR) $ofnam]

			if {[info exists spk(display)] && ![info exists orig_brrk_range]} {
				Inf "No range accessible for display data: cannot save it"
				continue
			} else {
				if {![info exists spk(display)]} {
					set rangelims [list $brrkfrm(lo) $brrkfrm(hi) $brrkfrm(startfreq) $brrkfrm(endfreq)]
				} else {
					set rangelims $orig_brrk_range
				}
				if [catch {open $ofnam "w"} zit ] {
					Inf "Cannot open file [file tail $ofnam] to write listings"
					continue
				} else {
					set outdata [concat $rangelims $brrk_fnams]
					foreach item $outdata {
						puts $zit $item
					}
					close $zit
				}
			}
			Inf "Data curves listing saved"
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc SpekListSav {y} {
	global speksavlist speksavnam
	set i [$speksavlist nearest $y]
	set nametag [$speksavlist get $i]
	set speksavnam $nametag
}

#---- delete current OR named list of spectra (or data) files

proc DeleteNamedSpekDataListingFile {current} {
	global pr_speknamdel spekdelnam spekdellist wstk evv
	
	set nameroot "datdata"
	set nametags {}
	set done 0
	if {$current} {
		foreach fnam [lsort -dictionary [glob -nocomplain [file join $evv(SPEKDIR) *]]] {
			set fnamroot [file rootname [file tail $fnam]]
			if {[string match $nameroot $fnamroot]} {
				catch {file delete $fnam}
				set done 1
				break
			}
		}
		return $done
	}
	foreach fnam [lsort -dictionary [glob -nocomplain [file join $evv(SPEKDIR) *]]] {
		set fnam [file rootname [file tail $fnam]]
		if {[string length $fnam] > 7} {
			if {[string first $nameroot $fnam] == 0} {
				lappend nametags [string range $fnam 8 end]
			}
		}
	}
	if {[llength $nametags] <= 0} {
		Inf "No named data displays exist"
		return 0
	}
	set f .speknamdel
	if [Dlg_Create $f "Delete named display of data files" "set pr_speknamdel 0" -borderwidth 2 -width 80] {
		frame $f.0
		button $f.0.0 -text "Delete Selected " -command "set pr_speknamdel 1"  -highlightbackground [option get . background {}]
		button $f.0.1 -text "Abandon" -command "set pr_speknamdel 0"  -highlightbackground [option get . background {}]
		pack $f.0.0 -side left
		pack $f.0.1 -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.1 -text "Listing Name "
		entry $f.1.2 -textvariable spekdelnam -width 24
		pack $f.1.1 $f.1.2 -side left
		pack $f.1 -side top -pady 2
		frame $f.2
		label $f.2.tit -text "Existing data listing names" -fg $evv(SPECIAL)
		set spekdellist [Scrolled_Listbox $f.2.ll -width 64 -height 32 -selectmode single]
		pack $f.2.tit $f.2.ll -side top -pady 2
		pack $f.2 -side top -fill both
		bind $spekdellist <ButtonRelease-1> {SpekListDel %y}
		wm resizable $f 0 0
		bind $f <Return> {set pr_speknamdel 1}
		bind $f <Escape> {set pr_speknamdel 0}
	}
	wm title $f "Save named list of data files"
	$f.2.tit config -text "Existing data listing names"
	$spekdellist delete 0 end
	foreach nametag $nametags {
		$spekdellist insert end $nametag
	}
	set pr_speknamdel 0
	update idletasks
	raise $f
	update idletasks
	My_Grab 0 $f pr_speknamdel
	update idletasks
	set finished 0
	while {!$finished} {
		tkwait variable pr_speknamdel
		if {$pr_speknamdel} {
			if {[string length $spekdelnam] <= 0} {
				Inf "No listing name given"
				continue
			}
			set ofnam $nameroot
			append ofnam "_" $spekdelnam $evv(CDP_EXT)
			set ofnam [file join $evv(SPEKDIR) $ofnam]
			set msg "Are you sure you want to permanently delete the listing $spekdelnam"
			set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				continue
			}
			catch {file delete $ofnam}
			Inf "Data curves listing $spekdelnam deleted"
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return 1
}

proc SpekListDel {y} {
	global spekdellist spekdelnam
	set i [$spekdellist nearest $y]
	set nametag [$spekdellist get $i]
	set spekdelnam $nametag
}

#---- Load any named list of spectral or data

proc LoadNamedSpekData {srcfnam tell} {
	global init_brrk_range wstk init_spek_fnams init_brrk_fnams brrk_fnams pa swtk datosndlist evv

	if {![file exists $srcfnam]} {
		if {$tell} {
			Inf "Cannot load data from file $srcfnam"
		}
		return 0
	}
	set infnam [file rootname [file tail $srcfnam]]
	if {!([string first  "datdata" $infnam] == 0) && !([string first  "datspek" $infnam] == 0) } {
		Inf "Program error in loadnamedspekdata"
		return 0
	}
	if [catch {open $srcfnam "r"} zit] {
		Inf "Cannot open file $infnam to read sources for data display"
		return 0
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		} else {
			set line [split $line]
			catch {unset nuline}
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				lappend nuline $item
			}
			if {![info exists nuline] || [llength $nuline] > 1} {
				Inf "Unknown item ($line) in data display sources file $infnam\nAbandoning file"
				close $zit
				catch {file delete $srcfnam}
				return 0
			}
			lappend fnams $nuline
		}
	}
	close $zit
	if {![info exists fnams] || ([llength $fnams] < 5)} {
		Inf "No data display information retrieved from file $infnam"
		catch {file delete $srcfnam}
		return 0
	}
	set range [lrange $fnams 0 3]
	foreach {lo hi} $range {
		if {![IsNumeric $lo] || ![IsNumeric $hi] || ($lo >= $hi)} {
			Inf "Stored range of data files invalid"
			catch {file delete $srcfnam}
			return 0
		}
	}
	set init_brrk_range $range
	set fnams [lrange $fnams 4 end]
	foreach fnam $fnams {
		if {![file exists $fnam]} {
			lappend badfiles $fnam
		} else {
			lappend goodfiles $fnam
		}
	}
	if {![info exists goodfiles]} {
		set msg "Data files listed in file $infnam either no longer exist or have been moved\n"
		append msg "If you do not intend to retrieve these files, you should destroy this data list\n\n"
		append msg "Destroy data list ??"
		set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			catch {file delete $srcfnam}
		}
		return 0
	}
	if {[info exists badfiles]} {
		set msg "The following data files no longer exist (or have been moved)\n"
		set cnt 0
		foreach fnam $badfiles {
			append msg "$fnam\n"
			incr cnt
			if {$cnt >= 20} {
				append msg "AND MORE"
				break
			}
		}
		append msg "\n\nDo you still wish to load the data display with the remaining files ??"
		set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			set msg "Remove the file $srcfnam (so as not to refer to incomplete list of files again) ??"
			set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
			if {$choice == "yes"} {
				catch {file delete $srcfnam}
			}
			return 0
		}
	}
	set init_brrk_fnams $goodfiles
	if {$tell} {
		set do_load 0
		foreach fnam $init_brrk_fnams {
			if {![info exists pa($fnam,$evv(FTYP))]} {	
				set do_load 1
				break
			}	
		}
		if {$do_load} {
			Block "Some files are not on the workspace: loading them now"

			foreach fnam [ReverseList $init_brrk_fnams] {
				if {![info exists pa($fnam,$evv(FTYP))]} {	
					wm title .blocker  "PLEASE WAIT:      Loading file [file rootname [file tail $fnam]]"
					FileToWkspace $fnam 0 0 0 0 1
				} else {
					set k [LstIndx $fnam $datosndlist]
					if {$k >= 0} {
						$datosndlist delete $k
					}
				}
				lappend dfnams $fnam
			}
			foreach fnam $dfnams  {
				set k [LstIndx $fnam $datosndlist]
				if {$k < 0} {
					$datosndlist insert 0 $fnam
				}
			}
			UnBlock
		}
	}
	set brrk_fnams $goodfiles
	set brrk_curvcnt [llength $goodfiles]
	return 1
}

###################################################################
#																  #
# LOADING AND SAVING THE DEFAULT LISTINGS OF DATA TO BE DISPLAYED #
#																  #
###################################################################

#--- Initial load of default lists of data and spectral files

proc LoadSpekData {} {
	global evv
	set evv(SPEKDIR) [file join $evv(URES_DIR) spek]
	if {![file exists $evv(SPEKDIR)] || ![file isdirectory $evv(SPEKDIR)]} {
		return
	}
	set srcfnam [file join $evv(SPEKDIR) datdata$evv(CDP_EXT)]
	if {![LoadNamedSpekData $srcfnam 0]} {
		return
	}
	set srcfnam [file join $evv(SPEKDIR) datspek$evv(CDP_EXT)]
	LoadNamedSpekData $srcfnam 0
	LoadSpekouts
}

#--- Save display data for next session

proc SaveSpekData {} {
	global brrk_fnams init_data_lofrq init_data_hifrq init_spek_lofrq init_spek_hifrq evv
	global spk orig_spek_range orig_brrk_range brrkfrm spekfrm spek

	if {![file exists $evv(SPEKDIR)]} {
		if [catch {file mkdir $evv(SPEKDIR)} zorg] {
			Inf "Cannot create directory $evv(spekdir)"
			return
		}
	}
	set fnam [file join $evv(SPEKDIR) datdata$evv(CDP_EXT)]
	if {[info exists brrk_fnams]} {
		if {[info exists spk(display)] && ![info exists orig_brrk_range]} {
			Inf "No range accessible for display data: cannot save it"
		} else {
			if {![info exists spk(display)]} {
				if {![info exists brrkfrm(lo)]} {	;#	No range yet set up
					return
				}
				set rangelims [list $brrkfrm(lo) $brrkfrm(hi) $brrkfrm(startfreq) $brrkfrm(endfreq)]
			} else {
				set rangelims $orig_brrk_range
			}
			set outdata [concat $rangelims $brrk_fnams]
			if [catch {open $fnam "w"} zit] {
				Inf "Cannot save info on data display files"
			} else {
				foreach item $outdata {
					puts $zit $item
				}
				close $zit
			}
		}
	}
}

##########################################################################
#																		 #
# LOADING AND SAVING THE TRANSFORM SEQUENCES AND RELATED CONSTANT VALUES #
#																		 #
##########################################################################


#
#	SPEKT_QUIT	  : Quitting the application: Delete the spektransform used
#	SPEKT_PRESND  : Saving the transform BEFORE making sound : retain spektransform, as sound can still be made
#	SPEKT_APPLY	  : Applying the default transform, but it has been altered: save and retain spektransform
#	SPEKT_POSTSND : Saving and naming the current transform : Save then UNDO the last (sound-making) transform
#					as its possible to use same data to make different sound
#

proc SaveAndNameCurrentTransform {typ} {
	global spektransform pr_spektrstore specktr spektrnam wstk spk speksame evv

	if {$typ == $evv(SPEKT_POSTSND)} {
		if {![info exists spk(snd_created)]} {
			Inf "Create a sound before saving transformation sequence here"
			return
		}
	}
	if {$typ != $evv(SPEKT_QUIT)} {
		if {![info exists spektransform]} {
			Inf "No (new) transform sequences exist"		
			return
		}
		if {![UniqueSpektransform]} {
			set msg "Current transform sequence is same as transform sequence $speksame\n\n"		
			unset speksame
			append msg "Save it anyway, with a new name ?"
			set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				return
			}
		}
	}
	set f .spektranstore
	if [Dlg_Create $f "Save transform sequence with name" "set pr_spektrstore 0" -borderwidth 2 -width 80] {
		frame $f.0
		button $f.0.ok -text "Save Transform" -command "set pr_spektrstore 1"  -highlightbackground [option get . background {}]
		button $f.0.qq -text "Abandon" -command "set pr_spektrstore 0"  -highlightbackground [option get . background {}]
		pack $f.0.ok -side left
		pack $f.0.qq -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.tt -text "Name for Transform"
		entry $f.1.ee -textvariable spektrnam -width 24
		pack $f.1.tt $f.1.ee -side top
		pack $f.1 -side top
		wm resizable $f 0 0
		set spektrnam ""
		bind $f <Return> {set pr_spektrstore 1}
		bind $f <Escape> {set pr_spektrstore 0}
		bind $f <Up>	{AdvanceNameIndex 1 spektrnam 0}
		bind $f <Down>	{AdvanceNameIndex 0 spektrnam 0}
		bind $f <Control-Up>	{AdvanceNameIndex 1 spektrnam 1}
		bind $f <Control-Down>	{AdvanceNameIndex 0 spektrnam 1}
	}
	set pr_spektrstore 0
	ScreenCentre $f
	update idletasks
	raise $f
	My_Grab 0 $f pr_spektrstore $f.1.tt
	set finished 0
	while {!$finished} {
		tkwait variable pr_spektrstore
		if {$pr_spektrstore} {
			if {[string length $spektrnam] <= 0} {
				Inf "No name entered for transform sequence"
				continue
			}
			set thisnam [string tolower $spektrnam] 
			if {![ValidCDPRootname $thisnam]} {
				continue
			}
			if {[string match $thisnam "default"]} {
				Inf "You cannot use this name for a transform sequence"
				continue
			}
			set OK 1
			if {[info exists specktr]} {
				foreach nam [array names specktr] {
					if {[string match $nam $thisnam]} {
						set msg "A transform sequence with this name already exists: overwrite it ??"
						set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							set OK 0
							break
						}
					}
				}
			}
			if {!$OK} {
				continue
			}
			set specktr($thisnam) $spektransform
			switch -regexp -- $typ \
				^$evv(SPEKT_POSTSND)$ {
					if {![SameTransformSequence $specktr($thisnam) $specktr(default)]} {
						set msg "set this transform sequence as the default ??"
						set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
						if {$choice == "yes"} {
							SetCurrentTransformAsDefault 0
						}
					}
					SpekTransseqToPresound
				} \
				^$evv(SPEKT_QUIT)$ {
					unset spektransform
				} \
				^$evv(SPEKT_APPLY)$ {
					set spk(tsaved) 1	;#	Prevent 2nd attempt to save  a "Unique" transform
				}

			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc SpekTransseqToPresound {} {
	global spektransform
	set len [llength $spektransform]
	set k 0
	while {$k < $len} {
		set thistransform [lindex $spektransform $k]
		set action [lindex $thistransform 0]
		if {[string match $action "SPEKSND"] || [string match $action "VARYSPEK"]} {
			set spektransform [lreplace $spektransform $k $k]
			incr len -1
		} else {
			incr k
		}
	}
}

#---- Load and Save Science Data

proc LoadScience {} {
	LoadScienceConstants
	LoadScienceTransforms
}

proc SaveScience {} {
	SaveScienceConstants
	SaveAllScienceTransforms
}

proc LoadScienceConstants {} {
	global evv origspeknyquist origanalpoints origspekdur origvarispekdur
	set scidir [file join $evv(URES_DIR) science]
	if {![file exists $scidir] || ![file isdirectory $scidir]} {
		return
	}
	set fnam [file join $scidir scicons$evv(CDP_EXT)]
	if {![file exists $fnam]} {
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot open data file $fnam to load data sound constants"
		return
	}
	set cnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[llength $line] <= 0} {
			continue
		}
		set line [split $line]
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			switch -- $cnt {
				0 {
					set evv(SPEKNYQUIST) $item
				}
				1 {
					set evv(ANALPOINTS) $item
				}
				2 {
					set evv(SPEKDUR) $item
				}
				3 {
					set evv(VARISPEKDUR) $item
				}
				default {
					Inf "Corrupted data in $fnam (extra data ($item) found"
					break
				}
			}
			incr cnt
		}
	}
	close $zit
	if {[info exists evv(SPEKNYQUIST)]} {
		set origspeknyquist $evv(SPEKNYQUIST)
	}
	if {[info exists evv(ANALPOINTS)]} {
		set origanalpoints $evv(ANALPOINTS)
	}
	if {[info exists evv(SPEKDUR)]} {
		set origspekdur $evv(SPEKDUR)
	}
	if {[info exists evv(VARISPEKDUR)]} {
		set origvarispekdur $evv(VARISPEKDUR)
	}
}

proc SaveScienceConstants {} {
	global evv origspeknyquist origanalpoints origspekdur origvarispekdur
	set save_it 0
	if {![info exists evv(SPEKNYQUIST)] && ![info exists evv(ANALPOINTS)]} {
		return
	}
	set finished 0
	while {!$finished} {
		if {[info exists evv(SPEKNYQUIST)]} {
			if {![info exists origspeknyquist] || ($evv(SPEKNYQUIST) != $origspeknyquist)} {
				set save_it 1
				break
			}
		}
		if {[info exists evv(ANALPOINTS)]} {
			if {![info exists origanalpoints] || ($evv(ANALPOINTS) != $origanalpoints)} {
				set save_it 1
				break
			}
		}
		if {[info exists evv(SPEKDUR)]} {
			if {![info exists origspekdur] || ($evv(SPEKDUR) != $origspekdur)} {
				set save_it 1
				break
			}
		}
		if {[info exists evv(VARISPEKDUR)]} {
			if {![info exists origvarispekdur] || ($evv(VARISPEKDUR) != $origvarispekdur)} {
				set save_it 1
				break
			}
		}
		break
	}
	if {$save_it} {
		set scidir [file join $evv(URES_DIR) science]
		if {![file exists $scidir]} {
			if [catch {file mkdir $scidir} zit] {
				Inf	"Cannot create directory '$scidir' to save science constants"
				return
			}
		}
		set fnam [file join $scidir scicons$evv(CDP_EXT)]
		if [catch {open $fnam "w"} zit] {
			Inf	"Cannot open file $fnam to save data sound constants"
			return
		}
		if {[info exists evv(SPEKNYQUIST)]} {
			puts $zit $evv(SPEKNYQUIST)
		}
		if {[info exists evv(ANALPOINTS)]} {
			puts $zit $evv(ANALPOINTS)
		}
		if {[info exists evv(SPEKDUR)]} {
			puts $zit $evv(SPEKDUR)
		}
		if {[info exists evv(VARISPEKDUR)]} {
			puts $zit $evv(VARISPEKDUR)
		}
		close $zit
	}
}

proc LoadScienceTransforms {} {
	global evv specktr origspekt

	set scidir [file join $evv(URES_DIR) science]
	if {![file exists $scidir] || ![file isdirectory $scidir]} {
		return
	}
	foreach fnam [glob -nocomplain [file join $scidir sci_*]] {
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot open data file $fnam to load transform sequence data"
			continue
		}
		set nam [file rootname [file tail $fnam]]
		set nam [string range $nam 4 end]

		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[llength $line] <= 0} {
				continue
			}
			set line [split $line]
			set cnt 0
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				switch -- $cnt {
					0 {
						set thistransform $item
					}
					default {
						lappend thistransform $item
					}
				}
				incr cnt
			}
			lappend specktr($nam) $thistransform
		}
		close $zit
		if {[info exists specktr($nam)]} {
			set origspekt($nam) $specktr($nam)
		}
	}
}

proc SaveAllScienceTransforms {} {
	global evv specktr origspekt
	if {![info exists specktr]} {
		return
	}
	set save_it 0
	foreach nam [array names specktr] {
		if {![info exists origspekt($nam)]} {
			set save_it 1
		} elseif {[llength $specktr($nam)] != [llength $origspekt($nam)]} {
			set save_it 1
		} else {
			foreach t $specktr($nam) ot $origspekt($nam) {
				if {[llength $t] != [llength $ot]} {
					set save_it 1
					break
				}
				foreach i_t $t i_ot $ot {
					if {![string match $i_t $i_ot]} {
						set save_it 1
						break
					}
				}
				if {$save_it} {
					break
				}
			}
		}
		if {$save_it} {
			SaveScienceTransform $nam
		}
	}
}

proc SaveScienceTransform {nam} {
	global evv specktr
	set scidir [file join $evv(URES_DIR) science]
	if {![file exists $scidir]} {
		if [catch {file mkdir $scidir} zit] {
			Inf	"Cannot create directory to save transform info"
			return
		}
	}
	set fnam [file join $scidir "sci_"]
	append fnam $nam $evv(CDP_EXT)
	if [catch {open $fnam "w"} zit] {
		Inf "Cannot open file $fnam to save data transform sequence $nam"
		return
	}
	foreach line $specktr($nam) {
		puts $zit $line
	}
	close $zit
}

#########################################################
#														#
#	GENERATE SPECTRUM IN FORMAT FOR CONVERTING TO SOUND	#
#														#
#########################################################

proc GenerateSpektra {apply} {
	global brrk_curvcnt spk evv wstk
	global spek_c orig_range_spek_c spekfrm orig_range_spekfrm last_spek_c spektransform bsh bsh_list brrkcolor

	if {!$apply && $spk(ified)} {
		Inf "Already converted to playable data"
		return 0
	}
	if {!$spk(interpd)} {
		if {!$apply} {
			Inf "Smooth spectrum first"
		}
		return 0
	}
	set last_indx [expr $brrk_curvcnt - 1]
	if {$apply} {
		set k 0
		while {$k < $brrk_curvcnt} {
			wm title .blocker  "PLEASE WAIT:      Converting file [expr $k + 1] to playable data"
			if {![GenerateSpektrum $spek_c($k) $k]} {
				return 0
			}
			incr k
		}
	} else {
		if {![info exists orig_range_spek_c]} {
			set orig_range_spek_c $spek_c($last_indx)
			foreach nam [array names spek] {
				set orig_range_spek($nam) $spek($nam)
			}
			foreach nam [array names spekfrm] {
				set orig_range_spekfrm($nam) $spekfrm($nam)
			}
		}
		set last_spek_c $spek_c($last_indx)
		if {![GenerateSpektrum $spek_c($last_indx) $last_indx]} {
			return 0
		}
		set thistransform [list SPEKIFY]
		lappend spektransform $thistransform
		set spk(ified) 1
#		if {[info exists evv(TESTING)]} {
#			List_Spectrum
#		}
		Inf "Converted to playable data"
	}
	return 1
}

#------ Gat amplitude from spctral display at specified frq (linear interp of smoothed data)

proc GetAmpFromSpectrum {chantopfrq spekk} {
	global spek_c
	foreach {frq amp} $spekk {
		if {$frq <= $chantopfrq} {
			set startfrq $frq
			set startamp $amp
		} elseif {$frq >= $chantopfrq} {
			set endfrq $frq
			set endamp $amp
			break
		}
	}
	if {[info exists endfrq]} {
		set frqgap   [expr $endfrq - $startfrq]
		set frqstep  [expr $chantopfrq - $startfrq]	;#	LINEAR INTERP
		set ratio	 [expr double($frqstep)/$frqgap]
		set ampgap   [expr $endamp - $startamp]
		set ampstep  [expr $ampgap * $ratio]
		set amp		 [expr $startamp + $ampstep]
	} else {
		set amp 0.0									;# AMP AT NYQUIST FORCED TO ZERO
	}
	return $amp
}

#---- Convert a smoothed version of amp frq data in range 0-1 0-nyquist
#---- To a version linked to PVOC channels with special coding of peaks, troughs

proc GenerateSpektrum {specc k} {
	global evv CDPidrun prg_dun prg_abortd

	set j $k
	incr j
	set fnam0 $evv(DFLT_OUTNAME)
	append fnam0 0 $evv(TEXT_EXT)
	set fnam1 $evv(DFLT_OUTNAME)
	append fnam1 $j $evv(TEXT_EXT)
	catch {file delete $fnam0}
	catch {file delete $fnam1}
	incr k
	if [file exists $fnam0] {
		if [catch {file delete $fnam0} zit] {
			Inf "Cannot delete temporary file in order to write spectral data for curve $k"
			return 0
		}
	}
	if [catch {open $fnam0 "w"} zit] {
		Inf "Cannot open temporary file to write spectral data for curve $k"
		return 0
	}
	foreach {frq amp} $specc {
		set line [list $frq $amp]
		puts $zit $line
	}
	close $zit
	set cmd [file join $evv(CDPROGRAM_DIR) spectrum]
	lappend cmd format $fnam1 $fnam0 $evv(ANALPOINTS) [expr $evv(SPEKNYQUIST) * 2]
	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	if [catch {open "|$cmd"} CDPidrun] {
		Inf "Spectral conversion failed for curve $k"
		DeleteAllTemporaryFiles
		return 0
   	} else {
   		fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
	}
	vwait prg_dun
	if {$prg_abortd} {
		set prg_dun 0
	}
	if {!$prg_dun} {
		Inf "Conversion of spectrum failed for curve $k"
		DeleteAllTemporaryFiles
		return 0
	}
	return 1
}

#---- Check for any temp anal files on the system, before proceding

proc CheckSpekTempFiles {} {
	global evv brrk_curvcnt brrk_curvcnt
	set sfnam $evv(DFLT_OUTNAME)
	append sfnam 1 $evv(ANALFILE_EXT)
	if {[file exists $sfnam]} {
		if [catch {file delete $sfnam} zit] {
			Inf "Cannot delete the temporary file $sfnam: delete before you proceed"
			return 0
		}
	}
	return 1
}

#----- CREATE SOUND FILE FROM SPECIAL-FORMAT SPECTRAL TEXT DATA

proc CreateFixedSpectrumSound {apply} {
	global brrk_curvcnt pr_speksnd speksnddur speksndharm speksndbrite speksndgain speksnd_got spek_sndnam 
	global spekouts spektransform spk last_spekouts speksndfrac speksndatt spek_sndfrac spek_sndatt
	global speksndnam spek_snddur spek_sndharm spek_sndbrite spek_sndgain prg_dun prg_abortd CDPidrun wstk evv
	global spek_sndspred speksndspred speksndtype spek_sndtype done_spekify last_spektransform 
	global testmaxspek testedmaxspek

	if {!$apply && !($spk(ified) || [info exists done_spekify])} {
		Inf "Convert to playable file first"
		return 0
	}
	set sndfnam $evv(DFLT_OUTNAME)
	append sndfnam 1 $evv(ANALFILE_EXT)
	if {![CheckSpekTempFiles]} {
		return 0
	}

	if {!$apply} {
		set datfnam $evv(DFLT_OUTNAME)
		append datfnam 1 $evv(TEXT_EXT)
		if {![file exists $datfnam]} {
			Inf "Temporary data file $datfnam does not exist, cannot proceed"
			return 0
		}
		catch {unset spekouts}
		set speksnd_got 0
		set f .speksnd
		if [Dlg_Create $f "Create sound output" "set pr_speksnd 0" -borderwidth 2 -width 80] {
			frame $f.0
			button $f.0.ok -text "Make Sound" -command "set pr_speksnd 1"  -highlightbackground [option get . background {}]
			button $f.0.qq -text "Abandon" -command "set pr_speksnd 0"  -highlightbackground [option get . background {}]
			pack $f.0.ok -side left
			pack $f.0.qq -side right
			pack $f.0 -side top -fill x -expand true
			frame $f.1
			entry $f.1.e -textvariable speksnddur -width 12
			label $f.1.ll -text "Duration"
			pack $f.1.e $f.1.ll -side left -padx 2
			frame $f.2
			entry $f.2.e -textvariable speksndharm -width 12
			label $f.2.ll -text "No. of harmonics of the peak frqs to use (if any)"
			pack $f.2.e $f.2.ll -side left -padx 2
			frame $f.3
			entry $f.3.e -textvariable speksndbrite -width 12
			label $f.3.ll -text "Brightness of peak pitches (>0 to 1)"
			pack $f.3.e $f.3.ll -side left -padx 2
			frame $f.3z
			entry $f.3z.e -textvariable speksndspred -width 12
			label $f.3z.ll -text "Freq spread of peak pitches (0 to 0.1)"
			pack $f.3z.e $f.3z.ll -side left -padx 2
			frame $f.3a
			entry $f.3a.e -textvariable speksndfrac -width 12
			label $f.3a.ll -text "Fraction of noise background fluctuating (0 to 1)"
			pack $f.3a.e $f.3a.ll -side left -padx 2
			frame $f.3b
			entry $f.3b.e -textvariable speksndatt -width 12
			label $f.3b.ll -text "Max attenuation of fluctuating background (0 to 1)"
			pack $f.3b.e $f.3b.ll -side left -padx 2
			frame $f.4
			entry $f.4.e -textvariable speksndgain -width 12
			label $f.4.ll -text "Overall attenuation of output (.01 to 1)"
			pack $f.4.e $f.4.ll -side left -padx 2
			frame $f.4a
			radiobutton $f.4a.0 -text "fixed brightness" -variable speksndtype -value 0
			radiobutton $f.4a.1 -text "peakwidth determines brightness" -variable speksndtype -value 1
			radiobutton $f.4a.2 -text "frq varies over pkwidth" -variable speksndtype -value 2
			radiobutton $f.4a.3 -text "harmonics also vary over pkwidth" -variable speksndtype -value 3
			radiobutton $f.4a.4 -text "peakwidth determines brightness : frq varies over pkwidth" -variable speksndtype -value 4
			radiobutton $f.4a.5 -text "peakwidth determines brightness : harmonics also vary over pkwidth" -variable speksndtype -value 5
			pack $f.4a.0 $f.4a.1 $f.4a.2 $f.4a.3 $f.4a.4 $f.4a.5 -side top -pady 2 -anchor w

			frame $f.5
			entry $f.5.e -textvariable speksndnam -width 12
			label $f.5.ll -text "Name for output file(s)"
			pack $f.5.e $f.5.ll -side left -padx 2
			pack $f.1 $f.2 $f.3 $f.3z $f.3a $f.3b $f.4 $f.4a $f.5 -side top -pady 2 -fill x -expand true
			wm resizable $f 0 0
			bind $f.1.e  <Down> {focus .speksnd.2.e}
			bind $f.2.e  <Down> {focus .speksnd.3.e}
			bind $f.3.e  <Down> {focus .speksnd.3z.e}
			bind $f.3z.e <Down> {focus .speksnd.3a.e}
			bind $f.3a.e <Down> {focus .speksnd.3b.e}
			bind $f.3b.e <Down> {focus .speksnd.4.e}
			bind $f.4.e  <Down> {focus .speksnd.5.e}
			bind $f.5.e  <Down> {focus .speksnd.1.e}
			bind $f.1.e  <Up>   {focus .speksnd.5.e}
			bind $f.2.e  <Up>   {focus .speksnd.1.e}
			bind $f.3.e  <Up>   {focus .speksnd.2.e}
			bind $f.3z.e <Up>   {focus .speksnd.3.e}
			bind $f.3a.e <Up>   {focus .speksnd.3z.e}
			bind $f.3b.e <Up>   {focus .speksnd.3a.e}
			bind $f.4.e  <Up>   {focus .speksnd.3b.e}
			bind $f.5.e  <Up>   {focus .speksnd.4.e}
			bind $f <Return> {set pr_speksnd 1}
			bind $f <Escape> {set pr_speksnd 0}
			if {[info exists evv(SPEKDUR)]} {
				set speksnddur $evv(SPEKDUR)
			} else {
				set speksnddur ""
			}
			set speksndtype 0
			set speksndnam ""
			set speksndharm ""
			set speksndbrite ""
			set speksndspred ""
			set speksndfrac ""
			set speksndatt ""
			set speksndgain ""
		}
		set pr_speksnd 0
		update idletasks
		raise $f
		My_Grab 0 $f pr_speksnd $f.2.e
		set finished 0
		while {!$finished} {
			tkwait variable pr_speksnd
			if {$pr_speksnd} {
				if {[string length $speksndnam] <= 0} {
					Inf "No name entered for output sound"
					continue
				}
				set spek_sndnam [string tolower $speksndnam] 
				if {![ValidCDPRootname $spek_sndnam]} { 
					continue
				}
				if {$brrk_curvcnt > 1} {
					set kk 1
					set asked 0
					set OK 1
					while {$kk <= $brrk_curvcnt} {
						set outnam $spek_sndnam
						append outnam $kk $evv(SNDFILE_EXT)
						if {[file exists $outnam]} {
							if {!$asked} {
								set msg "File $outnam already exists: overwrite files with this generic name ??"
								set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
								if {$choice == "no"} {
									set OK 0
									break
								}
								set asked 1
							}
							if [catch {file delete $outnam} zit] { 
								Inf "Cannot delete existing file $outnam"
								set OK 0
								break
							} elseif {[info exists last_spekouts]} {
								set kj [lsearch $last_spekouts $outnam]
								while {$kj >= 0} {
									set last_spekouts [lreplace $last_spekouts $kj $kj]
									set kj [lsearch $last_spekouts $outnam]
								}
								if {[llength $last_spekouts] <= 0} {
									unset last_spekouts
								}
							}
						}
						incr kk
					}
					if {[info exists spk(vary)]} {
						set outnam $spek_sndnam
						append outnam $evv(SNDFILE_EXT)
						if {[file exists $outnam]} {
							set msg "File $outnam already exists: overwrite file with this name ??"
							set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
							if {$choice == "no"} {
								set OK 0
							} elseif [catch {file delete $outnam} zit] { 
								Inf "Cannot delete existing file $outnam"
								set OK 0
							}
						}
					}
					if {!$OK} {
						continue
					}
				} else {
					append spek_sndnam $evv(SNDFILE_EXT)

					if {[file exists $spek_sndnam]} {
						set msg "File $spek_sndnam already exists: overwrite it ??"
						set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							continue
						}
						if [catch {file delete $spek_sndnam} zit] { 
							Inf "Cannot delete existing file $spek_sndnam"
							continue
						} elseif {[info exists last_spekouts]} {
							set kj [lsearch $last_spekouts $spek_sndnam]
							while {$kj >= 0} {
								set last_spekouts [lreplace $last_spekouts $kj $kj]
								set kj [lsearch $last_spekouts $spek_sndnam]
							}
							if {[llength $last_spekouts] <= 0} {
								unset last_spekouts
							}
						}
					}
				}
				if {([string length $speksnddur] <= 0) || ![IsNumeric $speksnddur] || ($speksnddur < 0.5) || ($speksnddur > 3600.0)} {
					Inf "Invalid duration value"
					continue
				} else {
					set evv(SPEKDUR) $speksnddur
				}
				if {[string length $speksndharm] <= 0} {
					set spek_sndharm 0
				} elseif {![regexp {^[0-9]+$} $speksndharm] || ![IsNumeric $speksndharm]} {
					Inf "Invalid no. of harmonics"
					continue
				} else {
					set spek_sndharm $speksndharm
				}
				if {[string length $speksndbrite] <= 0} {
					set spek_sndbrite 0
				} elseif {![IsNumeric $speksndbrite] || ($speksndbrite <= 0.0) || ($speksndbrite > 1.0)} {
					Inf "Invalid brightness value"
					continue
				} else {
					set spek_sndbrite $speksndbrite
					if {[Flteq $spek_sndbrite 0.0]} {
						set spek_sndbrite 0
					}
				}
				if {[string length $speksndspred] <= 0} {
					set spek_sndspred 0
				} elseif {![IsNumeric $speksndspred] || ($speksndspred < 0.0) || ($speksndspred > 0.1)} {
					Inf "Invalid peak spread value (0 to 0.1)"
					continue
				} else {
					set spek_sndspred $speksndspred
					if {[Flteq $spek_sndspred 0.0]} {
						set spek_sndspred 0
					}
				}
				if {[string length $speksndfrac] <= 0} {
					set spek_sndfrac 0
				} elseif {![IsNumeric $speksndfrac] || ($speksndfrac < 0.0) || ($speksndfrac > 1.0)} {
					Inf "Invalid fluctuation fraction"
					continue
				} else {
					set spek_sndfrac $speksndfrac
					if {[Flteq $spek_sndfrac 0.0]} {
						set spek_sndfrac 0
					}
				}
				if {[string length $speksndatt] <= 0} {
					set spek_sndatt 0
				} elseif {![IsNumeric $speksndatt] || ($speksndatt < 0.0) || ($speksndatt > 1.0)} {
					Inf "Invalid fluctuation attenuation"
					continue
				} else {
					set spek_sndatt $speksndatt
					if {[Flteq $spek_sndatt 0.0]} {
						set spek_sndatt 0
					}
				}
				if {[string length $speksndgain] <= 0} {
					set spek_sndgain 1
				} elseif {![IsNumeric $speksndgain] || ($speksndgain < 0.01) || ($speksndgain > 1.0)} {
					Inf "Invalid attenuation value"
					continue
				} else {
					set spek_sndgain $speksndgain
				}
				if {[Flteq $spek_sndgain 1.0]} {
					set spek_sndgain 1
				}
				set spek_sndtype $speksndtype
				set speksnd_got 1
				set finished 1
			} else {
				set speksnd_got 0
				set finished 1
			}
		}
		My_Release_to_Dialog $f
		Dlg_Dismiss $f
		if {!$speksnd_got} {
			return 0
		}
	} else {
		set kk 1
		set Deletecmd DeleteAllTemporaryFilesExcept
		while {$kk <= $brrk_curvcnt} {
			set datfnam $evv(DFLT_OUTNAME)
			append datfnam $kk $evv(TEXT_EXT)
			if {![file exists $datfnam]} {
				Inf "Temporary data file $datfnam does not exist, cannot proceed"
				return 0
			}
			lappend Deletecmd $datfnam
			incr kk
		}
	}
	catch {unset spekouts}
	set srate [expr round($evv(SPEKNYQUIST) * 2.0)]
	set cmd [file join $evv(CDPROGRAM_DIR) spectrum]
	if {$brrk_curvcnt == 1} {
		set inf $evv(DFLT_OUTNAME)
		append inf 1 $evv(TEXT_EXT)
		if {[info exists testmaxspek]} {
			 lappend cmd fixed $sndfnam $inf $evv(ANALPOINTS) $srate [expr $evv(SPEKDUR) * $testmaxspek]
		} else {
			lappend cmd fixed $sndfnam $inf $evv(ANALPOINTS) $srate $evv(SPEKDUR)
		}
		if {($spek_sndharm > 0) && ($spek_sndbrite > 0)} {
			lappend cmd -h$spek_sndharm -b$spek_sndbrite
		}
		if {($spek_sndfrac > 0) && ($spek_sndatt > 0)} {
			lappend cmd -f$spek_sndfrac -r$spek_sndatt
		}
		if {$spek_sndspred > 0} {
			lappend cmd -s$spek_sndspred
		}
		if {$spek_sndgain < 1.0} {
			lappend cmd -a$spek_sndgain
		}
		set silence_out 0
		if {$spek_sndtype > 0} {
			set widfnam $evv(MACH_OUTFNAME)
			append widfnam 0 $evv(TEXT_EXT)
			if {![file exists $widfnam]} {
				Inf "No spectral width information available: cannot proceed"
				catch {unset testmaxspek}
				return 0
			}
			if [catch {open $widfnam "r"} zit]  {
				Inf "Cannot open width information file $widfnam"
				catch {unset testmaxspek}
				return 0
			}
			set cnt 0
			while {[gets $zit line] >= 0} {
				set line [string trim $line]
				set line [split $line]
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] <= 0} {
						continue
					}
					lappend widata $item
					incr cnt
				}
			}
			close $zit
			if {$cnt > 0} {
				if {![IsEven $cnt]} {
					Inf "Invalid data in width information file $widfnam"
					catch {unset testmaxspek}
					return 0
				}
				set jj 0
				set maxwid 0
				set lastpfq 0.0
				foreach {pfq wid} $widata {
					if {$pfq <= $lastpfq} {
						Inf "Invalid peak frequency (of frq order) in width information file $widfnam"
						catch {unset testmaxspek}
						return 0
					}
					set lastpfq $pfq
					if {$wid < 0.0} {
						Inf "Invalid peak width aspect value ($wid) in width information file $widfnam"
						catch {unset testmaxspek}
						return 0
					}
					if {$wid > $maxwid} {
						set maxwid $wid
					}
					incr jj
				}
				lappend cmd -t$spek_sndtype -w$widfnam -m$maxwid 
			} else {
				set msg "No significant peaks: continue to create silent file ?"
				set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					catch {unset testmaxspek}
					return 0
				}
				set silence_out 1
			}
		}
		if {$silence_out} {
			set cmd [file join $evv(CDPROGRAM_DIR) synth]
			if {[info exists testmaxspek]} {
				lappend cmd silence $spek_sndnam $srate 1 [expr $evv(SPEKDUR) * $testmaxspek]
				catch {unset testmaxspek}
				set testedmaxspek 1
			} else {
				lappend cmd silence $spek_sndnam $srate 1 $evv(SPEKDUR)
			}
			set prg_dun 0
			set prg_abortd 0
			if [catch {open "|$cmd"} CDPidrun] {
				Inf "Silent file creation failed"
				catch {eval $Deletecmd}
				catch {unset testedmaxspek}
				return 0
   			} else {
   				fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
			}
			vwait prg_dun
			if {$prg_abortd} {
				set prg_dun 0
			}
			if {!$prg_dun} {
				Inf "Creation of silent soundfile failed"
				catch {eval $Deletecmd}
				catch {unset testedmaxspek}
				return 0
			}
		} else {
			set prg_dun 0
			set prg_abortd 0
			if [catch {open "|$cmd"} CDPidrun] {
				Inf "Analysis file conversion failed"
				catch {eval $Deletecmd}
				catch {unset testmaxspek}
				return 0
   			} else {
   				fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
			}
			vwait prg_dun
			if {$prg_abortd} {
				set prg_dun 0
			}
			if {!$prg_dun} {
				Inf "Conversion to analysis file failed"
				catch {eval $Deletecmd}
				catch {unset testmaxspek}
				return 0
			}
			set cmd [file join $evv(CDPROGRAM_DIR) pvoc]
			lappend cmd synth $sndfnam $spek_sndnam
			set prg_dun 0
			set prg_abortd 0
			if [catch {open "|$cmd"} CDPidrun] {
				Inf "Sound conversion failed"
				catch {eval $Deletecmd}
				catch {unset testmaxspek}
				return 0
   			} else {
   				fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
			}
			vwait prg_dun
			if {$prg_abortd} {
				set prg_dun 0
			}
			if {!$prg_dun} {
				Inf "Conversion to sound failed"
				catch {eval $Deletecmd}
				catch {unset testmaxspek}
				return 0
			}
			if {[info exists testmaxspek]} {
				unset testmaxspek
				set testedmaxspek 1
			}
		}
		FileToWkspace $spek_sndnam 0 0 0 0 1
		DummyHistory $spek_sndnam "CREATED"
		set msg "File  $spek_sndnam is on the workspace: Play it ?"
		set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			PlaySndfile $spek_sndnam 0
		}
		lappend spekouts $spek_sndnam
	} else {
		if {$spek_sndtype > 0} {		;#	Get max width-aspect value
			set is_snd_out 0
			set maxwid 0
			set kk 0
			catch {unset silents}
			while {$kk < $brrk_curvcnt} {
				set widfnam $evv(MACH_OUTFNAME)
				append widfnam $kk $evv(TEXT_EXT)
				if {![file exists $widfnam]} {
					Inf "No spectral width information for curve [expr $kk + 1] available: cannot proceed"
					return 0
				}
				if [catch {open $widfnam "r"} zit]  {
					Inf "Cannot open width information file $widfnam for curve [expr $kk + 1]"
					return 0
				}
				set cnt 0
				catch {unset widata}
				while {[gets $zit line] >= 0} {
					set line [string trim $line]
					set line [split $line]
					foreach item $line {
						set item [string trim $item]
						if {[string length $item] <= 0} {
							continue
						}
						lappend widata $item
						incr cnt
					}
				}
				close $zit
				if {$cnt > 0} {
					if {![IsEven $cnt]} {
						Inf "Invalid data in width information file $widfnam for curve [expr $kk + 1]"
						return 0
					}
					set jj 0
					set lastpfq 0.0
					foreach {pfq wid} $widata {
						if {$pfq <= $lastpfq} {
							Inf "Invalid peak frq (of frq order) in width information file $widfnam for curve [expr $kk + 1]"
							return 0
						}
						set lastpfq $pfq
						if {$wid < 0.0} {
							Inf "Invalid peak width aspect value ($wid) in width information file $widfnam for curve [expr $kk + 1]"
							return 0
						}
						if {$wid > $maxwid} {
							set maxwid $wid
						}
						incr jj
					}
					lappend silents 0
					set is_snd_out 1
				} else {
					lappend silents 1
				}
				incr kk
			}
		} else {
			set is_snd_out 1
			set kk 0
			catch {unset silents}
			while {$kk < $brrk_curvcnt} {
				lappend silents 0
				incr kk
			}
		}
		if {!$is_snd_out} {
			Inf "No significant peaks found using these parameters"
			return 0
		}
		if {[info exists spekouts]} {
			set spekoutsstt [llength $spekouts]
		} else {
			set spekoutsstt 0
		}
		if {!$apply} {
			Block "Generating Outfiles"
		}
		if {[info exists spk(vary)]} {
			set durspek [expr $evv(VARISPEKDUR)/double($brrk_curvcnt + 2)]
			set durspek [expr $durspek * 3]
		} else {
			set durspek $evv(SPEKDUR)
		}
		if {[info exists testmaxspek]} {
			set durspek [expr $durspek * $testmaxspek]
			unset testmaxspek
			set testedmaxspek 1
		}
		set firstendsilence $brrk_curvcnt
		if {[info exists silents]} {
			set jj $brrk_curvcnt					;#	IGNORE END SILENCE
			incr jj -1
			while {$jj >= 0} {
				if {[lindex $silents $jj] == 0} {
					set firstendsilence $jj
					incr firstendsilence
					break
				}
				incr jj -1
			}
		}

		set kk 0	;#	Numbers width files and outfiles
		set jj 1	;#	Numbers in-sndfiles, and used in messages
		while {$kk < $firstendsilence} {
			if {[file exists $sndfnam]} {
				if [catch {file delete $sndfnam} zit] {
					Inf "Failed to delete intermediate file"
					DeleteAllTemporaryFiles
					if {!$apply} {
						UnBlock
					}
					break
				}				
			}
			set silence_out [lindex $silents $kk]
			if {$silence_out} {
				set outnam $spek_sndnam
				append outnam $kk $evv(SNDFILE_EXT)
				set cmd [file join $evv(CDPROGRAM_DIR) synth]
				lappend cmd silence $outnam $srate 1 $durspek
				set prg_dun 0
				set prg_abortd 0
				wm title .blocker  "PLEASE WAIT:      Generating file $outnam"
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "Silent file $jj creation failed"
					catch {eval $Deletecmd}
					set k_k 0
					while {$k_k <= $kk} {
						set outnam $spek_sndnam
						append outnam $k_k $evv(SNDFILE_EXT)
						catch {file delete $outnam}
						incr k_k
					}
					catch {unset testedmaxspek}
					return 0
   				} else {
   					fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				if {!$prg_dun} {
					Inf "Creation of silent soundfile $jj failed"
					catch {eval $Deletecmd}
					set k_k 0
					while {$k_k <= $kk} {
						set outnam $spek_sndnam
						append outnam $k_k $evv(SNDFILE_EXT)
						catch {file delete $outnam}
						incr k_k
					}
					catch {unset testedmaxspek}
					return 0
				}
				lappend spekouts $outnam
			} else {
				set inf $evv(DFLT_OUTNAME)$jj$evv(TEXT_EXT)
				set cmd [file join $evv(CDPROGRAM_DIR) spectrum]
				lappend cmd fixed $sndfnam $inf $evv(ANALPOINTS) $srate $durspek
				if {($spek_sndharm > 0) && ($spek_sndbrite > 0)} {
					lappend cmd -h$spek_sndharm -b$spek_sndbrite
				}
				if {($spek_sndfrac > 0) && ($spek_sndatt > 0)} {
					lappend cmd -f$spek_sndfrac -r$spek_sndatt
				}
				if {$spek_sndspred > 0} {
					lappend cmd -s$spek_sndspred
				}
				if {$spek_sndgain < 1.0} {
					lappend cmd  -a$spek_sndgain
				}
				if {$spek_sndtype > 0} {				;#	INCORPORATE WIDTH INFO FOR OTHER SPECTRUM TYPES
					set widfnam $evv(MACH_OUTFNAME)
					append widfnam $kk $evv(TEXT_EXT)
					lappend cmd -t$spek_sndtype -w$widfnam -m$maxwid 
				}
				if {[info exists spk(vary)]} {
					lappend cmd -d						;#	LESS DOVETAILING OF INDIVIDUAL SOUNDS
				}
				set prg_dun 0
				set prg_abortd 0
				set outnam $spek_sndnam
				append outnam $kk $evv(SNDFILE_EXT)

				wm title .blocker  "PLEASE WAIT:      Generating file $outnam"
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "Analysis file conversion failed for curve $jj"
					incr kk
					incr jj
					continue
   				} else {
   					fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				if {!$prg_dun} {
					Inf "Conversion to analysis file failed for curve $jj"
					if {[info exists spk(vary)]} {
						set spek_vary_failed 1
					}
					incr kk
					incr jj
					continue
				}

				set cmd [file join $evv(CDPROGRAM_DIR) pvoc]
				lappend cmd synth $sndfnam $outnam
				set prg_dun 0
				set prg_abortd 0
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "Sound conversion failed for curve $jj"
					if {[info exists spk(vary)]} {
						set spek_vary_failed 1
					}
					incr kk
					incr jj
					continue
   				} else {
   					fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				if {!$prg_dun} {
					Inf "Conversion to sound failed for curve $jj"
					catch {eval $Deletecmd}
					if {[info exists spk(vary)]} {
						set spek_vary_failed 1
					}
					incr kk
					incr jj
					continue
				}
				lappend spekouts $outnam
			}
			incr kk
			incr jj
		}
		if {[file exists $sndfnam]} {
			if [catch {file delete $sndfnam} zit] {
				Inf "Failed to delete intermediate file $sndfnam"
			}				
		}
		if {!$apply} {
			UnBlock
		}
		set len [llength $spekouts]
		if {$len == $spekoutsstt} {
			Inf "No sounds generated"
			catch {unset testedmaxspek}
			return 0
		}
		if {[info exists spk(vary)]} {
			if [info exists spek_vary_failed] {
				unset spek_vary_failed
				set msg "Some files failed to be generated: cannot mix the time-series\n\n"
				append msg "Save the individual sounds generated ?"			
				set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					DeleteAllTemporaryFiles
					catch {unset testedmaxspek}
					return 0
				} else {
					set do_all_files 1
				} 
			} else {
				DeleteAllTemporaryFiles
				set outlist [lrange $spekouts $spekoutsstt end]
				catch {unset inffs}
				catch {unset outfs}
				set jj 0
				wm title .blocker  "PLEASE WAIT:      Renaming individual spectra"
				foreach fnam $outlist {
					set inff $evv(DFLT_OUTNAME)
					append inff $jj $evv(SNDFILE_EXT)
					set outf $evv(DFLT_OUTNAME)
					append outf 0 $jj $evv(SNDFILE_EXT)
					if [catch {file rename $fnam $inff} zit] {
						Inf "Failed to rename outfile $fnam"
						DeleteAllTemporaryFiles
						catch {unset testedmaxspek}
						return 0
					}
					lappend inffs $inff
					lappend outfs $outf
					incr jj
				}
				wm title .blocker  "PLEASE WAIT:      Creating enveloping files"
				set timestep [expr $durspek/3.0]
				set time0 0.0
				set time1 [expr $time0 + $timestep]
				set time2 [expr $time1 + $timestep]
				set time3 $durspek
				set envfnam0 $evv(DFLT_OUTNAME)
				append envfnam0 0 $evv(TEXT_EXT)
				set envfnam1 $evv(DFLT_OUTNAME)
				append envfnam1 1 $evv(TEXT_EXT)
				set envfnam2 $evv(DFLT_OUTNAME)
				append envfnam2 2 $evv(TEXT_EXT)
				set mixfnam  $evv(DFLT_OUTNAME)
				append mixfnam  3 $evv(TEXT_EXT)
				if [catch {open $envfnam0 "w"} zit] {
					Inf "Failed to open enveloping file $envfnam0"
					DeleteAllTemporaryFiles
					catch {unset testedmaxspek}
					return 0
				}
				set line [list $time0 1]
				puts $zit $line
				set line [list $time2 1]
				puts $zit $line
				set line [list $time3 0]
				puts $zit $line
				close $zit
				if [catch {open $envfnam1 "w"} zit] {
					Inf "Failed to open enveloping file $envfnam1"
					DeleteAllTemporaryFiles
					catch {unset testedmaxspek}
					return 0
				}
				set line [list $time0 0]
				puts $zit $line
				set line [list $time1 1]
				puts $zit $line
				set line [list $time2 1]
				puts $zit $line
				set line [list $time3 0]
				puts $zit $line
				close $zit
				if [catch {open $envfnam2 "w"} zit] {
					Inf "Failed to open enveloping file $envfnam2"
					DeleteAllTemporaryFiles
					catch {unset testedmaxspek}
					return 0
				}
				set line [list $time0 0]
				puts $zit $line
				set line [list $time1 1]
				puts $zit $line
				set line [list $time3 1]
				puts $zit $line
				close $zit
				set len [llength $inffs]
				set last [expr $len - 1] 
				set jj 0
				foreach inff $inffs outf $outfs {
					set cmd [file join $evv(CDPROGRAM_DIR) modify]
					lappend cmd loudness 1 $inff $outf
					if {$jj == 0} {
						lappend cmd $envfnam0
					} elseif {$jj == $last} {
						lappend cmd $envfnam2
					} else {
						lappend cmd $envfnam1
					}
					set silence_out [lindex $silents $jj]
					if {$silence_out} {
						wm title .blocker  "PLEASE WAIT:      Rename file [expr $jj + 1]"
						file rename $inff $outf
					} else {
						wm title .blocker  "PLEASE WAIT:      Enveloping file [expr $jj + 1]"
						set prg_dun 0
						set prg_abortd 0
						if [catch {open "|$cmd"} CDPidrun] {
							Inf "Enveloping failed for curve [expr $jj + 1]"
							DeleteAllTemporaryFiles
							catch {unset testedmaxspek}
							return 0
   						} else {
   							fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
						}
						vwait prg_dun
						if {$prg_abortd} {
							set prg_dun 0
						}
						if {!$prg_dun} {
							Inf "Enveloping of sound failed for curve [expr $jj + 1]"
							DeleteAllTemporaryFiles
							catch {unset testedmaxspek}
							return 0
						}
					}
					incr jj
				}
				wm title .blocker  "PLEASE WAIT:      Mixing time sequence"
				if [catch {open $mixfnam "w"} zit] {
					Inf "Failed to open mixing file $mixfnam"
					DeleteAllTemporaryFiles
					catch {unset testedmaxspek}
					return 0
				}
				set time 0.0
				foreach outf $outfs {
					set line $outf 
					lappend line $time 1 1 C
					puts $zit $line
					set time [expr $time + $timestep] 
				}
				close $zit
				set outnam $spek_sndnam
				append outnam $evv(SNDFILE_EXT)
				set cmd [file join $evv(CDPROGRAM_DIR) submix]
				lappend cmd mix $mixfnam $outnam 
				set prg_dun 0
				set prg_abortd 0
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "Mixing of time-sequence failed"
					DeleteAllTemporaryFiles
					foreach outf $outfs {
						catch {file delete $outf}
					}
					catch {unset testedmaxspek}
					return 0
   				} else {
   					fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				if {!$prg_dun} {
					Inf "Mixing of sounds in time-sequence failed"
					DeleteAllTemporaryFiles
					foreach outf $outfs {
						catch {file delete $outf}
					}
					catch {unset testedmaxspek}
					return 0
				}
				if {![info exists testedmaxspek]} {
					FileToWkspace $outnam 0 0 0 0 1
					Inf "File $outnam is on the workspace"
				}
				DeleteAllTemporaryFiles
				set outlist {}
				if {$spekoutsstt > 0} {
					set outlist [lrange $spekouts 0 [expr $spekoutsstt - 1]]
				}
				lappend outlist $outnam
				set spekouts $outlist
			}
		}
		if {[info exists do_all_files] || ![info exists spk(vary)]} {
			set len [llength $spekouts]
			set outlist [ReverseList [lrange $spekouts $spekoutsstt end]]
			foreach outnam $outlist {
				FileToWkspace $outnam 0 0 0 0 1
				DummyHistory $outnam "CREATED"
			}
			Inf "Files are on the workspace"
		}
	}
	if {!$apply} {
		set thistransform [list SPEKSND $spek_sndharm $spek_sndbrite $spek_sndspred $spek_sndfrac $spek_sndatt $spek_sndtype $spek_sndgain]
		if {[info exists last_spektransform]} {
			set spektransform [lreplace $last_spektransform end end $thistransform]
			set last_spektransform $spektransform
		} else {
			lappend spektransform $thistransform
		}
	}
	if {![info exists testedmaxspek]} {
		RememberSpekouts
	}
	set spk(snd_created) 1
	CheckTransformStatus 0
	GetSpekOutputLevel
	if {[info exists testedmaxspek]} {
		Inf "Reset level in default transform\n\nthen return to data-files listing page and select complete data set\n"
		if {[info exists outlist]} {
			foreach fnam $outlist {
				catch {dile delete $fnam}
			}
		}
		unset testedmaxspek
	}
	return 1
}

#---- Get New Params for Sound Output

proc GetSpekSndParams {} {
	global pr_speksnd2 speksnddur speksndharm speksndbrite speksndgain speksndnam spk wstk evv
	global brrk_curvcnt last_spekouts spek_sndnam spek_sndharm spek_sndbrite spek_sndgain speksnd_got
	global spekapplysnd speksndfrac speksndatt spek_sndfrac spek_sndatt speksndspred spek_sndspred 
	global speksndtype spek_sndtype

	set speksndharm  $spek_sndharm
	set speksndbrite $spek_sndbrite
	set speksndspred $spek_sndspred
	set speksndfrac  $spek_sndfrac
	set speksndatt   $spek_sndatt
	set speksndgain  $spek_sndgain
	set speksndtype	 $spek_sndtype

	set f .speksnd2
	if [Dlg_Create $f "Sound output params" "set pr_speksnd2 0" -borderwidth 2 -width 80] {
		frame $f.0
		button $f.0.ok -text "Set Params" -command "set pr_speksnd2 1"  -highlightbackground [option get . background {}]
		button $f.0.qq -text "Abandon" -command "set pr_speksnd2 0"  -highlightbackground [option get . background {}]
		pack $f.0.ok -side left
		pack $f.0.qq -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		entry $f.1.e -textvariable speksnddur -width 12
		label $f.1.ll -text "Duration"
		pack $f.1.e $f.1.ll -side left -padx 2
		pack $f.1 -side top -fill x -expand true
		frame $f.2
		entry $f.2.e -textvariable speksndharm -width 12
		label $f.2.ll -text "No. of harmonics of the peak frqs to use (if any)"
		pack $f.2.e $f.2.ll -side left -padx 2
		pack $f.2 -side top -fill x -expand true
		frame $f.3
		entry $f.3.e -textvariable speksndbrite -width 12
		label $f.3.ll -text "Brightness of peak pitches (>0 to 1)"
		pack $f.3.e $f.3.ll -side left -padx 2
		pack $f.3 -side top -fill x -expand true
		frame $f.3z
		entry $f.3z.e -textvariable speksndspred -width 12
		label $f.3z.ll -text "Frequency spread of peaks (0 to 0.1)"
		pack $f.3z.e $f.3z.ll -side left -padx 2
		pack $f.3z -side top -fill x -expand true
		frame $f.3a
		entry $f.3a.e -textvariable speksndfrac -width 12
		label $f.3a.ll -text "Fraction of noise background fluctuating (0 to 1)"
		pack $f.3a.e $f.3a.ll -side left -padx 2
		pack $f.3a -side top -fill x -expand true
		frame $f.3b
		entry $f.3b.e -textvariable speksndatt -width 12
		label $f.3b.ll -text "Max attenuation of fluctuating background (0 to 1)"
		pack $f.3b.e $f.3b.ll -side left -padx 2
		pack $f.3b -side top -fill x -expand true
		frame $f.4a
		radiobutton $f.4a.0 -text "fixed brightness" -variable speksndtype -value 0
		radiobutton $f.4a.1 -text "width determines brightness" -variable speksndtype -value 1
		radiobutton $f.4a.2 -text "frq varies over pkwidth" -variable speksndtype -value 2
		radiobutton $f.4a.3 -text "harmonics also vary over pkwidth" -variable speksndtype -value 3
		radiobutton $f.4a.4 -text "peakwidth determines brightness : frq varies over pkwidth" -variable speksndtype -value 4
		radiobutton $f.4a.5 -text "peakwidth determines brightness : harmonics also vary over pkwidth" -variable speksndtype -value 5
		pack $f.4a.0 $f.4a.1 $f.4a.2 $f.4a.3 $f.4a.4 $f.4a.5 -side top -pady 2 -anchor w
		pack $f.4a -side top -fill x -expand true
		frame $f.4
		entry $f.4.e -textvariable speksndgain -width 12
		label $f.4.ll -text "Overall attenuation of output (.01 to 1)"
		pack $f.4.e $f.4.ll -side left -padx 2
		pack $f.4 -side top -fill x -expand true
		wm resizable $f 0 0
		bind $f.1.e  <Down> {focus .speksnd2.2.e}
		bind $f.2.e  <Down> {focus .speksnd2.3.e}
		bind $f.3.e  <Down> {focus .speksnd2.3z.e}
		bind $f.3z.e <Down> {focus .speksnd2.3a.e}
		bind $f.3a.e <Down> {focus .speksnd2.3b.e}
		bind $f.3b.e <Down> {focus .speksnd2.4.e}
		bind $f.4.e  <Down> {focus .speksnd2.1.e}
		bind $f.1.e  <Up>   {focus .speksnd2.4.e}
		bind $f.2.e  <Up>   {focus .speksnd2.1.e}
		bind $f.3.e  <Up>   {focus .speksnd2.2.e}
		bind $f.3z.e <Up>   {focus .speksnd2.3.e}
		bind $f.3a.e <Up>   {focus .speksnd2.3z.e}
		bind $f.3b.e <Up>   {focus .speksnd2.3a.e}
		bind $f.4.e  <Up>   {focus .speksnd2.3b.e}
		bind $f <Return> {set pr_speksnd2 1}
		bind $f <Escape> {set pr_speksnd2 0}
	}
	if {[info exists spk(vary)] && [info exists evv(VARISPEKDUR)]} {
		set speksnddur $evv(VARISPEKDUR)
	} elseif {![info exists spk(vary)] && [info exists evv(SPEKDUR)]} {
		set speksnddur $evv(SPEKDUR)
	} else {
		set speksnddur ""
	}
	set pr_speksnd2 0
	update idletasks
	raise $f
	My_Grab 0 $f pr_speksnd2 $f.2.e
	set finished 0
	while {!$finished} {
		tkwait variable pr_speksnd2
		if {$pr_speksnd2} {
			if {([string length $speksnddur] <= 0) || ![IsNumeric $speksnddur] || ($speksnddur < 0.5) || ($speksnddur > 3600.0)} {
				Inf "Invalid duration value"
				continue
			} elseif {[info exists spk(vary)]} {
				set evv(VARISPEKDUR) $speksnddur
			} else {
				set evv(SPEKDUR) $speksnddur
			}
			if {[string length $speksndharm] <= 0} {
				set spek_sndharm 0
			} elseif {![regexp {^[0-9]+$} $speksndharm] || ![IsNumeric $speksndharm]} {
				Inf "Invalid no. of harmonics"
				continue
			} else {
				set spek_sndharm $speksndharm
			}
			if {[string length $speksndbrite] <= 0} {
				set spek_sndbrite 0
			} elseif {![IsNumeric $speksndbrite] || ($speksndbrite <= 0.0) || ($speksndbrite > 1.0)} {
				Inf "Invalid brightness value"
				continue
			} else {
				set spek_sndbrite $speksndbrite
				if {[Flteq $spek_sndbrite 0.0]} {
					set spek_sndbrite 0
				}
			}
			if {[string length $speksndspred] <= 0} {
				set spek_sndspred 0
			} elseif {![IsNumeric $speksndspred] || ($speksndspred < 0.0) || ($speksndspred > 0.1)} {
				Inf "Invalid peak spread value"
				continue
			} else {
				set spek_sndspred $speksndspred
				if {[Flteq $spek_sndspred 0.0]} {
					set spek_sndspred 0
				}
			}
			if {[string length $speksndfrac] <= 0} {
				set spek_sndfrac 0
			} elseif {![IsNumeric $speksndfrac] || ($speksndfrac < 0.0) || ($speksndfrac > 1.0)} {
				Inf "Invalid fluctuation fraction"
				continue
			} else {
				set spek_sndfrac $speksndfrac
				if {[Flteq $spek_sndfrac 0.0]} {
					set spek_sndfrac 0
				}
			}
			if {[string length $speksndatt] <= 0} {
				set spek_sndatt 0
			} elseif {![IsNumeric $speksndatt] || ($speksndatt < 0.0) || ($speksndatt > 1.0)} {
				Inf "Invalid fluctuation attenuation"
				continue
			} else {
				set spek_sndatt $speksndatt
				if {[Flteq $spek_sndatt 0.0]} {
					set spek_sndatt 0
				}
			}
			if {[string length $speksndgain] <= 0} {
				set spek_sndgain 1
			} elseif {![IsNumeric $speksndgain] || ($speksndgain < 0.01) || ($speksndgain > 1.0)} {
				Inf "Invalid attenuation value"
				continue
			} else {
				set spek_sndgain $speksndgain
			}
			if {[Flteq $spek_sndgain 1.0]} {
				set spek_sndgain 1
			}
			set spekapplysnd 1
			set speksnd_got 1
			set spek_sndtype $speksndtype
			set finished 1
		} else {
			set msg "Use original parameters (otherwise proceed without sound generation) ?"
			set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				set spekapplysnd 0
			} else {
				set spekapplysnd 1
			}
			set speksnd_got 0
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#----- GET NAME FOR SOUND OUTFILE, WHEN WHOLE TRANSFORM SEQUENCE IS APPLIED

proc GetSpekSndName {} {
	global pr_speknam spek_sndnam speksndnam last_spekouts brrk_curvcnt wstk evv

	set speksnd_got 0
	set f .spekname
	if [Dlg_Create $f "Name for sound output" "set pr_speknam 0" -borderwidth 2 -width 80] {
		frame $f.0
		button $f.0.ok -text "Keep Name" -command "set pr_speknam 1"  -highlightbackground [option get . background {}]
		button $f.0.qq -text "Abandon" -command "set pr_speknam 0"  -highlightbackground [option get . background {}]
		pack $f.0.ok -side left
		pack $f.0.qq -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		entry $f.1.e -textvariable speksndnam -width 12
		label $f.1.ll -text "Name for output file"
		pack $f.1.e $f.1.ll -side left -padx 2
		pack $f.1 -side top -pady 2 -fill x -expand true
		wm resizable $f 0 0
		bind $f <Return> {set pr_speknam 1}
		bind $f <Escape> {set pr_speknam 0}
	}
	set pr_speknam 0
	ScreenCentre $f
	update idletasks
	raise $f
	My_Grab 0 $f pr_speknam $f.1.e
	set finished 0
	while {!$finished} {
		tkwait variable pr_speknam
		if {$pr_speknam} {
			if {[string length $speksndnam] <= 0} {
				Inf "No name entered for output sound"
				continue
			}
			set spek_sndnam [string tolower $speksndnam] 
			if {![ValidCDPRootname $spek_sndnam]} { 
				continue
			}
			if {$brrk_curvcnt > 1} {
				set kk 1
				set OK 1
				while {$kk <= $brrk_curvcnt} {
					set outnam $spek_sndnam
					append outnam $kk $evv(SNDFILE_EXT)
					if {[file exists $outnam]} {
						set msg "File $outnam already exists: overwrite it ??"
						set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							set OK 0
							break
						}
						if [catch {file delete $outnam} zit] { 
							Inf "Cannot delete existing file $spek_sndnam"
							set OK 0
							break
						} elseif {[info exists last_spekouts]} {
							set kj [lsearch $last_spekouts $outnam]
							while {$kj >= 0} {
								set last_spekouts [lreplace $last_spekouts $kj $kj]
								set kj [lsearch $last_spekouts $outnam]
							}
							if {[llength $last_spekouts] <= 0} {
								unset last_spekouts
							}
						}
					}
					incr kk
				}
				if {!$OK} {
					continue
				}
				set outnam $spek_sndnam
				append outnam $evv(SNDFILE_EXT)
				if {[file exists $outnam]} {
					set msg "File $outnam  already exists: overwrite it ??"
					set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
					if [catch {file delete $outnam} zit] { 
						Inf "Cannot delete existing file $outnam"
						continue
					}
				}
			} else {
				append spek_sndnam $evv(SNDFILE_EXT)
				if {[file exists $spek_sndnam]} {
					set msg "File $spek_sndnam already exists: overwrite it ??"
					set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
					if [catch {file delete $spek_sndnam} zit] { 
						Inf "Cannot delete existing file $spek_sndnam"
						continue
					} elseif {[info exists last_spekouts]} {
						set kj [lsearch $last_spekouts $spek_sndnam]
						while {$kj >= 0} {
							set last_spekouts [lreplace $last_spekouts $kj $kj]
							set kj [lsearch $last_spekouts $spek_sndnam]
						}
						if {[llength $last_spekouts] <= 0} {
							unset last_spekouts
						}
					}
				}
			}
			set speksnd_got 1
			set finished 1
		} else {
			set speksnd_got 0
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $speksnd_got
}

#----- Delete (various categories of) temporary files which are NOT outputs of CDP processes.

proc DeleteAllTemporaryFilesExcept {args} {
	global evv
	set outfname $evv(DFLT_OUTNAME)
	set fnams [glob -nocomplain "$outfname*"]
	foreach fnam $fnams {
		set dodelete 1
		foreach ifnam $args {
			if {[string match $fnam $ifnam]} {
				set dodelete 0
				break
			}
		}
		if {$dodelete} {
			catch {file delete -force $fnam}
		}
	}
}

#--- Trim silence at start and end of sound outputs from spectral-conversion

proc SpekTrim {} {
	global spekouts evv prg_dun prg_abortd CDPidrun
	set done 0
	set n 1
	Block "Trimming trailing silence"
	foreach fnam $spekouts {
		wm title .blocker  "PLEASE WAIT:      Trimming file $n"
		set outname($n) [file rootname $fnam]
		append outname($n) 000 $evv(SNDFILE_EXT)
		if {[file exists $outname($n)]} {
			if [catch {file detete $outname($n)} zit] {
				Inf "Cannot delete temporary intermediate file for sound $n"
				incr n
				continue
			}
		}
		set cmd [file join $evv(CDPROGRAM_DIR) housekeep]
		lappend cmd extract 3 $fnam $outname($n) -g0 -s0
		set prg_dun 0
		set prg_abortd 0
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "Silence trim failed for output $n"
			incr n
			continue
   		} else {
   			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			Inf "Failed to trim silence for output $n"
			incr n
			continue
		}
		incr done
		incr n
	}
	if {!$done} {
		UnBlock
		Inf "No silence trimmed"
		return
	}
	set lost 0
	set n 1
	foreach fnam $spekouts {
		if [file exists $outname($n)] {
			if [catch {file delete $fnam} zit] {
				Inf "Cannot replace output file $n with its trimmed version"
				incr done -1
			} elseif [catch {file rename $outname($n) $fnam} zit] {
				incr lost
				incr done -1
			} else {
				DoParse $fnam 0 0 0		;#	Establish new duration
			}
			catch {file delete $outname($n)}
		}
		incr n
	}
	if {$done <= 0} {
		UnBlock
		Inf "No silence trimmed"
		return
	}
	set msg ""
	if {$done != [llength $spekouts]} {
		append msg "Not all outputs succesfully trimmed\n\n"
	}
	if {$lost} {
		append msg "$lost output files lost in trimming process"
	}
	if {[string length $msg] > 0} {
		Inf $msg
	}
	UnBlock
}

#####################################
# DEAL WITH SCIENTIFIC DATA FORMATS #
#####################################

#--- Convert scientific data using "e" notation to standard numeric format

proc DataConvertor {} {
	global pr_dataconv dataconvskip dataconvpair dataconvnam dataconvxpct dataconvch chlist ch orig_brrk_range pa wstk evv

	if {![info exists chlist] || ([llength $chlist] < 1)} {
		Inf "Select text data files to process"
		return
	}
	set fnams $chlist
	set multiplefiles 0
	if {[llength $fnams] > 1} {
		set multiplefiles [llength $fnams]
	}
	foreach fnam $fnams {
		if {!($pa($fnam,$evv(FTYP)) & $evv(WORDLIST)) && !($pa($fnam,$evv(FTYP)) & $evv(LINELIST))} {
			Inf "file $fnam is not a text data file :select only text data files to process"
			return
		}
	}
	set tcl_precision 17
	set f .dataconv
	if [Dlg_Create $f "convert to numeric format" "set pr_dataconv 0" -borderwidth 2] {
		frame $f.0
		button $f.0.ok -text "Convert" -command "set pr_dataconv 1"  -highlightbackground [option get . background {}]
		button $f.0.qq -text "Abandon" -command "set pr_dataconv 0"  -highlightbackground [option get . background {}]
		pack $f.0.ok -side left
		pack $f.0.qq -side right
		pack $f.0 -side top -fill x -expand true
		label $f.1 -text "(Converts scientific e-notation to standard numeric format)" -fg $evv(SPECIAL) -width 80
		pack $f.1 -side top -pady 2
		frame $f.2
		entry $f.2.e -textvariable dataconvskip -width 12
		label $f.2.ll -text "Number of words to skip, at file start"
		pack $f.2.e $f.2.ll -side left -padx 2
		pack $f.2 -side top -pady 2 -fill x -expand true
		frame $f.3
		checkbutton $f.3.pof -variable dataconvpair -text "Pair off 1st column with each of others" -command DataExpectShow
		pack $f.3.pof -side left -padx 2
		pack $f.3 -side top -pady 2 -fill x -expand true
		frame $f.4
		entry $f.4.e -textvariable dataconvxpct -width 12
		label $f.4.ll -text "No of input data columns to expect"
		pack $f.4.e $f.4.ll -side left -padx 2
		pack $f.4 -side top -pady 2 -fill x -expand true
		frame $f.5
		entry $f.5.e -textvariable dataconvnam -width 24
		label $f.5.ll -text "Output filename(s)"
		pack $f.5.e $f.5.ll -side left -padx 2
		checkbutton $f.5.ch -variable dataconvch -text "Outfiles to Chosen File list"
		pack $f.5.ch -side right -padx 2
		pack $f.5 -side top -pady 2 -fill x -expand true
		wm resizable $f 0 0
		bind $f.2.e <Down> {focus .dataconv.5.e}
		bind $f.5.e <Down> {focus .dataconv.2.e}
		bind $f.2.e <Up> {focus .dataconv.5.e}
		bind $f.5.e <Up> {focus .dataconv.2.e}
		bind $f.4.e <Up>   {focus .dataconv.2.e}
		bind $f.4.e <Down> {focus .dataconv.5.e}
		bind $f <Return> "set pr_dataconv 1"
		bind $f <Escape> "set pr_dataconv 0"
	}
	set dataconvch 0
	if {$multiplefiles} {
		$f.3.pof config -text "" -command {} -bd 0
	} else {
		$f.3.pof config -text "Pair off 1st column with each of others" -command DataExpectShow
	}
	set dataconvskip 0
	set dataconvpair 0
	DataExpectShow
	set pr_dataconv 0
	update idletasks
	raise $f
	My_Grab 0 $f pr_dataconv $f.2.e
	set finished 0
	while {!$finished} {
		tkwait variable pr_dataconv
		if {$pr_dataconv} {
			if {![ValidCDPRootname $dataconvnam]} { 
				continue
			}
			set outnam [string tolower $dataconvnam]
			append outnam $evv(TEXT_EXT)
			if {!$dataconvpair && !$multiplefiles} {
				if {[file exists $outnam]} {
					Inf "File $outnam exists: choose a different name"
					continue
				}
			} elseif {$dataconvpair} {
				if {![regexp {^[0-9]+$} $dataconvxpct] || ($dataconvxpct < 1) || ($dataconvxpct > 100)} {
					Inf "Invalid input column count (range	1 - 100)"
					continue
				}
				set ofilcnt [expr $dataconvxpct - 1]
				set outnambas [file rootname $outnam]
				set k 1
				set OK 1
				while {$k <= $ofilcnt} {
					set thisoutnam $outnambas$k$evv(TEXT_EXT)
					if {[file exists $thisoutnam]} {
						Inf "file $thisoutnam exists: choose a different generic name"
						set OK 0
						break
					}
					incr k 
				}
				if {!$OK} {
					continue
				}
			} else {	;#	multiplefiles
				set ofilcnt $multiplefiles
				set outnambas [file rootname $outnam]
				set k 1
				set OK 1
				while {$k <= $ofilcnt} {
					set thisoutnam $outnambas$k$evv(TEXT_EXT)
					if {[file exists $thisoutnam]} {
						Inf "File $thisoutnam exists: choose a different generic name"
						set OK 0
						break
					}
					incr k 
				}
				if {!$OK} {
					continue
				}
			}
			if {![regexp {^[0-9]+$} $dataconvskip] || ($dataconvskip < 0) || ($dataconvskip > 1000)} {
				Inf "Invalid count of words to skip (range 0 - 1000)"
				continue
			}
#KLUDGE HERE
			set maxx -1000000
			set minx 1000000
			set maxy -1000000
			set miny 1000000
			catch {unset  pairedd}
			if {$dataconvpair || !$multiplefiles} {
				if [catch {open $fnam "r"} zit] {
					Inf "Cannot open file $fnam to read data"
					continue
				}
				catch {unset outvals}
				set OK 1
				set kcnt 1
				set skippedwords 0
				Block "Converting data from item 1"
				while {[gets $zit line] >= 0} {
					set line [string trim $line]
					set line [split $line]
					foreach item $line {
						set item [string trim $item]
						if {[string length $item] <= 0} {
							continue
						}
						if {$skippedwords < $dataconvskip} {
							incr skippedwords
							continue
						}
						incr kcnt
						if {[expr $kcnt % 1000] == 0} {
							wm title .blocker  "PLEASE WAIT:      Converting data from item $kcnt"
						}
						if {[IsNumeric $item]} {
							lappend outvals $item
						} else {
							set len [string length $item]
							set k 0
							set isneg 0
							catch {unset epos}
							catch {unset substr}
							catch {unset powstr}
							catch {unset pointpos}
							while {$k < $len} {
								set thischar [string index $item $k]
								if {![regexp {^[e0-9\.\-\+]+} $thischar]} {
									set OK 0
									break
								} elseif {[string match $thischar "e"]} {
									if {[info exists epos]} {
										set OK 0
										break
									}
									set epos $k
									set substr [string range $item 0 [expr $epos - 1]]
									if {![IsNumeric $substr]} {
										set OK 0
										break
									}
									set substr [StripLeadingZeros $substr]
								} elseif {[string match $thischar "-"]} {
									if {[info exists epos] && ([expr $epos + 1] == $k)} {
										set powstr [string range $item [expr $k + 1] end]
										if {![IsNumeric $powstr]} {
											set OK 0
											break
										}
										set powstr [StripLeadingZerosFromInteger $powstr]
										if {$isneg} {
											set substr [string range $substr 1 end]
											set val "-0."
										} else {
											set val "0."
										}
										set zeros [expr $powstr - 1]
										set zcnt 0
										while {$zcnt < $zeros} {
											append val "0"
											incr zcnt
										}
										if {[string match [string index $substr 0] "."]} {
											set zzz "0"
											append zzz $substr
											set substr $zzz
										}
										set substr [split $substr "."]
										append val [lindex $substr 0]
										if {[llength $substr] > 1} {
											append val [lindex $substr 1]
										}
										lappend outvals $val
									} elseif {$k == 0} {		;#		MINUS SIGN AT START GIVES -VE NUMBER
										set isneg 1
									} else {					;#		ANY OTHER MINUS SIGN MUST BE ERROR
										set OK 0
										break
									}
								} elseif {[string match $thischar "+"]} {
									if {[info exists epos] && ([expr $epos + 1] == $k)} {
										set powstr [string range $item [expr $k + 1] end]
										if {![IsNumeric $powstr]} {
											set OK 0
											break
										}
										set powstr [StripLeadingZerosFromInteger $powstr]	;#	01 --> 1
										if {$isneg} {
											set substr [string range $substr 1 end]
										}
										if {[string match [string index $substr 0] "."]} {
											set zzz "0"
											append zzz $substr
											set substr $zzz							;#	.73 --> 0.73
										}
										set slen [string length $substr]
										set j 0
										set gotpoint 0
										while {$j < $slen} {
											if {[string match [string index $substr $j] "."]} {
												set gotpoint 1
												break
											}
											incr j
										}
										if {!$gotpoint} {							;#	73e02
											set j 0
											while {$j < $powstr} {					;#	73 --> 7300
												append substr "0"
												incr j
											}
											set val $substr
											if {$isneg} {
												set nval "-"
												append nval $val
												set val $nval
											}
										} else {									;#	73.06		
											catch {unset after}
											set substr [split $substr "."]			;#	73   06
											set before [lindex $substr 0]
											if {[llength $substr] > 1} {
												set after [lindex $substr 1]
											}
											set j 0
											while {$j < $powstr} {
												if {[info exists after]} {					;#		73  (.)	06
													set thischar [string index $after 0]	;# -->	730 (.)  6
													append before $thischar					;# -->	7306
													if {[string length $after] > 1} {
														set after [string range $after 1 end]
													} else {
														unset after
													}
												} else {
													append before "0"						;# -->	73060
												}
												incr j
											}
											set val $before
											if {[info exists after]} {
												append val "." $after
											}
											if {$isneg} {
												set nval "-"
												append nval $val
												set val $nval
											}
										}
										lappend outvals $val
									} else {		;#		ANY OTHER PLUS SIGN IS INVALID
										set OK 0
										break
									}
								} elseif {[string match $thischar "."]} {
									if {[info exists pointpos] || [info exists epos]} {
										set OK 0
										break
									} else {
										set pointpos $k
									}
								}
								incr k
							}
							if {[info exists epos] && ![info exists powstr]} {		;#	"e" used but with incorrect syntax
								set OK 0
							}
						}
						if {!$OK} {
							Inf "Unrecognised entry '$item' in file [file rootname [file tail $fnam]]"
							break
						}
					}
					if {!$OK} {
						break
					}
				}
				close $zit
				if {![info exists outvals]} {
					Inf "No data retrieved from file"
					set OK 0
				}
				if {!$OK} {
					UnBlock
					continue
				}
				if {$dataconvpair} {
					set len [llength $outvals]
					if {[expr $len % $dataconvxpct] !=0} {
						Inf "Number of entries ($len) in input data does not tally with expected number of columns ($dataconvxpct)"
						UnBlock
						continue
					}
					set k 0
					while {$k < $len} {
						set j 0
						while {$j < $dataconvxpct} {
							lappend ovals($j) [lindex $outvals $k]
							incr k
							incr j
						}
					}
					set k 1
					while {$k <= $ofilcnt} {
						set thisoutnam $outnambas$k$evv(TEXT_EXT)
						wm title .blocker  "PLEASE WAIT:      Writing new data to file $thisoutnam"
						if [catch {open $thisoutnam "w"} zit] {
							Inf "Cannot open file $thisoutnam to write data"
						} else {
							foreach val1 $ovals(0) val2 $ovals($k) {
								set val [list $val1 $val2]
								puts $zit $val
							}
							close $zit
							FileToWkspace $thisoutnam 0 0 0 0 1
							DummyHistory $thisoutnam "CREATED"
						}
						incr k
					}
				} else {
					if [catch {open $outnam "w"} zit] {
						Inf "Cannot open file $outnam to write data"
						continue
					}
					wm title .blocker  "PLEASE WAIT:      Writing new data to file $outnam"
					set pairedd 1
					foreach {val1 val2} $outvals {
						if {$val1 > $maxx} {
							set maxx $val1
						}
						if {$val1 < $minx} {
							set minx $val1
						}
						if {$val2 > $maxy} {
							set maxy $val2
						}
						if {$val2 < $miny} {
							set miny $val2
						}
						set val [list $val1 $val2]
						puts $zit $val
					}
					close $zit
					FileToWkspace $outnam 0 0 0 0 1
					DummyHistory $outnam "CREATED"
				}
			} else {
				set kk 1
				Block "Converting data from files"
				foreach fnam $fnams {
					if [catch {open $fnam "r"} zit] {
						Inf "Cannot open file [file rootname [file tail $fnam]] to read data"
						incr kk
						continue
					}
					catch {unset outvals}
					set OK 1
					set kcnt 1
					set skippedwords 0
					wm title .blocker  "PLEASE WAIT:      Converting data from file [file rootname [file tail $fnam]]"
					while {[gets $zit line] >= 0} {
						set line [string trim $line]
						set line [split $line]
						set cccnt 0
						foreach item $line {
							set item [string trim $item]
							if {[string length $item] <= 0} {
								continue
							}
							if {$skippedwords < $dataconvskip} {
								incr skippedwords
								continue
							}
							incr kcnt
							if {[IsNumeric $item]} {
								lappend outvals $item
							} else {
								set len [string length $item]
								set k 0
								set isneg 0
								catch {unset epos}
								catch {unset substr}
								catch {unset powstr}
								catch {unset pointpos}
								while {$k < $len} {
									set thischar [string index $item $k]
									if {![regexp {^[e0-9\.\-\+]+} $thischar]} {
										set OK 0
										break
									} elseif {[string match $thischar "e"]} {
										if {[info exists epos]} {
											set OK 0
											break
										}
										set epos $k
										set substr [string range $item 0 [expr $epos - 1]]
										if {![IsNumeric $substr]} {
											set OK 0
											break
										}
										set substr [StripLeadingZeros $substr]
									} elseif {[string match $thischar "-"]} {
										if {[info exists epos] && ([expr $epos + 1] == $k)} {
											set powstr [string range $item [expr $k + 1] end]
											if {![IsNumeric $powstr]} {
												set OK 0
												break
											}
											set powstr [StripLeadingZerosFromInteger $powstr]
											if {$isneg} {
												set substr [string range $substr 1 end]
												set val "-0."
											} else {
												set val "0."
											}
											set zeros [expr $powstr - 1]
											set zcnt 0
											while {$zcnt < $zeros} {
												append val "0"
												incr zcnt
											}
											if {[string match [string index $substr 0] "."]} {
												set zzz "0"
												append zzz $substr
												set substr $zzz
											}
											set substr [split $substr "."]
											append val [lindex $substr 0]
											if {[llength $substr] > 1} {
												append val [lindex $substr 1]
											}
											lappend outvals $val
										} elseif {$k == 0} {		;#		MINUS SIGN AT START GIVES -VE NUMBER
											set isneg 1
										} else {					;#		ANY OTHER MINUS SIGN MUST BE ERROR
											set OK 0
											break
										}
									} elseif {[string match $thischar "+"]} {
										if {[info exists epos] && ([expr $epos + 1] == $k)} {
											set powstr [string range $item [expr $k + 1] end]
											if {![IsNumeric $powstr]} {
												set OK 0
												break
											}
											set powstr [StripLeadingZerosFromInteger $powstr]	;#	01 --> 1
											if {$isneg} {
												set substr [string range $substr 1 end]
											}
											if {[string match [string index $substr 0] "."]} {
												set zzz "0"
												append zzz $substr
												set substr $zzz							;#	.73 --> 0.73
											}
											set slen [string length $substr]
											set j 0
											set gotpoint 0
											while {$j < $slen} {
												if {[string match [string index $substr $j] "."]} {
													set gotpoint 1
													break
												}
												incr j
											}
											if {!$gotpoint} {							;#	73e02
												set j 0
												while {$j < $powstr} {					;#	73 --> 7300
													append substr "0"
													incr j
												}
												set val $substr
												if {$isneg} {
													set nval "-"
													append nval $val
													set val $nval
												}
											} else {									;#	73.06		
												catch {unset after}
												set substr [split $substr "."]			;#	73   06
												set before [lindex $substr 0]
												if {[llength $substr] > 1} {
													set after [lindex $substr 1]
												}
												set j 0
												while {$j < $powstr} {
													if {[info exists after]} {					;#		73  (.)	06
														set thischar [string index $after 0]	;# -->	730 (.)  6
														append before $thischar					;# -->	7306
														if {[string length $after] > 1} {
															set after [string range $after 1 end]
														} else {
															unset after
														}
													} else {
														append before "0"						;# -->	73060
													}
													incr j
												}
												set val $before
												if {[info exists after]} {
													append val "." $after
												}
												if {$isneg} {
													set nval "-"
													append nval $val
													set val $nval
												}
											}
											lappend outvals $val
										} else {		;#		ANY OTHER PLUS SIGN IS INVALID
											set OK 0
											break
										}
									} elseif {[string match $thischar "."]} {
										if {[info exists pointpos] || [info exists epos]} {
											set OK 0
											break
										} else {
											set pointpos $k
										}
									}
									incr k
								}
								if {[info exists epos] && ![info exists powstr]} {		;#	"e" used but with incorrect syntax
									set OK 0
								}
							}
							if {!$OK} {
								Inf "Unrecognised entry '$item' in file [file rootname [file tail $fnam]]"
								break
							}
							incr cccnt
						}
						if {!$OK} {
							break
						}
						lappend cccnts $cccnt
					}
					close $zit
					if {![info exists outvals]} {
						Inf "No data retrieved from file $fnam"
						incr kk
						continue
					}
					if {!$OK} {
						incr kk
						continue
					}
					set irregular 0
					set icnt [lindex $cccnt 0]
					foreach cccnt [lrange $cccnts 1 end] {
						if {$cccnt != $icnt} {
							set irregular 1
							break
						}
					}
					if {!$irregular && ($icnt == 2)} {
						set paireddd 1
						foreach {val1 val2} $outvals {
							if {$val1 > $maxx} {
								set maxx $val1
							}
							if {$val1 < $minx} {
								set minx $val1
							}
							if {$val2 > $maxy} {
								set maxy $val2
							}
							if {$val2 < $miny} {
								set miny $val2
							}
						}
					}
					set outnambas [file rootname $outnam]
					set thisoutnam $outnambas$kk$evv(TEXT_EXT)
					if [catch {open $thisoutnam "w"} zit] {
						Inf "Cannot open file $thisoutnam to write data"
						incr kk
						continue
					}
					wm title .blocker  "PLEASE WAIT:      Writing new data to file $thisoutnam"
					set out_cnt [llength $outvals]
					set jjjj 0
					set kkkk 0
					set mmmm 0
					while {$kkkk < $out_cnt} {
						set nuline {}
						set jjjj 0
						while {$jjjj < [lindex $cccnts $mmmm]} {
							lappend nuline [lindex $outvals $kkkk]
							incr kkkk
							incr jjjj
							if {$kkkk > $out_cnt} {
								break
							}
						}
						puts $zit $nuline
						incr mmmm
					}
					close $zit
					lappend out_nams $thisoutnam
					DummyHistory $thisoutnam "CREATED"
					incr kk
				}
				if {[info exists out_nams]} {
					wm title .blocker  "PLEASE WAIT:      Placing new files on workspace"
					set out_nams [ReverseList $out_nams]
					foreach fnam $out_nams {
						FileToWkspace $fnam 0 0 0 0 1
					}
					if {$dataconvch} {
						set out_nams [ReverseList $out_nams]
						DoChoiceBak
						set chlist $out_nams
						$ch delete 0 end
						foreach fnam $chlist {
							$ch insert end $fnam
						}
					}
				}
			}
			UnBlock
			Inf "New data file(s) on the workspace"
			if {[info exists pairedd]} {
				set msg "Save data ranges ?"
				set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
				if {$choice == "yes"} {
					if {$minx > 0} {
						set minx 0
					}
					if {$miny > 0} {
						set miny 0
					}
					set orig_brrk_range [list $miny $maxy $minx $maxx ]
				}
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	set tcl_precision 6
}

#--- Convert data using 1 list of frqs, followed by lists of amps at successive times, to frq/amp pairs

proc CosmicConvertor {} {
	global pr_cosmicconv cosmicconvskip cosmicconvnam cosmicconvch chlist ch orig_brrk_range pa wstk evv

	if {![info exists chlist] || ([llength $chlist] < 1)} {
		Inf "Select a text data files to process"
		return
	}
	if {[llength $chlist] != 1} {
		Inf "Select a single text data file"
		return
	}
	set infnam [lindex $chlist 0]
	if {!($pa($infnam,$evv(FTYP)) & $evv(WORDLIST)) && !($pa($infnam,$evv(FTYP)) & $evv(LINELIST))} {
		Inf "File $infnam is not a text data file :select only text data file to process"
		return
	}
	set tcl_precision 17
	set f .cosmicconv
	if [Dlg_Create $f "Convert to frq/amp format" "set pr_cosmicconv 0" -borderwidth 2] {
		frame $f.0
		button $f.0.ok -text "Convert" -command "set pr_cosmicconv 1" -highlightbackground [option get . background {}]
		button $f.0.qq -text "Abandon" -command "set pr_cosmicconv 0" -highlightbackground [option get . background {}]
		pack $f.0.ok -side left
		pack $f.0.qq -side right
		pack $f.0 -side top -fill x -expand true
		label $f.1 -text "(Converts 1 list of frqs, and several lists of amps to set of frq/amp files)" -fg $evv(SPECIAL) -width 80
		pack $f.1 -side top -pady 2
		frame $f.2
		entry $f.2.e -textvariable cosmicconvskip -width 12
		label $f.2.ll -text "Number of (non-empty) lines to skip, at file start"
		pack $f.2.e $f.2.ll -side left -padx 2
		pack $f.2 -side top -pady 2 -fill x -expand true
		frame $f.3
		entry $f.3.e -textvariable cosmicconvnam -width 24
		label $f.3.ll -text "Generic outputfile name "
		pack $f.3.e $f.3.ll -side left -padx 2
		checkbutton $f.3.ch -variable cosmicconvch -text "Outfiles to Chosen File list"
		pack $f.3.ch -side right -padx 2
		pack $f.3 -side top -pady 2 -fill x -expand true
		wm resizable $f 0 0
		bind $f.2.e <Down> {focus .cosmicconv.3.e}
		bind $f.3.e <Down> {focus .cosmicconv.2.e}
		bind $f.2.e <Up> {focus .cosmicconv.3.e}
		bind $f.3.e <Up> {focus .cosmicconv.2.e}
		bind $f <Return> "set pr_cosmicconv 1"
		bind $f <Escape> "set pr_cosmicconv 0"
	}
	set cosmicconvch 0
	set cosmicconvskip 0
	set pr_cosmicconv 0
	update idletasks
	raise $f
	My_Grab 0 $f pr_cosmicconv $f.3.e
	set finished 0
	while {!$finished} {
		tkwait variable pr_cosmicconv
		if {$pr_cosmicconv} {
			set OK 1
			if {![info exists times]} {
				set timecnt 0
				if {[string length $cosmicconvskip] <= 0} {
					set cosmicconvskip 0
				} elseif {![regexp {^[0-9]+$} $cosmicconvskip]} {
					Inf "Invalid number of lines to skip"
					continue
				}
				if [catch {open $infnam "r"} zit] {
					Inf "Cannot open file [file tail $infnam] to read data"
					continue
				}
				Block "Converting Data"
				set abslinecnt 1
				set linecnt -2
				while {[gets $zit line] >= 0} {
					set line [string trim $line]
					if {[string length $line] <= 0} {
						continue
					}
					if {$abslinecnt <= $cosmicconvskip} {
						incr abslinecnt
						continue
					}
					set line [split $line]
					set cnt 0
					foreach item $line {
						set item [string trim $item]
						if {[string length $item] <= 0} {
							continue
						}
						if {![IsNumeric $item] || ($item < 0.0)} {
							Inf "Invalid data on line $abslinecnt"
							set OK 0
							break
						}
						switch -- $linecnt {
							"-2" {
								if {$cnt == 0} {
									if {$item < 0.0} {
										Inf "Invalid firsttime on time line (1st)"
										set OK 0
										break
									}								
								} elseif {$item <= $lasttime} {
									Inf "time data item [expr $cnt + 1] ($item) (in first line) not in ascending order"
									set OK 0
									break
								}
								set lasttime $item
								lappend times $item
							}
							"-1" {
								if {$cnt == 0} {
									if {$item < 0.0} {
										Inf "Invalid first frequency on frequency line (2nd)"
										set OK 0
										break
									}								
								} elseif {$item <= $lastfrq} {
									Inf "Frequency data item [expr $cnt + 1] ($item) (in second line) not in ascending order"
									set OK 0
									break
								}								
								set lastfrq $item
								lappend frqs $item
							}
							default {
								lappend amps($linecnt) $item
							}
						}
						incr cnt
					}
					if {!$OK} {
						break
					}
					switch -- $linecnt {
						"-2" {
							if {![info exists times]} {
								Inf "No (first line) time data found"
								set OK 0
							} else {
								set timecnt [llength $times]
							}
						}
						"-1" {
							if {![info exists frqs]} {
								Inf "No (first line) frequency data found"
								set OK 0
							} else {
								set frqcnt [llength $frqs]
							}
						}
						0 {
							if {![info exists amps($linecnt)]} {
								Inf "No amplitudes found on line $abslinecnt"
								set OK 0
							} elseif {[llength $amps($linecnt)] != $frqcnt} {
								Inf "Amplitudes list on line $abslinecnt is wrong length ([llength $amps($linecnt)]): should be $frqcnt"
								set OK 0
							}
						}
					}
					if {!$OK} {
						break
					}
					incr linecnt
					incr abslinecnt
				}
				close $zit
				if {!$OK} {
					UnBlock
					break
				}
				if {$linecnt != $timecnt} {
					Inf "No of amplitude-lines ($linecnt) does not correspond with number of times ($timecnt)"
					UnBlock
					break
				}
			}
			if {![ValidCDPRootname $cosmicconvnam]} { 
				continue
			}
			set outnambas [string tolower $cosmicconvnam]
			set OK 1
			set n 0
			catch {unset outnams}
			while {$n < $timecnt} {
				set timindx [lindex $times $n]
				set timindx [split $timindx "."]
				if {[llength $timindx] > 1} {
					set zog [lindex $timindx 1]
					if {$zog != 0} {
						set timindx [join $timindx "p"]
					} else {
						set timindx [lindex $timindx 0]
					}
				}
				set outnam $outnambas
				append outnam $timindx $evv(TEXT_EXT)
				if {[file exists $outnam]} {
					Inf "File $outnam already exists: please choose a different generic name"
					set OK 0
					break
				}
				lappend outnams $outnam
				incr n
			}
			if {!$OK} {
				UnBlock
				continue
			}
			if {[winfo exists .blocker]} {
				wm title .blocker "PLEASE WAIT:       Writing data"
			} else {
				Block "Writing Data"
			}
			set n 0
			catch {unset lines}
			while {$n < $timecnt} {
				set k 0
				foreach frq $frqs amp $amps($n) {
					set line [list $frq $amp]
					lappend lines($n) $line
					incr k
				}
				incr n
			}
			catch {unset goodfiles}
			catch {unset badfiles}
			set n 0
			foreach outnam $outnams {
				if [catch {open $outnam "w"} zit] {
					incr n
					Inf "Cannot open file $outnam to write data set $n"
					set badfiles 1
					continue
				}
				wm title .blocker "PLEASE WAIT:       Writing file $outnam"
				foreach line $lines($n) {
					puts $zit $line
				}
				lappend goodfiles $outnam
				close $zit
				incr n
			}
			if {![info exists goodfiles]} {
				Inf "No data was written to files"
				UnBlock
				continue
			}
			if {[info exists badfiles]} {
				Inf "Not all data was written to files (see file numbering to check for missing data)"
			}
			set goodfiles [ReverseList $goodfiles]
			foreach fnam $goodfiles {
				FileToWkspace $fnam 0 0 0 0 1
			}
			if {$cosmicconvch} {
				set goodfiles [ReverseList $goodfiles]
				DoChoiceBak
				set chlist $goodfiles
				$ch delete 0 end
				foreach fnam $chlist {
					$ch insert end $fnam
				}
			}
			UnBlock
			Inf "Frq/amp data files on on the workspace"
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	set tcl_precision 6
}

proc DataExpectShow {} {
	global dataconvpair dataconvxpct
	switch -- $dataconvpair {
		0 {
			.dataconv.4.e config -state disabled -bd 0 -disabledbackground [option get . background {}]
			.dataconv.4.ll  config -text ""
			bind .dataconv.2.e <Down> {}
			bind .dataconv.2.e <Down> {focus .dataconv.5.e}
			bind .dataconv.5.e <Up> {}
			bind .dataconv.5.e <Up> {focus .dataconv.2.e}
			set dataconvxpct ""
		} 
		1 {
			.dataconv.4.e config -state normal -bd 2
			.dataconv.4.ll  config -text "No of input data columns to expect"
			bind .dataconv.2.e <Down> {}
			bind .dataconv.2.e <Down> {focus .dataconv.4.e}
			bind .dataconv.5.e <Up> {}
			bind .dataconv.5.e <Up> {focus .dataconv.4.e}
		}
	}
}

#####################################################
#													#
#	SEE AND HEAR SPECTRA GENERATED, ON WORKSPACE	#
#													#
#####################################################

proc SpectralDataToSoundCompare {} {
	global last_spekouts pr_spekshow spekshowlist pa evv
	if {![info exists last_spekouts]} {
		Inf "No generated sounds saved"
		return
	}
	foreach fnam $last_spekouts {
		if {![file exists $fnam]} {
			lappend badfiles $fnam
		} elseif {![info exists pa($fnam,$evv(DUR))]} {
			if {[FileToWkspace $fnam 0 0 0 1 0]} {
				lappend spekshowing $fnam
			}
		} else {
			lappend spekshowing $fnam
		}
	}
	if {[info exists badfiles]} {
		set msg "The following files no longer exist\n"
		set cnt 0
		foreach fnam $badfiles {
			append msg "$fnam\n"
			incr cnt
			if {$cnt >= 20} {
				append msg "and more"
				break
			}
		}
		Inf $msg
		foreach fnam $badfiles {
			set k [lsearch $last_spekouts $fnam]
			while {$k >= 0} {
				set last_spekouts [lreplace $last_spekouts $k $k]
				set k [lsearch $last_spekouts $fnam]
			}
		}
		if {[llength $last_spekouts] <= 0} {
			unset last_spekouts
			catch {unset spekshowing}
		}
	}
	if {![info exists spekshowing]} {
		return
	}
	set f .spekshow
	if [Dlg_Create $f "Hear generated sounds" "set pr_spekshow 0" -borderwidth 2 -width 80] {
		frame $f.0
		button $f.0.ok -text "Play Selected" -command "set pr_spekshow 1" -highlightbackground [option get . background {}]
		button $f.0.qq -text "Quit" -command "set pr_spekshow 0" -highlightbackground [option get . background {}]
		pack $f.0.ok -side left
		pack $f.0.qq -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.2
		button $f.2.b1 -text "Select All" -command AllSpekShowSelect -width 14 -highlightbackground [option get . background {}]
		button $f.2.b2 -text "Move To Top" -command SpekShowMove -width 14 -highlightbackground [option get . background {}]
		button $f.2.b3 -text "Reverse Order" -command SpekShowReverse -width 14 -highlightbackground [option get . background {}]
		button $f.2.b4 -text "Delete Files" -command SpekShowDelete -width 14 -highlightbackground [option get . background {}]
		pack $f.2.b1 $f.2.b2 $f.2.b3 $f.2.b4 -side left -padx 2
		pack $f.2 -side top -pady 2
		frame $f.3
		label $f.3.tit -text "Select sounds to play, with mouse" -fg $evv(SPECIAL)
		set spekshowlist [Scrolled_Listbox $f.3.ll -width 64 -height 32 -selectmode extended]
		pack $f.3.tit $f.3.ll -side top -pady 2
		pack $f.3 -side top -fill both -expand true
		bind $f <Return> {set pr_spekshow 1}
		bind $f <Escape> {set pr_spekshow 0}
		wm resizable $f 0 0
	}
	$spekshowlist delete 0 end
	foreach fnam $spekshowing {
		$spekshowlist insert end $fnam
	}
	set pr_spekshow 0
	update idletasks
	raise $f
	My_Grab 0 $f pr_spekshow $spekshowlist
	set finished 0
	while {!$finished} {
		tkwait variable pr_spekshow
		if {$pr_spekshow} {
			if {[$spekshowlist index end] == 1} {
				PlaySndfile [$spekshowlist get 0] 0
			} else {
				set ilist [$spekshowlist curselection]
				if {![info exists ilist] || ([llength $ilist] <= 0) || (([llength $ilist] == 1) && ($ilist == -1))} {
					Inf "No sounds selected"
					continue
				}
				if {[llength $ilist] == 1} {
					PlaySndfile [$spekshowlist get [lindex $ilist 0]] 0
				} else {
					set ilist [lsort -integer $ilist]
					ConcatSpekFilesPlay $ilist
				}
			}
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}


proc AllSpekShowSelect {} {
	global spekshowlist
	$spekshowlist selection set 0 end 
}

proc SpekShowMove {} {
	global spekshowlist
	set ilist [$spekshowlist curselection]
	if {![info exists ilist] || ([llength $ilist] <= 0) || (([llength $ilist] == 1) && ($ilist == -1))} {
		Inf "No sounds selected"
		return
	}
	set ilist [lsort -integer $ilist]
	foreach i $ilist {
		lappend nulist [$spekshowlist get $i]
	}
	set len [$spekshowlist index end]
	set i 0
	while {$i < $len} {
		if {[lsearch $ilist $i] < 0} {
			lappend nulist [$spekshowlist get $i]
		}
		incr i
	}
	$spekshowlist delete 0 end
	foreach fnam $nulist {
		$spekshowlist insert end $fnam
	}
}

proc SpekShowReverse {} {
	global spekshowlist
	set ilist [$spekshowlist curselection]
	if {![info exists ilist] || ([llength $ilist] <= 0) || (([llength $ilist] == 1) && ($ilist == -1))} {
		Inf "No sounds selected"
		return
	}
	if {[llength $ilist] == 1} {
		return
	}
	set ilist [lsort -integer $ilist]
	foreach i $ilist {
		lappend fnams [$spekshowlist get $i]
	}
	set fnams [ReverseList $fnams]
	set fcnt [llength $fnams]
	set len [$spekshowlist index end]
	set i 0
	set cnt 0
	while {$i < $len} {
		if {[lsearch $ilist $i] >= 0} {
			$spekshowlist delete $i
			$spekshowlist insert $i [lindex $fnams $cnt]
			incr cnt
			if {$cnt >= $fcnt} {
				break
			}
		}
		incr i
	}
}

proc SpekShowDelete {} {
	global spekshowlist wstk wl rememd pr_spekshow
	set ilist [$spekshowlist curselection]
	if {![info exists ilist] || ([llength $ilist] <= 0) || (([llength $ilist] == 1) && ($ilist == -1))} {
		Inf "No sounds selected"
		return
	}
	set msg "Are you sure you want to permanently delete these files ?"
	set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
	if {$choice == "no"} {
		return
	}
	set ilist [lsort -integer $ilist]
	set jlist [ReverseList $ilist]
	foreach j $jlist {
		set fnam [$spekshowlist get $j]
		if {[DeleteFileFromSystem $fnam 1 1]} {
			if {[IsInAMixfile $fnam]} {
				lappend delete_mixmanage $fnam
			}
			set i [LstIndx $fnam $wl]	;#	remove from workspace listing, if there
			if {$i >= 0} {
				$wl delete $i
				WkspCnt $fnam -1
				catch {unset rememd}
			}
			$spekshowlist delete $j
		}
	}
	if {[info exists delete_mixmanage]} {
		MixM_ManagedDeletion $delete_mixmanage
		MixMStore
	}
	if {[$spekshowlist index end] <= 0} {
		set pr_spekshow 0
	}
}

proc ConcatSpekFilesPlay {ilist} {
	global spekshowlist wstk pa CDPidrun prg_dun evv playcmd_dummy

	foreach i $ilist {
		lappend fnams [$spekshowlist get $i]
	}
	set totdur 0
	foreach fnam $fnams {
		set dur $pa($fnam,$evv(DUR))
		set chans $pa($fnam,$evv(CHANS))
		set line $fnam
		append line " " $totdur " " $chans " 1"
		lappend mixlines $line
		set totdur [expr $totdur + $dur + 0.2]
	}
	set mfile $evv(DFLT_OUTNAME)
	set ofile $evv(DFLT_OUTNAME)
	append mfile "0" $evv(TEXT_EXT)
	append ofile "0" $evv(SNDFILE_EXT)
	set prg_dun 0
	Block "Joining Files"
	if [catch {open $mfile "w"} zit] {
		Inf "Cannot make temporary mixfile"
		UnBlock
		return
	}
	foreach line $mixlines {
		puts $zit $line
	}
	close $zit
	set cmd [file join $evv(CDPROGRAM_DIR) "submix"]
	lappend cmd "mix" $mfile $ofile

	if [catch {open "|$cmd"} CDPidrun] {
		Inf "CANNOT MAKE TEMPORARY MIX"
		DeleteAllTemporaryFiles
		UnBlock
		return
	} else {
	   	fileevent $CDPidrun readable "Run_With_No_Messages"
	}
	vwait prg_dun
	UnBlock
	if {!$prg_dun} {
		set line "Cannot make temporary mix"
	} elseif {[file exists $ofile]} {
		set choice "yes"
		set msg "Hear it again ?"
		while {$choice == "yes"} {
			PlaySndfile $ofile 0			;# PLAY OUTPUT
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		}
		if {$playcmd_dummy != "pvplay"} {
			Inf "If there is a play-program display\nyou must close it before proceeding!!"
		}
	}
	DeleteAllTemporaryFiles
}

###################################
#								  #
# REMEMBERING THE SOUNDS CREATED  #
#								  #
###################################

proc RememberSpekouts {} {
	global spekouts last_spekouts wstk evv
	if {![info exists spekouts]} {
		return
	}
	set msg "Remember the newly created sounds (add to a listing) ?"
	set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
	if {$choice == "no"} {
		return
	}
	set dodelete 1
	if {[info exists last_spekouts]} {
		set msg "Append the newly created sounds to the existing sound list ?"
		set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			set dodelete 0
			foreach thisfnam $spekouts {
				if {[lsearch  $last_spekouts $thisfnam] >= 0} {
					set msg "Sounds with (some of) these names are already in the remembered list\n\ndelete ~~all~~ previously remembered files ?"
					set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						set dodelete 1
						break
					} else {
						set msg "Delete just the files with the same names ?"
						set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
						if {$choice == "yes"} {
							set dodelete 2
						} else {
							set msg "Continue with this backup ?"
							set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
							if {$choice == "no"} {
								return
							}
						}
					}
					break
				}
			}
		}
	}
	switch -- $dodelete {
		0 {
			set last_spekouts [concat $last_spekouts $spekouts]
		}
		1 {
			set last_spekouts $spekouts
		}
		2 {
			foreach thisfnam $spekouts {
				set k [lsearch $last_spekouts $thisfnam]
				if {$k >= 0} {
					set last_spekouts [lreplace $last_spekouts $k $k]
				}
			}
			set last_spekouts [concat $last_spekouts $spekouts]
		}
	}
	if {[llength $last_spekouts] <= 0} {
		unset last_spekouts
	}
}	

proc SaveSpekouts {} {
	global last_spekouts orig_spekouts wstk evv
	if {![info exists last_spekouts]} {
		return
	}
	set dosave 1
	if {[info exists orig_spekouts] && ([llength $last_spekouts] == [llength $orig_spekouts])} {
		set dosave 0
		foreach orig $orig_spekouts last $last_spekouts {
			if {![string match $orig $last]} {
				set dosave 1
				break
			}
		}
	}	
	if {!$dosave} {
		return
	}
	set evv(SPEKDIR) [file join $evv(URES_DIR) spek]
	set fnam [file join $evv(SPEKDIR) scisnds$evv(CDP_EXT)]
	if [catch {open  $fnam "w"} zit] {
		Inf "Cannot open file to remember sounds created in data conversion"
		return
	}
	foreach zfnam $last_spekouts {
		puts $zit $zfnam
	}
	close $zit
}

proc LoadSpekouts {} {
	global last_spekouts orig_spekouts wstk evv
	set fnam [file join $evv(SPEKDIR) scisnds$evv(CDP_EXT)]
	if {![file exists $fnam]} {
		return
	}
	if [catch {open  $fnam "r"} zit] {
		Inf "Cannot open file to read list of sounds created in previous data conversion"
		return
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {![file exists $line]} {
			lappend badfiles $line
		} else {
			lappend last_spekouts $line
			lappend orig_spekouts $line
		}
	}
	close $zit
	if {![info exists last_spekouts]} {
		Inf "None of the files previously created in data conversion exist"
		catch {file delete $fnam}
		return
	} elseif {[info exists badfiles]} {
		set msg "The following files, previously created in data conversion, no longer exist\n"
		set cnt 0
		foreach zfnam $badfiles {
			append msg "$zfnam\n"
			incr cnt
			if {$cnt >= 20} {
				append msg "and more\n"
				break
			}
		}
		append msg "\nDo you wish to retain the list of remaining files ?"
		set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			catch {unset last_spekouts}		 
			catch {unset orig_spekouts}
			catch {file delete $fnam}
		}
	}
}

################################################################
#															   #
#	KEEPING TABS ON DATA WHEN NAMES CHANGED OR FILES BACKED UP #
#															   #
################################################################

proc DataManage {typ args} {
	global last_spekouts spekouts data_released evv
	if {!$data_released} {
		return
	}
	if {$typ == "update"} {
		set fnam [lindex $args 0]
		set ftyp [FindFileType $fnam]
		if {$ftyp != $evv(SNDFILE)} {
			set typ "delete"
		}
	}
	switch -- $typ {
		delete {
			set fnam [lindex $args 0]
			if {[info exists last_spekouts]} {
				set k [lsearch $last_spekouts $fnam]
				while {$k >= 0} {
					set last_spekouts [lreplace $last_spekouts $k $k]
					set k [lsearch $last_spekouts $fnam]
				}
				if {[llength $last_spekouts] <= 0} {
					unset last_spekouts
				}
			}
			if {[info exists spekouts]} {
				set k [lsearch $spekouts $fnam]
				while {$k >= 0} {
					set spekouts [lreplace $spekouts $k $k]
					set k [lsearch $spekouts $fnam]
				}
				if {[llength $spekouts] <= 0} {
					unset spekouts
				}
			}
		}
		rename {
			set fnam1 [lindex $args 0]
			set fnam2 [lindex $args 1]
			if {[info exists last_spekouts]} {
				set k [lsearch $last_spekouts $fnam2]
				while {$k >= 0} {
					set last_spekouts [lreplace $last_spekouts $k $k]
					set k [lsearch $last_spekouts $fnam2]
				}
				if {[llength $last_spekouts] <= 0} {
					unset last_spekouts
				} else {
					set k [lsearch $last_spekouts $fnam1]
					while {$k >= 0} {
						set last_spekouts [lreplace $last_spekouts $k $k $fnam2]
						set k [lsearch $last_spekouts $fnam1]
					}
				}
			}
			if {[info exists spekouts]} {
				set k [lsearch $spekouts $fnam2]
				while {$k >= 0} {
					set spekouts [lreplace $spekouts $k $k]
					set k [lsearch $spekouts $fnam2]
				}
				if {[llength $spekouts] <= 0} {
					unset spekouts
				} else {
					set k [lsearch $spekouts $fnam1]
					while {$k >= 0} {
						set spekouts [lreplace $spekouts $k $k $fnam2]
						set k [lsearch $spekouts $fnam1]
					}
				}
			}
		}
		swap  {
			set fnam1 [lindex $args 0]
			set fnam2 [lindex $args 1]
			if {[info exists last_spekouts]} {
				set len [llength $last_spekouts]
				set n 0
				while {$n < $len} {
					set fnam [lindex $last_spekouts $n]
					if {[string match $fnam $fnam1]} {
						set last_spekouts [lreplace $last_spekouts $n $n $fnam2]
					} elseif {[string match $fnam $fnam2]} {
						set last_spekouts [lreplace $last_spekouts $n $n $fnam1]
					}
					incr n
				}
			}
			if {[info exists spekouts]} {
				set len [llength $spekouts]
				set n 0
				while {$n < $len} {
					set fnam [lindex $spekouts $n]
					if {[string match $fnam $fnam1]} {
						set spekouts [lreplace $spekouts $n $n $fnam2]
					} elseif {[string match $fnam $fnam2]} {
						set spekouts [lreplace $spekouts $n $n $fnam1]
					}
					incr n
				}
			}
		}
	}
}

#----- Rename/Delete existing transform sequences

proc ManageTransformSeqs {} {
	global evv specktr pr_spktranrenam spktran_nunam spektrenamlist spktran_nams
	if {![info exists specktr]} {
		Inf "No named transform sequences exist"
		return
	}
	catch {unset spktran_nams}
	foreach nam [array names specktr] {
		if {![string match $nam "default"]} {
			lappend spktran_nams $nam
		}
	}
	if {![info exists spktran_nams]} {
		Inf "No named transform sequences exist"
		return
	}
	set spktran_nams [lsort -ascii $spktran_nams]
	set scidir [file join $evv(URES_DIR) science]
	if {![file exists $scidir] || ![file isdirectory $scidir]} {
		Inf	"Cannot find directory $scidir containing transform sequence information"
		return
	}
	set f .spktranrenam
	if [Dlg_Create $f "Manage transform sequences" "set pr_spktranrenam 0" -borderwidth 2 -width 80] {
		frame $f.0
		button $f.0.ok -text "Rename Sequence" -command "set pr_spktranrenam 1" -highlightbackground [option get . background {}]
		button $f.0.del -text "Destroy Sequence" -command "set pr_spktranrenam 2" -highlightbackground [option get . background {}]
		button $f.0.qq -text "Quit" -command "set pr_spktranrenam 0" -highlightbackground [option get . background {}]
		pack $f.0.ok $f.0.del -side left -padx 4
		pack $f.0.qq -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		entry $f.1.e -textvariable spktran_nunam -width 32
		label $f.1.ll -text "New transform name"
		pack $f.1.e $f.1.ll -side left -padx 2
		pack $f.1 -side top -fill x -expand true -pady 2 
		frame $f.2
		label $f.2.tit -text "Select an item to rename from the list below" -fg $evv(SPECIAL)
		frame $f.2.bb
		button $f.2.bb.sort -text "Sort List" -command {SpekTranSort} -width 18 -highlightbackground [option get . background {}]
		button $f.2.bb.see -text "View Seq (Dbl-Clk)" -command {SeeSpekTranSeq manage} -width 18 -highlightbackground [option get . background {}]
		pack $f.2.bb.sort $f.2.bb.see -side left -padx 8 
		set spektrenamlist [Scrolled_Listbox $f.2.ll -width 64 -height 32 -selectmode single]
		pack $f.2.tit $f.2.bb $f.2.ll -side top -pady 2
		pack $f.2 -side top -fill both -expand true
		bind $f <Escape> {set pr_spktranrenam 0}
		bind $spektrenamlist <Double-1> {SeeSpekTranSeq manage}
		bind $spektrenamlist <ButtonRelease-1> {SpekManageGet}
		wm resizable $f 0 0
	}
	$spektrenamlist delete 0 end
	foreach nam $spktran_nams {
		$spektrenamlist insert end $nam
	}
	set pr_spktranrenam 0
	update idletasks
	raise $f
	My_Grab 0 $f pr_spktranrenam $f.1.e
	set finished 0
	while {!$finished} {
		tkwait variable pr_spktranrenam
		switch -- $pr_spktranrenam {
			1 {
				if {[string length $spktran_nunam] <= 0} {
					Inf "No new name entered"
					continue
				}
				if {![regexp {^[a-z0-9\-\_]+$} $spktran_nunam]} {
					Inf "Invalid name entered (lower case alphanumeric required)"
					continue
				}
				if {[string match $spktran_nunam "default"]} {
					Inf "This is a reserved name: please choose a different name"
					continue
				}
				set OK 1
				foreach nam $spktran_nams {
					if {[string match $spktran_nunam $nam]} {
						set OK 0
						break
					}
				}
				if {!$OK} {
					Inf "There is already a transform sequence with this name: please choose a different name"
					continue
				}

				set i [$spektrenamlist curselection]
				if {![info exists i] || ([llength $i] <= 0) || ($i == -1)} {
					Inf "No transform sequence selected for renaming"
					continue
				}
				set oldnam [$spektrenamlist get $i]
				set oldfnam [file join $scidir "sci_"]
				append oldfnam $oldnam $evv(CDP_EXT)
				set newfnam [file join $scidir "sci_"]
				append newfnam $spktran_nunam $evv(CDP_EXT)
				if {[file exists $oldfnam]} {
					if [catch {file rename $oldfnam $newfnam} zit] {
						Inf "Cannot rename file [file rootname [file tail $oldfnam]] to [file rootname [file tail $newfnam]]"
						continue
					}
				}
				set specktr($spktran_nunam) $specktr($oldnam)
				unset specktr($oldnam)
				$spektrenamlist delete $i
				$spektrenamlist insert $i $spktran_nunam
				set k [lsearch $spktran_nams $oldnam]
				set spktran_nams [lreplace $spktran_nams $k $k $spktran_nunam]
			}
			2 {
				DelSpekTranSeq
			}
			0 {
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc SpekManageGet {} {
	global spektrenamlist spktran_nunam
	set i [$spektrenamlist curselection]
	if {$i >= 0} {
		if {[string length $spktran_nunam] <= 0} {
			set spktran_nunam  [$$spektrenamlist get $i]
		}
	}
}

proc SpekTranSort {} {
	global spktran_nams spektrenamlist
	set spktran_nams [lsort -ascii $spktran_nams]
	$spektrenamlist delete 0 end
	foreach nam $spktran_nams {
		$spektrenamlist insert end $nam
	}
	$spektrenamlist selection clear 0 end
}

proc SeeSpekTranSeq {typ} {
	global spektrenamlist spektlist specktr
	switch -- $typ {
		"manage" {
			set ll $spektrenamlist
		}
		"load" {
			set ll $spektlist
		}
	}
	set i [$ll curselection]
	if {![info exists i] || ([llength $i] <= 0) || ($i == -1)} {
		Inf "No transform sequence selected"
		return
	}
	set nam [$ll get $i]
	set msg ""
	foreach line $specktr($nam) {
		append msg $line "\n"
	}
	Inf $msg
}

proc DelSpekTranSeq {} {
	global spektrenamlist specktr wstk spktran_nams evv
	set i [$spektrenamlist curselection]
	if {![info exists i] || ([llength $i] <= 0) || ($i == -1)} {
		Inf "No transform sequence selected"
		return
	}
	set nam [$spektrenamlist get $i]
	set msg "Are you sure you want to ~~destroy~~ transform sequence $nam ??"
	set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
	if {$choice == "no"} {
		return
	}
	set scidir [file join $evv(URES_DIR) science]
	set fnam [file join $scidir "sci_"]
	append fnam $nam $evv(CDP_EXT)
	if [catch {file delete $fnam} zit] {
		Inf "Cannot remove this transform sequence"
		return
	}
	unset specktr($nam)
	$spektrenamlist delete $i
	set k [lsearch $spktran_nams $nam]
	set spktran_nams [lreplace $spktran_nams $k $k]
	Inf "Transform sequence $nam destroyed"
}

#---- TEST FUNCTIONS

proc  List_Spectrum {} {
	global pr_showit spek_c brrk_curvcnt
	set last_indx [expr $brrk_curvcnt - 1]
	set f .showit
	if [Dlg_Create $f "Spec output" "set pr_showit 0" -borderwidth 2] {
		frame $f.0
		button $f.0.qu  -text "Quit" -command "set pr_showit 0" -highlightbackground [option get . background {}]
		pack $f.0.qu -side right
		pack  $f.0 -side top -fill x -expand true
		frame $f.1
		Scrolled_Listbox $f.1.ll -width 64 -height 64 -selectmode single
		pack $f.1.ll -side left
		pack $f.1 -side top
		wm resizable $f 1 1
		bind $f <Return> {set pr_showit 0}
		bind $f <Escape> {set pr_showit 0}
	}
	$f.1.ll.list delete 0 end
	set k 0
	foreach {frq amp} $spek_c($last_indx) {
		set xx [list \[$k\] $amp $frq]
		$f.1.ll.list insert end $xx
		incr k
	}
	set pr_showit 0
	update idletasks
	raise $f
	update idletasks
	My_Grab 0 $f pr_showit
	update idletasks
	set finished 0
	tkwait variable pr_showit
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

###################
#   TIME_SERIES	  #
###################

proc TimeSeriesToSnd {} {
	global pr_ts tsdatatype tsp0 tscubic tsfrq tshalfrange tsharmonics tsfnam tsdur pa wstk evv rememd wl
	global last_last_tsfrq last_tsfrq last_last_tshalfrange last_tshalfrange tsmaxdur tsmaxdurfunc ts_emph ts_hlp_actv
	global last_last_tsharmonics last_tsharmonics last_tscubic_trace tscubic_trace tsdatanamtype
	global last_tscubic_oscil tscubic_oscil tslist chlist ch chcnt tsoutfnam tsmode last_tsmode tsduro tsminduro
	global prg_dun prg_abortd CDPidrun pr_uberdata tscmds tsdatanamlist tsplaylist ts_parsed ts_chlist
	global ts_setting ts_setting_cmd tsforce last_tsforce_trace tsforce_trace last_force_oscil tsforce_oscil 
	global last_outfile tsdurlist tsmin_indur tsmax_indur tsmin_indur_at tsmax_indur_at tsochans tsmany
	global readonlyfg readonlybg ts_harmcnt ts_harmvals tsfunc tsfpar1 tsfpar2 tsfpar3 tsfpar4 tsrmin tsrmax tsequal
	global ts_maxlens ts_previous tsfuncnam tscrand tsbrkstep istsview TsDeleteCmd tsmultiout tssrcsnd tssubfunc
	global tsfmultisrcd tssubfunccnt ts_olddir

	set evv(TS_SRATE) 44100
	set evv(TS_MAXOCT) 16
	set evv(TS_MAXTSTRETCH) 10000
	set evv(TS_PAIR)	4
	set evv(TS_ANAL)	3
	set evv(TS_SHORT)	0
	set evv(TS_LONG)	2
	set evv(TS_SOUND)	1
	set evv(TS_SOUNDS)	5
	set tsduro ""
	set tsminduro ""
	catch {unset ts_setting}
	catch {unset ts_setting_cmd}
	catch {unset ts_previous}
	set ts_hlp_actv 0
	set tssubfunccnt 1
	set tsfmultisrcd -1

	if {![info exists chlist] || ([llength $chlist] <= 0)} {
		Inf "No files selected on chosen list"
		set pr_uberdata 0
		return
	}
	set msgtyp "Selected files"
	Block "Getting Listed Files"
	if {[llength $chlist] == 1} {
		set fnam [lindex $chlist 0]
		if {![IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
			if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
				Inf "File [file tail $fnam] is neither numeric data, nor a list of files of numeric data"
				UnBlock
				return
			}
			set allcnt 0
			set goodcnt 0
			set msgtyp "Items listed in file [file tail $fnam]"
			if [catch {open $fnam "r"} zit] {
				Inf "Cannot open file [file tail $fnam]"
				UnBlock
				return
			}
			while {[gets $zit line] >= 0} {
				set line [string trim $line]
				if {[string length $line] <= 0} {
					continue
				}
				if {[string match [string index $line 0] ";"]} {
					continue
				}
				if {![file exists $line]} {
					incr allcnt
					lappend badfiles $line
					continue
				} else {
					lappend listfnams $line
					incr allcnt
					incr goodcnt
				}
			}
			close $zit
			while {![info exists listfnams]} {
				if {[info exists ts_olddir]} {
					set msg "None of the $msgtyp is an existing file\n\nlook in previously use directory\n\n$ts_olddir ??"
					set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						set msg "Specify a different directory to look for them ??"
						set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							UnBlock
							return
						}
						set nuts_olddir [DoListingOfDirectories datalist]
						if {[string length $nuts_olddir] <= 0} {
							catch {unset nuts_olddir}
							continue
						} else {
							set ts_olddir $nuts_olddir
						}
					}
				} else {
					set msg "None of the $msgtyp is an existing file\n\nspecify a directory to look for them ??"
					set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						UnBlock
						return
					}
					set ts_olddir [DoListingOfDirectories datalist]
					if {[string length $ts_olddir] <= 0} {
						catch {unset ts_olddir}
						continue
					}
				}
				set goodcnt 0
				set allcnt 0
				foreach fnam $badfiles {
					set fnam [file join $ts_olddir [file tail $fnam]]
					if {![file exists $fnam]} {
						incr allcnt
						continue
					} else {
						lappend listfnams $fnam
						incr allcnt
						incr goodcnt
					}
				}
			}
			catch {unset badfiles}
			if {$allcnt != $goodcnt} {
				set msg "Not all the $msgtyp are existing files\n\ncontinue checking those that do exist ??"
				set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					UnBlock
					return
				}
			}
			set n 0
			set len [llength $listfnams]
			while {$n < $len} {
				set fnam [lindex $listfnams $n]
				if {[LstIndx $fnam $wl] < 0} {
					if {[FileToWkspace $fnam 0 0 0 0 1] <= 0} {
						set listfnams [lreplace $listfnams $n $n]
						incr len -1
						continue
					}
				}
				incr n
			}
			if {[llength $listfnams] <= 0} {
				Inf "Could not grab any of the files to the workspace"
				UnBlock
				return
			}
			DoChoiceBak
			set chlist $listfnams
			$ch delete 0 end
			foreach fnam $chlist {
				$ch insert end $fnam
			}
			set chcnt [llength $chlist]
		}
	}
	foreach fnam $chlist {
		if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
			lappend goodfiles $fnam
		} else {
			lappend badfiles $fnam
		}
	}
	if {![info exists goodfiles]} {
		Inf "None of the $msgtyp are possible time-series"
		UnBlock
		return
	}
	if {[info exists badfiles]} {
		set msg "Some $msgtyp are not lists of numbers.\n\n"
		append msg "You can proceed with the valid files, or check which files are invalid.\n\n"
		append msg "Proceed with valid files ?"
		set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			set msg "Do you want to see which files are not valid ?"
			set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
			if {$choice == "yes"} {
				set msg [file rootname [file tail [lindex $badfiles 0]]]
				append msg "\n"
				set cnt 1
				foreach ffnam [lrange $badfiles 1 end] {
					append msg [file rootname [file tail $ffnam]] "\n"
					incr cnt
					if {$cnt >= 20} {
						append msg "and more"
						break
					}
				}
				Inf $msg
				set msg "Select these files on the workspace ?"
				set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
				if {$choice == "yes"} {
					DoChoiceBak
					ClearWkspaceSelectedFiles
					foreach fnam $badfiles {
						lappend chlist $fnam
						$ch insert end $fnam
						incr chcnt
					}
				}
			}
			set pr_uberdata 0
			UnBlock
			return
		}
	}
	UnBlock

	if {[info exists last_last_tsfrq]} {
		set last_tsfrq $last_last_tsfrq
	}
	if {[info exists last_last_tshalfrange]} {
		set last_tshalfrange $last_last_tshalfrange
	}
	if {[info exists last_last_tsharmonics]} { 
		set last_tsharmonics $last_last_tsharmonics
	}
	if {[info exists last_tscubic_trace]} { 
		set tscubic_trace $last_tscubic_trace
	}
	if {[info exists last_tsforce_trace]} { 
		set tsforce_trace $last_tsforce_trace
	}
	if {[info exists last_tscubic_oscil]} {
		set tscubic_oscil $last_tscubic_oscil
	}
	if {[info exists last_tsforce_oscil]} {
		set tsforce_oscil $last_tsforce_oscil
	}
	set evv(DATA_HEIGHT) 20

	set f .ts
	if [Dlg_Create $f "Timeseries data to sound" "set pr_ts 0" -borderwidth 2] {
		frame $f.0
		button $f.0.qu -text "Quit" -command "set pr_ts 0" -highlightbackground [option get . background {}]
		button $f.0.es -text "End Session" -command "DoWkspaceQuit 1 0" -highlightbackground [option get . background {}]
		button $f.0.k -text "K" -highlightbackground [option get . background {}] -command "Shortcuts ts" -width 2
		label $f.0.dum -text "" -width 4

		frame $f.0.0
		button $f.0.0.lod -text "Load" -command "set pr_ts 22" -highlightbackground [option get . background {}]
		label $f.0.0.nnn -text "Name"
		entry $f.0.0.eee -textvariable tsfuncnam -width 10
		button $f.0.0.sav -text "Save" -command "set pr_ts 21" -highlightbackground [option get . background {}]
		button $f.0.0.dum -text "" -command {} -bd 0 -width 8 -highlightbackground [option get . background {}]
		pack $f.0.0.lod $f.0.0.nnn $f.0.0.eee $f.0.0.sav $f.0.0.dum -side left 
		
		button $f.0.hlp -text "Help" -highlightbackground [option get . background {}] -command "ActivateHelp .ts.0" -width 4
		label  $f.0.conn -text "" -width 13
		button $f.0.con -text "" -borderwidth 0 -state disabled -width 8 -highlightbackground [option get . background {}]
		label $f.0.help -width 84 -text "$evv(HELP_DEFAULT)"		pack $f.0.ok -side left

		pack $f.0.es $f.0.dum $f.0.k $f.0.hlp $f.0.conn $f.0.con $f.0.help -side left
		pack $f.0.qu -side right
		pack $f.0.0 -side right
		pack  $f.0 -side top -fill x -expand true
		
		frame $f.a
		frame $f.b

		label $f.b.00 -text "Data as control file" -fg $evv(SPECIAL)  -font bigfnt
		frame $f.b.001 -bg black -height 1 
		frame $f.b.01 
		frame $f.b.002 -bg black -height 1 
		label $f.b.01.ldur  -text "Durations"
		entry $f.b.01.dur -textvariable tsmaxdurfunc -width 8
		checkbutton $f.b.01.rr -variable tsequal -text "equal"
		set tsequal 0
		pack $f.b.01.rr -side right
		pack $f.b.01.dur $f.b.01.ldur -side left
		pack $f.b.00 -side top
		pack $f.b.001 -side top -fill x -expand true -pady 2
		pack $f.b.01 -side top
		pack $f.b.002 -side top -fill x -expand true -pady 2
		frame $f.b.0
		radiobutton $f.b.0.0  -text "0:  Output raw control data"			  -variable tsfunc -value 0  -command {SetupTsFunc 0}
		radiobutton $f.b.0.1  -text "1:  Texture Pulsed : vary density"		  -variable tsfunc -value 1  -command {SetupTsFunc 0}
		radiobutton $f.b.0.2  -text "2:  Texture Random : vary density"		  -variable tsfunc -value 2  -command {SetupTsFunc 0}
		radiobutton $f.b.0.3  -text "3:  Texture Random : vary range"		  -variable tsfunc -value 3  -command {SetupTsFunc 0}
		radiobutton $f.b.0.4  -text "4:  Envelopes rising : vary cyclecnt"	  -variable tsfunc -value 4  -command {SetupTsFunc 2}
		radiobutton $f.b.0.5  -text "5:  Envelopes falling : vary cyclecnt"	  -variable tsfunc -value 5  -command {SetupTsFunc 2}
		radiobutton $f.b.0.6  -text "6:  Envelopes troughing : vary cyclecnt" -variable tsfunc -value 6  -command {SetupTsFunc 2}
		radiobutton $f.b.0.7  -text "7:  Waveset omission : vary erasure"	  -variable tsfunc -value 7  -command {SetupTsFunc 2}
		radiobutton $f.b.0.8  -text "8:  Tremolo : vary frequency"			  -variable tsfunc -value 8  -command {SetupTsFunc 2}
		radiobutton $f.b.0.9  -text "9:  Tremolo : vary depth"				  -variable tsfunc -value 9  -command {SetupTsFunc 2}
		radiobutton $f.b.0.10 -text "10: Vibrato : vary freqency"			  -variable tsfunc -value 10 -command {SetupTsFunc 2}
		radiobutton $f.b.0.11 -text "11: Vibrato : vary depth"				  -variable tsfunc -value 11 -command {SetupTsFunc 2}
		radiobutton $f.b.0.12 -text "12: Zigzag : scan file"				  -variable tsfunc -value 12 -command {SetupTsFunc 1}
		radiobutton $f.b.0.13 -text "13: Drunkwalk : vary locus"			  -variable tsfunc -value 13 -command {SetupTsFunc 1}
		radiobutton $f.b.0.14 -text "14: Drunkwalk : vary ambitus"			  -variable tsfunc -value 14 -command {SetupTsFunc 1}
		radiobutton $f.b.0.15 -text "15: Drunkwalk : vary clockrate"		  -variable tsfunc -value 15 -command {SetupTsFunc 1}
		radiobutton $f.b.0.16 -text "16: Filterbank harmonic : vary Q"		  -variable tsfunc -value 16 -command {SetupTsFunc 2}
		radiobutton $f.b.0.17 -text "17: Filterbank subharmonic : vary Q"	  -variable tsfunc -value 17 -command {SetupTsFunc 2}
		radiobutton $f.b.0.18 -text "18: Spectral shift : vary shift"		  -variable tsfunc -value 18 -command {SetupTsFunc 3}
		radiobutton $f.b.0.19 -text "19: Spectral stretch : vary stretch"	  -variable tsfunc -value 19 -command {SetupTsFunc 3}
		radiobutton $f.b.0.20 -text "20: Mix sources : vary balance"		  -variable tsfunc -value 20 -command {SetupTsFunc 4}
		frame $f.b.0.a
		radiobutton $f.b.0.a.21 -text "21: Sequence : "						  -variable tsfunc -value 21 -command {SetupTsFunc 5}
		checkbutton $f.b.0.a.21loud -text "Atten" -width 10					  -variable tssubfunc(1) -command {TSSequenceSubfuncCnt}
		checkbutton $f.b.0.a.21spac -text "Space" -width 10					  -variable tssubfunc(2) -command {TSSequenceSubfuncCnt}
		pack $f.b.0.a.21 $f.b.0.a.21loud $f.b.0.a.21spac -side left
#		radiobutton $f.b.0.22 -text "22: Melody : generate line"			  -variable tsfunc -value 22 -command {SetupTsFunc 5}
		pack $f.b.0.0 $f.b.0.1 $f.b.0.2 $f.b.0.3 $f.b.0.4 $f.b.0.5 $f.b.0.6 $f.b.0.7 $f.b.0.8 $f.b.0.9 $f.b.0.10 \
			$f.b.0.11 $f.b.0.12 $f.b.0.13 $f.b.0.14 $f.b.0.15 $f.b.0.16 $f.b.0.17 $f.b.0.18 $f.b.0.19 $f.b.0.20 $f.b.0.a -side top -anchor w
		pack $f.b.0 -side top
		frame $f.b.0xx -bg black -height 1
		pack $f.b.0xx -side top -fill x -expand true
		frame $f.b.0x
		label $f.b.0x.cntrl -text "Control param"
		pack $f.b.0x.cntrl -side left
		label $f.b.0x.other -text "Other params"
		pack $f.b.0x.other -side right
		pack $f.b.0x -side top -fill x -expand true
		frame $f.b.0a
		label $f.b.0a.rng -text ""  -fg $evv(SPECIAL)
		pack $f.b.0a.rng -side left
		pack $f.b.0a -side top -fill x -expand true
		frame $f.b.1
		entry $f.b.1.p1 -textvariable tsfpar1 -width 8
		label $f.b.1.ll1 -text ""
		pack $f.b.1.p1 $f.b.1.ll1 -side right
		entry $f.b.1.rmin  -textvariable tsrmin -width 8
		label $f.b.1.min -text "min"
		pack $f.b.1.rmin $f.b.1.min -side left
		pack $f.b.1 -side top -fill x -expand true
		frame $f.b.2
		entry $f.b.2.p2 -textvariable tsfpar2 -width 8
		label $f.b.2.ll2 -text ""
		pack $f.b.2.p2 $f.b.2.ll2 -side right
		entry $f.b.2.rmax  -textvariable tsrmax -width 8
		label $f.b.2.max -text "max"
		pack $f.b.2.rmax $f.b.2.max -side left
		pack $f.b.2 -side top -fill x -expand true
		frame $f.b.3
		entry $f.b.3.p3 -textvariable tsfpar3 -width 8
		label $f.b.3.ll3 -text ""
		pack $f.b.3.p3 $f.b.3.ll3 -side right
		checkbutton $f.b.3.log -variable tslog -text "log"
		set tslog 0
		pack $f.b.3.log -side left
		pack $f.b.3 -side top -fill x -expand true
		frame $f.b.4
		entry $f.b.4.p4 -textvariable tsfpar4 -width 8
		label $f.b.4.ll4 -text ""
		pack $f.b.4.p4 $f.b.4.ll4 -side right
		entry $f.b.4.stp -textvariable tsbrkstep -width 8
		label $f.b.4.stl -text "step"
		pack $f.b.4.stp $f.b.4.stl -side left
		pack $f.b.4 -side top -fill x -expand true
		frame $f.b.4a
		checkbutton $f.b.4a.cr -variable tscrand -text "randclok"
		set tscrand 0
		pack $f.b.4a.cr -side right
		radiobutton $f.b.4a.au -variable tsauto -text "autostep" -value 0 -command TsAutoStep
		pack $f.b.4a.au -side left
		pack $f.b.4a -side top -fill x -expand true
		frame $f.b.5
		frame $f.b.5.a
		button $f.b.5.a.src -text "Get Target Sound(s)" -command "set pr_ts 17" -width 20 -highlightbackground [option get . background {}]
		entry $f.b.5.a.eee -textvariable tssrcsnd -width 16 -fg $readonlyfg -readonlybackground $readonlybg -state readonly
		pack $f.b.5.a.src $f.b.5.a.eee -side left -padx 2 
		button $f.b.5.run -text "Run Process" -command "set pr_ts 18" -bg $evv(EMPH) -highlightbackground [option get . background {}]
		pack $f.b.5.a $f.b.5.run  -side top -pady 2
		pack $f.b.5 -side top

		label $f.a.0 -text "Data as sound" -fg $evv(SPECIAL)  -font bigfnt
		pack $f.a.0 -side top
		frame $f.a.1
		label $f.a.1.ll -text "Treat As "
		radiobutton $f.a.1.ts -text "Amplitude plot" -variable tsdatatype -value 1 -command {TimeSeriesParamSet amp}
		radiobutton $f.a.1.sp -text "Pitch plots" -variable tsdatatype -value 2 -command {TimeSeriesParamSet pitch}
		radiobutton $f.a.1.zz -text "Pitch plots for partials" -variable tsdatatype -value 3 -command {TimeSeriesParamSet many}
		pack $f.a.1.ll $f.a.1.ts  $f.a.1.sp $f.a.1.zz -side left -padx 2
		pack $f.a.1 -side top -pady 2
		frame $f.a.1x -bg black
		pack $f.a.1x -side top -fill x -expand true -pady 4
		frame $f.a.2
		button $f.a.2.go -text "Make Sounds" -command "set pr_ts 1" -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $f.a.2.pp -text "Play Sounds" -command "set pr_ts 2" -highlightbackground [option get . background {}]
		button $f.a.2.vv -text "View Sounds" -command "set pr_ts 6" -bg $evv(SNCOLOR) -highlightbackground [option get . background {}]
		button $f.a.2.nn -text "Save Sounds" -command "set pr_ts 3" -highlightbackground [option get . background {}]
		label $f.a.2.ll -text "(Generic) Output filename "
		entry $f.a.2.ee -textvariable tsfnam -width 16
		set tsfnam ""
		radiobutton $f.a.2.r1 -text "new name" -variable tsdatanamtype -value 0
		radiobutton $f.a.2.r2 -text "data name" -variable tsdatanamtype -value 1
		radiobutton $f.a.2.r3 -text "Prefix data name" -variable tsdatanamtype -value 2
		pack $f.a.2.go $f.a.2.pp $f.a.2.vv $f.a.2.nn $f.a.2.ll $f.a.2.ee $f.a.2.r1 $f.a.2.r2 $f.a.2.r3 -side left -padx 2
		pack $f.a.2 -side top -pady 2
		frame $f.a.2x -bg black
		pack $f.a.2x -side top -fill x -expand true -pady 4
		frame $f.a.2a
		label $f.a.2a.gps -text "Play grps of "
		entry $f.a.2a.chans -textvariable tsochans -width 2 -fg $readonlyfg -readonlybackground $readonlybg -state readonly
		label $f.a.2a.llch -text "snds (Cntrl Up/Dn)"
		button $f.a.2a.gpp -text "Multi"   -command "set pr_ts 13" -highlightbackground [option get . background {}]
		button $f.a.2a.seq -text "Seq"  -command "set pr_ts 14" -highlightbackground [option get . background {}]
		button $f.a.2a.mix -text "Mix"  -command "set pr_ts 15" -highlightbackground [option get . background {}]
		button $f.a.2a.msp -text "Sprd"  -command "set pr_ts 16" -highlightbackground [option get . background {}]
		button $f.a.2a.ssm -text "Save Mix"  -command "set pr_ts 23" -highlightbackground [option get . background {}]
		button $f.a.2a.dum2 -text "" -width 4 -command {} -bd 0  -highlightbackground [option get . background {}]
		button $f.a.2a.ss -text "Save Settings" -command "set pr_ts 4" -highlightbackground [option get . background {}]
		button $f.a.2a.lo -text "Load Settings" -command "set pr_ts 5" -highlightbackground [option get . background {}]
		button $f.a.2a.dum -text "" -width 4 -command {} -bd 0  -highlightbackground [option get . background {}]
		button $f.a.2a.strf -text "Get a datastretch file" -command "set pr_ts 8" -highlightbackground [option get . background {}]
		button $f.a.2a.vts -text "List data" -command "set pr_ts 9" -highlightbackground [option get . background {}]
		button $f.a.2a.dur -text "See Output Dur" -command "set pr_ts 10" -highlightbackground [option get . background {}]
		pack $f.a.2a.gps $f.a.2a.chans $f.a.2a.llch $f.a.2a.gpp $f.a.2a.seq $f.a.2a.mix $f.a.2a.msp $f.a.2a.ssm $f.a.2a.dum2 $f.a.2a.ss \
			$f.a.2a.lo $f.a.2a.dum $f.a.2a.strf $f.a.2a.vts $f.a.2a.dur -side left -padx 2
		pack $f.a.2a -side top -pady 2
		frame $f.a.2b -bg black
		pack $f.a.2b -side top -fill x -expand true -pady 4
		frame $f.a.3
		entry $f.a.3.e -textvariable tsp0 -width 8
		label $f.a.3.ll -text "Octaves to Downsample (0-16)" -width 28
		entry $f.a.3.e2 -textvariable tsmaxdur -width 8
		label $f.a.3.ll2 -text "Optional duration limit"
		pack $f.a.3.e  $f.a.3.ll $f.a.3.e2  $f.a.3.ll2 -side left -padx 2
		pack $f.a.3 -side top -pady 2 -fill x -expand true
		frame $f.a.4
		checkbutton $f.a.4.cubic -variable tscubic -text "Cubic spline interpolation"
		pack $f.a.4.cubic -side left -padx 2
		checkbutton $f.a.4.force -variable tsforce -text "Loop to given duration if too short"
		pack $f.a.4.force -side left -padx 2
		label $f.a.4.ll -text "(Max) Input duration "
		entry $f.a.4.dur -textvariable tsdur -width 20 -state readonly
		pack $f.a.4.dur $f.a.4.ll -side right -padx 4
		pack $f.a.4 -side top -pady 2 -fill x -expand true
		frame $f.a.5
		entry $f.a.5.e -textvariable tsfrq -width 8
		label $f.a.5.ll -text "Centre Frq of output"
		pack $f.a.5.e  $f.a.5.ll -side left -padx 2

		label $f.a.5.ll2 -text "(Max) Output duration "
		entry $f.a.5.dro -textvariable tsduro -width 20 -state readonly
		pack $f.a.5.dro $f.a.5.ll2 -side right -padx 4
		pack $f.a.5 -side top -pady 2 -fill x -expand true
		frame $f.a.6
		entry $f.a.6.e -textvariable tshalfrange -width 8
		label $f.a.6.ll -text "Half-Range of output (semitones)"
		pack $f.a.6.e  $f.a.6.ll -side left -padx 2

		label $f.a.6.ll2 -text "(Min) Output duration "
		entry $f.a.6.dro -textvariable tsminduro -width 20 -state readonly
		pack $f.a.6.dro $f.a.6.ll2 -side right -padx 4
		pack $f.a.6 -side top -pady 2 -fill x -expand true
		frame $f.a.7
		entry $f.a.7.e -textvariable tsharmonics -width 32
		label $f.a.7.ll -text "Partials : Optional File listing partial-no/amplitude pairs"
		button $f.a.7.gf -text "Get File" -command GetTsHarmonicsFile -highlightbackground [option get . background {}]
		pack $f.a.7.e  $f.a.7.ll $f.a.7.gf -side left -padx 2
		pack $f.a.7 -side top -pady 2 -fill x -expand true
		frame $f.a.8
		label $f.a.8.tit -text "Numeric Data Files: Select files to process" -foreground $evv(SPECIAL)
		frame $f.a.8.zz
		button $f.a.8.zz.sla -text "Select All"   -command "set pr_ts 7" -highlightbackground [option get . background {}]
		button $f.a.8.zz.pre -text "Previous"     -command "set pr_ts 20" -highlightbackground [option get . background {}]
		button $f.a.8.zz.sht -text "Shortest"     -command "set pr_ts 11" -highlightbackground [option get . background {}]
		button $f.a.8.zz.lng -text "Longest"      -command "set pr_ts 12" -highlightbackground [option get . background {}]
		button $f.a.8.zz.lng2 -text "Next Longest" -command "set pr_ts 19" -highlightbackground [option get . background {}]
		label $f.a.8.zz.dum -text "" -width 16
		button $f.a.8.zz.see -text "Schematic View of Data" -command "ViewTsData" -highlightbackground [option get . background {}]
		button $f.a.8.zz.sec -text "See Control File" -command "ViewTsControl" -highlightbackground [option get . background {}]
		pack $f.a.8.zz.sla $f.a.8.zz.pre $f.a.8.zz.sht $f.a.8.zz.lng $f.a.8.zz.lng2 $f.a.8.zz.dum $f.a.8.zz.see $f.a.8.zz.sec -side left -padx 2
		frame $f.a.8.ss
		set tslist [Scrolled_Listbox $f.a.8.ss.ll -width 120 -height $evv(DATA_HEIGHT) -selectmode extended]
		set tsdurlist [Scrolled_Listbox $f.a.8.ss.dd -width 16 -height $evv(DATA_HEIGHT) -selectmode extended]
		pack $f.a.8.ss.ll $f.a.8.ss.dd -side left -pady 2
		pack $f.a.8.tit $f.a.8.zz $f.a.8.ss -side top -pady 2
		pack $f.a.8 -side top -fill both
		frame $f.aa -bg black -width 1
		pack $f.a -side left
		pack $f.aa -side left -fill y -expand true
		pack $f.b -side left
		wm resizable $f 1 1
		bind $f <Escape> {set pr_ts 0}
		bind $f <Return> {DoTs }
		bind $f <Key-space> {set pr_ts 2}
		bind $f <Control-s> {set pr_ts 3}
		bind $f <Control-S> {set pr_ts 3}
		bind $f <Command-s> {set pr_ts 4}
		bind $f <Command-S> {set pr_ts 4}
		bind $f <Command-l> {set pr_ts 5}
		bind $f <Command-L> {set pr_ts 5}
		bind $f <Control-P> {PlayTsData}
		bind $f <Control-p> {PlayTsData}
		bind $f <Tab> {set pr_ts 7}
		bind $f <Control-Up> {TsChansChange 0}
		bind $f <Control-Down> {TsChansChange 1}
		bind $f <Key-space> {set pr_ts 2}
		bind $f <Shift-Key-space> {set pr_ts 13}
		bind $tslist <Double-1> {ViewTsData}
	}
	catch {unset tsmultiout}
	set tscrand 0
	set tsfuncnam ""
	SetupTsFunc -1
	set tsochans 8
	catch {unset tsplaylist}
	.ts.0.hlp config -text "Help"
	set ts_emph $f.a.2.go
	set tsdatanamtype 2
	if {[info exists last_tsmode]} {
		set tsmode $last_tsmode
		TimeSeriesParamSet $tsmode
	} else {	
		TimeSeriesParamSet init	
	}
	$tslist delete 0 end
	$tsdurlist delete 0 end
	set tsmin_indur $pa([lindex $goodfiles 0],$evv(ALL_WORDS))
	set tsmin_indur_at 0
	set tsmax_indur 0
	set n 0
	foreach fnam $goodfiles {
		$tslist insert end $fnam
		$tsdurlist insert end $pa($fnam,$evv(ALL_WORDS))
		if {$pa($fnam,$evv(ALL_WORDS)) > $tsmax_indur} {
			set tsmax_indur $pa($fnam,$evv(ALL_WORDS))
			set tsmax_indur_at $n
		} elseif {$pa($fnam,$evv(ALL_WORDS)) < $tsmin_indur} {
			set tsmin_indur $pa($fnam,$evv(ALL_WORDS))
			set tsmin_indur_at $n
		}
		incr n
	}
	set n 0
	foreach val [$tsdurlist get 0 end] {
		lappend zvals $val 
		lappend zposs $n
		incr n
	}
	set len $n
	if {$len > 1} {
		set len_less_one [expr $len - 1]
		set n 0
		while {$n < $len_less_one} {
			set valn [lindex $zvals $n]
			set posn [lindex $zposs $n]
			set m $n
			incr m
			while {$m < $len} {
				set valm [lindex $zvals $m]
				set posm [lindex $zposs $m]
				if {$valm > $valn} {
					set zvals [lreplace $zvals $m $m $valn]
					set zvals [lreplace $zvals $n $n $valm]
					set zposs [lreplace $zposs $m $m $posn]
					set zposs [lreplace $zposs $n $n $posm]
					set temp $valn
					set valn $valm
					set valm $temp
					set temp $posn
					set posn $posm
					set posm $temp
				}
				incr m
			}
			incr n
		}
		set ts_maxlens $zposs
	} else {
		set ts_maxlens 0
	}
	if {![GenerateViewableData]} {
		Inf "Unable to convert data to viewable format"
		set istsview 0
		set TsDeleteCmd DeleteAllTemporaryFiles
		Dlg_Dismiss $f
		set pr_uberdata 0
		return
	} else {
		set istsview 1
		set len [llength $goodfiles]
		set kk 0
		set TsDeleteCmd DeleteAllTemporaryFilesExcept
		while {$kk < $len} {
			set datvvfnam $evv(DFLT_OUTNAME)
			append datvvfnam 001100
			append datvvfnam $kk $evv(SNDFILE_EXT)
			if {[file exists $datvvfnam]} {
				lappend TsDeleteCmd $datvvfnam
			}
			incr kk
		}
	}
	set tscubic 0
	set tsforce 0
	set tsdatatype 0
	set pr_ts 0
	update idletasks
	raise $f
	StandardPosition $f
	My_Grab 0 $f pr_ts
	update idletasks
	set finished 0
	while {!$finished} {
		tkwait variable pr_ts
		switch -- $pr_ts {
			0 {
				catch {eval $TsDeleteCmd}
				set finished 1
			}
			1 {
				if {[info exists ts_parsed]} {
					foreach ttfnam $ts_parsed {
						catch {PurgeProps $ttfnam}
					}
				}
				catch {eval $TsDeleteCmd}
				catch {unset cmd} 
				set tsduro ""
				set ilist [$tslist curselection]
				if {$ilist < 0} {
					if {[info exists lasti]} {
						foreach i $lasti {
							$tslist selection set $i
						}
					} elseif {[llength $goodfiles] == 1} {
						$tslist selection set 0
						set ilist 0
					} else  {
						Inf "No datafile selected for processing"
						continue
					}
				}
				set lasti $ilist
				set tsdata {}
				set tsdur 0
				set n 0
				catch {unset tsoutfnam} 
				foreach i $ilist {
					set thisfnam [$tslist get $i]
					lappend tsdata $thisfnam
					set len $pa($thisfnam,$evv(ALL_WORDS))
					set thistsdur [expr double($len)/$evv(TS_SRATE)]
					if {$thistsdur > $tsdur} {
						set tsdur $thistsdur
					}
					set tsoutfnam($n) $evv(DFLT_OUTNAME)
					append tsoutfnam($n) $n $evv(SNDFILE_EXT)
					incr n
				}
				set files_to_process $n
				set cmd [file join $evv(CDPROGRAM_DIR) ts]
				lappend cmd $tsmode thistsdata outsnd
				switch -- $tsmode {
					"oscil" {
						set tsp0 [string trim $tsp0]
						if {[string length $tsp0] <= 0} {
							set msg "No downsampling octave entered: proceed without downsampling ??"
							set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
							if {$choice == "no"} {
								unset cmd
								continue
							} else {
								set tsp0 0
							}
						} elseif {![IsNumeric $tsp0]} {
							if {![file exists $tsp0]} {
								Inf "File [file rootname [file tail $tsp0]] does not exist"
								unset cmd
								continue
							} elseif {![info exists pa($tsp0,$evv(FTYP))]} {
								Inf "File [file rootname [file tail $tsp0]] is not on the workspace: cannot proceed"
								unset cmd
								continue
							} elseif {![IsABrkfile $pa($tsp0,$evv(FTYP))]} {
								Inf "File [file rootname [file tail $tsp0]] is not a brkpnt file"
								unset cmd
								continue
							} elseif {($pa($tsp0,$evv(MAXBRK)) > $evv(TS_MAXOCT)) || ($pa($tsp0,$evv(MINBRK)) < 0)} {
								Inf "File [file rootname [file tail $tsp0]] is out of range"
								unset cmd
								continue
							}		
						} elseif {($tsp0 < 0) || ($tsp0 > 16)} {
							Inf "Downsampling value out of range (0-16 octaves)"
							unset cmd
							continue
						}
						lappend cmd $tsp0
						set orig_tsduro [expr $tsdur * pow(2.0,$tsp0)]
						set tsmaxdur [string trim $tsmaxdur]
						if {[string length $tsmaxdur] > 0} {
							if {![IsNumeric $tsmaxdur]} {
								Inf "Invalid maximum duration entered"
								unset cmd
								continue
							} elseif {($tsmaxdur < 1) || ($tsmaxdur > 600)} {
								Inf "Maximum duration value out of range (1 - 600 secs)"
								unset cmd
								continue
							}
							if {$tsforce || ($tsmaxdur < $orig_tsduro)} {
								set tsduro $tsmaxdur
							} else {
								set tsduro $orig_tsduro
							}
							lappend cmd -d$tsmaxdur
						} elseif {$orig_tsduro > 60} {
							set msg "(Maximum) output duration is [convdurtohrs $orig_tsduro]: set a duration limit ?" 
							set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
							if {$choice == "yes"} {
								unset cmd
								continue
							} else {
								set tsduro $orig_tsduro
							}
						} else {
							set tsduro $orig_tsduro
						}
					}
					"trace" {
						set tsharmonics [string trim $tsharmonics]
						
						if {[string length $tsharmonics] <= 0} {
							if {[info exists tsmany]} {
								Inf "No partials file specified"
								unset cmd
								continue
							} else {
								lappend cmd 0
							}
						} else {
							if {![file exists $tsharmonics]} {
								Inf "Partials data file $tsharmonics does not exist"
								unset cmd
								continue
							} elseif {![ValidTsHarmonicsDataFile $tsharmonics]} {
								unset cmd
								continue
							}
							if {[info exists tsmany]} {
								if {$ts_harmcnt < [llength $tsdata]} {
									Inf "Not enough partials ($ts_harmcnt) for the number of data files selected ([llength $tsdata])"
									unset cmd
									continue

								} elseif {$ts_harmcnt > [llength $tsdata]} {
									set msg "Too many partials ($ts_harmcnt) for the number of data files selected ([llength $tsdata])\n\n"
									append msg "Proceed without the later partials ?"
									set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
									if {$choice == "no"} {
										unset cmd
										continue
									}
								}
								lappend cmd 0	;#	partials file not used directly
							} else {
								lappend cmd $tsharmonics
							}
						}
						set tsp0 [string trim $tsp0]
						if {[string length $tsp0] <= 0} {
							set tsp0 1
						} elseif {![IsNumeric $tsp0]} {
							if {![file exists $tsp0]} {
								Inf "File [file rootname [file tail $tsp0]] does not exist"
								unset cmd
								continue
							} elseif {![info exists pa($tsp0,$evv(FTYP))]} {
								Inf "File [file rootname [file tail $tsp0]] is not on the workspace: cannot proceed"
								unset cmd
								continue
							} elseif {![IsABrkfile $pa($tsp0,$evv(FTYP))]} {
								Inf "File [file rootname [file tail $tsp0]] is not a brkpnt file"
								unset cmd
								continue
							} elseif {($pa($tsp0,$evv(MAXBRK)) > $evv(TS_MAXTSTRETCH)) || ($pa($tsp0,$evv(MINBRK)) < 1)} {
								Inf "File [file rootname [file tail $tsp0]] is out of range"
								unset cmd
								continue
							}		
						} elseif {($tsp0 < 1) || ($tsp0 > 10000)} {
							Inf "Timestretching value out of range (1-10000)"
							unset cmd
							continue
						}
						lappend cmd $tsp0
						set orig_tsduro [expr $tsdur * $tsp0]

						set tsfrq [string trim $tsfrq]
						if {[string length $tsfrq] <= 0} {
							Inf "No centre frequency entered"
							unset cmd
							continue
						} elseif {![IsNumeric $tsfrq]} {
							Inf "Invalid centre frequency value entered"
							unset cmd
							continue
						} elseif {($tsfrq < 16) || ($tsfrq >= 11025)} {
							Inf "Centre frequency value out of range (16-11025 hz)"
							unset cmd
							continue
						}
						lappend cmd $tsfrq

						set tshalfrange [string trim $tshalfrange]
						if {[string length $tshalfrange] <= 0} {
							Inf "No half range entered"
							unset cmd
							continue
						} elseif {![IsNumeric $tshalfrange]} {
							Inf "Invalid half range value entered"
							unset cmd
							continue
						} elseif {($tshalfrange <= 0) || ($tshalfrange >= 48)} {
							Inf "Half range value out of range (0-48 semitones)"
							unset cmd
							continue
						}
						lappend cmd $tshalfrange

						set tsmaxdur [string trim $tsmaxdur]
						if {[string length $tsmaxdur] > 0} {
							if {![IsNumeric $tsmaxdur]} {
								Inf "Invalid maximum duration entered"
								unset cmd
								continue
							} elseif {($tsmaxdur < 1) || ($tsmaxdur > 600)} {
								Inf "Maximum duration value out of range (1 - 600 secs)"
								unset cmd
								continue
							}
							if {$tsforce || ($tsmaxdur < $orig_tsduro)} {
								set tsduro $tsmaxdur
							} else {
								set tsduro $orig_tsduro
							}
							lappend cmd -d$tsmaxdur
						} elseif {$orig_tsduro > 60} {
							set tsduro $orig_tsduro
							set msg "(Maximum) output duration is [convdurtohrs $orig_tsduro]: set a duration limit ?" 
							set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
							if {$choice == "yes"} {
								unset cmd
								continue
							}
						} else {
							set tsduro $orig_tsduro
						}
					}
					default {
						Inf "No output type selected yet"
						unset cmd
						continue
					}
				}
				if {$tscubic} {
					lappend cmd "-c"
				}
				if {$tsforce} {
					if {[string length $tsmaxdur] > 0} {
						lappend cmd "-f"
					}
				}
				CheckForARecalledSetting $cmd
				Block "Generating Sound"
				set done 0
				set n 0
				foreach tsdatafile $tsdata {
					wm title .blocker  "PLEASE WAIT:      Generating sound [file rootname [file tail $tsdatafile]]"
					set cmd [lreplace $cmd 2 2 $tsdatafile]
					set cmd [lreplace $cmd 3 3 $tsoutfnam($n)]
					if {[info exists tsmany]} {
						set h [lindex $ts_harmvals [expr $n * 2]]
						set frq [expr $tsfrq * $h]
						set cmd [lreplace $cmd 6 6 $frq]
					}
					set prg_dun 0
					set prg_abortd 0
					if [catch {open "|$cmd"} CDPidrun] {
						Inf Sound generation failed for file [file rootname [file tail $tsdatafile]]"
						catch {file delete $tsoutfnam($n)}
						incr n
						continue
   					} else {
   						fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
					}
					vwait prg_dun
					if {$prg_abortd} {
						set prg_dun 0
					}
					if {!$prg_dun} {
						Inf "Failed to generate sound from file [file rootname [file tail $tsdatafile]]"
						catch {file delete $tsoutfnam($n)}
						incr n
						continue
					}
					incr n
					set done 1
				}
				UnBlock
				if {$done} {
					Inf "Sounds generated"							
					catch {unset tsplaylist}
					catch {unset tsdatanamlist}
					set n 0
					while {$n < $files_to_process} {
						if {[file exists $tsoutfnam($n)]} {
							lappend tsplaylist $tsoutfnam($n)
							lappend tsdatanamlist [lindex $tsdata $n]
						}
						incr n
					}
				} else {
					Inf "No sounds generated"							
				}
			}
			2 -
			6 {
				if {![info exists tsplaylist]} {
					Inf "No sounds to play"
					continue
				} elseif {[llength $tsplaylist] != $files_to_process} {
					set msg "Not all files were turned into sound: listen anyway?"
					set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
				}
				if {[llength $tsplaylist] == 1} {
					set this_fnam [lindex $tsplaylist 0]
					if {$pr_ts == 2} {
						PlaySndfile $this_fnam 0
					} else {
						if {![info exists pa($this_fnam,$evv(FTYP))]} {
							if {[DoParse $this_fnam 0 0 0] <= 0} {
								Inf "File parsing failed : cannot view file"
							}
						}
						SnackDisplay 0 $evv(SN_FILE_PRMPAGE_NO_OUTPUT) 0 $this_fnam
					}
				} else {
					TsPlayList
				}
			}
			3 {
				if {![info exists tsplaylist]} {
					Inf "No sounds to save"
					continue
				}
				Block "Saving Files"				
				catch {unset outnnams}
				set ts_copynames 0
				set ts_prefix 0
				if {$tsdatanamtype} {
					set ts_copynames 1
					if {$tsdatanamtype == 2} {
						catch {unset prenam}
						set ts_prefix 1
						if {[info exists ts_setting]} {
							set msg "Prefix names with name of the sound-conversion settings name already defined ?"
							set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
							if {$choice == "yes"} {
								set prenam [string tolower $ts_setting]
							}
						}
						if {![info exists prenam]} {
							if {[string length $tsfnam] <= 0} {
								Inf "No output soundfile prefix given"
								UnBlock
								continue
							}
							if {![ValidCDPRootname $tsfnam]} { 
								UnBlock
								continue
							}
							set prenam [string tolower $tsfnam]
						}
					}
					set OK 1
					foreach nam $tsdatanamlist {
						set outfnam [file rootname [file tail $nam]]
						if {$ts_prefix} {
							set thisnam $prenam
							append thisnam "_" $outfnam
							set outfnam $thisnam
						}
						append outfnam $evv(SNDFILE_EXT)
						lappend outnnams $outfnam
					}
				} else {
					if {[string length $tsfnam] <= 0} {
						Inf "No output soundfile name given"
						UnBlock
						continue
					}
					if {![ValidCDPRootname $tsfnam]} { 
						UnBlock
						continue
					}
					if {[llength $tsplaylist] == 1} {
						set outfnam [string tolower $tsfnam]
						append outfnam $evv(SNDFILE_EXT)
						set outnnams $outfnam
					} else {
						set OK 1
						set n 1
						foreach snd_output $tsplaylist {
							set outfnam [string tolower $tsfnam]
							append outfnam $n $evv(SNDFILE_EXT)
							lappend outnnams $outfnam
							incr n
						}
					}
				}
				set OK 1
				set checkexists 0
				foreach outfnam $outnnams {
					if {[file exists $outfnam]} {
						if {!$checkexists} {
							set msg "A file with the name [file rootname [file tail $outfnam]] already exists: overwrite ~~all~~ such files ?"
							set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
							if {$choice == "no"} {
								set OK 0
								break
							}
							set checkexists 1
						}
						if {[DeleteFileFromSystem $outfnam 1 1]} {
							if {[IsInAMixfile $outfnam]} {
								MixM_ManagedDeletion $outfnam
								MixMStore
							}
							set i [LstIndx $outfnam $wl]	;#	remove from workspace listing, if there
							if {$i >= 0} {
								$wl delete $i
								WkspCnt $outfnam -1
								catch {unset rememd}
							}
						} else {
							Inf "Cannot delete file $outfnam : choose a different name"
							set OK 0
							break
						}
					}
				}
				if {!$OK} {
					UnBlock
					continue
				}
				set done 0
				set m 0
				catch {unset out_files}
				foreach snd_output $tsplaylist outfnam $outnnams {
					if [catch {file rename $snd_output $outfnam} zit] {
						Inf "Failed to save soundfile output from [file rootname [file tail [lindex $tsdatanamlist $m]]]"
						incr m
						continue
					}
					set done 1
					lappend out_files $outfnam
					DummyHistory $outfnam "CREATED"
					incr m
				}
				if {$done} {
					set out_files [ReverseList $out_files]
					foreach fnam $out_files {
						FileToWkspace $fnam 0 0 0 0 1
					}
					set last_outfile $out_files
					catch {unset tsplaylist}
					catch {unset tsdatanamlist}
					Inf "Files are on the workspace"
				} else {
					Inf "No files saved"
				}
				UnBlock
			}
			4 {
				if {![info exists tsplaylist]} {
					Inf "No sounds generated"
					continue
				}
				StoreTsCommand $cmd
			}
			5 {
				GetTsCommand
			}
			7 {
				$tslist selection set 0 end
			}
			8 {
				set fff [GetDataStretchFile]
				if {[string length $fff] > 0} {
					set tsp0 $fff
				}
			}
			9 { 
				ViewTs
			}
			10 {
				TsOutdur
			}
			11 {
				TsBylen 0
			}
			12 {
				TsBylen 1
			}
			13 {
				PlayMultichanTs
			}
			14 {
				PlaySequenceTs
			}
			15 {
				PlayMixTs 0
			}
			16 {
				PlayMixTs 1
			}
			17 {
				GetTsFuncSource
			}
			18 {
				set files_to_process [RunTsFunc]
			}
			19 {
				TsLongest
			}
			20 {
				if {[info exists ts_previous]} {
					$tslist selection clear 0 end
					foreach i $ts_previous {
						$tslist selection set $i
					}
				}
			}
			21 {
				SaveTsProcess
			}
			22 {
				GetTsProcess
			}
			23 {
				SaveTsMix
			}
		}
	}
	if {[info exists ts_parsed]} {
		foreach fnam $ts_parsed {
			catch {PurgeProps $fnam}
		}
	}
	if {[info exists last_tsfrq]} {
		set last_last_tsfrq $last_tsfrq
	}
	if {[info exists last_tshalfrange]} {
		set last_last_tshalfrange $last_tshalfrange
	}
	if {[info exists last_tsharmonics]} { 
		set last_last_tsharmonics $last_tsharmonics
	}
	if {[info exists tscubic_trace]} { 
		set last_tscubic_trace $tscubic_trace
	}
	if {[info exists tscubic_oscil]} {
		set last_tscubic_oscil $tscubic_oscil
	}
	if {[info exists tsforce_trace]} { 
		set last_tsforce_trace $tsforce_trace
	}
	if {[info exists tsforce_oscil]} {
		set last_tsforce_oscil $tsforce_oscil
	}
	if {[info exists tsmode]} {
		set last_tsmode $tsmode
	}
	PutHelpInActiveMode .ts.0
	DisableHelp .ts.0
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	set pr_uberdata 0
}

#--- Either run Tseries synth, or run as control-file

proc DoTs {} {
	global pr_ts ts_emph
	if {$ts_emph == ".ts.a.2.go"} {
		set pr_ts 1
	} else {
		set pr_ts 18
	}
}

#--- Establish parameter-entry interface appropriate for selected synthesis approach

proc TimeSeriesParamSet {typ} {
	global tsmode tsp0min tsp0max last_tsfrq tsfrq last_tshalfrange tshalfrange last_tsharmonics tsharmonics
	global tscubic_trace tscubic_oscil tscubic tsforce_trace tsforce_oscil tsforce tsmany TsDeleteCmd
	global tsbrkstep
	catch {unset tsmany}
	catch {eval $TsDeleteCmd}
	switch -- $typ {
		"init" {
			set tsmode ""
			.ts.a.3.ll config -text ""
			.ts.a.3.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.ts.a.3.ll2 config -text ""
			.ts.a.3.e2 config -bd 0 -state disabled -disabledbackground [option get . background {}]
			set tsfrq ""
			.ts.a.4.cubic config -bd 0 -text "" -state disabled
			set tscubic 0
			.ts.a.4.force config -bd 0 -text "" -state disabled
			set tsforce 0
			.ts.a.5.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.ts.a.5.ll config -text "" 
			set tshalfrange ""
			.ts.a.6.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.ts.a.6.ll config -text "" 
			set tsharmonics ""
			.ts.a.7.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.ts.a.7.ll config -text "" 
			.ts.a.7.gf config -bd 0 -text "" -command {}
			set tsbrkstep ""
		}
		"amp" {
			SetupTsFunc -1
			set tsmode "oscil"
			set tsp0min 0
			set tsp0max 16
			.ts.a.3.ll config -text "Octaves to Downsample (0-16)" -state normal
			.ts.a.3.e config -state normal -bd 2
			.ts.a.3.ll2 config -text "Optional duration limit" -state normal
			.ts.a.3.e2 config -state normal -bd 2
			.ts.a.4.cubic config -text "Cubic spline interpolation" -state normal
			.ts.a.4.force config -text "Loop to given duration if too short" -state normal
			if {[info exists tsfrq]} {
				set last_tsfrq $tsfrq
			}
			set tsfrq ""
			.ts.a.5.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.ts.a.5.ll config -text "" 
			if {[info exists tshalfrange]} {
				set last_tshalfrange $tshalfrange
			}
			set tshalfrange ""
			.ts.a.6.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.ts.a.6.ll config -text "" 
			if {[info exists tsharmonics]} {
				set last_tsharmonics $tsharmonics
			}
			set tsharmonics ""
			.ts.a.7.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.ts.a.7.ll config -text "" 
			.ts.a.7.gf config -bd 0 -text "" -command {}
			set tscubic_trace $tscubic
			set tsforce_trace $tsforce
			if {[info exists tscubic_oscil]} {
				set tscubic $tscubic_oscil
			} else {
				set tscubic 0
			}
			if {[info exists tsforce_oscil]} {
				set tsforce $tsforce_oscil
			} else {
				set tsforce 0
			}
			focus .ts.a.3.e		
			bind .ts.a.2.ee <Down>  {focus .ts.a.3.e2}
			bind .ts.a.2.ee <Left>  {focus .ts.a.3.e2}
			bind .ts.a.2.ee <Right> {focus .ts.a.3.e}
			bind .ts.a.2.ee <Up>    {focus .ts.a.3.e}

			bind .ts.a.3.e  <Up>	  {focus .ts.a.2.ee}
			bind .ts.a.3.e  <Right> {focus .ts.a.3.e2} 
			bind .ts.a.3.e  <Down>  {focus .ts.a.2.ee}
			bind .ts.a.3.e  <Left>  {focus .ts.a.2.ee}

			bind .ts.a.3.e2 <Up>	  {focus .ts.a.2.ee}
			bind .ts.a.3.e2 <Left>  {focus .ts.a.3.e} 
			bind .ts.a.3.e2 <Right> {focus .ts.a.2.ee} 
			bind .ts.a.3.e2 <Down>  {focus .ts.a.2.ee}

			bind .ts.a.5.e  <Up>	{}
			bind .ts.a.5.e  <Down>  {}
			bind .ts.a.5.e  <Right> {} 
			bind .ts.a.5.e  <Left>  {}

			bind .ts.a.6.e  <Up>	{}
			bind .ts.a.6.e  <Down>  {}
			bind .ts.a.6.e  <Right> {} 
			bind .ts.a.7.e  <Left>  {}

			bind .ts.a.7.e  <Up>	{}
			bind .ts.a.7.e  <Down>  {}
			bind .ts.a.7.e  <Right> {} 
			bind .ts.a.7.e  <Left>  {}

		}
		"pitch" -
		"many" {
			SetupTsFunc -1
			set tsmode "trace"
			if {$typ == "many"} {
				set tsmany 1
			}
			set tsp0min 1
			set tsp0max 10000
			.ts.a.3.ll config -text "Time Stretch by (1 - 10000)" -state normal
			.ts.a.3.e config -state normal -bd 2
			.ts.a.3.ll2 config -text "Optional duration limit" -state normal
			.ts.a.3.e2 config -state normal -bd 2
			.ts.a.4.cubic config -text "Cubic spline interpolation" -state normal
			.ts.a.4.force config -text "Loop to given duration if too short" -state normal
			if {[info exists last_tsfrq]} {
				set tsfrq $last_tsfrq
			} else {
				set tsfrq ""
			}
			.ts.a.5.e config -bd 2 -state normal
			.ts.a.5.ll config -text "Centre Frq of output" 
			if {[info exists last_tshalfrange]} {
				set tshalfrange $last_tshalfrange
			} else {
				set tshalfrange ""
			}
			.ts.a.6.e config -bd 2 -state normal
			.ts.a.6.ll config -text "Half-Range of output (semitones)" 
			if {[info exists last_tsharmonics]} {
				set tsharmonics $last_tsharmonics
			} else {
				set tsharmonics ""
			}
			.ts.a.7.e config -bd 2 -state normal
			if {$typ == "many"} {
				.ts.a.7.ll config -text "Harmonics : Obligatory file listing harmonic-no/amplitude pairs" 
			} else {
				.ts.a.7.ll config -text "Harmonics : Optional File listing harmonic-no/amplitude pairs" 
			}
			.ts.a.7.gf config -bd 2 -text "Get File" -command GetTsHarmonicsFile
			set tscubic_oscil $tscubic
			if {[info exists tscubic_trace]} {
				set tscubic $tscubic_trace
			} else {
				set tscubic 0
			}
			set tsforce_oscil $tsforce
			if {[info exists tsforce_trace]} {
				set tsforce $tsforce_trace
			} else {
				set tsforce 0
			}
			 focus .ts.a.3.e		
			bind .ts.a.2.ee <Down>  {focus .ts.a.3.e2}
			bind .ts.a.2.ee <Left>  {focus .ts.a.3.e2}
			bind .ts.a.2.ee <Right> {focus .ts.a.3.e}
			bind .ts.a.2.ee <Up>    {focus .ts.a.7.e}
	
			bind .ts.a.3.e  <Up>	{focus .ts.a.2.ee}
			bind .ts.a.3.e  <Right> {focus .ts.a.3.e2} 
			bind .ts.a.3.e  <Down>  {focus .ts.a.5.e}
			bind .ts.a.3.e  <Left>  {focus .ts.a.2.ee} 

			bind .ts.a.3.e2 <Up>	{focus .ts.a.2.ee}
			bind .ts.a.3.e2 <Left>  {focus .ts.a.3.e} 
			bind .ts.a.3.e2 <Right> {focus .ts.a.2.ee} 
			bind .ts.a.3.e2 <Down>  {focus .ts.a.5.e} 

			bind .ts.a.5.e  <Up>	{focus .ts.a.3.e}
			bind .ts.a.5.e  <Down>  {focus .ts.a.6.e}
			bind .ts.a.5.e  <Right> {focus .ts.a.3.e2} 
			bind .ts.a.5.e  <Left>  {focus .ts.a.2.ee} 

			bind .ts.a.6.e  <Up>	{focus .ts.a.5.e}
			bind .ts.a.6.e  <Down>  {focus .ts.a.7.e}
			bind .ts.a.6.e  <Right> {focus .ts.a.3.e2} 
			bind .ts.a.6.e  <Left>  {focus .ts.a.2.ee} 

			bind .ts.a.7.e  <Up>	{focus .ts.a.6.e}
			bind .ts.a.7.e  <Down>  {focus .ts.a.2.ee}
			bind .ts.a.7.e  <Right> {focus .ts.a.3.e2} 
			bind .ts.a.7.e  <Left>  {focus .ts.a.2.ee} 
		}
	}
}

#---- Select a textfile to define harmonic-nos/amps

proc GetTsHarmfile {} {
	global pr_tshf tsharmlist tsharmonics
	set i [$tsharmlist curselection]
	if {$i >= 0} {
		set tsharmonics [$tsharmlist get $i]
		return 1
	} else {
		Inf "No file selected"
		return 0
	}
}

proc SeeTsHarmfile {y see} {
	global pr_tshf tsharmlist tsharmonics ts_harm_list tszit tsharm_select
	set i [$tsharmlist nearest $y]
	if {$see} {
		set fnam [$tsharmlist get $i]
		set tsharm_select $i
		if [catch {open $fnam "r"} tszit] {
			return
		}
		while {[gets $tszit line] >= 0} {
			lappend nulist $line
		}
		close $tszit
		$tsharmlist delete 0 end
		foreach fnam $nulist {
			$tsharmlist insert end $fnam
		}
	} else {
		catch {close $tszit}
		$tsharmlist delete 0 end
		foreach fnam $ts_harm_list {
			$tsharmlist insert end $fnam
		}
		if {[info exists tsharm_select]} {
			$tsharmlist selection set $tsharm_select
		}
	}
}

#---- Display potential harmonics textfiles

proc GetTsHarmonicsFile {} {
	global wl evv pr_tshf tsharmlist ts_harm_list pa
	set cnt 0
	foreach fnam [$wl get 0 end] {
		if {[IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
			if {[info exists chlist]} {
				if {[lsearch $chlist $fnam] >= 0} {
					continue
				}
			}
			lappend hfiles $fnam
		}
	}
	if {![info exists hfiles]} {
		Inf "No partials files exist"
		return
	}
	set f .tshf
	if [Dlg_Create $f "Possible partials files" "set pr_tshf 0" -borderwidth 2] {
		frame $f.0
		button $f.0.qu  -text "Quit" -command "set pr_tshf 0" -highlightbackground [option get . background {}]
		button $f.0.ss  -text "Select" -command "set pr_tshf 1" -highlightbackground [option get . background {}]
		pack $f.0.ss -side left
		pack $f.0.qu -side right
		pack  $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.tit -text "See file with Click-Hold" -fg $evv(SPECIAL)
		set tsharmlist [Scrolled_Listbox $f.1.ll -width 64 -height 32 -selectmode single]
		pack $f.1.tit $f.1.ll -side top -pady 2
		pack $f.1 -side top
		wm resizable $f 1 1
		bind $f <Return> {set pr_tshf 0}
		bind $f <Escape> {set pr_tshf 0}
		bind $tsharmlist <ButtonPress-1> {SeeTsHarmfile %y 1}
		bind $tsharmlist <ButtonRelease-1> {SeeTsHarmfile %y 0}
	}
	set ts_harm_list {}
	$tsharmlist delete 0 end
	foreach fnam $hfiles {
		$tsharmlist insert end $fnam
		lappend ts_harm_list $fnam
	}
	set pr_tshf 0
	update idletasks
	raise $f
	update idletasks
	My_Grab 0 $f pr_tshf
	update idletasks
	set finished 0
	while {!$finished} {
		tkwait variable pr_tshf
		if {$pr_tshf} {
			if {[GetTsHarmfile]} {
				break
			}
		} else {
			break
		}
	}	
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#----- Check syntax of textdata harminc-no/amplitude for timeseries harmonics

proc ValidTsHarmonicsDataFile {fnam} {
	global ts_harmvals ts_harmcnt
	catch {unset ts_harmvals}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot open file $fnam to test data"
		return 0
	}
	set ts_harmcnt 0
	while {[gets $zit line] >= 0} {
		set is_hno 1
		set vals [string trim $line]
		if {[string length $vals] <= 0} {
			continue
		}
		set vals [split $vals]
		set cnt 0
		foreach val $vals {
			if {[string length $val] > 0} {
				if {$is_hno} {
					if {![IsNumeric $val] || ($val < 1) || ($val > 100)} {
						Inf "Invalid partial number $val (range 1 - 100) in file [file rootname [file tail $fnam]]"
						catch {close $fnam}
						return 0
					}
					lappend ts_harmvals $val
					set is_hno 0
					incr cnt
				} else {
					if {![IsNumeric $val] || ($val <= 0) || ($val > 1)} {
						Inf "Invalid partial amplitude $val (range >0 - 1) in file [file rootname [file tail $fnam]]"
						catch {close $fnam}
						return 0
					}
					lappend ts_harmvals $val
					set is_hno 1
					incr cnt
				}
			}
		}
		incr ts_harmcnt
		if {$cnt != 2} {
			Inf "Values not paired correctly on line $ts_harmcnt in file [file rootname [file tail $fnam]]""
			catch {close $fnam}
			return 0
		}
	}
	if {$ts_harmcnt <= 0} {
		Inf "No data found in file [file rootname [file tail $fnam]]""
		catch {close $fnam}
		return 0
	}
	catch {close $zit}
	return 1
}

#------ Remember timeseries commandline

proc StoreTsCommand {cmd} {
	global tscmds pr_tscmdstor tscmdname tscmdlst tscmdshow ts_setting ts_setting_cmd tsharmonics tsmany wstk evv 
	set storedcmd [lreplace $cmd 0 0 "ts"]
	set storedcmd [lreplace $storedcmd 2 2 "indata"]
	set storedcmd [lreplace $storedcmd 3 3 "outsnd"]
	if {[info exists tsmany]} {
		set storedcmd [lreplace $cmd 4 4 $tsharmonics]		;#	tsharmonics file needed for mode using MANY spearate harmonics
		set storedcmd [lreplace $cmd 6 6 $tsfrq]			;#	even though this file does not occur in the cmdline + need orig frq
	}			
	set nulen [llength $storedcmd]
	if {[info exists tscmds]} {
		set ismatch 0
		foreach tscmd $tscmds {
			if {[llength $tscmd] != $nulen} {
				continue
			}
			set ismatch 1
			foreach aa [lrange $tscmd 1 end] bb [lrange $storedcmd 1 end] {
				if {![string match $aa $bb]} {
					set ismatch 0
					break
				}
			}
			if {$ismatch} {
				Inf "These settings are already stored as [lindex $tscmd 0]"
				set ts_setting [lindex $tscmd 0]
				set ts_setting_cmd $tscmd
				return
			}
		}
	}
	set f .tscmdstor
	if [Dlg_Create $f "Save timeseries conversion settings" "set pr_tscmdstor 0" -borderwidth 2] {
		frame $f.0
		button $f.0.qu  -text "Quit" -command "set pr_tscmdstor 0" -highlightbackground [option get . background {}]
		button $f.0.ss  -text "Save" -command "set pr_tscmdstor 1" -highlightbackground [option get . background {}]
		pack $f.0.ss -side left
		pack $f.0.qu -side right
		pack  $f.0 -side top -fill x -expand true
		frame $f.00
		entry $f.00.e -textvariable tscmdshow -width 120 -state readonly
		pack $f.00.e -side left
		pack $f.00 -side top -pady 2
		frame $f.1
		label $f.1.ll -text "Name for saved settings"
		entry $f.1.e -textvariable tscmdname -width 24
		pack  $f.1.ll $f.1.e -side left -padx 2
		pack $f.1 -side top -pady 2
		frame $f.2
		label $f.2.tit -text "Existing Timeseries Conversion Settings" -fg $evv(SPECIAL)
		set tscmdlst [Scrolled_Listbox $f.2.ll -width 128 -height 32 -selectmode single]
		pack $f.2.tit $f.2.ll -side top -pady 2
		pack $f.2 -side top
		wm resizable $f 1 1
		bind $f <Return> {set pr_tscmdstor 1}
		bind $f <Escape> {set pr_tscmdstor 0}
	}
	set tscmdshow $storedcmd 
	$tscmdlst delete 0 end
	if {[info exists tscmds]} { 
		foreach tscmd $tscmds {
			$tscmdlst insert end $tscmd
		}
	}
	set pr_tscmdstor 0
	update idletasks
	raise $f
	update idletasks
	My_Grab 0 $f pr_tscmdstor $f.1.e
	update idletasks
	set finished 0
	while {!$finished} {
		tkwait variable pr_tscmdstor
		switch -- $pr_tscmdstor {
			1 {
				if {[string length $tscmdname] <= 0} {
					Inf "No settings name given"
					continue
				}
				if {![ValidCDPRootname $tscmdname]} { 
					continue
				}
				set nucmd [lreplace $storedcmd 0 0 [string toupper $tscmdname]]
				if {![info exists tscmds]} { 
					set tscmds [list $nucmd]
				} else {
					set OK 1
					set n 0
					foreach tscmd $tscmds {
						if {[string match [lindex $tscmd 0] [lindex $nucmd 0]]} {
							set msg "This setting name already exists: overwrite the existing saved setting ?"
							set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
							if {$choice == "no"} {
								set OK 0
							} else {
								set tscmds [lreplace $tscmds $n $n]
								$tscmdlst delete $n
							}
							break
						}
						incr n
					}
					if {!$OK} {
						continue
					}

					set ts_setting [lindex $nucmd 0]
					set ts_setting_cmd $nucmd

					lappend tscmds $nucmd
					catch {unset nams}
					foreach tscmd $tscmds {
						lappend nams [lindex $tscmd 0]
					}
					set nams [lsort $nams]
					set nutscmds {}
					foreach nam $nams {
						foreach tscmd $tscmds {
							if {[string match [lindex $tscmd 0] $nam]} {
								lappend nutscmds $tscmd
								break
							}
						}
					}
					set tscmds $nutscmds
				}
				$tscmdlst delete 0 end
				foreach tscmd $tscmds {
					$tscmdlst insert end $tscmd
				}
				StoreTsCmds
			}
			0 {
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#------ Get a specific saved timeseries commandline

proc GetTsCommand {} {
	global tscmds tscmdgetlst pr_tscmdget tscubic tsp0 tsmaxdur tsharmonics tsfrq tshalfrange wstk evv
	global ts_setting ts_setting_cmd tsforce tsmany
	if {![info exists tscmds]} {
		Inf "No settings to load"
		return
	}
	set f .tscmdget
	if [Dlg_Create $f "Get specific timeseries conversion settings" "set pr_tscmdget 0" -borderwidth 2] {
		frame $f.0
		button $f.0.qu  -text "Quit" -command "set pr_tscmdget 0" -highlightbackground [option get . background {}]
		button $f.0.ss  -text "Use" -command "set pr_tscmdget 1" -highlightbackground [option get . background {}]
		button $f.0.dd  -text "Delete" -command "set pr_tscmdget 2" -highlightbackground [option get . background {}]
		pack $f.0.ss $f.0.dd -side left -padx 12
		pack $f.0.qu -side right
		pack  $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.tit -text "Select Settings with mouse" -fg $evv(SPECIAL)
		set tscmdgetlst [Scrolled_Listbox $f.1.ll -width 128 -height 32 -selectmode single]
		pack $f.1.tit $f.1.ll -side top -pady 2
		pack $f.1 -side top
		wm resizable $f 1 1
		bind $f <Return> {set pr_tscmdget 1}
		bind $f <Escape> {set pr_tscmdget 0}
	}
	$tscmdgetlst delete 0 end
	foreach tscmd $tscmds {
		$tscmdgetlst insert end $tscmd
	}
	set pr_tscmdget 0
	update idletasks
	raise $f
	update idletasks
	My_Grab 0 $f pr_tscmdget
	update idletasks
	set finished 0
	while {!$finished} {
		tkwait variable pr_tscmdget
		switch -- $pr_tscmdget {
			0 {
				set finished 1
			}
			1 {
				set i [$tscmdgetlst curselection]
				if {$i < 0} {
					Inf "No settings selected"
					continue
				}
				set ts_setting_cmd [$tscmdgetlst get $i]
				set ts_setting [string tolower [lindex $ts_setting_cmd 0]]
				switch -- [lindex $ts_setting_cmd 1] {
					"oscil" {
						TimeSeriesParamSet amp
						set tscubic 0
						set tsforce 0
						set tsp0 [lindex $ts_setting_cmd 4]
						if {[llength $ts_setting_cmd] > 5} {
							set flag [string index [lindex $ts_setting_cmd 5] 1]
							switch -- $flag {
								"d" {
									set tsmaxdur [string range [lindex $ts_setting_cmd 5] 2 end]
								}
								"c" {
									set tscubic 1
								}
								"f" {
									set tsforce 1
								}
							}
						}
						if {[llength $ts_setting_cmd] > 6} {
							set flag [string index [lindex $ts_setting_cmd 6] 1]
							switch -- $flag {
								"c" {
									set tscubic 1
								}
								"f" {
									set tsforce 1
								}
							}
						}
						if {[llength $ts_setting_cmd] > 7} {
							set flag [string index [lindex $ts_setting_cmd 7] 1]
							switch -- $flag {
								"c" {
									set tscubic 1
								}
								"f" {
									set tsforce 1
								}
							}
						}
					}
					"trace" {
						set hfile [lindex $ts_setting_cmd 4]
						if {[info exists tsmany]} {
							if {![file exists $hfile]} {
								set msg "This partials file no longer exists"
								continue
							}
						} else {
							if {![string match $hfile "0"] && ![file exists $hfile]} {
								set msg "This partials file no longer exists: load rest of settings ?"
								set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
								if {$choice == "no"} {
									continue
								}
							}
						}
						if {[info exists tsmany]} {
							TimeSeriesParamSet many
						} else {
							TimeSeriesParamSet pitch
						}
						set tscubic 0
						set tsforce 0
						if {[string match $hfile "0"] || [file exists $hfile]} {
							set tsharmonics $hfile
						} else {
							set tsharmonics ""
						}
						set tsp0 [lindex $ts_setting_cmd 5]
						set tsfrq [lindex $ts_setting_cmd 6]
						set tshalfrange [lindex $ts_setting_cmd 7]
						if {[llength $ts_setting_cmd] > 8} {
							set flag [string index [lindex $ts_setting_cmd 8] 1]
							switch -- $flag {
								"d" {
									set tsmaxdur [string range [lindex $ts_setting_cmd 8] 2 end]
								}
								"c" {
									set tscubic 1
								}
								"f" {
									set tsforce 1
								}
							}
						}
						if {[llength $ts_setting_cmd] > 9} {
							set flag [string index [lindex $ts_setting_cmd 9] 1]
							switch -- $flag {
								"c" {
									set tscubic 1
								}
								"f" {
									set tsforce 1
								}
							}
						}
						if {[llength $ts_setting_cmd] > 10} {
							set flag [string index [lindex $ts_setting_cmd 10] 1]
							switch -- $flag {
								"c" {
									set tscubic 1
								}
								"f" {
									set tsforce 1
								}
							}
						}
					}
				}
				set finished 1
			} 
			2 {
				set i [$tscmdgetlst curselection]
				if {$i < 0} {
					Inf "No settings selected"
					continue
				}
				set msg "Are you sure you want to delete these specific settings ?"
				set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				$tscmdgetlst delete $i
				set tscmds [lreplace $tscmds $i $i]
				if {[llength $tscmds] <= 0} {
					unset tscmds
					set scidir [file join $evv(URES_DIR) science]
					set tscmdstore [file join $scidir tscmds$evv(CDP_EXT)]
					catch {file delete $tscmdstore}
					set finished 1
				} else {
					StoreTsCmds
				}
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#------ Store to backup ts-cmdlines, when a new one is saved on interface

proc StoreTsCmds {} {
	global tscmds evv
	set scidir [file join $evv(URES_DIR) science]
	set tscmdstore [file join $scidir tscmds$evv(CDP_EXT)]
	if [catch {open $tscmdstore "w"} zit] {
		Inf "Cannot open file [file rootname [file tail $tscmdstore]] to store timestretch settings data"
		return
	}
	foreach tscmd $tscmds {
		puts $zit $tscmd 
	}
	close $zit
}

#------ Load backed-up ts-cmdlines

proc LoadTsCmds {} {
	global tscmds evv
	set scidir [file join $evv(URES_DIR) science]
	set tscmdstore [file join $scidir tscmds$evv(CDP_EXT)]
	if {![file exists $tscmdstore]} {
		return
	}
	if [catch {open $tscmdstore "r"} zit] {
		Inf "Cannot open file [file rootname [file tail $tscmdstore]] to read timestretch settings data"
		return
	}
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
			lappend tscmds $nuline
		}
	}
	close $zit
}

#---- Play timeseries sound outputs from a playlist

proc TsPlayList {} {
	global tsdata pr_tsplay tsplaylist tsdatanamlist tsplay_display ts_parsed pa evv 
	set f .tsplay
	foreach fnam $tsplaylist {
		if {![info exists pa($fnam,$evv(FTYP))]} {
			if {[DoParse $fnam 0 0 0] <= 0} {
				set view_off 1
				break
			}
			if {[info exists ts_parsed]} {
				set k [lsearch $ts_parsed $fnam] 
			} else {
				set k -1
			}
			if {$k < 0} {
				lappend ts_parsed $fnam
			}
		}
	}
	if [Dlg_Create $f "Play or view sound outputs" "set pr_tsplay 0" -borderwidth 2] {
		frame $f.0
		button $f.0.qu -text "Quit" -command "set pr_tsplay 0" -highlightbackground [option get . background {}]
		button $f.0.pp -text "View" -command "set pr_tsplay 1" -bg $evv(SNCOLOR) -highlightbackground [option get . background {}]
		pack $f.0.pp -side left
		pack $f.0.qu -side right
		pack  $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.tit -text "Play selected Sound with space-bar" -fg $evv(SPECIAL)
		set tsplay_display [Scrolled_Listbox $f.1.ll -width 128 -height 32 -selectmode single]
		pack $f.1.tit $f.1.ll -side top -pady 2
		pack $f.1 -side top
		wm resizable $f 1 1
		bind $f <Key-space> {PlayTs}
		bind $f <Return> {set pr_tsplay 1}
		bind $f <Escape> {set pr_tsplay 0}
	}
	if {[info exist view_off]} {
		$f.0.pp config -bg [option get .background {}] -bd 0 -command {}
	} else {
		$f.0.pp config -bg $evv(SNCOLOR) -bd 2 -command "set pr_tsplay 1"
	}
	$tsplay_display delete 0 end
	foreach nam $tsdatanamlist {
		$tsplay_display insert end $nam
	}
	set pr_tsplay 0
	update idletasks
	raise $f
	update idletasks
	My_Grab 0 $f pr_tsplay
	update idletasks
	set finished 0
	while {!$finished} {
		tkwait variable pr_tsplay
		if {$pr_tsplay} {
			if {[llength $tsdatanamlist] == 1} {
				set  i 0
			} else {
				set i [$tsplay_display curselection]
				if {$i < 0} {
					Inf "No item selected"
					continue
				}
			}
			set fnam [lindex $tsplaylist $i]
			SnackDisplay 0 $evv(SN_FILE_PRMPAGE_NO_OUTPUT) 0 $fnam
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc PlayTs {} {
	global tsplay_display tsplaylist
	set i [$tsplay_display curselection]
	if {$i < 0} {
		Inf "No sound SELECTED"
		return
	}
	set fnam [lindex $tsplaylist $i]
	PlaySndfile $fnam 0
}

#--- Are we still using params realled from store

proc CheckForARecalledSetting {cmd} {
	global ts_setting ts_setting_cmd
	if {![info exists ts_setting_cmd]} {
		return
	}
	if {[llength $cmd] != [llength $ts_setting_cmd]} {
		unset ts_setting
		unset ts_setting_cmd
		return
	}
	set n 0	
	foreach item $cmd s_item $ts_setting_cmd {
		if {($n ==1) || ($n >= 4)} {
			if {![string match $item $s_item]} {
				unset ts_setting
				unset ts_setting_cmd
				break
			}
		}
		incr n
	}
}

##########################
# INCOMPATIBLE FILENAMES #
##########################

proc CopyDirToSubdir {dirname} {
	global pr_dirtosub dirsubname wstk
	set f .dirtosub
	if [Dlg_Create $f "Copy to subdir" "set pr_dirtosub 0" -borderwidth 2 -width 84] {
		frame $f.0
		button $f.0.qu -text "Quit" -command "set pr_dirtosub 0" -highlightbackground [option get . background {}]
		button $f.0.pp -text "Copy" -command "set pr_dirtosub 1" -highlightbackground [option get . background {}]
		pack $f.0.pp -side left
		pack $f.0.qu -side right
		pack  $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Name of subdirectory "
		entry $f.1.ee -textvariable dirsubname
		pack $f.1.ll $f.1.ee -side left -pady 2
		pack $f.1 -side top
		wm resizable $f 1 1
		bind $f <Return> {set pr_dirtosub 1}
		bind $f <Escape> {set pr_dirtosub 0}
	}
	set dirsubname ""
	set pr_dirtosub 0
	update idletasks
	raise $f
	update idletasks
	My_Grab 0 $f pr_dirtosub $f.1.ee
	update idletasks
	set finished 0
	while {!$finished} {
		tkwait variable pr_dirtosub
		if {$pr_dirtosub} {
			if {[string length $dirsubname] <= 0} {
				Inf "No subdirectory name entered"
				continue
			}
			if {![ValidCDPRootname $dirsubname]} { 
				set dirsubname ""
				continue
			}
			set nudir [file join $dirname $dirsubname]
			if {[file exists $nudir]} {
				Inf "Directory or file with this name already exists: choose a different name"
				set dirsubname ""
				continue
			}
			if [catch {file mkdir $nudir} zorg] { 
				Inf "Cannot create new subdirectory $dirsubname"
				set dirsubname ""
				continue
			}
			catch {unset badfiles}
			Block "Copying to Subdir $dirsubname"
			set cnt 0
			foreach fnam [glob -nocomplain [file join $dirname *]] {
				if {[file isdirectory $fnam]} {
					continue
				}
				set fnamtail [file tail $fnam]
				set nufnam [file join $nudir $fnamtail]
				if [catch {file copy $fnam $nufnam} zit] {
					lappend badfiles $fnamtail
				}
				incr cnt
			}
			UnBlock
			if {[info exists badfiles]} {
				if {[llength $badfiles] == $cnt} { 
					Inf "Failed to copy any files to subdirectory"
				} else {
					set msg "The following files failed to copy\n"
					set cnt 0
					foreach fnam $badfiles {
						append msg "$fnam\n"
						incr cnt
						if {$cnt >= 20} {
							append msg "and more"
							break
						}
					}
					Inf $msg
					Block "Aborting Copy"
					foreach fnam [glob -nocomplain [file join $nudir *]] {
						catch {file delete $fnam}
					}
					UnBlock
				}
				catch {file delete -force $nudir}
				set dirsubname ""
			}
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $dirsubname
}

proc CompatibleRename {dirname} {
	global pr_compati dirsubname compatipoint compatiext evv wstk

	foreach fnam [glob -nocomplain [file join $dirname *]] {
		lappend origfnams $fnam
	}
	foreach fnam $origfnams {
		set ftyp [FindFileType $fnam]
		if {!($ftyp & $evv(IS_A_TEXTFILE))} {
			Inf "Not all the files are text files (e.g. [file tail $fnam]): cannot proceed"
			return 0
		}
		if {[string length [file rootname [file tail $fnam]]] <= 0} {		;#	Catches MAC Files like ".DStore"
			lappend badfiles $fnam
			continue
		} else {
			lappend checknams $fnam
		}
	}
	if {[info exists badfiles]} {
		set msg "The following files will not rename\n"
		set cnt 0
		foreach fnam $badfiles {	
			append msg "$fnam\n"
			incr cnt
			if {$cnt >= 20} {
				append msg "and more"
				break
			}
		}
		Inf $msg
	}
	set origfnams $checknams
	catch {unset badfiles}

	set f .compati
	if [Dlg_Create $f "Rename files CDP-compatibly" "set pr_compati 0" -borderwidth 2 -width 84] {
		frame $f.0
		button $f.0.qu -text "Quit" -command "set pr_compati 0" -highlightbackground [option get . background {}]
		button $f.0.pp -text "Rename" -command "set pr_compati 1" -highlightbackground [option get . background {}]
		pack $f.0.pp -side left
		pack $f.0.qu -side right
		pack  $f.0 -side top -fill x -expand true
		frame $f.1
		checkbutton $f.1.point -variable compatipoint -text "\".\" to \"p\""
		checkbutton $f.1.txt -variable compatiext -text "Extension to \".txt\""
		pack $f.1.point $f.1.txt -side left -pady 2 -padx 32
		pack $f.1 -side top
		wm resizable $f 1 1
		bind $f <Return> {set pr_compati 1}
		bind $f <Escape> {set pr_compati 0}
	}
	set compatipoint 0
	set compatiext 0
	set pr_compati 0
	update idletasks
	raise $f
	update idletasks
	My_Grab 0 $f pr_compati $f
	update idletasks
	set finished 0
	while {!$finished} {
		tkwait variable pr_compati
		if {$pr_compati} {
			if {!$compatipoint && !$compatiext} {
				Inf "No modifications flagged"
				continue
			}
			catch {unset nufnams}
			catch {unset outfnams}
			Block "Renaming Files"
			if {$compatipoint} {
				foreach fnam $origfnams {
					set zfnam [file tail $fnam]
					set nufnam [file join $dirname [ReplaceDots $zfnam]]
					lappend nufnams $nufnam
				}
			} else {
				set nufnams $origfnams
			}
			if {$compatiext} {
				foreach fnam $nufnams {
					if {[string match [file extension $fnam] $evv(TEXT_EXT)] && ([lsearch $origfnams $fnam] >= 0)} {
						lappend outfnams ""
					} else {
						set zfnam [file rootname $fnam]
						append zfnam $evv(TEXT_EXT)
						lappend outfnams $zfnam
					}
				}
			} else {
				set outfnams $nufnams
			}
			set OK 1
			foreach fnam $outfnams {
				if {[string length $fnam] > 0} {
					if {[file exists $fnam]} {
						Inf "A file with the name [file tail $fnam] already exists: cannot proceed"
						set OK 0
						break
					}
				}
			}
			if {!$OK} {
				UnBlock
				continue
			}
			catch {unset badfiles}
			set cnt 0
			foreach nam $origfnams nunam $outfnams {
				if {[string length $nunam] > 0} {
					if [catch {file rename $nam $nunam} zit] {
						lappend badfiles $nam
					}
					incr cnt
				}
			}
			if {[info exists badfiles]} {
				if {[llength $badfiles] == $cnt} {
					Inf "No files were renamed"
					UnBlock
					continue
				}
				set msg "The following files failed to be renamed\n"
				set cnt 0
				foreach fnam $badfiles {
					append msg "$fnam\n"
					incr cnt
					if {$cnt >= 20} {
						append msg "and more"
						break
					}
				}
				Inf $msg
			}
			UnBlock
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $pr_compati
}

#------- Find any valid datastretch files on wkspace,and select one

proc GetDataStretchFile {} {
	global tsdatatype datastrfnam pr_datastrf wl pa evv
	set datastrfnam ""
	foreach fnam [$wl get 0 end] {
		if {[IsABrkfile $pa($fnam,$evv(FTYP))]} {
			switch -- $tsdatatype {
				1 {
					if {($pa($fnam,$evv(MAXBRK)) <= $evv(TS_MAXOCT)) && ($pa($fnam,$evv(MINBRK)) >= 1)} {
						lappend possibs $fnam
					}
				}
				2 -
				3 {
					if {($pa($fnam,$evv(MAXBRK)) <= $evv(TS_MAXTSTRETCH)) && ($pa($fnam,$evv(MINBRK)) >= 1)} {
						lappend possibs $fnam
					}
				}
			}
		}
	}
	if {![info exists possibs]} {
		Inf "No appropriate breakpoint files on the workspace"
		return ""
	} elseif {[llength $possibs] == 1} {
		return [lindex $possibs 0]
	}
	set f .datastrf
	if [Dlg_Create $f "Data stretch files" "set pr_datastrf 0" -borderwidth 2 -width 84] {
		frame $f.0
		button $f.0.qu -text "Quit" -command "set pr_datastrf 0" -highlightbackground [option get . background {}]
		button $f.0.pp -text "Use File" -command "set pr_datastrf 1" -highlightbackground [option get . background {}]
		pack $f.0.pp -side left
		pack $f.0.qu -side right
		pack  $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.tit -text "Select a data-stretch file" -fg $evv(SPECIAL)
		Scrolled_Listbox $f.1.ll -width 128 -height 32 -selectmode single
		pack $f.1.tit $f.1.ll -side top -pady 2
		pack $f.1 -side top
		wm resizable $f 1 1
		bind $f <Return> {set pr_datastrf 1}
		bind $f <Escape> {set pr_datastrf 0}
	}
	$f.1.ll.list delete 0 end
	foreach fnam $possibs {
		$f.1.ll.list insert end $fnam
	}
	set pr_datastrf 0
	update idletasks
	raise $f
	update idletasks
	My_Grab 0 $f pr_datastrf $f
	update idletasks
	set finished 0
	while {!$finished} {
		tkwait variable pr_datastrf
		if {$pr_datastrf} {
			set i [$f.1.ll.list curselection]
			if {$i < 0} {
				Inf "No file selected"
				continue
			}
			set datastrfnam [$f.1.ll.list get $i]
			set finished 1
		} else {
			set datastrfnam ""
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $datastrfnam
}

#--- See selected time-series data file

proc ViewTs {} {
	global tslist
	if {[$tslist index end] == 1} {
		$tslist selection set 0
	}
	set i [$tslist curselection]
	if {[llength $i] > 1} {
		Inf "Select just one file"
		return
	}
	if {$i < 0} {
		Inf "No file selected"
		return
	}
	set fnam [$tslist get $i]
	SimpleDisplayTextfile $fnam
}

#--- See duration of sound generated from time-series data file

proc TsOutdur {} {
	global tsdatatype tslist tsmaxdur tsforce tsp0 tsdur tsduro tsminduro evv pa wstk
	if {!$tsdatatype} {
		Inf "No data conversion type set"
		return
	}
	switch -- $tsdatatype {
		1 {
			if {[string length $tsp0] <= 0} {
				set msg "No downsampling octave entered : proceed without downsampling ?"
				set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					return
				} else {
					set tsp0 0
				}
			} elseif {![IsNumeric $tsp0]} {
				Inf "Cannot calculate durations, here, for time-varying values"
				return
			} elseif {($tsp0 < 0) || ($tsp0 > 16)} {
				Inf "Downsampling value out of range (0-16 octaves)"
				return
			}
		}
		2 -
		3 {
			if {[string length $tsp0] <= 0} {
				Inf "No timestretching entered : proceed without timestretching ?"
				set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					return"
				} else {
					set tsp0 1
				}
			} elseif {![IsNumeric $tsp0]} {
				Inf "Cannot calculate durations, here, for time-varying values"
				return
			} elseif {($tsp0 < 1) || ($tsp0 > 10000)} {
				Inf "Timestretching value out of range (1-10000)"
				return
			}
		}
	}
	if {[string length $tsmaxdur] > 0} {
		if {![IsNumeric $tsmaxdur]} {
			Inf "Invalid maximum duration entered"
			return
		} elseif {($tsmaxdur < 1) || ($tsmaxdur > 600)} {
			Inf "Maximum duration value out of range (1 - 600 secs)"
			return
		}
	}
	set ilist [$tslist curselection]
	set len [llength $ilist]
	if {($len <= 0) || (($len == 1) && ($ilist == -1))} {
		Inf "No data files selected"
		return
	}
	foreach i $ilist {
		lappend fnams [$tslist get $i]
	} 
	set fnam [lindex $fnams 0]
	set len $pa($fnam,$evv(ALL_WORDS))
	set mindur $len
	set maxdur $len

	if {[llength $fnams] > 1} {
		foreach fnam [lrange $fnams 1 end] {
			set len $pa($fnam,$evv(ALL_WORDS))
			if {$len > $maxdur} {	
				set maxdur $len
			}
			if {$len < $mindur} {	
				set mindur $len
			}
		}
	}
	set mindur [expr double($mindur)/$evv(TS_SRATE)]
	set maxdur [expr double($maxdur)/$evv(TS_SRATE)]

	set tsdur $maxdur

	switch -- $tsdatatype {
		1 {
			set maxdur [expr $maxdur * pow(2.0,$tsp0)]
			set mindur [expr $mindur * pow(2.0,$tsp0)]
		}
		2 -
		3 {
			set maxdur [expr $maxdur * $tsp0]
			set mindur [expr $mindur * $tsp0]
		}
	}
	if {[string length $tsmaxdur] > 0} {
		if {$tsforce || ($tsmaxdur < $maxdur)} {
			set maxdur $tsmaxdur
		}
		if {$tsforce || ($tsmaxdur < $mindur)} {
			set mindur $tsmaxdur
		}
	}
	set tsduro $maxdur
	set tsminduro $mindur
}

#---- Select data file by length (min/max)

proc TsBylen {longest} {
	global tslist tsmin_indur_at tsmax_indur_at evv
	$tslist selection clear 0 end
	if {$longest} {
		set at $tsmax_indur_at
	} else {
		set at $tsmin_indur_at
	}
	$tslist selection set $at
	if {$at >= $evv(WKSPACE_HEIGHT)} {
		set k [expr double($at)/double([$tslist index end])]
		$tslist yview moveto $k
	} else {
		$tslist yview moveto 0.0
	}
}

#---- Select data file by length : next longest

proc TsLongest {} {
	global tslist ts_maxlens tsmin_indur_at tsmax_indur_at evv
	set ilist [$tslist curselection]
	if {([llength $ilist] <= 0) || (([llength $ilist] == 1) && ($ilist < 0))} {
		set at [lindex $ts_maxlens 0]
	} elseif {([llength $ilist] == 1) && ($ilist == $tsmin_indur_at)} {
		$tslist selection clear $tsmin_indur_at
		$tslist selection set $tsmax_indur_at
	} else {
		foreach zz $ts_maxlens {
			if {[lsearch $ilist $zz] < 0} {
				set at $zz
				break
			}
		}
	}
	if {[info exists at]} {
		$tslist selection set $at
		if {$at >= $evv(WKSPACE_HEIGHT)} {
			set k [expr double($at)/double([$tslist index end])]
			$tslist yview moveto $k
		} else {
			$tslist yview moveto 0.0
		}
	}
}

#--- Change number of channels to mix to multichan output

proc TsChansChange {down} {
	global tsochans tsplaylist
	if {![info exists tsplaylist]} {
		Inf "No sounds to play"
		return
	}
	set len [llength $tsplaylist]
	if {$down} { 
		if {$tsochans > 2} {
			incr tsochans -1
		}
	} else {
		if {$tsochans < $len} {
			incr tsochans
		}
	}
}

proc PlayMultichanTs {} {
	global tsplaylist tsmixf tsoutf tsochans wstk evv simple_program_messages prg_dun prg_abortd CDPidrun tsmultiout
	global tssrcsndchans pa evv playcmd_dummy

	if {[string length $tsochans] <= 0} {
		Inf "No group size selected (use up/dn arrows)"
		return 0
	}
	if {[llength $tsplaylist] <= 0} {
		Inf "No output sounds to play"
		return 0
	} elseif {[llength $tsplaylist] == 1} {
		Inf "Only one output sound to play"
		return 0
	}
	if {$tsochans > 8} {
		set msg "Maximum number of sounds to play as multichan file = 8: reset to 8 ?"
		set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return 0
		}
		set tsochans 8
	}
	Block "Mixing Sounds"
	if {[llength $tsplaylist] > 8} {
		set msg "Play in groups of 8 ??"
		set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			UnBlock
			return 0
		}
	}
	set mixcnt 0
	set channo 1
	foreach fnam $tsplaylist {
		set line $fnam
		if {$tssrcsndchans == 2} {
			lappend line 0.0 2 1:$channo 0.5 2:$channo 0.5
		} else {
			lappend line 0.0 1 1:$channo 1.0
		}
		lappend lines $line
		incr channo
		if {$channo > $tsochans} {
			set tsmixf($mixcnt) $evv(MACH_OUTFNAME)
			set tsoutf($mixcnt) $evv(MACH_OUTFNAME)
			append tsmixf($mixcnt) $mixcnt [GetTextfileExtension mmx]
			append tsoutf($mixcnt) $mixcnt $evv(SNDFILE_EXT)
			catch {file delete $tsmixf($mixcnt)}
			catch {file delete $tsoutf($mixcnt)}
			if [catch {open $tsmixf($mixcnt) "w"} zit] {
				Inf "Cannot open temporary mixfile $tsmixf($mixcnt)"
				PurgeTsMultimixes $mixcnt 
				UnBlock
				return 0
			}
			set line $tsochans
			puts $zit $line
			foreach line $lines {
				puts $zit $line
			}
			close $zit
			catch {unset lines}
			set channo 1
			incr mixcnt
		}
	}
	if {$channo > 1} {
		set tsmixf($mixcnt) $evv(MACH_OUTFNAME)
		set tsoutf($mixcnt) $evv(MACH_OUTFNAME)
		append tsmixf($mixcnt) $mixcnt [GetTextfileExtension mmx]
		append tsoutf($mixcnt) $mixcnt $evv(SNDFILE_EXT)
		if [catch {open $tsmixf($mixcnt) "w"} zit] {
			Inf "Cannot open temporary mixfile $tsmixf($mixcnt)"
			PurgeTsMultimixes $mixcnt 
			UnBlock
			return 0
		}
		set line [expr $channo - 1]
		puts $zit $line
		foreach line $lines {
			puts $zit $line
		}
		close $zit
		incr mixcnt
	}
	set j 0 
	set k 1
	while {$j < $mixcnt} {
		catch {file delete $tsoutf($j)}
		set cmd [file join $evv(CDPROGRAM_DIR) newmix]
		lappend cmd multichan $tsmixf($j) $tsoutf($j)

		catch {unset simple_program_messages}
		set prg_dun 0
		set prg_abortd 0
		wm title .blocker "PLEASE WAIT:        Mixing group $k"			
		if [catch {open "|$cmd"} CDPidrun] {
			ErrShow "Failed to do multichannel mix $k"
			catch {unset CDPidrun}
			PurgeTsMultimixes $mixcnt 
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
			set msg "Mixing group $k failed"
			set msg [AddSimpleMessages $msg]
			ErrShow $msg
			PurgeTsMultimixes $mixcnt 
			UnBlock
			return
		}
		if {![file exists $tsoutf($j)]} {
			set msg "Mixing group $k produced no output file"
			ErrShow $msg
			PurgeTsMultimixes $mixcnt 
			UnBlock
			return
		}
		lappend playlist $tsoutf($j)
		incr j
		incr k
	}
	UnBlock
	if {![info exists playlist]} {
		return 0
	} elseif {[llength $playlist] == 1} {
		set is_playing 0
		set msg "Hear the output ?"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		while {$choice == "yes"} {
			set is_playing 1
			PlaySndfile [lindex $playlist 0] 0			;# PLAY OUTPUT
			set msg "Hear it again ?"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		} 
	} else {
		set endfile [llength $playlist]
		incr endfile -1
		set is_playing 0
		set msg "Hear the outputs ?"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		set k 0
		while {$choice == "yes"} {
			set is_playing 1
			PlaySndfile [lindex $playlist $k] 0			;# PLAY OUTPUTS
			set msg "Hear the same file again ?"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]	
			if {$choice == "no"} {
				if {$k < $endfile} {
					set msg "Hear the next file ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]	
					if {$choice == "yes"} {
						incr k
					}
				} else {
					set msg "Hear all the files again ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						set k 0
					}
				}
			}
		} 
	}
	if {$is_playing && ($playcmd_dummy != "pvplay")} {
		Inf "If there is a play-program display\nyou must close it before proceeding!!"
	}
	set tsmultiout [list "multi" [llength $playlist]]
}

#--- Get rid of temporary mixes and snds from ts interface multichannel mixes

proc PurgeTsMultimixes {mixcnt} {
	global tsmixf tsoutf
	set j 0
	while {$j < $mixcnt} {
		catch {file delete $tsmixf($j)}
		catch {file delete $tsoutf($j)}
		incr j
	}
}

#---- Play several time-series sound outputs as sequences

proc PlaySequenceTs {} {
	global tsplaylist tsochans tsmixf tsoutf pa wstk evv
	global simple_program_messages prg_dun prg_abortd CDPidrun  tsmultiout playcmd_dummy

	if {[llength $tsplaylist] <= 0} {
		Inf "No output sounds to play"
		return 0
	} elseif {[llength $tsplaylist] == 1} {
		Inf "Only one output sound to play"
		return 0
	} elseif {[string length $tsochans] <= 0} {
		Inf "No group size selected (use up/dn arrows)"
		return 0
	} elseif {[llength $tsplaylist] < $tsochans} {
		set tsochans [llength $tsplaylist]
	}
	Block "Mixing Sounds"
	set mixcnt 0
	set sndcnt 1
	set time 0.0
	foreach fnam $tsplaylist {
		set line $fnam
		lappend line $time 1 1.0 C
		if {![info exists pa($fnam,$evv(FTYP))]} {
			if {[DoParse $fnam 0 0 0] <= 0} {
				Inf "Cannot find duration of one of files: canot proceed"
				return 0
			}
		}
		set time [expr $time + $pa($fnam,$evv(DUR)) + 0.5]
		lappend lines $line
		incr sndcnt
		if {$sndcnt > $tsochans} {
			set tsmixf($mixcnt) $evv(MACH_OUTFNAME)
			set tsoutf($mixcnt) $evv(MACH_OUTFNAME)
			append tsmixf($mixcnt) $mixcnt [GetTextfileExtension mix]
			append tsoutf($mixcnt) $mixcnt $evv(SNDFILE_EXT)
			if {[catch {file delete $tsmixf($mixcnt)} zit] || [catch {file delete $tsoutf($mixcnt)} zit]} {
				Inf "Cannot delete pre-existing temporary file(s)"
				PurgeTsMultimixes $mixcnt 
				UnBlock
				return 0
			}
			if [catch {open $tsmixf($mixcnt) "w"} zit] {
				Inf "Cannot open temporary mixfile $tsmixf($mixcnt)"
				PurgeTsMultimixes $mixcnt 
				UnBlock
				return 0
			}
			foreach line $lines {
				puts $zit $line
			}
			close $zit
			catch {unset lines}
			set time 0.0
			set sndcnt 1
			incr mixcnt
		}
	}
	if {$sndcnt > 1} {
		set tsmixf($mixcnt) $evv(MACH_OUTFNAME)
		set tsoutf($mixcnt) $evv(MACH_OUTFNAME)
		append tsmixf($mixcnt) $mixcnt [GetTextfileExtension mix]
		append tsoutf($mixcnt) $mixcnt $evv(SNDFILE_EXT)
		if {[catch {file delete $tsmixf($mixcnt)} zit] || [catch {file delete $tsoutf($mixcnt)} zit]} {
			Inf "Cannot delete pre-existing temporary file(s)"
			PurgeTsMultimixes $mixcnt 
			UnBlock
			return 0
		}
		if [catch {open $tsmixf($mixcnt) "w"} zit] {
			Inf "Cannot open temporary mixfile $tsmixf($mixcnt)"
			PurgeTsMultimixes $mixcnt 
			UnBlock
			return 0
		}
		foreach line $lines {
			puts $zit $line
		}
		close $zit
		incr mixcnt
	}
	set j 0 
	set k 1
	while {$j < $mixcnt} {
		set cmd [file join $evv(CDPROGRAM_DIR) submix]
		lappend cmd mix $tsmixf($j) $tsoutf($j)
		catch {unset simple_program_messages}
		set prg_dun 0
		set prg_abortd 0
		wm title .blocker "PLEASE WAIT:        Mixing group $k"			
		if [catch {open "|$cmd"} CDPidrun] {
			ErrShow "Failed to do multichannel mix $k"
			catch {unset CDPidrun}
			PurgeTsMultimixes $mixcnt 
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
			set msg "Mixing group $k failed"
			set msg [AddSimpleMessages $msg]
			ErrShow $msg
			PurgeTsMultimixes $mixcnt 
			UnBlock
			return
		}
		if {![file exists $tsoutf($j)]} {
			set msg "Mixing group $k produced no output file"
			ErrShow $msg
			PurgeTsMultimixes $mixcnt 
			UnBlock
			return
		}
		lappend playlist $tsoutf($j)
		incr j
		incr k
	}
	UnBlock
	if {![info exists playlist]} {
		return 0
	} elseif {[llength $playlist] == 1} {
		set is_playing 0
		set msg "Hear the output ?"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		while {$choice == "yes"} {
			set is_playing 1
			PlaySndfile [lindex $playlist 0] 0			;# PLAY OUTPUT
			set msg "Hear it again ?"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		} 
	} else {
		set endfile [llength $playlist]
		incr endfile -1
		set is_playing 0
		set msg "Hear the outputs ?"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		set k 0
		while {$choice == "yes"} {
			set is_playing 1
			PlaySndfile [lindex $playlist $k] 0			;# PLAY OUTPUTS
			set msg "Hear the same file again ?"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]	
			if {$choice == "no"} {
				if {$k < $endfile} {
					set msg "Hear the next file ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]	
					if {$choice == "yes"} {
						incr k
					}
				} else {
					set msg "Hear all the files again ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						set k 0
					}
				}
			}
		} 
	}
	if {$is_playing && ($playcmd_dummy != "pvplay")} {
		Inf "If there is a play-program display\nyou must close it before proceeding!!"
	}
	set tsmultiout [list "seq" 1]
}


#---- Play several time-series sound outputs superimposed

proc PlayMixTs {stereosprd} {
	global tsplaylist tsochans tsmixf tsoutf pa wstk evv
	global simple_program_messages prg_dun prg_abortd CDPidrun 
	global CDPmaxId maxsamp_line done_maxsamp ts_harmvals tsmany tsmultiout playcmd_dummy


	if {[llength $tsplaylist] <= 0} {
		Inf "No output sounds to play"
		return 0
	} elseif {[llength $tsplaylist] == 1} {
		Inf "Only one output sound to play"
		return 0
	}
	set tsochans [llength $tsplaylist]
	Block "Mixing Sounds"
	set pos -.95
	set spinc [expr 1.9/double($tsochans - 1)]
	set level 1.0
	set n 1
	foreach fnam $tsplaylist {
		if {[info exists tsmany]} {
			set level [lindex $ts_harmvals $n]
		}
		set line $fnam
		if {$stereosprd} {
			lappend line 0.0 1 $level $pos
			set pos [expr $pos + $spinc]
		} else {
			lappend line 0.0 1 $level C
		}
		lappend lines $line
		incr n 2
	}
	set tsmixf(0) $evv(MACH_OUTFNAME)
	set tsoutf(0) $evv(MACH_OUTFNAME)
	append tsmixf(0) 0 [GetTextfileExtension mix]
	append tsoutf(0) 0 $evv(SNDFILE_EXT)
	if {[file exists $tsmixf(0)]} {
		if [catch {file delete $tsmixf(0)} zit] {
			Inf "Cannot delete existing temporary mixfile"
			UnBlock
			return 0
		}
	}
	if {[file exists $tsoutf(0)]} {
		if [catch {file delete $tsoutf(0)} zit] {
			Inf "Cannot delete existing temporary file"
			UnBlock
			return 0
		}
	}
	if [catch {open $tsmixf(0) "w"} zit] {
		Inf "Cannot open temporary mixfile $tsmixf(0)"
		UnBlock
		return 0
	}
	foreach line $lines {
		puts $zit $line
	}
	close $zit
	set mixcnt 1
	set cmd [file join $evv(CDPROGRAM_DIR) submix]
	lappend cmd mix $tsmixf(0) $tsoutf(0)
	catch {unset simple_program_messages}
	set prg_dun 0
	set prg_abortd 0
	wm title .blocker "PLEASE WAIT:        Mixing"			
	if [catch {open "|$cmd"} CDPidrun] {
		ErrShow "Failed to do mix"
		catch {unset CDPidrun}
		PurgeTsMultimixes 1
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
		set msg "Mixing failed"
		set msg [AddSimpleMessages $msg]
		ErrShow $msg
		PurgeTsMultimixes $mixcnt 
		UnBlock
		return
	}
	if {![file exists $tsoutf(0)]} {
		set msg "Mixing produced no output file"
		ErrShow $msg
		PurgeTsMultimixes $mixcnt 
		UnBlock
		return
	}
	set done 0
	while {!$done} {
		set cmd2 [file join $evv(CDPROGRAM_DIR) maxsamp2]
		catch {unset maxsamp_line}
		set done_maxsamp 0
		lappend cmd2 $tsoutf(0)
		if [catch {open "|$cmd2"} CDPmaxId] {
			Inf "Failed to find maximum level of output: outfile could be distorted"
			set done 1
			break
		}
		fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
		vwait done_maxsamp
		if {![info exists maxsamp_line]} {
			Inf "Cannot retrieve maximum level information: outfile could be distorted"
			set done 1
			break
		}
		set maxoutsamp [lindex $maxsamp_line 0]
		if {$maxoutsamp <= 0.95} {
			set done 1
			break
		}
		set nulevel [expr 0.95/$maxoutsamp]
		if [catch {file delete $tsoutf(0)} zit] {
			Inf "Cannot delete the distorted output file, to remix"
			break
		}
		PurgeTsMultimixes $mixcnt 
		unset lines
		set pos -.95
		set spinc [expr 1.9/double($tsochans - 1)]
		set level $nulevel
		set n 1
		foreach fnam $tsplaylist {
			set line $fnam
			if {[info exists tsmany]} {
				set hlevel [lindex $ts_harmvals $n]
				set level [expr $hlevel * $nulevel]
			}
			if {$stereosprd} {
				lappend line 0.0 1 $level $pos
				set pos [expr $pos + $spinc]
			} else {
				lappend line 0.0 1 $level C
			}
			lappend lines $line
			incr n 2
		}
		if [catch {open $tsmixf(0) "w"} zit] {
			Inf "Cannot open temporary mixfile to remix sound"
			break
		}
		foreach line $lines {
			puts $zit $line
		}
		close $zit
		catch {unset simple_program_messages}
		set prg_dun 0
		set prg_abortd 0
		wm title .blocker "PLEASE WAIT:        Remixing"			
		if [catch {open "|$cmd"} CDPidrun] {
			ErrShow "Failed to do remix the file"
			catch {unset CDPidrun}
			PurgeTsMultimixes 1
			break
		} else {
			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			set msg "Re-mixing for better level failed"
			set msg [AddSimpleMessages $msg]
			ErrShow $msg
			PurgeTsMultimixes $mixcnt 
			break
		}
		if {![file exists $tsoutf(0)]} {
			set msg "Re-mixing produced no output file"
			ErrShow $msg
			PurgeTsMultimixes $mixcnt 
			break
		}
		set done 1
	}
	UnBlock
	if {!$done} {
		return
	}
	set is_playing 0
	set msg "Hear the output ?"
	set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
	while {$choice == "yes"} {
		set is_playing 1
		PlaySndfile $tsoutf(0) 0			;# PLAY OUTPUT
		set msg "Hear it again ?"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
	} 
	if {$is_playing && ($playcmd_dummy != "pvplay")} {
		Inf "If there is a play-program display\nyou must close it before proceeding!!"
	}
	set tsmultiout [list "mix" $stereosprd]
}

#---- Play groups of mono files, from workspace

proc PlayN {multi} {
	global chlist pa evv pr_playn playnsize playnlen playnmulti readonlyfg readonlybg tsplaylist tsochans tssrcsndchans
	if {![info exists chlist] || ([llength $chlist] <= 0)} {
		Inf "No files on chosen list"
		return
	}
	set chans 1
	foreach fnam $chlist {
		if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
			Inf "File $fnam is not a soundfile"
			return
		}
		if {$multi} {
			if {![info exists inchans]} {
				if {$pa($fnam,$evv(CHANS)) < 2} {
					Inf "File $fnam is not a multichannel soundfile"
					return
				}
				set inchans $pa($fnam,$evv(CHANS))
			} else {
				if {$pa($fnam,$evv(CHANS)) != $inchans} {
					Inf "File $fnam not same channel-count ($pa($fnam,$evv(chans))) as previous files ($inchans)"
					return
				}
			}
		} else {
			if {$pa($fnam,$evv(CHANS)) != 1} {
				Inf "File $fnam is not a mono soundfile"
				return
			}
		}
	}
	if {$multi} {
		set tssrcsndchans $inchans
	}
	set playnlen [llength $chlist]
	set playnmulti $multi
	set f .playn
	if [Dlg_Create $f "Play files in groups" "set pr_playn 0" -borderwidth 2 -width 84] {
		frame $f.0
		button $f.0.qu -text "Quit" -command "set pr_playn 0" -highlightbackground [option get . background {}]
		button $f.0.pp -text "Play Files" -command "set pr_playn 1" -highlightbackground [option get . background {}]
		pack $f.0.pp -side left
		pack $f.0.qu -side right
		pack  $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.siz -text "Size of  groups (Up/Dn Arrows)"
		entry $f.1.gpp -textvariable playnsize -width 4 -fg $readonlyfg -readonlybackground $readonlybg -state readonly
		set playnsize ""
		pack $f.1.siz $f.1.gpp -side left -padx 2
		pack $f.1 -side top
		wm resizable $f 1 1
		bind $f <Return> {set pr_playn 1}
		bind $f <Escape> {set pr_playn 0}
		bind $f <Up>   {IncrPlayN 0}
		bind $f <Down> {IncrPlayN 1}
	}
	if {[string length $playnsize] <= 0} {
		if {$playnlen < 8} {
			set playnsize $playnlen
		} else {
			set playnsize 8
		}
	}
	set pr_playn 0
	update idletasks
	raise $f
	update idletasks
	My_Grab 0 $f pr_playn $f
	update idletasks
	set finished 0
	while {!$finished} {
		tkwait variable pr_playn
		if {$pr_playn} {
			set tsplaylist $chlist
			set tsochans $playnsize
			if {$playnmulti} {
				PlayMultichanTs
			} else {
				PlaySequenceTs
			}
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc IncrPlayN {down} {
	global chlist playnsize playnlen playnmulti
	set len $playnlen
	if {$playnmulti && ($len > 8)} {
		set len 8
	}
	if {$down} {
		if {$playnsize > 2} {
			incr playnsize -1
		}
	} else {
		if {$playnsize < $len} {
			incr playnsize
		}
	}
}

###################################################
# ACCESSING CDP PROGS FROM TIME-SERIES CONVERSION #
###################################################


proc SetupTsFunc {srctype} {
	global tsfunc ts_srctype tsdatatype ts_emph tsfpar1 tsfpar2 tsfpar3 tsfpar4 tsrmin tsrmax 
	global tsmaxdurfunc tsbrkstep tssrcsnd tssubfunc readonlybg evv
	set tsfpar1 ""
	set tsfpar2 ""
	set tsfpar3 ""
	set tsfpar4 ""
	set tsrmin ""
	set tsrmax ""
	set tsmaxdurfunc ""
	set tssubfunc(1) 0
	set tssubfunc(2) 0
	.ts.b.0.a.21loud config -state disabled -text ""
	.ts.b.0.a.21spac config -state disabled -text ""
	if {$srctype >= 0} {
		set ts_srctype $srctype		;#	Call to a function, of specific ttype
		set tsdatatype 0			;#	Switch off oscil and trace
		TimeSeriesParamSet init	
		.ts.b.01.ldur config -text "Durations"
		.ts.b.01.dur config -state normal -bd 2
		.ts.b.01.rr config -state normal -text "equal"
		.ts.b.5.a.src config -text "Get Target Sound(s)" -command "set pr_ts 17" -bd 2
		.ts.b.5.a.eee config -bd 2 -readonlybackground $readonlybg
		.ts.b.5.run config -text "Run Process" -command "set pr_ts 18" -bd 2 -bg $evv(EMPH)
		.ts.a.2.go config -bg [option get . background {}]
		set ts_emph .ts.b.5.run
		bind .ts.b.01.dur <Up>	 {focus .ts.b.2.rmax}
		bind .ts.b.01.dur <Down> {focus .ts.b.1.rmin}
		bind .ts.b.1.rmin <Up>	 {focus .ts.b.01.dur}
		bind .ts.b.1.rmin <Down> {focus .ts.b.2.rmax}
		bind .ts.b.2.rmax <Up>	 {focus .ts.b.1.rmin}
		bind .ts.b.2.rmax <Down> {focus .ts.b.01.dur}
		focus .ts.b.01.dur
	} else {						;#	Functions switched off	
		set tsfunc -1
		.ts.b.01.ldur config -text ""
		.ts.b.01.dur config -state disabled -disabledbackground [option get . background {}] -bd 0
		.ts.b.01.rr config -state disabled -text ""
		set tssrcsnd ""
		.ts.b.5.a.src config -text "" -bd 0 -command {}
		.ts.b.5.a.eee config -bd 0 -readonlybackground [option get . background {}]
		.ts.b.5.run config -text "" -bd 0 -command {} -bg [option get . background {}]
		.ts.a.2.go config -bg $evv(EMPH)
		set ts_emph .ts.a.2.go
		bind .ts.b.01.dur <Up>	 {}
		bind .ts.b.01.dur <Down> {}
		bind .ts.b.1.rmin <Up>	 {}
		bind .ts.b.1.rmin <Down> {}
		bind .ts.b.2.rmax <Up>	 {}
		bind .ts.b.2.rmax <Down> {}
	}
	.ts.b.4a.cr config -state disabled -text ""
	.ts.b.4.stp config -state normal -bd 2
	.ts.b.4.stl config -text "step"
	switch -- $tsfunc {
		"-1" -
		7  -
		12 -
		13 -
		14 -
		19 -
		20 - 
		21 {
			.ts.b.0a.rng config -text ""
			.ts.b.1.rmin config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.1.min  config -text ""
			.ts.b.2.rmax config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.2.max  config -text ""
			.ts.b.3.log config -state disabled -text ""
			switch -- $tsfunc {
				7  { .ts.b.0a.rng config -text "Omit Ratio" }
				12 {
					.ts.b.0a.rng config -text "Read reverse times" 
					.ts.b.4.stp config -state disabled -disabledbackground [option get . background {}] -bd 0
					.ts.b.4.stl config -text ""
					set tsbrkstep ""
				}
				13 { 
					.ts.b.0a.rng config -text "Read locus"
					.ts.b.4a.cr config -state normal -text "randclok"
				}
 				14 { 
					.ts.b.0a.rng config -text "Read ambitus" 
					.ts.b.4a.cr config -state normal -text "randclok"
				}
				19 { .ts.b.0a.rng config -text "Stretch depth" }
				20 { .ts.b.0a.rng config -text "Balance" }
				21 { 
					.ts.b.0a.rng config -text "Snd to select"
					.ts.b.4a.cr config -state normal -text "no repet"
					.ts.b.0.a.21loud config -state normal -text "Atten"
					.ts.b.0.a.21spac config -state normal -text "Space"
				}
			}
		}
		default {
			switch -- $tsfunc {
				0  { 
					.ts.b.0a.rng config -text "Data range" 
				}
				1 -
				2 {
					.ts.b.0a.rng config -text "Density"
				}
				3 {
					.ts.b.0a.rng config -text "Midi pitch"
				}
				4 -
				5 -
				6 {
					.ts.b.0a.rng config -text "Waveset cnt"
				}
				8  -
				10 {
					.ts.b.0a.rng config -text "Freq"
				}
				9  -
				11 {
					.ts.b.0a.rng config -text "Depth"
				}
				15 {
					.ts.b.0a.rng config -text "Clokrate"
				}
				16 -
				17 {
					.ts.b.0a.rng config -text "Filter Q"
				}
				18 {
					.ts.b.0a.rng config -text "Frq shift"
				}
			}
			.ts.b.1.rmin config -state normal -bd 2
			.ts.b.1.min  config -text "min"
			.ts.b.2.rmax config -state normal -bd 2
			.ts.b.2.max  config -text "max"
			.ts.b.3.log config -state normal -text "log"
		}
	}
	bind .ts.b.1.p1   <Up>    {}
	bind .ts.b.1.p1   <Down>  {}
	bind .ts.b.1.p1   <Left>  {}
	bind .ts.b.1.p1   <Right> {}
	bind .ts.b.2.p2   <Up>    {}
	bind .ts.b.2.p2   <Down>  {}
	bind .ts.b.2.p2   <Left>  {}
	bind .ts.b.2.p2   <Right> {}
	bind .ts.b.3.p3   <Up>    {}
	bind .ts.b.3.p3   <Down>  {}
	bind .ts.b.3.p3   <Left>  {}
	bind .ts.b.3.p3   <Right> {}
	bind .ts.b.4.p4   <Up>    {}
	bind .ts.b.4.p4   <Down>  {}
	bind .ts.b.4.p4   <Left>  {}
	bind .ts.b.4.p4   <Right> {}

	bind .ts.b.4.stp  <Up>    {}
	bind .ts.b.4.stp  <Down>  {}
	bind .ts.b.4.stp  <Left>  {}
	bind .ts.b.4.stp  <Right> {}
	bind .ts.b.1.rmin <Up>    {}
	bind .ts.b.1.rmin <Down>  {}
	bind .ts.b.1.rmin <Left>  {}
	bind .ts.b.1.rmin <Right> {}
	bind .ts.b.2.rmax <Up>    {}
	bind .ts.b.2.rmax <Down>  {}
	bind .ts.b.2.rmax <Left>  {}
	bind .ts.b.2.rmax <Right> {}
	bind .ts.b.01.dur <Up>    {}
	bind .ts.b.01.dur <Down>  {}
	bind .ts.b.01.dur <Left>  {}
	bind .ts.b.01.dur <Right> {}

	switch -- $tsfunc {
		"-1" {
			.ts.b.0x.other config -text ""
			.ts.b.1.ll1 config -text ""
			.ts.b.2.ll2 config -text ""
			.ts.b.3.ll3 config -text ""
			.ts.b.4.ll4 config -text ""
			.ts.b.1.p1 config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.2.p2 config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.3.p3 config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.4.p4 config -state disabled -disabledbackground [option get . background {}] -bd 0
		}
		0  {
			.ts.b.0x.other config -text ""
			.ts.b.1.ll1 config -text ""
			.ts.b.2.ll2 config -text ""
			.ts.b.3.ll3 config -text ""
			.ts.b.4.ll4 config -text ""
			.ts.b.1.p1 config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.2.p2 config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.3.p3 config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.4.p4 config -state disabled -disabledbackground [option get . background {}] -bd 0
			bind .ts.b.01.dur <Up>   {focus .ts.b.4.stp}
			bind .ts.b.01.dur <Down> {focus .ts.b.1.rmin}
			bind .ts.b.1.rmin <Up>   {focus .ts.b.01.dur}
			bind .ts.b.1.rmin <Down> {focus .ts.b.2.rmax}
			bind .ts.b.2.rmax <Up>   {focus .ts.b.1.rmin}
			bind .ts.b.2.rmax <Down> {focus .ts.b.4.stp}
			bind .ts.b.4.stp  <Up>   {focus .ts.b.2.rmax}
			bind .ts.b.4.stp  <Down> {focus .ts.b.01.dur}
		}
		7  {
			.ts.b.0x.other config -text ""
			.ts.b.1.ll1 config -text ""
			.ts.b.2.ll2 config -text ""
			.ts.b.3.ll3 config -text ""
			.ts.b.4.ll4 config -text ""
			.ts.b.1.p1 config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.2.p2 config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.3.p3 config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.4.p4 config -state disabled -disabledbackground [option get . background {}] -bd 0
			bind .ts.b.4.stp  <Up>   {focus .ts.b.01.dur}
			bind .ts.b.4.stp  <Down> {focus .ts.b.01.dur}
			bind .ts.b.01.dur <Down> {focus .ts.b.4.stp}
			bind .ts.b.01.dur <Up>   {focus .ts.b.4.stp}
		}
		18 {
			.ts.b.0x.other config -text ""
			.ts.b.1.ll1 config -text ""
			.ts.b.2.ll2 config -text ""
			.ts.b.3.ll3 config -text ""
			.ts.b.4.ll4 config -text ""
			.ts.b.1.p1 config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.2.p2 config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.3.p3 config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.4.p4 config -state disabled -disabledbackground [option get . background {}] -bd 0
			bind .ts.b.01.dur <Up> {focus .ts.b.4.stp}
			bind .ts.b.01.dur <Down> {focus .ts.b.1.rmin}
			bind .ts.b.1.rmin <Up>	 {focus .ts.b.01.dur}
			bind .ts.b.1.rmin <Down> {focus .ts.b.2.rmax}
			bind .ts.b.2.rmax <Up>	 {focus .ts.b.1.rmin}
			bind .ts.b.2.rmax <Down> {focus .ts.b.4.stp}
			bind .ts.b.4.stp <Up>    {focus .ts.b.2.rmax}
			bind .ts.b.4.stp <Down>  {focus .ts.b.01.dur}
		}
		20 {
			.ts.b.0x.other config -text ""
			.ts.b.1.ll1 config -text ""
			.ts.b.2.ll2 config -text ""
			.ts.b.3.ll3 config -text ""
			.ts.b.4.ll4 config -text ""
			.ts.b.1.p1 config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.2.p2 config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.3.p3 config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.4.p4 config -state disabled -disabledbackground [option get . background {}] -bd 0
			bind .ts.b.01.dur <Up>   {focus .ts.b.4.stp}
			bind .ts.b.01.dur <Down> {focus .ts.b.4.stp}
			bind .ts.b.4.stp <Up>    {focus .ts.b.01.dur}
			bind .ts.b.4.stp <Down>  {focus .ts.b.01.dur}
		}
		1  - 
		2  {
			.ts.b.0x.other config -text "Other params"
			.ts.b.1.ll1 config -text "level"
			.ts.b.2.ll2 config -text ""
			.ts.b.3.ll3 config -text ""
			.ts.b.4.ll4 config -text ""
			.ts.b.1.p1 config -state normal -bd 2
			.ts.b.2.p2 config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.3.p3 config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.4.p4 config -state disabled -disabledbackground [option get . background {}] -bd 0
			bind .ts.b.01.dur <Up>   {focus .ts.b.4.stp}
			bind .ts.b.01.dur <Down>  {focus .ts.b.1.rmin}
			bind .ts.b.1.rmin <Up>    {focus .ts.b.01.dur}
			bind .ts.b.1.rmin <Down>  {focus .ts.b.2.rmax}
			bind .ts.b.2.rmax <Up>    {focus .ts.b.1.rmin}
			bind .ts.b.2.rmax <Down>  {focus .ts.b.4.stp}
			bind .ts.b.4.stp  <Up>    {focus .ts.b.2.rmax}
			bind .ts.b.4.stp  <Down>  {focus .ts.b.01.dur}
			bind .ts.b.1.rmin <Right> {focus .ts.b.1.p1}
			bind .ts.b.2.rmax <Right> {focus .ts.b.1.p1}
			bind .ts.b.4.stp  <Right> {focus .ts.b.1.p1}
			bind .ts.b.1.p1   <Left>  {focus .ts.b.1.rmin}
			bind .ts.b.1.p1   <Up>    {focus .ts.b.01.dur}
			bind .ts.b.1.p1   <Down>  {focus .ts.b.4.stp}
		}
		3 {
			.ts.b.0x.other config -text "Other params"
			.ts.b.1.ll1 config -text "level"
			.ts.b.2.ll2 config -text "packing"
			.ts.b.3.ll3 config -text ""
			.ts.b.4.ll4 config -text ""
			.ts.b.1.p1 config -state normal -bd 2
			.ts.b.2.p2 config -state normal -bd 2
			.ts.b.3.p3 config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.4.p4 config -state disabled -disabledbackground [option get . background {}] -bd 0
			bind .ts.b.01.dur <Up>    {focus .ts.b.4.stp}
			bind .ts.b.01.dur <Down>  {focus .ts.b.1.rmin}
			bind .ts.b.1.rmin <Up>    {focus .ts.b.01.dur}
			bind .ts.b.1.rmin <Down>  {focus .ts.b.2.rmax}
			bind .ts.b.2.rmax <Up>    {focus .ts.b.1.rmin}
			bind .ts.b.2.rmax <Down>  {focus .ts.b.4.stp}
			bind .ts.b.4.stp  <Up>    {focus .ts.b.2.rmax}
			bind .ts.b.4.stp  <Down>  {focus .ts.b.01.dur}
			bind .ts.b.1.rmin <Right> {focus .ts.b.1.p1}
			bind .ts.b.2.rmax <Right> {focus .ts.b.2.p2}
			bind .ts.b.2.p2   <Left>  {focus .ts.b.2.rmax}
			bind .ts.b.4.stp  <Right> {focus .ts.b.1.p1}
			bind .ts.b.1.p1   <Left>  {focus .ts.b.1.rmin}
			bind .ts.b.1.p1   <Down>  {focus .ts.b.2.p2}
			bind .ts.b.2.p2   <Up>    {focus .ts.b.1.p1}
			bind .ts.b.1.p1   <Up>    {focus .ts.b.01.dur}
			bind .ts.b.2.p2   <Down>  {focus .ts.b.4.stp}
		}
		4 -
		5 -
		6 {
			.ts.b.0x.other config -text "Other params"
			.ts.b.1.ll1 config -text "exponent"
			.ts.b.2.ll2 config -text ""
			.ts.b.3.ll3 config -text ""
			.ts.b.4.ll4 config -text ""
			.ts.b.1.p1 config -state normal -bd 2
			.ts.b.2.p2 config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.3.p3 config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.4.p4 config -state disabled -disabledbackground [option get . background {}] -bd 0
			bind .ts.b.01.dur <Up>   {focus .ts.b.4.stp}
			bind .ts.b.01.dur <Down>  {focus .ts.b.1.rmin}
			bind .ts.b.1.rmin <Up>    {focus .ts.b.01.dur}
			bind .ts.b.1.rmin <Down>  {focus .ts.b.2.rmax}
			bind .ts.b.2.rmax <Up>    {focus .ts.b.1.rmin}
			bind .ts.b.2.rmax <Down>  {focus .ts.b.4.stp}
			bind .ts.b.4.stp  <Up>    {focus .ts.b.2.rmax}
			bind .ts.b.4.stp  <Down>  {focus .ts.b.01.dur}
			bind .ts.b.1.rmin <Right> {focus .ts.b.1.p1}
			bind .ts.b.2.rmax <Right> {focus .ts.b.1.p1}
			bind .ts.b.4.stp  <Right> {focus .ts.b.1.p1}
			bind .ts.b.1.p1   <Left>  {focus .ts.b.1.rmin}
			bind .ts.b.1.p1   <Up>    {focus .ts.b.01.dur}
			bind .ts.b.1.p1   <Down>  {focus .ts.b.4.stp}
		}
		8 -
		10 {
			.ts.b.0x.other config -text "Other params"
			.ts.b.1.ll1 config -text "depth"
			.ts.b.2.ll2 config -text ""
			.ts.b.3.ll3 config -text ""
			.ts.b.4.ll4 config -text ""
			.ts.b.1.p1 config -state normal -bd 2
			.ts.b.2.p2 config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.3.p3 config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.4.p4 config -state disabled -disabledbackground [option get . background {}] -bd 0
			bind .ts.b.01.dur <Up>   {focus .ts.b.4.stp}
			bind .ts.b.01.dur <Down>  {focus .ts.b.1.rmin}
			bind .ts.b.1.rmin <Up>    {focus .ts.b.01.dur}
			bind .ts.b.1.rmin <Down>  {focus .ts.b.2.rmax}
			bind .ts.b.2.rmax <Up>    {focus .ts.b.1.rmin}
			bind .ts.b.2.rmax <Down>  {focus .ts.b.4.stp}
			bind .ts.b.4.stp  <Up>    {focus .ts.b.2.rmax}
			bind .ts.b.4.stp  <Down>  {focus .ts.b.01.dur}
			bind .ts.b.1.rmin <Right> {focus .ts.b.1.p1}
			bind .ts.b.2.rmax <Right> {focus .ts.b.1.p1}
			bind .ts.b.4.stp  <Right> {focus .ts.b.1.p1}
			bind .ts.b.1.p1   <Left>  {focus .ts.b.1.rmin}
			bind .ts.b.1.p1   <Up>    {focus .ts.b.01.dur}
			bind .ts.b.1.p1   <Down>  {focus .ts.b.4.stp}
		}
		9 -
		11 {
			.ts.b.0x.other config -text "Other params"
			.ts.b.1.ll1 config -text "frequency"
			.ts.b.2.ll2 config -text ""
			.ts.b.3.ll3 config -text ""
			.ts.b.4.ll4 config -text ""
			.ts.b.1.p1 config -state normal -bd 2
			.ts.b.2.p2 config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.3.p3 config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.4.p4 config -state disabled -disabledbackground [option get . background {}] -bd 0
			bind .ts.b.01.dur <Up>   {focus .ts.b.4.stp}
			bind .ts.b.01.dur <Down>  {focus .ts.b.1.rmin}
			bind .ts.b.1.rmin <Up>    {focus .ts.b.01.dur}
			bind .ts.b.1.rmin <Down>  {focus .ts.b.2.rmax}
			bind .ts.b.2.rmax <Up>    {focus .ts.b.1.rmin}
			bind .ts.b.2.rmax <Down>  {focus .ts.b.4.stp}
			bind .ts.b.4.stp  <Up>    {focus .ts.b.2.rmax}
			bind .ts.b.4.stp  <Down>  {focus .ts.b.01.dur}
			bind .ts.b.1.rmin <Right> {focus .ts.b.1.p1}
			bind .ts.b.2.rmax <Right> {focus .ts.b.1.p1}
			bind .ts.b.4.stp  <Right> {focus .ts.b.1.p1}
			bind .ts.b.1.p1   <Left>  {focus .ts.b.1.rmin}
			bind .ts.b.1.p1   <Up>    {focus .ts.b.01.dur}
			bind .ts.b.1.p1   <Down>  {focus .ts.b.4.stp}
		}
		12 {
			.ts.b.0x.other config -text "Other params"
			.ts.b.1.ll1 config -text "splicelen"
			set tsfpar1 15
			.ts.b.2.ll2 config -text ""
			.ts.b.3.ll3 config -text ""
			.ts.b.4.ll4 config -text ""
			.ts.b.1.p1 config -state normal -bd 2
			.ts.b.2.p2 config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.3.p3 config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.4.p4 config -state disabled -disabledbackground [option get . background {}] -bd 0
			bind .ts.b.1.p1	  <Up>   {focus .ts.b.01.dur}
			bind .ts.b.1.p1	  <Down> {focus .ts.b.01.dur}
			bind .ts.b.01.dur <Up>   {focus .ts.b.1.p1}
			bind .ts.b.01.dur <Down> {focus .ts.b.1.p1}
		}
		13 {
			.ts.b.0x.other config -text "Other params"
			.ts.b.1.ll1 config -text ""
			.ts.b.2.ll2 config -text "ambitus"
			.ts.b.3.ll3 config -text "step"
			.ts.b.4.ll4 config -text "clockrate"
			.ts.b.1.p1 config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.2.p2 config -state normal -bd 2
			.ts.b.3.p3 config -state normal -bd 2
			.ts.b.4.p4 config -state normal -bd 2
			bind .ts.b.01.dur <Up>    {focus .ts.b.4.stp}
			bind .ts.b.01.dur <Down>  {focus .ts.b.2.p2}
			bind .ts.b.2.p2   <Up>    {focus .ts.b.01.dur}
			bind .ts.b.2.p2   <Down>  {focus .ts.b.3.p3}
			bind .ts.b.3.p3   <Up>    {focus .ts.b.2.p2}
			bind .ts.b.3.p3   <Down>  {focus .ts.b.4.p4}
			bind .ts.b.2.p2   <Left>  {focus .ts.b.4.stp}
			bind .ts.b.3.p3   <Left>  {focus .ts.b.4.stp}
			bind .ts.b.4.p4   <Left>  {focus .ts.b.3.stp}
			bind .ts.b.4.p4   <Up>    {focus .ts.b.3.p3}
			bind .ts.b.4.p4   <Down>  {focus .ts.b.01.dur}
			bind .ts.b.4.stp  <Up>    {focus .ts.b.01.dur}
			bind .ts.b.4.stp  <Down>  {focus .ts.b.01.dur}
			bind .ts.b.01.dur <Down>  {focus .ts.b.4.stp}
			bind .ts.b.4.stp  <Right> {focus .ts.b.4.p4}
			bind .ts.b.4.p4   <Left>  {focus .ts.b.4.stp}
		}
		14 {
			.ts.b.0x.other config -text "Other params"
			.ts.b.1.ll1 config -text "locus"
			.ts.b.2.ll2 config -text ""
			.ts.b.3.ll3 config -text "step"
			.ts.b.4.ll4 config -text "clockrate"
			.ts.b.1.p1 config -state normal -bd 2
			.ts.b.2.p2 config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.3.p3 config -state normal -bd 2
			.ts.b.4.p4 config -state normal -bd 2
			bind .ts.b.01.dur <Up>    {focus .ts.b.4.stp}
			bind .ts.b.01.dur <Down>  {focus .ts.b.1.p1}
			bind .ts.b.1.p1   <Up>    {focus .ts.b.01.dur}
			bind .ts.b.1.p1   <Down>  {focus .ts.b.3.p3}
			bind .ts.b.1.p1   <Left>  {focus .ts.b.4.stp}
			bind .ts.b.3.p3   <Left>  {focus .ts.b.4.stp}
			bind .ts.b.3.p3   <Up>    {focus .ts.b.1.p1}
			bind .ts.b.3.p3   <Down>  {focus .ts.b.4.p4}
			bind .ts.b.4.p4   <Up>    {focus .ts.b.3.p3}
			bind .ts.b.4.p4   <Down>  {focus .ts.b.01.dur}
			bind .ts.b.4.stp  <Up>    {focus .ts.b.01.dur}
			bind .ts.b.4.stp  <Down>  {focus .ts.b.01.dur}
			bind .ts.b.01.dur <Down>  {focus .ts.b.4.stp}
			bind .ts.b.4.stp  <Right> {focus .ts.b.4.p4}
			bind .ts.b.4.p4   <Left>  {focus .ts.b.4.stp}
		}
		15 {
			.ts.b.0x.other config -text "Other params"
			.ts.b.1.ll1 config -text "locus"
			.ts.b.2.ll2 config -text "ambitus"
			.ts.b.3.ll3 config -text "step"
			.ts.b.4.ll4 config -text ""
			.ts.b.1.p1 config -state normal -bd 2
			.ts.b.2.p2 config -state normal -bd 2
			.ts.b.3.p3 config -state normal -bd 2
			.ts.b.4.p4 config -state disabled -disabledbackground [option get . background {}] -bd 0
			bind .ts.b.01.dur <Up>    {focus .ts.b.4.stp}
			bind .ts.b.01.dur <Down>  {focus .ts.b.1.rmin}
			bind .ts.b.1.p1   <Up>    {focus .ts.b.01.dur}
			bind .ts.b.1.p1   <Down>  {focus .ts.b.2.p2}
			bind .ts.b.2.p2   <Up>    {focus .ts.b.1.p1}
			bind .ts.b.2.p2   <Down>  {focus .ts.b.3.p3}
			bind .ts.b.3.p3   <Up>    {focus .ts.b.2.p2}
			bind .ts.b.3.p3   <Down>  {focus .ts.b.4.stp}
			bind .ts.b.1.p1   <Left>  {focus .ts.b.4.stp}
			bind .ts.b.2.p2   <Left>  {focus .ts.b.4.stp}
			bind .ts.b.3.p3   <Left>  {focus .ts.b.4.stp}
			bind .ts.b.4.stp  <Up>    {focus .ts.b.2.rmax}
			bind .ts.b.4.stp  <Down>  {focus .ts.b.01.dur}
			bind .ts.b.4.stp  <Right> {focus .ts.b.3.p3}
			bind .ts.b.2.rmax <Up>    {focus .ts.b.1.rmin}
			bind .ts.b.2.rmax <Down>  {focus .ts.b.4.stp}
			bind .ts.b.1.rmin <Up>    {focus .ts.b.01.dur}
			bind .ts.b.1.rmin <Down>  {focus .ts.b.2.rmax}
			bind .ts.b.2.rmax <Right> {focus .ts.b.2.p2}
			bind .ts.b.1.rmin <Right> {focus .ts.b.1.p1}
			bind .ts.b.2.p2   <Left>  {focus .ts.b.2.rmax}
			bind .ts.b.1.p1   <Left>  {focus .ts.b.1.rmin}
		}
		16 {
			.ts.b.0x.other config -text "Other params"
			.ts.b.1.ll1 config -text "low frq"
			.ts.b.2.ll2 config -text "high frq"
			.ts.b.3.ll3 config -text "gain"
			.ts.b.4.ll4 config -text ""
			.ts.b.1.p1 config -state normal -bd 2
			.ts.b.2.p2 config -state normal -bd 2
			.ts.b.3.p3 config -state normal -bd 2
			.ts.b.4.p4 config -state disabled -disabledbackground [option get . background {}] -bd 0
			bind .ts.b.01.dur <Up>    {focus .ts.b.4.stp}
			bind .ts.b.01.dur <Down>  {focus .ts.b.1.rmin}
			bind .ts.b.1.p1   <Up>    {focus .ts.b.01.dur}
			bind .ts.b.1.p1   <Down>  {focus .ts.b.2.p2}
			bind .ts.b.2.p2   <Up>    {focus .ts.b.1.p1}
			bind .ts.b.2.p2   <Down>  {focus .ts.b.3.p3}
			bind .ts.b.3.p3   <Up>    {focus .ts.b.2.p2}
			bind .ts.b.3.p3   <Down>  {focus .ts.b.4.stp}
			bind .ts.b.1.p1   <Left>  {focus .ts.b.4.stp}
			bind .ts.b.2.p2   <Left>  {focus .ts.b.4.stp}
			bind .ts.b.3.p3   <Left>  {focus .ts.b.4.stp}
			bind .ts.b.4.stp  <Up>    {focus .ts.b.2.rmax}
			bind .ts.b.4.stp  <Down>  {focus .ts.b.01.dur}
			bind .ts.b.4.stp  <Right> {focus .ts.b.3.p3}
			bind .ts.b.2.rmax <Up>    {focus .ts.b.1.rmin}
			bind .ts.b.2.rmax <Down>  {focus .ts.b.4.stp}
			bind .ts.b.1.rmin <Up>    {focus .ts.b.01.dur}
			bind .ts.b.1.rmin <Down>  {focus .ts.b.2.rmax}
			bind .ts.b.2.rmax <Right> {focus .ts.b.2.p2}
			bind .ts.b.1.rmin <Right> {focus .ts.b.1.p1}
			bind .ts.b.2.p2   <Left>  {focus .ts.b.2.rmax}
			bind .ts.b.1.p1   <Left>  {focus .ts.b.1.rmin}
		}
		17 {
			.ts.b.0x.other config -text "Other params"
			.ts.b.1.ll1 config -text "low frq"
			.ts.b.2.ll2 config -text "high frq"
			.ts.b.3.ll3 config -text "gain"
			.ts.b.4.ll4 config -text ""
			.ts.b.1.p1 config -state normal -bd 2
			.ts.b.2.p2 config -state normal -bd 2
			.ts.b.3.p3 config -state normal -bd 2
			.ts.b.4.p4 config -state disabled -disabledbackground [option get . background {}] -bd 0
			bind .ts.b.01.dur <Up>    {focus .ts.b.4.stp}
			bind .ts.b.01.dur <Down>  {focus .ts.b.1.rmin}
			bind .ts.b.1.p1   <Up>    {focus .ts.b.01.dur}
			bind .ts.b.1.p1   <Down>  {focus .ts.b.2.p2}
			bind .ts.b.2.p2   <Up>    {focus .ts.b.1.p1}
			bind .ts.b.2.p2   <Down>  {focus .ts.b.3.p3}
			bind .ts.b.3.p3   <Up>    {focus .ts.b.2.p2}
			bind .ts.b.3.p3   <Down>  {focus .ts.b.4.stp}
			bind .ts.b.1.p1   <Left>  {focus .ts.b.4.stp}
			bind .ts.b.2.p2   <Left>  {focus .ts.b.4.stp}
			bind .ts.b.3.p3   <Left>  {focus .ts.b.4.stp}
			bind .ts.b.4.stp  <Up>    {focus .ts.b.2.rmax}
			bind .ts.b.4.stp  <Down>  {focus .ts.b.01.dur}
			bind .ts.b.4.stp  <Right> {focus .ts.b.3.p3}
			bind .ts.b.2.rmax <Up>    {focus .ts.b.1.rmin}
			bind .ts.b.2.rmax <Down>  {focus .ts.b.4.stp}
			bind .ts.b.1.rmin <Up>    {focus .ts.b.01.dur}
			bind .ts.b.1.rmin <Down>  {focus .ts.b.2.rmax}
			bind .ts.b.2.rmax <Right> {focus .ts.b.2.p2}
			bind .ts.b.1.rmin <Right> {focus .ts.b.1.p1}
			bind .ts.b.2.p2   <Left>  {focus .ts.b.2.rmax}
			bind .ts.b.1.p1   <Left>  {focus .ts.b.1.rmin}
		}
		19 {
			.ts.b.0x.other config -text "Other params"
			.ts.b.1.ll1 config -text "frq divide"
			.ts.b.2.ll2 config -text "max stretch"
			.ts.b.3.ll3 config -text "exponent"
			.ts.b.4.ll4 config -text ""
			.ts.b.1.p1 config -state normal -bd 2
			.ts.b.2.p2 config -state normal -bd 2
			.ts.b.3.p3 config -state normal -bd 2
			.ts.b.4.p4 config -state disabled -disabledbackground [option get . background {}] -bd 0
			bind .ts.b.01.dur <Down> {focus .ts.b.1.p1}
			bind .ts.b.01.dur <Up>   {focus .ts.b.4.stp}
			bind .ts.b.1.p1   <Up>   {focus .ts.b.01.dur}
			bind .ts.b.1.p1   <Down> {focus .ts.b.2.p2}
			bind .ts.b.1.p1   <Left> {focus .ts.b.4.stp}
			bind .ts.b.2.p2   <Left> {focus .ts.b.4.stp}
			bind .ts.b.2.p2   <Up>   {focus .ts.b.1.p1}
			bind .ts.b.2.p2   <Down> {focus .ts.b.3.p3}
			bind .ts.b.3.p3   <Up>   {focus .ts.b.2.p2}
			bind .ts.b.3.p3   <Down> {focus .ts.b.4.stp}
			bind .ts.b.4.stp  <Up>   {focus .ts.b.01.dur}
			bind .ts.b.01.dur <Down> {focus .ts.b.4.stp}
			bind .ts.b.4.stp  <Down> {focus .ts.b.01.dur}
			bind .ts.b.4.stp <Right> {focus .ts.b.3.p3}
			bind .ts.b.3.p3  <Left>  {focus .ts.b.4.stp}
		}
		21  {
			.ts.b.0x.other config -text "Other params"
			.ts.b.1.ll1 config -text "no of snds"
			.ts.b.2.ll2 config -text ""
			.ts.b.3.ll3 config -text ""
			.ts.b.4.ll4 config -text ""
			.ts.b.1.p1 config -state normal -bd 2
			.ts.b.2.p2 config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.3.p3 config -state disabled -disabledbackground [option get . background {}] -bd 0
			.ts.b.4.p4 config -state disabled -disabledbackground [option get . background {}] -bd 0
			bind .ts.b.1.p1	  <Up>   {focus .ts.b.01.dur}
			bind .ts.b.01.dur <Down> {focus .ts.b.1.p1}
			bind .ts.b.01.dur <Up>   {focus .ts.b.4.stp}
			bind .ts.b.1.p1	  <Down> {focus .ts.b.2.rmax}
			bind .ts.b.4.stp <Up>    {focus .ts.b.01.dur}
			bind .ts.b.01.dur <Down> {focus .ts.b.4.stp}
			bind .ts.b.4.stp <Right> {focus .ts.b.1.p1}
			bind .ts.b.1.p1  <Left>  {focus .ts.b.4.stp}
			bind .ts.b.4.stp <Up>    {focus .ts.b.01.dur}
			bind .ts.b.4.stp <Down>  {focus .ts.b.01.dur}
		}
	}
}	

#--- Find appropriate sound(s) for processing with time-series data

proc GetTsFuncSource {} {
	global ts_srctype wl evv pa wstk pr_tsfsrcs ts_srcfiles tsmaxdurfunc tslist tssrcsnd tssrcsndchans tsfpar1
	global ts_sndslist ts_slistlist tsfunc ts_srclist tsgroup tsgrpperm tsgroupchans tsgroupcnt

	;#	ts_srclist is a scrolled_listbox
	;#	ts_sndslist is list of snds on that scrolled_listbox
	;#	ts_slistlist is a list of sndfile_listings_in_textfiles on that scrolled_listbox

	set zzlist [$tslist curselection]
	if {$ts_srctype < 0} {
		Inf "No process selected"
		foreach i $zzlist {
			if {$i >= 0} {
				$tslist selection set $i
			}
		}
		return 0
	}
	if {$ts_srctype == $evv(TS_SOUNDS)} {
		if {([string length $tsfpar1] <= 0) || ![regexp {^[0-9]+$} $tsfpar1] || ($tsfpar1 < 2)} {
			Inf "Number of sources not specified correctly (>1)"
			return 0
		}
	}
	if {($ts_srctype > 1) && ($ts_srctype != $evv(TS_SOUNDS))} {
		if {![info exists tsmaxdurfunc] || ([string length $tsmaxdurfunc] <= 0)} {
			Inf "No maximum duration set: cannot proceed with this function"
			foreach i $zzlist {
				if {$i >= 0} {
					$tslist selection set $i
				}
			}
			return 0
		}
	}
	set previous_sources_ok 0
	if {[info exists ts_srcfiles($ts_srctype)]} {
		set previous_sources_ok 1
		foreach fnam $ts_srcfiles($ts_srctype) {
			if {![file exists $fnam]} {
				set previous_sources_ok 0
			} elseif {![info exists pa($fnam,($evv(DUR))]} {
				set previous_sources_ok 0
			} elseif {($ts_srctype > 1) && ($ts_srctype != $evv(TS_SOUNDS))} {
				if {$pa($fnam,($evv(DUR)) <= $tsmaxdurfunc} {
					set previous_sources_ok 0
				}
			}
		}
		if {$previous_sources_ok} {
			set msg "Use same source files again ?"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			while {$choice == "yes"} {
				foreach i $zzlist {
					if {$i >= 0} {
						$tslist selection set $i
					}
				}
				return 1
			}
		}
	}
	set ts_sndslist {}
	set ts_slistlist {}
	foreach fnam [$wl get 0 end] {
		switch -regexp -- $ts_srctype \
			^$evv(TS_ANAL)$  {			;#	ANAL FILES
				if {$pa($fnam,$evv(FTYP)) == $evv(ANALFILE)} {
					if {$pa($fnam,$evv(DUR)) > $tsmaxdurfunc} {
						lappend ts_sndslist $fnam
					}
				}
			} \
			^$evv(TS_SHORT)$  {			;#	SHORT SOUND FILES
				if {$pa($fnam,$evv(FTYP)) == $evv(SNDFILE)} {
					if {$pa($fnam,$evv(DUR)) < 1.0} {
						lappend ts_sndslist $fnam
					}
				}
			} \
			^$evv(TS_LONG)$  {			;#	LONG SOUND FILES
				if {$pa($fnam,$evv(FTYP)) == $evv(SNDFILE)} {
					if {($tsfunc >= 4) && ($tsfunc <= 7)} {
						if {$pa($fnam,$evv(CHANS)) > 1} {			;#	Distort processes take MONO files only
							continue
						}
					}
					if {$pa($fnam,$evv(DUR)) > $tsmaxdurfunc} {
						lappend ts_sndslist $fnam
					}
				}
			} \
			default {			;#	ANY SOUND FILES
				if {$pa($fnam,$evv(FTYP)) == $evv(SNDFILE)} {
					lappend ts_sndslist $fnam
				} elseif {[IsASndlist $pa($fnam,$evv(FTYP))]} {
					lappend ts_slistlist $fnam
				}
			}
	}
	if {![info exists ts_sndslist]} {
		switch -regexp -- $ts_srctype \
			^$evv(TS_SHORT)$ {	;#	Short duration
				Inf "No short duration sounds (<= 1 sec) on workspace"
				foreach i $zzlist {
					if {$i >= 0} {
						$tslist selection set $i
					}
				}
				return 0
			} \
			^$evv(TS_SOUND)$ {	;#	Any duration
				Inf "No sounds on workspace"
				foreach i $zzlist {
					if {$i >= 0} {
						$tslist selection set $i
					}
				}
				return 0
			} \
			^$evv(TS_SOUNDS)$ {	;#	Any duration
				;#
			} \
			^$evv(TS_ANAL)$ {	;#	spectrum >= expected output duration
				Inf "No anaysis files of sufficient duration (> $tsmaxdurfunc) on workspace"
				foreach i $zzlist {
					if {$i >= 0} {
						$tslist selection set $i
					}
				}
				return 0
			} \
			default {			;#	>= expected output duration
				Inf "No sounds of sufficient duration (> $tsmaxdurfunc) on workspace"
				foreach i $zzlist {
					if {$i >= 0} {
						$tslist selection set $i
					}
				}
				return 0
			}
	}
	if {($ts_srctype == $evv(TS_PAIR)) && ([llength $ts_sndslist] < 2)} {
		Inf "Insufficient sounds (requires 2) of sufficient duration (> $tsmaxdurfunc) on workspace"
		foreach i $zzlist {
			if {$i >= 0} {
				$tslist selection set $i
			}
		}
		return 0
	}
	if {($ts_srctype == $evv(TS_SOUNDS)) && ([llength $ts_sndslist] < $tsfpar1)} {
		set do_return 0
		set msg "Insufficient sounds on workspace (require $tsfpar1)"
		if {[llength $ts_slistlist] <= 0} {
			Inf $msg
			set do_return 1
		} else {
			append msg ": Show soundlist files ?"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "yes"} {
				set show_sndlists 1
			} else {
				set do_return 1
			}
		}
		if {$do_return} {
			foreach i $zzlist {
				if {$i >= 0} {
					$tslist selection set $i
				}
			}
			return 0
		}
	}
	set f .tsfsrcs
	if [Dlg_Create $f "select sound to process" "set pr_tsfsrcs 0" -borderwidth 2 -width 84] {
		frame $f.0
		button $f.0.qu -text "Quit" -command "set pr_tsfsrcs 0" -highlightbackground [option get . background {}]
		button $f.0.ss -text "Select" -command "set pr_tsfsrcs 1" -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $f.0.mm -text "Move To Top" -command "set pr_tsfsrcs 2" -highlightbackground [option get . background {}]
		button $f.0.rr -text "Reverse" -command "set pr_tsfsrcs 3" -highlightbackground [option get . background {}]
		button $f.0.oo -text "Original" -command "set pr_tsfsrcs 4" -highlightbackground [option get . background {}]
		label $f.0.dum -text "" -width 12
		button $f.0.pp -text "Play" -command "set pr_tsfsrcs 5" -highlightbackground [option get . background {}]
		button $f.0.vv -text "View" -command "set pr_tsfsrcs 6" -bg $evv(SNCOLOR) -highlightbackground [option get . background {}]
		label $f.0.dum2 -text "" -width 12
		button $f.0.slis -text "Show Sndlist files" -width 20 -command "set pr_tsfsrcs 7" -highlightbackground [option get . background {}]
		radiobutton $f.0.rand -text "Rand Select" -width 10  -variable tsgrpperm -value 0
		radiobutton $f.0.perm -text "Rand Perm"   -width 10  -variable tsgrpperm -value 1	
		pack $f.0.ss $f.0.mm $f.0.rr $f.0.oo $f.0.dum $f.0.pp $f.0.vv $f.0.dum2 $f.0.slis $f.0.rand $f.0.perm -side left -padx 2
		pack $f.0.qu -side right
		pack  $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.tit -text "Select a data-stretch file" -fg $evv(SPECIAL)
		label $f.1.tit2 -text "" -fg $evv(SPECIAL)
		set ts_srclist [Scrolled_Listbox $f.1.ll -width 128 -height 32 -selectmode single]
		pack $f.1.tit $f.1.tit2 $f.1.ll -side top -pady 2
		pack $f.1 -side top
		wm resizable $f 1 1
		bind $f <Return> {set pr_tsfsrcs 1}
		bind $f <Escape> {set pr_tsfsrcs 0}
		bind $f <Key-space> {set pr_tsfsrcs 5}
		bind $f <Up>   {IncrPlayN 0}
		bind $f <Down> {IncrPlayN 1}
	}
	set tsgrpperm -1
	switch -regexp -- $ts_srctype \
		^$evv(TS_ANAL)$ {
			wm title $f "Select analysis file to process"
			$f.1.tit config -text "Analysis Files"
			$f.1.tit2 config -text ""
			$ts_srclist config -selectmode single
		} \
		^$evv(TS_PAIR)$ {
			wm title $f "Select two sounds to process"
			$f.1.tit config -text "Sound Files"
			$f.1.tit2 config -text ""
			$ts_srclist  config -selectmode extended
		} \
		^$evv(TS_SOUNDS)$ {
			wm title $f "Select $tsfpar1 sounds to sequence"
			$f.1.tit config -text "Sound Files"
			$f.1.tit2 config -text ""
			$ts_srclist  config -selectmode extended
		} \
		default {
			wm title $f "Select sound to process"
			$f.1.tit config -text "Sound Files"
			$f.1.tit2 config -text ""
			$ts_srclist config -selectmode single
	}
	$ts_srclist delete 0 end
	if {[info exists show_sndlists]} {
		foreach fnam $ts_slistlist {
			$ts_srclist insert end $fnam
			lappend ts_sndslist $fnam
		}
	} else {
		foreach fnam $ts_sndslist {
			$ts_srclist insert end $fnam
			lappend ts_sndslist $fnam
		}
	}
	if [string match [.tsfsrcs.1.tit cget -text] "Sound Files"] {
		.tsfsrcs.0.slis config -text "Show Sndlist files" -bg [option get . background {}]
		.tsfsrcs.0.rand config -text "" -state disabled
		.tsfsrcs.0.perm config -text "" -state disabled	
		.tsfsrcs.1.tit2 config -text ""
	} else {
		.tsfsrcs.0.slis config -text "Show Sounds" -bg $evv(EMPH)
		.tsfsrcs.0.rand config -text "Rand Select" -state normal
		.tsfsrcs.0.perm config -text "Rand Perm" -state normal	
		.tsfsrcs.1.tit2 config -text "If several lists selected: choose Rand select (any item within group) or Rand perm (once all items selected in order, randperm order of group)"
	}
	set pr_tsfsrcs 0
	update idletasks
	raise $f
	update idletasks
	My_Grab 0 $f pr_tsfsrcs $f
	update idletasks
	set finished 0
	while {!$finished} {
		tkwait variable pr_tsfsrcs
		catch {unset ts_srcfiles($ts_srctype)}
		switch -- $pr_tsfsrcs {
			1 {
				if {[$ts_srclist index end] == 1} {
					set i 0
				} else {
					set i [$ts_srclist curselection]
				}
				if {([llength $i] <= 0) ||	(([llength $i] == 1) && ($i == -1))} {
					Inf "No file selected"
					continue
				}
				if {$ts_srctype == $evv(TS_PAIR)} {
					if {[llength $i] != 2} {
						Inf "Two files required"
						continue
					}
					set fnam1 [$ts_srclist get [lindex $i 0]]
					set fnam2 [$ts_srclist get [lindex $i 1]]
					set chans $pa($fnam1,$evv(CHANS))
					if {$chans > 2 } {
						Inf "File [file rootname [file tail $fnam1]] has too many channels (must be mono or stereo)"
						continue
					}
					if {$chans != $pa($fnam2,$evv(CHANS))} {
						Inf "Files do not have same number of channels"
						continue
					}
					set ts_srcfiles($ts_srctype) [list $fnam1 $fnam2]
					set tssrcsndchans $pa($fnam1,$evv(CHANS))
					set tssrcsnd [file rootname [file tail $fnam1]]
				} elseif {$ts_srctype == $evv(TS_SOUNDS)} {
					catch {unset tsgroup}
					set firstfile [$ts_srclist get [lindex $i 0]]
					set firsttype $pa($firstfile,$evv(FTYP))
					if {[IsASndlist $firsttype]} {										;#	DEAL WITH SELECTED SNDFILE-LISTS
						set do_return 0
						if {[llength $i] == 1} {										;#	Single snd-listing file
							set i [TsExtractFilesFromList $firstfile $tsfpar1 0 0]		;#	Converts single soundlisting file
							if {[llength $i] <= 0} {									;#	to an "i" list of sndfiles
								Inf "$tsfpar1 files required"							;#	if list has correct number of sndfiles
								set do_return 1											;#	all with same number of chans (and mono or stereo only)	
							}
							if {!$do_return} {
								set tssrcsndchans $tsgroupchans
								foreach ii $i {											;#	"i" has now been converted to point at the src-sndlist
									lappend ts_srcfiles($ts_srctype) [lindex $ts_sndslist $ii]
								}
								set tssrcsnd [file tail [lindex $ts_srcfiles($ts_srctype) 0]]
							}
						} elseif {[llength $i] == $tsfpar1 } {							;#	Treats N soundlists as N src-groups
							catch {unset fn_ams}										;#	(instead of N src sounds)
							foreach ii $i {
								lappend fn_ams [lindex $ts_slistlist $ii]
							}
							set n 0
							foreach fn_am $fn_ams {
								set j [TsExtractFilesFromList $fn_am $tsfpar1 1 $n]		;#	Converts each soundlisting file
								if {[llength $j] <= 0} {								;#	to a group of files for later group-processing
									set do_return 1										;#	Checking channel compatibility etc
									break
								}
								incr n
							}
							if {!$do_return && ($tsgrpperm < 0)} {
								Inf "Chose \"rand select\" or \"rand perm\""
								set do_return 1
							}
							if {!$do_return} {
								set tssrcsndchans $tsgroupchans							;#	sounds required are now in tsgroups
								foreach ii $i {											;#	"i" still refers to sndlists_listing
									lappend ts_srcfiles($ts_srctype) [lindex $ts_slistlist $ii]
								}
								set tssrcsnd [file tail [lindex $ts_srcfiles($ts_srctype) 0]]
							}
						} else {
							Inf "Wrong number ([llength $i]) of snd-listings (either 1 or $tsfpar1 required)"
							set do_return 1
						}
						if {$do_return} {
							continue
						}

					} else {															;#	DEAL WITH SELECTED SOUNDS
						if {[llength $i] != $tsfpar1} {
							Inf "Wrong number ([llength $i]) of sounds selected ($tsfpar1 required)"
							continue
						}
						set fnam1 [$ts_srclist get [lindex $i 0]]
						set chans $pa($fnam1,$evv(CHANS))
						if {$chans > 2 } {
							Inf "File [file rootname [file tail $fnam1]] has too many channels (must be mono or stereo)"
							continue
						}
						set fn_ams $fnam1
						set OK 1
						foreach ii $i {
							set fnam2 [$ts_srclist get $ii]
							set thischans $pa($fnam2,$evv(CHANS))
							if {$thischans != $chans} {
								Inf "Files do not have same number of channels"
								set OK 0
								break
							}
							lappend fn_ams $fnam2
						}
						if {!$OK} {
							continue
						}
						set tssrcsndchans $chans
						set ts_srcfiles($ts_srctype) $fn_ams
						set tssrcsnd [file tail [lindex ts_srcfiles($ts_srctype) 0]]
					}
				} else {
					set ilist $i
					set i [lindex $ilist 0]
					set fnam1 [$ts_srclist get $i]
					set chans $pa($fnam1,$evv(CHANS))
					if {($ts_srctype != $evv(TS_ANAL)) && ($chans > 2)} {
						Inf "File [file rootname [file tail $fnam1]] has too many channels (must be mono or stereo)"
						continue
					}
					set ts_srcfiles($ts_srctype) $fnam1
					if {[llength $ilist] > 1} {
						set ilist [lrange $ilist 1 end]
						set OK 1
						foreach i $ilist {
							set fnam1 [$ts_srclist get $i]
							set chansx $pa($fnam1,$evv(CHANS))
							if {$chans != $chansx } {
								Inf "File do not have same number of channels"
								set OK 0
								break
							}
							lappend ts_srcfiles($ts_srctype) $fnam1
						}
						if {!$OK} {
							continue
						}
					}
					set tssrcsndchans $pa($fnam1,$evv(CHANS))
					set tssrcsnd [file rootname [file tail $fnam1]]
				}
				set finished 1
			}
			2 {	;#	MOVE TO TOP
				set ilist [$ts_srclist curselection]
				if {([llength $ilist] <= 0) ||	(([llength $ilist] == 1) && ($ilist == -1))} {
					Inf "No file selected"
					continue
				}
				catch {unset nulist}
				foreach i $ilist {
					lappend nulist [$ts_srclist get $i]
				} 
				set ilen [llength $ilist]
				set len [$ts_srclist index end]
				set i 0
				while {$i < $len} {
					if {[lsearch $ilist $i] < 0} {
						lappend nulist [$ts_srclist get $i]
					}
					incr i
				}
				$ts_srclist selection clear 0 end
				$ts_srclist delete 0 end
				set i 0
				foreach fnam $nulist {
					$ts_srclist insert end $fnam
					if {$i < $ilen} {
						$ts_srclist selection set $i
					}
					incr i
				}
			}
			3 {	;#	REVERSE SELECTION
				set ilist [$ts_srclist curselection]
				if {[llength $ilist] < 2} {
					Inf "Less than two files selected"
					continue
				}
				catch {unset nulist}
				foreach i $ilist {
					lappend nulist [$ts_srclist get $i]
				} 
				set ilist [ReverseList $ilist]
				set j 0
				foreach i $ilist fnam $nulist {
					$ts_srclist delete $i
					$ts_srclist insert $i $fnam
				}
				foreach i $ilist {
					$ts_srclist selection set $i
				}
			}
			5 -
			6 {	;#	PLAY OR VIEW
				set ilist [$ts_srclist curselection]
				if {([llength $ilist] <= 0) || (([llength $ilist] == 1) && ($ilist == -1))} {
					Inf "No sound selected"
					continue
				} elseif {[llength $ilist] > 1} {
					Inf "Select just one sound"
					continue
				}
				set fnam [$ts_srclist get [lindex $ilist 0]]
				if {$pr_tsfsrcs == 5} {
					PlaySndfile $fnam 0
				} else {
					SnackDisplay 0 $evv(SN_FILE_PRMPAGE_NO_OUTPUT) 0 $fnam
				}
			}
			7 {
				if {$tsfunc != 21} {
					Inf "Only available with sequencer option"
					continue
				}
				if [string match [.tsfsrcs.1.tit cget -text] "Sound-listing files"] {
					if {[llength $ts_sndslist] <= 0} {
						Inf "No appropriate sounds on workspace"
						continue
					}
					$ts_srclist delete 0 end
					foreach fnam $ts_sndslist {
						$ts_srclist insert end $fnam
					}
					.tsfsrcs.0.slis config -text "Show Sndlist files" -bg [option get . background {}]
					.tsfsrcs.1.tit config -text "Sound Files"
					.tsfsrcs.1.tit2 config -text ""
					.tsfsrcs.0.rand config -text "" -state disabled
					.tsfsrcs.0.perm config -text "" -state disabled
				} else {
					if {[llength $ts_slistlist] <= 0} {
						Inf "No sound-listings on workspace"
						continue
					}
					$ts_srclist delete 0 end
					foreach fnam $ts_slistlist {
						$ts_srclist insert end $fnam
					}
					.tsfsrcs.0.slis config -text "Show Sounds" -bg $evv(EMPH)
					.tsfsrcs.1.tit config -text "Sound-listing files"
					.tsfsrcs.1.tit2 config -text "If several lists selected: choose Rand select (any item within group) or Rand perm (once all items selected in order, randperm order of group)"
					.tsfsrcs.0.rand config -text "Rand Select" -state normal
					.tsfsrcs.0.perm config -text "Rand Perm" -state normal	
				}
			}
			0 {
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	if {![info exists ts_srcfiles($ts_srctype)]} {
		return 0
	}
	foreach i $zzlist {
		if {$i >= 0} {
			$tslist selection set $i
		}
	}
	return 1
}

#---- Use time-series to process a file

proc RunTsFunc {} {
	global tslist tsdata tsflens tsoutfnam ts_srctype tsfunc ts_srcfiles tsmaxdurfunc tsplaylist tsdatanamlist tsfcmd tsequal
	global simple_program_messages prg_dun prg_abortd CDPidrun pa evv wstk
	global maxsamp_line done_maxsamp CDPmaxId ts_previous tsfmultisrcd tslog tssubfunccnt tscontrolfnam tsvarifunc

	set tsaside $evv(DFLT_OUTNAME)
	append tsaside 000 $evv(SNDFILE_EXT)

	set ilist [$tslist curselection]
	if {([llength $ilist] <= 0) || (([llength $ilist] == 1) && ($ilist < 0))} {
		Inf "No datafile selected for processing"
		return 0
	}
	set ts_previous $ilist

	if {![info exists ts_srctype] || ($ts_srctype < 0) || ![info exists tsfunc] || ($tsfunc < 0)} {
		Inf "No process selected"
		return 0
	}
	if {$tsfunc == 0} {
		set tsfmultisrcd 0
	} else {
		if {![info exists ts_srcfiles($ts_srctype)]} {
			Inf "No (appropriate) source sound files selected for processing"
			return 0
		}
		set len_data [llength $ilist]
		if {$tsfunc == 21} {
			if {$tssubfunccnt == 1} {
				set tsfmultisrcd 0		;#	EACH DATA FILE IN TURN GENERATES A MIXFILE
			} else {
				if {$len_data != $tssubfunccnt} {
					Inf "Select $tssubfunccnt data files, one to control each specified feature"
					return 0
				}
				set tsfmultisrcd 3		;#	THE SELECTED DATA FILES GENERATE A SINGLE MIXFILE
			}
			set len_srcs 1				;#	SOURCE BECOMES A SINGLE MIXFILE
		} else {
			set tsfmultisrcd 0
			if {$ts_srctype != $evv(TS_PAIR)} {
				set len_srcs [llength $ts_srcfiles($ts_srctype)]
				if {$len_srcs > 1} {
					if {$len_srcs == $len_data} {
						set tsfmultisrcd 1
					} elseif {$len_data == 1} {
						set tsfmultisrcd 2
					} else {
						set msg "Number of data files ($len_data) and number of source sounds ($len_srcs) differs\n"
						append msg "Select either\n"
						append msg "1) One source and several data files: apply all data to same source\n"
						append msg "2) Several sources and one data file: apply data to several source\n"
						append msg "3) N sources and N data files: apply each datafile to each source in turn\n"
						Inf $msg
					}
				}
			}
		}
	}
	catch {unset tsdata}
	catch {unset tsflens}
	set tsfmaxlen 0
	set n 0

	;#	ASSEMBLE LIST OF DATA FILES, AND THEIR DATA LENGTHS


	Block "Assessing data file lengths"
	foreach i $ilist {
		set thisfnam [$tslist get $i]
		lappend tsdata $thisfnam
		set len $pa($thisfnam,$evv(ALL_WORDS))
		lappend tsflens $len
		if {$len > $tsfmaxlen} {
			set tsfmaxlen $len
		}
		set tsoutfnam($n) $evv(DFLT_OUTNAME)
		append tsoutfnam($n) $n

		if {$ts_srctype == $evv(TS_ANAL)} {
			append tsoutfnam($n) $evv(ANALFILE_EXT)
		} else {
			append tsoutfnam($n) $evv(SNDFILE_EXT)
		}				
		incr n
	}

	;#	STORE RELATIVE LENGTHS OF DATA FILES, AS FRACTIONS OF MAXLEN
	;#	AND DELETE ANY EXISTING TEMPORARY OUTFILES

	set cnt $n
	set n 0
	while {$n < $cnt} {
		set len [expr double([lindex $tsflens $n])/double($tsfmaxlen)]
		set tsflens [lreplace $tsflens $n $n $len]
		if {[file exists $tsoutfnam($n)]} {
			catch {file delete $tsoutfnam($n)}
		}
		incr n	
	}
	wm title .blocker "PLEASE WAIT:        Checking fixed parameters"			
	if {![CheckTsFuncFixedParams]} {
		UnBlock
		return 0
	}
	wm title .blocker "PLEASE WAIT:        Checking ranges of control files"			
	if {![CheckTsFuncRangingParam]} {
		UnBlock
		return 0
	}
	wm title .blocker "PLEASE WAIT:        Establishing process commandline"			
	set tsflen [EstablishTsFuncCmdline]
	if {[llength $tsflen] <= 0} {
		UnBlock
		return 0
	}
	set n 0
	catch {unset badfiles}
	catch {unset goodfiles}
	set files_to_process [llength $tsdata]
	set finished 0

	while {!$finished} {

		;#	FOR (1 src : many data) tsfmultisrcd == 0 : 
		;#		Goes round FOREACH loop once: as tsfmultisrcd==0 (!=2), exits WHILE!FINISHED loop
		;#	FOR (N srcs: N data)    tsfmultisrcd == 1 : 
		;#		Goes round FOREACH loop once, upping infile with 'n'
		;#		when srcs exhausted, sets 'finished': as finished set, exits WHILE!FINISHED loop
		;#	FOR (N srcs: 1 data)    tsfmultisrcd == 2 : 
		;#		Goes round FOREACH loop 'n' times, upping infile with 'n'
		;#		when srcs exhausted, sets 'finished' : as finished set, exits WHILE!FINISHED loop
		;#	FOR (N srcs: K data)    tsfmultisrcd == 3 : 
		;#		Goes round FOREACH loop once, then exits near top as len_srcs has been preset to 1
		;#		this sets  finished, so exits WHILE!FINISHED loop

		foreach fnam $tsdata {

			if {($n > 0) && $tsfmultisrcd} {
				if {$n >= $len_srcs} {			;#	tsfmultisrcd=3 automatically drops out after 1 pass
					set finished 1
					break
				}
				set k [lsearch $tsfcmd [lindex $ts_srcfiles($ts_srctype) [expr $n - 1]]]
				set tsfcmd [lreplace $tsfcmd $k $k [lindex $ts_srcfiles($ts_srctype) $n]]
			}
			wm title .blocker "PLEASE WAIT:        Generating control file from [file rootname [file tail $fnam]]"			
#KLUDGE
			if {[llength $tsflens] <= $n} {
				set finished 1
				break
			}
#KLUDGE
			if {![GenerateTsControlFiles $fnam $n $tslog]} {
				incr n
				continue							;#	GENERATE APPROPRIATE CONTROL FILE, FROM INPUT DATA
			}
			if {$tsfunc == 0}  {
				if [catch {file rename $tsvarifunc(1) $tscontrolfnam($n)} zit] {
					lappend badfiles $n
				} else {
					lappend goodfiles $tscontrolfnam($n)
				}
				incr n
				continue
			}
			set cmd $tsfcmd
			set k [lsearch $cmd "__outfile__"]		;#	INSERT NEXT OUTPUT FILE INTO CMDLINE
			set cmd [lreplace $cmd $k $k $tsoutfnam($n)]

			set k [lsearch $cmd "__outdur__"]		;#	IF CMDLINE REQUIRES OUTPUT DURATION, INSERT
			if {$k >= 0} {
				if {$tsequal} {			
					set cmd [lreplace $cmd $k $k $tsmaxdurfunc]
				} else {
					set thisdur [expr $tsmaxdurfunc * [lindex $tsflens $n]]
					set cmd [lreplace $cmd $k $k $thisdur]
				}
			}
			catch {unset simple_program_messages}
			set prg_dun 0
			set prg_abortd 0
			wm title .blocker "PLEASE WAIT:        Processing item [expr $n + 1]"			
			if [catch {open "|$cmd"} CDPidrun] {
				ErrShow "Failed to run the process with [file rootname [file tail $fnam]]"
				catch {unset CDPidrun}
				lappend badfiles $n
				incr n
				continue
			} else {
				fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
			}
			vwait prg_dun
			if {$prg_abortd} {
				set prg_dun 0
			}
			if {!$prg_dun} {
				set msg "Process  [expr $n + 1] failed"
				set msg [AddSimpleMessages $msg]
				ErrShow $msg
				lappend badfiles $n
				incr n
				continue
			}
			if {![file exists $tsoutfnam($n)]} {
				set msg "Process [expr $n + 1] produced no output file"
				ErrShow $msg
				lappend badfiles $n
				incr n
				continue
			}
			if {$ts_srctype == $evv(TS_ANAL)} {
				set done 0 
				while {!$done} {
					set outfilenam [file rootname $tsoutfnam($n)]
					append outfilenam $evv(SNDFILE_EXT)
					if {[file exists $outfilenam]} {
						if [catch {file delete $outfilenam} zit] {
							Inf "Cannot delete intermediate file: cannot resynth output [expr $n + 1]"
							set done 1
							break
						}
					}
					set cmd2 [file join $evv(CDPROGRAM_DIR) pvoc]
					lappend cmd2 synth $tsoutfnam($n) $outfilenam
					catch {unset simple_program_messages}
					set prg_dun 0
					set prg_abortd 0
					wm title .blocker "PLEASE WAIT:        Resynthesizing file [expr $n + 1]"			
					if [catch {open "|$cmd2"} CDPidrun] {
						ErrShow "Failed to resynth file	[expr $n + 1]"
						catch {unset CDPidrun}
						set done 1
						break
					} else {
						fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
					}
					vwait prg_dun
					if {$prg_abortd} {
						set prg_dun 0
					}
					if {!$prg_dun} {
						set msg "Resynthesis [expr $n + 1] failed"
						set msg [AddSimpleMessages $msg]
						ErrShow $msg
						set done 1
						break
					}
					if {![file exists $outfilenam]} {
						set msg "Resynthesis [expr $n + 1] produced no output file"
						ErrShow $msg
						set done 1
						break
					}
					catch {file delete $tsoutfnam($n)}
					set tsoutfnam($n) $outfilenam
					set done 1
			
				}
			} elseif {$tsfunc == 21} {

			;#	NEED TO TEST LEVEL 

				set done 0				
				while {!$done} {
					wm title .blocker "PLEASE WAIT:        Checking level"
					set cmd2 [file join $evv(CDPROGRAM_DIR) maxsamp2]
					catch {unset maxsamp_line}
					set done_maxsamp 0
					lappend cmd2 $tsoutfnam($n)
					if [catch {open "|$cmd2"} CDPmaxId] {
						Inf "Failed to find maximum level of output: outfile could be distorted"
						set done 1
						break
					}
					fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
					vwait done_maxsamp
					if {![info exists maxsamp_line]} {
						Inf "Cannot retrieve maximum level information: outfile could be distorted"
						set done 1
						break
					}
					set maxoutsamp [lindex $maxsamp_line 0]
					if {$maxoutsamp <= 0.95} {
						set done 1
						break
					}
					if [catch {file delete $tsoutfnam($n)} zit] {
						Inf "Cannot delete the distorted output file, to remix"
						break
					}
					wm title .blocker "PLEASE WAIT:        Recreating mix to assess best level"
					lappend cmd -g0.1
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					if [catch {open "|$cmd"} CDPidrun] {
						catch {unset CDPidrun}
						ErrShow "Cannot do remix of sounds: $CDPidrun"
						catch {file delete $tsoutfnam($n)}
						break
					} else {
						fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
					}
					vwait prg_dun
					if {$prg_abortd} {
						set prg_dun 0
					}
					if {!$prg_dun} {
						set msg "Failed to remix sounds:"
						set msg [AddSimpleMessages $msg]
						ErrShow $msg
						catch {file delete $tsoutfnam($n)}
						break
					}
					if {![file exists $tsoutfnam($n)]} {
						set msg "Failed to generate new output sound:"
						set msg [AddSimpleMessages $msg]
						ErrShow $msg
						catch {file delete $tsoutfnam($n)}
						break
					}
					wm title .blocker "PLEASE WAIT:        2nd level check"
					catch {unset maxsamp_line}
					set done_maxsamp 0
					if [catch {open "|$cmd2"} CDPmaxId] {
						Inf "Failed to find max level on second check: output attenuated"
						set done 1
						break
					}
					fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
					vwait done_maxsamp
					if {![info exists maxsamp_line]} {
						Inf "Cannot retrieve max level: output attenuated"
						set done 1
						break
					}
					set maxoutsamp [lindex $maxsamp_line 0]
					set nulevel [expr 0.1 * 0.95/$maxoutsamp]
					set cmd [lreplace $cmd end end -g$nulevel]
					if [catch {file delete $tsoutfnam($n)} zit] {
						Inf "Cannot delete the test output file, to do final mix"
						break
					}
					wm title .blocker "PLEASE WAIT:        Final remix"
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					if [catch {open "|$cmd"} CDPidrun] {
						catch {unset CDPidrun}
						ErrShow "Cannot do final remix of sounds: $CDPidrun"
						catch {file delete $tsoutfnam($n)}
						break
					} else {
						fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
					}
					vwait prg_dun
					if {$prg_abortd} {
						set prg_dun 0
					}
					if {!$prg_dun} {
						set msg "Failed to do final remix of sounds:"
						set msg [AddSimpleMessages $msg]
						ErrShow $msg
						catch {file delete $tsoutfnam($n)}
						break
					}
					if {![file exists $tsoutfnam($n)]} {
						set msg "Failed to generate final output sound:"
						set msg [AddSimpleMessages $msg]
						ErrShow $msg
						catch {file delete $tsoutfnam($n)}
						break
					}
					set done 1
				}
				if {!$done} {
					incr n		;#		FILE LOST IN RE-LEVELLING
					continue
				}
			}
			lappend goodfiles $n
			if {$tsflen  && ![string match [file extension tsoutfnam($n)] $evv(ANALFILE_EXT)]} {
				set indur $pa([lindex $ts_srcfiles($ts_srctype) 0],$evv(DUR))
				if {$tsfunc == 20} {
					if {$pa([lindex $ts_srcfiles($ts_srctype) 1],$evv(DUR)) < $indur} {
						set indur $pa([lindex $ts_srcfiles($ts_srctype) 1],$evv(DUR))
					}
				}
				if {$tsmaxdurfunc < $indur} {
					set done 0
					while {!$done} {
						if {[file exists $tsaside]} {
							if [catch {file delete $tsaside} zit] {
								Inf "Cannot delete intermediate file: cannot truncate output [expr $n + 1]"
								set done 1
								break
							}
						}
						if [catch {file rename $tsoutfnam($n) $tsaside} zit] {
							Inf "Cannot truncate output [expr $n + 1]"
							set done 1
							break
						}
						set len [llength $goodfiles]
						incr len -1
						if {$len < 0} {
							unset goodfiles
						} else {
							set goodfiles [lrange $goodfiles 0 $len]
						}
						set cmd [file join $evv(CDPROGRAM_DIR) envel]
						lappend cmd curtail 4 $tsaside $tsoutfnam($n) [expr $tsmaxdurfunc - 0.02] $tsmaxdurfunc
						catch {unset simple_program_messages}
						set prg_dun 0
						set prg_abortd 0
						wm title .blocker "PLEASE WAIT:        Truncating file [expr $n + 1]"			
						if [catch {open "|$cmd"} CDPidrun] {
							ErrShow "Failed to truncate file [file rootname [file tail $fnam]]""
							catch {unset CDPidrun}
							lappend badfiles $n
							incr n
							continue
						} else {
							fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
						}
						vwait prg_dun
						if {$prg_abortd} {
							set prg_dun 0
						}
						if {!$prg_dun} {
							set msg "Truncation [expr $n + 1] failed"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							lappend badfiles $n
							incr n
							continue
						}
						if {![file exists $tsoutfnam($n)]} {
							set msg "Truncation [expr $n + 1] produced no output file"
							ErrShow $msg
							lappend badfiles $n
							incr n
							continue
						}
						lappend goodfiles $n
						set done 1
					}
				}
			}
			incr n
		}
		if {$tsfmultisrcd != 2} {
			break
		}
	}
	UnBlock
	if {![info exists goodfiles]} {
		Inf "Process produced no outputs"
		if {[info exists badfiles]} {
			foreach n $badfiles {
				catch {file delete $tsoutfnam($n)}
			}
		}
		return 0
	} elseif {[info exists badfiles]} {
		foreach n $badfiles {
			catch {file delete $tsoutfnam($n)}
		}
		set msg "Not all files were processed: continue ??"
		set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return 0
		}
	} elseif {$tsfunc > 0} {
		Inf "Sounds generated"
	}
	if {$tsfunc == 0} {
		set goodfiles [ReverseList $goodfiles]
		foreach fnam $goodfiles {
			FileToWkspace $fnam 0 0 0 0 1
		}
		Inf "Control files are on the workspace"
		return 1
	}
	catch {unset tsplaylist}
	catch {unset tsdatanamlist}
	set n 0
	if {$tsfmultisrcd == 3} {
		set files_to_process 1
	}
	while {$n < $files_to_process} {
		if {[file exists $tsoutfnam($n)]} {
			lappend tsplaylist $tsoutfnam($n)
			lappend tsdatanamlist [lindex $tsdata $n]
		}
		incr n
	}
	return $files_to_process
}

#---- Check validity of fixed parameters for processes running with time-series data

proc CheckTsFuncFixedParams {} {
	global tsfunc pa evv tsfpar1 tsfpar2 tsfpar3 tsfpar4 ts_srcfiles ts_srctype
	switch -- $tsfunc {
		1 -
		2 {
			set nam1 "LEVEL"
			set min(1) 0.001
			set max(1) 1.0
		}
		3 {
			set nam1 "LEVEL"
			set min(1) 0.001
			set max(1) 1.0
			set nam2 "PACKING"
			set min(2) [expr 1.0/double($evv(TS_SRATE))]
			set max(2) 60.0
		}
		4 -
		5 -
		6 {
			set nam1 "DECAY EXPONENT"
			set min(1) 0.02
			set max(1) 50.0
		}
		8 {
			set nam1 "DEPTH"
			set min(1) 0.0
			set max(1) 1.0
		}
		10 {
			set nam1 "DEPTH"
			set min(1) 0.0
			set max(1) 96.0
		}
		9 -
		11 {
			set nam1 "FREQUENCY"
			set min(1) 0.0
			set max(1) 500.0
		}
		12 {
			set nam1 "SPLICELEN"
			set min(1) 1.0
			set max(1) 50.0
		}
		13 -
		14 -
		15 {
			set nam1 "LOCUS"
			set min(1) 0.0
			set max(1) $pa([lindex $ts_srcfiles($ts_srctype) 0],$evv(DUR))
			set nam2 "AMBITUS"
			set min(2) 0.0
			set max(2) $pa([lindex $ts_srcfiles($ts_srctype) 0],$evv(DUR))
			set nam3 "STEP"
			set min(3) 0.0
			set max(3) $pa([lindex $ts_srcfiles($ts_srctype) 0],$evv(DUR))
			set nam4 "CLOCK RATE"
			set min(4) .031
			set max(4) $pa([lindex $ts_srcfiles($ts_srctype) 0],$evv(DUR))
		}
		16 -
		17 {
			set nam1 "LOW FRQ"
			set min(1) 10
			set max(1) [expr double($evv(TS_SRATE))/2.0]
			set nam2 "HIGH FRQ"
			set min(2) 10
			set max(2) [expr double($evv(TS_SRATE))/2.0]
			set nam3 "GAIN"
			set min(3) 0.001
			set max(3) 1.0
		}
		19 {
			set nam1 "FRQ DIVIDE"
			set min(1) 16
			set max(1) [expr double($evv(TS_SRATE))/2.0]
			set nam2 "MAX STRETCH"
			set min(2) [expr 20.0/double($evv(TS_SRATE))]
			set max(2) [expr double($evv(TS_SRATE))/20.0]
			set nam3 "EXPONENT"
			set min(3) 0.02
			set max(3) 50.0
		}
		21 {
			set nam1 "NUMBER OF SOURCES"
			set min(1) 2
			set max(1) 1024
		}
	}
	switch -- $tsfunc {
		1  -
		2  -
		3  -
		4  -
		5  -
		6  -
		8  -
		9  -
		10 -
		11 -
		12 -
		14 -
		15 -
		16 -
		19 - 
		21 {
			if {![info exists tsfpar1] || ([string length $tsfpar1] <= 0) || ![IsNumeric $tsfpar1]} {
				Inf "No valid $nam1 parameter entered"
				return 0
			}
			if {($tsfpar1 < $min(1)) || ($tsfpar1 > $max(1))} {
				Inf "$nam1 parameter out of range (range $min(1) - $max(1))"
				return 0
			}
		}
	}
	switch -- $tsfunc {
		3  -
		13 -
		15 -
		16 -
		17 -
		19 {
			if {![info exists tsfpar2] || ([string length $tsfpar2] <= 0) || ![IsNumeric $tsfpar2]} {
				Inf "No valid $nam2 parameter entered"
				return 0
			}
			if {($tsfpar2 < $min(2)) || ($tsfpar2 > $max(2))} {
				Inf "$nam2 parameter out of range (range $min(2) - $max(2))"
				return 0
			}
		}
	}
	switch -- $tsfunc {
		13 -
		14 -
		15 -
		16 -
		17 -
		19 {
			if {![info exists tsfpar3] || ([string length $tsfpar3] <= 0) || ![IsNumeric $tsfpar3]} {
				Inf "no valid $nam3 parameter entered"
				return 0
			}
			if {($tsfpar3 < $min(3)) || ($tsfpar3 > $max(3))} {
				Inf "$nam3 parameter out of range (range $min(3) - $max(3))"
				return 0
			}
		}
	}
	switch -- $tsfunc {
		13 -
		14 {
			if {![info exists tsfpar4] || ([string length $tsfpar4] <= 0) || ![IsNumeric $tsfpar4]} {
				Inf "No valid $nam4 parameter entered"
				return 0
			}
			if {($tsfpar4 < $min(4)) || ($tsfpar4 > $max(4))} {
				Inf "$nam4 parameter out of range  (range $min(4) - $max(4))"
				return 0
			}
		}
	}
	return 1
}

#---- Check validity of ranged parameters controlled by time-series data

proc CheckTsFuncRangingParam {} {
	global tsfunc evv ts_srcfiles ts_srctype tsrmin tsrmax tsdata tsmaxdurfunc tsbrkstep tsfnam pa evv
	global tscontrolfnam tsdatanamtype
	switch -- $tsfunc {
		0 {
			set nam1 "CONTROL DATA RANGE"
			set min(r) -32768.0
			set max(r) 32767.0

			if {$tsdatanamtype > 0} {
				if {$tsdatanamtype == 1} {
					Inf "Using the datafile names may generate two files with same name: use prefixing"
					return 0
				}
			}
			set n 0
			set len [llength $tsdata]
			if {[string length $tsfnam] <= 0} {
				Inf "No output control file name given"
				return 0	
			}
			if {![ValidCDPRootname $tsfnam]} { 
				return 0	
			}
			catch {unset tscontrolfnam}
			if {$len == 1} {

				if {$tsdatanamtype == 2} {	;#	Prefixing
					set outfnam [string tolower $tsfnam]
					append outfnam "_" [file rootname [file tail [lindex $tsdata 0]]] [GetTextfileExtension brk]
				} else {
					set outfnam [string tolower $tsfnam]
					append outfnam [GetTextfileExtension brk]
				}
				if {[file exists $outfnam]} {
					Inf "File $outfnam exists: choose a different name"
					return 0
				}
				set tscontrolfnam(0) $outfnam
			} else {
				set n 0
				set m 1
				while {$n < $len} {
					if {$tsdatanamtype == 2} {	;#	Prefixing
						set outfnam [string tolower $tsfnam]
						append outfnam "_" [file rootname [file tail [lindex $tsdata $n]]] [GetTextfileExtension brk]
					} else {
						set outfnam [string tolower $tsfnam]
						append outfnam $m [GetTextfileExtension brk]
						if {[file exists $outfnam]} {
							Inf "File $outfnam exists: choose a different name"
							return 0
						}
					}
					set tscontrolfnam($n) $outfnam
					incr n
					incr m
				}
			}
		}
		1 -
		2 {
			set nam1 "PACKING"
			set min(r) [expr 1.0/double($evv(TS_SRATE))]
			set max(r) 60.0
		}
		3 {
			set nam1 "MIDI PITCH"
			set min(r) 36.0
			set max(r) 84.0
		}
		4 -
		5 -
		6 {
			set nam1 "WAVESET COUNT"
			set min(r) 1.0
			set max(r) 1000.0
		}
		8 -
		10 {
			set nam1 "FREQUENCY"
			set min(r) 0.0
			set max(r) 500.0
		}
		9 {
			set nam1 "DEPTH"
			set min(r) 0.0
			set max(r) 1.0
		}
		11 {
			set nam1 "DEPTH"
			set min(r) 0.0
			set max(r) 96.0
		}
		15 {
			set nam1 "CLOCK RATE"
			set min(r) .031
			set max(r) $pa([lindex $ts_srcfiles($ts_srctype) 0],$evv(DUR))
		}
		16 -
		17 {
			set nam1 "Q OF FILTER"
			set min(r) 8
			set max(r) 1000
		}
		18 {
			set nam1 "FRQ SHIFT"
			set min(r) [expr -double($evv(TS_SRATE))/2.0]
			set max(r) [expr  double($evv(TS_SRATE))/2.0]
		}
	}
	if {[info exists nam1]} {
		if {($tsrmin < $min(r)) || ($tsrmax < $min(r))} {
			Inf "Invalid lower value for range of $nam1 (Range $min(r) - $max(r))"
			return 0
		}
		if {($tsrmax > $max(r)) || ($tsrmin > $max(r))} {
			Inf "Invalid upper value for range of $nam1 (Range $min(r) = $max(r))"
			return 0
		}
	}
	if {$tsfunc != 12} {
		if {[string length $tsbrkstep] <= 0} {
			Inf "No data step specified"
			return 0
		}
		if {![IsNumeric $tsbrkstep] || ($tsbrkstep <= 0.0)} {
			Inf "Invalid data step specified"
			return 0
		}
		if {$tsfunc == 21} {
			if {$tsbrkstep >= [expr $tsmaxdurfunc / 2]} {
				Inf "Invalid data step specified (too large for specified output duration)"
				return 0
			}
		} elseif {$tsfunc != 0} {
			if {$tsbrkstep >= $pa([lindex $ts_srcfiles($ts_srctype) 0],$evv(DUR))} {
				Inf "Invalid data step specified"
				return 0
			}
		}
	}
	if {[string length $tsmaxdurfunc] <= 0} {
		Inf "No output duration entered"
		return 0
	}
	if {![IsNumeric $tsmaxdurfunc]} {
		Inf "Invalid output duration entered"
		return 0
	} elseif {($tsmaxdurfunc < 1) || ($tsmaxdurfunc > 600)} {
		Inf "Duration value out of range (1 - 600 secs)"
		return 0
	}
	return 1
}

#--- Set up cmdline for specific process, leaving indata file (and possibly outdur) "blank"

proc EstablishTsFuncCmdline {} {
	global evv tsfunc ts_srcfiles ts_srctype tsvarifunc tsfpar1 tsfpar2 tsfpar3 tsfpar4 tsfcmd tscrand tsseqmix

	catch {unset tsfcmd}

	set notedatafile $evv(DFLT_OUTNAME)
	append notedatafile 000 $evv(TEXT_EXT)

	;#	NB, AT THIS STAGE, tsvarifuncs ARE SIMPLY NAMES: ACTUAL FILES HAVE YET TO BE CREATED

	set tsseqmix $evv(DFLT_OUTNAME)
	append tsseqmix 111 [GetTextfileExtension mix]
	set tsvarifunc(1) $evv(DFLT_OUTNAME)
	append tsvarifunc(1) 111 $evv(TEXT_EXT) 
	set tsvarifunc(2) $evv(DFLT_OUTNAME)
	append tsvarifunc(2) 222 $evv(TEXT_EXT) 

	switch -- $tsfunc {
		0 {
			return 1
		}
		1 -
		2 -
		3 {
			set thisprg "texture"
			set subprg "simple"
			set mode 5
			if {![file exists notedatafile]} {
				if [catch {open $notedatafile "w"} zit] {
					Inf "Cannot create notedata file for texture process"
					return {}
				}
				puts $zit 60
				close $zit
			}
		}
		4 -
		5 -
		6 {
			set thisprg "distort"
			set subprg "envel"
			switch -- $tsfunc {
				4 { set mode 1 }
				5 { set mode 2 }
				6 { set mode 3 }
			}
		}
		7 {
			set thisprg "distort"
			set subprg "omit"
		}
		8  -
		9  {
			set thisprg "envel"
			set subprg "tremolo"
			set mode "1"
		}
		10 -
		11 {
			set thisprg "modify"
			set subprg "speed"
			set mode "6"
		}
		12 {
			set thisprg "extend"
			set subprg "zigzag"
			set mode "2"
		}
		13 -
		14 -
		15 {
			set thisprg "extend"
			set subprg "drunk"
			set mode "1"
		}
		16 -
		17 {
			set thisprg "filter"
			set subprg "bank"
			switch -- $tsfunc {
				16 { set mode 1 }
				17 { set mode 3 }
			}
		}
		18 {
			set thisprg "strange"
			set subprg "shift"
			set mode "1"
		}
		19 {
			set thisprg "stretch"
			set subprg "spectrum"
			set mode "1"
		}
		20 {
			set thisprg "submix"
			set subprg "balance"
		}
		21 {
			set thisprg "submix"
			set subprg "mix"
		}
	}
	set cmd [file join $evv(CDPROGRAM_DIR) $thisprg]
	lappend cmd $subprg
	if {[info exists mode]} {
		lappend cmd $mode
	}
	switch -- $tsfunc {			;#	ADD INPUT SOUND(S)
		20 {
			set cmd [concat $cmd $ts_srcfiles($ts_srctype)]		;#	Two src files are mixed
		}
		21 {
			set cmd [concat $cmd $tsseqmix]				;#	MIXFILE IS GENERATED AT varifunc stage
		} 
		default {
			lappend cmd [lindex $ts_srcfiles($ts_srctype) 0]	;#	1 Src is processed
		}
	}
	lappend cmd "__outfile__"	;#	ADD TEMPORARY POSITION HOLDER FOR OUTFILE
	
	set tsflen 0

	switch -- $tsfunc {
		1 {
			lappend cmd $notedatafile __outdur__ $tsvarifunc(1)		;#	__outdur__ IS TEMPORARY POSITION HOLDER
			lappend cmd 1 0 1 1 32 127 1 1 58.5 61.5 -a$tsfpar1 -p.5 -s1 -w
		}
		2  {
			lappend cmd $notedatafile __outdur__ $tsvarifunc(1)
			lappend cmd 0 0 1 1 32 127 1 1 58.5 61.5 -a$tsfpar1 -p.5 -s1 -w 
		}
		3 {
			lappend cmd $notedatafile __outdur__ $tsfpar2
			lappend cmd 1 0 1 1 32 127 1 1 $tsvarifunc(1) $tsvarifunc(2) -a$tsfpar1 -p.5 -s1 -w
		}
		4 -
		5 {
			lappend cmd $tsvarifunc(1) -e$tsfpar1
			set tsflen 1
		}
		6 {
			lappend cmd $tsvarifunc(1) 0 -e$tsfpar1
			set tsflen 1
		}
		7 {
			lappend cmd $tsvarifunc(1) 64
			set tsflen 1
		}
		8  {
			lappend cmd $tsvarifunc(1) $tsfpar1 1
			set tsflen 1
		}
		9  {
			lappend cmd $tsfpar1 $tsvarifunc(1) 1
			set tsflen 1
		}
		10 {
			lappend cmd $tsvarifunc(1) $tsfpar1
			set tsflen 1
		}
		11 {
			lappend cmd $tsfpar1 $tsvarifunc(1)
			set tsflen 1
		}
		12 {
			lappend cmd $tsvarifunc(1) -s$tsfpar1
			set tsflen 1
		}
		13 {
			lappend cmd __outdur__ $tsvarifunc(1) $tsfpar2 $tsfpar3 $tsfpar4 -s5
			if {$tscrand} {
				 lappend cmd -c0.5
			}
		}
		14 {
			lappend cmd __outdur__ $tsfpar1 $tsvarifunc(1) $tsfpar3 $tsfpar4 -s5
			if {$tscrand} {
				 lappend cmd -c0.5
			}
		}
		15 {
			lappend cmd __outdur__ $tsfpar1 $tsfpar2 $tsfpar3 $tsvarifunc(1) -s5
			if {$tscrand} {
				 lappend cmd -c0.5
			}
		}
		16 {
			lappend cmd $tsvarifunc(1) $tsfpar3 $tsfpar1 $tsfpar2 -d
			set tsflen 1
		}
		17 {
			lappend cmd $tsvarifunc(1) $tsfpar3 $tsfpar1 $tsfpar2 -d
			set tsflen 1
		}
		18 {
			lappend cmd $tsvarifunc(1)
			set tsflen 1
		}
		19 {
			lappend cmd $tsfpar1 $tsfpar2 $tsfpar3 -d$tsvarifunc(1)
			set tsflen 1
		}
		20 {
			lappend cmd -k$tsvarifunc(1)
			set tsflen 1
		}
	}
	set tsfcmd $cmd
	return $tsflen
}

#-- Generate appropriate control files from data files

proc GenerateTsControlFiles {indata n islog} {
	global tsfunc tsvarifunc tsequal tsmaxdurfunc tsflens tsrmin tsrmax ts_srcfiles ts_srctype pa evv
	global simple_program_messages prg_dun prg_abortd CDPidrun tsfpar1 tsbrkstep tsdata tsfmultisrcd

	if {[file exists $tsvarifunc(1)]} {
		if [catch {file delete $tsvarifunc(1)} zit] {
			Inf "Cannot delete the previous control file $tsvarifunc(1)"
			return 0
		}
	}
	if {[file exists $tsvarifunc(2)]} {
		if [catch {file delete $tsvarifunc(2)} zit] {
			Inf "Cannot delete the previous brkpnt control file $tsvarifunc(2)"
			return 0
		}
	}
	if {$tsequal} {
		set dur $tsmaxdurfunc
	} else {
		set dur [expr $tsmaxdurfunc * [lindex $tsflens $n]]
	}
	if {$tsfmultisrcd != 3} {				;#	Several control data files on one soundfile
		if {$tsfmultisrcd == 2} {			
			set fnam [lindex $tsdata 0]		;#	One control data file on 1 or more soundfiles
		} else {							
			set fnam [lindex $tsdata $n]	;#	Each data file in turn on just 1 soundfile, or on the Nth soundfile
		}
		if {$tsfunc != 12} {	;#	ALL EXCEPT ZIGZAG (where control data not a (time-val) file) need brkpoint time-values
			set datalen $pa($fnam,$evv(ALL_WORDS)) 
			set step [expr $dur / double($datalen)]
			set rat [expr $tsbrkstep / $step]
			set dur [expr $dur * $rat]
		}
	}
	set cmd [file join $evv(CDPROGRAM_DIR) tsconvert]

	switch -- $tsfunc {
		0  -
		1  - 
		2  -
		4  -
		5  -
		6  -
		8  -
		9  -
		10 -
		11 -
		15 -
		18 {
			set cmd1 $cmd
			lappend cmd1 $indata $tsvarifunc(1) $tsrmin $tsrmax -d$dur	;#	Brkpnt file, between given min and max vals
		}
		13 -
		14 {
			set cmd1 $cmd
			lappend cmd1 $indata $tsvarifunc(1) 0 $pa([lindex $ts_srcfiles($ts_srctype) 0],$evv(DUR)) -d$dur	;#	Brkpnt file, between start and end of src file
		}
		3 {
			set cmd1 $cmd
			lappend cmd1 $indata $tsvarifunc(1) 60 $tsrmin -d$dur -r		;#	Data rectified around mean, varies DOWN 60 to min
			set cmd2 $cmd
			lappend cmd2 $indata $tsvarifunc(2) 60 $tsrmax -d$dur -r		;#	Data rectified around mean, varies from 60 to max
			if {$islog} {
				lappend cmd12 -l
			}
		}
		7 {
			set cmd1 $cmd
			lappend cmd1 $indata $tsvarifunc(1) 1 63 -d$dur -r			;#	Data rectified around mean, and across fixed range 1-63
		}
		12 {
			set cmd1 $cmd												;#	Variation is across width of file, and NOT a brkfile
																		;#	Data must be compacted, and cut off when it reaches desired duration
			lappend cmd1 $indata $tsvarifunc(1) 0 [expr $pa([lindex $ts_srcfiles($ts_srctype) 0],$evv(DUR)) - 0.001]
			lappend cmd1 -c[expr ($tsfpar1 * $evv(MS_TO_SECS) * 2) + 0.001] -m$tsmaxdurfunc
		}
		16 -
		17 {
			set cmd1 $cmd
			lappend cmd1 $indata $tsvarifunc(1) $tsrmin $tsrmax -d$dur
		}
		19 -
		20 {
			set cmd1 $cmd												;#	Depth varies across fixed range 0 to 1
			lappend cmd1 $indata $tsvarifunc(1) 0 1 -d$dur
		}
		21 {
			if {![GenerateTSSequenceMixfile $indata]} {
				return 0
			}
			return 1
		}
	}
	if {$islog} {
		lappend cmd1 -l
	}
	catch {unset simple_program_messages}
	set prg_dun 0
	set prg_abortd 0
	if [catch {open "|$cmd1"} CDPidrun] {
		ErrShow "Failed to create control brkfile"
		catch {unset CDPidrun}
		catch {file delete $tsvarifunc(1)}
		return 0
	} else {
		fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
	}
	vwait prg_dun
	if {$prg_abortd} {
		set prg_dun 0
	}
	if {!$prg_dun} {
		set msg "Creating control brkfile failed"
		set msg [AddSimpleMessages $msg]
		ErrShow $msg
		catch {file delete $tsvarifunc(1)}
		return 0
	}
	if {[info exists cmd2]} {
		set prg_dun 0
		set prg_abortd 0
		wm title .blocker "PLEASE WAIT:        Creating second control brkfile"			
		if [catch {open "|$cmd2"} CDPidrun] {
			ErrShow "Failed to create second control brkfile""
			catch {unset CDPidrun}
			catch {file delete $tsvarifunc(1)}
			catch {file delete $tsvarifunc(2)}
			return 0
		} else {
			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			set msg "Creating second control brkfile failed"
			set msg [AddSimpleMessages $msg]
			ErrShow $msg
			catch {file delete $tsvarifunc(1)}
			catch {file delete $tsvarifunc(2)}
			return 0
		}
	}
	return 1
}

#--- Load and Save list of files used as source files for processing by Time-series 

proc SaveTsSrcFiles {} {
	global ts_srcfiles ts_olddir evv
	set srcfnam [file join $evv(URES_DIR) tssrcs$evv(CDP_EXT)]
	set dirfnam [file join $evv(URES_DIR) tsolddir$evv(CDP_EXT)]

	set n 0
	while {$n < 4} {
		if {[info exists ts_srcfiles($n)]} {
			set line $n
			foreach fnam $ts_srcfiles($n) {
				lappend line $fnam
			}
			lappend lines $line
		}
		incr n
	}
	if {[info exists lines]} {
		if {![catch {open $srcfnam "w"} zit]} {
			foreach line $line {
				puts $zit $line
			}
			close $zit
		}
	} else {
		catch {file delete $srcfnam}
	}
	if {[info exists ts_olddir]} {
		if {![catch {open $dirfnam "w"} zit]} {
			puts $zit $ts_olddir
			close $zit
		}
	} else {
		catch {file delete $dirfnam}
	}

}

proc LoadTsSrcFiles {} {
	global ts_srcfiles ts_olddir evv
	set srcfnam [file join $evv(URES_DIR) tssrcs$evv(CDP_EXT)]
	set dirfnam [file join $evv(URES_DIR) tsolddir$evv(CDP_EXT)]
	if {[file exists $srcfnam]} {
		if [catch {open $srcfnam "r"} zit] {
			return
		}
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			set line [split $line]
			set itemcnt 0
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				switch -- $itemcnt {
					0 {
						set val $item
					}
					1 {
						if {[file exists $item]} {
							set ts_srcfiles($val) $item
						}
					}
					2 {
						if {$val == 4} {
							lappend ts_srcfiles($val) $item
						} else {
							Inf "Data in file $srcfnam corrupted"
						}
					}
					default {
						Inf "Data in file $srcfnam corrupted"
					}
				}
				incr itemcnt
			}
		}
		close $zit
	}
	if {[file exists $dirfnam]} {
		if [catch {open $dirfnam "r"} zit] {
			return
		}
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			set ts_olddir $line
			if {![file exists $ts_olddir] || ![file isdirectory $ts_olddir]} {
				unset ts_olddir
			}
		}
		close $zit
		if {![info exists ts_olddir]} {
			catch {file delete $dirfnam}
		}
	}
}

#--- Load and Save list of previous processes used by Time-series 

proc SaveTsProcess {} {
	global tsfunc tsmaxdurfunc tsrmin tsrmax tsfpar1 tsfpar2 tsfpar3 tsfpar4 tslog tsequal evv
	global tsfuncnam tsfuncstore ts_srctype tsbrkstep tscrand

	if {![info exists tsfunc] || ($tsfunc < 0)} {
		Inf "No process to save"
		return
	}
	if {![info exists ts_srctype] || ($ts_srctype < 0)} {
		Inf "Unknown source type"
		return
	}
	if {$tsfunc == 21} {
		set descrip [.ts.b.0.a.$tsfunc cget -text]
	} else {
		set descrip [.ts.b.0.$tsfunc cget -text]
	}
	set descrip [string trim $descrip]
	set descrip [split $descrip :]
	set descrip [lindex $descrip 1]
	set descrip [string trim $descrip]
	set descrip [split $descrip]
	set descrip [join $descrip "_"]

	set sav [list $descrip $ts_srctype $tsfunc]

	if {[string length $tsmaxdurfunc] <= 0} {
		Inf "No output duration set"
		return
	} else {
		lappend sav $tsmaxdurfunc
	}
	if {[.ts.b.1.rmin cget -bd]} {
		if {[string length $tsrmin] <= 0} {
			Inf "No range minimum set"
			return
		} elseif {[string length $tsrmax] <= 0} {
			Inf "No range maximum set"
			return
		} else {
			lappend	sav $tsrmin $tsrmax
		}
	} else {
		lappend	sav - -
	}
	if {[.ts.b.1.p1 cget -bd]} {
		if {[string length $tsfpar1] <= 0} {
			Inf "No fixed parameter 1 set"
			return
		} else {		
			lappend	sav $tsfpar1
		}
	} else {
		lappend	sav -
	}
	if {[.ts.b.2.p2 cget -bd]} {
		if {[string length $tsfpar2] <= 0} {
			Inf "No fixed parameter 2 set"
			return
		} else {		
			lappend	sav $tsfpar2
		}
	} else {
		lappend	sav -
	}
	if {[.ts.b.3.p3 cget -bd]} {
		if {[string length $tsfpar3] <= 0} {
			Inf "No fixed parameter 3 set"
			return
		} else {		
			lappend	sav $tsfpar3
		}
	} else {
		lappend	sav -
	}
	if {[.ts.b.4.p4 cget -bd]} {
		if {[string length $tsfpar4] <= 0} {
			Inf "No fixed parameter 4 set"
			return
		} else {		
			lappend	sav $tsfpar4
		}
	} else {
		lappend	sav -
	}
	if {$tslog} {
		lappend sav log
	} else {
		lappend	sav -
	}
	if {$tsequal} {
		lappend sav equal
	} else {
		lappend	sav -
	}
	if {[.ts.b.4.stp cget -bd]} {
		if {[string length $tsbrkstep] <= 0} {
			Inf "No brkpoint timestep set"
			return
		} else {		
			lappend	sav $tsbrkstep
		}
	} else {
		lappend	sav -
	}
	if {$tscrand} {
		lappend sav 1
	} else {
		lappend sav -
	}

	if {[info exists tsfuncstore]} {
		set ismatch 1
		foreach ff $tsfuncstore {
			foreach val [lrange $ff 1 end] nuval $sav {
				if {![string match $val $nuval]} {
					set ismatch 0
					break
				}
			}
			if {!$ismatch} {
				break
			}
		}
		if {$ismatch} {
			Inf "Process already previously saved, with name $prnam"
			return
		}
	}
	if {![info exists tsfuncnam] || ([string length $tsfuncnam] <= 0)} {
		Inf "No name entered for saved process"
		return
	}
	set tsfuncnam [string tolower $tsfuncnam]
	if {![regexp {^[a-z0-9\-\_]+$} $tsfuncnam]} {
		Inf "Invalid name entered for saved process"
		return
	} elseif {[info exists tsfuncstore]} {
		foreach ff $tsfuncstore {
			set nam [lindex $ff 0]
			if {[string match $nam $tsfuncnam]} {
				Inf "Name already used: choose a different name"
				return
			}
		}
	}
	set sav [concat $tsfuncnam $sav]
	set fnam [file join $evv(URES_DIR) tsfuncs$evv(CDP_EXT)]
	if {[file exists $fnam]} {
		if [catch {open $fnam "a"} zit] {
			Inf "Cannot open file $fnam to save process details"
			return
		}
		puts $zit $sav
		close $zit
	} else {
		if [catch {open $fnam "w"} zit] {
			Inf "Cannot open file $fnam to save process details"
			return
		}
		puts $zit $sav
		close $zit
	}
	lappend tsfuncstore $sav
	Inf "Process $tsfuncnam saved"
}

proc LoadTsProcesses {} {
	global tsfuncstore evv

	set fnam [file join $evv(URES_DIR) tsfuncs$evv(CDP_EXT)]
	if {![file exists $fnam]} {
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot open file $fnam to read previously saved time-series processes"
		return
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		set line [split $line]
		set itemcnt 0
		catch {unset ff}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			lappend ff $item
			incr itemcnt
		}
		if {$itemcnt != 15} {
			Inf "Corrupted data in file $fnam"
		} else {
			lappend tsfuncstore $ff
		}
	}
	close $zit
}

proc GetTsProcess {} {
	global tsfunc tsmaxdurfunc tsrmin tsrmax tsfpar1 tsfpar2 tsfpar3 tsfpar4 tslog tsequal evv
	global tsfuncnam tsfuncstore tsthisfunc pr_tsfuncget ts_srctype tsbrkstep tscrand wstk

	set fnam [file join $evv(URES_DIR) tsfuncs$evv(CDP_EXT)]

	if {![info exists tsfuncstore]} {
		Inf "No previous processes saved"
		return
	}
	catch {unset tsthisfunc}
	if {[string length $tsfuncnam] > 0} {
		set msg "Load process $tsfuncnam ?"
		set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			foreach ff $tsfuncstore {
				set nam [lindex $ff 0]
				if {[string match $nam [string tolower $tsfuncnam]]} {
					set tsthisfunc $ff
					break
				}
			}
			if {![info exists tsthisfunc]} {
				Inf "No function exists with this name"
			}
		}
	}
	if {![info exists tsthisfunc]} {
		if {[llength $tsfuncstore] == 1} {
			set tsthisfunc [lindex $tsfuncstore 0]
			set msg "Load process $tsfuncnam ?"
			set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				return
			}
		} else {
			set f .tsfuncget
			if [Dlg_Create $f "Get previous process" "set pr_tsfuncget 0" -borderwidth 2 -width 84] {
				frame $f.0
				button $f.0.qu -text "Abandon" -command "set pr_tsfuncget 0" -highlightbackground [option get . background {}]
				button $f.0.pp -text "Use Process" -command "set pr_tsfuncget 1" -highlightbackground [option get . background {}]
				button $f.0.dd -text "Delete" -command "set pr_tsfuncget 2" -highlightbackground [option get . background {}]
				pack $f.0.pp $f.0.dd -side left -padx 12
				pack $f.0.qu -side right
				pack  $f.0 -side top -fill x -expand true
				frame $f.1
				label $f.1.tit -text "Select a data-stretch file" -fg $evv(SPECIAL)
				Scrolled_Listbox $f.1.ll -width 48 -height 20 -selectmode single
				pack $f.1.tit $f.1.ll -side top -pady 2
				pack $f.1 -side top
				wm resizable $f 1 1
				bind $f <Return> {set pr_tsfuncget 1}
				bind $f <Escape> {set pr_tsfuncget 0}
			}
			$f.1.ll.list delete 0 end
			foreach func $tsfuncstore {
				$f.1.ll.list insert end $func
			}
			set pr_tsfuncget 0
			update idletasks
			raise $f
			update idletasks
			My_Grab 0 $f pr_tsfuncget $f
			update idletasks
			set finished 0
			while {!$finished} {
				tkwait variable pr_tsfuncget
				switch -- $pr_tsfuncget {
					1 {
						set i [$f.1.ll.list curselection]
						if {([llength $i] <= 0) || (([llength $i] == 1) && ($i < 0))} {
							Inf "No process selected"
							continue
						}
						set tsthisfunc [$f.1.ll.list get $i]
						set finished 1
					} 
					2 {
						set i [$f.1.ll.list curselection]
						if {([llength $i] <= 0) || (([llength $i] == 1) && ($i < 0))} {
							Inf "No process selected"
							continue
						}
						set delthisfunc [$f.1.ll.list get $i]
						set nam [lindex [split $delthisfunc] 0]
						set msg "Are you sure you want to delete process $nam"
						set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							continue
						}
						set tsfuncstore [lreplace $tsfuncstore $i $i]
						if {[llength $tsfuncstore] <= 0} {
							unset tsfuncstore
							catch {file delete $fnam}
						} else {
							if [catch {open $fnam "w"} zit] {
								Inf "Cannot open file $fnam to save new process details"
								$f.1.ll.list delete $i
								continue
							}
							foreach item $tsfuncstore {
								puts $zit $item
							}
							close $zit
						}
						$f.1.ll.list delete $i
					}
					0 {
						set finished 1
					}
				}
			}
			My_Release_to_Dialog $f
			Dlg_Dismiss $f
		}
	}
	if {![info exists tsthisfunc]} {
		return
	}
	set n 1
	foreach item $tsthisfunc {
		if {[string match $item "-"]} {
			switch -- $n {
				12 { set tslog   0}
				13 { set tsequal 0}
				15 { set tscrand 0}
			}
		} else {
			switch -- $n {
				1  { set tsfuncnam  $item }
				3  { set ts_srctype $item }
				4  { 
					set tsfunc	$item
					SetupTsFunc $ts_srctype
				}
				5  { set tsmaxdurfunc $item}
				6  { set tsrmin    $item }
				7  { set tsrmax    $item }
				8  { set tsfpar1   $item }
				9  { set tsfpar2   $item }
				10  { set tsfpar3   $item }
				11 { set tsfpar4   $item }
				12 { set tslog   1}
				13 { set tsequal 1}
				14 {
					if {![string match $item "-"]} {
						set tsbrkstep $item
					}
				}
				15 { set tscrand 1}
			}
		}
		incr n
	}
}

#------ Convert Time-series data files to temporary soundfiles, to view

proc GenerateViewableData {} {
	global tslist evv simple_program_messages prg_dun prg_abortd CDPidrun wstk tsview

	set tsview(base) $evv(DFLT_OUTNAME)
	append tsview(base) 001100

	Block "Converting data to viewable format"
	set n 0
	foreach fnam [$tslist get 0 end] {
		wm title .blocker "PLEASE WAIT:        Creating viewable [file rootname [file tail $fnam]]"			
		set tsview($n) $tsview(base)
		append tsview($n) $n $evv(SNDFILE_EXT)
		if {[file exists $tsview($n)]} {
			if [catch {file delete $tsview($n)} zit] {
				Inf "Cannot delete existing view to replace with view [file rootname [file tail $fnam]]"
				lappend badfiles $n
				incr n
			}
		}
		set cmd [file join $evv(CDPROGRAM_DIR) ts]
		lappend cmd oscil $fnam $tsview($n) 0
		catch {unset simple_program_messages}
		set prg_dun 0
		set prg_abortd 0
		if [catch {open "|$cmd"} CDPidrun] {
			ErrShow "Failed to create viewable for [file rootname [file tail $fnam]]"
			catch {unset CDPidrun}
			lappend badfiles $n
			incr n
			continue
		} else {
			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			set msg "Creating viewable for [file rootname [file tail $fnam]] failed"
			set msg [AddSimpleMessages $msg]
			ErrShow $msg
			if {![info exists badfiles]} {
				set msg "Continue with the file set ??"
				set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					UnBlock
					return 0
				}
			}
			lappend badfiles $n
			incr n
			continue
		}
		if {[DoParse $tsview($n) 0 0 0] <= 0} {
			Inf "Parsing viewable for [file rootname [file tail $fnam]] failed"
			lappend badfiles $n
			incr n
			continue
		}
		lappend goodfiles $n
		incr n
	}
	UnBlock
	if {![info exists goodfiles]} {
		return 0
	} elseif {[info exists badfiles]} {
		set msg "Failed to create viewables for the following data files\n"
		set cnt 0
		foreach fnam $badfiles {
			append msg "[file rootname[ file tail $fnam]]\n"
			incr cnt
			if {$cnt >= 20} {
				append msg "and more\n"
				break
			}
		}
		Inf $msg
	}
	return 1
}

#---- See a data file (display as a sound)

proc ViewTsData {} {
	global tslist tsview istsview evv
	if {!$istsview} {
		Inf "No viewable data files"
	}
	set i [$tslist curselection]
	if {([llength $i] != 1) || ($i == -1)} {
		Inf "Select a single data file"
		return
	}
	if {![info exists tsview($i)] || ![file exists $tsview($i)]} {
		Inf "No viewable file for [file rootname [file tail [$tslist get $i]]]"
		return
	}
	SnackDisplay 0 $evv(SN_FILE_PRMPAGE_NO_OUTPUT) 0 $tsview($i)
}

#---- See a data file (display as a sound)

proc PlayTsData {} {
	global tslist tsview istsview evv
	if {!$istsview} {
		Inf "No playable data files yet"
	}
	set i [$tslist curselection]
	if {([llength $i] != 1) || ($i == -1)} {
		Inf "Select a single data file"
		return
	}
	if {![info exists tsview($i)] || ![file exists $tsview($i)]} {
		Inf "No playable file for [file rootname [file tail [$tslist get $i]]]"
		return
	}
	PlaySndfile $tsview($i) 0
}

#--- See last used control file for time-series function

proc  ViewTsControl {} {
	global tsvarifunc ps_tscontrolsee
	if {![file exists $tsvarifunc(1)]} {
		Inf "No control file exists at the moment"
		return
	}
	set f .tscontrolsee
	if [Dlg_Create $f "Last control file used" "set ps_tscontrolsee 0" -borderwidth 2 -width 84] {
		frame $f.0
		button $f.0.qu -text "Quit" -command "set ps_tscontrolsee 0" -highlightbackground [option get . background {}]
		pack $f.0.qu -side right
		pack  $f.0 -side top -fill x -expand true
		frame $f.1
		Scrolled_Listbox $f.1.ll -width 48 -height 20 -selectmode single
		pack $f.1.ll -side top -pady 2
		pack $f.1 -side top
		wm resizable $f 1 1
		bind $f <Return> {set ps_tscontrolsee 0}
		bind $f <Escape> {set ps_tscontrolsee 0}
	}
	$f.1.ll.list delete 0 end
	if [catch {open $tsvarifunc(1) "r"} zit] {
		Inf "Can't open control file, to view"
		Dlg_Dismiss $f
	}
	while {[gets $zit line] >= 0} {
		$f.1.ll.list insert end $line
	}
	close $zit
	set ps_tscontrolsee 0
	update idletasks
	raise $f
	update idletasks
	My_Grab 0 $f ps_tscontrolsee $f
	update idletasks
	tkwait variable ps_tscontrolsee
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Calculate a step in (shortest) data file which will take us gradually from start to end over specified duration		
				
proc TsAutoStep {} {
	global tslist tsdurlist tsmaxdurfunc tsbrkstep tsfunc
	if {[.ts.b.4.stp cget -bd] <= 0} {
		return
	} elseif {$tsfunc == 21} {
		Inf "Not available with sequencing"
		return
	}
	set ilist [$tslist curselection]
	set len [llength $ilist]
	if {($len <= 0) || (($len == 1) && ($ilist == -1))} {
		Inf "No data file(s) selected"
		return
	}
	if {[string length $tsmaxdurfunc] <= 0} {
		Inf "No output duration entered"
		return
	}
	if {![IsNumeric $tsmaxdurfunc]} {
		Inf "Invalid output duration entered"
		return
	} elseif {($tsmaxdurfunc < 1) || ($tsmaxdurfunc > 600)} {
		Inf "Duration value out of range (1 - 600 secs)"
		return
	}
	set mindat [$tsdurlist get [lindex $ilist 0]]
	if {$len > 1} {
		foreach i [lrange $ilist 1 end] {
			set dur [$tsdurlist get $i]
			if {$dur < $mindat}	{
				set mindat $dur
			}
		}
	}
	set step [expr double($tsmaxdurfunc) / double($mindat)]
	set tsbrkstep $step
}

#---- Save output of mix from time-series

proc SaveTsMix {} {
	global tsmultiout tsoutf tsfnam evv wstk
	if {![info exists tsmultiout] || ![info exists tsoutf]} {
		Inf "No mixes to play"
		return
	}
	set typ [lindex $tsmultiout 0]
	switch -- $typ {
		"seq" -
		"multi" {
			set num [lindex $tsmultiout 1]
			set n 0
			while {$n < $num} {
				if {![file exists $tsoutf($n)]} {
					set badfiles 1
				} else {
					lappend savefiles $tsoutf($n)
				}
				incr n
			}
			if {![info exists savefiles]} {
				Inf "None of the output files still exist"
				return
			}
			if {[info exists badfiles]} {
				set msg "Not all the output files exist: continue with saving ??"
				set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					return
				}
			}
		}
		default {
			lappend savefiles $tsoutf(0)
		}
	}
	set lensavs [llength $savefiles]
	if {$lensavs > 1} {
		set msg "More than one output file: use a generic name ??"
		set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		}
	}
	if {[string length $tsfnam] <= 0} {
		Inf "No output soundfile name given"
		return
	}
	if {![ValidCDPRootname $tsfnam]} { 
		return
	}
	if {$lensavs == 1} {
		set outfnam(0) [string tolower $tsfnam]
		append outfnam(0) $evv(SNDFILE_EXT)
	} else {
		set n 0
		while {$n < $lensavs} {
			set outfnam($n) [string tolower $tsfnam]
			append outfnam($n) "_$n" $evv(SNDFILE_EXT)
			incr n
		}
	}
	set n 0
	set OK 1
	while {$n < $lensavs} {
		if {[file exists $outfnam($n)]} {
			Inf "File $outfnam($n) already exists, please choose a different name"
			set OK 0
			break
		}
		incr n
	}
	if {!$OK} {
		return
	}
	set n 0
	catch {unset badfiles}
	catch {unset goodfiles}
	foreach fnam $savefiles {
		if [catch {file rename $fnam $outfnam($n)} zit] {
			lappend badfiles $outfnam($n)
		} else {
			lappend goodfiles $outfnam($n)
		}
		incr n
	}
	set OK 1
	if {![info exists goodfiles]} {
		Inf "No files saved"
		return
	} elseif {[info exists badfiles]} {
		set msg "Some of these files have not been saved: keep the others ??"
		set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			foreach zfnam $goodfiles {
				catch {file delete $zfnam}
			}
			set OK 0
		}
	}
	if {[info exists goodfiles]} {
		set goodfiles [ReverseList $goodfiles]
		foreach fnam $goodfiles {
			FileToWkspace $fnam 0 0 0 0 1
		}
		if {[llength $goodfiles] == 1} {	
			Inf "File is on the workspace"
		} else {
			Inf "Files are on the workspace"
		}
	}
}

#--- Establish number of controls required for sequencing process

proc TSSequenceSubfuncCnt {} {
	global tssubfunc tssubfunccnt
	set tssubfunccnt [expr 1 + $tssubfunc(1) + $tssubfunc(2)]
}

#--- Generate mixfile for sequencing

proc GenerateTSSequenceMixfile {fnam} {
	global pa evv tsdata tsvarifunc tsfpar1 tsbrkstep tsmaxdurfunc tsbrkstep
	global ts_srcfiles ts_srctype tssubfunc tssrcsndchans tsseqmix tscrand
	global simple_program_messages prg_dun prg_abortd CDPidrun
	global tsgroup tsgrpperm tsgroupcnt tsgrouplen

	if {[file exists $tsseqmix]} {
		if [catch {file delete $tsseqmix} zit] {
			Inf "Cannot delete previous temporary mix file"	
			return 0
		}
	}
	if {[file exists $tsvarifunc(1)]} {
		if [catch {file delete $tsvarifunc(1)} zit] {
			Inf "Cannot delete intermediate control file"
			return 0
		}
	}
	wm title .blocker "PLEASE WAIT:            Generating sequence data"
	set len [llength $ts_srcfiles($ts_srctype)]

	if {$tssubfunc(1)} {
		set fpnam(1) [lindex $tsdata 1]		;#	Gets end of data files
		if {$tssubfunc(2)} {
			set fpnam(2) [lindex $tsdata 2]	;#	Gets first of data files
		}
	} elseif {$tssubfunc(2)} {
		set fpnam(2) [lindex $tsdata 1]		;#	Gets first of data files
	}

	;#	GENERATE NUMERIC QUANTISED DATA FROM DATA FILE PASSED IN TO FUNCTION (fnam)

	set datalen $pa([lindex $tsdata 0],$evv(ALL_WORDS)) 
	set dur [expr $tsbrkstep * double($datalen)] 
	set maxdur $tsmaxdurfunc

	set cmd [file join $evv(CDPROGRAM_DIR) tsconvert]
	lappend cmd $fnam $tsvarifunc(1) 0.501 [expr $tsfpar1 + 0.499] -d$dur -m$tsmaxdurfunc 
	if {$tscrand} {
		lappend cmd -Q		;#	no repetitions in sequence
	} else {
		lappend cmd -q		;#	repetitions allowed
	}
	catch {unset simple_program_messages}
	set prg_dun 0
	set prg_abortd 0
	if [catch {open "|$cmd"} CDPidrun] {
		ErrShow "Failed to generate sequencing data from [file rootname [file tail $fnam]]"
		catch {unset CDPidrun}
		return 0
	} else {
		fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
	}
	vwait prg_dun
	if {$prg_abortd} {
		set prg_dun 0
	}
	if {!$prg_dun} {
		set msg "Creating sequence from [file rootname [file tail $fnam]] failed"
		set msg [AddSimpleMessages $msg]
		ErrShow $msg
		return 0
	}
	if [catch {open $tsvarifunc(1) "r"} zit] {
		Inf "Cannot read control data for sequencing"
		return 0
	}

	wm title .blocker "PLEASE WAIT:        Generating timed sequence"			


	;#	IF USING GROUPS OF SOURCES, AND GROUPS ARE TO BE RAND PERMUTED, DO INITIAL PERMUTE

	if {[info exists tsgroup] && $tsgrpperm} {
		set k 0
		while {$k < $tsfpar1} { 
			SeqRandPerm $k
			incr k
		}
	}

	;#	ASSEMBLE SEQUENCE OF SOURCES AND ONSET TIMES

	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		set line [split $line]
		set itemcnt 0
		set finished 0
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			switch -- $itemcnt {
				0 {
					if {$item > $tsmaxdurfunc} {
						set finished 1
						break
					}
					lappend onsettimes $item		;#	Assemble onset times of sources
				}
				1 {
					set k [expr round($item)]
					incr k -1						;#	Sequence indexing runs from 1 to N, file indexing from 0 to (N-1)

					set kmax [expr $len - 1]		;#	Probably unness
					if {$k >= $len} {
						set k $kmax
					}								;#	Assemble sequence of sources
					if {[info exists tsgroup]} {	;#	THREE OPTIONS
						if {$tsgrpperm} {			;#	Select from specific groups of source, in group order, (which has been rand permed)
							lappend srclist [lindex $tsgroup($k) $tsgroupcnt($k)]
							incr tsgroupcnt($k)
							if {$tsgroupcnt($k) >= $tsgrouplen($k)} {
								SeqRandPerm $k		;#	once group exausted, randomly permute its order
								set tsgroupcnt($k) 0
							}
						} else {					;#	Select from specific group of sources, at random
							set j [expr int(floor(rand() * $tsgrouplen($k)))]
							lappend srclist [lindex $tsgroup($k) $j]
						}
					} else {						;#	Select specific source
						lappend srclist [lindex $ts_srcfiles($ts_srctype) $k]
					}
				}
				default {
					close $zit
					Inf "Invalid control data for sequencing (too many vals in line)"
					return 0
				}
			}
			incr itemcnt
		}
		if {$finished} {
			break
		}
		if {$itemcnt != 2} {
			close $zit
			Inf "Invalid control data for sequencing (too few vals in line)"
			return 0
		}
	}
	close $zit

	;#	IF LEVELS OR POSITION BEING CONTROLLED BY DATA, GENERATE BRKPNT FILE OF LEVELS

	if {$tssubfunc(1) || $tssubfunc(2)} {
		if {[file exists $tsvarifunc(2)]} {
			if [catch {file delete $tsvarifunc(2)} zit] {
				Inf "Cannot delete intermediate control file 2"
				return 0
			}
		}
		if [catch {open $tsvarifunc(2) "w"} zit] {
			Inf "Cannot open control file 2"
			return 0
		}
		foreach time $onsettimes {
			puts $zit $time
		}
		close $zit
	}
	if {$tssrcsndchans == 2} {
		set levlo 0.05
		set levhi 0.5			;#	Stereo mixes to mono, so halve levels
	} else {
		set levlo 0.1
		set levhi 1.0
	}

	;#	IF LEVELS BEING CONTROLLED BY DATA, GENERATE LEVELS AT ONSET TIMES

	wm title .blocker "PLEASE WAIT:        Generating sequence levels"			

	if {$tssubfunc(1)} {
		if {[file exists $tsvarifunc(1)]} {
			if [catch {file delete $tsvarifunc(1)} zit] {
				Inf "Cannot delete intermediate control file"
				return 0
			}
		}

		set cmd [file join $evv(CDPROGRAM_DIR) tsconvert]	;#	Generate timed level values, logarithmic spread
		set thisdatalen $pa($fpnam(1),$evv(ALL_WORDS)) 
		set rat [expr double($thisdatalen) / double($datalen)]
		set thisdur [expr $dur * $rat]
		lappend cmd $fpnam(1) $tsvarifunc(1) $levlo $levhi -d$thisdur -f$tsvarifunc(2) -m$tsmaxdurfunc -l

		catch {unset simple_program_messages}
		set prg_dun 0
		set prg_abortd 0
		if [catch {open "|$cmd"} CDPidrun] {
			ErrShow "Failed to generate level data from [file rootname [file tail $fpnam(1)]]"
			catch {unset CDPidrun}
			return 0
		} else {
			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			set msg "Creating levels from [file rootname [file tail $fpnam(1)]] failed"
			set msg [AddSimpleMessages $msg]
			ErrShow $msg
			return 0
		}
		if {![file exists $tsvarifunc(1)]} {
			Inf  "No level values obtained from [file rootname [file tail $fpnam(1)]]"
			return 0
		} 
		if [catch {open $tsvarifunc(1) "r"} zit] {
			Inf "Cannot open control file to read levels"
			return 0
		}
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			lappend levlist $line
		}
		close $zit
	} else {

		;#	ELSE SET FIXED LEVELS

		set n 0
		set len [llength $srclist]
		while {$n < $len} {
			lappend levlist $levhi
			incr n
		}
	}

	wm title .blocker "PLEASE WAIT:        Generating spatial data"			

	;#	IF POSITIONS BEING CONTROLLED BY DATA, GENERATE POSITIONS AT ONSET TIMES

	if {$tssubfunc(2)} {
		if {[file exists $tsvarifunc(1)]} {
			if [catch {file delete $tsvarifunc(1)} zit] {
				Inf "Cannot delete intermediate control file"
				return 0
			}
		}
		set cmd [file join $evv(CDPROGRAM_DIR) tsconvert]	;#	Generate brkpnt of timed position values
		set thisdatalen $pa($fpnam(2),$evv(ALL_WORDS)) 
		set rat [expr double($thisdatalen) / double($datalen)]
		set thisdur [expr $dur * $rat]
		lappend cmd $fpnam(2) $tsvarifunc(1) -1 1 -d$thisdur -f$tsvarifunc(2) -m$tsmaxdurfunc

		catch {unset simple_program_messages}
		set prg_dun 0
		set prg_abortd 0
		if [catch {open "|$cmd"} CDPidrun] {
			ErrShow "Failed to generate position data from [file rootname [file tail $fpnam(2)]]"
			catch {unset CDPidrun}
			return 0
		} else {
			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			set msg "Creating position values from [file rootname [file tail $fpnam(2)]] failed"
			set msg [AddSimpleMessages $msg]
			ErrShow $msg
			return 0
		}
		if {![file exists $tsvarifunc(1)]} {
			Inf  "No position values obtained from [file rootname [file tail $fpnam(2)]]"
			return 0
		} 
		if [catch {open $tsvarifunc(1) "r"} zit] {
			Inf "Cannot open control file 1 to read spatial positions"
			return 0
		}
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			lappend poslist $line
		}
		close $zit
	} else {

		;#	ELSE SET FIXED POSITION

		set n 0
		set len [llength $srclist]
		while {$n < $len} {
			lappend poslist 0
			incr n
		}
	}

	wm title .blocker "PLEASE WAIT:        Creating sequence mixfile"			

	if [catch {open $tsseqmix "w"} zit] {
		Inf "Cannot open mix file to write sequence data"
		return 0
	}
	if {$tssrcsndchans == 2} {
		foreach src $srclist time $onsettimes lev $levlist pos $poslist {
			set line [list $src $time $tssrcsndchans $lev $pos $lev $pos]
			puts $zit $line
		}
	} else {
		foreach src $srclist time $onsettimes lev $levlist pos $poslist {
			set line [list $src $time $tssrcsndchans $lev $pos]
			puts $zit $line
		}
	}
	close $zit
	return 1
}

#---- Check files in a sndlisting file to use as srcs for sequence (21)

proc TsExtractFilesFromList {listfil cnt manylists n} {
	global pa evv ts_srclist wstk wl ts_sndslist tsgroup tsgroupchans tsgrouplen tsgroupcnt

	;#	ts_srclist is a scrolled_listbox
	;#	ts_sndslist is list of snds on that scrolled_listbox
	;#	ts_slistlist is a list of sndfile_listings_in_textfiles on that scrolled_listbox

	if [catch {open $listfil "r"} zit] {
		Inf "Cannot open sound-listing file [file tail $listfil]"
		return {}
	}

	;#	GET SOUNDS LISTED IN SND-LISTING FILE

	set incnt 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		set fnam $line
		if {![file exists $fnam]} {
			Inf "File $fnam no longer exists"
			catch {close $zit}
			return {}
		}
		lappend fnams $fnam
		set i [LstIndx $fnam $wl]
		if {$i < 0} {
			lappend badfiles $fnam
		}
		incr incnt
	}
	close $zit

	;#	CHECK FOR CORRECT NUMBER OF FILES

	if {!$manylists} {
		if {$incnt != $cnt} {
			Inf "Wrong number of soundfiles in [file tail $listfil]"
			return {}
		}
	}

	;#	ATTEMPT TO GRAB ANY FILES NOT ON WORKSPACE

	if {[info exists badfiles]} {
		set msg "Some of these files are no longer on the workspace: grab them ?"
		set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return {}
		}
		foreach fnam $badfiles {
			if {[FileToWkspace $fnam 0 0 0 0 1] <= 0} {
				Inf "Cannot grab $fnam (in [file tail $listfil]) to the workspace"
				return {}
			}
		}
	}
	;#	CHECK CHANNEL COUNT AND MUTUAL COMPATIBILITY, COPY VIABLE SOUNDS TO ts_sndslist

	set badchans(1) 0
	set badchans(2) 0
	set doreturn 0
	set chans $pa([lindex $fnams 0],$evv(CHANS)) 
	if {$n == 0} {
		set tsgroupchans $chans
	} elseif {$chans != $tsgroupchans} {
		Inf "Files in listing [file tail $listfil] have different channel-cnt to previous listings"
		return {}
	}
	foreach fnam $fnams {
		if {$pa($fnam,$evv(CHANS)) > 2} {	;#	Reject files with too many chans
			set badchans(1) 1				;#	and force return
			set doreturn 1
		} elseif {$pa($fnam,$evv(CHANS)) != $chans} {
			set badchans(2) 1
			set doreturn 1					;#	Force return if files have incompatible chan-counts
			lappend ts_sndslist $fnam		;#	but add files to src sounds listing
		} else {										
			lappend ts_sndslist $fnam
		}
	}
	;#	RECONFIGURE SOURCES LISTING TO SHOW (THE REVISED) LIST OF SOUNDS

	.tsfsrcs.1.tit config -text "Sound Files"
	.tsfsrcs.1.tit2 config -text ""
	.tsfsrcs.0.slis config -text "Show Sndlist files"
	.tsfsrcs.0.rand config -text "" -state disabled
	.tsfsrcs.0.perm config -text "" -state disabled
	$ts_srclist delete 0 end
	foreach fnam $ts_sndslist {
		$ts_srclist insert end $fnam
	}
	if {$doreturn} {
		set msg ""
		if {$badchans(1)} {
			append msg "some files in listing-file (in [file tail $listfil]) have more than 2 channels\n\n"
		} 
		if {$badchans(2)} {
			append msg "not all files in listing-file (in [file tail $listfil]) have same number of channels"
		}
		Inf $msg
		return {}
	} 
	if {$manylists} {
		set tsgroup($n) $fnams
		set tsgrouplen($n) [llength $fnams]
		set tsgroupcnt($n) 0
	}
	set i 0
	foreach fnam $fnams {
		set i [LstIndx $fnam $ts_srclist]
		lappend ilist $i
	}
	return $ilist
}

#---- Randomly permute order of group of snd-sources

proc SeqRandPerm {k} {
	global tsgrouplen tsgroup
	set permlen $tsgrouplen($k)
	set seqperm {}
	set n 0
	set n_plus_1 1
	set endindex -1
	while {$n < $permlen} {
		set t [expr int(floor(rand() * $n_plus_1))]
		if {$t==$n} {
			set q [concat $n $seqperm]
			set seqperm $q
		} else {
			incr t
			if {$t > $endindex} {
				lappend seqperm $n
			} else {
				set seqperm [linsert $seqperm $t $n]
			}
		}
		incr n
		incr n_plus_1
		incr endindex
	}
	foreach n $seqperm {
		lappend nugroup [lindex $tsgroup($k) $n]
	}
	set tsgroup($k) $nugroup
}

####################################################################
# DERIVING AND COMPARING AVERAGE SPECTRUM (for Formant comparison) #
####################################################################


proc SpecAverageMaster {} {
	global chlist evv pa wstk specavframetime specav_nyquist specavvmaxwin specavvwinwid specavvwinfoot specdata
	global specavvendwin specavvsttwin specavlo specavhi specavfilecnt

	set helpmsg "Files needed on the chosen files list could be\n"
	append helpmsg "\n"
	append helpmsg "ONE OR MORE ANALYSIS FILES\n"
	append helpmsg "\n"
	append helpmsg "When the (single) average spectrum\n"
	append helpmsg "will be extracted, and displayed\n"
	append helpmsg "and can be saved as a textfile.\n"
	append helpmsg "\n"
	append helpmsg "ONE ANALYSIS FILE\n"
	append helpmsg "\n"
	append helpmsg "When the individual windows,\n"
	append helpmsg "or (averaged) window-groups of a specified size,\n"
	append helpmsg "will be extracted as textfiles.\n"
	append helpmsg "\n"
	append helpmsg "SPECTRAL-DATA (TEXT) FILES (from above)\n"
	append helpmsg "\n"
	append helpmsg "When the spectra will be displayed, for comparison.\n"
	append helpmsg "(Movie display is possible).\n"
	append helpmsg "\n"
	append helpmsg "ONE MONO SOUNDFILE\n"
	append helpmsg "\n"
	append helpmsg "When spectrum (or other time-windowed data)\n"
	append helpmsg "will be extracted as a series of textfiles\n"
	append helpmsg "for (possible movie) display.\n"
	append helpmsg "\n"
	append helpmsg "Options include FFT magnitudes, Log FFT etc.\n"
	append helpmsg "\n"
	if {![info exists chlist] || ([llength $chlist] == 0)} {
		Inf $helpmsg
		return
	}
	set cnt 0
	set isanal 0
	set issnd 0
	Block "Checking Input Files"
	set ftyp $pa([lindex $chlist 0],$evv(FTYP))
	if {$ftyp == $evv(SNDFILE)} {
		if {($pa([lindex $chlist 0],$evv(CHANS)) == 1) && ([llength $chlist] == 1)} {
			set issnd 1
		}
	} elseif {$ftyp == $evv(ANALFILE)} {
		set isanal 1
	} elseif {[IsABrkfile $ftyp]} {
		;
	} elseif {[IsAListofNumbers $ftyp] && [IsEven $pa([lindex $chlist 0],$evv(NUMSIZE))]} {  ;# Frq vals can be out of ascending-order
		;
	} else {
		set msg "Input file not of correct type\n\n"
		append msg $helpmsg
		Inf $msg
		UnBlock
		return
	}
	if {$issnd} {
		UnBlock
		WavSpecDisplay	
		return
	}
	if {$isanal} {
		set fnam [lindex $chlist 0]
		set specavframetime $pa($fnam,$evv(FRAMETIME))
		set specav_nyquist	$pa($fnam,$evv(NYQUIST))
		set specavvmaxwin [expr ($pa($fnam,$evv(CHANS))/2) - 1]
		set specavvwinwid [expr double($specav_nyquist) /double($specavvmaxwin)]
		set specavvwinfoot [expr -($specavvwinwid/2.0)]
		set mode 1
		if {[llength $chlist] > 1} {
			set mode 2
			set fnam [lindex $chlist 0]
			set srate		$pa($fnam,$evv(SRATE))
			set chans		$pa($fnam,$evv(CHANS))
			set wanted		$pa($fnam,$evv(WANTED))
			set arate		$pa($fnam,$evv(ARATE))
			set stype		$pa($fnam,$evv(STYPE))
			set origstype	$pa($fnam,$evv(ORIGSTYPE))
			set origrate	$pa($fnam,$evv(ORIGRATE))
			set mlen		$pa($fnam,$evv(MLEN))
			set dfac		$pa($fnam,$evv(DFAC))
			set origchans	$pa($fnam,$evv(ORIGCHANS))
			set bum 0
			foreach fnam [lrange $chlist 1 end] {
				if {$srate		!= $pa($fnam,$evv(SRATE))} {
					set bum 1
					break
				}
				if {$chans		!= $pa($fnam,$evv(CHANS))} {
					set bum 1
					break
				}
				if {$wanted		!= $pa($fnam,$evv(WANTED))} {
					set bum 1
					break
				}
				if {$arate		!= $pa($fnam,$evv(ARATE))} {
					set bum 1
					break
				}
				if {$specavframetime != $pa($fnam,$evv(FRAMETIME))} {
					set bum 1
					break
				}
				if {$specav_nyquist	!= $pa($fnam,$evv(NYQUIST))} {
					set bum 1
					break
				}
				if {$stype		!= $pa($fnam,$evv(STYPE))} {
					set bum 1
					break
				}
				if {$origstype	!= $pa($fnam,$evv(ORIGSTYPE))} {
					set bum 1
					break
				}
				if {$origrate	!= $pa($fnam,$evv(ORIGRATE))} {
					set bum 1
					break
				}
				if {$mlen		!= $pa($fnam,$evv(MLEN))} {
					set bum 1
					break
				}
				if {$dfac		!= $pa($fnam,$evv(DFAC))} {
					set bum 1
					break
				}
				if {$origchans	!= $pa($fnam,$evv(ORIGCHANS))} {
					set bum 1
					break
				}
			}
			if {$bum} {
				Inf "Chosen analysis files do not have same properties"
				UnBlock
				return
			}
		} else {
			set msg "YOU CAN\n\n"
			append msg "\n"
			append msg "(1) Extract the average spectrum\n"
			append msg "\n"
			append msg "and display it.\n"
			append msg "\n"
			append msg "~~OR~~\n"
			append msg "\n"
			append msg "(2) Extract every analysis window\n"
			append msg "  or several (averaged) groups of analysis windows\n"
			append msg "\n"
			append msg "and use the output textfiles to view the moving spectrum.\n"
			append msg "\n"
			append msg "\n"
			append msg "Extract the average spectrum (option 1) only ??\n"
			set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				set is_all_anal 1
			}
		}
	} else {
		foreach fnam $chlist {
			if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
				Inf "Not all chosen files are of same type"
				UnBlock
				return
			}
		}
		if {[llength $chlist] > 16} {
			set msg "Movies can be run with this number of files\n\n"
			append msg "Max number of files for individual comparison = 16"
			Inf $msg
		}
		catch {unset specdata}
		set specavfilecnt 0
		foreach fnam $chlist {
			if [catch {open $fnam "r"} zit] {
				Inf "Cannot open file $fnam"
				UnBlock
				return
			}
			while {[gets $zit line] >= 0} {
				set line [string trim $line]
				if {[string length $line] <= 0} {
					continue
				}
				set line [split $line]
				set itemcnt 0
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] <= 0} {
						continue
					}
					switch -- $itemcnt {
						0 -
						1 {
							lappend specdata($specavfilecnt) $item
							incr itemcnt
						}
						default {
							incr itemcnt
							break
						}
					}
				}
				if {$itemcnt != 2} {
					Inf "Corrupted data in spectral data file $fnam"
					close $zit
					UnBlock
					return
				}
			}
			close $zit
			incr specavfilecnt
		}
		set len [llength $specdata(0)]
		incr len -2
		set specav_nyquist [lindex $specdata(0) $len]
		set specav_nyquist [NyquistAdjust $specav_nyquist]
		set n 0
		while {$n < $specavfilecnt} {
			set thislen [llength $specdata($n)]
			incr thislen -2
			set maxfrq [NyquistAdjust [lindex $specdata($n) $thislen]]
			if {$thislen != $len} {
				Inf "File $fnam has different number of analysis channels to other selected files"
				UnBlock
				return
			}
			if {![Flteq $specav_nyquist $maxfrq]} {
				Inf "File [lindex $chlist $n] has different freq range (nyquist probably at $maxfrq) to other selected files (nyquist $specav_nyquist)"
				UnBlock
				return
			}
			incr n
		}
		set specavvmaxwin [expr ([llength $specdata(0)]/2) - 1]
		set specavvendwin $specavvmaxwin
		set specavvsttwin 0
		set specavvwinwid [expr double($specav_nyquist) /double($specavvmaxwin)]
		set specavvwinfoot [expr -($specavvwinwid/2.0)]
		set specavlo 0.0
		set specavhi $specav_nyquist
	}
	UnBlock
	if {$isanal} {
		if {[info exists is_all_anal]} {
			SpecAllExtract
		} else {
			SpecAverageDisplay
		}
	} else {
		SpecAverageCompare
	}
}

# ----- DERIVING AVERAGE SPECTRUM

proc SpecAverageDisplay {} {
	global wl chlist pa evv pr_specav readonlyfg  readonlybg specavstt specavend specavframetime specavnorm
	global specavsttframe specavendframe specavmaxframe specavsetstt specavsetend specavnam
	global simple_program_messages prg_dun prg_abortd CDPidrun wstk rememd bav bkc specavlo specavhi specavgot
	global specavvmaxwin specavvsttwin specavvendwin specav_nyquist specavvwinwid specavvwinfoot specdata
	global specavdefrr specavinnam

	set specfile $evv(DFLT_OUTNAME)
	append specfile $evv(ANALFILE_EXT)
	if {[file exists $specfile]} {
		if [catch {file delete $specfile} zit] {
			Inf "Cannot delete existing temporary file $specfile"
			return
		}
	}
	set fnam [lindex $chlist 0]
	set mindur $pa($fnam,$evv(DUR))
	set mode 1
	if {[llength $chlist] > 1} {
		set mode 2
		foreach fnam [lrange $chlist 1 end] {
			if {$mindur	> $pa($fnam,$evv(DUR))} {
				set mindur $pa($fnam,$evv(DUR))
			}
		}
	}
	set f .specav
	if [Dlg_Create $f "Display average spectrum" "set pr_specav 0" -borderwidth 2 -width 84] {
		frame $f.0
		button $f.0.qu -text "Abandon" -command "set pr_specav 0" -highlightbackground [option get . background {}]
		button $f.0.dd -text "Get spectrum" -command "set pr_specav 1" -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $f.0.vv -text "See Spectrum" -command "set pr_specav 2" -bg $evv(SNCOLOR) -highlightbackground [option get . background {}]
		label $f.0.from -text "from"
		entry $f.0.lo -textvariable specavlo -width 7 -fg $readonlyfg -readonlybackground $readonlybg -state readonly
		label $f.0.to -text "to"
		entry $f.0.hi -textvariable specavhi -width 7 -fg $readonlyfg -readonlybackground $readonlybg -state readonly
		label $f.0.ll -text "Dflt range" -width 12
		radiobutton $f.0.defset -text "Set as" -variable specavdefrr -value 1 -command "SaveSpecavDflt" -width 7
		radiobutton $f.0.defget -text "Get" -variable specavdefrr -value 2 -command "SetSpecavDflt" -width 4
		button $f.0.ss -text "Save Spectrum & Quit" -command "set pr_specav 3" -highlightbackground [option get . background {}]
		pack $f.0.dd $f.0.vv $f.0.ss -side left -padx 12
		pack $f.0.from $f.0.lo $f.0.to $f.0.hi $f.0.ll $f.0.defget $f.0.defset -side left -padx 2
		pack $f.0.qu -side right -padx 2
		pack  $f.0 -side top -fill x -expand true
		label $f.00 -text "NB: Highest-frq peak displayed should be at low level relative to others for peak envelope to be drawn correctly" -fg $evv(SPECIAL)
		pack $f.00 -side top -pady 2
		frame $f.1
		entry $f.1.start -textvariable specavstt -width 12 -fg $readonlyfg -readonlybackground $readonlybg -state readonly
		label $f.1.ll -text "Start time" -width 12 
		radiobutton $f.1.r -text "to Start of snd" -width 14 -variable specavsetstt -value 0 -command {ResetSpecav start}
		pack $f.1.start $f.1.ll $f.1.r -side left
		pack $f.1 -side top -pady 2
		frame $f.2
		entry $f.2.end -textvariable specavend -width 12 -fg $readonlyfg -readonlybackground $readonlybg -state readonly
		label $f.2.ll -text "End time"  -width 12
		radiobutton $f.2.r -text "to End of snd" -width 14 -variable specavsetend -value 0 -command {ResetSpecav end}
		pack $f.2.end $f.2.ll $f.2.r -side left
		pack $f.2 -side top -pady 2
		frame $f.3
		label $f.3.ll -text "Starttime set with UP/DOWN arrows  :  Endtime set with RIGHT/LEFT arrows" -fg $evv(SPECIAL)
		pack $f.3.ll -side left -fill x -expand true
		pack $f.3 -side top -pady 2
		frame $f.4
		checkbutton $f.4.n -variable specavnorm -text "Normalise display" -width 20
		pack $f.4.n -side left -fill x -expand true
		pack $f.4 -side top -pady 2
		set specavnorm 1
		frame $f.5
		entry $f.5.nam -textvariable specavnam -width 24 
		label $f.5.ll -text "Output spectral file name"
		radiobutton $f.5.ch -variable specavinnam -text "Use input file name" -value 0 -command {SetSpecAvOutNameAsSrcName} 
		pack $f.5.ll $f.5.nam $f.5.ch -side left -padx 2
		pack $f.5 -side top -pady 2
		set bav(can) [canvas $f.6 -height $bkc(height) -width $bkc(width) -borderwidth 0 \
			-highlightthickness 1 -highlightbackground $evv(SPECIAL) -background white]
		pack $f.6 -side top -fill both
		wm resizable $f 1 1
		bind $f <Up>	{SpecAvTimeChange 0 0}
		bind $f <Down>	{SpecAvTimeChange 0 1}
		bind $f <Right> {SpecAvTimeChange 1 0}
		bind $f <Left>	{SpecAvTimeChange 1 1}
		bind $f <Return> {set pr_specav 1}
		bind $f <Escape> {set pr_specav 0}
	}
	set specavgot 0
	.specav.0.vv config -text "" -bd 0 -bg [option get . background {}] -command {}
	.specav.0.from config -text ""
	.specav.0.lo config  -bd 0 -state disabled -disabledbackground [option get . background {}] 
	.specav.0.to config -text ""
	.specav.0.hi config  -bd 0 -state disabled -disabledbackground [option get . background {}]
	.specav.0.ss config -text "" -command {} -bd 0 -bg [option get . background {}]
	.specav.5.nam config -bd 0 -state disabled -disabledbackground [option get . background {}]
	.specav.5.ll config -text ""
	.specav.5.ch config -text "" -state disabled -command {}
	.specav.0.dd config -bg $evv(EMPH)
	set specavinnam ""
	.specav.3.ll config -text "STARTTIME set with UP/DOWN arrows  :  ENDTIME set with RIGHT/LEFT arrows" -fg $evv(SPECIAL)
	.specav.0.ll config -text "" 
	.specav.0.defset config -text "" -command {}
	.specav.0.defget config -text "" -command {}
	bind $f <Return> {}
	bind $f <Return> {set pr_specav 1}
	set specavlo ""
	set specavhi ""
	set specavnam ""
	set specavdefrr 0
	catch {$bav(can) delete specavline} in
	set specavstt [DecPlaces $specavframetime 6]
	set specavend [DecPlaces $mindur 6]
	set specavsttframe 1
	set specavendframe [expr int(round($mindur/$specavframetime)) - 1]
	set specavmaxframe $specavendframe 
	catch {$bav(can) delete specavline} in
	set pr_specav 0
	update idletasks
	raise $f
	My_Grab 0 $f pr_specav $f
	update idletasks
	set finished 0
	while {!$finished} {
		tkwait variable pr_specav
		switch -- $pr_specav {
			1 {
				set specavgot 0
				.specav.0.dd config -bg $evv(EMPH)
				.specav.0.vv config -text "" -bd 0 -bg [option get . background {}] -command {}
				.specav.0.from config -text ""
				.specav.0.lo config  -bd 0 -state disabled -disabledbackground [option get . background {}] 
				.specav.0.to config -text ""
				.specav.0.hi config  -bd 0 -state disabled -disabledbackground [option get . background {}]
				.specav.0.ss config -text "" -command {} -bd 0 -bg [option get . background {}]
				.specav.5.nam config -bd 0 -state disabled -disabledbackground [option get . background {}]
				.specav.5.ll config -text ""
				.specav.5.ch config -text "" -state disabled -command {}
				.specav.3.ll config -text "STARTTIME set with UP/DOWN arrows  :  ENDTIME set with RIGHT/LEFT arrows" -fg $evv(SPECIAL)
				.specav.0.ll config -text "" 
				.specav.0.defset config -text "" -command {}
				.specav.0.defget config -text "" -command {}
				catch {$bav(can) delete specavline} in
				bind $f <Return> {}
				bind $f <Return> {set pr_specav 1}
				set specavnam ""
				set specavlo ""
				set specavhi ""
				if {([string length $specavstt] <= 0)} {
					Inf "No start time given"
					continue
				}
				if {([string length $specavend] <= 0)} {
					Inf "No end time given"
					continue
				}
				set cmd [file join $evv(CDPROGRAM_DIR) specav]
				lappend cmd specav $mode
				foreach fnam $chlist {
					lappend cmd $fnam
				}
				lappend cmd $specfile $specavstt $specavend
				if {$specavnorm == 1} {
					lappend cmd "-n"
				}
				Block "Generating Spectrum"
				catch {unset simple_program_messages}
				set prg_dun 0
				set prg_abortd 0
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "Failed to generate spectral data"
					catch {unset CDPidrun}
					UnBlock
					break
				} else {
					fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				if {!$prg_dun} {
					Inf "Creating spectral data failed"
					UnBlock
					break
				}
				if {![file exists $specfile]} {
					set msg "No output file generated"
					UnBlock
					break
				}
				UnBlock
				.specav.0.dd config -bg [option get . background {}]
				.specav.0.vv config -text "See Spectrum" -bd 2 -bg $evv(SNCOLOR) -command "set pr_specav 2"
				.specav.0.from config -text "from"
				.specav.0.lo config  -bd 2 -state normal 
				.specav.0.to config -text "to"
				.specav.0.hi config  -bd 2 -state normal
				.specav.0.ss config -text "Save Spectrum & Quit" -command "set pr_specav 3" -bd 2 -bg $evv(EMPH)
				.specav.5.nam config -bd 2 -state normal
				.specav.5.ll config -text "Output spectral file name"
				.specav.5.ch config -text "" -state normal  -text "Use input file name" -command {SetSpecAvOutNameAsSrcName}
				.specav.3.ll config -text "set START FRQ with UP/DOWN arrows  :  set END FRQ with RIGHT/LEFT arrows" -fg $evv(SPECIAL)
				.specav.0.ll config -text "Dflt range" 
				.specav.0.defset config -text "Set as" -command "SaveSpecavDflt"
				.specav.0.defget config -text "Get" -command "SetSpecavDflt"
				bind $f <Return> {}
				bind $f <Return> {set pr_specav 2}
				set specavlo 0
				set specavhi [DecPlaces $specav_nyquist 0]
				set specavvsttwin 0
				set specavvendwin $specavvmaxwin
				set specavgot 1
				if {[llength $chlist] == 1} {
					set specavnam [file rootname [file tail [lindex $chlist 0]]]
				}
				Inf "Generated spectrum"
			}
			2 {	;#	SEE
				catch {$bav(can) delete specavline} in
				if {![file exists $specfile]} {
					Inf "The spectral data does not exist"
					set specavgot 0
					.specav.0.dd config -bg $evv(EMPH)
					.specav.0.vv config -text "" -bd 0 -bg [option get . background {}] -command {}
					.specav.0.from config -text ""
					.specav.0.lo config  -bd 0 -state disabled -disabledbackground [option get . background {}] 
					.specav.0.to config -text ""
					.specav.0.hi config  -bd 0 -state disabled -disabledbackground [option get . background {}]
					.specav.0.ss config -text "" -command {} -bd 0 -bg [option get . background {}]
					.specav.5.nam config -bd 0 -state disabled -disabledbackground [option get . background {}]
					.specav.5.ll config -text ""
					.specav.5.ch config -text "" -state disabled -command {}
					.specav.3.ll config -text "STARTTIME set with UP/DOWN arrows  :  ENDTIME set with RIGHT/LEFT arrows" -fg $evv(SPECIAL)
					.specav.0.ll config -text "" 
					.specav.0.defset config -text "" -command {}
					.specav.0.defget config -text "" -command {}
					bind $f <Return> {}
					bind $f <Return> {set pr_specav 1}
					set specavlo ""
					set specavhi ""
					set specavnam ""
					continue
				}
				if [catch {open $specfile "r"} zit] {
					Inf "Cannot open the spectral datafile"
					continue
				}
				catch {unset specdata(0)}
				set OK 1
				while {[gets $zit line] >= 0} {
					set line [string trim $line]
					if {[string length $line] <= 0} {
						continue
					}
					set line [split $line]
					set itemcnt 0
					foreach item $line {
						set item [string trim $item]
						if {[string length $item] <= 0} {
							continue
						}
						switch -- $itemcnt {
							0 -
							1 {
								lappend specdata(0) $item
								incr itemcnt
							}
							default {
								incr itemcnt
								break
							}
						}
					}
					if {$itemcnt != 2} {
						Inf "Corrupted data in spectral file"
						close $zit
						catch [file delete $specfile]
						set specavgot 0
						.specav.0.dd config -bg $evv(EMPH)
						.specav.0.vv config -text "" -bd 0 -bg [option get . background {}] -command {}
						.specav.0.from config -text ""
						.specav.0.lo config  -bd 0 -state disabled -disabledbackground [option get . background {}] 
						.specav.0.to config -text ""
						.specav.0.hi config  -bd 0 -state disabled -disabledbackground [option get . background {}]
						.specav.0.ss config -text "" -command {} -bd 0 -bg [option get . background {}]
						.specav.5.nam config -bd 0 -state disabled -disabledbackground [option get . background {}]
						.specav.5.ll config -text ""
						.specav.5.ch config -text "" -state disabled -command {}
						.specav.3.ll config -text "STARTTIME set with UP/DOWN arrows  :  ENDTIME set with RIGHT/LEFT arrows" -fg $evv(SPECIAL)
						.specav.0.ll config -text "" 
						.specav.0.defset config -text "" -command {}
						.specav.0.defget config -text "" -command {}
						bind $f <Return> {}
						bind $f <Return> {set pr_specav 1}
						set specavlo ""
						set specavhi ""
						set specavnam ""
						set OK 0
						break
					}
				}
				close $zit
				if {!$OK} {
					continue
				}
				set specavrange [expr $specavvendwin - $specavvsttwin + 3]
				set specavstep [expr double($bkc(width))/double($specavrange)]
				set thisstep 1
				set ya $bkc(height)
				catch {unset specavmaxima}
				catch {unset specavpks}
				foreach {frq amp} $specdata(0) {
					if {$frq < $specavlo} {
						continue
					} elseif {$frq > $specavhi} {
						break
					}
					set x [expr $thisstep * $specavstep]
					set yb [expr (1.0 - $amp) * $bkc(height)]
					set line_specav [list $x $ya $x $yb]
					eval {$bav(can) create line} $line_specav {-fill black} {-tag specavline}
					if {$thisstep == 1} {
						;
					} elseif {$thisstep == 2} {
						if {$amp > $lastamp} {
							set ampmax $amp
							set ismax 1
						} else {
							lappend specavmaxima $lastx $lastyb
							lappend specavpks $lastamp
							set ampmin $amp
							set ismax 0
						}
					} else {
						if {$ismax} {
							if {$amp >= $ampmax} {
								set ampmax $amp
							} else {
								lappend specavmaxima $lastx $lastyb
								lappend specavpks $lastamp
								set ismax 0
								set ampmin $amp
							}
						} else {
							if {$amp <= $ampmin} {
								set ampmin $amp
							} else {
								set ismax 1
								set ampmax $amp
							}
						}
					}
					set lastamp $amp
					set lastx $x
					set lastyb $yb
					incr thisstep
				}
				set lastpk [lindex $specavpks end]
				set lastpk [expr $lastpk/3.0]
				set n [llength $specavpks]
				incr n -2
				set j [expr $n * 2]		;#	DELETE ALL PEAKS WHICH FALL BELOW LEVEL OF THIRD OF FINAL PEAK
				set k [expr $j + 1]
				while {$n >= 0} {
					if {[lindex $specavpks $n] < $lastpk} {
						set specavmaxima [lreplace $specavmaxima $j $k]
					}
					incr n -1
					incr j -2
					incr k -2
				}
				if {[info exists specavmaxima] && ([llength $specavmaxima] > 2)} {
					eval {$bav(can) create line} $specavmaxima {-fill red} {-tag specavline}
				}
			}
			3 {	;# SAVE & QUIT
				if {[string length $specavnam] <= 0} {
					Inf "No output filename entered"
					continue
				}
				set outnam [string tolower $specavnam]
				if {![ValidCDPRootname $outnam]} { 
					continue
				}
				append outnam $evv(TEXT_EXT)
				if [file exists $outnam] {
					set msg "File $outnam already exists: overwrite it ??"
					set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
					if {[DeleteFileFromSystem $outnam 1 1]} {
						if {[IsInAMixfile $outnam]} {
							MixM_ManagedDeletion $outnam
							MixMStore
						}
						set i [LstIndx $outnam $wl]	;#	remove from workspace listing, if there
						if {$i >= 0} {
							$wl delete $i
							WkspCnt $outnam -1
							catch {unset rememd}
						}
					} else {
						Inf "Cannot delete file $outnam : choose a different name"
						continue
					}
				}
				if [catch {file rename $specfile $outnam} zit] {
					Inf "Cannot rename the output file"
					continue
				}
				if {[FileToWkspace $outnam 0 0 0 0 1] <= 0} {
					continue
				}
				Inf "File $outnam is on the workspace"
				set finished 1
			}
			0 {
				set finished 1
			}
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Display several averaged spectra in the same window,so they can be compared

proc SpecAverageCompare {} {
	global wl chlist pa evv pr_specavc readonlyfg  readonlybg specavstt specavend specavframetime specavnorm
	global specavsttframe specavendframe specavmaxframe specavsetstt specavsetend specavnam
	global simple_program_messages prg_dun prg_abortd CDPidrun wstk rememd bav bkc specavlo specavhi specavgot
	global specavvmaxwin specavvsttwin specavvendwin specav_nyquist specavvwinwid specavvwinfoot
	global specavdefrr specavmultdisp specavdisp bavlist brrkcolor specavdisplist specavfilecnt specdata
	global spekframedur sar specavmaxgraphs specavlim spkmax specavform specavformchans specavxact lastspecavxact

	set specavform 0
	set specavxact 0
	set lastspecavxact -1
	catch {unset specavformchans}
	set k 0
	set evv(DATACOLORS) 16
	set evv(MAXGRAPHS)  256
	set specavmaxgraphs 16
	while {$k < $evv(DATACOLORS)} {
		switch -- $k {
			0  { set brrkcolor($k) black }
			1  { set brrkcolor($k) firebrick3 }
			2  { set brrkcolor($k) firebrick1 }			
			3  { set brrkcolor($k) DeepPink1 }			
			4  { set brrkcolor($k) magenta1 }			
			5  { set brrkcolor($k) MediumOrchid }			
			6  { set brrkcolor($k) DarkBlue }			
			7  { set brrkcolor($k) DeepSkyBlue3 }			
			8  { set brrkcolor($k) DeepSkyBlue1 }			
			9  { set brrkcolor($k) aquamarine3 }			
			10 { set brrkcolor($k) SeaGreen2 }			
			11 { set brrkcolor($k) chartreuse }			
			12 { set brrkcolor($k) yellow3 }			
			13 { set brrkcolor($k) gold3 }			
			14 { set brrkcolor($k) burlywood3 }			
			15 { set brrkcolor($k) tan4 }			
		}
		incr k
	}
	set f .specavc
	if [Dlg_Create $f "Compare spectra" "set pr_specavc 0" -borderwidth 2 -width 84] {
		frame $f.0
		button $f.0.qu -text "Abandon" -command "set pr_specavc 0" -highlightbackground [option get . background {}]
		button $f.0.vv -text "Clear Display" -command "set pr_specavc 1" -bg $evv(SNCOLOR) -highlightbackground [option get . background {}]
		label $f.0.from -text "Display Spectrum from"
		entry $f.0.lo -textvariable specavlo -width 7 -fg $readonlyfg -readonlybackground $readonlybg -state readonly
		label $f.0.to -text "to"
		entry $f.0.hi -textvariable specavhi -width 7 -fg $readonlyfg -readonlybackground $readonlybg -state readonly
		label $f.0.ll -text "Dflt range" -width 12
		radiobutton $f.0.defset -text "Set as" -variable specavdefrr -value 1 -command "SaveSpecavDflt" -width 7
		radiobutton $f.0.defget -text "Get" -variable specavdefrr -value 2 -command "SetSpecavDflt" -width 4
		checkbutton $f.0.form -text "formant data" -variable specavform
		checkbutton $f.0.ex -text "exact frq" -variable specavxact
		pack $f.0.vv -side left -padx 12
		pack $f.0.from $f.0.lo $f.0.to $f.0.hi $f.0.ll $f.0.defget $f.0.defset -side left -padx 2
		pack $f.0.form $f.0.ex -side left -padx 10
		pack $f.0.qu -side right -padx 2
		pack  $f.0 -side top -fill x -expand true
		label $f.00 -text "NB: Highest-frq peak displayed should be at low level relative to others for peak envelope to be drawn correctly" -fg $evv(SPECIAL)
		label $f.000 -text "LOW FRQ limit of display set with UP/DOWN arrows  :  HIGHG FREQ with RIGHT/LEFT arrows" -fg $evv(SPECIAL)
		pack $f.00 $f.000 -side top -pady 2
		frame $f.1
		radiobutton $f.1.r0 -text "Single Display" -variable specavmultdisp -value 0 -command "set pr_specavc 1"
		radiobutton $f.1.r1 -text "Multiple Display" -variable specavmultdisp -value 1
		radiobutton $f.1.r2 -text "Movie Display" -variable specavmultdisp -value 2 -command "DoSpecavMovie"
		radiobutton $f.1.r2e -text "Movie Envelopes" -variable specavmultdisp -value 3 -command "DoSpecavMovie"
		radiobutton $f.1.r3 -text "Clear" -variable specavmultdisp -value -1 -command "set pr_specavc 1"
		button $f.1.msp -text "Speed" -command {SetSpekMovieSpeed} -width 8 -highlightbackground [option get . background {}]
		pack $f.1.r0 $f.1.r1 $f.1.r2 $f.1.r2e $f.1.r3 $f.1.msp -side left
		pack $f.1 -side top -pady 2
		label $f.11 -text "Click on buttons below to display individual files" -fg $evv(SPECIAL)
		pack $f.11 -side top -pady 2
		frame $f.2
		frame $f.2.0
		set linecnt 0
		set m 0
		set n 1
		while {$m < $specavmaxgraphs} {
			set sar($m) [radiobutton $f.2.$linecnt.r$n -text $n -variable specavdisp -value $m -command "set pr_specavc 2" -width 6]
			pack $f.2.$linecnt.r$n -side left
			incr n
			incr m
			if {[expr $m % 16] == 0} {
				pack $f.2.$linecnt -side top
				incr linecnt
				frame $f.2.$linecnt
			}
		}
		if {[expr $m % 16] != 0} {
			pack $f.2.$linecnt -side top
		}
		pack $f.2 -side top -pady 2
		frame $f.3
		set bav(can) [canvas $f.3.1 -height $bkc(height) -width $bkc(width) -borderwidth 0 \
			-highlightthickness 1 -highlightbackground $evv(SPECIAL) -background white]
		set bavlist [text $f.3.2 -setgrid true -wrap word -width 40 -height 32 \
			-xscrollcommand "$f.3.sx set" -yscrollcommand "$f.3.sy set" -bg white]
		scrollbar $f.3.sy -orient vert  -command "$f.3.2 yview"
		scrollbar $f.3.sx -orient horiz -command "$f.3.2 xview"
		pack $f.3.1 $f.3.2 -side left -fill both -expand true
		pack $f.3.sy -side right -fill y
		pack $f.3 -side top -fill both
		set m 0
		while {$m < $specavfilecnt} {
			$bavlist tag configure color($m) -foreground $brrkcolor([expr $m % $evv(DATACOLORS)])   			;#	Text-colors for various files displayed
			incr m
		}
		wm resizable $f 1 1
		bind $f <Up>	{SpecAvTimeChange 0 0}
		bind $f <Down>	{SpecAvTimeChange 0 1}
		bind $f <Right> {SpecAvTimeChange 1 0}
		bind $f <Left>	{SpecAvTimeChange 1 1}
		bind $f <Return> {set pr_specavc 1}
		bind $f <Escape> {set pr_specavc 0}
	}
	if {$specavfilecnt > [expr $evv(MAXGRAPHS) * $evv(MAXGRAPHS)]} {
		Inf "Cannot display more than [expr $evv(MAXGRAPHS) * $evv(MAXGRAPHS)] graphs"
	}
	set n 1
	set m 0
	set specavlim $specavmaxgraphs
	if {$specavfilecnt < $specavmaxgraphs} {
		set specavlim $specavfilecnt
	}
	while {$m < $specavlim} {
		$sar($m) config -state normal -text "$n"
		incr m
		incr n
	}
	while {$m < $specavmaxgraphs} {
		$sar($m) config -state disabled -text ""
		incr m
	}
	set specavgot 1
	set specavmultdisp 0
	set specavdisp -1
	set specavdisplist {}
	bind $f <Return> {}
	bind $f <Return> {set pr_specavc 1}
	set specavdefrr 0
	catch {$bav(can) delete specavline} in
	set pr_specavc 0
	update idletasks
	raise $f
	My_Grab 0 $f pr_specavc $f
	update idletasks
	set finished 0
	while {!$finished} {
		tkwait variable pr_specavc
		switch -- $pr_specavc {
			1 {
				catch {$bav(can) delete specavline} in
				$bavlist delete 1.0 end
				set specavdisplist {}
				continue
			}
			2 {	;#	SEE
				if {$specavmultdisp >= 2} { ;# movie
					set specavdisplist {}
				} elseif {[lsearch $specavdisplist $specavdisp] >= 0} {
					Inf "File already displayed"
					continue
				}
				if {$specavmultdisp != 1} {
					catch {$bav(can) delete specavline} in
					$bavlist delete 1.0 end
					set specavdisplist {}
				}
				set recalc 0
				if {![info exists specavhilast] || ($specavlo != $specavlolast) || ($specavhi != $specavhilast) \
				|| ($lastspecavxact != $specavxact)} {
					set recalc 1		;#	If using same range as last time, don't recalc the range-lines display
					catch {$bav(can) delete specavscale}
					set specav_rang [expr $specavhi - $specavlo]
					if {$specav_rang < 10} {
						set specavrangstep 1.0
					} elseif {$specav_rang < 50} {
						set specavrangstep 5.0
					} elseif {$specav_rang < 100} {
						set specavrangstep 10.0
					} elseif {$specav_rang < 500} {
						set specavrangstep 50.0
					} elseif {$specav_rang < 1000} {
						set specavrangstep 100.0
					} elseif {$specav_rang < 5000} {
						set specavrangstep 500.0
					} else {
						set specavrangstep 1000.0
					}
					set thisval $specavrangstep
					while {$thisval <= $specavlo} {
						set thisval [expr $thisval + $specavrangstep]
					}
					while {$thisval < $specavhi} {
						set x [expr ($thisval - $specavlo)/$specav_rang]
						set x [expr $x * $bkc(width)]
						set thisrangline [list $x 0.0 $x $bkc(height)]
						eval {$bav(can) create line} $thisrangline {-fill black} {-tag specavscale}
						set thistxt [expr int(round($thisval))]
						$bav(can) create text $x 6 -text $thistxt -fill black -tag specavscale
						set thisval [expr $thisval + $specavrangstep]

					}
					if {!$specavform && !$specavxact} {
						set specavrange [expr $specavvendwin - $specavvsttwin + 3]
						set specavstep [expr double($bkc(width))/double($specavrange)]
					}
				}
				set lastspecavxact $specavxact
				set thisstep 1
				catch {unset specavmaxima}
				set ya $bkc(height)
				if {$specavmultdisp >= 2} { ;# movie
					if {$recalc} { ;#	If using same range as last time, don't recalc the spectral lines for a movie
						Block "Calculating graphic displays"
						set specavhilast $specavhi
						set specavlolast $specavlo

						if {![info exists spekframedur]} {
							set spekframedur 600
						}
						catch {unset linspecav}
						set nn 0
						while {$nn < $specavfilecnt} {
							set lspkav {}
							set spkmax($nn) {}
							set thisstep 1
							foreach {frq amp} $specdata($nn) {
								if {$frq < $specavlo} {
									continue
								} elseif {$frq > $specavhi} {
									break
								}
								if {$specavform || $specavxact} {
									set x [expr ($frq - $specavlo)/$specav_rang]
									set x [expr $x * $bkc(width)]
								} else {
									set x [expr $thisstep * $specavstep]
								}
								set yb [expr (1.0 - $amp) * $bkc(height)]
								set lspkav [list $x $ya $x $yb]
								lappend linspecav($nn) $lspkav
								lappend spkmax($nn) $x $yb
								incr thisstep
							}
							incr nn
						}
						UnBlock
					}
					set m -1
					set n 0
					while {$n < $specavfilecnt} {
						if {$specavmultdisp == 2} {
							foreach lspkav $linspecav($n) {
								eval {$bav(can) create line} $lspkav {-fill $brrkcolor([expr $n % $evv(DATACOLORS)])} {-tag specav_line($n)}
							}
						}
						if {!$specavxact} {
							if {[info exists spkmax($n)] && ([llength $spkmax($n)] > 2)} {
								eval {$bav(can) create line} $spkmax($n) {-fill $brrkcolor([expr $n % $evv(DATACOLORS)]) -width 2} {-tag specav_line($n)}
							}
						}
						set x 0
						after $spekframedur {set x 1}
						vwait x
						catch {$bav(can) delete specav_line($m)}
						set x 0
						after $spekframedur {set x 1}
						vwait x
						incr n
						incr m
					}
					set x 0
					after $spekframedur {set x 1}
					vwait x
					catch {$bav(can) delete specav_line($m)}
					SpecavMovieConclude
				} else {
					foreach {frq amp} $specdata($specavdisp) {
						if {$frq < $specavlo} {
							continue
						} elseif {$frq > $specavhi} {
							break
						}
						if {$specavform} {
							set x [expr ($frq - $specavlo)/$specav_rang]
							set x [expr $x * $bkc(width)]
						} else {
							set x [expr $thisstep * $specavstep]
						}
						set yb [expr (1.0 - $amp) * $bkc(height)]
						set line_specav [list $x $ya $x $yb]
						set specavmaxima [list $x $yb]
						eval {$bav(can) create line} $line_specav {-fill $brrkcolor([expr $specavdisp % $evv(DATACOLORS)])} {-tag specavline}
						incr thisstep
					}
					if {[info exists specavmaxima] && ([llength $specavmaxima] > 2)} {
						eval {$bav(can) create line} $specavmaxima {-fill $brrkcolor([expr $specavdisp % $evv(DATACOLORS)]) -width 2} {-tag specavline}
					}
					lappend specavdisplist $specavdisp
					set line [file rootname [file tail [lindex $chlist $specavdisp]]]
					append line "\n"
					$bavlist insert end $line "color($specavdisp)"
				}
			}
			0 {
				set finished 1
			}
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- Use Arrow Keys to change either time-limits of spectra to average, or frq range to display

proc SpecAvTimeChange {end down} {
	global specavframetime specavstt specavend specavsttframe specavendframe specavmaxframe specavgot 
	global specavvsttwin specavvendwin specavvmaxwin specavvwinwid specavvwinfoot specavlo specavhi specav_nyquist
	if {$specavgot} {
		if {$end} {
			if {$down} {
				if {$specavvendwin > 1} {
					incr specavvendwin -1
					set specavhi [expr int(round(double($specavvendwin) * $specavvwinwid) + $specavvwinfoot)]
				}
			} else {
				if {$specavvendwin < $specavvmaxwin} {
					incr specavvendwin
					set specavhi [expr int(round(double($specavvendwin) * $specavvwinwid) + $specavvwinfoot)]
					if {$specavhi > $specav_nyquist} {
						set specavhi [DecPlaces $specav_nyquist 0]
					}
				}
			}
		} else {
			if {$down} {
				if {$specavvsttwin > 0} {
					incr specavvsttwin -1
					set specavlo [expr int(round(double($specavvsttwin) * $specavvwinwid) + $specavvwinfoot)]
					if {$specavlo < 0.0} {
						set specavlo 0
					}
				}
			} else {
				if {$specavvsttwin < [expr $specavvmaxwin - 1]} {
					incr specavvsttwin
					set specavlo [expr int(round(double($specavvsttwin) * $specavvwinwid) + $specavvwinfoot)]
				}
			}
		}
	} else {
		if {$end} {
			if {$down} {
				if {$specavendframe > 1} {
					incr specavendframe -1
					set specavend [DecPlaces [expr double($specavendframe) * $specavframetime] 6]
				}
			} else {
				if {$specavendframe < $specavmaxframe} {
					incr specavendframe
					set specavend [DecPlaces [expr double($specavendframe) * $specavframetime] 6]
				}
			}
		} else {
			if {$down} {
				if {$specavsttframe > 1} {
					incr specavsttframe -1
					set specavstt [DecPlaces [expr double($specavsttframe) * $specavframetime] 6]
				}
			} else {
				if {$specavsttframe < $specavmaxframe} {
					incr specavsttframe
					set specavstt [DecPlaces [expr double($specavsttframe) * $specavframetime] 6]
				}
			}
		}
	}
}

proc ResetSpecav {where} {
	global specavstt specavsttframe specavsetstt specavend specavendframe specavsetend specavframetime specavmaxframe
	switch -- $where {
		"start" {
			set specavsttframe 1
			set specavstt [DecPlaces [expr double($specavsttframe) * $specavframetime] 6]
			set specavsetstt 0
		}
		"end" {
			set specavendframe $specavmaxframe
			set specavend [DecPlaces [expr double($specavendframe) * $specavframetime] 6]
			set specavsetend 0
		}
	}
}

proc SetSpecavDflt {} {
	global specavdfltwinlo specavdfltwinhi specavdfltmax specavvmaxwin specavvsttwin specavvendwin specavlo specavhi wstk specavdefrr
	global specavvwinwid specavvwinfoot specav_nyquist specavform specavformchans
	if {[info exists specavdfltwinlo] && [info exists specavdfltwinhi] && [info exists specavdfltmax]} {
		if {$specavdfltmax != $specavvmaxwin} { 
			if {[info exists specavform] && $specavform} {
				if {![info exists specavformchans]} {
					set specavformchans [InputSpecAvChans]
					if {$specavformchans <= 0} {
						unset specavformchans
						return
					}
				}
				set fwidth [expr double($specav_nyquist)/double($specavformchans/2)]
				set ffoot  [expr -($fwidth/2.0)]
				set specavlo [expr (double($specavdfltwinlo) * $fwidth) + $ffoot]
				if {$specavlo < 0.0} {
					set specavlo 0.0
				}
				set specavhi [expr (double($specavdfltwinhi) * $fwidth) + $ffoot]
				set specavdefrr 0
				return
			}
			set msg "Default vals set for data with different no.of analysis chans: proceed anyway??"
			set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				return
			} elseif {$specavdfltwinhi > $specavvmaxwin} { 
				Inf "Default values out of range for this data"
				return
			}
		}
		set specavvsttwin $specavdfltwinlo
		set specavvendwin $specavdfltwinhi

		set specavlo [DecPlaces [expr (double($specavvsttwin) * $specavvwinwid) + $specavvwinfoot] 0]
		if {$specavlo < 0.0} {
			set specavlo 0.0
		}
		set specavhi [DecPlaces [expr (double($specavvendwin) * $specavvwinwid) + $specavvwinfoot] 0]
		if {$specavhi > $specav_nyquist} {
			set specavhi $specav_nyquist
		}
	} else {
		Inf "No default values to set"
	}
	set specavdefrr 0
}

proc SaveSpecavDflt {} {
	global specavdfltwinlo specavdfltwinhi specavdfltmax specavvmaxwin specavvsttwin specavvendwin evv specavdefrr wstk
	set msg "Alter default display range to the current setting ?"
	set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
	if {$choice == "no"} {
		return
	}
	set specavdfltwinlo $specavvsttwin
	set specavdfltwinhi $specavvendwin
	set specavdfltmax $specavvmaxwin
	set line [list $specavdfltwinlo $specavdfltwinhi $specavdfltmax]
	set specavdefrr 0
	set fnam specavdflt$evv(CDP_EXT)
	set scidir [file join $evv(URES_DIR) science]
	set fnam [file join $scidir $fnam]
	if [catch {open $fnam "w"} zit] {
		Inf "Cannot open file $fnam to store default frequency range data"
		return
	}
	puts $zit $line
	close $zit
}

proc LoadSpecavDflt {} {
	global specavdfltwinlo specavdfltwinhi specavdfltmax specavvmaxwin specavvsttwin specavvendwin evv

	set fnam specavdflt$evv(CDP_EXT)
	set scidir [file join $evv(URES_DIR) science]
	set fnam [file join $scidir $fnam]
	if {![file exists $fnam]} {
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot open file $fnam to read default frequency range data for spectral averaging"
		return
	}
	set OK 1
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		set line [split $line]
		set cnt 0
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			switch -- $cnt {
				0 {
					set specavdfltwinlo $item
				}
				1 {
					set specavdfltwinhi $item
				}
				2 {
					set specavdfltmax $item
				}
				3 {
					set OK 0
					break
				}
			}
			incr cnt
		}
		if {$cnt < 3} {
			set OK 0
		}
	}
	close $zit
	if {!$OK} {
		Inf "Corrupted data in file $fnam\ncannot load default frq range for spectral averaging"
		catch {unset specavdfltwinlo}
		catch {unset specavdfltwinhi}
		catch {unset specavdfltmax}
	}
}

proc SpecAvHelp {} {

	set msg "                         SPECTRAL DISPLAY\n"
	append msg "\n"
	append msg "SPECTRAL DATA EXTRACTION\n"
	append msg "INPUT - SINGLE MONO SOUNDFILE\n"
	append msg "\n"
	append msg "Create sequence of textfiles representing\n"
	append msg "windows of the sound\n"
	append msg "\n"
	append msg "\n"
	append msg "SPECTRAL AVERAGE EXTRACTION\n"	
	append msg "INPUT - ANALYSIS FILE(S)\n"	
	append msg "\n"
	append msg "Calculate Average Spectrum of 1 (or many) snds.\n"
	append msg "OR\n"
	append msg "Compare the Average spectra of several sounds.\n"
	append msg "OR\n"
	append msg "Extract every analysis window of single sound\n"
	append msg "to view as a \"movie\".\n"
	append msg "\n"
	append msg "If a SINGLE ANALYSIS file is selected\n"
	append msg "you will be offered the option of extracting\n"
	append msg "EVERY analysis window as a TEXT file.\n"
	append msg "\n"
	append msg "If ONE OR MORE ANALYSIS files are selected,\n"
	append msg "the average spectrum can be calculated\n"
	append msg "and output as a TEXT file.\n"
	append msg "\n"
	append msg "\n"
	append msg "SPECTRAL DATA DISPLAY\n"
	append msg "INPUT - TEXTFILES OUTPUT FROM THE ABOVE\n"
	append msg "\n"
	append msg "If the TEXT files generated above\n"
	append msg "are placed on the Chosen Files list\n"
	append msg "they will be display (individually or together,\n"
 	append msg "or as a \"movie\") allowing the spectra\n"
 	append msg "to be compared, or their evolution followed.\n"
	append msg "\n"
	append msg "The movie-display of spectrum of a single sound\n"
	append msg "allows its spectral evolution to be followed.\n"
	append msg "\n"
	append msg "The display of the AVERAGED spectrum\n"
	append msg "enables the characteristic spectral envelope\n"
	append msg "of one sound (e.g. an instrument, a vocal vowel)\n"
	append msg "to be compared with others.\n"
	append msg "\n"
	Inf $msg
}

proc SetSpecAvOutNameAsSrcName {} {
	global specavnam chlist
	if {[llength $chlist] == 1} {
		set specavnam [file rootname [file tail [lindex $chlist 0]]]
	} else {
		Inf "More than one input file"
	}
}

proc NyquistAdjust {frq} {

	set nyqs [list 11025.0 16000.0 22050.0 24000.0 44100.0 48000.0]
	set minerr 100000.0
	foreach nyq $nyqs {
		set diff [expr $nyq - $frq]
		if {$diff < 0.0} {
			set diff [expr -$diff]
		}
		set err [expr $diff/$nyq]
		if {$err < $minerr} {
			set minerr $err
			set nyquist $nyq
		}
	}
	return $nyquist
}

proc DoSpecavMovie {} {
	global pr_specavc sar specavlim
	set m 0
	set n 1
	while {$m < $specavlim} {
		$sar($m) config -state disabled
		incr n
		incr m
	}
	.specavc.1.r0  config -state disabled
	.specavc.1.r1  config -state disabled
	.specavc.1.r2  config -state disabled
	.specavc.1.r2e config -state disabled
	.specavc.1.r3  config -state disabled
	set pr_specavc 2
}

proc SpecavMovieConclude {} {
	global specavlim sar
	set m 0
	set n 1
	while {$m < $specavlim} {
		$sar($m) config -state normal
		incr n
		incr m
	}
	.specavc.1.r0  config -state normal
	.specavc.1.r1  config -state normal
	.specavc.1.r2  config -state normal
	.specavc.1.r2e config -state normal
	.specavc.1.r3  config -state normal
}

#---- Extract every window of an analysis file (for movie-type display)

proc SpecAllExtract {} {
	global chlist ch chcnt pa evv wstk pr_spec_all specavnorm spekallnam prg_dun prg_abortd CDPidrun simple_program_messages 
	global last_outfile specallgpcnt readonlyfg readonlybg specalloutfilecnt specalloutwincnt

	set fnam [lindex $chlist 0]
	set specalloutwincnt [expr $pa($fnam,$evv(WLENGTH)) - 1]
	set specalloutfilecnt $specalloutwincnt
	set f .spec_all
	if [Dlg_Create $f "Extract every spectral window" "set pr_spec_all 0" -borderwidth 2 -width 84] {
		frame $f.0
		button $f.0.qu -text "Abandon" -command "set pr_spec_all 0" -highlightbackground [option get . background {}]
		button $f.0.dd -text "Get spectrum" -command "set pr_spec_all 1" -bg $evv(EMPH) -highlightbackground [option get . background {}]
		pack $f.0.dd -side left
		pack $f.0.qu -side right
		pack  $f.0 -side top -fill x -expand true
		frame $f.1
		checkbutton $f.1.n -variable specavnorm -text "Normalise display" -width 20
		entry $f.1.e -textvariable specallgpcnt -width 4 -fg $readonlyfg -readonlybackground $readonlybg -state readonly
		label $f.1.ll -text "windows per outframe"
		pack $f.1.n $f.1.e $f.1.ll -side left -fill x -expand true
		pack $f.1 -side top -pady 2
		label $f.1a -text "Use Up and Down Arrows to alter window count" -fg $evv(SPECIAL)
		pack $f.1a -side top -pady 2
		frame $f.2
		entry $f.2.nam -textvariable spekallnam -width 24 
		label $f.2.ll -text "Generic Outputfile name"
		pack $f.2.nam $f.2.ll -side left
		pack $f.2 -side top -pady 2
		wm resizable $f 1 1
		bind $f <Up> {SpecallGpcntIncr 0}
		bind $f <Down> {SpecallGpcntIncr 1}
		bind $f <Return> {set pr_spec_all 1}
		bind $f <Escape> {set pr_spec_all 0}
	}
	set specallgpcnt 1
	set specavnorm 1
	set spekallnam [string tolower [file rootname [file tail $fnam]]]
	set pr_spec_all 0
	update idletasks
	raise $f
	My_Grab 0 $f pr_spec_all $f
	update idletasks
	set finished 0
	while {!$finished} {
		tkwait variable pr_spec_all
		switch -- $pr_spec_all {
			0 {
				set finished 1
			}
			1 {
				set alloutnam [string tolower $spekallnam]
				if {![ValidCDPRootname $alloutnam]} { 
					continue
				}
				set OK 1
				set n 1
				while {$n <= $specalloutfilecnt} {
					set ofnam $alloutnam
					append ofnam "_" $n ".txt"
					if {[file exists $ofnam]} {
						Inf "A file with the name $ofnam already exists: please choose a different generic name"
						set OK 0
						break
					}
					incr n
				}
				if {!$OK} {
					continue
				}
				set cmd [file join $evv(CDPROGRAM_DIR) specav]
				lappend cmd specav 3
				lappend cmd $fnam
				lappend cmd $alloutnam
				if {$specallgpcnt > 1} {
					lappend cmd "-g$specallgpcnt"
				}
				if {$specavnorm == 1} {
					lappend cmd "-n"
				}
				Block "Extracting Spectrum"
				catch {unset simple_program_messages}
				set prg_dun 0
				set prg_abortd 0
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "Failed to generate spectral data"
					catch {unset CDPidrun}
					UnBlock
					break
				} else {
					fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				if {!$prg_dun} {
					Inf "Creating spectral data failed"
					UnBlock
					break
				}
				catch {unset goodfiles}
				catch {unset badfiles}
				set n 1
				while {$n <= $specalloutfilecnt} {
					set ofnam $alloutnam
					append ofnam "_" $n ".txt"
					if {![file exists $ofnam]} {
						lappend badfiles $ofnam
					} else {
						lappend goodfiles $ofnam
					}
					incr n
				}
				if {![info exists goodfiles]} {
					Inf "No output file generated"
					UnBlock
					continue
				}
				if {[info exists badfiles]} {
					set msg "Not all analysis windows generated output files\n"
					append msg "(check numbers at end of names, which refer to numbered consecutive windows\n"
					append msg "in the original analysis file)\n"
					Inf $msg
				}
				set goodfiles [ReverseList $goodfiles]
				foreach ofnam $goodfiles {
					FileToWkspace $ofnam 0 0 0 0 1
				}
				set goodfiles [ReverseList $goodfiles]
				set last_outfile $goodfiles
				set msg "Output files \"$alloutnam\" are on the workspace\n\n"
				append msg "Put them on the chosen files list ??"
				set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
				if {$choice == "yes"} {
					DoChoiceBak
					ClearWkspaceSelectedFiles
					foreach ofnam $goodfiles {
						lappend chlist $ofnam
						$ch insert end $ofnam
						incr chcnt
					}
				}
				UnBlock
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc SpecallGpcntIncr {down} {
	global specalloutwincnt specalloutfilecnt specallgpcnt
	if {$down} {
		if {$specallgpcnt > 1} {
			incr specallgpcnt -1
			set specalloutfilecnt [expr $specalloutwincnt / $specallgpcnt]
		}
	} else {
		if {$specallgpcnt < $specalloutwincnt} {
			incr specallgpcnt
			set specalloutfilecnt [expr $specalloutwincnt / $specallgpcnt]
		}
	}
}

proc InputSpecAvChans {} {
	global pr_ispac ispac_chans evv
	set f .ispac
	if [Dlg_Create $f "Enter number of channels used in analysis" "set pr_ispac 0" -borderwidth 2 -width 84] {
		frame $f.0
		button $f.0.qu -text "Abandon" -command "set ispac_chans 0; set pr_ispac 0" -highlightbackground [option get . background {}]
		pack $f.0.qu -side right
		pack  $f.0 -side top -fill x -expand true
		frame $f.1
		radiobutton $f.1.256  -text "256"  -variable ispac_chans -value 256  -command "set pr_ispac 1"
		radiobutton $f.1.512  -text "512"  -variable ispac_chans -value 512  -command "set pr_ispac 1"
		radiobutton $f.1.1024 -text "1024" -variable ispac_chans -value 1024 -command "set pr_ispac 1"
		radiobutton $f.1.2048 -text "2048" -variable ispac_chans -value 2048 -command "set pr_ispac 1"
		radiobutton $f.1.4096 -text "4096" -variable ispac_chans -value 4096 -command "set pr_ispac 1"
		pack $f.1.256 $f.1.512 $f.1.1024 $f.1.2048 $f.1.4096 -side left -fill x -expand true
		pack $f.1 -side top -pady 2
	}
	set ispac_chans 0
	set pr_ispac 0
	update idletasks
	raise $f
	My_Grab 0 $f pr_ispac $f
	update idletasks
	set finished 0
	tkwait variable pr_ispac
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $ispac_chans
}

proc WavSpecDisplay {} {
	global pr_wavspec wsmode wschans wsfnam wspks wsnorm chlist ch chcnt wl pa evv wstk
	global simple_program_messages prg_dun prg_abortd CDPidrun last_outfile

	if {![info exists chlist] || ([llength $chlist] != 1)} {
		Inf "Select one mono soundfile"
		return
	}
	set fnam [lindex $chlist 0]
	if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) != 1)} {
		Inf "Select one mono soundfile"
		return
	}
	set f .wavspec
	if [Dlg_Create $f "Analyse sound, for data display" "set pr_wavspec 0" -borderwidth 2 -width 84] {
		frame $f.0
		button $f.0.run -text "Run" -command "set pr_wavspec 1" -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $f.0.qu -text "Quit" -command "set pr_wavspec 0" -highlightbackground [option get . background {}]
		pack $f.0.run -side left
		pack $f.0.qu -side right
		pack  $f.0 -side top -fill x -expand true
		frame $f.1
		radiobutton $f.1.3 -text "Spectrum"			   -variable wsmode -value 3 -command "WSFormants 0"
		radiobutton $f.1.2 -text "FFT magnitude"	   -variable wsmode -value 2 -command "WSFormants 0"
		radiobutton $f.1.4 -text "Log FFT"			   -variable wsmode -value 4 -command "WSFormants 0"
		radiobutton $f.1.5 -text "Cepstrum"			   -variable wsmode -value 5 -command "WSFormants 0"
		radiobutton $f.1.6 -text "Formants (CDP algo)" -variable wsmode -value 6 -command "WSFormants 1"
		pack $f.1.3 $f.1.2 $f.1.4 $f.1.5 $f.1.6 -side left -fill x -expand true
		pack $f.1 -side top -pady 2
		frame $f.2
		label $f.2.ll -text "Analysis Points" -width 16
		radiobutton $f.2.256  -text "256"  -variable wschans -value 256 
		radiobutton $f.2.512  -text "512"  -variable wschans -value 512 
		radiobutton $f.2.1024 -text "1024" -variable wschans -value 1024
		radiobutton $f.2.2048 -text "2048" -variable wschans -value 2048
		radiobutton $f.2.4096 -text "4096" -variable wschans -value 4096
		pack $f.2.ll $f.2.256 $f.2.512 $f.2.1024 $f.2.2048 $f.2.4096 -side left
		pack $f.2 -side top -pady 2
		frame $f.3
		label $f.3.ll -text "Window Overlap" -width 16
		radiobutton $f.3.1 -text "1" -variable wsoverlap -value 1 
		radiobutton $f.3.2 -text "2" -variable wsoverlap -value 2
		radiobutton $f.3.3 -text "3" -variable wsoverlap -value 3
		radiobutton $f.3.4 -text "4" -variable wsoverlap -value 4
		pack $f.3.ll $f.3.1 $f.3.2 $f.3.3 $f.3.4 -side left
		pack $f.3 -side top -pady 2
		frame $f.4
		label $f.4.ll -text "Formant Peaks(1-12)" -width 16
		entry $f.4.e -textvariable wspks -width 4
		pack $f.4.ll $f.4.e -side left
		pack $f.4 -side top -pady 2
		frame $f.5
		checkbutton $f.5.n -variable wsnorm -text "Normalise output data for display"
		pack $f.5.n -side left
		pack $f.5 -side top -fill x -expand true -pady 2
		frame $f.6
		label $f.6.ll -text "Generic outfile name"
		entry $f.6.e -textvariable wsfnam -width 24
		pack  $f.6.ll $f.6.e -side left
		pack $f.6 -side top -pady 2
		bind $f <Return> {set pr_wavspec 1}
		bind $f <Escape> {set pr_wavspec 0}
	}
	set wsmode 3
	set wsnorm 1
	set wspks  4
	set wschans 1024
	set wsoverlap 3
	WSFormants 0
	set pr_wavspec 0
	update idletasks
	raise $f
	My_Grab 0 $f pr_wavspec $f.6.e
	update idletasks
	set finished 0
	while {!$finished} {
		tkwait variable pr_wavspec
		if {!$pr_wavspec} {
			break
		}
		if {[string length $wsfnam] <= 0} {
			Inf "No output filename entered"
			continue
		}
		set outfnam [string tolower $wsfnam]
		if {![ValidCDPRootname $outfnam]} { 
			continue
		}
		set testofnam $outfnam
		append testofnam "_"
		set len [string length $testofnam]
		set OK 1
		foreach zfnam [glob -nocomplain *] {
			if {[string first $testofnam $zfnam] == 0} {
				if {[string match [file extension $zfnam] $evv(TEXT_EXT)]} {
					Inf "Files already exist with the name '$wsfnam'\nplease choose a diferent name"
					set OK 0
					break
				}
			}
		}
		if {!$OK} {
			continue
		}
		if {$wsmode == 6} {
			if {![IsNumeric $wspks] || ![regexp {^[0-9]+$} $wspks] || ($wspks < 1) || ($wspks > 12)} {
				Inf "Invalid number of formant peaks (1-12)"
				continue
			}
		}
		set cmd [file join $evv(CDPROGRAM_DIR) specanal]
		lappend cmd specanal $wsmode
		lappend cmd $fnam $outfnam
		lappend cmd $wschans $wsoverlap
		if {$wsmode == 6} {
			lappend cmd $wspks
		}
		if {$wsnorm} {
			lappend cmd "-n"
		}
		Block "Extracting Spectrum"
		catch {unset simple_program_messages}
		set prg_dun 0
		set prg_abortd 0
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "Failed to generate spectral data"
			catch {unset CDPidrun}
			UnBlock
			continue
		} else {
			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			Inf "Creating spectral data failed"
			UnBlock
			continue
		}
		catch {unset goodfiles}
		foreach zfnam [glob -nocomplain *] {
			if {[string first $testofnam $zfnam] == 0} {
				if {[string match [file extension $zfnam] $evv(TEXT_EXT)]} {
					lappend goodfiles $zfnam
				}
			}
		}
		if {![info exists goodfiles]} {
			Inf "No output files created"
			UnBlock
			continue
		}
		wm title .blocker  "PLEASE WAIT:      Sorting output files"
		catch {unset dlist}		;#	Sort files on descending order of number at name end
		foreach zfnam $goodfiles {
			set numends [GetNumericEndPart $zfnam]
			set num [string range $zfnam [lindex $numends 0] [lindex $numends 1]]
			lappend dlist [list $zfnam $num]
		}
		set len [llength $dlist]
		set len_less_one [expr $len - 1]
		set n 0
		while {$n < $len_less_one} {
			set dlist_n [lindex $dlist $n]
			set num_n [lindex $dlist_n 1]
			set m $n
			incr m
			while {$m < $len} {
				set dlist_m [lindex $dlist $m]
				set num_m [lindex $dlist_m 1]
				if {$num_m > $num_n} {
					set dlist [lreplace $dlist $m $m $dlist_n]
					set dlist [lreplace $dlist $n $n $dlist_m]
					set dlist_n $dlist_m
					set num_n $num_m
				}
				incr m
			}
			incr n
		}
		catch {unset goodfiles}
		foreach kk $dlist {
			lappend goodfiles [lindex $kk 0]
		}
		set msg "Put output files on the chosen files list ??"
		set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			set to_choice 1
		} else {
			set to_choice 0
		}
		wm title .blocker  "PLEASE WAIT:      Loading files to workspace"
		foreach zfnam $goodfiles {
			FileToWkspace $zfnam 0 0 0 0 1
		}
		set last_outfile $goodfiles
		if {$to_choice} {
		wm title .blocker  "PLEASE WAIT:      Loading files to chosen files list"
			DoChoiceBak
			ClearWkspaceSelectedFiles
			set goodfiles [ReverseList $goodfiles]
			foreach zfnam $goodfiles {
				lappend chlist $zfnam
				$ch insert end $zfnam
				incr chcnt
			}
		}
		set msg "Output files are "
		if {$to_choice} {
			append msg "on the chosen files list"
		} else {
			append msg "on the workspace"
		}
		Inf $msg
		UnBlock
		set finished 1
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- Show formant peaks entry-box, or not

proc WSFormants {on} {
	global wspks old_wspks
	if {$on} {
		.wavspec.4.ll config -text "Formant Peaks(1-12)"
		.wavspec.4.e  config -bd 2 -state normal
		if {[info exists old_wspks]} {
			set wspks $old_wspks
		}
	} else {
		set old_wspks $wspks
		set wspks ""
		.wavspec.4.ll config -text ""
		.wavspec.4.e  config -bd 0 -state disabled -disabledbackground [option get . background {}]
	}
}

#--------- Convert time series to brkpoint file

proc TimeSeriesConvertor {} {
	global chlist wl evv pr_tsc tsc pa
	if {[info exists chlist] && ([llength $chlist] == 1)} {
		set fnam $chlist
	} else {
		set i [$wl curselection]
		if {[llength $i] == 1} {
			if {$i != -1} {
				set fnam [$wl get $i]
			}
		}
	}
	if {![info exists fnam] || ![IsAListofNumbers $pa($fnam,$evv(FTYP))]} {
		Inf "Select one textfile (a list of numeric values)"
		return
	}
	Block "Reading Data"
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot open file $fnam"
		UnBlock
		return
	}
	set cnt 0
	catch {unset vals}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		lappend vals $line
		incr cnt
	}
	UnBlock
	if {$cnt == 0} {
		Inf "No data found in file $fnam"
		return
	}
	set f .tseries
	if [Dlg_Create $f "Convert to breakpoint file" "set pr_tsc 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0] 
		set f1 [frame $f.1] 
		set f2 [frame $f.2] 
		set f3 [frame $f.3] 
		button $f0.ok -text "Convert" -command "set pr_tsc 1" -bg $evv(EMPH) -highlightbackground [option get . background {}]
		label $f0.ll -text "$cnt entries" -fg $evv(SPECIAL) -width 40
		button $f0.quit -text "Quit" -command "set pr_tsc 0" -highlightbackground [option get . background {}]
		pack $f0.ok $f0.ll -side left -pady 6
		pack $f0.quit -side right
		pack $f0 -side top -fill x -expand true

		radiobutton $f1.dur -text "Total duration" -value 0 -variable tsc(typ) -command FlipTsc 
		radiobutton $f1.stp -text "Time step" -value 1 -variable tsc(typ) -command FlipTsc
		pack $f1.dur $f1.stp -side left -padx 2
		pack $f1 -side top  -pady 2
		set tsc(typ) 0
		label $f2.ll -text "Total Duration" -width 15
		entry $f2.e -textvariable tsc(dur) -width 12
		pack $f2.e $f2.ll -side left -padx 2
		pack $f2 -side top -fill x -expand true -pady 2

		label $f3.ll -text "Output File Name"
		entry $f3.e -textvariable tsc(fnam) -width 12
		pack $f3.e $f3.ll -side left -padx 2
		pack $f3 -side top -fill x -expand true -pady 2

		bind $f <Escape> {set pr_tsc 0}
		bind $f <Return> {set pr_tsc 1}
		bind $f.2.e <Down> "focus $f.3.e"
		bind $f.3.e <Down> "focus $f.2.e"
		bind $f.2.e <Up> "focus $f.3.e"
		bind $f.3.e <Up> "focus $f.2.e"
		wm resizable $f 0 0
	}
	set pr_tsc 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_tsc $f.2.e
	while {!$finished} {
		tkwait variable pr_tsc
		if {$pr_tsc} {
			if {([string length $tsc(dur)] <= 0) || ![IsNumeric $tsc(dur)] || ($tsc(dur) <= 0.0)} {
				set msg "Invalid "
				if {$tsc(typ)} {
					append msg "time step "
				} else {
					append msg "total duration "
				}
				append msg "entered"
				Inf $msg
				continue
			}
			if {[string length $tsc(fnam)] <= 0} {
				Inf "No output filename entered"
				continue
			}
			set outfnam [string tolower $tsc(fnam)]
			if {![ValidCDPRootname $outfnam]} {
				continue
			}
			append outfnam $evv(TEXT_EXT)
			if {[file exists $outfnam]} {
				Inf "File $outfnam already exists: please choose a different name"
				continue
			}
			Block "Doing Conversion"
			if {$tsc(typ)} {
				set timestep $tsc(dur)
			} else {
				set timestep [expr $tsc(dur)/double($cnt - 1)]
			}
			set n 0
			set time 0.0
			catch {unset lines}
			foreach val $vals {
				set line [list $time $val]
				lappend lines $line
				set time [expr $time + $timestep]
			}					
			if [catch {open $outfnam "w"} zit] {
				Inf "Cannot open file $outfnam to write the breakpoint data"
				UnBlock
				continue
			}
			foreach line $lines {
				puts $zit $line
			}
			close $zit
			FileToWkspace $outfnam 0 0 0 0 1
			UnBlock
			Inf "File $outfnam is on the workspace"
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}
					
	
proc FlipTsc {} {
	global tsc
	switch -- $tsc(typ) {
		0 {
			.tseries.2.ll config -text "Total Duration"
		}
		1 {
			.tseries.2.ll config -text "Time Step"
		}
	}
}

#---- Convert multichannel mix to rhyhtmic cell 

proc MmixToRhyCell {} {
	global chlist pa evv wl mmxrhy_fnam pr_mmxrhy mmxrhy_mark

	if {[info exists chlist] && ([llength $chlist] == 1)} {
		set fnam $chlist
	} else {
		set i [$wl curselection]
		if {[llength $i] == 1} {
			if {$i != -1} {
				set fnam [$wl get $i]
			}
		}
	}
	if {![info exists fnam] || ($pa($fnam,$evv(FTYP)) != $evv(MIX_MULTI))} {
		Inf "Select one multichannel mixfile, representing a rhythmic cell"
		return
	}

	if [catch {open $fnam "r"} zit] {
		Inf "Cannot open file $fnam"
		return
	}
	set linecnt 1
	set OK 1
	set fnams {}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0 ] ";"]} {
			continue
		}
		set line [split $line]
		catch {unset nuline}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			lappend nuline $item
		}
		set line $nuline
		if {$linecnt != 1} {
			set fnam [file rootname [file tail [lindex $line 0]]]
			if {[lsearch $fnams $fnam] >= 0} {
				Inf "Duplication of path-free sndfile name $fnam : cannot proceed with this process"
				set OK 0
				break
			}
			lappend fnams $fnam
			set chans [lindex $line 2]
			if {$chans > 2} {
				Inf "This process only works for mixes of mono and/or stereo files"
				set OK 0
				break
			}
			lappend chancnts $chans
			set len [llength $line]
			if {$len > 5} {
				set routs {}
				set n 3
				while {$n < $len} {
					set rout [lindex $line $n]
					if {[lsearch $routs $rout] >= 0} {
						Inf "Duplicated routing in line $linecnt"
						set OK 0
						break
					}
					lappend routs $rout
					incr n 2
				}
				if {!$OK} {
					break
				}
			}
			lappend nulines $nuline		;#	SKIP CHANNELS-CNT LINE
		}
		incr linecnt
	}
	close $zit
	if {!$OK} {
		return
	}
	set inlines $nulines
	;#	SORT INTO TIME ORDER
	set len [llength $inlines]
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set line_n [lindex $inlines $n]
		set time_n [lindex $line_n 1]
		set m $n
		incr m
		while {$m < $len} {
			set line_m [lindex $inlines $m]
			set time_m [lindex $line_m 1]
			if {$time_m < $time_n} {
				set inlines [lreplace $inlines $n $n $line_m]
				set inlines [lreplace $inlines $m $m $line_n]
				set line_n line_m
				set time_n time_m
			}
			incr m
		}
		incr n
	}
	set lastchancnt [lindex $chancnts end]

	set f .mmxrhy
	if [Dlg_Create $f "Convert mix to rhythm cell" "set pr_mmxrhy 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0] 
		set f1 [frame $f.1] 
		button $f0.ok -text "Convert" -command "set pr_mmxrhy 1" -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $f0.quit -text "Quit" -command "set pr_mmxrhy 0" -highlightbackground [option get . background {}]
		pack $f0.ok -side left
		pack $f0.quit -side right
		pack $f0 -side top -fill x -expand true

		label $f1.ll -text "Output File Name"
		entry $f1.e -textvariable mmxrhy_fnam -width 12
		pack $f1.e $f1.ll -side left -padx 2
		pack $f1 -side top -fill x -expand true -pady 2
		label $f.2 -text "Outputs 2 files \"name.txt\" and \"name_idx.txt\"" -fg $evv(SPECIAL)
		pack $f.2 -side top
		label $f.3 -text "NB: Last line will be  cell duration marker ONLY" -fg $evv(SPECIAL)
		pack $f.3 -side top
		set mmxrhy_mark 1
		bind $f <Escape> {set pr_mmxrhy 0}
		bind $f <Return> {set pr_mmxrhy 1}
		wm resizable $f 0 0
	}
	set pr_mmxrhy 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_mmxrhy $f.1.e
	while {!$finished} {
		tkwait variable pr_mmxrhy
		if {$pr_mmxrhy} {
			if {[string length $mmxrhy_fnam] <= 0} {
				Inf "No output filename entered"
				continue
			}
			set rhofnam [string tolower $mmxrhy_fnam]
			if {![ValidCDPRootname $rhofnam]} {
				continue
			}
			append rhofnam $evv(TEXT_EXT)
			if {[file exists $rhofnam]} {
				Inf "File $rhofnam already exists: please choose a different name"
				continue
			}
			set mapofnam [string tolower $mmxrhy_fnam]
			append mapofnam "_idx" $evv(TEXT_EXT)
			if {[file exists $mapofnam]} {
				Inf "File $mapofnam already exists: please choose a different name"
				continue
			}
			set nulines {}
			set fnams {}
			set idxs {}
			set idx 1
			foreach line $inlines {
				set fnam   [file rootname [file tail [lindex $line 0]]]
				set chans  [lindex $line 2]
				if {$chans == 2} {
					set xfnam $fnam
					append xfnam "@1"
					if {[lsearch $fnams $xfnam] < 0} {
						lappend fnams $xfnam
						lappend idxs $idx
						incr idx
					}
					set xfnam $fnam
					append xfnam "@2"
					if {[lsearch $fnams $xfnam] < 0} {
						lappend fnams $xfnam
						lappend idxs $idx
						incr idx
					}
				} else {
					if {[lsearch $fnams $fnam] < 0} {
						lappend fnams $fnam
						lappend idxs $idx
						incr idx
					}
				}
			}
			foreach line $inlines {
				set len   [llength $line]
				set fnam  [file rootname [file tail [lindex $line 0]]]		
				set time  [lindex $line 1]
				set chans [lindex $line 2]
				set n 3
				if {$chans == 1} {
					set k [lsearch $fnams $fnam]
					set idx [lindex $idxs $k]
					while {$n < $len} {
						set rout [lindex $line $n]
						set rout [split $rout ":"]
						set goal [lindex $rout 1]
						incr n
						set levl [lindex $line $n]
						incr n
						set nuline [list $time $idx $levl $goal]
						lappend nulines $nuline
					}
				} else {
					while {$n < $len} {
						set rout [lindex $line $n]
						set rout [split $rout ":"]
						set srrc [lindex $rout 0]
						set goal [lindex $rout 1]
						incr n
						set levl [lindex $line $n]
						incr n
						set xfnam $fnam
						append xfnam "@" $srrc
						set k [lsearch $fnams $xfnam]
						set idx [lindex $idxs $k]
						set nuline [list $time $idx $levl $goal]
						lappend nulines $nuline
					}
				}
			}											;#	Last file is only a marker, if it is stereo
			if {$lastchancnt == 2} {					;#	so if it is stereo
				set len [llength $nulines]			
				incr len -2								;#	Delete the 2nd channel representation
				set nulines [lrange $nulines 0 $len]	;#	by deleting the last line

				set len [llength $idxs]					;#	Do same in indexing-file
				incr len -2
				set idxs [lrange $idxs 0 $len]
				set fnams [lrange $fnams 0 $len]
				set lastfnam [lindex $fnams $len]
				set strrlen [string length $lastfnam]
				incr strrlen -3
				set lastfnam [string range $lastfnam 0 $strrlen]
				set fnams [lreplace $fnams $len $len $lastfnam]

			}

			catch {unset ofnams}
			if [catch {open $rhofnam "w"} zit] {
				Inf "Cannot open file $rhofnam to write \"tilp\" file" 
				continue
			}
			foreach line $nulines {
				puts $zit $line
			}
			close $zit
			lappend ofnams $rhofnam

			if [catch {open $mapofnam "w"} zit] {
				Inf "Cannot open file $mapofnam to write snd-index info file" 
			} else {
				set line [list 0 SILENT]		;#	zero-indexed silent file
				puts $zit $line
				foreach idx $idxs fnam $fnams {
					set line [list $idx $fnam]
					puts $zit $line
				}
				close $zit
			}
			lappend ofnams $mapofnam
			foreach ofnam $ofnams {
				FileToWkspace $ofnam 0 0 0 0 1
			}
			Inf "Files are on the workspace"
			set finished 1
		} else {
			set finished 1
		}
	}		 
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc PlayPM {} {
	global chlist wl pa evv pr_playpm playpm_start playpm_end wstk CDPidrun CDPid prg_dun prg_abortd props_got parse_error propslist parse_the_max

	if {[info exists chlist] && ([llength $chlist] == 1)} {
		set fnam [lindex $chlist 0]
		if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) <= 2)} {
			unset fnam
		}
	}
	if {![info exists fnam]} {
		set i [$wl curselection]
		if {[info exists i] && ([llength $i] == 1) && ($i != -1)} {
			set fnam [$wl get $i]
			if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) <= 2)} {
				unset fnam
			}
		}
	}
	if {![info exists fnam]} {
		Inf "Select a single multichannel file"
		return
	}
	set chans $pa($fnam,$evv(CHANS))
	set dur $pa($fnam,$evv(DUR))
	if {$dur <= 1.0} {
		Inf "File must be longer than 1 second"
		return
	}
	set f .playpm
	if [Dlg_Create $f "Play part of multichannel file" "set pr_playpm 0" -borderwidth 2 -width 84] {
		frame $f.0
		button $f.0.qu -text "Quit" -command "set pr_playpm 0" -width 5 -highlightbackground [option get . background {}]
		button $f.0.pp -text "Play" -command "set pr_playpm 2" -width 5 -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $f.0.vv -text "View" -command "set pr_playpm 3" -width 5 -bg $evv(SNCOLOR) -highlightbackground [option get . background {}]
		button $f.0.cc -text "Cut"  -command "set pr_playpm 1" -width 5 -highlightbackground [option get . background {}]
		pack $f.0.cc $f.0.pp $f.0.vv -side left -padx 4
		pack $f.0.qu -side right
		pack  $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.siz -text "Start Time" -width 10
		entry $f.1.gpp -textvariable playpm_start -width 8
		button $f.1.stt -text "Zero" -command "set playpm_start 0.0" -width 4 -highlightbackground [option get . background {}]
		pack $f.1.siz $f.1.gpp $f.1.stt -side left -padx 2
		pack $f.1 -side top -fill x -expand true
		frame $f.2
		label $f.2.siz -text "End Time" -width 10
		entry $f.2.gpp -textvariable playpm_end -width 8
		button $f.2.end -text "End" -command "set playpm_end $dur" -width 4 -highlightbackground [option get . background {}]
		pack $f.2.siz $f.2.gpp $f.2.end -side left -padx 2
		pack $f.2 -side top -fill x -expand true
		frame $f.3
		label $f.3.ll -text "Play duration must be more than 1 second" -fg $evv(SPECIAL)
		pack $f.3.ll -side left -padx 2
		pack $f.3 -side top
		wm resizable $f 1 1
		bind $f <Escape> {set pr_playpm 0}
	}
	bind $f <Return> {set pr_playpm 1}
	.playpm.0.pp config -bd 0 -command {} -text "" -bg [option get . background {}]
	.playpm.0.vv config -bd 0 -command {} -text "" -bg [option get . background {}]
	set playpm_start 0.0
	set playpm_end $dur
	set minstart [expr $dur - 1.0]
	set pr_playpm 0
	update idletasks
	raise $f
	update idletasks
	My_Grab 0 $f pr_playpm $f
	update idletasks
	set finished 0
	set ofnam $evv(DFLT_OUTNAME)
	append ofnam 0 $evv(SNDFILE_EXT)
	while {!$finished} {
		tkwait variable pr_playpm
		switch -- $pr_playpm {
			1 {
				DeleteAllTemporaryFiles
				catch {unset pa($ofnam,$evv(CHANS))}
				.playpm.0.pp config -bd 0 -command {} -text "" -bg [option get . background {}]
				.playpm.0.vv config -bd 0 -command {} -text "" -bg [option get . background {}]
				if {([string length $playpm_start] <= 0) || ![IsNumeric $playpm_start] || ($playpm_start < 0.0)} {
					Inf "Invalid start time"
					continue
				}
				if {$playpm_start > $minstart} {
					Inf "Start time too late in the file"
					continue
				}
				if {([string length $playpm_end] <= 0) || ![IsNumeric $playpm_end] || ($playpm_end < 0.0)} {
					Inf "Invalid end time"
					continue
				}
				if {$playpm_end > $dur} {
					set playpm_end $dur
					Inf "End time truncated to end of file"
				}
				set playdur [expr $playpm_end - $playpm_start]
				if {$playdur <= 1.0} {
					Inf "Duration to play ($playdur) must be more than 1 second"
					continue
				}
				Block "Cutting File"
				set cmd [file join $evv(CDPROGRAM_DIR) sfedit]
				lappend cmd cut 1 $fnam $ofnam $playpm_start $playpm_end -w15
				set CDPidrun 0
				set prg_dun 0
				set prg_abortd 0
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "Failed to run file cutting process"
					UnBlock
					continue
   				} else {
   					fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				if {!$prg_dun} {
					Inf "Failed to cut file [file rootname [file tail $fnam]]"
					UnBlock
					continue
				}
				if {![file exists $ofnam]} {
					Inf "Failed to create file-segment to play"
					UnBlock
					continue
				}
				.playpm.0.pp config -bd 2 -text "Play" -command "set pr_playpm 2" -bg $evv(EMPH)
				.playpm.0.vv config -bd 2 -text "View" -command "set pr_playpm 3" -bg $evv(SNCOLOR)
				bind $f <Return> {set pr_playpm 2}
				UnBlock
				continue
			}
			2 {
				if {![file exists $ofnam]} {
					Inf "No soundfile to play"
					continue
				}	
				PlaySndfile $ofnam 0			;# PLAY OUTPUT
				continue
			} 
			3 {
				if {![file exists $ofnam]} {
					Inf "No soundfile to view"
					continue
				}
				if {![info exists pa($ofnam,$evv(CHANS))]} {
					set CDPid 0
					set props_got 0
					set parse_error 0
					set cmd [file join $evv(CDPROGRAM_DIR) cdparse]
					if [catch {open "|$cmd $ofnam $parse_the_max"} CDPid] {
						ErrShow "Cdparse program failed to run"
						catch {unset CDPid}
						continue
					} else {
						set propslist ""
						fileevent $CDPid readable AccumulateFileProps
					}
					vwait props_got
					if {$parse_error} {
						ErrShow "Cdparse program failed"
						continue
					}
					if [info exists propslist] {
						set propno 0
						foreach prop $propslist {
							set pa($ofnam,$propno) $prop
							incr propno
						}
					}
				}
				SnackDisplay 0 $evv(SN_FILE_PRMPAGE_NO_OUTPUT) 0 $ofnam
				continue
			}
			0 {
				set finished 1
			}
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc EightToOne {} {
	global chlist evv pa wl pr_eightone eightone_start eightone_end eightone_foc eightone_chan wstk
	global prg_dun prg_abortd done_maxsamp maxsamp_line CDPmaxId CDPidrun

	set gotchans 0
	if {[info exists chlist] && ([llength $chlist] == 1)} {
		set fnam [lindex $chlist 0]
		if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) != 8)} {
			unset fnam
		}
	}
	if {![info exists fnam]} {
		set i [$wl curselection]
		if {[info exists i] && ([llength $i] == 1) && ($i != -1)} {
			set fnam [$wl get $i]
			if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) != 8)} {
				unset fnam
			}
		}
	}
	if {![info exists fnam]} {
		Inf "Select a single 8-channel file"
		return
	}
	set chans 8
	set dur $pa($fnam,$evv(DUR))
	set basfnam [file rootname [file tail $fnam]]
	set n 1
	while {$n < 9} {
		set qfnam $basfnam 
		append qfnam _c$n $evv(SNDFILE_EXT)
		lappend cfnams $qfnam
		if {[file exists $qfnam]} {
			if {$n == 1} {
				set msg "A file $qfnam already exists:\n\ndo you want to re-use such extracted channel files ??"
				set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					Inf "Please delete all such channel-extracted files before proceeding"
					return
				}
				set qdur $pa($qfnam,$evv(DUR))
			} else {
				if {$pa($qfnam,$evv(DUR)) != $qdur} {
					Inf Durations of existing channel-extracted files do not tally"
					return
				}
			}
			lappend qfnams $qfnam
		}
		incr n
	}
	if {[info exists qfnams]} {
		if {[llength $qfnams] != 8} {
			Inf "Insufficient ([llength $qfnams]) channel-extracted files found"
			return
		}
		set gotchans 1
	}
	set ofnam [file rootname [file tail $fnam]]
	append ofnam "_8to1" $evv(SNDFILE_EXT)
	if {[file exists $ofnam]} {
		Inf "File $ofnam already exists : please rename it before proceeding"
		return
	}
	set n 1
	while {$n < 9} {
		set panfile($n) $evv(DFLT_OUTNAME)
		append panfile($n) $n $evv(SNDFILE_EXT)
		set pandata($n) $evv(DFLT_OUTNAME)
		append pandata($n) $n $evv(TEXT_EXT)
		incr n
	}
	set mixfile $evv(DFLT_OUTNAME)
	append mixfile 0 $evv(TEXT_EXT)

	set f .eightone
	if [Dlg_Create $f "Pan eight into one" "set pr_eightone 0" -borderwidth 2 -width 84] {
		frame $f.0
		button $f.0.qu -text "Quit" -command "set pr_eightone 0" -width 5 -highlightbackground [option get . background {}]
		button $f.0.pp -text "Play" -command "set pr_eightone 2" -width 5 -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $f.0.vv -text "View" -command "set pr_eightone 3" -width 5 -bg $evv(SNCOLOR) -highlightbackground [option get . background {}]
		button $f.0.cc -text "Pan"  -command "set pr_eightone 1" -width 5 -highlightbackground [option get . background {}]
		pack $f.0.cc $f.0.pp $f.0.vv -side left -padx 4
		pack $f.0.qu -side right
		pack  $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.siz -text "Start Time" -width 10
		entry $f.1.gpp -textvariable eightone_start -width 8
		button $f.1.stt -text "Zero" -command "set eightone_start 0.0" -width 4 -highlightbackground [option get . background {}]
		pack $f.1.siz $f.1.gpp $f.1.stt -side left -padx 2
		pack $f.1 -side top -fill x -expand true
		frame $f.2
		label $f.2.siz -text "End Time" -width 10
		entry $f.2.gpp -textvariable eightone_end -width 8
		button $f.2.end -text "End" -command "set eightone_end $dur" -width 4 -highlightbackground [option get . background {}]
		pack $f.2.siz $f.2.gpp $f.2.end -side left -padx 2
		pack $f.2 -side top -fill x -expand true
		frame $f.3
		label $f.3.siz -text "Merge to Channel" -width 16
		entry $f.3.gpp -textvariable eightone_chan -width 8
		pack $f.3.siz $f.3.gpp -side left -padx 2
		pack $f.3 -side top -fill x -expand true
		frame $f.4
		label $f.4.siz -text "Focus" -width 16
		entry $f.4.gpp -textvariable eightone_foc -width 8
		pack $f.4.siz $f.4.gpp -side left -padx 2
		pack $f.4 -side top -fill x -expand true
		frame $f.5
		label $f.5.ll -text "MINIMUM PAN DURATION = 1 SECOND" -fg $evv(SPECIAL)
		pack $f.5.ll -side left -padx 2
		pack $f.5 -side top
		wm resizable $f 1 1
		bind $f <Escape> {set pr_eightone 0}
		bind $f.1.gpp <Down> {focus .eightone.2.gpp} 
		bind $f.2.gpp <Down> {focus .eightone.3.gpp} 
		bind $f.3.gpp <Down> {focus .eightone.4.gpp} 
		bind $f.4.gpp <Down> {focus .eightone.1.gpp} 
		bind $f.1.gpp <Up> {focus .eightone.4.gpp} 
		bind $f.2.gpp <Up> {focus .eightone.1.gpp} 
		bind $f.3.gpp <Up> {focus .eightone.2.gpp} 
		bind $f.4.gpp <Up> {focus .eightone.3.gpp} 
	}
	if {[info exists eightone_foc] && ([string length $eightone_foc] <= 0)} {
		set eightone_foc 1.0
	}
	bind $f <Return> {set pr_eightone 1}
	.eightone.0.pp config -bd 0 -command {} -text "" -bg [option get . background {}]
	.eightone.0.vv config -bd 0 -command {} -text "" -bg [option get . background {}]
	set eightone_start 0.0
	if {[info exists eightone_end] && ([string length $eightone_end] <= 0)} {
		set eightone_end $dur
	}
	if {[info exists eightone_start] && ([string length $eightone_start] <= 0)} {
		set eightone_start 0.0
	}
	set minstart [expr $dur - 1.0]
	set pr_eightone 0
	update idletasks
	raise $f
	update idletasks
	My_Grab 0 $f pr_eightone $f.1.gpp
	update idletasks
	set finished 0
	while {!$finished} {
		tkwait variable pr_eightone
		switch -- $pr_eightone {
			1 {
				DeleteAllTemporaryFiles
				.eightone.0.pp config -bd 0 -command {} -text "" -bg [option get . background {}]
				.eightone.0.vv config -bd 0 -command {} -text "" -bg [option get . background {}]
				if {([string length $eightone_chan] <= 0) || ![IsNumeric $eightone_chan] || ![regexp {^[0-9]+$} $eightone_chan] \
				|| ($eightone_chan < 1) || ($eightone_chan > 8) } {
					Inf "Invalid merge-to channel number (1-8)"
					continue
				}
				if {([string length $eightone_start] <= 0) || ![IsNumeric $eightone_start] || ($eightone_start < 0.0)} {
					Inf "Invalid start time"
					continue
				}
				if {$eightone_start > $minstart} {
					Inf "Start time of pan too late in the file"
					continue
				}
				if {([string length $eightone_end] <= 0) || ![IsNumeric $eightone_end] || ($eightone_end < 0.0)} {
					Inf "Invalid end time"
					continue
				}
				if {$eightone_end > $dur} {
					set eightone_end $dur
					Inf "End time of pan truncated to end of file"
				}
				set playdur [expr $eightone_end - $eightone_start]
				if {$playdur <= 1.0} {
					Inf "Duration to pan ($playdur) must be more than 1 second"
					continue
				}
				if {([string length $eightone_foc] <= 0) || ![IsNumeric $eightone_foc] || ($eightone_foc <= 0.0) || ($eightone_foc > 1.0)} {
					Inf "Invalid focus value (>0 to 1)"
					continue
				}
				Block "Panning File"
				set OK 1
				if {!$gotchans} {
					set cmd [file join $evv(CDPROGRAM_DIR) housekeep]
					lappend cmd chans 2 $fnam
					set CDPidrun 0
					set prg_dun 0
					set prg_abortd 0
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "Failed to run file channel-extraction process"
						UnBlock
						set finished 1
						break
   					} else {
   						fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
					}
					vwait prg_dun
					if {$prg_abortd} {
						set prg_dun 0
					}
					if {!$prg_dun} {
						Inf "Failed to extract channels from file [file rootname [file tail $fnam]]"
						UnBlock
						set finished 1
						break
					}
					set n 1
					foreach cfnam $cfnams {
						if {![file exists $cfnam]} {
							Inf "Failed to extract channel $n"
							set OK 0
							break
						}
						incr n
					}
					if {!$OK} {
						UnBlock
						set finished 1
						break
					} else {
						set qfnams $cfnams
						set gotchans 1
					}
				}
				wm title .blocker  "PLEASE WAIT:      Creating pan info files"

				set opposite [expr ((($eightone_chan - 1) + 4) % 8) + 1]
							;# e.g.			6		--> 5 -->9  -->1-->2
							;# e.g.			2		--> 1 -->5  -->5-->6
				set pandir($eightone_chan) c	;#	copy
				set pandir($opposite) 0			;#	direct
				set k $eightone_chan
				set j 0
				while {$j < 3} {
					incr k
					if {$k > 8} {
						incr k -8
					}
					set pandir($k) -1			;#	anticlockwise
					incr j
				}
				set k $eightone_chan
				set j 0
				while {$j < 3} {
					incr k -1
					if {$k < 1} {
						incr k 8
					}
					set pandir($k) 1			;#	clockwise
					incr j
				}
				set n 1
				while {$n < 9} {
					if {$pandir($n) == "c"} {
						incr n
						continue
					}
					catch {unset lines}
					if {$eightone_start > 0.0} {
						set line [list 0  $n  0]
						lappend lines $line
					}
					set line [list	$eightone_start $n $pandir($n)]
					lappend lines $line
					set line [list	$eightone_end $eightone_chan 0]
					lappend lines $line
					if {$eightone_end < $dur} {
						set line [list $dur		$eightone_chan	0]
						lappend lines $line
					}
					if [catch {open $pandata($n) "w"} zit] {
						Inf "Cannot open pandatafile $n to write pandata for channel $n"
						set OK 0
						break
					}
					foreach line $lines {
						puts $zit $line
					}
					close $zit
					incr n
				}
				if {!$OK} {
					Unblock
					set finished 1
					break
				}
				set m 0
				set n 1
				while {$n < 9} {
					wm title .blocker  "PLEASE WAIT:      Panning channel $n"
					set qfnam [lindex $qfnams $m]
					if {![file exists $pandata($n)]} {	;#	unpanned file
						set panfile($n) $qfnam
						incr n
						incr m
						continue
					} 
					set cmd [file join $evv(CDPROGRAM_DIR) mchanpan]
					lappend cmd mchanpan 1 $qfnam $panfile($n) $pandata($n) 8 -f$eightone_foc
					set CDPidrun 0
					set prg_dun 0
					set prg_abortd 0
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "Failed to run panning of file $n"
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
						Inf "Failed to pan extracted channel $n"
						set OK 0
						break
					}
					incr n
					incr m
				}
				if {!$OK} {
					UnBlock
					set finished 1
					break
				}
				set n 1
				while {$n < 9} {
					if {![file exists $panfile($n)]} {
						Inf "Failed to pan channel $n"
						set OK 0
						break
					}
					incr n
				}
				if {!$OK} {
					UnBlock
					set finished 1
					break
				}
				wm title .blocker  "PLEASE WAIT:      Mixing panned channels"
				catch {unset lines}
				set routx [list 0.0 1 1:1 1]
				set rout  [list 0.0 8 1:1 1 2:2 1 3:3 1 4:4 1 5:5 1 6:6 1 7:7 1 8:8 1]

				set line 8
				lappend lines $line
				set n 1
				while {$n < 9} {
					if {$n == $eightone_chan} {
						set line [concat $panfile($n) $routx]
					} else {
						set line [concat $panfile($n) $rout]
					}
					lappend lines $line
					incr n
				}
				if [catch {open $mixfile "w"} zit] {
					Inf "Cannot open mixfile $mixfile to write mix data"
					continue
				}
				foreach line $lines {
					puts $zit $line
				}
				close $zit
				set cmd [file join $evv(CDPROGRAM_DIR) newmix]
				lappend cmd multichan $mixfile $ofnam
				set origcmd $cmd
				set CDPidrun 0
				set prg_dun 0
				set prg_abortd 0
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "Failed to run mix of panned channels"
					UnBlock
					set finished 1
					break
   				} else {
   					fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				if {!$prg_dun} {
					Inf "Failed to mix the panned channels"
					UnBlock
					set finished 1
					break
				}
				if {![file exists $ofnam]} {
					Inf "No mixed soundfile created"
					UnBlock
					set finished 1
					break
				}

				wm title .blocker "PLEASE WAIT:        Checking level of output"
				set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
				lappend cmd $ofnam
				set prg_dun 0
				set prg_abortd 0
				set done_maxsamp 0
				catch {unset maxsamp_line}
				if [catch {open "|$cmd"} CDPmaxId] {
					catch {unset CDPmaxId}
					Inf "Failed to find (and adjust) maximum level of output : $CDPmaxId"
					UnBlock
					set finished 1
					break
				} else {
					fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
				}
				vwait done_maxsamp
				if {!$done_maxsamp || ![info exists maxsamp_line]} {
					set msg "Failure to find (and adjust) maximum level of output"
					ErrShow $msg
					UnBlock
					set finished 1
					break
				}
				catch {close CDPmaxId}
				set maxlev [lindex $maxsamp_line 0]
				if {$maxlev <= 0.0} {
					set msg "Zero level output file"
					ErrShow $msg
					UnBlock
					set finished 1
					break
				}
				set k 0
				set dogain 1
				while {$maxlev > 0.95} {
					incr k
					catch {close $CDPidrun}
					set dogain [expr $dogain * 0.1]
					set gain -g$dogain
					wm title .blocker "PLEASE WAIT:        Remixing for better level : pass $k : gain $dogain"
					if [catch {file delete $ofnam} zit] {
						Inf "Cannot delete original mix : pass $k : $zit"
						set OK 0
						break
					}
					set cmd $origcmd
					lappend cmd $gain
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					if [catch {open "|$cmd"} CDPidrun] {
						catch {unset CDPidrun}
						ErrShow "Cannot do new remix of file : pass $k:  gain $dogain"
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
						set msg "Failed to do new remix $k of file:"
						set msg [AddSimpleMessages $msg]
						ErrShow $msg
						set OK 0
						break
					}
					if {![file exists $ofnam]} {
						Inf "NO OUTPUT FILE GENERATED ON PASS $k"
						set OK 0
						break
					}
					wm title .blocker "PLEASE WAIT:        Checking level of output"
					set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
					lappend cmd $ofnam
					set prg_dun 0
					set prg_abortd 0
					set done_maxsamp 0
					catch {unset maxsamp_line}
					if [catch {open "|$cmd"} CDPmaxId] {
						catch {unset CDPmaxId}
						Inf "Failed to find (and adjust) maximum level of output : $CDPmaxId"
						set OK 0
						break
					} else {
						fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
					}
					vwait done_maxsamp
					if {!$done_maxsamp || ![info exists maxsamp_line]} {
						set msg "Failure to find (and adjust) maximum level of output"
						ErrShow $msg
						set OK 0
						break
					}
					catch {close CDPmaxId}
					set maxlev [lindex $maxsamp_line 0]
				}
				if {!$OK} {
					UnBlock
					set finished 1
					break
				}
				set x 0
				after 1000 {set x 1}
				vwait x
				while {$OK} {
					if {$k && ($maxlev < 0.9)} {
						set gain -g
						set dogain [expr $dogain * (0.95/$maxlev)]
						append gain $dogain
						wm title .blocker "PLEASE WAIT:        Remixing for better level : pass $k gain $dogain"
						if [catch {file delete $ofnam} zit] {
							Inf "Cannot delete original mix : pass $k : $zit"
							set OK 0
							break
						}
						set cmd $origcmd
						lappend cmd $gain
						set prg_dun 0
						set prg_abortd 0
						catch {unset simple_program_messages}
						if [catch {open "|$cmd"} CDPidrun] {
							catch {unset CDPidrun}
							ErrShow "Cannot do new remix of file : pass $k: $CDPidrun"
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
							set msg "Failed to do new remix $k of file:"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							set OK 0
							break
						}
						if {![file exists $ofnam]} {
							Inf "No output file generated on pass $k"
							set OK 0
							break
						}
					}
					break
				}
				if {!$OK} {
					UnBlock
					set finished 1
					break
				}
				if {[FileToWkspace $ofnam 0 0 0 0 1] > 0} {
					Inf "File $ofnam is on the worksapce"
				}
				.eightone.0.pp config -bd 2 -text "Play" -command "set pr_eightone 2" -bg $evv(EMPH)
				.eightone.0.vv config -bd 2 -text "View" -command "set pr_eightone 3" -bg $evv(SNCOLOR)
				bind $f <Return> {set pr_eightone 2}
				UnBlock
				continue
			}
			2 {
				if {![file exists $ofnam]} {
					Inf "No soundfile to play"
					continue
				}	
				PlaySndfile $ofnam 0			;# PLAY OUTPUT
				continue
			} 
			3 {
				if {![file exists $ofnam]} {
					Inf "No soundfile to view"
					continue
				}
				if {![info exists pa($ofnam,$evv(CHANS))]} {
					set CDPid 0
					set props_got 0
					set parse_error 0
					set cmd [file join $evv(CDPROGRAM_DIR) cdparse]
					if [catch {open "|$cmd $ofnam $parse_the_max"} CDPid] {
						ErrShow "Cdparse program failed to run"
						catch {unset CDPid}
						continue
					} else {
						set propslist ""
						fileevent $CDPid readable AccumulateFileProps
					}
					vwait props_got
					if {$parse_error} {
						ErrShow "Cdparse program failed"
						continue
					}
					if [info exists propslist] {
						set propno 0
						foreach prop $propslist {
							set pa($ofnam,$propno) $prop
							incr propno
						}
					}
				}
				SnackDisplay 0 $evv(SN_FILE_PRMPAGE_NO_OUTPUT) 0 $ofnam
				continue
			}
			0 {
				set finished 1
			}
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc PlayCh {} {
	global chlist wl pa evv pr_playch playch_ch CDPidrun CDPid prg_dun prg_abortd props_got parse_error

	if {[info exists chlist] && ([llength $chlist] == 1)} {
		set fnam [lindex $chlist 0]
		if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) < 2)} {
			unset fnam
		}
	}
	if {![info exists fnam]} {
		set i [$wl curselection]
		if {[info exists i] && ([llength $i] == 1) && ($i != -1)} {
			set fnam [$wl get $i]
			if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) < 2)} {
				unset fnam
			}
		}
	}
	if {![info exists fnam]} {
		Inf "Select a single stereo or multichannel file"
		return
	}
	set chans $pa($fnam,$evv(CHANS))
	set ofnam $evv(DFLT_OUTNAME)
	append ofnam 0 $evv(SNDFILE_EXT)
	if [catch {file copy $fnam $ofnam} zit] {
		Inf "Failed to make temporary copy of file [file rootname [file tail $fnam]]"
		return
	}
	set f .playch
	if [Dlg_Create $f "Play single channel of snd" "set pr_playch 0" -borderwidth 2 -width 84] {
		frame $f.0
		button $f.0.qu -text "Quit" -command "set pr_playch 0" -width 5 -highlightbackground [option get . background {}]
		button $f.0.pp -text "Play" -command "set pr_playch 1" -width 5 -bg $evv(EMPH) -highlightbackground [option get . background {}]
		pack $f.0.pp -side left -padx 4
		pack $f.0.qu -side right
		pack  $f.0 -side top -fill x -expand true
		label $f.01 -text "Channel to play"
		pack $f.01 -side top -pady 2
		set n 1
		frame $f.1
		while {$n <= 8} {
			radiobutton $f.1.$n -text $n -value $n -variable playch_ch -width 6
			pack $f.1.$n -side left 
			incr n
		}
		pack $f.1 -side top 
		frame $f.2
		while {$n <= 16} {
			radiobutton $f.2.$n -text $n -value $n -variable playch_ch -width 6
			pack $f.2.$n -side left 
			incr n
		}
		pack $f.2 -side top
		set playch_ch 0
		wm resizable $f 1 1
		bind $f <Return> {set pr_playch 1}
		bind $f <Escape> {set pr_playch 0}
	}
	set k 16
	while {$k > $chans} {
		if {$k > 8} {
			.playch.2.$k config  -text "" -state disabled
		} else {
			.playch.1.$k config  -text "" -state disabled
		}
		incr k -1
	}
	while {$k > 0} {
		if {$k > 8} {
			.playch.2.$k  config  -text $k -state normal
		} else {
			.playch.1.$k  config  -text $k -state normal
		}
		incr k -1
	}
	set pr_playch 0
	update idletasks
	raise $f
	update idletasks
	My_Grab 0 $f pr_playch $f
	update idletasks
	set finished 0
	while {!$finished} {
		tkwait variable pr_playch
		switch -- $pr_playch {
			1 {
				if {![info exists last_playch_ch] || ($last_playch_ch != $playch_ch)} {
					DeleteAllTemporaryFilesExcept $ofnam
					if {$playch_ch <= 0} {
						Inf "No channel specified"
						continue
					}
					set cfnam [file rootname $ofnam]
					append cfnam "_c" $playch_ch $evv(SNDFILE_EXT)
					Block "Extracting Channel $playch_ch"
					set cmd [file join $evv(CDPROGRAM_DIR) housekeep]
					lappend cmd chans 1 $ofnam $playch_ch
					set CDPidrun 0
					set prg_dun 0
					set prg_abortd 0
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "Failed to run channel extraction process"
						UnBlock
						continue
   					} else {
   						fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
					}
					vwait prg_dun
					if {$prg_abortd} {
						set prg_dun 0
					}
					if {!$prg_dun} {
						Inf "Failed to extract channel $playch_ch from file [file rootname [file tail $fnam]]"
						UnBlock
						continue
					}
					if {![file exists $cfnam]} {
						Inf "No channel extracted"
						UnBlock
						continue
					}
					set pa($cfnam,$evv(CHANS)) 1
					UnBlock
				}
				PlaySndfile $cfnam 0			;# PLAY OUTPUT
				set last_playch_ch $playch_ch
				continue
			} 
			0 {
				set finished 1
			}
		}
	}
	catch {unset pa($cfnam,$evv(CHANS))}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Reorder channels in stereo or multichannel file

proc EightToEight {} {
	global chlist wl evv pa pr_eitoei eiei_order eiei_ofnam CDPidrun prg_dun prg_abortd wstk

	if {[info exists chlist] && ([llength $chlist] == 1)} {
		set fnam [lindex $chlist 0]
		if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) < 2)} {
			unset fnam
		} else {
			set chans $pa($fnam,$evv(CHANS))
		}
	} 
	if {![info exists fnam]} {
		set ilist [$wl curselection]
		if {[info exists ilist] && ([llength $ilist] == 1) && ($ilist != -1)} {
			set i [lindex $ilist 0]
			set fnam [$wl get $i]
		}
		if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) < 2)} {
			unset fnam
		} else {
			set chans $pa($fnam,$evv(CHANS))
		}
	}
	if {![info exists fnam]} {
		Inf "Select a single soundfile with more than one channel"
		return
	}
	set xfnam $evv(DFLT_OUTNAME)
	append xfnam 0 $evv(SNDFILE_EXT)
	if [catch {file copy $fnam $xfnam} zit] {
		Inf "Failed to copy file [file rootname [file tail $fnam]] to temporary file : $zit"
		return
	}
	set f .eitoei
	if [Dlg_Create $f "Rearrange channels" "set pr_eitoei 0" -borderwidth 2 -width 84] {
		frame $f.0
		button $f.0.qu -text "Quit" -command "set pr_eitoei 0" -width 5 -highlightbackground [option get . background {}]
		button $f.0.pp -text "Rearrange" -command "set pr_eitoei 1" -width 10 -bg $evv(EMPH) -highlightbackground [option get . background {}]
		pack $f.0.pp -side left
		pack $f.0.qu -side right
		pack  $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "New Channel Order"
		entry $f.1.ch -textvariable eiei_order -width 40
		pack $f.1.ch $f.1.ll -side left
		pack $f.1 -side top -pady 2
		label $f.2 -text "List all chans (1 to N) in their new order" -fg $evv(SPECIAL) -width 45
		pack $f.2 -side top -pady 4
		label $f.3 -text "leaving spaces between channel-numbers" -fg $evv(SPECIAL) -width 45
		pack $f.3 -side top -pady 4
		frame $f.4
		label $f.4.ll -text "Output filename"
		entry $f.4.nn -textvariable eiei_ofnam -width 40
		pack $f.4.nn $f.4.ll -side left
		pack $f.4 -side top -pady 2
		bind $f <Return> {set pr_eitoei 1}
		bind $f <Escape> {set pr_eitoei 0}
	}
	if {$chans > 2} {
		$f.2 config -text "List all chans (1 to $chans) in their new order"
		$f.3 config -text "leaving spaces between channel-numbers"
		$f.1.ll config -text "New Channel Order"
		$f.1.ch config -bd 2 -state normal
	} else {
		$f.2 config -text ""
		$f.3 config -text "Channels will be swapped"
		$f.1.ll config -text ""
		$f.1.ch config -bd 0 -state disabled -disabledbackground [option get . background ()]
	}
	set eiei_ofnam [file rootname [file tail $fnam]]
	append eiei_ofnam "_nu"
	set pr_eitoei 0
	update idletasks
	raise $f
	update idletasks
	if {$chans > 2} {
		My_Grab 0 $f pr_eitoei $f.1.ch
	} else {
		My_Grab 0 $f pr_eitoei $f.4.nn
	}
	update idletasks
	set finished 0
	while {!$finished} {
		tkwait variable pr_eitoei
		switch -- $pr_eitoei {
			1 {
				DeleteAllTemporaryFilesExcept $xfnam
				if {[string length $eiei_ofnam] <= 0} {
					Inf "No outputfile name entered"
					continue
				}
				set ofnam [string tolower $eiei_ofnam]
				if {![ValidCDPRootname $ofnam]} {
					continue
				}
				append ofnam $evv(SNDFILE_EXT)
				if {[file exists $ofnam]} {
					Inf "File $ofnam already exists: please choose a different name"
					continue
				}
				
				if {$chans == 2} {
					set orderstring [list 2 1]
				} else {
					set eiei_order [string trim $eiei_order]
					if {([string length $eiei_order] <= 0) || ![regexp {^[0-9\ \t]+$} $eiei_order]} {
						Inf "Invalid reordering string ($eiei_order) : use only channel numbers and spaces"
						continue
					}
					set eiei_order [split $eiei_order]
					set OK 1
					set OK2 1
					catch {unset orderstring}
					set is_warned 0
					while {$OK} {
						foreach item $eiei_order {
							set item [string trim $item]
							if {[string length $item] <= 0} {
								continue
							}
							if {![IsNumeric $item]} {
								Inf "Element ($item) in order-string is not numeric"
								set OK2 0
								set OK 0
								break
							}
							if {($item < 1) || ($item > $chans)} {
								Inf "Channel-number ($item) in order-string out of range (1 to $chans)"
								set OK2 0
								set OK 0
								break
							}
							if {[info exists orderstring]} {
								if {!$is_warned} {
									if {[lsearch $orderstring $item] >= 0} {
										set msg "Item ($item) in the order-string is duplicated : do you want to duplicate channels ??"
										set choice [tk_messageBox -type yesno -icon question  -parent [lindex $wstk end] -message $msg]
										if {$choice == "no"} {
											set OK2 0
											set OK 0
											break
										} else {
											set is_warned 1
										}
									}
								}
							}
							lappend orderstring $item
						}
						if {!$OK} {
							break
						}
						if {![info exists orderstring]} {
							Inf "No (valid) items found in order-string"
							set OK2 0
							break
						}
						if {[llength $orderstring] != $chans} {
							Inf "Wrong number ([llength $orderstring]) of items in the order-string (should be $chans)"
							set OK2 0
						}
						set OK 0
					}
					if {!$OK2} {
						continue
					}
				}
				Block "Separating Channels"
				set cmd [file join $evv(CDPROGRAM_DIR) housekeep]
				lappend cmd chans 2 $xfnam
				set CDPidrun 0
				set prg_dun 0
				set prg_abortd 0
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "Failed to run channel extraction process"
					UnBlock
					continue
   				} else {
   					fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				if {!$prg_dun} {
					Inf "Failed to extract channels from file [file rootname [file tail $fnam]]"
					UnBlock
					continue
				}
				set n 1
				set OK 1
				catch {unset $ochans}
				while {$n <= $chans} {
					set cfnam [file rootname $xfnam]
					append cfnam "_c" $n $evv(SNDFILE_EXT)
					if {![file exists $cfnam]} {
						Inf "No channel $n extracted"
						set OK 0
						break
					}
					lappend ochans $cfnam
					incr n
				}
				if {!$OK} {
					UnBlock
					continue
				}
				set nuochans {}
				foreach k $orderstring {
					lappend nuochans x
				}
				foreach k $orderstring item $ochans {
					set kk [expr $k - 1]
					set nuochans [lreplace $nuochans $kk $kk $item]
				}
				wm title .blocker "PLEASE WAIT:        Re-merging reordered channels"
				set cmd [file join $evv(CDPROGRAM_DIR) submix]
				lappend cmd interleave
				set cmd [concat $cmd $nuochans]
				lappend cmd $ofnam
				set CDPidrun 0
				set prg_dun 0
				set prg_abortd 0
				if [catch {open "|$cmd"} CDPidrun] {
					Inf "Failed to run channel merge process"
					UnBlock
					continue
   				} else {
   					fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				if {!$prg_dun} {
					Inf "Failed to re-merge channels extracted from original file"
					UnBlock
					continue
				}
				if {![file exists $ofnam]} {
					Inf "NO MERGED OUTPUT FILE CREATED"
					UnBlock
					continue
				}
				if {[FileToWkspace $ofnam 0 0 0 0 1] > 0} {
					Inf "File $ofnam is on the workspace"
				} else {
					Inf "File $ofnam has been created, but is not yet on the workspace"
				}
				UnBlock
				set finished 1
			}
			0 {
				set finished 1
			}
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Play stereo file in Wide stereo

proc PlayChWide {} {
	global sysoutchans chlist wl pa evv pr_playchw playchw_ll playchw_rr CDPidrun CDPid prg_dun prg_abortd playcmd_dummy wstk

	if {![info exists sysoutchans]} {
		GetSysPlayChans
	}
	if {![info exists sysoutchans]} {
		return
	}
	if {[info exists chlist] && ([llength $chlist] == 1)} {
		set fnam [lindex $chlist 0]
		if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) != 2)} {
			unset fnam
		}
	}
	if {![info exists fnam]} {
		set i [$wl curselection]
		if {[info exists i] && ([llength $i] == 1) && ($i != -1)} {
			set fnam [$wl get $i]
			if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) != 2)} {
				unset fnam
			}
		}
	}
	if {![info exists fnam]} {
		Inf "Select a single stereo file"
		return
	}
	set ofnam $evv(DFLT_OUTNAME)
	append ofnam 0 $evv(SNDFILE_EXT)
	set mfnam $evv(DFLT_OUTNAME)
	append mfnam 0 [GetTextfileExtension mmx]
	set f .playchw
	if [Dlg_Create $f "Play stereo in wide format" "set pr_playchw 0" -borderwidth 2 -width 84] {
		frame $f.0
		button $f.0.qu -text "Quit" -command "set pr_playchw 0" -width 5 -highlightbackground [option get . background {}]
		button $f.0.pp -text "Play" -command "set pr_playchw 1" -width 5 -bg $evv(EMPH) -highlightbackground [option get . background {}]
		pack $f.0.pp -side left -padx 4
		pack $f.0.qu -side right
		pack  $f.0 -side top -fill x -expand true
		label $f.01 -text "Play Left channel on channel ...."
		pack $f.01 -side top -pady 2
		set n 1
		frame $f.1
		while {$n <= 8} {
			radiobutton $f.1.$n -text $n -value $n -variable playchw_ll -width 6
			pack $f.1.$n -side left 
			incr n
		}
		pack $f.1 -side top 
		frame $f.2
		while {$n <= 16} {
			radiobutton $f.2.$n -text $n -value $n -variable playchw_ll -width 6
			pack $f.2.$n -side left 
			incr n
		}
		pack $f.2 -side top

		label $f.02 -text "Play Right channel on channel ...."
		pack $f.02 -side top -pady 2
		set n 1
		frame $f.3
		while {$n <= 8} {
			radiobutton $f.3.$n -text $n -value $n -variable playchw_rr -width 6
			pack $f.3.$n -side left 
			incr n
		}
		pack $f.3 -side top 
		frame $f.4
		while {$n <= 16} {
			radiobutton $f.4.$n -text $n -value $n -variable playchw_rr -width 6
			pack $f.4.$n -side left 
			incr n
		}
		pack $f.4 -side top
		set playchw_ll 0
		set playchw_rr 0
		wm resizable $f 1 1
		bind $f <Return> {set pr_playchw 1}
		bind $f <Escape> {set pr_playchw 0}
	}
	set k 16
	while {$k > $sysoutchans} {
		if {$k > 8} {
			.playchw.2.$k config  -text "" -state disabled
			.playchw.4.$k config  -text "" -state disabled
		} else {
			.playchw.1.$k config  -text "" -state disabled
			.playchw.3.$k config  -text "" -state disabled
		}
		incr k -1
	}
	while {$k > 0} {
		if {$k > 8} {
			.playchw.2.$k  config  -text $k -state normal
			.playchw.4.$k  config  -text $k -state normal
		} else {
			.playchw.1.$k  config  -text $k -state normal
			.playchw.3.$k  config  -text $k -state normal
		}
		incr k -1
	}
	set pr_playchw 0
	update idletasks
	raise $f
	update idletasks
	My_Grab 0 $f pr_playchw $f
	update idletasks
	set finished 0
	while {!$finished} {
		tkwait variable pr_playchw
		switch -- $pr_playchw {
			1 {
				DeleteAllTemporaryFiles
				if {!$playchw_ll} {
					if {!$playchw_rr} {
						Inf "No output play channels specified"
						continue
					} else {
						Inf "No left output play channel specified"
						continue
					}
				} elseif {!$playchw_rr} {
					Inf "NO Right output play channel specified"
					continue
				}
				if {$playchw_rr == $playchw_ll} {
					Inf "Output play channels are the same for left and right"
					continue
				}
				catch {unset lines}
				set line $sysoutchans
				lappend lines $line
				set line [list $fnam 0.0 2 1:$playchw_ll 1.0 1:$playchw_rr 1.0 ]
				lappend lines $line
				if [catch {open $mfnam "w"} zit] {
					Inf "Cannot open temporary mix file to generate wide output"
					continue
				}
				foreach line $lines {
					puts $zit $line
				}
				close $zit
				set OK 1
				Block "Creating wide stereo"
				while {$OK} {
					set cmd [file join $evv(CDPROGRAM_DIR) newmix]
					lappend cmd multichan $mfnam $ofnam
					set CDPidrun 0
					set prg_dun 0
					set prg_abortd 0
					if [catch {open "|$cmd"} CDPidrun] {
						Inf "Failed to run widening mix"
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
						Inf "Failed to create the wide image"
						set OK 0
						break
					}
					if {![file exists $ofnam]} {
						Inf "No wide stereo created"
						set OK 0
						break
					}
					break
				}
				if {!$OK} {
					UnBlock
					continue
				}
				set is_playing 0
				set choice "yes"
				while {$choice == "yes"} {
					set is_playing 1
					PlaySndfile $ofnam 0			;# PLAY OUTPUT
					set msg "Hear it again ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				} 
				if {$is_playing && ($playcmd_dummy != "pvplay")} {
					Inf "If there is a play-program display\nyou must close it before proceeding!!"
				}
				UnBlock
				set finished 1
			} 
			0 {
				set finished 1
			}
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc GetSysPlayChans {} {
	global sysoutchans pr_sysch evv sysoutch wstk
	set fnam [file join $evv(URES_DIR) sysoutch$evv(CDP_EXT)]
	if {[file exists $fnam]} {
		if {[LoadSysPlayChans]} {
			return
		}
	}		
	set f .sysoutch
	if [Dlg_Create $f "Specify system's channel-output-count" "set pr_sysch 0" -borderwidth 2 -width 84] {
		frame $f.0
		button $f.0.qu -text "Quit" -command "set pr_sysch 0" -width 5 -highlightbackground [option get . background {}]
		button $f.0.pp -text "Specify" -command "set pr_sysch 1" -width 8 -bg $evv(EMPH) -highlightbackground [option get . background {}]
		pack $f.0.pp -side left -padx 4
		pack $f.0.qu -side right
		pack  $f.0 -side top -fill x -expand true
		label $f.01 -text "System's output-channel-count"
		pack $f.01 -side top -pady 2
		set n 1
		frame $f.1
		radiobutton $f.1.2  -text 2  -value 2  -variable sysoutch -width 6
		radiobutton $f.1.4  -text 4  -value 4  -variable sysoutch -width 6
		radiobutton $f.1.5  -text 5  -value 5  -variable sysoutch -width 6
		radiobutton $f.1.7  -text 7  -value 7  -variable sysoutch -width 6
		radiobutton $f.1.8  -text 8  -value 8  -variable sysoutch -width 6
		radiobutton $f.1.16 -text 16 -value 16 -variable sysoutch -width 6
		pack $f.1.2 $f.1.4 $f.1.5 $f.1.7 $f.1.8 $f.1.16 -side left
		pack $f.1 -side top 
		set sysoutch 0
		wm resizable $f 1 1
		bind $f <Return> {set pr_sysch 1}
		bind $f <Escape> {set pr_sysch 0}
	}
	if {[info exists sysoutchans]} {
		set sysoutch $sysoutchans
	} else {
		set sysoutch 0
	}	
	set pr_sysch 0
	update idletasks
	raise $f
	update idletasks
	My_Grab 0 $f pr_sysch $f
	update idletasks
	set finished 0
	while {!$finished} {
		tkwait variable pr_sysch
		switch -- $pr_sysch {
			1 {
				if {$sysoutch <= 0} {
					Inf "No system output-channel-count specified"
					continue
				}
				set sysoutchans $sysoutch
				if [catch {open $fnam "w"} zit] {
					Inf "Cannot open file [file tail $ofnam] to store system's channel-output-count"
					continue
				}
				puts $zit $sysoutchans
				Inf "System's channel-output-count stored"
				set finished 1
			} 
			0 {
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc LoadSysPlayChans {} {
	global sysoutchans pr_sysch evv sysoutch wstk
	set fnam [file join $evv(URES_DIR) sysoutch$evv(CDP_EXT)]
	if {[file exists $fnam]} {
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot open file [file tail $fnam] to read system's channel-output-count"
		} else {
			set got 0
			while {[gets $zit line] >= 0} {
				set line [string trim $line]
				if {[string length $line] <= 0} {
					continue
				}
				set line [split $line]
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] <= 0} {
						continue
					}
					set got 1
					break
				}
				if {$got} {
					break
				}
			}
			if {$got} {
				if {($item == "2") || ($item == "4") || ($item == "5") || ($item == "7") || ($item == "8") || ($item == "16")} { 
					set sysoutchans $item
					return 1
				}
			}
		}
	} 		
	return 0
}
