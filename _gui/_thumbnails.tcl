#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD 30 June 2013
# ... fixup button rectangles

##############################################################
# CONSTRUCT AND MANAGE MONO THUMBNAILS OF MULTICHANNEL FILES #
##############################################################

#------- Mix multichan file to mono

proc MakeThumbnail {fnam} {
	global wl CDPidrun prg_dun prg_abortd simple_program_messages pa monomchfnam wstk evv
	if {[string match $fnam 0]} {			;#	Getting file from workspace
		set i [$wl curselection]
		if {([llength $i] != 1) || ($i < 0)} {
			Inf "Select One Multichannel Soundfile"
			return 0
		}
		set fnam [$wl get $i]
		if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) < 2)} {
			Inf "Select A Multichannel Soundfile"
			return 0
		}
	}
	set monomchfnam [file tail $fnam]
	set monomchfnam [file join $evv(THUMDIR) $monomchfnam]
	if {[file exists $monomchfnam]} {
		set msg "Overwrite Existing Thumbnail ??"
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "yes"} {
			if [catch {file delete $monomchfnam} zit] {
				Inf "Cannot Delete Existing Thumbnail"
			}
		} else {
			return 0
		}
	}
	set simple_program_messages ""
	set housekeep_version [GetVersion housekeep]
	if {$housekeep_version >= 6} {
		set mono_mix $evv(DFLT_OUTNAME)
		append mono_mix 000 $evv(SNDFILE_EXT)

		if [file exists $mono_mix] {
			catch {file delete $mono_mix}
		}
		set cmd [file join $evv(CDPROGRAM_DIR) housekeep]
		lappend cmd chans 4 $fnam $mono_mix
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		Block "Creating Thumbnail"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "Creating Thumbnail Failed"
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
			Inf "Creating Thumbnail Failed"
			UnBlock
			return 0
		}
		if {![file exists $monomchfnam]} {
			if [catch {file rename $mono_mix $monomchfnam} zit] {
				Inf "Cannot Name The File (Cannot Save As A Thumbnail)"
				UnBlock
				return 0
			}
		}
		if {[DoThumbnailParse $monomchfnam] <= 0} {
			catch {file delete $monomchfnam} 
			UnBlock
			return 0
		}
		UnBlock
		return 1
	}
	set inchans $pa($fnam,$evv(CHANS))
	set done 0
	while {!$done} {
		set simple_program_messages ""
		set innam $evv(DFLT_OUTNAME)
		append innam 0000
		set outnam $innam
		append outnam "_c"
		append innam $evv(SNDFILE_EXT)
		set mixfnam $evv(DFLT_OUTNAME)
		append mixfnam 000 $evv(TEXT_EXT)
		set mono_mix $evv(DFLT_OUTNAME)
		append mono_mix 000 $evv(SNDFILE_EXT)

		if [file exists $mono_mix] {
			catch {file delete $mono_mix}
		}
		if [catch {file copy $fnam $innam} zit] {
			Inf "Failed To Copy Infile"	
			break
		}
		set cmd [file join $evv(CDPROGRAM_DIR) housekeep]
		lappend cmd chans 2 $innam
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		Block "Extracting Channels"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "Channel Extraction Failed"
			UnBlock
			break
   		} else {
   			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		UnBlock
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			Inf "Channel Extraction Failed"
			set n 1
			while {$n <= $inchans} {
				set ofnam $outnam
				append ofnam $n $evv(SNDFILE_EXT)
				if {[file exists $ofnam]} {
					catch {file delete $ofnam}
				}
				incr n
			}
			catch {file delete $innam}
			break
		}
		set n 1
		while {$n <= $inchans} {
			set ofnam $outnam
			append ofnam $n $evv(SNDFILE_EXT)
			if {![file exists $ofnam]} {
				lappend badfiles $ofnam
			} else {
				lappend ofnams $ofnam
			}
			incr n
		}
		if {[info exists badfiles]} {
			set msg "Failed To Create\n"
			foreach ofnam $badfiles {
				append msg $ofnam "\n"
			}
			Inf $msg
			set n 1
			while {$n <= $inchans} {
				set ofnam $outnam
				append ofnam $n $evv(SNDFILE_EXT)
				if {[file exists $ofnam]} {
					catch {file delete $ofnam}
				}
				incr n
			}
			catch {file delete $innam}
			break
		}
		foreach ofnam $ofnams {
			set line $ofnam					;#	CREATE STANDARD MIXFILE LINE
			lappend line 0.0 1 1.0
			lappend mixlines $line
		}
		if [catch {open $mixfnam "w"} zit] {
			set n 1
			while {$n <= $inchans} {
				set ofnam $outnam
				append ofnam $n $evv(SNDFILE_EXT)
				if {[file exists $ofnam]} {
					catch {file delete $ofnam}
				}
				incr n
			}
			catch {file delete $innam}
			break
		}
		foreach line $mixlines {
			puts $zit $line
		}
		close $zit

		set gain [expr 1.0/double($inchans)]
		set cmd [file join $evv(CDPROGRAM_DIR) submix]
		lappend cmd mix $mixfnam $mono_mix -g$gain
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		Block "Mixing To Mono"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "Failed To Do Mix To Mono"
			catch {file delete $mixfnam}
			set n 1
			while {$n <= $inchans} {
				set ofnam $outnam
				append ofnam $n $evv(SNDFILE_EXT)
				if {[file exists $ofnam]} {
					catch {file delete $ofnam}
				}
				incr n
			}
			UnBlock
			catch {file delete $innam}
			break
   		} else {
   			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		UnBlock
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			Inf "Failed To Do Mix To Mono"
			set n 1
			while {$n <= $inchans} {
				set ofnam $outnam
				append ofnam $n $evv(SNDFILE_EXT)
				if {[file exists $ofnam]} {
					catch {file delete $ofnam}
				}
				incr n
			}
			catch {file delete $innam}
			break
		}
		catch {file delete $innam}
		catch {file delete $mixfnam}
		set done 1
	}
	if {!$done} {
		return 0
	}
	if {![file exists $monomchfnam]} {
		if [catch {file rename $mono_mix $monomchfnam} zit] {
			Inf "Cannot Name The File (Cannot Save As A Thumbnail)"
			return 0
		}
	}
	if {[DoThumbnailParse $monomchfnam] <= 0} {
		catch {file delete $monomchfnam} 
		return 0
	}
	set n 1
	while {$n <= $inchans} {	;#	remove intermediate temporary files
		set ofnam $outnam
		append ofnam $n $evv(SNDFILE_EXT)
		if {[file exists $ofnam]} {
			catch {file delete $ofnam}
		}
		incr n
	}
	return 1
}

