#
# SOUND LOOM RELEASE mac version 17.0.4
#

#----- NEW MANAGEMENT OF SOUNDFILES IN MIXFILE
#----- For existing users , who already have mixfiles..
#----- Incorporates these into the mix management system, on 1st LOADING the workspace
# ---- Also checks consistency of loaded files which are supposed to me mixfiles 
#----- (i.e. could have been bad-edited outside CDP)

proc MixMUpgrade {} {
	global mixmanage mixmanage_badmixes wl pa evv
	set update 0
	foreach fnam [$wl get 0 end] {
		set ftyp $pa($fnam,$evv(FTYP))
		if {[IsAMixfileIncludingMultichan $ftyp]} {	;#	ADDS ANY MIXFILES NOT IN MIX MANAGEMENT SYSTEM, TO SYSTEM
			if {![info exists mixmanage($fnam)]} {
				if {[MixMUpdate $fnam 0]} {
					set update 1
				}
			}
		} else {
			if {[info exists mixmanage($fnam)]} {	;#	REMOVES FRON MIX MANAGEMENT SYSTEM, FILES WHICH ARE NO LONGER MIXFILES
				unset mixmanage($fnam)
				set update 1
			}
		}
	}
	if {$update} {
		MixMStore
	}
	if {[info exists mixmanage_badmixes]} {			;#	CHECK 'MIXFILES' THAT SEEMED NO LONGER VALID WHEN MIXMANAGER LOADED
		foreach mixfile $mixmanage_badmixes {
			if {[file exists $mixfile]} {			
				if {![info exists mixmanage($mixfile)]} {
					lappend badmixes $mixfile		;#	IF THEY ARE STILL NO LONGER VALID, AFTER PARSING ACTUAL WORKSPACE FILES
				}
			}
		}
		if {[info exists badmixes]} {				;#	GIVE WARNING TO USER
			set msg "The Following Mixfile"
			if {[llength $badmixes] > 1} {
				append msg "s Use"
			} else {
				append msg " Uses"
			}
			append msg " One Or More Soundfiles That Seem To No Longer Exist.\n\n"
			set cnt 0
			foreach zfnam $badmixes {
				append msg $zfnam "\n"
				incr cnt
				if {$cnt >= 20} {
					append msg "And More\n"
					break
				}
			}
			append msg "\nIf You Wish To Recover "
			if {[llength $badmixes] > 1} {
				append msg "These As Operational Mixfiles,\nEdit Them "
			} else {
				append msg "This As An Operational Mixfile,\nEdit It "
			}
			append msg "On The Workspace.\n"
			Inf $msg
		}
		unset mixmanage_badmixes
	}
}

#----- loads existing mix management data from storage, and checks for file-existence, with warnings

proc MixMLoad {} {
	global mixmanage mixmanage_badmixes evv
	set fnam [file join $evv(URES_DIR) $evv(MIXMANAGE)$evv(CDP_EXT)]
	if {![file exists $fnam]} {
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot Open File '$fnam' To Manage Your Mixfiles"
		return
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		set line [split $line]
		catch {unset nuline}
		foreach item $line {
			if {[string length $item] <= 0} {
				continue
			}
			lappend nuline $item
		}
		if {[info exists nuline]} {
			set OK 1
			set mixf [lindex $nuline 0]
			if {![file exists $mixf]} {
				set OK 0
			}
			if {$OK} {
				set nuline [lrange $nuline 1 end]
				foreach zfnam $nuline {
					if {![file exists $zfnam]} {
						lappend badmixes $mixf
						set OK 0
						break
					}
				}
			}
			if {$OK} {
				set mixmanage($mixf) $nuline
				continue
			}
		}
	}
	close $zit
	MixMStore
	if {[info exists badmixes]} {		;#	REMEMBER 'MIXFILES' THAT ARE NO LONGER VALID
		set mixmanage_badmixes $badmixes
	}
}

#----- stores mix management data to a file

