#
# SOUND LOOM RELEASE mac version 17.0.4
#

# RWD changes for OS X: need to add -ipadx 5 to rows of widgets, to get proper space for text
# see Lines 119,136,233
# RWD 30 June 2013
# fixup button rectangles

# CUSTOMIZE INTERFACE	#
#########################

#------ Allow user to customise the appearance of the GUI
#
#		|		  |			   |  |		|			  |			  |	 |		|			 | |			 |	|
# COLUMN|	 0	  |		 1	   | 2|	 3	|	   4	  |		5	  |	6|	7	|	   8	 |9|	 10	     |11|
#		|		  |			   |  |		|			  |			  |	 |		|			 | |			 |	|
#---------------------------------------------------------------------------------------------------------
#	|	INTERFACE DESIGN																					  |
#	|---------------------------------------------------------------------------------------------------------|
#ROW|			     								  													  	  |
# 0	|												DON'T REDESIGN AGAIN [_] KEEP DESIGN [SAVE] ABANDON [QUIT]|
# 1	|---------------------------------------------------------------------------------------------------------|
# 	|													    /\	     /\		  /\					  		  |
# 2	|	FILES AND DIRECTORIES	sndfile extension  	   .wav \/	.aif \/ .aiff \/							  |
# 3 |NORMAL:    font      normal     active     select     trough      disabled								  |
# 4 |RUNNING: "Information :" "Warning !!! :" "Error Error :" 	[___________|____________]					  |
# 5 |PROCESS: [ACTIVE STATE] [DISABLED STATE] [HELP STATE] 						PITCH 	  DISABLED STATE: [C#]|
# 6 |TREEKEY:  SOUND  ANALYSIS  PITCH  TRANSPOS  FORMANT  ENVELOPE   TEXT  MONO   KEPT   DELETED  ACTIVE	  |
# 7	|---------------------------------------------------------------------------------------------------------|
# 	|			 	   /\		 /\		   /\		/\		/\		  /\	   /\		   /\		  	 /\	  |
# 8	|	PALETTE    red \/ orange \/ yellow \/ green \/ blue \/ purple \/ brown \/  offwhite\/ black:grey \/	  |
# 9	|		STANDARD FEATURES				MACHINE TREE KEY______			 ___COLORS___ ____FONTS____	  |
# 10|	Font	   ___________	[_]		Font size	  [__default__]	[_]		|		   | | |  | |	  |
# 11|	Font size [__default__]	[_]		active button bkgd color	[_]		|		   |v| 	 |		   |v|	  |
# 12|	background				[_]		active button frgd color	[_]		|		   | | |		   | |    |
# 13|	foreground				[_]		tree-key background			[_]		|		   | | |		   | |	  |
# 14|	activeBackground		[_]		tree-key text color			[_]		|		   | | |		   | |    |
# 15|	activeForeground		[_]		tree-key text bkgd color	[_]		|		   | | |		   |  |	  |
# 16|	selectColor				[_]		tree soundfile color		[_]		|		   | | |		   | |	  |
# 17|	selectBackground		[_]		tree mono sndfile color		[_]		|__________|_| |___________|_|    |
# 18|	troughColor				[_]		tree analysis file color	[_]				RESTORE STATE	_  |
# 19|	disabledForeground		[_]		tree pitchfile color		[_]		Restore CDP  defaults		  [_] |
# 20|	  PROCESS RUN DISPLAY	 _		tree transpose file color	[_]		Restore  current defaults	  [_] |
# 21|	info text color			[_] 	tree formant file color		[_]				PROCESS MENU	       _  |
# 22|	warning text color		[_] 	tree envelope file color	[_]		active process 	 color		  [_] |
# 23|	error text color		[_] 	tree textfile color			[_]		disabled process color		  [_] |
# 24|	progress bar color		[_]											help information color		  [_] |
# 25|	progress bar background	[_]												  PARAMETER MENU		   _  |
# 26|	Progress bar endstops	[_]											disabled pitchbutton color	  [_] |
# 27|---------------------------------------------------------------------------------------------------------|


