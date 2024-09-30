#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD 28 June 2013
# ... handles System Settings 1->get prog versions panel
# ... fixup button rectangles
#------ Set variables which depend on system on which interface is run

proc SetSystemDependentVariables {} {
	global killcmd playcmd automatic_logname_generation new_cdp_extensions evv

	set gotprog 0
	set evv(WHICHPROG) ""
	foreach progname [glob -nocomplain [file join $evv(CDPROGRAM_DIR) synth*]] {
		if {$gotprog} {
			Inf "You seem to have two different versions of the CDP software in your directory\n\nas you have both '[file tail $evv(WHICHPROG)]' and '[file tail $progname]'\n\nPLEASE INSTALL ONLY ONE VERSION"
			return 0
		}
		set evv(WHICHPROG) $progname
		set gotprog 1
	}
	if {!$gotprog} {
		Inf "Cannot set up the SoundLoom, even for Demonstration. Vital programs missing."
		return 0
	}
	switch -- $evv(SYSTEM) {
		PC {
			set killcmd kill
			set evv(WTITLE_HITE) 19
			set evv(W_BORDER) 4
			set evv(SHORTSIZE) 2
			set evv(INTSIZE) 4
			set evv(FLTSIZE) 4
			set evv(DBLSIZE) 8
			set automatic_logname_generation 1
			set evv(EXEC) ".exe"
			set evv(PRINT_CMD) print
			set evv(HANG1) "   Type Control Alt Del, and on the menu which appears,"
			set evv(HANG2) "   select the CDP process which is running (usually at foot of list)"
			set evv(HANG3) "   or select the Sound Loom window which is running (usually at top of list),"
			set evv(HANG4) "   and then press the 'End Task' button, and WAIT for several seconds."
			set evv(HANG5) "   If the Sound Loom stops running, restart it. No sound, data or configuration information will be lost."
		}
		SGI {
			set killcmd kill
#			set evv(WTITLE_HITE) 19
#			set evv(W_BORDER) 4
#			set evv(SHORTSIZE) 2
#			set evv(INTSIZE) 4
#			set evv(FLTSIZE) 4
#			set evv(DBLSIZE) 8
			set automatic_logname_generation 0
#??			set evv(EXEC) ".exe"
#??			set evv(PRINT_CMD) print
#??			set evv(HANG1) "   ????????"
#			set evv(HANG2) "   Then restart the Sound Loom, no sound, data or configuration information will be lost."
			set evv(HANG3) ""
			set evv(HANG4) ""
			set evv(HANG5) ""
		}
		MAC {
#RWD Feb 04 Provisional config; not sure about kill yet, how do we get prog ID?
			set killcmd kill
			set evv(WTITLE_HITE) 19
			set evv(W_BORDER) 4
			set evv(SHORTSIZE) 2
			set evv(INTSIZE) 4
			set evv(FLTSIZE) 4
			set evv(DBLSIZE) 8
			set automatic_logname_generation 1
			set evv(EXEC) ""
			set evv(PRINT_CMD) print
			set evv(HANG1) "   from terminal, type ps to get prog ID, then type kill -9 ID"
			set evv(HANG2) "   Then from the Apple menu, select 'Force Quit, and from the dialog select 'Wish' and 'Force Quit'."
			set evv(HANG3) "   Then restart the Sound Loom."
#TW COMMENT: DO NOT DELETE THE FOLLOWING TWO LINES
			set evv(HANG4) ""
			set evv(HANG5) ""
		}
		LINUX {
			Inf "System dependent commands for LINUX not yet known: MAY 1999"
#			set killcmd ?????
#			set evv(WTITLE_HITE) 19
#			set evv(W_BORDER) 4
#			set evv(SHORTSIZE) 2
#			set evv(INTSIZE) 4
#			set evv(FLTSIZE) 4
#			set evv(DBLSIZE) 8
			set automatic_logname_generation 1
#??			set evv(EXEC) ".exe"
#??			set evv(PRINT_CMD) print
#??			set evv(HANG1) "   ????????"
#			set evv(HANG2) "   Then restart the Sound Loom, no sound, data or configuration information will be lost."
			set evv(HANG3) ""
			set evv(HANG4) ""
			set evv(HANG5) ""
		}
	}
	set xx	[expr ($evv(INTSIZE) * 8) - 1]
	set xx	[expr (pow(2.0,$xx) - 1)]
	set evv(MAXINT) [expr round($xx)]
	set fnam [file join $evv(CDPRESOURCE_DIR) $evv(NEWSYS)$evv(CDP_EXT)]
	if {![file exists $fnam]} {
		set new_cdp_extensions 1
		DisplayFloatSysMessage
		if [catch {open $fnam "w"} zit] {
			Inf "Cannot Open File '$fnam' To Remember That This Message About The New System Has Been Displayed."
			return 1
		}
		puts $zit $new_cdp_extensions
		close $zit
	} else {
		set new_cdp_extensions 1
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot Open File '$fnam' To Read File Extension Choice: Reverting To Multiple Extensions."
			return 1
		}
		set OK 0
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[llength $line] > 0} {
				if {[string match $line "0"] || [string match $line "1"]} {
					set new_cdp_extensions $line
					set OK 1
					break
				}
			}
		}
		close $zit
		if {!$OK} {
			if [catch {open $fnam "w"} zit] {
				Inf "Cannot Open File '$fnam' To Write File Extension Choice For Next Session."
				return 1
			}
			puts $zit $new_cdp_extensions
			close $zit
		}
	}
	return 1
}

