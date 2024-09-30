#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD 30 June 2013
# ... fixup button rectangles

####################
# USER SCREEN SIZE #
####################

proc Establish_SmallScreen_Sizes {} {
	global evv
	set effective_scrollbar_width	20	;# estimates
	set title_bar_width				20
	set screen_edges				20
	set evv(SMALL_WIDTH)		[expr 800  - $effective_scrollbar_width - $screen_edges]
	set evv(SMALL_HEIGHT)		[expr 600  - ($effective_scrollbar_width + $screen_edges + $title_bar_width)]
# Available space for use of scrolling display = size of large display screen
	set evv(LARGE_WIDTH)		[expr 1024 + $effective_scrollbar_width]
	set evv(LARGE_HEIGHT)		[expr 768  + $effective_scrollbar_width]
# Squeezings of large available space to trim off areas not used in practice by (large-screen) display
	set evv(WKSPACE_WIDTH)		[expr int(round(($evv(LARGE_WIDTH) * 7)/double(6)))]
	set evv(PROCESS_WIDTH)		$evv(LARGE_WIDTH)
	set evv(PARAMS_WIDTH)		[expr int(round(($evv(LARGE_WIDTH) * 28)/double(23)))]
	set evv(INSCRE_WIDTH)		[expr int(round(($evv(LARGE_WIDTH) * 23)/double(28)))]
	set evv(BRKF_WIDTH)			[expr int(round(($evv(LARGE_WIDTH) * 13)/double(14)))]
	set evv(STAFF_WIDTH)		[expr int(round(($evv(LARGE_WIDTH) * 23)/double(28)))]
	set evv(WKSPACE_HEIGHT)		[expr int(round(($evv(LARGE_HEIGHT) * 9)/double(11)))]
	set evv(PROCESS_HEIGHT)		[expr int(round(($evv(LARGE_HEIGHT) * 53)/double(64)))]
	set evv(TABEDIT_HEIGHT)		[expr int(round(($evv(LARGE_HEIGHT) * 19)/double(22)))]
#JAN22 OLD VAL
#	set evv(PARAMS_HEIGHT)		[expr int(round(($evv(LARGE_HEIGHT) * 14)/double(15)))]
# NEW VAL
	set evv(PARAMS_HEIGHT)		$evv(LARGE_HEIGHT)
	set evv(MUSCALC_HEIGHT)		[expr int(round(($evv(LARGE_HEIGHT) * 3)/double(5)))]
	set evv(INSCRE_HEIGHT)		[expr int(round(($evv(LARGE_HEIGHT) * 6)/double(7)))]
	set evv(BRKF_HEIGHT)		[expr int(round(($evv(LARGE_HEIGHT) * 67)/double(85)))]
	set evv(STAFF_HEIGHT)		[expr int(round(($evv(LARGE_HEIGHT) * 19)/double(21)))]
# Squeezings of small available space to trim off areas used by non-scrolled parts of display
	set evv(SMALLER_HEIGHT)		[expr int(round(($evv(SMALL_HEIGHT) * 6)/double(7)))]
}


#--- Mechanism to establish screen size on first use (and to reset later)

proc EstablishScreenSize {startup} {
	global evv system_initialisation small_screen pr_scsize sschange shortwindows wstk ww lengthen_screen_menu_index

	set get_screensize 0 
	set fnam [file join $evv(CDPRESOURCE_DIR) $evv(INIT)$evv(CDP_EXT)]
	set sschange 0
	if {$startup} {
		if {$system_initialisation} {
			set get_screensize 1
		} elseif {![file exists $fnam]} {
			Inf "Cannot find file '$evv(INIT)$evv(CDP_EXT)' : reset your screensize."
			set get_screensize 1
		} elseif [catch {open $fnam r} ssfId] {
			Inf "Cannot open file '$evv(INIT)$evv(CDP_EXT)' : defaulting to small screensize."
			set small_screen 1
			return 1
		} elseif {([gets $ssfId line] < 0) || ([string length $line] <= 0)} {
			Inf "Cannot read screen size information in file '$evv(INIT)$evv(CDP_EXT)' : reset your screensize."
			set get_screensize 1
			close $ssfId
		} else {
			set line [string trim $line]
			if {([string length $line] <= 0)} {
				Inf "Cannot read screen size information in file '$evv(INIT)$evv(CDP_EXT)' : reset your screensize."
				set get_screensize 1
				close $ssfId
			}
			switch -- $line {
				1 {
					set small_screen 1
				}
				0 {
					set small_screen 0
				}
				default {
					Inf "Cannot read screen size information in file '$evv(INIT)$evv(CDP_EXT)' : reset your screensize."
					set get_screensize 2
					close $ssfId
				}
			}
		}
	} else {
		set get_screensize 1
	}
	if {$get_screensize} {
		if [catch {open $fnam w} ssfId] {
			Inf "Cannot open file '$evv(INIT)$evv(CDP_EXT)' to write screen data."
			return 0
		}
		set f .ssscreen	 	
		if [Dlg_Create $f "SCREEN SIZE" "set pr_scsize 0" -borderwidth 10] {
			set f0 [frame $f.labels -borderwidth 2]
			label $f0.1	-text "LARGE SCREEN RECOMMENDED: if available." -font bigfnt
			pack $f0.1 -side top
			set b [frame $f.b -borderwidth $evv(BBDR)]
			button $b.0 -text "Close" -command "set pr_scsize 0" -bd 2 -width 5 -font bigfnt -highlightbackground [option get . background {}]
			button $b.1 -text "OK"   -command "set pr_scsize 1" -bd 2 -width 5 -font bigfnt -highlightbackground [option get . background {}]
			pack $b.0 -side left
			pack $b.1 -side right
			frame $f.b1 -height 1 -bg [option get . foreground {}]
			set b2 [frame $f.b2 -borderwidth $evv(BBDR)]										
			button $b2.0 -text "large screen (at least 1024 x 768)" -width 36 -command "TogScreenSizeDisplay 1" -font bigfnt -highlightbackground [option get . background {}]
			button $b2.1 -text "small screen (at least 600 x 800)"  -width 36 -command "TogScreenSizeDisplay 0" -font bigfnt -highlightbackground [option get . background {}]
			pack $b2.0 $b2.1 -side top
			pack $f.labels $f.b $f.b1 $f.b2 -side top -fill x -expand true
		}
		if {$startup} {									;# at system init, or failure to read existing screen size
 			$f.b.0 config -text "" -command {} -bd 0	;# Cannot quit without setting screen size
			TogScreenSizeDisplay -1
			bind $f <Escape> {}
			bind $f <Return> {set pr_scsize 1}
		} else {
			$f.b.0 config -text "Close" -command "set pr_scsize 0" -bd 2 -width 5 -font bigfnt
			set orig_small_screen $small_screen
			if {$small_screen} {
				TogScreenSizeDisplay 0
			} else {																				
				TogScreenSizeDisplay 1
			}
			bind $f <Escape> {set pr_scsize 0}
			bind $f <Return> {set pr_scsize 1}
		}
#		wm resizable $f 0 0
		set pr_scsize 0
		set finished 0
		raise $f
		My_Grab 0 $f pr_scsize
		while {!$finished} {
			tkwait variable pr_scsize
			if {!$pr_scsize} {
				if {$startup} {
					Inf "No screen size specified"
				} else {
					set small_screen $orig_small_screen
					puts $ssfId $small_screen			;#	write screensize to file
					close $ssfId
					set finished 1
				}
			} else {			  				 					
				if {![info exists small_screen]} {
					Inf "No screen size specified"
				} else {
					puts $ssfId $small_screen			;#	write screensize to file
					close $ssfId
					set finished 1
				}
			}
		}
		if {$small_screen} {
			SaveShortWindows
			set shortwindows 1
			if {!$startup} {
				$ww.h.syscon.menu.sub1a entryconfig $lengthen_screen_menu_index -label "Lengthen Windows"
			}
		} else {
			set fnam [file join $evv(URES_DIR) shortwindows$evv(CDP_EXT)]
			if {[file exists $fnam]} {
				set msg "Do You Want To Retain Short (Not Deep) Windows ?"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					catch {unset shortwindows}
					catch {file delete $fnam}
					if {!$startup} {
						$ww.h.syscon.menu.sub1a entryconfig $lengthen_screen_menu_index -label "Shorten Windows"
					}
				} else {
					if {!$startup} {
						$ww.h.syscon.menu.sub1a entryconfig $lengthen_screen_menu_index -label "Lengthen Windows"
					}
				}
			}
		}
		My_Release_to_Dialog $f
		Dlg_Dismiss $f
		if {$pr_scsize && !$startup} {
			set sschange 1
			catch {destroy .ted}
			catch {destroy .inspage}
			catch {destroy .menupage}
			catch {destroy .pim}
			catch {destroy .ppg}
			catch {destroy .cpd}
			catch {destroy .proptab}
			catch {destroy .mixdisplay2}
			Inf "Large Windows have been resized.\n\nTo resize the WORKSPACE window you must restart the Sound Loom"
		}
	}
	return 1
}

proc TogScreenSizeDisplay {tolarge} {
	global small_screen evv

	switch -- $tolarge {
		1 {
			set small_screen 0
			.ssscreen.b2.0 config -text "LARGE SCREEN (AT LEAST 1024 x 768)"
			.ssscreen.b2.1 config -text "small screen (at least 600 x 800)"
		}
		0 {
			set small_screen 1
			.ssscreen.b2.1 config -text "SMALL SCREEN (AT LEAST 600 x 800)"
			.ssscreen.b2.0 config -text "large screen (at least 1024 x 768)"
		}
		-1 {
			.ssscreen.b2.0 config -text "large screen (at least 1024 x 768)"
			.ssscreen.b2.1 config -text "small screen (at least 600 x 800)"
		}
	}
}

#---- Distort-reverb

