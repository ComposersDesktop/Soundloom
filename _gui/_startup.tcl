#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD 30 June 2013
# ... fixup button rectangles

##############
#	STARTUP	 #
##############

#------ Set up (if not already existing) user's special directories

proc CheckUserDirectories {} {
	global system_initialisation evv

	set system_initialisation 0

	set filename [file join $evv(CDPRESOURCE_DIR) $evv(INIT)$evv(CDP_EXT)]
	if {![file exists $filename]} {
		set system_initialisation 1
		if [catch {open $filename "w"} zat] {
			Inf "Failed to register system initialisation."
		} else {
			close $zat
		}
	}
	set filename [file join $evv(CDPRESOURCE_DIR) $evv(SYSTEM_CLOCK)$evv(CDP_EXT)]
	set OK 1
	if {![file exists $filename] || [catch {open $filename "r"} clkId]} {
		set OK 0
	}
	if {$OK} {
		set OK 0
		if {[gets $clkId line] >= 0} {
			set line [string trim $line]
			if {([string length $line] > 0) && [IsNumeric $line] && ($line > 0.0)} {
				set evv(CLOCK_TICK) $line
				set OK 1
			}
		}
		close $clkId
	}
	if {!$OK} {
		Block "Setting system clock"
 		set t1 [clock clicks]
		after 10000
		set t2 [clock clicks]
		set evv(CLOCK_TICK) [expr ($t2 - $t1)/10]
		UnBlock
		if [catch {open $filename "w"} clkId] {
			Inf "Cannot write system clock speed to file : continuing with session."
		} else {
			puts $clkId $evv(CLOCK_TICK)
			catch {close $clkId}
		}
	}

#OLD CODE
#	set pwd [pwd]
#	set evv(CDPROGRAM_DIR) [file join $pwd $evv(CDPROGRAM_DIR)]
#
#NEW
	if {![file exists $evv(CDPRESOURCE_DIR)]} {
		ErrShow "Cannot Find directory $evv(CDPRESOURCE_DIR)"
		return 0
	}
	set get_execdir 0
	set fnam [file join $evv(CDPRESOURCE_DIR) $evv(EXECDIR)$evv(CDP_EXT)]
	if {![file exists $fnam]} {
		set get_execdir 1
	} elseif [catch {open $fnam "r"} ffId] {
		Inf "Cannot open file '$fnam' to find location of your CDP programs"
		set get_execdir 1
	} elseif {[gets $ffId line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			set get_execdir 1
		} elseif {![file exists $line] || ![file isdirectory $line]} {
			Inf "The directory '$line' specified in file $fnam does not exist"
			set get_execdir 1
		} else {
			set pfnam [file join $line synth$evv(EXEC)]
			if {![file exists $pfnam]} {
				Inf "The CDP programs are not in the directory '$line'"
				set get_execdir 1
			} else {
				set evv(CDPROGRAM_DIR) $line
			}
		}
	} else {
		set get_execdir 1
	}
	catch {close $ffId}

	if {$get_execdir} {
		SetCDPexecsDir 0
	}
#END OF NEW


	if {![file exists $evv(URES_DIR)]} {
		if [catch {file mkdir $evv(URES_DIR)} zorg] {
			ErrShow "Cannot create User Resource Directory"
			return 0
		}
	}
	if {![file exists $evv(LOGDIR)]} {
		if [catch {file mkdir $evv(LOGDIR)} zorg] {
			ErrShow "Cannot create User Log Directory"
			return 0
		}
		set fnam [file join $evv(LOGDIR) $evv(LOGSCNT_FILE)$evv(CDP_EXT)]
		if {![catch {open $fnam "w"} fileId]} {
			catch {puts $fileId $evv(MIN_MAXLOGS)}
			catch {close $fileId}
		}
	}
	if {![file exists $evv(INS_DIR)]} {
		if [catch {file mkdir $evv(INS_DIR)} zorg] {
			ErrShow "Cannot create User Instruments Directory"
			return 0
		}
	}
	if {![file exists $evv(PATCH_DIRECTORY)]} {
		if [catch {file mkdir $evv(PATCH_DIRECTORY)} zorg] {
			ErrShow "Cannot create User Patch Directory"
			return 0
		}
	}
	return 1
}

#------ Specify the directory in which the CDP programs are located