#-------- Make mono thumbnail of multichan file for SoundView Window

proc MakeSoundViewThumbnail {fnam} {
	global pa pathumb evv wstk wl
	set zfnam [MakeThumbnailFromSoundView $fnam $pa($fnam,$evv(CHANS))]
	if {[string match $zfnam $fnam]} {
		return ""
	}
	set snmixfnam $zfnam
	if [info exists evv(THUMDIR)] {
		set docopy 1
		if {![string match $evv(DFLT_OUTNAME)* $snmixfnam] && ![string match $evv(MACH_OUTFNAME)* $snmixfnam]} {
			set msg "KEEP FOR FUTURE PLAYS"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				set docopy 0
			}			;#	Temporary files (newly created mchan-files) are automatically copied to thumbnail dir, in case viewed a 2nd time
		}				;#	And tempfile-thumbnails are deleted (on naming temp file, or on quitting page) by PurgeTempThumbnails
		if {$docopy} {	;#	Or, on rerunning the process, by DeleteTemporaryFiles
			set thumbfnam [file rootname [file tail $fnam]]
			append thumbfnam $evv(SNDFILE_EXT)
			set thumbfnam [file join $evv(THUMDIR) $thumbfnam]
			set copying 1
			if {[file exists $thumbfnam]} {
				if [catch {file delete $thumbfnam} zit] {
					Inf "Can't Delete Previous Thumbnail"	
					set copying 0
				} else {
					catch {PurgeArray $thumbfnam}
					if [info exists pathumb($thumbfnam,$evv(FTYP))] {
						catch {PurgeThumbProps $thumbfnam}
					}
				} 
			}
			if {$copying} {
				if [catch {file copy $snmixfnam $thumbfnam} zit] {
					Inf "Can't Retain The Thumbnail"	
					set copying 0
				} elseif {[DoThumbnailParse $thumbfnam] <= 0} {
					Inf "Can't Retain The Thumbnail (Failed To Parse)"	
					catch {file delete $thumbfnam}
				}
			}
		}
	}
	return $snmixfnam
}

#--- Mix multichan files to mono to be played by 'Sound View'

