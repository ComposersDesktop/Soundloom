#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD 30 June 2013
# ... fixup button rectangles, portable file

#########################################################
# Directory Selector TCL version 1.5
#
# Daniel Roche, <daniel.roche@bigfoot.com>
#
# thanks to :
#  Cyrille Artho <cartho@netlink.ch> for the 'saving pwd fix'
#  Terry Griffin <terryg@axian.com> for <Return> key bindings on buttons.
#  Kenneth Kehl  <Kenneth.Kehl@marconiastronics.com> for blocking at end of dir tree
#  Michael Barth <m.barth@de.bosch.com> for finding the "-fill on image" problem 
#  Mike Avery <avery@loran.com> for finding the "myfont already exist" problem
#  Branko Rogic <b.rogic@lectra.com> for gif icons, parent and background options
#  Reinhard Holler <rones@augusta.de> for colors ,font and autovalid options
#
#	CDP mods by Trevor Wishart
#
#########################################################


#########################################################
# 
# tk_getDirectory [stripped down & modified for Sound Loom]
#
#########################################################

namespace eval tkgetdir {
    variable drives
    variable fini
    variable svwd
    variable msg
    variable geometry
    variable parent
    variable colors
    variable font
    variable myfont
    variable autovalid
    
    namespace export tk_getDirectory
}