proc Customize_Appearance_Dialog {} {
	global fntlist fnt_sz treefnt_sz pr_design uv evv
	global treefnt treedeletefnt treekeyfnt palette
	global displaypage cl ff3 ff4 ff5 ff6
	global local_fnt_family local_fnt_sz local_userfnt
	global local_treefnt_family local_treefnt_sz wstk user_resource_changed

	set dummy_pitch	  "C#"

	set local_fnt_family $uv(fnt_family)
	set local_fnt_sz $uv(fnt_sz)
	font create local_userfnt -family $local_fnt_family -size $local_fnt_sz
	font create testfnt -family $local_fnt_family -size $local_fnt_sz

	set local_treefnt_family $evv(T_FONT_STYLE)
	set local_treefnt_sz  $evv(T_FONT_SIZE)

	font create local_treefnt -family $local_treefnt_family -size $local_treefnt_sz -slant $evv(T_FONT_TYPE)
	font create local_deletefnt -family local_treefnt_family -size $local_treefnt_sz -slant $evv(T_DELETE_TYPE)

	#	Precision setting not required in TK8.0:	otherwise, set tcl_precision (17 = full)

	set d .displaypage
	eval {toplevel $d} -borderwidth $evv(SBDR)
	wm protocol $d WM_DELETE_WINDOW {set pr_design 0}
	wm title $d "Interface Display Style"

	set c [Scrolled_Canvas $d.c -width 860 -height 650 -scrollregion {0 0 1200 	800}]
	set f [frame $c.f -bd 0]
	$c create window 0 0 -anchor nw -window $f

	#ROW 0
	label $f.sys -text "SYSTEM" -font displ_fnt
	set frb [frame $f.frb0]
	label $frb.default -text "DEFAULT FONT  $evv(FONT_FAMILY)  SIZE $evv(FONT_SIZE)" -background $evv(EMPH)
	button $frb.savebtn   -text "Keep new design" -command "set pr_design 1" -font displ_fnt -highlightbackground [option get . background {}]
	button $frb.quitbtn   -text "Forget redesign: Close" -command "set pr_design 0" -font displ_fnt -highlightbackground [option get . background {}]


#
#REMOVED: FEB 2001
#	radiobutton $frb.16 -variable evv(BITRES) -text "16 bit" -value 16 -font  displ_fnt
#	radiobutton $frb.32 -variable evv(BITRES) -text "32 bit" -value 32 -font  displ_fnt
#	pack $frb.blank $frb.16 $frb.32 -side left
#
	pack $frb.default -side left

	pack $frb.quitbtn $frb.savebtn -side right -padx 10

	grid $f.sys  -row 0 -column 0 -sticky w
	grid $f.frb0 -row 0 -column 1 -columnspan 11 -sticky news


	# BLANK COLUMNS 3,7 & 9 (spacing only)
	frame $f.blank1 -width 24
	frame $f.blank2 -width 24
	frame $f.blank3 -width 8
	grid $f.blank1 -column 3 -row 9 -rowspan 19
	grid $f.blank2 -column 7 -row 9 -rowspan 19
	grid $f.blank3 -column 9 -row 9 -rowspan 11

	#ROW 1
	label $f.se -text "DEFAULT EXTENSION\nFOR OUTPUT SNDFILES" -font displ_fnt -width 25 -anchor w
	set frb1 [frame $f.frb1]
	label $f.ssr -text "SAMPLE\nRATES" -font displ_fnt
	set frb1a [frame $f.frb1a]
	grid $f.se    -row 1 -column 0 -columnspan 3 -sticky nws
	grid $f.frb1  -row 1 -column 2 -columnspan 3 -sticky news
	grid $f.ssr   -row 1 -column 5  -columnspan 1 -sticky news
	grid $f.frb1a -row 1 -column 6 -columnspan 6 -sticky news

	foreach ext $evv(SNDFILE_EXTS) {
		radiobutton $frb1$ext  -variable evv(SNDFILE_EXT) -text "$ext" -value  "$ext" -font displ_fnt
		pack $frb1$ext -side left -ipadx 5				;# RWD
	}

	radiobutton $frb1a.all -variable evv(DFLT_SR) -text "all"   -value 0 \
		-font displ_fnt
	radiobutton $frb1a.16  -variable evv(DFLT_SR) -text "16000" -value 16000 \
		-font displ_fnt
	radiobutton $frb1a.22  -variable evv(DFLT_SR) -text "22050" -value 22050 \
		-font displ_fnt
	radiobutton $frb1a.24  -variable evv(DFLT_SR) -text "24000" -value 24000 \
		-font displ_fnt
	radiobutton $frb1a.32  -variable evv(DFLT_SR) -text "32000" -value 32000 \
		-font displ_fnt
	radiobutton $frb1a.44  -variable evv(DFLT_SR) -text "44100" -value 44100 \
		-font displ_fnt
	radiobutton $frb1a.48  -variable evv(DFLT_SR) -text "48000" -value 48000 \
		-font displ_fnt
	pack $frb1a.all $frb1a.16 $frb1a.22 $frb1a.24 $frb1a.32 $frb1a.44 $frb1a.48 -side left -ipadx 5 ;# RWD

	# SPACING LINE (= ROW 2)
	frame $f.spacer0 -bg [option get . foreground {}] -height 1
	grid $f.spacer0 -row 2 -column 0 -columnspan 12 -sticky ew

	#ROW 4

	set ff4 [frame $f.4 -borderwidth $evv(SBDR)]
	grid $f.4 -row 4 -column 0 -columnspan 12 -sticky w
	label $ff4.run -text "RUNNING DISPLAY" -borderwidth $evv(SBDR) -width 25 -font displ_fnt \
		-anchor w
	entry $ff4.ei -textvariable dummy_info    -fg $evv(INF_COLR) -width 15 -state disabled
	entry $ff4.ew -textvariable dummy_warning -fg $evv(WARN_COLR) -width 15 -state disabled
	entry $ff4.ee -textvariable dummy_error   -fg $evv(ERR_COLR) -bg $evv(EMPH)  \
				-width 15 -state disabled
	frame $ff4.sbar -borderwidth $evv(SBDR) -width $evv(PBAR_ENDSIZE) \
							-height 2 -bg $evv(PBAR_ENDCOLOR)			;#	Frame for start of progress-bar
	set ff4bar [frame $ff4.bar -borderwidth $evv(BBDR) -width $evv(PBAR_LENGTH)  -height 2 \
							-bg $evv(PBAR_NOTDONECOLOR)]
	frame $ff4.ebar -borderwidth $evv(BBDR) -width $evv(PBAR_ENDSIZE) -height 2  \
							-bg $evv(PBAR_ENDCOLOR)
	grid $ff4.run $ff4.ei $ff4.ew $ff4.ee $ff4.sbar $ff4.bar $ff4.ebar
	grid $ff4.sbar -sticky ns
	grid $ff4.ebar -sticky ns
	grid $ff4.bar  -sticky ns
	set thislength [expr round($evv(PBAR_LENGTH) / 2)]
	frame $ff4bar.done -width $thislength -height $evv(PBAR_HEIGHT) -bg  $evv(PBAR_DONECOLOR)
	pack propagate $ff4bar false
	pack $ff4bar.done -side left	;#	ProgessBar Itself, fixed to left,and fills height of frame


	#ROW 5

	set ff5 [frame $f.5 -borderwidth $evv(SBDR)]
	grid $f.5 -row 5 -column 0 -columnspan 12 -sticky w
	label $ff5.menu    -text "PROCESS MENU" -borderwidth $evv(SBDR) -width 25  -font displ_fnt \
		-anchor w
	button $ff5.active   -text "active state" 	 -state disabled -bg $evv(ON_COLOR) -font displ_fnt -highlightbackground [option get . background {}]
	button $ff5.disabled -text "disabled state" -state disabled -bg  $evv(OFF_COLOR)  -font displ_fnt -highlightbackground [option get . background {}]
	label $ff5.paramm    -text "PARAMETER MENU" -width 25 -font displ_fnt
	label $ff5.prm     -text "pitch" -width 8 -font displ_fnt
	button $ff5.pitch	  -text $dummy_pitch -state disabled -width 4 -font displ_fnt -highlightbackground [option get . background {}]
	label $ff5.paramd    -text "disabled" -width 11 -font displ_fnt
	button $ff5.pitchd	  -text $dummy_pitch -state disabled -bg $evv(DISABLE_COLOR) -width 4 \
								-font displ_fnt -highlightbackground [option get . background {}]
	grid $ff5.menu $ff5.active $ff5.disabled $ff5.paramm $ff5.prm $ff5.pitch $ff5.paramd $ff5.pitchd

	#ROW 6

	set ff6 [frame $f.6 -borderwidth $evv(SBDR)]
	grid $f.6 -row 6 -column 0 -columnspan 12 -sticky w
	label $ff6.key   -text "INSTRUMENT TREE KEY" -width 25 -font displ_fnt 	 -anchor w
	label $ff6.snd   -text "sound"    -bg $evv(SOUND_TC)    -width 8 -font 	 treefnt
	label $ff6.mono  -text "mono" 	  -bg $evv(MONO_TC)     -width 8 -font 	 treefnt
	label $ff6.anal  -text "spectrum" -bg $evv(ANALYSIS_TC) -width 8 -font 	 treefnt
	label $ff6.pitch -text "pitch"    -bg $evv(PITCH_TC)    -width 8 -font 	 treefnt
	label $ff6.trans -text "transpos" -bg $evv(TRANSPOS_TC) -width 8 -font 	 treefnt
	label $ff6.fmnt  -text "formants" -bg $evv(FORMANT_TC)  -width 8 -font 	 treefnt
	label $ff6.env   -text "envelope" -bg $evv(ENVELOPE_TC) -width 8 -font 	 treefnt
	label $ff6.txt   -text "text"     -bg $evv(TEXT_TC) 	-width 8 -font treefnt
	label $ff6.gap   -text "" 		   -width 4 -font treefnt
	label $ff6.keep  -text "NORMAL"  -width 8 -font treefnt
	label $ff6.del   -text "DELETED" -width 8 -font treedeletefnt
	label $ff6.activ -text "ACTIVE" \
	 -fg $evv(T_ACTIVEFGND) -bg $evv(T_ACTIVEBKGD) 	-width 8 -font treekeyfnt
	grid $ff6.key $ff6.snd $ff6.mono $ff6.anal $ff6.pitch $ff6.trans $ff6.fmnt \
		 $ff6.env $ff6.txt $ff6.gap $ff6.keep $ff6.del $ff6.activ

	# SPACING LINE (= ROW 7)
	frame $f.spacer1 -bg [option get . foreground {}] -height 1
	grid $f.spacer1 -row 7 -column 0 -columnspan 12 -sticky ew

	#ROW 8
	label $f.palet -text "PALETTE" -font displ_fnt -anchor w
	set fpal [frame $f.palframe -borderwidth $evv(SBDR)]
	grid $f.palet -row 8 -column 0 -sticky e
	grid $f.palframe -row 8 -column 1 -columnspan 11 -sticky ew
	radiobutton $fpal.paletred -variable palette -text "red" -value "red" -command GetListofColors  \
		-font displ_fnt
	radiobutton $fpal.paletora -variable palette -text "orange" -value "orange" -command GetListofColors \
		-font displ_fnt
	radiobutton $fpal.paletyel -variable palette -text "yellow" -value "yellow" -command GetListofColors \
		-font displ_fnt
	radiobutton $fpal.paletgre -variable palette -text green -value "green"   -command GetListofColors \
		-font displ_fnt
	radiobutton $fpal.paletblu -variable palette -text blue -value "blue" 	  -command GetListofColors \
		-font displ_fnt
	radiobutton $fpal.paletpur -variable palette -text purple -value "purple" -command GetListofColors \
		-font displ_fnt
	radiobutton $fpal.paletbro -variable palette -text brown -value "brown"   -command GetListofColors \
		-font displ_fnt
	radiobutton $fpal.paletwhi -variable palette -text "offwhite" -value "white" -command GetListofColors \
		-font displ_fnt
	radiobutton $fpal.paletbla -variable palette -text "black:grey"	-value 	   "grey" -command GetListofColors \
		-font displ_fnt
	pack $fpal.paletred $fpal.paletora $fpal.paletyel $fpal.paletgre \
	$fpal.paletblu $fpal.paletpur $fpal.paletbro $fpal.paletwhi $fpal.paletbla -side left -ipadx 5 ;# RWD

	#LISTBOXES for COLORS and FONTS

	set cl [Scrolled_Listbox $f.cl -selectmode single -width 14]
	set fntlist  [Scrolled_Listbox $f.fntlist -selectmode single  -width 14]
	grid $f.cl -row 10 -column 8  -rowspan 6 -sticky news
	grid $f.fntlist  -row 10 -column 10 -rowspan 6 -sticky news

	#ROW 9
	label $f.g      -text "STANDARD FEATURES" -font displ_fnt
	label $f.mtd    -text "MACHINE TREE KEE" -font displ_fnt
	label $f.colors -text "COLORS" -font displ_fnt
	button $f.colz  -text "" -width 4 -command {} -state disabled -highlightbackground [option get . background {}]
	label $f.fnts  -text "FONTS" -font displ_fnt
	label $f.fonz   -text "Font"

	bind $f.cl.list <ButtonRelease-1> {ShowTestColor}
	bind $f.fntlist.list <ButtonRelease-1> {ShowTestFont}

	grid $f.g      -row 9 -column 0 -columnspan 3  -sticky ew
	grid $f.mtd    -row 9 -column 4 -columnspan 3  -sticky ew
	grid $f.colors -row 9 -column 8  -sticky ew
	grid $f.colz   -row 9 -column 9
	grid $f.fnts  -row 9 -column 10 -sticky ew
	grid $f.fonz   -row 9 -column 11

	#ROW 10
	label  $f.fnt    -text "Font" -font displ_fnt
	button $f.fntbtn -text "SET" -command "ResetFont" -font displ_fnt -highlightbackground [option get . background {}]
	label  $f.tfs  	  -text "Font size" -font displ_fnt
	entry  $f.tfse -width 2 -textvariable treefnt_sz
	button $f.tfsb    -text "SET" -command "ResetTreeFontSize $f.tfse" -font   displ_fnt -highlightbackground [option get . background {}]

	grid $f.fnt 	-row 10 -column 0 -columnspan 2  -sticky w
	grid $f.fntbtn	-row 10 -column 2 -sticky news -padx 1
	grid $f.tfs		-row 10 -column 4 -columnspan 2 -sticky w
	grid $f.tfse 	-row 10 -column 5 -sticky ew   -padx 1
	grid $f.tfsb	-row 10 -column 6 -sticky news -padx 1

	#ROW 11
	label  $f.fntsize -text "Font size" -font displ_fnt
	entry  $f.fsze -width 2 -textvariable fnt_sz
	button $f.fszb     -text "SET" -command "ResetFontSize $f.fsze" -font 	  displ_fnt -highlightbackground [option get . background {}]
	label  $f.tabbc    -text "Active button bkgd color" -font displ_fnt
	button $f.tabbcbtn -text "SET" -command "ResetEClr TREE_ACTIVEBKGD" -font displ_fnt -highlightbackground [option get . background {}]

	grid $f.fntsize -row 11 -column 0 -sticky w
	grid $f.fsze	 -row 11 -column 1 -sticky ew   -padx 1
	grid $f.fszb	 -row 11 -column 2 -sticky news -padx 1
	grid $f.tabbc	 -row 11 -column 4 -columnspan 2 -sticky w
	grid $f.tabbcbtn -row 11 -column 6 -sticky news -padx 1

	#ROW 3	 (makes reference to row 11)

	set ff3 [frame $f.3 -borderwidth $evv(SBDR)]
	grid  $f.3 -row 3 -column 0 -columnspan 12 -sticky w
	label $ff3.norm -text "STANDARD FEATURES" -borderwidth $evv(SBDR) -width 25  \
		-font displ_fnt -anchor w
	label $ff3.normal -text "normal" -width 11 \
			-bg [$f cget -background] -fg [$frb.savebtn cget -foreground] \
		 	-font userfnt
	label $ff3.active     -text "active" -borderwidth $evv(SBDR) -width 11 \
			-bg [$frb.savebtn cget -activebackground] \
			-fg [$frb.savebtn cget -activeforeground] -font userfnt
	label $ff3.select -text "select" -borderwidth $evv(SBDR) -width 11 \
			-fg [$fpal.paletbla cget -selectcolor] \
			-bg [option get . selectBackground {}] -font userfnt
	label $ff3.trough -text "trough" -borderwidth $evv(SBDR) -width 11 \
			-bg [$d.c.yscroll cget -troughcolor] -font userfnt
	label $ff3.disabled -text "disabled" -borderwidth $evv(SBDR) -width 11 \
			-fg	[option get . disabledForeground {}] -font userfnt
	label $ff3.emph -text "emphasis" -borderwidth $evv(SBDR) -width 11 \
			-bg $evv(EMPH) -font userfnt
	label $ff3.mark -text "marked state" -borderwidth $evv(SBDR) -width 11 \
			-fg $evv(SPECIAL) -font userfnt
	label $ff3.help -text "help" -borderwidth $evv(SBDR) -width 11 \
			-bg $evv(HELP) -font userfnt
	label $ff3.fquq -text "end session" -borderwidth $evv(SBDR) -width 11 \
			-bg $evv(QUIT_COLOR) -font userfnt
	grid $ff3.norm $ff3.normal $ff3.active $ff3.select $ff3.trough 	$ff3.disabled $ff3.emph $ff3.mark $ff3.help $ff3.fquq

	#ROW 12
	label  $f.bkgd     -text "Background" -font displ_fnt
	button $f.bkgdbtn  -text "SET" -command "ResetClr $d background" -font displ_fnt -highlightbackground [option get . background {}]
	label  $f.tabfc    -text "Active button fgrd color" -font displ_fnt
	button $f.tabfcbtn -text "SET" -command "ResetEClr TREE_ACTIVEFGND" -font displ_fnt -highlightbackground [option get . background {}]

	grid $f.bkgd 	 -row 12 -column 0 -columnspan 2  -sticky w
	grid $f.bkgdbtn	 -row 12 -column 2 -sticky news -padx 1
	grid $f.tabfc	 -row 12 -column 4 -columnspan 2 -sticky w
	grid $f.tabfcbtn -row 12 -column 6 -sticky news -padx 1

	#ROW 13
	label  $f.fgnd    -text "Foreground" -font displ_fnt
	button $f.fgndbtn -text "SET" -command "ResetClr $d foreground" -font  displ_fnt -highlightbackground [option get . background {}]
	label  $f.tkbc    -text "Tree Key background color" -font displ_fnt
	button $f.tkbcbtn -text "SET" -command "ResetEClr NEUTRAL_TC" -font  displ_fnt -highlightbackground [option get . background {}]

	grid $f.fgnd 	-row 13 -column 0 -columnspan 2  -sticky w
	grid $f.fgndbtn	-row 13 -column 2 -sticky news -padx 1
	grid $f.tkbc	-row 13 -column 4 -columnspan 2 -sticky w
	grid $f.tkbcbtn -row 13 -column 6 -sticky news -padx 1

	#ROW 14
	label  $f.abkgd     -text "Active background" -font displ_fnt
	button $f.abkgdbtn  -text "SET" -command "ResetClr $d activeBackground" -font displ_fnt -highlightbackground [option get . background {}]
	label  $f.tsnd    -text "Tree soundfile color" -font displ_fnt
	button $f.tsndbtn -text "SET" -command "ResetEClr SOUND_TC" -font displ_fnt -highlightbackground [option get . background {}]

	grid $f.abkgd 	 -row 14 -column 0 -columnspan 2  -sticky w
	grid $f.abkgdbtn -row 14 -column 2 -sticky news -padx 1
	grid $f.tsnd	 -row 14 -column 4 -columnspan 2 -sticky w
	grid $f.tsndbtn  -row 14 -column 6 -sticky news -padx 1

	#ROW 15
	label  $f.afgnd     -text "Active foreground" -font displ_fnt
	button $f.afgndbtn  -text "SET" -command "ResetClr $d activeForeground" -font displ_fnt -highlightbackground [option get . background {}]
	label  $f.tmon 	   -text "Tree mono soundfile color" -font displ_fnt
	button $f.tmonbtn  -text "SET" -command "ResetEClr MONO_TC" -font displ_fnt -highlightbackground [option get . background {}]

	grid $f.afgnd 	 -row 15 -column 0 -columnspan 2  -sticky w
	grid $f.afgndbtn -row 15 -column 2 -sticky news -padx 1
	grid $f.tmon     -row 15 -column 4  -columnspan 2 -sticky w
	grid $f.tmonbtn  -row 15 -column 6  -sticky news -padx 1

	#ROW 16
	label  $f.asc     -text "Selection color" -font displ_fnt
	button $f.ascbtn  -text "SET" -command "ResetClr $d selectColor" -font 	displ_fnt -highlightbackground [option get . background {}]
	label  $f.tana    -text "Tree spectrum file color" -font displ_fnt
	button $f.tanabtn -text "SET" -command "ResetEClr ANALYSIS_TC" -font 	displ_fnt -highlightbackground [option get . background {}]
	label  $f.rststa  -text "RESTORE STATE" -font displ_fnt

	grid $f.asc 	-row 16 -column 0 -columnspan 2  -sticky w
	grid $f.ascbtn  -row 16 -column 2 -sticky news -padx 1
	grid $f.tana   	-row 16 -column 4 -columnspan 2 -sticky w
	grid $f.tanabtn -row 16 -column 6 -sticky news -padx 1
	grid $f.rststa	-row 16 -column 8 -columnspan 3

	#ROW 17
	label  $f.asb      -text "Selection background" -font displ_fnt
	button $f.asbbtn   -text "SET" -command "ResetClr $d selectBackground" 	-font displ_fnt -highlightbackground [option get . background {}]
	label  $f.tpch     -text "Tree pitchfile color" -font displ_fnt
	button $f.tpchbtn  -text "SET" -command "ResetEClr PITCH_TC" -font 	displ_fnt -highlightbackground [option get . background {}]
	label  $f.rcdpd    -text "Restore CDP defaults" -font displ_fnt
	button $f.rcdpdbtn -text "OK" -width 3 -command "RestoreCDPDefaults ;  ResetCDPInterface" -font displ_fnt -highlightbackground [option get . background {}]

	grid $f.asb 	 -row 17 -column 0 -columnspan 2  -sticky w
	grid $f.asbbtn   -row 17 -column 2 -sticky news -padx 1
	grid $f.tpch	 -row 17 -column 4 -columnspan 2 -sticky w
	grid $f.tpchbtn  -row 17 -column 6 -sticky news -padx 1
	grid $f.rcdpd    -row 17 -column 8  -columnspan 3 -sticky w
	grid $f.rcdpdbtn -row 17 -column 11 -sticky nws -padx 1

	#ROW 18
	label  $f.atc     -text "Trough color" -font displ_fnt
	button $f.atcbtn  -text "SET" -command "ResetClr $d troughColor" -font displ_fnt -highlightbackground [option get . background {}]
	label  $f.ttrn    -text "Tree transpose file color" -font displ_fnt
	button $f.ttrnbtn -text "SET" -command "ResetEClr TRANSPOS_TC" -font   displ_fnt -highlightbackground [option get . background {}]
	label  $f.rcd     -text "Restore current defaults" -font displ_fnt
	button $f.rcdbtn  -text "OK" -width 3 -command "RestoreUserEnvironment 1 ; ResetInterface" -font displ_fnt -highlightbackground [option get . background {}]

	grid $f.atc 	-row 18 -column 0 -columnspan 2  -sticky w
	grid $f.atcbtn  -row 18 -column 2 -sticky news -padx 1
	grid $f.ttrn	-row 18 -column 4 -columnspan 2 -sticky w
	grid $f.ttrnbtn -row 18 -column 6 -sticky news -padx 1
	grid $f.rcd 	-row 18 -column 8 -columnspan 3 -sticky w
	grid $f.rcdbtn	-row 18 -column 11 -sticky nws -padx 1

	#ROW 19
	label  $f.dfc     -text "Disabled foreground" -font displ_fnt
	button $f.dfcbtn  -text "SET" -command "ResetClr $d disabledForeground" -font displ_fnt -highlightbackground [option get . background {}]
	label  $f.tfmt    -text "Tree formant file color" -font displ_fnt
	button $f.tfmtbtn -text "SET" -command "ResetEClr FORMANT_TC" -font displ_fnt -highlightbackground [option get . background {}]
	label  $f.handq   -text "HELP, EMPH & QUIT COLORS" -font displ_fnt

	grid $f.dfc 	-row 19 -column 0 -columnspan 2  -sticky w
	grid $f.dfcbtn  -row 19 -column 2 -sticky news -padx 1
	grid $f.tfmt	-row 19 -column 4 -columnspan 2 -sticky w
	grid $f.tfmtbtn -row 19 -column 6 -sticky news -padx 1
	grid $f.handq   -row 19 -column 8 -columnspan 3 -sticky ew

	#ROW 20
	label  $f.prd     -text "PROCESS RUN DISPLAY" -font displ_fnt
	label  $f.tenv    -text "Tree envelope file color" -font displ_fnt
	button $f.tenvbtn -text "SET" -command "ResetEClr ENVELOPE_TC" -font  displ_fnt -highlightbackground [option get . background {}]
	label  $f.hhc     -text "Help information color" -font displ_fnt
	button $f.hhcbtn  -text "SET" -command "ResetEClr HELP_COLOR" -font displ_fnt -highlightbackground [option get . background {}]

	grid $f.prd 	-row 20 -column 0 -columnspan 3 -sticky ew
	grid $f.tenv	-row 20 -column 4 -columnspan 2 -sticky w
	grid $f.tenvbtn -row 20 -column 6 -sticky news -padx 1
	grid $f.hhc     -row 20 -column 8  -columnspan 3 -sticky w
	grid $f.hhcbtn  -row 20 -column 11 -sticky nws -padx 1

	#ROW 21
	label  $f.itc     -text "Information text color" -font displ_fnt
	button $f.itcbtn  -text "SET" -command "ResetEClr INF_COLR" -font displ_fnt -highlightbackground [option get . background {}]
	label  $f.ttxt 	  -text "Tree textfile color" -font displ_fnt
	button $f.ttxtbtn -text "SET" -command "ResetEClr TEXT_TC" -font displ_fnt -highlightbackground [option get . background {}]
	label  $f.hhcs    -text "Emphasis color" -font displ_fnt
	button $f.hhcsbtn -text "SET" -command "ResetEClr EMPH" -font displ_fnt -highlightbackground [option get . background {}]

	grid $f.itc     -row 21 -column 0  -columnspan 2 -sticky w
	grid $f.itcbtn  -row 21 -column 2  -sticky news -padx 1
	grid $f.ttxt    -row 21 -column 4  -columnspan 2 -sticky w
	grid $f.ttxtbtn -row 21 -column 6  -sticky news -padx 1
	grid $f.hhcs    -row 21 -column 8  -columnspan 3 -sticky w
	grid $f.hhcsbtn -row 21 -column 11 -sticky nws -padx 1

	#ROW 22
	label  $f.wtc     -text "Warning text color" -font displ_fnt
	button $f.wtcbtn  -text "SET" -command "ResetEClr WARN_COLR" -font displ_fnt -highlightbackground [option get . background {}]
	label  $f.mark    -text "Special State" -font displ_fnt
	button $f.markbtn -text "SET" -command "ResetEClr SPECIAL_STATE" -font displ_fnt -highlightbackground [option get . background {}]

	grid $f.wtc     -row 22 -column 0  -columnspan 2 -sticky w
	grid $f.wtcbtn  -row 22 -column 2  -sticky news -padx 1
	grid $f.mark    -row 22 -column 8  -columnspan 3 -sticky w
	grid $f.markbtn -row 22 -column 11 -sticky nws -padx 1

	#ROW 23
	label  $f.etc     -text "Error text color" -font displ_fnt
	button $f.etcbtn  -text "SET" -command "ResetEClr ERR_COLR" -font displ_fnt -highlightbackground [option get . background {}]
	label  $f.quq 	  -text "End Session button color" -font displ_fnt
	button $f.quqbtn  -text "SET" -command "ResetEClr QUIT_COLOR" -font displ_fnt -highlightbackground [option get . background {}]

	grid $f.etc     -row 23 -column 0  -columnspan 2 -sticky w
	grid $f.etcbtn  -row 23 -column 2  -sticky news -padx 1
	grid $f.quq	    -row 23 -column 8 -columnspan 3 -sticky w
	grid $f.quqbtn 	-row 23 -column 11 -sticky nws -padx 1

	#ROW 24
	label  $f.pbc    -text "Progress bar color" -font displ_fnt
	button $f.pbcbtn -text "SET" -command "ResetEClr PBAR_DONECOLOR" -font displ_fnt -highlightbackground [option get . background {}]
	label  $f.pm     -text "PROCESS MENU" -font displ_fnt
	label  $f.pw     -text "PARAMETER MENU" -font displ_fnt

	grid $f.pbc    -row 24 -column 0  -columnspan 2 -sticky w
	grid $f.pbcbtn -row 24 -column 2  -sticky news -padx 1
	grid $f.pw     -row 24 -column 4 -columnspan 3  -sticky ew
	grid $f.pm 	   -row 24 -column 8 -columnspan 3

	#ROW 25
	label  $f.pbb    	-text "Progress bar background" -font displ_fnt
	button $f.pbbbtn 	-text "SET" -command "ResetEClr PBAR_NOTDONECOLOR" -font displ_fnt -highlightbackground [option get . background {}]
	label  $f.dpbutc    -text "Disabled pitchbutton color" -font displ_fnt
	button $f.dpbutcbtn -text "SET" -command "ResetEClr DISABLE_COLOR" -font displ_fnt -highlightbackground [option get . background {}]
	label  $f.apc    	-text "Active process color" -font displ_fnt
	button $f.apcbtn 	-text "SET" -command "ResetEClr ON_COLOR" -font displ_fnt -highlightbackground [option get . background {}]

	grid $f.pbb		  -row 25 -column 0 -columnspan 2 -sticky w
	grid $f.pbbbtn	  -row 25 -column 2 -sticky news -padx 1
	grid $f.dpbutc    -row 25 -column 4 -columnspan 3 -sticky w
	grid $f.dpbutcbtn -row 25 -column 6 -sticky nws -padx 1
	grid $f.apc    	  -row 25 -column 8  -columnspan 3 -sticky w
	grid $f.apcbtn 	  -row 25 -column 11 -sticky nws -padx 1

	#ROW 26
	label  $f.pbe       -text "Progress bar endstops" -font displ_fnt
	button $f.pbebtn    -text "SET" -command "ResetEClr PBAR_ENDCOLOR" -font displ_fnt -highlightbackground [option get . background {}]
	label  $f.dpc       -text "Disabled process color" -font displ_fnt
	button $f.dpcbtn 	-text "SET" -command "ResetEClr OFF_COLOR" -font displ_fnt -highlightbackground [option get . background {}]

	grid $f.pbe       -row 26 -column 0 -columnspan 2 -sticky w
	grid $f.pbebtn    -row 26 -column 2 -sticky news -padx 1
	grid $f.dpc    	  -row 26 -column 8  -columnspan 3 -sticky w
	grid $f.dpcbtn 	  -row 26 -column 11 -sticky nws -padx 1

	pack $d.c -fill both -expand true

	foreach ffnt [font families] {
		$fntlist insert end $ffnt
	}
	set palette grey
	GetListofColors
	set pr_design 0

	set dummy_info 	  "Information :"
	set dummy_warning "Warning !!! :"
	set dummy_error   "Error Error :"

	ForceVal $ff4.ei $dummy_info
	ForceVal $ff4.ew $dummy_warning
	ForceVal $ff4.ee $dummy_error

	if {[info exists uv(fnt_sz)]} {
		set fnt_sz $uv(fnt_sz)
	} else {
		set fnt_sz $evv(FONT_SIZE)
	}

	raise $d
	My_Grab 1 $d pr_design
	tkwait variable pr_design
	if {$pr_design} {
		DoReset
	} else {
		RestoreUserEnvironment 0
		set user_resource_changed 0
	}
	My_Release_to_Dialog $d
	destroy $d
	set evv(REDESIGN) 0
}