proc DisplayFloatSysMessage {} {
	set msg "NEW RELEASE CDP and the SOUND LOOM\n\n"
	append msg "You are now using the new CDP release which\n"
	append msg "accepts many different formats of soundfiles\n"
	append msg "(16-bit, 24-bit,32-bit, floating point etc.)\n\n"
	append msg "Creating this new version has involved\n"
	append msg "modifications to almost all the CDP software.\n"
	append msg "Please let us know if you encounter any problems,\n"
	append msg "especially if you used the previous system,\n"
	append msg "and the problem did NOT arise there.\n\n"
	append msg "COMPATIBILITY\n\n"
	append msg "Files generated with older versions of the CDP\n"
	append msg "can still be read and used in the new version.\n"
	append msg "However, files generated in this new version\n"
	append msg "CANNOT ALWAYS be read by the Old Version of CDP,\n"
	append msg "as that version only handles 16-bit soundfiles.\n\n"
	Inf $msg
	set msg "ABOUT OUTPUT FILENAMES\n\n"
	append msg "The SOUND LOOM, used with the New CDP Release,\n"
	append msg "assumes you wish to use\n"
	append msg "the special CDP soundfile extensions.\n"
	append msg "i.e. output files which are SOUNDFILES\n"
	append msg "have the standard filename extension,\n"
	append msg "but output files which are NOT soundfiles\n"
	append msg "(and not text files) have the following\n"
	append msg "filename extensions..\n\n"
	append msg ".ana     Analysis Files\n"
	append msg ".frq       Pitch Files\n"
	append msg ".trn       Transposition Files\n"
	append msg ".for       Formant Files\n"
	append msg ".evl      Envelope Files\n\n"
	append msg "If you wish to use a standard file extension\n"
	append msg "for all these files, on the Workspace\n"
	append msg "go to the 'System' menu -> 'System Settings'\n"
	append msg "and select 'Sndsys Extensions: One Or Many'\n"
	append msg "resetting to 'Standard File Extension'.\n"
	Inf $msg
}