proc tkgetdir::tk_getDirectory {drive} {
    global tcl_platform

    #
    # default
    #
    set tkgetdir::msg(title)  "DIRECTORY SELECTOR"
    set tkgetdir::msg(ldir)   "(click button to see all drives)"
    set tkgetdir::msg(ldir2)  "DRIVE SELECTOR"
	set tkgetdir::msg(ldir3)  "Double Click on a Directory Icon, to see any subdirectories"
    set tkgetdir::msg(ldnam)  "Directory Name:"
    set tkgetdir::msg(open)   "Select"
    set tkgetdir::msg(expand) "Open"
    set tkgetdir::msg(cancel) "Cancel"
    set tkgetdir::geometry "500x500"
    set tkgetdir::colors(lstfg) [option get . foreground {}]

	set tkgetdir::colors(lstbg) [option get . background {}]
	set tkgetdir::font [option get . font {}]

    set tkgetdir::colors(hilfg) [option get . activeForeground {}]
    set tkgetdir::colors(hilbg) [option get . activeBackground {}]
    set tkgetdir::colors(selfg) [option get . activeForeground {}]
    set tkgetdir::colors(selbg) [option get . background {}]
    set tkgetdir::colors(endcol) red2
    set tkgetdir::parent ""
    set tkgetdir::autovalid 0
    set tkgetdir::svwd [pwd]
    
    #
    # arguments: Sets the Directory selector to look on current drive
    #
	cd $drive
    
    #
    # variables et data
    #

	set tkgetdir::fini 0
    
    image create photo b_up -data {
		R0lGODlhFgATAMIAAHt7e9/fX////gAAAK6uSv///////////yH+Dk1hZGUgd2l0aCBHSU1QACH5
		BAEAAAcALAAAAAAWABMAAANVeArcoDBKEKoNT2p6b9ZLJzrkAQhoqq4qMJxi3LnwRcjeK9jDjWM6
		C2FA9Mlou8CQWMQhO4Nf5XmJSqkW6w9bYXqZFq40HBzPymYyac1uDA7fuJyZAAA7
    }

    image create photo b_dir -data {
		R0lGODlhEAAQAMIAAHB/cN/fX////gAAAP///////////////yH+Dk1hZGUgd2l0aCBHSU1QACH5
		BAEAAAQALAAAAAAQABAAAAM2SLrc/jA2QKkEIWcAsdZVpQBCaZ4lMBDk525r+34qK8x0fOOwzfcy
		Xi2IG4aOoRVhwGw6nYQEADs=
    }

    if {[lsearch -exact $tkgetdir::font -family] >= 0} {
		eval font create dlistfont $tkgetdir::font
		set tkgetdir::myfont dlistfont
    } else {
		set tkgetdir::myfont $tkgetdir::font
    }

    #
    # widgets
    #
    toplevel .dirsel

	#	force Directory Selector into my window stack, so sudden exit (from CDP window)
	#	is still possible, without upsetting that stack 

	update idletasks
	StandardPosition2 .dirsel
	My_Grab 1 .dirsel tkgetdir::fini

    wm geometry .dirsel $tkgetdir::geometry
    if {$tkgetdir::parent != ""} {
        set par $tkgetdir::parent
		set xOrgWin [expr [winfo rootx $par] + [winfo width $par] / 2 ]
		set yOrgWin [expr [winfo rooty $par] + [winfo height $par] / 2 ]
		wm geometry .dirsel +$xOrgWin+$yOrgWin
		wm transient .dirsel $tkgetdir::parent
    }
    wm title .dirsel $tkgetdir::msg(title)

    event add <<RetEnt>> <Return> <KP_Enter>
    
    frame .dirsel.f1 -relief flat -borderwidth 0
    frame .dirsel.f10 -bg [option get . foreground {}] -height 1
    frame .dirsel.f11 -relief flat -borderwidth 0
    frame .dirsel.f2 -relief sunken -borderwidth 2 
    frame .dirsel.f3 -relief flat -borderwidth 0
    frame .dirsel.f4 -relief flat -borderwidth 0
    
    pack .dirsel.f1 -fill x
    pack .dirsel.f10 -fill x
    pack .dirsel.f11 -fill x
    pack .dirsel.f2 -fill both -expand 1 -padx 6 -pady 6
    pack .dirsel.f3 -fill x
    pack .dirsel.f4 -fill x
    
    label .dirsel.f1.lab -text $tkgetdir::msg(ldir)
    label .dirsel.f1.lab2 -text $tkgetdir::msg(ldir2)
#RWD make these portable
    if {[tk windowingsystem] eq "aqua"} {
 	    button .dirsel.f1.dir -text "Drive" -command {VolumeDir} -highlightbackground [option get . background {}]
    } else {
        button .dirsel.f1.dir -text "Drive" -command { 
	        VolumeDir
        }
    }
    if {[tk windowingsystem] eq "aqua"} {
        button .dirsel.f1.up -image b_up -command tkgetdir::UpDir -highlightbackground [option get . background {}]
    } else {
        button .dirsel.f1.up -image b_up -command tkgetdir::UpDir

    }
    bind .dirsel.f1.up <<RetEnt>> {.dirsel.f1.up invoke}

    pack .dirsel.f1.up -side right -padx 4 -pady 4
    pack .dirsel.f1.lab2 .dirsel.f1.dir .dirsel.f1.lab -side left -padx 4 -pady 4
    
    label .dirsel.f11.lab2 -text $tkgetdir::msg(ldir3)
	pack .dirsel.f11.lab2  -side top -anchor center

    canvas .dirsel.f2.cv -borderwidth 0 -yscrollcommand ".dirsel.f2.sb set"
    if { $tkgetdir::colors(lstbg) != "" } {
		.dirsel.f2.cv configure -background $tkgetdir::colors(lstbg)
    }
    scrollbar .dirsel.f2.sb -command ".dirsel.f2.cv yview"
    set scw 16
    place .dirsel.f2.cv -x 0 -relwidth 1.0 -width [expr -$scw ] -y 0 \
	    -relheight 1.0
    place .dirsel.f2.sb -relx 1.0 -x [expr -$scw ] -width $scw -y 0 \
	    -relheight 1.0
    unset scw
    
    .dirsel.f2.cv bind TXT <Any-Enter> tkgetdir::EnterItem
    .dirsel.f2.cv bind TXT <Any-Leave> tkgetdir::LeaveItem
    .dirsel.f2.cv bind TXT <Any-Button> tkgetdir::ClickItem
    .dirsel.f2.cv bind TXT <Double-Button> tkgetdir::DoubleClickItem
    .dirsel.f2.cv bind IMG <Any-Enter> tkgetdir::EnterItem
    .dirsel.f2.cv bind IMG <Any-Leave> tkgetdir::LeaveItem
    .dirsel.f2.cv bind IMG <Any-Button> tkgetdir::ClickItem
    .dirsel.f2.cv bind IMG <Double-Button> tkgetdir::DoubleClickItem
    
    label .dirsel.f3.lnam -text $tkgetdir::msg(ldnam)
    entry .dirsel.f3.chosen -takefocus 0
    if { $tkgetdir::colors(lstbg) != "" } {
		.dirsel.f3.chosen configure -background $tkgetdir::colors(lstbg)
    }
    pack .dirsel.f3.lnam -side left -padx 4 -pady 4
    pack .dirsel.f3.chosen -side right -fill x -expand 1 -padx 4 -pady 4
#RWD
    if {[tk windowingsystem] eq "aqua"} {
        button .dirsel.f4.open -text $tkgetdir::msg(open) -command {set tkgetdir::fini 1} -highlightbackground [option get . background {}]
    } else {
        button .dirsel.f4.open -text $tkgetdir::msg(open) -command { 
	        set tkgetdir::fini 1 
        }
    }
    bind .dirsel.f4.open <<RetEnt>> {.dirsel.f4.open invoke}
    if {[tk windowingsystem] eq "aqua"} {
        button .dirsel.f4.expand -text $tkgetdir::msg(expand) -command tkgetdir::DownDir -highlightbackground [option get . background {}]
    } else {
        button .dirsel.f4.expand -text $tkgetdir::msg(expand) -command tkgetdir::DownDir
    }
    bind .dirsel.f4.expand <<RetEnt>> {.dirsel.f4.expand invoke}
    if {[tk windowingsystem] eq "aqua"} {
        button .dirsel.f4.cancel -text $tkgetdir::msg(cancel) -command {set tkgetdir::fini -1} -highlightbackground [option get . background {}]
    } else {
        button .dirsel.f4.cancel -text $tkgetdir::msg(cancel) -command { 
		    set tkgetdir::fini -1 
        }
    }
    bind .dirsel.f4.cancel <<RetEnt>> {.dirsel.f4.cancel invoke}
    
    pack .dirsel.f4.open .dirsel.f4.expand -side left -padx 10 -pady 4
    pack .dirsel.f4.cancel -side right -padx 10 -pady 4
    
    bind .dirsel.f1 <Destroy> tkgetdir::CloseDirSel

    #
    # realwork
    #
    tkgetdir::ShowDir [pwd]
    
    #
    # wait user
    #
    tkwait variable tkgetdir::fini

    if { $tkgetdir::fini == 1 } {
		set curdir [.dirsel.f1.dir cget -text]
		set nnam [.dirsel.f3.chosen get]
		set retval [string tolower [ file join $curdir $nnam ]]
    } else {
		set retval ""
    }
 	My_Release_to_Dialog .dirsel
	destroy .dirsel
    
    return $retval
}