#------ Display selected color or font

proc ShowTestColor {} {
	global cl
	set i [$cl curselection]
	if {[string length $i] <= 0} {
		return
	}
	.displaypage.c.canvas.f.colz config -bg [$cl get $i]
}

proc ShowTestFont {} {
	global fntlist
	set i [$fntlist curselection]
	if {[string length $i] <= 0} {
		return
	}
	font config testfnt -family [$fntlist get $i]
	.displaypage.c.canvas.f.fonz config -font testfnt
}

#------ Change overall font used in display

proc ResetFont {} {
	global fntlist ff3 local_fnt_family local_fnt_sz user_resource_changed

	set i [$fntlist curselection]
	if {[string length $i] <= 0} {
		Inf "No font type selected."
		return
	}
	set local_fnt_family [$fntlist get $i]

	font config local_userfnt -family $local_fnt_family -size $local_fnt_sz

	$ff3.normal   config -font local_userfnt
	$ff3.active   config -font local_userfnt
	$ff3.select   config -font local_userfnt
	$ff3.trough   config -font local_userfnt
	$ff3.disabled config -font local_userfnt
	set user_resource_changed 1
}

#------ Change overall fntsize used in display, except in TREE & in design dialog

proc ResetFontSize {f} {
	global evv inspage insviewpage displaypage fnt_sz user_resource_changed ff3
	global local_fnt_family local_fnt_sz

	set fnt_sz [FixTxt $fnt_sz "font size"]
	if {[string length $fnt_sz] <= 0} {
		ForceVal $f $fnt_sz
		return
	}
	if {![IsNumeric $fnt_sz]} {
		Inf "Numeric vals only for fntsize."
		set fnt_sz ""
		ForceVal $f $fnt_sz
		return
	} elseif {$fnt_sz > $evv(MAX_FONTSIZE)} {
		Inf "Font size too large."
		return
	} elseif {$fnt_sz < $evv(MIN_FONTSIZE)} {
		Inf "Font size too small."
		return
	}
	set local_fnt_sz $fnt_sz

	font config local_userfnt -family $local_fnt_family -size $local_fnt_sz

	$ff3.normal   config -font local_userfnt
	$ff3.active   config -font local_userfnt
	$ff3.select   config -font local_userfnt
	$ff3.trough   config -font local_userfnt
	$ff3.disabled config -font local_userfnt

	set user_resource_changed 1
}

