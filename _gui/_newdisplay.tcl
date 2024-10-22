#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD 29 June 2013
# ... fixed up button rectangles
# ... reduced height of "big" spectral display (sn(height)) to 300, use variables for both big and small
# ...  reduced precision of spectrum scale marks so they are easily legible
#
# brktype 0 outputs a pair of times (edges of box)
# brktype 1 outputs a brkpnt sequence of time-val
# brktype 2 outputs a SINGLE  time-point
# brktype 3 outputs a LIST OF SINGLE  time-points
# brktype 4 outputs a LIST OF SINGLE  time-points, and sets the input display to cut off at end of shortest file --> brktype 3
# brktype 5 outputs a LIST OF SINGLE  time-points where the value column in a breakpoint file cannot be range-specified (e.g. vowel values)   --> brktype 3
# brktype 6 outputs a LIST OF SINGLE  time-points where the text data has to contain alphabetic markers, to be entered by user im text window --> brktype 3
# brktype 7 outputs a LIST OF SINGLE  time-points, NOT sorted into time-order (for zigzag)
# brktype 8 allows  a LIST OF TIMES FROM a brkpnt file where value column can't be range-specified, to be displayed as markers, moved (only)
#						then reassociated with value column on output
# brktype 9 allows  a LIST OF TIMES FROM a timed FILTER DATA, to be displayed as markers, moved (only)
#						then reassociated with value column on output
#
# time evv(GRPS_OUT) = (gp)samples output
# time evv(TIME_OUT) = time output
# time evv(SMPS_OUT) =  absolute samples output
#
# "Listing" can be
# 1) The address of a real listing where data output will be sent
# 2) A mnemonic indicating a valueBOX where data is to be sent (associated with CLEANING KIT windows)
# 3) A numerical value > 0, being the number of a process, which helps determine to which PARAMPAGE parameter box data is sent
# 4) 0  = evv(SN_FROM_WKSP_NO_OUTPUT) indicating NO OUPUT, calling environment is workspace page.
# 5) -1 = evv(SN_FILE_PRMPAGE_NO_OUTPUT) indicating NO OUPUT, gives filename, where but calling environment is parameter page.
# 6) -2 = evv(SN_FROM_PRMPAGE_NO_OUTPUT) indicating NO OUPUT, calling environment is parameter page.

#---- Determine what kind of display the user wants to use

#RWD
set bigspech 300
set smallspech 300

proc GetSnackState {init} {
	global snack_enabled wstk pr_installsnack snack_notstereo snack_stereo evv
	set fnam [file join $evv(CDPRESOURCE_DIR) $evv(SNACK)$evv(CDP_EXT)]
	if {$init} {
		if {![file exists $fnam]} {
			set msg "The New 'SoundView' Facility Has Been Installed.\n"
			append msg "\n"
			append msg "This Only Functions With Tk/Tcl Versions 8.4 Or Later.\n"
			append msg "\n"
			append msg "You Can Modify This Facility Via The System State Menu On The Workspace.\n" 
			append msg "\n"
			append msg "On Some Operating Systems, Soundview Windows May Fail To Clear When They Are Closed.\n"
			append msg "There Is An Option To Force Window-Clearing.\n"
			append msg "\n"
			append msg "Soundview Displays Stereo Files As A Single Waveform.\n"
			append msg "(It Does Not Show The Channels Separately).\n"
			append msg "\n"
			append msg "There Is An Option To Retain The Existing View Facility For Stereo Files.\n"
			append msg "\n"
			Inf $msg
			set snack_enabled 1
			set snack_stereo 1
		} else {
			if [catch {open $fnam "r"} Ifd] {
				set msg "Cannot Open File '$fnam' To Read Soundview State : $Ifd\n"
				append msg "Defaulting To Soundview On\n"
				append msg "You Can Modify This Via The System State Menu"
				Inf $msg
				set snack_enabled 1
				set snack_stereo 1
				return
			} else {
				set OK 1
				gets $Ifd line
				set line [string trim $line]
				if {[IsNumeric $line]} {
					if {$line > 100} {
						set snack_stereo 1
						set line [expr $line - 100]
					} else {
						set snack_stereo 0
					}
					if {($line >= 0) && ($line <= 2)} {
						set snack_enabled $line
					} else {
						set OK 0
					}
				} else {
					set OK 0
				}
				if {!$OK} {
					set msg "Corrupted Data For Soundview State In File $fnam : $Ifd\n"
					append msg "Defaulting To Normal Soundview Mode\n"
					append msg "You Can Modify This\n"
					append msg "Via The System State Menu"
					Inf $msg
					set snack_enabled 1
					set snack_stereo 1
				}
				if {$snack_enabled <= 0} {
					set snack_enabled 1
				}
			}
			return
		}
	}
	set f .installsnack
	if [Dlg_Create $f "Sound View Operation" "set pr_installsnack 0" -borderwidth $evv(SBDR)] {
		button $f.0 -text "OK" -command "set pr_installsnack 1" -highlightbackground [option get . background {}]
		pack $f.0 -side top -pady 2
		frame $f.1
		radiobutton $f.1.on -text "NORMAL"     -variable snack_enabled -value 1 -width 15
		radiobutton $f.1.cl -text "+ WINDOW CLEAR" -variable snack_enabled -value 2 -width 15
		pack $f.1.on $f.1.cl -side left
		pack $f.1 -side top
		label $f.1a -text "\n"
		label $f.1b -text "Select WINDOW CLEAR if the new SoundView windows"
		label $f.1c -text "fail to clear from your screen."
		label $f.1d -text "\n"
		pack $f.1a $f.1b $f.1c $f.1d -side top
		checkbutton $f.2 -variable snack_notstereo -text "OLD STEREO FILES VIEW (see below)"
		pack $f.2 -side top
		label $f.3 -text "\n"
		label $f.4 -text "New SoundView does not display channels of a stereo file independently,"
		label $f.5 -text "But it enables data values for parameters or files"
		label $f.6 -text "to be created from the graphics at the press of a button."
		label $f.7 -text "\n"
		label $f.8 -text "For multichannel files, options are offered"
		label $f.9 -text "to mix down to mono or stereo before viewing"
		label $f.10 -text "as direct viewing of multichannel files displays only some channels."
		label $f.11 -text "\n"
		label $f.12 -text "If you want to see stereo channels independently"
		label $f.13 -text "in cases where data is not being generated"
		label $f.14 -text "choose OLD STEREO FILES VIEW."
		label $f.15 -text "\n"
		label $f.16 -text "( OLD STEREO FILES VIEW does NOT work with multichannel files)"
		label $f.17 -text "\n"
		pack $f.3 $f.4 $f.5 $f.6 $f.7 $f.8 $f.9 $f.10 $f.11 $f.12 \
			$f.13 $f.14 $f.15 $f.16 $f.17 -side top
		wm resizable $f 1 1
		bind $f <Return> {set pr_installsnack 1}
	}
	set snack_notstereo [expr !$snack_stereo]
	set finished 0
	set pr_installsnack 0
	raise $f
	update idletasks
	StandardPosition2 $f
	My_Grab 0 $f pr_installsnack
	tkwait variable pr_installsnack
	if {$snack_notstereo} {
		set snack_stereo 0
		set val $snack_enabled
	} else {
		set snack_stereo 1
		set val [expr $snack_enabled + 100]
	}
	if [catch {open $fnam "w"} Ifd] {
		Inf "Cannot Open File '$fnam' To Store Soundview State : $Ifd"
	} else {
		puts $Ifd $val
		close $Ifd
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

# ----- This Is A Kludge To Get Rid Of Snack Windows if they Hangs Around (they do on My Home PC, and on my MAC)

proc ClearSnackWindow {listing} {
	global papag evv
	switch -- $listing {
		"noiseg" {
			set exwin .denoi
		} 
		"noisegst" {
			set exwin .stdenoi
		} 
		"unnoiseg" {
			set exwin .unn
		} 
		"grftins" {
			set exwin .grft
		} 
		"pchdata" {
			set exwin .p_corr
		} 
		"fofisolate" {
			set exwin .fofex
		} 
		"syncmarks" {
			set exwin .massign
		} 
		"syncmarks2" {
			set exwin .isolate
		} 
		"syncmarks3" {
			set exwin .synctrans
		} 
		"syncmarks4" {
			set exwin .synlev
		} 
		"syncmarks5" {
			set exwin .syncmulti
		} 
		"realmarks" {
			set exwin .idealrh
		} 
		"mmtrim" {
			set exwin .mmtrim
		} 
		"emphasize" {
			set exwin .rss2
		} 
		"qikedit" -
		"qikedit2" -
		"qikedit3" {
			set exwin .mixdisplay2
		} 
		"mixmix" {
			set exwin $papag
		} 
		"playlist" {
			set exwin .playlist
		} 
		"fofex1" -
		"fofex6" -
		"fofex7" {
			set exwin .ppg
		} 
		"nessco" {
			set exwin .nessco
		} 
		"cliklist" {
			set exwin .do_click
		} 
		default {
			if {[IsNumeric $listing]} {
				if {$listing == $evv(SN_FROM_WKSP_NO_OUTPUT)} {
					set exwin .workspace
				} elseif {$listing == $evv(SN_FROM_SMOOTHER_NO_OUTPUT)} {
					set exwin .newenv
				} elseif {$listing == $evv(SN_FROM_CLEANKIT_NO_OUTPUT)} {
					set exwin .ckit
				} elseif {$listing == $evv(SN_FROM_PROPSPAGE_NO_OUTPUT)} {
					set exwin .nuaddp
				} elseif {$listing == $evv(SN_FROM_PROPSRHYTHM_NO_OUTPUT)} {
					set exwin .rhypropscreen
				} elseif {$listing == $evv(SN_FROM_PROPSHF_NO_OUTPUT)} {
					set exwin .phfpage
				} elseif {$listing == $evv(SN_FROM_PROPSTAB_NO_OUTPUT)} {
					set exwin .proptab
				} elseif {$listing == $evv(SN_FROM_FOFCNSTR_NO_OUTPUT)} {
					set exwin .fofex
				} elseif {$listing == $evv(SN_FROM_DEGRADE_NO_OUTPUT)} {
					set exwin .degrade
				} elseif {$listing == $evv(SN_FROM_POLYF_NO_OUTPUT)} {
					set exwin .polyf
				} elseif {$listing == $evv(SN_FROM_CLEANKIT_OUTPUT)} {
					set exwin .ckit
				} else {		;# Numbers of CDP processes, called from Parampage
					set exwin .ppg
				}
			} else {
				set zz [split $listing "."]
				foreach item $zz {
					if {[string length $item] > 0} {
						break
					}
				}
				set exwin "."
				append exwin $item
			}
		}
	}
	wm iconify $exwin
	wm deiconify $exwin
}

# ----- This process calls the routine which writes a script for a snack display.
# ----- It tailors that script to the specific soundfile and the environment from which the display is requested.
# ----- Some scripts deal with existing brkpnt, or time-marker data, & can redisplay that data on top of the waveform.
# ----- In the case of existing brkpnt data a subroutine can be called to establish the range of the display of that data.
# ----- The process finally  directs any output from the Snack window to the relevant place (a parameter box or text window).

proc SnackDisplay {brktype listing time pcnt} {
	global snack_got chlist snack_list pa evv denoistt denoiend denoi_fornoise den_t grftstt grft_forpos grft_t prm snack_enabled wl
	global sn_edit sn_pts sn_valsco sn_valhi sn_vallo actvhi actvlo prange sn_mlen sn_nyquist pprg sn_prm1 sn_prm2 sn_valloreal sn_valhireal
	global sn_windows sn_frametime tv_active sn_starty tabed isocuts symasamps fofisocuts emphatimes unn_t mmtrimtimes fof_separator
	global sn_feature sn_peakcnt sn_peakgroupindex sn_windowcnt sn_lofrq sn_hifrq sn_sttwintime sn_endwintime sn_amps nuaddp_esnds
	global sv_dummy sv_dummyname mmod pseudoprog pcorr_start pcorr_end p_corr_src sn_fofunitlen sn_fofunitcnt wstk dfault mixval pr100
	global restailstt restailend ideal_realsamptimes qiksync fad_instt fad_inend rearrastt rearraend rearrains viblocend articv artic_event
	global playchqik mix_outchans rezig dopl contract_dovein contract_doveout mrestailstt mrestailend degrade polyf
	global segment sn_troflist sn_rowcnt streveal pksync interstr doclick_times distrev noisegstfnam 

	catch {unset sn_troflist}
	catch {unset sn_rowcnt}

	if {($listing == $evv(SN_FROM_PROPSTAB_NO_OUTPUT)) && ![info exists pa($pcnt,$evv(FTYP))]} {	;#	pcnt == fnam in this case
		Inf "Cannot View File [file rootname [file tail $pcnt]] As It Is Not On The Workspace"
		return
	}
	if {($listing == $evv(SN_FROM_ENGINEER_NO_OUTPUT)) && ![info exists pa($pcnt,$evv(FTYP))]} {	;#	pcnt == fnam in this case
		Inf "Cannot View File [file rootname [file tail $pcnt]] As It Has Not Been Parsed"
		return
	}
	if {(($listing == "qikedit") || ($listing == "qikedit2")) && ![string match $pcnt $evv(DFLT_OUTNAME)0$evv(SNDFILE_EXT)] \
	&& ![info exists pa($pcnt,$evv(FTYP))]} {	;#	pcnt == fnam in this case
		Inf "Cannot View File [file rootname [file tail $pcnt]]"
		return
	}
	if {($listing == $evv(SN_FROM_DEGRADE_NO_OUTPUT))} {
		if {![info exists degrade(output)] || ![file exists $degrade(output)]} {
			return
		}
		set fnam $degrade(output)
	}
	if {$listing == "reveal"} {
		set fnam $streveal(fnam)
	}
	if {$listing == "distrev"} {
		set fnam $distrev(ifnam)
	}
	if {$listing == "noisegst"} {
		set fnam $noisegstfnam
	}
	if {($listing == $evv(SN_FROM_POLYF_NO_OUTPUT))} {
		if {![info exists polyf(output)] || ![file exists $polyf(output)]} {
			return
		}
		set fnam $polyf(output)
	}
	if {($listing == "nessco") || ($listing == "cliklist")} {
		set fnam $pcnt
	}
	set do_exit 0
	if {![IsNumeric $pcnt]} {
		if {![IsCleanKitWindow $listing] && ![string match $listing "fofisolate"] \
		&& ![string match $listing "mixmix"] && ![string match $listing "qikedit"] && ![string match $listing "qikedit2"] \
		&& ![string match $listing "mixcross"] && ![string match $listing "contract"]} {
			set do_exit 1
		}
	} elseif {![IsMultiEditType $pprg] || ([info exists pseudoprog] && (($pseudoprog == $evv(SLICE)) || ($pseudoprog == $evv(SNIP)) || ($pseudoprog == $evv(ELASTIC))))} {
		set do_exit 1
	}
	if {($listing == $evv(ENV_DOVETAILING)) || ($listing == "contract")} {
		set do_exit 0
	}
	if {$listing == "reveal"} {
		set do_exit 1
	}
	set sn_windows 0
	set sn_edit 0
	set sn_mlen 1024		;#	THESE VALUES ARE DEFAULTS FOR WHEN A SNDFILE IS DISPLAYED BY SNACK.
	set sn_nyquist 22100	;#  WHERE AN ANLYSIS FILE IS INPUT BY USER, mlen AND nyquist ARE PICKED UP FROM FILE PROPERTIES
	catch {unset sn_starty}

	catch {unset totabed}
	if {[info exists tabed] && [string match $listing $tabed.bot.otframe.l.list]} {
		set totabed 1
	}
	if {[string match $listing $evv(SN_FROM_WKSP_NO_OUTPUT)]} {		 ;#	From Workspace: already know it's a soundfile
		set i [$wl curselection]
		set fnam [$wl get $i]
	} elseif {[string match $listing troflist]} {							;#	From Voicebox: filename is in place  of "time" param
		set fnam $time
		set sn_troflist 1
	} elseif {[string match $listing "playlist"]} {							;#	From Workspace Playlist
		set i [.playlist.play.playlist.list curselection]
		set fnam [.playlist.play.playlist.list get $i]
	} elseif {[string match $listing "rezig"] || [string match $listing "doppler"] || [string match $listing "contract"]} {
		set fnam $pcnt
	} elseif {[string match $listing $evv(SN_FROM_SMOOTHER_NO_OUTPUT)] || [string match $listing "sn_artic"]} {	;#	From envelope smoother or "Artic" button
		set fnam $pcnt														;#	: already know it's a soundfile
	} elseif {[string match $listing "qikedit"] || [string match $listing "qikedit2"] || [string match $listing "qikedit3"] \
	|| [string match $listing "mixmix"] || [string match $listing "mmtrim"] || [string match $listing "syncpeaks"] || [string match $listing "internalstr"]} {	
		set fnam $pcnt														;#	From parampage for MIX, output display: already know it's a soundfile	
		set time $evv(TIME_OUT)
	} elseif { $listing <= $evv(SN_SENDFILE_NO_OUTPUT_TOP)} {				;#	no ouput, plus receives a filename
		set fnam $pcnt
		if {$listing != $evv(SN_FROM_FOFCNSTR_NO_OUTPUT)} {
			set time $evv(TIME_OUT)
		}
		if {$listing == $evv(SN_FROM_MULTICHAN_CHANVIEW)} {
			switch -- $playchqik {
				1 {
					set bigfnam [lindex $chlist 0]
					set pa($fnam,$evv(DUR))	   [expr $prm(1) - $prm(0)]
					set pa($fnam,$evv(SRATE))  $pa($bigfnam,$evv(SRATE))
					set pa($fnam,$evv(INSAMS)) [expr int(round($pa($fnam,$evv(DUR)) * double($pa($fnam,$evv(SRATE)))))]

				} 
				2 {
					set bigfnam cdptest0$evv(SNDFILE_EXT)
					set pa($fnam,$evv(DUR))	   $pa($bigfnam,$evv(DUR))
					set pa($fnam,$evv(SRATE))  $pa($bigfnam,$evv(SRATE))
					set pa($fnam,$evv(INSAMS)) [expr int(round($pa($bigfnam,$evv(DUR)) * double($pa($bigfnam,$evv(SRATE)))))]

				} 
				0 {
					if {[info exists chlist] && ([llength $chlist] == 1) && ($pa([lindex $chlist 0],$evv(FTYP)) == $evv(SNDFILE))} {
						set bigfnam [lindex $chlist 0]
					} else {
						set bigfnam [$wl get [$wl curselection]]
					}
					set pa($fnam,$evv(DUR))	   $pa($bigfnam,$evv(DUR))
					set pa($fnam,$evv(SRATE))  $pa($bigfnam,$evv(SRATE))
					set pa($fnam,$evv(INSAMS)) [expr $pa($bigfnam,$evv(INSAMS))/$pa($bigfnam,$evv(CHANS))]
				}
			}
			set pa($fnam,$evv(CHANS)) 1
		}
	} elseif {[string match $listing pchdata]} {							;#	from Pitchdata on Music Testbed
		set fnam2 $time
		set fnam $p_corr_src
		set time $evv(TIME_OUT)
	} elseif {[string match $listing mixcross]} {							;#	from Mixcross
		set fnam $pcnt
		set time $evv(TIME_OUT)
	} elseif {[string match $listing vibloc]} {							;#	from LocalVib Button for PSOW_EXTEND
		set fnam [lindex $chlist 0]
	} elseif {$brktype == $evv(SN_MULTIFILES)} {
		set fnam [ShortestInfile]
		if {[string length $fnam] <= 0} {
			return
		}
		set brktype $evv(SN_TIMESLIST)
	} elseif {$brktype == $evv(SN_BRKPNT_TIMEONLY)} {
		set fnam [FindSoundSrc]
		if {[string length $fnam] <= 0} {
			return
		}
		set msg "The Sound Display Can Output Only A List Of Times\n\n"	
		if {$tv_active && ($pprg == $evv(FLTBANKV))} {
			append msg "You Can Add The Pitch Data From A Midi Keyboard, Or By Hand"
		} else {
			switch -regexp -- $pprg \
				^$evv(FLTBANKV)$ {
					append msg "You Must Then Add The Filter Pitch Values By Hand"
					} \
				^$evv(FREEZE2)$ {
						append msg "You Must Then Add The Necessary Hold Times By Hand"
				} \
				^$evv(VFILT)$ {
						append msg "You Must Then Add The Vowel Values By Hand"
				}

		}
		Inf $msg
		set brktype $evv(SN_TIMESLIST)
	} elseif {$brktype == $evv(SN_WITHALPHA)} {
		set fnam [FindSoundSrc]
		if {[string length $fnam] <= 0} {
			return
		}
		Inf "The Sound Display Can Output Only A List Of Times: You Must Add Any Marker Values To Those Times"	
		set brktype $evv(SN_TIMESLIST)
	} elseif {($brktype == $evv(SN_UNSORTED_TIMES)) || ($brktype == $evv(SN_MOVETIME_ONLY)) || ($brktype == $evv(SN_MOVETIME_ONLY2)) \
		   || ($brktype == $evv(SN_SINGLEFRQ)) || ($brktype == $evv(SN_FRQBAND))} {
		set fnam [FindSoundSrc]
		if {[string length $fnam] <= 0} {
			return
		}
	} elseif {![regexp {^[0-9]+$} $pcnt]} {
		set fnam $pcnt
	} elseif {$listing == $evv(ENV_DOVETAILING)} {
		set fnam [lindex $chlist 0]
	} else {
		set fnam [FindSoundSrc]
		if {[string length $fnam] <= 0} {
			return
		}
	}
	if {($brktype == $evv(SN_BRKPNTPAIRS)) && [info exists sv_dummy] && $sv_dummy} {
		set fnam $sv_dummyname
	}
	if {![file exists $fnam]} {
		Inf "File $fnam No Longer Exists"
		return
	}
	if {[string match $listing ".maketext.k.t"]} {	;#	Via Parampage: Get File: Edit
		set sn_edit [AssessDataToDisplay $fnam $time $listing $brktype $pcnt]
		if {$sn_edit < 0} {
			return
		}
	} elseif {[string match $listing troflist]} { ;#	from vbox
		set sn_edit [VBoxDataToDisplay $brktype]
		if {$sn_edit <= 0} {
			return
		}
	} else {
		set sn_edit 0
	}
	if {$brktype == $evv(SN_MOVETIME_ONLY2)} {
		if {$pprg == $evv(FLTBANKV)} {
			set brktype $evv(SN_TIMESLIST)
		} else {
			set brktype $evv(SN_MOVETIME_ONLY)
		}
	}
	if {($listing != $evv(SN_FROM_FOFCNSTR_NO_OUTPUT)) && ($listing != $evv(SN_FROM_MULTICHAN_CHANVIEW)) && ($listing != "mixmix") && ($listing != "rezig") \
	&&  ($listing != "troflist")} {
		SnParameterOutputs
	}
	if {$brktype == $evv(SN_BRKPNTPAIRS)} {
		if {[string match $listing troflist]} {
			if {![info exists segment(displaysegs)]} {
				switch -- $segment(process) {
					TIMESTRETCH -
					ITERATE -
					ZIGZAG {
						set sn_valsco [expr $segment(MAXTSTR) - $segment(MINTSTR)]
						set sn_valhi  $segment(MAXTSTR)
						set sn_vallo  $segment(MINTSTR)
						set sn_dflt   $segment(DFLTTSTR)
					}
					DISTREP -
					VIBRATO -
					TREMOLO -
					REVERB	-
					LOOP	-
					SCAN	-
					FORMOVE -
					VOCODE	-
					EDOCOV	-
					BOUNCE	-
					TWANG	-
					VERGES	-
					TEXTURE -
					ACCENT	-
					TUNED	-
					HPITCH  -
					SPIKE   -
					SQZBOX  -
					TRANSFER -
					ZIGACCEL -
					TSTRETCH -
					PLUCKED {
						set sn_valsco [expr $segment(hi$segment(vp)) - $segment(lo$segment(vp))]
						set sn_valhi  $segment(hi$segment(vp))
						set sn_vallo  $segment(lo$segment(vp))
						set sn_dflt   $segment(pv$segment(vp))		;#	vp = Variable Param no : pv = dflt Param Val
					}
					default {
						Inf "UNKNOWN PROCESS ($segment(process)) IN SOUND VIEW DISPLAY"
						return
					}
				}
			}
			set sn_edit 0
		} else {
			set sn_valsco [expr $actvhi($pcnt) - $actvlo($pcnt)]
			set sn_valhi  $actvhi($pcnt)
			set sn_vallo  $actvlo($pcnt)
			set sn_dflt   [SnackDflt $pcnt]
		}
		if {$sn_edit > 0} {
			set miny [lindex $sn_pts 1]
			set maxy $miny
			foreach {x y} [lrange $sn_pts 2 end] {
				if {$y > $maxy} {
					set  maxy $y
				}
				if {$y < $miny} {
					set  miny $y
				}
			}
			set rr [SpecifySnackRange $actvlo($pcnt) $maxy [lindex $chlist 0] $actvhi($pcnt)]
			if {[llength $rr] > 1} {
				set sn_vallo [lindex $rr 0]
				set sn_valhi [lindex $rr 1]
				set sn_valsco [expr $sn_valhi - $sn_vallo]
			} elseif {$rr < 0} {
				return
			}
		} else {
			if {[string match $listing troflist]} {
				if {![info exists segment(displaysegs)]} {
					set rr [SpecifySnackRange $sn_vallo $sn_valhi 0 $sn_valhi]
				}
			} else {
				set rr [SpecifySnackRange $actvlo($pcnt) $actvhi($pcnt) [lindex $chlist 0] $actvhi($pcnt)]
			}
			if {[llength $rr] > 1} {
				set sn_vallo [lindex $rr 0]
				set sn_valhi [lindex $rr 1]
				set sn_valsco [expr $sn_valhi - $sn_vallo]
			} elseif {$rr < 0} {
				return
			}
		}
		if {($sn_dflt >= $sn_vallo) && ($sn_dflt <= $sn_valhi)} {
			set sn_starty $sn_dflt
		} else {
			set sn_starty $sn_vallo
		}
	} elseif {$brktype == $evv(SN_SINGLEFRQ) || $brktype == $evv(SN_FRQBAND)} {
		set sn_vallo 0
		set sn_valhi $sn_nyquist
		set sn_valsco $sn_nyquist 
		set sn_valloreal $actvlo($sn_prm1)
		if {($pprg == $evv(PITCH)) || ($pprg == $evv(SPECROSS))} {
			set sn_valhireal $actvhi($sn_prm1)
		} else {
			set sn_valhireal $sn_valhi
		}
#
#		NB The values on the display run between 0 and NYQUIST ... 
#		sn_valloreal RESTRICTS the low frqs ONLY at output
#		sn_valhireal RESTRICTS the hi frqs that can be grabbed as potential frq parameters
#	
		set sn_windows 1
		set sn_frametime $pa([lindex $chlist 0],$evv(FRAMETIME))
	} elseif {$brktype == $evv(SN_FEATURES_PEAKS)} {
		set sn_frametime $pa([lindex $chlist 0],$evv(FRAMETIME))
	}
	if {[IsNumeric $listing] && ($listing <= 0)} {
		set enable_output 0
	} elseif {[string match $listing "playlist"]} {
		set enable_output 0
	} elseif {[string match $listing "rezig"]} {
		set enable_output 1
	} elseif {[string match fofex* $listing]} {
		set enable_output 1
	} elseif {$brktype == $evv(SN_FEATURES_PEAKS)} {
		set enable_output 0
	} elseif {($listing == "qikedit") || ($listing == "qikedit2") || ($listing == "qikedit3") || ($listing == "mixmix")} {
		set enable_output 2
	} elseif {$listing == "nessco"} {
		set enable_output 0
	} elseif {$listing == "cliklist"} {
		set enable_output 1
	} elseif {[info exists segment(displaysegs)]}  {
		set enable_output 0
	} else {
		set enable_output 1
	}
	if {[string match $listing troflist]} {
		set chans  $segment(chans)
		set srate  $segment(srate)
		if {[info exists segment(displaytransfer)]} {
			set dur    $pa($segment(outfnamplay),$evv(DUR))
			set insams [expr int(round($dur * $segment(srate)))]
		} else {
			set dur    $segment(dur)
			set insams $segment(insams)
		}
		set time $evv(TIME_OUT)
	} else {
		if {![info exists pa($fnam,$evv(CHANS))]} {
			Inf "File is not on the workspace: cannot proceed"	
			return
		}
		set chans  $pa($fnam,$evv(CHANS))
		set insams $pa($fnam,$evv(INSAMS))
		set srate  $pa($fnam,$evv(SRATE))
		set dur    $pa($fnam,$evv(DUR))
	}

	if {$listing == "pchdata"} {
		set fnam $fnam2
		set chans 1
	}
	set sr_x_chs [expr $srate * $chans]
	if {$brktype != $evv(SN_FEATURES_PEAKS)} {
		catch {unset sn_feature}
		catch {unset sn_peakcnt}
		catch {unset sn_peakgroupindex}
		catch {unset sn_windowcnt}
		catch {unset sn_lofrq}
		catch {unset sn_hifrq}
		catch {unset sn_sttwintime}
		catch {unset sn_endwintime}
		catch {unset sn_amps}
	}
	if {$listing == $evv(SN_FROM_FOFCNSTR_NO_OUTPUT)} {
		set brktype $evv(SN_FROM_FOFCNSTR_NO_OUTPUT)
		set sn_fofunitlen $time
		set sn_fofunitcnt [expr ($insams / $sn_fofunitlen) - 1]
		set time $evv(TIME_OUT)
	}
	if {$pprg == $evv(REPEATER)} {
		set time $evv(TIME_OUT)
	}
	if {$listing == "cliklist"} {
		set time $evv(TIME_OUT)
	}
	SnackCreate $time $brktype $fnam $insams $sr_x_chs $chans $listing $enable_output $pcnt $dur $do_exit
	if {$listing == $evv(SN_FROM_MULTICHAN_CHANVIEW)} {
		PurgeArray $fnam
	}
	if {[info exists snack_list] && ([llength $snack_list] > 0)} {
		if {($pprg == $evv(FLTBANKV)) && [string match $listing ".maketextp.k.t"] && [string match [.maketextp.b.stan cget -text] "Delete Features"]} {
			set keeplines 1
		}
		if {[string match [lindex $snack_list 0] "CLEAR"]} {
			if {[string first "." $listing] == 0} {
				if {[info exists totabed]} {
					$listing delete 0 end
				} else {
					if {![info exists keeplines]} {
						catch {$listing delete 1.0 end}
					}
				}
			}
			set snack_list [lrange $snack_list 1 end]
		}
		catch {unset keeplines}
		switch -- $listing {
			"noiseg" -
			"noisegst" {
				set line [lindex $snack_list 0]
				set line [string trim $line]
				set line [split $line]
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] > 0} {
						lappend nuline $item
					}
				}
				if {[info exists nuline] && ([llength $nuline] == 2)} {
					set denoistt [lindex $nuline 0]
					set denoiend [lindex $nuline 1]
					set denoi_fornoise 0
					if {$listing == "noisegst"} {
						.stdenoi.0.see config -command "SnackDisplay $evv(SN_TIMEPAIRS) $den_t $evv(GRPS_OUT) $noisegstfnam"
					} else {
						.denoi.0.see config -command "SnackDisplay $evv(SN_TIMEPAIRS) $den_t $evv(GRPS_OUT) $fnam"
					}
				}
			} 
			"unnoiseg" {
				foreach line $snack_list {
					$unn_t insert end "$line\n"
				}
			} 
			"grftins" {
				set val [lindex $snack_list end]
				set grftstt $val
				set grft_forpos 0
				.grft.0.see config -command "SnackDisplay $evv(SN_TIMEPAIRS) $grft_t $evv(GRPS_OUT) $fnam"
			} 
			"pchdata" {
				set line [lindex $snack_list 0]
				set pcorr_start [lindex $line 0]
				set pcorr_end [lindex $line 1]
			} 
			"isolate" {
				set isocuts $snack_list
			}
			"fofisolate" {
				set fofisocuts $snack_list
			}
			"emphasize" {
				set emphatimes $snack_list
			}
			"syncmarks" -
			"syncmarks2" -
			"syncmarks3" -
			"syncmarks4" -
			"syncmarks5" {
				catch {unset symasamps(0)}
				foreach item $snack_list {
					if {[string match $item "CLEAR"]} {
						catch {unset symasamps(0)}
					} else {
						lappend symasamps(0) $item
					}
				}
			}
			"realmarks" {
				catch {unset ideal_realsamptimes}
				foreach item $snack_list {
					if {[string match $item "CLEAR"]} {
						catch {unset ideal_realsamptimes}
					} else {
						lappend ideal_realsamptimes $item
					}
				}
			}
			"mmtrim" {
				catch {unset mmtrimtimes}
				foreach item $snack_list {
					if {[string match $item "CLEAR"]} {
						catch {unset mmtrimtimes}
					} else {
						lappend mmtrimtimes $item
					}
				}
			}
			"reveal" {
				set c_cnt 0
				foreach item $snack_list {
					switch -- $c_cnt {
						0 { set streveal(stt) $item }
						1 { set streveal(end) $item }
						2 { set streveal(mstt) $item }
						3 { set streveal(mend) $item }
					}
					incr c_cnt
				}
			}
			"fadein" {
				set vals [lindex $snack_list 0]
				set fad_instt [lindex $vals 0]
				set fad_inend [lindex $vals 1]
			}
			"rearrangech" {
				set vals [lindex $snack_list 0]
				set rearrastt [lindex $vals 0]
				set rearraend [lindex $vals 1]
			}
			"rearranget" {
				set vals [lindex $snack_list 0]
				set rearrains [lindex $vals 0]
			}
			"distrev" {
				set vals [lindex $snack_list 0]
				set distrev(stt) [lindex $vals 0]
			}
			"qikedit" {
				QikEditPlace 1				;#	View mix output from qikedit page
			}
			"qikedit2" {
				QikEditPlace 2				;#	View soundfile-in-mix from qikedit page
			}
			"qikedit3" {
				foreach item $snack_list {
					if {[string match $item "CLEAR"]} {
						catch {unset qiksync}
					} else {
						lappend qiksync $item
					}
				}
				if {![info exists qiksync]} {
					set qiksync 0
				} else {
					set qiksync [lindex $qiksync end]
				}
			}
			"mixmix" {
				QikEditPlace 0				;# THIS IS REDUNDANT	
			}
			"mixcross" {
				set line [lindex $snack_list end]
				set line [string trim $line]
				set line [split $line]
				foreach item $line {
					set item [string trim $item]
					if {[string length $item] > 0} {
						lappend nuline $item
					}
				}
				if {[info exists nuline]} {
					set val1 [lindex $nuline 0]
					set val2 [lindex $nuline 1]
					if {[IsNumeric $val1] && [IsNumeric $val2]} {
						set prm(1) $val1
						set prm(2) $val2
						catch {unset snack_list}
						set pr100 1
						return
					}
				}
			}
			"fofex1" {
				set line [lindex $snack_list end]
				set line [string trim $line]
				set line [split $line]
				set out_put [expr $line / $fof_separator]
				set prm(4) $out_put 	
				return
			}
			"fofex6" {
				set len [llength $snack_list]
				if {$len < 2} {
					Inf "Insuficient FOFs Specified (2 Needed)"
					return
				}
				set stt [expr $len - 2]
				incr len -1
				set snack_list [lrange $snack_list $stt $len]
				set out_put [expr [lindex $snack_list 0] / $fof_separator]
				set prm(4) $out_put 	
				set out_put [expr [lindex $snack_list 1] / $fof_separator]
				set prm(5) $out_put 	
				return
			}
			"fofex7" {
				set len [llength $snack_list]
				if {$len < 3} {
					Inf "Insuficient FOFs Specified (3 Needed)"
					return
				}
				set stt [expr $len - 3]
				incr len -1
				set snack_list [lrange $snack_list $stt $len]
				set out_put [expr [lindex $snack_list 0] / $fof_separator]
				set prm(4) $out_put 	
				set out_put [expr [lindex $snack_list 1] / $fof_separator]
				set prm(5) $out_put 	
				set out_put [expr [lindex $snack_list 2] / $fof_separator]
				set prm(6) $out_put 	
				return
			}
			"restail" {
				catch {unset restailtimes}
				set restailtimes [lindex $snack_list end]
				set restailstt [lindex $restailtimes 0]
				set restailend [lindex $restailtimes 1]
			}
			"mrestail" {
				catch {unset mrestailtimes}
				set mrestailtimes [lindex $snack_list end]
				set mrestailstt [lindex $mrestailtimes 0]
				set mrestailend [lindex $mrestailtimes 1]
			}
			"vibloc" {
				set val $snack_list
				if {$val < $prm(1)} {
					set val $prm(1)
				}
				set viblocend $val
			}
			"syncpeaks" {
				set pksync $snack_list
			}
			"internalstr" {
				set interstr $snack_list
			}
			"sn_artic" {
				foreach val $snack_list {
					if {![IsNumeric $val]} {
						continue
					}
					if {$articv(zro,0) && ($val < [lindex $artic_event(0) 0])} {	;#	If first event elides with start of file
						set articv(onn,1) 1											;#	and time-mark lies within start of file,
					} else {														;#	activate first event
						set k 0
						while {$k < $articv(cnt,0)} {
							set stt  [expr [lindex $artic_event($k) 0] - 0.01]						
							set endd [expr [lindex $artic_event($k) 1] + 0.01]		;#	Otherwise				
							if {($val >= $stt) && ($val <= $endd)} {				;#	if time-mark lies within an event
								incr k												;#	activate that event
								set articv(onn,$k) 1
								break
							}
							incr k
						}
					}
				}
			}
			"rezig" {
				set rezig(mintime) [lindex [lindex $snack_list 0] 0]
				set rezig(maxtime) [lindex [lindex $snack_list 0] 1]
			}
			"doppler" {
				set dopl(time) [lindex $snack_list 0]
			}
			"contract" {
				SetDovetailParams $snack_list $dur
				set contract_dovein  $prm(0)
				set contract_doveout $prm(1)
			}
			"reverg" {
				.reverg.9.t insert 1.0 $snack_list
			}
			"troflist" {
				switch -regexp -- $brktype \
					^$evv(SN_TIMESLIST)$ {
						if {[info exists segment(spike_explicit)]} {
							set snack_list [ReconfigureSpikeData $snack_list]
							if {[llength $snack_list] <= 0} {
								return {}
							}
							set segment(spikepos) $snack_list
							catch {unset snack_list}
							if {$snack_enabled == 2} {
								ClearSnackWindow $listing
							}
							return
						} elseif {[info exists segment(marklist)]} {
							set OK 0
							if {[llength $snack_list] == [llength $segment(marklist)]} {
								set OK 1
								foreach time $snack_list oldtime $segment(marklist) {
									if {$time != $oldtime} {
										set OK 0
										break
									}
								}
							}
							if {$OK} {
								set segment(nochange) 1
								if {![info exists segment(exportsegs)] || ($segment(exportsegs) == 0)} {
									Inf "No change to timings"
								}
								return
							}
						}
						if [catch {open $segment(nutroflist) "w"} zit] {
							Inf "Cannot open file to write edited segmentation data"
							return
						}
						foreach time $snack_list {
							puts $zit $time
						}
						close $zit
					} \
					^$evv(SN_BRKPNTPAIRS)$ {
						if [catch {open $segment(prectrlfil) "w"} zit] {
							Inf "Cannot open file to write control data"
							return
						}
						foreach brkpair $snack_list {
							puts $zit $brkpair
						}
						close $zit
					}
			}
			"cliklist" {
				set doclick_times [lsort -real $snack_list]
			}
			default {
				if {[IsNumeric $listing]} {
					if {$listing == $evv(ENV_DOVETAILING)} {
						SetDovetailParams $snack_list $dur
					} elseif {$listing > 0} {		;#	i.e. WE EXPECT OUTPUT
						set line [lindex $snack_list 0]
						set line [string trim $line]
						set line [split $line]
						foreach item $line {
							set item [string trim $item]
							if {[string length $item] > 0} {
								lappend nuline $item
							}
						}
						if {[info exists nuline]} {
							set len [llength $nuline]
							if {$len == 2} {
								if {![IsCleanKitWindow $listing] && ($pprg == $evv(EDIT_INSERTSIL))} {
									set prm($sn_prm1) [lindex $nuline 0] 
									set prm($sn_prm2) [expr [lindex $nuline 1]  - [lindex $nuline 0]]
								} elseif {($pprg == $evv(ENV_CURTAILING)) && (($mmod == 2) || ($mmod == 5)) } {
									set prm($sn_prm1) [lindex $nuline 0] 
									set prm($sn_prm2) [expr [lindex $nuline 1]  - [lindex $nuline 0]]
								} elseif {$pprg == $evv(HOVER2)} {
									set vdur [expr [lindex $nuline 1]  - [lindex $nuline 0]]	;#	duration
									set prm($sn_prm1) [expr 1.0/($vdur * 2.0)]					;#	hover frq to play whole segment
									set prm($sn_prm2) [expr ($vdur/2.0) + [lindex $nuline 0]]	;#	centre of hover
								} elseif {$pprg == $evv(LOOP)} {
									set prm($sn_prm1) [lindex $nuline 0] 
									set prm($sn_prm2) [expr ([lindex $nuline 1] - $prm($sn_prm1)) * $evv(SECS_TO_MS)]
								} elseif {$pprg == $evv(SPECEX)} {
									set prm($sn_prm1) [lindex $nuline 0] 
									set prm($sn_prm2) [expr [lindex $nuline 1] - [lindex $nuline 0]]
								} else {
									set prm($sn_prm1) [lindex $nuline 0] 
									set prm($sn_prm2) [lindex $nuline 1] 
								}
							} elseif {$len == 1} {
								if {$pprg == $evv(PREFIXSIL)} {
									if {[IsNumeric $prm($sn_prm1)] && ($prm($sn_prm1) >= 0.0)} {
										set newval [expr $prm($sn_prm1) - [lindex $nuline 0]]
										if {$newval <= 0.0} {
											Inf "Impossible To Move Specified Event To Time Already In Parameter Box"
										}
										set prm($sn_prm1) $newval
									} else {
										Inf "Set Desired Value For Time Of An Event In Param Box: Then Mark That Event In Sound View"
									}
								} else {
									set prm($sn_prm1) [lindex $nuline 0]
								}
							}
						}
					}
				} else {
					if {[info exists pseudoprog]} {
						switch -regexp --  $pseudoprog \
							^$evv(SLICE)$ {
								if {[llength $snack_list] <= 0} {
									Inf "Required Data Is A List Of Times:\nEnter Times By Clicking (Not Dragging A Box) On The \"Sound View\" Display."
								} else {
									set snack_list [MakeSliceFile $snack_list $fnam]
								}
							} \
							^$evv(ELASTIC)$ {
								set snack_list [MakeElasticFile $snack_list $fnam]
							} \
							^$evv(SNIP)$ {
								if {[llength $snack_list] <= 0} {
									Inf "Required Data Is A List Of Times:\nEnter Times By Clicking (Not Dragging A Box) On The \"Sound View\" Display."
								} else {
									set snack_list [MakeSnipFile $snack_list $fnam]
								}
							}
					} elseif {$pprg == $evv(MANYSIL)} {
						set snack_list [MakeManysilFile $snack_list]
					} elseif {$pprg == $evv(ISOLATE) && (($mmod == 1) || ($mmod == 2))} {
						set snack_list [MakeIsolateFile $snack_list]
					}
					foreach line $snack_list {
						if {[string match $line CLEAR]} {
							if {[info exists totabed]} {
								$listing delete 0 end
							} else {
								$listing delete 1.0 end
							}
						} else {
							if {[info exists totabed] || [string match $listing .growamb.1.e] || [string match $listing .varispec.6.e]} {
								$listing insert end $line
							} else {
								$listing insert end "\n$line"
							}
						}
					}
				}
			}
		}
		if {($brktype == $evv(SN_UNSORTED_TIMES)) && ($pprg == $evv(DRUNKWALK) && ($pcnt == 0))} {
			Inf "You Have Created A List Of Locations In The Input File\n\nYou Must Now Add A First-Column Of Increasing Times (Starting At Time Zero)\nAt Which The Output File Is Reading From These Locations"
		} elseif {($brktype == $evv(SN_TIMEPAIRS)) && ($pprg == $evv(REPEATER) && ($pcnt == 0))} {
			if {$mmod == 1} {
				Inf "You have created a list of segment timings in the input file\n\nyou must now add a first-column of repeat-counts\nand a second column of delay-times"
			} else {
				Inf "You have created a list of segment timings in the input file\n\nyou must now add a first-column of repeat-counts\nand a second column of offset-times"
			}
		}
	}
	catch {unset snack_list}
	if {$snack_enabled == 2} {
		ClearSnackWindow $listing
	}
}

#----------- Get name of shortest infile

proc ShortestInfile {} {
	global chlist pa evv
	if {![info exists chlist] || ([llength $chlist] <= 0)} {
		Inf "No Sound On Chosen List"	
		return ""
	}
	set cnt 0
	foreach fnam $chlist {
		if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
			return ""
		}
		if {$cnt == 0} {
			set mindur $pa($fnam,$evv(DUR))
			set minfile $fnam
		} elseif {$pa($fnam,$evv(DUR)) < $mindur} {
			set mindur $pa($fnam,$evv(DUR))
			set minfile $fnam
		}
		incr cnt
	}
	Inf "Displaying Shortest Sound: $minfile"
	return $minfile
}

#----------- Find the sound source of anal or pitch file

proc FindSoundSrc {} {
	global chlist src pa evv sn sn_mlen sn_nyquist

	if {![info exists chlist] || ([llength $chlist] <= 0)} {
		Inf "No Files On Chosen List"	
		return
	}
	set fnam [lindex $chlist 0]
	if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
		set sn_nyquist $pa($fnam,$evv(NYQUIST))
		set sn_mlen $pa($fnam,$evv(MLEN))
		set truedur $pa($fnam,$evv(DUR))
		if [info exists src($fnam)] {
			foreach srcfile $src($fnam) {
				if [string match $evv(DELMARK)* $srcfile] {
					continue
				} elseif {![info exists pa($srcfile,$evv(FTYP))]} {
					continue
				} elseif {$pa($srcfile,$evv(FTYP)) != $evv(SNDFILE)} {
					continue
				} else {
					set outfnam $srcfile
					break
				}
			}
		}
		if {![info exists outfnam]} {
			Inf "The Sound Source Of This File Is No Longer On The Workspace"	
			return ""
		}
		set dur $pa($outfnam,$evv(DUR))
		if {$dur != $truedur} {
			if {[expr abs($dur - $truedur)] > 0.05} {
				Inf "Sound Derived From File Of Different Duration"	
				return ""
			}
		}
		return $outfnam
	}
	return $fnam
}

#------------- Where existing data is to be displayed: check it's valid (and possibly establishes a range)

proc AssessDataToDisplay {fnam time listing brktype pcnt} {
	global sv_rangetop sv_rangebot sn_range sn_pts pa wstk evv actvhi actvlo sn_remainder sn_other sn_rowcnt wstk
	catch {unset sn_pts}
	catch {unset sn_other}
	catch {unset sn_remainder}
	switch -regexp -- $time \
		^$evv(TIME_OUT)$ {
			set maxtime $pa($fnam,$evv(DUR))
		} \
		^$evv(SMPS_OUT)$ {
			set maxtime $pa($fnam,$evv(INSAMS))
		} \
		^$evv(GRPS_OUT)$ {
			set maxtime [expr $pa($fnam,$evv(INSAMS)) / $pa($fnam,$evv(CHANS))]
		}

	set dorange 0
	set cnt 0
	set tostop 0
	set OK 1 
	set istime 1

	if {$brktype == $evv(SN_MOVETIME_ONLY2)} {
		set sn_fcnt [FilterDataLineCnt] 
		if {$sn_fcnt < 1} {
			return -1
		}
		foreach word [$listing get 1.0 end] {
			set word [string trim $word]
			if {[string length $word] > 0} {
				if {![IsNumeric $word] || ($word < 0)} {
					set msg "Invalid Data : Delete This Data And Create New Data ?"
					set choice [tk_messageBox -type yesno -message $msg -parent [lindex $wstk end] -icon question]
					if {$choice == "no"} {
						return -1
					} else {
						return 2
					}
				}
				lappend nudata $word
				incr cnt
			}
		}
		set sn_rowcnt [expr $cnt / $sn_fcnt]
		if {[expr $sn_fcnt * $sn_rowcnt] != $cnt} {
			Inf "Data Does Not Tally With Your Line Count"
			return -1
		}
		set cnt 0
		foreach word $nudata {
			if {[expr $cnt % $sn_rowcnt] == 0} {
				if {$word < 0} {
					set msg "Time Is Out Of Range : Delete This Data And Create New Data ?"
					set choice [tk_messageBox -type yesno -message $msg -parent [lindex $wstk end] -icon question]
					if {$choice == "no"} {
						return -1
					} else {
						return 2
					}
				}
				if {$word > $maxtime} {
					lappend sn_remainder [lrange $nudata $cnt end]
					break
				}
				if {$cnt > 0} {
					if {$word < $lasttime} {
						set msg "Times Are Out Of Order ($lasttime $word) : Delete This Data And Create New Data ?"
						set choice [tk_messageBox -type yesno -message $msg -parent [lindex $wstk end] -icon question]
						if {$choice == "no"} {
							return -1
						} else {
							return 2
						}
					}
				}
				lappend sn_pts $word
				set lasttime $word
			} else {
				lappend sn_other $word
			}
			incr cnt
		}
		incr sn_rowcnt -1
		if {![info exists sn_pts]} {
			return -1
		}
		return 1
	}
	foreach word [$listing get 1.0 end] {
		set word [string trim $word]
		if {[string length $word] > 0} {
			if {$brktype == $evv(SN_MOVETIME_ONLY)} {
				if {$tostop >= 2} {
					lappend sn_remainder $word
				} elseif {$istime} {
					if {![IsNumeric $word]} {
						Inf "Invalid Time Data"
						return -1
					}
					if {$word < 0} {
						set msg "Time Less Than Zero, Out Of Range"
						return -1
					}
					if {$cnt > 0} {
						if {$word < $lasttime} {
							Inf "Times Are Out Of Order"
							return -1
						}
					}
					set lasttime $word
					if {$word > $maxtime} {
						lappend sn_remainder $word
						set tostop 1
					} else {
						lappend sn_pts $word
					}
				} else {
					if {$tostop} {
						lappend sn_remainder $word
						incr tostop
					} else {
						lappend sn_other $word
					}
				}
				set istime [expr !$istime]
				incr cnt
			} else {
				if {![IsNumeric $word]} {
					set msg "Invalid Data : Delete This Data And Create New Data ?"
					set choice [tk_messageBox -type yesno -message $msg -parent [lindex $wstk end] -icon question]
					if {$choice == "no"} {
						return -1
					} else {
						return 2
					}
				}
				if {$brktype == $evv(SN_BRKPNTPAIRS)} {
					if {$istime}  {
						if {$word < 0} {
							set msg "Time Is Out Of Range : Delete This Data And Create New Data ?"
							set choice [tk_messageBox -type yesno -message $msg -parent [lindex $wstk end] -icon question]
							if {$choice == "no"} {
								return -1
							} else {
								return 2
							}
						}
						if {$word >= $maxtime} {
							set tostop 1
						}
						if {$cnt > 0} {
							if {$word < $lasttime} {
								set msg "Times Are Out Of Order : Delete This Data And Create New Data ?"
								set choice [tk_messageBox -type yesno -message $msg -parent [lindex $wstk end] -icon question]
								if {$choice == "no"} {
									return -1
								} else {
									return 2
								}
							}
						}
						set lasttime $word
					} else {
						if {($word < $actvlo($pcnt)) || ($word > $actvhi($pcnt))} {
							set msg "Data Is Out Of Range : Delete This Data And Create New Data ?"
							set choice [tk_messageBox -type yesno -message $msg -parent [lindex $wstk end] -icon question]
							if {$choice == "no"} {
								return -1
							} else {
								return 2
							}
						}
						if {$tostop} {
							incr tostop
						}
					}
					set istime [expr !$istime]
					incr cnt
				} else {
					if {$word < 0} {
						set msg "Subzero Time Encountered: Delete This Data And Create New Data ?"
						set choice [tk_messageBox -type yesno -message $msg -parent [lindex $wstk end] -icon question]
						if {$choice == "no"} {
							return -1
						} else {
							return 2
						}
					} elseif {$word > $maxtime} {
						set msg "Time Out Of Range : Ignore It ?"
						set choice [tk_messageBox -type yesno -message $msg -parent [lindex $wstk end] -icon question]
						if {$choice == "no"} {
							return -1
						} else {
							break
						}
					}
				}
				lappend sn_pts $word
				if {$tostop >= 2} {
					break
				}
			}
		}
	}
	if {![info exists sn_pts]} {
		return 0
	}
	if {$brktype == $evv(SN_BRKPNTPAIRS)} {
		if {![IsEven $cnt]} {
			set msg "Invalid Data : Delete It And Create New Data ?"
			set choice [tk_messageBox -type yesno -message $msg -parent [lindex $wstk end] -icon question]
			if {$choice == "no"} {
				return -1
			} else {
				return 2
			}
		}
		if {[lindex $sn_pts 0] != 0.0} {
			set sn_pts [concat 0.0 [lindex $sn_pts 1] $sn_pts]
			incr cnt 2
		}
		set indx [llength $sn_pts]
		incr indx -1
		set endval [lindex $sn_pts $indx]
		incr indx -1
		set endtime [lindex $sn_pts $indx]
		if {$endtime < $maxtime} {
			set sn_pts [concat $sn_pts $maxtime $endval]
			incr cnt 2
		} elseif {$endtime > $maxtime} {
			incr indx -1
			set penultval  [lindex $sn_pts $indx]
			incr indx -1
			set penulttime [lindex $sn_pts $indx]
			set ratio [expr double($endtime - $penulttime) / double($maxtime - $penulttime)]
			set ystep [expr double($endval - $penultval)]
			set nuval [expr ($ystep * $ratio) + $penultval]
			incr indx 2
			set endindx [expr $indx + 1]
			set sn_pts [lreplace $sn_pts $indx $endindx $maxtime $nuval]
		}
	}
	if {$brktype == $evv(SN_TIMEPAIRS)} {
		return 0	;#	Don't edit existing data
	}
	return 1
}

#---- Where existing brkpnt data is being uploaded to the Snack display: allows user to limit range of values displayed, to get best resolution

proc SpecifySnackRange {lo hi fnam realhi} {
	global newrrrange pr_newrange nr_top nr_bot pprg mmod maxsamp_line pa evv newrange_botset
	set f .newrange
	set do_norm 0
	if {[info exists nr_top]} {
		set last_nr_top $nr_top
	}
	if [Dlg_Create $f "SPECIFY RANGE" "set pr_newrange 0" -borderwidth 2 -width 120] {
		frame $f.0
		button $f.0.s -text "Keep Range Below" -command "set pr_newrange 2" -width 16 -highlightbackground [option get . background {}]
		button $f.0.o -text "Standard Range" -command "set pr_newrange 1" -width 16 -highlightbackground [option get . background {}]
		button $f.0.q -text "Abandon" -command "set pr_newrange 0" -width 16 -highlightbackground [option get . background {}]
		pack $f.0.s $f.0.o -side left
		pack $f.0.q -side right

		frame $f.1
		label $f.1.s -text "Top of Range (max [expr int(round($hi))])" -width 25
		button $f.1.n  -text "Norm"  -command "set pr_newrange 3" -width 4 -highlightbackground [option get . background {}]
		button $f.1.f  -text "Flor"  -command "set pr_newrange 4" -width 4 -highlightbackground [option get . background {}]
		button $f.1.ff -text "Flr."  -command "set pr_newrange 5" -width 4 -highlightbackground [option get . background {}]
		button $f.1.l  -text "Last"  -command "set pr_newrange 6" -width 4 -highlightbackground [option get . background {}]
		button $f.1.one -text "1.0"  -command "set pr_newrange 7" -width 4 -highlightbackground [option get . background {}]
		entry $f.1.e -textvariable nr_top -width 16
		pack $f.1.s $f.1.n $f.1.f $f.1.ff $f.1.l $f.1.one -side left -padx 2
		pack $f.1.e -side right

		frame $f.2
		label $f.2.s -text "" -width 30
		entry $f.2.e -textvariable nr_bot -width 16
		radiobutton $f.2.0 -text "0.0" -variable newrange_botset -value 0 -command {}
		radiobutton $f.2.1 -text "1.0" -variable newrange_botset -value 1 -command "set nr_bot [DecPlaces 1.0 1]"
		set newrange_botset 0
		pack $f.2.s $f.2.0 $f.2.1 -side left -padx 2
		pack $f.2.e -side right

		pack $f.0 -side top -fill x -expand true
		pack $f.1 -side top -fill x -expand true
		pack $f.2 -side top -fill x -expand true
		bind $f <Return> "set pr_newrange 2" 
		bind $f <Escape> "set pr_newrange 0" 
		wm resizable $f 1 1
	}
	.newrange.2.0 config -command "set nr_bot $lo"
	.newrange.2.s config -text "Bottom of Range (min $lo)"
	bind $f <Up> "IncrRtop 1 $lo $hi"
	bind $f <Down> "IncrRtop 0 $lo $hi"
	if {$pprg == $evv(MOD_LOUDNESS)} {
		if {($mmod == 1) || ($mmod == 2)} {
			set do_norm $mmod
		}
	}
	if {$do_norm} {
		$f.1.n config -text "Norm" -command "set pr_newrange 3" -bd 2
	} else {
		$f.1.n config -text "" -command {} -bd 0
	}
	set nr_top $hi
	set nr_bot $lo
	set pr_newrange 0
	ScreenCentreBigger $f
	raise $f
	My_Grab 0 $f pr_newrange $f.1.e
	set finished 0
	while {!$finished} {
		tkwait variable pr_newrange
		switch -- $pr_newrange {
			2 {
				if {![IsNumeric $nr_top] || ![IsNumeric $nr_bot]} {
					Inf "Invalid Value(s) Entered"
					continue
				}
				if {$nr_top <= $nr_bot} {
					Inf "Range Too Small, Or Negative"
					continue
				}
				if {($nr_top > $realhi) || ($nr_bot < $lo)} {
					Inf "Range Is Outside Limits Set On Parameters Page"
					continue
				}
				set newrrrange  [list $nr_bot $nr_top]
				set finished 1
			} 
			3 {
				if {![info exists pa($fnam,$evv(MAXSAMP))]} {
					Inf "Sound Maxsamp Not Known"
					continue
				}
				if {$pa($fnam,$evv(MAXSAMP)) <= $evv(FLTERR)}  {
					GetMaxsampOnInput $fnam					
					if {![info exists maxsamp_line]} {
						continue
					}
				}
				if {$pa($fnam,$evv(MAXSAMP)) <= $evv(FLTERR)}  {
					Inf "Sound Level Too Low To Normalise"
					continue
				}
				set gain [expr 1.0 / $pa($fnam,$evv(MAXSAMP))]
				if {$do_norm == 2} {
					set gain [expr 20.0 * log10($gain)]
				}
				if {$gain > $realhi} {
					set gain $realhi
				}
				set nr_top $gain
			} 
			4 {
				if {![IsNumeric $nr_top]} {
					continue
				}
				set nr_top [expr int(floor($nr_top))]
			} 
			5 {
				if {![IsNumeric $nr_top]} {
					continue
				}
				set zzz [expr int(floor($nr_top * 10.0))]
				set nr_top [DecPlaces [expr $zzz / 10.0] 1]
			} 
			6 {
				if {[info exists last_nr_top]} {
					set nr_top $last_nr_top
				}
			} 
			7 {
				set nr_top 1.0
			} 
			1 {
				set newrrrange  0
				set finished 1
			}
			0 {
				set newrrrange  -1
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $newrrrange
}

proc IncrRtop {up lo hi} {
	global nr_top
	if {![IsNumeric $nr_top]} {
		return
	}
	if {$up} {
		if {$nr_top < $hi} {
			if {$nr_top < 1} { 
				set nr_top [expr $nr_top + 0.1]
			} else {
				set nr_top [expr $nr_top + 1]
			}
			if {$nr_top > $hi} {
				set nr_top $hi
			}
		}
	} else {
		set range [expr $nr_top - $lo]
		if {$range < 0.0} {
			return
		} elseif {$range  < 0.1} { 
			set nr_top [expr $nr_top - 0.01]
		} elseif {$range  < 1} { 
			set nr_top [expr $nr_top - 0.1]
		} else {
			set nr_top [expr $nr_top - 1]
		}
		if {$nr_top < $lo} {
			set nr_top $lo
		}
	}
}


#------ User enteres number of lines in a filterdata file

proc FilterDataLineCnt {} {
	global pr_fdlc sn_fdlc wstk
	set msg "You Will Need To Enther The Number Of Lines In The Data File."
	append msg "\n\n            Have You Removed All Comment Lines ?"
	set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
	if {$choice == "no"} {
		return 0
	}
	if {[info exists sn_fdlc]} {
		set msg "Same Number Of Data Lines ($sn_fdlc)?"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			return $sn_fdlc
		}
	}
	set f .fdlc
	if [Dlg_Create $f "HOW MANY LINES OF FILTER DATA" "set pr_fdlc 0" -borderwidth 2 -width 80] {
		frame $f.0
		button $f.0.s -text "OK" -command "set pr_fdlc 1" -width 10 -highlightbackground [option get . background {}]
		button $f.0.q -text "Abandon" -command "set pr_fdlc 0" -width 10 -highlightbackground [option get . background {}]
		pack $f.0.s -side left
		pack $f.0.q -side right
		frame $f.1
		label $f.1.s -text "Number of Filter Data Lines"
		entry $f.1.e -textvariable sn_fdlc -width 16
		pack $f.1.s -side left
		pack $f.1.e -side right
		pack $f.0 -side top -fill x -expand true
		pack $f.1 -side top -fill x -expand true
		wm resizable $f 1 1
		bind $f <Escape> {set pr_fdlc 0}
		bind $f <Return> {set pr_fdlc 1}
	}
	set sn_fdlc ""
	set pr_fdlc 0
	ScreenCentre $f
	raise $f
	My_Grab 0 $f pr_fdlc $f.1.e
	set finished 0
	while {!$finished} {
		tkwait variable pr_fdlc
		if {$pr_fdlc} {
			if {![regexp {^[0-9]+$} $sn_fdlc]} {
				Inf "Invalid Value Entered = $sn_fdlc"
				continue
			}
			if {$sn_fdlc < 1} {
				Inf "Too Few Lines"
				continue
			}
			set finished 1
		} else {
			set sn_fdlc  0
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $sn_fdlc
}

################################
# SOUND VIEW DISPLAY FUNCTIONS #
################################

proc SnackOutput {time_out} {
	global sn sn_pts sn_other sn_remainder sn_rowcnt sn_peakgroupindex sn_sttwintime sn_endwintime sn_amps sn_starty evv
	global pr_snack pprg
	if {($sn(edit) != 0) || (($sn(brktype) != $evv(SN_TIMEPAIRS)) && ($sn(brktype) != $evv(SN_TIMEDIFF)) \
	&& ($sn(brktype) != $evv(SN_FRQBAND)) && ($sn(brktype) != $evv(SN_SINGLEFRQ)))} {
			lappend sn(snack_list) "CLEAR"
	}
	set sn_silence 96.0		;#	0 to -96dB amplitude range for FEATURES DISPLAY
	if {[info exists sn_rowcnt]} {
		set sn(brktype) $evv(SN_MOVETIME_ONLY2)
	}
	switch -regexp -- $sn(brktype) \
		^$evv(SN_TIMEPAIRS)$ {
			switch -regexp -- $sn(out) \
				^$evv(GRPS_OUT)$ {
					lappend sn(snack_list) "[expr $sn(startsamp) / $sn(chans)] [expr $sn(endsamp) / $sn(chans)]"
				} \
				^$evv(TIME_OUT)$ {
					lappend sn(snack_list) "[DecPlaces $sn(starttime) 6]  [DecPlaces $sn(endtime) 6]"
				} \
				^$evv(SMPS_OUT)$ {
					lappend sn(snack_list) "$sn(startsamp)  $sn(endsamp)"
				}
		} \
		^$evv(SN_TIMEDIFF)$ {
			if {$time_out} {
				set sn(snack_list) [list $sn(starttime) $sn(endtime)] 
			} else {
				set sn(snack_list) [list $sn(starttime) $sn(endtime) "dur"]
			}
		} \
		^$evv(SN_FRQBAND)$ {
			if {[info exists sn(frqboxtop)]} {
				set x [expr $sn(height) - $sn(frqboxtop)]
				set x [expr double($x) / double($sn(height))]
				set sn(frqbot) [expr $x * $sn(valsco)]
				if {$sn(frqbot) < $sn(valloreal)} {
					set sn(frqbot) $sn(valloreal)
				} elseif {$sn(frqbot) > $sn(valhireal) } {
					set sn(frqbot) $sn(valhireal) 
				}
				set x [expr $sn(height) - $sn(frqboxbot)]
				set x [expr double($x) / double($sn(height))]
				set sn(frqtop) [expr $x * $sn(valsco)]
				if {$sn(frqtop) > $sn(valhireal) } {
					set sn(frqtop) $sn(valhireal) 
				} elseif {$sn(frqtop) < $sn(valloreal)} {
					set sn(frqtop) $sn(valloreal)
				}
				lappend sn(snack_list) "[DecPlaces $sn(frqbot) 6]  [DecPlaces $sn(frqtop) 6]"
			}
		} \
		^$evv(SN_BRKPNTPAIRS)$ {
			switch -regexp -- $sn(out) \
				^$evv(GRPS_OUT)$ {
					foreach {x y} $sn(brk) {
						set y [expr $sn(height) - $y]
						set y [expr double($y) / double($sn(height))]
						set y [expr $y * $sn(valsco)]
						set y [expr $y + $sn(vallo)]
						lappend sn(snack_list) "[expr $x / $sn(chans)] $y"
					}
					set end_sssamp [expr ($sn(sampdur) / $sn(chans)) + $sn(sr_x_chs)]	;#	PUT OUT EXTRA POINT BEYOND FILE END
					lappend sn(snack_list) "$end_sssamp $y"
				} \
				^$evv(TIME_OUT)$ {
					foreach {x y} $sn(brk) {
						set y [expr $sn(height) - $y]
						set y [expr double($y) / double($sn(height))]
						set y [expr $y * $sn(valsco)]
						set y [expr $y + $sn(vallo)]
						lappend sn(snack_list) "[DecPlaces [expr double($x) * $sn(inv_srxchs)] 6] [DecPlaces $y 6]"
					}
					lappend sn(snack_list) "[DecPlaces [expr $sn(indur) + 1.0] 6] [DecPlaces $y 6]"
				} \
				^$evv(SMPS_OUT)$ {
					foreach {x y} $sn(brk) {
						set y [expr $sn(height) - $y]
						set y [expr double($y) / double($sn(height))]
						set y [expr $y * $sn(valsco)]
						set y [expr $y + $sn(vallo)]
						lappend sn(snack_list) "$x $y"
					}
					set end_sssamp [expr ($sn(sampdur) + ($sn(chans) * $sn(sr_x_chs))]
					lappend sn(snack_list) "$end_sssamp $y"
				}

		} \
		^$evv(SN_SINGLETIME)$ {
			if {[info exists sn(markout)]} {
				switch -regexp -- $sn(out) \
					^$evv(GRPS_OUT)$ {
						lappend sn(snack_list) [expr $sn(markout) / $sn(chans)]
					} \
					^$evv(TIME_OUT)$ {
						set outtime [expr double($sn(markout)) * $sn(inv_srxchs)]
						lappend sn(snack_list) [DecPlaces $outtime 6]
					} \
					^$evv(SMPS_OUT)$ {
						lappend sn(snack_list) $sn(markout)
					}
			}
		} \
		^$evv(SN_SINGLEFRQ)$ {
			if {[info exists sn(markout)]} {
				lappend sn(snack_list) [DecPlaces $sn(markout) 6]
			}
		} \
		^$evv(SN_UNSORTED_TIMES)$ - \
		^$evv(SN_TIMESLIST)$ {
			if {[info exists sn(marklist)]} {
				if {$sn(brktype) == $evv(SN_TIMESLIST)} {
					DeleteDuplMarks
					set sn(marklist) [lsort -integer $sn(marklist)]
				} else {
					DeleteAdjacentDuplMarks
				}
				if {($pprg == $evv(VFILT)) || ($pprg == $evv(FLTBANKV)) || ($pprg == $evv(SYNFILT))} {
					if {[lindex $sn(marklist) 0] != 0} {
						set sn(marklist) [concat 0 $sn(marklist)]
					}
					if {[lindex $sn(marklist) end] < $sn(sampdur)} {
						set sn(marklist) [concat $sn(marklist) $sn(sampdur)]
					}
				}
				foreach outsamp $sn(marklist) {
					switch -regexp -- $sn(out) \
						^$evv(GRPS_OUT)$ {
							lappend sn(snack_list) [expr $outsamp / $sn(chans)]
						} \
						^$evv(TIME_OUT)$ {
							set outtime [expr double($outsamp) * $sn(inv_srxchs)]
							lappend sn(snack_list) [DecPlaces $outtime 6]
						} \
						^$evv(SMPS_OUT)$ {
							lappend sn(snack_list) $outsamp
						}

				}
			}
		} \
		^$evv(SN_MOVETIME_ONLY)$ {
			if {[info exists sn(marklist)]} {
				foreach outsamp $sn(marklist) outval $sn_other {
					switch -regexp -- $sn(out) \
						^$evv(GRPS_OUT)$ {
							lappend sn(snack_list) "[expr $outsamp / $sn(chans)] $outval"
						} \
						^$evv(TIME_OUT)$ {
							set outtime [expr double($outsamp) * $sn(inv_srxchs)]
							lappend sn(snack_list) "[DecPlaces $outtime 6] $outval"
						} \
						^$evv(SMPS_OUT)$ {
							lappend sn(snack_list) "$outsamp $outval"
						}

				}
				if {[info exists sn_remainder]} {
					foreach {outtime outval} $sn_remainder {
						lappend sn(snack_list) "$outtime $outval"
					}
				}
			}
		} \
		^$evv(SN_MOVETIME_ONLY2)$ {
			if {[info exists sn(marklist)]} {
				set sn(other) $sn_other
				set sn(rowcnt) $sn_rowcnt
				set endindx $sn(rowcnt)
				incr endindx -1
				foreach outsamp $sn(marklist) {
					set outtime [expr double($outsamp) * $sn(inv_srxchs)]
					set outt [DecPlaces $outtime 6]
					set outt [concat $outt [lrange $sn(other) 0 $endindx]]
					lappend sn(snack_list) $outt
					set sn(other) [lrange $sn(other) $sn(rowcnt) end]
				}
				set endindx $sn(rowcnt)
				incr sn(rowcnt)
				if {[info exists sn_remainder]} {
					set sn(remainder) {$sn_remainder}
					while {[llength $sn(remainder)] >= $sn(rowcnt)} {
						set outt [lrange $sn(remainder) 0 $endindx]
						lappend sn(snack_list) $outt
						set sn(other) [lrange $sn(other) $sn(rowcnt) end]
					}
				}
				set kk [lsearch $sn(snack_list) "CLEAR"]
				if {$kk >= 0} {
					set sn(snack_list) [lreplace $sn(snack_list) $kk $kk]
				}
				set lenq [llength $sn(snack_list)]
				set len_less_oneq [expr $lenq - 1]
				set nn 0							;#	SORT INTO TIME-INCREASING ORDER
				while {$nn < $len_less_oneq} {
					set nitem [lindex $sn(snack_list) $nn]
					set ntime [lindex $nitem 0]
					set mm $nn
					incr mm
					while {$mm < $lenq} {
						set mitem [lindex $sn(snack_list) $mm]
						set mtime [lindex $mitem 0]
						if {$mtime < $ntime} {
							set sn(snack_list) [lreplace $sn(snack_list) $nn $nn $mitem]		
							set sn(snack_list) [lreplace $sn(snack_list) $mm $mm $nitem]
							set nitem $mitem
							set ntime $mtime
						}
						incr mm
					}
					incr nn
				}
				if {$kk >= 0} {
					set sn(snack_list) [concat "CLEAR" $sn(snack_list)]
				}
			}
		}

	if {[info exists sn_rowcnt]} {
		set sn(brktype) $evv(SN_MOVETIME_ONLY)
	}
	Inf "Data Output"
	if {$sn(do_exit)} {
		set pr_snack 0
	}
}
	
proc ShowTime {time} {
	set show ""
	if {$time >= 3600} {
		set hrs [expr int(floor($time)) / 3600]
		set time [expr $time - double($hrs * 3600)]
		append show "$hrs h: "
	}
	if {$time >= 60} {
		set mins [expr int(floor($time)) / 60]
		set time [expr $time - double($mins * 60)]
		append show "$mins m: "
	}
	set time [DecPlaces $time 4]
	append show "$time s"
	return $show
}
	
proc SnCreatePoint {x y} {
	global sn evv
	set xa [expr $x - $evv(PWIDTH)]
	set xb [expr $x + $evv(PWIDTH)]
	set ya [expr $y - $evv(PWIDTH)]
	set yb [expr $y + $evv(PWIDTH)]
	$sn(snackan) create rect $xa $ya $xb $yb -fill blue -tag point
}

proc SnCreateVal {x y} {
	global sn
	if {($x == $sn(left)) || ($x == $sn(right))} {
		return
	}
	set ya [expr $y - 10]
	if {$ya < 6} {
		set ya $y
	}
	set val [expr $sn(height) - $y]
	set val [expr double($val) / double($sn(height))]
	set range [expr $sn(valhi) - $sn(vallo)]
	set val [expr $range * $val]
	set val [expr $val + $sn(vallo)]
	if {$range > 100} {
		set val [expr round($val)]
	} elseif {$range > 10} {
		set val [DecPlaces $val 1]
	} elseif {$range > 1} {
		set val [DecPlaces $val 2]
	} elseif {$range > .1} {
		set val [DecPlaces $val 3]
	} elseif {$range > .01} {
		set val [DecPlaces $val 4]
	} elseif {$range > .001} {
		set val [DecPlaces $val 5]
	}
	$sn(snackan) create text $x $ya -text $val -fill blue -tags "val val$x"
	set ya [expr $y + 10]
	if {$ya > [expr $sn(height) - 6]} {
		set ya $y
	}
	set val [expr double($x) / double($sn(width))]
	set range [expr $sn(dispend) - $sn(dispstart)]
	set trange [expr $range * $sn(inv_srxchs)]
	set val [expr $range * $val]
	set val [expr $val + $sn(dispstart)]
	set val [expr $val * $sn(inv_srxchs)]
	if {$trange > 100} {
		set val [expr round($val)]
	} elseif {$trange > 10} {
		set val [DecPlaces $val 1]
	} elseif {$trange > 1} {
		set val [DecPlaces $val 2]
	} elseif {$trange > .1} {
		set val [DecPlaces $val 3]
	} elseif {$trange > .01} {
		set val [DecPlaces $val 4]
	} elseif {$trange > .001} {
		set val [DecPlaces $val 5]
	}
	$sn(snackan) create text $x $ya -text $val -fill red -tags "val val$x"
}

proc SnRemoveVal {x} {
	global sn
	catch [$sn(snackan) delete val$x] in
}

proc SnHideVals {hide} {
	global sn
	if {$hide == -1} {
		catch {$sn(snackan) delete val} in
		return
	}
	if {$hide} {
		catch {$sn(snackan) delete val} in
		.snack.f6.1.zs config -text "SHOW VALUES" -bd 2 -command "SnHideVals 0"
		set sn(hidden) 1
	} else {
		foreach {x y} $sn(brk_disp) {
			SnCreateVal $x $y
		}
		.snack.f6.1.zs config -text "HIDE VALUES" -bd 2 -command "SnHideVals 1"
		set sn(hidden) 0
	}
}

proc SnPointAdd {x y} {
	global sn
	if {[info exists sn(frqzoom)] && ($sn(frqzoom) > 0)} {
		return
	}
	if {$x < $sn(left)} {
		set x $sn(left)
	} elseif {$x > $sn(right)} {
		set x $sn(right)
	}
	if {$y < 0} {
		set y 0
	} elseif {$y > $sn(height)} {
		set y $sn(height)
	}
	set sttindx -1
	set endindx 0
	set nu {}
	set cnt 0
	foreach {xa ya} $sn(brk_disp) {
		if {$x == $xa} {
			return
		} elseif {$x > $xa} {
			incr sttindx 2
			incr endindx 2
			incr cnt
		} else {
			break
		}
	}
	set sn(localindx) $cnt
	if {$sttindx > 0} {
		set nu [lrange $sn(brk_disp) 0 $sttindx]
	}
	lappend nu $x $y
	if {$endindx < $sn(localcnt)} {
		set nu [concat $nu [lrange $sn(brk_disp) $endindx end]]
	}
	set sn(brk_disp) $nu
	incr sn(localcnt) 2
	incr sn(endx) 2
	SnCreatePoint $x $y
	SnCreateVal $x $y
	SnPointSet add
	SnDrawLine
}

proc SnPointDel {x y} {
	global sn evv
	set obj [GetClosest $x $y point]
	if {$obj < 0} {
		return
	}
	set coords [$sn(snackan) coords $obj]
	set x [expr round([lindex $coords 0])]
	incr x $evv(PWIDTH)
	SnRemoveVal $x
	set indx [FindPointInList $x]
	set sn(localindx) [expr $indx / 2] 
	if {$indx < 0} {
		return
	} elseif {($indx == 0) && $sn(atzero)} {
		return
	} elseif {($indx == $sn(endx)) && $sn(atend)} {
		return
	}
	RemovePointFromList $indx
	SnPointSet delete
	catch {$sn(snackan) delete $obj} in
	SnDrawLine
}

proc SnPointMark {x y} {
	global sn evv
	set sn(marked) 0
	set sn(obj) [GetClosest $x $y point]
	if {$sn(obj) < 0} {
		return
	}
	set coords [$sn(snackan) coords $sn(obj)]
	set sn(x) [expr round([lindex $coords 0])]
	incr sn(x) $evv(PWIDTH)
	SnRemoveVal $sn(x)
	set sn(y) [expr round([lindex $coords 1])]
	incr sn(y) $evv(PWIDTH)
	set sn(mx) $x
	set sn(my) $y
	set sn(lastx) $sn(x)
	set sn(lasty) $sn(y)
	set sn(indx) [FindPointInList $sn(x)]
	set sn(localindx) [expr $sn(indx) / 2]
	if {$sn(drag)} {	;# MOVE TIME
		if {$sn(indx) < 0} {
			return
		} elseif {($sn(indx) == 0) && $sn(atzero)} {
			return
		} elseif {($sn(indx) == $sn(endx)) && $sn(atend)} {
			return
		}
		if {![FindMotionLimits]} {
			return
		}
	} else {
		incr sn(indx)
	}
	set sn(marked) 1
}

proc SnPointDrag {x y} {
	global sn
	if {!$sn(marked)} {
		return
	}
	if {$sn(drag)} { ;# MOVE TIME
		set mx $x
		set dx [expr $mx - $sn(mx)]
		incr sn(x) $dx
		if {$sn(x) > $sn(rightstop)} {
			set sn(x) $sn(rightstop)
			set dx [expr $sn(x) - $sn(lastx)]
		} elseif {$sn(x) < $sn(leftstop)} {
			set sn(x) $sn(leftstop)
			set dx [expr $sn(x) - $sn(lastx)]
		}
		set sn(lastx) $sn(x)
		$sn(snackan) move $sn(obj) $dx 0
		set sn(mx) $mx
		set x [expr round($sn(x))]
		set sn(brk_disp) [lreplace $sn(brk_disp) $sn(indx) $sn(indx) $x]
	} else {
		set my $y
		set dy [expr $my - $sn(my)]
		incr sn(y) $dy
		if {$sn(y) > $sn(height)} {
			set sn(y) $sn(height)
			set dy [expr $sn(y) - $sn(lasty)]
		} elseif {$sn(y) < 0} {
			set sn(y) 0
			set dy [expr $sn(y) - $sn(lasty)]
		}
		set sn(lasty) $sn(y)
		$sn(snackan) move $sn(obj) 0 $dy
		set sn(my) $my
		set y [expr round($sn(y))]
		set sn(brk_disp) [lreplace $sn(brk_disp) $sn(indx) $sn(indx) $y]
	}
	SnDrawLine
}

proc SnValSet {} {
	global sn evv
	set coords [$sn(snackan) coords $sn(obj)]
	if {[llength $coords] >= 2} {
		set x [expr round([lindex $coords 0])]
		set y [lindex $coords 1]
		incr x $evv(PWIDTH)
		SnCreateVal $x $y
	}
}

proc SnPointSet {act} {
	global sn 
	if {![info exists sn(localindx)]} {
		return					;#	'localindx' is position in local_brk of point added, deleted or moved
	}
	if {[info exists sn(brk_local)] && ([llength $sn(brk_local)] > 0)} {
		set len [llength $sn(brk_local)]
		incr len -2
		set start [lindex $sn(brk_local) 0]		;#	Total brkpnt set reconstructed from brk_local and all non-local points
		set thend [lindex $sn(brk_local) $len]
	} else {
		set start $sn(startsamp)
		set thend $sn(endsamp)
	}

	switch -- $act {			;#	SnPointSet modified so only changes added, deleted or moved point: all others unaffected
		"add" {
			set cnt 0
			set localbrkindx 0
			foreach {x y} $sn(brk_disp) {
				if {$cnt == $sn(localindx)} {
					set g [expr int(round(($x - $sn(left)) * $sn(timescale)))]
					incr g $sn(dispstart)
					lappend nuvals $g $y
				} else {
					lappend nuvals [lindex $sn(brk_local) $localbrkindx]
					incr localbrkindx
					lappend nuvals [lindex $sn(brk_local) $localbrkindx]
					incr localbrkindx
				}
				incr cnt
			}
		}
		"delete" {
			set cnt 0
			foreach {x y} $sn(brk_local) {
				if {$cnt != $sn(localindx)} {
					lappend nuvals $x $y
				}
				incr cnt
			}
		}
		"move" {
			set cnt 0
			foreach {x y} $sn(brk_local) {xa ya} $sn(brk_disp) {
				if {$cnt == $sn(localindx)} {
					set g [expr int(round(($xa - $sn(left)) * $sn(timescale)))]
					incr g $sn(dispstart)
					lappend nuvals $g $ya
				} else {
					lappend nuvals $x $y
				}
				incr cnt
			}
		}
	}
	if {![info exists nuvals]} {
		set sn(localcnt) 0
	} else {
		set sn(brk_local) $nuvals
		set sn(localcnt) [llength $sn(brk_local)]
	}
	switch -- $sn(localcnt) {
		0 {
			set sn(atcanstart) 0
			set sn(atcanend) 0
		}
		2 {
			if {[lindex $sn(brk_disp) 0] <= $sn(left)} {
				set sn(atcanstart) 1
			} else {
				set sn(atcanstart) 0
			}
			if {[lindex $sn(brk_disp) 0] >= $sn(right)} {
				set sn(atcanend) 1
			} else {
				set sn(atcanend) 0
			}
		}
		default {
			if {[lindex $sn(brk_disp) 0] <= $sn(left)} {
				set sn(atcanstart) 1
			} else {
				set sn(atcanstart) 0
			}
			if {[lindex $sn(brk_disp) $sn(endx)] >= $sn(right)} {
				set sn(atcanend) 1
			} else {
				set sn(atcanend) 0
			}
		}
	}
	set nuvals {}
	set gotend 0
	catch {unset sn(previous)}
	catch {unset sn(next)}
	set indx 0
	if {([lindex $sn(brk_local) 0] == 0)  && ([lindex $sn(brk_local) [expr [llength $sn(brk_local)] - 2]] == $sn(sampdur))} {
		set sn(brk) $sn(brk_local)
		set sn(marked) 0
		return
	}
	switch -- $sn(localcnt) {
		0 {
			foreach {x y} $sn(brk) {
				if {$x < $sn(dispstart)} {
					lappend nuvals $x $y
					set sn(previous) [list $x $y]
				} elseif {$x > $sn(dispend)} {
					set nuvals [concat $nuvals [lrange $sn(brk) $indx end]]
					set sn(next) [list $x $y]
					set gotend 1
					break
				}
				incr indx 2
			}
		}
		default {
			foreach {x y} $sn(brk) {
				if {$x < $start} {
					lappend nuvals $x $y
					set sn(previous) [list $x $y]
				} elseif {$x > $thend} {
					set nuvals [concat $nuvals $sn(brk_local) [lrange $sn(brk) $indx end]]
					set sn(next) [list $x $y]
					set gotend 1
					break
				}
				incr indx 2
			}
		}
	}
	if {!$gotend} {
		set nuvals [concat $nuvals $sn(brk_local)]
		set sn(next) [list $x $y]
	}
	set sn(brk) $nuvals
	set sn(marked) 0
}

proc FindPointInList {xa} {
	global sn
	set timindex 0
	foreach {x y} $sn(brk_disp) {
		if [string match $x $xa] {
			return $timindex
		}
		incr timindex 2
	}
	return -1
}

proc RemovePointFromList {timindex} {
	global sn
	set valindex $timindex
	incr valindex
	set sn(brk_disp) [lreplace $sn(brk_disp) $timindex $valindex]
	incr sn(localcnt) -2
	incr sn(endx) -2
}

proc SnDrawUnityLine {} {
	global sn
	set coords [list $sn(left) $sn(starty) $sn(right) $sn(starty)]
	$sn(snackan) create line $coords -fill blue -tag line
}
	
proc SnDrawLine {} {
	global sn
	set coords {}
	if {$sn(localcnt) <= 0} {
		if {![info exists sn(previous)] || ![info exists sn(next)]} {
			return
		}
		set prevtime [lindex $sn(previous) 0]
		set prevval  [lindex $sn(previous) 1]
		set nexttime [lindex $sn(next) 0]
		set nextval  [lindex $sn(next) 1]
		set longstep [expr double($nexttime - $prevtime)]
		set ystep [expr $nextval - $prevval]
		set ratio [expr double($sn(dispstart) - $prevtime) / $longstep]
		set yval [expr int(round($ystep * $ratio)) + $prevval]
		set coords [list $sn(left) $yval]
		set ratio [expr double($sn(dispend) - $prevtime) / $longstep]
		set yval [expr int(round($ystep * $ratio)) + $prevval]
		set coords [concat $coords $sn(right) $yval]
	} else {
		if {!$sn(atcanstart)} {
			if [info exists sn(previous)] {
				set brkstart [lindex $sn(brk_local) 0]
				set brkval   [lindex $sn(brk_local) 1]
				set prevtime [lindex $sn(previous) 0]
				set prevval  [lindex $sn(previous) 1]
				set ratio 1.0
				if {$brkstart != $prevtime} {
					set ratio [expr double($sn(dispstart) - $prevtime) / double($brkstart - $prevtime)]
				}
				set ystep [expr $brkval - $prevval]
				set yval [expr int(round($ystep * $ratio)) + $prevval]
				set coords [list $sn(left) $yval]
			}
		}
		set coords [concat $coords $sn(brk_disp)]
		if {!$sn(atcanend)} {
			if [info exists sn(next)] {
				set endindx $sn(endx)
				set canend  $sn(dispend)
				set brkend  [lindex $sn(brk_local) $endindx]
				incr endindx
				set brkval   [lindex $sn(brk_local) $endindx]
				set nexttime [lindex $sn(next) 0]
				set nextval  [lindex $sn(next) 1]
				if {$nexttime == $brkend} {
					set yval $brkval
				} else {
					set ratio [expr double($canend - $brkend) / double($nexttime - $brkend)]
					set ystep [expr $nextval - $brkval]
					set yval [expr int(round($ystep * $ratio)) + $brkval]
				}
				set coords [concat $coords $sn(right) $yval]
			}
		}
	}
	catch {$sn(snackan) delete line}
	$sn(snackan) create line $coords -fill blue -tag line
}

proc FindMotionLimits {} {
	global sn
	if {$sn(indx) == 0} {
		set sn(leftstop) $sn(left)
		if {$sn(localcnt) == 2} {
			set sn(rightstop) $sn(right)
		} else {
			set sn(rightstop) [lindex $sn(brk_disp) [expr $sn(indx) + 2]]
			incr sn(rightstop) -1
		}
	} elseif {$sn(indx) == $sn(endx)} {
		set sn(rightstop) $sn(right)
		if {$sn(localcnt) == 2} {
			set sn(leftstop) $sn(left)
		} else {
			set sn(leftstop) [lindex $sn(brk_disp) [expr $sn(indx) - 2]]
			incr sn(leftstop)
		}
	} else {
		set sn(leftstop) [lindex $sn(brk_disp) [expr $sn(indx) - 2]]
		incr sn(leftstop)
		set sn(rightstop) [lindex $sn(brk_disp) [expr $sn(indx) + 2]]
		incr sn(rightstop) -1
	}
	if {$sn(leftstop) >= $sn(rightstop)} {
		return 0
	}
	return 1
}

proc ForceVal {e val} {
	set origstate [$e cget -state]
	$e config -state normal
	$e delete 0 end
	$e insert 0 $val
	$e xview moveto 1.0
	$e config -state $origstate
}

proc SetValQuantiseSV {} {
	global sn
	set sn(quant) val
}

proc SetTimeQuantiseSV {} {
	global sn
	set sn(quant) time
}

proc SetQuantiseRestore {} {
	global sn
	set sn(quant) baktrak
}

proc SetTimeQuantiseOffSV {} {
	ForceVal .snack.f7.0.te Off
}

proc SetValQuantiseOffSV {} {
	ForceVal .snack.f7.0.ve Off
}

proc DoQuant {quantisation} {
	global sn
	if {![info exists sn(quant)]} {
		return
	}
	switch -- $sn(quant) {
		"time" {
			set orig_qtime $sn(qtime)
			set sn(qtime) $quantisation
			if {$sn(qtime) >= $sn(indur)} {
				Inf "Impossible quantisation value"
				set sn(qtime) $orig_qtime
				ForceVal .snack.f7.0.te $sn(qtime)
				return
			}
			if {$orig_qtime != $sn(qtime)} {
				ForceVal .snack.f7.0.te $sn(qtime)
				SnackZoom 2
				set sn(origbrk) $sn(brk)
				set len [llength $sn(brk)]
				incr len -2
				set lasttime [lindex $sn(brk) $len]
				foreach {time val} $sn(brk) {
					set time [QuantiseT $time $sn(qtime) 0.0 $sn(indur)]
					lappend new_c $time $val
				}
				set new_c [lreplace $new_c $len $len $lasttime]
			}
			set sn(lastquant) $sn(quant)
			set sn(lastqtime) $orig_qtime
		}
		"val" {
			set orig_qval  $sn(qval)
			set sn(qval) $quantisation
			if {($sn(qval) > $sn(valhi)) && ($sn(qval) > [expr abs($sn(vallo))])} {
				Inf "Impossible quantisation value"
				set sn(qval) $orig_qval
				ForceVal .snack.f7.0.ve $sn(qval)
				return
			}
			if {$orig_qval != $sn(qval)} {
				ForceVal .snack.f7.0.ve $sn(qval)
				SnackZoom 2
				set sn(origbrk) $sn(brk)
				foreach {time val} $sn(brk) {
					set val [QuantiseV $val $sn(qval)]
					lappend new_c $time $val
				}
			}
			set sn(lastquant) $sn(quant)
			set sn(lastqval) $orig_qval
		}
		"baktrak" {
			if {![info exists sn(origbrk)]} {
				return
			}
			set new_c $sn(origbrk)
			unset sn(origbrk)
			switch -- $sn(lastquant) {
				"time" {
					set sn(qtime) $sn(lastqtime)
					ForceVal .snack.f7.0.te $sn(qtime)
				}
				"val" {
					set sn(qval) $sn(lastqval)
					ForceVal .snack.f7.0.ve $sn(qval)
				}
			}
		}
		default {
			return
		}
	}
	if {![info exists new_c]} {
		Inf "Use Value Off: Value On, To Reset Quantisation Value"
		return
	}
	set sn(brk) $new_c
	catch {$sn(snackan) delete point}
	catch {$sn(snackan) delete line}
	catch {$sn(snackan) delete val}
	catch {unset sn(brk_local)}
	catch {unset sn(brk_disp)}
	foreach {x y} $sn(brk) {
		if {$x >= $sn(dispstart)} {
			if {$x <= $sn(dispend)} {
				lappend sn(brk_local) $x $y
				incr sn(localcnt) 2
			} else {
				set sn(next) [list $x $y]
				break
			}
		} else {
			set sn(previous) [list $x $y]
		}
	}
	if {[info exists sn(brk_local)]} {
		foreach {x y} $sn(brk_local) {
			set xa [expr $x - $sn(dispstart)]
			set xa [expr double($xa) / double($sn(displen))]
			set xa [expr int(round($xa * $sn(width)))]
			incr xa $sn(left)
			lappend sn(brk_disp) $xa $y
		}
		foreach {x y} $sn(brk_disp) {
			SnCreatePoint $x $y
			if {!$sn(hidden)} {
				SnCreateVal $x $y
			}
		}
		SnDrawLine
	}
}

proc QuantiseV {val q} {
	global sn
	set val [expr $sn(height) - $val]
	set val [expr double($val) / double($sn(height))]
	set val [expr $val * $sn(valsco)]
	set val [expr $val + $sn(vallo)]

	set z [expr round($val / $q)]
	set val [expr $z * $q]
	if {$val <= $sn(vallo)} {
		set val $sn(vallo)
	} 
	if {$val >= $sn(valhi)} {
		set val $sn(valhi)
	} 
	set val [expr double($val) - double($sn(vallo))]
	set val [expr $val / double($sn(valsco))]
	set val [expr $val * double($sn(height))]
	set val [expr $sn(height) - $val]
	return $val
}

proc QuantiseT {val q lo hi} {
	global sn
	set val [expr double($val) * $sn(inv_srxchs)]
	set z [expr round($val / $q)]
	set val [expr $z * $q]
	if {$val <= $lo} {
		set val $lo
	}
	if {$val >= $hi} {
		set val $hi
	}
	set val [expr int(round(double($val) * double($sn(sr_x_chs))))]
	return $val
}

proc SnMark {x y} {
	global sn 
	if {[info exists sn(frqzoom)] && ($sn(frqzoom) > 0)} {
		return
	}
	if {($x < $sn(left)) || ($x > $sn(right))} {
		return
	}
	catch {$sn(snackan) delete mark}
	catch {unset sn(markthis)}
	catch {unset sn(markx)}
	catch {unset sn(markout)}
	set wratio [expr double($x - $sn(left)) / double($sn(width))]
	set outsamp [expr int(round(double($sn(displen)) * $wratio))]
	set outsamp [expr $sn(dispstart) + $outsamp]
	set sn(markout) [expr ($outsamp / $sn(chans)) * $sn(chans)]
	set sn(markx) $x
	set sn(markthis) [eval {$sn(snackan) create line} {$x $sn(height) $x 0 -tag mark -fill blue}]
}

proc SnMarkF {x y} {
	global sn
	if {!$sn(spectrum)} {
		return
	}
	if {[info exists sn(frqzoom)] && $sn(frqzoom)} {
		return
	}
	if {($y < 0) || ($y > $sn(height))} {
		return
	}
	catch {$sn(snackan) delete mark}
	catch {unset sn(markthis)}
	catch {unset sn(markout)}
	set sn(marky) $y
	set ya [expr $sn(height) - $y]
	set ya [expr double($ya) / double($sn(height))]
	set sn(markout) [expr $ya * $sn(valsco)]
	if {$sn(markout) < $sn(valloreal)} {
		set sn(markout) $sn(valloreal)
	}
	set sn(marky) $y
	set sn(markthis) [eval {$sn(snackan) create line} {$sn(left) $y $sn(right) $y -tag mark -fill red}]
}

proc SnFrqBoxBegin {x y} {
	global sn
	if {[info exists sn(frqzoom)] && ($sn(frqzoom) > 0)} {
		return
	}
	if {[info exists sn(frqboxheight)] && ($y < $sn(frqboxheight))} {
		return
	}
	catch {unset sn(frqboxdrag)}
	DelSnFrqBox
	set sn(frqboxanchor) [list $sn(left) $y]
	set sn(frqboxthis) [eval {$sn(snackan) create rect} $sn(frqboxanchor) {$sn(right) $y -tag frqbox -outline red -stipple gray12}]
}

proc DelSnFrqBox {} {
	global sn
	catch {$sn(snackan) delete $sn(frqboxthis)}
	catch {$sn(snackan) delete frqbox}
	catch {unset sn(frqboxthis)}
	catch {unset sn(frqboxtop)}
	catch {unset sn(frqboxbot)}
}

proc SnFrqBoxDrag {x y} {
	global sn
	if {[info exists sn(frqzoom)] && ($sn(frqzoom) > 0)} {
		return
	}
	if {![info exists sn(frqboxanchor)]} {
		return
	}
	if [info exists sn(frqboxheight)] {
		set thisfoot $sn(frqboxheight)
	} else {
		set thisfoot 0
	}
	if {($y <= $sn(height)) && ($y >= $thisfoot)} {
		catch {$sn(snackan) delete $sn(frqboxthis)}
		set sn(frqboxthis) [eval {$sn(snackan) create rect} $sn(frqboxanchor) {$sn(right) $y -tag frqbox -outline red -stipple gray12}]
		set sn(frqboxtop) $y
	}
	set sn(frqboxdrag) 1
}

proc SnFrqBoxSet {} {
	global sn evv
	if {$sn(brktype) == $evv(SN_FROM_FOFCNSTR_NO_OUTPUT)} {
		if {$sn(foffeatures)} {
			return
		}
}
	if {[info exists sn(boxdrag)]} {
		SnBoxSet
		return
	}
	if {[info exists sn(frqzoom)] && ($sn(frqzoom) > 0)} {
		return
	}
	if {![info exists sn(frqboxdrag)]} {
		return
	}
	set sn(frqboxbot) [lindex $sn(frqboxanchor) 1]
	if {$sn(frqboxtop) < $sn(frqboxbot)} {
	    set temp $sn(frqboxbot)
	    set sn(frqboxbot) $sn(frqboxtop)
		set sn(frqboxanchor) [lreplace $sn(frqboxanchor) 1 1 $sn(frqboxbot)]
	    set sn(frqboxtop) $temp
	}
	if {$sn(frqboxbot) < 0} {
		set sn(frqboxbot) 0
	}
	if {$sn(frqboxtop) > $sn(height)} {
		set sn(frqboxtop) $sn(height)
	}
	if {$sn(frqboxbot) == $sn(frqboxtop)} {
		DelSnFrqBox
		unset sn(frqboxdrag)
		return
	}
	catch {$sn(snackan) delete $sn(frqboxthis)}
	set sn(frqboxthis) [eval {$sn(snackan) create rect} $sn(frqboxanchor) {$sn(right) $sn(frqboxtop) -tag frqbox -outline red -stipple gray12}]
	unset sn(frqboxdrag)
}	

proc SnMarkDel {x y} {
	global sn
	if {![info exists sn(marklist)]} {
		return
	}
	set obj [GetClosest $x $y mark]
	if {$obj < 0} {
		return
	}
	catch {$sn(snackan) delete $obj} in

	set wratio [expr double($x - $sn(left)) / double($sn(width))]
	set x [expr int(round(double($sn(displen)) * $wratio))]
	set x [expr $sn(dispstart) + $x]
	set x [expr ($x / $sn(chans)) * $sn(chans)]

	set mindiff [expr $sn(sampdur) + 10]
	set cnt 0
	foreach xx $sn(marklist) {
		set diff [expr abs($xx - $x)]
		if {$diff < $mindiff} {
			set mindiff $diff
			set item $cnt
		}
		incr cnt
	}
	if {[info exists item]} {
		set sn(marklist) [lreplace $sn(marklist) $item $item]
	}
}

proc DeleteDuplMarks {} {
	global sn
	set len [llength $sn(marklist)] 
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set n_mark [lindex $sn(marklist) $n]
		set m $n
		incr m
		while {$m < $len} {
			set m_mark [lindex $sn(marklist) $m]
			if {$n_mark == $m_mark} {
				set sn(marklist) [lreplace $sn(marklist) $m $m]
				incr m -1
				incr len -1
				incr len_less_one -1
			}
			incr m
		}
		incr n
	}
}

proc SnLastMarkDel {x y} {
	global sn
	if {![info exists sn(marklist)]} {
		return
	}
	set x [lindex $sn(marklist) end]

	if {($x >= $sn(dispstart)) && ($x <= $sn(dispend))} {
		set wratio [expr double($x - $sn(dispstart)) / double($sn(displen))]
		set x [expr int(round(double($sn(width)) * $wratio))]
		incr x $sn(left)
		set obj [GetClosest $x 0 mark]
		if {$obj < 0} {
			return
		}
		catch {$sn(snackan) delete $obj} in
	}
	set sn(marklist) [lreplace $sn(marklist) end end]	
	if {[llength $sn(marklist)] > 0} {
		set sn(markthis) [lindex $sn(marklist) end]	
	} else {
		catch {unset sn(markthis)}
	}
}

proc DeleteAdjacentDuplMarks {} {
	global sn
	set len [llength $sn(marklist)] 
	set len_less_one [expr $len - 1]
	set n 0
	while {$n < $len_less_one} {
		set n_mark [lindex $sn(marklist) $n]
		set m $n
		incr m
		set k $m
		incr k
		while {($m < $k) && ($m < $len)} {
			set m_mark [lindex $sn(marklist) $m]
			if {$n_mark == $m_mark} {
				set sn(marklist) [lreplace $sn(marklist) $m $m]
				incr m -1
				incr len -1
				incr len_less_one -1
			}
			incr m
		}
		incr n
	}
}

proc SnMarkMark {x y} {
	global sn
	set sn(marked) 0
	set sn(obj) [GetClosest $x $y mark]
	if {$sn(obj) < 0} {
		return
	}
	set coords [$sn(snackan) coords $sn(obj)]
	set sn(x) [expr round([lindex $coords 0])]
	set sn(mx) $x
	set sn(lastx) $sn(x)
	set sn(indx) [FindMarkInList $sn(x)]
	if {$sn(indx) < 0} {
		return
	}
	if {![FindMarkMotionLimits]} {
		return
	}
	set sn(marked) 1
}

proc SnMarkDrag {x y} {
	global sn
	if {!$sn(marked)} {
		return
	}
	set mx $x
	set dx [expr $mx - $sn(mx)]
	incr sn(x) $dx
	if {$sn(x) > $sn(rightstop)} {
		set sn(x) $sn(rightstop)
		set dx [expr $sn(x) - $sn(lastx)]
	} elseif {$sn(x) < $sn(leftstop)} {
		set sn(x) $sn(leftstop)
		set dx [expr $sn(x) - $sn(lastx)]
	}
	set sn(lastx) $sn(x)
	$sn(snackan) move $sn(obj) $dx 0
	set sn(mx) $mx
	set x [expr round($sn(x))]
	set sn(marks_disp) [lreplace $sn(marks_disp) $sn(indx) $sn(indx) $x]
}

proc SnMarkSet {} {
	global sn
	foreach x $sn(marks_disp) {
		set g [expr int(round(($x - $sn(left)) * $sn(timescale)))]
		incr g $sn(dispstart)
		lappend nuvals $g
	}
	set sn(marks_local) $nuvals
	set nuvals {}
	set k [expr  $sn(marks_start) - 1]
	if {$k >= 0} {
		set nuvals [lrange $sn(marklist) 0 $k]
	}
	set nuvals [concat $nuvals $sn(marks_local)]
	set k [expr $sn(marks_start) + $sn(marks_locallen)]
	if {$k < $sn(marks_total)} {
		set nuvals [concat $nuvals [lrange $sn(marklist) $k end]]
	}
	set sn(marklist) $nuvals
}

proc FindMarkInList {xa} {
	global sn
	if {![info exists sn(marks_disp)]} {
		return -1
	}
	set pos -1
	set timindex 0
	set mindist [expr $sn(width) + 10]
	foreach x $sn(marks_disp) {
		set thisdist [expr abs($x - $xa)]
		if {$thisdist < $mindist} {
			set pos $timindex
			set mindist $thisdist
		}
		incr timindex
	}
	return $pos
}	

proc FindMarkMotionLimits {} {
	global sn
	set endd [expr $sn(marks_locallen) - 1]
	if {$sn(indx) == 0} {
		set sn(leftstop) $sn(left)
		set nextindx $sn(indx)
		incr nextindx
		if {$nextindx >= $sn(marks_locallen)} {
			set sn(rightstop) $sn(right)
		} else {
			set sn(rightstop) [lindex $sn(marks_disp) $nextindx]
			incr sn(rightstop) -1
		}
	} elseif {$sn(indx) == $endd} {
		set sn(rightstop) $sn(right)
		set lastindx $sn(indx)
		incr lastindx -1
		if {$lastindx < 0} {
			set sn(leftstop) $sn(left)
		} else {
			set sn(leftstop) [lindex $sn(marks_disp) $lastindx]
			incr sn(leftstop)
		}
	} else {
		set nextindx $sn(indx)
		incr nextindx
		if {$nextindx >= $sn(marks_locallen)} {
			set sn(rightstop) $sn(right)
		} else {
			set sn(rightstop) [lindex $sn(marks_disp) $nextindx]
			incr sn(rightstop) -1
		}
		set lastindx $sn(indx)
		incr lastindx -1
		if {$lastindx < 0} {
			set sn(leftstop) $sn(left)
		} else {
			set sn(leftstop) [lindex $sn(marks_disp) $lastindx]
			incr sn(leftstop)
		}
	}
	if {$sn(leftstop) >= $sn(rightstop)} {
		return 0
	}
	return 1
}

proc SnMarks {x y} {
	global sn
	if {[info exists sn(frqzoom)] && ($sn(frqzoom) > 0)} {
		return
	}
	if {($x < $sn(left)) || ($x > $sn(right))} {
		return
	}
	set xx $x
	set sn(markthis) [eval {$sn(snackan) create line} {$x $sn(height) $x 0 -tag mark -fill blue}]
	set wratio [expr double($xx - $sn(left)) / double($sn(width))]
	set x [expr int(round(double($sn(displen)) * $wratio))]
	set outsamp [expr $sn(dispstart) + $x]
	set outsamp [expr ($outsamp / $sn(chans)) * $sn(chans)]
	lappend sn(marklist) $outsamp
}

proc DelAllMarks {} {
	global sn
	catch {$sn(snackan) delete mark}
	catch {unset sn(marklist)}
}

proc SnackZoom {in} {
	global sn snx evv sn_troflist segment
	catch {$sn(snackan) delete pm}
	catch {s stop}
	if {[info exists sn(lastbox_startsamp)]} {
		UnsetLastBox
	}
	if {$in == 1} {
		if {$sn(displen) <= $sn(width)} {
			return
		} elseif {[info exists sn(boxlen)] && ($sn(boxlen) <= $sn(width))} {
			if {$sn(displen) <= $sn(width)} {
				return
			}
		}
		catch {$sn(snackan) delete val}
	} else {
		if {$sn(displen) >= $sn(sampdur)} {
			return
		}
		catch {$sn(snackan) delete val}
		if {[info exists sn(boxthis)]} {
			set oldboxstart $sn(startsamp)
			if {$sn(brktype) == $evv(SN_FROM_FOFCNSTR_NO_OUTPUT)} {
				if {$sn(foffeatures)} {
					set oldboxend [expr $oldboxstart + $sn(fofunitlen)]
				} else {
					set oldboxend $sn(endsamp)
				}
			} else {
				set oldboxend $sn(endsamp)
			}
		} else {
			set oldboxstart $sn(dispstart)
			set oldboxend $sn(dispend)
		}
	}
	if {$sn(brktype) == $evv(SN_FROM_FOFCNSTR_NO_OUTPUT)} {
		set sn(foffeatures) 0
	}
	if {[info exists sn(marklist)]} {
		catch {$sn(snackan) delete mark}
		catch {unset sn(markout)}
		catch {unset sn(markthis)}
		catch {unset sn(markx)}
	}
	set centre [expr $sn(displen) / 2]
	set centre [expr ($centre / $sn(chans)) * $sn(chans)]
	set centre [expr $centre + $sn(startsamp)]
	if {$in == 1} {
		if {[info exists sn(boxthis)] && [info exists sn(boxlen)]} {
			set len $sn(boxlen)
			set centre [expr $len / 2]
			set centre [expr ($centre / $sn(chans)) * $sn(chans)]
			set centre [expr $centre + $sn(startsamp)]
			if {$len <= $sn(width)} {
				set len $sn(width)
				if {$sn(brktype) == $evv(SN_FROM_FOFCNSTR_NO_OUTPUT)} {
					set sn(foffeatures) 1
					DelSnBox 0
				} else {
					set oldboxstart $sn(startsamp)
					set oldboxend $sn(endsamp)
				}
			} else {
				DelSnBox 0
			}
		} else {
			set len [expr $sn(displen) / 4]
			set len [expr ($len / ($sn(chans) * 2)) * ($sn(chans) * 2)]
			if {$len <= $sn(width)} {
				set len $sn(width)
				if {$sn(brktype) == $evv(SN_FROM_FOFCNSTR_NO_OUTPUT)} {
					set sn(foffeatures) 1
				}
			}
		}
	} elseif {$in == 2} {
		set len $sn(sampdur)
		set centre [expr $sn(sampdur) / 2]
		set centre [expr ($centre / $sn(chans)) * $sn(chans)]
	} else {
		set len [expr $sn(dispend) - $sn(dispstart)]
		set centre [expr $len / 2]
		set centre [expr ($centre / $sn(chans)) * $sn(chans)]
		set centre [expr $centre + $sn(dispstart)]
		set len [expr $len * 4]
		set len [expr ($len / ($sn(chans) * 2)) * ($sn(chans) * 2)]
		if {$len >= $sn(sampdur)} {
			set len $sn(sampdur)
			set centre [expr $sn(sampdur) / 2]
			set centre [expr ($centre / $sn(chans)) * $sn(chans)]
		}
	}
	set start [expr $centre - ($len/2)]
	if {$start < 0} {
		set thisstart 0
	} else {
		set thisstart $start
	}
	if {$sn(brktype) == $evv(SN_FROM_FOFCNSTR_NO_OUTPUT)} {
		if {$sn(foffeatures)} {
			set xx [expr int(round(double($thisstart) / double($sn(fofunitlen))))]
			if {$xx < 1} {
				set xx 1
			}
			set thisstart [expr $xx * $sn(fofunitlen)]
			set sn(fofno) $xx 
		} else {
			set sn(fofno) ""
		}
	}
	set thisend [expr $thisstart + $len]
	if {$thisend > $sn(sampdur)} {
		set thisend $sn(sampdur)
		set thisstart [expr $thisend - $len]
	}
	set sn(dispstart) $thisstart
	set sn(dispend) $thisend
	set thisstarttime [expr double($sn(dispstart)) * $sn(inv_srxchs)]
	set thisendtime   [expr double($sn(dispend))   * $sn(inv_srxchs)]
	set len [expr $thisendtime - $thisstarttime]
	set sn(pixpersec) [expr double($sn(width))/$len]
	set sn(displen) [expr $sn(dispend) - $sn(dispstart)]
	catch {$sn(snackan) delete wave}
	if {[info exists oldboxstart]} {
		catch {$sn(snackan) delete $sn(boxthis)}
		catch {$sn(snackan) delete box}
		catch {unset sn(boxthis)}
	} else {
		set sn(startsamp) $sn(dispstart)
		set sn(endsamp)   $sn(dispend)
		set sn(gpstartsamp) [expr $sn(startsamp) / $sn(chans)]
		set sn(gpendsamp)   [expr $sn(endsamp) / $sn(chans)]
		set sn(starttime) $thisstarttime
		set sn(endtime)   $thisendtime
		set sn(starttime_shown) [ShowTime $sn(starttime)]
		set sn(endtime_shown)   [ShowTime $sn(endtime)]
		set sn(dur) [ShowTime [expr $sn(endtime) - $sn(starttime)]]
		if {$sn(windows) } {
			set sn(startwin) [expr int(round($thisstarttime / $sn(frametime)))]
			set sn(endwin)  [expr int(round($thisendtime / $sn(frametime)))]
		}
	}
	if {$sn(spectrum)} {
		SnSpectrogram
		.snack.f6.1.zs config -text "ZOOM SPECTRUM" -bd 2 -command "SnackSpecZoom 1"
		.snack.f6.1.sf config -text "SEE FRQ SCALE" -bd 2 -command "SnackSpecScale 1"
		if {$sn(brktype) == $evv(SN_FEATURES_PEAKS)} {
			.snack.f6.outp config -text "SEE LEVEL SCALE" -bd 2 -command "SnackVolScale 1"
		}
	} else {
		SnackSpecZoom 0
		$sn(snackan) create waveform 0 0 -sound s -height $sn(height) -pixelspersecond $sn(pixpersec) -start [expr $sn(dispstart) / $sn(chans)] -tag wave
		catch {$sn(snackan) delete pm}
		$sn(snackan) create poly -1 -1 -1 -1 -1 -1 -fill red -tags pm
		if {$sn(brktype) == $evv(SN_BRKPNTPAIRS)} {
			.snack.f6.1.sf config -text "SEE VAL SCALE" -bd 2 -command "SnackScale 1"
			if {$sn(hidden)} {
				.snack.f6.1.zs config -text "SHOW VALUES" -bd 2 -command {SnHideVals 0}
			} else {
				.snack.f6.1.zs config -text "HIDE VALUES" -bd 2 -command {SnHideVals 1}
			}
		} elseif {$sn(brktype) != $evv(SN_FROM_FOFCNSTR_NO_OUTPUT)} {
			.snack.f6.1.sf config -text "" -bd 0 -command {}
			.snack.f6.1.zs config -text "" -bd 0 -command {}
		}
	}
	if {$sn(brktype) == $evv(SN_FROM_FOFCNSTR_NO_OUTPUT)} {
		if {$sn(foffeatures)} {
			set oldboxstart [expr int(round(double($thisstart) / double($sn(fofunitlen)))) * $sn(fofunitlen)]
			set oldboxend [expr $oldboxstart + $sn(fofunitlen)]
		}
	}
	if {[info exists oldboxstart]} {
		set k [expr double($oldboxstart - $sn(dispstart))]
		set k [expr $k / double($sn(displen))]
		set k [expr int(round($k * $sn(width)))]
		set k [expr ($k / $sn(chans)) * $sn(chans)]
		set sn(boxanchor) [list $k $sn(height)]
		set k [expr double($oldboxend - $sn(dispstart))]
		set k [expr $k / double($sn(displen))]
		set k [expr int(round($k * $sn(width)))]
		set sn(boxend) [expr ($k / $sn(chans)) * $sn(chans)]
		set sn(boxthis) [eval {$sn(snackan) create rect} $sn(boxanchor) {$sn(boxend) 0 -tag box -outline blue -stipple gray12}]
		if {$in != 1} {
			set sn(boxlen) [expr $sn(endsamp) - $sn(startsamp)]
		}
		if {$sn(brktype) == $evv(SN_FROM_FOFCNSTR_NO_OUTPUT)} {
			if {$sn(foffeatures)} {
				set sn(boxlen) $sn(fofunitlen)
			}
			set sn(startsamp) [expr $oldboxstart]
			set sn(endsamp) [expr $oldboxstart + $sn(fofunitlen)]
		}
	}
	switch -regexp -- $sn(brktype) \
		^$evv(SN_BRKPNTPAIRS)$ {
			set sn(brk_local) {}
			set sn(brk_disp) {}
			set sn(localcnt) 0
			foreach {x y} $sn(brk) {
				if {$x >= $sn(dispstart)} {
					if {$x <= $sn(dispend)} {
						lappend sn(brk_local) $x $y
						incr sn(localcnt) 2
					} else {
						set sn(next) [list $x $y]
						break
					}
				} else {
					set sn(previous) [list $x $y]
				}
			}
			set sn(endx) [expr $sn(localcnt) - 2]
			set sn(atzero) 0
			set sn(atend) 0
			set sn(atcanstart) 0
			set sn(atcanend) 0
			if {$sn(localcnt) > 0} {
				if {[lindex $sn(brk_local) 0] == $sn(dispstart)} {
					if {$sn(dispstart) <= 0} {
						set sn(atzero) 1
					}
					set sn(atcanstart) 1
				}
				if {[lindex $sn(brk_local) $sn(endx)] == $sn(dispend)} {
					if {$sn(dispend) >= $sn(sampdur)} {
						set sn(atend) 1
					}
					set sn(atcanend) 1
				}
				foreach {x y} $sn(brk_local) {
					set xa [expr $x - $sn(dispstart)]
					set xa [expr double($xa) / double($sn(displen))]
					set xa [expr int(round($xa * $sn(width)))]
					incr xa $sn(left)
					lappend sn(brk_disp) $xa $y
				}
			}
			set sn(timescale) [expr double($sn(displen)) / double($sn(width))]
			catch {$sn(snackan) delete point}
			foreach {x y} $sn(brk_disp) {
				SnCreatePoint $x $y
				if {!$sn(hidden)} {
					SnCreateVal $x $y
				}
			}
			SnDrawLine
			if {[info exists sn_troflist]} {
				if {[info exists snx(marklist)]} {
					$sn(snackan) delete mark
					catch {unset snx(markthis)}
					foreach x $snx(marklist) {
						if {($x >= $sn(dispstart)) && ($x <= $sn(dispend))} {
							set wratio [expr double($x - $sn(dispstart)) / double($sn(displen))]
							set x [expr int(round(double($sn(width)) * $wratio))]
							incr x $sn(left)
							set snx(markthis) [eval {$sn(snackan) create line} {$x $sn(height) $x 0 -tag mark -fill red}]
						}
					}
				}
			}
		} \
		^$evv(SN_FRQBAND)$ {
			if {$sn(spectrum) && [info exists sn(frqboxthis)]} {
				catch {$sn(snackan) delete frqbox}
				if {[info exists sn(frqboxtop)]} {
					set sn(frqboxthis) [eval {$sn(snackan) create rect} $sn(frqboxanchor) {$sn(right) $sn(frqboxtop) -tag frqbox -outline red -stipple gray12}]
				}
			}
		} \
		^$evv(SN_SINGLETIME)$ {
			if {[info exists sn(markout)]} {
				$sn(snackan) delete mark
				catch {unset sn(markthis)}
				catch {unset sn(markx)}
				if {($sn(markout) >= $sn(dispstart)) && ($sn(markout) <= $sn(dispend))} {
					set wratio [expr double($sn(markout) - $sn(dispstart)) / double($sn(displen))]
					set x [expr int(round(double($sn(width)) * $wratio))]
					incr x $sn(left)
					set sn(markx) $x
					set sn(markthis) [eval {$sn(snackan) create line} {$x $sn(height) $x 0 -tag mark -fill blue}]
				}
			}
		} \
		^$evv(SN_SINGLEFRQ)$ {
			if {[info exists sn(markout)]} {
				$sn(snackan) delete mark
				set sn(markthis) [eval {$sn(snackan) create line} {$sn(left) $sn(marky) $sn(right) $sn(marky) -tag mark -fill red}]
			}
		} \
		^$evv(SN_TIMESLIST)$	 - \
		^$evv(SN_UNSORTED_TIMES)$ {
			if {[info exists sn(marklist)]} {
				$sn(snackan) delete mark
				catch {unset sn(markthis)}
				set h_cnt 0
				set i_cnt 0
				if {[info exists segment(displaysegs)]} {
					set txt_top 14												;#	Offset text from top of display
					set h_h $txt_top
				}
				foreach x $sn(marklist) {
					if {($x >= $sn(dispstart)) && ($x <= $sn(dispend))} {
						set wratio [expr double($x - $sn(dispstart)) / double($sn(displen))]
						set x [expr int(round(double($sn(width)) * $wratio))]
						incr x $sn(left)
						set sn(markthis) [eval {$sn(snackan) create line} {$x $sn(height) $x 0 -tag mark -fill blue}]
						if {[info exists segment(displaysegs)]} {
							if {[info exists segment(intext)]} {				;#	Use mnemonic, if it exists
								set t_xt [lindex $segment(intext) $i_cnt]		;#	else use number
							} else {
								set t_xt [expr $i_cnt + 1]
							}
							set x [expr $x + 0.5]
							$sn(snackan) create text $x $h_h -text $t_xt -font bigfntbold -fill darkred -anchor w -tag mark
							incr h_cnt
							if {[expr $h_cnt % 5] == 0} {						;#	Texts staggered, downwards, until we reach 5th item
								set h_h $txt_top 
							} else {
								set h_h [expr $h_h + 14]
							}
						}
					}
					incr i_cnt
				}
			}
		} \
		^$evv(SN_MOVETIME_ONLY)$ {
			if {[info exists sn(marklist)]} {
				$sn(snackan) delete mark
				catch {unset sn(marks_local)}
				catch {unset sn(marks_disp)}
				catch {unset sn(markthis)}
				set cntt 0
				set sn(marks_start) -1
				set sn(timescale) [expr double($sn(displen)) / double($sn(width))]
				foreach x $sn(marklist) {
					if {($x >= $sn(dispstart)) && ($x <= $sn(dispend))} {
						if {$sn(marks_start) < 0} {
							set sn(marks_start) $cntt
						}
						lappend sn(marks_local) $x
						set wratio [expr double($x - $sn(dispstart)) / double($sn(displen))]
						set x [expr int(round(double($sn(width)) * $wratio))]
						incr x $sn(left)
						lappend sn(marks_disp) $x
						set sn(markthis) [eval {$sn(snackan) create line} {$x $sn(height) $x 0 -tag mark -fill blue}]
					}
					incr cntt
				}
				if {[info exists sn(marks_local)]} {
					set sn(marks_locallen) [llength $sn(marks_local)]
				} else {
					set sn(marks_locallen) 0
				}
			}
		} \
		^$evv(SN_FEATURES_PEAKS)$ {
			if {$sn(spectrum)} {
				if {[info exists sn(feature_0)]} {
					$sn(snackan) delete feature
					set n 0
					while {$n < $sn(peakgroupindex)} {
						foreach {time freq color} $sn(feature_$n) {
							if {($time < $sn(dispstart)) || ($time > $sn(dispend))} {
								continue
							}
							set ratio [expr double($time - $sn(dispstart)) / double($sn(displen))]
							set x [expr int(round($ratio * $sn(width))) + $sn(left)]
							set ratio [expr double($freq) / $sn(topfrequency)]
							set y [expr int(round($ratio * double($sn(height))))]
							set y [expr $sn(height) - $y]
							set xa [expr $x - $evv(PWIDTH)]
							set xb [expr $x + $evv(PWIDTH)]
							set ya [expr $y - $evv(PWIDTH)]
							set yb [expr $y + $evv(PWIDTH)]
							$sn(snackan) create rect $xa $ya $xb $yb -fill magenta$color -tag feature
						}
						incr n
					}
					$sn(snackan) delete amp
					set time $sn(sttwintime)
					set started_line 0
					set dispdur [expr $sn(endtime) - $sn(starttime)]
					foreach amp $sn(amps) {
						if {($time < $sn(starttime)) || ($time > $sn(endtime))} {
							set time [expr $time + $sn(frametime)]
							continue
						}
						set ratio [expr ($time - $sn(starttime)) / $dispdur]
						set x [expr int(round($ratio * $sn(width))) + $sn(left)]
						set y [expr int(round($amp * double($sn(height))))]
						set y [expr $sn(height) -  $y]
						if {$started_line} {
							$sn(snackan) create line $lastx $lasty $x $y -fill red -tag amp
						}
						set	lastx $x
						set	lasty $y
						set started_line 1
						set time [expr $time + $sn(frametime)]
					}
				}
			} else {
				$sn(snackan) delete feature
				$sn(snackan) delete amp
			}
		}
}

proc SnackPlay {} {
	global sn sndcardfault
	if {[info exists sndcardfault]} {
		Inf "Playing sounds is temporarily impossible"
		return
	}
	if {[info exists sn(boxlen)]} {
		set sn(playdur) [expr $sn(endsamp) - $sn(startsamp)]
		set ratio [expr double($sn(playdur)) / double($sn(displen))]
		set sn(playdur) [expr double($sn(playdur)) * $sn(inv_srxchs)]
		set sn(playwidth) [expr int(round($sn(width) * $ratio))]
		set sn(playstart) [lindex $sn(boxanchor) 0]
	} else {
		set sn(playdur) [expr double($sn(displen)) * $sn(inv_srxchs)]
		set sn(playwidth) $sn(width)
		set sn(playstart) $sn(left)
	}
	s play -start $sn(gpstartsamp) -end $sn(gpendsamp)  -command StopPlayMarker
    after 0 PutPlayMarker 
}

proc SnackPlayStop {} {
	global sn sndcardfault
	if {[info exists sndcardfault]} {
		Inf "Playing sounds is temporarily impossible"
		return
	}
	if {[info exists sn(playing)]} {
		catch {unset sn(playing)}
		s stop
	} else {
		set sn(playing) 1
		SnackPlay
	}
}

proc PutPlayMarker {} {
    global sn
    set x [expr ($sn(playwidth) / $sn(playdur) * [audio elapsed]) + $sn(playstart)]
    set y [expr $sn(height) - 5]
    catch {$sn(snackan) coords pm [expr $x-5] $y $x [expr $y-10] [expr $x+5] $y}
    after 50 PutPlayMarker
}

proc StopPlayMarker {} { 
    after cancel PutPlayMarker 
} 

proc DecPlaces {val places} {
	set val [string trim $val]
	if {$places < 1} {
		return $val
	}
	set ppos [string first "." $val]
	if {$ppos < 0} {
		return $val
	}
	if {[string first "e-" $val] >= 0} {	;# very small values uses exponential representation
		set val "0."
		set n 0
		while {$n < $places} {	
			append val "0"
			incr n
		} 
		return $val
	}
	incr ppos -1
	set predec [string range $val 0 $ppos]
	if {$predec < 0} {
		set isneg 1
		set predec [string range $predec 1 end]
	}
	incr ppos 2
	if {$ppos >= [string length $val]} {
		return $val
	}
	set postdec [string range $val $ppos end]
	set postdeclen [string length $postdec]
	if {$postdeclen <= $places} {
		return $val
	}
	incr ppos $places
	set postdig [string index $val $ppos]
	set postdec [string range $postdec 0 [expr $places - 1]]
	if {$postdig >= 5} {
		set truelen [string length $postdec]
		set true_postdec $postdec
		set postdec [StripLeadingZeros $postdec]
		if {[string length $postdec] <= 0} {
			set postdec $true_postdec
		} else {
			set nozerolen [string length $postdec]
			set leading_zeros [expr $truelen - $nozerolen]
			incr postdec
			set post_nozerolen [string length $postdec]
			if {$post_nozerolen > $nozerolen} {
				incr leading_zeros -1
			}
			set q ""
			while {$leading_zeros > 0} {
				 append q 0
				 incr leading_zeros -1
			}
			append q $postdec
			set postdec $q
			if {[string length $postdec] > $places} {
				set postdec [string range $postdec 1 end]
				incr predec
			}
		}
	}
	set val ""
	if {[info exists isneg]} {
		append val "-"
	}
	append val $predec
	append val "."
	append val $postdec
	return $val
}

proc DecPlacesTrunc {val places} {
	set val [string trim $val]
	if {$places < 1} {
		return $val
	}
	set ppos [string first "." $val]
	if {$ppos < 0} {
		return $val
	}
	if {[string first "e-" $val] >= 0} {	;# very small values uses exponential representation
		set val "0."
		set n 0
		while {$n < $places} {	
			append val "0"
			incr n
		} 
		return $val
	}
	incr ppos -1
	set predec [string range $val 0 $ppos]
	incr ppos 2
	if {$ppos >= [string length $val]} {
		return $val
	}
	set postdec [string range $val $ppos end]
	set postdeclen [string length $postdec]
	if {$postdeclen <= $places} {
		return $val
	}
	set postdec [string range $postdec 0 [expr $places - 1]]
	set val $predec
	append val "."
	append val $postdec
	return $val
}

proc StripLeadingZeros {str} {
	set isneg 0
	if {[string match [string index $str 0] "-"]} {
		set isneg 1
		set str [string range $str 1 end]
	}
	if {$str == 0.0} {
		return 0
	}
	set len [string length $str]
	set cnt 0
	while {$cnt < $len} {
		if {![string match [string index $str $cnt] 0]} {
			break
		}
		incr cnt
	}
	set str [string range $str $cnt end]
	if {$isneg} {
		set nstr "-"
		append nstr $str
		set str $nstr
	}
	return $str
}	

proc SnBoxBegin {x y} {
	global sn evv
	if {$sn(brktype) == $evv(SN_FROM_FOFCNSTR_NO_OUTPUT)} {
		if {$sn(foffeatures)} {
			return
		}
	}
	UnsetLastBox
	catch {unset sn(boxdrag)}
	set sn(done) 0
	DelSnBox 0
	set sn(boxanchor) [list $x $sn(height)]
	set sn(boxthis) [eval {$sn(snackan) create rect} $sn(boxanchor) {$x 0 -tag box -outline blue -stipple gray12}]
}

proc GetClosest {x y z} {
	global sn
	set mindist $sn(width)
	incr mindist $sn(width)
	set displaylist [$sn(snackan) find withtag $z]
	if {![info exists displaylist] || ([llength $displaylist] <= 0)} {
		return -1
	}
	foreach obj $displaylist {
		set coords [$sn(snackan) coords $obj]
		set objx [expr round([lindex $coords 0])]
		set thisdist [expr abs($x - $objx)]
		if {$thisdist < $mindist} {
			set mindist $thisdist
			set closest_obj $obj
			set objy [expr round([lindex $coords 1])]
			set thatydist [expr abs($y - $objy)]
		} elseif {$thisdist == $mindist} {
			if {[info exists thisydist]} {
				set objy [expr round([lindex $coords 1])]
				set thisydist [expr abs($y - $objy)]
				if {$thisydist < $thatydist} {
					set thatydist $thisydist
					set closest_obj $obj
				}
			}
		} else {
			catch {unset thisydist}
		}
	}
	return $closest_obj
}

proc DelSnBox {recall} {
	global sn
	if {$recall && [info exists sn(boxthis)] && [info exists sn(boxlen)]} {
		set sn(lastbox_start)    [lindex $sn(boxanchor) 0]
		set sn(lastbox_end)       $sn(boxend)
		set sn(lastbox_startsamp) $sn(startsamp)
		set sn(lastbox_endsamp)   $sn(endsamp)
		set sn(lastbox_starttime) $sn(starttime)
		set sn(lastbox_endtime)   $sn(endtime)
		set sn(lastboxlen)		  $sn(boxlen)
	}
	set sn(startsamp) $sn(dispstart)
	set sn(endsamp) $sn(dispend)
	set sn(gpstartsamp) [expr $sn(startsamp) / $sn(chans)]
	set sn(gpendsamp)   [expr $sn(endsamp) / $sn(chans)]
	set sn(starttime) [expr double($sn(startsamp)) * $sn(inv_srxchs)]
	set sn(endtime)   [expr double($sn(endsamp))   * $sn(inv_srxchs)]
	if {$sn(windows) } {
		set sn(startwin) [expr int(round($sn(starttime) / $sn(frametime)))]
		set sn(endwin)  [expr int(round($sn(endtime) / $sn(frametime)))]
	}
	set sn(starttime_shown) [ShowTime $sn(starttime)]
	set sn(endtime_shown)   [ShowTime $sn(endtime)]
	set sn(dur) [ShowTime [expr $sn(endtime) - $sn(starttime)]]
	catch {$sn(snackan) delete $sn(boxthis)}
	catch {$sn(snackan) delete box}
	catch {unset sn(boxlen)}
	catch {unset sn(boxthis)}
}

proc RestoreSnBox {} {
	global sn
	if {[info exists sn(lastbox_startsamp)]} {
		set sn(boxanchor) [list $sn(lastbox_start) $sn(height)]
		set sn(boxend)		$sn(lastbox_end)
		set sn(startsamp)	$sn(lastbox_startsamp)
		set sn(endsamp)		$sn(lastbox_endsamp)
		set sn(gpstartsamp)	[expr $sn(startsamp) / $sn(chans)]
		set sn(gpendsamp)	[expr $sn(endsamp) / $sn(chans)]
		set sn(starttime)	$sn(lastbox_starttime)
		set sn(endtime)		$sn(lastbox_endtime)
		if {$sn(windows) } {
			set sn(startwin) [expr int(round($sn(starttime) / $sn(frametime)))]
			set sn(endwin)  [expr int(round($sn(endtime) / $sn(frametime)))]
		}
		set sn(boxlen)		$sn(lastboxlen)
		set sn(boxthis) [eval {$sn(snackan) create rect} $sn(boxanchor) {$sn(boxend) 0 -tag box -outline blue -stipple gray12}]
		UnsetLastBox
	}
}

proc UnsetLastBox {} {
	global sn
	catch {unset sn(lastbox_start)}
	catch {unset sn(lastbox_end)}
	catch {unset sn(lastbox_startsamp)}
	catch {unset sn(lastbox_endsamp)}
	catch {unset sn(lastbox_starttime)}
	catch {unset sn(lastbox_endtime)}
	catch {unset sn(lastboxlen)}
}

proc UnsetBox {} {
	global sn
	catch {unset sn(boxlen)}
	catch {unset sn(boxthis)}
	catch {unset sn(boxanchor)}
	catch {unset sn(boxend)}
	catch {unset sn(boxdrag)}
}

proc SnBoxDrag {x y} {
	global sn evv
	if {$sn(brktype) == $evv(SN_FROM_FOFCNSTR_NO_OUTPUT)} {
		if {$sn(foffeatures)} {
			return
		}
	}
	if {![info exists sn(boxanchor)] || $sn(done)} {
		return
	}
	if {($x >= $sn(left)) && ($x <= $sn(right))} {
		catch {$sn(snackan) delete $sn(boxthis)}
		set sn(boxthis) [eval {$sn(snackan) create rect} $sn(boxanchor) {$x 0 -tag box -outline blue -stipple gray12}]
	} else {
		set sn(done) 1
	}
	set sn(boxend) $x
	set sn(boxdrag) 1
	if {$sn(done)} {
		SnBoxSet	
	}
}

proc SnBoxExtend {x y inv} {
	global sn
	if {![info exists sn(boxanchor)] || [info exists sn(lastboxlen)]} {
		return
	}
	if {$inv} {
		if {$x < [lindex $sn(boxanchor) 0] || ($x > $sn(boxend))} {
			return
		}
	}
	if {($x < $sn(left)) || ($x > $sn(right))} {
		return
	}
	if {$x < [lindex $sn(boxanchor) 0]} {
		set sn(boxanchor) [lreplace $sn(boxanchor) 0 0 $x]
	} elseif {$x > $sn(boxend)} {
		set sn(boxend) $x
	} else {
		set box_start [lindex $sn(boxanchor) 0]
		set left [expr $box_start - $x]
		if {$left < 0} {
			set left [expr -$left]
		}
		set right [expr $sn(boxend) - $x]
		if {$right < 0} {
			set right [expr -$right]
		}
		if {$inv} {
			if {$left < $right} {
				set sn(boxend) $x
			} else {
				set sn(boxanchor) [lreplace $sn(boxanchor) 0 0 $x]
			}
		} else {
			if {$left < $right} {
				set sn(boxanchor) [lreplace $sn(boxanchor) 0 0 $x]
			} else {
				set sn(boxend) $x
			}
		}
	}
	set sn(boxdrag) 1
}

proc SnBoxSet {} {
	global sn evv
	if {$sn(brktype) == $evv(SN_FROM_FOFCNSTR_NO_OUTPUT)} {
		if {$sn(foffeatures)} {
			return
		}
	}
	if {![info exists sn(boxdrag)]} {
			if {$sn(marked)} {
				SnPointSet move
		}
		return
	}
	if {$sn(boxend) < $sn(left)} {
		set sn(boxend) $sn(left)
	} elseif {$sn(boxend) > $sn(right)} {
		set sn(boxend) $sn(right)
	}
	set stt [lindex $sn(boxanchor) 0]
	if {$sn(boxend) < $stt} {
	    set temp $stt
	    set stt $sn(boxend)
		set sn(boxanchor) [lreplace $sn(boxanchor) 0 0 $stt ]
	    set sn(boxend) $temp
	}
	if {$stt < $sn(left)} {
		set stt $sn(left)
	}
	if {$sn(boxend) > $sn(right)} {
		set sn(boxend) $sn(right)
	}
	if {$sn(boxend) == $stt} {
		DelSnBox 0
		unset sn(boxdrag)
		return
	}
	catch {$sn(snackan) delete $sn(boxthis)}
	set sn(boxthis) [eval {$sn(snackan) create rect} $sn(boxanchor) {$sn(boxend) 0 -tag box -outline blue -stipple gray12}]
	set wratio [expr double($stt - $sn(left)) / double($sn(width))]
	set x [expr int(round(double($sn(displen)) * $wratio))]
	set x [expr ($x / $sn(chans)) * $sn(chans)]
	set sn(startsamp) [expr $sn(dispstart) + $x]
	set wratio [expr double($sn(boxend) - $sn(left)) / double($sn(width))]
	set x [expr int(round(double($sn(displen)) * $wratio))]
	set x [expr ($x / $sn(chans)) * $sn(chans)]
	set sn(endsamp) [expr $sn(dispstart) + $x]
	set sn(gpstartsamp) [expr $sn(startsamp) / $sn(chans)]
	set sn(gpendsamp) [expr $sn(endsamp) / $sn(chans)]
	set sn(starttime) [expr double($sn(startsamp)) * $sn(inv_srxchs)]
	set sn(endtime)   [expr double($sn(endsamp))   * $sn(inv_srxchs)]
	if {$sn(windows) } {
		set sn(startwin) [expr int(round($sn(starttime) / $sn(frametime)))]
		set sn(endwin)  [expr int(round($sn(endtime) / $sn(frametime)))]
	}
	set sn(starttime_shown) [ShowTime $sn(starttime)]
	set sn(endtime_shown)   [ShowTime $sn(endtime)]
	set sn(dur) [ShowTime [expr $sn(endtime) - $sn(starttime)]]
	set sn(boxlen) [expr $sn(endsamp) - $sn(startsamp)]
	unset sn(boxdrag)
}	

proc SnSpectrum {spectrum} {
	global big_snack sn evv  bigspech smallspech
	$sn(snackan) delete wave 
	if {$spectrum} {
		DelSnMarkers
#RWD was 600!
		set sn(height) $bigspech
		$sn(snackan) config -height $sn(height)
		SnSpectrogram
		.snack.f6.1.zs config -text "ZOOM SPECTRUM" -bd 2 -command "SnackSpecZoom 1"
		if {[info exists sn(frqscale)] && $sn(frqscale)} {
			SnackSpecScale 1
			.snack.f6.1.sf config -text "HIDE SCALE" -bd 2 -command {SnackSpecScale 0}
		} else {
			SnackSpecScale 0
			.snack.f6.1.sf config -text "SEE FRQ SCALE" -bd 2 -command {SnackSpecScale 1}
		}
		if {$sn(brktype) == $evv(SN_FEATURES_PEAKS)} {
			if {[info exists sn(volscale)] && $sn(volscale)} {
				SnackVolScale 1
				.snack.f6.outp config -text "HIDE LEVEL SCALE" -bd 2 -command {SnackVolScale 0}
			} else {
				SnackVolScale 0
				.snack.f6.outp config -text "SEE LEVEL SCALE" -bd 2 -command {SnackVolScale 1}
			}
		}
	} else {
		if {[info exists sn(frqscale)]} {
			SnackSpecScale 2
		}
		if {$sn(brktype) == $evv(SN_FEATURES_PEAKS)} {
			if {[info exists sn(volscale)]} {
				SnackVolScale 2
			}
		}
		SnackSpecZoom 0
		DelSnMarkers
		catch {$sn(snackan) delete feature}
		catch {$sn(snackan) delete amp}
		if {$big_snack} {
#RWD also here was 600
			set sn(height) $bigspech
		} else {
			set sn(height) $smallspech
		}
		$sn(snackan) config -height $sn(height)
		$sn(snackan) create waveform 0 0 -sound s -height $sn(height) -pixelspersecond $sn(pixpersec) -start [expr $sn(dispstart) / $sn(chans)] -tag wave
		catch {$sn(snackan) delete pm}
		$sn(snackan) create poly -1 -1 -1 -1 -1 -1 -fill red -tags pm
		.snack.f6.1.zs config -text "" -bd 0 -command {}
		if {$sn(brktype) == $evv(SN_BRKPNTPAIRS)} {
			if {[info exists sn(scale)] && $sn(scale)} {
				SnackScale 1
				.snack.f6.1.sf config -text "HIDE SCALE" -bd 2 -command {SnackScale 0}
			} else {
				SnackScale 0
				.snack.f6.1.sf config -text "SEE VAL SCALE" -bd 2 -command {SnackScale 1}
			}
			if {$sn(hidden)} {
				SnHideVals 1
				.snack.f6.1.zs config -text "SHOW VALUES" -bd 2 -command {SnHideVals 0}
			} else {
				SnHideVals 0
				.snack.f6.1.zs config -text "HIDE VALUES" -bd 2 -command {SnHideVals 1}
			}
		}
	}
	RestoreSnMarkers 0
}	

proc DelSnMarkers {} {
	global sn
	if {[info exists sn(boxthis)]} {
		catch {$sn(snackan) delete box}
		set sn(restorebox) 1
	}
	if {[info exists sn(feature_0)]} {
		catch {$sn(snackan) delete feature}
		catch {$sn(snackan) delete amp}
		set sn(restore) features
	} elseif {[info exists sn(marklist)]} {
		catch {$sn(snackan) delete mark}
		set sn(restore) marks
	} elseif {[info exists sn(markx)]} {
		catch {$sn(snackan) delete mark}
		set sn(restore) markx
	} elseif {[info exists sn(marky)]} {
		catch {$sn(snackan) delete mark}
		set sn(restore) marky
	} elseif {[info exists sn(brk_disp)]} {
		catch {$sn(snackan) delete point}
		catch {$sn(snackan) delete line}
		set sn(restore) brk
	} elseif {[info exists sn(frqboxthis)]} {
		catch {$sn(snackan) delete frqbox}
		set sn(restore) frq
	}
}

proc RestoreSnMarkers {frqzoom} {
	global sn evv
	if {[info exists sn(restorebox)]} {
		if {!$frqzoom} {
			if {$sn(spectrum)} {
				set y [expr int([lindex $sn(boxanchor) 1])]
				incr y $y
				set sn(boxanchor) [lreplace $sn(boxanchor) 1 1 $y]
			} else {
				set y [lindex $sn(boxanchor) 1]
				set y [expr $y / 2]
				set sn(boxanchor) [lreplace $sn(boxanchor) 1 1 $y]
			}
		}
		set sn(boxthis) [eval {$sn(snackan) create rect} $sn(boxanchor) {$sn(boxend) 0 -tag box -outline blue -stipple gray12}]
		unset sn(restorebox)
	}
	if {[info exists sn(restore)]} {
		switch -- $sn(restore) {
			"frq" {
				if {$sn(spectrum) && [info exists sn(frqboxtop)]} {
					set sn(frqboxthis) [eval {$sn(snackan) create rect} $sn(frqboxanchor) {$sn(right) $sn(frqboxtop) -tag frqbox -outline red -stipple gray12}]
				}
			}
			"markx" {
				set sn(markthis) [eval {$sn(snackan) create line} {$sn(markx) $sn(height) $sn(markx) 0 -tag mark -fill blue}]
			}
			"marky" {
				if {$sn(spectrum)} {
					set sn(markthis) [eval {$sn(snackan) create line} {$sn(left) $sn(marky) $sn(right) $sn(marky) -tag mark -fill red}]
				}
			}
			"marks" {
				catch {unset sn(markthis)}
				foreach x $sn(marklist) {
					if {($x >= $sn(dispstart)) && ($x <= $sn(dispend))} {
						set wratio [expr double($x - $sn(dispstart)) / double($sn(displen))]
						set x [expr int(round(double($sn(width)) * $wratio))]
						incr x $sn(left)
						set sn(markthis) [eval {$sn(snackan) create line} {$x $sn(height) $x 0 -tag mark -fill blue}]
					}
				}
			}
			"features" {
				if {$sn(spectrum)} {
					set n 0
					while {$n < $sn(peakgroupindex)} {
						foreach {time freq color} $sn(feature_$n) {
							if {($time < $sn(dispstart)) || ($time > $sn(dispend))} {
								continue
							}
							set ratio [expr double($time - $sn(dispstart)) / double($sn(displen))]
							set x [expr int(round($ratio * $sn(width))) + $sn(left)]
							set ratio [expr double($freq) / $sn(topfrequency)]
							set y [expr int(round($ratio * double($sn(height))))]
							set y [expr $sn(height) - $y]
							set xa [expr $x - $evv(PWIDTH)]
							set xb [expr $x + $evv(PWIDTH)]
							set ya [expr $y - $evv(PWIDTH)]
							set yb [expr $y + $evv(PWIDTH)]
							$sn(snackan) create rect $xa $ya $xb $yb -fill magenta$color -tag feature
						}
						incr n
					}
					set time $sn(sttwintime)
					set started_line 0
					set dispdur [expr $sn(endtime) - $sn(starttime)]
					foreach amp $sn(amps) {
						if {($time < $sn(starttime)) || ($time > $sn(endtime))} {
							set time [expr $time + $sn(frametime)]
							continue
						}
						set ratio [expr ($time - $sn(starttime)) / $dispdur]
						set x [expr int(round($ratio * $sn(width))) + $sn(left)]
						set y [expr int(round($amp * double($sn(height))))]
						set y [expr $sn(height) -  $y]
						if {$started_line} {
							$sn(snackan) create line $lastx $lasty $x $y -fill red -tag amp
						}
						set	lastx $x
						set	lasty $y
						set started_line 1
						set time [expr $time + $sn(frametime)]
					}
				}
			}
			"brk" {
				if {!$frqzoom} {
					foreach {x y} $sn(brk) {
						if {$sn(spectrum)} {
							set y [expr $y + int($y)]
						} else {
							set y [expr $y / 2]
						}
						lappend nubrk $x $y
					}
					set sn(brk) $nubrk
					catch {unset nubrk}			
					foreach {x y} $sn(brk_local) {
						if {$sn(spectrum)} {
							set y [expr $y + int($y)]
						} else {
							set y [expr $y / 2]
						}
						lappend nubrk $x $y
					}
					set sn(brk_local) $nubrk
					catch {unset nubrk}			
					foreach {x y} $sn(brk_disp) {
						if {$sn(spectrum)} {
							set y [expr $y + int($y)]
						} else {
							set y [expr $y / 2]
						}
						lappend nubrk $x $y
					}
					set sn(brk_disp) $nubrk
					if {[info exists sn(previous)]} {				
						set y [lindex $sn(previous) 1]
						if {$sn(spectrum)} {
							set y [expr $y + int($y)]
						} else {
							set y [expr $y / 2]
						}
						set sn(previous) [lreplace $sn(previous) 1 1 $y]
					}
					if {[info exists sn(next)]} {				
						set y [lindex $sn(next) 1]
						if {$sn(spectrum)} {
							set y [expr $y + int($y)]
						} else {
							set y [expr $y / 2]
						}
						set sn(next) [lreplace $sn(next) 1 1 $y]
					}
				}
				SnHideVals -1
				foreach {x y} $sn(brk_disp) {
					SnCreatePoint $x $y
					if {!$sn(hidden)} {
						SnCreateVal $x $y
					}
				}
				SnDrawLine
			}
		}
		unset sn(restore)
	}
}
	
proc SnSpectrogram {} {
	global sn evv
	switch -- $sn(frqzoom) {
		0 {
			$sn(snackan) create spectrogram 0 0 -sound s -height $sn(height) -pixelspersecond $sn(pixpersec) -start [expr $sn(dispstart) / $sn(chans)] -tag wave \
	 			-fftlength $sn(mlen) -topfrequency $sn(nyquist) -winlength $sn(mlen)
 			set sn(topfrequency) $sn(nyquist)
		}
		1 {
			$sn(snackan) create spectrogram 0 0 -sound s -height $sn(height) -pixelspersecond $sn(pixpersec) -start [expr $sn(dispstart) / $sn(chans)] -tag wave \
				-fftlength $sn(mlen) -topfrequency $evv(SN_SPEECHTOP) -winlength $sn(mlen)
 			set sn(topfrequency) $evv(SN_SPEECHTOP)
		}
		2 {
			$sn(snackan) create spectrogram 0 0 -sound s -height $sn(height) -pixelspersecond $sn(pixpersec) -start [expr $sn(dispstart) / $sn(chans)] -tag wave \
				-fftlength $sn(mlen) -topfrequency $evv(SN_FORMTOP) -winlength $sn(mlen)
 			set sn(topfrequency) $evv(SN_FORMTOP)
		}
	}
	catch {$sn(snackan) delete pm}
	$sn(snackan) create poly -1 -1 -1 -1 -1 -1 -fill red -tags pm
	if {[info exists sn(frqscale)] && $sn(frqscale)} {
		SnackSpecScale 1
	} else {
		SnackSpecScale 0
	}
	if {$sn(brktype) == $evv(SN_FEATURES_PEAKS)} {
		if {[info exists sn(volscale)] && $sn(volscale)} {
			SnackVolScale 1
		} else {
			SnackVolScale 0
		}
	}
}

proc SnackSpecZoom {in} {
	global sn evv
	if {$in} {
		if {$sn(frqzoom) == 2} {
			set sn(frqzoom) 0
			catch {$sn(snackan) delete wave}
			SnSpectrogram		
			RestoreSnMarkers 1
		} else {
			incr sn(frqzoom)
			DelSnMarkers
			catch {$sn(snackan) delete wave}
			SnSpectrogram
			if {$sn(brktype) == $evv(SN_FEATURES_PEAKS)} {
				if {[info exists sn(feature_0)]} {
					RestoreSnMarkers 1
					set sn(restore) features
				}
			}
			ReDrawFrqBox
			RemakeBox
		}
	} elseif {$sn(frqzoom) != 0} {
		DelSnMarkers
		set sn(frqzoom) 0
		RestoreSnMarkers 1
	}
}

proc ReDrawFrqBox {} {
	global sn evv
	if {![info exists sn(frqboxtop)]} {
		return
	}
	switch -- $sn(frqzoom) {
		1 { set ratio [expr double($sn(nyquist)) / double($evv(SN_SPEECHTOP))] }
		2 { set ratio [expr double($sn(nyquist)) / double($evv(SN_FORMTOP))] }
	}
	set xa $sn(left)
	set ya [lindex $sn(frqboxanchor) 1]
	set xb $sn(right)
	set yb $sn(frqboxtop)
	set ya [expr $sn(height) - $ya]
	set ya [expr int(round(double($ya) * $ratio))]
	set ya [expr $sn(height) - $ya]
	if {$ya <= 0} {
		set ya 0
	}
	set yb [expr $sn(height) - $yb]
	set yb [expr int(round(double($yb) * $ratio))]
	set yb [expr $sn(height) - $yb]
	if {$yb <= 0} {
		set yb 0
	}
	if {($ya == 0) && ($yb == 0)} {
		return
	}
	$sn(snackan) delete frqbox
	eval {$sn(snackan) create rect $xa $ya $xb $yb -tag frqbox -outline red -stipple gray12}
}

proc RemakeBox {} {
	global sn
	if {[info exists sn(restorebox)]} {
		set sn(boxthis) [eval {$sn(snackan) create rect} $sn(boxanchor) {$sn(boxend) 0 -tag box -outline blue -stipple gray12}]
	}
}

proc SnackSpecScale {on} {
	global sn evv
	catch {$sn(snackan) delete frqscale}
	if {$on == 2} {
		.snack.f6.1.sf config -text "" -bd 0 -command {}
		return
	}
	if {$on} {
		switch -- $sn(frqzoom) {
			0 {
				set topfrq $sn(nyquist)
#RWD				set step 500.0
                set step 2000.0
			}
			1 {
				set topfrq $evv(SN_SPEECHTOP)
#RWD				set step 200.0
                set step 1000.0
			}
			2 {
				set topfrq $evv(SN_FORMTOP)
#RWD				set step 100.0
                set step 500.0
			}
		}
		set thisfrq $step
		while {$thisfrq < $topfrq} {
			set y [expr $thisfrq / $topfrq]
			set y [expr int(round($y * double($sn(height))))]
			set y [expr $sn(height) - $y]
			$sn(snackan) create line $sn(scaleleft) $y $sn(scalecleft) $y -fill black -tag frqscale
			$sn(snackan) create line $sn(scalecright) $y $sn(scaleright) $y -fill black -tag frqscale
			set scaletext [expr int(round($thisfrq))]
			$sn(snackan) create text $sn(left) $y -text  $scaletext -fill black -anchor w -tag frqscale
			$sn(snackan) create text $sn(centre) $y -text  $scaletext -fill black -anchor center -tag frqscale
			$sn(snackan) create text $sn(right) $y -text $scaletext -fill black -anchor e -tag frqscale
			set thisfrq [expr $thisfrq + $step]
		}
		.snack.f6.1.sf config -text "HIDE SCALE" -bd 2 -command "SnackSpecScale 0"
		set sn(frqscale) 1
	} else {
		.snack.f6.1.sf config -text "SEE FRQ SCALE" -bd 2 -command "SnackSpecScale 1"
		set sn(frqscale) 0
	}
}

proc SnackVolScale {on} {
	global sn
	catch {$sn(snackan) delete volscale}
	if {$on == 2} {
		.snack.f6.outp config -text "" -bd 0 -command {}
		return
	}
	if {$on} {
		set thisvol 0
		set step 0.025
		while {$thisvol <= 1.0} {
			set y [expr int(round($thisvol * double($sn(height))))]
			set y [expr $sn(height) - $y]
			$sn(snackan) create line $sn(scaleleft) $y $sn(scalecleft) $y -fill red -tag volscale
			$sn(snackan) create line $sn(scalecright) $y $sn(scaleright) $y -fill red -tag volscale
			set voltext [DecPlaces $thisvol 3]
			$sn(snackan) create text $sn(left) $y -text  $voltext -fill red -anchor w -tag volscale
			$sn(snackan) create text $sn(centre) $y -text  $voltext -fill red -anchor center -tag volscale
			$sn(snackan) create text $sn(right) $y -text $voltext -fill red -anchor e -tag volscale
			set thisvol [expr $thisvol + $step]
		}
		.snack.f6.outp config -text "HIDE LEVEL SCALE" -bd 2 -command "SnackVolScale 0"
		set sn(volscale) 1
	} else {
		.snack.f6.outp config -text "SEE LEVEL SCALE" -bd 2 -command "SnackVolScale 1"
		set sn(volscale) 0
	}
}

proc SnackScale {on} {
	global sn evv
	catch {$sn(snackan) delete scale}
	if {$on} {
		set range [expr $sn(valhi) - $sn(vallo)]
		set stepdata [SnGetStep $range]
		set step [lindex $stepdata 0]
		set scaling [lindex $stepdata 1]
		set scaletext [TrimTrailingZeros $sn(vallo)]
		set scbot [expr $sn(height) - $evv(SN_TEXTTRIM)]
		$sn(snackan) create text $sn(left)   $scbot -text $scaletext -fill red -anchor w -tag scale
		$sn(snackan) create text $sn(centre) $scbot -text $scaletext -fill red -anchor center -tag scale
		$sn(snackan) create text $sn(right)  $scbot -text $scaletext -fill red -anchor e -tag scale
		set topval [expr $sn(valhi) * pow(10.0,$scaling)]		
		set botval [expr $sn(vallo) * pow(10.0,$scaling)]				
		set range  [expr $range   * pow(10.0,$scaling)]				
		set thisval [expr $botval + double($step)]
		while {$thisval <= $topval} {
			set thisintval [expr int(floor($thisval))]
			set scaletext [MakeScaleText $thisintval $scaling]
			set y [expr (double($thisintval) - $botval) / double($range)]
			set y [expr int(round($y * $sn(height)))]
			set y [expr $sn(height) - $y]
			if {$y < $evv(SN_TEXTTRIM)} {
				set y $evv(SN_TEXTTRIM)
			} else {
				$sn(snackan) create line $sn(scaleleft) $y $sn(scalecleft) $y -fill red -tag scale
				$sn(snackan) create line $sn(scalecright) $y $sn(scaleright) $y -fill red -tag scale
			}
			$sn(snackan) create text $sn(left) $y -text  $scaletext -fill red -anchor w -tag scale
			$sn(snackan) create text $sn(centre) $y -text  $scaletext -fill red -anchor center -tag scale
			$sn(snackan) create text $sn(right) $y -text $scaletext -fill red -anchor e -tag scale
			set thisval [expr $thisval + $step]
		}
		.snack.f6.1.sf config -text "HIDE SCALE" -bd 2 -command "SnackScale 0"
		set sn(scale) 1
	} else {
		.snack.f6.1.sf config -text "SEE VAL SCALE" -bd 2 -command "SnackScale 1"
		set sn(scale) 0
	}
}

proc SnGetStep {range} {
	set scaling 0
	if {$range > 100.0} {
		while {$range > 100.0} {
			set range [expr $range / 10.0]
			incr scaling -1
		}
	} elseif {$range < 10.0} {
		while {$range < 10.0} {
			set range [expr $range * 10.0]
			incr scaling
		}
	}
	if {$range > 80} {
		set step 10
	} elseif {$range > 50} {
		set step 5
	} elseif {$range > 35} {
		set step 4
	} elseif {$range > 20} {
		set step 2
	} else {
		set step 1
	}
	return [list $step $scaling]
}

proc MakeScaleText {thisintval scaling} {
	if {$scaling > 0} {
		set outval "0."
		set cnt 1
		if {[string length $thisintval] > 1} {
			incr cnt
		}
		while {$cnt < $scaling} {
			append outval "0"
			incr cnt
		}
		append outval $thisintval
		return $outval
	} elseif {$scaling < 0} {
		set scaling [expr -$scaling]
		set cnt 0
		while {$cnt < $scaling} {
			append thisintval "0"
			incr cnt
		}
		return $thisintval
	}
	set thisintval [TrimTrailingZeros $thisintval]
	return $thisintval
}

proc TrimTrailingZeros {val} {
	set len [string length $val]
	if {($len > 1) && ([string first "." $val] >= 0)} {
		incr len -1
		while {[string match [string index $val $len] "0"]} {
			incr len -1
		}
		if {[string match [string index $val $len] "."]} {
			incr len -1
		}
		set val [string range $val 0 $len]
	}
	return $val
}


proc SnBoxMove {x} {
	global sn
	if {![info exists sn(boxlen)] || ($sn(boxlen) >= $sn(displen))} {
		return
	}
	if {![info exists sn(boxthis)]} {
		return
	}
	set box_start [lindex $sn(boxanchor) 0]
	set left [expr $box_start - $x]
	if {$left < 0} {
		set left [expr -$left]
	}
	set right [expr $sn(boxend) - $x]
	if {$right < 0} {
		set right [expr -$right]
	}
	if {$left < $right} {
		set right 0
	} else {
		set right 1
	}
	if {$right} {
		set newboxstart $sn(endsamp)
		set newboxend	[expr $newboxstart + $sn(boxlen)]

		if {$newboxend > $sn(dispend)} {
			set newboxend $sn(dispend)
		}
	} else {
		set newboxend $sn(startsamp)
		set newboxstart	[expr $sn(startsamp) - $sn(boxlen)]
		if {$newboxstart < $sn(dispstart)} {
			set newboxstart $sn(dispstart)
		}
	}
	if {[expr $newboxend - $newboxstart] <= 1} {
		return
	}
	set sn(startsamp) $newboxstart
	set sn(endsamp) $newboxend
	set sn(starttime) [expr double($sn(startsamp)) * $sn(inv_srxchs)]
	set sn(endtime)   [expr double($sn(endsamp))   * $sn(inv_srxchs)]
	set sn(starttime_shown) [ShowTime $sn(starttime)]
	set sn(endtime_shown)   [ShowTime $sn(endtime)]
	set sn(gpstartsamp) [expr $sn(startsamp) / $sn(chans)]
	set sn(gpendsamp)   [expr $sn(endsamp) / $sn(chans)]
	set sn(boxlen) [expr $sn(endsamp) - $sn(startsamp)]
	catch {$sn(snackan) delete $sn(boxthis)}
	catch {$sn(snackan) delete box}
	set k [expr double($sn(startsamp) - $sn(dispstart))]
	set k [expr $k / double($sn(displen))]
	set k [expr int(round($k * $sn(width)))]
	set k [expr ($k / $sn(chans)) * $sn(chans)]
	set sn(boxanchor) [list $k $sn(height)]
	set k [expr double($sn(endsamp) - $sn(dispstart))]
	set k [expr $k / double($sn(displen))]
	set k [expr int(round($k * $sn(width)))]
	set sn(boxend) [expr ($k / $sn(chans)) * $sn(chans)]
	set sn(boxthis) [eval {$sn(snackan) create rect} $sn(boxanchor) {$sn(boxend) 0 -tag box -outline blue -stipple gray12}]
}

#--- Convert start of existing playbox to a timemark

proc TimeMarkAtPlayBoxStart {} {
	global sn
	if {[info exists sn(frqzoom)] && ($sn(frqzoom) > 0)} {
		return
	}
	if {![info exists sn(boxlen)] || ($sn(boxlen) >= $sn(displen))} {
		return
	}
	if {![info exists sn(boxthis)]} {
		return
	}
	set x [lindex $sn(boxanchor) 0]
	set xx $x
	set sn(markthis) [eval {$sn(snackan) create line} {$x $sn(height) $x 0 -tag mark -fill blue}]
	set wratio [expr double($xx - $sn(left)) / double($sn(width))]
	set x [expr int(round(double($sn(displen)) * $wratio))]
	set outsamp [expr $sn(dispstart) + $x]
	set outsamp [expr ($outsamp / $sn(chans)) * $sn(chans)]
	lappend sn(marklist) $outsamp
}

#--- Move start of existing playbox to nearest timemark within or before playbox

proc SnBoxToTimeMark {} {
	global sn
	if {[info exists sn(frqzoom)] && ($sn(frqzoom) > 0)} {
		return
	}
	if {![info exists sn(boxlen)] || ($sn(boxlen) >= $sn(displen))} {
		return
	}
	if {![info exists sn(boxthis)]} {
		return
	}
	if {![info exists sn(marklist)]} {
		return
	}
	set x [lindex $sn(boxanchor) 0]

	set kk 0
	set this_marklist $sn(marklist)
	lappend this_marklist $sn(dispstart)
	foreach mk $this_marklist {
		if {($mk >= $sn(dispstart)) && ($mk <= $sn(dispend))} {
			set wratio [expr double($mk - $sn(dispstart)) / double($sn(displen))]
			set mk [expr int(round(double($sn(width)) * $wratio))]
			incr mk $sn(left)
		}
		if {[expr $sn(boxend) - $mk] >= 0} {
			lappend possiblemks $mk
			lappend possiblepos $kk
		}
		incr kk
	}
	if {![info exists possiblemks]} {
		return
	}
	set leastdiff 10000000000
	foreach mk $possiblemks pos $possiblepos {
		set thisdiff [expr abs($x - $mk)]
		if {$thisdiff < $leastdiff} {
			set closemk $mk
			set closepos $pos
			set leastdiff $thisdiff
		}
	}
	if {![info exists closemk]} {
		return
	}
	set sn(startsamp) [lindex $this_marklist $closepos]
	set sn(starttime) [expr double($sn(startsamp)) * $sn(inv_srxchs)]
	set sn(endtime)   [expr double($sn(endsamp))   * $sn(inv_srxchs)]
	set sn(gpstartsamp) [expr $sn(startsamp) / $sn(chans)]
	set sn(gpendsamp)   [expr $sn(endsamp) / $sn(chans)]
	set sn(dur) [ShowTime [expr $sn(endtime) - $sn(starttime)]]
	set sn(boxlen) [expr $sn(endsamp) - $sn(startsamp)]
	catch {$sn(snackan) delete $sn(boxthis)}
	catch {$sn(snackan) delete box}
	set k [expr double($sn(startsamp) - $sn(dispstart))]
	set k [expr $k / double($sn(displen))]
	set k [expr int(round($k * $sn(width)))]
	set k [expr ($k / $sn(chans)) * $sn(chans)]
	incr k $sn(left)
	set sn(boxanchor) [list $k $sn(height)]
	set k [expr double($sn(endsamp) - $sn(dispstart))]
	set k [expr $k / double($sn(displen))]
	set k [expr int(round($k * $sn(width)))]
	incr k $sn(left)
	set sn(boxend) [expr ($k / $sn(chans)) * $sn(chans)]
	set sn(boxthis) [eval {$sn(snackan) create rect} $sn(boxanchor) {$sn(boxend) 0 -tag box -outline blue -stipple gray12}]
	return
}

#--- Move end of existing playbox to nearest timemark within or after playbox

proc SnBoxEndToTimeMark {} {
	global sn
	if {[info exists sn(frqzoom)] && ($sn(frqzoom) > 0)} {
		return
	}
	if {![info exists sn(boxlen)] || ($sn(boxlen) >= $sn(displen))} {
		return
	}
	if {![info exists sn(boxthis)]} {
		return
	}
	if {![info exists sn(marklist)]} {
		return
	}
	set x [lindex $sn(boxend) 0]
	set stt [lindex $sn(boxanchor) 0]

	set kk 0
	set this_marklist $sn(marklist)
	lappend this_marklist $sn(dispend)
	foreach mk $this_marklist {
		if {($mk >= $sn(dispstart)) && ($mk <= $sn(dispend))} {
			set wratio [expr double($mk - $sn(dispstart)) / double($sn(displen))]
			set mk [expr int(round(double($sn(width)) * $wratio))]
		}
		if {[expr $mk - $stt] > 0} {
			lappend possiblemks $mk
			lappend possiblepos $kk
		}
		incr kk
	}
	if {![info exists possiblemks]} {
		return
	}
	set leastdiff 10000000000
	foreach mk $possiblemks pos $possiblepos {
		set thisdiff [expr abs($x - $mk)]
		if {$thisdiff < $leastdiff} {
			set closemk $mk
			set closepos $pos
			set leastdiff $thisdiff
		}
	}
	if {![info exists closemk]} {
		return
	}
	set sn(endsamp) [lindex $this_marklist $closepos]
	set sn(endtime) [expr double($sn(endsamp)) * $sn(inv_srxchs)]
	set sn(starttime)   [expr double($sn(startsamp))   * $sn(inv_srxchs)]
	set sn(gpstartsamp) [expr $sn(startsamp) / $sn(chans)]
	set sn(gpendsamp)   [expr $sn(endsamp) / $sn(chans)]
	set sn(dur) [ShowTime [expr $sn(endtime) - $sn(starttime)]]
	set sn(boxlen) [expr $sn(endsamp) - $sn(startsamp)]
	catch {$sn(snackan) delete $sn(boxthis)}
	catch {$sn(snackan) delete box}
	set k [expr double($sn(startsamp) - $sn(dispstart))]
	set k [expr $k / double($sn(displen))]
	set k [expr int(round($k * $sn(width)))]
	set k [expr ($k / $sn(chans)) * $sn(chans)]
	incr k $sn(left)
	set sn(boxanchor) [list $k $sn(height)]
	set k [expr double($sn(endsamp) - $sn(dispstart))]
	set k [expr $k / double($sn(displen))]
	set k [expr int(round($k * $sn(width)))]
	incr k $sn(left)
	set sn(boxend) [expr ($k / $sn(chans)) * $sn(chans)]
	set sn(boxthis) [eval {$sn(snackan) create rect} $sn(boxanchor) {$sn(boxend) 0 -tag box -outline blue -stipple gray12}]
	return
}

proc SnFofBoxMove {x} {
	global sn
	if {![info exists sn(boxlen)] || ($sn(boxlen) >= $sn(displen))} {
		return
	}
	if {![info exists sn(boxthis)]} {
		return
	}
	set box_start [lindex $sn(boxanchor) 0]
	if {$sn(foffeatures)} {
		set sn(boxlen) $sn(fofunitlen)
		if {$x > [expr $sn(width)/2]} {
			set right 1
		} else {
			set right 0
		}
	} else {
		set left [expr $box_start - $x]
		if {$left < 0} {
			set left [expr -$left]
		}
		set right [expr $sn(boxend) - $x]
		if {$right < 0} {
			set right [expr -$right]
		}
		if {$left < $right} {
			set right 0
		} else {
			set right 1
		}
	}
	if {$right} {
		if {$sn(foffeatures)} {
			set newboxstart [expr $sn(dispstart) + $sn(boxlen)]
		    set newboxend	[expr $newboxstart + $sn(boxlen)]
			if {$newboxend > $sn(dispend)} {
				set sn(dispstart) $newboxstart
				if {$sn(dispstart) > [expr $sn(sampdur) - $sn(fofunitlen)]} {
					set sn(dispstart) [expr $sn(sampdur) - $sn(fofunitlen)]
				}
				set sn(dispend) [expr $sn(dispstart) + $sn(width)]
				set thisstarttime [expr double($sn(dispstart)) * $sn(inv_srxchs)]
				set thisendtime   [expr double($sn(dispend))   * $sn(inv_srxchs)]
				set len [expr $thisendtime - $thisstarttime]
				set sn(pixpersec) [expr double($sn(width)) / $len]
				set sn(displen) [expr $sn(dispend) - $sn(dispstart)]
				catch {$sn(snackan) delete wave}
				$sn(snackan) create waveform 0 0 -sound s -height $sn(height) -pixelspersecond $sn(pixpersec) -start [expr $sn(dispstart) / 1] -tag wave
				catch {$sn(snackan) delete pm}
				$sn(snackan) create poly -1 -1 -1 -1 -1 -1 -fill red -tags pm
				set newboxstart $sn(dispstart)
				set newboxend [expr $newboxstart + $sn(boxlen)]
			}
		} else {
			set newboxstart $sn(endsamp)
			set newboxend	[expr $newboxstart + $sn(boxlen)]
			if {$newboxend > $sn(dispend)} {
				set newboxend $sn(dispend)
			}
		}
	} else {
		if {$sn(foffeatures)} {
			set newboxstart	[expr $sn(startsamp) - $sn(boxlen)]
			set newboxend [expr $newboxstart + $sn(boxlen)]
			set sn(dispstart) $newboxstart
			if {$sn(dispstart) < $sn(fofunitlen)} {
				set sn(dispstart) $sn(fofunitlen)
			}
			set sn(dispend) [expr $sn(dispstart) + $sn(width)]
			set thisstarttime [expr double($sn(dispstart)) * $sn(inv_srxchs)]
			set thisendtime   [expr double($sn(dispend))   * $sn(inv_srxchs)]
			set len [expr $thisendtime - $thisstarttime]
			set sn(pixpersec) [expr double($sn(width)) / $len]
			set sn(displen) [expr $sn(dispend) - $sn(dispstart)]
			catch {$sn(snackan) delete wave}
			$sn(snackan) create waveform 0 0 -sound s -height $sn(height) -pixelspersecond $sn(pixpersec) -start [expr $sn(dispstart) / 1] -tag wave
			catch {$sn(snackan) delete pm}
			$sn(snackan) create poly -1 -1 -1 -1 -1 -1 -fill red -tags pm
			set newboxstart $sn(dispstart)
			set newboxend [expr $newboxstart + $sn(boxlen)]
		} else {
			set newboxend $sn(startsamp)
			set newboxstart	[expr $sn(startsamp) - $sn(boxlen)]
			if {$newboxstart < $sn(dispstart)} {
				set newboxstart $sn(dispstart)
			}
		}
	}
	set sn(startsamp) $newboxstart
	set sn(endsamp) $newboxend
	set sn(starttime) [expr double($sn(startsamp)) * $sn(inv_srxchs)]
	set sn(endtime)   [expr double($sn(endsamp))   * $sn(inv_srxchs)]
	set sn(gpstartsamp) [expr $sn(startsamp) / $sn(chans)]
	set sn(gpendsamp)   [expr $sn(endsamp) / $sn(chans)]
	set sn(boxlen) [expr $sn(endsamp) - $sn(startsamp)]
	catch {$sn(snackan) delete $sn(boxthis)}
	catch {$sn(snackan) delete box}
	set k [expr double($sn(startsamp) - $sn(dispstart))]
	set k [expr $k / double($sn(displen))]
	set k [expr int(round($k * $sn(width)))]
	set k [expr ($k / $sn(chans)) * $sn(chans)]
	set sn(boxanchor) [list $k $sn(height)]
	set k [expr double($sn(endsamp) - $sn(dispstart))]
	set k [expr $k / double($sn(displen))]
	set k [expr int(round($k * $sn(width)))]
	set sn(boxend) [expr ($k / $sn(chans)) * $sn(chans)]
	set sn(boxthis) [eval {$sn(snackan) create rect} $sn(boxanchor) {$sn(boxend) 0 -tag box -outline blue -stipple gray12}]
	if {$sn(foffeatures)} {
		set sn(fofno) [expr $sn(startsamp) / $sn(fofunitlen)]
	}
}
	
proc SnEdgeGrab {x} {
	global sn
	if {![info exists sn(boxlen)] || ($sn(boxlen) >= $sn(displen))} {
		return
	}
	if {![info exists sn(boxthis)]} {
		return
	}
	set box_start [lindex $sn(boxanchor) 0]
	set left [expr $box_start - $x]
	if {$left < 0} {
		set left [expr -$left]
	}
	set right [expr $sn(boxend) - $x]
	if {$right < 0} {
		set right [expr -$right]
	}
	if {$left < $right} {
		set x $box_start
	} else {
		set x $sn(boxend)
	}
	UnsetLastBox
	catch {unset sn(boxdrag)}
	DelSnBox 0
	set sn(boxanchor) [list $x $sn(height)]
	set sn(boxthis) [eval {$sn(snackan) create rect} $sn(boxanchor) {$x 0 -tag box -outline blue -stipple gray12}]
}


#------ Creates the snack display

proc SnackCreate {time brktype fnam sampdur sr_x_chs chans listing enable_output pcnt dur do_exit} {
	global evv sn pa sn_edit prange sn_pts sn_valsco sn_valhi sn_vallo sn_other sn_remainder sn_rowcnt sn_mlen sn_nyquist 
	global sn_valloreal sn_valhireal sn_windows sn_frametime pprg sv_dummyname sn_fofunitlen sn_fofunitcnt
	global sn_feature sn_peakgroupindex sn_sttwintime sn_endwintime sn_amps sn_starty readonlyfg readonlybg snack_list big_snack
	global mono_mix wstk pr_snmix snmixfnam thumbnailed sv_tl mmod snx segment
#RWD
    global bigspech smallspech
    
	set sn(inv_srxchs) [expr 1.0 / double($sr_x_chs)]
	set sn(brktype) $brktype
	set sn(chans) $chans
	set sn(do_exit) $do_exit
	set sn(sampdur) $sampdur
	set sn(sr_x_chs) $sr_x_chs
	set sn(indur) $dur
	catch {set sn(valsco)     $sn_valsco}
	catch {set sn(vallo)      $sn_vallo}
	catch {set sn(valhi)      $sn_valhi}
	catch {set sn(edit)       $sn_edit}
	catch {set sn(mlen)       $sn_mlen}
	catch {set sn(nyquist)    $sn_nyquist}
	catch {set sn(valloreal)  $sn_valloreal}
	catch {set sn(valhireal)  $sn_valhireal}
	catch {set sn(windows)    $sn_windows}
	catch {set sn(frametime)  $sn_frametime}
	catch {set sn(fofunitlen) $sn_fofunitlen}
	catch {set sn(fofunitcnt) $sn_fofunitcnt}
	catch {set sn(feature)	  $sn_feature}

	if {$listing == "troflist2"} {
		set sn(edit) 0
		set sn(windows) 0
	}
	catch {unset sn(snack_list)}

	if {$sn(edit) == 1} {
		switch -regexp -- $sn(brktype) \
			^$evv(SN_BRKPNTPAIRS)$ {
				catch {unset sn(brk)}
				catch {unset sn(brk_local)}
				catch {unset sn(brk_disp)}
				catch {unset sn(previous)}
				catch {unset sn(next)}
			} \
			^$evv(SN_TIMESLIST)$ {
				catch {unset sn(marklist)}
				catch {unset sn(markthis)}
			} \
			^$evv(SN_MOVETIME_ONLY)$ {
				catch {unset sn(marklist)}
				catch {unset sn(markthis)}
				catch {unset sn(marks_local)}
				catch {unset sn(marks_disp)}
				catch {unset sn(marks_locallen)}
			} \
			^$evv(SN_TIMEPAIRS)$ - \
			^$evv(SN_TIMEDIFF)$ {
			} \
			default {
				Inf "Problem!!"
				return
			}
	}

	UnsetBox
	catch {unset sn(markout)}
	catch {unset sn(markthis)}
	catch {unset sn(marklist)}
	if {$big_snack} {
#RWD
		set sn(height) $bigspech
	} else {
		set sn(height) $smallspech
	}
	set sn(width) 900
	if {$sn(brktype) == $evv(SN_FROM_FOFCNSTR_NO_OUTPUT)} {
		if {$sn(width) < [expr $sn(fofunitlen) + 50]} {		
			set sn(width) [expr $sn(fofunitlen) + 50]
			if {$sn(width) > 1200} {
				set sn(width) 1200
			}		
		}		
	}
	set sn(left) 2
	set sn(right) [expr $sn(width) + $sn(left)]
	set sn(scaleleft)  [expr $sn(left)  + $evv(SN_SCALE_OFFSET)]
	set sn(scaleright) [expr $sn(right) - $evv(SN_SCALE_OFFSET)]
	set sn(centre) [expr ($sn(width) / 2) + $sn(left)]
	set halfoffset [expr $evv(SN_SCALE_OFFSET) / 2]
	set sn(scalecleft)  [expr $sn(centre) - $halfoffset]
	set sn(scalecright) [expr $sn(centre) + $halfoffset]
	set sn(res) -1
	set sn(drag) 0
	set sn(starttime) 0.0
	set sn(endtime) $dur
	set sn(starttime_shown) [ShowTime $sn(starttime)]
	set sn(endtime_shown)   [ShowTime $sn(endtime)]
	set sn(dur)   [ShowTime [expr $sn(endtime) - $sn(starttime)]]
	set sn(startsamp) 0
	set sn(endsamp) $sampdur
	set sn(gpstartsamp) 0
	set sn(gpendsamp) [expr $sn(endsamp) / $sn(chans)]
	if {$sn(windows) } {
		set sn(startwin) [expr int(round($sn(starttime) / $sn(frametime)))]
		set sn(endwin)  [expr int(round($sn(endtime) / $sn(frametime)))]
	}
	if {[info exists sn(feature)]} {
		set n 0
		while {$n < $sn_peakgroupindex} {
			foreach item $sn(feature)($n) {
				lappend sn(feature_$n) $item
			}
			incr n
		}
		foreach item $sn_amps {
			lappend sn(amps) $item
		}
		set sn(peakgroupindex) $sn_peakgroupindex
		set sn(sttwintime) $sn_sttwintime
		set sn(endwintime) $sn_endwintime
	} else {
		set sn(peakgroupindex) -1
	}
	set sn(pixpersec) [expr double($sn(width)) / $sn(endtime)]
	set sn(frqzoom) 0
	if {[info exists sn(snackan)]} {
		catch {$sn(snackan) delete line}
		catch {$sn(snackan) delete point}
		catch {$sn(snackan) delete val}
		unset sn(snackan)
	}
	if {$pa($fnam,$evv(CHANS)) > 2} {
		set snmixfnam $fnam
		if {[info exists thumbnailed]} {
			set thumfnam [file tail $fnam]
			set thumfnam [file join $evv(THUMDIR) $thumfnam]
			if {[file exists $thumfnam]} {
				set snmixfnam $thumfnam
				set fnam $thumfnam
			}
		} else {
			set f .snmix
			if [Dlg_Create $f "PREMIX FOR VIEW" "set pr_snmix 0" -borderwidth 2 -width 80] {
				button $f.mono -text "View Thumbnail"     -command "set pr_snmix 1" -width 18 -bg $evv(EMPH) -highlightbackground [option get . background {}]
				button $f.new  -text "New Mono Thumbnail" -command "set pr_snmix 2" -width 18 -highlightbackground [option get . background {}]
				button $f.quit -text "No Mix"		      -command "set pr_snmix 0" -width 18 -highlightbackground [option get . background {}]
				button $f.qq   -text "Quit"				  -command "set pr_snmix 3" -highlightbackground [option get . background {}]
				pack $f.new $f.mono $f.quit $f.qq -side left -pady 4 
				wm resizable .snmix 1 1
			}
			set thumbfnam [file rootname [file tail $fnam]]
			append thumbfnam $evv(SNDFILE_EXT)
			set thumbfnam [file join $evv(THUMDIR) $thumbfnam]
			if {[file exists $thumbfnam]} {
				if {![SameThumbProps $fnam $thumbfnam]} {
					$f.mono config -bg [option get . background {}]
					$f.new  config -bg $evv(EMPH)
					bind .snmix <Return> {set pr_snmix 2}
				} else {
					$f.mono config -bg $evv(EMPH)
					$f.new  config -bg [option get . background {}]
					bind .snmix <Return> {set pr_snmix 1}
				}
			} else {
				$f.mono config -bg [option get . background {}]
				$f.new  config -bg $evv(EMPH)
				bind .snmix <Return> {set pr_snmix 1}
			}
			bind .snmix <Escape> {set pr_snmix 3}
			set finished 0
			set pr_snmix 0
			raise $f
			My_Grab 0 $f pr_snmix
			while {!$finished} {
				tkwait variable pr_snmix
				switch -- $pr_snmix {
					0 {
						set finished 1
					}
					1 {
						if {[file exists $thumbfnam]} {
							set snmixfnam $thumbfnam
							set finished 1
						} else {
							set snmixfnam [MakeSoundViewThumbnail $fnam]
							if {[string length $snmixfnam] > 0} {
								set finished 1
							}
						}
						raise $f
					}
					2 {
						set snmixfnam [MakeSoundViewThumbnail $fnam]
						if {[string length $snmixfnam] > 0} {
							set finished 1
						}
						raise $f
					}
					3 {
						My_Release_to_Dialog $f
						Dlg_Dismiss $f
						destroy $f
						return
					}
				}
			}
			set fnam $snmixfnam
			My_Release_to_Dialog $f
			Dlg_Dismiss $f
			destroy $f
		}
	}
	set f .snack
	if [Dlg_Create $f "SOUND VIEW" "set pr_snack 0" -borderwidth 2 -width 80] {
		pack [canvas $f.cnu -height $sn(height) -width [expr $sn(left) + $sn(width)] -background grey]
		snack::sound s -load $fnam
		set sn(snackan) $f.cnu
		set sn(foffeatures) 0
		frame $f.f0 -height 1 -bg [option get . foreground {}]
		pack $f.f0 -side top -fill x -expand true -pady 6
		switch -regexp -- $sn(brktype) \
			^$evv(SN_BRKPNTPAIRS)$ {
				label $f.f1 -text "Click creates point: Control-Click deletes nearest: Command-Click drags nearest : Shift-Click & Drag creates Play Box"
			} \
			^$evv(SN_TIMEPAIRS)$ - \
			^$evv(SN_TIMEDIFF)$ {
				label $f.f1 -text "Shift-Click + Drag creates Play Box : Command-Click repositions nearest edge of box : Command-Shift-Control-Click repositions furthest edge of box : Command-Control-Click Moves Box Left or Right"
			} \
			^$evv(SN_FRQBAND)$ {
				label $f.f1 -text "Click & Drag to Create Frq Band : Shift-Click & Drag creates Play Box"
			} \
			^$evv(SN_SINGLETIME)$ {
				label $f.f1 -text "Click to Create a Mark : Shift-Click & Drag creates Play Box"
			} \
			^$evv(SN_SINGLEFRQ)$ {
				label $f.f1 -text "Click to Create Frq Mark : Shift-Click & Drag creates Play Box"
			} \
			^$evv(SN_TIMESLIST)$ {
				if {$listing == "troflist"} {
					label $f.f1 -text "Click Set Mark : Cntrl-Click Delete Mark : Shift-Click+Drag makes PlayBox (PB): Command-Cntrl-Click Moves PB L or R: Control-4 Puts PB in 1st seg shown, or Moves PB Edges to Seg edges, or Advances along seg"
				} else {
					label $f.f1 -text "Click Marks Time : Cntrl-Click Deletes Mark : Shift-Click+Drag creates PlayBox (PB): Command-Cntrl-Click Moves PB L or R: Control-1 Sets Mark at PB Start : Control-2 Move PB Start to Mark : Control-3 Move PB End to Mark"
				}
			} \
			^$evv(SN_MOVETIME_ONLY)$ {
				label $f.f1 -text "Command-Click and Drag Moves a Mark : Shift-Click & Drag creates Play Box"
			} \
			^$evv(SN_UNSORTED_TIMES)$ {
				frame $f.f1
				label $f.f1.1 -text "Click Marks a Time : Control-Click deletes last entered : Shift-Click & Drag creates Play Box : Command-Control-Click Moves Box Left or Right"
				label $f.f1.2 -text "ENTER TIMES IN THE ORDER YOU WANT TO USE THEM" -fg $evv(SPECIAL)
				pack $f.f1.1 $f.f1.2 -side left
			} \
			^$evv(SN_FEATURES_PEAKS)$ {
				label $f.f1 -text "Display of Peaks Found : Shift-Click & Drag creates Play Box"
			} \
			^$evv(SN_FROM_FOFCNSTR_NO_OUTPUT)$ {
				label $f.f1 -text "Highlights FOFs In Deepest Zoom: Command-Cntrl-Click RHS -> NEXT FOF: LHS -> PREVIOUS FOF  (for large FOF-groups, Zoom OUT, Command-Cntrl-Click to L/R of hilighted FOF)"
			}

		if {![info exists segment(displaysegs)]} {
			pack $f.f1 -side top
		}
		frame $f.f2 -borderwidth 0
		entry $f.f2.stime -textvariable sn(starttime_shown) -width 16
		label $f.f2.sll -text "Start Time of Selection"
		entry $f.f2.etime -textvariable sn(endtime_shown)   -width 16
		label $f.f2.ell -text "End Time of Selection"
		pack $f.f2.stime $f.f2.sll -side left
		switch -regexp -- $sn(brktype) \
			^$evv(SN_BRKPNTPAIRS)$ {
				frame $f.f2.1 -borderwidth 0
				radiobutton $f.f2.1.val -text "Drag Value" -variable sn(drag) -value 0
				radiobutton $f.f2.1.tim  -text "Drag Time" -variable sn(drag) -value 1
				pack $f.f2.1.val $f.f2.1.tim -side left
				pack $f.f2.1 -side left -padx 140
			} \
			^$evv(SN_TIMESLIST)$ - \
			^$evv(SN_UNSORTED_TIMES)$ {
				if {![info exists segment(displaysegs)]} {
					radiobutton $f.f2.1 -text "Delete All Marks" -variable sn(mdel) -value 0 -command "DelAllMarks; set sn(mdel) -1"
					pack $f.f2.1 -side left -padx 200
				}
			}

		pack $f.f2.etime $f.f2.ell -side right
		pack $f.f2 -side top -fill x -expand true
		frame $f.f3 -borderwidth 0
		switch -regexp -- $time \
			^$evv(SMPS_OUT)$ {
				entry $f.f3.ssmp -textvariable sn(startsamp) -width 16
				entry $f.f3.esmp -textvariable sn(endsamp)   -width 16
			} \
			default {
				entry $f.f3.ssmp -textvariable sn(gpstartsamp) -width 16
				entry $f.f3.esmp -textvariable sn(gpendsamp)   -width 16
			}

		label $f.f3.sll -text "Start Sample"
		label $f.f3.ell -text "End Sample"
		label $f.f3.dll -text "   :   Dur"
		entry $f.f3.dur -textvariable sn(dur)   -width 16
		frame $f.f3.1 -borderwidth 0
		switch -regexp -- $sn(brktype) \
			^$evv(SN_TIMEPAIRS)$   - \
			^$evv(SN_TIMEDIFF)$   - \
			^$evv(SN_BRKPNTPAIRS)$ - \
			^$evv(SN_SINGLETIME)$  - \
			^$evv(SN_FRQBAND)$     - \
			^$evv(SN_SINGLEFRQ)$   - \
			^$evv(SN_TIMESLIST)$   - \
			^$evv(SN_UNSORTED_TIMES)$ - \
			^$evv(SN_FEATURES_PEAKS)$ - \
			^$evv(SN_MOVETIME_ONLY)$ {
				radiobutton $f.f3.1.del -text "Remove PlayBox (Tab)" -variable sn(res) -value 0 -command "DelSnBox 1; set sn(res) -1"
				radiobutton $f.f3.1.res -text "Restore PlayBox (Tab)" -variable sn(res) -value 1 -command "RestoreSnBox; set sn(res) -1"
				pack $f.f3.1.del $f.f3.1.res -side left
				pack $f.f3.ssmp $f.f3.sll $f.f3.dll $f.f3.dur -side left
				pack $f.f3.1 -side left -padx 70
			} \
			^$evv(SN_FROM_FOFCNSTR_NO_OUTPUT)$ {
				pack $f.f3.ssmp $f.f3.sll $f.f3.dll $f.f3.dur -side left
			} \
			default {
				pack $f.f3.ssmp $f.f3.sll $f.f3.dll $f.f3.dur -side left
			}

		pack $f.f3.esmp $f.f3.ell -side right
		pack $f.f3 -side top -fill x -expand true
		if {$sn(windows) } {
			frame $f.f3a -borderwidth 0
			label $f.f3a.sll -text "Start Window"
			label $f.f3a.ell -text "End Window"
			entry $f.f3a.swin -textvariable sn(startwin) -width 16
			entry $f.f3a.ewin -textvariable sn(endwin)   -width 16
			pack $f.f3a.swin $f.f3a.sll -side left
			pack $f.f3a.ewin $f.f3a.ell -side right
			pack $f.f3a -side top -fill x -expand true
		}
		frame $f.f4 -height 1 -bg [option get . foreground {}]
		pack $f.f4 -side top -fill x -expand true -pady 6
		set sn(out) $time
		frame $f.f6 -borderwidth 0
		if {$sn(brktype) == $evv(SN_BRKPNTPAIRS)} {
			frame $f.f7 -borderwidth 0
			frame $f.f7.0 -borderwidth 0
			label $f.f7.0.lab -text "QUANTISE" -width 9
			button $f.f7.0.ton -text "TIME ON"   -width 9 -command "SetTimeQuantiseSV" -highlightbackground [option get . background {}]
			button $f.f7.0.tof -text "TIME OFF"  -width 9 -command "SetTimeQuantiseOffSV" -highlightbackground [option get . background {}]
			entry $f.f7.0.te -textvariable sn(qtime) -width 4  -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
			button $f.f7.0.von -text "VALUE ON"  -width 9 -command "SetValQuantiseSV" -highlightbackground [option get . background {}]
			button $f.f7.0.vof -text "VALUE OFF" -width 9 -command "SetValQuantiseOffSV" -highlightbackground [option get . background {}]
			entry $f.f7.0.ve -textvariable sn(qval) -width 4 -state readonly -foreground $readonlyfg -readonlybackground $readonlybg
			pack $f.f7.0.te $f.f7.0.ton $f.f7.0.tof $f.f7.0.lab $f.f7.0.von $f.f7.0.vof $f.f7.0.ve -side left -padx 2
			set ccnt 1
			foreach val [list .001 .002 .005 .01 .02 .05 .1 .2 .5 1 2 5 10 20 50 100] {
				button $f.f7.0.$ccnt -text $val -command "DoQuant $val" -width 3
				pack $f.f7.0.$ccnt -side left
				incr ccnt
			}
			button $f.f7.0.baktrak -text UNDO -command "set sn(quant) baktrak; DoQuant 0" -width 5 -highlightbackground [option get . background {}]
			pack $f.f7.0.baktrak -side left -padx 4 -pady 4
			pack $f.f7.0 -side top
			ForceVal $f.f7.0.te Off
			ForceVal $f.f7.0.ve Off
		}
		if {$sn(brktype) != $evv(SN_FROM_FOFCNSTR_NO_OUTPUT)} {
			frame $f.f6.0 -borderwidth 0
			button $f.f6.0.play -text "PLAY" -width 6 -command "SnackPlay" -highlightbackground [option get . background {}] 
			button $f.f6.0.paus -text "PAUSE" -width 6 -command "s pause" -highlightbackground [option get . background {}] 
			button $f.f6.0.stop -text "STOP" -width 6 -command "s stop" -highlightbackground [option get . background {}] 
			radiobutton $f.f6.0.wave -text wave     -variable sn(spectrum) -value 0 -command "SnSpectrum 0"
			radiobutton $f.f6.0.spec -text spectrum -variable sn(spectrum) -value 1 -command "SnSpectrum 1"
			if {($sn(brktype) == $evv(SN_SINGLEFRQ)) || ($sn(brktype) == $evv(SN_FRQBAND)) || ($sn(brktype) == $evv(SN_FEATURES_PEAKS))} {
				set sn(spectrum) 1
			} else {
				set sn(spectrum) 0
			}
			pack $f.f6.0.play $f.f6.0.paus $f.f6.0.stop $f.f6.0.wave $f.f6.0.spec -side left -padx 2
			pack $f.f6.0 -side left
			switch -- $enable_output {
				1 {
					button $f.f6.outp -text "OUTPUT DATA" -width 12  -command "SnackOutput 0" -highlightbackground [option get . background {}] 
					bind $f <Return> "SnackOutput 0"
					if {!$do_exit} {
						button $f.f6.close -text "CLOSE" -width 5  -command "set pr_snack 0" -highlightbackground [option get . background {}]
					}
				}
				2 {
					button $f.f6.outp -text  "DUR"  -width 5  -command "SnackOutput 0"  -highlightbackground [option get . background {}]
					button $f.f6.outp2 -text "TIME" -width 5  -command "SnackOutput 1" -highlightbackground [option get . background {}] 
					bind $f <Return> {}
					if {!$do_exit} {
						button $f.f6.close -text "CLOSE" -width 5  -command "set pr_snack 0" -highlightbackground [option get . background {}]
					}
				}
				0 {
					if {[info exists segment(exportsegs)] && ($segment(exportsegs) == 1) && ![info exists segment(outdisplay)]} {
						button $f.f6.outp -text "EXPORT DATA" -width 12  -command "SnackOutput 0" -highlightbackground [option get . background {}] 
						bind $f <Return> "SnackOutput 0"
					} else {
						bind $f <Return> "set pr_snack 0"
					}
					button $f.f6.close -text "CLOSE" -width 5  -command "set pr_snack 0" -highlightbackground [option get . background {}]
					bind $f <Escape> "set pr_snack 0"
					if {$sn(brktype) == $evv(SN_FEATURES_PEAKS)} {
						button $f.f6.outp -text "LOUDNESS SCALE" -width 16  -command "SnackVolScale 1"
					}
				}
			}
		}
		frame $f.f6.1 -borderwidth 0
		button $f.f6.1.zi -text "ZOOM IN"  -width 12 -command "SnackZoom 1" -highlightbackground [option get . background {}]
		button $f.f6.1.zo -text "ZOOM OUT" -width 12 -command "SnackZoom 0" -highlightbackground [option get . background {}]
		button $f.f6.1.fl -text "FULL VIEW" -width 12 -command "SnackZoom 2" -highlightbackground [option get . background {}]
		if {$sn(brktype) == $evv(SN_FROM_FOFCNSTR_NO_OUTPUT)} {
			label $f.f6.1.sf -text "FOF NUMBER" -width 16
			entry $f.f6.1.zs -textvariable sn(fofno) -width 5 -state readonly
		} else {
			button $f.f6.1.sf -text "SEE FRQ SCALE" -width 16 -command "SnackSpecScale 1" -highlightbackground [option get . background {}]
			button $f.f6.1.zs -text "ZOOM SPECTRUM" -width 16 -command "SnackSpecZoom 1" -highlightbackground [option get . background {}]
		}
		pack $f.f6.1.zi $f.f6.1.zo $f.f6.1.fl -side left -padx 2

		menubutton $f.f6.1.a -text "A" -menu $f.f6.1.a.menu -relief raised -bd 4 -width 2 -background $evv(HELP)
		set pchmenu [menu $f.f6.1.a.menu -tearoff 0]
		$pchmenu add command -label "C" -command "PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfilec$evv(SNDFILE_EXT)] 0" -background white -foreground black
		$pchmenu add separator
		$pchmenu add command -label "C#" -command "PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfiledb$evv(SNDFILE_EXT)] 0" -background black -foreground white
		$pchmenu add separator
		$pchmenu add command -label "D"  -command "PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfiled$evv(SNDFILE_EXT)] 0" -background white -foreground black
		$pchmenu add separator
		$pchmenu add command -label "Eb" -command "PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfileeb$evv(SNDFILE_EXT)] 0" -background black -foreground white
		$pchmenu add separator
		$pchmenu add command -label "E"  -command "PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfilee$evv(SNDFILE_EXT)] 0" -background white -foreground black
		$pchmenu add separator
		$pchmenu add command -label "F"  -command "PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfilef$evv(SNDFILE_EXT)] 0" -background white -foreground black
		$pchmenu add separator
		$pchmenu add command -label "F#" -command "PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfilegb$evv(SNDFILE_EXT)] 0" -background black -foreground white
		$pchmenu add separator
		$pchmenu add command -label "G"  -command "PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfileg$evv(SNDFILE_EXT)] 0" -background white -foreground black
		$pchmenu add separator
		$pchmenu add command -label "Ab" -command "PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfileab$evv(SNDFILE_EXT)] 0" -background black -foreground white
		$pchmenu add separator
		$pchmenu add command -label "A"  -command "PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfile$evv(SNDFILE_EXT)] 0" -background white -foreground black
		$pchmenu add separator
		$pchmenu add command -label "Bb" -command "PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfilebb$evv(SNDFILE_EXT)] 0" -background black -foreground white
		$pchmenu add separator
		$pchmenu add command -label "B"  -command "PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfileb$evv(SNDFILE_EXT)] 0" -background white -foreground black
		$pchmenu add separator
		$pchmenu add command -label "C"  -command "PlaySndfile [file join $evv(CDPRESOURCE_DIR) testfilec2$evv(SNDFILE_EXT)] 0" -background white -foreground black
		pack $f.f6.1.a -side left -padx 2
		pack $f.f6.1.sf $f.f6.1.zs -side left -padx 2
		pack $f.f6.1 -side left
		if {!$enable_output || !$do_exit} {
			catch {button $f.f6.close -text "CLOSE" -width 5  -command "set pr_snack 0" -highlightbackground [option get . background {}]}
			pack $f.f6.close -side right -padx 2
		}
		if {$enable_output || (($sn(brktype) == $evv(SN_FEATURES_PEAKS)) || ([info exists segment(exportsegs)] && ($segment(exportsegs) == 1) && ![info exists segment(outdisplay)]))} {
			pack $f.f6.outp -side right
		}
		if {$enable_output == 2} {
			pack $f.f6.outp2 -side right
		}
		pack $f.f6 -side top -fill x -expand true -pady 4
		if {$sn(brktype) == $evv(SN_BRKPNTPAIRS)} {
			pack $f.f7 -side top -fill x -expand true -pady 4
		}
		set sn(dispstart) $sn(startsamp)
		set sn(dispend)   $sn(endsamp)
		set sn(displen) $sampdur
		if {$sn(brktype) == $evv(SN_FROM_FOFCNSTR_NO_OUTPUT)} {
			set sn(foffeatures) 0
			set sn(spectrum) 0
		}
		if {$sn(spectrum)} {
#RWD
			set sn(height) $bigspech
			$sn(snackan) config -height $sn(height)
			SnSpectrogram
			if {[info exists sn(feature_0)]} {
				set sn(restore) features
				RestoreSnMarkers 0
			}
			$f.f6.1.sf config -text "SEE FRQ SCALE" -bd 2 -command "SnackSpecScale 1"
			$f.f6.1.zs config -text "ZOOM SPECTRUM" -bd 2 -command "SnackSpecZoom 1"
		} else {
			if {$big_snack} {
#RWD
				set sn(height) $bigspech
			} else {
				set sn(height) $smallspech
			}
			$sn(snackan) config -height $sn(height)
			$sn(snackan) create waveform 0 0 -sound s -height $sn(height) -pixelspersecond $sn(pixpersec) -tag wave
			catch {$sn(snackan) delete pm}
			if {($listing == "internalstr") && [info exists sn_pts]} {
				catch {unset sn(pts)}
				foreach pt $sn_pts {
					lappend sn(pts) [expr $pt * $pa($fnam,$evv(SRATE))]		;#	MONO_FILE
				}
				foreach x $sn(pts) {
					set xx [expr int(round($x / $sn(timescale)))]
					incr xx $sn(left)
					set sn(markthis) [eval {$sn(snackan) create line} {$xx $sn(height) $xx 0 -tag mark -fill blue}]
					lappend sn(marklist) [expr int(round($x))]
				}
			}	

# MULTICHAN CANVAS,
#MC			$sn(snackan) create waveform 0 0 -sound s -height $sn(height) -pixelspersecond $sn(pixpersec) -tag wave
#MC			catch {$sn(snackan) delete pm}
#MC			$sn(snackan2) create waveform 0 0 -sound s -height $sn(height) -pixelspersecond $sn(pixpersec) -tag wave
#MC			catch {$sn(snackan2) delete pm}
# MULTICHAN CANVAS,

			$sn(snackan) create poly -1 -1 -1 -1 -1 -1 -fill red -tags pm
			if {$sn(brktype) == $evv(SN_BRKPNTPAIRS)} {
				$f.f6.1.sf config -text "SEE VAL SCALE" -bd 2 -command "SnackScale 1"
				$f.f6.1.zs config -text "HIDE VALUES"  -bd 2 -command {SnHideVals 1}
				set sn(hidden) 0
			} elseif {$sn(brktype) != $evv(SN_FROM_FOFCNSTR_NO_OUTPUT)} {
				$f.f6.1.sf config -text "" -bd 0 -command {}
				$f.f6.1.zs config -text ""  -bd 0 -command {}
			}
		}
		bind .snack <Key-Tab> {TogglePlayBox}
		bind .snack <Escape> "set pr_snack 0"
		bind .snack <Up>   {SnackZoom 1}
		bind .snack <Down> {SnackZoom 0}
	}
	set titstr "SOUND VIEW [file rootname [file tail $fnam]]"
	if {$pprg == $evv(SPECFNU)} {
		set par_name [GetSpecfnuParname $mmod $pcnt]
		append titstr " : $par_name"
	}
	wm title $f $titstr
	bind .snack <Key-space> {catch {s stop}; SnackPlay}
	wm resizable .snack 1 1	
	set sn(marked) 0
	switch -regexp -- $sn(brktype) \
		^$evv(SN_BRKPNTPAIRS)$ {
			set sn(timescale) [expr double($sampdur) / double($sn(width))]
			set sn(atcanstart) 1
			set sn(atcanend) 1
			if {!$sn(edit)} {
				if {[info exists sn_starty]} {
					set yratio [expr ($sn_starty - $sn(vallo)) / $sn(valsco)]
					set yratio [expr 1.0 - $yratio]
					set y [expr $sn(height) * $yratio]
					set sn(starty) $y
				} else {
					set y $sn(height)
				}
				set sn(brk) [list 0 $y $sampdur $y]
				set sn(brk_local) [list 0 $y $sampdur $y]
				set sn(brk_disp) [list $sn(left) $y $sn(right) $y]
				SnCreatePoint $sn(left) $y
				SnCreatePoint $sn(right) $y
				set sn(localcnt) 4
				set sn(endx) 2
				if {[info exists sn_starty]} {
					SnDrawUnityLine
				} else {
					SnDrawLine
				}
			}
			set sn(atend) 1
			set sn(atzero) 1
			bind $sn(snackan)	<ButtonPress-1> 		{SnPointAdd %x %y}
			bind $sn(snackan)	<Control-ButtonPress-1> {SnPointDel %x %y}
			bind $sn(snackan)	<Command-ButtonPress-1> {SnPointMark %x %y}
			bind $sn(snackan)	<Command-B1-Motion> 	{SnPointDrag %x %y}
			bind $sn(snackan)	<Command-ButtonRelease-1>	{SnPointSet move; SnValSet}
			bind $sn(snackan)	<Shift-ButtonPress-1> 	{SnBoxBegin %x %y}
			bind $sn(snackan)	<Shift-B1-Motion> 		{SnBoxDrag %x %y}
			bind $sn(snackan)	<Shift-ButtonRelease-1> {SnBoxSet}
			bind $sn(snackan)	<ButtonRelease-1>		{SnBoxSet}
			bind .snack			<Control-1>					{}
			bind .snack			<Control-2>					{}
			bind .snack			<Control-3>					{}
			bind .snack			<Control-4>					{}
		} \
		^$evv(SN_FEATURES_PEAKS)$ - \
		^$evv(SN_TIMEPAIRS)$ - \
		^$evv(SN_TIMEDIFF)$ {
			bind $sn(snackan)	<Shift-ButtonPress-1> 	{SnBoxBegin %x %y}
			bind $sn(snackan)	<Shift-B1-Motion> 		{SnBoxDrag %x %y}
			bind $sn(snackan)	<Shift-ButtonRelease-1> {SnBoxSet}
			if {$sn(brktype) != $evv(SN_FEATURES_PEAKS)} { 
				bind $sn(snackan)	<Command-ButtonPress-1> 	{SnBoxExtend %x %y 0}
				bind $sn(snackan)	<Command-ButtonRelease-1>	{SnBoxSet}
				bind $sn(snackan)	<Command-Control-ButtonPress-1>	{SnBoxMove %x}
				bind $sn(snackan)	<Command-Shift-ButtonPress-1>	{SnEdgeGrab %x}
				bind $sn(snackan)	<Command-Shift-B1-Motion> 		{SnBoxDrag %x %y}
				bind $sn(snackan)	<Command-Shift-ButtonRelease-1>	{SnBoxSet}
				bind $sn(snackan)	<Command-Control-Shift-ButtonPress-1> 	{SnBoxExtend %x %y 1}
				bind $sn(snackan)	<Command-Control-Shift-ButtonRelease-1> {SnBoxSet}
			} else {
				bind $sn(snackan)	<Command-ButtonPress-1>			{}
				bind $sn(snackan)	<Command-ButtonRelease-1>		{}
				bind $sn(snackan)	<Command-Control-ButtonPress-1>	{}
				bind $sn(snackan)	<Command-Shift-ButtonPress-1>	{}
				bind $sn(snackan)	<Command-Shift-B1-Motion> 		{}
				bind $sn(snackan)	<Command-Shift-ButtonRelease-1>	{}
				bind $sn(snackan)	<Command-Control-Shift-ButtonPress-1> 	{}
				bind $sn(snackan)	<Command-Control-Shift-ButtonRelease-1> {}
			}
			bind $sn(snackan)	<ButtonPress-1> 		{}
			bind $sn(snackan)	<Control-ButtonPress-1> {}
			bind $sn(snackan)	<ButtonRelease-1>		{SnBoxSet}
			bind .snack			<Control-1>					{}
			bind .snack			<Control-2>					{}
			bind .snack			<Control-3>					{}
			bind .snack			<Control-4>					{}
		} \
		^$evv(SN_FRQBAND)$ {
			if {($pprg == $evv(PITCH)) || ($pprg == $evv(SPECROSS))} {
				set wratio [expr double($sn(valhireal) ) / double($sn(valhi))]
				set sn(frqboxheight) [expr int(round(double($sn(height)) * $wratio))] 
				set sn(frqboxheight) [expr $sn(height) - $sn(frqboxheight)] 
			}
			bind $sn(snackan)	<Shift-ButtonPress-1> 	{SnBoxBegin %x %y}
			bind $sn(snackan)	<Shift-B1-Motion> 		{SnBoxDrag %x %y}
			bind $sn(snackan)	<Shift-ButtonRelease-1> {SnBoxSet}
			bind $sn(snackan)	<ButtonPress-1> 		{SnFrqBoxBegin %x %y}
			bind $sn(snackan)	<B1-Motion> 			{SnFrqBoxDrag %x %y}
			bind $sn(snackan)	<ButtonRelease-1>		{SnFrqBoxSet}
			bind $sn(snackan)	<Control-ButtonPress-1> {}
			bind .snack			<Control-1>					{}
			bind .snack			<Control-2>					{}
			bind .snack			<Control-3>					{}
			bind .snack			<Control-4>					{}
		} \
		^$evv(SN_SINGLETIME)$ - \
		^$evv(SN_SINGLEFRQ)$ {
			if {$sn(brktype) == $evv(SN_SINGLEFRQ)} { 
				bind $sn(snackan)	<ButtonPress-1> 		{SnMarkF %x %y}
			} else {
				bind $sn(snackan)	<ButtonPress-1> 		{SnMark %x %y}
			}
			bind $sn(snackan)	<Control-ButtonPress-1> {}
			bind $sn(snackan)	<Shift-ButtonPress-1> 	{SnBoxBegin %x %y}
			bind $sn(snackan)	<Shift-B1-Motion> 		{SnBoxDrag %x %y}
			bind $sn(snackan)	<Shift-ButtonRelease-1> {SnBoxSet}
			bind $sn(snackan)	<ButtonRelease-1>		{SnBoxSet}
			bind .snack			<Control-1>				{}
			bind .snack			<Control-2>				{}
			bind .snack			<Control-3>				{}
			bind .snack			<Control-4>				{}
		} \
		^$evv(SN_TIMESLIST)$ - \
		^$evv(SN_UNSORTED_TIMES)$ {
			set sn(timescale) [expr double($sampdur) / double($sn(width))]
			bind $sn(snackan)	<Shift-ButtonPress-1>	{SnBoxBegin %x %y}
			bind $sn(snackan)	<Shift-B1-Motion> 		{SnBoxDrag %x %y}
			bind $sn(snackan)	<Shift-ButtonRelease-1>	{SnBoxSet}
			bind $sn(snackan)	<ButtonRelease-1>		{SnBoxSet}
			bind $sn(snackan)	<Command-Control-ButtonPress-1>	{SnBoxMove %x}
			bind .snack			<Control-2>					{SnBoxToTimeMark}
			bind .snack			<Control-3>					{SnBoxEndToTimeMark}
			bind .snack			<Control-4>					{SnBoxStartAndEndToTimeMark}
			if {![info exists segment(displaysegs)]} {
				bind $sn(snackan)	<ButtonPress-1> 		{SnMarks %x %y}
				bind .snack			<Control-1>				{TimeMarkAtPlayBoxStart}
			}
			if {$sn(brktype) == $evv(SN_TIMESLIST)} {
				if {![info exists segment(displaysegs)]} {
					bind $sn(snackan)	<Control-ButtonPress-1> {SnMarkDel %x %y}
				}
			} else {
				bind $sn(snackan)	<Control-ButtonPress-1> {SnLastMarkDel %x %y}
			}
		} \
		^$evv(SN_MOVETIME_ONLY)$ {
			set sn(timescale) [expr double($sampdur) / double($sn(width))]
			bind $sn(snackan)	<Shift-ButtonPress-1>	{SnBoxBegin %x %y}
			bind $sn(snackan)	<Shift-B1-Motion> 		{SnBoxDrag %x %y}
			bind $sn(snackan)	<Shift-ButtonRelease-1>	{SnBoxSet}
			bind $sn(snackan)	<Command-ButtonPress-1> 	{SnMarkMark %x %y}
			bind $sn(snackan)	<Command-B1-Motion> 		{SnMarkDrag %x %y}
			bind $sn(snackan)	<Command-ButtonRelease-1>	{SnMarkSet}
			bind $sn(snackan)	<Control-ButtonPress-1> {}
			bind $sn(snackan)	<ButtonPress-1> 		{}
			bind $sn(snackan)	<ButtonRelease-1>		{SnBoxSet}
			bind .snack			<Control-1>					{}
			bind .snack			<Control-2>					{}
			bind .snack			<Control-3>					{}
		} \
		^$evv(SN_FROM_FOFCNSTR_NO_OUTPUT)$ {
			bind $sn(snackan)	<Shift-ButtonPress-1> 	{SnBoxBegin %x %y}
			bind $sn(snackan)	<Shift-B1-Motion> 		{SnBoxDrag %x %y}
			bind $sn(snackan)	<Shift-ButtonRelease-1> {SnBoxSet}
			bind $sn(snackan)	<Command-Control-ButtonPress-1>	{SnFofBoxMove %x}
			bind .snack			<Control-1>					{}
			bind .snack			<Control-2>					{}
			bind .snack			<Control-3>					{}
		}

	bind .	<Key-space>	{SnackPlayStop}
	set sn(done) 0
	set pr_snack 0
	if {$listing == "troflist"} {
		if {$sn(brktype) == $evv(SN_BRKPNTPAIRS)} {
			set sn(edit) 1
			set true_brktype $evv(SN_BRKPNTPAIRS)
			set sn(brktype) $evv(SN_TIMESLIST)
			catch {unset snx(pts)}
			catch {unset snx(markthis)}
			catch {unset snx(marklist)}
		} elseif {[info exists segment(spike_explicit)]} {
			set sn(edit) 0
			set sn(brktype) $evv(SN_TIMESLIST)
			catch {unset snx(pts)}
			catch {unset snx(markthis)}
			catch {unset snx(marklist)}
		}
	}
	if {$sn(edit)} {
				#	CONVERT TO SAMPLE TIMEFRAME
		switch -regexp -- $time \
			^$evv(GRPS_OUT)$ {
				if {$sn(brktype) == $evv(SN_BRKPNTPAIRS)} {
					foreach {x y} $sn_pts {
						set xa [expr $x * $sn(chans)]
						lappend nuvals $xa $y
					}
					set indx [llength $nuvals]
					incr indx -2
					set endsamp $sampdur
				} else {
					foreach x $sn_pts {
						set x [expr $x * $sn(chans)]
						lappend nuvals $x
					}
					set sn(pts) $nuvals
				}
			} \
			^$evv(TIME_OUT)$ {
				if {$sn(brktype) ==$evv(SN_BRKPNTPAIRS)} {
					foreach {x y} $sn_pts {
						set xa [expr int(round($x * $sr_x_chs))]
						lappend nuvals $xa $y
					}
					set indx [llength $nuvals]
					incr indx -2
					set endsamp $sampdur
				} else {
					foreach x $sn_pts {
						set x [expr int(round($x * $sr_x_chs))]
						lappend nuvals $x
					}
					set sn(pts) $nuvals
				}
			} \
			^$evv(SMPS_OUT)$ {
				set sn(pts) $sn_pts
			}

		switch -regexp -- $sn(brktype) \
			^$evv(SN_BRKPNTPAIRS)$ {
				set endtime [lindex $nuvals $indx]	;#	ENSURE LAST TIME-POINT AT END-EDGE
				if {$endtime != $endsamp} {
					set nuvals [lreplace $nuvals $indx $indx $endsamp]
				}
				catch {unset sn(brk)}
				set sn(pts) $nuvals
				foreach {x y} $sn(pts) {		;#	CONVERT INTO 0-1 VALUE RANGE
					set ya [expr $y - $sn(vallo)]
					set ya [expr double($ya) / double($sn(valsco))]
					lappend sn(brk) $x $ya
				}
				set sn(brk_local) $sn(brk)
												;#	CREATE DISPLAY COORDS 	
				catch {unset sn(brk_disp)}
				foreach {x y} $sn(brk_local) {
					set xa [expr int(round($x / $sn(timescale)))]
					incr xa $sn(left)
					set ya [expr int(round($y * double($sn(height))))]
					set ya [expr $sn(height) - $ya]
					lappend sn(brk_disp) $xa $ya
				}
				set valindx 1
				foreach {x y} $sn(brk_disp) {
					set sn(brk) [lreplace $sn(brk) $valindx $valindx $y]
					set sn(brk_local) [lreplace $sn(brk_local) $valindx $valindx $y]
					incr valindx 2
				}
				set sn(localcnt) [llength $sn(brk_disp)]
				set sn(endx) [expr $sn(localcnt) - 2]
				foreach {x y} $sn(brk_disp) {
					SnCreatePoint $x $y
					SnCreateVal $x $y
				}
				SnDrawLine
				set sn(atcanstart) 1
				set sn(atcanend) 1
				set sn(atzero) 1
				set sn(atend) 1
			} \
			^$evv(SN_TIMESLIST)$ {
				if {[info exists segment(displaysegs)]} {
					set h_cnt 0
					set txt_top 14												;#	Offset text from top of display
					set h_h $txt_top
				}
				foreach x $sn(pts) {
					set xx [expr int(round($x / $sn(timescale)))]
					incr xx $sn(left)
					if {($listing == "troflist") && [info exists true_brktype]} {
						set sn(markthis) [eval {$sn(snackan) create line} {$xx $sn(height) $xx 0 -tag mark -fill red}]
					} else {
						set sn(markthis) [eval {$sn(snackan) create line} {$xx $sn(height) $xx 0 -tag mark -fill blue}]
						if {[info exists segment(displaysegs)]} {
							if {[info exists segment(intext)]} {				;#	Use mnemonic, if it exists
								set t_xt [lindex $segment(intext) $h_cnt]		;#	else use number
							} else {
								set t_xt [expr $h_cnt + 1]
							}
							set xx [expr $xx + 0.5]
							$sn(snackan) create text $xx $h_h -text $t_xt -font bigfntbold -fill darkred -anchor w -tag mark
							incr h_cnt
							if {[expr $h_cnt % 5] == 0} {						;#	Texts staggered, downwards, until we reach 5th item
								set h_h $txt_top 
							} else {
								set h_h [expr $h_h + 14]
							}
						}
					}
					lappend sn(marklist) $x
				}
			} \
			^$evv(SN_MOVETIME_ONLY)$ {
				catch {unset sn(marks_local)}
				catch {unset sn(marks_disp)}
				set sn(marks_total) 0
				foreach x $sn(pts) {
					lappend sn(marklist) $x
					lappend sn(marks_local) $x
					set xx [expr int(round($x / $sn(timescale)))]
					incr xx $sn(left)
					lappend sn(marks_disp) $xx
					set sn(markthis) [eval {$sn(snackan) create line} {$xx $sn(height) $xx 0 -tag mark -fill blue}]
					incr sn(marks_total)
				}
				set sn(marks_start) 0
				set sn(marks_locallen) [llength $sn(marks_local)]
			}
				
	}
	if {($listing == "troflist") && [info exists true_brktype]} {
		set sn(brktype) $true_brktype
		unset true_brktype
		catch {unset sn(pts)}
		catch {unset sn_pts}
		set snx(markthis) $sn(markthis)
		catch {unset sn(markthis)}
		set snx(marklist) $sn(marklist)
		catch {unset sn(marklist)}
		set sn(edit) 0
	}
	raise $f
	update idletasks
	if {[info exists sv_tl]} {
		set geo [LockToTopLeft $f]
		wm geometry $f $geo
	} else {
		StandardPosition2 $f
	}
	My_Grab 0 $f pr_snack
	tkwait variable pr_snack
	if {[info exists sn(snack_list)]} {
		if {$brktype == $evv(SN_TIMEPAIRS) && ($listing == ".maketextp.k.t") && (($pprg == $evv(EDIT_EXCISEMANY)) || ($pprg == $evv(INSERTSIL_MANY)))} {
			SortTimepairs
		}
		set snack_list $sn(snack_list)
		if {(($pprg == $evv(HOVER)) || ($pprg == $evv(HOVER2))) && ($pcnt == 1)} {
			Inf "You Must Next Add The Timings To These Locations"
		}
		if {($listing == "troflist") && [info exists segment(exportsegs)] && ($segment(exportsegs) == 1)} {
			ExportTroflist 1
		}
	}
	catch {unset sn(playing)}
	catch {s stop}
	ClearThumbnailTemps
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

proc SnParameterOutputs {} {
	global pprg mmod sn_prm1 sn_prm2 evv
	if {![info exists pprg] || ![info exists mmod]} {
		return
	}
	switch -regexp -- $pprg \
		^$evv(FOCUS)$ {
			set sn_prm1 5
			set sn_prm2 6
		} \
		^$evv(SPECEX)$ {
			set sn_prm1 0
			set sn_prm2 1
		} \
		^$evv(PREFIXSIL)$ {
			set sn_prm1 0
		} \
		^$evv(MIX_AT_STEP)$ {
			set sn_prm1 0
		} \
		^$evv(BAKTOBAK)$ {
			set sn_prm1 0
		} \
		^$evv(CHORD)$ {
			set sn_prm1 4
			set sn_prm2 5
		} \
		^$evv(MOD_PITCH)$ {
			if {$mmod == 5} {
				set sn_prm1 2
				set sn_prm2 1
			}
		} \
		^$evv(MOD_RADICAL)$ {
			if {$mmod == 3} {
				set sn_prm1 3
				set sn_prm2 4
			}
		} \
		^$evv(STRANS_MULTI)$ {
			if {$mmod == 3} {
				set sn_prm1 2
				set sn_prm2 1
			}
		} \
		^$evv(TRNSF)$ {
			switch -- $mmod {
				1 -
				2 -
				3 {
					set sn_prm1 4
					set sn_prm2 5
				}
				4 {
					set sn_prm1 3
					set sn_prm2 4
				}
			}
		} \
		^$evv(TRNSP)$ {
			switch -- $mmod {
				1 -
				2 -
				3 {
					set sn_prm1 1
					set sn_prm2 2
				}
				4 {
					set sn_prm1 0
					set sn_prm2 1
				}
			}
		} \
		^$evv(MEAN)$ - \
		^$evv(FOLD)$ - \
		^$evv(FILT)$ - \
		^$evv(EDIT_ZCUT)$ - \
		^$evv(EDIT_EXCISE)$	- \
		^$evv(EDIT_CUT)$ - \
		^$evv(ENV_CURTAILING)$ - \
		^$evv(EXPDECAY)$ {
			set sn_prm1 0
			set sn_prm2 1
		} \
		^$evv(INFO_MAXSAMP2)$ {
			set sn_prm1 0
			set sn_prm2 1
		} \
		^$evv(ITERATE_EXTEND)$ {
			set sn_prm1 5
			set sn_prm2 6
		} \
		^$evv(S_TRACE)$ {
			if {$mmod > 1} {
				set sn_prm1 1
				set sn_prm2 2
			}
		} \
		^$evv(RRRR_EXTEND)$ {
			if {($mmod == 1) || ($mmod == 3)} {
				set sn_prm1 0
				set sn_prm2 1
			}
		} \
		^$evv(ZIGZAG)$ - \
		^$evv(MCHZIG)$ {
			if {$mmod == 1} {
				set sn_prm1 0
				set sn_prm2 1
			}
		} \
		^$evv(ARPE)$ {
			set sn_prm1 3
			set sn_prm2 4
		} \
		^$evv(MULTRANS)$ - \
		^$evv(SHIFT)$ {
			set sn_prm1 1
			set sn_prm2 2
		} \
		^$evv(PITCH)$ - \
		^$evv(SPECROSS)$ {
			set sn_prm1 4
			set sn_prm2 5
		} \
		^$evv(WAVER)$ {
			set sn_prm1 2
		} \
		^$evv(GRAB)$ - \
		^$evv(MAGNIFY)$ - \
		^$evv(EDIT_INSERT)$ - \
		^$evv(ONEFORM_GET)$ - \
		^$evv(FIND_PANPOS)$ - \
		^$evv(PICK)$  - \
		^$evv(STRETCH)$ {
			set sn_prm1 0
		} \
		^$evv(LOOP)$ {
			switch -- $mmod {
				1 {
					set sn_prm1 0
					set sn_prm2 1
				}
				default {
					set sn_prm1 1
					set sn_prm2 2
				}
			}
		} \
		^$evv(TUNE)$ {
			set sn_prm1 4
		} \
		^$evv(STACK)$ {
			set sn_prm1 3
		} \
		^$evv(BRIDGE)$ {
			set sn_prm1 5
			set sn_prm2 6
		} \
		^$evv(TOSTEREO)$ {
			set sn_prm1 0
			set sn_prm2 1
		} \
		^$evv(MORPH)$ {
			set sn_prm1 6
		} \
		^$evv(PSOW_FREEZE)$ - \
		^$evv(PSOW_EXTEND)$ - \
		^$evv(PSOW_CUT)$ {
			set sn_prm1 1
		} \
		^$evv(SHRINK)$ - \
		^$evv(PACKET)$ - \
		^$evv(SHIFTP)$ {
			set sn_prm1 0
		} \
		^$evv(EDIT_INSERT2) - \
		^$evv(EDIT_INSERTSIL)$ {
			set sn_prm1 0
			set sn_prm2 1
		} \
		^$evv(GLIS)$ {
			switch -- $mmod {
				1 -
				3 {
					set sn_prm1 4
				}
				2 {
					set sn_prm1 5
				}
			}
		} \
		^$evv(GREV_EXTEND)$ {
			set sn_prm1 3
			set sn_prm2 4
		} \
		^$evv(RETIME)$ {
			switch -- $mmod {
				5 {
					set sn_prm1 2
					set sn_prm2 3
				}
				8 {
					set sn_prm1 1
				}
				14 {
					set sn_prm1 1
				}
			}
		} \
		^$evv(HOVER2)$ {
			set sn_prm1 0
			set sn_prm2 1
		} \
		^$evv(SYNTHSEQ)$ {
			set sn_prm1 0
		} \
		^$evv(SYNTHSEQ2)$ {
			set sn_prm1 0
			set sn_prm2 1
		} \
		^$evv(SPLINTER)$ {
			set sn_prm1 0
		}
}

######################
#					 #
#	MIDI IN USING tv #
#					 #
######################

#############################################
#	  SETTING UP THE MIDI INPUT DEVICE		#
#############################################

# ---- This function gets the MIDI device the user wants to use for input, the stop MIDI key they want to use
# ---- and the amount of data they want to store

proc SetMidiInputDeviceTV {} {
	global pr_selmidi CDPtv tv_got tv_output tv_midiin selmidi_cnt tv_maxevents tv_stop evv

	set tv_got 0
	set tv_output {}
	set cmd [file join $evv(CDPROGRAM_DIR) tv]
	if [catch {open "|$cmd"} CDPtv] {
		ErrShow "Cannot Run TV $CDPtv"
		catch {unset CDPtv}
	} else {
		fileevent $CDPtv readable WriteTVData
	}
	vwait tv_got
	if {![info exists tv_output]} {
		Inf "No Response From TV"
		return 0
	}
	set devices -1
	set OK 1
	foreach line $tv_output {
		set line [string trim $line]
		if {[llength $line] <= 0} {
			continue
		}
		if {$devices > 0} {
			set line [split $line]
			set cnt 0
			foreach item $line {
				if {[string length $item] <= 0} {
					continue
				}
				lappend nuline $item
			}
			if {![info exists nuline]} {
				set OK 0
				break
			}
			set nuline [lrange $nuline 1 end]
			set line [join $nuline]
			lappend device_names $line
			unset nuline
			incr devices -1
		} elseif {[string first "MIDI IN" $line] >= 0} {
			set line [split $line]
			set cnt 0
			foreach item $line {
				if {[string length $item] <= 0} {
					continue
				}
				if {$cnt == 1} {
					if {![regexp {^[0-9]+$} $item]} {
						set OK 0
						break
					}
					set devices $item
					set got_devices 1
					break
				}
				incr cnt
			}
		}
		if {($OK == 0) || ($devices == 0)} {
			break
		}
	}
	if {!$OK} {
		Inf "Bad Data Returned From TV"
		return 0
	}
	if {![info exists got_devices] || ![info exists device_names]} {
		Inf "Cannot Find Any Midi Input Devices On Your System"
		return 0
	}
	if {![info exists tv_stop]} {
		set tv_stop 21
	}
	if {![info exists tv_maxevents]} {
		set tv_maxevents 3000
	}
	set f .selectmidi
	if [Dlg_Create $f "MIDI In" "set pr_selmidi 0"] {
		frame $f.0
		button $f.0.q -text "Abandon" -command "set pr_selmidi 0" -highlightbackground [option get . background {}]
		button $f.0.ok -text "OK" -command "set pr_selmidi 1" -highlightbackground [option get . background {}]
		pack $f.0.ok -side left
		pack $f.0.q -side right
		pack $f.0 -side top -fill x -expand true -pady 4
		set selmidi_cnt 1
		if {[llength $device_names] > 1} {
			label $f.z -text "Select One Of The Midi Input Devices"
			pack $f.z -side top -pady 4
		}
		foreach name $device_names {
			button $f.$selmidi_cnt -text $name -command "SetMidiInTV $selmidi_cnt" -highlightbackground [option get . background {}]
			pack $f.$selmidi_cnt -side top -pady 4
			incr selmidi_cnt
		}
		if {[info exists tv_midiin] && ($tv_midiin < $selmidi_cnt)} {
			.selectmidi.$tv_midiin config -bg $evv(EMPH)
		}
		frame $f.a
		label $f.a.ll -text "Max No MIDI events to record"
		entry $f.a.e  -textvariable tv_maxevents -width 12
		frame $f.b
		label $f.b.ll -text "MIDI key triggering STOP (middle C == 60)"
		entry $f.b.e  -textvariable tv_stop -width 12
		pack $f.a.e $f.a.ll -side left
		pack $f.a -side top -pady 4 -fill x -expand true
		pack $f.b.e $f.b.ll -side left
		pack $f.b -side top -pady 4 -fill x -expand true
		frame $f.c
		label $f.c.1 -text "MIDI input is accessed\nthrough the PIANO-TYPE KEYS"
		frame $f.c.2
		MakeKeyboardKey $f.c.2 display 0
		pack $f.c.1 $f.c.2 -side left
		pack $f.c -side top -pady 10
		frame $f.d -bd 4 -bg grey0
		frame $f.d.ll  -bg grey0
		label $f.d.ll.1 -text "MIDI connectedness courtesy of Richard Orton's " -bg grey0 -fg white
		label $f.d.ll.2 -text "'Tabula Vigilans'" -fg red -bg grey0
		pack $f.d.ll.1 $f.d.ll.2 -side left
		pack $f.d.ll -side top
		label $f.d.2 -text "\n" -bg grey0
		pack $f.d.2 -side top
		pack $f.d -side top
		bind $f	<Return> {set pr_selmidi 1}
		bind $f	<Escape> {set pr_selmidi 0}
		wm resizable $f 1 1
	}
	set returnval 0
	set finished 0
	set pr_selmidi 0
	raise $f
	My_Grab 0 $f pr_selmidi
	while {!$finished} {
		tkwait variable pr_selmidi
		if {$pr_selmidi} {
			if {![info exists tv_midiin]} {
				if {[llength $device_names] == 1} {
					set tv_midiin 1
				} else {
					Inf "No Midi Device Selected"
					raise $f
					continue
				}
			}
			if {![regexp {^[0-9]+$} $tv_stop]} {
				Inf "Invalid 'Stop' Midi Value"
				raise $f
				continue
			}
			if {($tv_stop < 0) || ($tv_stop > 127)} {
				Inf "Invalid 'Stop' Midi Value"
				raise $f
				continue
			}
			if {![regexp {^[0-9]+$} $tv_maxevents]} {
				Inf "Invalid Number Of Midi Events"
				raise $f
				continue
			}
			if {($tv_maxevents < 2) || ($tv_maxevents > 6000)} {
				raise $f
				Inf "Invalid Number Of Midi Events (2 - 6000)"
				continue
			}
			if {![WriteTVConstants]} {
				Inf "Failed To Store These Values For Use In Next Session"
			}
			if {![CreateTVScript]} {
				Inf "Failed To Create New TV Script"
			} else {
				set returnval 1
			}
			set finished 1
		} else {
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	return $returnval
}

#------ This set the TV midi input device, and highlights the button related to it

proc SetMidiInTV {n} {
	global selmidi_cnt tv_midiin evv
	set cnt 1
	while {$cnt < $selmidi_cnt} {
		.selectmidi.$cnt config -bg [option get . background {}]
		incr cnt
	}
	.selectmidi.$n config -bg $evv(EMPH)
	set tv_midiin $n
}

#------ This captures the stdout output from TV: used to read the available MIDI devices on user's system

proc WriteTVData {} {
	global CDPtv tv_got tv_output

	if [eof $CDPtv] {
		catch {close $CDPtv}
		catch {unset CDPtv}
		set tv_got 1
		return
	} else {
		while {[gets $CDPtv line] >= 0} {
			set line [string trim $line]
			set thislen [string length $line]
			if {$thislen > 0} {
				lappend tv_output $line
			}
		}
	}
}			

###############################################################
#	  STORING AND LOADING USERS TV CONSTANTS TO/FROM FILE	  #
###############################################################

proc WriteTVConstants {} {
	global tv_midiin tv_stop tv_maxevents evv
	set fnam [file join $evv(CDPRESOURCE_DIR) tv$evv(CDP_EXT)]
	if [catch {open $fnam "w"} zit] {
		return 0
	}
	puts $zit $tv_midiin
	puts $zit $tv_stop
	puts $zit $tv_maxevents
	close $zit
	return 1
}

proc LoadTVConstants {} {
	global tv_midiin tv_stop tv_maxevents evv
#RWD debugging
#	Inf "calling tv as: tv$evv(CDP_EXT)"
	set fnam [file join $evv(CDPRESOURCE_DIR) tv$evv(CDP_EXT)]
# RWD 09/24 TV insists on the .tv file extension, so we can't use the default .cdp here.
#	set tvs  [file join $evv(CDPRESOURCE_DIR) tvscript$evv(CDP_EXT)]
 	set tvs  [file join $evv(CDPRESOURCE_DIR) tvscript.tv]
	if {[file exists $tvs]} {
		if [catch {file delete $tvs} zit] {
			Inf "Cannot Delete Existing TV File '$tvs': Cannot Activate Midi-Keyboard Input"
			return 0
		}
	}
	if {[file exists $fnam]} {
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot Open File '$fnam' To Read Data For TV"
			return 0
		}
		set cnt 0
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			if {![regexp {^[0-9]+$} $line] || ($line <= 0)} {
				Inf "Invalid Data ($line) On Line [expr $cnt + 1] Of File '$fnam'"
				close $zit
				return 0
			}
			set x($cnt) $line
			incr cnt
		}
		close $zit
		if {$cnt < 3} {
			Inf "Insufficient Data In File '$fnam'"		
			return 0
		}
		if {$cnt > 3} {
			WarningShow "Spurious Data At End Of File '$fnam'"		
		}
		set tv_midiin $x(0)
		set tv_stop $x(1)
		set tv_maxevents $x(2)
	} else {
		if {![SetMidiInputDeviceTV]} {
			Inf "Cannot Activate Midi-Keyboard Input"
			return 0
		} else {
			Inf "You Can Reset The Midi-Input Values From The 'System State' Menu On The Workspace"
		}
	}
	if {![file exists $tvs]} {
		if {![CreateTVScript]} {
			Inf "Cannot Activate Midi-Keyboard Input"
			return 0
		}
	}
	return 1
}

######################################################
# CREATING A TV-SCRIPT RELEVANT TO THE USER'S PARAMS #
######################################################

proc CreateTVScript {} {
	global tv_midiin tv_stop tv_maxevents evv

	if {![info exists tv_midiin] || ![info exists tv_stop] || ![info exists tv_maxevents]} {
		SetMidiInputDeviceTV
	}
	if {![info exists tv_midiin] || ![info exists tv_stop] || ![info exists tv_maxevents]} {
		return 0
	}
# RWD 09/24: TV insists on the tv extension, we can't use the default .cdp here.
#	set fnam [file join $evv(CDPRESOURCE_DIR) tvscript$evv(CDP_EXT)]
	set fnam [file join $evv(CDPRESOURCE_DIR) tvscript.tv]
	set fout [file join $evv(CDPRESOURCE_DIR) tvout]
	set pwd [pwd]
	set tv_script {}
	if [catch {open $fnam "w"} fId] {
		Inf "CANNOT OPEN FILE '$fnam' TO WRITE 'TV' SCRIPT"
		return 0
	}
	lappend tv_script "table DATA\[$tv_maxevents\]\[4\]"
	lappend tv_script ""
	lappend tv_script "start()"
	lappend tv_script "\{"
	lappend tv_script  "	storefile \"$fout\""
	lappend tv_script  "	while(pch != $tv_stop) \{"
	lappend tv_script  "		t time"
	lappend tv_script  "		xx = try(chan, pch, vel midiin)"
	lappend tv_script  "		if(xx == 1) \{"
	lappend tv_script  "			if(pch == $tv_stop) \{"
	lappend tv_script  "				break"
	lappend tv_script  "			\}"
	lappend tv_script  "			midiecho chan, pch, vel"
	lappend tv_script  "			DATA\[dndx\]\[0\] = t"
	lappend tv_script  "			DATA\[dndx\]\[1\] = chan"
	lappend tv_script  "			DATA\[dndx\]\[2\] = pch"
	lappend tv_script  "			DATA\[dndx++\]\[3\] = vel"
	lappend tv_script  "		\}"
	lappend tv_script  "		if(dndx >= $tv_maxevents) \{"
	lappend tv_script  "			break"
	lappend tv_script  "		\}"
	lappend tv_script  "	\}"
	#RWD debugging 28/24
	lappend tv_script  "    message \"      DATA size = \"  "
	
	lappend tv_script  "	start_offset = DATA\[0\]\[0\]"
	lappend tv_script  "	for(i=0; i<dimsize(DATA, 1); i+=1) \{"
	lappend tv_script  "		if(DATA\[i\]\[2\] == 0) \{"
	#RWD debugging				
	lappend tv_script  "                 probe i"
	
	lappend tv_script  "			break"
	lappend tv_script  "		\}"
	lappend tv_script  "		DATA\[i\]\[0\] -= start_offset"
	lappend tv_script  "	\}"
	lappend tv_script  "	for(i=0; i<dimsize(DATA, 1); i+=1) \{"
	lappend tv_script  "		if(DATA\[i\]\[2\] == 0) \{"
	lappend tv_script  "			break"
	lappend tv_script  "		\}"
	lappend tv_script  "		store DATA\[i\]\[0\]"
	lappend tv_script  "		storstr \" \""
	lappend tv_script  "		stori DATA\[i\]\[1\], DATA\[i\]\[2\], DATA\[i\]\[3\]"
	lappend tv_script  "		storstr \"\\n\""
	lappend tv_script  "	\}"
	lappend tv_script  "\}"
	foreach line $tv_script {
		puts $fId $line
	}
	close $fId
	return 1
}

#########################################
#	USE TV SCRIPT TO GET MIDIIN DATA	#
#########################################

#----- This procedure either calls DoTV, or calls windows with options for different versions of DoTV

proc DoTVCall {typ listing f tell} {
	global tv_durationerror tv_active fm_motifcnt tv_durationerror te_midid evv
	set tv_durationerror 0

	if {!$tv_active} {
		return 0
	}
	if {$typ == $evv(MIDITEXTURE)} {
		set fm_motifcnt 0
		GetNoteData
		if {$tv_durationerror} {
			Inf "Some Note Durations Could Not Be Calculated: They Have The Default Value '1'"
		}
		.maketextp.k.t yview moveto 1.0
		return
	} elseif {$typ == $evv(MIDISEQUENCER)} {
		GetSequencerData
		if {$tv_durationerror} {
			Inf "Some Note Durations Could Not Be Calculated: They Have The Default Value '1'"
		}
		.maketextp.k.t yview moveto 1.0
		return
	} elseif {$typ == $evv(MIDITOTABED)} {
		GetTabedData
		if {$tv_durationerror && $te_midid} {
			Inf "Some Note Durations Could Not Be Calculated: They Have The Default Value '1'"
		}
		return
	}
	DoTV $typ $listing $f $tell
	if {$tv_durationerror} {
		Inf "Some Note Durations Could Not Be Calculated: They Have The Default Value '1'"
	}
}

#----- This procedure runs "tv tvscript" and stores the midi-in data in file "tvout"
#----- It then reopens "tvout" and sends the data to the appropriate location in the Loom

proc DoTV {typ listing f tell} {
	global tv_active tv_got tv_output tv_midiin CDPtv fm_outtype fm_param1 fm_param2 prm chlist 
	global fm_motifcnt mmod pr_notedata tv_durationerror pprg sq_cnt seq_pitch seq_separate_entry 
	global sq_cnt sq_orig_sndcnt sq_real_offset seq_outvals mu evv ins pa wstk
	global te_midit te_midip te_midipp te_midia te_midiaa te_midid
	global pr_sutranspos su_transpos sutranspos
	set tv_got 0
	set tv_output {}
	if {!$tv_active} {
		return 0
	}
	set fm_outtype $typ
	
	if {!($typ == $evv(GETTROFLINE) || $typ == $evv(GETTROFTUNING))} {
		set mode $mmod
		incr mode -1
	}
# RWD debugging 29/24 looks like cmd not being constructed properly, we end up with a relative path
	set pwd [pwd]
	set cmd [file join $pwd $evv(CDPROGRAM_DIR) tv]
#	Inf "cmd = $cmd"
#	set pwd [pwd]

#RWD 27/24
#	lappend cmd "-i" "-I$tv_midiin"
    
# RWD 09/24 this creates line without adding silly braces
    append cmd " -i$tv_midiin -I "
#   RWD 09/24 TV insists on the .tv extension, we can't used the default .cdp here
#	lappend cmd [file join $pwd $evv(CDPRESOURCE_DIR) tvscript$evv(CDP_EXT)]
	lappend cmd [file join $pwd $evv(CDPRESOURCE_DIR) tvscript.tv]
#RWD
#	Inf "tv cmdline = $cmd"

	if {![NotedataType $typ]} {
		DiscolorKeyboard $f $tell
	}
	if [catch {open "|$cmd"} CDPtv] {
		ErrShow "Cannot Run tvscript: $CDPtv"
		catch {unset CDPtv}
	} else {
		fileevent $CDPtv readable WriteTVData
	}
	vwait tv_got
	if {![NotedataType $typ]} {
		RecolorKeyboard $f
	}
	set fout [file join $evv(CDPRESOURCE_DIR) tvout]
	if {![file exists $fout]} {
		Inf "No Midi Data ($fout)"
		return 0
	}
	if [catch {open $fout "r"} zit] {
		Inf "Cannot Open File '$fnam' To Read Midi Data"
		return 0
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		set cnt 0
		set line [split $line]
		catch {unset nuline}
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			lappend nuline $item
			incr cnt
		}
		if {$cnt != 4} {
			Inf "Invalid Data Returned By Tv"
			close $zit
			return 0
		}
		lappend outvals $nuline
	}
	close $zit

	if {![info exists outvals]} {
		if {($typ == $evv(TEXTUREMOTIF)) && ($fm_motifcnt >= 1)} {
			return -1
		} else {
			if {($typ == $evv(GETTROFLINE)) || ($typ == $evv(GETTROFTUNING)) || ($typ == $evv(GETTROFMOTIF)) || ($typ == $evv(GETTROFTIMING))} {
				TVTermination
				Inf "No data entered"
			} else {
				Inf "No Midi Data Read\n\n*** Close This Window Before Attempting To Record Any More Midi Data ***"
			}
			return 0
		}
	}
					;#		USE NOTE-OFFS TO CALC DURATIONS
	set cnt 0
	set len [llength $outvals]
	set pitches {}
	while {$cnt < $len} {
		set outval [lindex $outvals $cnt]
		if {[lindex $outval $evv(TV_VEL)] > 0} {
			lappend pitches [lindex $outval $evv(TV_PITCH)]
		} else {
			set pitchoff [lindex $outval $evv(TV_PITCH)]
			set k [ReverseSearch $pitches $pitchoff]
			if {$k >= 0} {
				set outvalon [lindex $outvals $k]
# RWD 10-2024: this is where MIDI durations are calculated. Need to add code to reduce to (say) 4 decimal places
# can use "set tcl_precision" - but where?
				set dur [expr [lindex $outval $evv(TV_TIME)] - [lindex $outvalon $evv(TV_TIME)]]
				if {$dur > 0} {
					lappend outvalon $dur
					set outvals [lreplace $outvals $k $k $outvalon]
				}
			}
			set outvals [lreplace $outvals $cnt $cnt]
			incr cnt -1
			incr len -1
		}
		incr cnt
	}
	set len $cnt
	set cnt 0
	while {$cnt < $len} {				;#	mend any notes without a note off
		set outval [lindex $outvals $cnt]
		if {[llength $outval] < 5} {
			lappend outval 1
			if {($fm_outtype != $evv(TEXTURENOTES)) && ($fm_outtype != $evv(MIDITOCALC))} {
				set tv_durationerror 1
			}
			set outvals [lreplace $outvals $cnt $cnt $outval]
		}
		incr cnt
	}
	if {$fm_outtype == $evv(TEXTUREHF)} {
		if {($mode == $evv(TEX_HFS)) || ($mode == $evv(TEX_HSS))} {
			set outvals [SynchroniseMidiChords $outvals]
		} elseif {($mode == $evv(TEX_HF)) || ($mode == $evv(TEX_HS))} {
			set outvals [ZeroMidiChord $outvals]
		}
	} elseif {$fm_outtype == $evv(GETTROFTUNING)} {
		set outvals [SynchroniseMidiChords $outvals]
	}
	switch -regexp -- $fm_outtype \
		^$evv(MIDITOPARAM)$ {
			set pcnt $listing
			set outval [lindex [lindex $outvals 0] $evv(TV_PITCH)]
			set prm($pcnt)  [FromMidi_GenOutval $outval]
		} \
		^$evv(MIDITOTRANSPOSPARAM)$ {
			if {$pprg != $evv(PSOW_EXTEND)} {
				return
			}
			set pcnt $listing
			if {[llength $outvals] <= 1} {
				Inf "Insufficient Midi Values: Did You Remember To Enter The Reference Pitch First ??"
				return 0
			}
			if {![IsNumeric $prm(1)] || ($prm(1) < 0)} {
				Inf "Freeze Time Parameter Must Be Set Before Proceeding"
				return 0
			}
			if {![IsNumeric $prm(2)] || ($prm(2) < 0)} {
				Inf "Output Duration Of Whole Sound Must Be Set Before Proceeding"
				return 0
			}
			set frztime $prm(1)
			if {$ins(create)} {
				set fnam [lindex $ins(chlist) 0]
			} else {
				set fnam [lindex $chlist 0]
			}
			set filedur $pa($fnam,$evv(DUR))
			set frzdur [expr $prm(2) - $filedur]
			set frzend [expr $frztime + $frzdur]

			set fnam [file rootname [file tail $fnam]]
			set transfnam $fnam
			append transfnam "_transp" [GetTextfileExtension brk]
			if {[file exists $transfnam]} {
				set msg "Transposition File '$transfnam' Exists: Overwrite It ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					return 0
				}
			}
			set g .transpos
			if [Dlg_Create $g "SUSTAIN PITCHES ??" "set pr_sutranspos 0"] {
				frame $g.0
				frame $g.1
				button $g.0.sus -text "Sustain pitches" -command "set pr_sutranspos 1" -highlightbackground [option get . background {}]
				button $g.0.gli -text "DON'T Sustain Pitches" -command "set pr_sutranspos 0" -highlightbackground [option get . background {}]
				pack $g.0.sus -side left
				pack $g.0.gli -side right
				pack $g.0 -side top -fill x -expand true
				label $g.1.0 -text "As far as "
				radiobutton $g.1.1  -text ".01" -variable sutranspos -value 1  -command "set su_transpos .01"
				radiobutton $g.1.2  -text ".02" -variable sutranspos -value 2  -command "set su_transpos .02"
				radiobutton $g.1.3  -text ".03" -variable sutranspos -value 3  -command "set su_transpos .03"
				radiobutton $g.1.4  -text ".04" -variable sutranspos -value 4  -command "set su_transpos .04"
				radiobutton $g.1.5  -text ".05" -variable sutranspos -value 5  -command "set su_transpos .05"
				radiobutton $g.1.6  -text ".06" -variable sutranspos -value 6  -command "set su_transpos .06"
				radiobutton $g.1.7  -text ".07" -variable sutranspos -value 7  -command "set su_transpos .07"
				radiobutton $g.1.8  -text ".08" -variable sutranspos -value 8  -command "set su_transpos .08"
				radiobutton $g.1.9  -text ".09" -variable sutranspos -value 9  -command "set su_transpos .09"
				radiobutton $g.1.10 -text ".10" -variable sutranspos -value 10 -command "set su_transpos .10"
				label $g.1.11 -text "Secs before next event"
				pack $g.1.0 $g.1.1 $g.1.2 $g.1.3 $g.1.4 $g.1.5 $g.1.6 $g.1.7 $g.1.8 $g.1.9 $g.1.10 $g.1.11 -side left
				pack $g.1 -side top -pady 2
				wm resizable $g 1 1
			}
			set sutranspos 0
			catch {unset su_transpos}
			set finished 0
			set pr_sutranspos 0
			raise $g
			My_Grab 0 $g pr_sutranspos
			while {!$finished} {
				tkwait variable pr_sutranspos
				if {$pr_sutranspos} {
					if {![info exists su_transpos]} {
						Inf "No Sustain Value Selected"
						continue
					}
					set finished 1
				} else {
					catch {unset su_transpos}
					set finished 1
				}
			}
			My_Release_to_Dialog $g
			Dlg_Dismiss $g
			if [catch {open $transfnam "w"} zitt] {
				Inf "Cannot Open File '$transfnam' To Write Transposition Data"
				return 0
			}
			set outlen [llength $outvals]
			set zval [lindex $outvals 0]
			set refmidi [lindex $zval $evv(TV_PITCH)]						;#	Pitch of reference value
			set zval [lindex $outvals 1]									;#	Time of first TRUE event
			set offsettime [lindex $zval $evv(TV_TIME)]						;#	Measure times from 1st MIDI val entered AFTER ref val,
			foreach zval [lrange $outvals 1 end] {
				set trans [expr [lindex $zval $evv(TV_PITCH)] - $refmidi]	;#	Calculate trasposition relative to ref pitch
				set timeval [expr [lindex $zval $evv(TV_TIME)] - $offsettime]	;#	Pitch data times are measured from START of FREEZE  portion
				if {[info exists su_transpos]} {							;#	If notes sustained ....
					if {[info exists lasttrans]} {
						set pretime [expr $timeval - $su_transpos]
						if {$pretime > $lasttimeval} {
							set line [list $pretime $lasttrans]	
							puts $zitt $line								;#	Save end of sustained value
						}
					}
					set lasttrans $trans
					set lasttimeval $timeval
				}
				set line [list $timeval $trans]
				puts $zitt $line											;#	Save transpos value in transpos file
			}
			close $zitt										
			FileToWkspace $transfnam 0 0 0 0 1
			set prm($pcnt) $transfnam										;#	Use transpos datafile as parameter on parampage

			set envfnam $fnam
			append envfnam "_env" [GetTextfileExtension brk]
			if {[file exists $envfnam]} {
				set msg "Envelope File '$envfnam' Exists: Overwrite It ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					return 0
				}
			}
			if [catch {open $envfnam "w"} zite] {
				Inf "Cannot Open File '$envfnam' To Write Envelope Data"
				return 1
			}
			set zval [lindex $outvals end]									;#	Extende last note if ness
			set lasttime [expr [lindex $zval $evv(TV_TIME)] - $offsettime]
			set lastdur [lindex $zval $evv(TV_DUR)]
			set lastsnd [expr $lasttime + $lastdur]
			if {$lastsnd <= $frzdur} {
				set msg "Extend Last Note To Meet End-Portion Of Sound ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "yes"} {
					set nudur [expr ($frzdur + $offsettime) - $lasttime]
					set nudur [expr $nudur + 1.0]
					set zval [lreplace $zval $evv(TV_DUR) $evv(TV_DUR) $nudur]
					set outvals [lreplace $outvals end end $zval]
				}
			}

			set done 0
			set nextvalcnt 2												;#	Count from the NEXT value (after the 1st true value = value 1)
			foreach zval [lrange $outvals 1 end] {
				set timeval [lindex $zval $evv(TV_TIME)]					;#	MIDI data times are measured from START of FREEZE portion
				set thistime [expr $timeval - $offsettime]					;#	Find time relative to start of freeze portion.
				set thistime [expr $thistime + $frztime]					;#	Envelope vals must be measured from start of file
				set velval  [lindex $zval $evv(TV_VEL)]
				set durval  [lindex $zval $evv(TV_DUR)]
				set line [list $thistime $velval]
				lappend envlines $line
				set gapped 1												;#	Initially assume (silent) gaps between notes
				if {$nextvalcnt < $outlen} {								;#	Ensure note duration NOT greater than gap between notes
					set nextzval [lindex $outvals $nextvalcnt]				;#	i.e. this is a MONO stream
					set nexttimeval [lindex $nextzval $evv(TV_TIME)]
					set nexttime [expr $nexttimeval - $offsettime]
					if {$nexttime >= $frzdur} {								;#	If midi values beyond end of frozen portion,
						set nexttimeval [expr $frzdur + $offsettime]		;#	set next val at end of frozen portion, for calc purposes
						set done 1											;#	but mark envelope creation as completed.
					}
					set nexttime [expr $nexttime + $frztime]	
					set step [expr ($nexttimeval - $timeval) - 0.02]		;#	Check if room for a silent gap between this and next note
					if {$durval >= $step} {
						set gapped 0										;#	If not, mark no gap between notes
					}
				}
				if {$gapped} {
					set endtime [expr $thistime + $durval]					;#	Force a fall to silence
					set line [list $endtime $velval]
					lappend envlines $line
					set gapstt [expr $endtime + 0.01]
					set line [list $gapstt 0]
					lappend envlines $line
					if {$nextvalcnt >= $outlen} {							;#	If reached end of file, need to set "end of gap" value
						set nexttime $frzend
					}
					set gapend [expr $nexttime - 0.01]
					if {$gapend > $gapstt} {
						set line [list $gapend 0]
						lappend envlines $line
					}
				}
				incr nextvalcnt
				if {$done} {												;#	if reached end of frozen portion, quit reading data
					break											
				}
			}
			set maxlev 0
			foreach line $envlines {
				set thislev [lindex $line 1]
				if {$thislev > $maxlev} {
					set maxlev $thislev
				}
			}
			if {$maxlev <= 0} {
				Inf "No Significant Level Found"
			} else {
				set len [llength $envlines]
				set cnt 0
				while {$cnt < $len} {
					set line [lindex $envlines $cnt]
					set thislev [lindex $line 1]
					set thislev [expr double($thislev)/double($maxlev)]		;#	Normalise envelope 
					set line [lreplace $line 1 1 $thislev]
					set envlines [lreplace $envlines $cnt $cnt $line]
					incr cnt
				}
				set sttimes {}
				if {$frztime > 0.0} {
					set line [list 0 1]										;#	Insert level 1.0 for start of sound (before freeze)
					lappend sttlines $line
					if {$frztime > 0.01} {
						set timeval [expr $frztime - 0.01]
						set line [list $timeval 1]
						lappend sttlines $line
					}
				}
				set envlines [concat $sttlines $envlines]

				set lasttime [lindex [lindex $envlines end] 0]				;#	Force level of end of src to be orig level
				set endtime [expr $lasttime + 0.01]
				set line [list $endtime 1]
				lappend envlines $line
				set line [list 10000 1]
				lappend envlines $line
				foreach line $envlines {
					puts $zite $line
				}
				close $zite
				FileToWkspace $envfnam 0 0 0 0 1
				set msg "Apply Loudness Envelope From MIDI Entry ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "yes"} {
					set prm(7) $envfnam
				}
			} 
		} \
		^$evv(GETTROFLINE)$ {
			catch {unset segment(pitches)}
			set outval [lindex $outvals 0]
			set segtime [lindex $outval $evv(TV_TIME)]
			set segvals [lindex $outval $evv(TV_PITCH)]
			foreach outval [lrange $outvals 1 end] {
				set thissegtime [lindex $outval $evv(TV_TIME)]
				if {[Flteq $thissegtime $segtime]}  {
					Inf "Line of single pitches only: do not use chords"
					return 0
				}
				lappend segvals [lindex $outval $evv(TV_PITCH)]
				set segtime $thissegtime
			}
			set segment(pitches) $segvals
			if {[llength $segment(pitches)] > $segment(tuningcnt)} {
				Inf "Too many notes (need $segment(tuningcnt))"
				return 0
			} elseif {[llength $segment(pitches)] < $segment(tuningcnt)} {
				Inf "Too few notes (need $segment(tuningcnt))"
				return 0
			}
		} \
		^$evv(GETTROFTUNING)$ {
			catch {unset segment(chords)}
			set outval [lindex $outvals 0]
			set segtime [lindex $outval $evv(TV_TIME)]
			set segvals [lindex $outval $evv(TV_PITCH)]
			foreach outval [lrange $outvals 1 end] {
				set thissegtime [lindex $outval $evv(TV_TIME)]
				if {[Flteq $thissegtime $segtime]}  {
					lappend segvals [lindex $outval $evv(TV_PITCH)]
				} else {
					lappend segment(chords) $segvals
					set segvals [lindex $outval $evv(TV_PITCH)]
					set segtime $thissegtime
				}
			}
			lappend segment(chords) $segvals
			if {[llength $segment(chords)] == 1} {						;#	Either 1 chord or segment(tuningcnt) chords
				set segvals $segment(chords)
				set kkk 1
				while {$kkk < $segment(tuningcnt)} {
					lappend segment(chords) $segvals
					incr kkk
				}
			} elseif {[llength $segment(chords)] > $segment(tuningcnt)} {
				Inf "Too many chords (need $segment(tuningcnt))"
				return 0
			} elseif {[llength $segment(chords)] < $segment(tuningcnt)} {
				Inf "Too few chords (need $segment(tuningcnt))"
				return 0
			}
		} \
		^$evv(MIDIPITCHES)$ {
			foreach outval $outvals {
				set outval [lindex $outval $evv(TV_PITCH)]
				set outval [FromMidi_GenOutval $outval]
				$listing insert end "$outval\n"
			}
		} \
		^$evv(MIDIPITCHVEL)$ {
			set cnt 0
			foreach outval $outvals {
				set outtime [lindex $outval $evv(TV_TIME)]
				if {$cnt == 0} {
					set timedec $outtime
				}
				set outtime [expr $outtime - $timedec]
				set outval [lindex $outval $evv(TV_PITCH)]
				set outval [FromMidi_GenOutval $outval]
				set outstr "$outtime  $outval\n"
				$listing insert end $outstr
				incr cnt
			}
		} \
		^$evv(MIDIFILT)$ {	;#	Data output, with associated "1" amplitudes, at cursor on listing
			set outval ""
			foreach val $outvals {
				set val [lindex $val $evv(TV_PITCH)]
				set val [FromMidi_GenOutval $val]
				append outval "  " $val "  " "1"
			}
			$listing insert insert "$outval"
		} \
		^$evv(TEXTURENOTES)$ {	;#	List of pitches of input files to 'texture'
			set k [llength $chlist]
			if {[llength $outvals] != $k} {
				if {$k == 1} {
					Inf "There Is Only One Input Soundfile But You Entered [llength $outvals] Notes\n\nPlease Try Again"
				} else {
					Inf "There Are $k Input Soundfiles But You Entered [llength $outvals] Notes\n\nPlease Try Again"
				}
				return 0
			}
			if {$pprg == $evv(SEQUENCER)} {
				set val [lindex $outvals 0]
				set seq_pitch [lindex $val $evv(TV_PITCH)]
			} else {	
				set outval "" 
				foreach val $outvals {
					set val [lindex $val $evv(TV_PITCH)]
					append outval $val "  "
				}
				set outval [string trim $outval]
				$listing insert end "$outval\n"
			}
		} \
		^$evv(TEXTURELINE)$ - \
		^$evv(TEXTUREHF)$   - \
		^$evv(TEXTUREMOTIF)$ {	;#	Lines defining a melodic line (timed or untimed) or HF (timed or untimed) or a motif for 'texture'
			set outval "#[llength $outvals]" 
			$listing insert end "$outval\n"
			foreach zval $outvals {
				set outval ""
				set val [lindex $zval $evv(TV_TIME)]
				append outval "$val  1  "
				set val [lindex $zval $evv(TV_PITCH)]
				append outval "$val  "
				set val [lindex $zval $evv(TV_VEL)]
				append outval "$val  "
				set val [lindex $zval $evv(TV_DUR)]
				append outval "$val"
				$listing insert end "$outval\n"
			}
			if {$fm_outtype == $evv(TEXTUREMOTIF)} {
				incr fm_motifcnt
			}
		} \
		^$evv(SEQUENCEMOTIF)$ {	;#	Lines defining a melodic line (timed or untimed) or HF (timed or untimed) or a motif for 'texture'
			if {$pprg == $evv(SEQUENCER)} {
				foreach zval $outvals {
					set outval ""
					set val [lindex $zval $evv(TV_TIME)]
					append outval "$val  "
					set val [lindex $zval $evv(TV_PITCH)]
					set val [expr $val - $seq_pitch]
					append outval "$val  "
					set val [lindex $zval $evv(TV_VEL)]
					set val [expr double($val) / double($mu(MIDIMAX))]
					append outval "$val"
					$listing insert end "$outval\n"
				}
			} elseif {$seq_separate_entry} {
				if {$sq_cnt == 1} {
					set cnt 0
					foreach zval $outvals {
						set zval [lreplace $zval $evv(TV_CHAN) $evv(TV_CHAN) $sq_cnt]
						set outvals [lreplace $outvals $cnt $cnt $zval]
						incr cnt
					}
					lappend seq_outvals $outvals
				} else {
					set cnt 0
					foreach zval $outvals {
						set time [lindex $zval $evv(TV_TIME)]
						set time [expr $time + $sq_real_offset]
						set zval [lreplace $zval $evv(TV_TIME) $evv(TV_TIME) $time]
						set zval [lreplace $zval $evv(TV_CHAN) $evv(TV_CHAN) $sq_cnt]
						set outvals [lreplace $outvals $cnt $cnt $zval]
						incr cnt
					}
					lappend seq_outvals $outvals
					if {$sq_cnt == $sq_orig_sndcnt} {
						set outvals {}
						set cnt 0
						foreach zvals $seq_outvals {
							foreach zval $zvals {
								lappend outvals $zval
								incr cnt
							}
						}
						set len $cnt
						set len_less_one [expr $len - 1]
						set n 0
						while {$n < $len_less_one} {
							set n_outval [lindex $outvals $n]
							set n_time [lindex $n_outval $evv(TV_TIME)]
							set m $n
							incr m
							while {$m < $len} {
								set m_outval [lindex $outvals $m]
								set m_time [lindex $m_outval $evv(TV_TIME)]
								if {$m_time < $n_time} {
									set outvals [lreplace $outvals $n $n $m_outval]
									set outvals [lreplace $outvals $m $m $n_outval]
									set n_outval $m_outval
									set n_time $m_time
									incr m -1
								}
								incr m
							}
							incr n
						}
						foreach zval $outvals {
							set val [lindex $zval $evv(TV_CHAN)]
							set outval "$val  "
							set val [lindex $zval $evv(TV_TIME)]
							append outval "$val  "
							set val [lindex $zval $evv(TV_PITCH)]
							append outval "$val  "
							set val [lindex $zval $evv(TV_VEL)]
							set val [expr double($val) / double($mu(MIDIMAX))]
							append outval "$val  "
							set val [lindex $zval $evv(TV_DUR)]
							append outval "$val"
							$listing insert end "$outval\n"
						}
					}
				}
			} else {
				foreach zval $outvals {
					set outval "$sq_cnt  "
					set val [lindex $zval $evv(TV_TIME)]
					append outval "$val  "
					set val [lindex $zval $evv(TV_PITCH)]
					append outval "$val  "
					set val [lindex $zval $evv(TV_VEL)]
					set val [expr double($val) / double($mu(MIDIMAX))]
					append outval "$val  "
					set val [lindex $zval $evv(TV_DUR)]
					append outval "$val"
					$listing insert end "$outval\n"
				}
			}
		} \
		^$evv(MIDITOCALC)$ {	;#	Data output, with associated "1" amplitudes, at cursor on listing
			set val [lindex $outvals 0]
			set val [lindex $val $evv(TV_PITCH)]
			InputMidiToCalc $val
		} \
		^$evv(MIDITOTABED)$ {	;#	Data output, with associated "1" amplitudes, at cursor on listing
			foreach zval $outvals {
				set outval ""
				if {$te_midit} {
					set time [lindex $zval $evv(TV_TIME)]
					append outval "$time "
				}
				if {$te_midip} {
					set pitch [lindex $zval $evv(TV_PITCH)]
					if {$te_midipp} {
						set pitch [MidiToHz $pitch]
					}
					append outval "$pitch "
				}
				if {$te_midia} {
					set amp [lindex $zval $evv(TV_VEL)]
					if {$te_midiaa > 0} {
						set amp [expr double($amp) / double($mu(MIDIMAX))]
					}
					append outval "$amp "
				}
				if {$te_midid} {
					set dur [lindex $zval $evv(TV_DUR)]
					append outval $dur
				}
				set outval [string trim $outval]
				$listing insert end $outval
			}
		} \
		^$evv(GETTROFMOTIF)$ {	;#	Lines defining a timed melodic line for Voicebox
			catch {unset segment(ocl)}
			foreach zval $outvals {
				set line {}
				set val [lindex $zval $evv(TV_TIME)]
				lappend line $val
				set val [lindex $zval $evv(TV_PITCH)]
				lappend line $val
				lappend segment(ocl) $line				;#	time/pitch pairs
			}
		} \
		^$evv(GETTROFTIMING)$ {	;#	Lines defining a timed melodic line for Voicebox
			catch {unset segment(ocl)}
			foreach zval $outvals {
				set val [lindex $zval $evv(TV_TIME)]
				lappend segment(ocl) $val				;#	times only
			}
		}

	return 1
}

#---- This function generates appropriate numeric vals from the input midi (->hz, -> ms delay, or plain midi)

proc FromMidi_GenOutval {outval} {
	global mmod pprg evv
	set mode $mmod
	incr mode -1
	switch -regexp -- $pprg \
		^$evv(OCTVU)$ - \
		^$evv(PICK)$  - \
		^$evv(PITCH)$ - \
		^$evv(SYNTH_WAVE)$ - \
		^$evv(SYNTH_SPEC)$ {	;# FREQ VAL OUT
			set outval [DecPlaces [MidiToHz $outval] 4]
		} \
		^$evv(TUNE)$ - \
		^$evv(FLTBANKV)$ {		;# FREQ VAL OUT
			if {$mode == 0} {
				set outval [DecPlaces [MidiToHz $outval] 4]
			}
		} \
		^$evv(MOD_REVECHO)$ {
			if {$mode != $evv(MOD_STADIUM)} {	;#	DELAY TIME in MS OUT
				set outval [MidiToHz $outval]
				set outval [expr (1.0 / $outval) * $evv(SECS_TO_MS)]
			}
		}

	return $outval
}

#----- 

proc NotedataType {typ} {
	global evv
	switch -regexp -- $typ \
		^$evv(TEXTURENOTES)$ - \
		^$evv(TEXTURELINE)$  - \
		^$evv(TEXTUREHF)$    - \
		^$evv(TEXTUREMOTIF)$ - \
		^$evv(GETTROFLINE)$ - \
		^$evv(GETTROFTUNING)$ - \
		^$evv(GETTROFMOTIF)$ - \
		^$evv(GETTROFTIMING)$ - \
		^$evv(SEQUENCEMOTIF)$ {
			return 1
		}

	return 0
}
		
proc ZeroMidiChord {outvals } {
	global evv
	set cnt 0
	set pitches {}
	set len [llength $outvals]
	while {$cnt < $len} {
		set outval [lindex $outvals $cnt]
		set pitch [lindex $outval $evv(TV_PITCH)]
		if {[lsearch $pitches $pitch] >= 0} {
			set outvals [lreplace $outvals $cnt $cnt]
			incr cnt -1
			incr len -1
		} else {
			lappend pitches $pitch
			set outval [concat 0 [lrange $outval 1 end]]
			set outvals [lreplace $outvals $cnt $cnt $outval]
		}
		incr cnt
	}
	return $outvals
}

proc SynchroniseMidiChords {outvals } {
	global evv
	set syncing -1
	set cnt 0
	foreach thisoutval $outvals {
		set time [lindex $thisoutval $evv(TV_TIME)]
		if {$cnt > 0} {
			if {$syncing < 0} {
				if {[expr $time - $lasttime] < $evv(MIDISYNCERROR)} {
					set syncing $cnt
					set synctime $lasttime
				}
			} elseif {[expr $time - $lasttime] >= $evv(MIDISYNCERROR)} {
				while {$syncing < $cnt} {
					set thatoutval [lindex $outvals $syncing]
					set thatoutval [lreplace $thatoutval $evv(TV_TIME) $evv(TV_TIME) $synctime]
					set outvals [lreplace $outvals $syncing $syncing $thatoutval]
					incr syncing
				}
				set syncing -1
			}
		}
		set lasttime $time
		incr cnt
	}
	if {$syncing >= 0} {
		while {$syncing < $cnt} {
			set thatoutval [lindex $outvals $syncing]
			set thatoutval [lreplace $thatoutval $evv(TV_TIME) $evv(TV_TIME) $synctime]
			set outvals [lreplace $outvals $syncing $syncing $thatoutval]
			incr syncing
		}
	}
	return $outvals
}

####################################
# CREATING A KEYBOARD-STYLE BUTTON #
####################################

#-- Determines where keyboard-style buttons will appear on parampage param-bars

proc Midiable {pcnt} {
	global tv_active pprg mmod evv
	if {!$tv_active} {
		return 0
	}
	set mode $mmod
	incr mode -1
	switch -regexp -- $pprg \
		^$evv(OCTVU)$ {
			if {$pcnt == 1} {
				return 1
			}
		} \
		^$evv(PICK)$ {
			if {$pcnt == 0} {
				return 1
			}
		} \
		^$evv(PITCH)$ {
			if {($pcnt == 4) || ($pcnt == 5)} {
				return 1
			}
		} \
		^$evv(SPEC_REMOVE)$ {
			if {($pcnt == 0) || ($pcnt == 1)} {
				return 1
			}
		} \
		^$evv(MOD_REVECHO)$ {
			if {$mode != $evv(MOD_STADIUM)} {
				if {$pcnt == 0} {
					return 1
				}
			}
		} \
		^$evv(SIMPLE_TEX)$ - \
		^$evv(TEX_MCHAN)$  - \
		^$evv(TIMED)$	   - \
		^$evv(GROUPS)$	   - \
		^$evv(TGROUPS)$	   - \
		^$evv(DECORATED)$  - \
		^$evv(PREDECOR)$   - \
		^$evv(POSTDECOR)$  - \
		^$evv(ORNATE)$	   - \
		^$evv(PREORNATE)$  - \
		^$evv(POSTORNATE)$ - \
		^$evv(MOTIFS)$	   - \
		^$evv(TMOTIFS)$	   - \
		^$evv(MOTIFSIN)$   - \
		^$evv(TMOTIFSIN)$ {
			if {($pcnt == 11) || ($pcnt == 12)} {
				return 1
			}
		} \
		^$evv(SYNTH_WAVE)$ {
			if {$pcnt == 3} {
				return 1
			}
		} \
		^$evv(SYNTH_SPEC)$ {
			if {$pcnt == 1} {
				return 1
			}
		} \
		^$evv(PSOW_EXTEND)$ {
			if {$pcnt == 6} {
				return 2
			}
		}

	return 0
}

#-- Determines where keyboard-style buttons will appear on parampage param-bars

proc MidiBrkable {pcnt} {
	global pprg mmod tv_active evv
	if {!$tv_active} {
		return 0
	}
	set mode $mmod
	incr mode -1
	switch -regexp -- $pprg \
		^$evv(SIMPLE_TEX)$ - \
		^$evv(TEX_MCHAN)$  - \
		^$evv(TIMED)$	   - \
		^$evv(GROUPS)$	   - \
		^$evv(TGROUPS)$	   - \
		^$evv(DECORATED)$  - \
		^$evv(PREDECOR)$   - \
		^$evv(POSTDECOR)$  - \
		^$evv(ORNATE)$	   - \
		^$evv(PREORNATE)$  - \
		^$evv(POSTORNATE)$ - \
		^$evv(MOTIFS)$	   - \
		^$evv(TMOTIFS)$	   - \
		^$evv(MOTIFSIN)$   - \
		^$evv(TMOTIFSIN)$ {
			if {($pcnt == 11) || ($pcnt == 12)} {
				return 1
			}
		} \
		^$evv(SYNTH_WAVE)$ {
			if {$pcnt == 3} {
				return 1
			}
		} \
		^$evv(SYNTH_SPEC)$ {
			if {$pcnt == 1} {
				return 1
			}
		}

	return 0
}

proc MidiFiltData {pcnt} {
	global tv_active pprg mmod evv
	if {!$tv_active} {
		return 0
	}
	set mode $mmod
	incr mode -1
	switch -regexp -- $pprg \
		^$evv(FLTBANKV)$ - \
		^$evv(FLTBANKV2)$ {
			if {($pcnt == 0)} {
				return 1
			}
		} \

	return 0
}

#---- Creates small key like a keyboard which will activate TV, or bring up a dialog

proc MakeKeyboardKey {f typ listing} {
	global pr_kbd tv_active
	if {!$tv_active && ($typ != "display")} {
		return
	}
	frame $f.0 -height 1 -bg black
	frame $f.1 -height 12
	frame $f.2 -height 12
	frame $f.3 -height 1 -bg black
	frame $f.1.0 -width 1 -height 12 -bg black
	frame $f.1.1 -width 7 -height 12 -bg white
	frame $f.1.2 -width 8 -height 12 -bg black
	frame $f.1.3 -width 4 -height 12 -bg white
	frame $f.1.4 -width 8 -height 12 -bg black
	frame $f.1.5 -width 7 -height 12 -bg white
	frame $f.1.6 -width 1 -height 12 -bg black
	pack $f.1.0 $f.1.1 $f.1.2 $f.1.3 $f.1.4 $f.1.5 $f.1.6 -side left
	frame $f.2.0 -width 1  -height 8 -bg black
	frame $f.2.1 -width 11 -height 8 -bg white
	frame $f.2.2 -width 1  -height 8 -bg black
	frame $f.2.3 -width 10 -height 8 -bg white
	frame $f.2.4 -width 1  -height 8 -bg black
	frame $f.2.5 -width 11 -height 8 -bg white
	frame $f.2.6 -width 1  -height 8 -bg black
	pack $f.2.0 $f.2.1 $f.2.2 $f.2.3 $f.2.4 $f.2.5 $f.2.6 -side left
	pack $f.0 -side top -fill x -expand true
	pack $f.1 $f.2 -side top
	pack $f.3 -side top -fill x -expand true
	if {$typ == "display"} {
		return
	}
	if {$typ >= 0} {
		bind $f.0 <ButtonPress-1>	"DoTVCall $typ $listing $f 1"
		bind $f.1.0 <ButtonPress-1> "DoTVCall $typ $listing $f 1"
		bind $f.1.1 <ButtonPress-1> "DoTVCall $typ $listing $f 1"
		bind $f.1.2 <ButtonPress-1> "DoTVCall $typ $listing $f 1"
		bind $f.1.3 <ButtonPress-1> "DoTVCall $typ $listing $f 1"
		bind $f.1.4 <ButtonPress-1> "DoTVCall $typ $listing $f 1"
		bind $f.1.5 <ButtonPress-1> "DoTVCall $typ $listing $f 1"
		bind $f.1.6 <ButtonPress-1> "DoTVCall $typ $listing $f 1"
		bind $f.2.0 <ButtonPress-1> "DoTVCall $typ $listing $f 1"
		bind $f.2.1 <ButtonPress-1> "DoTVCall $typ $listing $f 1"
		bind $f.2.2 <ButtonPress-1> "DoTVCall $typ $listing $f 1"
		bind $f.2.3 <ButtonPress-1> "DoTVCall $typ $listing $f 1"
		bind $f.2.4 <ButtonPress-1> "DoTVCall $typ $listing $f 1"
		bind $f.2.5 <ButtonPress-1> "DoTVCall $typ $listing $f 1"
		bind $f.2.6 <ButtonPress-1> "DoTVCall $typ $listing $f 1"
		bind $f.3   <ButtonPress-1> "DoTVCall $typ $listing $f 1"
	} else {
		bind $f.0 <ButtonPress-1>	"TVChoice $listing $f $typ"
		bind $f.1.0 <ButtonPress-1> "TVChoice $listing $f $typ"
		bind $f.1.1 <ButtonPress-1> "TVChoice $listing $f $typ"
		bind $f.1.2 <ButtonPress-1> "TVChoice $listing $f $typ"
		bind $f.1.3 <ButtonPress-1> "TVChoice $listing $f $typ"
		bind $f.1.4 <ButtonPress-1> "TVChoice $listing $f $typ"
		bind $f.1.5 <ButtonPress-1> "TVChoice $listing $f $typ"
		bind $f.1.6 <ButtonPress-1> "TVChoice $listing $f $typ"
		bind $f.2.0 <ButtonPress-1> "TVChoice $listing $f $typ"
		bind $f.2.1 <ButtonPress-1> "TVChoice $listing $f $typ"
		bind $f.2.2 <ButtonPress-1> "TVChoice $listing $f $typ"
		bind $f.2.3 <ButtonPress-1> "TVChoice $listing $f $typ"
		bind $f.2.4 <ButtonPress-1> "TVChoice $listing $f $typ"
		bind $f.2.5 <ButtonPress-1> "TVChoice $listing $f $typ"
		bind $f.2.6 <ButtonPress-1> "TVChoice $listing $f $typ"
		bind $f.3   <ButtonPress-1> "TVChoice $listing $f $typ"
	}
}

proc TVChoice {listing f typ} {
	global pr_tvchoice wstk tv_stop evv

	switch -- $typ {
		-2 {
			set msg "Enter New Midi Pitches At Cursor ? (Default : Transpose All Existing Pitches)"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]

			if {$choice == "no"} {
				TransposeVaribankFilterInSitu $listing
			} else {
				set typ $evv(MIDIFILT)
				Inf "TO STOP, Hit MIDI key = $tv_stop"
				DoTVCall $typ $listing $f 0
			}
		}
		default {	;# currently '-1'
			set msg "Record Pitches Only (Otherwise Record Time and Pitch) ?"
			append msg "\n\nTO STOP, Hit MIDI key = $tv_stop"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				set typ $evv(MIDIPITCHVEL)
			} else {
				set typ $evv(MIDIPITCHES)
			}
			DoTVCall $typ $listing $f 0
		}
	}
}

proc DiscolorKeyboard {f tell} {
	global tv_stop fm_outtype evv
	$f.1.0 config -bg white
	$f.1.1 config -bg black
	$f.1.2 config -bg white
	$f.1.3 config -bg black
	$f.1.4 config -bg white
	$f.1.5 config -bg black
	$f.1.6 config -bg white
	$f.2.0 config -bg white
	$f.2.1 config -bg black
	$f.2.2 config -bg white
	$f.2.3 config -bg black
	$f.2.4 config -bg white
	$f.2.5 config -bg black
	$f.2.6 config -bg white
	if {$tell} {
		Inf "Waiting for MIDI input\n\nTO STOP, Hit MIDI key = $tv_stop"
		if {$fm_outtype == $evv(MIDITOCALC)} {
			raise .cpd
		}
	}
}

proc RecolorKeyboard {f} {
	$f.1.0 config -bg black
	$f.1.1 config -bg white
	$f.1.2 config -bg black
	$f.1.3 config -bg white
	$f.1.4 config -bg black
	$f.1.5 config -bg white
	$f.1.6 config -bg black
	$f.2.0 config -bg black
	$f.2.1 config -bg white
	$f.2.2 config -bg black
	$f.2.3 config -bg white
	$f.2.4 config -bg black
	$f.2.5 config -bg white
	$f.2.6 config -bg black
}

###############################################################################################
#																							  #
#	WINDOW AND FUNCTIONS TO CONTROL ENTRY OF MIDI-DATA FOR TEXTURE PROGRAMS' 'NOTEDATA' FILE  #
#																							  #
###############################################################################################

#----- Establish window to enter 'notedata' information in correct sequence for every 'texture' prog and mode

proc GetNoteData {} {
	global pr_notedata pprg mmod chlist nd_entry nd_entryval tv_stop evv
	if {![info exists chlist]} {
		return
	}
	set sndcnt [llength $chlist]
	switch -- $sndcnt {
		0		{ return }
		1		{ set ndmsg "Pitch of input sound" } 
		default { set ndmsg "Pitches of input sounds" }
	}
	.maketextp.k.t delete 1.0 end
	set mode $mmod
	incr mode -1
	switch -regexp -- $mode \
		^$evv(TEX_HF)$ {
			set nd_hftext "Harmonic Field"
		} \
		^$evv(TEX_HS)$ {
			set nd_hftext "Harmonic Set"
		} \
		^$evv(TEX_HFS)$ {
			set nd_hftext "Harmonic Fields"
		} \
		^$evv(TEX_HSS)$ {
			set nd_hftext "Harmonic Sets"
		}

	set nd_entry 0
	set nd_entryval -1
	set f .notedata
	if [Dlg_Create $f "Generate Notedata" "set pr_notedata 0"] {
		button $f.0 -text "Abandon" -command "set pr_notedata 0" -highlightbackground [option get . background {}]
		pack $f.0 -side top -pady 2
		label $f.00 -text "PRESS BUTTON BELOW, AND ENTER DATA FOR ..."
		pack $f.00 -side top -pady 2
		radiobutton $f.basic -text $ndmsg -variable nd_entryval -value 0 -command {set pr_notedata [NoteDataPitches]}
		pack $f.basic -side top -pady 2 -fill x -expand true -anchor w
		switch -regexp -- $pprg \
			^$evv(DECORATED)$ - \
			^$evv(PREDECOR)$ - \
			^$evv(POSTDECOR)$ {
				radiobutton $f.line -text "Line to decorate" -variable nd_entryval -value 1 -command {set pr_notedata [NoteDataLine]} -state disabled
				pack $f.line -side top -pady 2 -fill x -expand true -anchor w
			} \
			^$evv(ORNATE)$ - \
			^$evv(PREORNATE)$ - \
			^$evv(POSTORNATE)$ {
				radiobutton $f.line -text "Line to ornament" -variable nd_entryval -value 1 -command {set pr_notedata [NoteDataLine]} -state disabled
				pack $f.line -side top -pady 2 -fill x -expand true -anchor w
			} \
			^$evv(TIMED)$ - \
			^$evv(TGROUPS)$ - \
			^$evv(TMOTIFS)$ - \
			^$evv(TMOTIFSIN)$ {
				radiobutton $f.line -text "Timed Line" -variable nd_entryval -value 1 -command {set pr_notedata [NoteDataLine]} -state disabled ;# TIMED
				pack $f.line -side top -pady 2 -fill x -expand true -anchor w
			}

		switch -regexp -- $pprg \
			^$evv(MOTIFSIN)$ - \
			^$evv(TMOTIFSIN)$ {
				if {($mode == $evv(TEX_HF)) || ($mode == $evv(TEX_HS))} {
					radiobutton $f.hf -text $nd_hftext -variable nd_entryval -value 2 -command {set pr_notedata [NoteDataHF]} -state disabled
					pack $f.hf -side top -pady 2 -fill x -expand true -anchor w
				} else {
					radiobutton $f.hf -text $nd_hftext -variable nd_entryval -value 2 -command {set pr_notedata [NoteDataHF]} -state disabled ;# timed, several
					pack $f.hf -side top -pady 2 -fill x -expand true -anchor w
				}
			} \
			default {
				if {$mode != $evv(TEX_NEUTRAL)} {
					if {($mode == $evv(TEX_HF)) || ($mode == $evv(TEX_HS))} {
						radiobutton $f.hf -text $nd_hftext -variable nd_entryval -value 2 -command {set pr_notedata [NoteDataHF]} -state disabled
						pack $f.hf -side top -pady 2 -fill x -expand true -anchor w
					} else {
						radiobutton $f.hf -text $nd_hftext -variable nd_entryval -value 2 -command {set pr_notedata [NoteDataHF]} -state disabled ;# timed, several
						pack $f.hf -side top -pady 2 -fill x -expand true -anchor w
					}
				}
			}
		switch -regexp -- $pprg \
			^$evv(MOTIFS)$ - \
			^$evv(MOTIFSIN)$ - \
			^$evv(TMOTIFS)$ - \
			^$evv(TMOTIFSIN)$ {
				radiobutton $f.mtf -text "Motif" -variable nd_entryval -value 3 -command {set pr_notedata [NoteDataMotifs]} -state disabled
				pack $f.mtf -side top -pady 2 -fill x -expand true -anchor w
			} \
			^$evv(ORNATE)$ - \
			^$evv(PREORNATE)$ - \
			^$evv(POSTORNATE)$ {
				radiobutton $f.mtf -text "Ornament" -variable nd_entryval -value 3 -command {set pr_notedata [NoteDataMotifs]} -state disabled
				pack $f.mtf -side top -pady 2 -fill x -expand true -anchor w
			}
		label $f.xx -text "HIT MIDI-KEY $tv_stop WHEN THIS MIDI DATA IS ALL ENTERED\n\n"
		pack $f.xx -side top -pady 2
		wm resizable $f 1 1
		bind $f <Escape> {set pr_notedata 0}
		switch -regexp -- $pprg \
			^$evv(MOTIFS)$ - \
			^$evv(MOTIFSIN)$ - \
			^$evv(TMOTIFS)$ - \
			^$evv(TMOTIFSIN)$ - \
			^$evv(ORNATE)$ - \
			^$evv(PREORNATE)$ - \
			^$evv(POSTORNATE)$ {
				label $f.mtfmsg -text "\n\n" 
				pack $f.mtfmsg -side top -pady 2
			}
	}
	set finished 0
	set pr_notedata 0
	raise $f
	update idletasks
	StandardPosition2 $f
	My_Grab 0 $f pr_notedata
	while {!$finished} {
		tkwait variable pr_notedata
		switch -- $pr_notedata {
			0 {
				.maketextp.k.t delete 1.0 end
				break
			} 
			1 {
				if {$nd_entry < 0} {
					break
				}
			}	
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}	

#----- Get Pitches of the input sounds as MIDI data, and update the data-entry window (or quit if all data entered)

proc NoteDataPitches {} {
	global nd_entry pr_notedata pprg mmod nd_entryval evv
	set mode $mmod
	incr mode -1
	if {![DoTV $evv(TEXTURENOTES) .maketextp.k.t .maketextp.b.midi 1]} {
		return 0
	}
	ActivateRadio
	switch -regexp -- $pprg \
		^$evv(DECORATED)$ - \
		^$evv(PREDECOR)$ - \
		^$evv(POSTDECOR)$ - \
		^$evv(ORNATE)$ - \
		^$evv(PREORNATE)$ - \
		^$evv(POSTORNATE)$ - \
		^$evv(TIMED)$ - \
		^$evv(TGROUPS)$ - \
		^$evv(TMOTIFS)$ - \
		^$evv(TMOTIFSIN)$ {
			incr nd_entry
		} \
		^$evv(MOTIFS)$ { 
			if {$mode == $evv(TEX_NEUTRAL)} {
				incr nd_entry 3
			} else {
				incr nd_entry 2
			}
		} \
		^$evv(MOTIFSIN)$ { 
			incr nd_entry 2
		} \
		default {
			if {$mode == $evv(TEX_NEUTRAL)} {
				set nd_entry -1
				DisableRadioExcept -1
				return 1
			} else {
				incr nd_entry 2
			}
			}
	set nd_entryval -1
	DisableRadioExcept $nd_entry
	return 1
}

#----- Enter data for a time-line of events as MIDI-data, and update the data-entry window (or quit if all data entered)

proc NoteDataLine {} {
	global nd_entry nd_entryval pr_notedata pprg mmod evv
	set mode $mmod
	incr mode -1
	if {![DoTV $evv(TEXTURELINE) .maketextp.k.t .maketextp.b.midi 1]} {
		return 0
	}
	ActivateRadio
	switch -regexp -- $pprg \
		^$evv(DECORATED)$ - \
		^$evv(PREDECOR)$ - \
		^$evv(POSTDECOR)$ {
			if {$mode == $evv(TEX_NEUTRAL)} {
				set nd_entry -1
				DisableRadioExcept -1
				return 1
			}
			incr nd_entry
		} \
		^$evv(ORNATE)$ - \
		^$evv(PREORNATE)$ - \
		^$evv(POSTORNATE)$ - \
		^$evv(TMOTIFS)$ {
			if {$mode == $evv(TEX_NEUTRAL)} {
				incr nd_entry 2			
			} else {
				incr nd_entry
			}
		} \
		^$evv(TMOTIFSIN)$ {
			incr nd_entry
		}\
		^$evv(TGROUPS)$ - \
		^$evv(TIMED)$ {
			if {$mode == $evv(TEX_NEUTRAL)} {
				set nd_entry -1
				DisableRadioExcept -1
				return 1
			}
			incr nd_entry
		}
	set nd_entryval -1
	DisableRadioExcept $nd_entry
	return 1
}

#----- Enter data for a HF or HS or multiples thereof, as MIDI-data, and update the data-entry window (or quit if all data entered)

proc NoteDataHF {} {
	global nd_entry nd_entryval pr_notedata pprg evv
	if {![DoTV $evv(TEXTUREHF) .maketextp.k.t .maketextp.b.midi 1]} {
		return 0
	}
	ActivateRadio
	switch -regexp -- $pprg \
		^$evv(ORNATE)$ - \
		^$evv(PREORNATE)$ - \
		^$evv(POSTORNATE)$ - \
		^$evv(MOTIFS)$ - \
		^$evv(MOTIFSIN)$ - \
		^$evv(TMOTIFS)$ - \
		^$evv(TMOTIFSIN)$ {
			incr nd_entry
			DisableRadioExcept $nd_entry
			set nd_entryval -1
			return 1
		}

	set nd_entry -1
	DisableRadioExcept -1
	return 1
}

#----- Enter data for motif(S) or ornament(s) as MIDI-data, and update the data-entry window (or quit if all data entered)

proc NoteDataMotifs {} {
	global nd_entry nd_entryval evv
	set returnval [DoTV $evv(TEXTUREMOTIF) .maketextp.k.t .maketextp.b.midi 1]
	if {$returnval <= 0} {
		if {$returnval == 0} {
			return 0
		} else {
			set nd_entry -1
		}
	}
	set nd_entryval -1
	return 1
}

#----- Activate all radio buttons (that exist) in order to advance active-item

proc ActivateRadio {} {
	.notedata.basic config -state normal
	catch {.notedata.line  config -state normal}
	catch {.notedata.hf    config -state normal}
	catch {.notedata.mtf   config -state normal}
}

#----- Disable all radio buttons (that exist) except the one that is active

proc DisableRadioExcept {n} {
	global tv_stop
	switch -- $n {
		0 {
			catch {.notedata.line  config -state disabled}
			catch {.notedata.hf    config -state disabled}
			catch {.notedata.mtf   config -state disabled}
			catch {.notedata.mtfmsg config -text "\n\n" -fg [option get . background {}]}
		}
		1 {
			.notedata.basic config -state disabled
			catch {.notedata.hf    config -state disabled}
			catch {.notedata.mtf   config -state disabled}
			catch {.notedata.mtfmsg config -text "\n\n" -fg [option get . background {}]}
		}
		2 {
			.notedata.basic config -state disabled
			catch {.notedata.line  config -state disabled}
			catch {.notedata.mtf   config -state disabled}
			catch {.notedata.mtfmsg config -text "\n\n" -fg [option get . background {}]}
		}
		3 {
			.notedata.basic config -state disabled
			catch {.notedata.line  config -state disabled}
			catch {.notedata.hf    config -state disabled}
			catch {.notedata.mtfmsg config -text "WHEN YOU HAVE FINISHED ENTERING [string toupper [.notedata.mtf cget -text]]S\nPRESS THE MIDI-ENTRY BUTTON AGAIN\n& THEN MIDI-KEY $tv_stop ON YOUR MIDI KEYBOARD" -fg blue}

		}
		default {
			.notedata.basic config -state disabled
			catch {.notedata.line  config -state disabled}
			catch {.notedata.hf    config -state disabled}
			catch {.notedata.mtf   config -state disabled}
			catch {.notedata.mtfmsg config -text "\n\n" -fg [option get . background {}]}
		}
	}
}

#############################################################################
#																			#
#	WINDOW AND FUNCTIONS TO CONTROL ENTRY OF MIDI-DATA FOR SEQUENCER DATA	#
#																			#
#############################################################################

#----- Establish window to enter 'sequencer' information

proc GetSequencerData {} {
	global pr_seqdata pprg chlist sq_data sq_dataval tv_stop sq_cnt sq_sndcnt sq_orig_sndcnt seq_separate_entry seq_outvals evv
	if {![info exists chlist]} {
		return
	}
	set sq_cnt 1
	set sq_offset ""
	catch {unset seq_outvals}
	set sq_sndcnt [llength $chlist]
	switch -- $sq_sndcnt {
		0		{ return }
		1		{ set sqmsg "Pitch of input sound" } 
		default { set sqmsg "Pitches of input sounds" }
	}
	set sq_orig_sndcnt $sq_sndcnt
	switch -regexp -- $pprg \
		^$evv(SEQUENCER)$ {
			set sqmsg2 "Your sequence"
		} \
		^$evv(SEQUENCER2)$ {
			set sqmsg2 "Sequence for all sources"
		}
	.maketextp.k.t delete 1.0 end
	set sq_data 0
	set sq_dataval -1
	set seq_separate_entry 0
	set f .seqdata
	if [Dlg_Create $f "Generate Sequencer Data" "set pr_seqdata 0"] {
		button $f.0 -text "Abandon" -command "set pr_seqdata 0" -highlightbackground [option get . background {}]
		pack $f.0 -side top -pady 2
		if {$sq_sndcnt > 1} {
			checkbutton $f.0a -variable seq_separate_entry -text "Enter notes for each src separately" -command ResetSeqSndCnt
			pack $f.0a -side top -pady 2
		}
		set sq_sndcnt 1
		label $f.00 -text "PRESS BUTTON BELOW, AND ENTER DATA FOR ..."
		pack $f.00 -side top -pady 2
		radiobutton $f.basic -text $sqmsg -variable sq_dataval -value 0 -command {set pr_seqdata [SeqDataSrcPitches]}
		pack $f.basic -side top -pady 2 -fill x -expand true -anchor w
		label $f.zz -text ""
		pack $f.zz -side top -pady 2
		frame $f.offset
		radiobutton $f.offset.ll -text "" -variable sq_dataval -value 1 -command MidiSeqOffset -state disabled
		entry $f.offset.ee -textvariable sq_offset -width 0 -bd 0
		pack $f.offset.ll $f.offset.ee -side left
		pack $f.offset -side top -pady 2 -fill x -expand true -anchor w
		radiobutton $f.line -text $sqmsg2 -variable sq_dataval -value 2 -command {set pr_seqdata [SeqDataMotif]} -state disabled
		pack $f.line -side top -pady 2 -fill x -expand true -anchor w
		label $f.xx -text "HIT MIDI-KEY $tv_stop WHEN THIS MIDI DATA IS ALL ENTERED\n\n"
		pack $f.xx -side top -pady 2
		wm resizable $f 1 1
		bind $f <Escape> {set pr_seqdata 0}
	}
	set finished 0
	set pr_seqdata 0
	raise $f
	update idletasks
	StandardPosition2 $f
	My_Grab 0 $f pr_seqdata
	while {!$finished} {
		tkwait variable pr_seqdata
		switch -- $pr_seqdata {
			0 {
				.maketextp.k.t delete 1.0 end
				break
			} 
			1 {
				if {$sq_data < 0} {
					break
				}
			}	
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}	

#----- Get Pitches of the input sounds as MIDI data, and update the data-entry window

proc SeqDataSrcPitches {} {
	global sq_data sq_cnt sq_dataval seq_separate_entry seq_pitch evv
	catch {unset seq_pitch}
	.seqdata.0a config -state disabled
	if {![DoTV $evv(TEXTURENOTES) .maketextp.k.t .maketextp.b.midi 1]} {
		return 0
	}
	incr sq_data 2
	set sq_dataval -1
	ActivateSeqRadio
	return 1
}

#----- Enter data for sequence(s) as MIDI-data, and update the data-entry window (or quit if all data entered)

proc SeqDataMotif {} {
	global sq_data sq_sndcnt sq_dataval sq_cnt evv
	if {![DoTV $evv(SEQUENCEMOTIF) .maketextp.k.t .maketextp.b.midi 1]} {
		return 0
	}
	incr sq_cnt
	if {$sq_cnt > $sq_sndcnt} {
		set sq_data -1
	} elseif {$sq_cnt > 1} {
		incr sq_data -1
	}
	set sq_dataval -1
	ActivateSeqRadio
	return 1
}


proc ActivateSeqRadio {} {
	global sq_data sq_cnt tv_stop seq_separate_entry
	switch -- $sq_data {
		1 {
			.seqdata.basic config -state disabled
			.seqdata.offset.ll config -text "Start time of this source" -state normal
			.seqdata.offset.ee config -bd 2 -width 12
			.seqdata.zz config -text "PRESS BUTTON ONCE START TIME HAS BEEN ENTERED"
			.seqdata.00 config -text ""
			.seqdata.line  config -state disabled
			.seqdata.xx config -text "\n\n"
		}
		2 {
			.seqdata.offset.ll config -text "" -state disabled
			.seqdata.offset.ee config -bd 0 -width 0
			.seqdata.zz config -text ""
			.seqdata.00 config -text "PRESS BUTTON BELOW, AND ENTER DATA FOR ..."
			.seqdata.basic config -state disabled
			if {$seq_separate_entry} {
				.seqdata.line  config -state normal -text "Sequence for source $sq_cnt"
			} else {
				.seqdata.line config -state normal -text "Sequence for all sources"
			}
			.seqdata.xx config -text "HIT MIDI-KEY $tv_stop WHEN THIS MIDI DATA IS ALL ENTERED\n\n"
		}
	}
}

proc ResetSeqSndCnt {} {
	global sq_sndcnt sq_orig_sndcnt seq_separate_entry
	if {$seq_separate_entry} {
		set sq_sndcnt $sq_orig_sndcnt
		.seqdata.line config -text "Sequence for source 1"
	} else {
		set sq_sndcnt 1
		.seqdata.line config -text "Sequence for all sources"
	}
}

proc MidiSeqOffset {} {
	global sq_offset sq_data sq_dataval	sq_real_offset
	if {![IsNumeric [StripLeadingZeros $sq_offset]] || ($sq_offset < 0.0)} {
		Inf "INVALID OFFSET TIME"
		set sq_dataval -1
		set sq_offset ""
	} else {
		incr sq_data
		set sq_real_offset $sq_offset
		set sq_offset ""
		set sq_dataval -1
		ActivateSeqRadio
	}
}

#########################################################################
#																		#
#	WINDOW AND FUNCTIONS TO CONTROL ENTRY OF MIDI-DATA TO TABLE_EDITOR	#
#																		#
#########################################################################

proc GetTabedData {} {
	global pr_midite te_midit te_midip te_midia te_midid te_midipp te_midiaa tabed wstk evv
	global col_infnam
	set f .midite
	set listing $tabed.bot.itframe.l.list
	set kbd $tabed.top2.kbd 
	$listing delete 0 end
	set callcentre [GetCentre [lindex $wstk end]]
	if [Dlg_Create $f "MIDI IN" "set pr_midite 0"] {
		frame $f.0
		button $f.0.0 -text "Get Midi" -command "set pr_midite 1" -highlightbackground [option get . background {}]
		button $f.0.1 -text "Abandon" -command "set pr_midite 0" -highlightbackground [option get . background {}]
		pack $f.0.0 -side left -padx 2 -pady 2
		pack $f.0.1 -side right -padx 2 -pady 2
		
		frame $f.xt -height 1 -bg [option get . foreground {}]
		frame $f.t
		checkbutton $f.t.0 -text "Time"      -variable te_midit
		label $f.t.ll -text "Time of events, setting first as zero"
		pack $f.t.0 -side left -anchor w
		pack $f.t.ll -side right -anchor e

		frame $f.xp -height 1 -bg [option get . foreground {}]
		frame $f.p
		checkbutton $f.p.1 -text "Pitch"     -variable te_midip
		radiobutton $f.p.2 -text "Midi"   -variable te_midipp -value 0
		radiobutton $f.p.3 -text "Freq"    -variable te_midipp -value 1
		pack $f.p.1 -side left
		pack $f.p.3 $f.p.2 -side right

		frame $f.xa -height 1 -bg [option get . foreground {}]
		frame $f.a
		checkbutton $f.a.1 -text "Amplitude" -variable te_midia
		radiobutton $f.a.2 -text "Midi" -variable te_midiaa -value 0
		radiobutton $f.a.3 -text "Gain" -variable te_midiaa -value 1
		pack $f.a.1 -side left
		pack $f.a.3 $f.a.2 -side right

		frame $f.xd -height 1 -bg [option get . foreground {}]
		frame $f.d
		checkbutton $f.d.0 -text "Duration"  -variable te_midid
		label $f.d.ll -text "Duration of events"
		pack $f.d.0 -side left -anchor w
		pack $f.d.ll -side right -anchor e

		pack $f.0 $f.xt $f.t $f.xp $f.p $f.xa $f.a $f.xd $f.d -side top -pady 2 -fill x -expand true
		wm resizable $f 1 1
		bind $f <Return> {set pr_midite 1}
		bind $f <Escape> {set pr_midite 0}
	}
	set te_midit 0 
	set te_midip 0 
	set te_midia 0 
	set te_midid 0 
	set te_midipp -1
	set te_midiaa -1
	set finished 0
	set pr_midite 0
	raise $f
	update idletasks
	set geo [CentreOnCallingWindow $f $callcentre]
	My_Grab 0 $f pr_midite
	wm geometry $f $geo
	while {!$finished} {
		tkwait variable pr_midite
		switch -- $pr_midite {
			0 {
				$listing delete 0 end
				break
			} 
			1 {
				if {!($te_midit || $te_midip || $te_midia || $te_midid)} {
					Inf "No Output Selected"	
					continue
				}
				if {$te_midip} {
					if {$te_midipp < 0} {
						Inf "Select MIDI or Frq Output"
						continue
					}
				}
				if {$te_midia} {
					if {$te_midiaa < 0} {
						Inf "Select MIDI or Gain Output"
						continue
					}
				}
				if {![DoTV $evv(MIDITOTABED) $listing $kbd 1]} {
					continue
				}
				ForceVal $tabed.message.e  ""
 				$tabed.message.e config -bg [option get . background {}]
				HaltCursCop
				set fnam $evv(DFLT_OUTNAME)
				append fnam "0" $evv(TEXT_EXT)
				if [catch {open $fnam "w"} fId] {
					ForceVal $tabed.message.e  "Cannot open temporary file $fnam"
	 				$tabed.message.e config -bg $evv(EMPH)
					$listing delete 0 end
					continue
				}
				foreach line [$listing get 0 end] {
					puts $fId $line
				}
				close $fId
				if {[DoParse $fnam 0 0 0] <= 0} {
					ErrShow "Parsing failed for new file."
				}
 				GetTableFromFilelist 0 0 1
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}	

proc TVAnnounce {} {
	global pr_selmidix evv
	set f .selectmidix
	if [Dlg_Create $f "MIDI In" "set pr_selmidix 0"] {
		button $f.ok -text "OK" -command "set pr_selmidix 1" -highlightbackground [option get . background {}]
		pack $f.ok -side top -pady 6
#MARCH 2011
#		label $f.1 -text "If you have 'Tabula Vigilans' in your '_cdprogs' directory."
		label $f.1 -text "If you have 'Tabula Vigilans' in your CDP programs directory."
		label $f.2 -text "DIRECT MIDI INPUT of pitch or frequency data from a MIDI keyboard is now available."
		pack $f.1 $f.2 -side top -pady 4
		frame $f.c
		label $f.c.1 -text "accessed through PIANO-TYPE Buttons"
		frame $f.c.2
		MakeKeyboardKey $f.c.2 display 0
		pack $f.c.1 $f.c.2 -side left
		pack $f.c -side top -pady 10
		frame $f.d -bd 4 -bg grey0
		frame $f.d.ll  -bg grey0
		label $f.d.ll.1 -text "MIDI connectedness courtesy of Richard Orton's " -bg grey0 -fg white
		label $f.d.ll.2 -text "'Tabula Vigilans'" -fg red -bg grey0
		pack $f.d.ll.1 $f.d.ll.2 -side left
		pack $f.d.ll -side top
		label $f.d.2 -text "\n" -bg grey0
		label $f.d.3 -text "'Tabula Vigilans' is a powerful algorithmic composing environment, using MIDI data" -bg grey0 -fg white
		label $f.d.4 -text "and is available from the CDP." -bg grey0 -fg white
		label $f.d.5 -text "\n" -bg grey0 -fg white
		label $f.d.6 -text "for more information go to" -bg grey0 -fg white
		label $f.d.7 -text "http://www.composersdesktop.com/options.html" -fg red -bg grey0
		pack $f.d.2 $f.d.3 $f.d.4 $f.d.5 $f.d.6 $f.d.7 -side top
		pack $f.d -side top
		wm resizable $f 1 1
		bind $f <Return> {set pr_selmidix 0}
		bind $f <Escape> {set pr_selmidix 0}
		bind $f <Key-space> {set pr_selmidix 0}
	}
	set pr_selmidix 0
	raise $f
	My_Grab 0 $f pr_selmidix
	tkwait variable pr_selmidix
	set fnam [file join $evv(CDPRESOURCE_DIR) tvannounce$evv(CDP_EXT)]
	catch {open $fnam "w"} fId
	catch {close $fId}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}


proc TransposeVaribankFilterInSitu {listing} {
	global pr_tris trinsitu mmod chlist pa evv
	if {![info exists chlist] || ([llength $chlist] != 1)} {
		return
	}
	set fnam [lindex $chlist 0]
	set filtmax [UnconstrainedHzToMidi $pa($fnam,$evv(NYQUIST))]
	set filtmin [UnconstrainedHzToMidi $evv(FLT_MINFRQ)]
	set mode $mmod
	incr mode -1

	set fdat_linecnt [FilterDataLineCnt]
	if {$fdat_linecnt <= 1} {
		return
	}
	set line [$listing get 1.0 end]
	set line [split $line]
	set cnt 0
	foreach item $line {
		set item [string trim $item]
		if {[string length $item] > 0} {
			lappend zline $item
			incr cnt
		}
	}
	set data_cnt [expr $cnt / $fdat_linecnt]
	if {$data_cnt < 3} {
		Inf	"Invalid Data In Filter File (If Your Line Count Is Correct)"
		return
	}
	set x [expr $data_cnt * $fdat_linecnt]
	if {$x != $cnt} {
		Inf	"Invalid Data In Filter File (If Your Line Count Is Correct)"
		return
	}
	set cnt 0
	foreach item $zline {
		lappend nuline $item
		incr cnt
		if {$cnt == $data_cnt} {
			lappend nulines $nuline
			unset nuline
			set cnt 0
		}
	}
	set maxval -1000
	set minval 1000
	set cnt 0
	foreach line $nulines {
		set x 1
		while {$x < $data_cnt} {
			set val [lindex $line $x] 
			if {$mode == $evv(FLT_HZ)} {
				set val [UnconstrainedHzToMidi $val]
				set line [lreplace $line $x $x $val]
			}
			if {$val > $maxval} {
				set maxval $val
			} 
			if {$val < $minval} {
				set minval $val
			}
			incr x 2
		}
		if {$mode == $evv(FLT_HZ)} {
			set nulines [lreplace $nulines $cnt $cnt $line]
		}
		incr cnt
	}
	set f .is
	if [Dlg_Create $f "Transpose Filter" "set pr_tris 0"] {
		frame $f.0
		button $f.0.ok -text "Transpose" -command "set pr_tris 1" -highlightbackground [option get . background {}]
		button $f.0.q -text "Abandon" -command "set pr_tris 0" -highlightbackground [option get . background {}]
		pack $f.0.ok -side left
		pack $f.0.q -side right
		frame $f.1
		label $f.1.ll -text "Transposition (semitones)"
		entry $f.1.e -textvariable trinsitu -width 12
		pack $f.1.ll $f.1.e -side left -padx 2
		pack $f.0 $f.1 -side top -fill x -expand true -pady 2
		wm resizable $f 1 1
		bind $f <Escape> {set pr_tris 0}
		bind $f <Return> {set pr_tris 1}
	}
	set finished 0
	set trinsitu 0
	set pr_tris 0
	raise $f
	My_Grab 0 $f pr_tris
	while {!$finished} {
		tkwait variable pr_tris
		if {$pr_tris} {
			if {![IsNumeric $trinsitu]} {
				Inf "Invalid Transposition Value"
				continue
			}
			if {[expr $trinsitu + $maxval] >= $filtmax} {
				Inf "Transposition Out Of Range For This Data"
				continue
			}
			if {[expr $trinsitu + $minval] < $filtmin} {
				Inf "Transposition Out Of Range For This Data"
				continue
			}
			set cnt 0
			foreach line $nulines {
				set x 1
				while {$x < $data_cnt} {
					set val [lindex $line $x] 
					set val [expr $val + $trinsitu]
					if {$mode == $evv(FLT_HZ)} {
						set val [DecPlaces [MidiToHz $val] 3]
					}
					set line [lreplace $line $x $x $val]
					incr x 2
				}
				set nulines [lreplace $nulines $cnt $cnt $line]
				incr cnt
			}
			$listing delete 1.0 end
			foreach line $nulines {
				$listing insert end "$line\n"
			}
			set finished 1
		} else {
			break
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}

proc CreateFoundPeaksData {origrate} {
	global featscram sn sn_feature sn_peakcnt sn_peakgroupindex sn_windowcnt sn_lofrq sn_hifrq sn_sttwintime sn_endwintime sn_amps
	set sn_peakcnt   [lindex $featscram 0]
	set sn_windowcnt [lindex $featscram 1]
	set sn_lofrq     [lindex $featscram 2]
	set sn_hifrq     [lindex $featscram 3]
	set sn_sttwintime     [lindex $featscram 4]
	set sn_endwintime     [lindex $featscram 5]
	set k 6
	set j [expr $k + $sn_windowcnt]
	set sn_amps [lrange $featscram 6 [expr $j - 1]]

	set cnt 0

	set featscram [lrange $featscram $j end]
	set colourstep [expr 4.0 / double($sn_peakcnt)]	;#	THERE ARE ONLY 4 COLOR: USE THESE ECONOMICALLY TO COLOR THE peakcnt PEAKS
	set cnt 0
	set sn_peakgroupindex 0
	catch {unset sn_feature}

	foreach item $featscram {		;#	ASSUMES THESE ARE LINES OF VALUE TRIPLES ...time /frq/amp
		lappend thistriple $item
		incr cnt
		if {[expr $cnt % 3] == 0} {
			lappend sn_feature($sn_peakgroupindex) $thistriple
			unset thistriple
		}
		if {$cnt == [expr $sn_peakcnt * 3]} {		;#	peakcnt OUTPUT BY c PROGRAM	
			set cnt 0
			incr sn_peakgroupindex		;#	EACH sn_peakgroup CONTAINS ALL THE TRIPLES OCCURING AT SAME TIME (THE peakcnt PEAKS) 
		}
	}
	set n 0
	while {$n < $sn_peakgroupindex} {
		set sn_feature($n) [SortPeakGroup $sn_feature($n) $sn_peakcnt]	;#	SORT PEAKS IN THE GROUP, SO LOUDEST IS FIRST, QUIETIST LAST
		catch {unset nu_peakubergroup}
		set thiscolor 1.0
		foreach item $sn_feature($n) {
			catch {unset nu_peakgroup}
			foreach {time freq amp} $item {
				set time [expr int(round($time * $origrate))]
				set color [expr int(ceil($thiscolor))]
				lappend nu_peakgroup $time $freq $color
				lappend nu_peakubergroup $nu_peakgroup
			}
			set thiscolor [expr $thiscolor + $colourstep]
		}
		set sn_feature($n) $nu_peakubergroup
		incr n
	}
	return 1
}

proc SortPeakGroup {peakgroup peakcnt} {

	set peakcnt_less_one $peakcnt
	incr peakcnt_less_one -1
	set n 0
	while {$n < $peakcnt_less_one} {
		set peakn [lindex $peakgroup $n]
		set ampn [lindex $peakn 2]
		set m $n
		incr m
		while {$m < $peakcnt} {
			set peakm [lindex $peakgroup $m]
			set ampm [lindex $peakm 2]
			if {$ampm < $ampn} {
				set peakgroup [lreplace $peakgroup $n $n $peakm]
				set peakgroup [lreplace $peakgroup $m $m $peakn]
				set peakn $peakm
				set ampn $ampm
			}
			incr m
		}
		incr n
	}
	return $peakgroup
}

proc MakeSliceFile {inlist fnam} {
	global mmod prm pa evv

	set dblsplice [expr $prm(1) * $evv(MS_TO_SECS)]
	if {$mmod == 1} {
		set dur $pa($fnam,$evv(DUR))
		set lim [expr $dur - $dblsplice]
	} else {
		set dur $pa($fnam,$evv(INSAMS))
		set dur [expr $dur / $pa($fnam,$evv(CHANS))]
		set dblsplice [expr $dblsplice * double($pa($fnam,$evv(SRATE)))]
		set dblsplice [expr int(ceil($dblsplice))]
		set lim [expr $dur - $dblsplice]
	}
	if {$lim <= 0} {
		Inf "File Too Short For Slicing With Splicelength Of $prm(1) mS"
		return {}
	}
	if {$mmod == 2} {
		set dblsplice [expr $dblsplice * $pa($fnam,$evv(CHANS))]
		set lim [expr $lim * $pa($fnam,$evv(CHANS))]
		set dur $pa($fnam,$evv(INSAMS))
	}
	if {[lindex $inlist 0] <= $dblsplice} {
		set tooclose 1
		set inlist [lreplace $inlist 0 0 0]
	} else {
		set inlist [linsert $inlist 0 0]
	}
	if {[lindex $inlist end] >= $lim} {
		set tooclose 1
		set inlist [lreplace $inlist end end $dur]
	} else {
		set inlist [linsert $inlist end $dur]
	}
	set len [llength $inlist]
	incr len -2
	set starts [lrange $inlist 0 $len]
	set ends [lrange $inlist 1 end]
	foreach start $starts finish $ends {
		set line $start
		lappend line $finish
		lappend nulines $line
	}
	if {[info exists tooclose]} {
		Inf "Some Points Are Too Close To Start Or End Of File, For Splicelength $prm(1) mS"
	}
	return $nulines
}

proc MakeElasticFile {inlist fnam} {
	global mmod prm evv pa evv actvlo actvhi ins chlist
	if {![IsNumeric $prm(0)]} {
		Inf "Time Stretch Parameter Not Preset On Parameters Page: Set It Now"
		return ""
	}
	if {($prm(0) < $actvlo(0)) || ($prm(0) > $actvhi(0))} {
		Inf "Time Stretch Parameter Out Of Range On Parameters Page: Reset It Now"
		return ""
	}
	set len [llength $inlist]
	if {($len != 2) && ([expr $len % 4] != 0)} {
		Inf "Either 2 Time-Points Or (Groups Of) 4 Time-Points Required"
	}
	if {$ins(create)} {
		set dur $pa([lindex $ins(chlist) 0],$evv(DUR))
	} else {
		set dur $pa([lindex $chlist 0],$evv(DUR))
	}
	set thisindex 0
	switch -- $len {
		2 {
			set line [list 0 1]
			lappend nulines $line
			set time [lindex $inlist $thisindex]
			set line [list $time 1]
			lappend nulines $line
			incr thisindex
			set endtime [lindex $inlist $thisindex]
			set line [list $endtime $prm(2)]
			lappend nulines $line
			if {$endtime < [expr $dur - 0.02]} {
				set line [list $dur $prm(2)]
				lappend nulines $line
			}
		}
		default {
			set gplen [expr $len / 4]
			set gpcnt 0
			while {$gpcnt < $gplen} {
				set starttime [lindex $inlist $thisindex]
				if {($gpcnt == 0) && ($starttime > 0)} {
					set line [list 0 1]
					lappend nulines $line
				}
				set line [list $starttime 1]
				lappend nulines $line
				incr thisindex
				set line [list [lindex $inlist $thisindex] $prm(0)]
				lappend nulines $line
				incr thisindex
				set line [list [lindex $inlist $thisindex] $prm(0)]
				lappend nulines $line
				incr thisindex
				set endtime [lindex $inlist $thisindex] 
				set line [list $endtime 1]
				lappend nulines $line
				incr thisindex
				incr gpcnt
			}
			if {$endtime < [expr $dur - 0.02]} {
				set line [list $dur 1]
				lappend nulines $line
			}
		}
	}
	return $nulines
}

proc MakeSnipFile {inlist fnam} {
	global pr_snip snip_dur snipdur pa chlist ins evv
	set snipdur $evv(SNIPDUR)
	set f .snip
	if [Dlg_Create $f "SNIP DURATION" "set pr_snip 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.d -text "Set Duration" -command "set pr_snip 1" -highlightbackground [option get . background {}]
		button $f.0.q -text "Default Duration $evv(SNIPDUR)" -command "set pr_snip 0" -bg $evv(EMPH) -highlightbackground [option get . background {}]
		pack $f.0.d -side left
		pack $f.0.q -side right
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Duration of Inserted Silences (secs) "
		entry $f.1.e  -textvariable snip_dur -width 6
		pack $f.1.ll $f.1.e -side left -padx 2
		pack $f.1 -side top -pady 2
		wm resizable $f 1 1
	}
	if {$ins(run)} {
		set fnam [lindex $ins(chlist) 0]
	} else {
		set fnam [lindex $chlist 0]
	}
	set srate $pa($fnam,$evv(SRATE))
	set minsnip [expr 2.0 / double($srate)]
	set finished 0
	set pr_snip 0
	raise $f
	update idletasks
	StandardPosition2 $f
	My_Grab 0 $f pr_snip
	while {!$finished} {
		tkwait variable pr_snip
		if {$pr_snip} {
			if {[string length snip_dur] <= 0} {
				Inf "No Duration Value Entered"
				continue
			}
			if {![IsNumeric $snip_dur] || ($snip_dur < $minsnip)} { 
				Inf "Invalid Duration Value"
				continue
			}
			set snipdur $snip_dur
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
	foreach time $inlist {
		set line $time
		lappend line $snipdur
		lappend nulines $line
	}
	return $nulines
}

proc MakeManysilFile {inlist} {
	set linecnt 0
	foreach pair $inlist {
		set start [lindex $pair 0]
		set end   [lindex $pair 1]
		set line $start
		lappend line [expr $end - $start]
		if {$linecnt} {
			set n 0
			foreach thisline $nulines {
				if {$start <= [lindex $thisline 0]} {
					break
				}
				incr n
			}
			if {$n < $linecnt} {
				set nulines [linsert $nulines $n $line]
			} else {
				lappend nulines $line
			}
		} else {
			lappend nulines $line
		}
		unset line
		incr linecnt
	}
	return $nulines
}

proc MakeIsolateFile {inlist} {
	global mmod
	set linecnt 0
	set mmode [expr $mmod - 1]
	set len [llength $inlist]
	set len_less_one [expr $len - 1]
	set originlist $inlist
	set n 0 
	while {$n < $len_less_one} {
		set inlist_n [lindex $inlist $n]
		set sttn [lindex $inlist_n 0]
		set m $n
		while {$m < $len} {
			set inlist_m [lindex $inlist $m]
			set sttm [lindex $inlist_m 0]
			if {$sttm < $sttn} {
				set inlist [lreplace $inlist $n $n $inlist_m]
				set inlist [lreplace $inlist $m $m $inlist_n]
				set inlist_n $inlist_m
			}
			incr m
		}
		incr n
	}
	set n 0 
	while {$n < $len_less_one} {
		set inlist_n [lindex $inlist $n]
		set sttn [lindex $inlist_n 0]
		set endn [lindex $inlist_n 1]
		set m $n
		incr m
		set inlist_m [lindex $inlist $m]
		set sttm [lindex $inlist_m 0]
		if {$endn > $sttm} {
			Inf "Segments overlap : invalid listing for this process"
			set outlist {}
			return $outlist
		}
		lappend outlist $inlist_n
		incr n
	}
	set inlist_n [lindex $inlist $n]
	lappend outlist $inlist_n
	if {$mmod == 2} {
		catch {unset outlist}
		set inlist $originlist
		set k 0
		set out($k) [lindex $inlist 0]
		set n 0
		while {$n < $len_less_one} {
			set inlist_n [lindex $inlist $n]
			set sttn [lindex $inlist_n 0]
			set m $n
			incr m
			set inlist_m [lindex $inlist $m]
			set sttm [lindex $inlist_m 0]
			if {$sttm < $sttn} {
				incr k
				set out($k) {}
			}
			set out($k) [concat $out($k) $inlist_m]
			incr n
		}
		set n 0
		while {$n <= $k} {
			lappend outlist $out($n)
			incr n
		}
	}
	return $outlist
}

proc IsCleanKitWindow {listing} {
	global den_t dis_t dcou_t cj_t grft_t clatn_t clinsil_t rpe_t

	if {[info exists den_t] && [string match $listing $den_t]} {
		return 1
	}
	if {[info exists dis_t] && [string match $listing $dis_t]} {
		return 1
	}
	if {[info exists dcou_t] && [string match $listing $dcou_t]} {
		return 1
	}
	if {[info exists cj_t] && [string match $listing $cj_t]} {
		return 1
	}
	if {[info exists grft_t] && [string match $listing $grft_t]} {
		return 1
	}
	if {[info exists clatn_t] && [string match $listing $clatn_t]} {
		return 1
	}
	if {[info exists clinsil_t] && [string match $listing $clinsil_t]} {
		return 1
	}
	if {[info exists rpe_t] && [string match $listing $rpe_t]} {
		return 1
	}
	if {[string match $listing noiseg]} {
		return 1
	}
	if {[string match $listing noisegst]} {
		return 1
	}
	if {[string match $listing unnoiseg]} {
		return 1
	}
	return 0
}

#----- Hilite mixfile lines that are being called at display-box in sound view display

proc QikEditPlace {at_qikedit} {
	global snack_list m_list mixval qiki qikclik prm pa evv qikaborig qikoffset
	set cnt 0

	foreach val $snack_list {
		switch -- $cnt {
			0 { set stt  $val }
			1 { set endd $val }
			2 { set isdur 1   }
		}
		incr cnt
	}
	if {![info exists stt]} {
		Inf "No Data From Sound-View Display"
		return
	}
	set origstt $stt
	set qoffset_added 0
	if {![info exists qikaborig]} {
		if {[info exists qikoffset]} {
			set stt  [expr $stt + $qikoffset]
			set endd [expr $endd + $qikoffset]
		} else {
			set offset [GetMinTimeInMix]
			set stt  [expr $stt + $offset]
			set endd [expr $endd + $offset]
		}
	}
	if {[info exists isdur]} {
		set mixval [DecPlaces [expr $endd - $stt] 4]
	} else {
		if {$at_qikedit == 2} {
			set i [$m_list curselection]
			if {([llength $i] != 1) || ($i < 0)} {
				return
			}
			set line [$m_list get $i]
			set val [lindex $line 1]
			set mixval [DecPlaces [expr $origstt + $val] 4]
		} else {
			set mixval [DecPlaces $stt 4]
		}
	}
	if {$at_qikedit != 1} {
		return
	}

	;# HIGHLIGHT LINES ACTIVE AT START-TIME OF, OR THROUGHOUT, SELECTED PART OF  GRAPHICS 

	set i 0

	foreach line [$m_list get 0 end] {
		set fnam [lindex $line 0]
		if {[string match ";" [string index $fnam 0]]} {
			incr i
			continue
		}
		if {[info exists qiki] && [string match $line $qikclik]} {	;#	Don't highlght the click-track line
			incr i
			continue
		}
		set line_stime [lindex $line 1]
		set dur	$pa($fnam,$evv(DUR))
		if {$dur <= 0.0} {
			incr i
			continue
		}
		set line_etime [expr $line_stime + $dur]
		if {$line_stime < $stt} {
			if {$line_etime > $stt} {
				lappend ilist $i
			}
		} elseif {$line_stime < $endd} {
			lappend ilist $i
		}
		incr i
	}			
	if {![info exists ilist]} {
		Inf "No Active Lines Found At This Mix Time"
		return
	}
	set qq [lindex $ilist 0]
	$m_list selection clear 0 end
	foreach i $ilist {
		$m_list selection set $i
	}
	set k [$m_list index end]
	if {$k > 0.0} {
		set k [expr double($qq) / double($k)]
		$m_list yview moveto $k
	}
}

proc SnackDflt {pcnt} {
	global dfault pprg ins temp_batch evv

	set p_rg 0
	if {$ins(run)} {
		set gadg [lindex [lindex [lindex $ins(gadgets) $pcnt] 1] 1]
		if {[string first "TIMESTRETCH_MULTIPLIER" $gadg] == 0} {
			set p_rg $evv(TSTRETCH)
		}
	} else {
		set p_rg $pprg
	}
	switch -regexp -- $p_rg \
		^$evv(TSTRETCH)$ {
			return 1.0
		}

	return $dfault($pcnt)
}

#----- Sort time pairs into correct order, where data is to be used to excise segs or add segs to an existing file

proc SortTimepairs {} {
	global sn evv
	set len [llength $sn(snack_list)]
	set len_less_one [expr $len - 1]
	set k 0								;#	SORT PAIRS INTO START-TIME ASCENDING ORDER
	while {$k < $len_less_one} {
		set snack_k [lindex $sn(snack_list) $k]
		set stt_k [lindex $snack_k 0]
		set j $k
		incr j
		while {$j < $len} {
			set snack_j [lindex $sn(snack_list) $j]
			set stt_j [lindex $snack_j 0]
			if {$stt_j < $stt_k} {
				set sn(snack_list) [lreplace $sn(snack_list) $k $k $snack_j]
				set sn(snack_list) [lreplace $sn(snack_list) $j $j $snack_k]
				set snack_k $snack_j
				set stt_k $stt_j
			}
			incr j
		}
		incr k
	}
	set k 0
	while {$k < $len_less_one} {		;#	MERGE OVERLAPPING PAIRS
		set snack_k [lindex $sn(snack_list) $k]
		set end_k [lindex $snack_k 1]
		set j $k
		incr j
		while {$j < $len} {
			set snack_j [lindex $sn(snack_list) $j]
			set stt_j [lindex $snack_j 0]
			set end_j [lindex $snack_j 1]
			if {$stt_j <= $end_k} {		;#	IF THIS SEG START BEFORE LAST SEG ENDS..
				if {$end_j > $end_k} {	;#	IF IT ENDS AFTER LAST ENDS
					set end_k $end_j	;#	SET END OF LAST SEG TO END OF THIS SEG
					set snack_k [lreplace $snack_k 1 1 $end_k]
					set sn(snack_list) [lreplace $sn(snack_list) $k $k $snack_k]
				}						;#	DELETE THE OVERLAPPED SEG
				set sn(snack_list) [lreplace $sn(snack_list) $j $j]
				incr len -1				;#	AND REDUCE TOTAL LENGTH OF LIST
				incr len_less_one -1
			} else {
				incr j
			}
		}
		incr k
	}
}

proc GetMinTimeInMix {} {
	global prm m_list pa evv qoffset_added
	set minstt 1000000					;# Check if (active) mixlines are ALL offset from zero 
	if {![info exists m_list]} {
		return 0		;#	KLUDGE
	}
	foreach line [$m_list get 0 end] {
		set fnam [lindex $line 0]
		if {[string match ";" [string index $fnam 0]]} {
			continue
		}
		if {![file exists $fnam]} {
			Inf "File '$fnam' Does Not Exist: Cannot Check If There Is Any Offset To Add To Times"
			return 0.0
		}
		if {![info exists pa($fnam,$evv(DUR))]} {
			Inf "File '$fnam' Not On The Workspace: Cannot Check If There Is Any Offset To Add To Times"
			return 0.0
		}
		set line_stime [lindex $line 1]
		if {$line_stime < $minstt} {
			set minstt $line_stime
		}
	}
	set offset 0.0
	if {$prm(0) >= $minstt} {		;#	If mix start-parameter is after start of 1st active line in mix
		set offset $prm(0)			;#	Times grabbed from display must be offset by start_prm(0) to get written times in mixfile
	} else {						;#	If mix start-parameter is BEFORE start of 1st active line in mix (minstt: which must hence be > 0.0)
		set offset $minstt			;#	Times grabbed from display must be offset by time of 1st active line in mix (minstt)
	}								;#	 to get written times in mixfile
	set qoffset_added 1
	return $offset
}

proc ReverseSearch {mylist mytarget} {
	set len [llength $mylist]
	incr len -1
	set mylist [ReverseList $mylist]
	set k [lsearch -exact $mylist $mytarget]
	if {$k >= 0} {
		set k [expr $len - $k]
	}
	return $k
}

proc SameThumbProps {fnam thum} {
	global pa evv
	if {![info exists pa($thum,$evv(SRATE))]} {
		return 0
	}
	if {$pa($fnam,$evv(SRATE)) != $pa($thum,$evv(SRATE))} {
		return 0
	}
	if {$pa($fnam,$evv(DUR)) != $pa($thum,$evv(DUR))} {
		return 0
	}
	return 1
}

#---- Set dovetail params from SnackDisplay timepairs output

proc SetDovetailParams {snklist dur} {
	global prm
	set len [llength $snklist]
	set prm(0) 0								;#	Preset Defaults
	set prm(1) 0
	set n 0
	while {$n < $len} {							;#	Delete all "CLEAR" instructions in list
		set item [lindex $snklist $n]
		if {[string match $item "CLEAR"]} {
			set snklist [lreplace $snklist $n $n]
			incr len -1
		} else {
			incr n
		}
	}
	if {$len == 0} {
		return
	}
	set snklist [ReverseList $snklist]			;#	In case there are more than 2 timepairs, search backwards from end
	set startset 0								;#	(Assuming earlier marked-areas have been over-ridden)	
	set endset   0
	foreach pair $snklist {
		set start [lindex $pair 0]
		set end   [lindex $pair 1]				;#	Proceed as above
		if {$start < [expr $dur - $end]} {
			if {!$startset} {					;#	Once start dovetail is set, don't reset it
				set prm(0) $end
				set startset 1					;#	Mark that start dovetail is set
			}
		} else {
			if {!$endset} {						;#	Once end dovetail is set, don't reset it
				set prm(1) [expr $dur - $start]
				set endset 1					;#	Mark that end dovetail is set
			}
		}
		if {$startset && $endset} {				;#	If both dovetails set, break
			break
		}
	}
	if {$dur < [expr $prm(0) + $prm(1)]} {
		Inf "START AND END DOVETAILS TOGETHER EXCEED THE FILE DURATION"
		set prm(0) 0					;#	Reset Defaults
		set prm(1) 0
	}
}

#--- Position window at TopLeft

proc LockToTopLeft {win} {
	set xy [wm geometry $win]
	set xy [split $xy x+]
	set w [lindex $xy 0]
	set h [lindex $xy 1]
	set geo $w
	append geo x $h + 0 + 0
	return $geo
}

proc SetSviewToTopLeft {topleft} {
	global sv_tl ww evv CDPnewver
	set fnam [file join $evv(CDPRESOURCE_DIR) svtl$evv(CDP_EXT)]
	if {$topleft} {
		set sv_tl 1
		$ww.h.syscon.menu.sub1 entryconfig 35 -label "Don't Force Soundview Display To Top Left" -command "SetSviewToTopLeft 0"
		if {![file exists $fnam]} {
			if {![catch {open $fnam "w"} zit]} {
				close $zit
			}
		}
	} else {
		catch {unset sv_tl}
		$ww.h.syscon.menu.sub1 entryconfig 35 -label "Force Soundview Display To Top Left" -command "SetSviewToTopLeft 1"
		if {[file exists $fnam]} {
			catch {file delete $fnam}
		}
	}
}

proc LoadSvtl {} {
	global evv sv_tl
	set fnam [file join $evv(CDPRESOURCE_DIR) svtl$evv(CDP_EXT)]
	if {[file exists $fnam]} {
		set sv_tl 1
	}
}

proc GetSpecfnuParname {mmod pcnt} {
	incr mmod -1
	set zzz ""
	switch -- $mmod {
		0 {
			if {$pcnt == 0} { set zzz "NARROWING" }
		}
		1 {
			if {$pcnt == 0} { set zzz "SQUEEZE"	  }
		}
		2 {
			if {$pcnt == 0} { set zzz "VIBRATE RATE"   }
		}
		3 {
			if {$pcnt == 0} { set zzz "ROTATION SPEED" }
		}
		6 {
			if {$pcnt == 0} { set zzz "TIMINGS FOR PITCHGRID" }
		}
		7 {
			switch -- $pcnt {
				0 { set zzz "MOVE1" }
				1 { set zzz "MOVE2" }
				2 { set zzz "MOVE3" }
				3 { set zzz "MOVE4" }
			}
		}
		8 {
			switch -- $pcnt {
				0 { set zzz "FRQ1" }
				1 { set zzz "FRQ2" }
				2 { set zzz "FRQ3" }
				3 { set zzz "FRQ4" }
			}
		}
		9 {
			if {$pcnt == 0} { set zzz "ARPEGGIATION RATE" }
		}
		10 {
			switch -- $pcnt {
				0 { set zzz "OCTAVE SHIFT"		}
				4 { set zzz "ARPEGGIATION RATE" }
			}
		}
		11 {
			switch -- $pcnt {
				0 { set zzz "TRANSPOSITION"     }
				4 { set zzz "ARPEGGIATION RATE"	}
			}
		}
		12 {
			switch -- $pcnt {
				0 { set zzz "FREQUENCY SHIFT"   }
				4 { set zzz "ARPEGGIATION RATE" }
			}
		}
		13 {
			switch -- $pcnt {
				0 { set zzz "FREQUENCY SPACING" }
				4 { set zzz "ARPEGGIATION RATE" }
			}
		}
		14 {
			switch -- $pcnt {
				1 { set zzz "PIVOT PITCH"       }
				5 { set zzz "ARPEGGIATION RATE" }
			}
		}
		15 {
			switch -- $pcnt {
				0 { set zzz "PIVOT PITCH"       }
				1 { set zzz "RANGE MULTIPLIER"  }
				5 { set zzz "ARPEGGIATION RATE" }
			}
		}
		16 {
			if {$pcnt == 4} { set zzz "ARPEGGIATION RATE" }
		}
		17 {
			switch -- $pcnt {
				1 { set zzz "RANDOMISATION RANGE" }
				2 { set zzz "RANDOMISATION SLEW"  }
				6 { set zzz "ARPEGGIATION RATE"   }
			}
		}
		18 {
			switch -- $pcnt {
				0 { set zzz "RANDOMISATION"     } 
				4 { set zzz "ARPEGGIATION RATE" }
			}
		}
		22 {
			switch -- $pcnt {
				1  { set zzz "DEPTH"		 }
				3  { set zzz "LEVEL1"		 }
				4  { set zzz "LEVEL2"		 }
				5  { set zzz "LEVEL3"		 }
				6  { set zzz "LEVEL4"		 }
				7  { set zzz "HFIELD DEPTH1" }
				8  { set zzz "HFIELD DEPTH2" }
				9  { set zzz "HFIELD DEPTH3" }
				10 { set zzz "HFIELD DEPTH4" }
			}
		}
	}
	return $zzz
}

proc VBoxDataToDisplay {brktype} {
	global sn_pts segment evv

	catch {unset sn_pts}

	if {$brktype == $evv(SN_TIMESLIST)} {
		if {[info exists segment(spike_explicit)]} { 
			return 1
		}
		if {$segment(phrase)} {
			if {$segment(phraserefine)} {
				if {![info exists segment(marklist)]} {
					Inf "No phrase segmentation to refine"
					return 0
				}
				set sn_pts $segment(marklist)						;#	Editing segmentation-points for PHRASE
			} elseif {![info exists segment(displaysegs)]} {		;#	Drawing segmentation points for PHRASE
				set sn_pts 0
				return 1
			}
		}
		if {[info exists segment(displaysegs)]} {
			if [catch {open $segment(nutroflist) "r"} zit] {
				Inf "Cannot open file $segment(nutroflist) containing refined segment-marking data"
				return 0
			}
		} elseif [catch {open $segment(troflist) "r"} zit] {
			Inf "Cannot open file $segment(troflist) containing segment-marking data"
			return 0
		}
	} else {
		if [catch {open $segment(nutroflist) "r"} zit] {
			Inf "Cannot open file $segment(nutroflist) containing refined segment-marking data"
			return 0
		}
	}
	while {[gets $zit item] >= 0} {
		set item [string trim $item]
		if {[string length $item] <= 0} {
			continue
		}
		if {[string match [string index $item 0] ";"]} {
			continue
		}
		lappend sn_pts $item
	}
	close $zit
	if {![info exists sn_pts]} {
		return 0
	}
	return 1
}

#------ Terminating TV process

proc TVTermination {} {
	global killtype CDPtv
	if {$killtype == 0} {
		return
	} 
	if {![catch {pid $CDPtv} pids]} {
		foreach pid $pids {
			DoKill $pid				;#	Terminate any processes associated with the pipe
		}
	}
	if [info exists CDPtv] {
		catch {close $CDPtv}
		catch {unset CDPtv}
	}
}

#--- Move a box end points to Nearest Markers, or to edges of display.
#--- AND, if there is no display box, put box over first pair of  markers or over entire display of no markers
#	Or, if display is already betweent existing markers, move to next pair of markers
#	Or, if already marking END segment in current display, go to 1st seg in current display

proc SnBoxStartAndEndToTimeMark {} {
	global sn
	catch {unset possiblepos}
	if {[info exists sn(boxlen)]} {
		set origstart $sn(startsamp)
		set origend $sn(endsamp)
		SnBoxToTimeMark
		SnBoxEndToTimeMark
		if {($sn(startsamp) == $origstart) && ($sn(endsamp) == $origend)} {
			;#	MOVE ON BY ONE BOX
			set this_marklist [concat $sn(dispstart) $sn(marklist) $sn(dispend)]
			set this_marklist [RemoveDuplicatesInList $this_marklist]
			set this_marklist [lsort -integer $this_marklist]
			set kk 0
			foreach mk $this_marklist {
				if {($mk >= $sn(dispstart)) && ($mk <= $sn(dispend))} {
					set wratio [expr double($mk - $sn(dispstart)) / double($sn(displen))]
					set mk [expr int(round(double($sn(width)) * $wratio))]
					incr mk $sn(left)
					lappend possiblepos $kk
				}
				incr kk
			}
			set origpos [lsearch $this_marklist $origstart]
			set k [lsearch $possiblepos $origpos]
			if {$origend == $sn(dispend)} {
				set possiblepos [lrange $possiblepos 0 1]
			} else {
				incr k
				set j $k
				incr j
				set possiblepos [lrange $possiblepos $k $j]
			}
		} else {
			return
		}
	}
	if {![info exists sn(marklist)]} {
		return
	}

	;#	No box exists, find first 2 marks on display

	if {![info exists possiblepos]} {
		set kk 0 
		set this_marklist [concat $sn(dispstart) $sn(marklist) $sn(dispend)]
		set this_marklist [RemoveDuplicatesInList $this_marklist]
		set this_marklist [lsort -integer $this_marklist]

		foreach mk $this_marklist {
			if {($mk >= $sn(dispstart)) && ($mk <= $sn(dispend))} {
				set wratio [expr double($mk - $sn(dispstart)) / double($sn(displen))]
				set mk [expr int(round(double($sn(width)) * $wratio))]
				incr mk $sn(left)
				lappend possiblepos $kk
			}
			incr kk
		}
		if {$kk > 2} {
			set possiblepos [lrange $possiblepos 1 2]
		}
	}
	set kk 0
	foreach pos $possiblepos {
		if {$kk == 0} {
			set sn(startsamp) [lindex $this_marklist $pos]
			set sn(starttime) [expr double($sn(startsamp)) * $sn(inv_srxchs)]
			set sn(gpstartsamp) [expr $sn(startsamp) / $sn(chans)]
		} else {
			set sn(endsamp) [lindex $this_marklist $pos]
			set sn(endtime) [expr double($sn(endsamp)) * $sn(inv_srxchs)]
			set sn(gpendsamp)   [expr $sn(endsamp) / $sn(chans)]
		}
		incr kk
	}
	set sn(dur) [ShowTime [expr $sn(endtime) - $sn(starttime)]]
	set sn(boxlen) [expr $sn(endsamp) - $sn(startsamp)]
	catch {$sn(snackan) delete $sn(boxthis)}
	catch {$sn(snackan) delete box}
	set k [expr double($sn(startsamp) - $sn(dispstart))]
	set k [expr $k / double($sn(displen))]
	set k [expr int(round($k * $sn(width)))]
	set k [expr ($k / $sn(chans)) * $sn(chans)]
	incr k $sn(left)
	set sn(boxanchor) [list $k $sn(height)]
	set k [expr double($sn(endsamp) - $sn(dispstart))]
	set k [expr $k / double($sn(displen))]
	set k [expr int(round($k * $sn(width)))]
	set k [expr ($k / $sn(chans)) * $sn(chans)]
	incr k $sn(left)
	set sn(boxend) $k
	set sn(boxthis) [eval {$sn(snackan) create rect} $sn(boxanchor) {$sn(boxend) 0 -tag box -outline blue -fill blue -stipple gray12}]
} 

#--- Turn entered spike times into trof-spike-trof triples

proc ReconfigureSpikeData {spike_times} {
	global segment

	set segment(conv) 1
	set segment(oldmarks) $segment(marklist)
	set segment(oldheadfirst) $segment(headfirst)
	set segment(oldcnt) $segment(cnt)
	if {![ConvertHTDataToPhraseData]} {
		return {}
	}
	set i 0
	set j 1
	set starti 0
	set spkcnt 0
	set spkgot 0
	set spklen [llength $spike_times]
	if {$segment(headfirst)} {
		incr i
		incr j
		incr starti 
	}
	set done 0
	set htcnt 1

	while {$i < $segment(cnt)} {							;#	For all segment HT pairs
		if {$i == $starti} {
			set stt 0.0
		} else {
			set stt [lindex $segment(marklist) $i]			;#	Find start and end of segmentHTpair
		}
		if {$j >= $segment(cnt)} {
			set endd $segment(dur)
		} else {
			set endd [lindex $segment(marklist) $j]
		}
		set spktim [lindex $spike_times $spkcnt]			;#	Get spike time at wherever we are in spikes list
		if {$spktim < $endd} {								;#	If spike within segment
			lappend outdata $stt
			lappend outdata $spktim
			lappend outdata $endd
			incr spkcnt										;#	and advance to next spike
			if {$spkcnt >= $spklen} {
				set done 1									;#	If spikes exhausted, quit
				break
			}
			set spktim [lindex $spike_times $spkcnt]
			if {$spktim < $endd} {
				Inf "More than one spike in head-tail group $htcnt"
				SegReset
				return {}
			}
		} else {											;#	IF no spike here, stay with this spike
			set spkgot 0
		}
		if {$done} {
			break
		}
		incr i 1											;#	Advance to next segment-HTpair
		incr j 1
		incr htcnt											;#	Count pairs for messaging
	}
	set spike_times $outdata
	SegReset
	return $spike_times
}

#-- Tab key toggles playbox on and off

proc TogglePlayBox {} {
	global sn
	if {[winfo exists .snack.f3.1.del]} {
		if {[info exists sn(boxthis)]} {
			DelSnBox 1
			set sn(res) -1
		} else {
			RestoreSnBox
			set sn(res) -1
		}
	}
}