proc MixMStore {} {
	global mixmanage mixmanage_sndrenames mixmanage_data evv
	if {![info exists mixmanage]} {
		return
	}
	if {[info exists mixmanage_sndrenames]} {
		RationaliseMixRevisionData
		if {[info exists mixmanage_data]} {
			foreach name [array names mixmanage_data] {
				UpdateMixfile $mixmanage_data($name)
			}
			MixManageReport
		}
		unset mixmanage_sndrenames
		unset mixmanage_data
	}
	set tempfnam $evv(DFLT_TMPFNAME)
	if [catch {open $tempfnam "w"} zit] {
		Inf "Canot Open Temporary File '$tempfnam' To Record Mix Management Data"
		return
	}
	foreach name [array names mixmanage] {
		set nuline $name
		foreach item $mixmanage($name) {
			lappend nuline $item
		}
		puts $zit $nuline
	}
	close $zit
	set fnam [file join $evv(URES_DIR) $evv(MIXMANAGE)$evv(CDP_EXT)]
	if [file exists $fnam] {
		if [catch {file delete $fnam} zit1] {
			set msg	"Cannot Delete Existing Mixmanager File ($fnam) To Write New One.\n"
			append msg "New Data Is In File '$tempfnam'.\n"
			append msg " To Preserve This Data, Delete The Existing File '$fnam',\n"
			append msg "And Rename '$tempfnam' To '$fnam' Outside The Sound Loom, Before Proceeding"
			Inf $msg
			return
		}
	}
	if [catch {file rename $tempfnam $fnam} zit2] {
		set msg	"Cannot Rename Temporary File '$tempfnam' To '$fnam'\n"
		append msg "To Preserve Mix Management Data,\n"
		append msg "Rename This File Outside The Sound Loom, Before Proceeding"
		Inf $msg
		return
	}
}

#-----  On Creating a NEW mixfile, or editing an existing mixfile, OR OVERWRITING an existing file, updates the mix management data

proc MixMUpdate {mixfnam dostore} {
	global mixmanage
	if {[IsCDPTempfile $mixfnam]} {
		return 0
	}
	if [catch {open $mixfnam "r"} zit] {
		Inf "Cannot Open Mixfile '$mixfnam' To Update Mix Management Data"
		return 0
	}
	while {[gets $zit line] >= 0} {				;#	GET SNDFILE DATA FROM MIXFILE
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
			if {[string match [string index $item 0] ";"]} {
				continue
			}
			if {[file exists $item]} {
				if {![info exists nuline]} {
					set nuline $item
				} else {
					set k [lsearch $nuline $item]
					if {$k < 0} {
						lappend nuline $item
					}
				}
			}
			break
		}
	}
	close $zit
	if {![info exists nuline]} {				;#	IF NO SNDFILE DATA FOUND
		if {[info exists mixmanage($mixfnam)]} {
			unset mixmanage($mixfnam)
			if {$dostore} {						;#	IF MIXMANAGE DATA EXISTS FOR FILE, DELETE IT
				MixMStore
			}
			return 1
		}
		return 0								;#	OTHERWISE RETURN 'NO-UPDATE'
	}
												;#	IF SNDFILE DATA DOES EXIST
	set newdata 1							
	if {[info exists mixmanage($mixfnam)]} {	;#	IF MIXMANAGE DATA FOR FILE ALREADY EXISTS
		if {[llength $nuline] == [llength $mixmanage($mixfnam)]} {
			set newdata 0						;#	CHECK IF IT HAS CHANGED
			foreach fnam $nuline {
				set k [lsearch $mixmanage($mixfnam) $fnam]
				if {$k < 0} {					;#	AND IF SO, SET TO UPDATE IT
					set newdata 1
					break
				}
			}
		}
	}
	if {$newdata} {								;#	IF DATA HAS CHANGED (OR IF THIS IS ENTIRELY NEW MIXFILE)
		set mixmanage($mixfnam) $nuline			;#	UPDATE MIX MANAGER
		if {$dostore} {
			MixMStore
		}
		return 1
	}
	return 0									;#	IF NO CHANGE,  RETURN 'NO-UPDATE'
}