proc MakeThumbnailFromSoundView {srcfnam inchans} {
	global CDPidrun prg_dun prg_abortd simple_program_messages pa mono_mix evv 
	set simple_program_messages ""

	set housekeep_version [GetVersion housekeep]
	if {$housekeep_version >= 6} {
		set mono_mix $evv(DFLT_OUTNAME)
		append mono_mix 000 $evv(SNDFILE_EXT)

		if [file exists $mono_mix] {
			catch {file delete $mono_mix}
		}
		set cmd [file join $evv(CDPROGRAM_DIR) housekeep]
		lappend cmd chans 4 $srcfnam $mono_mix
		set CDPidrun 0
		set prg_dun 0
		set prg_abortd 0
		Block "Creating Thumbnail"
		if [catch {open "|$cmd"} CDPidrun] {
			Inf "Creating Thumbnail Failed"
			UnBlock
			return $srcfnam
   		} else {
   			fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
		}
		vwait prg_dun
		if {$prg_abortd} {
			set prg_dun 0
		}
		if {!$prg_dun} {
			Inf "Creating Thumbnail Failed"
			UnBlock
			return $srcfnam
		}
		UnBlock
		set pa($mono_mix,$evv(FTYP)) $evv(SNDFILE)
		set pa($mono_mix,$evv(CHANS)) 1
		return $mono_mix
	}
	set innam $evv(DFLT_OUTNAME)
	append innam 0000
	set outnam $innam
	append outnam "_c"
	append innam $evv(SNDFILE_EXT)
	set mixfnam $evv(DFLT_OUTNAME)
	append mixfnam 000 $evv(TEXT_EXT)
	set mono_mix $evv(DFLT_OUTNAME)
	append mono_mix 000 $evv(SNDFILE_EXT)

	foreach fnam [glob -nocomplain $innam*] {
		catch {file delete $fnam}
	}
	if [file exists $mono_mix] {
		catch {file delete $mono_mix}
	}
	if [catch {file copy $srcfnam $innam} zit] {
		Inf "Failed To Copy Infile"	
		return $srcfnam
	}
	Block "Extracting Channels"
	foreach oldfile [glob -nocomplain $outnam*] {
		lappend oldfiles $oldfile
	}
	if {[info exists oldfiles]} {
		foreach oldfile $oldfiles {
			if [catch {file delete $oldfile} zit] {
				Inf "Channel Extraction Failed"
				ClearThumbnailTemps
				UnBlock
				return $srcfnam
			}
		}
	}
	set cmd [file join $evv(CDPROGRAM_DIR) housekeep]
	lappend cmd chans 2 $innam
	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	if [catch {open "|$cmd"} CDPidrun] {
		Inf "Channel Extraction Failed: Try Again"
		ClearThumbnailTemps
		UnBlock
		return $srcfnam
   	} else {
   		fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
	}
	vwait prg_dun
	UnBlock
	if {$prg_abortd} {
		set prg_dun 0
	}
	if {!$prg_dun} {
		Inf "Channel Extraction Failed: Try Again"
		ClearThumbnailTemps
		return $srcfnam
	}
	set n 1
	while {$n <= $inchans} {
		set ofnam $outnam
		append ofnam $n $evv(SNDFILE_EXT)
		if {![file exists $ofnam]} {
			lappend badfiles $ofnam
		} else {
			lappend ofnams $ofnam
		}
		incr n
	}
	if {[info exists badfiles]} {
		set msg "Failed To Create\n"
		foreach ofnam $badfiles {
			append msg $ofnam "\n"
		}
		Inf $msg
		ClearThumbnailTemps
		return $srcfnam
	}
	foreach ofnam $ofnams {
		set line $ofnam					;#	CREATE STANDARD MIXFILE LINE
		lappend line 0.0 1 1.0
		lappend mixlines $line
	}
	if [catch {open $mixfnam "w"} zit] {
		ClearThumbnailTemps
		return $srcfnam
	}
	foreach line $mixlines {
		puts $zit $line
	}
	close $zit

	set gain [expr 1.0/double($inchans)]
	set cmd [file join $evv(CDPROGRAM_DIR) submix]
	lappend cmd mix $mixfnam $mono_mix -g$gain
	set CDPidrun 0
	set prg_dun 0
	set prg_abortd 0
	Block "Mixing To Mono"
	if [catch {open "|$cmd"} CDPidrun] {
		Inf "Failed To Do Mix To Mono"
		ClearThumbnailTemps
		UnBlock
		catch {file delete $innam}
		return $srcfnam
   	} else {
   		fileevent $CDPidrun readable "HandleProcessOutputWithOnlyErrorsDisplayed"
	}
	vwait prg_dun
	UnBlock
	if {$prg_abortd} {
		set prg_dun 0
	}
	if {!$prg_dun} {
		Inf "Failed To Do Mix To Mono"
		ClearThumbnailTemps
		return $srcfnam
	}
# IF DOING MULTICHANNEL VIEW, WILL WANT TO KEEP THESE FILES -->
	ClearThumbnailTemps
	set pa($mono_mix,$evv(FTYP)) $evv(SNDFILE)
	set pa($mono_mix,$evv(CHANS)) 1
	return $mono_mix
}

#--- Setup style for recycling multichan output: use thumbnails or not

proc SetThumbnailRecyclingStatus {val} {
	global monomix_recycle evv
	set fnam [file join $evv(URES_DIR) "monofy"]
	append fnam $evv(CDP_EXT)
	set monomix_recycle $val
	if {[file exists $fnam]} {
		if [catch {file delete $fnam} zit] {
			Inf "CANNOT UPDATE INFORMATION ON THUMBNAIL RECYCLING, FOR FUTURE SESSIONS"
			return
		}
	}
	if {$val > 0} {
		if [catch {open $fnam "w"} zit] {
			Inf "CANNOT UPDATE INFORMATION ON THUMBNAIL RECYCLING, FOR FUTURE SESSIONS"
			return
		}
		puts $zit $val
		close $zit
	}
}

#--- Are thumbnails used, on recycling a multichan output from params page ??

proc GetThumbnailRecyclingStatus {} {
	global monomix_recycle evv
	set fnam [file join $evv(URES_DIR) "monofy"]
	append fnam $evv(CDP_EXT)
	if {![file exists $fnam]} {
		set monomix_recycle 0
		return
	} elseif [catch {open $fnam "r"} zit] {
		Inf "CANNOT RETRIEVE INFORMATION ON THUMBNAIL RECYCLING"
		set monomix_recycle 0
		return
	}
	while {[gets $zit line] >= 0} {
		set monomix_recycle [string trim $line]
		break
	}
	close $zit
	if {![info exists monomix_recycle] || ![regexp {^[0-2]$} $monomix_recycle]} {
		Inf "CORRUPTED DATA ON THUMBNAIL RECYCLING IN FILE '$fnam'"
		set monomix_recycle 0
		if [catch {file delete $fnam} zit] {
			Inf "CANNOT DELETE CORRUPTED FILE '$fnam'"
		}
	}
}

#--- Establish a directory for Thumbnails, and establish pa(props) of existing thumbnails