proc SetCDPexecsDir {moved} {
	global pr_execdir exec_dir execdir_check wstk evv

#MAR 2011
# DEFAULT VALUE of evv(CDPROGRAM_DIR) SET AT STARTUP
#	set pwd [pwd]			
#	set evv(CDPROGRAM_DIR) [file join $pwd $evv(CDPROGRAM_DIR)]

	set dirfnam [file join $evv(CDPRESOURCE_DIR) $evv(EXECDIR)$evv(CDP_EXT)]
	set tempfnam $evv(DFLT_TMPFNAME)$evv(CDP_EXT)
	set directory_exists 0

#MAR 2011
# IF USER HAS SUBSEQUENTLY CHANGED LOCATION OF EXECS, FIND LOCATION IN THIS FILE

	if {[file exists $dirfnam]} {
		if [catch {open $dirfnam "r"} fId] {
			Inf "Cannot open file '$dirfnam' containing current location of your CDP programs\n\nEnd The Session And Ensure This File Is Closed (or Deleted, if spurious)"
			return
		}
		while {[gets $fId line] >= 0} {
			set line [string trim $line]
			if {[string length $line] > 0} {
				set evv(CDPROGRAM_DIR) $line
				set linecnt 1
				set directory_exists 1
				break
			}
		}
		if {![info exists linecnt]} {
			Inf "WARNING: There is Currently No Information in file '$dirfnam'\nWhich Should Contain The Name Of Your Current Program Directory"
			set directory_exists 0
		} elseif {![file exists $evv(CDPROGRAM_DIR)] || ![file isdirectory $evv(CDPROGRAM_DIR)]} {
			Inf "WARNING: The Current Information About Your CDP Programs Directory in file '$dirfnam' Is Spurious"
			set directory_exists 0
		}			
		catch {close $fId}
		if {$directory_exists < 0} {
			catch {file delete $dirfnam}
		}
	}

#MAR 2011
# USER IS CURRENTLY MOVING EXECS TO DIFFERENT LOCATION
	if {$moved} {
		if [catch {open $tempfnam "w"} zat] {
			Inf "Cannot open temporary file $tempfnam to write location of your CDP programs\nContinuing With Session"
			return
		}
		set f .execdir
		if [Dlg_Create $f "CDP LOCATION" "set pr_execdir 0" -borderwidth 10] {
			set b [frame $f.b -bd 2]
			button $b.0 -text "Close" -command "set pr_execdir 0" -bd 2 -width 5 -font bigfnt -highlightbackground [option get . background {}]
			button $b.1 -text "OK"   -command "set pr_execdir 1" -bd 2 -width 5 -font bigfnt -highlightbackground [option get . background {}]
			pack $b.0 -side left
			pack $b.1 -side right
			set b0 [frame $f.b0 -bd 2]										
			label $b0.l -text "ENTER FULL PATHNAME OF DIRECTORY IN WHICH YOU WISH STORE CDP PROGRAMS.\n(IF YOU ARE A NEW USER, LEAVE THE PROGRAMS IN THE DIRECTORY SHOWN)" -font bigfnt
			pack $b0.l -side top
			set b1 [frame $f.b1 -bd 2]										
			checkbutton $b1.ch -variable execdir_check -text "QUERY OVERWRITE of any pre-existing CDP programs" -font bigfnt
			pack $b1.ch -side top
			set b2 [frame $f.b2 -bd 2]										
			entry  $b2.e -width 64 -textvariable exec_dir -font bigfnt
			pack $b2.e -side top
			pack $f.b $f.b0 $f.b1 $f.b2 -side top -fill x -expand true
#			wm resizable $f 0 0
			bind $b2.e <Return> {set pr_execdir 1}
			bind $b2.e <Escape> {set pr_execdir 0}
		}
		set execdir_check 1
		set exec_dir "$evv(CDPROGRAM_DIR)"
		set pr_execdir 0
		set finished 0
		raise $f
		My_Grab 1 $f pr_execdir $f.b2.e
		while {!$finished} {
			tkwait variable pr_execdir
			if {!$pr_execdir} {
				set finished 1
				break
			}
			if [string match $evv(CDPROGRAM_DIR) $exec_dir] {
				if {!$directory_exists} {
					if [catch {puts $zat $exec_dir} err] {
						Inf "Cannot Write A Record Of The CDP Programs Directory:\n\nContinuing The Present Session."
					}
					close $zat
					if {[file exists $dirfnam]} {
						if [catch {file rename -force $tempfnam $dirfnam} zup] {
							Inf "$zup : Cannot Write A Record Of The CDP Programs Directory:\n\nYou Should End The Session.\n\nAnd Rename The File '$tempfnam' to '$dirfnam'"
						}
					} else {
						if [catch {file rename $tempfnam $dirfnam} zup] {
							Inf "$zup : Cannot Write A Record Of The CDP Programs Directory:\n\nYou Should End The Session.\n\nAnd Rename The File '$tempfnam' to '$dirfnam'"
						}
					}
				}
				set finished 1
				break
			}

			set temp [CheckDirectoryNameForProgs $exec_dir "directory_name"]
			if {[string length $temp] <= 0} {
				continue
			}
			set exec_dir $temp
			set thispwd [pwd]
			if [file isdirectory $exec_dir] {
				cd $exec_dir
				set newpwd [pwd]
				set choice [tk_messageBox -type yesno -default yes \
					-message "The Directory You Have Chosen Is '$newpwd' : Is This Correct?\n" \
					-icon question -parent [lindex $wstk end]]
				cd $thispwd
				if [string match $choice no] {
					continue
				} else {
					set exec_dir $newpwd
				}
				if {[string match $exec_dir $evv(CDPROGRAM_DIR)]} {
					set moved 0
				}		
			} else {
				set OK 0
				set choice [tk_messageBox -type yesno -default no \
					-message "This Directory Does Not Exist. Do You Wish To Create It ?\n" \
					-icon question -parent [lindex $wstk end]]
				if [string match $choice yes] {
					if [catch {file mkdir $exec_dir} zorg] {
						ErrShow "Cannot create Directory $exec_dir"
					} else {
						set OK 1
					}
				}
				if {!$OK} {
					continue
				}
			}
			;# It could be that user has renamed the _cdp directory, so no programs need to be moved!!
			if {![AreExecsAlreadyThere $exec_dir]} {
				catch {unset copied_progs}
				catch {unset not_copied}
				Block "Copying Files to directory $exec_dir"
				foreach fnam [glob -nocomplain [file join $evv(CDPROGRAM_DIR) *]] {
					set progname [file tail $fnam]
					set prog_name [file join $exec_dir $progname]
					set OK 1
					if {$execdir_check} {
						if [file exists $prog_name] {
							set choice [tk_messageBox -type yesno -default yes \
								-message "Do You Wish To Overwrite The Existing '$progname'?\n" \
								-icon question -parent [lindex $wstk end]]
							if [string match $choice no] {
								set OK 0
							}
						}
					}
					if {$OK} {
						if {[file exists $prog_name]} {
							if [catch {file copy -force $fnam $prog_name} zib] {
								Inf "Cannot copy program '$progname' to directory '$exec_dir'"
								lappend not_copied $progname
							} else {
								lappend copied_progs $fnam
							}
						} else {
							if [catch {file copy $fnam $prog_name} zib] {
								Inf "Cannot copy program '$progname' to directory '$exec_dir'"
								lappend not_copied $progname
							} else {
								lappend copied_progs $fnam
							}
						}
					}
				}
				catch {UnBlock}
				set go_on 0
				if {![info exists copied_progs]} {
					set choice [tk_messageBox -type yesno -default yes \
						-message "No Programs Have Been Copied To The Specified Directory: Do You Want To Try A Diferent Directory?\n" \
						-icon question -parent [lindex $wstk end]]
					if [string match $choice no] {
						set exec_dir $evv(CDPROGRAM_DIR)
						set go_on 1
					} else {
						continue
					}
				}
				if {!$go_on && [info exists not_copied]} {
					Inf "The following programs still need to be copied to the new directory....\n\n$not_copied"
				}
			}
			if [catch {puts $zat $exec_dir} err] {
				Inf "Cannot Write A Record Of The New CDP Programs Directory:\n\nYou Need To End The Session ..... Then\n\n1) Open The File '$dirfnam'\n2) Delete Its Contents\n3) Write '$exec_dir' In That File\n"
				set finished 1
			} else {
				if {$directory_exists} {
					catch {file delete $dirfnam}
				}
				if {[file exists $dirfnam]} {
					if {[catch {file rename -force $tempfnam $dirfnam} err]} {
						Inf "Cannot Rename Temporary File Containing Name Of New CDP Programs Directory:\n\nYou Need To End The Session, and Rename File '$tempfnam' to '$dirfnam'"
					}
				} else {
					if {[catch {file rename $tempfnam $dirfnam} err]} {
						Inf "Cannot Rename Temporary File Containing Name Of New CDP Programs Directory:\n\nYou Need To End The Session, and Rename File '$tempfnam' to '$dirfnam'"
					}
				}
				if {$moved} {
					if [info exists not_copied] {
						Inf "BEWARE!!! The following files have NOT been copied to your new directory\n\n$not_copied\nTake care not to delete the original copies in directory $evv(CDPROGRAM_DIR)"
					} else {
						Inf "you may now delete the CDP programs in the original directory $evv(CDPROGRAM_DIR)"
					}
				}
				set evv(CDPROGRAM_DIR) $exec_dir
				set finished 1
			}
		}
		catch {close $zat}
		My_Release_to_Dialog $f
		destroy $f
#MARCH 2011
	}
	return
}