#-----  On Renaming any file.  NB Must have file EXTENSION!!!! ... updates the mix management data

proc MixMRename {fnam nufnam dostore} {
	global mixmanage mixmanage_sndrenames
	set storable 0
	if [info exists mixmanage($fnam)] {
		set mixmanage($nufnam) $mixmanage($fnam)
		unset mixmanage($fnam)
		set storable 1
	} else {
		if {![info exists mixmanage]} {
			return 0
		}
		set update 0
		foreach name [array names mixmanage] {
			set k [lsearch $mixmanage($name) $fnam]
			if {$k >= 0} {
				lappend sndrenames $name $fnam $nufnam
				set update 1
			}
		}
		if {$update} {
			if {$dostore} {								;#	UPDATES A SINGLE RENAMED SOUNDFILE
				set storable [UpdateMixfile $sndrenames]		
				MixManageReport
				catch {unset mixmanage_sndrenames}
			} elseif {[info exists mixmanage_sndrenames]} {
				set mixmanage_sndrenames [concat $mixmanage_sndrenames $sndrenames]
				set storable 1
			} else {
				set mixmanage_sndrenames $sndrenames		;#	OTHERWISE, UPDATES ARE ACCULUMULATED IN mixmanage_sndrenames
				set storable 1
			}												;#	DO BE DONE WHEN MixMStore IS CALLED
		} else {
			return 0
		}
	}
	if {$storable} {
		if {$dostore} {
			MixMStore
		}
		return 1
	}
	return 0
}

#-----  On Deleting any mixfile, updates the mix management data 

proc MixMDelete {fnam dostore} {
	global mixmanage wstk wl files_deleted rememd evv

	if {[IsCDPTempfile $fnam]} {
		return 0
	}
	set storable 0
	if [info exists mixmanage($fnam)] {
		unset mixmanage($fnam)
		set storable 1
	} else {
		return 0
	}
	if {$storable && $dostore} {
		MixMStore
	}
	return 1
}

#-----  On Deleting any soundfile, updates the mix management data 

proc MixMSndDelete {warning dostore delnames} {
	global mixmanage wstk wl files_deleted rememd del_mixm evv

	if {$warning} {
		set msg "Deleting File"
		if {[llength $del_mixm] > 1} {
			append msg "s"
		}
		set cnt 0
		foreach fnam $del_mixm {
			append msg "  $fnam"
			incr cnt
			if {$cnt > 4} {
				append msg "  etc."
				break
			}
		}
		append msg "\nInvalidates The Following Mixfile"
		if {[llength $delnames] > 1} {
			append msg "s"
		}
		append msg "\n\n"
		set cnt 0
		foreach mixname $delnames {
			append msg $mixname "\n"
			incr cnt
			if {$cnt >= 20} {
				append msg "And More.....\n"
				break
			}
		}
		append msg "\nDo You Want To Delete The Mixfile"
		if {[llength $delnames] > 1} {
			append msg "s"
		}
		append msg " ??"
		set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
		if {$choice == "no"} {
			return 0
		}
	}
	foreach mixname $delnames {
		set is_on_workspace 0
		set i [LstIndx $mixname $wl]
		if {$i >= 0} {
			set is_on_workspace 1
		}
		if [catch {file delete $mixname} q] {
			lappend undeleted_files "$mixname"
		} else {
			if {$is_on_workspace} {
				PurgeArray $mixname
				RemoveFromChosenlist $mixname
			}
			RemoveFromChoiceBakup $mixname
			RemoveFromDirlist $mixname
			if {$is_on_workspace} {
				lappend deleted_file_indeces $i
			}
			DummyHistory $mixname "DESTROYED"
			lappend deleted_files $mixname
		}
	}
	if {[info exists deleted_files]} {
		DoMixfileSndDeletionUpdates $deleted_files delete
	}
	if [info exists deleted_file_indeces] {
		foreach i [lsort -integer -decreasing $deleted_file_indeces] {
			WkspCnt [$wl get $i] -1
			$wl delete $i
		}
		set files_deleted 1
		catch {unset rememd}
	}
	if {[info exists undeleted_files]} {
		set msg "Failed To Delete The Following File"
		if {[llength $undeleted_files] > 1} {
			append msg "s"
		}
		append msg "\n\n"
		foreach mixname $undeleted_files {
			append msg $mixname "\n"
			incr cnt
			if {$cnt >= 20} {
				append msg "And More.....\n"
				break
			}
		}
		Inf $msg
	}
	if {[info exists deleted_files]} {
		foreach mixname $deleted_files {
			unset mixmanage($mixname)
		}
		set storable 1 
	} else {
		return 0
	}
	if {$storable && $dostore} {
		MixMStore
	}
	return 1
}