proc SetUpThumbnails {} {
	global evv wstk pa pathumb evv thumbs_loaded
	if {[info exists thumbs_loaded]} {
		return
	}
	set qikthumfiles {}
	set do_qikload 0
	set qthfnam [file join $evv(URES_DIR) qikthumb$evv(CDP_EXT)]
	if {[file exists $qthfnam]} {							;#	Check if qikload-thumbnails list (props of thumbnails) exists
		set do_qikload 1									;#	And if so, flag up QikLoad for thumbnails
	}
	set thumdir [file join $evv(URES_DIR) thumbnails]
	if {[file exists $thumdir]} {
		set evv(THUMDIR) $thumdir
		foreach fnam [glob -nocomplain [file join $evv(THUMDIR) *.*]] {
			lappend fnams $fnam
		}
		if {[info exists fnams]} {								;#	If thumbnail files exist
			Block "Loading Thumbnails"
			if {$do_qikload} {									;#	If Qikloading flagged up
				if [catch {open $qthfnam "r"} zit] {			;#	Open qikloading file
					catch {file delete $qthfnam}
				} else {
					while {[gets $zit line] >= 0} {
						set line [string trim $line]			;#	Read all property lists for thumbnails
						if {[llength $line] <= 0} {
							continue
						}
						set line [split $line]
						set cnt -1
						foreach item $line {
							set item [string trim $item]
							if {[string length $item] > 0} {
								switch -- $cnt {
									"-1" {
										set fnam $item
										lappend qikthumfiles $fnam
									}
									default {						;#	Create props for thumbnails
										set pa($fnam,$cnt) $item	;#	And the bakup props
										set pathumb($fnam,$cnt) $item
									}
								}
								incr cnt
							}
						}
					}
				}
			}
			foreach fnam $fnams {								;#	For every existing thumbnail
				set k [lsearch $qikthumfiles $fnam]
				if {$k < 0} {									;#	If not already qikloaded, do a real parse, and load
					if {[DoThumbnailParse $fnam] <= 0} {
						Inf "Failed To Parse Thumbnail For [file rootname [file tail $fnam]]"
						catch {file delete $fnam}
					}
				} else {										;#	But if already qikloaded, delete from qikload-thumbnails list
					set qikthumfiles [lreplace $qikthumfiles $k $k]
				}
			}													;#	After checking all existing thumbnails,
			foreach fnam $qikthumfiles {						;#	if any files remain in qikload-thumbnails list,
				PurgeArray $fnam								;#	these thumbnails must not exist,
				PurgeThumbProps $fnam							;#	so delete their props and bakup props
			}
			UnBlock
		}
	} elseif [catch {file mkdir $thumdir} zit] {				;#	When user first gets this version of the Loom,
		Inf "Cannot Create Directory For Thumbnails"			;#	thumbnails directory is set up
	}
	if {[file exists $qthfnam]} {								;#	Delete qikload-thumbnails list,
		catch {file delete $qthfnam}							;#	ready to write new one at end of session
	}
	set thumbs_loaded 1
}

#------ Parse thumbnail files : bakup pa(props) in "pathumb", so they can be restored if pa is purged

proc DoThumbnailParse {fnam} {
	global CDPid parse_error infile_rejected pa pathumb propslist props_got is_input_parse evv
	set parse_error 0
	set props_got 0
	set infile_rejected 0
	set is_input_parse 0

	set CDPid 0
	set cmd [file join $evv(CDPROGRAM_DIR) cdparse]
	set zzfnam [OmitSpaces $fnam]
	lappend cmd $zzfnam 0
	if [catch {open "|$cmd"} CDPid] {
		catch {unset CDPid}
		return 0
	} else {
		set propslist ""
		fileevent $CDPid readable AccumulateFileProps
	}
	vwait props_got
	if {$parse_error || $infile_rejected || ![info exists propslist] || ([llength $propslist] < 1)} {
		return 0
	}
	set n 0 
	foreach prop $propslist {
		set pa($fnam,$n) $prop
		set pathumb($fnam,$n) $prop
		incr n
	}
	return 1
}

#----- Restore thumbnail pa(props) if pa is purged

proc RestoreThumbnailProps {} {
	global pa pathumb
	foreach nam [array names pathumb] {
		set pa($nam) $pathumb($nam)
	}
}

#--- Set up Loom to use thumbnail version of 'Chosen Files' selected multichannel file

proc WorkWithThumbnail {} {
	global set_thumbnailed thumbnailed thumbfile chlist ww wstk pa evv
	if {![info exists evv(THUMDIR)]} {
		Inf "No Thumbnails Available"
		set set_thumbnailed 0
	}
	if {$set_thumbnailed} {
		if {![info exists chlist] || ([llength $chlist] != 1) || ($pa([lindex $chlist 0],$evv(CHANS)) < 2)} {
			Inf "Put A Single Multichannel Soundfile On Chosen Files List"
			catch {unset thumbnailed}
			set set_thumbnailed 0
			return
		}
		set fnam [lindex $chlist 0]
		set thumbfnam [file tail $fnam]
		set thumbfnam [file join $evv(THUMDIR) $thumbfnam]
		if {![file exists $thumbfnam]} {
			set msg "No Thumbnail Exists For This Sound: Create One ??"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "no"} {
				catch {unset thumbnailed}
				set set_thumbnailed 0
				return
			}
			if {![MakeThumbnail $fnam]} {
				catch {unset thumbnailed}
				set set_thumbnailed 0
				return
			}
		}
		$ww.1.a.mez.bkgd config -state disabled
		set thumbfile $thumbfnam
		set thumbnailed 1
	} else {
		$ww.1.a.mez.bkgd config -state normal
		catch {unset thumbnailed}
	}
}

#--- If use of thumbnail setup for Chosen File, unset it

proc UnsetThumbnail {} {
	global thumbnailed set_thumbnailed
	if {[info exists thumbnailed] || $set_thumbnailed} {
		catch {unset thumbnailed}
		set set_thumbnailed 0
	}
}

#--- Check that any thumbnail loaded corresponds to file finally chosen on Chosen Files list
#--- (Possibly redundant)

proc IsCorrectThumbnail {} {
	global thumbfile set_thumbnailed chlist chlist pa evv
	if {![info exists thumbfile] || ![file exists $thumbfile]} {
		set set_thumbnailed 0
		return 0
	}
	if {![info exists chlist] || ([llength $chlist] != 1)} {
		set set_thumbnailed 0
		return 0
	}
	set fnam [lindex $chlist 0]
	if {![string match [file extension $fnam] $evv(SNDFILE_EXT)]} {
		set set_thumbnailed 0
		return 0
	}
	set fnam [file tail $fnam]
	set fnam [file join $evv(THUMDIR) $fnam]
	if {![string match $fnam $thumbfile]} {
		set set_thumbnailed 0
		return 0
	}
	return 1
}