#------ Change fntsize used in tree

proc ResetTreeFontSize {f} {
	global inspage insviewpage displaypage treefnt_sz evv ff6 user_resource_changed
	global local_treefnt
	global local_treefnt_family local_treefnt_sz

	set treefnt_sz [FixTxt $treefnt_sz "tree fntsize"]
	if {[string length $treefnt_sz] <= 0} {
		ForceVal $f $treefnt_sz
		return
	}
	if {![IsNumeric $treefnt_sz]} {
		Inf "Numeric vals only for fntsize."
		set treefnt_sz ""
		ForceVal $f $treefnt_sz
		return
	} elseif {$treefnt_sz > $evv(MAX_TREE_FONT_SIZE)} {
		Inf "Tree font size too large."
		return
	} elseif {$treefnt_sz < $evv(MIN_TREE_FONT_SIZE)} {
		Inf "Tree font size too small."
		return
	}
	set local_treefnt_sz $treefnt_sz

	font config local_treefnt -family $local_treefnt_family -size $local_treefnt_sz -slant $evv(T_FONT_TYPE)
	font config local_deletefnt -family $local_treefnt_family -size $local_treefnt_sz -slant $evv(T_DELETE_TYPE)

	$ff6.key   config -font local_treefnt
	$ff6.snd   config -font local_treefnt
	$ff6.mono  config -font local_treefnt
	$ff6.anal  config -font local_treefnt
	$ff6.pitch config -font local_treefnt
	$ff6.trans config -font local_treefnt
	$ff6.fmnt  config -font local_treefnt
	$ff6.env   config -font local_treefnt
	$ff6.txt   config -font local_treefnt
	$ff6.gap   config -font local_treefnt
	$ff6.keep  config -font local_treefnt
	$ff6.del   config -font local_deletefnt
	$ff6.activ config -font local_treefnt

	set user_resource_changed 1
}

