#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD 30 June 2013
# ... fixup button rectangles

###########
# GENERAL #
###########

#--- Check if user has selected a single property-file, and if so, extract data and return filename

proc SelectedFileIsAPropertyFile {goti i} {
	global wl chlist evv
	if {!$goti} {
		set i [$wl curselection]
		if {![info exists i] || ([llength $i] <= 0)} {
			if {[info exists chlist]} {
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
					set i [$wl curselection]
				}
			}
		}
	}
	if {![info exists i] || ([llength $i] <= 0)} {
		Inf "No Workspace Files Selected"
		return ""
	}
	if {([llength $i] != 1) || ($i == -1)} {
		set msg "Select Just A Property File On The Workspace\n"
		append msg "Or Place It On The Chosen Files List, If In Choosen Files Mode"
		Inf $msg
		return ""
	}
	set fnam [$wl get $i]
	set ftyp [FindFileType $fnam]
	if {!($ftyp & $evv(IS_A_TEXTFILE))} {
		Inf "Select A Property File."
		return ""
	}
	if {![ThisIsAPropsFile $fnam 1 0]} {
		return ""
	}
	return $fnam
}

#--- Is this a properties file ??

proc IsThisAPropsFile {propfnam} {
	global propfiles_list wstk propdir evv old_props_protocol
	if {$old_props_protocol} {
		GetPropFileDir
	}
	if [catch {open $propfnam "r"} zit] {
		return 0
	}
	while {[gets $zit line] >= 0} {
		lappend propfile $line
	}
	close $zit
	if {![info exists propfile] || ([llength $propfile] < 2)} {
		return 0
	}
	set linecnt 0
	set itemcnt 0
	set sndcnt 0
	foreach line $propfile {
		set thisline_itemcnt 0
		catch {unset nuline}
		set line [string trim $line]
		set line [split $line]
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend nuline $item
				incr thisline_itemcnt
			}
		}
		if {$thisline_itemcnt > 0} {
			if {$linecnt == 0} {			;# FIRST LINE, SPECIAL CASE FOR PROPS FILES
				set theseprops $nuline
				set itemcnt $thisline_itemcnt
				incr itemcnt	;# lines to follow have filename, as well as props (if they're property files)
			} else {
				if {$thisline_itemcnt != $itemcnt} {
					return 0
				}
				set thisfnam [lindex $nuline 0]
				if {$old_props_protocol} {
					if {![string match [file tail $thisfnam] $thisfnam]} {
						return 0
					}
					set thisfnam [file join $propdir $thisfnam]
				} else {
					if {[string match [file tail $thisfnam] $thisfnam]} {
						return 0
					}
				}
				if {![file exists $thisfnam]} {
					return 0
				} elseif {[FindFileType $thisfnam] != $evv(SNDFILE)} {
					return 0
				} else {
					incr sndcnt
				}
			}
			lappend nupropfile $nuline
			incr linecnt 
		}
	}
	if {($linecnt <= 0) || ($sndcnt == 0)} {
		return 0
	}
	return 1
}

################################################################
# SORT FILES BY ARBITRARY PROPERTIES USING NON-TABLE INTERFACE #
################################################################

# PROBLEM: When put onto the CHOSEN FILE LIST, IF ANOTHER WORKSPACE IS RESTORED
#			then we go to PREVIOUS LIST, we don't get the property-files list
#			(this suggests 'Restore' is not remembering the list it restores OVER


# A property file has lines consisting of
# A title line, having the names of the properties, followed by
# Sndfile-name + list-of-arbitrary-properties..
# Properties in same column correspond

proc Do_Props {ofsnds} {
	global prop_sellist pr_props proplisting old_proplist wstk pa evv old_props_protocol
	global propch propchv last_propchv prop_fname wl orig_propfile propname propfile propcnt propfcnt
	global mark_list all_mark_list prop_name_swap text_search pr_mu propfiles_list ch chlist chcnt readonlyfg readonlybg

	set prop_name_swap 0
	catch {unset orig_propfile}
	catch {unset propfile}
	set i [$wl curselection]
	if {$i < 0} {
		if {[info exists chlist]} {
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
				set i [$wl curselection]
			}
		}
	}

	if {[string length $i] <= 0} {
		Inf "No File Selected"
		return
	}
	if {$ofsnds == 1} {
		if {[llength $i] < 2} {
			Inf "Choose Just One Property File And At Least One Soundfile"
			return
		}
		catch {unset propfile}
		set bigmsg "Choose Only One (User-Property) Textfile & Soundfiles Mentioned In The Props-File\n\nOr\n\nOne Property File And A Textfile Listing Those Soundfiles"
		set got_sounddir 0
		set got_propfile 0
		set got_sndlist 0
		set ilist $i
		Block "Checking File Consistency"
		foreach i $ilist {
			set fnam [$wl get $i]
			if {$pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)} {
				if {[IsASndlist $pa($fnam,$evv(FTYP))]} {
					if {[info exists in_sndfiles]} {
						Inf $bigmsg
						UnBlock
						return
					}
					if [catch {open $fnam "r"} zit] {
						Inf "Cannot Open Text File '$fnam'"
						UnBlock
						return
					}
					while {[gets $zit sfnam] >= 0} {
						if {$old_props_protocol} {
							if {$got_sounddir} {
								if {![string match [file dirname $sfnam] $filedir]} {
									Inf "Soundfiles Chosen Are Not All In The Same Directory"
									close $zit
									UnBlock
									return
								}
							} else {
								set filedir [file dirname $sfnam]
								set got_sounddir 1
							}
						} else {
							if {[string match $sfnam [file tail $sfnam]]} {
								Inf "Soundfile '$sfnam' Is Not Backed Up To A Directory"
								close $zit
								UnBlock
								return
							}
						}
						lappend in_sndfiles $sfnam
					}
					close $zit
					if {[llength $ilist] > 2} {
						Inf $bigmsg
						UnBlock
						return
					}
					set got_sndlist 1
					if {$got_propfile} {
						break
					} else {
						continue
					}
				}
				if {$got_propfile} {					;#	IF ALREADY FOUND A PROPFILE
					Inf $bigmsg
					UnBlock
					return
				}
				if {![info exists propfiles_list]} {
					set is_a_known_propfile -1
				} else {
					set is_a_known_propfile [lsearch $propfiles_list $fnam]
				}
				if [catch {open $fnam "r"} zit] {
					Inf "Cannot Open Text File '$fnam'"
					UnBlock
					return
				}
				while {[gets $zit line] >= 0} {
					lappend propfile $line
				}
				if {![info exists propfile]} {
					Inf "File '$fnam' Is Empty"
					if {$is_a_known_propfile >= 0} {
						set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
					}
					close $zit
					UnBlock
					return
				}
				if {[llength $propfile] < 2} {
					Inf "'$fnam' Is Not A Valid Properties File"
					if {$is_a_known_propfile >= 0} {
						set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
					}
					close $zit
					UnBlock
					return
				}
				set orig_propfile_name $fnam
				close $zit
				set linecnt 0
				set propcnt 0
				foreach line $propfile {
					set this_propcnt 0
					catch {unset nuline}
					set line [string trim $line]
					set line [split $line]
					foreach item $line {
						set item [string trim $item]
						if {[string length $item] > 0} {
							lappend nuline $item
							incr this_propcnt
						}
					}
					if {$this_propcnt > 0} {
						if {$linecnt == 0} {			;# FIRST LINE, SPECIAL CASE FOR PROPS FILES
							set propcnt $this_propcnt
							incr propcnt	;# lines to follow have filename, as well as props (if they're property files)
						} elseif {$propcnt != $this_propcnt} {
							Inf "Number Of Properties Incorrect On Line [expr $linecnt + 1]"
							if {$is_a_known_propfile >= 0} {
								set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
							}
							UnBlock
							return
						} else {
							set z_fnam [lindex $nuline 0]
							if {$old_props_protocol} {
								if {![string match $z_fnam [file tail $z_fnam]]} {
									Inf "Sound File Directories Found In File: Will Not Work With Old Protocol"
									if {$is_a_known_propfile >= 0} {
										set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
									}
									UnBlock
									return
								}
							} else { 
								if {[string match $z_fnam [file tail $z_fnam]]} {
									Inf "Sounds Without Directory Paths Found: Will Not Work With New Protocol"
									if {$is_a_known_propfile >= 0} {
										set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
									}
									UnBlock
									return
								}
							}
						}
						lappend nupropfile $nuline
						incr linecnt 
					}
				}
				if {$linecnt <= 0} {
					Inf "No Values Found In File"
					if {$is_a_known_propfile >= 0} {
						set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
					}
					UnBlock
					return
				}
				if {$propcnt > 21} {
					Inf "Cannot Handle More Than 20 Properties: Ignoring Other Properties"
					catch {unset propfile}

					set line [lrange [lindex $nupropfile 0] 0 19]
					lappend propfile $line
				
					foreach line [lrange $nupropfile 1 end] {
						set line [lrange $line 0 20]
						lappend propfile $line
					}
					set nupropfile $propfile
					set propcnt 21
				}
				set n 1
				foreach item [lindex $nupropfile 0] {
					if {[string length $item] > 8} {
						set item [string range $item 0 7]
					}
					set propname($n) $item
					incr n
				}
				set propfile [lrange $nupropfile 1 end]
				incr linecnt -1
				if {$linecnt <= 0} {
					Inf "No Properties (Only Property Names) Found In File"
					if {$is_a_known_propfile >= 0} {
						set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
					}
					UnBlock
					return
				}
				set got_propfile 1
				if {$is_a_known_propfile < 0} {		;# IF file not previously known as a propfile, add it to list of known profiles
					AddToPropfilesList $fnam
				}
				set this_propfile $fnam
				if {$got_sndlist} {
					if {[llength $ilist] > 2} {
						Inf $bigmsg
						UnBlock
						return
					} else {
						break
					}
				}
			} elseif {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
				Inf $bigmsg
				UnBlock
				return
			} else {
				if {$old_props_protocol} {
					if {$got_sounddir} {
						if {$got_sndlist} {
							Inf $bigmsg
							UnBlock
							return
						}
						if {![string match [file dirname $fnam] $filedir]} {
							Inf "Soundfiles Chosen Are Not All In The Same Directory"
							UnBlock
							return
						}
					} else {
						set filedir [file dirname $fnam]
						set got_sounddir 1
					}
				} else {	
					if {[string match $fnam [file tail $fnam]]} {
						Inf "Soundfile '$fnam' Is Not Backed Up To A Directory"
						UnBlock
						return
					}
				}
				lappend in_sndfiles $fnam
			}
		}
		if {$old_props_protocol} {
			if {([string length $filedir] > 0) && ![string match [string index $filedir 0] "."]} {
				InsertFileDirProps $filedir $linecnt
			}
		}
		set in_shadow $in_sndfiles
		set n 0
		while {$n < $linecnt} {
			set thisline [lindex $propfile $n]
			set fnam [lindex $thisline 0]
			if {![file exists $fnam] || [file isdirectory $fnam]} {
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
					-message "Either\nFiles Selected On Workspace Are In A Different Directory To Those In The Property File\nOr\nFile '$fnam' In The Property File No Longer Exists\n\n\n                                       Do You Want To Proceed??"]
				if {$choice == "no"} {
					UnBlock
					return
				}
				set propfile [lreplace $propfile $n $n]
				incr n -1
				incr linecnt -1
			} elseif {[llength $in_shadow] > 0} {
				set k [lsearch $in_shadow $fnam]
				if {$k >= 0} {
					set in_shadow [lreplace $in_shadow $k $k]
				}
			}
			incr n
		}
		if {$linecnt <= 0} {
			Inf "The Property List Files May All Be In A Different Directory"
			UnBlock
			return
		}
		if {[llength $in_shadow] == [llength $in_sndfiles]} {
			Inf "None Of The Selected Soundfiles Appear In The Properties-File Chosen"
			UnBlock
			return
		}
		if {[llength $in_shadow] > 0} {
			set msg "The Following Selected Sound Files Are Not Mentioned In The Properties-File\n"
			set cnt 0
			foreach fnam $in_shadow {
				if {$cnt > 10} {
					append msg "And More\n"
					break
				}
				append msg $fnam "\n"
				incr cnt
			}
			UnBlock
			return
		}
		set n 0
		set orig_orig_propfile $propfile
		while {$n < $linecnt} {
			set thisline [lindex $propfile $n]
			set fnam [lindex $thisline 0]
			set k [lsearch $in_sndfiles $fnam]
			if {$k < 0} {
				set propfile [lreplace $propfile $n $n]
				incr n -1
				incr linecnt -1
			}
			incr n
		}
	} else {
		if {[llength $i] > 1} {
			Inf "Choose Just One File"
			return
		}
		set fnam [$wl get $i] 
		if {[info exists propfiles_list]} {
			set is_a_known_propfile [lsearch $propfiles_list $fnam]
		} else {
			set is_a_known_propfile  -1
		}
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot Open Properties File '$fnam'"
			return
		}
		set orig_propfile_name $fnam
		while {[gets $zit line] >= 0} {
			lappend propfile $line
		}
		close $zit
		set linecnt 0
		set propcnt 0
		Block "Checking Property List"
		foreach line $propfile {
			set this_propcnt 0
			catch {unset nuline}
			set line [string trim $line]
			set line [split $line]
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] > 0} {
					lappend nuline $item
					incr this_propcnt
				}
			}
			if {$this_propcnt > 0} {
				if {$linecnt == 0} {
					set propcnt $this_propcnt
					incr propcnt	;# lines to follow have filename, as well as props
				} elseif {$propcnt != $this_propcnt} {
					Inf "Number Of Properties Incorrect On Line [expr $linecnt + 1]"
					if {$is_a_known_propfile >= 0} {
						set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
					}
					UnBlock
					return
				} else {
					set z_fnam [lindex $nuline 0]
					if {$old_props_protocol} {
						if {![string match $z_fnam [file tail $z_fnam]]} {
							Inf "Sound File Directories Found In File: Will Not Work With Old Protocol"
							if {$is_a_known_propfile >= 0} {
								set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
							}
							UnBlock
							return
						}
					} else { 
						if {[string match $z_fnam [file tail $z_fnam]]} {
							Inf "Sounds Without Directory Paths Found In File: Will Not Work With New Protocol"
							if {$is_a_known_propfile >= 0} {
								set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
							}
							UnBlock
							return
						}
					}
				}
				lappend nupropfile $nuline
				incr linecnt 
			}
		}
		if {$linecnt <= 0} {
			Inf "No Properties Found In File"
			if {$is_a_known_propfile >= 0} {
				set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
			}
			UnBlock
			return
		}
		if {$propcnt > 21} {
			Inf "Cannot Handle More Than 20 Properties: Ignoring Other Properties"
			catch {unset propfile}

			set line [lrange [lindex $nupropfile 0] 0 19]
			lappend propfile $line
		
			foreach line [lrange $nupropfile 1 end] {
				set line [lrange $line 0 20]
				lappend propfile $line
			}
			set nupropfile $propfile
			set propcnt 21
		}
		set n 1
		foreach item [lindex $nupropfile 0] {
			if {[string length $item] > 8} {
				set item [string range $item 0 7]
			}
			set propname($n) $item
			incr n
		}
		set propfile [lrange $nupropfile 1 end]
		incr linecnt -1
		if {$linecnt <= 0} {
			Inf "No Properties (Only Property Names) Found In File"
			if {$is_a_known_propfile >= 0} {
				set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
			}
			UnBlock
			return
		}
		if {$old_props_protocol} {
			set thisline [lindex $propfile 0]
			set fnam [lindex $thisline 0]
			if {![file exists $fnam] || [file isdirectory $fnam]} {
				set filedir [GetPropFileDir]
				if {[string length $filedir] <= 0} {
					UnBlock
					return
				} else {
					InsertFileDirProps $filedir $linecnt
				}
			}
		}
		set n 0

		while {$n < $linecnt} {
			set thisline [lindex $propfile $n]
			set fnam [lindex $thisline 0]
			if {![file exists $fnam] || [file isdirectory $fnam]} {
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
					-message "File '$fnam' No Longer Exists\n\nDo You Want To Proceed??"]
				if {$choice == "no"} {
					UnBlock
					return
				}
				set propfile [lreplace $propfile $n $n]
				incr n -1
				incr linecnt -1
			}
			incr n
		}
		if {$old_props_protocol} {
			if {$linecnt <= 0} {
				Inf "The Property List Files May All Be In A Different Directory"
				UnBlock
				return
			}
		}
		if {$is_a_known_propfile < 0} {
			AddToPropfilesList $orig_propfile_name
		}
	}
	UnBlock
	if {$ofsnds == 2} {
		set n $linecnt
		incr n -1
		Block "Loading Files"
		while {$n >= 0} {
			set thisline [lindex $propfile $n]
			set fnam [lindex $thisline 0]
			if {[LstIndx $fnam $wl] < 0} {
				set j [FileToWkspace $fnam 0 0 0 0 0]
				if {$j < 0} {
					UnBlock
					return
				} elseif {$j == 0} {
					incr n -1
					continue
				}
			}
			lappend fnamlist $fnam
			incr n -1
		}
		UnBlock
		if {![info exists fnamlist]} {
			Inf "No Files Found."
			return
		}
		set fnamlist [ReverseList $fnamlist]
		DoChoiceBak
		ClearWkspaceSelectedFiles
		foreach fnam $fnamlist {
			$ch insert end $fnam
			lappend chlist $fnam
			incr chcnt
		}
		return
	} elseif {$ofsnds == 3} {
		set n $linecnt
		incr n -1
		Block "Loading Files"
		while {$n >= 0} {
			set thisline [lindex $propfile $n]
			set fnam [lindex $thisline 0]
			if {[LstIndx $fnam $wl] < 0} {
				set j [FileToWkspace $fnam 0 0 0 0 0]
				if {$j < 0} {
					UnBlock
					return
				} elseif {$j == 0} {
					incr n -1
					continue
				}
			}
			lappend fnamlist $fnam
			incr n -1
		}
		UnBlock
		if {![info exists fnamlist]} {
			Inf "No Files Found."
		}
		set k [LstIndx $orig_propfile_name $wl]
		if {$k > 0} {
			$wl delete $k
			$wl insert 0 $orig_propfile_name
			$wl selection clear 0 end
			$wl selection set 0
		}
		return
	}
	catch {unset mark_list}
	catch {unset all_mark_list}
	if {![info exists orig_propfile]} {
		set orig_propfile $propfile
	}
	set f .prop_file
	if [Dlg_Create $f "ORDER SOUNDS BY USER SPECIFIED PROPERTIES" "set pr_props 0" -borderwidth $evv(BBDR)] {
		set f0 [frame $f.0 -borderwidth $evv(BBDR)]
		set fa [frame $f.a -borderwidth $evv(BBDR)]
		set ff [frame $f.f -borderwidth $evv(BBDR)]

		set ff0 [frame $ff.0 -borderwidth $evv(BBDR)]
		set ff1 [frame $ff.1 -borderwidth $evv(BBDR)]

		set ff3 [frame $ff0.3 -borderwidth $evv(BBDR)]
		set ff3a [frame $ff0.3a -borderwidth $evv(BBDR)]
		set ff3b [frame $ff0.3b -borderwidth $evv(BBDR)]
		set ff3c [frame $ff0.3c -borderwidth $evv(BBDR)]

		set ffz [frame $ff1.z -borderwidth $evv(BBDR)]
		set ffza [frame $ff1.za -borderwidth $evv(BBDR)]
		set ffzb [frame $ff1.zb -borderwidth $evv(BBDR)]
		set ffzc [frame $ff1.zc -borderwidth $evv(BBDR)]

		set f01 [frame $f.01 -borderwidth $evv(BBDR)]
		set f0x1 [frame $f.0x1 -borderwidth $evv(BBDR)]
		set f02 [frame $f.02 -bg [option get . foreground {}] -height 1]
		set f2 [frame $f.2 -borderwidth $evv(BBDR)]
		set f4 [frame $f.4 -bg [option get . foreground {}] -height 1]
		set f4a [frame $f.4a -bg [option get . foreground {}] -height 1]
		set f5 [frame $f.5 -borderwidth $evv(BBDR)]
		set f6 [frame $f.6 -borderwidth $evv(BBDR)]
		button $f0.quit -text "Close" -command {set pr_mu 1 ; set pr_props 0} -highlightbackground [option get . background {}]
		button $f0.nbk -text "Notebook" -command NnnSee -width 8 ;# -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f0.srch -text "Search" -command SearchProps -width 8 -highlightbackground [option get . background {}]
		label $f0.srst -text "Search String"
		button $f0.calc	-text "Calculator" -command "MusicUnitConvertor 0 0"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
		button $f0.a	-text "A" -command "PlaySndfile $evv(TESTFILE_A) 0"  -highlightbackground [option get . background {}];# -bg $evv(HELP)
		entry $f0.srce -textvariable text_search -width 16
		label $f0.ll -text "Number of sounds listed"
		entry $f0.cnt  -textvariable propfcnt -width  10 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $f0.cnt $f0.ll $f0.nbk $f0.srch $f0.srst $f0.srce $f0.calc $f0.a -side left -padx 2
		pack $f0.quit -side right
		label $fa.l -text "CHOOSE WHICH SINGLE PROPERTY TO WORK ON"
		button $fa.b -text "Select On Several Props" -command Reconfigure_Do_Props -highlightbackground [option get . background {}]
		pack $fa.l $fa.b -side left -padx 4
		label $f01.l -text "SELECTED VALUES OF PROPERTY (separate by commas) ..... or ..... SEARCH-STRING"
		entry $f01.e -textvariable prop_sellist -width 36
		pack $f01.l $f01.e -side left -padx 3
		label $f0x1.ll -text "IN THE LISTING BELOW"
		pack $f0x1.ll -side top
		menubutton $f2.rea  -text "Rearrange Snds" -menu $f2.rea.menu -relief raised -width 17
		set mre [menu $f2.rea.menu -tearoff 0]
		$mre add command -label "Sort Sounds On Vals Of Specified Property" -command {SortOnField proplisting} -foreground black
		$mre add separator
		$mre add command -label "Numeric Sort Sounds On Specified Property" -command {NumericSortOnField proplisting}
		$mre add separator
		$mre add command -label "Numerically Shift Values Of Specified Property" -command {NumericShiftOnField proplisting}
		$mre add separator
		$mre add command -label "Cycle Sounds On Vals Of Specified Property" -command {CycleOnField 0} -foreground black
		$mre add separator
		$mre add command -label "Permute Sounds On Vals Of Specified Property" -command {CycleOnField 1} -foreground black
		$mre add separator
		$mre add command -label "Just One Snd For Each Val Of Specified Property" -command {OneOfEach} -foreground black
		$mre add separator
		$mre add command -label "Randomise List" -command PropsListRand -foreground black
		$mre add separator
		$mre add command -label "CONVERT VALUES" -command {}  -foreground black
 		$mre add separator
		$mre add command -label "Convert Pitch To Midi" -command "PropsPtoM 0" -foreground black
		$mre add separator
		$mre add command -label "Convert Midi To Pitch" -command "PropsMtoP 0" -foreground black

		menubutton $f2.kee -text "Keep Sounds" -menu $f2.kee.menu -relief raised -width 17
		set mke [menu $f2.kee.menu -tearoff 0]
		$mke add command -label "PROPERTY VALUES" -command {}  -foreground black
 		$mke add separator
		$mke add command -label "Snds With Specified Vals Of Specified Property" -command {SelectOnField 1} -foreground black
		$mke add separator
		$mke add command -label "Snds Where Vals Of Specified Prop Are >= Specified Val" -command {SelectOnField 4} -foreground black
		$mke add separator
		$mke add command -label "Snds Where Vals Of Specified Prop Are <= Specified Val" -command {SelectOnField 5} -foreground black
		$mke add separator
		$mke add command -label "Snds Where Val Of Specified Prop Contains Specified String" -command {SelectOnField 2} -foreground black
		$mke add separator
		$mke add command -label "Snds Where Val Of Specified Prop Starts With Specified String" -command {SelectOnField 6} -foreground black
		$mke add separator
		$mke add command -label "Snds Where Val Of Prop Contains All Values In Specified String" -command {SelectOnField 8} -foreground black
		$mke add separator
		$mke add command -label "Snds Where Val Of Prop Contains All Vals In String, In Same Order" -command {SelectOnField 9} -foreground black
		$mke add separator
		$mke add command -label "CHOSEN FILES LIST" -command {}  -foreground black
 		$mke add separator
		$mke add command -label "Snds Which Are Currently On Chosen Files List" -command {SelectOnChosen} -foreground black
		menubutton $f2.rmv -text "Remove Snds" -menu $f2.rmv.menu -relief raised -width 17
		set mrm [menu $f2.rmv.menu -tearoff 0]
		$mrm add command -label "With Specified Vals Of Specified Property" -command {SelectOnField 0} -foreground black
		$mrm add separator
		$mrm add command -label "Where Val Of Specified Prop Contains Specified String" -command {SelectOnField 3} -foreground black
		$mrm add separator
		$mrm add command -label "Where Val Of Specified Prop Starts With Specified String" -command {SelectOnField 7} -foreground black
		$mrm add separator
		$mrm add command -label "Highlighted Sounds" -command RemovePropItems -foreground black
		$mrm add separator
		$mrm add command -label "Sounds At & Beyond Highlight" -command {RemovePropItemsBeyond 1} -foreground black
		$mrm add separator
		$mrm add command -label "Sounds At & Above Highlight" -command {RemovePropItemsBeyond 0} -foreground black
		menubutton $f2.rst -text "Restore Snds" -menu $f2.rst.menu -relief raised -width 17
		set mrs [menu $f2.rst.menu -tearoff 0]
		$mrs add command -label "Previous Sound List" -command RestoreLastList -foreground black
		$mrs add separator
		$mrs add command -label "Original Sound List" -command RestorePropList -foreground black

		menubutton $f2.red -text "RearrangeData" -menu $f2.red.menu -relief raised -width 17
		set med [menu $f2.red.menu -tearoff 0]
		$med add command -label "Rearrange Columns (and Data Names)" -command {PropRearrange 1} -foreground black
		$med add separator
		$med add command -label "Move Data Into A Different (named) Column" -command {PropRearrange 0} -foreground black
		$med add separator
		$med add command -label "Delete Specified Columns" -command {PropDel 1} -foreground black
		$med add separator
		$med add command -label "Keep Only The Specified Columns" -command {PropDel 0} -foreground black

		menubutton $f2.tes -text "Test Props" -menu $f2.tes.menu -relief raised -width 17
		set mes [menu $f2.tes.menu -tearoff 0]
		$mes add command -label "Get Data On Values Of Specified Property" -command {PropAll} -foreground black
		$mes add separator
		$mes add command -label "List In Groups, Files With All Props Identical" -command {FindIdenticals 0} -foreground black
		$mes add separator
		$mes add command -label "" -command {} -foreground black
		pack $f2.rea $f2.kee $f2.rmv $f2.rst $f2.red $f2.tes -side left -padx 10 

		radiobutton $ff3.b1  -text "" -width 8 -variable propch -value 1 
		radiobutton $ff3.b2  -text "" -width 8 -variable propch -value 2  
		radiobutton $ff3.b3  -text "" -width 8 -variable propch -value 3
		radiobutton $ff3.b4  -text "" -width 8 -variable propch -value 4
		radiobutton $ff3.b5  -text "" -width 8 -variable propch -value 5
		radiobutton $ff3a.b6  -text "" -width 8 -variable propch -value 6
		radiobutton $ff3a.b7  -text "" -width 8 -variable propch -value 7
		radiobutton $ff3a.b8  -text "" -width 8 -variable propch -value 8
		radiobutton $ff3a.b9  -text "" -width 8 -variable propch -value 9
		radiobutton $ff3a.b10 -text "" -width 8 -variable propch -value 10
		radiobutton $ff3b.b11  -text "" -width 8 -variable propch -value 11 
		radiobutton $ff3b.b12  -text "" -width 8 -variable propch -value 12  
		radiobutton $ff3b.b13  -text "" -width 8 -variable propch -value 13
		radiobutton $ff3b.b14  -text "" -width 8 -variable propch -value 14
		radiobutton $ff3b.b15  -text "" -width 8 -variable propch -value 15
		radiobutton $ff3c.b16  -text "" -width 8 -variable propch -value 16
		radiobutton $ff3c.b17  -text "" -width 8 -variable propch -value 17
		radiobutton $ff3c.b18  -text "" -width 8 -variable propch -value 18
		radiobutton $ff3c.b19  -text "" -width 8 -variable propch -value 19
		radiobutton $ff3c.b20 -text "" -width 8 -variable propch -value 20
		pack $ff3.b1 $ff3.b2 $ff3.b3 $ff3.b4 $ff3.b5 -side left
		pack $ff3a.b6 $ff3a.b7 $ff3a.b8 $ff3a.b9 $ff3a.b10 -side left
		pack $ff3b.b11 $ff3b.b12 $ff3b.b13 $ff3b.b14 $ff3b.b15 -side left
		pack $ff3c.b16 $ff3c.b17 $ff3c.b18 $ff3c.b19 $ff3c.b20 -side left
		pack $ff3 $ff3a $ff3b $ff3c -side top

		checkbutton $ffz.b1  -text "" -width 8 -variable propchv(1)
		checkbutton $ffz.b2  -text "" -width 8 -variable propchv(2)
		checkbutton $ffz.b3  -text "" -width 8 -variable propchv(3)
		checkbutton $ffz.b4  -text "" -width 8 -variable propchv(4)
		checkbutton $ffz.b5  -text "" -width 8 -variable propchv(5)
		checkbutton $ffza.b6  -text "" -width 8 -variable propchv(6)
		checkbutton $ffza.b7  -text "" -width 8 -variable propchv(7)
		checkbutton $ffza.b8  -text "" -width 8 -variable propchv(8)
		checkbutton $ffza.b9  -text "" -width 8 -variable propchv(9)
		checkbutton $ffza.b10 -text "" -width 8 -variable propchv(10)
		checkbutton $ffzb.b11  -text "" -width 8 -variable propchv(11)
		checkbutton $ffzb.b12  -text "" -width 8 -variable propchv(12)
		checkbutton $ffzb.b13  -text "" -width 8 -variable propchv(13)
		checkbutton $ffzb.b14  -text "" -width 8 -variable propchv(14)
		checkbutton $ffzb.b15  -text "" -width 8 -variable propchv(15)
		checkbutton $ffzc.b16  -text "" -width 8 -variable propchv(16)
		checkbutton $ffzc.b17  -text "" -width 8 -variable propchv(17)
		checkbutton $ffzc.b18  -text "" -width 8 -variable propchv(18)
		checkbutton $ffzc.b19  -text "" -width 8 -variable propchv(19)
		checkbutton $ffzc.b20 -text "" -width 8 -variable propchv(20)
		pack $ffz.b1 $ffz.b2 $ffz.b3 $ffz.b4 $ffz.b5 -side left
		pack $ffza.b6 $ffza.b7 $ffza.b8 $ffza.b9 $ffza.b10 -side left
		pack $ffzb.b11 $ffzb.b12 $ffzb.b13 $ffzb.b14 $ffzb.b15 -side left
		pack $ffzc.b16 $ffzc.b17 $ffzc.b18 $ffzc.b19 $ffzc.b20 -side left
		pack $ffz $ffza $ffzb $ffzc -side top

		pack $ff0 $ff1 -side left

		menubutton $f5.fil -text "Save New Data" -menu $f5.fil.menu -relief raised -width 15
		set mfi [menu $f5.fil.menu -tearoff 0]
		$mfi add command -label "Property List Shown" -command {PropToFile 2} -foreground black
		$mfi add separator
		$mfi add command -label "All Sounds Shown" -command {PropToFile 0} -foreground black
		$mfi add separator
		$mfi add command -label "Column Of Vals Of Selected Prop" -command {PropToFile 1} -foreground black

		label $f5.l -text "Name of File"
		entry $f5.e -textvariable prop_fname -width 48 -disabledbackground [option get . background {}]
		menubutton $f5.asse -text "Collect Files" -menu $f5.asse.menu -relief raised -width 16
		set mfa [menu $f5.asse.menu -tearoff 0]
		$mfa add command -label "DISPLAY OR ERASE COLLECTION" -command {}  -foreground black
		$mfa add separator ;# -background $evv(HELP)
		$mfa add command -label "Display Collection" -command {PropCollection 1} -foreground black
		$mfa add separator
		$mfa add command -label "Sort Collection On Specified Prop" -command {PropCollection 4} -foreground black
		$mfa add separator
		$mfa add command -label "Erase Collection" -command {PropCollection 0} -foreground black
		$mfa add separator
		$mfa add command -label "ADD TO COLLECTION" -command {} ;# -background $evv(HELP) -foreground black
		$mfa add separator ;# -background $evv(HELP)
		$mfa add command -label "All Files Listed" -command {PropCollection 2} -foreground black
		$mfa add separator
		$mfa add command -label "Highlighted Files" -command {PropCollection 3} -foreground black

		menubutton $f5.play -text "Play or Mark" -menu $f5.play.menu -relief raised -width 20
		set mfp [menu $f5.play.menu -tearoff 0]
		$mfp add command -label "PLAY" -command {}  -foreground black
		$mfp add separator ;# -background $evv(HELP)
		$mfp add command -label "Play Selected Files" -command {PlayPropFiles 0} -foreground black
		$mfp add separator
		$mfp add command -label "Play First N Files" -command {PlayPropFiles 1} -foreground black
		$mfp add separator
		$mfp add command -label "Play N Files From Selected File" -command {PlayPropFiles 6} -foreground black
		$mfp add separator
		$mfp add command -label "Play Next N Files" -command {PlayPropFiles 2} -foreground black
		$mfp add separator
		$mfp add command -label "Play Same Files Again" -command {PlayPropFiles 3} -foreground black
		$mfp add separator
		$mfp add command -label "Skip K Files" -command {PlayPropFiles 4} -foreground black
		$mfp add separator ;# -background $evv(HELP)
		$mfp add command -label "MARK" -command {}  -foreground black
		$mfp add separator ;# -background $evv(HELP)
		$mfp add command -label "Mark Some Of Played Files" -command {PlayPropFiles 5} -foreground black
		$mfp add separator
		$mfp add command -label "Clear All Marks" -command {ClearMarkList} -foreground black
		$mfp add separator
		$mfp add command -label "Highlight Marked Files" -command {HiliteMarkList} -foreground black

		menubutton $f5.cho -text "as Chosen Files" -menu $f5.cho.menu -relief raised -width 20
		set mfc [menu $f5.cho.menu -tearoff 0]
		$mfc add command -label "Sounds Now Listed" -command SndsWithPropsToChosen -foreground black
		$mfc add separator
		$mfc add command -label "Sounds Selected" -command {SndsSelectedWithPropsToChosen 0} -foreground black
		$mfc add separator
		$mfc add command -label "Sounds Marked" -command {SndsSelectedWithPropsToChosen 1} -foreground black
		set proplisting [Scrolled_Listbox $f6.ll -width 120 -height 16 -selectmode extended]
		pack $f5.fil $f5.l $f5.e -side left -padx 1
		pack $f5.cho $f5.play $f5.asse -side right -padx 4
		pack $f6.ll -side top -fill both -expand true
		pack $f0 -side top -fill both -expand true
		pack $fa -side top
 		pack $ff -side top -fill both -expand true
  		pack $f4 -pady 2 -side top -fill x -expand true
		pack $f01 -side top
  		pack $f02 -pady 2 -side top -fill x -expand true
		pack $f0x1 -side top
		pack $f2 -side top
		pack $f4a -pady 2 -side top -fill x -expand true
		pack $f5 $f6 -side top -fill both -expand true
		bind .prop_file <Control-Key-P> {UniversalPlay props 0}
		bind .prop_file <Control-Key-p> {UniversalPlay props 0}
		bind .prop_file <Key-space>		{UniversalPlay props 0}
		bind $f <Escape> {set pr_mu 1 ; set pr_props 0}
	}
	Reset_Do_Props
	wm title $f "ORDER SOUNDS BY USER SPECIFIED PROPERTIES IN FILE [file tail $orig_propfile_name]"
	set propfcnt $linecnt
	set n 1
	while {$n <= 20} {
		set propchv($n) 0
		set last_propchv($n) 0
		if {$n > 15} {
			$f.f.1.zc.b$n config -text "" -state disabled
		} elseif {$n > 10} {
			$f.f.1.zb.b$n config -text "" -state disabled
		} elseif {$n > 5} {
			$f.f.1.za.b$n config -text "" -state disabled
		} else {
			$f.f.1.z.b$n config -text "" -state disabled
		}
		incr n
	}
	set n 1
	while {$n < $propcnt} {
		if {$n > 15} {
			$f.f.0.3c.b$n config -text $propname($n) -state normal
		} elseif {$n > 10} {
			$f.f.0.3b.b$n config -text $propname($n) -state normal
		} elseif {$n > 5} {
			$f.f.0.3a.b$n config -text $propname($n) -state normal
		} else {
			$f.f.0.3.b$n config -text $propname($n) -state normal
		}
		incr n
	}
	while {$n < 6} {
		$f.f.0.3.b$n config -text "" -state disabled
		incr n
	}
	while {$n < 11} {
		$f.f.0.3a.b$n config -text "" -state disabled
		incr n
	}
	while {$n < 16} {
		$f.f.0.3b.b$n config -text "" -state disabled
		incr n
	}
	while {$n <= 20} {
		$f.f.0.3c.b$n config -text "" -state disabled
		incr n
	}
	catch unset {old_proplist}
	RestorePropList
	if {[info exists orig_orig_propfile]} {
		set orig_propfile $orig_orig_propfile
		set old_proplist [$proplisting get 0 end]
	}
	set prop_sellist ""
	set prop_fname ""
	set propch 0
	set pr_props 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_props $proplisting
	while {!$finished} {
		tkwait variable pr_props
		if {!$pr_props} {
			set finished 1
		}
	}
	catch {destroy .cpd}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc RestorePropList {} {
	global proplisting orig_propfile propfcnt prop_name_swap
	if {$prop_name_swap} {
		Inf "Property Names Have Been Changed: Cannot Restore Original List\nExit Here, And Reload File"
		return
	}
	$proplisting delete 0 end
	set cnt 0
	foreach line $orig_propfile {
		$proplisting insert end $line
		incr cnt
	}
	set propfcnt $cnt
}

proc RestoreLastList {} {
	global proplisting old_proplist propfcnt prop_name_swap
	if {$prop_name_swap} {
		Inf "Property Names Have Been Changed: Cannot Restore Previous List\nExit Here, And Reload File"
		return
	}
	set keep [$proplisting get 0 end]
	if {![info exists old_proplist]} {
		RestorePropList
	} else {
		$proplisting delete 0 end
		set cnt 0
		foreach line $old_proplist {
			$proplisting insert end $line
			incr cnt
		}
		set propfcnt $cnt
	}
	set old_proplist $keep
}

proc SelectOnField {selecttype} {
	global prop_sellist propch proplisting old_proplist propname propfcnt wstk
	if {[string length $prop_sellist] <= 0} {
		Inf "No Selection List Provided"
		return
	}
	if {$propch < 1} {
		Inf "No Property Selected"
		return
	}
	set proplist $prop_sellist
	set OK 1
	set vals {}
	set props {}
	while {$OK} {
		set k [string first "," $proplist]
		if {$k < 0} {
			set val [string trim [string range $proplist 0 end]]
			if {[string length $val] > 0} {
				set j [string first " " $val]
				if {$j < 0} {
					lappend vals $val
				} else {
					Inf "You Cannot Use A Selection Item ('$val') With Spaces In It"
					return
				}
			}
			break
		}
		if {$k==0} {
			set proplist [string range $proplist 1 end]
		} else {
			set val [string trim [string range $proplist 0 [expr $k - 1]]]
			if {[string length $val] > 0} {
				set j [string first " " $val]
				if {$j < 0} {
					lappend vals $val
				} else {
					Inf "You Cannot Use A Selection Item ('$val') With Spaces In It"
					return
				}
				incr k
				set proplist [string range $proplist $k end]
			}
        }
	}
	if {![info exists vals]} {
		Inf "No Valid Property Values Entered"
		return
	}
	if {($selecttype == 4) || ($selecttype == 5)} {
		 if {[llength $vals] !=1} {
			Inf "Select A Single Property Value"
			return
		} else {
			set val [lindex $vals 0]
			if {![IsNumeric $val]} {
				Inf "This Operation Only Works With Numeric Values"
				return
			}
		}
	} elseif {($selecttype == 8) || ($selecttype == 9)} {
		 if {[llength $vals] !=1} {
			Inf "Select A Single Comparison String (No Commas)"
			return
		} else {
			set val [lindex $vals 0]
			set prop_name $propname($propch)
			switch -- $prop_name {
				"HF" {
					set msg "Ignore Passing Notes (Lower Case Notes) ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						set no_pass 1
					} else {
						set no_pass 0
					}
					catch {unset vals}
					set len [string length $val]
					set j 0
					set m 0
					set n 1 
					while {$n < $len} {
						set item [string index $val $n]
						switch -- $item {
							"A" -
							"B" -
							"C" -
							"D" -
							"E" -
							"F" -
							"G" {
								lappend vals [string range $val $j $m]
								set j $n
							}
							"#" {
							}
							default {
								Inf "Invalid Search String (\"A B C D E F G #\" Only)"
								return
							}													
						}
						incr m
						incr n
					}
					lappend vals [string range $val $j $m]
				}
				default {
					Inf "This Option Does Not Work With Property \"$prop_name\""
					return
				}
			}
		}
	}
	foreach line [$proplisting get 0 end] {
		set line [split $line]
		lappend props [lindex $line $propch]
	}
	set has_numbers 0
	switch -- $selecttype {
		1 {				;#	Sound has property, keep it
			set cnt 0
			foreach prop $props {
				foreach val $vals {
					if {[regexp {^\?\?$} $prop]} {
					    if {[regexp {^\?\?$} $val]} {
						    lappend nulines [$proplisting get $cnt]
						    break
					    }
					} elseif {[string match $prop $val]} {
						lappend nulines [$proplisting get $cnt]
						break
					}
				}
				incr cnt
			}
		}
		2 {			;#	Sound property contains string, keep it
			set cnt 0
			foreach prop $props {
				foreach val $vals {
					set k [string first $val $prop]
					if {$k >= 0} {
						lappend nulines [$proplisting get $cnt]
						break
					}
				}
				incr cnt
			}
		}
		6 {			;#	Sound property starts with string, keep it
			set cnt 0
			foreach prop $props {
				foreach val $vals {
					set k [string first $val $prop]
					if {$k == 0} {
						lappend nulines [$proplisting get $cnt]
						break
					}
				}
				incr cnt
			}
		}
		0 {			;#	Sound has property, reject it
			set cnt 0
			foreach prop $props {
				set got 0
				foreach val $vals {
					if {[string match $prop $val]} {
						set got 1
						break
					}
				}
				if {!$got} {
					lappend nulines [$proplisting get $cnt]
				}
				incr cnt
			}
		}
		3 {			;#	Sound property contains string, reject it
			set cnt 0
			foreach prop $props {
				set got 0
				foreach val $vals {
					set k [string first $val $prop]
					if {$k >= 0} {
						set got 1
						break
					}
				}
				if {!$got} {
					lappend nulines [$proplisting get $cnt]
				}
				incr cnt
			}
		}
		7 {			;#	Sound property starts with string, reject it
			set cnt 0
			foreach prop $props {
				set got 0
				foreach val $vals {
					set k [string first $val $prop]
					if {$k == 0} {
						set got 1
						break
					}
				}
				if {!$got} {
					lappend nulines [$proplisting get $cnt]
				}
				incr cnt
			}
		}
		4 {				;#	Sound has property >= limit, keep it
			set cnt 0
			foreach prop $props {
				if {[IsNumeric $prop] && ($prop >= $val)} {
					lappend nulines [$proplisting get $cnt]
				}
				incr cnt
			}
		}
		5 {				;#	Sound has property <= limit, keep it
			set cnt 0
			foreach prop $props {
				if {[IsNumeric $prop]} {
					set has_numbers 1
					if {$prop <= $val} {
						lappend nulines [$proplisting get $cnt]
					}
				}
				incr cnt
			}
		}
		8 -
		9 {
			switch -- $prop_name {
				"HF" {
					set cnt 0
					foreach prop $props {
						set OK 1
						catch {unset p_rops}
						set startnote [string index $prop 0]
						if {[regexp {[A-G]} $startnote]} {
							set passing 0
						} elseif {[regexp {[a-g]} $startnote]} {
							set passing 1
						} else {
							set OK 0
						}
						set len [string length $prop]
						set j 0
						set m 0
						set n 1 
						while {$n < $len} {
							set item [string index $prop $n]
							switch -- $item {
								"A" -
								"B" -
								"C" -
								"D" -
								"E" -
								"F" -
								"G" {
									if {($no_pass && !$passing) || !$no_pass} {
										lappend p_rops [string toupper [string range $prop $j $m]]
										set j $n
									}
									set passing 0
								}
								"a" -
								"b" -
								"c" -
								"d" -
								"e" -
								"f" -
								"g" {
									if {($no_pass && !$passing) || !$no_pass} {
										lappend p_rops [string toupper [string range $prop $j $m]]
										set j $n
									}
									set passing 1
								}
								"#" {
								}
								default {
									Inf "Invalid Property Value ($prop)"
									set OK 0
									break
								}													
							}
							incr m
							incr n
						}
						if {!$OK} {
							set p_rops {}
						} elseif {($no_pass && !$passing) || !$no_pass} {
							lappend p_rops [string toupper [string range $prop $j $m]]
						}
						set OK 1
						switch -- $selecttype {
							8 {
								foreach val $vals {
									set k [lsearch $p_rops $val]
									if {$k < 0} {
										set OK 0
										break
									}
								}
							}
							9 {
								set lastk -1
								foreach val $vals {
									set k [lsearch $p_rops $val]
									if {$k <= $lastk} {
										set OK 0
										break
									}
									set lastk $k
								}
							}
						}
						if {$OK} {
							lappend nulines [$proplisting get $cnt]
						}
						incr cnt
					}
				}
				default {
					Inf "This Function Does Not Work With This Property"
					return
				}
			}
		}
	}
	if {![info exists nulines]} {
		if {($selecttype == 1) || ($selecttype == 2)} {
			Inf "No Listed File Has These Values Of The Property '$propname($propch)'"
		} elseif {($selecttype == 4) || ($selecttype == 5)} {
			if {!$has_numbers} {
				Inf "No Listed File Has Numeric Values Of The Property '$propname($propch)'"
			} else {
				Inf "No Listed File Has These Values Of The Property '$propname($propch)'"
			}
		} else {
			Inf "No Listed File Does Not Have These Values Of The Property '$propname($propch)'"
		}
		return
	}
	set old_proplist [$proplisting get 0 end]
	$proplisting delete 0 end
	set cnt 0
	foreach line $nulines {
		$proplisting insert end $line
		incr cnt
	}
	set propfcnt $cnt
}

proc RemovePropItems {} {
	global old_proplist proplisting  propfcnt
	set ilist [$proplisting curselection]
	if {[llength $ilist] <= 0} {
		Inf "No Items Selected For Deletion"
		return
	}
	set cnt 0
	foreach item [$proplisting get 0 end] {
		incr cnt
	}
	if {[llength $ilist] == $cnt} {
		Inf "This Operation Would Remove All The Listed Files"
		return
	}
	if {![AreYouSure]} {
		return
	}
	set old_proplist [$proplisting get 0 end]

	foreach i [lsort -integer -decreasing $ilist] {
		$proplisting delete $i
		incr cnt -1
	}
	set propfcnt $cnt
}


proc RemovePropItemsBeyond {below} {
	global old_proplist proplisting propfcnt

	set i [$proplisting curselection]
	if {[llength $i] <= 0} {
		Inf "No Items Selected For Deletion."
		return
	}
	if {[llength $i] > 1} {
		Inf "More Than One Line Indicated."
		return
	}
	if {$below} {
		incr i -1
		if {$i < 0} {
			Inf "This Operation Would Remove All The Listed Files"
			return
		}
	} else {
		set cnt 0
		foreach item [$proplisting get 0 end] {
			incr cnt
		}
		incr cnt -1
		if {$i >= $cnt} {
			Inf "This Operation Would Remove All The Listed Files"
			return
		}
	}
	if {![AreYouSure]} {
		return
	}
	set old_proplist [$proplisting get 0 end]
	if {$below} {
		set new_proplist [$proplisting get 0 $i]
	} else {
		incr i
		set new_proplist [$proplisting get $i end]
	}
	$proplisting delete 0 end
	set cnt 0
	foreach line $new_proplist {
		$proplisting insert end $line
		incr cnt
	}
	set propfcnt $cnt
}

proc PropToFile {getprop} {
	global propch prop_fname proplisting wstk wl total_wksp_cnt propcnt propname propfiles_list rememd old_props_protocol evv

	if {$getprop == 1} {
		if {$propch < 1} {
			Inf "No Property Selected"
			return
		}
	}
	if {[string length $prop_fname] <= 0} {
		Inf "No Filename Given"
		return
	}
	set prop_fname [FixTxt $prop_fname filename]
	if {[string length $prop_fname] <= 0} {
		return
	}
	set prop_fname [string tolower $prop_fname]
	switch -- $getprop  {
		0 { set this_ext [GetTextfileExtension sndlist]}
		1 { set this_ext $evv(TEXT_EXT)}
		2 { set this_ext [GetTextfileExtension props]}
	}
	set prop_ffname $prop_fname$this_ext
	if {[file exists $prop_ffname]} {
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
			-message "File '$prop_ffname' Already Exists\n\nDo You Want To Overwrite It??"]
		if {$choice == "no"} {
			return
		} else {
			set i [LstIndx $prop_ffname $wl]
			if {$i >= 0} {
				PurgeArray $prop_ffname
				RemoveFromChosenlist $prop_ffname
				incr total_wksp_cnt -1
				$wl delete $i
				catch {unset rememd}
			}
		}
	}
	if [catch {open $prop_ffname "w"} zit] {
		Inf "Cannot Open File '$prop_ffname'"
		return
	}
	if {$getprop == 2} {
		set n 1
		set line $propname($n)
		incr n
		while {$n < $propcnt} {
			append line " " $propname($n)
			incr n
		}
		puts $zit $line
	}
	foreach line [$proplisting get 0 end] {
		set linex [split $line]
		switch -- $getprop {
			0 { set val [lindex $linex 0] }
			1 { set val [lindex $linex $propch] } 
			2 { 
				if {$old_props_protocol} {
					set val [file tail [lindex $linex 0]]
					set val [concat $val [lrange $linex 1 end]]
				} else {
					set val $linex
				}
			} 
		}
		puts $zit $val
	}
	close $zit
	FileToWkspace $prop_ffname 0 0 0 0 1
	if {$getprop == 2} {
		if {[info exists propfiles_list]} {
			if {[lsearch $propfiles_list $prop_ffname] < 0} {
				lappend propfiles_list $prop_ffname
			} 
		} else {
			lappend propfiles_list $prop_ffname
		}
	}
	switch -- $getprop {
		0 { Inf "Written List Of Sounds Into The File '$prop_ffname'" }
		1 { Inf "Written Property Values Into The File '$prop_ffname'" } 
		2 { Inf "Written Entire Property List Into The File '$prop_ffname'" } 
	}
}

#--- Transfer sounds listed on property-list page, to chosen files list on workspace, and go to workspace

proc SndsWithPropsToChosen {} {
	global proplisting wl ch chlist chcnt pr_props propfile wstk

	set fnams {}
	foreach line [$proplisting get 0 end] {
		set line [split $line]
		set fnam [lindex $line 0]
		if {[lsearch $fnams $fnam] >= 0} {
			continue
		}
		if {![file exists $fnam]} {
			Inf "Anomaly!!\n\nfile '$fnam' No Longer Exists"
			continue
		}
		lappend fnams $fnam
	}
	set len [llength $fnams]
	if {$len <= 0} {
		return
	}
	if {$len > 20} {
		set msg "Put $len Soundfiles On The Chosen Files List??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		}
	}
	if {$len > 20} {
		Block "Loading Files to Chosen List"
	}
	DoChoiceBak
	ClearWkspaceSelectedFiles
	foreach fnam $fnams {
		if {[LstIndx $fnam $wl] < 0} {
			if {[FileToWkspace $fnam 0 0 1 1 0] <= 0} {
				Inf "Cannot Put The File '$fnam' On The Workspace."
				continue
			}
		}
		lappend chlist $fnam		;#	add to end of list
		$ch insert end $fnam		;#	add to end of display
		incr chcnt
	}
	if {$len > 20} {
		UnBlock
	}
	set pr_props 0
}

#--- Transfer sounds selected on property-list page, to chosen files list on workspace, and go to workspace

proc SndsSelectedWithPropsToChosen {marked} {
	global proplisting wl ch chlist chcnt pr_props propfile all_mark_list wstk

	set fnams {}
	if {$marked} {
		if {![info exists all_mark_list] || ([llength $all_mark_list] <= 0)} {
			Inf "No Sounds Are Marked"
			return
		}
		set ilist $all_mark_list 
	} else {
		set ilist [$proplisting curselection]
		if {[llength $ilist] <= 0} {
			Inf "No Sounds Selected"
			return
		}
	}
	foreach i $ilist {
		set line [$proplisting get $i]
		set line [split $line]
		set fnam [lindex $line 0]
		if {[lsearch $fnams $fnam] >= 0} {
			continue
		}
		if {![file exists $fnam]} {
			Inf "Anomaly!!\n\nFile '$fnam' No Longer Exists"
			continue
		}
		lappend fnams $fnam
	}
	set len [llength $fnams]
	if {$len <= 0} {
		return
	}
	if {$len > 20} {
		set msg "Put $len Soundfiles On The Chosen Files List??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		}
	}
	if {$len > 20} {
		Block "Loading Files to Chosen List"
	}
	DoChoiceBak
	ClearWkspaceSelectedFiles
	foreach fnam $fnams {
		if {[LstIndx $fnam $wl] < 0} {
			if {[FileToWkspace $fnam 0 0 1 1 0] <= 0} {
				Inf "Cannot Put The File '$fnam' On The Workspace."
				continue
			}
		}
		lappend chlist $fnam		;#	add to end of list
		$ch insert end $fnam		;#	add to end of display
		incr chcnt
	}
	if {$len > 20} {
		UnBlock
	}
	set pr_props 0
}

#----- Sort list of properties, using values of particular property to sort on

proc SortOnField {listing} {
	global propch proplisting old_proplist propfcnt prop_coll
	set vals {}
	if {$propch < 1} {
		Inf "No Property Chosen"
		return
	}
	switch -- $listing {
		"proplisting" {
			foreach line [$proplisting get 0 end] {
				lappend lines $line
				set line [split $line]
				set val [lindex $line $propch]
				lappend vals_in_line $val
				set k [lsearch -exact $vals $val]
				if {$k < 0} {
					lappend vals $val
				}
			}
		}
		"prop_coll" {
			foreach line $prop_coll {
				lappend lines $line
				set line [split $line]
				set val [lindex $line $propch]
				lappend vals_in_line $val
				set k [lsearch -exact $vals $val]
				if {$k < 0} {
					lappend vals $val
				}
			}
		}
	}
	set vals [lsort $vals]
	set len [llength $vals]
	set n 0
	while {$n < $len} {
		set val [lindex $vals $n]
		if {$val == "-"} {
			set vals [lreplace $vals $n $n]
			lappend vals "-"
			break
		}
		incr n
	}
	catch {unset nulines}
	foreach val $vals {
		foreach line $lines val_in_line $vals_in_line {
			if {[regexp {^\?\?$} $val]} {
			    if {[regexp {^\?\?$} $val_in_line]} {
				    lappend nulines $line
			    }
			} elseif {[string match $val $val_in_line]} {
				lappend nulines $line
			}
		}
	}
	switch -- $listing {
		"proplisting" {
			set old_proplist [$proplisting get 0 end]
			$proplisting delete 0 end
			set cnt 0
			foreach line $nulines {
				$proplisting insert end $line
				incr cnt
			}
			set propfcnt $cnt
		} 
		"prop_coll" {
			set prop_coll $nulines
		}
	}
}

#----- Sort list of properties, using numeric value of particular property to sort on

proc NumericSortOnField {listing} {
	global propch proplisting old_proplist propfcnt prop_coll
	set vals {}
	if {$propch < 1} {
		Inf "No Property Chosen"
		return
	}
	switch -- $listing {
		"proplisting" {
			foreach line [$proplisting get 0 end] {
				lappend lines $line
				set line [split $line]
				set val [lindex $line $propch]
				lappend vals_in_line $val
				set k [lsearch -exact $vals $val]
				if {$k < 0} {
					lappend vals $val
				}
			}
		}
		"prop_coll" {
			foreach line $prop_coll {
				lappend lines $line
				set line [split $line]
				set val [lindex $line $propch]
				lappend vals_in_line $val
				set k [lsearch -exact $vals $val]
				if {$k < 0} {
					lappend vals $val
				}
			}
		}
	}
	set numvals {}
	foreach val $vals_in_line {
		if {[string match $val "-"] || [regexp {^\?\?$} $val]} {
			continue
		}
		set numval ""
		set len [string length $val]
		set n 0
		set intcnt 0
		set gotint 0
		while {$n < $len} {
			set thischar [string index $val $n]
			if [regexp {^[0-9]$} $thischar] {
				if {$gotint} {
					Inf "Some Values Have Ambiguous Or Non_Integer Numbering (e.g. $val)"
					return
				}
				append numval $thischar
				incr intcnt
			} else {
				if {$intcnt} {
					set gotint 1
				}
			}
			incr n
		}
		if {!$intcnt} {
			Inf "Some Values Are Not Numeric (e.g.$val)"
			return
		}
		if {[lsearch $numvals $numval] < 0} { 
			lappend numvals $numval
		}
	}
	if {[llength $numvals] <= 0} {
		Inf "There Are No Numeric Values"
		return
	}
	set numvals [lsort -integer -decreasing $numvals]	;#	"-decreasing" ensures that e.g. 142 is found before 14 or 4

	catch {unset nulines}
	set qnulines {}
	set nulnulines {}
	catch {unset otherlines}
	catch {unset other_vals}

	foreach line $lines val_in_line $vals_in_line {
		if {[regexp {^\?\?$} $val_in_line]} {
			lappend qnulines $line
		} elseif {[string match "-" $val_in_line]} {
			lappend nulnulines $line
		} else {
			lappend otherlines $line
			lappend other_vals $val_in_line
		}
	}
	if {![info exists otherlines]} {
		Inf "No Lines Found With Specific Values In The Specified Field"
		return
	}
	set len [llength $otherlines]
	foreach val $numvals {
		set n 0
		while {$n < $len} {
			set line [lindex $otherlines $n]
			set val_in_line [lindex $other_vals $n]
			if {[string first $val $val_in_line] >= 0} {
				lappend nulines $line
				set otherlines [lreplace $otherlines $n $n]
				set other_vals [lreplace $other_vals $n $n]
				incr len -1
			} else {
				incr n
			}
		}
	}
	if {![info exists nulines]} {
		Inf "No Sorted Lines Generated"
		return
	}
	set nulines [ReverseList $nulines]		;#	This puts numerically sorted items into increasing-order
	set nulines [concat $nulines $qnulines $nulnulines]

	switch -- $listing {
		"proplisting" {
			set old_proplist [$proplisting get 0 end]
			$proplisting delete 0 end
			set cnt 0
			foreach line $nulines {
				$proplisting insert end $line
				incr cnt
			}
			set propfcnt $cnt
		} 
		"prop_coll" {
			set prop_coll $nulines
		}
	}
}

#----- Modify list of properties, using numeric values of particular property to shift on

proc NumericShiftOnField {listing} {
	global propch proplisting old_proplist propfcnt prop_coll 
	global pr_propnumshift evv propnumshift_shift propnumshift_lo propnumshift_hi pns evv
	catch {unset pns}

	set vals {}
	if {$propch < 1} {
		Inf "No Property Chosen"
		return
	}
	switch -- $listing {
		"proplisting" {
			foreach line [$proplisting get 0 end] {
				lappend lines $line
				set line [split $line]
				set val [lindex $line $propch]
				lappend vals_in_line $val
				set k [lsearch -exact $vals $val]
				if {$k < 0} {
					lappend vals $val
				}
			}
		}
		"prop_coll" {
			foreach line $prop_coll {
				lappend lines $line
				set line [split $line]
				set val [lindex $line $propch]
				lappend vals_in_line $val
				set k [lsearch -exact $vals $val]
				if {$k < 0} {
					lappend vals $val
				}
			}
		}
	}
	catch {unset numvals}
	foreach val $vals_in_line {
		if {[string match $val "-"] || [regexp {^\?\?$} $val]} {
			continue
		}
		set numval ""
		set len [string length $val]
		set n 0
		set intcnt 0
		set gotint 0
		while {$n < $len} {
			set thischar [string index $val $n]
			if [regexp {^[0-9]$} $thischar] {
				if {$gotint} {
					Inf "Some Values Have Ambiguous Or Non_Integer Numbering (e.g. $val)"
					return
				}
				append numval $thischar
				incr intcnt
			} else {
				if {$intcnt} {
					set gotint 1
				}
			}
			incr n
		}
		if {!$intcnt} {
			Inf "Some Values Are Not Numeric (e.g.$val)"
			return
		}
		lappend numvals $numval
	}
	if {![info exists numvals]} {
		Inf "There Are No Numeric Values"
		return
	}
	set numvals [lsort -integer -decreasing $numvals]	;#	"-decreasing" ensures that e.g. 142 is found before 14 or 4

	set pns(returnval) 0
	set f .propnumshift
	if [Dlg_Create $f "PROPERTY VALUE SHIFT" "set pr_propnumshift 0" -borderwidth $evv(BBDR)] {
		frame $f.0 -borderwidth $evv(BBDR)
		frame $f.1 -borderwidth $evv(BBDR)
		frame $f.2 -borderwidth $evv(BBDR)
		frame $f.3 -borderwidth $evv(BBDR)
		button $f.0.ok -text "Shift" -command {set pr_propnumshift 1} -width 10
		button $f.0.qu -text "Abandon" -command {set pr_propnumshift 0} -width 10
		pack $f.0.ok -side left
		pack $f.0.qu -side right
		label $f.1.ll -text "Shift value by "
		entry $f.1.e -textvariable propnumshift_shift -width 48
		pack $f.1.e $f.1.ll -side left -padx 8
		label $f.2.ll -text "Minimum value to shift "
		entry $f.2.e -textvariable propnumshift_lo -width 48
		pack $f.2.e $f.2.ll -side left -padx 8
		label $f.3.ll -text "Maximum value to shift "
		entry $f.3.e -textvariable propnumshift_hi -width 48
		pack $f.3.e $f.3.ll -side left -padx 8
		pack $f.0 $f.1 $f.2 $f.3 -side top -pady 2 -fill x -expand true		
		bind $f <Escape> {set pr_propnumshift 0}
		bind $f <Return> {set pr_propnumshift 1}
	}
	set pr_propnumshift 0
	set finished 0
	raise $f
	My_Grab 0 $f pr_propnumshift $f.1.e
	while {!$finished} {
		tkwait variable pr_propnumshift
		if {$pr_propnumshift} {
			if {[string length $propnumshift_shift] <= 0} {
				Inf "No Shift Value Entered"
				continue
			}
			if {![regexp {^[0-9\-]+$} $propnumshift_shift] || ![IsNumeric $propnumshift_shift] || ($propnumshift_shift == 0)} {
				Inf "Invalid Shift Value Entered"
				continue
			}
			if {[string length $propnumshift_lo] <= 0} {
				Inf "No Lower Limit Entered"
				continue
			}
			if {![regexp {^[0-9\-]+$} $propnumshift_lo] || ![IsNumeric $propnumshift_lo] || ($propnumshift_lo == 0)} {
				Inf "Invalid Lower Limit Entered"
				continue
			}
			if {[string length $propnumshift_hi] <= 0} {
				Inf "No Higher Limit Entered"
				continue
			}
			if {![regexp {^[0-9\-]+$} $propnumshift_hi] || ![IsNumeric $propnumshift_hi] || ($propnumshift_hi == 0)} {
				Inf "Invalid Higher Limit Entered"
				continue
			}
			if {$propnumshift_hi <= $propnumshift_lo} {
				Inf "Incompatible Low And High Limits Entered"
				continue
			}
			set pns(shift) $propnumshift_shift
			set pns(lo) $propnumshift_lo
			set pns(hi) $propnumshift_hi
			set finished 1
		} else {
			set pns(returnval) 1
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	if {$pns(returnval)} {
		return
	}
	catch {unset nulines}

	set n 0
	set len [llength $lines]
	while {$n < $len} {
		set line [lindex $lines $n]
		set val_in_line [lindex $vals_in_line $n]
		set vallen [string length $val_in_line]			;#	length of entire value-entry
		if {[regexp {^\?\?$} $val_in_line]} {
			lappend nulines $line
			incr n
			continue
		} elseif {[string match "-" $val_in_line]} {
			lappend nulines $line
			incr n
			continue
		} else {
			set gotit 0
			foreach val $numvals {
				set numlen [string length $val]			;#	length of numeric component we're searching for
				set k [string first $val $val_in_line]	;#	Is the (original) numeric value in the line?
				if {$k >= 0} {							;#	If the numeric value lies within the specified range for incrementation
					if {($val >= $pns(lo)) && ($val <= $pns(hi))} {
						if {$k == 0} {					;#	Get start of entry (if anything pre-number)
							set nuentry ""
						} else {
							incr k -1
							set nuentry [string range $val_in_line 0 $k]
							incr k
						}								;#	Incremented value to be substituted into entry
						set nuval [expr $val + $pns(shift)]
						append nuentry $nuval			;#	Insert new numeric value into entry
						incr k $numlen					;#	Jump over existing number in original entry
						if {$k < $vallen} {				;#	If any characters AFTER number, add these to entry
							append nuentry [string range $val_in_line $k end]
						}
						set nuline [lreplace $line $propch $propch $nuentry]
					} else {
						set nuline $line				;#	If line's numeric value is outside incrementable range, just copy it
					}
					lappend nulines $nuline
					set lines [lreplace $lines $n $n]	;#	Delete original line from list so search loop doesn't find 4 or 14 in entry "a142xx"
					set vals_in_line [lreplace $vals_in_line $n $n]
					set gotit 1
					incr len -1
					break
				}
			}
			if {!$gotit} {								;#	If found line ("gotit"), line deleted from list, so "n" NOT incremented
				incr n
			}
		}
	}
	switch -- $listing {
		"proplisting" {
			set old_proplist [$proplisting get 0 end]
			$proplisting delete 0 end
			set cnt 0
			foreach line $nulines {
				$proplisting insert end $line
				incr cnt
			}
			set propfcnt $cnt
		} 
		"prop_coll" {
			set prop_coll $nulines
		}
	}
}

#----- Cycle property list entries round values of a particular property (or random permute according to such values)

proc CycleOnField {random} {
	global propch proplisting old_proplist propfcnt
	set vals {}
	if {$propch < 1} {
		Inf "No Property Chosen"
		return
	}
	foreach line [$proplisting get 0 end] {
		lappend lines $line
		set line [split $line]
		set val [lindex $line $propch]
		lappend vals_in_line $val
		set k [lsearch -exact $vals $val]
		if {$k < 0} {
			lappend vals $val
		}
	}
	if {!$random} {
		set vals [lsort $vals]
	} elseif {[llength $vals] > 2} {
		set lastval [lindex $vals end]
		set vals [RandomiseValOrder $vals $lastval]
	}

	set n 0
	foreach val $vals {
		set cnt 0
		foreach line $lines val_in_line $vals_in_line {
			if {[string match $val $val_in_line]} {
				lappend sorted_lines($val) $line
				incr cnt
			}
		}
		if {$n == 0} {
			set mincnt $cnt
		} elseif {$cnt < $mincnt} {
			set mincnt $cnt
		}
		incr n
	}
	foreach val $vals {	;# This ensures we don't use the first few items in list, over & over
		set sorted_lines($val) [RandomiseLineOrder $sorted_lines($val)]
	}
	set old_proplist [$proplisting get 0 end]
	$proplisting delete 0 end
	set cnt 0
	while {$cnt < $mincnt} {
		foreach val $vals {
			lappend nulines [lindex $sorted_lines($val) $cnt]
		}
		incr cnt
	}
	set cnt 0
	foreach line $nulines {
		$proplisting insert end $line
		incr cnt
	}
	set propfcnt $cnt
}

#----- Randomise order of linesin a list of lines

proc RandomiseLineOrder {lines} {

	set cnt [llength $lines]
	set n 0
	set nulist {}
	while {$n < $cnt} {
		set t [expr int(floor(rand() * double($n + 1)))]
		if {$t == $n} {
			set nunulist [list [lindex $lines $n]]
			set nulist [concat $nunulist $nulist]
		} else {
			set nulist [linsert $nulist $t [lindex $lines $n]]
		}
		incr n
	}
	return $nulist
}

#----- Randomise sequence of vals of a particular property 

proc RandomiseValOrder {vals lastval} {	;# Ensure first val of new perm != lastval of previousv perm

	set cnt [llength $vals]
	set finished 0
	while {!$finished} {
		set n 0
		set nulist {}
		while {$n < $cnt} {
			set t [expr int(floor(rand() * double($n + 1)))]
			set nunulist [list [lindex $vals $n]]
			if {$t == $n} {
				set nulist [concat $nunulist $nulist]
			} else {
				set nulist [linsert $nulist $t $nunulist]
			}
			incr n
		}
		if {![string match [lindex $nulist 0] $lastval]} {
			set finished 1
		}
	}
	return $nulist
}

#----- Randomise orer of lines in property listing

proc PropsListRand {} {
	global old_proplist proplisting 

	set old_proplist [$proplisting get 0 end]
	set nulines [RandomiseLineOrder $old_proplist]
	$proplisting delete 0 end
	foreach line $nulines {
		$proplisting insert end $line
	}
}

#---- Add directory path to files listed in property file

proc InsertFileDirProps {filedir linecnt} {
	global propfile
	set n 0
	while {$n < $linecnt} {
		set thisline [lindex $propfile $n]
		set fnam [lindex $thisline 0]
		set fnam [file join $filedir $fnam]
		set thisline [lreplace $thisline 0 0 $fnam]
		set propfile [lreplace $propfile $n $n $thisline]
		incr n
	}
}

#---- Enter directory to be used for sounds on property-listing

proc GetPropFileDir {} {
	global pr_propdir propdir evv
	set f .prop_dir
	if [Dlg_Create $f "FILE DIRECTORY" "set pr_propdir 0" -borderwidth $evv(BBDR)] {
		frame $f.0 -borderwidth $evv(BBDR)
		frame $f.1 -borderwidth $evv(BBDR)
		button $f.0.ok -text "Keep It" -command {set pr_propdir 1} -width 10 -highlightbackground [option get . background {}]
		button $f.0.qu -text "Abandon It" -command {set pr_propdir 0} -width 10 -highlightbackground [option get . background {}]
		pack $f.0.ok -side left
		pack $f.0.qu -side right
		label $f.1.ll -text "Directory for\nfiles in\nproperty list"
		entry $f.1.e -textvariable propdir -width 48
		pack $f.1.ll $f.1.e -side left -padx 8
		pack $f.0 $f.1 -side top -pady 2 -fill x -expand true		
		bind $f <Escape> {set pr_propdir 0}
		bind $f <Return> {set pr_propdir 1}
	}
#	set propdir ""
	set pr_propdir 0
	set finished 0
	raise $f
	My_Grab 0 $f pr_propdir $f.1.e
	while {!$finished} {
		tkwait variable pr_propdir
		if {$pr_propdir} {
			if {[string length $propdir] <= 0} {
				Inf "No Directory Name Entered"
				continue
			}
			if {![file isdirectory $propdir]} {
				Inf "'$propdir' Is Not A Valid Directory Name"
				continue
			}
			set zog $propdir
			set finished 1
		} else {
			set zog ""
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $zog
}

#---- Make new property list having one each value of specified property

proc OneOfEach {} {
	global propch proplisting old_proplist propfcnt
	set vals {}
	if {$propch < 1} {
		Inf "No Property Chosen"
		return
	}
	foreach line [$proplisting get 0 end] {
		set origline $line
		set line [split $line]
		set val [lindex $line $propch]
		set k [lsearch -exact $vals $val]
		if {$k < 0} {
			lappend vals $val
			lappend nulines $origline
		}
	}
	set old_proplist [$proplisting get 0 end]
	$proplisting delete 0 end
	set cnt 0
	foreach line $nulines {
		$proplisting insert end $line
		incr cnt
	}
	set propfcnt $cnt
}

#---- Pitch values to MIDI

proc PropsPtoM {fromstats} {
	global propch proplisting old_proplist propall_list props_ranked stats_to_midi com

	Block "Midi Conversion"
	set cnt 0
		if {$fromstats} {
		if {[info exists props_ranked]} {
			foreach vals [$propall_list get 0 end] {
				set vals [string trim $vals]
				set vals [split $vals]
				set valset 0
				foreach item $vals {
					if {[string length $item] > 0} {
						if {$valset} {
							set val2 $item
							break
						} else {
							set val $item
							set valset 1
						}
					}
				}
				set midival [PropPtoM $val $cnt]
				if {[regexp {^-1$} $midival]} {
					Inf "Not All Property Values Are Of Pitch Notation Type"
					UnBlock
					return
				}
				append midival "      " $val2				
				lappend midivals $midival
				incr cnt
			}
		} else {
			foreach val [$propall_list get 0 end] {
				set midival [PropPtoM $val $cnt]
				if {[regexp {^-1$} $midival]} {
					Inf "Not All Property Values Are Of Pitch Notation Type"
					UnBlock
					return
				}				
				lappend midivals $midival
				incr cnt
			}
		}
	} else {
		if {$propch < 1} {
			Inf "No Property Chosen"
			UnBlock
			return
		}
		foreach line [$proplisting get 0 end] {
			set line [split $line]
			lappend nulines $line
			set val [lindex $line $propch]
			set midival [PropPtoM $val $cnt]
			if {[regexp {^-1$} $midival]} {
				Inf "Not All Property Values Are Of Pitch Notation Type"
				UnBlock
				return
			}				
			lappend midivals $midival
			incr cnt
		}
	}
	if {$fromstats} {
		$propall_list delete 0 end
		foreach line $midivals {
			$propall_list insert end $line
		}
	} else {
		set n 0
		while {$n < $cnt} {
			set line [lindex $nulines $n]
			set midival [lindex $midivals $n]
			set line [lreplace $line $propch $propch $midival]
			set nulines [lreplace $nulines $n $n $line]
			incr n
		}
		set old_proplist [$proplisting get 0 end]
		$proplisting delete 0 end
		foreach line $nulines {
			$proplisting insert end $line
		}
	}
	UnBlock
}

#----  MIDI values to Pitch 

proc PropsMtoP {fromstats} {
	global propch proplisting old_proplist com propall_list props_ranked 

	Block "Midi Conversion"
	set cnt 0
	if {$fromstats} {
		if {[info exists props_ranked]} {
			foreach vals [$propall_list get 0 end] {
				set vals [string trim $vals]
				set vals [split $vals]
				set valset 0
				foreach item $vals {
					if {[string length $item] > 0} {
						if {$valset} {
							set val2 $item
							break
						} else {
							set val $item
							set valset 1
						}
					}
				}
				set pitchval [PropMtoP $val]
				if {[string match $pitchval "Z"]} {
					Inf "Not All Property Values Are Of MIDI Type"
					UnBlock
					return
				}
				append pitchval "      " $val2				
				lappend pitchvals $pitchval
				incr cnt
			}
		} else {
			foreach val [$propall_list get 0 end] {
				set pitchval [PropMtoP $val]
				if {[string match $pitchval "Z"]} {
					Inf "Not All Property Values Are Of MIDI Type"
					UnBlock
					return
				}				
				lappend pitchvals $pitchval
				incr cnt
			}
		}
	} else {
		if {$propch < 1} {
			Inf "No Property Chosen"
			UnBlock
			return
		}
		foreach line [$proplisting get 0 end] {
			set line [split $line]
			lappend nulines $line
			set val [lindex $line $propch]
			set pitchval [PropMtoP $val]
			if {[string match $pitchval "Z"]} {
				Inf "Not All Property Values Are Of MIDI Type"
				UnBlock
				return
			}				
			lappend pitchvals $pitchval
			incr cnt
		}
	}
	if {$fromstats} {
		$propall_list delete 0 end
		foreach line $pitchvals {
			$propall_list insert end $line
		}
	} else {
		set n 0
		while {$n < $cnt} {
			set line [lindex $nulines $n]
			set pitchval [lindex $pitchvals $n]
			set line [lreplace $line $propch $propch $pitchval]
			set nulines [lreplace $nulines $n $n $line]
			incr n
		}
		set old_proplist [$proplisting get 0 end]
		$proplisting delete 0 end
		foreach line $nulines {
			$proplisting insert end $line
		}
	}
	UnBlock
}

#----  One Pitch  value to MIDI

proc PropPtoM {val lineno} {
	global proplisting
	global mu
	set origval $val
	set bracketed 0
	set isqueried 0
	set bigmsg "Unknown pitch-notation value found with sound [file tail [lindex [split [$proplisting get $lineno]] 0]]"

	if {[regexp {^gli} $val] || [string match "-" $val]} {
		return $val
	}
	set k [string first "?" $val]
	if {$k >= 0} {
		set isqueried 1
		set val [string range $val 0 [expr $k - 1]]
	}
	if [string match "(" [string index $val 0]] {
		set len [string length $val]
		incr len -1
		if {![string match ")" [string index $val $len]]} {
			Inf $bigmsg
			return -1
		} else {
			incr len -1
			set val [string range $val 1 $len]
			set bracketed 1
		}
	}
	if {[string length $val] < 2} {
		if {$isqueried} {
			return "??"
		}
		Inf $bigmsg
		return -1
	}
	set isneg 0
	set numbernext 0
	set k 0
	switch -- [string index [string toupper $val] $k] {
		"C" { set midival 0}
		"D" { set midival 2}
		"E" { set midival 4}
		"F" { set midival 5}
		"G" { set midival 7}
		"A" { set midival 9}
		"B" { set midival 11}
		default { 
			Inf $bigmsg
			return -1
		}
	}
	incr k
	set next [string index $val $k]
	switch -- $next {
		"#" {
			incr midival
			incr k
			if {[string length $val] < [expr $k + 1]} {
				Inf $bigmsg
				return -1
			}
		}
		"b" {
			incr midival -1
			incr k
			if {[string length $val] < [expr $k + 1]} {
				Inf $bigmsg
				return -1
			}
		}
		"-" {
			set isneg 1
			set numbernext 1
			incr k
			if {[string length $val] < [expr $k + 1]} {
				Inf $bigmsg
				return -1
			}
		}
		default {
			if {![IsNumeric $next]} {
				Inf $bigmsg
				return -1
			} else {
				set numbernext 1
			}
		}
	}
	set next [string index $val $k]
	if {!$numbernext} {
		if {[string match "-" $next]} {
			set isneg 1
			incr k
			if {[string length $val] < [expr $k + 1]} {
				Inf $bigmsg
				return -1
			}
		}
	}
	set next [string range $val $k end]
	if {![IsNumeric $next]} {
		Inf $bigmsg
		return -1
	}
	set next [expr round($next)]
	if {($next < 0) || ($next > 5)} {
		Inf $bigmsg
		return -1
	}
	if {$isneg} {
		set next [expr -$next]
	}
	incr next 5
	set next [expr $next * 12]
	set midival [expr $midival + $next]
	if {($midival < $mu(MIDIMIN)) || ($midival > $mu(MIDIMAX))} {
		Inf "MIDIval Out Of  Range For Pitch-Notation Value Found i.e. $origval"
		return -1
	}
	if {$bracketed} {
		set out "("
		append out $midival ")"
		if {$isqueried} {
			append out "?"
		}
		return $out
	}
	if {$isqueried} {
		append midival "?"
	}
	return $midival
}

#----  One MIDI value to Pitch

proc PropMtoP {val} {
	global mu
	set origval $val
	set bracketed 0
	set isqueried 0
	if {[regexp {^gli} $val] || [string match "-" $val]} {
		return $val
	}
	set k [string first "?" $val]
	if {$k >= 0} {
		set isqueried 1
		set val [string range $val 0 [expr $k - 1]]
	}
	if [string match "(" [string index $val 0]] {
		set len [string length $val]
		incr len -1
		if {![string match ")" [string index $val $len]]} {
			Inf "Unknown MIDI-Notation Value Found i.e. $origval"
			return -1
		} else {
		    incr len -1
			set bracketed 1
			set val [string range $val 1 $len]
		}
	}
	if {[string length $val] <= 0} {
		if {$isqueried} {
			return "??"
		} else {
			Inf "Unknown MIDI-Notation Value Found i.e. $origval"
			return "Z"
		}
	}
	if {![IsNumeric $val]} {
		Inf "Unknown MIDI-Notation Value found i.e. $origval"
		return "Z"
	}
	set val [expr round($val)]
	if {($val < $mu(MIDIMIN)) || ($val > $mu(MIDIMAX))} {
		Inf "MIDI-Notation Value Out Of Range  i.e. $origval"
		return "Z"
	}
	set oct [expr ($val/12) - 5]
	set pitch [expr $val % 12]
	switch -- $pitch {
		"0" {set pitch "C"}
		"1" {set pitch "C#"}
		"2" {set pitch "D"}
		"3" {set pitch "D#"}
		"4" {set pitch "E"}
		"5" {set pitch "F"}
		"6" {set pitch "F#"}
		"7" {set pitch "G"}
		"8" {set pitch "G#"}
		"9" {set pitch "A"}
		"10" {set pitch "A#"}
		"11" {set pitch "B"}
	}
	append pitch $oct
	if {$bracketed} {
		set out "("
		append out $pitch ")"
		if {$isqueried} {
			append out "?"
		}
		return $out
	}
	if {$isqueried} {
		append pitch "?"
	}
	return $pitch
}

#----  Find min or max value (of numeric valuess)

proc PropMinimax {type} {
	global com propall_list wstk props_ranked

	set cntr 0
	foreach val [array names com] {
		incr cntr
	}
	set cnt 0
	set isnumeric_checked 0
	if {[info exists props_ranked]} {
		foreach val [array names com] {
			lappend vals $val
			if {![IsNumeric $val]} {
				if {!$isnumeric_checked} {
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
						-message "Property Values Are Not (All) Numeric: (e.g.  $val ) Proceed ??"]
					if {$choice == "no"} {
						return
					} else {
						set isnumeric_checked 1
					}
				} 
				continue
			}
			if {$cnt == 0} {
				set exval $val
			}  else {
				switch -- $type {
					0 {	
						if {$exval < $val} {
							set exval $val
						}
					}
					1 {	
						if {$exval > $val} {
							set exval $val
						}
					}
				}
			}
			incr cnt
		}
	} else {
		foreach val [$propall_list get 0 end] {
			lappend vals $val
			if {![IsNumeric $val]} {
				if {!$isnumeric_checked} {
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
						-message "Property Values Are Not (All) Numeric: (e.g.  $val ) Proceed ??"]
					if {$choice == "no"} {
						return
					} else {
						set isnumeric_checked 1
					}
				} 
				continue
			}
			if {$cnt == 0} {
				set exval $val
			}  else {
				switch -- $type {
					0 {	
						if {$exval < $val} {
							set exval $val
						}
					}
					1 {	
						if {$exval > $val} {
							set exval $val
						}
					}
				}
			}
			incr cnt
		}
	}
	if {![info exists exval]} {
		Inf "No Numeric Values Found"
		return
	}
	if {$isnumeric_checked} {
		set msg "Of The Numeric Values : "
	} else {
		set msg ""
	}
	switch -- $type {
		0 {append msg "Max Value Is " $exval}	
		1 {append msg "Min Value Is " $exval}	
	}
	Inf $msg
}

#----  Most or least common value of a specific property

proc PropCommon {} {
	global propall_list com props_ranked

	set cnt 0
	Block "RANKING PROPERTIES"
	if {[info exists props_ranked]} {
		return
	}
	foreach val [array names com] {
		if {$cnt == 0} {
			lappend prvals $val
			lappend prcnts $com($val)	
		} else {
			set done 0
			set cnt2 0
			foreach prval $prvals prcnt $prcnts {
				if {$com($val) >= $prcnt} {
					set prcnts [linsert $prcnts $cnt2 $com($val)]
					set prvals [linsert $prvals $cnt2 $val]
					set done 1
					break
				}
				incr cnt2
			} 
			if {!$done} {
				lappend prcnts $com($val)
				lappend prvals $val
			}
		}
		incr cnt
	}
	$propall_list delete 0 end
	foreach prval $prvals prcnt $prcnts {
		set line $prval
		append line "      " $prcnt
		$propall_list insert end $line
	}
	set props_ranked 1 
	UnBlock
}

#----  All values of a specific property

proc PropAll {} {
	global propch proplisting pr_propall prprfil propall_list propname com orig_propall_list props_ranked evv

	if {$propch < 1} {
		Inf "No Property Chosen"
		return
	}
	catch {unset com}
	catch {unset props_ranked}
	foreach line [$proplisting get 0 end] {
		set line [split $line]
		set val [lindex $line $propch]
		if {![info exists com($val)]} {
			set com($val) 1
		} else {
			incr com($val)
		}
	}
	if {![info exists com]} {
		Inf "No Values Exist For This Property"
		return
	}
	set f .propall
	if [Dlg_Create $f "PROPERTY VALUES OF $propname($propch)" "set pr_propall 0" -borderwidth $evv(BBDR)] {
		frame $f.0 -borderwidth $evv(BBDR)
		frame $f.1 -borderwidth $evv(BBDR)
		frame $f.2 -borderwidth $evv(BBDR)
		button $f.2.pri	-text "Print To File" -command {PrintPropsToFile allprops}  -highlightbackground [option get . background {}]
		label $f.2.ll -text "Filename"
		entry $f.2.e -textvariable prprfil -width 48
		menubutton $f.0.s -text "More Data on Props" -menu $f.0.s.menu -relief raised -width 22
		button $f.0.g -text "Select Val" -command {GetPropVal propall} -highlightbackground [option get . background {}]
		set mm [menu $f.0.s.menu -tearoff 0]
		$mm add command -label "Count Property Values" -command {CountProps} -foreground black
		$mm add separator
		$mm add command -label "Sort Properties" -command {SortProps} -foreground black
		$mm add separator
		$mm add command -label "Rank Values, Most Commom First" -command {PropCommon} -foreground black
		$mm add separator ;# -background $evv(HELP)
		$mm add command -label "NUMERIC VALUES" -command {}  -foreground black
		$mm add separator ;# -background $evv(HELP)
		$mm add command -label "Highest Value" -command {PropMinimax 0} -foreground black
		$mm add separator
		$mm add command -label "Lowest Value" -command {PropMinimax 1} -foreground black
		$mm add separator ;# -background $evv(HELP)
		$mm add command -label "PITCH VALUES" -command {}  -foreground black
		$mm add separator ;# -background $evv(HELP)
		$mm add command -label "Pitch To Midi" -command {PropsPtoM 1} -foreground black
		$mm add separator
		$mm add command -label "Midi To Pitch" -command {PropsMtoP 1} -foreground black
		button $f.0.q	-text "Close" -command {set pr_propall 0} -highlightbackground [option get . background {}]
		pack $f.0.s $f.0.g -side left -padx 2
		pack $f.0.q -side right
		set propall_list [Scrolled_Listbox $f.1.ll -width 48 -height 24 -selectmode multiple]
		pack $f.1.ll -side left -fill both -expand true
		pack $f.2.pri $f.2.e $f.2.ll -side left -padx 2 -fill x -expand true
		pack $f.0 $f.1 $f.2 -side top -fill x -expand true
		bind $f <Escape> {set pr_propall 0}
	}
	wm title $f "PROPERTY VALUES OF $propname($propch)"
	raise $f
	update idletasks
	StandardPosition $f
	$propall_list delete 0 end
	catch {unset orig_propall_list}
	foreach val [array names com] {
		lappend orig_propall_list $val
		$propall_list insert end $val
	}
	set pr_propall 0
	My_Grab 0 $f pr_propall $propall_list
	tkwait variable pr_propall
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- Sort existing (different) values of prop alphabetically or numerically

proc SortProps {} {
	global propall_list orig_propall_list props_ranked
	set isnum 1
	Block "SORTING PROPERTIES"
	if {[info exists props_ranked]} {
		foreach item $orig_propall_list {
			if {$isnum && (![IsNumeric $item])} {
				set isnum 0
			}
			lappend tl $item
		}
		unset props_ranked
	} else {
		foreach item [$propall_list get 0 end] {
			if {$isnum && (![IsNumeric $item])} {
				set isnum 0
			}
			lappend tl $item
		}
	}
	set listlen [llength $tl]
	set listlen_less_one $listlen
	incr listlen_less_one -1
	switch -- $isnum {
		0 {
			foreach fnam [lsort -dictionary $tl] {
				lappend newlist $fnam
			}
			set tl $newlist
		}
		1 {
			set n 0
			while {$n < $listlen_less_one} {
				set thisval [lindex $tl $n]
				set m $n
				incr m
				while {$m < $listlen} {
					set thatval [lindex $tl $m]
					if {$thatval < $thisval} {
						set tl [lreplace $tl $n $n $thatval]
						set tl [lreplace $tl $m $m $thisval]
						set thisval $thatval
					}
					incr m
				}
				incr n
			}
		}
	}
	$propall_list delete 0 end
	foreach item $tl {
		$propall_list insert end $item
	}
	UnBlock
}

#----  Print list pf property-listing, sounds in prop-listing, or vals of specific prop, to a textfile

proc PrintPropsToFile {which} {
	global prprfil prprset prpifil propall_list propident_list wstk propsets_list evv

	switch -- $which {
		"propsets" {
			set plist $propsets_list
			set fnam $prprset
			set this_ext $evv(TEXT_EXT)
		}
		"allprops" {
			set plist $propall_list
			set fnam $prprfil
			set this_ext $evv(TEXT_EXT)
		}
		"sndidenticals" {
			set plist $propident_list
			set fnam $prpifil
			set this_ext [GetTextfileExtension sndlist]
		}
		"identicals" {
			set plist $propident_list
			set fnam $prpifil
			set this_ext [GetTextfileExtension props]
		}
	}

	if {![ValidCdpFilename $fnam 1]} {
		return
	}
	append fnam $this_ext
	if {[file exists $fnam]} {
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
			-message "File '$fnam' Already Exists: Overwrite It??"]
		if {$choice == "no"} {
			return
		}
	}
	if [catch {open $fnam "w"} zit] {
		Inf "Cannot Open File File '$fnam' To Write The List"
		return
	}
	switch -- $which {
		"sndidenticals" {
			foreach line [$plist get 0 end] {
				set item [lindex $line 0]
				puts $zit $item
			}
		}
		default {
			foreach item [$plist get 0 end] {
				puts $zit $item
			}
		}
	}
	close $zit
	FileToWkspace $fnam 0 0 0 0 1
	Inf "New File '$fnam' Is Now On The Workspace"
}

#----  Find sound(s) with identical sets of properties

proc FindIdenticals {selected} {
	global proplisting propcnt propchv pr_propident propident_list prpifil evv

	Block "Searching for Files with Identical Properties"
	foreach line [$proplisting get 0 end] {
		set line [split $line]
		lappend lines $line
	}
	set markedlinelen [llength $line]
	incr markedlinelen	;#	LENGTH OF A LINE WHICH HAS A MARK

	set len [llength $lines]
	set len_less_one $len
	incr len_less_one -1
	set n 0 
	while {$n < $len_less_one} {
		set m $n
		incr m
		set line_n [lindex $lines $n]
		if {[llength $line_n] == $markedlinelen} {		;#	MATCHES FOR FILE HAVE ALREADY BEEN FOUND
			incr n
			continue
		} elseif {$selected == 2} {
			set hasprop 1
			set k 1
			while {$k < $propcnt} {
				if {$propchv($k) && [string match [lindex $line_n $k] "-"]} {
					set hasprop 0
					break
				}
				incr k
			}
			if {!$hasprop} {
				incr n 
				continue
			}
		}
		set firstmatch 1
		while {$m < $len} {
			set matched 1
			set line_m [lindex $lines $m]
			if {[llength $line_m] == $markedlinelen} {		;#	MATCHES FOR FILE HAVE ALREADY BEEN FOUND
				incr m
				continue
			}
			set k 1
			while {$k < $propcnt} {
				if {!$selected || $propchv($k)} {
					if {![string match [lindex $line_n $k] [lindex $line_m $k]]} {
						set matched 0
						break
					}
				}
				incr k
			}
			if {$matched} {
				if {$firstmatch} {
					lappend line_n $n			;#	MARK AS MATCHED, BY INCREASING llength
					set lines [lreplace $lines $n $n $line_n]
					lappend matches $line_n
					set firstmatch 0
				}
				lappend line_m $n				;#	MARK AS MATCHED, BY INCREASING llength
				set lines [lreplace $lines $m $m $line_m]
				lappend matches $line_m
			}
			incr m
		}
		incr n
	}
	UnBlock
	if {![info exists matches]} {
		Inf "There Are No Files With Matching Properties"
		return
	}

	set f .propident
	if [Dlg_Create $f "FILES WITH IDENTICAL PROPERTY SETS" "set pr_propident 0" -borderwidth $evv(BBDR)] {
		frame $f.0 -borderwidth $evv(BBDR)
		frame $f.1 -borderwidth $evv(BBDR)
		button $f.0.all	-text "All to Top Page" -command {MoveGroupsToTop 0} -highlightbackground [option get . background {}]
		button $f.0.sel	-text "Keep Selected" -command {MoveGroupsToTop 1} -highlightbackground [option get . background {}]
		button $f.0.dum	-text "                    \n" -command {} -bd 0 -highlightbackground [option get . background {}]
		button $f.0.pri	-text "Print List" -command {PrintPropsToFile identicals} -highlightbackground [option get . background {}]
		button $f.0.prs	-text "Print Sndnames" -command {PrintPropsToFile sndidenticals} -highlightbackground [option get . background {}]
		label $f.0.l -text Filename
		entry $f.0.e -textvariable prpifil -width 48
		button $f.0.q	-text "Close" -command {set pr_propident 0} -highlightbackground [option get . background {}]
		pack $f.0.all $f.0.sel $f.0.dum $f.0.pri $f.0.prs $f.0.l $f.0.e -side left -padx 2
		pack $f.0.q -side right
		set propident_list [Scrolled_Listbox $f.1.ll -width 128 -height 24 -selectmode extended]
		pack $f.1.ll -side left -fill both -expand true
		pack $f.1 $f.0 -side top
		bind $f <Escape> {set pr_propident 0}
	}
	raise $f
	update idletasks
	StandardPosition $f
	$propident_list delete 0 end
	set firstline [lindex $matches 0]
	set len [llength $firstline]
	incr len -2
	set thismatch [lindex $firstline end]
	$propident_list insert end [lrange $firstline 0 $len]
	foreach line [lrange $matches 1 end] {
		set thisgrp [lindex $line end]
		if {$thisgrp != $thismatch} {
			$propident_list insert end ""
			set thismatch $thisgrp
		}
		$propident_list insert end [lrange $line 0 $len]
	}
	set pr_propident 0
	My_Grab 0 $f pr_propident $propident_list
	tkwait variable pr_propident
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	if {$selected} {
		Reset_Do_Props
	}
}

#--- Remove or Add new propvals, or add or remove entire property, to/from existing propsfile

proc Add_Prop {pflag} {
	global pr_addprops wstk pa evv
	global propch wl orig_propfile propname propfile propcnt proplisting propfiles_list
	global new_propname new_propval propnamelisting new_propvalfile all_mark_list chlist old_props_protocol

	set delete_entire_prop 0
	set from_marked 0
	set add_vector 0
	set add_void 0
	set is_a_known_propfile -1

	Block "Checking File Consistency"
	set ilist [$wl curselection]
	if {[string length $ilist] <= 0} {
		if {[info exists chlist]} {
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
	if {[string length $ilist] <= 0} {
		Inf "No File Selected"
		UnBlock
		return
	}
	switch -regexp -- $pflag \
		^$evv(DELETE_ENTIRE_PROP)$ { set delete_entire_prop 1 } \
		^$evv(ADD_VOID_PROP)$	   { set add_void 1			  } \
		^$evv(ADD_VECTOR_PROP)$	   { set add_vector 1		  }

	catch {unset propfile}
	if {$delete_entire_prop || $add_void} {
		if {[llength $ilist] != 1} {
			Inf "Choose A User-property Textfile Only"
			UnBlock
			return
		}
	} elseif {[llength $ilist] < 2} {
		if {!$add_vector} {
			Inf "Choose A User-Property Textfile & At Least One Soundfile Mentioned In The Props-File"
			UnBlock
			return
		}
	}
	if {$add_vector} {
		if {[llength $ilist] != 2} {
			Inf "Choose A User-Property Textfile & A Textfile With A List Of Property Values (Property Vector)"
			UnBlock
			return
		}
	}
	set got_sounddir 0
	set got_propfile 0
	set got_vector 0
	set veccnt 0
	foreach i $ilist {
		set fnam [$wl get $i]
		if {$pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)} {
			if {$got_propfile} {					;#	IF ALREADY FOUND A PROPFILE
				if {$add_vector} {
					if [catch {open $fnam "r"} zit] {
						Inf "Cannot Open Text File '$fnam'"
						UnBlock
						return
					}										;#	IF WE'VE NOT ALREADY GOT A PROPFILE
					set linecnt 1					;#	IF WE'RE ALSO LOOKING FOR A VECTOR FILE
					while {[gets $zit line] >= 0} {	;# GET VECTOR TEXTFILE ONLY
						set veclinecnt 0
						set line [string trim $line]
						set line [split $line]
						foreach item $line {
							set item [string trim $item]
							if {[string length $item] > 0} {
								incr veclinecnt
							}
						}
						if {$veclinecnt != 1} {
							Inf "Number Of Vector Entries > 1 On Line $linecnt"
							close $zit
							UnBlock
							return
						}
						lappend vecfile $item
						incr linecnt
					}
					close $zit
					if {![info exists vecfile]} {
						Inf "Vector File '$fnam' Is Empty"
						UnBlock
						return
					}
					set veccnt [llength $vecfile]
					if {$veccnt != [llength $propfile]} {
						Inf "Number Of Soundfiles Listed In Properties File\nDoes Not Correspond To Number Of Vector Values"
						UnBlock
						return
					}
												;# IF WE'RE NOT LOOKING FOR A VECTOR-FILE
				} else {								
					Inf "Choose Only One (User-Property) Textfile & Soundfiles Mentioned In The Props-File, Only"
					UnBlock
					return
				}
			} 
			if [catch {open $fnam "r"} zit] {
				Inf "Cannot Open Text File '$fnam'"
				UnBlock
				return
			}										;#	IF WE'VE NOT ALREADY GOT A PROPFILE
			if {!$got_propfile} {					;#	COULD BE A VECTOR OR A PROPFILE
				if {[info exists propfiles_list]} {
					set is_a_known_propfile [lsearch $propfiles_list $fnam]
				} else {
					set is_a_known_propfile -1
				}
				while {[gets $zit line] >= 0} {
					lappend propfile $line
				}
				if {![info exists propfile]} {
					Inf "File '$fnam' Is Empty"
					if {$is_a_known_propfile >= 0} {
						set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
					}
					close $zit
					UnBlock
					return
				}
				if {[llength $propfile] < 2} {		;#	CANNOT BE A VALID PROPFILE: COULD BE A VECTOR
					if {$add_vector && !$got_vector} {
						set vecfile $propfile
						unset propfile
						set veccnt 1
						set got_vector 1
						catch {close $zit}
						continue
					} else {
						Inf "'$fnam' Is Not A Valid Properties File"
						if {$is_a_known_propfile >= 0} {
							set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
						}
						close $zit
						UnBlock
						return
					}
				}
				close $zit
				set linecnt 0
				set propcnt 0
				set doing_vector 0
				foreach line $propfile {
					set this_propcnt 0
					catch {unset nuline}
					set line [string trim $line]
					set line [split $line]
					foreach item $line {
						set item [string trim $item]
						if {[string length $item] > 0} {
							lappend nuline $item
							incr this_propcnt
						}
					}
					if {$this_propcnt > 0} {
						if {$linecnt == 0} {			;# FIRST LINE, SPECIAL CASE FOR PROPS FILES
							set propcnt $this_propcnt
							incr propcnt	;# lines to follow have filename, as well as props (if they're property files)
						} elseif {$doing_vector} {		;# IF WE'VE ALREADY DECIDED IT'S NOT A PROPFILE, BUT A VECTOR FILE
							if {$this_propcnt != 1} {
								Inf "Number Of Vector Entries > 1 On Line [expr $linecnt + 1]"
								UnBlock
								return
							}							;# IF WE'RE NOT LOOKING FOR A VECTOR FILE, BUT A PROP FILE
						} elseif {!$add_vector || $got_vector} {
							if {$propcnt != $this_propcnt} {
								Inf "Number Of Properties Incorrect On Line [expr $linecnt + 1]"
								if {$is_a_known_propfile >= 0} {
									set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
								}
								UnBlock
								return
							} else {
								set z_fnam [lindex $nuline 0]
								if {$old_props_protocol} {
									if {![string match $z_fnam [file tail $z_fnam]]} {
										Inf "Sound File Directories Found In File: Will Not Work With Old Protocol"
										if {$is_a_known_propfile >= 0} {
											set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
										}
										UnBlock
										return
									}
								} else { 
									if {[string match $z_fnam [file tail $z_fnam]]} {
										Inf "Sounds Without Directory Paths Found In File: Will Not Work With New Protocol"
										if {$is_a_known_propfile >= 0} {
											set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
										}
										UnBlock
										return
									}
								}
							}
						} else {						;#	ELSE (at line 2) IT'S EITHER A VECTOR FILE OR A PROPERTY FILE
							if {($propcnt == 2) && ($this_propcnt == 1)} {
								set doing_vector 1
							} elseif {$propcnt != $this_propcnt} {
								Inf "Number Of Properties Incorrect On Line [expr $linecnt + 1]"
								if {$is_a_known_propfile >= 0} {
									set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
								}
								UnBlock
								return
							} else {
								set z_fnam [lindex $nuline 0]
								if {$old_props_protocol} {
									if {![string match $z_fnam [file tail $z_fnam]]} {
										Inf "Sound File Directories Found In File: Will Not Work With Old Protocol"
										if {$is_a_known_propfile >= 0} {
											set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
										}
										UnBlock
										return
									}
								} else { 
									if {[string match $z_fnam [file tail $z_fnam]]} {
										Inf "Sounds Without Directory Paths Found In File: Will Not Work With New Protocol"
										if {$is_a_known_propfile >= 0} {
											set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
										}
										UnBlock
										return
									}
								}
							}
						}
						lappend nupropfile $nuline
						incr linecnt 
					}
				}
				if {$linecnt <= 0} {
					Inf "No Values Found In File"
					if {$is_a_known_propfile >= 0} {
						set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
					}
					UnBlock
					return
				}
				if {$doing_vector} {		;#	IF WE'VE RECOGNISED A VECTOR FILE (ONLY POSSIBLE IF LOOKING FOR ONE!)
					set vecfile $nupropfile
					unset propfile
					unset nupropfile
					set propcnt 0
					set veccnt $linecnt
					set got_vector 1
					continue
				}				;#	FROM HERE, CAN ONLY BE A PROPFILE
				set n 1
				foreach item [lindex $nupropfile 0] {
					set propname($n) $item
					incr n
				}
				set propfile [lrange $nupropfile 1 end]
				incr linecnt -1
				if {$linecnt <= 0} {
					Inf "No Properties (Only Property Names) Found In File"
					if {$is_a_known_propfile >= 0} {
						set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
					}
					UnBlock
					return
				}
				if {$got_vector} {	;#	IF WE'D PREVIOUSLY ALSO GOT A VECTOR
					if {$veccnt != $linecnt} {
						Inf "Number Of Soundfiles Listed In Properties File\nDoes Not Correspond To Number Of Vector Values"
						UnBlock
						return
					}
				}
				set got_propfile 1
				if {$delete_entire_prop || $add_void} {
					break
				}
			}
		} elseif {$delete_entire_prop || $add_void} {
			Inf "Choose A User-Property Textfile Only"
			UnBlock
			return
		} elseif {$add_vector} {
			Inf "Choose A User-Property Textfile And A Textfile With A List Of Property-Values (A Vector File)"
			UnBlock
			return
		}
	}
	if {!$add_void && !$add_vector} {
		if {$old_props_protocol} {
			set thisline [lindex $propfile 0]
			set fnam [lindex $thisline 0]
			if {![file exists $fnam] || [file isdirectory $fnam]} {
				set filedir [GetPropFileDir]
				if {[string length $filedir] <= 0} {
					UnBlock
					return
				} else {
					InsertFileDirProps $filedir $linecnt
				}
			}
		}
		set n 0
		while {$n < $linecnt} {
			set thisline [lindex $propfile $n]
			set fnam [lindex $thisline 0]
			if {![file exists $fnam] || [file isdirectory $fnam]} {
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] \
					-message "File '$fnam' No Longer Exists\n\nDo You Want To Proceed??"]
				if {$choice == "no"} {
					UnBlock
					return
				}
				set propfile [lreplace $propfile $n $n]
				incr n -1
				incr linecnt -1
			}
			incr n
		}
		if {$linecnt <= 0} {
			Inf "The Property List Files May All Be In A Different Directory"
			UnBlock
			return
		}
	}
	UnBlock
	set f .add_prop
	if [Dlg_Create $f "CHANGE OR ADD NEW PROPERTY TO USER SPECIFIED PROPERTIES" "set pr_addprops 0" -borderwidth $evv(BBDR)] {
		set f0 [frame $f.0 -borderwidth $evv(BBDR)]
		set f1 [frame $f.1 -borderwidth $evv(BBDR)]
		set f2 [frame $f.2 -borderwidth $evv(BBDR)]
		set f3 [frame $f.3 -borderwidth $evv(BBDR)]
		set f3a [frame $f.3a -borderwidth $evv(BBDR)]
		set f4 [frame $f.4 -borderwidth $evv(BBDR)]
		button $f0.quit -text "Close" -command {set pr_addprops 0} -highlightbackground [option get . background {}]
		button $f0.add  -text "Add:Change Prop" -command {set pr_addprops 4} -highlightbackground [option get . background {}]
		button $f0.rem  -text "Remove Prop" -command {set pr_addprops 2} -highlightbackground [option get . background {}]
		pack $f0.add -side left
		pack $f0.rem -side left
		pack $f0.quit -side right
		pack $f.0 -side top -fill x -expand true
		label $f1.ll -text "Property Name     "
		entry $f1.name  -textvariable new_propname -width 20
		label $f2.ll -text "Property Value   "
		entry $f2.val -textvariable new_propval -width 20 -disabledbackground [option get . background {}]
		pack $f1.ll $f1.name -side left
		pack $f2.ll $f2.val -side left
		label $f3.ll -text "Name of new property file"
		entry $f3.name -textvariable new_propvalfile -width 20
		pack $f3.ll $f3.name -side left
		label $f3a.ll -text "NAMES OF EXISTING PROPERTIES"
		pack $f3a.ll -side left
		pack $f1 $f2 $f3 $f3a -side top -pady 2
		set propnamelisting [Scrolled_Listbox $f4.ll -width 48 -height 24 -selectmode single]
		pack $f4.ll -side top -fill both -expand true
		pack $f4 -side top -fill both -expand true
		bind $propnamelisting <ButtonRelease-1> {SetPropname %y}
		bind $f1.name <Down> {focus .add_prop.2.val}
		bind $f2.val <Down> {focus .add_prop.3.name}
		bind $f3.name <Down> {focus .add_prop.1.name}
		bind $f1.name <Up> {focus .add_prop.3.name}
		bind $f2.val <Up> {focus .add_prop.1.name}
		bind $f3.name <Up> {focus .add_prop.2.val}
		bind $f <Escape> {set pr_addprops 0}
	}
	if {$delete_entire_prop} {
		.add_prop.0.add config -text "" -bd 0 -command {}
		.add_prop.2.ll config -text ""
		.add_prop.2.val config -bd 0 -state disabled
		.add_prop.0.rem config -text "Remove Prop" -command {set pr_addprops 2} -bd 2
		bind $propnamelisting <ButtonRelease-1> {SetPropname %y}
	} elseif {$add_void} {		;# ADD A VOID PROPERTY ONLY
		.add_prop.0.add config -text "Add Empty Prop" -command {set pr_addprops 3} -bd 2
		.add_prop.2.ll config -text ""
		.add_prop.2.val config -bd 0 -state disabled
		.add_prop.0.rem config -text "" -command {} -bd 0
		bind $propnamelisting <ButtonRelease-1> {SetPropname %y}
	} elseif {$add_vector} {		;# NO PROP DELETING ALLOWED, AND NO VALUES ENTERED!!!
		.add_prop.0.add config -text "Add:Change Prop" -command {set pr_addprops 4} -bd 2
		.add_prop.2.ll config -text ""
		.add_prop.2.val config -bd 0 -state disabled
		.add_prop.0.rem config -text "" -command {} -bd 0
		bind $propnamelisting <ButtonRelease-1> {}
	}
	set new_propvalfile ""
	set new_propname ""
	set new_propval ""
	$propnamelisting delete 0 end
	set n 1
	while {$n < $propcnt} {
		$propnamelisting insert end $propname($n)
		incr n
	}
	set old_propcnt $propcnt
	set propch 0
	set pr_addprops 0
	set finished 0
	set changed 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_addprops $propnamelisting
	while {!$finished} {
		tkwait variable pr_addprops
		switch -- $pr_addprops {
			2 -
			3 -
			4 {
				if {[string length $new_propname] <= 0} {
					Inf "No Property Name Entered"
					continue
				}
				if {$pr_addprops == 1} {
					if {[string length $new_propval] <= 0} {
						Inf "No Property Value Entered"
						continue
					}
				}
				if {[string length $new_propvalfile] <= 0} {
					Inf "No Name Entered For Output Property File"
					continue
				}
				set new_propvalfile [string tolower $new_propvalfile]
				set xxx [file rootname [file tail $new_propvalfile]]
				if {![string match $new_propvalfile $xxx]} {
					Inf "Extensions Or Pathnames Cannot Be Used Here"
					continue
				}
				set new_propvalfile $xxx
				set new_propvalfile [FixTxt $new_propvalfile "new filename"]
				if {[string length $new_propvalfile] <= 0} {
					continue
				}
		 		if {![ValidCdpFilename $new_propvalfile 1]} {
					continue
				}
				set this_ext [GetTextfileExtension props]
				set outfile $new_propvalfile$this_ext
				if [file exists $outfile] {
					set msg "File '$outfile' Already Exists.  Overwrite It??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
				}
				if [catch {open $outfile "w"} zit] {
					Inf "Cannot Open File '$outfile' To Write New Property List"
					continue
				}
				set cnt 1
				set foundit 0
				set changed 0
				while {$cnt < $propcnt} {
					if {[string match $propname($cnt) $new_propname]} {
						switch --  $pr_addprops {
							2 { ;# DELETE PROP
								if {$delete_entire_prop} {
									set nulines [DeleteProp $cnt]
									set changed 1
								} else {
									set nulines [DeletePropVals $cnt $in_sndfiles]
									if {[llength $nulines] > 0} {
										set changed 1
									}
								}
							}
							3 -
							4 { ;# ADD VOID PROP
								Inf "This Property Already Exists"
							} 
						}
						set foundit 1
						break
					}
					incr cnt
				}
				if {!$foundit} {
					switch --  $pr_addprops {
						3 { ;# ADD VOID PROP
							set in_sndfiles {}						
							set nulines [InsertValueInNewProp $new_propname "-" $in_sndfiles $from_marked $add_void] 
							set changed 1
						} 
						4 { ;# ADD VECTOR PROP
							set nulines [InsertVectorValueInNewProp $new_propname $vecfile] 
							set changed 1
						} 
						2 { ;# DELETE PROPERTY
							Inf "No Such Property Exists"
						} 
					}
				}
				if {$changed} {
					catch {unset startline}
					set cnt 1
					while {$cnt < $propcnt} {
						append startline $propname($cnt) " "
						incr cnt
					}
					puts $zit $startline
					foreach line $nulines {
						if {$old_props_protocol} {
							set sndf [lindex $line 0]
							set sndf [file tail $sndf]
							set line [lreplace $line 0 0 $sndf]
						}
						puts $zit $line
					}
					close $zit
					FileToWkspace $outfile 0 0 0 0 1
					Inf "Property File '$outfile' Has Been Placed On The Workspace"
					if {[info exists propfiles_list]} {
						if {[lsearch $propfiles_list $outfile] < 0} {
							lappend propfiles_list $outfile
						}
					} else {
						lappend propfiles_list $outfile
					}
					if {$from_marked && ($propcnt > $old_propcnt)} {
						incr propcnt -1		;# RESTORE PROPCNT USED FOR DISPLAY IN 'MARKED' CASE
					}
				} else {
					close $zit
					if [catch {file delete $outfile} zat] {
						Inf "Cannot Delete Proposed Outfile '$outfile'"
					}
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

#--- Choose property name from property names list

proc SetPropname {y} {
	global propnamelisting new_propname
	set i [$propnamelisting nearest $y]
	set new_propname [$propnamelisting get $i]
}

#--- Insert new value into existing property listing

proc InsertValueInExistingProp {colno val in_sndfiles from_marked} {
	global propfile propname proplisting wstk
	if {$from_marked} {
		set propthing [$proplisting get 0 end]
	} else {
		set propthing $propfile
	}
	foreach line $propthing {
		set snd [lindex $line 0]
		set k [lsearch $in_sndfiles $snd]
		if {$k >= 0} {
			set oldval [lindex $line $colno]
			if {![string match $oldval "-"]} {
				set msg "Soundfile '$snd' Already Has A Value '$oldval' For Property $propname($colno): "
				append msg "\nDo You Want To Replace Any Existing Values For This Property??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					return {}
				} else {
					break
				}
			}
		}
	}
	foreach line $propthing {
		set snd [lindex $line 0]
		set k [lsearch $in_sndfiles $snd]
		if {$k >= 0} {
			set line [lreplace $line $colno $colno $val]
		}
		lappend nulines $line
	}
	return $nulines
}

#--- Add entirely new property to the listing

proc InsertValueInNewProp {name val in_sndfiles from_marked add_void} {
	global propcnt propfile propname proplisting
	if {$from_marked} {
		set propthing [$proplisting get 0 end]
	} else {
		set propthing $propfile
	}
	if {$add_void} {
		foreach line $propthing {
			set line [linsert $line $propcnt $val]
			lappend nulines $line
		}
	} else {
		foreach line $propthing {
			set snd [lindex $line 0]
			set k [lsearch $in_sndfiles $snd]
			if {$k >= 0} {
				set line [linsert $line $propcnt $val]
			} else {
				set line [linsert $line $propcnt "-"]
			}
			lappend nulines $line
		}
	}
	set propname($propcnt) $name
	incr propcnt
	return $nulines
}

proc InsertVectorValueInNewProp {name vector} {
	global propcnt propfile propname proplisting

	foreach line $propfile val $vector {
		set line [linsert $line $propcnt $val]
		lappend nulines $line
	}
	set propname($propcnt) $name
	incr propcnt
	return $nulines
}

#--- Delete entire property from property list

proc DeleteProp {colno} {
	global propfile propcnt propname
	foreach line $propfile {
		lappend nulines [lreplace $line $colno $colno]
	}
	set propfile $nulines
	set n $colno
	set m $n
	incr m
	while {$m < $propcnt} {
		set propname($n) $propname($m)
		incr n
		incr m
	}
	incr m -1
	unset propname($m)
	incr propcnt -1
	return $nulines
}

#--- Delete values of specified property for specified soundfiles

proc DeletePropVals {colno in_sndfiles} {
	global propcnt propfile propname

	set nulines {}
	foreach line $propfile {
		set snd [lindex $line 0]
		set k [lsearch $in_sndfiles $snd]
		if {$k >= 0} {
			set oldval [lindex $line $colno]
			if {![string match $oldval "-"]} {
				set line [lreplace $line $colno $colno "-"]
			}
		}
		lappend nulines $line
	}
	return $nulines
}

#--- User info

proc UserPropsHelp {} {
	global old_props_protocol
	set msg "A PROPERTY: ANYTHING WHICH CAN DESCRIBE A SOUND AND HAVE A VALUE\n"
	append msg "PropertY names can be anything you like,\n"
	append msg "from common usage (pitch, vowel) or personal (fuzzy, orange).\n"
	append msg "Values can be numeric or any text you wish.\n"
	append msg "                               SOME RESERVED PROP NAMES\n"
	append msg "(e.g. \"HF\") allow graphical entry of data.\n"
	append msg "See the \"Help\" info on Table Display of Props.\n"
	append msg "\n"
	append msg "A PROPERTY FILE IS A LIST OF SOUNDS WITH THEIR PROPERTIES\n"
	if {$old_props_protocol} {
		append msg "All Sounds Listed Must Be In Same Directory.\n"
	}
	append msg "\n"
	append msg "CREATE NEW PROPERTY FILE WITH \"START A NEW PROPERTIES FILE\"\n"
	append msg "Every Sound In The Properties File Must Be Given A Value For That Property\n"
	append msg "but if no meaningful value possible, use \"-\" (a dash, or hyphen)\n"
	append msg "(Put uncertain values in ordinary brackets, or follow by question mark).\n"
	append msg "\n"
	append msg "WITH PROPERTY FILES YOU CAN ...........\n"
	append msg "1) Display Properties As TABLES (Double Click on properties file)\n"
	append msg "      where you can play sounds, and read/enter props and explanations.\n"
	append msg "2) Use Properties To Sort Or Select Related Sounds.\n"
	append msg "      Selected sounds transferred directly to Chosen Files list.\n"
	append msg "3) Modify Property Files - Remove Or Add New Sounds;\n"
	append msg "      Add,remove Or Rename Properties Or Their Values.\n"
	append msg "\n"
	append msg "TO WORK WITH PROPERTY FILES, SELECT WORKSPACE FILES AS FOLLOWS\n"
	append msg "Start New Properties File:         Sndfile\n"
	append msg "Add Sounds or Props, Modify Props: Propfile + Sndfile(s)\n"
	append msg "Modify Property Tables etc:        Propile\n"
	append msg "Merge 2 Prop Files:                2 Propfiles\n"
	append msg "Sort/select Snds By Properties:    Propfile (+- sndfile(s))\n"
	append msg "\n"
	Inf $msg
}

#--- Play specified files in properties list, mark played files, add properties to marked files

proc PlayPropFiles {which} {
	global proplisting propsnds_playlist next_sel_prop how_many_propplay proplisting
	global mark_list all_mark_list wstk

	set maxlen 0
	foreach item [$proplisting get 0 end] {
		incr maxlen
	}

	switch -- $which {
		0	{	;# SELECTED FILES
			set ilist [$proplisting curselection]
			set how_many_propplay [llength $ilist]
			if {$how_many_propplay <= 0} {
				Inf "No Files Selected"
				return
			}
			catch {unset propsnds_playlist}
			catch {unset mark_list}
			foreach i $ilist {
				lappend mark_list $i
				lappend propsnds_playlist [lindex [$proplisting get $i] 0]
			}
			set next_sel_prop [lindex $ilist end]
		}	
		1	{	;#	FIRST N
			if {![info exists how_many_propplay] || ($how_many_propplay < 1)} {
				set how_many_propplay [Get_how_many_propplay 0]
			} else {
				set msg "Change Number Of Files To Play From $how_many_propplay ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "yes"} {
					set how_many_propplay [Get_how_many_propplay 0]
				}
			}
			if {$how_many_propplay <= 0} {
				return
			}
			if {$how_many_propplay > $maxlen} {
				Inf "There Are Only $maxlen Files"
				set maxlen $how_many_propplay
			}
			catch {unset propsnds_playlist}
			catch {unset mark_list}
			set i 0
			while {$i < $how_many_propplay} {
				lappend mark_list $i
				lappend propsnds_playlist [lindex [$proplisting get $i] 0]
				incr i
			}
			set next_sel_prop $how_many_propplay
		}
		2	{	;#	NEXT N
			if {![info exists next_sel_prop]} {
				Inf "No Previous Play Or Skip"
				return
			}
			if {$next_sel_prop >= $maxlen} {
				Inf "Reached End Of Files"
				return
			}
			set thisend $next_sel_prop
			incr thisend $how_many_propplay
			if {$thisend >= $maxlen} {
				set thisend $maxlen
			}
			catch {unset propsnds_playlist}
			catch {unset mark_list}
			set i $next_sel_prop
			while {$i < $thisend} {
				lappend mark_list $i
				lappend propsnds_playlist [lindex [$proplisting get $i] 0]
				incr i
			}
			set next_sel_prop $thisend
		}
		3 {		;# SAME FILES AGAIN
			if {![info exists propsnds_playlist]} {
				Inf "No Previous Sounds Played"
				return
			}
		}
		4 {		;# SKIP N FILES
			if {![info exists next_sel_prop]} {
				set next_sel_prop 0
			}
			if {$next_sel_prop >= $maxlen} {
				Inf "Reached End Of Files"
				return
			}
			set how_many_skip [Get_how_many_propplay 1]
			if {$how_many_skip <= 0} {
				return
			}
			set thisend $next_sel_prop
			incr thisend $how_many_skip
			if {$thisend >= $maxlen} {
				Inf "Reached End Of Files"
			} else {
				set msg "Last Sound Skipped Is '[lindex [$proplisting get [expr $thisend - 1]] 0]': OK ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					return
				}
			}
			set next_sel_prop $thisend
			return
		}
		5 {		;#	MARK SELECTED FILES FROM LAST SET OF FILES PLAYED 
				;#	(ADDING TO ANY EXISTING LIST OF MARKED FILES)
			set all_mark_list [DoMarking]		
			return
		}	
		6	{	;# N FILES STARTING WITH SELECTED FILE
			set ilist [$proplisting curselection]
			if {[llength $ilist] <= 0} {
				Inf "No File Selected"
				return
			}
			if {[llength $ilist] > 1} {
				Inf "Select Just One File"
				return
			}
			set i [lindex $ilist 0]
			if {![info exists how_many_propplay] || ($how_many_propplay < 1)} {
				set how_many_propplay [Get_how_many_propplay 0]
			} else {
				set msg "Change Number Of Files To Play From $how_many_propplay ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "yes"} {
					set how_many_propplay [Get_how_many_propplay 0]
				}
			}
			if {$how_many_propplay <= 0} {
				return
			}
			set thisend [expr $i + $how_many_propplay]
			if {$thisend > $maxlen} {
				set thisend $maxlen
				Inf "Can Only Play [expr $thisend - $i] Files"
			}
			catch {unset propsnds_playlist}
			catch {unset mark_list}
			while {$i < $thisend} {
				lappend mark_list $i
				lappend propsnds_playlist [lindex [$proplisting get $i] 0]
				incr i
			}
			set next_sel_prop $thisend
		}
	}
	$proplisting selection clear 0 end
	foreach i $mark_list {
		$proplisting selection set $i $i
	}
	$proplisting yview moveto [expr double([lindex $mark_list 0])/double($maxlen)]
	if {[llength $propsnds_playlist] == 1} {
		PlaySndfile $propsnds_playlist 0
	} else {
		ScoreTrueTestOut propslist 0
	}
	return
}

#--- Set how many consecutive sounds to play (N) from list of sounds in propslist

proc Get_how_many_propplay {skip} {
	global pr_how_many_propplay many_propplay evv

	set f .how_many_propplay
	if [Dlg_Create $f "HOW MANY SOUNDS" "set pr_how_many_propplay 0" -borderwidth $evv(BBDR)] {
		set f0 [frame $f.0 -borderwidth $evv(BBDR)]
		set f1 [frame $f.1 -borderwidth $evv(BBDR)]
		button $f0.ok -text "OK" -command {set pr_how_many_propplay 1} -highlightbackground [option get . background {}]
		button $f0.qu -text "Abandon" -command {set pr_how_many_propplay 0} -highlightbackground [option get . background {}]
		pack $f0.ok -side left
		pack $f0.qu -side right
		label $f1.ll -text "How many sounds to play (max 20)"
		entry $f1.e -textvariable many_propplay -width 4
		pack $f1.ll $f1.e -side left -padx 4
		pack $f0 $f1 -side top -pady 4 -fill x -expand true
		bind $f <Escape> {set pr_how_many_propplay 0}
		bind $f <Return> {set pr_how_many_propplay 1}
	}
	if {$skip} {
		$f.1.ll config -text "How many sounds to skip                   "
	} else {
		$f.1.ll config -text "How many sounds to play (max 20)"
	}
	set pr_how_many_propplay 0
	set finished 0
	raise $f
	My_Grab 0 $f pr_how_many_propplay .how_many_propplay.1.e
	while {!$finished} {
		tkwait variable pr_how_many_propplay
		if {$pr_how_many_propplay} {
			if {![info exists many_propplay] || ![IsNumeric $many_propplay] || ($many_propplay < 1)} {
				Inf "Invalid Value"
				continue
			}
			if {!$skip && ($many_propplay > 20)} {
				Inf "Too Many Files Chosen"
				continue
			}
			set pr_how_many_propplay [expr round($many_propplay)]
			break
		} else {
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $pr_how_many_propplay
}

#--- From the last sounds heard, mark those of interest (adding to any existing list of marked files)

proc DoMarking {} {
	global all_mark_list orig_all_mark_list mark_list pr_mark ch_b how_many_propplay mark evv 

	if {![info exists mark_list]} {
		Inf "No Files Played Recently"
		return
	}
	if {![info exists all_mark_list]} {
		set all_mark_list {}
	}
	set orig_all_mark_list $all_mark_list 
	set f .marklist
	if [Dlg_Create  $f "MARK FILES YOU HAVE JUST PLAYED" "set all_mark_list $orig_all_mark_list; set pr_mark 0" -borderwidth $evv(BBDR)] {
		set f0 [frame $f.0 -borderwidth $evv(BBDR)]
		set f1 [frame $f.1 -borderwidth $evv(BBDR)]
		set f2a [frame $f.2a -borderwidth $evv(BBDR)]
		set f2 [frame $f.2 -borderwidth $evv(BBDR)]
		set f3 [frame $f.3 -borderwidth $evv(BBDR)]
		button $f.0.qu -text "Exit:Keep New Marks" -command {set pr_mark 2} -width 19 -highlightbackground [option get . background {}]
		button $f.0.qu2 -text "Close:New Marks Not Kept" -command {set all_mark_list $orig_all_mark_list; set pr_mark 0}  -width 23 -highlightbackground [option get . background {}]
		button $f.0.do -text "Mark More Files" -command {set pr_mark 1} -width 15 -highlightbackground [option get . background {}]
		pack $f.0.qu $f0.do -side left
		pack $f0.qu2 -side right -padx 8
		pack $f0 $f1 -side top -pady 4 -fill x -expand true
		button $f3.clear -text "CLEAR ALL EXISTING MARKS (!!)" -command ClearMarkList -width 32 -highlightbackground [option get . background {}]
		pack $f3.clear -side top -pady 2
		label $f2a.ll -text "MARK FILES FROM THOSE YOU HAVE JUST PLAYED\n"
		checkbutton $f2.b0  -variable mark(0)  -text "1"
		checkbutton $f2.b1  -variable mark(1)  -text "2"
		checkbutton $f2.b2  -variable mark(2)  -text "3"
		checkbutton $f2.b3  -variable mark(3)  -text "4"
		checkbutton $f2.b4  -variable mark(4)  -text "5"
		checkbutton $f2.b5  -variable mark(5)  -text "6"
		checkbutton $f2.b6  -variable mark(6)  -text "7"
		checkbutton $f2.b7  -variable mark(7)  -text "8"
		checkbutton $f2.b8  -variable mark(8)  -text "9"
		checkbutton $f2.b9  -variable mark(9)  -text "10"
		checkbutton $f2.b10 -variable mark(10) -text "11"
		checkbutton $f2.b11 -variable mark(11) -text "12"
		checkbutton $f2.b12 -variable mark(12) -text "13"
		checkbutton $f2.b13 -variable mark(13) -text "14"
		checkbutton $f2.b14 -variable mark(14) -text "15"
		checkbutton $f2.b15 -variable mark(15) -text "16"
		checkbutton $f2.b16 -variable mark(16) -text "17"
		checkbutton $f2.b17 -variable mark(17) -text "18"
		checkbutton $f2.b18 -variable mark(18) -text "19"
		checkbutton $f2.b19 -variable mark(19) -text "20"
		pack $f2a.ll -side top
		pack $f2.b0 $f2.b1 $f2.b2 $f2.b3 $f2.b4 $f2.b5 $f2.b6 $f2.b7 $f2.b8 $f2.b9 $f2.b10 $f2.b11 \
			$f2.b12 $f2.b13 $f2.b14 $f2.b15 $f2.b16 $f2.b17 $f2.b18 $f2.b19 -side left
		pack $f2a $f2 $f3 -side top -pady 4 -fill x -expand true
		bind $f <Escape>"set all_mark_list $orig_all_mark_list; set pr_mark 0"
	}
	set n 0
	while {$n < 20} {
		set mark($n) 0
		if {$n < $how_many_propplay} {
			$f.2.b$n config -state normal
		} else {
			$f.2.b$n config -state disabled
		}
		incr n
	}
	if {[info exists all_mark_list] && ([llength $all_mark_list] > 0)} {
		$f.2a.ll config -text "MARK FURTHER FILES,\nFROM AMONGST THOSE YOU HAVE JUST PLAYED"
	} else {
		$f.2a.ll config -text "MARK FILES FROM AMONGST THOSE YOU HAVE JUST PLAYED\n"
	}
	set pr_mark 0
	raise $f
	update idletasks
	StandardPosition $f
	set finished 0
	My_Grab 0 $f pr_mark
	while {!$finished} {
		tkwait variable pr_mark
		if {$pr_mark > 0} {
			set n 0
			while {$n < 20} {
				if {$mark($n)} {
					set val [lindex $mark_list $n]
					if {[lsearch $all_mark_list $val] < 0} {
						lappend all_mark_list $val
					}
				}
				incr n
			}
			if {$pr_mark == 2} {
				break
			}
		} else {
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $all_mark_list
}

#--- Clear list of marks on files

proc ClearMarkList {} {
	global all_mark_list orig_all_mark_list mark_list mark
	if [AreYouSure] {
		set n 0 
		while {$n < 20} {
			set mark($n) 0
			incr n
		}
		set all_mark_list {}
		set orig_all_mark_list {}
	}
}

#--- Hilite files marked

proc HiliteMarkList {} {
	global proplisting all_mark_list
	if {![info exists all_mark_list] || ([llength $all_mark_list] <= 0)} {
		Inf "No Files Are Marked"
		return
	}
	$proplisting selection clear 0 end
	set maxlen 0
	foreach i [$proplisting get  0 end] {
		incr maxlen
	}
	foreach i $all_mark_list {
		$proplisting selection set $i
	}
	$proplisting yview moveto [expr double([lindex $all_mark_list 0])/double($maxlen)]
}

#----------

proc SelectOnChosen {} {
	global proplisting old_proplist propfcnt chlist

	if {![info exists chlist] || ([string length $chlist] <= 0)} {
		Inf "No Files On Chosen Files List"
		return
	}
	foreach line [$proplisting get 0 end] {
		if {[lsearch $chlist [lindex $line 0]] >= 0}  {
			lappend nulines $line
		}
	}
	if {![info exists nulines]} {
		Inf "No Chosen Files Are In The Properties List"
		return
	}
	set old_proplist [$proplisting get 0 end]
	$proplisting delete 0 end
	set cnt 0
	foreach line $nulines {
		$proplisting insert end $line
		incr cnt
	}
	set propfcnt $cnt
}

#--- Merge two profiles

proc Merge_Props {difprops} {
	global pr_mergeprops wstk pa evv old_props_protocol
	global propch wl orig_propfile propname proplisting propmergecol propfiles_list
	global new_propname new_propval propnamelisting new_propmergefile  all_mark_list chlist 

	set ilist [$wl curselection]
	if {[llength $ilist] <= 0} {
		if {[info exists chlist]} {
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
	if {[llength $ilist] != 2} {
		Inf "Choose Two Property Files"
		return
	}
	foreach i $ilist {
		set fnam [$wl get $i]
		if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
			Inf "Choose Two Property Files"
			return
		}
	}
	if {$difprops} {
		set msg "Insert File ('[$wl get [lindex $ilist 1]]' Into '[$wl get [lindex $ilist 0]]') ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			set ilist [ReverseList $ilist]
			Inf "Inserting File ('[$wl get [lindex $ilist 1]]' Into '[$wl get [lindex $ilist 0]]')"
		}
	} else {
		set msg "Merge Files In Given Order ('[$wl get [lindex $ilist 0]]' Followed By '[$wl get [lindex $ilist 1]]') ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			set ilist [ReverseList $ilist]
			Inf "Merging Files In Reverse Order ('[$wl get [lindex $ilist 0]]' Followed By '[$wl get [lindex $ilist 1]]')"
		}
	}
	set cnt 0
	set props_checked 0
	set done_props_check 0

	if {$difprops} {
		set cnt 0
		foreach i $ilist {
			set fnam [$wl get $i]
			if {[info exists propfiles_list]} {
				set is_a_known_propfile [lsearch $propfiles_list $fnam]
			} else {
				set is_a_known_propfile -1
			}
			if [catch {open $fnam "r"} zit] {
				Inf "Cannot Open Text File '$fnam'"
				return
			}
			while {[gets $zit line] >= 0} {
				lappend propfil($cnt) $line
			}
			close $zit
			if {![info exists propfil($cnt)]} {
				Inf "File '$fnam' Is Empty"
				if {$is_a_known_propfile >= 0} {
					set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
				}
				return
			}
			if {[llength $propfil($cnt)] < 2} {		;#	CANNOT BE A VALID PROPFILE
				Inf "'$fnam' Is Not A Valid Properties File"
				if {$is_a_known_propfile >= 0} {
					set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
				}
				return
			}
			set linecnt 0
			foreach line $propfil($cnt) {
				set this_propcnt 0
				catch {unset nuline}
				set line [string trim $line]
				set line [split $line]
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] > 0} {
						lappend nuline $item
						incr this_propcnt
					}
				}
				if {$this_propcnt > 0} {
					if {$linecnt == 0} {	;# FIRST LINE, SPECIAL CASE FOR PROPS FILES
						set propcn($cnt) $this_propcnt
						incr propcn($cnt)	;# lines to follow have filename, as well as props
						set n 0
						foreach item $nuline {
							set propnam($cnt,$n) $item
							incr n
						}
					} elseif {$propcn($cnt) != $this_propcnt} {
						Inf "Number Of Properties Incorrect On Line [expr $linecnt + 1] Of File '$fnam'"
						if {$is_a_known_propfile >= 0} {
							set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
						}
						return
					} else {
						set z_fnam [lindex $nuline 0]
						if {$old_props_protocol} {
							if {![string match $z_fnam [file tail $z_fnam]]} {
								Inf "Sound File Directories Found In File: Will Not Work With Old Protocol"
								if {$is_a_known_propfile >= 0} {
									set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
								}
								return
							}
						} else { 
							if {[string match $z_fnam [file tail $z_fnam]]} {
								Inf "Sounds Without Directory Paths Found In File: Will Not Work With New Protocol"
								if {$is_a_known_propfile >= 0} {
									set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
								}
								return
							}
						}
					}
					incr linecnt 
				}
			}
			if {$linecnt <= 0} {
				Inf "No Values Found In File '$fnam'"
				if {$is_a_known_propfile >= 0} {
					set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
				}
				return
			}
			set linecn($cnt) $linecnt
			if {$is_a_known_propfile < 0} {
				AddToPropfilesList $fnam
			}
			incr cnt
		}
		if {$linecn(0) != $linecn(1)} {
			Inf "These Files Contain Different Number Of Lines, Hence Cannot Refer To Same List Of Sounds"
			return
		}
		set n 0
		set lim0 [expr $propcn(0) - 1]
		set lim1 [expr $propcn(1) - 1]
		while {$n < $lim0} {
			set m 0
			while {$m < $lim1} {
				if {[string match $propnam(0,$n) $propnam(1,$m)]} {
					Inf "These Files Contain Values For The Same Prop '$propnam(0,$n)': Cannot Proceed"
					return
				}
				incr m
			}
			incr n
		}
		set propfil(0) [lrange $propfil(0) 1 end]
		set propfil(1) [lrange $propfil(1) 1 end]
		incr linecnt -1
		set n 0
		while {$n < $linecnt} {
			if {![string match [lindex [lindex $propfil(0) $n] 0] [lindex [lindex $propfil(1) $n] 0]]} {
				Inf "Sounds Referred To At Line [expr $n + 1] Are Not The Same: Cannot Proceed"
				return
			}				
			incr n
		}
	} else {
		foreach i $ilist {
			catch {unset propfile}
			set fnam [$wl get $i]
			if {[info exists propfiles_list]} {
				set is_a_known_propfile [lsearch $propfiles_list $fnam]
			} else {
				set is_a_known_propfile -1
			}
			if [catch {open $fnam "r"} zit] {
				Inf "Cannot Open Text File '$fnam'"
				return
			}
			while {[gets $zit line] >= 0} {
				lappend propfile $line
			}
			close $zit
			if {![info exists propfile]} {
				Inf "File '$fnam' Is Empty"
				if {$is_a_known_propfile >= 0} {
					set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
				}
				return
			}
			if {[llength $propfile] < 2} {		;#	CANNOT BE A VALID PROPFILE
				Inf "'$fnam' Is Not A Valid Properties File"
				if {$is_a_known_propfile >= 0} {
					set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
				}
				return
			}
			set linecnt 0
			foreach line $propfile {
				set this_propcnt 0
				catch {unset nuline}
				set line [string trim $line]
				set line [split $line]
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] > 0} {
						lappend nuline $item
						incr this_propcnt
					}
				}
				if {$this_propcnt > 0} {
					if {($linecnt == 0) && !($props_checked)} {	;# FIRST LINE, SPECIAL CASE FOR PROPS FILES
						if {$cnt == 0} {
							set propcnt $this_propcnt
							incr propcnt	;# lines to follow have filename, as well as props (if they're property files)
							set n 0
							foreach item $nuline {
								set propname($n) $item
								incr n
							}
						} else {
							incr this_propcnt
							if {$propcnt != $this_propcnt} {
								Inf "Number Of Properties Does Not Tally In The Two Files"
								return
							}
							set n 0
							foreach item $nuline {
								if {![string match $item $propname($n)]} {
									Inf "Different Properties In The Two Files"
									return
								}
								incr n
							}
							set props_checked 1
							set done_props_check 1
						}
					} elseif {$propcnt != $this_propcnt} {
						Inf "Number Of Properties Incorrect On Line [expr $linecnt + 1] Of File '$fnam'"
						if {$is_a_known_propfile >= 0} {
							set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
						}
						return
					}
					if {$done_props_check} {
						set done_props_check 0	;#	DON'T LIST PROPERTY NAMES LINE AGAIN!!
					} else {
						lappend nupropfile $nuline
						incr linecnt 
					}
				}
			}
			if {$linecnt <= 0} {
				Inf "No Values Found In File '$fnam'"
				if {$is_a_known_propfile >= 0} {
					set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
				}
				return
			}
			if {$is_a_known_propfile < 0} {
				AddToPropfilesList $fnam
			}
			set lines($cnt) $linecnt
			incr cnt
		}
		set n 1
		set m $lines(0)
		set lend [expr $lines(0) + $lines(1)]
		while {$n < $lines(0)} {
			set snd0 [lindex [lindex $nupropfile $n] 0]
			while {$m < $lend} {
				set snd1 [lindex [lindex $nupropfile $m] 0]
				if {[string match $snd0 $snd1]} {
					Inf "The Property Files Both Refer To The Same Sound '$snd0'"
					return
				}
				incr m
			}
			incr n
		}
	}
	set f .merge_props
	if [Dlg_Create $f "MERGE PROPERTIES" "set pr_mergeprops 0" -borderwidth $evv(BBDR)] {
		set f0 [frame $f.0 -borderwidth $evv(BBDR)]
		set f1 [frame $f.1 -borderwidth $evv(BBDR)]
		set f2 [frame $f.2 -borderwidth $evv(BBDR)]
		button $f0.quit -text "Close" -command {set pr_mergeprops 0} -highlightbackground [option get . background {}]
		button $f0.add  -text "Merge Prop Files" -command {set pr_mergeprops 1} -highlightbackground [option get . background {}]
		pack $f0.add -side left
		pack $f0.quit -side right
		pack $f.0 -side top -fill x -expand true

		label $f2.ll -text "at which property column to insert new props"
		entry $f2.no -textvariable propmergecol -width 20 -disabledbackground [option get . background {}]
		pack $f2.ll $f2.no -side left

		label $f1.ll -text "Name of new property file"
		entry $f1.name -textvariable new_propmergefile -width 20
		pack $f1.ll $f1.name -side left
		pack $f2 $f1 -side top -pady 2
		bind $f <Escape> {set pr_mergeprops 0}
		bind $f <Return> {set pr_mergeprops 1}
	}
	if {$difprops} {
		$f.2.ll config -text "at which property column to insert new props"
		$f.2.no config -state normal -bd 2
	} else {
		$f.2.ll config -text ""
		$f.2.no config -state disabled -bd 0
	}
	set new_propmergefile ""
	set propmergecol ""
	set pr_mergeprops 0
	set finished 0
	raise $f
	if {$difprops} {
		My_Grab 0 $f pr_mergeprops $f.2.no
	} else {
		My_Grab 0 $f pr_mergeprops $f.1.name
	}
	while {!$finished} {
		tkwait variable pr_mergeprops
		switch -- $pr_mergeprops {
			1 {

				if {$difprops} {
					if {![regexp {^[0-9]+$} $propmergecol] || ($propmergecol < 1)} {
						Inf "Invalid Property Number Used"
						continue
					}
				}					
				if {[string length $new_propmergefile] <= 0} {
					Inf "No Name Entered For Output Property File"
					continue
				}
				set new_propmergefile [string tolower $new_propmergefile]
				set xxx [file rootname [file tail $new_propmergefile]]
				if {![string match $new_propmergefile $xxx]} {
					Inf "Extensions Or Pathnames Cannot Be Used Here"
					continue
				}
				set new_propmergefile $xxx
				set new_propmergefile [FixTxt $new_propmergefile "new filename"]
				if {[string length $new_propmergefile] <= 0} {
					continue
				}
		 		if {![ValidCdpFilename $new_propmergefile 1]} {
					continue
				}
				set this_ext [GetTextfileExtension props]
				set outfile $new_propmergefile$this_ext
				if {$difprops} {
					if {$propmergecol == 1} {
						set n 0
						while {$n < $lim1} {
							lappend zab $propnam(1,$n)
							incr n
						}
						set n 0
						while {$n < $lim0} {
							lappend zab $propnam(0,$n)
							incr n
						}
						lappend nupropfile $zab
						foreach line0 $propfil(0) line1 $propfil(1) {
							set line [concat $line1 [lrange $line0 1 end]]
							lappend nupropfile $line
						}
					} elseif {$propmergecol > $propcn(0)} {
						set n 0
						while {$n < $lim0} {
							lappend zab $propnam(0,$n)
							incr n
						}
						set n 0
						while {$n < $lim1} {
							lappend zab $propnam(1,$n)
							incr n
						}
						lappend nupropfile $zab
						foreach line0 $propfil(0) line1 $propfil(1) {
							set line [concat $line0 [lrange $line1 1 end]]
							lappend nupropfile $line
						}
					} else {
						set lolim [expr $propmergecol -1]
						set n 0
						while {$n < $lolim} {
							lappend zab $propnam(0,$n)
							incr n
						}
						set n 0
						while {$n < $lim1} {
							lappend zab $propnam(1,$n)
							incr n
						}
						set n $lolim
						while {$n < $lim0} {
							lappend zab $propnam(0,$n)
							incr n
						}
						lappend nupropfile $zab
						foreach line0 $propfil(0) line1 $propfil(1) {
							set line [lrange $line0 0 $lolim]
							set line [concat $line [lrange $line1 1 end] [lrange $line0 $propmergecol end]]
							lappend nupropfile $line
						}
					}
				}
				if [file exists $outfile] {
					set msg "File '$outfile' Already Exists.  Overwrite It??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
				}
				if [catch {open $outfile "w"} zit] {
					Inf "Cannot Open File '$outfile' To Write New Property List"
					continue
				}
				foreach line $nupropfile {
					puts $zit $line
				}
				close $zit
				FileToWkspace $outfile 0 0 0 0 1
				if {[info exists propfiles_list]} {
					set k [lsearch $propfiles_list $outfile]
					if {$k < 0} {
						lappend propfiles_list $outfile
					}
				} else {
					lappend propfiles_list $outfile
				}
				Inf "Property File '$outfile' Has Been Placed On The Workspace"
				break
			}
			0 {
				break
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc GetPropVal {where} {
	global propall_list prop_sellist pr_propall props_ranked
	global propsets_list pr_propsets propsets_ranked 

	if {$where == "propall"} {
		set ilist [$propall_list curselection]
		if {![info exists ilist] || ([llength $ilist] <= 0)} {
			Inf "No Property Values Selected"
			return 
		}
		set cnt 0
		if {[info exists props_ranked]} {
			foreach i $ilist {
				set thisval [lindex [split [$propall_list get $i]] 0]
				if {$cnt == 0} {
					set prop_values $thisval
				} else {
					append prop_values "," $thisval
				}
				incr cnt
			}
		} else {
			foreach i $ilist {
				set thisval [$propall_list get $i]
				if {$cnt == 0} {
					set prop_values $thisval
				} else {
					append prop_values "," $thisval
				}
				incr cnt
			}
		}
		set prop_sellist $prop_values
		set pr_propall 0
	} else {	;# where = propsets
		set ilist [$propsets_list curselection]
		if {![info exists ilist] || ([llength $ilist] <= 0)} {
			Inf "No Property Values Selected"
			return 
		}
		if {[llength $ilist] > 1} {
			Inf "Select A Single Set Of Properties"
			return 
		}
		set i [lindex $ilist 0]
		if {[info exists propsets_ranked]} {
			set thisval [lindex [split [$propsets_list get $i]] 0]
		} else {
			set thisval [$propsets_list get $i]
		}
		set prop_sellist $thisval
		set pr_propsets 0
	}
}

proc PropRearrange {movenames} {
	global pr_rearrage rearr_fr rearr_no rearr_by propcnt proplisting prop_name_swap propname evv

	set f .rearr_props
	if [Dlg_Create $f "" "set pr_rearrage 0" -borderwidth $evv(BBDR)] {
		set f0 [frame $f.0 -borderwidth $evv(BBDR)]
		set f1 [frame $f.1 -borderwidth $evv(BBDR)]
		set f2 [frame $f.2 -borderwidth $evv(BBDR)]
		set f3 [frame $f.3 -borderwidth $evv(BBDR)]
		button $f0.quit -text "Close" -command {set pr_rearrage 0} -highlightbackground [option get . background {}]
		button $f0.rear -text "Rearrange" -command {set pr_rearrage 1} -highlightbackground [option get . background {}]
		pack $f0.rear -side left
		pack $f0.quit -side right
		pack $f.0 -side top -fill x -expand true

		label $f1.ll -text "Number of (1st) property to be moved"
		entry $f1.from -textvariable rearr_fr -width 20
		pack $f1.ll $f1.from -side left
		
		label $f2.ll -text "How many (adjacent) properties to move"
		entry $f2.cnt -textvariable rearr_no -width 20
		pack $f2.ll $f2.cnt -side left
		
		label $f3.ll -text "By how many columns to move"
		entry $f3.by -textvariable rearr_by -width 20
		pack $f3.ll $f3.by -side left
		
		pack $f1 $f2 $f3 -side top -pady 2

		bind $f.1.from <Down> {focus .rearr_props.2.cnt}
		bind $f.2.cnt  <Down> {focus .rearr_props.3.by}
		bind $f.3.by   <Down> {focus .rearr_props.1.from}
		bind $f.1.from <Up> {focus .rearr_props.3.by}
		bind $f.2.cnt  <Up> {focus .rearr_props.1.from}
		bind $f.3.by   <Up> {focus .rearr_props.2.cnt}
		bind $f <Return> {set pr_rearrage 1}
		bind $f <Escape> {set pr_rearrage 0}
	}
	if {$movenames} {
		wm title $f "REARRANGE COLUMNS (& DATA NAMES)"
		$f.1.ll config -text "Number of (1st) property to be moved"
		$f.2.ll config -text "How many (adjacent) properties to move"
		$f.3.ll config -text "By how many columns to move"
	} else {
		wm title $f "MOVE DATA INTO DIFFERENT COLUMN"
		$f.1.ll config -text "Number of (1st) property whose data is to be moved"
		$f.2.ll config -text "How many (adjacent) data columns to move"
		$f.3.ll config -text "By how many columns to move"
	}
	set pr_rearrage 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_rearrage $f.1.from

	while {!$finished} {
		tkwait variable pr_rearrage
		if {$pr_rearrage} {
			if {![regexp {^[0-9]+$} $rearr_fr] || ($rearr_fr < 1 || $rearr_fr >= $propcnt)} {
				Inf "Invalid Property Number For (1st) Column To Move"
				continue
			}
			set this_rearr_fr $rearr_fr
			set cols_remaining [expr $propcnt - $this_rearr_fr]
			set max_cols_back [expr 1 - $this_rearr_fr]
			set max_cols_fwd  [expr ($propcnt - 1) - $this_rearr_fr]
			if {![regexp {^[0-9]+$} $rearr_no] || ($rearr_no < 1)} {
				Inf "Invalid Count Of (adjacent) Columns To Move"
				continue
			}
			if {$rearr_no > $cols_remaining} {
				Inf "There Are Only $cols_remaining Columns From Column $rearr_fr Onwards: Invalid Value Of (Adjacent) Columns To Move"
				continue
			}
			if {![regexp {^[0-9\-]+$} $rearr_by] || ![IsNumeric $rearr_by] || ($rearr_by == 0)} {
				Inf "Invalid Value Of How Many Columns To Move By"
				continue
			}
			if {($rearr_by < $max_cols_back) || ($rearr_by > $max_cols_fwd)} {
				Inf "Impossible Value Of How Many Columns To Move By:\n\nMax Forward = $max_cols_fwd\n\nMax Backwards = [expr -($max_cols_back)]"
				continue
			}
			set rearr_end [expr $this_rearr_fr + $rearr_no - 1]
			set rearr_to [expr $this_rearr_fr + $rearr_by]
			set rearr_before [expr $rearr_to - 1]
			catch {unset $nulines}
			foreach line [$proplisting get 0 end] {
				set line [split $line]
				set moved_cols [lrange $line $this_rearr_fr $rearr_end]
				set line [lreplace $line $this_rearr_fr $rearr_end]
				set len [llength $line]
				if {$rearr_to >= $len} {
					set line [concat $line $moved_cols]
				} else {
					set line  [concat [lrange $line 0 $rearr_before] $moved_cols [lrange $line $rearr_to end]]
				}
				set line [join $line " "]
				lappend nulines $line
			}
			$proplisting delete 0 end
			foreach line $nulines {
				$proplisting insert end $line
			}
			if {$movenames} {
				set prop_names 0
				set n 1
				while {$n < $propcnt} {
					lappend prop_names $propname($n)
					incr n
				}
				set moved_names [lrange $prop_names $this_rearr_fr $rearr_end]
				set prop_names [lreplace $prop_names $this_rearr_fr $rearr_end]
				set len [llength $prop_names]
				if {$rearr_to >= $len} {
					set prop_names [concat $prop_names $moved_names]
				} else {
					set prop_names  [concat [lrange $prop_names 0 $rearr_before] $moved_names [lrange $prop_names $rearr_to end]]
				}
				set n 1
				while {$n < $propcnt} {
					set propname($n) [lindex $prop_names $n]
					if {$n > 15} {
						.prop_file.f.0.3c.b$n config -text $propname($n) -state normal
					} elseif {$n > 10} {
						.prop_file.f.0.3b.b$n config -text $propname($n) -state normal
					} elseif {$n > 5} {
						.prop_file.f.0.3a.b$n config -text $propname($n) -state normal
					} else {
						.prop_file.f.0.3.b$n config -text $propname($n) -state normal
					}
					incr n
				}
				set prop_name_swap 1
			}
			Inf "Remember To Save The New Version Of The Properties File, If You Want To Keep These Changes"
			break
		} else {
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc PropDel {isdelete} {
	global prop_name_swap prop_sellist proplisting propname propcnt

	if {![info exists prop_sellist] || ([llength $prop_sellist] <= 0)} {
		Inf "No Column Numbers Specified In 'Search-String' Box"
		return
	}
	if {![regexp {^[0-9\,]+$} $prop_sellist]} {
		Inf "Invalid Column Number Specification In 'Search-String' Box\n\n(Don't use spaces)"
		return
	}
	set lines [split $prop_sellist ","]
	if {![info exists lines] || ([llength $lines] <= 0)} {
		Inf "Invalid Column Number Specification In 'Search-String' Box"
		return
	}
	if {$isdelete} {
		set k 1
		while {$k < $propcnt} {
			lappend propnos $k
			incr k
		}
	}
	foreach item $lines {
		if {[string length $item] <= 0} {
			Inf "Blank Item In Column Number Specification (Two Adjacent Commas??)"
			return
		}
		if {![regexp {^[0-9]+$} $item]} {
			Inf "Item '$item' In Column Number Specification Is Invalid"
			return
		}
		if {($item < 1) || ($item > $propcnt)} {
			Inf "Item '$item' In Column Number Specification Is Out Of Range"
			return
		}
		if {$isdelete} {
			set k [lsearch $propnos $item]
			if {$k >= 0} {
				set propnos [lreplace $propnos $k $k]
			}
		} else {
			lappend propnos $item
		}
	}
	set len [llength $propnos]
	set i 0
	set j 1
	while {$i < $len} {
		set nupropname($j) $propname([lindex $propnos $i])
		incr i
		incr j
	}
	set j 1
	while {$j <= $len} {
		set propname($j) $nupropname($j)
		incr j
	}
	set propcnt $len
	incr propcnt

	foreach line [$proplisting get 0 end] {
		set line [split $line]
		set nuline [lindex $line 0]
		foreach k $propnos {
			lappend nuline [lindex $line $k]
		}
		lappend nulines $nuline
	}
	$proplisting delete 0 end
	foreach line $nulines {
		$proplisting insert end $line
	}
	set k 1
	while {$k < $propcnt} {
		if {$k > 15} {
			.prop_file.f.0.3c.b$k  config -text $propname($k) -state normal
		} elseif {$k > 10} {
			.prop_file.f.0.3b.b$k  config -text $propname($k) -state normal
		} elseif {$k > 5} {
			.prop_file.f.0.3a.b$k  config -text $propname($k) -state normal
		} else {
			.prop_file.f.0.3.b$k  config -text $propname($k) -state normal
		}
		incr k
	}	
	while {$k <= 20} {
		if {$k > 15} {
			.prop_file.f.0.3c.b$k  config -text "" -state disabled
		} elseif {$k > 10} {
			.prop_file.f.0.3b.b$k  config -text "" -state disabled
		} elseif {$k > 5} {
			.prop_file.f.0.3a.b$k  config -text "" -state disabled
		} else {
			.prop_file.f.0.3.b$k  config -text "" -state disabled
		}
		incr k
	}	
	set prop_name_swap 1
}

proc Reset_Do_Props {} {
	global propcnt propname propchv last_propchv evv
	set f .prop_file

	$f.a.b config -text "Select On Several Props" -command Reconfigure_Do_Props
	$f.01.l config -text "SELECTED VALUES OF PROPERTY (separate by commas) ..... or ..... SEARCH-STRING"

	$f.a.l config -text "CHOOSE WHICH SINGLE PROPERTY TO WORK ON"
	$f.2.rea config -text "Rearrange Snds" -state normal
	$f.2.red config -text "Rearrange Data" -state normal
	$f.2.rst config -text "Restore Snds" -state normal

	$f.2.tes.menu entryconfig 0 -label "GET DATA ON VALUES OF SPECIFIED PROPERTY"  -command {PropAll}
	$f.2.tes.menu entryconfig 2 -label "LIST IN GROUPS, FILES WITH ALL PROPS IDENTICAL" -command {FindIdenticals 0}
	$f.2.tes.menu entryconfig 4 -label "" -command {}

	$f.5.fil config -text "Save New Data" -state normal
	$f.5.play config -text "Play or Mark" -state normal
	$f.5.asse config -text "Collect Files" -state normal
	$f.5.cho config -text "as Chosen Files" -state normal
	$f.5.l config -text "Filename"
	$f.5.e config -bd 2 -state normal


	$f.2.kee.menu entryconfig 2 -label "Snds With Specified Vals Of Specified Property" -command {SelectOnField 1}
	$f.2.kee.menu entryconfig 4 -label "Snds Where Vals Of Specified Prop Are >= Specified Val" -command {SelectOnField 4}
	$f.2.kee.menu entryconfig 6 -label "Snds Where Vals Of Specified Prop Are <= Specified Val" -command {SelectOnField 5}
	$f.2.kee.menu entryconfig 8 -label "Snds Where Val Of Specified Prop Contains Specified String" -command {SelectOnField 2}
	$f.2.kee.menu entryconfig 10 -label "Snds Where Val Of Specified Prop Starts With Specified String" -command {SelectOnField 6}
	$f.2.kee.menu entryconfig 12 -label "Snds Where Val Of Prop Contains All Values In Specified String" -command {SelectOnField 8}
	$f.2.kee.menu entryconfig 14 -label "Snds Where Val Of Prop Contains All Vals In String,in Same Order" -command {SelectOnField 9}
	$f.2.kee.menu entryconfig 16 -label "CHOSEN FILES LIST" -background $evv(HELP)
	$f.2.kee.menu entryconfig 18 -label "Snds Which Are Currently On Chosen Files List" -command {SelectOnChosen}

	$f.2.rmv.menu entryconfig 0 -label "With Specified Vals Of Specified Property" -command {SelectOnField 0}
	$f.2.rmv.menu entryconfig 2 -label "Where Val Of Specified Prop Contains Specified String" -command {SelectOnField 3}
	$f.2.rmv.menu entryconfig 4 -label "Where Val Of Specified Prop Starts With Specified String" -command {SelectOnField 7}
	$f.2.rmv.menu entryconfig 6 -label "Highlighted Sounds" -command RemovePropItems
	$f.2.rmv.menu entryconfig 8 -label "Sounds At & Beyond Highlight" -command {RemovePropItemsBeyond 1}
	$f.2.rmv.menu entryconfig 10 -label "Sounds At & Above Highlight" -command {RemovePropItemsBeyond 0}

	set n 1
	while {$n < $propcnt} {
		if {$n > 15} {
			$f.f.0.3c.b$n config -text $propname($n) -state normal
		} elseif {$n > 10} {
			$f.f.0.3b.b$n config -text $propname($n) -state normal
		} elseif {$n > 5} {
			$f.f.0.3a.b$n config -text $propname($n) -state normal
		} else {
			$f.f.0.3.b$n config -text $propname($n) -state normal
		}
		incr n
	}
	set n 1
	while {$n < $propcnt} {
		set last_propchv($n) $propchv($n)
		set propchv($n) 0
		if {$n > 15} {
			$f.f.1.zc.b$n config -text "" -state disabled
		} elseif {$n > 10} {
			$f.f.1.zb.b$n config -text "" -state disabled
		} elseif {$n > 5} {
			$f.f.1.za.b$n config -text "" -state disabled
		} else {
			$f.f.1.z.b$n config -text "" -state disabled
		}
		incr n
	}
}

proc Reconfigure_Do_Props {} {
	global propcnt propname last_propchv propchv
	set f .prop_file 

	$f.a.b config -text "Select On Single Prop" -command Reset_Do_Props

	$f.01.l config -text "SELECTED VALUES OF PROPERTIES (separate by commas) ... or ... SEARCH-STRINGS"

	$f.a.l config -text "SELECT PROPERTIES TO WORK ON"
	$f.2.rea config -text "" -state disabled
	$f.2.red config -text "" -state disabled
	$f.2.rst config -text "" -state disabled

	$f.2.tes.menu entryconfig 0 -label "Get Data On Values Of Specified Properties"  -command {PropAllSets}
	$f.2.tes.menu entryconfig 2 -label "List In Groups, Files With All Selected Props Identical" -command {FindIdenticals 1}
	$f.2.tes.menu entryconfig 4 -label "The Same, Ignoring Files With No Property Value Assigned" -command {FindIdenticals 2}

	$f.5.fil config -text "" -state disabled
	$f.5.play config -text "" -state disabled
	$f.5.asse config -text "" -state disabled
	$f.5.cho config -text "" -state disabled
	$f.5.l config -text ""
	$f.5.e config -bd 0 -state disabled

	$f.2.kee.menu entryconfig 2 -label "Snds With Specified Vals Of Specified Properties" -command {SelectOnManyFields 1}
	$f.2.kee.menu entryconfig 4 -label "" -command {}
	$f.2.kee.menu entryconfig 6 -label "" -command {}
	$f.2.kee.menu entryconfig 8 -label "Snds Where Vals Of Specified Props Contain Specified Strings" -command {SelectOnManyFields 2}
	$f.2.kee.menu entryconfig 10 -label "Snds Where Vals Of Specified Props Start With Specified Strings" -command {SelectOnManyFields 6}
	$f.2.kee.menu entryconfig 12 -label "" -command {}
	$f.2.kee.menu entryconfig 14 -label "" -command {}
	$f.2.kee.menu entryconfig 16 -label "" -background [option get . background {}]
	$f.2.kee.menu entryconfig 18 -label "" -command {}

	$f.2.rmv.menu entryconfig 0 -label "With Specified Vals Of Specified Properties" -command {SelectOnManyFields 0}
	$f.2.rmv.menu entryconfig 2 -label "Where Vals Of Specified Props Contain Specified Strings" -command {SelectOnManyFields 3}
	$f.2.rmv.menu entryconfig 4 -label "Where Vals Of Specified Props Start With Specified Strings" -command {SelectOnManyFields 7}
	$f.2.rmv.menu entryconfig 6 -label "" -command {}
	$f.2.rmv.menu entryconfig 8 -label "" -command {}
	$f.2.rmv.menu entryconfig 10 -label "" -command {}

	set n 1
	while {$n < $propcnt} {
		if {$n > 15} {
			$f.f.0.3c.b$n config -text "" -state disabled
		} elseif {$n > 10} {
			$f.f.0.3b.b$n config -text "" -state disabled
		} elseif {$n > 5} {
			$f.f.0.3a.b$n config -text "" -state disabled
		} else {
			$f.f.0.3.b$n config -text "" -state disabled
		}
		incr n
	}
	set n 1
	while {$n < $propcnt} {
		if {$n > 15} {
			$f.f.1.zc.b$n config -text $propname($n) -state normal
		} elseif {$n > 10} {
			$f.f.1.zb.b$n config -text $propname($n) -state normal
		} elseif {$n > 5} {
			$f.f.1.za.b$n config -text $propname($n) -state normal
		} else {
			$f.f.1.z.b$n config -text $propname($n) -state normal
		}
		set propchv($n) $last_propchv($n) 
		incr n
	}
}

proc SelectOnManyFields {selecttype} {
	global prop_sellist propch proplisting old_proplist propname propfcnt propcnt
	global propchv

	if {[string length $prop_sellist] <= 0} {
		Inf "No Selection List Provided"
		Reset_Do_Props
		return
	}
	set n 1
	while {$n < $propcnt} {
		if {$propchv($n)} {
			lappend propsetlist $n
		}
		incr n
	}
	if {![info exists propsetlist]} {
		Inf "No Properties Selected"
		Reset_Do_Props
		return
	}
	set proplist $prop_sellist
	set OK 1
	set vals {}
	set props {}
	while {$OK} {
		set k [string first "," $proplist]
		if {$k < 0} {
			set val [string trim [string range $proplist 0 end]]
			if {[string length $val] > 0} {
				set j [string first " " $val]
				if {$j < 0} {
					lappend vals $val
				} else {
					Inf "You Cannot Use A Selection Item ('$val') With Spaces In It"
					Reset_Do_Props
					return
				}
			}
			break
		}
		if {$k==0} {
			set proplist [string range $proplist 1 end]
		} else {
			set val [string trim [string range $proplist 0 [expr $k - 1]]]
			if {[string length $val] > 0} {
				set j [string first " " $val]
				if {$j < 0} {
					lappend vals $val
				} else {
					Inf "You Cannot Use A Selection Item ('$val') With Spaces In It"
					Reset_Do_Props
					return
				}
				incr k
				set proplist [string range $proplist $k end]
			}
        }
	}
	if {![info exists vals]} {
		Inf "No Valid Property Values Entered"
		Reset_Do_Props
		return
	}
	if {[llength $vals] != [llength $propsetlist]} {
		Inf "Number Of Property Values Given Is Not Equal To Number Of Properties Selected"
		Reset_Do_Props
		return
	}
		
	foreach line [$proplisting get 0 end] {
		set line [split $line]
		catch {unset prop_set}
		foreach val $propsetlist {
			lappend prop_set [lindex $line $val]
		}
		lappend props $prop_set
	}
	set has_numbers 0
	switch -- $selecttype {
		1 {				;#	Sound has property, keep it
			set cnt 0
			foreach propset $props {
				set got 1
				foreach prop $propset val $vals {
					if {[regexp {^\?\?$} $prop]} {
					    if {![regexp {^\?\?$} $val]} {
							set got 0
							break
					    }
					} elseif {![string match $prop $val]} {
						set got 0
						break
					}
				}
				if {$got} {
					lappend nulines [$proplisting get $cnt]
				}
				incr cnt
			}
		}
		2 {			;#	Sound property contains string, keep it
			set cnt 0
			foreach propset $props {
				foreach prop $propset val $vals {
					set k [string first $val $prop]
					if {$k < 0} {
						break
					}
				}
				if {$k >= 0} {
					lappend nulines [$proplisting get $cnt]
				}
				incr cnt
			}
		}
		6 {			;#	Sound property starts with string, keep it
			set cnt 0
			foreach propset $props {
				foreach prop $propset val $vals {
					set k [string first $val $prop]
					if {$k != 0} {
						break
					}
				}
				if {$k == 0} {
					lappend nulines [$proplisting get $cnt]
				}
				incr cnt
			}
		}
		0 {			;#	Sound has property, reject it
			set cnt 0
			foreach propset $props {
				set got 0
				foreach prop $propset val $vals {
					if {[string match $prop $val]} {
						incr got
					}
				}
				if {$got != [llength $vals]} {
					lappend nulines [$proplisting get $cnt]
				}
				incr cnt
			}
		}
		3 {			;#	Sound property contains strings, reject it
			set cnt 0
			foreach propset $props {
				set got 0
				foreach prop $propset val $vals {
					set k [string first $val $prop]
					if {$k >= 0} {
						incr got
					}
				}
				if {$got != [llength $vals]} {
					lappend nulines [$proplisting get $cnt]
				}
				incr cnt
			}
		}
		7 {			;#	Sound property starts with strings, reject it
			set cnt 0
			foreach propset $props {
				set got 0
				foreach prop $propset val $vals {
					set k [string first $val $prop]
					if {$k == 0} {
						incr got
					}
				}
				if {$got != [llength $vals]} {
					lappend nulines [$proplisting get $cnt]
				}
				incr cnt
			}
		}
	}
	if {![info exists nulines]} {
		if {($selecttype == 1) || ($selecttype == 2)} {
			Inf "No Listed Files Have All The Values Of All The Properties"
		} else {
			Inf "No Listed Files Do Not Have The Values Of The Properties"
		}
		Reset_Do_Props
		return
	}
	set old_proplist [$proplisting get 0 end]
	$proplisting delete 0 end
	set cnt 0
	foreach line $nulines {
		$proplisting insert end $line
		incr cnt
	}
	set propfcnt $cnt
	Reset_Do_Props
}

proc PropCollection {typ} {
	global prop_coll old_proplist proplisting propfcnt propch

	switch -- $typ {
		0 {		;#	CLEAR COLLECTION
			if [AreYouSure] {
				catch {unset prop_coll}
			}
			return
		}
		1 {		;#	SHOW COLLECTION
			if {![info exists prop_coll]} {
				Inf "There Are No Collected Files"
				return
			}
			set old_proplist [$proplisting get 0 end]
			$proplisting delete 0 end
			set cnt 0
			foreach line $prop_coll {
				$proplisting insert end $line
				incr cnt
			}
			set propfcnt $cnt
			return
		}
		2 {		;#	ADD ALL FILES LISTED
			set k [$proplisting index end]
			set n 0
			catch {unset ilist}
			while {$n < $k} {
				lappend ilist $n
				incr n
			}
			if {![info exists ilist]} {
				Inf "There Are No Files Listed"
				return
			}
		}
		3 {		;#	ADD SELECTED FILES ONLY
			set ilist [$proplisting curselection]
			if {![info exists ilist] || ([llength $ilist] <= 0)} {
				Inf "There Are No Highlighted Files"
				return
			}
		}
		4 {		;#	SORT ON SPECIFIED PROPERTY
			if {$propch == 0} {
				Inf "No Property Specified"
				return
			}
			if {![info exists prop_coll] || ([llength $prop_coll] <= 0)} {
				Inf "No Files Collected Yet"
				return
			}
			SortOnField prop_coll
			return
		}
	}
	set cnt 0
	foreach i $ilist {
		set skip 0
		set line [$proplisting get $i]
		if {[llength $line] <= 0} {
			continue
		}
		set snd [lindex $line 0]
		if {[info exists prop_coll]} {
			foreach oldline $prop_coll {
				if {[llength $oldline] <= 0} {
					continue
				}
				set oldsnd [lindex $oldline 0]
				if {[string match $snd $oldsnd]} {
					set skip 1
					break
				}
			}
		}
		if {!$skip} {
			lappend prop_coll $line
			incr cnt
		}
	}
	if {$cnt == 0} {
		Inf "All These Files Are Already In The Collection"
		return
	}
}

proc MoveGroupsToTop {typ} {
	global propident_list old_proplist proplisting propfcnt pr_propident

	switch -- $typ {	;#	ALL LISTED FILES
		0 {
			set k [$propident_list index end]
			set i 0
			while {$i < $k} {
				lappend ilist $i
				incr i
			}
		}
		1 {	;#	SELECTED FILES ONLY
			set ilist [$propident_list curselection]
		}
	}
	if {![info exists ilist] || ([llength $ilist] <= 0)} {
		Inf "No Files Have Been Selected"
		return
	}
	foreach i $ilist {
		set line [$propident_list get $i]
		if {[llength $line] > 0} {
			lappend nulines $line
		}
	}
	if {![info exists nulines]} {
		Inf "No Files Have Been Selected"
		return
	}
	set old_proplist [$proplisting get 0 end]
	$proplisting delete 0 end
	set cnt 0
	foreach line $nulines {
		$proplisting insert end $line
		incr cnt
	}
	set propfcnt $cnt
	set pr_propident 0
}


#----  All values of a sets of specific properties

proc PropAllSets {} {
	global propchv proplisting pr_propsets prprset propsets_list comset propsetitem no_of_props propcnt evv

	catch {unset comset}
	catch {unset propsets_ranked}
	set n 1
	while {$n < $propcnt} {
		if {$propchv($n)} {
			lappend propsetlist $n
		}
		incr n
	}
	if {![info exists propsetlist]} {
		Inf "No Properties Selected"
		return
	}
	foreach line [$proplisting get 0 end] {
		set line [split $line]
		set k 0
		catch {unset array_name}
		catch {unset vals}
		foreach zz $propsetlist {
			set val [lindex $line $zz]
			lappend vals $val
			if {$k == 0} {
				set array_name $val
			} else {
				append array_name "," $val
			}
			incr k
		}
		if {![info exists comset($array_name)]} {
			set comset($array_name) 1
		} else {
			incr comset($array_name)
		}
	}
	if {![info exists comset]} {
		Inf "No Values Exist For This Property Set"
		return
	}
	set propsetitem 1
	set no_of_props [llength $propsetlist]
	set propset_names [SortPropSets 1]
	set propsetitem ""

	set f .propsets
	if [Dlg_Create $f "PROPERTY SETS" "set pr_propsets 0" -borderwidth $evv(BBDR)] {
		frame $f.0 -borderwidth $evv(BBDR)
		frame $f.1 -borderwidth $evv(BBDR)
		frame $f.2 -borderwidth $evv(BBDR)
		button $f.2.pri	-text "Print To File" -command {PrintPropsToFile propsets} -highlightbackground [option get . background {}]
		label $f.2.ll -text "Filename"
		entry $f.2.e -textvariable prprset -width 48
		button $f.0.s -text "Sort Sets nn Propno" -command {SortPropSets 0} -highlightbackground [option get . background {}]
		label $f.0.l -text "propno"
		entry $f.0.e -textvariable "propsetitem"
		button $f.0.r -text "Rank Sets" -command {PropSetCommon} -highlightbackground [option get . background {}]
		button $f.0.g -text "Keep Selected Set" -command {GetPropVal propsets} -highlightbackground [option get . background {}]
		button $f.0.q	-text "Close" -command {set pr_propsets 0} -highlightbackground [option get . background {}]
		pack $f.0.s $f.0.l $f.0.e $f.0.r $f.0.g -side left -padx 2
		pack $f.0.q -side right
		set propsets_list [Scrolled_Listbox $f.1.ll -width 48 -height 24 -selectmode multiple]
		pack $f.1.ll -side left -fill both -expand true
		pack $f.2.pri $f.2.e $f.2.ll -side left -padx 2 -fill x -expand true
		pack $f.0 $f.1 $f.2 -side top -fill x -expand true
		bind $f <Escape> {set pr_propsets 0}
	}
	raise $f
	update idletasks
	StandardPosition $f
	$propsets_list delete 0 end
	foreach val $propset_names {
		$propsets_list insert end $val
	}
	set pr_propsets 0
	My_Grab 0 $f pr_propsets $propsets_list
	tkwait variable pr_propsets
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc SortPropSets {initial} {
	global comset propsetitem propsets_list propsets_ranked no_of_props

	if {$initial} {
		set which 1
	} else {
		if {![regexp {^[0-9]+$} $propsetitem]} {
			Inf "Invalid Value Given To Prop Number ($propsetitem)"
			return
		}
		if {($propsetitem < 1) || ($propsetitem > $no_of_props)} {
			Inf "Prop Number Out Of Range (1  - $no_of_props)"
			return
		}
		set which $propsetitem
	}
	catch {unset propsets_ranked}
	incr which -1	
	set propset_names [array names comset]
	foreach item $propset_names {
		lappend propset_names_list [split $item ',']
	}		

	set sort_end [llength $propset_names_list]
	set propset_names_list [SetSort $propset_names_list $which 0 $sort_end]
	set propset_names_list [SubSorts $propset_names_list $which]
	unset propset_names
	foreach item $propset_names_list {
		lappend propset_names [join $item ","]
	}		
	if {$initial} {
		return $propset_names
	}
	$propsets_list delete 0 end
	foreach item $propset_names {
		$propsets_list insert end $item
	}
}

proc SetSort {propset_names_list which sort_start sort_end} {

	set sort_end_less_one [expr $sort_end - 1]

	set n $sort_start
	while {$n < $sort_end_less_one} {
		set propset_name_n [lindex $propset_names_list $n]
		set m $n
		incr m
		while {$m < $sort_end} {
			set propset_name_m [lindex $propset_names_list $m]
			set propset_val_n [lindex $propset_name_n $which]
			set propset_val_m [lindex $propset_name_m $which]
			if {[string compare $propset_val_n $propset_val_m] == 1} {
				set propset_names_list [lreplace $propset_names_list $n $n $propset_name_m]
				set propset_names_list [lreplace $propset_names_list $m $m $propset_name_n]
				set temp $propset_name_n
				set propset_name_n $propset_name_m
				set propset_name_m $temp
			}
			incr m
		}
		incr n
	}
	return $propset_names_list
}

proc SubSorts {propset_names_list which} {
	global no_of_props

	set len [llength $propset_names_list]
	set k 0
	while {$k < $no_of_props} {
		if {$k != $which} {
			set thisname [lindex [lindex $propset_names_list 0] $which]
			set z 0 
			while {$z < $k} {
				if {$z != $which} {
					lappend thisname [lindex [lindex $propset_names_list 0] $z]
				}
				incr z
			}
			set startn 0
			set n 1
			while {$n < $len} {
				set thatname [lindex [lindex $propset_names_list $n] $which]
				set z 0 
				while {$z < $k} {
					if {$z != $which} {
						lappend thatname [lindex [lindex $propset_names_list $n] $z]
					}
					incr z
				}
				set ended 0
				foreach this $thisname that $thatname {
					if {![string match $this $that]} {
						set ended 1
						break
					}
				}
				if {$ended} {
					if {[expr $n - $startn] > 1} {
						set propset_names_list [SetSort $propset_names_list $k $startn $n]

					}
					set startn $n
					set thisname $thatname
				}
				incr n
			}
			if {[expr $n - $startn] > 1} {
				set propset_names_list [SetSort $propset_names_list $k $startn $n]
			}
		}
		incr k
	}
	return $propset_names_list
}

proc PropSetCommon {} {
	global propsets_list comset propsets_ranked

	set cnt 0
	Block "RANKING PROPERTY SETS"
	if {[info exists propsets_ranked]} {
		UnBlock
		return
	}
	foreach val [array names comset] {
		if {$cnt == 0} {
			lappend prvals $val
			lappend prcnts $comset($val)	
		} else {
			set done 0
			set cnt2 0
			foreach prval $prvals prcnt $prcnts {
				if {$comset($val) >= $prcnt} {
					set prcnts [linsert $prcnts $cnt2 $comset($val)]
					set prvals [linsert $prvals $cnt2 $val]
					set done 1
					break
				}
				incr cnt2
			} 
			if {!$done} {
				lappend prcnts $comset($val)
				lappend prvals $val
			}
		}
		incr cnt
	}
	$propsets_list delete 0 end
	foreach prval $prvals prcnt $prcnts {
		set line $prval
		append line "      " $prcnt
		$propsets_list insert end $line
	}
	set propsets_ranked 1 
	UnBlock
}

proc SearchProps {} {
	global proplisting text_search

	if {[string length $text_search] <= 0} {
		Inf "No Search String Entered"
		return
	}
	set ilist [$proplisting	curselection]

	if {[llength $ilist] <= 0} {
		set q 0
	} else {
		set q [lindex $ilist 0]
		incr q
		if {$q == [$proplisting index end]} {
			set q 0
		}
	}
	set k $q
	foreach line [$proplisting get $q end] {
		if {[string first $text_search $line] >= 0} {
			$proplisting selection clear 0 end
			$proplisting selection set $k
			$proplisting yview moveto [expr double($k)/[$proplisting index end]]
			return
		}
		incr k
	}
	if {$q != 0} {
		set k 0
		foreach line [$proplisting get 0 $q] {
			if {[string first $text_search $line] >= 0} {
				$proplisting selection clear 0 end
				$proplisting selection set $k
				$proplisting yview moveto [expr double($k)/[$proplisting index end]]
				return
			}
			incr k
		}
	}
	Inf "String '$text_search' Not Found"
}

proc NewPropfile {} {
	global wl pa evv pr_newprop newpropcnt newpropno newpropname newpropval newpropfnam wstk propfiles_list
	global counter_bg readonlyfg readonlybg old_props_protocol chlist

	set ilist [$wl curselection]
	if {![info exists ilist] || ([llength $ilist] <= 0)} {
		if {[info exists chlist]} {
			if {([llength $chlist] != 1) } {
				Inf "Select Just One Workspace Soundfile, To Initialise A New Property File."
				return
			} 
			set infnam [lindex $chlist 0]
		} else {
			Inf "No Workspace Soundfile Selected"
			return
		}
	} else {
		if {[llength $ilist] > 1} {
			Inf "Select Just One Workspace Soundfile, To Initialise A New Property File."
			return
		}
		set i [lindex $ilist 0]
		set infnam [$wl get $i]
	}
	if {![info exists pa($infnam,$evv(FTYP))] || ($pa($infnam,$evv(FTYP)) != $evv(SNDFILE))} {
		Inf "File $infnam Is Not A Soundfile."
		return
	}
	if {[string match [file tail $infnam] $infnam]} {
		Inf "Soundfile Must Be Saved To A Directory Before Property File Can Be Created."
		return
	}
	if {$old_props_protocol} {
		set infnam [file tail $infnam]
	}
	set f .newprop
	if [Dlg_Create $f "NEW PROPERTY FILE" "set pr_newprop 0" -borderwidth $evv(BBDR)] {
		set f0 [frame $f.0 -borderwidth $evv(BBDR)]
		set f1 [frame $f.1 -borderwidth $evv(BBDR)]
		set f2 [frame $f.2 -borderwidth $evv(BBDR)]
		set f3 [frame $f.3 -borderwidth $evv(BBDR)]
		set f4 [frame $f.4 -borderwidth $evv(BBDR)]
		set f5 [frame $f.5 -borderwidth $evv(BBDR)]
		set f6 [frame $f.6 -borderwidth $evv(BBDR)]
		set f7 [frame $f.7 -borderwidth $evv(BBDR)]
		button $f.0.create -text "" -bd 0 -command {set pr_newprop 4} -state disabled -width 11 -highlightbackground [option get . background {}]
		button $f.0.quit -text "Abandon" -command {set pr_newprop 0} -highlightbackground [option get . background {}]
		pack $f.0.create -side left		
		pack $f.0.quit -side right
		label $f.1.ll -text "Property Count"
		entry $f.1.e -textvariable newpropcnt -width 2 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $f.1.ll $f.1.e -side left
		label $f.2.ll -text "  "
		pack $f.2.ll -side top
		label $f.3.ll -text "This Property Number"
		entry $f.3.e -textvariable newpropno -width 2 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $f.3.ll $f.3.e -side left
		label $f.4.ll -text "Property Name"
		entry $f.4.e -textvariable newpropname -width 10
		pack $f.4.e $f.4.ll -side right
		label $f.5.ll -text "Property Value for this file"
		entry $f.5.e -textvariable newpropval -width 10
		pack $f.5.e $f.5.ll -side right
		button $f.6.enter -text "Enter This Prop" -command {set pr_newprop 1} -width 18 -highlightbackground [option get . background {}]
		button $f.6.conclude -text "No More Props" -command {set pr_newprop 2} -width 16 -highlightbackground [option get . background {}]
		button $f.6.restart -text "Restart" -command {set pr_newprop 3} -width 10 -highlightbackground [option get . background {}]
		pack $f.6.enter $f.6.conclude $f.6.restart -side left -padx 6
		label $f.7.ll -text ""
		entry $f.7.e -textvariable newpropfnam -width 20 -bd 0 -state disabled -disabledbackground [option get . background {}]
		pack $f.7.ll $f.7.e -side left
		pack $f.0 -side top -fill x -expand true
		pack $f.1 $f.2 $f.3 -side top -pady 1
		pack $f.4 $f.5 -side top -pady 1 -fill x -expand true
		pack $f.6 $f.7 -side top -pady 1

		bind $f.4.e <Down>   "focus .newprop.5.e"
		bind $f.4.e <Up>     "focus .newprop.5.e"
		bind $f.5.e <Down>   "focus .newprop.4.e"
		bind $f.5.e <Up>     "focus .newprop.4.e"
		bind $f <Escape> {set pr_newprop 0}
	}
	$f.3.ll config -text "This Property Number"
	$f.3.e config  -bd 2
	$f.4.ll config -text "Property Name"
	$f.4.e config -bd 2 -state normal
	$f.5.ll config -text "Property Value for this file"
	$f.5.e config -bd 2 -state normal
	$f.6.enter config -bd 2 -text "Enter This Prop" -state normal
	$f.6.conclude config -bd 2 -text "No More Props" -state normal
	$f.6.restart config -bd 2 -text "Restart" -state normal
	$f.7.ll config -text ""
	$f.7.e config -bd 0 -state disabled
	$f.0.create config -text "" -bd 0 -command {set pr_newprop 4} -state disabled
	set pr_newprop 0
	set newpropfnam ""
	set newpropname ""
	set newpropval ""
	set newpropcnt 0
	set newpropno 1
	ForceVal $f.1.e $newpropcnt
	ForceVal $f.3.e $newpropno
	$f.3.e config -disabledbackground $counter_bg
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_newprop $f.4.e
	set newpropslist {}
	while {!$finished} {
		tkwait variable pr_newprop
		switch -- $pr_newprop {
			0 {	;#	QUIT
				break
			}
			1 {	;#	ENTER PROPERTY
				set newpropname [string trim $newpropname]
				if {[string length $newpropname] <= 0} {
					Inf "No Property Name Entered"
					continue
				}
				set test [split $newpropname]
				if {[llength $test] > 1} {
					Inf "Property Names Cannot Contain Spaces"
					continue
				}
				if {[regexp {[\,]} $newpropname]} {
					Inf "Property Names Cannot Contain Commas"
					continue
				}
				if {[regexp {[\£\$]} $newpropname]} {
					Inf "Property Names Cannot Contain '$' Or '£' Signs"
					continue
				}
				set newpropval [string trim $newpropval]
				if {[string length $newpropval] <= 0} {
					Inf "No Property Value Entered"
					continue
				}
				set test [split $newpropval]
				if {[llength $test] > 1} {
					Inf "Property Values Cannot Contain Spaces"
					continue
				}
				if {[regexp {[\,]} $newpropval]} {
					Inf "Property Values Cannot Contain Commas"
					continue
				}
				if {[regexp {[\£\$]} $newpropval]} {
					Inf "Property Values Cannot Contain '$' Or '£' Signs"
					continue
				}
				lappend newpropslist $newpropname
				lappend newpropslist $newpropval
				set newpropname ""
				set newpropval ""
				incr newpropcnt
				incr newpropno
				ForceVal $f.1.e $newpropcnt
				ForceVal $f.3.e $newpropno
				focus .newprop.4.e
				continue
			}
			2 {	;#	GO TO SAVE PROPERTIES ENTERED
				if {$newpropcnt <= 0} {
					Inf "No Properties Have Been Entered"
					continue
				}
				set msg "Are You Sure You Have Entered All The Properties You Need ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				$f.3.ll config -text ""
				set newpropno ""
				ForceVal $f.3.e $newpropno
				$f.3.e config -bd 0 -disabledbackground [option get . background {}]
				set newpropname ""
				$f.4.ll config -text ""
				$f.4.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
				set newpropval ""
				$f.5.ll config -text ""
				$f.5.e config -bd 0 -state disabled -disabledbackground [option get . background {}]
				$f.6.enter config -bd 0 -text "" -state disabled
				$f.6.conclude config -bd 0 -text "" -state disabled
				$f.6.restart config -bd 0 -text "" -state disabled
				$f.7.ll config -text "PROPERTY FILE NAME"
				$f.7.e config -bd 2 -state normal
				$f.0.create config -text "Save Propfile" -bd 2 -command {set pr_newprop 4} -state normal
				continue
			}
			3 {	;#	START AGAIN
				set newpropslist {}
				set newpropfnam ""
				set newpropname ""
				set newpropval ""
				set newpropcnt 0
				set newpropno 1
				ForceVal $f.1.e $newpropcnt
				ForceVal $f.3.e $newpropno
				continue
			}
			4 {	;#	NAME PROPERTY FILE, AND ENABLE EXIT SAVING IT
				set newpropfnam [string trim $newpropfnam]
				if {[string length $newpropfnam] <= 0} {
					Inf "No Property-File Name Entered"
					continue
				}
				if {![ValidCDPRootname $newpropfnam]} {
					continue
				}
				set outfnam $newpropfnam
				set this_ext [GetTextfileExtension props]
				append outfnam $this_ext
				if {[file exists $outfnam]} {
					set msg "File  '$newpropfnam' Already Exists: Do You Want To Overwrite It??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
				}
				if [catch {open $outfnam "w"} zit] {
					Inf "Cannot Open File '$newpropfnam'"
					continue
				}
				set line1 ""
				set line2 $infnam
				append line2 " "
				foreach {nname vval} $newpropslist {
					append line1 $nname " "
					append line2 $vval " "
				}
				set len [string length $line1]
				incr len -2
				set line1 [string range $line1 0 $len]
				set len [string length $line2]
				incr len -2
				set line2 [string range $line2 0 $len]
				puts $zit $line1
				puts $zit $line2
				close $zit
				if {[FileToWkspace $outfnam 0 0 0 0 1]} {
					Inf "Property File '$outfnam' Has Been Placed On The Workspace"
				} else {
					Inf "Property File '$outfnam' Has Been Created, But Is Not On The Workspace"
				}
				if {[info exists propfiles_list]} {
					if {[lsearch $propfiles_list $outfnam] < 0} {
						lappend propfiles_list $outfnam
					}
				} else {
					lappend propfiles_list $outfnam
				}
				set finished 1
				break
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc ShowKnownPropfiles {} {
	global propfiles_list pr_propknown knownpropfiles wl evv
	if {![info exists propfiles_list] || ([llength $propfiles_list] <= 0)} {
		Inf "No Property Files Are Known About At The Moment."
		return
	}
	set f .show_known_propfiles
	if [Dlg_Create $f "POSSIBLE PROPERTY FILES" "set pr_propknown 0" -borderwidth $evv(BBDR)] {
		frame $f.0 -borderwidth $evv(BBDR)
		frame $f.1 -borderwidth $evv(BBDR)
		button $f.0.get -text "File to Wkspace" -command {set pr_propknown 1} -width 18 -highlightbackground [option get . background {}]
		button $f.0.qu -text "Close" -command {set pr_propknown 0} -width 10 -highlightbackground [option get . background {}]
		pack $f.0.get -side left -pady 2
		pack $f.0.qu -side right -pady 2
		set knownpropfiles [Scrolled_Listbox $f.1.kk -width 120 -height 16 -selectmode single]
		label $f.1.ll -text "POSSIBLE PROPERTY FILES"
		pack $f.1.ll $f.1.kk -side top -pady 2
		pack $f.0 $f.1 -side top -pady 2 -fill x -expand true		
		bind $f <Return> {set pr_propknown 1}
		bind $f <Escape> {set pr_propknown 0}
	}
	raise $f
	update idletasks
	StandardPosition $f
	$knownpropfiles delete 0 end
	foreach val $propfiles_list {
		$knownpropfiles insert end $val
	}
	set pr_propknown 0
	set finished 0
	My_Grab 0 $f pr_propknown $knownpropfiles
	while {!$finished} {
		tkwait variable pr_propknown
		if {$pr_propknown} {
			set i [$knownpropfiles curselection]
			if {$i < 0} {
				Inf "No Property File Selected"
				continue
			}
			set fnam [$knownpropfiles get $i]
			set i [LstIndx $fnam $wl]
			if {$i >= 0} {
				$wl selection clear 0 end
				$wl selection set $i
			} else {
				if {[FileToWkspace $fnam 0 0 0 0 0] > 0} {
					$wl selection clear 0 end
					$wl selection set 0
				} else {
					continue
				}
			}
			break
		} else {
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc ThisIsAPropsFile {propfnam msgs rename} {
	global propfiles_list wstk propdir pa evv old_props_protocol props_info readin_props readin_propfile
	set props_info {}
	if {$old_props_protocol} {
		GetPropFileDir
	}
	if {![info exists propfiles_list]} {
		set is_a_known_propfile -1
	} else {
		set is_a_known_propfile [lsearch $propfiles_list $propfnam]
	}
	if {[info exists pa($propfnam,$evv(FTYP))] && ($pa($propfnam,$evv(FTYP)) == $evv(MIX_MULTI))} {
		if {$is_a_known_propfile >= 0} {
			set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
		}
	}
	if {![info exists propfiles_list]} {
		return 0
	}
	if [catch {open $propfnam "r"} zit] {
		if {$msgs} {
			Inf "Cannot Open Text File '$propfnam'"
		}
		return 0
	}
	while {[gets $zit line] >= 0} {
		lappend propfile $line
	}
	close $zit
	if {![info exists propfile]} {
		if {$msgs} {
			Inf "File '$propfnam' Is Empty"
		}
		if {$is_a_known_propfile >= 0} {
			set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
		}
		return 0
	}
	if {[llength $propfile] < 2} {
		if {$msgs} {
			Inf "'$propfnam' Is Not A Valid Properties File"
		}
		if {$is_a_known_propfile >= 0} {
			set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
		}
		return 0
	}
	set linecnt 0
	set itemcnt 0
	set sndcnt 0
	foreach line $propfile {
		set thisline_itemcnt 0
		catch {unset nuline}
		set line [string trim $line]
		set line [split $line]
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend nuline $item
				incr thisline_itemcnt
			}
		}
		if {$thisline_itemcnt > 0} {
			if {$linecnt == 0} {			;# FIRST LINE, SPECIAL CASE FOR PROPS FILES
				set theseprops $nuline
				set itemcnt $thisline_itemcnt
				incr itemcnt	;# lines to follow have filename, as well as props (if they're property files)
			} else {
				if {$thisline_itemcnt != $itemcnt} {
					if {$msgs} {
						Inf "Number Of Properties Incorrect On Line [expr $linecnt + 1]"
					}
					if {$is_a_known_propfile >= 0} {
						set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
					}
					return 0
				}
				set thisfnam [lindex $nuline 0]
				if {$old_props_protocol} {
					if {![string match [file tail $thisfnam] $thisfnam]} {
						Inf "Property Files Cannot Contain Soundfile Pathnames With Old Protocol"
						return 0
					}
					set thisfnam [file join $propdir $thisfnam]
				} else {
					if {[string match [file tail $thisfnam] $thisfnam]} {
						Inf "Property Files Must Contain Soundfile Pathnames With New Protocol"
						return 0
					}
				}
				if {![file exists $thisfnam]} {
					lappend nonexistent $linecnt
					lappend non_existent $thisfnam
				} elseif {[FindFileType $thisfnam] != $evv(SNDFILE)} {
					lappend notsound $linecnt
					lappend not_sound $thisfnam
				} else {
					incr sndcnt
				}
			}
			lappend nupropfile $nuline
			incr linecnt 
		}
	}
	if {$linecnt <= 0} {
		if {$msgs} {
			Inf "No Values Found In File '$propfnam'"
		}
		if {$is_a_known_propfile >= 0} {
			set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
		}
		return 0
	}
	if {!$rename} {
		if {[info exists non_existent] || [info exists not_sound]} {
			set msg ""
			if {[info exists non_existent]} {
				append msg "The Following Files No Longer Exist..\n\n"
				set len [llength $non_existent]
				set cnt 0
				while {$cnt < $len} {
					set fnam [lindex $non_existent $cnt]
					incr cnt
					if {$cnt > 20} {
						append msg "\n\nAnd More"
						break
					}
					append msg $fnam "   "
				}
				append msg "\n"
			}
			if {[info exists not_sound]} {
				append msg "The Following Files Are Not Sound Files..\n\n"
				set len [llength $not_sound]
				set cnt 0
				while {$cnt < $len} {
					set fnam [lindex $not_sound $cnt]
					incr cnt
					if {$cnt > 20} {
						append msg "\n\nAnd More"
						break
					}
					append msg $fnam "   "
				}
				append msg "\n"
			}
			if {$sndcnt == 0} {
				append msg "\nThere Are No Valid Soundfiles Listed In This Property File"
				if {$msgs} {
					Inf $msg
				}
				if {$is_a_known_propfile >= 0} {
					set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
				}
				return 0
			} else {
				append msg "\nRemove These Items From The Properties File ??"
				set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
				if {$choice == "yes"} {
					if {[info exists nonexistent]} {
						foreach i $nonexistent {
							lappend kill $i
						}
					}
					if {[info exists notsound]} {
						foreach i $notsound {
							lappend kill $i
						}
					}
					set kill [lsort -integer -decreasing $kill]
					foreach i $kill {
						set nupropfile [lreplace $nupropfile $i $i]
					}
					set readin_props $theseprops
					set readin_propfile [lrange $nupropfile 1 end]
					OverwritePropsfile $propfnam readin
				}
			}
		}
		if {$sndcnt == 0} {
			if {$msgs} {
				Inf "No Soundfiles Listed In File '$propfnam'"
			}
			if {$is_a_known_propfile >= 0} {
				set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
			}
			return 0
		}
	}
	set propfile [lrange $nupropfile 1 end]
	if {!$rename} {
		if {$is_a_known_propfile < 0} {		;# IF file not previously known as a propfile, add it to list of known profiles
			AddToPropfilesList $propfnam
		}
	}
	set props_info [list $theseprops $propfile]
	return 1
}

proc CountProps {} {
	global orig_propall_list
	Inf "Number Of Property Values = [llength $orig_propall_list]"
}

proc AddToPropfilesList {fnam} {
	global propfiles_list
	if {![info exists propfiles_list] || ([lsearch $propfiles_list $fnam] < 0)} {
		lappend propfiles_list $fnam
	}
}

proc ScanForPropFiles {} {
	global wl evv
	set thislist {}
	set this_ext [GetTextfileExtension props]
	if {![string match $this_ext $evv(TEXT_EXT)]} {
		foreach fnam [$wl get 0 end] {
			if {[string match [file extension $fnam] $this_ext]} {
				lappend thislist $fnam
			}
		}
	}
	return $thislist
}

proc HasUserDefinedPropfileExtension {fnam} {
	global evv
	set this_ext [GetTextfileExtension props]
	if {![string match $this_ext $evv(TEXT_EXT)]} {
		if {[string match [file extension $fnam] $this_ext]} {
			return 1
		}
	}
	return 0
}

proc UpdatePropfilesList {fnam newname} {
	global propfiles_list
	if {[info exists propfiles_list]} {
		set k [lsearch -exact $propfiles_list $fnam]
		if {$k >= 0} {
			set propfiles_list [lreplace $propfiles_list $k $k $newname]
		}
	}
}

proc PurgePropfilesList {fnam} {
	global propfiles_list
	if {[info exists propfiles_list]} {
		set k [lsearch -exact $propfiles_list $fnam]
		if {$k >= 0} {
			set propfiles_list [lreplace $propfiles_list $k $k]
		}
	}
}

proc SavePropfilesList {} {
	global propfiles_list evv
	if {[info exists propfiles_list]} {
		set tmpfnam $evv(DFLT_TMPFNAME)
		if [catch {open $tmpfnam w} fileId] {
			Inf "Cannot open temporary file to remember known properties files."
		} else {
			foreach ppp $propfiles_list {
				puts $fileId $ppp
			}
			close $fileId		
			set ofil [file join $evv(URES_DIR) $evv(PROPFILES_LIST)$evv(CDP_EXT)] 
			if [catch {file rename -force $evv(DFLT_TMPFNAME) $ofil} zit] {
				Inf "Cannot retain list of known properties files (list is in file '$tmpfnam')"
			}
		}
	} else {
		set ofil [file join $evv(URES_DIR) $evv(PROPFILES_LIST)$evv(CDP_EXT)] 
		if {[file exists $ofil]} {
			catch {file delete $ofil}
		}
	}
}

#---- New interface for adding sounds to a properties file

proc AddSndsToPropfile {} {
	global pr_nuaddp wstk wl chlist propfiles_list evv
	global old_props_protocol adp_sndfiles adp_props_list adp_propnames adp_pcnt adp_pthis adp_propcnt last_nuaddpsnd
	global nuaddpsnd nuaddpnam nuaddpval addp_pname nuaddp_evals nuaddp_snds nuaddp_vals last_confirmed_nuaddpsnd
	global nuaddp_nams nuaddp_esnds nuaddpsel addp_opname adp_orig_props_list props_info
	global total_wksp_cnt rememd tp_props_list tp_props_cnt tp_propnames tp_bfw tp_boxwid prp_nulwarn

	if {$old_props_protocol} {
		return
	}
	Block "Adding sound to properties file"
	set pfnamcnt 0
	set ii 0
	foreach pfnam [$wl get 0 end] {									;#	Check if there's only ONE properties file on workspace
		if {[string match [file extension $pfnam] ".prp"]} {
			set ppfnam $pfnam
			set iitxt $ii
			incr pfnamcnt
			if {$pfnamcnt > 1} {
				break
			}
		}
		incr ii
	}
	if {$pfnamcnt == 1} {											;#	If so, setup this as "onlyprop", and remember its position "iitxt"
		set onlyprop $ppfnam
	}
	set ilist [$wl curselection]										;#	If not enough files selected
	if {![info exists ilist] || ([llength $ilist] <= 0) || ([lindex $ilist 0] == -1)} {
		$wl selection clear 0 end
		catch {unset ilist}
		if {[info exists chlist] && ([llength $chlist] > 0)} {
			foreach item $chlist {
				set k [LstIndx $item $wl]
				if {$k >= 0} {
					lappend ilist $k
					$wl selection set $i
				}
			}
			if {[info exists ilist]} {
				if {[info exists onlyprop] && ([lsearch $ilist $iitxt] < 0)} {
					lappend ilist $iitxt
					$wl selection set $iitxt
				}
			} 
		} else {
			Inf "No workspace files selected"
			UnBlock
			return
		}
	} elseif {[info exists onlyprop] && ([lsearch $ilist $iitxt] < 0)} {
		lappend ilist $iitxt
		$wl selection set $iitxt
	}
	if {[llength $ilist] < 2} {											;#	If less than 2 selected	: i.e. only 1	
		set msg "If only one property file on workspace, select one or more sound files (or place on chosen files list)\n\n"
		append msg "Else select just one property file and any number of sound files on the workspace\n"
		append msg "or place these on the chosen files list"
		Inf $msg
		UnBlock
		return
	}
	foreach i $ilist {
		set fnam [$wl get $i]
		set ftyp [FindFileType $fnam]
		if {$ftyp < 0} {
			lappend badfiles $fnam
		} elseif {$ftyp == $evv(SNDFILE)} {
			lappend sndfiles $fnam
		} elseif {$ftyp & $evv(IS_A_TEXTFILE)} {
			lappend textfiles $fnam
		} else {
			lappend bumfiles $fnam
		}
	}
	if {![info exists sndfiles]} {
		Inf "No Sound Files Selected\n\nSelect Just One Property File And Any Number Of Sound Files."
		UnBlock
		return
	}
	if {![info exists textfiles]} {
		Inf "No Property File Selected\n\nSelect Just One Property File And Any Number Of Sound Files."
		UnBlock
		return
	}
	if {[llength $textfiles] > 1} {
		set msg "At Least One Too Many Textfiles Selected\n\nSelect Just One Property File And Any Number Of Sound Files.\n\nTextfiles Selected\n"
		set cnt 0
		foreach fnam $textfiles {
			append msg "$fnam\n"
			incr cnt
			if {$cnt >= 20} {
				append msg "AND MORE\n"
				break
			}
		}
		Inf $msg
		UnBlock
		return
	}
	set pfile [lindex $textfiles 0]
	if {![ThisIsAPropsFile $pfile 1 0]} {
		UnBlock
		return
	}
	set adp_propnames [lindex $props_info 0]
	set adp_props_list [lindex $props_info 1]
	set adp_orig_props_list $adp_props_list

	if {[info exists badfiles]} {
		set msg "The Following Files Were Selected, But Their File Type Could Not Be Determined.....\n\n"
		set cnt 0
		set len [llength $badfiles]
		while {$cnt < $len} {
			set fnam [lindex $badfiles $cnt]
			incr cnt
			if {$cnt > 20} {
				append msg "\n\nAnd More"
				break
			}
			append msg $fnam "   "
		}
		Inf $msg
	}
	if {[info exists bumfiles]} {
		set msg "The Following Selected Files, Are Neither Soundfiles Or Textfiles.....\n\n"
		set cnt 0
		set len [llength $bumfiles]
		while {$cnt < $len} {
			set fnam [lindex $bumfiles $cnt]
			incr cnt
			if {$cnt > 20} {
				append msg "\n\nAnd More"
				break
			}
			append msg $fnam "   "
		}
		Inf $msg
	}
	foreach fnam $sndfiles {
		if {[string match $fnam [file tail $fnam]]} {
			lappend badsnds $fnam
		}
	}
	if {[info exists badsnds]} {
		if {[llength $badsnds] == 1} {
			set msg "The Soundfile '$badsnds' Is Not Backed Up To A Directory\n"
			append msg "And Therefore Cannot Be Listed In A Properties File"
		} else {
			set msg "The Following Selected Soundfiles, Are Not Backed Up To A Directory\n"
			append msg "And Therefore Cannot Be Listed In A Properties File"
			set cnt 0
			set len [llength $badsnds]
			while {$cnt < $len} {
				set fnam [lindex $badsnds $cnt]
				incr cnt
				if {$cnt > 20} {
					append msg "\n\nAnd More"
					break
				}
				append msg $fnam "   "
			}
		}
		Inf $msg
		if {[llength $badsnds] == [llength $sndfiles]} {
			UnBlock
			return
		}
	}
	catch {unset adp_sndfiles}
	foreach line $adp_props_list {
		lappend adp_sndfiles [lindex $line 0]
	}
	foreach sndin $sndfiles {
		if {[lsearch $adp_sndfiles $sndin] >= 0} { 
			lappend already_snd $sndin
		}
	}
		;#		ADD NEW SOUNDS WITH ALL NULL PROPERTIES

	if {[info exists already_snd]} {
		if {[llength $already_snd] == [llength $sndfiles]} {
			Inf "All These Sounds Are Already In The Properties File"
			UnBlock
			return
		}
		foreach snd $already_snd {
			set k [lsearch $sndfiles $snd]
			if {$k >= 0} {
				set sndfiles [lreplace $sndfiles $k $k]
			}
		}
	}
	foreach sndin $sndfiles {
		set line $sndin
		foreach prop $adp_propnames {
			lappend line "-"
		}
		lappend adp_props_list $line
	}
	if {![OverwritePropsfile $pfile adp]} {
		UnBlock
		return
	}
	set len [llength $sndfiles]
	UnBlock
	if {$len == 1} {
		Inf "One Sound Added To Properties File \"[file rootname [file tail $pfile]]\""
	} else {
		Inf "$len Sounds Added To Properties File \"[file rootname [file tail $pfile]]\""
	}
}

proc AdpFillExistingValsList {propno} {
	global adp_props_list nuaddp_evals nuaddp_vals adp_pcnt nuaddpsnd evv
	$nuaddp_evals delete 0 end
	set plist {}
	foreach line $adp_props_list {
		set snd [lindex $line 0]
		if {[string match $snd $nuaddpsnd]} {
			if {($propno < $adp_pcnt) && ([string length [$nuaddp_vals get $propno]] > 0)} {
				set val [$nuaddp_vals get $propno]
			} else {
				set val [lindex $line [expr $propno + 1]]
			}
		} else {
			set val [lindex $line [expr $propno + 1]]
		}
		if {[string match $val $evv(NULL_PROP)]} {
			continue
		}
		if {[lsearch $plist $val] < 0} {
			lappend plist $val
		}
	}
	set plist [lsort -dictionary $plist]		;#	LIST (SORTED) EXISTING VALS OF PROP
	foreach prp $plist {
		$nuaddp_evals insert end $prp
	}
}

#--- Deduce line on which property appears from name of sndfile on that line

proc GetPropLinenoFromSndname {sndfnam} {
	global adp_props_list
	set n 0
	foreach line $adp_props_list {
		set fnam [lindex $line 0]
		if {[string match $fnam $sndfnam]} {
			return $n
		}
		incr n
	}
	return -1
}

proc AddpNull {} {
	global nuaddpval nuaddpnam
	if {[string length $nuaddpnam] <= 0} {
		return
	}
	set nuaddpval "-"
}

proc PropsListHasChanged {} {
	global adp_orig_props_list adp_props_list createdhf
	if {[llength $adp_orig_props_list] != [llength $adp_props_list]} {
		return 1
	}
	foreach oline $adp_orig_props_list line $adp_props_list {
		foreach oprp $oline prp $line {
			if {[string compare $oprp $prp]} {
				return 1
			}
		}
	}
	if {[info exists createdhf]} {
		unset createdhf
		return 1
	}
	return 0
}

proc AdpPlaySndfile {inprops} {
	global nuaddpsnd nuaddpsel
	if {$inprops} {
		set thissnd $nuaddpsel
	} else {
		set thissnd $nuaddpsnd
	}
	if {[string length $thissnd] <= 0} {
		return
	} elseif {![file exists $thissnd]} {
		return
	}
	PlaySndfile $thissnd 0
}

#------ Change the values of a property globally

proc GlobalPropVals {} {
	global propval_vals pr_prpglob prglobfil pradglob prgloborig prglobnew prgloblist prglobselect wstk evv
	set fnam [SelectedFileIsAPropertyFile 0 0]
	if {[string length $fnam] <= 0} {
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File $fnam"
		return
	}
	set n 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		set line [split $line]
		if {$n == 0} {
			catch {unset nameslist}
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] > 0} {
					lappend nameslist $item
				}
			}
			if {[info exists nameslist]} {
				incr n
			}
		} else {
			catch {unset nuline}
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] > 0} {
					lappend nuline $item
				}
			}
			if {[info exists nuline]} {
				lappend propvallines $nuline
			}
		}
	}
	close $zit
	if {![info exists nameslist] || ![info exists propvallines]} {
		Inf "No Significant Data Found In File $fnam"
		return
	}
	set namcnt [llength $nameslist]
	set n 1
	while {$n <= $namcnt} {
		set propval_vals($n) {}
		incr n
	}
	foreach line $propvallines {
		set n 1
		while {$n <= $namcnt} {
			set val [lindex	$line $n]
			if {![string match $val "-"] && ([lsearch $propval_vals($n) $val] < 0)} {
				lappend propval_vals($n) $val
			}
			incr n
		}
	}	
	set f .prpglob
	if [Dlg_Create $f "GLOBALLY CHANGE PROPERTY VALUES" "set pr_prpglob 0" -borderwidth $evv(BBDR)] {
		frame $f.a -borderwidth $evv(BBDR)
		button $f.a.q -text "Abandon Changes" -command {set pr_prpglob 0} -highlightbackground [option get . background {}]
		button $f.a.k -text "Keep Changes" -command {set pr_prpglob 2} -highlightbackground [option get . background {}]
		label $f.a.ll -text "New propfile name  "
		entry $f.a.e -textvariable prglobfil -width 16
		pack $f.a.k $f.a.ll $f.a.e -side left
		pack $f.a.q -side right
		pack $f.a -side top -fill x -expand true -pady 2
		frame $f.b -borderwidth $evv(BBDR)
		set n 1
		set m 0
		set thisrow 0
		foreach name $nameslist {
			radiobutton $f.b.n$n -text $name -variable pradglob -value $n -command PropGlobList
			grid $f.b.n$n -row $thisrow -column $m
			incr n
			incr m
			if {$m >= 6} {
				set m 0
				incr thisrow
			}
		}
		pack $f.b -side top -fill x -expand true -pady 2
		frame $f.c -borderwidth $evv(BBDR)
		label $f.c.ol -text "Original Value  "
		entry $f.c.ov -textvariable prgloborig -width 16 -state readonly
		label $f.c.nl -text "New Value  "
		entry $f.c.nv -textvariable prglobnew -width 16
		button $f.c.set -text "Change to New Value" -command {set pr_prpglob 1}  -highlightbackground [option get . background {}]
		pack $f.c.ol $f.c.ov $f.c.nl $f.c.nv -side left
		pack $f.c.set -side left -padx 2
		pack $f.c -side top -fill x -expand true -pady 2
		set prgloblist [Scrolled_Listbox $f.d -width 32 -height 40 -selectmode single]
		pack $f.d -side top -fill both -expand true
		bind $prgloblist <ButtonRelease-1> {GetGlobPrval %y}
		wm resizable $f 1 1
		bind $f <Escape> {set pr_prpglob 0}
		bind $f <Return> {set pr_prpglob 2}
	}
	$prgloblist delete 0 end
	set prglobselect -1
	set pradglob 0
	set prgloborig ""
	set prglobnew ""
	ForceVal $f.c.ov $prgloborig
	set prglobfil ""
	set pr_prpglob 0
	set finished 0
	wm title $f "GLOBALLY CHANGE PROPERTY VALUES IN $fnam"
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_prpglob $f
	while {!$finished} {
		tkwait variable pr_prpglob
		switch -- $pr_prpglob {
			0 {
				break
			}
			1 {
				if {$pradglob <= 0} {
					Inf "No Property Selected"
					continue
				}
				if {[string length $prgloborig] <= 0} {
					Inf "No Original Property Value Chosen"
					continue
				}
				set prglobnew [string trim $prglobnew]
				if {[string length $prglobnew] <= 0} {
					Inf "No	New Property Value Entered"
					continue
				}
				set prglobnew [string tolower $prglobnew]
				set test [split $prglobnew]
				if {[llength $test] > 1} {
					Inf "Property Values Cannot Contain Spaces"
					continue
				}
				if {[regexp {[\,\£\$]} $prglobnew]} {
					Inf "Property Values Cannot Contain Commas, '$' Or '£' Signs"
					continue
				}
				set OK 1
				foreach val [$prgloblist get 0 end] {
					if {[string match $prglobnew $val]} {
						set msg "The Value '$prglobnew' Is Already Being Used: Is This OK ??"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							set OK 0
							break
						}
					}
				}
				if {!$OK} {
					continue
				}
				set n 0
				foreach line $propvallines {
					set val [lindex $line $pradglob]
					if {[string match $val $prgloborig]} {
						set line [lreplace $line $pradglob $pradglob $prglobnew]
						set propvallines [lreplace $propvallines $n $n $line]
					}		
					incr n
				}
				set hasbeenset 1
				UpdateExplanationsFileForPropvalName [.prpglob.b.n$pradglob cget -text] $prgloborig $prglobnew
				Inf "'$prgloborig' Changed To '$prglobnew'"
				set prglobnew ""
				set prgloborig ""
				ForceVal $f.c.ov $prgloborig
				$prgloblist selection clear 0 end
				set prglobselect -1
				continue
			}
			2 {
				if {![info exists hasbeenset]} {
					Inf "No Changes Have Been Made"
					continue
				}
				if {![ValidCDPRootname $prglobfil]} {
					continue
				}
				set ext [GetTextfileExtension props]
				set zfnam $prglobfil$ext
				if {[file exists $zfnam]} {
					Inf "File $zfnam Already Exists: You Cannot Overwrite An Existing File Here"
					continue
				}
				if [catch {open $zfnam "w"} zit] {
					Inf "Cannot Open File $zfnam To Write New Data"
					continue
				}
				puts $zit $nameslist
				foreach line $propvallines {
					puts $zit $line
				}
				close $zit
				FileToWkspace $zfnam 0 0 0 0 1
				break
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

proc GetGlobPrval {y} {
	global prgloblist prgloborig prglobnew prglobselect
	set prglobselect [$prgloblist nearest $y]
	if {$prglobselect < 0} {
		return
	}
	set prgloborig [$prgloblist get $prglobselect]
	ForceVal .prpglob.c.ov $prgloborig
	set prglobnew ""
}

proc PropGlobList {} {
	global propval_vals pradglob prgloblist prgloborig prglobnew
	if {$pradglob <= 0} {
		return
	}
	$prgloblist delete 0 end
	foreach val $propval_vals($pradglob) {
		$prgloblist insert end $val
	}
	set prglobnew ""
	set prgloborig ""
	ForceVal .prpglob.c.ov $prgloborig
}

#----- Change the Property Name(s) in a Properties File,  CALLED FROM WORKSPACE

proc PropNamesChange {} {
	global pr_prnamch prnamch prnamchfil wstk evv
	set fnam [SelectedFileIsAPropertyFile 0 0]
	if {[string length $fnam] <= 0} {
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File $fnam"
		return
	}
	set n 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		set line [split $line]
		if {$n == 0} {
			catch {unset nameslist}
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] > 0} {
					lappend nameslist $item
				}
			}
			if {[info exists nameslist]} {
				incr n
			}
		} else {
			catch {unset nuline}
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] > 0} {
					lappend nuline $item
				}
			}
			if {[info exists nuline]} {
				lappend nulines $nuline
			}
		}
	}
	close $zit
	if {![info exists nameslist] || ![info exists nulines]} {
		Inf "No Significant Data Found In File $fnam"
		return
	}
	set namcnt [llength $nameslist]
	set f .prnamch
	if [Dlg_Create $f "CHANGE NAMES OF PROPERTIES" "set pr_prnamch 0" -borderwidth $evv(BBDR)] {
		frame $f.a -borderwidth $evv(BBDR)
		button $f.a.q -text "Abandon Changes" -command {set pr_prnamch 0} -highlightbackground [option get . background {}]
		button $f.a.k -text "Keep Changes" -command {set pr_prnamch 1} -highlightbackground [option get . background {}]
		label $f.a.ll -text "New propfile name  "
		entry $f.a.e -textvariable prnamchfil -width 16
		pack $f.a.k $f.a.ll $f.a.e -side left
		pack $f.a.q -side right
		pack $f.a -side top -fill x -expand true -pady 2
		frame $f.b -borderwidth $evv(BBDR)
		label $f.b.c -text "CURRENT NAMES"
		label $f.b.n -text "NEW NAMES"
		grid $f.b.c -row 0 -column 0
		grid $f.b.n -row 0 -column 1
		set n 1
		foreach name $nameslist {
			label $f.b.n$n -text $name
			grid $f.b.n$n -row $n -column 0
			entry $f.b.e$n -textvariable prnamch($n) -width 24
			grid $f.b.e$n -row $n -column 1
			set prnamch($n) ""
			incr n
		}
		pack $f.b -side top -fill x -expand true -pady 2
		wm resizable $f 1 1
		bind $f <Escape> {set pr_prnamch 0}
		bind $f <Return> {set pr_prnamch 1}
	}
	set prnamchfil ""
	set pr_prnamch 0
	set finished 0
	wm title $f "CHANGE NAMES OF PROPERTIES IN FILE $fnam"
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_prnamch $f
	while {!$finished} {
		set changed 0
		tkwait variable pr_prnamch
		if {$pr_prnamch} {
			if {![ValidCDPRootname $prnamchfil]} {
				continue
			}
			set ext [GetTextfileExtension props]
			set zfnam $prnamchfil$ext
			if {[file exists $zfnam]} {
				Inf "File $zfnam Already Exists: You Cannot Overwrite An Existing File Here"
				continue
			}
			catch {unset nunameslist}
			set n 1
			while {$n <= $namcnt} {
				set prnamch($n) [string trim $prnamch($n)]
				if {[string length $prnamch($n)] > 0} {
					set test [split $prnamch($n)]
					if {[llength $test] > 1} {
						Inf "Property Names ($prnamch($n)) Cannot Contain Spaces"
						continue
					}
					if {[regexp {[\,\£\$]} $prnamch($n)]} {
						Inf "Property Names ($prnamch($n)) Cannot Contain Commas '$' Or '£' Signs"
						continue
					}
					if {![string match $prnamch($n) [$f.b.n$n cget -text]]} {
						UpdateExplanationsFileForPropname [$f.b.n$n cget -text] $prnamch($n)
						set changed 1
					} else {
						set $prnamch($n) ""
					}
				}
				incr n
			}
			if {!$changed} {
				set msg "No Changes Have Been Made: Is This Correct ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "yes"} {
					break
				}
			}
			set n 1
			while {$n <= $namcnt} {
				if {[string length $prnamch($n)] <= 0} {
					lappend nunameslist [$f.b.n$n cget -text]
				} else {
					lappend nunameslist $prnamch($n)
				}
				incr n
			}
			if [catch {open $zfnam "w"} zit] {
				Inf Cannot Open File $zfnam To Write New Data"
				continue
			}
			puts $zit $nunameslist
			foreach line $nulines {
				puts $zit $line
			}
			close $zit
			FileToWkspace $zfnam 0 0 0 0 1
			break
		} else {
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

#-------- Sort lines referring to numerically indexed filenames in props file into numerical order

proc PropsNumericSort {} {
	global props_info wstk evv
	set sorted 0
	set fnam [SelectedFileIsAPropertyFile 0 0]
	if {[string length $fnam] <= 0} {
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File $fnam"
		return
	}
	Block "Numeric Sort"
	set nums {}
	set nameslist  [lindex $props_info 0]
	set props_list [lindex $props_info 1]
	set snamcnt 0
	foreach line $props_list {
		set item [lindex $line 0]
		set name_num [SplitNumericallyIndexedFilename $item 1]
		if {[llength $name_num] <= 0} {
			close $zit
			Inf "Not All Filenames Are Numerically Indexed"
			UnBlock
			return
		}				
		set name [lindex $name_num 0]
		if {$snamcnt == 0} {
			set basename $name
		} else {
			if {![info exists multiname] && ![string match $basename $name]} {
				set msg "Not All Filenames Have Same Basename: Continue With Sort Anyway ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					close $zit
					UnBlock
					return
				} else {
					set multiname 1
				}
			}
		}
		set this_num [lindex $name_num 1]
		if {![info exists multinum] && ([lsearch $nums $this_num] >= 0)} {
			set msg "Not All Files Have Different Numbers: Continue With Sort Anyway ??"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				close $zit
				UnBlock
				return
			} else {
				set multinum 1
			}
		}
		lappend nums $this_num
		incr snamcnt
	}
	close $zit
	set len $snamcnt 
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set num_n [lindex $nums $n]
		set m $n
		incr m
		while {$m < $len} {
			set num_m [lindex $nums $m]
			if {$num_m < $num_n} {
				set line_n [lindex $props_list $n]
				set line_m [lindex $props_list $m]
				set props_list [lreplace $props_list $n $n $line_m]
				set props_list [lreplace $props_list $m $m $line_n]
				set nums [lreplace $nums $n $n $num_m]
				set nums [lreplace $nums $m $m $num_n]
				set sorted 1
				set num_n $num_m
			}
			incr m
		}
		incr n
	}
	if {!$sorted} {
		UnBlock
		return
	}
	set tmpfnam $evv(DFLT_TMPFNAME)
	if [catch {open $tmpfnam "w"} zit] {
		Inf "Cannot Open Temporary File $tmpfnam To Write Reordered Data"
		UnBlock
		return
	}
	puts $zit $nameslist
	foreach line $props_list {
		puts $zit $line
	}
	close $zit
	if [catch {file delete $fnam} zit] {
		Inf "Cannot Delete Existing Properties File $fnam"	
		catch {file delete $tmpfnam}
		UnBlock
		return
	}
	if [catch {file rename $tmpfnam $fnam} zit] {
		UpdateBakupLog $fnam delete 1
		set msg "Cannot Rename New Explanations File $tmpfnam To $fnam\n\n"
		append msg "Do This, Outside The Soundloom, Before Closing This Dialogue Box"
		Inf $msg
		catch {file delete $tmpfnam}
	} else {
		UpdateBakupLog $fnam modify 1
	}
	UnBlock
}

#-------- Remove duplicate sounds in a propsfile

proc PropsDeleteDuplicates {} {
	global props_info evv
	set sorted 0
	set fnam [SelectedFileIsAPropertyFile 0 0]
	if {[string length $fnam] <= 0} {
		return
	}
	Block "Delete Duplicate Entries"

	set nameslist  [lindex $props_info 0]
	set props_list [lindex $props_info 1]
	set len [llength $props_list]
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set nam_n [lindex [lindex $props_list $n] 0]
		set m $n
		incr m
		while {$m < $len} {
			set nam_m [lindex [lindex $props_list $m] 0]
			if {[string match $nam_n $nam_m]} {
				set props_list [lreplace $props_list $m $m]
				set sorted 1
				incr len -1
				incr len_less_one -1
			} else {
				incr m
			}
		}
		incr n
	}
	if {!$sorted} {
		UnBlock
		return
	}
	set tmpfnam $evv(DFLT_TMPFNAME)
	if [catch {open $tmpfnam "w"} zit] {
		Inf "Cannot Open Temporary File '$tmpfnam' To Write Reordered Data"
		UnBlock
		return
	}
	puts $zit $nameslist
	foreach line $props_list {
		puts $zit $line
	}
	close $zit
	if [catch {file delete $fnam} zit] {
		Inf "Cannot Delete Existing Properties File '$fnam'"	
		catch {file delete $tmpfnam}
		UnBlock
		return
	}
	if [catch {file rename $tmpfnam $fnam} zit] {
		UpdateBakupLog $fnam delete 1
		set msg "Cannot Rename New Explanations File $tmpfnam To $fnam\n\n"
		append msg "Do This, Outside The Soundloom, Before Closing This Dialogue Box"
		Inf $msg
		catch {file delete $tmpfnam}
	} else {
		UpdateBakupLog $fnam modify 1
	}
	UnBlock
}

#---- Temporarily Bakup Properties File

proc TempBakupPropsfile {} {
	global wstk props_info evv
	set fnam [SelectedFileIsAPropertyFile 0 0]
	if {[string length $fnam] <= 0} {
		return
	}
	set propnames  [lindex $props_info 0]
	set props_list [lindex $props_info 1]
	set bakfile [file join $evv(URES_DIR) tempropbak$evv(TEXT_EXT)]
	if {[file exists $bakfile]} {
		set msg "A Temporary Backupfile Already Exists: This Will Be Overwritten If You Proceed.\n\nDo You Wish To Proceed ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		}
		if [catch {file delete $bakfile} zit] {
			Inf "Cannot Delete Existing Backup File $bakfile"	
			return
		}
	}
	Block "Backing Up"
	if [catch {open $bakfile "w"} zit] {
		Inf "Cannot Open Backup File $bakfile"	
		UnBlock 
		return
	}
	puts $zit $fnam
	puts $zit $propnames
	foreach line $props_list {
		puts $zit $line
	}
	close $zit
	UnBlock 
}

#---- Restore Propsfile From Temporary Bakup 

proc RestorePropsfileFromTempBakup {} {
	global wl ww total_wksp_cnt rememd wstk evv
	set bakfile [file join $evv(URES_DIR) tempropbak$evv(TEXT_EXT)]
	if {![file exists $bakfile]} {
		Inf "No Backup File $bakfile Exists"	
		return
	}
	Block "Restoring"
	if [catch {open $bakfile "r"} zit] {
		Inf "Cannot Open Backup File $bakfile"	
		UnBlock 
		return
	}
	while {[gets $zit line] >= 0} {
		lappend nulines $line
	}
	close $zit
	set fnam [lindex $nulines 0]
	set nulines [lrange $nulines 1 end]
	set dir [file dirname $fnam]
	if {![file exists $dir] || ![file isdirectory $dir]} {
		Inf "Directory $dir No Longer Exists : Create It First"	
		UnBlock 
		return
	}
	set file_existed 0
	if {[file exists $fnam]} {
		set msg "File To Restore ($fnam) Already Exists : Overwrite It ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			UnBlock 
			return
		} elseif [catch {file delete $fnam} zit] {
			Inf "Cannot Delete Existing File $file"
			UnBlock 
			return
		}
		UpdateBakupLog $fnam delete 1
		set file_existed 1	;#	BUT IS ABOUT TO BE RESTORED
	}
	if [catch {open $fnam "w"} zit] {
		Inf "Cannot Create File $fnam To Restore Data"
		if {$file_existed} {
			PropfileWkspaceRemove $fnam
		}
		UnBlock 
		return
	}
	foreach line $nulines {
		puts $zit $line
	}
	close $zit
	UpdateBakupLog $fnam create 1
	if {!$file_existed} {
		FileToWkspace $fnam 0 0 0 0 1
	}
	if [catch {file delete $bakfile} zit] {
		Inf "Cannot Delete The Temporary Backup File $bakfile"
	}
	UnBlock
}

#------ Remove a PROPERTY FILE FROM WORKSPACE

proc PropfileWkspaceRemove {fnam} {
	global wl total_wksp_cnt rememd ww
	if {[LstIndx $fnam $wl] >= 0} {
		PurgeArray $fnam
		RemoveFromChosenlist $fnam
		incr total_wksp_cnt -1
		$wl delete $i
		ForceVal $ww.1.a.endd.l.cnts.all $total_wksp_cnt
		catch {unset rememd}
	}
}

#---- Sort on numeric index of filenames

proc PrFilenameSort {} {
	global adp_propnames adp_props_list
	set snamcnt 0
	set sorted 0
	Block "Sorting"
	foreach line $adp_props_list {
		set item [lindex $line 0]
		set name_num [SplitNumericallyIndexedFilename $item 1]
		if {[llength $name_num] <= 0} {
			Inf "Not All Filenames Are Numerically Indexed"
			UnBlock
			return
		}				
		set name [lindex $name_num 0]
		if {$snamcnt == 0} {
			set basename $name
		} else {
			if {![string match $basename $name]} {
				Inf "Not All Filenames Have Same Basename"
				UnBlock
				return
			}
		}
		lappend nums [lindex $name_num 1]
		lappend nulines $line
		incr snamcnt
	}
	set len $snamcnt
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set num_n [lindex $nums $n]
		set m $n
		incr m
		while {$m < $len} {
			set num_m [lindex $nums $m]
			if {$num_n == $num_m} {
				Inf "Some Entries Use The Same Filename And Number : Sort This Out First"
				UnBlock
				return
			}
			if {$num_m < $num_n} {
				set line_n [lindex $nulines $n]
				set line_m [lindex $nulines $m]
				set nulines [lreplace $nulines $n $n $line_m]
				set nulines [lreplace $nulines $m $m $line_n]
				set nums [lreplace $nums $n $n $num_m]
				set nums [lreplace $nums $m $m $num_n]
				set sorted 1
				set num_n $num_m
			}
			incr m
		}
		incr n
	}
	if {!$sorted} {
		UnBlock
		return
	}
	set adp_props_list $nulines
	UnBlock
}

#------ Attempt to renumber several selected workspace files

proc GenericSubstituteWkspaceNumbersAndPropfileEntries {} {
	global wl pa background_listing props_info pr_snumprop genericnumloprp rememd ch chlist chcnt evv 

	set tmpfnam $evv(DFLT_TMPFNAME)

	ClearWkspaceSelectedFiles
	set ilist [$wl curselection]
	if {[llength $ilist] < 2} {							
		Inf "Insufficient Files Selected"
		return
	}
	set propfile_index -1
	foreach i $ilist {
		set fnam [$wl get $i]
		set ftyp $pa($fnam,$evv(FTYP))
		if {$ftyp == $evv(SNDFILE)} {
			lappend innames $fnam
		} else {
			if {$propfile_index >= 0} {
				Inf "Choose One Property File And One Or More Soundfiles"
				return
			} else {
				set propfile_index $i
			}
		}
	}
	if {$propfile_index < 0} {
		Inf "Choose One Property File And One Or More Soundfiles"
		return
	}
	set propfile [$wl get $propfile_index]
	
	set k [lsearch $ilist $propfile_index]
	set ilist [lreplace $ilist $k $k]

	$wl selection clear 0 end
	$wl selection set $propfile_index
	set pfnam [SelectedFileIsAPropertyFile 0 0]
	if {[string length $pfnam] <= 0} {
		foreach i $ilist {
			$wl selection set $i		
		}
		return
	}
	set propnames  [lindex $props_info 0]
	set props_list [lindex $props_info 1]
	foreach line $props_list {
		lappend sndnames [lindex $line 0]
	}

	;# CHECK FOR VALID (SET OF) SNDFILES

	set cnt 0
	set inpropfile 0
	foreach nam $innames {
		if {!$inpropfile} {
			if {[lsearch $sndnames $nam] >= 0} {
				set inpropfile 1
			}
		}
		set fnam [file rootname $nam]
		if {$cnt == 0} {
			set baseext [file extension $nam]
			set len [string length $fnam]
			incr len -1
			set strcnt 0
			while {$len >= 0} {
				set val [string index $fnam $len]
				if {![regexp {[0-9]} $val]} {
					break
				}
				incr strcnt
				incr len -1
			}
			if {$strcnt == 0} {
				Inf "File '$fnam' Is Not A File With Number At End."
				foreach i $ilist {
					$wl selection set $i		
				}
				return
			}
			set basefnam [string range $fnam 0 $len]
			set numstt $len
			incr numstt
		} else {
			if {[string first $basefnam $fnam] != 0} {
				Inf "Filename '$fnam' Does Not Start With '$basefnam'"
				foreach i $ilist {
					$wl selection set $i		
				}
				return
			}
			if {![regexp {^[0-9]+$} [string range $fnam $numstt end]]} {
				Inf "File '$fnam' Is Not An Already Numbered File"
				foreach i $ilist {
					$wl selection set $i		
				}
				return
			}
		}
		incr cnt
	}
	if {!$inpropfile} {
		Inf "None Of The Selected Soundfiles Are Referenced In The Properties File You Chose"	
		foreach i $ilist {
			$wl selection set $i		
		}
		return
	}
	set ren_blist 0

	set g .genericnumprp
	if [Dlg_Create $g "RENUMBER FILES IN PROPERTY FILE" "set pr_snumprop 0" -borderwidth $evv(BBDR)] {
		set gn [frame $g.name -borderwidth $evv(SBDR)]
		button $gn.b -text Close -width 6 -command "set pr_snumprop 0" -highlightbackground [option get . background {}]
		label $gn.l1 -text "Renumber FROM  "
		entry $gn.e1 -width 4 -textvariable genericnumloprp
		button $gn.ok -text OK -width 6 -command "set pr_snumprop 1" -highlightbackground [option get . background {}]
		pack $gn.ok $gn.l1 $gn.e1 -side left
		pack $gn.b -side right
		pack $g.name -side top
		pack $gn -side top -pady 2
		wm resizable $g 1 1
		bind .genericnumprp <Up> "incr genericnumloprp"
		bind .genericnumprp <Down> DecrGenericnumloprp
		bind $g <Escape> {set pr_snumprop 0}
		bind $g <Return> {set pr_snumprop 1}
	}
	set genericnumloprp 0
	set finished 0
	set pr_snumprop 0
	raise $g
	My_Grab 0 $g pr_snumprop $g.name.e1
	set save_mixmanage 0
	while {!$finished} {
		tkwait variable pr_snumprop
		if {!$pr_snumprop} {				  						
			foreach i $ilist {
				$wl selection set $i		
			}
			My_Release_to_Dialog $g
			Dlg_Dismiss $g
			return
		} else {				  					;#	If a generic name has been entered
			if {[string length $genericnumloprp] <= 0} {
				Inf "No start number has been entered"
				continue
			}
			if {![regexp {^[0-9]+$} $genericnumloprp]} {
				Inf "Invalid start number entered"
				continue
			}
			set genericnumloprp [StripLeadingZerosFromInteger $genericnumloprp]
			set j $genericnumloprp
			foreach i $ilist {
				lappend notyetdone $i $j
				incr j
			}
			foreach {k j} $notyetdone {
				set nuname $basefnam
				append nuname $j $baseext
				if {[file exists $nuname]} {
					Inf "A File With The Name '$nuname' Already Exists"
					foreach i $ilist {
						$wl selection set $i		
					}
					My_Release_to_Dialog $g
					Dlg_Dismiss $g
					return
				}
			}
			Block "Renumbering"
			foreach {i j} $notyetdone {
				set nuname $basefnam
				append nuname $j $baseext
				set origfnam [$wl get $i]
				set haspmark [HasPmark $origfnam]
				set hasmmark [HasMmark $origfnam]
				if [catch {file rename $origfnam $nuname} zub] {
					Inf "Cannot Rename File\n$origfnam\nTo\n$nuname"
					continue
				}
				DataManage rename $origfnam $nuname
				lappend couettelist $origfnam $nuname
				UpdateBakupLog $origfnam delete 0
				UpdateBakupLog $nuname create 1
				$wl delete $i								
				$wl insert $i $nuname
				catch {unset rememd}
				UpdateChosenFileMemory $origfnam $nuname
				set oldname_pos_on_chosen [LstIndx $origfnam $ch]
				if {$oldname_pos_on_chosen >= 0} {
					RemoveFromChosenlist $origfnam
					set chlist [linsert $chlist $oldname_pos_on_chosen $nuname]
					incr chcnt
					$ch insert $oldname_pos_on_chosen $nuname
				}
				RenameProps	$origfnam $nuname 1				
				DummyHistory $origfnam "RENAMED_$nuname"
				if {[MixMRename $origfnam $nuname 0]} {
					set save_mixmanage 1
				}
				if {$haspmark} {
					MovePmark $origfnam $nuname
				}
				if {$hasmmark} {
					MoveMmark $origfnam $nuname
				}
				if [IsInBlists $origfnam] {
					if [RenameInBlists $origfnam $nuname] {
						set ren_blist 1
					}
				}
				RenameOnDirlist $origfnam $nuname

				;# RENAME IN PROFILE

				set k [lsearch $sndnames $origfnam]
				if {$k >= 0} {
					set line [lindex $props_list $k]
					set line [lreplace $line 0 0 $nuname]
					set props_list [lreplace $props_list $k $k $line]
				}
			}
			if {[info exists couettelist]} {
				CouetteManage rename $couettelist
			}
			UnBlock
			break
		}
	}
	if {$save_mixmanage} {
		MixMStore
	}
	if {$ren_blist} {
		SaveBL $background_listing
	}
	if [catch {open $tmpfnam "w"} zit] {
		Inf "Cannot Open Temporary File $tmpfnam To Write Reordered Data"
		UnBlock
		return
	}
	Block "Writing New Properties File"
	puts $zit $propnames
	foreach line $props_list {
		puts $zit $line
	}
	close $zit
	if [catch {file delete $pfnam} zit] {
		Inf "Cannot Delete Existing Properties File $fnam"	
		catch {file delete $tmpfnam}
		UnBlock
		return
	}
	if [catch {file rename $tmpfnam $pfnam} zit] {
		UpdateBakupLog $pfnam delete 1
		set msg "Cannot Rename New Explanations File $tmpfnam To $fnam\n\n"
		append msg "Do This, Outside The Soundloom, Before Closing This Dialogue Box"
		Inf $msg
		catch {file delete $tmpfnam}
	} else {
		UpdateBakupLog $pfnam modify 1
	}
	UnBlock
	My_Release_to_Dialog $g
	Dlg_Dismiss $g
}

#--- Decrement Renumbering-value for file renumbering in Prop File

proc DecrGenericnumloprp {} {
	global genericnumlo 
	set val [expr $genericnumloprp - 1]
	if {$val >= 0} {
		set genericnumloprp $val
	}
}

#-------- Put property Columns into New order

proc PropsPropnameSort {} {
	global pr_prprs prprto prprfrom props_info evv
	set fnam [SelectedFileIsAPropertyFile 0 0]
	if {[string length $fnam] <= 0} {
		return
	}
	set propnames  [lindex $props_info 0]
	set props_list [lindex $props_info 1]
	set propnames_plus_one 0
	set propnames_plus_one [concat $propnames_plus_one $propnames]
	set f .prprs
	if [Dlg_Create $f "REORDER PROPERTY COLUMNS" "set pr_prprs 0" -borderwidth $evv(BBDR)] {
		frame $f.a -borderwidth $evv(BBDR)
		frame $f.b -borderwidth $evv(BBDR)
		button $f.a.q -text "Abandon" -command {set pr_prprs 0} -width 16 -highlightbackground [option get . background {}]
		button $f.a.r -text "Reorder" -command {set pr_prprs 1} -width 16 -highlightbackground [option get . background {}]
		pack $f.a.r -side left -padx 2
		pack $f.a.q -side right
		pack $f.a -side top -fill x -expand true -pady 2
		label $f.aa -text "SPECIFY WHICH PROPERTY TO MOVE (\"FROM\") AND WHICH POSITION TO MOVE IT \"TO\"" -fg $evv(SPECIAL)
		pack $f.aa -side top -pady 2
		label $f.b.fr -text FROM
		label $f.b.to -text TO
		grid $f.b.fr -row 0 -column 0
		grid $f.b.to -row 0 -column 2
		set n 1
		foreach nam $propnames {
			radiobutton $f.b.fr$n -variable prprfrom -value $n
			label $f.b.ll$n -text $nam
			radiobutton $f.b.to$n   -variable prprto -value $n
			grid $f.b.fr$n -row $n -column 0
			grid $f.b.ll$n -row $n -column 1
			grid $f.b.to$n -row $n -column 2
			incr n
		}
		pack $f.b -side top -fill x -expand true -pady 2
		wm resizable $f 1 1
		bind $f <Return> {set pr_prprs 1}
		bind $f <Escape> {set pr_prprs 0}
	}
	set prprto 0
	set prprfrom 0
	set pr_prprs 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_prprs $f
	while {!$finished} {
		tkwait variable pr_prprs
		if {$pr_prprs} {
			if {($prprfrom <= 0) || ($prprto <= 0) || ($prprfrom == $prprto)} {
				Inf "\"FROM\" And \"TO\" Must Both Be Set, And Must Be Different"
				continue
			}
			if {$prprfrom < $prprto} {
				incr prprto -1
			}
			set gotname [lindex $propnames_plus_one $prprfrom]

			set propnames_plus_one [lreplace $propnames_plus_one $prprfrom $prprfrom]
			set propnames_plus_one [linsert $propnames_plus_one $prprto $gotname]
			set propnames [lrange $propnames_plus_one 1 end]
			foreach line $props_list {
				set gotval [lindex $line $prprfrom]
				set line [lreplace $line $prprfrom $prprfrom]
				set line [linsert $line $prprto $gotval]
				lappend nulines $line
			}
			set props_list $nulines
			set tmpfnam $evv(DFLT_TMPFNAME)
			if [catch {open $tmpfnam "w"} zit] {
				Inf "Cannot Open Temporary File $tmpfnam To Write Reordered Data"
				continue
			}
			puts $zit $propnames
			foreach line $props_list {
				puts $zit $line
			}
			close $zit
			if [catch {file delete $fnam} zit] {
				Inf "Cannot Delete Existing Properties File $fnam"	
				catch {file delete $tmpfnam}
				break
			}
			if [catch {file rename $tmpfnam $fnam} zit] {
				UpdateBakupLog $fnam delete 1
				set msg "Cannot Rename New Explanations File $tmpfnam To $fnam\n\n"
				append msg "Do This, Outside The Soundloom, Before Closing This Dialogue Box"
				Inf $msg
				catch {file delete $tmpfnam}
			} else {
				UpdateBakupLog $fnam modify 1
			}
		}
		break
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

#---- Removing snds from propsfile

proc RemoveSndsFromPropfile {} {
	global wl chlist props_info old_props_protocol wstk pa evv

	Block "Checking File Consistency"
	if {[info exists chlist]} {
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
		}
	}
	set ilist [$wl curselection]
	if {([string length $ilist] <= 0) || ($ilist == -1)} {
		Inf "No File Selected"
		UnBlock
		return
	}
	set got_propsfile 0
	if {[llength $ilist] < 2} {
		Inf "Choose A Property File & At Least One Soundfile Mentioned In The Props-File"
		UnBlock
		return
	}
	foreach i $ilist {
		set fnam [$wl get $i]
		if {$pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)} {
			if {$got_propsfile} {
				Inf "Choose Only One Property File & Soundfiles Mentioned In The Props-File, Only"
				UnBlock
				return
			}
			set fnam [SelectedFileIsAPropertyFile 1 $i]
			if {[string length $fnam] <= 0} {
				Inf "Choose Only One Property File & Soundfiles Mentioned In The Props-File, Only"
				UnBlock
				return
			}
			set propnames  [lindex $props_info 0]
			set props_list [lindex $props_info 1]
			set got_propsfile 1
			set pfnam $fnam
		} elseif {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
			Inf "Choose A Property File & Soundfile(s) Mentioned In That Props-File"
			UnBlock
			return
		} else {
			if {$old_props_protocol} {
				if {$got_sounddir} {
					if {![string match [file dirname $fnam] $filedir]} {
						Inf "Soundfiles Chosen Are Not All In The Same Directory"
						UnBlock
						return
					}
				} else {
					set filedir [file dirname $fnam]
					set got_sounddir 1
				}
			} else {
				if {[string match [file tail $fnam] $fnam]} {
					Inf "Soundfile $fnam Is Not Backed Up To A Directory"
					UnBlock
					return
				}
			}
			lappend in_sndfiles $fnam
		}
	}
	UnBlock
	set msg "ARE YOU SURE YOU WANT TO REMOVE THESE SOUNDFILES FROM THE PROPERTIES FILE $pfnam ?"
	set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
	if {$choice == "no"} {
		return
	}
	lappend nupropfile $propnames
	set incnt 0
	set outcnt 0
	foreach line $props_list {
		incr incnt
		set snd [lindex $line 0]
		if {[lsearch $in_sndfiles $snd] < 0} {
			lappend nupropfile $line
			incr outcnt
		}
	}
	if {$incnt == $outcnt} {
		Inf "None Of These Sounds Is Mentioned In The Properties File."
		return
	}
	if {[llength $nupropfile] <= 1} {
		set msg "Deleting All These Files Would Leave No Data In The Properties File.\n\n"
		append msg "To Retain The Props File For Further Work, You Must Leave At Least One File In It.\n\n"
		append msg "However, If You Do Not Need This Props File Again, Just Delete It.\n"
		Inf $msg
		return
	}
	set tmpfnam $evv(DFLT_TMPFNAME)
	if [catch {open $tmpfnam "w"} zit] {
		Inf "Cannot Open Temporary File $tmpfnam To Write Reordered Data"
		continue
	}
	foreach line $nupropfile {
		puts $zit $line
	}
	close $zit
	if [catch {file delete $pfnam} zit] {
		Inf "Cannot Delete Existing Properties File $pfnam"	
		catch {file delete $tmpfnam}
		break
	}
	if [catch {file rename $tmpfnam $pfnam} zit] {
		UpdateBakupLog $pfnam delete 1
		set msg "Cannot Rename New Explanations File $tmpfnam To $pfnam\n\n"
		append msg "Do This, Outside The Soundloom, Before Closing This Dialogue Box"
		Inf $msg
		catch {file delete $tmpfnam}
	} else {
		UpdateBakupLog $pfnam modify 1
	}
	Inf "FILES REMOVED"
}	

#------ Strip inderscores from text

proc PropsStripUnderscores {str} {
	global evv
	set outstr ""
	set len [string length $str]
	set n 0
	while {$n < $len} {
		set char [string index $str $n]
		if {$char == $evv(TEXTJOIN)} {
			set char " "
		}
		append outstr $char
		incr n
	}
	return "$outstr"
}

#------ Find Underscores

proc PropsFindUnderscores {str} {
	global evv
	set len [string length $str]
	set n 0
	while {$n < $len} {
		set char [string index $str $n]
		if {$char == $evv(TEXTJOIN)} {
			return 1
		}
		incr n
	}
	return 0
}

#---- Overwrite existing propsfile

proc OverwritePropsfile {pfile src} {
	global evv adp_propnames adp_props_list propfiles_list wl total_wksp_cnt rememd
	global tp_propnames tp_props_list readin_props readin_propfile 

	set tempfnam $evv(DFLT_OUTNAME)$evv(TEXT_EXT)
	if [catch {open $tempfnam "w"} zit] {
		Inf "Cannot Open Temporary File 'tempfnam' To Write Updated Properties Information"
		return 0
	}
	switch -- $src {
		"adp" {
			set theseprops [join $adp_propnames]
			set props_list $adp_props_list
		}
		"tp" {
			set theseprops [join $tp_propnames]
			set props_list $tp_props_list
		} 
		"readin" {
			set theseprops [join $readin_props]
			set props_list $readin_propfile
		}
	}
	puts $zit $theseprops
	foreach line $props_list {
		puts $zit $line
	}
	close $zit
	if [catch {file delete $pfile} zit] {
		Inf "Cannot Delete Original Properties File"
		return 0
	}
	set k [lsearch -exact $propfiles_list $pfile]
	if {$k >= 0} {
		set propfiles_list [lreplace $propfiles_list $k $k]
	}
	set i [LstIndx $pfile $wl]
	if {$i >= 0} {
		PurgeArray $pfile
		RemoveFromChosenlist $pfile
		incr total_wksp_cnt -1
		$wl delete $i
		catch {unset rememd}
	}
	if [catch {file rename $tempfnam $pfile} zit] {
		set msg "Cannot Rename File '$tempfnam' To '$pfile'.\n\n"
		append msg "You Must Rename File '$tempfnam' To $ofnam Now, Outside The Soundloom, Before Proceeding.\n"
		append msg "\nIf You Do Not, You Will Lose All the Property Data"
		Inf $msg
		set msg "Renamed File Outside The Loom ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			lappend propfiles_list $pfile
			FileToWkspace $pfile 0 0 0 0 1
			UpdateBakupLog $pfile modify 1
			return 1
		} else {
			UpdateBakupLog $pfile delete 1
			return 0
		}
	}
	lappend propfiles_list $pfile
	UpdateBakupLog $pfile modify 1
	FileToWkspace $pfile 0 0 0 0 1
	return 1
}

#----- Shuffle properties down, when sounds are renumbered (i.e. new sounds get interpolated in numbered files)!!

proc PropfilePush {} {
	global pr_phfpush phfpushstart phfpushmove phfpushfnam propfiles_list wstk wl props_info rememd evv 

	set fnam [SelectedFileIsAPropertyFile 0 0]
	set propnames  [lindex $props_info 0]
	set props_list [lindex $props_info 1]
	foreach line $props_list {
		lappend sndnames [lindex $line 0]
	}
	set prpcnt [llength [lindex $props_list 0]]
	incr prpcnt -1
	set k 0 
	while {$k < $prpcnt} {
		lappend nulprp "-"
		incr k
	}
	set len [llength $sndnames]
	set len_less_one [expr $len - 1]
	if [catch {eval {toplevel .phfpush} -borderwidth $evv(BBDR)} zorg] {
		ErrShow "Failed To Establish Push Properties Window"
		return ""
	}
	set f .phfpush
	wm protocol $f WM_DELETE_WINDOW "set pr_phfpush 0"
	wm title $f "PUSH PROPERTIES DOWN IN FILE [file rootname [file tail $fnam]]"
	set pr_phfpush 0
	frame $f.0
	frame $f.1
	frame $f.2
	button $f.0.0 -text "Push" -command "set pr_phfpush 1" -highlightbackground [option get . background {}]
	button $f.0.1 -text "Abandon" -command "set pr_phfpush 0" -highlightbackground [option get . background {}]
	pack $f.0.0 -side left
	pack $f.0.1 -side right
	pack $f.0 -side top -fill x -expand true
	label $f.1.ll -text "Push From entry (count starts at zero) "
	entry $f.1.e -textvariable phfpushstart -width 4
	label $f.1.ll2 -text "By "
	entry $f.1.e2 -textvariable phfpushmove -width 4
	label $f.1.ll3 -text " Places"
	pack $f.1.ll $f.1.e $f.1.ll2 $f.1.e2 $f.1.ll3 -side left
	pack $f.1 -side top
	label $f.2.ll -text "Output Filename "
	entry $f.2.e -textvariable phfpushfnam -width 16
	pack $f.2.ll $f.2.e -side left
	pack $f.2 -side top
	wm resizable $f 1 1
	set phfpushfnam ""
	set phfpushstart ""
	set phfpushmove ""
	set pr_phfpush 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_phfpush $f.1.e
	while {!$finished} {
		tkwait variable pr_phfpush
		if {$pr_phfpush} {
			if {[string length $phfpushfnam] <= 0} {
				Inf "No Output Filename Entered"
				continue
			}
			if {![ValidCDPRootname $phfpushfnam]} {
				continue
			}
			set outfnam [string tolower $phfpushfnam]
			append outfnam [GetTextfileExtension props]
			if {[string match $fnam $outfnam]} {
				Inf "You Cannot Overwrite The Input Property File"	
				continue
			}
			if {[file exists $outfnam]} {
				set msg "File '$outfnam' Already Exists: Overwrite It ?"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				set i [LstIndx $outfnam $wl]
				if {![DeleteFileFromSystem $outfnam 0 1]} {
					Inf "Cannot Delete Existing File '$outfnam'"
					continue
				} else {
					DummyHistory $outfnam "DESTROYED"
					if {[info exists propfiles_list]} {
						set k [lsearch $propfiles_list $outfnam]
						if {$k > 0} {
							set propfiles_list [lreplace $propfiles_list $k $k]
						}
					}
					if {$i >= 0} {
						WkspCnt [$wl get $i] -1
						$wl delete $i
						catch {unset rememd}
					}
				}
			}
			if {![regexp {^[0-9]+$} $phfpushstart] || ($phfpushstart > $len_less_one)} {
				Inf "Invalid Push Value (0 - $len_less_one)"
				continue
			}
			if {![regexp {^[0-9]+$} $phfpushmove] || ($phfpushmove == 0)} {
				Inf "Invalid Push Value"
				continue
			}
			catch {unset nu_props_list}
			set n $len_less_one
			set m [expr $n - $phfpushmove]
			while {$m >= $phfpushstart} {
				set snd [lindex $sndnames $n]
				set prps [lrange [lindex $props_list $m] 1 end]
				set line [concat $snd $prps]
				lappend nu_props_list $line
				incr m -1
				incr n -1
			}
			while {$n >= $phfpushstart} {
				set snd [lindex $sndnames $n]
				set line [concat $snd $nulprp]
				lappend nu_props_list $line
				incr n -1
			}
			while {$n >= 0} {
				lappend nu_props_list [lindex $props_list $n]
				incr n -1
			}
			set nu_props_list [ReverseList $nu_props_list]
			if [catch {open $outfnam "w"} zit] {
				Inf "Cannot Open '$outfnam' To Write Reordered Data"
				continue
			}
			puts $zit $propnames
			foreach line $nu_props_list {
				puts $zit $line
			}
			close $zit
			lappend propfiles_list $outfnam
			FileToWkspace $outfnam 0 0 0 0 1
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

#------ Estimate MM of source by putting marks on 'beats' in graphic-display of sound

proc Props_GetMM {} {
	global snack_list nuaddpsnd nuaddpval pa evv
	global sn_windows sn_edit sn_mlen sn_nyquist

	set fnam $nuaddpsnd
	if {![info exists pa($fnam,$evv(SRATE))]} {
		Inf "File '$fnam' Is Not On The Workspace"
		return
	}
	set insams $pa($fnam,$evv(INSAMS))
	set dur    $pa($fnam,$evv(DUR))
	set chans  $pa($fnam,$evv(CHANS))
	set srate  $pa($fnam,$evv(SRATE))
	set invsrate  [expr 1.0 / $srate]
	set sn_windows 0
	set sn_edit 0
	set sn_mlen 1024
	set sn_nyquist 22100
	set snfnam [file join $evv(CDPRESOURCE_DIR) soundview]

	SnackCreate $evv(TIME_OUT) $evv(SN_TIMESLIST) $fnam $insams $srate $chans $snfnam 1 0 $dur 0

	if {![info exists snack_list]} {
		return
	}
	if {[string match [lindex $snack_list 0] "CLEAR"]} {
		set snack_list [lrange $snack_list 1 end]
	}
	if {[llength $snack_list] <= 0} {
		return
	}
	set starttime [lindex $snack_list 0]
	set endtime	  [lindex $snack_list end]
	set dur [expr $endtime - $starttime]
	set beats [llength $snack_list]
	incr beats -1
	set beattime [expr $dur / double($beats)]
	set nuaddpval [expr int(round(60.0 / $beattime))]
}

################################################
# WORK WITH PROPERTIES FILE AS A TABLE DISPLAY #
################################################

#--------- Display Propslisting as table

proc TabProps {ask} {
	global tp_propnames tp_props_list tp_canlen tp_boxwid tp_canwid tp_canwidpix tp_canlenpix tp_can tp_bfw evv
	global pr_proptab tp_props_cnt tp_zlen props_info tp_rhy tp_rhy2 props_paste phf wstk saved_props proplocn 
	global proptxtsrch textprops lasproptxtfind hastextprop lastproptxtsrch origproptxtsfind origproptxtsrch
	global getsndprpn getsndprpv getsndprpc propnsel hasmotifprop hasHFprop blok_propexplan prexpldir
	global wl chlist ch chcnt proplastsnd proplastplay prop_reserved_names hasMMprop hasoffsetprop rcodeat
	global small_screen proptab_f pt_radio

	set prop_reserved_names [list ideas text rmotif HF offset rcode]

	Block "Checking Properties File"
	catch {unset proplastsnd}
	set blok_propexplan 0
	catch {unset saved_props}
	catch {unset lastproptxtsrch}
	catch {unset origproptxtsfind}
	catch {unset origproptxtsrch}
	set propnsel 0
	set getsndprpc 0
	set tphilitestate 0
	set fnam [SelectedFileIsAPropertyFile 0 0]
	if {[string length $fnam] <= 0} {
		UnBlock
		return
	}
	set tp_propnames [lindex $props_info 0]
	set tp_props_list [lindex $props_info 1]
	set tp_props_cnt [llength $tp_propnames]
	set area [expr ($tp_props_cnt + 1) * [llength $tp_props_list]]
	if {$area > 9000} {
		set msg "The Property File Is Possibly Too Large To Display (Displaying It May Cause A Crash): Continue ??"
		set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			UnBlock
			return
		}
	}
	incr tp_props_cnt
	foreach line $tp_props_list {
		set snd [lindex $line 0]
		if {[LstIndx $snd $wl] < 0} {
			lappend grabsnds $snd
		}
	}
	if {[info exists grabsnds]} {
		set msg "Some Sounds In This Properties-File Are Not On The Workspace: Grab Them ??"
		set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			foreach snd $grabsnds {
				wm title .blocker "PLEASE WAIT :      GRABBING FILE [file rootname [file tail $snd]]"
				catch {FileToWkspace $snd 0 0 0 1 0}
			}
		}
	}
	wm title .blocker "PLEASE WAIT :      BUILDING PROPERTIES FILE DISPLAY"
	set prexpldir [file dirname [lindex [lindex $tp_props_list 0] 0]]	;#	DIRECTORY OF SNDS IN PROPFILE: HENCE LOCATION FOR 'EXPLANATION' FILE
	set tp_canlen [llength $tp_props_list]
	set tp_zlen $tp_canlen
	incr tp_zlen
	set tp_zlen [expr $tp_zlen * 2]	;# SAFETY
	set tp_boxwid(0) 0
	set cnt 1
	set rcodeat 0
	set motifat 0
	catch {unset hastextprop}
	catch {unset hasmotifprop}
	catch {unset hasHFprop}
	catch {unset textprops}
	foreach nm $tp_propnames {
		if {[string match -nocase $nm "rcode"]} {
			set rcodeat $cnt
		} elseif {[string match -nocase $nm "motif"]} {
			set motifat $cnt
			set hasmotifprop $cnt
		} elseif {[string match -nocase $nm "HF"]} {
			set hasHFprop $cnt
		} elseif {[string match -nocase $nm "MM"]} {
			set hasMMprop $cnt
		} elseif {[string match -nocase $nm "offset"]} {
			set hasoffsetprop $cnt
		} elseif {[string match -nocase $nm "text"]} {
			set hastextprop $cnt
			foreach line $tp_props_list {
				lappend textprops [PropsStripUnderscores [lindex $line $hastextprop]]
			}
			set lasproptxtfind [list 0 0]
		}
		set tp_boxwid($cnt) [string length $nm]
		incr cnt
	}
	set shorten 1
	if {$ask} {
		set msg "Use Filenames Without Directory Paths ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			set shorten 0
		}
	}
	foreach line $tp_props_list {
		set snd [lindex $line 0]
		if {$shorten} {
			set snd [file rootname [file tail $snd]]
		}
		set len [string length $snd]
		if {$len > $tp_boxwid(0)} {
			set tp_boxwid(0) $len
		}
		set cnt 1
		foreach prp [lrange $line 1 end] {
			if {($cnt == $rcodeat) || ($cnt == $motifat)} {
				if {[string length "yes"] > $tp_boxwid($cnt)} {
					set tp_boxwid($cnt) [string length "yes"]
				}
			} else {
				set len [string length $prp]
				if {$len > $tp_boxwid($cnt)} {
					set tp_boxwid($cnt) $len
				}
			}
			incr cnt
		}
	}
	set cnt 0
	set propnamax 0
	foreach name $tp_propnames {
		set len [string length $name]
		if {$len > $propnamax} {
			set propnamax $len
		}
	}
	set m 0
	set n 1
	set propvamax 0
	while {$n < $tp_props_cnt} {
		set nam [lindex $tp_propnames $m]
		if {![string match -nocase $nam "text"] && ($n != $rcodeat) && ($n != $motifat)} {
			set len $tp_boxwid($n) 
			if {$len > $propvamax} {
				set propvamax $len
			}
		}
		incr n
		incr m
	}
	set n 0
	set tp_canwid 0
	while {$n < $tp_props_cnt} {
		set tp_canwid [expr $tp_canwid + $tp_boxwid($n) + 2]
		incr n
	}
	set tp_canwidpix [ConvertFontHorizToPixels $tp_canwid]
	set tp_canlenpix [ConvertFontVertToPixels $tp_zlen]
	catch {unset props_paste}
	set phf(play) 0
	set phf(flats) 0
	UnBlock
	DoChoiceBak
	if [info exists chlist] {
		set origchlist $chlist
		catch {unset chlist}
		$ch delete 0 end
		set chcnt 0
	}
	if [Dlg_Create .proptab "PROPERTIES TABLE" "set pr_proptab 0" -borderwidth $evv(BBDR)] {

		if {$small_screen} {
			set can [Scrolled_Canvas .proptab.c -width $evv(SMALL_WIDTH) -height $evv(SMALL_HEIGHT) \
								-scrollregion "0 0 1300 660"]
			pack .proptab.c -side top -fill x -expand true
			set f [frame $can.f -bd 0]
			$can create window 0 0 -anchor nw -window $f
			set proptab_f $f
		} else {
			set proptab_f .proptab
		}
		set f $proptab_f

		frame $f.ok
		button $f.ok.ok -text Quit -command "set pr_proptab 0" -highlightbackground [option get . background {}]
		button $f.ok.kp -text Snd->Chosen -command "set pr_proptab 1" -highlightbackground [option get . background {}]
		button $f.ok.info -text Help -command "PropTabInfo" -bg $evv(HELP) -highlightbackground [option get . background {}]
		frame $f.ok.00 -width 1 -bg $evv(POINT)
		menubutton $f.ok.a -text "A" -menu $f.ok.a.menu -relief raised -bd 4 -width 2 -background $evv(HELP)
		set pchmenu [menu $f.ok.a.menu -tearoff 0]
		$pchmenu add command -label "C"  -command "PlaySndfile $evv(TESTFILE_C)  0" -background white -foreground black
		$pchmenu add separator
		$pchmenu add command -label "C#" -command "PlaySndfile $evv(TESTFILE_Db) 0" -background black -foreground white
		$pchmenu add separator
		$pchmenu add command -label "D"  -command "PlaySndfile $evv(TESTFILE_D)  0" -background white -foreground black
		$pchmenu add separator
		$pchmenu add command -label "Eb" -command "PlaySndfile $evv(TESTFILE_Eb) 0" -background black -foreground white
		$pchmenu add separator
		$pchmenu add command -label "E"  -command "PlaySndfile $evv(TESTFILE_E)  0" -background white -foreground black
		$pchmenu add separator
		$pchmenu add command -label "F"  -command "PlaySndfile $evv(TESTFILE_F)  0" -background white -foreground black
		$pchmenu add separator
		$pchmenu add command -label "F#" -command "PlaySndfile $evv(TESTFILE_Gb) 0" -background black -foreground white
		$pchmenu add separator
		$pchmenu add command -label "G"  -command "PlaySndfile $evv(TESTFILE_G)  0" -background white -foreground black
		$pchmenu add separator
		$pchmenu add command -label "Ab" -command "PlaySndfile $evv(TESTFILE_Ab) 0" -background black -foreground white
		$pchmenu add separator
		$pchmenu add command -label "A"  -command "PlaySndfile $evv(TESTFILE_A)  0" -background white -foreground black
		$pchmenu add separator
		$pchmenu add command -label "Bb" -command "PlaySndfile $evv(TESTFILE_Bb) 0" -background black -foreground white
		$pchmenu add separator
		$pchmenu add command -label "B"  -command "PlaySndfile $evv(TESTFILE_B)  0" -background white -foreground black
		$pchmenu add separator
		$pchmenu add command -label "C"  -command "PlaySndfile $evv(TESTFILE_C2) 0" -background white -foreground black
		button $f.ok.exex -text Ex -command {set blok_propexplan 0} -relief raised -bd 4 -fg $evv(SPECIAL) -bg $evv(EMPH) -highlightbackground [option get . background {}]
		pack $f.ok.ok -side left -padx 2
		pack $f.ok.kp -side right -padx 2
# MOVED TO LEFT
#		pack $f.ok.ok $f.ok.kp -side right -padx 2
		menubutton $f.ok.k  -text "K" -bg $evv(HELP) -menu $f.ok.k.menu -relief raised
		set pmenu [menu $f.ok.k.menu -tearoff 0]
		$pmenu add command -label "Command-Click                  PLAY or VIEW prop" -command {}
		$pmenu add command -label "....on Propname         SEE vals in other propfiles" -command {}
		$pmenu add separator
		$pmenu add command -label "Shift-Command-Clk            Play+Src or Permanent View" -command {}
		$pmenu add separator
		$pmenu add command -label "Cntrl-Shft-Command-Clk   ENTER prop or change Name" -command {}
		$pmenu add separator
		$pmenu add command -label "Shift-Click                    Write Prop-Explanation" -command {}
		$pmenu add command -label "                                          or, for \"ideas\" prop (only)" -command {}
		$pmenu add command -label "                                          enter numbered \"idea\" in file" -command {}
		$pmenu add command -label "Control-Click                Read Prop-Explanation" -command {}
		$pmenu add command -label "                                          or, for \"ideas\" prop (only)" -command {}
		$pmenu add command -label "                                          read numbered \"idea\"" -command {}
		$pmenu add command -label "\"Ex\" Button             Use if Explanation-Entry blocked" -command {}
		$pmenu add separator
		$pmenu add command -label "Up/Down Arrows         Move to Top/Bottom of display" -command {}
		$pmenu add separator
		$pmenu add command -label "L/R Arrows                  Move to edge of display" -command {}
		$pmenu add separator
		$pmenu add command -label "Cntrl Up/Dn Arrows     Change Play <--> View mode" -command {}
		$pmenu add separator
		$pmenu add command -label "Cntrl L/R Arrows          Move along Props, to" -command {}
		$pmenu add command -label "                                    get sounds with prop X" -command {}	
		label $f.ok.ll -text "Val in Last Hilit Box (HB): "
		button $f.ok.valtoval -text " CPY to Nxt HB" -width 12 -command {set props_paste 3} -highlightbackground [option get . background {}]
		button $f.ok.valtosome -text "..UP to Nxt HB" -width 12 -command {set props_paste 5} -highlightbackground [option get . background {}]
		button $f.ok.valtoall -text "Cpy to ALL Snds" -width 13 -command "CopyOrPasteProps 0 0 $fnam" -highlightbackground [option get . background {}]
		button $f.ok.valmove -text " MOVE to Nxt HB" -width 13 -command {set props_paste 6} -highlightbackground [option get . background {}]
		frame $f.ok.01 -width 1 -bg $evv(POINT)
		label $f.ok.ll2 -text "Last hilit prop line: "
		button $f.ok.allprops -text  "To nxt hilited Snd" -width 14 -command {set props_paste 1} -highlightbackground [option get . background {}]
		frame $f.ok.02 -width 1 -bg $evv(POINT)
		pack $f.ok.info $f.ok.k $f.ok.exex $f.ok.a -side left -padx 2
		pack $f.ok.00 -side left -fill y -expand true -padx 2
		pack $f.ok.ll $f.ok.valtoval $f.ok.valtosome $f.ok.valtoall -side left
		pack $f.ok.valmove -side left -padx 2
		pack $f.ok.01 -side left -fill y -expand true -padx 2
		pack $f.ok.ll2 $f.ok.allprops -side left -padx 2
		pack $f.ok.02 -side left -fill y -expand true -padx 2
		label $f.ok.hff -text ""
		button $f.ok.hfplay -text  "" -width 12 -bd 0 -command {} -highlightbackground [option get . background {}]
		frame $f.ok.03 -width 1 -bg $evv(POINT)
		pack $f.ok.hff $f.ok.hfplay -side left -padx 2
		pack $f.ok.03 -side left -fill y -expand true -padx 2
		pack $f.ok -side top -pady 2 -fill x -expand true
		frame $f.line -bg black -height 1
		pack $f.line -side top -fill x -expand true -pady 4

		frame $f.radio
		frame $f.radio.left
		frame $f.radio.left.0
		label $f.radio.left.0.ll -text "Sound cnt "
		label $f.radio.left.0.cnt -text "[llength $tp_props_list]" -bg $evv(EMPH) -fg $evv(SPECIAL)
		pack $f.radio.left.0.ll $f.radio.left.0.cnt -side left
		frame $f.radio.left.1
		radiobutton $f.radio.left.1.p -text play -command "PropTabPlayView 0" -variable pt_radio -value 0
		radiobutton $f.radio.left.1.v -text view -command "PropTabPlayView 1" -variable pt_radio -value 1
		set pt_radio 1
		pack $f.radio.left.1.p $f.radio.left.1.v -side left -anchor w
		pack $f.radio.left.0 $f.radio.left.1 -side top -pady 2
		pack $f.radio.left -side left
		label $f.radio.what -text "" -width 32 -fg $evv(SPECIAL)
		pack $f.radio.what -side left -padx 2
		frame $f.radio.zum -bg black -width 1 
		pack $f.radio.zum -side left -fill y -expand true
		frame $f.radio.dum
		button $f.radio.dum.r -text "Remember Sound" -width 14 -command PropTabRemem -fg $evv(SPECIAL) -highlightbackground [option get . background {}]
		button $f.radio.dum.t -text "Save or Forget" -width 14 -command PropTabRememStore -highlightbackground [option get . background {}]
		pack $f.radio.dum.r $f.radio.dum.t -side top -pady 1
		pack $f.radio.dum -side left -padx 2
		if {[info exists hastextprop] || [info exists hasmotifprop] || [info exists hasHFprop]} {
			frame $f.radio.tt
			menubutton $f.radio.tt.ss -text "STATISTICS" -menu $f.radio.tt.ss.menu -relief raised -width 10 -fg $evv(SPECIAL)
			set stst [menu $f.radio.tt.ss.menu -tearoff 0]
			if {[info exists hastextprop]} {
				$stst add cascade -label "TEXT" -menu $stst.txt
				set ststxt [menu $stst.txt -tearoff 0]
				$ststxt add command -label "Words And Phrases" -command "AnalyseTextPropertyWordData $fnam"
				$ststxt add command -label "Consonant Concentrations" -command "TextPropertyConsonantStatistics $fnam"
				$ststxt add command -label "Rhymes" -command "TextPropRhyme 0 $fnam"
				$ststxt add command -label "See Assigned Rhymes" -command "CheckForNewRhymes $fnam"
				$ststxt add command -label "Word Starts" -command "TextPropRhyme 1 $fnam"
			}
			if {[info exists hasHFprop]} {
				$stst add cascade -label "HF" -menu $stst.hf
				set ststhf [menu $stst.hf -tearoff 0]
				$ststhf add command -label "Hf Statistics" -command "HFStats 0"
				$ststhf add command -label "Refresh Hf Statistics" -command "HFStats 1"
				$ststhf add command -label "Use Motifs To Locate Sub-HFs Within Snds" -command "IntervalStats"
			}
			if {[info exists hasmotifprop]} {
				$stst add cascade -label "MOTIFS" -menu $stst.mtf
				set ststmtf [menu $stst.mtf -tearoff 0]
				$ststmtf add command -label "Motif Statistics" -command "MotifStats 0"
				$ststmtf add command -label "Refresh Motif Statistics" -command "MotifStats 1"
				$ststmtf add command -label "Use Motifs To Locate Sub-HFs Within Snds" -command "IntervalStats"
			}
			if {[info exists hasMMprop] && ($rcodeat > 0)} {
				$stst add cascade -label "RHYTHM" -menu $stst.rhy
				set ststrhy [menu $stst.rhy -tearoff 0]
				$ststrhy add command -label "Map To Idealised Rhythm" -command "IdealisedRhythmMap"
			}
			button $f.radio.tt.ll -text "Text Search" -bd 2 -command {} -width 11 -highlightbackground [option get . background {}]
			pack $f.radio.tt.ss $f.radio.tt.ll -side top 
			entry $f.radio.e -textvariable proptxtsrch -width 20
			pack  $f.radio.e $f.radio.tt -side right -padx 2
			frame $f.radio.01 -width 1 -bg $evv(POINT)
			pack $f.radio.01 -side right -fill y -expand true
			set proptxtsrch ""
		}
		bind $f <Control-Right> {PropNameSelect 1}
		bind $f <Control-Left>  {PropNameSelect 0}
		bind $f <Control-Up>   {PropTabPlayView 0}
		bind $f <Control-Down> {PropTabPlayView 1}
		bind $f <Left>  {PropTabEdge 0}
		bind $f <Right> {PropTabEdge 1}
		bind $f <Up> {PropTabEdge 2}
		bind $f <Down>  {PropTabEdge 3}
		frame $f.radio.00 -width 1 -bg $evv(POINT)
		frame $f.radio.gtt
		frame $f.radio.gtt.1
		label $f.radio.gtt.1.0 -text "GET SOUNDS WITH PROPERTY" -fg $evv(SPECIAL)
		button $f.radio.gtt.1.x -text "Use Last Hilited Val" -command "CopyOrPasteProps 0 0 0" -highlightbackground [option get . background {}]
		button $f.radio.gtt.1.1 -text "More Options" -command "Do_Props 0 ; set pr_proptab 0" -highlightbackground [option get . background {}]
		pack $f.radio.gtt.1.0 $f.radio.gtt.1.x -side left
		pack $f.radio.gtt.1.1 -side right
		frame $f.radio.gtt.2
		label $f.radio.gtt.2.getln -text Name
		entry $f.radio.gtt.2.gpr1 -textvariable getsndprpn -state readonly -width $propnamax -readonlybackground [option get . background {}]
		checkbutton $f.radio.gtt.2.getall -text "(vals include)" -variable getsndprpc -width 14
		label $f.radio.gtt.2.getll -text Val
		entry $f.radio.gtt.2.gpr2 -textvariable getsndprpv -width $propvamax
		pack $f.radio.gtt.2.getln $f.radio.gtt.2.gpr1 $f.radio.gtt.2.getall $f.radio.gtt.2.getll $f.radio.gtt.2.gpr2 -side left
		pack $f.radio.gtt.1 -side top -fill x -expand true -pady 2
		pack $f.radio.gtt.2 -side top -pady 2
		frame $f.radio.get
		button $f.radio.get.get -text "Snds to Chosen List" -command "GetSndsOnPropval 0" -width 20 -highlightbackground [option get . background {}]
		button $f.radio.get.prf -text "Snds to New Propfile" -command "GetSndsOnPropval $fnam" -width 20 -highlightbackground [option get . background {}]
		pack $f.radio.get.get $f.radio.get.prf -side top
		pack $f.radio.00 -side left -fill y -expand true
		pack $f.radio.get -side right -padx 2
		pack $f.radio.gtt -side right -padx 2
		pack $f.radio -side top -fill x -expand true -pady 2
		frame $f.c -bd 2 -highlightthickness 2 -highlightbackground $evv(SPECIAL)
		set tp_can [Scrolled_Canvas $f.c.c -width 1200 -height $evv(PROPTABLEN) -scrollregion "0 0 $tp_canwidpix $tp_canlenpix"]
		pack $f.c.c -side top -fill x -expand true
		pack $f.c -side top -fill x -expand true
		frame $f.d
		frame $f.d.1
		frame $f.d.2
		set tp_rhy  [canvas $f.d.1.1 -height 70 -width 600 -borderwidth 0 -highlightthickness 1 -highlightbackground $evv(SPECIAL)]
		set tp_rhy2 [canvas $f.d.1.2 -height 70 -width 600 -borderwidth 0 -highlightthickness 1 -highlightbackground $evv(SPECIAL)]
		pack $f.d.1.1 $f.d.1.2 -side top -fill x -expand true
		$tp_rhy create text	60 64 -text "RHYTHM DISPLAY" -font {helvetica 9 bold} -fill $evv(POINT)
		set kk [frame $tp_rhy2.f -bd 0]
		$tp_rhy2 create window 0 0 -anchor nw -window $kk
		button $kk.c -text "Clear" -command {ClearGraphicFromRhythmDisplay $tp_rhy2} -highlightbackground [option get . background {}]
		label $kk.ll -text ""  -width $tp_boxwid(0)
		pack $kk.c $kk.ll -side right -anchor n -padx 2

		set phf(can1)  [canvas $f.d.2.1 -height 144 -width 300 -borderwidth 0 -highlightthickness 1 -highlightbackground $evv(SPECIAL)]
		set phf(can2) [canvas $f.d.2.2 -height 144 -width 300 -borderwidth 0 -highlightthickness 1 -highlightbackground $evv(SPECIAL)]
		pack $f.d.2.1 $f.d.2.2 -side left -fill x -expand true
		$phf(can1) create text	240 6 -text "HFIELD DISPLAY" -font {helvetica 9 bold} -fill $evv(POINT)
		set jj [frame $phf(can2).f -bd 0]
		$phf(can2) create window 0 0 -anchor nw -window $jj
		button $jj.c -text "Clr" -command {ClearGraphicFromHFDisplay $phf(can2)} -highlightbackground [option get . background {}]
		button $jj.p -text "Play" -command {PlayGraphicFromHFDisplay 0} -highlightbackground [option get . background {}]
		button $jj.s -text "+Src" -command {PlayGraphicFromHFDisplay 1} -highlightbackground [option get . background {}]
		button $jj.f -text "Flat" -command {HFDisplayFlats 0 0} -width 6 -highlightbackground [option get . background {}]
		label $jj.ll -text ""  -width $tp_boxwid(0)
		pack $jj.c $jj.f $jj.p $jj.s $jj.ll -side left -anchor n -padx 2

		set phf(shrpline) 60
		set phf(shrpnoteline) 70 
		set phf(noteline) 110 
		set phf(shrpspace) 160 
		set phf(shrpnotespace) 170 
		set phf(notespace) 210 

		$phf(can1) create line 12 50 240 50 -width 1 -fill $evv(POINT)
		$phf(can1) create line 12 60 240 60 -width 1 -fill $evv(POINT)
		$phf(can1) create line 12 70 240 70 -width 1 -fill $evv(POINT)
		$phf(can1) create line 12 80 240 80 -width 1 -fill $evv(POINT)
		$phf(can1) create line 12 90 240 90 -width 1 -fill $evv(POINT)
	
		$phf(can1) create line 40  40 40 105 -width 1 -fill $evv(POINT)
		$phf(can1) create arc 40 34 52 46 -style arc -start 180 -extent -230 -width 1 -outline $evv(POINT)
		$phf(can1) create line 48  45 30 80 -width 1 -fill $evv(POINT)
		$phf(can1) create arc 30 70 50 90 -style arc -start 180 -extent 270 -width 1 -outline $evv(POINT)

		$phf(can2) create line 12 50 240 50 -width 1 -tag staff -fill $evv(POINT)
		$phf(can2) create line 12 60 240 60 -width 1 -tag staff -fill $evv(POINT)
		$phf(can2) create line 12 70 240 70 -width 1 -tag staff -fill $evv(POINT)
		$phf(can2) create line 12 80 240 80 -width 1 -tag staff -fill $evv(POINT)
		$phf(can2) create line 12 90 240 90 -width 1 -tag staff -fill $evv(POINT)
	
		$phf(can2) create line 40  40 40 105 -width 1 -fill $evv(POINT)
		$phf(can2) create arc 40 34 52 46 -style arc -start 180 -extent -230 -width 1 -outline $evv(POINT)
		$phf(can2) create line 48  45 30 80 -width 1 -fill $evv(POINT)
		$phf(can2) create arc 30 70 50 90 -style arc -start 180 -extent 270 -width 1 -outline $evv(POINT)

		pack $f.d.1 $f.d.2 -side left -fill x -expand true
		pack $f.d -side top -fill x -expand true
		set k [frame $tp_can.f -bd 0]
		$tp_can create window 0 0 -anchor nw -window $k
		set tp_bfw $k
		set n 0
		while {$n <= $tp_canlen} {
			frame $tp_bfw.$n
			incr n
		}
		set n 0
		set m 0
		set mm -1
		Block "Creating Properties Display"
		while {$m < $tp_props_cnt} {
			if {$m == 0} {
				button $tp_bfw.$n.$m -width $tp_boxwid($m) -text "PLAY" -command {} -bd 0 -state disabled -disabledforeground $evv(SPECIAL) -highlightbackground [option get . background {}]
				grid $tp_bfw.$n.$m -row $n -column $m -padx 2
			} else { 
				button $tp_bfw.$n.$m -width $tp_boxwid($m) -text [lindex $tp_propnames $mm] -command {} -bg $evv(EMPH) -fg $evv(SPECIAL) -highlightbackground [option get . background {}]
				bind   $tp_bfw.$n.$m <Control-Shift-Command-ButtonPress-1>   "set blok_propexplan 1; ChangePropertyName $mm $tp_bfw.$n.$m $fnam"
				bind   $tp_bfw.$n.$m <Control-Shift-Command-ButtonRelease-1>   {set blok_propexplan 0}
				bind   $tp_bfw.$n.$m <Control-ButtonRelease-1> "ReadPropertyExplanation  [lindex $tp_propnames $mm] ^"
				bind   $tp_bfw.$n.$m <Shift-ButtonRelease-1>   "WritePropertyExplanation [lindex $tp_propnames $mm] ^"
				bind   $tp_bfw.$n.$m <Command-ButtonRelease-1>   "SeePropvalsElsewhere [lindex $tp_propnames $mm] $fnam"
				grid $tp_bfw.$n.$m -row $n -column $m
			}
			incr m
			incr mm
		}
		button $tp_bfw.$n.$m -width $tp_boxwid(0) -text "PLAY" -command {} -bd 0 -state disabled -disabledforeground $evv(SPECIAL) -highlightbackground [option get . background {}]
		grid $tp_bfw.$n.$m -row $n -column $m -padx 2
		set k 0
		incr n
		while {$n <= $tp_canlen} {
			set line [lindex $tp_props_list $k]
			set m 0
			set mm -1
			while {$m < $tp_props_cnt} {
				set val [lindex $line $m]
				if {$m == 0} {
					set valx $val
					if {$shorten} {
						set valx [file rootname [file tail $valx]]
					}
					button $tp_bfw.$n.$m -width $tp_boxwid($m) -text $valx -command "SetAndSaveProplocn $n; PlaySndfile $val 0" -bg $evv(HELP) -highlightbackground [option get . background {}]
					bind $tp_bfw.$n.$m <ButtonRelease-1> "set proplastplay $val"
				} else {
					set p_name [lindex $tp_propnames $mm]
					if {[string match [string tolower $p_name] "text"]} {
						set val [PropsStripUnderscores $val]
						set padval [expr $tp_boxwid($m) - [string length $val]]
						if {$padval > 0} {
							set padval [expr ($padval * 3) / 2]
							set padstr ""
							set jj 0
							while {$jj < $padval} {
								append padstr " "
								incr jj
							}
							append val $padstr
						}
					} elseif {[string match [string tolower $p_name] "rcode"]} {
						if {![string match $val "-"]} {
							set val "yes"
						}
					} elseif {[string match [string tolower $p_name] "offset"]} {
						if {![string match $val "-"]} {
							set val [DecPlaces $val 4]
						}
					}
					button $tp_bfw.$n.$m -width $tp_boxwid($m) -text $val -command {} -highlightbackground [option get . background {}]
					bind   $tp_bfw.$n.$m <Control-ButtonRelease-1> "ReadPropertyExplanation  $p_name \"$val\""
					bind   $tp_bfw.$n.$m <Shift-ButtonRelease-1>   "WritePropertyExplanation $p_name \"$val\""
					bind   $tp_bfw.$n.$m <Control-Shift-Command-ButtonPress-1>   "set blok_propexplan 1; CallPropEntry [lindex $line 0] $fnam $n $m"
					bind   $tp_bfw.$n.$m <Control-Shift-Command-ButtonRelease-1>  {set blok_propexplan 0}
					bind   $tp_bfw.$n.$m <Command-ButtonPress-1>  "set blok_propexplan 1; PropGrafDisplay $n $m 0 $fnam"
					bind   $tp_bfw.$n.$m <Command-ButtonRelease-1>  {set blok_propexplan 0; ClearGraphicFromRhythmDisplay $tp_rhy; ClearGraphicFromHFDisplay $phf(can1)}
					bind   $tp_bfw.$n.$m <Shift-Command-ButtonPress-1>  "set blok_propexplan 1; PropGrafDisplay $n $m 1 $fnam"
					bind   $tp_bfw.$n.$m <Shift-Command-ButtonRelease-1>  {set blok_propexplan 0}
				}
				grid $tp_bfw.$n.$m -row $n -column $m
				incr m
				incr mm
			}
			set val [lindex $line 0]
			button $tp_bfw.$n.$m -width $tp_boxwid(0) -text $valx -command "SetAndSaveProplocn $n; PlaySndfile $val 0" -bg $evv(HELP) -highlightbackground [option get . background {}]
			bind $tp_bfw.$n.$m <ButtonRelease-1> "set proplastplay $val"
			grid $tp_bfw.$n.$m -row $n -column $m
			incr k
			incr n
		}
		set n 0
		while {$n <= $tp_canlen} {
			pack $tp_bfw.$n -side top
			incr n
		}
		set m 1
		while {$m < $tp_props_cnt} {
			bind $tp_bfw.0.$m <ButtonPress-1> "TpHilite $m 1"
			bind $tp_bfw.0.$m <ButtonRelease-1> "TpHilite $m 0"
			bind $tp_bfw.0.$m <Control-ButtonRelease-1> "+ TpHilite $m 0"
			bind $tp_bfw.0.$m <Shift-ButtonRelease-1> "+ TpHilite $m 0"
			incr m
		}
		set n 1
		while {$n <= $tp_canlen} {
			set m 1
			while {$m < $tp_props_cnt} {
				bind $tp_bfw.$n.$m <ButtonPress-1> "TpCrossHair $n $m 1; CopyOrPasteProps $n $m $fnam"
				bind $tp_bfw.$n.$m <ButtonRelease-1> "TpCrossHair $n $m 0"
				bind $tp_bfw.$n.$m <Control-ButtonRelease-1> "+ TpCrossHair $n $m 0"
				bind $tp_bfw.$n.$m <Shift-ButtonRelease-1> "+ TpCrossHair $n $m 0"
				bind $tp_bfw.$n.$m <Command-ButtonRelease-1> "+ TpCrossHair $n $m 0"
				incr m
			}
			incr n
		}
		UnBlock
		frame $f.other
		radiobutton $f.other.g -text "Ensure Snds Are On Wkspace" -command "PropTabSndsToWkspace"
		radiobutton $f.other.c -text "Selected Snd To Chosen List" -command "PropTabSndsToChosen"
		pack $f.other.g $f.other.c -side left -padx 2
		button $f.other.renum -text "Renumber Sounds" -command "PropsSndsNumericRenumber $fnam" -highlightbackground [option get . background {}]
		label $f.other.frll -text "from number "
		entry $f.other.from -textvariable phf(from) -width 3
		label $f.other.adll -text "adding "
		entry $f.other.add -textvariable phf(adding) -width 3
		label $f.other.toll -text "to file "
		entry $f.other.toff -textvariable phf(renumf)
		pack $f.other.toff $f.other.toll $f.other.add $f.other.adll $f.other.from $f.other.frll $f.other.renum -side right
		pack $f.other -side top -fill x -expand true -pady 2
		frame $f.zz -height 1 -bg [option get . foreground {}]
		pack $f.zz -side top -fill x -expand true -pady 4

		set phf(from) ""
		set phf(adding) ""
		set phf(renumf) ""
		if {[info exists hastextprop]} {
			bind $f.radio.tt.ll <ButtonPress-1>   {PropTextSearch}
		}
		wm resizable .proptab 1 1
		bind $f <Escape> {set pr_proptab 0}
	}
	set pt_radio 1
	PropTabPlayView 1
	set f $proptab_f
	$f.radio.left.0.cnt config -text "[llength $tp_props_list]"
	if {[string match -nocase [lindex $tp_propnames 0] "hf"]} {
		$proptab_f.radio.gtt.2.getall config -state disabled -text ""
		set getsndprpc 0
	} else {
		$proptab_f.radio.gtt.2.getall config -state normal -text "(vals include)"
		set getsndprpc 1
	}
	set getsndprpn [lindex $tp_propnames 0]
	foreach nam $tp_propnames {
		if {[string match [string tolower $nam] "hf"]} {
			set k [lsearch $tp_propnames $nam]
			incr k
			$f.ok.hff config  -text "HF snds "
			$f.ok.hfplay config -bd 2 -text "Display=Play" -command "TogglePropHFPlay"
			break
		}
	}
	wm title .proptab "PROPERTIES TABLE $fnam"
	if {[info exists proplastplay]} {
		set testfnam [file rootname [file tail $proplastplay]]
		set n 1
		while {$n <= $tp_canlen} {
			if [string match [$tp_bfw.$n.0 cget -text] $testfnam] {
				set canvlen [expr [llength $tp_props_list] + 6]	;#	KLUDGE
				$tp_can yview moveto [expr double($n - 1)/double($canvlen)]
				set doflash 1
				break
			}
			incr n
		}
		if {$n == $tp_canlen} {
			unset proplastplay
		}
	}
	set finished 0
	set pr_proptab 0
	raise .proptab
	update idletasks
	StandardPosition .proptab
	My_Grab 0 .proptab pr_proptab $f
	if {[info exists doflash]} {
		DoPropsFlash $n
		set proplocn $n
	}
	while {!$finished} {
		tkwait variable pr_proptab
		if {$pr_proptab} {
			if {[info exists proplastplay]} {
				set i [LstIndx $proplastplay $wl]
				if {$i < 0} {
					if {![file exists $proplastplay]} {
						continue
					} elseif {[FileToWkspace $proplastplay 0 0 0 0 0] <= 0} {
						continue
					}
				}
				if {[info exists chlist]} {
					if {[lsearch $chlist $proplastplay] < 0} {
						lappend chlist $proplastplay
						$ch insert end $proplastplay
						incr chcnt
					}
				} else {
					lappend chlist $proplastplay
					$ch insert end $proplastplay
					incr chcnt
				}
			}
		} else {
			break
		}
	}
	if {![info exists chlist] || ([llength $chlist] <= 0)} {
		if [info exists origchlist] {
			set chcnt 0
			set chlist $origchlist
			foreach fn $chlist {
				$ch insert end $fn
				incr chcnt
			}
		}
	}
	set fnams [glob -nocomplain "__snd*"]
	foreach fnam $fnams {
		catch {file delete $fnam}
	}
	My_Release_to_Dialog .proptab
	Dlg_Dismiss .proptab
	destroy .proptab
}

#----- Get all sounds in props file to workspace

proc PropTabSndsToWkspace {} {
	global tp_props_list wl
	set got 0
	Block "Loading Files to Workspace"
	foreach line $tp_props_list {
		set snd [lindex $line 0]
		if {[LstIndx $snd $wl] < 0} {
			set got 1
			if {[FileToWkspace $snd 0 0 0 1 0] <= 0} {
				lappend badfiles $snd
			} else {
				lappend goodfiles $snd
			}
		}
	}
	UnBlock
	if {!$got} {
		Inf "All Files Are Already On The Workspace"
		return
	} elseif {![info exists goodfiles]} {
		Inf "No Files Could Be Put On The Worksapce"
		return
	} elseif [info exists badfiles] {
		set msg "The Following Files Could Not Be Placed On The Workspace\n"
		set cnt 0
		foreach fnam $badfiles {
			append msg $fnam "\n"
			incr cnt
			if {$cnt >= 20} {
				append msg "And More"
				break
			}
		}
	} else {
		Inf "Files Now On Workspace"
	}
}

proc ConvertFontHorizToPixels {n} {
	return [expr $n * 7]
}

proc ConvertFontVertToPixels {n} {
	return [expr int(round($n * 11.5))]
}

proc TpHilite {m on} {
	global tp_props_cnt tp_canlen tp_bfw evv
	set n 1
	switch -- $on {
		1 {
			while {$n <= $tp_canlen} {
				$tp_bfw.$n.$m config -bg $evv(EMPH)
				incr n
			}
		}
		0 {
			while {$n <= $tp_canlen} {
				$tp_bfw.$n.$m config -bg [option get . background {}]
				incr n
			}
		}
	}
}

proc TpCrossHair {n m on} {
	global tp_props_list tp_propnames evv proptab_f
	switch -- $on {
		1 {
			incr n -1
			incr m -1
			set name [lindex [lindex $tp_props_list $n] 0]
			set name [file rootname [file tail $name]]
			set propnam [lindex $tp_propnames $m]
			append name " : " $propnam
			$proptab_f.radio.what config -text $name -bg $evv(EMPH)
		}
		0 {
			$proptab_f.radio.what config -text "" -bg [option get . background {}]
		}
	}
}

#--- Special calls to Sound Graphics display from Props Table environment

proc PropsSndView {from} {
	global nuaddpsnd evv
	if {[string length $nuaddpsnd] <= 0} {
		return
	}
	switch -- $from {
		"tab" {
			SnackDisplay 0 $evv(SN_FROM_PROPSPAGE_NO_OUTPUT) 0 $nuaddpsnd
		}
		"hfgrfix" {
			SnackDisplay 0 $evv(SN_FROM_PROPSHF_NO_OUTPUT) 0 $nuaddpsnd
		}
	}
}

#---- Renumber numbered sndfiles in a propsfile

proc PropsSndsNumericRenumber {fnam} {
	global tp_propnames tp_props_list phf wstk evv
	global total_wksp_cnt wl rememd propfiles_list

	set outfilename $phf(renumf)
	set fileno $phf(from)
	set thisincr $phf(adding)

	if {[string length $outfilename] < 0} {
		Inf "No New Propsfile Name Entered"	
		return
	}
	if {[string match $outfilename $fnam]} {
		Inf "You Cannot Overwrite The Input File Here"
		return
	}
	if {![ValidCDPRootname $outfilename]} {
		return
	}
	if {![regexp {^[0-9]+$} $fileno]} {
		Inf "Invalid Startfile Number"
		return
	}
	if {![IsNumeric $thisincr]} {
		Inf "Invalid File Numbering Increment"
		return
	}
	set intcheck $thisincr
	if {[string match [string index $intcheck 0] "-"]} {
		set intcheck [string range $intcheck 1 end]
	}
	if {![regexp {^[0-9]+$} $intcheck]} {
		Inf "Invalid File Numbering Increment"
		return
	}
	set outfnam $outfilename
	set this_ext [GetTextfileExtension props]
	append outfnam $this_ext
	if {[file exists $outfnam]} {
		set msg "File  '$outfnam' Already Exists: Do You Want To Overwrite It??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		} elseif [catch {file delete $outfnam} zit] {
			Inf "Cannot Delete Existing File '$outfnam'"
			return
		} else {
			set k [lsearch -exact $propfiles_list $outfnam]
			if {$k >= 0} {
				set propfiles_list [lreplace $propfiles_list $k $k]
			}
			set i [LstIndx $outfnam $wl]
			if {$i >= 0} {
				PurgeArray $outfnam
				RemoveFromChosenlist $outfnam
				incr total_wksp_cnt -1
				$wl delete $i
				catch {unset rememd}
			}
		}
	}
	set msg "If This Process Is Successful\n"
	append msg "Return To Workspace And\n"
	append msg "Renumber The Soundfiles There In Exactly The Same Way\n"
	append msg "Before Proceeding To Use The New Properties File\n"
	Inf $msg
	Block "Renunmbering Soundfiles in Property File"
	set props_list $tp_props_list
	set linecnt 0
	foreach line $props_list {
		set item [lindex $line 0]
		set ext [file extension $item]
		set name_num [SplitNumericallyIndexedFilename $item 0]
		if {[llength $name_num] <= 0} {
			Inf "Not All Filenames Are Numerically Indexed"
			UnBlock
			return
		}				
		set name [lindex $name_num 0]
		if {$linecnt == 0} {
			set basename $name
		} else {
			if {![string match $basename $name]} {
				Inf "Not All Filenames Have Same Basename"
				UnBlock
				return
			}
		}
		set num [lindex $name_num 1]
		lappend nums $num
		if {$num == $fileno} {
			set startline $linecnt
		}
		incr linecnt
	}
	if {![info exists startline]} {
		Inf "Failed To Find File '$basename$fileno'"
		UnBlock
		return
	}
	set len [llength $props_list] 
	set n $startline
	while {$n < $len} {
		set num_n [lindex $nums $n]
		incr num_n $thisincr
		set nuname $basename
		append nuname $num_n $ext
		set line_n [lindex $props_list $n]
		set line_n [lreplace $line_n 0 0 $nuname]
		set props_list [lreplace $props_list $n $n $line_n]
		incr n
	}
	if [catch {open $outfnam "w"} zit] {
		Inf "Cannot Open File '$outfnam' To Write Reordered Data"
		UnBlock
		return
	}
	puts $zit $tp_propnames
	foreach line $props_list {
		puts $zit $line
	}
	close $zit
	FileToWkspace $outfnam 0 0 0 0 1
	Inf "New Data In File '$outfnam'"
	UnBlock
}

#---- Split components of filename with a numeric index at end

proc SplitNumericallyIndexedFilename {fnam rootonly} {
	if {!$rootonly} {
		set thisdir [file dirname $fnam]
	}
	set fnam [file rootname [file tail $fnam]]
	set k [string length $fnam]
	incr k -1
	set endk $k
	while {[regexp {[0-9]} [string index $fnam $k]]} {
		incr  k -1
		if {$k < 0} {
			break
		}
	}
	if {($k == $endk) || ($k < 0)} {
		return {}
	}
	set name [string range $fnam 0 $k]
	incr k 
	set num [string range $fnam $k end]
	if {!$rootonly} {
		set name [file join $thisdir $name]
	}
	return [list $name $num]
}

#--- Switch between play and SoundView

proc PropTabPlayView {view} {
	global tp_canlen tp_props_list tp_bfw proplocn evv pt_radio proplastplay
	set len [llength [lindex $tp_props_list 0]]
	switch -- $view {
		0 {
			$tp_bfw.0.0 config -text "PLAY"
			$tp_bfw.0.$len config -text "PLAY"
			set k 0
			set n 1
			while {$n <= $tp_canlen} {
				set val [lindex [lindex $tp_props_list $k] 0]
				$tp_bfw.$n.0 config -command "SetAndSaveProplocn $n; PlaySndfile $val 0; set proplastplay $val" -bg $evv(HELP)
				$tp_bfw.$n.$len config -command "SetAndSaveProplocn $n; PlaySndfile $val 0; set proplastplay $val" -bg $evv(HELP)
				incr k
				incr n
			}
			set pt_radio 0
		}
		1 {
			$tp_bfw.0.0 config -text "VIEW"
			$tp_bfw.0.$len config -text "VIEW"
			set k 0
			set n 1
			while {$n <= $tp_canlen} {
				set val [lindex [lindex $tp_props_list $k] 0]
				$tp_bfw.$n.0 config -command "SetAndSaveProplocn $n; SnackDisplay 0 $evv(SN_FROM_PROPSTAB_NO_OUTPUT) 0 $val; set proplastplay $val" -bg $evv(SNCOLOR)
				$tp_bfw.$n.$len config -command "SetAndSaveProplocn $n; SnackDisplay 0 $evv(SN_FROM_PROPSTAB_NO_OUTPUT) 0 $val; set proplastplay $val" -bg $evv(SNCOLOR)
				incr k
				incr n
			}
			set pt_radio 1
		}
	}
}

#---- Copy/Paste prop on Prop Table display

proc CopyOrPasteProps {n m fnam} {
	global tp_props_list tp_props_cnt tp_propnames tp_boxwid tp_bfw saved_props props_paste wstk evv
	global proplocn proplocm tp_canlen getsndprpv getsndprpn propnsel pre_proplocn last_proplocn

	if {[info exists last_proplocn] && [info exists props_paste] && [info exists saved_props] && ($props_paste == 5)} {
		set proplocn $last_proplocn
	}
	if {($n == 0) && ($m == 0)} {
		if {[string match $fnam "0"]} {
			set props_paste 4			;#	Pastes prop name and val to GenSnds boxes
		} else {
			set props_paste 2			;#	Pastes value of a specific prop to all snds
		}
	}
	set k [expr $n - 1]	;#	k = index to property-val lines, n includes propnames line

	if {[info exists props_paste]} {
		if {[info exists saved_props]} {
			switch -- $props_paste {
				1 {
					set msg "Paste ~All~ Properties In Last-Highlighted Row To This Sound ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						set line [lindex $tp_props_list $k]
						set nuline [lindex $line 0]
						set nuline [concat $nuline $saved_props]
						set tp_props_list [lreplace $tp_props_list $k $k $nuline]
						set m 1
						set mm 0
						while {$m < $tp_props_cnt} {
							set val [lindex $nuline $m]
							set p_name [lindex $tp_propnames $mm]
							if {[string match [string tolower $p_name] "text"]} {
								set val [PropsStripUnderscores $val]
								set padval [expr $tp_boxwid($m) - [string length $val]]
								if {$padval > 0} {
									set padval [expr ($padval * 3) / 2]
									set padstr ""
									set jj 0
									while {$jj < $padval} {
										append padstr " "
										incr jj
									}
									append val $padstr
								}
							} elseif {[string match [string tolower $p_name] "rcode"]} {
								if {![string match $val $evv(NULL_PROP)]} {
									set val "yes"
								}
							}
							$tp_bfw.$n.$m config -text $val -command {}
							incr m
							incr mm
						}
					}
				}
				2 {
					set msg "Paste Last-Highlighted Property Value To ~All~ Sounds ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						set val [lindex $saved_props [expr $proplocm - 1]]
						set len [llength $tp_props_list]
						set j 0
						while {$j < $len} {
							set line [lindex $tp_props_list $j]
							set line [lreplace $line $proplocm $proplocm $val]
							set tp_props_list [lreplace $tp_props_list $j $j $line]
							incr j
						}
						set p_name [lindex $tp_propnames [expr $proplocm - 1]]
						if {[string match [string tolower $p_name] "text"]} {
							set val [PropsStripUnderscores $val]
							set padval [expr $tp_boxwid($m) - [string length $val]]
							if {$padval > 0} {
								set padval [expr ($padval * 3) / 2]
								set padstr ""
								set jj 0
								while {$jj < $padval} {
									append padstr " "
									incr jj
								}
								append val $padstr
							}
						} elseif {[string match [string tolower $p_name] "rcode"]} {
							if {![string match $val $evv(NULL_PROP)]} {
								set val "yes"
							}
						}
						set n 1
						while {$n <= $tp_canlen} {
							$tp_bfw.$n.$proplocm config -text $val
							incr n
						}
					}
				}
				3 -
				6 {
					set val [lindex $saved_props [expr $proplocm - 1]]
					set p_name [lindex $tp_propnames [expr $proplocm - 1]]
					set line [lindex $tp_props_list $k]
					set line [lreplace $line $m $m $val]
					set tp_props_list [lreplace $tp_props_list $k $k $line]
					if {[string match [string tolower $p_name] "text"]} {
						set padval [expr $tp_boxwid($m) - [string length $val]]
						set val [PropsStripUnderscores $val]
						if {$padval > 0} {
							set padval [expr ($padval * 3) / 2]
							set padstr ""
							set jj 0
							while {$jj < $padval} {
								append padstr " "
								incr jj
							}
							append val $padstr
						}
					} elseif {[string match [string tolower $p_name] "rcode"]} {
						if {![string match $val $evv(NULL_PROP)]} {
							set val "yes"
						}
					}
					if {$props_paste == 6} {
						set zz [expr $proplocn - 1]
						set line [lindex $tp_props_list $zz]
						set line [lreplace $line $proplocm $proplocm $evv(NULL_PROP)]
						set tp_props_list [lreplace $tp_props_list $zz $zz $line]
						$tp_bfw.$proplocn.$proplocm config -text $evv(NULL_PROP) -command {}
					}
					$tp_bfw.$n.$m config -text $val -command {}
				}
				4 {	;#	PASTES PROP NAME AND VAL TO 'GET  SNDS' BOXES
					set propnsel [expr $proplocm - 1]
					set getsndprpn [lindex $tp_propnames $propnsel]
					if {[string match [string tolower $getsndprpn] "text"]} {
						set getsndprpv [PropsStripUnderscores [lindex $saved_props $propnsel]]
					} else {
						set getsndprpv [lindex $saved_props $propnsel]
					}
					set pre_proplocn $proplocn
				}
				5 {
					if {$proplocm == $m} {
						set msg "Paste Last-Highlighted Property Value To All Boxes From There To Here ??"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "yes"} {
							set val [lindex $saved_props [expr $proplocm - 1]]
							if {$proplocn < $n} {
								set stt [expr $proplocn - 1]
								set len [expr $n - 1]
							} else {
								set len [expr $proplocn - 1]
								set stt [expr $n - 1]
							}
							set j $stt
							while {$j <= $len} {
								set line [lindex $tp_props_list $j]
								set line [lreplace $line $proplocm $proplocm $val]
								set tp_props_list [lreplace $tp_props_list $j $j $line]
								incr j
							}
							set p_name [lindex $tp_propnames [expr $proplocm - 1]]
							if {[string match [string tolower $p_name] "text"]} {
								set val [PropsStripUnderscores $val]
								set padval [expr $tp_boxwid($m) - [string length $val]]
								if {$padval > 0} {
									set padval [expr ($padval * 3) / 2]
									set padstr ""
									set jj 0
									while {$jj < $padval} {
										append padstr " "
										incr jj
									}
									append val $padstr
								}
							} elseif {[string match [string tolower $p_name] "rcode"]} {
								if {![string match $val $evv(NULL_PROP)]} {
									set val "yes"
								}
							}
							incr stt
							incr len
							set n $stt
							while {$n <= $len} {
								$tp_bfw.$n.$proplocm config -text $val
								incr n
							}
						}
					}
				}
			}
		}
		if {$props_paste != 4} {
			OverwritePropsfile $fnam tp
		}
		unset props_paste
	}

	set proplocn $n
	set proplocm $m
	catch {unset last_proplocn}
	set line [lindex $tp_props_list $k]
	set saved_props [lrange $line 1 end]
}

#------- Graphically Display Rhythm, Pitch or other special Data, om PRops Table page

proc PropGrafDisplay {lineno propno permanent propfile}  {
	global tp_propnames tp_props_list tp_rhy tp_rhy2 phf prg_dun prg_abortd CDPidrun pa evv simple_program_messages tp_bfw
	global xx_code xx_lineno play_window_below
	set pname [lindex $tp_propnames [expr $propno - 1]]
	incr lineno -1
	if {$permanent} {
		set sndname [lindex [lindex $tp_props_list $lineno] 0]
		set sndname [file rootname [file tail $sndname]]
	}
	switch -- [string tolower $pname] {
		"rcode" {
			if {$permanent} {
				set can $tp_rhy2
			} else {
				set can $tp_rhy
			}
			ReadRhythm $lineno $propno $can
			if {$permanent} {
				$tp_rhy2.f.ll config -text $sndname
			}
		}
		"hf" {
			if {$permanent} {
				set can $phf(can2)
			} else {
				set can $phf(can1)
			}
			set jj [ReadHFProp $lineno $propno $can]
			if {[llength $jj] == 2} {
				set xx_lineno [lindex $jj 0]
				set xx_code   [lindex $jj 1]
			} else {
				catch {unset xx_lineno}
				catch {unset xx_code}
			}
			if {$permanent} {
				$phf(can2).f.ll config -text $sndname
			}
		}
		"mm" {
			set code [lindex [lindex $tp_props_list $lineno] $propno]
			if {![IsNumeric $code]} {
				return
			}
			if {$permanent} {
				Inf "6/8 -->> 3/4\n\nMM = [DecPlaces [expr $code  * 3.0] 1]"
			} else {
				Inf "3/4 -->> 6/8\n\nMM = [DecPlaces [expr $code /3.0] 1]"
			}
		}
		"motif" {
			switch -- [$tp_bfw.0.0 cget -text] {
				"PLAY" {
					set sndname [lindex [lindex $tp_props_list $lineno] 0]
					set sndbasnam [file rootname [file tail $sndname]]
					if {![info exists pa($sndname,$evv(SRATE))]} {
						Inf "Cannot Play Motif: Source File Not On The Workspace"
						return
					}
					set srate $pa($sndname,$evv(SRATE))
					set chans $pa($sndname,$evv(CHANS))
					set dur $pa($sndname,$evv(DUR))
					set outname "__snd_"
					append outname $sndbasnam $evv(SNDFILE_EXT)
					set datafnam [file rootname $sndname]
					append datafnam $evv(PCH_TAG) [GetTextfileExtension brk]
					if {![file exists $datafnam]} {
						Inf "Cannot Find Pitchdata File '$datafnam'"
						return
					}
					if {![file exists $outname]} {
						set cmd [file join $evv(CDPROGRAM_DIR) synth]
						lappend cmd wave 1 $outname $srate 1 $dur $datafnam -a0.25 -t256 
						set prg_dun 0
						set prg_abortd 0
						catch {unset simple_program_messages}
						if [catch {open "|$cmd"} CDPidrun] {
							ErrShow "Cannot Synthesize The Pitchline: $CDPidrun"
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
							set msg "Cannot Synthesize The Pitchline"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							return
						}
					}
					if {$permanent} {  ;#	i.e. PLAY BOTH
						set bothname "__snd_both_"
						append bothname $sndbasnam $evv(SNDFILE_EXT)
						if {![file exists $bothname]} {
							if {![OffsetForBothFileMix $outname $srate $chans $lineno]} {
								return
							}
							set cmd [file join $evv(CDPROGRAM_DIR) submix]
							lappend cmd interleave $outname $sndname $bothname
							set prg_dun 0
							set prg_abortd 0
							catch {unset simple_program_messages}
							if [catch {open "|$cmd"} CDPidrun] {
								ErrShow "Cannot Mix Pitchline Sound With Source: $CDPidrun"
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
								set msg "Cannot Mix Pitchline Sound With Source: $CDPidrun"
								set msg [AddSimpleMessages $msg]
								ErrShow $msg
								return
							}
						}
					}
					if {$permanent} {
						PlaySndfile $bothname 0
					} else {
						PlaySndfile $outname 0
					}
				}
				"VIEW" {
					SeePropMotif $lineno $propno $propfile
				}
			}
		}
		"tonic" {
			set code [lindex [lindex $tp_props_list $lineno] $propno]
			if {[string first "C#" $code] >= 0} {
				set code Db
			} elseif {[string first "C" $code] >= 0} {
				set code C
			} elseif {[string first "Db" $code] >= 0} {
				set code Db
			} elseif {[string first "D#" $code] >= 0} {
				set code Eb
			} elseif {[string first "D" $code] >= 0} {
				set code D
			} elseif {[string first "Eb" $code] >= 0} {
				set code Eb
			} elseif {[string first "E" $code] >= 0} {
				set code E
			} elseif {[string first "F#" $code] >= 0} {
				set code Gb
			} elseif {[string first "F" $code] >= 0} {
				set code F
			} elseif {[string first "Gb" $code] >= 0} {
				set code Gb
			} elseif {[string first "G#" $code] >= 0} {
				set code Ab
			} elseif {[string first "G" $code] >= 0} {
				set code G
			} elseif {[string first "Ab" $code] >= 0} {
				set code Ab
			} elseif {[string first "A#" $code] >= 0} {
				set code Bb
			} elseif {[string first "A" $code] >= 0} {
				set code A
			} elseif {[string first "Bb" $code] >= 0} {
				set code Bb
			} elseif {[string first "B" $code] >= 0} {
				set code B
			} else {
				return
			}
			switch -- $code {
				C {
					set tonfile $evv(TESTFILE_C)
				}
				Db {
					set tonfile $evv(TESTFILE_Db)
				}
				D {
					set tonfile $evv(TESTFILE_D)
				}
				Eb {
					set tonfile $evv(TESTFILE_Eb)
				}
				E {
					set tonfile $evv(TESTFILE_E)
				}
				F {
					set tonfile $evv(TESTFILE_F)
				}
				Gb {
					set tonfile $evv(TESTFILE_Gb)
				}
				G {
					set tonfile $evv(TESTFILE_G)
				}
				Ab {
					set tonfile $evv(TESTFILE_Ab)
				}
				A {
					set tonfile $evv(TESTFILE_A)
				}
				Bb {
					set tonfile $evv(TESTFILE_Bb)
				}
				B {
					set tonfile $evv(TESTFILE_B)
				}
			}
			if {$permanent} {  ;#	i.e. PLAY BOTH
				set sndname [lindex [lindex $tp_props_list $lineno] 0]
				set sndbasnam [file rootname [file tail $sndname]]
				if {![info exists pa($sndname,$evv(SRATE))] || $pa($sndname,$evv(SRATE)) != 44100} {
					return
				}
				if {($code == "A") && ![file exists $tonfile]} {
					set msg "YOU NEED file \"testfilea\" to be in your \"_cdpenv\" directory\n"
					append msg "To create this...\n"
					append msg "1) copy \"testfile\" from directory \"_cdpenv\" to your CDP base directory\n"
					append msg "       (do this outside the Loom as directory \"cdpenv\" is not acccessible from the Loom)\n"
					append msg "2) change the sample rate of the copy to 44100: and rename it \"tesfilea\"\n"
					append msg "3) copy the new file into directory \"_cdpenv\" (again, outside the Loom).\n"
					Inf $msg
					return
				}
				set bothname "__snd_plustonic_"
				append bothname $code "_" $sndbasnam $evv(SNDFILE_EXT)
				if {![file exists $bothname]} {
					set cmd [file join $evv(CDPROGRAM_DIR) submix]
					lappend cmd interleave $tonfile $sndname $bothname
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					if [catch {open "|$cmd"} CDPidrun] {
						ErrShow "Cannot Mix Tonic With Source: $CDPidrun"
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
						set msg "Cannot Mix Tonic With Source: $CDPidrun"
						set msg [AddSimpleMessages $msg]
						ErrShow $msg
						return
					}
				}
				PlaySndfile $bothname 0
			} else {
				if {($code == "A") && ![file exists $tonfile]} {
					PlaySndfile $evv(TESTFILE_A) 0
				} else {
					PlaySndfile $tonfile 0
				}
			}
		}
		default {
			set code [lindex [lindex $tp_props_list $lineno] $propno]
			if {![IsNumeric $code] || ($code < 0) || ($code >= 127)} {
				return
			}
			if {![regexp {^[0-9]+$} $code]} {
				set code [expr int(round($code))]
			}
			while {$code > 72} {
				incr code -12
			}
			while {$code < 60} {
				incr code 12
			}
			switch -- $code {
				60 { set tonfile testfilec }
				61 { set tonfile testfiledb }
				62 { set tonfile testfiled }
				63 { set tonfile testfileeb }
				64 { set tonfile testfilee }
				65 { set tonfile testfilef }
				66 { set tonfile testfilegb }
				67 { set tonfile testfileg }
				68 { set tonfile testfileab }
				69 { set tonfile testfilea }
				70 { set tonfile testfilebb }
				71 { set tonfile testfileb }
				72 { set tonfile testfilec2 }
			}
			set play_window_below 1
			PlaySndfile [file join $evv(CDPRESOURCE_DIR) $tonfile$evv(SNDFILE_EXT)] 0
			unset {play_window_below}
		}
	}
}

#--- Toggle between playing or not playing HF files when display-HF is called

proc TogglePropHFPlay {} {
	global phf proptab_f
	switch -- $phf(play) {
		0 {
			set phf(play) 1
			$proptab_f.ok.hfplay config -text "DisplayQuiet"
		
		}
		1 {
			set phf(play) 0
			$proptab_f.ok.hfplay config -text "Display=Play"
		}
	}
}

#----- Get a sndfile in a props file table display to the Chosen Files list and go to workspace

proc PropTabSndsToChosen {} {
	global tp_props_list proplocn tp_canlen ch chlist chcnt wl pr_proptab CDPsnack
	if {![info exists proplocn]} {
		return
	}
	set k [expr $proplocn - 1]
	set fnam [lindex [lindex $tp_props_list $k] 0]

	if {![LstIndx $fnam $wl] < 0} {
		Inf "File '$fnam' Is Not On The Workspace"
		return
	}
	if {[info exists CDPsnack]} {
		Inf "Close The \"Sound View\" Window"
	}
	DoChoiceBak
	catch {unset chlist}
	set chlist $fnam
	$ch delete 0 end
	$ch insert end $fnam
	set chcnt 1
	set pr_proptab 0
 }

#----- Change a specific Property Name,  CALLED FROM TABLE DISPLAY

proc ChangePropertyName {mm box pfile} {
	global pr_chprname tp_propnames chprname prop_reserved_names wstk evv

	set thispropname [lindex $tp_propnames $mm]
	if {[lsearch $prop_reserved_names $thispropname] >= 0} {
		set msg "\"$thispropname\" Is A Reserved Property Name. If You Are Using The Name In The Convention-Defined Way,\n"
		append msg "Altering This Name Will Mean The Special Features Are No Longer Accessible For This Property.\n\n"
		append msg  "Do You Wish To Change The Name ??.\n"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		}
	}
	set f .chprname
	if [Dlg_Create $f "CHANGE NAMES OF PROPERTY" "set pr_chprname 0" -borderwidth $evv(BBDR)] {
		frame $f.a -borderwidth $evv(BBDR)
		button $f.a.q -text "Abandon Change" -command {set pr_chprname 0} -highlightbackground [option get . background {}]
		button $f.a.k -text "Keep New Name" -command {set pr_chprname 1} -highlightbackground [option get . background {}]
		pack $f.a.q -side right
		pack $f.a.k -side left
		pack $f.a -side top -fill x -expand true
		frame $f.b -borderwidth $evv(BBDR)
		label $f.b.ll -text "New Name for Property  "
		entry $f.b.e -textvariable chprname -width 16
		pack $f.b.ll $f.b.e -side left
		pack $f.b -side top -pady 2 
		wm resizable $f 1 1
		bind $f <Escape> {set pr_chprname 0}
		bind $f <Return> {set pr_chprname 1}
	}
	set chprname ""
	set pr_chprname 0
	set finished 0
	set orig_name [lindex $tp_propnames $mm]
	wm title $f "CHANGE NAMES OF PROPERTY $orig_name"
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_chprname $f
	while {!$finished} {
		tkwait variable pr_chprname
		if {$pr_chprname} {
			set chprname [string trim $chprname]
			if {[string length $chprname] <= 0} {
				Inf "No New Property Name Entered"
				continue
			}
			set test [split $chprname]
			if {[llength $test] > 1} {
				Inf "Property Name ($chprname) Cannot Contain Spaces"
				continue
			}
			if {[regexp {[\,\£\$]} $chprname]} {
				Inf "Property Name ($chprname) Cannot Contain Commas '$' Or '£' Signs"
				continue
			}
			if {[string match $chprname $orig_name]} {
				set msg "No Change To Property Name: Is This Correct ?"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				} else {
					break
				}
			}
			if {[lsearch $tp_propnames $chprname] >= 0} {
				Inf "The Property Name ($chprname) Is Already Being Used For Another Property"
				continue
			}
			set tp_propnames [lreplace $tp_propnames $mm $mm $chprname]
			if {[OverwritePropsfile $pfile tp]} {
				$box config -text $chprname
			} else {
				set tp_propnames [lreplace $tp_propnames $mm $mm $orig_name]
			}
		}
		break
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

#--- Initial check before calling prop entry on Props Table window

proc CallPropEntry {sndfile propfile lineno propno} {
	global wl tp_bfw tp_propnames tp_props_list
	if {[string match [$tp_bfw.0.0 cget -text] "VIEW"]} {
		PropTabPlayView 1
	}
	$wl selection clear 0 end
	set k [LstIndx $sndfile $wl]
	if {$k < 0} {
		Inf "File $sndfile Is Not On The Workspace"
		return
	}
	set thisprop [lindex $tp_propnames [expr $propno - 1]]
	if {[string match [string tolower $thisprop] "motif"]} {
		MelodyAssignTab 1 [expr $lineno - 1] $propno $propfile
	} else {
		AddPropsToSndsInPropfileTab $lineno $propno $propfile
	}
}

#------ Do offsetting for start-silence in Play Both from Props window

proc OffsetForBothFileMix {outfnam srate chans lineno} {
	global tp_propnames tp_props_list CDPidrun prg_dun prg_abortd evv

	set othername $evv(DFLT_OUTNAME)
	append othername 00 $evv(SNDFILE_EXT)
	set silfil $evv(DFLT_OUTNAME)
	append silfil 02 $evv(SNDFILE_EXT)
	set tst [lsearch $tp_propnames "offset"]
	if {$tst < 0} {
		return 1
	}
	incr tst 
	set offset [lindex [lindex $tp_props_list $lineno] $tst]
	if {![IsNumeric $offset] || ($offset < 0)} {
		Inf "Invalid Offset Value"
		return 1
	}
	if {$offset <= 0} {
		return 1
	}
	set cmd [file join $evv(CDPROGRAM_DIR) synth]
	lappend cmd silence $silfil $srate $chans $offset
	set prg_dun 0
	set prg_abortd 0
	catch {unset simple_program_messages}
	if [catch {open "|$cmd"} CDPidrun] {
		ErrShow "Cannot Create Silence For Offset: $CDPidrun"
		catch {unset CDPidrun}
		return 1
	} else {
		fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
	}
	vwait prg_dun
	if {$prg_abortd} {
		set prg_dun 0
	}
	if {!$prg_dun} {
		set msg "Cannot Create Silence For Offset: $CDPidrun"
		set msg [AddSimpleMessages $msg]
		ErrShow $msg
		DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
		return 1
	}
	if [catch {file rename $outfnam $othername} zit] {
		Inf "Can't Do Offsetting"
		DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
		return 1
	}
	set cmd [file join $evv(CDPROGRAM_DIR) sfedit]
	lappend cmd join $silfil $othername $outfnam -w0
	set prg_dun 0
	set prg_abortd 0
	catch {unset simple_program_messages}
	if [catch {open "|$cmd"} CDPidrun] {
		ErrShow "Cannot Create Offset Motif-File: $CDPidrun"
		catch {unset CDPidrun}
		if [catch {file rename $othername $outfnam} zit] {
			Inf "Playing Motif Failed"
			DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
			return 0
		}
		DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
		return 1
	} else {
		fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
	}
	vwait prg_dun
	if {$prg_abortd} {
		set prg_dun 0
	}
	if {!$prg_dun} {
		set msg "Cannot Create Offset Motif-File: $CDPidrun"
		set msg [AddSimpleMessages $msg]
		ErrShow $msg
		if [catch {file rename $othername $outfnam} zit] {
			Inf "Playing Motif Failed"
			DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
			return 0
		}
	}
	DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
	return 1
}

#---- Interface for adding properties to sounds in a properties table

proc AddPropsToSndsInPropfileTab {lineno propno propfile} {
	global pr_nueraddp wstk wl chlist propfiles_list evv
	global readonlyfg readonlybg old_props_protocol adp_sndfiles adp_props_list adp_propnames
	global nuaddpsnd nuaddpsndshow nuaddpnam nuaddpval addp_pnamenu nuaddp_evals
	global total_wksp_cnt rememd tp_props_list tp_props_cnt tp_propnames tp_bfw tp_boxwid proplastplay

	set propline [expr $lineno - 1]
	if {$old_props_protocol} {
		return
	}
	set adp_propnames $tp_propnames
	set adp_props_list $tp_props_list
	catch {unset adp_sndfiles}
	foreach line $adp_props_list {
		lappend adp_sndfiles [lindex $line 0]
	}
	set nuaddpsnd [lindex [lindex $adp_sndfiles $propline] 0]
	set nuaddpsndshow [file rootname [file tail $nuaddpsnd]] 
	set nuaddpnam [lindex $adp_propnames [expr $propno - 1]]
	set orig_nuaddpnam $nuaddpnam
	if {[string match -nocase ok* $nuaddpnam]} {
		set doneit 0
		set the_line [lindex $adp_props_list $propline]
		set val [lindex $the_line $propno]
		if {$val == $evv(NULL_PROP)} {
			set val "ok"
			set the_line [lreplace $the_line $propno $propno $val]
			set adp_props_list [lreplace $adp_props_list $propline $propline $the_line]
			set doneit 1
		} elseif {$val == "ok"} {
			set val "**"
			set the_line [lreplace $the_line $propno $propno $val]
			set adp_props_list [lreplace $adp_props_list $propline $propline $the_line]
			set doneit 1
		} elseif {$val == "**"} {
			set val $evv(NULL_PROP)
			set the_line [lreplace $the_line $propno $propno $val]
			set adp_props_list [lreplace $adp_props_list $propline $propline $the_line]
			set doneit 1
		}
		if {$doneit} {
			if {![OverwritePropsfile $propfile adp]} {
				return
			}
			set new_props [lindex $adp_props_list $propline]
			set tp_props_list [lreplace $tp_props_list $propline $propline $new_props]
			$tp_bfw.$lineno.$propno config -text $val
		}
		return
	}
	set f .nueraddp
	if [Dlg_Create $f "ADD OR CHANGE PROPERTY IN PROPERTIES FILE" "set pr_nueraddp 0" -borderwidth $evv(BBDR)] {
		set f0 [frame $f.0 -borderwidth $evv(BBDR)]
		set f0a [frame $f.0a -height 1 -bg [option get . foreground {}]]
		set f1 [frame $f.1 -borderwidth $evv(BBDR)]
		set f1a [frame $f.1a -height 1 -bg [option get . foreground {}]]
		set f2 [frame $f.2 -borderwidth $evv(BBDR)]
		set f2a [frame $f.2a -height 1 -bg [option get . foreground {}]]
		set f3 [frame $f.3 -borderwidth $evv(BBDR)]
		set f4 [frame $f.4 -borderwidth $evv(BBDR)]
		button $f0.sav -text "Save" -width 4 -command {set pr_nueraddp 1} -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $f0.cfi -text "Create File" -width 11 -command {set pr_nueraddp 1} -bg $evv(EMPH) -highlightbackground [option get . background {}]
		frame $f0.1
		label $f0.1.ll -text "PROPERTY FILE NAME"
		entry  $f0.1.nam -textvariable addp_pnamenu -width 20 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		pack $f0.1.ll $f0.1.nam -side left		
		button $f0.quit -text "Abandon" -command {set pr_nueraddp 0} -highlightbackground [option get . background {}]
		pack $f0.sav $f0.cfi -side left		
		pack $f0.1 -side left -padx 60		
		pack $f0.quit -side right
		pack $f0 -side top -fill x -expand true
		pack $f0a -side top -fill x -expand true

		label $f1.ll -text "SOUND:                  "
		entry $f1.e -textvariable nuaddpsndshow -width 32 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		button $f1.play -text  "PLAY" -bd 4 -width 4 -command "AdpPlaySndfile 0; ; set proplastplay $nuaddpsnd" -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f1.a -text "A" -bd 4 -command "PlaySndfile $evv(TESTFILE_A) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f1.motif -text  "HF from Motif" -bd 2 -command "Motif_to_HF $lineno $propno $tp_propnames"
		pack $f1.ll $f1.e $f1.play -side left -padx 2
		pack $f1.a $f1.motif -side right
		pack $f1 -side top -fill x -expand true
		pack $f1a -side top -fill x -expand true

		label $f2.ll -text "PROP:  "
		frame $f2.x
		frame $f2.x.1
		
		label $f2.x.1.ll -text "Name" -width 7
		entry $f2.x.1.nam -textvariable nuaddpnam -width 48 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
		button $f2.x.1.rcode -text "" -command {} -bg $evv(EMPH)  -state disabled -bg [option get . background {}] -width 19 -highlightbackground [option get . background {}]
		pack $f2.x.1.ll $f2.x.1.nam $f2.x.1.rcode -side left -pady 2 -padx 2
		frame $f2.x.2
		label $f2.x.2.ll -text "Value" -width 7
		entry $f2.x.2.val -textvariable nuaddpval -width 48
		button $f2.x.2.nul -text "Null" -command AddpNull -width 5 -highlightbackground [option get . background {}]
		button $f2.x.2.bkt -text "()" -command AddBrackets -width 3 -highlightbackground [option get . background {}]
		button $f2.x.2.str -text "*" -command AddStar -width 3 -highlightbackground [option get . background {}]
		button $f2.x.2.clr -text "Clear" -command {set nuaddpval ""} -width 5 -highlightbackground [option get . background {}]
		pack $f2.x.2.ll $f2.x.2.val $f2.x.2.clr $f2.x.2.bkt $f2.x.2.str $f2.x.2.nul -side left -pady 2 -padx 2
		pack $f2.x.1 $f2.x.2 -side top -anchor w -pady 1
		pack $f2.ll $f2.x -side left -padx 2
		pack $f2 -side top -fill x -expand true
		pack $f2a -side top -fill x -expand true

		label $f3.ll -text "ALL EXISTING VALUES OF SELECTED PROPERTY"
		label $f3.l2 -text "click to select   " -fg $evv(SPECIAL)
		pack $f3.ll $f3.l2 -side top
		set nuaddp_evals [Scrolled_Listbox $f3.eval -width 80 -height 24 -selectmode single]
		pack $f3.eval -side top -pady 1
		pack $f3 -side top
		MakeBigKeyboard $f4
		pack $f4 -side top
		bind $f <Up>   {IncrTabPropName 0}
		bind $f <Down> {IncrTabPropName 1}
		bind $nuaddp_evals <ButtonRelease-1> {AddpDisplayPropValTab %y}
		wm resizable $f 1 1
		bind $f <Escape> {set pr_nueraddp 0}
	}
	set line [lindex $adp_props_list $propline]
	set val [lindex $line $propno]
	if {[string match $val $evv(NULL_PROP)]} {
		set val ""
	}
	if {[string match [string tolower $nuaddpnam] "text"]} {
		set val [PropsStripUnderscores $val]
	}
	set nuaddpval $val
#KLUDGE
if {[string match [string tolower $nuaddpnam] "hf"]} {
Inf "Original value = $nuaddpval"
}
	ForceVal .nueraddp.1.e $nuaddpsndshow	;#	PUT NAME OF SND INTO SNDNAME BOX
	ForceVal .nueraddp.2.x.1.nam $nuaddpnam	;#	PUT NAME OF PROP INTO PROPNAME BOX
	if {[string match [string tolower $nuaddpnam] "rcode"]} {
		.nueraddp.2.x.1.rcode config -text RhythmCode -command {set nuaddpval [EstablishRhythmPropDisplay 0 1]} -bd 2 -state normal -bg $evv(EMPH)
	} elseif {[string match [string tolower $nuaddpnam] "hf"]} {
		.nueraddp.2.x.1.rcode config -text "enter HF as graphic" -command {set nuaddpval [Props_CreateHFData]} -bd 2 -state normal -bg $evv(EMPH)
	} elseif {[string match [string toupper $nuaddpnam] "MM"]} {
		.nueraddp.2.x.1.rcode config -text "Mark Beats" -command {Props_GetMM} -bd 2 -state normal -bg $evv(EMPH)
	} else {
		.nueraddp.2.x.1.rcode config -text "" -bd 0 -state disabled -bg [option get . background {}]
	}
	set addp_pnamenu [file rootname [file tail $propfile]]
	ForceVal $f.0.1.nam $addp_pnamenu
	set origtabfnam $propfile
	$nuaddp_evals delete 0 end
	set plist {}
	foreach line $adp_props_list {
		set val [lindex $line $propno]
		if {[string match $val $evv(NULL_PROP)]} {
			continue
		}
		if {[string match -nocase $nuaddpnam "text"]} {
			set vals $val
		} else {
			set vals [SeparatePropvals $val]
		}
		foreach val $vals {
			
			if {[lsearch $plist $val] < 0} {
				lappend plist $val
			}
		}
	}
	set plist [lsort -dictionary $plist]		;#	LIST (SORTED) EXISTING VALS OF PROP
	foreach prp $plist {
		if {[string match [string tolower $nuaddpnam] "text"]} {
			$nuaddp_evals insert end [PropsStripUnderscores $prp]
		} else {
			$nuaddp_evals insert end $prp
		}
	}

	if {[string match -nocase $nuaddpnam "hf"]} {
		.nueraddp.0.cfi config -text "Create File" -command {set pr_nueraddp 2} -bd 2 -bg $evv(EMPH)
		.nueraddp.0.sav config -bg [option get . background {}]
	} else {
		.nueraddp.0.cfi config -text "" -command {} -bd 0 -bg [option get . background {}]
		.nueraddp.0.sav config -bg $evv(EMPH)
	}
	set pr_nueraddp 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_nueraddp $f.2.x.2.val
	while {!$finished} {
		tkwait variable pr_nueraddp
		switch -- $pr_nueraddp {
			0 {	;#	QUIT
				if {![string match $orig_nuaddpnam $nuaddpnam]} {
					set msg "Alterations To The Property Will Be Lost. Do You Really Want To Quit ?"
					set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
					if {$choice == "no"} {
						continue
					}
				}
				set nuaddpval ""
				set finished 1
			}
			1 -
			2 {
				set nuaddpval [string trim $nuaddpval]		;#	CHECK PROPERTY EXISTS AND IS A SINGLE STRING
				if {[string length $nuaddpval] <= 0} {
					Inf "No Property Value Entered"
					continue
				}
				set istext 0
				switch -- [string tolower $nuaddpnam] {
					"text" {
						set istext 1
						if {[PropsFindUnderscores $nuaddpval]} {
							Inf "Underscores Not Permitted In \"Text\" Property (Reserved For Enetering Written Text)"
							continue
						}
					}
					"motif" {
						if {[string match $nuaddpval "got_motif"]} {
							set val "yes"
						}
					}
					"hf" {
						set nuaddpval [BackSlashHashProblem $nuaddpval]
						if {![GoodHFSyntax $nuaddpval]} {
							continue
						}
					}
					"tonic" {
						set nuaddpval [BackSlashHashProblem $nuaddpval]
					}
				}
				set itemcnt 0
				set line [split $nuaddpval]
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] > 0} {
						incr itemcnt
					}
				}
				if {$istext && ($itemcnt != 1)} {
					set cnt 0
					foreach item $line {
						if {$cnt == 0} {
							set zz $item
						} else {
							append zz $evv(TEXTJOIN) $item
						}
						incr cnt
					}
					set nuaddpval $zz
					set itemcnt 1
				}
				if {$itemcnt != 1} {
					Inf "Invalid Property Value Entered (No Spaces Permitted)"
					continue
				}
				if {$pr_nueraddp == 2} {
					GeneratePropSingleHFSndfile $propline $nuaddpval
				}
				set line [lindex $adp_props_list $propline]
				set line [lreplace $line $propno $propno $nuaddpval]
				set adp_props_list [lreplace $adp_props_list $propline $propline $line]		;#	SUBSTITUTE ITS NEW PROPSLIST

				set tempfnam $evv(DFLT_OUTNAME)$evv(TEXT_EXT)
				if [catch {open $tempfnam "w"} zit] {
					Inf "Cannot Open Temporary File 'tempfnam' To Write Updated Properties Information"
					continue
				}
				set theseprops [join $adp_propnames]
				puts $zit $theseprops
				foreach line $adp_props_list {
					puts $zit $line
				}
				close $zit
				set onam $origtabfnam
				if [catch {file delete $onam} zit] {
					set msg "Cannot Delete Original File '$onam'"
					append msg "\n\nTry A New Name ?"
					set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
					if {$choice == "yes"} {
						continue
					}
					set msg "You Can Rename File '$tempfnam' Now, Outside The Soundloom, Before Proceeding.\n"
					append msg "\nIf You Do Not, You Will Lose The New Data Once You Hit 'OK'?"
					Inf $msg
					break
				}
				set k [lsearch -exact $propfiles_list $onam]
				if {$k >= 0} {
					set propfiles_list [lreplace $propfiles_list $k $k]
				}
				set i [LstIndx $onam $wl]
				if {$i >= 0} {
					PurgeArray $onam
					RemoveFromChosenlist $onam
					incr total_wksp_cnt -1
					$wl delete $i
					catch {unset rememd}
				}
				if [catch {file rename $tempfnam $onam} zit] {
					set msg "Cannot Rename File '$tempfnam' To '$onam'.\n\n"
					append msg "You Can Rename File '$tempfnam' Now, Outside The Soundloom, Before Proceeding.\n"
					append msg "\nIf You Do Not, You Will Lose The New Data Once You Hit 'OK'?"
					Inf $msg
					break
				}
				lappend propfiles_list $onam
				FileToWkspace $onam 0 0 0 0 1
				set new_props [lindex $adp_props_list $propline]
				set m 1
				set mm 0
				while {$m < $tp_props_cnt} {
					set newval [lindex $new_props $m]
					set oldval [$tp_bfw.$lineno.$m cget -text]
					if {[string compare $oldval $newval]} {
						set newvaldisp $newval
						set nuaddpnam [lindex $tp_propnames $mm]
						if {[string match [string tolower $nuaddpnam] "rcode"]} {
							set newvaldisp "yes"
						} elseif {[string match [string tolower $nuaddpnam] "motif"]} {
							set newvaldisp "yes"
							set new_props [lreplace $new_props $m $m "yes"]
						} elseif {[string match [string tolower $nuaddpnam] "offset"]} {
							set newvaldisp [DecPlaces $newvaldisp 4]
						} elseif {[string match [string tolower $nuaddpnam] "text"]} {
							set newvaldisp [PropsStripUnderscores $newval]
							set padval [expr $tp_boxwid($m) - [string length $newvaldisp]]
							if {$padval > 0} {
								set padval [expr ($padval * 3) / 2]
								set padstr ""
								set jj 0
								while {$jj < $padval} {
									append padstr " "
									incr jj
								}
								append newvaldisp $padstr
							}
						}
						$tp_bfw.$lineno.$m config -text $newvaldisp
						bind $tp_bfw.$lineno.$m <Control-ButtonRelease-1> {}
						bind $tp_bfw.$lineno.$m <Control-ButtonRelease-1> "ReadPropertyExplanation  $nuaddpnam \"$newval\""
						bind $tp_bfw.$lineno.$m <Shift-ButtonRelease-1>   "WritePropertyExplanation $nuaddpnam \"$newval\""
					}
					incr m
					incr mm
					set tp_props_list [lreplace $tp_props_list $propline $propline $new_props]
				}
				set nuaddpval ""
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

#---- Display existing property value (from table) in value box in prop-entry window

proc AddpDisplayPropValTab {y} {
	global nuaddp_evals nuaddpval nuaddpnam
	set i [$nuaddp_evals nearest $y]
	if {$i < 0} {
		return
	}
	set nuval [$nuaddp_evals get $i]
	switch -- [string tolower $nuaddpnam] {
		"text" -
		"offset" -
		"mm" -
		"text" -
		"src" -
		"hf" {
			ForceVal .nueraddp.2.x.2.val $nuval
			return
		}
	}
	set zozo [.nueraddp.2.x.2.val get]
	set zozo [string trim $zozo]
	if {[string length $zozo] > 0} {
		set nuaddpval $zozo
		append nuaddpval "," [$nuaddp_evals get $i]
	} else {
		set nuaddpval [$nuaddp_evals get $i]
	}
	if {[string match [string tolower $nuaddpnam] "text"]} {
		set nuaddpval [PropsStripUnderscores $nuaddpval]
	}
	ForceVal .nueraddp.2.x.2.val $nuaddpval
}

#---- Display existing property value (from table) in value box in prop-entry window

proc AddBrackets {} {
	global nuaddpval
	set zozo [.nueraddp.2.x.2.val get]
	set zozo [string trim $zozo]
	if {[string length $zozo] <= 0} {
		return
	}
	set zozo [split $zozo ","]
	set lastzoz "("
	append lastzoz [lindex $zozo end] ")"
	set len [llength $zozo]
	if {$len == 1} {
		set zozo $lastzoz
	} else {
		set zozo [lreplace $zozo end end $lastzoz]
		set zozo [join $zozo ","]
	}
	set nuaddpval $zozo
	ForceVal .nueraddp.2.x.2.val $nuaddpval
}

#---- Display existing property value (from table) in value box in prop-entry window

proc AddStar {} {
	global nuaddpval
	set zozo [.nueraddp.2.x.2.val get]
	set zozo [string trim $zozo]
	if {[string length $zozo] <= 0} {
		return
	}
	append zozo "*"
	set nuaddpval $zozo
	ForceVal .nueraddp.2.x.2.val $nuaddpval
}

#----- Delete (various categories of) temporary files which are NOT outputs of CDP processes.

proc DeleteAllTemporaryFilesWhichAreNotCDPOutput {type infnam} {
	global evv
	set returnval 1
	set i 0
	while {$i < 2} {
		switch -- $i {
			"0" {set outfname $evv(DFLT_OUTNAME) }
			"1" {set outfname $evv(MACH_OUTFNAME) }
		}
		set fnams [glob -nocomplain "$outfname*"]
		foreach fnam $fnams {
			switch -- $type {
				"all" {
					if [catch {file delete -force $fnam} result] {
						lappend baddeletes $fnam
					}
				}
				"text" {
					if {[string match [file extension $fnam] $evv(TEXT_EXT)]} {
						if [catch {file delete -force $fnam} result] {
							lappend baddeletes $fnam
						}
					}
				}
				"snd" {
					if {[string match [file extension $fnam] $evv(SNDFILE_EXT)]} {
						if [catch {file delete -force $fnam} result] {
							lappend baddeletes $fnam
						}
					}
				}
				"except" {
					set dodelete 1
					foreach ifnam $infnam {
						if {[string match $fnam $ifnam]} {
							set dodelete 0
							break
						}
					}
					if {$dodelete} {
						if [catch {file delete -force $fnam} result] {
							lappend baddeletes $fnam
						}
					}
				}
			}
		}
		incr i
	}
	if {[info exists baddeletes]} {
		set msg "Cannot Delete The Following Temporary Files\n\n"
		set cnt 0
		foreach fnam $baddeletes {
			append msg $fnam "\n"
			incr cnt
			if {$cnt >= 20} {
				append msg "AND MORE"
				break
			}
		}
		ErrShow $msg
		set returnval 0
	}
	return $returnval
}

#---- Info on prop table

proc PropTabInfo {} {
	global evv
	set msg "PROPERTY TABLE INFORMATION\n"
	append msg "\n"
	append msg "\"Control Shift Command Click\" on prop box,\n"
	append msg "Goes to Prop entry page. Props take any value\n"
	append msg "and value shown in table\n"
	append msg "EXCEPT special formats (See below).\n"
	append msg "\n"
	append msg "Otherwise, no spaces; items can be bracketed,starred,\n"
	append msg "or separated by commas (for multiple vals).\n"
	append msg "These recognised when \"Explanations\" entered\n"
	append msg "(see \"K\" key).\n"
	append msg "\n"
	append msg "SPECIAL PROPERTY FORMATS\n"
	append msg "\n"
	append msg "                 RCODE\n"
	append msg "Rhythmic pattern stored as alphanumeric string.\n"
	append msg "Enter from music-staff using \"RhythmCode\" button.\n"
	append msg "If Rcode exists, table shows \"yes\".\n"
	append msg "View (graphics) using keyboard (see \"K\" key).\n"
	append msg "                HF\n"
	append msg "Enter from music staff, using \"enter HF as graphic\" button.\n"
	append msg "To play from Table (see key \"K\" for details),\n"
	append msg "you must first \"HF Generate snds\" (see button\n"
	append msg "on Property Entry Page for HF).\n"
	append msg "To play HF automatically when HF value clicked-on,\n"
	append msg "press the \"Display=Play\" button above Table Display.\n"
	append msg "\n"
	append msg "HF generated automatically if \"Motif\" prop entered.\n"
	append msg "In that case, none of motif notes treated as passing note.\n"
	append msg "To convert note -> passing note: Upper-case -> lower-case\n"
	append msg "on Property Entry Page for Motif.\n"
	append msg "\n"
	append msg "(.....MORE.....)\n"
	append msg "\n"
	Inf $msg
	set msg "                   MOTIF\n"
	append msg "Enter from music staff, using \"Enter Motif\" button.\n"
	append msg "First use \"Sound View\" to mark TIMES of motif notes.\n"
	append msg "Then enter motif-notes on staff as explained.\n"
	append msg "Play, with or without source-snd, (see key \"K\").\n"
	append msg "Stored in name-tagged files, in directory of source.\n"
	append msg "\"$evv(SEQ_TAG)\" is midi sequence file.\n"
	append msg "\"$evv(PCH_TAG)\" is frequency breakpoint file.\n"
	append msg "\"$evv(FILT_TAG)\" is filter data for varibank filter.\n"
	append msg "                OFFSET\n"
	append msg "If 1st snd in source not at zero, its time = \"offset\".\n"
	append msg "If prop \"Offset\" exists, value automatically set\n"
	append msg "when motif created.\n"
	append msg "                TONIC\n"
	append msg "tonic key(s) of sound. Enter key name (A-G caps) \n"
	append msg "+ possible '#' or 'b' and 'm' (minor key).\n"
	append msg "                TEXT\n"
	append msg "You can use spaces when entering text.\n"
	append msg "Stored as single strings joined by underscores.\n"
	append msg "You cannot use underscores in entered texts.\n"
	append msg "You can search for words (etc) WITHIN \"text\" props,\n"
	append msg "and also do statistics (word, phrase counts etc.)\n"
	append msg "                IDEAS\n"
	append msg "Written in textfile (\"ideas.txt\")\n"
	append msg "in same directory as (first) soundfile(s).\n"
	append msg "Shift-Click on \"ideas\" property box\n"
	append msg "will create or call up this file for editing.\n"
	append msg "Each idea should be numbered (from 1 upwards).\n"
	append msg "Shift-Command-Control-Click (as normal)\n"
	append msg "to enter idea-number in the property box.\n"
	append msg "Control-Click on number in property box\n"
	append msg "will display numbered idea(s).\n"
	Inf $msg
}

###############################
# PROPERTY TABLE EXPLANATIONS #
###############################

proc WritePropertyExplanation {name val} {
	global blok_propexplan prexpldir evv
	if {$blok_propexplan} {
		return
	}
	if {![regexp {^[\^]} $val]} {
		if {$name == "text"} {
			return
		} elseif {$name == "ideas"} {
			IdeasFile 0
			return
		}
	}
	set exfile [file join $prexpldir $evv(EXPROPS)]
	set tmpfnam $evv(DFLT_TMPFNAME)
	if {[string match $val "-"]} {
		return
	}
	if {[string match $val "^"]} {
		append val $name
		set nuvals $val
	} else {
		set nuvals [SplitProperty $val]
	}
	set len [llength $nuvals]
	set n 0
	while {$n < $len} {
		set val [lindex $nuvals $n]
		if {[string length $val] <= 0} {
			set nuvals [lreplace $nuvals $n $n]
			incr len -1
			continue
		}
		set explan [EnterPropExplanation $val {}]
		if {[llength $explan] <= 0} {
			set nuvals [lreplace $nuvals $n $n]
			incr len -1
			continue
		}
		lappend explans $explan
		incr n
	}
	if {$len <= 0} {
		return
	}
	if {![file exists $exfile]} {
		if [catch {open $exfile "w"} zit] {
			Inf "Cannot Open File $exfile To Write New Data"
			return
		}
		foreach val $nuvals explan $explans {
			if [regexp {^[\^]} $val] {
				set val "^"
			}
			set line [list $name $val]
			set line [concat $line $explan]
			puts $zit $line
		}
		close $zit
		return
	}
	if [catch {open $exfile "r"} zit] {
		Inf "Cannot Open Property Explanations File"	
		return
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		set line [split $line]
		catch {unset nuline}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend nuline $item
			}
		}
		set len [llength $nuvals]
		if {[info exists nuline]} {
			if {$len > 0} {
				set propname [lindex $nuline 0]
				set propval [lindex $nuline 1]
				set n 0
				while {$n < $len} {
					set val [lindex $nuvals $n]
					set explan [lindex $explans $n]
					if {[string match $name $propname] && [string match $val $propval]} {
						set line [list $name $val]
						set line [concat $line $explan]
						set nuline $line
						set nuvals [lreplace $nuvals $n $n]
						set explans [lreplace $explans $n $n]
						incr len -1
					} else {
						incr n
					}
				}
			}
			lappend nulines $nuline
		}
	}
	close $zit
	if {$len > 0} {
		foreach val $nuvals explan $explans {
			set line [list $name $val]
			set line [concat $line $explan]
			set nuline $line
			lappend nulines $nuline
		}
	}
	if [catch {open $tmpfnam "w"} zit] {
		Inf "Cannot Open File $tmpfnam To Write New Data"
		return
	}
	foreach line $nulines {
		puts $zit $line
	}
	close $zit
	if [catch {file delete $exfile} zit] {
		Inf "Cannot Delete Existing Explanations File"	
		catch {file delete $tmpfnam}
		return
	}
	if [catch {file rename $tmpfnam $exfile} zit] {
		set msg "CANNOT RENAME NEW EXPLANATIONS FILE $tmpfnam TO $exfile\n\n"
		append msg "DO THIS, OUTSIDE THE SOUNDLOOM, BEFORE CLOSING THIS DIALOGUE BOX"
		Inf $msg
		catch {file delete $tmpfnam}
	}
}

#--- Read Explanation for Property on props table window

proc ReadPropertyExplanation {name val} {
	global blok_propexplan prexpldir evv
	if {$blok_propexplan} {
		return
	}
	set got 0
	set nuvals [SplitProperty $val]
	if {[string match -nocase $name "ideas"]} {
		if {[string match -nocase [lindex $nuvals 0] "^"]} {
			IdeasFile 0
			return
		} else {				
			set vals [split $val ","]
			foreach val $vals {
				if  {[regexp {^[0-9,]+$} $val]} {
					IdeasFile $val
				}
			}
			return
		}
	}
	set len [llength $nuvals]
	set exfile [file join $prexpldir $evv(EXPROPS)]
	if {![file exists $exfile]} {
		Inf "No Explanation File"	
		return
	}
	if [catch {open $exfile "r"} zit] {
		Inf "Cannot Open Property Explanations File"	
		return
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		set line [split $line]
		catch {unset nuline}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend nuline $item
			}
		}
		if {[info exists nuline]} {
			set propname [lindex $nuline 0]
			set propval [lindex $nuline 1]
			if {[string match $name $propname]} {
				if {[lsearch $nuvals $propval] >= 0} {
					if {$got} {
						append explan "\n" $propval " : " [lrange $nuline 2 end]
					} else {
						set explan $propval
						append explan " : " [lrange $nuline 2 end]
					}
					incr got
					if {$got >= $len} {
						close $zit
						Inf $explan
						return
					}
				}
			}
		}
	}
	close $zit
	if {$got} {
		Inf $explan
		return
	}
	Inf "No Explanation In Explanation File"	
}

#------ split up properies between commas and brackets

proc SplitProperty {val} {
	set val [string trim $val]
	set vals [split $val \ ,]
	set nuvals {}
	foreach item $vals {		;#	DEAL WITH COMMAS
		set item [string trim $item]
		if {[string length $item] > 0} {
			lappend nuvals $item
		}
	}
	set vals {}
	foreach item $nuvals {		;#	DEAL WITH STARS
		set len [string length $item]
		set n 0
		set nuitem ""
		set gotstar 0
		while {$n < $len} {
			set char [string index $item $n]
			if {[regexp {\*} $char]} {
				set gotstar 1
			} else {
				append nuitem $char
			}
			incr n
		}
		if {$gotstar} {
			set item $nuitem
		}
		if {[string length $item] <= 0} {
			continue
		}
		set j -1
		set k [string first "(" $item] 		;#	DEAL WITH BRACKETS
		if {$k >= 0}  {
			while {$k >= 0}  {
				if {$k > 0} {
					lappend nuitems [string range $item 0 [expr $k - 1]]
				}
				incr k
				if {$k >= $len} {
					break
				}
				set j [string first ")" $item] 
				if {$j >= 0} {
					if {$j > [expr $k + 1]} {
						lappend nuitems [string range $item $k [expr $j - 1]]
					}
					incr j
					if {$j < $len} {
						set item [string range $item $j end]
						set k [string first "(" $item] 
					} else {
						set j -1
						break
					}
				} else {
					lappend nuitems [string range $item $k end]
					break
				}
			}
			if {$j >= 0} { 
				lappend nuitems $item
			}
			if {[info exists nuitems]} {
				set vals [concat $vals $nuitems]
			}
		} else {
			lappend vals $item
		}
	}
	return $vals
}

#--- Separate key codes from tonic property

proc SplitTonicProperty {val} {
	set nuvals {}
	set issharp 0
	set len [string length $val]
	set n 0
	while {$n < $len} {
		set char [string index $val $n]
		if {[regexp {[A-G]} $char]} {
			if {[info exists nuval]} {
				lappend nuvals $nuval
			}
			set nuval $char
			set issharp 0
		} elseif [info exists nuval] {
			if {[string match "m" $char]} {
				append nuval $char
				lappend nuvals $nuval
				unset nuval
				set issharp 0
			} elseif {[string match "#" $char] || [string match "b" $char]} {
				if {!$issharp} {
					append nuval $char
					set issharp 1
				}	
			} elseif [info exists nuval] {
				lappend nuvals $nuval
				unset nuval
				set issharp 0
			}
		}
		incr n
	}
	if [info exists nuval] {
		lappend nuvals $nuval
	}
	return $nuvals
}

#--- Valid representation of key

proc ValidTonicString {val} {
	set val [string trim $val]
	set len [string length $val]
	if {$len <= 0} {
		return 0
	}
	set vals [SplitTonicProperty $val]
	foreach val $vals {
		set char [string index $val 0]
		if {![regexp {[A-G]} $char]} {
			return 0
		}
		if {$len == 1} {
			continue
		}
		set char [string index $val 1]
		if {![string compare "#" $char] || ![string compare "b" $char]} {
			if {$len == 2} {
				continue
			}
		} elseif {![string compare "m" $char]} {
			if {[$len == 2]} {
				continue
			} else {
				return 0
			}
		} else {
			return 0
		}
		set char [string index $val 2]
		if {![string compare "m" $char] && [$len == 3]} {
			continue
		}
		return 0
	}
	return 1
}

#--- Update Explanation for Property-Name on props table window

proc UpdateExplanationsFileForPropname {oldpropname newpropname} {
	global prexpldir evv
	set exfile [file join $prexpldir $evv(EXPROPS)]
	set tmpfnam $evv(DFLT_TMPFNAME)
	if {![file exists $exfile]} {
		return
	}
	if [catch {open $exfile "r"} zit] {
		Inf "Cannot Open Property Explanations File To Update It"	
		return
	}
	set rewritten 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		set line [split $line]
		catch {unset nuline}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend nuline $item
			}
		}
		if {[info exists nuline]} {
			set propname [lindex $nuline 0]
			if {[string match $propname $oldpropname]} {
				set nuline [lreplace $nuline 0 0 $newpropname]
				set rewritten 1
			}
			lappend nulines $nuline
		}
	}
	close $zit
	if {!$rewritten} {
		return
	}
	if [catch {open $tmpfnam "w"} zit] {
		Inf "Cannot Open File $tmpfnam To Write New Property Explanation Data"
		return
	}
	foreach line $nulines {
		puts $zit $line
	}
	close $zit
	if [catch {file delete $exfile} zit] {
		Inf "Cannot Delete Existing Explanations File"	
		catch {file delete $tmpfnam}
		return
	}
	if [catch {file rename $tmpfnam $exfile} zit] {
		set msg "Cannot Rename New Explanations File $tmpfnam To $exfile\n\n"
		append msg "Do This, Outside The Soundloom, Before Closing This Dialogue Box"
		Inf $msg
		catch {file delete $tmpfnam}
	}
}

#--- Update Explanation for Property on props table window

proc UpdateExplanationsFileForPropvalName {srcpropname oldpropvalname newpropvalname} {
	global evv prexpldir
	set exfile [file join $prexpldir $evv(EXPROPS)]
	set tmpfnam $evv(DFLT_TMPFNAME)
	if {![file exists $exfile]} {
		return
	}
	if [catch {open $exfile "r"} zit] {
		Inf "Cannot Open Property Explanations File To Update It"	
		return
	}
	set rewritten 0
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		set line [split $line]
		catch {unset nuline}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend nuline $item
			}
		}
		if {[info exists nuline]} {
			if {!$rewritten} {
				set propname [lindex $nuline 0]
				set propval  [lindex $nuline 1]
				if {[string match $propname $srcpropname] && [string match $propval $oldpropvalname]} {
					set nuline [lreplace $nuline 1 1 $newpropvalname]
					set rewritten 1
				}
			}
			lappend nulines $nuline
		}
	}
	close $zit
	if {!$rewritten} {
		return
	}
	if [catch {open $tmpfnam "w"} zit] {
		Inf "Cannot Open File $tmpfnam To Write New Property Explanation Data"
		return
	}
	foreach line $nulines {
		puts $zit $line
	}
	close $zit
	if [catch {file delete $exfile} zit] {
		Inf "Cannot Delete Existing Explanations File"	
		catch {file delete $tmpfnam}
		return
	}
	if [catch {file rename $tmpfnam $exfile} zit] {
		set msg "Cannot Rename New Explanations File $tmpfnam To $exfile\n\n"
		append msg "Do This, Outside The Soundloom, Before Closing This Dialogue Box"
		Inf $msg
		catch {file delete $tmpfnam}
	}
}

#--- Enter Explanation for Property on props table window

proc EnterPropExplanation {propval oldexplan} {
	global pr_pex pexpex pexstr evv
	set f .pex
	set pexpex {}
	if [Dlg_Create $f "PROPERTY EXPLANATION" "set pr_pex 0" -borderwidth $evv(BBDR)] {
		frame $f.a -borderwidth $evv(BBDR)
		button $f.a.q -text "Abandon"	    -command {set pr_pex 0} -width 13 -highlightbackground [option get . background {}]
		button $f.a.k -text "Keep New Text" -command {set pr_pex 1} -width 13 -highlightbackground [option get . background {}]
		pack $f.a.k -side left
		pack $f.a.q -side right
		pack $f.a -side top -fill x -expand true -pady 2
		entry $f.b -textvariable pexstr -width 120
		pack $f.b -side top -fill x -expand true -pady 2 -pady 4
		wm resizable $f 1 1
		bind $f <Escape> {set pr_pex 0}
		bind $f <Return> {set pr_pex 1}
	}
	set pexstr ""
	set n 0
	foreach item $oldexplan {
		append pexstr " " $item
		incr n
	}
	if {$n > 0} {
		$f.a.q config -text "Keep Original"
	}
	set pr_pex 0
	set finished 0
	if {[regexp {^[\^]+} $propval]} {
		wm title $f "PROPERTY EXPLANATION FOR PROPERTY NAME [string range $propval 1 end]"
	} else {
		wm title $f "PROPERTY EXPLANATION FOR $propval"
	}
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_pex $f
	while {!$finished} {
		tkwait variable pr_pex
		catch {unset nupex}
		if {$pr_pex} {
			set pexstr [string trim $pexstr]
			if {[string length $pexstr] <= 0} {
				Inf "No Explanation Entered"	
				continue
			}
			if {[regexp {[\"\{\}\[\]\^]} $pexstr]} {
				Inf "Invalid Character Used: Avoid \" \{ \} \[ \]"	
				continue
			}
			set pexpex [split $pexstr]
			foreach item $pexpex {
				set item [string trim $item]
				if {[string length $item] > 0} {
					lappend nupex $item
				}
			}
			if {![info exists nupex]} {
				Inf "No Explanation Entered"	
				continue
			}
			set pexpex $nupex
		}
		break
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
	return $pexpex
}

########################################
# ENTERING, CODING AND READING RHYTHMS #
########################################
#
#	CODING
#	wN = N crotchets duration single-note
#	xN = N quavers duration single-note
#
#	OTHERWISE
#
#	a duple-time quavers
#	b triple-time quavers
#	c triple-time semiquavers
#	d triplets crotchets
#	e triplets quavers
#	f semiquavers amongst triplet quavers
#
#	0 = WHOLE BEAT
#	   duple				triple
#	1 = X---X---			X---X---X---
#	2 = XX----x-			XX------X---
#	3 = x-XX----			X---XX------
#	4 = X---x-x-			Xx----x-X---
#	5 = x-x-X---			x-Xx----X---
#	6 = x-X---x-			X--XX-----x-
#	7 = x-x-x-x-			XX----X---x-
#	8 =						x-X---Xx----
#
# There are some 9s, for odd groups (e.g. 2 beamed semiqs)
# a9 = beamed squaver pair
# b9 = standalone quaver
# c9 = standalone squaver
# z0 is standalone dotted squaver
# ,.: are crotchet, quav, squaver rests | = barline
#


#------ Establish interactive rhythm-notation display

proc EstablishRhythmPropDisplay {inrhfnam fromsnd} {
	global pr_propryt rhencoding rhenscreen rhencode rh_encoding nuaddpsnd nuaddpval in_rhfnam readonlyfg readonlybg evv
 
	set f .rhypropscreen
	set rhencode $f
	set rh_encoding ""
	if {$inrhfnam == "0"} {
		if {$fromsnd} {		;#	PROCESS CALLED FROM PROP-ENTRY FOR A SOUNDFILE AT nuaddpsnd
			set orig_code $nuaddpval
			if {[string match $orig_code $evv(NULL_PROP)]} {
				set orig_code ""
			}
			set inrhfnam $nuaddpsnd
			set fromprops 1
		} else {			;#	PROCESS CALLED TO CREATE TIME-CUES: NO SNDFILE INVOLVED
			set inrhfnam ""
			set orig_code ""
			set fromprops 0
		}
	} else {				;#	PROCESS ASSOCIATED WITH SPECIFIC SNDFILE
		set orig_code ""
		set fromprops 0
	}
	set in_rhfnam $inrhfnam
	if [Dlg_Create $f "RHYTHM ENCODER" "set pr_propryt 0" -width 48 -borderwidth $evv(SBDR)] {

		set b [frame $f.btns -borderwidth 0]
 
		entry  $b.val	  -textvariable rhencoding -width 24 -state readonly -fg $readonlyfg -readonlybackground $readonlybg
		button $b.abdn 	  -text "Close" 		  			-command "set pr_propryt 0" -highlightbackground [option get . background {}]
		button $b.save 	  -text "Save Values" 				-command "set pr_propryt 1" -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $b.restart -text "Start Again" 				-command "set pr_propryt 2" -highlightbackground [option get . background {}]
		button $b.baktrak -text "Remove last value entered" -command "set pr_propryt 3" -highlightbackground [option get . background {}]
		button $b.double  -text "Double/Halve vals"         -command "set pr_propryt 4" -highlightbackground [option get . background {}]
		button $b.dum -text "" -bd 0 -command {} -width 12 -state disabled -bg [option get . background {} ] -highlightbackground [option get . background {}]
		if {$fromsnd} {
			button $b.play    -text "SndView Only" -command {SnackDisplay 0 $evv(SN_FROM_PROPSRHYTHM_NO_OUTPUT) 0 $in_rhfnam} -bg $evv(SNCOLOROFF) -width 12  -highlightbackground [option get . background {}]
			button $b.sview   -text "Play Source" -command {PlaySndfile $in_rhfnam 0} -bg $evv(HELP) -width 12 -highlightbackground [option get . background {}]
		}

		pack $b.abdn -side right -padx 2
		pack $b.save $b.val	$b.baktrak $b.double $b.restart $b.dum -side left -padx 2
		if {$fromsnd} {
			pack $b.play $b.sview -side left -padx 2
		}
		#	CANVAS AND VALUE LISTING
		set rhenscreen [canvas $f.c -height 600 -width 800 -borderwidth 0 \
			-highlightthickness 1 -highlightbackground $evv(SPECIAL)]
		pack $f.btns -side top -fill x 
		pack $f.c -side left -fill both

		# SEMIBREVE , MINIM
		
		set semibreve  [$rhenscreen create oval 30  30 38  36 -fill [option get . background {}] -outline $evv(POINT) -tag beats] 
		set minim      [$rhenscreen create oval 70  30 78  36 -fill [option get . background {}] -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 78  33 78  13 -width 1 -fill $evv(POINT)

		# QUAVER REST

		$rhenscreen create oval 129  29 131  31 -fill $evv(POINT) -tag beats -outline $evv(POINT)
		$rhenscreen create line 130  30 140  20 128  20 -tag beats -fill $evv(POINT)

		# SEMIQUAVER REST

		$rhenscreen create oval 169  29 171  31 -fill $evv(POINT) -tag beats -outline $evv(POINT)
		$rhenscreen create line 170  30 180  20 168 20 -tag beats -fill $evv(POINT)
		$rhenscreen create line 170  23 177  23 -tag beats -fill $evv(POINT)

		# CROTCHET REST

		$rhenscreen create line 210 36 210 32 213 29 210 29 215 26 210 26 210 19 -tag beats -fill $evv(POINT)

		$rhenscreen create text 370 36  -text "BARLINE" -font {helvetica 9 normal}  -fill $evv(POINT)

		# DOTTED SEMIBREVE , DOTTED MINIM

		set dsemibreve  [$rhenscreen create oval 30 60 38 66 -fill [option get . background {}] -outline $evv(POINT) -tag beats] 
		set dminim      [$rhenscreen create oval 70 60 78 66 -fill [option get . background {}] -outline $evv(POINT) -tag beats] 

		$rhenscreen create line 78 63 78 43 -width 1 -fill $evv(POINT)
		$rhenscreen create oval 41 63 43 65 -fill $evv(POINT) -outline $evv(POINT)
		$rhenscreen create oval 81 63 83 65 -fill $evv(POINT) -outline $evv(POINT)

######## QUAVER BEAMS

		set bmquaver1a  [$rhenscreen create oval 30 130 38 136 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set bmquaver1b  [$rhenscreen create oval 45 130 53 136 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 38 133 38 116 -width 1 -fill $evv(POINT)
		$rhenscreen create line 53 133 53 116 -width 1 -fill $evv(POINT)
		$rhenscreen create line 39 116 53 116 -width 2 -fill $evv(POINT)

		set bmquaver2a  [$rhenscreen create oval 70 130 78 136 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set bmquaver2b  [$rhenscreen create oval 90 130 98 136 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 78 133 78 116 -width 1 -fill $evv(POINT)
		$rhenscreen create line 98 133 98 116 -width 1 -fill $evv(POINT)
		$rhenscreen create line 79 116 98 116 -width 2 -fill $evv(POINT)

		$rhenscreen create oval 81 133 83 135 -fill $evv(POINT)
		$rhenscreen create line 94 119 98 119 -width 2 -fill $evv(POINT)

		set bmquaver3a  [$rhenscreen create oval 110 130 118 136 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set bmquaver3b  [$rhenscreen create oval 120 130 128 136 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 118 133 118 116 -width 1 -fill $evv(POINT)
		$rhenscreen create line 128 133 128 116 -width 1 -fill $evv(POINT)
		$rhenscreen create line 119 116 128 116 -width 2 -fill $evv(POINT)

		$rhenscreen create oval 131 133 133 135 -fill $evv(POINT)
		$rhenscreen create line 119 119 122 119 -width 2 -fill $evv(POINT)

		set bmquaver4a  [$rhenscreen create oval 150 130 158 136 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set bmquaver4b  [$rhenscreen create oval 165 130 173 136 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set bmquaver4c  [$rhenscreen create oval 175 130 183 136 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 158 133 158 116 -width 1 -fill $evv(POINT)
		$rhenscreen create line 173 133 173 116 -width 1 -fill $evv(POINT)
		$rhenscreen create line 183 133 183 116 -width 1 -fill $evv(POINT)
		$rhenscreen create line 159 116 183 116 -width 2 -fill $evv(POINT)
		$rhenscreen create line 173 119 183 119 -width 2 -fill $evv(POINT)

		set bmquaver5a  [$rhenscreen create oval 200 130 208 136 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set bmquaver5b  [$rhenscreen create oval 210 130 218 136 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set bmquaver5c  [$rhenscreen create oval 225 130 233 136 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 208 133 208 116 -width 1 -fill $evv(POINT)
		$rhenscreen create line 218 133 218 116 -width 1 -fill $evv(POINT)
		$rhenscreen create line 233 133 233 116 -width 1 -fill $evv(POINT)
		$rhenscreen create line 209 116 233 116 -width 2 -fill $evv(POINT)
		$rhenscreen create line 209 119 218 119 -width 2 -fill $evv(POINT)

		set bmquaver6a  [$rhenscreen create oval 250 130 258 136 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set bmquaver6b  [$rhenscreen create oval 260 130 268 136 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set bmquaver6c  [$rhenscreen create oval 275 130 283 136 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 258 133 258 116 -width 1 -fill $evv(POINT)
		$rhenscreen create line 268 133 268 116 -width 1 -fill $evv(POINT)
		$rhenscreen create line 283 133 283 116 -width 1 -fill $evv(POINT)
		$rhenscreen create line 259 116 283 116 -width 2 -fill $evv(POINT)
		$rhenscreen create line 259 119 262 119 -width 2 -fill $evv(POINT)
		$rhenscreen create line 279 119 283 119 -width 2 -fill $evv(POINT)


		set bmsquaver8a  [$rhenscreen create oval 300 130 308 136 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set bmsquaver8b  [$rhenscreen create oval 310 130 318 136 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set bmsquaver8c  [$rhenscreen create oval 320 130 328 136 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set bmsquaver8c  [$rhenscreen create oval 330 130 338 136 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 308 133 308 116 -width 1 -fill $evv(POINT)
		$rhenscreen create line 318 133 318 116 -width 1 -fill $evv(POINT)
		$rhenscreen create line 328 133 328 116 -width 1 -fill $evv(POINT)
		$rhenscreen create line 338 133 338 116 -width 1 -fill $evv(POINT)
		$rhenscreen create line 309 116 338 116 -width 2 -fill $evv(POINT)
		$rhenscreen create line 309 113 338 113 -width 2 -fill $evv(POINT)

######### CROTCHET

		set crotchet   [$rhenscreen create oval 370 130 378 136 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 378 133 378 113 -width 1 -fill $evv(POINT)

######### 4 QUAVER GROUP

		set bmquaver8a  [$rhenscreen create oval 430 130 438 136 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set bmquaver8b  [$rhenscreen create oval 440 130 448 136 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set bmquaver8c  [$rhenscreen create oval 450 130 458 136 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set bmquaver8c  [$rhenscreen create oval 460 130 468 136 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 438 133 438 116 -width 1 -fill $evv(POINT)
		$rhenscreen create line 448 133 448 116 -width 1 -fill $evv(POINT)
		$rhenscreen create line 458 133 458 116 -width 1 -fill $evv(POINT)
		$rhenscreen create line 468 133 468 116 -width 1 -fill $evv(POINT)
		$rhenscreen create line 439 116 468 116 -width 2 -fill $evv(POINT)

								######## SEMIQUAVER DUPLET

		set bmsquaver8a  [$rhenscreen create oval 30 175 38 181 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set bmsquaver8b  [$rhenscreen create oval 40 175 48 181 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 

		$rhenscreen create line 38 178 38 161 -width 1 -fill $evv(POINT)
		$rhenscreen create line 48 178 48 161 -width 1 -fill $evv(POINT)
		$rhenscreen create line 39 161 48 161 -width 2 -fill $evv(POINT)
		$rhenscreen create line 39 164 48 164 -width 2 -fill $evv(POINT)


								######## QUAVER TRIPLET BEAMS

		set tbmquaver1a  [$rhenscreen create oval 30 220 38 226 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmquaver1b  [$rhenscreen create oval 45 220 53 226 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmquaver1c  [$rhenscreen create oval 60 220 68 226 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 38 223 38 203 -width 1 -fill $evv(POINT)
		$rhenscreen create line 53 223 53 203 -width 1 -fill $evv(POINT)
		$rhenscreen create line 68 223 68 203 -width 1 -fill $evv(POINT)
		$rhenscreen create line 39 203 68 203 -width 2 -fill $evv(POINT)

		set tbmquaver2a  [$rhenscreen create oval 85  220 93  226 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmquaver2b  [$rhenscreen create oval 115 220 123 226 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 93  223 93  203 -width 1 -fill $evv(POINT)
		$rhenscreen create line 123 223 123 203 -width 1 -fill $evv(POINT)
		$rhenscreen create line 123 203 128 210 -width 1 -fill $evv(POINT)
		$rhenscreen create arc  83  193 133 243 -start 125 -extent -70 -style arc -outline $evv(POINT) -width 1

		set tbmquaver3a  [$rhenscreen create oval 140 220 148 226 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmquaver3b  [$rhenscreen create oval 155 220 163 226 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 148 223 148 203 -width 1 -fill $evv(POINT)
		$rhenscreen create line 163 223 163 203 -width 1 -fill $evv(POINT)
		$rhenscreen create line 148 203 153 210 -width 1 -fill $evv(POINT)
		$rhenscreen create arc  133 193 188 243 -start 125 -extent -70 -style arc -outline $evv(POINT) -width 1

		set tbmquaver4a  [$rhenscreen create oval 195 220 203 226 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmquaver4b  [$rhenscreen create oval 215 220 223 226 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmquaver4c  [$rhenscreen create oval 225 220 233 226 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 203 223 203 203 -width 1 -fill $evv(POINT)
		$rhenscreen create line 223 223 223 203 -width 1 -fill $evv(POINT)
		$rhenscreen create line 233 223 233 203 -width 1 -fill $evv(POINT)
		$rhenscreen create line 204 203 233 203 -width 2 -fill $evv(POINT)

		$rhenscreen create oval 206 222 208 224 -fill $evv(POINT)
		$rhenscreen create line 218 206 223 206 -width 2 -fill $evv(POINT)

		set tbmquaver5a  [$rhenscreen create oval 250 220 258 226 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmquaver5b  [$rhenscreen create oval 260 220 268 226 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmquaver5c  [$rhenscreen create oval 280 220 288 226 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 258 223 258 203 -width 1 -fill $evv(POINT)
		$rhenscreen create line 268 223 268 203 -width 1 -fill $evv(POINT)
		$rhenscreen create line 288 223 288 203 -width 1 -fill $evv(POINT)
		$rhenscreen create line 259 203 288 203 -width 2 -fill $evv(POINT)

		$rhenscreen create oval 271 222 273 224 -fill $evv(POINT) -outline $evv(POINT)
		$rhenscreen create line 259 206 263 206 -width 2 -fill $evv(POINT)

		set tbmquaver6a  [$rhenscreen create oval 305 220 313 226 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmquaver6b  [$rhenscreen create oval 320 220 328 226 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmquaver6c  [$rhenscreen create oval 340 220 348 226 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 313 223 313 203 -width 1 -fill $evv(POINT)
		$rhenscreen create line 328 223 328 203 -width 1 -fill $evv(POINT)
		$rhenscreen create line 348 223 348 203 -width 1 -fill $evv(POINT)
		$rhenscreen create line 314 203 348 203 -width 2 -fill $evv(POINT)

		$rhenscreen create oval 331 222 333 224 -fill $evv(POINT)
		$rhenscreen create line 343 206 348 206 -width 2 -fill $evv(POINT)

		set tbmquaver7a  [$rhenscreen create oval 365 220 373 226 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmquaver7b  [$rhenscreen create oval 385 220 393 226 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmquaver7c  [$rhenscreen create oval 400 220 408 226 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 373 223 373 203 -width 1 -fill $evv(POINT)
		$rhenscreen create line 393 223 393 203 -width 1 -fill $evv(POINT)
		$rhenscreen create line 408 223 408 203 -width 1 -fill $evv(POINT)
		$rhenscreen create line 374 203 408 203 -width 2 -fill $evv(POINT)

		$rhenscreen create oval 376 222 378 224 -fill $evv(POINT)
		$rhenscreen create line 403 206 408 206 -width 2 -fill $evv(POINT)

		set tbmquaver8a  [$rhenscreen create oval 425 220 433 226 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmquaver8b  [$rhenscreen create oval 435 220 443 226 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmquaver8c  [$rhenscreen create oval 450 220 458 226 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 433 223 433 203 -width 1 -fill $evv(POINT)
		$rhenscreen create line 443 223 443 203 -width 1 -fill $evv(POINT)
		$rhenscreen create line 458 223 458 203 -width 1 -fill $evv(POINT)
		$rhenscreen create line 434 203 458 203 -width 2 -fill $evv(POINT)

		$rhenscreen create oval 461 222 463 224 -fill $evv(POINT) -outline $evv(POINT)
		$rhenscreen create line 434 206 438 206 -width 2 -fill $evv(POINT)

######### DOTTED CROTCHET

		set dcrotchet   [$rhenscreen create oval 485 220 493 226 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 493 223 493 203 -width 1 -fill $evv(POINT)
		$rhenscreen create oval 496 223 498 225 -fill $evv(POINT) -outline $evv(POINT)

######### SINGLE QUAVER

		set quaver     [$rhenscreen create oval 537 220 545 226 -fill $evv(POINT) -tag beats -outline $evv(POINT)] 
		$rhenscreen create line 545 223 545 203 -width 1 -fill $evv(POINT)
		$rhenscreen create line 545 203 550 208 -width 1 -fill $evv(POINT)

######## SEMIQUAVER TRIPLET BEAMS

		set tbmsquaver1a  [$rhenscreen create oval 30 280 38 286 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmsquaver1b  [$rhenscreen create oval 45 280 53 286 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmsquaver1c  [$rhenscreen create oval 60 280 68 286 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 38 283 38 260 -width 1 -fill $evv(POINT)
		$rhenscreen create line 53 283 53 260 -width 1 -fill $evv(POINT)
		$rhenscreen create line 68 283 68 260 -width 1 -fill $evv(POINT)
		$rhenscreen create line 39 263 68 263 -width 2 -fill $evv(POINT)
		$rhenscreen create line 39 260 68 260 -width 2 -fill $evv(POINT)

		set tbmsquaver2a  [$rhenscreen create oval 85  280 93  286 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmsquaver2b  [$rhenscreen create oval 115 280 123 286 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 93  283 93  260 -width 1 -fill $evv(POINT)
		$rhenscreen create line 123 283 123 260 -width 1 -fill $evv(POINT)
		$rhenscreen create line 94  260 123 260 -width 2 -fill $evv(POINT)
		$rhenscreen create line 118 263 123 263 -width 2 -fill $evv(POINT)

		set tbmsquaver3a  [$rhenscreen create oval 140 280 148 286 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmsquaver3b  [$rhenscreen create oval 155 280 163 286 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 148 283 148 260 -width 1 -fill $evv(POINT)
		$rhenscreen create line 163 283 163 260 -width 1 -fill $evv(POINT)
		$rhenscreen create line 149 260 163 260 -width 2 -fill $evv(POINT)
		$rhenscreen create line 149 263 153 263 -width 2 -fill $evv(POINT)

		set tbmsquaver4a  [$rhenscreen create oval 195 280 203 286 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmsquaver4b  [$rhenscreen create oval 215 280 223 286 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmsquaver4c  [$rhenscreen create oval 225 280 233 286 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 203 283 203 260 -width 1 -fill $evv(POINT)
		$rhenscreen create line 223 283 223 260 -width 1 -fill $evv(POINT)
		$rhenscreen create line 233 283 233 260 -width 1 -fill $evv(POINT)
		$rhenscreen create line 204 263 233 263 -width 2 -fill $evv(POINT)
		$rhenscreen create line 204 260 233 260 -width 2 -fill $evv(POINT)

		$rhenscreen create oval 206 282 208 284 -fill $evv(POINT) -outline $evv(POINT)
		$rhenscreen create line 218 266 223 266 -width 2 -fill $evv(POINT)

		set tbmsquaver5a  [$rhenscreen create oval 250 280 258 286 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmsquaver5b  [$rhenscreen create oval 260 280 268 286 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmsquaver5c  [$rhenscreen create oval 280 280 288 286 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 258 283 258 260 -width 1 -fill $evv(POINT)
		$rhenscreen create line 268 283 268 260 -width 1 -fill $evv(POINT)
		$rhenscreen create line 288 283 288 260 -width 1 -fill $evv(POINT)
		$rhenscreen create line 259 263 288 263 -width 2 -fill $evv(POINT)
		$rhenscreen create line 259 260 288 260 -width 2 -fill $evv(POINT)

		$rhenscreen create oval 271 282 273 284 -fill $evv(POINT) -outline $evv(POINT)
		$rhenscreen create line 259 266 263 266 -width 2 -fill $evv(POINT)

		set tbmsquaver6a  [$rhenscreen create oval 305 280 313 286 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmsquaver6b  [$rhenscreen create oval 320 280 328 286 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmsquaver6c  [$rhenscreen create oval 340 280 348 286 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 313 283 313 260 -width 1 -fill $evv(POINT)
		$rhenscreen create line 328 283 328 260 -width 1 -fill $evv(POINT)
		$rhenscreen create line 348 283 348 260 -width 1 -fill $evv(POINT)
		$rhenscreen create line 314 263 348 263 -width 2 -fill $evv(POINT)
		$rhenscreen create line 314 260 348 260 -width 2 -fill $evv(POINT)

		$rhenscreen create oval 331 282 333 284 -fill $evv(POINT) -outline $evv(POINT)
		$rhenscreen create line 343 266 348 266 -width 2 -fill $evv(POINT)

		set tbmsquaver7a  [$rhenscreen create oval 365 280 373 286 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmsquaver7b  [$rhenscreen create oval 385 280 393 286 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmsquaver7c  [$rhenscreen create oval 400 280 408 286 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 373 283 373 260 -width 1 -fill $evv(POINT)
		$rhenscreen create line 393 283 393 260 -width 1 -fill $evv(POINT)
		$rhenscreen create line 408 283 408 260 -width 1 -fill $evv(POINT)
		$rhenscreen create line 374 263 408 263 -width 2 -fill $evv(POINT)
		$rhenscreen create line 374 260 408 260 -width 2 -fill $evv(POINT)

		$rhenscreen create oval 376 282 378 284 -fill $evv(POINT) -outline $evv(POINT)
		$rhenscreen create line 403 266 408 266 -width 2 -fill $evv(POINT)

		set tbmsquaver8a  [$rhenscreen create oval 425 280 433 286 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmsquaver8b  [$rhenscreen create oval 435 280 443 286 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmsquaver8c  [$rhenscreen create oval 450 280 458 286 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 433 283 433 260 -width 1 -fill $evv(POINT)
		$rhenscreen create line 443 283 443 260 -width 1 -fill $evv(POINT)
		$rhenscreen create line 458 283 458 260 -width 1 -fill $evv(POINT)
		$rhenscreen create line 434 263 458 263 -width 2 -fill $evv(POINT)
		$rhenscreen create line 434 260 458 260 -width 2 -fill $evv(POINT)

		$rhenscreen create oval 461 282 463 284 -fill $evv(POINT) -outline $evv(POINT)
		$rhenscreen create line 434 266 438 266 -width 2 -fill $evv(POINT)

####### DOTTED QUAVER, SEMIQUAVER, DOTTED SEMIQUAVER

		set dquaver     [$rhenscreen create oval 485 280 493 286 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 493 283 493 263 -width 1 -fill $evv(POINT)
		$rhenscreen create oval 496 283 498 285 -fill $evv(POINT) -outline $evv(POINT)
		$rhenscreen create line 493 263 498 270 -width 1 -fill $evv(POINT)

		set semiquaver [$rhenscreen create oval 537 280 545 286 -fill $evv(POINT) -tag beats -outline $evv(POINT)] 
		$rhenscreen create line 545 283 545 263 -width 1 -fill $evv(POINT)
		$rhenscreen create line 545 263 550 268 -width 1 -fill $evv(POINT)
		$rhenscreen create line 545 266 550 271 -width 1 -fill $evv(POINT)

		set dsemiquaver [$rhenscreen create oval 557 280 565 286 -fill $evv(POINT) -tag beats -outline $evv(POINT)] 
		$rhenscreen create line 565 283 565 263 -width 1 -fill $evv(POINT)
		$rhenscreen create line 565 263 570 268 -width 1 -fill $evv(POINT)
		$rhenscreen create line 565 266 570 271 -width 1 -fill $evv(POINT)
		$rhenscreen create oval 568 283 570 285 -fill $evv(POINT) -outline $evv(POINT)

###### 3rd-NOTE GROUPS. CROTCHETS

		set tbmtcrotch1a  [$rhenscreen create oval 30 350 38 356 -fill $evv(POINT) -tag beats -outline $evv(POINT)] 
		set tbmtcrotch1b  [$rhenscreen create oval 45 350 53 356 -fill $evv(POINT) -tag beats -outline $evv(POINT)] 
		set tbmtcrotch1c  [$rhenscreen create oval 60 350 68 356 -fill $evv(POINT) -tag beats -outline $evv(POINT)] 
		$rhenscreen create line 38 353 38 333 -width 1 -fill $evv(POINT)
		$rhenscreen create line 53 353 53 333 -width 1 -fill $evv(POINT)
		$rhenscreen create line 68 353 68 333 -width 1 -fill $evv(POINT)
		$rhenscreen create arc  28 315 78 351 -start 125 -extent -70 -style arc -outline $evv(POINT) -width 1
		$rhenscreen create text 54 325 -text "3" -font {helvetica 9 normal}  -fill $evv(POINT)

		set tbmtcrotch2a  [$rhenscreen create oval 85  350 93  356 -fill [option get . background {}] -outline $evv(POINT) -tag beats] 
		set tbmtcrotch2b  [$rhenscreen create oval 115 350 123 356 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 93  353 93  333 -width 1 -fill $evv(POINT)
		$rhenscreen create line 123 353 123 333 -width 1 -fill $evv(POINT)
		$rhenscreen create arc  83 315 133 351 -start 125 -extent -70 -style arc -outline $evv(POINT) -width 1
		$rhenscreen create text 108 325 -text "3" -font {helvetica 9 normal}  -fill $evv(POINT)

		set tbmtcrotch3a  [$rhenscreen create oval 140  350 148 356 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmtcrotch3b  [$rhenscreen create oval 155 350  163 356 -fill [option get . background {}] -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 148 353 148 333 -width 1 -fill $evv(POINT)
		$rhenscreen create line 163 353 163 333 -width 1 -fill $evv(POINT)
		$rhenscreen create arc  138 315 188 351 -start 125 -extent -70 -style arc -outline $evv(POINT) -width 1
		$rhenscreen create text 163 325 -text "3" -font {helvetica 9 normal}  -fill $evv(POINT)

		set tbmtcrotch4a  [$rhenscreen create oval 195 350 203 356 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmtcrotch4b  [$rhenscreen create oval 215 350 223 356 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmtcrotch4c  [$rhenscreen create oval 225 350 233 356 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 203 353 203 333 -width 1 -fill $evv(POINT)
		$rhenscreen create line 223 353 223 333 -width 1 -fill $evv(POINT)
		$rhenscreen create line 233 353 233 333 -width 1 -fill $evv(POINT)
		$rhenscreen create line 223 333 228 340 -width 1 -fill $evv(POINT)

		$rhenscreen create oval 206 352 208 354 -fill $evv(POINT) -outline $evv(POINT)

		$rhenscreen create arc  193 315 243 351 -start 125 -extent -70 -style arc -outline $evv(POINT) -width 1
		$rhenscreen create text 218 325 -text "3" -font {helvetica 9 normal}  -fill $evv(POINT)

		set tbmtcrotch5a  [$rhenscreen create oval 250 350 258 356 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmtcrotch5b  [$rhenscreen create oval 260 350 268 356 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmtcrotch5c  [$rhenscreen create oval 280 350 288 356 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 258 353 258 333 -width 1 -fill $evv(POINT)
		$rhenscreen create line 268 353 268 333 -width 1 -fill $evv(POINT)
		$rhenscreen create line 288 353 288 333 -width 1 -fill $evv(POINT)
		$rhenscreen create line 258 333 263 340 -width 1 -fill $evv(POINT)

		$rhenscreen create oval 271 352 273 354 -fill $evv(POINT) -outline $evv(POINT)
		$rhenscreen create arc  248 315 298 351 -start 125 -extent -70 -style arc -outline $evv(POINT) -width 1
		$rhenscreen create text 273 325 -text "3" -font {helvetica 9 normal}  -fill $evv(POINT)

		set tbmtcrotch6a  [$rhenscreen create oval 305 350 313 356 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmtcrotch6b  [$rhenscreen create oval 320 350 328 356 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmtcrotch6c  [$rhenscreen create oval 340 350 348 356 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 313 353 313 333 -width 1 -fill $evv(POINT)
		$rhenscreen create line 328 353 328 333 -width 1 -fill $evv(POINT)
		$rhenscreen create line 348 353 348 333 -width 1 -fill $evv(POINT)
		$rhenscreen create line 348 333 353 340 -width 1 -fill $evv(POINT)

		$rhenscreen create oval 331 352 333 354 -fill $evv(POINT) -outline $evv(POINT)
		$rhenscreen create arc  303 315 353 351 -start 125 -extent -70 -style arc -outline $evv(POINT) -width 1
		$rhenscreen create text 328 325 -text "3" -font {helvetica 9 normal}  -fill $evv(POINT)

		set tbmtcrotch7a  [$rhenscreen create oval 365 350 373 356 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmtcrotch7b  [$rhenscreen create oval 385 350 393 356 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmtcrotch7c  [$rhenscreen create oval 400 350 408 356 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 373 353 373 333 -width 1 -fill $evv(POINT)
		$rhenscreen create line 393 353 393 333 -width 1 -fill $evv(POINT)
		$rhenscreen create line 408 353 408 333 -width 1 -fill $evv(POINT)
		$rhenscreen create line 408 333 413 340 -width 1 -fill $evv(POINT)

		$rhenscreen create oval 376 352 378 354 -fill $evv(POINT) -outline $evv(POINT)
		$rhenscreen create arc  363 315 413 351 -start 125 -extent -70 -style arc -outline $evv(POINT) -width 1
		$rhenscreen create text 388 325 -text "3" -font {helvetica 9 normal}  -fill $evv(POINT)

		set tbmtcrotch8a  [$rhenscreen create oval 425 350 433 356 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmtcrotch8b  [$rhenscreen create oval 435 350 443 356 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmtcrotch8c  [$rhenscreen create oval 450 350 458 356 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 433 353 433 333 -width 1 -fill $evv(POINT)
		$rhenscreen create line 443 353 443 333 -width 1 -fill $evv(POINT)
		$rhenscreen create line 458 353 458 333 -width 1 -fill $evv(POINT)
		$rhenscreen create line 433 333 438 340 -width 1 -fill $evv(POINT)

		$rhenscreen create oval 461 352 463 354 -fill $evv(POINT) -outline $evv(POINT)
		$rhenscreen create arc  423 315 473 351 -start 125 -extent -70 -style arc -outline $evv(POINT) -width 1
		$rhenscreen create text 448 325 -text "3" -font {helvetica 9 normal}  -fill $evv(POINT)

		set tbmtquaver8b  [$rhenscreen create oval 500 350 508 356 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmtquaver8c  [$rhenscreen create oval 515 350 523 356 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 507 353 507 333 -width 1 -fill $evv(POINT)
		$rhenscreen create line 522 353 522 333 -width 1 -fill $evv(POINT)

		set x0 485
		set x3 [expr $x0 + 3]
		set x5 [expr $x0 + 5]
		set y0 356
		set y4 [expr $y0 - 4]
		set y7 [expr $y0 - 7]
		set y10 [expr $y0 - 10]
		set y15 [expr $y0 - 15]
		$rhenscreen create line $x0 $y0 $x0 $y4 $x3 $y7 $x0 $y7 $x5 $y10 $x0 $y10 $x0 $y15 -tag beats -fill $evv(POINT)

		$rhenscreen create oval 521 352 523 354 -fill $evv(POINT) -outline $evv(POINT)
		$rhenscreen create arc  483 315 533 351 -start 125 -extent -70 -style arc -outline $evv(POINT) -width 1
		$rhenscreen create text 508 325 -text "3" -font {helvetica 9 normal}  -fill $evv(POINT)

###### 3rd-NOTE GROUPS QUAVERS

		set tbmtquaver1a  [$rhenscreen create oval 30 410 38 416 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmtquaver1b  [$rhenscreen create oval 45 410 53 416 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmtquaver1c  [$rhenscreen create oval 60 410 68 416 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 38 413 38 393 -width 1 -fill $evv(POINT)
		$rhenscreen create line 53 413 53 393 -width 1 -fill $evv(POINT)
		$rhenscreen create line 68 413 68 393 -width 1 -fill $evv(POINT)
		$rhenscreen create line 39 393 68 393 -width 2 -fill $evv(POINT)
		$rhenscreen create arc  28 375 78 411 -start 125 -extent -70 -style arc -outline $evv(POINT) -width 1
		$rhenscreen create text 54 385 -text "3" -font {helvetica 9 normal}  -fill $evv(POINT)

		set tbmtquaver2a  [$rhenscreen create oval 85  410 93  416 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmtquaver2b  [$rhenscreen create oval 115 410 123 416 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 93  413 93  393 -width 1 -fill $evv(POINT)
		$rhenscreen create line 123 413 123 393 -width 1 -fill $evv(POINT)
		$rhenscreen create line 123 393 128 400 -width 1 -fill $evv(POINT)
		$rhenscreen create arc  83 375 133 411 -start 125 -extent -70 -style arc -outline $evv(POINT) -width 1
		$rhenscreen create text 108 385 -text "3" -font {helvetica 9 normal}  -fill $evv(POINT)

		set tbmtquaver3a  [$rhenscreen create oval 140  410 148 416 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmtquaver3b  [$rhenscreen create oval 155 410  163 416 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 148 413 148 393 -width 1 -fill $evv(POINT)
		$rhenscreen create line 163 413 163 393 -width 1 -fill $evv(POINT)
		$rhenscreen create line 148 393 153 400 -width 1 -fill $evv(POINT)
		$rhenscreen create arc  138 375 188 411 -start 125 -extent -70 -style arc -outline $evv(POINT) -width 1
		$rhenscreen create text 163 385 -text "3" -font {helvetica 9 normal}  -fill $evv(POINT)

		set tbmtquaver4a  [$rhenscreen create oval 195 410 203 416 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmtquaver4b  [$rhenscreen create oval 215 410 223 416 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmtquaver4c  [$rhenscreen create oval 225 410 233 416 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 203 413 203 393 -width 1 -fill $evv(POINT)
		$rhenscreen create line 223 413 223 393 -width 1 -fill $evv(POINT)
		$rhenscreen create line 233 413 233 393 -width 1 -fill $evv(POINT)
		$rhenscreen create line 204 393 233 393 -width 2 -fill $evv(POINT)

		$rhenscreen create oval 206 412 208 414 -fill $evv(POINT) -outline $evv(POINT)
		$rhenscreen create line 218 396 222 396 -width 2 -fill $evv(POINT)
		$rhenscreen create arc  193 375 243 411 -start 125 -extent -70 -style arc -outline $evv(POINT) -width 1
		$rhenscreen create text 218 385 -text "3" -font {helvetica 9 normal}  -fill $evv(POINT)

		set tbmtquaver5a  [$rhenscreen create oval 250 410 258 416 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmtquaver5b  [$rhenscreen create oval 260 410 268 416 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmtquaver5c  [$rhenscreen create oval 280 410 288 416 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 258 413 258 393 -width 1 -fill $evv(POINT)
		$rhenscreen create line 268 413 268 393 -width 1 -fill $evv(POINT)
		$rhenscreen create line 288 413 288 393 -width 1 -fill $evv(POINT)
		$rhenscreen create line 259 393 288 393 -width 2 -fill $evv(POINT)

		$rhenscreen create oval 271 412 273 414 -fill $evv(POINT) -outline $evv(POINT)
		$rhenscreen create line 259 396 263 396 -width 2 -fill $evv(POINT)
		$rhenscreen create arc  248 375 298 411 -start 125 -extent -70 -style arc -outline $evv(POINT) -width 1
		$rhenscreen create text 273 385 -text "3" -font {helvetica 9 normal}  -fill $evv(POINT)

		set tbmtquaver6a  [$rhenscreen create oval 305 410 313 416 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmtquaver6b  [$rhenscreen create oval 320 410 328 416 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmtquaver6c  [$rhenscreen create oval 340 410 348 416 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 313 413 313 393 -width 1 -fill $evv(POINT)
		$rhenscreen create line 328 413 328 393 -width 1 -fill $evv(POINT)
		$rhenscreen create line 348 413 348 393 -width 1 -fill $evv(POINT)
		$rhenscreen create line 314 393 348 393 -width 2 -fill $evv(POINT)

		$rhenscreen create oval 331 412 333 414 -fill $evv(POINT) -outline $evv(POINT)
		$rhenscreen create line 343 396 348 396 -width 2 -fill $evv(POINT)
		$rhenscreen create arc  303 375 358 411 -start 125 -extent -70 -style arc -outline $evv(POINT) -width 1
		$rhenscreen create text 328 385 -text "3" -font {helvetica 9 normal}  -fill $evv(POINT)

		set tbmtquaver7a  [$rhenscreen create oval 365 410 373 416 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmtquaver7b  [$rhenscreen create oval 385 410 393 416 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmtquaver7c  [$rhenscreen create oval 400 410 408 416 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 373 413 373 393 -width 1 -fill $evv(POINT)
		$rhenscreen create line 393 413 393 393 -width 1 -fill $evv(POINT)
		$rhenscreen create line 408 413 408 393 -width 1 -fill $evv(POINT)
		$rhenscreen create line 374 393 408 393 -width 2 -fill $evv(POINT)

		$rhenscreen create oval 376 412 378 414 -fill $evv(POINT) -outline $evv(POINT)
		$rhenscreen create line 403 396 408 396 -width 2 -fill $evv(POINT)
		$rhenscreen create arc  363 375 413 411 -start 125 -extent -70 -style arc -outline $evv(POINT) -width 1
		$rhenscreen create text 388 385 -text "3" -font {helvetica 9 normal}  -fill $evv(POINT)

		set tbmtquaver8a  [$rhenscreen create oval 425 410 433 416 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmtquaver8b  [$rhenscreen create oval 435 410 443 416 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmtquaver8c  [$rhenscreen create oval 450 410 458 416 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 433 413 433 393 -width 1 -fill $evv(POINT)
		$rhenscreen create line 443 413 443 393 -width 1 -fill $evv(POINT)
		$rhenscreen create line 458 413 458 393 -width 1 -fill $evv(POINT)
		$rhenscreen create line 434 393 458 393 -width 2 -fill $evv(POINT)

		$rhenscreen create oval 461 412 463 414 -fill $evv(POINT) -outline $evv(POINT)
		$rhenscreen create line 434 396 438 396 -width 2 -fill $evv(POINT)
		$rhenscreen create arc  423 375 473 411 -start 125 -extent -70 -style arc -outline $evv(POINT) -width 1
		$rhenscreen create text 448 385 -text "3" -font {helvetica 9 normal}  -fill $evv(POINT)

		set tbmtquaver9b  [$rhenscreen create oval 500 410 508 416 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		set tbmtquaver9c  [$rhenscreen create oval 515 410 523 416 -fill $evv(POINT) -outline $evv(POINT) -tag beats] 
		$rhenscreen create line 507 413 507 393 -width 1 -fill $evv(POINT)
		$rhenscreen create line 522 413 522 393 -width 1 -fill $evv(POINT)
		$rhenscreen create line 507 393 523 393 -width 2 -fill $evv(POINT)
		$rhenscreen create line 488 398 496 398 490 413 -tag beats -fill $evv(POINT)

		$rhenscreen create oval 521 412 523 414 -fill $evv(POINT) -outline $evv(POINT)
		$rhenscreen create line 434 396 438 396 -width 2 -fill $evv(POINT)
		$rhenscreen create arc  483 375 533 411 -start 125 -extent -70 -style arc -outline $evv(POINT) -width 1
		$rhenscreen create text 508 385 -text "3" -font {helvetica 9 normal}  -fill $evv(POINT)


					;############## QUAVER TRIPLETS WITH SEMIQUAVERS
					 
		$rhenscreen create oval 30 470 38 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats
		$rhenscreen create oval 40 470 48 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats 
		$rhenscreen create oval 50 470 58 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats 
		$rhenscreen create oval 65 470 73 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats 

		$rhenscreen create line 38 473 38 453 -fill $evv(POINT) -tag beats
		$rhenscreen create line 48 473 48 453 -fill $evv(POINT) -tag beats 
		$rhenscreen create line 58 473 58 453 -fill $evv(POINT) -tag beats 
		$rhenscreen create line 73 473 73 453 -fill $evv(POINT) -tag beats 

		$rhenscreen create line 39 453 73 453 -width 2 -fill $evv(POINT)
		$rhenscreen create line 39 456 48 456 -width 2 -fill $evv(POINT)

		$rhenscreen create arc  28 435 83 441 -start 125 -extent -70 -style arc -outline $evv(POINT) -width 1
		$rhenscreen create text 54 445 -text "3" -font {helvetica 9 normal}  -fill $evv(POINT)

		$rhenscreen create oval 100 470 108 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats
		$rhenscreen create oval 115 470 123 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats 
		$rhenscreen create oval 125 470 133 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats 
		$rhenscreen create oval 140 470 148 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats 

		$rhenscreen create line 108 473 108 453 -fill $evv(POINT) -tag beats
		$rhenscreen create line 123 473 123 453 -fill $evv(POINT) -tag beats 
		$rhenscreen create line 133 473 133 453 -fill $evv(POINT) -tag beats 
		$rhenscreen create line 148 473 148 453 -fill $evv(POINT) -tag beats 

		$rhenscreen create line 109 453 148 453 -width 2 -fill $evv(POINT)
		$rhenscreen create line 124 456 133 456 -width 2 -fill $evv(POINT)

		$rhenscreen create arc  98 435 153 441 -start 125 -extent -70 -style arc -outline $evv(POINT) -width 1
		$rhenscreen create text 124 445 -text "3" -font {helvetica 9 normal}  -fill $evv(POINT)

		$rhenscreen create oval 170 470 178 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats
		$rhenscreen create oval 185 470 193 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats 
		$rhenscreen create oval 200 470 208 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats 
		$rhenscreen create oval 210 470 218 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats 

		$rhenscreen create line 178 473 178 453 -fill $evv(POINT) -tag beats
		$rhenscreen create line 193 473 193 453 -fill $evv(POINT) -tag beats 
		$rhenscreen create line 208 473 208 453 -fill $evv(POINT) -tag beats 
		$rhenscreen create line 218 473 218 453 -fill $evv(POINT) -tag beats 

		$rhenscreen create line 179 453 218 453 -width 2 -fill $evv(POINT)
		$rhenscreen create line 209 456 218 456 -width 2 -fill $evv(POINT)

		$rhenscreen create arc  168 435 223 441 -start 125 -extent -70 -style arc -outline $evv(POINT) -width 1
		$rhenscreen create text 194 445 -text "3" -font {helvetica 9 normal}  -fill $evv(POINT)

		$rhenscreen create oval 240 470 248 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats
		$rhenscreen create oval 250 470 258 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats 
		$rhenscreen create oval 260 470 268 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats 
		$rhenscreen create oval 270 470 278 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats 
		$rhenscreen create oval 280 470 288 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats 

		$rhenscreen create line 248 473 248 453 -fill $evv(POINT) -tag beats
		$rhenscreen create line 258 473 258 453 -fill $evv(POINT) -tag beats 
		$rhenscreen create line 268 473 268 453 -fill $evv(POINT) -tag beats 
		$rhenscreen create line 278 473 278 453 -fill $evv(POINT) -tag beats 
		$rhenscreen create line 288 473 288 453 -fill $evv(POINT) -tag beats 

		$rhenscreen create line 249 453 288 453 -width 2 -fill $evv(POINT)
		$rhenscreen create line 249 456 278 456 -width 2 -fill $evv(POINT)

		$rhenscreen create arc  238 435 293 441 -start 125 -extent -70 -style arc -outline $evv(POINT) -width 1
		$rhenscreen create text 264 445 -text "3" -font {helvetica 9 normal}  -fill $evv(POINT)

		$rhenscreen create oval 310 470 318 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats
		$rhenscreen create oval 325 470 333 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats 
		$rhenscreen create oval 335 470 343 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats 
		$rhenscreen create oval 345 470 353 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats 
		$rhenscreen create oval 355 470 363 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats 

		$rhenscreen create line 318 473 318 453 -fill $evv(POINT) -tag beats
		$rhenscreen create line 333 473 333 453 -fill $evv(POINT) -tag beats 
		$rhenscreen create line 343 473 343 453 -fill $evv(POINT) -tag beats 
		$rhenscreen create line 353 473 353 453 -fill $evv(POINT) -tag beats 
		$rhenscreen create line 363 473 363 453 -fill $evv(POINT) -tag beats 

		$rhenscreen create line 319 453 363 453 -width 2 -fill $evv(POINT)
		$rhenscreen create line 334 456 363 456 -width 2 -fill $evv(POINT)

		$rhenscreen create arc  308 435 363 441 -start 125 -extent -70 -style arc -outline $evv(POINT) -width 1
		$rhenscreen create text 344 445 -text "3" -font {helvetica 9 normal}  -fill $evv(POINT)

		$rhenscreen create oval 380 470 388 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats
		$rhenscreen create oval 390 470 398 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats 
		$rhenscreen create oval 400 470 408 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats 
		$rhenscreen create oval 410 470 418 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats 
		$rhenscreen create oval 420 470 428 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats 
		$rhenscreen create oval 430 470 438 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats 

		$rhenscreen create line 388 473 388 453 -fill $evv(POINT) -tag beats
		$rhenscreen create line 398 473 398 453 -fill $evv(POINT) -tag beats 
		$rhenscreen create line 408 473 408 453 -fill $evv(POINT) -tag beats 
		$rhenscreen create line 418 473 418 453 -fill $evv(POINT) -tag beats 
		$rhenscreen create line 428 473 428 453 -fill $evv(POINT) -tag beats 
		$rhenscreen create line 438 473 438 453 -fill $evv(POINT) -tag beats 

		$rhenscreen create line 389 453 438 453 -width 2 -fill $evv(POINT)
		$rhenscreen create line 389 456 438 456 -width 2 -fill $evv(POINT)

		$rhenscreen create arc  378 435 438 441 -start 125 -extent -70 -style arc -outline $evv(POINT) -width 1
		$rhenscreen create text 414 445 -text "3" -font {helvetica 9 normal}  -fill $evv(POINT)

######### TRIPlET SEMIQUAVERS

		$rhenscreen create oval 450 470 458 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats
		$rhenscreen create oval 460 470 468 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats 
		$rhenscreen create oval 470 470 478 476 -fill $evv(POINT) -outline $evv(POINT) -tag beats 

		$rhenscreen create line 458 473 458 453 -fill $evv(POINT) -tag beats
		$rhenscreen create line 468 473 468 453 -fill $evv(POINT) -tag beats 
		$rhenscreen create line 478 473 478 453 -fill $evv(POINT) -tag beats 

		$rhenscreen create line 459 453 478 453 -width 2 -fill $evv(POINT)
		$rhenscreen create line 459 456 478 456 -width 2 -fill $evv(POINT)

		$rhenscreen create arc  452 435 482 441 -start 125 -extent -70 -style arc -outline $evv(POINT) -width 1
		$rhenscreen create text 467 445 -text "3" -font {helvetica 9 normal}  -fill $evv(POINT)

		$rhenscreen create line 0 486 600 486 -width 2 -fill $evv(POINT)

		bind $rhenscreen <ButtonRelease-1>	{CodeFromRhythmGraphic %W %x %y}
		bind $f <Return> {set pr_propryt 1}
		bind $f <Escape> {set pr_propryt 0}
	}
	wm title $f "RHYTHM ENCODER [file rootname [file tail $inrhfnam]]"
	ClearGraphicFromRhythmDisplay $rhenscreen
 	if {[string length $orig_code] > 0} {
		DisplayRhythmGraphicFromFullCode $orig_code $rhenscreen
		set rhencoding $orig_code
	} else {
		set rhencoding ""
	}
	$f.btns.abdn 	config -state normal
	$f.btns.save 	config -state normal
	$f.btns.restart config -state normal
	$f.btns.baktrak config -state normal

	raise .rhypropscreen
	update idletasks
	StandardPosition $f
	set pr_propryt 0
	set finished 0
	My_Grab 0 .rhypropscreen pr_propryt

	while {!$finished} {
		tkwait variable pr_propryt
		switch -- $pr_propryt {
			0 {
				if {$fromprops} {
					if {[string length $orig_code] <= 0} {
						set orig_code $evv(NULL_PROP)
					}
					set rhencoding $orig_code
				} else {
					set rhencoding ""
				}
				set finished 1
			}
			1 {
				set len [string length $rhencoding]
				if {$len < 2} {
					Inf "No values entered."
					continue
				}
				set finished 1
			}
			2 {
				set rhencoding ""
				ClearGraphicFromRhythmDisplay $rhenscreen
			}
			3 {
				set len [string length $rhencoding]
				set lastcodon [string index $rhencoding end]
				switch -- $lastcodon {
					"|" -
					"," -
					"." -
					":" {
						set eraser 2
					}
					default {
						set eraser 3
					}
				}
				if {$len >= $eraser} {
					incr len [expr -$eraser]
					set rhencoding [string range $rhencoding 0 $len]
					ClearLastGraphicFromRhythmDisplay $rhenscreen
				} else {
					set rhencoding ""
					ClearGraphicFromRhythmDisplay $rhenscreen
				}
			}
			4 {
				if {[string length $rhencoding] <= 0} {
					if {[string length $orig_code] <= 0} {
						Inf "No Code To Change"	
						continue
					} else {
						set orig_orig_coding $orig_code
					}
				} else {
					set orig_orig_coding $rhencoding
				}
				set nucode [RcodeHalveDouble $orig_orig_coding 1 0]
				if {[string length $nucode] <= 0} {
					continue
				}
				set rhencoding $nucode
				DisplayRhythmGraphicFromFullCode $rhencoding $rhenscreen
			}
		}
	}
	set rh_encoding $rhencoding
	My_Release_to_Dialog .rhypropscreen
	Dlg_Dismiss .rhypropscreen
	destroy .rhypropscreen
	return $rh_encoding
}

#------ Convert screen position to CODE value

proc CodeFromRhythmGraphic {w xx yy} {
	global rhencoding rhenscreen

	set obj [$rhenscreen find closest $xx $yy]
	set coords [$rhenscreen coords $obj]
	set x [expr int([lindex $coords 0])]
	set y [expr int([lindex $coords 1])]

	if {$y >= 475} {	;#	IGNORE ITEMS IN OUTPUT DISPLAY AT FOOT OF CANVAS
		return
	} 

	switch -- $x {
		30 {
			switch -- $y {
				30	{ append rhencoding w4; GraphicFromRhythmCode w4 $rhenscreen}
				60	{ append rhencoding w6; GraphicFromRhythmCode w6 $rhenscreen}
				130 { append rhencoding a1; GraphicFromRhythmCode a1 $rhenscreen}
				175 { append rhencoding a9; GraphicFromRhythmCode a9 $rhenscreen}
				220 { append rhencoding b1; GraphicFromRhythmCode b1 $rhenscreen}
				280 { append rhencoding c1; GraphicFromRhythmCode c1 $rhenscreen}
				350 { append rhencoding d1; GraphicFromRhythmCode d1 $rhenscreen}
				410 { append rhencoding e1; GraphicFromRhythmCode e1 $rhenscreen}
				470 { append rhencoding f1; GraphicFromRhythmCode f1 $rhenscreen}
			}
		}
		40 {
			switch -- $y {
				175 { append rhencoding a9; GraphicFromRhythmCode a9 $rhenscreen}
				470 { append rhencoding f1; GraphicFromRhythmCode f1 $rhenscreen}
			}
		}
		45 {
			switch -- $y {
				130 { append rhencoding a1; GraphicFromRhythmCode a1 $rhenscreen}
				220 { append rhencoding b1; GraphicFromRhythmCode b1 $rhenscreen}
				280 { append rhencoding c1; GraphicFromRhythmCode c1 $rhenscreen}
				350 { append rhencoding d1; GraphicFromRhythmCode d1 $rhenscreen}
				410 { append rhencoding e1; GraphicFromRhythmCode e1 $rhenscreen}
			}
		}
		50 {
			switch -- $y {
				470 { append rhencoding f1; GraphicFromRhythmCode f1 $rhenscreen}
			}
		}
		60 {
			switch -- $y {
				220 { append rhencoding b1; GraphicFromRhythmCode b1 $rhenscreen}
				280 { append rhencoding c1; GraphicFromRhythmCode c1 $rhenscreen}
				350 { append rhencoding d1; GraphicFromRhythmCode d1 $rhenscreen}
				410 { append rhencoding e1; GraphicFromRhythmCode e1 $rhenscreen}
			}
		}
		65 {
			switch -- $y {
				470 { append rhencoding f1; GraphicFromRhythmCode f1 $rhenscreen}
			}
		}
		70 {
			switch -- $y {
				30	{ append rhencoding x4; GraphicFromRhythmCode x4 $rhenscreen}
				60	{ append rhencoding x6; GraphicFromRhythmCode x6 $rhenscreen}
				130	{ append rhencoding a2; GraphicFromRhythmCode a2 $rhenscreen}
			}
		}
		85 {
			switch -- $y {
				220	{ append rhencoding b2; GraphicFromRhythmCode b2 $rhenscreen}
				280	{ append rhencoding c2; GraphicFromRhythmCode c2 $rhenscreen}
				350	{ append rhencoding d2; GraphicFromRhythmCode d2 $rhenscreen}
				410 { append rhencoding e2; GraphicFromRhythmCode e2 $rhenscreen}
			}
		}
		90 {
			switch -- $y {
				130	{ append rhencoding a2; GraphicFromRhythmCode a2 $rhenscreen}
			}
		}
		100 {
			switch -- $y {
				470 { append rhencoding f2; GraphicFromRhythmCode f2 $rhenscreen}
			}
		}
		110 {
			switch -- $y {
				130	{ append rhencoding a3; GraphicFromRhythmCode a3 $rhenscreen}
			}
		}
		115 {
			switch -- $y {
				220	{ append rhencoding b2; GraphicFromRhythmCode b2 $rhenscreen}
				280	{ append rhencoding c2; GraphicFromRhythmCode c2 $rhenscreen}
				350	{ append rhencoding d2; GraphicFromRhythmCode d2 $rhenscreen}
				410 { append rhencoding e2; GraphicFromRhythmCode e2 $rhenscreen}
				470 { append rhencoding f2; GraphicFromRhythmCode f2 $rhenscreen}
			}
		}
		120 {
			switch -- $y {
				130	{ append rhencoding a3; GraphicFromRhythmCode a3 $rhenscreen}
			}
		}
		125 {
			switch -- $y {
				470 { append rhencoding f2; GraphicFromRhythmCode f2 $rhenscreen}
			}
		}
		129 -
		130 {
			append rhencoding "."
			GraphicFromRhythmCode "." $rhenscreen
		}
		140 {
			switch -- $y {
				220	{ append rhencoding b3; GraphicFromRhythmCode b3 $rhenscreen}
				280	{ append rhencoding c3; GraphicFromRhythmCode c3 $rhenscreen}
				350	{ append rhencoding d3; GraphicFromRhythmCode d3 $rhenscreen}
				410 { append rhencoding e3; GraphicFromRhythmCode e3 $rhenscreen}
				470 { append rhencoding f2; GraphicFromRhythmCode f2 $rhenscreen}
			}
		}
		155 {
			switch -- $y {
				220	{ append rhencoding b3; GraphicFromRhythmCode b3 $rhenscreen}
				280	{ append rhencoding c3; GraphicFromRhythmCode c3 $rhenscreen}
				350	{ append rhencoding d3; GraphicFromRhythmCode d3 $rhenscreen}
				410 { append rhencoding e3; GraphicFromRhythmCode e3 $rhenscreen}
			}
		}
		150 {
			switch -- $y {
				130	{ append rhencoding a4; GraphicFromRhythmCode a4 $rhenscreen}
			}
		}
		165 -
		175 {
			switch -- $y {
				130	{ append rhencoding a4; GraphicFromRhythmCode a4 $rhenscreen}
			}
		}
		169 {
			append rhencoding ":"
			GraphicFromRhythmCode ":" $rhenscreen
		}
		170 {
			switch -- $y {
				23  { append rhencoding ":"; GraphicFromRhythmCode ":" $rhenscreen}
				30  { append rhencoding ":"; GraphicFromRhythmCode ":" $rhenscreen}
				470 { append rhencoding f3; GraphicFromRhythmCode f3 $rhenscreen}
			}
		}
		185 {
			switch -- $y {
				470 { append rhencoding f3; GraphicFromRhythmCode f3 $rhenscreen}
			}
		}
		195 -
		215 {
			switch -- $y {
				220	{ append rhencoding b4; GraphicFromRhythmCode b4 $rhenscreen}
				280	{ append rhencoding c4; GraphicFromRhythmCode c4 $rhenscreen}
				350	{ append rhencoding d4; GraphicFromRhythmCode d4 $rhenscreen}
				410 { append rhencoding e4; GraphicFromRhythmCode e4 $rhenscreen}
			}
		}
		200 {
			switch -- $y {
				130	{ append rhencoding a5; GraphicFromRhythmCode a5 $rhenscreen}
				470 { append rhencoding f3; GraphicFromRhythmCode f3 $rhenscreen}
			}
		}
		210 {
			switch -- $y {
				36	{ append rhencoding ","; GraphicFromRhythmCode "," $rhenscreen}
				130	{ append rhencoding a5; GraphicFromRhythmCode a5 $rhenscreen}
				470 { append rhencoding f3; GraphicFromRhythmCode f3 $rhenscreen}
			}
		}
		225 {
			switch -- $y {
				130	{ append rhencoding a5; GraphicFromRhythmCode a5 $rhenscreen}
				220	{ append rhencoding b4; GraphicFromRhythmCode b4 $rhenscreen}
				280	{ append rhencoding c4; GraphicFromRhythmCode c4 $rhenscreen}
				350	{ append rhencoding d4; GraphicFromRhythmCode d4 $rhenscreen}
				410 { append rhencoding e4; GraphicFromRhythmCode e4 $rhenscreen}
			}
		}
		240 {
			switch -- $y {
				470 { append rhencoding f4; GraphicFromRhythmCode f4 $rhenscreen}
			}
		}
		250 -
		260 {
			switch -- $y {
				130	{ append rhencoding a6; GraphicFromRhythmCode a6 $rhenscreen}
				220	{ append rhencoding b5; GraphicFromRhythmCode b5 $rhenscreen}
				280	{ append rhencoding c5; GraphicFromRhythmCode c5 $rhenscreen}
				350	{ append rhencoding d5; GraphicFromRhythmCode d5 $rhenscreen}
				410 { append rhencoding e5; GraphicFromRhythmCode e5 $rhenscreen}
				470 { append rhencoding f4; GraphicFromRhythmCode f4 $rhenscreen}
			}
		}
		270 {
			switch -- $y {
				470 { append rhencoding f4; GraphicFromRhythmCode f4 $rhenscreen}
			}
		}
		275 {
			switch -- $y {
				130	{ append rhencoding a6; GraphicFromRhythmCode a6 $rhenscreen}
			}
		}
		280 {
			switch -- $y {
				220	{ append rhencoding b5; GraphicFromRhythmCode b5 $rhenscreen}
				280	{ append rhencoding c5; GraphicFromRhythmCode c5 $rhenscreen}
				350	{ append rhencoding d5; GraphicFromRhythmCode d5 $rhenscreen}
				410 { append rhencoding e5; GraphicFromRhythmCode e5 $rhenscreen}
				470 { append rhencoding f4; GraphicFromRhythmCode f4 $rhenscreen}
			}
		}
		300 -
		330 {
			switch -- $y {
				130 { append rhencoding a7; GraphicFromRhythmCode a7 $rhenscreen}
			}
		}
		310 {
			switch -- $y {
				130 { append rhencoding a7; GraphicFromRhythmCode a7 $rhenscreen}
				470 { append rhencoding f5; GraphicFromRhythmCode f5 $rhenscreen}
			}
		}
		320 {
			switch -- $y {
				130 { append rhencoding a7; GraphicFromRhythmCode a7 $rhenscreen}
				220	{ append rhencoding b6; GraphicFromRhythmCode b6 $rhenscreen}
				280	{ append rhencoding c6; GraphicFromRhythmCode c6 $rhenscreen}
				350	{ append rhencoding d6; GraphicFromRhythmCode d6 $rhenscreen}
				410 { append rhencoding e6; GraphicFromRhythmCode e6 $rhenscreen}
			}
		}
		305 -
		340 {
			switch -- $y {
				220	{ append rhencoding b6; GraphicFromRhythmCode b6 $rhenscreen}
				280	{ append rhencoding c6; GraphicFromRhythmCode c6 $rhenscreen}
				350	{ append rhencoding d6; GraphicFromRhythmCode d6 $rhenscreen}
				410 { append rhencoding e6; GraphicFromRhythmCode e6 $rhenscreen}
			}
		}
		325 -
		335 -
		345 -
		355 {
			switch -- $y {
				470 { append rhencoding f5; GraphicFromRhythmCode f5 $rhenscreen}
			}
		}
		365 -
		385 {
			switch -- $y {
				220	{ append rhencoding b7; GraphicFromRhythmCode b7 $rhenscreen}
				280	{ append rhencoding c7; GraphicFromRhythmCode c7 $rhenscreen}
				350	{ append rhencoding d7; GraphicFromRhythmCode d7 $rhenscreen}
				410 { append rhencoding e7; GraphicFromRhythmCode e7 $rhenscreen}
			}
		}
		370 {
			switch -- $y {
				36	{ append rhencoding "|"; GraphicFromRhythmCode "|" $rhenscreen}
				130	{ append rhencoding a0; GraphicFromRhythmCode a0 $rhenscreen}
			}
		}
		380 -
		390 {
			switch -- $y {
				470 { append rhencoding f6; GraphicFromRhythmCode f6 $rhenscreen}
			}
		}
		400 {
			switch -- $y {
				220	{ append rhencoding b7; GraphicFromRhythmCode b7 $rhenscreen}
				280	{ append rhencoding c7; GraphicFromRhythmCode c7 $rhenscreen}
				350	{ append rhencoding d7; GraphicFromRhythmCode d7 $rhenscreen}
				410 { append rhencoding e7; GraphicFromRhythmCode e7 $rhenscreen}
				470 { append rhencoding f6; GraphicFromRhythmCode f6 $rhenscreen}
			}
		}
		410 -
		420 {
			switch -- $y {
				470 { append rhencoding f6; GraphicFromRhythmCode f6 $rhenscreen}
			}
		}
		425 -
		435 {
			switch -- $y {
				220	{ append rhencoding b8; GraphicFromRhythmCode b8 $rhenscreen}
				280	{ append rhencoding c8; GraphicFromRhythmCode c8 $rhenscreen}
				350	{ append rhencoding d8; GraphicFromRhythmCode d8 $rhenscreen}
				410 { append rhencoding e8; GraphicFromRhythmCode e8 $rhenscreen}
			}
		}
		430 {
			switch -- $y {
				130 { append rhencoding a8; GraphicFromRhythmCode a8 $rhenscreen}
				470 { append rhencoding f6; GraphicFromRhythmCode f6 $rhenscreen}
			}
		}
		440 -
		460 {
			switch -- $y {
				130 { append rhencoding a8; GraphicFromRhythmCode a8 $rhenscreen}
				470 { append rhencoding f7; GraphicFromRhythmCode f7 $rhenscreen}
			}
		}
		450 {
			switch -- $y {
				130 { append rhencoding a8; GraphicFromRhythmCode a8 $rhenscreen}
				220	{ append rhencoding b8; GraphicFromRhythmCode b8 $rhenscreen}
				280	{ append rhencoding c8; GraphicFromRhythmCode c8 $rhenscreen}
				350	{ append rhencoding d8; GraphicFromRhythmCode d8 $rhenscreen}
				410 { append rhencoding e8; GraphicFromRhythmCode e8 $rhenscreen}
				470 { append rhencoding f7; GraphicFromRhythmCode f7 $rhenscreen}
			}
		}
		470 {
			switch -- $y {
				470 { append rhencoding f7; GraphicFromRhythmCode f7 $rhenscreen}
			}
		}
		485 {
			switch -- $y {
				220	{ append rhencoding b0; GraphicFromRhythmCode b0 $rhenscreen}
				280	{ append rhencoding c0; GraphicFromRhythmCode c0 $rhenscreen}
			}
		}
		500 -
		515 {
			switch -- $y {
				350	{ append rhencoding d9; GraphicFromRhythmCode d9 $rhenscreen}
				410	{ append rhencoding e9; GraphicFromRhythmCode e9 $rhenscreen}
			}
		}
		537 {
			switch -- $y {
				220	{ append rhencoding b9; GraphicFromRhythmCode b9 $rhenscreen}
				280	{ append rhencoding c9; GraphicFromRhythmCode c9 $rhenscreen}
			}
		}
		557 {
			switch -- $y {
				280	{ append rhencoding z0; GraphicFromRhythmCode z0 $rhenscreen}
			}
		}
	}
}

#------ Remove all from rhythm graphic display

proc ClearGraphicFromRhythmDisplay {can} {
	global rcodex lastrcodex tp_rhy2
	catch {$can delete show}
	if {[info exists tp_rhy2] && [string match $can $tp_rhy2]} {
		$tp_rhy2.f.ll config -text ""
	}
	set rcodex 30	;#	Set display to left of screen
	set lastrcodex {}
}

#------ Remove last entered rhythm-cell from rhythm graphic display

proc ClearLastGraphicFromRhythmDisplay {can} {
	global rcodex lastrcodex
	set len [llength $lastrcodex]
	if {$len > 0} {
		set	rcodex [lindex $lastrcodex end]
		set leftlim [expr $rcodex - 2]
		foreach obj [$can find withtag show] {
			set coords [$can coords $obj]
			set x [lindex $coords 0]
			if {$x >= $leftlim} {
				catch {$can delete $obj} 
			}
		}
		if {$len == 1} {
			set lastrcodex  {}
		} else {
			incr len -2
			set lastrcodex [lrange $lastrcodex 0 $len]
		}
	}
}

#------ Convert code to rhythm graphic

proc GraphicFromRhythmCode {code can} {
	global rhenscreen tp_rhy tp_rhy2 ideal_rhy rcodex lastrcodex evv

	set headwid 8					;#	width of notehead

	;#	HEIGHT COORDINATES OF NOTEHEADS, DOTS, STEMS, AND QUAVER-SLOPELINES

	if {[info exists rhenscreen] && ($can == $rhenscreen)} {;#	FOR DISPLAY DURING RHYYTHM ENTRY
		set headhiy 590				;#	top of notehead
		set headloy 596				;#	bottom of notehead
		set stemhiy 573				;#	top of stem
		set stemloy 593				;#	bottom of stem
		set seplo   603				;#	bottom of separator
	} elseif {[info exists tp_rhy] && ($can == $tp_rhy)} {	;#	FOR TEMPORARY FROM PROPS TABLE
		set headhiy 40				;#	top of notehead
		set headloy 46				;#	bottom of notehead
		set stemhiy 23				;#	top of stem
		set stemloy 43				;#	bottom of stem
		set seplo   53				;#	bottom of separator
	} elseif {[info exists tp_rhy2] && ($can == $tp_rhy2)} {;#	FOR RETAINED FROM PROPS TABLE
		set headhiy 60				;#	top of notehead
		set headloy 66				;#	bottom of notehead
		set stemhiy 43				;#	top of stem
		set stemloy 63				;#	bottom of stem
		set seplo   73				;#	bottom of separator
	} elseif {[info exists ideal_rhy] && ($can == $ideal_rhy)} {;#	FOR RHYTHM IDEALISATION DISPLAY
		set headhiy 60				;#	top of notehead
		set headloy 66				;#	bottom of notehead
		set stemhiy 43				;#	top of stem
		set stemloy 63				;#	bottom of stem
		set seplo   73				;#	bottom of separator
	} else {
		return
	}
	switch -- $code {
		"|" {
			$can create line $rcodex $stemhiy $rcodex $seplo -width 3 -tag show  -fill $evv(POINT)
			lappend lastrcodex $rcodex
			incr rcodex 10
			return
		}
		"," {
			set x0 $rcodex
			set x3 [expr $x0 + 3]
			set x5 [expr $x0 + 5]
			set y0 $headloy
			set y4 [expr $y0 - 4]
			set y7 [expr $y0 - 7]
			set y10 [expr $y0 - 10]
			set y15 [expr $y0 - 15]
			$can create line $x0 $y0 $x0 $y4 $x3 $y7 $x0 $y7 $x5 $y10 $x0 $y10 $x0 $y15 -tag show -fill $evv(POINT)
			lappend lastrcodex $rcodex
			incr rcodex 30
			return
		}
		"." -
		":" {
			set x0 $rcodex
			set x10 [expr $x0 + 10]
			set x7 [expr $x0 + 7]
			set x2 [expr $x0 - 2]
			set xa [expr $rcodex - 1]
			set xb [expr $rcodex + 1]
			set y0 $headhiy
			set ya [expr $headhiy - 1]
			set yb [expr $headhiy + 1]
			set y10 [expr $y0 - 10]
			set y7 [expr $y0 - 7]
			$can create oval $xa  $ya $xb  $yb -fill $evv(POINT) -outline $evv(POINT) -tag show
			$can create line $x0  $y0 $x10  $y10 $x2 $y10 -tag show -fill $evv(POINT)
			if {$code == ":"} {
				$can create line $x0  $y7 $x7 $y7 -tag show -fill $evv(POINT)
			}
			lappend lastrcodex $rcodex
			incr rcodex 20
			return
		}
	}
	set quavy [expr $stemhiy + 7]		;#	y-coord of end of quaver slope-line
	set squavstart [expr $stemhiy + 3]	;#	y-coord of start of semiquaver 2nd-slope-line
	set squavy [expr $quavy + 3]		;#	y-coord of end of semiquaver 2nd-slope-line

	set beam2hiy [expr $stemhiy + 3]	;#	height of 2nd beam

	set dothiy $stemloy				;#	top of dot
	set dotloy [expr $stemloy + 2]	;#	bottom of dot


	;#	EXTRACT TYPE OF GROUPING, (DUPLE, TRIPLE: QUAVER, SEMIQUAVER ETC) AND WHICH GROUPING IT IS

	set gp [string index $code 0]	;#	which type of group (duple, triple; quaver, semiquaver etc)
	set no [string index $code 1]	;#	which note-grouping

	;#	ESTABLIOSH STEPS BETWEEN NOTEHEADS IN GROUPS

	set n 0
	while {$n <= 9} {		;#	Set dummy values, so later for-loops work
		set nstep(1,$n) 0
		set nstep(2,$n) 0
		set nstep(3,$n) 0
		set nstep(4,$n) 0
		set nstep(5,$n) 0
		incr n
	}
	set nstep(1,1)	15
	set nstep(2,1)	15
	set nstep(1,3)	15
	set nstep(3,7)	10
	set nstep(3,8)	10
	set nstep(1,8)	10
	set nstep(1,9)	10
	if {$gp == "a"} {
		set nstep(1,2)	20
		set nstep(1,3)	10
		set nstep(1,4)	15
		set nstep(2,8)	10
	} else {
		set nstep(1,2)	30
		set nstep(1,3)	15
		set nstep(1,4)	20
		set nstep(2,8)	15
	}
	set nstep(2,4)	10
	set nstep(1,5)	10
	if {$gp == "a"} {
		set nstep(2,5)	15
		set nstep(1,6)	10
		set nstep(2,6)	15
		set nstep(1,7)	10
		set nstep(2,7)	10
	} else {
		set nstep(2,5)	20
		set nstep(1,6)	15
		set nstep(2,6)	20
		set nstep(1,7)	20
		set nstep(2,7)	15
	}
	if {$gp == "f"} {
		set nstep(1,1) 10
		set nstep(1,2) 15
		set nstep(1,3) 15
		set nstep(1,4) 10
		set nstep(1,5) 15
		set nstep(1,6) 10
		set nstep(1,7) 10

		set nstep(2,1) 10
		set nstep(2,2) 10
		set nstep(2,3) 15
		set nstep(2,4) 10
		set nstep(2,5) 10
		set nstep(2,6) 10
		set nstep(2,7) 10

		set nstep(3,1) 15
		set nstep(3,2) 10
		set nstep(3,3) 10
		set nstep(3,4) 10
		set nstep(3,5) 10
		set nstep(3,6) 10

		set nstep(4,4) 10
		set nstep(4,5) 10
		set nstep(4,6) 10

		set nstep(5,6) 10
	}

	;#	INDICATE IF NOTES HAVE STEMS

	set stem 1
	if {$gp == "w"} {
		set stem 0
	}

	;#	INDICATE ANY BEAMS, TIES, OR WHITE-NOTE-HEADS

	set hasbeam 0
	set hasbeam2 0
	set hastie 0
	set iswhite 0
	set halfbeam 0
	set halfbeam_end 0
	set tiepush 0
	switch  -- $gp {
		"a" {
			if {$no > 0} {
				set hasbeam 1
			}
			switch -- $no {
				7 -
				9 { set hasbeam2 1 }
				4 { set halfbeam 2; set halfbeam_end 3 }
				5 { set halfbeam 1; set halfbeam_end 2 }
			}	 
		}
		"b" {
			if {($no < 2) || ($no > 3)} {
				set hasbeam 1
			} else {
				set hastie 1
			}
		}
		"c" {
			if {$no > 0} {
				set hasbeam 1
			}
			if {($no == 1) || ($no > 3)} { 
				set hasbeam2 1
			}
			set hasbeam 1
		}
		d {
			if {$no == 2} {
				set iswhite 1
			} elseif {$no == 3} {
				set iswhite 2
			}
			set hastie 3
		}
		"e" {
			if {($no < 2) || ($no > 3)} {
				set hasbeam 1
			}
			set hastie 3
		}
		"w" -
		"x" {
			set iswhite 1
		}
		"f" {
			set hastie 3
			set hasbeam 1
			switch -- $no {
				1 { set halfbeam 1; set halfbeam_end 2; set tiepush 4} 
				2 { set halfbeam 2; set halfbeam_end 3; set tiepush 4}
				3 { set halfbeam 3; set halfbeam_end 4; set tiepush 6}
				4 { set halfbeam 1; set halfbeam_end 4; set tiepush 7}
				5 { set halfbeam 2; set halfbeam_end 5; set tiepush 9}
				6 { set halfbeam 1; set halfbeam_end 6; set tiepush 10}
				7 { set halfbeam 1; set halfbeam_end 3; set tiepush -3}
			}		
		}
	}
	if {$code == "a7"} {
		set hasbeam 1
	}
	if {($no == 9) && ($gp != "a") && ($gp != "e") && ($gp != "d")} {
		set hasbeam 0
		set hasbeam2 0
		set hastie 0
		set iswhite 0
		set halfbeam 0
	}

	;#	INDICATE ANY DOTTED-NOTES

	set hasdot 0
	switch -- $gp {
		"w" -
		"x" {
			if {$no == 6} {
				set hasdot 1
			}
		}
		"a" {
			switch -- $no {
				2 { set hasdot 1}
				3 { set hasdot 2}
			}
		}
		default {
			switch -- $no {
				4 { set hasdot 1}
				5 { set hasdot 2}
				6 { set hasdot 2}
				7 { set hasdot 1}
				8 { set hasdot 3}
			}
		}
	}
	switch -- $code {
		"z0" -
		"b0" -
		"c0" { set hasdot 1 }
	}

	;#	INDICATE ANY RIGHT OR LEFT FLAGS FOR (DEMI)SEMIQUAVERS

	set lflag 0	
	set rflag 0
	switch -- $gp {
		"a" {
			switch -- $no {
				2 { set lflag 2 }
				3 { set rflag 1 } 
				6 {
					set rflag 1
					set lflag 3
				}
			}
		}
		"b" -
		"e" {
			switch -- $no {
				4 { set lflag 2 }
				5 { set rflag 1 }
				6 -
				7 { set lflag 3 }
				8 { set rflag 1 }
			}
		}
		"c" {
			switch -- $no {
				2 { set lflag 2 }
				3 { set rflag 1 }
				4 { set lflag 2 }
				5 { set rflag 1 }
				6 -
				7 { set lflag 3 }
				8 { set rflag 1 }
			}
		}
	}

	;#	INDICATE ANY SLOPELINES FOR STANDALONE QUAVERS

	set quav  0
	set squav 0
	switch -- $gp {
		"b" {
			switch -- $no {
				2 { set quav 2 }
				3 { set quav 1 }
				9 { set quav 1 }
			}
		}
		"e" {
			switch -- $no {
				2 { set quav 2 }
				3 { set quav 1 }
			}
		}
		"c" {
			switch -- $no {
				0 { set quav 1 }
				9 { set squav 1}
			}
		}
		"d" {
			switch -- $no {
				4 { set quav 2 }
				5 -
				8 { set quav 1 }
				6 -
				7 { set quav 3 }
			}
		}
		"y" {
			set quav 1
		}
		"z" {
			switch -- $no {
				0 { set squav 1}
			}
		}
	}

	;#	SET NUMBER OF NOTES IN GROUP
	
	switch -- $gp {
		"a" {
			switch -- $no {
				0 {
					set ncnt 1
				}
				1 -
				2 -
				3 -
				9 {
					set ncnt 2
				}
				4 -
				5 -
				6 {
					set ncnt 3
				} 
				7 -
				8 { 
					set ncnt 4 
				}
			}
		}
		"b" -	
		"c" -	
		"d" -	
		"e" {
			if {($no == 1) || ($no > 3)} {
				set ncnt 3
			} else {
				set ncnt 2
			}
		}
		"f" {
			if {$no < 4} {
				set ncnt 4
			} elseif {$no < 6} {
				set ncnt 5
			} elseif {$no == 6} {
				set ncnt 6
			} elseif {$no == 7} {
				set ncnt 3
			}
		}
		default {
			set ncnt 1
		}
	}
	switch -- $code {
		"z0" -
		"b9" -
		"c9" {
			set ncnt 1
		}
	}

	;#	SET SIZE OF STEP TO NEXT GROUP 

	switch  -- $gp {
		"a" { set gstep 40 }
		"b" -
		"c" -
		"d" -
		"e" { set gstep 60 }
		"f" { 
			if {$no < 7}  {
				set gstep 70 
			} else {
				set gstep 35 
			}
		}
	}
	if {($no == 9) && ($code != "d9") && ($code != "e9")} {
		set gstep 15
	}
	switch -- $code {
		"a7" { set gstep 50 }
		"a8" { set gstep 50 }
		"a9" { set gstep 25 }
		"w4" { set gstep 40 }
		"w6" { set gstep 60 }
		"x4" { set gstep 30 }
		"x6" { set gstep 45 }
		"z0" { set gstep 20 }
		"ye" {			;#	"yes" without a code
			Inf "No Coding For This Entry"
			return
		}
	}
	if {![info exists gstep]} {
		Inf "Problem In Coding: NO gstep: code == $code"
		return
	}

	;#	SET GLOBAL COORDINATES OF NOTE-GROUP

	set pos $rcodex							;#	position of first note = start position of group
	set note1end  [expr $pos + $headwid]	;#	position of end of 1st note
	set beamstart [expr $note1end + 1]		;#	start of beams
	set halfbeamend 0
	if {$hastie} {
		set tiestartx [expr $note1end - 10]	;#	tie coordinates
		set tiestarty [expr $stemhiy - 18]	
		set tieendx   [expr $tiestartx + 50]	
		set tieendy   [expr $stemloy - 2]	
		if {$hastie == 3} {
			set no3x [expr $tiestartx + 26]
			set no3y [expr $tiestarty + 10]
		}
		if {$tiepush != 0} {
			incr tiestartx $tiepush
			incr tieendx $tiepush
			if {[info exists no3x]} {
				incr no3x [expr int(round(double($tiepush)/2))]
			}
		}
	}
	if {$code == "e9"} {
		$can create line $pos [expr $stemhiy + 5] [expr $pos + 8] [expr $stemhiy + 5] [expr $pos + 2] $stemloy -width 1 -tag show -fill $evv(POINT)	;#	quaver fill in triplet
		incr beamstart 15
		incr pos 15
	} elseif {$code == "d9"} {
		set x0 $pos
		set x3 [expr $x0 + 3]
		set x5 [expr $x0 + 5]
		set y0 $headloy
		set y4 [expr $y0 - 4]
		set y7 [expr $y0 - 7]
		set y10 [expr $y0 - 10]
		set y15 [expr $y0 - 15]
		$can create line $x0 $y0 $x0 $y4 $x3 $y7 $x0 $y7 $x5 $y10 $x0 $y10 $x0 $y15 -tag show -fill $evv(POINT)
		incr pos 15
	}
	set lastk 0
	set k 1

	;#	CREATE ALL NOTES IN NOTE GROUP

	while {$k <= $ncnt} {
		set headend [expr $pos + $headwid]	;#	right edge of notehead
		set quavx [expr $headend + 5]		;#	x-coord of end of quaver slope-line
		set dotstart [expr $headend + 3]	;#	left of any dot
		set dotend [expr $dotstart + 2]	;#	right of any dot
		if {$iswhite == $k} {				;#	colour of notehead
			set col [option get . background {}]
		} else {
			set col $evv(POINT)
		}
		set hasflag 0
		if {$rflag == $k} {					;#	position of (demi)semiquaver flag
			set flagx0 $headend
			set flagx1 [expr $flagx0 + 3]
			set hasflag 1
		} elseif {$lflag == $k} {
			set flagx1 $headend
			set flagx0 [expr $flagx1 - 3]
			set hasflag 1
		}
		if {$hasflag} {
			set flagy  [expr $stemhiy + 3]
			if {$hasbeam2} {				;#	if has 2nd beam, all flags are lower
				set flagy  [expr $flagy + 3]
			}
		}
		if {$halfbeam} {
			if {$k == $halfbeam} {
				set halfbeamstart $headend
			} elseif {$k == $halfbeam_end} {
				set halfbeamend $headend
			}				
		}
		$can create oval $pos $headhiy $headend $headloy -fill $col -tag show -outline $evv(POINT)			;#	Notehead
		if {$stem} {
			$can create line $headend $stemhiy $headend $stemloy -width 1 -tag show -fill $evv(POINT)		;#	Stem
		}
		if {$hasdot == $k} {
			$can create oval $dotstart $dothiy $dotend $dotloy -tag show -fill $evv(POINT) -outline $evv(POINT) ;#	Dot
		}
		if {$quav == $k} {	
			$can create line $headend $stemhiy $quavx $quavy -width 1 -tag show -fill $evv(POINT)			;#	Quaver sloping line
		}
		if {$squav == $k} {	
			$can create line $headend $stemhiy $quavx $quavy -width 1 -tag show -fill $evv(POINT)			;#	Quaver sloping line
			$can create line $headend $squavstart $quavx $squavy -width 1 -tag show -fill $evv(POINT)		;#	2nd sloping line
		}
		if {$hasflag} {
			$can create line $flagx0 $flagy $flagx1 $flagy -width 2 -tag show -fill $evv(POINT)			;#	(demi)Semiquaver flag
		}
		if {$k < $ncnt} {
			incr pos $nstep($k,$no)	;#	Move forward to next note-in-group; step depends on which group we're in, and which note we're at
		}
		set lastk $k
		incr k
	}

	;#	ADD ANY BEAMS OR TIES

	if {$hasbeam} {
		$can create line $beamstart $stemhiy $headend $stemhiy -width 2 -tag show -fill $evv(POINT)		;#	beam from beamstart to end of last Notehead entered
	}	
	if {$hasbeam2} {
		$can create line $beamstart $beam2hiy $headend $beam2hiy -width 2 -tag show -fill $evv(POINT)		;#	2nd beam
	}	
	if {$halfbeam} {
#		if {$halfbeamend == 0} {
#			set halfbeamend $headend
#		}
		$can create line $halfbeamstart $beam2hiy $halfbeamend $beam2hiy -width 2 -tag show -fill $evv(POINT)		;#	2nd half beam
	}	
	if {$hastie} {																		;#	Tie
		$can create arc  $tiestartx $tiestarty $tieendx $tieendy -start 125 -extent -70 -style arc -outline $evv(POINT) -width 1 -tag show
		if {$hastie == 3} {
			$can create text $no3x $no3y -text "3" -font {helvetica 9 normal} -tag show -fill $evv(POINT) ;#	No "3" under tie
		}
	}

	;#	MOVE TO START OF NEXT NOTEGROUP
	lappend lastrcodex $rcodex
	incr rcodex $gstep
}

#--- Graphically display rhythm encoded in props table

proc ReadRhythm {lineno propno can} {
	global tp_props_list tp_propnames tp_rhy
	
	set code [lindex [lindex $tp_props_list $lineno] $propno]
	if {[string match $code "-"]} {
		return
	}
	DisplayRhythmGraphicFromFullCode $code $can
}

#---- Display Rhythm graphic from Rcode property of propfile

proc DisplayRhythmGraphicFromFullCode {code can} {
	set codelen [string len $code]
	ClearGraphicFromRhythmDisplay $can
	set j 0
	set k 1
	while {$j < $codelen} {
		set subcodon [string index $code $j]
		switch -- $subcodon {
			"|" -
			"," -
			"." -
			":" {
				set codon $subcodon
				incr j
				incr k
			}
			default {
				set codon [string range $code $j $k]
				incr j 2
				incr k 2
			}
		}
		GraphicFromRhythmCode $codon $can
	}
}

#---- Double or halve duration of rhythm groups, if possible

proc RcodeHalveDouble {code msgs doubling} {
	global rhhalve rhbadhalve rhdouble rhbaddouble
	EstablishRhythmDoublingMappings
	set codelen [string length $code]
	set isbaddouble 0
	set isbadhalve 0
	set j 0
	set k 1
	while {$j < $codelen} {
		set subcodon [string index $code $j]
		switch -- $subcodon {
			"|" {
				incr j
				incr k
			}
			"," -
			"." -
			":" {
				lappend rests $subcodon
				incr j
				incr k
			}
			default {
				set codon [string range $code $j $k]
				if {[lsearch $rhbaddouble $codon] >= 0} {
					set isbaddouble 1
				}
				if {[lsearch $rhbadhalve $codon] >= 0} {
					set isbadhalve 1
				}
				incr j 2
				incr k 2
			}
		}
	}
	if [info exists rests] {
		foreach rest $rests {
			if {[lsearch $rhbaddouble $rest] >= 0} {
				set isbaddouble 1
			}
			if {[lsearch $rhbadhalve $rest] >= 0} {
				set isbadhalve 1
			}
		}
	}
	if {$isbaddouble && $isbadhalve} {
		if {$msgs} {
			Inf "Cannot Double Or Halve Duration Values"
		}
		return ""
	}
	if {$doubling} {
		set double [expr $doubling - 1]
	} else {
		if {!$isbaddouble && !$isbadhalve} {
			if {$msgs} {
				set double [HalveOrDouble]
				if {$double < 0} {
					return ""
				}
			}
		} elseif {$isbaddouble} {
			set double 0
		} else {
			set double 1
		}
	}
	set j 0
	set k 1
	set nucode ""
	while {$j < $codelen} {
		set subcodon [string index $code $j]
		switch -- $subcodon {
			"|" {
				append nucode "|"
				incr j
				incr k
			}
			"," {
				if {$double} {
					if {[string match $rhdouble($subcodon) "BAD"]} {
						if {$msgs} {
							Inf "Cannot Double Duration Values"
						}
						return ""
					}							
					append nucode $rhdouble($subcodon)
				} else {
					set zzz [RhSpecialCase $subcodon $code $j $codelen]
					if {[llength $zzz] > 0} {
						append nucode [lindex $zzz 0]
						incr j [lindex $zzz 1]
						incr k [lindex $zzz 1]
					} else {
						if {[string match $rhhalve($subcodon) "BAD"]} {
							if {$msgs} {
								Inf "Cannot Halve Duration Values"
							}
							return ""
						}							
						append nucode $rhhalve($subcodon)
					}
				}
				incr j
				incr k
			}
			"." -
			":" {
				if {$double} {
					if {[string match $rhdouble($subcodon) "BAD"]} {
						if {$msgs} {
							Inf "Cannot Double Duration Values"
						}
						return ""
					}							
					append nucode $rhdouble($subcodon)
				} else {
					if {[string match $rhhalve($subcodon) "BAD"]} {
						if {$msgs} {
							Inf "Cannot Halve Duration Values"
						}
						return ""
					}							
					append nucode $rhhalve($subcodon)
				}
				incr j
				incr k
			}
			default {
				set codon [string range $code $j $k]
				if {$double} {
					if {[string match $rhdouble($codon) "BAD"]} {
						if {$msgs} {
							Inf "Cannot Double Duration Values"
						}
						return ""
					}							
					append nucode $rhdouble($codon)
				} else {
					set zzz [RhSpecialCase $codon $code $j $codelen]
					if {[llength $zzz] > 0} {
						append nucode [lindex $zzz 0]
						incr j [lindex $zzz 1]
						incr k [lindex $zzz 1]
					} else {
						if {[string match $rhhalve($codon) "BAD"]} {
							if {$msgs} {
								Inf "Cannot Halve Duration Values"
							}
							return ""
						}							
						append nucode $rhhalve($codon)
					}
				}
				incr j 2
				incr k 2
			}
		}
	}
	return $nucode
}

#---Choose Halving or Doubling

proc HalveOrDouble {} {
	global pr_hord rhy_doubler evv
	set f .hord
	set rhy_doubler -1
	if [Dlg_Create $f "DOUBLE OR HALVE ?" "set pr_hord 0" -borderwidth $evv(BBDR)] {
		frame $f.a -borderwidth $evv(BBDR)
		frame $f.b -borderwidth $evv(BBDR)
		button $f.a.q -text "Abandon" -command {set pr_hord 0} -width 7 -highlightbackground [option get . background {}]
		button $f.a.d -text "Double" -command {set pr_hord 1} -width 7 -highlightbackground [option get . background {}]
		button $f.a.h -text "Halve" -command {set pr_hord 2} -width 7 -highlightbackground [option get . background {}]
		pack $f.a.d $f.a.h -side left -padx 2
		pack $f.a.q -side right
		pack $f.a -side top -fill x -expand true -pady 2
		wm resizable $f 1 1
		bind $f <Escape>  {set pr_hord 0}
	}
	set pr_hord 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_hord $f
	while {!$finished} {
		tkwait variable pr_hord
		switch -- $pr_hord {
			0 { set rhy_doubler -1 }
			1 { set rhy_doubler 1 }
			2 { set rhy_doubler 0 }
		}
		break
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
	return $rhy_doubler
}

#--- Establish what double and half values are fror eeach rhtythmic grouping

proc EstablishRhythmDoublingMappings {} {
	global rhhalve rhbadhalve rhdouble rhbaddouble
	if {[info exists rhhalve]} {
		return
	}
	set rhbadhalve {}
	set rhbaddouble {}
	set rhhalve(w4) "x4"
	set rhhalve(w6) "x6"
	set rhhalve(x4) "a0"
	set rhhalve(x6) "b0"
	set rhhalve(z0) "BAD"
	set rhhalve(a0) "b9"
	set rhhalve(a1) "a9"
	set rhhalve(a2) "BAD"
	set rhhalve(a3) "BAD"
	set rhhalve(a4) "BAD"
	set rhhalve(a5) "BAD"
	set rhhalve(a6) "BAD"
	set rhhalve(a7) "BAD"
	set rhhalve(a8) "a7"
	set rhhalve(a9) "BAD"
	set rhhalve(b0) "c0"
	set rhhalve(b1) "c1"
	set rhhalve(b2) "c2"
	set rhhalve(b3) "c3"
	set rhhalve(b4) "c4"
	set rhhalve(b5) "c5"
	set rhhalve(b6) "c6"
	set rhhalve(b7) "c7"
	set rhhalve(b8) "c8"
	set rhhalve(b9) "c9"
	set rhhalve(c0) "z0"
	set rhhalve(c1) "BAD"
	set rhhalve(c2) "BAD"
	set rhhalve(c3) "BAD"
	set rhhalve(c4) "BAD"
	set rhhalve(c5) "BAD"
	set rhhalve(c6) "BAD"
	set rhhalve(c7) "BAD"
	set rhhalve(c8) "BAD"
	set rhhalve(c9) "BAD"
	set rhhalve(d1) "e1"
	set rhhalve(d2) "e2"
	set rhhalve(d3) "e3"
	set rhhalve(d4) "e4"
	set rhhalve(d5) "e5"
	set rhhalve(d6) "e6"
	set rhhalve(d7) "e7"
	set rhhalve(d8) "e8"
	set rhhalve(d9) "e9"
	set rhhalve(e1) "f7"
	set rhhalve(e2) "BAD"
	set rhhalve(e3) "BAD"
	set rhhalve(e4) "BAD"
	set rhhalve(e5) "BAD"
	set rhhalve(e6) "BAD"
	set rhhalve(e7) "BAD"
	set rhhalve(e8) "BAD"
	set rhhalve(f1) "BAD"
	set rhhalve(f2) "BAD"
	set rhhalve(f3) "BAD"
	set rhhalve(f4) "BAD"
	set rhhalve(f5) "BAD"
	set rhhalve(f6) "BAD"
	set rhhalve(f7) "BAD"
	set rhhalve(,)  "."
	set rhhalve(.)  ":"
	set rhhalve(:)  "BAD"
	set rhhalve(|)  "|"

	set rhdouble(w4) "BAD"
	set rhdouble(w6) "BAD"
	set rhdouble(x4) "w4"
	set rhdouble(x6) "w6"
	set rhdouble(z0) "c0"
	set rhdouble(a0) "x4"
	set rhdouble(a1) "a0a0"
	set rhdouble(a2) "b0b9"
	set rhdouble(a3) "b9b0"
	set rhdouble(a4) "a0a1"
	set rhdouble(a5) "a1a0"
	set rhdouble(a6) "b9a0b9"
	set rhdouble(a7) "a8"
	set rhdouble(a8) "a0a0a0a0"
	set rhdouble(a9) "a1"
	set rhdouble(b0) "x6"
	set rhdouble(b1) "a0a0a0"
	set rhdouble(b2) "x4a0"
	set rhdouble(b3) "a0x4"
	set rhdouble(b4) "b0b9a0"
	set rhdouble(b5) "b9b0a0"
	set rhdouble(b6) "a0b0b9"
	set rhdouble(b7) "b0a0b9"
	set rhdouble(b8) "b9a0b0"
	set rhdouble(b9) "a0"
	set rhdouble(c0) "b0"
	set rhdouble(c1) "b1"
	set rhdouble(c2) "b2"
	set rhdouble(c3) "b3"
	set rhdouble(c4) "b4"
	set rhdouble(c5) "b5"
	set rhdouble(c6) "b6"
	set rhdouble(c7) "b7"
	set rhdouble(c8) "b8"
	set rhdouble(c9) "b9"
	set rhdouble(d1) "BAD"
	set rhdouble(d2) "BAD"
	set rhdouble(d3) "BAD"
	set rhdouble(d4) "BAD"
	set rhdouble(d5) "BAD"
	set rhdouble(d6) "BAD"
	set rhdouble(d7) "BAD"
	set rhdouble(d8) "BAD"
	set rhdouble(e1) "d1"
	set rhdouble(e2) "d2"
	set rhdouble(e3) "d3"
	set rhdouble(e4) "d4"
	set rhdouble(e5) "d5"
	set rhdouble(e6) "d6"
	set rhdouble(e7) "d7"
	set rhdouble(e8) "d8"
	set rhdouble(e9) "d9"
	set rhdouble(f1) "BAD"
	set rhdouble(f2) "BAD"
	set rhdouble(f3) "BAD"
	set rhdouble(f4) "BAD"
	set rhdouble(f5) "BAD"
	set rhdouble(f6) "BAD"
	set rhdouble(f7) "e1"
	set rhdouble(,)  ",,"
	set rhdouble(.)  ","
	set rhdouble(:)  "."
	set rhdouble(|)  "|"

	foreach name [array names rhdouble] {
		if {[string match $rhdouble($name) "BAD"]} {
			lappend rhbaddouble $name
		}
	}
	foreach name [array names rhhalve] {
		if {[string match $rhhalve($name) "BAD"]} {
			lappend rhbadhalve $name
		}
	}
}

#---- Rhythm entry to props table, special codons

proc RhSpecialCase {codon code j codelen} {
	global rhdouble
	set remaining [expr $codelen - $j]
	set lim 3
	if {$codon == ","} {
		set lim 1
	}
	if {$remaining <= $lim} {
		return {}
	}
	switch -- $codon {
		"," {
			if {$remaining >= 4} {
				set teststr [string range $code $j [expr $j + 3]]
				if {[string match $teststr $codon$codon$codon$codon]} {
					return [list $codon$codon 3]
				}
			}
			if {$remaining >= 2} {
				set teststr [string range $code $j [expr $j + 1]]
				if {[string match $teststr $codon$codon]} {
					return [list $codon 1]
				}
			}
		}
		"a0" {
			if {$remaining >= 8} {
				set teststr [string range $code $j [expr $j + 7]]
				if {[string match $teststr $rhdouble(a8)]} {
					return [list a8 6]
				}
			}
			if {$remaining >= 6} {
				set teststr [string range $code $j [expr $j + 5]]
				if {[string match $teststr $rhdouble(b6)]} {
					return [list b6 4]
				}
				if {[string match $teststr $rhdouble(b1)]} {
					return [list b1 4]
				}
			}
			if {$remaining >= 4} {
				set teststr [string range $code $j [expr $j + 3]]
				if {[string match $teststr $rhdouble(b3)]} {
					return [list b3 2]
				} elseif {[string match $teststr $rhdouble(a4)]} {
					return [list a4 2]
				} elseif {[string match $teststr $rhdouble(a1)]} {
					return [list a1 2]
				}
			}
		}
		"a1" {
			if {$remaining >= 4} {
				set teststr [string range $code $j [expr $j + 3]]
				if {[string match $teststr $rhdouble(a5)]} {
					return [list a5 2]
				}
			}
		}
		"b0" {
			if {$remaining >= 6} {
				set teststr [string range $code $j [expr $j + 5]]
				if {[string match $teststr $rhdouble(b4)]} {
					return [list b4 4]
				}
				if {[string match $teststr $rhdouble(b7)]} {
					return [list b7 4]
				}
			}
			if {$remaining >= 4} {
				set teststr [string range $code $j [expr $j + 3]]
				if {[string match $teststr $rhdouble(a2)]} {
					return [list a2 2]
				}
			}
		}
		"b9" {
			if {$remaining >= 6} {
				set teststr [string range $code $j [expr $j + 5]]
				if {[string match $teststr $rhdouble(b8)]} {
					return [list b8 4]
				}
				if {[string match $teststr $rhdouble(b5)]} {
					return [list b5 4]
				}
				if {[string match $teststr $rhdouble(a6)]} {
					return [list a6 4]
				}
			}
			if {$remaining >= 4} {
				set teststr [string range $code $j [expr $j + 3]]
				if {[string match $teststr $rhdouble(a3)]} {
					return [list a3 2]
				}
			}
		}
		"x4" {
			if {$remaining >= 4} {
				set teststr [string range $code $j [expr $j + 3]]
				if {[string match $teststr $rhdouble(b2)]} {
					return [list b2 2]
				}
			}
		}
	}
	return {}
}

###############
# HF PROPERTY #
###############

#--- Read and Display (possibly play) HF data in props table

proc ReadHFProp {lineno propno can} {
	global tp_props_list phf prexpldir evv
	set code [lindex [lindex $tp_props_list $lineno] $propno]
	set midilist [HFSort $code midi]
	if {([llength $midilist] <= 0) || [string match [lindex $midilist 0] "-1"]} {
		return {}
	}
	set passlist $phf(passing)			;#	phf(passing) is flagging of passing notes generated by HFSort
	ClearGraphicFromHFDisplay $can
	if [string match $can $phf(can2)] {
		set phf(midilist) $midilist		;#	phf(midilist) stores midi data in permanent HF display
		set phf(passlist) $passlist		;#	phf(passlist) stores passing note data in permanent HF display
	}
	foreach midival $midilist passing $phf(passing) {
		MidiToPHFpos $can $midival $passing
	}
	if {$can == $phf(can2)} {
		set phf(lastperm) $lineno
	}
	if {$phf(play)} {
		set fnam [file join $prexpldir $evv(HFPROP_FNAME)$lineno$evv(SNDFILE_EXT)]
		if {[file exists $fnam]} {
			PlaySndfile $fnam 0
		} else {
			set msg "The soundfile for this harmonic-field does not exist : create it?"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "yes"} {
				GeneratePropSingleHFSndfile $lineno $code
			}
		}
	}
	return [list $lineno $code]
}

#--- Clear HF display below props table window

proc ClearGraphicFromHFDisplay {can} {
	global phf
	if {$can == $phf(can2)} {
		catch {unset phf(lastperm)}
		catch {unset phf(midilist)}
		catch {unset phf(passlist)}
		$phf(can2).f.ll config -text ""
	}
	catch {$can delete show}
}

#--- Displaying HF data on PRops Table display

proc MidiToPHFpos {can midi passing} {
	global phf evv
	set sharp 0
	set issharp 0
	switch -- $midi {
		53 {	;#	F-		
			set x $phf(noteline) 
			set y 120
		}
		54 {	;#	F#-		
			set x $phf(shrpnoteline) 
			set y 120
			set sharp $phf(shrpline)
			set issharp 1
		}
		55 {	;#	G		
			set x $phf(notespace) 
			set y 115		
		}
		56 {	;#	G#		
			set x $phf(shrpnotespace) 
			set y 115	
			set sharp $phf(shrpspace)
			set issharp 1
		}
		57 {	;#	A-		
			set x $phf(noteline) 
			set y 110		
		}
		58 {	;#	A#-		
			set x $phf(shrpnoteline) 
			set y 110	
			set sharp $phf(shrpline)
			set issharp 1
		}
		59 {	;#	B		
			set x $phf(notespace) 
			set y 105		
		}
		60 {	;#	C-		
			set x $phf(noteline) 
			set y 100		
		}
		61 {	;#	C#-		
			set x $phf(shrpnoteline) 
			set y 100	
			set sharp $phf(shrpline)
			set issharp 1
		}
		62 {	;#	D		
			set x $phf(notespace) 
			set y 95		
		}
		63 {	;#	D#		
			set x $phf(shrpnotespace) 
			set y 95	
			set sharp $phf(shrpspace)
			set issharp 1
		}
		64 {	;#	E-		
			set x $phf(noteline) 
			set y 90		
		}
		65 {	;#	F		
			set x $phf(notespace) 
			set y 85		
		}
		66 {	;#	F#		
			set x $phf(shrpnotespace) 
			set y 85	
			set sharp $phf(shrpspace)
			set issharp 1
		}
		67 {	;#	G-		
			set x $phf(noteline) 
			set y 80		
		}
		68 {	;#	G#-		
			set x $phf(shrpnoteline) 
			set y 80	
			set sharp $phf(shrpline)
			set issharp 1
		}
		69 {	;#	A		
			set x $phf(notespace) 
			set y 75		
		}
		70 {	;#	A#		
			set x $phf(shrpnotespace) 
			set y 75	
			set sharp $phf(shrpspace)
			set issharp 1
		}
		71 {	;#	B-		
			set x $phf(noteline) 
			set y 70		
		}
		72 {	;#	C		
			set x $phf(notespace) 
			set y 65		
		}
		73 {	;#	C#		
			set x $phf(shrpnotespace) 
			set y 65	
			set sharp $phf(shrpspace)
			set issharp 1
		}
		74 {	;#	D-		
			set x $phf(noteline) 
			set y 60		
		}
		75 {	;#	D#-		
			set x $phf(shrpnoteline) 
			set y 60	
			set sharp $phf(shrpline)
			set issharp 1
		}
		76 {	;#	E		
			set x $phf(notespace) 
			set y 55		
		}
		77 {	;#	F-		
			set x $phf(noteline) 
			set y 50		
		}
		78 {	;#	F#-		
			set x $phf(shrpnoteline) 
			set y 50	
			set sharp $phf(shrpline)
			set issharp 1
		}
		79 {	;#	G		
			set x $phf(notespace) 
			set y 45		
		}
		80 {	;#	G#		
			set x $phf(shrpnotespace) 
			set y 45	
			set sharp $phf(shrpspace)
			set issharp 1
		}
		81 {	;#	A-		
			set x $phf(noteline) 
			set y 40		
		}
		82 {	;#	A#-		
			set x $phf(shrpnoteline) 
			set y 40	
			set sharp $phf(shrpline)
			set issharp 1
		}
		83 {	;#	B		
			set x $phf(notespace) 
			set y 35		
		}
		84 {	;#	C-		
			set x $phf(noteline) 
			set y 30		
		}
		85 {	;#	C#-		
			set x $phf(shrpnoteline) 
			set y 30	
			set sharp $phf(shrpline)
			set issharp 1
		}
		86 {	;#	D		
			set x $phf(notespace) 
			set y 25		
		}
		87 {	;#	D#		
			set x $phf(shrpnotespace) 
			set y 25	
			set sharp $phf(shrpspace)
			set issharp 1
		}
		88 {	;#	E-		
			set x $phf(noteline) 
			set y 20		
		}
	}
	if {$issharp && $phf(flats)} {
		incr y -5
	}
	set xa [expr $x - 4]
	set xb [expr $x + 4]
	set ya [expr $y - 3]
	set yb [expr $y + 3]
	if {$issharp} {
		if {$passing} {
			$can create oval $xa $ya $xb $yb -fill $evv(POINT)  -outline $evv(POINT) -tag {show	sharp}
		} else {
			$can create oval $xa $ya $xb $yb -outline $evv(POINT) -tag {show	sharp}
		}
	} else {
		if {$passing} {
			$can create oval $xa $ya $xb $yb -fill $evv(POINT)  -outline $evv(POINT) -tag show	
		} else {
			$can create oval $xa $ya $xb $yb -outline $evv(POINT) -tag show	
		}
	}
	if {$y > 90} {
		set legpos $y
		if {![IsEven [expr $legpos / 5]]} { 
			incr legpos -5
		}
		while {$legpos > 90} {
			$can create line [expr $x - 7] $legpos [expr $x + 7] $legpos -width 1 -tag show -fill $evv(POINT)
			incr legpos -10
		}
	} elseif {$y < 50} {
		set legpos $y
		if {![IsEven [expr $legpos / 5]]} { 
			incr legpos 5
		}
		while {$legpos < 50} {
			$can create line [expr $x - 7] $legpos [expr $x + 7] $legpos -width 1 -tag show -fill $evv(POINT)
			incr legpos 10
		}
	}
	if {$sharp} {
		if {$phf(flats)} {
			$can create text $sharp $y  -text "b" -font {helvetica 12 bold} -tag show -fill $evv(POINT)
		} else {
			$can create text $sharp $y  -text "#" -font {helvetica 14 bold} -tag show -fill $evv(POINT)
		}
	}
}

#----- Delete any existing hf soundfile for use with a property file

proc DeleteAllPropHFSnds {} {
	global prexpldir evv
	foreach fnam [glob -nocomplain [file join $prexpldir $evv(HFPROP_FNAME)*]] {
		if {[catch {file delete $fnam} zit]} {
			lappend baddeletes $fnam
		}
	}
	if {[info exists baddeletes]} {
		set msg "Cannot Delete The Following Harmonic-Field Files\n\n"
		set cnt 0
		foreach fnam $baddeletes {
			append msg $fnam "\n"
			incr cnt
			if {$cnt >= 20} {
				append msg "AND MORE"
				break
			}
		}
		Inf $msg
		return 0
	}
	return 1
}

#----- Are there any existing hf soundfile for use with a property file

proc PropHFSndsExist {} {
	global prexpldir evv
	foreach fnam [glob -nocomplain [file join $prexpldir $evv(HFPROP_FNAME)*]] {
		lappend fnams $fnam
	}
	if {[info exists fnams]} {
		return 1
	}
	return 0
}

#---- Enter HF as string, leave as list

proc HFSort {hf typ} {
	global phf tp_props_list evv
	catch {unset phf(passing)}
	set hfout {}
	set len [string length $hf]
	if {($len <= 0) || [string match $hf $evv(NULL_PROP)]} {
		return $hfout
	}
	set phf(minmidi) -1
	set j 0
	while {$j < $len} {
		set incrstep 1
		set adjust 0
		set k [expr $j + 1]
		if {$k < $len} {
			if {[string match [string index $hf $k] "#"]} {
				set adjust 1
				set incrstep 2
			}
		}
		set ncode [string index $hf $j]
		switch -- $ncode {
			"F" { set midival 53 ; lappend phf(passing) 0}
			"G" { set midival 55 ; lappend phf(passing) 0}
			"A" { set midival 57 ; lappend phf(passing) 0}
			"B" { set midival 59 ; lappend phf(passing) 0}
			"C" { set midival 60 ; lappend phf(passing) 0}
			"D" { set midival 62 ; lappend phf(passing) 0}
			"E" { set midival 64 ; lappend phf(passing) 0}
			"f" { set midival 53 ; lappend phf(passing) 1}
			"g" { set midival 55 ; lappend phf(passing) 1}
			"a" { set midival 57 ; lappend phf(passing) 1}
			"b" { set midival 59 ; lappend phf(passing) 1}
			"c" { set midival 60 ; lappend phf(passing) 1}
			"d" { set midival 62 ; lappend phf(passing) 1}
			"e" { set midival 64 ; lappend phf(passing) 1}
			default {
				return -1
			}
		}
		incr midival $adjust
		while {$midival < $phf(minmidi)} {
			incr midival 12
		}
		set phf(minmidi) $midival
		if {$midival > $evv(HFMAX_PROP)} {
			lappend badrep [lindex $tp_props_list 0]
		}
		if {$typ == "frq"} {
			lappend hfout [MidiToHz $midival]
		} else {
			lappend hfout $midival
		}
		incr j $incrstep
	}
	if {[info exists badrep]} {
		set msg "Pitches In The Following Harmonic-Fields Go Out Of Representational Range\n(F below treble clef to E above treble clef)\n\n"
		set cnt 0	
		foreach fnam $badrep {
			append msg $fnam "\n"
			incr cnt
			if {$cnt >= 20} {
				append msg "And More"
				break
			}
		}
		Inf $msg
	}
	return $hfout
}

#--- Play HF field graphic in permanent HFgraphics display

proc PlayGraphicFromHFDisplay {withsrc} {
	global phf tp_props_list prg_dun prg_abortd CDPidrun lastsrcfnam pa evv simple_program_messages prexpldir wstk
	global xx_code xx_lineno

	if {![info exists phf(midilist)]} {
		return
	}
	set fnam [file join $prexpldir $evv(HFPROP_FNAME)$phf(lastperm)$evv(SNDFILE_EXT)]
	if {[file exists $fnam]} {
		if {$withsrc} {
			set srcfnam [lindex [lindex $tp_props_list $phf(lastperm)] 0]
			set hfsrcfnam $evv(DFLT_OUTNAME)
			append hfsrcfnam "01" $evv(SNDFILE_EXT)
			set resynth 0
			if [info exists phf(lastplay)] {
				if {($phf(lastperm) != $phf(lastplay))} {
					if {[file exists $hfsrcfnam]} {
						if {![DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0]} {
							return
						}
					}
					set resynth 1
				} elseif {![file exists $hfsrcfnam]} {
					set resynth 1
				} elseif {[info exists lastsrcfnam] && (![string match $lastsrcfnam $srcfnam])} {
					set resynth 1
				}
			} else {
				set resynth 1
			}
			if {$resynth} {
				if {![info exists pa($srcfnam,$evv(CHANS))]} {
					Inf "Need To Know Properties Of Source File: Put Source On Workspace"
					return
				} else {
					set phf(chans) $pa($srcfnam,$evv(CHANS))
				}
				Block "Mixing HF and Source"
				set mixfnam $evv(DFLT_OUTNAME)$evv(TEXT_EXT)
				if [catch {open $mixfnam "w"} zit] {
					Inf "Cannot Open File '$mixfnam' To Create Mixfile For Src And Harmonic Field Sound"
					UnBlock
					return 0
				}
				if {$phf(chans) > 1} {
					set line [list $srcfnam 0 2 .5]
					puts $zit $line
					set line [list $fnam 0 1 .25 C]
					puts $zit $line
				} else {
					set line [list $srcfnam 0 1 1 L]
					puts $zit $line
					set line [list $fnam 0 1 .5 R]
					puts $zit $line
				}
				close $zit	
				set cmd [file join $evv(CDPROGRAM_DIR) submix]
				lappend cmd mix $mixfnam $hfsrcfnam
				set prg_dun 0
				set prg_abortd 0
				catch {unset simple_program_messages}
				if [catch {open "|$cmd"} CDPidrun] {
					ErrShow "Cannot Mix The HF With Source Sound: $CDPidrun"
					catch {unset CDPidrun}
					DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
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
					set msg "Cannot Mix The Hf With Source Sound"
					set msg [AddSimpleMessages $msg]
					ErrShow $msg
					DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
					UnBlock
					return
				}
				DeleteAllTemporaryFilesWhichAreNotCDPOutput except $hfsrcfnam
				UnBlock
			}
			set lastsrcfnam $srcfnam
			PlaySndfile $hfsrcfnam 0
		} else {
			PlaySndfile $fnam 0
		}
	} else {
		set msg "The soundfile for this harmonic-field does not exist : create it?"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			if {![info exists xx_lineno] || ![info exists xx_code]} {
				Inf "Failed to find data to create soundfile"
			} else {
				GeneratePropSingleHFSndfile $xx_lineno $xx_code
			}
		}
		return
	}
	set phf(lastplay) $phf(lastperm)
}

#----- Enter HF data from graphic display

proc Props_CreateHFData {} {
	global pr_phf pm_numidilist pm_passlist pmgrafix nuaddpsnd nuaddpval phf pa wstk evv
	set srcfnam $nuaddpsnd
	set pm_numidilist {}
	set pm_passlist {}
	if {![DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0]} {
		return ""
	}
	catch {unset phf(chans)}
	if {[info exists pa($srcfnam,$evv(CHANS))]} {
		set phf(chans) $pa($srcfnam,$evv(CHANS))
	}
	if {![info exists phf(shrpline)]} {
		set phf(shrpline) 60
		set phf(shrpnoteline) 70 
		set phf(noteline) 110 
		set phf(shrpspace) 160 
		set phf(shrpnotespace) 170 
		set phf(notespace) 210 
	}
	set phf(outcode) ""
	if [catch {eval {toplevel .phfpage} -borderwidth $evv(BBDR)} zorg] {
		ErrShow "Failed to establish Harmonic Field Graphics Window"
		return ""
	}
	set f .phfpage
	wm protocol $f WM_DELETE_WINDOW "set pr_phf 0"
	wm title $f "ENTER HARMONIC FIELD PROPERTY [file rootname [file tail $nuaddpsnd]]"
	set pr_phf 0
	frame $f.0
	frame $f.1
	button $f.0.quit -text "Abandon" -command {set pr_phf 0} -width 7 -highlightbackground [option get . background {}]
	button $f.0.c  -text "C"  -bd 4 -command "PlaySndfile $evv(TESTFILE_C)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.0.db -text "C#" -bd 4 -command "PlaySndfile $evv(TESTFILE_Db) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.0.d  -text "D"  -bd 4 -command "PlaySndfile $evv(TESTFILE_D)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.0.eb -text "D#" -bd 4 -command "PlaySndfile $evv(TESTFILE_Eb) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.0.e  -text "E"  -bd 4 -command "PlaySndfile $evv(TESTFILE_E)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.0.f  -text "F"  -bd 4 -command "PlaySndfile $evv(TESTFILE_F)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.0.gb -text "F#" -bd 4 -command "PlaySndfile $evv(TESTFILE_Gb) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.0.g  -text "G"  -bd 4 -command "PlaySndfile $evv(TESTFILE_G)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.0.ab -text "G#" -bd 4 -command "PlaySndfile $evv(TESTFILE_Ab) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.0.a  -text "A"  -bd 4 -command "PlaySndfile $evv(TESTFILE_A)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.0.bb -text "A#" -bd 4 -command "PlaySndfile $evv(TESTFILE_Bb) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.0.b  -text "B"  -bd 4 -command "PlaySndfile $evv(TESTFILE_B)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.0.c2 -text "C"  -bd 4 -command "PlaySndfile $evv(TESTFILE_C2) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
	button $f.0.k  -text "K" -bg $evv(HELP) -command "Shortcuts hfentry" -width 2 -highlightbackground [option get . background {}]
	button $f.0.flats -text "Flat" -command {HFDisplayFlats 1 0} -width 6 -padx 1 -highlightbackground [option get . background {}]
	button $f.0.vws -text "View Src" -command "PropsSndView hfgrfix" -width 10 -bg $evv(SNCOLOROFF) -highlightbackground [option get . background {}]
	button $f.0.pls -text "Play Src" -command "PlaySndfile $srcfnam 0" -width 10 -highlightbackground [option get . background {}]
	button $f.0.plh -text "Play HF" -command "PropsHFPlayer 0 $srcfnam" -width 10 -highlightbackground [option get . background {}]
	button $f.0.plb -text "Play Both" -command "PropsHFPlayer 1 $srcfnam" -width 10 -highlightbackground [option get . background {}]
	button $f.0.shf -text "Save HF" -command {set phf(outcode) [SaveHFData]} -width 10 -bg $evv(EMPH) -highlightbackground [option get . background {}]
	pack $f.0.k $f.0.flats $f.0.c $f.0.db $f.0.d  $f.0.eb $f.0.e  $f.0.f  $f.0.gb $f.0.g  $f.0.ab $f.0.a  $f.0.bb $f.0.b  $f.0.c2 -side left
	pack $f.0.vws $f.0.pls $f.0.plh $f.0.plb -side left
	pack $f.0.shf -side left
	pack $f.0.quit -side right
	set pmgrafix [EstablishSmallPmarkDisplay $f.1]
	set jj [frame $pmgrafix.f -bd 0]
	$pmgrafix create window 0 0 -anchor nw -window $jj
	button $jj.c -text "Clear" -command {ClearGraphicFromHFDisplay $pmgrafix; set pm_numidilist {}; set pm_passlist {} } -highlightbackground [option get . background {}]
	pack $jj.c -side left -anchor n
	pack $pmgrafix -side top -pady 1
	pack $f.0 $f.1 -side top -fill x -expand true
	raise .phfpage
	update idletasks
	StandardPosition2 .phfpage
	set finished 0
	My_Grab 0 $f pr_phf $pmgrafix
	HFDisplayFlats 1 1
	if {([string length $nuaddpval] > 0) && ![string match $nuaddpval $evv(NULL_PROP)]} {
		if [info exists phf(passing)] {
			set passing $phf(passing)
		}
		set inmidilist [HFSort $nuaddpval midi]
		if {[info exists phf(passing)]} {
			set inpasslist $phf(passing)
		} else {
			set inpasslist {}
		}
		if [info exists passing] {
			set phf(passing) $passing
		}
		if {([llength $inmidilist] <= 0) || ([lindex $inmidilist 0] == -1)} {
			set msg "Previous Code Value Invalid: Delete It ??"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				My_Release_to_Dialog $f
				destroy $f
				return ""
			}
		} else {
			set pm_numidilist $inmidilist
			set pm_passlist $inpasslist
			InsertPitchSmallGrafix $pm_numidilist $pm_passlist $pmgrafix
		}
	}
	while {!$finished} {
		tkwait variable pr_phf
		switch -- $pr_phf {
			-1 {
				continue
			}
			0 {
				set phf(outcode) ""
				if {[string length $nuaddpval] > 0} {
					set phf(outcode) $nuaddpval
				}
				set finished 1
			}
			1 {
				if {![CheckHFData]} {
					continue
				}
				set finished 1
			}
		}
	}
	DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
	My_Release_to_Dialog $f
	destroy $f
	HFDisplayFlats 0 1
	return $phf(outcode)
}

#---- Play newly entered HF code for property

proc PropsHFPlayer {withsrc srcfnam} {
	global evv pm_numidilist pm_passlist last_pm_numidilist prg_dun prg_abortd CDPidrun phf simple_program_messages 

	if {$withsrc} {
		if {![info exists phf(chans)]} {
			set msg "To Use This Option: Need To Know Properties Of The Source Sound.\n\n"
			append msg "Put The Source Sound On The Workspace."
			Inf $msg
			return 0
		} elseif {$phf(chans) > 2} {
			Inf "This Option Only Works With Mono Or Stereo Files"
			return 0
		}
	}
	if {$withsrc} {
		set hfsrcfnam $evv(DFLT_OUTNAME)
		append hfsrcfnam "01" $evv(SNDFILE_EXT)
	}
	foreach note $pm_numidilist passing $pm_passlist {
		lappend checklist $note
		if {!$passing} {
			lappend nulist $note
		}
	}
	if {![info exists nulist] || ([llength $nulist] <= 0)} {
		return 0
	}
	set resynth 0
	if {[info exists last_pm_numidilist]} {
		if {[llength $last_pm_numidilist] == [llength $checklist]} {
			foreach note $checklist {
				if {[lsearch $last_pm_numidilist $note] < 0} {
					set resynth 1
					break
				}
			}
			if {!$resynth} {
				foreach note $last_pm_numidilist {
					if {[lsearch $checklist $note] < 0} {
						set resynth 1
						break
					}
				}
			}
		}
	} else {
		set resynth 1
	}
	if {$resynth} {
		set hffnam $evv(DFLT_OUTNAME)
		append hffnam "00" $evv(SNDFILE_EXT)
		if {[file exists $hffnam]} {
			if [catch {file delete $hffnam} zit] {
				Inf "Cannot Delete Temporary Harmonic Field Soundfile '$hffnam'"
				return 0
			}
		}
		if {$withsrc && [file exists $hfsrcfnam]} {
			if [catch {file delete $hfsrcfnam} zit] {
				Inf "Cannot Delete Temporary HF+Src Soundfile '$hfsrcfnam'"
				return 0
			}
		}
		Block "Resynthesizing Harmonic Field sound"
		set n 0
		set len [llength $nulist]
		set atten [expr (1.0/(double($len))) * 0.3]
		set lonote [lindex $nulist 0]
		foreach note [lrange $nulist 1 end] {
			if {$note < $lonote} {
				set lonote $note
			}
		}
		set oct 0
		while {[expr $lonote - 12] >= $evv(HFMIN_PROP)} {
			incr lonote -12
			incr oct
		}
		if {$oct > 0} {
			set diff [expr 12 * $oct]
			catch {unset nunulist}
			foreach note $nulist {
				lappend nunulist [expr $note - $diff]
			}
			set nulist $nunulist
		}
		foreach note $nulist {
			set oscfnam $evv(DFLT_OUTNAME)$n$evv(SNDFILE_EXT)
			set cmd [file join $evv(CDPROGRAM_DIR) synth]
			lappend cmd wave 1 $oscfnam 44100 1 $evv(HFPROP_DUR) [MidiToHz $note]
			set prg_dun 0
			set prg_abortd 0
			catch {unset simple_program_messages}
			if [catch {open "|$cmd"} CDPidrun] {
				ErrShow "Cannot Create Oscillator [expr $n + 1]: $CDPidrun"
				catch {unset CDPidrun}
				DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
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
				set msg "Cannot Create Oscillator [expr $n + 1]"
				set msg [AddSimpleMessages $msg]
				ErrShow $msg
				DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
				UnBlock
				return 0
			}

			;#	WRITE DATA FOR SUBSEQUENT-MIX

			set line [list $oscfnam 0 1 $atten C]
			lappend mixlines $line
			incr n
		}
		DeleteAllTemporaryFilesWhichAreNotCDPOutput text 0

		;#	CREATE THE MIXFILE TO COMBINE THE OSCILLATORS

		set mixfnam $evv(DFLT_OUTNAME)$evv(TEXT_EXT)
		if [catch {open $mixfnam "w"} zit] {
			Inf "Cannot Open File '$mixfnam' To Create Mixfile For Oscillators For Harmonic Field Sounds"
			DeleteAllTemporaryFilesWhichAreNotCDPOutput snd 0
			UnBlock
			return 0
		}
		foreach line $mixlines {
			puts $zit $line
		}
		close $zit	

			;#	MIX THE OSCILLATORS

		set cmd [file join $evv(CDPROGRAM_DIR) submix]
		lappend cmd mix $mixfnam $hffnam
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		if [catch {open "|$cmd"} CDPidrun] {
			ErrShow "Cannot Mix The Oscillators: $CDPidrun"
			catch {unset CDPidrun}
			DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
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
			set msg "Cannot Mix The Oscillators"
			set msg [AddSimpleMessages $msg]
			ErrShow $msg
			DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
			UnBlock
			return 0
		}
		DeleteAllTemporaryFilesWhichAreNotCDPOutput except $hffnam
	}
	if {$withsrc} {
		if {$resynth || ![file exists $hfsrcfnam]} {
			set mixfnam $evv(DFLT_OUTNAME)$evv(TEXT_EXT)
			if [catch {open $mixfnam "w"} zit] {
				Inf "Cannot Open File '$mixfnam' To Create Mixfile For Src And Harmonic Field Sound"
				UnBlock
				return 0
			}
			if {$phf(chans) > 1} {
				set line [list $srcfnam 0 2 .5]
				puts $zit $line
				set line [list $hffnam 0 1 .25 C]
				puts $zit $line
			} else {
				set line [list $srcfnam 0 1 1 L]
				puts $zit $line
				set line [list $hffnam 0 1 .5 R]
				puts $zit $line
			}
			close $zit	
			set cmd [file join $evv(CDPROGRAM_DIR) submix]
			lappend cmd mix $mixfnam $hfsrcfnam
			set prg_dun 0
			set prg_abortd 0
			catch {unset simple_program_messages}
			if [catch {open "|$cmd"} CDPidrun] {
				ErrShow "Cannot Mix The HF With Source Sound: $CDPidrun"
				catch {unset CDPidrun}
				DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
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
				set msg "Cannot Mix The Hf With Source Sound"
				set msg [AddSimpleMessages $msg]
				ErrShow $msg
				DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
				UnBlock
				return 0
			}
			DeleteAllTemporaryFilesWhichAreNotCDPOutput except [list $hffnam $hfsrcfnam]
		}
	}
	UnBlock
	if {$withsrc} {
		PlaySndfile $hfsrcfnam 0
	} else {
		PlaySndfile $hffnam 0
	}
	return 1
}

#---- Save the entered HF property midi data as an HF code

proc SaveHFData {} {
	global pm_numidilist pm_passlist pr_phf evv
	if {![info exists pm_numidilist] || ([llength $pm_numidilist] <=0)} {
		Inf "No Harmonic Field Data To Save"	
		return ""
	}
	set len [llength $pm_numidilist]
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set midi_n [lindex $pm_numidilist $n]
		set pass_n [lindex $pm_passlist $n]
		set m $n
		incr m
		while {$m < $len} {
			set midi_m [lindex $pm_numidilist $m]
			set pass_m [lindex $pm_passlist $m]
			if {$midi_n > $midi_m} {
				set pm_numidilist [lreplace $pm_numidilist $n $n $midi_m]
				set pm_numidilist [lreplace $pm_numidilist $m $m $midi_n]
				set pm_passlist [lreplace $pm_passlist $n $n $pass_m]
				set pm_passlist [lreplace $pm_passlist $m $m $pass_n]
				set midi_n $midi_m
				set pass_n $pass_m
			}
			incr m
		}
		incr n
	}
	set firstval [lindex $pm_numidilist 0]
	set oct [expr ($firstval - $evv(HFMIN_PROP))/12]
	set firstval [expr $firstval - ($oct * 12)]
	set lastval $firstval
	set isvalid 0
	set code ""
	foreach val $pm_numidilist passing $pm_passlist {
		while {$val < $lastval} {
			incr val 12
		}
		if {$passing} {
			switch -- $val {
				53	{ append code f }
				54	{ append code f# }
				55	{ append code g }
				56	{ append code g# }
				57	{ append code a }
				58	{ append code a# }
				59	{ append code b }
				60	{ append code c }
				61	{ append code c# }
				62	{ append code d }
				63	{ append code d# }
				64	{ append code e }
				65	{ append code f }
				66	{ append code f# }
				67	{ append code g }
				68	{ append code g# }
				69	{ append code a }
				70	{ append code a# }
				71	{ append code b }
				72	{ append code c }
				73	{ append code c# }
				74	{ append code d }
				75	{ append code d# }
				76	{ append code e }
				77	{ append code f }
				78	{ append code f# }
				79	{ append code g }
				80	{ append code g# }
				81	{ append code a }
				82	{ append code a# }
				83	{ append code b }
				84	{ append code c }
				85	{ append code c# }
				86	{ append code d }
				87	{ append code d# }
				88	{ append code e }
				default {
					Inf "Midi Value Outside Range: Cannot Encode"
					return ""
				}
			}
		} else {
			set isvalid 1
			switch -- $val {
				53	{ append code F }
				54	{ append code F# }
				55	{ append code G }
				56	{ append code G# }
				57	{ append code A }
				58	{ append code A# }
				59	{ append code B }
				60	{ append code C }
				61	{ append code C# }
				62	{ append code D }
				63	{ append code D# }
				64	{ append code E }
				65	{ append code F }
				66	{ append code F# }
				67	{ append code G }
				68	{ append code G# }
				69	{ append code A }
				70	{ append code A# }
				71	{ append code B }
				72	{ append code C }
				73	{ append code C# }
				74	{ append code D }
				75	{ append code D# }
				76	{ append code E }
				77	{ append code F }
				78	{ append code F# }
				79	{ append code G }
				80	{ append code G# }
				81	{ append code A }
				82	{ append code A# }
				83	{ append code B }
				84	{ append code C }
				85	{ append code C# }
				86	{ append code D }
				87	{ append code D# }
				88	{ append code E }
				default {
					Inf "Midi Value Outside Range: Cannot Encode"
					return ""
				}
			}
		}
		set lastval $val
	}
	if {!$isvalid} {
		Inf "You Cannot Use Only Passing Notes"
		return ""
	}
	set pr_phf 1
	return $code
}

#---- Check validity of HF property code returned, and exit or not the Dialog box for ewntering HF data

proc CheckHFData {} {
	global phf
	if {[string length $phf(outcode)] > 0} {
		return 1
	}
	Inf "No HF Code To Save"
	return 0
}

#------ Establish interactive pitchstaff notation display

proc EstablishSmallPmarkDisplay {pstaff} {
	global pr_pnscreen pnscreen pnscrlist pnscrlist_out pnscreenval pnfilename pnscreencnt evv

	#	CANVAS AND VALUE LISTING

	set pnscreen [canvas $pstaff.c -height 144 -width 300 -borderwidth 0 -highlightthickness 1 -highlightbackground $evv(SPECIAL)]

	$pnscreen create line 20  20 280 20 -tag notehite				-fill [option get . background {}]
	$pnscreen create line 20  25 280 25 -tag {notehite sharphite}	-fill [option get . background {}]
	$pnscreen create line 20  30 280 30 -tag {notehite sharphite}	-fill [option get . background {}]
	$pnscreen create line 20  35 280 35 -tag notehite				-fill [option get . background {}]
	$pnscreen create line 20  40 280 40 -tag {notehite sharphite}	-fill [option get . background {}]
	$pnscreen create line 20  45 280 45 -tag {notehite sharphite}	-fill [option get . background {}]
	$pnscreen create line 20  50 280 50 -tag {notehite sharphite}	-fill $evv(POINT)	
	$pnscreen create line 20  55 280 55 -tag  notehite				-fill [option get . background {}]
	$pnscreen create line 20  60 280 60 -tag {notehite sharphite}	-fill $evv(POINT) 
	$pnscreen create line 20  65 280 65 -tag {notehite sharphite}	-fill [option get . background {}]
	$pnscreen create line 20  70 280 70 -tag notehite				-fill $evv(POINT)
	$pnscreen create line 20  75 280 75 -tag {notehite sharphite}	-fill [option get . background {}]
	$pnscreen create line 20  80 280 80 -tag {notehite sharphite}	-fill $evv(POINT)
	$pnscreen create line 20  85 280 85 -tag {notehite sharphite}	-fill [option get . background {}]
	$pnscreen create line 20  90 280 90 -tag notehite				-fill $evv(POINT)
	$pnscreen create line 20  95 280 95 -tag {notehite sharphite}	-fill [option get . background {}]
	$pnscreen create line 20  100 280 100 -tag {notehite sharphite} -fill [option get . background {}]
	$pnscreen create line 20  105 280 105 -tag notehite				-fill [option get . background {}]
	$pnscreen create line 20  110 280 110 -tag {notehite sharphite} -fill [option get . background {}]
	$pnscreen create line 20  115 280 115 -tag {notehite sharphite} -fill [option get . background {}]
	$pnscreen create line 20  120 280 120 -tag {notehite sharphite} -fill [option get . background {}]

	$pnscreen create line 40  40 40 105 -width 1 -fill $evv(POINT)
	$pnscreen create arc 40 34 52 46 -style arc -start 180 -extent -230 -width 1 -outline $evv(POINT)
	$pnscreen create line 48  45 30 80 -width 1 -fill $evv(POINT)
	$pnscreen create arc 30 70 50 90 -style arc -start 180 -extent 270 -width 1 -outline $evv(POINT)

	bind $pnscreen <ButtonRelease-1> {PsmallgrafixAddPitch $pnscreen %x %y 0 0}
	bind $pnscreen <Shift-ButtonRelease-1> {PsmallgrafixAddPitch $pnscreen %x %y 1 0}
	bind $pnscreen <Command-ButtonRelease-1> {PsmallgrafixAddPitch $pnscreen %x %y 0 1}
	bind $pnscreen <Command-Shift-ButtonRelease-1> {PsmallgrafixAddPitch $pnscreen %x %y 1 1}
	bind $pnscreen <Control-ButtonRelease-1> {PsmallgrafixDelPitch $pnscreen %x %y}

	return $pnscreen
}

#----- Add notes to graphic display with mouse

proc PsmallgrafixAddPitch {w x y sharp passing} {
	global pm_numidilist pm_passlist
	if {$sharp} {
		set displaylist [$w find withtag sharphite]	;#	List all objects which are points
	} else {
		set displaylist [$w find withtag notehite]	;#	List all objects which are points
	}
	set mindiff 100000								;#	Find closest point
	foreach thisobj $displaylist {
		set coords [$w coords $thisobj]
		set yy [lindex $coords 1]
		set diff [expr abs($y - $yy)]
		if {$diff < $mindiff} {
			set yyy $yy
			set mindiff $diff
		}
	}
	if {![info exists yyy]} {
		return
	}
	set thismidi [GetNuPitchFromSmallMouseClikHite [expr int(round($yyy))] 0]
	if {$thismidi < 0} {
		return
	}
	if {$sharp} {
		incr thismidi 1
	}
	lappend pm_numidilist $thismidi
	lappend pm_passlist $passing
	set len [llength $pm_numidilist]
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set midi_n [lindex $pm_numidilist $n]
		set pass_n [lindex $pm_passlist $n]
		set m $n
		incr m
		while {$m < $len} {
			set midi_m [lindex $pm_numidilist $m]
			set pass_m [lindex $pm_passlist $m]
			if {$midi_m > $midi_n} {
				set pm_numidilist [lreplace $pm_numidilist $m $m $midi_n]
				set pm_numidilist [lreplace $pm_numidilist $n $n $midi_m]
				set midi_n $midi_m
				set pm_passlist [lreplace $pm_passlist $m $m $pass_n]
				set pm_passlist [lreplace $pm_passlist $n $n $pass_m]
				set pass_n $pass_m
				incr m
			} elseif {$midi_m == $midi_n} {
				set pm_numidilist [lreplace $pm_numidilist $m $m]
				set pm_passlist [lreplace $pm_passlist $m $m]
				incr len -1
				incr len_less_one -1
			} else {
				incr m
			}
		}
		incr n
	}
	ClearPitchSmallGrafix $w
	InsertPitchSmallGrafix $pm_numidilist $pm_passlist $w
}

#----- Convert mouse click to midi value to display

proc GetNuPitchFromSmallMouseClikHite {hite del} {
	if {$del} {
		incr hite 3
	}
	switch -- $hite {
		20  { return 88 }
		25  { return 86 }
		30  { return 84 }
		35  { return 83 }
		40  { return 81 }
		45  { return 79 }
		50  { return 77	}
		55  { return 76	}
		60  { return 74	}
		65  { return 72	}
		70  { return 71	}
		75  { return 69	}
		80  { return 67	}
		85  { return 65	}
		90  { return 64	}
		95  { return 62 } 
		100 { return 60	} 
		105 { return 59	} 
		110 { return 57	} 
		115 { return 55	}
		120 { return 53	}
	}
	return -1
}

#----- Draw note on HF prop graphics display

proc InsertPitchSmallGrafix {midilist passlist can} {
	global maxpcol evv
	if {[llength $midilist] <= 0} {
		return
	}
	set len [llength $midilist]
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set midi_n [lindex $midilist $n]
		set pass_n [lindex $passlist $n]
		set m $n
		incr m
		while {$m < $len} {
			set midi_m [lindex $midilist $m]
			set pass_m [lindex $passlist $m]
			if {$midi_m > $midi_n} {
				set midilist [lreplace $midilist $m $m $midi_n]
				set midilist [lreplace $midilist $n $n $midi_m]
				set midi_n $midi_m
				set passlist [lreplace $passlist $m $m $pass_n]
				set passlist [lreplace $passlist $n $n $pass_m]
				set pass_n $pass_m
			}
			incr m
		}
		incr n
	}
	foreach midival $midilist passing $passlist {
		MidiToPHFpos $can $midival $passing
	}
}

#----- Delete note on HF prop graphics display

proc PsmallgrafixDelPitch {w x y} {
	global pm_numidilist pm_passlist pmgrafix
	set displaylist [$w find withtag show]	;#	List all objects which are notes
	set sharplist   [$w find withtag sharp]	;#	List all objects which are flats

	set mindiffx 100000								;#	Find closest note
	set mindiffy 100000
	foreach thisobj $displaylist {
		set coords [$w coords $thisobj]
		set xx [lindex $coords 0]
		set yy [lindex $coords 1]
		set diff [expr abs($y - ($yy + 3))]
		if {$diff < $mindiffy} {
			set yyy $yy
			if {[lsearch -exact $sharplist $thisobj] >= 0} {			;#	If the note is sharp
				set sharp 1
			} else {
				set sharp 0
			}
			set mindiffy $diff
			set mindiffx [expr abs($x - $xx)]
		} elseif {$diff == $mindiffy} {
			set diff [expr abs($x - $xx)]
			if {$diff < $mindiffx} {
				set mindiffx $diff
				set yyy $yy
				if {[lsearch -exact $sharplist $thisobj] >= 0} {			;#	If the note is sharp
					set sharp 1
				} else {
					set sharp 0
				}
			}
		}
	}
	if {![info exists yyy]} {
		return
	}
	set thismidi [GetNuPitchFromSmallMouseClikHite [expr int(round($yyy))] 1]
	if {$thismidi < 0} {
		return
	}
	if {$sharp} {
		incr thismidi
	}
	set k [lsearch $pm_numidilist $thismidi]
	if {$k < 0} {
		return
	}
	set pm_numidilist [lreplace $pm_numidilist $k $k]
	set pm_passlist  [lreplace $pm_passlist $k $k]
	ClearPitchSmallGrafix $w
	InsertPitchSmallGrafix $pm_numidilist $pm_passlist $w
}


#---- Clear all notes from VaribankGrafix display

proc ClearPitchSmallGrafix {w} {
	catch {$w delete show}
}

#---- Display Flats instead of Sharps and v.v.

proc HFDisplayFlats {fromhf inverse} {
	global phf pnscreen pm_numidilist pm_passlist
	set thistext [$phf(can2).f.f cget -text]
	set thisname [$phf(can2).f.ll cget -text]
	switch -- $thistext {
		"Flat" {
			if {$inverse} {
				if [winfo exists .phfpage] {
					.phfpage.0.db config -text "C#"
					.phfpage.0.eb config -text "D#"
					.phfpage.0.gb config -text "F#"
					.phfpage.0.ab config -text "G#"
					.phfpage.0.bb config -text "A#"
					.phfpage.0.flats config -text "Flat"
				}			
			} else {
				set phf(flats) 1
				$phf(can2).f.f config -text "#"
				if [winfo exists .phfpage] {
					.phfpage.0.db config -text "Db"
					.phfpage.0.eb config -text "Eb"
					.phfpage.0.gb config -text "Gb"
					.phfpage.0.ab config -text "Ab"
					.phfpage.0.bb config -text "Bb"
					.phfpage.0.flats config -text "#"
				}
			}		
		}
		"#" {
			if {$inverse} {
				if [winfo exists .phfpage] {
					.phfpage.0.db config -text "Db"
					.phfpage.0.eb config -text "Eb"
					.phfpage.0.gb config -text "Gb"
					.phfpage.0.ab config -text "Ab"
					.phfpage.0.bb config -text "Bb"
					.phfpage.0.flats config -text "#"
				}			
			} else {
				set phf(flats) 0
				$phf(can2).f.f config -text "Flat"
				if [winfo exists .phfpage] {
					.phfpage.0.db config -text "C#"
					.phfpage.0.eb config -text "D#"
					.phfpage.0.gb config -text "F#"
					.phfpage.0.ab config -text "G#"
					.phfpage.0.bb config -text "A#"
					.phfpage.0.flats config -text "Flat"
				}			
			}
		}
	}
	if {[info exists phf(midilist)]} {
		set midilist $phf(midilist)
		set passlist $phf(passlist)
		if {[info exists phf(lastperm)]} { 		
			set lastperm $phf(lastperm)
		}
		ClearGraphicFromHFDisplay $phf(can2)
		$phf(can2).f.ll config -text $thisname
		foreach midival $midilist passing $passlist {
			MidiToPHFpos $phf(can2) $midival $passing
		}
		set phf(midilist) $midilist
		set phf(passlist) $passlist
		if {[info exists lastperm]} { 		
			set phf(lastperm) $lastperm
		}
	}
	if {[winfo exists .phfpage] && ([llength $pm_numidilist] > 0)} {
		ClearPitchSmallGrafix $pnscreen
		InsertPitchSmallGrafix $pm_numidilist $pm_passlist $pnscreen
	}
}

#--- Generate a sndfile corresponding to newly entered HF property

proc GeneratePropSingleHFSndfile {lineno hf} {
	global tp_props_list prg_dun prg_abortd CDPidrun phf wstk evv simple_program_messages prexpldir createdhf
	set outfnam [file join $prexpldir $evv(HFPROP_FNAME)$lineno$evv(SNDFILE_EXT)]
	if {[file exists $outfnam]} {
		set msg "Harmonic-Field Soundfiles Already Exists: Rewrite It ?"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		} elseif {[catch {file delete $outfnam} zit]} {
			Inf "Cannot Delete Existing HF Sound"
			return
		}
	}
	set line [lindex $tp_props_list	$lineno]
	set hf [HFSort $hf frq]
	if {[llength $hf] <= 0} {
		Inf "No Harmonic Field Data For Sound [lindex $lineno 0]"
		return
	} else {
		if {[string match [lindex $hf 0] "-1"]} {
			Inf "Invalid Harmonic Field Data '$hf' For Sound [lindex $line 0]"
			return
		}
		foreach note $hf passing $phf(passing) {
			if {!$passing} {
				lappend nuhf $note
			}
		}
		set hf $nuhf
		if {[llength $hf] <= 0} {
			Inf "Invalid Harmonic Field Data (All Passsing Notes) '$hf' For Sound [lindex $line 0]"
			return
		}
	}
	set osccnt [llength $hf]
	set env [expr 1.0 / double($osccnt)]

	Block "Creating HF soundfile"

		;#	CREATE THE NECESSARY ENVELOPE

	set brkpair [list 0 0]
	lappend outenv $brkpair
	set brkpair [list $evv(HFPROP_SPLICETIME) $env]
	lappend outenv $brkpair
	set thistime [expr $evv(HFPROP_DUR) - $evv(HFPROP_SPLICETIME)]	
	set brkpair [list $thistime $env]							
	lappend outenv $brkpair
	set brkpair [list $evv(HFPROP_DUR) 0]
	lappend outenv $brkpair

	set envfnam $evv(DFLT_OUTNAME)$evv(TEXT_EXT)
	if [catch {open $envfnam "w"} zit] {
		Inf "Cannot Open File '$envfnam' To Write Harmonic Field Envelope Data"
		UnBlock
		return
	}
	foreach line $outenv {
		puts $zit $line
	}
	close $zit	

	set n 0
	while {$n < $osccnt} {
		set oscfnam $evv(DFLT_OUTNAME)$n$evv(SNDFILE_EXT)
		set cmd [file join $evv(CDPROGRAM_DIR) synth]
		lappend cmd wave 1 $oscfnam 44100 1 $evv(HFPROP_DUR) [lindex $hf $n] -a$envfnam
		set prg_dun 0
		set prg_abortd 0
		catch {unset simple_program_messages}
		if [catch {open "|$cmd"} CDPidrun] {
			ErrShow "Cannot Create Oscillator [expr $n + 1]: $CDPidrun"
			catch {unset CDPidrun}
			DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
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
			set msg "Cannot Create Oscillator [expr $n + 1]"
			set msg [AddSimpleMessages $msg]
			ErrShow $msg
			DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
			UnBlock
			return
		}

		;#	WRITE DATA FOR SUBSEQUENT-MIX

		set line [list $oscfnam 0 1 .3 C]
		lappend mixlines $line
		incr n
	}

	DeleteAllTemporaryFilesWhichAreNotCDPOutput text 0

		;#	CREATE THE MIXFILE TO COMBINE THE OSCILLATORS

	set mixfnam $evv(DFLT_OUTNAME)$evv(TEXT_EXT)
	if [catch {open $mixfnam "w"} zit] {
		Inf "Cannot Open File '$mixfnam' To Create Mixfile For Oscillators For Harmonic Field Sound"
		DeleteAllTemporaryFilesWhichAreNotCDPOutput snd 0
		UnBlock
		return
	}
	foreach line $mixlines {
		puts $zit $line
	}
	close $zit	

		;#	MIX THE OSCILLATORS

	set cmd [file join $evv(CDPROGRAM_DIR) submix]
	lappend cmd mix $mixfnam $outfnam
	set prg_dun 0
	set prg_abortd 0
	catch {unset simple_program_messages}
	if [catch {open "|$cmd"} CDPidrun] {
		ErrShow "Cannot Mix The Oscillators: $CDPidrun"
		catch {unset CDPidrun}
		DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
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
		set msg "Cannot Mix The Oscillators"
		set msg [AddSimpleMessages $msg]
		ErrShow $msg
		DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
		UnBlock
		return
	}

	DeleteAllTemporaryFilesWhichAreNotCDPOutput except $outfnam
	UnBlock
	Inf "Harmonic Field Soundfile Created"
	set createdhf 1
	return
}

########################################
# PROPERTY TABLE, TEXT PROPERTY SEARCH #
########################################

#--- Search text-property for defined string

proc PropTextSearch {} {
	global proptxtsrch textprops lasproptxtfind hastextprop proptxtsrch_home tp_bfw tp_props_list tp_can evv
	global origproptxtsfind lastproptxtsrch origproptxtsrch proplastplay
	if {[string length $proptxtsrch] <= 0} {
		Inf "No Search String Entered"
		return
	}
	set proptxtsrch [string tolower $proptxtsrch]
	set textslen [llength $textprops]
#KLUDGE TO MAKE CANVAS DISPLAY, AT ITS TOP, SNDFILE BEING PLAYED : + 6 is a kludge
	set canvlen [expr $textslen + 6]
	if {![info exists origproptxtsfind] || ![string match $proptxtsrch $origproptxtsrch]} {
		set lastindex 0
		set lastcharpos 0
	} else {
		set lastindex [lindex $lasproptxtfind 0]
		set lastcharpos [lindex $lasproptxtfind 1]
	}
	if {$lastindex >= $textslen} {		;#	ERROR TRAP
		set lastindex 0
		set lastcharpos 0
	}
	set n $lastindex
	set m [expr $n + 1]
	set startindex $lastindex
	foreach txt [lrange $textprops $lastindex end] {
		set len [string length $txt]
		set k [string first $proptxtsrch [string tolower [string range $txt $lastcharpos end]]]
		if {$k >= 0} {
			set lastindex $n
			incr lastcharpos [expr $k + [string length $proptxtsrch]]
			if {$lastcharpos >= $len} {
				set lastcharpos 0
				incr lastindex
				if {$lastindex > $textslen} {
					set lastindex 0
				}
			}
			set lasproptxtfind [list $lastindex $lastcharpos]
			if {![info exists lastproptxtsrch] || ![string match $proptxtsrch $lastproptxtsrch]} {
				set origproptxtsfind $lasproptxtfind
				set origproptxtsrch $proptxtsrch
			}
			$tp_can yview moveto [expr double($n)/double($canvlen)]
			set proptxtsrch_home [list $m $hastextprop]
			set snd [lindex [lindex $tp_props_list $n] 0]
			PlaySndfile $snd 0
			set proplastplay $snd
			DoPropsFlash $m
			set lastproptxtsrch $proptxtsrch
			return
		} else {
			set lastcharpos 0
		}
		incr n
		incr m
	}
	if {$startindex > 0} {
		set kk $lastindex
		set n 0
		set m 1
		set lastindex 0
		set lastcharpos 0
		foreach txt [lrange $textprops $lastindex $kk] {
			set len [string length $txt]
			set k [string first $proptxtsrch [string tolower [string range $txt $lastcharpos end]]]
			if {$k >= 0} {
				set lastindex $n
				incr lastcharpos [expr $k + [string length $proptxtsrch]]
				if {$lastcharpos >= $len} {
					set lastcharpos 0
					incr lastindex
					if {$lastindex > $textslen} {
						set lastindex 0
						set n 0
						set m 1
					}
				}
				if {[info exists origproptxtsfind] \
				&& [info exists lastproptxtsrch] && [string match $proptxtsrch $lastproptxtsrch]} {
					if {($n == [lindex $origproptxtsfind 0]) && ($lastcharpos == [lindex $origproptxtsfind 1])} {
						Inf "No More Matches"
						unset lastproptxtsrch
						unset origproptxtsfind
						return
					}
				}
				set lasproptxtfind [list $lastindex $lastcharpos]
				if {![info exists lastproptxtsrch] || ![string match $proptxtsrch $lastproptxtsrch]} {
					set origproptxtsfind $lasproptxtfind
				}
				$tp_can yview moveto [expr double($n)/double($canvlen)]
				set proptxtsrch_home [list $m $hastextprop]
				set snd [lindex [lindex $tp_props_list $n] 0]
				PlaySndfile $snd 0
				set proplastplay $snd
				DoPropsFlash $m
				set lastproptxtsrch $proptxtsrch
				return
			} else {
				set lastcharpos 0
			}
			incr n
			incr m
		}
	}
	Inf "Not Found"
}

#--- Stop Search text-property (i.e. uncolour any found text)

proc PropTextSearchEnd {} {
	global proptxtsrch_home textprops tp_bfw
	if {[info exists proptxtsrch_home]} {
		set m [lindex $proptxtsrch_home 1]
#ERROR TRAP: UNKNOWN CAUSE OF ERROR
		if {$m >= [llength $textprops]} {
			return
		}
	}
}

###########################################
# SELECTING SOUNDS ON BASIS OF PROPERTIES #
###########################################

#--- Select which property to access, using up-down arrows

proc PropNameSelect {up} {
	global propnsel tp_props_cnt tp_propnames getsndprpn getsndprpc proptab_f
	set lim [expr $tp_props_cnt - 2]
	if {$up} {
		incr propnsel
		if {$propnsel > $lim} {
			set propnsel 0
		}
	} else {
		incr propnsel -1
		if {$propnsel < 0} {
			set propnsel $lim
		}
	}
	set getsndprpn [lindex $tp_propnames $propnsel]
	if {[string match -nocase $getsndprpn "hf"]} {
		set getsndprpc 0
		$proptab_f.radio.gtt.2.getall config -state disabled -text ""
	} else {
		$proptab_f.radio.gtt.2.getall config -state normal -text "(vals include)"
		set getsndprpc 1
	}
}

#----- Get Sounds on the basis of their property values

proc GetSndsOnPropval {tofile} {
	global propnsel getsndprpv getsndprpn getsndprpc tp_props_list pr_prselsnd sel_doquit readonlyfg readonlybg propaud_tfil propaud_nu_tfil wstk evv
	global propaud propaudsel pr_proptab ch chlist propaud_done propaud_index propaud_snds propaud_nu_snds propaudhf propaudhfpass proppos
	global tp_propnames propaudrcaugdim propaudhom propaudmin propaudmax propaudfrac propaud_frac propaudrcode propaudtrans propaud_rh wl

	set proppos [expr $propnsel + 1]
	set inval [string trim $getsndprpv]
	catch {unset propaud_snds}
	catch {unset propaud_nu_snds}
	catch {unset propaud_tfil}
	catch {unset propaud_nu_tfil}
	if {[string length $inval] <= 0} {
		Inf "No Property Value Entered"
		return
	}
	set starred 0
	if {[regexp {\*} $inval]} {
		if {[regexp {^\*$} $inval]} {
			set starred 1
		} elseif {[regexp {^\*\*$} $inval]} {
			set starred 2
		} else {	
			set	msg "'*' And '**' Can Only Be Used As Search Strings By Themselves.\n\n"
			append msg"'*' Finds All Items With 1 Or More Stars.\n"
			append msg"'**' Finds Only Double Stars.\n"
			Inf $msg
			return
		}
	}
	set tonicmatch 0
	set inminor 0
	if {[string match -nocase $getsndprpn "tonic"]} {
		if {![ValidTonicString $inval]} {
			Inf "Invalid Tonic String"
			return
		}
		set tonicmatch 1
		if {[string match [string index $inval end] "m"]} {
			set inminor 1
			if {$getsndprpc && !$starred} {				;#	IGNORE minor/major divide if comparison is "includes"
				set inval [string range $inval 0 [expr [string length $inval] - 2]]
			}
		}
	} elseif {[string match -nocase $getsndprpn "text"]} {
		if {[string first "_" $getsndprpv] >= 0} {
			Inf "You Cannot Use Underscores (\"_\") In The Text Property"
			return
		}
	} elseif {[string match -nocase $getsndprpn "motif"]} {
		if {![string match $getsndprpv "yes"]} {
			Inf "No Motif To Compare"
			return
		}
		if {![SetPropaudMaxMotif]} {
			return
		}
	}
	if {!([string match -nocase $getsndprpn "hf"] \
	|| [string match -nocase $getsndprpn "rcode"] \
	|| [string match -nocase $getsndprpn "motif"] \
	|| [string match -nocase $getsndprpn "text"])} {
		set n 0		
		foreach line $tp_props_list {
			set val [lindex $line $proppos]
			switch -- $getsndprpc {
				0 {
					if {![string compare $val $inval]} {
						lappend propaud_tfil $n
						lappend propaud_snds [lindex $line 0]
					}
				}
				1 {
					switch -- $starred {
						0 {
							if {[string match -nocase $getsndprpn "tonic"]} {
								set vals [SplitTonicProperty $val]
							} else {
								set vals [SplitProperty $val]
							}
							foreach val $vals {
								if {$tonicmatch && [string match [string index $val end] "m"]} {	;#	IGNORE major/minor distinction
									set val [string range $val 0 [expr [string length $val] - 2]]
								}
								if {![string compare $val $inval]} {
									lappend propaud_tfil $n
									lappend propaud_snds [lindex $line 0]
									break
								}
							}
						}
						1 {
							if {[regexp {\*} $val]} {
								lappend propaud_tfil $n
								lappend propaud_snds [lindex $line 0]
							}
						}
						2 {
							if {[regexp {\*\*} $val]} {
								lappend propaud_tfil $n
								lappend propaud_snds [lindex $line 0]
							}
						}
					}
				}
			}
			incr n
		}
		if {![info exists propaud_snds]} {
			if {$getsndprpc} {
				Inf "No Sounds Contain The String \"$getsndprpv\" Within Any Value For The Property \"$getsndprpn\""
			} else {
				Inf "No Sounds Have The Value \"$getsndprpv\" For The Property \"$getsndprpn\""
			}
			return
		}
		if {[llength $propaud_snds] == 1} {
			if {![string match $tofile "0"]} {
				CreateSubPropfile $tofile $tp_propnames $propaud_tfil
				return
			} else {
				set fnam [lindex $propaud_snds 0]
				set i [LstIndx $fnam $wl]
				if {$i < 0} {
					if {[FileToWkspace $fnam 0 0 0 1 0] <= 0} {
						Inf "Cannot Grab File '$fnam' To The Workspace"
						return
					}
				}
				DoChoiceBak
				$ch delete 0 end
				catch {unset chlist}
				$ch insert end $fnam
				lappend chlist $fnam
				set pr_proptab 0
				return
			}
		}
	}
	set propaudhf -1
	set f .prselsnd
	if [Dlg_Create $f "SELECT SOUNDS" "set pr_prselsnd 0" -borderwidth $evv(BBDR)] {
		frame $f.1 -borderwidth $evv(BBDR)
		frame $f.2 -borderwidth $evv(BBDR)
		frame $f.3 -borderwidth $evv(BBDR)
		button $f.1.q -text "Abandon" -command {set propaud_done 1; set propaud_snds {}; set propaud_tfil {}; set pr_prselsnd 0} -width 9 -highlightbackground [option get . background {}]
		button $f.1.a -text "Keep All" -command {set pr_prselsnd 2} -width 9 -highlightbackground [option get . background {}]
		button $f.1.ll -text "Listen & Select" -command {set pr_prselsnd 1} -width 16 -highlightbackground [option get . background {}]
		pack $f.1.q -side right
		pack $f.1.a $f.1.ll -side left -pady 2
		pack $f.1 -side top -fill x -expand true
		entry $f.2.e -textvariable propaud -state readonly -width 24 -bd 0 -fg $readonlyfg -readonlybackground $readonlybg
		radiobutton $f.2.sel -text keep -variable propaudsel -value 1 -command {PropAudSel 0} -state disabled
		radiobutton $f.2.rej -text reject -variable propaudsel -value 0 -command {PropAudSel 0} -state disabled
		button $f.2.keep -text "Keep These" -command {PropAudSel 1} -highlightbackground [option get . background {}]
		pack $f.2.e -side left
		pack $f.2.rej $f.2.sel -side right
		pack $f.2 -side top
		if {[string match -nocase $getsndprpn "hf"]} {
			radiobutton $f.3.same -text "Is The Same as" -variable propaudhf -value 0 -command "PropAudHF $tofile"
			radiobutton $f.3.incs -text "Includes" -variable propaudhf -value 1 -command "PropAudHF $tofile"
			radiobutton $f.3.incm -text "Includes Most of" -variable propaudhf -value 3 -command "PropAudHF $tofile"
			radiobutton $f.3.incd -text "Is Included by" -variable propaudhf -value 2 -command "PropAudHF $tofile"
			radiobutton $f.3.incb -text "Is Mostly Included by" -variable propaudhf -value 4 -command "PropAudHF $tofile"
			label $f.3.this -text "THIS HF"
			checkbutton $f.3.pass -text "Including Passing Notes" -variable propaudhfpass
			pack $f.3.same $f.3.incs $f.3.incm $f.3.incd $f.3.incb $f.3.this $f.3.pass -side left -padx 2
			pack $f.3 -side top
			$f.1.a config -text "" -command {} -bd 0
			$f.1.ll config -text "" -command {} -bd 0
		} elseif {[string match -nocase $getsndprpn "rcode"]} {
			radiobutton $f.3.same -text "Is The Same as" -variable propaudhf -value 0 -command "PropAudRcode $tofile"
			radiobutton $f.3.incs -text "Includes" -variable propaudhf -value 1 -command "PropAudRcode $tofile"
			radiobutton $f.3.incm -text "Includes Most of" -variable propaudhf -value 3 -command "PropAudRcode $tofile"
			radiobutton $f.3.incd -text "Is Included by" -variable propaudhf -value 2 -command "PropAudRcode $tofile"
			radiobutton $f.3.incb -text "Is Mostly Included by" -variable propaudhf -value 4 -command "PropAudRcode $tofile"
			label $f.3.this -text "THIS RHYTHM"
			checkbutton $f.3.pass -text "Include Augm + Dimin" -variable propaudrcaugdim
			pack $f.3.same $f.3.incs $f.3.incm $f.3.incd $f.3.incb $f.3.this $f.3.pass -side left -padx 2
			pack $f.3 -side top
			radiobutton $f.4 -text "Enter a different rhythm" -variable propaudrcode -value 1 -command {set propaudrcode 0; set propaud_rh [EstablishRhythmPropDisplay 0 0]}
			pack $f.4 -side top
			$f.1.a config -text "" -command {} -bd 0
			$f.1.ll config -text "" -command {} -bd 0
		} elseif {[string match -nocase $getsndprpn "motif"]} {
			radiobutton $f.3.same -text "Is The Same as" -variable propaudhf -value 0 -command "PropAudMotif $tofile"
			radiobutton $f.3.incs -text "Includes" -variable propaudhf -value 1 -command "PropAudMotif $tofile"
			radiobutton $f.3.incm -text "Includes Most of" -variable propaudhf -value 3 -command "PropAudMotif $tofile"
			radiobutton $f.3.incd -text "Is Included by" -variable propaudhf -value 2 -command "PropAudMotif $tofile"
			radiobutton $f.3.incb -text "Is Mostly Included by" -variable propaudhf -value 4 -command "PropAudMotif $tofile"
			label $f.3.this -text "THIS MOTIF"
			pack $f.3.same $f.3.incs $f.3.incm $f.3.incd $f.3.incb $f.3.this -side left -padx 2
			pack $f.3 -side top
			frame $f.4
			radiobutton $f.4.tr0 -text "As is" -variable propaudtrans -value 0 -command "set propaudhf -1"
			radiobutton $f.4.tr1 -text "8va Equivalence" -variable propaudtrans -value 1 -command "set propaudhf -1"
			radiobutton $f.4.tr2 -text "Including Transpositions" -variable propaudtrans -value 2 -command "set propaudhf -1"
			label $f.4.ml -text "Min Fraction of notes to compare (Up/Dn Arrows)"
			entry $f.4.m -textvariable propaudfrac -width 3 -state readonly -fg $readonlyfg -readonlybackground $readonlybg
			SetPropaudMotifFrac
			pack $f.4.tr0 $f.4.tr1 $f.4.tr2 $f.4.ml $f.4.m -side left -padx 2
			pack $f.4 -side top
			bind $f <Up> {IncrPropaudFracMotif 1}
			bind $f <Down> {IncrPropaudFracMotif 0}
			$f.1.a config -text "" -command {} -bd 0
			$f.1.ll config -text "" -command {} -bd 0
		} elseif {[string match -nocase $getsndprpn "text"]} {
			radiobutton $f.3.same -text "Is The Same as" -variable propaudhf -value 0 -command "PropAudText $tofile"
			radiobutton $f.3.incs -text "Includes" -variable propaudhf -value 1 -command "PropAudText $tofile"
			radiobutton $f.3.incm -text "Includes Most of" -variable propaudhf -value 3 -command "PropAudText $tofile"
			radiobutton $f.3.incd -text "Is Included by" -variable propaudhf -value 2 -command "PropAudText $tofile"
			radiobutton $f.3.incb -text "Is Mostly Included by" -variable propaudhf -value 4 -command "PropAudText $tofile"
			label $f.3.this -text "THIS TEXT"
			checkbutton $f.3.pass -text "Include Homonyms" -variable propaudhom
			pack $f.3.same $f.3.incs $f.3.incm $f.3.incd $f.3.incb $f.3.this $f.3.pass -side left -padx 2
			pack $f.3 -side top
			frame $f.3a -bg $evv(POINT) -height 1
			pack $f.3a -side top -fill x -expand true -pady 2
			label $f.3b -text "LOOSER MATCHING" -fg $evv(SPECIAL)
			pack $f.3b -side top
			frame $f.4
			radiobutton $f.4.c -text "Looser matching        " -variable propaudtstats -value 1 -command "AnalyseTextPropertyWordDataFromTable $tofile"
			label $f.4.ml -text "Min no. words to compare (Shift Up/Dn Arrows)"
			entry $f.4.m -textvariable propaudmin -width 3 -state readonly -fg $readonlyfg -readonlybackground $readonlybg
			set propaudmax [SetPropaudMax]
			set propaudmin $propaudmax
			label $f.4.fl -text "Fraction of skipable words (Up/Dn Arrows)"
			entry $f.4.f -textvariable propaudfrac -width 4 -state readonly -fg $readonlyfg -readonlybackground $readonlybg
			SetPropaudFrac
			pack $f.4.c $f.4.fl $f.4.f $f.4.ml $f.4.m -side left
			pack $f.4 -side top
			bind $f <Shift-Up> {IncrPropaudMin 1}
			bind $f <Shift-Down> {IncrPropaudMin 0}
			bind $f <Up> {IncrPropaudFrac 1}
			bind $f <Down> {IncrPropaudFrac 0}
			$f.1.a config -text "" -command {} -bd 0
			$f.1.ll config -text "" -command {} -bd 0
		}
		bind $f <Escape> {set pr_prselsnd 0}
		wm resizable $f 1 1
	}
	set sel_doquit 0
	set propaudtrans 0
	set propaudrcode 0
	set propaudhfpass 0
	set propaudrcaugdim 0
	set propaudhom 0
	set propaudtstats 0
	set propaudhf -1
	set propaud ""
	set pr_prselsnd 0
	set propaudsel -1
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_prselsnd $f
	while {!$finished} {
		switch -- [string tolower $getsndprpn] {
			"hf" {
				$f.3.same config -text "Is The Same as" -state normal
				$f.3.incs config -text "Includes" -state normal
				$f.3.incm config -text "Includes Most of" -state normal
				$f.3.incd config -text "Is Included by" -state normal
				$f.3.incb config -text "Is Mostly Included by" -state normal
				$f.3.this config -text "THIS HF"
				$f.3.pass config -text "Including Passing Notes" -state normal
			}
			"rcode" {
				$f.3.same config -text "Is The Same as" -state normal
				$f.3.incs config -text "Includes" -state normal
				$f.3.incm config -text "Includes Most of" -state normal
				$f.3.incd config -text "Is Included by" -state normal
				$f.3.incb config -text "Is Mostly Included by" -state normal
				$f.3.this config -text "THIS RHYTHM"
				$f.3.pass config -text "Include Augm + Dimin" -state normal
				$f.4	  config -text "Enter a different rhythm" -state normal
			}
			"text" {
				$f.3.same config -text "Is The Same as" -state normal
				$f.3.incs config -text "Includes" -state normal
				$f.3.incm config -text "Includes Most of" -state normal
				$f.3.incd config -text "Is Included by" -state normal
				$f.3.incb config -text "Is Mostly Included by" -state normal
				$f.3.this config -text "THIS TEXT"
				$f.3.pass config -text "Include Homonyms" -state normal
				$f.3b	  config -text "LOOSER MATCHING"
				$f.4.c	  config -text "Looser matching        " -state normal
				$f.4.ml   config -text "Min no. words to compare (Shift Up/Dn Arrows)"
				set propaudmin $propaudmax
				$f.4.m    config -bd 2
				$f.4.fl   config -text "Fraction of skipable words (Up/Dn Arrows)"
				SetPropaudFrac
				$f.4.f    config -bd 2
			}
			"motif" {
				$f.3.same config -text "Is The Same as" -state normal
				$f.3.incs config -text "Includes" -state normal
				$f.3.incm config -text "Includes Most of" -state normal
				$f.3.incd config -text "Is Included by" -state normal
				$f.3.incb config -text "Is Mostly Included by" -state normal
				$f.3.this config -text "THIS MOTIF"
				$f.4.tr0  config -text "As is" -state normal
				$f.4.tr1  config -text "8va Equivalence" -state normal
				$f.4.tr2  config -text "Including Transpositions" -state normal
				$f.4.ml   config -text "Min Fraction of notes to compare (Up/Dn Arrows)"
				$f.4.m    config -bd 2
				SetPropaudMotifFrac
			}
		}
		wm title $f "SELECT FROM SOUNDS"
		tkwait variable pr_prselsnd
		switch -- $pr_prselsnd {
			0 {
				set finished 1
			}
			1 {
				set propaud_done 0
				$f.1.a config -text "" -bd 0 -command {}
				$f.2.e config -bd 2
				$f.2.sel config -state normal
				$f.2.rej config -state normal
				set propaud_index 0
				set snd [lindex $propaud_snds $propaud_index]
				set propaud [file rootname [file tail $snd]]
				PlaySndfile $snd 0
				.prselsnd.1.ll config -text "Listen & Select" -command "Inf \"Select Or Reject Sound\""
				tkwait variable propaud_done
				.prselsnd.1.ll config -text "Listen & Select" -command {set pr_prselsnd 1} -bd 2
				if {[info exists propaud_snds] && ([llength $propaud_snds] > 0)} {
					if {![string match $tofile "0"]} {
						CreateSubPropfile $tofile $tp_propnames $propaud_tfil
						set OK 1
					} else {
						set OK 0
						DoChoiceBak
						$ch delete 0 end
						catch {unset chlist}
						foreach fnam $propaud_snds {
							set i [LstIndx $fnam $wl]
							if {$i < 0} {
								if {[FileToWkspace $fnam 0 0 0 1 0] <= 0} {
									continue
								}
							}
							set OK 1
							$ch insert end $fnam
							lappend chlist $fnam
						}
					}
					if {$OK} {
						set sel_doquit 1
						set finished 1
					}
				} else {
					if {$pr_prselsnd == 0} {
						set sel_doquit 0
						set finished 1
					} else {
						Inf "No Sounds Selected"
						continue
					}
				}
			}
			2 {
				if {![string match $tofile "0"]} {
					CreateSubPropfile $tofile $tp_propnames $propaud_tfil
					set OK 1
				} else {
					set OK 0
					DoChoiceBak
					$ch delete 0 end
					catch {unset chlist}
					if {[info exists propaud_snds] && ([llength $propaud_snds] > 0)} {
						foreach fnam $propaud_snds {
							set i [LstIndx $fnam $wl]
							if {$i < 0} {
								if {[FileToWkspace $fnam 0 0 0 1 0] <= 0} {
									continue
								}
							}
							set OK 1
							$ch insert end $fnam
							lappend chlist $fnam
						}
					}
				}
				if {$OK} {
					set sel_doquit 1
					set finished 1
				}
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
	if {$sel_doquit} {
		set pr_proptab 0
	}
}

#--- Select or Reject a sound from the list of snds from property-selection of snds

proc PropAudSel {truncate} {
	global propaud_index propaud_snds propaud_nu_snds propaud_done propaudsel propaud propaud_tfil propaud_nu_tfil
	if {$truncate} {
		if {![info exists propaud_nu_snds]} {
			Inf "No Sounds Selected"
			return
		}
		set propaud_snds $propaud_nu_snds
		set propaud_tfil $propaud_nu_tfil
		set propaud_done 1
		return
	}
	set len [llength $propaud_snds]
	if {$propaudsel == 1}  {
		lappend propaud_nu_snds [lindex $propaud_snds $propaud_index]
		lappend propaud_nu_tfil [lindex $propaud_tfil $propaud_index]
	}
	incr propaud_index
	if {$propaud_index >= $len} {
		if {![info exists propaud_nu_snds]} {
			Inf "No Sounds Selected"
			return
		}
		set propaud_snds $propaud_nu_snds
		set propaud_tfil $propaud_nu_tfil
		set propaud_done 1
	} else {
		set snd [lindex $propaud_snds $propaud_index]
		set propaud [file rootname [file tail $snd]]
		PlaySndfile $snd 0
		set propaudsel -1
	}
}

#--- Select how HF are related : equal , Includes or Included, from Snd selection by prop.

proc PropAudHF {tofile} {
	global propaudhf propaudhfpass getsndprpv tp_props_list proppos pr_proptab pr_prselsnd ch chlist propaud_snds propaud_tfil
	global propaud_nu_snds propaud_nu_tfil tp_propnames wstk

	set inval [string trim $getsndprpv]
	set inmidivals [ConvertHFCodeToMidi $inval]
	set len [llength $inmidivals]
	if {$len <= 0} {
		Inf "This Is Not An \"hf\" Property Value"
		set pr_prselsnd 0
	}
	set n 0
	foreach line $tp_props_list {
		set val [lindex $line $proppos]
		set midivals [ConvertHFCodeToMidi $val]
		if {[llength $midivals] <= 0} {
			incr n
			continue
		}
		set OK 1
		switch -- $propaudhf {
			0 {														;#	HFs are same
				if {[llength $midivals] != [llength $inmidivals]} {
					set OK 0
				} else {
					foreach midival $midivals {
						if {[lsearch $inmidivals $midival] < 0} {
							set OK 0
							break
						}
					}
				}
			}
			1 {
				foreach inmidival $inmidivals {						;#	If this HF includes comparison HF
					if {[lsearch $midivals $inmidival] < 0} {
						set OK 0
						break
					}
				}
			}
			2 {
				foreach midival $midivals {							;#	If this HF included within comparison HF
					if {[lsearch $inmidivals $midival] < 0} {
						set OK 0
						break
					}
				}
			}
			3 {
				set matches 0
				set OK 0
				set target [expr ($len / 2) + 1]
				foreach inmidival $inmidivals {						;#	If this HF includes more than half of comparison HF
					if {[lsearch $midivals $inmidival] >= 0} {
						incr matches
						if {$matches >= $target} {
							set OK 1
							break
						}
					}
				}
			}
			4 {
				set matches 0
				set OK 0
				set len [llength $midivals]
				set target [expr ($len / 2) + 1]
				foreach midival $midivals {							;#	If more than half of this HF included within comparison HF
					if {[lsearch $inmidivals $midival] >= 0} {
						incr matches
						if {$matches >= $target} {
							set OK 1
							break
						}
					}
				}
			}
		}
		if {$OK} {
			lappend propaud_snds [lindex $line 0]
			lappend propaud_tfil $n
		}
		incr n
	}
	if {![info exists propaud_snds]} {
		Inf "No Sounds Have The Value \"$getsndprpv\" For The Property \"hf\""
		return
	}
	if {[llength $propaud_snds] == 1} {
		set msg "No Other Sounds Match This Sound : Keep Just The Original Sound ??"
		set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			catch {unset propaud_snds}
			catch {unset propaud_nu_snds}
			catch {unset propaud_tfil}
			catch {unset propaud_nu_tfil}
			return
		}
		if {![string match $tofile "0"]} {
			CreateSubPropfile $tofile $tp_propnames $propaud_tfil
		} else {
			DoChoiceBak
			set chlist $propaud_snds
			$ch delete 0 end
			foreach fnam $chlist {
				$ch insert end $fnam
			}
		}
		set pr_prselsnd 0
		set pr_proptab 0
		return
	}
	.prselsnd.3.same config -text "" -state disabled
	.prselsnd.3.incs config -text "" -state disabled
	.prselsnd.3.incd config -text "" -state disabled
	.prselsnd.3.incm config -text "" -state disabled
	.prselsnd.3.incb config -text "" -state disabled
	.prselsnd.3.this config -text ""
	.prselsnd.3.pass config -text "" -state disabled
	.prselsnd.1.a config -text "Keep All" -command {set pr_prselsnd 2} -bd 2
	.prselsnd.1.ll config -text "Listen & Select" -command {set pr_prselsnd 1} -bd 2
}

#-- Convert Property "hf" code to lowest posssible MIDI vals

proc ConvertHFCodeToMidi {code} {
	global propaudhfpass
	set len [string length $code]
	if {![regexp {^[A-Ga-g#]+$} $code]} {
		return {}
	}
	set i 0
	set vals {}
	while {$i < $len} {
		set inval [string index $code $i]
		if {[string match $inval "#"]} {
			set val [lindex $vals end]
			incr val
			set vals [lreplace $vals end end $val]
		} else {
			set nuval -1
			if {[info exists propaudhfpass] && $propaudhfpass} {
				switch -- $inval {
					"c"  { set nuval 0  }
					"d"  { set nuval 2  }
					"e"  { set nuval 4  }
					"f"  { set nuval 5  }
					"g"  { set nuval 7  }
					"a"  { set nuval 9  }
					"b"  { set nuval 11 }
				}
			} else {
				if {![regexp {^[A-G]$} $inval]} {
					set j [expr $i + 1]
					if {$j < $len} {
						set nextinval [string index $code $j]
						if {[string match $nextinval "#"]} {
							incr i
						}
					}
				}
			}
			switch -- $inval {
				"C"  { set nuval 0  }
				"D"  { set nuval 2  }
				"E"  { set nuval 4  }
				"F"  { set nuval 5  }
				"G"  { set nuval 7  }
				"A"  { set nuval 9  }
				"B"  { set nuval 11 }
			}
			if {$nuval >= 0} {
				lappend vals $nuval
			}
		}
		incr i
	}
	set len [llength $vals]
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set val_n [lindex $vals $n]
		set m $n
		incr m
		while {$m < $len} {
			set val_m [lindex $vals $m]
			if {$val_n == $val_m} {
				set vals [lreplace $vals $m $m]
				incr  m -1
				incr len -1
				incr len_less_one -1
			}
			incr m
		}
		incr n
	}
	set vals [lsort -integer -increasing $vals]
	return $vals
}

#--- Select how Rhythm Codes are related : equal , Includes or Included, from Snd selection by prop.

proc PropAudRcode {tofile} {
	global propaudhf propaudrcaugdim getsndprpv tp_props_list proppos pr_proptab pr_prselsnd ch chlist propaud_snds propaud_tfil
	global tp_propnames propaud_rh propaud_nu_snds propaud_nu_tfil wstk evv

	if {[info exists propaud_rh] && ([llength $propaud_rh] > 0)} {
		set getsndprpv $propaud_rh
		unset propaud_rh
	}
	set inrcodeval [string trim $getsndprpv]
	set inrcodeval [StripBarlinesFromRcode $inrcodeval]
	if {![ValidRhythmCode $inrcodeval]} {
		Inf "Invalid Reference Rhythm Code"
		return
	}
	Block "Matching Rhythms"
	set inlen [string length $inrcodeval]
	set intestrcodeval $inrcodeval
	if {$propaudrcaugdim} {							;#	Get all doubled and halved versions of code
		set innucode $intestrcodeval
		while {[string length $innucode] > 0} {
			set innucode [RcodeHalveDouble $innucode 0 1] ;# Halve Vals
			if {[string length $innucode] > 0} {
				lappend intestrcodeval $innucode
			} else {
				break
			}
		}
		set innucode $inrcodeval
		while {[string length $innucode] > 0} {
			set innucode [RcodeHalveDouble $innucode 0 2] ;# Double Vals
			if {[string length $innucode] > 0} {
				lappend intestrcodeval $innucode
			} else {
				break
			}
		}
	}
	set n 0
	foreach line $tp_props_list {
		set rcodeval [lindex $line $proppos]
		if {[string match $rcodeval $evv(NULL_PROP)]} {
			incr n
			continue
		}
		set rcodeval [StripBarlinesFromRcode $rcodeval]
		if {![ValidRhythmCode $rcodeval]} {
			Inf "Invalid Rhythm Code"
			UnBlock
			return
		}
		set testrcodeval $rcodeval
		if {$propaudrcaugdim} {						;#	Get all doubled and halved versions of code
			set nucode $testrcodeval
			while {[string length $nucode] > 0} {
				set nucode [RcodeHalveDouble $nucode 0 1] ;# Halve Vals
				if {[string length $nucode] > 0} {
					lappend testrcodeval $nucode
				} else {
					break
				}
			}
			set nucode $rcodeval
			while {[string length $nucode] > 0} {
				set nucode [RcodeHalveDouble $nucode 0 2] ;# Double Vals
				if {[string length $nucode] > 0} {
					lappend testrcodeval $nucode
				} else {
					break
				}
			}
		}
		set OK 0
		switch -- $propaudhf {
			0 {													;#	Rcodes are same
				foreach inrcodeval $intestrcodeval {
					foreach rcodeval $testrcodeval {
						if {[string match $rcodeval $inrcodeval]} {
							set OK 1
							break
						}
					}
					if {$OK} {
						break
					}
				}
			}
			1 {													;#	If this Rcode includes comparison Rcode
				foreach inrcodeval $intestrcodeval {
					foreach rcodeval $testrcodeval {
						if {[string first $inrcodeval $rcodeval] >= 0} {
							set OK 1
							break
						}
					}
					if {$OK} {
						break
					}
				}
			}
			2 {													;#	If this Rcode included within comparison Rcode
				foreach inrcodeval $intestrcodeval {
					foreach rcodeval $testrcodeval {
						if {[string first $rcodeval $inrcodeval] >= 0} {
							set OK 1
							break
						}
					}
					if {$OK} {
						break
					}
				}
			}
			3 {													;#	If this Rcode includes more than half of comparison Rcode
				foreach inrcodeval $intestrcodeval {
					set inlen [string length $inrcodeval]
					set target [expr ($inlen / 2) + 1]
					foreach rcodeval $testrcodeval {
						set strt 0
						set endd $target
						while {$endd < $inlen} {
							set testcode [string range $inrcodeval $strt $endd]
							if {[string first $testcode $rcodeval] >= 0} {
								set OK 1
								break
							}
							incr strt
							incr endd
						}
						if {$OK} {
							break
						}
					}
					if {$OK} {
						break
					}
				}
			}
			4 {													;#	If more than half of this Rcode included within comparison Rcode
				foreach inrcodeval $intestrcodeval {
					foreach rcodeval $testrcodeval {
						set len [string length $rcodeval]
						set target [expr ($len / 2) + 1]
						set strt 0
						set endd $target
						while {$endd < $len} {
							set testcode [string range $rcodeval $strt $endd]
							if {[string first $testcode $inrcodeval] >= 0} {
								set OK 1
								break
							}
							incr strt
							incr endd
						}
						if {$OK} {
							break
						}
					}
					if {$OK} {
						break
					}
				}
			}
		}
		if {$OK} {
			lappend propaud_snds [lindex $line 0]
			lappend propaud_tfil $n
		}
		incr n
	}
	if {![info exists propaud_snds]} {
		Inf "No Sounds Have The Value \"$getsndprpv\" For The Property \"rcode\""
		UnBlock
		return
	}
	UnBlock
	if {[llength $propaud_snds] == 1} {
		set msg "No Other Sounds Match This Sound : Keep Just The Original Sound ??"
		set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			catch {unset propaud_snds}
			catch {unset propaud_nu_snds}
			catch {unset propaud_tfil}
			catch {unset propaud_nu_tfil}
			return
		}
		if {![string match $tofile "0"]} {
			CreateSubPropfile $tofile $tp_propnames $propaud_tfil
		} else {
			DoChoiceBak
			set chlist $propaud_snds
			$ch delete 0 end
			foreach fnam $chlist {
				$ch insert end $fnam
			}
		}
		set pr_prselsnd 0
		set pr_proptab 0
		return
	}
	.prselsnd.3.same config -text "" -state disabled
	.prselsnd.3.incs config -text "" -state disabled
	.prselsnd.3.incd config -text "" -state disabled
	.prselsnd.3.incm config -text "" -state disabled
	.prselsnd.3.incb config -text "" -state disabled
	.prselsnd.3.pass config -text "" -state disabled
	.prselsnd.3.this config -text ""
	.prselsnd.4 config -text "" -state disabled
	.prselsnd.1.a config -text "Keep All" -command {set pr_prselsnd 2} -bd 2
	.prselsnd.1.ll config -text "Listen & Select" -command {set pr_prselsnd 1} -bd 2
}

#---- Remove barlines from "rcode" property, before doing comparisons

proc StripBarlinesFromRcode {rcode} {
	set outstr ""
	set thisstart 0
	set len [string length $rcode]
	set k [string first "|" $rcode]
	while {$k >= 0} {
		if {$k == 0} {
			incr k
			if {$k >= $len} {
				set rcode ""
				break
			} else {
				set rcode [string range $rcode $k end]
				set len [string length $rcode]
			}
		} else {
			append outstr [string range $rcode 0 [expr $k - 1]]
			incr k
			if {$k >= $len} {
				set rcode ""
				break
			} else {
				set rcode [string range $rcode $k end]
				set len [string length $rcode]
			}
		}
		set k [string first "|" $rcode]
	}
	append outstr $rcode
	return $outstr
}

#---- Check "rcode" property value is valid

proc ValidRhythmCode {rcode} {

	if {![regexp {^[a-fwxz0-9:,\.]+$} $rcode]} {
		return 0
	}
	set len [string length $rcode]
	set lastchar ""
	set n 0
	while {$n < $len} {
		set char [string index $rcode $n]
		switch -- $char {
			0 {
				if {![regexp {[a-cz]} $lastchar]} {
					return 0
				}
			}
			4 -
			6 {
				if {![regexp {[a-fwx]} $lastchar]} {
					return 0
				}
			}
			1 -
			2 -
			3 -
			5 -
			7 {
				if {![regexp {[a-f]} $lastchar]} {
					return 0
				}
			}
			8 {
				if {![regexp {[a-e]} $lastchar]} {
					return 0
				}
			}
			9 {
				if {![regexp {[a-e]} $lastchar]} {
					return 0
				}
			}
		}
		if {[regexp {[a-z]} $char]} {
			if {[regexp {[a-z]} $lastchar]} {
				return 0
			}
		}
		set lastchar $char
		incr n
	}
	return 1
}

#------ Create a Properties file from selected lines in an existing props file

proc CreateSubPropfile {origfnam nams lines} {
	global pr_subprop subpropfnam wl propfiles_list tp_propnames tp_props_list props_info rememd wstk evv
	set f .subprop
	if [Dlg_Create $f "CREATE SUB PROPFILE" "set pr_subprop 0" -borderwidth $evv(BBDR)] {
		frame $f.1
		frame $f.2
		button $f.1.q -text "Abandon" -command "set pr_subprop 0" -highlightbackground [option get . background {}]
		button $f.1.a -text "Create File" -command "set pr_subprop 1" -highlightbackground [option get . background {}]
		pack $f.1.q -side right
		pack $f.1.a -side left
		pack $f.1 -side top -fill x -expand true
		label $f.2.ll -text "New Propfile Name"
		entry $f.2.e -textvariable subpropfnam
		pack $f.2.ll $f.2.e -side left -padx 2
		pack $f.2 -side top
		wm resizable $f 1 1
		bind $f <Escape> {set pr_subprop 0}
		bind $f <Return> {set pr_subprop 1}
	}
	set subpropfnam ""
	set pr_subprop 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_subprop $f.2.e
	while {!$finished} {
		tkwait variable pr_subprop
		switch -- $pr_subprop {
			0 {
				set finished 1
			}
			1 {
				if {[string length $subpropfnam] <= 0} {
					Inf "No Output Filename Entered"
					continue
				}
				if {![ValidCDPRootname $subpropfnam]} {
					continue
				}
				set outfnam [string tolower $subpropfnam]
				append outfnam [GetTextfileExtension props]
				if {[string match $origfnam $outfnam]} {
					Inf "You Cannot Overwrite The Input Property File Here"
					continue
				}
				if {[file exists $outfnam]} {
					set msg "File '$outfnam' Already Exists: Append This Data To It ?"
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						set orig_props_info $props_info
						if {![ThisIsAPropsFile $outfnam 0 0]} {
							Inf "'$outfnam' Is Not A Properties File"
							set props_info $orig_props_info
							continue
						}
						set orig_tp_propnames [lindex $props_info 0]
						set orig_tp_props_list [lindex $props_info 1]
						set props_info $orig_props_info
						set OK 1
						foreach nam $tp_propnames orignam $orig_tp_propnames {
							if {![string match $nam $orignam]} {
								Inf "Properties In File '$outfnam' Do Not Correspond To Properties Of New Sounds"
								set OK 0
								break
							}
						}
						if {!$OK} {
							continue
						}
						catch {unset snds}
						catch {unset orig_snds}
						foreach line $orig_tp_props_list {
							lappend orig_snds [lindex $line 0]
						}
						foreach lineno $lines {
							lappend snds [lindex [lindex $tp_props_list $lineno] 0]
						}
						set len [llength $lines]
						set n 0
						while {$n < $len} {
							set thissnd  [lindex $snds $n]
							set thisline [lindex $lines $n]
							if {[lsearch $orig_snds $thissnd] >= 0} {
								set lines [lreplace $lines $n $n]
								set snds [lreplace $snds $n $n]
								incr len -1
							} else {
								incr n
							}
						}
						if {$len <= 0} {
							Inf "All These Sounds Are Already In File '$outfnam'"
							break
						}
						catch {unset nu_props_list}
						foreach line $orig_tp_props_list {
							lappend nu_props_list $line
						}
						foreach lineno $lines {
							lappend nu_props_list [lindex $tp_props_list $lineno]
						}
						set tmpfnam $evv(DFLT_TMPFNAME)$evv(TEXT_EXT)
						if [catch {open $tmpfnam w} zit] {
							Inf "Cannot Open Temporary File To Store Enlarged Properties Listing."
							continue
						}
						puts $zit $nams
						foreach line $nu_props_list {
							puts $zit $line
						}
						close $zit
						set i [LstIndx $outfnam $wl]
						if {![DeleteFileFromSystem $outfnam 0 1]} {
							set msg "Cannot Delete Original File '$outfnam'"
							append msg "\n\nThe New Data Is In File '$tmpfnam'"
							append msg "\n\nRename This File, Outside The CDP, Before Quitting This Dialogue Box"
							Inf $msg
						} else {
							DummyHistory $outfnam "DESTROYED"
							if {[info exists propfiles_list]} {
								set k [lsearch $propfiles_list $outfnam]
								if {$k > 0} {
									set propfiles_list [lreplace $propfiles_list $k $k]
								}
							}
							if {$i >= 0} {
								WkspCnt [$wl get $i] -1
								$wl delete $i
								catch {unset rememd}
							}
							if [catch {file rename $tmpfnam $outfnam} zit] {
								set msg "Cannot Rename Appended Properties Files To '$outfnam'"
								append msg "\n\nThe New Data Is In File '$tmpfnam'"
								append msg "\n\nRename This File, Outside The CDP, Before Quitting This Dialogue Box"
								Inf $msg
							}
						}
						set finished 1
					} else {
						set msg "Overwrite Existing Property File '$outfnam' ?"
						set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							continue
						}
						set i [LstIndx $outfnam $wl]
						if {![DeleteFileFromSystem $outfnam 0 1]} {
							Inf "Cannot Delete Existing File '$outfnam'"
							continue
						} else {
							DummyHistory $outfnam "DESTROYED"
							if {[info exists propfiles_list]} {
								set k [lsearch $propfiles_list $outfnam]
								if {$k > 0} {
									set propfiles_list [lreplace $propfiles_list $k $k]
								}
							}
							if {$i >= 0} {
								WkspCnt [$wl get $i] -1
								$wl delete $i
								catch {unset rememd}
							}
						}
					}
				}
				if {!$finished} {
					if [catch {open $outfnam "w"} zit] {
						Inf "Cannot Create File '$outfnam' To Write Data"
						continue
					}
					puts $zit $nams
					foreach lineno $lines {
						puts $zit [lindex $tp_props_list $lineno]
					}
					close $zit
				}
				if {[lsearch $propfiles_list $outfnam] < 0} {
					lappend propfiles_list $outfnam
				}
				FileToWkspace $outfnam 0 0 0 0 1
				Inf "File '$outfnam' Is On The Workspace"
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

#--- Select related Texts in text-property: equal , Includes or Included: from Snd selection by prop.

proc PropAudText {tofile} {
	global propaudhf propaudhom getsndprpv tp_props_list proppos pr_proptab pr_prselsnd ch chlist propaud_snds propaud_tfil
	global tp_propnames equivalents_loaded homonym propaudmin propaudfrac propaud_nu_snds propaud_nu_tfil wstk evv
	set inphrase {}
	set words [split $getsndprpv]
	foreach word $words {
		set word [string trim $word]
		if {[string length $word] > 0} {
			lappend inphrase [string tolower $word]
		}
	}
	Block "Matching Texts"
	set inlen [llength $inphrase]
	set inphrases [list $inphrase]
	if {$propaudhom} {
		if {!$equivalents_loaded} {
			if {![LoadSoundEquivalents]} {
				return
			}
		}
		set n 0
		foreach word $inphrase {
			if [info exists homonym($word)] {
				lappend homs $n
			}
			incr n
		}
		if {[info exists homs]} {
			foreach n $homs {										;#	FOR EVERY WORD THAT HAS A HOMONYM
				set thisword [lindex $inphrase $n]
				set equivs [concat $thisword $homonym($thisword)]	;#	GET LIST OF IT AND ITS HOMONYMS
				catch {unset nuwordsets} 
				foreach wordset $inphrases {						;#	FOR EVERY PHRASE ALREADY EXISTING
					if {$n > 0} {									;#	RETAIN THE REST OF THE PHRASE (APART FROM THISWORD)
						set homwordsbas [lrange $wordset 0 [expr $n - 1]]
					} else {
						set homwordsbas {}
					}
					if {$n < [expr $inlen - 1]} {
						set homwordsend [lrange $wordset [expr $n + 1] end]
					} else {
						set homwordsend {}
					}
					foreach equiv $equivs {							;#	FORM NEW PHRASES BY SUBSITUTING EACH HOMONYM IN EACH ORIG PHRASE
						set homwords [concat $homwordsbas $equiv $homwordsend]
						lappend nuwordsets $homwords
					}
				}
				set inphrases $nuwordsets							;#	REPLACE EXISTING LIST OF PHRASES BY EXTENDED LIST
			}
			unset homs
		}
	}

	set n 0
	foreach line $tp_props_list {
		set val [string tolower [lindex $line $proppos]]
		if {[string match $val $evv(NULL_PROP)]} {
			incr n
			continue
		}
		set words [PropsStripUnderscores $val]
		set phrase {}
		set words [split $words]
		foreach word $words {
			set word [string trim $word]
			if {[string length $word] > 0} {
				lappend phrase [string tolower $word]
			}
		}
		set len [llength $phrase]
		set phrases [list $phrase]
		if {$propaudhom} {		;#	IF USING HOMONYMS
			set n 0
			foreach word $phrase {
				if [info exists homonym($word)] {
					lappend homs $n
				}
				incr n
			}
			if {[info exists homs]} {
				foreach n $homs {										;#	FOR EVERY WORD THAT HAS A HOMONYM
					set thisword [lindex $phrase $n]
					set equivs [concat $thisword $homonym($thisword)]	;#	GET LIST OF IT AND ITS HOMONYMS
					catch {unset nuwordsets} 
					foreach wordset $phrases {							;#	FOR EVERY PHRASE ALREADY EXISTING
						if {$n > 0} {									;#	RETAIN THE REST OF THE PHRASE (APART FROM THISWORD)
							set homwordsbas [lrange $wordset 0 [expr $n - 1]]
						} else {
							set homwordsbas {}
						}
						if {$n < [expr $inlen - 1]} {
							set homwordsend [lrange $wordset [expr $n + 1] end]
						} else {
							set homwordsend {}
						}
						foreach equiv $equivs {							;#	FORM NEW PHRASES BY SUBSITUTING EACH HOMONYM IN EACH ORIG PHRASE
							set homwords [concat $homwordsbas $equiv $homwordsend]
							lappend nuwordsets $homwords
						}
					}
					set phrases $nuwordsets								;#	REPLACE EXISTING LIST OF PHRASES BY EXTENDED LIST
				}
				unset homs
			}
		}
		set OK 0
		switch -- $propaudhf {
			0 {													;#	Texts are same
				foreach inphrase $inphrases {
					set inphrase [join $inphrase]
					foreach phrase $phrases {
						set phrase [join $phrase]
						if {[string match $inphrase $phrase]} {
							set OK 1
							break
						}
					}
					if {$OK} {
						break
					}
				}
			}
			1 {													;#	If this Text includes comparison Text
				foreach inphrase $inphrases {
					set inphrase [join $inphrase]
					foreach phrase $phrases {
						set phrase [join $phrase]
						if {[string first $inphrase $phrase] >= 0} {
							set OK 1
							break
						}
					}
					if {$OK} {
						break
					}
				}
			}
			2 {													;#	If this Text included within comparison Text
				foreach inphrase $inphrases {
					set inphrase [join $inphrase]
					foreach phrase $phrases {
						set phrase [join $phrase]
						if {[string first $phrase $inphrase] >= 0} {
							set OK 1
							break
						}
					}
					if {$OK} {
						break
					}
				}
			}
			3 {													;#	If this Text includes more than half of comparison Text
				foreach inphrase $inphrases {
					set inlen [llength $inphrase]
					set target [expr ($inlen / 2) + 1]
					foreach phrase $phrases {
						set phrase [join $phrase]
						set strt 0
						set endd $target
						while {$endd < $inlen} {
							set testphrase [lrange $inphrase $strt $endd]
							set testphrase [join $testphrase]
							if {[string first $testphrase $phrase] >= 0} {
								set OK 1
								break
							}
							incr strt
							incr endd
						}
						if {$OK} {
							break
						}
					}
					if {$OK} {
						break
					}
				}
			}
			4 {													;#	If more than half of this Text included within comparison Text
				foreach inphrase $inphrases {
					set inphrase [join $inphrase]
					foreach phrase $phrases {
						set len [llength $phrase]
						set target [expr ($len / 2) + 1]
						set strt 0
						set endd $target
						while {$endd < $len} {
							set testphrase [lrange $phrase $strt $endd]
							set testphrase [join $testphrase]
							if {[string first $testphrase $inphrase] >= 0} {
								set OK 1
								break
							}
							incr strt
							incr endd
						}
						if {$OK} {
							break
						}
					}
					if {$OK} {
						break
					}
				}
			}
		}
		if {$OK} {
			lappend propaud_snds [lindex $line 0]
			lappend propaud_tfil $n
		}
		incr n
	}
	if {![info exists propaud_snds]} {
		Inf "No Sounds Have The Value \"$getsndprpv\" For The Property \"rcode\""
		UnBlock
		return
	}
	UnBlock
	if {[llength $propaud_snds] == 1} {
		set msg "No Other Sounds Match This Sound : Keep Just The Original Sound ??"
		set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			catch {unset propaud_snds}
			catch {unset propaud_nu_snds}
			catch {unset propaud_tfil}
			catch {unset propaud_nu_tfil}
			return
		}
		if {![string match $tofile "0"]} {
			CreateSubPropfile $tofile $tp_propnames $propaud_tfil
		} else {
			DoChoiceBak
			set chlist $propaud_snds
			$ch delete 0 end
			foreach fnam $chlist {
				$ch insert end $fnam
			}
		}
		set pr_prselsnd 0
		set pr_proptab 0
		return
	}
	.prselsnd.3.same config -text "" -state disabled
	.prselsnd.3.incs config -text "" -state disabled
	.prselsnd.3.incd config -text "" -state disabled
	.prselsnd.3.incm config -text "" -state disabled
	.prselsnd.3.incb config -text "" -state disabled
	.prselsnd.3.this config -text ""
	.prselsnd.3.pass config -text "" -state disabled
	.prselsnd.3b	 config  -text ""
	.prselsnd.4.c config -text "" -state disabled
	.prselsnd.4.ml config -text ""
	set propaudmin ""
	.prselsnd.4.m  config -bd 0
	.prselsnd.4.fl config -text ""
	set propaudfrac ""
	.prselsnd.4.f  config -bd 0
	.prselsnd.1.a config -text "Keep All" -command {set pr_prselsnd 2} -bd 2
	.prselsnd.1.ll config -text "Listen & Select" -command {set pr_prselsnd 1} -bd 2
}

#---- Set initial value of maximum number of words to compare

proc SetPropaudFrac {} {
	global propaudmax propaudfrac propaud_frac
	if {$propaudmax == 1} {
		set propaudfrac "none"
		set propaud_frac 0
	} else {
		set propaudfrac "1/2"
		set propaud_frac 2
	}
}

#---- Set initial value of maximum number of words to compare

proc SetPropaudMax {} {
	global getsndprpv
	set words [split $getsndprpv]
	set cnt 0
	foreach word $words {
		set word [string trim $word]
		if {[string length $word] > 0} {
			incr cnt
		}
	}
	return $cnt
}

#---- Increment and decrement min number of words-in-phrase to compare, with Up-Down keys

proc IncrPropaudMin {up} {
	global propaudmax propaudmin
	if {$up} {
		if {$propaudmin < $propaudmax}  {
			incr propaudmin
		}
	} else {
		if {$propaudmin > 1} {
			incr propaudmin -1
		}
	}
}

#---- Increment and decrement fraction of words-in-phrase to skip during comparison, with Shift-Up-Down keys

proc IncrPropaudFrac {up} {
	global propaudmax propaudfrac propaud_frac
	if {$propaudmax == 1} {
		return
	}
	if {$up} {
		if {[string match $propaudfrac "none"]} {
			set propaud_frac $propaudmax
		} elseif {$propaud_frac > 2} {
			incr propaud_frac -1
		} else {
			return
		}
	} else {
		if {[string match $propaudfrac "none"]} {
			return
		} elseif {$propaud_frac == $propaudmax} {
			set propaudfrac "none"
			set propaud_frac 0
			return
		} else {
			incr propaud_frac 1
		}
	}
	set propaudfrac "1/"
	append propaudfrac $propaud_frac
}

#---- Find length of reference Motif for motif-property comparison initialisation

proc SetPropaudMaxMotif {} {
	global propaudmidilist propaudmax propaudfrac propaud_frac tp_props_list pre_proplocn evv
	catch {unset propaudmidilist}
	set fnam [lindex [lindex $tp_props_list $pre_proplocn] 0]
	set dir [file dirname $fnam]
	set ext [file extension $fnam]
	set fnam [file rootname [file tail $fnam]]
	append fnam $evv(PCH_TAG)
	set fnam [file join $dir $fnam]
	append fnam [GetTextfileExtension brk]
	if {![file exists $fnam]} {
		Inf "MOTIF DATA FILE '$fnam' DOES NOT EXIST"
		return 0
	}
	set midilist [ExtractMidiFromTemperedFrqBrkpntFile $fnam 1]
	if {[llength $midilist] <= 0} {
		UnBlock
		return 0
	}
	set propaudmidilist $midilist
	set propaudmax [llength $propaudmidilist]
	if {$propaudmax == 1} {
		set propaudfrac "none"
		set propaud_frac 0
	} else {
		set propaudfrac "1/2"
		set propaud_frac 2
	}
	return 1
}

#----- Compare Motif properties

proc PropAudMotif {tofile} {
	global propaudmidilist propaudtrans tp_props_list getsndprpv propaudhf propaud_frac propaudfrac propaudmax 
	global propaud_snds propaud_tfil propaud_nu_snds propaud_nu_tfil tp_propnames chlist ch pr_prselsnd pr_proptab wstk evv

	Block "Matching Motifs"
	set refmidilist $propaudmidilist
	if {$propaudtrans == 1} {
		set refmidilist [MidiToLowestOct $refmidilist]
	} elseif {$propaudtrans == 2} {
		set refmidilist [MidiToLowest $refmidilist]
	}
	set n 0
	foreach line $tp_props_list {
		if {![string match $getsndprpv "yes"]} {
			incr n
			continue
		}
		set snd [lindex $line 0]
		set dir [file dirname $snd]
		set ext [file extension $snd]
		set fnam [file rootname [file tail $snd]]
		append fnam $evv(PCH_TAG)
		set fnam [file join $dir $fnam]
		append fnam [GetTextfileExtension brk]
		if {![file exists $fnam]} {
			lappend badfiles $n
			incr n
			continue
		}
		set midilist [ExtractMidiFromTemperedFrqBrkpntFile $fnam 0]
		if {[llength $midilist] <= 0} {
			lappend badfiles $n
			incr n
			continue
		}
		if {$propaudtrans == 1} {
			set midilist [MidiToLowestOct $midilist]
		} elseif {$propaudtrans == 2} {
			set midilist [MidiToLowest $midilist]
		}
		switch -- $propaudhf {
			0 {					;# IS THE SAME AS refmotif
				set OK 1
				foreach refmidival $refmidilist midival $midilist {
					if {$refmidival != $midival} {
						set OK 0
						break
					}
				}
			}
			1 {					;#	INCLUDES refmotif
				set OK 0
				set refmidival [join $refmidilist]
				set midival [join $midilist]
				if {[string first $refmidival $midival] >= 0} {
					set OK 1
				}
			}
			2 {					;#	IS INCLUDED BY refmotif
				set OK 0
				set refmidival [join $refmidilist]
				set midival [join $midilist]
				if {[string first $midival $refmidival] >= 0} {
					set OK 1
				}
			}
			3 {					;#	INCLUDES MOST OF refmotif
				set reflen [llength $refmidilist]
				set phrlen  [llength $midilist]							;# For 6 words : propaudmax = 6	
				if {$propaud_frac > $propaudmax} {						;# For 6 words : propaudfrac  = 1/6 1/5 1/4 1/3 1/2 2/3 3/4 4/5 5/6 all
					set xx $reflen										;# For 6 words : propaud_frac =  -6  -5  -4  -3   2  3   4   5   6   7
				} elseif {$propaud_frac > 0} {
					set num [expr $propaud_frac - 1] 
					set frac [expr double($num)/double($propaud_frac)]
					set xx [expr int(ceil(double($reflen) * $frac))]
				} else {
					set frac [expr 1.0/double([expr -$propaud_frac])]
					set xx [expr int(ceil(double($reflen) * $frac))]
				}
				set OK 0
				if {$phrlen >= $xx} {
					while {$xx <= $reflen} {
						set refstt 0
						set refend [expr $xx - 1]
						while {$refend < $reflen} {
							set refmidivals [lrange $refmidilist $refstt $refend]
							set phrstt 0
							set phrend [expr $xx - 1] 
							while {$phrend < $phrlen} {
								set midivals [lrange $midilist $phrstt $phrend]
								set OK 1
								foreach refmidival $refmidivals midival $midivals {
									if {$refmidival != $midival} {
										set OK 0
										break
									}
								}
								if {$OK} {
									break
								}																	
								incr phrstt
								incr phrend
							}
							if {$OK} {
								break
							}																	
							incr refstt
							incr refend
						}
						if {$OK} {
							break
						}																	
						incr xx
						if {$xx > $phrlen} {
							break
						}
					}
				}
			}
			4 {					;#	IS MOSTLY INCLUDED BY refmotif
				set reflen [llength $refmidilist]
				set phrlen  [llength $midilist]
				if {$propaud_frac > $propaudmax} {
					set xx $phrlen
				} elseif {$propaud_frac > 0} {
					set num [expr $propaud_frac - 1] 
					set frac [expr double($num)/double($propaud_frac)]
					set xx [expr int(ceil(double($phrlen) * $frac))]
				} else {
					set frac [expr 1.0/double([expr -$propaud_frac])]
					set xx [expr int(ceil(double($phrlen) * $frac))]
				}
				set OK 0
				if {$reflen >= $xx} {
					while {$xx <= $phrlen} {
						set phrstt 0
						set phrend [expr $xx - 1]
						while {$phrend < $phrlen} {
							set midivals [lrange $midilist $phrstt $phrend]
							set refstt 0
							set refend [expr $xx - 1] 
							while {$refend < $reflen} {
								set refmidivals [lrange $refmidilist $refstt $refend]
								set OK 1
								foreach midival $midivals refmidival $refmidivals {
									if {$refmidival != $midival} {
										set OK 0
										break
									}
								}
								if {$OK} {
									break
								}																	
								incr refstt
								incr refend
							}
							if {$OK} {
								break
							}																	
							incr phrstt
							incr phrend
						}
						if {$OK} {
							break
						}																	
						incr xx
						if {$xx > $reflen} {
							break
						}
					}
				}
			}
		}
		if {$OK} {
			lappend propaud_snds $snd
			lappend propaud_tfil $n
		}
		incr n
	}
	if {[info exists badfiles]} {
		set msg "The Following Files Could Not Be Compared (Bad Or Nonexistent Motif Data)\n"
		set cnt 0
		foreach fnam $badfiles {
			append msg [file rootname [file tail $fnam]]
			append msg "\n"
			incr cnt
			if {$cnt >= 20} {
				append msg "And More"
				break
			}
		}
	}
	if {![info exists propaud_snds]} {
		Inf "No Sounds Match The Motif"
		UnBlock
		return
	}
	UnBlock
	if {[llength $propaud_snds] == 1} {
		set msg "No Other Sounds Match This Sound : Keep Just The Original Sound ??"
		set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			catch {unset propaud_snds}
			catch {unset propaud_nu_snds}
			catch {unset propaud_tfil}
			catch {unset propaud_nu_tfil}
			return
		}
		if {![string match $tofile "0"]} {
			CreateSubPropfile $tofile $tp_propnames $propaud_tfil
		} else {
			DoChoiceBak
			set chlist $propaud_snds
			$ch delete 0 end
			foreach fnam $chlist {
				$ch insert end $fnam
			}
		}
		set pr_prselsnd 0
		set pr_proptab 0
		return
	}
	.prselsnd.3.same config -text "" -state disabled
	.prselsnd.3.incs config -text "" -state disabled
	.prselsnd.3.incd config -text "" -state disabled
	.prselsnd.3.incm config -text "" -state disabled
	.prselsnd.3.incb config -text "" -state disabled
	.prselsnd.3.this config -text ""
	.prselsnd.4.tr0 config -text "" -state disabled
	.prselsnd.4.tr1 config -text "" -state disabled
	.prselsnd.4.tr2 config -text "" -state disabled
	.prselsnd.4.ml config -text ""
	set propaudfrac ""
	.prselsnd.4.m config -bd 0
	.prselsnd.1.a config -text "Keep All" -command {set pr_prselsnd 2} -bd 2
	.prselsnd.1.ll config -text "Listen & Select" -command {set pr_prselsnd 1} -bd 2
}

#----- Convert Tempered-scale time-frq note data to an untimed list of midivals

proc ExtractMidiFromTemperedFrqBrkpntFile {fnam msgs} {

	if [catch {open $fnam "r"} zit] {
		if {$msgs} {
			Inf "Cannot Open File '$fnam' To Read Frq Data"
		}
		return {}
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		set line [split $line]
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] > 0} {
				lappend indata $item
			}
		}
	}
	close $zit
	if {![info exists indata]} {
		if {$msgs} {
			Inf "No Data In File '$fnam'"
		}
		return {}
	}
	set len [llength $indata]
	set sublen [expr $len / 4]
	if {[expr $sublen * 4] != $len} {
		if {$msgs} {
			Inf "Invalid Data In File '$fnam'"
		}
		return {}
	}
	set cnt 0
	foreach {time1 val1 time2 val2} $indata {
		if {$cnt == 0} {
			if {![Flteq $time1 0.0]} {
				if {$msgs} {
					Inf "Invalid Data In File '$fnam'"
				}
				return {}
			}
		} elseif {$lasttime >= $time1} {
			if {$msgs} {
				Inf "Invalid Data In File '$fnam'"
			}
			return {}
		} 
		if {![Flteq $val1 $val2] || ($time1 >= $time2)} {
			if {$msgs} {
				Inf "Invalid Data In File '$fnam'"
			}
			return {}
		}
		set lasttime $time2 
		set midi [HzToMidi $val1]
		lappend midivals [expr int(round($midi))]
		incr cnt
	}
	return $midivals
}

#---- Initialise proportion of motif to match, as all of it

proc SetPropaudMotifFrac {} {
	global propaudmax propaudfrac propaud_frac propaudhf
	set propaudfrac "all"
	set propaud_frac [expr $propaudmax + 1]
	set propaudhf -1
}

#---- Increment and decrement fraction of words-in-phrase to skip during comparison, with Shift-Up-Down keys

proc IncrPropaudFracMotif {up} {
	global propaudmax propaudfrac propaud_frac propaudhf
	if {$propaudmax == 1} {
		return
	}
	if {$up} {
		if {$propaud_frac <= $propaudmax} {
			incr propaud_frac
			if {$propaud_frac == -2} {
				set propaud_frac 2
			}
		} else {
			return
		}
	} else {
		if {$propaud_frac > [expr -$propaudmax]} {
			incr propaud_frac -1
			if {$propaud_frac == 1} {
				set propaud_frac -3
			}
		} else {
			return
		}
	}
	if {$propaud_frac > $propaudmax} {
		set propaudfrac "all"
	} elseif {$propaud_frac > 0} {
		set num [expr $propaud_frac - 1] 
		set propaudfrac "$num/"
		append propaudfrac $propaud_frac
	} else {
		set propaudfrac "1/"
		append propaudfrac [expr -$propaud_frac]
	}
	set propaudhf -1
}

#---- Transpose MIDI list to lowest possible transposition

proc MidiToLowest {midilist} {
	set lowest 10000
	foreach midi $midilist {
		if {$midi < $lowest} {
			set lowest $midi
		}
	}
	foreach midi $midilist {
		set midi [expr $midi - $lowest]
		lappend numidilist $midi	
	}
	return $numidilist
}

#---- Transpose MIDI list to lowest possible 8va transposition

proc MidiToLowestOct {midilist} {
	set lowest 10000
	foreach midi $midilist {
		if {$midi < $lowest} {
			set lowest $midi
		}
	}
	set octcnt 0
	while {$lowest >= 0} {
		set lastlowest $lowest
		set lastoctcnt $octcnt
		incr lowest -12
		incr octcnt
	}
	set octtransp [expr 12 * $lastoctcnt]
	foreach midi $midilist {
		set midi [expr $midi - $octtransp]
		lappend numidilist $midi	
	}
	return $numidilist
}

#################
# HF STATISTICS #
#################

#----- Get and display stats on HF property

proc HFStats {force} {
	global tp_propnames tp_props_list hasHFprop propaudhfpass HFinfo HFsnds HFpart HFwhole pr_hfstats HFstats HFstatsndlist wstk evv
	set maxlen 0
	set minlen 200
	catch {unset HFstatsndlist}
	if {$force} {
		catch {unset HFinfo}
		catch {unset HFsnds}
	}
	set msg "Include Passing Notes ??"
	set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
	if {$choice == "yes"} {
		if {[info exists HFinfo]} {
			if {![info exists propaudhfpass] || ($propaudhfpass == 0)} {
				unset HFinfo
				catch {unset HFsnds}
			}
		}
		set propaudhfpass 1
	} else {
		if {[info exists HFinfo]} {
			if {[info exists propaudhfpass] && $propaudhfpass} {
				unset HFinfo
				catch {unset HFsnds}
			}
		}
		catch {unset propaudhfpass}
	}

	if {![info exists HFinfo]} {
		Block "Extracting HF statistics"
		foreach line $tp_props_list {
			set sndnam [lindex $line 0]
			set hflist [lindex $line $hasHFprop]	
			set midilist [ConvertHFCodeToMidi $hflist]
			set len [llength $midilist]
			if {$len <= 0} {
				continue
			}
			if {$len < $minlen} {
				set minlen $len
			} elseif {$len > $maxlen} {
				set maxlen $len
			}
			lappend HFinfo $midilist
			lappend HFsnds $sndnam
		}
		if {![info exists HFsnds]} {
			Inf "No HF Information Extracted"
			UnBlock 
			return
		}
		foreach midilist $HFinfo fnam $HFsnds {
			if {![info exists HFwhole($midilist)]} {
				set HFwhole($midilist) $fnam
			} else {
				lappend HFwhole($midilist) $fnam
			}
			set len [llength $midilist]
			set n 2
			while {$n <= $len} {
				set m [expr $len - $n]
				set j 0
				set k [expr $j + $n - 1]
				while {$j <= $m} {
					set sublist [lrange $midilist $j $k]
					if {![info exists HFpart($sublist)]} {
						set HFpart($sublist) $fnam
					} else {
						lappend HFpart($sublist) $fnam
					}
					incr j
					incr k
				}
				incr n
			}
		}
		UnBlock 
	}
	Block "Sorting HF Data"
	foreach nam [array names HFwhole] {
		lappend whnamlist $nam
		lappend lenlist [llength $HFwhole($nam)]
	}
	set len [llength $whnamlist]
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set len_n [lindex $lenlist $n]
		set nam_n [lindex $whnamlist $n]
		set m $n
		incr m
		while {$m < $len} {
			set len_m [lindex $lenlist $m]
			set nam_m [lindex $whnamlist $m]
			if {$len_m > $len_n} {							;#	FREQUENCY SORT
				set lenlist [lreplace $lenlist $m $m $len_n]
				set lenlist [lreplace $lenlist $n $n $len_m]
				set whnamlist [lreplace $whnamlist $m $m $nam_n]
				set whnamlist [lreplace $whnamlist $n $n $nam_m]
				set len_n $len_m
				set nam_n $nam_m
			} elseif {$len_m == $len_n} {
				foreach val_n $nam_n val_m $nam_m {
					if {$val_m < $val_n} {					;#	MIDI ORDER SORT
						set lenlist [lreplace $lenlist $m $m $len_n]
						set lenlist [lreplace $lenlist $n $n $len_m]
						set whnamlist [lreplace $whnamlist $m $m $nam_n]
						set whnamlist [lreplace $whnamlist $n $n $nam_m]
						set len_n $len_m
						set nam_n $nam_m
						break
					} elseif {$val_m > $val_n} {
						break
					}
				}
			}
			incr m
		}
		incr n
	}
	catch {unset lenlist}
	foreach nam [array names HFpart] {
		lappend panamlist $nam
		lappend lenlist [llength $HFpart($nam)]
	}
	set len [llength $panamlist]
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set len_n [lindex $lenlist $n]
		set nam_n [lindex $panamlist $n]
		set m $n
		incr m
		while {$m < $len} {
			set len_m [lindex $lenlist $m]
			set nam_m [lindex $panamlist $m]
			if {$len_m > $len_n} {
				set lenlist [lreplace $lenlist $m $m $len_n]
				set lenlist [lreplace $lenlist $n $n $len_m]
				set panamlist [lreplace $panamlist $m $m $nam_n]
				set panamlist [lreplace $panamlist $n $n $nam_m]
				set len_n $len_m
				set nam_n $nam_m
			} elseif {$len_m == $len_n} {
				foreach val_n $nam_n val_m $nam_m {
					if {$val_m < $val_n} {					;#	MIDI ORDER SORT
						set lenlist [lreplace $lenlist $m $m $len_n]
						set lenlist [lreplace $lenlist $n $n $len_m]
						set panamlist [lreplace $panamlist $m $m $nam_n]
						set panamlist [lreplace $panamlist $n $n $nam_m]
						set len_n $len_m
						set nam_n $nam_m
						break
					} elseif {$val_m > $val_n} {
						break
					}
				}
			}
			incr m
		}
		incr n
	}
	UnBlock

	set f .hfstats
	if [Dlg_Create $f "HARMONIC FIELD STATISTICS" "set pr_hfstats 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		frame $f.1
		frame $f.2
		frame $f.3
		frame $f.4
		button $f.0.q -text "Quit" -command "set pr_hfstats 0" -highlightbackground [option get . background {}]
		button $f.0.p -text "Play Hilited HF" -command "set pr_hfstats 6" -highlightbackground [option get . background {}]
		pack $f.0.q -side right -padx 10
		pack $f.0.p -side left
		pack $f.0 -side top -fill x -expand true
		button $f.1.full -text "Stats of Complete HFs" -command "set pr_hfstats 1" -width 26 -highlightbackground [option get . background {}]
		button $f.1.part -text "Stats of Partial HFs" -command "set pr_hfstats 2" -width 26 -highlightbackground [option get . background {}]
		pack $f.1.full $f.1.part -side left -padx 2
		pack $f.1 -side top -pady 2
		button $f.2.incl -text "HFs containing this HF" -command "set pr_hfstats 3" -width 26 -highlightbackground [option get . background {}]
		button $f.2.snds -text "Get Snds with HFs Listed" -command "set pr_hfstats 4" -width 26 -highlightbackground [option get . background {}]
		pack $f.2.incl $f.2.snds -side left -padx 2
		pack $f.2 -side top -pady 2
		button $f.3.sel  -text "Snds of Selected HF + Quit" -command "set pr_hfstats 7" -width 26 -highlightbackground [option get . background {}]
		button $f.3.snds -text "Get Snds + Quit" -command "set pr_hfstats 5" -width 26 -highlightbackground [option get . background {}]
		pack $f.3.sel $f.3.snds -side left -padx 2
		pack $f.3 -side top -pady 2
		label $f.4.tit -text "" -fg $evv(SPECIAL)
		set HFstats [Scrolled_Listbox $f.4.ll -width 50 -height 32 -selectmode single]
		pack $f.4.tit $f.4.ll -side top
		pack $f.4 -side top -fill x -expand true
		bind $f <Escape> {set pr_hfstats 0}
	}
	$HFstats delete 0 end
	set pr_hfstats 0
	raise $f
	update idletasks
	StandardPosition2 $f
	My_Grab 0 $f pr_hfstats $f
	set finished 0
	while {!$finished} {
		tkwait variable pr_hfstats
		switch -- $pr_hfstats {
			0 {
				set finished 1
			}
			1 {
				if {![info exists whnamlist]} {
					Inf "No Data To Sort"
					continue
				}
				$HFstats delete 0 end
				DisplayHFstats 0 0 $whnamlist
			}
			2 {
				$HFstats delete 0 end
				DisplayHFstats 1 0 $panamlist
			}
			3 {
				if {[$HFstats curselection] < 0} {
					Inf "No HF Selected"
					continue
				}
				DisplayHFstats 0 1 $whnamlist
			}
			4 {
				DisplayedHFstatsToChosenFilesList 1
			}
			5 {
				if {[DisplayedHFstatsToChosenFilesList 0]} {
					set finished 1
				}
			}
			6 {
				if {[$HFstats curselection] < 0} {
					Inf "No HF Selected"
					continue
				}
				PlayHFstats
			}
			7 {
				set i [$HFstats curselection]
				if {$i < 0} {
					Inf "No HF Selected"
					continue
				}
				set line [$HFstats get $i]
				$HFstats delete 0 end
				$HFstats insert end $line
				set nam [lindex $line 1]
				set len [string length $nam]
				set n 0
				set k -1
				while {$n < $len} {
					set item [string index $nam $n]
					switch -- $item {
						"C" {
							lappend nunam 0
							incr k
						}
						"D" {
							lappend nunam 2
							incr k
						}
						"E" {
							lappend nunam 4
							incr k
						}
						"F" {
							lappend nunam 5
							incr k
						}
						"G" {
							lappend nunam 7
							incr k
						}
						"A" {
							lappend nunam 9
							incr k
						}
						"B" {
							lappend nunam 11
							incr k
						}
						"#" {
							set qq [lindex $nunam $k]
							incr qq
							set nunam [lreplace $nunam $k $k $qq]
						}
					}
					incr n
				}
				set nam [lindex $nunam 0]
				foreach item [lrange $nunam 1 end] {
					append nam " " $item
				}
				set HFstatsndlist {}
				foreach fnam $HFpart($nam) {
					if {[lsearch $HFstatsndlist $fnam] < 0} {
						lappend HFstatsndlist $fnam
					}
				}
				if {[DisplayedHFstatsToChosenFilesList 0]} {
					set finished 1
				}
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
	DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
}

#---- List HF stats

proc DisplayHFstats {part includes namlist} {
	global HFpart HFwhole HFstats propaudhfpass HFstatsndlist
	if {$part} {
		set HFstatsndlist {}
		foreach nam $namlist {
			set frq [llength $HFpart($nam)]
			set val [ConvertMinimalMidiToHFCode $nam]
			set line [list $frq $val]
			$HFstats insert end $line
			foreach fnam $HFpart($nam) {
				if {[lsearch $HFstatsndlist $fnam] < 0} {
					lappend HFstatsndlist $fnam
				}
			}
		}
		.hfstats.4.tit config -text "STATS OF HFs INCLUDED WITHIN OTHERS"
	} else {
		if {$includes} {
			set i [$HFstats curselection]
			set line [$HFstats get $i]
			set hfstr [lindex $line 1]
			if {[info exists propaudhfpass]} {
				set origpropaudhfpass $propaudhfpass
			}
			set midilist [ConvertHFCodeToMidi $hfstr]
			if {[info exists origpropaudhfpass]} {
				set propaudhfpass $origpropaudhfpass
			}
			foreach nam $namlist {			;#	CHECK EVERY COMPLETE-HF TO SEE IF IT CONTAINS THE SELECTED ONE
				set OK 1
				foreach val $midilist {
					set k [lsearch $nam $val]
					if {$k < 0} {
						set OK 0
						break
					}
				}
				if {$OK} {
					lappend outlist $nam
				}
			}
			if {![info exists outlist]} {
				Inf "No Matches Found"
				return
			}
			$HFstats delete 0 end
			set HFstatsndlist {}
			foreach nam $outlist {
				set frq [llength $HFwhole($nam)]
				set val [ConvertMinimalMidiToHFCode $nam]
				set line [list $frq $val]
				$HFstats insert end $line
				foreach fnam $HFwhole($nam) {
					if {[lsearch $HFstatsndlist $fnam] < 0} {
						lappend HFstatsndlist $fnam
					}
				}
			}
			.hfstats.4.tit config -text "STATS OF HFs INCLUDING \"$hfstr\""
		} else {
			set HFstatsndlist {}
			foreach nam $namlist {
				set frq [llength $HFwhole($nam)]
				set val [ConvertMinimalMidiToHFCode $nam]
				set line [list $frq $val]
				$HFstats insert end $line
				foreach fnam $HFwhole($nam) {
					if {[lsearch $HFstatsndlist $fnam] < 0} {
						lappend HFstatsndlist $fnam
					}
				}
			}
			.hfstats.4.tit config -text "STATISTICS OF COMPLETE HFs"
		}
	}
}

#----- Put snds using HFs listed on HF-stats, onto Chosen Files list

proc DisplayedHFstatsToChosenFilesList {msg} {
	global HFstatsndlist chlist ch wl
	if {![info exists HFstatsndlist]} {
		Inf "No Sounds To List"
		return 0
	}
	foreach fnam $HFstatsndlist {
		if {![file exists $fnam]} {
			Inf "File '$fnam' Does Not Exist"
			continue
		}
		set i [LstIndx $fnam $wl]
		if {$i < 0} {
			if {[FileToWkspace $fnam 0 0 0 1 0] > 0} {
				lappend nulist $fnam
			}
		} else {
			lappend nulist $fnam
		}
	}
	if {[info exists nulist]} {
		DoChoiceBak
		set chlist $nulist
		$ch delete 0 end
		foreach fnam $nulist {
			$ch insert end $fnam
		}
		if {$msg} {
			Inf "Files Are On The Chosen Files List"
		}
		return 1
	}
	return 0
}

#----- Play an HF listed on HF stats display

proc PlayHFstats {} {
	global HFstats tp_props_list hasHFprop prexpldir evv
	set i [$HFstats curselection]
	set line [$HFstats get $i]
	set hfstr [lindex $line 1]
	set n 0
	foreach line $tp_props_list {
		set hfprop [lindex $line $hasHFprop]
		set hfprop [HFStripPassing $hfprop]
		if [RotateMatch $hfstr $hfprop] {
			set fnam [file join $prexpldir $evv(HFPROP_FNAME)$n$evv(SNDFILE_EXT)]
			break
		}
		incr n
	}
	if {![file exists $fnam]} {
		Inf "Cannot Find HF File To Play"
		return
	}
	PlaySndfile $fnam 0
}

#-- Convert PRoperty "hf" code to lowest posssible MIDI vals

proc ConvertMinimalMidiToHFCode {midilist} {
	global propaudhfpass
	set len [llength $midilist]
	set i 0
	set outstr ""
	while {$i < $len} {
		set inval [lindex $midilist $i]
		switch -- $inval {
			0  { set nuval C }
			1  { set nuval C# }
			2  { set nuval D }
			3  { set nuval D# }
			4  { set nuval E }
			5  { set nuval F }
			6  { set nuval F# }
			7  { set nuval G }
			8  { set nuval G# }
			9  { set nuval A }
			10 { set nuval A# }
			11 { set nuval B }
		}
		append outstr $nuval
		incr i
	}
	return $outstr
}

#------ Remove passing notes from HF string

proc HFStripPassing {hfstr} {
	set len [string length $hfstr]
	set n 0
	set outstr ""
	while {$n < $len} {
		set char_n [string index $hfstr $n]
		if [regexp {[A-G]} $char_n] {
			append outstr $char_n
			incr n
			set char_n [string index $hfstr $n]
			if {($n < $len) && [string match "#" $char_n]} {
				append outstr $char_n
				incr n
			}
		} else {
			incr n
			set char_n [string index $hfstr $n]
			if {($n < $len) && [string match "#" $char_n]} {
				incr n
			}
		}
	}
	return $outstr
}

#----- MAtch with rotation  i.e. ABCDE = CDEAB

proc RotateMatch {str1 str2} {
	set len1 [string length $str1]
	set len2 [string length $str2]
	if {$len1 != $len2} {
		return 0
	}
	set firstchar [string index $str1 0]
	set k [string first $firstchar $str2]
	if {$k < 0} {
		return 0
	}
	if {$k != 0} {
		set nustr [string range $str2 $k end]
		append nustr [string range $str2 0 [expr $k - 1]]
		set str2 $nustr
	}
	if {![string match $str1 $str2]} {
		return 0
	}
	return 1
}

###############
# MOTIF STATS #
###############

#----- Do stats on motif property

proc MotifStats {force} {
	global tp_propnames tp_props_list hasmotifprop motifstatinfo motifstatsnds motifwhole motifstats pr_proptab evv
	global pr_motifstats motifstatsexit motifstatsig motifstatspec
	set motifstatsexit 0
	if {$force} {
		catch {unset motifstatinfo}
		catch {unset motifstatsnds}
	}
	if {![info exists motifstatinfo]} {
		Block "Getting Motif Data"
		foreach line $tp_props_list {
			set sndfnam [lindex $line 0]
			set fnam [file rootname $sndfnam]
			append fnam $evv(FILT_TAG) $evv(TEXT_EXT)
			if {![file exists $fnam]} {
				continue
			}
			if [catch {open $fnam "r"} zit] {
				Inf "Failed To Open Pitch Data File '$fnam'"
				continue
			}
			catch {unset vals}
			set OK 1
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
				if {![info exists nuline] || ([llength $nuline] !=3)} {
					Inf "Corrupted Data In Pitch Data File '$fnam'"
					set OK 0
					break
				}
				lappend vals [lindex $nuline 1]
			}
			if {$OK} {
				lappend motifstatinfo $vals
				lappend motifstatsnds $sndfnam
			}
			close $zit
		}
		UnBlock
		if {![info exists motifstatsnds]} {
			Inf "No Motif Information Extracted"
			return
		}
	}
	Block "Sorting Motif Data"
	foreach midilist $motifstatinfo fnam $motifstatsnds {
		if {![info exists motifwhole($midilist)]} {
			set motifwhole($midilist) $fnam
		} else {
			lappend motifwhole($midilist) $fnam
		}
	}
	foreach nam [array names motifwhole] {
		lappend whnamlist $nam
		lappend lenlist [llength $motifwhole($nam)]
	}
	set len [llength $whnamlist]
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set len_n [lindex $lenlist $n]
		set nam_n [lindex $whnamlist $n]
		set m $n
		incr m
		while {$m < $len} {
			set len_m [lindex $lenlist $m]
			set nam_m [lindex $whnamlist $m]
			if {$len_m > $len_n} {							;#	FREQUENCY SORT
				set lenlist [lreplace $lenlist $m $m $len_n]
				set lenlist [lreplace $lenlist $n $n $len_m]
				set whnamlist [lreplace $whnamlist $m $m $nam_n]
				set whnamlist [lreplace $whnamlist $n $n $nam_m]
				set len_n $len_m
				set nam_n $nam_m
			} elseif {$len_m == $len_n} {
				foreach val_n $nam_n val_m $nam_m {
					if {$val_m < $val_n} {					;#	MIDI ORDER SORT
						set lenlist [lreplace $lenlist $m $m $len_n]
						set lenlist [lreplace $lenlist $n $n $len_m]
						set whnamlist [lreplace $whnamlist $m $m $nam_n]
						set whnamlist [lreplace $whnamlist $n $n $nam_m]
						set len_n $len_m
						set nam_n $nam_m
						break
					} elseif {$val_m > $val_n} {
						break
					}
				}
			}
			incr m
		}
		incr n
	}
	UnBlock
	set f .motifstats
	if [Dlg_Create $f "MOTIF STATISTICS" "set pr_motifstats 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		frame $f.1
		frame $f.2
		frame $f.3
		frame $f.4
		frame $f.5
		button $f.0.q -text "Quit" -command "set pr_motifstats 0" -highlightbackground [option get . background {}]
		button $f.0.w -text "To Workspace" -command "set motifstatsexit 1; set pr_motifstats 0" -highlightbackground [option get . background {}]
		button $f.0.p -text "Play Hilited Motif" -command "set pr_motifstats 6" -highlightbackground [option get . background {}]
		pack $f.0.q $f.0.w -side right -padx 10
		pack $f.0.p -side left
		pack $f.0 -side top -fill x -expand true
		button $f.1.full -text "Stats of Complete Motifs" -command "set pr_motifstats 1" -width 32 -highlightbackground [option get . background {}]
		button $f.1.part  -text "Motifs containing selected Motif" -command "set pr_motifstats 2" -width 32 -highlightbackground [option get . background {}]
		pack $f.1.full $f.1.part -side left -padx 2
		pack $f.1 -side top -pady 2
		button $f.2.snds -text "Get Snds with Motifs Listed" -command "set pr_motifstats 3" -width 32 -highlightbackground [option get . background {}]
		button $f.2.exit -text "Get Snds + Exit to Wkspace" -command "set pr_motifstats 4" -width 32 -highlightbackground [option get . background {}]
		pack $f.2.snds $f.2.exit -side left -padx 2
		pack $f.2 -side top -pady 2
		button $f.4.b -text "Motifs containing Motif ->" -command "set pr_motifstats 5" -width 32 -highlightbackground [option get . background {}]
		entry $f.4.e -textvariable motifstatspec -width 32
		pack $f.4.b $f.4.e -side left -padx 2
		pack $f.4 -side top -pady 2
		checkbutton $f.3.ex -text "Ignore Note Repetitions" -variable motifstatsig
		pack $f.3.ex -side top
		pack $f.3 -side top -pady 2
		label $f.5.tit -text ""
		set motifstats [Scrolled_Listbox $f.5.ll -width 180 -height 32 -selectmode single]
		pack $f.5.tit $f.5.ll -side top
		pack $f.5 -side top -fill x -expand true
		bind $f <Escape> {set pr_motifstats 0}
	}
	set motifstatspec ""
	set motifstatsig 1
	$motifstats delete 0 end
	set pr_motifstats 0
	raise $f
	update idletasks
	StandardPosition2 $f
	My_Grab 0 $f pr_motifstats $f
	set finished 0
	while {!$finished} {
		tkwait variable pr_motifstats
		switch -- $pr_motifstats {
			0 {
				set finished 1
			}
			1 {
				if {![info exists whnamlist]} {
					Inf "No Data To Sort"
					continue
				}
				$motifstats delete 0 end
				DisplayMotifStats 0 0 $whnamlist
			}
			2 {
				if {[$motifstats curselection] < 0} {
					Inf "No Motif Selected"
					continue
				}
				DisplayMotifStats 1 $motifstatsig $whnamlist
			}
			3 {
				DisplayedMotifsToChosenFilesList 1
			}
			4 {
				if {[DisplayedMotifsToChosenFilesList 0]} {
					set motifstatsexit 1
					set finished 1
				}
			}
			5 {
				if {[string length $motifstatspec] <= 0} {
					Inf "No Matching Motif Entered"
					continue
				}
				if {![ValidMotifStatsSpec $motifstatspec]} {
					Inf "Invalid Motif Entered"
					continue
				}
				DisplayMotifStats -1 $motifstatsig $whnamlist
			}
			6 {
				if {[$motifstats curselection] < 0} {
					Inf "No Motif Selected"
					continue
				}
				PlayMotifStats
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
	DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
	if {$motifstatsexit} {
		set pr_proptab 1
	}	
}

#---- List Motif stats

proc DisplayMotifStats {includes ig namlist} {
	global motifwhole motifstats propaudhfpass motifstatsndlist motifstatspec
	if {$includes != 0} {
		if {$includes < 0} {
			set hfstr $motifstatspec
		} else {
			set i [$motifstats curselection]
			set line [$motifstats get $i]
			set hfstr [lindex $line 1]
		}
		set midilist [ConvertMotifCodeToMidi $hfstr]
		if {$ig} {
			set midilist [MergeMidiRepets $midilist]
			set hfstr [ConvertMidiToMotifCode $midilist]
		}
		set len [llength $midilist]
		foreach nam $namlist {			;#	CHECK EVERY COMPLETE-HF TO SEE IF IT CONTAINS THE SELECTED ONE
			if {$ig} {
				set nunam [MergeMidiRepets $nam]
			} else {
				set nunam $nam
			}
			set len2 [llength $nunam]
			set diff [expr $len2  - $len]
			if {$diff < 0} {
				continue
			}
			set n 0
			set m [expr $len - 1]
			while {$n <= $diff} {
				set sublist [lrange $nunam $n $m]
				set OK 1
				foreach val1 $midilist val2 $sublist {
					if {$val1 != $val2} {
						set OK 0
						break
					}
				}
				if {$OK} {
					lappend outlist $nam
					break
				}
				incr n
				incr m
			}
		}
		if {![info exists outlist]} {
			Inf "No Matches Found"
			return
		}
		$motifstats delete 0 end
		set motifstatsndlist {}
		foreach nam $outlist {
			set frq [llength $motifwhole($nam)]
			set val [ConvertMidiToMotifCode $nam]
			set line [list $frq $val]
			$motifstats insert end $line
			lappend motifstatsndlist [lindex $motifwhole($nam) 0]
		}
		.motifstats.5.tit config -text "STATS OF HFs INCLUDING \"$hfstr\""
	} else {
		set motifstatsndlist {}
		foreach nam $namlist {
			set frq [llength $motifwhole($nam)]
			set val [ConvertMidiToMotifCode $nam]
			set line [list $frq $val]
			$motifstats insert end $line
			lappend motifstatsndlist [lindex $motifwhole($nam) 0]
		}
		.motifstats.5.tit config -text "STATISTICS OF COMPLETE HFs"
	}
}

#----- Put snds using Motifs listed on Motif-stats, onto Chosen Files list

proc DisplayedMotifsToChosenFilesList {withmsg} {
	global motifstatsndlist chlist ch wl
	if {![info exists motifstatsndlist]} {
		Inf "No Sounds To List"
		return 0
	}
	foreach fnam $motifstatsndlist {
		if {![file exists $fnam]} {
			Inf "File '$fnam' Does Not Exist"
			continue
		}
		set i [LstIndx $fnam $wl]
		if {$i < 0} {
			if {[FileToWkspace $fnam 0 0 0 1 0] > 0} {
				lappend nulist $fnam
			}
		} else {
			lappend nulist $fnam
		}
	}
	if {[info exists nulist]} {
		DoChoiceBak
		set chlist $nulist
		$ch delete 0 end
		foreach fnam $nulist {
			$ch insert end $fnam
		}
		if {$withmsg} {
			Inf "Files Are On The Chosen Files List"
		}
		return 1
	}
	return 0
}

#----- Play a Motif listed on Motif-stats display

proc PlayMotifStats {} {
	global motifstats tp_props_list hasmotifprop prg_dun prg_abortd CDPidrun motifstatsndlist lastmotifstatsplay pa evv
	set outname $evv(DFLT_OUTNAME)
	append outname 11 $evv(SNDFILE_EXT)
	set i [$motifstats curselection]
	set sndfnam [lindex $motifstatsndlist $i]
	if {[file exists $outname] && [info exists lastmotifstatsplay] && [string match $lastmotifstatsplay $sndfnam]} {
		PlaySndfile $outname 0
		return
	}
	if [catch {file delete $outname} zit] { 
		Inf "Cannot Delete Existing Motif Sndfile"
		return
	}
	set datafnam [file rootname $sndfnam]
	if {![info exists pa($sndfnam,$evv(DUR))]} {
		Inf "Cannot Play Motif If Sound '$sndfnam' Is Not On The Workspace"
		return
	}
	Block "Creating Motif"
	set dur $pa($sndfnam,$evv(DUR))
	append datafnam $evv(PCH_TAG) [GetTextfileExtension brk]
	set cmd [file join $evv(CDPROGRAM_DIR) synth]
	lappend cmd wave 1 $outname 44100 1 $dur $datafnam -a0.25 -t256 
	set prg_dun 0
	set prg_abortd 0
	catch {unset simple_program_messages}
	if [catch {open "|$cmd"} CDPidrun] {
		ErrShow "Cannot Synthesize The Pitchline: $CDPidrun"
		catch {unset CDPidrun}
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
		set msg "Cannot Synthesize The Pitchline"
		set msg [AddSimpleMessages $msg]
		ErrShow $msg
		UnBlock
		return
	}
	UnBlock
	PlaySndfile $outname 0
	set lastmotifstatsplay $sndfnam
}

#--- Convert MIDI info to readable note-string

proc ConvertMotifCodeToMidi {mcode} {
	set midilist {}
	set len [string length $mcode]
	set n 0
	while {$n < $len} {
		set char_n [string index $mcode $n]
		switch -- $char_n {
			"C" { set midival 0}
			"D" { set midival 2}
			"E" { set midival 4}
			"F" { set midival 5}
			"G" { set midival 7}
			"A" { set midival 9}
			"B" { set midival 11}
		}
		incr n
		set char_n [string index $mcode $n]
		if {[string match $char_n "#"]} {
			incr midival
			incr n
			set char_n [string index $mcode $n]
		}
		set oct ""
		if {[string match $char_n "-"]} {
			append oct $char_n
			incr n
			set char_n [string index $mcode $n]
		}
		append oct $char_n
		incr n
		set oct [expr $oct + 5]
		set midival [expr $midival + ($oct * 12)]
		lappend midilist $midival
	}
	return $midilist
}

#----- Check user entered valid note representation of motif

proc ValidMotifStatsSpec {mcode} {
	set len [string length $mcode]
	set n 0
	while {$n < $len} {
		set char_n [string index $mcode $n]
		if {![regexp {[A-G]} $char_n]} {
			return 0
		}
		incr n
		if {$n >= $len} {
			return 0
		}
		set char_n [string index $mcode $n]
		if {[string match $char_n "#"]} {
			incr n
			if {$n >= $len} {
				return 0
			}
			set char_n [string index $mcode $n]
		}
		if {[string match $char_n "-"]} {
			incr n
			if {$n >= $len} {
				return 0
			}
			set char_n [string index $mcode $n]
		}
		if {![regexp {[0-9]} $char_n]} {
			return 0
		}
		incr n
	}
	return 1
}

#--- Convert MIDI info to readable note-string

proc ConvertMidiToMotifCode {midilist} {
	set outstr ""
	foreach midi $midilist {
		switch -- $midi {
			40 { append outstr E-2  }
			41 { append outstr F-2  }
			42 { append outstr F#-2 }
			43 { append outstr G-2  }
			44 { append outstr G#-2 }
			45 { append outstr A-2  }
			46 { append outstr A#-2 }
			47 { append outstr B-2  }
			48 { append outstr C-1  }
			49 { append outstr C#-1 }
			50 { append outstr D-1  }
			51 { append outstr D#-1 }
			52 { append outstr E-1  }
			53 { append outstr F-1  }
			54 { append outstr F#-1 }
			55 { append outstr G-1  }
			56 { append outstr G#-1 }
			57 { append outstr A-1  }
			58 { append outstr A#-1 }
			59 { append outstr B-1  }
			60 { append outstr C0   }
			61 { append outstr C#0  }
			62 { append outstr D0   }
			63 { append outstr D#0  }
			64 { append outstr E0   }
			65 { append outstr F0   }
			66 { append outstr F#0  }
			67 { append outstr G0   }
			68 { append outstr G#0  }
			69 { append outstr A0   }
			70 { append outstr A#0  }
			71 { append outstr B0   }
			72 { append outstr C1   }
			73 { append outstr C#1  }
			74 { append outstr D1   }
			75 { append outstr D#1  }
			76 { append outstr E1   }
			77 { append outstr F1   }
			78 { append outstr F#1  }
			79 { append outstr G1   }
			80 { append outstr G#1  }
			81 { append outstr A1   }
			82 { append outstr A#1  }
			83 { append outstr B1   }
			84 { append outstr C2   }
			85 { append outstr C#2  }
			86 { append outstr D2   }
			87 { append outstr D#2  }
			88 { append outstr E2   }
		}
	}
	return $outstr
}

#----- Merge repeated motes in Midi list

proc MergeMidiRepets {midilist} {
	set len [llength $midilist]
	if {$len <= 1} {
		return $midilist
	}
	set lastmidi [lindex $midilist 0]
	set n 1
	while {$n < $len} {
		set thismidi [lindex $midilist $n]
		if {$thismidi == $lastmidi} {
			set midilist [lreplace $midilist $n $n]
			incr len -1
		} else {
			set lastmidi $thismidi
			incr n
		}
	}
	return $midilist
}

##############################################################
# ENTERING AND DISPLAYING MOTIF PROPERTY IN PROPERTIES TABLE #
##############################################################

#------ Assign Tempered pitches to specific times in sndfile, from Props Table display

proc MelodyAssignTab {setprop lineno propno propfile} {
	global pa wl chlist massign_fnam evv pm_numidilist massign_srate massign_invsrate massign_dur massign_chans pr_massign
	global massign_isseq asgrafix massignoutfnam symasamps massign_sequence wstk rememd massign_pdatafile massignsnd massignboth
	global prg_dun prg_abortd CDPidrun tp_props_list tp_propnames tp_props_cnt propfiles_list total_wksp_cnt tp_bfw zz_lastprg pprg
	global simple_program_messages melwidth melstaveleft local_props_list proptabnotesbak proptabnotesfil proptabtimesbak proptabtimesfil
	global play_window_below

	set play_window_below 1
	set massign_fnam [lindex [lindex $tp_props_list $lineno] 0]
	set local_props_list $tp_props_list
	if {![info exists pa($massign_fnam,$evv(SRATE))]} {
		Inf "File '$massign_fnam' Is Not On The Workspace: Cannot Proceed"
		return
	}
	if {$setprop} {
		catch {unset pm_numidilist}
	}
	set massign_srate $pa($massign_fnam,$evv(SRATE))
	set massign_invsrate [expr 1.0 / double($massign_srate)]
	set massign_dur $pa($massign_fnam,$evv(DUR))
	set massign_chans $pa($massign_fnam,$evv(CHANS))
	set massign_pdatafile $evv(DFLT_OUTNAME)
	append massign_pdatafile $evv(TEXT_EXT)	
	set massignsnd $evv(DFLT_OUTNAME)
	append  massignsnd 0 $evv(SNDFILE_EXT)
	set massignboth $evv(DFLT_OUTNAME)
	append  massignboth 1 $evv(SNDFILE_EXT)
	set massignenv $evv(DFLT_OUTNAME)
	append  massignenv 0 $evv(TEXT_EXT)
	set f .massign
	ClearTimesForPropTableMotifEntry
	if [Dlg_Create $f "ASSOCIATE PITCHLINE" "set pr_massign 0" -width 60 -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0]
		set f1 [frame $f.1]
		set f2 [frame $f.2]
		set f3 [frame $f.3]
		set f4 [frame $f.4]
		set f5 [frame $f.5]
		set f6 [frame $f.6]
		set f7 [frame $f.7]
		button $f0.quit -text "Quit" -command {set pr_massign 0} -width 10 -highlightbackground [option get . background {}]
		if {$setprop} {
			label $f0.bak -text "Temp Bakup "
			button $f0.bakn -text "Notes" -command {set pr_massign 2} -width 6 -highlightbackground [option get . background {}]
			button $f0.bakt -text "Times" -command {set pr_massign 3} -width 6 -highlightbackground [option get . background {}]
			button $f0.ok  -text "Save Data" -command {set pr_massign 1} -width 10 -highlightbackground [option get . background {}]
			button $f0.dum -text "" -command {} -width 23 -bd 0 -highlightbackground [option get . background {}]
			button $f0.src -text "Play Src" -command "PlaySndfile $massign_fnam 0" -bg $evv(HELP) -width 10 -highlightbackground [option get . background {}]
			button $f0.sndv -text "SV SetTime" -command "ClearTimesForPropTableMotifEntry; SnackDisplay $evv(SN_TIMESLIST) syncmarks 0 $massign_fnam" -bg $evv(SNCOLOR) -width 10  -highlightbackground [option get . background {}]
			button $f0.sndx -text "Sound View" -command "SnackDisplay 0 $evv(SN_FILE_PRMPAGE_NO_OUTPUT) 0 $massign_fnam" -bg $evv(SNCOLOR) -width 10
			button $f0.pch -text "Play Pitch" -command "PlayAssign 0" -bg $evv(HELP) -width 10 -highlightbackground [option get . background {}]
			if {($massign_chans == 1) || ($massign_chans == 2)} {
				button $f0.both -text "Play Both" -command "PlayAssign 1" -bg $evv(HELP) -width 10 -highlightbackground [option get . background {}]
			}
			pack $f0.ok $f0.sndv $f0.dum $f0.src $f0.sndx $f0.pch -side left -padx 2
			if {($massign_chans == 1) || ($massign_chans == 2)} {
				pack $f0.both -side left -padx 2
			}
		} else {
			button $f0.src -text "Play Src" -command "PlaySndfile $massign_fnam 0" -bg $evv(HELP) -width 10 -highlightbackground [option get . background {}]
			button $f0.pch -text "Play Pitch" -command "PlayExistingPropMotif $massign_srate $massign_dur 0" -bg $evv(HELP) -width 10 -highlightbackground [option get . background {}]
			pack $f0.src $f0.pch -side left -padx 2
			if {[info exists pa($massign_fnam,$evv(CHANS))] && ($pa($massign_fnam,$evv(CHANS)) == 1)} {
				button $f0.both -text "Play Both" -command "PlayExistingPropMotif $massign_srate $massign_dur 1" -bg $evv(HELP) -width 10 -highlightbackground [option get . background {}]
				pack $f0.both -side left -padx 2
			}
		}
		pack $f.0 -side top -fill x -expand true
		pack $f0.quit -side right
		if {$setprop} {
			pack $f0.bakt $f0.bakn $f0.bak -side right -padx 2
		}
		if {$setprop} {
			button $f.1.c  -text "C"  -bd 4 -command "PlaySndfile $evv(TESTFILE_C)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
			button $f.1.db -text "Db" -bd 4 -command "PlaySndfile $evv(TESTFILE_Db) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
			button $f.1.d  -text "D"  -bd 4 -command "PlaySndfile $evv(TESTFILE_D)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
			button $f.1.eb -text "Eb" -bd 4 -command "PlaySndfile $evv(TESTFILE_Eb) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
			button $f.1.e  -text "E"  -bd 4 -command "PlaySndfile $evv(TESTFILE_E)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
			button $f.1.f  -text "F"  -bd 4 -command "PlaySndfile $evv(TESTFILE_F)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
			button $f.1.gb -text "Gb" -bd 4 -command "PlaySndfile $evv(TESTFILE_Gb) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
			button $f.1.g  -text "G"  -bd 4 -command "PlaySndfile $evv(TESTFILE_G)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
			button $f.1.ab -text "Ab" -bd 4 -command "PlaySndfile $evv(TESTFILE_Ab) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
			button $f.1.a  -text "A"  -bd 4 -command "PlaySndfile $evv(TESTFILE_A)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
			button $f.1.bb -text "Bb" -bd 4 -command "PlaySndfile $evv(TESTFILE_Bb) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
			button $f.1.b  -text "B"  -bd 4 -command "PlaySndfile $evv(TESTFILE_B)  0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
			button $f.1.c2 -text "C"  -bd 4 -command "PlaySndfile $evv(TESTFILE_C2) 0" -width 2 -bg $evv(HELP) -highlightbackground [option get . background {}]
			pack $f.1.c $f.1.db $f.1.d $f.1.eb $f.1.e $f.1.f $f.1.gb $f.1.g $f.1.ab $f.1.a $f.1.bb $f.1.b $f.1.c2 -side left
			pack $f.1 -side top -pady 2
			label $f.2.ll -text "Assign Note Times from \"Sound View\" : Click on Staff to create Notes : Control-Click to Delete" -fg $evv(SPECIAL)
			pack $f.2.ll -side top
			pack $f.2 -side top
			frame $f.3.clear
			button $f.3.clear.notes -text "Clear Notes" -command "AsgrafixClear 1" -highlightbackground [option get . background {}]
			button $f.3.clear.times -text "Clear Times" -command ClearTimesForPropTableMotifEntry -highlightbackground [option get . background {}]
			pack $f.3.clear.notes $f.3.clear.times -side left -padx 4
			pack $f.3.clear -side top -pady 4
		}
		set asgrafix [EstablishMelodyEntryDisplay $f.3]
		pack $asgrafix -side top -pady 1
		pack $f.3 -side top -fill both -expand true
		wm resizable $f 1 1
		if {$setprop} {
			frame $f.8
			button $f.8.t -text "Wrong Pitchline?" -command PitchlineTips -highlightbackground [option get . background {}]
			pack $f.8.t -side right
			pack $f.8 -side top -pady 2 -fill x -expand true
			set massign_isseq 0
			bind $asgrafix <ButtonRelease-1> {AsgrafixAddPitch $asgrafix %x %y 0}
			bind $asgrafix <Shift-ButtonRelease-1> {AsgrafixAddPitch $asgrafix %x %y 1}
			bind $asgrafix <Control-ButtonRelease-1> {AsgrafixDelPitch $asgrafix %x %y}
		}
		bind $f <Return> {set pr_massign 1}
		bind $f <Escape> {set pr_massign 0}
	}
	if {$setprop} {
		wm title $f "Associate Pitchline With File $massign_fnam"
	} else {
		wm title $f "Pitchline Associated With File $massign_fnam"
	}
	;# Timemarks are read INTO symasamps(0) from Sound View (or restored from a previous pass)
	catch {unset symasamps(0)}

	if {!$setprop} {
		AsgrafixClear 0
		set len [llength $pm_numidilist]
		incr len 4
		set notestep [expr int(round(double($melwidth) / double($len)))]	
		set xpos [expr $melstaveleft + ($notestep * 2)]
		foreach midival $pm_numidilist {
			if {![InsertAssignPitchGrafix $xpos $midival]} {
				break
			}
			incr xpos $notestep
		}
	} else {
		if {[info exists proptabnotesbak]} {
			if {[string match $proptabnotesfil $massign_fnam]} {
				AsgrafixClear 0
				set pm_numidilist $proptabnotesbak
				set len [llength $pm_numidilist]
				incr len 4
				set notestep [expr int(round(double($melwidth) / double($len)))]	
				set xpos [expr $melstaveleft + ($notestep * 2)]
				foreach midival $pm_numidilist {
					if {![InsertAssignPitchGrafix $xpos $midival]} {
						break
					}
					incr xpos $notestep
				}
			}
			unset proptabnotesbak
			unset proptabnotesfil
			set xfnam [file join $evv(URES_DIR) proptabnotes]
			append xfnam $evv(CDP_EXT)
			catch {file delete $xfnam}
		}
		if {[info exists proptabtimesbak]} {
			if {[string match $proptabtimesfil $massign_fnam]} {
				set symasamps(0) $proptabtimesbak
			}
			unset proptabtimesbak
			unset proptabtimesfil
			set xfnam [file join $evv(URES_DIR) proptabtimes]
			append xfnam $evv(CDP_EXT)
			catch {file delete $xfnam}
		}
	}
	set massignoutfnam ""
	raise $f
	update idletasks
	StandardPosition $f
	set finished 0
	set pr_massign 0
	if {$setprop} {
		My_Grab 0 $f pr_massign $f.1.e
	} else {
		My_Grab 0 $f pr_massign
	}
	while {!$finished} {
		tkwait variable pr_massign
		if {$pr_massign} {
			if {$pr_massign == 2} {
				if {![info exists pm_numidilist]} {
					Inf "No Notedata To Save"	
				} else {
					set proptabnotesbak $pm_numidilist
					set proptabnotesfil $massign_fnam
				}
				continue
			} elseif {$pr_massign == 3} {
				if {![info exists symasamps(0)]} {
					Inf "No Timedata To Save"	
				} elseif {[llength $symasamps(0)] < 2} {
					Inf "Motif Must Have At Least Two Time Points"	
				} else {
					set proptabtimesbak $symasamps(0)
					set proptabtimesfil $massign_fnam
				}
				continue
			}
			if {![info exists symasamps(0)]} {
				Inf "No Timemarks Specified"
				continue
			} elseif {[llength $symasamps(0)] < 2} {
				Inf "Motif Must Have At Least Two Notes"
				continue
			}
			if {![info exists pm_numidilist]} {
				Inf "No Pitch-Sequence Specified"
				continue
			}
			if {[llength $pm_numidilist] != [llength $symasamps(0)]} {
				Inf "Not Every Time-Mark Has Been Assigned A Pitch"
				continue
			}
			catch {unset massign_sequence}
			catch {unset symatimes(0)}
			foreach samptime $symasamps(0) midival $pm_numidilist {
				set time [expr double($samptime) * $massign_invsrate]
				lappend symatimes(0) $time
				lappend massign_sequence $time $midival
			}
			set massign_sequence [lreplace $massign_sequence 0 0 0.0]	;#	EXTEND TO TIME ZERO
			if {$setprop} {
				set delletes {}
				set outfnamseq [file rootname $massign_fnam]
				append outfnamseq $evv(SEQ_TAG) $evv(TEXT_EXT)
				if {[file exists $outfnamseq]} {
					set msg "File '$outfnamseq' Already Exists: Overwrite It ?"
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
					set i [LstIndx $outfnamseq $wl]
					if {![DeleteFileFromSystem $outfnamseq 0 1]} {
						Inf "Cannot Delete Existing File '$outfnamseq'"
						continue
					} else {
						DummyHistory $outfnamseq "DESTROYED"
						if {$i >= 0} {
							WkspCnt [$wl get $i] -1
							$wl delete $i
							catch {unset rememd}
						}
						if {![string match $outfnamseq [file tail $outfnamseq]]} {
							lappend delletes $outfnamseq
						}
					}
				}
				set outfnamflt [file rootname $massign_fnam]
				append outfnamflt $evv(FILT_TAG) $evv(TEXT_EXT)
				if {[file exists $outfnamflt]} {
					set msg "File '$outfnamflt' Already Exists: Overwrite It ?"
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
					set i [LstIndx $outfnamflt $wl]
					if {![DeleteFileFromSystem $outfnamflt 0 1]} {
						Inf "Cannot Delete Existing File '$outfnamflt'"
						continue
					} else {
						DummyHistory $outfnamflt "DESTROYED"
						if {$i >= 0} {
							WkspCnt [$wl get $i] -1
							$wl delete $i
							catch {unset rememd}
						}
						if {![string match $outfnamflt [file tail $outfnamflt]]} {
							lappend delletes $outfnamflt
						}
					}
				}
				set outfnamfrq [file rootname $massign_fnam]
				append outfnamfrq $evv(PCH_TAG) [GetTextfileExtension brk]
				if {[file exists $outfnamfrq]} {
					set msg "File '$outfnamfrq' Already Exists: Overwrite It ?"
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
					set i [LstIndx $outfnamfrq $wl]
					if {![DeleteFileFromSystem $outfnamfrq 0 1]} {
						Inf "Cannot Delete Existing File '$outfnamfrq'"
						continue
					} else {
						DummyHistory $outfnamfrq "DESTROYED"
						if {$i >= 0} {
							WkspCnt [$wl get $i] -1
							$wl delete $i
							catch {unset rememd}
						}
						if {![string match $outfnamfrq [file tail $outfnamfrq]]} {
							lappend delletes $outfnamfrq
						}
					}
				}

				;#	OFFSET SEQUENCE (SO ZERO IN SEQ = FIRST TIMEMARK IN SRC)

				set orig_massign_sequence $massign_sequence
				unset massign_sequence
				set offset [lindex $symasamps(0) 0]
				set offset [expr double($offset) * $massign_invsrate]
				foreach {time val} $orig_massign_sequence {
					set time [expr $time - $offset]
					lappend massign_sequence $time $val
				}

				;#	INSERT THE OFFSET PROP IN PROPS FILE, IF SUCH A PROP EXISTS

				set kk 0
				set k -1
				foreach nam $tp_propnames {
					if {[string match -nocase $nam "offset"]} {
						set k $kk
						break
					}
					incr kk
				}
				if {$k >= 0} {
					incr k			;#	Position of 'offset' property on sndline
					set line [lindex $local_props_list $lineno]
					set line [lreplace $line $k $k $offset]
					set local_props_list [lreplace $local_props_list $lineno $lineno $line]
				}

				;#	INSERT THE HF PROP IN PROPS FILE, IF SUCH A PROP EXISTS

				set kk 0
				set k -1
				foreach nam $tp_propnames {
					if {[string match -nocase $nam "HF"]} {
						set k $kk
						break
					}
					incr kk
				}
				if {$k >= 0} {
					incr k			;#	Position of 'HF' property on sndline
					set nuhf [CreateTempHFData $massign_sequence]
					if {[string length $nuhf] > 0} {
						set line [lindex $local_props_list $lineno]
						set line [lreplace $line $k $k $nuhf]
						set local_props_list [lreplace $local_props_list $lineno $lineno $line]
					}
				}
				
				;#	GET LOUDNESSES AT TIMEMARKS IN ORDER TO WRITE SEQ FILE
				
				set cmd [file join $evv(CDPROGRAM_DIR) envel]
				lappend cmd extract 2 $massign_fnam $massignenv 50 -d0
				set prg_dun 0
				set prg_abortd 0
				catch {unset simple_program_messages}
				if [catch {open "|$cmd"} CDPidrun] {
					ErrShow "Cannot Extract Envelope From Source: $CDPidrun"
					catch {unset CDPidrun}
					continue
				} else {
					fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
				}
				vwait prg_dun
				if {$prg_abortd} {
					set prg_dun 0
				}
				if {!$prg_dun} {
					set msg "Cannot Extract Envelope From Source $fnam: $CDPidrun"
					set msg [AddSimpleMessages $msg]
					ErrShow $msg
					catch {file delete $out_fnam}
					continue
				}
				set levels [GetTimemarkLevels $massignenv $symatimes(0) $massign_dur]
				if {[llength $levels] > 0} {

					;#	WRITE SEQUENCE DATA, ASSUMING SEQ SRC HAS PITCH 60

					if [catch {open $outfnamseq "w"} zit] {
						Inf "Cannot Open File '$outfnamseq' To Write Sequence Data"
						continue
					}
					set massign_sequence [lreplace $massign_sequence 0 0 0.0]
					foreach {time midival} $massign_sequence level $levels {
						set line [list $time [expr $midival - 60] $level]
						puts $zit $line
					}
					close $zit
				} else {
					Inf "Cannot Create Sequence File"
				}
					;#	WRITE SYNTH BRKPNT DATA

				ConvertMassignSeqToFrqBrkpntAndSaveToFile $massign_sequence $outfnamfrq 1

				;#	WRITE FILTER DATA, WHICH IS NOT OFFSET, AS FILTER DATA MAY BE APPLIED TO SRC SND

				set massign_sequence $orig_massign_sequence
				ConvertMassignSeqToFilterDataAndSaveToFile $massign_sequence $outfnamflt 0
				FilesToWkspace $outfnamseq $outfnamfrq $outfnamflt
				if {![string match $outfnamfrq [file tail $outfnamfrq]]} {
					UpdateBakLogWithMotifFiles $delletes $outfnamseq $outfnamfrq $outfnamflt
				}
				set line [lindex $local_props_list $lineno]
				set line [lreplace $line $propno $propno "yes"]
				set local_props_list [lreplace $local_props_list $lineno $lineno $line]
				set tempfnam $evv(DFLT_OUTNAME)$evv(TEXT_EXT)
				if [catch {open $tempfnam "w"} zit] {
					Inf "Cannot Open Temporary File 'tempfnam' To Write Updated Properties Information"
					continue
				}
				set theseprops [join $tp_propnames]
				puts $zit $theseprops
				foreach line $local_props_list {
					puts $zit $line
				}
				close $zit
				set onam $propfile
				if [catch {file delete $onam} zit] {
					Inf "Cannot Delete Original File '$onam'"
					break
				}
				set k [lsearch -exact $propfiles_list $onam]
				if {$k >= 0} {
					set propfiles_list [lreplace $propfiles_list $k $k]
				}
				set i [LstIndx $onam $wl]
				if {$i >= 0} {
					PurgeArray $onam
					RemoveFromChosenlist $onam
					incr total_wksp_cnt -1
					$wl delete $i
					catch {unset rememd}
				}
				if [catch {file rename $tempfnam $onam} zit] {
					set msg "Cannot Rename File '$tempfnam' To '$onam'.\n\n"
					append msg "You Can Rename File '$tempfnam' Now, Outside The Soundloom, Before Proceeding.\n"
					append msg "\nIf You Do Not, You Will Lose The New Data Once You Hit 'OK'?"
					Inf $msg
					break
				}
				lappend propfiles_list $onam
				FileToWkspace $onam 0 0 0 0 1
				set tp_props_list $local_props_list
				set new_props [lindex $tp_props_list $lineno]
				incr lineno ;#	lineno BEFORE REFERS TO TABLE DISPLAY, RATHER THAN tp_props_list
				set m 1
				set mm 0
				while {$m < $tp_props_cnt} {
					set newval [lindex $new_props $m]
					set oldval [$tp_bfw.$lineno.$m cget -text]
					if {[string compare $oldval $newval]} {
						set newvaldisp $newval
						set pnam [lindex $tp_propnames $mm]
						if {[string match [string tolower $pnam] "motif"]} {
							set newvaldisp "yes"
						} elseif {[string match [string tolower $pnam] "hf"]} {
							set newvaldisp $newval
						} elseif {[string match [string tolower $pnam] "offset"]} {
							set newvaldisp [DecPlaces $newvaldisp 4]
						} elseif {[string match [string tolower $pnam] "rcode"]} {
							set newvaldisp $oldval
						} elseif {[string match [string tolower $pnam] "text"]} {
							set newvaldisp $oldval
						}
						$tp_bfw.$lineno.$m config -text $newvaldisp
						bind $tp_bfw.$lineno.$m <Control-ButtonRelease-1> {}
						bind $tp_bfw.$lineno.$m <Control-ButtonRelease-1> "ReadPropertyExplanation  $pnam \"$newval\""
						bind $tp_bfw.$lineno.$m <Shift-ButtonRelease-1>   "WritePropertyExplanation $pnam \"$newval\""
					}
					incr m
					incr mm
				}
				set finished 1
			}
		} else {
			set finished 1
		}
	}
	DeleteAllTemporaryFilesWhichAreNotCDPOutput all 0
	if {[info exists pprg] && ($pprg == -1)} {
		if [info exists zz_lastprg] {
			set pprg $zz_lastprg
			unset zz_lastprg
		} else {
			unset pprg
		}
	}
	catch {unset play_window_below}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

#-------  See Motif from prop file

proc SeePropMotif {lineno propno propfile} {
	global pm_numidilist tp_props_list evv 
	set sndfnam [lindex [lindex $tp_props_list $lineno] 0]
	set fnam [file rootname $sndfnam]
	append fnam $evv(FILT_TAG) $evv(TEXT_EXT)
	if {![file exists $fnam]} {
		Inf "No Motif Data"
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Failed To Open Motif Data File '$fnam'"
		continue
	}
	catch {unset vals}
	set OK 1
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
		if {![info exists nuline] || ([llength $nuline] !=3)} {
			Inf "Corrupted Data In Motif Data File '$fnam'"
			set OK 0
			break
		}
		lappend vals [lindex $nuline 1]
	}
	close $zit
	catch {unset pm_numidilist}
	foreach {val1 val2} $vals {
		lappend pm_numidilist $val1
	}
	MelodyAssignTab 0 $lineno $propno $propfile
}

#----- Edit Ideas file

proc IdeasFile {no} {
	global tp_props_list evv wstk brk wl ww rememd total_wksp_cnt ideas_create
	set fdir [file dirname [lindex [lindex $tp_props_list 0] 0]]
	set ideasfile [file join $fdir ideas$evv(TEXT_EXT)]
	if {![string match $no "0"] && [regexp {^[0-9]+$} $no]} {
		if {![file exists $ideasfile]} {
			Inf "Click On Property Name To Create Or View An Ideas File"
			return
		}
		if [catch {open $ideasfile "r"} zit] {
			Inf "Cannot Open File '$ideasfile'"
			return
		}
		set showing 0
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			set line [split $line]
			set nuline {}
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] > 0} {
					lappend nuline $item
				}
			}
			set line $nuline
			set inval [lindex $line 0]
			if {![regexp {[0-9]} [string index $inval 0]]} {
				if {$showing} {
					lappend showlines $line
				}
				continue
			} else {
				set len [string length $inval]
				set numval [string index $inval 0]
				set n 1
				while {$n < $len} {
					if {[regexp {[0-9]} [string index $inval $n]]} {
						append numval [string index $inval $n]
					} else {
						break
					}
					incr n
				}
			}
			if {!$showing} {
				if {$numval == $no} {
					lappend showlines $line
					set showing 1
				}
			} else {
				break
			}
		}
		close $zit
		if {$showing} {
			set msg [lindex $showlines 0]
			foreach line [lrange $showlines 1 end] {
				append msg "\n" $line
			}
			append msg "\n\nTo Edit: Shift-click On Property Entry"
			Inf $msg
		} else {
			Inf "No Line In The 'ideas' File Begins With '$no'"
		}
		return
	}
	if {![file exists $ideasfile]} {
		set msg "Create An Ideas File ?"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			set ideas_create 1
			if [catch {open $ideasfile "w"} zit] {
				Inf "Cannot Open File '$ideasfile'"
				unset ideas_create
				return
			}
			close $zit
		}
	}
	if {[info exists brk(from_wkspace)]} {
		set exbrk $brk(from_wkspace)
	}
	set onwkspace 0
	if {[LstIndx $ideasfile $wl] >= 0} {
		set onwkspace 1
	}
	set brk(from_wkspace) 0
	Dlg_EditTextfile $ideasfile -1 0 ideas
	catch {unset ideas_create}
	if {[info exists exbrk]} {
		set brk(from_wkspace) $exbrk
	} else {
		unset brk(from_wkspace)
	}
	set i [LstIndx $ideasfile $wl]
	if {!$onwkspace && ($i >= 0)} {			;#	KEEP OFF WORKSPACE IF POSS 
		PurgeArray $ideasfile
		RemoveFromChosenlist $ideasfile
		incr total_wksp_cnt -1
		$wl delete $i
		ForceVal $ww.1.a.endd.l.cnts.all $total_wksp_cnt
		catch {unset rememd}
	}
}

proc PropTabEdge {where} {
	global tp_can proplocm proplocn tp_props_cnt tp_props_list tp_bfw evv
	switch -- $where {
		0 {
			$tp_can xview moveto 0
		}
		1 {
			$tp_can xview moveto 1
		}
		2 {
			$tp_can yview moveto 0
		}
		3 {
			$tp_can yview moveto 1
		}
	}
	switch -- $where {
		0 -
		1 {
			if {![info exists proplocn]} {
				return
			}
			set m 1
			while {$m < $tp_props_cnt} {
				$tp_bfw.$proplocn.$m config -bg $evv(EMPH)
				incr m
			}
			set x 0
			after 1000 {set x 1}
			vwait x
			set m 1
			while {$m < $tp_props_cnt} {
				$tp_bfw.$proplocn.$m config -bg [option get . background {}]
				incr m
			}
		}
		2 -
		3 {
			if {![info exists proplocm]} {
				return
			}
			set len [llength $tp_props_list]
			set n 1
			while {$n <= $len} {
				$tp_bfw.$n.$proplocm config -bg $evv(EMPH)
				incr n
			}
			set x 0
			after 1000 {set x 1}
			vwait x
			set n 1
			while {$n <= $len} {
				$tp_bfw.$n.$proplocm config -bg [option get . background {}]
				incr n
			}
		}
	}
}

proc IncrTabPropName {down} {
	global nuaddpval
	if {![regexp {[0-9]} $nuaddpval]} {
		return
	}
	set len [string length $nuaddpval]
	set n [expr $len - 1]
	set gotno 0
	while {$n >= 0} {
		if {!$gotno} {
			if {[regexp {[0-9]} [string index $nuaddpval $n]]} {
				set numend $n
				set gotno 1
			}
		} else {
			if {![regexp {[0-9]} [string index $nuaddpval $n]]} {
				set numstt [expr $n + 1]
				break
			}
		}	
		incr n -1
	}
	if {!$gotno} {
		return
	} elseif {![info exists numstt]} {
		set numstt 0
	}
	set val [string range $nuaddpval $numstt $numend]
	if {$down} {
		if {$val > 0} {
			incr val -1
		} else {
			return
		}
	} else {
		incr val
	}
	incr numstt -1
	incr numend
	set nunam ""
	if {$numstt >= 0} {
		append nunam [string range $nuaddpval 0 $numstt]
	}
	append nunam $val
	if {$numend < $len} {
		append nunam [string range $nuaddpval $numend end]
	}
	set nuaddpval $nunam
}

#----- Save last motif attempted to enter in Props Motif-Entry page

proc SavePropTabNotesData {} {
	global proptabnotesbak proptabnotesfil evv
	set fnam [file join $evv(URES_DIR) proptabnotes]
	append fnam $evv(CDP_EXT)
	set line [concat $proptabnotesfil $proptabnotesbak]
	if [catch {open $fnam "w"} zit] {
		return
	}
	puts $zit $line
	close $zit
}

#----- Save last motif-pitches attempted to enter in Props Motif-Entry page

proc SavePropTabTimesData {} {
	global proptabtimesbak proptabtimesfil evv
	set fnam [file join $evv(URES_DIR) proptabtimes]
	append fnam $evv(CDP_EXT)
	set line [concat $proptabtimesfil $proptabtimesbak]
	if [catch {open $fnam "w"} zit] {
		return
	}
	puts $zit $line
	close $zit
}

#----- Save last motif-timings attempted to enter in Props Motif-Entry page

proc LoadPropTabNotesData {} {
	global proptabnotesbak proptabnotesfil proptabtimesbak proptabtimesfil evv
	set fnam [file join $evv(URES_DIR) proptabnotes]
	append fnam $evv(CDP_EXT)
	if {[file exists $fnam]} {
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot Open File '$fnam' Storing Note Information On Last Motif Entry For Props-Table"
			return
		}
		while {[gets $zit line] >= 0} {
			set line [split $line]
			if {[llength $line] < 2} {
				Inf "Data Corrupted In File '$fnam' Storing Note Information On Last Motif Entry For Props-Table"
				close $zit
				return
			}
			set proptabnotesfil [lindex $line 0]
			set proptabnotesbak [lrange $line 1 end]
			break
		}
		close $zit
		if {![file exists $proptabnotesfil]} {
			unset proptabnotesbak
			unset proptabnotesfil
			return
		}
		foreach val $proptabnotesbak {
			if {![regexp {^[0-9]+$} $val] || ($val < 36) || ($val > 84)} {
				Inf "Data Corrupted In File '$fnam' Storing Note Information On Last Motif Entry For Props-Table"
				unset proptabnotesbak
				unset proptabnotesfil
				return
			}
		}
	}	
	set fnam [file join $evv(URES_DIR) proptabtimes]
	append fnam $evv(CDP_EXT)
	if {[file exists $fnam]} {
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot Open File '$fnam' Storing Time Information On Last Motif Entry For Props-Table"
			return
		}
		while {[gets $zit line] >= 0} {
			set line [split $line]
			if {[llength $line] < 2} {
				Inf "Data Corrupted In File '$fnam' Storing Time Information On Last Motif Entry For Props-Table"
				close $zit
				return
			}
			set proptabtimesfil [lindex $line 0]
			set proptabtimesbak [lrange $line 1 end]
			break
		}
		close $zit
		if {![file exists $proptabtimesfil]} {
			unset proptabtimesbak
			unset proptabtimesfil
			return
		}
		set lastval -1.0
		foreach val $proptabtimesbak {
			if {![IsNumeric $val] || ($val < $lastval) || ($val < 0.0)} {
				Inf "Data Corrupted In File '$fnam' Storing Time Information On Last Motif Entry For Props-Table"
				unset proptabtimesbak
				unset proptabtimesfil
				return
			}
			set lastval $val
		}
	}	
}

#---- Reorder sndfiles in a properties file, in accordance with a textfile-listing

proc PropsSoundSort {} {
	global wl chlist evv pa props_info wstk pr_prprr prprfnam propfiles_list rememd 

	set msg "Select A Property File And A Sndfile Listing On The Workspace\n"
	append msg "Or Place These On The Chosen Files List\n\n"
	append msg "Properties File Will Be Reordered In The Order Defined By The Soundfile Listing"

	set ilist [$wl curselection]
	if {![info exists ilist] || ([llength $ilist] != 2)} {
		catch {unset ilist}
		if {[info exists chlist] && ([llength $chlist] == 2)} {
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
	if {![info exists ilist] || ([llength $ilist] != 2)} {
		Inf $msg
		return
	}
	set gotpropfile 0
	foreach i $ilist {
		set fnam [$wl get $i]
		set ftyp [FindFileType $fnam]
		if {!($ftyp & $evv(IS_A_TEXTFILE))} {
			Inf $msg
			return
		}
		if {!$gotpropfile} {
			if {[ThisIsAPropsFile $fnam 0 0]} {
				set gotpropfile 1
				set pfnam $fnam
			} elseif {[IsASndlist $pa($fnam,$evv(FTYP))]} {
				set chfnam $fnam
			} else {
				Inf $msg
				return ""
			}
		} else {
			if {[IsASndlist $pa($fnam,$evv(FTYP))]} {
				set chfnam $fnam
			} else {
				Inf $msg
				return ""
			}
		}
	}
	if {!([info exists pfnam] && [info exists chfnam])} {
		Inf $msg
		return ""
	}
	set propnames  [lindex $props_info 0]
	set props_list [lindex $props_info 1]
	foreach line $props_list {
		lappend origsnds [lindex $line 0]
	}
	if [catch {open $chfnam "r"} zit] {
		Inf "Cannot Open File '$chfnam' To Read List Of Sounds"
		return
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		lappend filorder $line
	}
	close $zit
	if {![info exists filorder]} {
		Inf "NO DATA IN FILE '$chfnam'"
		return
	}
	set len [llength $filorder]
	if {$len > 1} {
		set len_less_one [expr $len - 1]
		set n 0
		while {$n < $len_less_one} {
			set fnam_n [lindex $filorder $n]
			set m $n
			incr m
			while {$m < $len} {
				set fnam_m [lindex $filorder $m]
				if {[string match $fnam_n $fnam_m]} {
					Inf "There Is A Duplicated Soundfile ($fnam_n) In The Sound-listing ($chfnam): Cannot Proceed"
					return
				}
				incr m
			}
			incr n
		}
	}
	foreach fnam $filorder {
		if {[lsearch $origsnds $fnam] < 0} {
			Inf "There Is A Sound ($fnam) In Sound-listing ($chfnam) Which Is Not In The Properties File"
			return
		}
	}
	set msgsent 0
	foreach fnam $origsnds {
		if {[lsearch $filorder $fnam] < 0} {
			if {!$msgsent} {
				set msg "There Are Is A Sound ($fnam) In The Properties File Which Is Not In The Sound-listing File ($chfnam).\n\n"			
				append msg "Such Sounds Will Be Omitted From The Reordered Property File.\n\n"
				append msg "Is This OK ??\n\n"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					return
				}
				set msgsent 1
			}
		}
	}
	set outnames [concat $propnames]
	lappend outprops $outnames
	foreach fnam $filorder {
		set k [lsearch $origsnds $fnam]
		lappend outprops [lindex $props_list $k]
	}
	set f .prprr
	if [Dlg_Create $f "REORDER PROPERTY ROWS" "set pr_prprr 0" -borderwidth $evv(BBDR)] {
		frame $f.a -borderwidth $evv(BBDR)
		frame $f.b -borderwidth $evv(BBDR)
		button $f.a.q -text "Abandon" -command {set pr_prprr 0} -width 16 -highlightbackground [option get . background {}]
		button $f.a.r -text "Reorder" -command {set pr_prprr 1} -width 16 -highlightbackground [option get . background {}]
		pack $f.a.r -side left -padx 2
		pack $f.a.q -side right
		pack $f.a -side top -fill x -expand true -pady 2
		label $f.b.ll -text "Output property-file name "
		entry $f.b.e -textvariable prprfnam
		pack $f.b.ll $f.b.e -side left
		pack $f.b -side top -pady 2
		wm resizable $f 1 1
		bind $f <Escape> {set pr_prprr 0}
		bind $f <Return> {set pr_prprr 1}
	}
	set pr_prprr 0
	set finished 0
	set prprfnam ""
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_prprr $f
	while {!$finished} {
		tkwait variable pr_prprr
		if {$pr_prprr} {
			if {[string length $prprfnam] <= 0} {
				Inf "No Output Filename Entered"
				continue
			}
			if {![ValidCDPRootname $prprfnam]} {
				continue
			}
			set outfnam [string tolower $prprfnam]
			append outfnam [GetTextfileExtension props]
			if {[string match $pfnam $outfnam]} {
				Inf "You Cannot Overwrite The Input Property File Here"
				continue
			}
			if {[file exists $outfnam]} {
				set msg "File '$outfnam' Already Exists: Overwrite It ?"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				set i [LstIndx $outfnam $wl]
				if {![DeleteFileFromSystem $outfnam 0 1]} {
					Inf "Cannot Delete Existing File '$outfnam'"
					continue
				} else {
					DummyHistory $outfnam "DESTROYED"
					if {[info exists propfiles_list]} {
						set k [lsearch $propfiles_list $outfnam]
						if {$k > 0} {
							set propfiles_list [lreplace $propfiles_list $k $k]
						}
					}
					if {$i >= 0} {
						WkspCnt [$wl get $i] -1
						$wl delete $i
						catch {unset rememd}
					}
				}
			}
			if [catch {open $outfnam "w"} zit] {
				Inf "Cannot Create File '$outfnam' To Write Data"
				continue
			}
			foreach line $outprops {
				puts $zit $line
			}
			close $zit
			FileToWkspace $outfnam 0 0 0 0 1
			Inf "File '$outfnam' Has Been Created"
			break
		} else {
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Rename all sndfiles in a 'properties file' (i.e. possibly now an invalid props file!)

proc PropsSoundRename {} {
	global wl chlist evv pa props_info wstk pr_prpre prpefnam propfiles_list rememd 

	set msg "Select A Property File And A Sndfile Listing On The Workspace\n"
	append msg "Or Place These On The Chosen Files List.\n\n"
	append msg "Sounds In Properties File Will Take The Names Of The Files In The Soundlisting\n"
	append msg "In The Order In Which They Are Listed."

	set ilist [$wl curselection]
	if {![info exists ilist] || ([llength $ilist] != 2)} {
		catch {unset ilist}
		if {[info exists chlist] && ([llength $chlist] == 2)} {
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
	if {![info exists ilist] || ([llength $ilist] != 2)} {
		Inf $msg
		return
	}
	set gotpropfile 0
	foreach i $ilist {
		set fnam [$wl get $i]
		set ftyp [FindFileType $fnam]
		if {!($ftyp & $evv(IS_A_TEXTFILE))} {
			Inf $msg
			return
		}
		if {!$gotpropfile} {
			if {[ThisIsAPropsFile $fnam 0 1]} {
				set gotpropfile 1
				set pfnam $fnam
			} elseif {[IsASndlist $pa($fnam,$evv(FTYP))]} {
				set chfnam $fnam
			} else {
				Inf $msg
				return ""
			}
		} else {
			if {[IsASndlist $pa($fnam,$evv(FTYP))]} {
				set chfnam $fnam
			} else {
				Inf $msg
				return ""
			}
		}
	}
	if {!([info exists pfnam] && [info exists chfnam])} {
		Inf $msg
		return ""
	}
	set propnames  [lindex $props_info 0]
	set props_list [lindex $props_info 1]

	set plen [llength $props_list]
	if [catch {open $chfnam "r"} zit] {
		Inf "Cannot Open File '$chfnam' To Read List Of Sounds"
		return
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		lappend filorder $line
	}
	close $zit
	if {![info exists filorder]} {
		Inf "No Data In File '$chfnam'"
		return
	}
	set len [llength $filorder]
	if {$len > 1} {
		set len_less_one [expr $len - 1]
		set n 0
		while {$n < $len_less_one} {
			set fnam_n [lindex $filorder $n]
			set m $n
			incr m
			while {$m < $len} {
				set fnam_m [lindex $filorder $m]
				if {[string match $fnam_n $fnam_m]} {
					Inf "There Is A Duplicated Soundfile ($fnam_n) In The Sound-listing ($chfnam): Cannot Proceed"
					return
				}
				incr m
			}
			incr n
		}
	}
	if {$len != $plen} {
		Inf "Property File And Soundslist File Do Not Contain The Same Number Of Soundfile Entries"
		return
	}
	set outnames [concat $propnames]
	lappend outprops $outnames 
	foreach fnam $filorder line $props_list {
		set line [lreplace $line 0 0 $fnam]
		lappend outprops $line
	}
	set f .prpre
	if [Dlg_Create $f "REORDER PROPERTY ROWS" "set pr_prpre 0" -borderwidth $evv(BBDR)] {
		frame $f.a -borderwidth $evv(BBDR)
		frame $f.b -borderwidth $evv(BBDR)
		button $f.a.q -text "Abandon" -command {set pr_prpre 0} -width 16
		button $f.a.r -text "Reorder" -command {set pr_prpre 1} -width 16
		pack $f.a.r -side left -padx 2
		pack $f.a.q -side right
		pack $f.a -side top -fill x -expand true -pady 2
		label $f.b.ll -text "Output property-file name "
		entry $f.b.e -textvariable prpefnam
		pack $f.b.ll $f.b.e -side left
		pack $f.b -side top -pady 2
		wm resizable $f 1 1
		bind $f <Escape> {set pr_prpre 0}
		bind $f <Return> {set pr_prpre 1}
	}
	set pr_prpre 0
	set finished 0
	set prprfnam ""
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_prpre $f
	while {!$finished} {
		tkwait variable pr_prpre
		if {$pr_prpre} {
			if {[string length $prpefnam] <= 0} {
				Inf "No Output Filename Entered"
				continue
			}
			if {![ValidCDPRootname $prpefnam]} {
				continue
			}
			set outfnam [string tolower $prpefnam]
			append outfnam [GetTextfileExtension props]
			if {[string match $pfnam $outfnam]} {
				Inf "You Cannot Overwrite The Input Property File Here"
				continue
			}
			if {[file exists $outfnam]} {
				set msg "FILE '$outfnam' Already Exists: Overwrite It ?"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				set i [LstIndx $outfnam $wl]
				if {![DeleteFileFromSystem $outfnam 0 1]} {
					Inf "Cannot Delete Existing File '$outfnam'"
					continue
				} else {
					DummyHistory $outfnam "DESTROYED"
					if {[info exists propfiles_list]} {
						set k [lsearch $propfiles_list $outfnam]
						if {$k > 0} {
							set propfiles_list [lreplace $propfiles_list $k $k]
						}
					}
					if {$i >= 0} {
						WkspCnt [$wl get $i] -1
						$wl delete $i
						catch {unset rememd}
					}
				}
			}
			if [catch {open $outfnam "w"} zit] {
				Inf "Cannot Create File '$outfnam' To Write Data"
				continue
			}
			foreach line $outprops {
				puts $zit $line
			}
			close $zit
			if {![ThisIsAPropsFile $outfnam 1 0]} {
				if [catch {file delete $outfnam} zit] {
					Inf "Cannot Delete The Invalid 'Properties File' $outfnam"
				}
				continue
			} else {
				if {![info exists propfiles_list]} {
					set is_a_known_propfile -1
				} else {
					set is_a_known_propfile [lsearch $propfiles_list $outfnam]
				}
				if {$is_a_known_propfile < 0} {
					lappend $propfiles_list $outfnam
				}
			}
			FileToWkspace $outfnam 0 0 0 0 1
			Inf "File '$outfnam' Has Been Created"
			break
		} else {
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Avoids playing-snd-from-propsfile interfering with copying an entry at position x down to next position y

proc SetAndSaveProplocn {n} {
	global proplocn last_proplocn
	if {![info exists last_proplocn] && [info exists proplocn]} {
		set last_proplocn $proplocn
	}
	set proplocn $n
}

proc SavePositionInProptable {} {
	global proplastplay evv
	if {![info exists proplastplay]} {
		return
	}
	set fnam [file join $evv(URES_DIR) proppos$evv(CDP_EXT)]
	if [catch {open $fnam "w"} zit]  {
		return
	}
	puts $zit $proplastplay
	close $zit
}

proc LoadPositionInProptable {} {
	global proplastplay evv
	set fnam [file join $evv(URES_DIR) proppos$evv(CDP_EXT)]
	if {![file exists $fnam]} {
		return
	}
	if [catch {open $fnam "r"} zit]  {
		return
	}
	gets $zit proplastplay
	close $zit
	if {![file exists $proplastplay]} {
		unset proplastplay
	} 
}

proc GoodHFSyntax {str} {
	set len [string length $str]
	if {$len <= 0} {
		return 0
	}
	set note_essential 1
	set k 0
	while {$k < $len} {
		set char [string index $str $k]
		if {$note_essential} {
			if {![regexp {[A-Ga-g]} $char]} {
				Inf "HF Property : Bad Syntax (A-G,a-g Or \"#\" Signs Only)"
				return 0
			}
			set note_essential 0
		} else {
			if {![regexp {[A-Ga-g#]} $char]} {
				Inf "HF Property : Bad Syntax (A-G,a-g Or \"#\" Signs Only)"
				return 0
			}
			if {[string match "#" $char]} {
				set note_essential 1
			}
		}
		incr k
	}
	return 1
}

#---- Tease out propvals from commas, brackets and stars

proc SeparatePropvals {val} {
	set nuvals {}
	set vals [split $val ","]
	foreach val $vals {
		set len [string length $val]
		set k 0
		set gotval 0
		set nuval ""
		while {$k < $len} {
			set char [string index $val $k]
			if [regexp {[\*\?]} $char] {
				incr k
				continue
			} elseif [regexp {[\(\)]} $char] {
				if {$gotval} {
					lappend nuvals $nuval
					set gotval 0
				}
				set nuval ""
			} else {
				set gotval 1
				append nuval $char
			}
			incr k
		}
		if {$gotval} {
			lappend nuvals $nuval
		}
	}
	return $nuvals
}

#------- Problem with keyboard switching "#" to "\"

proc BackSlashHashProblem {val} {
	global nuaddpval
	set len [string length $val]
	if {$len <= 0} {
		return $val
	}
	set k 0
	set nustr ""
	while {$k < $len} {
		set char [string index $val $k]
		if {[regexp {\\} $char]} {
			append nustr "#"
		} else {
			append nustr $char
		}
		incr k
	}
	if {![string match $val $nustr]} {
		set val $nustr
		set nuaddpval $nustr
	}
	return $val
}

#----- If this prop exists in other files, see its values

proc SeePropvalsElsewhere {nam inpfnam} {
	global propfiles_list pr_pelse known_propvals evv
	set poscnt 0
	set getfiles 1
	if {[info exists known_propvals]} {
		set getfiles 0
		set len [llength $known_propvals]
		set kprop 0
		foreach known_props $known_propvals {
			if {[string match [lindex $known_props 0] $nam] && [string match [lindex $known_props 1] $inpfnam]} {
				set these_known_props $known_props
				break
			}
			incr kprop
		}
		if {![info exists these_known_props]} {
			set getfiles 1
		}
	}
	if {$getfiles} {
		foreach fnam $propfiles_list {
			if {[file exists $fnam] && ![string match $inpfnam $fnam]} {
				lappend posfiles $fnam
				incr poscnt
			}
		}
		if {!$poscnt} {
			Inf "No Other Propfiles Known"
			return
		}
	}
	set f .pelse
	if [Dlg_Create $f "SEE PROPERTY VALUES ELSEWHERE" "set pr_pelse 0" -borderwidth $evv(BBDR)] {
		frame $f.a -borderwidth $evv(BBDR)
		frame $f.b -borderwidth $evv(BBDR)
		button $f.a.q -text "Quit" -command {set pr_pelse 0} -width 6 -highlightbackground [option get . background {}]
		button $f.a.r -text "Remove Selected File from List" -command {set pr_pelse 2} -width 30 -highlightbackground [option get . background {}]
		button $f.a.l -text "Look In All Listed File" -command {set pr_pelse 1} -width 30 -highlightbackground [option get . background {}]
		button $f.a.z -text "Search Again" -command {set pr_pelse 3} -width 10 -highlightbackground [option get . background {}]
		pack $f.a.l $f.a.z -side left -padx 2
		pack $f.a.q $f.a.r -side right -padx 2
		pack $f.a -side top -fill x -expand true -pady 2
		label $f.b.ll -text "Known Property Files"
		Scrolled_Listbox $f.b.e -width 120 -height 64 -selectmode single
		pack $f.b.ll $f.b.e -side top
		pack $f.b -side top -pady 2
		wm resizable $f 1 1
		bind $f <Escape> {set pr_pelse 0}
	}
	$f.b.e.list delete 0 end

	if {[info exists these_known_props]} {
		foreach val [lrange $these_known_props 2 end] {
			$f.b.e.list insert end $val
		}
		$f.b.ll config -text "Known Property Values for '$nam'"
		$f.a.r config -text "" -command {} -bd 0
		$f.a.l config -text "" -command {} -bd 0
		$f.a.z config -text "Search Again" -command {set pr_pelse 3} -bd 2
	} else {
		foreach fnam $posfiles {
			$f.b.e.list insert end $fnam
		}
		$f.b.ll config -text "Known Property Files"
		$f.a.r config -text "Remove Selected File from List" -command {set pr_pelse 2} -bd 2
		$f.a.l config -text "Look In All Listed File" -command {set pr_pelse 1} -bd 2
		$f.a.z config -text "" -command {} -bd 0
	}
	set pr_pelse 0
	set finished 0
	set prprfnam ""
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_pelse $f
	while {!$finished} {
		tkwait variable pr_pelse
		switch -- $pr_pelse {
			3 {
				set known_propvals [lreplace $known_propvals $kprop $kprop]
				if {[llength $known_propvals] <= 0} {
					unset known_propvals
				}
				Inf "Close This Window And Reopen It"
				break
			}
			2 {
				set i [$f.b.e.list curselection]
				if {![info exists i] || ($i < 0)} {
					Inf "No File Selected"
					continue
				}
				$f.b.e.list delete $i
				incr poscnt -1
				if {$poscnt == 0} {
					Inf "No Files Left"
					break
				}
			}
			1 {
				.pelse.a.r config -state disabled
				.pelse.a.l config -state disabled
				set propvals {}
				foreach fnam [$f.b.e.list get 0 end] {
					set thesevals [GetPropValsFromElsewhere $nam $fnam]
					if {[llength $thesevals] > 0} {
						foreach val $thesevals {
							if {[lsearch $propvals $val] < 0} {
								lappend propvals $val
							}
						}
					}
				}
				set k [lsearch $propvals $evv(NULL_PROP)]
				if {$k >= 0} {
					set propvals [lreplace $propvals $k $k]
				}
				if {[llength $propvals] <= 0} {
					Inf "Values For Property \"$nam\" Not Found In Other Files"
					break
				}
				set propvals [lsort -dictionary $propvals]
				$f.b.e.list delete 0 end
				foreach val $propvals {
					$f.b.e.list insert end $val
				}
				set these_known_props [concat $nam $inpfnam $propvals]
				if {[info exists known_propvals]} {
					set len [llength $known_propvals]
					set k 0
					foreach known_props $known_propvals {
						if {[string match [lindex $known_props 0] $nam] && [string match [lindex $known_props 1] $inpfnam]} {
							set known_propvals [lreplace $known_propvals $k $k $these_known_props]
							break
						}
						incr k
					}
					if {$k == $len}  {
						lappend known_propvals $these_known_props
					}
				} else {	
					lappend known_propvals $these_known_props
				}
			}
			0 {
				break
			}
		}
	}
	.pelse.a.r config -state normal
	.pelse.a.l config -state normal
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Find all values of a named property in a named property-file

proc GetPropValsFromElsewhere {nam fnam} {
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File '$fnam' To Read Properties"
		return {}
	}
	set linecnt 0
	set propvals {}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		set line [split $line]
		if {$linecnt == 0} {
			set propcnt 1
			set got 0
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] < 0} {
					continue
				}
				if {[string match -nocase $item $nam]} {
					set got 1
					break
				}
				incr propcnt
			}
			if {!$got} {
				close $zit
				return {}	;#	PROPERTY NOT IN THIS FILE
			}
		} else {
			set itemcnt 0
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] < 0} {
					continue
				}
				if {$itemcnt == $propcnt} {
					if {[string match -nocase $nam "text"]} {
						set thesevals $item
					} else {
						set thesevals [SeparatePropvals $item]
					}
					foreach val $thesevals {
						if {[lsearch $propvals $val] < 0} {
							lappend propvals $val
						}
					}
					break
				}
				incr itemcnt
			}
		}
		incr linecnt
	}
	close $zit
	return $propvals
}

proc PitchlineTips {} {
	set msg "\"PLAY BOTH\" BUTTON PLAYING THE WRONG PITCH LINE ??\n"
	append msg "\n"	
	append msg "Occasionally, when a pitchline is revised, and played AGAIN\n"
	append msg "through the \"Play Both\" button,\n"
	append msg "the unrevised pitchline is still heard in the mix.\n"
	append msg "\n"	
	append msg "However, on Saving the Data, the revised pitchline will be retained.\n"	
	append msg "\n"	
	append msg "You can check by returning to this page to re-audition the pitchline\n"	
	append msg "with the \"Play Both\" button.\n"	
	Inf $msg
}

proc ClearTimesForPropTableMotifEntry {} {
	global zz_lastprg symasamps snack_list sn pprg
	catch {unset snack_list}
	catch {unset sn(snack_list)}
	catch {unset symasamps(0)}
	if {[info exists pprg]} {
		set zz_lastprg $pprg
	}
	set pprg -1
}

proc DoPropsFlash {n} {
	global tp_props_cnt tp_bfw evv
	set m 1
	while {$m < $tp_props_cnt} {
		$tp_bfw.$n.$m config -bg $evv(EMPH)
		incr m
	}
	set x 0
	after 1500 {set x 1}
	vwait x
	set m 1
	while {$m < $tp_props_cnt} {
		$tp_bfw.$n.$m config -bg [option get . background {}]
		incr m
	}
}

#---- Remeber sound just played, in properties table

proc PropTabRemem {} {
	global proptabremem proplastplay
	if {[info exists proplastplay]} {
		lappend proptabremem $proplastplay
		Inf "Remembered '[file rootname [file tail $proplastplay]]'"
	} else {
		Inf "No Sound Played Yet"
	}
}

#---- Store a list of sounds, remembered in properties table, to a textfile (or clear an existing list)

proc PropTabRememStore {} {
	global pr_ptrs ptrs_fnam proptabremem wstk wl rememd evv
	if {![info exists proptabremem] || ([llength $proptabremem] <= 0)} {
		Inf "No Sounds Remembered Yet"
		return
	}
	set f .ptrs
	if [Dlg_Create $f "SAVE REMEMBERED SNDS TO TEXTFILE" "set pr_ptrs 0" -borderwidth $evv(BBDR)] {
		frame $f.a -borderwidth $evv(BBDR)
		frame $f.b -borderwidth $evv(BBDR)
		frame $f.c -borderwidth $evv(BBDR)
		button $f.a.n -text "Quit" -command {set pr_ptrs 0} -width 6 -highlightbackground [option get . background {}]
		button $f.a.c -text "Forget These Sounds" -command {set pr_ptrs 2} -width 20 -highlightbackground [option get . background {}]
		button $f.a.s -text "Store These Sounds" -command {set pr_ptrs 1} -width 20 -bg $evv(EMPH) -highlightbackground [option get . background {}]
		pack $f.a.s -side left
		pack $f.a.c -side left -padx 10
		pack $f.a.n -side right
		pack $f.a -side top -fill x -expand true -pady 2
		label $f.b.ll -text "Text Filename  "
		entry $f.b.e -textvariable ptrs_fnam -width 16
		pack $f.b.ll $f.b.e -side left
		pack $f.b -side top -pady 2
		label $f.c.del -text "Use 'Control-Click' to remove file from list" -fg $evv(SPECIAL)
		Scrolled_Listbox $f.c.ll -width 80 -height 48 -selectmode single
		pack $f.c.del $f.c.ll -side top -pady 2
		pack $f.c -side top
		wm resizable $f 1 1
		bind $f.c.ll.list <Control-ButtonRelease> {TabRememLose %y}
		bind $f <Escape> {set pr_ptrs 0}
	}
	$f.c.ll.list delete 0 end
	foreach fnam $proptabremem {
		$f.c.ll.list insert end $fnam
	}
	set pr_ptrs 0
	set finished 0
	set ptrs_fnam ""
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_ptrs $f.b.e
	while {!$finished} {
		tkwait variable pr_ptrs
		switch -- $pr_ptrs {
			2 {
				set msg "Destroy The Existing List Of Remembered Files ?"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				$f.c.ll.list delete 0 end
				unset proptabremem
			}
			1 {
				set deldupls 0
				if {![info exists proptabremem] || ([llength $proptabremem] <= 0)} {
					Inf "No Sounds To Store"
					continue
				}
				if {[string length $ptrs_fnam] <= 0} {
					Inf "No Output Filename Entered"
					continue
				}
				if {![ValidCdpFilename $ptrs_fnam 1]} {
					continue
				}
				set outfiles $proptabremem
				set outfnam $ptrs_fnam
				append outfnam [GetTextfileExtension sndlist]
				if {[file exists $outfnam]} {
					set msg "File '$outfnam' Exists : Append These Files To The Existing List ?"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						set msg "Remove Duplicated Filenames ?"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "yes"} {
							set nodupls 1
						} else {
							set nodupls 0
						}
						if [catch {open $outfnam "r"} zit] {
							Inf "Cannot Open File '$outfnam' To Read Existing Data"
							continue
						}
						catch {unset lines}
						while {[gets $zit line] >= 0} {
							set line [string trim $line]
							if {[string length $line] > 0} {
								lappend lines $line
							}
						}
						close $zit
						if [info exists lines] {
							if {$nodupls} {
								foreach line $lines {
									set k [lsearch $outfiles $line]
									if {$k >= 0} {
										set outfiles [lreplace $outfiles $k $k]
									}
								}
								if {[llength $outfiles] <= 0} {
									Inf "All These Sounds Are Already Contained In File '$outfnam'"
									continue
								}
							}
							set outfiles [concat $lines $outfiles]
						}
					} else {
						set msg "Overwrite The Existing File '$outfnam' ?"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							continue
						}
					}
					set i [LstIndx $outfnam $wl]
					if {![DeleteFileFromSystem $outfnam 0 1]} {
						Inf "Cannot Delete Existing File '$outfnam'"
						continue
					} else {
						DummyHistory $outfnam "DESTROYED"
						if {$i >= 0} {
							WkspCnt [$wl get $i] -1
							$wl delete $i
							catch {unset rememd}
						}
					}
				}
				if [catch {open $outfnam "w"} zit] {
					Inf "Cannot Open File '$outfnam' To Write Data"
					continue
				}
				foreach ofnam $outfiles {
					puts $zit $ofnam
				}
				close $zit
				FileToWkspace $outfnam 0 0 0 0 1
				Inf "File '$outfnam' Has Been Created"
				set msg "Clear The List Of Remembered Files ?"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "yes"} {
					unset proptabremem
				}
				set finished 1
			}
			0 {
				break
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc TabRememLose {y} {
	global proptabremem pr_ptrs
	set i [.ptrs.c.ll.list nearest $y]
	if {$i < 0} {
		return
	}
	.ptrs.c.ll.list delete $i
	set proptabremem [lreplace $proptabremem $i $i]
	if {[llength $proptabremem] <= 0} {
		set pr_ptrs 0
	}
}

#----- Extract text property to a textfile

proc TextPropExtract {} {
	global wl chlist props_info pr_textrac textracfnam evv
	set i [$wl curselection]
	if {![info exists i] || ([llength $i] != 1) || ($i == -1)} {
		if {![info exists chlist] || ([llength $chlist] != 1)} {
			Inf "No Properties File Selected"
			return
		}
		set fnam [lindex $chlist 0]
	} else {
		set fnam [$wl get $i]
	}
	if {![ThisIsAPropsFile $fnam 1 0]} {
		return
	}
	set theseprops [lindex $props_info 0]
	set len [llength $theseprops]
	incr len
	set n 1
	foreach item $theseprops {
		if {[string match -nocase $item "text"]} {
			break
		}
		incr n
	}
	if {$n >= $len} {
		Inf "No 'Text' Property In This Properties File"
		return
	}
	set propsfile [lindex $props_info 1]
	foreach line $propsfile {
		set snd [file rootname [file tail [lindex $line 0]]]
		set txt [lindex $line $n]
		lappend snds $snd
		lappend txts $txt
	}
	foreach snd $snds txt $txts {
		set line $snd
		append line "\t\t"
		set txt [split $txt "_"]
		foreach item $txt {
			append line $item " "
		}
		lappend outlines $line
	}
	set f .textrac
	if [Dlg_Create $f "EXTRACT TEXT PROPERTY" "set pr_textrac 0" -borderwidth $evv(BBDR)] {
		frame $f.0 -borderwidth $evv(BBDR)
		frame $f.1 -borderwidth $evv(BBDR)
		button $f.0.ok -text "Extract Texts" -command {set pr_textrac 1} -width 10 -highlightbackground [option get . background {}]
		button $f.0.qu -text "Abandon" -command {set pr_textrac 0} -width 10 -highlightbackground [option get . background {}]
		pack $f.0.ok -side left
		pack $f.0.qu -side right
		label $f.1.ll -text "Output Filename "
		entry $f.1.e -textvariable textracfnam -width 36
		pack $f.1.ll $f.1.e -side left -padx 8
		pack $f.0 $f.1 -side top -pady 2 -fill x -expand true		
		bind $f <Escape> {set pr_textrac 0}
		bind $f <Return> {set pr_textrac 1}
	}
	set pr_textrac 0
	set finished 0
	raise $f
	My_Grab 0 $f pr_textrac $f.1.e
	while {!$finished} {
		tkwait variable pr_textrac
		if {$pr_textrac} {
			if {[string length $textracfnam] <= 0} {
				Inf "No Output Filename Entered"
				continue
			}
			if {![ValidCDPRootname $textracfnam]} {
				continue
			}
			set ofnam $textracfnam
			append ofnam $evv(TEXT_EXT)
			if {[file exists $ofnam]} {
				Inf "File 'ofnam' Already Exists: Please Choose Another Name"
				continue
			}
			if [catch {open $ofnam "w"} zit] {
				Inf "Cannot Open File '$ofnam' To Write Data"
				continue
			}
			foreach line $outlines {
				puts $zit $line
			}
			close $zit
			FileToWkspace $ofnam 0 0 0 0 1
			Inf "File '$ofnam' Is On The Workspace"
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#----- Change directory of all files in a (potential) props file

proc PropsDirChange {} {
	global wl chlist evv props_info wstk pr_propnudir prop_nudir propnudirfnam propfiles_list

	set ilist [$wl curselection]
	if {![info exists ilist] || ([llength $ilist] != 1) || ([lindex $ilist 0] == -1)} {
		if {![info exists chlist] || ([llength $chlist] != 1)} {
			Inf "No Property File Selected"
			return
		}
		set fnam [lindex $chlist 0]
	} else {
		set fnam [$wl get [lindex $ilist 0]]
	}
	set ftyp [FindFileType $fnam]
	if {!($ftyp & $evv(IS_A_TEXTFILE))} {
		Inf "Select A Text File."
		return
	}
	Block "Checking File Data"
	if {![ThisIsAPropsFile $fnam 1 1]} {
		UnBlock
		return
	}
	set propvals  [lindex $props_info 0]
	set propslist [lindex $props_info 1]
	foreach line $propslist {
		set fnam [lindex $line 0]
		if {[file exists $fnam]} {
			lappend existing $fnam
		}
		lappend fnams [lindex $line 0]
	}
	if {[info exists existing]} {
		if {[llength $existing] == [llength $fnams]} {
			set msg "All Of The Files In This Property File Already Exist."
		} else {
			set msg "[llength $existing] Of The Files In This Property File Already Exist."
			set msg2 $msg
			append msg2 "\n\nDo You Want To See Which These Are ??"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg2]
			if {$choice == "yes"} {
				set cnt 0
				set msg3 ""
				foreach efnam $existing {
					append msg3 "$efnam\n"
					incr cnt
					if {$cnt >= 20} {
						append msg "And More"
						break
					}
				}
				Inf $msg3
			}
			append msg "\n\nDo You Wish To Continue With The Directory Change ??"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				UnBlock
				return
			}
		}
	}
	foreach fnam $fnams {
		set fnam [file tail $fnam]
		lappend nufnams $fnam
	}
	set fnams $nufnams
	set f .propnudir
	if [Dlg_Create $f "CHANGE DIRECTORY" "set pr_propnudir 0" -borderwidth $evv(BBDR)] {
		frame $f.0 -borderwidth $evv(BBDR)
		frame $f.1 -borderwidth $evv(BBDR)
		frame $f.2 -borderwidth $evv(BBDR)
		button $f.0.ok -text "Change Directory" -command {set pr_propnudir 1} -highlightbackground [option get . background {}]
		button $f.0.qu -text "Abandon" -command {set pr_propnudir 0} -width 10 -highlightbackground [option get . background {}]
		pack $f.0.ok -side left
		pack $f.0.qu -side right
		label $f.1.ll -text "Name of New Directory "
		entry $f.1.e -textvariable prop_nudir -width 32
		button $f.1.dir -text "FIND DIRECTORY" -command "DoListingOfDirectories .propnudir.1.e" -highlightbackground [option get . background {}]
		pack  $f.1.ll $f.1.e $f.1.dir -side left -padx 2
		label $f.2.ll -text "Output Filename "
		entry $f.2.e -textvariable propnudirfnam -width 36
		pack $f.2.ll $f.2.e -side left -padx 8
		pack $f.0 $f.1 $f.2 -side top -pady 2 -fill x -expand true
		wm resizable $f 1 1
		bind $f <Escape> {set pr_propnudir 0}
		bind $f <Return> {set pr_propnudir 1}
	}
	set pr_propnudir 0
	set finished 0
	raise $f
	My_Grab 0 $f pr_propnudir $f.1.e
	while {!$finished} {
		tkwait variable pr_propnudir
		if {$pr_propnudir} {
			set dir_changed 0
			if {![info exists got_dir] || ![string match $prop_nudir $got_dir]} {
				set prop_nudir [string tolower $prop_nudir]
				if {[string length $prop_nudir] <= 0} {
					Inf "No New Directory Name Entered"
					continue
				}
				if {![file exists $prop_nudir] || ![file isdirectory $prop_nudir]} {
					Inf "'$prop_nudir' Is Not An Existing Directory"
					continue
				}
				set OK 1
				set badfilemsg 0
				catch {unset outfnams}
				foreach fnam $fnams {
					set fnam [file join $prop_nudir $fnam]
					if {!$badfilemsg && ![file exists $fnam]} {
						set badfilemsg 1
						set msg "File '$fnam' Does Not Exist : Do You Wish To Continue"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "no"} {
							set OK 0
							break
						}
					}
					lappend outfnams $fnam
				}
				if {!$OK} {
					continue
				}
				set dir_changed 1
			}
			set got_dir $prop_nudir 
			if {[string length $propnudirfnam] <= 0} {
				Inf "No Output Filename Entered"
				continue
			}
			if {![ValidCDPRootname $propnudirfnam]} {
				continue
			}
			set ofnam $propnudirfnam
			append ofnam [GetTextfileExtension props]
			if {[file exists $ofnam]} {
				Inf "File 'ofnam' Already Exists: Please Choose Another Name"
				continue
			}
			if {$dir_changed} {
				set len [llength $outfnams]
				set cnt 0
				while {$cnt < $len} {
					set line [lindex $propslist $cnt]
					set outfnam [lindex $outfnams $cnt]
					set line [lreplace $line 0 0 $outfnam]
					set propslist [lreplace $propslist $cnt $cnt $line]
					incr cnt
				}
			}
			if [catch {open $ofnam "w"} zit] {
				Inf "Cannot Open File '$ofnam' To Write Data"
				continue
			}
			puts $zit $propvals
			foreach line $propslist {
				puts $zit $line
			}
			close $zit
			FileToWkspace $ofnam 0 0 0 0 1
			if {![info exists propfiles_list]} {
				lappend propfiles_list $ofnam
			} elseif {[lsearch $propfiles_list $ofnam] < 0} {
				lappend propfiles_list $ofnam
			}
			Inf "File '$ofnam' Is On The Workspace"
			set finished 1
		} else {
			set finished 1
		}
	}
	UnBlock
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Display statistics of property (in one or more properties files)

proc PropsStats {} {
	global propstatname pr_propstats propstatsfnam propstatorder props_info ditchbrackets proporderednames
	global propsubmin propsubmax propfrqmin readonlybg readonlyfg psval psvalfnams wl chlist wstk evv
	global lastpropstatname lastpropstatorder laststatpropvals laststatpropfnams

	catch {unset lastpropstatname}
	catch {unset lastpropstatorder}
	catch {unset laststatpropvals}
	catch {unset laststatpropfnams}

	set ilist [$wl curselection]
	if {![info exists ilist] || ([llength $ilist] <= 0)} {
		if {[info exists chlist]} {
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
	if {![info exists ilist] || ([llength $ilist] <= 0)} {
		Inf "No Workspace Files Selected"
		return
	}
	set prop_names {}
	Block "Checking Property Files"
	foreach i $ilist { 
		set fnam [$wl get $i]
		wm title .blocker "PLEASE WAIT :        CHECKING PROPERTY FILE [file rootname [file tail $fnam]]"
		if {[ThisIsAPropsFile $fnam 0 0]} {
			lappend fnams $fnam
			foreach prnam [lindex $props_info 0] {
				if {[lsearch $prop_names $prnam] < 0} {
					lappend prop_names $prnam
				}
			}

		} else {
			lappend badfiles $fnam
		}
	}

	UnBlock
	if {![info exists fnams]} {
		Inf "No Properties Files Selected"
		return
	}
	if {[info exists badfiles]} {
		set msg "Some Of The Selected Files Are Not Properties Files\n\n"
		append msg "Ignore These And Continue ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		}
		unset badfiles
	}
	set f .propstats
	if [Dlg_Create $f "GET PROPERTY STATISTICS" "set pr_propstats 0" -borderwidth $evv(BBDR)] {
		frame $f.0 -borderwidth $evv(BBDR)
		frame $f.1 -borderwidth $evv(BBDR)
		frame $f.2 -borderwidth $evv(BBDR)
		frame $f.2a -borderwidth $evv(BBDR)
		frame $f.2b -borderwidth $evv(BBDR)
		frame $f.3 -borderwidth $evv(BBDR)
		frame $f.4 -borderwidth $evv(BBDR)
		frame $f.5 -borderwidth $evv(BBDR)
		button $f.0.help -text "Help" -command {HelpStats} -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.0.ok -text "Get Stats" -command {set pr_propstats 1} -width 12 -highlightbackground [option get . background {}]
		button $f.0.save -text "Save Stats" -command {set pr_propstats 2} -width 12 -highlightbackground [option get . background {}]
		button $f.0.ssnd -text "Save Sndlists" -command {set pr_propstats 5} -width 12 -highlightbackground [option get . background {}]
		button $f.0.stt -text "Restart" -command {set pr_propstats 3} -width 12 -highlightbackground [option get . background {}]
		button $f.0.sub -text "Subgroups" -command {set pr_propstats 4} -width 12 -highlightbackground [option get . background {}]
		button $f.0.qu -text "Quit" -command {set pr_propstats 0} -highlightbackground [option get . background {}]
		pack $f.0.help $f.0.ok $f.0.sub $f.0.save $f.0.stt $f.0.ssnd -side left -padx 2
		pack $f.0.qu -side right
		label $f.1.ll -text "Name of Property "
		entry $f.1.e -textvariable propstatname -width 32
		pack  $f.1.ll $f.1.e -side left -padx 2
		label $f.2.ll -text "ORDER THE DATA DISPLAY "
		radiobutton $f.2.alpha -text "Alphabetically" -variable propstatorder -value "alpha"
		radiobutton $f.2.num   -text "Numerically" -variable propstatorder -value "numeric"
		radiobutton $f.2.frq -text "By frequency" -variable propstatorder -value "frq"
		pack $f.2.ll $f.2.alpha $f.2.num $f.2.frq -side left
		label $f.2a.igg -text " min frq of occurence to list"
		entry $f.2a.ig -textvariable propfrqmin -width 3 -state readonly -readonlybackground $readonlybg -fg $readonlyfg
		label $f.2a.mii -text "subgroup length min "
		entry $f.2a.min -textvariable propsubmin -width 3 -state readonly -readonlybackground $readonlybg -fg $readonlyfg
		label $f.2a.maa -text " max "
		entry $f.2a.max -textvariable propsubmax -width 3 -state readonly -readonlybackground $readonlybg -fg $readonlyfg
		pack $f.2a.ig $f.2a.igg -side left
		pack $f.2a.max $f.2a.maa $f.2a.min $f.2a.mii -side right
		frame $f.2b.xx
		label $f.2b.xx.1 -text "Up/Down Arrows change Frq Value" -fg $evv(SPECIAL)
		pack $f.2b.xx.1 -side top -anchor w
		pack $f.2b.xx -side left
		frame $f.2b.ll
		label $f.2b.ll.1 -text "Left/Right Arrows change subgroup MAX" -fg $evv(SPECIAL)
		label $f.2b.ll.2 -text "Control Left/Right change subgroup MIN" -fg $evv(SPECIAL)
		pack $f.2b.ll.1 $f.2b.ll.2 -side top -anchor e
		pack $f.2b.ll -side right
		label $f.3.ll -text "Output Filename " -width 16
		entry $f.3.e -textvariable propstatsfnam -width 36
		pack $f.3.ll $f.3.e -side left -padx 8
		checkbutton $f.4.ch -text "Ignore bracketed values" -variable ditchbrackets
		pack $f.4.ch -side top
		Scrolled_Listbox $f.5.ll -width 120 -height 36 -selectmode single
		pack $f.5.ll -side top
		pack $f.0 $f.1 $f.2 $f.2a $f.2b $f.3 $f.4 $f.5 -side top -pady 2 -fill x -expand true
		wm resizable $f 1 1
		bind $f <Escape> {set pr_propstats 0}
	}
	set propfrqmin 1
	.propstats.2a.mii config -text ""
	set propsubmin ""
	.propstats.2a.min config -width 3 -readonlybackground [option get . background {}] -bd 0
	.propstats.2a.maa config -text ""
	set propsubmax ""
	.propstats.2a.max config -width 3 -readonlybackground [option get . background {}] -bd 0
	.propstats.2b.ll.1 config -text ""
	.propstats.2b.ll.2 config -text ""
	bind .propstats <Up>    {IncrPropFrq 0}
	bind .propstats <Down>  {IncrPropFrq 1}
	bind .propstats <Left>		    {}
	bind .propstats <Right>			{}
	bind .propstats <Control-Left>  {}
	bind .propstats <Control-Right> {}

	.propstats.0.stt config  -text "" -bd 0 -command {}
	.propstats.0.sub config  -text "" -bd 0 -command {}
	.propstats.0.ssnd config  -text "" -bd 0 -command {}
	set ditchbrackets 0
	$f.5.ll.list delete 0 end
	set prop_names [lsort $prop_names]
	foreach prnam $prop_names {
		$f.5.ll.list insert end $prnam
	}
	bind $f.5.ll.list <ButtonRelease-1> {SetStatPropName %y}

	.propstats.0.save config -text "" -bd 0 -command {}
	.propstats.3.ll config -text ""
	.propstats.3.e config -state disabled -disabledbackground [option get . background {}] -bd 0
	set propstatorder 0
	raise $f
	update idletasks
	StandardPosition $f
	set pr_propstats 0 
	set finished 0
	My_Grab 0 $f pr_propstats $f.1.e
	while {!$finished} {
		tkwait variable pr_propstats
		switch -- $pr_propstats {
			bind $f.5.ll.list <ButtonRelease-1> {}
			1 {
				if {$propstatorder == 0} {
					Inf "No Ordering Specified"
					continue
				}
				if {![DoStatsOnProp $fnams]} {
					continue
				}
				Block "Extracting Property Values"
				catch {unset names}
				foreach name [array names psval] {
					lappend names $name
				}
				if {$propfrqmin > 1} {
					catch {unset badnames}
					set orignames $names
					set len [llength $names]
					set n 0
					while {$n < $len} {
						set name [lindex $names $n]
						if {$psval($name) < $propfrqmin} {
							lappend badnames $name
							set names [lreplace $names $n $n]
							incr len -1
						} else {
							incr n
						}
					}
					if {[llength $names] <= 0} {
						set msg "All Items Occur Less Than $propfrqmin Times : Display Them ??"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "yes"} {
							set names $orignames
						} else {
							UnBlock
							continue
						}
					} elseif {[info exists badnames]} {
						foreach name $badnames {
							unset psval($name)
							unset psvalfnams($name)
						}
					}
				}
				set len [llength $names]
				set len_less_one [expr $len - 1]
				set n 0
				while {$n < $len_less_one} {
					set name_n [lindex $names $n]
					set m $n
					incr m
					while {$m < $len} {
						set name_m [lindex $names $m]
						switch -- $propstatorder {
							"frq" {
								if {$psval($name_m) > $psval($name_n)} {
									set names [lreplace $names $n $n $name_m]
									set names [lreplace $names $m $m $name_n]
									set name_n $name_m
								}
							}
							"numeric" {
								if {$name_m > $name_n} {
									set names [lreplace $names $n $n $name_m]
									set names [lreplace $names $m $m $name_n]
									set name_n $name_m
								}
							}
							"alpha" {
								if {[string compare $name_m $name_n] < 0} {
									set names [lreplace $names $n $n $name_m]
									set names [lreplace $names $m $m $name_n]
									set name_n $name_m
								}
							}
						}
						incr m
					}
					incr n
				}
				$f.5.ll.list delete 0 end
				set proporderednames $names
				foreach name $names {
					set line $name
					append line "   " $psval($name)
					$f.5.ll.list insert end $line
				}
				.propstats.0.save config -text "Save Stats" -bd 2 -command "set pr_propstats 2"
				.propstats.3.ll config -text "Output Filename "
				.propstats.3.e config -bd 2 -state normal
				.propstats.0.stt config -text "Restart" -command {set pr_propstats 3} -bd 2
				if {[string match $propstatname "HF"] || [string match $propstatname "text"]} {
					.propstats.0.ssnd config -text "Save Sndlists" -command {set pr_propstats 5} -bd 2
				}
				UnBlock
			}
			2 {
				if {[string length $propstatsfnam] <= 0} {
					Inf "No Filename Entered"
					continue
				}
				if {![ValidCDPRootname $propstatsfnam]} {
					continue
				}
				set ofnam $propstatsfnam
				append ofnam $evv(TEXT_EXT)
				if {[file exists $ofnam]} {
					Inf "File 'ofnam' Already Exists: Please Choose Another Name"
					continue
				}
				if [catch {open $ofnam "w"} zit] {
					Inf "Cannot Open File '$ofnam'"
					continue
				}
				foreach line [$f.5.ll.list get 0 end] {
					puts $zit $line
				}
				close $zit
				FileToWkspace $ofnam 0 0 0 0 1
				Inf "File '$ofnam' Is On The Workspace"
			}
			3 {
				set ditchbrackets 0
				$f.5.ll.list delete 0 end
				set prop_names [lsort $prop_names]
				foreach prnam $prop_names {
					$f.5.ll.list insert end $prnam
				}

				bind $f.5.ll.list <ButtonRelease-1> {SetStatPropName %y}
				.propstats.0.stt config  -text "" -bd 0 -command {}
				.propstats.0.sub config  -text "" -bd 0 -command {}
				.propstats.0.ssnd config -text "" -bd 0 -command {}
				.propstats.2a.mii config -text ""
				set propsubmin ""
				.propstats.2a.min config -width 3 -readonlybackground [option get . background {}] -bd 0
				.propstats.2a.maa config -text ""
				set propsubmax ""
				.propstats.2a.max config -width 3 -readonlybackground [option get . background {}] -bd 0
				.propstats.2b.ll.1 config -text ""
				.propstats.2b.ll.2 config -text ""
				bind .propstats <Left>		    {}
				bind .propstats <Right>		    {}
				bind .propstats <Control-Left>  {}
				bind .propstats <Control-Right> {}
				.propstats.0.save config -text "" -bd 0 -command {}
				.propstats.3.ll config -text ""
				.propstats.3.e config -state disabled -disabledbackground [option get . background {}] -bd 0
				set propstatorder 0
				set propstatname ""
				set propfrqmin 1
				catch {unset statpropvals}
			}
			4 {
				if {$propstatorder == 0} {
					Inf "No Ordering Specified"
					continue
				}
				if {[string match $propstatorder "mumeric"]} {
					Inf "This Process Does Not Work With Numeric Sorts"	
					continue
				}
				if {![DoStatsOnProp $fnams]} {
					continue
				}
				Block "Extracting Property Values"
				catch {unset pssubval}
				catch {unset pssubvalfnams}
				catch {unset names}
				foreach name [array names psval] {
					lappend names $name
				}
				switch -- $propstatname {
					"HF" {
						set maxlen 0
						foreach name $names {
							set len [string length $name]
							set outlen 1
							set n 1 
							while {$n < $len} {
								set item [string index $name $n]
								if {![string match $item "#"]} {
									incr outlen 1
								}
								incr n
							}
							if {$outlen > $maxlen} {
								set maxlen $outlen
							}
						}
					}
					"text" {
						set maxlen 0
						foreach name $names {
							set name [split $name "_"]
							set len [llength $name]
							if {$len > $maxlen} {
								set maxlen $len
							}
						}
					}
				}
				set k $propsubmin
				if {$maxlen < $k} {
					Inf "No Subgroups Found"
					UnBlock
					continue
				}
				if {$propsubmax < $maxlen} {
					set maxlen $propsubmax
				}
				while {$k <= $maxlen} {
					switch -- $propstatname {
						"HF" {
							foreach name $names {
								set len [string length $name]
								set j 0
								while {$j < $len} {							;#	Search the name-string
									set nuval [string index $name $j]		;#	Start a new substring within 'name'
									set outlen 1							;#	Count signif items in sub-string (e.g. C, or C# etc.)
									if {$k == 1} {
										set nextj [expr $j + 1]
										if {($nextj < $len) && [string match [string index $name $nextj] "#"]} {
											append nuval "#"
											incr nextj
										}
									} else {
										set n [expr $j + 1] 
										while {$n < $len} {
											set item [string index $name $n]
											append nuval $item					;#	Assemble more of substring
											if {![string match $item "#"]} {	;#	Count signif items in sub-string (e.g. C, or C# etc.)
												incr outlen
												if {$outlen == 2} {				;#	Once a 2nd signif char found, mark this as start of next substring search
													set nextj $n
												}
												if {$outlen >= $k} {			;#	Once substring is of desired length (k)
													set nn [expr $n + 1]		;#	Check for a following '#' sign
													if {$nn < $len} {			;#	and if there is one, appen it to 'nuval'
														set item [string index $name $nn]
														if {[string match $item "#"]} {
															append nuval $item
														}						;#	then break
													}
													break
												}
											}
											incr n
										}
										if {$outlen < $k} {						;#	If insuffcient chars in string to assemble substring of length k
											break								;#	go on to next name
										}
									}
									if {![info exists pssubval($nuval)]} {	;#	Do stats on subgroups
										set pssubval($nuval) $psval($name)
										set pssubvalfnams($nuval) $psvalfnams($name)
									} else {
										incr pssubval($nuval) $psval($name)
										foreach f_nam $psvalfnams($name) {
											if {[lsearch pssubvalfnams($nuval) $f_nam] < 0} {
												lappend pssubvalfnams($nuval) $f_nam
											}
										}
									}
									set j $nextj							;#	Move to next substring-search start-position in 'name'
								}
							}	
						}
						"text" {
							foreach name $names {
								set nuname [string tolower $name]
								set nuname [split $name "_"]
								set len [llength $nuname]
								set j 0
								while {$j <= [expr $len - $k]} {			;#	Step thro the phrase, one word at a time
									set n [expr $j + $k - 1]				;#	Forming subphrases of length k
									set nuval [lrange $nuname $j $n]
									if {![info exists pssubval($nuval)]} {	;#	Do stats on subphrases
										set pssubval($nuval) $psval($name)
										set pssubvalfnams($nuval) $psvalfnams($name)
									} else {
										incr pssubval($nuval) $psval($name)
										foreach f_nam $psvalfnams($name) {
											if {[lsearch pssubvalfnams($nuval) $f_nam] < 0} {
												lappend pssubvalfnams($nuval) $f_nam
											}
										}
									}
									incr j									;#	Move to next word in 'text' to start next subphrase
								}
							}	
						}
					}
					incr k
				}
				set names [array names pssubval]
				set len [llength $names]
				if {$propfrqmin > 1} {
					catch {unset badnames}
					set orignames $names
					set len [llength $names]
					set n 0
					while {$n < $len} {
						set name [lindex $names $n]
						if {$pssubval($name) < $propfrqmin} {
							lappend badnames $name
							set names [lreplace $names $n $n]
							incr len -1
						} else {
							incr n
						}
					}
					if {[llength $names] <= 0} {
						set msg "All Items Occur Less Than $propfrqmin Times: Display Them ??"
						set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
						if {$choice == "yes"} {
							set names $orignames
						} else {
							UnBlock
							continue
						}
					} elseif {[info exists badnames]} {
						foreach name $badnames {
							unset pssubval($name)
							unset pssubvalfnams($name)
						}
					}
				}
				set len_less_one [expr $len - 1]
				set n 0
				while {$n < $len_less_one} {
					if {[expr $n % 100] == 0} {
						wm title .blocker "PLEASE WAIT:          SORTING FROM ITEM $n OF $len ITEMS"
					}
					set name_n [lindex $names $n]
					set m $n
					incr m
					while {$m < $len} {
						set name_m [lindex $names $m]
						switch -- $propstatorder {
							"frq" {
								if {$pssubval($name_m) > $pssubval($name_n)} {
									set names [lreplace $names $n $n $name_m]
									set names [lreplace $names $m $m $name_n]
									set name_n $name_m
								}
							}
							"numeric" {			;#	CURRENTLY REDUNDANT: included in case function later expanded to act on props with numeric vals
								if {$name_m > $name_n} {
									set names [lreplace $names $n $n $name_m]
									set names [lreplace $names $m $m $name_n]
									set name_n $name_m
								}
							}
							"alpha" {
								if {[string compare $name_m $name_n] < 0} {
									set names [lreplace $names $n $n $name_m]
									set names [lreplace $names $m $m $name_n]
									set name_n $name_m
								}
							}
						}
						incr m
					}
					incr n
				}
				$f.5.ll.list delete 0 end
				catch {unset psval}
				catch {unset psvalfnams}
				set proporderednames $names
				foreach name $names {
					set psval($name) $pssubval($name)
					set psvalfnams($name) $pssubvalfnams($name)
					set line $name
					append line "   " $pssubval($name)
					$f.5.ll.list insert end $line
				}
				.propstats.0.save config -text "Save Stats" -bd 2 -command "set pr_propstats 2"
				.propstats.3.ll config -text "Output Filename "
				.propstats.3.e config -bd 2 -state normal
				UnBlock
				.propstats.0.stt config -text "Restart" -command {set pr_propstats 3} -bd 2
				if {[string match $propstatname "HF"] || [string match $propstatname "text"]} {
					.propstats.0.ssnd config -text "Save Sndlists" -command {set pr_propstats 5} -bd 2
				}
			}
			5 {
				if {![info exists proporderednames] || ![info exists psvalfnams]} {
					Inf "No Soundfile Data To Save"
					continue
				}
				set dirnam ""
				set propstatsfnam [string trim $propstatsfnam]
				if {[string length $propstatsfnam] > 0} {
					set msg "Save Files In Directory $propstatsfnam ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						if {![ValidCDPRootname $propstatsfnam]} {
							continue
						}
						set dirnam $propstatsfnam
						if {[file exists $dirnam] && ![file isdirectory $dirnam]} {
							Inf "This Is The Name Of An Existing File (Not A Directory): Choose A Different Directory Name"
							continue
						} elseif {![file exists $dirnam]} {
							if [catch {file mkdir $dirnam} zit] {
								Inf "Cannot Create Directory '$dirnam': Choose A Different Directory Name"
								continue
							}
						}
					}
				}
				Block "Saving Sounds in Statistics Files"
				set OK 1
				switch -- $lastpropstatname {
					"HF" {
						set matchstr "#"
						set newstr   "sh"
					}
					"text" {
						set matchstr " "
						set newstr "_"
					}
				}
				foreach nam $proporderednames {
					set outnam ""
					set len [string length $nam]
					set n 0
					while {$n < $len} {
						set kar [string index $nam $n]
						if {[string match $kar $matchstr]} {
							append outnam $newstr
						} else {	
							append outnam $kar
						}
						incr n
					}
					append outnam "_" $psval($nam)
					append outnam [GetTextfileExtension sndlist]
					if {[string length $dirnam] > 0} {
						set outnam [file join $dirnam $outnam]
					}
					if {[file exists $outnam]} {
						Inf "One Of The Output Filenames ($outnam) Already Exists\n\nEnter A (Different) Target Directory Name In The \"Output Filename\" Box"
						set OK 0
						break
					}
					lappend outnames $outnam
				}
				if {$OK} {
					foreach nam $proporderednames outnam $outnames {
						wm title .blocker "PLEASE WAIT :        SAVING SOUNDS IN STATS FILE [file rootname [file tail $outnam]]"
						if [catch {open $outnam "w"} zit] {
							set msg "Cannot Open File '$outnam' To Write Sound List: Abandon Saving Stats Soundlists ??"
							set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
							if {$choice == "yes"} {
								break
							}
						}
						foreach f_nam $psvalfnams($nam) {
							puts $zit $f_nam
						}
						close $zit
					}
					set outnames [ReverseList $outnames]
					foreach outnam $outnames {
						wm title .blocker "PLEASE WAIT :        PUTTING STATS FILE [file rootname [file tail $outnam]] ON WORKSPACE"
						FileToWkspace $outnam 0 0 0 0 1
					}
					unset psvalfnams
					unset proporderednames
					.propstats.0.ssnd config -text "" -command {} -bd 0
					Inf "The Statistics Files Are On The Workspace"
				}
				UnBlock
			}
			0 {
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#------ Select property name from listing of propnames, with mouse

proc SetStatPropName {y} {
	global propstatname propsubmin propsubmax readonlybg
	set i [.propstats.5.ll.list nearest $y]
	set propstatname [.propstats.5.ll.list get $i]
	if {[string match $propstatname "HF"] || [string match $propstatname "text"]} {
		.propstats.0.sub config  -text "Subgroups" -command {set pr_propstats 4} -bd 2
		.propstats.2a.mii config -text "subgroup length min "
		.propstats.2a.min config -readonlybackground $readonlybg -state readonly -bd 2
		set propsubmin 1
		.propstats.2a.maa config -text " max "
		set propsubmax 2
		.propstats.2a.max config -readonlybackground $readonlybg -state readonly -bd 2
		.propstats.2b.ll.1 config -text "Left/Right Arrows change subgroup MAX"
		.propstats.2b.ll.2 config -text "Control Left/Right change subgroup MIN"
		bind .propstats <Left>			{IncrPropSub 1 1}
		bind .propstats <Right>			{IncrPropSub 0 1}
		bind .propstats <Control-Left>  {IncrPropSub 1 0}
		bind .propstats <Control-Right> {IncrPropSub 0 0}
	} else {
		.propstats.0.sub config  -text "" -bd 0 -command {}
		.propstats.2a.mii config -text ""
		set propsubmin ""
		.propstats.2a.min config -width 3 -readonlybackground [option get . background {}] -bd 0
		.propstats.2a.maa config -text ""
		set propsubmax ""
		.propstats.2a.max config -width 3 -readonlybackground [option get . background {}] -bd 0
		.propstats.2b.ll.1 config -text ""
		.propstats.2b.ll.2 config -text ""
		bind .propstats <Left>		    {}
		bind .propstats <Right>			{}
		bind .propstats <Control-Left>  {}
		bind .propstats <Control-Right> {}
	}
}

#------ Remove brackets from a property-value

proc RemoveBrackets {val} {
	set len [string length $val]
	set outval ""
	set n 0
	while {$n < $len} {
		set char [string index $val $n]
		if {[string match $char ")"] || [string match $char "("]} {
			incr n
			continue
		}
		append outval $char
		incr n
	}
	return $outval
}

#----- Gather property lines of files with specific property values, to a new property file, from several propfiles

proc PropsGather {} {
	global pr_propgath propgathname propgathvals propgathfnam props_info wl chlist wstk evv
	set ilist [$wl curselection]
	if {![info exists ilist] || ([llength $ilist] <= 0)} {
		if {[info exists chlist]} {
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
	if {![info exists ilist] || ([llength $ilist] <= 0)} {
		Inf "No Workspace Files Selected"
		return
	}
	Block "Checking Property Files"
	foreach i $ilist { 
		set fnam [$wl get $i]
		wm title .blocker "PLEASE WAIT :         CHECKING PROPERTY FILE [file rootname [file tail $fnam]]"
		if {[ThisIsAPropsFile $fnam 0 0]} {
			lappend fnams $fnam
			if {![info exists prop_names]} {
				set prop_names [lindex $props_info 0]
			} else {			
				set nu_prop_names [lindex $props_info 0]
				if {[llength $prop_names] != [llength $nu_prop_names]} {
					Inf "Properties In Files '$fnam' And '[lindex $fnams 0]' Do Not Tally"
					return
				}
				foreach p1 $prop_names p2 $nu_prop_names {
					if {![string match $p1 $p2]} {
						Inf "Properties In Files '$fnam' And '[lindex $fnams 0]' Do Not Tally"
						return
					}
				}
			}
		} else {
			lappend badfiles $fnam
		}
	}
	UnBlock
	if {![info exists fnams]} {
		Inf "No Properties Files Selected"
		return
	}
	if {[info exists badfiles]} {
		set msg "Some Of The Selected Files Are Not Properties Files\n\n"
		append msg "Ignore These And Continue ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		}
		unset badfiles
	}
	set f .propgath
	if [Dlg_Create $f "GATHER FILES WITH GIVEN PROP VALUE(S)" "set pr_propgath 0" -borderwidth $evv(BBDR)] {
		frame $f.0 -borderwidth $evv(BBDR)
		frame $f.1 -borderwidth $evv(BBDR)
		frame $f.2 -borderwidth $evv(BBDR)
		frame $f.3 -borderwidth $evv(BBDR)
		frame $f.4 -borderwidth $evv(BBDR)
		frame $f.5 -borderwidth $evv(BBDR)
		button $f.0.ok -text "Get Sounds" -command {set pr_propgath 1} -width 10 -highlightbackground [option get . background {}]
		button $f.0.qu -text "Quit" -command {set pr_propgath 0} -highlightbackground [option get . background {}]
		pack $f.0.ok -side left -padx 2
		pack $f.0.qu -side right
		label $f.1.ll -text "Name of Property "
		entry $f.1.e -textvariable propgathname -width 32
		pack  $f.1.ll $f.1.e -side left -padx 2
		label $f.2.ll -text "Value(s) of Property"
		entry $f.2.e -textvariable propgathvals -width 32
		label $f.2.ll2 -text "(use commas to separate multiple values)"
		pack  $f.2.ll $f.2.e $f.2.ll2 -side left -padx 2
		label $f.3.ll -text "Output Filename " -width 16
		entry $f.3.e -textvariable propgathfnam -width 36
		pack $f.3.ll $f.3.e -side left -padx 8
		checkbutton $f.4.ch -text "Ignore bracketed values" -variable ditchbrackets
		pack $f.4.ch -side top
		Scrolled_Listbox $f.5.ll -width 80 -height 48 -selectmode single
		pack $f.5.ll -side top
		pack $f.0 $f.1 $f.2 $f.3 $f.4 $f.5 -side top -pady 2 -fill x -expand true
		wm resizable $f 1 1
		bind $f <Escape> {set pr_propgath 0}
		bind $f <Return> {set pr_propgath 1}
	}
	set ditchbrackets 0
	raise $f
	update idletasks
	StandardPosition $f
	set pr_propgath 0 
	set finished 0
	My_Grab 0 $f pr_propgath $f.1.e
	while {!$finished} {
		tkwait variable pr_propgath
		switch -- $pr_propgath {
			1 {
				set propgathname [string trim $propgathname]
				if {[string length $propgathname] <= 0} {
					Inf "No Property Name Entered"
					continue
				}
				set pos [lsearch $prop_names $propgathname] 
				if {$pos < 0} {
					Inf "No Property '$propgathname' Exists"
					continue
				}
				incr pos
				set propgathvals [string trim $propgathvals]
				if {[string length $propgathvals] <= 0} {
					Inf "No Property Value(s) Entered"
					continue
				}
				set gathvals [split $propgathvals ","]
				if {[string length $propgathfnam] <= 0} {
					Inf "No Filename Entered"
					continue
				}
				if {![ValidCDPRootname $propgathfnam]} {
					continue
				}
				set ofnam $propgathfnam
				append ofnam [GetTextfileExtension props]
				if {[file exists $ofnam]} {
					Inf "File 'ofnam' Already Exists: Please Choose Another Name"
					continue
				}
				Block "Extracting Sounds with Property Value"
				catch {unset outlines}
				catch {unset outsnds}
				foreach fnam $fnams {
					if [catch {open $fnam "r"} zit] {
						Inf "Failed To Reopen File '$fnam'"
						continue
					}
					set linecnt 0
					while {[gets $zit line] >= 0} {
						catch {unset nuline}
						set line [string trim $line]
						if {[string length $line] <= 0} {
							continue
						}
						set line [split $line]
						foreach item $line {
							set item [string trim $item]
							if {[string length $item] > 0} {
								lappend nuline $item
							}
						}
						if {![info exists nuline]} {
							continue
						}
						if {$linecnt > 0} {
							set gotline 0
							set thisval [lindex $nuline $pos]
							if {[string match $thisval "-"]} {
								incr linecnt
								continue
							}
							set vals [split $thisval ","]
							foreach value $vals {
								if {[string first "(" $value] >= 0} {
									if {$ditchbrackets} {
										continue
									} else {
										set value [RemoveBrackets $value]
									}
								}
								foreach val $gathvals {
									if {[string match $value $val]} {
										lappend outlines $nuline
										lappend outsnds [lindex $nuline 0]
										set gotline 1
										break
									}
								}
								if {$gotline} {
									break
								}
							}
						}
						incr linecnt
					}
					close $zit
				}					
				if {![info exists outlines]} {
					Inf "Failed To Find Any Sounds With Value(s) '$propgathvals' For Property '$propgathname'"
					UnBlock							
					continue
				}
				foreach snd $outsnds {
					$f.5.ll.list insert end $snd
				}
				UnBlock
				if [catch {open $ofnam "w"} zit] {
					Inf "Cannot Open File '$ofnam'"
					continue
				}
				puts $zit $prop_names
				foreach line $outlines {
					puts $zit $line
				}
				close $zit
				FileToWkspace $ofnam 0 0 0 0 1
				Inf "File '$ofnam' Is On The Workspace"
			}
			0 {
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- Generate a mapping from an actual timing of events to an idealised timimng of events, from a props file.

proc IdealisedRhythmMap {} {
	global pr_idealrh proplocn tp_props_list rcodeat hasMMprop hasoffsetprop readonlybg readonlyfg pa wstk evv 
	global ideal_rhy firstmainbeat idealresetval idealreset tempochanges idealMmult upMM dnMM idealsee idealmm origidealmm
	global idealoff origidealoff idealtag origidealtag idealmult motiftimes idealmm ideal_realtimes ideal_realsamptimes idealtimes
	global chlist ch chcnt pr_proptab

	set evv(FRACBUTTON_CNT) 24

	if {![info exists proplocn]} {
		Inf "Choose A Sound By Playing It From The Properties Interface"
		return
	}
	set firstmainbeat -1
	set idealresetval ""
	set idealreset -1
	catch {unset tempochanges}
	catch {unset ideal_realtimes}
	catch {unset ideal_realsamptimes}
	catch {unset origidealmm}
	catch {unset upMM}
	catch {unset dnMM}
	set idealMmult 0
	set k $proplocn
	incr k -1
	set sndfnam [lindex [lindex $tp_props_list $k] 0]
	if {![info exists pa($sndfnam,$evv(SRATE))]} {
		Inf "Sound '$sndfnam' Not On Workspace: Cannot Proceed"
		return
	}
	set srate [expr double($pa($sndfnam,$evv(SRATE)))]
	set rcode [lindex [lindex $tp_props_list $k] $rcodeat]
	if {[string match $rcode "-"]} {
		Inf "No Rhythm Specified For '$sndfnam'"
		return
	}
	set mm    [lindex [lindex $tp_props_list $k] $hasMMprop]
	set idealmm [ExtractIdealMM $mm]
	set origidealmm $idealmm
	if {[info exists hasoffsetprop]} {
		set offset [lindex [lindex $tp_props_list $k] $hasoffsetprop]
		if {[string match $offset "-"]} {
			unset offset
		}
	}
	set f .idealrh
	if [Dlg_Create $f "GENERATE IDEALISED RHYTHM MAP" "set pr_idealrh 0" -borderwidth $evv(BBDR)] {
		frame $f.a -borderwidth $evv(BBDR)
		frame $f.0 -borderwidth $evv(BBDR)
		frame $f.1 -borderwidth $evv(BBDR)
		frame $f.2 -borderwidth $evv(BBDR)
		frame $f.3 -borderwidth $evv(BBDR)
		frame $f.4 -borderwidth $evv(BBDR)
		button $f.a.hh -text "Help" -command "IdealHelp" -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.a.qu -text "To Props File" -command "set pr_idealrh 0" -highlightbackground [option get . background {}]
		button $f.a.q2 -text "To Wkspace" -command "set pr_idealrh 2" -highlightbackground [option get . background {}]
		pack $f.a.hh -side left
		pack $f.a.q2 $f.a.qu -side right -padx 2
		pack $f.a -side top -fill x -expand true
		button $f.0.ok -text "Create Map" -command "set pr_idealrh 1" -highlightbackground [option get . background {}]
		button $f.0.pl -text "Play Sound" -command "PlaySndfile $sndfnam 0" -highlightbackground [option get . background {}]
		button $f.0.sv -text "Sound View" -command "Ideal_GetRealTimesFromSview $srate $sndfnam" -bg $evv(SNCOLOR) -width 10 -highlightbackground [option get . background {}]
		button $f.0.mo -text "Use Motif Times" -command {} -width 16 -highlightbackground [option get . background {}]
		pack $f.0.ok $f.0.pl $f.0.sv $f.0.mo -side left -padx 2
		entry $f.0.e2 -textvariable idealoff -width 10
		label $f.0.ll2 -text "Time placement in output data of 1st Accented event in input sound          "
		entry $f.0.e -textvariable idealtag -width 10
		label $f.0.ll -text "Outfile Tag"
		pack $f.0.ll $f.0.e $f.0.ll2 $f.0.e2 -side right -pady 2
		pack $f.0 -side top -fill x -expand true
		label $f.1.ll -text "MM "
		entry $f.1.e -textvariable idealmm -state readonly -bg $readonlybg -fg $readonlyfg
		label $f.1.zz -text "        MM multiplier"
		radiobutton $f.1.z1 -text "*2/3" -variable idealMmult -value "1"  -command "MMMult"
		radiobutton $f.1.z2 -text "*3/2" -variable idealMmult -value "-1"  -command "MMMult"
		label $f.1.binds -text "UP incr : DN decr : L round : R unround : Cntrl-0 restore"
		pack $f.1.ll $f.1.e $f.1.zz $f.1.z1 $f.1.z2 $f.1.binds -side left
		pack $f.1 -side top

		set ideal_rhy [canvas $f.2.c -height 70 -width 600 -borderwidth 0 -highlightthickness 1 -highlightbackground $evv(SPECIAL)]

		pack $f.2.c -side left
		pack $f.2 -side top

		label $f.3.ll -text "FRACTIONAL BEAT REPRESENTATION"
		frame $f.3.fr
		set n 0
		frame $f.3.fr.a
		label $f.3.fr.a.rb1 -text "1st Accent "
		button $f.3.fr.a.bu -text "" -width 5 -command {} -bd 0 -highlightbackground [option get . background {}]
		label $f.3.fr.a.rb2 -text "Reset "
		pack $f.3.fr.a.rb1 $f.3.fr.a.bu $f.3.fr.a.rb2 -side top -anchor e  
		pack $f.3.fr.a -side left
		while {$n < $evv(FRACBUTTON_CNT)} {
			set nn [expr $n * 2]
			set nk [expr $nn + 1]
			frame $f.3.fr.$nn
			radiobutton $f.3.fr.$nn.rb1 -variable firstmainbeat -value $n
			button $f.3.fr.$nn.bu -text "" -width 5 -command "set idealreset $n" -highlightbackground [option get . background {}]
			radiobutton $f.3.fr.$nn.rb2 -variable idealreset -value $n
			pack $f.3.fr.$nn.rb1 $f.3.fr.$nn.bu $f.3.fr.$nn.rb2 -side top -anchor w
			pack $f.3.fr.$nn -side left
			frame $f.3.fr.$nk -width 1 -bg [option get . background {}]
			pack $f.3.fr.$nk -side left -fill y -expand true
			incr n
		}

		label $f.3.mult -text "Fractional beat unit multiplier"
		frame $f.3.mvals
		radiobutton $f.3.mvals.b1 -text "*4" -variable idealmult -value 4  -command "IdealFracsMult"
		radiobutton $f.3.mvals.b2 -text "*2" -variable idealmult -value 2  -command "IdealFracsMult"
		radiobutton $f.3.mvals.b3 -text "/2" -variable idealmult -value -2 -command "IdealFracsMult"
		radiobutton $f.3.mvals.b4 -text "/4" -variable idealmult -value -4 -command "IdealFracsMult"
		pack $f.3.mvals.b1 $f.3.mvals.b2 $f.3.mvals.b3 $f.3.mvals.b4 -side left 

		pack $f.3.ll $f.3.fr $f.3.mult $f.3.mvals -side top -pady 2 
		pack $f.3 -side top


		frame $f.4.0
		frame $f.4.1
		label $f.4.0.tit -text "DATAFILE OUTPUT"
		set idealsee [Scrolled_Listbox $f.4.0.ll -width 60 -height 20 -selectmode single]
		pack $f.4.0.tit $f.4.0.ll -side top -pady 2
		frame $f.4.1.0
		frame $f.4.1.1
		frame $f.4.1.2
		frame $f.4.1.3
		label $f.4.1.0.ll -text "Replacement Fraction Value"
		frame $f.4.1.0.fr
		frame $f.4.1.0.fr.0
		label $f.4.1.0.fr.0.ll -text "1/8"
		radiobutton $f.4.1.0.fr.0.rb -value "1/8" -variable idealresetval
		pack $f.4.1.0.fr.0.ll $f.4.1.0.fr.0.rb -side top
		pack $f.4.1.0.fr.0 -side left
		frame $f.4.1.0.fr.1
		label $f.4.1.0.fr.1.ll -text "3/8"
		radiobutton $f.4.1.0.fr.1.rb -value "3/8" -variable idealresetval
		pack $f.4.1.0.fr.1.ll $f.4.1.0.fr.1.rb -side top
		pack $f.4.1.0.fr.1 -side left
		frame $f.4.1.0.fr.2
		label $f.4.1.0.fr.2.ll -text "5/8"
		radiobutton $f.4.1.0.fr.2.rb -value "5/8" -variable idealresetval
		pack $f.4.1.0.fr.2.ll $f.4.1.0.fr.2.rb -side top
		pack $f.4.1.0.fr.2 -side left
		frame $f.4.1.0.fr.3
		label $f.4.1.0.fr.3.ll -text "7/8"
		radiobutton $f.4.1.0.fr.3.rb -value "7/8" -variable idealresetval
		pack $f.4.1.0.fr.3.ll $f.4.1.0.fr.3.rb -side top
		pack $f.4.1.0.fr.3 -side left
		frame $f.4.1.0.fr.4
		label $f.4.1.0.fr.4.ll -text "1/4"
		radiobutton $f.4.1.0.fr.4.rb -value "1/4" -variable idealresetval
		pack $f.4.1.0.fr.4.ll $f.4.1.0.fr.4.rb -side top
		pack $f.4.1.0.fr.4 -side left
		frame $f.4.1.0.fr.5
		label $f.4.1.0.fr.5.ll -text "3/4"
		radiobutton $f.4.1.0.fr.5.rb -value "3/4" -variable idealresetval
		pack $f.4.1.0.fr.5.ll $f.4.1.0.fr.5.rb -side top
		pack $f.4.1.0.fr.5 -side left
		frame $f.4.1.0.fr.6
		label $f.4.1.0.fr.6.ll -text "1/2"
		radiobutton $f.4.1.0.fr.6.rb -value "1/2" -variable idealresetval
		pack $f.4.1.0.fr.6.ll $f.4.1.0.fr.6.rb -side top
		pack $f.4.1.0.fr.6 -side left
		frame $f.4.1.0.fr.7
		label $f.4.1.0.fr.7.ll -text "1"
		radiobutton $f.4.1.0.fr.7.rb -value "1" -variable idealresetval
		pack $f.4.1.0.fr.7.ll $f.4.1.0.fr.7.rb -side top
		pack $f.4.1.0.fr.7  -side left
		frame $f.4.1.0.fr.8
		label $f.4.1.0.fr.8.ll -text "1/3"
		radiobutton $f.4.1.0.fr.8.rb -value "1/3" -variable idealresetval
		pack $f.4.1.0.fr.8.ll $f.4.1.0.fr.8.rb -side top
		pack $f.4.1.0.fr.8 -side left
		frame $f.4.1.0.fr.9
		label $f.4.1.0.fr.9.ll -text "2/3"
		radiobutton $f.4.1.0.fr.9.rb -value "2/3" -variable idealresetval
		pack $f.4.1.0.fr.9.ll $f.4.1.0.fr.9.rb -side top
		pack $f.4.1.0.fr.9 -side left
		frame $f.4.1.0.fr.10
		label $f.4.1.0.fr.10.ll -text "1/6"
		radiobutton $f.4.1.0.fr.10.rb -value "1/6" -variable idealresetval
		pack $f.4.1.0.fr.10.ll $f.4.1.0.fr.10.rb -side top
		pack $f.4.1.0.fr.10 -side left
		frame $f.4.1.0.fr.11
		label $f.4.1.0.fr.11.ll -text "5/6"
		radiobutton $f.4.1.0.fr.11.rb -value "5/6" -variable idealresetval
		pack $f.4.1.0.fr.11.ll $f.4.1.0.fr.11.rb -side top
		pack $f.4.1.0.fr.11 -side left
		frame $f.4.1.0.fr.12
		label $f.4.1.0.fr.12.ll -text "1/5"
		radiobutton $f.4.1.0.fr.12.rb -value "1/5" -variable idealresetval
		pack $f.4.1.0.fr.12.ll $f.4.1.0.fr.12.rb -side top
		pack $f.4.1.0.fr.12 -side left
		frame $f.4.1.0.fr.13
		label $f.4.1.0.fr.13.ll -text "2/5"
		radiobutton $f.4.1.0.fr.13.rb -value "2/5" -variable idealresetval
		pack $f.4.1.0.fr.13.ll $f.4.1.0.fr.13.rb -side top
		pack $f.4.1.0.fr.13 -side left
		frame $f.4.1.0.fr.14
		label $f.4.1.0.fr.14.ll -text "3/5"
		radiobutton $f.4.1.0.fr.14.rb -value "3/5" -variable idealresetval
		pack $f.4.1.0.fr.14.ll $f.4.1.0.fr.14.rb -side top
		pack $f.4.1.0.fr.14 -side left
		frame $f.4.1.0.fr.15
		label $f.4.1.0.fr.15.ll -text "4/5"
		radiobutton $f.4.1.0.fr.15.rb -value "4/5" -variable idealresetval
		pack $f.4.1.0.fr.15.ll $f.4.1.0.fr.15.rb -side top
		pack $f.4.1.0.fr.15 -side left
		frame $f.4.1.0.fr.16
		label $f.4.1.0.fr.16.ll -text "1/7"
		radiobutton $f.4.1.0.fr.16.rb -value "1/7" -variable idealresetval
		pack $f.4.1.0.fr.16.ll $f.4.1.0.fr.16.rb -side top
		pack $f.4.1.0.fr.16 -side left
		frame $f.4.1.0.fr.17
		label $f.4.1.0.fr.17.ll -text "2/7"
		radiobutton $f.4.1.0.fr.17.rb -value "2/7" -variable idealresetval
		pack $f.4.1.0.fr.17.ll $f.4.1.0.fr.17.rb -side top
		pack $f.4.1.0.fr.17 -side left
		frame $f.4.1.0.fr.18
		label $f.4.1.0.fr.18.ll -text "3/7"
		radiobutton $f.4.1.0.fr.18.rb -value "3/7" -variable idealresetval
		pack $f.4.1.0.fr.18.ll $f.4.1.0.fr.18.rb -side top
		pack $f.4.1.0.fr.18 -side left
		frame $f.4.1.0.fr.19
		label $f.4.1.0.fr.19.ll -text "4/7"
		radiobutton $f.4.1.0.fr.19.rb -value "4/7" -variable idealresetval
		pack $f.4.1.0.fr.19.ll $f.4.1.0.fr.19.rb -side top
		pack $f.4.1.0.fr.19 -side left
		frame $f.4.1.0.fr.20
		label $f.4.1.0.fr.20.ll -text "5/7"
		radiobutton $f.4.1.0.fr.20.rb -value "5/7" -variable idealresetval
		pack $f.4.1.0.fr.20.ll $f.4.1.0.fr.20.rb -side top
		pack $f.4.1.0.fr.20 -side left
		frame $f.4.1.0.fr.21
		label $f.4.1.0.fr.21.ll -text "6/7"
		radiobutton $f.4.1.0.fr.21.rb -value "6/7" -variable idealresetval
		pack $f.4.1.0.fr.21.ll $f.4.1.0.fr.21.rb -side top
		pack $f.4.1.0.fr.21 -side left
		pack $f.4.1.0.ll $f.4.1.0.fr -side top -pady 2

		frame $f.4.1.1.0
		label $f.4.1.1.0.ll -text "9/8"
		radiobutton $f.4.1.1.0.rb -value "9/8" -variable idealresetval
		pack $f.4.1.1.0.ll $f.4.1.1.0.rb -side top
		pack $f.4.1.1.0 -side left
		frame $f.4.1.1.1
		label $f.4.1.1.1.ll -text "11/8"
		radiobutton $f.4.1.1.1.rb -value "11/8" -variable idealresetval
		pack $f.4.1.1.1.ll $f.4.1.1.1.rb -side top
		pack $f.4.1.1.1 -side left
		frame $f.4.1.1.2
		label $f.4.1.1.2.ll -text "13/8"
		radiobutton $f.4.1.1.2.rb -value "13/8" -variable idealresetval
		pack $f.4.1.1.2.ll $f.4.1.1.2.rb -side top
		pack $f.4.1.1.2 -side left
		frame $f.4.1.1.3
		label $f.4.1.1.3.ll -text "15/8"
		radiobutton $f.4.1.1.3.rb -value "15/8" -variable idealresetval
		pack $f.4.1.1.3.ll $f.4.1.1.3.rb -side top
		pack $f.4.1.1.3 -side left
		frame $f.4.1.1.4
		label $f.4.1.1.4.ll -text "5/4"
		radiobutton $f.4.1.1.4.rb -value "5/4" -variable idealresetval
		pack $f.4.1.1.4.ll $f.4.1.1.4.rb -side top
		pack $f.4.1.1.4 -side left
		frame $f.4.1.1.5
		label $f.4.1.1.5.ll -text "7/4"
		radiobutton $f.4.1.1.5.rb -value "7/4" -variable idealresetval
		pack $f.4.1.1.5.ll $f.4.1.1.5.rb -side top
		pack $f.4.1.1.5 -side left
		frame $f.4.1.1.6
		label $f.4.1.1.6.ll -text "3/2"
		radiobutton $f.4.1.1.6.rb -value "3/2" -variable idealresetval
		pack $f.4.1.1.6.ll $f.4.1.1.6.rb -side top
		pack $f.4.1.1.6 -side left
		frame $f.4.1.1.7
		label $f.4.1.1.7.ll -text "2"
		radiobutton $f.4.1.1.7.rb -value "2" -variable idealresetval
		pack $f.4.1.1.7.ll $f.4.1.1.7.rb -side top
		pack $f.4.1.1.7 -side left
		frame $f.4.1.1.8
		label $f.4.1.1.8.ll -text "4/3"
		radiobutton $f.4.1.1.8.rb -value "4/3" -variable idealresetval
		pack $f.4.1.1.8.ll $f.4.1.1.8.rb -side top
		pack $f.4.1.1.8 -side left
		frame $f.4.1.1.9
		label $f.4.1.1.9.ll -text "5/3"
		radiobutton $f.4.1.1.9.rb -value "5/3" -variable idealresetval
		pack $f.4.1.1.9.ll $f.4.1.1.9.rb -side top
		pack $f.4.1.1.9 -side left
		frame $f.4.1.1.10
		label $f.4.1.1.10.ll -text "7/6"
		radiobutton $f.4.1.1.10.rb -value "7/6" -variable idealresetval
		pack $f.4.1.1.10.ll $f.4.1.1.10.rb -side top
		pack $f.4.1.1.10 -side left
		frame $f.4.1.1.11
		label $f.4.1.1.11.ll -text "11/6"
		radiobutton $f.4.1.1.11.rb -value "11/6" -variable idealresetval
		pack $f.4.1.1.11.ll $f.4.1.1.11.rb -side top
		pack $f.4.1.1.11 -side left
		frame $f.4.1.1.12
		label $f.4.1.1.12.ll -text "6/5"
		radiobutton $f.4.1.1.12.rb -value "6/5" -variable idealresetval
		pack $f.4.1.1.12.ll $f.4.1.1.12.rb -side top
		pack $f.4.1.1.12 -side left
		frame $f.4.1.1.13
		label $f.4.1.1.13.ll -text "7/5"
		radiobutton $f.4.1.1.13.rb -value "7/5" -variable idealresetval
		pack $f.4.1.1.13.ll $f.4.1.1.13.rb -side top
		pack $f.4.1.1.13 -side left
		frame $f.4.1.1.14
		label $f.4.1.1.14.ll -text "8/5"
		radiobutton $f.4.1.1.14.rb -value "8/5" -variable idealresetval
		pack $f.4.1.1.14.ll $f.4.1.1.14.rb -side top
		pack $f.4.1.1.14 -side left
		frame $f.4.1.1.15
		label $f.4.1.1.15.ll -text "9/5"
		radiobutton $f.4.1.1.15.rb -value "9/5" -variable idealresetval
		pack $f.4.1.1.15.ll $f.4.1.1.15.rb -side top
		pack $f.4.1.1.15 -side left
		frame $f.4.1.1.16
		label $f.4.1.1.16.ll -text "8/7"
		radiobutton $f.4.1.1.16.rb -value "8/7" -variable idealresetval
		pack $f.4.1.1.16.ll $f.4.1.1.16.rb -side top
		pack $f.4.1.1.16 -side left
		frame $f.4.1.1.17
		label $f.4.1.1.17.ll -text "9/7"
		radiobutton $f.4.1.1.17.rb -value "9/7" -variable idealresetval
		pack $f.4.1.1.17.ll $f.4.1.1.17.rb -side top
		pack $f.4.1.1.17 -side left
		frame $f.4.1.1.18
		label $f.4.1.1.18.ll -text "10/7"
		radiobutton $f.4.1.1.18.rb -value "10/7" -variable idealresetval
		pack $f.4.1.1.18.ll $f.4.1.1.18.rb -side top
		pack $f.4.1.1.18 -side left
		frame $f.4.1.1.19
		label $f.4.1.1.19.ll -text "11/7"
		radiobutton $f.4.1.1.19.rb -value "11/7" -variable idealresetval
		pack $f.4.1.1.19.ll $f.4.1.1.19.rb -side top
		pack $f.4.1.1.19 -side left
		frame $f.4.1.1.20
		label $f.4.1.1.20.ll -text "12/7"
		radiobutton $f.4.1.1.20.rb -value "12/7" -variable idealresetval
		pack $f.4.1.1.20.ll $f.4.1.1.20.rb -side top
		pack $f.4.1.1.20 -side left
		frame $f.4.1.1.21
		label $f.4.1.1.21.ll -text "13/7"
		radiobutton $f.4.1.1.21.rb -value "13/7" -variable idealresetval
		pack $f.4.1.1.21.ll $f.4.1.1.21.rb -side top
		pack $f.4.1.1.21 -side left

		frame $f.4.1.2.0
		label $f.4.1.2.0.ll -text "17/8"
		radiobutton $f.4.1.2.0.rb -value "17/8" -variable idealresetval
		pack $f.4.1.2.0.ll $f.4.1.2.0.rb -side top
		pack $f.4.1.2.0 -side left
		frame $f.4.1.2.1
		label $f.4.1.2.1.ll -text "19/8"
		radiobutton $f.4.1.2.1.rb -value "19/8" -variable idealresetval
		pack $f.4.1.2.1.ll $f.4.1.2.1.rb -side top
		pack $f.4.1.2.1 -side left
		frame $f.4.1.2.2
		label $f.4.1.2.2.ll -text "21/8"
		radiobutton $f.4.1.2.2.rb -value "21/8" -variable idealresetval
		pack $f.4.1.2.2.ll $f.4.1.2.2.rb -side top
		pack $f.4.1.2.2 -side left
		frame $f.4.1.2.3
		label $f.4.1.2.3.ll -text "23/8"
		radiobutton $f.4.1.2.3.rb -value "23/8" -variable idealresetval
		pack $f.4.1.2.3.ll $f.4.1.2.3.rb -side top
		pack $f.4.1.2.3 -side left
		frame $f.4.1.2.4
		label $f.4.1.2.4.ll -text "9/4"
		radiobutton $f.4.1.2.4.rb -value "9/4" -variable idealresetval
		pack $f.4.1.2.4.ll $f.4.1.2.4.rb -side top
		pack $f.4.1.2.4 -side left
		frame $f.4.1.2.5
		label $f.4.1.2.5.ll -text "11/4"
		radiobutton $f.4.1.2.5.rb -value "11/4" -variable idealresetval
		pack $f.4.1.2.5.ll $f.4.1.2.5.rb -side top
		pack $f.4.1.2.5 -side left
		frame $f.4.1.2.6
		label $f.4.1.2.6.ll -text "5/2"
		radiobutton $f.4.1.2.6.rb -value "5/2" -variable idealresetval
		pack $f.4.1.2.6.ll $f.4.1.2.6.rb -side top
		pack $f.4.1.2.6 -side left
		frame $f.4.1.2.7
		label $f.4.1.2.7.ll -text "3"
		radiobutton $f.4.1.2.7.rb -value "3" -variable idealresetval
		pack $f.4.1.2.7.ll $f.4.1.2.7.rb -side top
		pack $f.4.1.2.7 -side left
		frame $f.4.1.2.8
		label $f.4.1.2.8.ll -text "7/3"
		radiobutton $f.4.1.2.8.rb -value "7/3" -variable idealresetval
		pack $f.4.1.2.8.ll $f.4.1.2.8.rb -side top
		pack $f.4.1.2.8 -side left
		frame $f.4.1.2.9
		label $f.4.1.2.9.ll -text "8/3"
		radiobutton $f.4.1.2.9.rb -value "8/3" -variable idealresetval
		pack $f.4.1.2.9.ll $f.4.1.2.9.rb -side top
		pack $f.4.1.2.9 -side left
		frame $f.4.1.2.10
		label $f.4.1.2.10.ll -text "13/6"
		radiobutton $f.4.1.2.10.rb -value "13/6" -variable idealresetval
		pack $f.4.1.2.10.ll $f.4.1.2.10.rb -side top
		pack $f.4.1.2.10 -side left
		frame $f.4.1.2.11
		label $f.4.1.2.11.ll -text "17/6"
		radiobutton $f.4.1.2.11.rb -value "17/6" -variable idealresetval
		pack $f.4.1.2.11.ll $f.4.1.2.11.rb -side top
		pack $f.4.1.2.11 -side left
		frame $f.4.1.2.12
		label $f.4.1.2.12.ll -text "11/5"
		radiobutton $f.4.1.2.12.rb -value "11/5" -variable idealresetval
		pack $f.4.1.2.12.ll $f.4.1.2.12.rb -side top
		pack $f.4.1.2.12 -side left
		frame $f.4.1.2.13
		label $f.4.1.2.13.ll -text "12/5"
		radiobutton $f.4.1.2.13.rb -value "12/5" -variable idealresetval
		pack $f.4.1.2.13.ll $f.4.1.2.13.rb -side top
		pack $f.4.1.2.13 -side left
		frame $f.4.1.2.14
		label $f.4.1.2.14.ll -text "13/5"
		radiobutton $f.4.1.2.14.rb -value "13/5" -variable idealresetval
		pack $f.4.1.2.14.ll $f.4.1.2.14.rb -side top
		pack $f.4.1.2.14 -side left
		frame $f.4.1.2.15
		label $f.4.1.2.15.ll -text "14/5"
		radiobutton $f.4.1.2.15.rb -value "14/5" -variable idealresetval
		pack $f.4.1.2.15.ll $f.4.1.2.15.rb -side top
		pack $f.4.1.2.15 -side left
		frame $f.4.1.2.16
		label $f.4.1.2.16.ll -text "15/7"
		radiobutton $f.4.1.2.16.rb -value "15/7" -variable idealresetval
		pack $f.4.1.2.16.ll $f.4.1.2.16.rb -side top
		pack $f.4.1.2.16 -side left
		frame $f.4.1.2.17
		label $f.4.1.2.17.ll -text "16/7"
		radiobutton $f.4.1.2.17.rb -value "16/7" -variable idealresetval
		pack $f.4.1.2.17.ll $f.4.1.2.17.rb -side top
		pack $f.4.1.2.17 -side left
		frame $f.4.1.2.18
		label $f.4.1.2.18.ll -text "17/7"
		radiobutton $f.4.1.2.18.rb -value "17/7" -variable idealresetval
		pack $f.4.1.2.18.ll $f.4.1.2.18.rb -side top
		pack $f.4.1.2.18 -side left
		frame $f.4.1.2.19
		label $f.4.1.2.19.ll -text "18/7"
		radiobutton $f.4.1.2.19.rb -value "18/7" -variable idealresetval
		pack $f.4.1.2.19.ll $f.4.1.2.19.rb -side top
		pack $f.4.1.2.19 -side left
		frame $f.4.1.2.20
		label $f.4.1.2.20.ll -text "19/7"
		radiobutton $f.4.1.2.20.rb -value "19/7" -variable idealresetval
		pack $f.4.1.2.20.ll $f.4.1.2.20.rb -side top
		pack $f.4.1.2.20 -side left
		frame $f.4.1.2.21
		label $f.4.1.2.21.ll -text "20/7"
		radiobutton $f.4.1.2.21.rb -value "20/7" -variable idealresetval
		pack $f.4.1.2.21.ll $f.4.1.2.21.rb -side top
		pack $f.4.1.2.21 -side left

		frame $f.4.1.3.0
		label $f.4.1.3.0.ll -text "25/8"
		radiobutton $f.4.1.3.0.rb -value "25/8" -variable idealresetval
		pack $f.4.1.3.0.ll $f.4.1.3.0.rb -side top
		pack $f.4.1.3.0 -side left
		frame $f.4.1.3.1
		label $f.4.1.3.1.ll -text "27/8"
		radiobutton $f.4.1.3.1.rb -value "27/8" -variable idealresetval
		pack $f.4.1.3.1.ll $f.4.1.3.1.rb -side top
		pack $f.4.1.3.1 -side left
		frame $f.4.1.3.2
		label $f.4.1.3.2.ll -text "29/8"
		radiobutton $f.4.1.3.2.rb -value "29/8" -variable idealresetval
		pack $f.4.1.3.2.ll $f.4.1.3.2.rb -side top
		pack $f.4.1.3.2 -side left
		frame $f.4.1.3.3
		label $f.4.1.3.3.ll -text "31/8"
		radiobutton $f.4.1.3.3.rb -value "31/8" -variable idealresetval
		pack $f.4.1.3.3.ll $f.4.1.3.3.rb -side top
		pack $f.4.1.3.3 -side left
		frame $f.4.1.3.4
		label $f.4.1.3.4.ll -text "13/4"
		radiobutton $f.4.1.3.4.rb -value "13/4" -variable idealresetval
		pack $f.4.1.3.4.ll $f.4.1.3.4.rb -side top
		pack $f.4.1.3.4 -side left
		frame $f.4.1.3.5
		label $f.4.1.3.5.ll -text "15/4"
		radiobutton $f.4.1.3.5.rb -value "15/4" -variable idealresetval
		pack $f.4.1.3.5.ll $f.4.1.3.5.rb -side top
		pack $f.4.1.3.5 -side left
		frame $f.4.1.3.6
		label $f.4.1.3.6.ll -text "7/2"
		radiobutton $f.4.1.3.6.rb -value "7/2" -variable idealresetval
		pack $f.4.1.3.6.ll $f.4.1.3.6.rb -side top
		pack $f.4.1.3.6 -side left
		frame $f.4.1.3.7
		label $f.4.1.3.7.ll -text "4"
		radiobutton $f.4.1.3.7.rb -value "4" -variable idealresetval
		pack $f.4.1.3.7.ll $f.4.1.3.7.rb -side top
		pack $f.4.1.3.7 -side left
		frame $f.4.1.3.8
		label $f.4.1.3.8.ll -text "10/3"
		radiobutton $f.4.1.3.8.rb -value "10/3" -variable idealresetval
		pack $f.4.1.3.8.ll $f.4.1.3.8.rb -side top
		pack $f.4.1.3.8 -side left
		frame $f.4.1.3.9
		label $f.4.1.3.9.ll -text "11/3"
		radiobutton $f.4.1.3.9.rb -value "11/3" -variable idealresetval
		pack $f.4.1.3.9.ll $f.4.1.3.9.rb -side top
		pack $f.4.1.3.9 -side left
		frame $f.4.1.3.10
		label $f.4.1.3.10.ll -text "19/6"
		radiobutton $f.4.1.3.10.rb -value "19/6" -variable idealresetval
		pack $f.4.1.3.10.ll $f.4.1.3.10.rb -side top
		pack $f.4.1.3.10 -side left
		frame $f.4.1.3.11
		label $f.4.1.3.11.ll -text "23/6"
		radiobutton $f.4.1.3.11.rb -value "23/6" -variable idealresetval
		pack $f.4.1.3.11.ll $f.4.1.3.11.rb -side top
		pack $f.4.1.3.11 -side left
		frame $f.4.1.3.12
		label $f.4.1.3.12.ll -text "16/5"
		radiobutton $f.4.1.3.12.rb -value "16/5" -variable idealresetval
		pack $f.4.1.3.12.ll $f.4.1.3.12.rb -side top
		pack $f.4.1.3.12 -side left
		frame $f.4.1.3.13
		label $f.4.1.3.13.ll -text "17/5"
		radiobutton $f.4.1.3.13.rb -value "17/5" -variable idealresetval
		pack $f.4.1.3.13.ll $f.4.1.3.13.rb -side top
		pack $f.4.1.3.13 -side left
		frame $f.4.1.3.14
		label $f.4.1.3.14.ll -text "18/5"
		radiobutton $f.4.1.3.14.rb -value "18/5" -variable idealresetval
		pack $f.4.1.3.14.ll $f.4.1.3.14.rb -side top
		pack $f.4.1.3.14 -side left
		frame $f.4.1.3.15
		label $f.4.1.3.15.ll -text "19/5"
		radiobutton $f.4.1.3.15.rb -value "19/5" -variable idealresetval
		pack $f.4.1.3.15.ll $f.4.1.3.15.rb -side top
		pack $f.4.1.3.15 -side left
		frame $f.4.1.3.16
		label $f.4.1.3.16.ll -text "22/7"
		radiobutton $f.4.1.3.16.rb -value "22/7" -variable idealresetval
		pack $f.4.1.3.16.ll $f.4.1.3.16.rb -side top
		pack $f.4.1.3.16 -side left
		frame $f.4.1.3.17
		label $f.4.1.3.17.ll -text "23/7"
		radiobutton $f.4.1.3.17.rb -value "23/7" -variable idealresetval
		pack $f.4.1.3.17.ll $f.4.1.3.17.rb -side top
		pack $f.4.1.3.17 -side left
		frame $f.4.1.3.18
		label $f.4.1.3.18.ll -text "24/7"
		radiobutton $f.4.1.3.18.rb -value "24/7" -variable idealresetval
		pack $f.4.1.3.18.ll $f.4.1.3.18.rb -side top
		pack $f.4.1.3.18 -side left
		frame $f.4.1.3.19
		label $f.4.1.3.19.ll -text "25/7"
		radiobutton $f.4.1.3.19.rb -value "25/7" -variable idealresetval
		pack $f.4.1.3.19.ll $f.4.1.3.19.rb -side top
		pack $f.4.1.3.19 -side left
		frame $f.4.1.3.20
		label $f.4.1.3.20.ll -text "26/7"
		radiobutton $f.4.1.3.20.rb -value "26/7" -variable idealresetval
		pack $f.4.1.3.20.ll $f.4.1.3.20.rb -side top
		pack $f.4.1.3.20 -side left
		frame $f.4.1.3.21
		label $f.4.1.3.21.ll -text "27/7"
		radiobutton $f.4.1.3.21.rb -value "27/7" -variable idealresetval
		pack $f.4.1.3.21.ll $f.4.1.3.21.rb -side top
		pack $f.4.1.3.21 -side left

		button $f.4.1.4 -text "RESET FRACTION VALUE" -command ResetIdealVal -highlightbackground [option get . background {}]
		label $f.4.1.5 -text "(Select a \"Replacement Fraction Value\" AND Select a fraction to Reset)"

		pack $f.4.1.0 $f.4.1.1 $f.4.1.2 $f.4.1.3 $f.4.1.4 $f.4.1.5 -side top

		pack $f.4.0 $f.4.1 -side left -padx 20
		pack $f.4 -side top

		bind $f <Up>	{ChangeIdealMM up} 
		bind $f <Down>	{ChangeIdealMM down} 
		bind $f <Control-Key-0>	{ChangeIdealMM restore} 
		bind $f <Left>	{ChangeIdealMM round} 
		bind $f <Right> {ChangeIdealMM unround} 
		wm resizable $f 1 1
		bind $f <Escape> {set pr_idealrh 0}
		bind $f <Return> {set pr_idealrh 2}
	}
	wm title $f "GENERATE IDEALISED RHYTHM MAP FOR [file rootname [file tail $sndfnam]]"
	$idealsee delete 0 end
	set idealmult 0
	DisplayRhythmGraphicFromFullCode $rcode $ideal_rhy
	DisplayRhythmFractionsFromFullCode $rcode			;#		This also sets tempochanges, if any
	if {![CheckTempochanges $sndfnam]} {
		Dlg_Dismiss $f
		return
	}
	set motiftimes {}
	if {[info exists offset]} {
		set motiftimes [GetMotifTimesForIdeal $sndfnam]
	}
	set rcnt [CountRhythmEvents]
	if {[llength $motiftimes] == $rcnt} {
		.idealrh.0.mo config -text "Use Motif Times" -command "UseMotifForIdeal $offset $motiftimes" -bd 2
	} else {
		.idealrh.0.mo config -text "" -command {} -bd 0
	}
	raise $f
	update idletasks
	StandardPosition $f
	set pr_idealrh 0 
	set finished 0
	My_Grab 0 $f pr_idealrh
	while {!$finished} {
		tkwait variable pr_idealrh
		switch -- $pr_idealrh {
			1 {
				$idealsee delete 0 end
				if {![info exists ideal_realtimes]} {
					Inf "Real Event Times Not Specified"
					continue
				}
				if {[string length $idealtag] <= 0} {
					Inf "No Tag Specified For Data Filename"
					continue
				}
				set idealtag [string tolower $idealtag]
				if {![info exists origidealtag] || ![string match $origidealtag $idealtag]} {
					if {[SaveIdealTag]} {
						set origidealtag $idealtag
					}
				}
				if {([string length $idealoff] <= 0) || ![IsNumeric $idealoff] || ($idealoff <= 0.0)} {
					Inf "Invalid Time Of 1st Accent"
					continue
				}
				if {![info exists origidealoff] || ![string match $origidealoff $idealoff]} {
					if {[SaveIdealOffset]} {
						set origidealoff $idealoff
					}
				}
				set fnam [file rootname [file tail $sndfnam]]
				append fnam "_" $idealtag $evv(TEXT_EXT)
				if {[file exists $fnam]} {
					Inf "File Already Exists: Delete The File, Or Change The Tag"
					continue
				}
				if {$firstmainbeat < 0} {
					Inf "No First Accent Indicated"
					continue
				}
				if {![ConvertFraclistToTimes]} {
					continue
				}
				if {[llength $ideal_realtimes] != [llength $idealtimes]} {
					Inf "Number Of Marked Real Times ([llength $ideal_realtimes]) Different To Number Of Ideal Times ([llength $idealtimes])"
					continue
				}
				if [catch {open $fnam "w"} zit] {
					Inf "Cannot Open File '$fnam' To Write Data"
					continue
				}
				set line [list [lindex $idealmm 0] $idealoff]
				$idealsee insert end $line
				puts $zit $line
				foreach r $ideal_realtimes i $idealtimes {
					set r [DecPlaces $r 4]
					set i [DecPlaces $i 4]
					set line [list $r $i]
					$idealsee insert end $line
					puts $zit $line
				}
				close $zit
				FileToWkspace $fnam 0 0 0 0 1
				Inf "File '$fnam' Is On The Workspace"
			}
			2 {
				ClearAndSaveChoice
				set chlist $sndfnam
				$ch insert end $sndfnam
				incr chcnt
				My_Release_to_Dialog $f
				Dlg_Dismiss $f
				destroy $f
				set pr_proptab 0
				return
			}
			0 {
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

#---- Scale the duration of the rhythm graphics e.g. quaver ->crotchet or vice-versa

proc IdealFracsMult {} {
	global idealfracs idealmult
	set n 0
	foreach frac $idealfracs {
		set isneg 0			;#	neg indicates a rest
		set numer [lindex $frac 0]
		set denom [lindex $frac 1]
		if {$numer < 0} {
			set isneg 1
			set numer [expr -$numer]
		}
		switch -- $idealmult {
			"2" {		
				if {[IsEven $denom]} {
					set q [expr $denom/$idealmult]
					if {$q > 0} {
						set denom $q
					} else {
						set numer [expr $numer * $idealmult]
					}
				} else {
					set numer [expr $numer * $idealmult]
				}
			}
			"4" {		
				if {($denom == 4) || ($denom == 8) || ($denom == 12) || ($denom == 16)} {
					set q [expr $denom/$idealmult]
					if {$q > 0} {
						set denom $q
					} else {
						set numer [expr $numer * $idealmult]
					}
				} else {
					set numer [expr $numer * $idealmult]
				}
			}
			"-2" {
				if {[IsEven $numer] && ($numer > 0)} {
					set numer [expr $numer / -$idealmult]
				} else {
					set denom [expr $denom * -$idealmult]
				}
			}
			"-4" {
				if {($numer == 4) || ($numer == 8) || ($numer == 12) || ($numer == 16)} {
					set numer [expr $numer / -$idealmult]
				} else {
					set denom [expr $denom * -$idealmult]
				}
			}
		}
		while {[IsEven $numer] && [IsEven $denom]} {
			set numer [expr $numer / 2 ]
			set denom [expr $denom / 2 ]
		}
		if {$isneg} {
			set numer [expr -$numer]
		}
		set nufrac [list $numer $denom]
		set idealfracs [lreplace $idealfracs $n $n $nufrac]
		incr n
	}
	RemapFracDisplay
}

#---- Change from "crotchet = " to "dotted crotchet = " for MM

proc MMMult {} {
	global idealmm origidealmm idealMmult dnMM upMM
	switch -- $idealMmult {
		-1 {
			if {[info exists dnMM]} {
				set idealmm $origidealmm
				unset dnMM
				return
			} else {
				foreach mm $idealmm {
					set numm [expr ($mm * 3.0)/2.0]
					lappend numms $numm
				}
				if {[info exists upMM]} {
					unset upMM
				} else {
					set upMM 1
				}
			}
		}
		1 {
			if {[info exists upMM]} {
				set idealmm $origidealmm
				unset upMM
				return
			} else {
				foreach mm $idealmm {
					set numm [expr ($mm * 2.0)/3.0]
					lappend numms $numm
				}
				if {[info exists dnMM]} {
					unset dnMM
				} else {
					set dnMM 1
				}
			}
		}
	}
	set idealmm $numms
}

#----- Change fractions shown on display

proc RemapFracDisplay {} {
	global idealfracs
	set k 0
	foreach frac $idealfracs {
		set thistext [lindex $frac 0]
		set denom [lindex $frac 1]
		if {$denom != 1} {
			append thistext "/"
			append thistext $denom
		}
		set nn [expr $k * 2]
		.idealrh.3.fr.$nn.bu config -text $thistext -width 5
		incr k
	}
}

#--- Change a unit-duration on the fractional display

proc ResetIdealVal {} {
	global idealresetval idealreset idealfracs
	set neg ""
	if {([string length $idealresetval] <= 0) || ($idealreset < 0)} {
		Inf "Select Item To Reset, And Select Reset Value, First"
		return
	}
	set orignumer [lindex [lindex $idealfracs $idealreset] 0]
	if {$orignumer < 0} {
		set neg "-"
	}
	set nn [expr $idealreset * 2]
	set reval $neg$idealresetval
	.idealrh.3.fr.$nn.bu config -text $reval
	if {[string length $idealresetval] == 1} {
		set nufrac [list $reval 1]
	} else {
		set nufrac [split $reval "/"]
	}
	set idealfracs [lreplace $idealfracs $idealreset $idealreset $nufrac]
}

#---- Display Rhythm as fractions, from Rcode property of propfile

proc DisplayRhythmFractionsFromFullCode {code} {
	global idealfracs ideal_barset ideal_isrest ideal_barcnt ideal_first_accent firstmainbeat tempochanges evv
	catch {unset ideal_first_accent}
	catch {unset tempochanges}
	catch {unset idealfracs}
	set codelen [string len $code]
	set j 0
	set k 1
	set n 0
	set ideal_barset 0
	set ideal_isrest 0
	set ideal_barcnt 0
	while {$j < $codelen} {
		set subcodon [string index $code $j]
		switch -- $subcodon {
			"|" -
			"," -
			"." -
			":" {
				set codon $subcodon
				incr j
				incr k
			}
			default {
				set codon [string range $code $j $k]
				incr j 2
				incr k 2
			}
		}
		set n [FractionFromRhythmCode $codon $n]
	}
	set k 0
	while {$k < $n} {
		set nn [expr $k * 2]
		.idealrh.3.fr.$nn.bu config -command "set idealreset $k"
		incr k
		if {$k >= $evv(FRACBUTTON_CNT)} {
			Inf "Too Many Values To Represent On Beat-Fraction Display"
		}
	}
	while {$k < $evv(FRACBUTTON_CNT)} {
		set nn [expr $k * 2]
		.idealrh.3.fr.$nn.bu config -command {}
		incr k
	}
	RemapFracDisplay
	if {[info exists ideal_first_accent]} {
		set firstmainbeat $ideal_first_accent
	}
	if {[info exists tempochanges]} {		;#	MARK TEMPO CHANGE POINTS ON DISPLAY
		foreach k $tempochanges {
			set nk [expr $k * 2]
			incr nk -1
			.idealrh.3.fr.$nk config -bg black
		}
	}
}

#--- Generate (set of) fractions-of-beats, from a codon in "rcode"

proc FractionFromRhythmCode {codon n} {
	global idealfracs tempochanges ideal_barset ideal_isrest ideal_barcnt ideal_first_accent
#NB neg vals are rests; double bars indicate change of tempo

	switch -- $codon {
		"a0" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 1]
			lappend fraclist $frac
			incr n
		}
		"a1" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 2]
			lappend fraclist $frac $frac
			incr n 2
		}
		"a2" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 3 4]
			lappend fraclist $frac
			set frac [list 1 4]
			lappend fraclist $frac
			incr n 2
		}
		"a3" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 4]
			lappend fraclist $frac
			set frac [list 3 4]
			lappend fraclist $frac
			incr n 2
		}
		"a4" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 2]
			lappend fraclist $frac
			set frac [list 1 4]
			lappend fraclist $frac
			set frac [list 1 4]
			lappend fraclist $frac
			incr n 3
		}
		"a5" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 4]
			lappend fraclist $frac
			set frac [list 1 4]
			lappend fraclist $frac
			set frac [list 1 2]
			lappend fraclist $frac
			incr n 3
		}
		"a6" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 4]
			lappend fraclist $frac
			set frac [list 1 2]
			lappend fraclist $frac
			set frac [list 1 4]
			lappend fraclist $frac
			incr n 3
		}
		"a7" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 4]
			lappend fraclist $frac $frac $frac $frac
			incr n 4
		}
		"a8" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 2]
			lappend fraclist $frac $frac $frac $frac
			incr n 4
		}
		"a9" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 4]
			lappend fraclist $frac $frac
			incr n 2
		}
		"b0" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 3 2]
			lappend fraclist $frac
			incr n
		}
		"b1" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 2]
			lappend fraclist $frac $frac $frac
			incr n 3
		}
		"b2" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 1]
			lappend fraclist $frac
			set frac [list 1 2]
			lappend fraclist $frac
			incr n 2
		}
		"b3" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 2]
			lappend fraclist $frac
			set frac [list 1 1]
			lappend fraclist $frac
			incr n 2
		}
		"b4" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 3 4]
			lappend fraclist $frac
			set frac [list 1 4]
			lappend fraclist $frac
			set frac [list 1 2]
			lappend fraclist $frac
			incr n 3
		}
		"b5" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 4]
			lappend fraclist $frac
			set frac [list 3 4]
			lappend fraclist $frac
			set frac [list 1 2]
			lappend fraclist $frac
			incr n 3
		}
		"b6" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 2]
			lappend fraclist $frac
			set frac [list 3 4]
			lappend fraclist $frac
			set frac [list 1 4]
			lappend fraclist $frac
			incr n 3
		}
		"b7" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 3 4]
			lappend fraclist $frac
			set frac [list 1 2]
			lappend fraclist $frac
			set frac [list 1 4]
			lappend fraclist $frac
			incr n 3
		}
		"b8" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 4]
			lappend fraclist $frac
			set frac [list 1 2]
			lappend fraclist $frac
			set frac [list 3 4]
			lappend fraclist $frac
			incr n 3
		}
		"c0" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 3 4]
			lappend fraclist $frac
			incr n
		}
		"c1" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 4]
			lappend fraclist $frac $frac $frac
			incr n 3
		}
		"c2" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 2]
			lappend fraclist $frac
			set frac [list 1 4]
			lappend fraclist $frac
			incr n 2
		}
		"c3" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 4]
			lappend fraclist $frac
			set frac [list 1 2]
			lappend fraclist $frac
			incr n 2
		}
		"c4" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 3 8]
			lappend fraclist $frac
			set frac [list 1 8]
			lappend fraclist $frac
			set frac [list 1 4]
			lappend fraclist $frac
			incr n 3
		}
		"c5" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 8]
			lappend fraclist $frac
			set frac [list 3 8]
			lappend fraclist $frac
			set frac [list 1 4]
			lappend fraclist $frac
			incr n 3
		}
		"c6" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 4]
			lappend fraclist $frac
			set frac [list 3 8]
			lappend fraclist $frac
			set frac [list 1 8]
			lappend fraclist $frac
			incr n 3
		}
		"c7" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 3 8]
			lappend fraclist $frac
			set frac [list 1 4]
			lappend fraclist $frac
			set frac [list 1 8]
			lappend fraclist $frac
			incr n 3
		}
		"c8" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 8]
			lappend fraclist $frac
			set frac [list 1 4]
			lappend fraclist $frac
			set frac [list 3 8]
			lappend fraclist $frac
			incr n 3
		}
		"d0" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 2 1]
			lappend fraclist $frac
			incr n
		}
		"d1" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 2 3]
			lappend fraclist $frac $frac $frac
			incr n 3
		}
		"d2" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 4 3]
			lappend fraclist $frac
			set frac [list 2 3]
			lappend fraclist $frac
			incr n 2
		}
		"d3" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 2 3]
			lappend fraclist $frac
			set frac [list 4 3]
			lappend fraclist $frac
			incr n 2
		}
		"d4" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 1]
			lappend fraclist $frac
			set frac [list 1 3]
			lappend fraclist $frac
			set frac [list 2 3]
			lappend fraclist $frac
			incr n 3
		}
		"d5" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 3]
			lappend fraclist $frac
			set frac [list 1 1]
			lappend fraclist $frac
			set frac [list 2 3]
			lappend fraclist $frac
			incr n 3
		}
		"d6" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 2 3]
			lappend fraclist $frac
			set frac [list 1 1]
			lappend fraclist $frac
			set frac [list 1 3]
			lappend fraclist $frac
			incr n 3
		}
		"d7" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 1]
			lappend fraclist $frac
			set frac [list 2 3]
			lappend fraclist $frac
			set frac [list 1 3]
			lappend fraclist $frac
			incr n 3
		}
		"d8" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 3]
			lappend fraclist $frac
			set frac [list 2 3]
			lappend fraclist $frac
			set frac [list 1 1]
			lappend fraclist $frac
			incr n 3
		}
		"e0" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 1]
			lappend fraclist $frac
			incr n
		}
		"e1" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 3]
			lappend fraclist $frac $frac $frac
			incr n 3
		}
		"e2" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 2 3]
			lappend fraclist $frac
			set frac [list 1 3]
			lappend fraclist $frac
			incr n 2
		}
		"e3" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 3]
			lappend fraclist $frac
			set frac [list 2 3]
			lappend fraclist $frac
			incr n 2
		}
		"e4" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 2]
			lappend fraclist $frac
			set frac [list 1 6]
			lappend fraclist $frac
			set frac [list 1 3]
			lappend fraclist $frac
			incr n 3
		}
		"e5" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 6]
			lappend fraclist $frac
			set frac [list 1 2]
			lappend fraclist $frac
			set frac [list 1 3]
			lappend fraclist $frac
			incr n 3
		}
		"e6" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 3]
			lappend fraclist $frac
			set frac [list 1 2]
			lappend fraclist $frac
			set frac [list 1 6]
			lappend fraclist $frac
			incr n 3
		}
		"e7" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 2]
			lappend fraclist $frac
			set frac [list 1 3]
			lappend fraclist $frac
			set frac [list 1 6]
			lappend fraclist $frac
			incr n 3
		}
		"e8" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 6]
			lappend fraclist $frac
			set frac [list 1 3]
			lappend fraclist $frac
			set frac [list 1 2]
			lappend fraclist $frac
			incr n 3
		}
		"b9" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 2]
			lappend fraclist $frac
			incr n
		}
		"c9" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 4]
			lappend fraclist $frac
			incr n
		}
		"d9" -
		"e9" {
			set ideal_isrest 0
			set ideal_barcnt 0
			if {$ideal_barset} {
				if {[info exists ideal_first_accent] && ($ideal_first_accent == $n)} {
					unset ideal_first_accent			;#	bar-rest does not create a strong beat at barline
				}
			}
			set ideal_barset 0
			set frac [list -1 3]
			lappend fraclist $frac
			set frac [list 1 3]
			lappend fraclist $frac
			set frac [list 1 3]
			lappend fraclist $frac
			incr n 3
		}
		"f0" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 1]
			lappend fraclist $frac
			incr n
		}
		"f1" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 6]
			lappend fraclist $frac $frac
			set frac [list 1 3]
			lappend fraclist $frac $frac
			incr n 4
		}
		"f2" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 3]
			lappend fraclist $frac
			set frac [list 1 6]
			lappend fraclist $frac $frac
			set frac [list 1 3]
			lappend fraclist $frac
			incr n 4
		}
		"f3" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 3]
			lappend fraclist $frac $frac
			set frac [list 1 6]
			lappend fraclist $frac $frac
			incr n 4
		}
		"f4" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 6]
			lappend fraclist $frac $frac $frac $frac
			set frac [list 1 3]
			lappend fraclist $frac
			incr n 5
		}
		"f5" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 3]
			lappend fraclist $frac
			set frac [list 1 6]
			lappend fraclist $frac $frac $frac $frac
			incr n 5
		}
		"f6" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 6]
			lappend fraclist $frac $frac $frac $frac $frac $frac
			incr n 6
		}
		"f7" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 6]
			lappend fraclist $frac $frac $frac
			incr n 3
		}
		"w4" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 4 1]
			lappend fraclist $frac
			incr n
		}
		"w6" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 6 1]
			lappend fraclist $frac
			incr n
		}
		"x4" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 2 1]
			lappend fraclist $frac
			incr n
		}
		"x6" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 3 1]
			lappend fraclist $frac
			incr n
		}
		"x9" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 1 1]
			lappend fraclist $frac
			incr n
		}
		"z0" {
			set ideal_isrest 0
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list 3 8]
			lappend fraclist $frac
			incr n
		}
		"." {
			if {$ideal_barset} {
				if {[info exists ideal_first_accent] && ($ideal_first_accent == $n)} {
					unset ideal_first_accent			;#	bar-rest does not create a strong beat at barline
				}
			}
			set ideal_isrest 1
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list -1 2]
			lappend fraclist $frac
			incr n
		}
		":" {
			if {$ideal_barset} {
				if {[info exists ideal_first_accent] && ($ideal_first_accent == $n)} {
					unset ideal_first_accent			;#	bar-rest does not create a strong beat at barline
				}
			}
			set ideal_isrest 1
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list -1 4]
			lappend fraclist $frac
			incr n
		}
		"," {
			if {$ideal_barset} {
				if {[info exists ideal_first_accent] && ($ideal_first_accent == $n)} {
					unset ideal_first_accent			;#	bar-rest does not create a strong beat at barline
				}
			}
			set ideal_isrest 1
			set ideal_barcnt 0
			set ideal_barset 0
			set frac [list -1 1]
			lappend fraclist $frac
			incr n
		}
		"|" {
			set ideal_barset 1
			if {$ideal_barcnt} {						;#	DOUBLE BAR = TEMPO CHANGE
				lappend tempochanges $n
				set ideal_barcnt 0
			} else {
				set ideal_barcnt 1
			}
			if {![info exists ideal_first_accent]} {
				set ideal_first_accent $n
			}
			set fraclist {}
		}
		default {
			set fraclist {}
			incr n
		}
	}
	if {![info exists idealfracs]} {
		set idealfracs $fraclist
	} else {
		set idealfracs [concat $idealfracs $fraclist]
	}
	return $n
}

#----- Count events that are not rests (rests are represented as -ve fracs)

proc CountRhythmEvents {} {
	global idealfracs
	set n 0
	foreach frac $idealfracs {
		if {[lindex $frac 0] > 0} {
			incr n
		}
	}
	return $n
}

#---- Use times grabbed from pitch-motif (+offset) as times for rhythm motif

proc UseMotifForIdeal {args} {
	global ideal_realtimes
	set offset [lindex $args 0]
	set args [lrange $args 1 end]
	catch {unset ideal_realtimes}
	foreach time $args {
		lappend ideal_realtimes [expr $time + $offset]
	}
}

#------ If a motif prop exists, get its times for use in Ideal-Rhythm

proc GetMotifTimesForIdeal {sndfnam} {
	global evv
	set motiftimes {}
	set motifnam [file rootname $sndfnam]
	append motifnam "_seq" $evv(TEXT_EXT)
	if {[file exists $motifnam]} {
		if {![catch {open $motifnam "r"} zit]} {
			while {[gets $zit line] >= 0} {
				catch {unset nuline}
				set line [string trim $line]
				if {[string length $line] <= 0} {
					continue
				}
				set line [split $line]
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] > 0} {
						lappend nuline $item
					}
				}
				if {![info exists nuline]} {
					continue
				}
				if {[llength $line] != 3} {
					set motiftimes {}
					break
				}
				lappend motiftimes [lindex $line 0]
			}
		}
	}
	return $motiftimes
}

#--- Get 1 MM (or more) from a possibly complex value with brackets and commas, and non-numeric, or empty values

proc ExtractIdealMM {mm} {
	if {[string match $mm "-"]} {
		Inf "NO MM SET"
		return ""
	}
	set mm [split $mm ","]
	foreach val $mm {
		if {[string first "(" $val] >= 0} {
			set val [RemoveBrackets $val]
		}
		if {![IsNumeric $val]} {
			set nonnum 1
			continue
		}
		lappend mmout $val
	}
	if {![info exists mmout]} {
		Inf "Non-Numeric MM Found ($mm)"
		return ""
	}
	if {[info exists nonnum]} {
		set msg "Non-Numeric MM Compoment(s) Found ($mm) : Use Numeric Component(s) ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return ""
		}
	}
	return $mmout
}


#---- Convert the fraction coding of rhythm pattern, to real times.

proc ConvertFraclistToTimes {} {
	global idealfracs idealoff idealtimes idealmm tempochanges firstmainbeat
	set beatdur [expr 60.0 / double([lindex $idealmm 0])]
	set eventcnt 0
	set timescnt 0				;#	There may be less (event)times than 'events' as some 'events' are rests
	set mmcnt 0					;#	Count of MMs (usually only 1)
	set nexteventtime 0			;#	Time where nextevent begins
	set times 0					;#	First event (initially) set to start at time zero

	foreach frac $idealfracs {
		if {$eventcnt == $firstmainbeat} {		;#	If this is event-position of first accent
			set accentpos $timescnt				;#	Note its position in the times list
		}
		if {[info exists tempochanges] && ([lindex $tempochanges $mmcnt] == $eventcnt)} {	;#	if reached tempochanging point, change tempo
			incr mmcnt																		;#	index in tempochanges is one less than index in MM list
			set beatdur [expr 60.0 / double([lindex $idealmm $mmcnt])]
			if {$mmcnt >= [llength $tempochanges]} {
				unset tempochanges
			}
		}
		set numer [lindex $frac 0]
		set denom [lindex $frac 1]
		set trufrac [expr abs(double($numer) / double($denom))]
		set dur [expr $beatdur * $trufrac]
		if {$numer < 0} {				;#	A rest
			if {$timescnt == 0} {		;#	 at start, ignore
				;#
			} else {					;#	A rest after previous event(s); add dur to dur-of-last-event, replacing previous val
				set nexteventtime [expr $nexteventtime + $dur]
				set times [lreplace $times end end $nexteventtime]
			}
		} else {						;#	An event
			set nexteventtime [expr $nexteventtime + $dur]
			lappend times $nexteventtime
			incr timescnt
		}
		incr eventcnt
	}
	set len [llength $times]
	incr len -2
	if {$len < 1} {
		Inf "TOO FEW TIMED EVENTS (MUST BE MORE THAN 1)"
		return 0
	}
	set times [lrange $times 0 $len]			;#	Lose last time, which is time of END of last event
	if {![info exists accentpos] || ($accentpos >= [llength $times])} {
		Inf "Accent Does Not Lie Within The Motif"
		return 0
	}
	set accenttime [lindex $times $accentpos]	;#	Find timing of 1st accent
	set shift [expr $idealoff - $accenttime]	;#	Shift all times, so first accent is at time specified by 'idealoff'
	catch {unset idealtimes}
	foreach time $times {
		set nutime [expr $time + $shift]
		if {$nutime < 0.0} {
			Inf "OFFSET IS NOT COMPATIBLE WITH THIS MOTIF"
			return 0
		}
		lappend idealtimes $nutime
	}
	return 1
}

#----- Check tempochanges tally with number of MMs listed

proc CheckTempochanges {sndfnam} {
	global tempochanges idealmm wstk
	if {![info exists tempochanges]} {
		set changlen 0
	} else {
		set changlen [llength $tempochanges]
	}
	incr changlen
	set mmlen [llength $idealmm]
	if {$changlen != $mmlen} {
		Inf "Tempo Changes ([expr $changlen - 1]) And Number Of MMs ($idealmm) Do Not Tally "
		if {$mmlen > $changlen} {
			set msg "Choose One Of These Tempi ($idealmm) ??"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				return 0
			}
			catch {unset tempochanges}
			WhichTempoToChoose $sndfnam
		} else {
			set idealmm [lindex $idealmm 0]
			unset tempochanges
			set msg "Revert To Single Tempo ($idealmm) ??"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				return 0
			}
			return 1
		}
	}
	return 1
}

#--- Choose among alternative tempi

proc WhichTempoToChoose {sndfnam} {
	global pr_idealtempo idealmm idealmm_choice evv

	set f .idealtempo
	if [Dlg_Create $f "CHOOSE A TEMPO" "set pr_idealtempo 0" -borderwidth $evv(BBDR)] {
		frame $f.0 -borderwidth $evv(BBDR)
		frame $f.1 -borderwidth $evv(BBDR)
		button $f.0.ok -text "Confirm Tempo" -command "set pr_idealtempo 1" -highlightbackground [option get . background {}]
		button $f.0.pl -text "Play Sound" -command "PlaySndfile $sndfnam 0" -highlightbackground [option get . background {}]
		pack $f.0.ok -side left		
		pack $f.0.pl -side right
		pack $f.0 -side top -fill x -expand true
		set len [llength $idealmm]
		set n 0
		while {$n < $len} {
			set val [lindex $idealmm $n]
			radiobutton $f.1.$n -text $val -value $val -variable idealmm_choice
			pack $f.1.$n -side left
			incr n
		}
		pack $f.1 -side top -pady 2
		wm resizable $f 1 1
		bind $f <Return> {set pr_idealtempo 1}
		bind $f <Escape> {set pr_idealtempo 0}
		bind $f <space>  "PlaySndfile $sndfnam 0"
	}
	set idealmm_choice 0
	raise $f
	update idletasks
	StandardPosition $f
	set pr_idealtempo 0 
	set finished 0
	My_Grab 0 $f pr_idealtempo
	while {!$finished} {
		tkwait variable pr_idealtempo
		if {$pr_idealtempo} {
			if {$idealmm_choice == 0} {
				Inf "No Tempo Chosen"
				continue
			}
			set idealmm $idealmm_choice
			break
		} else {
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

#--- Convert samptimes (from Sound View) to time in secs

proc Ideal_GetRealTimesFromSview {srate sndfnam} { 
	global ideal_realsamptimes ideal_realtimes evv
	SnackDisplay $evv(SN_TIMESLIST) realmarks 0 $sndfnam
	if {[info exists ideal_realsamptimes]} {
		foreach val $ideal_realsamptimes {
			set val [expr double($val)/$srate]
			lappend outvals $val
		}
		set ideal_realtimes $outvals
	}
}

proc IdealHelp {} {
	set msg "GENERATE IDEALISED RHYTHM MAP\n"
	append msg "\n"
	append msg "Generates datafile, associated with soundfile, describing map\n"
	append msg "FROM: actual timing of events within that soundfile.\n"
	append msg "TO:      idealised timing of events in \"rcode\" property.\n"
	append msg "\n"
	append msg "\"Outfile Tag\" is string added to name of input soundfile\n"
	append msg "to create the data outputfile name.\n"
	append msg "\n"
	append msg "ACTUAL TIMING of events can be extracted from \"motif\" property\n"
	append msg "if it exists AND if no. of motif events = no. of rhythm events.\n"
	append msg "If conditions met, button appears allowing use of motif-timings.\n"
	append msg "\n"
	append msg "Actual timing can be specified by marking attacks in \"Sound View\".\n"
	append msg "\n"
	append msg "The IDEALISED TIMING of events is displayed both as\n"
	append msg "(1)  Music notation graphic of rhythm (derived from \"rcode\" prop.)\n"
	append msg "(2)  Representation of each event as fraction of a crotchet beat.\n"
	append msg "         (Rests represented by negative values).\n"
	append msg "\n"
	append msg "First strong beat (at a bar start) is marked on the display.\n"
	append msg "Beat can be changed: click on a \"1st accent\" button on display.\n"
	append msg "\n"
	append msg "The beat-fractions can be changed, from buttons on display.\n"
	append msg "\n"
	append msg "IDEALISED TEMPO of sound, (may be more than 1 tempo).\n"
	append msg "    In output data, MM always assumed to be CROTCHETS per sec.\n"
	append msg "    If tempo in dotted-crotchets, use \"3/2\" button to adjust.\n"  
	append msg "    The \"2/3\" button does opposite transformation.\n"    
	append msg "    (If minims or quavers per sec, change fractional representation).\n"   
	append msg "\n"
	append msg "    Fraction vals can be doubled or halved, from buttons on display.\n"
	append msg "\n"
	append msg "For sounds generated (later) from output data to be syncd,\n"
	append msg "parameter \"Time of 1st accent\" = time where 1st accented event\n"
	append msg "is placed in output data (all other events shifted appropriately).\n"
	append msg "This ensures a set of sounds (see below), generated using datafiles,\n"
	append msg "will all synchronise at their first accented events.\n"
	append msg "\n"
	append msg "Where several datafiles are to be generated,\n"
	append msg "bearing in mind 1st accent may not be at start of soundfile,\n"
	append msg "offset should accomodate all possible accent positions in files\n"
	append msg "i.e. accent position should be >=  masimum distance in all files\n"
	append msg "between its 1st event and its 1st accented event.\n"
	append msg "\n"
	append msg "Output datafile can be used to generate soundfiles\n"
	append msg "derived from original soundfile, in which the key events\n"
	append msg "are synchronised to the idealised rhythm.\n"
	Inf $msg
}

#-----  Save and Load tag used for idealised-rhthm datafiles

proc SaveIdealTag {} {
	global idealtag evv
	set fnam [file join $evv(URES_DIR) idealtag$evv(CDP_EXT)]
	if [catch {open $fnam "w"} zit] {
		return 0
	}
	puts $zit $idealtag
	close $zit
	return 1
}

proc LoadIdealTag {} {
	global idealtag origidealtag evv
	set fnam [file join $evv(URES_DIR) idealtag$evv(CDP_EXT)]
	if {![file exists $fnam]} {
		return
	}
	if [catch {open $fnam "r"} zit] {
		return
	}
	gets $zit idealtag
	set origidealtag $idealtag
	close $zit
}

proc SaveIdealOffset {} {
	global idealoff evv
	set fnam [file join $evv(URES_DIR) idealoff$evv(CDP_EXT)]
	if [catch {open $fnam "w"} zit] {
		return 0
	}
	puts $zit $idealoff
	close $zit
	return 1
}

proc LoadIdealOffset {} {
	global idealoff origidealoff evv
	set fnam [file join $evv(URES_DIR) idealoff$evv(CDP_EXT)]
	if {![file exists $fnam]} {
		return
	}
	if [catch {open $fnam "r"} zit] {
		return
	}
	gets $zit idealoff
	set origidealoff $idealoff
	close $zit
}

proc ChangeIdealMM {how} {
	global idealmm origidealmm preround_idealmm
	switch -- $how {
		"up" {
			catch {unset preround_idealmm}
			set idealmm [expr $idealmm + 1.0]
		}
		"down" {
			catch {unset preround_idealmm}
			set k [expr $idealmm - 1.0]
			if {$k > 0} {
				set idealmm $k
			}
		}
		"round" {
			set preround_idealmm $idealmm
			set idealmm [expr int(round($idealmm))]
		}
		"unround" {
			if {[info exists preround_idealmm]} {
				set idealmm $preround_idealmm
			}
		}
		"restore" {
			catch {unset preround_idealmm}
			set idealmm $origidealmm
		}
	}
}

#-------- How many sounds in propsfile

proc PropsFileCount {} {
	global wl chlist props_info
	set i [$wl curselection]
	if {![info exists i] || ([llength $i] <= 0)} {
		if {[info exists chlist]} {
			if {[llength $chlist] > 1} {
				Inf "Select Just One Properties File"
				return
			}
			set i [LstIndx [lindex $chlist 0] $wl]
			$wl selection clear 0 end
			$wl selection set $i
		}
	}
	if {![info exists i] || ([llength $i] <= 0)} {
		Inf "No Workspace Files Selected"
		return
	} elseif {[llength $i] > 1} {
		Inf "Select Just One Properties File"
		return
	}
	Block "Checking Property File"
	set fnam [$wl get $i]
	if {![ThisIsAPropsFile $fnam 0 0]} {
		Inf "No Properties Files Selected"
		UnBlock
		return
	}
	UnBlock
	set sndcnt [llength [lindex $props_info 1]]
	Inf "There Are $sndcnt Sounds In This Property File"
}

#--- Merge Several Props Files having same properties, but different sounds

proc Merge_Many_Props {} {
	global pr_mergemanyprops propname propfiles_list new_manypropmergefile wstk wl chlist pa evv

	set ilist [$wl curselection]
	if {[llength $ilist] <= 0} {
		if {[info exists chlist]} {
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
	if {[llength $ilist] < 2} {
		Inf "Choose At Least Two Property Files"
		return
	}
	foreach i $ilist {
		set fnam [$wl get $i]
		if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
			Inf "Choose Property Files Only"
			return
		}
	}
	set msg "Property Files Will Be Merged In The Order You Have Listed Them: Is This OK ??"
	set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
	if {$choice == "no"} {
		return
	}
	set cnt 0
	set filecnt 0
	set total_linecnt 0
	foreach i $ilist {
		catch {unset propfile}
		set fname($filecnt) [$wl get $i]
		if {[info exists propfiles_list]} {
			set is_a_known_propfile [lsearch $propfiles_list $fname($filecnt)]
		} else {
			set is_a_known_propfile -1
		}
		if [catch {open $fname($filecnt) "r"} zit] {
			Inf "Cannot Open Text File '$fname($filecnt)'"
			return
		}
		while {[gets $zit line] >= 0} {
			lappend propfile $line
		}
		close $zit
		if {![info exists propfile]} {
			Inf "File $fname($filecnt) Is Empty"
			if {$is_a_known_propfile >= 0} {
				set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
			}
			return
		}
		if {[llength $propfile] < 2} {		;#	CANNOT BE A VALID PROPFILE
			Inf "$fname($filecnt) Is Not A Valid Properties File"
			if {$is_a_known_propfile >= 0} {
				set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
			}
			return
		}
		set linecnt 0
		foreach line $propfile {
			set this_propcnt 0
			catch {unset nuline}
			set line [string trim $line]
			set line [split $line]
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] > 0} {
					lappend nuline $item
					incr this_propcnt
				}
			}
			if {$this_propcnt > 0} {
				if {$linecnt == 0} {				;# FIRST LINE, SPECIAL CASE FOR PROPS FILES
					if {$filecnt == 0} {
						set propcnt $this_propcnt
						incr propcnt	;# lines to follow have filename, as well as props (if they're property files)
						set n 0
						foreach item $nuline {
							set propname($n) $item
							incr n
						}
						lappend nupropfile $nuline
					} else {
						incr this_propcnt
						if {$propcnt != $this_propcnt} {
							Inf "Number Of Properties Does Not Tally In Files $fname(0) ([expr $propcnt - 1]) And $fname($filecnt) ([expr $this_propcnt - 1])"
							return
						}
						set n 0
						foreach item $nuline {
							if {![string match $item $propname($n)]} {
								Inf "Different Properties In Files 1 And $fname($filecnt)"
								return
							}
							incr n
						}
					}
				} else {
					if {$propcnt != $this_propcnt} {
						if {$filecnt == 0} {
							Inf "Number Of Properties Incorrect On Line [expr $linecnt + 1] Of File $fname($filecnt)"
						} else {
							Inf "Number Of Properties Incorrect On Line [expr $linecnt + 2] Of File $fname($filecnt)"
						}
						if {$is_a_known_propfile >= 0} {
							set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
						}
						return
					}
					lappend nupropfile $nuline
				}
			}
			incr linecnt
		}
		if {$linecnt <= 0} {
			Inf "No Values Found In File $fname($filecnt)"
			if {$is_a_known_propfile >= 0} {
				set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
			}
			return
		}
		if {$is_a_known_propfile < 0} {
			AddToPropfilesList $fname($filecnt)
		}
		if {$filecnt == 0} {		
			set lines($filecnt) $linecnt
		} else {
			set lines($filecnt) [expr $linecnt - 1]		;#	Property names line from all files except first, is jettisoned
		}
		incr total_linecnt $lines($filecnt)
		incr filecnt
	}

	;#	COMPARE SOUNDS USED IN EACH FILE (MUST BE DIFFERENT)

	set filecnt_less_one [expr $filecnt - 1]
	set n 1									;#	Skip first line, as that is the property names line
	set thisfile 0
	set thisfile_end 0
	while {$thisfile < $filecnt_less_one} {
		incr thisfile_end $lines($thisfile)		;#	incr thisfile_end to end of thisfile lineset = first line of thisfile+1 lineset
		while {$n < $thisfile_end} {
			set snd0 [lindex [lindex $nupropfile $n] 0]
			set m $thisfile_end
			set nextfile [expr $thisfile + 1]							;#	Initially, file being compared is thisfile+1th
			set nextfile_end [expr $thisfile_end + $lines($nextfile)]	;#	End line from file thisfile+1 is set, so we know which file we're comparing
			while {$m < $total_linecnt} {
				if {$m >= $nextfile_end} {								;#	Eventually we will reach end of lines of file thisfile+n, so
					incr nextfile										;#	On reaching end of lines of file thisfile+n,
					if {$nextfile < $filecnt} {							;#	incr limit to end of lines of file thisfile+n+1
						incr nextfile_end $lines($nextfile)
					}
				}
				set snd1 [lindex [lindex $nupropfile $m] 0]
				if {[string match $snd0 $snd1]} {
					Inf "Property Files $fname($thisfile) And $fname($nextfile) Both Refer To The Same Sound $snd0"
					return
				}
				incr m
			}
			incr n
		}
		incr thisfile
	}
	set f .merge_manyprops
	if [Dlg_Create $f "MERGE PROPERTY FILES CONTAINING DIFFERENT SOUNDS" "set pr_mergemanyprops 0" -borderwidth $evv(BBDR)] {
		set f0 [frame $f.0 -borderwidth $evv(BBDR)]
		set f1 [frame $f.1 -borderwidth $evv(BBDR)]
		button $f0.quit -text "Close" -command {set pr_mergemanyprops 0} -highlightbackground [option get . background {}]
		button $f0.add  -text "Merge Property Files" -command {set pr_mergemanyprops 1} -highlightbackground [option get . background {}]
		pack $f0.add -side left
		pack $f0.quit -side right
		pack $f.0 -side top -fill x -expand true
		label $f1.ll -text "Name of new property file"
		entry $f1.name -textvariable new_manypropmergefile -width 20
		pack $f1.ll $f1.name -side left
		pack $f.1 -side top
		wm resizable $f 1 1
		bind $f <Escape> {set pr_mergemanyprops 0}
		bind $f <Return> {set pr_mergemanyprops 1}
	}
	set new_manypropmergefile ""
	set pr_mergemanyprops 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_mergemanyprops $f.1.name
	while {!$finished} {
		tkwait variable pr_mergemanyprops
		switch -- $pr_mergemanyprops {
			1 {
				if {[string length $new_manypropmergefile] <= 0} {
					Inf "No Name Entered For Output Property File"
					continue
				}
				set new_manypropmergefile [string tolower $new_manypropmergefile]
				set xxx [file rootname [file tail $new_manypropmergefile]]
				if {![string match $new_manypropmergefile $xxx]} {
					Inf "Extensions Or Pathnames Cannot Be Used Here"
					continue
				}
				set new_manypropmergefile $xxx
				set new_manypropmergefile [FixTxt $new_manypropmergefile "new filename"]
				if {[string length $new_manypropmergefile] <= 0} {
					continue
				}
		 		if {![ValidCdpFilename $new_manypropmergefile 1]} {
					continue
				}
				set this_ext [GetTextfileExtension props]
				set outfile $new_manypropmergefile$this_ext
				if [file exists $outfile] {
					Inf "File $outfile Already Exists.  Choose A Different Filename"
					continue
				}
				if [catch {open $outfile "w"} zit] {
					Inf "Cannot Open File $outfile To Write New Property List"
					continue
				}
				foreach line $nupropfile {
					puts $zit $line
				}
				close $zit
				FileToWkspace $outfile 0 0 0 0 1
				if {[info exists propfiles_list]} {
					set k [lsearch $propfiles_list $outfile]
					if {$k < 0} {
						lappend propfiles_list $outfile
					}
				} else {
					lappend propfiles_list $outfile
				}
				Inf "Property File $outfile Has Been Placed On The Workspace"
				break
			}
			0 {
				break
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#----  Remove passing notes from HF property used in PropsStats

proc DelPassingNotes {val} {
	set true_note 0
	set len [string length $val]
	set n 0
	while {$n < $len} {
		set item [string index $val $n]
		if {[string match $item "#"]} {
			if {$true_note} {				;#	If not at start, and not following a passing note
				append nuval $item			;#	Keep the sharp sign
			}
		} elseif {[regexp {[A-G]} $item]} {
			append nuval $item				;#	If not a passing note, keep item
			set true_note 1			
		} else {
			set true_note 0				;#	 IF passing note, mark as passing-note
		}
		incr n
	}
	return $nuval
}

#----  Help for PropsStats

proc HelpStats {} {
	set msg "STATISTICS ON PROPERTY VALUES IN PROPERTIES FILE\n"
	append msg "\n"
	append msg "On this page you can select the name of a property\n"
	append msg "(displayed in the window when you begin)\n"
	append msg "and then discover how frequently that value occurs\n"
	append msg "in the property file(s) you have selected.\n"
	append msg "\n"
	append msg "You can choose NOT to generate statistics on items\n"
	append msg "that occur infrequently, using the Up & Down Arrow Keys\n"
	append msg "to change the \"min frq of occurence to list\" value.\n"
	append msg "\n"
	append msg "With some properties, extra facilities are available\n"
	append msg "via the \"Subgroups\" button, which appears (only)\n"
	append msg "when the following properties are selected.\n"
	append msg "\n"
	append msg "(1) \"HF\" : If the Harmonic Field property (\"HF\") is selected\n"
	append msg "              you can get statistics on subsets of the Harmonic Fields.\n"
	append msg "              i.e. statistics on every 2, 3,...N -note grouping\n"
	append msg "              occuring WITHIN the Harmonic Fields.\n"
	append msg "\n"
	append msg "(2) \"text\" : If the Text property (\"text\") is selected\n"
	append msg "              you can get statistics on subphrases of the texts.\n"
	append msg "              i.e. on every 1,2,3,...N word phrase\n"
	append msg "              occuring WITHIN the Text property data.\n"
	append msg "\n"
	append msg "In these cases, the (minimum and maximum) size of the subgroups\n"
	append msg "can be set in the entry boxes which appear,\n"
	append msg "using the Left & Right Arrow keys.\n"
	append msg "\n"
	append msg "In these cases, also, you can save the lists of soundfiles\n"
	append msg "associated with each subgroup, using the \"Save Sndlists\" button\n"
	append msg "(which will appear once the stats have been generated).\n"
	append msg "\n"
	Inf $msg
}

#----  Change the limits of the size of subgroups being searched for in PropsStats

proc IncrPropSub {down max} {
	global propsubmin propsubmax
	if {$max} {
		if {$down} {
			if {$propsubmax > $propsubmin} {
				incr propsubmax -1
			}
		} else {
			incr propsubmax
		}
	} else {
		if {$down} {
			if {$propsubmin > 1} {
				incr propsubmin -1
			}
		} elseif {$propsubmin < $propsubmax} {
 			incr propsubmin
		}
	}
}

#----  Change the miniumum frq-of-occurence of stats to be listed in PropsStats

proc IncrPropFrq {down} {
	global propfrqmin
	if {$down} {
		if {$propfrqmin > 1} {
			incr propfrqmin -1
		}
	} else {
		incr propfrqmin
	}
}

#--- Get the statistics on a particular property, for PropsStats

proc DoStatsOnProp {fnams} {
	global propstatorder propstatname ditchbrackets proporderednames psval psvalfnams wstk 
	global lastpropstatname lastpropstatorder laststatpropvals laststatpropfnams

	set propstatname [string trim $propstatname]
	set calc_propstats 1
	if {[info exists lastpropstatname] && [string match $propstatname $lastpropstatname]} {
		if {[string match $propstatorder $lastpropstatorder]} {
			return 1
		} else {
			set calc_propstats 0
		}
	}
	set statpropvals {}
	if {[string length $propstatname] <= 0} {
		Inf "No Property Name Entered"
		return 0
	}
	Block "Doing Statistics"
	if {$calc_propstats} {
		if {[string match $propstatname "HF"]} {
			set msg "Include Passing Notes ??"
			set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				set delete_passing 1
			}
		} elseif {[string match -nocase $propstatname "text"]} {
			set separate_text 1
		}
		catch {unset badfiles1}
		catch {unset badfiles2}
		catch {unset proporderednames}
		catch {unset propstatpos}
		set n 0
		foreach fnam $fnams {
			if [catch {open $fnam "r"} zit] {
				lappend badfiles1 $n
				incr n
				continue
			}
			set cnt 0
			while {[gets $zit line] >= 0} {
				catch {unset nuline}
				set line [string trim $line]
				if {[string length $line] <= 0} {
					continue
				}
				set line [split $line]
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] > 0} {
						lappend nuline $item
					}
				}
				if {![info exists nuline]} {
					continue
				}
				break
			}
			close $zit
			if {![info exists nuline]} {
				lappend badfiles1 $n
				incr n
				continue
			}
			set k [lsearch $nuline $propstatname] 
			if {$k < 0} {
				lappend badfiles2 $n
			} else {
				lappend propstatpos $k
			}
			incr n
		}
		if {[info exists badfiles1] || [info exists badfiles2]} {
			set badfiles {}
			if {[info exists badfiles1]} {
				if {[llength $badfiles1] == [llength $fnams]} {
					Inf "None Of These Files Could Be Opened"
					UnBlock
					return 0
				} else {
					set msg "The Files\n"
					foreach fnam $badfiles1 {
						append msg $fnam "\n"
					}
					append msg "Could Not Be Opened: Continue With The Others ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						UnBlock
						return 0
					}
				}
				set badfiles [concat $badfiles $badfiles1]
			}
			if {[info exists badfiles2]} {
				if {[llength $badfiles2] == [llength $fnams]} {
					Inf "None Of These Files Contain The Property '$propstatname'"
						UnBlock
					return 0
				} else {
					set msg "The Files\n"
					foreach fnam $badfiles2 {
						append msg $fnam "\n"
					}
					append msg "Do Not Use The Property '$propstatname' : Continue To Process The Others ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						UnBlock
						return 0
					}
				}
				set badfiles [concat $badfiles $badfiles2]
			}
			set badfiles [lsort -decreasing $badfiles]
			foreach n $badfiles {
				set fnams [lreplace $fnams $n $n]
			}
		}
		foreach fnam $fnams pos $propstatpos {
			incr pos
			if [catch {open $fnam "r"} zit] {
				Inf "Failed To Reopen File '$fnam'"
				UnBlock
				return 0
			}
			set linecnt 0
			while {[gets $zit line] >= 0} {
				catch {unset nuline}
				set line [string trim $line]
				if {[string length $line] <= 0} {
					continue
				}
				set line [split $line]
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] > 0} {
						lappend nuline $item
					}
				}
				if {![info exists nuline]} {
					continue
				}
				if {$linecnt > 0} {
					set val [lindex $nuline $pos]
					if {![string match $val "-"]} {
						if {[info exists delete_passing]} {
								lappend statpropvals [DelPassingNotes $val]
								lappend statpropfnams [lindex $nuline 0]
							} elseif {[info exists separate_text]} {
								set vals [split [string tolower $val] "_"]
								set statpropvals [concat $statpropvals $vals]
								set k 0
								while {$k < [llength $vals]} {
									lappend statpropfnams [lindex $nuline 0]
									incr k
								}
							} else {
								lappend statpropvals $val
								lappend statpropfnams [lindex $nuline 0]
							}
						}
					}
				incr linecnt
			}
			close $zit
		}					
		if {[llength $statpropvals] == 0} {
			Inf "Failed To Find Any Values For Property '$propstatname'"
			UnBlock
			return 0
		}
	} else {
		set statpropvals  $laststatpropvals
		set statpropfnams $laststatpropfnams
	}
	wm title .blocker "PLEASE WAIT :         CALCULATING STATISTICS"
	catch {unset badvals}
	catch {unset goodvals}
	catch {unset psval}
	switch -- $propstatorder {
		"alpha" {
			foreach val $statpropvals {
				if {![regexp {[A-Za-z]} $val]} {
					set badvals 1
				} else {
					set goodvals 1
				}
			}
			if {![info exists goodvals]} {
				Inf "No Alphabetic Values Found"
				UnBlock
				return 0
			}
			if {[info exists badvals]} {
				set msg "Some Values Are Not Alphabetic: Proceed Anyway ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					UnBlock
					return 0
				}
			}
			foreach val $statpropvals fnam $statpropfnams {
				if {[regexp {[A-Za-z]} $val]} {
					set vals [split $val ","]
					foreach value $vals {
						if {[string first "(" $value] >= 0} {
							if {$ditchbrackets} {
								continue
							} else {
								set value [RemoveBrackets $value]
							}
						}
						if {[string length $value] > 0} {
							if {![info exists psval($value)]} {
								set psval($value) 1
								set psvalfnams($value) $fnam
							} else {
								incr psval($value)
								if {[lsearch $psvalfnams($value) $fnam] < 0} {
									lappend psvalfnams($value) $fnam
								}
							}
						}
					}
				}
			}
		}
		"numeric" {
			foreach val $statpropvals {
				if {![regexp {[0-9]} $val]} {
					set badvals 1
				} else {
					set goodvals 1
				}
			}
			if {![info exists goodvals]} {
				Inf "No Numeric Values Found"
				UnBlock
				return 0
			}
			if {[info exists badvals]} {
				set msg "Some Values Are Not Numeric: Proceed Anyway ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					UnBlock
					return 0
				}
			}
			foreach val $statpropvals fnam $statpropfnams {
				if {[regexp {[0-9]} $val]} {
					set vals [split $val ","]
					foreach value $vals {
						if {[string first "(" $value] >= 0} {
							if {$ditchbrackets} {
								continue
							} else {
								set value [RemoveBrackets $value]
							}
						}
						if {[string length $value] > 0} {
							if {![info exists psval($value)]} {
								set psval($value) 1
								set psvalfnams($value) $fnam
							} else {
								incr psval($value)
								lappend psvalfnams($value) $fnam
							}
						}
					}
				}
			}
		}
		"frq" {
			foreach val $statpropvals fnam $statpropfnams {
				set vals [split $val ","]
				foreach value $vals {
					if {[string first "(" $value] >= 0} {
						if {$ditchbrackets} {
							continue
						} else {
							set value [RemoveBrackets $value]
						}
					}
					if {[string length $value] > 0} {
						if {![info exists psval($value)]} {
							set psval($value) 1
							set psvalfnams($value) $fnam
						} else {
							incr psval($value)
							lappend psvalfnams($value) $fnam
						}
					}
				}
			}
		}
	}
	set lastpropstatname $propstatname
	set lastpropstatorder $propstatorder
	set laststatpropvals $statpropvals
	set laststatpropfnams $statpropfnams
	UnBlock
	return 1
}

#--- are selected sounds in selected propfile??

proc SndsInPropsfile {} {
	global wl chlist propfiles_list pa evv old_props_protocol propfile propcnt 
	catch {unset propfile}
	set i [$wl curselection]
	if {$i < 0} {
		if {[info exists chlist]} {
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
				set i [$wl curselection]
			}
		}
	}
	if {[string length $i] <= 0} {
		Inf "No File Selected"
		return
	}
	if {[llength $i] < 2} {
		Inf "Choose Just One Property File And At Least One Soundfile"
		return
	}
	catch {unset propfile}
	set bigmsg "Choose Only One (User-Property) Textfile & Some Soundfiles\n\nOr\n\nOne Property File And A Textfile Listing Those Soundfiles"
	set got_sounddir 0
	set got_propfile 0
	set got_sndlist 0
	set ilist $i
	Block "Checking Files"
	foreach i $ilist {
		set fnam [$wl get $i]
		if {$pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)} {
			if {[IsASndlist $pa($fnam,$evv(FTYP))]} {
				if {[info exists in_sndfiles]} {
					Inf $bigmsg
					UnBlock
					return
				}
				if [catch {open $fnam "r"} zit] {
					Inf "Cannot Open Text File '$fnam'"
					UnBlock
					return
				}
				while {[gets $zit sfnam] >= 0} {
					if {[string match $sfnam [file tail $sfnam]]} {
						Inf "Soundfile $sfnam Is Not Backed Up To A Directory"
						close $zit
						UnBlock
						return
					}
					lappend in_sndfiles $sfnam
				}
				close $zit
				if {[llength $ilist] > 2} {
					Inf $bigmsg
					UnBlock
					return
				}
				set got_sndlist 1
				if {$got_propfile} {
					break
				} else {
					continue
				}
			}
			if {$got_propfile} {					;#	IF ALREADY FOUND A PROPFILE
				Inf $bigmsg
				UnBlock
				return
			}
			if {![info exists propfiles_list]} {
				set is_a_known_propfile -1
			} else {
				set is_a_known_propfile [lsearch $propfiles_list $fnam]
			}
			if [catch {open $fnam "r"} zit] {
				Inf "Cannot Open Text File '$fnam'"
				UnBlock
				return
			}
			while {[gets $zit line] >= 0} {
				lappend propfile $line
			}
			if {![info exists propfile]} {
				Inf "File $fnam Is Empty"
				if {$is_a_known_propfile >= 0} {
					set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
				}
				close $zit
				UnBlock
				return
			}
			if {[llength $propfile] < 2} {
				Inf "$fnam Is Not A Valid Properties File"
				if {$is_a_known_propfile >= 0} {
					set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
				}
				close $zit
				UnBlock
				return
			}
			set orig_propfile_name $fnam
			close $zit
			set linecnt 0
			set propcnt 0
			foreach line $propfile {
				set this_propcnt 0
				catch {unset nuline}
				set line [string trim $line]
				set line [split $line]
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] > 0} {
						lappend nuline $item
						incr this_propcnt
					}
				}
				if {$this_propcnt > 0} {
					if {$linecnt == 0} {			;# FIRST LINE, SPECIAL CASE FOR PROPS FILES
						set propcnt $this_propcnt
						incr propcnt	;# lines to follow have filename, as well as props (if they're property files)
					} elseif {$propcnt != $this_propcnt} {
						Inf "Number Of Properties Incorrect On Line [expr $linecnt + 1]"
						if {$is_a_known_propfile >= 0} {
							set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
						}
						UnBlock
						return
					} else {
						set z_fnam [lindex $nuline 0]
						if {$old_props_protocol} {
							if {![string match $z_fnam [file tail $z_fnam]]} {
								Inf "Sound File Directories Found In File: Will Not Work With Old Protocol"
								if {$is_a_known_propfile >= 0} {
									set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
								}
								UnBlock
								return
							}
						} else { 
							if {[string match $z_fnam [file tail $z_fnam]]} {
								Inf "Sounds Without Directory Paths Found: Will Not Work With New Protocol"
								if {$is_a_known_propfile >= 0} {
									set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
								}
								UnBlock
								return
							}
						}
						lappend p_sndfiles $z_fnam
					}
					lappend nupropfile $nuline
					incr linecnt 
				}
			}
			if {$linecnt <= 0} {
				Inf "No Values Found In File"
				if {$is_a_known_propfile >= 0} {
					set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
				}
				UnBlock
				return
			}
			if {$propcnt > 21} {
				Inf "Cannot Handle More Than 20 Properties: Ignoring Other Properties"
				catch {unset propfile}

				set line [lrange [lindex $nupropfile 0] 0 19]
				lappend propfile $line
			
				foreach line [lrange $nupropfile 1 end] {
					set line [lrange $line 0 20]
					lappend propfile $line
				}
				set nupropfile $propfile
				set propcnt 21
			}
			set propfile [lrange $nupropfile 1 end]
			incr linecnt -1
			if {$linecnt <= 0} {
				Inf "No Properties (Only Property Names) Found In File"
				if {$is_a_known_propfile >= 0} {
					set propfiles_list [lreplace $propfiles_list $is_a_known_propfile $is_a_known_propfile]
				}
				UnBlock
				return
			}
			set got_propfile 1
			if {$is_a_known_propfile < 0} {		;# IF file not previously known as a propfile, add it to list of known profiles
				AddToPropfilesList $fnam
			}
			set this_propfile $fnam
			if {$got_sndlist} {
				if {[llength $ilist] > 2} {
					Inf $bigmsg
					UnBlock
					return
				} else {
					break
				}
			}
		} elseif {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
			Inf $bigmsg
			UnBlock
			return
		} else {
			if {[string match $fnam [file tail $fnam]]} {
				Inf "Soundfile $fnam Is Not Backed Up To A Directory"
				UnBlock
				return
			}
			lappend in_sndfiles $fnam
		}
	}
	foreach insnd $in_sndfiles {
		set gotit 0
		foreach psnd $p_sndfiles {
			if {[string match $insnd $psnd]} {
				set gotit 1
				break
			}
		}
		if {!$gotit} {
			lappend notinp $insnd
		}
	}
	UnBlock
	if {[info exists notinp]} {
		if {[llength $notinp] == [llength $in_sndfiles]} {
			set msg "None Of These Sounds Are In The Properties File [file rootname [file tail $this_propfile]]\n"
		} else {
			set cnt 0
			set msg "The Following Sounds Are Not In The Properties File [file rootname [file tail $this_propfile]]\n"
			foreach fnam $notinp {
				append msg "[file rootname [file tail $fnam]]\n"
				incr cnt
				if {$cnt >= 20} {
					append msg "AND MORE\n"
					break
				}
			}
		}
	} else {
		set msg "All These Sounds Are In The Properties File [file rootname [file tail $this_propfile]]\n"
	}
	Inf $msg
}

proc Motif_to_HF {args} {
	global adp_props_list tp_props_list nuaddpval evv
	set lineno [expr [lindex $args 0] - 1]	;#	Index of line nos is from 1 (as prop names are on line 0), index of props is from 0
	set propno [lindex $args 1]
	set propnames [lrange $args 2 end]
	set mpropno [lsearch $propnames motif]
	if {$mpropno < 0} {
		Inf "No \"motif\" properties exist"
		return
	}
	incr mpropno							;#	Skip soundname in listing
	set props_line [lindex $adp_props_list $lineno]
	set val [lindex $props_line $mpropno]
	if {![string match $val "yes"]} {
		Inf "No \"motif\" property exists for this sound"
		return
	}
	set fnam [lindex [lindex $tp_props_list $lineno] 0]
	set fnam [file rootname $fnam]
	append fnam _flt$evv(TEXT_EXT)
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot open motif data file $fnam to read motif : $zit"
		return
	}
	set midivals {}
	while {[gets $zit line] >= 0} {	
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		set line [split $line]
		set cnt 0
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] < 0} {
				continue
			}
			if {$cnt == 1} {
				set thismidi [expr int(round($item))]
				set thismidi [expr $thismidi % 12]
				set thismidi [expr $thismidi + 60]
				if {[lsearch $midivals $thismidi] < 0} {
					lappend midivals $thismidi
				}
			}
			incr cnt
		}
	}
	close $zit
	if {![info exists midivals] || ([llength $midivals] < 0)} {
		Inf "No data found in motif data file [file tail $fnam]"
		return
	}
	set midivals [lsort -integer -increasing $midivals]
	set len [llength $midivals]
	set k 0
	set hfstring ""
	while {$k < $len} {
		set val [lindex $midivals $k]
		switch -- $val {
			60 {	append hfstring "C"  }
			61 {	append hfstring "C#" }
			62 {	append hfstring "D"  }
			63 {	append hfstring "D#" }
			64 {	append hfstring "E"  }
			65 {	append hfstring "F"  }
			66 {	append hfstring "F#" }
			67 {	append hfstring "G"  }
			68 {	append hfstring "G#" }
			69 {	append hfstring "A"  }
			70 {	append hfstring "A#" }
			71 {	append hfstring "B"  }
		}
		incr k
	}
	set nuaddpval $hfstring
}

#--- Put motif-data files in bakup log, if they are not in CDP base directory

proc UpdateBakLogWithMotifFiles {delletes outfnamseq outfnamfrq outfnamflt} {

	if {[lsearch $delletes $outfnamseq] >= 0} {
		UpdateBakupLog $outfnamseq modify 0
	} else {
		UpdateBakupLog $outfnamseq create 0
	}
	if {[lsearch $delletes $outfnamfrq] >= 0} {
		UpdateBakupLog $outfnamfrq modify 0
	} else {
		UpdateBakupLog $outfnamfrq create 0
	}
	if {[lsearch $delletes $outfnamflt] >= 0} {
		UpdateBakupLog $outfnamflt modify 1
	} else {
		UpdateBakupLog $outfnamflt create 1			;#	Finally write data to bakuplog file
	}
}


#---- Creates full-size keyboard with central octave active to play, and other keys sending MIDI values to linked window

proc MakeBigKeyboard {f} {
	global nuaddpval evv

	label $f.00 -text "Blue range keys play sound" -fg $evv(SPECIAL)
	pack $f.00 -side top -pady 2
	frame $f.0 -height 1 -bg black
	frame $f.1 -height 12
	frame $f.2 -height 12
	frame $f.3 -height 1 -bg black

	frame $f.1.00 -width 1 -height 12 -bg black
	frame $f.1.01 -width 7 -height 12 -bg white
	frame $f.1.02 -width 7 -height 12 -bg black
	frame $f.1.03 -width 7 -height 12 -bg white

	frame $f.1.11  -width 1 -height 12 -bg black
	frame $f.1.12  -width 7 -height 12 -bg pink
	frame $f.1.13  -width 7 -height 12 -bg black
	frame $f.1.14  -width 4 -height 12 -bg white
	frame $f.1.15  -width 7 -height 12 -bg black
	frame $f.1.16  -width 7 -height 12 -bg white
	frame $f.1.17 -width 1 -height 12 -bg black
	frame $f.1.18 -width 7 -height 12 -bg white
	frame $f.1.19 -width 7 -height 12 -bg black
	frame $f.1.1a -width 4 -height 12 -bg white
	frame $f.1.1b -width 7 -height 12 -bg black
	frame $f.1.1c -width 4 -height 12 -bg white
	frame $f.1.1d -width 7 -height 12 -bg black
	frame $f.1.1e -width 7 -height 12 -bg white

	frame $f.1.21  -width 1 -height 12 -bg black
	frame $f.1.22  -width 7 -height 12 -bg pink
	frame $f.1.23  -width 7 -height 12 -bg black
	frame $f.1.24  -width 4 -height 12 -bg white
	frame $f.1.25  -width 7 -height 12 -bg black
	frame $f.1.26  -width 7 -height 12 -bg white
	frame $f.1.27 -width 1 -height 12 -bg black
	frame $f.1.28 -width 7 -height 12 -bg white
	frame $f.1.29 -width 7 -height 12 -bg black
	frame $f.1.2a -width 4 -height 12 -bg white
	frame $f.1.2b -width 7 -height 12 -bg black
	frame $f.1.2c -width 4 -height 12 -bg white
	frame $f.1.2d -width 7 -height 12 -bg black
	frame $f.1.2e -width 7 -height 12 -bg white

	frame $f.1.31  -width 1 -height 12 -bg black
	frame $f.1.32  -width 7 -height 12 -bg pink
	frame $f.1.33  -width 7 -height 12 -bg black
	frame $f.1.34  -width 4 -height 12 -bg white
	frame $f.1.35  -width 7 -height 12 -bg black
	frame $f.1.36  -width 7 -height 12 -bg white
	frame $f.1.37 -width 1 -height 12 -bg black
	frame $f.1.38 -width 7 -height 12 -bg white
	frame $f.1.39 -width 7 -height 12 -bg black
	frame $f.1.3a -width 4 -height 12 -bg white
	frame $f.1.3b -width 7 -height 12 -bg black
	frame $f.1.3c -width 4 -height 12 -bg white
	frame $f.1.3d -width 7 -height 12 -bg black
	frame $f.1.3e -width 7 -height 12 -bg white

	frame $f.1.41  -width 1 -height 12 -bg black
	frame $f.1.42  -width 7 -height 12 -bg red
	frame $f.1.43  -width 7 -height 12 -bg black
	frame $f.1.44  -width 4 -height 12 -bg white
	frame $f.1.45  -width 7 -height 12 -bg black
	frame $f.1.46  -width 7 -height 12 -bg white
	frame $f.1.47 -width 1 -height 12 -bg black
	frame $f.1.48 -width 7 -height 12 -bg white
	frame $f.1.49 -width 7 -height 12 -bg black
	frame $f.1.4a -width 4 -height 12 -bg white
	frame $f.1.4b -width 7 -height 12 -bg black
	frame $f.1.4c -width 4 -height 12 -bg white
	frame $f.1.4d -width 7 -height 12 -bg black
	frame $f.1.4e -width 7 -height 12 -bg white

	frame $f.1.51  -width 1 -height 12 -bg black
	frame $f.1.52  -width 7 -height 12 -bg pink
	frame $f.1.53  -width 7 -height 12 -bg black
	frame $f.1.54  -width 4 -height 12 -bg white
	frame $f.1.55  -width 7 -height 12 -bg black
	frame $f.1.56  -width 7 -height 12 -bg white
	frame $f.1.57 -width 1 -height 12 -bg black
	frame $f.1.58 -width 7 -height 12 -bg white
	frame $f.1.59 -width 7 -height 12 -bg black
	frame $f.1.5a -width 4 -height 12 -bg white
	frame $f.1.5b -width 7 -height 12 -bg black
	frame $f.1.5c -width 4 -height 12 -bg white
	frame $f.1.5d -width 7 -height 12 -bg black
	frame $f.1.5e -width 7 -height 12 -bg white

	frame $f.1.61  -width 1 -height 12 -bg black
	frame $f.1.62  -width 7 -height 12 -bg pink
	frame $f.1.63  -width 7 -height 12 -bg black
	frame $f.1.64  -width 4 -height 12 -bg white
	frame $f.1.65  -width 7 -height 12 -bg black
	frame $f.1.66  -width 7 -height 12 -bg white
	frame $f.1.67 -width 1 -height 12 -bg black
	frame $f.1.68 -width 7 -height 12 -bg white
	frame $f.1.69 -width 7 -height 12 -bg black
	frame $f.1.6a -width 4 -height 12 -bg white
	frame $f.1.6b -width 7 -height 12 -bg black
	frame $f.1.6c -width 4 -height 12 -bg white
	frame $f.1.6d -width 7 -height 12 -bg black
	frame $f.1.6e -width 7 -height 12 -bg white

	frame $f.1.71  -width 1 -height 12 -bg black
	frame $f.1.72  -width 7 -height 12 -bg pink
	frame $f.1.73  -width 7 -height 12 -bg black
	frame $f.1.74  -width 4 -height 12 -bg white
	frame $f.1.75  -width 7 -height 12 -bg black
	frame $f.1.76  -width 7 -height 12 -bg white
	frame $f.1.77 -width 1 -height 12 -bg black
	frame $f.1.78 -width 7 -height 12 -bg white
	frame $f.1.79 -width 7 -height 12 -bg black
	frame $f.1.7a -width 4 -height 12 -bg white
	frame $f.1.7b -width 7 -height 12 -bg black
	frame $f.1.7c -width 4 -height 12 -bg white
	frame $f.1.7d -width 7 -height 12 -bg black
	frame $f.1.7e -width 7 -height 12 -bg white

	frame $f.1.80 -width 1  -height 12 -bg black
	frame $f.1.81 -width 10 -height 12 -bg pink
	frame $f.1.82 -width 1  -height 12 -bg black

	pack $f.1.00 $f.1.01 $f.1.02 $f.1.03 -side left
	pack $f.1.11  $f.1.12  $f.1.13  $f.1.14  $f.1.15  $f.1.16  $f.1.17 $f.1.18 $f.1.19 $f.1.1a $f.1.1b $f.1.1c $f.1.1d $f.1.1e -side left
	pack $f.1.21  $f.1.22  $f.1.23  $f.1.24  $f.1.25  $f.1.26  $f.1.27 $f.1.28 $f.1.29 $f.1.2a $f.1.2b $f.1.2c $f.1.2d $f.1.2e -side left
	pack $f.1.31  $f.1.32  $f.1.33  $f.1.34  $f.1.35  $f.1.36  $f.1.37 $f.1.38 $f.1.39 $f.1.3a $f.1.3b $f.1.3c $f.1.3d $f.1.3e -side left
	pack $f.1.41  $f.1.42  $f.1.43  $f.1.44  $f.1.45  $f.1.46  $f.1.47 $f.1.48 $f.1.49 $f.1.4a $f.1.4b $f.1.4c $f.1.4d $f.1.4e -side left
	pack $f.1.51  $f.1.52  $f.1.53  $f.1.54  $f.1.55  $f.1.56  $f.1.57 $f.1.58 $f.1.59 $f.1.5a $f.1.5b $f.1.5c $f.1.5d $f.1.5e -side left
	pack $f.1.61  $f.1.62  $f.1.63  $f.1.64  $f.1.65  $f.1.66  $f.1.67 $f.1.68 $f.1.69 $f.1.6a $f.1.6b $f.1.6c $f.1.6d $f.1.6e -side left
	pack $f.1.71  $f.1.72  $f.1.73  $f.1.74  $f.1.75  $f.1.76  $f.1.77 $f.1.78 $f.1.79 $f.1.7a $f.1.7b $f.1.7c $f.1.7d $f.1.7e -side left
	pack $f.1.80  $f.1.81  $f.1.82 -side left

	frame $f.2.00 -width 1  -height 8 -bg black
	frame $f.2.01 -width 10 -height 8 -bg white
	frame $f.2.02 -width 1  -height 8 -bg black
	frame $f.2.03 -width 10 -height 8 -bg white

	frame $f.2.11 -width 1  -height 8 -bg black
	frame $f.2.12 -width 10 -height 8 -bg pink
	frame $f.2.13 -width 1  -height 8 -bg black
	frame $f.2.14 -width 10 -height 8 -bg white
	frame $f.2.15 -width 1  -height 8 -bg black
	frame $f.2.16 -width 10 -height 8 -bg white
	frame $f.2.17 -width 1  -height 8 -bg black
	frame $f.2.18 -width 10 -height 8 -bg white
	frame $f.2.19 -width 1  -height 8 -bg black
	frame $f.2.1a -width 10 -height 8 -bg white
	frame $f.2.1b -width 1  -height 8 -bg black
	frame $f.2.1c -width 10 -height 8 -bg white
	frame $f.2.1d -width 1  -height 8 -bg black
	frame $f.2.1e -width 10 -height 8 -bg white

	frame $f.2.21 -width 1  -height 8 -bg black
	frame $f.2.22 -width 10 -height 8 -bg pink
	frame $f.2.23 -width 1  -height 8 -bg black
	frame $f.2.24 -width 10 -height 8 -bg white
	frame $f.2.25 -width 1  -height 8 -bg black
	frame $f.2.26 -width 10 -height 8 -bg white
	frame $f.2.27 -width 1  -height 8 -bg black
	frame $f.2.28 -width 10 -height 8 -bg white
	frame $f.2.29 -width 1  -height 8 -bg black
	frame $f.2.2a -width 10 -height 8 -bg white
	frame $f.2.2b -width 1  -height 8 -bg black
	frame $f.2.2c -width 10 -height 8 -bg white
	frame $f.2.2d -width 1  -height 8 -bg black
	frame $f.2.2e -width 10 -height 8 -bg white

	frame $f.2.31 -width 1  -height 8 -bg black
	frame $f.2.32 -width 10 -height 8 -bg pink
	frame $f.2.33 -width 1  -height 8 -bg black
	frame $f.2.34 -width 10 -height 8 -bg white
	frame $f.2.35 -width 1  -height 8 -bg black
	frame $f.2.36 -width 10 -height 8 -bg white
	frame $f.2.37 -width 1  -height 8 -bg black
	frame $f.2.38 -width 10 -height 8 -bg white
	frame $f.2.39 -width 1  -height 8 -bg black
	frame $f.2.3a -width 10 -height 8 -bg white
	frame $f.2.3b -width 1  -height 8 -bg black
	frame $f.2.3c -width 10 -height 8 -bg white
	frame $f.2.3d -width 1  -height 8 -bg black
	frame $f.2.3e -width 10 -height 8 -bg white

	frame $f.2.41 -width 1  -height 8 -bg black
	frame $f.2.42 -width 10 -height 8 -bg red
	frame $f.2.43 -width 1  -height 8 -bg black
	frame $f.2.44 -width 10 -height 8 -bg "light blue"
	frame $f.2.45 -width 1  -height 8 -bg black
	frame $f.2.46 -width 10 -height 8 -bg "light blue"
	frame $f.2.47 -width 1  -height 8 -bg black
	frame $f.2.48 -width 10 -height 8 -bg "light blue"
	frame $f.2.49 -width 1  -height 8 -bg black
	frame $f.2.4a -width 10 -height 8 -bg "light blue"
	frame $f.2.4b -width 1  -height 8 -bg black
	frame $f.2.4c -width 10 -height 8 -bg "light blue"
	frame $f.2.4d -width 1  -height 8 -bg black
	frame $f.2.4e -width 10 -height 8 -bg "light blue"

	frame $f.2.51 -width 1  -height 8 -bg black
	frame $f.2.52 -width 10 -height 8 -bg pink
	frame $f.2.53 -width 1  -height 8 -bg black
	frame $f.2.54 -width 10 -height 8 -bg white
	frame $f.2.55 -width 1  -height 8 -bg black
	frame $f.2.56 -width 10 -height 8 -bg white
	frame $f.2.57 -width 1  -height 8 -bg black
	frame $f.2.58 -width 10 -height 8 -bg white
	frame $f.2.59 -width 1  -height 8 -bg black
	frame $f.2.5a -width 10 -height 8 -bg white
	frame $f.2.5b -width 1  -height 8 -bg black
	frame $f.2.5c -width 10 -height 8 -bg white
	frame $f.2.5d -width 1  -height 8 -bg black
	frame $f.2.5e -width 10 -height 8 -bg white

	frame $f.2.61 -width 1  -height 8 -bg black
	frame $f.2.62 -width 10 -height 8 -bg pink
	frame $f.2.63 -width 1  -height 8 -bg black
	frame $f.2.64 -width 10 -height 8 -bg white
	frame $f.2.65 -width 1  -height 8 -bg black
	frame $f.2.66 -width 10 -height 8 -bg white
	frame $f.2.67 -width 1  -height 8 -bg black
	frame $f.2.68 -width 10 -height 8 -bg white
	frame $f.2.69 -width 1  -height 8 -bg black
	frame $f.2.6a -width 10 -height 8 -bg white
	frame $f.2.6b -width 1  -height 8 -bg black
	frame $f.2.6c -width 10 -height 8 -bg white
	frame $f.2.6d -width 1  -height 8 -bg black
	frame $f.2.6e -width 10 -height 8 -bg white

	frame $f.2.71 -width 1  -height 8 -bg black
	frame $f.2.72 -width 10 -height 8 -bg pink
	frame $f.2.73 -width 1  -height 8 -bg black
	frame $f.2.74 -width 10 -height 8 -bg white
	frame $f.2.75 -width 1  -height 8 -bg black
	frame $f.2.76 -width 10 -height 8 -bg white
	frame $f.2.77 -width 1  -height 8 -bg black
	frame $f.2.78 -width 10 -height 8 -bg white
	frame $f.2.79 -width 1  -height 8 -bg black
	frame $f.2.7a -width 10 -height 8 -bg white
	frame $f.2.7b -width 1  -height 8 -bg black
	frame $f.2.7c -width 10 -height 8 -bg white
	frame $f.2.7d -width 1  -height 8 -bg black
	frame $f.2.7e -width 10 -height 8 -bg white

	frame $f.2.80 -width 1  -height 8 -bg black
	frame $f.2.81 -width 10 -height 8 -bg pink
	frame $f.2.82 -width 1  -height 8 -bg black

	pack $f.2.00 $f.2.01 $f.2.02 $f.2.03 -side left
	pack $f.2.11 $f.2.12 $f.2.13 $f.2.14 $f.2.15 $f.2.16 $f.2.17 $f.2.18 $f.2.19 $f.2.1a $f.2.1b $f.2.1c $f.2.1d $f.2.1e -side left
	pack $f.2.21 $f.2.22 $f.2.23 $f.2.24 $f.2.25 $f.2.26 $f.2.27 $f.2.28 $f.2.29 $f.2.2a $f.2.2b $f.2.2c $f.2.2d $f.2.2e -side left
	pack $f.2.31 $f.2.32 $f.2.33 $f.2.34 $f.2.35 $f.2.36 $f.2.37 $f.2.38 $f.2.39 $f.2.3a $f.2.3b $f.2.3c $f.2.3d $f.2.3e -side left
	pack $f.2.41 $f.2.42 $f.2.43 $f.2.44 $f.2.45 $f.2.46 $f.2.47 $f.2.48 $f.2.49 $f.2.4a $f.2.4b $f.2.4c $f.2.4d $f.2.4e -side left
	pack $f.2.51 $f.2.52 $f.2.53 $f.2.54 $f.2.55 $f.2.56 $f.2.57 $f.2.58 $f.2.59 $f.2.5a $f.2.5b $f.2.5c $f.2.5d $f.2.5e -side left
	pack $f.2.61 $f.2.62 $f.2.63 $f.2.64 $f.2.65 $f.2.66 $f.2.67 $f.2.68 $f.2.69 $f.2.6a $f.2.6b $f.2.6c $f.2.6d $f.2.6e -side left
	pack $f.2.71 $f.2.72 $f.2.73 $f.2.74 $f.2.75 $f.2.76 $f.2.77 $f.2.78 $f.2.79 $f.2.7a $f.2.7b $f.2.7c $f.2.7d $f.2.7e -side left
	pack $f.2.80 $f.2.81 $f.2.82  -side left


	pack $f.0 -side top -fill x -expand true
	pack $f.1 $f.2 -side top
	pack $f.3 -side top -fill x -expand true

	bind $f.1.01 <ButtonPress-1> "set nuaddpval  21"
	bind $f.1.02 <ButtonPress-1> "set nuaddpval  22"
	bind $f.1.03 <ButtonPress-1> "set nuaddpval  23"

	bind $f.1.12 <ButtonPress-1> "set nuaddpval  24"
	bind $f.1.13 <ButtonPress-1> "set nuaddpval  25"
	bind $f.1.14 <ButtonPress-1> "set nuaddpval  26 "
	bind $f.1.15 <ButtonPress-1> "set nuaddpval  27"
	bind $f.1.16 <ButtonPress-1> "set nuaddpval  28"
	bind $f.1.18 <ButtonPress-1> "set nuaddpval  29"
	bind $f.1.19 <ButtonPress-1> "set nuaddpval  30"
	bind $f.1.1a <ButtonPress-1> "set nuaddpval  31"
	bind $f.1.1b <ButtonPress-1> "set nuaddpval  32"
	bind $f.1.1c <ButtonPress-1> "set nuaddpval  33"
	bind $f.1.1d <ButtonPress-1> "set nuaddpval  34"
	bind $f.1.1e <ButtonPress-1> "set nuaddpval  35"

	bind $f.1.22 <ButtonPress-1> "set nuaddpval  36"
	bind $f.1.23 <ButtonPress-1> "set nuaddpval  37"
	bind $f.1.24 <ButtonPress-1> "set nuaddpval  38"
	bind $f.1.25 <ButtonPress-1> "set nuaddpval  39"
	bind $f.1.26 <ButtonPress-1> "set nuaddpval  40"
	bind $f.1.28 <ButtonPress-1> "set nuaddpval  41"
	bind $f.1.29 <ButtonPress-1> "set nuaddpval  42"
	bind $f.1.2a <ButtonPress-1> "set nuaddpval  43"
	bind $f.1.2b <ButtonPress-1> "set nuaddpval  44"
	bind $f.1.2c <ButtonPress-1> "set nuaddpval  45"
	bind $f.1.2d <ButtonPress-1> "set nuaddpval  46"
	bind $f.1.2e <ButtonPress-1> "set nuaddpval  47"

	bind $f.1.32 <ButtonPress-1> "set nuaddpval  48"
	bind $f.1.33 <ButtonPress-1> "set nuaddpval  49"
	bind $f.1.34 <ButtonPress-1> "set nuaddpval  50"
	bind $f.1.35 <ButtonPress-1> "set nuaddpval  51"
	bind $f.1.36 <ButtonPress-1> "set nuaddpval  52"
	bind $f.1.38 <ButtonPress-1> "set nuaddpval  53"
	bind $f.1.39 <ButtonPress-1> "set nuaddpval  54"
	bind $f.1.3a <ButtonPress-1> "set nuaddpval  55"
	bind $f.1.3b <ButtonPress-1> "set nuaddpval  56"
	bind $f.1.3c <ButtonPress-1> "set nuaddpval  57"
	bind $f.1.3d <ButtonPress-1> "set nuaddpval  58"
	bind $f.1.3e <ButtonPress-1> "set nuaddpval  59"
 
	bind $f.1.42 <ButtonPress-1> "set nuaddpval  60; PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfilec$evv(SNDFILE_EXT)] 0"
	bind $f.1.43 <ButtonPress-1> "set nuaddpval  61; PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfiledb$evv(SNDFILE_EXT)] 0"
	bind $f.1.44 <ButtonPress-1> "set nuaddpval  62; PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfiled$evv(SNDFILE_EXT)] 0"
	bind $f.1.45 <ButtonPress-1> "set nuaddpval  63; PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfileeb$evv(SNDFILE_EXT)] 0"
	bind $f.1.46 <ButtonPress-1> "set nuaddpval  64; PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfilee$evv(SNDFILE_EXT)] 0"
	bind $f.1.48 <ButtonPress-1> "set nuaddpval  65; PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfilef$evv(SNDFILE_EXT)] 0"
	bind $f.1.49 <ButtonPress-1> "set nuaddpval  66; PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfilegb$evv(SNDFILE_EXT)] 0"
	bind $f.1.4a <ButtonPress-1> "set nuaddpval  67; PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfileg$evv(SNDFILE_EXT)] 0"
	bind $f.1.4b <ButtonPress-1> "set nuaddpval  68; PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfileab$evv(SNDFILE_EXT)] 0"
	bind $f.1.4c <ButtonPress-1> "set nuaddpval  69; PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfilea$evv(SNDFILE_EXT)] 0"
	bind $f.1.4d <ButtonPress-1> "set nuaddpval  70; PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfilebb$evv(SNDFILE_EXT)] 0"
	bind $f.1.4e <ButtonPress-1> "set nuaddpval  71; PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfileb$evv(SNDFILE_EXT)] 0"

	bind $f.1.52 <ButtonPress-1> "set nuaddpval  72"
	bind $f.1.53 <ButtonPress-1> "set nuaddpval  73"
	bind $f.1.54 <ButtonPress-1> "set nuaddpval  74"
	bind $f.1.55 <ButtonPress-1> "set nuaddpval  75"
	bind $f.1.56 <ButtonPress-1> "set nuaddpval  76"
	bind $f.1.58 <ButtonPress-1> "set nuaddpval  77"
	bind $f.1.59 <ButtonPress-1> "set nuaddpval  78"
	bind $f.1.5a <ButtonPress-1> "set nuaddpval  79"
	bind $f.1.5b <ButtonPress-1> "set nuaddpval  80"
	bind $f.1.5c <ButtonPress-1> "set nuaddpval  81"
	bind $f.1.5d <ButtonPress-1> "set nuaddpval  82"
	bind $f.1.5e <ButtonPress-1> "set nuaddpval  83"
 
	bind $f.1.62 <ButtonPress-1> "set nuaddpval 84 "
	bind $f.1.63 <ButtonPress-1> "set nuaddpval  85"
	bind $f.1.64 <ButtonPress-1> "set nuaddpval  86"
	bind $f.1.65 <ButtonPress-1> "set nuaddpval  87"
	bind $f.1.66 <ButtonPress-1> "set nuaddpval  88"
	bind $f.1.68 <ButtonPress-1> "set nuaddpval  89"
	bind $f.1.69 <ButtonPress-1> "set nuaddpval  90"
	bind $f.1.6a <ButtonPress-1> "set nuaddpval  91"
	bind $f.1.6b <ButtonPress-1> "set nuaddpval  92"
	bind $f.1.6c <ButtonPress-1> "set nuaddpval  93"
	bind $f.1.6d <ButtonPress-1> "set nuaddpval  94"
	bind $f.1.6e <ButtonPress-1> "set nuaddpval  95"

	bind $f.1.72 <ButtonPress-1> "set nuaddpval  96"
	bind $f.1.73 <ButtonPress-1> "set nuaddpval  97"
	bind $f.1.74 <ButtonPress-1> "set nuaddpval  98"
	bind $f.1.75 <ButtonPress-1> "set nuaddpval  99"
	bind $f.1.76 <ButtonPress-1> "set nuaddpval 100"
	bind $f.1.78 <ButtonPress-1> "set nuaddpval 101"
	bind $f.1.79 <ButtonPress-1> "set nuaddpval 102"
	bind $f.1.7a <ButtonPress-1> "set nuaddpval 103"
	bind $f.1.7b <ButtonPress-1> "set nuaddpval 104"
	bind $f.1.7c <ButtonPress-1> "set nuaddpval 105"
	bind $f.1.7d <ButtonPress-1> "set nuaddpval 106"
	bind $f.1.7e <ButtonPress-1> "set nuaddpval 107"

	bind $f.1.81 <ButtonPress-1> "set nuaddpval 108"

	bind $f.2.01 <ButtonPress-1>  "set nuaddpval 21"
	bind $f.2.03 <ButtonPress-1>  "set nuaddpval 23"

	bind $f.2.12 <ButtonPress-1>  "set nuaddpval 24"
	bind $f.2.14 <ButtonPress-1>  "set nuaddpval 26"
	bind $f.2.16 <ButtonPress-1>  "set nuaddpval 28"
	bind $f.2.18 <ButtonPress-1>  "set nuaddpval 29"
	bind $f.2.1a <ButtonPress-1>  "set nuaddpval 31"
	bind $f.2.1c <ButtonPress-1>  "set nuaddpval 33"
	bind $f.2.1e <ButtonPress-1>  "set nuaddpval 35"

	bind $f.2.22 <ButtonPress-1>  "set nuaddpval 36"
	bind $f.2.24 <ButtonPress-1>  "set nuaddpval 38"
	bind $f.2.26 <ButtonPress-1>  "set nuaddpval 40"
	bind $f.2.28 <ButtonPress-1>  "set nuaddpval 41"
	bind $f.2.2a <ButtonPress-1>  "set nuaddpval 43"
	bind $f.2.2c <ButtonPress-1>  "set nuaddpval 45"
	bind $f.2.2e <ButtonPress-1>  "set nuaddpval 47"

	bind $f.2.32 <ButtonPress-1>  "set nuaddpval 48"
	bind $f.2.34 <ButtonPress-1>  "set nuaddpval 50"
	bind $f.2.36 <ButtonPress-1>  "set nuaddpval 52"
	bind $f.2.38 <ButtonPress-1>  "set nuaddpval 53"
	bind $f.2.3a <ButtonPress-1>  "set nuaddpval 55"
	bind $f.2.3c <ButtonPress-1>  "set nuaddpval 57"
	bind $f.2.3e <ButtonPress-1>  "set nuaddpval 59"

	bind $f.2.42 <ButtonPress-1>  "set nuaddpval 60; PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfilec$evv(SNDFILE_EXT)] 0"
	bind $f.2.44 <ButtonPress-1>  "set nuaddpval 62; PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfiled$evv(SNDFILE_EXT)] 0"
	bind $f.2.46 <ButtonPress-1>  "set nuaddpval 64; PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfilee$evv(SNDFILE_EXT)] 0"
	bind $f.2.48 <ButtonPress-1>  "set nuaddpval 65; PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfilef$evv(SNDFILE_EXT)] 0"
	bind $f.2.4a <ButtonPress-1>  "set nuaddpval 67; PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfileg$evv(SNDFILE_EXT)] 0"
	bind $f.2.4c <ButtonPress-1>  "set nuaddpval 69; PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfilea$evv(SNDFILE_EXT)] 0"
	bind $f.2.4e <ButtonPress-1>  "set nuaddpval 71; PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfileb$evv(SNDFILE_EXT)] 0"
	bind $f.2.52 <ButtonPress-1>  "set nuaddpval 72"
	bind $f.2.54 <ButtonPress-1>  "set nuaddpval 74"
	bind $f.2.56 <ButtonPress-1>  "set nuaddpval 76"
	bind $f.2.58 <ButtonPress-1>  "set nuaddpval 77"
	bind $f.2.5a <ButtonPress-1>  "set nuaddpval 79"
	bind $f.2.5c <ButtonPress-1>  "set nuaddpval 81"
	bind $f.2.5e <ButtonPress-1>  "set nuaddpval 83"

	bind $f.2.62 <ButtonPress-1>  "set nuaddpval 84"
	bind $f.2.64 <ButtonPress-1>  "set nuaddpval 86"
	bind $f.2.66 <ButtonPress-1>  "set nuaddpval 88"
	bind $f.2.68 <ButtonPress-1>  "set nuaddpval 89"
	bind $f.2.6a <ButtonPress-1>  "set nuaddpval 91"
	bind $f.2.6c <ButtonPress-1>  "set nuaddpval 93"
	bind $f.2.6e <ButtonPress-1>  "set nuaddpval 95"

	bind $f.2.72 <ButtonPress-1>  "set nuaddpval 96"
	bind $f.2.74 <ButtonPress-1>  "set nuaddpval 98"
	bind $f.2.76 <ButtonPress-1>  "set nuaddpval 100"
	bind $f.2.78 <ButtonPress-1>  "set nuaddpval 101"
	bind $f.2.7a <ButtonPress-1>  "set nuaddpval 103"
	bind $f.2.7c <ButtonPress-1>  "set nuaddpval 105"
	bind $f.2.7e <ButtonPress-1>  "set nuaddpval 107"

	bind $f.2.81 <ButtonPress-1>  "set nuaddpval 108"
}

proc SnackDisplayX {listing val} {
	global tp_props_list tp_bfw evv
	SnackDisplay 0 $listing 0 $val
	set len [llength [lindex $tp_props_list 0]]
	set k 0
	set n 1
	foreach line $tp_props_list {
		if {[lindex $line 0] == $val} {
			$tp_bfw.$n.0 config -bg LimeGreen
			$tp_bfw.$n.$len config -bg LimeGreen
		} else {
			$tp_bfw.$n.0 config -bg $evv(SNCOLOR)
			$tp_bfw.$n.$len config -bg $evv(SNCOLOR)
		}
		incr n
		incr k
	}
}

proc PlaySndfileX {val} {
	global tp_props_list tp_bfw evv
	PlaySndfile $val 0
	set len [llength [lindex $tp_props_list 0]]
	set k 0
	set n 1
	foreach line $tp_props_list {
		if {[lindex $line 0] == $val} {
			$tp_bfw.$n.0 config -bg aquamarine2
			$tp_bfw.$n.$len config -bg aquamarine2
		} else {
			$tp_bfw.$n.0 config -bg $evv(HELP)
			$tp_bfw.$n.$len config -bg $evv(HELP)
		}
		incr n
		incr k
	}
}