proc LoadLastMix {} {
	global last_mix wl evv
	set fnam [file join $evv(URES_DIR) $evv(LASTMIX)$evv(CDP_EXT)]
	if {![file exists $fnam]} {
		return
	}
	if [catch {open $fnam "r"} zit] {
		return
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		set line [split $line]
		foreach item $line {
			if {[string length $item] <= 0} {
				continue
			}
			set zzz $item
			break
		}
	}
	close $zit
	if {[info exists zzz]} {
		if {[LstIndx $zzz $wl] >= 0} {
			set last_mix $zzz
		}
	}
}
	
proc SaveLastMix {} {
	global last_mix evv
	set empty 0
	if {[info exists last_mix]} {
		set tempfnam $evv(DFLT_TMPFNAME)
		if [catch {open $tempfnam "w"} zit] {
			set empty 1
		} else {
			puts $zit $last_mix
			close $zit
		}
	} else {
		set empty 1
	}
	set fnam [file join $evv(URES_DIR) $evv(LASTMIX)$evv(CDP_EXT)]
	if {[file exists $fnam]} {
		if [catch {file delete $fnam} zit2] {
			return
		}
	}
	if {!$empty} {
		catch {file rename $tempfnam $fnam}
	}
}

proc UpdatedIfAMix {fnam dostore} {
	global evv
	if {[IsCDPTempfile $fnam]} {
		return 0
	}
	set ftyp [FindFileType $fnam]
	if {$ftyp < 0} {
		return 0
	}
	if {![IsAMixfileIncludingMultichan $ftyp]} {
		return 0
	}
	return [MixMUpdate $fnam $dostore]
}

proc IsCDPTempfile {fnam} {
	global evv
	if {[string match $evv(DFLT_TMPFNAME)* $fnam]} {
		return 1
	}
	if {[string match $evv(DFLT_OUTNAME)* $fnam]} {
		return 1
	}
	if {[string match $evv(MACH_OUTFNAME)* $fnam]} {
		return 1
	}
	return 0
}

proc MixMPurge {dostore} {
	global mixmanage
	set storable 0
	if {![info exists mixmanage]} {
		return 0
	}
	foreach name [array names mixmanage] {
		if {![file exists $name]} {
			unset mixmanage($name)
			set storable 1
		}
	}
	if {$storable} {
		if {$dostore} {
			MixMStore
		}
		return 1
	}
	return 0
}

proc CopiedIfAMix {fnam nufnam dostore} {
	global evv mixmanage
	if {[IsCDPTempfile $nufnam]} {
		return 0
	}
	set ftyp [FindFileType $fnam]
	if {$ftyp < 0} {
		return 0
	}
	if {![IsAMixfileIncludingMultichan $ftyp]} {
		return 0
	}
	if {[info exists mixmanage($fnam)]} {
		set newdata 1							
		if {[info exists mixmanage($nufnam)]} {		;#	IF MIXMANAGE DATA FOR FILE ALREADY EXISTS
			if {[llength $mixmanage($nufnam)] == [llength $mixmanage($fnam)]} {
				set newdata 0						;#	CHECK IF IT HAS CHANGED
				foreach zfnam $mixmanage($nufnam) {
					set k [lsearch $mixmanage($fnam) $zfnam]
					if {$k < 0} {					;#	AND IF SO, SET TO UPDATE IT
						set newdata 1
						break
					}
				}
			}
		}
		if {$newdata} {
			set mixmanage($nufnam) $mixmanage($fnam)
			if {$dostore} {
				MixMStore
			}
			return 1
		}
	}
	return 0
}