#------ Reset color of specified item, in the resources

proc ResetClr {d item} {
	global cl displaypage user_resource_changed uv ff3
	set i [$cl curselection]
	if {[string length $i] <= 0} {
		Inf "No color selected."
		return
	}
	set new_color [$cl get $i]

	option add *$item $new_color									;#	make global change to colors

								;#	Alter dummy display: reinstate new color on	relevant display item
	switch -- $item {
		"background" 		 {$ff3.normal  config -bg  $new_color}
		"foreground" 		 {$ff3.normal  config -fg  $new_color}
		"activeBackground"	 {$ff3.active  config -bg  $new_color}
		"activeForeground" 	 {$ff3.active  config -fg  $new_color}
		"selectColor" 		 {$ff3.select  config -bg  $new_color}
		"troughColor" 		 {$ff3.trough  config -bg  $new_color}
		"disabledForeground" {$ff3.disabled config -fg $new_color}
	}
	set item [string tolower $item]
	set uv($item) $new_color
	set user_resource_changed 1
}

#------ Reset color of specified item, in the environment

proc ResetEClr {item} {
	global cl displaypage evv ff3 ff4 ff5 ff6 user_resource_changed
	set i [$cl curselection]
	if {[string length $i] <= 0} {
		Inf "No color selected."
		return
	}
	set evv($item) [$cl get $i]
								;#	Alter dummy display
	switch -- $item {
		"ON_COLOR"			 {$ff5.active   config -bg $evv(ON_COLOR)}
		"OFF_COLOR"			 {$ff5.disabled config -bg $evv(OFF_COLOR)}
		"HELP_COLOR"		 {$ff3.help	 	config -bg $evv(HELP)}
		"QUIT_COLOR"		 {$ff3.fquq 	config -bg $evv(QUIT_COLOR)}
		"EMPH"			 {
							  $ff3.emph 	config -bg $evv(EMPH)
							  $ff4.ee 		config -bg $evv(EMPH)
							 }
		"SPECIAL_STATE"		 {$ff3.mark 	config -fg $evv(SPECIAL)}
		"DISABLE_COLOR"		 {$ff5.pitchd   config -bg $evv(DISABLE_COLOR)}
		"INF_COLR"	 {$ff4.ei	    config -fg $evv(INF_COLR)}
		"WARN_COLR"	 {$ff4.ew	    config -fg $evv(WARN_COLR)}
		"ERR_COLR"	 {$ff4.ee	    config -fg $evv(ERR_COLR)}
		"PBAR_DONECOLOR"	 {$ff4.bar.done config -bg $evv(PBAR_DONECOLOR)}
		"PBAR_NOTDONECOLOR"	 {$ff4.bar		config -bg $evv(PBAR_NOTDONECOLOR)}
		"PBAR_ENDCOLOR"		 {$ff4.ebar	 	config -bg $evv(PBAR_ENDCOLOR)}
		"TREE_ACTIVEBKGD"	 {$ff6.activ    config -bg $evv(T_ACTIVEBKGD)}
		"TREE_ACTIVEFGND"	 {$ff6.activ    config -fg $evv(T_ACTIVEFGND)}
		"NEUTRAL_TC"  {
							  $ff6.key      config -bg $evv(NEUTRAL_TC)
							  $ff6.gap      config -bg $evv(NEUTRAL_TC)
							 }
		"SOUND_TC"	  {$ff6.snd   config -bg $evv(SOUND_TC)}
		"ANALYSIS_TC" {$ff6.anal  config -bg $evv(ANALYSIS_TC)}
		"PITCH_TC"	  {$ff6.pitch config -bg $evv(PITCH_TC)}
		"TRANSPOS_TC" {$ff6.trans config -bg $evv(TRANSPOS_TC)}
		"FORMANT_TC"  {$ff6.fmnt  config -bg $evv(FORMANT_TC)}
		"ENVELOPE_TC" {$ff6.env	  config -bg $evv(ENVELOPE_TC)}
		"MONO_TC"	  {$ff6.mono  config -bg $evv(MONO_TC)}
		"TEXT_TC"	  {$ff6.txt	  config -bg $evv(TEXT_TC)}
	}
	set user_resource_changed 1
}

#------ Post list of colors, for a given palette, in color list

