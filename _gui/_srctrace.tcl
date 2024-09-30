#
# SOUND LOOM RELEASE mac version 17.0.4
#
#RWD 30 June 2013
# ... fixup button rectangles

#####################################################
# KEEPING TRACK OF SOUND-SOURCES OF NON-SOUND FILES #
#####################################################

#------ Generate list of srcs for appropriate files

proc GenerateSrcList {fnam} {
	global pa pprg ins evv

 	set ftype $pa($fnam,$evv(FTYP))

	if {$ftype & $evv(IS_A_SNDSYSTEM_FILE)} {
		switch -regexp -- $ftype \
			^$evv(ANALFILE)$     - \
			^$evv(PITCHFILE)$    - \
			^$evv(TRANSPOSFILE)$ - \
			^$evv(FORMANTFILE)$  - \
			^$evv(ENVFILE)$ { 
				GetSrcs $fnam 
			} \
			^$evv(SNDFILE)$ {
				if {$pprg == $evv(FOFEX_EX)} {
					GetSrcs $fnam 
				}
			}

	} elseif {!$ins(run)} {
		if {($ftype != $evv(MIX_MULTI)) && (($ftype & $evv(IS_A_PITCH_BRKFILE)) || ($ftype & $evv(IS_A_TRANSPOS_BRKFILE)))} {
			switch  -regexp -- $pprg \
				^$evv(REPITCHB)$ - \
				^$evv(P_WRITE)$ { GetSrcs $fnam }
		} 
		if {[IsANormdBrkfile $ftype]} {
			switch  -regexp -- $pprg \
				^$evv(ENV_DBBRKTOBRK)$ - \
				^$evv(ENV_ENVTOBRK)$   - \
				^$evv(ENV_REPLOTTING)$ - \
				^$evv(ENV_EXTRACT)$ { GetSrcs $fnam }
		} elseif {$ftype & $evv(IS_A_DB_BRKFILE)} {
			switch  -regexp -- $pprg \
				^$evv(ENV_BRKTODBBRK)$ - \
				^$evv(ENV_ENVTODBBRK)$ { GetSrcs $fnam }
		}
	}
}

#------ Generate list of srcs for a nonsound-file

proc GetSrcs {fnam} {
	global chlist pa src evv

	if [info exists chlist] {
		set src($fnam) ""
		foreach startfile $chlist {
		 	set ftype $pa($startfile,$evv(FTYP))

			if {$ftype & $evv(IS_A_TEXTFILE)} {
				if [info exists src($startfile)] {
					set src($fnam) [concat $src($fnam) $src($startfile)]
				}
			} else {
				switch -regexp -- $ftype \
					^$evv(ANALFILE)$ - \
					^$evv(PITCHFILE)$ - \
					^$evv(TRANSPOSFILE)$ - \
					^$evv(FORMANTFILE)$ - \
					^$evv(ENVFILE)$ {
						if [info exists src($startfile)] {
							set src($fnam) [concat $src($fnam) $src($startfile)]
						}
					} \
					^$evv(PSEUDO_SND)$ - \
					^$evv(SNDFILE)$ {
#FEB 13
						set startfile [OmitSpaces $startfile]
						set src($fnam) [concat $src($fnam) $startfile]
					}
			}
		}
		if {[llength $src($fnam)] <= 0} {
			unset src($fnam)
		} else {
			set src($fnam) [RemoveDupls $src($fnam)]
		}
	}
}

#------ Generate list of srcs for appropriate files in a bulk process

proc GenerateSrcListBulk {fnam srcname} {
	global pa pprg ins evv

 	set ftype $pa($fnam,$evv(FTYP))

	if {$ftype & $evv(IS_A_SNDSYSTEM_FILE)} {
		switch -regexp -- $ftype \
			^$evv(ANALFILE)$     - \
			^$evv(PITCHFILE)$    - \
			^$evv(TRANSPOSFILE)$ - \
			^$evv(FORMANTFILE)$  - \
			^$evv(ENVFILE)$ { GetBulkSrcs $fnam $srcname}
	} elseif {!$ins(run)} {
		if {($ftype != $evv(MIX_MULTI)) && (($ftype & $evv(IS_A_PITCH_BRKFILE)) || ($ftype & $evv(IS_A_TRANSPOS_BRKFILE)))} {
			switch  -regexp -- $pprg \
				^$evv(REPITCHB)$ - \
				^$evv(P_WRITE)$ { GetBulkSrcs $fnam $srcname}
		} 
		if {[IsANormdBrkfile $ftype]} {
			switch  -regexp -- $pprg \
				^$evv(ENV_DBBRKTOBRK)$ - \
				^$evv(ENV_ENVTOBRK)$   - \
				^$evv(ENV_REPLOTTING)$ - \
				^$evv(ENV_EXTRACT)$ { GetBulkSrcs $fnam $srcname}
		} elseif {$ftype & $evv(IS_A_DB_BRKFILE)} {
			switch  -regexp -- $pprg \
				^$evv(ENV_BRKTODBBRK)$ - \
				^$evv(ENV_ENVTODBBRK)$ { GetBulkSrcs $fnam $srcname}
		}
	}
}

#------ Generate list of srcs for a file in a bulk process

proc GetBulkSrcs {fnam srcname} {
	global pa src evv

	set src($fnam) ""
 	set ftype $pa($srcname,$evv(FTYP))

	if {$ftype & $evv(IS_A_TEXTFILE)} {
		if [info exists src($srcname)] {
			set src($fnam) [concat $src($fnam) $src($srcname)]
		}
	} else {
		switch -regexp -- $ftype \
			^$evv(ANALFILE)$ - \
			^$evv(PITCHFILE)$ - \
			^$evv(TRANSPOSFILE)$ - \
			^$evv(FORMANTFILE)$ - \
			^$evv(ENVFILE)$ {
				if [info exists src($srcname)] {
					set src($fnam) [concat $src($fnam) $src($srcname)]
				}
			} \
			^$evv(PSEUDO_SND)$ - \
			^$evv(SNDFILE)$ {
#FEB 13
				set srcname [OmitSpaces $srcname]
				set src($fnam) [concat $src($fnam) $srcname]
			}
	}
	if {[llength $src($fnam)] <= 0} {
		unset src($fnam)
	}
}

#------ Remove a deleted file from all source listings, and remove any src-listing of its own
			
proc DeleteFileFromSrcLists {deleted_file} {
	global src evv

	if {![info exists src]} {
		return
	}
	if [info exists src($deleted_file)] {
		unset src($deleted_file)				;#	If a srcs-listing exists, delete it
	} else {
		foreach index [array names src] {				;#	For every other src listing
			set i 0
			set deleted 0
			foreach srcfile $src($index) {
				if [string match $evv(DELMARK)* $srcfile] {
					incr deleted		  				;#	Count files already marked as deleted
				} elseif [string match $srcfile $deleted_file] {
					set srcfile $evv(DELMARK)$srcfile
					set src($index) [lreplace $src($index) $i $i $srcfile] 
					incr deleted						;#	If file in this src-list, mark as deleted, and Count as deleted
				}
				incr i
			}
			if {[llength $src($index)] == $deleted} {	;#	If all files in listing are marked as deleted, delete listing
				unset src($index)
			}
		}
	}
}

#------ Change a filename in srcs listings

proc ChangeSrcName {fnam nufnam} {
	global src

	if {![info exists src]} {
		return
	}
	if [info exists src($fnam)] {
		catch {unset src($nufnam)}
		foreach sfile $src($fnam) {
			lappend src($nufnam) $sfile
		}
		unset src($fnam)
	} else {
		foreach index [array names src] {
			set changed 0
			catch {unset newsrclist}
			foreach fnm $src($index) {
				if [string match $fnam $fnm]	{
					lappend newsrclist $nufnam
					set changed 1
				} else {
					lappend newsrclist $fnm
				}
			}
			if {$changed} {
				set src($index) $newsrclist
			}
		}
	}
}

#------ Get listing of sndfile-sources of non-sndfile files, from listing file

proc GetSrcListsFromFile {} {
	global src evv 

	set sources_file [file join $evv(URES_DIR) $evv(SRCLISTS)$evv(CDP_EXT)]

	if {![file exists $sources_file]} {
		return
	}
	if [catch {open $sources_file r} fileId] {
		Inf $fileId							;#	If srcs file cannot be opened
		return		
	}
	while { [gets $fileId thisline] >= 0} {			;#	Read lines from srcs file into text-listing
		set cnt 0
		foreach fnam $thisline {
			set OK 1
			switch -- $cnt {
				0 {
					if {![file exists $fnam]} {		;#	File-for-which-srcs-listed no longer exists
						set OK 0
					} else {
						set thissrc $fnam
						catch {unset src($thissrc)}		;#	Avoid erroneous double entries
					}
				}
				default {
					if {![string match $evv(DELMARK)* $fnam] && ![file exists $fnam]} {
						lappend src($thissrc) $evv(DELMARK)$fnam
					} else {							;#	Mark and List a source which no longer exists
						lappend src($thissrc) $fnam	;#	List a source (existing or previously deleted)
					}
				}
			}
			if {!$OK} {
				break
			}
			incr cnt
		}
		if {!$OK} {
			continue
		}
		set OK 0
		foreach fnam $src($thissrc) {
			if {![string match $evv(DELMARK)* $fnam]} {	;#	If any src still exists, keep the listing
				set OK 1
				break
			}
		}
		if {!$OK} {										;#	Otherwise delete the listing
			catch {unset src($thissrc)}
		}
	}
	close $fileId
}

#------ Save listing of sndfile-sources of non-sndfile files, to listing file

proc SaveSrcListsToFile {} {
	global src evv 

	if {![info exists src]} {
		return
	}
	set tmpfnam $evv(DFLT_TMPFNAME)
	if [catch {open $tmpfnam w} fileId] {
		Inf "Cannot open temporary file to do updating of sound-sources of non-sound files."
		return
	}
		
	set cnt 0
	foreach index [array names src] {
		if {[llength $src($index)] <= 0} {
			continue
		}
		catch {unset tl}
		lappend tl $index
		set OK 0
		foreach fnam $src($index) {
			if {![string match $evv(DELMARK)* $fnam]} {	;#	If any src still exists, keep the listing
				set OK 1
				break
			}
		}
		if {!$OK} {
			continue
		}
		foreach fnam $src($index) {
			lappend tl $fnam
		}
		if {[llength $tl] > 1} {				;#	Discard spurious lists, at save
			puts $fileId $tl
			incr cnt
		}
	}
	close $fileId
	set sources_file [file join $evv(URES_DIR) $evv(SRCLISTS)$evv(CDP_EXT)]
	if [file exists $sources_file] {
		if [catch {file delete $sources_file}] {
			ErrShow "Cannot delete original Sourcelists file. Cannot update listing of sound-sources of non-sound files."
			return
		}
	}
	if {$cnt > 0} {
		if [catch {file rename $tmpfnam $sources_file}] {
			ErrShow "Cannot Rename temporary Sourcelists file. Lost the listing of sound-sources of non-sound files."
			return
		}
	}
}

#------

proc ShowSrcs {} {
	global pa prompt717 wl src sl_real evv

	if {!$sl_real} {
		Inf "The Soundloom Keeps Track Of The Source Sound Of Any Analysis File\nOr Transformed Analysis File\n\nThis Information Can Be Queried Here.\n\nIt Is Also Used At The 'Play Src' Button On The Parameters Page\nWhen The Source Sound For The Process Is An Analysis File"
		return
	}
	set ilist [$wl curselection]
	set lenn [llength $ilist]

	if {$lenn <= 0} {
		Inf "No files selected"
		return
	} elseif {$lenn == 1} {
		set fnam [$wl get [lindex $ilist 0]]
		if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_SNDFILE))} {
			if [info exists src($fnam)] {
				DisplayFileSrcs $fnam
			} else {
				Inf "No sources known for this file."
			}
		} else {
			Inf "$fnam is a Soundfile. No sourcelists exist for soundfiles."
		}
		return
	} else {
		foreach item $ilist {
			set fnam [$wl get $item]
			if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_SNDFILE))} {
				if [info exists src($fnam)] {
					lappend srclist $fnam
				} else {
					lappend nosrclist $fnam
				}
			} else {
				lappend soundlist $fnam
			}
		}
	}
	if [info exists soundlist] {
		if {[llength $soundlist] == 1} {
			Inf "File '[lindex $soundlist 0]' is a soundfile. No sourcelists exist for soundfiles."
		} else {
			Inf "These files are soundfiles.\n$soundlist\nNo sourcelists exist for soundfiles."
		}
	}
	if [info exists nosrclist] {
		if {[llength $nosrclist] == 1} {
			Inf "No sources are known for the file '$nosrclist'"
		} else {
			Inf "No sources are known for the files\n$nosrclist"
		}
	}
	if [info exists srclist] {
		if {[llength $srclist] == 1} {
			DisplayFileSrcs [lindex $srclist 0]
		} else {
			set f .srcsndlist
			if [Dlg_Create $f "FILES WITH SOURCE LISTINGS" "set prompt717 0" -borderwidth $evv(BBDR)] {
				button $f.quit -text "Close" -command "set prompt717 0" -highlightbackground [option get . background {}]
				Scrolled_Listbox $f.list -width 48 -height 12 -selectmode single
				pack $f.quit $f.list -side top
				bind $f <Return> {set prompt717 0}
				bind $f <Escape> {set prompt717 0}
				bind $f <Key-space> {set prompt717 0}
			}
#			wm resizable $f 0 0
			bind .srcsndlist <ButtonRelease-1> {HideWindow %W %x %y prompt717}
			bind $f.list.list <ButtonRelease-1> {ShowFileSrcs %W}
			$f.list.list delete 0 end
			foreach fnam $srclist {
				$f.list.list insert end $fnam
			}
			raise $f
			set prompt717 0
			My_Grab 0 $f prompt717 $f.list.list
			tkwait variable prompt717
			My_Release_to_Dialog $f
			Dlg_Dismiss $f
		}
	}
}

#------ Get max sample of file selected from list

proc ShowFileSrcs {w} {
	set hindx [$w curselection]
	if {[string length $hindx] <= 0} {
		return
	}
	set fnam [$w get $hindx]
	DisplayFileSrcs $fnam
}

#------ 

