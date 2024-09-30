#
# SOUND LOOM RELEASE mac version 17.0.4
#

#######################
# OTHER MIXFILE STUFF #
#######################

proc SpatialiseMonoMix {} {
	global wl chlist wstk pa evv pr_spacmix spmixfnam 
	set ilist [$wl curselection]
	if {![info exists ilist] || ([llength $ilist] != 2)} {
		if {![info exists chlist] || ([llength $chlist] != 2)} {
			Inf "CHOOSE ONE MONO MIXFILE AND ONE SPACE-DATA FILE (TIME-WIDTH \[0-1\] PAIRS)"
			return
		} else {	
			set mfnam [lindex $chlist 0]
			set sfnam [lindex $chlist 1]
		}
	} else {
		set mfnam [$wl get [lindex $ilist 0]]
		set sfnam [$wl get [lindex $ilist 1]]
	}
	if {![IsAMixfile $pa($mfnam,$evv(FTYP))]} {
		if {![IsAMixfile $pa($sfnam,$evv(FTYP))]} { 
			Inf "Choose One Mono Mixfile And One Space-Data File (Time-Width \[0-1\] Pairs)"
			return
		} else {
			set temp $mfnam
			set mfnam $sfnam
			set sfnam $temp
		}
	}
	if {$pa($mfnam,$evv(OUT_CHANS)) != 1} {
		Inf "Choose One Mono Mixfile And One Space-Data File (Time-Width \[0-1\] Pairs)"
		return
	}
	set mdur $pa($mfnam,$evv(DUR))
	if {![IsANormdBrkfile $pa($sfnam,$evv(FTYP))]} {
		Inf "Choose One Mono Mixfile And One Space-Data File (Time-Width \[0-1\] Pairs)"
		return
	}
	set sdur $pa($sfnam,$evv(DUR))
	set f .spacmix
	if [Dlg_Create $f "SPATIALISE MIXFILE" "set pr_spacmix 0" -borderwidth $evv(SBDR)] {
		set f0 [frame $f.0 -borderwidth $evv(BBDR)]
		set f1 [frame $f.1 -borderwidth $evv(BBDR)]
		button $f0.ok -text "Spatialise" -command "set pr_spacmix 1"
		label $f0.fnam -text ""
		button $f0.q -text "Abandon" -command "set pr_spacmix 0"
		pack $f0.ok $f0.fnam -side left -padx 2
		pack $f0.q -side right
		label $f1.ll -text "New Mixfile Name "
		entry $f1.e -textvariable spmixfnam -width 48
		pack $f1.ll $f1.e -side left -padx 2
		pack $f0 -side top -fill x -expand true
		pack $f1 -side top -pady 2
		bind $f <Escape> {set pr_spacmix 0}
		bind $f <Return> {set pr_spacmix 1}
	}
	set spmixfnam ""
	raise $f
	update idletasks
	StandardPosition2 $f
	set pr_spacmix 0
	set finished 0
	My_Grab 0 $f pr_spacmix $f.1.e
	while {!$finished} {
		tkwait variable pr_spacmix
		if {$pr_spacmix} {
			if {![info exists outlines]} {
				if [catch {open $sfnam "r"} zib] {
					Inf "Cannot Open File $sfnam"
					continue
				}
				set spcbrk {}
				set OK 1
				while {[gets $zib line] >= 0} {
					catch {unset newline}
					set line [string trim $line]
					if {[string length $line] <= 0} {
						continue
					}
					if [string match [string index $line 0] ";"] {
						continue
					}
					set line [split $line]
					foreach item $line {
						if {[string length $item] > 0} {
							lappend newline $item
						}
					}
					if {![info exists newline] || ([llength $newline] != 2)} {
						Inf "Problem With Spatialisation Data"
						set OK 0
						break
					}
					set spcbrk [concat $spcbrk $newline]
				}
				close $zib
				if {!$OK} {
					continue
				}
				if {[llength $spcbrk] <= 4} {
					Inf "Problem With Spatialisation Data (Must Be Two Lines Of Data At Least)"
					continue
				}				
				if {[lindex $spcbrk 0] != 0.0} {
					set newline [list 0 [lindex $spcbrk 1]]
					set spcbrk [concat $newline $spcbrk]
				}
				if {$sdur < $mdur} {
					set slen [llength $spcbrk]
					set newline [list $mdur [lindex $spcbrk [expr $slen - 1]]]
					set spcbrk [concat $spcbrk $newline]
				}
				if [catch {open $mfnam "r"} zib] {
					Inf "Cannot Open File $mfnam"
					continue
				}
				while {[gets $zib line] >= 0} {
					catch {unset newline}
					set line [string trim $line]
					if {[string length $line] <= 0} {
						continue
					}
					if [string match [string index $line 0] ";"] {
						lappend mixlines $newline
						continue
					}
					set line [split $line]
					foreach item $line {
						if {[string length $item] > 0} {
							lappend newline $item
						}
					}
					lappend mixlines $newline
				}
				close $zib
				set this_stim [expr double([lindex $spcbrk 0])]
				set this_swid [expr double([lindex $spcbrk 1])]
				set next_stim [expr double([lindex $spcbrk 2])]
				set next_swid [expr double([lindex $spcbrk 3])]
				set spcindx 2
				set tdiff [expr $next_stim - $this_stim]
				set wdiff [expr $next_swid - $this_swid]
				set isleft 1
				set done 0
				foreach line $mixlines {
					if [string match [string index $line 0] ";"] {
						lappend outlines $newline
						continue
					}
					set thistime [lindex $line 1]
					if {$thistime > $next_stim} {
						incr spcindx 2
						if {$spcindx >= $slen} {
							set width [lindex $spcbrk [expr $slen - 1]]
							set done 1
						} else {
							set this_swid $next_swid
							set this_stim $next_stim
							set next_stim [expr double([lindex $spcbrk $spcindx])]
							set next_swid [expr double([lindex $spcbrk [expr $spcindx + 1]])]
							set tdiff [expr $next_stim - $this_stim]
							set wdiff [expr $next_swid - $this_swid]
						}
					}
					if {!$done} {
						set tratio [expr ($thistime - $this_stim) / $tdiff]
						set wstep  [expr $wdiff * $tratio]
						set width [expr $this_swid + $wstep]
					}
					set pos [expr rand() * $width * 2]	;#	TRICK TO ENSURE HALF OF EVENTS LAND AT EDGE OF SPACE
					if {$pos > $width} {
						set pos $width
					}
					set pos [expr $pos * $isleft]
					set isleft [expr -$isleft]
					if {[llength $line] == 5} {
						set line [lreplace $line end end $pos]
					} else {
						lappend line $pos
					}
					lappend outlines $line
				}
			}
			if {![ValidCDPRootname $spmixfnam]} {
				continue
			}
			set outfnam [string tolower $spmixfnam]
			append outfnam [GetTextfileExtension mix]
			if {[string match $mfnam $outfnam]} {
				Inf "You Cannot Overwrite The Input Mixfile Here"	
				continue
			}
			if {[file exists $outfnam]} {
				set msg "File '$outfnam' Exists: Overwrite It ?"
				set choice [tk_messageBox -type yesno -icon warning -parent [lindex $wstk end] -message $msg]
				if {$choice == "no"} {
					continue
				}
			}
			if [catch {open $outfnam "w"} zit] {
				Inf "Cannot Open File '$outfnam' To Write Data"
				continue
			}
			foreach line $outlines {
				puts $zit $line
			}
			close $zit
			FileToWkspace $outfnam 0 0 0 0 1
			set finished 1
		} else {
			set finished 1
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}