#------ Specify the type of platform

proc SetSystem {} {
	global pr_system got_sys evv
    global tcl_platform

	set filename [file join $evv(CDPRESOURCE_DIR) $evv(SYS)$evv(CDP_EXT)]
	if [file exists $filename] {
		set got_sys 1
		if [catch {open $filename "r"} zat] {
			Inf "Failed to find system type:\n\nPlease specify this again."
			set got_sys 0
		} elseif {([gets $zat line] < 0) || ([string length $line] <= 0)} {
			Inf "Cannot read system type.\n\nPlease specify this again."
			set got_sys 0
		} else {
			set evv(SYSTEM) [string trim $line]
			if {([string length $evv(SYSTEM)] <= 0)} {
				Inf "Cannot read system type.\n\nPlease specify this again."
				set got_sys 0
				close $zat
			} else {
				switch -- $evv(SYSTEM) {
					"PC"  	-
					"SGI" 	-
					"MAC" 	-
					"LINUX" {}
					default {
						Inf "Invalid system type '$evv(SYSTEM)' specified.\n\nPlease specify this again."
						set got_sys 0
					}
				}
			}
		} 
	} else {
		set got_sys 0
	}
	catch {close $zat}
	if {$got_sys} {
		EstablishFont
		return
	}
	if {[string match $tcl_platform(platform) "unix"]} {
		set evv(SYSTEM) MAC
		set doneset 1
	}
	if {![info exists doneset]} {
		switch -- $tcl_platform(platform) {
			"windows" {
				Inf "This version of the CDP does not run on this platform: You need the PC version"
			}
			default {
				Inf "The CDP does not run on this platform: You need a MAC (OSX) or a PC"
			}
		}
		exit
	}
	if {[catch {open $filename "w"} zat] || [catch {puts $zat $evv(SYSTEM)} zurb]} {
		Inf "Failed to record system type:\n\nProceeding with session."
		catch {close $zat}
		catch {file delete $filename}
	} else {
		catch {close $zat}
	}
	EstablishFont
	return
}