proc DisplayFileSrcs {fnam} {
	global pr_srcs src evv

	if {![info exists src($fnam)]} {		;#	SHOULD BE REDUNDANT: SAFETY ONLY
		return
	}
	foreach srcname $src($fnam) {
		if [string match $evv(DELMARK)* $srcname] {
			lappend deleted_files [string range $srcname 1 end]
		} else {
			lappend src_files $srcname
		}
	}

	set f .srclisting
	if [Dlg_Create $f "" "set pr_srcs 1" -borderwidth $evv(BBDR)] {
		EstablishSrcDisplayWindow $f
	}
	bind .srclisting <ButtonRelease-1> {HideWindow %W %x %y pr_srcs}
	wm title $f "FILE $fnam: LIST OF SOURCES"

	set t $f.k.t
	$t delete 1.0 end					  				;#	Clear any existing text in window
	if [info exists src_files] {
		set line "EXISTING SOUND SOURCES"
		$t insert end "$line\n\n"
		foreach srcname $src_files {
			$t insert end "$srcname\n"
		}
		$t insert end "\n"
	}
	if [info exists deleted_files] {
		set line "SOUND SOURCES WHICH HAVE BEEN DELETED"
		$t insert end "$line\n\n"
		foreach srcname $deleted_files {
			$t insert end "$srcname\n"
		}
		$t insert end "\n"
	}
	set pr_srcs 0
	raise $f
	My_Grab 0 $f pr_srcs
	tkwait variable pr_srcs
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

#------ Establish a Window to display text

proc EstablishSrcDisplayWindow {f} {
	global pr_srcs

	set b [frame $f.b]
	set k [frame $f.k]		
	pack $f.b $f.k -side top -fill x
	button $b.quit -text "Close" -command "set pr_srcs 1" -highlightbackground [option get . background {}]
	set t [text $k.t -setgrid true -wrap word -width 64 -height 14 \
	-xscrollcommand "$k.sx set" -yscrollcommand "$k.sy set"]
	scrollbar $k.sy -orient vert  -command "$f.k.t yview"
	scrollbar $k.sx -orient horiz -command "$f.k.t xview"
	pack $k.sy -side right -fill y
	pack $k.t -side left -fill both -expand true
	pack $k.sx -side top -fill x
}

######################################################################################
# GENERATE PHRASES BY PERMUTING NOUNS, ADJECTIVES, ADVERBS FROM DIFERRENT CATEGORIES #
#					CATEGORIES FALLING INTO TWO CONTRADITORY TYPES					 #
######################################################################################
#
#	INPUTS: Presorted lists of adverbs, adjectives and nouns in various categories.
#	CATEGORY TYPES: Two contrasting category-types e.g. scientific v poetic/theological
#	CATEGORY FILENAMES:	For a generic datafilename "myname" we have ...
#		myname_adv.txt	  =	adverbs
#		myname_adjN.txt	  =	category N of adjectives
#		myname_nounN.txt  =	category N of nouns
#		myname_cadjN.txt  =	category N of contrasting-category adjectives
#		myname_cnounN.txt =	category N of contrasting-category nouns
#

proc PreSortTexts {} {
	global chlist wl evv pa pr_presort presortnam presort_precnt presort_postcnt

	if {[info exists chlist] && ([llength $chlist] == 1)}  {
		set fnam $chlist
	} else {
		set i [$wl curselection]
		if {[info exists i] && ([llength $i] == 1) && ($i != -1)}  {
			set fnam [$wl get $i]
		}
	}
	if {[info exists fnam]} {
		if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
			unset fnam
		}
	}
	if {![info exists fnam]} {
		Inf "Select a textfile list of texts"
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot open file $fnam to read: $zit"
		return
	}
	set linecnt 0
	set OK 1
	while {[gets $zit line] >= 0} {
		incr linecnt
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0 ] ";"]} {
			continue
		}
		if {[regexp {[^A-Za-z_\-\ ]} $line]} {		;# Alphabetic,underscore,hyphen,space
			Inf "Line $linecnt\n$line\ncontains invalid character(s) : (must be alphabetic, hyphen , underscore or space)"
			set OK 0
			break
		}
		lappend lines [string tolower $line]
	}
	close $zit
	if {!$OK} {
		return
	}
	if {![info exists lines] || ([llength $lines] <= 0)} {
		Inf "No data found in file $fnam"
		return
	}
	set prelines $lines
	set presort__precnt [llength $lines]
	set lines [lsort -dictionary $lines]
	set lines [RemoveDuplicatesInList $lines]
	set presort__postcnt [llength $lines]
	set nochange 0
	if {$presort__precnt == $presort__postcnt} {
		set nochange 1
		foreach line $lines preline $prelines {
			if {![string match $line $preline]} {
				set nochange 0
				break
			}
		}
	}
	if {$nochange} {
		Inf "The original file is already sorted"
		return
	}
	set f .presort
	if [Dlg_Create $f "PRESORT LIST OF TEXTS" "set pr_presort 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.s -text "Sort"    -command "set pr_presort 1" -width 8 -highlightbackground [option get . background {}]
		button $f.0.q -text "Abandon" -command "set pr_presort 0" -width 8 -highlightbackground [option get . background {}]
		pack $f.0.s -side left
		pack $f.0.q -side right 
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Output filename "
		entry $f.1.e -textvariable presortnam -width 48
		set presortnam ""
		pack $f.1.ll $f.1.e -side left
		pack $f.1 -side top -pady 4
		frame $f.2
		label $f.2.no -text "Number of Lines : "
		label $f.2.bef -text "Before Sort "
		entry $f.2.pre  -textvariable presort_precnt  -width 6 -state readonly
		label $f.2.aft -text "After Sort "
		entry $f.2.post -textvariable presort_postcnt -width 6 -state readonly
		pack $f.2.no $f.2.bef $f.2.pre $f.2.aft $f.2.post -side left
		pack $f.2 -side top -pady 4
		wm resizable $f 0 0
		bind $f <Return> {set pr_presort 1}
		bind $f <Escape> {set pr_presort 0}
	}
	set presort_precnt $presort__precnt
	set presort_postcnt $presort__postcnt

	set presortnam [file rootname $fnam]
	append presortnam "_sorted"
	set pr_presort 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_presort
	while {!$finished} {
		tkwait variable pr_presort
		switch -- $pr_presort {
			0 {
				set finished 1
			}
			1 {
				if {![ValidCDPRootname $presortnam]} {
					continue
				}
				set ofnam [string tolower $presortnam]
				append ofnam $evv(TEXT_EXT)
				if {[file exists $ofnam]} {
					Inf "File $ofnam already exists : please choose a different name"
					continue
				}
				if [catch {open $ofnam "w"} zit] {
					Inf "Cannot open file $ofnam to write: $zit"
					continue
				}
				foreach line $lines {
					puts $zit $line
				}
				close $zit
				if {[FileToWkspace $ofnam 0 0 0 0 1] > 0} {
					Inf "File $ofnam is on the workspace"
				}
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

			
proc GeneratePhrases {} {
	global evv wstk hopperm gentext chlist wl pa pr_gentext

	set t1 [clock clicks]		;#	Set up an asrbitrary rand number from computer clock
	set junk [expr srand($t1)]

	set f .gentext
	if [Dlg_Create $f "GENERATE PHRASES" "set pr_gentext 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.s -text "Generate" -command "set pr_gentext 1" -width 8 -highlightbackground [option get . background {}]
		button $f.0.h -text "Help" -command "GentextHelp" -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.0.q -text "Abandon"  -command "set pr_gentext 0" -width 8 -highlightbackground [option get . background {}]
		pack $f.0.s $f.0.h -padx 2 -side left
		pack $f.0.q -side right 
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Generic Infile Name" -width 24 -anchor w
		entry $f.1.e -textvariable gentext(in) -width 84
		set gentext(in) ""
		pack $f.1.ll $f.1.e -side left
		pack $f.1 -side top -fill x -expand true
		frame $f.2
		label $f.2.ll -text "Outfile Name" -width 24 -anchor w
		entry $f.2.e -textvariable gentext(out) -width 20
		set gentext(out) ""
		pack $f.2.ll $f.2.e -side left
		pack $f.2 -side top -fill x -expand true
		frame $f.3
		label $f.3.ll -text "No. of outputs (1-1000)" -width 24 -anchor w
		entry $f.3.e -textvariable gentext(cnt) -width 6
		set gentext(cnt) ""
		frame $f.3.a
		label $f.3.a.ll -text "Word Length"
		radiobutton $f.3.a.short -text "Short(2-3)"  -variable gentext(short) -value 1 -command {GenTextChooseLen 1} -width 12
		radiobutton $f.3.a.long  -text "Long(5-12)"  -variable gentext(short) -value 0 -command {GenTextChooseLen 0} -width 12
		label $f.3.a.mi -text min -width 3 
		entry $f.3.a.min -textvariable gentext(min) -width 3
		label $f.3.a.ma -text min -width 3
		entry $f.3.a.max -textvariable gentext(max) -width 3
		pack $f.3.a.ll $f.3.a.short $f.3.a.long $f.3.a.mi $f.3.a.min $f.3.a.ma $f.3.a.max -side left
		pack $f.3.ll $f.3.e -side left
		pack $f.3.a -side right
		pack $f.3 -side top -fill x -expand true
		wm resizable $f 0 0
		bind $f.1.e <Up> {focus .gentext.3.e}
		bind $f.2.e <Up> {focus .gentext.1.e}
		bind $f.3.e <Up> {focus .gentext.2.e}
		bind $f.1.e <Down> {focus .gentext.2.e}
		bind $f.2.e <Down> {focus .gentext.3.e}
		bind $f.3.e <Down> {focus .gentext.1.e}
		bind $f <Return> {set pr_gentext 1}
		bind $f <Escape> {set pr_gentext 0}
	}
	set gentext(short) 1
	set gentext(min) ""
	set gentext(max) ""
	$f.3.a.mi config -text ""
	$f.3.a.min config -bd 0 -state disabled -disabledbackground [option get . background {}]
	$f.3.a.ma config -text ""
	$f.3.a.max config -bd 0 -state disabled -disabledbackground [option get . background {}]
	set gentext(in) ""
	if {[info exists chlist] && ([llength $chlist] == 1)} {
		set fnam [lindex $chlist 0]
		if {$pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)} {
			set posname [file rootname $fnam]
		}
	} else {
		set i [$wl curselection]
		if {[info exists i] && ([llength $i] == 1) && ($i != -1)} {
			set fnam [$wl get $i]
			if {$pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE)} {
				set posname [file rootname $fnam]
			}
		}
	}
	if {[info exists posname]} {
		set len [string length $posname]
		set emansop [ReverseString $posname]
		set k [string first "_" $emansop]
		if {$k >= 3} {
			set kk [expr $k - 1]
			set antikk [expr $len - $k]	;#	index of charactor before last "_" in forward-going string
			incr antikk -2
			if {[string match [string range $emansop 0 $kk] "vda"]} {
				set gentext(in) [string range $posname 0 $antikk]
			} else {
				set nn 0
				while {$nn < $k} {
					if {[regexp {^[0-9]+$} [string index $emansop $nn]]} {
						incr nn
					} else {
						break
					}
				}
				if {$nn != $k} {
					set emansop [string range $emansop $nn end]
					if {[string match [string range $emansop 0 4] "nuonc"]} {
						set gentext(in) [string range $posname 0 $antikk]
					} elseif {[string match [string range $emansop 0 3] "nuon"]} {
						set gentext(in) [string range $posname 0 $antikk]
					} elseif {[string match [string range $emansop 0 3] "jdac"]} {
						set gentext(in) [string range $posname 0 $antikk]
					} elseif {[string match [string range $emansop 0 2] "jda"]} {
						set gentext(in) [string range $posname 0 $antikk]
					}
				}
			}
		}		
	}		

	set pr_gentext 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_gentext
	while {!$finished} {
		tkwait variable pr_gentext
		switch -- $pr_gentext {
			0 {
				set finished 1
			}
			1 {
				if {[string length $gentext(out)] <= 0} {
					Inf "No output filename entered"
					continue
				}
				if {![ValidCDPRootname $gentext(out)]} {
					continue
				}
				set ofnam [string tolower $gentext(out)]
				append ofnam $evv(TEXT_EXT)
				if {[file exists $ofnam]} {
					Inf "File $ofnam already exists : please choose a different name"
					continue
				}
				if {[string length $gentext(cnt)] <= 0} {
					Inf "No count of output phrases entered"
					continue
				}
				if {![IsNumeric $gentext(cnt)] || ![regexp {^[0-9]+$} $gentext(cnt)] || ($gentext(cnt) < 1) || ($gentext(cnt) > 1000)} {
					Inf "Invalid count of output phrases to generate (range 1 - 1000)"
					continue
				}
				if {[string length $gentext(in)] <= 0} {
					Inf "No generic input-filename entered"
					continue
				}
				if {[regexp {[^A-Za-z0-9_:/\\\-]} $gentext(in)]} {		;# Alphabetic,underscore,hyphen,space, forward and backslash and ":" for filenames with paths
					Inf "Generic infilename  has invalid character(s) :\n(must be alphanumeric, hyphen, underscore, backslash, forwardslash or colon : and no file-extension)"
					continue
				}
				if {!$gentext(short)} {
					if {[string length $gentext(min)] <= 0} {
						Inf "No minimum phrase length entered"
						continue
					}
					if {![IsNumeric $gentext(min)] || ![regexp {^[0-9]+$} $gentext(min)] || ($gentext(min) < 5) || ($gentext(min) > 12)} {
						Inf "Invalid minimum phrase length (range 5 - 12)"
						continue
					}
					if {[string length $gentext(max)] <= 0} {
						Inf "No maximum phrase length entered"
						continue
					}
					if {![IsNumeric $gentext(max)] || ![regexp {^[0-9]+$} $gentext(max)] || ($gentext(max) < 5) || ($gentext(max) > 12)} {
						Inf "Invalid maximum phrase length (range 5 - 12)"
						continue
					}
					if {$gentext(max) < $gentext(min)} {	
						Inf "Maximum phrase length ($gentext(max)) less than minimumn phrase length ($gentext(min))"
						continue
					}
				}
				set fnam $gentext(in)
				set adv_fnam $fnam
				append adv_fnam "_adv" $evv(TEXT_EXT)
				if {![file exists $adv_fnam]} {
					Inf "Adverbs files $adv_fnam does not exist"
					continue
				}
				set adjfnam $fnam
				append adjfnam "_adj"
				set n 0
				while {1} {
					set adj_fnam($n) $adjfnam$n
					append adj_fnam($n) $evv(TEXT_EXT)
					if {![file exists $adj_fnam($n)]} {
						break
					}
					incr n
				}
				if {$n == 0} {
					Inf "No files of adjectives found"
					continue
				}
				set bigmsg "THERE ARE $n CATEGORIES OF ADJECTIVES"
				set adjcatcnt $n
				set cadjfnam $fnam
				append cadjfnam "_cadj"
				set n 0
				while {1} {
					set cadj_fnam($n) $cadjfnam$n
					append cadj_fnam($n) $evv(TEXT_EXT)
					if {![file exists $cadj_fnam($n)]} {
						break
					}
					incr n
				}
				if {$n == 0} {
					Inf "No files of contrary categories of adjectives found"
					continue
				}
				append bigmsg "\nTHERE ARE $n CONTRARY CATEGORIES OF ADJECTIVES"
				set adjconcatcnt $n

				set nounfnam $fnam
				append nounfnam "_noun"
				set n 0
				while {1} {
					set noun_fnam($n) $nounfnam$n
					append noun_fnam($n) $evv(TEXT_EXT)
					if {![file exists $noun_fnam($n)]} {
						break
					}
					incr n
				}
				if {$n == 0} {
					Inf "No categories of nouns found"
					continue
				}
				set msg "There are $n categories of nouns"
				append bigmsg "\n$msg"
				if {$n != $adjcatcnt} {
					append msg "\n\nThis does not tally with the number of categories of adjectives ($adjcatcnt): continue ??"
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
				}
				set nouncatcnt $n
				set cnounfnam $fnam
				append cnounfnam "_cnoun"
				set n 0
				while {1} {
					set cnoun_fnam($n) $cnounfnam$n
					append cnoun_fnam($n) $evv(TEXT_EXT)
					if {![file exists $cnoun_fnam($n)]} {
						break
					}
					incr n
				}
				if {$n == 0} {
					Inf "No contrary categories of nouns found"
					continue
				}
				set msg "There are $n contrary categories of nouns"
				append bigmsg "\n$msg"
				if {$n != $adjconcatcnt} {
					append msg "\n\nThis does not tally with the number of contrary categories of adjectives : continue ??"
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
					if {$choice == "no"} {
						continue
					}
				}
				set nounconcatcnt $n

				Inf $bigmsg

				;#	GET ALL DATA, COUNT, AND SET UP PERMUTATION FOR EACH

				if [catch {open $adv_fnam "r"} zit] {
					Inf "Cannot open file $adv_fnam to read adverbs"
					continue
				}
				catch {unset lines}
				while {[gets $zit line] >= 0} {
					set line [string trim $line]
					if {[string length $line] <= 0} {
						continue
					}
					if {[string match [string index $line 0 ] ";"]} {
						continue
					}
					lappend lines [string tolower $line]
				}
				close $zit
				if {![info exists lines] || ([llength $lines] <= 0)} {
					Inf "No data found in file $adv_fnam"
					continue
				}
				set adv $lines
				set cnt(adv) [llength $adv]
				randperm $cnt(adv)
				set perm(adv) $hopperm
				set cnt(adv_perm) 0

				set n 0
				set OK 1
				while {$n < $adjcatcnt} {
					catch {unset lines}
					if [catch {open $adj_fnam($n) "r"} zit] {
						Inf "Cannot open file $adj_fnam($n) to read adjectives in category $n"
						set OK 0
						break
					}
					while {[gets $zit line] >= 0} {
						set line [string trim $line]
						if {[string length $line] <= 0} {
							continue
						}
						if {[string match [string index $line 0 ] ";"]} {
							continue
						}
						lappend lines [string tolower $line]
					}
					close $zit
					if {![info exists lines] || ([llength $lines] <= 0)} {
						Inf "No data found in file $adv_fnam"
						set OK 0
						break
					}
					set adj($n) $lines
					set cnt(adj$n) [llength $adj($n)]
					randperm $cnt(adj$n)
					set perm(adj$n) $hopperm
					set cnt(perm_adj$n) 0
					incr n
				}
				if {!$OK} {
					continue
				}
				randperm $adjcatcnt
				set perm(adjcat) $hopperm
				set cnt(adjcat_perm) 0

				set n 0
				while {$n < $adjconcatcnt} {
					catch {unset lines}
					if [catch {open $cadj_fnam($n) "r"} zit] {
						Inf "Cannot open file $cadj_fnam($n) to read adjectives in contrary category $n"
						set OK 0
						break
					}
					while {[gets $zit line] >= 0} {
						set line [string trim $line]
						if {[string length $line] <= 0} {
							continue
						}
						if {[string match [string index $line 0 ] ";"]} {
							continue
						}
						lappend lines [string tolower $line]
					}
					close $zit
					if {![info exists lines] || ([llength $lines] <= 0)} {
						Inf "No data found in file $adv_fnam"
						set OK 0
						break
					}
					set cadj($n) $lines
					set cnt(cadj$n) [llength $cadj($n)]
					randperm $cnt(cadj$n)
					set perm(cadj$n) $hopperm
					set cnt(perm_cadj$n) 0
					incr n
				}
				if {!$OK} {
					continue
				}
				randperm $adjconcatcnt
				set perm(adjconcat) $hopperm
				set cnt(adjconcat_perm) 0

				set n 0
				while {$n < $nouncatcnt} {
					catch {unset lines}
					if [catch {open $noun_fnam($n) "r"} zit] {
						Inf "Cannot open file $noun_fnam($n) to read nouns in category $n"
						set OK 0
						break
					}
					while {[gets $zit line] >= 0} {
						set line [string trim $line]
						if {[string length $line] <= 0} {
							continue
						}
						if {[string match [string index $line 0 ] ";"]} {
							continue
						}
						lappend lines [string tolower $line]
					}
					close $zit
					if {![info exists lines] || ([llength $lines] <= 0)} {
						Inf "No data found in file $adv_fnam"
						set OK 0
						break
					}
					set noun($n) $lines
					set cnt(noun$n) [llength $noun($n)]
					randperm $cnt(noun$n)
					set perm(noun$n) $hopperm
					set cnt(perm_noun$n) 0
					incr n
				}
				if {!$OK} {
					continue
				}
				randperm $nouncatcnt
				set perm(nouncat) $hopperm
				set cnt(nouncat_perm) 0

				set n 0
				while {$n < $nounconcatcnt} {
					catch {unset lines}
					if [catch {open $cnoun_fnam($n) "r"} zit] {
						Inf "Cannot open file $cnoun_fnam($n) to read nouns in contrary category $n"
						set OK 0
						break
					}
					while {[gets $zit line] >= 0} {
						set line [string trim $line]
						if {[string length $line] <= 0} {
							continue
						}
						if {[string match [string index $line 0 ] ";"]} {
							continue
						}
						lappend lines [string tolower $line]
					}
					close $zit
					if {![info exists lines] || ([llength $lines] <= 0)} {
						Inf "No data found in file $adv_fnam"
						set OK 0
						break
					}
					set cnoun($n) $lines
					set cnt(cnoun$n) [llength $cnoun($n)]
					randperm $cnt(cnoun$n)
					set perm(cnoun$n) $hopperm
					set cnt(perm_cnoun$n) 0
					incr n
				}
				if {!$OK} {
					continue
				}

				randperm $nounconcatcnt
				set perm(nounconcat) $hopperm
				set cnt(nounconcat_perm) 0

	;#	ESTABLISH PERM OF PHRASE TYPES:	(0) Adj Noun	(1) Adj Adj Noun	(2) Adv Adj Noun	(3) Adj Noun Noun	(4) Noun Noun

				if {$gentext(short)} {
					set grammarcnt 5
				} else {
					set wordlencnt [expr $gentext(max) - $gentext(min) + 1]	;#	Number of possible phrase lengths
					set grammarcnt [expr $wordlencnt * 4]
				}
				randperm $grammarcnt
				set perm(grammar) $hopperm
				set gramcnt 0

				;#	SET WHETHER CONTRARY CATEGORY IS FINAL NOUN OR NOT-FINAL-NOUN

				set contrary_final 1

				;#	SET WHICH OF PAIR OF WORDS PRIOR TO FINAL NOUN (IN 3 WORD GRAMMARS) IS THE CONTRARY CATEGORY WHEN NOUN IS NOT THE CONTRARY CATEGORY

				set flip 0

				;#	PROCEED TO GENERATE OUTPUT TEXTS

				set outcnt 0
				catch {unset outtexts}
				while {$outcnt < $gentext(cnt)} {


					;#	CHOOSE A GRAMMAR

					set grammar [lindex $perm(grammar) $gramcnt]
					incr gramcnt
					if {$gramcnt >= $grammarcnt} {
						randperm $grammarcnt
						set perm(grammar) $hopperm
						set gramcnt 0
					}
					if {$gentext(short)} {
						switch -- $grammar {
							0 {	set wordseq	[list A N]   }
							1 {	set wordseq	[list A A N] }
							2 {	set wordseq	[list V A N] }
							3 {	set wordseq	[list A N N] }
							4 {	set wordseq	[list N N]   }
						}
					} else {
						set gramlen [expr $grammar/4]				;#	Convert "grammar" value (truncate) to wordlencnt-index (0 to wordlencnt)
						incr gramlen $gentext(min)					;#	Gives wordlength of phrase
						set gramtyp [expr $grammar % 4]				;#	Convert "grammar" value to range 0 to 3
						set wordseq [SetWordseq $gramtyp $gramlen]	;#	Generates phrase of correct type, and correct word-length
					}

					if {$gentext(short)} {


					;#	HANDLE SHORT GRAMMARS WHERE FINAL NOUN IS OF CONTRARY-TYPE

						if {$contrary_final} {
							set category [lindex $perm(nounconcat) $cnt(nounconcat_perm)]	;#	Get next category in random perm of contrary categories of nouns
							incr cnt(nounconcat_perm)
							if {$cnt(nounconcat_perm) >= $nounconcatcnt} {					;#	IF used all categories in perm ,reperm and reset permcnt to zero
								randperm $nounconcatcnt
								set perm(nounconcat) $hopperm
								set	cnt(nounconcat_perm) 0
							}
							set n $category
							set endnoun [lindex $cnoun($n) [lindex $perm(cnoun$n) $cnt(perm_cnoun$n)]]	;#	Get next of (perm of) nouns within category
							incr cnt(perm_cnoun$n)
							if {$cnt(perm_cnoun$n) >= $cnt(cnoun$n)} {
								randperm $cnt(cnoun$n)
								set perm(cnoun$n) $hopperm
								set cnt(perm_cnoun$n) 0
							}
							if {[llength $wordseq] == 2} {								;#	Other word must be non-contrary category
								switch -- [lindex $wordseq 0] {
									"A" {														;#	grammar 0 = AN
										set category [lindex $perm(adjcat) $cnt(adjcat_perm)]	;#	Get next category in random perm of categories of adjectives
										incr cnt(adjcat_perm)
										if {$cnt(adjcat_perm) >= $adjcatcnt} {					;#	IF used all categories in perm ,reperm and reset permcnt to zero
											randperm $adjcatcnt
											set perm(adjcat) $hopperm
											set	cnt(adjcat_perm) 0
										}
										set n $category
										set adjj [lindex $adj($n) [lindex $perm(adj$n) $cnt(perm_adj$n)]]				;#	Get next adjective within category
										incr cnt(perm_adj$n)
										if {$cnt(perm_adj$n) >= $cnt(adj$n)} {
											randperm $cnt(adj$n)
											set perm(adj$n) $hopperm
											set cnt(perm_adj$n) 0
										}
										set outtext [list $adjj $endnoun]
									}
									"N" {														;#	grammar 4 = NN
										set category [lindex $perm(nouncat) $cnt(nouncat_perm)]	;#	Get next category in random perm of categories of nouns
										incr cnt(nouncat_perm)
										if {$cnt(nouncat_perm) >= $nouncatcnt} {					;#	IF used all categories in perm ,reperm and reset permcnt to zero
											randperm $nouncatcnt
											set perm(nouncat) $hopperm
											set	cnt(nouncat_perm) 0
										}
										set n $category
										set nounn [lindex $noun($n) [lindex $perm(noun$n) $cnt(perm_noun$n)]]				;#	Get next noun within category
										incr cnt(perm_noun$n)
										if {$cnt(perm_noun$n) >= $cnt(noun$n)} {
											randperm $cnt(noun$n)
											set perm(noun$n) $hopperm
											set cnt(perm_noun$n) 0
										}
										set outtext [list $nounn $endnoun]

									}
								}
							} else {		;#	3 word text output

								switch -- [lindex $wordseq 0] {
									"A" {														
										set category [lindex $perm(adjcat) $cnt(adjcat_perm)]	;#	Get next category in random perm of categories of adjectives
										incr cnt(adjcat_perm)
										if {$cnt(adjcat_perm) >= $adjcatcnt} {					;#	IF used all categories in perm ,reperm and reset permcnt to zero
											randperm $adjcatcnt
											set perm(adjcat) $hopperm
											set	cnt(adjcat_perm) 0
										}
										set n $category
										set word1 [lindex $adj($n) [lindex $perm(adj$n) $cnt(perm_adj$n)]]				;#	Get next adjective within category
										incr cnt(perm_adj$n)
										if {$cnt(perm_adj$n) >= $cnt(adj$n)} {
											randperm $cnt(adj$n)
											set perm(adj$n) $hopperm
											set cnt(perm_adj$n) 0
										}
									}
									"V" {														
										set word1 [lindex $adv [lindex $perm(adv) $cnt(adv_perm)]]					;#	Get next adverb
										incr cnt(adv_perm)
										if {$cnt(adv_perm) >= $cnt(adv)} {
											randperm $cnt(adv)
											set perm(adv) $hopperm
											set cnt(adv_perm) 0
										}
									}
								}
								switch -- [lindex $wordseq 1] {
									"A" {														;#	grammar = AAN or VAN
										set category [lindex $perm(adjcat) $cnt(adjcat_perm)]	;#	Get next category in random perm of categories of adjectives
										incr cnt(adjcat_perm)
										if {$cnt(adjcat_perm) >= $adjcatcnt} {					;#	IF used all categories in perm ,reperm and reset permcnt to zero
											randperm $adjcatcnt
											set perm(adjcat) $hopperm
											set	cnt(adjcat_perm) 0
										}
										set n $category
										set word2 [lindex $adj($n) [lindex $perm(adj$n) $cnt(perm_adj$n)]]				;#	Get next adjective within category
										incr cnt(perm_adj$n)
										if {$cnt(perm_adj$n) >= $cnt(adj$n)} {
											randperm $cnt(adj$n)
											set perm(adj$n) $hopperm
											set cnt(perm_adj$n) 0
										}
									}
									"N" {														;#	grammar = ANN, AAN or VAN
										set category [lindex $perm(nouncat) $cnt(nouncat_perm)]	;#	Get next category in random perm of categories of nouns
										incr cnt(nouncat_perm)
										if {$cnt(nouncat_perm) >= $nouncatcnt} {					;#	IF used all categories in perm ,reperm and reset permcnt to zero
											randperm $nouncatcnt
											set perm(nouncat) $hopperm
											set	cnt(nouncat_perm) 0
										}
										set n $category
										set word2 [lindex $noun($n) [lindex $perm(noun$n) $cnt(perm_noun$n)]]				;#	Get next noun within category
										incr cnt(perm_noun$n)
										if {$cnt(perm_noun$n) >= $cnt(noun$n)} {
											randperm $cnt(noun$n)
											set perm(noun$n) $hopperm
											set cnt(perm_noun$n) 0
										}
									}
								}
								set outtext [list $word1 $word2 $endnoun]
							}
						
						} else {	;#	FINAL NOUN IS NOT A CONTRARY-CATEGORY

							set category [lindex $perm(nouncat) $cnt(nouncat_perm)]
							incr cnt(nouncat_perm)
							if {$cnt(nouncat_perm) >= $nouncatcnt} {
								randperm $nouncatcnt
								set perm(nouncat) $hopperm
								set	cnt(nouncat_perm) 0
							}
							set n $category
							set endnoun [lindex $noun($n) [lindex $perm(noun$n) $cnt(perm_noun$n)]]
							incr cnt(perm_noun$n)
							if {$cnt(perm_noun$n) >= $cnt(noun$n)} {
								randperm $cnt(noun$n)
								set perm(noun$n) $hopperm
								set cnt(perm_noun$n) 0
							}
							if {[llength $wordseq] == 2} {								;#	Other word must be CONTRARY category
								switch -- [lindex $wordseq 0] {
									"A" {														;#	grammar 0 = AN
										set category [lindex $perm(adjconcat) $cnt(adjconcat_perm)]
										incr cnt(adjconcat_perm)
										if {$cnt(adjconcat_perm) >= $adjconcatcnt} {
											randperm $adjconcatcnt
											set perm(adjconcat) $hopperm
											set	cnt(adjconcat_perm) 0
										}
										set n $category
										set adjj [lindex $cadj($n) [lindex $perm(cadj$n) $cnt(perm_cadj$n)]]
										incr cnt(perm_cadj$n)
										if {$cnt(perm_cadj$n) >= $cnt(cadj$n)} {
											randperm $cnt(cadj$n)
											set perm(cadj$n) $hopperm
											set cnt(perm_cadj$n) 0
										}
										set outtext [list $adjj $endnoun]
									}
									"N" {														;#	grammar 4 = NN
										set category [lindex $perm(nounconcat) $cnt(nounconcat_perm)]
										incr cnt(nounconcat_perm)
										if {$cnt(nounconcat_perm) >= $nounconcatcnt} {
											randperm $nounconcatcnt
											set perm(nounconcat) $hopperm
											set	cnt(nounconcat_perm) 0
										}
										set n $category
										set nounn [lindex $cnoun($n) [lindex $perm(cnoun$n) $cnt(perm_cnoun$n)]]				;#	Get next noun within category
										incr cnt(perm_cnoun$n)
										if {$cnt(perm_cnoun$n) >= $cnt(cnoun$n)} {
											randperm $cnt(cnoun$n)
											set perm(cnoun$n) $hopperm
											set cnt(perm_cnoun$n) 0
										}
										set outtext [list $nounn $endnoun]

									}
								}
							} else {		;#	3 word text output, select which of first two words (if they are noun or adjective) is the contrary category
											;#	if "flip" , 2nd is contrary: ELSE 1st is contrary	
								switch -- [lindex $wordseq 0] {
									"A" {														
										if {$flip} {
											set category [lindex $perm(adjcat) $cnt(adjcat_perm)]
											incr cnt(adjcat_perm)
											if {$cnt(adjcat_perm) >= $adjcatcnt} {
												randperm $adjcatcnt
												set perm(adjcat) $hopperm
												set	cnt(adjcat_perm) 0
											}
											set n $category
											set word1 [lindex $adj($n) [lindex $perm(adj$n) $cnt(perm_adj$n)]]
											incr cnt(perm_adj$n)
											if {$cnt(perm_adj$n) >= $cnt(adj$n)} {
												randperm $cnt(adj$n)
												set perm(adj$n) $hopperm
												set cnt(perm_adj$n) 0
											}
										} else {
											set category [lindex $perm(adjconcat) $cnt(adjconcat_perm)]
											incr cnt(adjconcat_perm)
											if {$cnt(adjconcat_perm) >= $adjconcatcnt} {
												randperm $adjconcatcnt
												set perm(adjconcat) $hopperm
												set	cnt(adjconcat_perm) 0
											}
											set n $category
											set word1 [lindex $cadj($n) [lindex $perm(cadj$n) $cnt(perm_cadj$n)]]				;#	Get next adjective within category
											incr cnt(perm_cadj$n)
											if {$cnt(perm_cadj$n) >= $cnt(cadj$n)} {
												randperm $cnt(cadj$n)
												set perm(cadj$n) $hopperm
												set cnt(perm_cadj$n) 0
											}
										}
									}
									"V" {														
										set word1 [lindex $adv [lindex $perm(adv) $cnt(adv_perm)]]					;#	Get next adverb
										incr cnt(adv_perm)
										if {$cnt(adv_perm) >= $cnt(adv)} {
											randperm $cnt(adv)
											set perm(adv) $hopperm
											set cnt(adv_perm) 0
										}
									}
								}
								switch -- [lindex $wordseq 1] {									;#	Grammar VAN AAN
									"A" {
										if {([lindex $wordseq 0] == "V") || $flip} {
											set category [lindex $perm(adjconcat) $cnt(adjconcat_perm)]
											incr cnt(adjconcat_perm)
											if {$cnt(adjconcat_perm) >= $adjconcatcnt} {
												randperm $adjconcatcnt
												set	cnt(adjconcat_perm) 0
											}
											set n $category
											set word2 [lindex $cadj($n) [lindex $perm(cadj$n) $cnt(perm_cadj$n)]]
											incr cnt(perm_cadj$n)
											if {$cnt(perm_cadj$n) >= $cnt(cadj$n)} {
												randperm $cnt(cadj$n)
												set perm(cadj$n) $hopperm
												set cnt(perm_cadj$n) 0
											}
											if {$flip} {
												set flip [exzpr !$flip]
											}
										} else {
											set category [lindex $perm(adjcat) $cnt(adjcat_perm)]
											incr cnt(adjcat_perm)
											if {$cnt(adjcat_perm) >= $adjcatcnt} {
												randperm $adjcatcnt
												set	cnt(adjcat_perm) 0
											}
											set n $category
											set word2 [lindex $adj($n) [lindex $perm(adj$n) $cnt(perm_adj$n)]]
											incr cnt(perm_adj$n)
											if {$cnt(perm_adj$n) >= $cnt(adj$n)} {
												randperm $cnt(adj$n)
												set perm(adj$n) $hopperm
												set cnt(perm_adj$n) 0
											}
										}
									}
									"N" {														;#	grammar 4 = ANN
										if {$flip} {
											set category [lindex $perm(nounconcat) $cnt(nounconcat_perm)]
											incr cnt(nounconcat_perm)
											if {$cnt(nounconcat_perm) >= $nounconcatcnt} {
												randperm $nounconcatcnt
												set perm(nounconcat) $hopperm
												set	cnt(nounconcat_perm) 0
											}
											set n $category
											set word2 [lindex $cnoun($n) [lindex $perm(cnoun$n) $cnt(perm_cnoun$n)]]
											incr cnt(perm_cnoun$n)
											if {$cnt(perm_cnoun$n) >= $cnt(cnoun$n)} {
												randperm $cnt(cnoun$n)
												set perm(cnoun$n) $hopperm
												set cnt(perm_cnoun$n) 0
											}
										} else {
											set category [lindex $perm(nouncat) $cnt(nouncat_perm)]
											incr cnt(nouncat_perm)
											if {$cnt(nouncat_perm) >= $nouncatcnt} {
												randperm $nouncatcnt
												set perm(nouncat) $hopperm
												set	cnt(nouncat_perm) 0
											}
											set n $category
											set word2 [lindex $noun($n) [lindex $perm(noun$n) $cnt(perm_noun$n)]]
											incr cnt(perm_noun$n)
											if {$cnt(perm_noun$n) >= $cnt(noun$n)} {
												randperm $cnt(noun$n)
												set perm(noun$n) $hopperm
												set cnt(perm_noun$n) 0
											}
										}
									}
								}
								set outtext [list $word1 $word2 $endnoun]
							}
						}

					} else {		;#	LONG PHRASES

						if {$contrary_final} {	;#	FINAL NOUN IS A CONTRARY-CATEGORY

							set category [lindex $perm(nounconcat) $cnt(nounconcat_perm)]	;#	Get next category in random perm of contrary categories of nouns
							incr cnt(nounconcat_perm)
							if {$cnt(nounconcat_perm) >= $nounconcatcnt} {					;#	IF used all categories in perm ,reperm and reset permcnt to zero
								randperm $nounconcatcnt
								set perm(nounconcat) $hopperm
								set	cnt(nounconcat_perm) 0
							}
							set n $category
							set endnoun [lindex $cnoun($n) [lindex $perm(cnoun$n) $cnt(perm_cnoun$n)]]	;#	Get next of (perm of) nouns within category
							incr cnt(perm_cnoun$n)
							if {$cnt(perm_cnoun$n) >= $cnt(cnoun$n)} {
								randperm $cnt(cnoun$n)
								set perm(cnoun$n) $hopperm
								set cnt(perm_cnoun$n) 0
							}

						} else {	;#	FINAL NOUN IS NOT A CONTRARY-CATEGORY

							set category [lindex $perm(nouncat) $cnt(nouncat_perm)]
							incr cnt(nouncat_perm)
							if {$cnt(nouncat_perm) >= $nouncatcnt} {
								randperm $nouncatcnt
								set perm(nouncat) $hopperm
								set	cnt(nouncat_perm) 0
							}
							set n $category
							set endnoun [lindex $noun($n) [lindex $perm(noun$n) $cnt(perm_noun$n)]]
							incr cnt(perm_noun$n)
							if {$cnt(perm_noun$n) >= $cnt(noun$n)} {
								randperm $cnt(noun$n)
								set perm(noun$n) $hopperm
								set cnt(perm_noun$n) 0
							}
						}					
						set isadverb 0
						if {$gramtyp > 1} {										;#	PAIR OF NOUNS AT END
							set adjcnt [expr $gramlen - 2]
						} else {												;#	SINGLE NOUN AT END
							set adjcnt [expr $gramlen - 1]
						}
						if {[string match [lindex $wordseq 0] "V"]} {			;#	ADVERB AT START
							incr adjcnt -1
							set isadverb 1
						}
						set outtext {}											;#	BEGIN WITH EMPTY PHRASE
						if {$isadverb} {
							set word1 [lindex $adv [lindex $perm(adv) $cnt(adv_perm)]]					;#	Get next adverb
							incr cnt(adv_perm)
							if {$cnt(adv_perm) >= $cnt(adv)} {
								randperm $cnt(adv)
								set perm(adv) $hopperm
								set cnt(adv_perm) 0
							}
							lappend outtext $word1								;#	PHRASE STARTS WITH ADVERB
						}
						set kj 0
						while {$kj < $adjcnt} {									;#	ADD ALL THE ADJECTIVES, FLIPPING CONTRARY/NON-CONTRARY TYPES
							if {$flip} {
								set category [lindex $perm(adjcat) $cnt(adjcat_perm)]
								incr cnt(adjcat_perm)
								if {$cnt(adjcat_perm) >= $adjcatcnt} {
									randperm $adjcatcnt
									set perm(adjcat) $hopperm
									set	cnt(adjcat_perm) 0
								}
								set n $category
								set word1 [lindex $adj($n) [lindex $perm(adj$n) $cnt(perm_adj$n)]]
								incr cnt(perm_adj$n)
								if {$cnt(perm_adj$n) >= $cnt(adj$n)} {
									randperm $cnt(adj$n)
									set perm(adj$n) $hopperm
									set cnt(perm_adj$n) 0
								}
							} else {
								set category [lindex $perm(adjconcat) $cnt(adjconcat_perm)]
								incr cnt(adjconcat_perm)
								if {$cnt(adjconcat_perm) >= $adjconcatcnt} {
									randperm $adjconcatcnt
									set perm(adjconcat) $hopperm
									set	cnt(adjconcat_perm) 0
								}
								set n $category
								set word1 [lindex $cadj($n) [lindex $perm(cadj$n) $cnt(perm_cadj$n)]]				;#	Get next adjective within category
								incr cnt(perm_cadj$n)
								if {$cnt(perm_cadj$n) >= $cnt(cadj$n)} {
									randperm $cnt(cadj$n)
									set perm(cadj$n) $hopperm
									set cnt(perm_cadj$n) 0
								}
							}
							lappend outtext $word1
							set flip [expr !$flip]
							incr kj
						}
						if {$gramtyp > 1} {				;#	PAIR OF NOUNS AT END

							if {$contrary_final} {		;#	FINAL NOUN IS A CONTRARY-CATEGORY, SO THIS ONE IS NOT
								set category [lindex $perm(nouncat) $cnt(nouncat_perm)]
								incr cnt(nouncat_perm)
								if {$cnt(nouncat_perm) >= $nouncatcnt} {
									randperm $nouncatcnt
									set perm(nouncat) $hopperm
									set	cnt(nouncat_perm) 0
								}
								set n $category
								set word1 [lindex $noun($n) [lindex $perm(noun$n) $cnt(perm_noun$n)]]
								incr cnt(perm_noun$n)
								if {$cnt(perm_noun$n) >= $cnt(noun$n)} {
									randperm $cnt(noun$n)
									set perm(noun$n) $hopperm
									set cnt(perm_noun$n) 0
								}

							} else {	;#	FINAL NOUN IS NOT A CONTRARY-CATEGORY, SO THIS ONE IS

								set category [lindex $perm(nounconcat) $cnt(nounconcat_perm)]	;#	Get next category in random perm of contrary categories of nouns
								incr cnt(nounconcat_perm)
								if {$cnt(nounconcat_perm) >= $nounconcatcnt} {					;#	IF used all categories in perm ,reperm and reset permcnt to zero
									randperm $nounconcatcnt
									set perm(nounconcat) $hopperm
									set	cnt(nounconcat_perm) 0
								}
								set n $category
								set word1 [lindex $cnoun($n) [lindex $perm(cnoun$n) $cnt(perm_cnoun$n)]]	;#	Get next of (perm of) nouns within category
								incr cnt(perm_cnoun$n)
								if {$cnt(perm_cnoun$n) >= $cnt(cnoun$n)} {
									randperm $cnt(cnoun$n)
									set perm(cnoun$n) $hopperm
									set cnt(perm_cnoun$n) 0
								}
							}					
							lappend outtext $word1

						}
						lappend outtext $endnoun

					}
					set outtext [StripCurliesFromWords $outtext]
					if {$gentext(short) && [Excluded $outtext $grammar]} {
						continue
					}
					lappend outtexts $outtext
					set contrary_final [expr !$contrary_final]			;#		Swap placing of contrary category
					incr outcnt
				}
				if [catch {open $ofnam "w"} zit] {
					Inf "Cannot open output file $ofnam to write output texts"
					continue
				}
				foreach outtext $outtexts {
					puts $zit $outtext
				}
				close $zit
				if {[FileToWkspace $ofnam 0 0 0 0 1] > 0} {
					Inf "File $ofnam is on the workspace"
				}
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}	

proc GenTextChooseLen {short} {
	switch -- $short {
		0 {
			.gentext.3.a.mi config -text "min"
			.gentext.3.a.min config -bd 2 -state normal
			.gentext.3.a.ma config -text "max"
			.gentext.3.a.max config -bd 2 -state normal
		}
		1 {
			.gentext.3.a.mi config -text ""
			.gentext.3.a.min config -bd 0 -state disabled -disabledbackground [option get . background {}]
			.gentext.3.a.ma config -text ""
			.gentext.3.a.max config -bd 0 -state disabled -disabledbackground [option get . background {}]
		}
	}
}

proc Excluded {outtext grammar} {

	;#	GRAMMAR TYPES:	(0) Adj Noun	(1) Adj Adj Noun	(2) Adv Adj Noun	(3) Adj Noun Noun	(4) Noun Noun

	set item [lindex $outtext 0]
	set len [string length $item]
		
	switch -- $grammar {
		2 {		;# ADV (Adj Noun)

			set meti [ReverseString $item]
			set k [string first "ylla" $meti] 
			if {$k == 0} {
				set substr(0) [string range $item 0 [expr $len - 5]]
			} else {
				set k [string first "yl" $meti] 
				if {$k == 0} {
					set substr(0) [string range $item 0 [expr $len - 3]]
				} else {
					set sublen [expr int(round($len * 0.7))]
					incr sublen -1
					set substr(0) [string range $item 0 $sublen]
				}
			}
		}
		default {			;#	ADJ OR NOUN
			set sublen [expr int(round($len * 0.7))]
			incr sublen -1
			set substr(0) [string range $item 0 $sublen]
		}
	}
	set item [lindex $outtext 1]
	set len [string length $item]
	set sublen [expr int(round($len * 0.7))]
	incr sublen -1
	set substr(1) [string range $item 0 $sublen]

	if {($grammar != 0)  && ($grammar != 4)} {
		set item [lindex $outtext 2]
		set len [string length $item]
		set sublen [expr int(round($len * 0.67))]
		incr sublen -1
		set substr(2) [string range $item 0 $sublen]
		set len 3
	} else {
		set len 2
	}
	set len_less_one [expr $len - 1]
	set minstrlen [string length $substr(0)]
	set n 1
	while {$n < $len} {
		if {[string length $substr($n)] < $minstrlen} {
			set minstrlen [string length $substr($n)]
		}
		incr n
	}
	set submin [expr $minstrlen - 1]
	set n 0
	while {$n <$len} {
		if {[string length $substr($n)] > $minstrlen} {
			set substr($n) [string range $substr($n) 0 $submin] 
		}
		incr n
	}
	set n 0
	while {$n <$len_less_one} {
		set m $n
		incr m
		while {$m < $len} {
			if {[string match $substr($n) $substr($m)]} {
				return 1
			}
			incr m
		}
		incr n
	}
	return 0
}

proc GentextHelp {} {

	set msg "generate Permuted Texts\n"
	append msg "\n"
	append msg "This procedure expects to find a set of textfiles.\n"
	append msg "\n"
	append msg "Every textfile_name begins with the Generic Name you input (e.g. myname).\n"
	append msg "\n"
	append msg "Each of these textfiles contains a list of nouns, adjectives or adverbs.\n"
	append msg "\n"
	append msg "The Nouns and Adjectives are chosen from different \"categories\", numbered from ZERO upwards.\n"
	append msg "\n"
	append msg "A \"category\" might be words from psychology, or words from botany, or words from needlecraft or ....\n"
	append msg "\n"
	append msg "Categories of nouns and adjectives correspond :\n"
	append msg "e.g. category \"2\" of the nouns is the same as category \"2\" of the adjectives.\n"
	append msg "\n"
	append msg "Categories are further divided into two contrasting types\n"
	append msg "\n"
	append msg "e.g. words from sciences (psychology, sociology, neuroscience, etc.)\n"
	append msg "may form a set of categories contrasting with words from non-scientific categories such as \n"
	append msg "literature, religion, flavour, emotional state, and so on ...\n"
	append msg "\n"
	append msg "\n"
	append msg "The set of files the process expects to find are (using generic name \"myname\")..\n"
	append msg "\n"
	append msg "       myname_adv.txt      = a list of adverbs.\n"
	append msg "       myname_adjN.txt     = a list of adjectives in category N.\n"
	append msg "       myname_nounN.txt  = a list of nouns in category N.\n"
	append msg "       myname_cadjM.txt    = a list of adjectives in contrasting-type category-M\n"
	append msg "       myname_cnounM.txt = a list of nouns in contrasting-type category-M\n"
	append msg "\n"
	append msg "NB: The simplest way to input a generic name\n"
	append msg "is to highlight ONE of the source textfiles on the workspace\n"
	append msg "or select it to the chosen-files list.\n"
	append msg "\n"
	Inf $msg
}

#--- Extract any lines marked with a "*" in a list of lines

proc SelectStarredTexts {} {
	global chlist wl evv pa starsortnam pr_starsort

	if {[info exists chlist] && ([llength $chlist] == 1)}  {
		set fnam $chlist
	} else {
		set i [$wl curselection]
		if {[info exists i] && ([llength $i] == 1) && ($i != -1)}  {
			set fnam [$wl get $i]
		}
	}
	if {[info exists fnam]} {
		if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
			unset fnam
		}
	}
	if {![info exists fnam]} {
		Inf "Select a textfile list of texts"
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot open file $fnam to read: $zit"
		return
	}
	set linecnt 0
	set OK 1
	while {[gets $zit line] >= 0} {
		incr linecnt
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match ";" [string index $line 0 ]]} {
			continue
		}
		if {[regexp {[^A-Za-z_\-\ \:\,\']} $line]} {		;# Alphabetic,underscore,hyphen,space, or colon
			Inf "Line $linecnt\n$line\ncontains invalid character(s) : (must be alphabetic, hyphen , underscore, apostrophe, comma, colon or space)"
			set OK 0
			break
		}
		lappend lines $line

	}
	close $zit
	if {!$OK} {
		return
	}
	if {![info exists lines] || ([llength $lines] <= 0)} {
		Inf "No data found in file $fnam"
		return
	}
	set f .starsort
	if [Dlg_Create $f "EXTRACT STARRED LINES" "set pr_starsort 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.s -text "Extract" -command {set pr_starsort 1} -width 8 -highlightbackground [option get . background {}]
		button $f.0.q -text "Abandon" -command {set pr_starsort 0} -width 8 -highlightbackground [option get . background {}]
		pack $f.0.s -side left
		pack $f.0.q -side right 
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Output filename "
		entry $f.1.e -textvariable starsortnam -width 48
		set starsortnam ""
		pack $f.1.ll $f.1.e -side right 
		pack $f.1 -side top
		frame $f.2
		label $f.2.tit -text "Select or deselect lines with mouse click" -fg $evv(SPECIAL)
		Scrolled_Listbox $f.2.ll -width 120 -height 32 -selectmode single
		pack $f.2.tit $f.2.ll -side top -pady 2
		pack $f.2 -side top
		wm resizable $f 0 0
		bind $f.2.ll.list <ButtonRelease-1> {StarUnstar %y}
		bind $f <Return> {set pr_starsort 1}
		bind $f <Escape> {set pr_starsort 0}
	}
	set starsortnam [file rootname [file tail $fnam]]
	append starsortnam "_chosen"
	.starsort.2.ll.list delete 0 end
	foreach line $lines {
		.starsort.2.ll.list insert end $line
	}
	set pr_starsort 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_starsort
	while {!$finished} {
		tkwait variable pr_starsort
		switch -- $pr_starsort {
			0 {
				set finished 1
			}
			1 {
				if {![ValidCDPRootname $starsortnam]} {
					continue
				}
				set ofnam [string tolower $starsortnam]
				append ofnam $evv(TEXT_EXT)
				if {[file exists $ofnam]} {
					Inf "File $ofnam already exists : please choose a different name"
					continue
				}

			;#	SEARCH FOR STARRED ITEMS

				catch {unset nulines}
				foreach line [.starsort.2.ll.list get 0 end] {
					set len [string length $line]
					set k [string first "*" $line]
					if {$k == 0} {
						set nuline [string range $line 1 end]
						if {[string length $nuline] > 0} {
							lappend nulines $nuline
						}
					}
				}
				if {![info exists nulines]} {
					Inf "No starred items to extract"
					continue
				}
				if [catch {open $ofnam "w"} zit] {
					Inf "Cannot open file $ofnam to write: $zit"
					continue
				}
				foreach line $nulines {
					puts $zit $line
				}
				close $zit
				if {[FileToWkspace $ofnam 0 0 0 0 1] > 0} {
					Inf "File $ofnam is on the workspace"
				}
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc StarUnstar {y} {
	set i [.starsort.2.ll.list nearest $y]
	if {$i < 0} {
		return
	}
	set txt [.starsort.2.ll.list get $i]
	set k [string first "*" $txt]
	if {$k == 0} {
		set txt [string range $txt 1 end]
		.starsort.2.ll.list delete $i
		.starsort.2.ll.list insert $i $txt
	} else {
		set nutxt "*"
		append nutxt $txt
		.starsort.2.ll.list delete $i
		.starsort.2.ll.list insert $i $nutxt
	}
}


proc ConflateTexts {} {
	global wl chlist pa evv conflatenam pr_conflate conflate_resort

	if {[info exists chlist] && ([llength $chlist] >= 2)} {
		foreach fnam $chlist {
			if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
				catch {unset fnams}
				break
			}
			lappend fnams $fnam
		}
	}
	if {![info exists fnams]} {
		set ilist [$wl curselection]
		if {[info exists ilist] && ([llength $ilist] > 1)} {
			foreach i $ilist {
				set fnam [$wl get $i]
				if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
					catch {unset fnams}
					break
				}
				lappend fnams $fnam
			}
		}
	}
	if {![info exists fnams]} {
		Inf "Choose two or more textfiles to conflate"
		return
	}
	set OK 1
	set lines {}
	foreach fnam $fnams {
		catch {unset nulines}
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot open file $fnam to read data"
			return
		}
		while {[gets $zit line] >= 0}	 {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			if {[string match ";" [string index $line 0]]} {
				continue
			}
			lappend nulines $line
		}
		close $zit
		if {![info exists nulines] || ([llength $nulines] <= 0)} {
			Inf "No data found in file $fnam"
			set OK 0
			break
		}
		set lines [concat $lines $nulines]
	}
	if {!$OK} {
		return
	}
	set f .conflate
	if [Dlg_Create $f "CONFLATE & RE-SORT TEXTS IN TEXTFILES" "set pr_conflate 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.s -text "Conflate" -command {set pr_conflate 1} -width 8 -highlightbackground [option get . background {}]
		checkbutton $f.0.ch -text ReSort -variable conflate_resort
		set conflate_resort 0 
		button $f.0.q -text "Abandon"  -command {set pr_conflate 0} -width 8 -highlightbackground [option get . background {}]
		pack $f.0.s $f.0.ch -side left -padx 16
		pack $f.0.q -side right 
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Output filename "
		entry $f.1.e -textvariable conflatenam -width 48
		set conflatenam ""
		pack $f.1.ll $f.1.e -side right 
		pack $f.1 -side top
		wm resizable $f 0 0
		bind $f <Return> {set pr_conflate 1}
		bind $f <Escape> {set pr_conflate 0}
	}
	set pr_conflate 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_conflate
	while {!$finished} {
		tkwait variable pr_conflate
		switch -- $pr_conflate {
			0 {
				set finished 1
			}
			1 {
				if {![ValidCDPRootname $conflatenam]} {
					continue
				}
				set ofnam [string tolower $conflatenam]
				append ofnam $evv(TEXT_EXT)
				if {[file exists $ofnam]} {
					Inf "File $ofnam already exists : please choose a different name"
					continue
				}
				if {$conflate_resort} {
					set lines [lsort -dictionary $lines]
					set lines [RemoveDuplicatesInList $lines]
				}
				if [catch {open $ofnam "w"} zit] {
					Inf "Cannot open file $ofnam to write: $zit"
					continue
				}
				foreach line $lines {
					puts $zit $line
				}
				close $zit
				if {[FileToWkspace $ofnam 0 0 0 0 1] > 0} {
					Inf "File $ofnam is on the workspace"
				}
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc MutualEliminationOfTexts {} {
	global wl chlist pa evv elimtxnam pr_elimtx

	if {[info exists chlist] && ([llength $chlist] >= 2)} {
		foreach fnam $chlist {
			if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
				catch {unset fnams}
				break
			}
			lappend fnams $fnam
		}
	}
	if {![info exists fnams]} {
		set ilist [$wl curselection]
		if {[info exists ilist] && ([llength $ilist] > 1)} {
			foreach i $ilist {
				set fnam [$wl get $i]
				if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
					catch {unset fnams}
					break
				}
				lappend fnams $fnam
			}
		}
	}
	if {![info exists fnams]} {
		Inf "Choose two or more textfiles to conflate"
		return
	}
	set OK 1
	set n 0
	foreach fnam $fnams {
		catch {unset lines($n)}
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot open file $fnam to read data"
			return
		}
		while {[gets $zit line] >= 0}	 {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			if {[string match ";" [string index $line 0]]} {
				continue
			}
			lappend lines($n) $line
		}
		close $zit
		if {![info exists lines($n)] || ([llength $lines($n)] <= 0)} {
			Inf "No data found in file $fnam"
			set OK 0
			break
		}
		set textslen($n) [llength $lines($n)]
		incr n
	}
	if {!$OK} {
		return
	}

	;#	COMPARE FILE-TEXTLISTINGS PAIRWISE

	set filecnt [llength $fnams]
	set filecnt_less_one [expr $filecnt - 1]
	set n_fileno 0
	while {$n_fileno < $filecnt_less_one} {
		set m_fileno $n_fileno
		incr m_fileno
		while {$m_fileno < $filecnt} {

			;#	COMPARE TEXTS IN PAIR OF TEXTLISTINGS

			set nn 0
			while {$nn < $textslen($n_fileno)} {
				set nline [lindex $lines($n_fileno) $nn]
				set mm 0
				while {$mm < $textslen($m_fileno)} {
					set mline [lindex $lines($m_fileno) $mm]
					if {[string match $nline $mline]} {
						if {$textslen($n_fileno) >= $textslen($m_fileno)} {
							set lines($n_fileno) [lreplace $lines($n_fileno) $nn $nn]
							incr textslen($n_fileno) -1
							set modified($n_fileno) 1			;#	Flag that textlisting n_fileno has been modified
							lappend modification $nline			;#	Flag that some textlisting has been modified
						} else {
							set lines($m_fileno) [lreplace $lines($m_fileno) $mm $mm]
							incr textslen($m_fileno) -1
							set modified($m_fileno) 1			;#	Flag that textlisting m_fileno has been modified
							lappend modification $mline			;#	Flag that some textlisting has been modified
						}
					}
					incr mm
				}
				incr nn
			}
			incr m_fileno
		}
		incr n_fileno
	}
	if {![info exists modification]} {
		Inf "No changes to existing data"
		return
	}
	set modification [lsort -dictionary $modification]

	set f .elimtx
	if [Dlg_Create $f "ELIMINATE TEXTS SHARED BY TEXTFILES" "set pr_elimtx 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.s -text "Eliminate" -command {set pr_elimtx 1} -width 9 -highlightbackground [option get . background {}]
		button $f.0.h -text "Help" -command {set pr_elimtx 2} -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.0.q -text "Abandon"  -command {set pr_elimtx 0}  -width 9 -highlightbackground [option get . background {}]
		pack $f.0.s $f.0.h -side left -padx 2
		pack $f.0.q -side right 
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.tit -text "Eliminated Duplicates" -fg $evv(SPECIAL)
		Scrolled_Listbox $f.1.ll -width 60 -height 32 -selectmode single
		pack $f.1.tit $f.1.ll -side top -pady 2
		pack $f.1 -side top
		wm resizable $f 0 0
		bind $f <Return> {set pr_elimtx 1}
		bind $f <Escape> {set pr_elimtx 0}
	}
	.elimtx.1.ll.list delete  0 end
	foreach item $modification {
		.elimtx.1.ll.list  insert end $item
	}
	set pr_elimtx 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_elimtx
	while {!$finished} {
		tkwait variable pr_elimtx
		switch -- $pr_elimtx {
			0 {
				set finished 1
			}
			1 {
				catch {unset ofnams}
				set n 0
				set OK 1
				foreach fnam $fnams {
					if {[info exists modified($n)]} {
						set ofnam($n) [file rootname [file tail $fnam]]
						append ofnam($n) "_short" $evv(TEXT_EXT)
						if {[file exists $ofnam($n)]} {
							Inf "File $ofnam($n) already exists: delete or rename it before proceeding"
							set OK 0
						}
					}
					incr n
				}
				if {!$OK} {
					break
				}
				set n 0
				foreach fnam $fnams {
					if {[info exists modified($n)]} {
						if [catch {open $ofnam($n) "w"} zit] {
							Inf "Cannot open file $ofnam($n) to write: $zit"
							set OK 0
							break
						}
						foreach line $lines($n) {
							puts $zit $line
						}
						close $zit
						FileToWkspace $ofnam($n) 0 0 0 0 1
						lappend ofnams $ofnam($n)
					}
					incr n
				}
				if {!$OK} {
					if {![info exists ofnams]} {
						Inf "Failed to modify any textlisting"
						break
					} else {
						set msg "Failed to modify textlisting [expr $n + 1]"
						set m $n
						incr m
						while {$m < $filecnt} {
							if {[info exists modified($m)]} {
								append msg " and [expr $m + 1]"
							}
							incr m
						}
						append msg "\n\n"
					}
				} else {
					set msg ""
				}
				if {[info exists ofnams]} {
					append msg "Modified files are on the workspace"
					Inf $msg
				}
				set finished 1
			}
			2 {
				set hmsg "Eliminate shared texts\n"
				append hmsg "\n"
				append hmsg "NB It is assumed that Duplicated-lines\n"
				append hmsg "have been removed from these files.\n"
				append hmsg "\n"
				append hmsg "(1)  Compare textlines in two or more files\n"
				append hmsg "     which list textlines.\n"
				append hmsg "(2)  Find any textlines which occur\n"
				append hmsg "     in more than one file.\n"
				append hmsg "(3)  Eliminate any shared textline\n"
				append hmsg "     from all but one file,\n"
				append hmsg "(3)  Eliminate any shared textline from all but one file,\n"
				append hmsg "     retaining it only in the shortest file\n"
				append hmsg "     which shares that textline.\n"
				append hmsg "(4)  Do this for all shared textlines.\n"
				append hmsg "\n"
				Inf $hmsg
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc CheckForInvalidCharacters {} {
	global dl evv prg_dun prg_abortd simple_program_messages CDPidrun invalid_chars

	set i [$dl curselection]
	if {![info exists i] || ([llength $i] != 1) || ($i == -1)} {
		Inf "Select one file on the directory listing (on rhs of workspace)\nwhich you expect to be a listing alphabetic text"
		return
	}
	set fnam [$dl get $i]
	if {![string match [file extension $fnam] $evv(TEXT_EXT)]} {
		Inf "Choose a textfile which you expect to be listing alphabetic text"
		return
	}
	catch {unset invalid_chars}
	set cmd [file join $evv(CDPROGRAM_DIR) see_text_characters]
	lappend cmd $fnam
	set prg_dun 0
	set prg_abortd 0
	catch {unset simple_program_messages}
	if [catch {open "|$cmd"} CDPidrun] {
		Inf "Cannot run file-checking of file [file rootname [file tail $fnam]] : $CDPidrun"
		catch {unset CDPidrun}
		return
	} else {
		fileevent $CDPidrun readable "Get_Invalid_Characters"
	}
	vwait prg_dun
	if {$prg_abortd} {
		set prg_dun 0
	}
	if {!$prg_dun} {
		set msg "Failed to run file-checking of file [file rootname [file tail $fnam]]"
		set msg [AddSimpleMessages $msg]
		Inf $msg
		return
	}
	if {![info exists invalid_chars] || ([llength $invalid_chars] <= 0)} {
		Inf "No invalid characters found in file [file rootname [file tail $fnam]]"
	} else {
		set msg ""
		set cnt 0
		foreach line $invalid_chars {
			append msg "$line\n"
			incr cnt
			if {$cnt >= 10} {
				append msg "and more\n"
				break
			}
		}
		Inf $msg
	}		
}

proc Get_Invalid_Characters {} {
	global CDPidrun prg_dun prg_abortd invalid_chars

	if [eof $CDPidrun] {
		set prg_dun 1
		catch {close $CDPidrun}
		return
	} else {
		gets $CDPidrun line
		set line [string trim $line]
		if {[string length $line] <= 0} {
			return
		} elseif [string match invalid* $line] {
			lappend invalid_chars $line
		} else {
			return
		}
	}
	update idletasks
}

proc SyllableCount {} {
	global chlist wl evv pa pr_sybcnt sybcntval wstk

	if {[info exists chlist] && ([llength $chlist] > 0)}  {
		set fnams $chlist
	} else {
		set ilist [$wl curselection]
		if {[info exists ilist] && ([llength $ilist] > 0)}  {
			if {([llength $ilist] > 1) || ($ilist != -1)} {
				foreach i $ilist {
					lappend fnams [$wl get $i]
				}
			}
		}
	}
	if {[info exists fnams]} {
		foreach fnam $fnams {
			if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
				unset fnams
				break
			}
		}
	}
	if {![info exists fnams]} {
		Inf "Select alphabetic textfiles"
		return
	}
	set linecnt 0
	set OK 1
	set numeric_warning 0
	foreach fnam $fnams {
		set linecnt 0
		set word_cnt 0
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot open file $fnam to read: $zit"
			return
		}
		while {[gets $zit line] >= 0} {
			incr linecnt
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			if {[string match ";" [string index $line 0]]} {
				continue
			}
			if {!$numeric_warning} {
				if {[regexp {[0-9]+} $line]} {
					set msg "File contains numbers : ignore these or items containing them ?"
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg -default yes]
					if {$choice == "no"} {
						close $zit
						return
					}
					set numeric_warning 1
				}
			}
			if {[regexp {[^A-Za-z_\-\ \'\"\!\?\.\,\:0-9]} $line]} {		;# Alphabetic,underscore,hyphen,space
				Inf "Line $linecnt\n$line\n\nin file [file rootname [file tail $fnam]]\n\ncontains invalid character(s) \nmust be alphabetic, hyphen, underscore, quote marks, full-stop, comma, colon,\"?\",\"!\" or space)"
				set OK 0
				break
			}
			set line [split $line -_\ \t]
			foreach item $line {
				set item [string trim $item]
				if {[string length $item] <= 0} {
					continue
				}
				if {![regexp {[0-9]+} $item]} {
					lappend words $item
					incr word_cnt
				}
			}
			incr linecnt
		}
		close $zit
		if {$OK && ($word_cnt <= 0)} {
			set "NO WORDS FOUND IN FILE $fnam"
			set OK 0
		}
		if {!$OK} {
			return
		}
	}
	set syllabcnt 0
	foreach word $words {
		set have_vowel 0
		set have_y 0
		set len [string length $word]
		set len_less_one [expr $len - 1]
		set n 0
		while {$n < $len} {
			set letter [string index $word $n]
			if {[IsVowel $letter]} {
				set silent_e 0
				if {$have_y && ($have_y == [expr $n - 1])} {				;#	If the last letter was a "y" NOT at start of word
					if {[regexp {[aiouAIOU]} $letter]} {					;#	and this letter is "a" "i" "o" or "u"
						incr syllabcnt										;#	start of a fresh syllable e.y. "saying" 
						set have_y 0
					} else {												;#	else this letter is "e"
						if {$n < $len_less_one} {							;#	and if not the last letter in the word e.g. buyer, ---yee	
							incr syllabcnt									;#	indicates start of a fresh syllable
							set have_y 0
						}
					}
				} else {
					set have_y 0
				}
				if {[regexp {[eE]} $letter]} {
					if {$n == $len_less_one} {								;#	e at end as in "bite", almost always silent
						set silent_e 1
					} else {
						set k [expr $n - 2]
						if {$k >= 0} {
							set prepreletter [string index $word $k]		;#	 look for vowel cons vowel e.g. "ate--"
							set m [expr $n - 1]
							set preletter [string index $word $m]
							set j [expr $n + 1]
							set postletter [string index $word $j]			;#	 look for following letter(s)
							set h [expr $n + 2]
							if {$h < $len} {
								set postpostletter [string index $word $h]
							}																				
							if {![IsVowelOrY $preletter] && [IsVowelOrY $prepreletter]} {
								if {[regexp {[bB]} $postletter]} {											;#	"hereby"
									set silent_e 1
								} elseif {[regexp {[lL]} $postletter]} {									;#	"gravely" silent e :  "gravelly" not
									if {($h < $len) && ![regexp {[lL]} $postpostletter]} {
										set silent_e 1
									}
								} elseif {[regexp {[t]} $postletter]} {										;#	"safety" silent
									if {![regexp {[cC]} $preletter]} {										;#	"nicety" not
										set silent_e 1
									}
								}
							}
						}
					}
				}	 
				if {!$silent_e} {
					set have_vowel 1
				}
			} elseif {[regexp {[yY]} $letter]} {
				if {$n != 0} {												;#	a "y" which does not start a word, is a vowel
					set have_y $n
					if {!$have_vowel} {
						set have_vowel 1
					}
				}
			} else {														;#	a consonant
				if {$have_vowel} {											;#	if have vowel already, then that syllab has ended, so count it
					incr syllabcnt
				}
				set have_vowel 0
				set have_y 0
			}
			incr n
		}
		if {$have_vowel} {
			incr syllabcnt
		}
	}
	set f .sybcnt
	if [Dlg_Create $f "COUNT SYLLABLES : ASSESS SPOKEN DURATION" "set pr_sybcnt 0" -borderwidth $evv(SBDR) -width 50] {
		frame $f.0
		button $f.0.s -text "Count" -command {set pr_sybcnt 1} -width 9 -highlightbackground [option get . background {}]
		button $f.0.q -text "Abandon"  -command {set pr_sybcnt 0}  -width 9 -highlightbackground [option get . background {}]
		pack $f.0.s -side left
		pack $f.0.q -side right 
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Syllables per second "
		entry $f.1.e  -textvariable sybcntval -width 3 -state readonly
		set sybcntval 8
		label $f.1.up -text "Use Up/Down Arrow Keys" -fg $evv(SPECIAL)
		pack $f.1.ll $f.1.e $f.1.up -side left -pady 2
		pack $f.1 -side top
		wm resizable $f 0 0
		bind $f <Up>	{IncrSybcnt 0}
		bind $f <Down>	{IncrSybcnt 1}
		bind $f <Return> {set pr_sybcnt 1}
		bind $f <Escape> {set pr_sybcnt 0}
	}
	set pr_sybcnt 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_sybcnt
	while {!$finished} {
		tkwait variable pr_sybcnt
		switch -- $pr_sybcnt {
			1 {
				set mins 0
				set secs [expr int(round(double($syllabcnt)/double($sybcntval)))]
				if {$secs > 60} {
					set mins [expr $secs/60]
					set secs [expr $secs - ($mins * 60)]
				}
				set msg "$syllabcnt Syllables"
				if {[llength $fnams] > 1} {
					append msg " in [llength $fnams] Files"
				}
				if {$mins > 0} {
					append msg "\n= approx $mins mins $secs secs"
				} else {
					append msg "\n= $secs secs"
				}
				Inf $msg
			}
			0 {
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}


proc IsVowel {char} {
	if {[regexp {[aeiouAEIOU]} $char]} {
		return 1
	}
	return 0
}

proc IsVowelOrY {char} {
	if {[regexp {[aeiouyAEIOUY]} $char]} {
		return 1
	}
	return 0
}

proc SameFirstLastWord {} {
	global chlist wl evv pa fstlst_typ pr_fstlst excluded_words fstlst_cnt fstlst_fnam

	set excluded_words [list ad a and anti auto b bi bias bio c co cost cross d de electro factor fat high hoc ill in inter]
	lappend excluded_words k m micro multi neuro non of omni or p para pi pre pro product psycho ratio res sub super tend the to trans uni

	if {[info exists chlist] && ([llength $chlist] == 1)}  {
		set fnam $chlist
	} else {
		set i [$wl curselection]
		if {[info exists i] && ([llength $i] == 1) && ($i != -1)}  {
			set fnam [$wl get $i]
		}
	}
	if {[info exists fnam]} {
		if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
			unset fnam
		}
	}
	if {![info exists fnam]} {
		Inf "Select an alphabetic textfile"
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot open file $fnam to read: $zit"
		return
	}
	set linecnt 0
	set xlinecnt 1
	set OK 1
	while {[gets $zit line] >= 0} {
		catch {unset words}
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match ";" [string index $line 0]]} {
			continue
		}
		if {[regexp {[^A-Za-z_\-\ ]} $line]} {		;# Alphabetic,underscore,hyphen,space
			Inf "Line $xlinecnt\n$line\ncontains invalid character(s) : (must be alphabetic, hyphen , underscore or space)"
			set OK 0
			break
		}
		set line [split $line -_\ \t]
		foreach item $line {
			set item [string trim $item]
			if {[string length $item] <= 0} {
				continue
			}
			lappend words $item
		}
		if {[llength $words] <= 0} {
			Inf "No words found in line $xlinecnt"
			set OK 0
			break
		}
		lappend lines $words
		incr linecnt
		incr xlinecnt
	}
	close $zit
	if {!$OK} {
		return
	}
	if {![info exists lines] || ([llength $lines] <= 0)} {
		Inf "No lines found in file $fnam"
		return
	}
	set f .fstlst
	if [Dlg_Create $f "FIND LINES WITH SHARED WORDS" "set pr_fstlst 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.s -text "Find Matches" -command {set pr_fstlst 1} -width 12 -highlightbackground [option get . background {}]
		button $f.0.p -text "Partion to N files" -command {set pr_fstlst 2} -width 18 -highlightbackground [option get . background {}]
		button $f.0.q -text "Abandon"  -command {set pr_fstlst 0}  -width 9 -highlightbackground [option get . background {}]
		pack $f.0.s $f.0.p -side left -padx 2
		pack $f.0.q -side right 
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		radiobutton $f.1.first -text "First words same" -variable fstlst_typ -value 1
		radiobutton $f.1.last  -text "Last words same"  -variable fstlst_typ -value 2
		radiobutton $f.1.shared -text "Words shared"    -variable fstlst_typ -value 3
		pack $f.1.first $f.1.last $f.1.shared -side top -pady 2
		pack $f.1 -side top
		frame $f.1a
		label $f.1a.ll -text "Number of outfiles (range 2 - 100)"
		entry $f.1a.num -textvariable fstlst_cnt -width 4
		pack $f.1a.ll $f.1a.num -side left -pady 2
		pack $f.1a -side top
		frame $f.2
		label $f.2.tit -text "Duplicates" -fg $evv(SPECIAL)
		Scrolled_Listbox $f.2.ll -width 60 -height 32 -selectmode single
		pack $f.2.tit $f.2.ll -side top -pady 2
		pack $f.2 -side top
		wm resizable $f 0 0
		bind $f <Return> {set pr_fstlst 1}
		bind $f <Escape> {set pr_fstlst 0}
	}
	set fstlst_cnt ""
	.fstlst.0.p config -text "" -command {} -bd 0
	.fstlst.1a.ll config -text ""
	.fstlst.1a.num config -bd 0 -state disabled -bg [option get . background {}]
	set fstlst_typ 0
	.fstlst.2.ll.list delete  0 end
	set pr_fstlst 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_fstlst
	while {!$finished} {
		tkwait variable pr_fstlst
		switch -- $pr_fstlst {
			0 {
				set finished 1
			}
			1 {
				if {[info exists linegroup]} {
					foreach nam [array names linegroup] {
						catch {unset linegroup($nam)}	
					}
					catch {unset linegroup}
				}
				if {$fstlst_typ == 0} {
					Inf "No match-type selected"
					continue
				}
				set len_less_one [expr $linecnt - 1]
				set n 0
				set q 1
				Block "PLEASE WAIT : CHECKING ALL LINES"
				while {$n < $len_less_one} {
					set line_n [lindex $lines $n]
					wm title .blocker "CHECKING LINE $q of $linecnt"
					switch -- $fstlst_typ {
						1 {
							set word_n [lindex $line_n 0]
						}
						2 {
							set word_n [lindex $line_n end]
						}
					}
					set m $n
					incr m
					while {$m < $linecnt} {
						set line_m [lindex $lines $m]
						switch -- $fstlst_typ {
							1 {
								set word_m [lindex $line_m 0]
							}
							2 {
								set word_m [lindex $line_m end]
							}
						}
						if {$fstlst_typ <= 2} {
							if {!([IsExcludedWord $word_n] || [IsExcludedWord $word_m])} {
								if {[string match $word_n* $word_m] || [string match $word_m* $word_n]} {
									if {[string length $word_n] <= [string length $word_m]} {
										set nam $word_n
									} else {
										set nam $word_m
									}
									if {[info exists linegroup($nam)]} {
										if {[lsearch $linegroup($nam) $line_n] < 0} {
											lappend linegroup($nam) $line_n
										}
										if {[lsearch $linegroup($nam) $line_m] < 0} {
											lappend linegroup($nam) $line_m
										}
									} else {
										lappend linegroup($nam) $line_n
										lappend linegroup($nam) $line_m
									}
								}
							}
						} else {
							set n_len [llength $line_n]
							set m_len [llength $line_m]
							set nn 0
							while {$nn < $n_len} {
								set word_nn [lindex $line_n $nn]
								if {![IsExcludedWord $word_nn]} {
									set mm 0
									while {$mm < $m_len} {
										set word_mm [lindex $line_m $mm]
										if {![IsExcludedWord $word_mm]} {
											if {[string match $word_nn* $word_mm] || [string match $word_mm* $word_nn]} {
												if {[string length $word_nn] <= [string length $word_mm]} {
													set nam $word_nn
												} else {
													set nam $word_mm
												}
												if {[info exists linegroup($nam)]} {
													if {[lsearch $linegroup($nam) $line_n] < 0} {
														lappend linegroup($nam) $line_n
													}
													if {[lsearch $linegroup($nam) $line_m] < 0} {
														lappend linegroup($nam) $line_m
													}
												} else {
													lappend linegroup($nam) $line_n
													lappend linegroup($nam) $line_m
												}
											}
										}
										incr mm
									}
								}
								incr nn
							}
						}
						incr m
					}
					incr n
					incr q
				}
				UnBlock
				if {![info exists linegroup]} {
					Inf "No shared items found"
				} else {
					set maxshare 0
					set nams [lsort -dictionary [array names linegroup]]
					.fstlst.2.ll.list delete  0 end
					foreach nam $nams {
						.fstlst.2.ll.list  insert end "------------------- $nam -------------------"
						foreach item $linegroup($nam) {
							.fstlst.2.ll.list  insert end $item
						}
						if {[llength $linegroup($nam)] > $maxshare} {
							set maxshare [llength $linegroup($nam)]
							set bigshare $nam
						} elseif {[llength $linegroup($nam)] == $maxshare} {
							lappend bigshare $nam
						}
					}
				}
				set msg "Maximum mumber of lines with a shared word = $maxshare for the word"
				if {[llength $bigshare] > 1} {
					append msg "S"
				}
				foreach z $bigshare {
					append msg "\n$z"
				}
				Inf $msg
				.fstlst.0.p config -text "Partion to N files" -command {set pr_fstlst 2} -bd 2
				.fstlst.1a.ll config -text "Number of outfiles (range 2 - 100)"
				.fstlst.1a.num config -bd 2 -state normal
				continue
			}
			2 {
				if {[string length $fstlst_cnt] <= 0} {
					Inf "No count of partition files entered"
					continue
				}
				if {![IsNumeric $fstlst_cnt] || ![regexp {^[0-9]+$} $fstlst_cnt] || ($fstlst_cnt < 2) || ($fstlst_cnt > 100)} {
					Inf "Invalid  count of partition files entered"
					continue
				}
				set ofnambas [file rootname [file tail $fnam]]
				set n 0
				set OK 1
				catch {unset ofnams}
				while {$n < $fstlst_cnt} {
					set ofnam $ofnambas
					append ofnam "_" $n $evv(TEXT_EXT)
					if {[file exists $ofnam]} {
						Inf "File $ofnam already exists : please delete or rename before proceeding"
						set OK 0
						break
					}
					lappend ofnams $ofnam
					incr n
				}
				if {!$OK} {
					continue
				}
				Block "PLEASE WAIT : DISTRIBUTING TEXTS AMONGST $fstlst_cnt FILES"

				set len [llength $nams]
				set len_less_one [expr $len - 1]
				set n 0
				wm title .blocker "PLEASE WAIT : CHECKING LINE DUPLICATION IN REPEATED LINE GROUPS"
				while {$n < $len_less_one} {
					set nam_n [lindex $nams $n]
					set n_len [llength $linegroup($nam_n)]
					set m $n
					incr m
					while {$m < $len} {
						set nam_m [lindex $nams $m]
						set m_len [llength $linegroup($nam_m)]

						set nn 0
						set done 0
						while {$nn < $n_len} {
							set n_line [lindex $linegroup($nam_n) $nn]
							set mm 0
							while {$mm < $m_len} {
								set m_line [lindex $linegroup($nam_m) $mm]
								if {[string match $n_line $m_line]} {
									if {$n_len >= $m_len} {
										set linegroup($nam_m) [lreplace $linegroup($nam_m) $mm $mm]
										incr m_len -1
										incr mm -1		;#	mm item replaced : prevent advance in mm list
									} else {
										set linegroup($nam_n) [lreplace $linegroup($nam_n) $nn $nn]
										incr n_len -1
										incr nn -1		;#	nn item replaced : prevent advance in nn list
										break			;#	break out of mm loop : next pass will compare new item at nn with the mms
									}
								}
								incr mm
							}
							incr nn
						}
						incr m
					}
					incr n
				}
				foreach nam $nams {
					if {[llength $linegroup($nam)] <= 0} {
						unset linegroup($nam)
					}
				}
				set nams [array names linegroup]
				catch {unset otherlines}
				wm title .blocker "PLEASE WAIT : FINDING ALL LINES ~~NOT~~ IN REPEATED LINE GROUPS"
				foreach line $lines {
					set got 0
					foreach nam $nams {
						foreach gline $linegroup($nam) {
							if {[string match $line $gline]} {
								set got 1
								break
							}
						}
						if {$got} {
							break
						}
					}
					if {!$got} {
						lappend otherlines $line
					}
				}
				wm title .blocker "PLEASE WAIT : PARTITIONING FILES AMONGST $fstlst_cnt OUTPUT SETS"
				set jj 0
				while {$jj < $fstlst_cnt} {
					catch {unset outlist($jj)}
					incr jj
				}
				set jj 0
				foreach nam $nams {
					foreach line $linegroup($nam) {
						lappend outlist($jj) $line
						incr jj
						if {$jj >= $fstlst_cnt} {
							set jj 0
						}
					}
				}
				if {[info exists otherlines]} {
					foreach line $otherlines {
						lappend outlist($jj) $line
						incr jj
						if {$jj >= $fstlst_cnt} {
							set jj 0
						}
					}
				}
				set n 0
				set OK 1

				wm title .blocker "PLEASE WAIT : OPENING OUTPUT FILES"
				while {$n < $fstlst_cnt} {
					set ofnam [lindex $ofnams $n]
					if [catch {open $ofnam "w"} zit] {
						Inf "Cannot open file $ofnam : $zit"
						set OK 0
						break
					}
					foreach line $outlist($n) {
						puts $zit $line
					}
					close $zit
					FileToWkspace $ofnam 0 0 0 0 1
					incr n
				}
				if {!$OK} {
					set msg "Files\n"
					while {$n < $fstlst_cnt} {
						append msg "[lindex ofnams $n]\n"
						incr n
					}
					append msg "have not been created"
					Inf $msg
					UnBlock
					continue
				}
				UnBlock
				Inf "Files are on the workspace"
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc IsExcludedWord {word} {
	global excluded_words
	if {[lsearch $excluded_words $word] < 0} {
		return 0
	} 
	return 1
}

proc IncrSybcnt {down} {
	global sybcntval
	set forceit 0
	switch -- $down {
		1 {
			if {$sybcntval > 1} {
				incr sybcntval -1
				set forceit 1
			}
		}
		0 {
			if {$sybcntval < 20} {
				incr sybcntval
				set forceit 1
			}
		}
	}
	if {$forceit} {
		ForceVal .sybcnt.1.e $sybcntval
	}
}

#--- Mark lines with numbers : extract marked lines into different outfiles (one for each number used)

proc SelectCategorisedTexts {} {
	global chlist wl evv pa catsortnam pr_catsort catsort_disp catsort_changefrom catsort_changeto

	if {[info exists chlist] && ([llength $chlist] == 1)}  {
		set fnam $chlist
	} else {
		set i [$wl curselection]
		if {[info exists i] && ([llength $i] == 1) && ($i != -1)}  {
			set fnam [$wl get $i]
		}
	}
	if {[info exists fnam]} {
		if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
			unset fnam
		}
	}
	if {![info exists fnam]} {
		Inf "Select a textfile list of texts"
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot open file $fnam to read: $zit"
		return
	}
	set linecnt 0
	set OK 1
	while {[gets $zit line] >= 0} {
		incr linecnt
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match ";" [string index $line 0 ]]} {
			continue
		}
		if {[regexp {[^A-Za-z_\-\ \,]} $line]} {		;# Alphabetic,underscore,hyphen,space, comma
			Inf "Line $linecnt\n$line\ncontains invalid character(s) : (must be alphabetic, hyphen , underscore or space)"
			set OK 0
			break
		}
		lappend lines $line

	}
	close $zit
	if {!$OK} {
		return
	}
	if {![info exists lines] || ([llength $lines] <= 0)} {
		Inf "No data found in file $fnam"
		return
	}
	set f .catsort
	if [Dlg_Create $f "CATEGORISE LINES AND EXTRACT TO FILES" "set pr_catsort 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.f -text "Keep Filename" -command {set pr_catsort 2} -width 13 -highlightbackground [option get . background {}]
		label $f.0.ll -text "Categories 1 to 9 only" -fg $evv(SPECIAL)
		button $f.0.s -text "Extract Lines" -command {set pr_catsort 1} -width 13 -highlightbackground [option get . background {}]
		button $f.0.q -text "Abandon" -command {set pr_catsort 0} -width 13 -highlightbackground [option get . background {}]
		pack $f.0.f $f.0.s $f.0.ll -side left -padx 2
		pack $f.0.q -side right 
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Output filename "
		entry $f.1.e -textvariable catsortnam -width 48
		set catsortnam ""
		pack $f.1.ll $f.1.e -side right 
		pack $f.1 -side top
		frame $f.1a
		label $f.1a.sh -text "Show lines marked by " 
		radiobutton $f.1a.1 -text "1" -variable catsort_disp -value 1 -command {ShowCatsort 1}
		radiobutton $f.1a.2 -text "2" -variable catsort_disp -value 2 -command {ShowCatsort 2}
		radiobutton $f.1a.3 -text "3" -variable catsort_disp -value 3 -command {ShowCatsort 3}
		radiobutton $f.1a.4 -text "4" -variable catsort_disp -value 4 -command {ShowCatsort 4}
		radiobutton $f.1a.5 -text "5" -variable catsort_disp -value 5 -command {ShowCatsort 5}
		radiobutton $f.1a.6 -text "6" -variable catsort_disp -value 6 -command {ShowCatsort 6}
		radiobutton $f.1a.7 -text "7" -variable catsort_disp -value 7 -command {ShowCatsort 7}
		radiobutton $f.1a.8 -text "8" -variable catsort_disp -value 8 -command {ShowCatsort 8}
		radiobutton $f.1a.9 -text "9" -variable catsort_disp -value 9 -command {ShowCatsort 9}
		label $f.1a.00 -text "Clear Selection "
		radiobutton $f.1a.0 -variable catsort_disp -value 0 -command {ShowCatsort 0}
		pack $f.1a.sh $f.1a.1 $f.1a.2 $f.1a.3 $f.1a.4 $f.1a.5 $f.1a.6 $f.1a.7 $f.1a.8 $f.1a.9 $f.1a.00 $f.1a.0 -side left
		pack $f.1a -side top
		frame $f.1b
		label $f.1b.ch -text "Change marks numbered " 
		entry $f.1b.0 -textvariable catsort_changefrom -width 3 -state readonly
		label $f.1b.to -text "to number " 
		entry $f.1b.1 -textvariable catsort_changeto -width 3 -state readonly
		button $f.1b.b -text "Do Change" -command ChangeCategoryNumber -highlightbackground [option get . background {}]
		label $f.1b.dum -text "      "
		pack $f.1b.ch $f.1b.0 $f.1b.to $f.1b.1 $f.1b.1 $f.1b.dum $f.1b.b -side left
		pack $f.1b -side top
		label $f.1bb -text "Up/Down keys for \"from\" val : Left/Right for \"to\" val" -fg $evv(SPECIAL)
		pack $f.1bb -side top
		frame $f.1cc
		label $f.1cc.ch -text "Number all remaining lines with next available number" -width 53
		button $f.1cc.b -text "Number Reset" -command RemainCategoryNumbers -highlightbackground [option get . background {}]
		pack $f.1cc.ch $f.1cc.b -side left -pady 8 
		pack $f.1cc -side top
		frame $f.1c
		label $f.1c.ch -text "Force Marking Numbers To Be Contiguous from 1 " 
		button $f.1c.b -text "Contiguate" -command ContiguateCategoryNumbers -highlightbackground [option get . background {}]
		pack $f.1c.ch $f.1c.b -side left -pady 8 
		pack $f.1c -side top
		frame $f.1d -bg black
		pack $f.1d -side top -fill x -expand true -pady 8
		frame $f.2
		label $f.2.tit -text "Select Line : Mark with number (range = 1-9) : Unmark with \"0\"" -fg $evv(SPECIAL)
		label $f.2.tit2 -text "Use Contiguous Numbers, starting at \"1\"" -fg $evv(SPECIAL)
		Scrolled_Listbox $f.2.ll -width 60 -height 32 -selectmode multiple
		pack $f.2.tit $f.2.tit2 $f.2.ll -side top -pady 2
		pack $f.2 -side top
		wm resizable $f 0 0
	}
	bind $f <Key-0> {}
	bind $f <Key-1> {}
	bind $f <Key-2> {}
	bind $f <Key-3> {}
	bind $f <Key-4> {}
	bind $f <Key-5> {}
	bind $f <Key-6> {}
	bind $f <Key-7> {}
	bind $f <Key-8> {}
	bind $f <Key-9> {}
	bind $f <Up>	{}
	bind $f <Down>	{}
	bind $f <Left>	{}
	bind $f <Right>	{}
	.catsort.0.f config -text "Keep Filename" -bd 2 -state normal -command {set pr_catsort 2} -width 13
	.catsort.0.s config -text "" -bd 0 -command {} -state disabled -background [option get . background {}]
	.catsort.1.e config -bd 2 -state normal
	set catsortnam [file rootname [file tail $fnam]]

	.catsort.2.ll.list delete 0 end
	foreach line $lines {
		.catsort.2.ll.list insert end $line
	}
	set pr_catsort 0
	set catsort_disp -1
	set catsort_changefrom ""
	set catsort_changeto ""
	ForceVal .catsort.1b.0 $catsort_changefrom
	ForceVal .catsort.1b.1 $catsort_changeto
	.catsort.1b.ch config -text "" 
	.catsort.1b.0  config -bd 0 -state disabled -background [option get . background {}]
	.catsort.1b.to config -text "" 
	.catsort.1b.1  config -bd 0 -state disabled -background [option get . background {}]
	.catsort.1bb  config -text ""
	.catsort.1cc.ch config -text "" 
	.catsort.1cc.b config -text "" -bd 0 -command {} -state disabled -background [option get . background {}]
	.catsort.1b.b  config -bd 0 -text "" -command {} -state disabled -background [option get . background {}]
	.catsort.1c.ch config -text "" 
	.catsort.1c.b  config -bd 0 -text "" -command {} -state disabled -background [option get . background {}]
	bind $f <Return> {set pr_catsort 2}
	bind $f <Escape> {set pr_catsort 0}
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_catsort $f.1.e
	while {!$finished} {
		tkwait variable pr_catsort
		switch -- $pr_catsort {
			0 {
				set finished 1
			}
			1 {

			;#	SEARCH FOR CATEGORISED ITEMS

				catch {unset nulines}
				set kmax 0
				set kset {}
				foreach line [.catsort.2.ll.list get 0 end] {
					set k [string index $line 0]
					if {[regexp {^[1-9]+$} $k]} {
						if {[lsearch $kset $k] < 0} {
							lappend kset $k
						}
						if {$k > $kmax} {
							set kmax $k
						}							
						set nuline [string range $line 1 end]
						lappend nulines($k) $nuline
					}
				}
				if {$kmax == 0} {
					Inf "No categorised items to extract"
					continue
				}
				set kset [lsort -integer $kset]
				set j 1
				set OK 1
				foreach item $kset {
					if {$item != $j} {
						if {$j == 1} {
							Inf "Marking numbers do not start at \"1\" : numbers used = $kset"
						} else {
							Inf "Marking numbers are not contiguous at \"$lastitem  $item\" : numbers used = $kset"
						}
						set OK 0
						break
					}
					set lastitem $item
					incr j
				}
				if {!$OK} {
					continue
				}
				set j 0
				set k 1
				set oofnams {}
				while {$j < $kmax} {
					set ofnam [lindex $ofnams $j]
					if [catch {open $ofnam "w"} zit] {
						Inf "Cannot open file $ofnam to write : $zit"
						continue
					}
					foreach line $nulines($k) {
						puts $zit $line
					}
					close $zit
					lappend oofnams $ofnam
					incr j
					incr k
				}
				if {[llength $oofnams] <= 0} {
					Inf "No output files written"
					continue
				}
				set ofnams [ReverseList $oofnams]
				foreach ofnam $ofnams {
					FileToWkspace $ofnam 0 0 0 0 1
				}
				Inf "Files are on the workspace"
				set finished 1
			}
			2 {
				if {![ValidCDPRootname $catsortnam]} {
					continue
				}
				set basofnam [string tolower $catsortnam]
				set OK 1
				catch {unset ofnams}
				set k 1
				while {$k <= 9} {
					catch {unset nulines($k)}
					set ofnam $basofnam
					append ofnam "_" $k $evv(TEXT_EXT)
					if {[file exists $ofnam]} {
						Inf "File $ofnam already exists : please delete it (and related files), or choose a different name"
						set OK 0
						break
					}
					lappend ofnams $ofnam
					incr k
				}
				if {!$OK} {
					continue
				}
				.catsort.0.f config -text "" -bd 0 -command {} -state disabled -background [option get . background {}]
				.catsort.0.s config -text "Extract Lines" -bd 2 -command {set pr_catsort 1} -state normal
				.catsort.1.e config -bd 0 -state disabled
				.catsort.1b.b config -text "Do Change" -command ChangeCategoryNumber -state normal -bd 2
				.catsort.1b.ch config -text "Change marks numbered " 
				.catsort.1b.0  config -bd 2 -state readonly
				.catsort.1b.to config -text "to number " 
				.catsort.1b.1  config -bd 2 -state readonly
				.catsort.1bb  config -text "Up/Down keys for \"from\" val : Left/Right for \"to\" val" -fg $evv(SPECIAL)
				.catsort.1b.b  config -bd 2 -state normal -text "Do Change" -command ChangeCategoryNumber
				.catsort.1cc.ch config -text "Number all remaining lines with next available number" 
				.catsort.1cc.b config -text "Number Reset" -command RemainCategoryNumbers -bd 2 -state normal
				.catsort.1c.ch config -text "Force Marking Numbers To Be Contiguous from 1 " 
				.catsort.1c.b  config -bd 2 -state normal -text "Contiguate" -command ContiguateCategoryNumbers
				set catsort_changefrom "1"
				set catsort_changeto "2"
				ForceVal .catsort.1b.0 $catsort_changefrom
				ForceVal .catsort.1b.1 $catsort_changeto
				bind $f <Key-0> {CatUncat 0}
				bind $f <Key-1> {CatUncat 1}
				bind $f <Key-2> {CatUncat 2}
				bind $f <Key-3> {CatUncat 3}
				bind $f <Key-4> {CatUncat 4}
				bind $f <Key-5> {CatUncat 5}
				bind $f <Key-6> {CatUncat 6}
				bind $f <Key-7> {CatUncat 7}
				bind $f <Key-8> {CatUncat 8}
				bind $f <Key-9> {CatUncat 9}
				bind $f <Up>	{IncrCatsort from 0}
				bind $f <Down>	{IncrCatsort from 1}
				bind $f <Left>	{IncrCatsort to 1}
				bind $f <Right>	{IncrCatsort to 0}
				bind $f <Return> {}		
				bind $f <Return> {set pr_catsort 1}
				focus .catsort.2.ll.list
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc CatUncat {n} {
	set ilist [.catsort.2.ll.list curselection]
	if {([llength $ilist] <= 0) || (([llength $ilist] == 1) && ($ilist < 0))} {
		Inf "No lines selected"
		return
	}
	foreach i $ilist {
		set txt [.catsort.2.ll.list get $i]
		set k [string index $txt 0]
		if {$n == 0} {
			if {[regexp {^[1-9]+$} $k]} {
				set txt [string range $txt 2 end]
				.catsort.2.ll.list delete $i
				.catsort.2.ll.list insert $i $txt
			}
		} else {
			if {[regexp {^[1-9]+$} $k]} {
				set txt [string range $txt 2 end]
			}
			set nutxt $n
			append nutxt " " $txt
			.catsort.2.ll.list delete $i
			.catsort.2.ll.list insert $i $nutxt
		}
	}
}

proc ShowCatsort {n} {
	global catsort_disp
	.catsort.2.ll.list selection clear 0 end
	if {$n == 0}  {
		set catsort_disp -1
		return
	}
	set j 0
	foreach txt [.catsort.2.ll.list get 0 end] {
		set k [string index $txt 0]
		if {$k == $n} {
			.catsort.2.ll.list selection set $j
		}
		incr j
	}
	set catsort_disp -1
}

proc IncrCatsort {fromto down} {
	global catsort_changefrom catsort_changeto
	switch -- $fromto {
		"from" {
			if {$down} {
				if {$catsort_changefrom > 1} {
					incr catsort_changefrom -1
				}
			} else {
				if {$catsort_changefrom < 9} {
					incr catsort_changefrom
				}
			}
		}
		"to" {
			if {$down} {
				if {$catsort_changeto > 1} {
					incr catsort_changeto -1
				}
			} else {
				if {$catsort_changeto < 9} {
					incr catsort_changeto
				}
			}
		}
	}
}

proc ChangeCategoryNumber {} {
	global catsort_changefrom catsort_changeto
	if {$catsort_changefrom == $catsort_changeto} {
		Inf "Values $catsort_changefrom and catsort_changeto are not dirrerent"
		return
	}
	set j 0
	foreach line [.catsort.2.ll.list get 0 end] {
		set k [string index $line 0]
		if {$k == $catsort_changefrom} {
			set nuline $catsort_changeto
			append nuline " " [string range $line 2 end]
			.catsort.2.ll.list delete $j
			.catsort.2.ll.list insert $j $nuline
		}
		incr j
	}
}

proc ContiguateCategoryNumbers {} {
	set kset {}
	foreach line [.catsort.2.ll.list get 0 end] {
		set k [string index $line 0]
		if {[regexp {^[1-9]+$} $k]} {
			set kno $k
			set n 1
			while {[regexp {^[0-9]+$} [string index $line $n]]} {
				append kno [string index $line $n]
				incr n
			}
			if {[lsearch $kset $kno] < 0} {
				lappend kset $kno
			}
		}
	}
	set kset [lsort -integer $kset]
	set j 1
	set recat 0
	foreach item $kset {
		if {$item != $j} {
			set recat 1
			break
		}
		incr j
	}
	if {!$recat} {
		Inf "Category numbers are already contiguous"
		return
	}
	set n 0
	foreach line [.catsort.2.ll.list get 0 end] {
		set k [string index $line 0]
		if {[regexp {^[1-9]+$} $k]} {
			set kno $k
			set m 1
			while {[regexp {^[0-9]+$} [string index $line $m]]} {
				append kno [string index $line $m]
				incr m
			}
			set j [lsearch $kset $kno]				;#	Find index numbering-number in set-of-ditto (kset)
			incr j									;#	Using 1 more than that index as new numbering number		
			set nuline $j
			incr m
			append nuline " " [string range $line $m end]			
			.catsort.2.ll.list delete $n
			.catsort.2.ll.list insert $n $nuline
		}
		incr n
	}
}

proc RemainCategoryNumbers {} {
	set kset {}
	foreach line [.catsort.2.ll.list get 0 end] {
		set k [string index $line 0]
		if {[regexp {^[1-9]+$} $k]} {
			set kno $k
			set m 1
			while {[regexp {^[0-9]+$} [string index $line $m]]} {
				append kno [string index $line $m]
				incr m
			}
			if {[lsearch $kset $kno] < 0} {
				lappend kset $kno
			}
		}
	}
	if {[llength $kset] >= 9} {
		Inf "Too many categories (max 9) : cannot proceed"
		return
	}
	set kset [lsort -integer $kset]
	set j [lindex $kset end]
	incr j
	set n 0
	foreach line [.catsort.2.ll.list get 0 end] {
		set k [string index $line 0]
		if {![regexp {^[1-9]+$} $k]} {
			set nuline $j
			append nuline " " $line
			.catsort.2.ll.list delete $n
			.catsort.2.ll.list insert $n $nuline
		}
		incr n
	}
}

#--- Specify order of texts

proc OrderTexts {prenumbered} {
	global chlist wl evv pa ordersort pr_ordersort wstk

	set ordersort(prenumbered) 0
	if {$prenumbered} {
		set ordersort(prenumbered) 1
	}
	if {[info exists chlist] && ([llength $chlist] == 1)}  {
		set fnam $chlist
	} else {
		set i [$wl curselection]
		if {[info exists i] && ([llength $i] == 1) && ($i != -1)}  {
			set fnam [$wl get $i]
		}
	}
	if {[info exists fnam]} {
		if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
			unset fnam
		}
	}
	if {![info exists fnam]} {
		Inf "Select a textfile list of texts"
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot open file $fnam to read: $zit"
		return
	}
	set linecnt 0
	set OK 1
	while {[gets $zit line] >= 0} {
		incr linecnt
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match ";" [string index $line 0 ]]} {
			continue
		}
		if {$ordersort(prenumbered)} {
			if {[regexp {[^A-Za-z0-9_\-\ ]} $line]} {		;# Alphabetic,underscore,hyphen,space, and numbering
				Inf "Line $linecnt\n$line\ncontains invalid character(s) : (must be alphanumeric, hyphen , underscore or space)"
				set OK 0
				break
			}
		} else {
			if {[regexp {[^A-Za-z_\-\ ]} $line]} {		;# Alphabetic,underscore,hyphen,space
				Inf "Line $linecnt\n$line\ncontains invalid character(s) : (must be alphabetic, hyphen , underscore or space)"
				set OK 0
				break
			}
		}
		lappend lines $line

	}
	close $zit
	if {!$OK} {
		return
	}
	if {![info exists lines] || ([llength $lines] <= 0)} {
		Inf "No data found in file $fnam"
		return
	}
	set f .ordersort
	if [Dlg_Create $f "SPECIFY ORDERING OF LINES AND REORDER" "set pr_ordersort 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.f -text "Enter Filename" -command {set pr_ordersort 2} -width 26 -highlightbackground [option get . background {}]
		button $f.0.s -text "Extract In Specified Order" -command {set pr_ordersort 1} -width 26 -highlightbackground [option get . background {}]
		checkbutton $f.0.ch -text "retain numbering" -variable ordersort(retain)
		set ordersort(retain) 0
		button $f.0.q -text "Abandon" -command {set pr_ordersort 0} -width 8 -highlightbackground [option get . background {}]
		pack $f.0.f $f.0.s $f.0.ch -side left -padx 2
		pack $f.0.q -side right 
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Output filename "
		entry $f.1.e -textvariable ordersort(nam) -width 48
		set ordersort(nam) ""
		pack $f.1.ll $f.1.e -side right 
		pack $f.1 -side top -pady 4
		frame $f.1a
		button $f.1a.sh -text "Show unmarked lines"  -command {ShowUnsorted} -width 19 -highlightbackground [option get . background {}]
		button $f.1a.cc -text "Clear highlighting"  -command {.ordersort.2.ll.list selection clear 0 end} -width 19 -highlightbackground [option get . background {}]
		pack $f.1a.sh -side left
		pack $f.1a.cc -side right
		pack $f.1a -side top -pady 4 -fill x -expand true
		frame $f.1b
		label $f.1b.ch -text "Incr marks >= mark on this line : " 
		button $f.1b.b -text "Do Change" -command ChangeOrderNumber -highlightbackground [option get . background {}]
		label $f.1b.gg -text "  except this line" 
		checkbutton $f.1b.cx -variable ordersort(except)
		pack $f.1b.ch $f.1b.gg $f.1b.cx -side left
		pack $f.1b.b -side right
		pack $f.1b -side top -pady 4 -fill x -expand true
		frame $f.1c
		button $f.1c.cln -text "Clear All Numbering" -command ClearAllSortNumbers -highlightbackground [option get . background {}]
		label $f.1c.ch -text "Show lines having same numbering " 
		button $f.1c.b1 -text "Show" -command "SameSortingNumbers 0" -highlightbackground [option get . background {}]
		button $f.1c.b2 -text "Next" -command "SameSortingNumbers 1" -highlightbackground [option get . background {}]
		pack $f.1c.cln  -side left
		pack $f.1c.b2 $f.1c.b1 $f.1c.ch -side right -padx 2 
		pack $f.1c -side top -pady 4 -fill x -expand true
		frame $f.1d
		label $f.1d.ch -text "Force Numbering To Be Contiguous from 1 " 
		button $f.1d.b -text "Contiguate" -command ContiguateSortingNumbers -highlightbackground [option get . background {}]
		pack $f.1d.ch $f.1d.b -side left -padx 2 
		pack $f.1d -side top -pady 8
		frame $f.1e -bg black
		pack $f.1e -side top -fill x -expand true -pady 8
		frame $f.2
		label $f.2.tit -text "Select Line : Mark with numbers : Unmark with \"x\"" -fg $evv(SPECIAL)
		label $f.2.tit2 -text "Use Different Numbers, for any numbered lines" -fg $evv(SPECIAL)
		Scrolled_Listbox $f.2.ll -width 60 -height 32 -selectmode single
		pack $f.2.tit $f.2.tit2 $f.2.ll -side top -pady 2
		pack $f.2 -side top -pady 4
		wm resizable $f 0 0
		bind $f <Return> {set pr_ordersort 1}
		bind $f <Escape> {set pr_ordersort 0}
	}
	bind $f <Key-x> {}
	bind $f <Key-X> {}
	bind $f <Key-0> {}
	bind $f <Key-1> {}
	bind $f <Key-2> {}
	bind $f <Key-3> {}
	bind $f <Key-4> {}
	bind $f <Key-5> {}
	bind $f <Key-6> {}
	bind $f <Key-7> {}
	bind $f <Key-8> {}
	bind $f <Key-9> {}
	.ordersort.1.ll config -text "Output filename "
	.ordersort.1.e config -state normal -bd 2
	.ordersort.0.s config -text "" -bd 0 -command {} -width 26
	.ordersort.0.f config -text "Enter Filename" -bd 2 -command {set pr_ordersort 2}

	set ordersort(except) 1
	set ordersort(nam) [file rootname [file tail $fnam]]
	.ordersort.2.ll.list delete 0 end
	foreach line $lines {
		.ordersort.2.ll.list insert end $line
	}
	set pr_ordersort 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_ordersort
	focus $f.1.e
	while {!$finished} {
		tkwait variable pr_ordersort
		switch -- $pr_ordersort {
			0 {
				set finished 1
			}
			1 {

			;#	SORT ITEMS

				catch {unset nulines}
				set OK 1
				set kset {}
				set j 0
				set klen [.ordersort.2.ll.list index end]
				catch {unset numbered_lines}
				while {$j < $klen} {
					set line [.ordersort.2.ll.list get $j]				
					set k [string index $line 0]
					if {[regexp {^[1-9]+$} $k]} {
						set kno $k
					} else {
						incr j
						continue
					}
					set len [string length $line]
					set n 1
					while {$n < $len} {
						set k [string index $line $n]
						if {[regexp {^[0-9]+$} $k]} {
							append kno $k
						} else {
							break
						}
						incr n
					}
					if {[lsearch $kset $kno] >= 0} {
						Inf "The numbering $kno is used more than once"
						set OK 0
						break
					}
					incr n
					if {!$ordersort(retain)} {
						set line [string range $line $n end]
					}
					lappend kset $kno
					lappend numbered_lines [list $j $kno $line]

					incr j
				}
				if {!$OK} {
					continue
				}
				if {[llength $kset] <= 0} {
					Inf "No numbered items to order"
					continue
				}
				set kset [lsort -integer $kset]
				set nn_len [llength $numbered_lines]
				catch {unset nulines}
				foreach k $kset {
					set j 0
					while {$j < $nn_len} {
						set numbered_line [lindex $numbered_lines $j]
						set numbering [lindex $numbered_line 1]
						if {$k == $numbering} {
							lappend nulines [lindex $numbered_line 2]
							set numbered_lines [lreplace $numbered_lines $j $j]
							incr j -1
							incr nn_len -1
							break
						}	
						incr j
					}
				}
				if {![info exists nulines]} {
					Inf "No numbered lines found"
					continue
				}
				if [catch {open $ofnam "w"} zit] {
					Inf "Cannot open file $ofnam to write : $zit"
					continue
				}
				foreach line $nulines {
					puts $zit $line
				}
				close $zit
				FileToWkspace $ofnam 0 0 0 0 1
				Inf "File is on the workspace"
				set finished 1
			}
			2 {
				set ofnam [string tolower $ordersort(nam)]
				if {[string length $ofnam] <= 0} {
					Inf "No output filename entered"
					continue
				}
				if {![ValidCDPRootname $ofnam]} {
					continue
				}
				append ofnam $evv(TEXT_EXT)
				if {[string match $fnam $ofnam]} {
					Inf "You cannot use the input filename as the output filename"
					continue
				}
				if {[file exists $ofnam]} {
					Inf "File $ofnam already exists : please delete it, or choose a different name"
					continue
				}
				set ordersort(nam) $ofnam
				.ordersort.1.e config -state disabled -bd 0 -bg [option get . background {}] -fg [option get . foreground {}]
				.ordersort.0.f config -text "" -bd 0 -command {}
				bind .ordersort <Key-x> {SortUnsort x}
				bind .ordersort <Key-X> {SortUnsort x}
				bind .ordersort <Key-0> {SortUnsort 0}
				bind .ordersort <Key-1> {SortUnsort 1}
				bind .ordersort <Key-2> {SortUnsort 2}
				bind .ordersort <Key-3> {SortUnsort 3}
				bind .ordersort <Key-4> {SortUnsort 4}
				bind .ordersort <Key-5> {SortUnsort 5}
				bind .ordersort <Key-6> {SortUnsort 6}
				bind .ordersort <Key-7> {SortUnsort 7}
				bind .ordersort <Key-8> {SortUnsort 8}
				bind .ordersort <Key-9> {SortUnsort 9}
				.ordersort.0.s config -text "Extract In Specified Order" -bd 2 -command {set pr_ordersort 1} -width 26
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc ContiguateSortingNumbers {} {
	set kset {}
	set j 0
	foreach line [.ordersort.2.ll.list get 0 end] {
		set k [string index $line 0]
		if {[regexp {^[1-9]+$} $k]} {
			set kno $k
		} else {
			incr j
			continue
		}
		set n 1
		set len [string length $line]
		while {$n < $len} {
			set k [string index $line $n]
			if {[regexp {^[0-9]+$} $k]} {
				append kno $k
			} else {
				break
			}
			incr n
		}
		if {[lsearch $kset $kno] < 0} {
			lappend kset $kno
		}
		lappend numbered_lines [list $j $kno $line]
		incr j
	}
	if {![info exists numbered_lines]} {
		Inf "No lines have yet been numbered"
		return
	}
	set kset [lsort -integer $kset]
	set j 1
	set do_renumber 0
	foreach item $kset {
		if {$item != $j} {
			set do_renumber 1
			break
		}
		incr j
	}
	if {!$do_renumber} {
		Inf "Sorting numbers are already contiguous"
		return
	}
	set n 0
	foreach numbered_line $numbered_lines {
		set lineno [lindex $numbered_line 0]
		set numbering [lindex $numbered_line 1]
		set line [lindex $numbered_line 2]
		set nulineno [lsearch $kset $numbering]
		incr nulineno
		set len [string length $line]
		set jj 0
		while {$jj < $len} {
			set k [string index $line $jj]
			if {[regexp {^[a-zA-Z]+$} $k]} {
				set nuline $nulineno
				append nuline " " [string range $line $jj end]
				.ordersort.2.ll.list delete $lineno
				.ordersort.2.ll.list insert $lineno $nuline
				break
			}
			incr jj
		}
	}
}

proc ChangeOrderNumber {} {
	global ordersort
	set j 0
	set i [.ordersort.2.ll.list  curselection]
	if {![info exists i] || ($i < 0)} {
		Inf "No line selected"
		return
	}
	set line [.ordersort.2.ll.list get $i]
	set k [string index $line 0]
	if {[regexp {^[1-9]+$} $k]} {
		set kno $k
	} else {
		Inf "Selected line is not a numbered line"
		return
	}
	set len [string length $line]
	set n 1
	while {$n < $len} {
		set k [string index $line $n]
		if {[regexp {^[0-9]+$} $k]} {
			append kno $k
		} else {
			break
		}
		incr n
	}
	set ordersort_changefrom $kno
	foreach line [.ordersort.2.ll.list get 0 end] {
		set k [string index $line 0]
		if {[regexp {^[1-9]+$} $k]} {
			set kno $k
		} else {
			incr j
			continue
		}
		set len [string length $line]
		set n 1
		while {$n < $len} {
			set k [string index $line $n]
			if {[regexp {^[0-9]+$} $k]} {
				append kno $k
			} else {
				break
			}
			incr n
		}
		if {$kno >= $ordersort_changefrom} {
			lappend numbered_lines [list $j $kno $line]
		}
		incr j
	}
	foreach numbered_line $numbered_lines {
		set lineno [lindex $numbered_line 0]
		if {$ordersort(except) && ($lineno == $i)} {
			continue
		}
		set numbering [lindex $numbered_line 1]
		set line [lindex $numbered_line 2]
		set nulineno $numbering
		incr nulineno
		set len [string length $line]
		set jj 0
		while {$jj < $len} {
			set k [string index $line $jj]
			if {[regexp {^[a-zA-Z]+$} $k]} {
				set nuline $nulineno
				append nuline " " [string range $line $jj end]
				.ordersort.2.ll.list delete $lineno
				.ordersort.2.ll.list insert $lineno $nuline
				break
			}
			incr jj
		}
	}
}

proc SortUnsort {n} {
	global sortsort_list
	set i [.ordersort.2.ll.list curselection]
	if {(![info exists i] || ($i < 0))} {
		Inf "No line selected"
		return
	}
	set line [.ordersort.2.ll.list get $i]
	if {$n == "x"} {
		set k [string index $line 0]
		if {![regexp {^[1-9]+$} $k]} {
			return
		}
		set len [string length $line]
		set nn 1
		while {$nn < $len} {
			set k [string index $line $nn]
			if {![regexp {^[0-9]+$} $k]} {
				break
			}
			incr nn
		}
		incr nn
		set nuline [string range $line $nn end]
		.ordersort.2.ll.list delete $i
		.ordersort.2.ll.list insert $i $nuline
	} else {
		set kno ""
		set len [string length $line]
		set nn 0
		while {$nn < $len} {
			set k [string index $line $nn]
			if {![regexp {^[0-9]+$} $k]} {
				break
			}
			incr nn
		}
		if {$nn == 0} {
			if {$n == 0} {
				Inf "Numberings cannot begin with zero"
				return
			}
			set nuline $n
			append nuline " " $line
		} else {
			set nuline [string range $line 0 [expr $nn - 1]]
			append nuline $n
			append nuline [string range $line $nn end]
		}
		.ordersort.2.ll.list delete $i
		.ordersort.2.ll.list insert $i $nuline
	}
	.ordersort.2.ll.list selection set $i
}

proc ShowUnsorted {} {
	set j 0
	foreach line [.ordersort.2.ll.list get 0 end] {
		set k [string index $line 0]
		if {![regexp {^[1-9]+$} $k]} {
			lappend selectlist $j
		}
		incr j
	}
	if {![info exists selectlist]} {
		Inf "All lines are numbered"
		return
	}
	.ordersort.2.ll.list selection clear 0 end	
	foreach i $selectlist {
		.ordersort.2.ll.list selection set $i
	}
}

proc SameSortingNumbers {next} {
	global sortgroups sortgroup_no
	if {$next == 0} {
		catch {unset sortgroups}
		set j 0
		foreach line [.ordersort.2.ll.list get 0 end] {
			set k [string index $line 0]
			if {[regexp {^[1-9]+$} $k]} {
				set kno $k
				set len [string length $line]
				set nn 1
				while {$nn < $len} {
					set k [string index $line $nn]
					if {[regexp {^[0-9]+$} $k]} {
						append kno $k
					} else {
						break
					}
					incr nn
				}
				lappend knos $kno
				set numbered_line [list $j $kno]
				lappend numbered_lines $numbered_line
			}
			incr j
		}
		if {![info exists numbered_lines]} {
			Inf "No numbered lines exist"
			return
		}
		if {[llength $numbered_lines] < 2} {
			return
		}
		set kno_groups {}
		set len [llength $knos]
		set len_less_one [expr $len - 1]
		set n 0
		while {$n < $len_less_one} {
			set kno_n [lindex $knos $n]
			set m $n
			incr m
			while {$m < $len} {
				set kno_m [lindex $knos $m]
				if {$kno_n == $kno_m} {
					if {[lsearch $kno_groups $kno_n] < 0} {
						lappend kno_groups $kno_n
					}
				}
				incr m
			}
			incr n
		}
		if {[llength $kno_groups] <= 0} {
			return
		}
		set kno_groups [lsort -integer $kno_groups]
		foreach kno_group $kno_groups {
			catch {unset sortgroup}
			foreach numbered_line $numbered_lines {
				set kno [lindex $numbered_line 1]
				if {$kno == $kno_group} {
					lappend sortgroup [lindex $numbered_line 0]
				}
			}
			if {[info exists sortgroup]} {
				lappend sortgroups $sortgroup
			}
		}
		if {![info exists sortgroups]} {
			return
		}
		set sortgroup_no 0
		.ordersort.2.ll.list selection clear 0 end
		foreach i [lindex $sortgroups $sortgroup_no] {
			.ordersort.2.ll.list selection set $i
		}
		incr sortgroup_no
		if {$sortgroup_no >= [llength $sortgroups]} {
			set sortgroup_no 0
		}
	} else {
		if {![info exists sortgroups]} {
			Inf "Problem !!"
			return
		}
		.ordersort.2.ll.list selection clear 0 end
		foreach i [lindex $sortgroups $sortgroup_no] {
			.ordersort.2.ll.list selection set $i
		}
		incr sortgroup_no
		if {$sortgroup_no >= [llength $sortgroups]} {
			set sortgroup_no 0
		}
	}
}

proc ClearAllSortNumbers {} {
	global wstk
	set msg "Are you sure you want to clear ~~all~~ numbering ??"
	set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg -default no]
	if {$choice == "no"} {
		return
	}
	set j 0
	foreach line [.ordersort.2.ll.list get 0 end] {
		set k [string index $line 0]
		if {[regexp {^[1-9]+$} $k]} {
			set len [string length $line]
			set nn 1
			while {$nn < $len} {
				set k [string index $line $nn]
				if {![regexp {^[0-9]+$} $k]} {
					break
				}
				incr nn
			}
			incr nn
			set line [string range $line $nn end]
			.ordersort.2.ll.list delete $j
			.ordersort.2.ll.list insert $j $line
		}
		incr j
	}
}

proc AssembleTexts {} {
	global chlist wl evv pa pr_txassmbl txassmblnam

	if {[info exists chlist] && ([llength $chlist] == 1)}  {
		set fnam $chlist
	} else {
		set i [$wl curselection]
		if {[info exists i] && ([llength $i] == 1) && ($i != -1)}  {
			set fnam [$wl get $i]
		}
	}
	if {[info exists fnam]} {
		if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
			unset fnam
		}
	}
	if {![info exists fnam]} {
		Inf "Select a textfile list of texts"
		return
	}
	if [catch {open $fnam "r"} zit] {
		Inf "Cannot open file $fnam to read: $zit"
		return
	}
	set linecnt 0
	set OK 1
	while {[gets $zit line] >= 0} {
		incr linecnt
		set line [string trim $line]
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0 ] ";"]} {
			continue
		}
		if {[regexp {[^A-Za-z_0-9\-\ \'\",\.\?\!]} $line]} {		;# Alphabetic,underscore,hyphen,space, comma, full-stop, quotemarks
			Inf "Line $linecnt\n$line\ncontains invalid character(s)\nmust be alphanumeric, hyphen, underscore, comma, full-stop, quotation marks,\"!\",\"?\" or space."
			set OK 0
			break
		}
		lappend lines [string tolower $line]
	}
	close $zit
	if {!$OK} {
		return
	}
	if {![info exists lines] || ([llength $lines] <= 0)} {
		Inf "No data found in file $fnam"
		return
	}
	set f .txassmbl
	if [Dlg_Create $f "MERGE TEXT-LINES TO CONTINUOUS TEXT" "set pr_txassmbl 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.s -text "Merge"   -command "set pr_txassmbl 1" -width 8 -highlightbackground [option get . background {}]
		button $f.0.q -text "Abandon" -command "set pr_txassmbl 0" -width 8 -highlightbackground [option get . background {}]
		pack $f.0.s -side left
		pack $f.0.q -side right 
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Output filename "
		entry $f.1.e -textvariable txassmblnam -width 48
		set txassmblnam ""
		pack $f.1.ll $f.1.e -side left
		pack $f.1 -side top -pady 4
		frame $f.2
		label $f.2.tit -text "Use \"#\" key to insert or remove paragraph breaks." -fg $evv(SPECIAL)
		label $f.2.tit2 -text "Use \".\" (full stop) key to insert or remove sentence ends." -fg $evv(SPECIAL)
		Scrolled_Listbox $f.2.ll -width 120 -height 64 -selectmode single
		pack $f.2.tit $f.2.tit2 $f.2.ll -side top -pady 2
		pack $f.2.ll -side left
		pack $f.2 -side top -pady 4
		wm resizable $f 0 0
		bind $f <Key-.> {AssemblyMark sentence}
		bind $f <Key-#> {AssemblyMark paragraph}
		bind $f <Return> {set pr_txassmbl 1}
		bind $f <Escape> {set pr_txassmbl 0}
	}
	$f.2.ll.list delete 0 end
	foreach line $lines {
		$f.2.ll.list insert end $line
	}
	set txassmblnam [file rootname $fnam]
	append txassmblnam "_assembled"
	set pr_txassmbl 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_txassmbl
	while {!$finished} {
		tkwait variable pr_txassmbl
		switch -- $pr_txassmbl {
			0 {
				set finished 1
			}
			1 {
				if {![ValidCDPRootname $txassmblnam]} {
					continue
				}
				set ofnam [string tolower $txassmblnam]
				append ofnam $evv(TEXT_EXT)
				if {[file exists $ofnam]} {
					Inf "File $ofnam already exists : please rename it, or choose a different name"
					continue
				}
				set nuline ""
				set new_sentence 0
				set new_paragraph 0
				set is_sentence_start 1
				set is_new_paragraph 1
				catch {unset nulines}
				foreach line [.txassmbl.2.ll.list get 0 end] {
					if {[string match [string index $line end] "\."]} {
						set new_sentence 1
					} elseif {[string match [string index $line end] "\#"]} {
						set new_sentence 1
						set new_paragraph 1
						set line [string range $line 0 [expr [string length $line] - 2]]
						append line "\."
					}
					set line [string trim $line]
					if {$is_sentence_start} {
						set k [string index $line 0]
						set k [string toupper $k]
						set xline $k 
						append xline [string range $line 1 end]
						set line $xline
						set is_sentence_start 0
					}
					set words [split $line]
					foreach word $words {
						set word [string trim $word]
						if {[string length $word] <= 0} {
							continue
						}
						if {$is_new_paragraph} {
							append nuline $word
							set is_new_paragraph 0
						} else {
							append nuline " " $word
						}
					}
					if {$new_paragraph} {
						lappend nulines $nuline
						lappend nulines ""
						set nuline ""
						set new_paragraph 0
						set is_new_paragraph 1
					}
					if {$new_sentence} {
						set is_sentence_start 1
						set new_sentence 0
					}
				}
				if {[string length $nuline] > 0} {
					lappend nulines $nuline
				}
				if {![info exists nulines]} {
					Inf "No output text generated"
					continue
				}
				if [catch {open $ofnam "w"} zit] {
					Inf "Cannot open file $ofnam to write: $zit"
					continue
				}
				foreach line $nulines {
					puts $zit $line
				}
				close $zit
				if {[FileToWkspace $ofnam 0 0 0 0 1] > 0} {
					Inf "File $ofnam is on the workspace"
				} else {
					Inf "File $ofnam has been created, but is not on the workspace yet"
				}
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc AssemblyMark {typ} {
	set i [.txassmbl.2.ll.list curselection]
	if {![info exists i] || ($i < 0)} {
		Inf "No line selected"
		return
	}
	set line [.txassmbl.2.ll.list get $i]
	set k [string index $line end]
	if {$typ == "paragraph"} {
		if {[regexp {\#} $k]} {
			set line [string range $line 0 [expr [string length $line] - 2]]
		} else {
			append line "\#"
		}
	} else {			;# sentence
		if {[regexp {\.} $k]} {
			set line [string range $line 0 [expr [string length $line] - 2]]
		} else {
			append line "\."
		}
	}
	.txassmbl.2.ll.list delete $i
	.txassmbl.2.ll.list insert $i $line
	.txassmbl.2.ll.list selection set $i
}


proc DoubleFilter {} {
	global chlist wl evv pa wstk pr_dblfilt dblfilt prg_dun prg_abortd simple_program_messages CDPidrun blist_change

	if {[info exists chlist] && ([llength $chlist] == 1)}  {
		set fnam $chlist
	} else {
		set i [$wl curselection]
		if {[info exists i] && ([llength $i] == 1) && ($i != -1)}  {
			set fnam [$wl get $i]
		}
	}
	if {[info exists fnam]} {
		if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
			unset fnam
		}
	}
	if {![info exists fnam]} {
		Inf "Select a soundfile"
		return
	}
	set dblfilt(nyq) [expr int(floor($pa($fnam,$evv(SRATE)) / 2))]

	set f .dblfilt
	if [Dlg_Create $f "RECURSIVELY FILTER A SOUND" "set pr_dblfilt 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.s -text "Run Filter" -command "set pr_dblfilt 1" -width 10 -highlightbackground [option get . background {}]
		button $f.0.q -text "Abandon"	 -command "set pr_dblfilt 0" -width 10 -highlightbackground [option get . background {}]
		pack $f.0.s -side left
		pack $f.0.q -side right 
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Filter Attenuation (Range : 0 to -96dB)"
		entry $f.1.e -textvariable dblfilt(atten) -width 8
		pack $f.1.e $f.1.ll -side left
		pack $f.1 -side top -pady 4 -fill x -expand true
		frame $f.2
		label $f.2.ll -text "Stopband ABOVE Passband = LOWpass : Stopband BELOW Passband = HIGHpass" -fg $evv(SPECIAL)
		pack $f.2.ll -side left
		pack $f.2 -side top -pady 4 -fill x -expand true
		frame $f.3
		label $f.3.ll -text "Passband (hz) (Range : 10 to 22050)"
		entry $f.3.e -textvariable dblfilt(pass) -width 8
		pack $f.3.e $f.3.ll -side left
		pack $f.3 -side top -pady 4 -fill x -expand true
		frame $f.4
		label $f.4.ll -text "Stopband (hz) (Range : 10 to 22050)"
		entry $f.4.e -textvariable dblfilt(stop) -width 8
		pack $f.4.e $f.4.ll -side left
		pack $f.4 -side top -pady 4 -fill x -expand true
		frame $f.5
		label $f.5.ll -text "ZERO Decaytail leaves sound to decay to zero level : other vals = decay-time in seconds" -fg $evv(SPECIAL)
		pack $f.5.ll -side left
		pack $f.5 -side top -pady 4 -fill x -expand true
		frame $f.6
		label $f.6.ll -text "Decaytail duration (secs) (Range : Zero or >0 to 20)"
		entry $f.6.e -textvariable dblfilt(decay) -width 8
		pack $f.6.e $f.6.ll -side left
		pack $f.6 -side top -pady 4 -fill x -expand true
		frame $f.7
		label $f.7.ll -text "Adjust input level (Range : 0.005 to 200)"
		entry $f.7.e -textvariable dblfilt(prescale) -width 8
		pack $f.7.e $f.7.ll -side left
		pack $f.7 -side top -pady 4 -fill x -expand true
		frame $f.8
		label $f.8.ll -text "Use Left/Right Arrows to change Number of filter passes" -fg $evv(SPECIAL)
		pack $f.8.ll -side left
		pack $f.8 -side top -pady 4 -fill x -expand true
		frame $f.9
		label $f.9.ll -text "Number of filter passes (Range : 2 to 8)"
		entry $f.9.e -textvariable dblfilt(cnt) -width 8 -state readonly
		pack $f.9.e $f.9.ll -side left
		pack $f.9 -side top -pady 4 -fill x -expand true
		frame $f.10
		label $f.10.ll -text "Output filename "
		entry $f.10.e -textvariable dblfilt(onam) -width 48
		pack $f.10.ll $f.10.e -side left
		pack $f.10 -side top -pady 4

		frame $f.11a
		label $f.11a.ll -text "PRESET FILTERS "
		radiobutton $f.11a.0 -variable dblfilt(typ) -text "Clear"  -value 0 -command "SetDblFilt"
		pack $f.11a.ll $f.11a.0 -side left -fill x -expand true
		frame $f.11b
		label $f.11b.hi -text "HIpass"
		radiobutton $f.11b.50 -variable dblfilt(typ) -text "80-50"  -value 50 -command "SetDblFilt"
		radiobutton $f.11b.80 -variable dblfilt(typ) -text "100-80"  -value 80 -command "SetDblFilt"
		radiobutton $f.11b.150 -variable dblfilt(typ) -text "200-150"  -value 150 -command "SetDblFilt"
		radiobutton $f.11b.600 -variable dblfilt(typ) -text "1000-600"  -value 600 -command "SetDblFilt"
		radiobutton $f.11b.800 -variable dblfilt(typ) -text "1000-800"  -value 800 -command "SetDblFilt"
		pack $f.11b.hi $f.11b.50 $f.11b.80 $f.11b.150 $f.11b.600 $f.11b.800 -side left
		frame $f.11c
		label $f.11c.lo -text "LOpass"
		radiobutton $f.11c.700 -variable dblfilt(typ) -text "700-500"  -value 500 -command "SetDblFilt"
		radiobutton $f.11c.1000 -variable dblfilt(typ) -text "1000-600"  -value 1000 -command "SetDblFilt"
		radiobutton $f.11c.1200 -variable dblfilt(typ) -text "3000-1200"  -value 1200 -command "SetDblFilt"
		radiobutton $f.11c.2500 -variable dblfilt(typ) -text "2500-2000"  -value 2500 -command "SetDblFilt"
		radiobutton $f.11c.3500 -variable dblfilt(typ) -text "3500-3000"  -value 3500 -command "SetDblFilt"
		radiobutton $f.11c.6000 -variable dblfilt(typ) -text "6000-5000"  -value 6000 -command "SetDblFilt"
		pack $f.11c.lo $f.11c.700 $f.11c.1000 $f.11c.1200 $f.11c.2500 $f.11c.3500 $f.11c.6000 -side left
		pack $f.11a $f.11b $f.11c  -side top -anchor w

		wm resizable $f 0 0
		bind $f.1.e <Down>	{focus .dblfilt.3.e}
		bind $f.3.e <Down>	{focus .dblfilt.4.e}
		bind $f.4.e <Down>	{focus .dblfilt.6.e}
		bind $f.6.e <Down>	{focus .dblfilt.7.e}
		bind $f.7.e <Down>	{focus .dblfilt.10.e}
		bind $f.10.e <Down>	{focus .dblfilt.1.e}
		bind $f.1.e <Up>	{focus .dblfilt.10.e}
		bind $f.3.e <Up>	{focus .dblfilt.1.e}
		bind $f.4.e <Up>	{focus .dblfilt.3.e}
		bind $f.6.e <Up>	{focus .dblfilt.4.e}
		bind $f.7.e <Up>	{focus .dblfilt.6.e}
		bind $f.10.e <Up>	{focus .dblfilt.7.e}
		bind $f <Left>	{IncrFilterPasses 1}
		bind $f <Right>	{IncrFilterPasses 0}
		bind $f <Return> {set pr_dblfilt 1}
		bind $f <Escape> {set pr_dblfilt 0}
	}
	$f.3.ll config -text "Passband (hz) (Range : 10 to $dblfilt(nyq))"
	$f.4.ll config -text "Stopband (hz) (Range : 10 to $dblfilt(nyq))"
	set dblfilt(typ) 0
	set dblfilt(atten) -96
	set dblfilt(decay) 0
	set dblfilt(prescale) 1
	if {[string length $dblfilt(cnt)] <= 0} {
		set dblfilt(cnt) 2
	}
	ForceVal .dblfilt.9.e $dblfilt(cnt)
	set dblfilt(onam) [file rootname [file tail $fnam]]
	append dblfilt(onam) "_f"
	ForceVal .dblfilt.10.e $dblfilt(onam)
	set pr_dblfilt 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_dblfilt $f.1.e
	while {!$finished} {
		tkwait variable pr_dblfilt
		switch -- $pr_dblfilt {
			1 {
				DeleteAllTemporaryFiles
				if {([string length $dblfilt(atten)] <= 0) || ![IsNumeric $dblfilt(atten)] || ($dblfilt(atten) < -96.0) || ($dblfilt(atten) > 0.0)} {
					Inf "Invalid value for filter attenuation : range -96 to 0 (dB)"
					continue
				}
				if {([string length $dblfilt(pass)] <= 0) || ![IsNumeric $dblfilt(pass)] || ($dblfilt(pass) < 10.0) || ($dblfilt(pass) > $dblfilt(nyq))} {
					Inf "Invalid value for passband frequency : range 10 to $dblfilt(nyq)"
					continue
				}
				if {([string length $dblfilt(stop)] <= 0) || ![IsNumeric $dblfilt(stop)] || ($dblfilt(stop) < 10.0) || ($dblfilt(stop) > $dblfilt(nyq))} {
					Inf "Invalid value for stopband frequency : range 10 to $dblfilt(nyq)"
					continue
				}
				if {([string length $dblfilt(decay)] <= 0) || ![IsNumeric $dblfilt(decay)] || ($dblfilt(decay) < 0.0) || ($dblfilt(decay) > 20)} {
					Inf "Invalid value for filter decay time : range 0 to 20"
					continue
				}
				if {([string length $dblfilt(prescale)] <= 0) || ![IsNumeric $dblfilt(prescale)] || ($dblfilt(prescale) < 0.005) || ($dblfilt(prescale) > 200)} {
					Inf "Invalid value for filter input level adjustment : range 0.005 to 200"
					continue
				}
				if {![ValidCDPRootname $dblfilt(onam)]} {
					continue
				}
				set ofnam [string tolower $dblfilt(onam)]
				append ofnam $evv(SNDFILE_EXT)
				if {[file exists $ofnam]} {
					set msg "File $ofnam already exists : overwrite it ??"
					set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg -default no]
					if {$choice == "no"} {
						Inf "Please rename file $ofnam on workspace, or choose a different name for the output here"
						continue
					} else {
						set blist_change 0
						if [DeleteFileFromSystem $ofnam 0 1] {
							DeleteFromSystemTidyUp $ofnam
						} else {
							Inf "Cannot delete file $ofnam"
							continue
						}
					}					
				}
				Block "FILTERING THE FILE"
				set n 1
				set OK 1
				set ifnam $fnam
				while {$n <= $dblfilt(cnt)} {
					catch {unset CDPidrun}
					set prg_dun 0
					set prg_abortd 0
					catch {unset simple_program_messages}
					wm title .blocker "PLEASE WAIT:        RUNNING FILTER PASS $n"
					set outfnam $evv(DFLT_OUTNAME)
					append outfnam $n $evv(SNDFILE_EXT)
					set cmd [file join $evv(CDPROGRAM_DIR) filter]
					lappend cmd lohi 1 $ifnam $outfnam $dblfilt(atten) $dblfilt(pass) $dblfilt(stop) -t$dblfilt(decay) -s$dblfilt(prescale)
					if [catch {open "|$cmd"} CDPidrun] {
						ErrShow "CANNOT RUN FILTER PASS $n : $CDPidrun"
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
						set msg "Failed to run filter pass $n"
						set msg [AddSimpleMessages $msg]
						ErrShow $msg
						set OK 0
						break
					}
					if {![file exists $outfnam]} {
						set msg "No output file from filter pass $n created"
						set msg [AddSimpleMessages $msg]
						ErrShow $msg
						set OK 0
						break
					}
					set ifnam $outfnam
					incr n
				}
				if {!$OK} {
					UnBlock
					continue
				}

				if [catch {file rename $outfnam $ofnam} zit] {
					Inf "Cannot rename the output file"
					continue
				}
				if {[FileToWkspace $ofnam 0 0 0 0 1] > 0} {
					Inf "File $ofnam is on the workspace"
				} else {
					Inf "File $ofnam created"
				}
				UnBlock
				set finished 1
			} 0 {
				set finished 1
			}
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc IncrFilterPasses {down} {
	global dblfilt

	if {$down} {
		if {$dblfilt(cnt) > 2} {
			incr dblfilt(cnt) -1
			ForceVal .dblfilt.9.e $dblfilt(cnt)
		}
	} else {
		if {$dblfilt(cnt) < 8} {
			incr dblfilt(cnt)
			ForceVal .dblfilt.9.e $dblfilt(cnt)
		}
	}
}
proc SetDblFilt {} {
	global dblfilt
	switch -- $dblfilt(typ) {
		0 {
				set dblfilt(typ) -1
				set dblfilt(pass) ""
				set dblfilt(stop) ""
		}
		50 {	;# HIpass	
				set dblfilt(pass) 80
				set dblfilt(stop) 50
		}
		80 {	
				set dblfilt(pass) 100
				set dblfilt(stop) 80
		}
		150 {	
				set dblfilt(pass) 200
				set dblfilt(stop) 150
		}
		600 {	
				set dblfilt(pass) 1000
				set dblfilt(stop) 600
		}
		800 {	
				set dblfilt(pass) 1000
				set dblfilt(stop) 800
		} 
		500 {	;# LOpass	
				set dblfilt(pass) 500
				set dblfilt(stop) 700
		}
		1000 {	
				set dblfilt(pass) 600
				set dblfilt(stop) 1000 
		}
		1200 {	
				set dblfilt(pass) 1200
				set dblfilt(stop) 3000
				
		}
		2500 {	
				set dblfilt(pass) 2000
				set dblfilt(stop) 2500
		}
		3500 {	
				set dblfilt(pass) 3000
				set dblfilt(stop) 3500
		}
		6000 {	
				set dblfilt(pass) 5000
				set dblfilt(stop) 6000
		}
	}
}

proc ChanPairExtract {} {
	global chlist wl evv pa wstk pr_chanexx chanexx prg_dun prg_abortd simple_program_messages CDPidrun

	if {[info exists chlist] && ([llength $chlist] == 1)}  {
		set fnam $chlist
	} else {
		set i [$wl curselection]
		if {[info exists i] && ([llength $i] == 1) && ($i != -1)}  {
			set fnam [$wl get $i]
		}
	}
	if {[info exists fnam]} {
		if {$pa($fnam,$evv(FTYP)) != $evv(SNDFILE)} {
			unset fnam
		}
		if {$pa($fnam,$evv(CHANS)) < 3} {
			unset fnam
		}
		if {![info exists fnam]} {
			Inf "Select a soundfile with more than 2 channels"
			return
		}
		if {$pa($fnam,$evv(CHANS)) > 8} {
			Inf "Process only runs with files of 8 channels or less"
			return
		}
	}
	set chanexx(chans) $pa($fnam,$evv(CHANS))

	set f .chanexx
	if [Dlg_Create $f "EXTRACT A PAIR OF CHANNELS" "set pr_chanexx 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.s -text "Extract" -command "set pr_chanexx 1" -width 8 -highlightbackground [option get . background {}]
		button $f.0.q -text "Quit" -command "set pr_chanexx 0" -width 8 -highlightbackground [option get . background {}]
		pack $f.0.s -side left
		pack $f.0.q -side right 
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		radiobutton $f.1.12 -variable chanexx(typ) -text "12"  -value 12 -command "CheckChanPair"
		radiobutton $f.1.13 -variable chanexx(typ) -text "13"  -value 13 -command "CheckChanPair"
		radiobutton $f.1.14 -variable chanexx(typ) -text "14"  -value 14 -command "CheckChanPair"
		radiobutton $f.1.15 -variable chanexx(typ) -text "15"  -value 15 -command "CheckChanPair"
		radiobutton $f.1.16 -variable chanexx(typ) -text "16"  -value 16 -command "CheckChanPair"
		radiobutton $f.1.17 -variable chanexx(typ) -text "17"  -value 17 -command "CheckChanPair"
		radiobutton $f.1.18 -variable chanexx(typ) -text "18"  -value 18 -command "CheckChanPair"
		frame $f.2
		radiobutton $f.2.21 -variable chanexx(typ) -text "21"  -value 21 -command "CheckChanPair"
		radiobutton $f.2.23 -variable chanexx(typ) -text "23"  -value 23 -command "CheckChanPair"
		radiobutton $f.2.24 -variable chanexx(typ) -text "24"  -value 24 -command "CheckChanPair"
		radiobutton $f.2.25 -variable chanexx(typ) -text "25"  -value 25 -command "CheckChanPair"
		radiobutton $f.2.26 -variable chanexx(typ) -text "26"  -value 26 -command "CheckChanPair"
		radiobutton $f.2.27 -variable chanexx(typ) -text "27"  -value 27 -command "CheckChanPair"
		radiobutton $f.2.28 -variable chanexx(typ) -text "28"  -value 28 -command "CheckChanPair"
		frame $f.3
		radiobutton $f.3.31 -variable chanexx(typ) -text "31"  -value 31 -command "CheckChanPair"
		radiobutton $f.3.32 -variable chanexx(typ) -text "32"  -value 32 -command "CheckChanPair"
		radiobutton $f.3.34 -variable chanexx(typ) -text "34"  -value 34 -command "CheckChanPair"
		radiobutton $f.3.35 -variable chanexx(typ) -text "35"  -value 35 -command "CheckChanPair"
		radiobutton $f.3.36 -variable chanexx(typ) -text "36"  -value 36 -command "CheckChanPair"
		radiobutton $f.3.37 -variable chanexx(typ) -text "37"  -value 37 -command "CheckChanPair"
		radiobutton $f.3.38 -variable chanexx(typ) -text "38"  -value 38 -command "CheckChanPair"
		frame $f.4
		radiobutton $f.4.41 -variable chanexx(typ) -text "41"  -value 41 -command "CheckChanPair"
		radiobutton $f.4.42 -variable chanexx(typ) -text "42"  -value 42 -command "CheckChanPair"
		radiobutton $f.4.43 -variable chanexx(typ) -text "43"  -value 43 -command "CheckChanPair"
		radiobutton $f.4.45 -variable chanexx(typ) -text "45"  -value 45 -command "CheckChanPair"
		radiobutton $f.4.46 -variable chanexx(typ) -text "46"  -value 46 -command "CheckChanPair"
		radiobutton $f.4.47 -variable chanexx(typ) -text "47"  -value 47 -command "CheckChanPair"
		radiobutton $f.4.48 -variable chanexx(typ) -text "48"  -value 48 -command "CheckChanPair"
		frame $f.5
		radiobutton $f.5.51 -variable chanexx(typ) -text "51"  -value 51 -command "CheckChanPair"
		radiobutton $f.5.52 -variable chanexx(typ) -text "52"  -value 52 -command "CheckChanPair"
		radiobutton $f.5.53 -variable chanexx(typ) -text "53"  -value 53 -command "CheckChanPair"
		radiobutton $f.5.54 -variable chanexx(typ) -text "54"  -value 54 -command "CheckChanPair"
		radiobutton $f.5.56 -variable chanexx(typ) -text "56"  -value 56 -command "CheckChanPair"
		radiobutton $f.5.57 -variable chanexx(typ) -text "57"  -value 57 -command "CheckChanPair"
		radiobutton $f.5.58 -variable chanexx(typ) -text "58"  -value 58 -command "CheckChanPair"
		frame $f.6
		radiobutton $f.6.61 -variable chanexx(typ) -text "61"  -value 61 -command "CheckChanPair"
		radiobutton $f.6.62 -variable chanexx(typ) -text "62"  -value 62 -command "CheckChanPair"
		radiobutton $f.6.63 -variable chanexx(typ) -text "63"  -value 63 -command "CheckChanPair"
		radiobutton $f.6.64 -variable chanexx(typ) -text "64"  -value 64 -command "CheckChanPair"
		radiobutton $f.6.65 -variable chanexx(typ) -text "65"  -value 65 -command "CheckChanPair"
		radiobutton $f.6.67 -variable chanexx(typ) -text "67"  -value 67 -command "CheckChanPair"
		radiobutton $f.6.68 -variable chanexx(typ) -text "68"  -value 68 -command "CheckChanPair"
		frame $f.7
		radiobutton $f.7.71 -variable chanexx(typ) -text "71"  -value 71 -command "CheckChanPair"
		radiobutton $f.7.72 -variable chanexx(typ) -text "72"  -value 72 -command "CheckChanPair"
		radiobutton $f.7.73 -variable chanexx(typ) -text "73"  -value 73 -command "CheckChanPair"
		radiobutton $f.7.74 -variable chanexx(typ) -text "74"  -value 74 -command "CheckChanPair"
		radiobutton $f.7.75 -variable chanexx(typ) -text "75"  -value 75 -command "CheckChanPair"
		radiobutton $f.7.76 -variable chanexx(typ) -text "76"  -value 76 -command "CheckChanPair"
		radiobutton $f.7.78 -variable chanexx(typ) -text "78"  -value 78 -command "CheckChanPair"
		frame $f.8
		radiobutton $f.8.81 -variable chanexx(typ) -text "81"  -value 81 -command "CheckChanPair"
		radiobutton $f.8.82 -variable chanexx(typ) -text "82"  -value 82 -command "CheckChanPair"
		radiobutton $f.8.83 -variable chanexx(typ) -text "83"  -value 83 -command "CheckChanPair"
		radiobutton $f.8.84 -variable chanexx(typ) -text "84"  -value 84 -command "CheckChanPair"
		radiobutton $f.8.85 -variable chanexx(typ) -text "85"  -value 85 -command "CheckChanPair"
		radiobutton $f.8.86 -variable chanexx(typ) -text "86"  -value 86 -command "CheckChanPair"
		radiobutton $f.8.87 -variable chanexx(typ) -text "87"  -value 87 -command "CheckChanPair"
		pack $f.1.12 $f.1.13 $f.1.14 $f.1.15 $f.1.16 $f.1.17 $f.1.18 -side left
		pack $f.2.21 $f.2.23 $f.2.24 $f.2.25 $f.2.26 $f.2.27 $f.2.28 -side left
		pack $f.3.31 $f.3.32 $f.3.34 $f.3.35 $f.3.36 $f.3.37 $f.3.38 -side left
		pack $f.4.41 $f.4.42 $f.4.43 $f.4.45 $f.4.46 $f.4.47 $f.4.48 -side left
		pack $f.5.51 $f.5.52 $f.5.53 $f.5.54 $f.5.56 $f.5.57 $f.5.58 -side left
		pack $f.6.61 $f.6.62 $f.6.63 $f.6.64 $f.6.65 $f.6.67 $f.6.68 -side left
		pack $f.7.71 $f.7.72 $f.7.73 $f.7.74 $f.7.75 $f.7.76 $f.7.78 -side left
		pack $f.8.81 $f.8.82 $f.8.83 $f.8.84 $f.8.85 $f.8.86 $f.8.87 -side left
		pack $f.1 $f.2 $f.3 $f.4 $f.5 $f.6 $f.8 -side top
		frame $f.9
		label $f.9.ll -text "Channel Pair"
		entry $f.9.e -textvariable chanexx(pair) -width 4 -state readonly
		button $f.9.b -text "Chan-Pair on Name End" -command PairexNamend -highlightbackground [option get . background {}]
		pack $f.9.ll $f.9.e $f.9.b -side left -padx 2
		pack $f.9 -side top -padx 4 -fill x -expand true
		frame $f.10
		label $f.10.ll -text "Output Filename "
		entry $f.10.e -textvariable chanexx(onam) -width 80
		pack $f.10.ll $f.10.e -side left
		pack $f.10 -side top -padx 4
		wm resizable $f 0 0
		bind $f <Return> {set pr_chanexx 1}
		bind $f <Escape> {set pr_chanexx 0}
	}
	set chanexx(onam) [file rootname [file tail $fnam]]
	set chanexx(pair) 12
	set chanexx(typ) 0
	set pr_chanexx 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_chanexx
	while {!$finished} {
		tkwait variable pr_chanexx
		switch -- $pr_chanexx {
			1 {
				if {![CheckChanPair]} {
					continue
				}
				if {![ValidCDPRootname $chanexx(onam)]} {
					continue
				}
				set ofnam [string tolower $chanexx(onam)]
				append ofnam $evv(SNDFILE_EXT)
				if {[file exists $ofnam]} {
					Inf "File $ofnam already exists : choose a different name"
					continue
				}
				Block "EXTRACTING THE CHANNEL PAIR [string index $chanexx(pair) 0] AND [string index $chanexx(pair) 1]"
				catch {unset CDPidrun}
				set prg_dun 0
				set prg_abortd 0
				catch {unset simple_program_messages}
				set cmd [file join $evv(CDPROGRAM_DIR) pairex]
				lappend cmd pairex $fnam $ofnam $chanexx(pair)
				if [catch {open "|$cmd"} CDPidrun] {
					ErrShow "CANNOT RUN CHANNEL EXTRACTION : $CDPidrun"
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
					set msg "Failed to run channel extraction"
					set msg [AddSimpleMessages $msg]
					ErrShow $msg
					UnBlock
					continue
				}
				if {![file exists $ofnam]} {
					set msg "No output file from channel extraction created"
					set msg [AddSimpleMessages $msg]
					ErrShow $msg
					UnBlock
					continue
				}

				if {[FileToWkspace $ofnam 0 0 0 0 1] > 0} {
					Inf "File $ofnam is on the workspace"
				} else {
					Inf "File $ofnam created"
				}
				UnBlock
			} 0 {
				set finished 1
			}
		}
	}
	DeleteAllTemporaryFiles
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}

proc CheckChanPair {} {
	global chanexx

	set chan1 [string index $chanexx(typ) 0]
	set chan2 [string index $chanexx(typ) 1]
	if {($chan1 > $chanexx(chans)) || ($chan2 > $chanexx(chans)) || ($chan1 == $chan2) || ($chan1 < 1) || ($chan2 < 1) } {
		Inf "Channel selection ($chanexx(typ)) inappropriate for a file of $chanexx(chans) channels\n\nuse channel values 1 to $chanexx(chans)"
		return 0
	}
	set chanexx(pair) $chanexx(typ)
	return 1
}

proc PairexNamend {} {
	global chanexx
	if {[string length $chanexx(onam)] <= 0} {
		Inf "No name entered yet"
		return
	}
	set nuname $chanexx(onam)
	set len [string length $chanexx(onam)]
	if {$len > 3} {
		set k [expr $len - 1]
		if {[regexp {[1-8]} [string index $chanexx(onam) $k]]} {
			incr k -1
			if {[regexp {[1-8]} [string index $chanexx(onam) $k]]} {
				incr k -1
				if {[regexp {\_} [string index $chanexx(onam) $k]]} {
					incr k -1
					set nuname [string range $chanexx(onam) 0 $k]
				}
			}
		}
	}
	append nuname "_" $chanexx(pair)
	set chanexx(onam) $nuname
}

#----- Take textfiles contaning phrases : pair the phrases (or form triples etc) onto single lines of new file

proc PairPhrases {} {
	global evv wstk hopperm pairphras chlist wl pa pr_pairphras

	set t1 [clock clicks]		;#	Set up an arbitrary rand number from computer clock
	set junk [expr srand($t1)]

	if {[info exists chlist] && ([llength $chlist] > 1)} {
		set fnams $chlist
		foreach fnam $fnams {
			if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
				unset fnams
				break
			}
		}
	}
	if {![info exists fnams]} {
		set ilist [$wl curselection]
		if {[info exists ilist] && ([llength $ilist] > 1)} {
			foreach i $ilist {
				lappend fnams [$wl get $i]
			}
		}
	}
	if {[info exists fnams]} {
		foreach fnam $fnams {
			if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
				unset fnams
				break
			}
		}
	}
	if {![info exists fnams]} {
		Inf "Select two or more textfiles"
		return
	}
	set n 0
	set OK 1
	set minlinescnt 10000000
	catch {unset lines}
	foreach fnam $fnams {
		set linecnt 1
		if [catch {open $fnam "r"} zit] {
			Inf "Cannot open file $fnam"
			set OK 0
			break
		}
		while {[gets $zit line] >= 0} {
			set line [string trim $line]
			if {[string length $line] <= 0} {
				continue
			}
			if {[string match [string index $line 0 ] ";"]} {
				continue
			}
			if {[regexp {[^A-Za-z_\-\ \'\,]} $line]} {		;# Alphabetic,underscore,hyphen,comma, space, single apostrophe
				Inf "Line $linecnt\n$line\n\nin file [file rootname [file tail $fnam]]contains invalid character(s)\nmust be alphanumeric, hyphen, underscore, apostrophe, comma or space."
				close $zit
				set OK 0
				break
			}
			lappend lines($n) [string tolower $line]
			incr linecnt
		}
		if {!$OK} {
			break
		}
		if {![info exists lines($n)] || ([llength $lines($n)] <= 0)} {
			Inf "No text found in file $fnam"
			close $zit
			set OK 0
			break
		}
		incr linecnt -1
		if {$linecnt < $minlinescnt} {
			set minlinescnt $linecnt
		}
		set pairphras(cnt,$n) [llength $lines($n)]
		close $zit
		incr n
	}
	if {!$OK} {
		return
	}
	set pairphras(filecnt) $n

	set f .pairphras
	if [Dlg_Create $f "PAIR PHRASES" "set pr_pairphras 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.s -text "Do Grouping" -command "set pr_pairphras 1" -width 11 -highlightbackground [option get . background {}]
		button $f.0.h -text "Help" -command "set pr_pairphras 2" -bg $evv(HELP) -highlightbackground [option get . background {}]
		label $f.0.m -text "Min linecount" -width 20
		button $f.0.q -text "Abandon"  -command "set pr_pairphras 0" -width 11 -highlightbackground [option get . background {}]
		pack $f.0.s $f.0.h $f.0.m -padx 2 -side left
		pack $f.0.q -side right 
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Outfile Name" -width 24 -anchor w
		entry $f.1.e -textvariable pairphras(ofnam) -width 20
		set pairphras(ofnam) ""
		pack $f.1.ll $f.1.e -side left
		pack $f.1 -side top -fill x -expand true
		frame $f.2
		label $f.2.ll -text "No. of outputs (1-1000)" -width 24 -anchor w
		entry $f.2.e -textvariable pairphras(cnt) -width 6
		set pairphras(cnt) ""
		pack $f.2.ll $f.2.e -side left
		pack $f.2 -side top -fill x -expand true
		wm resizable $f 0 0
		bind $f.1.e <Up> {focus .pairphras.2.e}
		bind $f.2.e <Up> {focus .pairphras.1.e}
		bind $f.1.e <Down> {focus .pairphras.2.e}
		bind $f.2.e <Down> {focus .pairphras.1.e}
		bind $f <Return> {set pr_pairphras 1}
		bind $f <Escape> {set pr_pairphras 0}
	}
	$f.0.m config -text "Min linecount $minlinescnt"
	set pairphras(cnt) $minlinescnt
	set pr_pairphras 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_pairphras $f.1.e
	while {!$finished} {
		tkwait variable pr_pairphras
		switch -- $pr_pairphras {
			0 {
				set finished 1
			}
			2 {
				set msg "Phrases\n"
				append msg "\n"
				append msg "Takes two or more textfiles listing phrases\n"
				append msg "(alphabetic, underscores, hyphens & spaces only)\n"
				append msg "\n"
				append msg "Selects phrases at random from each list\n"
				append msg "and conjoins them using \":\" as separator.\n"
				append msg "\n"
				append msg "With 2 input files output is\n"
				append msg "\"File 1 Phrase  :  File 2 Phrase\"\n"
				append msg "With 3 input files output is \n"
				append msg "\"File 1 Phrase  :  File 2 Phrase  :  File 3 Phrase\"\n"
				append msg "And so on....\n"
				append msg "\n"
				append msg "Output text is then written to a new file.\n"
				Inf $msg
			}
			1 {
				if {[string length $pairphras(ofnam)] <= 0} {
					Inf "No output filename entered"
					continue
				}
				if {![ValidCDPRootname $pairphras(ofnam)]} {
					continue
				}
				set ofnam [string tolower $pairphras(ofnam)]
				append ofnam $evv(TEXT_EXT)
				if {[file exists $ofnam]} {
					Inf "File $ofnam already exists : please choose a different name"
					continue
				}
				if {[string length $pairphras(cnt)] <= 0} {
					Inf "No count of output phrases entered"
					continue
				}
				if {![IsNumeric $pairphras(cnt)] || ![regexp {^[0-9]+$} $pairphras(cnt)] || ($pairphras(cnt) < 1) || ($pairphras(cnt) > 1000)} {
					Inf "Invalid count of output phrases to generate (range 1 - 1000)"
					continue
				}

				;#	GET ALL DATACOUNTS, AND SET UP PERMUTATION FOR EACH

				set n 0
				while {$n < $pairphras(filecnt)} {
					randperm $pairphras(cnt,$n)
					set pairphras(perm,$n) $hopperm
					set pairphras(permcnt,$n) 0
					incr n
				}

				catch {unset outtexts}
				set outcnt 0
				set top [expr $pairphras(filecnt) - 1]
				while {$outcnt < $pairphras(cnt)} {
					set outtext {}
					set n 0
					while {$n < $pairphras(filecnt)} {
						set k [lindex $pairphras(perm,$n) $pairphras(permcnt,$n)]
						incr pairphras(permcnt,$n)
						if {$pairphras(permcnt,$n) >= $pairphras(cnt,$n)} {				;#	If permutation (of phrases in file) exhausted
							randperm $pairphras(cnt,$n)									;#	Create a new perm and reset permcounter to zero
							set pairphras(perm,$n) $hopperm								
							set pairphras(permcnt,$n) 0
						}
						set outtext [concat $outtext [lindex $lines($n) $k]]
						if {$n < $top} {	
							set outtext [concat $outtext  " : "]
						}
						incr n
					}
					lappend outtexts $outtext
					incr outcnt
				}
				if [catch {open $ofnam "w"} zit] {
					Inf "Cannot open output file $ofnam to write output texts"
					continue
				}
				foreach outtext $outtexts {
					puts $zit $outtext
				}
				close $zit
				if {[FileToWkspace $ofnam 0 0 0 0 1] > 0} {
					Inf "File $ofnam is on the workspace"
				}
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
}	

#----- Take textfiles contaning phrases : pair (form triples etc) the phrases on single lines of new file

proc PhraseLinkage {} {
	global evv wstk hopperm phraslink chlist wl pa pr_phraslink wstk
	catch {unset lines(prelink)}
	catch {unset lines(midlink)}
	catch {unset lines(postlink)}
	catch {unset lines(inverselink)}
	if {[info exists chlist] && ([llength $chlist] > 1)} {
		set fnams $chlist
		foreach fnam $fnams {
			if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
				unset fnams
				break
			}
		}
	}
	if {![info exists fnams]} {
		set ilist [$wl curselection]
		if {[info exists ilist] && ([llength $ilist] > 1)} {
			foreach i $ilist {
				lappend fnams [$wl get $i]
			}
		}
	}
	if {[info exists fnams]} {
		foreach fnam $fnams {
			if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
				unset fnams
				break
			}
		}
	}
	if {![info exists fnams]} {
		set msg "Select a textfile of paired phrases\n"
		append msg "and at least one textfile of phrase-linkers which can be called any of\n"
		append msg "\"prelink.txt\"  \"midlink.txt\"  \"postlink.txt\"  \"inverselink.txt\"\n"
		Inf $msg
		return
	}
	set phraslink(cnt) 0
	set gotphrases 0
	set OK 1
	catch {unset lines(phrases)}
	catch {unset lines(prelink)}
	catch {unset lines(midlink)}
	catch {unset lines(postlink)}
	catch {unset lines(inverselink)}
	foreach fnam $fnams {
		set nam [file rootname [file tail $fnam]]
		if {[string match $nam "prelink"] || [string match $nam "midlink"] || [string match $nam "postlink"] || [string match $nam "inverselink"]} {
			if {[info exists lines($nam)]} {
				Inf "A $nam textfile has already been read"	
				set OK 0
				break
			}
			if [catch {open $fnam "r"} zit] {
				Inf "Cannot open file $fnam"
				set OK 0
				break
			}
			set linecnt 0
			while {[gets $zit line] >= 0} {
				incr linecnt
				set line [string trim $line]
				if {[string length $line] <= 0} {
					continue
				}
				if {[string match [string index $line 0 ] ";"]} {
					continue
				}
				if {[regexp {[^A-Za-z_\-\ \']} $line]} {		;# Alphabetic,underscore,hyphen,space, single apostrophe
					Inf "Line $linecnt in file $fnam\n$line\ncontains invalid character(s) for a file of phrase-linkers\nmust be alphanumeric, hyphen, underscore, apostrophe or space."
					set OK 0
					break
				}
				lappend lines($nam) $line
			}
			close $zit
			if {!$OK} {
				break
			}
			if {![info exists lines($nam)]} {
				Inf "No text found in file $fnam"
				set OK 0
				break
			}
			incr phraslink(cnt)
		} else {
			if [catch {open $fnam "r"} zit] {
				Inf "Cannot open file $fnam"
				set OK 0
				break
			}
			set linecnt 0
			while {[gets $zit line] >= 0} {
				set line [string trim $line]
				incr linecnt
				if {[string length $line] <= 0} {
					continue
				}
				if {[string match [string index $line 0 ] ";"]} {
					continue
				}
				if {[regexp {[^A-Za-z_\-\ \'\:\,]} $line]} {		;# Alphabetic,underscore,hyphen,space, single apostrophe, comma
					Inf "Line $linecnt in file $fnam\n$line\ncontains invalid character(s)\nmust be alphanumeric, hyphen, underscore, comma, apostrophe, colon or space."
					set OK 0
					break
				} elseif {![regexp {\:} $line]} {
					Inf "Line $linecnt\n$line\nin what must be the phrase-file $fnam\ncontains no colon separator."
					set OK 0
					break
				} else {
					set len [string length $line]
					set k 0
					set coloncnt 0
					while {$k < $len} {
						if {[string match [string index $line $k] "\:"]} {
							incr coloncnt
							if {$coloncnt > 1} {
								Inf "Line $linecnt\n$line\nin phrase-file $fnam\nhas more than two phrases on the line."
								set OK 0
								break
							}
						}
						incr k
					}
					if {!$OK} {
						break
					}
				}													
				lappend lines(phrases) $line
			}
			close $zit
			if {!$OK} {
				break
			}
			if {![info exists lines(phrases)]} {
				Inf "No text found in file $fnam"
				set OK 0
				break
			}
			set gotphrases 1
		}
	}
	if {!$OK} {
		return
	}
	if {$phraslink(cnt) <= 0} {
		Inf "No linking texts found"
		return
	}
	if {!$gotphrases} {
		Inf "No paired-phrases textfile found"
		return
	}
	set f .phraslink
	if [Dlg_Create $f "LINK PAIRED PHRASES" "set pr_phraslink 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.s -text "Save linked lines" -command "set pr_phraslink 1" -width 17 -highlightbackground [option get . background {}]
		button $f.0.h -text "Help" -command "set pr_phraslink 2" -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.0.c -text "Clear Line" -command "set pr_phraslink 3" -width 9 -highlightbackground [option get . background {}]
		button $f.0.cc -text "Clear All" -command "set pr_phraslink 4" -width 9 -highlightbackground [option get . background {}]
		button $f.0.q -text "Abandon"  -command "set pr_phraslink 0" -width 11 -highlightbackground [option get . background {}]
		pack $f.0.s $f.0.h $f.0.c -padx 2 -side left
		pack $f.0.q -side right 
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Outfile Name" -width 24 -anchor w
		entry $f.1.e -textvariable phraslink(ofnam) -width 20
		set phraslink(ofnam) ""
		pack $f.1.ll $f.1.e -side left
		pack $f.1 -side top -fill x -expand true
		frame $f.2
		label $f.2.tit -text "Phrase pairs" -fg $evv(SPECIAL)
		Scrolled_Listbox $f.2.ll -width 180 -height 30 -selectmode single
		bind .phraslink.2.ll.list <ButtonRelease-1> {PhrasLinkSelect %y} 
		pack $f.2.tit $f.2.ll -side top -pady 2
		pack $f.2.ll -side left
		pack $f.2 -side top -pady 4
		frame $f.3
		set zwidth [expr int(floor(180/$phraslink(cnt)))]
		if {[info exists lines(prelink)]} {
			frame $f.3.0
			label $f.3.0.tit -text "PRE-links" -fg $evv(SPECIAL)
			Scrolled_Listbox $f.3.0.ll -width $zwidth -height 24 -selectmode single
			pack $f.3.0.tit $f.3.0.ll -side top -pady 2
			pack $f.3.0 -side left
			bind .phraslink.3.0.ll.list <ButtonRelease-1> {PhrasLinkInsert pre 0 %y} 
		}
		if {[info exists lines(midlink)]} {
			frame $f.3.1
			label $f.3.1.tit -text "MID-links" -fg $evv(SPECIAL)
			Scrolled_Listbox $f.3.1.ll -width $zwidth -height 24 -selectmode single
			pack $f.3.1.tit $f.3.1.ll -side top -pady 2
			pack $f.3.1 -side left
			bind .phraslink.3.1.ll.list <ButtonRelease-1> {PhrasLinkInsert mid 1 %y}
		}
		if {[info exists lines(postlink)]} {
			frame $f.3.2
			label $f.3.2.tit -text "POST-links" -fg $evv(SPECIAL)
			Scrolled_Listbox $f.3.2.ll -width $zwidth -height 24 -selectmode single
			pack $f.3.2.tit $f.3.2.ll -side top -pady 2
			pack $f.3.2 -side left
			bind .phraslink.3.2.ll.list <ButtonRelease-1> {PhrasLinkInsert post 2 %y} 
		}
		if {[info exists lines(inverselink)]} {
			frame $f.3.3
			label $f.3.3.tit -text "INVERSE-links" -fg $evv(SPECIAL)
			Scrolled_Listbox $f.3.3.ll -width $zwidth -height 24 -selectmode single
			pack $f.3.3.tit $f.3.3.ll -side top -pady 2
			pack $f.3.3 -side left
			bind .phraslink.3.3.ll.list <ButtonRelease-1> {PhrasLinkInsert invert 3 %y} 
		}
		pack $f.3 -side top -pady 4
		bind $f <Return> {set pr_phraslink 1}
		bind $f <Escape> {set pr_phraslink 0}
	}
	.phraslink.2.ll.list delete 0 end
	set phraslink(origlines) {}
	foreach line $lines(phrases) {
		.phraslink.2.ll.list insert end $line
		lappend phraslink(origlines) $line
	}
	if {[info exists lines(prelink)]} {
		.phraslink.3.0.ll.list delete 0 end
		foreach line $lines(prelink) {
			.phraslink.3.0.ll.list insert end $line
		}
	}
	if {[info exists lines(midlink)]} {
		.phraslink.3.1.ll.list delete 0 end
		foreach line $lines(midlink) {
			.phraslink.3.1.ll.list insert end $line
		}
	}
	if {[info exists lines(postlink)]} {
		.phraslink.3.2.ll.list delete 0 end
		foreach line $lines(postlink) {
			.phraslink.3.2.ll.list insert end $line
		}
	}
	if {[info exists lines(inverselink)]} {
		.phraslink.3.3.ll.list delete 0 end
		foreach line $lines(inverselink) {
			.phraslink.3.3.ll.list insert end $line
		}
	}
	set phraslink(sel) -1
	set pr_phraslink 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_phraslink $f.1.e
	while {!$finished} {
		tkwait variable pr_phraslink
		switch -- $pr_phraslink {
			0 {
				set finished 1
			}
			2 {
				set msg "Pair Phrases\n"
				append msg "\n"
				append msg "Select a Phrase-pair Line\n"
				append msg "\n"
				append msg "Then select link phrase from displayed lists ...\n"
				append msg "\n"
				append msg "(1) Prelink\n"
				append msg "\n"
				append msg "Introduces selected phrase-pair with \"Prelink\" text.\n"
				append msg "\n"
				append msg "(2) Midlink\n"
				append msg "\n"
				append msg "Joins selected phrase-pair with a \"Midlink\" text.\n"
				append msg "\n"
				append msg "(3) Postlink\n"
				append msg "\n"
				append msg "Concludes selected phrase-pair with \"Postlink\" text.\n"
				append msg "\n"
				append msg "(4) Inverselink\n"
				append msg "\n"
				append msg "Inverts order of phrases in the phrase-pair\n"
				append msg "and links them with an \"Inverselink\" text.\n"
				append msg "\n"
				append msg "Selected line can be Reset to its original state\n"
				append msg "using the \"Clear Line\" button.\n"
				append msg "\n"
				append msg "Output text is then written to a new file.\n"
				Inf $msg
			}
			3 {
				if {$phraslink(sel) < 0} {
					Inf "No line selected"
					continue
				}
				set k $phraslink(sel)
				.phraslink.2.ll.list delete $k
				.phraslink.2.ll.list insert $k [lindex $phraslink(origlines) $k]
				catch {unset phraslink(pre,$k)}
				catch {unset phraslink(mid,$k)}
				catch {unset phraslink(post,$k)}
				catch {unset phraslink(inverse,$k)}
				.phraslink.2.ll.list selection set $k

			}
			4 {
				set msg "Are you sure you want to clear ~~all~~ the lines ??"
				set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg -default no]
				if {$choice == "no"} {
					continue
				}
				.phraslink.2.ll.list delete 0 end
				set n 0
				foreach origline $phraslink(origlines) {
					.phraslink.2.ll.list insert end $origline
					catch {unset phraslink(pre,$n)}
					catch {unset phraslink(mid,$n)}
					catch {unset phraslink(post,$n)}
					catch {unset phraslink(inverse,$n)}
					incr n
				}
			}
			1 {
				if {[string length $phraslink(ofnam)] <= 0} {
					Inf "No output filename entered"
					continue
				}
				if {![ValidCDPRootname $phraslink(ofnam)]} {
					continue
				}
				set ofnam [string tolower $phraslink(ofnam)]
				append ofnam $evv(TEXT_EXT)
				if {[file exists $ofnam]} {
					Inf "File $ofnam already exists : please choose a different name"
					continue
				}
				catch {unset outtexts}
				foreach line [.phraslink.2.ll.list get 0 end] origline $phraslink(origlines) {
					if {![string match $line $origline]} {
						set linend [expr [string length $line] - 1]
						set k [string first \: $line]
						if {$k >= 0} {
							set msg "Line \"$line\" still has a colon-separator : remove it ??"
							set choice [tk_messageBox -type yesno -icon question -parent [lindex $wstk end] -message $msg]
							if {$choice == "yes"} {
								if {$k == 0} {
									set line [string range $line 1 end]
								} elseif {$k == $linend} {
									set line [string range $line 0 [expr $linend - 1]]
								} else {
									incr k -1
									set nuline [string range $line 0 $k]
									incr k 2
									set nuline [concat $nuline [string range $line $k end]]
									set line $nuline
								}
							}
						}
						lappend outtexts $line
					}
				}
				if {![info exists outtexts]} {
					Inf "No lines have been linked"
					continue
				}
				if [catch {open $ofnam "w"} zit] {
					Inf "Cannot open output file $ofnam to write output texts"
					continue
				}
				foreach outtext $outtexts {
					puts $zit $outtext
				}
				close $zit
				if {[FileToWkspace $ofnam 0 0 0 0 1] > 0} {
					Inf "File $ofnam is on the workspace"
				}
				set finished 1
			}
		}
	}
	set n 0
	foreach origline $phraslink(origlines) {
		catch {unset phraslink(pre,$n)}
		catch {unset phraslink(mid,$n)}
		catch {unset phraslink(post,$n)}
		catch {unset phraslink(inverse,$n)}
		incr n
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}	

proc PhrasLinkSelect {y} {
	global phraslink
	set i [.phraslink.2.ll.list nearest $y]
	if {$i < 0} {
		return
	}
	set phraslink(sel) $i
}

proc PhrasLinkInsert {typ k y} {
	global phraslink
	if {$phraslink(sel) < 0} {
		Inf "No phrase-pair selected"
		return
	}
	set ps $phraslink(sel)
	set i [.phraslink.3.$k.ll.list nearest $y]
	if {$i < 0} {
		return
	}
	switch -- $typ {
		"pre" {
			if {[info exists phraslink(pre,$ps)]} {
				Inf "Line already has a prelink: clear line to start afresh"
				return
			}
			set nuline [.phraslink.3.$k.ll.list get $i]
			set nuline [concat $nuline " "]
			set nuline [concat $nuline [.phraslink.2.ll.list get $ps]]
			set phraslink(pre,$ps) 1
		}
		"mid"  {
			if {[info exists phraslink(mid,$ps)]} {
				Inf "Line already has a midlink: clear line to start afresh"
				return
			}
			if {[info exists phraslink(inverse,$ps)]} {
				Inf "Line already modified by an inverse link: clear line to start afresh"
				return
			}
			set origline [.phraslink.2.ll.list get $ps]
			set origline [split $origline ":"]
			set nuline [lindex $origline 0]
			set nuline [concat $nuline [.phraslink.3.$k.ll.list get $i]]
			set nuline [concat $nuline [lindex $origline 1]]
			set phraslink(mid,$ps) 1
		}
		"post"  {
			if {[info exists phraslink(post,$ps)]} {
				Inf "Line already has a postlink: clear line to start afresh"
				return
			}
			if {[info exists phraslink(inverse,$ps)]} {
				Inf "Line already modified by an inverse link: clear line to start afresh"
				return
			}
			set nuline [.phraslink.2.ll.list get $ps]
			set nuline [concat $nuline " "]
			set nuline [concat $nuline [.phraslink.3.$k.ll.list get $i]]
			set phraslink(post,$ps) 1
		}
		"invert"  {
			if {[info exists phraslink(inverse,$ps)]} {
				Inf "Line already has an inverse link: clear line to start afresh"
				return
			}
			set origline [.phraslink.2.ll.list get $ps]
			set origline [split $origline ":"]
			set nuline [lindex $origline 1]
			set nuline [concat $nuline [.phraslink.3.$k.ll.list get $i]]
			set nuline [concat $nuline [lindex $origline 0]]
			set phraslink(inverse,$ps) 1
		}
	}
	.phraslink.2.ll.list delete $ps			
	.phraslink.2.ll.list insert $ps $nuline
	.phraslink.2.ll.list selection set $ps
}


proc SetWordseq {gramtyp len} {
	switch -- $gramtyp {
		0 {			;#	A | A A ..... | N
			set acnt  [expr $len - 2]
			set wordseq	A 
			set kj 0
			while {$kj < $acnt} {
				lappend wordseq A
				incr kj
			}
			lappend wordseq N
		}
		1 {			;#	V | A A ..... | N
			set acnt  [expr $len - 2]
			set wordseq	V 
			set kj 0
			while {$kj < $acnt} {
				lappend wordseq A
				incr kj
			}
			lappend wordseq N
		}
		2 {			;#	A | A A .... | N N
			set acnt [expr $len - 3]
			set wordseq	A 
			set kj 0
			while {$kj < $acnt} {
				lappend wordseq A
				incr kj
			}
			lappend wordseq N N
		}
		3 {			;#	V | A A .... | N N
			set acnt [expr $len - 3]
			set wordseq	V 
			set kj 0
			while {$kj < $acnt} {
				lappend wordseq A
				incr kj
			}
			lappend wordseq N N
		}
	}
	return $wordseq
}

#---- Get text bracketed in curly-brackets

proc StripCurliesFromWords {str} {
	set len [string length $str]
	set j 0
	while {$j >= 0} {
		set j [string first "\{" $str] 
		if {$j == 0} {
			set str [string range $str 1 end]
			incr len -1
		} elseif {$j == [expr $len - 1]} {
			incr len -2
			set str [string range $str 0 $len]
			incr len
		} elseif {$j > 0} {
			incr j -1
			set str1 [string range $str 0 $j]
			incr j 2
			set str2 [string range $str $j end]
			set str $str1
			append str $str2
			incr len -1
		}
	}
	set j 0
	while {$j >= 0} {
		set j [string first "\}" $str] 
		if {$j == 0} {
			set str [string range $str 1 end]
			incr len -1
		} elseif {$j == [expr $len - 1]} {
			incr len -2
			set str [string range $str 0 $len]
			incr len
		} elseif {$j > 0} {
			incr j -1
			set str1 [string range $str 0 $j]
			incr j 2
			set str2 [string range $str $j end]
			set str $str1
			append str $str2
			incr len -1
		}
	}
	return $str
}

#----- Change ordxer of paired phrases

proc PairPhraseSwap {} {
	global evv phraswap chlist wl pa pr_phraswap
	if {[info exists chlist] && ([llength $chlist] == 1)} {
		set fnam [lindex $chlist 0]
	} else {
		set i [$wl curselection]
		if {[info exists i] && ([llength $i] == 1) && ($i != -1)} {
			set fnam [$wl get $i]
		}
	}
	if {[info exists fnam]} {
		if {!($pa($fnam,$evv(FTYP)) & $evv(IS_A_TEXTFILE))} {
			unset fnam
			break
		}
	}
	if {![info exists fnam]} {
		Inf "Select a textfile of paired phrases (no more than 3 linked phrases)\n"
		return
	}
	set OK 1

	if [catch {open $fnam "r"} zit] {
		Inf "Cannot open file $fnam"
		set OK 0
		break
	}
	set linecnt 0
	set datalinecnt 0
	catch {unset phraswap(lines)}
	while {[gets $zit line] >= 0} {
		set line [string trim $line]
		incr linecnt
		if {[string length $line] <= 0} {
			continue
		}
		if {[string match [string index $line 0 ] ";"]} {
			continue
		}
		if {[regexp {[^A-Za-z_\-\ \'\:\,]} $line]} {		;# Alphabetic,underscore,hyphen,space, single apostrophe, comma
			Inf "Line $linecnt in file $fnam\n$line\ncontains invalid character(s)\nmust be alphanumeric, hyphen, underscore, comma, apostrophe, colon or space."
			set OK 0
			break
		} elseif {![regexp {\:} $line]} {
			Inf "Line $linecnt\n$line in file $fnam\ncontains no colon separator."
			set OK 0
			break
		}
		set coloncnt 0
		set len [string length $line]
		set k 0
		while {$k < $len} {
			if {[string match [string index $line $k] "\:"]} {
				incr coloncnt
				if {$coloncnt > 3} {
					Inf "Line $linecnt\n\"$line\"\nin file $fnam\nhas more than four phrases per line."
					set OK 0
					break
				}
			}
			incr k
		}
		if {!$OK} {
			break
		}
		if {![info exists x_coloncnt]} {
			set x_coloncnt $coloncnt
		} elseif {$coloncnt != $x_coloncnt} {
			Inf "File $fnam has different numbers of phrases ($coloncnt & $x_coloncnt) on different lines"
			set OK 0
			break
		}
		set line [split $line ":"]
		set k 0
		catch {unset nuline}
		foreach item $line {
			set item [string trim $item]
			lappend nuline $item
		}
		lappend phraswap(lines) $nuline
		incr datalinecnt
	}													
	close $zit
	if {!$OK} {
		return
	}
	if {![info exists x_coloncnt]} {
		Inf "No phrases found"
		return
	}
	set f .phraswap
	if [Dlg_Create $f "LINK PAIRED PHRASES" "set pr_phraswap 0" -borderwidth $evv(SBDR)] {
		frame $f.0
		button $f.0.s -text "Swap Phrases" -command "set pr_phraswap 1" -width 12 -highlightbackground [option get . background {}]
		button $f.0.h -text "Help" -command "set pr_phraswap 2" -bg $evv(HELP) -highlightbackground [option get . background {}]
		button $f.0.q -text "Abandon"  -command "set pr_phraswap 0" -width 11 -highlightbackground [option get . background {}]
		pack $f.0.s $f.0.h -padx 2 -side left
		pack $f.0.q -side right 
		pack $f.0 -side top -fill x -expand true
		frame $f.1
		label $f.1.ll -text "Outfile Name" -width 24 -anchor w
		entry $f.1.e -textvariable phraswap(ofnam) -width 20
		pack $f.1.ll $f.1.e -side left
		pack $f.1 -side top -fill x -expand true
		label $f.1a -text "REARRANGEMENT" -fg $evv(SPECIAL)
		pack $f.1a -side top -pady 2
		frame $f.2
		radiobutton $f.2.21   -variable phraswap(typ) -text "21"   -width 6 -value 21   
		radiobutton $f.2.132  -variable phraswap(typ) -text "132"  -width 6 -value 132  
		radiobutton $f.2.213  -variable phraswap(typ) -text "213"  -width 6 -value 213  
		radiobutton $f.2.231  -variable phraswap(typ) -text "231"  -width 6 -value 231  
		pack $f.2.21 $f.2.132 $f.2.213 $f.2.231 -side left
		pack $f.2 -side top -fill x -expand true
		frame $f.2a
		radiobutton $f.2a.1243 -variable phraswap(typ) -text "1243" -width 6 -value 1243 
		radiobutton $f.2a.1324 -variable phraswap(typ) -text "1324" -width 6 -value 1324 
		radiobutton $f.2a.1342 -variable phraswap(typ) -text "1342" -width 6 -value 1342 
		radiobutton $f.2a.1423 -variable phraswap(typ) -text "1423" -width 6 -value 1423 
		radiobutton $f.2a.1432 -variable phraswap(typ) -text "1432" -width 6 -value 1432 
		radiobutton $f.2a.2134 -variable phraswap(typ) -text "2134" -width 6 -value 2134 
		radiobutton $f.2a.2143 -variable phraswap(typ) -text "2143" -width 6 -value 2143 
		radiobutton $f.2a.2314 -variable phraswap(typ) -text "2314" -width 6 -value 2314 
		radiobutton $f.2a.2341 -variable phraswap(typ) -text "2341" -width 6 -value 2341 
		radiobutton $f.2a.2413 -variable phraswap(typ) -text "2413" -width 6 -value 2413 
		radiobutton $f.2a.2431 -variable phraswap(typ) -text "2431" -width 6 -value 2431 
		pack $f.2a.1243 $f.2a.1324 $f.2a.1342 $f.2a.1423 $f.2a.1432 $f.2a.2134 $f.2a.2143 $f.2a.2314 $f.2a.2341 $f.2a.2413 $f.2a.2431 -side left
		pack $f.2a -side top -fill x -expand true
		frame $f.2b
		radiobutton $f.2b.3124 -variable phraswap(typ) -text "3124" -width 6 -value 3124 
		radiobutton $f.2b.3142 -variable phraswap(typ) -text "3142" -width 6 -value 3142 
		radiobutton $f.2b.3214 -variable phraswap(typ) -text "3214" -width 6 -value 3214 
		radiobutton $f.2b.3241 -variable phraswap(typ) -text "3241" -width 6 -value 3241 
		radiobutton $f.2b.3412 -variable phraswap(typ) -text "3412" -width 6 -value 3412 
		radiobutton $f.2b.3421 -variable phraswap(typ) -text "3421" -width 6 -value 3421 
		radiobutton $f.2b.4123 -variable phraswap(typ) -text "4123" -width 6 -value 4123 
		radiobutton $f.2b.4132 -variable phraswap(typ) -text "4132" -width 6 -value 4132 
		radiobutton $f.2b.4213 -variable phraswap(typ) -text "4213" -width 6 -value 4213 
		radiobutton $f.2b.4231 -variable phraswap(typ) -text "4231" -width 6 -value 4231 
		radiobutton $f.2b.4312 -variable phraswap(typ) -text "4312" -width 6 -value 4312 
		radiobutton $f.2b.4321 -variable phraswap(typ) -text "4321" -width 6 -value 4321 
		pack $f.2b.3124 $f.2b.3142 $f.2b.3214 $f.2b.3241 $f.2b.3412 $f.2b.3421 $f.2b.4123 $f.2b.4132 $f.2b.4213 $f.2b.4231 $f.2b.4312 $f.2b.4321 -side left
		pack $f.2b -side top -fill x -expand true
		bind $f <Return> {set pr_phraswap 1}
		bind $f <Escape> {set pr_phraswap 0}
	}
	set phraswap(ofnam) [file rootname [file tail $fnam]]
	switch -- $x_coloncnt {
		1 {
			$f.2.21    config -text "21" -state normal
			$f.2.132   config -text "" -state disabled 
			$f.2.213   config -text "" -state disabled 
			$f.2.231   config -text "" -state disabled 
			$f.2a.1243 config -text "" -state disabled 
			$f.2a.1324 config -text "" -state disabled 
			$f.2a.1342 config -text "" -state disabled 
			$f.2a.1423 config -text "" -state disabled 
			$f.2a.1432 config -text "" -state disabled 
			$f.2a.2134 config -text "" -state disabled 
			$f.2a.2143 config -text "" -state disabled 
			$f.2a.2314 config -text "" -state disabled 
			$f.2a.2341 config -text "" -state disabled 
			$f.2a.2413 config -text "" -state disabled 
			$f.2a.2431 config -text "" -state disabled 
			$f.2b.3124 config -text "" -state disabled 
			$f.2b.3142 config -text "" -state disabled 
			$f.2b.3214 config -text "" -state disabled 
			$f.2b.3241 config -text "" -state disabled 
			$f.2b.3412 config -text "" -state disabled 
			$f.2b.3421 config -text "" -state disabled 
			$f.2b.4123 config -text "" -state disabled 
			$f.2b.4132 config -text "" -state disabled 
			$f.2b.4213 config -text "" -state disabled 
			$f.2b.4231 config -text "" -state disabled 
			$f.2b.4312 config -text "" -state disabled 
			$f.2b.4321 config -text "" -state disabled 
		}
		2 {
			$f.2.21    config -text "" -state disabled  
			$f.2.132   config -text "132" -state normal
			$f.2.213   config -text "213" -state normal
			$f.2.231   config -text "231" -state normal
			$f.2a.1243 config -text "" -state disabled 
			$f.2a.1324 config -text "" -state disabled 
			$f.2a.1342 config -text "" -state disabled 
			$f.2a.1423 config -text "" -state disabled 
			$f.2a.1432 config -text "" -state disabled 
			$f.2a.2134 config -text "" -state disabled 
			$f.2a.2143 config -text "" -state disabled 
			$f.2a.2314 config -text "" -state disabled 
			$f.2a.2341 config -text "" -state disabled 
			$f.2a.2413 config -text "" -state disabled 
			$f.2a.2431 config -text "" -state disabled 
			$f.2b.3124 config -text "" -state disabled 
			$f.2b.3142 config -text "" -state disabled 
			$f.2b.3214 config -text "" -state disabled 
			$f.2b.3241 config -text "" -state disabled 
			$f.2b.3412 config -text "" -state disabled 
			$f.2b.3421 config -text "" -state disabled 
			$f.2b.4123 config -text "" -state disabled 
			$f.2b.4132 config -text "" -state disabled 
			$f.2b.4213 config -text "" -state disabled 
			$f.2b.4231 config -text "" -state disabled 
			$f.2b.4312 config -text "" -state disabled 
			$f.2b.4321 config -text "" -state disabled 
		}
		3 {
			$f.2.21    config -text "" -state disabled 
			$f.2.132   config -text "" -state disabled 
			$f.2.213   config -text "" -state disabled 
			$f.2.231   config -text "" -state disabled 
			$f.2a.1243 config -text "1243" -state normal
			$f.2a.1324 config -text "1324" -state normal
			$f.2a.1342 config -text "1342" -state normal
			$f.2a.1423 config -text "1423" -state normal
			$f.2a.1432 config -text "1432" -state normal
			$f.2a.2134 config -text "2134" -state normal
			$f.2a.2143 config -text "2143" -state normal
			$f.2a.2314 config -text "2314" -state normal
			$f.2a.2341 config -text "2341" -state normal
			$f.2a.2413 config -text "2413" -state normal
			$f.2a.2431 config -text "2431" -state normal
			$f.2b.3124 config -text "3124" -state normal
			$f.2b.3142 config -text "3142" -state normal
			$f.2b.3214 config -text "3214" -state normal
			$f.2b.3241 config -text "3241" -state normal
			$f.2b.3412 config -text "3412" -state normal
			$f.2b.3421 config -text "3421" -state normal
			$f.2b.4123 config -text "4123" -state normal
			$f.2b.4132 config -text "4132" -state normal
			$f.2b.4213 config -text "4213" -state normal
			$f.2b.4231 config -text "4231" -state normal
			$f.2b.4312 config -text "4312" -state normal
			$f.2b.4321 config -text "4321" -state normal
		}
		default {
			Inf "Unrecognised count of phrases per line ($x_coloncnt)"
			Dlg_Dismiss $f
			return
		}
	}
	set phraswap(typ) 0
	set pr_phraswap 0
	set finished 0
	raise $f
	update idletasks
	StandardPosition $f
	My_Grab 0 $f pr_phraswap $f.1.e
	while {!$finished} {
		tkwait variable pr_phraswap
		switch -- $pr_phraswap {
			0 {
				set finished 1
			}
			2 {
				set msg "Swap Phrases\n"
				append msg "\n"
				append msg "Swap phrases in phrase-paired lines\n"
				append msg "\n"
				append msg "(1) With 2 phrases options are ....\n"
				append msg "\n"
				append msg "\"12\" (original order) and \"21\" (reversed).\n"
				append msg "\n"
				append msg "(2) With 3 phrases options are  ....\n"
				append msg "\n"
				append msg "\"123\" (original order)\n"
				append msg "gives \"132\", \"213\", \"231\", \"312\", \"321\".\n"
				append msg "\n"
				append msg "(3) With 4 phrases options are  ....\n"
				append msg "\"1234\" (original order), gives\n"
				append msg "\"1243\", \"1324\", \"1342\", \"1423\", \"1432\".\n"
				append msg "\"2134\", \"2143\", \"2314\", \"2341\", \"2413\", \"2431\".\n"
				append msg "\"3124\", \"3142\", \"3214\", \"3241\", \"3412\", \"3421\".\n"
				append msg "\"4123\", \"4132\", \"4213\", \"4231\", \"4312\", \"4321\".\n"
				append msg "\n"
				append msg "Output text is then written to a new file.\n"
				Inf $msg
			}
			1 {
				if {$phraswap(typ) <= 0} {
					Inf "No swap selected"
					continue
				}
				if {[string length $phraswap(ofnam)] <= 0} {
					Inf "No output filename entered"
					continue
				}
				if {![ValidCDPRootname $phraswap(ofnam)]} {
					continue
				}
				set ofnam [string tolower $phraswap(ofnam)]
				append ofnam $evv(TEXT_EXT)
				if {[file exists $ofnam]} {
					Inf "File $ofnam already exists : please choose a different name"
					continue
				}
				catch {unset nulines}
				set len [string length $phraswap(typ)]
				foreach line $phraswap(lines) {
					catch {unset nuline}
					set n 0
					while {$n < $len} {				
						set i [string index $phraswap(typ) $n]
						incr i -1
						lappend nuline [lindex $line $i]
						incr n
					}
					set nuline [join $nuline " : "]
					lappend nulines $nuline
				}
				if [catch {open $ofnam "w"} zit] {
					Inf "Cannot open output file $ofnam to write output texts"
					continue
				}
				foreach nuline $nulines {
					puts $zit $nuline
				}
				close $zit
				if {[FileToWkspace $ofnam 0 0 0 0 1] > 0} {
					Inf "File $ofnam is on the workspace"
				}
				set finished 1
			}
		}
	}
	My_Release_to_Dialog $f
	Dlg_Dismiss $f
	destroy $f
}	