#----- New mixfile made from existing mixfiles

proc MixMMerge {mixfnam} {
	global chlist mixmanage
	if {![info exists chlist]} {
		return
	}
	set nulist {}
	foreach fnam $chlist {
		if {![info exists mixmanage($fnam)]} {
			return
		}
		foreach zfnam $mixmanage($fnam) {
			set k [lsearch $nulist $zfnam]
			if {$k < 0} {
				lappend nulist $zfnam
			}
		}
	}
	if {[llength $nulist] > 0} {
		set mixmanage($mixfnam) $nulist
		MixMStore
	}
}

proc IsInAMixfile {thisfnam} {
	global mixmanage
	if {![info exists mixmanage]} {
		return 0
	}
	foreach name [array names mixmanage] {
		foreach fnam $mixmanage($name) {
			if {[string match $fnam $thisfnam]} {
				return 1
			}
		}
	}
	return 0
}

proc MixM_ManagedDeletion {delete_mixmanage} {
	global mixmanage wstk del_mixm 
	set save_mixmanage 0
	set warning 0
	foreach mixname [array names mixmanage] {
		if {![file exists $mixname]} {
			if [info exists mixmanage($mixname)] {
				unset mixmanage($mixname)
				set save_mixmanage 1
			}
		}
	}
	if {[info exists mixmanage]} {
		set delfiles {}
		foreach fnam $delete_mixmanage {
			set delfiles [concat $delfiles [CheckMixMSndDelete $fnam]]
		}
		if {[llength $delfiles] > 0} {
			set delfiles [RationaliseDelfiles $delfiles]
			set msg "Deleting Some Files Has Invalidated Certain Mixfiles:\n Do You Want These To Be Deleted Too ??"
			set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
			if {$choice == "yes"} {
				set msg "Do You Want To Be Informed Of Which Mixfiles Will Be Deleted ??"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "yes"} {
					set warning 1
				}
				set del_mixm $delete_mixmanage
				if {[MixMSndDelete $warning 0 $delfiles]} {
					set save_mixmanage 1
				}
			} else {
				DoMixfileSndDeletionUpdates $delfiles modify
			}
		}
	}
	return $save_mixmanage
}

proc MixMSwap {name1 name2 dostore} {
	global mixmanage pa evv
	if {![info exists mixmanage]} {
		return 0
	}
	set storable 0
	set ftyp $pa($name1,$evv(FTYP))
	if {[IsAMixfile $ftyp]} {
		if {[info exists mixmanage($name1)]} {
			set list1 $mixmanage($name1) 
		}
		if {[info exists mixmanage($name2)]} {
			set list2 $mixmanage($name2)
		}
		if {[info exists list1]} {
			set mixmanage($name2) $list1
			set storable 1
		}
		if {[info exists list2]} {
			set mixmanage($name1) $list2
			set storable 1
		}
	} elseif {$ftyp == $evv(SNDFILE)} {
		MixMRename $name1 $name2 0		;#	This creates triplet-list of "mixfile oldname newname" for each renamable file.
		MixMRename $name2 $name1 0		;#  called "mixmanage_sndrenames"
		set storable 1
	}									
	if {$storable} {
		if {$dostore} {
			MixMStore
		}
		return 1
	}
	return 0
}

#------ Get name of mixfile and pairs of oldname-newname sndfile renamings in that mixfile .. update mixfile, and mixmanager data