#------ 

proc CheckDirectoryNameForProgs {str var} {
	global private_directories evv
	set str "[string trim $str]"
	set len [string length $str]
	if {$len <= 0} {
		Inf "No $var entered"
		return ""
	}
#JUNE 30 UC-LC FIX
	set str [string tolower $str]
	switch -- $evv(SYSTEM) {
		SGI {
			if {[regexp {[^A-Za-z0-9_/\.\-]} $str]} {		;#	Allows directory separator '/'
				Inf "$var contains invalid characters"
				return ""
			}
		}
		PC {					
			set OK 1
			set origstr $str
			set colontest [string first ":" $str]
			if {$colontest == 1} {								;#	Allows (e.g.) "c:" at start of filename
				if {[regexp {[^A-Za-z]} [string range $str 0 0]]} {
					set OK 0
				} else {
					set str [string range $str 2 end]
					if {[string length $str] <= 0} { 			;#	But not ONLY "c:"
						Inf "$var is incomplete"
						return ""
					}
				}
			} elseif {$colontest >= 0} {						;#	Disallows ":" elsewhere in filename
				set OK 0
			}
			if {$OK} {
				set str [RegulariseDirectoryRepresentation $str]
				if {[regexp {[^A-Za-z\ 0-9_/\.\-]} $str]} {	;#	Allows directory separator '\',
					set OK 0									;#	 and spaces in dirnames
				}
			}
			if {$OK == 0} {
				Inf "$var contains invalid characters"
				return ""
			}
			if {$colontest == 1} {
				set newstr [string range $origstr 0 1]
				append newstr $str
				set str $newstr
			}
		}
		MAC {
			if {[regexp {[^~A-Za-z0-9_/\.\-]} $str]} {		;#	RWD: we support OSX only: Allows directory separator '/' and ~
				Inf "$var contains invalid characters"
				return ""
			}
		}
		LINUX {
			Inf "Directory separator for linux not known: CheckDirectoryNameForProgs"
			return ""
		}
	}
	if {![string match $evv(CDPROGRAM_DIR) $str]} {
		set OK 1
		set n 0
		while {$n < 9} {
			switch -- $n {
				0 {
					set matchstr "*$evv(CDPRESOURCE_DIR)*"
					if [string match $matchstr $str] {
						set OK 0
						break
					}
				}
				1 {
					set matchstr "*$evv(CDPGUI_DIR)*"
					if [string match $matchstr $str] {
						set OK 0
						break
					}
				}
				2 {
					set matchstr "*$evv(PATCH_DIRECTORY)*"
					if [string match $matchstr $str] {
						set OK 0
						break
					}
				}
				3 {
					set matchstr "*$evv(SUBPATCH_DIRECTORY)*"
					if [string match $matchstr $str] {
						set OK 0
						break
					}
				}
				4 {
					set matchstr "*$evv(INS_DIR)*"
					if [string match $matchstr $str] {
						set OK 0
						break
					}
				}
				5 {
					set matchstr "*$evv(MACRO_DIR)*"
					if [string match $matchstr $str] {
						set OK 0
						break
					}
				}
				6 {
					set matchstr "*$evv(URES_DIR)*"
					if [string match $matchstr $str] {
						set OK 0
						break
					}
				}
				7 {
					set matchstr "*$evv(LOGDIR)*"
					if [string match $matchstr $str] {
						set OK 0
						break
					}
				}
				8 {
					if {[info exists private_directories]} {
						foreach matchstr $private_directories {
							if [string match $matchstr* $str] {
								set OK 0
								break
							}
						}
						if {!$OK} {
							break
						}
					}
				}
			}
			incr n
		}
		if {!$OK} {
			Inf "This is a reserved CDP directory"
			return ""
		}
	}
	return $str
}