proc GetVersions {} {
	global pr_version evv
	set f .version
	if [Dlg_Create $f "FIND VERSION NUMBER OF CDP PROGRAM" "set pr_version 0"	-borderwidth $evv(SBDR)] {
		frame $f.1 -bd $evv(SBDR)
		frame $f.2 -bd $evv(SBDR)
		frame $f.3 -bd $evv(SBDR)
		button $f.1.q -text "Close" -command "set pr_version 0" -highlightbackground [option get . background {}]
		pack $f.1.q -side top
		frame $f.2.a -bd $evv(SBDR)
		frame $f.2.b -bd $evv(SBDR)
		frame $f.2.c -bd $evv(SBDR)
		frame $f.2.d -bd $evv(SBDR)
		button $f.2.a.1  -text "BLUR" -command {ShowVersion "BLUR"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.a.2  -text "BRASSAGE" -command {ShowVersion "BRASSAGE"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.a.3  -text "CHANNELS" -command {ShowVersion "CHANNELS"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.a.4  -text "COMBINE" -command {ShowVersion "COMBINE"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.a.5  -text "DATA CREATE (FILTER FILES)" -command {ShowVersion "DATA CREATE FILTER FILES"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.a.6  -text "DATA CREATE (BATCH FILES)" -command {ShowVersion "DATA CREATE BATCH FILES"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.a.7  -text "DISTORT" -command {ShowVersion "DISTORT"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.a.8  -text "EDIT" -command {ShowVersion "EDIT"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.a.9  -text "ENVELOPE" -command {ShowVersion "ENVELOPE"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.a.10 -text "ENVELOPE (IMPOSE CONTOUR)" -command {ShowVersion "ENVELOPE IMPOSE CONTOUR"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.a.11 -text "EXTEND" -command {ShowVersion "EXTEND"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.a.12 -text "FILTER" -command {ShowVersion "FILTER"} -width 26 -highlightbackground [option get . background {}]
		pack $f.2.a.1 $f.2.a.2 $f.2.a.3 $f.2.a.4 $f.2.a.5 $f.2.a.6 $f.2.a.7 $f.2.a.8 $f.2.a.9 $f.2.a.10 \
		$f.2.a.11 $f.2.a.12 -side top -pady 1 
		button $f.2.b.1  -text "FOCUS" -command {ShowVersion "FOCUS"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.b.2  -text "FORMANTS" -command {ShowVersion "FORMANTS"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.b.3  -text "GRAIN" -command {ShowVersion "GRAIN"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.b.4  -text "HARMONIC FIELD" -command {ShowVersion "HARMONIC FIELD"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.b.5  -text "HILIGHT" -command {ShowVersion "HILIGHT"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.b.6  -text "HOUSEKEEP" -command {ShowVersion "HOUSEKEEP"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.b.7  -text "LOUDNESS" -command {ShowVersion "LOUDNESS"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.b.8  -text "MIX" -command {ShowVersion "MIX"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.b.9  -text "MORPH" -command {ShowVersion "MORPH"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.b.10 -text "PITCH:HARMONY" -command {ShowVersion "PITCH:HARMONY"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.b.11 -text "PITCH INFO" -command {ShowVersion "PITCH INFO"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.b.12 -text "PITCH:SPEED" -command {ShowVersion "PITCH:SPEED"} -width 26 -highlightbackground [option get . background {}]
		pack $f.2.b.1 $f.2.b.2 $f.2.b.3 $f.2.b.4 $f.2.b.5 $f.2.b.6 $f.2.b.7 $f.2.b.8 $f.2.b.9 $f.2.b.10 \
		$f.2.b.11 $f.2.b.12 -side top -pady 1
		button $f.2.c.1  -text "PVOC" -command {ShowVersion "PVOC"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.c.2  -text "RADICAL" -command {ShowVersion "RADICAL"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.c.3  -text "REPITCH" -command {ShowVersion "REPITCH"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.c.4  -text "REVERB:ECHO" -command {ShowVersion "REVERB:ECHO"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.c.5  -text "SIMPLE" -command {ShowVersion "SIMPLE"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.c.6  -text "SOUND INFO" -command {ShowVersion "SOUND INFO"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.c.7  -text "SPECTRAL INFO" -command {ShowVersion "SPECTRAL INFO"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.c.8  -text "SPACE" -command {ShowVersion "SPACE"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.c.9  -text "STRANGE" -command {ShowVersion "STRANGE"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.c.10 -text "STRETCH" -command {ShowVersion "STRETCH"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.c.11 -text "SYNTHESIS" -command {ShowVersion "SYNTHESIS"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.c.12 -text "TEXTURE" -command {ShowVersion "TEXTURE"} -width 26 -highlightbackground [option get . background {}]
		pack $f.2.c.1 $f.2.c.2 $f.2.c.3 $f.2.c.4 $f.2.c.5 $f.2.c.6 $f.2.c.7 $f.2.c.8 $f.2.c.9 $f.2.c.10 \
		$f.2.c.11 $f.2.c.12 -side top -pady 1
		if {[file exists [file join $evv(CDPROGRAM_DIR) psow$evv(EXEC)]]} {
			button $f.2.d.1  -text "PITCH SYNC GRAINS" -command {ShowVersion "PSOW"} -width 26 -highlightbackground [option get . background {}]
		} else {
			button $f.2.d.1  -text "" -command {} -width 26 -bd 0 -highlightbackground [option get . background {}]
		}
		if {[file exists [file join $evv(CDPROGRAM_DIR) oneform$evv(EXEC)]]} {
			button $f.2.d.2  -text "SINGLE FORMANTS" -command {ShowVersion "ONEFORM"} -width 26 -highlightbackground [option get . background {}]
		} else {
			button $f.2.d.2  -text "" -command {} -width 26 -bd 0 -highlightbackground [option get . background {}]
		}
		button $f.2.d.3  -text "MAXSAMP" -command {ShowVersion "MAXSAMP"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.d.4  -text "" -command {} -width 26 -bd 0 -highlightbackground [option get . background {}]
		button $f.2.d.5  -text "TABLE EDITOR" -command {ShowVersion "TABLE EDITOR"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.d.6  -text "" -command {} -width 26 -bd 0 -highlightbackground [option get . background {}]
		button $f.2.d.7  -text "GRAPHIC DISPLAY FRM WKSPACE" -command {ShowVersion "GRAPHIC DISPLAY FROM WORKSPACE"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.d.8  -text "GRAPHICALLY EDIT PITCHFILE" -command {ShowVersion "GRAPHICALLY EDIT A PITCHFILE"} -width 26 -highlightbackground [option get . background {}]
		if {[file exists [file join $evv(CDPROGRAM_DIR) vuform$evv(EXEC)]]} {
			button $f.2.d.9  -text "GRAPHICALLY DISPLAY FORMANT" -command {ShowVersion "VUFORM"} -width 26 -highlightbackground [option get . background {}]
		} else {
			button $f.2.d.9  -text "" -command {} -width 26 -bd 0 -highlightbackground [option get . background {}]
		}
		button $f.2.d.10 -text "CDPARSE" -command {ShowVersion "CDPARSE"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.d.11 -text "CDPARAMS" -command {ShowVersion "CDPARAMS"} -width 26 -highlightbackground [option get . background {}]
		button $f.2.d.12 -text "DISKSPACE" -command {ShowVersion "DISKSPACE"} -width 26 -highlightbackground [option get . background {}]
		pack $f.2.d.1 $f.2.d.2 $f.2.d.3 $f.2.d.4 $f.2.d.5 $f.2.d.6 $f.2.d.7 $f.2.d.8 $f.2.d.9 $f.2.d.10 \
		$f.2.d.11 $f.2.d.12 -side top -pady 1

		pack $f.2.a $f.2.b $f.2.c $f.2.d -side left -padx 2

		button $f.3.1 -text "SYSTEM PROGRAMS" -command {ShowVersion "SYSTEM PROGRAMS"} -width 26 -highlightbackground [option get . background {}]
		pack $f.3.1 -side top -pady 2
		pack $f.1 $f.2 $f.3 -side top -pady 2
		wm resizable .version 0 0
		bind $f <Return> {set pr_version 0}
		bind $f <Escape> {set pr_version 0}
		bind $f <Key-space> {set pr_version 0}
	}
	set pr_version 0
	raise $f
	update idletasks
	StandardPosition2 .version
	My_Grab 0 $f pr_version
	tkwait variable pr_version
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc ShowVersion {str} {
	global CDPv do_version CDPversions evv
	
	switch -- $str {
		"SYSTEM PROGRAMS"	{
			set testprgs [list cdparams gobo gobosee progmach diskspace histconv maxsamp2 listdate]
		}
		"GRAPHICALLY EDIT A PITCHFILE"		{ set testprgs [list paudition pmodify pdisplay] }
		"GRAPHIC DISPLAY FROM WORKSPACE"	{ set testprgs [list pview pagrab paview] }
		"DATA CREATE FILTER FILES"	{ set testprgs [list filter] } 
		"DATA CREATE BATCH FILES"	{ set testprgs [list housekeep] }
		"CDPARSE"		{ set testprgs [list cdparse] }
		"TABLE EDITOR"	{ set testprgs [list brkdur columns getcol putcol vectors] }
		"CDPARAMS"		{ set testprgs [list cdparams] }
		"CDPARAMS_OTHER" { set testprgs [list cdparams_other] }
		"TKUSAGE"		{ set testprgs [list tkusage] }
		"TKUSAGE_OTHER"	{ set testprgs [list tkusage_other] }
		"GOBO"			{ set testprgs [list gobo] }
		"DISKSPACE"		{ set testprgs [list diskspace] }
		"MAXSAMP"		{ set testprgs [list maxsamp2] }
		"BLUR"			{ set testprgs [list blur] }
		"COMBINE"		{ set testprgs [list combine] }
		"DISTORT"		{ set testprgs [list distort] }
		"ENVELOPE"		{ set testprgs [list envel] }
		"EXTEND"		{ set testprgs [list extend] }
		"FILTER"		{ set testprgs [list filter] }
		"FOCUS"			{ set testprgs [list focus]	}
		"FORMANTS"		{ set testprgs [list formants] }
		"GRAIN"			{ set testprgs [list grain] }
		"HARMONIC FIELD" { set testprgs [list hfperm] }
		"HILIGHT"		{ set testprgs [list hilite] }
		"HOUSEKEEP"		{ set testprgs [list housekeep] }
		"REVERB:ECHO"	{ set testprgs [list rmresp rmverb tapdelay modify] }
		"MORPH"			{ set testprgs [list morph] }
		"PITCH:SPEED"	{ set testprgs [list modify] }
		"PITCH:HARMONY"	{ set testprgs [list pitch] }
		"PITCH INFO"	{ set testprgs [list pitchinfo] }
		"PVOC"			{ set testprgs [list pvoc] }
		"REPITCH"		{ set testprgs [list repitch] }
		"EDIT"			{ set testprgs [list sfedit] }
		"SOUND INFO"	{ set testprgs [list sndinfo] }
		"SIMPLE"		{ set testprgs [list spec] }
		"SPECTRAL INFO"	{ set testprgs [list specinfo] }
		"STRANGE"		{ set testprgs [list strange] }
		"STRETCH"		{ set testprgs [list stretch] }
		"MIX"			{ set testprgs [list submix] }
		"SYNTHESIS"		{ set testprgs [list synth] }
		"TEXTURE"		{ set testprgs [list texture] }
		"PSOW"			{ set testprgs [list psow] }
		"ONEFORM"		{ set testprgs [list oneform] }
		"VUFORM"		{ set testprgs [list vuform] }
		"ENVELOPE IMPOSE CONTOUR" -
		"LOUDNESS"				  -
		"SPACE"					  -
		"PITCH_SPEED"			  -
		"CHANNELS"				  -
		"BRASSAGE"				  -
		"RADICAL"		{ set testprgs [list modify] }
	}
	set do_version 0
	catch {unset CDPversions}

	Inf "THIS FEATURE NOT YET AVAILABLE FOR MAC"
	return

	set lastline 0
	foreach testprg $testprgs {
		set cmd [file join $evv(CDPROGRAM_DIR) $testprg]
		lappend cmd "--version"
		if [catch {open "|$cmd"} CDPv] {
			ErrShow "$CDPv"
			return
   		} else {
   			fileevent $CDPv readable "DisplayVersion"
			vwait do_version
   		}
		catch {close $CDPv}
		if {!$do_version} {
			Inf "Failed To Find Version Of Program $testprg"
			return
		}
		set line [lrange $CDPversions $lastline end]
		if {[llength $line] > 1} {
			set CDPversions [lreplace $CDPversions $lastline end "5.0.0"]
		} elseif {![regexp {^[0-9]+\.[0-9]+\.[0-9]+} $line]} {
			set CDPversions [lreplace $CDPversions $lastline end "5.0.0"]
		}
		set lastline [llength $CDPversions]
	}
	if {$do_version} {
		if {[info exists CDPversions]} {
			set msg ""
			foreach testprg $testprgs version $CDPversions {
				append msg "$testprg : version_number $version\n"
			}
			Inf $msg
		} else {
			Inf "Failed To Find Version Numbers Of Program"
			return
		}
	}
}

proc DisplayVersion {} {
	global do_version CDPv CDPversions
	if {![info exists CDPv] || [eof $CDPv]} {
		set do_version 1
		catch {close $CDPv}
		return
	} else {
		gets $CDPv line
		set line [string trim $line]
		if {[string length $line] <= 0} {
			return
		}
		lappend CDPversions $line
	}
}