proc DistRev {} {
	global evv wstk pa wl chlist distrev pr_distrev distbak distsame prg_dun prg_abortd simple_program_messages CDPidrun
	catch {unset distbak}
	if {[info exists chlist] && ([llength $chlist] == 1)} {
		set ifnam [lindex $chlist 0]
	} else {
		set i [$wl curselection]
		if {([llength $i] == 1) && ($i != -1)} {
			set ifnam [$wl get $i]
		}
	}
	if {![info exists ifnam] || ($pa($ifnam,$evv(CHANS)) != 1)} {
		Inf "Select one mono soundfile"
		return
	}
	set distrev(ifnam) $ifnam
	set dur $pa($ifnam,$evv(DUR))
	if {![DistrevLoadParams $dur]} {
		set distrev(stt) ""
		set distrev(rep) 16
		set distrev(cycgp) 16
		set distrev(stad) .2
		set distrev(echo) 840
		set distrev(tstr) 8
		set distrev(crend) ""
		set distrev(spl) 0
	}
	set tstr $evv(DFLT_OUTNAME)				;#	Time-stretch envelope file
	append tstr 0 $evv(TEXT_EXT)

	set fnamn $evv(DFLT_OUTNAME)			;#	Normalised (to half-level) infile
	append fnamn 0 $evv(SNDFILE_EXT)

	set fnamana $evv(DFLT_OUTNAME)			;#	Associated analysis file
	append fnamana 0 $evv(ANALFILE_EXT)

	set fnamtsana $evv(DFLT_OUTNAME)		;#	Tstretched analfile
	append fnamtsana 1 $evv(ANALFILE_EXT)

	set fnamts $evv(DFLT_OUTNAME)			;#	Tstretched infile
	append fnamts 1 $evv(SNDFILE_EXT)

	set fnamd  $evv(DFLT_OUTNAME)			;#	Distorted infile
	append fnamd 2 $evv(SNDFILE_EXT)

	set fnamdc  $evv(DFLT_OUTNAME)			;#	Distorted infile with start cut off
	append fnamdc 3 $evv(SNDFILE_EXT)

	set fnamdcr  $evv(DFLT_OUTNAME)			;#	Distorted infile reverbd
	append fnamdcr 4 $evv(SNDFILE_EXT)

	set fnamdcrm  $evv(DFLT_OUTNAME)		;#	Distorted infile reverbd to mono
	append fnamdcrm 5 $evv(SNDFILE_EXT)

	set oofnam  $evv(DFLT_OUTNAME)			;#	(Temporary) outfile
	append oofnam 6 $evv(SNDFILE_EXT)

	set f .distrev
	if [Dlg_Create $f "DISTORT REVERB" "set pr_distrev 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0] 
		set f01 [frame $f.01] 
		set f1 [frame $f.1] 
		set f2 [frame $f.2] 
		set f3 [frame $f.3] 
		set f4 [frame $f.4] 
		set f5 [frame $f.5] 
		set f6 [frame $f.6] 
		set f7 [frame $f.7] 
		set f8 [frame $f.8] 
		set f9 [frame $f.9] 
		button $f0.ok -text "Run Process" -command "set pr_distrev 1" -width 12 -highlightbackground [option get . background {}]
		button $f0.hh -text "Help" -command "set pr_distrev 5" -width 5 -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f0.pi -text "View Input" -command  "set pr_distrev 4" -width 12 -bg $evv(SNCOLOR) -highlightbackground [option get . background {}]
		button $f0.po -text "View Output" -command "set pr_distrev 2" -width 12 -bg $evv(SNCOLOROFF) -highlightbackground [option get . background {}]
		button $f0.so -text "Save Output" -command "set pr_distrev 3" -width 12 -highlightbackground [option get . background {}]
		button $f0.qq -text "Quit" -command "set pr_distrev 0" -width 12 -highlightbackground [option get . background {}]
		pack $f0.ok $f0.hh $f0.pi $f0.po $f0.so -side left -padx 2
		pack $f0.qq -side right
		pack $f0 -side top -fill x -expand true
		button $f01.so -text "Save Intermediate Outputs" -command "set pr_distrev 6" -width 25 -highlightbackground [option get . background {}]
		pack $f01.so -side right -padx 2
		pack $f01 -side top -fill x -expand true -pady 4
		entry $f1.e -textvariable distrev(stt) -width 12
		label $f1.ll -text "Start-time of stability in input sound"
		pack $f1.e $f1.ll -side left
		pack $f1 -side top -fill x -expand true -pady 2
		entry $f2.e -textvariable distrev(rep) -width 12
		label $f2.ll -text "Distortion : repetition-count"
		pack $f2.e $f2.ll -side left
		pack $f2 -side top -fill x -expand true -pady 2
		entry $f3.e -textvariable distrev(cycgp) -width 12
		label $f3.ll -text "Distortion : waveset-group count"
		pack $f3.e $f3.ll -side left
		pack $f3 -side top -fill x -expand true -pady 2
		entry $f4.e -textvariable distrev(stad) -width 12
		label $f4.ll -text "Reverb : stadium-size multiplier"
		pack $f4.e $f4.ll -side left
		pack $f4 -side top -fill x -expand true -pady 2
		entry $f5.e -textvariable distrev(echo) -width 12
		label $f5.ll -text "Reverb : stadium echocount"
		pack $f5.e $f5.ll -side left
		pack $f5 -side top -fill x -expand true -pady 2
		entry $f6.e -textvariable distrev(tstr) -width 12
		label $f6.ll -text "Time stretch of tail of input sound"
		pack $f6.e $f6.ll -side left
		pack $f6 -side top -fill x -expand true -pady 2
		entry $f7.e -textvariable distrev(crend) -width 12
		label $f7.ll -text "End time of crossfade from (stretched)src to rev-distorted-src"
		pack $f7.e $f7.ll -side left
		pack $f7 -side top -fill x -expand true -pady 2
		label $f9.ll -text "Distort splicelength (mS)"
		entry $f9.e -textvariable distrev(spl) -width 12
		pack $f9.e $f9.ll -side left
		pack $f9 -side top -fill x -expand true -pady 2
		entry $f8.e -textvariable distrev(ofnam) -width 24
		label $f8.ll -text "Output Filename"
		set zz [file rootname [file tail $ifnam]]
		append zz "_dr"
		set distrev(ofnam) $zz
		pack $f8.e $f8.ll -side left
		pack $f8 -side top -pady 2
		wm resizable $f 0 0
		bind $f.1.e <Up> {focus .distrev.8.e}
		bind $f.2.e <Up> {focus .distrev.1.e}
		bind $f.3.e <Up> {focus .distrev.2.e}
		bind $f.4.e <Up> {focus .distrev.3.e}
		bind $f.5.e <Up> {focus .distrev.4.e}
		bind $f.6.e <Up> {focus .distrev.5.e}
		bind $f.7.e <Up> {focus .distrev.6.e}
		bind $f.8.e <Up> {focus .distrev.7.e}
		bind $f.1.e <Down> {focus .distrev.2.e}
		bind $f.2.e <Down> {focus .distrev.3.e}
		bind $f.3.e <Down> {focus .distrev.4.e}
		bind $f.4.e <Down> {focus .distrev.5.e}
		bind $f.5.e <Down> {focus .distrev.6.e}
		bind $f.6.e <Down> {focus .distrev.7.e}
		bind $f.7.e <Down> {focus .distrev.8.e}
		bind $f.8.e <Down> {focus .distrev.1.e}
		bind $f <Return> {set pr_distrev 1}
		bind $f <Escape> {set pr_distrev 0}
	}
	.distrev.0.po config -text "" -bd 0 -command {} -bg [option get . background {}] -state disabled
	.distrev.0.so config -text "" -bd 0 -command {} -bg [option get . background {}] -state disabled
	.distrev.01.so config -text "" -bd 0 -command {} -bg [option get . background {}] -state disabled
	.distrev.0.ok config -bg $evv(EMPH)
	set pr_distrev 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_distrev $f.1.e
	while {!$finished} {
		tkwait variable pr_distrev
		switch -- $pr_distrev {
			1 {
				.distrev.01.so config -text "" -bd 0 -command {} -bg [option get . background {}] -state disabled

				;#	CHECK INPUT PARAMS

				if {([string length $distrev(spl)] <= 0) || ![IsNumeric $distrev(spl)] || ($distrev(spl) < 0) || ($distrev(spl) > 50)} {
					Inf "Invalid splice-length (range 0 to 50 ms)"
					continue
				}
				if {([string length $distrev(stt)] <= 0) || ![IsNumeric $distrev(stt)] || ($distrev(stt) < 0) || ($distrev(stt) >= $dur)} {
					Inf "Invalid start-time of \"sustain\" in input sound (range 0 to <$dur)"
					continue
				}
				if {([string length $distrev(rep)] <= 0) || ![regexp {^[0-9]+$} $distrev(rep)] || ![IsNumeric $distrev(rep)] || ($distrev(rep) < 2) || ($distrev(rep) > 64)} {
					Inf "Invalid distort repeat-count (range 2 to 64)"
					continue
				}
				if {([string length $distrev(cycgp)] <= 0) || ![regexp {^[0-9]+$} $distrev(cycgp)] || ![IsNumeric $distrev(cycgp)] || ($distrev(cycgp) < 1) || ($distrev(cycgp) > 64)} {
					Inf "Invalid distort waveset-group-count (range 1 to 64)"
					continue
				}
				if {([string length $distrev(stad)] <= 0) || ![IsNumeric $distrev(stad)] || ($distrev(stad) < 0.01) || ($distrev(stad) >= 10.0)} {
					Inf "Invalid reverberation stadium-size multiplier (range 0.01 to 10)"
					continue
				}
				if {([string length $distrev(echo)] <= 0) || ![regexp {^[0-9]+$} $distrev(echo)] || ![IsNumeric $distrev(echo)] || ($distrev(echo) < 2) || ($distrev(echo) >= 1000)} {
					Inf "Invalid reverberation echo-count (range 2 to 1000)"
					continue
				}
				if {([string length $distrev(tstr)] <= 0) || ![IsNumeric $distrev(tstr)] || ($distrev(tstr) < 1) || ($distrev(tstr) >= 1000)} {
					Inf "Invalid time-stretch (range >1 to 1000)"
					continue
				}
				set diststrend [expr $dur * ($distrev(rep) - 1)]								;#	input snd length to rev
				set diststrend [expr $diststrend + (0.1 * $distrev(echo) * $distrev(stad))]		;#	added length from delays
				if {([string length $distrev(crend)] <= 0) || ![IsNumeric $distrev(crend)] || ($distrev(crend) < 1) || ($distrev(crend) >= $diststrend)} {
					Inf "Invalid crossfade end (range >$distrev(stt) to around $diststrend)"
					continue
				}
				if {[string length $distrev(ofnam)] <= 0} {
					Inf "No output filename entered"
					continue
				}
				if {![ValidCDPRootname $distrev(ofnam)]} {
					continue
				}
				set ofnam [string tolower $distrev(ofnam)]
				append ofnam $evv(SNDFILE_EXT) 
				if {[file exists $ofnam]} {
					Inf "A file with the name '$ofnam' already exists: please choose a different name"
					continue
				}

				Block "Running Distort Reverb Process"

				;#	IF PROCESS HAS SUCCESSFULLY RUN PREVIOUSLY, CHECK IF ANY PARAMETERS HAVE CHANGED SINCE

				if {[info exists distbak]} {
					set changed [DistrevParamsChanged]
					if {!$changed} {
						Inf "No change in the input parameters"
						UnBlock
						continue
					}
					if {[file exists $oofnam] && ([catch {file delete $oofnam} zit])} {
						Inf "Cannot delete existing output file $oofnam"
						UnBlock
						continue
					}
					if {!$distsame(stt)} {
						DeleteAllTemporaryFilesExcept $fnamn $fnamana		;#	Always retain the "normalised" input, delete all else
					} else {
						if {!$distsame(tstr)} {								;#	if tstr params changed, delete tstretch brkfile and tstretched sndfiles
							catch {file delete $tstr}
							catch {file delete $fnamtsana}
							catch {file delete $fnamts}
						}													;#	if distort params change, delete distorted file and all its followers
						if {!$distsame(rep) || !$distsame(cycgp) || !$distsame(spl)} {
							catch {file delete $fnamd}
							catch {file delete $fnamdc}
							catch {file delete $fnamdcr}
							catch {file delete $fnamdcrm}
						} elseif {!$distsame(stad) || !$distsame(echo)} {	;#	if distort params NOT changed, but rev params changed - delete the rev outputs
							catch {file delete $fnamdcr}
							catch {file delete $fnamdcrm}
						} elseif {!$distsame(crend)} {						;#	if crossfade params ONLY changed - delete ofnams
							catch {file delete $oofnam }
						}
					}
				}

				;#	MAKE TIMESTRETCH FILE

				set OK 1
				
				if {![file exists $tstr]} {				;#	tstr = Time-stretch envelope file

					wm title .blocker "Creating Timestretch brkpnt file"

					catch {unset lines}
					set line [list 0.0 1.0]
					lappend lines $line
					set line [list $distrev(stt) 1.0]
					lappend lines $line
					set line [list [expr $distrev(stt) + 0.03] $distrev(tstr)]
					lappend lines $line
					set line [list $dur $distrev(tstr)]
					lappend lines $line
					if [catch {open $tstr "w"} zit] {
						Inf "Cannot open time-stretch envelope file : $zit"
						DistrevParamsRemember
						UnBlock
						continue
					}
					foreach line $lines {
						puts $zit $line
					}
					close $zit
				}

				;#	SET INPUT LEVEL TO HALF MAXIMUM GAIN (AVOID DISTORT IN PVOC PROCESS)		fnamn = Normalised (to half-level) infile

				while {$OK} {
					if {![file exists $fnamn]} {				
						wm title .blocker "PLEASE WAIT:        ADJUSTING INPUT LEVEL"
						set cmd [file join $evv(CDPROGRAM_DIR) modify]
						lappend cmd loudness 4 $ifnam $fnamn -l0.5
						set prg_dun 0
						set prg_abortd 0
						catch {unset simple_program_messages}
						if [catch {open "|$cmd"} CDPidrun] {
							ErrShow "CANNOT RUN PROCESS TO ADJUST INPUT LEVEL: $CDPidrun"
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
							set msg "Cannot create adjusted level input"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							set OK 0
							break
						}
						if {![file exists $fnamn]} {
							set msg "No adjusted level input file created"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							set OK 0
							break
						}
					}

				;#	ANALYSIS OF INPUT FILE		fnamana = Associated analysis file of Normalised infile

					if {![file exists $fnamana]} {
						wm title .blocker "PLEASE WAIT:        EXTRACTING SPECTRUM"
						set cmd [file join $evv(CDPROGRAM_DIR) pvoc]
						lappend cmd anal 1 $fnamn $fnamana -c1024 -o3
						set prg_dun 0
						set prg_abortd 0
						catch {unset simple_program_messages}
						if [catch {open "|$cmd"} CDPidrun] {
							ErrShow "CANNOT RUN PROCESS TO EXTRACT SPECTRUM OF INPUT FILE: $CDPidrun"
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
							set msg "Cannot create spectrum of input file"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							set OK 0
							break
						}
						if {![file exists $fnamana]} {
							set msg "No input file spectrum created"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							set OK 0
							break
						}
					}

				;#	TIMESTRETCH OF INPUT FILE		fnamtsana = Tstretched analfile

					if {![file exists $fnamtsana]} {
						wm title .blocker "PLEASE WAIT:        TIME-STRETCHING SPECTRUM"
						set cmd [file join $evv(CDPROGRAM_DIR) stretch]
						lappend cmd time 1 $fnamana $fnamtsana $tstr
						set prg_dun 0
						set prg_abortd 0
						catch {unset simple_program_messages}
						if [catch {open "|$cmd"} CDPidrun] {
							ErrShow "CANNOT RUN PROCESS TO TIMESTRETCH INPUT FILE SPECTRUM: $CDPidrun"
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
							set msg "Cannot create time-stretched spectrum of input file"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							set OK 0
							break
						}
						if {![file exists $fnamtsana]} {
							set msg "No time-stretched spectrum created"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							set OK 0
							break
						}
					}

				;#	RESYNTHESIS OF TIMESTRETCHED INPUT FILE		fnamts = Tstretched infile

					if {![file exists $fnamts]} {
						wm title .blocker "PLEASE WAIT:        RESYNTHESIZING TIME-STRETCHED SOUNDFILE"
						set cmd [file join $evv(CDPROGRAM_DIR) pvoc]
						lappend cmd synth $fnamtsana $fnamts
						set prg_dun 0
						set prg_abortd 0
						catch {unset simple_program_messages}
						if [catch {open "|$cmd"} CDPidrun] {
							ErrShow "CANNOT RUN PROCESS TO RESYNTHESIZE : $CDPidrun"
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
							set msg "Cannot create time-stretched soundfile"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							set OK 0
							break
						}
						if {![file exists $fnamts]} {
							set msg "No time-stretched soundfile created"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							set OK 0
							break
						}
					}

				;#	DISTORT INPUT FILE		fnamd = Distorted infile

					if {![file exists $fnamd]} {
						wm title .blocker "PLEASE WAIT:        DISTORTING INPUT FILE"
						set cmd [file join $evv(CDPROGRAM_DIR) distrep]
						lappend cmd distrep 1 $ifnam $fnamd $distrev(rep) $distrev(cycgp) -k1 -s$distrev(spl)
						set prg_dun 0
						set prg_abortd 0
						catch {unset simple_program_messages}
						if [catch {open "|$cmd"} CDPidrun] {
							ErrShow "CANNOT RUN PROCESS TO DISTORT INPUT FILE: $CDPidrun"
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
							set msg "Cannot create distorted input file"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							set OK 0
							break
						}
						if {![file exists $fnamd]} {
							set msg "No distorted input file created"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							set OK 0
							break
						}
					}

				;#	CUT START OFF DISTORTED FILE	fnamdc = Distorted infile with start cut off

					if {![file exists $fnamdc]} {
						set cuttime [expr ($distrev(rep) - 1) * $distrev(stt)]

						wm title .blocker "PLEASE WAIT:        SHORTENING DISTORTED FILE"
						set cmd [file join $evv(CDPROGRAM_DIR) sfedit]
						lappend cmd excise 1 $fnamd $fnamdc 0 $cuttime -w15
						set prg_dun 0
						set prg_abortd 0
						catch {unset simple_program_messages}
						if [catch {open "|$cmd"} CDPidrun] {
							ErrShow "CANNOT RUN PROCESS TO SHORTEN DISTORTED FILE: $CDPidrun"
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
							set msg "Cannot create shortened distorted file"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							set OK 0
							break
						}
						if {![file exists $fnamdc]} {
							set msg "No shortened distorted file created"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							set OK 0
							break
						}
					}

				;#	REVERB THE CUT DISTORTED FILE	fnamdcr = Distorted infile reverbd

					if {![file exists $fnamdcr]} {
						wm title .blocker "PLEASE WAIT:        REVERBING DISTORTED FILE"
						set cmd [file join $evv(CDPROGRAM_DIR) modify]
						lappend cmd revecho 3 $fnamdc $fnamdcr -g1 -r1 -s$distrev(stad) -e$distrev(echo) -n
						set prg_dun 0
						set prg_abortd 0
						catch {unset simple_program_messages}
						if [catch {open "|$cmd"} CDPidrun] {
							ErrShow "CANNOT RUN REVERBERATION PROCESS: $CDPidrun"
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
							set msg "Cannot create reverberated file"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							set OK 0
							break
						}
						if {![file exists $fnamdcr]} {
							set msg "No reverberated file created"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							set OK 0
							break
						}
					}

				;#	CONVERT REVERBED FILE TO MONO	fnamdcrm = Distorted infile reverbd to mono

					if {![file exists $fnamdcrm]} {
						wm title .blocker "PLEASE WAIT:        CONVERTING REVERBED FILE TO MONO"
						set cmd [file join $evv(CDPROGRAM_DIR) housekeep]
						lappend cmd chans 4 $fnamdcr $fnamdcrm
						set prg_dun 0
						set prg_abortd 0
						catch {unset simple_program_messages}
						if [catch {open "|$cmd"} CDPidrun] {
							ErrShow "CANNOT RUN CONVERSION TO MONO: $CDPidrun"
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
							set msg "Cannot create mono reverb file"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							set OK 0
							break
						}
						if {![file exists $fnamdcrm]} {
							set msg "No mono reverb file created"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							set OK 0
							break
						}
					}
					if {[DoParse $fnamts 0 0 0] <= 0} {
						Inf "Cannot check duration of time-stretched file"
						set OK 0
						break
					}
					set dur1 $pa($fnamts,$evv(DUR))
					if {[DoParse $fnamdcrm 0 0 0] <= 0} {
						Inf "Cannot check duration of distort-reverbd file"
						set OK 0
						break
					}
					set dur2 $pa($fnamdcrm,$evv(DUR))
					if {$distrev(crend) >= $dur1} {
						Inf "End of crossfade ($distrev(crend)) beyond end of time-stretched source ($dur1)"
						set OK 0
						break
					}
					if {$distrev(crend) >= $dur2} {
						Inf "End of crossfade ($distrev(crend)) beyond end of distorted source ($dur2)"	
						set OK 0
						break
					}

				;#	CROSSFADE FROM INPUT (TSTRETCHED) TO DISTORTED-REV-MONO

					wm title .blocker "PLEASE WAIT:        CROSSFADING FROM SOURCE TO DISTORT-REVERB"
					set cmd [file join $evv(CDPROGRAM_DIR) submix]
					lappend cmd crossfade 1 $fnamts $fnamdcrm $oofnam -s0 -b$distrev(stt) -e$distrev(crend)
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					if [catch {open "|$cmd"} CDPidrun] {
						ErrShow "CANNOT RUN CROSSFADE PROCESS: $CDPidrun"
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
						set msg "Cannot create crossfaded file"
						set msg [AddSimpleMessages $msg]
						ErrShow $msg
						set OK 0
						break
					}
					if {![file exists $oofnam]} {
						set msg "No crossfaded file created"
						set msg [AddSimpleMessages $msg]
						ErrShow $msg
						set OK 0
						break
					}
					break			;#	If successful, break out of OK loop
				}
				DistrevParamsRemember
				if {!$OK} {
					UnBlock
					continue
				}

				;#	AT END, REMEMBER PARAMETER SETTINGS OF THIS SUCCESSFUL RUN

				.distrev.0.po config -text "Play output" -bd 2 -command "set pr_distrev 2" -bg $evv(SNCOLOROFF) -state normal
				.distrev.0.so config -text "Save output" -bd 2 -command "set pr_distrev 3" -bg $evv(EMPH) -state normal
				.distrev.01.so config -text "Save Intermediate Outputs" -bd 2 -command "set pr_distrev 6" -state normal
				.distrev.0.ok config -bg [option get . background {}]
				UnBlock
			}
			2 {
				;#	PLAY OUTPUT
				if {![file exists $oofnam]} {
					Inf "Cannot find the output file"
				} else {
					if {[DoParse $oofnam 0 0 0] <= 0} {
						Inf "Cannot check properties of output file: cannot display"
						PlaySndfile $oofnam 0
					}
					SnackDisplay 0 $evv(SN_FROM_REVDIST_OUTPUT) 0 $oofnam
				}
			}
			3 {
				;#	SAVE OUTPUT
				if [catch {file rename $oofnam $ofnam} zit] {
					Inf "Cannot rename the output file to [file rootname [file tail $ofnam]]"
				} else {
					if {[FileToWkspace $ofnam 0 0 0 0 1] > 0}  {
						Inf "File $ofnam is on the workspace"
					} else {
						Inf "File $ofnam saved"
					}
					.distrev.0.po config -text "" -bd 0 -command {} -bg [option get . background {}] -state disabled
					.distrev.0.so config -text "" -bd 0 -command {} -bg [option get . background {}] -state disabled
					.distrev.0.ok config -bg $evv(EMPH)
				}
				DistrevSaveParams
			}
			6 {
				;#	SAVE INTERMEDIATE OUTPUTS
				set xfnam [file rootname $ofnam]
				set xfnam1 $xfnam
				append xfnam1 "_distonly" $evv(SNDFILE_EXT)
				set xfnam2 $xfnam
				append xfnam2 "_distrevonly" $evv(SNDFILE_EXT)
				set xfnam3 $xfnam
				append xfnam3 "_tstronly" $evv(SNDFILE_EXT)
				set kmsg ""
				set jmsg ""
				set qmsg ""
				if {[file exists $xfnam1]} {
					set aamsg "FILE $xfnam1 ALREADY EXISTS : OVERWRITE IT"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $aamsg]
					if {$choice == "no"} {
						append kmsg "\nOLD VERSION of $xfnam1 Already exists"
					} else {
						$wl selection clear 0 end
						set j [LstIndx $xfnam1 $wl]
						if {$j >= 0} {
							$wl selection set $j
							DeleteFromSystem 0
						}
					}
				}
				if {![file exists $xfnam1]} {
					if [catch {file copy $fnamdc $xfnam1} zit] {
						append jmsg "\nCANNOT RENAME THE DISTORT FILE TO [file rootname [file tail $xfnam1]]"
					} elseif {[FileToWkspace $xfnam1 0 0 0 0 1] > 0}  {
						append qmsg "\nFILE $xfnam1 IS ON THE WORKSPACE"
					} else {
						append qmsg "\nFILE $xfnam1 SAVED"
					}
				}
				if {[file exists $xfnam2]} {
					set aamsg "FILE $xfnam2 ALREADY EXISTS : OVERWRITE IT"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $aamsg]
					if {$choice == "no"} {
						append kmsg "\nOLD VERSION of $xfnam2 Already exists"
					} else {
						$wl selection clear 0 end
						set j [LstIndx $xfnam2 $wl]
						if {$j >= 0} {
							$wl selection set $j
							DeleteFromSystem 0
						}
					}
				}
				if {![file exists $xfnam2]} {
					if [catch {file copy $fnamdcrm $xfnam2} zit] {
						append jmsg "\nCANNOT RENAME THE REVERBED DISTORT FILE TO [file rootname [file tail $xfnam2]]"
					} elseif {[FileToWkspace $xfnam2 0 0 0 0 1] > 0}  {
						append qmsg "\nFILE $xfnam2 IS ON THE WORKSPACE"
					} else {
						append qmsg "\nFILE $xfnam2 SAVED"
					}
				}
				if {[file exists $xfnam3]} {
					set aamsg "FILE $xfnam3 ALREADY EXISTS : OVERWRITE IT"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $aamsg]
					if {$choice == "no"} {
						append kmsg "\nOLD VERSION of $xfnam3 Already exists"
					} else {
						$wl selection clear 0 end
						set j [LstIndx $xfnam3 $wl]
						if {$j >= 0} {
							$wl selection set $j
							DeleteFromSystem 0
						}
					}
				}
				if {![file exists $xfnam3]} {
					if [catch {file copy $fnamts $xfnam3} zit] {
						append jmsg "\nCANNOT RENAME THE TIMESTRETCHED FILE TO [file rootname [file tail $xfnam3]]"
					} elseif {[FileToWkspace $xfnam3 0 0 0 0 1] > 0}  {
						append qmsg "\nFILE $xfnam3 IS ON THE WORKSPACE"
					} else {
						append qmsg "\nFILE $xfnam3 SAVED"
					}
				}
				if {[string length $kmsg] > 0} {
					if {[string length $jmsg] > 0} {
						append kmsg $jmsg
					}
					if {[string length $qmsg] > 0} {
						append kmsg $qmsg
					}
				} elseif {[string length $jmsg] > 0} {
					set kmsg $jmsg
					if {[string length $qmsg] > 0} {
						append kmsg $qmsg
					}
				} elseif {[string length $qmsg] > 0} {
					set kmsg $qmsg
				}
				if {[string length $kmsg] > 0} {
					Inf $kmsg
				}
				.distrev.01.so config -text "" -bd 0 -command {} -bg [option get . background {}] -state disabled
			}
			4 {
				;#	PLAY INPUT
					SnackDisplay $evv(SN_SINGLETIME) distrev $evv(TIME_OUT) 0
			}
			5 {
				set msg "                                     REVERB DISTORT\n"
				append msg "\n"
				append msg "The input file is distorted by repetition of waveset(group)s\n"
				append msg "and this material is then reverberated.\n"
				append msg "\n"
				append msg "A crossfade is made from the original, after an appropriate time\n"
				append msg "(usually when sound has reached its peak, or a \"stable\" state).\n"
				append msg "\n"
				append msg "This time can be entered from the graphic display\n"
				append msg " of the input sound, at \"View Input\".\n"
				append msg "\n"
				append msg "The original sound can also be timestretched (after that time)\n"
				append msg "to ensure there is enough of it to permit the cross-fade to happen.\n"
				append msg "\n"
				append msg "Distortion parameters are those for \"DISTORT REPEAT (WITH SPLICES)\" i.e.\n"
				append msg "\n"
				append msg "            repetition-count = REPETITION COUNT\n"
				append msg "                     Range 2 to 64\n"
				append msg "            waveset-group count = COUNT OF WAVESETS IN GROUP TO REPEAT\n"
				append msg "                     Range 1 to 64\n"
				append msg "            Distort splicelength (mS) = SPLICELENGTH(mS)\n"
				append msg "                     Range 0 to 50\n"
				append msg "\n"
				append msg "Reverb parameters are as for \"MODIFY : REV/ECHO : STADIUM\"\n"
				append msg "\n"
				append msg "            stadium-size multiplier = STADIUM SIZE MULTIPLIER\n"
				append msg "            stadium echocount = NUMBER OF ECHOS\n"
				append msg "\n"
				Inf $msg
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

proc DistrevParamsChanged {} {
	global distrev distbak distsame
	set haschanged 0
	foreach name [array names distrev] {
		if {($name == "ofnam") ||  ($name == "ifnam")} {
			continue
		}
		if {$distrev($name) != $distbak($name)} {
			set distsame($name) 0
			set haschanged 1
		} else {
			set distsame($name) 1
		}
	}
	return $haschanged
}

proc DistrevParamsRemember {} {
	global distrev distbak	
	foreach name [array names distrev] {
		set distbak($name) $distrev($name)
	}
}

proc DistrevLoadParams {dur} {
	global distrev evv
	set fnam [file join $evv(URES_DIR) "distrev"]
	append fnam $evv(CDP_EXT)
	if {![file exists $fnam]} {
		return 0
	}
	catch {unset params}
	if {[catch {open $fnam "r"} zit]} {
		Inf "Cannot open distort reverb data file ($fnam) : cannot load last patch"
		catch {file delete $fnam}
		return 0
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		set line [split $line]
		set cnt 0
		catch {unset nuline}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			lappend params $item
		}
	}
	close $zit
	if {![info exists params] || ([llength $params] != 8)} {
		Inf "Corrupted data in distort reverb data file ($fnam) : cannot load last patch"
		catch {file delete $fnam}
		return 0
	}
	set cnt [llength $params]
	set n 0
	while {$n < $cnt} {
		set param [lindex $params $n]
		if {![IsNumeric $param]} {
			Inf "Corrupted data in distort reverb data file ($fnam) : cannot load last patch"
			catch {file delete $fnam}
			return 0
		}
		switch -- $n {
			0 {	;#	distrev(stt)
				set lo	0.0 
				set hi	[expr $dur - 0.01]
				set msg "Start time of stability"
			}
			1 { ;#	distrev(rep)
				set lo	2 
				set hi	64
				set msg "Repetition count"
			}
			2 {	;#	distrev(cycgp)
				set lo	1 
				set hi	64
				set msg "Waveset-group count"
			}
			3 {	;#	distrev(stad)
				set lo	0.01 
				set hi	10
				set msg "Stadium-size multiplier"
			}
			4 {	;#	distrev(echo)
				set lo	2 
				set hi	1000
				set msg "Stadium echo-count"
			}
			5 {	;#	distrev(tstr)
				set lo	1.0001 
				set hi	1000
				set msg "Time-stretch of input tail"
			}
			6 {	;#	distrev(crend)
				set lo 0.0
				set hi 100000			;# arbitrary highval
				set msg "End time of crossfade"
			}
			7 {	;#	distrev(spl)
				set lo	0
				set hi	50
				set msg "Splice length"
			}
		}
		if {($param < $lo) || ($param > $hi)} {
			Inf "Parameter ($msg) out of range\nin data file ($fnam)\n\ncannot load last patch"
			catch {file delete $fnam}
			return 0
		}
		incr n
	}
	set n 0
	while {$n < $cnt} {
		set param [lindex $params $n]
		switch -- $n {
			0 { set distrev(stt)   $param }
			1 { set distrev(rep)   $param }
			2 { set distrev(cycgp) $param }
			3 { set distrev(stad)  $param }
			4 { set distrev(echo)  $param }
			5 { set distrev(tstr)  $param }
			6 { set distrev(crend) $param }
			7 { set distrev(spl)   $param }
		}
		incr n
	}
	return 1
}