proc GetListofColors {} {
	global cl palette
	set c $cl
	$cl delete 0 end
	switch -- $palette {
		blue {
		    $cl insert end "aliceblue"
		    $cl insert end "aquamarine"
		    $cl insert end "aquamarine1"
		    $cl insert end "aquamarine2"
		    $cl insert end "aquamarine3"
		    $cl insert end "aquamarine4"
		    $cl insert end "azure"
		    $cl insert end "azure1"
		    $cl insert end "azure2"
		    $cl insert end "azure3"
		    $cl insert end "azure4"
		    $cl insert end "blue"
		    $cl insert end "blue1"
		    $cl insert end "blue2"
		    $cl insert end "blue3"
		    $cl insert end "blue4"
		    $cl insert end "BlueViolet"
		    $cl insert end "CadetBlue"
		    $cl insert end "CadetBlue1"
		    $cl insert end "CadetBlue2"
		    $cl insert end "CadetBlue3"
		    $cl insert end "CadetBlue4"
		    $cl insert end "CornflowerBlue"
		    $cl insert end "cyan"
		    $cl insert end "cyan1"
		    $cl insert end "cyan2"
		    $cl insert end "cyan3"
		    $cl insert end "cyan4"
		    $cl insert end "DarkCyan"
		    $cl insert end "DarkBlue"
		    $cl insert end "DarkSlateBlue"
		    $cl insert end "DarkTurquoise"
		    $cl insert end "DeepSkyBlue"
		    $cl insert end "DeepSkyBlue1"
		    $cl insert end "DeepSkyBlue2"
		    $cl insert end "DeepSkyBlue3"
		    $cl insert end "DeepSkyBlue4"
		    $cl insert end "gainsboro"
		    $cl insert end "LightCyan"
		    $cl insert end "LightCyan1"
		    $cl insert end "LightCyan2"
		    $cl insert end "LightCyan3"
		    $cl insert end "LightCyan4"
		    $cl insert end "LightSkyBlue"
		    $cl insert end "LightSlateBlue"
		    $cl insert end "LightSteelBlue"
		    $cl insert end "LightBlue"
		    $cl insert end "LightBlue1"
		    $cl insert end "LightBlue2"
		    $cl insert end "LightBlue3"
		    $cl insert end "LightBlue4"
		    $cl insert end "MediumAquamarine"
		    $cl insert end "MediumBlue"
		    $cl insert end "MediumSlateBlue"
		    $cl insert end "MediumTurquoise"
		    $cl insert end "MidnightBlue"
		    $cl insert end "navy"
		    $cl insert end "NavyBlue"
		    $cl insert end "paleturquoise"
		    $cl insert end "PaleTurquoise1"
		    $cl insert end "PaleTurquoise2"
		    $cl insert end "PaleTurquoise3"
		    $cl insert end "PaleTurquoise4"
		    $cl insert end "PowderBlue"
		    $cl insert end "RoyalBlue"
		    $cl insert end "RoyalBlue1"
		    $cl insert end "RoyalBlue2"
		    $cl insert end "RoyalBlue3"
		    $cl insert end "RoyalBlue4"
		    $cl insert end "skyblue"
		    $cl insert end "SkyBlue1"
		    $cl insert end "SkyBlue2"
		    $cl insert end "SkyBlue3"
		    $cl insert end "SkyBlue4"
		    $cl insert end "SlateBlue"
		    $cl insert end "SlateBlue1"
		    $cl insert end "SlateBlue2"
		    $cl insert end "SlateBlue3"
		    $cl insert end "SlateBlue4"
		    $cl insert end "SteelBlue"
		    $cl insert end "SteelBlue1"
		    $cl insert end "SteelBlue2"
		    $cl insert end "SteelBlue3"
		    $cl insert end "SteelBlue4"
		    $cl insert end "turquoise"
		    $cl insert end "turquoise1"
		    $cl insert end "turquoise2"
		    $cl insert end "turquoise3"
		    $cl insert end "turquoise4"
		}
		white {
		    $cl insert end "AntiqueWhite"
		    $cl insert end "AntiqueWhite1"
		    $cl insert end "AntiqueWhite2"
		    $cl insert end "AntiqueWhite3"
		    $cl insert end "AntiqueWhite4"
		    $cl insert end "beige"
		    $cl insert end "cornsilk"
		    $cl insert end "cornsilk1"
		    $cl insert end "cornsilk2"
		    $cl insert end "cornsilk3"
		    $cl insert end "cornsilk4"
		    $cl insert end "FloralWhite"
		    $cl insert end "GhostWhite"
		    $cl insert end "ivory"
		    $cl insert end "ivory1"
		    $cl insert end "ivory2"
		    $cl insert end "ivory3"
		    $cl insert end "ivory4"
		    $cl insert end "LightCoral"
		    $cl insert end "linen"
		    $cl insert end "NavajoWhite"
		    $cl insert end "NavajoWhite1"
		    $cl insert end "NavajoWhite2"
		    $cl insert end "NavajoWhite3"
		    $cl insert end "NavajoWhite4"
		    $cl insert end "MintCream"
		    $cl insert end "OldLace"
		    $cl insert end "seashell"
		    $cl insert end "seashell1"
		    $cl insert end "seashell2"
		    $cl insert end "seashell3"
		    $cl insert end "seashell4"
		    $cl insert end "snow"
		    $cl insert end "snow1"
		    $cl insert end "snow2"
		    $cl insert end "snow3"
		    $cl insert end "snow4"
		    $cl insert end "white"
		    $cl insert end "WhiteSmoke"
		}
		brown {
		    $cl insert end "bisque"
		    $cl insert end "bisque1"
		    $cl insert end "bisque2"
		    $cl insert end "bisque3"
		    $cl insert end "bisque4"
		    $cl insert end "BlanchedAlmond"
		    $cl insert end "brown"
		    $cl insert end "brown1"
		    $cl insert end "brown2"
		    $cl insert end "brown3"
		    $cl insert end "brown4"
		    $cl insert end "burlywood"
		    $cl insert end "burlywood1"
		    $cl insert end "burlywood2"
		    $cl insert end "burlywood3"
		    $cl insert end "burlywood4"
		    $cl insert end "chocolate"
		    $cl insert end "chocolate1"
		    $cl insert end "chocolate2"
		    $cl insert end "chocolate3"
		    $cl insert end "chocolate4"
		    $cl insert end "DarkKhaki"
		    $cl insert end "khaki"
		    $cl insert end "khaki1"
		    $cl insert end "khaki2"
		    $cl insert end "khaki3"
		    $cl insert end "khaki4"
		    $cl insert end "moccasin"
		    $cl insert end "RosyBrown"
		    $cl insert end "RosyBrown1"
		    $cl insert end "RosyBrown2"
		    $cl insert end "RosyBrown3"
		    $cl insert end "RosyBrown4"
		    $cl insert end "SaddleBrown"
		    $cl insert end "SandyBrown"
		    $cl insert end "sienna"
		    $cl insert end "sienna1"
		    $cl insert end "sienna2"
		    $cl insert end "sienna3"
		    $cl insert end "sienna4"
		    $cl insert end "tan"
		    $cl insert end "tan1"
		    $cl insert end "tan2"
		    $cl insert end "tan3"
		    $cl insert end "tan4"
		    $cl insert end "wheat"
		    $cl insert end "wheat1"
		    $cl insert end "wheat2"
		    $cl insert end "wheat3"
		    $cl insert end "wheat4"
		}
		green {
			$cl insert end "chartreuse"
		    $cl insert end "chartreuse1"
		    $cl insert end "chartreuse2"
			$cl insert end "chartreuse3"
		    $cl insert end "chartreuse4"
		    $cl insert end "DarkGreen"
			$cl insert end "DarkOliveGreen"
		    $cl insert end "DarkOliveGreen"
		    $cl insert end "DarkOliveGreen1"
		    $cl insert end "DarkOliveGreen2"
		    $cl insert end "DarkOliveGreen3"
		    $cl insert end "DarkOliveGreen4"
		    $cl insert end "DarkSeaGreen"
		    $cl insert end "DarkSeaGreen"
		    $cl insert end "DarkSeaGreen1"
		    $cl insert end "DarkSeaGreen2"
		    $cl insert end "DarkSeaGreen3"
		    $cl insert end "DarkSeaGreen4"
		    $cl insert end "ForestGreen"
		    $cl insert end "green"
		    $cl insert end "green1"
		    $cl insert end "green2"
		    $cl insert end "green3"
		    $cl insert end "green4"
		    $cl insert end "GreenYellow"
		    $cl insert end "honeydew"
		    $cl insert end "honeydew1"
		    $cl insert end "honeydew2"
		    $cl insert end "honeydew3"
		    $cl insert end "honeydew4"
		    $cl insert end "LawnGreen"
		    $cl insert end "LightGreen"
		    $cl insert end "LimeGreen"
		    $cl insert end "OliveDrab"
		    $cl insert end "OliveDrab1"
		    $cl insert end "OliveDrab2"
		    $cl insert end "OliveDrab3"
		    $cl insert end "OliveDrab4"
		    $cl insert end "palegreen"
		    $cl insert end "PaleGreen1"
		    $cl insert end "PaleGreen2"
		    $cl insert end "PaleGreen3"
		    $cl insert end "PaleGreen4"
		    $cl insert end "seagreen"
		    $cl insert end "MediumSeaGreen"
		    $cl insert end "LightSeaGreen"
		    $cl insert end "SeaGreen1"
		    $cl insert end "SeaGreen2"
		    $cl insert end "SeaGreen3"
		    $cl insert end "SeaGreen4"
		    $cl insert end "SpringGreen"
		    $cl insert end "MediumSpringGreen"
		    $cl insert end "SpringGreen1"
		    $cl insert end "SpringGreen2"
		    $cl insert end "SpringGreen3"
		    $cl insert end "SpringGreen4"
		    $cl insert end "yellowgreen"
		}
		yellow {
		    $cl insert end "gold"
		    $cl insert end "gold1"
		    $cl insert end "gold2"
		    $cl insert end "gold3"
		    $cl insert end "gold4"
		    $cl insert end "goldenrod"
		    $cl insert end "goldenrod1"
		    $cl insert end "goldenrod2"
		    $cl insert end "goldenrod3"
		    $cl insert end "goldenrod4"
		    $cl insert end "LightGoldenrod"
		    $cl insert end "LightGoldenrod1"
		    $cl insert end "LightGoldenrod2"
		    $cl insert end "LightGoldenrod3"
		    $cl insert end "LightGoldenrod4"
		    $cl insert end "PaleGoldenrod"
		    $cl insert end "LightGoldenrodYellow"
		    $cl insert end "darkGoldenrod"
		    $cl insert end "DarkGoldenrod1"
		    $cl insert end "DarkGoldenrod2"
		    $cl insert end "DarkGoldenrod3"
		    $cl insert end "DarkGoldenrod4"
		    $cl insert end "LemonChiffon"
		    $cl insert end "LemonChiffon1"
		    $cl insert end "LemonChiffon2"
		    $cl insert end "LemonChiffon3"
		    $cl insert end "LemonChiffon4"
		    $cl insert end "LightYellow"
		    $cl insert end "yellow"
		    $cl insert end "yellow1"
		    $cl insert end "yellow2"
		    $cl insert end "yellow3"
		    $cl insert end "yellow4"
		}
		red {
		    $cl insert end "coral"
		    $cl insert end "coral1"
		    $cl insert end "coral2"
		    $cl insert end "coral3"
		    $cl insert end "coral4"
		    $cl insert end "firebrick"
		    $cl insert end "firebrick1"
		    $cl insert end "firebrick2"
		    $cl insert end "firebrick3"
		    $cl insert end "firebrick4"
		    $cl insert end "indian red"
		    $cl insert end "IndianRed1"
		    $cl insert end "IndianRed2"
		    $cl insert end "IndianRed3"
		    $cl insert end "IndianRed4"
		    $cl insert end "maroon"
		    $cl insert end "maroon1"
		    $cl insert end "maroon2"
		    $cl insert end "maroon3"
		    $cl insert end "maroon4"
		    $cl insert end "pink"
		    $cl insert end "pink1"
		    $cl insert end "pink2"
		    $cl insert end "pink3"
		    $cl insert end "pink4"
		    $cl insert end "DeepPink"
		    $cl insert end "DeepPink1"
		    $cl insert end "DeepPink2"
		    $cl insert end "DeepPink3"
		    $cl insert end "DeepPink4"
		    $cl insert end "lightpink"
		    $cl insert end "hotpink"
		    $cl insert end "HotPink1"
		    $cl insert end "HotPink2"
		    $cl insert end "HotPink3"
		    $cl insert end "HotPink4"
		    $cl insert end "red"
		    $cl insert end "red1"
		    $cl insert end "red2"
		    $cl insert end "red3"
		    $cl insert end "red4"
		    $cl insert end "dark red"
		    $cl insert end "MistyRose"
		    $cl insert end "MistyRose1"
		    $cl insert end "MistyRose2"
		    $cl insert end "MistyRose3"
		    $cl insert end "MistyRose4"
		    $cl insert end "salmon"
		    $cl insert end "salmon1"
		    $cl insert end "salmon2"
		    $cl insert end "salmon3"
		    $cl insert end "salmon4"
		    $cl insert end "LightSalmon"
		    $cl insert end "DarkSalmon"
		    $cl insert end "tomato"
		    $cl insert end "tomato1"
		    $cl insert end "tomato2"
		    $cl insert end "tomato3"
		    $cl insert end "tomato4"
		}
		orange {
		    $cl insert end "orange"
		    $cl insert end "orange1"
		    $cl insert end "orange2"
		    $cl insert end "orange3"
		    $cl insert end "orange4"
		    $cl insert end "DarkOrange"
		    $cl insert end "DarkOrange1"
		    $cl insert end "DarkOrange2"
		    $cl insert end "DarkOrange3"
		    $cl insert end "DarkOrange4"
		    $cl insert end "orangered"
		    $cl insert end "OrangeRed1"
		    $cl insert end "OrangeRed2"
		    $cl insert end "OrangeRed3"
		    $cl insert end "OrangeRed4"
		}
		purple {
		    $cl insert end "DarkMagenta"
		    $cl insert end "DarkOrchid"
		    $cl insert end "DarkOrchid1"
		    $cl insert end "DarkOrchid2"
		    $cl insert end "DarkOrchid3"
		    $cl insert end "DarkOrchid4"
		    $cl insert end "lavenderblush"
		    $cl insert end "LavenderBlush1"
		    $cl insert end "LavenderBlush2"
		    $cl insert end "LavenderBlush3"
		    $cl insert end "LavenderBlush4"
		    $cl insert end "magenta"
		    $cl insert end "magenta1"
		    $cl insert end "magenta2"
		    $cl insert end "magenta3"
		    $cl insert end "magenta4"
		    $cl insert end "MediumOrchid"
		    $cl insert end "MediumOrchid1"
		    $cl insert end "MediumOrchid2"
		    $cl insert end "MediumOrchid3"
		    $cl insert end "MediumOrchid4"
		    $cl insert end "orchid"
		    $cl insert end "orchid1"
		    $cl insert end "orchid2"
		    $cl insert end "orchid3"
		    $cl insert end "orchid4"
		    $cl insert end "orchid"
		    $cl insert end "orchid1"
		    $cl insert end "orchid2"
		    $cl insert end "orchid3"
		    $cl insert end "orchid4"
		    $cl insert end "plum"
		    $cl insert end "plum1"
		    $cl insert end "plum2"
		    $cl insert end "plum3"
		    $cl insert end "plum4"
		    $cl insert end "purple"
		    $cl insert end "purple1"
		    $cl insert end "purple2"
		    $cl insert end "purple3"
		    $cl insert end "purple4"
		    $cl insert end "MediumPurple"
		    $cl insert end "MediumPurple1"
		    $cl insert end "MediumPurple2"
		    $cl insert end "MediumPurple3"
		    $cl insert end "MediumPurple4"
		    $cl insert end "thistle"
		    $cl insert end "thistle1"
		    $cl insert end "thistle2"
		    $cl insert end "thistle3"
		    $cl insert end "thistle4"
		    $cl insert end "violet"
		    $cl insert end "DarkViolet"
		    $cl insert end "VioletRed"
		    $cl insert end "VioletRed1"
		    $cl insert end "VioletRed2"
		    $cl insert end "VioletRed3"
		    $cl insert end "VioletRed4"
		    $cl insert end "PaleVioletRed"
		    $cl insert end "PaleVioletRed1"
		    $cl insert end "PaleVioletRed2"
		    $cl insert end "PaleVioletRed3"
		    $cl insert end "PaleVioletRed4"
		    $cl insert end "MediumVioletRed"
		}
	 	grey {
		    $cl insert end "black"
		    $cl insert end "DarkGrey"
		    $cl insert end "LightGrey"
		    $cl insert end "SlateGrey"
		    $cl insert end "LightSlateGrey"
		    $cl insert end "DarkSlateGrey"
		    $cl insert end "DarkSlateGray1"
		    $cl insert end "DarkSlateGray2"
		    $cl insert end "DarkSlateGray3"
		    $cl insert end "DarkSlateGray4"
		    $cl insert end "grey"
		    $cl insert end "grey0"
		    $cl insert end "grey1"
		    $cl insert end "grey2"
		    $cl insert end "grey3"
		    $cl insert end "grey4"
		    $cl insert end "grey5"
		    $cl insert end "grey6"
		    $cl insert end "grey7"
		    $cl insert end "grey8"
		    $cl insert end "grey9"
		    $cl insert end "grey10"
		    $cl insert end "grey11"
		    $cl insert end "grey12"
		    $cl insert end "grey13"
		    $cl insert end "grey14"
		    $cl insert end "grey15"
		    $cl insert end "grey16"
		    $cl insert end "grey17"
		    $cl insert end "grey18"
		    $cl insert end "grey19"
		    $cl insert end "grey20"
		    $cl insert end "grey21"
		    $cl insert end "grey22"
		    $cl insert end "grey23"
		    $cl insert end "grey24"
		    $cl insert end "grey25"
		    $cl insert end "grey26"
		    $cl insert end "grey27"
		    $cl insert end "grey28"
		    $cl insert end "grey29"
		    $cl insert end "grey30"
		    $cl insert end "grey31"
		    $cl insert end "grey32"
		    $cl insert end "grey33"
		    $cl insert end "grey34"
		    $cl insert end "grey35"
		    $cl insert end "grey36"
		    $cl insert end "grey37"
		    $cl insert end "grey38"
		    $cl insert end "grey39"
		    $cl insert end "grey40"
		    $cl insert end "grey41"
		    $cl insert end "grey42"
		    $cl insert end "grey43"
		    $cl insert end "grey44"
		    $cl insert end "grey45"
		    $cl insert end "grey46"
		    $cl insert end "grey47"
		    $cl insert end "grey48"
		    $cl insert end "grey49"
		    $cl insert end "grey50"
		    $cl insert end "grey51"
		    $cl insert end "grey52"
		    $cl insert end "grey53"
		    $cl insert end "grey54"
		    $cl insert end "grey55"
		    $cl insert end "grey56"
		    $cl insert end "grey57"
		    $cl insert end "grey58"
		    $cl insert end "grey59"
		    $cl insert end "grey60"
		    $cl insert end "grey61"
		    $cl insert end "grey62"
		    $cl insert end "grey63"
		    $cl insert end "grey64"
		    $cl insert end "grey65"
		    $cl insert end "grey66"
		    $cl insert end "grey67"
		    $cl insert end "grey68"
		    $cl insert end "grey69"
		    $cl insert end "grey70"
		    $cl insert end "grey71"
		    $cl insert end "grey72"
		    $cl insert end "grey73"
		    $cl insert end "grey74"
		    $cl insert end "grey75"
		    $cl insert end "grey76"
		    $cl insert end "grey77"
		    $cl insert end "grey78"
		    $cl insert end "grey79"
		    $cl insert end "grey80"
		    $cl insert end "grey81"
		    $cl insert end "grey82"
		    $cl insert end "grey83"
		    $cl insert end "grey84"
		    $cl insert end "grey85"
		    $cl insert end "grey86"
		    $cl insert end "grey87"
		    $cl insert end "grey88"
		    $cl insert end "grey89"
		    $cl insert end "grey90"
		    $cl insert end "grey91"
		    $cl insert end "grey92"
		    $cl insert end "grey93"
		    $cl insert end "grey94"
		    $cl insert end "grey95"
		    $cl insert end "grey96"
		    $cl insert end "grey97"
		    $cl insert end "grey98"
		    $cl insert end "grey99"
		    $cl insert end "grey100"
		}
	}
}