proc tkgetdir::CloseDirSel {} {
    set wt [font names]
    if {[lsearch -exact $wt dlistfont] >= 0} {
		font delete dlistfont 
    }
    event delete <<RetEnt>>
    cd $tkgetdir::svwd
    set tkgetdir::fini 0
}

proc tkgetdir::ShowDir {curdir} {

    global tcl_platform	curdrive
    variable drives 
    
    if [catch {cd $curdir} zit] {
		Inf "Directory Not Available"
		return
	}
    .dirsel.f1.dir configure -text $curdir
    
    set hi1 [font metrics $tkgetdir::myfont -linespace]
    set hi2 [image height b_dir]
    if { $hi1 > $hi2 } {
		set hi $hi1
    } else {
		set hi $hi2
    }
    set wi1 [image width b_dir]
    incr wi1 4
    set wi2 [winfo width .dirsel.f2.cv]
    
    set lidir [list]
    foreach file [ glob -nocomplain * ] {
		if {[ file isdirectory [string trim $file "~"] ] && ![CDP_Restricted_Directory $file 1]} { 
		    lappend lidir $file
		}
    }
   set sldir [lsort -dictionary $lidir]
     
    .dirsel.f2.cv delete all
    set ind 0
    # Adjust the position of the text wi1 with an offset.
    if { $hi1 < $hi2 } {
		set offset [expr $hi2 - $hi1]
    } else {
		set offset 0
    }
    foreach file $sldir {
		if [ file isdirectory $file ] { 
		    .dirsel.f2.cv create image 2 [expr $ind * $hi] \
			    -anchor nw -image b_dir -tags IMG
		    .dirsel.f2.cv create text $wi1 [expr ($ind * $hi) + $offset] \
			    -anchor nw -text $file -fill $tkgetdir::colors(lstfg) \
			    -font $tkgetdir::myfont -tags TXT
		    set ind [ expr $ind + 1 ]
		}
    }

    set ha [expr $ind * $hi]
    .dirsel.f2.cv configure -scrollregion [list 0 0 $wi2 $ha]
    
    set curlst [file split $curdir]
    set nbr [llength $curlst]
}