#---- Save Distrev parameters

proc DistrevSaveParams {} {
	global distrev evv
	set fnam [file join $evv(URES_DIR) "distrev"]
	append fnam $evv(CDP_EXT)
	set	params [list $distrev(stt) $distrev(rep) $distrev(cycgp) $distrev(stad) $distrev(echo) $distrev(tstr) $distrev(crend) $distrev(spl)]
	if {[catch {open $fnam "w"} zit]} {
		Inf "Cannot open data file ($fnam) to save current patch"
		return
	}
	foreach param $params {
		puts $zit $param
	}
	close $zit
}

#--- Fast Convolution

proc FastConvolution {} {
	global chlist wl evv pa fcofnam pr_fc prg_dun prg_abortd simple_program_messages CDPidrun
	global maxsamp_line done_maxsamp CDPmaxId

	set outfnam $evv(DFLT_OUTNAME)
	append outfnam 0 $evv(SNDFILE_EXT)

	set OK 1
	if {[info exists chlist] && ([llength $chlist] == 2)} {
		set ifnam1 [lindex $chlist 0]
		set ifnam2 [lindex $chlist 1]
	} else {
		set ilist [$wl curselection]
		if {[llength $ilist] == 2} {
			set ifnam1 [$wl get [lindex $ilist 0]]
			set ifnam2 [$wl get [lindex $ilist 1]]
		}
	}
	if {![info exists ifnam1] || ![info exists ifnam2]}  {
		set OK 0
	} elseif {($pa($ifnam1,$evv(TYP)) != $evv(SNDFILE)) || ($pa($ifnam2,$evv(TYP)) != $evv(SNDFILE))} {
		set OK 0
	} else {
		set chans $pa($ifnam1,$evv(CHANS))
		if {$pa($ifnam2,$evv(CHANS)) !=  $chans} {
			set OK 0
		}
	}
	if {!$OK} {
		Inf "Select two mono or two stereo soundfiles"
		return
	}
	set f .fc
	if [Dlg_Create $f "FAST CONVOLUTION" "set pr_fc 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0] 
		set f1 [frame $f.1] 
		button $f0.ok -text "Convolve" -command "set pr_fc 1" -width 8 -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $f0.qq -text "Abandon" -command "set pr_fc 0"  -width 8 -highlightbackground [option get . background {}]
		pack $f0.ok -side left
		pack $f0.qq -side right
		pack $f0 -side top -fill x -expand true
		entry $f1.e -textvariable fcofnam -width 24
		label $f1.ll -text "Output Filename"
		pack $f1.e $f1.ll -side left
		pack $f1 -side top -pady 2
		wm resizable $f 0 0
		bind $f <Return> {set pr_fc 1}
		bind $f <Escape> {set pr_fc 0}
	}
	set zz [file rootname [file tail $ifnam1]]
	append zz "_fc"
	set fcofnam $zz
	set pr_fc 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_fc $f.1.e
	while {!$finished} {
		tkwait variable pr_fc
		switch -- $pr_fc {
			1 {
				DeleteAllTemporaryFiles

				;#	CHECK INPUT PARAMS

				if {[string length $fcofnam] <= 0} {
					Inf "No output filename entered"
					continue
				}
				if {![ValidCDPRootname $fcofnam]} {
					continue
				}
				set ofnam [string tolower $fcofnam]
				append ofnam $evv(SNDFILE_EXT) 
				if {[file exists $ofnam]} {
					Inf "A file with the name '$ofnam' already exists: please choose a different name"
					continue
				}

				Block "Running Fast Convolution Process"
				set OK 1
				set renormalise 1

				;#	GET MAX LEVEL OF 1ST INPUT FILE (FOR RENORMALISATION OF OUTPUT)

				while {$OK} {
					while {$renormalise} {
						wm title .blocker "PLEASE WAIT:        FINDING MAXIMUM LEVEL OF INPUT FILE"
						set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
						catch {unset maxsamp_line}
						set done_maxsamp 0
						lappend cmd $ifnam1
						if [catch {open "|$cmd"} CDPmaxId] {
							Inf "Failed to run 'maxsamp2$evv(exec)'"
							set renormalise 0
							break
	   					} else {
	   						fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
						}
	 					vwait done_maxsamp
						if {![info exists maxsamp_line]} {
							Inf "Cannot retrieve maximum sample information from [file rootname [file tail $ifnam1]]"
							set renormalise 0
							break
						}
						set maxinsamp [lindex $maxsamp_line 0]
						if {$maxinsamp < $evv(FLTERR)} {
							Inf "Insufficient level in file [file rootname [file tail $ifnam1]]"
							set OK 0
							break
						}
						break
					}
					if {!$OK} {
						break
					}

				;#	DO FAST CONVOLUTION

					wm title .blocker "PLEASE WAIT:        RUNNING FAST CONVOLUTION"
					set cmd [file join $evv(CDPROGRAM_DIR) fastconv]
					lappend cmd -f $ifnam1 $ifnam2 $outfnam
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					if [catch {open "|$cmd"} CDPidrun] {
						ErrShow "CANNOT RUN FAST CONVOLUTION PROCESS: $CDPidrun"
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
						set msg "Cannot create convolved file"
						set msg [AddSimpleMessages $msg]
						ErrShow $msg
						set OK 0
						break
					}
					if {![file exists $outfnam]} {
						set msg "No convolved file created"
						set msg [AddSimpleMessages $msg]
						ErrShow $msg
						set OK 0
						break
					}

				;#	IF RENORMALISATION STILL POSSIBLE, ATTEMP TO RENORMALISE OUTPUT

					while {$renormalise} {									;#	IF renormalise is already zero, this loop is skipped

						wm title .blocker "PLEASE WAIT:        FINDING MAXIMUM LEVEL OF CONVOLVED FILE"
						set cmd [file join $evv(CDPROGRAM_DIR) maxsamp2]
						catch {unset maxsamp_line}
						set done_maxsamp 0
						lappend cmd $outfnam
						if [catch {open "|$cmd"} CDPmaxId] {
							Inf "Failed to run 'maxsamp2$evv(exec)' on convolved file"
							set renormalise 0
							break
	   					} else {
	   						fileevent $CDPmaxId readable "Display_Maxsamp_Info_Wksp"
						}
	 					vwait done_maxsamp
						if {![info exists maxsamp_line]} {
							Inf "Cannot retrieve maximum sample information from convolved file"
							set renormalise 0
							break
						}
						set maxoutsamp [lindex $maxsamp_line 0]
						if {$maxoutsamp < $evv(FLTERR)} {
							Inf "Insufficient level in convolved file to renormalise it"
							set renormalise 0
							break
						}
						if {$maxoutsamp > $maxinsamp} {
							set renormalise 0
							break
						}
						set gain [expr $maxinsamp/$maxoutsamp]

						wm title .blocker "PLEASE WAIT:        RENORMALISING CONVOLVED FILE"
						set cmd [file join $evv(CDPROGRAM_DIR) modify]
						lappend cmd loudness 1 $outfnam $ofnam $gain
						set prg_dun 0
						set prg_abortd 0
						catch {unset simple_program_messages}
						if [catch {open "|$cmd"} CDPidrun] {
							ErrShow "CANNOT RUN RENORMALISATION PROCESS: $CDPidrun"
							catch {unset CDPidrun}
							set renormalise 0
							break
						} else {
							fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
						}
						vwait prg_dun
						if {$prg_abortd} {
							set prg_dun 0
						}
						if {!$prg_dun} {
							set msg "Cannot renormalise the convolved file"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							set renormalise 0
							break
						}
						if {![file exists $ofnam]} {
							set msg "No renormalised convolved file created : cannot renormalise convolved file"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							set renormalise 0
							break
						}
						break
					}
					if {!$renormalise} {
						if [catch {file rename $outfnam $ofnam} zit] {
							Inf "Cannot rename the un-normalised convolved file as $ofnam"
							set OK 0
							break
						}
					}
					break
				}
				if {!$OK} {
					UnBlock
					continue
				}
				if {[FileToWkspace $ofnam 0 0 0 0 1] > 0}  {
					Inf "File $ofnam is on the workspace"
				} else {
					Inf "File $ofnam saved"
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

#---- Extract sudden onsets

proc ExtractSuddenOnsets {} {
	global chlist wl evv pa pr_xo xofnam xojump prg_dun prg_abortd simple_program_messages CDPidrun

	set envfnam $evv(DFLT_OUTNAME)
	append envfnam 0 $evv(TEXT_EXT)

	set OK 1
	if {[info exists chlist] && ([llength $chlist] == 1)} {
		set fnam [lindex $chlist 0]
	} else {
		set ilist [$wl curselection]
		if {([llength $ilist] == 1) && ($ilist != -1)} {
			set fnam [$wl get [lindex $ilist 0]]
		}
	}
	if {![info exists fnam]}  {
		set OK 0
	} elseif {($pa($fnam,$evv(TYP)) != $evv(SNDFILE))} {
		set OK 0
	}
	if {!$OK} {
		Inf "Select a soundfile"
		return
	}
	set f .xo
	if [Dlg_Create $f "EXTRACT SUDDEN ONSETS" "set pr_xo 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0] 
		set f1 [frame $f.1] 
		set f2 [frame $f.2] 
		button $f0.ok -text "Extract" -command "set pr_xo 1" -width 8 -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $f0.qq -text "Quit" -command "set pr_xo 0"  -width 8 -highlightbackground [option get . background {}]
		pack $f0.ok -side left
		pack $f0.qq -side right
		pack $f0 -side top -fill x -expand true
		entry $f1.e -textvariable xojump -width 24
		label $f1.ll -text "Onset Jump (Range : level upstep 0.01 to 1)"
		pack $f1.e $f1.ll -side left
		pack $f1 -side top -pady 2
		entry $f2.e -textvariable xofnam -width 24
		label $f2.ll -text "Output Filename"
		pack $f2.e $f2.ll -side left
		pack $f2 -side top -pady 2
		wm resizable $f 0 0
		bind $f <Return> {set pr_xo 1}
		bind $f <Escape> {set pr_xo 0}
	}
	set zz [file rootname [file tail $fnam]]
	append zz "_xo"
	set xofnam $zz
	set pr_xo 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_xo $f.1.e
	while {!$finished} {
		tkwait variable pr_xo
		switch -- $pr_xo {
			1 {
				DeleteAllTemporaryFiles
				if {([string length $xojump] <= 0) || ![IsNumeric $xojump] || ($xojump < 0.01) || ($xojump > 1.0)} {
					Inf "Invalid onset step (range 0.01 to 1)"
					continue
				}
				if {[string length $xofnam] <= 0} {
					Inf "No output filename entered"
					continue
				}
				if {![ValidCDPRootname $xofnam]} {
					continue
				}
				set ofnam [string tolower $xofnam]
				append ofnam $evv(TEXT_EXT) 
				if {[file exists $ofnam]} {
					Inf "A file with the name '$ofnam' already exists: please choose a different name"
					continue
				}
				Block "Extracting sound envelope"
				set OK 1
				while {$OK} {	
					set cmd [file join $evv(CDPROGRAM_DIR) envel]
					lappend cmd extract 2 $fnam $envfnam 5 -d0
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					if [catch {open "|$cmd"} CDPidrun] {
						ErrShow "CANNOT RUN ENVELOPE EXTRACTION PROCESS: $CDPidrun"
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
						set msg "Cannot extract sound envelope"
						set msg [AddSimpleMessages $msg]
						ErrShow $msg
						set OK 0
						break
					}
					if {![file exists $envfnam]} {
						set msg "No envelope extracted"
						set msg [AddSimpleMessages $msg]
						ErrShow $msg
						set OK 0
						break
					}
					wm title .blocker "PLEASE WAIT:        SEARCHING FOR SUDDDEN ONSETS"
					if [catch {open $envfnam "r"} zit] {
						Inf "Cannot open intermediate envelope file to read data"
						set OK 0
						break
					}
					catch {unset edata}
					while {[gets $zit line] >= 0} {
						set line [string trim $line]
						if {[string length $line] <= 0} {
							continue
						}
						set line [split $line]
						set cnt 0
						catch {unset vals}
						foreach item $line {
							set item [string trim $item]
							if {[string length $item] <= 0} {
								continue
							}
							lappend vals $item
						}
						if {![info exists vals] || ([llength $vals] != 2)}  {
							Inf "Invalid line ($line) in intermediate envelope data"
							set OK 0
							break
						}
						lappend edata $vals
					}
					close $zit
					if {![info exists edata]} {
						Inf "No data found in intermediate envelope file"
						set OK 0
						break
					}
					set len [llength $edata]
					if {[llength $edata] <= 1} {
						Inf "Insufficient data found in intermediate envelope file"
						set OK 0
						break
					}
					set lastval [lindex [lindex $edata 0] 1]
					set n 1
					catch {unset onsets}
					while {$n < $len} {
						set vals [lindex $edata $n]
						set val [lindex $vals 1]
						if {[expr $val - $lastval] >= $xojump} {
							lappend onsets [lindex $vals 0]			
						}
						set lastval $val
						incr n
					}
					if {![info exists onsets]} {
						Inf "No sudden onsets found with jump set to $xojump"
						set OK 0
						break
					}		
					if [catch {open $ofnam "w"} zit] {
						Inf "Cannot open output file $ofnam to write onset data : $zit"
						set OK 0
						break
					}		
					foreach onset $onsets {
						puts $zit $onset
					}
					close $zit
					if {[FileToWkspace $ofnam 0 0 0 0 1] > 0}  {
						Inf "File $ofnam is on the workspace"
					} else {
						Inf "File $ofnam saved"
					}
					break
				}
				UnBlock
				if {!$OK} {
					continue
				}
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

proc TimesFilesToMix {} {
	global chlist wl evv pa pr_tfm tfmfnam wstk hopperm prg_dun prg_abortd simple_program_messages CDPidrun

	set mfnam $evv(DFLT_OUTNAME)
	append mfnam 0  $evv(TEXT_EXT)

	if {[info exists chlist] && ([llength $chlist] >= 2)} {
		set fnams $chlist
	} else {
		set ilist [$wl curselection]
		if {[llength $ilist] >= 2} {
			foreach i $ilist {
				lappend fnams [$wl get $i]
			}
		}
	}

	set msg "Select one times-list text\file and either\n(1)  one soundfile, ~~or~~\n(2)  a selection of soundfiles"
	if {![info exists fnams]}  {
		Inf $msg
		return
	}
	foreach fnam $fnams {
		if {$pa($fnam,$evv(TYP)) == $evv(SNDFILE)} {
			if {![info exists sfnams]} {
				set chans $pa($fnam,$evv(CHANS))
			} elseif {$chans != $pa($fnam,$evv(CHANS))} {
				Inf "Sndfiles selected do not all have the same number of channels"
				return
			}
			lappend sfnams $fnam
		} else {
			if {[info exists tfnam]} {
				Inf $msg
				return
			} else {
				set tfnam $fnam
			}
		}
	}
	set fnams $sfnams
	if [catch {open $tfnam "r"} zit] {
		Inf "Cannot open file $tfnam"
		return
	}
	set OK 1
	set lasttime -1
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {![IsNumeric $line] || ($line < 0.0)}  {
			Inf "Invalid time ($line) in file $tfnam"
			set OK 0
			break
		}
		if {$line <= $lasttime} {
			Inf "Times do not advance ($lasttime  :  $line) in file $tfnam"
			set OK 0
			break
		}
		set lasttime $line
		lappend times $line
	}
	close $zit
	if {!$OK} {
		return
	}
	if {![info exists times]}  {
		Inf "No time data in file $tfnam"
		return
	}
	set slen [llength $fnams]
	set tlen [llength $times]
	if {($slen > 1) && ($slen != $tlen)} {
		if {$slen > $tlen} {
			Inf "Number of soundfiles ($slen) is greater than number of times in times-list ($tlen)"
			return
		}
		if {$slen < $tlen} {
			set msg "Number of soundfiles ($slen) is less than number of times in times-list ($tlen)\n\nignore the later times ??"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "yes"} {
				set times [lrange $times 0 [expr $slen - 1]]
			} else {
				set msg "Cyclically repeat the sounds ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "yes"} {
					set copfnams $fnams
					set origslen $slen
					set n 0
					while {$slen < $tlen} {
						lappend fnams [lindex $copfnams $n]
						incr n
						if {$n >= $origslen} {
							set n 0
						}
						incr slen
					}
				} else {
					set msg "Randomly repeat the sounds ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "yes"} {
						set nu 0
						while {$nu < $tlen} {
							randperm $slen
							foreach val $hopperm {
								lappend nufnams [lindex $fnams $val]
								incr nu
								if {$nu >= $tlen} {
									break
								}
							}
						}
						set fnams $nufnams
					} else {
						return
					}
				}
			}
		}
	}
	if {$slen == 1} {
		set fnam [lindex $fnams 0]
		unset fnams
		set n 0
		while {$n < $tlen} {
			lappend fnams $fnam
			incr n
		}
	}
	set f .tfm
	if [Dlg_Create $f "MAKE MIXFILE FROM TIME-LIST AND SOUNDFILE(S)" "set pr_tfm 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0] 
		set f1 [frame $f.1] 
		button $f0.ok -text "Run" -command "set pr_tfm 1" -width 8 -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $f0.qq -text "Quit" -command "set pr_tfm 0"  -width 8 -highlightbackground [option get . background {}]
		pack $f0.ok -side left
		pack $f0.qq -side right
		pack $f0 -side top -fill x -expand true
		entry $f1.e -textvariable tfmfnam -width 24
		label $f1.ll -text "Output Filename"
		pack $f1.e $f1.ll -side left
		pack $f1 -side top -pady 2
		wm resizable $f 0 0
		bind $f <Return> {set pr_tfm 1}
		bind $f <Escape> {set pr_tfm 0}
	}
	set pr_tfm 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_tfm $f.1.e
	while {!$finished} {
		tkwait variable pr_tfm
		switch -- $pr_tfm {
			1 {
				DeleteAllTemporaryFiles
				if {[string length $tfmfnam] <= 0} {
					Inf "No output filename entered"
					continue
				}
				if {![ValidCDPRootname $tfmfnam]} {
					continue
				}
				set ofnam [string tolower $tfmfnam]
				set mofnam $ofnam
				append ofnam $evv(SNDFILE_EXT)
				if {$chans > 2} {
					append mofnam [GetTextfileExtension mmx]
				} else {
					append mofnam [GetTextfileExtension mix]
				}
				if {[file exists $mofnam]} {
					Inf "A file with the name '$mofnam' already exists: please choose a different name"
					continue
				}
				if {[file exists $ofnam]} {
					Inf "A file with the name '$ofnam' already exists: please choose a different name"
					continue
				}
				catch {unset lines}
				if {$chans > 2} {
					set line $chans
					lappend lines $line
					foreach fnam $fnams time $times {
						set line [list $fnam $time $chans] 
						set n 1
						while {$n <= $chans} {
							set rout $n
							append rout ":" $n
							lappend line $rout 1.0
							incr n
						}
					}
				} else {
					foreach fnam $fnams time $times {
						set line [list $fnam $time $chans 1.0] 
						lappend lines $line
					}
				}
				set OK 1
				Block "Mixing Output File"
				while {$OK} {
					if [catch {open $mfnam "w"} zit] {
						Inf "Cannot open temporary mixfile $mfnam to write mix data"
						set OK 0
						break
					}
					foreach line $lines {
						puts $zit $line
					}
					close $zit
					wm title .blocker "PLEASE WAIT:        MIXING THE OUTPUT SOUND"
					if {$chans > 2} {
						set cmd [file join $evv(CDPROGRAM_DIR) newmix]
						lappend cmd multichan
					} else {
						set cmd [file join $evv(CDPROGRAM_DIR) submix]
						lappend cmd mix
					}
					lappend cmd $mfnam $ofnam
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					if [catch {open "|$cmd"} CDPidrun] {
						ErrShow "CANNOT RUN THE MIXING PROCESS : $CDPidrun"
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
						set msg "Cannot create mixed sound"
						set msg [AddSimpleMessages $msg]
						ErrShow $msg
						set OK 0
						break
					}
					if {![file exists $ofnam]} {
						set msg "No mixed sound created"
						set msg [AddSimpleMessages $msg]
						ErrShow $msg
						set OK 0
						break
					}
					break
				}
				if {!$OK} {
					UnBlock
					continue
				}
				set is_mo 0
				set sw 0
				set mw 0
				if [catch {file rename -force $mfnam $mofnam} zit] {
					Inf "Cannot rename temporary mixfile to $mofnam : $zit"
				} else {
					set is_mo 1
				}
				if {[FileToWkspace $ofnam 0 0 0 0 1] > 0}  {
					set sw 1
				}
				if {$is_mo} {
					if {[FileToWkspace $mofnam 0 0 0 0 1] > 0} {
						set mw 1
					}
				}
				set msg ""
				if {$sw && $mw} {
					append msg "Files [file rootname $ofnam] are on the workspace"
				} else {
					if {$sw} {
						append msg "File $ofnam is on the workspace\n"
					}
					if {$is_mo} {
						if {$mw} {
							append msg "File $mofnam is on the workspace"
						} else {
							append msg "File $mofnam is saved"
						}
					}
				}
				Inf $msg
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

proc ExtendFileWithOnsets {} {
	global chlist wl evv pa pr_xfwo xfwofnam xfwodur hopperm prg_dun prg_abortd simple_program_messages CDPidrun

	if {[info exists chlist] && ([llength $chlist] >= 2)} {
		set fnams $chlist
	} else {
		set ilist [$wl curselection]
		if {[llength $ilist] >= 2} {
			foreach i $ilist {
				lappend fnams [$wl get $i]
			}
		}
	}
	set msg "Select one splice-times textfile and the soundfiles resulting from the slice (at least 4)"
	if {![info exists fnams]}  {
		Inf $msg
		return
	}
	set totaldur 0.0
	foreach fnam $fnams {
		if {$pa($fnam,$evv(TYP)) == $evv(SNDFILE)} {
			if {![info exists sfnams]} {
				set chans $pa($fnam,$evv(CHANS))
			} elseif {$chans != $pa($fnam,$evv(CHANS))} {
				Inf "Sndfiles selected do not all have the same number of channels"
				return
			}
			set totaldur [expr $totaldur + $pa($fnam,$evv(DUR))]
			lappend sfnams $fnam
		} else {
			if {[info exists tfnam]} {
				Inf $msg
				return
			} else {
				set tfnam $fnam
			}
		}
	}
	set fnams $sfnams
	set flen [llength $fnams]
	set penult [expr $flen - 2]
	if {$penult < 0} {
		Inf "Cannot proceed with less than 4 input sounds"
		return
	}
	if [catch {open $tfnam "r"} zit] {
		Inf "Cannot open file $tfnam"
		return
	}
	set OK 1
	set lasttime -1
	catch {unset durs}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		set line [split $line]
		catch {unset vals}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			if {![IsNumeric $item] || ($item < 0.0)} {
				Inf "Invalid value ($item) in edit slice data"
				set OK 0
				break
			}
			lappend vals $item
		}
		if {![info exists vals] || ([llength $vals] != 2)}  {
			Inf "Invalid line ($line) in edit slice data"
			set OK 0
			break
		}
		set dur [expr [lindex $vals 1] - [lindex $vals 0]]
		if {$dur <= 0}  {
			Inf "Invalid line ($line) in edit slice data"
			set OK 0
			break
		}
		lappend durs $dur
	}
	close $zit
	if {!$OK} {
		return
	}
	if {![info exists durs]} {
		Inf "No data in edit slice file"
		return
	}
	if {[llength $durs] != $flen} {
		Inf "Number of sliced files does not tally with slice-data"
		return
	}
	set f .xfwo
	if [Dlg_Create $f "EXTEND A SOUND FROM SEGMENTS SLICED FROM ORIGINAL" "set pr_xfwo 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0] 
		set f1 [frame $f.1] 
		set f2 [frame $f.2] 
		button $f0.ok -text "Run" -command "set pr_xfwo 1" -width 8 -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $f0.qq -text "Quit" -command "set pr_xfwo 0"  -width 8 -highlightbackground [option get . background {}]
		pack $f0.ok -side left
		pack $f0.qq -side right
		pack $f0 -side top -fill x -expand true
		entry $f1.e -textvariable xfwodur -width 24
		label $f1.ll -text "Output Duration"
		pack $f1.e $f1.ll -side left
		pack $f1 -side top -pady 2
		entry $f2.e -textvariable xfwofnam -width 24
		label $f2.ll -text "Output Filename"
		pack $f2.e $f1.ll -side left
		pack $f2 -side top -pady 2
		wm resizable $f 0 0
		bind $f.1.e <Down> {focus .xfwo.2.e}
		bind $f.2.e <Down> {focus .xfwo.1.e}
		bind $f.1.e <Up> {focus .xfwo.2.e}
		bind $f.2.e <Up> {focus .xfwo.1.e}
		bind $f <Return> {set pr_xfwo 1}
		bind $f <Escape> {set pr_xfwo 0}
	}
	set pr_xfwo 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_xfwo $f.1.e
	while {!$finished} {
		tkwait variable pr_xfwo
		switch -- $pr_xfwo {
			1 {
				if {([string length $xfwodur] <= 0) || ![IsNumeric $xfwodur] || ($xfwodur < 0.01) || ($xfwodur > 10000)} {
					Inf "Invalid output duration ($xfwodur) (range >$totaldur to 10000)"
					continue
				}
				if {[string length $xfwofnam] <= 0} {
					Inf "No output filename entered"
					continue
				}
				if {![ValidCDPRootname $xfwofnam]} {
					continue
				}
				set ofnam [string tolower $xfwofnam]
				set mofnam $ofnam
				if {$chans > 2} {
					append mofnam [GetTextfileExtension mmx]
				} else {
					append mofnam [GetTextfileExtension mix]
				}
				append ofnam $evv(SNDFILE_EXT)
				if {[file exists $ofnam]} {
					Inf "A file with the name '$ofnam' already exists: please choose a different name"
					continue
				}
				if {[file exists $mofnam]} {
					Inf "A file with the name '$mofnam' already exists: please choose a different name"
					continue
				}
				Block "assembling mixfile for output"
				set lastfnam [lindex $fnams end]
				set lastdur  [lindex $durs 0]
				set time 0
				set n 0
				set outdat [list [lindex $fnams 0] $time]
				lappend outdats $outdat
				set dur [lindex $durs 0]
				set time [expr $time + $dur]

				set fnams [lrange $fnams 1 $penult]
				set durs  [lrange $durs  1 $penult]

				foreach fnam $fnams dur $durs {
					set item [list $fnam $dur]
					lappend qwags $item
				}
				set qwaglen [llength $qwags]
				while {$time < $xfwodur} {
					randperm $qwaglen
					foreach val $hopperm {
						set qwag [lindex $qwags $val]
						set fnam [lindex $qwag 0]			;#	fnam
						set outdat [list $fnam $time]
						lappend outdats $outdat
						set dur [lindex $qwag 1]		
						set time [expr $time + $dur]
						if {$time >= $xfwodur} {
							break
						}
					}
				}
				set outdat [list $lastfnam $time]
				lappend outdats $outdat

				if {$chans > 2} {
					set nuoutdats $chans
					foreach outdat $outdats {
						set n 1
						while {$n <= $chans} {
							set rout $n
							append rout ":" $n
							lappend outdat $rout 1.0
							incr n
						}
						lappend nuoutdats 
					}
					set outdats $nuoutdats
				} else {
					set n 0
					foreach outdat $outdats {
						lappend outdat $chans 1.0
						set outdats [lreplace $outdats $n $n $outdat]
						incr n
					}
				}
				if [catch {open $mofnam "w"} zit] {
					Inf "Cannot open the output mixfile $mofnam"
					UnBlock
					continue
				}
				foreach outdat $outdats {
					puts $zit $outdat
				}
				close $zit
				set OK 1 
				while {$OK} {
					wm title .blocker "PLEASE WAIT:        MIXING THE OUTPUT SOUND"
					if {$chans > 2} {
						set cmd [file join $evv(CDPROGRAM_DIR) newmix]
						lappend cmd multichan
					} else {
						set cmd [file join $evv(CDPROGRAM_DIR) submix]
						lappend cmd mix
					}
					lappend cmd $mofnam $ofnam
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					if [catch {open "|$cmd"} CDPidrun] {
						ErrShow "CANNOT RUN ENVELOPE MIXING PROCESS: $CDPidrun"
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
						set msg "Cannot create mixed sound"
						set msg [AddSimpleMessages $msg]
						ErrShow $msg
						set OK 0
						break
					}
					if {![file exists $ofnam]} {
						set msg "No mixed sound created"
						set msg [AddSimpleMessages $msg]
						ErrShow $msg
						set OK 0
						break
					}
					break
				}
				UnBlock
				if {!$OK} {
					continue
				}
				set sw 0
				set mw 0
				if {[FileToWkspace $ofnam 0 0 0 0 1] > 0}  {
					set sw 1
				}
				if {[FileToWkspace $mofnam 0 0 0 0 1] > 0}  {
					set mw 1
				}
				if {$sw && $mw} {
					set msg "Files [file rootname $ofnam] are on the workspace"
				} else {
					set msg "Files are saved\n"
					if {$sw} {
						append msg "File $ofnam is on the workspace"
					}
					if {$mw} {
						append msg "File $mofnam is on the workspace"
					}
				}
				Inf $msg
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

proc OnsetsToSlice {} {
	global chlist wl evv pa pr_onstosl onstoslfnam onstosldur

	if {[info exists chlist] && ([llength $chlist] == 1)} {
		set fnam [lindex $chlist 0]
	} else {
		set i [$wl curselection]
		if {([llength $i] == 1) && ($i != -1)} {
				set fnam [$wl get $i]
		}
	}
	set msg "Select a textfile listing of onset-times (within a sound)"
	if {![info exists fnam]}  {
		Inf $msg
		return
	}
	if {!($pa($fnam,$evv(TYP)) & $evv(IS_A_TEXTFILE))} {
		Inf $msg
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot open file $fnam to read data"
		return
	}
	set lasttime -1
	set cnt 0
	set OK 1
	catch {unset vals}
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
			if {![IsNumeric $item] || ($item < 0.0)} {
				Inf "Invalid value ($item) in onset times data"
				set OK 0
				break
			}
			if {$item <= $lasttime} {
				Inf "Times do not increase in file $fnam"
				set OK 0
				break
			}
			lappend vals $item
		}
	}
	set endtime [lindex $vals end]
	close $zit
	if {!$OK} {
		return
	}
	if {[Flteq [lindex $vals 0] 0.0]} {
		set vals [lrange $vals 1 end]
	}
	catch {unset lines}
	set lastval 0.0
	foreach val $vals {
		set line [list $lastval $val]
		lappend lines $line
		set lastval $val
	}
	set f .onstosl
	if [Dlg_Create $f "CONVERT ONSET TIMES TO EDIT-SLICE TIMES" "set pr_onstosl 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0] 
		set f1 [frame $f.1] 
		set f2 [frame $f.2] 
		button $f0.ok -text "Run" -command "set pr_onstosl 1" -width 8 -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $f0.qq -text "Quit" -command "set pr_onstosl 0"  -width 8 -highlightbackground [option get . background {}]
		pack $f0.ok -side left
		pack $f0.qq -side right
		pack $f0 -side top -fill x -expand true
		entry $f1.e -textvariable onstosldur -width 24
		label $f1.ll -text "(beyond) Time of Source Sound End (used in cutting last segment in file)"
		pack $f1.e $f1.ll -side left
		pack $f1 -side top -pady 2
		entry $f2.e -textvariable onstoslfnam -width 24
		label $f2.ll -text "Output Filename"
		pack $f2.e $f1.ll -side left
		pack $f2 -side top -pady 2
		wm resizable $f 0 0
		bind $f.1.e <Down> {focus .onstosl.2.e}
		bind $f.2.e <Down> {focus .onstosl.1.e}
		bind $f.1.e <Up> {focus .onstosl.2.e}
		bind $f.2.e <Up> {focus .onstosl.1.e}
		bind $f <Return> {set pr_onstosl 1}
		bind $f <Escape> {set pr_onstosl 0}
	}
	set pr_onstosl 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_onstosl $f.1.e
	while {!$finished} {
		tkwait variable pr_onstosl
		switch -- $pr_onstosl {
			1 {
				if {([string length $onstosldur] <= 0) || ![IsNumeric $onstosldur] || ($onstosldur <= $endtime)} {
					Inf "Invalid end cut time ($onstosldur) : must be beyond last onset time ($endtime)"
					continue
				}
				if {[string length $onstoslfnam] <= 0} {
					Inf "No output filename entered"
					continue
				}
				if {![ValidCDPRootname $onstoslfnam]} {
					continue
				}
				set ofnam [string tolower $onstoslfnam]
				append ofnam $evv(TEXT_EXT)
				if [catch {open $ofnam "w"} zit] {
					Inf "Cannot open file $ofnam to write edit splice data"
					set OK 0
					break
				}
				set line [list $endtime $onstosldur]
				lappend lines $line
				foreach line $lines {
					puts $zit $line
				}
				close $zit
				if {[FileToWkspace $ofnam 0 0 0 0 1] > 0}  {
					Inf "File $ofnam is on the workspace"
				} else {
					Inf "File $ofnam saved"
				}
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

###############

proc ReplaceSndsInMixfile {} {
	global chlist pa evv pr_xro xro prg_dun prg_abortd simple_program_messages CDPidrun

	set outmsg "SELECT ONE MIXFILE AND THE SAME NUMBER OF SOUNDFILES AS OCCUR IN THE MIXFILE"
	append outmsg "\n\nCHANNEL COUNT OF EACH INPUT SOUND MUST CORRESPOND WITH CORRESPONDING FILE IN MIXFILE"

	set envfnam $evv(DFLT_OUTNAME)
	append envfnam 0 $evv(TEXT_EXT)

	set multichan 0
	if {![info exists chlist] || [llength $chlist] < 2} {
		Inf $outmsg
		return
	}
	foreach fnam $chlist {
		set ftyp $pa($fnam,$evv(FTYP))
		if {$ftyp == $evv(SNDFILE)} {
			if {![info exists insnds]} {
				set srate $pa($fnam,$evv(SRATE))
			} elseif {$srate != $pa($fnam,$evv(SRATE))} {
				Inf "Not all the input soundfiles have the same sample rate"
				return
			}
			lappend inchans $pa($fnam,$evv(CHANS))
			lappend insnds $fnam
		} elseif {[IsAMixfileIncludingMultichan $ftyp]} {
			if {[info exists mfile]} {
				Inf "Too many mixfiles in the chosen files list"
				return
			}
			set mfile $fnam
			if {$ftyp == $evv(MIX_MULTI)} {
				set multichan 1
			}
		} else {
			Inf $outmsg
			return
		}
	}
	if {![info exists insnds] || ![info exists mfile]} {
		Inf $outmsg
		return
	}
	set f .xro
	if [Dlg_Create $f "REPLACE ALL SOUNDS IN MIX" "set pr_xro 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0] 
		set f1 [frame $f.1] 
		set f2 [frame $f.2] 
		set f3 [frame $f.3] 
		button $f0.ok -text "Replace" -command "set pr_xro 1" -width 8 -bg $evv(EMPH) -highlightbackground [option get . background {}]
		button $f0.qq -text "Quit" -command "set pr_xro 0"  -width 8 -highlightbackground [option get . background {}]
		pack $f0.ok -side left
		pack $f0.qq -side right
		pack $f0 -side top -fill x -expand true
		set xro(sync) 0
		checkbutton $f1.ch -text "Sync with attacks" -variable xro(sync) -command "SetJump"
		pack $f1.ch -side left
		pack $f1 -side top -pady 2
		pack $f1 -side top -fill x -expand true
		entry $f2.e -textvariable xro(jump) -width 24 -bd 0 -state disabled -disabledbackground [option get . background {}]
		label $f2.ll -text "" -width 44
		pack $f2.e $f2.ll -side left -expand true
		pack $f2 -side top -pady 2
		entry $f3.e -textvariable xro(fnam) -width 24
		label $f3.ll -text "Output Filename"
		pack $f3.e $f3.ll -side left -expand true
		pack $f3 -side top -pady 2
		wm resizable $f 0 0
		bind $f <Return> {set pr_xro 1}
		bind $f <Escape> {set pr_xro 0}
	}
	set pr_xro 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_xro $f.3.e
	while {!$finished} {
		tkwait variable pr_xro
		switch -- $pr_xro {
			1 {
				set OK 1
				if {$xro(sync)} {
					if {([string length $xro(jump)] <= 0) || ![IsNumeric $xro(jump)] || ($xro(jump) < 0.01) || ($xro(jump) > 1.0)} {
						Inf "Invalid onset step (range 0.01 to 1)"
						continue
					}
				}
				if {[string length $xro(fnam)] <= 0} {
					Inf "No output filename entered"
					continue
				}
				if {![ValidCDPRootname $xro(fnam)]} {
					continue
				}
				set ofnam [string tolower $xro(fnam)]
				if {$multichan} {
					append ofnam [GetTextfileExtension mmx]
				} else {
					append ofnam [GetTextfileExtension mix]
				}
				if {[file exists $ofnam]} {
					Inf "A file with the name '$ofnam' already exists: please choose a different name"
					continue
				}
				Block "PROCESSING"
				if {$xro(sync)} {
					catch {unset inonsets}
					catch {unset onsets}
					foreach fnam $insnds {
						wm title .blocker "PLEASE WAIT:        EXTRACTING ENVELOPE FROM FILE [file rootname [file tail $fnam]]"
						catch {file delete $envfnam}
						set cmd [file join $evv(CDPROGRAM_DIR) envel]
						lappend cmd extract 2 $fnam $envfnam 5 -d0
						set prg_dun 0
						set prg_abortd 0
						catch {unset simple_program_messages}
						if [catch {open "|$cmd"} CDPidrun] {
							ErrShow "CANNOT RUN ENVELOPE EXTRACTION PROCESS ON FILE [file rootname [file tail $fnam]]: $CDPidrun"
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
							set msg "Cannot extract sound envelope from file [file rootname [file tail $fnam]]"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							set OK 0
							break
						}
						if {![file exists $envfnam]} {
							set msg "No envelope extracted from file [file rootname [file tail $fnam]]"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							set OK 0
							break
						}
						wm title .blocker "PLEASE WAIT:        SEARCHING FOR ONSET IN FILE [file rootname [file tail $fnam]]"
						if [catch {open $envfnam "r"} zit] {
							Inf "Cannot open intermediate envelope file to read data for file [file rootname [file tail $fnam]]"
							set OK 0
							break
						}
						catch {unset edata}
						while {[gets $zit line] >= 0} {
							set line [string trim $line]
							if {[string length $line] <= 0} {
								continue
							}
							set line [split $line]
							set cnt 0
							catch {unset vals}
							foreach item $line {
								set item [string trim $item]
								if {[string length $item] <= 0} {
									continue
								}
								lappend vals $item
							}
							if {![info exists vals] || ([llength $vals] != 2)}  {
								Inf "Invalid line ($line) in intermediate envelope data for file [file rootname [file tail $fnam]]"
								set OK 0
								break
							}
							lappend edata $vals
						}
						close $zit
						if {![info exists edata]} {
							Inf "No data found in intermediate envelope file for file [file rootname [file tail $fnam]]"
							set OK 0
							break
						}
						set len [llength $edata]
						if {[llength $edata] <= 1} {
							Inf "Insufficient data found in intermediate envelope file for file [file rootname [file tail $fnam]]"
							set OK 0
							break
						}
						set lastval [lindex [lindex $edata 0] 1]
						set n 1
						catch {unset onset}
						while {$n < $len} {
							set vals [lindex $edata $n]
							set val [lindex $vals 1]
							if {[expr $val - $lastval] >= $xro(jump)} {
								set onset [lindex $vals 0]			
								break
							}
							set lastval $val
							incr n
						}
						if {![info exists onset]} {
							Inf "No sudden onsets found for file [file rootname [file tail $fnam]] with jump set to $xro(jump)"
							set OK 0
							break
						}
						lappend inonsets $onset
					}
					if {!$OK} {
						UnBlock
						continue
					}
				}
				wm title .blocker "PLEASE WAIT:        READING MIXFILE DATA"
				catch {unset mixdata}
				if [catch {open $mfile "r"} zit] {
					Inf "Cannot open file [file rootname [file tail $mfile]] to read mix data"
					UnBlock
					continue
				}
				while {[gets $zit line] >= 0} {
					set line [string trim $line]
					if {[string length $line] <= 0} {
						continue
					}
					if {[string match [string index $line 0] ";"]} {
						continue
					}
					set line [split $line]
					catch {unset vals}
					foreach item $line {
						set item [string trim $item]
						if {[string length $item] <= 0} {
							continue
						}
						lappend vals $item
					}
					lappend mixdata $vals
				}
				if {![info exists mixdata]} {
					Inf "No valid data found in mixfile [file rootname [file tail $mfile]]"
					UnBlock
					continue
				}
				if {[expr [llength $mixdata] - $multichan] != [llength $insnds]} {
					Inf "Number of active lines in mixfile does not tally with no of input sounds"
					UnBlock
					continue
				}
				if {$multichan} {
					set multichan [lindex [lindex $mixdata 0] 0]
					set mixdata [lrange mixdata 1 end]
				}
				set k 0
				set m 1
				wm title .blocker "PLEASE WAIT:        CHECKING INPUT SOUNDFILES AGAINST MIXFILE DATA"
				catch {unset sttimes}
				foreach line $mixdata {
					set chans [lindex $line 2]
					if {$chans != [lindex $inchans $k]} {
						Inf "Input sound $m has different channel count ([lindex $inchans $k]) to mixfile sound	$m ($chans)"
						set OK 0
						break
					}
					incr k
					incr m
					if {$xro(sync)} {
						wm title .blocker "PLEASE WAIT:        FINDING ATTACK TIME IN FILE [file rootname [file tail $fnam]] IN MIXFILE"
						catch {file delete $envfnam}
						set fnam [lindex $line 0]
						set sttime [lindex $line 1]
						lappend sttimes $sttime
						set cmd [file join $evv(CDPROGRAM_DIR) envel]
						lappend cmd extract 2 $fnam $envfnam 5 -d0
						set prg_dun 0
						set prg_abortd 0
						catch {unset simple_program_messages}
						if [catch {open "|$cmd"} CDPidrun] {
							ErrShow "CANNOT RUN ENVELOPE EXTRACTION PROCESS ON FILE [file rootname [file tail $fnam]] IN MIXFILE: $CDPidrun"
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
							set msg "Cannot extract sound envelope from file [file rootname [file tail $fnam]] in  mixfile"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							set OK 0
							break
						}
						if {![file exists $envfnam]} {
							set msg "No envelope extracted from file [file rootname [file tail $fnam]] in mixfile"
							set msg [AddSimpleMessages $msg]
							ErrShow $msg
							set OK 0
							break
						}
						wm title .blocker "PLEASE WAIT:        SEARCHING FOR ONSET IN FILE [file rootname [file tail $fnam]] IN MIXFILE"
						if [catch {open $envfnam "r"} zit] {
							Inf "Cannot open intermediate envelope file to read data for file [file rootname [file tail $fnam]] in mixfile"
							set OK 0
							break
						}
						catch {unset edata}
						while {[gets $zit line] >= 0} {
							set line [string trim $line]
							if {[string length $line] <= 0} {
								continue
							}
							set line [split $line]
							set cnt 0
							catch {unset vals}
							foreach item $line {
								set item [string trim $item]
								if {[string length $item] <= 0} {
									continue
								}
								lappend vals $item
							}
							if {![info exists vals] || ([llength $vals] != 2)}  {
								Inf "Invalid line ($line) in intermediate envelope data for file [file rootname [file tail $fnam]] in mixfile"
								set OK 0
								break
							}
							lappend edata $vals
						}
						close $zit
						if {![info exists edata]} {
							Inf "No data found in intermediate envelope file for file [file rootname [file tail $fnam]] in mixfile"
							set OK 0
							break
						}
						set len [llength $edata]
						if {[llength $edata] <= 1} {
							Inf "Insufficient data found in intermediate envelope file for file [file rootname [file tail $fnam]] in mixfile"
							set OK 0
							break
						}
						set lastval [lindex [lindex $edata 0] 1]
						set n 1
						catch {unset onset}
						while {$n < $len} {
							set vals [lindex $edata $n]
							set val [lindex $vals 1]
							if {[expr $val - $lastval] >= $xro(jump)} {
								set onset [lindex $vals 0]			
								break
							}
							set lastval $val
							incr n
						}
						if {![info exists onset]} {
							Inf "No sudden onsets found for file [file rootname [file tail $fnam]] in mixfile, with jump set to $xro(jump)"
							set OK 0
							break
						}
						lappend onsets $onset
					}
				}
				if {!$OK} {
					UnBlock
					continue
				}
				catch {unset numixlines}
				if {$multichan} {
					lappend numixlines $multichan
				}
				wm title .blocker "PLEASE WAIT:        WRITING OUTPUT MIXFILE"
				if {$xro(sync)} {
					set n 1
					foreach mixline $mixdata sttime $sttimes inonset $inonsets onset $onsets fnam $insnds {
						set nustt [expr $sttime - ($inonset - $onset)]
						if {$nustt < 0.0} {
							Inf "New sound $n would start before time zero in the mixfile"
							set OK 0
							break
						}
						set mixline [lreplace $mixline 0 0 $fnam]
						set mixline [lreplace $mixline 1 1 $nustt]
						lappend numixlines $mixline
						incr n
					}
					if {!$OK} {
						 UnBlock
						continue
					}
				} else {
					foreach mixline $mixdata fnam $insnds {
						set mixline [lreplace $mixline 0 0 $fnam]
						lappend numixlines $mixline
					}
				}
				if [catch {open $ofnam "w"} zit] {
					Inf"Cannot open file $outmix to write new mix data"
					UnBlock
					continue
				}
				foreach mixline $numixlines {
					puts $zit $mixline
				}
				close $zit
				if {[FileToWkspace $ofnam 0 0 0 0 1] > 0}  {
					Inf "File $ofnam is on the workspace"
				} else {
					Inf "File $ofnam saved"
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

proc SetJump {} {
	global xro
	if {$xro(sync)} {
		.xro.2.e  config -bd 2 -state normal
		.xro.2.ll config -text "Onset Jump (Range : level upstep 0.01 to 1)"
		if {[info exists xro(jumpbak)]} {
			set xro(jump) $xro(jumpbak)
		}
	} else {
		set xro(jumpbak) $xro(jump)
		set xro(jump) ""
		.xro.2.e  config -bd 0 -state disabled -disabledbackground [option get . background {}]
		.xro.2.ll config -text ""
	}
}