#------ reset Interface to start state

proc ResetInterface {} {
	global fntlist ff3 ff4 ff5 ff6 uv local_userfnt evv local_userfnt
	global local_treefnt_family local_treefnt_sz
	global local_fnt_family local_fnt_sz user_resource_changed

	option clear

	option add *background			$uv(background)
	option add *foreground			$uv(foreground)
	option add *activeBackground	$uv(activeBackground)
	option add *activeForeground	$uv(activeForeground)
	option add *selectColor			$uv(selectColor)
	option add *selectBackground	$uv(selectBackground)
	option add *troughColor			$uv(troughColor)
	option add *disabledForeground	$uv(disabledForeground)

	$ff3.normal  config -bg  $uv(background)
	$ff3.normal  config -fg  $uv(foreground)
	$ff3.active  config -bg  $uv(activeBackground)
	$ff3.active  config -fg  $uv(activeForeground)
	$ff3.select  config -fg  $uv(selectColor)
	$ff3.select  config -bg  $uv(selectBackground)
	$ff3.trough  config -bg  $uv(troughColor)
	$ff3.disabled config -fg $uv(disabledForeground)

	set local_fnt_family $uv(fnt_family)
	set local_fnt_sz $uv(fnt_sz)

	font config local_userfnt -family $local_fnt_family -size $local_fnt_sz

	$ff3.normal   config -font local_userfnt
	$ff3.active   config -font local_userfnt
	$ff3.select   config -font local_userfnt
	$ff3.trough   config -font local_userfnt
	$ff3.disabled config -font local_userfnt

	set local_treefnt_family $evv(T_FONT_STYLE)
	set local_treefnt_sz  $evv(T_FONT_SIZE)

	font config local_treefnt -family $local_treefnt_family -size $local_treefnt_sz -slant $evv(T_FONT_TYPE)
	font config local_deletefnt -family $local_treefnt_family -size $local_treefnt_sz -slant $evv(T_DELETE_TYPE)


	$ff5.active   config -bg $uv(on_color)
	$ff5.disabled config -bg $uv(off_color)
	$ff3.help	  config -bg $uv(help_color)
	$ff3.fquq 	  config -bg $uv(quit_color)
	$ff3.emph	  config -bg $uv(emphasis)
	$ff4.ee	  	  config -bg $uv(emphasis)
	$ff3.mark	  config -fg $uv(special)
	$ff5.pitchd   config -bg $uv(disable_color)
	$ff4.ei	   	  config -fg $uv(INF_COLR)
	$ff4.ew	   	  config -fg $uv(warning_textcolor)
	$ff4.ee	   	  config -fg $uv(error_textcolor)
	$ff4.bar.done config -bg $uv(pbar_donecolor)
	$ff4.bar	  config -bg $uv(pbar_notdonecolor)
	$ff4.ebar	  config -bg $uv(pbar_endcolor)
	$ff6.activ    config -bg $uv(tree_activebkgd)
	$ff6.activ    config -fg $uv(tree_activefgnd)
	$ff6.key      config -bg $uv(neutral_treecolor)
	$ff6.gap      config -bg $uv(neutral_treecolor)
	$ff6.snd      config -bg $uv(sound_treecolor)
	$ff6.anal	  config -bg $uv(analysis_treecolor)
	$ff6.pitch    config -bg $uv(pitch_treecolor)
	$ff6.trans    config -bg $uv(transpos_treecolor)
	$ff6.fmnt     config -bg $uv(formant_treecolor)
	$ff6.env	  config -bg $uv(envelope_treecolor)
	$ff6.txt	  config -bg $uv(text_treecolor)
	$ff6.mono	  config -bg $uv(mono_treecolor)

	set evv(SNDFILE_EXT) $uv(sndfile_extension)

	set user_resource_changed 0
}