proc UpdateMixfile {sndrenames} {
	global mixmanage mixupdate_badfiles mixupdate_goodfiles mixupdate_delfiles mixupdate_bypass wstk evv
	set mixname [lindex $sndrenames 0]
	set update 0
	set upgrade 0
	set tempfnam $evv(DFLT_TMPFNAME)
	if {[file exists $tempfnam]} {
		if [catch {file delete $tempfnam} zit0] {
			set badfile $mixname
		}
	}
	if {![info exists badfile]} {
		if {![file exists $mixname]} {
			catch {unset mixmanage($mixname)}
			set update 1
		} elseif [catch {open $mixname "r"} zit1] {
			set badfile $mixname
		} else {
			set upgrade 0
			foreach {fnam nufnam} [lrange $sndrenames 1 end] {
				lappend fnams $fnam
				lappend nufnams $nufnam
			}
			catch {unset nulines}
			while {[gets $zit1 line] >= 0} {
				set line [string trim $line]
				if {[string length $line] <= 0} {
					continue
				}
				set line [split $line]
				set firstword [lindex $line 0]
				set k [lsearch $fnams $firstword]
				if {$k >= 0} {
					set line [lreplace $line 0 0 [lindex $nufnams $k]]
					set upgrade 1
				}
				catch {unset nuline}	;# STRIP BAD SPACES
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
		catch {close $zit1}
		if {$upgrade} {
			if [catch {open $tempfnam "w"} zit2] {
				set badfile $mixname
			} else {
				foreach line $nulines {
					set line [StripLocalCurlies $line]
					puts $zit2 $line
				}
				close $zit2
				if [catch {file rename -force $tempfnam $mixname} zit4] {
					set msg "Permission Is Being Denied To Overwrite The Original '$mixname'.\n\n"
					append msg "Save With An Alternative Name ??"
					set choice [tk_messageBox -type yesno -default yes -message $msg -icon question -parent [lindex $wstk end]]
					if {$choice == "yes"} {
						set ext [file extension $mixname]
						set nuname [file rootname $mixname]
						while {[file exists $nuname$ext]} {
							append nuname "_a"
						}
						if [catch {file rename -force $tempfnam $nuname$ext} zit4] {
							set msg "Permission Is Still Being Denied To Rename The Temporary File '$tempfnam'.\n\n"
							append msg "Rename This To Some Other Name, Outside The Sound Loom, Then Close The Workspace.\n"
							set badfile $mixname
						} else {
							Inf "The Updated File '$mixname' Has Been Saved With The Name '$nuname$ext'."
							Inf "(You May Need To Close The Workspace Before The Original Mixfiles Can Be Deleted)."
							set bypassfile $nuname$ext
							FileToWkspace $bypassfile 0 0 0 0 1 
							UpdateBakupLog $bypassfile create 1	
						}
					} else {
						set badfile $mixname
					}
				} else {
					set goodfile $mixname
					UpdateBakupLog $goodfile modify 1	
				}
			}
		}
	}
	set nulist {}
	if {[info exists goodfile]} {
		foreach zfnam $mixmanage($mixname) {		;#	LOOK AT EACH FILE IN ORIGINAL LIST
			set j [lsearch $fnams $zfnam]			;#	IF IT HAS NAME OF A RENAMABLE FILE
			if {$j >= 0} {
				lappend nulist [lindex $nufnams $j]	;#	PUT NEW NAME IN OUTPUT LIST
				set update 1
			} else {
				lappend nulist $zfnam				;#	ELSE PUT ORIG NAME IN OUTPUT LIST
			}
		}
		if {$update} {
			set mixmanage($mixname) $nulist
		}
		lappend mixupdate_goodfiles $goodfile
	}
	if {[info exists bypassfile]} {
		foreach zfnam $mixmanage($mixname) {
			set j [lsearch $fnams $zfnam]
			if {$j >= 0} {
				lappend mixmanage($bypassfile) [lindex $nufnams $j]			
			} else {
				lappend mixmanage($bypassfile) $zfnam
			}
		}
		set update 1
		lappend mixupdate_bypass $mixname $bypassfile
	}
	if {[info exists badfile]} {
		lappend mixupdate_badfiles $badfile
	}
	if {[info exists delfile]} {
		lappend mixupdate_delfiles $delfile
	}
	return $update
}

proc MixManageReport {} {
	global mixmanage mixupdate_badfiles mixupdate_goodfiles mixupdate_delfiles mixupdate_bypass wstk evv
	set msg ""
	if {[info exists mixupdate_goodfiles]} {
		append msg "The Following Mixfiles Were Updated\n"
		set cnt 0
		foreach fnam $mixupdate_goodfiles {
			append msg $fnam "    "
			incr cnt
			if {$cnt > 20} {
				append msg "\nAnd More"
				break
			}
		}
		append msg "\n\n"
	}
	if {[info exists mixupdate_badfiles]} {
		append msg "The Following Mixfiles Were ~~Not~~ Updated\n"
		set cnt 0
		foreach fnam $mixupdate_badfiles {
			append msg $fnam "    "
			incr cnt
			if {$cnt > 20} {
				append msg "\nAnd More"
				break
			}
		}
		append msg "\n\n"
	}
	if {[info exists mixupdate_bypass]} {
		append msg "The Following Mixfiles Were Updated With New Names\n"
		set cnt 0
		foreach {fnam nufnam} $mixupdate_bypass {
			append msg "$fnam   -->   $nufnam\n"
			incr cnt
			if {$cnt > 20} {
				append msg "\nAnd More"
				break
			}
		}
		append msg "\n\n"
	}
	if {[info exists mixupdate_delfiles]} {
		append msg "The Following Mixfiles Were ~~Lost~~\n"
		set cnt 0
		foreach fnam $mixupdate_delfiles {
			append msg $fnam "    "
			incr cnt
			if {$cnt > 20} {
				append msg "\nAnd More"
				break
			}
		}
		append msg "\n\n"
	}
	Inf $msg
	catch {unset mixupdate_goodfiles}
	catch {unset mixupdate_badfiles}
	catch {unset mixupdate_delfiles}
	catch {unset mixupdate_bypass}
}

#---- Collect all reanmed files in any mixfile, under the heading of that mixfile

proc RationaliseMixRevisionData {} {
	global mixmanage_sndrenames mixmanage_data
	catch {unset mixmanage_data}
	foreach {mixname fnam nufnam} $mixmanage_sndrenames {
		if {![info exists mixmanage_data($mixname)]} {
			set mixmanage_data($mixname) $mixname
		}
		lappend mixmanage_data($mixname) $fnam $nufnam
	}
	if {[info exists mixmanage_data]} {		;#	REMOVE DUPLICATES
		set snds {}
		foreach name [array names mixmanage_data] {
			foreach {fnam nufnam} [lrange $mixmanage_data($name) 1 end] {
				set k [lsearch $snds $fnam]
				if {$k < 0} {
					lappend snds $fnam
					lappend nusnds $nufnam
				}
			}
			set mixmanage_data($name) $name
			foreach snd $snds nusnd $nusnds {
				lappend mixmanage_data($name) $snd $nusnd
			}
		}
	}
}

proc LoadAutoMix {} {
	global evv
	set returnval 0
	set fnam [file join $evv(URES_DIR) $evv(AUTO_MIXMANAGE)$evv(CDP_EXT)]
	if {![file exists $fnam]} {
		return 0
	}
	if [catch {open $fnam "r"} zit] {
		return 0
	}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {![IsNumeric $line]} {
			break
		}
		if {[string match $line "1"]} {
			set returnval 1
		}
		break
	}
	close $zit
	return $returnval
}

#---- Delete mixmanage data about mies where snds no longer exist

proc MixMSndPurge {dostore} {
	global mixmanage
	set storable 0
	if {![info exists mixmanage]} {
		return 0
	}
	foreach name [array names mixmanage] {
		foreach fnam $mixmanage($name) {
			if {![file exists $fnam]} {
				lappend delnames $name
				break
			}
		}
	}
	if {[info exists delnames]} {
		foreach fnam $delnames {
			unset mixmanage($fnam)
			set storable 1
		}
	}
	if {$storable} {
		if {$dostore} {
			MixMStore
		}
		return 1
	}
	return 0
}

proc CheckMixMSndDelete {fnam} {
	global mixmanage wstk wl files_deleted rememd evv

	if {[IsCDPTempfile $fnam]} {
		return {}
	}
	if {![info exists mixmanage]} {
		return {}
	}
	foreach mixname [array names mixmanage] {
		set k [lsearch $mixmanage($mixname) $fnam]
		if {$k >= 0} {
			lappend delnames $mixname
		}
	}
	if {[info exists delnames]} {
		return $delnames
	}
	return {}
}

proc RationaliseDelfiles {delfiles} {
	set len [llength $delfiles]
	if {$len > 1} {
		set len_less_one $len
		incr len_less_one -1
		set n 0
		while {$n < $len_less_one} {
			set m $n
			incr m
			while {$m < $len} {
				if {[string match [lindex $delfiles $n] [lindex $delfiles $m]]} {
					set delfiles [lreplace $delfiles $m $m]
					incr len -1
					incr len_less_one -1
					incr m -1
				}
				incr m
			}
			incr n
		}
	}
	return $delfiles
}

proc UpdateIfAMix {fnam dostore} {
	global mixmanage pa evv
	set update 0
	set ftyp $pa($fnam,$evv(FTYP))
	if {[IsAMixfileIncludingMultichan $ftyp]} {
		if {[MixMUpdate $fnam 0]} {
			set update 1
		}
	} elseif {[info exists mixmanage($fnam)]} {
		unset mixmanage($fnam)
		set update 1
	}
	if {$update && $dostore} {
		MixMStore
	}
	return $update
}

proc DoMixfileSndDeletionUpdates {deleted_files typ} {
	global dobakuplog
	if {!$dobakuplog} {
		return
	}
	set dellen [llength $deleted_files]
	set delcnt 0
	while {$delcnt < $dellen} {
		set mixname [lindex $deleted_files $delcnt]
		if {[string match [file tail $mixname] $mixname]} {
			set deleted_files [lreplace $deleted_files $delcnt $delcnt]	;#	Don't backup files still on worksapce
			incr dellen -1
		} else {
			incr delcnt
		}
	}
	set dellen [llength $deleted_files]
	if {$dellen > 0} {
		incr dellen -1
		set delcnt 0
		foreach mixname $deleted_files {
			if {$delcnt == $dellen} {
				UpdateBakupLog $mixname $typ 1	;#	Once last file in list is recorded, write to file.
			} else {
				UpdateBakupLog $mixname $typ 0	;#	Record which files have been deleted, or modified.
			}
			incr delcnt
		}
	}
}

proc ShowSoundsInMixfiles {unbakdup} {
	global mixmanage wl
	if {![info exists mixmanage]} {
		Inf "No Known Mixfiles Exist"
		return
	}
	foreach mixfile [array names mixmanage] {
		if {![file exists $mixfile]} {
			continue
		}
		foreach fnam $mixmanage($mixfile) {
			set i [LstIndx $fnam $wl]
			if {$i < 0} {
				continue
			}
			if {$unbakdup} {
				set zfnam [file tail $fnam]
				if {![string match $fnam $zfnam]} {
					continue
				}
			}
			if {![info exists ilist] || ([lsearch $ilist $i] < 0)} {
				lappend ilist $i
				lappend inmixfiles $mixfile
			}
		}
	}
	if {![info exists ilist]} {
		Inf "No Files Used In Known Mixfiles Are On The Workspace"
		return
	} else {
		set msg "To Find Which Mixfile Any Files Are In: Select Those File, And Go To Menu\n"
		append msg "\"Selected Files Of Type\" --> Mixfiles --> \"Is File In Any Known Mixfile?\""
		Inf $msg
	}
	$wl selection clear 0 end
	foreach i $ilist {
		$wl selection set $i
	}
}