proc tkgetdir::UpDir {} {
    set curdir [.dirsel.f1.dir cget -text]
    set curlst [file split $curdir]
    
    set nbr [llength $curlst]
    if { $nbr < 2 } {
		return
    }
    set tmp [expr $nbr - 2]
    
    set newlst [ lrange $curlst 0 $tmp ]
    set newdir [ eval file join $newlst ]
    
    .dirsel.f3.chosen delete 0 end
    tkgetdir::ShowDir $newdir
}

proc tkgetdir::DownDir {} {
    set curdir [.dirsel.f1.dir cget -text]
    set nnam [.dirsel.f3.chosen get]

    set newdir [ file join $curdir $nnam ]

    # change 07/19/99
    # If there are more dirs, permit display of one level down.
    # Otherwise, block display and hilight selection in red.
    set areDirs 0
    foreach f [glob -nocomplain [file join $newdir *]] {
		if {[file isdirectory $f]} {
		    set areDirs 1
		    break
		}
    }
 
    if {$areDirs} {
		.dirsel.f3.chosen delete 0 end
		tkgetdir::ShowDir $newdir
    } else {
		set id [.dirsel.f2.cv find withtag HASBOX ]
		.dirsel.f2.cv itemconfigure $id -fill $tkgetdir::colors(endcol)
    }
}

proc tkgetdir::EnterItem {} {
    global tcl_platform

    set id [.dirsel.f2.cv find withtag current]
    set wt [.dirsel.f2.cv itemcget $id -tags]
    if {[lsearch -exact $wt IMG] >= 0} {
		set id [.dirsel.f2.cv find above $id]
    }

    .dirsel.f2.cv itemconfigure $id -fill $tkgetdir::colors(hilfg)
    set bxr [.dirsel.f2.cv bbox $id]
    eval .dirsel.f2.cv create rectangle $bxr \
	    -fill $tkgetdir::colors(hilbg) -outline $tkgetdir::colors(hilbg) \
	    -tags HILIT
    .dirsel.f2.cv lower HILIT
}

proc tkgetdir::LeaveItem {} {
    .dirsel.f2.cv delete HILIT
    set id [.dirsel.f2.cv find withtag current]
    set wt [.dirsel.f2.cv itemcget $id -tags]
    if {[lsearch -exact $wt IMG] >= 0} {
		set id [.dirsel.f2.cv find above $id]
    }
    set wt [.dirsel.f2.cv itemcget $id -tags]
    if {[lsearch -exact $wt HASBOX] >= 0} {
		.dirsel.f2.cv itemconfigure $id -fill $tkgetdir::colors(selfg)
    } else {
		.dirsel.f2.cv itemconfigure $id -fill $tkgetdir::colors(lstfg)
    }
}

proc tkgetdir::ClickItem {} {
    .dirsel.f2.cv delete HILIT
    # put old selected item in normal state
    .dirsel.f2.cv delete BOX
    set id [.dirsel.f2.cv find withtag HASBOX]
    .dirsel.f2.cv itemconfigure $id -fill $tkgetdir::colors(lstfg)
    .dirsel.f2.cv dtag HASBOX HASBOX
    # put new selected item in selected state
    set id [.dirsel.f2.cv find withtag current]
    set wt [.dirsel.f2.cv itemcget $id -tags]
    if {[lsearch -exact $wt IMG] >= 0} {
		set id [.dirsel.f2.cv find above $id]
    }
     set bxr [.dirsel.f2.cv bbox $id]
    .dirsel.f2.cv addtag HASBOX withtag $id
    .dirsel.f2.cv itemconfigure $id -fill $tkgetdir::colors(selfg)
    eval .dirsel.f2.cv create rectangle $bxr \
	    -fill $tkgetdir::colors(selbg) -outline $tkgetdir::colors(selbg) \
	    -tags BOX
    .dirsel.f2.cv lower BOX
    set nam [.dirsel.f2.cv itemcget $id -text]
    .dirsel.f3.chosen delete 0 end
    .dirsel.f3.chosen insert 0 $nam
}

proc tkgetdir::DoubleClickItem {} {
    set id [.dirsel.f2.cv find withtag current]
    tkgetdir::DownDir
}

proc VolumeDir {} {
    set newdir "/Volumes"
    .dirsel.f3.chosen delete 0 end
    tkgetdir::ShowDir $newdir
}