#------ reset Interface to CDP state

proc ResetCDPInterface {} {
	global fntlist ff3 ff4 ff5 ff6 local_userfnt evv local_userfnt
	global local_treefnt_family local_treefnt_sz
	global local_fnt_family local_fnt_sz CDPd user_resource_changed

	option clear

	option add *background			$CDPd(background)
	option add *foreground			$CDPd(foreground)
	option add *activeBackground	$CDPd(activeBackground)
	option add *activeForeground	$CDPd(activeForeground)
	option add *selectColor			$CDPd(selectColor)
	option add *selectBackground	$CDPd(selectBackground)
	option add *troughColor			$CDPd(troughColor)
	option add *disabledForeground	$CDPd(disabledForeground)

	$ff3.normal  config -bg  $CDPd(background)
	$ff3.normal  config -fg  $CDPd(foreground)
	$ff3.active  config -bg  $CDPd(activeBackground)
	$ff3.active  config -fg  $CDPd(activeForeground)
	$ff3.select  config -fg  $CDPd(selectColor)
	$ff3.select  config -bg  $CDPd(selectBackground)
	$ff3.trough  config -bg  $CDPd(troughColor)
	$ff3.disabled config -fg $CDPd(disabledForeground)

	set local_fnt_family $CDPd(fnt_family)
	set local_fnt_sz $CDPd(fnt_sz)

	font config local_userfnt -family $local_fnt_family -size $local_fnt_sz

	$ff3.normal   config -font local_userfnt
	$ff3.active   config -font local_userfnt
	$ff3.select   config -font local_userfnt
	$ff3.trough   config -font local_userfnt
	$ff3.disabled config -font local_userfnt

	set local_treefnt_family $CDPd(tree_fnt_style)
	set local_treefnt_sz  $CDPd(tree_fnt_sz)

	font config local_treefnt -family $local_treefnt_family -size $local_treefnt_sz -slant $evv(T_FONT_TYPE)
	font config local_deletefnt -family $local_treefnt_family -size $local_treefnt_sz -slant $evv(T_DELETE_TYPE)

	$ff5.active   config -bg $CDPd(on_color)
	$ff5.disabled config -bg $CDPd(off_color)
	$ff3.help	  config -bg $CDPd(help_color)
	$ff3.fquq 	  config -bg $CDPd(quit_color)
	$ff3.emph	  config -bg $CDPd(emphasis)
	$ff4.ee		  config -bg $CDPd(emphasis)
	$ff3.mark	  config -fg $CDPd(special)
	$ff5.pitchd   config -bg $CDPd(disable_color)
	$ff4.ei	   	  config -fg $CDPd(INF_COLR)
	$ff4.ew	   	  config -fg $CDPd(warning_textcolor)
	$ff4.ee	   	  config -fg $CDPd(error_textcolor)
	$ff4.bar.done config -bg $CDPd(pbar_donecolor)
	$ff4.bar	  config -bg $CDPd(pbar_notdonecolor)
	$ff4.ebar	  config -bg $CDPd(pbar_endcolor)
	$ff6.activ    config -bg $CDPd(tree_activebkgd)
	$ff6.activ    config -fg $CDPd(tree_activefgnd)
	$ff6.key      config -bg $CDPd(neutral_treecolor)
	$ff6.gap      config -bg $CDPd(neutral_treecolor)
	$ff6.snd      config -bg $CDPd(sound_treecolor)
	$ff6.anal	  config -bg $CDPd(analysis_treecolor)
	$ff6.pitch    config -bg $CDPd(pitch_treecolor)
	$ff6.trans    config -bg $CDPd(transpos_treecolor)
	$ff6.fmnt     config -bg $CDPd(formant_treecolor)
	$ff6.env	  config -bg $CDPd(envelope_treecolor)
	$ff6.txt	  config -bg $CDPd(text_treecolor)
	$ff6.mono	  config -bg $CDPd(mono_treecolor)

	set evv(SNDFILE_EXT) $CDPd(sndfile_extension)

	set user_resource_changed 1
}

#------ Reset the user variables, ready to save

proc DoReset {} {
	global uv local_treefnt_family local_treefnt_sz evv
	global local_fnt_family local_fnt_sz user_resource_changed

	set evv(T_FONT_STYLE) $local_treefnt_family
	set evv(T_FONT_SIZE)  $local_treefnt_sz

	if {$uv(sndfile_extension) != $evv(SNDFILE_EXT)} {
		set user_resource_changed 1
	}
	if {$uv(default_srate) != $evv(DFLT_SR)} {
		set user_resource_changed 1
	}

	RememberUserEnvironment	;#	copy all new evv(X) settings to uv(X)

	font config treefnt -family $evv(T_FONT_STYLE) -size $evv(T_FONT_SIZE) -slant $evv(T_FONT_TYPE)
	font config treedeletefnt -family $evv(T_FONT_STYLE) -size $evv(T_FONT_SIZE) -slant $evv(T_DELETE_TYPE)

	set uv(fnt_family) $local_fnt_family
	set uv(fnt_sz) $local_fnt_sz
	font config userfnt -family $uv(fnt_family) -size $uv(fnt_sz)

	option clear

	option add *background			$uv(background)
	option add *foreground			$uv(foreground)
	option add *activeBackground	$uv(activeBackground)
	option add *activeForeground	$uv(activeForeground)
	option add *selectColor			$uv(selectColor)
	option add *selectBackground	$uv(selectBackground)
	option add *troughColor			$uv(troughColor)
	option add *disabledForeground	$uv(disabledForeground)
	option add *font				userfnt

	SaveUserEnvironmentAndResources
}