#--- Change default extension for output Soundfiles

proc ChangeSndfileExtension {} {
	global pr_cse sse_permanent default_extension cse_cse wstk uv evv
	set f .cse
	if [Dlg_Create $f "OUTPUT SOUNDS: FILE EXTENSION" "set pr_cse 0" -borderwidth 10] {
		set b0 [frame $f.b0 -bd 2]
		set b1 [frame $f.b1 -bd 2]
		set b2 [frame $f.b2 -bd 2]
		set b3 [frame $f.b3 -bd 2]
		set b4 [frame $f.b4 -bd 2]
		button $b0.0 -text "Close" -command "set pr_cse 0" -bd 2 -highlightbackground [option get . background {}]
		button $b2.0 -text "Change Default For this Session only" -command "set pr_cse 1" -bd 2 -highlightbackground [option get . background {}]
		button $b1.0 -text "Change Default Extension Permanently" -command "set pr_cse 2" -bd 2 -highlightbackground [option get . background {}]
		button $b3.0 -text "Revert to Original Default Extension" -command "set pr_cse 3" -bd 2 -highlightbackground [option get . background {}]
		pack $b0.0 -side right 
		pack $b1.0 -side left
		pack $b2.0 -side left 
		pack $b3.0 -side left 
		foreach ext $evv(SNDFILE_EXTS) {
			radiobutton $b4$ext  -variable cse_cse -text "$ext" -value "$ext"
			pack $b4$ext -side left
		}

		pack $f.b0 $f.b1 $f.b2 $f.b3 $f.b4 -side top -pady 2
		bind $f <Escape>  {set pr_cse 0}
	}
	set cse_cse $evv(SNDFILE_EXT)
	set pr_cse 0
	set finished 0
	raise $f
	My_Grab 0 $f pr_cse
	while {!$finished} {
		tkwait variable pr_cse
		switch -- $pr_cse {
			0 {
				break
			}
			1 {
				set choice [tk_messageBox -type yesno -default yes \
					-message "Are You Sure You Want Change The Default Extension\nFor This Session ??\n" \
					-icon question -parent [lindex $wstk end]]
				if [string match $choice no] {
					continue
				}		
				set evv(SNDFILE_EXT) $cse_cse
				Inf "Output Soundfile Extension Changed,\nFor This Session Only, TO\n\n$evv(SNDFILE_EXT)"
				break
			}
			2 {
				set choice [tk_messageBox -type yesno -default yes \
					-message "Are You Sure You Want Change The Default Extension\nFor This Session\n**** And Future Sessions **** ??\n" \
					-icon question -parent [lindex $wstk end]]
				if [string match $choice no] {
					continue
				}		
				set evv(SNDFILE_EXT) $cse_cse
				set uv(sndfile_extension) $evv(SNDFILE_EXT)
				SaveUserEnvironment
				set sse_permanent 1
				Inf "Output Soundfile Extension Changed\nFor This Session\nAnd For Future Sessions TO\n\n$evv(SNDFILE_EXT)"
				break
			}
			3 {
				set choice [tk_messageBox -type yesno -default yes \
					-message "Are You Sure You Want To Revert To The Extension ($default_extension) You Were Using\nAt The Start Of This Session?\n" \
					-icon question -parent [lindex $wstk end]]
				if [string match $choice no] {
					continue
				}		
				if {![info exists default_extension]} {
					PROBLEM!!
				}
				set evv(SNDFILE_EXT) $default_extension
				if {[info exists sse_permanent] && ($sse_permanent == 1)} {
					set uv(sndfile_extension) $evv(SNDFILE_EXT)
					SaveUserEnvironment
					set sse_permanent 0
				}
				break
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#--- Set default sndfile extension when Intially setting up a CDP system

proc SetSndfileExtension {} {
	global pr_sse sse_permanent default_extension sse_sse wstk uv evv
	set f .sse
	if [Dlg_Create $f "OUTPUT SOUNDS: FILE EXTENSION" "set pr_sse 0" -borderwidth 10] {
		set b0 [frame $f.b0 -bd 2]
		set b1 [frame $f.b1 -bd 2]
		set b2 [frame $f.b2 -bd 2]
		set b3 [frame $f.b3 -bd 2]
		button $b0.0 -text "Close" -command "set pr_sse 0" -bd 2 -highlightbackground [option get . background {}]
		button $b1.0 -text "Set Default Output Soundfile Extension" -command "set pr_sse 1" -bd 2 -highlightbackground [option get . background {}]
		pack $b0.0 -side right 
		pack $b1.0 -side left
		label $b2.0 -text "The Output Soundfile Extension can be changed,\ntemporarily or permanently,\nfrom the STSTEM STATE menu\non the Workspace page"
		pack $b1.0 -side top
		foreach ext $evv(SNDFILE_EXTS) {
			radiobutton $b3$ext  -variable sse_sse -text "$ext" -value "$ext"
			pack $b3$ext -side left
		}

		pack $f.b0 $f.b1 $f.b2 $f.b3 -side top -pady 2
		bind $f <Return> {set pr_sse 1}
		bind $f <Escape> {set pr_sse 0}
	}
	set sse_sse $evv(SNDFILE_EXT)
	set pr_sse 0
	set finished 0
	raise $f
	My_Grab 1 $f pr_sse
	while {!$finished} {
		tkwait variable pr_sse
		if {$pr_sse} {
			set choice [tk_messageBox -type yesno -default yes \
				-message "Set Default Extension To\n\n$sse_sse ??\n" \
				-icon question -parent [lindex $wstk end]]
			if [string match $choice no] {
				continue
			}		
			set evv(SNDFILE_EXT) $sse_sse
			set uv(sndfile_extension) $evv(SNDFILE_EXT)
			SaveUserEnvironment
			Inf "Output Soundfile Extension Set To\n\n$evv(SNDFILE_EXT)"
			continue
		} else {
			break
		}
	}
	My_Release_to_Dialog $f
	destroy $f
}

#--- Establish system-dependent font

proc EstablishFont {} {
	global numacfnt evv

	switch -- $evv(SYSTEM) {
		"PC"  	{
			if {[info exists numacfnt] && $numacfnt} {	;#	FOR TESTING MAC CODE ON PC
				set evv(FONT_FAMILY) "Arial narrow"
				set evv(FONT_SIZE) 12
				set evv(BIG_FONT_SIZE) 14
			} else {
				set evv(FONT_FAMILY) tahoma
				set evv(FONT_SIZE) 8
				set evv(BIG_FONT_SIZE) 12
			}
		}
		"SGI" {
			set evv(FONT_FAMILY) tahoma
			set evv(FONT_SIZE) 8
			set evv(BIG_FONT_SIZE) 12
		}
		"MAC" {
			if {$numacfnt} {
				set evv(FONT_FAMILY) "Arial narrow"
				set evv(FONT_SIZE) 12
				set evv(BIG_FONT_SIZE) 14
			} else {
				set evv(FONT_FAMILY) "Euphemia UCAS"
				set evv(FONT_SIZE) 10
				set evv(BIG_FONT_SIZE) 15
			}
		}
		"LINUX" { 
			set evv(FONT_FAMILY) tahoma
			set evv(FONT_SIZE) 8
			set evv(BIG_FONT_SIZE) 12
		}
	}
}

#--- Change default extension for output Files

proc ChangeFileExtensions {} {
	global pr_cse2 new_cdp_extensions multiple_file_extensions evv
;# 2023
	set old_cdp_extensions new_cdp_extensions
	set f .cse2
	if [Dlg_Create $f "OUTPUT FILES: FILENAME EXTENSIONS" "set pr_cse2 0" -borderwidth 10] {
		button $f.0 -text "Close" -command "set pr_cse2 0" -bd 2 -highlightbackground [option get . background {}]
		if {$multiple_file_extensions} {
			label $f.1 -text "You can use THE SAME filename extension (e.g. '.wav')"
		} else {
			label $f.1 -text "You can use THE SAME filename extension ('.wav')"
		}
		label $f.2 -text "FOR ALL soundsystem files (soundfiles, analysis files, etc.)\n"
		label $f.3 -text "OR a DIFFERENT filename extension FOR EACH different filetype"
		frame $f.4
		if {$multiple_file_extensions} {
			label $f.4.a -text  "                .wav (.aiff  or .aif) for SOUND"
		} else {
			label $f.4.a -text  "                .wav .......  for SOUND"
		}
		pack $f.4.a -side left
		frame $f.4a
		label $f.4a.a -text "                .ana .......  ANALYSIS data"
		pack $f.4a.a -side left
		frame $f.4b
		label $f.4b.a -text "                .for ........  FORMANT data"
		pack $f.4b.a -side left
		frame $f.4c
		label $f.4c.a -text "                .evl ........  binary ENVELOPE data"
		pack $f.4c.a -side left
		frame $f.4d
		label $f.4d.a -text "                .frq ........  binary PITCH data"
		pack $f.4d.a -side left
		frame $f.4e
		label $f.4e.a -text "                .trn ........  binary TRANSPOSITION data"
		pack $f.4e.a -side left
		button $f.5 -text "Standard File Extension" -command "SetSndsysExtensions 0" -width 30 -highlightbackground [option get . background {}]
		button $f.6 -text "Different File Extensions" -command "SetSndsysExtensions 1" -width 30 -highlightbackground [option get . background {}]
		label $f.7 -text "****** WARNING ****** " -fg $evv(SPECIAL)
		label $f.8 -text "If you are working with different filename extensions" -fg $evv(SPECIAL)
		label $f.9 -text "and you switch back to using a standard extension" -fg $evv(SPECIAL)
		label $f.10 -text "the Sound Loom will no longer recognise files with" -fg $evv(SPECIAL)
		label $f.11 -text "non-standard extensions as valid files!!" -fg $evv(SPECIAL)
		pack $f.0 $f.1 $f.2 $f.3 -side top -pady 2
		pack $f.4 $f.4a $f.4b $f.4c $f.4d $f.4e -side top -pady 2 -fill x -expand true
		pack $f.5 $f.6 $f.7 $f.8 $f.9 $f.10 $f.11 -side top -pady 2
		bind $f <Return> {set pr_cse2 0}
		bind $f <Escape> {set pr_cse2 0}
		bind $f <Key-space> {set pr_cse2 0}
	}
	ToggleSndfileExtension
	set pr_cse2 0
	raise $f
	My_Grab 0 $f pr_cse2
	tkwait variable pr_cse2
	if {$old_cdp_extensions != $new_cdp_extensions} {
		set fnam [file join $evv(CDPRESOURCE_DIR) $evv(NEWSYS)$evv(CDP_EXT)]
		if [catch {open $fnam "w"} zit] {
			Inf "Cannot Open File '$fnam' To Write File Extension Choice For Next Session."
		} else {
			puts $zit $new_cdp_extensions
			close $zit
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc SetSndsysExtensions {many} {
	global new_cdp_extensions
	if {$many} {
		set new_cdp_extensions 1
	} else {
		set new_cdp_extensions 0
	}
	ToggleSndfileExtension
}

proc ReInitialiseCDP {} {
	global system_initialisation wstk evv

#TEST
Inf "Currently Not Working As 'init.cdp', 'sys.cdp' And 'clock.cdp' Will Not Delete (Permission Denied)\nEven Though They Have Same Status Vals As Files That Can Be Deleted!!!"
return


	set msg "Reinitialising The System Means Starting Everything From Scratch Once Again\n\nAre You Sure You Want To Do This ??"
	set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
	if {$choice == "no"} {
		return
	}
	foreach fnam [glob -nocomplain [file join $evv(CDPRESOURCE_DIR) *]] {
		set zfnam [file rootname [file tail $fnam]]
		if {($zfnam != "CDPres") && ($zfnam != "testfile")} {
			if [catch {file delete $fnam} zit] {
				lappend undeleted $fnam
				Inf $zit
			} 
		}
	}
	if {[info exists undeleted]} {
		set msg "The Following Files In Directory $evv(CDPRESOURCE_DIR) Could Not Be Deleted\n"
		set zzcnt 0
		foreach fnam $undeleted {
			if {$zzcnt > 60} {
				append msg "    AND MORE"
				break
			}
			append msg "    $fnam"
			incr zzcnt
		}
		Inf $msg
	}
	set filename [file join $evv(CDPRESOURCE_DIR) $evv(INIT)$evv(CDP_EXT)]
	if {[file exists $filename]} {
		Inf "Cannot Re-Initialise The System"
	} else {
		Inf "Re-Initialisation Marked\n\nyou Must Now Restart The Sound Loom"
	}
}

proc ToggleSndfileExtension {} {
	global new_cdp_extensions
	if {$new_cdp_extensions} {
		.cse2.5 config -text "Standard File Extension"
		.cse2.6 config -text "DIFFERENT FILE EXTENSIONS"
	} else {
		.cse2.5 config -text "STANDARD FILE EXTENSION"
		.cse2.6 config -text "Different File Extensions"
	}
}

proc ConfirmSys {} {
	global got_sys
	set str [.system.b.5 cget -text]
	if {[string length $str] > 0} {
		set got_sys 1
	} else {
		Inf "No System Chosen"
	}
}

proc AreExecsAlreadyThere {exec_dir} {
	global evv
	set proglst {}
	lappend proglist blur	  
	lappend proglist brkdur	  
	lappend proglist cdparams  
	lappend proglist cdparse   
	lappend proglist columns	  
	lappend proglist combine	  
	lappend proglist diskspace 
	lappend proglist distort	  
	lappend proglist envel	  
	lappend proglist extend	  
	lappend proglist filter	  
	lappend proglist focus	  
	lappend proglist formants  
	lappend proglist getcol    
	lappend proglist gobo	  
	lappend proglist gobosee	  
	lappend proglist grain	  
	lappend proglist hfperm	  
	lappend proglist hilite	  
	lappend proglist histconv  
	lappend proglist housekeep 
	lappend proglist listdate  
	lappend proglist maxsamp2  
	lappend proglist modify	  
	lappend proglist morph	  
	lappend proglist paudition 
	lappend proglist pdisplay  
	lappend proglist pitch	  
	lappend proglist pitchinfo 
	lappend proglist pmodify   
	lappend proglist progmach  
	lappend proglist pview	  
	lappend proglist pagrab	  
	lappend proglist paview	  
	lappend proglist putcol    
	lappend proglist pvoc	  
	lappend proglist repitch	  
	lappend proglist sfedit
	lappend proglist sndinfo	  
	lappend proglist spec	  
	lappend proglist specinfo  
	lappend proglist strange	  
	lappend proglist stretch	  
	lappend proglist submix	  
	lappend proglist synth	  
	lappend proglist texture	  
	lappend proglist vectors
	foreach prg $proglst {
		if {![file exists [file join $exec_dir $progname$evv(EXEC)]]} {
			return 0
		}
	}
	return 1
}