#------- See Thumbnails, and edit list

proc ThumbSee {doload} {
	global pr_thumbs pathumb wstk evv superlog thumb_badfiles thumbs_loaded
	if {$doload} {
		SetUpThumbnails			;#	If "ThumbSee" called before Workspace is set up, Existing thumbs dir is loaded here, and "thumbs_loaded" is flagged.
		set thumbs_loaded 1		;#	Otherwise "ThumbSee" has been called AFTER Workspace is set up.
								;#	If "thumbs_loaded" was NOT flagged on previous call to ThumbSee, 
								;#	any existing thumbnails would have been  loaded at "SetUpThumbnails" when the Workspace was set up.
	}
	if {![info exists evv(THUMDIR)]} {
		return
	}
	set cnt 0
	foreach fnam [glob -nocomplain [file join $evv(THUMDIR) *.*]] {
		lappend fnams $fnam
		incr cnt
	}
	if {$cnt == 0} {
		Inf "There Are No Thumbnails"
		return
	}
	set f .thumbs
	if [Dlg_Create $f "MONO THUMBNAILS" "set pr_thumbs 0" -borderwidth 2 -width 80] {
		frame $f.1
		label $f.1.ll -text "DELETE "
		button $f.1.del -text "Selected" -command "set pr_thumbs 1" -width 10 -highlightbackground [option get . background {}]
		button $f.1.red -text "Redundant" -command "set pr_thumbs 3" -width 10 -highlightbackground [option get . background {}]
		button $f.1.old -text "Ancient" -command "set pr_thumbs 4" -width 10 -highlightbackground [option get . background {}]
		button $f.1.all -text "All" -command "set pr_thumbs 2" -width 10 -highlightbackground [option get . background {}]
		button $f.1.qui -text "Quit" -command "set pr_thumbs 0" -width 8 -highlightbackground [option get . background {}]
		pack $f.1.ll -side left
		pack $f.1.del $f.1.red $f.1.old $f.1.all -side left -padx 2
		pack $f.1.qui -side right
		pack $f.1 -side top -fill x -expand true
		frame $f.2
		label $f.2.tit -text "Select Items to delete" -fg $evv(SPECIAL)
		label $f.2.f12 -text "Command \"=\" Key shows creation date/time" -fg $evv(SPECIAL)
		Scrolled_Listbox $f.2.ll -width 80 -height 24 -selectmode extended
		pack $f.2.tit $f.2.f12 $f.2.ll -side top -fill both -expand true -pady 2
		pack $f.2 -side top
		wm resizable $f 1 1
		bind $f <Escape>  {set pr_thumbs 0}
		bind $f <Command-=>  {ModificationDate thumbs}
	}
	$f.2.ll.list delete 0 end
	foreach fnam $fnams {
		set nam [file rootname [file tail $fnam]]
		$f.2.ll.list insert end $nam
	}
	set finished 0
	set pr_thumbs 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_thumbs
	while {!$finished} {
		tkwait variable pr_thumbs
		switch -- $pr_thumbs {
			1 {
				set ilist [$f.2.ll.list curselection]
				if {([llength $ilist] <= 0) || (([llength $ilist] == 1) && ([lindex $ilist 0] == -1))} {
					Inf "Select Thumbnails To Delete"
					continue
				}
				$f.2.ll.list selection clear 0 end
				Block "Deleting Thumbnails"
				set ilist [ReverseList $ilist]
				foreach i $ilist {
					set fnam [$f.2.ll.list get $i]
					set delfnam $fnam
					append delfnam $evv(SNDFILE_EXT)
					set delfnam [file join $evv(THUMDIR) $delfnam]
					if [catch {file delete $delfnam} zit] {
						Inf "Failed To Delete Thumbnail '$fnam'"
					} else {
						catch {PurgeArray $delfnam}
						if [info exists pathumb($delfnam,$evv(FTYP))] {
							PurgeThumbProps $delfnam
						}
						incr cnt -1
					}
					$f.2.ll.list delete $i
				}
				UnBlock
				if {$cnt == 0} {
					set finished 1
				}
			}
			2 {
				set msg "Are You Sure You Want To Delete ~All~ Thumbnails ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				Block "Deleting Thumbnails"
				foreach fnam $fnams {
					if {[file exists $fnam]} {
						if [catch {file delete $fnam} zit] {
							Inf "Failed To Delete Thumbnail [file rootname [file tail $fnam]]"
						} else {
							catch {PurgeArray $fnam}
							if [info exists pathumb($fnam,$evv(FTYP))] {
								PurgeThumbProps $fnam
							}
							incr cnt -1
						}
					}
				}
				UnBlock
				if {$cnt == 0} {
					set finished 1
				}
			}
			3 {
				set thumb_badfiles {}
				foreach zfnam [$f.2.ll.list get 0 end] {
					lappend thumb_badfiles $zfnam
				}
				PurgeThumbnails
			}
			4 {
				OutofDateThumbnails $superlog 0
			}
			0 {
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#---- Destroy thumbnails associated with selected multichannel files

proc ThumbKill {fnam} {
	global pa pathumb set_thumbnailed wl wstk evv
	if {[string match $fnam "0"]} {
		set ilist [$wl curselection]
		if {![info exists evv(THUMDIR)]} {
			Inf "No Thumbnails Available"
			set set_thumbnailed 0
		}
		if {([llength $ilist] < 1) || (([llength $ilist] == 1) && ($ilist < 0))} {
			Inf "Select Multichannel Soundfile(s)"
			return
		}
		foreach i $ilist {
			set fnam [$wl get $i]
			if {($pa($fnam,$evv(FTYP)) != $evv(SNDFILE)) || ($pa($fnam,$evv(CHANS)) < 2)} {
				lappend badfiles $fnam
			} else {
				lappend goodfiles $fnam
			}
		}
		if {![info exists goodfiles]} {
			Inf "No Multichannel Files Here"
			return
		}
		if {[info exists badfiles]} {
			Inf "Some Of These Files Are Not Multichannel Files"
		}
		if {[llength $goodfiles] == 1} {
			set msg "Destroy Thumbnail Of File '[lindex $goodfiles 0]' ??"
		} else {
			set msg "Destroy Thumbnails Of [llength $goodfiles] Files ??"
		}
		set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
		if {$choice == "no"} {
			return
		}
	} else {
		set goodfiles $fnam
	}
	foreach fnam $goodfiles {
		set thumfnam [file tail $fnam]
		set thumfnam [file join $evv(THUMDIR) $thumfnam]
		if {[file exists $thumfnam]} {
			if [catch {file delete $thumfnam} zit] {
				Inf "Cannot Delete Thumbnail [file rootname [file tail $thumfnam]]"
			} else {
				catch {PurgeArray $thumfnam}
				if [info exists pathumb($thumfnam,$evv(FTYP))] {
					PurgeThumbProps $thumfnam
				}
			}
		}
	}
}

#----- Remove thumbnails of temporary files (i.e. newly generated multichan files before they are renamed)

proc PurgeTempThumbnails {} {
	global evv
	if {![info exists evv(THUMDIR)] || ![file exists $evv(THUMDIR)]} {
		return
	}
	foreach fnam [glob -nocomplain [file join $evv(THUMDIR) $evv(DFLT_OUTNAME)*]] {
		lappend fnams $fnam
	}
	foreach fnam [glob -nocomplain [file join $evv(THUMDIR) $evv(MACH_OUTFNAME)*]] {
		lappend fnams $fnam
	}
	if {![info exists fnams]} {
		return
	}
	foreach fnam $fnams {
		catch {file delete $fnam}
	}
}

#----- Delete all temp files after failure or success of making temporary thumbnail

proc ClearThumbnailTemps {} {
	global evv
	set tempfnam $evv(DFLT_OUTNAME)
	append tempfnam 0000
	foreach fnam [glob -nocomplain $tempfnam*] {
		catch {file delete $fnam}		;#	Extracted channels of multichan file
	}
	set tempfnam $evv(DFLT_OUTNAME)
	append tempfnam 000 $evv(TEXT_EXT)
	catch {file delete $tempfnam}		;#	Delete intermediate mixfile
}

#----- Delete all Thumbnails for which no srcfiles exist

proc PurgeThumbnails {} {
	global wstk evv pa pathumb pa_thumpurj thumpurjdir readonlyfg readonlybg thumb_badfiles
	if {![info exists evv(THUMDIR)] || ![file exists $evv(THUMDIR)] || ![file isdirectory $evv(THUMDIR)]} {
		Inf "No Thumbnails Exist"
		return
	}
	foreach fnam [glob -nocomplain [file join $evv(THUMDIR) *.*]] {
		lappend badthumbs [file tail $fnam]
	}
	if {![info exists badthumbs]} {
		Inf "No Thumbnails Exist"
		return
	}
	set f .thumpurj
	if [Dlg_Create $f "FIND REDUNDANT THUMBNAILS" "set pa_thumpurj 0" -borderwidth 2 -width 80] {
		frame $f.1
		button $f.1.del -text "Find Thumbnail Srcs" -command "set pa_thumpurj 1" -width 28 -highlightbackground [option get . background {}]
		button $f.1.bad -text "Delete Selected Thumbnails" -command "set pa_thumpurj 2" -width 28 -highlightbackground [option get . background {}]
		button $f.1.all -text "Delete All Listed Thumbnails" -command "set pa_thumpurj 3" -width 28 -highlightbackground [option get . background {}]
		button $f.1.qui -text "Quit" -command "set pa_thumpurj 0" -width 8 -highlightbackground [option get . background {}]
		pack $f.1.del $f.1.bad $f.1.all -side left -padx 2
		pack $f.1.qui -side right
		pack $f.1 -side top -fill x -expand true
		label $f.0 -text "CDP Base Directory (and its subdirectories) is always searched,\nas well as any directory you specify (and its subdirs)" -fg $evv(SPECIAL)
		label $f.000 -text "Always specify the directory at the ~ROOT~ of your sound storage area" -fg $evv(SPECIAL)
		pack $f.0 $f.000 -side top -pady 2
		frame $f.2
		label $f.2.ll -text "Directory To Search "
		entry $f.2.e -textvariable thumpurjdir -width 32 -state readonly -bg $readonlybg -fg $readonlyfg
		button $f.2.b -text "Find Directory" -command {DoListingOfDirectories .thumpurj.2.e} -highlightbackground [option get . background {}]
		button $f.2.c -text "Clear" -command {set thumpurjdir ""} -highlightbackground [option get . background {}]
		pack $f.2.ll $f.2.e $f.2.b $f.2.c -side left -padx 2
		pack $f.2 -side top -pady 2
		frame $f.2a -bg $evv(POINT) -height 1
		pack $f.2a -side top -fill x -expand true -pady 4
		frame $f.3
		label $f.3.tit -text "Thumbnails with no srcs in specified directory, or CDP base directory" -fg $evv(SPECIAL)
		Scrolled_Listbox $f.3.ll -width 80 -height 24 -selectmode extended
		pack $f.3.tit $f.3.ll -side top -fill both -expand true -pady 2
		pack $f.3 -side top -pady 2
		wm resizable $f 1 1
		bind $f <Escape>  {set pa_thumpurj 0}
		bind $f <Command-=>  {ModificationDate redthumbs}
	}
	$f.1.all config -text "" -command {} -bd 0
	$f.1.bad config -text "" -command {} -bd 0
	$f.3.tit config -text ""
	$f.3.ll.list delete 0 end
	set searched_basedir 0
	set finished 0
	set pa_thumpurj 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pa_thumpurj $f.2.e 
	while {!$finished} {
		tkwait variable pa_thumpurj
		switch -- $pa_thumpurj {
			1 {
				$f.1.all config -text "" -command {} -bd 0
				$f.1.bad config -text "" -command {} -bd 0
				$f.3.tit config -text ""
				$f.3.ll.list delete 0 end
				if {[string length $thumpurjdir] <= 0} {
					set msg "No Search Directory Specified : Search CDP Base Directory Only ??"
					set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
				} elseif {![file exists $thumpurjdir] || ![file isdirectory $thumpurjdir]} {
					Inf "Directory '$thumpurjdir' Does Not Exist"
					continue
				}
				Block "Checking Thumbnail Files"
				if {!$searched_basedir} {
					set current_pwd [pwd]
					set len [llength $badthumbs]
					set n 0
					while {$n < $len} {
						set fnam [lindex $badthumbs $n]
						if {[SearchDirectoryForThumbnailSrcFile $current_pwd $fnam]} {
							set badthumbs [lreplace $badthumbs $n $n]
							incr len -1
						} else {
							incr n
						}
					}
					set searched_basedir 1
				}
				if {[string length $thumpurjdir] > 0} {
					set len [llength $badthumbs]
					set n 0
					while {$n < $len} {
						set fnam [lindex $badthumbs $n]
						if {[SearchDirectoryForThumbnailSrcFile $thumpurjdir $fnam]} {
							set badthumbs [lreplace $badthumbs $n $n]
							incr len -1
						} else {
							incr n
						}
					}
				}
				foreach fnam $badthumbs {
					$f.3.ll.list insert end $fnam
				}
				if {[llength $badthumbs] <= 0} {
					unset badthumbs
				}
				UnBlock
				if {[info exists badthumbs]} {
					set msg "Warning:\n\n"
					append msg "The Listed Thumbnails ~MAY~ Correspond To Multichannel Files\n\n"
					append msg "Which Are In ~Other Directories~ You Have Not Specified.\n\n"
					append msg "Always Specify The Directory At The Root Of Your Sound Storage Area"
					Inf $msg
					$f.1.all config -text "Delete All Listed Thumbnails" -command "set pa_thumpurj 3" -bd 2
					$f.1.bad config -text "Delete Selected Thumbnails" -command "set pa_thumpurj 2" -bd 2
					$f.3.tit config -text "Thumbnails with no srcs in specified directory"
				} else {
					set msg "All Thumbnails Appear To Have Corresponding Multichannel Sources.\n"
					append msg "\n"
					append msg "However, Existing Thumbnails With Commonly Used Names\n"
					append msg "May Not Correspond To Multichannel Files Of Same Name.\n"
					append msg "\n"
					append msg "To Delete Individual Thumbnails, Use The Next Window.\n"
					Inf $msg
					set finished 1
				}
			}
			2 {
				set ilist [$f.3.ll.list curselection]
				if {![info exists ilist] || ([llength $ilist] <= 0) || (([llength $ilist] == 1) && ([lindex $ilist 0] == -1))} {
					Inf "No Thumbnails Selected For Deletion"
					continue
				}
				Block "Deleting Bad Thumbnails"
				set ccnt [llength $badthumbs]
				set cnt 0
				set ilist [ReverseList $ilist]
				set badthumbs [ReverseList $badthumbs]
				set badfiles_update 0
				foreach i $ilist {
					set fnam [file join $evv(THUMDIR) [$f.3.ll.list get $i]]
					if {![catch {file delete $fnam} zit]} {
						$f.3.ll.list delete $i
						set kk [lsearch $thumb_badfiles [file rootname [file tail $fnam]]]
						if {$kk >= 0} {
							set thumb_badfiles [lreplace $thumb_badfiles $kk $kk]
							set badfiles_update 1
						}	
						set badthumbs [lreplace $badthumbs $i $i]
						incr cnt
					}
					if [info exists pa($fnam,$evv(FTYP))] {
						PurgeArray $fnam
					}
					if [info exists pathumb($fnam,$evv(FTYP))] {
						PurgeThumbProps $fnam
					}
				}
				if {$cnt == $ccnt} {
					$f.3.tit config -text ""
					$f.1.all config -text "" -command {} -bd 0
					$f.1.bad config -text "" -command {} -bd 0
					catch {unset badthumbs}
				} else {
					set badthumbs [ReverseList $badthumbs]
				}
				if {$badfiles_update} {
					.thumbs.2.ll.list delete 0 end		;#	Update listing in calling window
					foreach fnam $thumb_badfiles {
						.thumbs.2.ll.list insert end $fnam
					}
				}
				set searched_basedir 0
				UnBlock
			}
			3 {
				set msg "Are You Sure You Want To Delete ~ALL~ The Thumbnails Listed ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
				Block "Deleting Bad Thumbnails"
				set i 0
				set ccnt [llength $badthumbs]
				while {$i < $ccnt} {
					lappend ilist $i
					incr i
				}
				set ilist [ReverseList $ilist]
				set badthumbs [ReverseList $badthumbs]
				set cnt 0
				set badfiles_update 0
				foreach i $ilist {
					set fnam [file join $evv(THUMDIR) [$f.3.ll.list get $i]]
					if {![catch {file delete $fnam} zit]} {
						$f.3.ll.list delete $i
						set badthumbs [lreplace $badthumbs $i $i]
						set kk [lsearch $thumb_badfiles [file rootname [file tail $fnam]]]
						if {$kk >= 0} {
							set thumb_badfiles [lreplace $thumb_badfiles $kk $kk]
							set badfiles_update 1
						}	
						incr cnt
					}
					if [info exists pa($fnam,$evv(FTYP))] {
						PurgeArray $fnam
					}
					if [info exists pathumb($fnam,$evv(FTYP))] {
						PurgeThumbProps $fnam
					}
				}
				if {$cnt == $ccnt} {
					$f.3.tit config -text ""
					$f.1.all config -text "" -command {} -bd 0
					$f.1.bad config -text "" -command {} -bd 0
					catch {unset badthumbs}
				} else {
					set badthumbs [ReverseList $badthumbs]
				}
				if {$badfiles_update} {
					.thumbs.2.ll.list delete 0 end		;#	Update listing in calling window
					foreach fnam $thumb_badfiles {
						.thumbs.2.ll.list insert end $fnam
					}
				}
				set searched_basedir 0
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

#--- Search Directories for files corresponding to thumbs

proc SearchDirectoryForThumbnailSrcFile {dirname str} {
	global evv
	if {[string first soundloom$evv(EXEC) $dirname] >= 0} {
		return 0
	} 
	foreach fnam [glob -nocomplain [file join $dirname *]] {
		if {[file isdirectory $fnam]} {
			if {![CDP_Restricted_Directory $fnam 1]} {
				if {[SearchDirectoryForThumbnailSrcFile $fnam $str]} {
					return 1
				}
			}
			continue
		}
		if {![string match [file extension $fnam] $evv(SNDFILE_EXT)]} {
			continue
		}
		set rfnam [file tail $fnam]
		if {[string match $str $rfnam]} {
			return 1
		}
	}
	return 0
}

#------ Delete special properties store for thumbnails

proc PurgeThumbProps {fnam} {
	global pathumb evv
	set propno 0									;#	so delete their props and bakup props
	while {$propno < ($evv(CDP_PROPS_CNT) + $evv(CDP_MAXSAMP_CNT))} {
		catch {unset pathumb($fnam,$propno)}
		incr propno
	}
}

#----- Check out-of-date thumbnails at startup

proc OutofDateThumbnails {date startup} {
	global evv development_version wstk month_end fastskip
	set twenty_one_days [expr 21 * $evv(SECS_PER_DAY)]
	set thumdir [file join $evv(URES_DIR) thumbnails]
	if {![file exists $thumdir]} {
		if {!$startup} {
			Inf "No Thumbnails Are Over 3 Weeks Old"
		}
		return
	}
	set month [string range $date 0 2]
	set date [string range $date 3 end]
	set date [split $date "_"]
	set day [lindex $date 0]
	if {[string match [string index $day 0] "0"]} {	;#	reject any leading zero in day-number
		set day [string index $day 1]
	}
	set date [lindex $date 1]
	set date [split $date "."]
	set year [lindex $date 1]
	set n 2010
	set now $evv(SECS_BEFORE_2010)
	while {$n < $year} {
		if {[expr $n % 4] == 0} {
			set now [expr $now + $evv(LEAP_YEAR_SECS)]
		} else {
			set now [expr $now + $evv(YEAR_SECS)]
		}
		incr n
	}
	if {[expr $n % 4] == 0} {
		set is_leap 1
	} else {
		set is_leap 0
	}
	switch -- $month {
		"Jan" {
			set monthno 1
		}
		"Feb" {
			set monthno 2
		}
		"Mar" {
			set monthno 3
		}
		"Apr" {
			set monthno 4
		}
		"May" {
			set monthno 5
		}
		"Jun" {
			set monthno 6
		}
		"Jul" {
			set monthno 7
		}
		"Aug" {
			set monthno 8
		}
		"Sep" {
			set monthno 9
		}
		"Oct" {
			set monthno 10
		}
		"Nov" {
			set monthno 11
		}
		"Dec" {
			set monthno 12
		}
	}
	if {![info exists monthno]} {
		if{$development_version} {
			Inf "Month Being Read Incorrectly: Month Mnemonic Is '$month'"
		}
		return
	}
	set now [expr $now + $month_end([expr $monthno - 1],$is_leap)]
	set now [expr $now + ($day * $evv(SECS_PER_DAY))]
	foreach fnam [glob -nocomplain [file join $thumdir *.*]] {
		set datestamp [file mtime $fnam]
		if {[expr $now - $datestamp] > $twenty_one_days} {
			lappend badfiles [file rootname [file tail $fnam]]
		}
	}
	if {$startup} {
		if {![info exists fastskip]} {
			if {[info exists badfiles]} {
				set msg "Some Thumbnails Are Over 3 Weeks Old: Show These ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					return
				}
				set msg "Thumbnails Over 3 Weeks Old\n"
				set cnt 0
				foreach fnam $badfiles {
					append msg "\n$fnam"
					incr cnt
					if {$cnt >= 20} {
						append msg "\nAND MORE"
					}
				}
				append msg "\n\nDelete Unwanted Thumbnails ??"
				set choice [tk_messageBox -type yesno -default no -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "yes"} {
					ThumbSee 1
				}
				Inf $msg
			}
		}
	} else {
		if {[info exists badfiles]} {
			.thumbs.2.ll.list delete 0 end
			foreach fnam $badfiles {
				.thumbs.2.ll.list insert end $fnam
			}
		} else {
			Inf "~No~ Thumbnails Are Over 3 Weeks Old\n"
		}
	}
}
